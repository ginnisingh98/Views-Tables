--------------------------------------------------------
--  DDL for Package Body OE_SCH_FIRM_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SCH_FIRM_CONC" AS
/* $Header: OEXCFDPB.pls 120.4 2006/02/07 22:08:13 rmoharan noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_SCH_FIRM_CONC';

Function Firm_Eligible(p_line_id IN NUMBER)
RETURN BOOLEAN
IS
  l_activity_status_code VARCHAR2(8);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

  -- Check for workflow status to be Purchase Release Eligible
  SELECT ACTIVITY_STATUS
  INTO l_activity_status_code
  FROM wf_item_activity_statuses wias, wf_process_activities wpa
  WHERE wias.item_type = 'OEOL' AND
        wias.item_key  = to_char(p_line_id) AND
        wias.process_activity = wpa.instance_id AND
        wpa.activity_name = 'FIRM_ELIGIBLE' AND
        wias.activity_status = 'NOTIFIED';

   -- Return true since the record exists.
     RETURN TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'RETURNING FALSE 1 ' , 1 ) ;
     END IF;
       RETURN FALSE;
  WHEN OTHERS THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Firm_Eligible;

/*-----------------------------------------------------------------
PROCEDURE  : Request
DESCRIPTION: Firm Demand Process  Concurrent Request
-----------------------------------------------------------------*/

Procedure Request
(ERRBUF                     OUT NOCOPY VARCHAR2,
 RETCODE                    OUT NOCOPY VARCHAR2,
 -- Moac
 p_org_id                   IN NUMBER,
 p_order_number_low         IN NUMBER,
 p_order_number_high        IN NUMBER,
 p_customer_id              IN VARCHAR2,
 p_order_type               IN VARCHAR2,
 p_line_type_id             IN VARCHAR2,
 p_warehouse                IN VARCHAR2,
 p_inventory_item_id        IN VARCHAR2,
 p_request_date_low         IN VARCHAR2,
 p_request_date_high        IN VARCHAR2,
 p_schedule_ship_date_low   IN VARCHAR2,
 p_schedule_ship_date_high  IN VARCHAR2,
 p_schedule_arrival_date_low    IN VARCHAR2,
 p_schedule_arrival_date_high   IN VARCHAR2,
 p_ordered_date_low         IN VARCHAR2,
 p_ordered_date_high        IN VARCHAR2,
 p_demand_class_code        IN VARCHAR2,
 p_planning_priority        IN NUMBER,
 p_shipment_priority        IN VARCHAR2,
 p_schedule_status          IN VARCHAR2
)IS

l_msg_count               NUMBER;
l_msg_data                VARCHAR2(2000) := NULL;

-- variable for debugging.
l_file_val                VARCHAR2(80);


-- Moac Changed below cursor to join to oe_order_lines table
CURSOR wf_item IS
    Select item_key, l.org_id
    From   wf_item_activity_statuses wias, wf_process_activities wpa,
    oe_order_lines l
    Where  wias.item_type = 'OEOL'
    And    wias.process_activity = wpa.instance_id
    And    wpa.activity_item_type = 'OEOL'
    And    wpa.activity_name = 'FIRM_ELIGIBLE'
    And    wias.activity_status = 'NOTIFIED'
    And    wias.item_key = l.line_id
    order by l.org_id;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

l_request_date_low           DATE;
l_request_date_high          DATE;
l_schedule_ship_date_low     DATE;
l_schedule_ship_date_high    DATE;
l_schedule_arrival_date_low  DATE;
l_schedule_arrival_date_high DATE;
l_ordered_date_low           DATE;
l_ordered_date_high          DATE;

v_line_id       NUMBER;
l_sql_stmt      VARCHAR2(20900);
l_sqlCursor     INTEGER;
l_dummy         NUMBER;

-- Moac
l_single_org            BOOLEAN := FALSE;
l_old_org_id            NUMBER  := -99;
l_org_id                NUMBER;

BEGIN

  -- When user does not specifiy any parameters, we drive the scheduling
  -- through workflow. Pick up all the lines which are schedule eligible
  -- and notified status, call wf_engine to complete the activity.

  -- If value is passed through any of the parameters, then get the header
  -- and line
  -- records and call wf_engine.

  oe_debug_pub.add('Starting Progress Firm: ' , 1 ) ;

  IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL > '110509' THEN
   IF  p_order_number_low         is null AND
       p_order_number_high        is null AND
       p_customer_id              is null AND
       p_order_type               is null AND
       p_line_type_id             is null AND
       p_warehouse                is null AND
       p_inventory_item_id        is null AND
       p_request_date_low         is null AND
       p_request_date_high        is null AND
       p_schedule_ship_date_low   is null AND
       p_schedule_ship_date_high  is null AND
       p_schedule_arrival_date_low    is null AND
       p_schedule_arrival_date_high   is null AND
       p_ordered_date_low         is null AND
       p_ordered_date_high        is null AND
       p_demand_class_code        is null AND
       p_planning_priority        is null AND
       p_shipment_priority        is null AND
       p_schedule_status          is null THEN

       -- MOAC Start
       IF MO_GLOBAL.get_access_mode = 'S' THEN
          l_single_org := TRUE;
       ELSIF p_org_id IS NOT NULL THEN
	  l_single_org := TRUE;
          MO_GLOBAL.set_policy_context(p_access_mode => 'S', p_org_id  => p_org_id);
       END IF;
       -- MOAC End

       FOR k IN wf_item LOOP

         fnd_file.put_line(FND_FILE.LOG, '***** Processing item key '||
                                                         k.item_key||' *****');

	   -- MOAC Start. Set policy context if the OU changes on lines.
	   IF NOT l_single_org and k.org_id <> l_old_org_id then
              l_old_org_id := k.org_id;
              MO_GLOBAL.set_policy_context(p_access_mode => 'S', p_org_id  => k.org_id);
	   END IF;
	   -- MOAC End.

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'COMPLETING ACTIVITY FOR : ' || K.ITEM_KEY ,1);
         END IF;
         wf_engine.CompleteActivityInternalName
                     ('OEOL',
                      k.item_key,
                      'FIRM_ELIGIBLE',
                      'COMPLETE');

         OE_MSG_PUB.Count_And_Get
            ( p_count     => l_msg_count
            , p_data      => l_msg_data
            );


         FOR I in 1..l_msg_count LOOP
              l_msg_data := OE_MSG_PUB.Get(I,'F');
              -- Write Messages in the log file
              fnd_file.put_line(FND_FILE.LOG, l_msg_data);
              -- Write the message to the database

         END LOOP;


       END LOOP;


   ELSE -- If some value is passed then derive based on the header_cur.


     IF l_debug_level  > 0 THEN
       OE_DEBUG_PUB.Add('Inside the Firm Demand Concurrent Program',1);
     END IF;

     SELECT FND_DATE.Canonical_To_Date(p_request_date_low),
            FND_DATE.Canonical_To_Date(p_request_date_high),
            FND_DATE.Canonical_To_Date(p_schedule_ship_date_low),
            FND_DATE.Canonical_To_Date(p_schedule_ship_date_high),
            FND_DATE.Canonical_To_Date(p_schedule_arrival_date_low),
            FND_DATE.Canonical_To_Date(p_schedule_arrival_date_high),
            FND_DATE.Canonical_To_Date(p_ordered_date_low),
            FND_DATE.Canonical_To_Date(p_ordered_date_high)
     INTO   l_request_date_low,
            l_request_date_high,
            l_schedule_ship_date_low,
            l_schedule_ship_date_high,
            l_schedule_arrival_date_low,
            l_schedule_arrival_date_high,
            l_ordered_date_low,
            l_ordered_date_high
     FROM   DUAL;


     l_sql_stmt := 'SELECT Line_id, l.org_id FROM  OE_ORDER_LINES l, OE_ORDER_HEADERS_ALL h ';

     l_sql_stmt := l_sql_stmt|| ' WHERE  h.header_id    = l.header_id'||
             ' AND     h.open_flag    = '||'''Y'''||
             ' AND     NVL(l.cancelled_flag,'||'''N'''||') <> '||'''Y'''||
             ' AND     NVL(l.line_category_code,'||'''ORDER'''||') <> '||'''RETURN''' ;

     IF nvl(p_schedule_status,'ALL') = 'SCHEDULED' THEN

       l_sql_stmt := l_sql_stmt || ' AND l.schedule_status_code  is not null';

     ELSIF  nvl(p_schedule_status,'ALL') = 'UNSCHEDULED' THEN

       l_sql_stmt := l_sql_stmt || ' AND l.schedule_status_code  is null ' ;

     END IF;

     -- Moac Start
     IF p_org_id is not null THEN
      l_sql_stmt := l_sql_stmt || ' AND h.org_id = :bindvar_org_id ';
     END IF;
     -- Moac End

     IF p_order_number_low is not null THEN
      l_sql_stmt := l_sql_stmt || ' AND h.ORDER_NUMBER >= :p1 ';
     END IF;
     IF  p_order_number_high        is not null THEN
      l_sql_stmt := l_sql_stmt || ' AND h.ORDER_NUMBER <= :p2 ';
     END IF;
     IF  p_customer_id              is not null THEN
      l_sql_stmt := l_sql_stmt || ' AND h.sold_to_org_id = :p3 ';
     END IF;
     IF  p_order_type               is not null THEN
      l_sql_stmt := l_sql_stmt || ' AND h.order_type_id = :p4 ';
     END IF;
     IF   p_line_type_id             is not null THEN
      l_sql_stmt := l_sql_stmt || ' AND l.line_type_id = :p5 ';
     END IF;
     IF   p_warehouse                is not null THEN
      l_sql_stmt := l_sql_stmt || ' AND l.ship_from_org_id = :p6 ';
     END IF;
     IF   p_inventory_item_id        is not null THEN
      l_sql_stmt := l_sql_stmt || ' AND l.inventory_item_id = :p7 ';
     END IF;
     IF   p_request_date_low         is not null THEN
      l_sql_stmt := l_sql_stmt || ' AND l.request_date >= :p8 ';
     END IF;
     IF   p_request_date_high        is not null THEN
      l_sql_stmt := l_sql_stmt || ' AND l.request_date <= :p9 ';
     END IF;
     IF   p_schedule_ship_date_low   is not null THEN
      l_sql_stmt := l_sql_stmt || ' AND l.schedule_ship_date >= :p10 ';
     END IF;
     IF   p_schedule_ship_date_high  is not null THEN
      l_sql_stmt := l_sql_stmt || ' AND l.schedule_ship_date <= :p11 ';
     END IF;
     IF   p_schedule_arrival_date_low    is not null THEN
      l_sql_stmt := l_sql_stmt || ' AND l.schedule_arrival_date >= :p12 ';
     END IF;
     IF   p_schedule_arrival_date_high   is not null THEN
      l_sql_stmt := l_sql_stmt || ' AND l.schedule_arrival_date <= :p13 ';
     END IF;
     IF   p_ordered_date_low         is not null THEN
      l_sql_stmt := l_sql_stmt || ' AND h.ordered_date >= :p14 ';
     END IF;
     IF   p_ordered_date_high        is not null THEN
      l_sql_stmt := l_sql_stmt || ' AND h.ordered_date <= :p15 ';
     END IF;
     IF   p_demand_class_code        is not null THEN
      l_sql_stmt := l_sql_stmt || ' AND l.demand_class_code = :p16 ';
     END IF;
     IF   p_planning_priority        is not null THEN
      l_sql_stmt := l_sql_stmt || ' AND l.planning_priority = :p17 ';
     END IF;
     IF   p_shipment_priority        is not null THEN
      l_sql_stmt := l_sql_stmt || ' AND l.shipment_priority_code = :p18 ';
     END IF;

     -- Moac Start
     IF NOT l_single_org THEN
        l_sql_stmt := l_sql_stmt|| ' Order By h.org_id ';
     End IF;
     -- Moac End

     oe_debug_pub.add (l_sql_stmt,1);
     l_sqlCursor := DBMS_SQL.Open_Cursor;

     DBMS_SQL.PARSE(l_sqlCursor, l_sql_stmt, DBMS_SQL.NATIVE);

     -- Moac Start
     IF p_org_id IS NOT NULL THEN
        DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':bindvar_org_id',p_org_id);
     END IF;
     -- Moac End

     IF p_order_number_low IS NOT NULL THEN
        DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p1',p_order_number_low);
     END IF;
     IF  p_order_number_high        is not null THEN
        DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p2',p_order_number_high);
     END IF;
     IF  p_customer_id              is not null THEN
        DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p3',p_customer_id);
     END IF;
     IF  p_order_type               is not null THEN
        DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p4',p_order_type);
     END IF;
     IF   p_line_type_id             is not null THEN
        DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p5',p_line_type_id);
     END IF;
     IF   p_warehouse                is not null THEN
        DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p6',p_warehouse);
     END IF;
     IF   p_inventory_item_id        is not null THEN
        DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p7',p_inventory_item_id);
     END IF;
     IF   p_request_date_low         is not  null THEN
        DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p8',l_request_date_low);
     END IF;
     IF   p_request_date_high        is not null THEN
        DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p9',l_request_date_high);
     END IF;
     IF   p_schedule_ship_date_low   is not null THEN
        DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p10',l_schedule_ship_date_low);
     END IF;
     IF   p_schedule_ship_date_high  is not null THEN
        DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p11',l_schedule_ship_date_high);
     END IF;
     IF   p_schedule_arrival_date_low    is  not null THEN
        DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p12',l_schedule_arrival_date_low);
     END IF;
     IF   p_schedule_arrival_date_high   is not null THEN
        DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p13',l_schedule_arrival_date_high);
     END IF;
     IF   p_ordered_date_low         is not null THEN
        DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p14',l_ordered_date_low);
     END IF;
     IF   p_ordered_date_high        is not null THEN
        DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p15',l_ordered_date_high);
     END IF;
     IF   p_demand_class_code        is not null THEN
        DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p16',p_demand_class_code);
     END IF;
     IF   p_planning_priority        is not null THEN
        DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p17',p_planning_priority);
     END IF;
     IF   p_shipment_priority        is not null THEN
        DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p18',p_shipment_priority);
     END IF;

     DBMS_SQL.DEFINE_COLUMN (l_sqlCursor,1,v_line_id);
     DBMS_SQL.DEFINE_COLUMN (l_sqlCursor,2,l_org_id);

     l_dummy := DBMS_SQL.execute(l_sqlCursor);

     LOOP

      IF DBMS_SQL.FETCH_ROWS(l_sqlCursor) = 0 THEN
         EXIT;
      END IF;

      DBMS_SQL.COLUMN_VALUE(l_sqlCursor,1,v_line_id);
      DBMS_SQL.COLUMN_VALUE(l_sqlCursor,2,l_org_id);

      IF Firm_Eligible(p_line_id => v_line_id) THEN

          fnd_file.put_line(FND_FILE.LOG, '***** Processing Line id '||
                                                v_line_id||' *****');

          -- Moac Start
          IF NOT l_single_org and l_org_id <> l_old_org_id THEN
             l_old_org_id := l_org_id;
             MO_GLOBAL.set_policy_context(p_access_mode => 'S', p_org_id  => l_org_id);
          END IF;
          -- Moac End

          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'COMPLETING ACTIVITY FOR : ' || v_line_id ,1);
          END IF;

          wf_engine.CompleteActivityInternalName
                    ('OEOL',
                     to_char(v_line_id),
                     'FIRM_ELIGIBLE',
                     'COMPLETE');

           OE_MSG_PUB.Count_And_Get
               ( p_count     => l_msg_count
               , p_data      => l_msg_data
                );

           FOR I in 1..l_msg_count loop
              l_msg_data := OE_MSG_PUB.Get(I,'F');
               -- Write Messages in the log file
               FND_FILE.PUT_LINE(FND_FILE.LOG, l_msg_data);
               -- Write the message to the database
           END LOOP;
      END IF;

     END LOOP;

     DBMS_SQL.CLOSE_CURSOR(l_sqlCursor);

   END IF; -- Main

  END IF;
EXCEPTION

  WHEN OTHERS THEN

    oe_debug_pub.add('Error executing Scheduling ' || SQLERRM,1);
    fnd_file.put_line(FND_FILE.LOG,
            'Error executing Scheduling, ' || SQLERRM);
END Request;

END OE_SCH_FIRM_CONC;

/
