--------------------------------------------------------
--  DDL for Package Body OE_INC_ITEMS_FREEZE_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_INC_ITEMS_FREEZE_CONC" AS
/* $Header: OEXCFIIB.pls 120.5 2006/09/13 18:30:10 akurella noship $ */



/*-----------------------------------------------------+
 | Name        :   Request                             |
 | Parameters  :   IN  p_order_num_low                 |
 |                     p_order_num_high                |
 |                     p_inventory_item_id             |
 |                     p_schedule_date_low             |
 |                     p_schedule_date_high            |
 |                     p_num_of_days                   |
 |                     p_ship_set_id                   |
 |                 OUT ERRBUF                          |
 |                     RETCODE                         |
 | Description :   This Procedure is called from       |
 |                 concurrent Program for progressing  |
 |                 all the lines that are eligible for |
 |                 Freezing the included items         |
 |                 First select all the lines depending|
 |                 upon the parameters and eligibility |
 |                 and complete the activity.          |
 +-----------------------------------------------------*/


PROCEDURE Request
( ERRBUF                 OUT  NOCOPY VARCHAR2
 ,RETCODE                OUT  NOCOPY VARCHAR2
 ,p_org_id		 IN          NUMBER
 ,p_order_num_low        IN          NUMBER
 ,p_order_num_high       IN          NUMBER
 ,p_inventory_item_id    IN          NUMBER
 ,p_schedule_date_low    IN          VARCHAR2
 ,p_schedule_date_high   IN          VARCHAR2
 ,p_num_of_days          IN          NUMBER
 ,p_ship_set_id          IN          NUMBER
) IS

l_line_id                  NUMBER;
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(2000)  := NULL;
l_schedule_date_low        DATE;
l_schedule_date_high       DATE;
l_sql_stmt                 VARCHAR2(20900);
l_sqlCursor                INTEGER;
l_dummy                    NUMBER;

-- Moac
l_single_org		   BOOLEAN := FALSE;
l_old_org_id		   NUMBER  := -99;
l_org_id		   NUMBER;

BEGIN
   --Initialze retcode #4220950
   ERRBUF  := '';
   RETCODE := 0;

    -- MOAC Start
    IF MO_GLOBAL.Get_Access_Mode = 'S' THEN
       l_single_org := TRUE;
    ELSIF p_org_id IS NOT NULL THEN
       l_single_org := TRUE;
       MO_GLOBAL.set_policy_context(p_access_mode => 'S', p_org_id => p_org_id);
    END IF;

   l_sql_stmt := 'SELECT   L.line_id, L.org_id  FROM     oe_order_lines L'     ||
                 ',oe_order_headers_all H '                                    ||
                 ',wf_item_activity_statuses WIAS'                             ||
	         ',wf_process_activities WPA'                                  ||
                 ' WHERE  l.open_flag           =   ''Y'' '                      ||
                 ' AND  WIAS.Process_Activity =   WPA.instance_id'             ||
                 ' AND  WPA.activity_name     =  ''FREEZE_INCLUDED_ITEMS_ELIGIBLE'''  ||
                 ' AND  WIAS.item_type        =   ''OEOL'''                    ||
                 ' AND  WPA.activity_item_type =  ''OEOL'''                    ||
                 ' AND  WIAS.item_key         =   l.line_id'          ||
                 ' AND  WIAS.activity_status  =   ''NOTIFIED''' ;


   IF p_org_id is NOT NULL THEN
      l_sql_stmt := l_sql_stmt || ' AND  H.org_id        =  :bindvar_org_id';
   END IF;
   -- MOAC End

   IF p_order_num_low is NOT NULL THEN
      l_sql_stmt := l_sql_stmt || ' AND  H.order_number        >=  :p1';
   END IF;

   IF p_order_num_high is NOT NULL THEN
      l_sql_stmt := l_sql_stmt || ' AND  H.order_number        <=  :p2';
   END IF;

   IF p_inventory_item_id is NOT NULL THEN
      l_sql_stmt := l_sql_stmt || ' AND  L.inventory_item_id   =  :p3';
   END IF;

   IF p_schedule_date_low is NOT NULL OR
               p_num_of_days is NOT NULL THEN
      l_sql_stmt := l_sql_stmt || ' AND  L.schedule_ship_date  >=  :p4';
   END IF;

   IF p_schedule_date_high is NOT NULL OR
               p_num_of_days is NOT NULL THEN
      l_sql_stmt := l_sql_stmt || ' AND  L.schedule_ship_date  <=  :p5';
   END IF;

   IF p_ship_set_id is NOT NULL THEN
      l_sql_stmt := l_sql_stmt || ' AND  L.ship_set_id         =  :p6';
   END IF;

   -- MOAC Start
   If not l_single_org then
      l_sql_stmt := l_sql_stmt || ' ORDER BY L.org_id, L.header_id';
   else
      l_sql_stmt := l_sql_stmt || ' ORDER BY L.header_id';
   end if;
   -- MOAC End

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Starting Freeze Included Items Program..');

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Program Parameters');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'------------------');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Order Num Low:'||p_order_num_low);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Order Num High:'||p_order_num_high);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Item:'||p_inventory_item_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Schedule Date Low:'||p_schedule_date_low);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Schedule Date High:'||p_schedule_date_high);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Ship Set:'||p_ship_set_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Num of Days:'||p_num_of_days);

    SELECT
          FND_DATE.Canonical_To_Date(p_schedule_date_low),
          FND_DATE.Canonical_To_Date(p_schedule_date_high)
    INTO
          l_schedule_date_low,
          l_schedule_date_high
    FROM   DUAL;

   l_sqlCursor := DBMS_SQL.Open_Cursor;

   DBMS_SQL.PARSE(l_sqlCursor, l_sql_stmt, DBMS_SQL.NATIVE);

    -- Moac Start
    IF p_org_id IS NOT NULL THEN
       DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':bindvar_org_id',p_org_id);
    END IF;
    -- Moac End

   IF p_order_num_low IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p1',p_order_num_low);
   END IF;

   IF p_order_num_high IS NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p2',p_order_num_high);
   END IF;

   IF p_inventory_item_id is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p3',p_inventory_item_id);
   END IF;

   IF p_schedule_date_low is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p4',l_schedule_date_low);
   END IF;

   IF p_schedule_date_high is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p5',l_schedule_date_high);
   END IF;

   IF p_ship_set_id is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p6',p_ship_set_id);
   END IF;

   IF (p_schedule_date_low is NULL   AND
        p_schedule_date_high is NULL) AND
          p_num_of_days is NOT NULL    THEN
      DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p4',sysdate);
      DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p5',sysdate+p_num_of_days);
   END IF;

   Oe_debug_pub.add('Sql Stmt: ' || l_sql_stmt,1);
   DBMS_SQL.DEFINE_COLUMN (l_sqlCursor,1,l_line_id);
   -- Moac
   DBMS_SQL.DEFINE_COLUMN (l_sqlCursor,2,l_org_id);

   l_dummy := DBMS_SQL.execute(l_sqlCursor);

    Oe_debug_pub.add('After Executing the Cusrsor',1);
    LOOP

      IF DBMS_SQL.FETCH_ROWS(l_sqlCursor) = 0 THEN
         EXIT;
      END IF;

      DBMS_SQL.COLUMN_VALUE(l_sqlCursor,1,l_line_id);
      -- Moac
      DBMS_SQL.COLUMN_VALUE(l_sqlCursor,2,l_org_id);

            FND_FILE.PUT_LINE(FND_FILE.LOG,'Processing Line:'||l_line_id);

	    -- MOAC Start
	    IF not l_single_org and l_org_id <> l_old_org_id THEN
	       l_old_org_id := l_org_id;
	       MO_GLOBAL.set_policy_context(p_access_mode => 'S', p_org_id  => l_org_id);
	    END IF;
	    -- MOAC End

           Oe_debug_pub.add('Processing Line : ' || to_char(l_line_id),1);

            WF_ENGINE.CompleteActivityInternalName(
                        itemtype  =>  'OEOL',
                        itemkey   =>  to_char(l_line_id),
                        activity  =>  'FREEZE_INCLUDED_ITEMS_ELIGIBLE',
                        result    =>  'COMPLETED');

           -- Write messages in to the log file

                OE_MSG_PUB.Count_And_Get (
                                 p_count  => l_msg_count,
                                 p_data   => l_msg_data);

                FOR I IN 1..l_msg_count
                LOOP
                   l_msg_data  :=  OE_MSG_PUB.Get(I,'F');
                   FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_data);
                END LOOP;
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(l_sqlCursor);

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Exiting Freeze Included Items Program:..');


EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Expected Error in '||
                  'Freeze Included Items Concurrent Program '||sqlerrm);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Unexpected Error in '||
                  'Freeze Included Items Concurrent Program '||sqlerrm);
END Request;

END OE_INC_ITEMS_FREEZE_CONC;

/
