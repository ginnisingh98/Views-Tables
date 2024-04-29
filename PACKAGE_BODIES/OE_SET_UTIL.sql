--------------------------------------------------------
--  DDL for Package Body OE_SET_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SET_UTIL" AS
/* $Header: OEXUSETB.pls 120.10.12010000.7 2010/05/07 06:30:55 spothula ship $ */


G_PKG_NAME      CONSTANT    VARCHAR2(30):='OE_Line_Set';

 --Bug4080531
 --g_set_rec OE_ORDER_CACHE.set_rec_type;

 g_cust_pref_set boolean := FALSE;
 g_old_line_tbl OE_ORDER_PUB.Line_tbl_Type;
 g_process_options boolean := TRUE;
 g_old_arrival_set_path boolean := FALSE;

Procedure Validate_Fulfillment_Set
( p_x_line_rec   IN OUT NOCOPY oe_order_pub.line_rec_type,
  p_old_line_rec IN oe_order_pub.line_rec_type,
  p_system_set   IN VARCHAR2 DEFAULT 'N'
);

FUNCTION IS_SET_CLOSED(p_set_id number)
return BOOLEAN
IS
l_set_rec OE_ORDER_CACHE.set_rec_type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
l_set_rec := get_set_rec(p_set_id);
IF l_set_rec.set_status = 'C' THEN
RETURN TRUE;
ELSE
RETURN FALSE;
END IF;

RETURN FALSE;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

     RAISE FND_API.G_EXC_ERROR;


    WHEN OTHERS THEN

     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Is Set Closed'
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END IS_SET_CLOSED;

FUNCTION Get_Fulfillment_Set(p_line_id NUMBER,
				        p_set_id NUMBER)
RETURN BOOLEAN
IS
lcount number := 0;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

-- 4236316 start
select 1
into lcount
from dual
where exists (select 1
              from oe_line_sets
              where set_id = p_set_id
              and line_id = p_line_id);

-- 4236316 end


IF lcount > 0 THEN
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'THIS LINE EXIST IN FULLFILLMENT SET' ) ;
END IF;
RETURN TRUE;
ELSE
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'DOES NOT EXIST' ) ;
END IF;
RETURN FALSE;
END IF;

Exception
    WHEN FND_API.G_EXC_ERROR THEN

     RAISE FND_API.G_EXC_ERROR;

WHEN NO_DATA_FOUND THEN
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'DOES NOT EXIST- IN NO DATA FOUND' ) ;
END IF;
    RETURN FALSE;

End  Get_Fulfillment_Set;


Procedure Validate_ShipSet
( p_line_rec       IN    OE_Order_PUB.Line_Rec_Type
 ,p_old_line_rec   IN    OE_Order_PUB.Line_Rec_Type
 ,x_return_status  OUT   NOCOPY   VARCHAR2
  )
IS
  l_debug_level      CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_shipset_enforce  VARCHAR2(1);
  l_set_name         VARCHAR2(30);
  l_ship_set         NUMBER := 0;
BEGIN

    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    IF l_debug_level > 0 then
       OE_DEBUG_PUB.Add('Entering OE_SET_UTIL.Validate_Shipset',1);
    END IF;

    -- Select statement to check the Ship Set Enforce Parameter.
    BEGIN
        SELECT Enforce_Ship_Set_And_Smc
          INTO l_shipset_enforce
          FROM Wsh_Shipping_Parameters
          WHERE Organization_Id = p_line_rec.ship_from_org_Id;
    EXCEPTION
         WHEN NO_DATA_FOUND THEN
              NULL;
         WHEN OTHERS THEN
              NULL;
    END;


    IF NOT OE_GLOBALS.Equal(p_line_rec.ship_set_id,
                            p_old_line_rec.ship_set_id) THEN

       -- Select statement to check whether the set is pick released.
/*
       SELECT  count(*)
         INTO  l_ship_set
         FROM  Wsh_Delivery_Details
        WHERE  Ship_Set_Id = p_line_rec.ship_set_id
          AND  Source_Code = 'OE'
          AND  Source_Header_Id = p_line_rec.header_id
          AND  Released_Status In ('S','Y','C')
          AND  ROWNUM = 1;  -- 3229707 Removed 'B' from Released_Status check
*/

        SELECT count(*)
        INTO   l_ship_set
        FROM   wsh_delivery_details wdd
        WHERE  wdd.ship_set_id = p_line_rec.ship_set_id
        AND    wdd.source_code = 'OE'
        AND    wdd.source_header_id = p_line_rec.header_id
        AND   ((wdd.released_status = 'C')
        OR EXISTS (select wda.delivery_detail_id
        FROM   wsh_delivery_assignments wda, wsh_new_deliveries wnd
        WHERE  wda.delivery_detail_id = wdd.delivery_detail_id
        AND    wda.delivery_id = wnd.delivery_id
        AND    wnd.status_code in ('CO', 'IT', 'CL', 'SA')))
        AND rownum = 1;

       IF  l_ship_set > 0 AND l_shipset_enforce = 'Y' THEN
               FND_MESSAGE.Set_Name ('ONT','ONT_SET_PICK_RELEASED');
               BEGIN
                SELECT SET_NAME
                INTO l_set_name
                FROM OE_SETS
                WHERE set_id = p_line_rec.ship_set_id;
               EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  l_set_name := null;
               END;
               x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

    END IF;
    IF l_debug_level > 0 then
       OE_DEBUG_PUB.Add('Exiting OE_SET_UTIL.Validate_Shipset:'
                                                     ||x_return_status,1);
    END IF;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
           if l_debug_level > 0 then
                OE_DEBUG_PUB.Add('Expected Error in Validate_Shipset ',2);
           End if;

           x_return_status := FND_API.G_RET_STS_ERROR;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           if l_debug_level > 0 then
              OE_DEBUG_PUB.Add('Unexpected Error in Validate_Shipset:'||SqlErrm, 1);
           End if;

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
              THEN
               OE_MSG_PUB.Add_Exc_Msg
                               (   'OE_SET_UTIL',
                                  'Validate_Shipset');
           END IF;
END Validate_Shipset;


Function Is_Service_Eligible (p_line_rec IN OE_Order_Pub.Line_Rec_Type)
RETURN BOOLEAN
IS
l_header_id Number;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

   IF l_debug_level > 0 then
       OE_DEBUG_PUB.Add('Entering Is_Service_Eligible',1);
   END IF;

   IF p_line_rec.SERVICE_REFERENCE_TYPE_CODE <> 'ORDER'
   THEN

      RETURN TRUE;
   ELSE

      BEGIN

        Select header_id
        Into   l_header_id
        From   oe_order_lines_all
        Where  line_id = p_line_rec.service_reference_line_id;

      END;
      IF p_line_rec.header_id = l_header_id THEN

         RETURN FALSE;
      ELSE

         RETURN TRUE;
      END IF;
   END IF;

   RETURN FALSE;
EXCEPTION
     WHEN OTHERS THEN
           IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
              THEN
               OE_MSG_PUB.Add_Exc_Msg
                               (   'OE_SET_UTIL',
                                  'Is_Service_Eligible');
           END IF;
           RETURN FALSE;
END Is_Service_Eligible;

Procedure Create_Fulfillment_Set(p_line_id NUMBER,
                                 -- 4925992
                                 p_top_model_line_id NUMBER := NULL,
                                 p_set_id NUMBER) IS
l_set_rec OE_ORDER_CACHE.set_rec_type;
x_msg_count number;
x_msg_data varchar2(2000);
Cursor C1 is
Select line_id from
oe_order_lines_all where
top_model_line_id = p_line_id and
--item_type_code = 'INCLUDED' and
nvl(cancelled_flag,'N') <> 'Y' and
nvl(model_remnant_flag,'N') <> 'Y' and
line_id not in
(select line_id from oe_line_sets where
set_id = p_set_id );
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

l_set_s VARCHAR2(2); --bug8420761
--
BEGIN

IF NOT Get_Fulfillment_Set(p_line_id => p_line_id,
					p_set_id => p_set_id) THEN

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'CREATE FULLFILLMENT SET' ) ;
END IF;

l_set_rec := get_set_rec(p_set_id);

-- Begin changes for bug8420761
 BEGIN
          oe_debug_pub.add('Locking The Set Status ');

         SELECT set_status
	   INTO l_set_s
	   FROM oe_sets
	  WHERE set_id = p_set_id
	    FOR UPDATE NOWAIT;

       EXCEPTION
         WHEN Others THEN
          l_set_s := 'U'  ;
          oe_debug_pub.add('Error while locking Set status : '||SQLERRM);
          fnd_message.set_name('ONT', 'OE_SET_LOCKED');
          oe_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR ;
       END;

	   oe_debug_pub.add('Create_Fulfillment_Set:'||OE_Set_util.g_set_rec.set_status ||' l_set_s ' || l_set_s);

-- End changes for bug8420761

	IF is_set_closed(p_set_id => p_set_id) THEN
          fnd_message.set_name('ONT', 'OE_SET_CLOSED');
         	FND_MESSAGE.SET_TOKEN('SET',
          l_set_rec.set_name);
          oe_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR ;
		END IF;

Insert into oe_line_sets(
Line_id,
Set_id,
SYSTEM_REQUIRED_FLAG )
Values
(p_line_id,
p_set_id,
'Y');

-- 4925992
IF p_top_model_line_id IS NOT NULL THEN
   FOR c1rec in C1
   loop

      Insert into oe_line_sets(Line_id,
                               Set_id,
                               SYSTEM_REQUIRED_FLAG )
      Values (c1rec.line_id,
              p_set_id,
              'Y');

   end loop;
END IF;


END IF;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXIT - CREATE FULLFILLMENT SET' ) ;
END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN


        --  Get message count and data
        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'IN FULFILLMENT CREATE EXCEPTION ' , 1 ) ;
     END IF;

     RAISE FND_API.G_EXC_ERROR;


    WHEN OTHERS THEN

     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Create_Fulfillment_Set'
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End Create_Fulfillment_Set;

/* Fulfill_Sts was added for 2525203 to get status of FULFILL_LINE activity */
Function Fulfill_Sts(p_line_id IN NUMBER) RETURN VARCHAR2 IS

  l_activity_status               VARCHAR2(8);
  l_activity_result               VARCHAR2(30);
  l_activity_id                   NUMBER;
  l_return_status                 VARCHAR2(1);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTER OE_SET_UTIL.FULFILL_STS' , 5 ) ;
  END IF;
  OE_LINE_FULLFILL.Get_Activity_Result (
	    p_item_type                     => OE_GLOBALS.G_WFI_LIN
    ,       p_item_key                      => to_char(p_line_id)
    ,       p_activity_name                 => 'FULFILL_LINE'
    ,       x_return_status                 => l_return_status
    ,       x_activity_result               => l_activity_result
    ,       x_activity_status_code          => l_activity_status
    ,       x_activity_id                   => l_activity_id);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'RETURN STATUS FROM GET ACTIVITY RESULT : '||L_RETURN_STATUS , 5 ) ;
  END IF;

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS AND
        nvl(l_activity_status,'ERROR') = 'NOTIFIED' THEN
    NULL;
  ELSE
    l_activity_status := 'ERROR';
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXIT OE_SET_UTIL.FULFILL_STS:'||L_ACTIVITY_STATUS , 5 ) ;
  END IF;
  RETURN l_activity_status;

END Fulfill_Sts;

Procedure Delete_Fulfillment_Set(p_line_id NUMBER,
				 p_set_id  NUMBER) IS
l_return_status varchar2(30);
-- l_line_rec oe_order_pub.line_rec_type;  removed for 2525203
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF Get_Fulfillment_Set(p_line_id => p_line_id,
			 p_set_id => p_set_id) THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'DELETE FULLFILLMENT SET' ) ;
    END IF;

    /* The next check is redundant and harmful if a child line is being deleted from
       set. The check has already been done in process_sets(). Commented for 2525203.
    -- See if this is already fulfilled .  if fulfilled raise error
    oe_line_util.query_row(p_line_id => p_line_id,
			   x_line_rec => l_line_rec);
    IF (nvl(l_line_rec.fulfilled_flag,'N') = 'Y') THEN
          fnd_message.set_name('ONT', 'OE_LINE_FULFILLED');
          oe_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR ;
    END IF;
    2525203 */

    /*Delete oe_line_sets
      Where line_id = p_line_id
      and set_id = p_set_id;*/

    -- Call this fulfillment api for removal of sets
    -- Bug 2068310: Pass 'Y' to a newly added IN parameter p_operation_fulfill.

    oe_line_fullfill.cancel_line(p_line_id => p_line_id,
                                 x_return_status => l_return_status,
                                 p_fulfill_operation => 'Y',
                                 p_set_id => p_set_id);  -- p_set_id added for 2525203

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
                if l_return_status = FND_API.G_RET_STS_ERROR then
                   raise FND_API.G_EXC_ERROR;
                else
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                end if;
    end if;

    -- 2695403
    g_set_rec := OE_ORDER_CACHE.Load_Set(p_set_id); -- refresh the cache record
    ---

    Delete oe_line_sets
    Where line_id = p_line_id
    and set_id = p_set_id;

  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXIT - DELETE FULLFILLMENT SET' ) ;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

     RAISE FND_API.G_EXC_ERROR;

    WHEN OTHERS THEN

     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Delete Fulfillment Set'
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End Delete_Fulfillment_Set;

FUNCTION Find_line(p_line_id  IN  NUMBER)
Return NUMBER
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING FIND_LINE: ' || P_LINE_ID , 1 ) ;
  END IF;

  FOR J IN 1..g_old_line_tbl.count LOOP

     IF p_line_id = g_old_line_tbl(J).line_id THEN

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  ' LINE EXISTS IN THE TABLE' , 1 ) ;
         END IF;

         RETURN J;
     END IF;
  END LOOP;

 RETURN Null;

END Find_line;


Procedure Process_Options IS
l_line_id NUMBER;
l_line_tbl                 OE_ORDER_PUB.Line_Tbl_Type;
l_old_line_tbl                 OE_ORDER_PUB.Line_Tbl_Type;
l_control_rec               OE_GLOBALS.control_rec_type;
l_api_name         CONSTANT VARCHAR2(30) := 'Insert_Into_Set';
x_msg_count number;
x_msg_data varchar2(2000);

l_return_status         VARCHAR2(30);
l_set_rec      OE_ORDER_CACHE.set_rec_type;
l_atp_rec                     OE_ATP.atp_tbl_type;
l_atp_tbl                     OE_ATP.atp_tbl_type;

Cursor optiontbl IS
Select Ordered_quantity,
       header_id,
       Line_id
       from
       oe_order_lines_all where
       top_model_line_id = l_line_id and
       --and line_id <> l_line_id and
      nvl(cancelled_flag,'N') <> 'Y' and
       nvl(model_remnant_flag,'N') <> 'Y'
       ORDER BY arrival_set_id,ship_set_id,line_number,shipment_number,nvl(option_number,-1);
--       order by line_id;
l_count number;
l_perform_sch boolean := FALSE;
l_found NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

		FOR I in 1 .. g_set_opt_tbl.count
		LOOP
		l_count := 0;
		l_line_id := g_set_opt_tbl(I).line_id;

		FOR optionrec in optiontbl
		Loop
		l_count := l_count + 1;
		l_line_tbl(l_count).line_id := optionrec.line_id;
          oe_line_util.query_row(p_line_id => optionrec.line_id,
							  x_line_rec => l_line_tbl(l_count));
		g_old_line_tbl(l_count) :=
		                                 l_line_tbl(l_count);
		l_old_line_tbl(l_count) := l_line_tbl(l_count);
		l_line_tbl(l_count).operation := oe_globals.g_opr_update;
		IF g_set_opt_tbl(I).set_id IS NOT NULL THEN
		 l_set_rec := get_set_rec(g_set_opt_tbl(I).set_id);
		l_perform_sch := TRUE;
		END IF;
		IF g_set_opt_tbl(I).set_type = 'SHIP_SET' THEN
		l_line_tbl(l_count).ship_set_id := g_set_opt_tbl(I).set_id;
                l_line_tbl(l_count).ship_to_org_id := l_set_rec.ship_to_org_id;
        l_line_tbl(l_count).ship_from_org_id := l_set_rec.ship_from_org_id;
        l_line_tbl(l_count).schedule_ship_Date := l_set_rec.schedule_ship_date;


		ELSIF g_set_opt_tbl(I).set_type = 'ARRIVAL_SET' THEN
		l_line_tbl(l_count).arrival_set_id := g_set_opt_tbl(I).set_id;
                l_line_tbl(l_count).ship_to_org_id := l_set_rec.ship_to_org_id;
	l_line_tbl(l_count).schedule_arrival_Date := l_set_rec.schedule_arrival_date;

		ELSIF g_set_opt_tbl(I).set_type = 'FULFILLMENT_SET' THEN
		l_line_tbl(l_count).fulfillment_set_id := g_set_opt_tbl(I).set_id;
		END IF;
          l_line_tbl(l_count).schedule_action_code :=
                              OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE;

		End Loop;
         g_set_recursive_flag := TRUE;
		IF l_line_tbl.count > 0 AND L_Perform_Sch THEN
            OE_GRP_SCH_UTIL.Schedule_set_of_lines
                   (p_x_line_tbl  => l_line_tbl,
                    p_old_line_tbl => g_old_line_tbl,
                    x_return_status => l_return_status);

            l_old_line_tbl.delete;

            FOR I IN 1..l_line_tbl.count LOOP

              l_found := find_line(l_line_tbl(I).line_id);
              IF l_found is null THEN

                l_old_line_tbl(I) := l_line_tbl(I);
              ELSE

                l_old_line_tbl(I) := g_old_line_tbl(l_found);
              END IF;


            END LOOP;

			g_old_line_tbl.delete;
		END IF;

               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'AFTER GROUP SCHEDULING' || L_LINE_TBL.COUNT , 1 ) ;
               END IF;
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'AFTER GROUP SCHEDULING' || L_OLD_LINE_TBL.COUNT , 1 ) ;
               END IF;
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'RETURNSTATUS UNEXPECTED SCHEDULING' , 1 ) ;
               END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'RETURNSTATUS ERROR SCHEDULING' , 1 ) ;
               END IF;
                 RAISE FND_API.G_EXC_ERROR;
      END IF;

          l_control_rec.controlled_operation := TRUE;
          l_control_rec.write_to_db := TRUE;
          l_control_rec.PROCESS := FALSE;
          l_control_rec.default_attributes := TRUE;
          l_control_rec.change_attributes := TRUE;
     OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'N';
    g_set_recursive_flag := TRUE;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESS OPTIONS- BEFORE CALLING PROCESS ORDER IN SETS' ) ;
    END IF;

    FOR I in 1 .. l_line_tbl.count
    Loop
                    IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'SHIP_SET: ' || L_LINE_TBL ( I ) .SHIP_SET_ID ) ;
                    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE_ID :' || L_LINE_TBL ( I ) .LINE_ID , 1 ) ;
    END IF;
    end loop;
	IF l_line_tbl.count > 0 THEN

     oe_order_pvt.Lines
	(   p_validation_level  =>   FND_API.G_VALID_LEVEL_NONE
	,   p_control_rec       => l_control_rec
	,   p_x_line_tbl         =>  l_line_tbl
	,   p_x_old_line_tbl    =>  l_old_line_tbl
	,   x_return_status     => l_return_status

	);
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

/* jolin start comment out nocopy for notification project

-- Api to call notify OC and ACK and to process delayed requests

    OE_Order_PVT.Process_Requests_And_Notify
          ( p_process_requests          => FALSE
          , p_notify                    => TRUE
          , x_return_status             => l_return_status
          , p_line_tbl                  => l_line_tbl
          , p_old_line_tbl             => l_old_line_tbl
          );

jolin end */

    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PROCESS OPTIONS- AFTER CALLING PROCESS ORDER IN SETS' ) ;
    END IF;

     OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
    g_set_recursive_flag := FALSE;
		l_line_tbl.delete;

	END LOOP;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

     RAISE FND_API.G_EXC_ERROR;

    WHEN OTHERS THEN

     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Process Options'
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Process_Options;



procedure Get_Options(p_x_line_tbl IN OUT NOCOPY OE_ORDER_PUB.line_tbl_type,
				   p_set_type IN VARCHAR2,
				   p_index IN NUMBER,
				  p_line_id IN NUMBER  := NULL,
			p_line_rec OE_ORDER_PUB.line_rec_type
				 := OE_ORDER_PUB.g_miss_line_rec
				 ) IS
l_line_id NUMBER;
Cursor optiontbl IS
Select Ordered_quantity,
       header_id,
       Line_id
       from
       oe_order_lines_all where
       top_model_line_id = l_line_id
       and line_id <> l_line_id and
       nvl(cancelled_flag,'N') <> 'Y' and
       nvl(model_remnant_flag,'N') <> 'Y'
       order by line_id;
l_count number;
lexist boolean := FALSE;
l_return_status varchar2(1);
l_line_rec OE_ORDER_PUB.line_rec_type := p_line_rec;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTER GET OPTIONS' ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTER COUNT GET OPTIONS'|| P_X_LINE_TBL.COUNT ) ;
     END IF;
		IF p_x_line_tbl.count = 0 THEN
		l_line_id := p_line_id;
		else
          l_line_id := p_x_line_tbl(p_index).line_id;
		end if;
		l_count := p_x_line_tbl.count + 1;
		IF l_line_rec.line_id is null OR
		   l_line_rec.line_id = FND_API.G_MISS_NUM THEN
		l_line_rec := p_x_line_tbl(p_index);
		END IF;

          FOR Optionrec IN Optiontbl
          Loop
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTER INTO OPTIONS' ) ;
     END IF;

		lexist := FALSE;
		IF g_process_options THEN
		FOR I in 1..g_auto_set_tbl.count
		LOOP
		IF optionrec.line_id = g_auto_set_tbl(I).line_id THEN
		lexist := TRUE;
		EXIT;
		END IF;
		END LOOP;

		END IF;

		IF NOT lexist THEN
		p_x_line_tbl(l_count).line_id := optionrec.line_id;
			oe_line_util.query_row(p_line_id => optionrec.line_id,
							  x_line_rec => p_x_line_tbl(l_count));

          g_old_line_tbl(g_old_line_tbl.count + 1) :=
          p_x_line_tbl(l_count);
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTER INTO OPTIONS' || P_X_LINE_TBL ( L_COUNT ) .ITEM_TYPE_CODE ) ;
     END IF;

		IF p_set_type = 'SHIP_SET' THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'IN SHIP SET:' ) ;
		END IF;
 		p_x_line_tbl(l_count).ship_from_org_id
 			:= l_line_rec.ship_from_org_id;
		p_x_line_tbl(l_count).ship_to_org_id
		:= l_line_rec.ship_to_org_id;
	     p_x_line_tbl(l_count).schedule_ship_date
		:= l_line_rec.schedule_ship_date;
	     /*p_x_line_tbl(l_count).schedule_arrival_date
		:= p_x_line_tbl(p_index).schedule_arrival_date;
	     p_x_line_tbl(l_count).freight_carrier_code
		:= p_x_line_tbl(p_index).freight_carrier_code; */
	     p_x_line_tbl(l_count).ship_set
		:= l_line_rec.ship_set;
		ELSIF p_set_type = 'ARRIVAL_SET' THEN
		p_x_line_tbl(l_count).ship_to_org_id :=
		l_line_rec.ship_to_org_id;
		p_x_line_tbl(l_count).schedule_arrival_date
		:= l_line_rec.schedule_arrival_date;
	     p_x_line_tbl(l_count).arrival_set
		:= l_line_rec.arrival_set;
		END IF;
		p_x_line_tbl(l_count).operation := oe_globals.g_opr_update;
		p_x_line_tbl(l_count).schedule_action_code
		:= OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE;
		l_count := l_count + 1;
		END IF; -- if not exists
		End Loop;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'COUNT GET OPTIONS'|| P_X_LINE_TBL.COUNT ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXIT GET OPTIONS' ) ;
     END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

     RAISE FND_API.G_EXC_ERROR;

     WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
       OE_MSG_PUB.Add_Exc_Msg
               (    G_PKG_NAME ,
                    'Get_Options'
               );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Options;

-- This procedure is added for to seperate arrival sets from the ship set
-- logic given to DWL customer. The arrival set behaves the same
--way as it does



Procedure Insert_Into_arrival_Set
        (p_Set_request_tbl             oe_order_pub.Request_Tbl_Type,
         p_Push_Set_Date                IN VARCHAR2 := FND_API.G_FALSE,
X_Return_Status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

)IS
l_line_rec		  OE_ORDER_PUB.line_rec_type;
l_model_line_rec		  OE_ORDER_PUB.line_rec_type;
l_header_rec		  OE_ORDER_PUB.header_rec_type;
l_line_tbl                 OE_ORDER_PUB.Line_Tbl_Type;
l_temp_line_tbl                 OE_ORDER_PUB.Line_Tbl_Type;
l_sch_line_tbl                 OE_ORDER_PUB.Line_Tbl_Type;
l_set_request_tbl oe_order_pub.Request_Tbl_Type;
set_request_tbl oe_order_pub.Request_Tbl_Type := p_Set_request_tbl ;
l_set_tbl                 OE_ORDER_PUB.Line_Tbl_Type;
l_old_line_tbl            OE_ORDER_PUB.Line_Tbl_Type ;
l_line_query_tbl                 OE_ORDER_PUB.Line_Tbl_Type;
l_control_rec               OE_GLOBALS.control_rec_type;
l_api_name         CONSTANT VARCHAR2(30) := 'Insert_Into_Set';
l_return_status         VARCHAR2(30);
l_query_clause          VARCHAR2(2000);
l_exist BOOLEAN := FALSE;
l_line_exist BOOLEAN := FALSE;
l_set_id NUMBER ;
l_ship_set_id NUMBER ;
l_arrival_set_id NUMBER ;
l_sch_count NUMBER := 0 ;
l_header_id NUMBER ;
l_line_id NUMBER ;
l_set_type VARCHAR2(30) ;
l_set_name VARCHAR2(30) ;
l_set_rec 	OE_ORDER_CACHE.set_rec_type;
l_atp_rec                     OE_ATP.atp_tbl_type;
l_atp_tbl                     OE_ATP.atp_tbl_type;
lcnt number := 0;
l_Ship_from_org_id  NUMBER ;
l_Ship_to_org_id    NUMBER ;
l_Schedule_Ship_Date DATE ;
l_Schedule_Arrival_Date DATE ;
l_Freight_Carrier_Code  VARCHAR2(30) ;
l_Shipping_Method_Code  VARCHAR2(30) ;
l_Shipment_priority_code VARCHAR2(30);
LCOUNT NUMBER := 0;
lsettempname number;
l_top_model_line_id number;
l_line_tbl_model_exists varchar2(1) := 'N' ;

Cursor shipset is
Select set_id from
oe_sets where
set_type = 'SHIP_SET'
and header_id = l_header_id
and ship_from_org_id = l_ship_from_org_id
and ship_to_org_id = l_ship_to_org_id
and trunc(schedule_ship_date) = trunc(l_Schedule_Ship_Date)
and nvl(set_status,'X') <> 'C'
;

Cursor arrivalset is
Select set_id from
oe_sets where
set_type = 'ARRIVAL_SET' and
header_id = l_header_id
and ship_to_org_id = l_ship_to_org_id
and trunc(schedule_arrival_date) = trunc(l_Schedule_arrival_Date)
and nvl(set_status,'X') <> 'C';

Cursor C1 is
select Max(to_number(set_name)) from
oe_sets
where
set_status = 'T'
and header_id = l_header_id and
set_type = l_set_type;

Cursor C2 is
Select Schedule_ship_date,
Ship_from_org_id,
ship_to_org_id,
schedule_arrival_date,
ship_set_id,
arrival_set_id
from
oe_order_lines_all
where
line_id = l_top_model_line_id ;
/*nvl(cancelled_flag,'N') <> 'Y' and
nvl(model_remnant_flag,'N') <> 'Y'
and (
ship_model_complete_flag = 'Y' OR
ato_line_id IS NOT NULL) */

Cursor C3 is
select Max(to_number(set_name)) from
oe_sets
where
header_id = l_header_id and
set_type = l_set_type and
set_name = lsettempname;

tempname varchar2(240);

l_perform_sch boolean := TRUE;
l_model_exists boolean := FALSE;
l_x_ship_set_id number;
l_x_arrival_set_id number;


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'INSERT_INTO ARRIVAL SETSS' , 1 ) ;
     END IF;
g_old_arrival_set_path := TRUE;

	IF p_set_request_tbl.count >  0 THEN
	--g_cust_pref_set := TRUE;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROCESS REQUEST RECORD ' , 1 ) ;
     END IF;

	l_header_id := p_set_request_tbl(1).entity_id;
	 oe_header_util.query_row(p_header_id => l_header_id,
						 x_header_rec => l_header_rec);
		IF l_header_rec.customer_preference_set_code = 'ARRIVAL' THEN
			l_set_type := 'ARRIVAL_SET';
		ELSIF l_header_rec.customer_preference_set_code = 'SHIP' THEN
			l_set_type := 'SHIP_SET';
		ELSE
			GOTO END_1;
	     END IF;


	FOR I in 1..g_auto_set_tbl.count
	Loop
	Begin
	l_temp_line_tbl.delete;
	g_old_line_tbl.delete;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTER INTO AUTO SET TABLE LOOP ' , 1 ) ;
     END IF;
	 oe_line_util.query_row(p_line_id => g_auto_set_tbl(I).line_id,
								  x_line_rec => l_line_rec);
	IF (l_line_rec.split_from_line_id is not null) THEN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'INVALID ITEM SPLIT'||L_LINE_REC.LINE_ID ) ;
	END IF;
		RAISE NO_DATA_FOUND;
	END IF;
	IF l_line_rec.line_category_code = 'RETURN' OR
		l_line_rec.item_type_code = 'INCLUDED'  THEN
		RAISE NO_DATA_FOUND;
	END IF;
	l_temp_line_tbl(1) := l_line_rec;

		g_old_line_tbl(g_old_line_tbl.count +1 ) :=
          l_temp_line_tbl(1);

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ITEM TYPE CODE IS: '||L_LINE_REC.ITEM_TYPE_CODE , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP FROM : '||L_LINE_REC.SHIP_FROM_ORG_ID , 1 ) ;
     END IF;
		IF l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL
			OR l_line_rec.item_type_code = 'KIT' THEN
				l_model_exists := TRUE;
		   Get_Options(p_x_line_tbl => l_temp_line_tbl,
					p_set_type => l_set_type,
					p_index => 1);
	     ELSIF l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
			l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION OR
			l_line_rec.item_type_code = 'INCLUDED' OR
		 l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CONFIG  THEN
			l_top_model_line_id := l_line_rec.top_model_line_id;
			l_line_tbl_model_exists := 'N';
	FOR T in 1..l_line_tbl.count loop
		IF l_top_model_line_id = l_line_tbl(T).line_id THEN
			l_line_tbl_model_exists := 'Y';
			IF l_set_type = 'SHIP_SET' THEN
		l_schedule_ship_date := l_line_tbl(T).schedule_ship_date;
		l_ship_from_org_id := l_line_tbl(T).ship_from_org_id;
		l_ship_to_org_id := l_line_tbl(T).ship_to_org_id;
		l_ship_set_id := l_line_tbl(T).ship_set_id;
			ELSIF l_set_type = 'ARRIVAL_SET' THEN
		l_ship_to_org_id := l_line_tbl(T).ship_to_org_id;
		l_schedule_arrival_date := l_line_tbl(T).schedule_arrival_date;
		l_arrival_set_id := l_line_tbl(T).arrival_set_id;
			END IF;
			EXIT;
		END IF;
			END LOOP;
			IF l_line_tbl_model_exists = 'N' THEN
			OPEN C2;
			FETCH C2 into
			l_schedule_ship_date,
			l_ship_from_org_id,
			l_ship_to_org_id,
			l_schedule_arrival_date,
			l_ship_set_id,
			l_arrival_set_id;
			CLOSE C2;
			END IF;
			IF l_set_type = 'SHIP_SET'
			/*-- AND
			 l_schedule_ship_date IS NOT NULL AND
			 l_ship_from_org_id IS NOT NULL AND
			 l_ship_to_org_id IS NOT NULL */
			 THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'INTO SHIP SET' , 1 ) ;
     END IF;
			 l_temp_line_tbl(1).schedule_ship_date := l_schedule_ship_date;
			 l_temp_line_tbl(1).ship_from_org_id := l_ship_from_org_id;
			 l_temp_line_tbl(1).ship_to_org_id := l_ship_to_org_id;
			 l_temp_line_tbl(1).ship_set_id := l_ship_set_id;
			 --l_perform_sch := FALSE;
			ELSIF l_set_type = 'ARRIVAL_SET' THEN
/*
			 l_schedule_arrival_date IS NOT NULL AND
			 l_ship_to_org_id IS NOT NULL THEN */
		l_temp_line_tbl(1).schedule_arrival_date := l_schedule_arrival_date;
		l_temp_line_tbl(1).ship_to_org_id := l_ship_to_org_id;
		 l_temp_line_tbl(1).arrival_set_id := l_arrival_set_id;
			 --l_perform_sch := FALSE;
			END IF;
		END IF;
--	IF l_line_rec.schedule_status_code IS NULL THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'COUNT OF TEMP TABLE' || L_TEMP_LINE_TBL.COUNT , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ITEM TYPE CODE' || L_TEMP_LINE_TBL ( 1 ) .ITEM_TYPE_CODE , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP SET' || L_TEMP_LINE_TBL ( 1 ) .SHIP_SET_ID , 1 ) ;
     END IF;
	FOR J in 1..l_temp_line_tbl.count
	LOOP
	l_temp_line_tbl(J).schedule_action_code :=
	OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE;
	l_sch_count := l_sch_count + 1;
	l_sch_line_tbl(l_sch_count) := l_temp_line_tbl(J);
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'COUNT OF TEMP TABLE' || L_TEMP_LINE_TBL.COUNT , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ITEM TYPE CODE' || L_TEMP_LINE_TBL ( 1 ) .ITEM_TYPE_CODE , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP SET' || L_TEMP_LINE_TBL ( 1 ) .SHIP_SET_ID , 1 ) ;
     END IF;
			l_model_exists := false;
			IF l_temp_line_tbl(J).item_type_code = 'INCLUDED' OR
				l_temp_line_tbl(J).item_type_code = 'OPTION' OR
			l_temp_line_tbl(J).item_type_code = 'CLASS' OR
			l_temp_line_tbl(J).item_type_code = 'CONFIG' THEN
			FOR L in 1..g_auto_set_tbl.count
			LOOP
			IF l_temp_line_tbl(J).top_model_line_id =
				g_auto_set_tbl(L).line_id THEN
				l_model_exists := true;
					exit;
			END IF;
		        END LOOP;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'COUNT OF TEMP TABLE' || L_TEMP_LINE_TBL.COUNT , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ITEM TYPE CODE' || L_TEMP_LINE_TBL ( 1 ) .ITEM_TYPE_CODE , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP SET' || L_TEMP_LINE_TBL ( 1 ) .SHIP_SET_ID , 1 ) ;
     END IF;
			if not l_model_exists then
	oe_line_util.query_row(p_line_id => l_temp_line_tbl(J).top_model_line_id,
			   x_line_rec => l_model_line_rec);
			if l_model_line_rec.ship_set_id is null and
				l_model_line_rec.arrival_set_id is null THEN

			l_sch_line_tbl.delete(l_sch_count) ;
			l_sch_count := l_sch_count - 1;


			END IF;
			END IF;
			END IF;

	l_temp_line_tbl(J).schedule_action_code :=
	OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE;
	END LOOP;

-- Call scheduling
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE CALLING SCHEDULING ' , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'COUNT BEFORE CALLING : '||G_OLD_LINE_TBL.COUNT , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'COUNT BEFORE CALLING : '||G_OLD_LINE_TBL.LAST , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'COUNT BEFORE CALLING : '||L_SCH_LINE_TBL.COUNT , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'COUNT BEFORE CALLING : '||L_SCH_LINE_TBL.LAST , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP FROM : '||L_TEMP_LINE_TBL ( 1 ) .SHIP_FROM_ORG_ID , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LINE : '||L_TEMP_LINE_TBL ( 1 ) .LINE_ID , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP TO : '||L_TEMP_LINE_TBL ( 1 ) .SHIP_TO_ORG_ID , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP FROM : '||L_SCH_LINE_TBL ( 1 ) .SHIP_FROM_ORG_ID , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LINE : '||L_SCH_LINE_TBL ( 1 ) .LINE_ID , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP TO : '||L_SCH_LINE_TBL ( 1 ) .SHIP_TO_ORG_ID , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP FROM : '||G_OLD_LINE_TBL ( 1 ) .SHIP_FROM_ORG_ID , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LINE : '||G_OLD_LINE_TBL ( 1 ) .LINE_ID , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP TO : '||G_OLD_LINE_TBL ( 1 ) .SHIP_TO_ORG_ID , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'COUNT BEFORE CALLING : '||L_SCH_LINE_TBL.COUNT , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'COUNT BEFORE CALLING : '||G_OLD_LINE_TBL.COUNT , 1 ) ;
     END IF;
	 IF l_perform_sch and l_sch_line_tbl.count > 0  THEN
         OE_GRP_SCH_UTIL.Schedule_set_of_lines
                   (p_x_line_tbl   => l_sch_line_tbl,
                    p_old_line_tbl => g_old_line_tbl,
                    x_return_status => l_return_status);
         g_old_line_tbl.delete;
	 END IF;
	 l_perform_sch := TRUE;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  ' SCHEDULING UNEXPECTED ERROR ' , 1 ) ;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  ' EXPECTED ERROR ' , 1 ) ;
        END IF;
        l_sch_line_tbl.delete;
        l_sch_count := 0;
        goto END_2;

    --  RAISE FND_API.G_EXC_ERROR;
    END IF;
--	END IF; -- Schedule Action Code
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTER CALLIN SCHEDULING ' , 1 ) ;
     END IF;
		IF l_sch_line_tbl.count > 0 THEN
		l_temp_line_tbl.delete;
		--END IF;
		l_temp_line_tbl := l_sch_line_tbl;
		l_sch_line_tbl.delete;
		l_sch_count := 0;
		END IF;
      l_ship_from_org_id := l_temp_line_tbl(1).ship_from_org_id;
      l_ship_to_org_id := l_temp_line_tbl(1).ship_to_org_id;
      l_schedule_ship_date := l_temp_line_tbl(1).schedule_ship_date;
      l_schedule_arrival_date := l_temp_line_tbl(1).schedule_arrival_date;
      l_freight_carrier_code := l_temp_line_tbl(1).freight_carrier_code;
      l_shipping_method_code := l_temp_line_tbl(1).shipping_method_code;
      l_shipment_priority_code := l_temp_line_tbl(1).shipment_priority_code;
	 l_set_id := null;

		IF l_set_type = 'SHIP_SET' THEN
			Open shipset;
			Fetch shipset into l_set_id;
			Close shipset;
		ELSIF l_set_type = 'ARRIVAL_SET' THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP FROM : '||L_TEMP_LINE_TBL ( 1 ) .SHIP_FROM_ORG_ID , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LINE : '||L_TEMP_LINE_TBL ( 1 ) .LINE_ID , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP TO : '||L_TEMP_LINE_TBL ( 1 ) .SHIP_TO_ORG_ID , 1 ) ;
     END IF;
			Open arrivalset;
			Fetch arrivalset into l_set_id;
			Close arrivalset;
		END IF;

		IF l_set_id IS NULL THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP FROM : '||L_TEMP_LINE_TBL ( 1 ) .SHIP_FROM_ORG_ID , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LINE : '||L_TEMP_LINE_TBL ( 1 ) .LINE_ID , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP TO : '||L_TEMP_LINE_TBL ( 1 ) .SHIP_TO_ORG_ID , 1 ) ;
     END IF;
		OPEN C1;
		FETCH C1 INTO lsettempname;
	     CLOSE C1;
	 IF lsettempname IS NULL THEN
		lsettempname := 1;

		LOOP
			OPEN C3;
			FETCH C3 INTO tempname;
	     	CLOSE C3;
				IF tempname is not null then
					lsettempname := lsettempname + 1;
				ELSE
					EXIT;
				END IF;
		END LOOP ;

	 ELSE
	     lsettempname := lsettempname + 1;
	END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  ' BEFORE CREATING SET ' , 1 ) ;
     END IF;
     Create_Set
        (p_Set_Name => to_char(lsettempname),
         p_Set_Type => l_set_type,
         p_Header_Id => l_header_id,
         p_Ship_From_Org_Id => l_ship_from_org_id,
         p_Ship_To_Org_Id   => l_Ship_To_Org_Id,
         p_Schedule_Ship_Date  => l_schedule_ship_Date,
         p_Schedule_Arrival_Date => l_Schedule_Arrival_Date,
         p_Freight_Carrier_Code  => l_Freight_Carrier_Code,
         p_Shipping_Method_Code   => l_Shipping_Method_Code,
         p_Shipment_priority_code  => l_Shipment_priority_code,
         x_Set_Id                 => l_set_id,
         X_Return_Status  => l_return_status,
          x_msg_count      => x_msg_count,
      	x_msg_data       => x_msg_data);
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
      END IF;

		END IF; -- if set id is null

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  ' SET ID IS '|| L_SET_ID , 1 ) ;
     END IF;

	FOR K in 1..l_temp_line_tbl.count
	LOOP
		IF l_set_type = 'SHIP_SET' THEN
	l_temp_line_tbl(K).ship_Set_id := l_set_id;
		ELSIF l_set_type = 'ARRIVAL_SET' THEN
	l_temp_line_tbl(K).arrival_Set_id := l_set_id;
	    END IF;
	l_temp_line_tbl(K).operation := oe_globals.g_opr_update;
	END LOOP;

		FOR L in 1..l_temp_line_tbl.count
		LOOP
		l_line_tbl(l_line_tbl.count+1) := l_temp_line_tbl(L);
		END LOOP;

    <<END_2>>
    null;

	Exception

	WHEN NO_DATA_FOUND THEN
		   NULL;
    	WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data


        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'IN INSERINTO EXCEPTION ' , 1 ) ;
     END IF;
        RAISE FND_API.G_EXC_ERROR;

	WHEN OTHERS THEN
        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        /*x_return_status := FND_API.G_EXC_UNEXPECTED_ERROR ;

        OE_DEBUG_PUB.Add('In Inserinto exception ',1);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;*/

		   NULL;

	END ;-- End of get line
	END LOOP;
		FOR I in 1..l_line_tbl.count
		LOOP
			l_model_exists := false;
			IF l_line_tbl(I).item_type_code = 'INCLUDED' OR
				l_line_tbl(I).item_type_code = 'OPTION' OR
			l_line_tbl(I).item_type_code = 'CLASS' THEN
			FOR J in 1..l_line_tbl.count
			LOOP
			IF l_line_tbl(I).top_model_line_id =
				l_line_tbl(J).line_id THEN
				l_model_exists := true;
					exit;
			END IF;
		        END LOOP;
			if not l_model_exists then
	oe_line_util.query_row(p_line_id => l_line_tbl(I).top_model_line_id,
			   x_line_rec => l_model_line_rec);
			IF l_model_line_rec.ship_set_id is null then
				l_line_tbl(I).ship_set_id := NULL;
			ELSIF l_model_line_rec.ship_set_id is not null then
				l_line_tbl(I).ship_set_id :=
				l_model_line_rec.ship_set_id;


			END IF;
			IF l_model_line_rec.arrival_set_id is null then
				l_line_tbl(I).arrival_set_id := NULL;
			ELSIF l_model_line_rec.arrival_set_id is not null then
				l_line_tbl(I).arrival_set_id :=
				l_model_line_rec.arrival_set_id;
			END IF;
			END IF;
			END IF;


		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SHIP SET IS-'||L_LINE_TBL ( I ) .SHIP_SET_ID , 1 ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'LINE -'||L_LINE_TBL ( I ) .LINE_ID , 1 ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ITEM TYPE -'||L_LINE_TBL ( I ) .ITEM_TYPE_CODE , 1 ) ;
		END IF;
		END LOOP;

	IF l_line_tbl.count > 0 THEN


-- Call Process Order
          l_control_rec.controlled_operation := TRUE;
          l_control_rec.write_to_db := TRUE;
          l_control_rec.PROCESS := FALSE;
          l_control_rec.default_attributes := TRUE;
          l_control_rec.change_attributes := TRUE;
          l_control_rec.validate_entity :=TRUE;


     OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'N';
          g_set_recursive_flag := TRUE;
     oe_order_pvt.Lines
(   p_validation_level  =>    FND_API.G_VALID_LEVEL_NONE
,   p_control_rec       => l_control_rec
,   p_x_line_tbl         =>  l_line_tbl
,   p_x_old_line_tbl    =>  l_old_line_tbl
,   x_return_status     => l_return_status

);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

/* jolin start comment out nocopy for notification project

-- Api to call notify OC and ACK and to process delayed requests

OE_Order_PVT.Process_Requests_And_Notify
          ( p_process_requests          => FALSE
          , p_notify                    => TRUE
          , x_return_status             => l_return_status
          , p_line_tbl                  => l_line_tbl
          , p_old_line_tbl             => l_old_line_tbl
          );

jolin end */

	l_line_tbl.delete;


     OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
          g_set_recursive_flag := FALSE;
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

  END IF; -- IF line table is greate than Zero

	g_cust_pref_set := TRUE;

END IF;
		g_auto_set_tbl.delete;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  ' EXIT INSERT INTO SETS' , 1 ) ;
     END IF;

<<END_1>>
NULL;
	g_auto_set_tbl.delete;
	g_old_arrival_set_path := FALSE;
	--g_cust_pref_set := TRUE;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data


        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'IN INSERINTO EXCEPTION ' , 1 ) ;
     END IF;
        RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Into_Set'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

End Insert_Into_arrival_Set;


Procedure New_Process_Sets
(   p_selected_line_tbl    IN OE_GLOBALS.Selected_Record_Tbl, --(R12.MOAC)
    p_record_count         IN NUMBER,
    p_set_name             IN VARCHAR2,
    p_set_type             IN VARCHAR2 := FND_API.G_MISS_CHAR,
    p_operation            IN VARCHAR2,
    p_header_id            IN VARCHAR2 := FND_API.G_MISS_CHAR,
x_Set_Id OUT NOCOPY NUMBER,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

) IS

l_num_of_records NUMBER := p_record_count;
l_line_rec                OE_ORDER_PUB.line_rec_type;
l_in_line_rec                OE_ORDER_PUB.line_rec_type;
l_control_rec               OE_GLOBALS.Control_Rec_Type;
l_line_tbl                  OE_ORDER_PUB.Line_Tbl_Type;
l_line_opt_tbl              OE_ORDER_PUB.Line_Tbl_Type;
l_line_opt_temp_tbl         OE_ORDER_PUB.Line_Tbl_Type;
l_old_line_tbl              OE_ORDER_PUB.Line_Tbl_Type;
l_api_name         CONSTANT VARCHAR2(30)   := 'New_Process_sets';
l_line_id         Number;
l_return_status             VARCHAR2(30);
l_header_id number := to_number(p_header_id);

j Integer;
initial Integer;
nextpos Integer;
--l_record_ids  varchar2(32000) := p_record_ids || ','; --R12.MOAC
l_set_id number;
l_set_type varchar2(80);
l_exists BOOLEAN := FALSE ;
l_Ship_from_org_id  NUMBER ;
l_Ship_to_org_id    NUMBER ;
l_Schedule_Ship_Date DATE ;
l_Schedule_Arrival_Date DATE ;
l_Freight_Carrier_Code  VARCHAR2(30) ;
l_Shipping_Method_Code  VARCHAR2(30) ;
l_Shipment_priority_code VARCHAR2(30);
l_set_rec OE_ORDER_CACHE.set_rec_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
 	SAVEPOINT New_Process_sets;
	x_return_status := FND_API.G_RET_STS_SUCCESS;



     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROCEDURE NEW PROCESS SETS' , 1 ) ;
     END IF;

          j := 1;
         initial := 1;
         --nextpos := INSTR(l_record_ids,',',1,j) ; --R12.MOAC

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SET NAME IS-' || P_SET_NAME , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SET TYPE IS-' || P_OPERATION , 1 ) ;
     END IF;
if p_set_name is not null then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SET TYPE IS-' || P_SET_TYPE , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SET TYPE IS-' || P_OPERATION , 1 ) ;
     END IF;

	if p_set_type = 'ARRIVAL' THEN
		l_set_type := 'ARRIVAL_SET';
	elsif p_set_type = 'SHIP' THEN
		l_set_type := 'SHIP_SET';
	end if;
	l_exists :=  Set_Exist(p_set_name => p_set_name,
           p_set_type => l_set_type,
	   p_header_id =>l_header_id,
           x_set_id    => l_set_id);
		IF l_set_id IS NOT NULL  THEN
			IF is_set_closed(l_set_id) THEN
          	fnd_message.set_name('ONT', 'OE_SET_CLOSED');
         		FND_MESSAGE.SET_TOKEN('SET',
          	p_set_name);
          		oe_msg_pub.add;
        			RAISE FND_API.G_EXC_ERROR;
			END IF;
		END IF;
		if (p_operation = 'REMOVE' ) THEN
     		IF l_debug_level  > 0 THEN
     		    oe_debug_pub.add(  'INTO REMOVE' , 1 ) ;
     		END IF;
		l_exists := TRUE;
		l_set_id := NULL;
		end if;

end if; -- Set name is not null


		IF l_exists and p_operation <> 'REMOVE' THEN
		l_set_rec := get_set_rec(l_set_id);
		END IF;


 --R12.MOAC Start
 /*
 FOR I IN 1..l_num_of_records LOOP

 l_line_id := to_number(substr(l_record_ids,initial, nextpos-initial));
 initial := nextpos + 1.0;
 j := j + 1.0;
 nextpos := INSTR(l_record_ids,',',1,j) ;
 */
 FOR I IN 1..p_selected_line_tbl.COUNT LOOP
  l_line_id := p_selected_line_tbl(I).id1;
 -- R12.MOAC End
  OE_LINE_UTIL.lock_row
    (   p_line_id      => l_line_id,
	   p_x_line_rec => l_line_rec
	   ,x_return_status => l_return_status);

		IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
			  RAISE FND_API.G_EXC_ERROR;
	     END IF;

        OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => l_line_rec.line_id
         ,p_header_id                   => l_line_rec.header_id
         ,p_line_id                     => l_line_rec.line_id
         ,p_orig_sys_document_ref       =>
                                l_line_rec.orig_sys_document_ref
         ,p_orig_sys_document_line_ref  =>
                                l_line_rec.orig_sys_line_ref
         ,p_orig_sys_shipment_ref       =>
                                l_line_rec.orig_sys_shipment_ref
         ,p_change_sequence             =>  l_line_rec.change_sequence
         ,p_source_document_id          =>
                                l_line_rec.source_document_id
         ,p_source_document_line_id     =>
                                l_line_rec.source_document_line_id
         ,p_order_source_id             =>
                                l_line_rec.order_source_id
         ,p_source_document_type_id     =>
                                l_line_rec.source_document_type_id);

       IF l_line_rec.ship_set = FND_API.G_MISS_CHAR THEN
          l_line_rec.ship_set := Null;
       END IF;
       IF l_line_rec.arrival_set = FND_API.G_MISS_CHAR THEN
          l_line_rec.arrival_set := Null;
       END IF;
	   l_line_tbl(I) := l_line_rec;

	   --{ Bug 3692277 starts
	   IF l_debug_level > 0 THEN
	      OE_DEBUG_PUB.Add('RMC: Versioning with Reason');
	   END IF;
	   l_line_tbl(I).change_reason := 'SYSTEM';
	   l_line_tbl(I).change_comments := 'Set Action';
	   -- bug 3692277 ends }

     IF (l_line_tbl(I).top_model_line_id <> l_line_tbl(I).line_id AND
        l_line_tbl(I).item_type_code <> 'STANDARD'
        AND
         nvl(l_line_tbl(I).model_remnant_flag,'N') <> 'Y') OR
	l_line_tbl(I).line_category_code = 'RETURN' OR
	l_line_tbl(I).source_type_code = 'EXTERNAL' OR
    l_line_tbl(I).item_type_code = 'SERVICE' OR
	nvl(l_line_tbl(I).fulfilled_flag,'N') =  'Y' OR
	nvl(l_line_tbl(I).open_flag,'N') =  'N' OR
	l_line_tbl(I).shipped_quantity is not null
	 THEN
/* and
                 p_operation <> 'REMOVE' )) THEN*/

               FND_MESSAGE.SET_NAME('ONT','OE_INVALID_SET_OPR');
                     --    FND_MESSAGE.SET_TOKEN('ITEMTYPE',
                      --             l_line_tbl(I).item_type_code);
                         OE_MSG_PUB.ADD;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SET- NOT ALLOWED FOR THIS ITEMTYPE' ) ;
            END IF;
                         RAISE FND_API.G_EXC_ERROR;
        END IF;


          g_old_line_tbl(I) :=
          l_line_tbl(I);

	IF p_set_type = 'ARRIVAL' THEN
		IF (p_operation = 'ADD' ) THEN
/* Added the following if condition to fix the bug 2802249 */

             IF l_line_tbl(I).ship_set_id is not null or
                l_line_tbl(I).ship_set is not null THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ship_set:' || l_line_tbl(I).ship_set,2 ) ;
                oe_debug_pub.add(  'ship_set_id:' || l_line_tbl(I).ship_set_id,2 ) ;
            END IF;
             /* Changed the message to fix the bug 2862565 */
              --  FND_MESSAGE.Set_Name('ONT', 'OE_INVALID_SET_COMB');
                  FND_MESSAGE.Set_Name('ONT','OE_SCH_NOT_IN_SHIP_ARR');
                  oe_msg_pub.add;
            /* Changed the message to fix the bug 2862565  */
                  RAISE FND_API.G_EXC_ERROR;
             END IF;

	  IF (l_set_id IS NULL) THEN
	  l_line_tbl(I).arrival_set := p_set_name ;
	  ELSE
	   l_line_tbl(I).arrival_set_id := l_set_id ;
	  END IF;
		ELSIF (p_operation = 'MOVE') THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROCEDURE PROCESS SETS'||TO_CHAR ( L_SET_ID ) , 1 ) ;
     END IF;
	 IF l_set_id IS NOT NULL THEN
	 l_line_tbl(I).arrival_set_id := l_set_id ;
	 ELSE
	 l_line_tbl(I).arrival_set_id := NULL ;
	l_line_tbl(I).arrival_set := p_set_name ;
	END IF;
		ELSIF (p_operation = 'REMOVE') THEN
	 l_line_tbl(I).arrival_set_id := NULL ;
		END IF;
	ELSIF p_set_type = 'SHIP' THEN
		IF (p_operation = 'ADD' ) THEN
	  IF (l_set_id IS NULL) THEN
	  l_line_tbl(I).ship_set := p_set_name ;
	  ELSE
	 l_line_tbl(I).ship_set_id := l_set_id ;
	 END IF;
		ELSIF (p_operation = 'MOVE') THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROCEDURE NEW PROCESS SETS'||TO_CHAR ( L_SET_ID ) , 1 ) ;
     END IF;
	  IF l_set_id IS NOT NULL THEN
	  l_line_tbl(I).ship_set_id := l_set_id ;
	  ELSE
	  l_line_tbl(I).ship_set_id := NULL ;
	l_line_tbl(I).ship_set := p_set_name ;
	  END IF;
		ELSIF (p_operation = 'REMOVE') THEN
	  l_line_tbl(I).ship_set_id := NULL ;
		END IF;
	END IF;

  l_line_tbl(I).operation := OE_GLOBALS.G_OPR_UPDATE;

 END LOOP;


		l_control_rec.write_to_db := TRUE;
		l_control_rec.PROCESS := TRUE;
		l_control_rec.default_attributes := TRUE;
		l_control_rec.change_attributes := TRUE;
		l_control_rec.validate_entity := TRUE;

-- Call OE_Order_PVT.Process_order

     oe_order_pvt.Lines
(   p_validation_level  =>    FND_API.G_VALID_LEVEL_NONE
,   p_control_rec       => l_control_rec
,   p_x_line_tbl         =>  l_line_tbl
,   p_x_old_line_tbl    =>  l_old_line_tbl
,   x_return_status     => l_return_status

);
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


-- jolin start comment out nocopy for notification project

-- Api to call notify OC and ACK and to process delayed requests

OE_Order_PVT.Process_Requests_And_Notify
          ( p_process_requests          => TRUE
          , p_notify                    => TRUE
          , x_return_status             => l_return_status
          , p_line_tbl                  => l_line_tbl
          , p_old_line_tbl             => l_old_line_tbl
          );

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;
--jolin end

        x_return_status := l_return_status;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data


        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
     		IF l_debug_level  > 0 THEN
     		    oe_debug_pub.add(  'BEFORE ROLLING BACK' , 1 ) ;
     		END IF;
	ROLLBACK TO SAVEPOINT New_Process_sets;
     		IF l_debug_level  > 0 THEN
     		    oe_debug_pub.add(  'AFTER ROLLING BACK' , 1 ) ;
     		END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
     		IF l_debug_level  > 0 THEN
     		    oe_debug_pub.add(  'BEFORE ROLLING BACK' , 1 ) ;
     		END IF;

	ROLLBACK TO SAVEPOINT New_Process_sets;
     		IF l_debug_level  > 0 THEN
     		    oe_debug_pub.add(  'AFTER ROLLING BACK' , 1 ) ;
     		END IF;
    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Sets'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
	ROLLBACK TO SAVEPOINT New_Process_sets;

END New_Process_Sets;

FUNCTION Set_Exist(p_set_name IN VARCHAR2,
                    p_set_type IN VARCHAR2,
                    p_Header_Id  IN NUMBER,
x_set_id OUT NOCOPY NUMBER)

RETURN BOOLEAN IS
row_exists VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  SELECT set_id
  INTO x_set_id
  FROM OE_SETS
  where set_name = p_set_name
  and set_type = p_set_type and
  header_id = p_header_id ;
  --and nvl(set_status,'X') <> 'C';

	RETURN TRUE;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

     RAISE FND_API.G_EXC_ERROR;

    WHEN NO_DATA_FOUND THEN

        RETURN FALSE;

End Set_Exist;

FUNCTION Set_Exist(p_set_id    IN NUMBER,
		   p_header_id  IN NUMBER := FND_API.G_MISS_NUM)
RETURN BOOLEAN IS
row_exists VARCHAR2(1);
l_header_id NUMBER := p_header_id;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
IF p_header_id = FND_API.G_MISS_NUM THEN
   l_header_id := NULL;
ELSE
   l_header_id := p_header_id;
END IF;


  SELECT 'Y'
  INTO row_exists
  FROM OE_SETS
  WHERE set_id = p_set_id
  and header_id = nvl(l_header_id,header_id);

  RETURN TRUE;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

     RAISE FND_API.G_EXC_ERROR;

    WHEN NO_DATA_FOUND THEN

        RETURN FALSE;

Null;
End Set_Exist;

Procedure Create_Set
        (p_Set_Name                     IN VARCHAR2,
         p_Set_Type                     IN VARCHAR2,
         p_Header_Id                    IN NUMBER := NULL,
         p_Ship_From_Org_Id             IN NUMBER := NULL,
         p_Ship_To_Org_Id               IN NUMBER := NULL,
         p_shipment_priority_code       IN VARCHAR2 := NULL,
         p_Schedule_Ship_Date           IN DATE := NULL,
         p_Schedule_Arrival_Date        IN DATE := NULL,
         p_Freight_Carrier_Code         IN VARCHAR2 := NULL,
         p_Shipping_Method_Code         IN VARCHAR2 := NULL,
         p_system_set                   IN VARCHAR2 DEFAULT 'N',
x_Set_Id OUT NOCOPY NUMBER,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

)IS
l_set_id NUMBER;
lcustpref varchar2(1) := 'A';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
	x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTER:CREATE SETS ' , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'HEADER ' || P_HEADER_ID , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SET NAME ' || P_SET_NAME , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SET TYPE ' || P_SET_TYPE , 1 ) ;
     END IF;
IF (p_header_id IS NULL OR
    p_set_name IS NULL OR
    p_set_type IS NULL) THEN
          fnd_message.set_name('ONT', 'OE_SET_REQ_ARG');
	  FND_MESSAGE.SET_TOKEN('SET',p_set_name);
          oe_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR ;
	-- Require all three header,set name ane set type to create
END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE SETEXISTS ' , 1 ) ;
     END IF;

IF NOT Set_Exist(p_set_name => p_set_name,
	           p_set_type => p_set_type,
		   p_header_id =>p_header_id,
	           x_set_id    => x_set_id) THEN
NULL;

/*	IF (p_set_type = 'SHIP_SET') AND
                   (p_Ship_from_org_id IS NULL OR
                   p_Ship_to_org_id IS NULL OR
                   p_Schedule_Ship_Date IS NULL ) THEN
                   --p_Freight_Carrier_Code IS NULL OR
                   --p_Shipping_Method_Code IS NULL) THEN
          fnd_message.set_name('ONT', 'OE_INVALID_SET_ATTR');
	  	FND_MESSAGE.SET_TOKEN('SET',p_set_name);
          oe_msg_pub.add;
		RAISE FND_API.G_EXC_ERROR;
		-- set attributes cannot be null
       ELSIF (p_set_type = 'ARRIVAL_SET') AND
                   (p_Ship_to_org_id IS NULL OR
                   p_Schedule_arrival_date IS NULL)THEN
	-- Arrival set attributes cannot be null
          fnd_message.set_name('ONT', 'OE_INVALID_SET_ATTR');
	  FND_MESSAGE.SET_TOKEN('SET',p_set_name);
          oe_msg_pub.add;
	RAISE FND_API.G_EXC_ERROR;

	END IF;   */


      SELECT OE_SETS_S.NEXTVAL
      INTO   l_set_id
      FROM   DUAL;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTERSEQUECEVALUE ' , 1 ) ;
     END IF;
IF g_cust_pref_set AND (p_set_type = 'SHIP_SET'
                        OR p_set_type = 'ARRIVAL_SET')
THEN
lcustpref := 'T';
END IF;

IF  p_system_set = 'Y' AND (p_set_type = 'FULFILLMENT_SET') THEN
lcustpref := 'T';
END IF;

INSERT INTO OE_SETS(
  SET_ID
, SET_NAME
, SET_TYPE
, Header_Id
, Ship_from_org_id
, Ship_to_org_id
, Schedule_Ship_Date
, Schedule_Arrival_Date
, Freight_Carrier_Code
, Shipping_Method_Code
, Shipment_priority_code
, Set_Status
, CREATED_BY
,CREATION_DATE
,UPDATE_DATE
,UPDAtED_BY
)
 VALUES(
  l_set_id
, p_set_name
, p_Set_type
, p_Header_Id
, p_Ship_from_org_id
, p_Ship_to_org_id
, p_Schedule_Ship_Date
, p_Schedule_Arrival_Date
, p_Freight_Carrier_Code
, p_Shipping_Method_Code
,p_shipment_priority_code
, lcustpref
,1
,sysdate
,sysdate
,1001
    );
x_set_id := l_Set_id;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTERINSERT ' , 1 ) ;
     END IF;
END IF; -- set EXISTS


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data


        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'IN CREATE EXCEPTION ' , 1 ) ;
     END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'create_Set'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


End Create_Set;

Procedure Insert_Into_Set
        (p_Set_request_tbl             oe_order_pub.Request_Tbl_Type,
         p_Push_Set_Date                IN VARCHAR2 := FND_API.G_FALSE,
X_Return_Status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

)IS
l_line_rec		  OE_ORDER_PUB.line_rec_type;
l_old_line_rec		  OE_ORDER_PUB.line_rec_type;
l_model_line_rec		  OE_ORDER_PUB.line_rec_type;
l_header_rec		  OE_ORDER_PUB.header_rec_type;
l_line_tbl                 OE_ORDER_PUB.Line_Tbl_Type;
l_temp_line_tbl                 OE_ORDER_PUB.Line_Tbl_Type;
l_sch_line_tbl                 OE_ORDER_PUB.Line_Tbl_Type;
l_set_request_tbl oe_order_pub.Request_Tbl_Type;
set_request_tbl oe_order_pub.Request_Tbl_Type := p_Set_request_tbl ;
l_set_tbl                 OE_ORDER_PUB.Line_Tbl_Type;
l_old_line_tbl            OE_ORDER_PUB.Line_Tbl_Type ;
l_line_query_tbl                 OE_ORDER_PUB.Line_Tbl_Type;
l_control_rec               OE_GLOBALS.control_rec_type;
l_api_name         CONSTANT VARCHAR2(30) := 'Insert_Into_Set';
l_return_status         VARCHAR2(30);
l_query_clause          VARCHAR2(2000);
l_exist BOOLEAN := FALSE;
l_line_exist BOOLEAN := FALSE;
l_set_id NUMBER ;
l_ship_set_id NUMBER ;
l_sch_count NUMBER := 0 ;
l_header_id NUMBER ;
l_line_id NUMBER ;
l_set_type VARCHAR2(30) ;
l_set_name VARCHAR2(30) ;
l_set_rec 	OE_ORDER_CACHE.set_rec_type;
l_atp_rec                     OE_ATP.atp_tbl_type;
l_atp_tbl                     OE_ATP.atp_tbl_type;
lcnt number := 0;
l_Ship_from_org_id  NUMBER ;
l_Ship_to_org_id    NUMBER ;
l_Schedule_Ship_Date DATE ;
l_Schedule_Arrival_Date DATE ;
l_Freight_Carrier_Code  VARCHAR2(30) ;
l_Shipping_Method_Code  VARCHAR2(30) ;
l_Shipment_priority_code VARCHAR2(30);
LCOUNT NUMBER := 0;
lsettempname number;
l_top_model_line_id number;

Cursor shipset is
Select set_id from
oe_sets where
set_type = 'SHIP_SET'
and header_id = l_header_id
and ship_from_org_id = l_ship_from_org_id
and ship_to_org_id = l_ship_to_org_id
and trunc(schedule_ship_date) = trunc(l_Schedule_Ship_Date)
and nvl(set_status,'X') <> 'C'
;

Cursor arrivalset is
Select set_id from
oe_sets where
set_type = 'ARRIVAL_SET' and
header_id = l_header_id
and ship_to_org_id = l_ship_to_org_id
and trunc(schedule_arrival_date) = trunc(l_Schedule_arrival_Date)
and nvl(set_status,'X') <> 'C';

Cursor C1 is
select Max(to_number(set_name)) from
oe_sets
where
set_status = 'T'
and header_id = l_header_id and
set_type = l_set_type;

Cursor C2 is
Select Schedule_ship_date,
Ship_from_org_id,
ship_to_org_id,
schedule_arrival_date
from
oe_order_lines_all
where
line_id = l_top_model_line_id ;
/*nvl(cancelled_flag,'N') <> 'Y' and
nvl(model_remnant_flag,'N') <> 'Y'
and (
ship_model_complete_flag = 'Y' OR
ato_line_id IS NOT NULL) */

Cursor C3 is
select Max(to_number(set_name)) from
oe_sets
where
header_id = l_header_id and
set_type = l_set_type and
set_name = lsettempname;

Cursor C4 is
select set_id,
Schedule_ship_date,
Ship_from_org_id,
ship_to_org_id
from
oe_sets
where
header_id = l_header_id and
set_type = 'SHIP_SET' and
set_status = 'T';

tempname varchar2(240);

l_perform_sch boolean := TRUE;
l_model_exists boolean := FALSE;
l_x_ship_set_id number;
l_x_arrival_set_id number;


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'INSERT_INTO SETSS' , 1 ) ;
     END IF;

	IF p_set_request_tbl.count >  0 THEN
	g_cust_pref_set := TRUE;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROCESS REQUEST RECORD ' , 1 ) ;
     END IF;

	l_header_id := p_set_request_tbl(1).entity_id;
	 oe_header_util.query_row(p_header_id => l_header_id,
				x_header_rec => l_header_rec);
		IF l_header_rec.customer_preference_set_code = 'ARRIVAL' THEN
			l_set_type := 'ARRIVAL_SET';
		ELSIF l_header_rec.customer_preference_set_code = 'SHIP' THEN
			l_set_type := 'SHIP_SET';
		ELSE
			GOTO END_1;
	     	END IF;

		IF l_set_type = 'ARRIVAL_SET' THEN
     	IF l_debug_level  > 0 THEN
     	    oe_debug_pub.add(  ' INTO CALLING ARRIVAL SET ' , 1 ) ;
     	END IF;
	 Insert_Into_arrival_Set
        (p_Set_request_tbl    => p_Set_request_tbl  ,
         X_Return_Status      => l_return_status ,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data);
     	IF l_debug_level  > 0 THEN
     	    oe_debug_pub.add(  ' EXIT CALLING ARRIVAL SET ' , 1 ) ;
     	END IF;

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     	IF l_debug_level  > 0 THEN
     	    oe_debug_pub.add(  ' ARRIVAL SET UNEXPECTED ERROR ' , 1 ) ;
     	END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  ' ARRIVAL SET ' , 1 ) ;
     END IF;
                 RAISE FND_API.G_EXC_ERROR;
          END IF;

			GOTO END_1;
		END IF;



	l_temp_line_tbl.delete;
	g_old_line_tbl.delete;

	FOR I in 1..g_auto_set_tbl.count
	Loop
	Begin
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTER INTO AUTO SET TABLE LOOP ' , 1 ) ;
     END IF;
	 oe_line_util.query_row(p_line_id => g_auto_set_tbl(I).line_id,
								  x_line_rec => l_line_rec);
	IF (l_line_rec.split_from_line_id IS NOT NULL) THEN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'INVALID SPLIT LINEE'||L_LINE_REC.LINE_ID ) ;
	END IF;
		RAISE NO_DATA_FOUND;
	END IF;
	IF l_line_rec.line_category_code = 'RETURN' THEN
		RAISE NO_DATA_FOUND;
	END IF;
		g_old_line_tbl(g_old_line_tbl.count + 1) :=
          			l_line_rec;

-- Default ship set if it is already created

		OPEN C4;
 		FETCH C4
		 into
			l_ship_set_id,
                        l_schedule_ship_date,
                        l_ship_from_org_id,
                        l_ship_to_org_id;
		close C4;
			IF l_ship_set_id is not null then
			l_line_rec.schedule_ship_date := l_schedule_ship_date;
			l_line_rec.ship_Set_id := l_ship_set_id;
			l_line_rec.ship_to_org_id := l_ship_to_org_id;
			l_line_rec.ship_from_org_id := l_ship_from_org_id;
			l_set_id := l_ship_set_id;


             IF I = 1 -- Validation added as part of 2502504
             AND l_line_rec.booked_flag = 'Y' THEN

              Oe_Validate_Line.Validate_Shipset_SMC
              ( p_line_rec           =>   l_line_rec
               ,p_old_line_rec       =>   l_old_line_rec
               ,x_return_status      =>   l_return_status);

              IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 GOTO END_1;
              ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

             END IF;

			ELSE
			l_line_rec.ship_Set := '1';
			END IF;
	l_temp_line_tbl(l_temp_line_tbl.count + 1) := l_line_rec;



     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ITEM TYPE CODE IS: '||L_LINE_REC.ITEM_TYPE_CODE , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'SHIP FROM : '||L_LINE_REC.SHIP_FROM_ORG_ID , 1 ) ;
     END IF;
		IF l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_MODEL
			OR l_line_rec.item_type_code = 'KIT' THEN
				l_model_exists := TRUE;
		   Get_Options(p_x_line_tbl => l_temp_line_tbl,
					p_set_type => l_set_type,
					p_index => l_temp_line_tbl.count);
	     ELSIF l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
			l_line_rec.item_type_code = OE_GLOBALS.G_ITEM_OPTION OR
			l_line_rec.item_type_code = 'INCLUDED'  OR
			l_line_rec.item_type_code = 'CONFIG'  THEN
			l_top_model_line_id := l_line_rec.top_model_line_id;
			/*OPEN C2;
			FETCH C2 into
			l_schedule_ship_date,
			l_ship_from_org_id,
			l_ship_to_org_id,
			l_schedule_arrival_date;
			CLOSE C2;
			IF l_set_type = 'SHIP_SET' THEN
     OE_DEBUG_PUB.Add('Into Ship Set',1);
 l_temp_line_tbl(l_temp_line_tbl.count).schedule_ship_date := l_schedule_ship_date;
 l_temp_line_tbl(l_temp_line_tbl.count).ship_from_org_id := l_ship_from_org_id;
 l_temp_line_tbl(l_temp_line_tbl.count).ship_to_org_id := l_ship_to_org_id;
			 --l_perform_sch := FALSE;
			ELSIF l_set_type = 'ARRIVAL_SET' THEN
l_temp_line_tbl(l_temp_line_tbl.count).schedule_arrival_date := l_schedule_arrival_date;
l_temp_line_tbl(l_temp_line_tbl.count).ship_to_org_id := l_ship_to_org_id;
			 --l_perform_sch := FALSE;
			END IF; */
		END IF;

        Exception

        WHEN NO_DATA_FOUND THEN
                   NULL;
        WHEN OTHERS THEN
                   NULL;

        END ;-- End of get line
        END LOOP;

--	IF l_line_rec.schedule_status_code IS NULL THEN
	IF l_temp_line_tbl.count > 0 THEN
	FOR J in 1..l_temp_line_tbl.count
	LOOP
	l_temp_line_tbl(J).schedule_action_code :=
	OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE;
	l_sch_count := l_sch_count + 1;
	l_sch_line_tbl(l_sch_count) := l_temp_line_tbl(J);
			l_model_exists := false;
			IF l_temp_line_tbl(J).item_type_code = 'INCLUDED' OR
				l_temp_line_tbl(J).item_type_code = 'OPTION' OR
			l_temp_line_tbl(J).item_type_code = 'CLASS' OR
			l_temp_line_tbl(J).item_type_code = 'CONFIG' THEN
			FOR L in 1..g_auto_set_tbl.count
			LOOP
			IF l_temp_line_tbl(J).top_model_line_id =
				g_auto_set_tbl(L).line_id THEN
				l_model_exists := true;
					exit;
			END IF;
		        END LOOP;
			if not l_model_exists then
	oe_line_util.query_row(p_line_id => l_temp_line_tbl(J).top_model_line_id,
			   x_line_rec => l_model_line_rec);
			if l_model_line_rec.ship_set_id is null and
				l_model_line_rec.arrival_set_id is null THEN

			l_sch_line_tbl.delete(l_sch_count) ;
			l_sch_count := l_sch_count - 1;

			END IF;
			END IF;
			END IF;

	l_temp_line_tbl(J).schedule_action_code :=
	OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE;
	END LOOP;

-- Call scheduling
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE CALLING SCHEDULING ' , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'COUNT BEFORE CALLING : '||L_SCH_LINE_TBL.COUNT , 1 ) ;
     END IF;

	IF l_perform_sch and l_sch_line_tbl.count > 0  THEN

     OE_GRP_SCH_UTIL.Schedule_set_of_lines(p_x_line_tbl   => l_sch_line_tbl,
                                           p_old_line_tbl => g_old_line_tbl,
                                        x_return_status => l_return_status);
			g_old_line_tbl.delete;
	END IF;
			 l_perform_sch := TRUE;

          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  ' SCHEDULING UNEXPECTED ERROR ' , 1 ) ;
     END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
			GOTO END_1;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  ' EXPECTED ERROR ' , 1 ) ;
     END IF;
                 --RAISE FND_API.G_EXC_ERROR;
          END IF;

--	END IF; -- Schedule Action Code
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTER CALLIN SCHEDULING ' , 1 ) ;
     END IF;
		l_temp_line_tbl.delete;
		l_temp_line_tbl := l_sch_line_tbl;
	IF l_temp_line_tbl.count > 0 and l_ship_set_id is null THEN
      l_ship_from_org_id := l_temp_line_tbl(1).ship_from_org_id;
      l_ship_to_org_id := l_temp_line_tbl(1).ship_to_org_id;
      l_schedule_ship_date := l_temp_line_tbl(1).schedule_ship_date;
      l_schedule_arrival_date := l_temp_line_tbl(1).schedule_arrival_date;
      l_freight_carrier_code := l_temp_line_tbl(1).freight_carrier_code;
      l_shipping_method_code := l_temp_line_tbl(1).shipping_method_code;
      l_shipment_priority_code := l_temp_line_tbl(1).shipment_priority_code;
	 l_set_id := null;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'INTO CREATING SET ' , 1 ) ;
     END IF;

		IF l_set_type = 'SHIP_SET' THEN
			Open shipset;
			Fetch shipset into l_set_id;
			Close shipset;
		ELSIF l_set_type = 'ARRIVAL_SET' THEN
			Open arrivalset;
			Fetch arrivalset into l_set_id;
			Close arrivalset;
		END IF;

		IF l_set_id IS NULL THEN
		OPEN C1;
		FETCH C1 INTO lsettempname;
	     CLOSE C1;
	 IF lsettempname IS NULL THEN
		lsettempname := 1;

		LOOP
			OPEN C3;
			FETCH C3 INTO tempname;
	     	CLOSE C3;
				IF tempname is not null then
					lsettempname := lsettempname + 1;
				ELSE
					EXIT;
				END IF;
		END LOOP ;

	 ELSE
	     lsettempname := lsettempname + 1;
	END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  ' BEFORE CREATING SET ' , 1 ) ;
     END IF;
     Create_Set
        (p_Set_Name => to_char(lsettempname),
         p_Set_Type => l_set_type,
         p_Header_Id => l_header_id,
         p_Ship_From_Org_Id => l_ship_from_org_id,
         p_Ship_To_Org_Id   => l_Ship_To_Org_Id,
         p_Schedule_Ship_Date  => l_schedule_ship_Date,
         p_Schedule_Arrival_Date => l_Schedule_Arrival_Date,
         p_Freight_Carrier_Code  => l_Freight_Carrier_Code,
         p_Shipping_Method_Code   => l_Shipping_Method_Code,
         p_Shipment_priority_code  => l_Shipment_priority_code,
         x_Set_Id                 => l_set_id,
         X_Return_Status  => l_return_status,
          x_msg_count      => x_msg_count,
      	x_msg_data       => x_msg_data);
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
      END IF;

		END IF; -- if set id is null
		END IF; -- Temp table intenal if condition
     END IF ; -- If temp table is greater than zero

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  ' SET ID IS '|| L_SET_ID , 1 ) ;
     END IF;

	FOR K in 1..l_temp_line_tbl.count
	LOOP
		IF l_set_type = 'SHIP_SET' THEN
	l_temp_line_tbl(K).ship_Set_id := l_set_id;
		ELSIF l_set_type = 'ARRIVAL_SET' THEN
	l_temp_line_tbl(K).arrival_Set_id := l_set_id;
	    END IF;
	l_temp_line_tbl(K).operation := oe_globals.g_opr_update;
	END LOOP;

		FOR L in 1..l_temp_line_tbl.count
		LOOP
		l_line_tbl(l_line_tbl.count+1) := l_temp_line_tbl(L);
		END LOOP;



/*	Exception

	WHEN NO_DATA_FOUND THEN
		   NULL;
	WHEN OTHERS THEN
		   NULL;

	END ;-- End of get line
	END LOOP; */
		FOR I in 1..l_line_tbl.count
		LOOP
			l_model_exists := false;
			IF l_line_tbl(I).item_type_code = 'INCLUDED' OR
				l_line_tbl(I).item_type_code = 'OPTION' OR
			l_line_tbl(I).item_type_code = 'CLASS' THEN
			FOR J in 1..l_line_tbl.count
			LOOP
			IF l_line_tbl(I).top_model_line_id =
				l_line_tbl(J).line_id THEN
				l_model_exists := true;
					exit;
			END IF;
		        END LOOP;
			if not l_model_exists then
	oe_line_util.query_row(p_line_id => l_line_tbl(I).top_model_line_id,
			   x_line_rec => l_model_line_rec);
			IF l_model_line_rec.ship_set_id is null then
				l_line_tbl(I).ship_set_id := NULL;
			ELSIF l_model_line_rec.ship_set_id is not null then
				l_line_tbl(I).ship_set_id :=
				l_model_line_rec.ship_set_id;


			END IF;
			IF l_model_line_rec.arrival_set_id is null then
				l_line_tbl(I).arrival_set_id := NULL;
			ELSIF l_model_line_rec.arrival_set_id is not null then
				l_line_tbl(I).arrival_set_id :=
				l_model_line_rec.arrival_set_id;
			END IF;
			END IF;
			END IF;


		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SHIP SET IS-'||L_LINE_TBL ( I ) .SHIP_SET_ID , 1 ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'LINE -'||L_LINE_TBL ( I ) .LINE_ID , 1 ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ITEM TYPE -'||L_LINE_TBL ( I ) .ITEM_TYPE_CODE , 1 ) ;
		END IF;
		END LOOP;

	IF l_line_tbl.count > 0 THEN


-- Call Process Order
          l_control_rec.controlled_operation := TRUE;
          l_control_rec.write_to_db := TRUE;
          l_control_rec.PROCESS := FALSE;
          l_control_rec.default_attributes := TRUE;
          l_control_rec.change_attributes := TRUE;
          l_control_rec.validate_entity :=TRUE;


     OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'N';
          g_set_recursive_flag := TRUE;
     oe_order_pvt.Lines
(   p_validation_level  =>    FND_API.G_VALID_LEVEL_NONE
,   p_control_rec       => l_control_rec
,   p_x_line_tbl         =>  l_line_tbl
,   p_x_old_line_tbl    =>  l_old_line_tbl
,   x_return_status     => l_return_status

);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

/* jolin start comment out nocopy for notification project

-- Api to call notify OC and ACK and to process delayed requests

OE_Order_PVT.Process_Requests_And_Notify
          ( p_process_requests          => FALSE
          , p_notify                    => TRUE
          , x_return_status             => l_return_status
          , p_line_tbl                  => l_line_tbl
          , p_old_line_tbl             => l_old_line_tbl
          );
jolin end */

	l_line_tbl.delete;

     OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
          g_set_recursive_flag := FALSE;
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

  END IF; -- IF line table is greate than Zero

	g_cust_pref_set := TRUE;

END IF;
		g_auto_set_tbl.delete;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  ' EXIT INSERT INTO SETS' , 1 ) ;
     END IF;

<<END_1>>
NULL;
	g_auto_set_tbl.delete;
	g_cust_pref_set := TRUE;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data


        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'IN INSERINTO EXCEPTION ' , 1 ) ;
     END IF;
        RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Into_Set'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

End Insert_Into_Set;



Procedure Update_Set
        (p_Set_Id                       IN NUMBER,
         p_Ship_From_Org_Id             IN NUMBER := FND_API.G_MISS_NUM,
         p_Ship_To_Org_Id               IN NUMBER := FND_API.G_MISS_NUM,
         p_Schedule_Ship_Date           IN DATE := FND_API.G_MISS_DATE,
         p_Schedule_Arrival_Date        IN DATE := FND_API.G_MISS_DATE,
         p_Freight_Carrier_Code         IN VARCHAR2 := FND_API.G_MISS_CHAR,
         p_Shipping_Method_Code IN VARCHAR2 := FND_API.G_MISS_CHAR,
         p_shipment_priority_code       IN VARCHAR2 := FND_API.G_MISS_CHAR,
X_Return_Status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

)IS
l_set_rec 	OE_ORDER_CACHE.set_rec_type;
l_init_set_rec 	OE_ORDER_CACHE.set_rec_type;
  l_Ship_From_Org_Id              NUMBER ;
  l_Ship_To_Org_Id               NUMBER ;
  l_Schedule_Ship_Date           DATE ;
  l_Schedule_Arrival_Date         DATE ;
  l_Freight_Carrier_Code          VARCHAR2(30);
  l_Shipping_Method_Code  VARCHAR2(30) ;
  l_shipment_priority_code      VARCHAR2(30);
  l_Return_Status                VARCHAR2(30);

   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
Begin
l_set_rec := get_set_rec(p_set_id);
	IF (p_ship_from_org_id = fnd_api.g_miss_num or
	   p_ship_from_org_id IS NULL )THEN
 	l_Ship_From_Org_Id  := l_set_rec.Ship_From_Org_Id ;
	ELSE
	l_Ship_From_Org_Id  := p_Ship_From_Org_Id ;
	END IF;

	IF (p_ship_to_org_id = fnd_api.g_miss_num or
	   p_ship_from_org_id IS NULL )THEN
 	l_Ship_to_Org_Id  := l_set_rec.Ship_to_Org_Id ;
	ELSE
	l_Ship_to_Org_Id  := p_Ship_to_Org_Id ;
	END IF;

	IF (p_Schedule_Arrival_Date = fnd_api.g_miss_date or
	   p_Schedule_Arrival_Date IS NULL )THEN
 	l_Schedule_Arrival_Date  := l_set_rec.Schedule_Arrival_Date;
	ELSE
	l_Schedule_Arrival_Date  := p_Schedule_Arrival_Date ;
	END IF;

	IF (p_Schedule_ship_Date = fnd_api.g_miss_date or
	   p_Schedule_ship_Date IS NULL )THEN
 	l_Schedule_ship_Date  := l_set_rec.Schedule_ship_Date;
	ELSE
	l_Schedule_ship_Date  := p_Schedule_ship_Date ;
	END IF;

	IF (p_Freight_Carrier_Code = fnd_api.g_miss_char or
	   p_Freight_Carrier_Code IS NULL )THEN
 	l_Freight_Carrier_Code  := l_set_rec.Freight_Carrier_Code;
	ELSE
	l_Freight_Carrier_Code := p_Freight_Carrier_Code ;
	END IF;

	IF p_Shipping_Method_Code = fnd_api.g_miss_char
	THEN
 	l_Shipping_Method_Code  := l_set_rec.Shipping_Method_Code;
	ELSE
	l_Shipping_Method_Code := p_Shipping_Method_Code ;
	END IF;

	IF (p_shipment_priority_code = fnd_api.g_miss_char or
	   p_shipment_priority_code IS NULL )THEN
 	l_shipment_priority_code  := l_set_rec.shipment_priority_code;
	ELSE
	l_shipment_priority_code := p_shipment_priority_code ;
	END IF;

	UPDATE OE_SETS SET
	ship_from_org_id = l_ship_from_org_id,
	ship_to_org_id   = l_ship_to_org_id,
	Schedule_Arrival_Date = l_Schedule_Arrival_Date,
   	Schedule_Ship_Date = l_Schedule_Ship_Date,
        Freight_Carrier_Code = l_Freight_Carrier_Code ,
        Shipping_Method_Code  =  l_Shipping_Method_Code,
        shipment_priority_code  = l_shipment_priority_code
	WHERE SET_ID = P_SET_ID;


Null;
		g_set_rec := l_init_set_rec;
		--FP bug 3891395: setting the return status
		x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data


        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_set'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
End Update_Set;

FUNCTION get_set_rec(p_set_id IN NUMBER)
RETURN OE_ORDER_CACHE.set_rec_type IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin
  --Performance regression. Reverted the changes made earlier for Bug4080531
  IF g_set_rec.set_id IS NULL OR
   g_set_rec.set_id <> p_set_id THEN

  g_set_rec := OE_ORDER_CACHE.Load_Set(p_set_id);
  RETURN g_set_rec;

  ELSE
  RETURN g_set_rec;
END IF;

END get_set_rec;

PROCEDURE Validate_set_attributes(p_set_id IN NUMBER ,
       p_Ship_From_Org_Id IN NUMBER := FND_API.G_MISS_NUM,
       p_Ship_To_Org_Id   IN NUMBER := FND_API.G_MISS_NUM,
       p_Schedule_Ship_Date  IN DATE := FND_API.G_MISS_DATE,
       p_Schedule_Arrival_Date IN DATE := FND_API.G_MISS_DATE,
       p_Freight_Carrier_Code IN VARCHAR2 := FND_API.G_MISS_CHAR,
       p_Shipping_Method_Code  IN VARCHAR2 := FND_API.G_MISS_CHAR,
         p_shipment_priority_code       IN VARCHAR2 := FND_API.G_MISS_CHAR,
X_Return_Status OUT NOCOPY VARCHAR2) IS

l_set_rec OE_ORDER_CACHE.set_rec_type;
x_msg_count NUMBER;
x_msg_data VARCHAR2(254);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

l_set_rec := get_set_rec(p_set_id);
	IF (l_set_rec.set_type = 'SHIP_SET') THEN
		IF (p_Ship_From_Org_Id <> l_set_rec.ship_from_org_id) OR
		(p_Ship_To_Org_Id <> l_Set_rec.Ship_To_Org_Id) OR
		(p_Schedule_Ship_Date <> l_set_rec.Schedule_ship_Date) OR
		(p_Freight_Carrier_Code <> l_set_rec.Freight_Carrier_Code) OR
		(p_Shipping_Method_Code <> l_set_rec.Shipping_Method_Code) OR
		(p_shipment_priority_code <>  l_set_rec.shipment_priority_code) THEN
			--RAISE FND_API.G_EXC_ERROR;
          fnd_message.set_name('ONT', 'OE_INVALID_SET_ATTR');
	  FND_MESSAGE.SET_TOKEN('SET','SHIP');
          oe_msg_pub.add;
        --  RAISE FND_API.G_EXC_ERROR ;

			NULL;
		END IF;
	ELSIF (l_set_rec.set_type = 'ARRIVAL_SET') THEN
		IF (p_Schedule_Arrival_Date <> l_set_rec.Schedule_Arrival_Date) OR
		(p_Ship_To_Org_Id <> l_Set_rec.Ship_To_Org_Id) THEN
          fnd_message.set_name('ONT', 'OE_INVALID_SET_ATTR');
	  FND_MESSAGE.SET_TOKEN('SET','ARRIVAL');
          oe_msg_pub.add;
          --RAISE FND_API.G_EXC_ERROR ;
			NULL;
		END IF;
       END IF;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data


        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_Set_Attributes'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
NULL;
END Validate_set_attributes;



Procedure Process_Sets
(   p_selected_line_tbl    IN OE_GLOBALS.Selected_Record_Tbl, -- R12.MOAC
    p_record_count	   IN NUMBER,
    p_set_name             IN VARCHAR2,
    p_set_type             IN VARCHAR2 := FND_API.G_MISS_CHAR,
    p_operation            IN VARCHAR2,
    p_header_id            IN VARCHAR2 := FND_API.G_MISS_CHAR,
x_Set_Id OUT NOCOPY NUMBER,

x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2

) IS
l_num_of_records            NUMBER := p_record_count;
l_line_rec                  OE_ORDER_PUB.line_rec_type;
l_in_line_rec               OE_ORDER_PUB.line_rec_type;
l_control_rec               OE_GLOBALS.Control_Rec_Type;
l_line_tbl                  OE_ORDER_PUB.Line_Tbl_Type;
l_line_opt_tbl              OE_ORDER_PUB.Line_Tbl_Type;
l_line_opt_temp_tbl         OE_ORDER_PUB.Line_Tbl_Type;
l_old_line_tbl              OE_ORDER_PUB.Line_Tbl_Type;
l_api_name         CONSTANT VARCHAR2(30)   := 'Process_sets';
l_line_id                   NUMBER;
l_return_status             VARCHAR2(30);
l_header_id                 NUMBER := to_number(p_header_id);
I                           NUMBER := 0;
j                           INTEGER;
initial                     INTEGER;
nextpos                     INTEGER;
--l_record_ids              varchar2(32000) := p_record_ids || ','; --R12.MOAC
l_set_id                    NUMBER;
l_set_type                  VARCHAR2(80);
l_exists                    BOOLEAN := FALSE ;
l_Ship_from_org_id          NUMBER ;
l_Ship_to_org_id            NUMBER ;
l_Schedule_Ship_Date        DATE ;
l_Schedule_Arrival_Date     DATE ;
l_Freight_Carrier_Code      VARCHAR2(30) ;
l_Shipping_Method_Code      VARCHAR2(30) ;
l_Shipment_priority_code    VARCHAR2(30);
l_set_rec                   OE_ORDER_CACHE.set_rec_type;
l_debug_level CONSTANT      NUMBER := oe_debug_pub.g_debug_level;
-- 4925992
l_top_model_line_id         NUMBER;
BEGIN

  SAVEPOINT Process_sets;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

/* If the profile to process new set schduling functioanlity after
performance changes is set to Yest then branch the code to new
procedure or continue */

  --Bug4504362
  IF p_set_type <>  'FULFILLMENT' THEN

    --R12.MOAC
    New_Process_Sets
   (p_selected_line_tbl => p_selected_line_tbl,
    p_record_count     => p_record_count,
    p_set_name         => p_set_name,
    p_set_type         => p_set_type,
    p_operation        => p_operation,
    p_header_id        => p_header_id ,
    x_Set_Id           => x_set_id ,
    x_return_status    => x_return_status,
    x_msg_count        => x_msg_count,
    x_msg_data         => x_msg_data );

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    GOTO END_NEW_PROCESS_SETS;

  END IF;


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'PROCEDURE PROCESS SETS' , 1 ) ;
  END IF;

  j := 1;
  initial := 1;
  --nextpos := INSTR(l_record_ids,',',1,j) ; --R12.MOAC

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SET NAME IS-' || P_SET_NAME , 1 ) ;
  END IF;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SET TYPE IS-' || P_OPERATION , 1 ) ;
  END IF;

  IF p_set_name is not null THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SET TYPE IS-' || P_SET_TYPE , 1 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SET TYPE IS-' || P_OPERATION , 1 ) ;
    END IF;

 	IF p_set_type = 'ARRIVAL' THEN
		l_set_type := 'ARRIVAL_SET';
	ELSIF p_set_type = 'SHIP' THEN
		l_set_type := 'SHIP_SET';
	ELSIF p_set_type = 'FULFILLMENT' THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INTO FULFILLMENT SETS' , 1 ) ;
        END IF;
		l_set_type := 'FULFILLMENT_SET';
	END IF;

	l_exists :=  Set_Exist(p_set_name  => p_set_name,
                           p_set_type  => l_set_type,
	                       p_header_id => l_header_id,
                           x_set_id    => l_set_id);

    IF l_set_id IS NOT NULL  THEN

    -- bug8420761
    g_set_rec := OE_ORDER_CACHE.Load_Set(l_set_id); -- refresh the cache record
    ---end bug8420761

       IF is_set_closed(l_set_id) THEN

          fnd_message.set_name('ONT', 'OE_SET_CLOSED');
          FND_MESSAGE.SET_TOKEN('SET', p_set_name);
          oe_msg_pub.add;
      	  RAISE FND_API.G_EXC_ERROR;
       END IF;
	END IF;

    IF (p_operation = 'REMOVE' AND
		l_set_type <> 'FULFILLMENT_SET') THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INTO REMOVE' , 1 ) ;
        END IF;
		l_exists := TRUE;
		l_set_id := NULL;
    END IF;

  END IF; -- Set name.


  IF (p_operation = 'REMOVE' AND
      p_set_type <> 'FULFILLMENT_SET') THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INTO REMOVE' , 1 ) ;
    END IF;
	l_exists := TRUE;

  END IF;


  IF l_exists and p_operation <> 'REMOVE' THEN
     l_set_rec := get_set_rec(l_set_id);
  END IF;


 --R12.MOAC Start
 FOR K IN 1..p_selected_line_tbl.count LOOP

    l_line_id := p_selected_line_tbl(K).id1;
 /*
 FOR K IN 1..l_num_of_records LOOP

  l_line_id := to_number(substr(l_record_ids,initial, nextpos-initial));
  initial := nextpos + 1.0;
  j := j + 1.0;
  nextpos := INSTR(l_record_ids,',',1,j) ;
  */
 --R12.MOAC End
  OE_LINE_UTIL.lock_row
  (p_line_id       => l_line_id
  ,p_x_line_rec    => l_line_rec
  ,x_return_status => l_return_status);

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR;
  END IF;

  OE_MSG_PUB.set_msg_context
        ( p_entity_code     => 'LINE'
         ,p_entity_id       => l_line_rec.line_id
         ,p_header_id       => l_line_rec.header_id
         ,p_line_id         => l_line_rec.line_id
         ,p_order_source_id            => l_line_rec.order_source_id
         ,p_orig_sys_document_ref      => l_line_rec.orig_sys_document_ref
         ,p_orig_sys_document_line_ref => l_line_rec.orig_sys_line_ref
         ,p_orig_sys_shipment_ref      => l_line_rec.orig_sys_shipment_ref
         ,p_change_sequence            => l_line_rec.change_sequence
         ,p_source_document_type_id    => l_line_rec.source_document_type_id
         ,p_source_document_id         => l_line_rec.source_document_id
         ,p_source_document_line_id    => l_line_rec.source_document_line_id);


  -- Bug 2427798/2446437
  IF ((nvl(l_line_rec.source_type_code,'X') = 'EXTERNAL')
      AND (p_set_type <> 'FULFILLMENT'))
  OR (nvl(l_line_rec.shipped_quantity,0) > 0 AND p_set_type <> 'FULFILLMENT')  -- 2525203
  OR (nvl(l_line_rec.fulfilled_flag,'N') =  'Y' AND
        (p_set_type <>  'FULFILLMENT' OR Fulfill_Sts(l_line_id)<>'NOTIFIED'))  -- 2525203
  OR nvl(l_line_rec.open_flag,'N') =  'N'
  OR (l_line_rec.line_category_code = 'RETURN' AND
      p_set_type <> 'FULFILLMENT')   THEN

     FND_MESSAGE.SET_NAME('ONT','OE_INVALID_SET_OPR');
     OE_MSG_PUB.ADD;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'LINE IS NOT VALID TO ADD: ' || L_LINE_REC.LINE_ID , 1 ) ;
     END IF;
     GOTO do_not_process;

  END IF;

  I := I +1;
  l_line_tbl(I) := l_line_rec;

  g_old_line_tbl(I) := l_line_tbl(I);

/*	IF (nvl(l_line_tbl(I).source_type_code,'X') = 'EXTERNAL' OR
	    nvl(l_line_tbl(I).shipped_quantity,0) > 0 OR
	nvl(l_line_tbl(I).fulfilled_flag,'N') =  'Y' OR
	nvl(l_line_tbl(I).open_flag,'N') =  'N' OR
		l_line_tbl(I).line_category_code = 'RETURN' )  THEN
			GOTO do_not_process;
	END IF;
*/


  IF (l_line_tbl(I).item_type_code <> 'MODEL' AND
      l_line_tbl(I).item_type_code <> 'STANDARD' AND
      l_line_tbl(I).item_type_code <> 'KIT' AND
      l_line_tbl(I).item_type_code <> 'SERVICE' AND
	  nvl(l_line_tbl(I).model_remnant_flag,'N') <> 'Y')
  OR (l_line_tbl(I).item_type_code = 'SERVICE'
      AND p_set_type  =  'FULFILLMENT'
      AND NOT Is_Service_Eligible(l_line_tbl(I)))
  OR (l_line_tbl(I).item_type_code = 'SERVICE'
      AND (p_set_type  =  'ARRIVAL'
       OR  p_set_type  = 'SHIP'))  THEN


      FND_MESSAGE.SET_NAME('ONT','OE_INVALID_SET_OPR');
 --     FND_MESSAGE.SET_TOKEN('ITEMTYPE',
  --                          l_line_tbl(I).item_type_code);
      OE_MSG_PUB.ADD;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SET- NOT ALLOWED FOR THIS ITEMTYPE' ) ;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_set_type = 'ARRIVAL' THEN

	IF (p_operation = 'ADD' ) THEN

/* Added the following if condition to fix the bug 2802249 */

             IF l_line_tbl(I).ship_set_id is not null or
                l_line_tbl(I).ship_set is not null THEN
                /* Changed the message to fix the bug 2862565  */
               -- FND_MESSAGE.Set_Name('ONT', 'OE_INVALID_SET_COMB');
                  FND_MESSAGE.Set_Name('ONT','OE_SCH_NOT_IN_SHIP_ARR');
                /* Changed the message to fix the bug 2862565  */
                  oe_msg_pub.add;
                  RAISE FND_API.G_EXC_ERROR;
             END IF;

	 IF (l_set_id IS NULL) THEN
     	  l_line_tbl(I).arrival_set := p_set_name ;
	 ELSE
	      l_line_tbl(I).arrival_set_id := l_set_id ;
	 END IF;

    ELSIF (p_operation = 'MOVE') THEN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROCEDURE PROCESS SETS'||TO_CHAR ( L_SET_ID ) , 1 ) ;
     END IF;
	 IF l_set_id IS NOT NULL THEN
	    l_line_tbl(I).arrival_set_id := l_set_id ;
	    l_line_tbl(I).arrival_set := p_set_name ;
	 ELSE
	    l_line_tbl(I).arrival_set_id := NULL ;
	    l_line_tbl(I).arrival_set := p_set_name ;
	 END IF;

    ELSIF (p_operation = 'REMOVE') THEN

        l_line_tbl(I).arrival_set_id := NULL ;
    END IF;

  ELSIF p_set_type = 'SHIP' THEN

    IF (p_operation = 'ADD' ) THEN

	 IF (l_set_id IS NULL) THEN
	     l_line_tbl(I).ship_set := p_set_name ;
	 ELSE
	     l_line_tbl(I).ship_set_id := l_set_id ;
	 END IF;

    ELSIF (p_operation = 'MOVE') THEN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROCEDURE PROCESS SETS'||TO_CHAR ( L_SET_ID ) , 1 ) ;
     END IF;
     IF l_set_id IS NOT NULL THEN
	    l_line_tbl(I).ship_set_id := l_set_id ;
	    l_line_tbl(I).ship_set := p_set_name ;
	 ELSE
	    l_line_tbl(I).ship_set_id := NULL ;
	    l_line_tbl(I).ship_set := p_set_name ;
	 END IF;

    ELSIF (p_operation = 'REMOVE') THEN

  	    l_line_tbl(I).ship_set_id := NULL ;
    END IF;

  ELSIF p_set_type = 'FULFILLMENT' THEN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'INTO FULFILLMENT SETS-2' , 1 ) ;
    END IF;
    IF (p_operation = 'ADD' ) THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INTO FULFILLMENT SETS-3' , 1 ) ;
      END IF;
	  IF (l_set_id IS NULL) THEN
	      l_line_tbl(I).fulfillment_set := p_set_name ;
	  ELSE
	      l_line_tbl(I).fulfillment_set_id := l_set_id ;
	      IF l_line_tbl(I).item_type_code = 'MODEL' OR
		     l_line_tbl(I).item_type_code = 'KIT' THEN

             l_line_opt_tbl(1) := l_line_tbl(I);
		     Get_Options(p_x_line_tbl => l_line_opt_tbl,
                         p_set_type => l_set_type,
                         p_index => 1);

             FOR Optrec in 1..l_line_opt_tbl.count
             LOOP
                -- 4925992
                IF l_line_opt_tbl(optrec).line_id = l_line_opt_tbl(optrec).top_model_line_id
                   AND l_line_opt_tbl(optrec).operation <> 'CREATE'
                THEN
                   l_top_model_line_id := l_line_opt_tbl(optrec).line_id;
                ELSE
                   l_top_model_line_id := NULL;
                END IF;
                Create_Fulfillment_Set(p_line_id           => l_line_opt_tbl(optrec).line_id,
                                       -- 4925992
                                       p_top_model_line_id => l_top_model_line_id,
                                       p_set_id  => l_set_id);
             END LOOP;
					l_line_opt_tbl.delete;

	      END IF;
	      IF l_line_tbl(I).item_type_code <> 'MODEL' THEN

             Create_Fulfillment_Set
                  (p_line_id => l_line_id,
                   p_set_id => l_set_id);
	      END IF;
	  END IF;
    ELSIF (p_operation = 'MOVE') THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PROCEDURE PROCESS SETS'||TO_CHAR ( L_SET_ID ) , 1 ) ;
      END IF;
	  IF l_set_id IS NOT NULL THEN
	     l_line_tbl(I).fulfillment_set_id := l_set_id ;
	     l_line_tbl(I).fulfillment_set := p_set_name ;

         IF l_line_tbl(I).item_type_code = 'MODEL' OR
		    l_line_tbl(I).item_type_code = 'KIT' THEN

            l_line_opt_tbl(1) := l_line_tbl(I);
		    Get_Options(p_x_line_tbl => l_line_opt_tbl,
					    p_set_type   => l_set_type,
					    p_index      => 1);

            FOR Optrec in 1..l_line_opt_tbl.count
            LOOP
               -- 4925992
               IF l_line_opt_tbl(optrec).line_id = l_line_opt_tbl(optrec).top_model_line_id
                  AND l_line_opt_tbl(optrec).operation <> 'CREATE'
               THEN
                  l_top_model_line_id := l_line_opt_tbl(optrec).line_id;
               ELSE
                  l_top_model_line_id := NULL;
               END IF;
               Create_Fulfillment_Set(p_line_id           => l_line_opt_tbl(optrec).line_id,
                                      -- 4925992
                                      p_top_model_line_id => l_top_model_line_id,
                                      p_set_id  => l_set_id);
            END LOOP;

            l_line_opt_tbl.delete;

         END IF;

         IF l_line_tbl(I).item_type_code <> 'MODEL' THEN
            Create_Fulfillment_Set
            (p_line_id => l_line_id,
             p_set_id => l_set_id);
	     END IF;
	  ELSE

   	     l_line_tbl(I).fulfillment_set_id := NULL ;
	     l_line_tbl(I).fulfillment_set := p_set_name ;
	  END IF;
    ELSIF (p_operation = 'REMOVE') THEN

	  l_line_tbl(I).fulfillment_set_id := l_set_id ;
	  IF l_line_tbl(I).item_type_code = 'MODEL' OR
		 l_line_tbl(I).item_type_code = 'KIT' THEN

         l_line_opt_tbl(1) := l_line_tbl(I);
         Get_Options(p_x_line_tbl => l_line_opt_tbl,
					 p_set_type   => l_set_type,
					 p_index      => 1);

         FOR Optrec in 1..l_line_opt_tbl.count
         LOOP

	  	    Delete_Fulfillment_Set
               (p_line_id => l_line_opt_tbl(optrec).line_id,
                p_set_id => l_Set_id);
         END LOOP;

         l_line_opt_tbl.delete;

      END IF;

	  IF l_line_tbl(I).item_type_code <> 'MODEL' THEN

         Delete_Fulfillment_Set
              (p_line_id => l_line_id,
               p_set_id => l_Set_id);
      END IF;

    END IF; -- Action

  END IF; -- type of set

  IF p_set_type <> 'FULFILLMENT'  THEN

    -- Get Options
    l_line_tbl(I).schedule_action_code :=
         OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE;

    IF l_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_MODEL
    OR l_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_KIT THEN
		l_in_line_rec := l_line_tbl(I);
		   Get_Options(p_x_line_tbl => l_line_opt_temp_tbl,
					p_set_type => l_set_type,
					p_index => I,
					p_line_id => l_line_tbl(I).line_id,
					p_line_rec => l_in_line_rec);
    END IF;

  END IF;

  l_line_tbl(I).operation := OE_GLOBALS.G_OPR_UPDATE;
  FOR t in 1..l_line_tbl.count
  LOOP
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'IN LOOP' ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'SHIP SET' || L_LINE_TBL ( T ) .SHIP_SET_ID ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'SHIP TO' || L_LINE_TBL ( T ) .SHIP_TO_ORG_ID ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'SHIP FROM' || L_LINE_TBL ( T ) .SHIP_FROM_ORG_ID ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'SHIP FROM' || L_LINE_TBL ( T ) .ITEM_TYPE_CODE ) ;
	END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SCH DATE' || TO_CHAR ( L_LINE_TBL ( T ) .SCHEDULE_SHIP_DATE , 'DD-MON-YY' ) ) ;
    END IF;
  END LOOP;

  FOR t in 1..l_line_opt_temp_tbl.count
  LOOP
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'OPTION TABLE' ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ITEM TYPE' || L_LINE_OPT_TEMP_TBL ( T ) .ITEM_TYPE_CODE ) ;
	END IF;
	l_line_opt_tbl(l_line_opt_tbl.count +1 ) := l_line_opt_temp_tbl(t);
  END LOOP;

  l_line_opt_temp_tbl.delete;

  << do_not_process >>
		NULL;

 END LOOP;

 I := Null;
		For t in 1..l_line_opt_tbl.count
		loop
	l_line_tbl(l_line_tbl.count +1 ) := l_line_opt_tbl(t);
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'OPTION TABLE' ) ;
		END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ITEM TYPE' || L_LINE_OPT_TBL ( T ) .ITEM_TYPE_CODE ) ;
	END IF;
		end loop;

		g_old_line_tbl.delete;
		For t in 1..l_line_tbl.count
		loop
	oe_line_util.query_row(p_line_id => l_line_tbl(t).line_id,
						x_line_rec => l_line_rec);
		g_old_line_tbl(t) := l_line_rec;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'OUT LOOP' ) ;
	END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SHIP SET' || L_LINE_TBL ( T ) .SHIP_SET_ID ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SHIP TO' || L_LINE_TBL ( T ) .SHIP_TO_ORG_ID ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SHIP FROM' || L_LINE_TBL ( T ) .SHIP_FROM_ORG_ID ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SHIP FROM' || L_LINE_TBL ( T ) .ITEM_TYPE_CODE ) ;
		END IF;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SCH DATE' || TO_CHAR ( L_LINE_TBL ( T ) .SCHEDULE_SHIP_DATE , 'DD-MON-YY' ) ) ;
END IF;
		end loop;

	IF p_set_type <> 'FULFILLMENT'  THEN

		FOR Setrec in 1..l_line_tbl.count
		LOOP
		l_line_tbl(setrec).schedule_action_code :=
		OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE;
		IF p_set_type = 'SHIP' THEN
		IF p_operation =  'REMOVE' THEN
		l_line_tbl(setrec).ship_set_id := NULL;
		ELSE
		l_line_tbl(setrec).ship_set_id := l_set_id;
		END IF;
		ELSIF p_set_type = 'ARRIVAL' THEN
		 IF p_operation =  'REMOVE' THEN
		l_line_tbl(setrec).arrival_set_id := NULL;
		ELSE
		l_line_tbl(setrec).arrival_set_id := l_set_id;
		END IF;
		END IF;
		END LOOP;

	END IF;


		IF l_exists AND p_operation <>  'REMOVE' THEN

	IF p_set_type <> 'FULFILLMENT'  THEN
	FOR I IN 1 .. l_line_tbl.COUNT
	LOOP
		IF l_set_type = 'SHIP_SET' THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SHIP_TO_ORG_ID'||L_LINE_TBL ( I ) .SHIP_TO_ORG_ID ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SHIP_FROM_ORG_ID'||L_LINE_TBL ( I ) .SHIP_FROM_ORG_ID ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SHIP_RG_ID'||L_SET_REC.SHIP_FROM_ORG_ID ) ;
		END IF;
	   l_line_tbl(I).schedule_ship_date := l_set_rec.schedule_ship_date;
	   l_line_tbl(I).ship_to_org_id := l_set_rec.ship_to_org_id;
	    l_line_tbl(I).ship_from_org_id := l_set_rec.ship_from_org_id;
	    ELSIF l_set_type = 'ARRIVAL_SET' THEN
	    l_line_tbl(I).schedule_arrival_date := l_set_rec.schedule_arrival_date;
	   l_line_tbl(I).ship_to_org_id := l_set_rec.ship_to_org_id;
	   END IF;
	END LOOP;
	END IF;
	ELSIF NOT l_exists AND p_operation <>  'REMOVE' THEN

	IF p_set_type <> 'FULFILLMENT'  THEN
     FOR I IN 2 .. l_line_tbl.COUNT
     LOOP
		IF l_set_type = 'SHIP_SET' THEN
	 l_line_tbl(I).schedule_ship_date := l_line_tbl(1).schedule_ship_date;
	l_line_tbl(I).ship_to_org_id := l_line_tbl(1).ship_to_org_id;
     l_line_tbl(I).ship_from_org_id := l_line_tbl(1).ship_from_org_id;
     l_line_tbl(I).ship_set := l_line_tbl(1).ship_set;
	    ELSIF l_set_type = 'ARRIVAL_SET' THEN
     l_line_tbl(I).schedule_arrival_date := l_line_tbl(1).schedule_arrival_date;
	l_line_tbl(I).ship_to_org_id := l_line_tbl(1).ship_to_org_id;
	l_line_tbl(I).arrival_set := l_line_tbl(1).arrival_set;
	    END IF;
     END LOOP;
	END IF;


	    END IF;  -- lexists

	IF NOT l_exists and p_set_name IS NULL THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE FAILING AT SET NAME' , 1 ) ;
     END IF;
          fnd_message.set_name('ONT', 'OE_SET_NAME_REQ');
          oe_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR ;
	END IF;
	IF p_operation <>  'REMOVE' THEN
	IF p_set_type <> 'FULFILLMENT'
    AND l_line_tbl.count > 0 THEN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'BEFORE CALLING SCHEDULET'|| L_LINE_TBL.COUNT ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'BEFORE CALLING SCHEDULET'|| G_OLD_LINE_TBL.COUNT ) ;
	END IF;
		For t in 1..l_line_tbl.count
		loop
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'BEFORE CALLING SCHEDULET' ) ;
	END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SHIP SET' || L_LINE_TBL ( T ) .SHIP_SET_ID ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SHIP TO' || L_LINE_TBL ( T ) .SHIP_TO_ORG_ID ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SHIP FROM' || L_LINE_TBL ( T ) .SHIP_FROM_ORG_ID ) ;
		END IF;
		end loop;

	OE_GRP_SCH_UTIL.Schedule_set_of_lines(p_x_line_tbl   => l_line_tbl,
								   p_old_line_tbl => g_old_line_tbl,
								x_return_status => l_return_status);
			g_old_line_tbl.delete;

		IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
			  RAISE FND_API.G_EXC_ERROR;
	     END IF;
	END IF;
	END IF;


    IF l_line_tbl.count > 0 THEN
	IF NOT l_exists THEN
	IF p_set_type <> 'FULFILLMENT' THEN

	IF p_set_type = 'SHIP' THEN
	 l_ship_from_org_id := l_line_tbl(1).ship_from_org_id;
	 l_ship_to_org_id := l_line_tbl(1).ship_to_org_id;
	 l_schedule_ship_date := l_line_tbl(1).schedule_ship_date;
	 ELSIF p_set_type = 'ARRIVAL' THEN
	 l_schedule_arrival_date := l_line_tbl(1).schedule_arrival_date;
	 l_ship_to_org_id := l_line_tbl(1).ship_to_org_id;
	 END IF;
	 --l_freight_carrier_code := l_line_tbl(1).freight_carrier_code;
	 --l_shipping_method_code := l_line_tbl(1).shipping_method_code;
	 --l_shipment_priority_code := l_line_tbl(1).shipment_priority_code;
	 END IF;
     		IF l_debug_level  > 0 THEN
     		    oe_debug_pub.add(  'SET6' , 1 ) ;
     		END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE CALLING CREATE SET-4'||P_SET_NAME , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE CALLING SET TYPE -5'||L_SET_TYPE , 1 ) ;
     END IF;

	Create_Set
        (p_Set_Name => p_set_name,
         p_Set_Type => l_set_type,
         p_Header_Id => l_header_id,
         p_Ship_From_Org_Id => l_ship_from_org_id,
         p_Ship_To_Org_Id   => l_Ship_To_Org_Id,
         p_Schedule_Ship_Date  => l_schedule_ship_Date,
         p_Schedule_Arrival_Date => l_Schedule_Arrival_Date,
         p_Freight_Carrier_Code  => l_Freight_Carrier_Code,
         p_Shipping_Method_Code   => l_Shipping_Method_Code,
         p_Shipment_priority_code  => l_Shipment_priority_code,
         x_Set_Id                 => l_set_id,
         X_Return_Status  => l_return_status,
         x_msg_count      => x_msg_count,
   	 x_msg_data       => x_msg_data);

   	 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     		IF l_debug_level  > 0 THEN
     		    oe_debug_pub.add(  'INTO UNEXPECTED ERROR' , 1 ) ;
     		END IF;
      		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	 ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
     		IF l_debug_level  > 0 THEN
     		    oe_debug_pub.add(  'INTO EXPECTED ERROR' , 1 ) ;
     		END IF;
      		  RAISE FND_API.G_EXC_ERROR;
   	 END IF;

/*	 FOR I IN 1 .. L_line_Tbl.Count
	 LOOP
		IF l_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_MODEL THEN
		   Get_Options(p_x_line_tbl => l_line_tbl,
					p_set_type => l_set_type,
					p_index => I);
		END IF;
	END LOOP;
*/


         FOR I IN 1 .. L_line_Tbl.Count
         LOOP
            l_line_tbl(I).change_reason := 'SYSTEM';
            IF p_set_type = 'ARRIVAL' THEN
               l_line_tbl(I).arrival_set_id := l_set_id ;
            ELSIF p_set_type = 'SHIP' THEN
               l_line_tbl(I).ship_set_id := l_set_id ;
            ELSIF p_set_type = 'FULFILLMENT' THEN
               l_line_tbl(I).Fulfillment_set_id := l_set_id ;
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'INTO LOOP - CREATING FULLFILLMENT SET' ) ;
               END IF;
               -- 4925992
               IF l_line_tbl(I).line_id = l_line_tbl(I).top_model_line_id
                  AND l_line_tbl(I).operation <> 'CREATE'
               THEN
                  l_top_model_line_id := l_line_tbl(I).line_id;
               ELSE
                  l_top_model_line_id := NULL;
               END IF;
               Create_Fulfillment_Set(p_line_id           => l_line_tbl(I).line_id,
                                      -- 4925992
                                      p_top_model_line_id => l_top_model_line_id,
                                      p_set_id            => l_set_id);
               IF l_line_tbl(I).item_type_code = 'MODEL' OR
                  l_line_tbl(I).item_type_code = 'KIT' THEN
                  l_line_opt_tbl(1) := l_line_tbl(I);
                  Get_Options(p_x_line_tbl => l_line_opt_tbl,
                              p_set_type => l_set_type,
                              p_index => 1);
                  FOR Optrec in 1..l_line_opt_tbl.count
                  Loop
                     -- 4925992
                     IF l_line_opt_tbl(optrec).line_id = l_line_opt_tbl(optrec).top_model_line_id
                        AND l_line_opt_tbl(optrec).operation <> 'CREATE'
                     THEN
                        l_top_model_line_id := l_line_opt_tbl(optrec).line_id;
                     ELSE
                        l_top_model_line_id := NULL;
                     END IF;
                     Create_Fulfillment_Set(p_line_id           => l_line_opt_tbl(optrec).line_id,
                                            -- 4925992
                                            p_top_model_line_id => l_top_model_line_id,
                                            p_set_id  => l_set_id);
                  END LOOP;
                  l_line_opt_tbl.delete;
               END IF;

            END IF;
         END LOOP;


         END IF; -- Lexists

		l_control_rec.controlled_operation := TRUE;
		l_control_rec.write_to_db := TRUE;
		l_control_rec.PROCESS := TRUE;
		l_control_rec.default_attributes := TRUE;
		l_control_rec.change_attributes := TRUE;
		l_control_rec.validate_entity := TRUE;

	IF p_set_type <> 'FULFILLMENT' THEN
	OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'N';
		g_set_recursive_flag := TRUE;

-- Call OE_Order_PVT.Process_order
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING PROCESS ORDER' ) ;
    END IF;
		For t in 1..l_line_tbl.count
		loop
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SHIP SET' || L_LINE_TBL ( T ) .SHIP_SET_ID ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SHIP TO' || L_LINE_TBL ( T ) .SHIP_TO_ORG_ID ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SHIP FROM' || L_LINE_TBL ( T ) .SHIP_FROM_ORG_ID ) ;
		END IF;
		end loop;
     oe_order_pvt.Lines
(   p_validation_level  =>    FND_API.G_VALID_LEVEL_NONE
,   p_control_rec       => l_control_rec
,   p_x_line_tbl         =>  l_line_tbl
,   p_x_old_line_tbl    =>  l_old_line_tbl
,   x_return_status     => l_return_status

);
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

/* jolin start comment out nocopy for notification project

-- Api to call notify OC and ACK and to process delayed requests

OE_Order_PVT.Process_Requests_And_Notify
          ( p_process_requests          => FALSE
          , p_notify                    => TRUE
          , x_return_status             => l_return_status
          , p_line_tbl                  => l_line_tbl
          , p_old_line_tbl             => l_old_line_tbl
          );
jolin end */

	OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
		g_set_recursive_flag := FALSE;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;
	END IF; -- FUlfillment set

    END IF; -- Line count
<< END_NEW_PROCESS_SETS >>
		NULL;

        --x_return_status := l_return_status;

     oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data


        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
     		IF l_debug_level  > 0 THEN
     		    oe_debug_pub.add(  'BEFORE ROLLING BACK' , 1 ) ;
     		END IF;
	ROLLBACK TO SAVEPOINT Process_sets;
     		IF l_debug_level  > 0 THEN
     		    oe_debug_pub.add(  'AFTER ROLLING BACK' , 1 ) ;
     		END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
     		IF l_debug_level  > 0 THEN
     		    oe_debug_pub.add(  'BEFORE ROLLING BACK' , 1 ) ;
     		END IF;

	ROLLBACK TO SAVEPOINT Process_sets;
     		IF l_debug_level  > 0 THEN
     		    oe_debug_pub.add(  'AFTER ROLLING BACK' , 1 ) ;
     		END IF;
    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Sets'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
	ROLLBACK TO SAVEPOINT Process_sets;

END Process_Sets;

Procedure Split_Set
        ( p_set_Id                      IN NUMBER,
	  p_set_name			VARCHAR2,
X_Return_Status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2) IS

l_line_rec		  OE_ORDER_PUB.line_rec_type;
l_line_tbl                 OE_ORDER_PUB.Line_Tbl_Type;
l_old_line_tbl                 OE_ORDER_PUB.Line_Tbl_Type;
l_control_rec               OE_GLOBALS.control_rec_type;
l_api_name         CONSTANT VARCHAR2(30) := 'Split_set';
l_Line_Adj_Assoc_tbl          OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;

l_return_status         VARCHAR2(30);
l_set_rec OE_ORDER_CACHE.set_rec_type;
J number;
l_set_tbl          OE_ORDER_PUB.Line_Tbl_Type;
l_set_name varchar2(240);
l_set_id NUMBER;
l_seq_id NUMBER;
l_position NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
NULL;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data


        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Split Sets'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
End Split_Set;

Procedure Validate_multi_arr_set(p_header_id IN NUMBER,
				 p_ship_set_id IN NUMBER,
x_arrival_set_id OUT NOCOPY NUMBER) IS

				 --
				 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
				 --
BEGIN

SELECT arrival_set_id INTO
       x_arrival_set_id
FROM OE_ORDER_LINES_ALL WHERE
header_id = p_header_id AND
ship_set_id = p_ship_set_id AND
arrival_set_id IS NOT NULL AND
rownum = 1;
NULL;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

     RAISE FND_API.G_EXC_ERROR;
    WHEN NO_DATA_FOUND THEN

	x_arrival_set_id := NULL;


END Validate_multi_arr_set;


Procedure Update_Options(p_ato_line_id IN NUMBER := FND_API.G_MISS_NUM,
	       p_config_line_id IN NUMBER := FND_API.G_MISS_NUM,
	       p_set_id IN NUMBER,
	       p_set_type IN VARCHAR2 )IS
stmt_str varchar2(2000);
Parent_line_id Number ;
column1 varchar2(240);
column2 varchar2(240);
TYPE test1 IS TABLE OF OE_ORDER_PUB.HEADER_REC_TYPE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
/**********************
IF p_set_type = 'SHIP_SET' THEN
column1 := 'SHIP_SET_ID';
ELSE
column1 := 'ARRIVAL_SET_ID';
END IF;

IF (p_ato_line_id = FND_API.G_MISS_NUM OR
    p_ato_line_id IS NULL ) THEN
column2 := 'CONFIG_LINE_ID';
parent_line_id := p_config_line_id;
ELSE
column2 := 'ATO_LINE_ID';
parent_line_id := p_ato_line_id;
END IF;

stmt_str := 'UPDATE OE_ORDER_LINES_ALL ' ||
	    'SET '  || column1 || ' =  ' ||  to_char(p_set_id) ||
	    'WHERE ' || column2 || ' =  ' ||to_char(parent_line_id);


EXECUTE IMMEDIATE stmt_Str;
********************/

 Null;

 -- This procedure is not being used. Commenting the same to fix bug
 -- 2935346
END Update_Options;

Procedure Get_Set_Id( p_x_line_rec IN OUT NOCOPY OE_ORDER_PUB.LINE_REC_TYPE,
			 p_old_line_rec IN OE_ORDER_PUB.LINE_REC_TYPE,
			 p_index IN number) IS

l_set_id NUMBER;
 l_set_rec OE_ORDER_CACHE.set_rec_type;
 I number := 0;
 J number := 0;
 x_arrival_set_id Number;
 l_exist boolean := FALSE;
 litemtypecode number := 0;
 lshpqty number := 0;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN

	IF NOT (g_set_recursive_flag) THEN
	-- This is to supress the recursive call made from sets login itself and
	-- is coded before the g recursion flag is desingned

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ENTER GET SET ID' ) ;
		END IF;
		IF (p_x_line_rec.item_type_code IS NULL OR
		   p_x_line_rec.item_type_code = FND_API.G_MISS_CHAR) AND
             p_x_line_rec.operation = oe_globals.g_opr_create THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ENTER ITEM TYPE CODE NULL' ) ;
		END IF;

	IF ( NVL(p_x_line_rec.top_model_line_id,FND_API.G_MISS_NUM)
                         <> FND_API.G_MISS_NUM
          OR NVL(p_x_line_rec.top_model_line_index,FND_API.G_MISS_NUM)
                         <>  FND_API.G_MISS_NUM ) THEN
      IF ( p_x_line_rec.top_model_line_id <> FND_API.G_MISS_NUM
               AND p_x_line_rec.top_model_line_id = p_x_line_rec.line_id )
              OR ( p_x_line_rec.top_model_line_index <> FND_API.G_MISS_NUM
               AND p_x_line_rec.top_model_line_index = p_index )
          THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'TOP MODEL LINE' , 1 ) ;
               END IF;
			litemtypecode := 1;
          -- OPTION/CLASS line if line is NOT the model line
      ELSE
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'OPTION/CLASS LINE' , 1 ) ;
               END IF;
               litemtypecode :=  0;
      END IF;

	ELSE
			litemtypecode := 1;
    END IF;
    END IF ;



	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ITEM TYPE CODE' || P_X_LINE_REC.ITEM_TYPE_CODE ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'SHIP SET' || P_X_LINE_REC.SHIP_SET_ID ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'OLD SHIP SET' || P_OLD_LINE_REC.SHIP_SET_ID ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'SHIP SET' || P_X_LINE_REC.SHIP_SET ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ARRIVAL SET' || P_X_LINE_REC.ARRIVAL_SET ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'FULFILLMENT SET' || P_X_LINE_REC.FULFILLMENT_SET ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'OLD SHIP SET' || P_OLD_LINE_REC.SHIP_SET ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ITEM TYPE CODE' || LITEMTYPECODE ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'SOURCE TYPE' || P_X_LINE_REC.SOURCE_TYPE_CODE , 1 ) ;
	END IF;

-- Lines that are of type external(drop ships) or shipped or any line that
-- is not model standard and kit are not allowed to have set operations.
		IF p_x_line_rec.shipped_quantity IS NULL OR
		  p_x_line_rec.shipped_quantity = FND_API.G_MISS_NUM THEN
		  lshpqty := 0;
		ELSIF p_x_line_rec.shipped_quantity > 0 THEN
			lshpqty := 1;
		END IF;

	IF nvl(p_x_line_rec.source_type_code,'X') <> 'EXTERNAL' AND
	    				lshpqty = 0 THEN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'INTO THE SOURCE TYPE' , 1 ) ;
	END IF;

	IF (p_x_line_rec.item_type_code = 'MODEL' AND
	   p_x_line_rec.top_model_line_id =
	   p_x_line_rec.line_id) OR
	   (p_x_line_rec.item_type_code = 'STANDARD') OR
	   (p_x_line_rec.item_type_code = 'SERVICE' AND
            p_x_line_rec.fulfillment_set IS NOT NULL AND
	    p_x_line_rec.fulfillment_set <> FND_API.G_MISS_CHAR )
	   OR
	   (p_x_line_rec.item_type_code = 'KIT') OR
        (litemtypecode = 1) THEN

-- The g_set_tbl is used to gather the line ids that are requested for set
-- operations and they are processed in the post line process when user tries
-- to commit. This logic is similar to have a delayed request that gathers all
-- the lines to process sets. Instead of looping through the table of dealyed
-- request to identify set requests and put them together in a table
--and process them by set
-- together for group scheduling reasons, we decided for performance reasons
-- to gather informations as and when requested and process the global table.
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'BEFORE SETTING THE LINE '||P_X_LINE_REC.LINE_ID , 1 ) ;
	END IF;
		IF (p_x_line_rec.operation = oe_globals.g_opr_create AND
			(p_x_line_rec.line_id = FND_API.G_MISS_NUM OR
			p_x_line_rec.line_id IS  NULL))  THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'BEFORE SETTING THE LINE -1' , 1 ) ;
		END IF;
			p_x_line_rec.line_id := OE_Default_Line.get_Line;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'AFTER SETTING THE LINE -1' , 1 ) ;
		END IF;
		END IF;

		IF g_set_tbl.count = 0 THEN
			I := 1;
		ELSE
			I := g_set_tbl.count + 1;
		END IF;

		IF g_set_opt_tbl.count = 0 THEN
			J := 1;
		ELSE
			J := g_set_opt_tbl.count + 1;
		END IF;

 -- Populate the arrival_set_id and ship_set_id when names are populated.
 -- Bug fix 2527647
    IF  p_x_line_rec.arrival_set IS NOT NULL
    AND p_x_line_rec.arrival_set <> FND_API.G_MISS_CHAR THEN

      IF  Set_Exist(p_set_name  => p_x_line_rec.arrival_set,
                    p_set_type  => 'ARRIVAL_SET',
                    p_header_id => p_x_line_rec.header_id,
                    x_set_id    => l_set_id) THEN
        --  p_x_line_rec.arrival_set := Null;
          p_x_line_rec.arrival_set_id := l_set_id;


      END IF;

    ELSIF  p_x_line_rec.ship_set IS NOT NULL
    AND p_x_line_rec.ship_set <> FND_API.G_MISS_CHAR THEN

      IF  Set_Exist(p_set_name  => p_x_line_rec.ship_set,
                    p_set_type  => 'SHIP_SET',
                    p_header_id => p_x_line_rec.header_id,
                    x_set_id    => l_set_id) THEN

         -- p_x_line_rec.ship_set := Null;
          p_x_line_rec.ship_set_id := l_set_id;


      END IF;


    END IF; -- name not null.

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'BEFORE CALLING ARRIVAL SET' , 1 ) ;
	END IF;
-- The arrrival sets are processed first. User can either pass a set name or
-- set id to request a set operation.
-- set id will be derived from set name if passed and if set already exists

	IF (p_x_line_rec.arrival_set IS NOT NULL AND
	    p_x_line_rec.arrival_set <> FND_API.G_MISS_CHAR AND
        (p_x_line_rec.arrival_set_id IS  NULL OR
         p_x_line_rec.arrival_set_id = FND_API.G_MISS_NUM)) OR
	    (p_old_line_rec.arrival_set is not null AND
		 p_old_line_rec.arrival_set <> FND_API.G_MISS_CHAR ) then
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ARRIVAL SET CREATION' , 1 ) ;
	END IF;

--	Validate if arrival set already exists

-- This logic will make sure that if line is part of a ship set and any line
-- that belongs to this ship set is part of another arrival set then this
-- will not allow user to create other arrival set. Concept is system cannot
-- have multiple arrival sets in a ship set since a dead lock situation might
-- arise while cascading scheduling attributes since there are ovelapping
-- set attributes in arrival and ship sets.

	IF (p_x_line_rec.ship_set_id IS NOT NULL AND
	    p_x_line_rec.ship_set_id <> FND_API.G_MISS_NUM ) OR
		(p_x_line_rec.ship_set IS NOT NULL AND
                p_x_line_rec.ship_set <> FND_API.G_MISS_CHAR) THEN


           /* Changed the message to fix the bug 2862565  */
         -- 	FND_MESSAGE.Set_Name('ONT', 'OE_INVALID_SET_COMB');
                FND_MESSAGE.Set_Name('ONT','OE_SCH_NOT_IN_SHIP_ARR');
           /* Changed the message to fix the bug 2862565  */
          	oe_msg_pub.add;
                RAISE FND_API.G_EXC_ERROR;

		/*IF  Set_Exist(p_set_name => p_x_line_rec.arrival_set,
          			 p_set_type => 'ARRIVAL_SET',
	   				p_header_id =>p_x_line_rec.header_id,
           			x_set_id    => l_set_id) THEN
		   			l_set_id := l_set_id;
	     ELSE
		   			l_set_id := NULL;
	     END IF;

			Validate_Multi_Arr_Set(p_header_id => p_x_line_rec.header_id,
                               p_ship_set_id => p_x_line_rec.ship_set_id,
					       x_arrival_set_id => x_arrival_set_id);

		IF x_arrival_set_id IS NOT NULL AND
			nvl(l_set_id,-99) <> x_arrival_set_id THEN
          	FND_MESSAGE.Set_Name('ONT', 'OE_INVALID_SET_COMB');
          	oe_msg_pub.add;
        		RAISE FND_API.G_EXC_ERROR;
		END IF; */

	END IF; -- If ship set id

-- If set exists and is closed you cannot insert into set

	IF  Set_Exist(p_set_name => p_x_line_rec.arrival_set,
           	p_set_type => 'ARRIVAL_SET',
	   		p_header_id =>p_x_line_rec.header_id,
           	x_set_id    => l_set_id) THEN

		l_set_rec := get_set_rec(l_set_id);

		IF l_set_rec.set_status = 'C' THEN
         		     fnd_message.set_name('ONT', 'OE_SET_CLOSED');
         			FND_MESSAGE.SET_TOKEN('SET',
          		l_set_rec.set_name);
          		oe_msg_pub.add;
        			RAISE FND_API.G_EXC_ERROR;
		END IF;

-- If set exists and line is getting inserted into an existing set then
-- default set attributes.

		p_x_line_rec.ship_to_org_id := l_set_rec.ship_to_org_id;
		p_x_line_rec.schedule_arrival_date := l_set_rec.schedule_arrival_date;
		p_x_line_rec.arrival_set_id := l_set_id;

-- This logic will go and check if the request for this line already exists
-- in the gloabl table described above and if not exists then will insert an
-- entry into the gloabal table

		IF g_set_tbl.count > 0 THEN

			l_exist := FALSE;

			for Cnt In 1..g_set_tbl.count
			Loop
				IF (g_set_tbl(cnt).line_id = p_x_line_rec.line_id AND
		   		p_old_line_rec.arrival_set = g_set_tbl(cnt).set_name AND
		  		g_set_tbl(cnt).set_type = 'ARRIVAL_SET') THEN

-- Setting the set type in global table to invalid set will ensure this
-- record will not processed in post line process in creating new sets.
-- This scenario will only
-- happen when user puts the line into a new set first and then decides to
-- move into a different existing set.

		  		g_set_tbl(cnt).set_type := 'INVALID_SET';
		  		l_exist := TRUE;
		  		exit;
				END IF;
			end loop;
		END IF;  -- Set table > 0

		ELSE -- Set does not exists
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ARRIVAL SET CREATION- ' , 1 ) ;
	END IF;

		IF g_set_tbl.count > 0 THEN
			l_exist := FALSE;
			for Cnt In 1..g_set_tbl.count
			Loop
				IF (g_set_tbl(cnt).line_id = p_x_line_rec.line_id AND
		   			p_x_line_rec.arrival_set IS NULL  AND
		  			g_set_tbl(cnt).set_type = 'ARRIVAL_SET') THEN

-- This if ensure if user trying to enter set name and remove it then the
-- line will not be processed in the post line process

		  			g_set_tbl(cnt).set_type := 'INVALID_SET';
		  			l_exist := TRUE;
				END IF;

				IF (g_set_tbl(cnt).line_id = p_x_line_rec.line_id AND
		   		p_old_line_rec.arrival_set = g_set_tbl(cnt).set_name AND
		  		g_set_tbl(cnt).set_type = 'ARRIVAL_SET') THEN
		  		g_set_tbl(cnt).set_name := p_x_line_rec.arrival_set;
		  		l_exist := TRUE;
		  		exit;
				END IF;

				IF (g_set_tbl(cnt).line_id = p_x_line_rec.line_id AND
		  		g_set_tbl(cnt).set_name = p_x_line_rec.arrival_set AND
		  		g_set_tbl(cnt).set_type = 'ARRIVAL_SET') THEN
		  		l_exist := TRUE;
		  		exit;
	    			END IF;
	    		End Loop;
	    End IF; -- gtbl > 0

		IF NOT l_exist THEN

-- This logic will add an entry into global table if already not exists one

		IF p_x_line_rec.operation = oe_globals.g_opr_create THEN
			IF (p_x_line_rec.line_id IS NOT NULL AND
		   	p_x_line_rec.line_id <> FND_API.G_MISS_NUM ) THEN
			g_set_tbl(I).line_id := p_x_line_rec.line_id;
			ELSE
			g_set_tbl(I).line_id := p_index;
			g_set_tbl(I).operation := 'C';
			END IF;
		ELSIF p_x_line_rec.operation = oe_globals.g_opr_update THEN
			g_set_tbl(I).line_id := p_x_line_rec.line_id;
		END IF;

		g_set_tbl(I).set_name := p_x_line_rec.arrival_set;
		g_set_tbl(I).set_type := 'ARRIVAL_SET';
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ADDING INTO GLOBAL TABLE - ARRIVAL' , 1 ) ;
	END IF;

		I := I + 1;

		END IF; -- If not lexists

		p_x_line_rec.arrival_set_id := NULL;

		END IF;  -- set does not exists

-- This login will work off the set id if user chooses to pass setid

	ELSIF (p_x_line_rec.arrival_set_id IS NOT NULL AND
	    	p_x_line_rec.arrival_set_id <> FND_API.G_MISS_NUM) then
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'IN ARRIVAL SET ID' , 1 ) ;
	END IF;

    		IF NOT OE_GLOBALS.Equal
		(p_x_line_rec.arrival_set_id,p_old_line_rec.arrival_set_id)
    		THEN

-- Check if set exists and if not set it null

	    IF NOT Set_Exist(p_set_id => p_x_line_rec.arrival_set_id) THEN
			p_x_line_rec.arrival_set_id := NULL;
	    ELSE
-- Assign the default set attributes from the set
		l_set_rec := get_set_rec(p_x_line_rec.arrival_set_id);
		p_x_line_rec.ship_to_org_id := l_set_rec.ship_to_org_id;
		p_x_line_rec.schedule_arrival_date := l_set_rec.schedule_arrival_date;
-- If this is model than add an entry to process options for this model in
-- the options table

		IF (p_x_line_rec.top_model_line_id = p_x_line_rec.line_id) THEN

		IF g_set_opt_tbl.count > 0 THEN
		l_exist := FALSE;
		for Cnt In 1..g_set_opt_tbl.count
		Loop
		IF (g_set_opt_tbl(cnt).line_id = p_x_line_rec.line_id AND
	  nvl(g_set_opt_tbl(cnt).set_id,-99) = nvl(p_x_line_rec.arrival_set_id,-99)
		  AND
		  g_set_opt_tbl(cnt).set_type = 'ARRIVAL_SET') THEN
		  l_exist := TRUE;
		  exit;
	    END IF;
	    End Loop;
	    End IF;
	    IF NOT L_exist THEN
		g_set_opt_tbl(J).line_id := p_x_line_rec.line_id;
		g_set_opt_tbl(J).set_id := p_x_line_rec.arrival_set_id;
		g_set_opt_tbl(J).set_type := 'ARRIVAL_SET';
		J := J + 1;
		END IF;
		END IF;
		END IF;
	END IF;

-- If user is trying to remove the line from the set and if its a model then
-- all the options need be removed

	ELSIF (p_old_line_rec.arrival_set_id IS NOT NULL AND
	    p_old_line_rec.arrival_set_id <> FND_API.G_MISS_NUM) AND
	    (p_x_line_rec.arrival_set_id IS NULL)then
		IF (p_x_line_rec.top_model_line_id = p_x_line_rec.line_id) THEN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'IN REMOVE OF ARRIVAL SET' , 1 ) ;
	END IF;

		IF g_set_opt_tbl.count > 0 THEN
		l_exist := FALSE;
		for Cnt In 1..g_set_opt_tbl.count
		Loop
		IF (g_set_opt_tbl(cnt).line_id = p_x_line_rec.line_id AND
	  nvl(g_set_opt_tbl(cnt).set_id,-99) = nvl(p_x_line_rec.arrival_set_id,-99)
		  AND
		  g_set_opt_tbl(cnt).set_type = 'ARRIVAL_SET') THEN
		  l_exist := TRUE;
		  exit;
	    END IF;
	    End Loop;
	    End IF;

	    IF NOT L_exist THEN
	    g_set_opt_tbl(J).line_id := p_x_line_rec.line_id;
         g_set_opt_tbl(J).set_id := NULL;
	    g_set_opt_tbl(J).set_type := 'ARRIVAL_SET';
		J := J + 1;
		END IF;
		END IF;
	END IF; -- END ARRIVAL SETS
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'OUT OF ARRIVAL SET' , 1 ) ;
	END IF;
		for Cnt In 1..g_set_tbl.count
		Loop
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  ' END OF ARRIVAL SET NAME' || G_SET_TBL ( CNT ) .SET_NAME , 1 ) ;
				END IF;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'SET TYPE' || G_SET_TBL ( CNT ) .SET_TYPE , 1 ) ;
				END IF;
	     end loop;

-- Start Ship Sets and ship sets follow the similar logic as arrival sets
-- above
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'WHAT THE HEC ' , 1 ) ;
		END IF;

	IF (p_x_line_rec.ship_set IS NOT NULL AND
		p_x_line_rec.ship_set <> FND_API.G_MISS_CHAR)OR
	    ( p_old_line_rec.ship_set is not null AND
		 p_old_line_rec.ship_set <> FND_API.G_MISS_CHAR) then
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'BEFORE SHIP SET NAME' ) ;
		END IF;
         IF  Set_Exist(p_set_name =>p_x_line_rec.ship_set,
           p_set_type => 'SHIP_SET',
           p_header_id =>p_x_line_rec.header_id,
           x_set_id    => l_set_id) THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SHIP SET EXISTS' ) ;
		END IF;
		l_set_rec := get_set_rec(l_set_id);
		IF l_set_rec.set_status = 'C' THEN
          fnd_message.set_name('ONT', 'OE_SET_CLOSED');
         	FND_MESSAGE.SET_TOKEN('SET',
          l_set_rec.set_name);
          	oe_msg_pub.add;
        		RAISE FND_API.G_EXC_ERROR;
		END IF;
		p_x_line_rec.ship_to_org_id := l_set_rec.ship_to_org_id;
		p_x_line_rec.ship_from_org_id := l_set_rec.ship_from_org_id;
		p_x_line_rec.schedule_ship_date := l_set_rec.schedule_ship_date;
		p_x_line_rec.freight_carrier_code := l_set_rec.freight_carrier_code;
               p_x_line_rec.ship_set_id := l_set_id;
		IF g_set_tbl.count > 0 THEN

		l_exist := FALSE;

		for Cnt In 1..g_set_tbl.count
		Loop
		IF (g_set_tbl(cnt).line_id = p_x_line_rec.line_id AND
		   p_old_line_rec.ship_set = g_set_tbl(cnt).set_name AND
		  g_set_tbl(cnt).set_type = 'SHIP_SET') THEN
		  g_set_tbl(cnt).set_type := 'INVALID_SET';
		  l_exist := TRUE;
		  exit;
		END IF;
		end loop;
		END IF;
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'BEFORE GOING INTO OPTIONS TABLE ' , 1 ) ;
                END IF;
                IF (p_x_line_rec.item_type_code = 'MODEL' OR
                        p_x_line_rec.item_type_code = 'KIT') AND
                (p_x_line_rec.top_model_line_id = p_x_line_rec.line_id) THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'INTO MODEL IF CONDITON ' , 1 ) ;
                END IF;

                IF g_set_opt_tbl.count > 0 THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'INTO SET OPT TABLE ' , 1 ) ;
                END IF;
                l_exist := FALSE;
                for Cnt In 1..g_set_opt_tbl.count
                Loop
                IF (g_set_opt_tbl(cnt).line_id = p_x_line_rec.line_id AND
          nvl(g_set_opt_tbl(cnt).set_id,-99) = nvl(p_x_line_rec.ship_set_id,-99)
                  AND
                  g_set_opt_tbl(cnt).set_type = 'SHIP_SET') THEN
                  l_exist := TRUE;
                  exit;
                 END IF;
                End Loop;
                End IF;
            IF NOT L_exist THEN
                IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'IF NOT EXISTS ' , 1 ) ;
                END IF;
                g_set_opt_tbl(J).line_id := p_x_line_rec.line_id;
                g_set_opt_tbl(J).set_id := p_x_line_rec.ship_set_id;
                g_set_opt_tbl(J).set_type := 'SHIP_SET';
                J := J+1;
            END IF;
                END IF;


		ELSE

		IF g_set_tbl.count > 0 THEN
		l_exist := FALSE;
		for Cnt In 1..g_set_tbl.count
		Loop
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'INTO GETSETID TBL' || G_SET_TBL ( CNT ) .LINE_ID ) ;
				END IF;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'INTO GETSETID TBL' || P_X_LINE_REC.LINE_ID ) ;
				END IF;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'INTO GETSETID TBL' || G_SET_TBL ( CNT ) .SET_NAME ) ;
				END IF;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'INTO GETSETID TBL' || P_X_LINE_REC.SHIP_SET ) ;
				END IF;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'INTO GETSETID TBL' || G_SET_TBL ( CNT ) .SET_TYPE ) ;
				END IF;

		IF (g_set_tbl(cnt).line_id = p_x_line_rec.line_id AND
		   p_x_line_rec.ship_set IS NULL  AND
		  g_set_tbl(cnt).set_type = 'SHIP_SET') THEN
		  --g_set_tbl(cnt).set_name := null;
		  g_set_tbl(cnt).set_type := 'INVALID_SET';
		  l_exist := TRUE;
		END IF;
		IF (g_set_tbl(cnt).line_id = p_x_line_rec.line_id AND
		   p_old_line_rec.ship_set = g_set_tbl(cnt).set_name AND
		  g_set_tbl(cnt).set_type = 'SHIP_SET') THEN
		  g_set_tbl(cnt).set_name := p_x_line_rec.ship_set;
		  l_exist := TRUE;
		  exit;
		END IF;
		IF (g_set_tbl(cnt).line_id = p_x_line_rec.line_id AND
		  g_set_tbl(cnt).set_name = p_x_line_rec.ship_Set AND
		  g_set_tbl(cnt).set_type = 'SHIP_SET') THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'EXISTS' ) ;
		END IF;
		  l_exist := TRUE;
		  exit;
	    	END IF;
	    End Loop;
	    End IF;
		IF Not L_Exist THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'NOT EXISTS' ) ;
		END IF;
		IF p_x_line_rec.operation = oe_globals.g_opr_create THEN
		IF (p_x_line_rec.line_id IS NOT NULL AND
		   p_x_line_rec.line_id <> FND_API.G_MISS_NUM ) THEN
		g_set_tbl(I).line_id := p_x_line_rec.line_id;
		ELSE
		g_set_tbl(I).line_id := p_index;
		g_set_tbl(I).operation := 'C';
		END IF;
		ELSIF p_x_line_rec.operation = oe_globals.g_opr_update THEN
		g_set_tbl(I).line_id := p_x_line_rec.line_id;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'POPULATING SHIP SET S' ) ;
		END IF;
		g_set_tbl(I).set_name := p_x_line_rec.ship_set;
		g_set_tbl(I).set_type := 'SHIP_SET';
		I := I + 1;
		END IF;

		p_x_line_rec.ship_set_id := NULL;
		END IF;
	ELSIF (p_x_line_rec.ship_set_id IS NOT NULL AND
	p_x_line_rec.ship_set_id <> FND_API.G_MISS_NUM)THEN
    IF NOT OE_GLOBALS.Equal(p_x_line_rec.ship_set_id,p_old_line_rec.ship_set_id)
    THEN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ITEM TYPE CODE' || P_X_LINE_REC.SHIP_SET_ID ) ;
	END IF;

	    IF NOT Set_Exist(p_set_id => p_x_line_rec.ship_set_id) THEN
		p_x_line_rec.ship_set_id := NULL;
		ELSE
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'INTO DEFAULTING SCHEDULING ATTRIBUTES' ) ;
		END IF;
		l_set_rec := get_set_rec(p_x_line_rec.ship_set_id);
		p_x_line_rec.ship_to_org_id := l_set_rec.ship_to_org_id;
		p_x_line_rec.ship_from_org_id := l_set_rec.ship_from_org_id;
		p_x_line_rec.schedule_ship_date := l_set_rec.schedule_ship_date;
		p_x_line_rec.freight_carrier_code := l_set_rec.freight_carrier_code;
		IF (p_x_line_rec.top_model_line_id = p_x_line_rec.line_id) THEN

		IF g_set_opt_tbl.count > 0 THEN
		l_exist := FALSE;
		for Cnt In 1..g_set_opt_tbl.count
		Loop
		IF (g_set_opt_tbl(cnt).line_id = p_x_line_rec.line_id AND
	  nvl(g_set_opt_tbl(cnt).set_id,-99) = nvl(p_x_line_rec.ship_set_id,-99)
		  AND
		  g_set_opt_tbl(cnt).set_type = 'SHIP_SET') THEN
		  l_exist := TRUE;
		  exit;
	    END IF;
	    End Loop;
	    End IF;
	    IF NOT L_exist THEN
		g_set_opt_tbl(J).line_id := p_x_line_rec.line_id;
		g_set_opt_tbl(J).set_id := p_x_line_rec.ship_set_id;
		g_set_opt_tbl(J).set_type := 'SHIP_SET';
		J := J+1;
		END IF;
		END IF;
		END IF;
	END IF;
	ELSIF (p_old_line_rec.ship_set_id IS NOT NULL AND
	    p_old_line_rec.ship_set_id <> FND_API.G_MISS_NUM) AND
	    (p_x_line_rec.ship_set_id IS NULL)then
		IF (p_x_line_rec.top_model_line_id = p_x_line_rec.line_id) THEN

		IF g_set_opt_tbl.count > 0 THEN
		l_exist := FALSE;
		for Cnt In 1..g_set_opt_tbl.count
		Loop
		IF (g_set_opt_tbl(cnt).line_id = p_x_line_rec.line_id AND
	  nvl(g_set_opt_tbl(cnt).set_id,-99) = nvl(p_x_line_rec.ship_set_id,-99)
		  AND
		  g_set_opt_tbl(cnt).set_type = 'SHIP_SET') THEN
		  l_exist := TRUE;
		  exit;
	    END IF;
	    End Loop;
	    End IF;
	    IF NOT L_exist THEN
	    g_set_opt_tbl(J).line_id := p_x_line_rec.line_id;
         g_set_opt_tbl(J).set_id := NULL;
	    g_set_opt_tbl(J).set_type := 'SHIP_SET';
		J := J + 1;
	    END IF;
	    END IF;
	END IF;
		for Cnt In 1..g_set_tbl.count
		Loop
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  ' END OF SHIP SET NAME' || G_SET_TBL ( CNT ) .SET_NAME , 1 ) ;
				END IF;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'SET TYPE' || G_SET_TBL ( CNT ) .SET_TYPE , 1 ) ;
				END IF;
	     end loop;

	-- fulfillment sets

-- Fulfillment sets will have the similar logic as arrival sets

	IF (p_x_line_rec.fulfillment_set IS NOT NULL AND
		p_x_line_rec.fulfillment_set <> FND_API.G_MISS_CHAR)THEN

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'INTO FULLFILLMENT SETS ' ) ;
		END IF;

         /*IF  Set_Exist(p_set_name =>p_x_line_rec.fulfillment_set,
           p_set_type => 'FULFILLMENT_SET',
           p_header_id =>p_x_line_rec.header_id,
           x_set_id    => l_set_id) THEN

             Create_Fulfillment_Set(p_line_id =>p_x_line_rec.line_id,
									   p_set_id => l_set_id);

               p_x_line_rec.fulfillment_set_id := l_set_id;
		ELSE*/

		IF g_set_tbl.count > 0 THEN
		l_exist := FALSE;
		for Cnt In 1..g_set_tbl.count
		Loop
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'INTO GETSETID TBL' || G_SET_TBL ( CNT ) .LINE_ID ) ;
				END IF;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'INTO GETSETID TBL' || P_X_LINE_REC.LINE_ID ) ;
				END IF;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'INTO GETSETID TBL' || G_SET_TBL ( CNT ) .SET_NAME ) ;
				END IF;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'INTO GETSETID TBL' || P_X_LINE_REC.SHIP_SET ) ;
				END IF;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'INTO GETSETID TBL' || G_SET_TBL ( CNT ) .SET_TYPE ) ;
				END IF;
		IF (g_set_tbl(cnt).line_id = p_x_line_rec.line_id AND
		  g_set_tbl(cnt).set_name = p_x_line_rec.fulfillment_set AND
		  g_set_tbl(cnt).set_type = 'FULFILLMENT_SET') THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'EXISTS' ) ;
		END IF;
		  l_exist := TRUE;
		  exit;
	    	END IF;
	    End Loop;
	    End IF;
		IF Not L_Exist THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'NOT EXISTS' ) ;
		END IF;
		IF p_x_line_rec.operation = oe_globals.g_opr_create THEN
		IF (p_x_line_rec.line_id IS NOT NULL AND
		   p_x_line_rec.line_id <> FND_API.G_MISS_NUM ) THEN
		g_set_tbl(I).line_id := p_x_line_rec.line_id;
		ELSE
		g_set_tbl(I).line_id := p_index;
		g_set_tbl(I).operation := 'C';
		END IF;
		ELSIF p_x_line_rec.operation = oe_globals.g_opr_update THEN
		g_set_tbl(I).line_id := p_x_line_rec.line_id;
		END IF;
		g_set_tbl(I).set_name := p_x_line_rec.fulfillment_set;
		g_set_tbl(I).set_type := 'FULFILLMENT_SET';
		END IF;

		p_x_line_rec.fulfillment_set_id := NULL;
		--END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'EXIT FULLFILLMENT SET ' ) ;
		END IF;
	ELSIF (p_x_line_rec.fulfillment_set_id IS NOT NULL AND
	p_x_line_rec.fulfillment_set_id <> FND_API.G_MISS_NUM)THEN
    IF NOT OE_GLOBALS.Equal(p_x_line_rec.fulfillment_set_id,p_old_line_rec.fulfillment_set_id)
    THEN

	    IF NOT Set_Exist(p_set_id => p_x_line_rec.fulfillment_set_id) THEN
		p_x_line_rec.fulfillment_set_id := NULL;
		ELSE

		l_set_rec := get_set_rec(p_x_line_rec.fulfillment_set_id);
		-- Populate g_Set_tbl

		IF g_set_tbl.count > 0 THEN
		l_exist := FALSE;
		for Cnt In 1..g_set_tbl.count
		Loop
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'INTO GETSETID TBL' || G_SET_TBL ( CNT ) .LINE_ID ) ;
				END IF;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'INTO GETSETID TBL' || P_X_LINE_REC.LINE_ID ) ;
				END IF;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'INTO GETSETID TBL' || G_SET_TBL ( CNT ) .SET_NAME ) ;
				END IF;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'INTO GETSETID TBL' || P_X_LINE_REC.SHIP_SET ) ;
				END IF;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'INTO GETSETID TBL' || G_SET_TBL ( CNT ) .SET_TYPE ) ;
				END IF;
		IF (g_set_tbl(cnt).line_id = p_x_line_rec.line_id AND
		  g_set_tbl(cnt).set_name = p_x_line_rec.fulfillment_set AND
		  g_set_tbl(cnt).set_type = 'FULFILLMENT_SET') THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'EXISTS' ) ;
		END IF;
		  l_exist := TRUE;
		  exit;
	    	END IF;
	    End Loop;
	    End IF;
		IF Not L_Exist THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'NOT EXISTS' ) ;
		END IF;
		IF p_x_line_rec.operation = oe_globals.g_opr_create THEN
		IF (p_x_line_rec.line_id IS NOT NULL AND
		   p_x_line_rec.line_id <> FND_API.G_MISS_NUM ) THEN
		g_set_tbl(I).line_id := p_x_line_rec.line_id;
		ELSE
		g_set_tbl(I).line_id := p_index;
		g_set_tbl(I).operation := 'C';
		END IF;
		ELSIF p_x_line_rec.operation = oe_globals.g_opr_update THEN
		g_set_tbl(I).line_id := p_x_line_rec.line_id;
		END IF;
		g_set_tbl(I).set_name := l_set_rec.set_name;
		g_set_tbl(I).set_type := 'FULFILLMENT_SET';
		END IF;
		p_x_line_rec.fulfillment_set_id := NULL;

		IF (p_x_line_rec.top_model_line_id = p_x_line_rec.line_id) THEN

		IF g_set_opt_tbl.count > 0 THEN
		l_exist := FALSE;
		for Cnt In 1..g_set_opt_tbl.count
		Loop
		IF (g_set_opt_tbl(cnt).line_id = p_x_line_rec.line_id AND
	  nvl(g_set_opt_tbl(cnt).set_id,-99) = nvl(p_x_line_rec.fulfillment_set_id,-99)
		  AND
		  g_set_opt_tbl(cnt).set_type = 'FULFILLMENT_SET') THEN
		  l_exist := TRUE;
		  exit;
	    END IF;
	    End Loop;
	    End IF;
	    IF NOT L_exist THEN
		g_set_opt_tbl(J).line_id := p_x_line_rec.line_id;
		g_set_opt_tbl(J).set_id := p_x_line_rec.fulfillment_set_id;
		g_set_opt_tbl(J).set_type := 'FULFILLMENT_SET';
		END IF;
		END IF;
		END IF;
	END IF;
	ELSIF (p_old_line_rec.fulfillment_set_id IS NOT NULL AND
	    p_old_line_rec.fulfillment_set_id <> FND_API.G_MISS_NUM) AND
	    (p_x_line_rec.fulfillment_set_id IS NULL)then
		IF (p_x_line_rec.top_model_line_id = p_x_line_rec.line_id) THEN

		IF g_set_opt_tbl.count > 0 THEN
		l_exist := FALSE;
		for Cnt In 1..g_set_opt_tbl.count
		Loop
		IF (g_set_opt_tbl(cnt).line_id = p_x_line_rec.line_id AND
	  nvl(g_set_opt_tbl(cnt).set_id,-99) = nvl(p_x_line_rec.fulfillment_set_id,-99)
		  AND
		  g_set_opt_tbl(cnt).set_type = 'FULFILLMENT_SET') THEN
		  l_exist := TRUE;
		  exit;
	    END IF;
	    End Loop;
	    End IF;
	    IF NOT L_exist THEN
	    g_set_opt_tbl(J).line_id := p_x_line_rec.line_id;
         g_set_opt_tbl(J).set_id := NULL;
	    g_set_opt_tbl(J).set_type := 'FULFILLMENT_SET';
	    END IF;
	    END IF;
	END IF;

-- End fulfillment sets

	ELSE
/*
IF NOT OE_GLOBALS.Equal(p_x_line_rec.arrival_set_id,p_old_line_rec.arrival_set_id)
OR
NOT OE_GLOBALS.Equal(p_x_line_rec.ship_set_id,p_old_line_rec.ship_set_id)
OR
(p_x_line_rec.arrival_set IS NOT NULL AND
    p_x_line_rec.arrival_set  <> FND_API.G_MISS_CHAR)
OR
(p_x_line_rec.ship_set IS NOT NULL AND
    p_x_line_rec.ship_set  <> FND_API.G_MISS_CHAR)
THEN

                         FND_MESSAGE.SET_NAME('ONT','OE_INVALID_SET_OPR');
              --   		FND_MESSAGE.SET_TOKEN('ITEMTYPE',
               --                    p_x_line_rec.item_type_code);

                         OE_MSG_PUB.ADD;
                         oe_debug_pub.add('Set- not allowed for this itemtype');
                         RAISE FND_API.G_EXC_ERROR;

END IF;
*/

   -- Added this part of the code to fix bug 2116353.
    IF  p_x_line_rec.arrival_set IS NOT NULL
    AND p_x_line_rec.arrival_set <> FND_API.G_MISS_CHAR
    AND p_x_line_rec.arrival_set_id IS NULL THEN

      IF  Set_Exist(p_set_name  => p_x_line_rec.arrival_set,
                    p_set_type  => 'ARRIVAL_SET',
                    p_header_id => p_x_line_rec.header_id,
                    x_set_id    => l_set_id) THEN
        --  p_x_line_rec.arrival_set := Null;
          p_x_line_rec.arrival_set_id := l_set_id;


      END IF;

    ELSIF p_x_line_rec.ship_set IS NOT NULL
    AND   p_x_line_rec.ship_set <> FND_API.G_MISS_CHAR
    AND   p_x_line_rec.ship_set_id IS NULL THEN

      IF  Set_Exist(p_set_name  => p_x_line_rec.ship_set,
                    p_set_type  => 'SHIP_SET',
                    p_header_id => p_x_line_rec.header_id,
                    x_set_id    => l_set_id) THEN

         -- p_x_line_rec.ship_set := Null;
          p_x_line_rec.ship_set_id := l_set_id;


      END IF;

    END IF; -- name not null.

	END IF; -- Model And Standard
	ELSIF(p_x_line_rec.source_type_code = 'EXTERNAL') THEN
	-- Source type code is external
			p_x_line_rec.arrival_set_id := NULL;
			p_x_line_rec.ship_set_id := NULL;

	END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'EXIT GET SET ID' ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'AFTER GET SET ID PROCESS - COMPLETE TABLE - ' ) ;
		END IF;
		for Cnt In 1..g_set_tbl.count
		Loop
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'SET NAME' || G_SET_TBL ( CNT ) .SET_NAME ) ;
				END IF;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'SET TYPE' || G_SET_TBL ( CNT ) .SET_TYPE ) ;
				END IF;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'LINE ID' || G_SET_TBL ( CNT ) .LINE_ID ) ;
				END IF;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'OPERATION' || G_SET_TBL ( CNT ) .OPERATION ) ;
				END IF;
	     end loop;


	END IF; -- Recursive Flag

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

     RAISE FND_API.G_EXC_ERROR;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Set_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;



END Get_Set_Id;



PROCEDURE Query_Set_Rows
(   p_set_id                       IN  NUMBER,
    x_line_tbl   OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
)
IS
l_line_rec                    OE_Order_PUB.Line_Rec_Type;
l_header_id                   NUMBER;
CURSOR   c1 is
SELECT   line_id
FROM     oe_order_lines
WHERE    header_id = l_header_id
AND      (ship_set_id = p_set_id
OR       arrival_set_id = p_set_id)
ORDER BY line_number,shipment_number,nvl(option_number,-1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_SET_UTIL.QUERY_ROWS' , 1 ) ;
    END IF;


    IF
    (p_set_id IS NULL
     OR
     p_set_id = FND_API.G_MISS_NUM)
    THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

   Begin

   Select header_id
   Into   l_header_id
   From   Oe_sets
   Where  set_id = p_set_id;
   Exception
     When Others Then

       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;
		FOR C1REC in C1 LOOP
    			oe_line_util.query_row(p_line_id => c1rec.line_id,
                           x_line_rec => l_line_rec);
			x_line_tbl(x_line_tbl.count + 1) := l_line_rec;
		END LOOP;


    --  PK sent and no rows found

    IF
    (p_set_id IS NOT NULL
     AND
     p_set_id <> FND_API.G_MISS_NUM)
    AND
    (x_line_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_LINE_UTIL.QUERY_ROWS' , 1 ) ;
    END IF;


EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Query_Set_Rows'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Set_Rows;

PROCEDURE Create_line_Set(p_x_line_rec IN OUT NOCOPY OE_ORDER_PUB.LINE_REC_TYPE
			  ) IS
l_set_id number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTER:CREATE LINE SETS ' , 1 ) ;
     END IF;

     SELECT OE_SETS_S.NEXTVAL
      INTO   l_set_id
      FROM   DUAL;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTERSEQUECEVALUE ' , 1 ) ;
     END IF;
INSERT INTO OE_SETS(
  SET_ID
, SET_NAME
, SET_TYPE
, Header_Id
, inventory_item_id
, ordered_quantity_uom
, line_type_id
, Ship_tolerance_above
, ship_tolerance_below
, CREATED_BY
,CREATION_DATE
,UPDATE_DATE
,UPDATED_BY
)
 VALUES(
  l_set_id
, to_char(p_x_line_rec.line_id)
, 'SPLIT'
, p_x_line_rec.Header_Id
, p_x_line_rec.inventory_item_id
, p_x_line_rec.order_quantity_uom
, p_x_line_rec.line_type_id
, p_x_line_rec.Ship_tolerance_above
, p_x_line_rec.ship_tolerance_below
,1
,sysdate
,sysdate
,1001
    );
p_x_line_rec.line_set_id := l_Set_id;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTERINSERT'||TO_CHAR ( L_SET_ID ) , 1 ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'AFTERINSERT ' , 1 ) ;
     END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

     RAISE FND_API.G_EXC_ERROR;


     WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
       OE_MSG_PUB.Add_Exc_Msg
               (    G_PKG_NAME ,
                    'create_line_set'
               );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Create_Line_Set;

Procedure Process_Sets(p_x_line_tbl IN OUT NOCOPY OE_ORDER_PUB.LINE_TBL_TYPE
                         ) IS

l_line_tbl                 OE_ORDER_PUB.Line_Tbl_Type;
l_line_rec                 OE_ORDER_PUB.Line_rec_Type;
l_old_line_tbl  OE_ORDER_PUB.Line_Tbl_Type :=
			 OE_ORDER_PUB.G_MISS_LINE_TBL;
l_control_rec               OE_GLOBALS.control_rec_type;
l_api_name         CONSTANT VARCHAR2(30) := 'Insert_Into_Set';

l_return_status         VARCHAR2(30);
l_set_id NUMBER ;
l_header_id NUMBER ;
l_line_id NUMBER ;
l_set_type VARCHAR2(30) ;
l_set_name VARCHAR2(30) ;
l_set_rec      OE_ORDER_CACHE.set_rec_type;
l_atp_rec                     OE_ATP.atp_tbl_type;
l_atp_tbl                     OE_ATP.atp_tbl_type;
l_Ship_from_org_id  NUMBER ;
l_Ship_to_org_id    NUMBER ;
l_Schedule_Ship_Date DATE ;
l_Schedule_Arrival_Date DATE ;
l_Freight_Carrier_Code  VARCHAR2(30) ;
l_Shipping_Method_Code  VARCHAR2(30) ;
l_Shipment_priority_code VARCHAR2(30);
L_COUNT NUMBER := 0;
l_Loop_COUNT NUMBER := 0;
x_msg_count number;
x_msg_data varchar2(2000);
next number;
l_proc_record number := 0;
x_arrival_set_id number;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
-- 4925992
l_top_model_line_id NUMBER;
BEGIN



		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'ENTER PROCESS SETS' ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'RECURSION MODE' || OE_GLOBALS.G_RECURSION_MODE ) ;
		END IF;

-- To avoid this in a recursive procedure

		IF NOT (g_set_recursive_flag ) THEN
		l_count := 1;

		FOR I in 1..g_set_tbl.count
		Loop
		-- To control logic in get options procedure
		  g_process_options := FALSE;
-- for existing sets and lines we can default the set attributes and avoid this
-- procedure call and also a recursive call to register the updated attributes

		IF g_set_tbl(I).operation = 'C' THEN

		FOR J in 1..p_x_line_tbl.count
		Loop

-- Populate line id if the index id populated and operation is create
--on the line
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'LINE ID' || G_SET_TBL ( I ) .LINE_ID ) ;
				END IF;
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'OPERATION' || G_SET_TBL ( I ) .OPERATION ) ;
				END IF;

		IF g_set_tbl(I).line_id = J THEN
				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'OPERATION' || P_X_LINE_TBL ( J ) .ITEM_TYPE_CODE ) ;
				END IF;
		IF p_x_line_tbl(J).item_type_code <> 'MODEL' AND
		   p_x_line_tbl(J).item_type_code <> 'STANDARD' AND
		   p_x_line_tbl(J).item_type_code <> 'KIT' THEN
		   goto End_Psets;
	     END IF;
		g_set_tbl(I).line_id := p_x_line_tbl(J).line_id;

		Exit;
		END IF;
		End loop;
		END IF;
		End Loop;

				IF l_debug_level  > 0 THEN
				    oe_debug_pub.add(  'G_LINE_TBL: COUNT' || G_SET_TBL.COUNT ) ;
				END IF;

-- Process all the lines in the set table now

		FOR I in 1.. g_set_tbl.count
		Loop
-- From the set table we process for each set all the lines first and
-- Process the second set. If three lines are going in one set and two
-- lines going in other than we process the three lines that belong to
-- one set processed first before others are processed.

		IF l_proc_record = g_set_tbl.count THEN
		EXIT;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'INTO SET COUNT' ) ;
		END IF;

-- This logic is avoid the invalid sets that are marked in get set id api

		IF g_set_tbl(I).set_type = 'INVALID_SET' THEN
		g_set_tbl(I).process_flag := 'Y' ;
		END IF;

        IF g_set_tbl(I).process_flag <> 'Y' THEN

          BEGIN
			oe_line_util.query_row(p_line_id => g_set_tbl(I).line_id,
							       x_line_rec => l_line_rec);

          EXCEPTION

           WHEN NO_DATA_FOUND THEN

		     IF l_debug_level  > 0 THEN
		        oe_debug_pub.add(  'No data found ' || g_set_tbl(I).line_id ) ;
		     END IF;
              g_set_tbl(I).process_flag := 'Y' ;
          END;

        END IF;

        OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => l_line_rec.line_id
         ,p_header_id                   => l_line_rec.header_id
         ,p_line_id                     => l_line_rec.line_id
         ,p_orig_sys_document_ref       =>
                                l_line_rec.orig_sys_document_ref
         ,p_orig_sys_document_line_ref  =>
                                l_line_rec.orig_sys_line_ref
         ,p_orig_sys_shipment_ref       =>
                                l_line_rec.orig_sys_shipment_ref
         ,p_change_sequence             =>  l_line_rec.change_sequence
         ,p_source_document_id          =>
                                l_line_rec.source_document_id
         ,p_source_document_line_id     =>
                                l_line_rec.source_document_line_id
         ,p_order_source_id             =>
                                l_line_rec.order_source_id
         ,p_source_document_type_id     =>
                                l_line_rec.source_document_type_id);
        -- Added and condition to external check to fix bug 3250887.
        IF g_set_tbl(I).process_flag <> 'Y' THEN
            IF ((nvl(l_line_rec.source_type_code,'X') = 'EXTERNAL') AND (g_set_tbl(I).set_type <> 'FULFILLMENT_SET'))
            OR (nvl(l_line_rec.shipped_quantity,0) > 0 AND g_set_tbl(I).set_type <> 'FULFILLMENT_SET')
            OR (nvl(l_line_rec.fulfilled_flag,'N') =  'Y' AND
               (g_set_tbl(I).set_type <>  'FULFILLMENT_SET' OR Fulfill_Sts(l_line_id)<>'NOTIFIED'))
            /* next two lines replaced with above two for 2525203
            OR nvl(l_line_rec.shipped_quantity,0) > 0
            OR nvl(l_line_rec.fulfilled_flag,'N') =  'Y'
            */
            OR nvl(l_line_rec.open_flag,'N') =  'N'
            /* Fix Bug # 2834750 : Only Fulfillment Sets allowed for RMA Lines */
            OR (l_line_rec.line_category_code = 'RETURN' AND
                g_set_tbl(I).set_type <> 'FULFILLMENT_SET') THEN

               FND_MESSAGE.SET_NAME('ONT','OE_INVALID_SET_OPR');
               OE_MSG_PUB.ADD;
                                  IF l_debug_level  > 0 THEN
                                      oe_debug_pub.add(  'LINE IS NOT VALID TO PROCESS: ' || L_LINE_REC.LINE_ID , 1 ) ;
                                  END IF;
               g_set_tbl(I).process_flag := 'Y' ;
               OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;

            END IF;

            IF (l_line_rec.item_type_code <> 'MODEL' AND
                l_line_rec.item_type_code <> 'STANDARD' AND
                l_line_rec.item_type_code <> 'KIT' AND
                l_line_rec.item_type_code <> 'SERVICE' AND
	            nvl(l_line_rec.model_remnant_flag,'N') <> 'Y')
             OR (l_line_rec.item_type_code = 'SERVICE'
                 AND g_set_tbl(I).set_type  =  'FULFILLMENT'
                 AND NOT Is_Service_Eligible(l_line_rec))
            OR (l_line_rec.item_type_code = 'SERVICE'
                AND (g_set_tbl(I).set_type  =  'ARRIVAL'
                 OR  g_set_tbl(I).set_type  = 'SHIP'))  THEN

               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'SET- NOT ALLOWED FOR THIS ITEMTYPE' || L_LINE_REC.ITEM_TYPE_CODE ) ;
               END IF;

               FND_MESSAGE.SET_NAME('ONT','OE_INVALID_SET_OPR');
             --  FND_MESSAGE.SET_TOKEN('ITEMTYPE',
              --                     l_line_rec.item_type_code);
               OE_MSG_PUB.ADD;
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'SET- NOT ALLOWED FOR THIS ITEMTYPE' ) ;
               END IF;
                         --RAISE FND_API.G_EXC_ERROR;
		       g_set_tbl(I).process_flag := 'Y' ;
	       END IF;
        END IF;

		IF g_set_tbl(I).process_flag <> 'Y' THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SET PROCESSING- I:' || I ) ;
		END IF;
		l_set_name := g_set_tbl(I).set_name;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'LINE ID :' || G_SET_TBL ( I ) .LINE_ID ) ;
		END IF;
		l_line_tbl(l_count) :=
				l_line_rec;
		l_old_line_tbl(l_count) :=
				l_line_rec;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SCHEDULE REQUEST DATE- :' || L_LINE_REC.REQUEST_DATE , 1 ) ;
END IF;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SCHEDULE REQUEST DATE- :' || L_LINE_REC.SCHEDULE_SHIP_DATE , 1 ) ;
END IF;
          g_old_line_tbl(l_count) :=
		l_line_tbl(l_count);
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'AFTER QUERY_ROW :' ) ;
		END IF;
		l_line_tbl(l_count).schedule_action_code :=
	OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'AFTER SCHDULING ACITON ASSIGN:' ) ;
		END IF;
		IF g_set_tbl(I).set_type = 'SHIP_SET' THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'IN SHIP SET:' ) ;
		END IF;
		l_set_type := 'SHIP_SET';
		l_ship_from_org_id := l_line_tbl(l_count).ship_from_org_id;
		l_ship_to_org_id := l_line_tbl(l_count).ship_to_org_id;
		l_schedule_ship_date := l_line_tbl(l_count).schedule_ship_date;
		 l_line_tbl(l_count).ship_set := l_set_name;
	--l_schedule_arrival_date := l_line_tbl(l_count).schedule_arrival_date;
--	l_freight_carrier_code := l_line_tbl(l_count).freight_carrier_code;
		ELSIF g_set_tbl(I).set_type = 'ARRIVAL_SET' THEN
		l_set_type := 'ARRIVAL_SET';
		l_ship_to_org_id := l_line_tbl(l_count).ship_to_org_id;
		l_schedule_arrival_date := l_line_tbl(l_count).schedule_arrival_date;
		 l_line_tbl(l_count).arrival_set := l_set_name;
		ELSIF g_set_tbl(I).set_type = 'FULFILLMENT_SET' THEN
		l_set_type := 'FULFILLMENT_SET';
		END IF;

		-- If this is model get children
		IF (l_line_tbl(l_count).item_type_code = 'MODEL' AND
		   l_line_tbl(l_count).top_model_line_id =
		   l_line_tbl(l_count).line_id ) OR
		   l_line_tbl(l_count).item_type_code = 'KIT' THEN
		   Get_Options(p_x_line_tbl => l_line_tbl,
					p_set_type => l_set_type,
					p_index => l_count);
		END IF;

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'AFTER ASSIGNING SCHEDULE ATTRI- I:' || I ) ;
		END IF;
		g_set_tbl(I).process_flag := 'Y';
		l_count := l_line_tbl.count + 1;
		l_proc_record := l_proc_record + 1;
		-- This end if should be at the end since it covers the entire loop
		-- END IF;

		IF g_set_tbl.count = 1 THEN
		Next := 1;
		ELSIF I = g_set_tbl.last THEN
		Next := I;
		ELSE
		Next := I + 1;
		END IF;


		FOR J in Next .. g_set_tbl.count
		LOOP
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SET PROCESSING- J:' || J ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SET PROCESSING- NEXT:' || NEXT ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SET NAME- NEXT:' || L_SET_NAME ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SET NAME- NEXT:' || L_SET_TYPE ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SET NAME- NEXT:' || G_SET_TBL ( J ) .SET_NAME ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SET NAME- NEXT:' || G_SET_TBL ( J ) .SET_TYPE ) ;
		END IF;
				oe_line_util.query_row(p_line_id => g_set_tbl(J).line_id,
						x_line_rec => l_line_rec);


    IF (l_line_rec.item_type_code <> 'MODEL' AND
        l_line_rec.item_type_code <> 'STANDARD' AND
        l_line_rec.item_type_code <> 'KIT' AND
        l_line_rec.item_type_code <> 'SERVICE' AND
	    nvl(l_line_rec.model_remnant_flag,'N') <> 'Y')
     OR (l_line_rec.item_type_code = 'SERVICE'
         AND (g_set_tbl(J).set_type  =  'ARRIVAL'
          OR  g_set_tbl(J).set_type  = 'SHIP'))  THEN

            OE_MSG_PUB.set_msg_context
        ( p_entity_code                 => 'LINE'
         ,p_entity_id                   => l_line_rec.line_id
         ,p_header_id                   => l_line_rec.header_id
         ,p_line_id                     => l_line_rec.line_id
         ,p_orig_sys_document_ref       =>
                                l_line_rec.orig_sys_document_ref
         ,p_orig_sys_document_line_ref  =>
                                l_line_rec.orig_sys_line_ref
         ,p_orig_sys_shipment_ref       =>
                                l_line_rec.orig_sys_shipment_ref
         ,p_change_sequence             =>  l_line_rec.change_sequence
         ,p_source_document_id          =>
                                l_line_rec.source_document_id
         ,p_source_document_line_id     =>
                                l_line_rec.source_document_line_id
         ,p_order_source_id             =>
                                l_line_rec.order_source_id
         ,p_source_document_type_id     =>
                                l_line_rec.source_document_type_id);
               FND_MESSAGE.SET_NAME('ONT','OE_INVALID_SET_OPR');
                  --       FND_MESSAGE.SET_TOKEN('ITEMTYPE',
                   --                l_line_rec.item_type_code);
                         OE_MSG_PUB.ADD;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SET- NOT ALLOWED FOR THIS ITEMTYPE' ) ;
            END IF;
                         --RAISE FND_API.G_EXC_ERROR;
		g_set_tbl(J).process_flag := 'Y' ;
	END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'PROCES FLAG- J:' || G_SET_TBL ( J ) .PROCESS_FLAG ) ;
		END IF;

		IF g_set_tbl(J).process_flag <> 'Y' THEN

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'INTO PROCESSFLAG- J:' ) ;
		END IF;
		IF g_set_tbl(J).set_name = l_set_name AND
		 g_set_tbl(J).set_type = l_set_type THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SET PROCESSING- J:' || J ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SET PROCESSING- NEXT:' || NEXT ) ;
		END IF;

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'INTO PROCESSING- J:' || NEXT ) ;
		END IF;
		l_line_tbl(l_count) :=
				       l_line_rec;
		l_old_line_tbl(l_count) :=
				       l_line_rec;

          g_old_line_tbl(l_count) :=
          l_line_tbl(l_count);

		l_line_tbl(l_count).schedule_action_code :=
		OE_ORDER_SCH_UTIL.OESCH_ACT_SCHEDULE;
		IF g_set_tbl(J).set_type = 'SHIP_SET' THEN
		l_line_tbl(l_count).ship_from_org_id := l_ship_from_org_id;
		l_line_tbl(l_count).ship_to_org_id:=l_ship_to_org_id;
		l_line_tbl(l_count).schedule_ship_date := l_schedule_ship_date;
		l_line_tbl(l_count).ship_set := l_set_name;
	--l_line_tbl(l_count).schedule_arrival_date := l_schedule_arrival_date;
--	l_line_tbl(l_count).freight_carrier_code := l_freight_carrier_code;
		ELSIF g_set_tbl(J).set_type = 'ARRIVAL_SET' THEN
	IF (l_line_tbl(l_count).ship_set_id IS NOT NULL AND
         l_line_tbl(l_count).ship_set_id <> FND_API.G_MISS_NUM) THEN

		IF  Set_Exist(p_set_name =>g_set_tbl(J).set_name,
           p_set_type => 'ARRIVAL_SET',
	   	p_header_id =>l_line_tbl(l_count).header_id,
           x_set_id    => l_set_id) THEN
		   l_set_id := l_set_id;
	     ELSE
		   l_set_id := NULL;
	     END IF;

     Validate_Multi_Arr_Set(p_header_id => l_line_tbl(l_count).header_id,
                             p_ship_set_id => l_line_tbl(l_count).ship_set_id,
                      		x_arrival_set_id => x_arrival_set_id);

          IF x_arrival_set_id IS NOT NULL AND
		   nvl(l_set_id,-99) <> x_arrival_set_id THEN
             /* Changed the message to fix the bug 2862565  */
            -- FND_MESSAGE.Set_Name('ONT', 'OE_INVALID_SET_COMB');
               FND_MESSAGE.Set_Name('ONT','OE_SCH_NOT_IN_SHIP_ARR');
             /* Changed the message to fix the bug 2862565  */
               oe_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
          END IF;

     END IF;

		l_line_tbl(l_count).ship_to_org_id:=l_ship_to_org_id;
		l_line_tbl(l_count).schedule_arrival_date := l_schedule_arrival_date;
		l_line_tbl(l_count).arrival_set := l_set_name;
		END IF;

		-- If this is model get children

		IF (l_line_tbl(l_count).item_type_code = 'MODEL' AND
		   l_line_tbl(l_count).top_model_line_id =
		   l_line_tbl(l_count).line_id) OR
		   l_line_tbl(l_count).item_type_code = 'KIT' THEN
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'CALLING OPTIONS J:' ) ;
		END IF;
		   Get_Options(p_x_line_tbl => l_line_tbl,
					p_set_type => l_set_type,
					p_index => l_count);
		END IF;
		g_set_tbl(J).process_flag := 'Y';
		l_proc_record := l_proc_record + 1;
		l_count := l_line_tbl.count + 1;
		END IF; -- setname and set type
		END IF; -- Process Flag

		END LOOP; -- J

					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'BEFORE CALLING SCHSET:'|| L_LINE_TBL.COUNT , 1 ) ;
					END IF;
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'BEFORE CALLING SCHSET REQUEST DATE:'|| L_LINE_TBL ( 1 ) .REQUEST_DATE , 1 ) ;
					END IF;
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'BEFORE CALLING SCHSET SCHEDULE DATE:'|| L_LINE_TBL ( 1 ) .SCHEDULE_SHIP_DATE , 1 ) ;
					END IF;
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'BEFORE CALLING SHIP SET:'|| L_LINE_TBL ( 1 ) .SHIP_SET_ID , 1 ) ;
					END IF;
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'BEFORE CALLING SHIP SET:'|| G_OLD_LINE_TBL ( 1 ) .SHIP_SET_ID , 1 ) ;
					END IF;
	 --l_line_tbl(1).schedule_ship_date := l_line_tbl(1).request_date;

    g_set_recursive_flag := TRUE;
	 IF l_set_type <> 'FULFILLMENT_SET' THEN

	 /*FOR lrec in 2..l_line_tbl.count
	 Loop
	 IF l_Set_type = 'SHIP_SET' THEN
	 l_line_tbl(lrec).schedule_ship_date := l_line_tbl(1).schedule_ship_date;
	 l_line_tbl(lrec).ship_to_org_id := l_line_tbl(1).ship_to_org_id;
	 l_line_tbl(lrec).ship_from_org_id := l_line_tbl(1).ship_from_org_id;
	 ELSIF l_Set_type = 'ARRIVAL_SET' THEN
	 l_line_tbl(lrec).schedule_arrival_date := l_line_tbl(1).schedule_arrival_date;
	 l_line_tbl(lrec).ship_to_org_id := l_line_tbl(1).ship_to_org_id;
	 END IF;
	 END LOOP;*/
	IF l_set_type <> 'FULFILLMENT_SET' THEN
			for t in 1..l_line_tbl.count loop
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'BEFORE CALLING SCHSET SCHEDULE DATE:'|| L_LINE_TBL ( T ) .SCHEDULE_SHIP_DATE , 1 ) ;
					END IF;
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'BEFORE CALLING SCHSET SCHEDULE DATE:'|| L_LINE_TBL ( T ) .REQUEST_DATE , 1 ) ;
					END IF;
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'BEFORE CALLING SCHSET SCHEDULE DATE:'|| L_LINE_TBL ( T ) .ITEM_TYPE_CODE , 1 ) ;
					END IF;
			end loop;


     OE_GRP_SCH_UTIL.Schedule_set_of_lines(p_x_line_tbl      => l_line_tbl,
                                           p_old_line_tbl => g_old_line_tbl,
                                        x_return_status => l_return_status);
	END IF;
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'AFTER CALLING SCHSET:'|| L_LINE_TBL.COUNT , 1 ) ;
					END IF;
			for t in 1..l_line_tbl.count loop
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'BEFORE CALLING SCHSET SCHEDULE DATE:'|| L_LINE_TBL ( T ) .SCHEDULE_SHIP_DATE , 1 ) ;
					END IF;
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'BEFORE CALLING SCHSET SCHEDULE DATE:'|| L_LINE_TBL ( T ) .REQUEST_DATE , 1 ) ;
					END IF;
					IF l_debug_level  > 0 THEN
					    oe_debug_pub.add(  'BEFORE CALLING SCHSET SCHEDULE DATE:'|| L_LINE_TBL ( T ) .ITEM_TYPE_CODE , 1 ) ;
					END IF;
			end loop;
			--g_old_line_tbl.delete;

               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'AFTER GROUP SCHEDULING' , 1 ) ;
               END IF;
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'RETURNSTATUS UNEXPECTED SCHEDULING' , 1 ) ;
               END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'RETURNSTATUS ERROR SCHEDULING' , 1 ) ;
               END IF;
                 RAISE FND_API.G_EXC_ERROR;
      END IF;
      --l_header_id := l_line_tbl(1).header_id;
	 IF l_set_type = 'SHIP_SET' THEN
      l_ship_from_org_id := l_line_tbl(1).ship_from_org_id;
      l_ship_to_org_id := l_line_tbl(1).ship_to_org_id;
      l_schedule_ship_date := l_line_tbl(1).schedule_ship_date;
	 ELSIF l_set_type = 'ARRIVAL_SET' THEN
      l_schedule_arrival_date := l_line_tbl(1).schedule_arrival_date;
      l_ship_to_org_id := l_line_tbl(1).ship_to_org_id;
	 END IF;
               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'SET6' , 1 ) ;
               END IF;
	END IF;
      l_header_id := l_line_tbl(1).header_id;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SET NAME- BEFORE CREATE:' || L_SET_NAME ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'SET TYPE- BEFORE CREATE:' || L_SET_TYPE ) ;
		END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  ' HEADER- BEFORE CREATE:' || L_HEADER_ID ) ;
		END IF;

     Create_Set
        (p_Set_Name => l_set_name,
         p_Set_Type => l_set_type,
         p_Header_Id => l_header_id,
         p_Ship_From_Org_Id => l_ship_from_org_id,
         p_Ship_To_Org_Id   => l_Ship_To_Org_Id,
         p_Schedule_Ship_Date  => l_schedule_ship_Date,
         p_Schedule_Arrival_Date => l_Schedule_Arrival_Date,
         p_Freight_Carrier_Code  => l_Freight_Carrier_Code,
         p_Shipping_Method_Code   => l_Shipping_Method_Code,
         p_Shipment_priority_code  => l_Shipment_priority_code,
         x_Set_Id                 => l_set_id,
         X_Return_Status  => l_return_status,
         x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data);

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
      END IF;

	IF l_set_type = 'FULFILLMENT_SET' THEN
			IF l_debug_level  > 0 THEN
			    oe_debug_pub.add(  'BEFORE CREATING FULLFILLMENT SET' ) ;
			END IF;
         FOR fullrec in 1..l_line_tbl.COUNT
         LOOP
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'INTO LOOP - CREATING FULLFILLMENT SET' ) ;
            END IF;
            -- 4274226
            IF l_line_tbl(fullrec).line_id = l_line_tbl(fullrec).top_model_line_id
               AND l_line_tbl(fullrec).operation <> 'CREATE'
            THEN
               l_top_model_line_id := l_line_tbl(fullrec).line_id;
            ELSE
               l_top_model_line_id := NULL;
            END IF;
            Create_Fulfillment_Set(p_line_id           => l_line_tbl(fullrec).line_id,
                                   -- 4274226
                                   p_top_model_line_id => l_top_model_line_id,
                                   p_set_id            => l_set_id);
         END LOOP;
	END IF;

          FOR K IN 1 .. l_line_tbl.COUNT
          LOOP
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'BEFORE ASSIGNING THE OLD RECORD IN SET' , 1 ) ;
		END IF;
		oe_line_util.query_row( l_line_tbl(K).line_id,
					l_line_rec);
			g_old_line_tbl(K) := l_line_rec;

IF l_Set_type = 'SHIP_SET' THEN
l_line_tbl(K).ship_set_id := l_Set_id;
			/*IF l_line_tbl(K).item_type_code = 'KIT' THEN
					Update oe_order_lines_all
					set ship_set_id = l_set_id where
					top_model_line_id = l_line_tbl(K).line_id and
					item_type_code = 'INCLUDED';
			END IF; */
ELSIF l_Set_type = 'ARRIVAL_SET' THEN
l_line_tbl(K).arrival_set_id := l_Set_id;
			/*IF l_line_tbl(K).item_type_code = 'KIT' THEN
					Update oe_order_lines_all
					set arrival_set_id = l_set_id where
					top_model_line_id = l_line_tbl(K).line_id and
					item_type_code = 'INCLUDED';
			END IF; */
ELSIF l_Set_type = 'FULFILLMENT_SET' THEN
l_line_tbl(K).fulfillment_set_id := l_Set_id;
END IF;
		IF l_Set_type <> 'FULFILLMENT_SET' THEN

l_line_tbl(K).operation := oe_globals.g_opr_update;

  /*      Validate_set_attributes(p_set_id => l_set_id,
     p_Ship_From_Org_Id => l_line_tbl(K).ship_from_org_id,
        p_Ship_To_Org_Id   => l_line_tbl(K).Ship_To_Org_Id,
        p_Schedule_Ship_Date  => l_line_tbl(K).schedule_ship_Date,
        p_Schedule_Arrival_Date => l_line_tbl(K).Schedule_Arrival_Date,
        p_Freight_Carrier_Code  => l_line_tbl(K).Freight_Carrier_Code,
        p_Shipping_Method_Code   => l_line_tbl(K).Shipping_Method_Code,
          X_Return_Status  => l_return_status);*/

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
      END IF;
	 END IF;
	END LOOP;

		IF l_Set_type <> 'FULFILLMENT_SET' THEN
          l_control_rec.controlled_operation := TRUE;
          l_control_rec.write_to_db := TRUE;
          l_control_rec.PROCESS := FALSE;
          l_control_rec.default_attributes := TRUE;
          l_control_rec.change_attributes := TRUE;
     OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'N';
    g_set_recursive_flag := TRUE;

    FOR I IN 1..l_line_tbl.count LOOP

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LINE ID ' || L_LINE_TBL ( I ) .LINE_ID , 1 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ITEM ' || L_LINE_TBL ( I ) .INVENTORY_ITEM_ID , 1 ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OLD ITEM ' || G_OLD_LINE_TBL ( I ) .INVENTORY_ITEM_ID , 1 ) ;
      END IF;



    END LOOP;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE CALLING PROCESS ORDER IN SETS' ) ;
    END IF;


	     oe_order_pvt.Lines
		(   p_validation_level  =>    FND_API.G_VALID_LEVEL_NONE
		,   p_control_rec       => l_control_rec
		,   p_x_line_tbl         =>  l_line_tbl
		,   p_x_old_line_tbl    =>  g_old_line_tbl
		,   x_return_status     => l_return_status

		);
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

/* jolin start comment out nocopy for notification project

-- Api to call notify OC and ACK and to process delayed requests

OE_Order_PVT.Process_Requests_And_Notify
          ( p_process_requests          => FALSE
          , p_notify                    => TRUE
          , x_return_status             => l_return_status
          , p_line_tbl                  => l_line_tbl
          , p_old_line_tbl             => g_old_line_tbl
          );
jolin end */

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'AFTER CALLING PROCESS ORDER IN SETS' ) ;
	END IF;

     OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
	END IF;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'AFTER CALLING PROCESS ORDER IN SETS-1' ) ;
		END IF;
    g_set_recursive_flag := FALSE;

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
       OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
    END IF;


	FOR M in 1..l_line_tbl.count
	LOOP
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'AFTER CALLING PROCESS ORDER IN SETS-2' ) ;
		END IF;
		FOR H in 1..p_x_line_tbl.count
		Loop
	IF p_x_line_tbl(H).line_id = l_line_tbl(M).line_id THEN
		 p_x_line_tbl(H):= l_line_tbl(M);
		 EXIT;
	END IF;
	END LOOP;
     END LOOP;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'AFTER CALLING PROCESS ORDER IN SETS-3' ) ;
		END IF;
			l_line_tbl.delete;
			g_old_line_tbl.delete;
			l_count := 1;

	--	END LOOP; -- J
	END IF; -- This is for if processed flag = Y for I

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'AFTER CALLING PROCESS ORDER IN SETS-4' ) ;
		END IF;

END LOOP; -- I
	IF g_set_tbl.count > 0 THEN
	 g_set_tbl.delete;
	 END IF;

		IF g_set_opt_tbl.count <>  0 THEN

		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'AFTER CALLING PROCESS ORDER IN SETS-5' ) ;
		END IF;
-- This is to process options that has been effected by changes on the model
-- other than creating a new set. If model is removed or moved into an
-- existing sets then all the options are queried and we will put them in
-- a new set.
			Process_Options;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'AFTER CALLING PROCESS ORDER IN SETS-6' ) ;
		END IF;
	 		g_set_opt_tbl.delete;
		END IF;

END IF;
<<End_Psets>>
		  g_process_options := TRUE;
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'EXIT PROCESS SETS' ) ;
		END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

     RAISE FND_API.G_EXC_ERROR;

    WHEN OTHERS THEN

     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Process Sets'
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;



END Process_Sets;

FUNCTION Get_Fulfillment_List(p_line_id IN NUMBER)
RETURN VARCHAR2
IS
Cursor FULLIST IS
Select os.set_name from
oe_sets os,
oe_line_sets ls
where
ls.line_id = p_line_id and
os.set_id = ls.set_id;
lfullist varchar2(2000);
lcount number := 0;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

FOR I in FULLIST
LOOP
lfullist := lfullist || I.set_name || ',';
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'FULLFILLMENT LIST' ||LFULLIST ) ;
END IF;
END LOOP;
lfullist := rtrim(lfullist,',');
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'AFTER TRIM FULLFILLMENT LIST' ||LFULLIST ) ;
END IF;
RETURN lfullist;

END Get_Fulfillment_List;

Procedure Remove_from_fulfillment(p_line_id NUMBER)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

Delete oe_line_sets
where line_id = p_line_id;

Exception
when no_data_found then
null;
when others then
null;
End Remove_from_fulfillment;

/* This procedure is added for the new set scheduling functioanlity
and it takes the responsibility of creating a set if a line is requested
into a set and populate set id for scheduling to be sensitive to sets */

Procedure Default_Line_Set(p_x_line_rec IN OUT NOCOPY oe_order_pub.line_rec_type,
			               p_old_line_rec IN oe_order_pub.line_rec_type)
IS
l_set_id number;
l_cascade_flag        varchar2(1) := 'N';
l_create_set          varchar2(1) := 'N';
l_set_type            varchar2(30) ;
l_set_name            varchar2(2000);
l_set_rec             oe_order_cache.set_rec_type ;
x_msg_data            varchar2(32000);
x_msg_count           number ;
l_return_status       varchar2(30);
lsettempname          varchar2(2000);
tempname              varchar2(2000);
l_ful_exists          varchar2(1) := 'N';
l_cust_pref 	      varchar2(240);
l_set_pref_type       varchar2(240);
l_fulfillment_set     VARCHAR2(240);
l_x_line_rec          OE_ORDER_PUB.LINE_REC_TYPE;
K                     NUMBER;
l_old_set_id          NUMBER;
l_child_line_rec      OE_ORDER_PUB.line_rec_type;
l_action              VARCHAR2(20);
l_operation           VARCHAR2(30);
l_entity_type         VARCHAR2(30);
l_auto_schedule_sets  VARCHAR2(1):='Y' ;  --4241385
l_schedule_ship_date  DATE := NULL ;      --4241385
l_ship_set_id         NUMBER ;            --4241385
l_ship_from_org_id    NUMBER ;            --4241385
l_validate_combinition NUMBER  ;          --4241385
l_shipping_method_code VARCHAR2(50);      --4241385
l_set_name_dsp             VARCHAR2(20);  --4241385
Cursor C1 is
select Max(to_number(set_name))
from oe_sets
where set_status = 'T'
and   header_id = p_x_line_rec.header_id and
set_type = l_set_pref_type;

Cursor C3 is
select Max(to_number(set_name))
from   oe_sets
where  header_id = p_x_line_rec.header_id
and set_type = l_set_pref_type
and set_name = lsettempname;

CURSOR C4 is
select set_id
from oe_sets
where header_id = p_x_line_rec.header_id
and set_type = l_set_pref_type
and set_status = 'T';

CURSOR C5 IS
Select line_id, shipping_interfaced_flag
 from oe_order_lines_all
where top_model_line_id = p_x_line_rec.line_id
and open_flag = 'Y';

CURSOR C6 is
select set_name
from oe_sets
where header_id = p_x_line_rec.header_id
and set_type =  'FULFILLMENT_SET'
and set_status = 'T';

Cursor C7 is
select set_name
from   oe_sets
where  header_id = p_x_line_rec.header_id
and set_type = l_set_pref_type;
--and set_status = 'T';

CURSOR C2 is
select set_id
from oe_sets
where header_id = p_x_line_rec.header_id
and set_type = l_set_pref_type
and set_status = 'T'
and set_name = nvl(p_x_line_rec.arrival_set,p_x_line_rec.ship_set);

CURSOR C8 is
select line_id,ship_set_id,arrival_set_id
from oe_order_lines_all
where top_model_line_id=p_x_line_rec.line_id
and line_id<>p_x_line_rec.line_id
and open_flag='Y';

CURSOR C9 IS
SELECT inventory_item_id, ship_from_org_id, item_type_code,
       line_id,top_model_line_id,source_document_type_id,  line_number,
       shipment_number, option_number, component_number, service_number,
       line_category_code					--4241385
FROM oe_order_lines_all
WHERE ship_set_id = p_x_line_rec.ship_set_id;



--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

-- Firstly Check if the Set is a new set Requested. We can check in the
-- order of   Arrival, Ship and Fulfillment set

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTER PROCEDURE DEFAULT LINE SET' , 1 ) ;
   END IF;

-- This will process only if the line is internal , standard and model and
-- not shipped

	IF  NOT g_old_arrival_set_path  THEN
     IF NOT ((p_x_line_rec.split_action_code = 'SPLIT' and
              p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE) or
             (p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE and
              p_x_line_rec.split_from_line_id is NOT NULL)) then

      IF  ((p_x_line_rec.arrival_set is not null AND
            p_x_line_rec.arrival_set <> FND_API.G_MISS_CHAR) OR
           (p_x_line_rec.arrival_set_id is not null AND
            p_x_line_rec.arrival_set_id <> FND_API.G_MISS_NUM))
      AND ((p_x_line_rec.ship_set is not null AND
            p_x_line_rec.ship_set <> FND_API.G_MISS_CHAR) OR
           (p_x_line_rec.ship_set_id is not null AND
            p_x_line_rec.ship_set_id <> FND_API.G_MISS_NUM))
      THEN

            IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'INVALID SER OPR' , 2 ) ;
            END IF;
            FND_MESSAGE.Set_Name('ONT', 'OE_SCH_NOT_IN_SHIP_ARR');  -- 2724197 New message added
            oe_msg_pub.add;
            RAISE FND_API.G_EXC_ERROR;

      END IF; -- not both sets populated.

      -- QUOTING Changes - default line set only for lines in fulfillment phase
      IF nvl(p_x_line_rec.transaction_phase_code,'F') = 'F' AND
         p_x_line_rec.source_type_code <> 'EXTERNAL' AND
         p_x_line_rec.shipped_quantity IS NULL AND
        (nvl(p_x_line_rec.fulfilled_flag,'N') =  'N' OR
        (nvl(p_x_line_rec.fulfilled_flag,'N') = 'Y'
         AND p_x_line_rec.ship_set_id is null
         AND p_x_line_rec.arrival_set is null)) AND
	     nvl(p_x_line_rec.open_flag,'N') =  'Y' AND
         (p_x_line_rec.item_type_code = 'STANDARD' OR
          p_x_line_rec.top_model_line_id = p_x_line_rec.line_id ) AND
	     p_x_line_rec.line_category_code <> 'RETURN'   THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'IS A VALID SET REQUEST' , 1 ) ;
        END IF;

	   -- Check if the header preference is set to keep the line in a set
       -- by default
         -- QUOTING changes - add lines to sets based on header preference
         -- during complete negotiation step
	   IF p_x_line_rec.operation = oe_globals.g_opr_create
              OR (OE_Quote_Util.G_COMPLETE_NEG = 'Y'
                  AND NOT OE_GLOBALS.EQUAL(p_x_line_rec.transaction_phase_code
                                   ,p_old_line_rec.transaction_phase_code)
                  )
          THEN

          OE_Order_Cache.Load_Order_Header(p_x_line_rec.header_id);

          IF OE_ORDER_CACHE.g_header_rec.customer_preference_set_code = 'SHIP' OR
		     OE_ORDER_CACHE.g_header_rec.customer_preference_set_code = 'ARRIVAL'
	      THEN
	        l_cust_pref := OE_ORDER_CACHE.g_header_rec.customer_preference_set_code;
			IF l_cust_pref = 'SHIP' THEN
               l_set_pref_type := 'SHIP_SET';
			ELSE
               l_set_pref_type := 'ARRIVAL_SET';
			END IF;

		    g_cust_pref_set := TRUE;

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'INTO SYSTEM SET' , 1 ) ;
           END IF;

           IF NVL(FND_PROFILE.VALUE('ONT_SET_FOR_EACH_LINE'),'N') = 'N' THEN

	          -- Check if the system set is already created
              OPEN C4;
              FETCH C4 into l_set_id;
              close C4;
           ELSE
            oe_debug_pub.add('Profile ARRIVAL: '|| p_x_line_rec.arrival_set,2);
            oe_debug_pub.add('Profile SHIP: ' || p_x_line_rec.ship_set , 2);

            IF p_x_line_rec.arrival_set is not null or
               p_x_line_rec.ship_set is not null THEN
                 OPEN C2;
                 FETCH C2 into l_set_id;
                 close C2;

            END IF;
           END IF;


           IF l_set_id is not null then

            IF l_cust_pref = 'SHIP' THEN

              p_x_line_rec.ship_set_id := l_set_id;


              --2502504
              IF p_x_line_rec.booked_flag = 'Y' THEN

              Validate_Shipset
              ( p_line_rec           =>   p_x_line_rec
               ,p_old_line_rec       =>   p_old_line_rec
               ,x_return_status      =>   l_return_status);

              IF l_debug_level  > 0 THEN
	        	    oe_debug_pub.add(  'Return Status '|| l_return_status , 1 ) ;
              END IF;

              IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 p_x_line_rec.ship_set_id := Null;
                 GOTO NO_PROCESS;
              ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

             END IF;

              IF l_debug_level  > 0 THEN
	        	    oe_debug_pub.add(  'INTO SET EXISTS'|| L_SET_ID , 1 ) ;
            	    oe_debug_pub.add(  'INTO SET EXISTS'|| P_X_LINE_REC.SHIP_SET_ID , 1 ) ;
              END IF;

            ELSIF l_cust_pref = 'ARRIVAL' THEN
              p_x_line_rec.arrival_set_id := l_set_id;
              IF l_debug_level  > 0 THEN
	        	    oe_debug_pub.add(  'INTO SET EXISTS'|| L_SET_ID , 1 ) ;
            	    oe_debug_pub.add(  'INTO SET EXISTS'|| P_X_LINE_REC.ARRIVAL_SET_ID , 1 ) ;
               END IF;
            END IF;

           END IF; -- lSet_id is not null

        	IF l_set_id is null THEN
              IF NVL(FND_PROFILE.VALUE('ONT_SET_FOR_EACH_LINE'),'N') = 'N' THEN
                OPEN C1;
                FETCH C1 INTO lsettempname;
                CLOSE C1;
              END IF;
              IF lsettempname IS NULL   THEN
               IF NVL(FND_PROFILE.VALUE('ONT_SET_FOR_EACH_LINE'),'N') = 'N' THEN
                   lsettempname := 1;
                   LOOP
                       OPEN C3;
                       FETCH C3 INTO tempname;
                       CLOSE C3;
                       IF tempname is not null then
                          lsettempname := lsettempname + 1;
                       ELSE
                          EXIT;
                       END IF;

                   END LOOP ;
               ELSE
                 tempname := 0;

                 FOR L IN C7 LOOP

                  BEGIN
                   IF to_number(L.set_name) > tempname THEN
                      tempname := L.set_name;
                   END IF;
                  EXCEPTION
                   WHEN OTHERS THEN
                    Null;
                  END;
                 END LOOP;
/*
                 OPEN C7;
                 FETCH C7 INTO tempname;
                 CLOSE C7;
*/
                 lsettempname := nvl(tempname,0) + 1;
               END IF;

              ELSE
                 lsettempname := lsettempname;
	          END IF; -- L_set_temp_name
              IF l_cust_pref = 'SHIP' THEN
                 --Bug 5654902
                 --Added the condition to check if 'Ship Set' name already exists
                 IF p_x_line_rec.ship_set IS NULL
                 THEN
                    p_x_line_rec.ship_set := lsettempname;
                 ELSE
                    oe_debug_pub.add('Using the Ship Set Name passed: '||p_x_line_rec.ship_set);
                 END IF;
              ELSIF l_cust_pref = 'ARRIVAL' THEN
                 --Bug 5654902
                 --Added the condition to check if 'Arrival Set' name already exists
                 IF p_x_line_rec.arrival_set IS NULL
                 THEN
                    p_x_line_rec.arrival_set := lsettempname;
                 ELSE
                    oe_debug_pub.add('Using the Arrival Set Name passed: '||p_x_line_rec.arrival_set);
                 END IF;
              END IF;
	        END IF; -- L_set_id is null

             	IF l_debug_level  > 0 THEN
             	    oe_debug_pub.add(  'SYSTEM SET IS' || LSETTEMPNAME , 1 ) ;
             	END IF;

	     END IF; -- Customer Preference
	   END IF; -- Operation is create

	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'INTO SET EXISTS'|| P_X_LINE_REC.SHIP_SET_ID , 1 ) ;
	   END IF;
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'INTO SET EXISTS'|| P_X_LINE_REC.SHIP_SET , 1 ) ;
	   END IF;
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'INTO SET EXISTS'|| P_X_LINE_REC.ARRIVAL_SET , 1 ) ;
	   END IF;
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'INTO SET EXISTS'|| P_X_LINE_REC.ARRIVAL_SET_ID , 1 ) ;
	   END IF;

	   -- Check if the set name is populated and it is a new set
	   -- Process for arrival sets

       IF (p_x_line_rec.arrival_set IS NOT NULL AND
           p_x_line_rec.arrival_set <> FND_API.G_MISS_CHAR) THEN

	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'INTO ARRIVAL SET'|| P_X_LINE_REC.ARRIVAL_SET_ID , 1 ) ;
	   END IF;
     		-- Check if this is existing set
		    IF  Set_Exist(p_set_name  => p_x_line_rec.arrival_set,
              		      p_set_type  => 'ARRIVAL_SET',
                          p_header_id =>p_x_line_rec.header_id,
                          x_set_id    => l_set_id) THEN

                 	l_set_rec := get_set_rec(l_set_id);
			        IF l_set_rec.set_status = 'C' THEN
                        fnd_message.set_name('ONT', 'OE_SET_CLOSED');
                        FND_MESSAGE.SET_TOKEN('SET', l_set_rec.set_name);
                        oe_msg_pub.add;
					    GOTO NO_PROCESS;
                    END IF; -- Set Status = 'C'

	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'ARRIVAL SET-1'|| P_X_LINE_REC.ARRIVAL_SET_ID , 1 ) ;
	   END IF;
                    p_x_line_rec.arrival_set_id := l_set_id;
			        l_set_type := 'ARRIVAL_SET';
                    l_set_name := p_x_line_rec.arrival_set;

			ELSE -- If set not exists
              -- Create the arrival set and populate the set id;
			  l_create_set := 'Y';
			  l_set_type := 'ARRIVAL_SET';
			  l_set_name := p_x_line_rec.arrival_set;

			END IF ; -- Set Exists

            -- Set the cascade flag if line is a model or kit
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'ARRIVAL SET-2'|| P_X_LINE_REC.ARRIVAL_SET_ID , 1 ) ;
	   END IF;

			IF p_x_line_rec.top_model_line_id = p_x_line_rec.line_id
            THEN
			   l_cascade_flag := 'Y';
			END IF;

          -- Now check if the arrival set id is populated in a case when the line
          -- moving into existing arrival set OR removed from existing arrival set
       ELSIF NOT OE_GLOBALS.EQUAL (p_x_line_rec.arrival_set_id,
                                   p_old_line_rec.arrival_set_id )
       THEN
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'ARRIVAL SET-3'|| P_X_LINE_REC.ARRIVAL_SET_ID , 1 ) ;
	   END IF;
			-- Process the moving from one set to another
			IF p_x_line_rec.arrival_set_id IS NOT NULL THEN


               IF Set_Exist(p_set_id => p_x_line_rec.arrival_Set_id) THEN

                   l_Set_id := p_x_line_rec.arrival_Set_id;

				   l_set_rec := get_set_rec(l_set_id);
			       IF l_set_rec.set_status = 'C' THEN
                      fnd_message.set_name('ONT', 'OE_SET_CLOSED');
                      FND_MESSAGE.SET_TOKEN('SET', l_set_rec.set_name);
                      oe_msg_pub.add;
					  GOTO NO_PROCESS;

                   END IF; -- Set Status = 'C'
                   p_x_line_rec.arrival_set_id := l_set_id;
			       l_set_type := 'ARRIVAL_SET';
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'ARRIVAL SET-4'|| P_X_LINE_REC.ARRIVAL_SET_ID , 1 ) ;
	   END IF;

               ELSE -- If set not exists

                 -- not a valid set so retain the old value;
		         p_x_line_rec.arrival_set_id := p_old_line_rec.arrival_set_id;
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'ARRIVAL SET-5'|| P_X_LINE_REC.ARRIVAL_SET_ID , 1 ) ;
	   END IF;
                 GOTO NO_PROCESS;

			   END IF ; -- Set Exists

               -- See if the line is removed from the set */
               ELSIF p_x_line_rec.arrival_set_id IS NULL THEN
         	     p_x_line_rec.arrival_set_id := null;
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'ARRIVAL SET-6'|| P_X_LINE_REC.ARRIVAL_SET_ID , 1 ) ;
	   END IF;
                 l_set_id := null;
			     l_set_type := 'ARRIVAL_SET';
               END IF; -- Arrival set id is not null

               IF p_x_line_rec.top_model_line_id =
                  p_x_line_rec.line_id  THEN
		          l_cascade_flag := 'Y';
               END IF;
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'ARRIVAL SET-7'|| P_X_LINE_REC.ARRIVAL_SET_ID , 1 ) ;
	   END IF;

       -- End Arrival Set Logic
       -- Begin the logic for Ship sets . The logic must go in the same way as
       -- arrival sets and is no different execept for set type being SHIP SET

	   ELSIF (p_x_line_rec.ship_set IS NOT NULL AND
              p_x_line_rec.ship_set <> FND_API.G_MISS_CHAR) THEN

      		-- Check if this is existing set
		    IF  Set_Exist(p_set_name  => p_x_line_rec.ship_set,
                          p_set_type  => 'SHIP_SET',
                          p_header_id => p_x_line_rec.header_id,
                          x_set_id    => l_set_id) THEN

        	    l_set_rec := get_set_rec(l_set_id);
			    IF l_set_rec.set_status = 'C' THEN
                   fnd_message.set_name('ONT', 'OE_SET_CLOSED');
                   FND_MESSAGE.SET_TOKEN('SET', l_set_rec.set_name);
                   oe_msg_pub.add;
                   GOTO NO_PROCESS;
               	END IF; -- Set Status = 'C'
			    p_x_line_rec.ship_set_id := l_set_id;
			    l_set_type := 'SHIP_SET';
			    l_set_name := p_x_line_rec.ship_set;
			ELSE -- If set not exists
              -- Create the arrival set and populate the set id;
			  l_create_set := 'Y';
			  l_set_type := 'SHIP_SET';
			  l_set_name := p_x_line_rec.ship_set;

			END IF ; -- Set Exists

            -- Set the cascade flag if line is a model or kit

			IF p_x_line_rec.top_model_line_id = p_x_line_rec.line_id
            THEN
			   l_cascade_flag := 'Y';
			END IF;

         -- Now check if the arrival set id is populated in a case when the line
         -- moving into existing arrival set OR removed from existing arrival set
       ELSIF NOT OE_GLOBALS.EQUAL (p_x_line_rec.ship_set_id,
                                   p_old_line_rec.ship_set_id )
       THEN
	       IF l_debug_level  > 0 THEN
	           oe_debug_pub.add(  'INTO SHIP SETS '|| P_X_LINE_REC.SHIP_SET_ID , 1 ) ;
	       END IF;
			-- Process the moving from one set to another
			IF p_x_line_rec.ship_set_id IS NOT NULL THEN

              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'SHIP SET ID NOT NULL '|| P_X_LINE_REC.SHIP_SET_ID , 1 ) ;
              END IF;

	          IF  Set_Exist(p_set_id => p_x_line_rec.ship_set_id) THEN

          		l_set_id := p_x_line_rec.ship_set_id;
				l_set_rec := get_set_rec(l_set_id);
			    IF l_set_rec.set_status = 'C' THEN
                   fnd_message.set_name('ONT', 'OE_SET_CLOSED');
                   FND_MESSAGE.SET_TOKEN('SET', l_set_rec.set_name);
                   oe_msg_pub.add;
                   GOTO NO_PROCESS;
       			END IF; -- Set Status = 'C'
			    p_x_line_rec.ship_set_id := l_set_id;
			    l_set_type := 'SHIP_SET';
			    l_set_name := p_x_line_rec.ship_set;

			  ELSE -- If set not exists

                -- not a valid set so retain the old value;
	        	p_x_line_rec.ship_set_id := p_old_line_rec.ship_set_id;
                GOTO NO_PROCESS;

			  END IF ; -- Set Exists
              -- See if the line is removed from the set
            ELSIF p_x_line_rec.ship_set_id IS NULL THEN
				p_x_line_rec.ship_set_id := null;
				l_set_id   := null;
			    l_set_type := 'SHIP_SET';
		    END IF; -- Ship set id is not null

			IF p_x_line_rec.top_model_line_id = p_x_line_rec.line_id
            THEN
			   l_cascade_flag := 'Y';
			END IF;



       END IF; -- Arrival Set is NOT null

	-- Create or Update based on the flags set above

/* First we will create the set if l_create_flag is set to 'Y' */
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'CREATE FLAG IS - ' || L_CREATE_SET , 1 ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'CASCADE FLAG IS - ' || L_CASCADE_FLAG , 1 ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'SET NAME - ' || L_SET_NAME , 1 ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'SET TYPE - ' || L_SET_TYPE , 1 ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'SET ID - ' || L_SET_ID , 1 ) ;
	END IF;
/* 4241385
The below logic will come into picture only when the system parameter "OM:Auto Schedule Sets"
is set to "No" and the set is not yet scheduled. Becuase if the set is scheduled, then
scheduling code will take care to see that all the lines in the ship set, will have a
same warehouse.Also, this piece of code is only for ship sets, becuase arrival sets can
have a different warehouse on each line.

 */
l_auto_schedule_sets := NVL(oe_sys_parameters.Value('ONT_AUTO_SCH_SETS',p_x_line_rec.org_id),'Y');
IF l_auto_schedule_sets = 'N' THEN
   IF l_debug_level  > 0 THEN
	oe_debug_pub.add(  'p_old_line_rec.ship_from_org_id' ||p_old_line_rec.ship_from_org_id) ;
	oe_debug_pub.add(  'p_x_line_rec.ship_from_org_id' ||p_x_line_rec.ship_from_org_id) ;
	oe_debug_pub.add(  'p_old_line_rec.ship_set_id' ||p_old_line_rec.ship_set_id) ;
	oe_debug_pub.add(  'p_x_line_rec.ship_set_id' ||p_x_line_rec.ship_set_id) ;
	oe_debug_pub.add(  'p_x_line_rec.ship_set' ||p_x_line_rec.ship_set) ;
	oe_debug_pub.add(  'p_x_line_rec.arrival_set_id' ||p_x_line_rec.arrival_set_id) ;

   END IF;

   /*IF ((p_x_line_rec.arrival_set_id IS NOT  NULL
    AND p_x_line_rec.arrival_set_id <> FND_API.G_MISS_NUM)
    OR
   ( p_x_line_rec.arrival_set IS NOT NULL
   AND p_x_line_rec.arrival_set <> FND_API.G_MISS_char ))
   THEN

      IF  p_x_line_rec.ship_from_org_id IS NULL THEN
	   FND_MESSAGE.SET_NAME('ONT','ONT_ATTR_REQ_SET');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Warehouse'); --9680007 4241385
			OE_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
      END IF ;

      IF  p_x_line_rec.shipping_method_code IS NULL THEN
	   FND_MESSAGE.SET_NAME('ONT','ONT_ATTR_REQ_SET');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Ship Method');
			OE_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
      END IF ;

   END IF ;*/
  /*we need to ensure that all the lines in a ship set have the same warehouse, if the
  ship set id is passed(from PO API) or even if ship set name is passed (from UI)*/
   IF ((p_x_line_rec.ship_set_id IS NOT  NULL
    AND p_x_line_rec.ship_set_id <> FND_API.G_MISS_NUM)
    OR
   ( p_x_line_rec.ship_set IS NOT NULL
   AND p_x_line_rec.ship_set <> FND_API.G_MISS_char ))
   THEN

     /* IF  p_x_line_rec.ship_from_org_id IS NULL THEN
	   FND_MESSAGE.SET_NAME('ONT','ONT_ATTR_REQ_SET');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Warehouse');
			OE_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR; --9680007 4241385
      END IF ;

      IF  p_x_line_rec.shipping_method_code IS NULL THEN
	   FND_MESSAGE.SET_NAME('ONT','ONT_ATTR_REQ_SET');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Ship Method');
			OE_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
      END IF ; */

     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  ' BEFORE SET EXISTS ' , 1 ) ;
     END IF;
     IF (p_x_line_rec.ship_set_id IS NOT NULL
      AND p_x_line_rec.ship_set_id <> FND_API.G_MISS_NUM) THEN

             BEGIN
             SELECT ship_from_org_id , schedule_ship_date ,shipping_method_code
	     , set_name
             INTO l_ship_from_org_id , l_schedule_ship_Date,l_shipping_method_code
	     , l_set_name_dsp
             FROM oe_sets
             WHERE set_id=p_x_line_rec.ship_set_id;
	     EXCEPTION
	     WHEN NO_DATA_FOUND THEN
	        l_ship_set_id:= NULL ;
		l_ship_from_org_id := NULL ;
                l_schedule_ship_Date := NULL ;
	     END ;
             l_ship_set_id:= p_x_line_rec.ship_set_id;

     ELSIF  ( p_x_line_rec.ship_set IS NOT NULL
      AND p_x_line_rec.ship_set <> FND_API.G_MISS_char ) THEN

    /* if only the ship set name is passed, we can get the ship set id by calling the
    set_exists API*/

	     BEGIN
             SELECT ship_from_org_id , schedule_ship_date, set_id ,shipping_method_code
             INTO l_ship_from_org_id , l_schedule_ship_Date , l_ship_set_id ,
	     l_shipping_method_code
             FROM oe_sets
             WHERE set_name = p_x_line_rec.ship_set
             and set_type = 'SHIP_SET'
	     and header_id = p_x_line_rec.header_id ;
	     EXCEPTION
             WHEN NO_DATA_FOUND THEN
	        l_ship_set_id:= NULL ;
		l_ship_from_org_id := NULL ;
                l_schedule_ship_Date := NULL ;
	     END ;
             l_set_name_dsp:=p_x_line_rec.ship_set;
     END IF ;

  IF l_ship_set_id IS NOT NULL THEN

        /* The first if condition will ensure that the warehouse on the line is different
	from the set warehouse, only then we need to proceed further. Then we need to see
	if the line is already part of the set, or getting added to the set newly.*/
    IF p_x_line_rec.ship_from_org_id IS NOT NULL THEN --9680007
	IF p_x_line_rec.ship_from_org_id <> NVL(l_ship_from_org_id,-99) THEN

          /* we are checking that the line is already part of a set, and we are trying to
	  change the warehouse on the set. Like if there are 4 lines already in set 1,
	  with warehouse V1. If we change the warehouse on one line to M1, then if all the
	  4 lines are available in M1, the warehouse should change on all the lines.*/

	  --9680007 added nvl condition to take care of null values.
	  IF ((p_x_line_rec.ship_from_org_id <> p_old_line_rec.ship_from_org_id)
	  AND p_old_line_rec.ship_from_org_id IS NOT NULL
	  AND p_old_line_rec.ship_from_org_id <>FND_API.G_MISS_NUM
	  AND l_schedule_ship_Date IS NULL)
	  OR (p_x_line_rec.ship_from_org_id IS NOT NULL
	      AND l_ship_from_org_id IS null )THEN --9680007 4241385 added OR condition.

		FOR i IN c9 LOOP

		 BEGIN
		      SELECT 1
		      INTO   l_validate_combinition
		      FROM   mtl_system_items_b msi,
                             org_organization_definitions org
		      WHERE  msi.inventory_item_id= i.inventory_item_id
                      AND    org.organization_id=msi.organization_id
                      AND    sysdate<=nvl(org.disable_date,sysdate)
                      AND    org.organization_id=p_x_line_rec.ship_from_org_id
                      AND    rownum=1 ;
		  EXCEPTION
		    WHEN NO_DATA_FOUND THEN
                        FND_MESSAGE.SET_NAME('ONT','ONT_INVALID_SET_ATTR_W');
			fnd_message.set_token('ATTR1',oe_order_util.GET_ATTRIBUTE_name('ITEM_ID'));
			fnd_message.set_token('ATTR2',oe_order_util.GET_ATTRIBUTE_name('SHIP_FROM_ORG_ID'));
                        OE_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
		  END ;
		END LOOP ;

		/* if the new warehouse is valid on all the lines in the set, then update
		the new warehouse on all the lines and also update the set with the new
		warehouse information*/

                UPDATE oe_order_lines_all
		SET ship_from_org_id=p_x_line_rec.ship_from_org_id
		WHERE ship_set_id= p_x_line_rec.ship_set_id
		AND open_flag='Y';

		Update_Set
	       (p_Set_Id                   => p_x_line_rec.ship_set_id,
		p_Ship_From_Org_Id         => p_x_line_rec.ship_from_org_id,
		p_Ship_To_Org_Id           => p_x_line_rec.Ship_To_Org_Id,
		p_Schedule_Ship_Date       => p_x_line_rec.Schedule_Ship_Date,
		p_Schedule_Arrival_Date    => p_x_line_rec.Schedule_Arrival_Date,
		p_Freight_Carrier_Code     => p_x_line_rec.Freight_Carrier_Code,
		p_Shipping_Method_Code     => p_x_line_rec.Shipping_Method_Code,
		p_shipment_priority_code   => p_x_line_rec.shipment_priority_code,
		X_Return_Status            => l_return_status,
		x_msg_count                => x_msg_count,
		x_msg_data                 => x_msg_data
		);

            /* we will come to the elsif block in the case where there are 3 lines in the
	    order. First two lines with warehouse V1 and third with warehouse W1. All the
	    lines are not scheduled. Now if we put line 1, and 2 in set 1 and try to put
	    line 3 also in set 1 and save, it will not allow to put the line 3 in the set.
	    This is becuase 3rd line is not part of the set yet. So we will not try to
	    cascade the changes.*/

	    ELSIF l_schedule_ship_Date IS NULL THEN
            FND_MESSAGE.SET_NAME('ONT','ONT_DIFF_SET_ATTR');
	    fnd_message.set_token('SHIP_SET',l_set_name_dsp);
            fnd_message.set_token('ATTRIBUTE',oe_order_util.GET_ATTRIBUTE_name('SHIP_FROM_ORG_ID'));
            OE_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
            END IF ;
        END IF ;
    END IF ; --9680007
	/*Adding validation for ship_method also*/

        IF NVL(p_x_line_rec.shipping_method_code,-99) <> NVL(l_shipping_method_code,-99) THEN

          IF NVL(fnd_profile.value('ONT_SHIP_METHOD_FOR_SHIP_SET'),'N')='Y' THEN

          /* we are checking that the line is already part of a set, and we are trying to
	  change the ship method on the set. Like if there are 4 lines already in set 1,
	  with warehouse V1. If we change the warehouse on one line to M1, then if all the
	  4 lines are available in M1, the warehouse should change on all the lines.*/

	  IF ((NVL(p_x_line_rec.shipping_method_code,-99) <>
	       NVL(p_old_line_rec.shipping_method_code,-99) ) --9680007 added nvl condition
	  AND p_old_line_rec.shipping_method_code IS NOT NULL
	  AND p_old_line_rec.shipping_method_code <>FND_API.G_MISS_CHAR
	  AND l_schedule_ship_Date IS NULL)
	  OR
	  (p_x_line_rec.shipping_method_code IS NOT NULL
	   AND l_shipping_method_code IS null ) -- 9680007 4241385
	  THEN


		FOR i IN c9 LOOP

		  BEGIN
		      SELECT  1
                      INTO    l_validate_combinition
                      FROM    OE_SHIP_METHODS_V
                      WHERE   lookup_code = p_x_line_rec.shipping_method_code
                      AND     ENABLED_FLAG = 'Y'
                      AND     SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE)
                      AND     NVL(END_DATE_ACTIVE, SYSDATE)
                      AND     ROWNUM = 1;
		  EXCEPTION
		    WHEN NO_DATA_FOUND THEN

                        FND_MESSAGE.SET_NAME('ONT','ONT_INVALID_SET_ATTR_S');
			fnd_message.set_token('ATTR',oe_order_util.GET_ATTRIBUTE_name('SHIPPING_METHOD_CODE'));
			OE_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
		  END ;
		END LOOP ;

		/* if the new warehouse is valid on all the lines in the set, then update
		the new warehouse on all the lines and also update the set with the new
		warehouse information*/

                UPDATE oe_order_lines_all
		SET shipping_method_code=p_x_line_rec.shipping_method_code
		WHERE ship_set_id= p_x_line_rec.ship_set_id
		AND open_flag='Y';

		Update_Set
	       (p_Set_Id                   => p_x_line_rec.ship_set_id,
		p_Ship_From_Org_Id         => p_x_line_rec.ship_from_org_id,
		p_Ship_To_Org_Id           => p_x_line_rec.Ship_To_Org_Id,
		p_Schedule_Ship_Date       => p_x_line_rec.Schedule_Ship_Date,
		p_Schedule_Arrival_Date    => p_x_line_rec.Schedule_Arrival_Date,
		p_Freight_Carrier_Code     => p_x_line_rec.Freight_Carrier_Code,
		p_Shipping_Method_Code     => p_x_line_rec.Shipping_Method_Code,
		p_shipment_priority_code   => p_x_line_rec.shipment_priority_code,
		X_Return_Status            => l_return_status,
		x_msg_count                => x_msg_count,
		x_msg_data                 => x_msg_data
		);

            /* we will come to the elsif block in the case where there are 3 lines in the
	    order. First two lines with warehouse V1 and third with warehouse W1. All the
	    lines are not scheduled. Now if we put line 1, and 2 in set 1 and try to put
	    line 3 also in set 1 and save, it will not allow to put the line 3 in the set.
	    This is becuase 3rd line is not part of the set yet. So we will not try to
	    cascade the changes.*/

	    ELSIF l_schedule_ship_Date IS NULL THEN
            FND_MESSAGE.SET_NAME('ONT','ONT_DIFF_SET_ATTR');
	    fnd_message.set_token('SHIP_SET',l_set_name_dsp);
            fnd_message.set_token('ATTRIBUTE',oe_order_util.GET_ATTRIBUTE_name('SHIPPING_METHOD_CODE'));
            OE_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
            END IF ;
        END IF ;
       END IF ;--ship methos profile option.
    END IF ;
  END IF ;
END IF ; -- autoschedule sets.
-- end 4241385
	IF l_create_set = 'Y' THEN
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  ' BEFORE CREATING SET ' , 1 ) ;
	     END IF;
     Create_Set
        (p_Set_Name => l_set_name,
         p_Set_Type => l_set_type,
         p_Header_Id => p_x_line_rec.header_id,
	 p_Ship_From_Org_Id => p_x_line_rec.ship_from_org_id, --ER 4241385
     	 p_Shipping_Method_Code => p_x_line_rec.Shipping_Method_Code, --ER 4241385
         x_Set_Id                 => l_set_id,
         X_Return_Status  => l_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data);

/* Re Initialize the customer preference to false if it was set in the above
 if condition */
	g_cust_pref_set := FALSE;

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
      END IF;
-- Populate set id on the line record accordingly
		IF l_set_type = 'ARRIVAL_SET' THEN
			p_x_line_rec.arrival_set_id := l_set_id;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ARRIVAL SET ID IS '|| P_X_LINE_REC.ARRIVAL_SET_ID , 1 ) ;
	END IF;
		ELSIF l_set_type = 'SHIP_SET' THEN
			p_x_line_rec.ship_set_id := l_set_id;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'SHIP SET ID IS '|| P_X_LINE_REC.SHIP_SET_ID , 1 ) ;
	END IF;
		END IF;

	END IF ; -- Create Set is Y
-- Now look at the cascade flag and update the children of the model

		IF l_cascade_flag = 'Y' THEN
	/* Update set id on the children of the top model */

/*Changes for bug 6719457 start*/
	IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Cascade flag is yes',1);
  END IF;
    IF l_set_type = 'ARRIVAL_SET' THEN
    	begin
	select ol.arrival_set_id
	into l_old_set_id
	from oe_order_lines_all ol
	where ol.top_model_line_id = p_x_line_rec.line_id
	and ol.line_id<>p_x_line_rec.line_id
	and rownum=1;
	exception
     		when no_data_found then
      		 null;
		 IF l_debug_level  > 0 THEN
      		 oe_debug_pub.add('old arrival set does not exist');
		 END IF;
        end;
     ELSIF l_set_type='SHIP_SET' THEN
  	begin
	select distinct(ol.ship_set_id)
	into l_old_set_id
	from oe_order_lines_all ol
	where ol.top_model_line_id = p_x_line_rec.line_id
	and ol.line_id<>p_x_line_rec.line_id
	and rownum=1;
	exception
    		 when no_data_found then
       		 null;
		 IF l_debug_level  > 0 THEN
       		 oe_debug_pub.add('old Ship set does not exist');
		 END IF;
    	end;
     END IF;
     IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'After selecting, old set id is:'||l_old_set_id,1);
     END IF;
/*Changes for bug 6719457 End*/

		Begin
		Update oe_order_lines_all l
		set
		arrival_set_id =
		decode(l_Set_type , 'ARRIVAL_SET', l_set_id,l.arrival_set_id),
		ship_set_id =
		decode(l_Set_type , 'SHIP_SET', l_set_id,l.ship_set_id)
		WHERE
		top_model_line_id = p_x_line_rec.line_id
        AND open_flag = 'Y'
        and l.item_type_code<>'SERVICE'; -- added for bug 8369694

/*Changes for bug 6719457 start*/

 FOR i in C8 loop
    l_child_line_rec:=OE_LINE_UTIL.QUERY_ROW(p_line_id => i.line_id);
    IF l_child_line_rec.schedule_status_code is not null THEN
        l_action := OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE;
    ELSE
        l_action := OE_SCHEDULE_UTIL.OESCH_ACT_SCHEDULE;
    END IF;

    IF OE_QUOTE_UTIL.G_COMPLETE_NEG='Y'
    THEN
       l_operation:=OE_GLOBALS.G_OPR_CREATE;
    ELSE
       l_operation:= l_child_line_rec.operation;
    END IF;

	IF l_set_type='ARRIVAL_SET'
	AND i.arrival_set_id<>l_old_set_id THEN

		l_entity_type := OE_SCHEDULE_UTIL.OESCH_ENTITY_ARRIVAL_SET;

		IF l_debug_level  > 0 THEN
		oe_debug_pub.add( 'new arrival set id id'||i.arrival_set_id);
		END IF;

		IF OE_Delayed_Requests_PVT.Check_for_Request
    		(   p_entity_code  =>OE_GLOBALS.G_ENTITY_ALL
    		,   p_entity_id    =>i.line_id
    		,   p_request_type =>OE_GLOBALS.G_GROUP_SCHEDULE)
		 THEN


			OE_delayed_requests_Pvt.log_request
		(p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,  --OE_GLOBALS.G_ENTITY_LINE,
		 p_entity_id              => l_child_line_rec.line_id,
		 p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
		 p_requesting_entity_id   => l_child_line_rec.line_id,
		 p_request_type           => OE_GLOBALS.G_GROUP_SCHEDULE,
		 p_param1                 => l_child_line_rec.arrival_set_id,
		 p_param2                 => l_child_line_rec.header_id,
		 p_param3                 => l_action,
		 p_param4                 => l_child_line_rec.ship_from_org_id,
		 p_param5                 => l_child_line_rec.ship_to_org_id,
		 p_date_param1            => l_child_line_rec.schedule_ship_date,
		 p_date_param2            => l_child_line_rec.schedule_arrival_date,
		 p_date_param3            => l_child_line_rec.request_date,
		 p_date_param4            => l_child_line_rec.request_date,
		 p_date_param5            => l_child_line_rec.request_date,
		 p_param6                 => l_child_line_rec.ship_set_id,
		 p_param7                 => l_child_line_rec.arrival_set_id,
		 p_param8                 => l_entity_type,
		 p_param9                 => l_child_line_rec.ship_to_org_id,
		 p_param10                => l_child_line_rec.ship_from_org_id,
		 p_param11                =>l_child_line_rec.shipping_method_code,
		 /* removed param11 to fix the bug 2916814 */
		 p_param14                => l_operation,
		 x_return_status          => l_return_status
		);
		END IF;
	ELSIF l_set_type='SHIP_SET'
	AND i.ship_set_id<>l_old_set_id THEN

		l_entity_type := OE_SCHEDULE_UTIL.OESCH_ENTITY_SHIP_SET;

		IF l_debug_level  > 0 THEN
			oe_debug_pub.add( 'new ship set id id'||i.ship_set_id);
		END IF;

		IF OE_Delayed_Requests_PVT.Check_for_Request
    		(   p_entity_code  =>OE_GLOBALS.G_ENTITY_ALL
    		,   p_entity_id    =>i.line_id
    		,   p_request_type =>OE_GLOBALS.G_GROUP_SCHEDULE)
		THEN
			OE_delayed_requests_Pvt.log_request
			(p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,  --OE_GLOBALS.G_ENTITY_LINE,
			 p_entity_id              => l_child_line_rec.line_id,
			 p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
			 p_requesting_entity_id   => l_child_line_rec.line_id,
			 p_request_type           => OE_GLOBALS.G_GROUP_SCHEDULE,
			 p_param1                 => l_child_line_rec.ship_set_id,
			 p_param2                 => l_child_line_rec.header_id,
			 p_param3                 => l_action,
			 p_param4                 => l_child_line_rec.ship_from_org_id,
			 p_param5                 => l_child_line_rec.ship_to_org_id,
			 p_date_param1            => l_child_line_rec.schedule_ship_date,
			 p_date_param2            => l_child_line_rec.schedule_arrival_date,
			 p_date_param3            => l_child_line_rec.request_date,
			 p_date_param4            => l_child_line_rec.request_date,
			 p_date_param5            => l_child_line_rec.request_date,
			 p_param6                 => l_child_line_rec.ship_set_id,
			 p_param7                 => l_child_line_rec.arrival_set_id,
			 p_param8                 => l_entity_type,
			 p_param9                 => l_child_line_rec.ship_to_org_id,
			 p_param10                => l_child_line_rec.ship_from_org_id,
			 p_param11                =>l_child_line_rec.shipping_method_code,
			/* removed param11 to fix the bug 2916814 */
			 p_param14                => l_operation,
			 x_return_status          => l_return_status
			 );
		END IF;
	END IF;
	IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'After loggin the group_schedule request for line '||i.line_id,1);
	END IF;
END LOOP;

/*Changes for bug 6719457 End*/


		FOR optionrec in C5
		Loop
		IF  optionrec.shipping_interfaced_flag = 'Y' THEN

           IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'UPDATE SHIPPING : CHILDREN OF MODEL FOR SETS ' || TO_CHAR ( OPTIONREC.LINE_ID ) , 1 ) ;
           END IF;

          OE_Delayed_Requests_Pvt.Log_Request(
          p_entity_code        =>      OE_GLOBALS.G_ENTITY_LINE,
          p_entity_id              =>      optionrec.line_id,
          p_requesting_entity_code   =>   OE_GLOBALS.G_ENTITY_LINE,
          p_requesting_entity_id     =>   optionrec.line_id,
          p_request_type              =>  OE_GLOBALS.G_UPDATE_SHIPPING,
          p_request_unique_key1       =>  OE_GLOBALS.G_OPR_UPDATE,
          p_param1                     =>      FND_API.G_TRUE,
          x_return_status               =>      l_return_status);

        	END IF;
		End loop;


        -- Setting G_CASCADING_REQUEST_LOGGED to requery the lines in the form
        OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;

		exception
			when others then
				null;
		end;-- Begin of the update

		END IF; -- Cascade Flag
	ELSE -- IF not external
      IF NOT(p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE
      AND p_x_line_rec.top_model_line_id <> p_x_line_rec.line_id)
      AND p_x_line_rec.top_model_line_id IS NOT NULL THEN

		IF p_x_line_rec.ship_set IS NOT NULL AND
			p_x_line_rec.ship_set <> FND_API.G_MISS_CHAR THEN
            IF  oe_set_util.Set_Exist(p_set_name  => p_x_line_rec.ship_set,
                          p_set_type  => 'SHIP_SET',
                          p_header_id =>p_x_line_rec.header_id,
                          x_set_id    => p_x_line_rec.ship_set_id) THEN
        		null;
			END IF;
		ELSIF p_x_line_rec.arrival_set IS NOT NULL AND
			p_x_line_rec.arrival_set <> FND_API.G_MISS_CHAR THEN
            IF  oe_set_util.Set_Exist(p_set_name  => p_x_line_rec.arrival_set,
                          p_set_type  => 'ARRIVAL_SET',
                          p_header_id =>p_x_line_rec.header_id,
                          x_set_id    => p_x_line_rec.arrival_set_id) THEN
        		null;
			END IF;
		END IF;


	    IF NOT OE_GLOBALS.EQUAL (p_x_line_rec.ship_set_id,
	    			 p_old_line_rec.ship_set_id) OR
	    NOT OE_GLOBALS.EQUAL (p_x_line_rec.arrival_Set_id,
	    			 p_old_line_rec.arrival_Set_id) THEN


            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SHIP SET NAME-' || P_X_LINE_REC.SHIP_SET ) ;
            END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'OLD SHIP SET NAME-' || P_OLD_LINE_REC.SHIP_SET ) ;
            END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SHIP SET-' || P_X_LINE_REC.SHIP_SET_ID ) ;
            END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'OLD SHIP SET-' || P_OLD_LINE_REC.SHIP_SET_ID ) ;
            END IF;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'ARRIVAL SET-' || P_X_LINE_REC.ARRIVAL_SET_ID ) ;
            END IF;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ARRIVAL SHIP SET-' || P_OLD_LINE_REC.ARRIVAL_SET_ID ) ;
         END IF;
            FND_MESSAGE.SET_NAME('ONT','OE_INVALID_SET_OPR');
           -- FND_MESSAGE.SET_TOKEN('ITEMTYPE', p_x_line_rec.item_type_code);
            OE_MSG_PUB.ADD;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SET- NOT ALLOWED FOR THIS ITEMTYPE' ) ;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;


	  END IF;
    END IF; -- If not EXTERNAL
<< NO_PROCESS >>
		NULL;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'SHIP SET ID IS '|| P_X_LINE_REC.SHIP_SET_ID , 1 ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ARRIVAL SET ID IS '|| P_X_LINE_REC.ARRIVAL_SET_ID , 1 ) ;
	END IF;


        OE_DEBUG_PUB.Add('Automatic Fulfillment Set:'||p_x_line_rec.fulfillment_set);

        IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

         OE_Order_Cache.Load_Order_Header(p_x_line_rec.header_id);

         IF OE_ORDER_CACHE.g_header_rec.default_fulfillment_set = 'Y' THEN

            IF l_debug_level  > 0 THEN
               OE_DEBUG_PUB.Add('Default Fulfillment set to YES!!!',1 ) ;
            END IF;

            l_set_pref_type := 'FULFILLMENT_SET';

              -- Check if the system set is already created

              OPEN C6;
              FETCH C6 INTO l_fulfillment_set;
              CLOSE C6;

              IF l_debug_level  > 0 THEN
                 OE_DEBUG_PUB.Add('After Checking System Set:'||l_fulfillment_set) ;
              END IF;

              l_x_line_rec := p_x_line_rec;

              IF l_fulfillment_set IS NULL THEN

              -- Get the Maximum Set Name of System generated sets

              OPEN C1;
              FETCH C1 INTO lsettempname;
              CLOSE C1;

              OE_DEBUG_PUB.Add('Temp Set Name:'||lsettempname);

              IF lsettempname IS NULL   THEN
                 lsettempname := 1;

                 LOOP
                 OPEN C3;
                 FETCH C3 INTO tempname;
                 CLOSE C3;

                 IF tempname is not null then
                    lsettempname := lsettempname + 1;

                  ELSE
                    EXIT;
                 END IF;

                 END LOOP ;
              ELSE
                 lsettempname := lsettempname;
              END IF;

              l_x_line_rec.fulfillment_set := lsettempname;

              ELSE
              l_x_line_rec.fulfillment_set := l_fulfillment_set;

             END IF;

             IF l_debug_level  > 0 THEN
                OE_DEBUG_PUB.Add('Auto Fulfillment Set:'||p_x_line_rec.fulfillment_set);
                OE_DEBUG_PUB.Add('Item Type:'||p_x_line_rec.item_type_code);
                OE_DEBUG_PUB.Add('Service Reference:'||p_x_line_rec.service_reference_line_id);
             END IF;

             IF p_x_line_rec.fulfillment_set IS NULL THEN
                p_x_line_rec.fulfillment_set := l_x_line_rec.fulfillment_set;
             END IF;

             IF (l_x_line_rec.item_type_code <> 'SERVICE') OR
                    (l_x_line_rec.item_type_code = 'SERVICE' AND
                       l_x_line_rec.service_reference_line_id IS NOT NULL AND
                            Is_Service_Eligible(l_x_line_rec) )THEN

                 Validate_Fulfillment_Set
                        ( p_x_line_rec   => l_x_line_rec,
                          p_old_line_rec => p_old_line_rec,
                          p_system_set   => 'Y');

             END IF;
          END IF;

      END IF;

        OE_DEBUG_PUB.Add('Before User Defined Ful Set:'||p_x_line_rec.item_type_code);

        IF p_x_line_rec.fulfillment_set is NOT NULL  AND
               (p_x_line_rec.item_type_code <> 'SERVICE') OR
                    (p_x_line_rec.item_type_code = 'SERVICE' AND
                       p_x_line_rec.service_reference_line_id IS NOT NULL AND
                            Is_Service_Eligible(p_x_line_rec) )THEN

            Validate_Fulfillment_Set
                ( p_x_line_rec   => p_x_line_rec,
                  p_old_line_rec => p_old_line_rec);

        END IF;

    END IF; -- Split action code
  END IF; -- g old arrival set path


		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'EXIT PROCEDURE DEFAULT LINE SET' , 1 ) ;
		END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

     RAISE FND_API.G_EXC_ERROR;


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Default_Line_Set'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;




END Default_Line_Set;

Procedure Validate_Fulfillment_Set
( p_x_line_rec   IN OUT NOCOPY oe_order_pub.line_rec_type,
  p_old_line_rec IN oe_order_pub.line_rec_type,
  p_system_set   IN VARCHAR2 DEFAULT 'N'
)
IS
l_set_id               number;
l_cascade_flag         varchar2(1) := 'N';
l_create_set           varchar2(1) := 'N';
l_set_type             varchar2(30) ;
l_set_name             varchar2(2000);
x_msg_data             varchar2(32000);
x_msg_count            number ;
l_return_status        varchar2(30);
l_ful_exists           varchar2(1) := 'N';
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
-- 4925992
l_top_model_line_id    NUMBER;
BEGIN

  OE_DEBUG_PUB.Add('Entering Validate Fulfillment Set');

  IF --p_x_line_rec.source_type_code <> 'EXTERNAL' AND --Bug #4537341
      p_x_line_rec.shipped_quantity IS NULL AND
      (p_x_line_rec.item_type_code = 'STANDARD' OR
       p_x_line_rec.top_model_line_id =
       p_x_line_rec.line_id OR
       p_x_line_rec.item_type_code = 'SERVICE') AND -- the following added for 3504787
       p_x_line_rec.open_flag = 'Y' and
       nvl(p_x_line_rec.cancelled_flag, 'N') <> 'Y' AND
       (p_x_line_rec.ordered_quantity <> 0 OR -- OR added for bug4024986
        p_x_line_rec.ordered_quantity IS NULL ) AND
       (nvl(p_x_line_rec.fulfilled_flag, 'N') <> 'Y' OR
        fulfill_sts(p_x_line_rec.line_id) = 'NOTIFIED')  THEN
                        l_set_id := null;
                        l_set_name := null;
                        l_set_type := null;
                        l_create_set := 'N';
                        l_cascade_flag := 'N';
                        l_ful_exists := 'N';

        IF (p_x_line_rec.fulfillment_set IS NOT NULL AND
            p_x_line_rec.fulfillment_set <> FND_API.G_MISS_CHAR)THEN
               IF  Set_Exist(p_set_name =>p_x_line_rec.fulfillment_set,
                             p_set_type => 'FULFILLMENT_SET',
                             p_header_id =>p_x_line_rec.header_id,
                             x_set_id    => l_set_id) THEN

                  -- 4925992
                  IF p_x_line_rec.line_id = p_x_line_rec.top_model_line_id
                     AND p_x_line_rec.operation <> 'CREATE'
                  THEN
                     l_top_model_line_id := p_x_line_rec.line_id;
                  ELSE
                     l_top_model_line_id := NULL;
                  END IF;

                  Create_Fulfillment_Set(p_line_id           => p_x_line_rec.line_id,
                                         -- 4925992
                                         p_top_model_line_id => l_top_model_line_id,
                                         p_set_id            => l_set_id);
               ELSE
                   l_create_set := 'Y';

               END IF;

               l_ful_exists := 'Y';

       ELSIF NOT OE_GLOBALS.EQUAL(p_x_line_rec.fulfillment_set_id,
                                  p_old_line_rec.fulfillment_set_id) THEN
             IF NOT Set_Exist(p_set_id => p_x_line_rec.fulfillment_set_id) THEN

                p_x_line_rec.fulfillment_set_id := NULL;
                RETURN;
             ELSE
                -- 4925992
                IF p_x_line_rec.line_id = p_x_line_rec.top_model_line_id
                   AND p_x_line_rec.operation <> 'CREATE'
                THEN
                   l_top_model_line_id := p_x_line_rec.line_id;
                ELSE
                   l_top_model_line_id := NULL;
                END IF;

                Create_Fulfillment_Set(p_line_id           => p_x_line_rec.line_id,
                                       -- 4925992
                                       p_top_model_line_id => l_top_model_line_id,
                                       p_set_id            => l_set_id);
             END IF;

             l_ful_exists := 'Y';

        END IF;

        -- Create the fulfillment set only if the fulfillment set
        -- request  exists and l_create_flag is set to 'Y'

        IF l_ful_exists = 'Y' AND l_create_set = 'Y' THEN

           Create_Set
               (p_Set_Name      => p_x_line_rec.fulfillment_Set,
                p_Set_Type      => 'FULFILLMENT_SET',
                p_Header_Id     => p_x_line_rec.header_id,
                p_system_set    => p_system_set,
                 x_Set_Id        => l_set_id,
                X_Return_Status => l_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data);

           IF l_set_id is not null THEN
              -- 4925992
              IF p_x_line_rec.line_id = p_x_line_rec.top_model_line_id
                 AND p_x_line_rec.operation <> 'CREATE'
              THEN
                 l_top_model_line_id := p_x_line_rec.line_id;
              ELSE
                 l_top_model_line_id := NULL;
              END IF;

              Create_Fulfillment_Set(p_line_id           => p_x_line_rec.line_id,
                                     -- 4925992
                                     p_top_model_line_id => l_top_model_line_id,
                                     p_set_id            => l_set_id);
           END IF;

         END IF;

         -- Cascading of fulfillment sets to options is not required in case of
         -- a model since the create fulfillment will take care of cascading the line
         -- passed is a model line

   END IF;

  OE_DEBUG_PUB.Add('Exiting Validate Fulfillment Set');

EXCEPTION
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_Fulfillment_Set'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End Validate_Fulfillment_Set;

-- 4026756
/*
PROCEDURE: Delete_Set
DESCRIPTION:This api will delete set record from oe_sets table if
            the set is not associated with any line.
*/
Procedure Delete_Set(p_request_rec   IN  OE_ORDER_PUB.request_rec_type,
                     x_return_status OUT NOCOPY VARCHAR2)
IS
l_dummy  NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'ENTERING DELETE SET' , 3 ) ;
     oe_debug_pub.add(  'HEADER ID '||p_request_rec.param2 , 3 ) ;
     oe_debug_pub.add(  'SET TYPE'||p_request_rec.param3 , 3 ) ;
     oe_debug_pub.add(  'SET ID'||p_request_rec.param1 , 3 ) ;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BEGIN
     IF p_request_rec.param3 = oe_schedule_util.OESCH_ENTITY_SHIP_SET THEN
        SELECT 1
        INTO l_dummy
        FROM oe_order_lines_all
        WHERE header_id=p_request_rec.param2
        AND ship_set_id =p_request_rec.param1
        AND ROWNUM =1;

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LINE EXISTS WITH THE SHIP SET' , 3 ) ;
        END IF;
     ELSIF p_request_rec.param3 = oe_schedule_util.OESCH_ENTITY_ARRIVAL_SET THEN
        SELECT 1
        INTO l_dummy
        FROM oe_order_lines_all
        WHERE header_id=p_request_rec.param2
        AND arrival_set_id =p_request_rec.param1
        AND ROWNUM =1;

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LINE EXISTS WITH THE ARRIVAL SET' , 3 ) ;
        END IF;
     END IF;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'DELETING SET '||p_request_rec.param1 , 3 ) ;
        END IF;

        DELETE FROM OE_SETS
        WHERE set_id = p_request_rec.param1;

     WHEN OTHERS THEN
        NULL;
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'IN OTHERS EXCEPTION OF DELETE SET ' , 3 ) ;
        END IF;
  END;
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'EXITING DELETE SET' , 3 ) ;
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
      ,   'Delete_Set'
       );
    END IF;
END Delete_Set;

/*--------------------------------------------------------------------------
 * Function Name : Stand_Alone_set_exists
 * Description   : This procedure check if the set contains any Inactive Demand
 *                 Line or not.Will return TRUE if there is any Inactive Demand
 *                 Line in the set.It will return TRUE if this is a new set.
 * Parameters    : p_ship_set_id IN NUMBER  Ship Set Id
 *                 p_arrival_set_id IN NUMBER Arrival Set id
 *                 p_header_id IN NUMBER Header id
 *                 p_line_id IN NUMBER   Line Id
 *                 p_sch_level IN VARCHAR2 Scheduling Level of the line
 * -------------------------------------------------------------------------*/


FUNCTION Stand_Alone_set_exists (p_ship_set_id IN NUMBER,
                                 p_arrival_set_id IN NUMBER,
                                 p_header_id IN NUMBER,
                                 p_line_id IN NUMBER,
				 p_sch_level IN VARCHAR2)
RETURN BOOLEAN IS
l_row_exists NUMBER;
l_scheduling_Level_code VARCHAR2(30);
l_line_type_id NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING STAND_ALONE_SET_EXISTS '||p_ship_set_id, 1 ) ;
   END IF;

     IF p_ship_set_id IS NOT NULL THEN
        SELECT line_type_id INTO l_line_type_id
          FROM OE_ORDER_LINES_ALL
         WHERE header_id = p_header_id
           AND ship_set_id = p_ship_set_id
           AND line_id <> p_line_id
           AND rownum=1;
        l_scheduling_level_code
               := Oe_Schedule_Util.Get_Scheduling_Level(p_header_id,
                                                        l_line_type_id);
        -- Return True if sch level of new line is 4/5 and set line is also 4/5
        -- Also return true if line is a active demand line and set line is also
        -- an active demand line
        IF l_scheduling_level_code= Oe_Schedule_Util.SCH_LEVEL_FOUR OR
         l_scheduling_level_code = Oe_Schedule_Util.SCH_LEVEL_FIVE THEN
          IF p_sch_level = Oe_Schedule_Util.SCH_LEVEL_FOUR OR
               p_sch_level = Oe_Schedule_Util.SCH_LEVEL_FIVE THEN

             RETURN TRUE;
          ELSE
             RETURN FALSE;
          END IF;
        ELSIF p_sch_level = Oe_Schedule_Util.SCH_LEVEL_FOUR OR
               p_sch_level = Oe_Schedule_Util.SCH_LEVEL_FIVE THEN
           RETURN FALSE;
        ELSE
          RETURN TRUE;
        END IF;
     ELSE
        SELECT line_type_id INTO l_line_type_id
          FROM OE_ORDER_LINES_ALL
         WHERE header_id = p_header_id
           AND arrival_set_id = p_arrival_set_id
           AND line_id <> p_line_id
           AND rownum=1;
        l_scheduling_level_code
               := Oe_Schedule_Util.Get_Scheduling_Level(p_header_id,
                                                        l_line_type_id);

        IF l_scheduling_level_code= Oe_Schedule_Util.SCH_LEVEL_FOUR OR
         l_scheduling_level_code = Oe_Schedule_Util.SCH_LEVEL_FIVE THEN
          IF p_sch_level = Oe_Schedule_Util.SCH_LEVEL_FOUR OR
               p_sch_level = Oe_Schedule_Util.SCH_LEVEL_FIVE THEN

             RETURN TRUE;
          ELSE
             RETURN FALSE;
          END IF;
        ELSIF p_sch_level = Oe_Schedule_Util.SCH_LEVEL_FOUR OR
               p_sch_level = Oe_Schedule_Util.SCH_LEVEL_FIVE THEN
           RETURN FALSE;
        ELSE
          RETURN TRUE;
        END IF;
     END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- New set, return true.
        RETURN TRUE;

END Stand_Alone_set_exists;

END OE_Set_util;


/
