--------------------------------------------------------
--  DDL for Package Body OE_ORDER_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_PURGE_PVT" AS
/* $Header: OEXVPURB.pls 120.19 2008/01/08 19:38:44 shrgupta ship $ */


Procedure Select_Purge_Orders
(
	p_dummy1			OUT NOCOPY /* file.sql.39 change */	VARCHAR2,
	p_dummy2			OUT NOCOPY /* file.sql.39 change */	VARCHAR2,
	p_purge_set_id		IN	NUMBER
)
IS
	l_id_list			CLOB;
	l_Count_Selected	NUMBER;
	l_purge_set_submit_datetime DATE;

	l_buffer			VARCHAR2(32000);
	l_amount			BINARY_INTEGER := 32000;
	l_position			INTEGER := 1;

	l_char_id_list		VARCHAR2(32000);
	l_selected_ids_tbl	SELECTED_IDS_TBL;
	l_start_from		INTEGER := 1;
	l_length			INTEGER;
	l_separator		VARCHAR2(1) := ',';
	l_header_id		NUMBER;
	l_orders_per_commit	NUMBER;

	Cursor purge_set is
  	Select selected_ids
      , Count_Selected
      ,purge_set_submit_datetime
	 , orders_per_commit
	From OE_PURGE_SETS
	Where Purge_set_id = p_purge_set_id;

BEGIN

	oe_debug_pub.add('Entering OE_Order_Purge_PVT.Select_Purge_Orders '||p_purge_set_id,1);

	fnd_file.put_line(FND_FILE.LOG,'Parameters :');
	fnd_file.put_line(FND_FILE.LOG,'             Purge Set Id : '||p_purge_set_id);
	OPEN purge_set;
	Fetch purge_set
	into l_id_list
	,l_Count_Selected
	,l_purge_set_submit_datetime
	,l_orders_per_commit;

	IF	nvl(l_count_selected,0) <> 0 THEN
		DBMS_LOB.OPEN(l_id_list,DBMS_LOB.LOB_READONLY);
		l_length := DBMS_LOB.GETLENGTH(l_id_list);
		oe_debug_pub.add('Lenght of the LOB : '||to_char(l_length));

		FOR	I IN 1..l_count_selected LOOP
			l_position := DBMS_LOB.INSTR(l_id_list,l_separator,l_start_from,1);
			IF	l_position <> 0 THEN
				l_header_id := to_number(DBMS_LOB.SUBSTR(l_id_list,(l_position - l_start_from),l_start_from));
			ELSE
				l_header_id := to_number(DBMS_LOB.SUBSTR(l_id_list,(l_length - l_start_from + 1),l_start_from));
			END IF;
			l_selected_ids_tbl(I) := l_header_id;
			oe_debug_pub.add('Header id : '||to_char(l_header_id));
			l_start_from := l_position + 1;
		END LOOP;

		DBMS_LOB.CLOSE(l_id_list);

		oe_debug_pub.add('Selected Ids : '||l_char_id_list);
	END IF;

	l_orders_per_commit := 100;

	IF	nvl(l_count_selected,0) <> 0 THEN
		Select_Ids_Purge
		(
			p_purge_set_id,
			l_selected_ids_tbl,
			l_count_selected ,
			l_orders_per_commit);
	END IF;

	oe_debug_pub.add('Exiting OE_Order_Purge_PVT '||p_purge_set_id,1);



EXCEPTION
	WHEN OTHERS THEN
		fnd_file.put_line(FND_FILE.LOG,'*** Error In Generate purge set ** '||substr(sqlerrm,1,300));

End Select_Purge_Orders;


--- for bug 2323045
-- Changed the date format MM/DD/RRRR HH24:MM:SS to MM/DD/RRRR HH24:MI:SS

Procedure Select_Where_Cond_Purge
(
        ERRBUF                        OUT NOCOPY /* file.sql.39 change */       VARCHAR2
,       RETCODE                       OUT NOCOPY /* file.sql.39 change */       VARCHAR2
,       p_organization_id             IN      NUMBER
,       p_purge_set_name              IN        VARCHAR2
,       p_purge_set_description       IN        VARCHAR2
,       p_order_number_low            IN        NUMBER
,       p_order_number_high           IN        NUMBER
,       p_order_type_id               IN        NUMBER
,       p_order_category              IN        VARCHAR2
,       p_customer_id                 IN        NUMBER
,       p_ordered_date_low            IN        VARCHAR2
,       p_ordered_date_high           IN        VARCHAR2
,       p_creation_date_low           IN        VARCHAR2
,       p_creation_date_high          IN        VARCHAR2
,	p_dummy			      IN	VARCHAR2 DEFAULT NULL
,       p_include_contractual_orders  IN        VARCHAR2 DEFAULT NULL
)
IS
        l_sql_stmt              VARCHAR2(4000) := NULL;
        l_where_condition       VARCHAR2(4000) := NULL ;
        l_header_id             NUMBER;
        l_order_number          NUMBER;
        l_order_type_name       VARCHAR2(30);
        l_sold_to_org_id        NUMBER;
        l_price_list_id         NUMBER;
        l_purge_set_id          NUMBER;
        l_selected_ids          SELECTED_IDS_TBL;
        l_customer_name         VARCHAR2(50);
        l_orders_per_commit     NUMBER := 100;
        l_rec_count             NUMBER := 0;
        l_ordered_date_low      DATE;
        l_ordered_date_high     DATE;
        l_creation_date_low     DATE;
        l_creation_date_high    DATE;
        l_purge                 VARCHAR2(1);
        l_quote_number          NUMBER;
        l_flow_status_code      VARCHAR2(30);
        l_upgraded_flag         VARCHAR2(1);
        l_sql_cursor            INTEGER;
        l_dummy                 NUMBER;
        l_debug_level CONSTANT  NUMBER := oe_debug_pub.g_debug_level;
	l_org_id                NUMBER;

    CURSOR cur_get_org_for_ord_type IS
           SELECT org_id
           FROM OE_ORDER_TYPES_V --MOAC view based on multiple objects
           WHERE order_type_id = p_order_type_id;

BEGIN
    --Bug #4220950
    ERRBUF  := '';
    RETCODE := 0;

  -- Begining MOAC Changes

     IF p_organization_id IS NOT NULL THEN

     -- Setting a Single Org access.

       MO_GLOBAL.set_policy_context ('S', p_organization_id);

     ELSIF p_organization_id IS NULL THEN

      --
      -- If p_organization_id is NULL, then check if the p_order_type_id is NULL.
      -- If it is not NULL then get the org_id for this assosiated transaction type
      -- If the p_order_type_id is NULL the the Multiple Org access is set.
      --


          IF p_order_type_id IS NOT NULL THEN

             OPEN  cur_get_org_for_ord_type;
             FETCH cur_get_org_for_ord_type INTO l_org_id;
             CLOSE cur_get_org_for_ord_type;

           -- Setting a Single Org access.

	      MO_GLOBAL.set_policy_context ('S', l_org_id);

           ELSE
            -- Setting a Multiple Org access.

	       MO_GLOBAL.set_policy_context('M','');

	   END IF;
        END IF;


 -- End MOAC Changes



   --Quote purge changes
   --Select Flow Status Code,Quote Number,Upgraded Flag.
   --Check for transaction phase code as F

   l_sql_stmt:=
       'SELECT  OOH.HEADER_ID,
                OOH.ORDER_NUMBER,
                OOT.NAME,
                OOH.SOLD_TO_ORG_ID,
                OOH.PRICE_LIST_ID,
                OOH.QUOTE_NUMBER,
                OOH.FLOW_STATUS_CODE,
                OOH.UPGRADED_FLAG
        FROM    OE_ORDER_HEADERS_ALL OOH,
                OE_ORDER_TYPES_V OOT  --MOAC view based on multiple obj
        WHERE   OOH.ORDER_TYPE_ID = OOT.ORDER_TYPE_ID
        AND     NVL(OOH.TRANSACTION_PHASE_CODE,''F'')<>''N''';


   IF l_debug_level  > 0
   THEN
      OE_DEBUG_PUB.Add('Inside select_where_cond_quote');
   END IF;

   SELECT fnd_date.canonical_to_date(p_ordered_date_low),
          fnd_date.canonical_to_date(p_ordered_date_high),
          fnd_date.canonical_to_date(p_creation_date_low),
          fnd_date.canonical_to_date(p_creation_date_high)
   INTO   l_ordered_date_low,
          l_ordered_date_high,
          l_creation_date_low,
          l_creation_date_high
   FROM   DUAL;


   -- SQL literal changes
   IF nvl(p_order_number_low,0) <> 0 AND
      nvl(p_order_number_high,0) <> 0
   THEN
      l_where_condition := 'Order Number between '||to_char(p_order_number_low)||' AND '||to_char(p_order_number_high);  -- Bug 5667753
      l_sql_stmt:=  l_sql_stmt || ' AND  OOH.ORDER_NUMBER    >=  :p1';
      l_sql_stmt := l_sql_stmt || ' AND  OOH.ORDER_NUMBER    <=  :p2';
   -- l_where_condition := 'Order Number between :p1 AND :p2';

   ELSIF nvl(p_order_number_low,0) = 0 AND
         nvl(p_order_number_high,0) <> 0
   THEN
      l_sql_stmt := l_sql_stmt || ' AND  OOH.ORDER_NUMBER    <=  :p2';
      l_where_condition := 'Order Number <= '||to_char(p_order_number_high);   -- bug 5667753
   -- l_where_condition := 'Order Number <= :p2';
         /* Changed the above statement to fix the bug 2745071 */

   ELSIF nvl(p_order_number_low,0) <> 0 AND
         nvl(p_order_number_high,0) = 0
   THEN
      l_sql_stmt := l_sql_stmt || ' AND  OOH.ORDER_NUMBER    >=  :p1';
      l_where_condition := 'Order Number >= '||to_char(p_order_number_low);   -- bug 5667753
   -- l_where_condition := 'Order Number >= :p1';
           /* Changed the above statement to fix the bug 2745071 */
   END IF;


   IF nvl(p_order_type_id,0) <> 0
   THEN
      l_sql_stmt := l_sql_stmt || ' AND  OOH.ORDER_TYPE_ID    =  :p3';
      SELECT    NAME
      INTO      l_order_type_name
      FROM      OE_ORDER_TYPES_V --MOAC view based on multiple obj
      WHERE     ORDER_TYPE_ID = p_order_type_id;

      IF l_where_condition IS NULL
      THEN
	 l_where_condition := ' Order Type = '||l_Order_type_name;      -- bug 5667753
      -- l_where_condition := ' Order Type = :p10';
      ELSE
	 l_where_condition := l_where_condition || ' AND Order Type = '||l_Order_type_name;  -- bug 5667753
      -- l_where_condition := l_where_condition || ' AND Order Type = :p10';
      END IF;
   END IF;

   IF p_order_category IS NOT NULL
   THEN
      l_sql_stmt := l_sql_stmt || ' AND  OOH.ORDER_CATEGORY_CODE    =  :p4';
      IF l_where_condition IS NULL
      THEN
	 l_where_condition := ' Order Category = '||p_order_category; -- bug 5667753
      -- l_where_condition := ' Order Category = :p4';
      ELSE
	 l_where_condition := l_where_condition || ' AND Order Category = '||p_order_category; -- bug 5667753
      -- l_where_condition := l_where_condition || ' AND Order Category = :p4';
      END IF;
   END IF;

   IF nvl(p_customer_id,0) <> 0
   THEN
      l_sql_stmt := l_sql_stmt || ' AND  OOH.SOLD_TO_ORG_ID    =  :p5';
      SELECT    p.PARTY_NAME
      INTO      l_customer_name
      FROM      HZ_CUST_ACCOUNTS c,
                HZ_PARTIES p
      WHERE     c.CUST_ACCOUNT_ID = p_customer_id
      AND       c.PARTY_ID = p.PARTY_ID;

      IF l_where_condition IS NULL
      THEN
	 l_where_condition := ' Customer = '||l_customer_name; -- bug 5667753
      -- l_where_condition := ' Customer = :p11';
      ELSE
	 l_where_condition := l_where_condition|| ' AND Customer = '||l_customer_name;  -- bug 5667753
      -- l_where_condition := l_where_condition|| ' AND Customer = :p11';
      END IF;
   END IF;

--Bug5702003

   IF l_ordered_date_low IS NOT NULL AND
      l_ordered_date_high IS NOT NULL
   THEN
      l_sql_stmt := l_sql_stmt || ' AND  OOH.ORDERED_DATE    >=  :p6';
      l_sql_stmt := l_sql_stmt || ' AND  OOH.ORDERED_DATE    <=  :p7';

      IF l_where_condition IS NULL
      THEN
	 l_where_condition := 'Ordered Date Between '||to_char(l_ordered_date_low,'MM/DD/RRRR HH24:MI:SS')||' AND '||to_char(l_ordered_date_high,'MM/DD/RRRR HH24:MI:SS');  -- bug 5667753
      -- l_where_condition := 'Ordered Date Between :p6 AND :p7';
      ELSE
	 l_where_condition := l_where_condition|| ' AND Ordered Date Between '||to_char(l_ordered_date_low,'MM/DD/RRRR HH24:MI:SS')||' AND '||to_char(l_ordered_date_high,'MM/DD/RRRR HH24:MI:SS');  -- bug 5667753
      -- l_where_condition := l_where_condition|| ' Ordered Date Between :p6 AND :p7';
      END IF;

   ELSIF l_ordered_date_low IS NOT NULL AND
         l_ordered_date_high IS NULL
   THEN
      l_sql_stmt := l_sql_stmt || ' AND  OOH.ORDERED_DATE    >=  :p6';
      IF l_where_condition IS NULL
      THEN
	 l_where_condition := 'Ordered Date >= '||to_char(l_ordered_date_low,'MM/DD/RRRR HH24:MI:SS'); -- bug 5667753
      -- l_where_condition := 'Ordered Date >= :p6';
      ELSE
	 l_where_condition := l_where_condition||' AND Ordered Date >= '||to_char(l_ordered_date_low,'MM/DD/RRRR HH24:MI:SS'); -- bug 5667753
      -- l_where_condition := l_where_condition||' Ordered Date >= :p6';
      END IF;

   ELSIF l_ordered_date_low IS NULL AND
         l_ordered_date_high IS NOT NULL
   THEN
      l_sql_stmt := l_sql_stmt || ' AND  OOH.ORDERED_DATE    <=  :p7';
      IF l_where_condition IS NULL
      THEN
	 l_where_condition := 'Ordered Date <= '||to_char(l_ordered_date_high,'MM/DD/RRRR HH24:MI:SS');  -- bug 5667753
      -- l_where_condition := 'Ordered Date <= :p7';
      ELSE
	 l_where_condition := l_where_condition||' AND Ordered Date <= '||to_char(l_ordered_date_high,'MM/DD/RRRR HH24:MI:SS');  -- bug 5667753
      -- l_where_condition := l_where_condition||' Ordered Date <= :p7';
      END IF;
   END IF;

--bug5702003

   IF l_creation_date_low IS NOT NULL AND
      l_creation_date_high IS NOT NULL
   THEN
      l_sql_stmt := l_sql_stmt || ' AND  OOH.CREATION_DATE   >=  :p8';
      l_sql_stmt := l_sql_stmt || ' AND  OOH.CREATION_DATE   <=  :p9';
      IF l_where_condition IS NULL
      THEN
	 l_where_condition := 'Creation Date Between '||to_char(l_creation_date_low,'MM/DD/RRRR HH24:MI:SS')||' AND '||to_char(l_creation_date_high,'MM/DD/RRRR HH24:MI:SS'); -- bug 5667753
      -- l_where_condition := 'Creation Date Between :p8 AND :p9';
      ELSE
	 l_where_condition := l_where_condition|| ' AND Creation Date Between '||to_char(l_creation_date_low,'MM/DD/RRRR HH24:MI:SS')||' AND '||to_char(l_creation_date_high,'MM/DD/RRRR HH24:MI:SS'); -- bug 5667753
      -- l_where_condition := l_where_condition|| ' Creation Date Between :p8 AND p9';
      END IF;

   ELSIF l_creation_date_low IS NOT NULL AND
         l_creation_date_high IS NULL
   THEN
      l_sql_stmt := l_sql_stmt || ' AND  OOH.CREATION_DATE   >=  :p8';
      IF l_where_condition IS NULL
      THEN
	 l_where_condition := 'Creation Date >= '||to_char(l_creation_date_low,'MM/DD/RRRR HH24:MI:SS'); -- bug 5667753
      -- l_where_condition := 'Creation Date >= :p8';
      ELSE
	 l_where_condition := l_where_condition||' AND Creation Date >= '||to_char(l_creation_date_low,'MM/DD/RRRR HH24:MI:SS'); -- bug 5667753
      -- l_where_condition := l_where_condition||' Creation Date >= :p8';
      END IF;

   ELSIF l_creation_date_low IS NULL AND
         l_creation_date_high IS NOT NULL
   THEN
      l_sql_stmt := l_sql_stmt || ' AND  OOH.CREATION_DATE   <=  :p9';
      IF l_where_condition IS NULL
      THEN
	 l_where_condition := 'Creation Date <= '||to_char(l_creation_date_high,'MM/DD/RRRR HH24:MI:SS'); -- bug 5667753
      -- l_where_condition := 'Creation Date <= :p9';
      ELSE
	 l_where_condition := l_where_condition||' AND Creation Date <= '||to_char(l_creation_date_high,'MM/DD/RRRR HH24:MI:SS'); -- bug 5667753
      -- l_where_condition := l_where_condition||' Creation Date <= :p9';
      END IF;
   END IF;

   -- end SQL literal changes

	-- Purge Changes for 11i.10
   IF OE_CODE_CONTROL.Code_Release_Level  >= '110510' AND
      OE_CONTRACTS_UTIL.Check_License = 'Y'  AND
      p_include_contractual_orders IS NOT NULL
   THEN
      l_where_condition := l_where_condition||
                         'Purge Orders with Contract Terms = '||p_include_contractual_orders;
   END IF;


   fnd_file.put_line(FND_FILE.LOG,'Parameters :');
   fnd_file.put_line(FND_FILE.LOG,'             Organization Id : '|| p_organization_id);
   fnd_file.put_line(FND_FILE.LOG,'             Purge Set Name : '||p_purge_set_name);
   fnd_file.put_line(FND_FILE.LOG,'             Purge Set Description : '||p_purge_set_description);
   fnd_file.put_line(FND_FILE.LOG,'             Order Number Low : '||to_char(p_order_number_low));
   fnd_file.put_line(FND_FILE.LOG,'             Order Number High : '||to_char(p_order_number_high));
   fnd_file.put_line(FND_FILE.LOG,'             Order Order Type : '||l_order_type_name);
   fnd_file.put_line(FND_FILE.LOG,'             Order Category : '||p_order_category);
   fnd_file.put_line(FND_FILE.LOG,'             Customer Name : '||l_customer_name);
   fnd_file.put_line(FND_FILE.LOG,'             Order Date Low : '||to_char(l_ordered_date_low,'MM/DD/RRRR HH24:MI:SS'));
   fnd_file.put_line(FND_FILE.LOG,'             Order Date High : '||to_char(l_ordered_date_high,'MM/DD/RRRR HH24:MI:SS'));
   fnd_file.put_line(FND_FILE.LOG,'             Creation Date Low : '||to_char(l_creation_date_low,'MM/DD/RRRR HH24:MI:SS'));
   fnd_file.put_line(FND_FILE.LOG,'             Creation Date High : '||to_char(l_creation_date_high,'MM/DD/RRRR HH24:MI:SS'));
   fnd_file.put_line(FND_FILE.LOG,'             Purge Orders with Contract Terms: '||p_include_contractual_orders);

   oe_debug_pub.add('Where Condition : '||l_where_condition);

   OE_Order_Purge_PVT.Insert_Purge_Set
                (
                p_purge_set_name                        =>      p_purge_set_name,
                p_purge_set_description         =>      p_purge_set_description,
                p_purge_set_request_Id          =>      1,
                p_purge_set_submit_datetime =>  SYSDATE,
                p_selected_ids                          =>      l_selected_ids,
                p_count_selected                        =>      0,
                p_where_condition                       =>      l_where_condition,
                p_created_by                            =>      FND_GLOBAL.USER_ID,
                p_last_updated_by                       =>      FND_GLOBAL.USER_ID,
                x_purge_set_id                          =>      l_purge_set_id
                );



   l_sql_cursor := DBMS_SQL.Open_Cursor;

   DBMS_SQL.PARSE(l_sql_cursor, l_sql_stmt, DBMS_SQL.NATIVE);

   --Binding the variables
   IF p_order_number_low is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE (l_sql_cursor, ':p1', p_order_number_low);
   END IF;
   IF p_order_number_high is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE (l_sql_cursor, ':p2', p_order_number_high);
   END IF;
   IF p_order_type_id is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE (l_sql_cursor, ':p3', p_order_type_id);
   END IF;
   IF p_order_category is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE (l_sql_cursor, ':p4', p_order_category);
   END IF;
   IF p_customer_id is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE (l_sql_cursor, ':p5', p_customer_id);
   END IF;
   IF l_ordered_date_low is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE (l_sql_cursor, ':p6', l_ordered_date_low);
   END IF;
   IF l_ordered_date_high is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE (l_sql_cursor, ':p7', l_ordered_date_high);
   END IF;
   IF l_creation_date_low is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE (l_sql_cursor, ':p8', l_creation_date_low);
   END IF;
   IF l_creation_date_high is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE (l_sql_cursor, ':p9', l_creation_date_high);
   END IF;

   DBMS_SQL.DEFINE_COLUMN (l_sql_cursor,1,l_header_id);
   DBMS_SQL.DEFINE_COLUMN (l_sql_cursor,2,l_order_number);
   DBMS_SQL.DEFINE_COLUMN (l_sql_cursor,3,l_order_type_name,30);
   DBMS_SQL.DEFINE_COLUMN (l_sql_cursor,4,l_sold_to_org_id);
   DBMS_SQL.DEFINE_COLUMN (l_sql_cursor,5,l_price_list_id);
   DBMS_SQL.DEFINE_COLUMN (l_sql_cursor,6,l_quote_number);
   DBMS_SQL.DEFINE_COLUMN (l_sql_cursor,7,l_flow_status_code,30);
   DBMS_SQL.DEFINE_COLUMN (l_sql_cursor,8,l_upgraded_flag,1);

   l_dummy := DBMS_SQL.execute(l_sql_cursor);

   LOOP



        IF DBMS_SQL.FETCH_ROWS(l_sql_cursor) = 0 THEN
           EXIT;
        END IF;

        DBMS_SQL.COLUMN_VALUE (l_sql_cursor,1,l_header_id);
        DBMS_SQL.COLUMN_VALUE (l_sql_cursor,2,l_order_number);
        DBMS_SQL.COLUMN_VALUE (l_sql_cursor,3,l_order_type_name);
        DBMS_SQL.COLUMN_VALUE (l_sql_cursor,4,l_sold_to_org_id);
        DBMS_SQL.COLUMN_VALUE (l_sql_cursor,5,l_price_list_id);
        DBMS_SQL.COLUMN_VALUE (l_sql_cursor,6,l_quote_number);
        DBMS_SQL.COLUMN_VALUE (l_sql_cursor,7,l_flow_status_code);
        DBMS_SQL.COLUMN_VALUE (l_sql_cursor,8,l_upgraded_flag);

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Order Number : '||to_char(l_order_number));
        END IF;


                IF  OE_CODE_CONTROL.Code_Release_Level  >= '110510' THEN

                    l_purge := 'Y';

                    IF OE_CONTRACTS_UTIL.Check_License = 'Y' THEN

                           IF p_include_contractual_orders  = 'N' THEN

                              IF OE_CONTRACTS_UTIL.Terms_Exists
                                           (  p_doc_type  =>   'O'
                                            , p_doc_id    =>   l_header_id) = 'Y' THEN

                                 l_purge := 'N';

                                 OE_DEBUG_PUB.Add('Skip the Order:'||l_header_id);

                              END IF;
                            END IF;
                    END IF;

                    IF l_purge = 'Y' THEN

                       check_and_get_detail(l_purge_set_id
                                           ,l_header_id
                                           ,l_order_number
                                           ,l_order_type_name
                                           ,l_sold_to_org_id
                                           ,l_price_list_id
                                           ,l_quote_number
                                           ,l_flow_status_code
                                           ,l_upgraded_flag);

                       l_rec_count      := l_rec_count + 1;

                       IF  l_rec_count >= l_orders_per_commit THEN
                           COMMIT;
                           l_rec_count := 0;
                       END IF;

                     END IF;

                ELSE
                      Check_And_Get_Detail(l_purge_set_id
                                              ,l_header_id
                                              ,l_order_number
                                              ,l_order_type_name
                                              ,l_sold_to_org_id
                                              ,l_price_list_id);


                              l_rec_count       := l_rec_count + 1;

                              IF  l_rec_count >= l_orders_per_commit THEN
                                  COMMIT;
                                  l_rec_count := 0;
                              END IF;

                  END IF;

   END LOOP;

        DBMS_SQL.CLOSE_CURSOR(l_sql_cursor);
        OE_DEBUG_PUB.Add('before update='|| l_purge_set_id);

        UPDATE OE_PURGE_SETS
        SET purge_processed = 'Y'
        WHERE purge_set_id =  l_purge_set_id;

        COMMIT;

        OE_DEBUG_PUB.Add('after update='|| to_char(SQL%ROWCOUNT));
        OE_DEBUG_PUB.Add('End');


EXCEPTION
   WHEN OTHERS THEN
        l_dummy := DBMS_SQL.LAST_ERROR_POSITION;
        fnd_file.put_line(FND_FILE.LOG,'At_Position '||l_dummy);
        fnd_file.put_line(FND_FILE.LOG,'*** Error In Generate purge set ** '||substr(sqlerrm,1,300));

End Select_Where_Cond_Purge;


/*--------------------------------------------------------------------------------------------------------
Procedure       : Select_Where_Cond_Purge_Quote
Description     : Called from Quote Purge Selection concurrent program. Based on
                  the parameters it will construct the where condition. Call Insert_Purge_Set.
                  Calls Check_And_Get_Detail for every record satisfying the where condition.
                  DBMS_SQL Package is being used for building the where condition for optimization.
Change Record   : Version 1
-------------------------------------------------------------------------------------------------------------*/


Procedure Select_Where_Cond_Purge_Quote
(
 ERRBUF                  OUT NOCOPY /* file.sql.39 change */     VARCHAR2
,RETCODE                 OUT NOCOPY /* file.sql.39 change */     VARCHAR2
,p_organization_id       IN      NUMBER
,p_purge_set_name        IN      VARCHAR2
,p_purge_set_description IN      VARCHAR2
,p_quote_number_low      IN      NUMBER
,p_quote_number_high     IN      NUMBER
,p_order_type_id         IN      NUMBER
,p_customer_id           IN      NUMBER
,p_quote_date_low        IN      VARCHAR2
,p_quote_date_high       IN      VARCHAR2
,p_creation_date_low     IN      VARCHAR2
,p_creation_date_high    IN      VARCHAR2
,p_offer_exp_date_low    IN      VARCHAR2
,p_offer_exp_date_high   IN      VARCHAR2
,p_purge_exp_quotes      IN      VARCHAR2
,p_purge_lost_quotes     IN      VARCHAR2
)
IS
 l_sql_stmt             VARCHAR2(4000) := NULL;
 l_where_condition      VARCHAR2(4000) := NULL ;
 l_creation_date_low    DATE;
 l_quote_date_high      DATE;
 l_quote_date_low       DATE;
 l_creation_date_high   DATE;
 l_offer_exp_date_low   DATE;
 l_offer_exp_date_high  DATE;
 l_order_type_name      VARCHAR2(30);
 l_header_id            NUMBER;
 l_quote_number         NUMBER;
 l_expiration_date      DATE;
 l_flow_status_code     VARCHAR2(30);
 l_upgraded_flag        VARCHAR2(1);
 l_sold_to_org_id       NUMBER;
 l_price_list_id        NUMBER;
 l_purge_set_id         NUMBER;
 l_selected_ids         SELECTED_IDS_TBL;
 l_customer_name        VARCHAR2(50);
 l_orders_per_commit    NUMBER := 10;
 l_rec_count            NUMBER := 0;
 l_sql_cursor           INTEGER;
 l_dummy                NUMBER;
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 l_org_id                NUMBER;

    CURSOR cur_get_org_for_ord_type IS
           SELECT org_id
           FROM OE_ORDER_TYPES_V  --MOAC view based on multiple objects
           WHERE order_type_id = p_order_type_id;

BEGIN
    --Bug #4220950
    ERRBUF  := '';
    RETCODE := 0;

  -- Begining MOAC Changes

     IF p_organization_id IS NOT NULL THEN

     -- Setting a Single Org access.

       MO_GLOBAL.set_policy_context ('S', p_organization_id);

     ELSIF p_organization_id IS NULL THEN

      --
      -- If p_organization_id is NULL, then check if the p_order_type_id is NULL.
      -- If it is not NULL then get the org_id for this assosiated transaction type
      -- If the p_order_type_id is NULL the the Multiple Org access is set.
      --

          IF p_order_type_id IS NOT NULL THEN

             OPEN  cur_get_org_for_ord_type;
             FETCH cur_get_org_for_ord_type INTO l_org_id;
             CLOSE cur_get_org_for_ord_type;

           -- Setting a Single Org access.

	      MO_GLOBAL.set_policy_context ('S', l_org_id);

           ELSE
            -- Setting a Multiple Org access.

	       MO_GLOBAL.set_policy_context('M','');

	   END IF;
        END IF;


 -- End MOAC Changes

  l_sql_stmt  :=
             ' SELECT    OOH.HEADER_ID,
                         OOH.QUOTE_NUMBER,
                         OOT.NAME,
                         OOH.SOLD_TO_ORG_ID,
                         OOH.PRICE_LIST_ID,
                         OOH.EXPIRATION_DATE,
                         OOH.FLOW_STATUS_CODE,
                         OOH.UPGRADED_FLAG
                FROM     OE_ORDER_HEADERS_ALL OOH,
                         OE_ORDER_TYPES_V OOT  --MOAC view based on multiple objects
                WHERE    OOH.ORDER_TYPE_ID = OOT.ORDER_TYPE_ID
                AND      NVL(OOH.TRANSACTION_PHASE_CODE,''F'')=''N''';


   IF l_debug_level  > 0 THEN
      OE_DEBUG_PUB.Add('Inside select_where_cond_quote');
   END IF;


   SELECT       fnd_date.canonical_to_date(p_offer_exp_date_low),
                fnd_date.canonical_to_date(p_offer_exp_date_high),
                fnd_date.canonical_to_date(p_creation_date_low),
                fnd_date.canonical_to_date(p_creation_date_high),
                fnd_date.canonical_to_date(p_quote_date_low),
                fnd_date.canonical_to_date(p_quote_date_high)
   INTO         l_offer_exp_date_low,
                l_offer_exp_date_high,
                l_creation_date_low,
                l_creation_date_high,
                l_quote_date_low,
                l_quote_date_high
   FROM         DUAL;


   --Quote Number Range

   IF    p_quote_number_low is NOT NULL AND p_quote_number_high is NOT NULL THEN
         l_sql_stmt := l_sql_stmt || ' AND  OOH.QUOTE_NUMBER    >=  :p1';
         l_sql_stmt := l_sql_stmt || ' AND  OOH.QUOTE_NUMBER    <=  :p2';
	 l_where_condition := 'Quote Number between '||to_char(p_quote_number_low)||' AND '||to_char(p_quote_number_high); -- bug 5667753
   --    l_where_condition := 'Quote Number between :p1 AND :p2';
   ELSIF p_quote_number_low is NULL AND p_quote_number_high is NOT NULL THEN
         l_sql_stmt := l_sql_stmt || ' AND  OOH.QUOTE_NUMBER    <=  :p2';
	 l_where_condition := 'Quote Number <= '||to_char(p_quote_number_high); -- bug 5667753
   --    l_where_condition := 'Quote Number <= :p2';
   ELSIF p_quote_number_low is NOT NULL AND p_quote_number_high is NULL THEN
         l_sql_stmt := l_sql_stmt || ' AND  OOH.QUOTE_NUMBER    >=  :p1';
	 l_where_condition := 'Quote Number >= '||to_char(p_quote_number_low); -- bug 5667753
   --    l_where_condition := 'Quote Number >= :p1';
   END IF;


   --Order Type
   IF   p_order_type_id is NOT NULL THEN
        SELECT NAME
        INTO   l_order_type_name
        FROM   OE_ORDER_TYPES_V  --MOAC view based on multiple objects
        WHERE  ORDER_TYPE_ID = p_order_type_id;

        l_sql_stmt := l_sql_stmt || ' AND  OOH.ORDER_TYPE_ID    =  :p3';


        IF l_where_condition IS NULL THEN
	   l_where_condition := 'Order Type = '||l_order_type_name;  -- bug 5667753
        -- l_where_condition := ' Order Type = :p11';
        ELSE
	   l_where_condition := l_where_condition || ' AND Order Type = '||l_Order_type_name;
        -- l_where_condition := l_where_condition || ' AND Order Type = :p11';
        END IF;
   END IF;


   --Customer
   IF   nvl(p_customer_id,0) <> 0 THEN

        SELECT    p.PARTY_NAME
        INTO      l_customer_name
        FROM      HZ_CUST_ACCOUNTS c,
                  HZ_PARTIES p
        WHERE     c.CUST_ACCOUNT_ID = p_customer_id
        AND       c.PARTY_ID = p.PARTY_ID;

        l_sql_stmt := l_sql_stmt || ' AND  OOH.SOLD_TO_ORG_ID   =  :p4';

        IF l_where_condition IS NULL THEN
	   l_where_condition := ' Customer = '||l_customer_name;  -- bug 5667753
        -- l_where_condition := ' Customer = :p12';
        ELSE
	   l_where_condition := l_where_condition|| ' AND Customer = '||l_customer_name;  -- bug 5667753
        -- l_where_condition := l_where_condition|| ' AND Customer = :p12';
        END IF;
   END IF;


   --Quote Date Range
   --Bug 5702003

   IF    l_quote_date_low  IS NOT NULL AND l_quote_date_high IS NOT NULL THEN
         l_sql_stmt := l_sql_stmt || ' AND  OOH.QUOTE_DATE    >=  :p5';
         l_sql_stmt := l_sql_stmt || ' AND  OOH.QUOTE_DATE    <=  :p6';

         IF l_where_condition IS NULL THEN
	    l_where_condition := 'Quote Date Between '||to_char(l_quote_date_low,'MM/DD/RRRR HH24:MI:SS')||' AND '||to_char(l_quote_date_high,'MM/DD/RRRR HH24:MI:SS');  -- bug 5667753
         -- l_where_condition := 'Quote Date Between :p5 and :p6';
         ELSE
	    l_where_condition := l_where_condition|| ' AND Quote Date Between '||to_char(l_quote_date_low,'MM/DD/RRRR HH24:MI:SS')||' AND '||to_char(l_quote_date_high,'MM/DD/RRRR HH24:MI:SS');  -- bug 5667753
         -- l_where_condition := l_where_condition|| ' AND Quote Date Between :p5 and :p6';
         END IF;

   ELSIF l_quote_date_low IS NOT NULL AND l_quote_date_high IS NULL THEN
         l_sql_stmt := l_sql_stmt || ' AND  OOH.QUOTE_DATE    >=  :p5';

         IF l_where_condition IS NULL THEN
	    l_where_condition := 'Quote Date >= '||to_char(l_quote_date_low,'MM/DD/RRRR HH24:MI:SS');  -- bug 5667753
         -- l_where_condition := 'Quote Date >= :p5';
         ELSE
	    l_where_condition := l_where_condition||' AND Quote Date >= '||to_char(l_quote_date_low,'MM/DD/RRRR HH24:MI:SS');  -- bug 5667753
         -- l_where_condition := l_where_condition|| ' AND Quote Date >= :p5';
         END IF;

   ELSIF l_quote_date_low IS NULL AND l_quote_date_high IS NOT NULL THEN
         l_sql_stmt := l_sql_stmt || ' AND  OOH.QUOTE_DATE    <=  :p6';

         IF l_where_condition IS NULL THEN
	    l_where_condition := 'Quote Date <= '||to_char(l_quote_date_high,'MM/DD/RRRR HH24:MI:SS');  -- bug 5667753
         -- l_where_condition := 'Quote Date <= :p6';
         ELSE
	    l_where_condition := l_where_condition||' AND Quote Date <= '||to_char(l_quote_date_high,'MM/DD/RRRR HH24:MI:SS'); -- bug 5667753
         -- l_where_condition := l_where_condition|| ' AND Quote Date >= :p6';
         END IF;
   END IF;


   --Creation date Range
   --Bug5702003

   IF    l_creation_date_low  IS NOT NULL AND l_creation_date_high IS NOT NULL THEN
         l_sql_stmt := l_sql_stmt || ' AND  OOH.CREATION_DATE   >=  :p7';
         l_sql_stmt := l_sql_stmt || ' AND  OOH.CREATION_DATE   <=  :p8';

         IF l_where_condition IS NULL THEN
	    l_where_condition := 'Quote Creation Date Between '||to_char(l_creation_date_low,'MM/DD/RRRR HH24:MI:SS')||' AND '||to_char(l_creation_date_high,'MM/DD/RRRR HH24:MI:SS');  -- bug 5667753
         -- l_where_condition := 'Quote Creation Date Between :p7 and :p8';
         ELSE
	    l_where_condition := l_where_condition|| ' AND Quote Creation Date Between '||to_char(l_creation_date_low,'MM/DD/RRRR HH24:MI:SS')||' AND '||to_char(l_creation_date_high,'MM/DD/RRRR HH24:MI:SS'); -- bug 5667753
         -- l_where_condition := l_where_condition|| ' AND Quote Creation Date Between :p7 and :p8';
         END IF;

   ELSIF l_creation_date_low IS NOT NULL AND l_creation_date_high IS NULL THEN
         l_sql_stmt := l_sql_stmt || ' AND  OOH.CREATION_DATE   >=  :p7';

         IF l_where_condition IS NULL THEN
	    l_where_condition := 'Quote Creation Date >= '||to_char(l_creation_date_low,'MM/DD/RRRR HH24:MI:SS'); -- bug 5667753
         -- l_where_condition := 'Quote Creation Date >= :p7';
         ELSE
	    l_where_condition := l_where_condition||' AND Quote Creation Date >= '||to_char(l_creation_date_low,'MM/DD/RRRR HH24:MI:SS');  -- bug 5667753
         -- l_where_condition := l_where_condition|| ' AND Quote Creation Date >= :p7';
         END IF;

   ELSIF l_creation_date_low IS NULL AND l_creation_date_high IS NOT NULL THEN
         l_sql_stmt := l_sql_stmt || ' AND  OOH.CREATION_DATE   <=  :p8';

         IF l_where_condition IS NULL THEN
	    l_where_condition := 'Quote Creation Date <= '||to_char(l_creation_date_high,'MM/DD/RRRR HH24:MI:SS'); -- bug 5667753
         -- l_where_condition := 'Quote Creation Date <= :p8';
         ELSE
	    l_where_condition := l_where_condition||' AND Quote Creation Date <= '||to_char(l_creation_date_high,'MM/DD/RRRR HH24:MI:SS');  -- bug 5667753
         -- l_where_condition := l_where_condition|| ' AND Quote Creation Date >= :p8';
         END IF;
   END IF;


   --Offer Expiration Date Range
   --5702003

   IF    l_offer_exp_date_low  IS NOT NULL AND l_offer_exp_date_high IS NOT NULL THEN
         l_sql_stmt := l_sql_stmt || ' AND  OOH.EXPIRATION_DATE >=  :p9';
         l_sql_stmt := l_sql_stmt || ' AND  OOH.EXPIRATION_DATE <=  :p10';
         IF l_where_condition IS NULL THEN
	    l_where_condition := 'Quote Expiration Date Between '||to_char(l_offer_exp_date_low,'MM/DD/RRRR HH24:MI:SS')||' AND '||to_char(l_offer_exp_date_high,'MM/DD/RRRR HH24:MI:SS');  -- bug 5667753
         -- l_where_condition := 'Quote Expiration Date Between :p9 and :p10';
         ELSE
	    l_where_condition := l_where_condition|| ' AND Quote Expiration Date Between '||to_char(l_offer_exp_date_low,'MM/DD/RRRR HH24:MI:SS')||' AND '||to_char(l_offer_exp_date_high,'MM/DD/RRRR HH24:MI:SS');  -- bug 5667753
         -- l_where_condition := l_where_condition|| ' AND Quote Expiration Date Between :p9 and :p10';
         END IF;

   ELSIF l_offer_exp_date_low IS NOT NULL AND l_offer_exp_date_high IS NULL THEN
         l_sql_stmt := l_sql_stmt || ' AND  OOH.EXPIRATION_DATE >=  :p9';

         IF l_where_condition IS NULL THEN
	    l_where_condition := 'Quote Expiration Date >= '||to_char(l_offer_exp_date_low,'MM/DD/RRRR HH24:MI:SS');  -- bug 5667753
         -- l_where_condition := 'Quote Expiration Date >= :p9';
         ELSE
	    l_where_condition := l_where_condition||' AND Quote Expiration Date >= '||to_char(l_offer_exp_date_low,'MM/DD/RRRR HH24:MI:SS');  -- bug 5667753
         -- l_where_condition := l_where_condition|| ' AND Quote Expiration Date >= :p9';
         END IF;

   ELSIF l_offer_exp_date_low IS NULL AND l_offer_exp_date_high IS NOT NULL THEN
         l_sql_stmt := l_sql_stmt || ' AND  OOH.EXPIRATION_DATE <=  :p10';

         IF l_where_condition IS NULL THEN
	    l_where_condition := 'Quote Expiration Date <= '||to_char(l_offer_exp_date_high,'MM/DD/RRRR HH24:MI:SS');  -- bug 5667753
         -- l_where_condition := 'Quote Expiration Date <= :p10';
         ELSE
	    l_where_condition := l_where_condition||' AND Quote Expiration Date <= '||to_char(l_offer_exp_date_high,'MM/DD/RRRR HH24:MI:SS');  -- bug 5667753
            l_where_condition := l_where_condition|| ' AND Quote Expiration Date >= :p10';
         END IF;
   END IF;


   --To Purge only Expired Quotes
   IF   nvl(p_purge_exp_quotes,'Y')='Y' THEN
        IF l_where_condition IS NULL THEN
           l_where_condition := 'Purge Expired Quotes';
        ELSE
           l_where_condition := l_where_condition|| ' AND Purge Expired Quotes';
        END IF;
   END IF;


   --To Purge only Lost Quotes
   IF   nvl(p_purge_lost_quotes,'Y')='Y' THEN
        IF l_where_condition IS NULL THEN
           l_where_condition := 'Purge Lost Quotes';
        ELSE
           l_where_condition := l_where_condition|| ' AND Purge Lost Quotes';
        END IF;
   END IF;

   --The sql statement for Purge Expired and Lost Quotes.
   IF   nvl(p_purge_exp_quotes,'Y')='Y' THEN
        IF nvl(p_purge_lost_quotes,'Y') ='Y' THEN
           l_sql_stmt:= l_sql_stmt|| ' AND OOH.FLOW_STATUS_CODE IN (''LOST'',''OFFER_EXPIRED'')';
        ELSE
           l_sql_stmt:=l_sql_stmt||' AND OOH.FLOW_STATUS_CODE=''OFFER_EXPIRED''';
        END IF;
   ELSE
        IF nvl(p_purge_lost_quotes,'Y')='Y' THEN
           l_sql_stmt:=l_sql_stmt||' AND OOH.FLOW_STATUS_CODE=''LOST''';
        END IF;
   END IF;


   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Where Condition : '||l_where_condition);
      oe_debug_pub.add('Cursor Query : '||l_sql_stmt);
   END IF;
   OE_ORDER_PURGE_PVT.Insert_Purge_Set
                (
                p_purge_set_name                        =>      p_purge_set_name,
                p_purge_set_description                 =>      p_purge_set_description,
                p_purge_set_request_Id                  =>      1,
                p_purge_set_submit_datetime             =>      SYSDATE,
                p_selected_ids                          =>      l_selected_ids,
                p_count_selected                        =>      0,
                p_where_condition                       =>      l_where_condition,
                p_created_by                            =>      FND_GLOBAL.USER_ID,
                p_last_updated_by                       =>      FND_GLOBAL.USER_ID,
                x_purge_set_id                          =>      l_purge_set_id
                );


   l_sql_cursor := DBMS_SQL.Open_Cursor;

   DBMS_SQL.PARSE(l_sql_cursor, l_sql_stmt, DBMS_SQL.NATIVE);


   --Binding the variables
   IF p_quote_number_low is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE (l_sql_cursor, ':p1', p_quote_number_low);
   END IF;
   IF p_quote_number_high is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE (l_sql_cursor, ':p2', p_quote_number_high);
   END IF;
   IF p_order_type_id is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE (l_sql_cursor, ':p3', p_order_type_id);
   END IF;
   IF p_customer_id is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE (l_sql_cursor, ':p4', p_customer_id);
   END IF;
   IF p_quote_date_low is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE (l_sql_cursor, ':p5', l_quote_date_low);
   END IF;
   IF p_quote_date_high is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE (l_sql_cursor, ':p6', l_quote_date_high);
   END IF;
   IF p_creation_date_low is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE (l_sql_cursor, ':p7', l_creation_date_low);
   END IF;
   IF p_creation_date_high is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE (l_sql_cursor, ':p8', l_creation_date_high);
   END IF;
   IF p_offer_exp_date_low is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE (l_sql_cursor, ':p9', l_offer_exp_date_low);
   END IF;
   IF p_offer_exp_date_high is NOT NULL THEN
      DBMS_SQL.BIND_VARIABLE (l_sql_cursor, ':p10', l_offer_exp_date_high);
   END IF;

   DBMS_SQL.DEFINE_COLUMN (l_sql_cursor,1,l_header_id);
   DBMS_SQL.DEFINE_COLUMN (l_sql_cursor,2,l_quote_number);
   DBMS_SQL.DEFINE_COLUMN (l_sql_cursor,3,l_order_type_name,30);
   DBMS_SQL.DEFINE_COLUMN (l_sql_cursor,4,l_sold_to_org_id);
   DBMS_SQL.DEFINE_COLUMN (l_sql_cursor,5,l_price_list_id);
   DBMS_SQL.DEFINE_COLUMN (l_sql_cursor,6,l_expiration_date);
   DBMS_SQL.DEFINE_COLUMN (l_sql_cursor,7,l_flow_status_code,30);
   DBMS_SQL.DEFINE_COLUMN (l_sql_cursor,8,l_upgraded_flag,1);

   l_dummy := DBMS_SQL.execute(l_sql_cursor);

   LOOP

        IF DBMS_SQL.FETCH_ROWS(l_sql_cursor) = 0 THEN
           EXIT;
        END IF;

        DBMS_SQL.COLUMN_VALUE (l_sql_cursor,1,l_header_id);
        DBMS_SQL.COLUMN_VALUE (l_sql_cursor,2,l_quote_number);
        DBMS_SQL.COLUMN_VALUE (l_sql_cursor,3,l_order_type_name);
        DBMS_SQL.COLUMN_VALUE (l_sql_cursor,4,l_sold_to_org_id);
        DBMS_SQL.COLUMN_VALUE (l_sql_cursor,5,l_price_list_id);
        DBMS_SQL.COLUMN_VALUE (l_sql_cursor,6,l_expiration_date);
        DBMS_SQL.COLUMN_VALUE (l_sql_cursor,7,l_flow_status_code);
        DBMS_SQL.COLUMN_VALUE (l_sql_cursor,8,l_upgraded_flag);

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Quote Number : '||to_char(l_quote_number));
        END IF;

        Check_And_Get_Detail(l_purge_set_id
                          ,l_header_id
                          ,null
                          ,l_order_type_name
                          ,l_sold_to_org_id
                          ,l_price_list_id
                          ,l_quote_number
                          ,l_flow_status_code
                          ,l_upgraded_flag
                          ,l_expiration_date);

        l_rec_count     := l_rec_count + 1;
        IF l_rec_count >= l_orders_per_commit THEN
           COMMIT;
           l_rec_count := 0;
        END IF;
   END LOOP;

   DBMS_SQL.CLOSE_CURSOR(l_sql_cursor);

   IF l_debug_level  > 0 THEN
      OE_DEBUG_PUB.Add('before update='|| l_purge_set_id);
   END IF;

   UPDATE OE_PURGE_SETS
   SET    purge_processed = 'Y'
   WHERE  purge_set_id =  l_purge_set_id;

   COMMIT;

   IF l_debug_level  > 0 THEN
      OE_DEBUG_PUB.Add('after update='|| to_char(SQL%ROWCOUNT));
      OE_DEBUG_PUB.Add('End');
   END IF;


EXCEPTION
   WHEN OTHERS THEN
        l_dummy := DBMS_SQL.LAST_ERROR_POSITION;
        fnd_file.put_line(FND_FILE.LOG,'At_Position '||l_dummy);
        fnd_file.put_line(FND_FILE.LOG,'*** Error In Generate purge set ** '||substr(sqlerrm,1,300));
End Select_Where_Cond_Purge_Quote;


PROCEDURE Select_Ids_Purge
(
	p_purge_set_id		IN NUMBER
,	p_selected_ids_tbl	IN SELECTED_IDS_TBL
,	p_count_selected	IN NUMBER
,	p_orders_per_commit	IN NUMBER
)
IS
	l_order_number 			NUMBER := 0;
	l_order_type_name  		VARCHAR2(30);
	l_customer_number 		NUMBER := 0;
	l_price_list_id 		NUMBER := 0;
	l_error_message 		VARCHAR2(200);
	l_header_id     		NUMBER;
	l_rec_count			NUMBER := 0;
        l_quote_number                  NUMBER;
        l_expiration_date               DATE;
        l_flow_status_code              VARCHAR2(30);
        l_upgraded_flag                 VARCHAR2(1);
        l_transaction_phase_code        VARCHAR2(1);


BEGIN

	oe_debug_pub.Add('Entering OE_Order_Purge_PVT.Select_Ids_Purge : '||p_purge_set_id,1);

	FOR I IN 1..p_count_selected
	LOOP

		l_header_id := p_selected_ids_tbl(I);

		OE_DEBUG_PUB.Add('Header Id '||to_char(l_header_id));

                --Quote purge changes.Select the added fields
                --and transaction phase code

		SELECT  ooh.order_number
		,       oot.name
		,       ooh.sold_to_org_id
		,       ooh.price_list_id
                ,       ooh.quote_number
                ,       ooh.expiration_date
                ,       ooh.flow_status_code
                ,       ooh.upgraded_flag
                ,       ooh.transaction_phase_code
		INTO
			l_order_number
		,	l_order_type_name
		,	l_customer_number
		,	l_price_list_id
                ,       l_quote_number
                ,       l_expiration_date
                ,       l_flow_status_code
                ,       l_upgraded_flag
                ,       l_transaction_phase_code
		From 	oe_order_types_v 	oot,  --MOAC view based on multiple objects
			oe_order_headers_all     ooh

		WHERE
			ooh.header_id  = l_header_id
		AND 	ooh.order_type_id = oot.order_type_id;

                --Quote Purge Changes.To mask order number for a
                --quote and Expiration date for orders.

                IF      OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' THEN
                        IF nvl(l_transaction_phase_code,'F')='N' THEN
                           l_order_number   := Null;
                        ELSE
                           l_expiration_date:= Null;
                        END IF;
                        check_and_get_detail(p_purge_set_id
                                          ,l_header_id
                                          ,l_order_number
                                          ,l_order_type_name
                                          ,l_customer_number
                                          ,l_price_list_id
                                          ,l_quote_number
                                          ,l_flow_status_code
                                          ,l_upgraded_flag
                                          ,l_expiration_date);
		ELSE
                        check_and_get_detail(p_purge_set_id
                                          ,l_header_id
                                          ,l_order_number
                                          ,l_order_type_name
                                          ,l_customer_number
                                          ,l_price_list_id);
                END IF;
		l_rec_count := l_rec_count + 1;

		IF	l_rec_count >= p_orders_per_commit THEN
			COMMIT;
			l_rec_count := 0;
		END IF;

	END LOOP;


	OE_DEBUG_PUB.Add('before update='|| p_purge_set_id);

	UPDATE OE_PURGE_SETS
	SET purge_processed = 'Y'
	WHERE purge_set_id =  p_purge_set_id;

	COMMIT;

	OE_DEBUG_PUB.Add('after update='|| to_char(SQL%ROWCOUNT));

	oe_debug_pub.Add('Exiting OE_Order_Purge_PVT.Select_Ids_Purge : '||p_purge_set_id,1);

EXCEPTION
	WHEN OTHERS THEN
		fnd_file.put_line(FND_FILE.LOG,'*** Error In Generate purge set ** '||substr(sqlerrm,1,300));
END Select_Ids_Purge;

PROCEDURE Insert_Purge_Set
(
	p_purge_set_name 			IN	VARCHAR2
,	p_purge_set_description		IN 	VARCHAR2
,	p_purge_set_request_Id 		IN 	NUMBER
,	p_purge_set_submit_datetime IN 	DATE
,	p_selected_ids  			IN 	SELECTED_IDS_TBL
,	p_count_selected 			IN 	NUMBER
,	p_where_condition 			IN 	VARCHAR2
,	p_created_by      			IN 	NUMBER
,	p_last_updated_by 			IN 	NUMBER
,	x_purge_set_id				OUT NOCOPY /* file.sql.39 change */	NUMBER
)

IS
	l_purge_set_id		NUMBER;
	l_separator		VARCHAR2(1) := ',';
	l_selected_ids		CLOB;
	l_position		INTEGER := 1;
	l_buffer			VARCHAR2(32767);
	l_amount			BINARY_INTEGER := 32767;
	l_orders_per_commit	NUMBER;

BEGIN

	oe_debug_pub.add('Entering OE_Order_Purge_PVT.Insert_Purge_Set : '||p_purge_set_name,1);

	SELECT	OE_PURGE_SETS_S.NEXTVAL
	INTO	l_purge_set_id
	FROM	DUAL;

	l_orders_per_commit := FND_PROFILE.VALUE('OM_ORDERS_PURGE_PER_COMMIT');

	INSERT INTO OE_PURGE_SETS
	( 	PURGE_SET_ID
	,	PURGE_SET_NAME
	,	PURGE_SET_DESCRIPTION
	,	PURGE_SET_REQUEST_ID
	,	PURGE_SET_SUBMIT_DATETIME
	,	COUNT_SELECTED
	,	PURGE_PROCESSED
	,	PURGE_SET_PURGED
	,	WHERE_CONDITION
	,	ORDERS_PER_COMMIT
	,	SELECTED_IDS
	,	CREATION_DATE
	,	CREATED_BY
	,	LAST_UPDATE_DATE
	,	LAST_UPDATED_BY
	)
	VALUES
	( 	l_purge_set_id
	,	p_purge_set_name
	,	p_purge_set_description
	,	p_purge_set_request_Id
	,	p_purge_set_submit_datetime
	,	p_count_selected
	,	'N'
	,	'N'
	,	p_where_condition
	,	l_orders_per_commit
	,	EMPTY_CLOB()
	,	sysdate
	,	p_created_by
	,	sysdate
	,	p_last_updated_by);

	x_purge_set_id := l_purge_set_id;

	oe_debug_pub.add('Purge Set ID : '||to_char(l_purge_set_id));

	IF	p_count_selected <> 0 THEN

		SELECT	SELECTED_IDS
		INTO		l_selected_ids
		FROM		OE_PURGE_SETS
		WHERE 	PURGE_SET_ID = l_purge_set_id;

		DBMS_LOB.OPEN(l_selected_ids,DBMS_LOB.LOB_READWRITE);

		FOR	I	IN 1 .. p_count_selected
		LOOP
			IF	(length(l_buffer) + length(p_selected_ids(I))) > l_amount THEN
				oe_debug_pub.add('Reached the limit : '||to_char(length(l_buffer)));
				l_amount := length(l_buffer);
				DBMS_LOB.WRITE(l_selected_ids,l_amount,l_position,l_buffer);
				l_buffer := '';
				l_position := l_position + l_amount;
			END IF;

			IF	I = 1 THEN
				l_buffer := l_buffer || to_char(p_selected_ids(I));
			ELSE
				l_buffer := l_buffer||l_separator||to_char(p_selected_ids(I));
			END IF;

		END LOOP;

		oe_debug_pub.add('Length : '||to_char(length(l_buffer)));
		l_amount := length(l_buffer);
		DBMS_LOB.WRITE(l_selected_ids,l_amount,l_position,l_buffer);
		DBMS_LOB.CLOSE(l_selected_ids);

		oe_debug_pub.add('Value : '||l_buffer);

	END IF;

	oe_debug_pub.add('Exiting OE_Order_Purge_PVT.Insert_Purge_Set : '||to_char(x_purge_set_id),1);

END Insert_Purge_Set;

--Quote purge changes:
--1. Modified the signature
--2. Query Transaction Phase Code and make appropriate calls
--3. Added field in insert statement

PROCEDURE Check_And_Get_Detail
(
        p_purge_set_id          IN NUMBER
,       p_header_id             IN NUMBER
,       p_order_number          IN NUMBER
,       p_order_type_name       IN VARCHAR2
,       p_customer_number       IN NUMBER
,       p_price_list_id         IN NUMBER
,       p_quote_number          IN NUMBER       DEFAULT NULL
,       p_flow_status_code      IN VARCHAR2     DEFAULT NULL
,       p_upgraded_flag         IN VARCHAR2     DEFAULT NULL
,       p_expiration_date       IN DATE         DEFAULT NULL
)
IS

	l_return_status		 VARCHAR2(1) := FND_API.G_TRUE;
	l_error_message 	 VARCHAR2(2000);
	l_temp_mesg 		 VARCHAR2(2000);
	l_is_purgable  		 VARCHAR2(1);
	l_order_type_name	 VARCHAR2(30);
        l_flow_status            VARCHAR2(80);
        l_transaction_phase_code VARCHAR2(1);
        -- 3789233
        l_cnt                    NUMBER;

BEGIN

	oe_debug_pub.add('Entering OE_ORDER_PURGE_PVT.Check_And_Get_Detail : '||to_char(p_order_number));
   --Quote purge changes.To Select Transaction Phase code
   SELECT transaction_phase_code
   INTO   l_transaction_phase_code
   FROM   oe_order_headers
   WHERE  header_id=p_header_id;

   IF p_flow_status_code IS NOT NULL THEN
      SELECT meaning
      INTO   l_flow_status
      FROM   fnd_lookup_values lv
      WHERE  lv.lookup_code=p_flow_status_code
      AND    lookup_type='LINE_FLOW_STATUS'
      AND    LANGUAGE = userenv('LANG')
      AND    VIEW_APPLICATION_ID = 660
      AND    SECURITY_GROUP_ID =
      fnd_global.Lookup_Security_Group(lv.lookup_type,
                                             lv.view_application_id);
   END IF;

   IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510'
                        AND nvl(l_transaction_phase_code,'F')='N' THEN

        IF      l_return_status = FND_API.G_TRUE THEN

                FND_MESSAGE.SET_NAME('ONT','OE_PUR_OPEN_QUOTE');
                l_temp_mesg := FND_MESSAGE.GET_ENCODED;
                FND_MESSAGE.SET_ENCODED(l_temp_mesg);
                l_error_message := FND_MESSAGE.GET;
                l_return_status := OE_ORDER_PURGE_PVT.Check_Open_Quotes(p_header_id);

        END IF;

   ELSE
	IF 	l_return_status = FND_API.G_TRUE THEN
		FND_MESSAGE.SET_NAME('ONT','OE_PUR_OPEN_ORDER');
      	l_temp_mesg := FND_MESSAGE.GET_ENCODED;
		FND_MESSAGE.SET_ENCODED(l_temp_mesg);
	 	l_error_message := FND_MESSAGE.GET;
		--for Bug # 4516769
		l_return_status := OE_ORDER_PURGE_PVT.Check_Open_Orders
		( p_header_id);
	END IF;

	IF 	l_return_status = FND_API.G_TRUE THEN

    		SELECT otl.name
    		INTO   l_order_type_name
    		FROM   oe_transaction_types_tl otl,
           		oe_order_headers ooh
    		WHERE  otl.language = (select language_code
         		                 from fnd_languages
              		            where installed_flag = 'B')
    		AND    otl.transaction_type_id = ooh.order_type_id
    		AND    ooh.header_id = p_header_id;

		FND_MESSAGE.SET_NAME('ONT','OE_PUR_OPEN_INVOICES');
      	l_temp_mesg := FND_MESSAGE.GET_ENCODED;
		FND_MESSAGE.SET_ENCODED(l_temp_mesg);
	 	l_error_message := FND_MESSAGE.GET;
		l_return_status := OE_ORDER_PURGE_PVT.check_open_invoiced_orders
		( TO_CHAR(p_order_number), l_order_type_name );
	END IF;

	IF 	l_return_status = FND_API.G_TRUE THEN
		FND_MESSAGE.SET_NAME('ONT','OE_PUR_OPEN_RETURNS');
      	        l_temp_mesg := FND_MESSAGE.GET_ENCODED;
		FND_MESSAGE.SET_ENCODED(l_temp_mesg);
	 	l_error_message := FND_MESSAGE.GET;
		l_return_status := OE_ORDER_PURGE_PVT.check_open_returns
		(p_order_number, p_order_type_name);
	END IF;

	IF 	l_return_status = FND_API.G_TRUE THEN
		Check_Open_RMA_Receipts(p_header_id,
			l_return_status, l_error_message);
	END IF;

        -- 3789233
        IF      l_return_status = FND_API.G_TRUE THEN
                FND_MESSAGE.SET_NAME('ONT','OE_PUR_OPEN_DELIVERIES');
                l_temp_mesg := FND_MESSAGE.GET_ENCODED;
                FND_MESSAGE.SET_ENCODED(l_temp_mesg);
                l_error_message := FND_MESSAGE.GET;

                select count(*)
                into l_cnt
                from wsh_delivery_details dd,
                     oe_order_lines l
                where l.header_id = p_header_id
                and   dd.source_line_id = l.line_id
		AND   dd.org_id = l.org_id
                and   dd.source_code = 'OE'
                and   (nvl(dd.released_status, 'N') not in ('C', 'D') or
                       ( dd.released_status = 'C' and
                        ( nvl(dd.inv_interfaced_flag, 'N')  in ( 'N','P') or
                          nvl(dd.oe_interfaced_flag, 'N')  in ( 'N','P')
                        )
                       )
                      );
                IF l_cnt > 0 THEN
                  l_return_status := FND_API.G_FALSE;
                END IF;
        END IF;

        --      Purge Changes for 11i.10

        IF      l_return_status = FND_API.G_TRUE THEN

                IF PO_CODE_RELEASE_GRP.Current_Release >=
                           PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J AND
                              OE_CODE_CONTROL.Code_Release_Level  >= '110510' THEN

                    l_return_status :=
                         OE_ORDER_PURGE_PVT.Check_Open_PO_Reqs_Dropship
                                           (p_header_id       => p_header_id
                                           );

                    IF l_return_status = FND_API.G_FALSE THEN

                       FND_MESSAGE.SET_NAME('ONT','OE_PURGE_OPEN_PO_REQ');
      	               l_temp_mesg := FND_MESSAGE.GET_ENCODED;
		       FND_MESSAGE.SET_ENCODED(l_temp_mesg);
	               l_error_message := FND_MESSAGE.GET;

                    END IF;

                END IF;
        END IF;
  END IF;

	IF 	l_return_status = FND_API.G_TRUE THEN
		l_error_message := NULL;
		l_is_purgable := 'Y' ;
	ELSE
		l_error_message := l_error_message;
		OE_DEBUG_PUB.Add(l_error_message);
		l_is_purgable := 'N';
	END IF;

        INSERT INTO OE_PURGE_ORDERS
        (       PURGE_SET_ID,
                HEADER_ID,
                ORDER_NUMBER,
                QUOTE_NUMBER,
                ORDER_TYPE_NAME,
                CUSTOMER_NUMBER,
                PRICE_LIST_ID,
                IS_PURGABLE,
                IS_PURGED,
                ERROR_TEXT,
                FLOW_STATUS,
                EXPIRATION_DATE,
                UPGRADED_FLAG,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGON,
                REQUEST_ID,
                PROGRAM_ID,
                PROGRAM_APPLICATION_ID)
        VALUES (  p_purge_set_id
                , p_header_id
                , p_order_number
                , p_quote_number
                , p_order_type_name
                , p_customer_number
                , p_price_list_id
                , l_is_purgable
                ,'N'
                , l_error_message
                , l_flow_status
                , p_expiration_date
                , p_upgraded_flag
                , sysdate
                , FND_GLOBAL.USER_ID
                , sysdate
                , FND_GLOBAL.LOGIN_ID
                , NULL
                , NULL
                , 0
                ,660);


	oe_debug_pub.add('Exiting OE_ORDER_PURGE_PVT.Check_And_Get_Detail : '||to_char(p_order_number));

END check_and_get_detail;

--
--  As per the MOAC changes the 'Order Purge Job' would be MULTI Organizational concurrent Request.
--  But the organization_id is not passed as this would be always passed as NULL.
--

PROCEDURE Submit_Purge
(
        p_dummy1 		IN VARCHAR2
,	p_dummy2 		IN VARCHAR2
, 	p_purge_set_id	IN NUMBER
)

IS

	l_header_id   		NUMBER := 0;
	l_return_status 	VARCHAR2(1);
	l_number_of_rec		NUMBER := 0;
	l_orders_per_commit	NUMBER;
        l_number_of_orders      NUMBER := 0;      --added for bug 3680441
        l_purged_success        NUMBER := 0;      --added for bug 3680441
        l_purge_failure         NUMBER := 0;      --added for bug 3680441
        l_purge_set_name        OE_PURGE_SETS.PURGE_SET_NAME%TYPE;
	l_savepoint_est         VARCHAR2(1) := 'N';

	CURSOR c_purge_orders IS
	SELECT header_id
	FROM  oe_purge_orders
	Where purge_set_id = p_purge_set_id
	AND   NVL(is_purgable,'N') = 'Y'
	AND	 NVL(is_purged,'N') = 'N';

       CURSOR cur_logged_in_user IS
         SELECT created_by
	    FROM oe_purge_orders
	    WHERE purge_set_id = p_purge_set_id;

    l_created_by    oe_purge_sets.created_by%type;
BEGIN

	oe_debug_pub.add('Entering OE_ORDER_PURGE_PVT.Submit_Purge : '||to_char(p_purge_set_id));
	fnd_file.put_line(FND_FILE.LOG,'Parameters :');
	fnd_file.put_line(FND_FILE.LOG,'Purge Set Name : '||p_purge_set_id);

        OPEN cur_logged_in_user;
	FETCH cur_logged_in_user INTO l_created_by;
	CLOSE cur_logged_in_user;


	IF  l_created_by <> FND_GLOBAL.USER_ID THEN

          FND_MESSAGE.SET_NAME ('ONT', 'ONT_ONLY_CREATOR_CAN_PURGE');
          FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());
	  APP_EXCEPTION.RAISE_EXCEPTION;

	END IF;


	SELECT	orders_per_commit, purge_set_name
	INTO	l_orders_per_commit, l_purge_set_name
	FROM	OE_PURGE_SETS
	WHERE	purge_set_id = p_purge_set_id
        AND     created_by = fnd_global.user_id;

	IF	nvl(l_orders_per_commit,0) = 0 THEN
		l_orders_per_commit := 1;
		oe_debug_pub.add('Orders per commit is not defined ');
	END IF;


	oe_debug_pub.add('Orders per commit : '||to_char(l_orders_per_commit),1);

        IF l_purge_set_name IS NOT NULL THEN

            --
            -- This code is added because we query the records form the Secured
            -- Synonym. The Secured synonym would require the Context to be set else
            -- they would not fetch any data. So the data of all the org attached to -
            -- the responsibility would be fetched, the segration would be only based
            -- on the created_by
            --

            --
            -- We are purging the data based on the crested_by of the Purge Set and
            -- Orders in the purge set, so we are not restricting on a Single Org.
            --

              MO_GLOBAL.set_policy_context('M','');


        --added for bug 3680441
        SELECT count(*)
        INTO   l_number_of_orders
        FROM   oe_purge_orders
        where  purge_set_id = p_purge_set_id;

	OPEN c_purge_orders;

	LOOP

		SAVEPOINT	ORDER_HEADER;
		l_savepoint_est := 'Y';

		FETCH c_purge_orders INTO  l_header_id;
		OE_DEBUG_PUB.Add('loop purging='||to_char(l_header_id));

		EXIT WHEN c_purge_orders%NOTFOUND OR c_purge_orders%NOTFOUND IS NULL;
        -- end of fetch or empty cursor

		BEGIN


			OE_ORDER_PURGE_PVT.oe_purge_headers
							(p_purge_set_id,
							l_header_id,
							l_return_status);

			oe_debug_pub.add('Returned from oe_purge_orders : '||l_return_status);

		EXCEPTION
			WHEN OTHERS THEN
				NULL;

		END;

		BEGIN

			IF 	l_return_status = FND_API.G_RET_STS_SUCCESS THEN
				OE_ORDER_PURGE_PVT.oe_purge_lines
								(p_purge_set_id,
								l_header_id,
								l_return_status
								);
				oe_debug_pub.add('Returned from oe_purge_lines : '||l_return_status);

			END IF;

		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;

		IF 	l_return_status = FND_API.G_RET_STS_SUCCESS THEN

			UPDATE OE_PURGE_ORDERS
			SET IS_PURGED = 'Y'
			WHERE purge_set_id = p_purge_set_id
			AND   header_id  = l_header_id
			AND   created_by = fnd_global.user_id;

			l_number_of_rec := l_number_of_rec + 1;
                        l_purged_success := l_purged_success + 1;  --added for bug 3680441

			IF 	l_number_of_rec = l_orders_per_commit THEN
				COMMIT;
				l_savepoint_est := 'N';
				l_number_of_rec := 0;
			END IF;

		ELSE
			NULL;
		END IF;

	END LOOP;

	CLOSE c_purge_orders;
	oe_debug_pub.add('before setting purge_Set_purge');

	UPDATE	OE_PURGE_SETS
	SET		PURGE_SET_PURGED = 'Y',
			LAST_UPDATE_DATE = SYSDATE,
			LAST_UPDATED_BY  = FND_GLOBAL.USER_ID,
			LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
	WHERE 	        PURGE_SET_ID = p_purge_set_id
	            AND CREATED_BY   = fnd_global.user_id;
	COMMIT;
        --added for bug 3680441
        l_purge_failure := l_number_of_orders - l_purged_success;

        IF ( l_purge_failure > 0 )THEN
        FND_MESSAGE.SET_NAME ('ONT', 'ONT_FAILED_ORD_SECURITY');
        FND_MESSAGE.SET_TOKEN ('SNAME',l_purge_set_name );
        FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());
	END IF;

        FND_FILE.PUT_LINE(FND_FILE.LOG,'Number of orders/quotes selected for purge : '||l_number_of_orders);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Number of orders/quotes purged successfully : '||l_purged_success);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Number of orders/quotes failed purge : '||l_purge_failure);
        --end of change for bug 3680441
	oe_debug_pub.add('Exiting OE_ORDER_PURGE_PVT.Submit_Purge : ');

    -- Begining of MOAC Changes
      ELSE
	 fnd_file.put_line(FND_FILE.LOG,'Orders could not be Purged as the Purge Set selected is Created by another User.');
      END IF;
    -- End of MOAC Changes

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
		l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF l_savepoint_est = 'Y' THEN
		 ROLLBACK TO SAVEPOINT ORDER_HEADER;
                END IF;

		OE_DEBUG_PUB.Add('rollback 2');
		record_errors
		(
		l_return_status,
		p_purge_set_id,
		l_header_id ,
		'ORDPUR: '||substr(sqlerrm,1,200)
		);
		CLOSE c_purge_orders;

END Submit_Purge;

PROCEDURE Delete_Purge_Set
(
	p_purge_set_id 		IN 	NUMBER
,	x_return_status		OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS

	Cursor	c_purge_set is
	SELECT	PURGE_SET_NAME,
			PURGE_SET_PURGED
	FROM OE_PURGE_SETS
	WHERE purge_set_id = p_purge_set_id;

	Cursor	c_purge_orders IS
	SELECT	IS_PURGED
	FROM		OE_PURGE_ORDERS
	WHERE	PURGE_SET_ID = p_purge_set_id
	AND		NVL(IS_PURGED,'N') = 'Y';

	l_purge_set_purged VARCHAR2(1) :=  NULL;
	l_purge_set_name   VARCHAR2(50) := NULL;
	l_is_purged		VARCHAR2(1) := NULL;

BEGIN

	oe_debug_pub.add('Entering OE_Order_Purge_PVT.Delete_Purge_Set : '||to_char(p_purge_set_id),1);

	OPEN c_purge_set;
	FETCH  c_purge_set into
	l_purge_set_name
	,l_purge_set_purged;

	IF 	nvl(l_purge_set_purged,'N') = 'Y' THEN
		x_return_status := FND_API.G_FALSE;
		CLOSE c_purge_set;
		RETURN;
	ELSE
		OPEN	c_purge_orders;
		LOOP

			FETCH	c_purge_orders INTO l_is_purged;
			EXIT WHEN c_purge_orders%NOTFOUND OR
					c_purge_orders%NOTFOUND IS NULL;

			x_return_status := FND_API.G_FALSE;
			CLOSE c_purge_set;
			CLOSE c_purge_orders;
			RETURN;

		END LOOP;

		DELETE FROM OE_PURGE_ORDERS
		WHERE purge_set_id = p_purge_set_id;

		IF 	SQLCODE = 0 THEN
			DELETE FROM OE_PURGE_SETS
			WHERE purge_set_id = p_purge_set_id;
		END IF;

	END IF;

	CLOSE c_purge_set;
	CLOSE c_purge_orders;

	x_return_status := FND_API.G_TRUE;

	oe_debug_pub.add('Exiting OE_Order_Purge_PVT.Delete_Purge_Set : '||to_char(p_purge_set_id),1);

END Delete_Purge_Set;

--Added this function to check for open quotes

FUNCTION        Check_Open_Quotes
(
        p_header_id          NUMBER
)
RETURN VARCHAR2
IS
        CURSOR c_open_quotes IS
        SELECT 'Open Quotes'
        FROM   OE_ORDER_HEADERS
        WHERE  HEADER_ID = p_header_id
        AND    NVL(OPEN_FLAG,'Y')    = 'N';

        l_open_quotes           VARCHAR2(50);
        l_record_exists         BOOLEAN;

BEGIN

  OPEN c_open_quotes;

  FETCH c_open_quotes INTO l_open_quotes;
  l_record_exists := c_open_quotes%FOUND;

  CLOSE c_open_quotes;

  IF (NOT l_record_exists) then
     RETURN FND_API.G_FALSE;
  END IF;
  RETURN FND_API.G_TRUE;
END Check_Open_Quotes;


FUNCTION	Check_Open_Orders
(
--for Bug # 4516769
	p_header_id		NUMBER
)
RETURN VARCHAR2
IS
	CURSOR c_open_orders IS
	SELECT 'Open Orders'
	FROM	  OE_ORDER_HEADERS
	WHERE  Header_id=p_header_id		   --for Bug # 4516769
	AND	  NVL(OPEN_FLAG,'Y')	= 'N';

	l_open_orders		VARCHAR2(50);
	l_record_exists	BOOLEAN;

BEGIN

        OPEN c_open_orders;

        FETCH c_open_orders INTO l_open_orders;
        l_record_exists := c_open_orders%FOUND;

        CLOSE c_open_orders;

        IF (NOT l_record_exists) then
                RETURN FND_API.G_FALSE;
        END IF;

        RETURN FND_API.G_TRUE;

END Check_Open_Orders;

FUNCTION Check_Open_Invoiced_Orders
(
	p_order_number     IN	VARCHAR2
,	p_order_type_name  IN	VARCHAR2 )
RETURN VARCHAR2
IS

	CURSOR c_oe_ope_invoice IS
	SELECT 'Open invoices for this sales order'
	--FROM   ra_customer_trx_lines rctl, --MOAC
	FROM   ra_customer_trx_lines_all rctl, --MOAC
	RA_CUSTOMER_TRX       rct
	WHERE  rctl.interface_line_attribute1 = p_order_number
	AND    rctl.interface_line_attribute2 = p_order_type_name
        --bug3389049 start
        AND    rctl.interface_line_context = 'ORDER ENTRY'
        --bug3389049 end
	AND    rctl.customer_trx_id = rct.customer_trx_id
	AND    rct.complete_flag    = 'N';

	l_fetch_value     VARCHAR2(80);
	l_records_exists  BOOLEAN;
BEGIN

	OPEN c_oe_ope_invoice;
	FETCH c_oe_ope_invoice INTO l_fetch_value;
	l_records_exists := c_oe_ope_invoice%FOUND;
	CLOSE c_oe_ope_invoice;

	IF (NOT l_records_exists) THEN
		RETURN FND_API.G_TRUE;
	END IF;
	RETURN FND_API.G_FALSE;

EXCEPTION
        WHEN  OTHERS  THEN
	RETURN FND_API.G_TRUE;

END Check_Open_Invoiced_Orders;

FUNCTION Check_Open_Returns
(
	p_order_number  	IN	NUMBER
,	p_order_type_name	IN	VARCHAR2 )
RETURN VARCHAR2
IS

	CURSOR c_open_returns IS
	SELECT 'Open return for this sales order'
	/*MOAC*/
	--FROM   oe_order_lines    sl1,
	--oe_order_lines    sl2,
	FROM   oe_order_lines_all    sl1,
	oe_order_lines_all    sl2,
	oe_order_headers_all  sh,
	oe_order_types_v ot  --MOAC view based on multiple objects
	WHERE  sh.order_number = p_order_number
	AND    sh.order_type_id = ot.order_type_id
	AND    ot.name = p_order_type_name
	AND    sl1.header_id    = sh.header_id
	AND    sl2.reference_line_id = sl1.line_id
	AND    sl2.line_category_code =  'RETURN'
--	AND    sl2.reference_type IN ( 'ORDER', 'PO' )
	AND    sl2.return_context IN ( 'ORDER', 'PO' ) --for bug 2784219
	AND    nvl(sl2.open_flag,'N') = 'Y';

	l_fetch_value     VARCHAR2(80);
	l_records_exists  BOOLEAN;

BEGIN

	OPEN c_open_returns;

	FETCH c_open_returns INTO l_fetch_value;
	l_records_exists := c_open_returns%FOUND;
	CLOSE c_open_returns;

	IF (NOT l_records_exists) THEN
		RETURN FND_API.G_TRUE;
	END IF;

	RETURN FND_API.G_FALSE;

EXCEPTION
        WHEN  OTHERS  THEN
	RETURN FND_API.G_FALSE;
END Check_Open_Returns;

PROCEDURE Check_Open_RMA_Receipts
( p_header_id        IN    NUMBER,
  x_return_status    OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_message          OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
     CURSOR c_return_lines IS
     SELECT line_id
     FROM   oe_order_lines
     WHERE  header_id    = p_header_id
     AND    line_category_code =  'RETURN';
     l_line_id     NUMBER;
     l_return_status varchar2(10);
BEGIN

     OPEN c_return_lines;
     LOOP
       FETCH c_return_lines INTO l_line_id;
       EXIT When c_return_lines%NOTFOUND;

       RCV_RMA_RCPT_PURGE.Check_Open_Receipts(l_line_id,
	  	l_return_status,x_message);

       IF l_return_status = 'FALSE' THEN
          CLOSE c_return_lines;
          x_return_status := FND_API.G_FALSE;
		RETURN;
       END IF;
     END LOOP;

     CLOSE c_return_lines;
	x_return_status := FND_API.G_TRUE;

EXCEPTION
        WHEN  OTHERS  THEN
		x_return_status := FND_API.G_FALSE;

END Check_Open_RMA_Receipts;

--      Purge Changes for 11i.10

/*--------------------------------------------------------------------
Function    : Check_Open_PO_Reqs_Dropship
Description : This function checks if there are any open
              PO/Requsitions associated with drop ship order lines.
              It will call an API provided by Purchasing. If this API
              returns that the PO/Requsition associated with any of
              the drop ship order line is open, the order will be marked
              for not to be purged, with message OE_PURGE_OPEN_PO_REQ.
----------------------------------------------------------------------*/
Function Check_Open_PO_Reqs_Dropship
( p_header_id           IN           NUMBER
)
 RETURN VARCHAR2
IS
 CURSOR c_ds_line_loc IS
        SELECT ds.line_location_id  line_location_id
        FROM  oe_drop_ship_sources ds
        WHERE ds.header_id          = p_header_id;

 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 l_return_status        VARCHAR2(1);
 l_msg_count            NUMBER;
 l_msg_data             VARCHAR2(1000);
 I                      NUMBER := 1;
 l_entity_id_tbl        PO_TBL_NUMBER   := PO_TBL_NUMBER();
 l_purge_allowed_tbl    PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();

BEGIN

  IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add('Entering Check_Open_PO_Reqs_Dropship...',1);
  END IF;

  FOR c_loc in c_ds_line_loc LOOP

      IF c_loc.line_location_id is NOT NULL THEN

         l_entity_id_tbl.extend(I);
         l_entity_id_tbl(I)  := c_loc.line_location_id;
         I := I + 1;

      END IF;

  END LOOP;


  IF I > 1 THEN

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Before Calling PO Validate_Purge...',1);
     END IF;

     PO_OM_INTEGRATION_GRP.Validate_Purge
                          ( p_api_version        => 1.0
                           ,p_init_msg_list      => FND_API.G_FALSE
                           ,p_commit             => FND_API.G_FALSE
                           ,p_entity             => 'PO_LINE_LOCATIONS'
                           ,p_entity_id_tbl      => l_entity_id_tbl
                           ,x_return_status      => l_return_status
                           ,x_msg_count          => l_msg_count
                           ,x_msg_data           => l_msg_data
                           ,x_purge_allowed_tbl  => l_purge_allowed_tbl
                           );

     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('After Calling PO Validate_Purge...'||l_return_status,1);
     END IF;

     IF    l_return_status = FND_API.G_RET_STS_SUCCESS THEN

           FOR J  in 1..l_purge_allowed_tbl.COUNT LOOP

               IF l_purge_allowed_tbl(J) = 'N' THEN


                  IF l_debug_level  > 0 THEN
                     OE_DEBUG_PUB.Add('Purge Not Alowed for Loc Id: '||
                                                    l_entity_id_tbl(J),2) ;
                  END IF;

                  -- Return False if record Exists

                  RETURN FND_API.G_FALSE;

               END IF;

           END LOOP;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

            OE_MSG_PUB.Add_Text(l_msg_data);

            IF l_debug_level  > 0 THEN
               OE_DEBUG_PUB.Add('Errors from Validate Purge: '||l_msg_data,2) ;
            END IF;

           RAISE FND_API.G_EXC_ERROR;
      END IF;


  END IF;


  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('Exiting Check_Open_PO_Reqs_Dropship...',1);
  END IF;

  -- Return True if record Exists

  RETURN FND_API.G_TRUE;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('Exp Error in Check_Open_PO_Reqs_Dropship...',4);
         END IF;
         RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('UnExp Error in Check_Open_PO_Reqs_Dropship...'
                                                                  ||sqlerrm,4);
         END IF;
         RAISE;

    WHEN OTHERS THEN
         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
           OE_MSG_PUB.Add_Exc_Msg
             ( 'OE_ORDER_PURGE_PVT'
              ,'Check_Open_PO_Reqs_Dropship'
             );
         END IF;
         RAISE;

END Check_Open_PO_Reqs_Dropship;


PROCEDURE Oe_Purge_Headers
(
	p_purge_set_id 	IN	NUMBER
,	p_header_id		IN	NUMBER
,	x_return_status	OUT NOCOPY /* file.sql.39 change */	VARCHAR2)
IS

	l_return_status    VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
	l_error_msg        VARCHAR2(240);
	CURSOR c_lock_header IS
	SELECT header_id            --  Lock all rows to be purged
	FROM   oe_order_headers
	WHERE  header_id = p_header_id
	FOR UPDATE NOWAIT;

	CURSOR c_lock_header_hist IS
	SELECT header_id            --  Lock all rows to be purged
	FROM   oe_order_header_history
	WHERE  header_id = p_header_id
	FOR UPDATE NOWAIT;

        CURSOR c_lock_price_adj_hist IS
        SELECT header_id            --  Lock all rows to be purged
        FROM   oe_price_adjs_history
        WHERE  header_id = p_header_id
        FOR UPDATE NOWAIT;

        CURSOR c_lock_sales_credit_hist IS
        SELECT header_id            --  Lock all rows to be purged
        FROM   oe_sales_credit_history
        WHERE  header_id = p_header_id
        FOR UPDATE NOWAIT;

	cursor c_purge_set_history is  --bug#5631508
		select set_id  from oe_sets_history
		where header_id= p_header_id
		FOR UPDATE NOWAIT;

        l_doc_tbl    OE_CONTRACTS_UTIL.doc_tbl_type;
        l_doc_rec    OKC_TERMS_UTIL_GRP.doc_rec_type;
        l_msg_count  NUMBER;
        l_msg_data   VARCHAR2(2000);

BEGIN

	oe_debug_pub.add('Entering OE_ORDER_PURGE_PVT.OE_Purge_Headers : '||to_char(p_header_id));

	OPEN c_lock_header;                   --  Lock all rows to be purged

	CLOSE c_lock_header;

	IF	l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		l_return_status := OE_Order_Purge_PVT.OE_Purge_Header_Adj
					(
						p_purge_set_id 	=> p_purge_set_id,
						p_header_id		=> p_header_id
					);

	ELSE
		x_return_status := l_return_status;
		RETURN;
	END IF;

	IF	l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		l_return_status := OE_Order_Purge_PVT.OE_Purge_Price_Attribs
					(
						p_purge_set_id 	=> p_purge_set_id,
						p_header_id		=> p_header_id
					);

	ELSE
		x_return_status := l_return_status;
		RETURN;
	END IF;

	IF	l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		l_return_status := OE_Order_Purge_PVT.OE_Purge_Order_Sales_Credits
					(
						p_purge_set_id 	=> p_purge_set_id,
						p_header_id		=> p_header_id
					);

	ELSE
		x_return_status := l_return_status;
		RETURN;
	END IF;

	IF	l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		l_return_status := OE_Order_Purge_PVT.OE_Purge_Order_Sets
					(
						p_purge_set_id 	=> p_purge_set_id,
						p_header_id		=> p_header_id
					);

	ELSE
		x_return_status := l_return_status;
		RETURN;
	END IF;

	IF	l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		l_return_status := OE_Order_Purge_PVT.OE_Purge_Order_Holds
					(
						p_purge_set_id 	=> p_purge_set_id,
						p_header_id		=> p_header_id
					);

	ELSE
		x_return_status := l_return_status;
		RETURN;
	END IF;

        -- purge for multiple payments
        IF      l_return_status = FND_API.G_RET_STS_SUCCESS THEN
             	l_return_status := OE_Order_Purge_PVT.OE_Purge_Header_payments
                                                ( p_purge_set_id  => p_purge_set_id,
                                                  p_header_id     => p_header_id
                                                );
     	ELSE
              x_return_status := l_return_status;
              RETURN;
    	END IF;

	-- Delete the attachments.

	IF	l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		OE_Atchmt_Util.Delete_Attachments
					(
						p_entity_code		=> OE_GLOBALS.G_ENTITY_HEADER,
						p_entity_id		=> p_header_id,
						x_return_status	=> l_return_status
					);
		IF	l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			oe_debug_pub.add('Attachments delete failed : ');
			x_return_status := l_return_status;
			RETURN;
		END IF;

	ELSE
		x_return_status := l_return_status;
		RETURN;
	END IF;

     -- Delete record from CTO tables

	oe_debug_pub.add('Calling CTOs API ',3);

	IF	l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		CTO_ORDER_PURGE.Cto_Purge_Tables
					(
						p_header_id		=> p_header_id,
						x_error_msg		=> l_error_msg,
						x_return_status	=> l_return_status
					);

		oe_debug_pub.add('Return from CTOs API : '||l_return_status,3);

		IF	l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

			x_return_status := l_return_status;
			ROLLBACK TO SAVEPOINT ORDER_HEADER;
			record_errors( l_return_status
			,p_purge_set_id
			,p_header_id
			,'ORDPUR: CTO Package Errored '||l_error_msg);
			RETURN;

		END IF;

	ELSE
		x_return_status := l_return_status;
		RETURN;
	END IF;

	-- Delete the header work flow.

	BEGIN

		OE_Order_WF_Util.Delete_Row
		(
		p_type	=>	'HEADER',
		p_id		=>	p_header_id
		);

	EXCEPTION
		WHEN OTHERS THEN
			NULL;

	END;

        -- Purge Changes for 11i.10
        -- Purge the History tables

        OPEN  c_lock_header_hist;
        CLOSE c_lock_header_hist;
        DELETE FROM oe_order_header_history  WHERE  header_id = p_header_id;

        OE_DEBUG_PUB.Add('After Deleting header history='|| to_char(p_header_id));

        OPEN c_lock_price_adj_hist;
        CLOSE c_lock_price_adj_hist;
        DELETE FROM oe_price_adjs_history  WHERE  header_id = p_header_id;

	OE_DEBUG_PUB.Add('After Deleting Price Adj history='|| to_char(p_header_id));

        OPEN c_lock_sales_credit_hist;
        CLOSE c_lock_sales_credit_hist;
        DELETE FROM oe_sales_credit_history WHERE  header_id = p_header_id;

	OE_DEBUG_PUB.Add('After Deleting Sales Credit history='|| to_char(p_header_id));

	OPEN c_purge_set_history; --bug#5631508
        CLOSE c_purge_set_history;
	DELETE FROM oe_sets_history WHERE  header_id = p_header_id;

        -- Purging Contract Articles

        IF  OE_CODE_CONTROL.Code_Release_Level  >= '110510' THEN

            IF OE_CONTRACTS_UTIL.Check_License = 'Y' THEN

               l_doc_rec.doc_type    :=   'O';
               l_doc_rec.doc_id      :=   p_header_id;
               l_doc_tbl(1)          :=   l_doc_rec;

               OE_CONTRACTS_UTIL.Purge_articles
                                (  p_api_version     => 1.0
	                         , p_doc_tbl         => l_doc_tbl
                                 , x_return_status   => x_return_status
                                 , x_msg_count	     => l_msg_count
                                 , x_msg_data	     => l_msg_data
                                );

               OE_DEBUG_PUB.Add('Purged the Articles for Header:'||to_char(p_header_id));

             END IF;

        END IF;
	DELETE FROM oe_order_headers
	WHERE  header_id = p_header_id;
	oe_debug_pub.add('deleted header='|| to_char(p_header_id));

	oe_debug_pub.add('Exiting OE_ORDER_PURGE_PVT.OE_Purge_Headers : ');

	x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION                   --  Exception handler to record error

	WHEN OTHERS THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		ROLLBACK TO SAVEPOINT ORDER_HEADER;
		record_errors( l_return_status
		,p_purge_set_id
		,p_header_id
		,'ORDPUR: OE_ORDER_HEADERS '||substr(sqlerrm,1,200)
		);
		CLOSE c_lock_header;

END Oe_Purge_Headers;

PROCEDURE Oe_Purge_Lines
(
	p_purge_set_id 	IN 	NUMBER
,	p_header_id		IN	NUMBER
,	x_return_status	OUT NOCOPY /* file.sql.39 change */	VARCHAR2)

IS

	l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
	l_line_id		NUMBER;
	l_lock_line_id		NUMBER;
	l_order_quantity_uom  	VARCHAR2(3);
	l_is_ota_line       	BOOLEAN;
	l_org_id            	NUMBER;
	l_line_category_code    VARCHAR2(30);
	l_source_type_code      VARCHAR2(30);
        I                       NUMBER  := 1;
        l_entity_id_tbl         PO_TBL_NUMBER   := PO_TBL_NUMBER();
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
        l_top_model_line_id     NUMBER;          --added for bug 3664878
        l_config_header_id      NUMBER;          --added for bug 3664878
        l_config_rev_nbr        NUMBER;          --added for bug 3664878

        --cursor definition of c_purge_lines modified for bug 3664878
	CURSOR c_purge_lines IS
	SELECT line_id,order_quantity_uom,
               org_id,line_category_code,source_type_code,
               top_model_line_id,config_header_id,
               config_rev_nbr
	FROM   oe_order_lines
	WHERE  header_id = p_header_id;

        CURSOR c_purge_lines_hist IS
        SELECT line_id
        FROM   oe_order_lines_history
        WHERE  header_id = p_header_id
        FOR UPDATE NOWAIT;

        CURSOR c_purge_ds IS
        SELECT line_id
        FROM   oe_drop_ship_sources
        WHERE  header_id = p_header_id
        FOR UPDATE NOWAIT;

        CURSOR c_ds_line_loc IS
        SELECT ds.line_location_id
        FROM   oe_drop_ship_sources ds
        WHERE  ds.header_id    = p_header_id;

BEGIN

	oe_debug_pub.add('Entering OE_ORDER_PURGE_PVT.OE_Purge_Lines : '||to_char(p_header_id));


	OPEN c_purge_lines;
	LOOP
		FETCH c_purge_lines INTO  l_line_id, l_order_quantity_uom, l_org_id
			, l_line_category_code,l_source_type_code,l_top_model_line_id
                        , l_config_header_id, l_config_rev_nbr;
		EXIT WHEN c_purge_lines%NOTFOUND           -- end of fetch
		OR c_purge_lines%NOTFOUND IS NULL;  -- empty cursor

		SELECT line_id
		INTO   l_lock_line_id
		FROM   oe_order_lines
		WHERE  line_id = l_line_id
		FOR UPDATE NOWAIT;

                --IF condition added for bug 3664878
                --to delete data from CZ tables in case of configurations
                IF l_line_id = l_top_model_line_id AND
                   l_config_header_id is not null THEN

                   OE_Config_Pvt.Delete_Config
                    ( p_config_hdr_id    => l_config_header_id,
                      p_config_rev_nbr   => l_config_rev_nbr,
                      x_return_status    => l_return_status );

                   OE_DEBUG_PUB.Add('After Calling Delete_Config',1);
                END IF;


		IF	l_return_status = FND_API.G_RET_STS_SUCCESS THEN
			l_return_status := OE_Order_Purge_PVT.OE_Purge_Line_Adj
						(
							p_purge_set_id 	=> p_purge_set_id,
							p_header_id		=> p_header_id,
							p_line_id			=> l_line_id
						);

		ELSE
			x_return_status := l_return_status;
			RETURN;
		END IF;

		IF	l_return_status = FND_API.G_RET_STS_SUCCESS THEN
			l_return_status := OE_Order_Purge_PVT.OE_Purge_Line_Sales_Credits
						(
							p_purge_set_id 	=> p_purge_set_id,
							p_header_id		=> p_header_id,
							p_line_id			=> l_line_id
						);

		ELSE
			x_return_status := l_return_status;
			RETURN;
		END IF;

		IF	l_return_status = FND_API.G_RET_STS_SUCCESS THEN
			l_return_status := OE_Order_Purge_PVT.OE_Purge_Line_Sets
						(
							p_purge_set_id 	=> p_purge_set_id,
							p_header_id		=> p_header_id,
							p_line_id			=> l_line_id
						);

		ELSE
			x_return_status := l_return_status;
			RETURN;
		END IF;

                -- purge for multiple payments.
                IF      l_return_status = FND_API.G_RET_STS_SUCCESS THEN
             		l_return_status := OE_Order_Purge_PVT.OE_Purge_Line_payments
                                                ( p_purge_set_id  => p_purge_set_id,
                                                   p_header_id    => p_header_id,
                                                   p_line_id      => l_line_id
                                                );
     		ELSE
              		x_return_status := l_return_status;
              		RETURN;
    		END IF;


          oe_debug_pub.add('Before RMA : ',1);

		IF	l_return_status = FND_API.G_RET_STS_SUCCESS  THEN
			IF l_line_category_code = 'RETURN' THEN

			l_return_status := OE_Purge_RMA_Line_Receipts
						(    p_purge_set_id 	=> p_purge_set_id,
							p_header_id		=> p_header_id,
							p_line_id			=> l_line_id
						);

               END IF;

		ELSE
			x_return_status := l_return_status;
			RETURN;
		END IF;

          oe_debug_pub.add('Before RMA_LOT : ',1);

		IF	l_return_status = FND_API.G_RET_STS_SUCCESS  THEN
			IF l_line_category_code = 'RETURN' THEN

			l_return_status := OE_Purge_RMA_Line_Lot_Srl
						(    p_purge_set_id 	=> p_purge_set_id,
							p_header_id		=> p_header_id,
							p_line_id			=> l_line_id
						);

               END IF;
		ELSE
			x_return_status := l_return_status;
			RETURN;
		END IF;


		-- Delete the attachments.

          oe_debug_pub.add('Before before attach : ',1);

		IF	l_return_status = FND_API.G_RET_STS_SUCCESS THEN
			OE_Atchmt_Util.Delete_Attachments
						(
							p_entity_code		=> OE_GLOBALS.G_ENTITY_LINE,
							p_entity_id		=> l_line_id,
							x_return_status	=> l_return_status
						);
			IF	l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				oe_debug_pub.add('Attachments delete failed : ');
				x_return_status := l_return_status;
				RETURN;
			END IF;

		ELSE
			x_return_status := l_return_status;
			RETURN;
		END IF;

		-- Delete the Line work flow.
          oe_debug_pub.add('Before workflow : ',1);
		BEGIN


			OE_Order_WF_Util.Delete_Row
			(
			p_type	=>	'LINE',
			p_id		=>	l_line_id
			);

		EXCEPTION
			WHEN OTHERS THEN
				NULL;

		END;

		-- Purge the OTA lines. Currently, OTA lines are identified by UOM.

          oe_debug_pub.add('Before ota : ',1);
	    l_is_ota_line :=  OE_OTA_UTIL.Is_OTA_Line(l_order_quantity_uom);
	    IF (l_is_ota_line) THEN
		 OE_OTA_UTIL.Notify_OTA
				 (p_line_id => l_line_id,
				  p_org_id  => l_org_id,
				  p_order_quantity_uom => l_order_quantity_uom,
				  p_daemon_type => 'P',
				  x_return_status => l_return_status);

              if l_return_status <> FND_API.G_RET_STS_SUCCESS then
              null;
		    end if;
         End IF;

           -- Purge the History tables

           OPEN c_purge_lines_hist;
           CLOSE c_purge_lines_hist;
           DELETE FROM oe_order_lines_history WHERE  header_id = p_header_id;

           OE_DEBUG_PUB.Add('Before line delete : ',1);

	   DELETE FROM   oe_order_lines
	   WHERE  line_id = l_line_id;

	END LOOP;

         --  Purge Changes for 11i.10
         --  Purge PO/Req

         IF PO_CODE_RELEASE_GRP.Current_Release >=
              PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J AND
                 OE_CODE_CONTROL.Code_Release_Level  >= '110510' THEN

                   OE_DEBUG_PUB.Add('Purge Externally Sourced Lines');

                   FOR c_ds_loc in c_ds_line_loc LOOP

                       IF  c_ds_loc.line_location_id IS NOT NULL THEN
                           OE_DEBUG_PUB.Add('Purge Line Loc : '||c_ds_loc.line_location_id);
                           l_entity_id_tbl.extend(1);
                           l_entity_id_tbl(I) := c_ds_loc.line_location_id;
                           I := I + 1;
                       END IF;
                   END LOOP;

                   OPEN c_purge_ds;
                   CLOSE c_purge_ds;

                   DELETE FROM oe_drop_ship_sources where header_id = p_header_id;

	           OE_DEBUG_PUB.Add('Before Calling PO Purge API ');

                   PO_OM_INTEGRATION_GRP.Purge
                                      ( p_api_version          => 1.0
                                      ,p_init_msg_list        => FND_API.G_FALSE
                                      ,p_commit               => FND_API.G_FALSE
                                      ,x_return_status        => x_return_status
                                      ,x_msg_count            => l_msg_count
                                      ,x_msg_data             => l_msg_data
                                      ,p_entity               => 'PO_LINE_LOCATIONS'
                                      ,p_entity_id_tbl        => l_entity_id_tbl
                                      );

	           OE_DEBUG_PUB.Add('After Calling PO Purge API '||x_return_status);

                   IF    x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                         OE_MSG_PUB.Add_Text(l_msg_data);
                         OE_DEBUG_PUB.Add('Errors from Purge: '||l_msg_data,2) ;
                         RAISE FND_API.G_EXC_ERROR;
                   END IF;
         END IF;


	oe_debug_pub.add('Number of lines deleted : '||to_char(c_purge_lines%ROWCOUNT),1);
	CLOSE c_purge_lines;

	oe_debug_pub.add('deleted lines for header='|| to_char(p_header_id));
	oe_debug_pub.add('Exiting OE_ORDER_PURGE_PVT.OE_Purge_Lines : ');

	x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION                   --  Exception handler to record error

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		ROLLBACK TO SAVEPOINT ORDER_HEADER;
		record_errors( l_return_status
		,p_purge_set_id
		,p_header_id
		,'ORDPUR: OE_ORDER_LINES '||substr(sqlerrm,1,200)
		);
		CLOSE c_purge_lines;

END Oe_Purge_Lines;

FUNCTION OE_Purge_Header_Adj
(
	p_purge_set_id 	IN 	NUMBER
,	p_header_id		IN	NUMBER)

RETURN VARCHAR2
IS
	CURSOR 	c_header_adj IS
	SELECT	PRICE_ADJUSTMENT_ID
	FROM		OE_PRICE_ADJUSTMENTS
	WHERE 	HEADER_ID = p_header_id;

	CURSOR	c_price_adj(p_price_adjustment_id NUMBER) IS
	SELECT price_adj_attrib_id
	FROM   oe_price_adj_attribs
	WHERE  price_adjustment_id = p_price_adjustment_id;

	CURSOR	c_price_adj_assocs(p_price_adjustment_id NUMBER) IS
	SELECT	price_adj_assoc_id
	FROM		OE_PRICE_ADJ_ASSOCS OPAA
        WHERE opaa.rltd_price_adj_id IN (SELECT TO_NUMBER (p_price_adjustment_id)
                                    FROM DUAL
                                   UNION ALL
                                  SELECT opaa1.rltd_price_adj_id
                                    FROM oe_price_adj_assocs opaa1
                                   WHERE opaa1.price_adjustment_id = p_price_adjustment_id);
/*
	WHERE	(OPAA.price_adjustment_id = p_price_adjustment_id or
			OPAA.rltd_price_adj_id = p_price_adjustment_id) or
			OPAA.rltd_price_adj_id in( select opaa1.rltd_price_adj_id from
								oe_price_adj_assocs opaa1 where
								opaa1.price_adjustment_id = p_price_adjustment_id);
 ========= Commented for the bug 3053445 =========
*/
	l_price_adjustment_id	NUMBER;
	l_lock_adjustment_id	NUMBER;
	l_price_adj_assoc_id	NUMBER;
	l_lock_price_adj_assoc_id	NUMBER;
	l_price_adj_attrib_id	NUMBER;
	l_lock_price_adj_attrib_id	NUMBER;
	l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

BEGIN

	oe_debug_pub.add('Entering OE_ORDER_PURGE_PVT.OE_Purge_Header_Adj : '||to_char(p_header_id));

	OPEN c_header_adj;

	LOOP

		FETCH c_header_adj INTO  l_price_adjustment_id;
		oe_debug_pub.add('price adjust ment : '||to_char(l_price_adjustment_id));
		EXIT WHEN c_header_adj%NOTFOUND           -- end of fetch
		OR c_header_adj%NOTFOUND IS NULL;  -- empty cursor

		-- Lock the price adjustments record.
		SELECT price_adjustment_id
		INTO   l_lock_adjustment_id
		FROM   oe_price_adjustments
		WHERE  price_adjustment_id = l_price_adjustment_id
		FOR UPDATE NOWAIT;

		-- Delete from price_adj_attribs.
		OPEN	c_price_adj(l_price_adjustment_id);
		LOOP
			FETCH c_price_adj INTO  l_price_adj_attrib_id;
			EXIT WHEN c_price_adj%NOTFOUND           -- end of fetch
			OR c_price_adj%NOTFOUND IS NULL;  -- empty cursor

			SELECT price_adj_attrib_id
			INTO   l_lock_price_adj_attrib_id
			FROM   oe_price_adj_attribs
			WHERE  price_adj_attrib_id = l_price_adj_attrib_id
			FOR UPDATE NOWAIT;

			DELETE FROM   oe_price_adj_attribs
			WHERE  price_adj_attrib_id = l_price_adj_attrib_id;

		END LOOP;

		oe_debug_pub.add('Number of price_adj deleted : '||to_char(c_price_adj%ROWCOUNT),1);
		CLOSE c_price_adj;

		-- Delete from price_adj_assocs.
		OPEN	c_price_adj_assocs(l_price_adjustment_id);
		LOOP
			FETCH c_price_adj_assocs INTO  l_price_adj_assoc_id;
			EXIT WHEN c_price_adj_assocs%NOTFOUND           -- end of fetch
			OR c_price_adj_assocs%NOTFOUND IS NULL;  -- empty cursor
			oe_debug_pub.add('price adjust ment 4 : '||to_char(l_price_adjustment_id));

			SELECT price_adj_assoc_id
			INTO   l_lock_price_adj_assoc_id
			FROM   oe_price_adj_assocs
			WHERE  price_adj_assoc_id = l_price_adj_assoc_id
			FOR UPDATE NOWAIT;

			DELETE FROM   oe_price_adj_assocs
			WHERE price_adj_assoc_id = l_lock_price_adj_assoc_id;

		END LOOP;

		oe_debug_pub.add('Number of price_adj_assocs deleted : '||to_char(c_price_adj_assocs%ROWCOUNT),1);
		CLOSE c_price_adj_assocs;


		DELETE FROM OE_PRICE_ADJUSTMENTS
		WHERE price_adjustment_id = l_lock_adjustment_id;

	END LOOP;

	oe_debug_pub.add('Number of price adjustments deleted : '||to_char(c_header_adj%ROWCOUNT),1);
	CLOSE c_header_adj;

	oe_debug_pub.add('Exiting OE_ORDER_PURGE_PVT.OE_Purge_Header_Adj : ');

	RETURN FND_API.G_RET_STS_SUCCESS;

EXCEPTION                   --  Exception handler to record error

	WHEN OTHERS THEN
		l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		ROLLBACK TO SAVEPOINT ORDER_HEADER;
		record_errors( l_return_status
		,p_purge_set_id
		,p_header_id
		,'ORDPUR: Header Price Adjustments '||substr(sqlerrm,1,200)
		);
		CLOSE c_header_adj;
		CLOSE c_price_adj_assocs;
		RETURN l_return_status;

END OE_Purge_Header_Adj;

FUNCTION OE_Purge_Line_Adj
(
	p_purge_set_id 	IN 	NUMBER
,	p_header_id		IN	NUMBER
,	p_line_id			IN	NUMBER)

RETURN VARCHAR2
IS
	CURSOR 	c_line_adj IS
	SELECT	PRICE_ADJUSTMENT_ID
	FROM		OE_PRICE_ADJUSTMENTS
	WHERE 	LINE_ID = p_line_id;

        -- Added cursor c_price_adj for bug # 4701261

        CURSOR c_price_adj(p_price_adjustment_id NUMBER) IS
        SELECT price_adj_attrib_id
        FROM   oe_price_adj_attribs
        WHERE  price_adjustment_id = p_price_adjustment_id;

    -- Modified for the SQLREP changes for SQL_ID = 14882948
    CURSOR  c_price_adj_assocs(p_price_adjustment_id NUMBER) IS
    SELECT  price_adj_assoc_id
    FROM        OE_PRICE_ADJ_ASSOCS OPAA
    WHERE opaa.rltd_price_adj_id IN (
                                SELECT p_price_adjustment_id
                                FROM DUAL
                                UNION ALL
                                SELECT opaa1.rltd_price_adj_id
                                FROM oe_price_adj_assocs opaa1
                                WHERE opaa1.price_adjustment_id = p_price_adjustment_id);


	l_price_adjustment_id	NUMBER;
	l_lock_adjustment_id	NUMBER;
	l_price_adj_assoc_id	NUMBER;
	l_lock_price_adj_assoc_id	NUMBER;
	l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
        l_price_adj_attrib_id      NUMBER;
        l_lock_price_adj_attrib_id NUMBER;


BEGIN

	oe_debug_pub.add('Entering OE_ORDER_PURGE_PVT.OE_Purge_Line_Adj : '||to_char(p_line_id));
	OPEN c_line_adj;

	LOOP

		FETCH c_line_adj INTO  l_price_adjustment_id;
		EXIT WHEN c_line_adj%NOTFOUND           -- end of fetch
		OR c_line_adj%NOTFOUND IS NULL;  -- empty cursor

		-- Lock the price adjustments record.
		SELECT price_adjustment_id
		INTO   l_lock_adjustment_id
		FROM   oe_price_adjustments
		WHERE  price_adjustment_id = l_price_adjustment_id
		FOR UPDATE NOWAIT;


                -- Added the following cursor for bug # 4701261

                OPEN    c_price_adj(l_price_adjustment_id);
                LOOP
                        FETCH c_price_adj INTO  l_price_adj_attrib_id;
                        EXIT WHEN c_price_adj%NOTFOUND
                        OR c_price_adj%NOTFOUND IS NULL;

                        SELECT price_adj_attrib_id
                        INTO   l_lock_price_adj_attrib_id
                        FROM   oe_price_adj_attribs
                        WHERE  price_adj_attrib_id = l_price_adj_attrib_id
                        FOR UPDATE NOWAIT;

                        DELETE FROM   oe_price_adj_attribs
                        WHERE  price_adj_attrib_id = l_price_adj_attrib_id;

                END LOOP;

                oe_debug_pub.add('Number of price_adj deleted : '||to_char(c_price_adj%ROWCOUNT),1);
                CLOSE c_price_adj;

         -- Commented for Bug # 4701261

	/*
		-- Delete from price_adj_attribs.
		SELECT price_adjustment_id
		INTO   l_lock_adjustment_id
		FROM   oe_price_adj_attribs
		WHERE  price_adjustment_id = l_price_adjustment_id
		FOR UPDATE NOWAIT;

		DELETE FROM   oe_price_adj_attribs
		WHERE  price_adjustment_id = l_price_adjustment_id;
       */

		-- Delete from price_adj_assocs.
		OPEN	c_price_adj_assocs(l_price_adjustment_id);
		LOOP
			FETCH c_price_adj_assocs INTO  l_price_adj_assoc_id;
			EXIT WHEN c_price_adj_assocs%NOTFOUND           -- end of fetch
			OR c_price_adj_assocs%NOTFOUND IS NULL;  -- empty cursor

			SELECT price_adj_assoc_id
			INTO   l_lock_price_adj_assoc_id
			FROM   oe_price_adj_assocs
			WHERE  price_adj_assoc_id = l_price_adj_assoc_id
			FOR UPDATE NOWAIT;

			DELETE FROM   oe_price_adj_assocs
			WHERE price_adj_assoc_id = l_lock_price_adj_assoc_id;

		END LOOP;

		oe_debug_pub.add('Number of price_adj_assocs deleted : '||to_char(c_price_adj_assocs%ROWCOUNT),1);
		CLOSE c_price_adj_assocs;

		DELETE FROM OE_PRICE_ADJUSTMENTS
		WHERE price_adjustment_id = l_lock_adjustment_id;

	END LOOP;

	oe_debug_pub.add('Number of price adjustments deleted : '||to_char(c_line_adj%ROWCOUNT),1);
	CLOSE c_line_adj;
	oe_debug_pub.add('Exiting OE_ORDER_PURGE_PVT.OE_Purge_Line_Adj : ');

	RETURN FND_API.G_RET_STS_SUCCESS;

EXCEPTION                   --  Exception handler to record error

	WHEN OTHERS THEN
		l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		ROLLBACK TO SAVEPOINT ORDER_HEADER;
		record_errors( l_return_status
		,p_purge_set_id
		,p_header_id
		,'ORDPUR: Line Price Adjustments '||substr(sqlerrm,1,200)
		);
		CLOSE c_line_adj;
		CLOSE c_price_adj_assocs;
		RETURN l_return_status;

END OE_Purge_Line_Adj;

FUNCTION OE_Purge_Price_Attribs
(
	p_purge_set_id 	IN 	NUMBER
,	p_header_id		IN	NUMBER)

RETURN VARCHAR2
IS

	CURSOR 	c_order_price_attribs IS
	SELECT	ORDER_PRICE_ATTRIB_ID
	FROM		OE_ORDER_PRICE_ATTRIBS
	WHERE 	HEADER_ID = p_header_id;

	l_order_price_attrib_id		NUMBER;
	l_lock_price_attrib_id		NUMBER;
	l_return_status			VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

BEGIN

	oe_debug_pub.add('Entering OE_ORDER_PURGE_PVT.OE_Purge_Price_Attribs : '||to_char(p_header_id));
	OPEN c_order_price_attribs;

	LOOP

		FETCH c_order_price_attribs INTO  l_order_price_attrib_id;
		EXIT WHEN c_order_price_attribs%NOTFOUND           -- end of fetch
		OR c_order_price_attribs%NOTFOUND IS NULL;  -- empty cursor

		-- Lock the sales credits record.
		SELECT ORDER_PRICE_ATTRIB_ID
		INTO   l_lock_price_attrib_id
		FROM   oe_order_price_attribs
		WHERE  ORDER_PRICE_ATTRIB_ID = l_order_price_attrib_id
		FOR UPDATE NOWAIT;

		DELETE FROM OE_ORDER_PRICE_ATTRIBS
		WHERE ORDER_PRICE_ATTRIB_ID = l_order_price_attrib_id;

 	END LOOP;

	oe_debug_pub.add('Number of order price attribs deleted : '||to_char(c_order_price_attribs%ROWCOUNT),1);
	CLOSE c_order_price_attribs;

	oe_debug_pub.add('Exiting OE_ORDER_PURGE_PVT.OE_Purge_Price_Attribs : ');

	RETURN FND_API.G_RET_STS_SUCCESS;

EXCEPTION                   --  Exception handler to record error

	WHEN OTHERS THEN
		l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		ROLLBACK TO SAVEPOINT ORDER_HEADER;
		record_errors( l_return_status
		,p_purge_set_id
		,p_header_id
		,'ORDPUR: Order Price Attributes '||substr(sqlerrm,1,200)
		);
		CLOSE c_order_price_attribs;
		RETURN l_return_status;

END OE_Purge_Price_Attribs;

FUNCTION OE_Purge_Order_Sales_Credits
(
	p_purge_set_id 	IN 	NUMBER
,	p_header_id		IN	NUMBER)

RETURN VARCHAR2
IS

	CURSOR	c_order_sales_credits IS
	SELECT	SALES_CREDIT_ID
	FROM		OE_SALES_CREDITS
	WHERE	HEADER_ID = p_header_id;

	l_sales_credit_id		NUMBER;
	l_lock_sales_credit_id	NUMBER;
	l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

BEGIN
	oe_debug_pub.add('Entering OE_ORDER_PURGE_PVT.OE_Purge_Order_Sales_Credits : '||to_char(p_header_id));

	OPEN c_order_sales_credits;

	LOOP

		FETCH c_order_sales_credits INTO  l_sales_credit_id;
		EXIT WHEN c_order_sales_credits%NOTFOUND           -- end of fetch
		OR c_order_sales_credits%NOTFOUND IS NULL;  -- empty cursor

		-- Lock the sales credits record.
		SELECT sales_credit_id
		INTO   l_lock_sales_credit_id
		FROM   oe_sales_credits
		WHERE  sales_credit_id = l_sales_credit_id
		FOR UPDATE NOWAIT;

		DELETE FROM OE_SALES_CREDITS
		WHERE SALES_CREDIT_ID = l_sales_credit_id;

 	END LOOP;

	oe_debug_pub.add('Number of order sales credit deleted : '||to_char(c_order_sales_credits%ROWCOUNT),1);
	CLOSE c_order_sales_credits;

	oe_debug_pub.add('Exiting OE_ORDER_PURGE_PVT.OE_Purge_Order_Sales_Credits : ');
	RETURN FND_API.G_RET_STS_SUCCESS;

EXCEPTION                   --  Exception handler to record error

	WHEN OTHERS THEN
		l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		ROLLBACK TO SAVEPOINT ORDER_HEADER;
		record_errors( l_return_status
		,p_purge_set_id
		,p_header_id
		,'ORDPUR: Order Sales Credits '||substr(sqlerrm,1,200)
		);
		CLOSE c_order_sales_credits;
		RETURN l_return_status;

END OE_Purge_Order_Sales_Credits;

FUNCTION OE_Purge_Line_Sales_Credits
(
	p_purge_set_id 	IN 	NUMBER
,	p_header_id		IN	NUMBER
,	p_line_id			IN	NUMBER)

RETURN VARCHAR2
IS

	CURSOR	c_line_sales_credits IS
	SELECT	SALES_CREDIT_ID
	FROM		OE_SALES_CREDITS
	WHERE	LINE_ID = p_line_id;

	l_sales_credit_id		NUMBER;
	l_lock_sales_credit_id	NUMBER;
	l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

BEGIN

	oe_debug_pub.add('Entering OE_ORDER_PURGE_PVT.OE_Purge_Line_Sales_Credits : '||to_char(p_line_id));
	OPEN c_line_sales_credits;

	LOOP

		FETCH c_line_sales_credits INTO  l_sales_credit_id;
		EXIT WHEN c_line_sales_credits%NOTFOUND           -- end of fetch
		OR c_line_sales_credits%NOTFOUND IS NULL;  -- empty cursor

		-- Lock the sales credits record.
		SELECT sales_credit_id
		INTO   l_lock_sales_credit_id
		FROM   oe_sales_credits
		WHERE  sales_credit_id = l_sales_credit_id
		FOR UPDATE NOWAIT;

		DELETE FROM OE_SALES_CREDITS
		WHERE SALES_CREDIT_ID = l_sales_credit_id;

 	END LOOP;

	oe_debug_pub.add('Number of line sales credit deleted : '||to_char(c_line_sales_credits%ROWCOUNT),1);
	CLOSE c_line_sales_credits;

	oe_debug_pub.add('Exiting OE_ORDER_PURGE_PVT.OE_Purge_Line_Sales_Credits : ');
	RETURN FND_API.G_RET_STS_SUCCESS;

EXCEPTION                   --  Exception handler to record error

	WHEN OTHERS THEN
		l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		ROLLBACK TO SAVEPOINT ORDER_HEADER;
		record_errors( l_return_status
		,p_purge_set_id
		,p_header_id
		,'ORDPUR: Line Sales Credits '||substr(sqlerrm,1,200)
		);
		CLOSE c_line_sales_credits;
		RETURN l_return_status;

END OE_Purge_line_Sales_Credits;

FUNCTION OE_Purge_Order_Sets
(
	p_purge_set_id 	IN 	NUMBER
,	p_header_id		IN	NUMBER)

RETURN VARCHAR2
IS

	CURSOR	c_order_sets IS
	SELECT	SET_ID
	FROM		OE_SETS
	WHERE	HEADER_ID = p_header_id;

	l_set_id		NUMBER;
	l_lock_set_id	NUMBER;
	l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

BEGIN

	oe_debug_pub.add('Entering OE_ORDER_PURGE_PVT.OE_Purge_Order_Sets : '||to_char(p_header_id));
	OPEN c_order_sets;

	LOOP

		FETCH c_order_sets INTO  l_set_id;
		EXIT WHEN c_order_sets%NOTFOUND           -- end of fetch
		OR c_order_sets%NOTFOUND IS NULL;  -- empty cursor

		-- Lock the set record.
		SELECT set_id
		INTO   l_lock_set_id
		FROM   oe_sets
		WHERE  set_id = l_set_id
		FOR UPDATE NOWAIT;

		DELETE FROM OE_SETS
		WHERE SET_ID = l_set_id;

 	END LOOP;

	oe_debug_pub.add('Number of order sets deleted : '||to_char(c_order_sets%ROWCOUNT),1);
	CLOSE c_order_sets;

	oe_debug_pub.add('Exiting OE_ORDER_PURGE_PVT.OE_Purge_Order_Sets : ');
	RETURN FND_API.G_RET_STS_SUCCESS;

EXCEPTION                   --  Exception handler to record error

	WHEN OTHERS THEN
		l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		ROLLBACK TO SAVEPOINT ORDER_HEADER;
		record_errors( l_return_status
		,p_purge_set_id
		,p_header_id
		,'ORDPUR: Order Sets '||substr(sqlerrm,1,200)
		);
		CLOSE c_order_sets;
		RETURN l_return_status;

END OE_Purge_Order_Sets;

FUNCTION OE_Purge_Line_Sets
(
	p_purge_set_id 	IN 	NUMBER
,	p_header_id		IN	NUMBER
,	p_line_id			IN	NUMBER)

RETURN VARCHAR2
IS

	CURSOR	c_line_sets IS
	SELECT	LINE_ID,SET_ID
	FROM		OE_LINE_SETS
	WHERE	LINE_ID = p_line_id;

	l_set_id		NUMBER;
	l_line_id		NUMBER;
	l_lock_line_id	NUMBER;
	l_lock_set_id	NUMBER;
	l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

BEGIN
	oe_debug_pub.add('Entering OE_ORDER_PURGE_PVT.OE_Purge_Line_Sets : '||to_char(p_line_id));

	OPEN c_line_sets;

	LOOP

		FETCH c_line_sets INTO  l_line_id,l_set_id;
		EXIT WHEN c_line_sets%NOTFOUND           -- end of fetch
		OR c_line_sets%NOTFOUND IS NULL;  -- empty cursor

		-- Lock the line sets record.
		SELECT set_id,line_id
		INTO   l_lock_set_id,l_lock_line_id
		FROM   oe_line_sets
		WHERE  set_id = l_set_id
		AND	  line_id = l_line_id
		FOR UPDATE NOWAIT;

		DELETE FROM OE_LINE_SETS
		WHERE SET_ID = l_set_id
		AND   LINE_ID      = l_line_id;

 	END LOOP;

	oe_debug_pub.add('Number of Line sets deleted : '||to_char(c_line_sets%ROWCOUNT),1);
	CLOSE c_line_sets;

	oe_debug_pub.add('Exiting OE_ORDER_PURGE_PVT.OE_Purge_Line_Sets : ');
	RETURN FND_API.G_RET_STS_SUCCESS;

EXCEPTION                   --  Exception handler to record error

	WHEN OTHERS THEN
		l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		ROLLBACK TO SAVEPOINT ORDER_HEADER;
		record_errors( l_return_status
		,p_purge_set_id
		,p_header_id
		,'ORDPUR: Line Sets '||substr(sqlerrm,1,200)
		);
		CLOSE c_line_sets;
		RETURN l_return_status;

END OE_Purge_Line_Sets;

FUNCTION OE_Purge_Order_Holds
(
	p_purge_set_id 	IN 	NUMBER
,	p_header_id		IN	NUMBER)

RETURN VARCHAR2
IS

	CURSOR	c_order_holds IS
	SELECT	DISTINCT NVL(HOLD_RELEASE_ID,0),
			NVL(HOLD_SOURCE_ID,0),
			ORDER_HOLD_ID
	FROM		OE_ORDER_HOLDS
	WHERE	HEADER_ID = p_header_id;

	CURSOR	c_hold_sources(p_hold_source_id NUMBER) IS
	SELECT hold_source_id
	FROM   OE_HOLD_SOURCES
	WHERE  hold_source_id   = p_hold_source_id
    AND    hold_entity_id   = p_header_id
    AND    hold_entity_code = 'O';

	CURSOR	c_hold_releases(p_hold_release_id NUMBER) IS
	SELECT hold_release_id
	FROM   OE_HOLD_RELEASES
	WHERE  hold_release_id = p_hold_release_id;

	l_order_hold_id		NUMBER;
	l_lock_order_hold_id	NUMBER;
	l_hold_release_id		NUMBER;
	l_hold_source_id		NUMBER;
	l_lock_hold_release_id		NUMBER;
	l_lock_hold_source_id		NUMBER;
	l_return_status		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
        l_count                 NUMBER := 0;  -- bug 6148214

BEGIN
	oe_debug_pub.add('Entering OE_ORDER_PURGE_PVT.OE_Purge_Order_Hold : '||to_char(p_header_id));

	OPEN c_order_holds;

	LOOP

		FETCH c_order_holds INTO
			 l_hold_release_id,
			 l_hold_source_id,
			 l_order_hold_id;
		EXIT WHEN c_order_holds%NOTFOUND           -- end of fetch
		OR c_order_holds%NOTFOUND IS NULL;  -- empty cursor

		-- Lock the order holds record.
		SELECT order_hold_id
		INTO   l_lock_order_hold_id
		FROM   oe_order_holds
		WHERE  order_hold_id = l_order_hold_id
		FOR UPDATE NOWAIT;

		OPEN	c_hold_sources(l_hold_source_id);
		LOOP

			FETCH c_hold_sources INTO  l_hold_source_id;
			EXIT WHEN c_hold_sources%NOTFOUND           -- end of fetch
			OR c_hold_sources%NOTFOUND IS NULL;  -- empty cursor

			-- Lock the order holds source record.
			SELECT hold_source_id
			INTO   l_lock_hold_source_id
			FROM   oe_hold_sources
			WHERE  hold_source_id = l_hold_source_id
			FOR UPDATE NOWAIT;

			DELETE FROM OE_HOLD_SOURCES
			WHERE HOLD_SOURCE_ID = l_hold_source_id;

		END LOOP;
		oe_debug_pub.add('Number of hold sources deleted : '||to_char(c_hold_sources%ROWCOUNT),1);
		CLOSE c_hold_sources;

		OPEN	c_hold_releases(l_hold_release_id);
		LOOP

			FETCH c_hold_releases INTO  l_hold_release_id;
			EXIT WHEN c_hold_releases%NOTFOUND           -- end of fetch
			OR c_hold_releases%NOTFOUND IS NULL;  -- empty cursor
                        --bug 6148214
                        select count(*) into l_count from OE_ORDER_HOLDS where
                          hold_release_id = l_hold_release_id and HEADER_ID <> p_header_id;
                        IF (l_count = 0) THEN
			 -- Lock the order holds release record.
			  SELECT hold_release_id
			  INTO   l_lock_hold_release_id
			  FROM   oe_hold_releases
			  WHERE  hold_release_id = l_hold_release_id
			  FOR UPDATE NOWAIT;

			  DELETE FROM OE_HOLD_RELEASES
			  WHERE HOLD_RELEASE_ID = l_hold_release_id;
			END IF;
		END LOOP;
		oe_debug_pub.add('Number of hold releases deleted : '||to_char(c_hold_releases%ROWCOUNT),1);
		CLOSE c_hold_releases;

		DELETE FROM OE_ORDER_HOLDS
		WHERE ORDER_HOLD_ID = l_order_hold_id;

 	END LOOP;

	oe_debug_pub.add('Number of order holds deleted : '||to_char(c_order_holds%ROWCOUNT),1);
	CLOSE c_order_holds;

	oe_debug_pub.add('Exiting OE_ORDER_PURGE_PVT.OE_Purge_Order_Holds : ');
	RETURN FND_API.G_RET_STS_SUCCESS;

EXCEPTION                   --  Exception handler to record error

	WHEN OTHERS THEN
		l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		ROLLBACK TO SAVEPOINT ORDER_HEADER;
		record_errors( l_return_status
		,p_purge_set_id
		,p_header_id
		,'ORDPUR: Order Holds '||substr(sqlerrm,1,200)
		);
		CLOSE c_order_holds;
		RETURN l_return_status;

END OE_Purge_Order_Holds;

FUNCTION OE_Purge_RMA_Line_Receipts
(    p_purge_set_id 	IN 	NUMBER
,	p_header_id		IN	NUMBER
,	p_line_id			IN	NUMBER)
RETURN VARCHAR2
IS
	l_return_status	VARCHAR2(10);
	l_message			VARCHAR2(2000);
BEGIN
	oe_debug_pub.add('Entering OE_ORDER_PURGE_PVT.OE_Purge_RMA_Line_Receipts: '||to_char(p_line_id));

       RCV_RMA_RCPT_PURGE.Purge_Receipts(p_line_id,l_return_status,l_message);

       IF l_return_status = 'FALSE' THEN
          RETURN FND_API.G_RET_STS_ERROR;
       END IF;

	oe_debug_pub.add('Exiting OE_ORDER_PURGE_PVT.OE_Purge_RMA_Line_Receipts.');
	RETURN FND_API.G_RET_STS_SUCCESS;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
		l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		ROLLBACK TO SAVEPOINT ORDER_HEADER;
          IF l_message is not null then
			record_errors( l_return_status
			,p_purge_set_id
			,p_header_id
			,l_message
			);
          else
			record_errors( l_return_status
			,p_purge_set_id
			,p_header_id
			,'ORDPUR: OE_Purge_RMA_Line_Receipts'||substr(sqlerrm,1,200)
			);
		end if;

		RETURN l_return_status;

END OE_Purge_RMA_Line_Receipts;

FUNCTION OE_Purge_RMA_Line_Lot_Srl
(    p_purge_set_id 	IN 	NUMBER
,	p_header_id		IN	NUMBER
,	p_line_id			IN	NUMBER)
RETURN VARCHAR2
IS
CURSOR    c_line_lot_serials IS
     SELECT    lot_serial_id
     FROM      oe_lot_serial_numbers
     WHERE     LINE_ID = p_line_id;

     l_lot_serial_id        NUMBER;
     l_lock_lot_serial_id   NUMBER;
     l_return_status        VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
	l_message			VARCHAR2(2000);
BEGIN
	oe_debug_pub.add('Entering OE_ORDER_PURGE_PVT.OE_Purge_RMA_Line_Lot_Srl: '||to_char(p_line_id));


     OPEN c_line_lot_serials;

     LOOP
          FETCH c_line_lot_serials INTO  l_lot_serial_id;
          EXIT WHEN c_line_lot_serials%NOTFOUND           -- end of fetch
          OR c_line_lot_serials%NOTFOUND IS NULL;  -- empty cursor

          -- Lock the sales credits record.
          SELECT lot_serial_id
          INTO   l_lock_lot_serial_id
          FROM   oe_lot_serial_numbers
          WHERE  lot_serial_id = l_lot_serial_id
          FOR UPDATE NOWAIT;

		delete from oe_lot_serial_numbers
		where lot_serial_id = l_lot_serial_id;

     END LOOP;

     CLOSE c_line_lot_serials;

	oe_debug_pub.add('Exiting OE_ORDER_PURGE_PVT.OE_Purge_RMA_Line_Lot_Srl.');
	RETURN FND_API.G_RET_STS_SUCCESS;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
		l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		ROLLBACK TO SAVEPOINT ORDER_HEADER;
		record_errors( l_return_status
		,p_purge_set_id
		,p_header_id
		,'ORDPUR: OE_Purge_RMA_Line_Lot_Srl'||substr(sqlerrm,1,200)
		);
		CLOSE c_line_lot_serials;
		RETURN l_return_status;

END OE_Purge_RMA_Line_Lot_Srl;


PROCEDURE Record_Errors
(
	p_return_status			IN VARCHAR2
,	p_purge_set_id			IN NUMBER
,	p_header_id				IN NUMBER
,	p_error_message			IN VARCHAR2 )
IS

BEGIN

	oe_debug_pub.add('Error Message : '||p_error_message);
	UPDATE oe_purge_orders
	SET ERROR_TEXT = p_error_message
	,IS_PURGED = 'N'
	WHERE purge_set_id = p_purge_set_id
	AND   header_id  = p_header_id;

	IF 	p_return_status <> FND_API.G_RET_STS_SUCCESS  -- If writting a SQL error
	THEN                     -- then commit the record
		COMMIT;             -- else (assume) it is commited by the caller
	END IF;

END Record_Errors;

-- Linda: added for multiple payments
FUNCTION OE_Purge_Header_Payments
( p_purge_set_id  	IN      NUMBER
, p_header_id           IN      NUMBER)
RETURN VARCHAR2 IS

l_header_id		NUMBER;
l_lock_header_id	NUMBER;
l_payment_number        NUMBER;

l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

Cursor c_header_pmts IS
Select	payment_number
From	oe_payments
Where	header_id = p_header_id
and     line_id is null
FOR UPDATE NOWAIT;

BEGIN

   OPEN c_header_pmts;
    LOOP

      FETCH c_header_pmts into l_payment_number;
      EXIT WHEN c_header_pmts%NOTFOUND or c_header_pmts%NOTFOUND is NULL;

      Delete from oe_payments
      Where  header_id = p_header_id
      and nvl(payment_number,0) = nvl(l_payment_number,0);

    END LOOP;
    CLOSE c_header_pmts;

   RETURN FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN OTHERS THEN
		l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		ROLLBACK TO SAVEPOINT ORDER_HEADER;
		record_errors( l_return_status
		,p_purge_set_id
		,p_header_id
		,'ORDPUR: Header Payments '||substr(sqlerrm,1,200)
		);
		CLOSE c_header_pmts;
		RETURN l_return_status;
END OE_Purge_Header_Payments;

-- Added for multiple payments
FUNCTION OE_Purge_Line_Payments
( p_purge_set_id  	IN      NUMBER
, p_header_id           IN      NUMBER
, p_line_id		IN      NUMBER)
RETURN VARCHAR2 IS

l_line_id		NUMBER;
l_lock_line_id		NUMBER;
l_pmt_count             NUMBER;
l_payment_number        NUMBER;
l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

cursor c_lock_pmts is
select payment_number
from oe_payments
where line_id = p_line_id
and   header_id = p_header_id
FOR UPDATE NOWAIT;

BEGIN

    OPEN c_lock_pmts;
    LOOP

      FETCH c_lock_pmts into l_payment_number;
      EXIT WHEN c_lock_pmts%NOTFOUND or c_lock_pmts%NOTFOUND is NULL;

      Delete from oe_payments
      Where  line_id = p_line_id
      and nvl(payment_number,0) = nvl(l_payment_number,0);

    END LOOP;
    CLOSE c_lock_pmts;

   RETURN FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN OTHERS THEN
		l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		ROLLBACK TO SAVEPOINT ORDER_HEADER;
		record_errors( l_return_status
		,p_purge_set_id
		,p_line_id
		,'ORDPUR: Line Payments '||substr(sqlerrm,1,200)
		);
		CLOSE c_lock_pmts;
		RETURN l_return_status;

END OE_Purge_Line_Payments;


-- This procedure is called from the OEXOEPUR.pld .
-- This checks if the Order is eligible for Purging.

PROCEDURE check_is_purgable(  p_purge_set_id          IN NUMBER
                            , p_header_id             IN NUMBER
                            , p_order_number          IN NUMBER
                            , p_order_type_name       IN VARCHAR2
			    , p_quote_number          IN NUMBER
			    , p_is_purgable           OUT NOCOPY VARCHAR2
			    , p_error_message         OUT NOCOPY VARCHAR2
     			    ) IS


	l_return_status		 VARCHAR2(1) := FND_API.G_TRUE;
	l_error_message 	 VARCHAR2(2000);
	l_temp_mesg 		 VARCHAR2(2000);
	l_is_purgable  		 VARCHAR2(1);
	l_order_type_name	 VARCHAR2(30);
        l_flow_status            VARCHAR2(80);
        l_transaction_phase_code VARCHAR2(1);
        l_cnt                    NUMBER;

 CURSOR cur_transaction_code IS
   SELECT transaction_phase_code
   FROM   oe_order_headers
   WHERE  header_id=p_header_id;

  BEGIN

  -- Setting a Multiple Org access.
       mo_global.init('ONT');

  --Quote purge changes.To Select Transaction Phase code

   OPEN cur_transaction_code ;
   FETCH cur_transaction_code INTO l_transaction_phase_code;


   IF (cur_transaction_code%NOTFOUND) THEN

     CLOSE cur_transaction_code;

     IF (p_order_number IS NOT NULL) THEN
       FND_MESSAGE.SET_NAME('ONT','ONT_ORDER_ALREADY_PURGED');
       FND_MESSAGE.SET_TOKEN('ORDER', p_order_number);
     ELSE
       FND_MESSAGE.SET_NAME('ONT','ONT_ORDER_ALREADY_PURGED');
       FND_MESSAGE.SET_TOKEN('ORDER', p_quote_number);
     END IF;

     l_temp_mesg := FND_MESSAGE.GET_ENCODED;
     FND_MESSAGE.SET_ENCODED(l_temp_mesg);
     l_error_message := FND_MESSAGE.GET;
     p_error_message := l_error_message;
     p_is_purgable := 'N';
     RETURN;
   ELSE
     CLOSE cur_transaction_code;
   END IF;




   IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510'
                        AND nvl(l_transaction_phase_code,'F')='N' THEN

	IF      l_return_status = FND_API.G_TRUE THEN

                FND_MESSAGE.SET_NAME('ONT','OE_PUR_OPEN_QUOTE');
                l_temp_mesg := FND_MESSAGE.GET_ENCODED;
                FND_MESSAGE.SET_ENCODED(l_temp_mesg);
                l_error_message := FND_MESSAGE.GET;
                l_return_status := OE_ORDER_PURGE_PVT.Check_Open_Quotes(p_header_id);

        END IF;

       ELSE

	  IF l_return_status = FND_API.G_TRUE THEN
		FND_MESSAGE.SET_NAME('ONT','OE_PUR_OPEN_ORDER');
         	l_temp_mesg := FND_MESSAGE.GET_ENCODED;
		FND_MESSAGE.SET_ENCODED(l_temp_mesg);
	 	l_error_message := FND_MESSAGE.GET;
		l_return_status := OE_ORDER_PURGE_PVT.Check_Open_Orders( p_header_id);
  	 END IF;

  	  IF l_return_status = FND_API.G_TRUE THEN

    		SELECT otl.name
    		INTO   l_order_type_name
    		FROM   oe_transaction_types_tl otl,
           	       oe_order_headers ooh
    		WHERE  otl.language = (SELECT language_code
         		                 FROM fnd_languages
              		            WHERE installed_flag = 'B')
    		AND    otl.transaction_type_id = ooh.order_type_id
    		AND    ooh.header_id = p_header_id;

		FND_MESSAGE.SET_NAME('ONT','OE_PUR_OPEN_INVOICES');
      	        l_temp_mesg := FND_MESSAGE.GET_ENCODED;
		FND_MESSAGE.SET_ENCODED(l_temp_mesg);
	 	l_error_message := FND_MESSAGE.GET;
		l_return_status := OE_ORDER_PURGE_PVT.check_open_invoiced_orders
		( TO_CHAR(p_order_number), l_order_type_name );
  	  END IF;


 	    IF  l_return_status = FND_API.G_TRUE THEN
		FND_MESSAGE.SET_NAME('ONT','OE_PUR_OPEN_RETURNS');
      	        l_temp_mesg := FND_MESSAGE.GET_ENCODED;
		FND_MESSAGE.SET_ENCODED(l_temp_mesg);
	 	l_error_message := FND_MESSAGE.GET;
		l_return_status := OE_ORDER_PURGE_PVT.check_open_returns
		(p_order_number, p_order_type_name);
 	     END IF;


	    IF l_return_status = FND_API.G_TRUE THEN
		Check_Open_RMA_Receipts(p_header_id,l_return_status, l_error_message);
	    END IF;



        IF   l_return_status = FND_API.G_TRUE THEN
               FND_MESSAGE.SET_NAME('ONT','OE_PUR_OPEN_DELIVERIES');
               l_temp_mesg := FND_MESSAGE.GET_ENCODED;
               FND_MESSAGE.SET_ENCODED(l_temp_mesg);
               l_error_message := FND_MESSAGE.GET;

                SELECT count(*)
                INTO l_cnt
                FROM wsh_delivery_details dd,
                     oe_order_lines l
                WHERE l.header_id = p_header_id
                AND   dd.source_line_id = l.line_id
		AND   dd.org_id = l.org_id
                AND   dd.source_code = 'OE'
                AND   (nvl(dd.released_status, 'N') not in ('C', 'D') or
                       ( dd.released_status = 'C' and
                        ( nvl(dd.inv_interfaced_flag, 'N')  in ( 'N','P') or
                          nvl(dd.oe_interfaced_flag, 'N')  in ( 'N','P')
                        )
                       )
                      );
                IF l_cnt > 0 THEN
                  l_return_status := FND_API.G_FALSE;
                END IF;
         END IF;


        IF      l_return_status = FND_API.G_TRUE THEN

                IF PO_CODE_RELEASE_GRP.Current_Release >=
                           PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J AND
                              OE_CODE_CONTROL.Code_Release_Level  >= '110510' THEN

                    l_return_status :=
                         OE_ORDER_PURGE_PVT.Check_Open_PO_Reqs_Dropship
                                           (p_header_id       => p_header_id );

                    IF l_return_status = FND_API.G_FALSE THEN

                       FND_MESSAGE.SET_NAME('ONT','OE_PURGE_OPEN_PO_REQ');
      	               l_temp_mesg := FND_MESSAGE.GET_ENCODED;
		       FND_MESSAGE.SET_ENCODED(l_temp_mesg);
	               l_error_message := FND_MESSAGE.GET;

                    END IF;

                END IF;
        END IF;

      END IF;

	IF 	l_return_status = FND_API.G_TRUE THEN
		p_error_message := NULL;
		p_is_purgable := 'Y' ;

	ELSE
		p_error_message := l_error_message;
		p_is_purgable := 'N';
	END IF;

  END check_is_purgable;


END OE_Order_Purge_PVT;

/
