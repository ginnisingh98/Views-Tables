--------------------------------------------------------
--  DDL for Package Body OE_PUR_CONC_REQUESTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PUR_CONC_REQUESTS" AS
/* $Header: OEXCDSPB.pls 120.6.12010000.2 2008/11/26 00:08:03 shrgupta ship $ */

--  Global constant holding the package name

G_PKG_NAME   CONSTANT VARCHAR2(30) := 'OE_PUR_CONC_REQUESTS';

/*-----------------------------------------------------------------
FUNCTION   : Line_Eligible
DESCRIPTION: Check if the line is eligible for purchase release.
-----------------------------------------------------------------*/

Function Line_Eligible(p_line_id IN NUMBER)
RETURN BOOLEAN
IS
  l_activity_status_code VARCHAR2(8);
BEGIN

  -- Check for workflow status to be Purchase Release Eligible

  SELECT wias.ACTIVITY_STATUS
  INTO l_activity_status_code
  FROM wf_item_activity_statuses wias, wf_process_activities wpa
  WHERE wias.process_activity = wpa.instance_id
  AND   wpa.activity_name = 'PURCHASE RELEASE ELIGIBLE'
  AND   wias.item_type = 'OEOL'
  AND   wias.item_key  = to_char(p_line_id)
  AND   wias.activity_status = 'NOTIFIED';

  RETURN TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN FALSE;
  WHEN OTHERS THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Line_Eligible;


/*-----------------------------------------------------------------
PROCEDURE  : Request
DESCRIPTION: Purchase Release Concurrent Request
-----------------------------------------------------------------*/

Procedure Request
(ERRBUF OUT NOCOPY VARCHAR2,

RETCODE OUT NOCOPY VARCHAR2,
 /* Moac */
 p_org_id	      IN  NUMBER,
 p_order_number_low   IN  NUMBER,
 p_order_number_high  IN  NUMBER,
 p_request_date_low   IN  VARCHAR2,
 p_request_date_high  IN  VARCHAR2,
 p_customer_po_number IN  VARCHAR2,
 p_ship_to_location   IN  VARCHAR2,
 p_order_type         IN  VARCHAR2,
 p_customer           IN  VARCHAR2,
 p_item               IN  VARCHAR2
)
IS
   l_return_status VARCHAR2(1);
   l_msg_count     NUMBER;
   l_msg_data      VARCHAR2(2000) := NULL;

   v_line_id       NUMBER;
   l_sql_stmt      VARCHAR2(20900);
   l_sqlCursor    INTEGER;
   l_dummy         NUMBER;
--bug#5081428: introducing 1 local variable
   l_count         number := 1;
--Bug2295434 Introduced 2 Local Varibles given below.
   l_request_date_low    DATE;
   l_request_date_high   DATE;

   -- MOAC
   l_single_org     BOOLEAN := FALSE;
   l_old_org_id     NUMBER  := -99;
   l_org_id         NUMBER;
l_activity_status     VARCHAR2(50);
l_activity_result     VARCHAR2(50);

BEGIN
   --Initialze retcode #4220950
   ERRBUF  := '';
   RETCODE := 0;

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start of the program ');

   -- Moac Start
   IF MO_GLOBAL.get_access_mode = 'S' THEN
      l_single_org := TRUE;
   ELSIF p_org_id IS NOT NULL THEN
      l_single_org := TRUE;
      MO_GLOBAL.set_policy_context(p_access_mode => 'S', p_org_id  => p_org_id);
   END IF;
   -- Moac End

   SELECT fnd_date.canonical_to_date(p_request_date_low),
          fnd_date.canonical_to_date(p_request_date_high)
   INTO   l_request_date_low,
          l_request_date_high
   FROM   DUAL;

   --MOAC start
  /* l_sql_stmt := ' SELECT SL.LINE_ID, SL.ORG_ID '||
                 ' FROM MTL_SYSTEM_ITEMS MSI,  OE_ORDER_LINES SL, OE_ORDER_HEADERS_ALL SH  '||
                 ' WHERE SL.HEADER_ID = SH.HEADER_ID '||
                 ' AND SL.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID '||
                 ' AND SL.SHIP_FROM_ORG_ID = MSI.ORGANIZATION_ID '||
                 ' AND SL.SOURCE_TYPE_CODE = ''EXTERNAL'''; */

    l_sql_stmt := ' SELECT SL.LINE_ID, SL.ORG_ID '||
                 ' FROM OE_ORDER_LINES SL, OE_ORDER_HEADERS_ALL SH  '||
                 ' WHERE SL.HEADER_ID = SH.HEADER_ID '||
                 ' AND SL.SOURCE_TYPE_CODE = ''EXTERNAL''';

   IF p_org_id is NOT NULL THEN
      l_sql_stmt := l_sql_stmt || ' AND SH.ORG_ID = :bindvar_org_id ' ;
   END IF;
   -- Moac End

   IF p_order_number_low IS NOT NULL THEN
      l_sql_stmt := l_sql_stmt || ' AND SH.ORDER_NUMBER >= :p1 ';
   END IF;
   IF p_order_number_high IS NOT NULL THEN
      l_sql_stmt := l_sql_stmt || ' AND SH.ORDER_NUMBER <= :p2 ';
   END IF;
   IF p_ship_to_location IS NOT NULL THEN
      l_sql_stmt := l_sql_stmt || ' AND SL.SHIP_TO_ORG_ID = :p3 ';
   END IF;
   IF p_order_type IS NOT NULL THEN
      l_sql_stmt := l_sql_stmt || ' AND SH.ORDER_TYPE_ID = :p4 ';
   END IF;
   IF p_customer IS NOT NULL THEN
      l_sql_stmt := l_sql_stmt || ' AND SH.SOLD_TO_ORG_ID = :p5 ';
   END IF;
   IF l_request_date_low IS NOT NULL THEN
      l_sql_stmt := l_sql_stmt || ' AND SH.REQUEST_DATE >= :p6 ';
   END IF;
   IF l_request_date_high IS NOT NULL THEN
      l_sql_stmt := l_sql_stmt || ' AND SH.REQUEST_DATE <= :p7 ';
   END IF;

   -- Moac Start : Commented the below code
   --IF p_item IS NOT NULL THEN
   --   l_sql_stmt := l_sql_stmt || ' AND MSI.SEGMENT1 = :p8 ';
   --END IF;
    IF p_item IS NOT NULL THEN
       l_sql_stmt := l_sql_stmt || ' AND SL.INVENTORY_ITEM_ID = :p8 ';
    END IF;
   -- Moac End

    -- shewgupt
    IF p_customer_po_number IS NOT NULL THEN
       l_sql_stmt := l_sql_stmt || ' AND SH.cust_po_number = :p9 ';
    END IF;

   --bug3241701
   --added the open_flag condition to l_sql_stmt
   l_sql_stmt := l_sql_stmt || ' AND SH.OPEN_FLAG = ''Y''' ; /* Moac */
   --bug3241701 ends

   --bug7583417
   l_sql_stmt := l_sql_stmt || ' AND SL.OPEN_FLAG = ''Y''';
   --bug7583417 ends

   -- Moac Start
   IF p_org_id IS NOT NULL THEN
      l_sql_stmt := l_sql_stmt || ' ORDER BY SH.ORG_ID, SH.HEADER_ID ';
   ELSE
      l_sql_stmt := l_sql_stmt || ' ORDER BY SH.HEADER_ID ';
   END IF;
   -- Moac End

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Entering Purchase Release program with new set Parameters:');
   FND_FILE.PUT_LINE(FND_FILE.LOG, '  p_org_id		 =  '|| p_org_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '  Order Number High  =  '|| p_order_number_low);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '  Order Number Low   =  '|| p_order_number_high);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '  Ship To Org ID     =  '|| p_ship_to_location);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '  Order Type ID      =  '|| p_order_type);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '  Customer ID        =  '|| p_customer);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '  Request Date High  =  '|| to_char(l_request_date_high,'DD-MON-YYYY'));
   FND_FILE.PUT_LINE(FND_FILE.LOG, '  Request Date Low   =  '|| to_char(l_request_date_low,'DD-MON-YYYY'));
   FND_FILE.PUT_LINE(FND_FILE.LOG, '  Item               =  '|| p_item);
   FND_FILE.PUT_LINE(FND_FILE.LOG, ' Cust PO Number      =  '|| p_customer_po_number);

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
   IF p_order_number_high IS NOT NULL THEN
      dbms_sql.bind_variable(l_sqlCursor,':p2',p_order_number_high);
   END IF;
   IF p_ship_to_location IS NOT NULL THEN
      dbms_sql.bind_variable(l_sqlCursor,':p3',p_ship_to_location);
   END IF;
   IF p_order_type IS NOT NULL THEN
      dbms_sql.bind_variable(l_sqlCursor,':p4',p_order_type);
   END IF;
   IF p_customer IS NOT NULL THEN
      dbms_sql.bind_variable(l_sqlCursor,':p5',p_customer);
   END IF;
   IF l_request_date_low IS NOT NULL THEN
      dbms_sql.bind_variable(l_sqlCursor,':p6',l_request_date_low);
   END IF;
   IF l_request_date_high IS NOT NULL THEN
      dbms_sql.bind_variable(l_sqlCursor,':p7',l_request_date_high);
   END IF;

   -- Moac Start.
   IF p_item IS NOT NULL THEN
      dbms_sql.bind_variable(l_sqlCursor,':p8',p_item);
   END IF;

   IF p_customer_po_number IS NOT NULL THEN
      dbms_sql.bind_variable(l_sqlCursor,':p9',p_customer_po_number);
   END IF;
  -- Moac End.

   DBMS_SQL.DEFINE_COLUMN (l_sqlCursor,1,v_line_id);
   -- Moac
   DBMS_SQL.DEFINE_COLUMN (l_sqlCursor,2,l_org_id);


   l_dummy := DBMS_SQL.execute(l_sqlCursor);

   LOOP

      IF DBMS_SQL.FETCH_ROWS(l_sqlCursor) = 0 THEN
         EXIT;
      END IF;

      DBMS_SQL.COLUMN_VALUE(l_sqlCursor,1,v_line_id);
      DBMS_SQL.COLUMN_VALUE(l_sqlCursor,2,l_org_id);

      IF Line_Eligible(p_line_id => v_line_id) THEN

         FND_FILE.PUT_LINE (FND_FILE.LOG, 'Processing Line ID => '||v_line_id);

        -- Moac Start
	IF NOT l_single_org and l_org_id <> l_old_org_id THEN
	   l_old_org_id := l_org_id;
           MO_GLOBAL.set_policy_context(p_access_mode => 'S', p_org_id => l_org_id);
        END IF;
	-- Moac End.

         WF_ENGINE.CompleteActivityInternalName
                       (itemtype  => 'OEOL',
                        itemkey   => to_char(v_line_id),
                        activity  => 'PURCHASE RELEASE ELIGIBLE',
                        result    => 'COMPLETE');

             -- #5873209, to set the concurrent program's completion status, check if
             --           the order line was purchase release complete

             BEGIN

                 SELECT wias.ACTIVITY_STATUS, wias.activity_result_code
                 INTO   l_activity_status, l_activity_result
                 FROM   wf_item_activity_statuses wias, wf_process_activities wpa
                 WHERE  wias.process_activity = wpa.instance_id
                 AND    wpa.activity_name = 'PUR_REL_THE_LINE'
                 AND    wias.item_type = 'OEOL'
                 AND    wias.item_key  = to_char(v_line_id);

             EXCEPTION WHEN OTHERS THEN
                            NULL;
             END;

             FND_FILE.PUT_LINE (FND_FILE.LOG,'activity result '||l_activity_result);

             -- #5873209, if purchase release activity was not complete, then set the conc program status as warning
             IF l_activity_result <> 'COMPLETE' THEN
                errbuf := 'Could not complete the Purchase Release activity for Order Line ID '||v_line_id||', review the log for more details';
                retcode := AD_CONC_UTILS_PKG.CONC_WARNING;
             END IF;

        /* Write Messages in the log file */

         OE_MSG_PUB.Count_And_Get
           ( p_count     => l_msg_count
           , p_data      => l_msg_data
           );

        --bug#5081428:- printing only those mesgs which belongs to line_id
        --under iteration.  Earlier all the mesgs from 1st till last were
        -- printed and causing log file to increase exponentially in size.
         for I in l_count..l_msg_count loop
             l_msg_data := OE_MSG_PUB.Get(I,'F');
             fnd_file.put_line(FND_FILE.LOG, l_msg_data);
             -- Write the message to the database?
         end loop;
         l_count :=  l_msg_count + 1;
        --bug#5081428


      END IF;

   END LOOP;
   DBMS_SQL.CLOSE_CURSOR(l_sqlCursor);


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      fnd_file.put_line(FND_FILE.LOG, 'Expected Error in Purchase Release Program'||sqlerrm);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      fnd_file.put_line(FND_FILE.LOG, 'Unexpected Error in Purchase Release Program'||sqlerrm);
END Request;

END OE_PUR_CONC_REQUESTS;

/
