--------------------------------------------------------
--  DDL for Package Body OE_SCH_ORGANIZER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SCH_ORGANIZER_UTIL" AS
/* $Header: OEXUSCOB.pls 120.11.12010000.3 2009/04/08 08:44:35 spothula ship $ */

G_PKG_NAME         CONSTANT     VARCHAR2(30):='OE_SCH_ORGANIZER_UTIL';

------------------------------------------------------------------------
PROCEDURE Sch_Window_Key_Commit
( p_x_sch_line_tbl IN OUT NOCOPY sch_line_tbl_type,
  x_return_status OUT NOCOPY VARCHAR2, x_msg_count OUT NOCOPY NUMBER, x_msg_data OUT NOCOPY VARCHAR2,
  x_failed_count OUT NOCOPY NUMBER)
------------------------------------------------------------------------
IS
l_x_old_line_tbl OE_ORDER_PUB.Line_Tbl_Type;
l_x_line_tbl OE_ORDER_PUB.Line_Tbl_Type;
l_x_line_rec OE_ORDER_PUB.Line_Rec_Type;
l_control_rec OE_GLOBALS.Control_Rec_Type;
l_count NUMBER;
l_init_msg VARCHAR2(30) := FND_API.G_TRUE;
l_failed_count NUMBER := 0;
K NUMBER := 2;
L NUMBER;
l_dummy NUMBER;
--R12.MOAC--
l_org_id   NUMBER :=-99;
l_access_mode  VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
-- for every record in g_line_tbl, parse the G_line_tbl for records to be processed together
-- e.g. sets, SMCs etc. those line_id will be inserted into the exclude list, only if
-- a given line_id which is not in the list will be processed by the loop

l_count := p_x_sch_line_tbl.count;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SCH: IN SCH_WINDOW_KEY_COMMIT: COUNT:' || L_COUNT ) ;
END IF;
--R12.MOAC--
l_access_mode := mo_global.get_access_mode;

l_control_rec.controlled_operation := TRUE; --since we do process partial
l_control_rec.process_partial := TRUE;

For I in 1..l_count Loop  --loop for all modified lines
    BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SCH: MAIN LOOP LINE_ID: ' || P_X_SCH_LINE_TBL ( I ) .LINE_ID ) ;
    END IF;
    IF nvl(p_x_sch_line_tbl(I).exclude, 'N') <> 'Y' THEN
    --R12.MOAC--
       IF l_access_mode <> 'S' and l_org_id  <>  p_x_sch_line_tbl(I).org_id THEN
          l_org_id := p_x_sch_line_tbl(I).org_id;
          mo_global.set_policy_context(p_access_mode => 'S',
                                        p_org_id  => l_org_id);
       END IF;

       OE_Line_Util.Query_Row
       (   p_line_id                     => p_x_sch_line_tbl(I).line_id
       ,   x_line_rec                    => l_x_line_rec
       );

       l_x_old_line_tbl(1) := l_x_line_rec;
       l_x_line_tbl(1) := l_x_old_line_tbl(1);

       l_x_line_tbl(1).source_type_code  := p_x_sch_line_tbl(I).source_type_code;

       l_x_line_tbl(1).schedule_ship_date := p_x_sch_line_tbl(I).schedule_ship_date;
       IF l_x_line_tbl(1).source_type_code <>  'EXTERNAL' THEN
         l_x_line_tbl(1).schedule_arrival_date := p_x_sch_line_tbl(I).schedule_arrival_date;
         l_x_line_tbl(1).reserved_quantity := p_x_sch_line_tbl(I).reserved_quantity;
         l_x_line_tbl(1).reserved_quantity2 := p_x_sch_line_tbl(I).reserved_quantity2; -- INVCONV 4668439
         l_x_line_tbl(1).subinventory := p_x_sch_line_tbl(I).subinventory;
         IF p_x_sch_line_tbl(I).ship_set_changed = 'Y' THEN
           l_x_line_tbl(1).ship_set := p_x_sch_line_tbl(I).ship_set;
           l_x_line_tbl(1).ship_set_id := null;
         END IF;
         IF p_x_sch_line_tbl(I).arrival_set_changed = 'Y' THEN
           l_x_line_tbl(1).arrival_set := p_x_sch_line_tbl(I).arrival_set;
           l_x_line_tbl(1).arrival_set_id := null;
         END IF;
         l_x_line_tbl(1).planning_priority := p_x_sch_line_tbl(I).planning_priority;
       END IF;

       l_x_line_tbl(1).ship_from_org_id := p_x_sch_line_tbl(I).ship_from_org_id;
       l_x_line_tbl(1).demand_class_code := p_x_sch_line_tbl(I).demand_class_code;
       l_x_line_tbl(1).shipment_priority_code  := p_x_sch_line_tbl(I).shipment_priority_code;


       l_x_line_tbl(1).shipping_method_code  := p_x_sch_line_tbl(I).shipping_method_code;
  /*   l_x_line_tbl(1).project_id:= p_x_sch_line_tbl(I).project_id;
       l_x_line_tbl(1).task_id  := p_x_sch_line_tbl(I).task_id;
       l_x_line_tbl(1).end_item_unit_number := p_x_sch_line_tbl(I).end_item_unit_number;
  */
       l_x_line_tbl(1).override_atp_date_code := p_x_sch_line_tbl(I).override_atp_date_code;
       l_x_line_tbl(1).firm_demand_flag := p_x_sch_line_tbl(I).firm_demand_flag; -- 8370582
       l_x_line_tbl(1).late_demand_penalty_factor := p_x_sch_line_tbl(I).late_demand_penalty_factor;
       l_x_line_tbl(1).latest_acceptable_date := p_x_sch_line_tbl(I).latest_acceptable_date;


       l_x_line_tbl(1).operation := 'UPDATE';
       -- 4195146
       /*  Start Audit Trail */
       l_x_line_tbl(1).change_reason := 'SYSTEM';
       l_x_line_tbl(1).change_comments := 'SCHEDULING ORGANIZER';
       /* End Audit Trail */

       L := I + 1;
       IF L <= l_count THEN
        For J in L..l_count Loop  --loop for remained modified lines
         IF p_x_sch_line_tbl(J).header_id = p_x_sch_line_tbl(I).header_id THEN --if any remained lines has same header
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SCH: BINGO! LINE: ' || P_X_SCH_LINE_TBL ( J ) .LINE_ID || ' HAS SAME HEADER_ID', 5 ) ;
END IF;
            p_x_sch_line_tbl(J).exclude := 'Y'; --so that we will not process them when we come to it

            OE_Line_Util.Query_Row
            (   p_line_id                     => p_x_sch_line_tbl(J).line_id
             ,   x_line_rec                    => l_x_line_rec
            );

            l_x_old_line_tbl(K) := l_x_line_rec;

            l_x_line_tbl(K) := l_x_old_line_tbl(K);

            l_x_line_tbl(K).source_type_code  := p_x_sch_line_tbl(J).source_type_code;

            l_x_line_tbl(K).schedule_ship_date := p_x_sch_line_tbl(J).schedule_ship_date;
            IF l_x_line_tbl(K).source_type_code <> 'EXTERNAL' THEN
              l_x_line_tbl(K).schedule_arrival_date := p_x_sch_line_tbl(J).schedule_arrival_date;
              l_x_line_tbl(K).reserved_quantity := p_x_sch_line_tbl(J).reserved_quantity;
              l_x_line_tbl(K).reserved_quantity2 := p_x_sch_line_tbl(J).reserved_quantity2; -- INVCONV 4668439
              l_x_line_tbl(K).subinventory := p_x_sch_line_tbl(J).subinventory;
              IF p_x_sch_line_tbl(J).ship_set_changed = 'Y' THEN
                l_x_line_tbl(K).ship_set := p_x_sch_line_tbl(J).ship_set;
                l_x_line_tbl(K).ship_set_id := null;
              END IF;
              IF p_x_sch_line_tbl(J).arrival_set_changed = 'Y' THEN
                l_x_line_tbl(K).arrival_set := p_x_sch_line_tbl(J).arrival_set;
                l_x_line_tbl(K).arrival_set_id := null;
              END IF;
              l_x_line_tbl(K).planning_priority := p_x_sch_line_tbl(J).planning_priority;
            END IF;

            l_x_line_tbl(K).ship_from_org_id := p_x_sch_line_tbl(J).ship_from_org_id;
            l_x_line_tbl(K).demand_class_code := p_x_sch_line_tbl(J).demand_class_code;
            l_x_line_tbl(K).shipment_priority_code  := p_x_sch_line_tbl(J).shipment_priority_code;



            l_x_line_tbl(K).shipping_method_code  := p_x_sch_line_tbl(J).shipping_method_code;
/*          l_x_line_tbl(K).project_id:= p_x_sch_line_tbl(J).project_id;
            l_x_line_tbl(K).task_id  := p_x_sch_line_tbl(J).task_id;
            l_x_line_tbl(K).end_item_unit_number := p_x_sch_line_tbl(J).end_item_unit_number;
*/

            l_x_line_tbl(K).override_atp_date_code := p_x_sch_line_tbl(J).override_atp_date_code;
            l_x_line_tbl(K).firm_demand_flag := p_x_sch_line_tbl(J).firm_demand_flag;--8370582
            l_x_line_tbl(K).late_demand_penalty_factor := p_x_sch_line_tbl(J).late_demand_penalty_factor;
            l_x_line_tbl(K).latest_acceptable_date := p_x_sch_line_tbl(J).latest_acceptable_date;


            l_x_line_tbl(K).operation := 'UPDATE';

            K := K+1;
         END IF; --same header
        End Loop; --for remained modified lines
       END IF; --L <= l_count

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SCH: GOING TO CALL LINES NOW' ) ;
       END IF;

       K := 2; --reset K

SAVEPOINT PRE_LINES;

       OE_ORDER_PVT.Lines(p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list => l_init_msg,
                     p_control_rec => l_control_rec,
                     p_x_line_tbl => l_x_line_tbl,
                     p_x_old_line_tbl => l_x_old_line_tbl,
                     x_return_status => x_return_status);

       l_init_msg := FND_API.G_FALSE;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'SCH: DONE CALLING LINES: ' || X_RETURN_STATUS ) ;
       END IF;

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
       END IF;

       Oe_Order_Pvt.Process_Requests_And_Notify
    (   p_process_requests           => TRUE
    ,   p_init_msg_list              => FND_API.G_FALSE
    ,   p_notify                     => TRUE
    ,   x_return_status              => x_return_status
    ,   p_line_tbl                   => l_x_line_tbl
    ,   p_old_line_tbl               => l_x_old_line_tbl
    );

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        ROLLBACK TO SAVEPOINT PRE_LINES;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status  = FND_API.G_RET_STS_ERROR THEN
        ROLLBACK TO SAVEPOINT PRE_LINES;
        RAISE FND_API.G_EXC_ERROR;
       END IF;

       l_x_line_tbl.delete;  -- clear out the table for every order
       l_x_old_line_tbl.delete;

    END IF; -- not marked as exclude

   EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           l_failed_count := l_failed_count + l_x_line_tbl.count;
           x_failed_count := l_failed_count;
           l_x_line_tbl.delete;
           l_x_old_line_tbl.delete;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SCH: IN EXCEPTION HANDLER! FAILED COUNT: ' || L_FAILED_COUNT ) ;
END IF;
           x_msg_count := oe_msg_pub.count_msg;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SCH: IN EXCEPTION HANDLER! MSG COUNT: ' || OE_MSG_PUB.COUNT_MSG ) ;
END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           l_failed_count := l_failed_count + l_x_line_tbl.count;
           x_failed_count := l_failed_count;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SCH: IN UNEXP EXCEPTION HANDLER! FAILED COUNT: ' || L_FAILED_COUNT ) ;
END IF;
           l_x_line_tbl.delete;
           l_x_old_line_tbl.delete;

           x_msg_count := oe_msg_pub.count_msg;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SCH: IN UNEXP EXCEPTION HANDLER! MSG COUNT: ' || OE_MSG_PUB.COUNT_MSG ) ;
END IF;

        WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           l_failed_count := l_failed_count + l_x_line_tbl.count;
           x_failed_count := l_failed_count;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SCH: IN OTHER EXCEPTION HANDLER! FAILED COUNT: ' || L_FAILED_COUNT ) ;
END IF;
           l_x_line_tbl.delete;
           l_x_old_line_tbl.delete;

           IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
           THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sch_Window_Key_Commit'
            );
           END IF;

           x_msg_count := oe_msg_pub.count_msg;


   END; -- block
End Loop; -- Main loop
--R12.MOAC--
IF l_access_mode  <> 'S' THEN
   Mo_global.set_policy_context(p_access_mode => l_access_mode , p_org_id  =>'');
END IF;
x_msg_count := oe_msg_pub.count_msg;

END Sch_Window_Key_Commit;


----------------------------------------------------------------------------
PROCEDURE Order_Boundary_Sorting(p_line_list IN VARCHAR2, p_count IN NUMBER,
                                    x_line_list_tbl OUT NOCOPY line_list_tab_typ)
----------------------------------------------------------------------------
IS
I                      NUMBER;
K                      NUMBER := 0;
L                      NUMBER;
M                      NUMBER;
match_count            NUMBER := 1; --at least one id already there
j                      Integer;
init                   Integer;
nextpos                Integer;
l_record_ids           VARCHAR2(32000) := p_line_list;
l_line_id              NUMBER;
l_header_id            NUMBER;
l_header_line_tbl      header_line_tab;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SCH: IN ORDER_BOUNDARY_SORTING' ) ;
  END IF;
  j := 1;
  init := 1;
  nextpos := INSTR(l_record_ids,',',1,j) ;

  FOR I IN 1..p_count LOOP

    l_line_id := to_number(substr(l_record_ids,init, nextpos-init));
    l_header_line_tbl(j).line_id := l_line_id;

    SELECT header_id
    INTO l_header_id
    FROM oe_order_lines_all
    WHERE line_id = l_line_id;

    l_header_line_tbl(j).header_id := l_header_id;
    l_header_line_tbl(j).exclude := 'N';

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SCH: LINE_ID:' || L_LINE_ID || ' HEADER_ID:' || L_HEADER_ID , 5 ) ;
    END IF;

    init := nextpos + 1.0;
    j := j + 1.0;
    nextpos := INSTR(l_record_ids,',',1,j) ;

  END LOOP;

  For I in 1..p_count Loop
   IF l_header_line_tbl(I).exclude <> 'Y' THEN
     K := K+1;
     x_line_list_tbl(K).line_list := l_header_line_tbl(I).line_id || ',';
     x_line_list_tbl(K).count := 1;
     l_header_id := l_header_line_tbl(I).header_id;
     L := I + 1;
     IF L <= p_count THEN
       For M in L..p_count Loop -- here I am not checking if M is excluded or not, as no cost difference
         IF l_header_line_tbl(M).header_id = l_header_id THEN --same order
               match_count := match_count + 1;
               x_line_list_tbl(K).line_list := x_line_list_tbl(K).line_list || l_header_line_tbl(M).line_id || ',';
               x_line_list_tbl(K).count := match_count;
               l_header_line_tbl(M).exclude := 'Y'; --so we wont process it when the main loop comes to it
         END IF;
       End Loop;
       match_count := 1; --reset for next order
      END IF;
   END IF;
  End Loop;

/* for testing purpose only, to verify the list */
/*
  For I in 1..K Loop
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'K: ' || K || ' - ' || X_LINE_LIST_TBL ( I ) .LINE_LIST || ' COUNT: ' || X_LINE_LIST_TBL ( I ) .COUNT ) ;
     END IF;
  End Loop;
*/

END Order_Boundary_Sorting;

-- Pack J
/*-------------------------------------------------------------------------------------
FUNCTION : Submit_Reservation_Request
DESCRIPTION: This api will call reserve order concurrent program along with the
             parameters passed and will return the request id.
--------------------------------------------------------------------------------------*/

FUNCTION Submit_Reservation_Request
(p_selected_line_tbl    IN OE_GLOBALS.selected_record_tbl, -- R12.MOAC
 p_reservation_mode     IN VARCHAR2 DEFAULT NULL,
 p_percent              IN NUMBER DEFAULT NULL,
 p_reserve_run_type     IN VARCHAR2,
 p_reservation_set_Name IN VARCHAR2 DEFAULT NULL,
 p_override_set         IN VARCHAR2 DEFAULT 'N',
 p_order_by             IN VARCHAR2 DEFAULT NULL,
 p_partial_preference   IN VARCHAR2 DEFAULT 'N')
RETURN NUMBER
IS
   l_request_id  NUMBER;
   l_set_id      NUMBER;
   --R12.MOAC
   l_access_mode VARCHAR2(1);
   l_org_id      NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'IN SUBMIT_RESERVATION_REQUEST ' ) ;
  END IF;
   --R12.MOAC Start
   l_access_mode := mo_global.get_access_mode;
   IF l_access_mode = 'S' THEN
      l_org_id := mo_global.get_current_org_id;
   ELSE
      l_org_id := NULL;
   END IF;

   IF p_selected_line_tbl.COUNT > 0 THEN
      SELECT oe_reservation_sets_s.nextval
      INTO l_set_id
      FROM dual;
      --  selected rows are inserted into oe_rsv_set_details table without parent, and then the
      --  concurrent  program will delete these rows after processing.
      FOR I IN 1..p_selected_line_tbl.COUNT LOOP
         INSERT INTO oe_rsv_set_details
         (reservation_set_id
         ,line_id
         ,header_id
         ,creation_date
         ,created_by
         ,last_update_date
         ,last_updated_by
         ,last_update_login
         )
         VALUES
         (-l_set_id
         ,p_selected_line_tbl(I).id1
         ,0
         ,sysdate
         ,FND_GLOBAL.USER_ID
         ,sysdate
         ,FND_GLOBAL.USER_ID
         ,FND_GLOBAL.LOGIN_ID
         );
      END LOOP;

   END IF;
   --R12.MOAC End
   l_request_id :=
         FND_REQUEST.Submit_Request
                ('ONT','OMRSVORD','','',FALSE,
                  l_org_id,               --p_org_id
                  'N',                   --p_use_reservation_time_fence
                  NULL,                   --p_order_number_low
                  NULL,                   --p_order_number_high
                  NULL,                   --p_customer_id
                  NULL,                   --p_order_type
                  NULL,                   --p_line_type_id
                  NULL,                   --p_warehouse
                  NULL,                   --p_inventory_item_id
                  NULL,                   --p_request_date_low
                  NULL,                   --p_request_date_high
                  NULL,                   --p_schedule_ship_date_low
                  NULL,                   --p_schedule_ship_date_high
                  NULL,                   --p_schedule_arrival_date_low
                  NULL,                   --p_schedule_arrival_date_high
                  NULL,                   --p_ordered_date_low
                  NULL,                   --p_ordered_date_high
                  NULL,                   --p_demand_class_code
                  NULL,                   --p_planning_priority
                  NULL,                   --p_booked -- 3359603
                  p_reservation_mode,     --p_reservation_mode
                  NULL,                   --Dummy Parameter
                  NULL,                   --Dummy Parameter
                  p_percent,              --p_percent
                  NULL,                   --p_shipment_priority
                  p_reserve_run_type,     --p_reserve_run_type
                  p_reservation_set_Name, --p_reserve_set_Name
                  p_override_set,         --p_override_set
                  p_order_by,             --p_order_by
                     -l_set_id,        --p_selected_ids -- R12.MOAC
		  NULL,                   --Dummy Parameter
                  p_partial_preference);   --p_partial_preference

    IF (l_request_id > 0) THEN
      COMMIT WORK;
    END IF;
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING SUBMIT_RESERVATION_REQUEST ' ) ;
    END IF;
    return l_request_id;

END Submit_Reservation_Request;

/*-----------------------------------------------------------------
PROCEDURE : Update_Reservation_Qty
DESCRIPTION : Will update the corrected qty of the lines of reservation set
------------------------------------------------------------------*/
PROCEDURE Update_Reservation_Qty
(p_reservation_set  IN  VARCHAR2,
 p_sch_line_tbl  IN OE_SCH_ORGANIZER_UTIL.sch_line_tbl_type)
IS
   CURSOR rsv_set_id IS
   SELECT reservation_set_id
   FROM oe_reservation_sets
   WHERE Reservation_set_name =p_reservation_set;

   l_set_id NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   OPEN rsv_set_id;
   FETCH rsv_set_id INTO l_set_id;
   CLOSE rsv_set_id;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'IN UPDATE_RESERVATION_QTY FOR SET:'||l_set_id ) ;
   END IF;


   FOR I IN 1..p_sch_line_tbl.COUNT
   LOOP
      Update Oe_Rsv_Set_Details
      SET Corrected_Qty = p_sch_line_tbl(I).corrected_qty,
      Corrected_Qty2 = p_sch_line_tbl(I).corrected_qty2, -- INVCONV
      last_update_login = FND_GLOBAL.LOGIN_ID,
      last_updated_by = FND_GLOBAL.USER_ID,
      last_update_date = sysdate
      WHERE Reservation_set_id = l_set_id
      AND Line_Id = p_sch_line_tbl(I).line_id;

   END LOOP;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING UPDATE_RESERVATION_QTY' ) ;
   END IF;

END Update_Reservation_Qty;

/*--------------------------------------------------
FUNCTION : Reservation_Set_Processed
DESCRIPTION: This api will return true if the reservation set is already processed
----------------------------------------------------*/
FUNCTION Reservation_Set_Processed
(p_reservation_set_name  IN VARCHAR2)
RETURN BOOLEAN
IS
   CURSOR set_processed IS
   SELECT process_flag
   FROM oe_reservation_sets
   WHERE reservation_set_name = p_reservation_set_name;

   l_process_flag VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   OPEN set_processed;
   FETCH set_processed INTO l_process_flag;
   CLOSE set_processed;
   IF l_process_flag = 'Y' THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;

END Reservation_Set_Processed;

--R12.MOAC
PROCEDURE Insert_into_tmp_tab(p_line_id IN NUMBER)
IS
BEGIN
   INSERT INTO OE_SCH_ID_LIST_TMP(line_id)
            VALUES(p_line_id);

END Insert_into_tmp_tab;

PROCEDURE Insert_into_tmp_tab(p_line_tbl IN OE_GLOBALS.Selected_Record_Tbl)
IS
BEGIN
   FOR I IN 1..p_line_tbl.COUNT LOOP
      INSERT INTO OE_SCH_ID_LIST_TMP(line_id)
               VALUES(p_line_tbl(I).id1);
   END LOOP;
END Insert_into_tmp_tab;

PROCEDURE delete_tmp_tab
IS
BEGIN
   DELETE FROM OE_SCH_ID_LIST_TMP;
END delete_tmp_tab;
/*--------------------------------------------------
PROCEDURE : Process_Schedule_Action
DESCRIPTION: This api will call oe_group_sch_util.schedule_multi_lines procedure per header_id
----------------------------------------------------*/
PROCEDURE Process_Schedule_Action
(p_selected_line_tbl     IN   OE_GLOBALS.Selected_Record_Tbl,
p_sch_action             IN   VARCHAR2,
x_atp_tbl                OUT NOCOPY oe_atp.atp_tbl_type,
x_return_status          OUT NOCOPY VARCHAR2,
x_msg_count              OUT NOCOPY NUMBER,
x_msg                    OUT NOCOPY VARCHAR2)
IS

  l NUMBER;
  k NUMBER :=2;
  l_org_id NUMBER := -99;
  l_count  NUMBER;
  l_access_mode  VARCHAR2(1);
  p_processed_table OE_GLOBALS.Number_Tbl_Type;
  l_selected_tbl OE_GLOBALS.Selected_Record_Tbl;
  l_atp_tbl            OE_ATP.Atp_Tbl_Type;
  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
  l_error_count        NUMBER := 0;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING Process_Schedule_Action  ' , 1 ) ;
   END IF;
   /*  MOAC Changes */
   --Remember and re-set the access mode, if its Multi.
   l_access_mode := mo_global.get_access_mode();
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_count := p_selected_line_tbl.count;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Lines selected  '||l_count , 1 ) ;
   END IF;
   IF l_count > 1 THEN
      FOR I IN 1..p_selected_line_tbl.count Loop

         /* in the selected table of records,  id1 is line_id and id2 is header_id */

         IF NOT p_processed_table.exists(p_selected_line_tbl(I).id2) THEN
           --p_processed_table(p_selected_line_tbl(I).id2) :='Y';
            p_processed_table(p_selected_line_tbl(I).id2) :=p_selected_line_tbl(I).id2;
            l_selected_tbl(1).id1 := p_selected_line_tbl(I).id1;
            insert_into_tmp_tab(p_selected_line_tbl(I).id1);
            /*  MOAC Changes */
            IF l_access_mode <> 'S' OR -- 4757862
               l_org_id  <>  p_selected_line_tbl(I).org_id THEN
               l_org_id := p_selected_line_tbl(I).org_id;
               Mo_global.set_policy_context(p_access_mode => 'S',
                                         p_org_id  => l_org_id);
            END IF;

            l := I + 1;
            IF l <= l_count THEN
               FOR J IN l..l_count LOOP  --loop for remained modified lines
                  IF p_selected_line_tbl(J).id2 = p_selected_line_tbl (I).id2 THEN
                     l_selected_tbl(K).id1 := p_selected_line_tbl(J).id1;
                     K:= K+1;
                     insert_into_tmp_tab(p_selected_line_tbl(J).id1);
                  END IF;
               END LOOP;
            END IF;

            K := 2; --reset K
            OE_GROUP_SCH_UTIL.Schedule_Multi_lines
                      (p_selected_line_tbl   => l_selected_tbl,
                       p_line_count          => l_selected_tbl.count,
                       p_sch_action          => p_sch_action,
                       x_atp_tbl             => l_atp_tbl,
                       x_return_status       => l_return_status,
                       x_msg_count           => l_msg_count,
                       x_msg_data            => l_msg_data);

           --exception handling--

           l_error_count := l_error_count + l_msg_count;
           -- clearing the table
           l_selected_tbl.DELETE;


           /*  MOAC Changes */
            IF l_access_mode  <> 'S' THEN
               Mo_global.set_policy_context(p_access_mode => l_access_mode
                                     , p_org_id  =>'');
            END IF;
         END IF; /* if header_id in  p_processed_table */

      END LOOP;
   ELSE
      l_selected_tbl(1).id1 := p_selected_line_tbl(1).id1;
      insert_into_tmp_tab(p_selected_line_tbl(1).id1);
      /*  MOAC Changes */
      IF l_access_mode <> 'S' AND
         l_org_id  <>  p_selected_line_tbl(1).org_id THEN
         l_org_id := p_selected_line_tbl(1).org_id;
         Mo_global.set_policy_context(p_access_mode => 'S',
                                         p_org_id  => l_org_id);
      END IF;
      OE_GROUP_SCH_UTIL.Schedule_Multi_lines
                   (p_selected_line_tbl   => l_selected_tbl,
                    p_line_count          => l_selected_tbl.count,
                    p_sch_action          => p_sch_action,
                    x_atp_tbl             => l_atp_tbl,
                    x_return_status       => l_return_status,
                    x_msg_count           => l_msg_count,
                    x_msg_data            => l_msg_data);
      l_error_count := l_error_count + l_msg_count;
      /*  MOAC Changes */
      IF l_access_mode  <> 'S' THEN
         Mo_global.set_policy_context(p_access_mode => l_access_mode
                                     , p_org_id  =>'');
      END IF;
   END IF;
   x_msg_count := l_error_count;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING Process_Schedule_Action  ' , 1 ) ;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         OE_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
       ,   'process_schedule_action');
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Process_Schedule_Action;


END OE_SCH_ORGANIZER_UTIL;

/
