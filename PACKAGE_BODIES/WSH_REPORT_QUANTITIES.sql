--------------------------------------------------------
--  DDL for Package Body WSH_REPORT_QUANTITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_REPORT_QUANTITIES" AS
/* $Header: WSHUTRQB.pls 115.6 99/07/16 08:24:09 porting shi $ */


-- NAME: populate_temp_table
-- DESC: populated the temporary table with all the lines and their shipped
--       quantity this commits the records on creation
-- ARGS: report_id  = must be a unique id, usual the request id of a conc prog.
--       p_mode     = either PAK ir INV. calculates extra values if in one of
--                    these.
--       p_departure_id
--       p_delivery_id
--       p_order_line
--       p_asn      = will limit the Ship Qty to to this asn or greater
--       p_upd_ship = Update shipping flag: use this to reflect whether
--                    you want the sq to be calculated only if update shipping
--                    has run. Therefore if 'Y' then it will return zero if
--                    update shipping has not run otherwise it return the
--                    SC quantity.
--       p_debug    = Flag to turn debugging information ON  or OFF
--
PROCEDURE POPULATE_TEMP_TABLE (p_report_id IN NUMBER,
                               p_mode IN VARCHAR2 DEFAULT NULL,
                               p_departure_id IN NUMBER DEFAULT NULL,
                               p_delivery_id IN NUMBER DEFAULT NULL,
                               p_order_line IN NUMBER DEFAULT NULL,
                               p_asn IN NUMBER DEFAULT NULL,
                               p_upd_ship IN VARCHAR2 DEFAULT 'N',
                               p_debug IN VARCHAR2 DEFAULT 'OFF') is
BEGIN

   DECLARE

   l_dep_id               NUMBER:= NULL;
   l_shipped_td           NUMBER:= NULL;
   l_already_shipped      NUMBER:= NULL;
   l_sql_statement        VARCHAR2(2000);
   l_cursor               INTEGER;
   l_records_fetched      NUMBER;

   l_f_dep_id             NUMBER;
   l_f_del_id             NUMBER;
   l_f_asn                NUMBER;
   l_f_pick_line_id       NUMBER;
   l_f_line_id            NUMBER;
   l_f_comp_code          VARCHAR2(1000);
   l_f_comp_ratio         NUMBER;
   l_f_comp_seq_id        NUMBER;
   l_f_unit_code          VARCHAR2(30);
   l_f_warehouse_id       NUMBER;
   l_f_item_id            NUMBER;
   l_f_cust_item_id       NUMBER;
   l_f_ship_to_contact_id NUMBER;
   l_f_shipped_qty        NUMBER;

   CURSOR SHIPPED_QUANTITIES (l_asn_num IN NUMBER,
                              l_pl_id     IN NUMBER) IS
   SELECT NVL(SUM(DECODE(p_upd_ship,'Y',
          DECODE(PH.STATUS_CODE,'PENDING',0,'OPEN',0, PLD.SHIPPED_QUANTITY), PLD.SHIPPED_QUANTITY)), 0) SHIPPED_TD,
		NVL(SUM(DECODE(D.ASN_SEQ_NUMBER,l_asn_num,0, DECODE(p_upd_ship,'Y', DECODE(PH.STATUS_CODE,'PENDING',0,'OPEN',0, PLD.  SHIPPED_QUANTITY), PLD.SHIPPED_QUANTITY))), 0) ALREADY_SHIPPED
   FROM   SO_PICKING_HEADERS_ALL PH
   ,      SO_PICKING_LINES_ALL PL2
   ,      SO_PICKING_LINES_ALL PL1
   ,      SO_PICKING_LINE_DETAILS PLD
   ,      WSH_DELIVERIES D
   WHERE  PH.PICKING_HEADER_ID  = PL2.PICKING_HEADER_ID
   AND    PL2.PICKING_LINE_ID = PLD.PICKING_LINE_ID
   AND    PL1.PICKING_LINE_ID = l_pl_id
   AND    PL1.ORDER_LINE_ID = PL2.ORDER_LINE_ID
   AND    D.DELIVERY_ID = PLD.DELIVERY_ID
   AND    DECODE(l_asn_num,NULL,-1,D.ASN_SEQ_NUMBER) <= nvl(l_asn_num,-1);

   BEGIN

   IF p_debug = 'ON' THEN

      --dbms_output.enable(1000000);
      --dbms_output.put_line('POPULATE_TEMP_TABLE Parameters: '||
      --                   'Report Id: '   || p_report_id    ||', '||
      --                   'Mode: '        || p_mode         ||', '||
      --                   'Departure Id: '|| p_departure_id ||', '||
      --                   'Delivery Id: ' || p_delivery_id  ||', '||
      --                   'Line Id: '     || p_order_line   ||', '||
      --                   'ASN: '         || p_asn          ||', '||
      --                   'Update Ship: ' || p_upd_ship     );
      null;

   END IF;

   -- If asn is given, select only those lines in this asn else select all
   -- picking line details since, and including, this ASN but group by dep,
   -- del/asn. We may have the same item in different parts of the model so
   -- group by component code

   -- Building main picking lines cursor to resolve a performance problem with
   -- the old cursor statement which was causing a full table scan on
   -- SO_PICKING_LINE_DETAILS

   l_sql_statement := 'SELECT PLD.DEPARTURE_ID'||
                      ',      PLD.DELIVERY_ID'||
                      ',      D.ASN_SEQ_NUMBER'||
                      ',      PL.PICKING_LINE_ID'||
                      ',      PL.ORDER_LINE_ID'||
                      ',      PL.COMPONENT_CODE'||
                      ',      PL.COMPONENT_RATIO'||
                      ',      PL.COMPONENT_SEQUENCE_ID'||
                      ',      PL.UNIT_CODE'||
                      ',      PL.WAREHOUSE_ID'||
                      ',      PL.INVENTORY_ITEM_ID'||
                      ',      PL.CUSTOMER_ITEM_ID'||
                      ',      PL.SHIP_TO_CONTACT_ID'||
                      ',      NVL(SUM(DECODE(:p_upd_ship,''Y'','||
                      '                      DECODE(PH.STATUS_CODE,''PENDING'',0,''OPEN'',0, PLD.SHIPPED_QUANTITY),'||
                      '                      PLD.SHIPPED_QUANTITY)),'||
                      '           0)'||
                      'FROM   WSH_DELIVERIES D'||
                      ',      SO_PICKING_HEADERS_ALL PH'||
                      ',      SO_PICKING_LINES_ALL PL'||
                      ',      SO_PICKING_LINE_DETAILS PLD '||
                      'WHERE  PH.PICKING_HEADER_ID  = PL.PICKING_HEADER_ID '||
                      'AND    PL.PICKING_LINE_ID = PLD.PICKING_LINE_ID '||
                      'AND    PLD.DELIVERY_ID = D.DELIVERY_ID ';

   -- Only attach the bind variables where clause statements if the variables
   -- are not null

   IF (p_departure_id IS NOT NULL) THEN
      l_sql_statement := l_sql_statement ||
                         'AND    PLD.DEPARTURE_ID =  :p_departure_id ';
   END IF;

   IF (p_delivery_id IS NOT NULL) THEN
      l_sql_statement := l_sql_statement ||
                         'AND    PLD.DELIVERY_ID  =  :p_delivery_id ';
   END IF;

   IF (p_order_line IS NOT NULL) THEN
      l_sql_statement := l_sql_statement ||
                         'AND    PL.ORDER_LINE_ID =  :p_order_line ';
   END IF;

   IF (p_asn IS NOT NULL) THEN

      -- If the mode is ORDERLINE then we are being called by Automotive
      -- and they require to view shipments that happened for any ASN
      -- following the current one.
      --
      -- If the mode is not ORDERLINE include the passed ASN shipments into
      -- the quantity calculations

      IF (p_mode = 'ORDERLINE') THEN
         l_sql_statement := l_sql_statement ||
                            'AND    D.ASN_SEQ_NUMBER > :p_asn ';
      ELSE
         l_sql_statement := l_sql_statement ||
                            'AND    D.ASN_SEQ_NUMBER >= :p_asn ';
      END IF;

   END IF;

   l_sql_statement := l_sql_statement ||
                      'GROUP BY PLD.DEPARTURE_ID'||
                      ',      PLD.DELIVERY_ID'||
                      ',      D.ASN_SEQ_NUMBER'||
                      ',      PL.PICKING_LINE_ID '||
                      ',      PL.ORDER_LINE_ID '||
                      ',      PL.COMPONENT_CODE'||
                      ',      PL.COMPONENT_RATIO'||
                      ',      PL.COMPONENT_SEQUENCE_ID'||
                      ',      PL.UNIT_CODE'||
                      ',      PL.WAREHOUSE_ID'||
                      ',      PL.INVENTORY_ITEM_ID'||
                      ',      PL.CUSTOMER_ITEM_ID'||
                      ',      PL.SHIP_TO_CONTACT_ID '||
                      'ORDER BY PL.ORDER_LINE_ID';

   IF p_debug = 'ON' THEN

      -- Print SQL statement executed

      --dbms_output.enable(1000000);
      --dbms_output.put_line(substr(l_sql_statement,1,255));
      --dbms_output.put_line(substr(l_sql_statement,256,255));
      --dbms_output.put_line(substr(l_sql_statement,511,255));
      --dbms_output.put_line(substr(l_sql_statement,766,255));
      --dbms_output.put_line(substr(l_sql_statement,1021,255));
      --dbms_output.put_line(substr(l_sql_statement,1276,255));
      null;

   END IF;

   l_cursor := dbms_sql.open_cursor;
   dbms_sql.parse(l_cursor,l_sql_statement,dbms_sql.v7);

   dbms_sql.bind_variable(l_cursor,'p_upd_ship',p_upd_ship);

   IF (p_departure_id IS NOT NULL) THEN
      dbms_sql.bind_variable(l_cursor,'p_departure_id',p_departure_id);
   END IF;

   IF (p_delivery_id IS NOT NULL) THEN
      dbms_sql.bind_variable(l_cursor,'p_delivery_id',p_delivery_id);
   END IF;

   IF (p_order_line IS NOT NULL) THEN
      dbms_sql.bind_variable(l_cursor,'p_order_line',p_order_line);
   END IF;

   IF (p_asn IS NOT NULL) THEN
      dbms_sql.bind_variable(l_cursor,'p_asn',p_asn);
   END IF;

   dbms_sql.define_column(l_cursor,1,l_f_dep_id);
   dbms_sql.define_column(l_cursor,2,l_f_del_id);
   dbms_sql.define_column(l_cursor,3,l_f_asn);
   dbms_sql.define_column(l_cursor,4,l_f_pick_line_id);
   dbms_sql.define_column(l_cursor,5,l_f_line_id);
   dbms_sql.define_column(l_cursor,6,l_f_comp_code,1000);
   dbms_sql.define_column(l_cursor,7,l_f_comp_ratio);
   dbms_sql.define_column(l_cursor,8,l_f_comp_seq_id);
   dbms_sql.define_column(l_cursor,9,l_f_unit_code,30);
   dbms_sql.define_column(l_cursor,10,l_f_warehouse_id);
   dbms_sql.define_column(l_cursor,11,l_f_item_id);
   dbms_sql.define_column(l_cursor,12,l_f_cust_item_id);
   dbms_sql.define_column(l_cursor,13,l_f_ship_to_contact_id);
   dbms_sql.define_column(l_cursor,14,l_f_shipped_qty);

   l_records_fetched := dbms_sql.execute(l_cursor);

   WHILE (dbms_sql.fetch_rows(l_cursor) > 0) LOOP

      dbms_sql.column_value(l_cursor,1,l_f_dep_id);
      dbms_sql.column_value(l_cursor,2,l_f_del_id);
      dbms_sql.column_value(l_cursor,3,l_f_asn);
      dbms_sql.column_value(l_cursor,4,l_f_pick_line_id);
      dbms_sql.column_value(l_cursor,5,l_f_line_id);
      dbms_sql.column_value(l_cursor,6,l_f_comp_code);
      dbms_sql.column_value(l_cursor,7,l_f_comp_ratio);
      dbms_sql.column_value(l_cursor,8,l_f_comp_seq_id);
      dbms_sql.column_value(l_cursor,9,l_f_unit_code);
      dbms_sql.column_value(l_cursor,10,l_f_warehouse_id);
      dbms_sql.column_value(l_cursor,11,l_f_item_id);
      dbms_sql.column_value(l_cursor,12,l_f_cust_item_id);
      dbms_sql.column_value(l_cursor,13,l_f_ship_to_contact_id);
      dbms_sql.column_value(l_cursor,14,l_f_shipped_qty);

      OPEN  SHIPPED_QUANTITIES (l_f_asn, l_f_pick_line_id);
      FETCH SHIPPED_QUANTITIES INTO l_shipped_td, l_already_shipped;
      CLOSE SHIPPED_QUANTITIES;

      INSERT INTO WSH_REPORT_TEMP
      (      REPORT_TEMP_ID
      ,      DEPARTURE_ID
      ,      DELIVERY_ID
      ,      SHIPPED_FLAG
      ,      LINE_ID
      ,      ITEM_INDENTATION
      ,      COMPONENT_CODE
      ,      COMPONENT_RATIO
      ,      COMPONENT_SEQUENCE_ID
      ,      ORGANIZATION_ID
      ,      INVENTORY_ITEM_ID
      ,      CUSTOMER_ITEM_ID
      ,      SHIP_TO_CONTACT_ID
      ,      SHIPPED_QUANTITY
      ,      TOTAL_SHIPPED_TODATE
      ,      TOTAL_ALREADY_SHIPPED
      ,      QUANTITY_TO_INVOICE
      ,      UNIT_OF_MEASURE
      ,      CREATION_DATE
      ,      CREATED_BY
      ,      LAST_UPDATE_DATE
      ,      LAST_UPDATED_BY)
      VALUES
      (      p_report_id
      ,      l_f_dep_id
      ,      l_f_del_id
      ,      'Y'
      ,      l_f_line_id
      ,      NVL(LENGTH(TRANSLATE(l_f_comp_code,'X1234567890','X')),0)+1
      ,      l_f_comp_code
      ,      l_f_comp_ratio
      ,      l_f_comp_seq_id
      ,      l_f_warehouse_id
      ,      l_f_item_id
      ,      l_f_cust_item_id
      ,      l_f_ship_to_contact_id
      ,      l_f_shipped_qty
      ,      l_shipped_td
      ,      l_already_shipped
      ,      l_f_shipped_qty
      ,      l_f_unit_code
      ,      SYSDATE
      ,      FND_GLOBAL.USER_ID
      ,      SYSDATE
      ,      FND_GLOBAL.USER_ID);

      -- For this picking line, add the order line to temp table if it hasn't
      -- already been added
      --
      -- NOTE: this could be an area for improving performance - we may want
      --       to call this out of the loop

      -- BUG 787126 : Adding p_mode to INSERT_ORDER_LINE to restrict ATO explosion
      --              only for PACK SLIP
      INSERT_ORDER_LINE(p_report_id, l_f_dep_id, l_f_del_id,l_f_line_id,p_mode);

      -- Departure_id may have been null when called so assign it here

      l_dep_id := l_f_dep_id;

   END LOOP;

   dbms_sql.close_cursor(l_cursor);

   -- Update any detail, line and header attributes
   -- Index on the INVENTORY_ITEM_ID for SO_LINE_DETAILS table is turned off
   -- deliberately to make sure the index on LINE_ID is used.

   UPDATE WSH_REPORT_TEMP R
   SET
   (      R.CONFIGURATION_ITEM_FLAG
   ,      R.REQUIRED_FOR_REVENUE_FLAG
   ,      R.COMPONENT_RATIO
   ,      R.ORDERED_QUANTITY
   ,      R.SELLING_PRICE
   ,      R.ORDER_NUMBER
   ,      R.PURCHASE_ORDER_NUM
   ,      R.CURRENCY_CODE ) =
        ( SELECT MAX(LD.CONFIGURATION_ITEM_FLAG)
          ,      MAX(LD.REQUIRED_FOR_REVENUE_FLAG)
          ,      DECODE(R.COMPONENT_RATIO,'',MAX(LD.COMPONENT_RATIO),
                        R.COMPONENT_RATIO)
          ,      L.ORDERED_QUANTITY * NVL(R.COMPONENT_RATIO,1)
          ,      L.SELLING_PRICE
          ,      H.ORDER_NUMBER
          ,      H.PURCHASE_ORDER_NUM
          ,      H.CURRENCY_CODE
          FROM   SO_LINE_DETAILS LD
          ,      SO_HEADERS_ALL H
          ,      SO_LINES_ALL L
          WHERE  H.HEADER_ID = L.HEADER_ID
          AND    L.LINE_ID =  LD.LINE_ID
          AND    LD.LINE_ID = R.LINE_ID
          AND    LD.INVENTORY_ITEM_ID+0 = R.INVENTORY_ITEM_ID
          GROUP  BY L.ORDERED_QUANTITY * NVL(R.COMPONENT_RATIO,1)
          ,      L.SELLING_PRICE
          ,      H.ORDER_NUMBER
          ,      H.PURCHASE_ORDER_NUM
          ,      H.CURRENCY_CODE )
   ,      R.INCLUDE_ON_SHIP_DOCS =
        ( SELECT BOM.INCLUDE_ON_SHIP_DOCS
          FROM   BOM_INVENTORY_COMPONENTS BOM
          WHERE  BOM.COMPONENT_SEQUENCE_ID = R.COMPONENT_SEQUENCE_ID
          AND    p_mode IN ('PAK','INV'))
   WHERE  R.REPORT_TEMP_ID = p_report_id
   AND    R.DEPARTURE_ID = l_dep_id;


   ADD_NON_SHIP_LINES(p_report_id);
   SET_SHIPPED_QUANTITY(p_report_id);

   -- BUG : 787126 : Commenting out the following code as we want
   --                to print the config items and option classes.
/*
   IF p_mode = 'PAK' THEN

      -- Dont print any config items (the report prints the actual model
      -- instead) or option classes on the pack slip

      UPDATE WSH_REPORT_TEMP R
      SET    R.INCLUDE_ON_SHIP_DOCS = 0
      WHERE  R.REPORT_TEMP_ID = p_report_id
      AND    R.DEPARTURE_ID = l_dep_id
      AND   (R.CONFIGURATION_ITEM_FLAG = 'Y'
             OR
             EXISTS (SELECT NULL FROM MTL_SYSTEM_ITEMS M
                     WHERE  M.INVENTORY_ITEM_ID = R.INVENTORY_ITEM_ID
                     AND    M.ORGANIZATION_ID = R.ORGANIZATION_ID
                     AND    M.ITEM_TYPE IN ('AOC','POC','OC')));

   END IF;
*/

   -- BUG : 787126 : We do not want to print the quantities, UOM for
   --                configuration items. So set them to NULL

   IF p_mode = 'PAK' THEN

      -- Dont print any config items (the report prints the actual model
      -- instead) or option classes on the pack slip

      UPDATE WSH_REPORT_TEMP R
      SET    R.ORDERED_QUANTITY = NULL,
             R.SHIPPED_QUANTITY = NULL,
             R.TOTAL_ALREADY_SHIPPED = NULL,
             R.TOTAL_SHIPPED_TODATE = NULL,
             R.QUANTITY_TO_INVOICE = NULL,
             R.UNIT_OF_MEASURE = NULL
      WHERE  R.REPORT_TEMP_ID = p_report_id
      AND    R.DEPARTURE_ID = l_dep_id
      AND    R.CONFIGURATION_ITEM_FLAG = 'Y';

   END IF;

   -- End BUG 787126

   IF p_mode = 'INV' THEN

      -- Assign fields for commercial invoice report only

      SET_INVOICE_QUANTITY(p_report_id);

      -- Dont print any config items (the report prints the actual model
      -- instead)

      UPDATE WSH_REPORT_TEMP
      SET    INCLUDE_ON_SHIP_DOCS = 0
      WHERE  REPORT_TEMP_ID = p_report_id
      AND    DEPARTURE_ID = l_dep_id
      AND    CONFIGURATION_ITEM_FLAG = 'Y';

   END IF;

   IF p_debug = 'ON' THEN

      FOR DREC IN (SELECT * FROM WSH_REPORT_TEMP
                   WHERE REPORT_TEMP_ID = p_report_id) LOOP

          --dbms_output.enable(1000000);
          --dbms_output.put_line('Order Number: '||DREC.order_number);
          --dbms_output.put_line('Purchase Order Num: '||
          --                   DREC.purchase_order_num);
          --dbms_output.put_line('Currency Code: '||DREC.currency_code);
          --dbms_output.put_line('Line Id: '||DREC.line_id);
          --dbms_output.put_line('Include On Ship Docs: '||
          --                   DREC.include_on_ship_docs);
          --dbms_output.put_line('Configuration Item Flag: '||
          --                   DREC.configuration_item_flag);
          --dbms_output.put_line('Required For Revenue Flag: '||
          --                   DREC.required_for_revenue_flag);
          --dbms_output.put_line('Ordered Quantity: '||DREC.ordered_quantity);
          --dbms_output.put_line('Shipped Quantity: '||DREC.Shipped_quantity);
          --dbms_output.put_line('Total Shipped Todate: '||
          --                   DREC.total_shipped_todate);
          --dbms_output.put_line('Total Already Shipped: '||
          --                   DREC.total_already_shipped);
          --dbms_output.put_line('Inventory Item Id: '||DREC.inventory_item_id);
          --dbms_output.put_line('Component Code: '||DREC.component_code);
          --dbms_output.put_line('Component Ratio: '||DREC.component_ratio);
          --dbms_output.put_line('Component Sequence Id: '||
          --                   DREC.component_sequence_id);
          --dbms_output.put_line('Child Rfr Flag: '||DREC.child_rfr_flag);
          --dbms_output.put_line('Quantity To Invoice: '||
          --                   DREC.quantity_to_invoice);
          --dbms_output.put_line('Unit Of Measure: '||DREC.unit_of_measure);
          --dbms_output.put_line('Customer Item Id: '||DREC.customer_item_id);
          --dbms_output.put_line('Ship To Contact Id: '||
          --                   DREC.ship_to_contact_id);
          --dbms_output.put_line('Shipped Flag: '||DREC.shipped_flag);
          --dbms_output.put_line('Organization Id: '||DREC.organization_id);
          --dbms_output.put_line('Item Indentation: '||DREC.item_indentation);
          --dbms_output.put_line('Departure Id: '||DREC.departure_id);
          --dbms_output.put_line('Delivery Id: '||DREC.delivery_id);
          null;

      END LOOP;

   END IF;

   EXCEPTION WHEN OTHERS THEN

         -- Check if cursor for picking lines is open and if it is close it

         IF dbms_sql.is_open(l_cursor) THEN
            dbms_sql.close_cursor(l_cursor);
         END IF;

  	 FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	 FND_MESSAGE.Set_Token('PACKAGE','WSH_REPORT_QUANTITIES.populate_temp_table');
	 FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
	 APP_EXCEPTION.Raise_Exception;

   END;


END POPULATE_TEMP_TABLE;



PROCEDURE ADD_NON_SHIP_LINES (p_report_id IN NUMBER,
                              p_debug     IN VARCHAR2 DEFAULT 'OFF') IS

-- insert any items that are in so_line_details only: ie non option components
-- which are not shippable but a mandatory part of the configuration
-- (eg kits in a model, models in a model)
-- These are required so as to complete the bill stucture without which the
-- bottomup shipped_quantity calulation will not work as well as for printing
-- the complete bill

BEGIN

   DECLARE

   CURSOR NON_SHIP_LINES (l_rep_id IN NUMBER) IS
   SELECT DISTINCT RT.DEPARTURE_ID
   ,      RT.DELIVERY_ID
   ,      LD.LINE_ID
   ,      LD.COMPONENT_CODE
   ,      LD.COMPONENT_RATIO
   ,      LD.COMPONENT_SEQUENCE_ID
   ,      NVL(LENGTH(TRANSLATE(LD.COMPONENT_CODE,'X1234567890','X')),0)+1
              ITEM_INDENTATION -- strips all numerics and counts hyphen
   ,      LD.WAREHOUSE_ID
   ,      LD.INVENTORY_ITEM_ID
   ,      LD.CUSTOMER_ITEM_ID
   ,      LD.CONFIGURATION_ITEM_FLAG
   ,      LD.REQUIRED_FOR_REVENUE_FLAG
   ,      LD.UNIT_CODE
   FROM   SO_LINE_DETAILS LD
   ,      WSH_REPORT_TEMP RT
   WHERE  LD.LINE_ID = RT.LINE_ID
   AND    LD.SHIPPABLE_FLAG = 'N'
   AND    RT.REPORT_TEMP_ID = l_rep_id
   --  make sure the non shipable line detail is not an order line.
   AND    NOT EXISTS (SELECT 'ORDERED LINE'
		      FROM   SO_LINES_ALL L
		      WHERE  L.LINE_ID = LD.LINE_ID
		      AND    L.COMPONENT_CODE  =   LD.COMPONENT_CODE);
/**** always select non shippable lines irrespective if any component lines where pick releases
   and    exists (select 'shipped component line'
		  from so_picking_lines_all
		  where order_line_id in (select line_id from wsh_report_temp where report_temp_id= rep_id)
		  and component_code !=   ld.component_code
		  and component_code like ld.component_code||'%')
***/

   BEGIN

      IF p_debug = 'ON' THEN

         --dbms_output.enable(1000000);
         --dbms_output.put_line('ADD_NON_SHIP_LINES Parameters: '||
         --                   'Report Id: '   || p_report_id);
	 null;

      END IF;

      FOR NSLINE IN NON_SHIP_LINES(p_report_id) LOOP

         INSERT INTO WSH_REPORT_TEMP
         (      REPORT_TEMP_ID
         ,      DEPARTURE_ID
         ,      DELIVERY_ID
         ,      SHIPPED_FLAG
         ,      LINE_ID
         ,      ITEM_INDENTATION
         ,      ORGANIZATION_ID
         ,      INVENTORY_ITEM_ID
         ,      CUSTOMER_ITEM_ID
         ,      CONFIGURATION_ITEM_FLAG
         ,      REQUIRED_FOR_REVENUE_FLAG
         ,      COMPONENT_CODE
         ,      COMPONENT_RATIO
         ,      COMPONENT_SEQUENCE_ID
         ,      UNIT_OF_MEASURE
         ,      CREATION_DATE
         ,      CREATED_BY
         ,      LAST_UPDATE_DATE
         ,      LAST_UPDATED_BY)
         VALUES
         (      p_report_id
         ,      NSLINE.departure_id
         ,      NSLINE.delivery_id
         ,      'N'
         ,      NSLINE.line_id
         ,      NSLINE.item_indentation
         ,      NSLINE.warehouse_id
         ,      NSLINE.inventory_item_id
         ,      NSLINE.customer_item_id
         ,      NSLINE.configuration_item_flag
         ,      NSLINE.required_for_revenue_flag
         ,      NSLINE.component_code
         ,      NSLINE.component_ratio
         ,      NSLINE.component_sequence_id
         ,      NSLINE.unit_code
         ,      SYSDATE
         ,      FND_GLOBAL.USER_ID
         ,      SYSDATE
         ,      FND_GLOBAL.USER_ID);

      END LOOP;

      EXCEPTION WHEN OTHERS THEN
  	 FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	 FND_MESSAGE.Set_Token('PACKAGE','WSH_REPORT_QUANTITIES.add_non_ship_lines');
	 FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
	 APP_EXCEPTION.Raise_Exception;

      END;

END ADD_NON_SHIP_LINES;

PROCEDURE SET_SHIPPED_QUANTITY (p_report_id IN NUMBER,
                                p_debug     IN VARCHAR2 DEFAULT 'OFF') IS

-- Example: Kit with order qty = 10 sent in 3 deliveries/asn
-- below diagram shows shipped quantities:
--                   Del1           Del2               Del3
--
-- Kit:               2              1                  4     2+1+4 = 7 total
--                   / \            / \                / \           this is wrong
-- Items:           2   5          3   1              5   4

-- ShippedQty       2   5          5   6              10  10
-- AlreadyShipd     0   0          2   5               5   6
-- for the KIT
-- shipped qty todt   2              5                   10
-- alreadyShpd        0              2                    5
-- difference =       2              3                    5   2+3+5 = 10
--                                                                   this is correct


BEGIN

   DECLARE

   CURSOR MAX_LEVELS (l_rep_id IN NUMBER) IS
   SELECT MAX(ITEM_INDENTATION)
   FROM   WSH_REPORT_TEMP
   WHERE  REPORT_TEMP_ID = l_rep_id;

   l_i     NUMBER;
   l_max_l NUMBER;

   BEGIN

      IF p_debug = 'ON' THEN

         --dbms_output.enable(1000000);
         --dbms_output.put_line('SET_SHIPPED_QUANTITY Parameters: '||
         --                   'Report Id: '   || p_report_id);
	 null;

      END IF;

      -- shipped_quantity = min(total_shipped_to_date) - min(already_shipped)
      -- where to_date and already are relative to the ASN_SEQ_NUMBER
      -- which in turn is relative to the delivery.date_closed
      --
      -- note: the shipped_qty for the bottom of the BOM (the picking lines) is
      -- already set (it was selected from the picking lines). So only set the qty
      -- if it doesnt already exist
      -- also propagate the ship_to_contact_id up the BOM

      OPEN  MAX_LEVELS (p_report_id);
      FETCH MAX_LEVELS INTO l_max_l;
      CLOSE MAX_LEVELS;

      IF l_max_l > 1 THEN

         FOR l_i IN REVERSE 1..l_max_l LOOP

            UPDATE WSH_REPORT_TEMP R
            SET  ( R.TOTAL_SHIPPED_TODATE
                 , R.TOTAL_ALREADY_SHIPPED
                 , R.SHIPPED_QUANTITY
                 , R.SHIP_TO_CONTACT_ID ) =
                 ( SELECT MIN(S.TOTAL_SHIPPED_TODATE/S.COMPONENT_RATIO)
                   ,      MIN(S.TOTAL_ALREADY_SHIPPED/S.COMPONENT_RATIO)
                   ,      MIN(S.TOTAL_SHIPPED_TODATE/S.COMPONENT_RATIO) -
                          MIN(S.TOTAL_ALREADY_SHIPPED/S.COMPONENT_RATIO)
                   ,      MIN(S.SHIP_TO_CONTACT_ID)
                   FROM   WSH_REPORT_TEMP S
                   WHERE  S.REPORT_TEMP_ID = R.REPORT_TEMP_ID
                   AND    S.DELIVERY_ID = R.DELIVERY_ID
                   AND    S.ITEM_INDENTATION = R.ITEM_INDENTATION + 1
                   AND    S.COMPONENT_CODE LIKE  R. COMPONENT_CODE||'%')
            WHERE  R.ITEM_INDENTATION = l_i
            AND    R.REPORT_TEMP_ID = p_report_id
            AND    R.SHIPPED_QUANTITY IS NULL;

         END LOOP;

      END IF;

   EXCEPTION WHEN OTHERS THEN
  	 FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	 FND_MESSAGE.Set_Token('PACKAGE','WSH_REPORT_QUANTITIES.set_shipped_quantity');
	 FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
	 APP_EXCEPTION.Raise_Exception;
   END;

END SET_SHIPPED_QUANTITY;

PROCEDURE SET_INVOICE_QUANTITY (p_report_id IN NUMBER,
                                p_debug     IN VARCHAR2 DEFAULT 'OFF') IS
BEGIN
   DECLARE

   CURSOR MAX_LEVELS (l_rep_id IN NUMBER) IS
   SELECT MAX(ITEM_INDENTATION)-1
   FROM   WSH_REPORT_TEMP
   WHERE  REPORT_TEMP_ID = l_rep_id;

   l_i     NUMBER;
   l_max_l NUMBER;

   BEGIN

      IF p_debug = 'ON' THEN

         --dbms_output.enable(1000000);
         --dbms_output.put_line('SET_INVOICE_QUANTITY Parameters: '||
         --                   'Report Id: '   || p_report_id);
	 null;

      END IF;

      OPEN  MAX_LEVELS (p_report_id);
      FETCH MAX_LEVELS INTO l_max_l;
      CLOSE MAX_LEVELS;


      IF l_max_l > 0 THEN

         FOR l_i IN REVERSE 1..l_max_l LOOP

             UPDATE WSH_REPORT_TEMP R
             SET  ( R.QUANTITY_TO_INVOICE, R.CHILD_RFR_FLAG) =
                  ( SELECT MIN (S.TOTAL_SHIPPED_TODATE/S.COMPONENT_RATIO) -
                           MIN (S.TOTAL_ALREADY_SHIPPED/S.COMPONENT_RATIO)
                    ,      'Y'
                    FROM   WSH_REPORT_TEMP S
                    WHERE  S.REPORT_TEMP_ID = R.REPORT_TEMP_ID
    	            AND    S.DELIVERY_ID = R.DELIVERY_ID
    	            AND    S.ITEM_INDENTATION = R.ITEM_INDENTATION + 1
                    AND   (S.REQUIRED_FOR_REVENUE_FLAG = 'Y'
                           OR
                           S.CHILD_RFR_FLAG = 'Y')
                    AND    S.COMPONENT_CODE LIKE  R.COMPONENT_CODE||'%')
             WHERE  R.ITEM_INDENTATION = l_i
             AND    R.QUANTITY_TO_INVOICE IS NULL
             AND    R.REPORT_TEMP_ID = p_report_id;

             -- do the same select again but for not required for revenue
             -- note: the only difference between these 2 is wether it select Y or N
             -- unfortunately we cant use decode because of the group function min()

             UPDATE WSH_REPORT_TEMP R
             SET  ( R.QUANTITY_TO_INVOICE, R.CHILD_RFR_FLAG) =
                  ( SELECT MIN (S.TOTAL_SHIPPED_TODATE/S.COMPONENT_RATIO) -
                           MIN (S.TOTAL_ALREADY_SHIPPED/S.COMPONENT_RATIO)
                    ,      'N'
                    FROM   WSH_REPORT_TEMP S
    	            WHERE  S.REPORT_TEMP_ID = R.REPORT_TEMP_ID
    	            AND    S.DELIVERY_ID = R.DELIVERY_ID
    	            AND    S.ITEM_INDENTATION = R.ITEM_INDENTATION + 1
    	            AND    S.COMPONENT_CODE LIKE  R.COMPONENT_CODE||'%')
             WHERE  R.ITEM_INDENTATION = l_i
             AND    R.REPORT_TEMP_ID = p_report_id
             AND    R.QUANTITY_TO_INVOICE IS NULL;

        END LOOP;
    END IF;

    EXCEPTION WHEN OTHERS THEN
  	 FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	 FND_MESSAGE.Set_Token('PACKAGE','WSH_REPORT_QUANTITIES.set_invoice_quantity');
	 FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
	 APP_EXCEPTION.Raise_Exception;
    END;
END SET_INVOICE_QUANTITY;



-- NAME: insert_order_line
-- DESC:
-- This inserts any order lines for a picking line
-- if they havent already been added to the temp table.
-- If the order line being added has a link_to_id,
-- then this traverses up the link-to relationship.

PROCEDURE INSERT_ORDER_LINE (p_report_id    IN NUMBER,
                             p_departure_id IN NUMBER,
                             p_delivery_id  IN NUMBER,
                             p_line_id      IN NUMBER,
                             p_mode IN VARCHAR2 DEFAULT NULL,
                             p_debug        IN VARCHAR2 DEFAULT 'OFF') IS
BEGIN
   DECLARE

   CURSOR ORDER_LINES (l_rep_id IN NUMBER,
                       l_del_id IN NUMBER,
                       l_id     IN NUMBER) IS
   SELECT L.LINK_TO_LINE_ID
   ,      L.COMPONENT_CODE
   ,      L.COMPONENT_SEQUENCE_ID
   ,      L.WAREHOUSE_ID
   ,      L.INVENTORY_ITEM_ID
   ,      L.CUSTOMER_ITEM_ID
   ,      L.ORDERED_QUANTITY
   ,      L.SELLING_PRICE
   ,      L.UNIT_CODE
   ,      NVL(L.ATO_FLAG,'N')
   FROM   SO_LINES_ALL L
   WHERE  L.LINE_ID = l_id
   AND    L.LINE_TYPE_CODE IN ('DETAIL','REGULAR')
   AND    NOT EXISTS (SELECT 'ALREADY EXISTS IN TEMP TABLE'
                      FROM   WSH_REPORT_TEMP T
                      WHERE  T.REPORT_TEMP_ID = l_rep_id
                      AND    T.LINE_ID = L.LINE_ID
                      AND    T.DELIVERY_ID = l_del_id
                      AND    T.SHIPPED_FLAG = 'N');

   l_component_code        VARCHAR2(1000);
   l_component_sequence_id NUMBER;
   l_customer_item_id      NUMBER;
   l_departure_id          NUMBER;
   l_warehouse_id          NUMBER;
   l_item_id               NUMBER;
   l_link_line             NUMBER;
   l_ordered_quantity      NUMBER;
   l_selling_price         NUMBER;
   l_unit_code             VARCHAR2(3);
   l_ato_flag              VARCHAR2(1);   -- 787126

   BEGIN

   -- BUG 787126 : Added ATO_FLAG to the ORDER_LINES Cursor
   --              Since we want to explode the ATO Items

      IF p_debug = 'ON' THEN

         --dbms_output.enable(1000000);
         --dbms_output.put_line('INSERT_ORDER_LINE Parameters: '   ||
         --                   'Report Id: '    || p_report_id    ||', '||
         --                   'Departure Id: ' || p_departure_id ||', '||
         --                   'Delivery Id: '  || p_delivery_id  ||', '||
         --                   'Line Id: '      || p_line_id);
	 null;

      END IF;

      OPEN  ORDER_LINES(p_report_id, p_delivery_id, p_line_id);
      FETCH ORDER_LINES INTO l_link_line, l_component_code, l_component_sequence_id,
            l_warehouse_id, l_item_id, l_customer_item_id, l_ordered_quantity,
            l_selling_price, l_unit_code,l_ato_flag;


      IF ORDER_LINES%FOUND THEN
         INSERT INTO WSH_REPORT_TEMP
         (      REPORT_TEMP_ID
         ,      DEPARTURE_ID
         ,      DELIVERY_ID
         ,      SHIPPED_FLAG
         ,      LINE_ID
         ,      COMPONENT_CODE
         ,      COMPONENT_SEQUENCE_ID
         ,      ITEM_INDENTATION
         ,      ORGANIZATION_ID
         ,      INVENTORY_ITEM_ID
         ,      CUSTOMER_ITEM_ID
         ,      ORDERED_QUANTITY
         ,      SELLING_PRICE
         ,      UNIT_OF_MEASURE
         ,      CREATION_DATE
         ,      CREATED_BY
         ,      LAST_UPDATE_DATE
         ,      LAST_UPDATED_BY)
         SELECT p_report_id
         ,      p_departure_id
         ,      p_delivery_id
         ,      'N'
         ,      p_line_id
         ,      l_component_code
         ,      l_component_sequence_id
         ,      NVL(LENGTH(TRANSLATE(l_component_code,'X1234567890','X')),0)+1
         ,      l_warehouse_id
         ,      l_item_id
         ,      l_customer_item_id
         ,      l_ordered_quantity
         ,      l_selling_price
         ,      l_unit_code
         ,      SYSDATE
         ,      FND_GLOBAL.user_id
         ,      SYSDATE
         ,      FND_GLOBAL.user_id
         FROM   DUAL
         WHERE  NOT EXISTS
               (SELECT 'ALREADY EXISTS IN TEMP TABLE'
                FROM   WSH_REPORT_TEMP
                WHERE  REPORT_TEMP_ID = p_report_id
                AND    LINE_ID = p_line_id
                AND    DELIVERY_ID = p_delivery_id
                AND    INVENTORY_ITEM_ID = l_item_id);

         CLOSE ORDER_LINES;

         -- BUG 787126 : Explode the ATO Model top down using ATO_LINE_ID

         IF (l_ato_flag = 'Y' and p_mode = 'PAK') THEN
            INSERT_ATO_COMPONENTS(p_report_id, p_departure_id,  p_delivery_id, p_line_id,p_mode);
         END IF;

         -- END BUG 787126

         -- EXPLODE the PTO items bottom up using link to line id

         IF l_link_line IS NOT NULL THEN
            INSERT_ORDER_LINE (p_report_id, p_departure_id,  p_delivery_id, l_link_line,p_mode);
         END IF;

      ELSE
         CLOSE ORDER_LINES;
      END IF;

   EXCEPTION WHEN OTHERS THEN
  	 FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	 FND_MESSAGE.Set_Token('PACKAGE','WSH_REPORT_QUANTITIES.insert_order_line');
	 FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
	 APP_EXCEPTION.Raise_Exception;
   END;
END INSERT_ORDER_LINE;

-- BUG 787126 : New Procedure
-- NAME: insert_ato_components
-- DESC:
-- This inserts the ATO components for the order line

PROCEDURE INSERT_ATO_COMPONENTS (p_report_id    IN NUMBER,
                             p_departure_id IN NUMBER,
                             p_delivery_id  IN NUMBER,
                             p_line_id      IN NUMBER,
                             p_mode IN VARCHAR2 DEFAULT NULL,
                             p_debug        IN VARCHAR2 DEFAULT 'OFF') IS
BEGIN
   DECLARE

   CURSOR ORDER_LINES (l_rep_id IN NUMBER,
                       l_del_id IN NUMBER,
                       l_id     IN NUMBER) IS
   SELECT L.LINK_TO_LINE_ID
   ,      L.COMPONENT_CODE
   ,      L.COMPONENT_SEQUENCE_ID
   ,      L.WAREHOUSE_ID
   ,      L.INVENTORY_ITEM_ID
   ,      L.CUSTOMER_ITEM_ID
   ,      L.ORDERED_QUANTITY
   ,      L.SELLING_PRICE
   ,      L.UNIT_CODE
   ,      L.LINE_ID
   FROM   SO_LINES_ALL L
   WHERE  L.ATO_LINE_ID = l_id
   AND    L.LINE_TYPE_CODE IN ('DETAIL','REGULAR')
   AND    NOT EXISTS (SELECT 'ALREADY EXISTS IN TEMP TABLE'
                      FROM   WSH_REPORT_TEMP T
                      WHERE  T.REPORT_TEMP_ID = l_rep_id
                      AND    T.LINE_ID = L.LINE_ID
                      AND    T.DELIVERY_ID = l_del_id
                      AND    T.SHIPPED_FLAG = 'N');

   l_component_code        VARCHAR2(1000);
   l_component_sequence_id NUMBER;
   l_customer_item_id      NUMBER;
   l_departure_id          NUMBER;
   l_warehouse_id          NUMBER;
   l_item_id               NUMBER;
   l_link_line             NUMBER;
   l_ordered_quantity      NUMBER;
   l_selling_price         NUMBER;
   l_unit_code             VARCHAR2(3);
   l_line_id               NUMBER;

   BEGIN


      IF p_debug = 'ON' THEN

         --dbms_output.enable(1000000);
         --dbms_output.put_line('INSERT_ATO_COMPONENTS Parameters: '   ||
         --                   'Report Id: '    || p_report_id    ||', '||
         --                   'Departure Id: ' || p_departure_id ||', '||
         --                   'Delivery Id: '  || p_delivery_id  ||', '||
         --                   'Line Id: '      || p_line_id);
	 null;

      END IF;

      OPEN  ORDER_LINES(p_report_id, p_delivery_id, p_line_id);
      LOOP
        FETCH ORDER_LINES INTO l_link_line, l_component_code, l_component_sequence_id,
              l_warehouse_id, l_item_id, l_customer_item_id, l_ordered_quantity,
              l_selling_price, l_unit_code,l_line_id;


        EXIT WHEN ORDER_LINES%NOTFOUND;

           INSERT INTO WSH_REPORT_TEMP
           (      REPORT_TEMP_ID
           ,      DEPARTURE_ID
           ,      DELIVERY_ID
           ,      SHIPPED_FLAG
           ,      LINE_ID
           ,      COMPONENT_CODE
           ,      COMPONENT_SEQUENCE_ID
           ,      ITEM_INDENTATION
           ,      ORGANIZATION_ID
           ,      INVENTORY_ITEM_ID
           ,      CUSTOMER_ITEM_ID
           ,      ORDERED_QUANTITY
           ,      SELLING_PRICE
           ,      UNIT_OF_MEASURE
           ,      CREATION_DATE
           ,      CREATED_BY
           ,      LAST_UPDATE_DATE
           ,      LAST_UPDATED_BY)
           SELECT p_report_id
           ,      p_departure_id
           ,      p_delivery_id
           ,      'N'
           ,      l_line_id
           ,      l_component_code
           ,      l_component_sequence_id
           ,      NVL(LENGTH(TRANSLATE(l_component_code,'X1234567890','X')),0)+1
           ,      l_warehouse_id
           ,      l_item_id
           ,      l_customer_item_id
           ,      l_ordered_quantity
           ,      l_selling_price
           ,      l_unit_code
           ,      SYSDATE
           ,      FND_GLOBAL.user_id
           ,      SYSDATE
           ,      FND_GLOBAL.user_id
           FROM   DUAL
           WHERE  NOT EXISTS
                 (SELECT 'ALREADY EXISTS IN TEMP TABLE'
                  FROM   WSH_REPORT_TEMP
                  WHERE  REPORT_TEMP_ID = p_report_id
                  AND    LINE_ID = l_line_id
                  AND    DELIVERY_ID = p_delivery_id
                  AND    INVENTORY_ITEM_ID = l_item_id);


           -- EXPLODE the PTO items bottom up using link to line id

           IF l_link_line IS NOT NULL THEN
              INSERT_ORDER_LINE (p_report_id, p_departure_id,  p_delivery_id, l_link_line, p_mode);
           END IF;

         END LOOP;

         CLOSE ORDER_LINES;

   EXCEPTION WHEN OTHERS THEN
  	 FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	 FND_MESSAGE.Set_Token('PACKAGE','WSH_REPORT_QUANTITIES.insert_ato_components');
	 FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
	 APP_EXCEPTION.Raise_Exception;
   END;
END INSERT_ATO_COMPONENTS;

-- NAME: lines_shipped_quantity
-- DESC: returns the shipped quantity for a particular so_line in the
--       given asn and there after
--       this rollbacks all rows it created in the temp table at end.
-- ARGS:  p_order_line = so_lines.line_id
--        p_item_id    = item_id
--        p_asn        = asn sequence number
--        p_upd_ship = Update shipping flag: use this to reflect whether
--                     you want the sq to be calculated only if update shipping
--                     has run. Therefore if 'Y' then it will return zero if
--                     update shipping has not run otherwise it return the
--                     SC quantity.
--        p_debug      = Flag to turn debugging information ON  or OFF
--
--
--
FUNCTION  LINE_SHIPPED_QUANTITY (p_order_line IN NUMBER,
                                 p_item_id IN NUMBER,
                                 p_asn IN NUMBER,
                                 p_upd_ship IN VARCHAR2 DEFAULT 'N',
                                 p_debug IN VARCHAR2 DEFAULT 'OFF') RETURN NUMBER IS
BEGIN
   DECLARE

   l_sq     NUMBER;
   CURSOR SHIPPED_QUANTITY (l_rep_id      IN NUMBER,
                            l_ord_line_id IN NUMBER,
                            l_item_id     IN NUMBER) IS
   SELECT SUM(SHIPPED_QUANTITY)
   FROM   WSH_REPORT_TEMP
   WHERE  REPORT_TEMP_ID = l_rep_id
   AND    LINE_ID = l_ord_line_id
   AND    INVENTORY_ITEM_ID = l_item_id;

   BEGIN

      IF p_debug = 'ON' THEN

         --dbms_output.enable(1000000);
         --dbms_output.put_line('INSERT_ORDER_LINE Parameters: ' ||
         --                   'ASN: '          || p_asn        ||', '||
         --                   'Line Id: '      || p_order_line ||', '||
         --                   'Item Id: '      || p_item_id    ||', '||
         --                   'Update Ship: '  || p_upd_ship);
	 null;

      END IF;

      SAVEPOINT START_OF_FUNCTION;

      POPULATE_TEMP_TABLE (p_report_id => -100,
                           p_mode => 'ORDERLINE',
                           p_order_line => p_order_line,
                           p_asn => p_asn,
                           p_upd_ship => p_upd_ship,
                           p_debug => p_debug );

      OPEN  SHIPPED_QUANTITY (-100, p_order_line, p_item_id);
      FETCH SHIPPED_QUANTITY INTO l_sq;
      CLOSE SHIPPED_QUANTITY;

      ROLLBACK TO SAVEPOINT START_OF_FUNCTION;

      RETURN(l_sq);

   EXCEPTION WHEN OTHERS THEN
  	 FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	 FND_MESSAGE.Set_Token('PACKAGE','WSH_REPORT_QUANTITIES.line_shipped_quantity');
	 FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
	 APP_EXCEPTION.Raise_Exception;
   END;

END LINE_SHIPPED_QUANTITY;

PROCEDURE DELETE_REPORT (p_report_id IN NUMBER) IS
BEGIN

   DELETE FROM WSH_REPORT_TEMP
   WHERE  REPORT_TEMP_ID = p_report_id
   OR     CREATION_DATE < sysdate - 2;

END DELETE_REPORT;

end WSH_REPORT_QUANTITIES;

/
