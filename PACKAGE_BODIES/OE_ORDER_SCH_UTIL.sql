--------------------------------------------------------
--  DDL for Package Body OE_ORDER_SCH_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_SCH_UTIL" AS
/* $Header: OEXVSCHB.pls 120.5 2005/12/15 03:42:56 rmoharan noship $ */

G_PKG_NAME         CONSTANT     VARCHAR2(30):='OE_Schedule';
G_SOURCE_AGAIN     VARCHAR2(1)  := 'Y';
G_OVERRIDE_FLAG    VARCHAR2(1)  := 'N';
G_UPDATE_FLAG      VARCHAR2(1)  := FND_API.G_TRUE;
G_LINE_ACTION      VARCHAR2(30) := null;
G_HEADER_ID        NUMBER       := null;
G_DATE_TYPE        VARCHAR2(30) := null;
USER_SPLIT         CONSTANT     VARCHAR2(30) := 'USER_SPLIT';
SYSTEM_SPLIT       CONSTANT     VARCHAR2(30) := 'SYSTEM_SPLIT';
G_LINE_PART_OF_SET BOOLEAN      := FALSE;

FUNCTION Get_Date_Type
( p_header_id      IN NUMBER)
RETURN VARCHAR2;

Procedure Update_PO
(p_schedule_ship_date       IN DATE,
 p_source_document_id       IN VARCHAR2,
 p_source_document_line_id  IN VARCHAR2);

FUNCTION Item_Is_Ato_Model(p_line_rec   IN  OE_ORDER_PUB.line_rec_type)
RETURN BOOLEAN
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING ITEM IS ATO MODEL' , 1 ) ;
    END IF;
    IF p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL
    and p_line_rec.line_id = p_line_rec.ato_line_id
    THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RR: RETURNING TRUE' , 1 ) ;
       END IF;
       RETURN TRUE;
    ELSE
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RR: RETURNING FALSE' , 1 ) ;
       END IF;
       RETURN FALSE;

    END IF;

END Item_Is_Ato_Model;

/* --------------------------------------------------------------------
Function Name  : Group_Scheduling_Required
Description    : This function will return true if the line to be scheduled
			  is in a scheduling group:
                 Ship Set
                 Arrival Set
                 Ship Model Complete PTO
                 ATO Model
                 This function will also return true, for a different kind
                 of group: Lines which are split. When a line is split into
                 multiple lines, the scheduling (if one exists) for the line
                 also needs to split. This function will return TRUE if a line
                 is split and it has been scheduled. The main (Schedule Line)
                 function, will then log a delayed request to split the
                 scheduling on the line.

----------------------------------------------------------------------- */
FUNCTION Group_Scheduling_Required(p_line_rec     OE_ORDER_PUB.line_rec_type,
                                   p_old_line_rec OE_ORDER_PUB.line_rec_type)
RETURN BOOLEAN
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING GROUP_SCHEDULING_REQUIRED' , 1 ) ;
   END IF;

   -- If the operation is delete, we just need to unschedule this line.
   -- So we do not need to perform any group scheduling right away.

   IF p_line_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN
              RETURN FALSE;
   END IF;

   -- If the line belongs to a remnant set, we should not treat it in a
   -- group, even if it did belong to a scheduling group before the split.

   IF p_line_rec.model_remnant_flag = 'Y' THEN
              RETURN FALSE;
   END IF;


   IF (p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE) THEN

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IT IS A CREATE ACTION ON THE LINE' , 1 ) ;
         END IF;

         IF (p_line_rec.ship_set_id is not null AND
             p_line_rec.ship_set_id <> FND_API.G_MISS_NUM) OR
            (p_line_rec.arrival_set_id is not null AND
             p_line_rec.arrival_set_id <> FND_API.G_MISS_NUM) OR
            (p_line_rec.ship_model_complete_flag = 'Y') OR
            (p_line_rec.ato_line_id is not null AND
             p_line_rec.ato_line_id <> FND_API.G_MISS_NUM AND
             NOT (p_line_rec.ato_line_id = p_line_rec.line_id AND
                  p_line_rec.item_type_code IN (OE_GLOBALS.G_ITEM_STANDARD,
                                                OE_GLOBALS.G_ITEM_OPTION))) THEN

                   RETURN TRUE;

         END IF;
   END IF;

   IF (p_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IT IS A UPDATE ACTION ON THE LINE' , 1 ) ;
         END IF;

         IF (NOT OE_GLOBALS.Equal(p_line_rec.ship_set_id,
                                 p_old_line_rec.ship_set_id)
             AND p_line_rec.ship_set_id IS NOT NULL ) OR
            (NOT OE_GLOBALS.Equal(p_line_rec.arrival_set_id,
                                 p_old_line_rec.arrival_set_id)
             AND p_line_rec.arrival_set_id IS NOT NULL) THEN
            RETURN TRUE;
         END IF;

   END IF;


   -- If the ship_set_id has changed on the line, it means
   -- that the line is being added to a set, or being moved from
   -- one to another. This does not need group scheduling right away. We
   -- will just try to schedule the line as is.

   IF NOT OE_GLOBALS.Equal(p_line_rec.ship_set_id,
                           p_old_line_rec.ship_set_id)
   THEN
      RETURN FALSE;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_line_rec.arrival_set_id,
                           p_old_line_rec.arrival_set_id)
   THEN
      RETURN FALSE;
   END IF;


   -- If the line belongs to a set and the user is trying
   -- to unschedule the line, it is not group schedule.Or if you are
   -- trying to reserve the line, it is not a group schedule.

   IF (p_line_rec.ship_set_id is not null OR
       p_line_rec.arrival_set_id is not null OR
       p_line_rec.ship_model_complete_flag = 'Y') THEN

       IF (p_line_rec.schedule_action_code = OESCH_ACT_UNSCHEDULE OR
           p_line_rec.schedule_action_code = OESCH_ACT_UNRESERVE) THEN
           RETURN FALSE;
       END IF;

      -- Adding this code so that, if an item is changed on one of the line
      -- which belong to set require a group_scheduling.

        IF p_line_rec.operation =  OE_GLOBALS.G_OPR_UPDATE AND
           p_line_rec.schedule_status_code IS NOT NULL AND
           (NOT OE_GLOBALS.Equal(p_line_rec.inventory_item_id,
                               p_old_line_rec.inventory_item_id))

        THEN
          RETURN TRUE;
        END IF;

   END IF;


   IF (p_line_rec.ato_line_id is not null AND
       NOT (p_line_rec.ato_line_id = p_line_rec.line_id AND
            p_line_rec.item_type_code IN (OE_GLOBALS.G_ITEM_STANDARD,
                                          OE_GLOBALS.G_ITEM_OPTION))) OR
       (nvl(p_line_rec.ship_model_complete_flag,'N') = 'Y') OR
       (p_line_rec.ship_set_id is not null) OR
       (p_line_rec.arrival_set_id is not null)
   THEN
       IF (p_line_rec.schedule_action_code = OESCH_ACT_SCHEDULE OR
           p_line_rec.schedule_action_code = OESCH_ACT_UNSCHEDULE OR
           p_line_rec.schedule_action_code = OESCH_ACT_ATP_CHECK OR
           p_line_rec.schedule_action_code = OESCH_ACT_RESERVE AND
           p_line_rec.schedule_status_code is null)
       THEN
           RETURN TRUE;
       END IF;
   END IF;


   IF (p_line_rec.ato_line_id is not null) AND
       NOT (p_line_rec.ato_line_id = p_line_rec.line_id AND
            p_line_rec.item_type_code IN (OE_GLOBALS.G_ITEM_STANDARD,
                                          OE_GLOBALS.G_ITEM_OPTION))
   THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ITEM CHANGED IS ATO MODEL OR OPTION' , 1 ) ;
       END IF;

       -- Change of following attributes affects the whole set
       -- and thus we must create a group request for it.


       IF NOT OE_GLOBALS.Equal(p_line_rec.DEMAND_CLASS_CODE,
                               p_old_line_rec.DEMAND_CLASS_CODE)
       THEN
          RETURN TRUE;
       END IF;

       -- Added > 0 to fix bug 2019034.
       IF NOT OE_GLOBALS.Equal(p_line_rec.ORDERED_QUANTITY,
                               p_old_line_rec.ORDERED_QUANTITY)
       --AND p_line_rec.ORDERED_QUANTITY > 0
/* commented the above line for bug 2690471 */
       THEN
          RETURN TRUE;
       END IF;

       IF NOT OE_GLOBALS.Equal(p_line_rec.REQUEST_DATE,
                               p_old_line_rec.REQUEST_DATE)
       THEN
          RETURN TRUE;
       END IF;

       IF NOT OE_GLOBALS.Equal(p_line_rec.SHIP_FROM_ORG_ID,
                               p_old_line_rec.SHIP_FROM_ORG_ID)
       THEN
          RETURN TRUE;
       END IF;

       IF NOT OE_GLOBALS.Equal(p_line_rec.SHIP_TO_ORG_ID,
                               p_old_line_rec.SHIP_TO_ORG_ID)
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

   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'G6' , 1 ) ;
   END IF;

   IF (p_line_rec.ship_set_id is not null) OR
      (nvl(p_line_rec.ship_model_complete_flag,'N') = 'Y') THEN

       -- Change of following attributes affects the whole set
       -- and thus we must create a group request for it.

       IF NOT OE_GLOBALS.Equal(p_line_rec.SHIP_FROM_ORG_ID,
                               p_old_line_rec.SHIP_FROM_ORG_ID)
       THEN
          RETURN TRUE;
       END IF;

       IF NOT OE_GLOBALS.Equal(p_line_rec.SHIP_TO_ORG_ID,
                               p_old_line_rec.SHIP_TO_ORG_ID)
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

       IF (nvl(p_line_rec.ship_model_complete_flag,'N') = 'Y')
       THEN
         -- We will reschedule the whole set for change in ordered
         -- quantity of a ship_model_complete PTO only ).

         -- If the line is getting unscheduled due to cancellation
         -- let it not be group schedule.
         -- Added 0 check to fix 2019034.
         IF NOT OE_GLOBALS.Equal(p_line_rec.ORDERED_QUANTITY,
                                 p_old_line_rec.ORDERED_QUANTITY)
         AND p_line_rec.ORDERED_QUANTITY > 0
         THEN
            RETURN TRUE;
         END IF;

/* Commented the following lines to fix the bug 2720398
         IF NOT OE_GLOBALS.Equal(p_line_rec.SHIPPING_METHOD_CODE,
                                 p_old_line_rec.SHIPPING_METHOD_CODE)
         THEN
            RETURN TRUE;
         END IF;
*/

       END IF;

/* Added the following if condition to fix the bug 2720398 */

         IF NOT OE_GLOBALS.Equal(p_line_rec.SHIPPING_METHOD_CODE,
                                 p_old_line_rec.SHIPPING_METHOD_CODE)
         THEN
            RETURN TRUE;
         END IF;

/* End of new code added to fix the bug 2720398 */

       IF NOT OE_GLOBALS.Equal(p_line_rec.REQUEST_DATE,
                               p_old_line_rec.REQUEST_DATE)
       THEN
          RETURN TRUE;
       END IF;

   END IF;

   IF (p_line_rec.arrival_set_id is not null) THEN

       -- Change of following attributes affects the whole set
       -- and thus we must create a group request for it.


       IF NOT OE_GLOBALS.Equal(p_line_rec.SCHEDULE_ARRIVAL_DATE,
                               p_old_line_rec.SCHEDULE_ARRIVAL_DATE)
       THEN
          RETURN TRUE;
       END IF;

       IF NOT OE_GLOBALS.Equal(p_line_rec.SCHEDULE_SHIP_DATE,
                               p_old_line_rec.SCHEDULE_SHIP_DATE)
       THEN
          RETURN TRUE;
       END IF;

       IF NOT OE_GLOBALS.Equal(p_line_rec.SHIP_TO_ORG_ID,
                               p_old_line_rec.SHIP_TO_ORG_ID)
       THEN
          RETURN TRUE;
       END IF;

       IF NOT OE_GLOBALS.Equal(p_line_rec.REQUEST_DATE,
                               p_old_line_rec.REQUEST_DATE)
       THEN
          RETURN TRUE;
       END IF;

   END IF;

   RETURN FALSE;
END Group_Scheduling_Required;

/* --------------------------------------------------------------------
Procedure Name : Update_Group_Sch_Results
Description    :
----------------------------------------------------------------------- */

Procedure Update_Group_Sch_Results
(p_x_line_rec      IN OUT NOCOPY /* file.sql.39 change */ OE_ORDER_PUB.line_rec_type,
 x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
l_line_rec   OE_ORDER_PUB.line_rec_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
--  x_line_rec := p_line_rec;

--  l_line_rec := OE_Line_Util.Query_Row
--                         (p_line_id => p_x_line_rec.line_id);

  OE_Line_Util.Query_Row(p_line_id    => p_x_line_rec.line_id,
					x_line_rec   => l_line_rec);

  IF NOT OE_GLOBALS.Equal(p_x_line_rec.ship_from_org_id,
                          l_line_rec.ship_from_org_id)
  THEN
     p_x_line_rec.ship_from_org_id := l_line_rec.ship_from_org_id;
  END IF;

  IF NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_ship_date,
                          l_line_rec.schedule_ship_date)
  THEN
     p_x_line_rec.schedule_ship_date := l_line_rec.schedule_ship_date;
  END IF;

  IF NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_arrival_date,
                          l_line_rec.schedule_arrival_date)
  THEN
    p_x_line_rec.schedule_arrival_date := l_line_rec.schedule_arrival_date;
  END IF;

  IF NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_status_code,
                          l_line_rec.schedule_status_code)
  THEN
     p_x_line_rec.schedule_status_code := l_line_rec.schedule_status_code;
  END IF;

  IF NOT OE_GLOBALS.Equal(p_x_line_rec.shipping_method_code,
                          l_line_rec.shipping_method_code)
  THEN
    p_x_line_rec.shipping_method_code := l_line_rec.shipping_method_code;
  END IF;

  IF NOT OE_GLOBALS.Equal(p_x_line_rec.visible_demand_flag,
                          l_line_rec.visible_demand_flag)
  THEN
    p_x_line_rec.visible_demand_flag := l_line_rec.visible_demand_flag;
  END IF;

END Update_Group_Sch_Results;

/* -----------------------------------------------------------
Procedure   : Build_Included_Items
Description : This API is called when you want to get the included
		    items for a particular order line (if the order line
              is model, class or kit).
              When a model, class or kit is scheduled, the included
              items under it should also get scheduled. This
              API returns back the included items for item.

              For the following cases, it just queries the included items
              and returns them to the calling API:
              1. If the included items are frozen (explosion date is
                 populated on the line).
              2. The action on the line is UNSCHEDULE or UNRESERVE
              3. The operation on the line is DELETE.

              If will explode the included items (by calling
              process_included_items) for the following cases

              1. Explosion date is null on the line and operation is
                 UPDATE on the line.


----------------------------------------------------------- */
PROCEDURE Build_Included_Items
             (p_line_rec IN OE_ORDER_PUB.line_rec_type,
              x_line_tbl IN OUT NOCOPY OE_ORDER_PUB.line_tbl_type)
IS
--l_line_tbl          OE_ORDER_PUB.line_tbl_type;
l_validation_org    NUMBER;
l_group_id          NUMBER;
l_session_id        NUMBER;
l_levels            NUMBER;
l_stdcompflag       VARCHAR2(30);
l_exp_quantity      NUMBER;
l_return_status     VARCHAR2(1);
l_explode           BOOLEAN;
is_set_recursion    VARCHAR2(1) := 'Y';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING BUILD_INCLUDED_ITEMS' , 1 ) ;
    END IF;

    IF ((p_line_rec.schedule_action_code = OESCH_ACT_UNSCHEDULE) OR
        (p_line_rec.schedule_action_code = OESCH_ACT_UNDEMAND) OR
        (p_line_rec.schedule_action_code = OESCH_ACT_UNRESERVE)) THEN
        l_explode := FALSE;
    END IF;

    IF p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
        l_explode := TRUE;
    END IF;

    IF p_line_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN
        l_explode := FALSE;
    END IF;

    IF p_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RR:I1' ) ;
       END IF;
       IF p_line_rec.explosion_date is not null AND
          p_line_rec.explosion_date <> FND_API.G_MISS_DATE THEN
          l_explode := FALSE;
       ELSE
          l_explode := TRUE;
       END IF;
    END IF;

    IF l_explode THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'L_EXPLODE IS TRUE' , 1 ) ;
        END IF;
    ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'L_EXPLODE IS FALSE' , 1 ) ;
        END IF;
    END IF;

    IF l_explode THEN

        -- Set the recursion flag here to suppress sets related logic

        IF NOT oe_set_util.g_set_recursive_flag  THEN
           is_set_recursion := 'N';
           oe_set_util.g_set_recursive_flag := TRUE;
        END IF;

          -- Calling Process_Included_Items. This procedure
          -- will take care of explosions and updateing the picture
          -- of included_items in the oe_order_lines table.

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'CALLING PROCESS_INCLUDED_ITEMS' , 1 ) ;
          END IF;

          l_return_status := OE_CONFIG_UTIL.Process_Included_Items
                               (p_line_id  => p_line_rec.line_id,
                                p_freeze    => FALSE);

          IF is_set_recursion = 'N'  THEN
             is_set_recursion := 'Y';
             oe_set_util.g_set_recursive_flag := FALSE;
          END IF;


          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

--          x_line_tbl :=
--               oe_config_util.query_included_items(p_line_rec.line_id);

		OE_Config_Util.Query_Included_Items(p_line_id  => p_line_rec.line_id,
									 p_header_id => p_line_rec.header_id,
									 p_top_model_line_id => p_line_rec.top_model_line_id,
									 x_line_tbl => x_line_tbl);

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'COUNT IS: ' || X_LINE_TBL.COUNT , 1 ) ;
          END IF;
    ELSE

        -- Query the records from the database

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'QUERYING INCLUDED ITEMS' , 1 ) ;
        END IF;

--        x_line_tbl :=
--               oe_config_util.query_included_items(p_line_rec.line_id);

	   OE_Config_Util.Query_Included_Items(p_line_id  => p_line_rec.line_id,
								    p_header_id => p_line_rec.header_id,
								    p_top_model_line_id => p_line_rec.top_model_line_id,
                                            x_line_tbl => x_line_tbl);
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'COUNT IS: ' || X_LINE_TBL.COUNT , 1 ) ;
        END IF;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING BUILD_INCLUDED_ITEMS' , 1 ) ;
    END IF;
--    RETURN l_line_tbl;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Build_Included_Items'
            );
        END IF;


    WHEN OTHERS THEN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Build_Included_Items'
            );
        END IF;

END Build_Included_Items;

/* -----------------------------------------------------------
Procedure: Schedule_Parent_line
Description:This procedure will be called, if the user is trying to
            schedule a parent (a model or a class)  of a non-ship model
            complete PTO. We need to get included items associated with the
            parent before we schedule the line.
---------------------------------------------------------------*/
Procedure Schedule_Parent_line
( p_old_line_rec  IN  OE_ORDER_PUB.line_rec_type
, p_write_to_db   IN  VARCHAR2
, p_x_line_rec    IN OUT NOCOPY OE_ORDER_PUB.line_rec_type
, p_recursive_call IN VARCHAR2
, x_out_atp_tbl   OUT NOCOPY /* file.sql.39 change */ OE_ATP.Atp_Tbl_Type
, x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
l_line_rec             OE_ORDER_PUB.line_rec_type;
l_line_tbl             OE_ORDER_PUB.line_tbl_type;
l_new_line_tbl         OE_ORDER_PUB.line_tbl_type;
l_included_items_tbl   OE_ORDER_PUB.line_tbl_type;
l_old_line_tbl         OE_ORDER_PUB.line_tbl_type;
l_inc_upd_tbl          OE_ORDER_PUB.line_tbl_type;
l_inc_upd_index        NUMBER;
l_inc_old_tbl          OE_ORDER_PUB.line_tbl_type;
l_inc_old_index        NUMBER;
l_top_old_tbl          OE_ORDER_PUB.line_tbl_type;
l_top_old_index        NUMBER;
l_explode              BOOLEAN;
l_old_ordered_quantity NUMBER;
l_out_line_rec         OE_ORDER_PUB.line_rec_type;
K                      NUMBER :=0;
atp_count              NUMBER :=0;
l_out_atp_tbl          OE_ATP.atp_tbl_type;
l_return_status        VARCHAR2(1);
l_schedule_action_code VARCHAR2(30);
l_sales_order_id       NUMBER;
l_old_recursion_mode   VARCHAR2(1);
l_process_requests     BOOLEAN;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING SCHEDULE PARENT LINE '||P_X_LINE_REC.SCHEDULE_ACTION_CODE , 1 ) ;
  END IF;

  l_line_tbl(1)     := p_x_line_rec;
  l_old_line_tbl(1) := p_old_line_rec;
  l_top_old_tbl(1)  := p_old_line_rec;

  -- We need to figure out the action which needs to be performed.

/*
  IF p_x_line_rec.schedule_action_code is null THEN
     IF p_x_line_rec.schedule_status_code is null THEN
        -- The line was never scheduled before. So it needs to
        -- get scheduled.
        l_schedule_action_code := OESCH_ACT_SCHEDULE;
     ELSIF p_x_line_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN
        l_schedule_action_code := OESCH_ACT_UNSCHEDULE;
     ELSE
        l_schedule_action_code := OESCH_ACT_RESCHEDULE;
     END IF;
  ELSE
     l_schedule_action_code := p_x_line_rec.schedule_action_code;
  END IF;

  l_line_tbl(1).schedule_action_code := l_schedule_action_code;
  oe_debug_pub.add('Action is ' || l_schedule_action_code,1);

*/

  -- The primary reason to have this procedure for parent lines
  -- is because we need to prepare included items to scheduling when
  -- it's parent is scheduled. Depending on the action needed to be performed,
  -- we might need to explode the included items.

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SCH:CALLING BUILD_INCLUDED_ITEMS' , 1 ) ;
  END IF;

--  l_included_items_tbl := Build_Included_Items
--                          (p_line_rec => p_x_line_rec);

   l_old_recursion_mode := OE_GLOBALS.G_RECURSION_MODE;

   IF p_recursive_call = FND_API.G_TRUE
   THEN

     -- OE_GLOBALS.G_RECURSION_MODE := 'Y';
     null;

   END IF;

  Build_Included_Items( p_line_rec => p_x_line_rec,
                        x_line_tbl => l_included_items_tbl);

  -- OE_GLOBALS.G_RECURSION_MODE :=  l_old_recursion_mode;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SCH:AFTER CALLING BUILD_INCLUDED_ITEMS' , 1 ) ;
  END IF;

  -- Starting with the index of 2 since the first element has
  -- been occupied by the parent line.

  -- Get reserved quantity for the lines.
  l_sales_order_id := OE_ORDER_SCH_UTIL.Get_mtl_sales_order_id
                                              (p_x_line_rec.HEADER_ID);

  l_inc_old_index := 0;
  l_top_old_index := 0;

  K := 2;
  FOR I IN 1..l_included_items_tbl.count LOOP

       l_line_rec := l_included_items_tbl(I);

	  IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(  'SCHEDULE_STATUS CODE/LINE : '||L_LINE_REC.SCHEDULE_STATUS_CODE||'/'||L_LINE_REC.LINE_ID , 3 ) ;
	  END IF;

       IF p_x_line_rec.schedule_action_code = OESCH_ACT_SCHEDULE AND
		l_line_rec.schedule_status_code IS NOT NULL THEN

          GOTO END_INCLUDED;

	  END IF;

       l_old_line_tbl(K) := l_line_rec;

       l_line_rec.schedule_action_code :=
                         p_x_line_rec.schedule_action_code;

       l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;

       /* -----------Bug 2315471 Start ---------------------*/

       IF NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity,
                               p_old_line_rec.ordered_quantity)
       AND p_x_line_rec.ordered_quantity = 0 THEN
         l_line_rec.schedule_action_code := OESCH_ACT_UNDEMAND;
       END IF;

       /* -----------Bug 2315471 End -----------------------*/


       IF NOT OE_GLOBALS.Equal(p_x_line_rec.ship_from_org_id,
                           p_old_line_rec.ship_from_org_id) OR
          l_line_rec.ship_from_org_id IS NULL OR
		l_line_rec.ship_from_org_id = FND_API.G_MISS_NUM
       THEN
           l_line_rec.ship_from_org_id :=
                         p_x_line_rec.ship_from_org_id;
       END IF;

	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'OLD ORDERED QUANTITY : '|| P_OLD_LINE_REC.ORDERED_QUANTITY , 3 ) ;
	     oe_debug_pub.add(  'NEW ORDERED QUANTITY : '|| P_X_LINE_REC.ORDERED_QUANTITY , 3 ) ;
	 END IF;
       IF NOT OE_GLOBALS.Equal(p_x_line_rec.ordered_quantity,
                              p_old_line_rec.ordered_quantity)
       THEN
           l_old_ordered_quantity := p_old_line_rec.ordered_quantity;
           IF l_old_ordered_quantity IS null OR
              l_old_ordered_quantity = 0 OR
              l_old_ordered_quantity = FND_API.G_MISS_NUM THEN
              l_old_ordered_quantity := p_x_line_rec.ordered_quantity;
       END IF;

	  IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(  'OLD ORDERED QUANTITY : '|| L_OLD_ORDERED_QUANTITY , 3 ) ;
	  END IF;
/*
       l_line_rec.ordered_quantity := l_line_rec.ordered_quantity *
                                      p_x_line_rec.ordered_quantity /
                                      l_old_ordered_quantity;
*/
       END IF;


       IF NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_ship_date,
                           p_old_line_rec.schedule_ship_date)
       THEN
          l_line_rec.schedule_ship_date := p_x_line_rec.schedule_ship_date;
       END IF;

       IF NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_arrival_date,
                               p_old_line_rec.schedule_arrival_date)
       THEN
          l_line_rec.schedule_arrival_date :=
                            p_x_line_rec.schedule_arrival_date;
       END IF;

       IF NOT OE_GLOBALS.Equal(p_x_line_rec.shipping_method_code,
                               p_old_line_rec.shipping_method_code)
       THEN
          l_line_rec.shipping_method_code :=
                            p_x_line_rec.shipping_method_code;
       END IF;

       IF NOT OE_GLOBALS.Equal(p_x_line_rec.delivery_lead_time,
                               p_old_line_rec.delivery_lead_time)
       THEN
          l_line_rec.delivery_lead_time := p_x_line_rec.delivery_lead_time;
       END IF;

       l_line_rec.reserved_quantity :=
              OE_LINE_UTIL.Get_Reserved_Quantity
                 (p_header_id   => l_sales_order_id,
                  p_line_id     => l_line_rec.line_id,
			   p_org_id      => l_line_rec.ship_from_org_id);

	  -- Assigning the quried reserved quantity to old record to fix bug 1567015.

	  l_old_line_tbl(k).reserved_quantity := l_line_rec.reserved_quantity;

       l_line_tbl(K) := l_line_rec;

	  IF l_line_rec.line_id = p_x_line_rec.line_id THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ADDED TO TOP OLD TABLE '||L_LINE_REC.LINE_ID , 3 ) ;
		END IF;
          l_top_old_index := l_top_old_index + 1;
          l_top_old_tbl(l_top_old_index) := l_old_line_tbl(K);
       ELSE
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ADDED TO INCLUDED OLD TABLE '||L_LINE_REC.LINE_ID , 3 ) ;
		END IF;
          l_inc_old_index := l_inc_old_index + 1;
          l_inc_old_tbl(l_inc_old_index) := l_old_line_tbl(K);

	  END IF;

       K := K+1;

	  << END_INCLUDED >>
	  NULL;

  END LOOP;

  l_inc_upd_index := 0;

  FOR  I in 1..l_line_tbl.count LOOP

     l_out_line_rec := l_line_tbl(I);
     Process_request(p_x_line_rec  => l_out_line_rec,
                  p_old_line_rec   => l_old_line_tbl(I),
                  x_out_atp_tbl    => l_out_atp_tbl ,
                  x_return_status  => l_return_status);

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF p_x_line_rec.line_id = l_out_line_rec.line_id THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ASSIGNING TO NEW TABLE '||L_OUT_LINE_REC.ORDERED_QUANTITY , 3 ) ;
        END IF;
        l_new_line_tbl(I) := l_out_line_rec;
	ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ASSIGNING TO INCLUDED TABLE '||L_OUT_LINE_REC.ORDERED_QUANTITY , 3 ) ;
        END IF;
        l_inc_upd_index := l_inc_upd_index + 1;
        l_inc_upd_tbl(l_inc_upd_index) := l_out_line_rec;

	END IF;

     l_line_tbl(I) := l_out_line_rec;

     IF l_out_atp_tbl.count = 1 THEN
        atp_count := atp_count + 1;
        x_out_atp_tbl(atp_count)  := l_out_atp_tbl(1);
     END IF;
  END LOOP;

  -- Update order lines if the scheduling resulted in any attribute change.

  IF NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_action_code,
                              OESCH_ACT_ATP_CHECK) AND
     NOT OE_GLOBALS.Equal(p_x_line_rec.schedule_action_code,
                              OESCH_ACT_UNRESERVE) AND
     g_update_flag = FND_API.G_TRUE
  THEN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CALLING UPDATE_LINE_RECORD WITH NEW TABLE ' , 1 ) ;
     END IF;

     Update_line_record(p_line_tbl      => l_top_old_tbl,
                        p_x_new_line_tbl  => l_new_line_tbl,
                        p_write_to_db   => p_write_to_db,
			         p_recursive_call => p_recursive_call,
                        x_return_status => l_return_status);

                                          IF l_debug_level  > 0 THEN
                                              oe_debug_pub.add(  'AFTER CALLING UPDATE_LINE_RECORD :' || L_RETURN_STATUS , 1 ) ;
                                          END IF;

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF l_inc_upd_index <> 0 THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING UPDATE_LINE_RECORD WITH INC TABLE '||L_INC_UPD_INDEX||'/'||L_INC_OLD_INDEX , 2 ) ;
        END IF;

        Update_line_record(p_line_tbl      => l_inc_old_tbl,
                           p_x_new_line_tbl  => l_inc_upd_tbl,
                           p_write_to_db   => FND_API.G_TRUE,
		   	            p_recursive_call => p_recursive_call,
                           x_return_status => l_return_status);

                                          IF l_debug_level  > 0 THEN
                                              oe_debug_pub.add(  'AFTER CALLING UPDATE_LINE_RECORD :' || L_RETURN_STATUS , 1 ) ;
                                          END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    -- Do not process delayed requests if this was a recursive
    -- call (e.g. from oe_line_util.pre_write_process)
    IF p_recursive_call = FND_API.G_TRUE THEN
        l_process_requests := FALSE;
    ELSE
        l_process_requests := TRUE;
    END IF;

    -- 2351698.
    IF OESCH_SCH_POST_WRITE = 'Y' THEN

       l_line_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;

    END IF;

    OE_Order_PVT.Process_Requests_And_Notify
    ( p_process_requests        => l_process_requests
    , p_notify                  => TRUE
    , p_line_tbl                => l_line_tbl
    , p_old_line_tbl            => l_old_line_tbl
    , x_return_status           => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  p_x_line_rec  := l_new_line_tbl(1);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING SCHEDULE PARENT LINE' , 1 ) ;
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
            ,   'Schedule_Parent_line'
            );
        END IF;


END Schedule_Parent_line;

/*-----------------------------------------------------------------------
Procedure Name : Reschedule_Set
Description    : ** Currently Not Used **
-------------------------------------------------------------------------- */
Procedure  Reschedule_Set
(p_line_rec     IN  OE_ORDER_PUB.line_rec_type,
p_old_line_rec  IN  OE_ORDER_PUB.line_rec_type,
x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
l_return_status  VARCHAR2(1);
l_line_tbl       OE_ORDER_PUB.line_tbl_type;
l_old_line_tbl   OE_ORDER_PUB.line_tbl_type;
l_atp_tbl        OE_ATP.atp_tbl_type;
l_count          NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING RESCHEDULE_SET' , 1 ) ;
  END IF;
  x_return_status := l_return_status;
--  l_line_tbl := OE_Set_util.Query_Set_Rows(p_line_rec.ship_set_id);
  OE_Set_Util.Query_Set_Rows(p_set_id  => p_line_rec.ship_set_id,
							 x_line_tbl => l_line_tbl);

  -- Let us first unschedule the whole set
  FOR I IN 1..l_line_tbl.count LOOP
      l_line_tbl(I).schedule_action_code :=
                         OE_ORDER_SCH_UTIL.OESCH_ACT_UNDEMAND;
  END LOOP;

  OE_GRP_SCH_UTIL.Process_set_of_lines
           ( p_old_line_tbl  => l_old_line_tbl,
            p_write_to_db   => FND_API.G_FALSE,
            x_atp_tbl       => l_atp_tbl,
            p_x_line_tbl      => l_line_tbl,
            x_return_status => l_return_status);

  -- Now let us try to schedule the whole set with the new line
  -- which was to be inserted to the set.

  l_count                 := l_line_tbl.count;

  l_line_tbl(l_count+1)     := p_line_rec;
  l_old_line_tbl(l_count+1) := p_old_line_rec;

  -- Let us now schedule the whole set
  FOR I IN 1..l_line_tbl.count LOOP
      l_line_tbl(I).schedule_action_code :=
                         OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE;
  END LOOP;

  OE_GRP_SCH_UTIL.Process_set_of_lines
           ( p_old_line_tbl  => l_old_line_tbl,
            p_write_to_db   => FND_API.G_FALSE,
            x_atp_tbl       => l_atp_tbl,
            p_x_line_tbl      => l_line_tbl,
            x_return_status => l_return_status);

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING RESCHEDULE_SET' , 1 ) ;
  END IF;
END;
/*---------------------------------------------------------------------
Procedure Name : Action_Undemand
Description    : This procedure is called from SCHEDULE LINE proecudure
                 to perform the UNDEMAD on the line when an item is changed.
--------------------------------------------------------------------- */

Procedure Action_Undemand(p_old_line_rec  IN  OE_ORDER_PUB.line_rec_type,
                          x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)

IS
l_old_line_tbl            OE_ORDER_PUB.line_tbl_type;
l_return_status           VARCHAR2(1);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(2000);
l_session_id              NUMBER := 0;
l_mrp_atp_rec             MRP_ATP_PUB.ATP_Rec_Typ;
l_out_mtp_atp_rec         MRP_ATP_PUB.ATP_Rec_Typ;
l_atp_supply_demand       MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_atp_period              MRP_ATP_PUB.ATP_Period_Typ;
l_atp_details             MRP_ATP_PUB.ATP_Details_Typ;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'ENTERING ACTION_UNDEMAND' , 1 ) ;
       END IF;

      -- Create MRP record with action of UNDEMAND.



         l_old_line_tbl(1) := p_old_line_rec;
         l_old_line_tbl(1).schedule_action_code := OESCH_ACT_UNDEMAND;

        Load_MRP_Request
          ( p_line_tbl              => l_old_line_tbl
          , p_old_line_tbl          => l_old_line_tbl
          , x_atp_table             => l_mrp_atp_rec);

        l_session_id := Get_Session_Id;

        -- Call ATP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  '4. CALLING MRP API WITH SESSION ID '||L_SESSION_ID , 1 ) ;
        END IF;

        MRP_ATP_PUB.Call_ATP
          ( p_session_id             =>  l_session_id
          , p_atp_rec                =>  l_mrp_atp_rec
          , x_atp_rec                =>  l_out_mtp_atp_rec
          , x_atp_supply_demand      =>  l_atp_supply_demand
          , x_atp_period             =>  l_atp_period
          , x_atp_details            =>  l_atp_details
          , x_return_status          =>  l_return_status
          , x_msg_data               =>  l_msg_data
          , x_msg_count              =>  l_msg_count);

                                              IF l_debug_level  > 0 THEN
                                                  oe_debug_pub.add(  '4. AFTER CALLING MRP_ATP_PUB.CALL_ATP' || L_RETURN_STATUS , 1 ) ;
                                              END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'EXITING ACTION_UNDEMAND' , 1 ) ;
       END IF;

END Action_Undemand;

/*-----------------------------------------------------------------------
Procedure Name : Schedule_line
Description    : This routine is called when:
                   Schedule_action is entered on a line
                   Scheduling Attribute Changes on the line
                 This procedure will take the new attributes and compares
                 them to the old attributes and decide on what scheduling
                 action needs to be performed.
                 This API is called From
                 1. Process_Order (in pre_write_process in OEXULINB.pls)
                 2. Schedule Workflow Process (in OEXWSCHB.pls)
                 3. Schedule_Order process (in OEXVGRPB.pls)
                 4. Sch_Multi_Selected_Lines (in OEXVGRPB.pls)

-------------------------------------------------------------------------- */

Procedure Schedule_line( p_old_line_rec      IN  OE_ORDER_PUB.line_rec_type,
                        p_write_to_db        IN  VARCHAR2,
                        p_update_flag        IN  VARCHAR2 := FND_API.G_TRUE,
			         					p_recursive_call     IN  VARCHAR2 := FND_API.G_TRUE,
                        p_x_line_rec         IN OUT NOCOPY OE_ORDER_PUB.line_rec_type,
                        x_atp_tbl            OUT NOCOPY /* file.sql.39 change */ OE_ATP.atp_tbl_type,
                        x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                      )
IS
l_schedule_line_rec      request_rec_type;
l_line_rec               OE_ORDER_PUB.line_rec_type;
l_line_tbl               OE_ORDER_PUB.line_tbl_type;
l_new_line_tbl           OE_ORDER_PUB.line_tbl_type;
l_old_line_rec           OE_ORDER_PUB.line_rec_type;
l_out_line_rec           OE_ORDER_PUB.line_rec_type;
l_out_atp_tbl            OE_ATP.atp_tbl_type;
l_request_rec            request_rec_type;
l_group_req_rec          OE_GRP_SCH_UTIL.Sch_Group_Rec_Type;
l_out_request_rec        request_rec_type;
l_need_sch               BOOLEAN;
l_entity_type            VARCHAR2(30);
l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_dummy                  VARCHAR2(240);
l_set_id                 NUMBER;
l_sales_order_id         NUMBER;
l_request_type           VARCHAR2(30);
l_schedule_ship_date     DATE;
l_schedule_arrival_date  DATE;
l_action                 VARCHAR2(30);
l_o_request_date         DATE   := null;
l_o_sch_ship_date        DATE   := null;
l_o_sch_arr_date         DATE   := null;
l_o_ship_from_org_id     NUMBER := null;
l_o_ship_to_org_id       NUMBER := null;
l_o_ord_qty              NUMBER := null;
l_o_ord_qty2             NUMBER := null; -- INVCONV
l_type_code              VARCHAR2(30);
l_param                  NUMBER;
l_process_requests       BOOLEAN;
l_set_rec                OE_ORDER_CACHE.set_rec_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  '56: ENTERING OE_ORDER_SCH_UTIL.SCHEDULE_LINE' , 1 ) ;
      oe_debug_pub.add(  '---- OLD RECORD ---- ' , 1 ) ;
      oe_debug_pub.add(  'LINE ID : ' || P_OLD_LINE_REC.LINE_ID , 1 ) ;
      oe_debug_pub.add(  'ATO LINE ID : ' || P_OLD_LINE_REC.ATO_LINE_ID , 1 ) ;
      oe_debug_pub.add(  'ORDERED QUANTITY : ' || P_OLD_LINE_REC.ORDERED_QUANTITY , 1 ) ;
      oe_debug_pub.add(  'SHIP FROM : ' || P_OLD_LINE_REC.SHIP_FROM_ORG_ID , 1 ) ;
      oe_debug_pub.add(  'SUBINVENTORY : ' || P_OLD_LINE_REC.SUBINVENTORY , 1 ) ;
      oe_debug_pub.add(  'SCH SHIP DATE : ' || P_OLD_LINE_REC.SCHEDULE_SHIP_DATE , 1 ) ;
      oe_debug_pub.add(  'SCH ARRIVAL DATE : ' || P_OLD_LINE_REC.SCHEDULE_ARRIVAL_DATE , 1 ) ;
      oe_debug_pub.add(  'SHIP SET ID : ' || P_OLD_LINE_REC.SHIP_SET_ID , 1 ) ;
      oe_debug_pub.add(  'ARRIVAL SET ID : ' || P_OLD_LINE_REC.ARRIVAL_SET_ID , 1 ) ;
      oe_debug_pub.add(  'ACTION : ' || P_OLD_LINE_REC.SCHEDULE_ACTION_CODE , 1 ) ;
      oe_debug_pub.add(  'STATUS : ' || P_OLD_LINE_REC.SCHEDULE_STATUS_CODE , 1 ) ;
      oe_debug_pub.add(  'RESERVED QUANTITY: ' || P_OLD_LINE_REC.RESERVED_QUANTITY , 1 ) ;
      oe_debug_pub.add(  ' ' , 1 ) ;
      oe_debug_pub.add(  '---- NEW RECORD ----' , 1 ) ;
      oe_debug_pub.add(  'LINE ID : ' || P_X_LINE_REC.LINE_ID , 1 ) ;
      oe_debug_pub.add(  'ATO LINE ID : ' || P_X_LINE_REC.ATO_LINE_ID , 1 ) ;
      oe_debug_pub.add(  'ORDERED QUANTITY : ' || P_X_LINE_REC.ORDERED_QUANTITY , 1 ) ;
       oe_debug_pub.add(  'ORDERED QUANTITY2 : ' || P_X_LINE_REC.ORDERED_QUANTITY2 , 1 ) ;
      oe_debug_pub.add(  'SHIP FROM : ' || P_X_LINE_REC.SHIP_FROM_ORG_ID , 1 ) ;
      oe_debug_pub.add(  'SUBINVENTORY : ' || P_X_LINE_REC.SUBINVENTORY , 1 ) ;
      oe_debug_pub.add(  'SCH SHIP DATE : ' || P_X_LINE_REC.SCHEDULE_SHIP_DATE , 1 ) ;
      oe_debug_pub.add(  'SCH ARRIVAL DATE : ' || P_X_LINE_REC.SCHEDULE_ARRIVAL_DATE , 1 ) ;
      oe_debug_pub.add(  'SHIP SET ID : ' || P_X_LINE_REC.SHIP_SET_ID , 1 ) ;
      oe_debug_pub.add(  'ARRIVAL SET ID : ' || P_X_LINE_REC.ARRIVAL_SET_ID , 1 ) ;
      oe_debug_pub.add(  'ACTION : ' || P_X_LINE_REC.SCHEDULE_ACTION_CODE , 1 ) ;
      oe_debug_pub.add(  'STATUS : ' || P_X_LINE_REC.SCHEDULE_STATUS_CODE , 1 ) ;
      oe_debug_pub.add(  'RESERVED QTY : ' || P_X_LINE_REC.RESERVED_QUANTITY , 1 ) ;
            oe_debug_pub.add(  'RESERVED QTY2 : ' || P_X_LINE_REC.RESERVED_QUANTITY2 , 1 ) ;
      oe_debug_pub.add(  'OPERATION : ' || P_X_LINE_REC.OPERATION , 1 ) ;
      oe_debug_pub.add(  ' ' , 1 ) ;
  END IF;


  l_line_rec        := p_x_line_rec;
  l_old_line_rec    := p_old_line_rec;

  -- Copying the value of p_update_flag to g_update_flag. G_UPDATE_FLAG
  -- value might be modified by process_request procedure.

  g_update_flag := p_update_flag;

  -- We need to decide the value of re_source_flag of the line before
  -- we proceed with scheduling.

  IF l_line_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN
      l_line_rec.ship_from_org_id := null;
  END IF;

  IF l_old_line_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN
      l_old_line_rec.ship_from_org_id := null;
  END IF;


  IF NOT OE_GLOBALS.Equal(l_old_line_rec.ship_from_org_id,
                          l_line_rec.ship_from_org_id) THEN
     IF l_line_rec.ship_from_org_id is not null
     THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SETTING RE_SOURCE_FLAG TO N' , 1 ) ;
         END IF;
         l_line_rec.re_source_flag := 'N';
     ELSE
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  '1.SETTING RE_SOURCE_FLAG TO NULL' , 1 ) ;
         END IF;
         l_line_rec.re_source_flag := '';
     END IF;
  ELSIF l_line_rec.ship_from_org_id is null
  THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  '2.SETTING RE_SOURCE_FLAG TO NULL' , 1 ) ;
      END IF;
      l_line_rec.re_source_flag := '';
  END IF;

  l_new_line_tbl(1) := l_line_rec;

  -- Query the old reservations from reservations table


  IF l_line_rec.schedule_status_code is not null THEN

     l_sales_order_id := Get_mtl_sales_order_id(l_line_rec.HEADER_ID);

     IF l_old_line_rec.reserved_quantity is null THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RR: L_OLD_LINE_REC.RESERVED_QUANTITY IS NULL' , 1 ) ;
        END IF;
     ELSIF l_old_line_rec.reserved_quantity = FND_API.G_MISS_NUM THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'RR: L_OLD_LINE_REC.RESERVED_QUANTITY IS MISSING' , 1 ) ;
        END IF;
     END IF;

      -- INVCONV - MERGED CALLS	 FOR OE_LINE_UTIL.Get_Reserved_Quantity and OE_LINE_UTIL.Get_Reserved_Quantity2

     OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => l_sales_order_id
                                              ,p_line_id   => l_line_rec.line_id
                                              ,p_org_id    => l_line_rec.ship_from_org_id
                                              ,x_reserved_quantity =>  l_old_line_rec.reserved_quantity
                                              ,x_reserved_quantity2 => l_old_line_rec.reserved_quantity2
																							);
     /*l_old_line_rec.reserved_quantity :=
          OE_LINE_UTIL.Get_Reserved_Quantity
                 (p_header_id   => l_sales_order_id,
                  p_line_id     => l_line_rec.line_id,
                  p_org_id      => l_line_rec.ship_from_org_id);

     l_old_line_rec.reserved_quantity2 :=   -- INVCONV
          OE_LINE_UTIL.Get_Reserved_Quantity2
                 (p_header_id   => l_sales_order_id,
                  p_line_id     => l_line_rec.line_id,
                  p_org_id      => l_line_rec.ship_from_org_id); */

  ELSE
     l_old_line_rec.reserved_quantity := null;
     l_old_line_rec.reserved_quantity2 := null; -- INVCONV
  END IF;

  IF l_old_line_rec.reserved_quantity = 0
  THEN
     -- Currently setting the reserved quantity to null if it is zero.
     l_old_line_rec.reserved_quantity := null;
  END IF;

  IF l_old_line_rec.reserved_quantity2 = 0  -- INVCONV
  THEN
     -- Currently setting the reserved2 quantity to null if it is zero.
     l_old_line_rec.reserved_quantity2 := null;
  END IF;

  IF l_line_rec.reserved_quantity = FND_API.G_MISS_NUM
  THEN
     -- Converting missing to old value
     l_line_rec.reserved_quantity := l_old_line_rec.reserved_quantity;
  END IF;

	IF l_line_rec.reserved_quantity2 = FND_API.G_MISS_NUM  -- INVCONV
  THEN
     -- Converting missing to old value
     l_line_rec.reserved_quantity2 := l_old_line_rec.reserved_quantity2;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' ' , 1 ) ;
      oe_debug_pub.add(  'OLD RESERVED QUANTITY :' || L_OLD_LINE_REC.RESERVED_QUANTITY , 1 ) ;
      oe_debug_pub.add(  'NEW RESERVED QUANTITY :' || L_LINE_REC.RESERVED_QUANTITY , 1 ) ;
      oe_debug_pub.add(  'OLD RESERVED QUANTITY2 :' || L_OLD_LINE_REC.RESERVED_QUANTITY2 , 1 ) ; -- INVCONV
      oe_debug_pub.add(  'NEW RESERVED QUANTITY2 :' || L_LINE_REC.RESERVED_QUANTITY2 , 1 ) ;  -- INVCONV
      oe_debug_pub.add(  ' ' , 1 ) ;
  END IF;

  l_need_sch :=  Need_Scheduling(p_line_rec         => l_line_rec,
                                 p_old_line_rec     => l_old_line_rec);

  IF not(l_need_sch) THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SCHEDULING NOT REQUIRED' , 1 ) ;
      END IF;
      goto end_schedule_line;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CALLING OE_ORDER_SCH_UTIL.VALIDATE LINE' , 1 ) ;
  END IF;

  Validate_Line(p_line_rec      => l_line_rec,
                p_old_line_rec  => l_old_line_rec,
                x_return_status => l_return_status);

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
      l_return_status := FND_API.G_RET_STS_ERROR;
      goto end_schedule_line;
  END IF;

  /*
    Check to see what type of line is this :

    1 - PTO :   Will go through normal scheduling.

    2 - ATO Item : Will go through normal scheduling.

    3 - ATO Model : We will translate this request into a group
        request if there is an action on it, and then call Group_Scheduling
        to perform the action.

    4 - ATO Option : Will go through normal scheduling.
  */

   IF OESCH_PERFORM_GRP_SCHEDULING = 'Y' AND
      Group_Scheduling_Required(p_line_rec     => l_line_rec,
                                p_old_line_rec => l_old_line_rec)
   THEN
      -- Get the Order Date Type Code
      l_type_code    := Get_Date_Type(l_line_rec.header_id);
      IF ((l_line_rec.schedule_status_code IS NOT NULL AND
           l_line_rec.schedule_status_code <> FND_API.G_MISS_CHAR) AND
           l_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE          AND
          (NOT OE_GLOBALS.Equal(p_x_line_rec.inventory_item_id,
                                p_old_line_rec.inventory_item_id)))
      THEN

        -- If the scheduling is happening due to inventory item change.
        -- We should call MRP twice. First time we should call MRP with
        -- Undemand for old item. Second call would be redemand.

        IF (l_old_line_rec.reserved_quantity is not null AND
            l_old_line_rec.reserved_quantity <> FND_API.G_MISS_NUM)
        THEN

         -- Call INV API to delete the reservations on  the line.


          Unreserve_Line
            ( p_line_rec               => l_old_line_rec
            , p_quantity_to_unreserve  => l_old_line_rec.reserved_quantity
            , p_quantity2_to_unreserve  => l_old_line_rec.reserved_quantity2 -- INVCONV
            , x_return_status          => l_return_status);

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;


       END IF;

       Action_Undemand(p_old_line_rec   => l_old_line_rec,
                       x_return_status  => l_return_status);


      END IF; -- Undemand.

      IF l_line_rec.schedule_action_code is null THEN

         IF (l_line_rec.ato_line_id is not null) THEN
                l_entity_type := OESCH_ENTITY_ATO_CONFIG;
                l_set_id      := p_x_line_rec.ato_line_id;
         END IF;

         IF nvl(l_line_rec.ship_model_complete_flag,'N') = 'Y' THEN
                l_entity_type := OESCH_ENTITY_SMC;
                l_set_id      := p_x_line_rec.top_model_line_id;
         END IF;

         -- Fix for bug 2898623 added AND condition
         IF ((l_line_rec.ship_set_id is not null) AND
             (l_line_rec.ordered_quantity > 0)) THEN
                l_entity_type := OESCH_ENTITY_SHIP_SET;
                l_set_id      := p_x_line_rec.ship_set_id;
         END IF;

         -- Fix for bug 2898623 added AND condition
         IF ((l_line_rec.arrival_set_id is not null) AND
             (l_line_Rec.ordered_quantity > 0)) THEN
                l_entity_type := OESCH_ENTITY_ARRIVAL_SET;
                l_set_id      := p_x_line_rec.arrival_set_id;
         END IF;

         IF l_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            -- Line is getting created, and is also being added to a set.

            IF l_line_rec.ato_line_id is NOT NULL THEN

               IF l_line_rec.ship_model_complete_flag = 'Y' THEN

                  l_param := l_line_rec.top_model_line_id;

               ELSE

                  l_param := l_line_rec.ato_line_id;

               END IF;
               IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'LOGGING REQUEST: GROUP_SCHEDULE ATO' , 1 ) ;
                oe_debug_pub.add(  'L_PARAM ' || L_PARAM , 1 ) ;
               END IF;

                OE_delayed_requests_Pvt.log_request
                (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
                 p_entity_id              => l_param,
                 p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                 p_requesting_entity_id   => p_x_line_rec.line_id,
                 p_request_type           => OE_GLOBALS.G_GROUP_SCHEDULE,
                 p_param1                 => l_set_id,
                 p_param2                 => p_x_line_rec.header_id,
                 p_param3                 => l_entity_type,
                 p_param4                 => OESCH_ACT_RESCHEDULE,
                 p_param11                => 'Y',
                 x_return_status          => l_return_status);

              goto end_schedule_line;

            ELSE -- Not an ato option/class
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'LOGGING REQUEST: SCHEDULE LINE' , 1 ) ;
              END IF;

              OE_delayed_requests_Pvt.log_request
               (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
                p_entity_id              => l_line_rec.line_id,
                p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                p_requesting_entity_id   => l_line_rec.line_id,
                p_request_type           => OE_GLOBALS.G_SCHEDULE_LINE,
                p_param1                 => l_set_id,
                p_param2                 => p_x_line_rec.header_id,
                p_param3                 => l_entity_type,
                x_return_status          => l_return_status);

            goto end_schedule_line;

           END IF; -- ATO Check
         ELSIF l_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
            ((NOT OE_GLOBALS.Equal(p_x_line_rec.ship_set_id,
                                 p_old_line_rec.ship_set_id)) OR
            (NOT OE_GLOBALS.Equal(p_x_line_rec.arrival_set_id,
                                 p_old_line_rec.arrival_set_id)))
         THEN

           -- Line is either being moved from one set to another,
           -- or is being added to a new set.

           IF l_line_rec.schedule_status_code is null THEN

		    -- New line which is being added to the set is not
              -- scheduled.

              l_request_type        := OE_GLOBALS.G_SCHEDULE_LINE;
              l_o_request_date      := l_old_line_rec.request_date;
              l_o_ship_from_org_id  := l_old_line_rec.ship_from_org_id;
              l_o_ship_to_org_id    := l_old_line_rec.ship_to_org_id;


           ELSE

             -- Code for bug 2431390.
             -- See if any schedule attributes are changed along with the
             -- set information, if changed we cannot bypass ato call.

             IF NOT Schedule_Attribute_Changed(p_line_rec => l_line_rec,
                                           p_old_line_rec => l_old_line_rec)
             AND OE_GLOBALS.Equal(l_line_rec.ordered_quantity,
                                 l_old_line_rec.ordered_quantity)
             AND (l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_STANDARD OR
                 nvl(l_line_rec.model_remnant_flag,'N') = 'Y')
             THEN


                IF l_line_rec.arrival_set_id is not null OR
                   l_line_rec.ship_set_id IS NOT NULL THEN
                   l_set_rec := OE_ORDER_CACHE.Load_Set
                    (nvl(l_line_rec.arrival_set_id,l_line_rec.ship_set_id));
                ELSE
                   l_set_rec := Null;
                END IF;


                IF l_set_rec.ship_from_org_id is null
                OR l_set_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN

                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'ONLY SCHEDULED LINE IS GETTING INTO NEW SET' , 2 ) ;
                    END IF;

                    GOTO end_schedule_line;

                ELSE

                      IF oe_grp_sch_util.Compare_Set_Attr
                         (p_set_ship_from_org_id    => l_set_rec.ship_from_org_id ,
                          p_line_ship_from_org_id   => l_line_rec.ship_from_org_id,
                          p_set_ship_to_org_id      => l_set_rec.ship_to_org_id ,
                          p_line_ship_to_org_id     => l_line_rec.ship_to_org_id ,
                          p_set_schedule_ship_date  => l_set_rec.schedule_ship_date ,
                          p_line_schedule_ship_date => l_line_rec.schedule_ship_date,
                          p_set_arrival_date        => l_set_rec.schedule_arrival_date,
                          p_line_arrival_date       => l_line_rec.schedule_arrival_date,
                          p_set_type                => l_set_rec.set_type) THEN

                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'ONLY SCHEDULED LINE IS GETTING INTO OLD SET' , 2 ) ;
                          END IF;

                          GOTO end_schedule_line;

                     END IF; -- compare.


                END IF; -- ship from .
             END IF; -- end of 2431390.

		    -- New line which is being added to the set is
              -- scheduled. We need to reschedule it with
              -- the set attributes.

              l_request_type     := OE_GLOBALS.G_RESCHEDULE_LINE;
              l_o_request_date      := l_old_line_rec.request_date;
              l_o_sch_ship_date     := l_old_line_rec.schedule_ship_date;
              l_o_sch_arr_date      := l_old_line_rec.schedule_arrival_date;
              l_o_ship_from_org_id  := l_old_line_rec.ship_from_org_id;
              l_o_ship_to_org_id    := l_old_line_rec.ship_to_org_id;
              l_o_ord_qty           := l_old_line_rec.ordered_quantity;
              l_o_ord_qty2          := l_old_line_rec.ordered_quantity2;

           END IF;

                                     IF l_debug_level  > 0 THEN
                                         oe_debug_pub.add(  '2. LOGGING REQUEST: '|| OE_GLOBALS.G_SCHEDULE_LINE , 1 ) ;
                                     END IF;
           -- Added param7 to list to fix bug 1894284.
           OE_delayed_requests_Pvt.log_request
                  (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
                   p_entity_id              => l_line_rec.line_id,
                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                   p_requesting_entity_id   => l_line_rec.line_id,
                   p_request_type           => l_request_type,
                   p_param1                 => l_set_id,
                   p_param2                 => p_x_line_rec.header_id,
                   p_param3                 => l_entity_type,
                   p_date_param1            => l_o_request_date,
                   p_date_param2            => l_o_sch_ship_date,
                   p_date_param3            => l_o_sch_arr_date,
                   p_param7                 => l_o_ship_from_org_id,
                   p_param8                 => l_o_ship_to_org_id,
                   p_param9                 => l_old_line_rec.ship_set_id,
                   p_param10                => l_old_line_rec.arrival_set_id,
                   x_return_status          => l_return_status);

           goto end_schedule_line;

         ELSE


           -- There is a change to a attribute of a line which belongs
           -- to a set and will affect the whole set.Logging a delayed
           -- request since it will affect the whole set.

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  '2. LOGGING A GROUP_SCH_REQUEST' , 1 ) ;
               oe_debug_pub.add(  'SET ATTRIBUTE HAS BEEN CHANGED' , 1 ) ;
           END IF;

           -- Group is either being rescheduling, and being scheduled for the
           -- first time.

           IF l_line_rec.schedule_status_code is null THEN
              l_action     := OESCH_ACT_SCHEDULE;
           ELSE
              l_action     := OESCH_ACT_RESCHEDULE;
           END IF;

/*
           IF NOT OE_GLOBALS.Equal(l_line_rec.request_date,
                                   l_old_line_rec.request_date)
           THEN
              IF (l_type_code = 'ARRIVAL') THEN
                 l_line_rec.schedule_arrival_date := l_line_rec.request_date;
              ELSE
                 l_line_rec.schedule_ship_date := l_line_rec.request_date;
              END IF;
              l_new_line_tbl(1) := l_line_rec;
           END IF;
*/

		  -- We dont require this check here. This data will be
		  -- used in group_schedule delayed request.
/*           IF NOT OE_GLOBALS.Equal(l_line_rec.schedule_ship_date,
                                   l_old_line_rec.schedule_ship_date)
           THEN
              l_schedule_ship_date := l_old_line_rec.schedule_ship_date;
           END IF;

           IF NOT OE_GLOBALS.Equal(l_line_rec.schedule_arrival_date,
                                   l_old_line_rec.schedule_arrival_date)
           THEN
              l_schedule_arrival_date := l_old_line_rec.schedule_arrival_date;
           END IF;
*/

           l_schedule_ship_date := l_old_line_rec.schedule_ship_date;
           l_schedule_arrival_date := l_old_line_rec.schedule_arrival_date;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  '2. LOGGING A GROUP_SCH_REQUEST' , 1 ) ;
           END IF;

           OE_delayed_requests_Pvt.log_request
                (p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
                 p_entity_id              => p_x_line_rec.line_id,
                 p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                 p_requesting_entity_id   => p_x_line_rec.line_id,
                 p_request_type           => OE_GLOBALS.G_GROUP_SCHEDULE,
                 p_param1                 => l_set_id,
                 p_param2                 => p_x_line_rec.header_id,
                 p_param3                 => l_entity_type,
                 p_param4                 => l_action,
                 p_param7                 => l_old_line_rec.ship_from_org_id,
                 p_date_param1            => l_schedule_ship_date,
                 p_date_param2            => l_schedule_arrival_date,
                 p_date_param3            => l_old_line_rec.request_date,
                 p_param9                 => l_old_line_rec.ship_set_id,
                 p_param10                => l_old_line_rec.arrival_set_id,
                 x_return_status          => l_return_status);


           goto end_schedule_line;

         END IF;
      ELSE

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'CALLING CREATE_GROUP_REQUEST' , 1 ) ;
         END IF;

         Create_Group_Request(p_line_rec          => l_line_rec,
                              p_old_line_rec      => p_old_line_rec,
                              x_group_req_rec     => l_group_req_rec,
                              x_return_status     => l_return_status);

                                          IF l_debug_level  > 0 THEN
                                              oe_debug_pub.add(  'AFTER CALLING CREATE_GROUP_REQUEST: ' || L_RETURN_STATUS , 1 ) ;
                                          END IF;

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'CALLING GROUP_SCHEDULE' , 1 ) ;
         END IF;

         OE_GRP_SCH_UTIL.Group_Schedule
           ( p_group_req_rec     => l_group_req_rec
            ,x_atp_tbl           => l_out_atp_tbl
            ,x_return_status     => l_return_status);

                                                  IF l_debug_level  > 0 THEN
                                                      oe_debug_pub.add(  'AFTER CALLING GROUP_SCHEDULE: ' || L_RETURN_STATUS , 1 ) ;
                                                  END IF;

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF NOT OE_GLOBALS.Equal(l_line_rec.schedule_action_code,
                              OESCH_ACT_ATP_CHECK)
         THEN

            -- Group Schedule had updated all the scheduling related
            -- attributes on the line. But there could be non scheduling
            -- related attributes which could have changed and whose
            -- values are in p_line_rec. We will update the p_line_rec
            -- with scheduling attributes which have been saved to the
            -- database.

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'CALLING UPDATE_GROUP_SCH_RESULTS' , 1 ) ;
            END IF;

            l_out_line_rec := l_line_rec;

            Update_Group_Sch_Results(p_x_line_rec      => l_out_line_rec,
                                     x_return_status   => l_return_status);

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'AFTER CALLING UPDATE_GROUP_SCH_RESULTS' , 1 ) ;
            END IF;
            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

	       -- Set the cascade_flag to TRUE, so that we query the block,
            -- since multiple lines have changed.

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SETTING G_CASCADING_REQUEST_LOGGED' , 1 ) ;
            END IF;
            OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
            l_new_line_tbl(1) := l_out_line_rec;

         END IF;

         goto end_schedule_line;

      END IF; /* calling group_request */

   END IF;

  -- Follow this path only for standard items and option items.

/*
  Check_Item_Attribute(p_line_rec => l_line_rec);
*/

  -- Scheduling Parent lines separately. These parent lines will be for
  -- non-SMC complete PTO only. For parents, the group request would have
  -- taken care of it.

  IF (l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
     l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
     l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_KIT) AND
     l_line_rec.ato_line_id is null THEN



     IF l_line_rec.OPERATION = OE_GLOBALS.G_OPR_CREATE THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALL SCHEDULE_PARENT_LINE IN POST-WRITE' , 3 ) ;
        END IF;

        OESCH_SCH_POST_WRITE := 'Y';

         l_out_line_rec := l_line_rec;
	ELSE

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'SCH: CALLING SCHEDULE_PARENT_LINE' , 1 ) ;
         END IF;

         l_out_line_rec := l_line_rec;

         Schedule_Parent_line( p_old_line_rec  => l_old_line_rec,
                              p_write_to_db   => p_write_to_db,
                              p_x_line_rec  => l_out_line_rec,
					     p_recursive_call => p_recursive_call,
                              x_out_atp_tbl   => l_out_atp_tbl,
                              x_return_status => l_return_status);

                                       IF l_debug_level  > 0 THEN
                                           oe_debug_pub.add(  'AFTER CALLING SCHEDULE_PARENT_LINE: ' || L_RETURN_STATUS , 1 ) ;
                                       END IF;

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         l_new_line_tbl(1) := l_out_line_rec;
         x_atp_tbl         := l_out_atp_tbl;
         x_return_status   := l_return_status;

      END IF;

  ELSE
     -- We are now scheduling line independently. So if the line belongs
     -- to a set, we should not let the set attributes change. So we will
     -- set the global variable G_SOURCE_AGAIN to 'N' and also set the
     -- the acceptable dates to be the same as the schedule_date (which
     -- means window acceptable.

     IF (l_line_rec.ship_set_id is not null AND
        l_line_rec.ship_set_id <> FND_API.G_MISS_NUM) OR
        (l_line_rec.arrival_set_id is not null AND
         l_line_rec.arrival_set_id <> FND_API.G_MISS_NUM) THEN

         G_SOURCE_AGAIN := 'N';

     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'CALLING PROCESS_REQUEST' , 1 ) ;
     END IF;

	l_out_line_rec := l_line_rec;

     Process_request(p_x_line_rec    => l_out_line_rec,
                  p_old_line_rec   => l_old_line_rec,
                  x_out_atp_tbl    => l_out_atp_tbl ,
                  x_return_status  => l_return_status);

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTER CALLING PROCESS_REQUEST: ' || L_RETURN_STATUS , 1 ) ;
     END IF;

     -- Setting back g_source_again

     G_SOURCE_AGAIN := 'Y';

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'COUNT IS ' || L_OUT_ATP_TBL.COUNT , 1 ) ;
     END IF;

     FOR P IN 1..l_out_atp_tbl.count LOOP
	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'ON HAND IS: ' || L_OUT_ATP_TBL ( P ) .ON_HAND_QTY , 1 ) ;
	    END IF;
     END LOOP;
     l_new_line_tbl(1) := l_out_line_rec;
     -- Added Reserve statement to if to fix bug 1567688.
     -- Update order lines if the scheduling resulted in any attribute change.
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SCHEDULE STATUS OLD : '||L_OLD_LINE_REC.SCHEDULE_STATUS_CODE , 3 ) ;
         oe_debug_pub.add(  'SCHEDULE STATUS NEW : '||L_OUT_LINE_REC.SCHEDULE_STATUS_CODE , 3 ) ;
     END IF;
     IF NOT OE_GLOBALS.Equal(l_out_line_rec.schedule_action_code,
                              OESCH_ACT_ATP_CHECK) AND
        NOT OE_GLOBALS.Equal(l_out_line_rec.schedule_action_code,
                              OESCH_ACT_UNRESERVE) AND
        NOT (OE_GLOBALS.EQUAL(l_out_line_rec.schedule_action_code,
                              OESCH_ACT_RESERVE) AND
             l_old_line_rec.schedule_status_code IS NOT NULL) AND
        g_update_flag = FND_API.G_TRUE
     THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING UPDATE_LINE_RECORD ' , 1 ) ;
        END IF;

        l_line_tbl(1) := l_line_rec;

        Update_line_record(p_line_tbl      => l_line_tbl,
                           p_x_new_line_tbl  => l_new_line_tbl,
                           p_write_to_db   => p_write_to_db,
			            p_recursive_call => p_recursive_call,
                           x_return_status => l_return_status);

                                          IF l_debug_level  > 0 THEN
                                              oe_debug_pub.add(  'AFTER CALLING UPDATE_LINE_RECORD :' || L_RETURN_STATUS , 1 ) ;
                                          END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Do not process delayed requests if this was a recursive
        -- call (e.g. from oe_line_util.pre_write_process)
        IF p_recursive_call = FND_API.G_TRUE THEN
           l_process_requests := FALSE;
        ELSE
           l_process_requests := TRUE;
        END IF;

        OE_Order_PVT.Process_Requests_And_Notify
        ( p_process_requests        => l_process_requests
        , p_notify                  => TRUE
        , p_line_tbl                => l_new_line_tbl
        , p_old_line_tbl            => l_line_tbl
        , x_return_status           => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- If schedule date has change, we need to call PO callback function
        -- to indicate the change.

        IF p_x_line_rec.operation = oe_globals.g_opr_update AND
           p_x_line_rec.source_document_type_id = 10 THEN

           /* Changing schedule ship date to schedule arrival date for
              bug 2024748 */
           IF NOT OE_GLOBALS.EQUAL(l_out_line_rec.schedule_arrival_date,
                                   p_old_line_rec.schedule_arrival_date) THEN

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'PASSING SCHEDULE_ARRIVAL_DATE TO PO ' , 3 ) ;
                END IF;
                Update_PO(l_out_line_rec.schedule_arrival_date,
                          l_out_line_rec.source_document_id,
                          l_out_line_rec.source_document_line_id);
           END IF;
        END IF;

       -- Commented this portion to fix bug 1883110.
        -- ReSet recursion mode.
        --  OE_GLOBALS.G_RECURSION_MODE := 'N';

     END IF;

     p_x_line_rec      := l_new_line_tbl(1);
     x_atp_tbl       := l_out_atp_tbl;
     x_return_status := l_return_status;

  END IF;

  <<end_schedule_line>>

  p_x_line_rec      := l_new_line_tbl(1);
  x_return_status   := l_return_status;

  -- Setting G_LINE_PART_OF_SET back to FALSE

  G_LINE_PART_OF_SET := FALSE;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' ' , 1 ) ;
      oe_debug_pub.add(  'PRINTING OUT NOCOPY RECORD: ' , 1 ) ;
      oe_debug_pub.add(  ' P_X_LINE_REC LINE ID :'|| L_NEW_LINE_TBL ( 1 ) .LINE_ID , 1 ) ;
      oe_debug_pub.add(  ' P_X_LINE_REC OPERATION :'|| L_NEW_LINE_TBL ( 1 ) .OPERATION , 1 ) ;
      oe_debug_pub.add(  ' P_X_LINE_REC SCH STATUS :'|| L_NEW_LINE_TBL ( 1 ) .SCHEDULE_STATUS_CODE , 1 ) ;
      oe_debug_pub.add(  ' P_X_LINE_REC RESERVED QTY : '|| L_NEW_LINE_TBL ( 1 ) .RESERVED_QUANTITY , 1 ) ;
      oe_debug_pub.add(  'AFTER PRINTING OUT NOCOPY RECORD: ' , 1 ) ;
      oe_debug_pub.add(  ' ' , 1 ) ;
      oe_debug_pub.add(  'EXITING OE_ORDER_SCH_UTIL.SCHEDULE_LINE' , 1 ) ;
  END IF;


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

        G_LINE_PART_OF_SET := FALSE;
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        G_LINE_PART_OF_SET := FALSE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        G_LINE_PART_OF_SET := FALSE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_line'
            );
        END IF;

END Schedule_line;

/*---------------------------------------------------------------------
Procedure Name : Update_line_record
Description    : This process is called after scheduling is performed
                 on the line and the result needs to be verified and/or
                 updated to the database.
--------------------------------------------------------------------- */

Procedure Update_line_record
( p_line_tbl      IN  OE_ORDER_PUB.line_tbl_type
, p_x_new_line_tbl  IN OUT NOCOPY OE_ORDER_PUB.line_tbl_type
, p_write_to_db   IN  VARCHAR2
, p_recursive_call  IN VARCHAR2
, x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
l_schedule_line_rec         request_rec_type;
l_line_rec                  OE_ORDER_PUB.line_rec_type;
l_old_line_rec              OE_ORDER_PUB.line_rec_type;
l_sch_rec                   sch_rec_type;
I                           NUMBER;
l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);
l_control_rec               OE_GLOBALS.control_rec_type;
l_line_tbl                  OE_ORDER_PUB.line_tbl_type;
l_process_requests	    BOOLEAN;
is_set_recursion            VARCHAR2(1) := 'Y';
/*
l_old_line_tbl              OE_ORDER_PUB.line_tbl_type;
l_header_out_rec            OE_Order_PUB.Header_Rec_Type;
l_header_rec                OE_Order_PUB.Header_Rec_Type;
l_line_out_tbl              OE_Order_PUB.Line_Tbl_Type;
l_header_adj_out_tbl        OE_Order_PUB.Header_Adj_Tbl_Type;
l_header_scredit_out_tbl    OE_Order_PUB.Header_Scredit_Tbl_Type;
l_line_adj_out_tbl          OE_Order_PUB.Line_Adj_Tbl_Type;
l_line_scredit_out_tbl      OE_Order_PUB.Line_Scredit_Tbl_Type;
l_lot_serial_out_tbl        OE_Order_PUB.Lot_Serial_Tbl_Type;
l_action_request_out_tbl    OE_Order_PUB.Request_Tbl_Type;
l_Header_Adj_Att_tbl        OE_ORDER_PUB.Header_Adj_Att_Tbl_Type;
l_Header_Adj_Assoc_tbl      OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type;
l_Header_price_Att_tbl      OE_ORDER_PUB.Header_Price_Att_Tbl_Type;
l_Line_Price_Att_tbl        OE_ORDER_PUB.Line_Price_Att_Tbl_Type;
l_Line_Adj_Att_tbl          OE_ORDER_PUB.Line_Adj_Att_Tbl_Type;
l_Line_Adj_Assoc_tbl        OE_ORDER_PUB.Line_Adj_Assoc_Tbl_Type;
*/
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING UPDATE_LINE_RECORD' , 1 ) ;
    END IF;
    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.change_attributes    := TRUE;

    l_control_rec.default_attributes   := TRUE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.check_security       := TRUE;

    IF (p_write_to_db = FND_API.G_TRUE) THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'H1' , 1 ) ;
       END IF;
       l_control_rec.write_to_DB          := TRUE;
       l_control_rec.validate_entity      := TRUE;
    ELSE
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'H2' , 1 ) ;
       END IF;
       l_control_rec.write_to_DB          := FALSE;
    END IF;

    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'N';

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING PROCESS ORDER' , 1 ) ;
    END IF;

    FOR I IN 1..p_x_new_line_tbl.count LOOP
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'I :' || I , 1 ) ;
            oe_debug_pub.add(  'OPERATION IS :' || P_X_NEW_LINE_TBL ( I ) .OPERATION , 1 ) ;
        END IF;
	   /* Start Audit Trail */
	   p_x_new_line_tbl(I).change_reason := 'SYSTEM';
	   p_x_new_line_tbl(I).change_comments := 'Scheduling Action';
	   /* End Audit Trail */
    END LOOP;

/*
    l_old_line_rec :=  p_line_tbl(1);
    l_line_rec :=  p_x_new_line_tbl(1);
*/

    l_line_tbl := p_line_tbl;

     -- Set global set recursive flag
     -- The global flag to supress the sets logic to fire in
     -- get set id api in lines
/*
    IF p_recursive_call = FND_API.G_TRUE THEN
       oe_set_util.g_set_recursive_flag := TRUE;
    END IF;
*/
    IF NOT oe_set_util.g_set_recursive_flag  THEN
       is_set_recursion := 'N';
       oe_set_util.g_set_recursive_flag := TRUE;
    END IF;

    --  Call OE_Order_PVT.Process_order

    OE_Order_PVT.Lines
    (p_validation_level            => FND_API.G_VALID_LEVEL_NONE,
     p_control_rec                 => l_control_rec,
     p_x_line_tbl                  => p_x_new_line_tbl,
     p_x_old_line_tbl		     => l_line_tbl,
     x_return_status               => l_return_status);

    -- unset global set recursive flag
    -- The global flag to supress the sets logic to
    -- fire in get set id api in lines

    IF is_set_recursion  = 'N' THEN
       is_set_recursion := 'Y';
       oe_set_util.g_set_recursive_flag := FALSE;
    END IF;

/*
    IF p_recursive_call = FND_API.G_TRUE THEN
       oe_set_util.g_set_recursive_flag := FALSE;
    END IF;
*/
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

   /** Commenting out this Process_request_and_notify call **/
   /** Since it is causing scheduling to to process requests too early **/
   /** Instead call process_requests_and_notify after this update_line_rec **/
   /** procedure is called. **/
   /*
    -- Do not process delayed requests if this was a recursive
    -- call (e.g. from oe_line_util.pre_write_process)
    IF p_recursive_call = FND_API.G_TRUE THEN
        l_process_requests := FALSE;
    ELSE
        l_process_requests := TRUE;
    END IF;

    OE_Order_PVT.Process_Requests_And_Notify
    ( p_process_requests        => l_process_requests
    , p_notify                  => TRUE
    , p_line_tbl                => p_x_new_line_tbl
    , p_old_line_tbl            => l_line_tbl
    , x_return_status           => l_return_status
    );
*/
/*
    OE_ORDER_PVT.Process_order
    ( p_api_version_number          => 1.0
    , p_init_msg_list               => FND_API.G_FALSE
    , p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    , x_return_status               => l_return_status
    , x_msg_count                   => l_msg_count
    , x_msg_data                    => l_msg_data
    , p_x_header_rec                => l_header_rec
    , p_control_rec                 => l_control_rec
    , p_x_line_tbl                  => p_x_new_line_tbl
    , p_old_line_tbl                => p_line_tbl
    , p_x_Header_Adj_tbl            => l_Header_Adj_out_tbl
    , p_x_Header_Price_Att_tbl      => l_Header_Price_Att_tbl
    , p_x_Header_Adj_Att_tbl        => l_Header_Adj_Att_tbl
    , p_x_Header_Adj_Assoc_tbl      => l_Header_Adj_Assoc_tbl
    , p_x_Header_Scredit_tbl        => l_Header_Scredit_out_tbl
    , p_x_Line_Adj_tbl              => l_Line_Adj_out_tbl
    , p_x_Line_Price_Att_tbl        => l_Line_Price_Att_tbl
    , p_x_Line_Adj_Att_tbl          => l_Line_Adj_Att_tbl
    , p_x_Line_Adj_Assoc_tbl        => l_Line_Adj_Assoc_tbl
    , p_x_Line_Scredit_tbl          => l_Line_Scredit_out_tbl
    , p_x_action_request_tbl        => l_Action_Request_out_tbl
    , p_x_Lot_Serial_Tbl            => l_lot_serial_out_tbl
    );
*/
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SCH: AFTER CALLING PROCESS ORDER' , 1 ) ;
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

    OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';

    x_return_status := l_return_status;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING UPDATE LINE RECORD' , 1 ) ;
    END IF;
EXCEPTION

  -- resetting the flag to fix bug 2043973.

   WHEN FND_API.G_EXC_ERROR THEN

        OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF is_set_recursion  = 'N' THEN
         oe_set_util.g_set_recursive_flag := FALSE;
        END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF is_set_recursion  = 'N' THEN
         oe_set_util.g_set_recursive_flag := FALSE;
        END IF;

    WHEN OTHERS THEN

        OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF is_set_recursion  = 'N' THEN
         oe_set_util.g_set_recursive_flag := FALSE;
        END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Schedule_line'
            );
        END IF;
END Update_line_record;

/*---------------------------------------------------------------------
Function Name  : Need_Scheduling
Description    : This API will return to the calling process if scheduling
                 needs to be performed on the line or not.
--------------------------------------------------------------------- */
FUNCTION Need_Scheduling(p_line_rec           IN OE_ORDER_PUB.line_rec_type,
                         p_old_line_rec       IN OE_ORDER_PUB.line_rec_type)
RETURN BOOLEAN
IS
l_schedule_action_code   VARCHAR2(30);
l_schedule_status_code   VARCHAR2(30);
l_order_date_type_code   VARCHAR2(30):='';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING NEED SCHEDULING' , 1 ) ;
       oe_debug_pub.add(  'SPLIT ACTION :' || P_LINE_REC.SPLIT_ACTION_CODE , 1 ) ;
       oe_debug_pub.add(  'S. LINE_ID :' || P_LINE_REC.SPLIT_FROM_LINE_ID , 1 ) ;
   END IF;

   -- We do not schedule service lines. So return false for them.
   IF (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_SERVICE) THEN
       RETURN FALSE;
   END IF;

   -- We do not schedule OTA lines. So return false for them.
   IF OE_OTA_UTIL.Is_OTA_Line(p_line_rec.order_quantity_uom)
   THEN
      RETURN FALSE;
   END IF;

   -- If a config item is deleted, we do not need to call scheduling.
   -- Config Item can be deleted only through delink API. While delinking,
   -- CTO team takes care of updating the demand picture for the
   -- configuration.

   IF (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG AND
       p_line_rec.operation = OE_GLOBALS.G_OPR_DELETE)
   THEN
      RETURN FALSE;
   END IF;

   -- If a config item is getting created, we do not need to call scheduling.

   IF (p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG AND
       p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE)
   THEN
      RETURN FALSE;
   END IF;

   IF OE_OTA_UTIL.Is_OTA_Line(p_line_rec.order_quantity_uom)
   THEN
      RETURN FALSE;
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

   l_schedule_action_code := p_line_rec.schedule_action_code;
   l_schedule_status_code := p_line_rec.schedule_status_code;

   IF (l_schedule_action_code = FND_API.G_MISS_CHAR) THEN
       l_schedule_action_code := null;
   END IF;

   -- If a scheduled line is deleted, the line should be unscheduled.
   IF (l_schedule_status_code is not null) AND
      (p_line_rec.operation = OE_GLOBALS.G_OPR_DELETE)
   THEN
        RETURN TRUE;
   END IF;

   -- Currently, we will not perform any scheduling action
   -- for lines with source_type=EXTERNAL

   IF (p_line_rec.source_type_code = OE_GLOBALS.G_SOURCE_EXTERNAL)
   AND (p_old_line_rec.schedule_status_code is null)
   THEN
        FND_MESSAGE.SET_NAME('ONT','OE_DS_COULD_NOT_SCH');
        FND_MESSAGE.SET_TOKEN('LINE',p_line_rec.line_number);
        RETURN FALSE;
   END IF;

   If (l_schedule_status_code is null) AND
      ((l_schedule_action_code = OESCH_ACT_UNSCHEDULE) OR
      (l_schedule_action_code = OESCH_ACT_UNDEMAND) OR
      (l_schedule_action_code = OESCH_ACT_UNRESERVE))
   THEN
       FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
       OE_MSG_PUB.Add;
       RETURN FALSE;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'N6' , 1 ) ;
   END IF;
   IF (l_schedule_status_code = OESCH_STATUS_SCHEDULED AND
      l_schedule_action_code = OESCH_ACT_SCHEDULE AND
      p_line_rec.ordered_quantity = p_old_line_rec.reserved_quantity) THEN

      -- We should not perform scheduling if the line is already scheduled
      RETURN FALSE;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'N7: ' || L_SCHEDULE_ACTION_CODE , 1 ) ;
   END IF;
   IF (l_schedule_action_code is not null)
   THEN
        RETURN TRUE;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'N8' , 1 ) ;
   END IF;
   IF NOT OE_GLOBALS.Equal(p_line_rec.schedule_ship_date,
                           p_old_line_rec.schedule_ship_date)
   THEN
      RETURN TRUE;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_line_rec.schedule_arrival_date,
                           p_old_line_rec.schedule_arrival_date)
   THEN
      RETURN TRUE;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'NEW RESERVED QTY' || P_LINE_REC.RESERVED_QUANTITY ) ;
       oe_debug_pub.add(  'OLD RESERVED QTY' || P_OLD_LINE_REC.RESERVED_QUANTITY ) ;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_line_rec.reserved_quantity,
                           p_old_line_rec.reserved_quantity)
   THEN
         RETURN TRUE;
   END IF;

   IF ((l_schedule_status_code is NULL AND
      l_schedule_action_code is NULL) AND
      OESCH_AUTO_SCH_FLAG = 'N')
   THEN
     RETURN FALSE;
   END IF;


   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'RR:G5' , 1 ) ;
   END IF;
   IF (p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE) THEN
      IF (OESCH_AUTO_SCH_FLAG = 'N')
      THEN
         RETURN FALSE;
      ELSE
         -- We are currently autoscheduling only standard lines not in any
         -- an model or option items.

         IF p_line_rec.top_model_line_id is not null AND
            p_line_rec.top_model_line_id <> FND_API.G_MISS_NUM AND
            p_line_rec.item_type_code <> OE_GLOBALS.G_ITEM_STANDARD THEN
            RETURN FALSE;
         ELSE
            RETURN TRUE;
         END IF;
      END IF;
   END IF;

   -- We should avoid calling scheduling when user changes values of the below
   -- attributes on the unscheduled lines. The below code is valid only for
   -- scheduled lines.

  IF p_line_rec.schedule_status_code is NOT NULL THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'RR:G6' , 6 ) ;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_line_rec.ship_from_org_id,
                           p_old_line_rec.ship_from_org_id)
   THEN
      RETURN TRUE;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_line_rec.subinventory,
                           p_old_line_rec.subinventory)
   THEN
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'SUBINVENTORY CHANGED , NEED RESCHEDULING' , 1 ) ;
	 END IF;
      RETURN TRUE;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_line_rec.ordered_quantity,
                           p_old_line_rec.ordered_quantity)
   THEN
      RETURN TRUE;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'RR:G7' , 1 ) ;
   END IF;
   IF NOT OE_GLOBALS.Equal(p_line_rec.order_quantity_uom,
                           p_old_line_rec.order_quantity_uom)
   THEN
      RETURN TRUE;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'RR:G8' , 1 ) ;
   END IF;
   IF NOT OE_GLOBALS.Equal(p_line_rec.request_date,
                           p_old_line_rec.request_date)
   THEN
      RETURN TRUE;
   END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RR:G9' , 1 ) ;
    END IF;
   IF NOT OE_GLOBALS.Equal(p_line_rec.shipping_method_code,
                           p_old_line_rec.shipping_method_code)
   THEN
      RETURN TRUE;
   END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RR:G10' , 1 ) ;
    END IF;
   IF NOT OE_GLOBALS.Equal(p_line_rec.delivery_lead_time,
                           p_old_line_rec.delivery_lead_time)
   THEN

      BEGIN
        select order_date_type_code into l_order_date_type_code
        from oe_order_headers_all
        where header_id =  p_line_rec.header_id;

        IF l_order_date_type_code  = 'ARRIVAL' THEN
          RETURN TRUE;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          NULL;
      END;

   END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RR:G11' , 1 ) ;
    END IF;
   IF NOT OE_GLOBALS.Equal(p_line_rec.demand_class_code,
                           p_old_line_rec.demand_class_code)
   THEN
      RETURN TRUE;
   END IF;

   /*
        Forecasting attributes.
   */

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RR:G12' , 1 ) ;
    END IF;
   IF NOT OE_GLOBALS.Equal(p_line_rec.ship_to_org_id,
                           p_old_line_rec.ship_to_org_id)
   THEN
      RETURN TRUE;
   END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RR:G13' , 1 ) ;
    END IF;
   IF NOT OE_GLOBALS.Equal(p_line_rec.sold_to_org_id,
                           p_old_line_rec.sold_to_org_id)
   THEN
      RETURN TRUE;
   END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RR:G14' , 1 ) ;
    END IF;
    IF NOT OE_GLOBALS.Equal(p_line_rec.inventory_item_id,
                            p_old_line_rec.inventory_item_id)
    THEN
       RETURN TRUE;
    END IF;

     -- Changing the source type on a scheduled line.
    -- We should unschedule the line
    IF p_line_rec.source_type_code = OE_GLOBALS.G_SOURCE_EXTERNAL AND
       NOT OE_GLOBALS.Equal(p_line_rec.source_type_code,
                            p_old_line_rec.source_type_code)
    THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SOURCE TYPE MADE EXTERNAL , UNSCHEDULE' , 4 ) ;
        END IF;
        RETURN TRUE;
    END IF;


  END IF; -- Check for schedule_status_code.

  RETURN FALSE;
END Need_Scheduling;

/*---------------------------------------------------------------------
Procedure Name : Get_Scheduling_Level
Description    : This function gets back the scheduling level
                 on the order type. The scheduling levels could be
                 ONE: Perform on ATP
                 TWO: Perform ATP and Scheduling. (no reservations)
                 THREE: Perform ATP,Scheduling and RESERVATIONS.
			  08/25 : changes are being made for bug 1385153 to get the
			  scheduling level based on line type instead of order type.
--------------------------------------------------------------------- */

FUNCTION Get_Scheduling_Level( p_header_id IN NUMBER,
						 p_line_type_id IN NUMBER)
RETURN VARCHAR2
IS
l_scheduling_level_code  VARCHAR2(30) := null;
l_line_type             VARCHAR2(80) := null;
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

  SELECT name, scheduling_level_code
  INTO   l_line_type,l_scheduling_level_code
  FROM   oe_transaction_types
  WHERE  transaction_type_id = p_line_type_id AND
	    transaction_type_code = 'LINE';

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

  SELECT name, scheduling_level_code
  INTO   l_order_type,l_scheduling_level_code
  FROM   oe_order_types_v ot, oe_order_headers h
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
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Scheduling_Level;

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
Procedure Validate_Line(p_line_rec      IN OE_ORDER_PUB.Line_Rec_Type,
                        p_old_line_rec  IN OE_ORDER_PUB.Line_Rec_Type,
                        x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
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
       oe_debug_pub.add(  '..ENTERING OE_ORDER_SCH_UTIL.VALIDATE_LINE' , 6 ) ;
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

   -- If the line is cancelled, scheduling is not allowed.

   IF (p_line_rec.cancelled_flag = 'Y') THEN

         IF p_line_rec.schedule_action_code is not null THEN

             -- The line is cancelled. Cannot perform scheduling
             -- on it.

             FND_MESSAGE.SET_NAME('ONT','OE_SCH_LINE_FULLY_CANCELLED');
             OE_MSG_PUB.Add;

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'E3' , 1 ) ;
             END IF;
             l_return_status := FND_API.G_RET_STS_ERROR;

         END IF;
   END IF;

   -- If the line is shipped, scheduling is not allowed.

   IF (p_line_rec.shipped_quantity is not null) AND
        (p_line_rec.shipped_quantity <> FND_API.G_MISS_NUM) THEN

/* modified he following if condition for fixing the bug 2763764 */

         IF p_line_rec.schedule_action_code is not null OR
            (p_line_rec.reserved_quantity is not null AND
             p_line_rec.reserved_quantity <> FND_API.G_MISS_NUM) THEN


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
                             p_line_rec.reserved_quantity) THEN

       -- Bug 2314463  Start
       IF p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INSIDE CONFIG ITEM...RESERVED QTY CHANGED' , 1 ) ;
         END IF;
         FND_MESSAGE.SET_NAME('ONT','OE_INVALID_ACTION');
         FND_MESSAGE.SET_TOKEN('ACTION',OE_Id_To_Value.Inventory_Item(p_line_rec.inventory_item_id));
         OE_MSG_PUB.Add;
         l_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
       -- Bug 2314463  End

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

			 -- Reserved2 Quantity has changed -- INVCONV
       IF (p_line_rec.ordered_quantity2 < p_line_rec.reserved_quantity2)
       THEN

         FND_MESSAGE.SET_NAME('ONT','OE_SCH_RES_MORE_ORD_QTY');
         OE_MSG_PUB.Add;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'E4a' , 1 ) ;
         END IF;
         l_return_status := FND_API.G_RET_STS_ERROR;
       END IF;


       -- after changing reserved qty, trying to unschedule or unreserve
       -- dose not make sense.
       IF (p_line_rec.schedule_action_code = OESCH_ACT_UNSCHEDULE OR
           p_line_rec.schedule_action_code = OESCH_ACT_UNRESERVE) AND
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

   -- INVCONV
   -- Check to see if the ordered quantity2 and reserved quantity2
   -- both have changed and if the ordered quantity2 is less than
   -- the reserved quantity2. This should not be allowed.

   IF NOT OE_GLOBALS.Equal(p_old_line_rec.ordered_quantity2,
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

           l_return_status := FND_API.G_RET_STS_ERROR;
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'E6a' , 1 ) ;
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
         (p_line_rec.schedule_action_code = OESCH_ACT_UNDEMAND OR
          p_line_rec.schedule_action_code = OESCH_ACT_UNSCHEDULE))
          THEN

             FND_MESSAGE.SET_NAME('ONT','OE_SCH_OE_ORDER_FAILED');
             OE_MSG_PUB.Add;

             l_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CHECKING FOR HOLDS....' , 1 ) ;
   END IF;
   IF FND_PROFILE.VALUE('ONT_SCHEDULE_LINE_ON_HOLD') = 'N' AND
        (p_line_rec.schedule_action_code = OESCH_ACT_SCHEDULE OR
          p_line_rec.schedule_action_code = OESCH_ACT_RESERVE OR
          (p_line_rec.schedule_status_code is not null AND
           Schedule_Attribute_Changed(p_line_rec     => p_line_rec,
                                      p_old_line_rec => p_old_line_rec)) OR
          (p_line_rec.schedule_status_code is not null AND
            p_line_rec.ordered_quantity > p_old_line_rec.ordered_quantity))

/*            (p_line_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
             OESCH_AUTO_SCH_FLAG = 'Y' AND
             p_line_rec.item_type_code = OE_GLOBALS.G_ITEM_STANDARD) OR
             (p_line_rec.schedule_status_code is  null AND
             (p_line_rec.schedule_ship_date is NOT NULL OR
             p_line_rec.schedule_arrival_date is NOT NULL)))
*/
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
   l_scheduling_level_code := Get_Scheduling_Level(p_line_rec.header_id,
										 p_line_rec.line_type_id);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'L_SCHEDULING_LEVEL_CODE : ' || L_SCHEDULING_LEVEL_CODE , 1 ) ;
   END IF;

   IF l_scheduling_level_code is not null THEN
        IF l_scheduling_level_code = SCH_LEVEL_ONE THEN
           IF p_line_rec.schedule_action_code = OESCH_ACT_SCHEDULE OR
              p_line_rec.schedule_action_code = OESCH_ACT_RESERVE OR
             (p_line_rec.schedule_status_code is  null AND
             (p_line_rec.schedule_ship_date is NOT NULL OR
              p_line_rec.schedule_arrival_date is NOT NULL))
            THEN

              FND_MESSAGE.SET_NAME('ONT','OE_SCH_ACTION_NOT_ALLOWED');
              FND_MESSAGE.SET_TOKEN('ACTION',
                       nvl(p_line_rec.schedule_action_code,OESCH_ACT_SCHEDULE));
              FND_MESSAGE.SET_TOKEN('ORDER_TYPE',
                       nvl(sch_cached_line_type,sch_cached_order_type));
              OE_MSG_PUB.Add;
              l_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
        ELSIF l_scheduling_level_code = SCH_LEVEL_TWO OR
              p_line_rec.reserved_quantity > 0 THEN
           IF p_line_rec.schedule_action_code = OESCH_ACT_RESERVE THEN
              FND_MESSAGE.SET_NAME('ONT','OE_SCH_ACTION_NOT_ALLOWED');
              FND_MESSAGE.SET_TOKEN('ACTION',
                        nvl(p_line_rec.schedule_action_code,OESCH_ACT_RESERVE));
              FND_MESSAGE.SET_TOKEN('ORDER_TYPE',
                        nvl(sch_cached_line_type,sch_cached_order_type));
              OE_MSG_PUB.Add;
              l_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
        END IF;
   END IF;

  -- Added this part of validation to fix bug 2051855
   IF  p_line_rec.ato_line_id = p_line_rec.line_id
   AND p_line_rec.item_type_code in ('STANDARD','OPTION')
   AND fnd_profile.value('INV_CTP') = '5' THEN

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
                            oe_debug_pub.add(  '..EXITING OE_ORDER_SCH_UTIL.VALIDATE_LINE WITH ' || L_RETURN_STATUS , 1 ) ;
                        END IF;
END Validate_Line;

/*---------------------------------------------------------------------
Procedure Name : Scheduling_Activity
Description    : ** CURRENT NOT USED **
--------------------------------------------------------------------- */
FUNCTION Scheduling_Activity(p_line_rec IN OE_ORDER_PUB.line_rec_type)
RETURN BOOLEAN
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  RETURN TRUE;
END Scheduling_Activity;

/*---------------------------------------------------------------------
Procedure Name : Check_Item_Attributes
Description    : ** CURRENT NOT USED **
--------------------------------------------------------------------- */
Procedure Check_Item_Attribute(p_line_rec IN OE_ORDER_PUB.line_rec_type)
IS
l_item_rec     OE_ORDER_CACHE.item_rec_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  '..ENTERING CHECK_ITEM_ATTRIBUTE' , 1 ) ;
   END IF;

/*
   l_item_rec   := Oe_Order_Cache.Load_Item
                   (p_key1   => p_line_rec.inventory_item_id,
                    p_key2   => p_line_rec.ship_from_org_id);

   oe_debug_pub.add('..Exiting Check_Item_Attribute',1);
*/

END Check_Item_Attribute;

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
                         x_on_hand_qty      OUT NOCOPY /* file.sql.39 change */ NUMBER,
                         x_avail_to_reserve OUT NOCOPY /* file.sql.39 change */ NUMBER,
                         x_on_hand_qty2 OUT NOCOPY NUMBER, -- INVCONV
												 x_avail_to_reserve2 OUT NOCOPY NUMBER -- INVCONV
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
  l_msg_index               NUMBER;
  l_lot_control_flag        BOOLEAN;
  l_lot_control_code        NUMBER;
  l_org_id                  NUMBER;

  -- added by fabdi 03/May/2001 -- INVCONV NO LONGER NEEDED
  l_process_flag	    VARCHAR2(1) := FND_API.G_FALSE;
  -- l_ic_item_mst_rec         GMI_RESERVATION_UTIL.ic_item_mst_rec; OPM INVCONV 4742691
  -- end fabdi

  l_sqoh                     NUMBER; -- INVCONV
  l_srqoh                    NUMBER; -- INVCONV
  l_sqr                      NUMBER; -- INVCONV
  l_sqs                      NUMBER; -- INVCONV
  l_satt                     NUMBER; -- INVCONV
  l_satr                     NUMBER; -- INVCONV



--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING QUERY_QTY_TREE ' , 1 ) ;
      oe_debug_pub.add(  'ORG IS : ' || P_ORG_ID , 1 ) ;
      oe_debug_pub.add(  'ITEM IS : ' || P_ITEM_ID , 1 ) ;
  END IF;
   /* -- added by fabdi 03/May/2001
  IF NOT INV_GMI_RSV_BRANCH.Process_Branch(p_organization_id => p_org_id)
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
           FND_MESSAGE.SET_TOKEN('BY_PROC','GMI_Reservation_Util.Get_OPM_item_from_Apps');
           FND_MESSAGE.SET_TOKEN('WHERE','OE_ORDER_SCH_UTIL');
           RAISE FND_API.G_EXC_ERROR;
        END IF;

  	get_process_query_quantities ( p_org_id => p_org_id,
				       p_item_id =>  l_ic_item_mst_rec.item_id,
                                       p_line_id => p_line_id,
                                       x_on_hand_qty => l_qoh,
				       x_avail_to_reserve => l_atr
                                      );
  -- end fabdi
  ELSE        */

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
     , p_grade_code           => NULL  -- INVCONV
     , p_is_lot_control          => l_lot_control_flag
     , p_lot_expiration_date     => nvl(p_sch_date,sysdate)
     , p_is_serial_control       => false
     , p_revision                => null
     , p_lot_number              => null
     , p_subinventory_code       => null
     , p_locator_id              => null
     , x_qoh                     => l_qoh
     , x_rqoh                    => l_rqoh
     , x_qr                      => l_qr
     , x_qs                      => l_qs
     , x_att                     => l_att
     , x_atr                     => l_atr
     , x_sqoh                    => l_sqoh        -- INVCONV
     , x_srqoh                 	 => l_srqoh       -- INVCONV
     , x_sqr                   	 => l_sqr         -- INVCONV
     , x_sqs                   	 => l_sqs         -- INVCONV
     , x_satt                  	 => l_satt        -- INVCONV
     , x_satr                  	 => l_satr        -- INVCONV
     );

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER CALLING QUERY_QUANTITIES' , 1 ) ;
  END IF;

--  END IF;



  /* if l_return_status != fnd_api.g_ret_sts_success then
     dbms_output.put_line('status: '|| l_return_status);
     dbms_output.put_line('error message count: '|| l_msg_count);
     if l_msg_count = 1 then
        dbms_output.put_line('error message: '|| l_msg_data);
     else
        for l_index in 1..l_msg_count loop
            fnd_msg_pub.get(  p_data          => l_msg_data
                            , p_msg_index_out => l_msg_index);
            dbms_output.put_line('error message: ' || l_msg_data);
        end loop;
     end if;
   end if; */

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'RR: L_QOH ' || L_QOH , 1 ) ;
      oe_debug_pub.add(  'RR: L_QOH ' || L_ATR , 1 ) ;
  END IF;

  x_on_hand_qty      := l_qoh;
  x_avail_to_reserve := l_atr;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING QUERY_QTY_TREE ' , 1 ) ;
  END IF;

END Query_Qty_Tree;

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
--------------------------------------------------------------------- */
Function Within_Rsv_Time_Fence(p_schedule_ship_date IN DATE)
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
       -- We will check to see if the the schedule_ship_date is within
       -- the reservation time fence. i.e:
       -- If schedule_date - SYSDATE < reservation_time_fence
       -- we will return TRUE, else will return FALSE

       -- Moac. Commented the below code
       -- l_rsv_time_fence_profile :=
       -- FND_PROFILE.VALUE('ONT_RESERVATION_TIME_FENCE');

       -- Moac. Fetching the reservation time fence from system parameter.
       l_rsv_time_fence_profile := OE_Sys_Parameters.VALUE('ONT_RESERVATION_TIME_FENCE');

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
           oe_debug_pub.add(  'L_TIME_TO_SHIP' || L_TIME_TO_SHIP , 1 ) ;
           oe_debug_pub.add(  'L_RSV_TIME_FENCE' || L_RSV_TIME_FENCE , 1 ) ;
       END IF;

       IF l_time_to_ship < 0 THEN
          -- We don't know what this means. Schedule ship date is already
          -- past due. So we are not trying to reserve any inventory for this
          -- line.
          RETURN FALSE;
       ELSIF l_time_to_ship <= l_rsv_time_fence THEN
          RETURN TRUE;
       ELSE
          RETURN FALSE;
       END IF;

END Within_Rsv_Time_Fence;
/*---------------------------------------------------------------------
Procedure Name : Action_Schedule
Description    : This procedure is called from Process_Request proecudure
                 to perform the action of SCHEDULE or RESERVE on the line.
--------------------------------------------------------------------- */

Procedure Action_Schedule(p_x_line_rec     IN OUT NOCOPY OE_ORDER_PUB.line_rec_type,
                          p_old_line_rec   IN  OE_ORDER_PUB.line_rec_type,
                          p_action         IN  VARCHAR2,
                          p_qty_to_reserve IN  NUMBER := null,
                          p_qty2_to_reserve IN  NUMBER := null, -- INVCONV
                          x_return_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
l_line_rec                OE_ORDER_PUB.line_rec_type;
l_old_line_rec            OE_ORDER_PUB.line_rec_type;
l_out_line_rec            OE_ORDER_PUB.line_rec_type;
l_line_tbl                OE_ORDER_PUB.line_tbl_type;
l_old_line_tbl            OE_ORDER_PUB.line_tbl_type;
l_out_line_tbl            OE_ORDER_PUB.line_tbl_type;
l_old_atp_tbl             OE_ATP.atp_tbl_type;
l_return_status           VARCHAR2(1);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(2000);

l_session_id              NUMBER := 0;
l_mrp_atp_rec             MRP_ATP_PUB.ATP_Rec_Typ;
l_out_mtp_atp_rec         MRP_ATP_PUB.ATP_Rec_Typ;
l_atp_supply_demand       MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_atp_period              MRP_ATP_PUB.ATP_Period_Typ;
l_atp_details             MRP_ATP_PUB.ATP_Details_Typ;
l_out_atp_tbl             OE_ATP.atp_tbl_type;
mrp_msg_data              VARCHAR2(200);

l_reservation_rec         inv_reservation_global.mtl_reservation_rec_type;
l_dummy_sn                inv_reservation_global.serial_number_tbl_type;
l_quantity_reserved       NUMBER;
l_qty_to_reserve          NUMBER;
l_quantity2_reserved      NUMBER; -- INVCONV
l_qty2_to_reserve         NUMBER; -- INVCONV

l_rsv_id                  NUMBER;


l_reservable_type         NUMBER;

l_buffer                  VARCHAR2(2000);

-- subinventory
l_revision_code NUMBER;
l_lot_code      NUMBER;
l_serial_code   NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING ACTION SCHEDULE' , 1 ) ;
  END IF;
  l_line_rec       := p_x_line_rec;
  l_out_line_rec   := p_x_line_rec;
  l_old_line_rec   := p_old_line_rec;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'RR5: ATO LINE ID: ' || L_LINE_REC.ATO_LINE_ID , 1 ) ;
  END IF;
  IF (l_line_rec.schedule_status_code is null)
  THEN

    -- The line is not scheduled, so go ahead and schedule the line
    -- Create MRP record from the line record with the action of schedule
    -- The result of the request should be in x_request_rec

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SCHEDULE THE LINE' , 1 ) ;
    END IF;

    -- Setting the action to schedule since first we need to schedule the line.
    -- Will reset the action to what is actually was after calling MRP.

    l_line_rec.schedule_action_code := OESCH_ACT_SCHEDULE;

    l_line_tbl(1)     := l_line_rec;
    l_old_line_tbl(1) := l_old_line_rec;

    Load_MRP_Request
          ( p_line_tbl              => l_line_tbl
          , p_old_line_tbl          => l_old_line_tbl
          , x_atp_table             => l_mrp_atp_rec);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'SCH1 COUNT IS ' || L_MRP_ATP_REC.ERROR_CODE.COUNT , 1 ) ;
   END IF;

   -- We are adding this so that we will not call MRP when
   -- table count is 0.

   IF l_mrp_atp_rec.error_code.count > 0 THEN


    l_session_id := Get_Session_Id;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  '1. CALLING MRP API WITH SESSION ID '||L_SESSION_ID , 1 ) ;
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
                                                  oe_debug_pub.add(  '1. AFTER CALLING MRP_ATP_PUB.CALL_ATP' || L_RETURN_STATUS , 1 ) ;
                                              END IF;
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ERROR IS' || MRP_MSG_DATA , 1 ) ;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    Load_Results(p_atp_table       => l_out_mtp_atp_rec,
                 p_x_line_tbl        => l_line_tbl,
                 x_atp_tbl         => l_out_atp_tbl,
                 x_return_status   => l_return_status);

    END IF; -- Check for MRP count.

    l_out_line_rec := l_line_tbl(1);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RR: L_RETURN_STATUS ' || L_RETURN_STATUS , 1 ) ;
    END IF;
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'RR: L1' , 1 ) ;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'RR: L2' , 1 ) ;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Reloading l_line_rec from l_out_line_tbl since the record
    -- in the table is the one which is demanded.

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RR: L3' , 1 ) ;
    END IF;
    l_line_rec     := l_line_tbl(1);
    l_line_rec.schedule_action_code := p_action;

  END IF; /* If schedule_status_code is null */

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'RR: L4' , 1 ) ;
      oe_debug_pub.add(  'SCH_CACHED_SCH_LEVEL_CODE ' || SCH_CACHED_SCH_LEVEL_CODE , 1 ) ;
  END IF;

  IF (p_action = OESCH_ACT_RESERVE)
      OR (p_action = OESCH_ACT_SCHEDULE AND
         (sch_cached_sch_level_code = SCH_LEVEL_THREE OR
          sch_cached_sch_level_code is null) AND
          Within_Rsv_Time_Fence(l_line_rec.schedule_ship_date)) OR
     (p_qty_to_reserve is not null)
  THEN

    /* Assigning reserved_quantity to 0 if MISS_NUM, to fix the bug 1384831 */

    IF l_old_line_rec.reserved_quantity = FND_API.G_MISS_NUM THEN

       l_old_line_rec.reserved_quantity := 0;

    END IF;
    IF l_old_line_rec.reserved_quantity2 = FND_API.G_MISS_NUM THEN -- INVCONV

       l_old_line_rec.reserved_quantity2 := 0;

    END IF;


    IF nvl(l_line_rec.shippable_flag,'N') = 'Y'
    THEN
      -- Create INV record from the line to reserve

      IF p_qty_to_reserve is null THEN
         l_qty_to_reserve := l_line_rec.ordered_quantity -
                           nvl(l_old_line_rec.reserved_quantity,0);
      ELSE
         l_qty_to_reserve := p_qty_to_reserve;
      END IF;

			IF p_qty2_to_reserve is null THEN  -- INVCONV
         l_qty2_to_reserve := l_line_rec.ordered_quantity2 -
                           nvl(l_old_line_rec.reserved_quantity2,0);
      ELSE
         l_qty2_to_reserve := p_qty2_to_reserve;
      END IF;



      IF l_qty_to_reserve > 0 THEN

         IF l_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
            -- We cannot create a reservation currently if the line is
            -- being created (since the lines is yet not in the database,
            -- and there is a validation done with this line id when we
            -- call INV API.). We will populate the reserved quantity on
            -- the line record, and in the post-write procedure (in OEXULINB),
            -- we will perform the reservation.

            l_out_line_rec := l_line_rec;
            l_out_line_rec.schedule_status_code := OESCH_STATUS_SCHEDULED;
            l_out_line_rec.reserved_quantity    := l_qty_to_reserve;
  					l_out_line_rec.reserved_quantity2    := l_qty2_to_reserve; -- INVCONV
         ELSE

          IF p_action <> OESCH_ACT_RESERVE THEN
		   SELECT RESERVABLE_TYPE
		   INTO   l_reservable_type
		   FROM   MTL_SYSTEM_ITEMS
		   WHERE  INVENTORY_ITEM_ID = l_line_rec.inventory_item_id
		   AND    ORGANIZATION_ID = l_line_rec.ship_from_org_id;

		   IF l_reservable_type <> 1 THEN

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'NON RESERVABLE ITEM RESERVATION NOT REQUIRED '||L_RESERVABLE_TYPE , 3 ) ;
                END IF;
		 	GOTO NO_RESERVATION;
		   END IF;

		END IF;

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'L_QTY_TO_RESERVE : ' || L_QTY_TO_RESERVE , 3 ) ;
                oe_debug_pub.add(  'L_QTY2_TO_RESERVE : ' || L_QTY2_TO_RESERVE , 3 ) ; -- INVCONV
            END IF;
            --newsub check if item is under lot/revision/serial control
            IF l_line_rec.subinventory is not null
               AND l_line_rec.subinventory <> FND_API.G_MISS_CHAR THEN
               BEGIN
                 SELECT revision_qty_control_code, lot_control_code,
                        serial_number_control_code
                 INTO l_revision_code, l_lot_code, l_serial_code
                 FROM mtl_system_items
                 WHERE inventory_item_id = l_line_rec.inventory_item_id
                 AND   organization_id   = l_line_rec.ship_from_org_id;

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
                     IF p_action = OESCH_ACT_RESERVE THEN
                         l_return_status := FND_API.G_RET_STS_ERROR;
                         RAISE FND_API.G_EXC_ERROR;
                     ELSE
                         l_return_status     := FND_API.G_RET_STS_SUCCESS;
                         l_quantity_reserved := null;
                         l_quantity2_reserved := null; -- INVCONV
                         GOTO NO_RESERVATION;
                     END IF;

               END IF;
             END IF;
            --end newsub

             Load_INV_Request
              ( p_line_rec              => l_line_rec
              , p_quantity_to_reserve   => l_qty_to_reserve
              , p_quantity2_to_reserve   => l_qty2_to_reserve -- INVCONV
              , x_reservation_rec       => l_reservation_rec);

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
                , x_secondary_quantity_reserved => l_quantity2_reserved -- INVCONV
                , x_reservation_id            => l_rsv_id
                );

                                              IF l_debug_level  > 0 THEN
                                                  oe_debug_pub.add(  '1. AFTER CALLING CREATE RESERVATION' || L_RETURN_STATUS , 1 ) ;
                  oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
              END IF;

	      -- Bug No:2097933
	      -- If the Reservation was succesfull we set
	      -- the package variable to "Y".
              IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                OESCH_PERFORMED_RESERVATION := 'Y';
	      END IF;

              IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'RAISING UNEXPECTED ERROR' , 1 ) ;
                   END IF;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   IF l_msg_data is not null THEN
                      fnd_message.set_encoded(l_msg_data);
                      l_buffer := fnd_message.get;
                      oe_msg_pub.add_text(p_message_text => l_buffer);
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
                      END IF;
                   END IF;

                   IF p_action = OESCH_ACT_RESERVE THEN

                      -- The user has explicitly required a reservation.
                      -- We should error out since reservation failed.

                      RAISE FND_API.G_EXC_ERROR;

                   ELSE
                      -- Reservation action took place since the line
                      -- was within reservation time fence. We do not
                      -- need to error out for this. The message will
                      -- indicate that reservation did not take place.

                      l_return_status     := FND_API.G_RET_STS_SUCCESS;
                      l_quantity_reserved := null;
											l_quantity2_reserved := null; -- INVCONV
                   END IF;

              END IF;

		    << NO_RESERVATION >>

              l_out_line_rec := l_line_rec;
              l_out_line_rec.schedule_status_code := OESCH_STATUS_SCHEDULED;
              --l_out_line_rec.reserved_quantity    := l_quantity_reserved;
         END IF; /* Operation on the line is create or not */

      ELSE

           l_out_line_rec := l_line_rec;
           l_out_line_rec.schedule_status_code := OESCH_STATUS_SCHEDULED;
           l_out_line_rec.reserved_quantity :=
                                  l_old_line_rec.reserved_quantity;
           l_out_line_rec.reserved_quantity2 :=
                                  l_old_line_rec.reserved_quantity2; -- INVCONV


      END IF; /* l_qty_to_reserve > 0 */
    END IF; /* If shippable Flag = Y */

  END IF; /* If reservation needs to be performed */

    p_x_line_rec      := l_out_line_rec;
    x_return_status := l_return_status;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING ACTION SCHEDULE: ' || L_RETURN_STATUS , 1 ) ;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

        p_x_line_rec      := l_out_line_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Action_Schedule'
            );
        END IF;

END Action_Schedule;

/*---------------------------------------------------------------------
Procedure Name : Action_UnSchedule
Description    : This procedure is called from Process_Request proecudure
                 to perform the action of UNSCHEDULE or UNRESERVE on the line.
--------------------------------------------------------------------- */

Procedure Action_UnSchedule(p_old_line_rec  IN  OE_ORDER_PUB.line_rec_type,
                            p_action        IN  VARCHAR2,
                            p_x_line_rec    IN OUT NOCOPY OE_ORDER_PUB.line_rec_type,
                            x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS

l_line_rec                OE_ORDER_PUB.line_rec_type;
l_old_line_rec            OE_ORDER_PUB.line_rec_type;
l_out_line_rec            OE_ORDER_PUB.line_rec_type;
l_line_tbl                OE_ORDER_PUB.line_tbl_type;
l_old_line_tbl            OE_ORDER_PUB.line_tbl_type;
l_out_line_tbl            OE_ORDER_PUB.line_tbl_type;
l_old_atp_tbl             OE_ATP.atp_tbl_type;
l_return_status           VARCHAR2(1);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(2000);
l_out_atp_rec             OE_ATP.atp_rec_type;
l_session_id              NUMBER := 0;
l_mrp_atp_rec             MRP_ATP_PUB.ATP_Rec_Typ;
l_out_mtp_atp_rec         MRP_ATP_PUB.ATP_Rec_Typ;
l_atp_supply_demand       MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_atp_period              MRP_ATP_PUB.ATP_Period_Typ;
l_atp_details             MRP_ATP_PUB.ATP_Details_Typ;
l_out_atp_tbl             OE_ATP.atp_tbl_type;
mrp_msg_data              VARCHAR2(200);
l_reservation_rec         inv_reservation_global.mtl_reservation_rec_type;
l_dummy_sn                inv_reservation_global.serial_number_tbl_type;
l_qty_to_unreserve        NUMBER;
l_rsv_id                  NUMBER;

l_qty2_to_unreserve        NUMBER; -- INVCONV
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING ACTION_UNSCHEDULE ' , 1 ) ;
     END IF;

     l_line_rec     := p_x_line_rec;
     l_old_line_rec := p_old_line_rec;


     -- Only unreserve line if line has NOT been interfaced to WSH

     IF (nvl(l_line_rec.shipping_interfaced_flag, 'N') = 'N' AND
        l_old_line_rec.reserved_quantity is not null AND
        l_old_line_rec.reserved_quantity <> FND_API.G_MISS_NUM)
     THEN

             -- Call INV API to delete the reservations on  the line.

          l_qty_to_unreserve := l_old_line_rec.reserved_quantity;
          l_qty_to_unreserve := nvl(l_old_line_rec.reserved_quantity, 0);  -- INVCONV

          Unreserve_Line
             ( p_line_rec               => l_old_line_rec
             , p_quantity_to_unreserve  => l_qty_to_unreserve
             , p_quantity2_to_unreserve  => l_qty2_to_unreserve -- INVCONV
             , x_return_status          => l_return_status);

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
          END IF;

          l_out_line_rec                      := l_line_rec;
          l_out_line_rec.schedule_status_code := OESCH_STATUS_SCHEDULED;

     END IF;


     -- If the action was unreserve, we do not need to unschedule the line.
     -- Thus we will check for this condition before unscheduling.

     IF p_action <> OESCH_ACT_UNRESERVE THEN

         -- Create MRP record with action of UNDEMAND.


         l_line_rec.schedule_action_code := OESCH_ACT_UNDEMAND;

         l_line_tbl(1)     := l_line_rec;
         l_old_line_tbl(1) := l_old_line_rec;

        Load_MRP_Request
          ( p_line_tbl              => l_line_tbl
          , p_old_line_tbl          => l_old_line_tbl
          , x_atp_table             => l_mrp_atp_rec);

        l_session_id := Get_Session_Id;

        -- Call ATP

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  '1. CALLING MRP API WITH SESSION ID '||L_SESSION_ID , 1 ) ;
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
                                                  oe_debug_pub.add(  '2. AFTER CALLING MRP_ATP_PUB.CALL_ATP' || L_RETURN_STATUS , 1 ) ;
                                              END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        Load_Results(p_atp_table       => l_out_mtp_atp_rec,
                     p_x_line_tbl      => l_line_tbl,
                     x_atp_tbl         => l_out_atp_tbl,
                     x_return_status   => l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_out_line_rec := l_line_tbl(1);
        l_out_atp_rec  := l_out_atp_tbl(1);

    END IF;

    -- If the action performed is UNSCHEDULE, then the reserved quantity is now     -- null.
    l_out_line_rec.reserved_quantity    := null;

    p_x_line_rec      := l_out_line_rec;
    x_return_status := l_return_status;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING ACTION_UNSCHEDULE ' , 1 ) ;
  END IF;

END Action_UnSchedule;

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

Procedure Process_request( p_old_line_rec   IN  OE_ORDER_PUB.line_rec_type,
                          p_x_line_rec     IN OUT NOCOPY OE_ORDER_PUB.line_rec_type,
                          x_out_atp_tbl    OUT NOCOPY /* file.sql.39 change */ OE_ATP.atp_tbl_type,
                          x_return_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS

l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_line_rec                  OE_ORDER_PUB.line_rec_type;
l_line_tbl                  OE_ORDER_PUB.line_tbl_type;
l_old_line_tbl              OE_ORDER_PUB.line_tbl_type;
l_out_line_rec              OE_ORDER_PUB.line_rec_type;
l_out_atp_rec               OE_ATP.atp_rec_type;
l_out_line_tbl              OE_ORDER_PUB.line_tbl_type;
l_out_atp_tbl               OE_ATP.atp_tbl_type;
l_old_line_rec              OE_ORDER_PUB.line_rec_type;
l_action                    VARCHAR2(30);
l_old_status                VARCHAR2(30);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);
l_reservation_rec           inv_reservation_global.mtl_reservation_rec_type;
l_query_rsv_rec             inv_reservation_global.mtl_reservation_rec_type;
l_rsv_tbl                   inv_reservation_global.mtl_reservation_tbl_type;
l_dummy_sn                  inv_reservation_global.serial_number_tbl_type;
l_quantity_reserved         NUMBER;
l_rsv_id                    NUMBER;
l_qty_unreserved            NUMBER := 0;
l_qty_reserved              NUMBER;

l_changed_ordered_qty       NUMBER := 0;
l_changed_reserved_qty      NUMBER := 0;
l_qty_to_unreserve          NUMBER := 0;
l_qty_to_reserve            NUMBER := 0;

-- INVCONV
l_qty2_unreserved            NUMBER := 0;
l_qty2_reserved              NUMBER;

l_changed_ordered_qty2       NUMBER := 0;
l_changed_reserved_qty2      NUMBER := 0;
l_qty2_to_unreserve          NUMBER := 0;
l_qty2_to_reserve            NUMBER := 0;
l_on_hand_qty2                NUMBER;
l_quantity2_reserved          NUMBER; -- INVCONV


l_session_id              NUMBER := 0;
l_mrp_atp_rec             MRP_ATP_PUB.ATP_Rec_Typ;
l_out_mtp_atp_rec         MRP_ATP_PUB.ATP_Rec_Typ;
l_atp_supply_demand       MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_atp_period              MRP_ATP_PUB.ATP_Period_Typ;
l_atp_details             MRP_ATP_PUB.ATP_Details_Typ;
mrp_msg_data              VARCHAR2(200);
l_on_hand_qty             NUMBER;
l_avail_to_reserve        NUMBER;
l_avail_to_reserve2       NUMBER; -- INVCONV
l_buffer                  VARCHAR2(2000);
l_reservable_type         NUMBER;
l_re_reserve_flag         VARCHAR2(1) := 'N';
-- added by fabdi 03/May/2001
-- l_process_flag            VARCHAR2(1) := FND_API.G_FALSE; -- INVCONV
-- end fabdi
l_sales_order_id          NUMBER;
l_x_error_code            NUMBER;
l_lock_records            VARCHAR2(1);
l_sort_by_req_date        NUMBER ;
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
      oe_debug_pub.add(  'ENTERING OE_ORDER_SCH_UTIL.PROCESS_REQUEST' , 1 ) ;
      oe_debug_pub.add(  'OESCH_AUTO_SCH_FLAG : ' || OESCH_AUTO_SCH_FLAG , 1 ) ;
  END IF;

  l_line_rec      := p_x_line_rec;
  l_out_line_rec  := p_x_line_rec;
  l_old_line_rec  := p_old_line_rec;
  l_action        := p_x_line_rec.schedule_action_code;
  l_old_status    := p_old_line_rec.schedule_status_code;

  -- There is a possiblity that the schedule_action_code comes to this
  -- code as missing. If it does, we will assign null value to it.

  IF (l_line_rec.schedule_action_code = FND_API.G_MISS_CHAR) THEN
      l_line_rec.schedule_action_code := null;
  END IF;


  IF (l_line_rec.schedule_action_code is NULL) THEN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SCHEDULE ACTION CODE IS NULL' , 1 ) ;
     END IF;

     IF (l_line_rec.schedule_status_code IS NULL) AND
         (OESCH_AUTO_SCH_FLAG = 'N') AND
         OE_GLOBALS.Equal(l_line_rec.schedule_ship_date,
                          l_old_line_rec.schedule_ship_date) AND
         OE_GLOBALS.Equal(l_line_rec.schedule_arrival_date,
                          l_old_line_rec.schedule_arrival_date) AND
         OE_GLOBALS.Equal(l_line_rec.reserved_quantity,
                          l_old_line_rec.reserved_quantity)
     THEN

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NO ACTION NEEDED TO BE PERFORMED' , 1 ) ;
         END IF;
         -- no action needs to be performed;
         goto end_of_processing;

     END IF;

     IF (l_line_rec.operation = OE_GLOBALS.G_OPR_DELETE) OR
        ((l_line_rec.source_type_code = OE_GLOBALS.G_SOURCE_EXTERNAL) AND
        (l_line_rec.schedule_status_code is not null)) THEN

        -- If the line is deleted, we need to unschedule it.
        -- If the line's source type is being changed from INTERNAL to
        -- EXTERNAL, and the old line was scheduled, we need to unschedule it.

        l_line_rec.schedule_action_code := OESCH_ACT_UNSCHEDULE;
		l_out_line_rec := l_line_rec;
        Action_UnSchedule(p_x_line_rec      => l_out_line_rec,
                          p_old_line_rec  => l_old_line_rec,
                          p_action        => OESCH_ACT_UNSCHEDULE,
                          x_return_status => l_return_status);

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
        END IF;

        goto end_of_processing;

     END IF; /* If operation on line was DELETE */

     IF NOT OE_GLOBALS.Equal(l_line_rec.schedule_ship_date,
                             l_old_line_rec.schedule_ship_date) THEN

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'NEW' || L_LINE_REC.SCHEDULE_SHIP_DATE ) ;
               oe_debug_pub.add(  'OLD' || L_OLD_LINE_REC.SCHEDULE_SHIP_DATE ) ;
           END IF;

        -- We will treat a special case here where the date changes
        -- from no date to some date. If this change takes place,
        -- it means the line was not scheduled and needs to get scheduled
        -- and not rescheduled.

        IF (l_old_line_rec.schedule_ship_date) is null OR
           (l_old_line_rec.schedule_ship_date = FND_API.G_MISS_DATE) THEN

            -- Set the action on the line as schedule
            l_line_rec.schedule_action_code := OESCH_ACT_SCHEDULE;

		    l_out_line_rec := l_line_rec;
            Action_Schedule(p_x_line_rec    => l_out_line_rec,
                            p_old_line_rec  => l_old_line_rec,
                            p_action        => OESCH_ACT_SCHEDULE,
                            x_return_status => l_return_status);

             IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;


            goto end_of_processing;

        END IF; /* For special demand */
     END IF; /* If schedule date has changed */

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OLD AD ' || L_OLD_LINE_REC.SCHEDULE_ARRIVAL_DATE , 1 ) ;
         oe_debug_pub.add(  'NEW AD ' || L_OLD_LINE_REC.SCHEDULE_ARRIVAL_DATE , 1 ) ;
     END IF;

     IF NOT OE_GLOBALS.Equal(l_line_rec.schedule_arrival_date,
                             l_old_line_rec.schedule_arrival_date) THEN

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'NEW' || L_LINE_REC.SCHEDULE_ARRIVAL_DATE ) ;
               oe_debug_pub.add(  'OLD' || L_OLD_LINE_REC.SCHEDULE_ARRIVAL_DATE ) ;
           END IF;

        -- We will treat a special case here where the date changes
        -- from no date to some date. If this change takes place,
        -- it means the line was not scheduled and needs to get scheduled
        -- and not rescheduled.

        IF (l_old_line_rec.schedule_arrival_date) is null OR
           (l_old_line_rec.schedule_arrival_date = FND_API.G_MISS_DATE) THEN

		    l_out_line_rec := l_line_rec;
            Action_Schedule(p_x_line_rec    => l_out_line_rec,
                            p_old_line_rec  => l_old_line_rec,
                            p_action        => OESCH_ACT_SCHEDULE,
                            x_return_status => l_return_status);

             IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;


            goto end_of_processing;

        END IF; /* For special demand */
     END IF; /* If schedule date has changed */

     /* status_code <> null and action_code is null */
     /* This condition means, existing order has been changed */

     IF p_x_line_rec.schedule_status_code is not null AND
        Schedule_Attribute_Changed(p_line_rec     => l_line_rec,
                                   p_old_line_rec => l_old_line_rec)

     THEN

          /* ordered_quantity has changed. Set the flag G_LINE_PART_OF_SET
             if the line belongs to a ship or arrival set */

          IF l_line_rec.ship_set_id is not null OR
             l_line_rec.arrival_set_id is not null THEN
             G_LINE_PART_OF_SET := TRUE;
          END IF;

         -- Right now I am assuming that when the scheduling attributes
         -- changes, we will unreserve all the quantity

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'RESCHEDULING SINCE SCHEDULE ATTRIBUTE CHANGED' ) ;
             oe_debug_pub.add(  'OLD RESERV QTY ' || L_OLD_LINE_REC.RESERVED_QUANTITY , 1 ) ;
         END IF;
         IF (l_old_line_rec.reserved_quantity is not null)
         THEN

           -- Added this part of code to fix bug 1797109.
           -- Unreserve only when one of the below mentioned, attrubutes
           -- changes, in other case simply re-schedule the line.
           --During the fix l_re_reserve_flag is introduced.
           l_re_reserve_flag := 'N';
           -- Only unreserve line if line has NOT been interfaced to WSH
           IF  (nvl(l_line_rec.shipping_interfaced_flag, 'N') = 'N' AND
               (NOT OE_GLOBALS.Equal(l_line_rec.inventory_item_id,
                               l_old_line_rec.inventory_item_id)
                OR NOT OE_GLOBALS.Equal(l_line_rec.subinventory,
                               l_old_line_rec.subinventory)
                OR NOT OE_GLOBALS.Equal(l_line_rec.ordered_quantity,
                               l_old_line_rec.ordered_quantity)
                OR NOT OE_GLOBALS.Equal(l_line_rec.order_quantity_uom,
                               l_old_line_rec.order_quantity_uom)
                OR NOT OE_GLOBALS.Equal(l_line_rec.ship_from_org_id,
                               l_old_line_rec.ship_from_org_id))) THEN

                l_re_reserve_flag := 'Y';
                -- Call INV to delete the old reservations
                Unreserve_Line
                   (p_line_rec              => l_old_line_rec,
                    p_quantity_to_unreserve => l_old_line_rec.reserved_quantity,
                    p_quantity2_to_unreserve => nvl(l_old_line_rec.reserved_quantity2, 0),  -- INVCONV
                    x_return_status         => l_return_status);
           END IF;

         ELSE
           l_re_reserve_flag := 'Y';
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'SETTING RE RESERVE IN ELSE' , 1 ) ;
           END IF;
         END IF;

        -- If the scheduling is happening due to inventory item change.
        -- We should call MRP twice. First time we should call the with
        -- Undemand for old item. Second call would be redemand.

          IF NOT OE_GLOBALS.Equal(l_line_rec.inventory_item_id,
                                  l_old_line_rec.inventory_item_id)
          THEN

             Action_undemand(p_old_line_rec  => l_old_line_rec,
                             x_return_status => l_return_status);

             IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          END IF;

         -- Call MRP with action = REDEMAND

          l_line_rec.schedule_action_code := OESCH_ACT_REDEMAND;
          l_line_tbl(1)     := l_line_rec;
          l_old_line_tbl(1) := l_old_line_rec;

          Load_MRP_Request
           ( p_line_tbl              => l_line_tbl
           , p_old_line_tbl          => l_old_line_tbl
           , x_atp_table             => l_mrp_atp_rec);

          l_session_id := Get_Session_Id;

          -- Call ATP

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  '1. CALLING MRP API WITH SESSION ID '||L_SESSION_ID , 1 ) ;
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
                                                  oe_debug_pub.add(  '3. AFTER CALLING MRP_ATP_PUB.CALL_ATP' || L_RETURN_STATUS , 1 ) ;
                                              END IF;

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          Load_Results(p_atp_table       => l_out_mtp_atp_rec,
                       p_x_line_tbl      => l_line_tbl,
                       x_atp_tbl         => l_out_atp_tbl,
                       x_return_status   => l_return_status);

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
          END IF;

          l_out_line_rec := l_line_tbl(1);

          -- Adding code to fix bug 2126165.

          IF NOT OE_GLOBALS.Equal(l_out_line_rec.schedule_ship_date,
                                  l_old_line_rec.schedule_ship_date)
          AND l_old_line_rec.reserved_quantity > 0
          AND l_re_reserve_flag = 'N'
          THEN


            l_query_rsv_rec.reservation_id := fnd_api.g_miss_num;

            l_sales_order_id
                       := Get_mtl_sales_order_id(l_old_line_rec.header_id);
            l_query_rsv_rec.demand_source_header_id  := l_sales_order_id;
            l_query_rsv_rec.demand_source_line_id    := l_old_line_rec.line_id;

            -- 02-jun-2000 mpetrosi added org_id to query_reservation start
            l_query_rsv_rec.organization_id  := l_old_line_rec.ship_from_org_id;
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
            FOR K IN 1..l_rsv_tbl.count LOOP

               l_reservation_rec := l_rsv_tbl(K);
               l_reservation_rec.requirement_date := l_out_line_rec.schedule_ship_date;

               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'RSCH: CALLING INVS UPDATE RESERVATION ' , 1 ) ;
               END IF;
               inv_reservation_pub.update_reservation
               ( p_api_version_number        => 1.0
               , p_init_msg_lst              => fnd_api.g_true
               , x_return_status             => l_return_status
               , x_msg_count                 => l_msg_count
               , x_msg_data                  => l_msg_data
               , p_original_rsv_rec          => l_rsv_tbl(k)
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

          IF nvl(l_line_rec.shippable_flag,'N') = 'Y'
          THEN
           -- This check will avoid calling reservation for
           -- non-shippable items.

            -- Inv code expect the item to be available in database before
            -- making reservation. If the reservation is being made due to
            -- change in inventory_item_id, we will move the reservation
            -- call to post_write. -- 1913263.

           IF (NOT OE_GLOBALS.Equal(l_line_rec.inventory_item_id,
                                   l_old_line_rec.inventory_item_id) OR
               NOT OE_GLOBALS.Equal(l_line_rec.ship_from_org_id,
                                   l_old_line_rec.ship_from_org_id)) AND
              l_re_reserve_flag = 'Y' THEN

                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'NO RE-RESERVE DUE TO ITEM/WAREHOUSE CHANGE' , 1 ) ;
                 END IF;
                 goto end_of_processing;

           END IF;

           -- Call INV to create reservation if the line
           -- was previously reserved.

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'BEFORE RESERVATION CHECK' , 1 ) ;
           END IF;

          IF (l_line_rec.reserved_quantity IS NOT NULL
             OR ((sch_cached_sch_level_code = SCH_LEVEL_THREE  OR
                  sch_cached_sch_level_code is null)
                 AND Within_Rsv_Time_Fence(l_out_line_rec.schedule_ship_date)))
             AND l_re_reserve_flag = 'Y'
          THEN
            -- Create INV record from the line to reserve

             IF l_line_rec.reserved_quantity is not null AND
                OE_GLOBALS.Equal(p_x_line_rec.order_quantity_uom,
                                 p_old_line_rec.order_quantity_uom)
             THEN
                --If quantity and request(any scheduling dates) changed, system
                --is re_reserving based on the reserved qty, even when qty is
                --is decresed. Modified to take ordered qty when it is less than
                --previously reserved qty.

                IF l_line_rec.reserved_quantity > p_x_line_rec.ordered_quantity
                THEN
                 l_qty_to_reserve := p_x_line_rec.ordered_quantity;
                ELSE
                 l_qty_to_reserve := l_line_rec.reserved_quantity;
                END IF;

                IF l_line_rec.reserved_quantity2 > p_x_line_rec.ordered_quantity2 -- INVCONV
                THEN
                 l_qty2_to_reserve := p_x_line_rec.ordered_quantity2;
                ELSE
                 l_qty2_to_reserve := l_line_rec.reserved_quantity2;
                END IF;


             ELSE
                l_qty_to_reserve := p_x_line_rec.ordered_quantity;
                l_qty2_to_reserve := p_x_line_rec.ordered_quantity2; -- INVCONV
             END IF;

             -- Load the INV record

		      SELECT RESERVABLE_TYPE
		      INTO   l_reservable_type
		      FROM   MTL_SYSTEM_ITEMS
		      WHERE  INVENTORY_ITEM_ID = l_line_rec.inventory_item_id
		      AND    ORGANIZATION_ID = l_line_rec.ship_from_org_id;

 		      IF l_reservable_type <> 1 THEN

                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'NON RESERVABLE ITEM RESERVATION NOT REQUIRED '||L_RESERVABLE_TYPE , 3 ) ;
                   END IF;
			    GOTO NO_RESERVATION;
		      END IF;

             --newsub check if item is under lot/revision/serial control
            IF l_line_rec.subinventory is not null
               AND l_line_rec.subinventory <> FND_API.G_MISS_CHAR THEN
               BEGIN
                 SELECT revision_qty_control_code, lot_control_code,
                        serial_number_control_code
                 INTO l_revision_code, l_lot_code, l_serial_code
                 FROM mtl_system_items
                 WHERE inventory_item_id = l_line_rec.inventory_item_id
                 AND   organization_id   = l_line_rec.ship_from_org_id;

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
                     IF l_line_rec.schedule_action_code = OESCH_ACT_RESERVE THEN
                         l_return_status := FND_API.G_RET_STS_ERROR;
                         RAISE FND_API.G_EXC_ERROR;
                     ELSE
                         l_return_status     := FND_API.G_RET_STS_SUCCESS;
                         l_quantity_reserved := null;
                         l_quantity2_reserved := null; -- INVCONV
                         GOTO NO_RESERVATION;
                     END IF;

               END IF;
             END IF;
              --end newsub

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'CALLING LOAD_INV_REQUEST' , 1 ) ;
             END IF;

             Load_INV_Request
             ( p_line_rec              => l_line_rec
             , p_quantity_to_reserve   => l_qty_to_reserve
             , p_quantity2_to_reserve   => l_qty2_to_reserve -- INVCONV
             , x_reservation_rec       => l_reservation_rec);

             -- Call INV with action = RESERVE

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'CALLING INVS CREATE_RESERVATION' , 1 ) ;
             END IF;

             inv_reservation_pub.create_reservation
              (
                 p_api_version_number        => 1.0
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
               , x_secondary_quantity_reserved => l_quantity2_reserved -- INVCONV
               , x_reservation_id            => l_rsv_id
               );

                                              IF l_debug_level  > 0 THEN
                                                  oe_debug_pub.add(  '2. AFTER CALLING CREATE RESERVATION' || L_RETURN_STATUS , 1 ) ;
                                              END IF;
	      -- Bug No:2097933
	      -- If the Reservation was succesfull we set
	      -- the package variable to "Y".
              IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                OESCH_PERFORMED_RESERVATION := 'Y';
	      END IF;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
              END IF;

             IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                IF l_msg_data is not null THEN
                   fnd_message.set_encoded(l_msg_data);
                   l_buffer := fnd_message.get;
                   oe_msg_pub.add_text(p_message_text => l_buffer);
                END IF;

                IF l_line_rec.Schedule_action_code = OESCH_ACT_RESERVE THEN
                   RAISE FND_API.G_EXC_ERROR;
                ELSE
                   l_return_status := FND_API.G_RET_STS_SUCCESS;
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'UNABLE TO RESERVE' , 2 ) ;
                   END IF;
                END IF;

             END IF;

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'AFTER CALLING INVS CREATE_RESERVATION' , 1 ) ;
             END IF;

		   << NO_RESERVATION >>
		   NULL;

          END IF;
      END IF; -- Check for shippable flag.


       -- Added this part of the code to fix bug 2536435
       -- Code to handle reserved quantity
       IF l_old_line_rec.reserved_quantity is null OR
          l_old_line_rec.reserved_quantity = FND_API.G_MISS_NUM THEN
          l_old_line_rec.reserved_quantity := 0;
       END IF;
			 IF l_old_line_rec.reserved_quantity2 is null OR -- INVCONV
          l_old_line_rec.reserved_quantity2 = FND_API.G_MISS_NUM THEN
          l_old_line_rec.reserved_quantity2 := 0;
       END IF;



       IF  l_line_rec.ordered_quantity  >=  l_line_rec.reserved_quantity THEN

       -- After the changes are made to the order, the order qty is still
       -- greater than the reserved quantity. This is a valid change.

         l_changed_reserved_qty   := l_old_line_rec.reserved_quantity -
                        l_line_rec.reserved_quantity;

         IF l_changed_reserved_qty > 0 THEN
         -- this definitely is a reserved_quantity decrement
         -- CMS is not touching this explicit rsv qty decrease
             IF nvl(l_line_rec.shipping_interfaced_flag, 'N') = 'N' THEN

               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  '1 RESERVED QUANTITY HAS DECREASED' , 1 ) ;
               END IF;


               l_qty_to_unreserve   := l_old_line_rec.reserved_quantity -
                           l_line_rec.reserved_quantity;
							 l_qty2_to_unreserve   := nvl(l_old_line_rec.reserved_quantity2, 0)  -   -- INVCONV
                           nvl(l_line_rec.reserved_quantity, 0);


               -- No need to pass old record. Since this is a change
               -- due to quantity.
               Unreserve_Line
               ( p_line_rec                => l_line_rec
                , p_quantity_to_unreserve => l_qty_to_unreserve
                , p_quantity2_to_unreserve => l_qty2_to_unreserve -- INVCONV
                , x_return_status         => l_return_status);

               IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               END IF;

             ELSE

               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  '1 RESERVED QTY HAS DECREASED , WSH INTERFACED' , 1 ) ;
               END IF;
                -- Reservation qty cannot be reduced when line is
                -- interfaced to wsh.
                -- Give a message here tell the user we are not unreserving
                -- Added code here to fix bug 2038201.
               FND_MESSAGE.SET_NAME('ONT','OE_SCH_UNRSV_NOT_ALLOWED');
               OE_MSG_PUB.Add;

               goto end_of_processing;


             END IF;

         ELSIF l_changed_reserved_qty < 0 THEN

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  '1 RESERVED QUANTITY HAS INCREASED' , 1 ) ;
           END IF;

           l_qty_to_reserve := l_line_rec.reserved_quantity -
                                  l_old_line_rec.reserved_quantity;

						l_qty2_to_reserve := nvl(l_line_rec.reserved_quantity2, 0) -    -- INVCONV
                                  nvl(l_old_line_rec.reserved_quantity2, 0);

           Action_Schedule(p_x_line_rec     => l_line_rec,
                           p_old_line_rec   => l_old_line_rec,
                           p_action         => OESCH_ACT_SCHEDULE,
                           p_qty_to_reserve => l_qty_to_reserve,
                           p_qty2_to_reserve => l_qty2_to_reserve, -- INVCONV
                           x_return_status  => l_return_status);

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;

          --Added this stmt to fix bug 1800048(2).
          goto end_of_processing;
         END IF; /* end of reserved_quantity change code */


        ELSE
        /* ordered_quantity  < reserved_quantity. If this has happened
        due to ordered_quantity had decreased and reserved_quantity has
        remained the same, then it is a valid change. We will just unreserve
        the difference */

         l_qty_to_unreserve := l_line_rec.reserved_quantity -
                      l_line_rec.ordered_quantity;

         l_qty2_to_unreserve := nvl(l_line_rec.reserved_quantity2, 0) -   --INVCONV
                      nvl(l_line_rec.ordered_quantity2, 0) ;

         IF l_changed_reserved_qty = 0 and
            nvl(l_line_rec.shipping_interfaced_flag, 'N') = 'N' and
            l_qty_to_unreserve > 0 THEN

            -- We dont need to change the record to old.
            Unreserve_Line
              ( p_line_rec               => l_line_rec
              , p_quantity_to_unreserve => l_qty_to_unreserve
              , p_quantity2_to_unreserve => l_qty2_to_unreserve  -- INVCONV
              , x_return_status         => l_return_status);

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
           END IF;

         END IF; /* reserved_quantity same, ordered_quantity changed*/

        END IF; /* Quantity change handling code ends */

        goto end_of_processing;
       END IF /* IF scheduling attributes changed */;


       /* IF ordered_quantity and/or reserved_quantity changed. */

       IF l_old_line_rec.reserved_quantity is null OR
          l_old_line_rec.reserved_quantity = FND_API.G_MISS_NUM THEN
          l_old_line_rec.reserved_quantity := 0;
       END IF;

       IF l_line_rec.reserved_quantity is null OR
          l_line_rec.reserved_quantity = FND_API.G_MISS_NUM THEN
          l_line_rec.reserved_quantity := 0;
       END IF;

       l_changed_ordered_qty    := l_old_line_rec.ordered_quantity -
                      l_line_rec.ordered_quantity;

			IF l_old_line_rec.reserved_quantity2 is null OR -- INVCONV
          l_old_line_rec.reserved_quantity2 = FND_API.G_MISS_NUM THEN
          l_old_line_rec.reserved_quantity2 := 0;
       END IF;

       IF l_line_rec.reserved_quantity2 is null OR
          l_line_rec.reserved_quantity2 = FND_API.G_MISS_NUM THEN
          l_line_rec.reserved_quantity2 := 0;
       END IF;

       l_changed_ordered_qty2    := l_old_line_rec.ordered_quantity2 -
                      l_line_rec.ordered_quantity2;


       IF l_changed_ordered_qty <> 0 THEN

          /* ordered_quantity has changed. Set the flag G_LINE_PART_OF_SET
             if the line belongs to a ship or arrival set */

          IF l_line_rec.ship_set_id is not null OR
             l_line_rec.arrival_set_id is not null THEN
             G_LINE_PART_OF_SET := TRUE;
          END IF;

          IF l_changed_ordered_qty > 0 THEN

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'ORDERED QUANTITY HAS DECREASED' , 1 ) ;
             END IF;

             IF l_line_rec.ordered_quantity = 0 THEN
                -- Since ordered quantity is now 0, undemand
                -- Call MRP with action = UNDEMAND

                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'CALLING MRP WITH THE ACTION OF UNDEMAND' , 1 ) ;
                 END IF;
                 l_line_rec.schedule_action_code := OESCH_ACT_UNDEMAND;
             ELSE
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'CALLING MRP WITH THE ACTION OF REDEMAND' , 1 ) ;
                 END IF;
                 l_line_rec.schedule_action_code := OESCH_ACT_REDEMAND;
             END IF;

          ELSIF l_changed_ordered_qty < 0 THEN

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'ORDERED QUANTITY HAS INCRESED' , 1 ) ;
             END IF;

             -- Assuming that change in quantity will take place only in the
             -- warehouse where the quantity was previously scheduled.
             -- Since ordered quantity is incresed, ATP check and redemand
             -- Call MRP with action = REDEMAND

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'CALLING MRP WITH THE ACTION OF REDEMAND' , 1 ) ;
             END IF;
             l_line_rec.schedule_action_code := OESCH_ACT_REDEMAND;

          END IF;

          l_line_tbl(1)     := l_line_rec;
          l_old_line_tbl(1) := l_old_line_rec;

          Load_MRP_Request
          (  p_line_tbl              => l_line_tbl
           , p_old_line_tbl          => l_old_line_tbl
           , x_atp_table             => l_mrp_atp_rec);

          l_session_id := Get_Session_Id;

          -- Call ATP

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  '1. CALLING MRP API WITH SESSION ID '||L_SESSION_ID , 1 ) ;
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
                                                  oe_debug_pub.add(  '4. AFTER CALLING MRP_ATP_PUB.CALL_ATP' || L_RETURN_STATUS , 1 ) ;
                                              END IF;

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          Load_Results
          (  p_atp_table       => l_out_mtp_atp_rec
           , p_x_line_tbl        => l_line_tbl
           , x_atp_tbl         => l_out_atp_tbl
           , x_return_status   => l_return_status);

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
          END IF;

          l_out_line_rec := l_line_tbl(1);

       END IF; /* If l_changed_ordered_qty <> 0 */

       -- Code to handle reserved quantity

       IF  l_line_rec.ordered_quantity  >=  l_line_rec.reserved_quantity THEN

       -- After the changes are made to the order, the order qty is still
       -- greater than the reserved quantity. This is a valid change.

         l_changed_reserved_qty   := l_old_line_rec.reserved_quantity -
                        l_line_rec.reserved_quantity;

         IF l_changed_reserved_qty > 0 THEN
         -- this definitely is a reserved_quantity decrement
-- CMS is not touching this explicit rsv qty decrease
             IF nvl(l_line_rec.shipping_interfaced_flag, 'N') = 'N' THEN

               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'RESERVED QUANTITY HAS DECREASED' , 1 ) ;
               END IF;


               l_qty_to_unreserve   := l_old_line_rec.reserved_quantity -
                           l_line_rec.reserved_quantity;
							 l_qty2_to_unreserve   := nvl(l_old_line_rec.reserved_quantity2, 0)  -  -- INVCONV
                           nvl(l_line_rec.reserved_quantity2, 0) ;


               -- No need to pass old record. Since this is a change
               -- due to quantity.
               Unreserve_Line
               ( p_line_rec                => l_line_rec
                , p_quantity_to_unreserve => l_qty_to_unreserve
                , p_quantity2_to_unreserve => l_qty2_to_unreserve  -- INVCONV
                , x_return_status         => l_return_status);


               IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               END IF;

             ELSE

               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'RESERVED QTY HAS DECREASED , WSH INTERFACED' , 1 ) ;
               END IF;
                -- Reservation qty cannot be reduced when line is
                -- interfaced to wsh.
                -- Give a message here tell the user we are not unreserving
                -- Added code here to fix bug 2038201.
               FND_MESSAGE.SET_NAME('ONT','OE_SCH_UNRSV_NOT_ALLOWED');
               OE_MSG_PUB.Add;

               goto end_of_processing;


             END IF;

         ELSIF l_changed_reserved_qty < 0 THEN

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'RESERVED QUANTITY HAS INCREASED' , 1 ) ;
           END IF;

           l_qty_to_reserve := l_line_rec.reserved_quantity -
                                  l_old_line_rec.reserved_quantity;

					 l_qty2_to_reserve := nvl(l_line_rec.reserved_quantity2, 0) -   -- INVCONV
                                  nvl(l_old_line_rec.reserved_quantity2, 0);
		   l_out_line_rec := l_line_rec;
           Action_Schedule(p_x_line_rec     => l_out_line_rec,
                           p_old_line_rec   => l_old_line_rec,
                           p_action         => OESCH_ACT_SCHEDULE,
                           p_qty_to_reserve => l_qty_to_reserve,
                           p_qty2_to_reserve => l_qty2_to_reserve, -- INVCONV
                           x_return_status  => l_return_status);

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;

          --Added this stmt to fix bug 1800048(2).
          goto end_of_processing;
         END IF; /* end of reserved_quantity change code */


       ELSE
       /* ordered_quantity  < reserved_quantity. If this has happened
       due to ordered_quantity had decreased and reserved_quantity has
       remained the same, then it is a valid change. We will just unreserve
       the difference */

         l_qty_to_unreserve := l_line_rec.reserved_quantity -
                      l_line_rec.ordered_quantity;
         l_qty2_to_unreserve := nvl(l_line_rec.reserved_quantity2, 0)  -  -- INVCONV
                      nvl(l_line_rec.ordered_quantity2, 0);


         IF l_changed_reserved_qty = 0 and
            nvl(l_line_rec.shipping_interfaced_flag, 'N') = 'N' and
            l_qty_to_unreserve > 0 THEN

            -- We dont need to change the record to old.
            Unreserve_Line
              ( p_line_rec               => l_line_rec
              , p_quantity_to_unreserve => l_qty_to_unreserve
              , p_quantity2_to_unreserve => l_qty2_to_unreserve  -- INVCONV
              , x_return_status         => l_return_status);

           IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
           END IF;

         END IF; /* reserved_quantity same, ordered_quantity changed*/
       goto end_of_processing;

       END IF; /* Quantity change handling code ends */

  END IF;  /* If the schedule_action_code was null */



  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'STARTING THE BIG ELSE LOOP' , 1 ) ;
      oe_debug_pub.add(  'OPR: ' || L_LINE_REC.OPERATION , 1 ) ;
  END IF;

  IF OE_GLOBALS.Equal(l_line_rec.schedule_action_code,
                               OESCH_ACT_UNRESERVE)
  THEN

    -- Setting update flag to false, so that schedule_line does not
    -- process_order as unreserving does not cause any line attributes
    -- to change.

    g_update_flag := FND_API.G_FALSE;
-- CMS is not touching the following explicit unreserve logic

        IF (l_old_line_rec.reserved_quantity is not null AND
            l_old_line_rec.reserved_quantity <> FND_API.G_MISS_NUM)
        THEN
          IF nvl(l_line_rec.shipping_interfaced_flag, 'N') = 'N' THEN

           l_out_line_rec := l_line_rec;
           Action_UnSchedule(p_x_line_rec    => l_out_line_rec,
                          p_old_line_rec  => l_old_line_rec,
                          p_action        => OESCH_ACT_UNRESERVE,
                          x_return_status => l_return_status);

           goto end_of_processing;
          ELSE
           -- Action_Unschedule will only unreserve if not interfaced to WSH
           -- Give a message here tell the user we are not unreserving
           FND_MESSAGE.SET_NAME('ONT','OE_SCH_UNRSV_NOT_ALLOWED');
           OE_MSG_PUB.Add;
           goto end_of_processing;
          END IF;

        ELSE
          FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
          OE_MSG_PUB.Add;
          goto end_of_processing;
        END IF;

  -- schedule_action_code -->  OESCH_ACT_UNDEMAND
  ELSIF OE_GLOBALS.Equal(l_line_rec.schedule_action_code,
                         OESCH_ACT_UNDEMAND)
  THEN
     IF OE_GLOBALS.Equal(l_line_rec.schedule_status_code,
                         OESCH_STATUS_DEMANDED) THEN

		l_out_line_rec := l_line_rec;
        Action_UnSchedule(p_x_line_rec    => l_out_line_rec,
                          p_old_line_rec  => l_old_line_rec,
                          p_action        => OESCH_ACT_UNDEMAND,
                          x_return_status => l_return_status);

        goto end_of_processing;

     ELSE
       FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
       OE_MSG_PUB.Add;
       goto end_of_processing;
     END IF;


  --schedule_action_code --> OESCH_ACT_UNSCHEDULE
  ELSIF OE_GLOBALS.Equal(l_line_rec.schedule_action_code,
                         OESCH_ACT_UNSCHEDULE)
  THEN

     l_out_line_rec := l_line_rec;
     Action_UnSchedule(p_x_line_rec    => l_out_line_rec,
                       p_old_line_rec  => l_old_line_rec,
                       p_action        => OESCH_ACT_UNSCHEDULE,
                       x_return_status => l_return_status);

     goto end_of_processing;


  --l_line_rec.schedule_action_code --> OESCH_ACT_ATP_CHECK
  ELSIF OE_GLOBALS.Equal(l_line_rec.schedule_action_code,
                         OESCH_ACT_ATP_CHECK)
  THEN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ACTION REQUESTED IS OESCH_ACT_ATP_CHECK' , 1 ) ;
     END IF;
     -- Call MRP API

     l_line_tbl(1)     := l_line_rec;
     l_old_line_tbl(1) := l_old_line_rec;

     Load_MRP_Request
      ( p_line_tbl              => l_line_tbl
      , p_old_line_tbl          => l_old_line_tbl
      , x_atp_table             => l_mrp_atp_rec);

     l_session_id := Get_Session_Id;

     -- Call ATP

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  '1. CALLING MRP API WITH SESSION ID '||L_SESSION_ID , 1 ) ;
     END IF;

     MRP_ATP_PUB.Call_ATP
            ( p_session_id              =>  l_session_id
             , p_atp_rec                =>  l_mrp_atp_rec
             , x_atp_rec                =>  l_out_mtp_atp_rec
             , x_atp_supply_demand      =>  l_atp_supply_demand
             , x_atp_period             =>  l_atp_period
             , x_atp_details            =>  l_atp_details
             , x_return_status          =>  l_return_status
             , x_msg_data               =>  mrp_msg_data
             , x_msg_count              =>  l_msg_count);


                                              IF l_debug_level  > 0 THEN
                                                  oe_debug_pub.add(  '5. AFTER CALLING MRP_ATP_PUB.CALL_ATP' || L_RETURN_STATUS , 1 ) ;
                                              END IF;
     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     Load_Results(p_atp_table       => l_out_mtp_atp_rec,
                  p_x_line_tbl      => l_line_tbl,
                  x_atp_tbl         => l_out_atp_tbl,
                  x_return_status   => l_return_status);

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
     END IF;

     l_out_line_rec := l_line_tbl(1);

     -- We also need to pass back on-hand qty and available_to_reserve
     -- qties while performing ATP. Getting these values from inventory.

     FOR K IN 1..l_out_atp_tbl.count LOOP
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING QUERY_QTY_TREE' , 1 ) ;
        END IF;
        Query_Qty_Tree(p_org_id           => l_out_atp_tbl(K).ship_from_org_id,
                       p_item_id          => l_out_atp_tbl(K).inventory_item_id,
                       p_line_id          => l_out_atp_tbl(K).line_id,
                       p_sch_date         =>
                              nvl(l_out_atp_tbl(K).group_available_date,
                                  l_out_atp_tbl(K).ordered_qty_Available_Date),
                       x_on_hand_qty      => l_on_hand_qty,
											 x_avail_to_reserve => l_avail_to_reserve,
                       x_on_hand_qty2      => l_on_hand_qty2, -- INVCONV
                       x_avail_to_reserve2 => l_avail_to_reserve2 -- INVCONV
                       );

/*        --  added by fabdi 03/May/2001 INVCONV - NOT NEEDED NOW
        IF NOT INV_GMI_RSV_BRANCH.Process_Branch(p_organization_id => l_out_atp_tbl(K).ship_from_org_id)
        THEN
		l_process_flag := FND_API.G_FALSE;
        ELSE
		l_process_flag := FND_API.G_TRUE;
        END IF;

        IF l_process_flag = FND_API.G_TRUE
        THEN
        	l_out_atp_tbl(K).on_hand_qty          := l_on_hand_qty;
        	l_out_atp_tbl(K).available_to_reserve := l_avail_to_reserve;
                l_out_atp_tbl(K).QTY_ON_REQUEST_DATE := l_avail_to_reserve; -- Available field in ATP

                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'L_ON_HAND_QTY' || L_ON_HAND_QTY ) ;
                    oe_debug_pub.add(  'L_AVAIL_TO_RESERVE' || L_AVAIL_TO_RESERVE ) ;
                    oe_debug_pub.add(  'AVAILABLE ' || L_AVAIL_TO_RESERVE ) ;
                END IF;
        else   */

        	l_out_atp_tbl(K).on_hand_qty          := l_on_hand_qty;
        	-- l_out_atp_tbl(K).on_hand_qty2          :=l_on_hand_qty2;  -- INVCONV PAL
        	l_out_atp_tbl(K).available_to_reserve := l_avail_to_reserve;
        	-- l_out_atp_tbl(K).available_to_reserve2 := l_avail_to_reserve2; -- INVCONV == PAL
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'L_ON_HAND_QTY' || L_ON_HAND_QTY ) ;
                    oe_debug_pub.add(  'L_AVAIL_TO_RESERVE' || L_AVAIL_TO_RESERVE ) ;
                    --oe_debug_pub.add(  'L_ON_HAND_QTY2' || L_ON_HAND_QTY2 ) ; -- INVCONV
                   -- oe_debug_pub.add(  'L_AVAIL_TO_RESERVE2' || L_AVAIL_TO_RESERVE2 ) ;
                END IF;
       --  end if;     -- INVCONV
        -- end fabdi

     END LOOP;


  --l_line_rec.schedule_action_code --> OESCH_ACT_SOURC
  ELSIF OE_GLOBALS.Equal(l_line_rec.schedule_action_code,
                         OESCH_ACT_SOURCE)
  THEN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ACTION REQUESTED IS OESCH_ACT_SOURCE' , 1 ) ;
     END IF;
     IF (l_line_rec.ship_from_org_id IS NULL)
     THEN
        -- Call MRP API to get the source for the line

        -- Since we do not have MRP API currently, the following
        -- line is a kludge to get the ship_from_org_id

        l_out_line_rec.ship_from_org_id :=
            OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
        END IF;
     ELSE
       null;
       goto end_of_processing;
     END IF;


  --l_line_rec.schedule_action_code --> OESCH_ACT_SCHEDULE
/*  ELSIF OE_GLOBALS.Equal(l_line_rec.schedule_action_code,
                         OESCH_ACT_SCHEDULE)
  THEN
     OE_DEBUG_PUB.ADD('Action Requested is OESCH_ACT_SCHEDULE',1);

     l_out_line_rec := l_line_rec;
     Action_Schedule(p_x_line_rec    => l_out_line_rec,
                     p_old_line_rec  => l_old_line_rec,
                     p_action        => OESCH_ACT_SCHEDULE,
                     x_return_status => l_return_status);

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;
*/
  ELSIF OE_GLOBALS.Equal(l_line_rec.schedule_action_code,
                         OESCH_ACT_SCHEDULE)
  THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ACTION REQUESTED IS OESCH_ACT_SCHEDULE' , 1 ) ;
     END IF;

     -- We will check to see if the status is not null. If the status
     -- is not null, it means that the line is either demanded or reserved.
     -- In this case, we will not need to perform the action of DEMAND.

      --Commenting this code not to display the message when
      --scheduled inclued lines being re-scheduled through schedule_parent-line.
     IF (l_line_rec.schedule_status_code IS NOT NULL) THEN
/*         FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
         OE_MSG_PUB.Add;*/
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  ' SCHEDULED LINE , GOTO END OF PROCESSING' , 3 ) ;
         END IF;
         goto end_of_processing;
     END IF;

     -- The line is not scheduled, so go ahead and schedule the line

     l_out_line_rec := l_line_rec;
     Action_Schedule(p_x_line_rec    => l_out_line_rec,
                     p_old_line_rec  => l_old_line_rec,
                     p_action        => OESCH_ACT_SCHEDULE,
                     x_return_status => l_return_status);

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;



  --l_line_rec.schedule_action_code --> OESCH_ACT_RESERVE
  ELSIF OE_GLOBALS.Equal(l_line_rec.schedule_action_code,
                         OESCH_ACT_RESERVE)
  THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ACTION IS RESERVE' , 1 ) ;
     END IF;

     IF OE_GLOBALS.Equal(l_line_rec.ordered_quantity,
                         l_line_rec.reserved_quantity) THEN
         FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_ACTION_DONE_NO_EXP');
         OE_MSG_PUB.Add;
         goto end_of_processing;

     END IF;

     l_out_line_rec := l_line_rec;
     Action_Schedule(p_x_line_rec    => l_out_line_rec,
                     p_old_line_rec  => l_old_line_rec,
                     p_action        => OESCH_ACT_RESERVE,
                     x_return_status => l_return_status);

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
     END IF;

  -- autoschedule flag is Y
  ELSIF (OESCH_AUTO_SCH_FLAG = 'Y') AND
         l_line_rec.operation = OE_GLOBALS.G_OPR_CREATE
  THEN
     -- We are taking care of autoscheduling only if scheduling_action
     -- code is null. If the action code has a value, we will perform
     -- that action instead of autoscheduling. Thus this check is done
     -- after all other checks are taken care of.

     -- If the line quantity is 0 (the line maybe cancelled or the
     -- quantity was assigned zero) , then we do not need to perform
     -- any scheduling action.

     IF (l_line_rec.ordered_quantity = 0) THEN
          -- Assigning l_out_line_rec the same values as that
          -- l_line_rec.

          l_out_line_rec := l_line_rec;
          goto end_of_processing;

     END IF;

     IF (l_line_rec.item_type_code <> OE_GLOBALS.G_ITEM_STANDARD) THEN
          -- Assigning l_out_line_rec the same values as that
          -- l_line_rec.

          l_out_line_rec := l_line_rec;
          goto end_of_processing;

     END IF;

     -- Check to see the scheduling level for this order line.
     -- If the scheduling_level does not allow performing any scheduling
     -- then do not perform scheduling.

     IF (sch_cached_sch_level_code = SCH_LEVEL_ONE) THEN
          l_out_line_rec := l_line_rec;
          goto end_of_processing;
     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PERFORMING ACTION SCHEDULE' , 1 ) ;
     END IF;

     l_line_rec.schedule_action_code := OESCH_ACT_SCHEDULE;

     l_out_line_rec := l_line_rec;
     Action_Schedule(p_x_line_rec    => l_out_line_rec,
                     p_old_line_rec  => l_old_line_rec,
                     p_action        => OESCH_ACT_SCHEDULE,
                     x_return_status => l_return_status);

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTER ACTION SCHEDULE : ' || L_RETURN_STATUS , 1 ) ;
     END IF;

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          -- We donot want to error out the insert if autoscheduling
          -- failed. So we will return success.
          -- We also do not want to do any update, so we will set
          -- the g_update_flag to FALSE.
          g_update_flag     := FND_API.G_FALSE;
          l_return_status   := FND_API.G_RET_STS_SUCCESS;
     END IF;

  END IF;


  <<end_of_processing>>
  x_return_status := l_return_status;
  p_x_line_rec  := l_out_line_rec;
  x_out_atp_tbl   := l_out_atp_tbl;
                                                 IF l_debug_level  > 0 THEN
                                                     oe_debug_pub.add(  'EXITING OE_ORDER_SCH_UTIL.PROCESS_REQUEST: ' || X_RETURN_STATUS , 1 ) ;
                                                 END IF;

END Process_request;

/*-----------------------------------------------------------------------------
Procedure Name : Initialize_mrp_record
Description    : This procedure create l_count records each for each table
                 in the record of tables of MRP's p_atp_rec.
----------------------------------------------------------------------------- */
Procedure Initialize_mrp_record(p_atp_rec IN  MRP_ATP_PUB.ATP_Rec_Typ,
                                l_count   IN  NUMBER,
                                x_atp_rec OUT NOCOPY /* file.sql.39 change */ MRP_ATP_PUB.ATP_Rec_Typ)
IS
l_atp_rec MRP_ATP_PUB.ATP_Rec_Typ;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXTENDING THE TABLE BY ' || L_COUNT , 5 ) ;
   END IF;
   l_atp_rec := p_atp_rec;
   l_atp_rec.Inventory_Item_Id.extend(l_count);
   l_atp_rec.Source_Organization_Id.extend(l_count);
   l_atp_rec.Identifier.extend(l_count);
   l_atp_rec.Order_Number.extend(l_count);
   l_atp_rec.Calling_Module.extend(l_count);
   l_atp_rec.Customer_Id.extend(l_count);
   l_atp_rec.Customer_Site_Id.extend(l_count);
   l_atp_rec.Destination_Time_Zone.extend(l_count);
   l_atp_rec.Quantity_Ordered.extend(l_count);
   l_atp_rec.Quantity_UOM.extend(l_count);
   l_atp_rec.Requested_Ship_Date.extend(l_count);
   l_atp_rec.Requested_Arrival_Date.extend(l_count);
   l_atp_rec.Earliest_Acceptable_Date.extend(l_count);
   l_atp_rec.Latest_Acceptable_Date.extend(l_count);
   l_atp_rec.Delivery_Lead_Time.extend(l_count);
   l_atp_rec.Atp_Lead_Time.extend(l_count);
   l_atp_rec.Freight_Carrier.extend(l_count);
   l_atp_rec.Ship_Method.extend(l_count);
   l_atp_rec.Demand_Class.extend(l_count);
   l_atp_rec.Ship_Set_Name.extend(l_count);
   l_atp_rec.Arrival_Set_Name.extend(l_count);
   l_atp_rec.Override_Flag.extend(l_count);
   l_atp_rec.Action.extend(l_count);
   l_atp_rec.ship_date.extend(l_count);
   l_atp_rec.Available_Quantity.extend(l_count);
   l_atp_rec.Requested_Date_Quantity.extend(l_count);
   l_atp_rec.Group_Ship_Date.extend(l_count);
   l_atp_rec.Group_Arrival_Date.extend(l_count);
   l_atp_rec.Vendor_Id.extend(l_count);
   l_atp_rec.Vendor_Site_Id.extend(l_count);
   l_atp_rec.Insert_Flag.extend(l_count);
   l_atp_rec.Error_Code.extend(l_count);
   l_atp_rec.Message.extend(l_count);
   l_atp_rec.Old_Source_Organization_Id.extend(l_count);
   l_atp_rec.Old_Demand_Class.extend(l_count);
   l_atp_rec.oe_flag.extend(l_count);
   -- Added below attributes to fix bug 1912138.
   l_atp_rec.ato_delete_flag.extend(l_count);
   l_atp_rec.attribute_05.extend(l_count);
   l_atp_rec.attribute_01.extend(l_count);
   l_atp_rec.vendor_name.extend(l_count);
   x_atp_rec := l_atp_rec;
END;

/*-----------------------------------------------------------------------------
Procedure Name : Get_Lead_Time
Description    : This function returns the manufacturing lead team for ATO
                 Options and Classes. While performing ATP, and scheduling
                 for an ATO configuration, we just don't have to check
                 the availability of the items, we also need to find out
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
      oe_debug_pub.add(  'ATO LINE IS ' || P_ATO_LINE_ID , 1 ) ;
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
RETURN number
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

/*-----------------------------------------------------------------------------
Procedure Name : Load_Request
Description    : This procedure loads the MRP record or tables to be passed
                 to MRP's API from the OM's table of records of order lines.
                 If line line to be passed to MRP is an ATO model, we call
                 CTO's GET_MANDATORY_COMPONENTS API to get the mandatory
                 components, and we pass them along with the ATO model
                 to MRP.
----------------------------------------------------------------------------- */
Procedure Load_MRP_Request
( p_line_tbl              IN  Oe_Order_Pub.Line_Tbl_Type
, p_old_line_tbl          IN  Oe_Order_Pub.Line_Tbl_Type
, x_atp_table             OUT NOCOPY /* file.sql.39 change */ MRP_ATP_PUB.ATP_Rec_Typ)
IS
I                   number := 1;
l_atp_rec           MRP_ATP_PUB.ATP_Rec_Typ;
l_smc_rec           MRP_ATP_PUB.ATP_Rec_Typ;
l_line_rec          Oe_Order_Pub.Line_Rec_Type;
l_old_line_rec      Oe_Order_Pub.Line_Rec_Type;

l_type_code         VARCHAR2(30);
l_st_atp_lead_time  NUMBER;
l_st_ato_line_id    NUMBER;

l_message_name      VARCHAR2(30);
l_error_message     VARCHAR2(2000);
l_table_name        VARCHAR2(30);
l_model_rec         MRP_ATP_PUB.ATP_Rec_Typ;
l_smc_recs          MRP_ATP_PUB.ATP_Rec_Typ;
l_ship_set          VARCHAR2(30);
l_arrival_set       VARCHAR2(30);

l_cto_result        NUMBER;
l_order_number      NUMBER;

lTableName          VARCHAR2(30);
lMessageName        VARCHAR2(30);
lErrorMessage       VARCHAR2(2000);

l_result            NUMBER := 1;
l_oe_flag           VARCHAR2(1);

l_mrp_calc_sd	    VARCHAR2(240);
l_insert_flag       NUMBER;

l_organization_id   NUMBER;
l_inventory_item_id NUMBER;

l_inv_ctp	    VARCHAR2(240);
l_explode           BOOLEAN;
l_action            NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  '....ENTERING OE_ORDER_SCH_UTIL.LOAD_MRP_REQUEST' , 1 ) ;
       oe_debug_pub.add(  'COUNT IS ' || P_LINE_TBL.COUNT , 1 ) ;
       oe_debug_pub.add(  '------------------LOAD MRP TABLE---------------' , 1 ) ;
   END IF;


   l_mrp_calc_sd :=  fnd_profile.value('MRP_ATP_CALC_SD');

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'MRP_ATP_CALC_SD : '||L_MRP_CALC_SD , 3 ) ;
   END IF;

   IF nvl(l_mrp_calc_sd,'N') = 'Y' THEN
      l_insert_flag   := 1;
   ELSE
      l_insert_flag   := 0;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INSERT FLAG : '||L_INSERT_FLAG , 3 ) ;
   END IF;

   IF (p_line_tbl.count >= 1) THEN

      I := 0;

      FOR cnt IN 1..p_line_tbl.count LOOP

        l_line_rec     := p_line_tbl(cnt);
        l_old_line_rec := p_old_line_tbl(cnt);

        IF cnt = 1 THEN
           -- This is the first line.
           -- We will get the order date type and order number

           l_type_code    := Get_Date_Type(l_line_rec.header_id);
           l_order_number := Get_Order_Number(l_line_rec.header_id);

        END IF;

        IF l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG THEN

           -- The config item might be a part of the table since query
           -- of a group of lines returns back the config item too. But
           -- we should not pass this item to MRP. Thus we will bypass this
           -- record out here.

           goto end_loop;
        END IF;

        I := I + 1;

        Initialize_mrp_record(p_atp_rec => l_atp_rec,
                              l_count   => 1,
                              x_atp_rec => l_atp_rec);

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  '--**-- ' , 3 ) ;
        END IF;
        l_atp_rec.atp_lead_time(I)   := 0;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LINE ID : ' || L_LINE_REC.LINE_ID , 3 ) ;
            oe_debug_pub.add(  'SCHEDULE ACTION : ' || L_LINE_REC.SCHEDULE_ACTION_CODE , 3 ) ;
           END IF;

        -- Set the non database files ship_set and arrival_set to null
        -- in case they are missing.

        IF l_line_rec.ship_set = FND_API.G_MISS_CHAR THEN
            l_line_rec.ship_set := null;
        END IF;

        IF l_line_rec.arrival_set = FND_API.G_MISS_CHAR THEN
            l_line_rec.arrival_set := null;
        END IF;

        IF l_line_rec.arrival_set_id is null THEN
           l_arrival_set := l_line_rec.arrival_set;
        ELSE
           l_arrival_set := nvl(l_line_rec.arrival_set,to_char(l_line_rec.arrival_set_id));
        END IF;

        IF l_line_rec.ship_set_id is null THEN
           l_ship_set := l_line_rec.ship_set;
        ELSE
           l_ship_set := nvl(l_line_rec.ship_set,to_char(l_line_rec.ship_set_id));
        END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SHIP_SET : ' || L_SHIP_SET , 3 ) ;
            oe_debug_pub.add(  'ARRIVAL SET : ' || L_ARRIVAL_SET , 3 ) ;
        END IF;

        l_atp_rec.Inventory_Item_Id(I)         := l_line_rec.inventory_item_id;

        IF (l_line_rec.ship_from_org_id = FND_API.G_MISS_NUM) THEN
            l_line_rec.ship_from_org_id := null;
        END IF;
        IF (l_old_line_rec.ship_from_org_id = FND_API.G_MISS_NUM) THEN
            l_old_line_rec.ship_from_org_id := null;
        END IF;

/*
        IF NOT OE_GLOBALS.Equal(l_line_rec.ship_from_org_id,
                                l_old_line_rec.ship_from_org_id) OR
               (l_line_rec.re_source_flag = 'N')
*/
        IF (l_line_rec.ship_from_org_id IS NOT NULL)
        THEN
            l_atp_rec.Source_Organization_Id(I)
                           := l_line_rec.ship_from_org_id;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SHIP FROM : ' || L_LINE_REC.SHIP_FROM_ORG_ID , 3 ) ;
            END IF;
        ELSE
            l_atp_rec.Source_Organization_Id(I) := null;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SHIP FROM IS NULL ' , 3 ) ;
            END IF;
        END IF;
        l_atp_rec.Identifier(I)                := l_line_rec.line_id;
        l_atp_rec.Order_Number(I)              := l_order_number;
        l_atp_rec.Calling_Module(I)            := 660;
        l_atp_rec.Customer_Id(I)               := l_line_rec.sold_to_org_id;
        l_atp_rec.Customer_Site_Id(I)          := l_line_rec.ship_to_org_id;
--      l_atp_rec.Destination_Time_Zone(I)     := null;
        l_atp_rec.Destination_Time_Zone(I)     := l_line_rec.item_type_code;
        l_atp_rec.Quantity_Ordered(I)          := l_line_rec.ordered_quantity;
        l_atp_rec.Quantity_UOM(I)              := l_line_rec.order_quantity_uom;
        l_atp_rec.Earliest_Acceptable_Date(I)  := null;

        -- For ATP check atp requested should be line_rec.request_date.
        -- Adding code to fix bug 2136818.

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'A1 : ' || L_LINE_REC.ARRIVAL_SET_ID , 1 ) ;
            oe_debug_pub.add(  'A2 : ' || L_OLD_LINE_REC.ARRIVAL_SET_ID , 1 ) ;
        END IF;

        IF NOT OE_GLOBALS.Equal(l_line_rec.arrival_set_id,
                                l_old_line_rec.arrival_set_id)
           OR (G_LINE_PART_OF_SET = TRUE AND
               l_line_rec.arrival_set_id is not null)
        THEN

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'T1' , 1 ) ;
           END IF;
           IF l_line_rec.schedule_action_code = OESCH_ACT_ATP_CHECK THEN
              l_atp_rec.Requested_Arrival_Date(I) :=
                                       l_line_rec.request_date;
           ELSE

              l_atp_rec.Requested_Arrival_Date(I) :=
                                       l_line_rec.schedule_arrival_date;
           END IF;

           l_atp_rec.Requested_Ship_Date(I)    := null;

        ELSIF NOT OE_GLOBALS.Equal(l_line_rec.ship_set_id,
                                   l_old_line_rec.ship_set_id)
           OR (G_LINE_PART_OF_SET = TRUE AND
               l_line_rec.ship_set_id is not null)
        THEN

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'T2' , 1 ) ;
           END IF;
           IF l_line_rec.schedule_action_code = OESCH_ACT_ATP_CHECK THEN
              l_atp_rec.Requested_Ship_Date(I)    :=
                                       l_line_rec.request_date;
           ELSE
              l_atp_rec.Requested_Ship_Date(I)    :=
                                       l_line_rec.schedule_ship_date;
           END IF;
           l_atp_rec.Requested_Arrival_Date(I) := null;

        ELSIF (l_type_code = 'ARRIVAL')
        THEN

		-- If user changes schedule_arrival_date then schedule based
		-- on the arrival_date. Otherwise look for the change in request date.
		-- If user changed request date, schedule based on the request
		-- date. Otherwise if the scheduling is happening because of
		-- some other changes, use nvl on arrival_date and request_dates.

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'T3' , 1 ) ;
         END IF;
         IF l_line_rec.schedule_action_code = OESCH_ACT_ATP_CHECK THEN
             l_atp_rec.Requested_Arrival_Date(I) :=
                                       l_line_rec.request_date;
         ELSE
           IF NOT OE_GLOBALS.Equal(l_line_rec.schedule_arrival_date,
                                   l_old_line_rec.schedule_arrival_date) AND
              l_line_rec.schedule_arrival_date IS NOT NULL AND
              l_line_rec.schedule_arrival_date <> FND_API.G_MISS_DATE
           THEN

		    l_atp_rec.Requested_Arrival_Date(I) :=
					    l_line_rec.schedule_arrival_date;

           ELSIF NOT OE_GLOBALS.Equal(l_line_rec.request_date,
                                   l_old_line_rec.request_date) AND
              l_line_rec.request_date IS NOT NULL AND
              l_line_rec.request_date <> FND_API.G_MISS_DATE
           THEN

              l_atp_rec.Requested_Arrival_Date(I) :=
                                   l_line_rec.request_date;

		   ELSE

              l_atp_rec.Requested_Arrival_Date(I) :=
		      nvl(l_line_rec.schedule_arrival_date,l_line_rec.request_date);

           END IF;
         END IF; -- ATP CHECK.
         l_atp_rec.Requested_Ship_Date(I)    := null;
                                   IF l_debug_level  > 0 THEN
                                       oe_debug_pub.add(  'REQ ARR DATE : ' || L_ATP_REC.REQUESTED_ARRIVAL_DATE ( I ) , 3 ) ;
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
         IF l_line_rec.schedule_action_code = OESCH_ACT_ATP_CHECK THEN
            l_atp_rec.Requested_Ship_Date(I) :=
                                      l_line_rec.request_date;
         ELSE

           IF NOT OE_GLOBALS.Equal(l_line_rec.schedule_ship_date,
                                   l_old_line_rec.schedule_ship_date) AND
              l_line_rec.schedule_ship_date IS NOT NULL AND
              l_line_rec.schedule_ship_date <> FND_API.G_MISS_DATE
           THEN

              l_atp_rec.Requested_Ship_Date(I) :=
                        l_line_rec.schedule_ship_date;

           ELSIF NOT OE_GLOBALS.Equal(l_line_rec.request_date,
                                   l_old_line_rec.request_date) AND
              l_line_rec.request_date IS NOT NULL AND
              l_line_rec.request_date <> FND_API.G_MISS_DATE
           THEN

              l_atp_rec.Requested_Ship_Date(I) :=
                        l_line_rec.request_date;

		   ELSE

              l_atp_rec.Requested_Ship_Date(I)    :=
		     nvl(l_line_rec.schedule_ship_date,l_line_rec.request_date);

           END IF;

         END IF; -- ATP CHECK.

         l_atp_rec.Requested_Arrival_Date(I)  := null;
                                     IF l_debug_level  > 0 THEN
                                         oe_debug_pub.add(  'REQ SHIP DATE : ' || L_ATP_REC.REQUESTED_SHIP_DATE ( I ) , 3 ) ;
                                     END IF;

        END IF;

                             IF l_debug_level  > 0 THEN
                                 oe_debug_pub.add(  'REQUEST SHIP DATE : ' || TO_CHAR ( L_ATP_REC.REQUESTED_SHIP_DATE ( I ) , 'DD-MON-RR:HH:MM:SS' ) , 3 ) ;
                                 oe_debug_pub.add(  'REQUEST ARRIVAL DATE : ' || TO_CHAR ( L_ATP_REC.REQUESTED_ARRIVAL_DATE ( I ) , 'DD-MON-RR:HH:MM:SS' ) , 3 ) ;
                             END IF;


        IF OESCH_PERFORM_GRP_SCHEDULING = 'Y'
        THEN
           l_atp_rec.Latest_Acceptable_Date(I)  :=
                                        l_line_rec.latest_acceptable_date;
        END IF;

        IF G_LINE_PART_OF_SET = TRUE
        THEN

           -- If the line is part of a set and we are rescheduling it
           -- just by itself, we should not let MRP change the date.
           -- Thus we will pass null Latest_Acceptable_Date

           l_atp_rec.Latest_Acceptable_Date(I)  := null;
        END IF;

        -- Clearing delivery lead time to fix bug 2111591.
        l_atp_rec.Delivery_Lead_Time(I)     := Null;
        --l_atp_rec.Delivery_Lead_Time(I)     := l_line_rec.delivery_lead_time;
   	    IF l_debug_level  > 0 THEN
   	        oe_debug_pub.add(  'DELIVERY : '||L_ATP_REC.DELIVERY_LEAD_TIME ( I ) , 3 ) ;
   	    END IF;
        l_atp_rec.Freight_Carrier(I)        := null;
        l_atp_rec.Ship_Method(I)            := l_line_rec.shipping_method_code;
        l_atp_rec.Demand_Class(I)           := l_line_rec.demand_class_code;
        l_atp_rec.Ship_Set_Name(I)          := l_ship_set;
        l_atp_rec.Arrival_Set_Name(I)       := l_arrival_set;
        IF G_OVERRIDE_FLAG = 'Y' THEN
             l_atp_rec.Override_Flag(I)     := 'Y';
        ELSE
             l_atp_rec.Override_Flag(I)     := null;
        END IF;
        l_atp_rec.Ship_Date(I)              := null;
        l_atp_rec.Available_Quantity(I)     := null;
        l_atp_rec.Requested_Date_Quantity(I) := null;
        l_atp_rec.Group_Ship_Date(I)        := null;
        l_atp_rec.Group_Arrival_Date(I)     := null;
        l_atp_rec.Vendor_Id(I)              := null;
        l_atp_rec.Vendor_Site_Id(I)         := null;
        l_atp_rec.Insert_Flag(I)            := l_insert_flag;
   	   IF l_debug_level  > 0 THEN
   	       oe_debug_pub.add(  'INSERT FLAG IN ATP_REC : '||L_ATP_REC.INSERT_FLAG ( I ) , 3 ) ;
   	       oe_debug_pub.add(  'ATO LINE ID : '||L_LINE_REC.ATO_LINE_ID , 3 ) ;
   	       oe_debug_pub.add(  'ITEM TYPE : '||L_LINE_REC.ITEM_TYPE_CODE , 3 ) ;
   	   END IF;
        l_atp_rec.Error_Code(I)             := null;

		/* Changes for Internal Orders */

        IF l_line_rec.source_document_type_id = 10 THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'IT IS AN INTERNAL ORDER ' , 3 ) ;
           END IF;
           l_oe_flag := 'Y';

		   IF (l_line_rec.schedule_ship_date IS NOT NULL AND
              l_line_rec.schedule_ship_date <> FND_API.G_MISS_DATE ) OR
			  (l_line_rec.schedule_arrival_date IS NOT NULL AND
              l_line_rec.schedule_arrival_date <> FND_API.G_MISS_DATE ) THEN

			  IF l_debug_level  > 0 THEN
			      oe_debug_pub.add(  'NO CHANGES TO DATE AS IT HAS BEEN PASSED' , 3 ) ;
			  END IF;
		   ELSE
			  IF l_debug_level  > 0 THEN
			      oe_debug_pub.add(  'PASS THE REQUEST DATE AS ARRIVAL DATE' , 3 ) ;
			  END IF;

			  l_atp_rec.Requested_ship_Date(I)  := null;
			  l_atp_rec.Requested_arrival_Date(I) := l_line_rec.request_date;

		   END IF;

		   l_atp_rec.attribute_01(I) := l_line_rec.source_document_id;

        ELSE
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'IT IS NOT AN INTERNAL ORDER ' , 3 ) ;
           END IF;
           l_oe_flag := 'N';
        END IF;

        l_atp_rec.oe_flag(I) := l_oe_flag;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OE FLAG/SOURCE DOC IS : '||L_ATP_REC.OE_FLAG ( I ) ||'/'||L_ATP_REC.ATTRIBUTE_01 ( I ) , 3 ) ;
        END IF;

        l_atp_rec.Message(I)                := null;

        IF (l_line_rec.schedule_action_code =
            OE_ORDER_SCH_UTIL.OESCH_ACT_ATP_CHECK)
        THEN
            l_atp_rec.Action(I)                    := 100;
        ELSIF (l_line_rec.schedule_action_code =
               OE_ORDER_SCH_UTIL.OESCH_ACT_DEMAND) OR
              (l_line_rec.schedule_action_code =
               OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE)
        THEN
            l_atp_rec.Action(I)                    := 110;
        ELSIF (l_line_rec.schedule_action_code =
               OE_ORDER_SCH_UTIL.OESCH_ACT_REDEMAND) OR
              (l_line_rec.schedule_action_code =
               OE_ORDER_SCH_UTIL.OESCH_ACT_RESCHEDULE)
        THEN
            l_atp_rec.Action(I)                     := 120;
            l_atp_rec.Old_Source_Organization_Id(I) :=
                               l_old_line_rec.ship_from_org_id;
            l_atp_rec.Old_Demand_Class(I)           :=
                               l_old_line_rec.demand_class_code;
        ELSIF (l_line_rec.schedule_action_code =
               OE_ORDER_SCH_UTIL.OESCH_ACT_UNDEMAND)
        THEN
         l_atp_rec.Action(I)                    := 120;
         l_atp_rec.Quantity_Ordered(I)          := 0;
         l_atp_rec.Old_Source_Organization_Id(I) :=
                               l_old_line_rec.ship_from_org_id;
         l_atp_rec.Old_Demand_Class(I)           :=
                               l_old_line_rec.demand_class_code;

         /*L.G. OPM bug 1828340 jul 19,01*/
	 IF ( INV_GMI_RSV_BRANCH.Process_Branch(p_organization_id => l_old_line_rec.ship_from_org_id) ) THEN
           Update oe_order_lines_all
           Set ordered_quantity = 0,
               ordered_quantity2 = 0
           Where line_id=l_old_line_rec.line_id;
         END IF;
        END IF;

        -- storing in local var to assing action to ato mandatory components
        -- to fix bug 1947539.

        l_action := l_atp_rec.Action(I);
        l_atp_rec.atp_lead_time(I)   := 0;

        IF l_line_rec.ato_line_id is not null AND
           l_line_rec.line_id <> l_line_rec.ato_line_id
        THEN

            -- This lines is a ato option or class.
            -- Set the atp_lead_time for it.

            IF l_line_rec.ato_line_id = l_st_ato_line_id
            THEN
              l_atp_rec.atp_lead_time(I)   := l_st_atp_lead_time;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'ATO LEAD TIME IS ' || L_ST_ATP_LEAD_TIME , 3 ) ;
              END IF;
            ELSE
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'CALLING GET_LEAD_TIME' , 3 ) ;
              END IF;
              l_st_atp_lead_time :=
                    Get_Lead_Time
                         (p_ato_line_id      => l_line_rec.ato_line_id,
                          p_ship_from_org_id => l_line_rec.ship_from_org_id);

              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'AFTER CALLING GET_LEAD_TIME' , 3 ) ;
                  oe_debug_pub.add(  'LEAD TIME: ' || L_ST_ATP_LEAD_TIME , 3 ) ;
              END IF;

            l_atp_rec.atp_lead_time(I)   := l_st_atp_lead_time;
            l_st_ato_line_id := l_line_rec.ato_line_id;
            END IF;
        END IF;

        l_inv_ctp :=  fnd_profile.value('INV_CTP');

        l_explode := TRUE;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INV_CTP : '||L_INV_CTP , 3 ) ;
        END IF;

        IF l_line_rec.ato_line_id = l_line_rec.line_id AND
           (l_line_rec.item_type_code in ('MODEL','CLASS') OR
           (l_line_rec.item_type_code in ('STANDARD','OPTION') AND
            l_inv_ctp = '5'))
        THEN

          -- Added this code to fix bug 1998613.
          IF l_line_rec.schedule_status_code is not null
          AND nvl(l_line_rec.ordered_quantity,0) <
                  l_old_line_rec.ordered_quantity
          AND l_old_line_rec.reserved_quantity > 0
          AND NOT Schedule_Attribute_Changed(p_line_rec     => l_line_rec,
                                             p_old_line_rec => l_old_line_rec)
          AND OE_GLOBALS.Equal(l_line_rec.sold_to_org_id,
                               l_old_line_rec.sold_to_org_id)
          THEN

             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'ONLY ORDERED QTY GOT REDUCED , NO EXPLOSION' , 3 ) ;
             END IF;
             l_explode := FALSE;

          END IF;

          IF l_explode THEN

          -- If the line scheduled is an ATO Model, call ATO's API
          -- to get the Standard Mandatory Components

	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'ATO ITEM TYPE : '||L_LINE_REC.ITEM_TYPE_CODE , 3 ) ;
	     END IF;

             IF  l_line_rec.item_type_code = 'STANDARD' AND
		         l_atp_rec.ship_set_name(I) is NULL THEN

                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'ASSIGNING SHIP SET FOR ATO ITEM ' , 3 ) ;
                 END IF;
                 l_atp_rec.Ship_Set_Name(I)          := l_line_rec.ato_line_id;

             END IF;

		   IF l_line_rec.item_type_code = 'STANDARD' THEN

              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'ASSIGNING WAREHOUSE AND ITEM ' , 3 ) ;
              END IF;
		    l_organization_id := l_line_rec.ship_from_org_id;
		    l_inventory_item_id := l_line_rec.inventory_item_id;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'WAREHOUSE/ITEM : '||L_ORGANIZATION_ID||'/'||L_INVENTORY_ITEM_ID , 3 ) ;
              END IF;

		   ELSE

		    l_organization_id := NULL;
		    l_inventory_item_id := NULL;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'WAREHOUSE/ITEM : '||L_ORGANIZATION_ID||'/'||L_INVENTORY_ITEM_ID , 3 ) ;
              END IF;

		   END IF;

          --Load Model Rec to pass to ATO's API
          --Load Model Rec to pass to ATO's API

          l_model_rec.Inventory_Item_Id := MRP_ATP_PUB.number_arr
                            (l_atp_rec.Inventory_Item_Id(I));

          l_model_rec.Source_Organization_Id := MRP_ATP_PUB.number_arr
                            (l_atp_rec.Source_Organization_Id(I));

          l_model_rec.Identifier := MRP_ATP_PUB.number_arr
                            (l_atp_rec.Identifier(I));

          l_model_rec.Calling_Module := MRP_ATP_PUB.number_arr
                            (l_atp_rec.Calling_Module(I));

          l_model_rec.Customer_Id := MRP_ATP_PUB.number_arr
                            (l_atp_rec.Customer_Id(I));

          l_model_rec.Customer_Site_Id := MRP_ATP_PUB.number_arr
                            (l_atp_rec.Customer_Site_Id(I));

          l_model_rec.Destination_Time_Zone := MRP_ATP_PUB.char30_arr
                            (l_atp_rec.Destination_Time_Zone(I));

          l_model_rec.Quantity_Ordered := MRP_ATP_PUB.number_arr
                            (l_atp_rec.Quantity_Ordered(I));

          l_model_rec.Quantity_UOM := MRP_ATP_PUB.char3_arr
                            (l_atp_rec.Quantity_UOM(I));

          l_model_rec.Earliest_Acceptable_Date := MRP_ATP_PUB.date_arr
                            (l_atp_rec.Earliest_Acceptable_Date(I));

          l_model_rec.Requested_Ship_Date := MRP_ATP_PUB.date_arr
                            (l_atp_rec.Requested_Ship_Date(I));

          l_model_rec.Requested_Arrival_Date := MRP_ATP_PUB.date_arr
                            (l_atp_rec.Requested_Arrival_Date(I));

          l_model_rec.Latest_Acceptable_Date := MRP_ATP_PUB.date_arr
                            (l_atp_rec.Latest_Acceptable_Date(I));

          l_model_rec.Delivery_Lead_Time := MRP_ATP_PUB.number_arr
                            (l_atp_rec.Delivery_Lead_Time(I));

          l_model_rec.Atp_lead_Time := MRP_ATP_PUB.number_arr
                            (l_atp_rec.Atp_lead_Time(I));

          l_model_rec.Freight_Carrier := MRP_ATP_PUB.char30_arr
                            (l_atp_rec.Freight_Carrier(I));

          l_model_rec.Ship_Method := MRP_ATP_PUB.char30_arr
                            (l_atp_rec.Ship_Method(I));

          l_model_rec.Demand_Class := MRP_ATP_PUB.char30_arr
                            (l_atp_rec.Demand_Class(I));

          l_model_rec.Ship_Set_Name := MRP_ATP_PUB.char30_arr
                            (l_atp_rec.Ship_Set_Name(I));

          l_model_rec.Arrival_Set_Name := MRP_ATP_PUB.char30_arr
                            (l_atp_rec.Arrival_Set_Name(I));

          l_model_rec.Override_Flag := MRP_ATP_PUB.char1_arr
                            (l_atp_rec.Override_Flag(I));

          l_model_rec.Ship_Date := MRP_ATP_PUB.date_arr
                            (l_atp_rec.Ship_Date(I));

          l_model_rec.Available_Quantity := MRP_ATP_PUB.number_arr
                            (l_atp_rec.Available_Quantity(I));

          l_model_rec.Requested_Date_Quantity := MRP_ATP_PUB.number_arr
                            (l_atp_rec.Requested_Date_Quantity(I));

          l_model_rec.Group_Ship_Date := MRP_ATP_PUB.date_arr
                            (l_atp_rec.Group_Ship_Date(I));

          l_model_rec.Group_Arrival_Date := MRP_ATP_PUB.date_arr
                            (l_atp_rec.Group_Arrival_Date(I));

          l_model_rec.Vendor_Id := MRP_ATP_PUB.number_arr
                            (l_atp_rec.Vendor_Id(I));

          l_model_rec.Vendor_Site_Id := MRP_ATP_PUB.number_arr
                            (l_atp_rec.Vendor_Site_Id(I));

          l_model_rec.Insert_Flag := MRP_ATP_PUB.number_arr
                            (l_atp_rec.Insert_Flag(I));
   	   --oe_debug_pub.add('Insert flag in model_rec : '||l_model_rec.insert_flag,3);

          l_model_rec.Error_Code := MRP_ATP_PUB.number_arr
                            (l_atp_rec.Error_Code(I));

          l_model_rec.Message := MRP_ATP_PUB.char2000_arr
                            (l_atp_rec.Message(I));

          l_model_rec.Action  := MRP_ATP_PUB.number_arr
                            (l_atp_rec.action(I));

          l_model_rec.order_number  := MRP_ATP_PUB.number_arr
                            (l_atp_rec.order_number(I));

          IF l_atp_rec.Old_Source_Organization_Id.Exists(I) THEN
            l_model_rec.Old_Source_Organization_Id := MRP_ATP_PUB.number_arr
                               (l_atp_rec.Old_Source_Organization_Id(I));
          END IF;

          IF l_atp_rec.Old_Demand_Class.Exists(I) THEN
             l_model_rec.Old_Demand_Class  :=
                         MRP_ATP_PUB.char30_arr(l_atp_rec.Old_Demand_Class(I));
          END IF;

          BEGIN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  '2.. CALLING CTO GET_BOM_MANDATORY_COMPS' , 3 ) ;
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
                 oe_debug_pub.add(  '2..AFTER CALLING CTO API : ' || L_RESULT , 3 ) ;
             END IF;

         EXCEPTION
            WHEN OTHERS THEN
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'CTO API RETURNED AN UNEXPECTED ERROR' ) ;
                 END IF;
                 l_result := 0;
         END;


/*
          IF l_result <> 1 THEN
                  IF lErrorMessage is not null THEN
                      oe_msg_pub.add_text(p_message_text => lErrorMessage);
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
*/

          IF l_result = 1 AND
             l_smc_rec.Identifier.count >= 1 THEN
                              IF l_debug_level  > 0 THEN
                                  oe_debug_pub.add(  'SMC COUNT IS : ' || L_SMC_REC.IDENTIFIER.COUNT , 1 ) ;
                              END IF;

             Initialize_mrp_record(p_atp_rec => l_atp_rec,
                               l_count   => l_smc_rec.Identifier.count,
                               x_atp_rec => l_atp_rec);

             FOR J IN 1..l_smc_rec.Identifier.count LOOP
                 I := I + 1;
  -- Added atp_lead_time, order Number to fix bug 1560461.
                 l_atp_rec.atp_lead_time(I)   := 0;
                 l_atp_rec.oe_flag(I) := l_oe_flag;
            -- As part of the bug fix 2910899, OM will indicate and remember the
           -- Standard Madatory record positions using vendor_name. This will be           -- used in the load_results procedure to bypass the SMC records.

                 l_atp_rec.vendor_name(I) := 'SMC';
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'OE FLAG IS : '||L_ATP_REC.OE_FLAG ( I ) , 3 ) ;
                 END IF;

                 l_atp_rec.Inventory_Item_Id(I)      := l_smc_rec.Inventory_Item_Id(J);
                 l_atp_rec.Source_Organization_Id(I) :=
                                       l_smc_rec.Source_Organization_Id(J);

                 l_atp_rec.Identifier(I)             := l_smc_rec.Identifier(J);
                 l_atp_rec.Order_Number(I)           := l_order_number;
                 l_atp_rec.Calling_Module(I)         := l_smc_rec.Calling_Module(J);
                 l_atp_rec.Customer_Id(I)            := l_smc_rec.Customer_Id(J);
                 l_atp_rec.Customer_site_Id(I)       := l_smc_rec.Customer_site_Id(J);
                 l_atp_rec.Destination_Time_Zone(I)  :=
                                       l_smc_rec.Destination_Time_Zone(J);
                 l_atp_rec.Quantity_Ordered(I)       := l_smc_rec.Quantity_Ordered(J);
                 l_atp_rec.Quantity_UOM(I)           := l_smc_rec.Quantity_UOM(J);
                 l_atp_rec.Earliest_Acceptable_Date(I) :=
                                       l_smc_rec.Earliest_Acceptable_Date(J);
                 l_atp_rec.Requested_Ship_Date(I)    :=
                                       l_smc_rec.Requested_Ship_Date(J);
                 l_atp_rec.Requested_Arrival_Date(I) :=
                                       l_smc_rec.Requested_Arrival_Date(J);
                 l_atp_rec.Latest_Acceptable_Date(I) :=
                                       l_smc_rec.Latest_Acceptable_Date(J);
                 l_atp_rec.Delivery_Lead_Time(I)     :=
                                       l_smc_rec.Delivery_Lead_Time(J);
                 l_atp_rec.Freight_Carrier(I)        :=
                                       l_smc_rec.Freight_Carrier(J);
                 l_atp_rec.Ship_Method(I)            :=
                                       l_smc_rec.Ship_Method(J);
                 l_atp_rec.Demand_Class(I)           :=
                                       l_smc_rec.Demand_Class(J);
                 l_atp_rec.Ship_Set_Name(I)          :=
                                       l_smc_rec.Ship_Set_Name(J);
                 l_atp_rec.Arrival_Set_Name(I)       :=
                                       l_smc_rec.Arrival_Set_Name(J);
                 l_atp_rec.Override_Flag(I)          :=
                                       l_smc_rec.Override_Flag(J);
                 l_atp_rec.Ship_Date(I)              :=
                                       l_smc_rec.Ship_Date(J);
                 l_atp_rec.Available_Quantity(I)     :=
                                       l_smc_rec.Available_Quantity(J);
                 l_atp_rec.Requested_Date_Quantity(I):=
                                       l_smc_rec.Requested_Date_Quantity(J);
                 l_atp_rec.Group_Ship_Date(I)        :=
                                       l_smc_rec.Group_Ship_Date(J);
                 l_atp_rec.Group_Arrival_Date(I)     :=
                                       l_smc_rec.Group_Arrival_Date(J);
                 l_atp_rec.Vendor_Id(I)              :=
                                       l_smc_rec.Vendor_Id(J);
                 l_atp_rec.Vendor_Site_Id(I)         :=
                                       l_smc_rec.Vendor_Site_Id(J);
                 l_atp_rec.Insert_Flag(I)            :=
                                       l_smc_rec.Insert_Flag(J);
                 l_atp_rec.atp_lead_time(I)            :=
                                       l_smc_rec.atp_lead_time(J);
   	   IF l_debug_level  > 0 THEN
   	       oe_debug_pub.add(  'INSERT FLAG IN SMC_REC : '||L_SMC_REC.INSERT_FLAG ( J ) , 3 ) ;
   	       oe_debug_pub.add(  'INSERT FLAG IN ATP_REC : '||L_ATP_REC.INSERT_FLAG ( I ) , 3 ) ;
   	   END IF;
                 l_atp_rec.Error_Code(I)             :=
                                       l_smc_rec.Error_Code(J);
                 l_atp_rec.Message(I)                :=
                                       l_smc_rec.Message(J);
                 l_atp_rec.Action(I) := l_action;
             END LOOP;
          END IF;
         END IF; -- l_explode.
        END IF; /* If line is a ATO model */

        <<end_loop>>

        null;

      END LOOP;
   END IF;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  '--**-- ' , 1 ) ;
   END IF;
   x_atp_table    := l_atp_rec;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  '....EXITING OE_ORDER_SCH_UTIL.LOAD_REQUEST' , 1 ) ;
   END IF;
EXCEPTION
  WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Load_MRP_Request'
            );
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNEXPECTED ERROR IN LOAD_RESULTS' ) ;
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Load_MRP_Request;

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
, p_quantity2_to_reserve     IN  NUMBER -- INVCONV
, x_reservation_rec          OUT NOCOPY /* file.sql.39 change */ Inv_Reservation_Global.Mtl_Reservation_Rec_Type)
IS
l_rsv                  Inv_Reservation_Global.Mtl_Reservation_Rec_Type;
l_source_code          VARCHAR2(40) := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
l_sales_order_id       NUMBER;
l_subinventory         VARCHAR2(10);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING LOAD INV REQUEST' , 1 ) ;
   END IF;

        l_rsv.reservation_id            := fnd_api.g_miss_num; -- cannot know
        l_rsv.requirement_date             := p_line_rec.schedule_ship_date;
        l_rsv.organization_id              := p_line_rec.ship_from_org_id;
        l_rsv.inventory_item_id            := p_line_rec.inventory_item_id;

        IF p_line_rec.source_document_type_id = 10 THEN

           -- This is an internal order line. We need to give
           -- a different demand source type for these lines.

           l_rsv.demand_source_type_id        :=
              INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_INTERNAL_ORD;
                                                       -- intenal order

        ELSE

           l_rsv.demand_source_type_id        :=
              INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_OE; -- order entry

        END IF;

        l_rsv.demand_source_name           := NULL;

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

        l_rsv.demand_source_header_id      := l_sales_order_id;
        l_rsv.demand_source_line_id        := p_line_rec.line_id;
        l_rsv.demand_source_delivery       := NULL;
        l_rsv.primary_uom_code             := NULL;
        l_rsv.primary_uom_id               := NULL;
        l_rsv.reservation_uom_code         := p_line_rec.order_quantity_uom;
        l_rsv.reservation_uom_id           := NULL;
        l_rsv.reservation_quantity         := p_quantity_to_reserve;
        l_rsv.primary_reservation_quantity := NULL;
        l_rsv.autodetail_group_id          := NULL;
        l_rsv.external_source_code         := NULL;
        l_rsv.external_source_line_id      := NULL;

        l_rsv.supply_source_type_id        :=
              INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_INV;

        l_rsv.supply_source_header_id      := NULL;
        l_rsv.supply_source_line_id        := NULL;
        l_rsv.supply_source_name           := NULL;
        l_rsv.supply_source_line_detail    := NULL;
        l_rsv.revision                     := NULL;
        l_rsv.subinventory_code            := l_subinventory;
        l_rsv.subinventory_id              := NULL;
        l_rsv.locator_id                   := NULL;
        l_rsv.lot_number                   := NULL;
        l_rsv.lot_number_id                := NULL;
        l_rsv.pick_slip_number             := NULL;
        l_rsv.lpn_id                       := NULL;
        l_rsv.attribute_category           := NULL;
	   /* OPM 02/JUN/00 send process attributes into the reservation
	   =============================================================
        l_rsv.attribute1                   := p_line_rec.preferred_grade;
        l_rsv.attribute2                   := p_line_rec.ordered_quantity2;
        l_rsv.attribute3                   := p_line_rec.ordered_quantity_uom2;
	    OPM 02/JUN/00 END
	  ====================   -- INVCONV    */

        l_rsv.secondary_reservation_quantity   := p_line_rec.ordered_quantity2; -- INVCONV
        l_rsv.secondary_uom_code               := p_line_rec.ordered_quantity_uom2;

 				l_rsv.attribute1                   := NULL;   -- INVCONV
  			l_rsv.attribute2                   := NULL;  -- INVCONV
   			l_rsv.attribute3                   := NULL;  -- INVCONV
        l_rsv.attribute4                   := NULL;
        l_rsv.attribute5                   := NULL;
        l_rsv.attribute6                   := NULL;
        l_rsv.attribute7                   := NULL;
        l_rsv.attribute8                   := NULL;
        l_rsv.attribute9                   := NULL;
        l_rsv.attribute10                  := NULL;
        l_rsv.attribute11                  := NULL;
        l_rsv.attribute12                  := NULL;
        l_rsv.attribute13                  := NULL;
        l_rsv.attribute14                  := NULL;
        l_rsv.attribute15                  := NULL;
        l_rsv.ship_ready_flag              := NULL;
   x_reservation_rec := l_rsv;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING LOAD INV REQUEST' , 1 ) ;
   END IF;
EXCEPTION

   WHEN NO_DATA_FOUND
     THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_INV_Request;
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


    RETURN FALSE;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETURNING FALSE ' , 3 ) ;
    END IF;
END Schedule_Attribute_Changed;

/*---------------------------------------------------------------------
Procedure Name : Unreserve_Line
Description    : This API calls Inventory's APIs to Unreserve. It first
                 queries the reservation records, and then calls
                 delete_reservations until the p_quantity_to_unreserve
                 is satisfied.
--------------------------------------------------------------------- */

Procedure Unreserve_Line
( p_line_rec              IN  OE_ORDER_PUB.Line_Rec_Type
, p_quantity_to_unreserve IN  NUMBER
, p_quantity2_to_unreserve IN  NUMBER -- INVCONV
, x_return_status         OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
l_line_rec              OE_ORDER_PUB.line_rec_type;
l_rsv_rec               inv_reservation_global.mtl_reservation_rec_type;
l_rsv_new_rec           inv_reservation_global.mtl_reservation_rec_type;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(240);
l_rsv_id                NUMBER;
l_return_status         VARCHAR2(1);
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

l_qty2_to_unreserve      NUMBER; -- INVCONV
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING UNRESERVE LINE' , 3 ) ;
      oe_debug_pub.add(  'QUANTITY TO UNRESERVE :' || P_QUANTITY_TO_UNRESERVE , 3 ) ;
      oe_debug_pub.add(  'QUANTITY2 TO UNRESERVE :' || P_QUANTITY2_TO_UNRESERVE , 3 ) ;
  END IF;

  -- If the quantity to reserve is passed and null or missing, we do not
  -- need to go throug this procedure.

  IF p_quantity_to_unreserve is null OR
     p_quantity_to_unreserve = FND_API.G_MISS_NUM THEN
     goto end_of_loop;
  END IF;

  l_line_rec                         := p_line_rec;

  IF p_line_rec.source_document_type_id = 10 THEN

     -- This is an internal order line. We need to give
     -- a different demand source type for these lines.

     l_rsv_rec.demand_source_type_id        :=
          INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_INTERNAL_ORD;
                                              -- intenal order

  ELSE

     l_rsv_rec.demand_source_type_id        :=
          INV_RESERVATION_GLOBAL.G_SOURCE_TYPE_OE; -- order entry

  END IF;

  -- Get demand_source_header_id from mtl_sales_orders

  l_sales_order_id := Get_mtl_sales_order_id(p_line_rec.HEADER_ID);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_SALES_ORDER_ID' || L_SALES_ORDER_ID , 3 ) ;
  END IF;

  l_rsv_rec.demand_source_header_id  := l_sales_order_id;
  l_rsv_rec.demand_source_line_id    := l_line_rec.line_id;

  -- 02-jun-2000 mpetrosi added org_id to query_reservation start
  l_rsv_rec.organization_id := l_line_rec.ship_from_org_id;
  -- 02-jun-2000 mpetrosi end change

  inv_reservation_pub.query_reservation
  (  p_api_version_number        => 1.0
  , p_init_msg_lst              => fnd_api.g_true
  , x_return_status             => l_return_status
  , x_msg_count                 => l_msg_count
  , x_msg_data                  => l_msg_data
  , p_query_input               => l_rsv_rec
  , p_cancel_order_mode         => INV_RESERVATION_GLOBAL.G_CANCEL_ORDER_YES
  , x_mtl_reservation_tbl       => l_rsv_tbl
  , x_mtl_reservation_tbl_count => l_count
  , x_error_code                => l_x_error_code
  , p_lock_records              => l_lock_records
  , p_sort_by_req_date          => l_sort_by_req_date
  );

                                         IF l_debug_level  > 0 THEN
                                             oe_debug_pub.add(  '3. AFTER CALLING QUERY RESERVATION' || L_RETURN_STATUS , 1 ) ;
       oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
   END IF;

  l_qty_to_unreserve      := p_quantity_to_unreserve;
  l_qty2_to_unreserve      := p_quantity2_to_unreserve; -- INVCONV
  FOR I IN 1..l_rsv_tbl.COUNT LOOP

    l_rsv_rec := l_rsv_tbl(I);
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RESERVED QTY : ' || L_RSV_REC.RESERVATION_QUANTITY , 1 ) ;
        oe_debug_pub.add(  'QTY TO UNRESERVE: ' || L_QTY_TO_UNRESERVE , 1 ) ;
        oe_debug_pub.add(  'RESERVED QTY2 : ' || L_RSV_REC.secondary_reservation_quantity, 1 ) ;
        oe_debug_pub.add(  'QTY2 TO UNRESERVE: ' || L_QTY2_TO_UNRESERVE , 1 ) ;

    END IF;

    IF (l_rsv_rec.reservation_quantity <= l_qty_to_unreserve)
    THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CALLING INVS DELETE_RESERVATION' , 3 ) ;
      END IF;
      inv_reservation_pub.delete_reservation
      ( p_api_version_number      => 1.0
      , p_init_msg_lst            => fnd_api.g_true
      , x_return_status           => l_return_status
      , x_msg_count               => l_msg_count
      , x_msg_data                => l_msg_data
      , p_rsv_rec                 => l_rsv_rec
      , p_serial_number           => l_dummy_sn
      );

                             IF l_debug_level  > 0 THEN
                                 oe_debug_pub.add(  'AFTER CALLING INVS DELETE_RESERVATION: ' || L_RETURN_STATUS , 1 ) ;
                             END IF;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_qty_to_unreserve := l_qty_to_unreserve -
                            l_rsv_rec.reservation_quantity;

      l_qty2_to_unreserve := l_qty2_to_unreserve -            -- INVCONV
                            l_rsv_rec.secondary_reservation_quantity;

      IF (l_qty_to_unreserve <= 0) THEN
            goto end_of_loop;
      END IF;

    ELSE

      l_rsv_new_rec                              := l_rsv_rec;
      l_rsv_new_rec.reservation_quantity         :=
            l_rsv_rec.reservation_quantity - l_qty_to_unreserve ;
      l_rsv_new_rec.primary_reservation_quantity := fnd_api.g_miss_num;
       --     l_rsv_rec.reservation_quantity - l_qty_to_unreserve ;

      l_rsv_new_rec.secondary_reservation_quantity :=   --INVCONV
            l_rsv_rec.secondary_reservation_quantity - l_qty2_to_unreserve ;


                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'OLD QTY : ' || L_RSV_REC.RESERVATION_QUANTITY , 3 ) ;
                            oe_debug_pub.add(  'NEW QTY : ' || L_RSV_NEW_REC.RESERVATION_QUANTITY , 3 ) ;
                            oe_debug_pub.add(  'OLD QTY2 : ' || L_RSV_REC.SECONDARY_RESERVATION_QUANTITY , 3 ) ; -- INVCONV
                            oe_debug_pub.add(  'NEW QTY2 : ' || L_RSV_NEW_REC.SECONDARY_RESERVATION_QUANTITY , 3 ) ;
                        END IF;

	 /* OPM 14/SEP/00 send process attributes into the reservation
	 =============================================================
      IF INV_GMI_RSV_BRANCH.Process_Branch(p_organization_id => l_line_rec.ship_from_org_id)	-- OPM 2645605
	then

      	l_rsv_new_rec.attribute1     := p_line_rec.preferred_grade;
      	l_rsv_new_rec.attribute2     := p_line_rec.ordered_quantity2;
      	l_rsv_new_rec.attribute3     := p_line_rec.ordered_quantity_uom2;

      END IF;

	  OPM 14/SEP/00 END  INVCONV
	 ====================*/
				l_rsv_new_rec.secondary_reservation_quantity   := p_line_rec.ordered_quantity2; -- INVCONV
        l_rsv_new_rec.secondary_uom_code               := p_line_rec.ordered_quantity_uom2;


      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CALLING INVS UPDATE_RESERVATION: ' , 3 ) ;
      END IF;

      inv_reservation_pub.update_reservation
      ( p_api_version_number        => 1.0
      , p_init_msg_lst              => fnd_api.g_true
      , x_return_status             => l_return_status
      , x_msg_count                 => l_msg_count
      , x_msg_data                  => l_msg_data
      , p_original_rsv_rec          => l_rsv_rec
      , p_to_rsv_rec                => l_rsv_new_rec
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

      l_qty_to_unreserve := 0;

      IF (l_qty_to_unreserve <= 0) THEN
            goto end_of_loop;
      END IF;


    END IF;
  END LOOP;
  <<end_of_loop>>
  null;

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
            ,   'Schedule_line'
            );
        END IF;

END Unreserve_Line;

/*--------------------------------------------------------------------------
Procedure Name : Create_Group_Request
Description    : This procedure is called to create a group request for
                 group_scheduling.
                 We have 4 scheduling groups:
                 1. Arrival Set
                 2. Ship Set
                 3. Ship Model Complete PTO configuration
                 4. ATO configuration

                 The entity type on the x_group_req_rec is populated
                 based on the type of group it is.

                 The group attributes are populated on the x_group_req_rec
                 based on the ones changed.
-------------------------------------------------------------------------- */
Procedure Create_Group_Request
(  p_line_rec         IN  OE_ORDER_PUB.line_rec_type
 , p_old_line_rec     IN  OE_ORDER_PUB.line_rec_type
 , x_group_req_rec    OUT NOCOPY /* file.sql.39 change */ OE_GRP_SCH_UTIL.Sch_Group_Rec_Type
 , x_return_status    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_group_req_rec  OE_GRP_SCH_UTIL.Sch_Group_Rec_Type;  -- INVCONV  PAL - not sure if need to change this - purpose of this ?
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING CREATE_GROUP_REQUEST' , 1 ) ;
   END IF;

   IF (p_line_rec.arrival_set_id is not null) THEN
       l_group_req_rec.entity_type := OESCH_ENTITY_ARRIVAL_SET;
       l_group_req_rec.arrival_set_number   := p_line_rec.arrival_set_id;
   ELSIF (p_line_rec.ship_set_id is not null) THEN
       l_group_req_rec.entity_type := OESCH_ENTITY_SHIP_SET;
       l_group_req_rec.ship_set_number   := p_line_rec.ship_set_id;
   ELSIF (p_line_rec.ship_model_complete_flag ='Y') THEN
       l_group_req_rec.entity_type := OESCH_ENTITY_SMC;
       l_group_req_rec.ship_set_number   := p_line_rec.top_model_line_id;
   ELSIF (p_line_rec.ato_line_id is not null) THEN
       l_group_req_rec.entity_type := OESCH_ENTITY_ATO_CONFIG;
       l_group_req_rec.ship_set_number   := p_line_rec.ato_line_id;
   END  IF;

   l_group_req_rec.header_id         := p_line_rec.header_id;
   l_group_req_rec.line_id           := p_line_rec.line_id;
   IF p_line_rec.schedule_action_code is not null THEN
       l_group_req_rec.action            := p_line_rec.schedule_action_code;
   ELSE
       l_group_req_rec.action            := OESCH_ACT_RESCHEDULE;
   END IF;

   IF p_line_rec.ship_from_org_id is NOT NULL and
      p_line_rec.ship_from_org_id <> FND_API.G_MISS_NUM
   THEN
       l_group_req_rec.ship_from_org_id := p_line_rec.ship_from_org_id;
   END IF;

   -- Added this code to fix bug 1894284.
   IF p_old_line_rec.ship_from_org_id is NOT NULL and
      p_old_line_rec.ship_from_org_id <> FND_API.G_MISS_NUM
   THEN
       l_group_req_rec.old_ship_from_org_id := p_old_line_rec.ship_from_org_id;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_line_rec.request_date,
                           p_old_line_rec.request_date) THEN
      l_group_req_rec.request_date := p_line_rec.request_date;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_line_rec.schedule_ship_date,
                           p_old_line_rec.schedule_ship_date)
   THEN

       l_group_req_rec.schedule_ship_date := p_line_rec.schedule_ship_date;

       -- If the old date is missing, then set the action as SCHEDULE

       IF (p_old_line_rec.schedule_ship_date is null OR
           p_old_line_rec.schedule_ship_date = FND_API.G_MISS_DATE) THEN
           l_group_req_rec.action  := OESCH_ACT_SCHEDULE;
       END IF;

   END IF;

   IF NOT OE_GLOBALS.Equal(p_line_rec.schedule_arrival_date,
                           p_old_line_rec.schedule_arrival_date)
   THEN

      l_group_req_rec.schedule_arrival_date :=
                              p_line_rec.schedule_arrival_date;

      -- If the old date is missing, then set the action as SCHEDULE

      IF (p_old_line_rec.schedule_arrival_date is null OR
           p_old_line_rec.schedule_arrival_date = FND_API.G_MISS_DATE)
      THEN
           l_group_req_rec.action            := OESCH_ACT_SCHEDULE;
      END IF;

   END IF;

   IF NOT OE_GLOBALS.Equal(p_line_rec.shipping_method_code,
                           p_old_line_rec.shipping_method_code) THEN

      -- NOTE!!!!
      -- We are storing the shipping_method_code value in the
      -- freight_carrier field of the l_group_req_rec.

      l_group_req_rec.freight_carrier := p_line_rec.shipping_method_code;

   END IF;

   IF NOT OE_GLOBALS.Equal(p_line_rec.ship_to_org_id,
                           p_old_line_rec.ship_to_org_id) THEN
       l_group_req_rec.ship_to_org_id := p_line_rec.ship_to_org_id;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_line_rec.ordered_quantity,
                           p_old_line_rec.ordered_quantity) THEN
       l_group_req_rec.quantity := p_line_rec.ordered_quantity;
       l_group_req_rec.old_quantity := p_old_line_rec.ordered_quantity;
   END IF;

   l_group_req_rec.old_ship_set_number    := p_old_line_rec.ship_set_id;
   l_group_req_rec.old_arrival_set_number := p_old_line_rec.arrival_set_id;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  '*********PRINTING GROUP REQUEST ATTRIBUTES***********' , 1 ) ;
       oe_debug_pub.add(  'GROUP ENTITY :' || L_GROUP_REQ_REC.ENTITY_TYPE , 1 ) ;
       oe_debug_pub.add(  'GROUP HEADER ID :' || L_GROUP_REQ_REC.HEADER_ID , 1 ) ;
       oe_debug_pub.add(  'LINE ID :' || L_GROUP_REQ_REC.LINE_ID , 1 ) ;
       oe_debug_pub.add(  'GROUP ACTION :' || L_GROUP_REQ_REC.ACTION , 1 ) ;
       oe_debug_pub.add(  'GROUP WAREHOUSE :' || L_GROUP_REQ_REC.SHIP_FROM_ORG_ID , 1 ) ;
       oe_debug_pub.add(  'GROUP SHIP TO :' || L_GROUP_REQ_REC.SHIP_TO_ORG_ID , 1 ) ;
       oe_debug_pub.add(  'GROUP SHIP SET# :' || L_GROUP_REQ_REC.SHIP_SET_NUMBER , 1 ) ;
       oe_debug_pub.add(  'GROUP ARR SET# :' || L_GROUP_REQ_REC.ARRIVAL_SET_NUMBER , 1 ) ;
       oe_debug_pub.add(  'SHIP METHOD :' || L_GROUP_REQ_REC.FREIGHT_CARRIER , 1 ) ;
       oe_debug_pub.add(  'GRP REQUEST DATE :' || L_GROUP_REQ_REC.REQUEST_DATE , 1 ) ;
       oe_debug_pub.add(  'GRP SHIP DATE :' || L_GROUP_REQ_REC.SCHEDULE_SHIP_DATE , 1 ) ;
       oe_debug_pub.add(  'GRP ARRIVAL DATE :' || L_GROUP_REQ_REC.SCHEDULE_ARRIVAL_DATE , 1 ) ;
   END IF;

   x_group_req_rec := l_group_req_rec;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING CREATE_GROUP_REQUEST' , 1 ) ;
   END IF;

END Create_Group_Request;

/*--------------------------------------------------------------------------
Procedure Name : Call_ATP
Description    : ** Not Used **
-------------------------------------------------------------------------- */

PROCEDURE Call_ATP
( p_atp_table          IN    MRP_ATP_PUB.ATP_Rec_Typ
, x_atp_table          OUT NOCOPY /* file.sql.39 change */   MRP_ATP_PUB.ATP_Rec_Typ
, x_atp_supply_demand  OUT NOCOPY /* file.sql.39 change */   MRP_ATP_PUB.ATP_Supply_Demand_Typ
, x_atp_period         OUT NOCOPY /* file.sql.39 change */   MRP_ATP_PUB.ATP_Period_Typ
, x_atp_details        OUT NOCOPY /* file.sql.39 change */   MRP_ATP_PUB.ATP_Details_Typ
, x_return_status      OUT NOCOPY /* file.sql.39 change */   VARCHAR2
, x_msg_data           OUT NOCOPY /* file.sql.39 change */   VARCHAR2
, x_msg_count          OUT NOCOPY /* file.sql.39 change */   NUMBER)
IS
I  NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  I := 1;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING CALL ATP' , 1 ) ;
      oe_debug_pub.add(  P_ATP_TABLE.INVENTORY_ITEM_ID ( 1 ) ) ;
  END IF;

  x_atp_table := p_atp_table;

  x_atp_table.Requested_Date_Quantity := MRP_ATP_PUB.number_arr
                                         (p_atp_table.Quantity_Ordered(I));
  x_atp_table.Source_Organization_Id  := MRP_ATP_PUB.number_arr(204);
  x_atp_table.Requested_Date_Quantity := MRP_ATP_PUB.number_arr(967900);
  x_atp_table.error_code := MRP_ATP_PUB.number_arr(0);
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count  := 0;
  null;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING CALL ATP' , 1 ) ;
  END IF;
END;

/*--------------------------------------------------------------------------
Procedure Name : Load_Results
Description    : This API loads the results from MRP's ATP_REC_TYPE to
                 OM's order line. It also populates OM's ATP Table which
                 is used to display the ATP results on the client side.
                 We ignore the mandatory components which we passed to MRP
                 while loading the results.
-------------------------------------------------------------------------- */
Procedure Load_Results
( p_atp_table       IN  MRP_ATP_PUB.ATP_Rec_Typ
, p_x_line_tbl      IN OUT NOCOPY OE_ORDER_PUB.line_tbl_type
, x_atp_tbl         OUT NOCOPY /* file.sql.39 change */ OE_ATP.ATP_Tbl_Type
, x_return_status   OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
I                  NUMBER := 0;
J                  NUMBER := 0;
ATP                NUMBER := 0;
l_line_rec         OE_ORDER_PUB.line_rec_type;
l_atp_rec          OE_ATP.atp_rec_type;
l_msg_count        NUMBER;
l_msg_data         VARCHAR2(2000);
l_explanation      VARCHAR2(80);
l_return_status    VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_type_code        VARCHAR2(30);
l_ship_set_name    VARCHAR2(30);
l_arrival_set_name VARCHAR2(30);
l_arrival_date     DATE := NULL;
l_config_exists    VARCHAR2(1):= 'N';
l_organization_id  NUMBER;     -------- Bug -2316250
l_inventory_item   VARCHAR2(2000);   -------- Bug - 2316250
l_old_ato_line_id  Number := -99;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  '2. ENTERING LOAD_RESULTS' , 1 ) ;
      oe_debug_pub.add(  '-----------------LOADING MRP RESULTS---------------' , 1 ) ;
      oe_debug_pub.add(  'MRP COUNT IS ' || P_ATP_TABLE.ERROR_CODE.COUNT , 1 ) ;
      oe_debug_pub.add(  'LINE COUNT IS ' || P_X_LINE_TBL.COUNT , 1 ) ;
  END IF;

  J := J + 1;
  FOR I in 1..p_x_line_tbl.count LOOP


  -- Added code to fix bug 1925326
     IF p_x_line_tbl(I).ato_line_id is not null
     AND p_x_line_tbl(I).ato_line_id <> l_old_ato_line_id
     THEN

        l_old_ato_line_id := p_x_line_tbl(I).ato_line_id;
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Check for config on line ' || P_X_LINE_TBL(I).ATO_LINE_ID , 1 ) ;
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

     l_line_rec      := p_x_line_tbl(I);

     IF l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG THEN

        -- The config item might be a part of the table since query
        -- of a group of lines returns back the config item too. But
        -- we did not pass this item to MRP (in load_mrp_request). Thus
        -- we will bypass this record out here too.

        -- Since we don't pass config line to MRP we need populate schedule date
        -- on config from Model line. This is to fix bug1576412.

        IF OE_GLOBALS.Equal(l_line_rec.schedule_action_code,
                                    OESCH_ACT_RESCHEDULE) THEN

        -- Modified this part to fix bug 1900085.
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'UPDATING CONFIG LINE ' || L_LINE_REC.LINE_ID , 1 ) ;
           END IF;
          IF p_atp_table.group_ship_date(1) IS NOT NULL
          THEN
            l_line_rec.schedule_ship_date := p_atp_table.group_ship_date(1);
            l_line_rec.schedule_arrival_date  :=
                                    l_line_rec.schedule_ship_date +
                                    nvl(p_atp_table.delivery_lead_time(1),0);

          ELSIF p_atp_table.group_arrival_date(1) IS NOT NULL
          THEN
            l_line_rec.schedule_arrival_date :=
                                    p_atp_table.group_arrival_date(1);
            l_line_rec.schedule_ship_date :=
                l_line_rec.schedule_arrival_date -
                nvl(p_atp_table.delivery_lead_time(1),0);

          END IF;

         --  l_line_rec.schedule_ship_date := p_atp_table.group_ship_date(1);

		 -- Get the arrival_date from model and populate the same to
		 -- Config line. The l_arrival_date should be used only for
		 -- populating config.

          -- l_line_rec.schedule_arrival_date := l_arrival_date;

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'CONFIG SCHEDULE ' || L_LINE_REC.SCHEDULE_SHIP_DATE , 2 ) ;
               oe_debug_pub.add(  'CONFIG ARRIVAL ' || L_LINE_REC.SCHEDULE_ARRIVAL_DATE , 2 ) ;
           END IF;
        END IF;

        goto end_loop;

     END IF;

     -- Setting Message Context


     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SCHEDULE ACTION CODE ' || L_LINE_REC.SCHEDULE_ACTION_CODE , 1 ) ;
     END IF;

     IF (p_atp_table.error_code(J) <> 0) AND
     NOT OE_GLOBALS.Equal(l_line_rec.schedule_action_code,
                               OESCH_ACT_ATP_CHECK) AND
        (p_atp_table.error_code(J) <> -99 ) AND -- Multi org changes.
        (p_atp_table.error_code(J) <> 150) -- to fix bug 1880166

     THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ERROR FROM MRP: ' || P_ATP_TABLE.ERROR_CODE ( J ) , 1 ) ;
        END IF;
        IF p_atp_table.error_code(J) = 80 THEN
             FND_MESSAGE.SET_NAME('ONT','OE_SCH_NO_SOURCE');
             OE_MSG_PUB.Add;
        ELSE

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SCHEDULING FAILED' , 1 ) ;
                oe_debug_pub.add(  P_ATP_TABLE.ERROR_CODE ( J ) , 1 ) ;
            END IF;

            OE_MSG_PUB.set_msg_context(
             p_entity_code                 => 'LINE'
             ,p_entity_id                  => l_line_rec.line_id
             ,p_header_id                  => l_line_rec.header_id
             ,p_line_id                    => l_line_rec.line_id
             ,p_order_source_id            => l_line_rec.order_source_id
             ,p_orig_sys_document_ref      => l_line_rec.orig_sys_document_ref
             ,p_orig_sys_document_line_ref => l_line_rec.orig_sys_line_ref
             ,p_orig_sys_shipment_ref      => l_line_rec.orig_sys_shipment_ref
             ,p_change_sequence            => l_line_rec.change_sequence
             ,p_source_document_type_id    => l_line_rec.source_document_type_id
             ,p_source_document_id         => l_line_rec.source_document_id
             ,p_source_document_line_id    => l_line_rec.source_document_line_id );

            l_explanation := null;

            select meaning
            into l_explanation
            from mfg_lookups where
            lookup_type = 'MTL_DEMAND_INTERFACE_ERRORS'
            and lookup_code = p_atp_table.error_code(J) ;

            IF p_atp_table.error_code(J) = 19 THEN
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

           -- Commenting below code to fix bug 2389242.
          /*  ELSIF p_atp_table.Ship_Set_Name(J) is not null OR
                  p_atp_table.Arrival_Set_Name(J) is not null THEN

             -- This line belongs to a scheduling group. We do not want
             -- to give out individual messages for each line. We will store
             -- them in atp_tbl which can be displayed by the user.
             null;
          */
            ELSE
		    IF l_debug_level  > 0 THEN
		        oe_debug_pub.add(  'ADDING MESSAGE TO THE STACK' , 1 ) ;
		    END IF;
              FND_MESSAGE.SET_NAME('ONT','OE_SCH_OE_ORDER_FAILED');
              FND_MESSAGE.SET_TOKEN('EXPLANATION',l_explanation);
              OE_MSG_PUB.Add;
            END IF;
        END IF;

        l_atp_rec.error_message   := l_explanation;

        l_atp_rec.inventory_item_id   := l_line_rec.inventory_item_id;
        l_atp_rec.ordered_quantity    := l_line_rec.ordered_quantity;
        l_atp_rec.order_quantity_uom  := l_line_rec.order_quantity_uom;
        l_atp_rec.request_date        := l_line_rec.request_date;
        l_atp_rec.ship_from_org_id    :=
                    p_atp_table.Source_Organization_Id(J);
        l_atp_rec.qty_on_request_date :=
                    p_atp_table.Requested_Date_Quantity(J);
        l_atp_rec.ordered_qty_Available_Date :=
                    p_atp_table.Ship_Date(J);
        l_atp_rec.qty_on_available_date  :=
                    p_atp_table.Available_Quantity(J);
        l_atp_rec.group_available_date  :=
                    p_atp_table.group_ship_date(J);
        IF p_atp_table.group_arrival_date(J) is not null THEN
          l_atp_rec.group_available_date  :=
                    p_atp_table.group_arrival_date(J);
        END IF;

        -- Display Values
        l_atp_rec.line_id             := l_line_rec.line_id;
        l_atp_rec.header_id           := l_line_rec.header_id;
        l_atp_rec.line_number         := l_line_rec.line_number;
        l_atp_rec.shipment_number     := l_line_rec.shipment_number;
        l_atp_rec.option_number       := l_line_rec.option_number;
        l_atp_rec.item_input          := l_line_rec.ordered_item;

        IF l_line_rec.ship_set_id is not null THEN
          BEGIN
             SELECT SET_NAME
             INTO l_ship_set_name
             FROM OE_SETS
             WHERE set_id = l_line_rec.ship_set_id;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
               l_ship_set_name := null;
          END;
        END IF;

        IF l_line_rec.arrival_set_id is not null THEN
          BEGIN
             SELECT SET_NAME
             INTO l_arrival_set_name
             FROM OE_SETS
             WHERE set_id = l_line_rec.arrival_set_id;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
               l_arrival_set_name := null;
          END;
        END IF;

        l_atp_rec.ship_set            := l_ship_set_name;
        l_atp_rec.arrival_set         := l_arrival_set_name;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SETTING ERROR' , 1 ) ;
        END IF;
        l_return_status := FND_API.G_RET_STS_ERROR;

     ELSE

	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'LOADING ATP RECORD' , 1 ) ;
            oe_debug_pub.add(  P_ATP_TABLE.SOURCE_ORGANIZATION_ID ( 1 ) , 1 ) ;
            oe_debug_pub.add(  'ERROR CODE : ' || P_ATP_TABLE.ERROR_CODE ( J ) , 1 ) ;
        END IF;
	-- Muti org changes.
      IF (p_atp_table.error_code(J) <> -99 ) THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  '3. ERROR CODE : ' || P_ATP_TABLE.ERROR_CODE ( J ) , 1 ) ;
            oe_debug_pub.add(  '3. J : ' || J , 3 ) ;
            oe_debug_pub.add(  '3. IDENTIFIER : ' || P_ATP_TABLE.IDENTIFIER ( J ) , 1 ) ;
            oe_debug_pub.add(  '3. ITEM : ' || P_ATP_TABLE.INVENTORY_ITEM_ID ( J ) , 1 ) ;
                                            oe_debug_pub.add(  '3.REQUEST SHIP DATE :' || TO_CHAR ( P_ATP_TABLE.REQUESTED_SHIP_DATE ( J ) , 'DD-MON-RR:HH:MM:SS' ) , 1 ) ;
                                    oe_debug_pub.add(  '3.REQUEST ARRIVAL DATE :' || P_ATP_TABLE.REQUESTED_ARRIVAL_DATE ( J ) , 1 ) ;
                                            oe_debug_pub.add(  '3.SHIP DATE :' || TO_CHAR ( P_ATP_TABLE.SHIP_DATE ( J ) , 'DD-MON-RR:HH:MM:SS' ) , 1 ) ;
                                    oe_debug_pub.add(  '3.LEAD TIME :' || P_ATP_TABLE.DELIVERY_LEAD_TIME ( J ) , 1 ) ;
                                    oe_debug_pub.add(  '3.GROUP SHIP DATE :' || P_ATP_TABLE.GROUP_SHIP_DATE ( J ) , 1 ) ;
                                    oe_debug_pub.add(  '3.GROUP ARRIVAL DATE :' || P_ATP_TABLE.GROUP_ARRIVAL_DATE ( J ) , 1 ) ;
                                END IF;

        l_explanation := null;

        IF (p_atp_table.error_code(J) <> 0) THEN

           BEGIN
              select meaning
              into l_explanation
              from mfg_lookups where
              lookup_type = 'MTL_DEMAND_INTERFACE_ERRORS'
              and lookup_code = p_atp_table.error_code(J) ;

              l_atp_rec.error_message   := l_explanation;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'EXPLANATION IS : ' || L_EXPLANATION , 1 ) ;
              END IF;

              IF p_atp_table.error_code(J) = 150 THEN -- to fix bug 1880166.
                 OE_MSG_PUB.add_text(l_explanation);
              END IF;

           EXCEPTION
              WHEN OTHERS THEN
                Null;
           END;

        END IF;

        l_atp_rec.inventory_item_id   := l_line_rec.inventory_item_id;
        l_atp_rec.ordered_quantity    := l_line_rec.ordered_quantity;
        l_atp_rec.order_quantity_uom  := l_line_rec.order_quantity_uom;
        l_atp_rec.request_date        := l_line_rec.request_date;
        l_atp_rec.ship_from_org_id    :=
                    p_atp_table.Source_Organization_Id(J);
        l_atp_rec.qty_on_request_date :=
                    p_atp_table.Requested_Date_Quantity(J);
        l_atp_rec.ordered_qty_Available_Date :=
                    p_atp_table.Ship_Date(J);
        l_atp_rec.qty_on_available_date  :=
                    p_atp_table.Available_Quantity(J);
        l_atp_rec.group_available_date  :=
                    p_atp_table.group_ship_date(J);
        IF p_atp_table.group_arrival_date(J) is not null THEN
          l_atp_rec.group_available_date  :=
                    p_atp_table.group_arrival_date(J);
        END IF;

        -- Display Values
        l_atp_rec.line_id             := l_line_rec.line_id;
        l_atp_rec.header_id           := l_line_rec.header_id;
        l_atp_rec.line_number         := l_line_rec.line_number;
        l_atp_rec.shipment_number     := l_line_rec.shipment_number;
        l_atp_rec.option_number       := l_line_rec.option_number;
        l_atp_rec.item_input          := l_line_rec.ordered_item;
        l_atp_rec.error_message       := l_explanation;

        IF l_line_rec.ship_set_id is not null THEN
          BEGIN
             SELECT SET_NAME
             INTO l_ship_set_name
             FROM OE_SETS
             WHERE set_id = l_line_rec.ship_set_id;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
               l_ship_set_name := null;
          END;
        END IF;

        IF l_line_rec.arrival_set_id is not null THEN
          BEGIN
             SELECT SET_NAME
             INTO l_arrival_set_name
             FROM OE_SETS
             WHERE set_id = l_line_rec.arrival_set_id;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
               l_arrival_set_name := null;
          END;
        END IF;

        l_atp_rec.ship_set            := l_ship_set_name;
        l_atp_rec.arrival_set         := l_arrival_set_name;

---------------------- Changes for Bug-2316250 ---------------------------
        l_organization_id := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
  --to fix bug 2795033,passing below l_line_rec.ordered_item instead of
  --l_line_rec.Original_ordered_item

       OE_ID_TO_VALUE.Ordered_Item
            (p_Item_Identifier_type  => l_line_rec.item_identifier_type
            ,p_inventory_item_id     => l_line_rec.inventory_item_id
            ,p_organization_id       => l_organization_id
            ,p_ordered_item_id       => l_line_rec.ordered_item_id
            ,p_sold_to_org_id        => l_line_rec.sold_to_org_id
            ,p_ordered_item          => l_line_rec.ordered_item
            ,x_ordered_item          => l_atp_rec.Ordered_item_name
            ,x_inventory_item        => l_inventory_item);

---------------------- Changes for Bug-2316250 ---------------------------

      END IF; --Check for -99.

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        IF OE_GLOBALS.Equal(l_line_rec.schedule_action_code,
                               OESCH_ACT_DEMAND)
              OR OE_GLOBALS.Equal(l_line_rec.schedule_action_code,
                                  OESCH_ACT_SCHEDULE)
        THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LOADING RESULTS OF SCHEDULE' , 1 ) ;
                                            oe_debug_pub.add(  '1.REQUEST SHIP DATE :' || TO_CHAR ( P_ATP_TABLE.REQUESTED_SHIP_DATE ( J ) , 'DD-MON-RR:HH:MM:SS' ) , 1 ) ;
                                    oe_debug_pub.add(  '1.REQUEST ARRIVAL DATE :' || P_ATP_TABLE.REQUESTED_ARRIVAL_DATE ( J ) , 1 ) ;
                                            oe_debug_pub.add(  '1.SHIP DATE :' || TO_CHAR ( P_ATP_TABLE.SHIP_DATE ( J ) , 'DD-MON-RR:HH:MM:SS' ) , 1 ) ;
                                    oe_debug_pub.add(  '1.LEAD TIME :' || P_ATP_TABLE.DELIVERY_LEAD_TIME ( J ) , 1 ) ;
                                    oe_debug_pub.add(  '1.GROUP SHIP DATE :' || P_ATP_TABLE.GROUP_SHIP_DATE ( J ) , 1 ) ;
                                    oe_debug_pub.add(  '1.GROUP ARRIVAL DATE :' || P_ATP_TABLE.GROUP_ARRIVAL_DATE ( J ) , 1 ) ;
                                END IF;


          l_line_rec.ship_from_org_id      :=
                                p_atp_table.Source_Organization_Id(J);

          l_line_rec.schedule_ship_date  := p_atp_table.ship_date(J);

          /* ------------------------Bug 2327620 Start -------------------
          IF l_line_rec.latest_acceptable_date is not null THEN
              IF l_line_rec.latest_acceptable_date <
                                             l_line_rec.schedule_ship_date
              THEN
                 l_line_rec.latest_acceptable_date  :=
                                             l_line_rec.schedule_ship_date;
              END IF;
          ELSE
              OE_DEBUG_PUB.Add('Latest Acceptable Date is NULL');
              l_line_rec.latest_acceptable_date  :=
                                             l_line_rec.schedule_ship_date;
          END IF;
          ------------------------Bug 2327620 End ------------------- */

          l_line_rec.schedule_arrival_date  :=
                                    p_atp_table.ship_date(J) +
                                    nvl(p_atp_table.delivery_lead_time(J),0);

          IF p_atp_table.group_arrival_date(J) IS NOT NULL
          THEN
            l_line_rec.schedule_arrival_date :=
                                    p_atp_table.group_arrival_date(J);
            l_line_rec.schedule_ship_date :=
                l_line_rec.schedule_arrival_date -
                nvl(p_atp_table.delivery_lead_time(J),0);

          /* ------------------------Bug 2327620 Start -------------------
            IF l_line_rec.latest_acceptable_date is not null THEN
                IF l_line_rec.latest_acceptable_date <
                                             l_line_rec.schedule_arrival_date
                THEN
                   l_line_rec.latest_acceptable_date  :=
                                             l_line_rec.schedule_arrival_date;
                END IF;
            ELSE
                OE_DEBUG_PUB.Add('Latest Acceptable Date is NULL');
                l_line_rec.latest_acceptable_date  :=
                                             l_line_rec.schedule_arrival_date;
            END IF;

          ------------------------Bug 2327620 End ------------------- */

          END IF;

          IF p_atp_table.group_ship_date(J) IS NOT NULL
          THEN
            l_line_rec.schedule_ship_date := p_atp_table.group_ship_date(J);
            l_line_rec.schedule_arrival_date  :=
                                    l_line_rec.schedule_ship_date +
                                    nvl(p_atp_table.delivery_lead_time(J),0);

          /* ------------------------Bug 2327620 Start -------------------
            IF l_line_rec.latest_acceptable_date is not null THEN
                IF l_line_rec.latest_acceptable_date <
                                             l_line_rec.schedule_ship_date
                THEN
                   l_line_rec.latest_acceptable_date  :=
                                             l_line_rec.schedule_ship_date;
                END IF;
            ELSE
                OE_DEBUG_PUB.Add('Latest Acceptable Date is NULL');
                l_line_rec.latest_acceptable_date  :=
                                             l_line_rec.schedule_ship_date;
            END IF;
          ------------------------Bug 2327620 End ------------------- */
          END IF;

          IF p_atp_table.ship_method(J) IS NOT NULL THEN
             l_line_rec.shipping_method_code  := p_atp_table.ship_method(J);
          END IF;

          l_line_rec.delivery_lead_time  := p_atp_table.delivery_lead_time(J);
          l_line_rec.mfg_lead_time       := p_atp_table.atp_lead_time(J);
          l_line_rec.schedule_status_code  := OESCH_STATUS_SCHEDULED;

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'BEFORE ATTRIBUTE 05' , 5 ) ;
          END IF;

          -- bug fix 1965182/1925326
          IF p_atp_table.attribute_05.COUNT > 0 THEN
             IF p_atp_table.attribute_05(J) IS NULL THEN
                IF l_config_exists = 'N' THEN
                   l_line_rec.visible_demand_flag   := 'Y';
                ELSE
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'INSIDE CONFIG EXISTS' , 3 ) ;
                   END IF;
                END IF;

             ELSIF p_atp_table.attribute_05(J) = 'N' THEN
               l_line_rec.visible_demand_flag   := 'N';
             ELSIF p_atp_table.attribute_05(J) = 'Y' THEN
               l_line_rec.visible_demand_flag   := 'Y';
             END IF;
          ELSE
             IF l_config_exists = 'N' THEN
              l_line_rec.visible_demand_flag   := 'Y';
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

          IF  l_line_rec.ship_set_id IS NOT NULL
		AND l_line_rec.ship_set_id <> FND_API.G_MISS_NUM THEN
             l_line_rec.ship_set     := null;
          END IF;

          IF  l_line_rec.arrival_set_id IS NOT NULL
		AND l_line_rec.arrival_set_id <> FND_API.G_MISS_NUM THEN
             l_line_rec.arrival_set  := null;
          END IF;


          -- Bug 2375055 Start
          -- Adding code to trap if mrp is returning success and not
          -- returning correct data to OM.
/* Modified the following if condition to fix the bug 2919141 */
          IF (l_line_rec.schedule_ship_date is null) and (l_line_rec.ordered_quantity <> 0) THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'SCH: MRP HAS RETURNED A NULL SHIP DATE' , 2 ) ;
             END IF;
             l_line_rec.visible_demand_flag   := 'N';
             FND_MESSAGE.SET_NAME('ONT','OE_SCH_ATP_ERROR');
             OE_MSG_PUB.Add;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          -- Bug 2375055 End



        ELSIF OE_GLOBALS.Equal(l_line_rec.schedule_action_code,
                               OESCH_ACT_REDEMAND) OR
              OE_GLOBALS.Equal(l_line_rec.schedule_action_code,
                               OESCH_ACT_RESCHEDULE)
        THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LOAD THE RESULT OF RESCHEDULE' , 3 ) ;
                                    oe_debug_pub.add(  '2.REQUEST SHIP DATE :' || P_ATP_TABLE.REQUESTED_SHIP_DATE ( J ) , 3 ) ;
                                    oe_debug_pub.add(  '2.REQUEST ARRIVAL DATE :' || P_ATP_TABLE.REQUESTED_ARRIVAL_DATE ( J ) , 3 ) ;
                                            oe_debug_pub.add(  '2.SHIP DATE :' || TO_CHAR ( P_ATP_TABLE.SHIP_DATE ( J ) , 'DD-MON-RR:HH:MM:SS' ) , 3 ) ;
                                    oe_debug_pub.add(  '2.LEAD TIME :' || P_ATP_TABLE.DELIVERY_LEAD_TIME ( J ) , 3 ) ;
                                    oe_debug_pub.add(  '2.GROUP SHIP DATE :' || P_ATP_TABLE.GROUP_SHIP_DATE ( J ) , 3 ) ;
                                    oe_debug_pub.add(  '2.GROUP ARRIVAL DATE :' || P_ATP_TABLE.GROUP_ARRIVAL_DATE ( J ) , 3 ) ;
                                END IF;

          l_line_rec.ship_from_org_id :=
                                  p_atp_table.Source_Organization_Id(J);

          l_line_rec.schedule_ship_date := p_atp_table.ship_date(J);

          /* ------------------------Bug 2327620 Start -------------------
          IF l_line_rec.latest_acceptable_date is not null THEN
             IF l_line_rec.latest_acceptable_date <
                                         l_line_rec.schedule_ship_date
             THEN
               l_line_rec.latest_acceptable_date  :=
                                         l_line_rec.schedule_ship_date;
             END IF;
          ELSE
             l_line_rec.latest_acceptable_date  :=
                                         l_line_rec.schedule_ship_date;
          END IF;
          ------------------------Bug 2327620 End ------------------- */

          l_line_rec.schedule_arrival_date  :=
                                  p_atp_table.ship_date(J) +
                                  nvl(p_atp_table.delivery_lead_time(J),0);

          IF p_atp_table.group_ship_date(J) IS NOT NULL
          THEN
            l_line_rec.schedule_ship_date := p_atp_table.group_ship_date(J);
            l_line_rec.schedule_arrival_date  :=
                                    l_line_rec.schedule_ship_date +
                                    nvl(p_atp_table.delivery_lead_time(J),0);

          /* ------------------------Bug 2327620 Start -------------------
            IF l_line_rec.latest_acceptable_date is not null THEN
               IF l_line_rec.latest_acceptable_date <
                                          l_line_rec.schedule_ship_date
               THEN
                 l_line_rec.latest_acceptable_date  :=
                                         l_line_rec.schedule_ship_date;
               END IF;
            ELSE
               l_line_rec.latest_acceptable_date  :=
                                         l_line_rec.schedule_ship_date;
            END IF;
          ------------------------Bug 2327620 End ------------------- */

          END IF;

          IF p_atp_table.group_arrival_date(J) IS NOT NULL
          THEN
            l_line_rec.schedule_arrival_date :=
                                    p_atp_table.group_arrival_date(J);
            l_line_rec.schedule_ship_date :=
                l_line_rec.schedule_arrival_date -
                nvl(p_atp_table.delivery_lead_time(J),0);

          /* ------------------------Bug 2327620 Start -------------------
            IF l_line_rec.latest_acceptable_date is not null THEN
               IF l_line_rec.latest_acceptable_date <
                                     l_line_rec.schedule_ship_date
               THEN
                 l_line_rec.latest_acceptable_date  :=
                                     l_line_rec.schedule_ship_date;
               END IF;
            ELSE
               l_line_rec.latest_acceptable_date  :=
                                     l_line_rec.schedule_ship_date;
            END IF;

          ------------------------Bug 2327620 End ------------------- */
          END IF;

          IF p_atp_table.ship_method(J) IS NOT NULL THEN
             l_line_rec.shipping_method_code  := p_atp_table.ship_method(J);
          END IF;

          l_line_rec.delivery_lead_time  := p_atp_table.delivery_lead_time(J);
          l_line_rec.mfg_lead_time       := p_atp_table.atp_lead_time(J);

          -- When a new option is added to scheduled SMC/SET OM will
          -- call MRP with action re-schedule. So, for the new line we need to
          -- assign the following values.

          l_line_rec.schedule_status_code  := OESCH_STATUS_SCHEDULED;

          --- Bug 1925326
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RSCH BEFORE ATTRIBUTE 05' , 5 ) ;
          END IF;
          IF p_atp_table.attribute_05.COUNT > 0 THEN

             IF p_atp_table.attribute_05(J) IS NULL THEN

                IF l_config_exists = 'N' THEN
                   l_line_rec.visible_demand_flag   := 'Y';
                ELSE
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'RSCH INSIDE: CONFIG EXISTS' , 3 ) ;
                    END IF;
                END IF;

             ELSIF p_atp_table.attribute_05(J) = 'N' THEN
               l_line_rec.visible_demand_flag   := 'N';
             ELSIF p_atp_table.attribute_05(J) = 'Y' THEN
               l_line_rec.visible_demand_flag   := 'Y';
             END IF;
          ELSE

             -- Check if config exists. If exists then leave
             -- visible demand flag as it is.
             IF l_config_exists = 'N' THEN
                l_line_rec.visible_demand_flag   := 'Y';
             ELSE
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'RSCH: CONFIG EXISTS' , 3 ) ;
                END IF;
             END IF;

          END IF;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RSCH AFTER ATTRIBUTE 05' , 5 ) ;
          END IF;

          IF (l_line_rec.ordered_quantity = 0)
          THEN
             -- Conditional clearing code has beed added as
             -- part of CMS changes. Bug 2101332.
                         IF l_debug_level  > 0 THEN
                             oe_debug_pub.add(  'LOAD THE RESULTS OF RESCHEDULE: ' || L_LINE_REC.RE_SOURCE_FLAG , 1 ) ;
                         END IF;
             -- 2388445 commenting below code.
          /*   IF l_line_rec.re_source_flag='Y' or
                l_line_rec.re_source_flag is null THEN
                  oe_debug_pub.add('Setting Ship From to null',1);
                  l_line_rec.ship_from_org_id      := null;
             END IF; */
            l_line_rec.schedule_ship_date    := null;
            l_line_rec.schedule_arrival_date := null;
            l_line_rec.schedule_status_code  := null;
          END IF;

          -- We had set the ship_set and arrival_set (which are value
          -- fields) to the set name values for calling MRP purpose.
          -- Setting these back to null since sets defaulting logic
          -- gets fired if these values are populated.

          IF  l_line_rec.ship_set_id IS NOT NULL
		AND l_line_rec.ship_set_id <> FND_API.G_MISS_NUM THEN
             l_line_rec.ship_set     := null;
          END IF;

          IF  l_line_rec.arrival_set_id IS NOT NULL
		AND l_line_rec.arrival_set_id <> FND_API.G_MISS_NUM THEN
             l_line_rec.arrival_set  := null;
          END IF;

		IF l_line_rec.top_model_line_id = l_line_rec.line_id THEN

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'STORE ARRIVAL_DATE ' || L_LINE_REC.SCHEDULE_ARRIVAL_DATE , 2 ) ;
           END IF;
		   l_arrival_date := l_line_rec.schedule_arrival_date;

		END IF;


          -- Bug 2375055 Start
          -- Adding code to trap if mrp is returning success and not
          -- returning correct data to OM.
/* Modified the following if condition to fix the bug 2919141 */
          IF (l_line_rec.schedule_ship_date is null) and (l_line_rec.ordered_quantity <> 0) THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'SCH: MRP HAS RETURNED A NULL SHIP DATE' , 2 ) ;
             END IF;
             l_line_rec.visible_demand_flag   := 'N';
             FND_MESSAGE.SET_NAME('ONT','OE_SCH_ATP_ERROR');
             OE_MSG_PUB.Add;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          -- Bug 2375055 End


        ELSIF OE_GLOBALS.Equal(l_line_rec.schedule_action_code,
                               OESCH_ACT_UNDEMAND)
        THEN
                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  'RR2:LOAD THE RESULTS OF UNDEMAND: ' || L_LINE_REC.RE_SOURCE_FLAG , 1 ) ;
                      END IF;
          IF l_line_rec.re_source_flag='Y' or
             l_line_rec.re_source_flag is null THEN
               -- 2427769.
               IF l_line_rec.ordered_quantity > 0 THEN
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'SETTING SHIP FROM TO NULL' , 1 ) ;
                 END IF;
                 l_line_rec.ship_from_org_id      := null;
               END IF;
          END IF;
          l_line_rec.schedule_ship_date    := null;
          l_line_rec.schedule_arrival_date := null;
          l_line_rec.schedule_status_code  := null;
          l_line_rec.visible_demand_flag   := null;

          -- We had set the ship_set and arrival_set (which are value
          -- fields) to the set name values for calling MRP purpose.
          -- Setting these back to null since sets defaulting logic
          -- gets fired if these values are populated.

          IF  l_line_rec.ship_set_id IS NOT NULL
		AND l_line_rec.ship_set_id <> FND_API.G_MISS_NUM THEN
             l_line_rec.ship_set     := null;
          END IF;

          IF  l_line_rec.arrival_set_id IS NOT NULL
		AND l_line_rec.arrival_set_id <> FND_API.G_MISS_NUM THEN
             l_line_rec.arrival_set  := null;
          END IF;


        END IF;
      END IF; -- Return Status.
     END IF; -- Main If;

	-- Muti org changes.
     IF(p_atp_table.error_code(J) <> -99 ) THEN

	   ATP := ATP + 1;
        x_atp_tbl(ATP)    := l_atp_rec;

     END IF;

     <<end_loop>>

     p_x_line_tbl(I)   := l_line_rec;
 -- Modified if stmt to fix bug 2115211
     IF I < p_x_line_tbl.count AND
        l_line_rec.item_type_code <> 'CONFIG' AND
        J < p_atp_table.Identifier.count THEN
         J := J + 1;
         IF (nvl(p_atp_table.vendor_name(J),'N') = 'SMC')
         THEN

            WHILE (nvl(p_atp_table.vendor_name(J),'N') = 'SMC')
            LOOP
               J := J + 1;
		     IF p_atp_table.identifier.count < J THEN
			   GOTO END_ATP_WHILE;
		     END IF;
            END LOOP;

		  << END_ATP_WHILE >>
		  NULL;

         END IF;
     END IF;

  END LOOP;

  x_return_status := l_return_status;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING LOAD_RESULTS: ' || L_RETURN_STATUS , 1 ) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Load_Results'
            );
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'UNEXPECTED ERROR IN LOAD_RESULTS' ) ;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Load_Results;

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
      oe_debug_pub.add(  'ENTERING INSERT_INTO_MTL_SALES_ORDERS' , 1 ) ;
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
      oe_debug_pub.add(  'ORDER TYPE: ' || L_ORDER_TYPE_NAME , 1 ) ;
      oe_debug_pub.add(  'SOURCE CODE: ' || L_SOURCE_CODE , 1 ) ;
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
  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING INSERT_INTO_MTL_SALES_ORDERS' , 1 ) ;
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
FUNCTION Get_mtl_sales_order_id(p_header_id IN NUMBER)
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
   --3748723
   --4504362 : Branch scheduling code removed.
      l_sales_order_id := oe_schedule_util.Get_Mtl_Sales_Order_Id(p_header_id);
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

/*
PROCEDURE Set_Auto_Sch_From_Order_Type
(p_value_from_user  IN VARCHAR2 := FND_API.G_MISS_CHAR)
IS
BEGIN

   IF p_value_from_user <> FND_API.G_MISS_CHAR THEN
       OESCH_AUTO_SCH_FROM_OT := p_value_from_user;
   END IF;

   IF OESCH_AUTO_SCH_FLAG = 'N' OR
      OESCH_AUTO_SCH_FLAG is null
--      oe_debug_pub.add('RSF-p_value is ' || p_value);

--   OESCH_AUTO_SCH_FLAG_FROM_USER := p_value;
END Set_Auto_Sch_From_Order_Type;
*/

PROCEDURE Set_Auto_Sch_Flag
(p_value_from_user  IN VARCHAR2 := FND_API.G_MISS_CHAR)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    OESCH_AUTO_SCH_FLAG := p_value_from_user;
END Set_Auto_Sch_Flag;

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

  FOR J IN 1..p_x_line_tbl.count LOOP

     IF p_line_id = p_x_line_tbl(J).line_id THEN

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  ' LINE EXISTS IN THE TABLE' , 1 ) ;
         END IF;

         RETURN TRUE;
     END IF;
  END LOOP;

 RETURN FALSE;

END Find_line;

/*PROCEDURE PROCESS_SPLIT
  This procedure will be used to call mrp with appropriate records:
  If the ato model is part of SMC, then Whome smc model will be called
  If the ato model is part of set, then whole set information will
  be passed to MRP and so on */

PROCEDURE PROCESS_SPLIT
(p_x_line_tbl  IN OE_ORDER_PUB.Line_Tbl_Type)

IS
l_line_tbl              OE_ORDER_PUB.line_tbl_type;
l_local_line_tbl        OE_ORDER_PUB.line_tbl_type;
K                       NUMBER;
I                       NUMBER;
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


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING PROCESS SPLIT' , 1 ) ;
   END IF;

   K := 0;

   FOR I IN 1..p_x_line_tbl.count LOOP
    --bug 2669788
   if p_x_line_tbl(I).schedule_status_code is not null then
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BUG 2669788:'||P_X_LINE_TBL ( I ) .LINE_ID , 1 ) ;
   END IF;

    IF NOT find_line(p_x_line_tbl => l_line_tbl,
                     p_line_id    => p_x_line_tbl(I).line_id)
    THEN

     IF p_x_line_tbl(I).arrival_set_id is not null THEN

      OE_Set_Util.Query_Set_Rows(p_set_id   => p_x_line_tbl(I).arrival_set_id,
                                 x_line_tbl => l_local_line_tbl);


      FOR L IN 1..l_local_line_tbl.count LOOP

           K := K +1;
           l_line_tbl(K) := l_local_line_tbl(L);
           l_line_tbl(K).schedule_action_code :=
                           OE_ORDER_SCH_UTIL.OESCH_ACT_RESCHEDULE;

      END LOOP;

      l_local_line_tbl.delete;

     ELSIF p_x_line_tbl(I).ship_set_id is not null THEN


      OE_Set_Util.Query_Set_Rows(p_set_id   => p_x_line_tbl(I).ship_set_id,
                                 x_line_tbl => l_local_line_tbl);

      FOR L IN 1..l_local_line_tbl.count LOOP

           K := K +1;
           l_line_tbl(K) := l_local_line_tbl(L);
           l_line_tbl(K).schedule_action_code :=
                           OE_ORDER_SCH_UTIL.OESCH_ACT_RESCHEDULE;

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
        l_line_tbl(K).schedule_action_code :=
                           OE_ORDER_SCH_UTIL.OESCH_ACT_RESCHEDULE;
        l_line_tbl(K).ship_set := p_x_line_tbl(I).top_model_line_id;

      END LOOP;

      l_local_line_tbl.delete;

     ELSIF (p_x_line_tbl(I).ato_line_id is not null)
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
           l_line_tbl(K).schedule_action_code :=
                           OE_ORDER_SCH_UTIL.OESCH_ACT_RESCHEDULE;
           l_line_tbl(K).ship_set := l_ato_line_id;


       END LOOP;

      l_local_line_tbl.delete;


     ELSE

        K := K +1;
        l_line_tbl(K) := p_x_line_tbl(I);
        l_line_tbl(K).schedule_action_code :=
                        OE_ORDER_SCH_UTIL.OESCH_ACT_RESCHEDULE;


     END IF;

    END IF; -- line is not part of the locak table.
    END IF; --bug 2669788
   END LOOP;

   G_OVERRIDE_FLAG := 'Y';

   IF l_line_tbl.count > 0 THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'SPLIT BEFORE CALLING LOAD_MRP_REQUEST' , 2 ) ;
        END IF;
          Load_MRP_Request
          (  p_line_tbl              => l_line_tbl
           , p_old_line_tbl          => l_line_tbl
           , x_atp_table             => l_mrp_atp_rec);

          l_session_id := Get_Session_Id;

          -- Call ATP
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'COUNT IS ' || L_MRP_ATP_REC.ERROR_CODE.COUNT , 1 ) ;
          END IF;

          -- We are adding this so that we will not call MRP when
          -- table count is 0.

         IF l_mrp_atp_rec.error_code.count > 0 THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'SPLIT CALLING MRP API WITH SESSION ID '||L_SESSION_ID , 1 ) ;
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
                                                  oe_debug_pub.add(  'SPLIT. AFTER CALLING MRP_ATP_PUB.CALL_ATP' || L_RETURN_STATUS , 1 ) ;
                                              END IF;

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          Load_Results
          (  p_atp_table       => l_out_mtp_atp_rec
           , p_x_line_tbl      => l_line_tbl
           , x_atp_tbl         => l_out_atp_tbl
           , x_return_status   => l_return_status);

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
          END IF;

         END IF; -- MRP count check.


   END IF; -- line count.

   G_OVERRIDE_FLAG := 'N';
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING PROCESS SPLIT' , 1 ) ;
  END IF;
EXCEPTION
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
, x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_header_id             NUMBER;
l_p_header_id           NUMBER;
l_line_id               NUMBER;
l_demand_source_line_id NUMBER;
l_ordered_quantity      NUMBER;
l_shipped_quantity      NUMBER;
l_qty_to_transfer       NUMBER;
l_qty_to_reserve        NUMBER;
l_sales_order_id        NUMBER;
l_reserved_quantity     NUMBER;
l_qty_to_tfer_in_this_record NUMBER;
l_qty_to_retain         NUMBER;
l_count                 NUMBER;
l_x_error_code          NUMBER;
l_lock_records          VARCHAR2(1);
l_sort_by_req_date      NUMBER;
continue_loop           BOOLEAN := TRUE;
l_line_tbl              OE_ORDER_PUB.line_tbl_type;
l_out_line_tbl          OE_ORDER_PUB.line_tbl_type;
l_x_line_tbl            OE_ORDER_PUB.line_tbl_type;
l_line_rec              OE_ORDER_PUB.line_rec_type;
l_out_line_rec          OE_ORDER_PUB.line_rec_type;
l_split_line_rec        OE_ORDER_PUB.line_rec_type;
l_out_split_line_rec    OE_ORDER_PUB.line_rec_type;
K                       NUMBER;
J                       NUMBER;

-- INVCONV
l_ordered_quantity2      NUMBER;
l_shipped_quantity2      NUMBER;
l_qty2_to_transfer       NUMBER;
l_qty2_to_reserve        NUMBER;
l_reserved_quantity2     NUMBER;
l_qty2_to_tfer_in_this_record NUMBER;
l_qty2_to_retain         NUMBER;


-- Reservation API variables
l_query_rsv_rec         inv_reservation_global.mtl_reservation_rec_type;
l_rsv_rec               inv_reservation_global.mtl_reservation_rec_type;
l_rsv_new_rec           inv_reservation_global.mtl_reservation_rec_type;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(240);
l_rsv_id                NUMBER;
l_rsv_tbl               inv_reservation_global.mtl_reservation_tbl_type;
l_dummy_sn              inv_reservation_global.serial_number_tbl_type;
l_qty_reserved              NUMBER;
-- INVCONV
l_qty2_reserved              NUMBER;

-- MRP API variables
--l_session_id              NUMBER := 0;
--l_mrp_atp_rec             MRP_ATP_PUB.ATP_Rec_Typ;
--l_out_mtp_atp_rec         MRP_ATP_PUB.ATP_Rec_Typ;
--l_atp_supply_demand       MRP_ATP_PUB.ATP_Supply_Demand_Typ;
--l_atp_period              MRP_ATP_PUB.ATP_Period_Typ;
--l_atp_details             MRP_ATP_PUB.ATP_Details_Typ;
--mrp_msg_data              VARCHAR2(200);
--l_on_hand_qty             NUMBER;
--l_avail_to_reserve        NUMBER;
--l_out_atp_tbl             OE_ATP.atp_tbl_type;
l_found                   BOOLEAN := FALSE;
l_buffer                  VARCHAR2(2000);


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  '31. ENTERING SPLIT_SCHEDULING' , 1 ) ;
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
  -- We will first set the flag g_source_again to 'N' since we do not
  -- want any resoucing to happen due to a split.

  G_SOURCE_AGAIN      := 'N';
  G_OVERRIDE_FLAG     := 'Y';

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'COUNT IS :' || P_X_LINE_TBL.COUNT , 1 ) ;
  END IF;
  l_out_line_tbl := p_x_line_tbl;

  process_split(p_x_line_tbl => p_x_line_tbl);

  FOR I in 1..p_x_line_tbl.count LOOP

       IF p_x_line_tbl(I).operation = OE_GLOBALS.G_OPR_UPDATE AND
          p_x_line_tbl(I).schedule_status_code is not null AND
          p_x_line_tbl(I).split_action_code = 'SPLIT' THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'SPLITTING SCHEDULING' , 1 ) ;
              oe_debug_pub.add(  ' ' , 1 ) ;
          END IF;
          g_line_action := USER_SPLIT;

          l_line_rec := p_x_line_tbl(I);

                                               IF l_debug_level  > 0 THEN
                                                   oe_debug_pub.add(  'SPLITTING SCHEDULING FOR LINE: ' || L_LINE_REC.LINE_ID , 1 ) ;
                                               END IF;
/*
          -- This is the line which is getting split. We should
          -- reschedule the line with the new quantity.

          -- Let's first reschedule this line and then schedule
          -- the new split lines.

          -- Add the action on the line as reschedule

          l_line_rec.schedule_action_code := OESCH_ACT_RESCHEDULE;
          l_line_tbl(1)     := l_line_rec;

          Load_MRP_Request
          (  p_line_tbl              => l_line_tbl
           , p_old_line_tbl          => l_line_tbl
           , x_atp_table             => l_mrp_atp_rec);

          l_session_id := Get_Session_Id;

          -- Call ATP
          oe_debug_pub.add('Count is ' || l_mrp_atp_rec.error_code.count,1);

          -- We are adding this so that we will not call MRP when
          -- table count is 0.

         IF l_mrp_atp_rec.error_code.count > 0 THEN

          oe_debug_pub.add('1. Calling MRP API with session id '||l_session_id,1);

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


          oe_debug_pub.add('6. After Calling MRP_ATP_PUB.Call_ATP' ||
                                              l_return_status,1);

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          Load_Results
          (  p_atp_table       => l_out_mtp_atp_rec
           , p_x_line_tbl      => l_line_tbl
           , x_atp_tbl         => l_out_atp_tbl
           , x_return_status   => l_return_status);

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
          END IF;

         END IF; -- MRP count check.

          l_out_line_tbl(I) := l_line_tbl(1);
*/
          --  Resetting the action to null, before this record is passed
          -- back to the caller.
/*
          l_out_line_tbl(I).schedule_action_code := null;

          -- Now let's schedule the new split lines.
          FOR J IN 1..p_x_line_tbl.count LOOP
              IF p_x_line_tbl(J).operation = OE_GLOBALS.G_OPR_CREATE AND
                 p_x_line_tbl(J).split_from_line_id = l_line_rec.line_id
              THEN
                  l_split_line_rec := p_x_line_tbl(J);
                  oe_debug_pub.add('Split lines ship from: ' ||
                                    l_split_line_rec.ship_from_org_id,1);
                  l_out_split_line_rec := l_split_line_rec;

                  --- Bug fix for 1881229

                  l_out_split_line_rec.schedule_action_code := OESCH_ACT_SCHEDULE;
                  l_line_tbl(1) := l_out_split_line_rec;

                  Load_MRP_Request
                  (  p_line_tbl              => l_line_tbl
                   , p_old_line_tbl          => l_line_tbl
                   , x_atp_table             => l_mrp_atp_rec);


                  -- Call ATP
                  oe_debug_pub.add('Split Count is ' || l_mrp_atp_rec.error_code.count,1);

                  -- We are adding this so that we will not call MRP when
                  -- table count is 0.

                 IF l_mrp_atp_rec.error_code.count > 0 THEN

                  l_session_id := Get_Session_Id;


                  oe_debug_pub.add('2. Calling MRP API with session id '||l_session_id,1);

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


                  oe_debug_pub.add('2. After Calling MRP_ATP_PUB.Call_ATP' ||
                                              l_return_status,1);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

                  Load_Results
                  (  p_atp_table       => l_out_mtp_atp_rec
                   , p_x_line_tbl      => l_line_tbl
                   , x_atp_tbl         => l_out_atp_tbl
                   , x_return_status   => l_return_status);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                        RAISE FND_API.G_EXC_ERROR;
                  END IF;

                 END IF; -- MRP count check.

-- Bug
                  Action_Schedule
                    (p_x_line_rec    => l_out_split_line_rec,
                     p_old_line_rec  => l_split_line_rec,
                     p_action        => OESCH_ACT_SCHEDULE,
                     x_return_status => l_return_status);

                  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                        RAISE FND_API.G_EXC_ERROR;
                  END IF;

                  l_out_line_tbl(J) := l_line_tbl(1);
                  -- reset the action to null
                  l_out_line_tbl(j).schedule_action_code := null;

              END IF;
          END LOOP;
*/
        --  G_SOURCE_AGAIN      := 'Y';
        --  G_OVERRIDE_FLAG     := 'N';
          -- We have updated the demand picture in MRP with the split.
          -- Now let's update the reservation picture.

          l_query_rsv_rec.reservation_id := fnd_api.g_miss_num;

          l_sales_order_id
                     := Get_mtl_sales_order_id(l_line_rec.header_id);
          l_query_rsv_rec.demand_source_header_id  := l_sales_order_id;
          l_query_rsv_rec.demand_source_line_id    := l_line_rec.line_id;

          -- 02-jun-2000 mpetrosi added org_id to query_reservation start
          l_query_rsv_rec.organization_id  := l_line_rec.ship_from_org_id;
          -- 02-jun-2000 mpetrosi added org_id to query_reservation end


          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'CALLING INVS QUERY_RESERVATION ' , 1 ) ;
          END IF;

          inv_reservation_pub.query_reservation
              (  p_api_version_number       => 1.0
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
          l_reserved_quantity := 0;
          FOR K IN 1..l_rsv_tbl.count LOOP
              l_reserved_quantity := l_reserved_quantity +
                                     l_rsv_tbl(K).reservation_quantity;
          END LOOP;

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RESERVED QUANTITY : ' || L_RESERVED_QUANTITY , 1 ) ;
          END IF;

          IF l_reserved_quantity > 0
          THEN
             -- There can be 2 kinds of splits. One where the user split,
             -- in which case, the reservations have to split. And another
             -- when shipping occurs partially. In that case, the remaining
             -- reservations are trasferred to the new line.

            IF l_line_rec.shipped_quantity is null AND  /* shipped_quantity is null */
                    nvl(l_line_rec.shipping_interfaced_flag, 'N') = 'N' THEN
               -- If we are here, it means the split was beacuse the user
               -- split the line. We should check to see if we need to
               -- split reservations or not.
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'USER INITIATED SPLIT' , 1 ) ;
               END IF;
               IF l_line_rec.ordered_quantity > l_reserved_quantity
               THEN

                 -- The first line (which got split) is taking up all
                 -- the reservations. So we do not need to split any
                 -- reservations.

                 goto end_loop;
               END IF;

               l_qty_to_transfer := l_reserved_quantity -
                                    l_line_rec.ordered_quantity;

               l_demand_source_line_id := l_line_rec.line_id;
               l_ordered_quantity := l_line_rec.ordered_quantity;

-- INVCONV
               l_qty2_to_transfer := NVL(l_reserved_quantity2,0)  -
                                    NVL(l_line_rec.ordered_quantity2, 0);

               l_ordered_quantity2 := l_line_rec.ordered_quantity2;



                                               IF l_debug_level  > 0 THEN
                                                   oe_debug_pub.add(  'QUANTITY TO TRANSFER: ' || L_QTY_TO_TRANSFER , 1 ) ;
                                               END IF;
               K := l_rsv_tbl.first;
               J := 0;

               l_qty_to_retain := l_line_rec.ordered_quantity;
               l_qty2_to_retain := l_line_rec.ordered_quantity2; -- INVCONV

               WHILE K is not null LOOP
                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  'L2' , 1 ) ;
                   END IF;
                   l_rsv_rec := l_rsv_tbl(K);

                   l_qty_to_tfer_in_this_record :=
                             l_rsv_rec.reservation_quantity;

									 l_qty2_to_tfer_in_this_record :=   -- INVCONV -- PAL
                             l_rsv_rec.secondary_reservation_quantity;

                   -- Update this reservation and also create a
                   -- new reservation for the remaining quantity to a
                   -- new split line .

                   l_rsv_new_rec := l_rsv_rec;
                   IF l_rsv_rec.reservation_quantity <= l_ordered_quantity
                   THEN
                     IF l_rsv_rec.demand_source_line_id = l_line_rec.line_id
                     THEN
                       -- No update required.
                       l_qty_to_retain := l_qty_to_retain -
                                          l_rsv_rec.reservation_quantity;
											 l_qty2_to_retain := NVL(l_qty2_to_retain,0) -  -- INVCONV
                                          nvl(l_rsv_rec.secondary_reservation_quantity, 0);
                       l_qty_to_tfer_in_this_record := 0;
                       l_qty2_to_tfer_in_this_record := 0; -- INVCONV
                     ELSE
                       -- update reservation with the new line_id
                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'UPDATING RESERVATION ' , 1 ) ;
                       END IF;

                       l_rsv_new_rec := l_rsv_rec;
                       l_rsv_new_rec.demand_source_line_id :=
                                            l_line_rec.line_id;
                          /* OPM 14/SEP/00 send process attributes into the reservation
                       =============================================================
                       l_rsv_new_rec.attribute1 := l_line_rec.preferred_grade;
                       l_rsv_new_rec.attribute2 := l_line_rec.ordered_quantity2;
                       l_rsv_new_rec.attribute3 := l_line_rec.ordered_quantity_uom2;
	                   OPM 14/SEP/00 END        -- INVCONV
	                  ====================*/

	                  l_rsv_new_rec.secondary_reservation_quantity   := l_line_rec.ordered_quantity2; -- INVCONV
        						l_rsv_new_rec.secondary_uom_code               := l_line_rec.ordered_quantity_uom2;



                       IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  '11. CALLING INVS UPDATE RSV: ' , 1 ) ;
                       END IF;

                       inv_reservation_pub.update_reservation
                           ( p_api_version_number     => 1.0
                           , p_init_msg_lst           => fnd_api.g_true
                           , x_return_status          => l_return_status
                           , x_msg_count              => l_msg_count
                           , x_msg_data               => l_msg_data
                           , p_original_rsv_rec       => l_rsv_rec
                           , p_to_rsv_rec             => l_rsv_new_rec
                           , p_original_serial_number => l_dummy_sn
                           , p_to_serial_number       => l_dummy_sn
                           , p_validation_flag        => fnd_api.g_true
                           );

                                                 IF l_debug_level  > 0 THEN
                                                     oe_debug_pub.add(  ' 11 AFTER CALLING INVS UPD_RESERVATION: ' || L_RETURN_STATUS , 1 ) ;
                                                 END IF;

                       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
                       THEN
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                       ELSIF l_return_status = FND_API.G_RET_STS_ERROR
                       THEN
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

                       l_qty_to_tfer_in_this_record := 0;
                     END IF;
                   ELSIF l_ordered_quantity is not null THEN
                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'NEW QTY: ' || L_ORDERED_QUANTITY , 1 ) ;
                     END IF;
                     l_rsv_new_rec.reservation_quantity :=
                                            l_ordered_quantity;
                     l_rsv_new_rec.primary_reservation_quantity := fnd_api.g_miss_num;
                                   --         l_ordered_quantity;

                     l_rsv_new_rec.demand_source_line_id :=
                                            l_demand_source_line_id;

                      l_rsv_new_rec.secondary_reservation_quantity :=  -- INVCONV
                                    l_ordered_quantity2;
											l_rsv_new_rec.secondary_uom_code :=  -- INVCONV
											                                    l_line_rec.ordered_quantity_uom2;



	                /* OPM 14/SEP/00 send process attributes into the reservation
                     =============================================================
                     l_rsv_new_rec.attribute1 := l_line_rec.preferred_grade;
                     l_rsv_new_rec.attribute2 := l_line_rec.ordered_quantity2;
                     l_rsv_new_rec.attribute3 := l_line_rec.ordered_quantity_uom2;
	                 OPM 14/SEP/00 END
	                ====================*/ -- INVCONV
                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  '1. CALLING INVS UPDATE RSV: ' , 1 ) ;
                     END IF;

                     inv_reservation_pub.update_reservation
                           ( p_api_version_number     => 1.0
                           , p_init_msg_lst           => fnd_api.g_true
                           , x_return_status          => l_return_status
                           , x_msg_count              => l_msg_count
                           , x_msg_data               => l_msg_data
                           , p_original_rsv_rec       => l_rsv_rec
                           , p_to_rsv_rec             => l_rsv_new_rec
                           , p_original_serial_number => l_dummy_sn
                           , p_to_serial_number       => l_dummy_sn
                           , p_validation_flag        => fnd_api.g_true
                           );

                                                 IF l_debug_level  > 0 THEN
                                                     oe_debug_pub.add(  '1 AFTER CALLING INVS UPDATE_RESERVATION: ' || L_RETURN_STATUS , 1 ) ;
                                                 END IF;

                     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
                     THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     ELSIF l_return_status = FND_API.G_RET_STS_ERROR
                     THEN
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

                     l_qty_to_tfer_in_this_record :=
                                   l_qty_to_tfer_in_this_record -
                                   l_ordered_quantity;

                     l_qty_to_retain :=  l_ordered_quantity -
                                          l_rsv_rec.reservation_quantity;

                     l_ordered_quantity := 0;


										 l_qty2_to_tfer_in_this_record :=  -- INVCONV
                                   nvl(l_qty2_to_tfer_in_this_record, 0) -
                                   nvl(l_ordered_quantity2, 0);

                     l_qty2_to_retain :=  nvl(l_ordered_quantity2, 0) -
                                          nvl(l_rsv_rec.secondary_reservation_quantity, 0);

                     l_ordered_quantity2 := 0;


                   END IF;

                   -- If there is any qty left in the reservation record
                   -- which needs to be transferred, let's find a split line
                   -- for it.

                                              IF l_debug_level  > 0 THEN
                                                  oe_debug_pub.add(  '2. QTY TO XFER IN THIS RSV :' || L_QTY_TO_TFER_IN_THIS_RECORD ) ;
                                              END IF;
                   <<find_split_line>>
                   IF l_qty_to_tfer_in_this_record > 0
                   THEN

                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  '1. FINDING THE NEXT SPLIT LINE' , 1 ) ;
                      END IF;
                      IF l_ordered_quantity <= 0 THEN
                        J := J + 1;
                        continue_loop := TRUE;
                        WHILE J <= p_x_line_tbl.count AND continue_loop
                        LOOP
                          IF p_x_line_tbl(J).operation =
                                               OE_GLOBALS.G_OPR_CREATE AND
                             p_x_line_tbl(J).split_from_line_id =
                                               l_line_rec.line_id
                          THEN
                             continue_loop := FALSE;
                          ELSE
                             J := J + 1;
                          END IF;
                        END LOOP;

                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'FOUND THE NEXT SPLIT LINE' , 1 ) ;
                        END IF;
                        l_split_line_rec := p_x_line_tbl(J);


                        -- We can transfer the whole of the remaining qty to
                        -- this new split line.

                        l_demand_source_line_id := l_split_line_rec.line_id;
                        l_ordered_quantity      :=
                                            l_split_line_rec.ordered_quantity;
												l_ordered_quantity2      :=  -- INVCONV
                                            l_split_line_rec.ordered_quantity2;
                      END IF;

                   -- We have found a record to which we should transfer the
                   -- reservation. If the amount we need to reserve is more
                   -- than the amount on this new split line, we will look for
                   -- next split line to transfer the reservation to.


                      IF l_ordered_quantity < l_qty_to_tfer_in_this_record
                      THEN
                        l_qty_to_reserve := l_ordered_quantity;
                        l_qty_to_tfer_in_this_record :=
                                l_qty_to_tfer_in_this_record -
                                l_ordered_quantity;
                        l_ordered_quantity := 0;
                      ELSE
                        l_qty_to_reserve := l_qty_to_tfer_in_this_record;
                        l_qty_to_tfer_in_this_record := 0;
                        l_ordered_quantity := l_ordered_quantity -
                                               l_qty_to_tfer_in_this_record;
                      END IF;

											IF l_ordered_quantity2 < l_qty2_to_tfer_in_this_record
                      THEN
                        l_qty2_to_reserve := l_ordered_quantity2;
                        l_qty2_to_tfer_in_this_record :=
                                l_qty2_to_tfer_in_this_record -
                                l_ordered_quantity2;
                        l_ordered_quantity2 := 0;
                      ELSE
                        l_qty2_to_reserve := l_qty2_to_tfer_in_this_record;
                        l_qty2_to_tfer_in_this_record := 0;
                        l_ordered_quantity2 := nvl(l_ordered_quantity2,0) -
                                               nvl(l_qty2_to_tfer_in_this_record, 0);
                      END IF;

                      l_rsv_new_rec                 := l_rsv_rec;
                      l_rsv_new_rec.reservation_id  := fnd_api.g_miss_num;
                      l_rsv_new_rec.reservation_quantity :=
                                             l_qty_to_reserve;
                      l_rsv_new_rec.secondary_reservation_quantity :=  -- INVCONV
                                             l_qty2_to_reserve;
                      l_rsv_new_rec.secondary_uom_code := l_split_line_rec.ordered_quantity_uom2; -- INVCONV
                      l_rsv_new_rec.primary_reservation_quantity := NULL;
                                            -- l_qty_to_reserve;
                      l_rsv_new_rec.demand_source_line_id :=
                                             l_split_line_rec.line_id;

                      -- Call INV's API to Create Reservation.

                                        IF l_debug_level  > 0 THEN
                                            oe_debug_pub.add(  'CREATING A NEW RESERVATION FOR : ' || L_QTY_TO_RESERVE || ' WITH LINE ID ' || L_SPLIT_LINE_REC.LINE_ID , 1 ) ;
                                        END IF;

                      inv_reservation_pub.create_reservation
                         (  p_api_version_number        => 1.0
                          , p_init_msg_lst              => FND_API.G_TRUE
                          , x_return_status             => l_return_status
                          , x_msg_count                 => l_msg_count
                          , x_msg_data                  => l_msg_data
                          , p_rsv_rec                   => l_rsv_new_rec
                          , p_serial_number             => l_dummy_sn
                          , x_serial_number             => l_dummy_sn
                          , p_partial_reservation_flag  => FND_API.G_FALSE
                          , p_force_reservation_flag    => FND_API.G_FALSE
                          , p_validation_flag           => FND_API.G_TRUE
                          , x_quantity_reserved         => l_qty_reserved
                          , x_secondary_quantity_reserved        => l_qty2_reserved -- INVCONV

                          , x_reservation_id            => l_rsv_id);

                                              IF l_debug_level  > 0 THEN
                                                  oe_debug_pub.add(  '5. AFTER CALLING CREATE RESERVATION' || L_RETURN_STATUS , 1 ) ;
                           oe_debug_pub.add(  L_MSG_DATA , 1 ) ;
                       END IF;

                      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
                      THEN
                         IF l_debug_level  > 0 THEN
                             oe_debug_pub.add(  'UNEXP ERROR : '|| L_MSG_DATA , 1 ) ;
                         END IF;
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
                         -- Need to raise an error, if we are not able to
                         -- transfer from parent record.
                         RAISE FND_API.G_EXC_ERROR;
                      END IF;

                      IF l_qty_to_tfer_in_this_record > 0
                      THEN
                        -- The new split line's ordered quantity is less
                        -- the quantity of reservation which needs to be
                        -- transferred. So let's try to find the next record
                        -- to transfer the the qty to.

                        goto find_split_line;

                      END IF;

                   END IF; /*  l_qty_to_tfer_in_this_record > 0 */

                   l_rsv_tbl.delete(K);
                   K := l_rsv_tbl.next(K);

               END LOOP;
             END IF; /* shipped_quantity is null AND not yet interfaced to WSH */

          END IF; /* reserved_quantity > 0 */

       END IF; /* If operation on the line was UPDATE */

       <<end_loop>>
       null;
  END LOOP;

  g_line_action := '';

  -- Reset the global flags

  G_SOURCE_AGAIN      := 'Y';
  G_OVERRIDE_FLAG     := 'N';

  p_x_line_tbl      := l_out_line_tbl;
  x_return_status := l_return_status;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SCHEDULING RESULTS OF THE LINES: ' , 1 ) ;
      oe_debug_pub.add(  ' ' , 1 ) ;
  END IF;

  FOR I IN 1..l_out_line_tbl.count LOOP
                            IF l_debug_level  > 0 THEN
                                oe_debug_pub.add(  'LINE ID : ' || L_OUT_LINE_TBL ( I ) .LINE_ID , 1 ) ;
                                oe_debug_pub.add(  'SCHEDULE STATUS : ' || L_OUT_LINE_TBL ( I ) .SCHEDULE_STATUS_CODE , 1 ) ;
          oe_debug_pub.add(  ' ' , 1 ) ;
      END IF;
  END LOOP;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING SPLIT_SCHEDULING WITH ' || L_RETURN_STATUS , 1 ) ;
      oe_debug_pub.add(  ' ' , 1 ) ;
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

END SPLIT_SCHEDULING;

/*--------------------------------------------------------------------------
Procedure Name : SPLIT_RESERVATIONS
Description    : ** Currently not used. **
-------------------------------------------------------------------------- */

Procedure SPLIT_RESERVATIONS
( p_reserved_line_id   IN  NUMBER
, p_ordered_quantity   IN  NUMBER
, p_reserved_quantity  IN  NUMBER
, x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_header_id             NUMBER;
l_p_header_id           NUMBER;
l_line_id               NUMBER;
l_ordered_quantity      NUMBER;
l_shipped_quantity      NUMBER;
l_sales_order_id        NUMBER;
l_count                 NUMBER;
l_x_error_code          NUMBER;
l_lock_records          VARCHAR2(1);
l_sort_by_req_date      NUMBER;

l_rsv_rec               inv_reservation_global.mtl_reservation_rec_type;
l_rsv_new_rec           inv_reservation_global.mtl_reservation_rec_type;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(240);
l_rsv_id                NUMBER;
l_rsv_tbl               inv_reservation_global.mtl_reservation_tbl_type;
l_dummy_sn              inv_reservation_global.serial_number_tbl_type;

l_buffer                VARCHAR2(2000);
l_ship_from_org_id      NUMBER;

cursor split_lines
IS select header_id,
          line_id ,
          ordered_quantity,
          shipped_quantity
   from oe_order_lines where
   split_from_line_id = p_reserved_line_id;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   -- Query the reserved records

   BEGIN
      SELECT header_id, ship_from_org_id
      into l_p_header_id, l_ship_from_org_id
      from oe_order_lines
      where line_id = p_reserved_line_id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   l_sales_order_id                   := Get_mtl_sales_order_id(l_header_id);
   l_rsv_rec.demand_source_header_id  := l_sales_order_id;
   l_rsv_rec.demand_source_line_id    := p_reserved_line_id;
   l_rsv_rec.organization_id          := l_ship_from_org_id;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CALLING INVS QUERY_RESERVATION ' , 1 ) ;
   END IF;

   inv_reservation_pub.query_reservation
       (  p_api_version_number        => 1.0
       , p_init_msg_lst              => fnd_api.g_true
       , x_return_status             => l_return_status
       , x_msg_count                 => l_msg_count
       , x_msg_data                  => l_msg_data
       , p_query_input               => l_rsv_rec
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
       oe_debug_pub.add(  'COUNT IS RESERVATION RECORDS IS' || L_RSV_TBL.COUNT , 1 ) ;
   END IF;

   -- There can be 2 kinds of splits. One where the use split,
   -- in which case, the reservations have to split. And another
   -- when shipping occurs partially. In that case, the remaining
   -- reservation is trasferred to the new line.

  OPEN split_lines;

  LOOP

    FETCH split_lines
    INTO
    l_header_id,l_line_id,l_ordered_quantity, l_shipped_quantity;
    EXIT WHEN split_lines%NOTFOUND;

    IF l_shipped_quantity is not null THEN
       -- This is the case where line was split due to shipping

       FOR I IN 1..l_rsv_tbl.COUNT LOOP

           l_rsv_rec := l_rsv_tbl(I);

           l_rsv_new_rec                  := l_rsv_rec;
           l_rsv_new_rec.demand_source_line_id := l_line_id;

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'CALLING INVS UPDATE_RESERVATION: ' , 1 ) ;
           END IF;

           inv_reservation_pub.update_reservation
           ( p_api_version_number        => 1.0
           , p_init_msg_lst              => fnd_api.g_true
           , x_return_status             => l_return_status
           , x_msg_count                 => l_msg_count
           , x_msg_data                  => l_msg_data
           , p_original_rsv_rec          => l_rsv_rec
           , p_to_rsv_rec                => l_rsv_new_rec
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

    ELSE
       -- This is the case where line was split by the user
       null;
    END IF;
  END LOOP;

   x_return_status := l_return_status;

END SPLIT_RESERVATIONS;

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
, x_msg_count     OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_msg_data      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
l_schedule_line_rec         request_rec_type;
l_line_rec                  OE_ORDER_PUB.line_rec_type;
l_sch_rec                   sch_rec_type;
I                           NUMBER;
l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count                 NUMBER := 0;
l_msg_data                  VARCHAR2(2000) := null;
l_control_rec               OE_GLOBALS.control_rec_type;
l_line_tbl                  OE_ORDER_PUB.line_tbl_type;
l_old_line_tbl              OE_ORDER_PUB.line_tbl_type;
l_mrp_line_tbl              OE_SCHEDULE_UTIL.mrp_line_tbl_type;
/*
l_header_out_rec            OE_Order_PUB.Header_Rec_Type;
l_header_rec                OE_Order_PUB.Header_Rec_Type;
l_line_out_tbl              OE_Order_PUB.Line_Tbl_Type;
l_header_adj_out_tbl        OE_Order_PUB.Header_Adj_Tbl_Type;
l_header_scredit_out_tbl    OE_Order_PUB.Header_Scredit_Tbl_Type;
l_line_adj_out_tbl          OE_Order_PUB.Line_Adj_Tbl_Type;
l_line_scredit_out_tbl      OE_Order_PUB.Line_Scredit_Tbl_Type;
l_lot_serial_out_tbl        OE_Order_PUB.Lot_Serial_Tbl_Type;
l_action_request_out_tbl    OE_Order_PUB.Request_Tbl_Type;
l_Header_Adj_Att_tbl        OE_ORDER_PUB.Header_Adj_Att_Tbl_Type;
l_Header_Adj_Assoc_tbl      OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type;
l_Header_price_Att_tbl      OE_ORDER_PUB.Header_Price_Att_Tbl_Type;
l_Line_Price_Att_tbl        OE_ORDER_PUB.Line_Price_Att_Tbl_Type;
l_Line_Adj_Att_tbl          OE_ORDER_PUB.Line_Adj_Att_Tbl_Type;
l_Line_Adj_Assoc_tbl        OE_ORDER_PUB.Line_Adj_Assoc_Tbl_Type;
*/
l_file_val                  VARCHAR2(80);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


--     l_file_val := OE_DEBUG_PUB.Set_Debug_Mode('FILE');
--     OE_DEBUG_PUB.Initialize;
--     OE_DEBUG_PUB.Debug_Off;
--     OE_DEBUG_PUB.Debug_On;
--     oe_Debug_pub.setdebuglevel(5);

   -- 4504362 : Branch scheduling check removed.

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'BEFORE CALLING NEW CODE' , 1 ) ;
   END IF;

   FOR I in 1..p_mrp_line_tbl.count LOOP

   l_mrp_line_tbl(I).line_id := p_mrp_line_tbl(I).line_id;
   l_mrp_line_tbl(I).schedule_ship_date := p_mrp_line_tbl(I).schedule_ship_date;
   l_mrp_line_tbl(I).schedule_arrival_date := p_mrp_line_tbl(I).schedule_arrival_date;
   l_mrp_line_tbl(I).ship_from_org_id := p_mrp_line_tbl(I).ship_from_org_id;
   l_mrp_line_tbl(I).ship_method_code := p_mrp_line_tbl(I).ship_method_code;
   END LOOP;

   OE_SCHEDULE_UTIL.Update_Results_from_backlog_wb
   (p_mrp_line_tbl  => l_mrp_line_tbl,
    x_msg_count     => x_msg_count,
    x_msg_data      => x_msg_data,
    x_return_status => x_return_status);

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'X_RETURN_STATUS IS ' || X_RETURN_STATUS , 1 ) ;
    END IF;


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING UPDATE_RESULTS_FROM_BACKLOG_WB' , 1 ) ;
    END IF;
    OE_DEBUG_PUB.Debug_Off;
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
            ,   'Schedule_line'
            );
        END IF;
END Update_Results_from_backlog_wb;

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

--  IF MRP_SESSION_ID = 0 THEN
      SELECT mrp_atp_schedule_temp_s.nextval
      INTO MRP_SESSION_ID
      from dual;
--  END IF;

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
x_return_status           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
          oe_debug_pub.add(  '1.. CALLING CTO GET_BOM_MANDATORY_COMPS' , 1 ) ;
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
          oe_debug_pub.add(  '1. AFTER CALLING CTO API : ' || L_RESULT , 1 ) ;
          oe_debug_pub.add(  'COUNT IS: ' || L_SMC_REC.INVENTORY_ITEM_ID.COUNT , 1 ) ;
      END IF;

      EXCEPTION
         WHEN OTHERS THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'CTO API RETURNED AN UNEXPECTED ERROR' ) ;
              END IF;
              l_result := 0;
      END;

/*
      IF l_result <> 1 THEN
              IF lErrorMessage is not null THEN
                  oe_msg_pub.add_text(p_message_text => lErrorMessage);
              END IF;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
*/

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
      oe_debug_pub.add(  'ENTERING OE_ORDER_SCH_UTIL.UPDATE_PO' , 2 ) ;
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
      oe_debug_pub.add(  'EXITING OE_ORDER_SCH_UTIL.UPDATE_PO' , 1 ) ;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'EXCEPTION IN UPDATE_PO' , 2 ) ;
         END IF;
END Update_PO;

Procedure Delete_Row(p_line_id      IN NUMBER)
IS
l_line_rec               OE_ORDER_PUB.line_rec_type;
l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_sales_order_id         NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_ORDER_SCH_UTIL.DELETE_ROW' , 1 ) ;
  END IF;
  OE_Line_Util.Query_Row(p_line_id    => p_line_id,
                         x_line_rec   => l_line_rec);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ITEM TYPE :' || L_LINE_REC.ITEM_TYPE_CODE , 1 ) ;
  END IF;

  /* Fix for bug 2643593, reservations to be removed only for
     shippable line */

  IF nvl(l_line_rec.shippable_flag,'N') = 'Y' THEN

    l_sales_order_id := OE_ORDER_SCH_UTIL.Get_mtl_sales_order_id
                                              (l_line_rec.HEADER_ID);

    -- INVCONV - MERGED CALLS	 FOR OE_LINE_UTIL.Get_Reserved_Quantity and OE_LINE_UTIL.Get_Reserved_Quantity2

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
		l_line_rec.reserved_quantity2 := -- INVCONV
              OE_LINE_UTIL.Get_Reserved_Quantity2
                 (p_header_id   => l_sales_order_id,
                  p_line_id     => l_line_rec.line_id,
                  p_org_id      => l_line_rec.ship_from_org_id); */

     IF l_line_rec.reserved_quantity is not null AND
        nvl(l_line_rec.shipping_interfaced_flag, 'N') = 'N'
     THEN
       -- Call INV to delete the old reservations
       Unreserve_Line
        (p_line_rec              => l_line_rec,
         p_quantity_to_unreserve => l_line_rec.reserved_quantity,
         p_quantity2_to_unreserve => l_line_rec.reserved_quantity2, -- INVCONV

         x_return_status         => l_return_status);
     END IF;

  END IF; /* Check for shippable flag */

  -- To fix bug 2060293
  IF l_line_rec.item_type_code <> OE_GLOBALS.G_ITEM_CONFIG THEN
     Action_Undemand(p_old_line_rec  => l_line_rec,
                     x_return_status => l_return_status);
  END IF;


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_ORDER_SCH_UTIL.DELETE_ROW' , 1 ) ;
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
END Delete_Row;

-- added by fabdi 03/May/2001 - For process ATP
/*--------------------------------------------------------------------------
Procedure Name : get_process_query_quantities
Description    :  This precedure works out the on_hand_qty and avail_to_reserve
quanties to display in the same ATP window for process inventory only. The procedure
takes into account grade controlled items and displays inventory result for a particular
grade as well a total sum if grade is null.
This procedure is called from Query_Qty_Tree only
-------------------------------------------------------------------------- INVCONV  - NOT USED NOW

PROCEDURE get_process_query_quantities
  (   p_org_id       IN  NUMBER
   ,  p_item_id      IN  NUMBER
   ,  p_line_id      IN  NUMBER
   ,  x_on_hand_qty  OUT NOCOPY NUMBER
   ,  x_avail_to_reserve OUT NOCOPY NUMBER
  ) IS

  l_on_hand_qty2          NUMBER;
  l_avail_to_reserve2     NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INSIDE GET_PROCESS_QUERY_QUANTITIES ' ) ;
        oe_debug_pub.add(  'P_LINE_ID - IN GET_PROCESS_QUERY_QUANTITIES IS: '|| P_LINE_ID ) ;
    END IF;
    GMI_RESERVATION_PVT.query_qty_for_ATP
         ( p_organization_id         => p_org_id
         , p_item_id                 => p_item_id
         , p_demand_source_line_id   => p_line_id
         , x_onhand_qty1             => x_on_hand_qty
         , x_onhand_qty2             => l_on_hand_qty2
         , x_avail_qty1              => x_avail_to_reserve
         , x_avail_qty2              => l_avail_to_reserve2
         );


   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'POCESS X_ON_HAND_QTY IS: '|| X_ON_HAND_QTY ) ;
       oe_debug_pub.add(  'PROCESS X_AVAIL_TO_RESERVE IS: '|| X_AVAIL_TO_RESERVE ) ;
   END IF;

END get_process_query_quantities;      */
-- end fabdi

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
 |		   If there is no sufficient Qty for   |
 |		   reservation then the Inventory      |
 |		   populates a pl-sql table. Before    |
 |                 commit we check if the pl-sql table |
 | 		   is NOT Null or not.		       |
 +-----------------------------------------------------*/

Procedure Post_Forms_Commit
(x_return_status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,x_msg_count      OUT NOCOPY /* file.sql.39 change */ NUMBER
,x_msg_data       OUT NOCOPY /* file.sql.39 change */ VARCHAR2) IS
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
--    OESCH_PERFORMED_RESERVATION := 'N';

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


END OE_ORDER_SCH_UTIL;

/
