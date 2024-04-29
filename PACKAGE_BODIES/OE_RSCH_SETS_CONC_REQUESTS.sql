--------------------------------------------------------
--  DDL for Package Body OE_RSCH_SETS_CONC_REQUESTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_RSCH_SETS_CONC_REQUESTS" AS
/* $Header: OEXCRSHB.pls 120.4 2005/12/15 17:36:42 akurella noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_RSCH_SETS_CONC_REQUESTS';

Procedure Schedule_set_of_lines
( x_old_line_tbl OUT NOCOPY OE_ORDER_PUB.line_tbl_type,

                p_x_line_tbl     IN  OUT NOCOPY OE_ORDER_PUB.line_tbl_type,
x_return_status OUT NOCOPY VARCHAR2)

IS
l_atp_tbl             OE_ATP.ATP_Tbl_Type;
l_line_tbl            OE_ORDER_PUB.line_tbl_type;
l_ii_line_tbl         OE_ORDER_PUB.line_tbl_type;
l_return_status       VARCHAR2(1);
K                     NUMBER := 0;
J                     NUMBER := 0;
l_sales_order_id      NUMBER;
l_entity_type         VARCHAR2(30);
l_set_rec             OE_ORDER_CACHE.set_rec_type;  -- 2887734
l_ship_set_id         NUMBER :=0;
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


   FOR I IN 1..p_x_line_tbl.count LOOP
   BEGIN
       IF p_x_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_INCLUDED THEN

           -- Service items cannot be scheduled, so we will skip them.
           -- Included items will be picked up by their parent, so we will
           -- skip them.
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'LINE IS A SERVICE OR INCLUDED ITEM' , 1 ) ;
           END IF;

       ELSE
          K := K + 1;
          l_line_tbl(K)     := p_x_line_tbl(I);
          l_line_tbl(K).schedule_action_code :=
                            OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE;
          l_line_tbl(K).schedule_ship_date := l_line_tbl(K).request_date;
          l_line_tbl(K).schedule_arrival_date := Null;
          l_line_tbl(K).operation := 'UPDATE';

          x_old_line_tbl(K) := p_x_line_tbl(I);

          IF (p_x_line_tbl(I).ato_line_id is null) AND
             (p_x_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_MODEL OR
              p_x_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_CLASS OR
              p_x_line_tbl(I).item_type_code = OE_GLOBALS.G_ITEM_KIT) THEN

            -- Calling Process_Included_Items. This procedure
            -- will take care of exploding and updating the picture
            -- of included_items in the oe_order_lines table.

            l_return_status := OE_CONFIG_UTIL.Process_Included_Items
                                 (p_line_rec  => p_x_line_tbl(I),
                                  p_freeze    => FALSE,
                                  p_process_requests => TRUE);

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

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'MERGING INCLUDED ITEM TABLE WITH LINE TABLE' , 1 ) ;
            END IF;

            -- Merge the Included Item table to the line table
            FOR J IN 1..l_ii_line_tbl.count LOOP
                K := K+1;
                l_line_tbl(k)           := l_ii_line_tbl(J);
                x_old_line_tbl(K)       := l_ii_line_tbl(J);
                l_line_tbl(k).operation := OE_GLOBALS.G_OPR_UPDATE;
                l_line_tbl(k).ship_set_id :=
                                      p_x_line_tbl(I).ship_set_id;
                l_line_tbl(k).arrival_set_id :=
                                      p_x_line_tbl(I).arrival_set_id;
                l_line_tbl(k).schedule_ship_date := l_line_tbl(k).request_date;
                l_line_tbl(k).schedule_arrival_date :=Null;
                l_line_tbl(k).operation :='UPDATE';
                l_line_tbl(k).schedule_action_code :=
                                    OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE;
            END LOOP;
          END IF;
       END IF;

   EXCEPTION

        WHEN OTHERS THEN

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;
   END LOOP;

                     IF l_debug_level  > 0 THEN
                         oe_debug_pub.add(  'CALLING PROCESS_SET_OF_LINES WITH : ' || L_LINE_TBL.COUNT , 1 ) ;
                     END IF;

   FOR I IN 1..l_line_tbl.count LOOP

     IF I = 1 THEN

        l_sales_order_id := OE_SCHEDULE_UTIL.Get_mtl_sales_order_id
                                           (l_line_tbl(1).HEADER_ID);
     END IF;
   -- If any of the lines are previously scheduled, then pass
   -- action as reschedule to MRP.



     IF l_line_tbl(I).schedule_status_code is not null THEN
     	-- INVCONV - MERGED CALLS	 FOR OE_LINE_UTIL.Get_Reserved_Quantity and OE_LINE_UTIL.Get_Reserved_Quantity2

     	OE_LINE_UTIL.Get_Reserved_Quantities(   p_header_id => l_sales_order_id
                                              ,p_line_id   => l_line_tbl(I).line_id
                                              ,p_org_id    => l_line_tbl(I).ship_from_org_id
                                              ,x_reserved_quantity =>  l_line_tbl(I).reserved_quantity
                                              ,x_reserved_quantity2 => l_line_tbl(I).reserved_quantity2
																							);
        x_old_line_tbl(I).reserved_quantity := l_line_tbl(I).reserved_quantity;
        x_old_line_tbl(I).reserved_quantity2 := l_line_tbl(I).reserved_quantity2;

     /*   l_line_tbl(I).reserved_quantity :=
              OE_LINE_UTIL.Get_Reserved_Quantity
                 (p_header_id   => l_sales_order_id,
                  p_line_id     => l_line_tbl(I).line_id,
                  p_org_id      => l_line_tbl(I).ship_from_org_id);
        x_old_line_tbl(I).reserved_quantity := l_line_tbl(I).reserved_quantity;

        l_line_tbl(I).reserved_quantity2 := -- INVCONV
              OE_LINE_UTIL.Get_Reserved_Quantity2
                 (p_header_id   => l_sales_order_id,
                  p_line_id     => l_line_tbl(I).line_id,
                  p_org_id      => l_line_tbl(I).ship_from_org_id);
       x_old_line_tbl(I).reserved_quantity2 := l_line_tbl(I).reserved_quantity2; */

     END IF;

     IF  l_line_tbl(I).reserved_quantity = FND_API.G_MISS_NUM
     OR  l_line_tbl(I).reserved_quantity IS NULL THEN
         l_line_tbl(I).reserved_quantity := 0;
     END IF;
     IF  x_old_line_tbl(I).reserved_quantity = FND_API.G_MISS_NUM
     OR  x_old_line_tbl(I).reserved_quantity IS NULL THEN
         x_old_line_tbl(I).reserved_quantity := 0;
     END IF;

     IF  l_line_tbl(I).reserved_quantity2 = FND_API.G_MISS_NUM -- INVCONV
     OR  l_line_tbl(I).reserved_quantity2 IS NULL THEN
         l_line_tbl(I).reserved_quantity2 := 0;
     END IF;
     IF  x_old_line_tbl(I).reserved_quantity2 = FND_API.G_MISS_NUM -- INVCONV
     OR  x_old_line_tbl(I).reserved_quantity2 IS NULL THEN
         x_old_line_tbl(I).reserved_quantity2 := 0;
     END IF;





     --- 2887734
     --  get set name
     IF l_line_tbl(I).ship_set_id IS NOT NULL THEN
        IF NOT OE_GLOBALS.Equal(l_line_tbl(I).ship_set_id,
                                    l_ship_set_id) THEN
           l_ship_set_id := l_line_tbl(I).ship_set_id;
           l_set_rec := OE_ORDER_CACHE.Load_Set(l_ship_set_id);
        END IF;
        l_line_tbl(I).ship_set := l_set_rec.set_name;
     END IF;
     --- 2887734
   END LOOP;

   IF l_line_tbl.count > 0 THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CALLING PROCESS_GROUP' || L_LINE_TBL ( 1 ) .SHIP_SET_ID , 1 ) ;
        END IF;

         Oe_Config_Schedule_Pvt.Process_Group
              (p_x_line_tbl     => l_line_tbl
              ,p_old_line_tbl   => x_old_line_tbl
              ,p_caller         => 'UI_ACTION'
              ,p_sch_action     => OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE
              ,x_return_status  => x_return_status);

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'AFTER CALLING PROCESS_GROUP' || X_RETURN_STATUS , 1 ) ;
         END IF;
   END IF;

   p_x_line_tbl := l_line_tbl;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING SCHEDULE_SET_OF_LINES' , 1 ) ;
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
            ,   'Schedule_set_of_lines'
            );
        END IF;

END Schedule_set_of_lines;

/* Reschedule Set: This concurrent program is to Reschedule the Ship Sets */
PROCEDURE Reschedule_Ship_Set(
ERRBUF OUT NOCOPY VARCHAR2

,RETCODE OUT NOCOPY VARCHAR2

	,p_order_number_low 	 IN  NUMBER
	,p_order_number_high     IN  NUMBER
	,p_start_from_no_of_days IN  NUMBER
	,p_end_from_no_of_days   IN  NUMBER
	,p_set_id 		 IN  NUMBER)
IS
   l_set_name varchar2(240);
   /* MOAC_SQL_CHANGE */
   CURSOR Line_Set(l_start_date DATE,l_end_date DATE) IS
	SELECT distinct l.ship_set_id, h.order_number
	FROM  oe_order_headers h
	     ,oe_order_lines_all l
		, oe_sets s
	WHERE h.order_number	   >= nvl(p_order_number_low,h.order_number)
	  AND h.order_number       <= nvl(p_order_number_high,h.order_number)
	  AND h.header_id	    = l.header_id
          AND h.org_id              = l.org_id
	  AND h.open_flag           = 'Y'
	  AND trunc(l.Schedule_ship_date)  BETWEEN trunc(l_start_date) and trunc(l_end_date)
	  AND l.open_flag           = 'Y'
	  AND l.ship_set_id         IS NOT NULL
	  AND l.ship_set_id = s.set_id
	  AND h.header_id = s.header_id
	  AND s.set_name = nvl(l_set_name,s.set_name)
	  AND l.shipped_quantity    IS NULL
	  AND l.fulfilled_quantity  IS NULL
	ORDER BY l.ship_set_id ;

    CURSOR Lock_Lines_in_set(l_ship_set_id NUMBER) IS
       SELECT l.line_id
	 FROM oe_order_lines l
	WHERE l.ship_set_id = l_ship_set_id
	  FOR UPDATE;

   CURSOR Get_Set_Name IS
		Select Set_Name from
			oe_sets where
			set_id = p_set_id;


   l_start_date         DATE;
   l_end_date           DATE;
   l_set_line_tbl       OE_Order_PUB.Line_Tbl_Type;
   l_return_status      VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
   l_line_rec           OE_Order_PUB.Line_Rec_Type;
   l_old_line_tbl       OE_ORDER_PUB.Line_Tbl_Type;
   l_control_rec        OE_GLOBALS.control_rec_type;
   g_set_recursive_flag BOOLEAN := FALSE;
   l_msg_count number;
   l_msg_data varchar2(32000);


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   --Initialze retcode #4220950
   ERRBUF  := '';
   RETCODE := 0;

   l_start_date  := SYSDATE + NVL(p_start_from_no_of_days,0);
   l_end_date    := SYSDATE + NVL(p_end_from_no_of_days,0);


   fnd_file.put_line(FND_FILE.LOG, 'Parameters:');

   fnd_file.put_line(FND_FILE.LOG, '    order_number_low =  '||
                                        p_order_number_low);
   fnd_file.put_line(FND_FILE.LOG, '    order_number_high = '||
                                        p_order_number_high);
   fnd_file.put_line(FND_FILE.LOG, '    Start From Number of Days = '||
                                        p_start_from_no_of_days);
   fnd_file.put_line(FND_FILE.LOG, '    End From Number of Days = '||
                                        p_end_from_no_of_days);
   fnd_file.put_line(FND_FILE.LOG, '    Ship Set Number = '||
                                        p_set_id);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'INSIDE THE RESCHEDULING SHIP SETS CONCURRENT PROGRAM' ) ;
   END IF;
		IF p_set_id is not null then
		OPEN Get_Set_Name;
		FETCH Get_Set_Name
		 into l_set_name;
		CLOSE Get_Set_Name;
		END IF;
   fnd_file.put_line(FND_FILE.LOG, '    Ship Set Name = '||
                                        l_set_name);


   FOR Get_Line_set IN Line_Set(l_start_date,l_end_date)
   LOOP

      SAVEPOINT Process_lines_in_set;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ORDER NUMBER:'||GET_LINE_SET.ORDER_NUMBER ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'SHIP SET ID:'||GET_LINE_SET.SHIP_SET_ID ) ;
      END IF;

   -- With the above cursor we have got the list of all the Ship Sets
   -- for the orders.
   -- Now for every Ship Set perform the ReScheduling.

   -- We need to query all the lines that are a part of the Ship Set.
	OE_SET_UTIL.Query_set_Rows
		 ( p_set_id       => Get_Line_set.ship_set_id
	      ,x_line_tbl     => l_set_line_tbl );

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER THE LINES ARE QUERIED' ) ;
      END IF;

   -- We need to set the Action on each line as OESCH_ACT_RESCHEDULE
   -- The Scheduled Dates and the Arrival Date have to be set to NULl
   -- so that the lines get rescheduled.
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'AFTER SETTING THE SCHEDULE STATUS CODE' ) ;
      END IF;

     -- Code should change for re-structuring purpose. If it a old code
     -- follow old path or else follow new path.

     --ELSE -- Re-structure path.
        OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'N';
        OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'N';
        OPEN Lock_Lines_in_set(Get_Line_set.ship_set_id);
     	CLOSE Lock_Lines_in_set;

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'NEW CODE' , 1 ) ;
         END IF;
         Schedule_Set_Of_lines
         ( p_x_line_tbl    => l_set_line_tbl
          ,x_old_line_tbl  => l_old_line_tbl
          ,x_return_status => l_return_status );

         OE_MSG_PUB.Count_And_Get
         ( p_count     => l_msg_count
         , p_data      => l_msg_data);

         FOR T in 1..l_msg_count loop
           l_msg_data := OE_MSG_PUB.Get(T,'F');

           -- Write Messages in the log file

           FND_FILE.PUT_LINE(FND_FILE.LOG, l_msg_data);

           -- Write the message to the database

         END LOOP;

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'INSIDE THE UNEXPECTED ERROR FOR THE FOLLOWING DATA:' ) ;
                oe_debug_pub.add(  'ORDER NUMBER:'||GET_LINE_SET.ORDER_NUMBER ||' AND '||
                'SHIP SET:'||GET_LINE_SET.SHIP_SET_ID||' HAS FAILED RESCHEDULING' ) ;
                 oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 2000 ) ) ;
             END IF;
             ROLLBACK TO SAVEPOINT Process_lines_in_set;

         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'INSIDE THE EXPECTED ERROR FOR THE FOLLOWING DATA :' ) ;
                oe_debug_pub.add(  'ORDER NUMBER:'||GET_LINE_SET.ORDER_NUMBER ||' AND '||
                 'SHIP SET:'||GET_LINE_SET.SHIP_SET_ID||' HAS FAILED RESCHEDULING' ) ;
            END IF;
            ROLLBACK TO SAVEPOINT Process_lines_in_set;

         ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

           OE_SCHEDULE_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';
           OE_ORDER_SCH_UTIL.OESCH_PERFORM_SCHEDULING := 'Y';

          IF l_set_line_tbl.count > 0 AND
         ( l_set_line_tbl(1).Schedule_Ship_Date <>
           l_old_line_tbl(1).Schedule_Ship_Date) THEN

	      OE_Set_Util.Update_Set
          (p_Set_Id                   => l_set_line_tbl(1).ship_set_id,
           p_Ship_From_Org_Id         => l_set_line_tbl(1).Ship_From_Org_Id,
           p_Ship_To_Org_Id           => l_set_line_tbl(1).Ship_To_Org_Id,
           p_Schedule_Ship_Date       => l_set_line_tbl(1).Schedule_Ship_Date,
           p_Schedule_Arrival_Date    => l_set_line_tbl(1).Schedule_Arrival_Date,
           p_Freight_Carrier_Code     => l_set_line_tbl(1).Freight_Carrier_Code,
           p_Shipping_Method_Code     => l_set_line_tbl(1).Shipping_Method_Code,
           p_shipment_priority_code   => l_set_line_tbl(1).shipment_priority_code,
           X_Return_Status            => l_return_status,
           x_msg_count                => l_msg_count,
           x_msg_data                 => l_msg_data
          );
          END IF;

         -- Now we will commit the entire Set together
         COMMIT;


       END IF; -- Return status
  END LOOP; -- Main Loop(Get_Line_set)


EXCEPTION
   WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INSIDE THE WHEN OTHERS EXECPTION' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 2000 ) ) ;
      END IF;

END Reschedule_Ship_Set;


END OE_RSCH_SETS_CONC_REQUESTS;

/
