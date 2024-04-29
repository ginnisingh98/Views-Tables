--------------------------------------------------------
--  DDL for Package Body OE_SCH_CONC_REQUESTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SCH_CONC_REQUESTS" AS
/* $Header: OEXCSCHB.pls 120.20.12010000.7 2009/12/09 08:06:50 nshah ship $ */

--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_SCH_CONC_REQUESTS';
--5166476
/*
TYPE status_arr IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
OE_line_status_Tbl status_arr;
*/

FUNCTION model_processed(p_model_id  IN NUMBER
                         ,p_line_id  IN NUMBER)
RETURN BOOLEAN
IS
   l_found    BOOLEAN:= FALSE;
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

   /* If many of the lines selected are part of a smc/ato/non-smc model, then delayed
    * request must get logged only for one of the lines.
    */
   IF oe_model_id_tbl.EXISTS(p_model_id) THEN
      l_found := TRUE;
   ELSIF p_model_id = p_line_id THEN
      oe_model_id_tbl(p_model_id) := p_model_id;
   END IF;
   RETURN (l_found);
END model_processed;

FUNCTION included_processed(p_inc_item_id  IN NUMBER)
RETURN BOOLEAN
IS
   l_found    BOOLEAN:= FALSE;
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

   /* to list the included items processed alone
    */
   IF l_debug_level  > 0 THEN
      OE_DEBUG_PUB.Add('INSIDE INCLUDED_PROCESSED',1);
   END IF;

   IF oe_included_id_tbl.EXISTS(p_inc_item_id) THEN
      l_found := TRUE;
   ELSE
      oe_included_id_tbl(p_inc_item_id) := p_inc_item_id;
   END IF;
   IF l_found THEN
      IF l_debug_level  > 0 THEN
        OE_DEBUG_PUB.Add('INCLIDED ITEM LISTED',1);
      END IF;
   ELSE
      IF l_debug_level  > 0 THEN
        OE_DEBUG_PUB.Add('INCLIDED ITEM NOT LISTED',1);
      END IF;
   END IF;
   RETURN (l_found);
END included_processed;

FUNCTION set_processed(p_set_id  IN NUMBER)
RETURN BOOLEAN
IS
   l_found    BOOLEAN:= FALSE;
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

   /* If many of the lines selected are part of a ship set / Arrival set, then delayed
    * request must get logged only for one of the lines.
    */
   IF oe_set_id_tbl.EXISTS(p_set_id) THEN
      l_found := TRUE;
   ELSE
      oe_set_id_tbl(p_set_id) := p_set_id;
   END IF;
   RETURN (l_found);
END set_processed;

FUNCTION Line_Eligible (p_line_id IN NUMBER)
   RETURN BOOLEAN
IS
   l_activity_status_code VARCHAR2(8);
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

   -- Check for workflow status to be Purchase Release Eligible
   SELECT ACTIVITY_STATUS
      INTO l_activity_status_code
      FROM wf_item_activity_statuses wias, wf_process_activities wpa
      WHERE wias.item_type = 'OEOL' AND
      wias.item_key  = to_char(p_line_id) AND
      wias.process_activity = wpa.instance_id AND
      wpa.activity_item_type = 'OEOL' AND
      wpa.activity_name = 'SCHEDULING_ELIGIBLE' AND
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
END Line_Eligible;

/*-----------------------------------------------------------------
PROCEDURE  : Request
DESCRIPTION: Schedule Orders Concurrent Request

Change log:
Bug 8813015: Parameter p_picked is added to allow exclusion of
             pick released lines.
-----------------------------------------------------------------*/
PROCEDURE Request (ERRBUF                   OUT NOCOPY VARCHAR2,
                   RETCODE                  OUT NOCOPY VARCHAR2,
                   /* Moac */
		   p_org_id                 IN NUMBER,
                   p_order_number_low       IN NUMBER,
                   p_order_number_high      IN NUMBER,
                   p_request_date_low       IN VARCHAR2,
                   p_request_date_high      IN VARCHAR2,
                   p_customer_po_number     IN VARCHAR2,
                   p_ship_to_location       IN VARCHAR2,
                   p_order_type             IN VARCHAR2,
                   p_customer               IN VARCHAR2,
                   p_ordered_date_low       IN VARCHAR2,
                   p_ordered_date_high      IN VARCHAR2,
                   p_warehouse              IN VARCHAR2,
                   p_item                   IN VARCHAR2,
                   p_demand_class           IN VARCHAR2,
                   p_planning_priority      IN VARCHAR2,
                   p_shipment_priority      IN VARCHAR2,
                   p_line_type              IN VARCHAR2,
                   p_line_request_date_low  IN VARCHAR2,
                   p_line_request_date_high IN VARCHAR2,
                   p_line_ship_to_location  IN VARCHAR2,
                   p_sch_ship_date_low      IN VARCHAR2,
                   p_sch_ship_date_high     IN VARCHAR2,
                   p_sch_arrival_date_low   IN VARCHAR2,
                   p_sch_arrival_date_high  IN VARCHAR2,
                   p_booked                 IN VARCHAR2,
                   p_sch_mode               IN VARCHAR2,
                   p_dummy1                 IN VARCHAR2,
                   p_dummy2                 IN VARCHAR2,
                   p_apply_warehouse        IN VARCHAR2,
                   p_apply_sch_date         IN VARCHAR2,
                   p_order_by_first         IN VARCHAR2,
                   p_order_by_sec           IN VARCHAR2,
                   p_picked                 IN VARCHAR2 DEFAULT NULL --Bug 8813015
                   )
IS
   l_apply_sch_date          DATE;
   l_arrival_set_id          NUMBER;
   l_ato_line_id             NUMBER;
   l_atp_tbl                 OE_ATP.Atp_Tbl_Type;
   l_booked_flag             VARCHAR2(1);
   l_control_rec             OE_GLOBALS.Control_Rec_Type;
   l_cursor_id               INTEGER;
   l_debug_level CONSTANT    NUMBER := oe_debug_pub.g_debug_level;
   l_found                   BOOLEAN;
   l_header_id               NUMBER;
   l_init_msg_list           VARCHAR2(1) := FND_API.G_FALSE;
   l_item_type_code          VARCHAR2(30);
   l_line_id                 NUMBER;
   l_line_rec                OE_ORDER_PUB.Line_Rec_Type;
   l_line_request_date_high  DATE;
   l_line_request_date_low   DATE;
   l_line_tbl                OE_ORDER_PUB.Line_Tbl_Type;
   l_msg_count               NUMBER;
   l_msg_data                VARCHAR2(2000) := NULL;
   l_old_line_tbl            OE_ORDER_PUB.Line_Tbl_Type;
   l_order_date_type_code    VARCHAR2(30);
   l_ordered_date_high       DATE;
   l_ordered_date_low        DATE;
   l_process_order           BOOLEAN := FALSE;
   l_rec_failure             NUMBER := 0;
   l_rec_processed           NUMBER := 0;
   l_rec_success             NUMBER := 0;
   l_request_date            DATE;
   l_request_date_high       DATE;
   l_request_date_low        DATE;
   l_request_id              VARCHAR2(50);
   l_return_status           VARCHAR2(1);
   l_retval                  INTEGER;
   l_sch_arrival_date_high   DATE;
   l_sch_arrival_date_low    DATE;
   l_sch_ship_date_high      DATE;
   l_sch_ship_date_low       DATE;
   l_schedule_status_code    VARCHAR2(30);
   l_ship_from_org_id        NUMBER;
   l_ship_set_id             NUMBER;
   l_smc_flag                VARCHAR2(1);
   l_stmt                    VARCHAR2(2000);
   l_temp_flag               BOOLEAN; -- temp variable (re-usable).
   l_temp_line_id            NUMBER;
   l_temp_num                NUMBER; -- temp variable (re-usable).
   l_top_model_line_id       NUMBER;
   l_link_to_line_id         NUMBER;
   l_locked_line_id          NUMBER; --8731703
   -- Moac
   l_single_org              BOOLEAN := FALSE;
   l_old_org_id              NUMBER  := -99;
   l_org_id                  NUMBER;
   l_selected_line_tbl       OE_GLOBALS.Selected_Record_Tbl; -- R12.MOAC
   l_failure                 BOOLEAN := FALSE;
   l_index                   NUMBER;
   -- Moac. Changed the below cursor logic to also join to oe_order_lines for OU.
   CURSOR wf_item IS
      SELECT item_key, l.org_id
      FROM wf_item_activity_statuses wias,
           wf_process_activities wpa,
	   oe_order_lines l
      WHERE wias.item_type = 'OEOL'
      AND wias.process_activity = wpa.instance_id
      AND wpa.activity_item_type = 'OEOL'
      AND wpa.activity_name = 'SCHEDULING_ELIGIBLE'
      AND wias.activity_status = 'NOTIFIED'
      AND wias.item_key = l.line_id
      Order by l.org_id;

   CURSOR progress_pto IS
     SELECT line_id
     FROM   oe_order_lines_all
     WHERE  header_id = l_header_id
     AND    top_model_line_id = l_line_id
     AND    item_type_code in ('MODEL','KIT','CLASS','OPTION')
     AND    ((ato_line_id is not null AND
              ato_line_id = line_id) OR
              ato_line_id is null)
     AND    open_flag = 'Y';

BEGIN
   --Bug#4220950
   ERRBUF  := 'Schedule Orders Request completed successfully';
   RETCODE := 0;

   -- Moac Start
   IF MO_GLOBAL.get_access_mode = 'S' THEN
	l_single_org := true;
   ELSIF p_org_id IS NOT NULL THEN
	l_single_org := true;
	MO_GLOBAL.set_policy_context(p_access_mode => 'S', p_org_id => p_org_id);
   END IF;
   -- Moac End.

   -- Turning debug on for testing purpose.
   fnd_file.put_line(FND_FILE.LOG, 'Parameters:');
   fnd_file.put_line(FND_FILE.LOG, '    order_number_low =  '||
                     p_order_number_low);
   fnd_file.put_line(FND_FILE.LOG, '    order_number_high = '||
                     p_order_number_high);
   fnd_file.put_line(FND_FILE.LOG, '    request_date_low = '||
                     p_request_date_low);
   fnd_file.put_line(FND_FILE.LOG, '    request_date_high = '||
                     p_request_date_high);
   fnd_file.put_line(FND_FILE.LOG, '    customer_po_number = '||
                     p_customer_po_number);
   fnd_file.put_line(FND_FILE.LOG, '    ship_to_location = '||
                     p_ship_to_location);
   fnd_file.put_line(FND_FILE.LOG, '    order_type = '||
                     p_order_type);
   fnd_file.put_line(FND_FILE.LOG, '    customer = '||
                     p_customer);
   fnd_file.put_line(FND_FILE.LOG, '    item = '||
                     p_item);
   fnd_file.put_line(FND_FILE.LOG, '    ordered_date_low = ' ||
                     p_ordered_date_low);
   fnd_file.put_line(FND_FILE.LOG, '    ordered_date_high = ' ||
                     p_ordered_date_high);
   fnd_file.put_line(FND_FILE.LOG, '    warehouse = ' ||
                     p_warehouse);
   fnd_file.put_line(FND_FILE.LOG, '    demand_class = ' ||
                     p_demand_class);
   fnd_file.put_line(FND_FILE.LOG, '    planning_priority = ' ||
                     p_planning_priority);
   fnd_file.put_line(FND_FILE.LOG, '    shipment_priority = ' ||
                     p_shipment_priority);
   fnd_file.put_line(FND_FILE.LOG, '    line_type = ' ||
                     p_line_type);
   fnd_file.put_line(FND_FILE.LOG, '    line_request_date_low = ' ||
                     p_line_request_date_low);
   fnd_file.put_line(FND_FILE.LOG, '    line_request_date_high = ' ||
                     p_line_request_date_high);
   fnd_file.put_line(FND_FILE.LOG, '    line_ship_to_location = ' ||
                     p_line_ship_to_location);
   fnd_file.put_line(FND_FILE.LOG, '    sch_ship_date_low = ' ||
                     p_sch_ship_date_low);
   fnd_file.put_line(FND_FILE.LOG, '    sch_ship_date_high = ' ||
                     p_sch_ship_date_high);
   fnd_file.put_line(FND_FILE.LOG, '    sch_arrival_date_low = ' ||
                     p_sch_arrival_date_low);
   fnd_file.put_line(FND_FILE.LOG, '    sch_arrival_date_high = ' ||
                     p_sch_arrival_date_high);
   fnd_file.put_line(FND_FILE.LOG, '    booked = ' ||
                     p_booked);
   fnd_file.put_line(FND_FILE.LOG, '    sch_mode = ' ||
                     p_sch_mode);
   fnd_file.put_line(FND_FILE.LOG, '    dummy1 = ' ||
                     p_dummy1);
   fnd_file.put_line(FND_FILE.LOG, '    apply_warehouse = ' ||
                     p_apply_warehouse);
   fnd_file.put_line(FND_FILE.LOG, '    apply_sch_date = ' ||
                     p_apply_sch_date);
   fnd_file.put_line(FND_FILE.LOG, '    order_by_first = ' ||
                     p_order_by_first);
   fnd_file.put_line(FND_FILE.LOG, '    order_by_sec = ' ||
                     p_order_by_sec);
   --Bug 8813015: start
   fnd_file.put_line(FND_FILE.LOG, '    picked = ' ||
                     p_picked);
   --Bug 8813015: end

   FND_PROFILE.Get(NAME => 'CONC_REQUEST_ID',
                   VAL  => l_request_id);
   OE_MSG_PUB.Initialize; -- Initializing message pub to clear messages.

   IF p_sch_mode NOT IN ('SCHEDULE','RESCHEDULE') AND
      (p_apply_sch_date IS NOT NULL OR
       p_apply_warehouse IS NOT NULL)
   THEN
      Fnd_Message.set_name('ONT', 'ONT_SCH_INVALID_MODE_ATTRB');
      Oe_Msg_Pub.Add;
      OE_MSG_PUB.Save_Messages(p_request_id => l_request_id);
      l_msg_data := Fnd_Message.get_string('ONT',
                                           'ONT_SCH_INVALID_MODE_ATTRB');
      FND_FILE.Put_Line(FND_FILE.LOG, l_msg_data);
      ERRBUF := 'ONT_SCH_INVALID_MODE_ATTRB';
      IF l_debug_level  > 0 THEN
        OE_DEBUG_PUB.Add('Error : Schedule date supplied for wrong mode.',1);
      END IF;
      RETCODE := 2;
      RETURN;
   END IF;

   -- Convert dates passed as varchar2 parameters to date variables.
   SELECT fnd_date.canonical_to_date(p_request_date_low),
          fnd_date.canonical_to_date(p_request_date_high),
          fnd_date.canonical_to_date(p_ordered_date_low),
          fnd_date.canonical_to_date(p_ordered_date_high),
          fnd_date.canonical_to_date(p_line_request_date_low),
          fnd_date.canonical_to_date(p_line_request_date_high),
          fnd_date.canonical_to_date(p_sch_ship_date_low),
          fnd_date.canonical_to_date(p_sch_ship_date_high),
          fnd_date.canonical_to_date(p_sch_arrival_date_low),
          fnd_date.canonical_to_date(p_sch_arrival_date_high)
        --  fnd_date.canonical_to_date(p_apply_sch_date)
      INTO l_request_date_low,
           l_request_date_high,
           l_ordered_date_low,
           l_ordered_date_high,
           l_line_request_date_low,
           l_line_request_date_high,
           l_sch_ship_date_low,
           l_sch_ship_date_high,
           l_sch_arrival_date_low,
           l_sch_arrival_date_high
         --  l_apply_sch_date
      FROM DUAL;

      SELECT fnd_date.chardt_to_date(p_apply_sch_date)
        INTO l_apply_sch_date
        FROM dual;

      IF l_debug_level  > 0 THEN
         OE_DEBUG_PUB.Add('Schedule date'||l_apply_sch_date,1);
      END IF;
   /* When user does not specifiy any parameters, we drive the scheduling
    * through workflow. Pick up all the lines which are schedule eligible
    * and notified status, call wf_engine to complete the activity.
    * If value is passed through any of the parameters, then get the header and
    * line records and call wf_engine.
    */
   IF p_order_number_low       IS NULL AND
      p_order_number_high      IS NULL AND
      p_request_date_low       IS NULL AND
      p_request_date_high      IS NULL AND
      p_customer_po_number     IS NULL AND
      p_ship_to_location       IS NULL AND
      p_order_type             IS NULL AND
      p_customer               IS NULL AND
      p_item                   IS NULL AND
      p_ordered_date_low       IS NULL AND
      p_ordered_date_high      IS NULL AND
      p_warehouse              IS NULL AND
      p_demand_class           IS NULL AND
      p_planning_priority      IS NULL AND
      p_shipment_priority      IS NULL AND
      p_line_type              IS NULL AND
      p_line_request_date_low  IS NULL AND
      p_line_request_date_high IS NULL AND
      p_line_ship_to_location  IS NULL AND
      p_sch_ship_date_low      IS NULL AND
      p_sch_ship_date_high     IS NULL AND
      p_sch_arrival_date_low   IS NULL AND
      p_sch_arrival_date_high  IS NULL AND
      p_sch_mode               IS NULL AND
      nvl(p_booked, 'Y')       =  'Y'  AND
      Nvl(p_picked,'Y')        =  'Y' --Bug 8813015
   THEN
      FOR k IN wf_item LOOP
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('***** 1. Processing item key '||
                             k.item_key ||' *****', 1);
         END IF;

         -- Moac Start
	 IF NOT l_single_org and k.org_id <> l_old_org_id THEN
	    l_old_org_id := k.org_id;
	    MO_GLOBAL.set_policy_context(p_access_mode => 'S', p_org_id => k.org_id);
	 END IF;
         -- Moac End

         -- Need to check whether still line is eligible for processing
         IF Line_Eligible(p_line_id => to_number(K.ITEM_KEY)) THEN
            --8448911
            g_conc_program := 'Y';
            g_recorded := 'N';

            IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'COMPLETING ACTIVITY FOR : ' || K.ITEM_KEY , 1 ) ;
            END IF;



            g_process_records := 0;
            g_failed_records  := 0;
            -- 8606874
            --Lock the line first
            BEGIN
               SELECT line_id
               INTO   l_locked_line_id
               FROM   oe_order_lines_all
               WHERE  line_id = to_number(K.ITEM_KEY)
               FOR UPDATE NOWAIT;

               wf_engine.CompleteActivityInternalName
               ('OEOL',
                k.item_key,
                'SCHEDULING_ELIGIBLE',
                'COMPLETE');
            EXCEPTION
               WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add('OEXCSCHB.pls: unable to lock the line:'||K.ITEM_KEY,1);
                  END IF;
               WHEN OTHERS THEN
                        IF l_debug_level  > 0 THEN
                           oe_debug_pub.add('*** 1. Error - '||SUBSTR(SQLERRM,1,200),1);
                        END IF;
            END;
           /* --8448911
            OE_MSG_PUB.Count_And_Get
               ( p_count     => l_msg_count,
                 p_data      => l_msg_data);

            FOR I in 1..l_msg_count LOOP
               l_msg_data := OE_MSG_PUB.Get(I,'F');

               -- Write Messages in the log file
               fnd_file.put_line(FND_FILE.LOG, l_msg_data);

            END LOOP;
	    */
            --5166476

            --IF g_failed_records > 0 THEN
              IF OE_SCH_CONC_REQUESTS.oe_line_status_tbl.EXISTS(k.item_key) AND
                 OE_SCH_CONC_REQUESTS.oe_line_status_tbl(k.item_key)= 'N' THEN
               l_failure := TRUE;
            END IF;
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'R1 PROCESSED: '||l_rec_processed||' FAILED: '||l_rec_failure , 1 ) ;
            END IF;

	 -- Moac
	 END IF;

      END LOOP;
   ELSE -- Some parameter is passed

      -- Open cursor.
      l_cursor_id := DBMS_SQL.OPEN_CURSOR;

      -- Building the dynamic query based on parameters passed.
      -- Moac Changed below cursor to use oe_order_headers_all
      /*Start  MOAC_SQL_CHANGE */
      l_stmt := 'SELECT H.header_id, L.Line_id, L.org_id ';
      IF NVL(p_sch_mode, 'LINE_ELIGIBLE') = 'LINE_ELIGIBLE' THEN
         l_stmt := l_stmt || 'FROM oe_order_headers_all H, oe_order_lines L, '
            || ' wf_item_activity_statuses wias, wf_process_activities wpa ';
      ELSE
         l_stmt := l_stmt || 'FROM oe_order_headers_all H, oe_order_lines L ';
      END IF;
      l_stmt := l_stmt || 'WHERE H.header_id = L.header_id '
         || 'AND H.org_id = L.org_id '
         || 'AND nvl(H.transaction_phase_code,''F'')=''F''' -- Bug 8517633
         || 'AND H.open_flag = ''Y'''||' AND L.open_flag = ''Y'''
         --9098824: Start
         ||' AND L.line_category_code <> '||'''RETURN'''
         ||' AND L.item_type_code <> '||'''SERVICE'''
         ||' AND L.source_type_code <> '||'''EXTERNAL'''
         --9098824: End
         ;
      /*End  MOAC_SQL_CHANGE */

      -- Building where clause.
      -- Moac Start
      IF p_org_id is NOT NULL THEN
         l_stmt := l_stmt || ' AND L.org_id = :org_id';
      END IF;
      -- Moac End

      IF p_order_number_low IS NOT NULL THEN
         l_stmt := l_stmt || ' AND H.order_number >= :order_number_low';
      END IF;
      IF p_order_number_high IS NOT NULL THEN
         l_stmt := l_stmt || ' AND H.order_number <= :order_number_high';
      END IF;
      IF p_request_date_low IS NOT NULL THEN
         l_stmt := l_stmt || ' AND H.request_date >= :request_date_low';
      END IF;
      IF p_request_date_high IS NOT NULL THEN
         l_stmt := l_stmt || ' AND H.request_date <= :request_date_high';
      END IF;
      IF p_customer_po_number IS NOT NULL THEN
         l_stmt := l_stmt || ' AND H.cust_po_number = :customer_po_number';
      END IF;
      IF p_ship_to_location IS NOT NULL THEN
         l_stmt := l_stmt || ' AND H.ship_to_org_id = :ship_to_location';
      END IF;
      IF p_order_type IS NOT NULL THEN
         l_stmt := l_stmt || ' AND H.order_type_id = :order_type';
      END IF;
      IF p_customer IS NOT NULL THEN
         l_stmt := l_stmt || ' AND H.sold_to_org_id = :customer';
      END IF;
      IF p_item IS NOT NULL THEN
         l_stmt := l_stmt || ' AND L.inventory_item_id = :item';
      END IF;
      IF p_ordered_date_low IS NOT NULL THEN
         l_stmt := l_stmt || ' AND H.ordered_date >= :ordered_date_low';
      END IF;
      IF p_ordered_date_high IS NOT NULL THEN
         l_stmt := l_stmt || ' AND H.ordered_date <= :ordered_date_high';
      END IF;
      IF p_warehouse IS NOT NULL THEN
         l_stmt := l_stmt || ' AND L.ship_from_org_id = :warehouse';
      END IF;
      IF p_demand_class IS NOT NULL THEN
         l_stmt := l_stmt || ' AND L.demand_class_code = :demand_class';
      END IF;
      IF p_planning_priority IS NOT NULL THEN
         l_stmt := l_stmt || ' AND L.planning_priority = :planning_priority';
      END IF;
      IF p_shipment_priority IS NOT NULL THEN
         l_stmt := l_stmt || ' AND L.shipment_priority_code = :shipment_priority';
      END IF;
      IF p_line_type IS NOT NULL THEN
         l_stmt := l_stmt || ' AND L.line_type_id = :line_type';
      END IF;
      IF p_line_request_date_low IS NOT NULL THEN
         l_stmt := l_stmt || ' AND L.request_date >= :line_request_date_low';
      END IF;
      IF p_line_request_date_high IS NOT NULL THEN
         l_stmt := l_stmt || ' AND L.request_date <= :line_request_date_high';
      END IF;
      IF p_line_ship_to_location IS NOT NULL THEN
         l_stmt := l_stmt || ' AND L.ship_to_org_id = :line_ship_to_location';
      END IF;
      IF p_sch_ship_date_low IS NOT NULL THEN
         l_stmt := l_stmt || ' AND L.schedule_ship_date >= :sch_ship_date_low';
      END IF;
      IF p_sch_ship_date_high IS NOT NULL THEN
         l_stmt := l_stmt || ' AND L.schedule_ship_date <= :sch_ship_date_high';
      END IF;
      IF p_sch_arrival_date_low IS NOT NULL THEN
         l_stmt := l_stmt || ' AND L.schedule_arrival_date >= :sch_arrival_date_low';
      END IF;
      IF p_sch_arrival_date_high IS NOT NULL THEN
         l_stmt := l_stmt || ' AND L.schedule_arrival_date <= :sch_arrival_date_high';
      END IF;
      IF p_booked IS NOT NULL THEN
         l_stmt := l_stmt || ' AND L.booked_flag = :booked';
      END IF;
      --Bug 8813015: start
      IF Nvl(p_picked,'Y') = 'N' THEN
        l_stmt := l_stmt || ' AND not exists (select 1 from wsh_delivery_details wdd';
        l_stmt := l_stmt || '                 where wdd.source_code = ''OE''';
        l_stmt := l_stmt || '                 and wdd.source_line_id = l.line_id';
        l_stmt := l_stmt || '                 and wdd.released_status in ';
        l_stmt := l_stmt || ' (''S'',''C'',''Y'')) ';
      END IF;
      --Bug 8813015: end

      IF p_sch_mode = 'SCHEDULE' THEN
         l_stmt := l_stmt || ' AND L.schedule_status_code IS NULL';
      ELSIF p_sch_mode IN ('UNSCHEDULE','RESCHEDULE','RESCHEDULE_RD') THEN
         l_stmt := l_stmt || ' AND L.schedule_status_code IS NOT NULL';
      ELSIF NVL(p_sch_mode, 'LINE_ELIGIBLE') = 'LINE_ELIGIBLE' THEN
         l_stmt := l_stmt || ' AND wias.item_type = ''OEOL'''
            || ' AND wias.process_activity = wpa.instance_id'
            || ' AND wpa.activity_item_type = ''OEOL'''
            || ' AND wpa.activity_name = ''SCHEDULING_ELIGIBLE'''
            || ' AND wias.activity_status = ''NOTIFIED'''
            || ' AND wias.item_key = to_char(L.line_id)';
      END IF;

      -- Building order by clause.
      IF p_order_by_first IS NOT NULL THEN
         l_stmt := l_stmt ||' ORDER BY L.'||p_order_by_first;
         IF p_order_by_sec IS NOT NULL THEN
            l_stmt := l_stmt ||', L.'||p_order_by_sec;
         END IF;
      ELSIF p_order_by_sec IS NOT NULL THEN
         l_stmt := l_stmt ||' ORDER BY L.'||p_order_by_sec;


      END IF;
      -- Moac start
      IF NOT l_single_org then
        IF p_order_by_first IS NOT NULL OR
          p_order_by_sec IS NOT NULL THEN
            l_stmt := l_stmt || ', L.org_id' ;
        ELSE
            l_stmt := l_stmt ||' ORDER BY L.org_id';
        END IF;
      END IF;
      -- Moac End.
      IF NOT l_single_org OR
         (p_order_by_first IS NOT NULL OR
          p_order_by_sec IS NOT NULL) then
         l_stmt := l_stmt || ', L.top_model_line_id,l.line_id' ; --5166476
      ELSE
         l_stmt := l_stmt ||' ORDER BY L.top_model_line_id,l.line_id' ;
      END IF;

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Query : ' || l_stmt, 1 ) ;
      END IF;

      -- Parse statement.
      DBMS_SQL.Parse(l_cursor_id,l_stmt,DBMS_SQL.NATIVE);

      -- Bind variables
      -- Moac Start
      IF p_org_id is NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':org_id', p_org_id);
      END IF;
      -- Moac End

      IF p_order_number_low IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':order_number_low',
                                p_order_number_low);
      END IF;
      IF p_order_number_high IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':order_number_high',
                                p_order_number_high);
      END IF;
      IF p_request_date_low IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':request_date_low',
                                l_request_date_low);
      END IF;
      IF p_request_date_high IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':request_date_high',
                                l_request_date_high);
      END IF;
      IF p_customer_po_number IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':customer_po_number',
                                p_customer_po_number);
      END IF;
      IF p_ship_to_location IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':ship_to_location',
                                p_ship_to_location);
      END IF;
      IF p_order_type IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':order_type', p_order_type);
      END IF;
      IF p_customer IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':customer', p_customer);
      END IF;
      IF p_item IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':item', p_item);
      END IF;
      IF p_ordered_date_low IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':ordered_date_low',
                                l_ordered_date_low);
      END IF;
      IF p_ordered_date_high IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':ordered_date_high',
                                l_ordered_date_high);
      END IF;
      IF p_warehouse IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':warehouse', p_warehouse);
      END IF;
      IF p_demand_class IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':demand_class', p_demand_class);
      END IF;
      IF p_planning_priority IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':planning_priority',
                                p_planning_priority);
      END IF;
      IF p_shipment_priority IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':shipment_priority',
                                p_shipment_priority);
      END IF;
      IF p_line_type IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':line_type', p_line_type);
      END IF;
      IF p_line_request_date_low IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':line_request_date_low',
                                l_line_request_date_low);
      END IF;
      IF p_line_request_date_high IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':line_request_date_high',
                                l_line_request_date_high);
      END IF;
      IF p_line_ship_to_location IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':line_ship_to_location',
                                p_line_ship_to_location);
      END IF;
      IF p_sch_ship_date_low IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':sch_ship_date_low',
                                l_sch_ship_date_low);
      END IF;
      IF p_sch_ship_date_high IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':sch_ship_date_high',
                                l_sch_ship_date_high);
      END IF;
      IF p_sch_arrival_date_low IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':sch_arrival_date_low',
                                l_sch_arrival_date_low);
      END IF;
      IF p_sch_arrival_date_high IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':sch_arrival_date_high',
                                l_sch_arrival_date_high);
      END IF;
      IF p_booked IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':booked', p_booked);
      END IF;
      --Bug 8813015: start
      --This code is to be un-commented while providing option for
      --picked lines in scheduling concurrent request UI.
      /*
      IF p_picked IS NOT NULL THEN
         DBMS_SQL.Bind_Variable(l_cursor_id, ':picked', p_picked);
      END IF;
      */
      --Bug 8813015: end

      -- Map output columns
      DBMS_SQL.Define_Column(l_cursor_id, 1, l_header_id);
      DBMS_SQL.Define_Column(l_cursor_id, 2, l_line_id);
      DBMS_SQL.Define_Column(l_cursor_id, 3, l_org_id);       -- Moac

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Before executing query.',1);
      END IF;

      -- Execute query.
      l_retval := DBMS_SQL.Execute(l_cursor_id);

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Execution Result : ' || l_retval, 2) ;
      END IF;

      -- Process each row retrieved.
      LOOP

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Execution Result : ' || l_retval, 2) ;
         END IF;

         IF DBMS_SQL.Fetch_Rows(l_cursor_id) = 0 THEN
            EXIT;
         END IF;

         DBMS_SQL.Column_Value(l_cursor_id, 1, l_header_id);
         DBMS_SQL.Column_Value(l_cursor_id, 2, l_line_id);
         DBMS_SQL.Column_Value(l_cursor_id, 3, l_org_id);      -- Moac


         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('***** 1. Processing Line Id '||
                           l_line_id ||' *****', 1);
         END IF;
         --4777400: Context set is Moved up to set before call to get_date_type
         -- Moac Start
	 IF NOT l_single_org and l_org_id <> l_old_org_id THEN
            l_old_org_id := l_org_id;
            MO_GLOBAL.set_policy_context(p_access_mode => 'S', p_org_id => l_org_id);
         END IF;
         -- Moac End.
         l_order_date_type_code := NVL
            (OE_SCHEDULE_UTIL.Get_Date_Type(l_header_id),'SHIP');
         l_temp_line_id := 0;

         BEGIN

            SELECT L.line_id,
                   L.booked_flag,
                   L.request_date,
                   L.ship_from_org_id,
                   L.ship_set_id,
                   L.arrival_set_id,
                   L.ato_line_id,
                   L.top_model_line_id,
                   L.link_to_line_id,
                   L.ship_model_complete_flag,
                   L.item_type_code,
                   L.schedule_status_code
            INTO   l_temp_line_id,
                   l_booked_flag,
                   l_request_date,
                   l_ship_from_org_id,
                   l_ship_set_id,
                   l_arrival_set_id,
                   l_ato_line_id,
                   l_top_model_line_id,
                   l_link_to_line_id,
                   l_smc_flag,
                   l_item_type_code,
                   l_schedule_status_code
            FROM   oe_order_lines_all L
            WHERE  L.open_flag = 'Y'
            AND    L.line_id = l_line_id;


         EXCEPTION
            WHEN no_data_found THEN
               NULL;
         END;


         IF l_temp_line_id <> 0 THEN

            g_conc_program := 'Y';
            g_recorded := 'N'; -- 5166476

            IF nvl(p_sch_mode, 'LINE_ELIGIBLE') = 'LINE_ELIGIBLE' THEN
               --5166476
               IF Line_Eligible(p_line_id => l_line_id) THEN

                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(to_char(l_line_id) || ' - Line Eligible', 1);
                  END IF;

                  --l_found := FALSE;

               --IF NOT l_found THEN
                  g_process_records := 0;
                  g_failed_records  := 0;
                  -- 8731703
                  -- Lock the record before processing
                  BEGIN
                     SELECT line_id
                     INTO   l_locked_line_id
                     FROM   oe_order_lines_all
                     WHERE  line_id = l_line_id
                     FOR UPDATE NOWAIT;
                     wf_engine.CompleteActivityInternalName ('OEOL',
                                                          to_char(l_line_id),
                                                          'SCHEDULING_ELIGIBLE',
                                                          'COMPLETE');
                  /*
                  OE_MSG_PUB.Count_And_Get (p_count     => l_msg_count,
                                            p_data      => l_msg_data);

                  FOR I in 1..l_msg_count LOOP
                     l_msg_data := OE_MSG_PUB.Get(I,'F');

                     -- Write Messages in the log file
                     FND_FILE.PUT_LINE(FND_FILE.LOG, l_msg_data);

                  END LOOP;
		  */
                  EXCEPTION
                     WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
                        IF l_debug_level  > 0 THEN
                          oe_debug_pub.add('OEXWSCHB.pls: unable to lock the line:'||l_line_id,1);
                        END IF;
                     WHEN OTHERS THEN
                        IF l_debug_level  > 0 THEN
                           oe_debug_pub.add('*** 1. Error -  '||SUBSTR(SQLERRM,1,200),1);
                        END IF;
                  END;

                  --5166476

                  --IF g_failed_records > 0 THEN
                  IF OE_SCH_CONC_REQUESTS.oe_line_status_tbl.EXISTS(l_line_id) AND
                     OE_SCH_CONC_REQUESTS.oe_line_status_tbl(l_line_id) ='N' THEN
                     l_failure := TRUE;
                  END IF;
                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'R2 PROCESSED: '||l_rec_processed||' FAILED: '||l_rec_failure, 1 ) ;
                  END IF;

               --END IF;
               END IF;
            ELSIF p_sch_mode = 'SCHEDULE'  AND
               l_schedule_status_code IS NULL THEN

               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(to_char(l_line_id) || ' - Schedule', 1);
               END IF;
               l_found := FALSE;

               IF l_smc_flag = 'Y' AND
                  l_top_model_line_id IS NOT NULL THEN
                  l_found := model_processed(l_top_model_line_id,l_top_model_line_id);
                  --5166476
                  IF l_found AND
                    oe_line_status_tbl.EXISTS(l_top_model_line_id) THEN
                    IF OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(l_top_model_line_id) = 'N' THEN
                     --5166476
                        OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(l_line_id) := 'N';
                     ELSE
                        OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(l_line_id) := 'Y';
                     END IF;
                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'R3.1 PROCESSED: '||l_line_id, 1 ) ;
                     END IF;
                  END IF;
               ELSIF l_ato_line_id IS NOT NULL THEN
                  --l_top_model_line_id = l_ato_line_id THEN --5166476
                  l_found := model_processed(l_ato_line_id,l_ato_line_id);
                  --5166476
                  IF l_found AND
                     oe_line_status_tbl.EXISTS(l_ato_line_id) THEN
                     IF OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(l_ato_line_id) ='N'  THEN
                         OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(l_line_id) := 'N';
                     ELSE
                        OE_SCH_CONC_REQUESTS.OE_line_status_Tbl(l_line_id) := 'Y';
                     END IF;
                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'R3.2 PROCESSED: '||l_line_id, 1 ) ;
                     END IF;
                  END IF;
                  IF NOT l_found AND
                    l_top_model_line_id IS NOT NULL AND
                    l_top_model_line_id <> l_ato_line_id AND
                    (p_apply_warehouse IS NULL AND
                     p_apply_sch_date IS NULL)THEN
                    l_found := model_processed(l_top_model_line_id,l_line_id);
                  END IF;

               ELSIF l_top_model_line_id IS NOT NULL THEN
                  IF (p_apply_warehouse IS NOT NULL OR
                     p_apply_sch_date IS NOT NULL) AND
                     l_item_type_code NOT IN (OE_GLOBALS.G_ITEM_INCLUDED) THEN
                     l_found := model_processed(l_line_id,l_line_id);
                     IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'R3.4 PROCESSED '||l_line_id,1);
                     END IF;
                  --5166476
                  ELSIF l_top_model_line_id <> l_link_to_line_id AND
                     l_item_type_code = (OE_GLOBALS.G_ITEM_INCLUDED) AND
                     (p_apply_warehouse IS NOT NULL OR
                     p_apply_sch_date IS NOT NULL) THEN
                     l_found := model_processed(l_link_to_line_id,l_line_id);
                     IF l_found AND
                        oe_line_status_tbl.EXISTS(l_link_to_line_id) AND
                        oe_line_status_tbl(l_link_to_line_id) ='N' THEN
                        oe_line_status_tbl(l_line_id) := 'N';
                     END IF;
                  ELSE

                     l_found := model_processed(l_top_model_line_id,l_line_id);
                     --5166476
                     IF l_found AND
                        oe_line_status_tbl.EXISTS(l_top_model_line_id) AND
                        oe_line_status_tbl(l_top_model_line_id) ='N' THEN
                        oe_line_status_tbl(l_line_id) := 'N';
                        IF l_debug_level  > 0 THEN
                           oe_debug_pub.add(  'R3.5 PROCESSED: '||l_line_id, 1 ) ;
                        END IF;
                     END IF;

                   END IF;
               END IF;

               IF NOT l_found THEN
                  IF p_apply_warehouse IS NOT NULL OR
                     p_apply_sch_date IS NOT NULL
                  THEN

                     -- Define a save point
                     SAVEPOINT Schedule_Line;

                     IF l_rec_processed > 1 THEN
                        -- Initially this will be set to FND_API.G_TRUE
                        l_init_msg_list := FND_API.G_FALSE;
                     END IF;

                     oe_line_util.lock_row
                        (x_return_status   => l_return_status
                        ,p_x_line_rec      => l_line_rec
                        ,p_line_id         => l_line_id);

                     --l_line_tbl := OE_ORDER_PUB.G_MISS_LINE_TBL;
                     --l_old_line_tbl := OE_ORDER_PUB.G_MISS_LINE_TBL;
                     --l_line_tbl(1) := OE_ORDER_PUB.G_MISS_LINE_REC;
                     --l_line_tbl(1).line_id := l_line_id;
                     --l_line_tbl(1).header_id := l_header_id;
                     l_line_tbl(1) := l_line_rec;
                     l_old_line_tbl(1) := l_line_rec;

                     l_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;

                     IF p_apply_warehouse IS NOT NULL THEN
                        l_line_tbl(1).ship_from_org_id := p_apply_warehouse;
                     END IF;

                     IF p_apply_sch_date IS NOT NULL THEN
                        IF l_order_date_type_code = 'SHIP' THEN
                           l_line_tbl(1).schedule_ship_date := l_apply_sch_date;
                        ELSE
                           l_line_tbl(1).schedule_arrival_date := l_apply_sch_date;
                        END IF;
                     ELSE
                        IF l_order_date_type_code = 'SHIP' THEN
                           l_line_tbl(1).schedule_ship_date := l_request_date;
                        ELSE
                           l_line_tbl(1).schedule_arrival_date := l_request_date;
                        END IF;

                     END IF;
                     --4892724
                     l_line_tbl(1).change_reason := 'SYSTEM';
                     l_line_tbl(1).change_comments := 'SCHEDULE ORDERS CONCURRENT PROGRAM';


                     -- Call to process order
                     l_control_rec.controlled_operation := TRUE;
                     l_control_rec.write_to_db := TRUE;
                     l_control_rec.PROCESS := FALSE;
                     l_control_rec.default_attributes := TRUE;
                     l_control_rec.change_attributes := TRUE;
                     l_process_order := TRUE;
                     l_control_rec.check_security    := TRUE;-- 5168540

                     g_process_records := 0;
                     g_failed_records  := 0;

                     Oe_Order_Pvt.Lines
                       (p_init_msg_list     => l_init_msg_list,
                        p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                        p_control_rec       => l_control_rec,
                        p_x_line_tbl        => l_line_tbl,
                        p_x_old_line_tbl    => l_old_line_tbl,
                        x_return_status     => l_return_status);

                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add('Oe_Order_Pvt.Lines returns with - '
                                                                    || l_return_status);
                     END IF;

                     IF l_return_status IN (FND_API.G_RET_STS_ERROR,
                                            FND_API.G_RET_STS_UNEXP_ERROR) THEN
                        IF l_debug_level  > 0 THEN
                           oe_debug_pub.add('#### FAILURE #### LINE_ID - '
                                         || to_char(l_line_id) || ' ####');
                        END IF;
                        --5166476
                        IF g_recorded = 'N' THEN
                           --5166476
                           OE_SCH_CONC_REQUESTS.oe_line_status_tbl(l_line_id) :='N';
                           g_recorded := 'Y';
                        END IF;
                        --5166476
                        --IF l_smc_flag = 'Y' AND
                        IF l_top_model_line_id IS NOT NULL AND
                           l_smc_flag = 'Y'  AND
                           l_ato_line_id IS NULL THEN
                           OE_line_status_Tbl(l_top_model_line_id) := 'N';
                        ELSIF l_ato_line_id IS NOT NULL THEN
                           OE_line_status_Tbl(l_ato_line_id) := 'N';
                        END IF;


                        l_failure := TRUE;

                        ROLLBACK TO SAVEPOINT Schedule_Line;

                     END IF;

                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'R3 PROCESSED: '||l_line_id,1);
                     END IF;

                  ELSE -- No scheduling attributes are provided

                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add('No scheduling attributes. Booked flag - '
                                      || l_booked_flag);
                     END IF;

                     g_process_records := 0;
                     g_failed_records  := 0;

                     --R12.MOAC
                     l_selected_line_tbl(1).id1 := l_line_id;

                     OE_GROUP_SCH_UTIL.Schedule_Multi_lines
                          (p_selected_line_tbl     => l_selected_line_tbl, --R12.MOAC
                           p_line_count    => 1,
                           p_sch_action    => 'SCHEDULE',
                           x_atp_tbl       => l_atp_tbl,
                           x_return_status => l_return_status,
                           x_msg_count     => l_msg_count,
                           x_msg_data      => l_msg_data);

                     --ELSE
                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add('Return Status  After Schedule_Multi_lines '||l_return_status,1);
                     END IF;

                     IF NVL(l_booked_flag,'N') ='Y'
                      AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN

                       IF l_debug_level  > 0 THEN
                        oe_debug_pub.add('It is a Booked Order' );
                       END IF;
                       -- Added PTO Logic as part of bug 5186581
                       IF l_top_model_line_id is not null
                       AND l_top_model_line_id = l_line_id
                       AND l_ato_line_id is null
                       AND l_smc_flag = 'N'  THEN

                       IF l_debug_level  > 0 THEN

                        oe_debug_pub.add('It is a PTO Model' );
                       END IF;

                         -- Workflow wont progress all child lines for the Non SMC PTO model scenario. We have to progress all the
                         -- child lines if the to Model is NON SMC

                         FOR M IN progress_pto  LOOP


                           IF l_debug_level  > 0 THEN
                              oe_debug_pub.add('Progressing Line ' || M.line_id, 1);
                           END IF;

                           BEGIN
                           -- COMPLETING ACTIVITY
                           wf_engine.CompleteActivityInternalName
                           ('OEOL',
                            to_char(M.line_id),
                            'SCHEDULING_ELIGIBLE',
                            'COMPLETE');
                           EXCEPTION
                              WHEN OTHERS THEN
                                 NULL;
                           END;


                         END LOOP;

                       ELSE -- Call for each line or ATO/SMC...


                           BEGIN
                           -- COMPLETING ACTIVITY
                           wf_engine.CompleteActivityInternalName
                           ('OEOL',
                            to_char(l_line_id),
                            'SCHEDULING_ELIGIBLE',
                            'COMPLETE');
                           EXCEPTION
                              WHEN OTHERS THEN
                                 NULL;
                           END;
                       END IF;
                     END IF;
                     --5166476

                     --IF g_failed_records > 0 THEN
                     IF OE_SCH_CONC_REQUESTS.oe_line_status_tbl.EXISTS(l_line_id) AND
                        OE_SCH_CONC_REQUESTS.oe_line_status_tbl(l_line_id) = 'N' THEN
                        l_failure := TRUE;
                     END IF;
                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'R4 PROCESSED: '||l_rec_processed||' FAILED: '||l_rec_failure, 1 ) ;
                     END IF;
                  END IF;
               END IF;


            ELSIF p_sch_mode = 'UNSCHEDULE' AND
               l_schedule_status_code IS NOT NULL THEN

               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(to_char(l_line_id) || ' - Unschedule', 1);
               END IF;

               l_found := FALSE;

               IF l_smc_flag = 'Y' AND
                  l_top_model_line_id IS NOT NULL THEN
                  l_found := model_processed(l_top_model_line_id,l_top_model_line_id);
               ELSIF l_ato_line_id IS NOT NULL THEN
                  --l_top_model_line_id = l_ato_line_id THEN
                  l_found := model_processed(l_ato_line_id,l_ato_line_id);
               ELSIF l_smc_flag = 'N' AND
                  l_top_model_line_id IS NOT NULL AND
                  (l_ato_line_id IS NULL OR
                   l_ato_line_id <> l_top_model_line_id) AND
                   l_item_type_code = OE_GLOBALS.G_ITEM_INCLUDED THEN

                   l_found := included_processed(l_line_id);
               END IF;

               IF NOT l_found THEN
                  g_process_records := 0;
                  g_failed_records  := 0;

                  IF l_item_type_code = OE_GLOBALS.G_ITEM_INCLUDED THEN
                     --5166476
                     --g_process_records := g_process_records + 1;
                     OE_SCH_CONC_REQUESTS.oe_line_status_tbl(l_line_id) := 'Y';
                  END IF;
                  --R12.MOAC
                  l_selected_line_tbl(1).id1 := l_line_id;
                  OE_GROUP_SCH_UTIL.Schedule_Multi_lines
                     (p_selected_line_tbl     => l_selected_line_tbl,
                      p_line_count    => 1,
                      p_sch_action    => 'UNSCHEDULE',
                      x_atp_tbl       => l_atp_tbl,
                      x_return_status => l_return_status,
                      x_msg_count     => l_msg_count,
                      x_msg_data      => l_msg_data);
                  --5166476

                  --IF g_failed_records > 0 THEN
                  IF OE_SCH_CONC_REQUESTS.oe_line_status_tbl.EXISTS(l_line_id) AND
                     OE_SCH_CONC_REQUESTS.oe_line_status_tbl(l_line_id) = 'N' THEN
                     l_failure := TRUE;
                  END IF;
                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'R5 PROCESSED: '||l_rec_processed||' FAILED: '||l_rec_failure, 1 ) ;
                  END IF;

               END IF;
            ELSIF p_sch_mode IN ('RESCHEDULE','RESCHEDULE_RD') THEN

               l_temp_flag := FALSE;

               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(to_char(l_line_id) || ' - Reschedule', 1);
               END IF;

               IF l_smc_flag = 'Y' AND
                  l_top_model_line_id IS NOT NULL THEN
                  l_temp_flag := model_processed(l_top_model_line_id,l_top_model_line_id);
                  --5166476
                  IF l_temp_flag AND
                    oe_line_status_tbl.EXISTS(l_top_model_line_id)  AND
                    oe_line_status_tbl(l_top_model_line_id) = 'N' THEN
                    oe_line_status_tbl(l_line_id) := 'N';
                    /*
                     l_rec_processed := l_rec_processed + 1;
                     l_rec_failure   := l_rec_failure + 1;
                    */
                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'R6.1 PROCESSED: '||l_rec_processed||' FAILED: '||l_rec_failure, 1 ) ;
                     END IF;
                  END IF;
               ELSIF l_ato_line_id IS NOT NULL THEN
                   --l_ato_line_id = l_top_model_line_id THEN
                  l_temp_flag := model_processed(l_ato_line_id,l_ato_line_id);
                  --5166476
                  IF l_temp_flag AND
                    oe_line_status_tbl.EXISTS(l_ato_line_id) AND
                    oe_line_status_tbl(l_ato_line_id) = 'N' THEN
                     oe_line_status_tbl(l_line_id) := 'N';
                     /*
                     l_rec_processed := l_rec_processed + 1;
                     l_rec_failure   := l_rec_failure + 1;
                     */
                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add(  'R6.2 PROCESSED: '||l_rec_processed||' FAILED: '||l_rec_failure, 1 ) ;
                     END IF;
                  END IF;

               END IF;

               /* If many of the lines selected are part of a set, then delayed
                * request must get logged only for one of the lines.
                */
               IF l_ship_set_id IS NOT NULL OR
                  l_arrival_set_id IS NOT NULL THEN

                  l_temp_flag := set_processed( NVL(l_ship_set_id,l_arrival_set_id));
               END IF;

               IF NOT l_temp_flag THEN

                  -- Define a save point
                  SAVEPOINT Schedule_Line;

                  IF l_rec_processed > 1 THEN
                     l_init_msg_list := FND_API.G_FALSE;
                  END IF;

                  oe_line_util.lock_row
                        (x_return_status   => l_return_status
                        ,p_x_line_rec      => l_line_rec
                        ,p_line_id         => l_line_id);

                  l_line_tbl(1) := l_line_rec;
                  l_old_line_tbl(1) := l_line_rec;

                  l_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;

                  IF p_sch_mode = 'RESCHEDULE_RD' THEN
                     l_apply_sch_date := l_line_tbl(1).request_date;
                  END IF;

                  l_line_tbl(1).ship_from_org_id
                     := NVL(p_apply_warehouse, l_ship_from_org_id);


                  IF l_apply_sch_date IS NOT NULL THEN
                    IF l_order_date_type_code = 'SHIP' THEN
                      l_line_tbl(1).schedule_ship_date := l_apply_sch_date;
                    ELSE
                      l_line_tbl(1).schedule_arrival_date := l_apply_sch_date;
                    END IF;
                  END IF;

                  --l_line_tbl(1).schedule_action_code := OE_SCHEDULE_UTIL.OESCH_ACT_RESCHEDULE;

                  --4892724
                  l_line_tbl(1).change_reason := 'SYSTEM';
                  l_line_tbl(1).change_comments := 'SCHEDULE ORDERS CONCURRENT PROGRAM';

                  -- Call to process order
                  l_control_rec.controlled_operation := TRUE;
                  l_control_rec.write_to_db := TRUE;
                  --l_control_rec.PROCESS := FALSE;
                  l_control_rec.default_attributes := TRUE;
                  l_control_rec.change_attributes := TRUE;
                  l_process_order := TRUE;
                  l_control_rec.check_security    := TRUE;-- 5168540

                  g_process_records := 0;
                  g_failed_records  := 0;

                  Oe_Order_Pvt.Lines
                     (p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                      p_init_msg_list      => l_init_msg_list,
                      p_control_rec        => l_control_rec,
                      p_x_line_tbl         => l_line_tbl,
                      p_x_old_line_tbl     => l_old_line_tbl,
                      x_return_status      => l_return_status);

                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add('Oe_Order_Pvt.Lines returns with - '
                                      || l_return_status);
                  END IF;

                  IF l_return_status IN
                     (FND_API.G_RET_STS_ERROR,FND_API.G_RET_STS_UNEXP_ERROR)
                  THEN
                     ROLLBACK TO SAVEPOINT Schedule_Line;
                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add('#### FAILURE #### LINE_ID - '
                                         || to_char(l_line_id) || ' ####');
                     END IF;
                     --5166476
                     OE_SCH_CONC_REQUESTS.oe_line_status_tbl(l_line_id) := 'N';
                     --516476
                     IF l_smc_flag = 'Y' AND
                        l_top_model_line_id IS NOT NULL THEN
                        OE_line_status_Tbl(l_top_model_line_id) := 'N';
                     ELSIF l_ato_line_id IS NOT NULL THEN
                        OE_line_status_Tbl(l_ato_line_id) := 'N';
                     END IF;
                     l_failure := TRUE;
                  END IF;
                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'R6 PROCESSED: '||l_rec_processed||' FAILED: '||l_rec_failure, 1 ) ;
                  END IF;

               END IF;
            END IF; -- line eligible

            IF l_process_order = TRUE
              AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('After Call to Process Order ',1);
               END IF;
               BEGIN

                  l_control_rec.controlled_operation := TRUE;
                  l_control_rec.process              := TRUE;
                  l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_ALL;
                  l_control_rec.check_security       := FALSE;
                  l_control_rec.clear_dependents     := FALSE;
                  l_control_rec.default_attributes   := FALSE;
                  l_control_rec.change_attributes    := FALSE;
                  l_control_rec.validate_entity      := FALSE;
                  l_control_rec.write_to_DB          := FALSE;

                  --  Instruct API to clear its request table

                  l_control_rec.clear_api_cache      := FALSE;
                  l_control_rec.clear_api_requests   := TRUE;

                  oe_line_util.Post_Line_Process (p_control_rec  => l_control_rec,
                                            p_x_line_tbl   => l_line_tbl );
                  g_process_records := 0;
                  g_failed_records  := 0;

                  IF l_debug_level  > 0 THEN
                     oe_debug_pub.add('GOING TO EXECUTE DELAYED REQUESTS ', 2);
                  END IF;

                  OE_DELAYED_REQUESTS_PVT.Process_Delayed_Requests
                                 (x_return_status => l_return_status);

                  IF l_return_status IN (FND_API.G_RET_STS_ERROR,
                                         FND_API.G_RET_STS_UNEXP_ERROR) THEN
                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add('#### FAILURE #### LINE_ID - '
                                         || to_char(l_line_id) || ' ####');
                     END IF;

                     l_failure := TRUE;

                     OE_Delayed_Requests_PVT.Clear_Request(l_return_status);

                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add('AFTER CLEARING DELAYED REQUESTS: '|| l_return_status, 2);
                     END IF;

                     ROLLBACK TO SAVEPOINT Schedule_Line;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     OE_Delayed_Requests_PVT.Clear_Request(l_return_status);
                     IF l_debug_level  > 0 THEN
                        oe_debug_pub.add('IN WHEN OTHERS '|| l_return_status, 2);
                     END IF;
               END;

               l_process_order := FALSE;
            ELSE -- (5174789)Return status is not success
               OE_DELAYED_REQUESTS_PVT.Clear_Request(l_return_status);
               l_process_order := FALSE;
            END IF;

         END IF;
      END LOOP; -- loop for each row of dynamic query.

      -- close the cursor
      DBMS_SQL.Close_Cursor(l_cursor_id);

   END IF; -- if parameters passed are null.

   OE_MSG_PUB.Save_Messages(p_request_id => to_number(l_request_id));
   --5166476
   --l_rec_success := l_rec_processed - l_rec_failure;
   l_rec_success :=0;
   l_rec_processed := 0;
   l_rec_failure := 0;
   l_index := OE_SCH_CONC_REQUESTS.oe_line_status_tbl.FIRST;
   WHILE l_index is not null
   LOOP
       --oe_debug_pub.add(  'R7 : '||l_index||' Status: '||oe_line_status_tbl(l_index), 1 ) ;
      IF OE_SCH_CONC_REQUESTS.oe_line_status_tbl(l_index) = 'Y' THEN
         l_rec_success := l_rec_success + 1;
      ELSE
         l_rec_failure := l_rec_failure + 1;
      END IF;
      l_rec_processed := l_rec_processed +1;
      l_index := OE_SCH_CONC_REQUESTS.oe_line_status_tbl.NEXT(l_index);
   END LOOP;

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total Lines Selected : ' || l_rec_processed);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Lines Failed : ' || l_rec_failure);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Lines Successfully Processed : ' || l_rec_success);

   IF l_failure THEN
      RETCODE := 1;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      fnd_file.put_line(FND_FILE.LOG,
                        'Error executing Scheduling, Exception:G_EXC_ERROR');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      fnd_file.put_line(FND_FILE.LOG,
                        'Error executing Scheduling, Exception:G_EXC_UNEXPECTED_ERROR');

   WHEN OTHERS THEN
      fnd_file.put_line(FND_FILE.LOG, 'Unexpected error in OE_SCH_CONC_REQUESTS.Request');
      fnd_file.put_line(FND_FILE.LOG, substr(sqlerrm, 1, 2000));
      DBMS_SQL.Close_Cursor(l_cursor_id);

END Request;

END OE_SCH_CONC_REQUESTS;

/
