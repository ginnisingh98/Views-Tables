--------------------------------------------------------
--  DDL for Package Body OE_EXPORT_COMPLIANCE_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_EXPORT_COMPLIANCE_CONC" AS
/* $Header: OEXCITMB.pls 120.5.12010000.2 2009/01/12 10:36:13 sahvivek ship $ */



/*-----------------------------------------------------+
 | Name        :   Screening_Eligible                  |
 | Parameters  :   IN  p_line_id                       |
 |                                                     |
 | Description :   This Procedure returns whether the  |
 |                 line is eligible for Screening.     |
 |                 The line is eligible for screening  |
 |                 if it has line status code as       |
 |                 EXPORT COMPLIANCE ELIGIBLE          |
 |                 (The line had a data error)         |
 +-----------------------------------------------------*/

FUNCTION Screening_Eligible(
                           p_line_id NUMBER
                           ) RETURN BOOLEAN IS

l_activity_status VARCHAR2(20);

BEGIN

     -- Get Work Flow status for Line Id

        SELECT WIAS.Activity_Status
        INTO   l_activity_status
        FROM   wf_item_activity_statuses WIAS,
	       wf_process_activities WPA
        WHERE  WIAS.Process_Activity = WPA.instance_id
          AND  WPA.activity_name     = 'EXPORT_COMPLIANCE_ELIGIBLE'
          AND  WIAS.item_type        = 'OEOL'
          AND  WIAS.item_key         = to_char(p_line_id)
          AND  WIAS.activity_status  = 'NOTIFIED' ;

      RETURN TRUE;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
           RETURN FALSE;
        WHEN OTHERS THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Screening_Eligible;





/*-----------------------------------------------------+
 | Name        :   Screening                           |
 | Parameters  :   IN  p_order_num_low                 |
 |                     p_order_num_high                |
 |                     p_customer_name                 |
 |                     p_customer_po_num               |
 |                     p_order_type                    |
 |                     p_warehouse                     |
 |                     p_ship_to_location              |
 |                     p_inventory_item_id             |
 |                     p_schedule_date_low             |
 |                     p_schedule_date_high            |
 |                     p_ordered_date_low              |
 |                     p_ordered_date_high             |
 |                 OUT NOCOPY ERRBUF                   |
 |                     RETCODE                         |
 | Description :   This Procedure is called from       |
 |                 concurrent Program for Performing   |
 |                 Export Compliance Screening         |
 +-----------------------------------------------------*/


PROCEDURE Screening  (
                      ERRBUF                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                     ,RETCODE                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
     		      /* Moac */
                     ,p_org_id		     IN   NUMBER
                     ,p_order_num_low        IN   NUMBER
                     ,p_order_num_high       IN   NUMBER
                     ,p_customer             IN   NUMBER
                     ,p_customer_po_num      IN   VARCHAR2
                     ,p_order_type           IN   NUMBER
                     ,p_warehouse            IN   NUMBER
                     ,p_ship_to_location     IN   NUMBER
                     ,p_inventory_item_id    IN   NUMBER
                     ,p_schedule_date_low    IN   VARCHAR2
                     ,p_schedule_date_high   IN   VARCHAR2
                     ,p_ordered_date_low     IN   VARCHAR2
                     ,p_ordered_date_high    IN   VARCHAR2
                     ) IS
  /* bug 4632747
      CURSOR C_GET_LINES (
                      cp_order_num_low        NUMBER
                     ,cp_order_num_high       NUMBER
                     ,cp_customer             NUMBER
                     ,cp_customer_po_num      VARCHAR2
                     ,cp_order_type           NUMBER
                     ,cp_warehouse            NUMBER
                     ,cp_ship_to_location     NUMBER
                     ,cp_inventory_item_id    NUMBER
                     ,cp_schedule_date_low    DATE
                     ,cp_schedule_date_high   DATE
                     ,cp_ordered_date_low     DATE
                     ,cp_ordered_date_high    DATE
                     )
      IS
        SELECT -- MOAC_SQL_CHANGE
               L.line_id , L.org_id
        FROM     oe_order_lines L
                 ,oe_order_headers_all H
                 ,mtl_system_items MSI
        WHERE      L.header_id             =   H.header_id
          AND  L.inventory_item_id         =   MSI.inventory_item_id
          AND  L.ship_from_org_id          =   MSI.organization_id
          AND  H.order_number             >=   NVL(cp_order_num_low,
                                                  H.order_number)
          AND  H.order_number             <=   NVL(cp_order_num_high,
                                                  H.order_number)
          AND  NVL(H.sold_to_org_id,-99)   =   NVL(cp_customer,
                                                   NVL(H.sold_to_org_id,-99))
          AND  NVL(H.cust_po_number,-99)   =   NVL(cp_customer_po_num,
                                                   NVL(H.cust_po_number,-99))
          AND  H.order_type_id             =   NVL(cp_order_type,
                                                   H.order_type_id)
          AND  NVL(L.ship_from_org_id,-99) =   NVL(cp_warehouse,
                                                   NVL(L.ship_from_org_id,-99))
          AND  NVL(L.ship_to_org_id,-99)   =   NVL(cp_ship_to_location,
                                                   NVL(L.ship_to_org_id,-99))
          AND  L.inventory_item_id         =   NVL(cp_inventory_item_id,
                                                   L.inventory_item_id)
          AND  L.schedule_ship_date       >=   NVL(cp_schedule_date_low,
                                                   L.schedule_ship_date)
          AND  L.schedule_ship_date       <=   NVL(cp_schedule_date_high,
                                                   L.schedule_ship_date)
          AND  H.ordered_date             >=   NVL(cp_ordered_date_low,
                                                   H.ordered_date)
          AND  H.ordered_date             <=   NVL(cp_ordered_date_high,
                                                   H.ordered_date)
          AND  H.open_flag                 =   'Y' --for 3631462
          AND  L.open_flag                 =   'Y' --for 3631462
          ORDER BY H.org_id, H.header_id;

 commented for bug 4632747 */
-- added for bug 4632747
l_sql_stmt      VARCHAR2(20900);
l_sqlCursor     INTEGER;
l_dummy         NUMBER;

l_line_id   NUMBER;
l_msg_count NUMBER;
l_msg_data  VARCHAR2(2000)  := NULL;
l_schedule_date_low        DATE;
l_schedule_date_high       DATE;
l_ordered_date_low         DATE;
l_ordered_date_high        DATE;

-- MOAC
l_single_org		   BOOLEAN := FALSE;
l_old_org_id		   NUMBER  := -99;
l_org_id                   NUMBER;

BEGIN
   --Initialze retcode #4220950
   ERRBUF  := '';
   RETCODE := 0;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Starting EC Screening Program..');


    FND_FILE.PUT_LINE(FND_FILE.LOG,'Program Parameters');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'------------------');

    FND_FILE.PUT_LINE(FND_FILE.LOG,'p_org_id:'||p_org_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Order Num Low:'||p_order_num_low);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Order Num High:'||p_order_num_high);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Customer Id:'||p_customer);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Customer PO Num:'||p_customer_po_num);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Order Type:'||p_order_type);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Warehouse:'||p_warehouse);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Ship To Location:'||p_ship_to_location);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Item:'||p_inventory_item_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Schedule Date Low:'||p_schedule_date_low);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Schedule Date High:'||p_schedule_date_high);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Ordered Date Low:'||p_ordered_date_low);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Ordered Date High:'||p_ordered_date_high);

    SELECT
          FND_DATE.Canonical_To_Date(p_schedule_date_low),
          FND_DATE.Canonical_To_Date(p_schedule_date_high),
          FND_DATE.Canonical_To_Date(p_ordered_date_low),
          FND_DATE.Canonical_To_Date(p_ordered_date_high)
    INTO
          l_schedule_date_low,
          l_schedule_date_high,
          l_ordered_date_low,
          l_ordered_date_high
    FROM   DUAL;

    -- MOAC Start
    IF MO_GLOBAL.get_access_mode =  'S' THEN
       l_single_org := TRUE;
    ELSIF p_org_id IS NOT NULL THEN
       l_single_org := TRUE;
       MO_GLOBAL.set_policy_context(p_access_mode => 'S', p_org_id  => p_org_id);
    END IF;
    -- MOAC End

 -- The cursor is being built based on the parameters passed, bug 4632747
  l_sql_stmt := 'SELECT L.line_id, L.org_id '||
                'FROM   oe_order_lines L, oe_order_headers_all H, '||
                       'wf_item_activity_statuses WIAS, wf_process_activities WPA ' ||
                'WHERE  L.header_id =   H.header_id '||
                'AND  WIAS.item_key         = to_char(L.line_id) '||
                'AND  WIAS.Process_Activity = WPA.instance_id '||
                'AND  WPA.activity_name     = ''EXPORT_COMPLIANCE_ELIGIBLE'' '||
                'AND  WIAS.item_type        = ''OEOL'' ' ||
                'AND  WIAS.activity_status  = ''NOTIFIED'' '||
                'AND  H.open_flag = ''Y'' ' ||
                'AND  L.open_flag = ''Y'' ';

  IF p_order_num_low is not null then
    l_sql_stmt := l_sql_stmt ||  ' AND H.ORDER_NUMBER >= :p1 ';
  END IF;
  IF p_order_num_high is not null then
    l_sql_stmt := l_sql_stmt || ' AND H.ORDER_NUMBER <= :p2 ';
  END IF;
  IF p_customer is not null then
    l_sql_stmt := l_sql_stmt || ' AND H.SOLD_TO_ORG_ID = :p3 ';
  END IF;
  IF p_customer_po_num is not null then
    l_sql_stmt := l_sql_stmt || ' AND H.cust_po_number = :p4 ' ;
  END IF;
  IF p_order_type is not null then
    l_sql_stmt := l_sql_stmt || ' AND H.order_type_id = :p5 ';
  END IF;
  IF p_warehouse is not null then
    l_sql_stmt := l_sql_stmt || ' AND L.ship_from_org_id = :p6 ';
  END IF;
  IF p_ship_to_location is not null then
    l_sql_stmt := l_sql_stmt || ' AND L.ship_to_org_id = :p7 ';
  END IF;
  IF p_inventory_item_id is not null then
    l_sql_stmt := l_sql_stmt || ' AND L.inventory_item_id = :p8';
  END IF;
  IF l_schedule_date_low is not null then
    l_sql_stmt := l_sql_stmt || ' AND L.schedule_ship_date >= :p9 ' ;
  END IF;
  IF l_schedule_date_high is not null then
    l_sql_stmt := l_sql_stmt || ' AND L.schedule_ship_date <= :p10 ' ;
  END IF;
  IF l_ordered_date_low is not null then
    l_sql_stmt := l_sql_stmt || ' AND H.ordered_date >= :p11 ';
  END IF;
  IF l_ordered_date_high is not null then
    l_sql_stmt := l_sql_stmt || ' AND H.ordered_date <= :p12';
  END IF;
  IF p_org_id is NOT NULL THEN
    l_sql_stmt := l_sql_stmt || ' AND L.org_id = :p13';
  END IF;

  l_sql_stmt := l_sql_stmt || ' ORDER BY H.header_id';
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Sql built = '|| l_sql_stmt);

  l_sqlCursor := DBMS_SQL.Open_Cursor;

  DBMS_SQL.PARSE(l_sqlCursor, l_sql_stmt, DBMS_SQL.NATIVE);

  IF p_order_num_low IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(l_sqlCursor,':p1',p_order_num_low);
  END IF;
  IF p_order_num_high IS NOT NULL THEN
    dbms_sql.bind_variable(l_sqlCursor,':p2',p_order_num_high);
  END IF;
  IF p_customer IS NOT NULL THEN
    dbms_sql.bind_variable(l_sqlCursor,':p3',p_customer);
  END IF;
  IF p_customer_po_num IS NOT NULL THEN
    dbms_sql.bind_variable(l_sqlCursor,':p4',p_customer_po_num);
  END IF;
  IF p_order_type IS NOT NULL THEN
    dbms_sql.bind_variable(l_sqlCursor,':p5',p_order_type);
  END IF;
  IF p_warehouse IS NOT NULL THEN
    dbms_sql.bind_variable(l_sqlCursor,':p6',p_warehouse);
  END IF;
  IF p_ship_to_location IS NOT NULL THEN
    dbms_sql.bind_variable(l_sqlCursor,':p7',p_ship_to_location);
  END IF;
  IF p_inventory_item_id IS NOT NULL THEN
    dbms_sql.bind_variable(l_sqlCursor,':p8',p_inventory_item_id);
  END IF;
  IF l_schedule_date_low IS NOT NULL THEN
    dbms_sql.bind_variable(l_sqlCursor,':p9',l_schedule_date_low);
  END IF;
  IF l_schedule_date_high IS NOT NULL THEN
    dbms_sql.bind_variable(l_sqlCursor,':p10',l_schedule_date_high);
  END IF;
  IF l_ordered_date_low IS NOT NULL THEN
    dbms_sql.bind_variable(l_sqlCursor,':p11',l_ordered_date_low);
  END IF;
  IF l_ordered_date_high IS NOT NULL THEN
    dbms_sql.bind_variable(l_sqlCursor,':p12',l_ordered_date_high);
  END IF;
  IF p_org_id IS NOT NULL THEN
    dbms_sql.bind_variable(l_sqlCursor,':p13',p_org_id);
  END IF;

  DBMS_SQL.DEFINE_COLUMN (l_sqlCursor,1,l_line_id);
  DBMS_SQL.DEFINE_COLUMN (l_sqlCursor,2,l_org_id);
  l_dummy := DBMS_SQL.execute(l_sqlCursor);

  LOOP

    IF DBMS_SQL.FETCH_ROWS(l_sqlCursor) = 0 THEN
      EXIT;
    END IF;

    DBMS_SQL.COLUMN_VALUE(l_sqlCursor,1,l_line_id);
    DBMS_SQL.COLUMN_VALUE(l_sqlCursor,2,l_org_id);

    /*
    FOR  c_lines IN C_GET_LINES(
                     p_order_num_low,
                     p_order_num_high,
                     p_customer,
                     p_customer_po_num,
                     p_order_type,
                     p_warehouse,
                     p_ship_to_location,
                     p_inventory_item_id,
                     l_schedule_date_low,
                     l_schedule_date_high,
                     l_ordered_date_low,
                     l_ordered_date_high
                     )
    LOOP
       l_line_id  :=   c_lines.Line_Id;

         IF Screening_Eligible(p_line_id => l_line_id) THEN
    */
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Line:'||l_line_id||
                                       ' is Eligible for Screening');

            -- MOAC Start
	    -- l_org_id := c_lines.org_id; commented for bug 4632747
            IF NOT l_single_org and l_org_id <> l_old_org_id THEN
               l_old_org_id := l_org_id;
               MO_GLOBAL.set_policy_context(p_access_mode => 'S', p_org_id  => l_org_id);
            END IF;
            -- MOAC End

            WF_ENGINE.CompleteActivityInternalName(
                        itemtype  =>  'OEOL',
                        itemkey   =>  to_char(l_line_id),
                        activity  =>  'EXPORT_COMPLIANCE_ELIGIBLE',
                        result    =>  'COMPLETE'); -- Bug 7688120

           -- Write messages in to the log file

                OE_MSG_PUB.Count_And_Get (
                                 p_count  => l_msg_count,
                                 p_data   => l_msg_data);

                FOR I IN 1..l_msg_count
                LOOP
                   l_msg_data  :=  OE_MSG_PUB.Get(I,'F');
                   FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_data);
                END LOOP;
     --  END IF;
    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(l_sqlCursor); -- bug 4632747

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Exiting EC Screening Program..');


EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Expected Error in '||
                  'Export Compliance Screening Concurrent Program '||sqlerrm);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Unexpected Error in '||
                  'Export Compliance Screening Concurrent Program '||sqlerrm);
END Screening;

END OE_EXPORT_COMPLIANCE_CONC;

/
