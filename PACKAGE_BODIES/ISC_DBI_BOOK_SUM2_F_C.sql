--------------------------------------------------------
--  DDL for Package Body ISC_DBI_BOOK_SUM2_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_BOOK_SUM2_F_C" AS
/* $Header: ISCSCF7B.pls 120.6 2006/06/07 22:58:58 scheung noship $ */

 g_errbuf			VARCHAR2(2000) 	:= NULL;
 g_retcode			VARCHAR2(200) 	:= NULL;
 g_row_count         		NUMBER		:= 0;
 g_push_from_date		DATE 		:= NULL;
 g_push_to_date			DATE 		:= NULL;
 g_batch_size			NUMBER;
 g_degree			NUMBER		:=1;
 g_global_currency		VARCHAR2(15);
 g_global_rate_type   		VARCHAR2(15);
 g_sec_global_currency		VARCHAR2(15);
 g_sec_global_rate_type   	VARCHAR2(15);
 g_treasury_rate_type		VARCHAR2(80);
 g_global_start_date		DATE;
 g_incre_start_date		DATE;
 g_load_mode			VARCHAR2(30);
 g_warning			NUMBER		:= 0;

      -- ----------------------------------
      --  FUNCTION GET_CUST_PRODUCT_LINE_ID
      -- ----------------------------------

FUNCTION GET_CUST_PRODUCT_LINE_ID(p_sold_to_org_id   		IN NUMBER,
        			  p_service_reference_line_id 	IN NUMBER) RETURN NUMBER IS

  l_return_status  VARCHAR2(1);
  l_order_line_id  NUMBER;

BEGIN

  OE_SERVICE_UTIL.Get_Cust_Product_Line_Id
	(x_return_status         => l_return_status,
  	 p_reference_line_id     => p_service_reference_line_id,
  	 p_customer_id           => p_sold_to_org_id,
  	 x_cust_product_line_id  => l_order_line_id);

  RETURN(l_order_line_id);

EXCEPTION
  WHEN OTHERS THEN
    RETURN (NULL);

END get_cust_product_line_id;


      -- -----------------
      -- UPDATE_SALES_FACT
      -- -----------------
-- =====================================================================
-- ====== START OF INCREMENTAL COLLECTION FOR SALES CREDITS FACT =======
-- =====================================================================

FUNCTION UPDATE_SALES_FACT RETURN NUMBER IS

l_isc_schema                    VARCHAR2(30);
l_status                        VARCHAR2(30);
l_industry                      VARCHAR2(30);
l_stmt                          VARCHAR2(32000);

BEGIN


/* Insert into ISC_TMP_BOOK_SUM2 all the orders lines for orders having at least 1 line that is present in ISC_TMP_BOOK_SUM2 */
 FII_UTIL.Start_Timer;
  INSERT INTO isc_tmp_book_sum2 (pk1)
  SELECT f.line_id
    FROM isc_book_sum2_f	f
   WHERE f.header_id IN (SELECT fact.header_id
                         FROM isc_sales_credits_f	fact,
			      isc_tmp_book_sum2		tmp
                        WHERE fact.line_id = tmp.pk1
                       )
     AND NOT EXISTS (SELECT 1 FROM isc_tmp_book_sum2 a WHERE a.pk1 = f.line_id);

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Inserted '||sql%rowcount||' rows into isc_tmp_book_sum2 (updated lines) in');

/* Insert into ISC_TMP_BOOK_SUM2 order lines from ISC_SALES_CREDITS_F to be recollected because their sales credit have been deleted from OE_SALES_CREDITS */
 FII_UTIL.Start_Timer;
  INSERT INTO isc_tmp_book_sum2 (pk1)
  SELECT f.line_id
    FROM isc_book_sum2_f	f
   WHERE header_id IN (SELECT fact.header_id
                         FROM isc_sales_credits_f	fact
                        WHERE NOT EXISTS (SELECT 1 FROM oe_sales_credits WHERE sales_credit_id = fact.sales_credit_id)
                       )
     AND NOT EXISTS (SELECT 1 FROM isc_tmp_book_sum2 a WHERE a.pk1 = f.line_id);

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Inserted '||sql%rowcount||' rows into isc_tmp_book_sum2 (lines deleted from oe_sc..) in');

  COMMIT;


/* Insert into ISC_TMP_BOOK_SUM2 "SERVICE" order lines referencing parent service identified in #1 and #2 */
-- SERVICE rows whose ORDER or CUSTOMER_PRODUCT parent line_id has been updated
 FII_UTIL.Start_Timer;
  INSERT INTO ISC_TMP_BOOK_SUM2 (pk1)
  SELECT f.line_id
    FROM isc_book_sum2_f f
   WHERE f.header_id IN
	 (SELECT fact.header_id
            FROM isc_tmp_book_sum2  tmp,
                 isc_book_sum2_f        fact
           WHERE tmp.pk1 = fact.service_parent_line_id
             AND EXISTS (SELECT 1 FROM isc_book_sum2_f WHERE line_id = fact.service_parent_line_id))
         AND NOT EXISTS( SELECT 1 FROM isc_tmp_book_sum2 a WHERE a.pk1 = f.line_id);

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Inserted '||sql%rowcount||' rows into isc_tmp_book_sum2 (service_parent_line_id...) in');

  COMMIT;

-- Delete from ISC_SALES_CREDITS_F order lines that will be recollected --
 FII_UTIL.Start_Timer;
  DELETE FROM isc_sales_credits_f
   WHERE line_id in (SELECT pk1 from ISC_TMP_BOOK_SUM2);

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Deleted '||sql%rowcount||' rows from ISC_SALES_CREDITS_F in');
  COMMIT;
/* Insert into ISC_SALES_CREDITS_F */
 BIS_COLLECTION_UTILITIES.put_line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Inserting data into sales fact table');
 FII_UTIL.Start_Timer;

INSERT /*+ APPEND PARALLEL(f) */ INTO isc_sales_credits_f f
with s as (
select /*+ ordered use_hash(sc) parallel(sc) parallel(sr)
	   pq_distribute(sr,hash,hash) */
       sc.sales_credit_id, sc.percent, sc.sales_credit_type_id,
       sc.salesrep_id, sc.header_id, sc.line_id, sr.resource_id,
       sr.org_id, sc.sales_group_id group_id, sc.created_by, sc.creation_date,
       sc.last_updated_by, sc.last_update_date, sc.last_update_login
  from oe_sales_credit_types	sc_typ,
       oe_sales_credits 	sc,
       jtf_rs_salesreps 	sr
 where sc.sales_group_id is not null
   and sc.salesrep_id = sr.salesrep_id
   and sc.sales_credit_type_id = sc_typ.sales_credit_type_id
   and sc_typ.quota_flag = 'Y'
 union all
select /*+ ordered use_hash(sc) parallel(sc) parallel(sg)
	   pq_distribute(sg,hash,hash) */
       sc.sales_credit_id, sc.percent, sc.sales_credit_type_id,
       sc.salesrep_id, sc.header_id, sc.line_id, sg.resource_id,
       sg.org_id, sg.group_id, sc.created_by, sc.creation_date,
       sc.last_updated_by, sc.last_update_date, sc.last_update_login
  from oe_sales_credit_types sc_typ,
       oe_sales_credits sc,
       jtf_rs_srp_groups sg
 where sc.sales_group_id is null
   and sc.salesrep_id = sg.salesrep_id
   and sc.last_update_date between sg.start_date and sg.end_date
   and sc.sales_credit_type_id = sc_typ.sales_credit_type_id
   and sc_typ.quota_flag = 'Y')
  SELECT pk, sales_credit_id, resource_id, group_id, header_id, line_id,
         percent, sales_credit_type_id, created_by, creation_date,
         last_updated_by, last_update_date, last_update_login
    FROM (SELECT pk, sales_credit_id, resource_id, group_id, header_id, line_id,
                 percent, sales_credit_type_id, created_by, creation_date,
                 last_updated_by, last_update_date, last_update_login,
		 rank() over (partition by line_id order by rnk) low_rnk
            FROM (SELECT /*+ parallel(s) */
			 'DIRECT-'||s.sales_credit_id pk,
                         s.sales_credit_id, s.group_id, t5.header_id, t5.line_id,
                         1 rnk, s.resource_id, s.percent, s.sales_credit_type_id, s.created_by,
                         s.creation_date, s.last_updated_by, s.last_update_date, s.last_update_login
                    FROM isc_tmp_book_sum2 tmp, isc_book_sum2_f t5, s
                   WHERE tmp.pk1 = t5.line_id
                     AND s.org_id = t5.org_ou_id
                     AND s.line_id = t5.line_id
                   UNION ALL
                  SELECT /*+ parallel(s) parallel(t7a) use_hash(s) pq_distribute(s,hash,hash) */
			 'SERVICE_PARENT-'||t7a.line_id||'-'||s.sales_credit_id pk,
                         s.sales_credit_id, s.group_id, t7a.header_id, t7a.line_id,
                         2 rnk, s.resource_id, s.percent, s.sales_credit_type_id, s.created_by,
                         s.creation_date, s.last_updated_by, s.last_update_date, s.last_update_login
                    FROM isc_tmp_book_sum2 tmp, isc_book_sum2_f t7a, s
                   WHERE tmp.pk1 = t7a.line_id
                     AND s.org_id = t7a.org_ou_id
                     AND s.line_id = t7a.service_parent_line_id
                     AND t7a.item_type_code = 'SERVICE'
                   UNION ALL
                  SELECT /*+ parallel(s) parallel(t7b2) use_hash(s) pq_distribute(s,hash,hash)
           		     parallel(t7b1) use_hash(t7b1) pq_distribute(t7b1,hash,hash) */
			 'SERVICE_PARENT_TOPMODEL-'||t7b2.line_id||'-'||s.sales_credit_id pk,
                         s.sales_credit_id, s.group_id group_id, t7b2.header_id, t7b2.line_id,
                         3 rnk, s.resource_id,
                         s.percent, s.sales_credit_type_id, s.created_by,
                         s.creation_date, s.last_updated_by, s.last_update_date, s.last_update_login
                    FROM isc_tmp_book_sum2 tmp, isc_book_sum2_f t7b1, isc_book_sum2_f t7b2, s
                   WHERE tmp.pk1 = t7b2.line_id
                     AND t7b2.item_type_code = 'SERVICE'
		     AND t7b1.line_id = t7b2.service_parent_line_id
                     AND s.line_id = t7b1.top_model_line_id
                     AND s.org_id = t7b1.org_ou_id
                   UNION ALL
                  SELECT /*+ ordered parallel(s) parallel(t7b1) use_hash(s) pq_distribute(s,hash,hash) */
			 'TOPMODEL-'||t7b1.line_id||'-'||s.sales_credit_id pk,
                         s.sales_credit_id, s.group_id, t7b1.header_id, t7b1.line_id,
                         4 rnk, s.resource_id,
                         s.percent, s.sales_credit_type_id, s.created_by,
  		         s.creation_date, s.last_updated_by, s.last_update_date, s.last_update_login
                    FROM isc_tmp_book_sum2 tmp, isc_book_sum2_f t7b1, s
                   WHERE tmp.pk1 = t7b1.line_id
                     AND s.line_id = t7b1.top_model_line_id
  		     AND s.org_id = t7b1.org_ou_id
  		   UNION ALL
                  SELECT /*+ ordered parallel(s) parallel(t11) use_hash(s) pq_distribute(s,hash,hash) */
			 'HEADER-'||t11.line_id||'-'||s.sales_credit_id pk,
                         s.sales_credit_id, s.group_id, t11.header_id, t11.line_id,
                         5 rnk, s.resource_id, s.percent, s.sales_credit_type_id, s.created_by,
                         s.creation_date, s.last_updated_by, s.last_update_date, s.last_update_login
                    FROM isc_tmp_book_sum2 tmp, isc_book_sum2_f t11, s
                   WHERE tmp.pk1 = t11.line_id
                     AND s.line_id IS NULL
                     AND s.org_id = t11.org_ou_id
                     AND s.header_id = t11.header_id))
   WHERE low_rnk = 1;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Inserted '||sql%rowcount||' rows into the sales fact table in');
 COMMIT;

 RETURN(1);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in function Update Sales Fact: '||sqlerrm;
    RETURN(-1);

END update_sales_fact;
-- ===================================================================
-- ======  END OF INCREMENTAL COLLECTION FOR SALES CREDITS FACT ======
-- ===================================================================


      -- --------------
      -- TRUNCATE_TABLE
      -- --------------

FUNCTION TRUNCATE_TABLE(table_name IN VARCHAR2) RETURN NUMBER IS

  l_isc_schema   VARCHAR2(30);
  l_stmt         VARCHAR2(200);
  l_status       VARCHAR2(30);
  l_industry     VARCHAR2(30);

BEGIN

  IF (FND_INSTALLATION.GET_APP_INFO('ISC', l_status, l_industry, l_isc_schema)) THEN
    l_stmt := 'TRUNCATE TABLE ' || l_isc_schema ||'.'||table_name;
    EXECUTE IMMEDIATE l_stmt;
  END IF;

  RETURN(1);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in function Truncate_Table : '||sqlerrm;
    RETURN(-1);

END truncate_table;

      -- -----------
      -- CHECK_SETUP
      -- -----------

FUNCTION CHECK_SETUP RETURN NUMBER IS

l_list 			dbms_sql.varchar2_table;
l_sec_curr_def  	VARCHAR2(1);

BEGIN

 l_list(1) := 'BIS_GLOBAL_START_DATE';
 IF (NOT bis_common_parameters.check_global_parameters(l_list)) THEN
    g_errbuf  := 'Collection aborted because the global start date has not been set up.';
    return(-1);
 END IF;

 IF (nvl(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'),'N') <> 'Y') THEN
    g_errbuf  := 'Collection aborted because the profile option (OM: DBI Installation) has not been set to Y.';
    return(-1);
 END IF;

l_sec_curr_def := isc_dbi_currency_pkg.is_sec_curr_defined;
 IF (l_sec_curr_def = 'E') THEN
    g_errbuf  := 'Collection aborted because the set-up of the DBI Global Parameter "Secondary Global Currency" is incomplete. Please verify the proper set-up of the Global Currency Rate Type and the Global Currency Code.';
    return(-1);
 END IF;

 g_batch_size := bis_common_parameters.get_batch_size(bis_common_parameters.high);
 BIS_COLLECTION_UTILITIES.put_line('The batch size is ' || g_batch_size);

 g_global_start_date := bis_common_parameters.get_global_start_date;
 BIS_COLLECTION_UTILITIES.put_line('The global start date is ' || g_global_start_date);

 g_global_currency := bis_common_parameters.get_currency_code;
 BIS_COLLECTION_UTILITIES.put_line('The global currency code is ' || g_global_currency);

 g_global_rate_type := bis_common_parameters.get_rate_type;
 BIS_COLLECTION_UTILITIES.put_line('The primary rate type is ' || g_global_rate_type);

 g_sec_global_currency := bis_common_parameters.get_secondary_currency_code;
 BIS_COLLECTION_UTILITIES.put_line('The secondary global currency code is ' || g_sec_global_currency);

 g_sec_global_rate_type := bis_common_parameters.get_secondary_rate_type;
 BIS_COLLECTION_UTILITIES.put_line('The secondary rate type is ' || g_sec_global_rate_type);

 g_treasury_rate_type := bis_common_parameters.get_treasury_rate_type;
 IF (g_treasury_rate_type IS NULL) THEN
    g_treasury_rate_type := g_global_rate_type;
    BIS_COLLECTION_UTILITIES.put_line('The treasury rate type is not set up. Use primary rate type instead.');
 END IF;
 BIS_COLLECTION_UTILITIES.put_line('The treasury rate type is ' || g_treasury_rate_type);

-- g_degree := bis_common_parameters.get_degree_of_parallelism;
-- BIS_COLLECTION_UTILITIES.put_line('The degree of parallelism is ' || g_degree);

 BIS_COLLECTION_UTILITIES.put_line('Truncating the temp table');
 FII_UTIL.Start_Timer;

  IF (truncate_table('ISC_DBI_CHANGE_LOG') = -1) THEN
     return(-1);
  END IF;

  IF (truncate_table('ISC_TMP_BOOK_SUM2') = -1) THEN
     return(-1);
  END IF;

  IF (truncate_table('ISC_CURR_BOOK_SUM2') = -1) THEN
     return(-1);
  END IF;

  IF (truncate_table('ISC_SERVICE_BOOK_SUM2') = -1) THEN
     return(-1);
  END IF;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Truncated the temp table in');
 BIS_COLLECTION_UTILITIES.Put_Line(' ');

  RETURN(1);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in function CHECK_SETUP : '||sqlerrm;
    RETURN(-1);

END check_setup;

      -- --------------------
      -- IDENTIFY_CHANGE_INIT
      -- --------------------

FUNCTION IDENTIFY_CHANGE_INIT RETURN NUMBER IS

l_count 	NUMBER;
l_stmt		VARCHAR2(8000);
l_from_date	VARCHAR2(30);
l_to_date	VARCHAR2(30);

BEGIN

  l_count := 0;
  l_from_date := to_char(g_push_from_date,'MM/DD/YYYY HH24:MI:SS');
  l_to_date   := to_char(g_push_to_date,'MM/DD/YYYY HH24:MI:SS');

      -- --------------------------------------------------------
      -- Populate line_id into isc_tmp_book_sum2 table
      -- VIEW_TYPE: 0 - NON CTO items
      -- 	    1 - ATO items
      -- 	    2 - PTO top model/KIT (nonshippable)
      -- 	    3 - PTO top model/KIT (shippable)
      -- 	    4 - others
      -- --------------------------------------------------------

 BIS_COLLECTION_UTILITIES.put_line('Identifying Booked orders lines');
 FII_UTIL.Start_Timer;


  l_stmt := 'INSERT /*+ APPEND PARALLEL(F) */ '||
	'INTO isc_tmp_book_sum2 F('||
	'PK1,'||
	'VIEW_TYPE,'||
	'LOG_ROWID,'||
	'BATCH_ID,'||
	'CURR_CONV_DATE,'||
	'FROM_CURRENCY,'||
	'TO_CURRENCY1,'||
	'RATE_TYPE, RATE1,'||
	'TO_CURRENCY2, '||
	'TO_CURRENCY3, '||
	'TO_CURRENCY4, '||
	'INV_OU_ID,'||
	'MASTER_ORG_ID,'||
	'INVENTORY_ITEM_ID,'||
	'ITEM_INV_ORG_ID,'||
	'TIME_BOOKED_DATE_ID,'||
	'TIME_SHIPPED_DATE_ID,'||
	'TIME_FULFILLED_DATE_ID,'||
	'TIME_SCHEDULE_DATE_ID,'||
	'TOP_MODEL_LINE_ID,'||
	'ORDER_QUANTITY_UOM,'||
	'INV_UOM_CODE,'||
	'INV_UOM_RATE,'||
	'ORDER_NUMBER,'||
	'HEADER_ID,'||
	'LINE_NUMBER,'||
	'SERVICE_REFERENCE_TYPE_CODE,'||
	'SOLD_TO_ORG_ID,'||
	'SERVICE_REFERENCE_LINE_ID,'||
        'FREIGHT_CHARGE,'||
	'FREIGHT_COST)' ||
  ' SELECT /*+ USE_HASH(h,l,opa,aspa,gsb,hoi,ospa,gsb1,item) PARALLEL(h) PARALLEL(l) PARALLEL(opa) PARALLEL(aspa) PARALLEL(gsb) PARALLEL(hoi) PARALLEL(ospa) PARALLEL(gsb1) PARALLEL(item) */ '||
         ' l.line_id 					PK1,'||
         ' decode(l.top_model_line_id,'||
         ' null, 0,'||
         ' decode(ato_line_id,'||
         '	null, decode(item_type_code,'||
         '		     ''MODEL'', 3,'||
         '		     ''KIT'', 3, 4), 1)) 	VIEW_TYPE,'||
         ' null 						LOG_ROWID,'||
         ' null			 			BATCH_ID,'||
         ' decode(upper(h.conversion_type_code),'||
         '	''USER'', h.conversion_rate_date,'||
         ' 	h.booked_date)				CURR_CONV_DATE,'||
         ' h.transactional_curr_code			FROM_CURRENCY,'||
         ' gsb.currency_code				TO_CURRENCY1,'||
         ' nvl(h.conversion_type_code,'''||
             g_treasury_rate_type ||''')			RATE_TYPE,'||
         ' decode(upper(h.conversion_type_code),'||
         '	''USER'', h.conversion_rate,null)	RATE1,'''||
           g_global_currency || ''' 			TO_CURRENCY2,'||
         ' gsb1.currency_code				TO_CURRENCY3,'''||
           g_sec_global_currency || ''' 		TO_CURRENCY4,'||
         ' to_number(hoi.org_information3) 		INV_OU_ID,'||
         ' ospa.parameter_value 			MASTER_ORG_ID,'||
         ' l.inventory_item_id 				INVENTORY_ITEM_ID,'||
         ' nvl(l.ship_from_org_id,ospa.parameter_value) ITEM_INV_ORG_ID,'||
         ' trunc(nvl(l.order_firmed_date, h.booked_date)) 	TIME_BOOKED_DATE_ID,'||
         ' trunc(l.actual_shipment_date) 			TIME_SHIPPED_DATE_ID,'||
         ' trunc(nvl(l.actual_fulfillment_date, l.fulfillment_date)) 	TIME_FULFILLED_DATE_ID,'||
         ' trunc(l.schedule_ship_date)			TIME_SCHEDULE_DATE_ID,'||
         ' l.top_model_line_id				TOP_MODEL_LINE_ID,'||
         ' l.order_quantity_uom				ORDER_QUANTITY_UOM,'||
         ' item.primary_uom_code				INV_UOM_CODE,'||
         ' decode(l.order_quantity_uom, item.primary_uom_code,1,'||
         '	INV_CONVERT.inv_um_convert('||
         '		l.inventory_item_id,NULL,1,'||
         '		l.order_quantity_uom,'||
         '		item.primary_uom_code,'||
         '		NULL, NULL)) 			INV_UOM_RATE,'||
         ' h.order_number					ORDER_NUMBER,'||
         ' h.header_id					HEADER_ID,'||
         ' l.line_number ||''.''||'||
         ' l.shipment_number||decode(l.service_number,'''','||
         '			   decode(l.component_number,'''','||
         '				  decode(l.option_number,'''','''',''.''),''.''),''.'') ||'||
         ' l.option_number||decode(l.service_number,'''','||
         '                         decode(l.component_number,'''','''',''.''),''.'') ||'||
         ' l.component_number||decode(l.service_number,'''','''',''.'')||'||
         ' l.service_number				LINE_NUMBER,'||
	 ' l.service_reference_type_code		SERVICE_REFERENCE_TYPE_CODE,'||
	 ' l.sold_to_org_id				SOLD_TO_ORG_ID,'||
	 ' l.service_reference_line_id			SERVICE_REFERENCE_LINE_ID,'||
	 ' nvl(opa.charge_adjamt,0)*l.ordered_quantity + nvl(opa.charge_operand,0)	FREIGHT_CHARGE,'||
	 ' opa.cost									FREIGHT_COST'||
    ' FROM OE_ORDER_HEADERS_ALL h,'||
         ' OE_ORDER_LINES_ALL l,'||
         ' AR_SYSTEM_PARAMETERS_ALL aspa,'||
         ' GL_SETS_OF_BOOKS gsb,'||
         ' HR_ORGANIZATION_INFORMATION hoi,'||
         ' OE_SYS_PARAMETERS_ALL ospa,'||
         ' GL_SETS_OF_BOOKS gsb1,'||
         ' MTL_SYSTEM_ITEMS_B item, '||
         ' (select p.line_id, sum(decode(p.list_line_type_code, ''COST'', '||
	 '					       p.adjusted_amount,  null)) cost,   '||
	 '			 sum(decode(p.list_line_type_code, ''FREIGHT_CHARGE'', '||
	 ' 		  decode(nvl(p.applied_flag, ''Y''), ''Y'', '||
	 '                       decode(p.arithmetic_operator, ''LUMPSUM'', p.operand, null), '||
	 ' 			  			   	 null),  null)) charge_operand, '||
	 '			 sum(decode(p.list_line_type_code, ''FREIGHT_CHARGE'', '||
	 ' 		  decode(nvl(p.applied_flag, ''Y''), ''Y'', '||
	 '                       decode(p.arithmetic_operator, ''LUMPSUM'', null, p.adjusted_amount), '||
	 ' 			  			   	 null),  null)) charge_adjamt '||
	 ' from oe_price_adjustments p '||
	 ' where p.line_id is not null '||
	 '     and p.charge_type_code in (''FTECHARGE'', ''FTEPRICE'') '||
	 ' group by p.line_id) opa '||
     ' WHERE nvl(l.order_firmed_date, h.booked_date) >= to_date('''|| l_from_date || ''',''MM/DD/YYYY HH24:MI:SS'')'||
     ' AND l.header_id = h.header_id'||
     ' AND l.line_id = opa.line_id (+)  '||
     ' AND h.org_id = aspa.org_id'||
     ' AND aspa.set_of_books_id = gsb.set_of_books_id'||
     ' AND h.booked_flag = ''Y'''||
     ' AND h.booked_date IS NOT NULL'||
     ' AND hoi.org_information_context =''Accounting Information'''||
     ' AND h.org_id = ospa.org_id'||
     ' AND ospa.parameter_code = ''MASTER_ORGANIZATION_ID'''||
     ' AND hoi.organization_id = nvl(l.ship_from_org_id, ospa.parameter_value)'||
     ' AND hoi.org_information1 = to_char(gsb1.set_of_books_id)'||
     ' AND l.inventory_item_id = item.inventory_item_id'||
     ' AND nvl(l.ship_from_org_id, ospa.parameter_value) = item.organization_id';

  EXECUTE IMMEDIATE l_stmt;

  l_count := l_count + sql%rowcount;
  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Identified '||l_count||' records in');
  COMMIT;


  FII_UTIL.Start_Timer;

  INSERT /*+ APPEND */
    INTO isc_curr_book_sum2 F(
	FROM_CURRENCY,
	TO_CURRENCY1,
	TO_CURRENCY3,
	CONVERSION_DATE,
	CONVERSION_TYPE,
	RATE1,
	RATE2,
	RATE3,
	RATE4)
  SELECT from_currency, to_currency1, to_currency3, time_booked_date_id CONVERSION_DATE, rate_type CONVERSION_TYPE,
	 decode(from_currency, to_currency1, 1,
		fii_currency.get_rate(from_currency, to_currency1, time_booked_date_id, rate_type)) RATE1,
	 decode(from_currency, g_global_currency, 1,
	 	fii_currency.get_global_rate_primary(to_currency3, time_booked_date_id)) RATE2,
	 decode(from_currency, to_currency3, 1,
		fii_currency.get_rate(from_currency, to_currency3, time_booked_date_id, g_global_rate_type))	RATE3,
	 decode(from_currency, g_sec_global_currency, 1,
	 	fii_currency.get_global_rate_secondary(to_currency3, time_booked_date_id)) RATE4
    FROM (SELECT /*+ PARALLEL(tmp) */ distinct from_currency, to_currency1, to_currency3, time_booked_date_id, rate_type
	    FROM isc_tmp_book_sum2 tmp);

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Retrieved '||sql%rowcount||' currency rates in');
  COMMIT;

  FII_UTIL.Start_Timer;

  INSERT /*+ APPEND */
    INTO isc_service_book_sum2 F(
	LINE_ID,
	SERVICE_PARENT_LINE_ID)
  SELECT pk1, ISC_DBI_BOOK_SUM2_F_C.get_cust_product_line_id(tmp.sold_to_org_id,tmp.service_reference_line_id)
    FROM isc_tmp_book_sum2 tmp
   WHERE service_reference_type_code = 'CUSTOMER_PRODUCT';

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Retrieved '||sql%rowcount||' customer product line in');
  COMMIT;

  RETURN(l_count);

  EXCEPTION
   WHEN OTHERS THEN
    g_errbuf  := 'Error in Function IDENTIFY_CHANGE_INIT : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
 END;

      -- --------------------
      -- DELETE_DBI_BASE
      -- --------------------

FUNCTION DELETE_DBI_BASE RETURN NUMBER IS

l_count		NUMBER		:= 0;

BEGIN

 BIS_COLLECTION_UTILITIES.put_line('Deleting obsolete records from the base summary');
 FII_UTIL.Start_Timer;

 DELETE FROM isc_book_sum2_f
  WHERE line_id IN (select pk1
		      from isc_tmp_book_sum2
		     where view_type = -1)
    AND fulfilled_flag = 'N';

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Deleted '||sql%rowcount||' changed records in');
 COMMIT;


/* Delete ont_dbi_change_log at the end */

-- BIS_COLLECTION_UTILITIES.put_line('Deleting obsolete records from OM log table');
-- FII_UTIL.Start_Timer;

-- DELETE FROM ont_dbi_change_log
--  WHERE rowid IN (select log_rowid
--		    from isc_tmp_book_sum2
--		   where view_type = -1);

-- FII_UTIL.Stop_Timer;
-- FII_UTIL.Print_Timer('Deleted '||sql%rowcount||' changed records in');
-- COMMIT;

 BIS_COLLECTION_UTILITIES.put_line('Deleting obsolete records from the temp table');
 FII_UTIL.Start_Timer;

 DELETE FROM isc_tmp_book_sum2
  WHERE view_type = -1;
 l_count := l_count + sql%rowcount;
 COMMIT;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Deleted '||l_count||' changed records in');

 RETURN(l_count);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function DELETE_DBI_BASE : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
END;

      -- --------------------
      -- IDENTIFY_CHANGE_ICRL
      -- --------------------

FUNCTION IDENTIFY_CHANGE_ICRL RETURN NUMBER IS

 l_count	       	NUMBER;
 l_delete_count		NUMBER := 0;
 l_status               VARCHAR2(30);
 l_industry             VARCHAR2(30);
 l_schema           	VARCHAR2(30);

 BEGIN

  l_count := 0;

      -- --------------------------------------------------------
      -- Populate rowid into isc_tmp_book_sum2 table based
      -- on order booked date
      -- VIEW_TYPE: -1 - Deletion
      -- 	     0 - NON CTO items
      -- 	     1 - ATO items
      -- 	     2 - PTO top model/KIT (nonshippable)
      -- 	     3 - PTO top model/KIT (shippable)
      -- 	     4 - others
      -- --------------------------------------------------------

 FII_UTIL.Start_Timer;

  INSERT INTO isc_dbi_change_log (LINE_ID, HEADER_ID, LOG_ROWID, LAST_UPDATE_DATE)
       SELECT line_id LINE_ID, header_id HEADER_ID, rowid LOG_ROWID, last_update_date LAST_UPDATE_DATE
         FROM ont_dbi_change_log;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Inserted '|| sql%rowcount || ' rows into ISC_DBI_CHANGE_LOG');

  COMMIT;


IF (FND_INSTALLATION.GET_APP_INFO('ISC', l_status, l_industry, l_schema)) THEN
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_schema,
				  TABNAME => 'ISC_DBI_CHANGE_LOG');
 END IF;


/* Make a copy of ont_dbi_change_log, no need to delete the duplication before the insert statement. */

--  DELETE FROM ont_dbi_change_log d1
--  WHERE EXISTS (SELECT 1 FROM ont_dbi_change_log d2
--                 WHERE d2.rowid < d1.rowid
--                   AND d2.last_update_date = d1.last_update_date
--                   AND d2.line_id = d1.line_id);

--  DELETE FROM ont_dbi_change_log
--        WHERE (line_id, last_update_date) NOT IN (SELECT line_id, max(last_update_date)
--	  					    FROM ont_dbi_change_log
--					          GROUP BY line_id);
--  COMMIT;

 FII_UTIL.Start_Timer;

  INSERT INTO isc_tmp_book_sum2(pk1, view_type)
  SELECT distinct line_id, -1
    FROM isc_dbi_change_log log
   WHERE NOT EXISTS (select '1'
                        from  oe_order_lines_all l
                       where  l.line_id = log.line_id);
  l_delete_count := sql%rowcount;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Identified '|| l_delete_count || ' deleted lines in');
 COMMIT;

  IF l_delete_count > 0 THEN
     BIS_COLLECTION_UTILITIES.Put_Line(' ');
     BIS_COLLECTION_UTILITIES.Put_Line('Analyzing table ISC_TMP_BOOK_SUM2');
     FII_UTIL.Start_Timer;
     IF (FND_INSTALLATION.GET_APP_INFO('ISC', l_status, l_industry, l_schema)) THEN
        FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_schema,
		 		     TABNAME => 'ISC_TMP_BOOK_SUM2');
     END IF;
     FII_UTIL.Stop_Timer;
     FII_UTIL.Print_Timer('Analyzed table ISC_TMP_BOOK_SUM2 in ');

     l_delete_count := DELETE_DBI_BASE;
     IF (l_delete_count = -1) THEN
          return -1;
     END IF;
  END IF;

 FII_UTIL.Start_Timer;

  INSERT
    INTO isc_tmp_book_sum2(
    	 PK1,
	 VIEW_TYPE,
--	 LOG_ROWID,
	 BATCH_ID,
	 CURR_CONV_DATE,
	 FROM_CURRENCY,
	 TO_CURRENCY1,
	 RATE_TYPE,
	 RATE1,
	 TO_CURRENCY2,
	 TO_CURRENCY3,
	 TO_CURRENCY4,
	 INV_OU_ID,
         MASTER_ORG_ID,
	 INVENTORY_ITEM_ID,
	 ITEM_INV_ORG_ID,
	 TIME_BOOKED_DATE_ID,
	 TIME_SHIPPED_DATE_ID,
	 TIME_FULFILLED_DATE_ID,
	 TIME_SCHEDULE_DATE_ID,
	 TOP_MODEL_LINE_ID,
	 ORDER_QUANTITY_UOM,
	 INV_UOM_CODE,
	 INV_UOM_RATE,
	 ORDER_NUMBER,
	 HEADER_ID,
	 LINE_NUMBER,
	 SERVICE_REFERENCE_TYPE_CODE,
	 SOLD_TO_ORG_ID,
	 SERVICE_REFERENCE_LINE_ID,
	 FREIGHT_CHARGE,
	 FREIGHT_COST)
  SELECT /*+ leading(log) use_hash(hoi,gsb,gsb1) */ l.line_id,
         decode(l.top_model_line_id,
		null, 0,
		decode(ato_line_id,
		       null, decode(item_type_code,
			            'MODEL', 3, 'KIT', 3, 4),1)) VIEW_TYPE,
--       log.rowid LOG_ROWID,
	 null BATCH_ID,
  	 decode(upper(h.conversion_type_code),
		'USER', h.conversion_rate_date,
 		h.booked_date)			CURR_CONV_DATE,
  	 h.transactional_curr_code		FROM_CURRENCY,
  	 gsb.currency_code			TO_CURRENCY1,
	 nvl(h.conversion_type_code,
	     g_treasury_rate_type)		RATE_TYPE,
  	 decode(upper(h.conversion_type_code),
		'USER', h.conversion_rate,null)		RATE1,
  	 g_global_currency 			TO_CURRENCY2,
  	 gsb1.currency_code			TO_CURRENCY3,
  	 g_sec_global_currency			TO_CURRENCY4,
	 to_number(hoi.org_information3) INV_OU_ID,
	 ospa.parameter_value MASTER_ORG_ID,
	 l.inventory_item_id INVENTORY_ITEM_ID,
	 nvl(l.ship_from_org_id, ospa.parameter_value) ITEM_INV_ORG_ID,
	 trunc(nvl(l.order_firmed_date, h.booked_date)) TIME_BOOKED_DATE_ID,
	 trunc(l.actual_shipment_date) TIME_SHIPPED_DATE_ID,
	 trunc(nvl(l.actual_fulfillment_date, l.fulfillment_date)) TIME_FULFILLED_DATE_ID,
	 trunc(l.schedule_ship_date) TIME_SCHEDULE_DATE_ID,
	 l.top_model_line_id	TOP_MODEL_LINE_ID,
	 l.order_quantity_uom				ORDER_QUANTITY_UOM,
	 item.primary_uom_code				INV_UOM_CODE,
	 decode(l.order_quantity_uom, item.primary_uom_code,1,
		INV_CONVERT.inv_um_convert(
			l.inventory_item_id,NULL,1,
			l.order_quantity_uom,
			item.primary_uom_code,
			NULL, NULL)) 			INV_UOM_RATE,
	 h.order_number 				ORDER_NUMBER,
	 h.header_id					HEADER_ID,
         l.line_number ||'.'||
         l.shipment_number||decode(l.service_number,'',
				   decode(l.component_number,'',
					  decode(l.option_number,'','','.'),'.'),'.') ||
         l.option_number||decode(l.service_number,'',
                                 decode(l.component_number,'','','.'),'.') ||
         l.component_number||decode(l.service_number,'','','.')||
         l.service_number				LINE_NUMBER,
	 l.service_reference_type_code			SERVICE_REFERENCE_TYPE_CODE,
	 l.sold_to_org_id				SOLD_TO_ORG_ID,
	 l.service_reference_line_id			SERVICE_REFERENCE_LINE_ID,
         nvl(opa.charge_operand,0) + nvl(opa.charge_adjamt,0)*l.ordered_quantity	FREIGHT_CHARGE,
	 opa.cost									FREIGHT_COST
    FROM (select p.line_id, sum(decode(p.list_line_type_code, 'COST',
                            p.adjusted_amount, null)) cost,
                            sum(decode(p.list_line_type_code, 'FREIGHT_CHARGE', decode(nvl(p.applied_flag, 'Y'), 'Y', decode(p.arithmetic_operator, 'LUMPSUM', p.operand, null), null),  null)) charge_operand,
                            sum(decode(p.list_line_type_code, 'FREIGHT_CHARGE', decode(nvl(p.applied_flag, 'Y'), 'Y', decode(p.arithmetic_operator, 'LUMPSUM', null, p.adjusted_amount), null),  null)) charge_adjamt
      from oe_price_adjustments p,
           (select /*+ no_merge cardinality (log, 1000)*/ distinct line_id from isc_dbi_change_log log) log1
      where p.line_id = log1.line_id
	    and p.line_id is not null
	    and p.charge_type_code in ('FTEPRICE', 'FTECHARGE')
      group by p.line_id) opa,
	 (select /*+ no_merge cardinality (ilog, 1000)*/ distinct line_id, header_id from isc_dbi_change_log ilog) log,
         oe_order_lines_all l,
	 OE_ORDER_HEADERS_ALL h,
	 AR_SYSTEM_PARAMETERS_ALL aspa,
	 GL_SETS_OF_BOOKS gsb,
         HR_ORGANIZATION_INFORMATION hoi,
	 OE_SYS_PARAMETERS_ALL ospa,
  	 GL_SETS_OF_BOOKS gsb1,
	 MTL_SYSTEM_ITEMS_B item
   WHERE log.line_id = l.line_id
--     AND log.last_update_date < g_incre_start_date
     AND l.header_id = h.header_id
     AND l.line_id = opa.line_id (+)
     AND h.org_id = aspa.org_id
     AND aspa.set_of_books_id = gsb.set_of_books_id
     AND h.booked_flag = 'Y'
     AND h.booked_date IS NOT NULL
     AND nvl(l.order_firmed_date, h.booked_date) >= g_global_start_date
     AND hoi.org_information_context ='Accounting Information'
     AND h.org_id = ospa.org_id
     AND ospa.parameter_code = 'MASTER_ORGANIZATION_ID'
     AND hoi.organization_id = nvl(l.ship_from_org_id, ospa.parameter_value)
     AND hoi.org_information1 = to_char(gsb1.set_of_books_id)
     AND l.inventory_item_id = item.inventory_item_id
     AND nvl(l.ship_from_org_id, ospa.parameter_value) = item.organization_id;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Identified '|| sql%rowcount || ' lines in');
 COMMIT;



 -- In DBI5.0, we determine if a PTO/KIT top model is shippable by scanning through all it's child lines
 -- Therefore, in the incremental load, we need to capture the top model line if the child line is changed
 -- For DBI6.0, we do not support this logic anymore, so comment it out to improve performance

 -- FII_UTIL.Start_Timer;

 --  INSERT
 --    INTO isc_tmp_book_sum2(
 --    	 PK1,
 --	 VIEW_TYPE,
 --	 LOG_ROWID,
 --	 BATCH_ID,
 --	 CURR_CONV_DATE,
 --	 FROM_CURRENCY,
 --	 TO_CURRENCY1,
 --	 RATE_TYPE,
 --	 RATE1,
 --	 TO_CURRENCY2,
 --	 TO_CURRENCY3,
 --	 INV_OU_ID,
 --	 MASTER_ORG_ID,
 --  	 INVENTORY_ITEM_ID,
 --	 ITEM_INV_ORG_ID,
 --	 TIME_BOOKED_DATE_ID,
 --	 TIME_SHIPPED_DATE_ID,
 --	 TIME_FULFILLED_DATE_ID,
 --	 TIME_SCHEDULE_DATE_ID,
 --	 TOP_MODEL_LINE_ID,
 --	 ORDER_QUANTITY_UOM,
 --	 INV_UOM_CODE,
 --	 INV_UOM_RATE,
 --	 ORDER_NUMBER,
 --	 HEADER_ID,
 --	 LINE_NUMBER)
 --  SELECT /*+ leading(log) */ pl.line_id,
 --         decode(pl.top_model_line_id,
 --		null, 0,
 --		decode(pl.ato_line_id,
 --		       null, decode(pl.item_type_code,
 --			            'MODEL', 3, 'KIT', 3, 4),1)) VIEW_TYPE,
 --         null,
 --	 null,
 --  	 decode(upper(h.conversion_type_code),
 --		'USER', h.conversion_rate_date,
 -- 		h.booked_date)			CURR_CONV_DATE,
 --  	 h.transactional_curr_code		FROM_CURRENCY,
 --  	 gsb.currency_code			TO_CURRENCY1,
 --	 nvl(h.conversion_type_code,
 --	     g_global_rate_type)		RATE_TYPE,
 --  	 decode(upper(h.conversion_type_code),
 --		'USER', h.conversion_rate,null)		RATE1,
 --  	 g_global_currency TO_CURRENCY2,
 --  	 gsb1.currency_code			TO_CURRENCY3,
 -- 	 to_number(hoi.org_information3) INV_OU_ID,
 --	 ospa.master_organization_id MASTER_ORG_ID,
 -- 	 pl.inventory_item_id INVENTORY_ITEM_ID,
 --	 nvl(pl.ship_from_org_id, ospa.master_organization_id) ITEM_INV_ORG_ID,
 --	 trunc(h.booked_date) TIME_BOOKED_DATE_ID,
 --	 trunc(pl.actual_shipment_date) TIME_SHIPPED_DATE_ID,
 --	 trunc(pl.fulfillment_date) TIME_FULFILLED_DATE_ID,
 --	 trunc(pl.schedule_ship_date) TIME_SCHEDULE_DATE_ID,
 --	 pl.top_model_line_id TOP_MODEL_LINE_ID,
 --	 pl.order_quantity_uom				ORDER_QUANTITY_UOM,
 --	 item.primary_uom_code				INV_UOM_CODE,
 --	 decode(pl.order_quantity_uom, item.primary_uom_code,1,
 --		INV_CONVERT.inv_um_convert(
 --			pl.inventory_item_id,NULL,1,
 --			pl.order_quantity_uom,
 --			item.primary_uom_code,
 --			NULL, NULL)) 			INV_UOM_RATE,
 --	 h.order_number					ORDER_NUMBER,
 --	 h.header_id					HEADER_ID,
 --         pl.line_number ||'.'||
 --         pl.shipment_number||decode(pl.service_number,'',
 --				   decode(pl.component_number,'',
 --					  decode(pl.option_number,'','','.'),'.'),'.') ||
 --         pl.option_number||decode(pl.service_number,'',
 --                                 decode(pl.component_number,'','','.'),'.') ||
 --         pl.component_number||decode(pl.service_number,'','','.')||
 --         pl.service_number				LINE_NUMBER
 --    FROM (SELECT distinct top_model_line_id FROM isc_tmp_book_sum2) log,
 --         oe_order_lines_all pl,
 --	 OE_ORDER_HEADERS_ALL h,
 --	 AR_SYSTEM_PARAMETERS_ALL aspa,
 --	 GL_SETS_OF_BOOKS gsb,
 --         HR_ORGANIZATION_INFORMATION hoi,
 --	 OE_SYSTEM_PARAMETERS_ALL ospa,
 --  	 GL_SETS_OF_BOOKS gsb1,
 --	 MTL_SYSTEM_ITEMS_B item
 --   WHERE log.top_model_line_id = pl.top_model_line_id
 --     AND not exists (select '1' from isc_tmp_book_sum2 tmp where tmp.pk1 = pl.line_id)
 --     AND pl.header_id = h.header_id
 --     AND h.org_id = aspa.org_id
 --     AND aspa.set_of_books_id = gsb.set_of_books_id
 --     AND h.booked_flag = 'Y'
 --     AND h.booked_date IS NOT NULL
 --     AND hoi.org_information_context ='Accounting Information'
 --     AND h.org_id = ospa.org_id
 --     AND hoi.organization_id = nvl(pl.ship_from_org_id, ospa.master_organization_id)
 --     AND hoi.org_information1 = to_char(gsb1.set_of_books_id)
 --     AND pl.inventory_item_id = item.inventory_item_id
 --     AND nvl(pl.ship_from_org_id, ospa.master_organization_id) = item.organization_id;

 -- FII_UTIL.Stop_Timer;
 -- FII_UTIL.Print_Timer('Identified '|| sql%rowcount || ' top model lines in');
 -- COMMIT;

  FII_UTIL.Start_Timer;

  INSERT
    INTO isc_curr_book_sum2 F(
	FROM_CURRENCY,
	TO_CURRENCY1,
	TO_CURRENCY3,
	CONVERSION_DATE,
	CONVERSION_TYPE,
	RATE1,
	RATE2,
	RATE3,
	RATE4)
  SELECT from_currency, to_currency1, to_currency3, time_booked_date_id CONVERSION_DATE, rate_type CONVERSION_TYPE,
	 decode(from_currency, to_currency1, 1,
		fii_currency.get_rate(from_currency, to_currency1, time_booked_date_id, rate_type)) RATE1,
	 decode(from_currency, g_global_currency, 1,
	 	fii_currency.get_global_rate_primary(to_currency3, time_booked_date_id)) RATE2,
	 decode(from_currency, to_currency3, 1,
		fii_currency.get_rate(from_currency, to_currency3, time_booked_date_id, g_global_rate_type))	RATE3,
	 decode(from_currency, g_sec_global_currency, 1,
	 	fii_currency.get_global_rate_secondary(to_currency3, time_booked_date_id)) RATE4
    FROM (SELECT distinct from_currency, to_currency1, to_currency3, time_booked_date_id, rate_type
	    FROM isc_tmp_book_sum2);

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Retrieved '||sql%rowcount||' currency rates in');
  COMMIT;



  FII_UTIL.Start_Timer;

  INSERT
    INTO isc_service_book_sum2 F(
	LINE_ID,
	SERVICE_PARENT_LINE_ID)
  SELECT pk1, ISC_DBI_BOOK_SUM2_F_C.get_cust_product_line_id(tmp.sold_to_org_id,tmp.service_reference_line_id)
    FROM isc_tmp_book_sum2 tmp
   WHERE service_reference_type_code = 'CUSTOMER_PRODUCT';

  FII_UTIL.Stop_Timer;
  FII_UTIL.Print_Timer('Retrieved '||sql%rowcount||' customer product line in');
  COMMIT;





 FII_UTIL.Start_Timer;




  UPDATE isc_tmp_book_sum2 SET batch_id = ceil(rownum/g_batch_size);
  l_count := sql%rowcount;
  COMMIT;



 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Updated the batch id for '|| l_count || ' rows in');

  RETURN(l_count);

  EXCEPTION
   WHEN OTHERS THEN
    g_errbuf  := 'Error in Function IDENTIFY_CHANGE_ICRL : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
 END;

      -- ---------------------
      -- CHECK_TIME_CONTINUITY
      -- ---------------------

FUNCTION CHECK_TIME_CONTINUITY RETURN NUMBER IS

l_min_booked_date	DATE;
l_max_booked_date	DATE;
l_min_shipped_date	DATE;
l_max_shipped_date	DATE;
l_min_ful_date		DATE;
l_max_ful_date		DATE;
l_min_sche_date		DATE;
l_max_sche_date		DATE;
l_min_1			DATE;
l_max_1			DATE;
l_min_2			DATE;
l_max_2			DATE;
l_is_missing		BOOLEAN	:= TRUE;
l_time_min		DATE;
l_time_max		DATE;
l_profile_option	VARCHAR2(100);
l_dangling		NUMBER := 0;

-- cursor

CURSOR Lines_Missing_Date_1 IS
   SELECT order_number,
	  line_number,
	  header_id,
	  pk1 line_id,
	  to_char(time_booked_date_id, 'MM/DD/YYYY') time_booked_date_id,
	  to_char(time_fulfilled_date_id, 'MM/DD/YYYY') time_fulfilled_date_id,
	  to_char(time_shipped_date_id,'MM/DD/YYYY') time_shipped_date_id
     FROM isc_tmp_book_sum2
    WHERE (least(time_booked_date_id, nvl(time_fulfilled_date_id,time_booked_date_id), nvl(time_shipped_date_id,time_booked_date_id)) < l_time_min
       OR greatest(time_booked_date_id, nvl(time_fulfilled_date_id,time_booked_date_id),nvl(time_shipped_date_id,time_booked_date_id)) > l_time_max);

CURSOR Lines_Missing_Date_2 IS
   SELECT order_number,
	  line_number,
	  header_id,
	  pk1 line_id,
	  to_char(time_schedule_date_id,'MM/DD/YYYY') time_schedule_date_id
     FROM isc_tmp_book_sum2
    WHERE (nvl(time_schedule_date_id, time_booked_date_id) < l_time_min
       OR nvl(time_schedule_date_id, time_booked_date_id) > l_time_max);

l_line_1				LINES_MISSING_DATE_1%ROWTYPE;
l_line_2				LINES_MISSING_DATE_2%ROWTYPE;

 BEGIN

 FII_UTIL.Start_Timer;

 IF (g_load_mode = 'INITIAL') THEN

   BIS_COLLECTION_UTILITIES.Put_Line('Begin to retrieve the time boundary for the initial load');
   SELECT /*+ PARALLEL(tmp) */ min(time_booked_date_id), max(time_booked_date_id),
          min(time_shipped_date_id), max(time_shipped_date_id),
          min(time_fulfilled_date_id), max(time_fulfilled_date_id),
	  min(time_schedule_date_id), max(time_schedule_date_id)
     INTO l_min_booked_date, l_max_booked_date,
          l_min_shipped_date, l_max_shipped_date,
          l_min_ful_date, l_max_ful_date,
	  l_min_sche_date, l_max_sche_date
     FROM isc_tmp_book_sum2 tmp;

 ELSIF (g_load_mode = 'INCREMENTAL') THEN

   BIS_COLLECTION_UTILITIES.Put_Line('Begin to retrieve the time boundary for the incremental load');
   SELECT min(time_booked_date_id), max(time_booked_date_id),
          min(time_shipped_date_id), max(time_shipped_date_id),
          min(time_fulfilled_date_id), max(time_fulfilled_date_id),
	  min(time_schedule_date_id), max(time_schedule_date_id)
     INTO l_min_booked_date, l_max_booked_date,
          l_min_shipped_date, l_max_shipped_date,
          l_min_ful_date, l_max_ful_date,
	  l_min_sche_date, l_max_sche_date
     FROM isc_tmp_book_sum2 tmp;

 END IF;

 l_min_1 := least(l_min_booked_date, nvl(l_min_shipped_date,l_min_booked_date), nvl(l_min_ful_date,l_min_booked_date));
 l_max_1 := greatest(l_max_booked_date, nvl(l_max_shipped_date,l_max_booked_date), nvl(l_max_ful_date, l_max_booked_date));
 l_min_2 := nvl(l_min_sche_date, l_min_booked_date);
 l_max_2 := nvl(l_max_sche_date, l_max_booked_date);

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Retrieved the time boundary in ');


 FII_UTIL.Start_Timer;

 BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
 BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
 FII_TIME_API.check_missing_date(l_min_1, l_max_1, l_is_missing);


 IF (l_is_missing) THEN
    BIS_COLLECTION_UTILITIES.Put_Line('Collection failed because there are dangling keys for time dimension.');
    BIS_COLLECTION_UTILITIES.Put_Line('No records were loaded.');

    SELECT min(report_date), max(report_date)
      INTO l_time_min, l_time_max
      FROM fii_time_day;

    OPEN lines_missing_date_1;
    FETCH lines_missing_date_1 INTO l_line_1;
    BIS_COLLECTION_UTILITIES.Put_Line_Out(fnd_message.get_string('ISC', 'ISC_DBI_DATE_NO_LOAD'));
    BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
    BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(fnd_message.get_string('ISC','ISC_DBI_ORDER_NUMBER'),18,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_LINE_NUMBER'),18,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_LINE_ID'),18,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_BOOKED_DATE'),15,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_FULFILLED_DATE'),19,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_SHIPPED_DATE'),16,' '));
    BIS_COLLECTION_UTILITIES.Put_Line_Out('------------------ - ------------------ - ------------------ - --------------- - ------------------- - ----------------');

   WHILE LINES_MISSING_DATE_1%FOUND LOOP
      BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(l_line_1.order_number,18,' ')
			      ||' - '||RPAD(l_line_1.line_number,18,' ')
			      ||' - '||RPAD(l_line_1.line_id,18,' ')
			      ||' - '||RPAD(l_line_1.time_booked_date_id,15,' ')
			      ||' - '||RPAD(nvl(l_line_1.time_fulfilled_date_id,' '),19,' ')
			      ||' - '||RPAD(nvl(l_line_1.time_shipped_date_id,' '),16,' '));
      FETCH Lines_Missing_Date_1 INTO l_line_1;
   END LOOP;
   CLOSE LINES_MISSING_DATE_1;
    BIS_COLLECTION_UTILITIES.Put_Line_Out('+---------------------------------------------------------------------------------------------------------------------+');
   l_dangling := 1;

 END IF;

 l_profile_option := nvl(fnd_profile.value('ISC_DBI_SCH_SHP_DATE_DNGL_CHK'),'ERROR');

 BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
 BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
 FII_TIME_API.check_missing_date(l_min_2, l_max_2, l_is_missing);


 IF (l_is_missing) THEN

    if (l_profile_option = 'ERROR') then
      if (l_dangling = 0) then
        BIS_COLLECTION_UTILITIES.Put_Line('Collection failed because there are dangling keys for time dimension.');
        BIS_COLLECTION_UTILITIES.Put_Line('No records were loaded.');

        BIS_COLLECTION_UTILITIES.Put_Line_Out(fnd_message.get_string('ISC', 'ISC_DBI_DATE_NO_LOAD'));
        BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
        l_dangling := 1;
      end if;
    else
      g_warning := 1;
    end if;

    SELECT min(report_date), max(report_date)
      INTO l_time_min, l_time_max
      FROM fii_time_day;

    OPEN lines_missing_date_2;
    FETCH lines_missing_date_2 INTO l_line_2;
    BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(fnd_message.get_string('ISC','ISC_DBI_ORDER_NUMBER'),18,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_LINE_NUMBER'),18,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_LINE_ID'),18,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_SCHEDULE_SHIP_DATE'),24,' '));
    BIS_COLLECTION_UTILITIES.Put_Line_Out('------------------ - ------------------ - ------------------ - ------------------------');

   WHILE LINES_MISSING_DATE_2%FOUND LOOP
      BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(l_line_2.order_number,18,' ')
			      ||' - '||RPAD(l_line_2.line_number,18,' ')
			      ||' - '||RPAD(l_line_2.line_id,18,' ')
			      ||' - '||RPAD(l_line_2.time_schedule_date_id,24,' '));
      FETCH Lines_Missing_Date_2 INTO l_line_2;
   END LOOP;
   CLOSE LINES_MISSING_DATE_2;
    BIS_COLLECTION_UTILITIES.Put_Line_Out('+-------------------------------------------------------------------------------------+');


 END IF;

 if (l_dangling = 1) then
   return (-999);
 elsif (g_warning = 1) then
   return (1);
 else
   BIS_COLLECTION_UTILITIES.Put_Line(' ');
   BIS_COLLECTION_UTILITIES.Put_Line('           THERE IS NO DANGLING TIME ATTRIBUTES    ');
   BIS_COLLECTION_UTILITIES.Put_Line('+---------------------------------------------------------------------------+');
   BIS_COLLECTION_UTILITIES.Put_Line(' ');

   FII_UTIL.Stop_Timer;
   FII_UTIL.Print_Timer('Completed time continuity check in');

   RETURN(1);
 end if;

  EXCEPTION
   WHEN OTHERS THEN
    g_errbuf  := 'Error in Function CHECK_TIME_CONTINUITY : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
 END;

      -- ----------------------------------------
      -- Identify Dangling Key for Item Dimension
      -- ----------------------------------------

FUNCTION IDENTIFY_DANGLING_ITEM RETURN NUMBER IS

CURSOR Dangling_Items_Init IS
SELECT /*+ PARALLEL(tmp) PARALLEL(item) */ distinct tmp.inventory_item_id, tmp.item_inv_org_id
  FROM isc_tmp_book_sum2 tmp,
       eni_oltp_item_star item
 WHERE tmp.inventory_item_id = item.inventory_item_id(+)
   AND tmp.item_inv_org_id = item.organization_id(+)
   AND item.organization_id IS NULL;

CURSOR Dangling_Items_Incre IS
SELECT distinct tmp.inventory_item_id, tmp.item_inv_org_id
  FROM isc_tmp_book_sum2 tmp,
       eni_oltp_item_star item
 WHERE tmp.inventory_item_id = item.inventory_item_id(+)
   AND tmp.item_inv_org_id = item.organization_id(+)
   AND item.organization_id IS NULL;

l_item	NUMBER;
l_org	NUMBER;
l_total	NUMBER;

BEGIN

  l_total := 0;

  IF (g_load_mode = 'INITIAL') THEN
     OPEN dangling_items_init;
     FETCH dangling_items_init INTO l_item, l_org;

    IF dangling_items_init%ROWCOUNT <> 0 THEN
       BIS_COLLECTION_UTILITIES.Put_Line('Collection failed because there are dangling keys for item dimension.');
       BIS_COLLECTION_UTILITIES.Put_Line('No records were loaded');

       BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
       BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
       BIS_COLLECTION_UTILITIES.Put_Line_Out(fnd_message.get_string('ISC', 'ISC_DBI_ITEM_NO_LOAD'));
       BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
       BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(fnd_message.get_string('ISC','ISC_DBI_INV_ITEM_ID'),23,' ')||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_ORG_ID'),20,' '));
       BIS_COLLECTION_UTILITIES.Put_Line_Out('----------------------- - --------------------');

       WHILE Dangling_Items_Init%FOUND LOOP
          BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(l_item,23,' ')||' - '||RPAD(l_org,20,' '));
  	  FETCH Dangling_Items_Init INTO l_item, l_org;
       END LOOP;
       BIS_COLLECTION_UTILITIES.Put_Line_Out('+--------------------------------------------+');
    ELSE
       BIS_COLLECTION_UTILITIES.Put_Line(' ');
       BIS_COLLECTION_UTILITIES.Put_Line('           THERE IS NO DANGLING ITEMS        ');
       BIS_COLLECTION_UTILITIES.Put_Line('+--------------------------------------------+');
       BIS_COLLECTION_UTILITIES.Put_Line(' ');
    END IF;
    l_total := Dangling_Items_Init%ROWCOUNT;
    CLOSE Dangling_Items_Init;

  ELSIF (g_load_mode = 'INCREMENTAL') THEN
    OPEN dangling_items_incre;
    FETCH dangling_items_incre INTO l_item, l_org;

    IF dangling_items_incre%ROWCOUNT <> 0 THEN
       BIS_COLLECTION_UTILITIES.Put_Line('Collection failed because there are dangling keys for item dimension.');
       BIS_COLLECTION_UTILITIES.Put_Line('No records were loaded');

       BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
       BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
       BIS_COLLECTION_UTILITIES.Put_Line_Out(fnd_message.get_string('ISC', 'ISC_DBI_ITEM_NO_LOAD'));
       BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
       BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(fnd_message.get_string('ISC','ISC_DBI_INV_ITEM_ID'),23,' ')||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_ORG_ID'),20,' '));
       BIS_COLLECTION_UTILITIES.Put_Line_Out('----------------------- - --------------------');

       WHILE Dangling_Items_Incre%FOUND LOOP
          BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(l_item,23,' ')||' - '||RPAD(l_org,20,' '));
	  FETCH Dangling_Items_Incre INTO l_item, l_org;
       END LOOP;
       BIS_COLLECTION_UTILITIES.Put_Line_Out('+--------------------------------------------+');
    ELSE
       BIS_COLLECTION_UTILITIES.Put_Line(' ');
       BIS_COLLECTION_UTILITIES.Put_Line('           THERE IS NO DANGLING ITEMS        ');
       BIS_COLLECTION_UTILITIES.Put_Line('+--------------------------------------------+');
       BIS_COLLECTION_UTILITIES.Put_Line(' ');
    END IF;
    l_total := Dangling_Items_Incre%ROWCOUNT;
    CLOSE Dangling_Items_Incre;
  END IF;

  RETURN(l_total);

  EXCEPTION
   WHEN OTHERS THEN
    g_errbuf  := 'Error in Function IDENTIFY_DANGLING_ITEM : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
 END;

      -- -----------------------------------
      -- Reporting of the missing currencies
      -- -----------------------------------

FUNCTION REPORT_MISSING_RATE RETURN NUMBER IS

l_sec_curr_def	VARCHAR2(1);




CURSOR Missing_Currency_Conversion IS
   SELECT distinct decode(rate1, -3, to_date('01/01/1999','MM/DD/RRRR'), conversion_date) CURR_CONV_DATE,
	  from_currency,
 	  to_currency1 TO_CURRENCY,
	  conversion_type RATE_TYPE,
 	  decode(rate1, -1, 'RATE NOT AVAILABLE', -2, 'INVALID CURRENCY') STATUS
     FROM isc_curr_book_sum2 tmp
    WHERE rate1 < 0
      AND upper(conversion_type) <> 'USER'
   UNION
   SELECT distinct decode(rate2, -3, to_date('01/01/1999','MM/DD/RRRR'), conversion_date) CURR_CONV_DATE,
	  to_currency3 FROM_CURRENCY,
 	  g_global_currency TO_CURRENCY,
	  g_global_rate_type RATE_TYPE,
 	  decode(rate2, -1, 'RATE NOT AVAILABLE', -2, 'INVALID CURRENCY') STATUS
     FROM isc_curr_book_sum2 tmp
    WHERE rate2 < 0
   UNION
   SELECT distinct decode(rate3, -3, to_date('01/01/1999','MM/DD/RRRR'), conversion_date) CURR_CONV_DATE,
	  from_currency,
 	  to_currency3,
	  g_global_rate_type RATE_TYPE,
   	  decode(rate3, -1, 'RATE NOT AVAILABLE', -2, 'INVALID CURRENCY') STATUS
     FROM isc_curr_book_sum2 tmp
    WHERE rate3 < 0
   UNION
   SELECT distinct decode(rate4, -3, to_date('01/01/1999','MM/DD/RRRR'), conversion_date) CURR_CONV_DATE,
	  to_currency3 FROM_CURRENCY,
 	  g_sec_global_currency TO_CURRENCY,
	  g_sec_global_rate_type RATE_TYPE,
 	  decode(rate4, -1, 'RATE NOT AVAILABLE', -2, 'INVALID CURRENCY') STATUS
     FROM isc_curr_book_sum2 tmp
    WHERE rate4 < 0
      AND l_sec_curr_def = 'Y';

l_record				Missing_Currency_Conversion%ROWTYPE;
l_total					NUMBER := 0;

 BEGIN

  l_sec_curr_def := isc_dbi_currency_pkg.is_sec_curr_defined;


  OPEN Missing_Currency_Conversion;
  FETCH Missing_Currency_Conversion INTO l_record;

  IF Missing_Currency_Conversion%ROWCOUNT <> 0
    THEN
      BIS_COLLECTION_UTILITIES.Put_Line('Collection failed because there are missing currency conversion rates.');
      BIS_COLLECTION_UTILITIES.Put_Line(fnd_message.get_string('BIS', 'BIS_DBI_CURR_NO_LOAD'));

      BIS_COLLECTION_UTILITIES.writeMissingRateHeader;
        WHILE Missing_Currency_Conversion%FOUND LOOP
          l_total := l_total + 1;
	  BIS_COLLECTION_UTILITIES.writeMissingRate(
        	l_record.rate_type,
        	l_record.from_currency,
        	l_record.to_currency,
        	l_record.curr_conv_date);
	  FETCH Missing_Currency_Conversion INTO l_record;
	END LOOP;
      BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
      BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');

  ELSE -- Missing_Currency_Conversion%ROWCOUNT = 0
      BIS_COLLECTION_UTILITIES.Put_Line(' ');
      BIS_COLLECTION_UTILITIES.Put_Line('           THERE IS NO MISSING CURRENCY CONVERSION RATE        ');
      BIS_COLLECTION_UTILITIES.Put_Line('+---------------------------------------------------------------------------+');
      BIS_COLLECTION_UTILITIES.Put_Line(' ');
  END IF; -- Missing_Currency_Conversion%ROWCOUNT <> 0

  CLOSE Missing_Currency_Conversion;



  RETURN(l_total);

  EXCEPTION
   WHEN OTHERS THEN

    g_errbuf  := 'Error in Function REPORT_MISSING_RATE : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
 END;

      -- ---------------------------------------------
      -- Reporting of the Missing UOM Conversion Rates
      -- ---------------------------------------------

FUNCTION REPORT_MISSING_UOM_RATE RETURN NUMBER IS

CURSOR Missing_UOM_Conversion IS
   SELECT distinct inventory_item_id,
	  order_quantity_uom from_unit,
	  inv_uom_code to_unit
     FROM ISC_TMP_BOOK_SUM2
    WHERE inv_uom_rate = -99999;

CURSOR Missing_Transaction_UOM IS
   SELECT order_number,
	  line_number,
	  header_id,
	  pk1 line_id
     FROM ISC_TMP_BOOK_SUM2
    WHERE order_quantity_uom IS NULL;

l_record				Missing_UOM_Conversion%ROWTYPE;
l_uom_record				Missing_Transaction_UOM%ROWTYPE;
l_total					NUMBER := 0;

BEGIN

  OPEN Missing_UOM_Conversion;
  FETCH Missing_UOM_Conversion INTO l_record;

  IF Missing_UOM_Conversion%ROWCOUNT <> 0 THEN
     BIS_COLLECTION_UTILITIES.Put_Line('Collection failed because there are missing UOM conversion rates.');
     BIS_COLLECTION_UTILITIES.Put_Line(fnd_message.get_string('BIS', 'BIS_DBI_UOM_NO_LOAD'));

     BIS_COLLECTION_UTILITIES.writeMissingUOMHeader;
     WHILE Missing_UOM_Conversion%FOUND LOOP
  	l_total := l_total + 1;

	  BIS_COLLECTION_UTILITIES.writeMissingUOM(
		nvl(l_record.from_unit,' '),
		nvl(l_record.to_unit,' '),
		l_record.inventory_item_id);

	  FETCH Missing_UOM_Conversion INTO l_record;
     END LOOP;

     OPEN Missing_Transaction_UOM;
     FETCH Missing_Transaction_UOM INTO l_uom_record;

     IF Missing_Transaction_UOM%ROWCOUNT <> 0
     THEN

     BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
     BIS_COLLECTION_UTILITIES.Put_Line_Out(fnd_message.get_string('ISC', 'ISC_DBI_UOM_NO_LOAD'));
     BIS_COLLECTION_UTILITIES.Put_Line_Out(' ');
     BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(fnd_message.get_string('ISC','ISC_DBI_ORDER_NUMBER'),16,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_LINE_NUMBER'),18,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_HEADER_ID'),17,' ')
	||' - '||RPAD(fnd_message.get_string('ISC','ISC_DBI_LINE_ID'),17,' '));

     BIS_COLLECTION_UTILITIES.Put_Line_Out('---------------- - ------------------ - ----------------- - -----------------');

     WHILE Missing_Transaction_UOM%FOUND LOOP
	BIS_COLLECTION_UTILITIES.Put_Line_Out(RPAD(l_uom_record.order_number,16,' ')
			      ||' - '||RPAD(l_uom_record.line_number,18,' ')
			      ||' - '||RPAD(l_uom_record.header_id,17,' ')
			      ||' - '||RPAD(l_uom_record.line_id,17,' '));

	FETCH Missing_Transaction_UOM INTO l_uom_record;
     END LOOP;
     BIS_COLLECTION_UTILITIES.Put_Line_Out('+---------------------------------------------------------------------------+');
     END IF;

  CLOSE Missing_Transaction_UOM;

  ELSE -- Missing_UOM_Conversion%ROWCOUNT = 0
      BIS_COLLECTION_UTILITIES.Put_Line(' ');
      BIS_COLLECTION_UTILITIES.Put_Line('	    THERE IS NO MISSING UOM CONVERSION RATE	   ');
      BIS_COLLECTION_UTILITIES.Put_Line('+---------------------------------------------------------------------------+');
      BIS_COLLECTION_UTILITIES.Put_Line(' ');
  END IF; -- Missing_UOM_Conversion%ROWCOUNT <> 0

  CLOSE Missing_UOM_Conversion;

  RETURN(l_total);

  EXCEPTION
   WHEN OTHERS THEN
    g_errbuf  := 'Error in Function REPORT_MISSING_UOM_RATE : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
 END;

      -- --------------
      -- DANGLING_CHECK
      -- --------------

FUNCTION DANGLING_CHECK RETURN NUMBER IS

l_time_dangling	NUMBER := 0;
l_item_count	NUMBER := 0;
l_miss_conv	NUMBER := 0;
l_miss_uom	NUMBER := 0;
l_dangling	NUMBER := 0;

BEGIN


      -- ----------------------------------------------------------
      -- Identify Missing Currency Rate from ISC_TMP_BOOK_SUM2
      -- When there is missing rate, exit the collection with error
      -- ----------------------------------------------------------

     BIS_COLLECTION_UTILITIES.put_line(' ');
     BIS_COLLECTION_UTILITIES.put_line('Identifying the missing currency conversion rates');
     FII_UTIL.Start_Timer;


     l_miss_conv := REPORT_MISSING_RATE;

     FII_UTIL.Stop_Timer;
     FII_UTIL.Print_Timer('Completed missing currency check in');

     IF (l_miss_conv = -1) THEN
        return(-1);
     ELSIF (l_miss_conv > 0) THEN
        g_errbuf  := g_errbuf || 'Collection aborted due to missing currency conversion rates. ';
        l_dangling := -999;
     END IF;


      -- --------------------------------------------------------------
      -- Identify Missing UOM Rate from ISC_TMP_BOOK_SUM2
      -- When there is missing UOM rate, exit the collection with error
      -- --------------------------------------------------------------

     BIS_COLLECTION_UTILITIES.put_line(' ');
     BIS_COLLECTION_UTILITIES.put_line('Identifying the missing UOM conversion rates');
     FII_UTIL.Start_Timer;

     l_miss_uom := REPORT_MISSING_UOM_RATE;

     FII_UTIL.Stop_Timer;
     FII_UTIL.Print_Timer('Completed missing UOM check in');

     IF (l_miss_uom = -1) THEN
	return(-1);
     ELSIF (l_miss_uom > 0) THEN
	g_errbuf  := g_errbuf || 'Collection aborted due to missing UOM conversion rates. ';
	l_dangling := -999;
     END IF;



      -- ---------------------
      -- CHECK_TIME_CONTINUITY
      -- ---------------------

     BIS_COLLECTION_UTILITIES.Put_Line(' ');
     BIS_COLLECTION_UTILITIES.put_line('Checking Time Continuity');

      l_time_dangling := check_time_continuity;

     IF (l_time_dangling = -1) THEN
        return(-1);
     ELSIF (l_time_dangling = -999) THEN
        g_errbuf  := g_errbuf || 'Collection aborted due to dangling keys for time dimension. ';
        l_dangling := -999;
     END IF;



      -- -------------------------------------
      -- Check Dangling Key for Item Dimension
      -- -------------------------------------

     BIS_COLLECTION_UTILITIES.put_line(' ');
     BIS_COLLECTION_UTILITIES.put_line('Identifying the dangling items');

    FII_UTIL.Start_Timer;

     l_item_count := IDENTIFY_DANGLING_ITEM;

    FII_UTIL.Stop_Timer;
    FII_UTIL.Print_Timer('Identified '||l_item_count||' dangling items in');

     IF (l_item_count = -1)
        THEN return(-1);
     ELSIF (l_item_count > 0) THEN
        g_errbuf  := g_errbuf || 'Collection aborted due to dangling items. ';
        l_dangling := -999;
     END IF;


     IF (l_dangling = -999) THEN
        return(-1);
     END IF;

 RETURN(1);

 EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function DANGLING_CHECK : '||sqlerrm;
    g_retcode	:= sqlcode;
    RETURN(-1);

END dangling_check;


      -- -----------
      -- INSERT_FACT
      -- -----------

FUNCTION INSERT_FACT RETURN NUMBER IS

l_total 	NUMBER;

BEGIN

 l_total := 0;



 INSERT /*+ APPEND PARALLEL(F) */ INTO ISC_BOOK_SUM2_F F
    (line_id,
     item_id,
     inv_org_id,
     inv_ou_id,
     org_ou_id,
     customer_id,
     sales_channel_id,
     return_reason_id,
     order_category_id,
     order_source_id,
     order_type_id,
     ship_to_org_id,
     sold_to_org_id,
     time_act_ship_date_id,
     time_booked_date_id,
     time_shipped_date_id,
     time_fulfilled_date_id,
     time_schedule_date_id,
     time_ordered_date_id,
     time_promise_date_id,
     time_request_date_id,
     currency_func_id,
     curr_wh_func_id,
     inventory_item_id,
     item_inv_org_id,
     top_model_item_id,
     top_model_org_id,
     actual_shipment_date,
     booked_date,
     shipped_date,
     fulfilled_date,
     schedule_ship_date,
     ordered_date,
     promise_date,
     request_date,
     ordered_quantity,
     header_id,
     h_marketing_source_code_id,
     invoice_to_org_id,
     marketing_source_code_id,
     open_flag,
     order_date_type_code,
     order_number,
     order_quantity_uom,
     shippable_flag,
     fulfilled_flag,
     line_category_code,
     line_item_type,
     line_number,
     item_type_code,
     ato_line_id,
     count_pdue_line,
     count_ship_line,
     flow_status_code,
     inv_uom_code,
     top_model_line_id,
     unit_list_price,
     unit_selling_price,
     service_parent_line_id,
     booked_amt_g,
     invoiced_amt_g,
     shipped_amt_g,
     fulfilled_amt_g,
     booked_list_amt_g,
     booked_amt_f,
     invoiced_amt_f,
     shipped_amt_f,
     fulfilled_amt_f,
     booked_list_amt_f,
     booked_amt_f1,
     invoiced_amt_f1,
     shipped_amt_f1,
     fulfilled_amt_f1,
     booked_list_amt_f1,
     booked_qty_inv,
     invoiced_qty_inv,
     shipped_qty_inv,
     fulfilled_qty_inv,
     created_by,
     last_update_login,
     creation_date,
     last_updated_by,
     last_update_date,
     ship_to_party_id,
     booked_amt_g1,
     invoiced_amt_g1,
     shipped_amt_g1,
     fulfilled_amt_g1,
     booked_list_amt_g1,
     freight_charge,
     freight_charge_f,
     freight_charge_g,
     freight_charge_g1,
     freight_cost,
     freight_cost_f,
     freight_cost_g,
     freight_cost_g1,
     charge_periodicity_code,
     blanket_number,
     blanket_line_number)
   SELECT /*+ PARALLEL(v)*/ v.line_id,
   	v.item_id,
   	v.inv_org_id,
   	v.inv_ou_id,
   	v.org_ou_id,
   	v.customer_id,
	v.sales_channel_id,
	v.return_reason_id,
	v.order_category_id,
	v.order_source_id,
	v.order_type_id,
        v.ship_to_org_id,
        v.sold_to_org_id,
	v.time_act_ship_date_id,
	v.time_booked_date_id,
	v.time_shipped_date_id,
	v.time_fulfilled_date_id,
	v.time_schedule_date_id,
	v.time_ordered_date_id,
	v.time_promise_date_id,
	v.time_request_date_id,
	v.currency_func_id,
	v.curr_wh_func_id,
	v.inventory_item_id,
	v.item_inv_org_id,
	v.top_model_item_id,
	v.top_model_org_id,
	v.actual_shipment_date,
	v.booked_date,
	v.shipped_date,
	v.fulfilled_date,
	v.schedule_ship_date,
	v.ordered_date,
     	v.promise_date,
     	v.request_date,
	v.ordered_quantity,
	v.header_id,
	v.h_marketing_source_code_id,
	v.invoice_to_org_id,
	v.marketing_source_code_id,
	v.open_flag,
	v.order_date_type_code,
	v.order_number,
	v.order_quantity_uom,
	v.shippable_flag,
	v.fulfilled_flag,
	v.line_category_code,
  	v.line_item_type,
 	v.line_number,
	v.item_type_code,
	v.ato_line_id,
	v.count_pdue_line,
	v.count_ship_line,
	v.flow_status_code,
     	v.inv_uom_code,
	v.top_model_line_id,
	v.unit_list_price,
	v.unit_selling_price,
     	v.service_parent_line_id,
	v.booked_amt_g,
	v.invoiced_amt_g,
	v.shipped_amt_g,
	v.fulfilled_amt_g,
	v.booked_list_amt_g,
	v.booked_amt_f,
	v.invoiced_amt_f,
	v.shipped_amt_f,
	v.fulfilled_amt_f,
	v.booked_list_amt_f,
	v.booked_amt_f1,
	v.invoiced_amt_f1,
	v.shipped_amt_f1,
	v.fulfilled_amt_f1,
	v.booked_list_amt_f1,
     	v.booked_qty_inv,
     	v.invoiced_qty_inv,
     	v.shipped_qty_inv,
     	v.fulfilled_qty_inv,
	v.created_by,
	v.last_update_login,
	v.creation_date,
	v.last_updated_by,
	v.last_update_date,
   	v.ship_to_party_id,
	v.booked_amt_g1,
	v.invoiced_amt_g1,
	v.shipped_amt_g1,
	v.fulfilled_amt_g1,
	v.booked_list_amt_g1,
	v.freight_charge,
	v.freight_charge_f,
	v.freight_charge_g,
	v.freight_charge_g1,
	v.freight_cost,
	v.freight_cost_f,
	v.freight_cost_g,
	v.freight_cost_g1,
	v.charge_periodicity_code,
        v.blanket_number,
        v.blanket_line_number
   FROM ISCBV_BOOK_SUM2_FCV v;

 l_total := sql%rowcount;
 COMMIT;

 RETURN(l_total);

 EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function INSERT_FACT : '||sqlerrm;
    g_retcode	:= sqlcode;
    RETURN(-1);

END insert_fact;

      -- -----------
      -- MERGE_FACT
      -- -----------

FUNCTION MERGE_FACT(p_batch number) RETURN NUMBER IS

l_count		NUMBER;
l_total		NUMBER;
l_max_batch	NUMBER;
l_date		DATE;

BEGIN


 l_total := 0;
 l_date := to_date('01/01/0001','DD/MM/YYYY');

 FOR v_batch_id IN 1..p_batch
   LOOP
     FII_UTIL.Start_Timer;
     BIS_COLLECTION_UTILITIES.put_line('Merging batch '||v_batch_id);

     l_count := 0;


     MERGE INTO ISC_BOOK_SUM2_F f
     USING
     (select new.* from ISCBV_BOOK_SUM2_FCV new, ISC_BOOK_SUM2_F old
       where new.line_id = old.line_id(+)
	 and new.batch_id = v_batch_id
	 and (old.line_id is null
              or new.customer_id <> old.customer_id
              or new.item_inv_org_id <> old.item_inv_org_id
              or new.inv_ou_id <> old.inv_ou_id
              or new.fulfilled_flag <> old.fulfilled_flag
              or new.open_flag <> old.open_flag
              or new.sales_channel_id <> old.sales_channel_id
              or new.return_reason_id <> old.return_reason_id
              or new.order_source_id <> old.order_source_id
              or new.booked_amt_f <> old.booked_amt_f
              or new.booked_amt_f1 <> old.booked_amt_f1
              or new.booked_amt_g <> old.booked_amt_g
              or new.booked_amt_g1 <> old.booked_amt_g1
              or new.freight_charge <> old.freight_charge
              or new.freight_charge_f <> old.freight_charge_f
              or new.freight_charge_g <> old.freight_charge_g
              or new.freight_charge_g1 <> old.freight_charge_g1
              or new.freight_cost <> old.freight_cost
              or new.freight_cost_f <> old.freight_cost_f
              or new.freight_cost_g <> old.freight_cost_g
              or new.freight_cost_g1 <> old.freight_cost_g1
              or new.booked_qty_inv <> old.booked_qty_inv
              or new.fulfilled_amt_f <> old.fulfilled_amt_f
              or new.fulfilled_amt_f1 <> old.fulfilled_amt_f1
              or new.fulfilled_amt_g <> old.fulfilled_amt_g
              or new.fulfilled_amt_g1 <> old.fulfilled_amt_g1
              or new.fulfilled_qty_inv <> old.fulfilled_qty_inv
              or new.invoiced_amt_f <> old.invoiced_amt_f
              or new.invoiced_amt_f1 <> old.invoiced_amt_f1
              or new.invoiced_amt_g <> old.invoiced_amt_g
              or new.invoiced_amt_g1 <> old.invoiced_amt_g1
              or new.invoiced_qty_inv <> old.invoiced_qty_inv
              or new.shipped_amt_f <> old.shipped_amt_f
              or new.shipped_amt_f1 <> old.shipped_amt_f1
              or new.shipped_amt_g <> old.shipped_amt_g
              or new.shipped_amt_g1 <> old.shipped_amt_g1
              or new.shipped_qty_inv <> old.shipped_qty_inv
              or new.org_ou_id <> old.org_ou_id
              or new.booked_date <> old.booked_date
              or new.inventory_item_id <> old.inventory_item_id
              or new.order_number <> old.order_number
              or new.line_number <> old.line_number
              or new.line_category_code <> old.line_category_code
              or new.currency_func_id <> old.currency_func_id
              or new.curr_wh_func_id <> old.curr_wh_func_id
              or new.order_quantity_uom <> old.order_quantity_uom
              or new.inv_uom_code <> old.inv_uom_code
	      or new.ship_to_party_id <> old.ship_to_party_id
              or nvl(new.actual_shipment_date,l_date) <> nvl(old.actual_shipment_date, l_date)
              or nvl(new.fulfilled_date, l_date) <> nvl(old.fulfilled_date, l_date)
              or nvl(new.promise_date, l_date) <> nvl(old.promise_date, l_date)
              or nvl(new.request_date, l_date) <> nvl(old.request_date, l_date)
              or nvl(new.schedule_ship_date, l_date) <> nvl(old.schedule_ship_date, l_date)
              or nvl(new.service_parent_line_id, -1) <> nvl(old.service_parent_line_id, -1)
              or nvl(new.invoice_to_org_id, -1) <> nvl(old.invoice_to_org_id, -1)
              or nvl(new.ordered_date, l_date) <> nvl(old.ordered_date, l_date)
              or nvl(new.ordered_quantity, 0) <> nvl(old.ordered_quantity, 0)
              or nvl(new.unit_selling_price, 0) <> nvl(old.unit_selling_price, 0)
              or nvl(new.blanket_number,0) <> nvl(old.blanket_number, 0)
              or nvl(new.blanket_line_number,0) <> nvl(old.blanket_line_number, 0)
              or nvl(new.charge_periodicity_code,'na') <> nvl(old.charge_periodicity_code,'na')
              or nvl(new.flow_status_code, 'na') <> nvl(old.flow_status_code, 'na')
              or nvl(new.h_marketing_source_code_id, -1) <> nvl(old.h_marketing_source_code_id, -1)
              or nvl(new.marketing_source_code_id, -1) <> nvl(old.marketing_source_code_id, -1)
              or nvl(new.item_type_code, 'na') <> nvl(old.item_type_code, 'na')
              or nvl(new.order_date_type_code, 'na') <> nvl(old.order_date_type_code, 'na')
              or nvl(new.shippable_flag, 'na') <> nvl(old.shippable_flag, 'na')
              or nvl(new.unit_list_price, 0) <> nvl(old.unit_list_price, 0)
              or nvl(new.order_type_id, -1) <> nvl(old.order_type_id, -1)
	      or nvl(new.sold_to_org_id, -1) <> nvl(old.sold_to_org_id, -1)
	      or nvl(new.ship_to_org_id, -1) <> nvl(old.ship_to_org_id, -1)
              or nvl(new.ato_line_id, -1) <> nvl(old.ato_line_id, -1)
              or nvl(new.top_model_line_id, -1) <> nvl(old.top_model_line_id, -1)
              or nvl(new.item_id, -1) <> nvl(old.item_id, -1)
              or nvl(new.inv_org_id, -1) <> nvl(old.inv_org_id, -1)
              or nvl(new.top_model_item_id, -1) <> nvl(old.top_model_item_id, -1)
              or nvl(new.top_model_org_id, -1) <> nvl(old.top_model_org_id, -1))) v
     ON (f.line_id = v.line_id)
     WHEN MATCHED THEN UPDATE SET
      f.item_id = v.item_id,
      f.inv_org_id = v.inv_org_id,
      f.inv_ou_id = v.inv_ou_id,
      f.org_ou_id = v.org_ou_id,
      f.customer_id = v.customer_id,
      f.sales_channel_id = v.sales_channel_id,
      f.return_reason_id = v.return_reason_id,
      f.order_category_id = v.order_category_id,
      f.order_source_id = v.order_source_id,
      f.order_type_id = v.order_type_id,
      f.ship_to_org_id = v.ship_to_org_id,
      f.sold_to_org_id = v.sold_to_org_id,
      f.time_act_ship_date_id = v.time_act_ship_date_id,
      f.time_booked_date_id = v.time_booked_date_id,
      f.time_shipped_date_id = v.time_shipped_date_id,
      f.time_fulfilled_date_id = v.time_fulfilled_date_id,
      f.time_schedule_date_id = v.time_schedule_date_id,
      f.time_ordered_date_id = v.time_ordered_date_id,
      f.time_promise_date_id = v.time_promise_date_id,
      f.time_request_date_id = v.time_request_date_id,
      f.currency_func_id = v.currency_func_id,
      f.curr_wh_func_id = v.curr_wh_func_id,
      f.inventory_item_id = v.inventory_item_id,
      f.item_inv_org_id = v.item_inv_org_id,
      f.top_model_item_id = v.top_model_item_id,
      f.top_model_org_id = v.top_model_org_id,
      f.actual_shipment_date = v.actual_shipment_date,
      f.booked_date = v.booked_date,
      f.shipped_date = v.shipped_date,
      f.fulfilled_date = v.fulfilled_date,
      f.schedule_ship_date = v.schedule_ship_date,
      f.ordered_date = v.ordered_date,
      f.promise_date = v.promise_date,
      f.request_date = v.request_date,
      f.ordered_quantity = v.ordered_quantity,
      f.header_id = v.header_id,
      f.h_marketing_source_code_id = v.h_marketing_source_code_id,
      f.invoice_to_org_id = v.invoice_to_org_id,
      f.marketing_source_code_id = v.marketing_source_code_id,
      f.open_flag = v.open_flag,
      f.order_date_type_code = v.order_date_type_code,
      f.order_number = v.order_number,
      f.order_quantity_uom = v.order_quantity_uom,
      f.shippable_flag = v.shippable_flag,
      f.fulfilled_flag = v.fulfilled_flag,
      f.line_category_code = v.line_category_code,
      f.line_item_type = v.line_item_type,
      f.line_number = v.line_number,
      f.item_type_code = v.item_type_code,
      f.ato_line_id = v.ato_line_id,
      f.count_pdue_line = v.count_pdue_line,
      f.count_ship_line = v.count_ship_line,
      f.flow_status_code = v.flow_status_code,
      f.inv_uom_code = v.inv_uom_code,
      f.top_model_line_id = v.top_model_line_id,
      f.unit_list_price = v.unit_list_price,
      f.unit_selling_price = v.unit_selling_price,
      f.service_parent_line_id = v.service_parent_line_id,
      f.booked_amt_g = v.booked_amt_g,
      f.invoiced_amt_g = v.invoiced_amt_g,
      f.shipped_amt_g = v.shipped_amt_g,
      f.fulfilled_amt_g = v.fulfilled_amt_g,
      f.booked_list_amt_g = v.booked_list_amt_g,
      f.booked_amt_f= v.booked_amt_f,
      f.invoiced_amt_f= v.invoiced_amt_f,
      f.shipped_amt_f = v.shipped_amt_f,
      f.fulfilled_amt_f = v.fulfilled_amt_f,
      f.booked_list_amt_f = v.booked_list_amt_f,
      f.booked_amt_f1= v.booked_amt_f1,
      f.invoiced_amt_f1= v.invoiced_amt_f1,
      f.shipped_amt_f1 = v.shipped_amt_f1,
      f.fulfilled_amt_f1 = v.fulfilled_amt_f1,
      f.booked_list_amt_f1 = v.booked_list_amt_f1,
      f.booked_qty_inv = v.booked_qty_inv,
      f.invoiced_qty_inv = v.invoiced_qty_inv,
      f.shipped_qty_inv = v.shipped_qty_inv,
      f.fulfilled_qty_inv = v.fulfilled_qty_inv,
      f.created_by = v.created_by,
      f.last_update_login = v.last_update_login,
      f.creation_date = v.creation_date,
      f.last_updated_by = v.last_updated_by,
      f.last_update_date = v.last_update_date,
      f.ship_to_party_id = v.ship_to_party_id,
      f.booked_amt_g1 = v.booked_amt_g1,
      f.invoiced_amt_g1 = v.invoiced_amt_g1,
      f.shipped_amt_g1 = v.shipped_amt_g1,
      f.fulfilled_amt_g1 = v.fulfilled_amt_g1,
      f.booked_list_amt_g1 = v.booked_list_amt_g1,
      f.freight_charge  = v.freight_charge,
      f.freight_charge_f  = v.freight_charge_f,
      f.freight_charge_g  = v.freight_charge_g,
      f.freight_charge_g1  = v.freight_charge_g1,
      f.freight_cost  = v.freight_cost,
      f.freight_cost_f  = v.freight_cost_f,
      f.freight_cost_g  = v.freight_cost_g,
      f.freight_cost_g1  = v.freight_cost_g1,
      f.charge_periodicity_code  = v.charge_periodicity_code,
      f.blanket_number = v.blanket_number,
      f.blanket_line_number = v.blanket_line_number
     WHEN NOT MATCHED THEN INSERT(
      f.line_id,
      f.item_id,
      f.inv_org_id,
      f.inv_ou_id,
      f.org_ou_id,
      f.customer_id,
      f.sales_channel_id,
      f.return_reason_id,
      f.order_category_id,
      f.order_source_id,
      f.order_type_id,
      f.ship_to_org_id,
      f.sold_to_org_id,
      f.time_act_ship_date_id,
      f.time_booked_date_id,
      f.time_shipped_date_id,
      f.time_fulfilled_date_id,
      f.time_schedule_date_id,
      f.time_ordered_date_id,
      f.time_promise_date_id,
      f.time_request_date_id,
      f.currency_func_id,
      f.curr_wh_func_id,
      f.inventory_item_id,
      f.item_inv_org_id,
      f.top_model_item_id,
      f.top_model_org_id,
      f.actual_shipment_date,
      f.booked_date,
      f.shipped_date,
      f.fulfilled_date,
      f.schedule_ship_date,
      f.ordered_date,
      f.promise_date,
      f.request_date,
      f.ordered_quantity,
      f.header_id,
      f.h_marketing_source_code_id,
      f.invoice_to_org_id,
      f.marketing_source_code_id,
      f.open_flag,
      f.order_date_type_code,
      f.order_number,
      f.order_quantity_uom,
      f.shippable_flag,
      f.fulfilled_flag,
      f.line_category_code,
      f.line_item_type,
      f.line_number,
      f.item_type_code,
      f.ato_line_id,
      f.count_pdue_line,
      f.count_ship_line,
      f.flow_status_code,
      f.inv_uom_code,
      f.top_model_line_id,
      f.unit_list_price,
      f.unit_selling_price,
      f.service_parent_line_id,
      f.booked_amt_g,
      f.invoiced_amt_g,
      f.shipped_amt_g,
      f.fulfilled_amt_g,
      f.booked_list_amt_g,
      f.booked_amt_f,
      f.invoiced_amt_f,
      f.shipped_amt_f,
      f.fulfilled_amt_f,
      f.booked_list_amt_f,
      f.booked_amt_f1,
      f.invoiced_amt_f1,
      f.shipped_amt_f1,
      f.fulfilled_amt_f1,
      f.booked_list_amt_f1,
      f.booked_qty_inv,
      f.invoiced_qty_inv,
      f.shipped_qty_inv,
      f.fulfilled_qty_inv,
      f.created_by,
      f.last_update_login,
      f.creation_date,
      f.last_updated_by,
      f.last_update_date,
      f.ship_to_party_id,
      f.booked_amt_g1,
      f.invoiced_amt_g1,
      f.shipped_amt_g1,
      f.fulfilled_amt_g1,
      f.booked_list_amt_g1,
      f.freight_charge,
      f.freight_charge_f,
      f.freight_charge_g,
      f.freight_charge_g1,
      f.freight_cost,
      f.freight_cost_f,
      f.freight_cost_g,
      f.freight_cost_g1,
      f.charge_periodicity_code,
      f.blanket_number,
      f.blanket_line_number)
     VALUES (
      v.line_id,
      v.item_id,
      v.inv_org_id,
      v.inv_ou_id,
      v.org_ou_id,
      v.customer_id,
      v.sales_channel_id,
      v.return_reason_id,
      v.order_category_id,
      v.order_source_id,
      v.order_type_id,
      v.ship_to_org_id,
      v.sold_to_org_id,
      v.time_act_ship_date_id,
      v.time_booked_date_id,
      v.time_shipped_date_id,
      v.time_fulfilled_date_id,
      v.time_schedule_date_id,
      v.time_ordered_date_id,
      v.time_promise_date_id,
      v.time_request_date_id,
      v.currency_func_id,
      v.curr_wh_func_id,
      v.inventory_item_id,
      v.item_inv_org_id,
      v.top_model_item_id,
      v.top_model_org_id,
      v.actual_shipment_date,
      v.booked_date,
      v.shipped_date,
      v.fulfilled_date,
      v.schedule_ship_date,
      v.ordered_date,
      v.promise_date,
      v.request_date,
      v.ordered_quantity,
      v.header_id,
      v.h_marketing_source_code_id,
      v.invoice_to_org_id,
      v.marketing_source_code_id,
      v.open_flag,
      v.order_date_type_code,
      v.order_number,
      v.order_quantity_uom,
      v.shippable_flag,
      v.fulfilled_flag,
      v.line_category_code,
      v.line_item_type,
      v.line_number,
      v.item_type_code,
      v.ato_line_id,
      v.count_pdue_line,
      v.count_ship_line,
      v.flow_status_code,
      v.inv_uom_code,
      v.top_model_line_id,
      v.unit_list_price,
      v.unit_selling_price,
      v.service_parent_line_id,
      v.booked_amt_g,
      v.invoiced_amt_g,
      v.shipped_amt_g,
      v.fulfilled_amt_g,
      v.booked_list_amt_g,
      v.booked_amt_f,
      v.invoiced_amt_f,
      v.shipped_amt_f,
      v.fulfilled_amt_f,
      v.booked_list_amt_f,
      v.booked_amt_f1,
      v.invoiced_amt_f1,
      v.shipped_amt_f1,
      v.fulfilled_amt_f1,
      v.booked_list_amt_f1,
      v.booked_qty_inv,
      v.invoiced_qty_inv,
      v.shipped_qty_inv,
      v.fulfilled_qty_inv,
      v.created_by,
      v.last_update_login,
      v.creation_date,
      v.last_updated_by,
      v.last_update_date,
      v.ship_to_party_id,
      v.booked_amt_g1,
      v.invoiced_amt_g1,
      v.shipped_amt_g1,
      v.fulfilled_amt_g1,
      v.booked_list_amt_g1,
      v.freight_charge,
      v.freight_charge_f,
      v.freight_charge_g,
      v.freight_charge_g1,
      v.freight_cost,
      v.freight_cost_f,
      v.freight_cost_g,
      v.freight_cost_g1,
      v.charge_periodicity_code,
      v.blanket_number,
      v.blanket_line_number);

      l_count := sql%rowcount;
      l_total := l_total + l_count;
      COMMIT;
      FII_UTIL.Stop_Timer;
      FII_UTIL.Print_Timer('Merged '||l_count|| ' rows in ');

   END LOOP;

 RETURN(l_total);

 EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function MERGE_FACT : '||sqlerrm;
    g_retcode	:= sqlcode;
    RETURN(-1);

END;

FUNCTION WRAPUP RETURN NUMBER IS

BEGIN

      -- ------------------------
      -- Delete ISC_TMP_BOOK_SUM2
      -- ------------------------

 BIS_COLLECTION_UTILITIES.put_line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Truncating the temp table');
 FII_UTIL.Start_Timer;

  IF (truncate_table('ISC_DBI_CHANGE_LOG') = -1) THEN
     return(-1);
  END IF;

  IF (truncate_table('ISC_TMP_BOOK_SUM2') = -1) THEN
     return(-1);
  END IF;

  IF (truncate_table('ISC_CURR_BOOK_SUM2') = -1) THEN
     return(-1);
  END IF;

  IF (truncate_table('ISC_SERVICE_BOOK_SUM2') = -1) THEN
     return(-1);
  END IF;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Truncated the temp table in');

      -- ----------------------------------------------
      -- No exception raised so far.  Successful.  Call
      -- Wrapup to commit and insert messages into logs
      -- ----------------------------------------------

  BIS_COLLECTION_UTILITIES.WRAPUP(
  TRUE,
  g_row_count,
  NULL,
  ISC_DBI_BOOK_SUM2_F_C.g_push_from_date,
  ISC_DBI_BOOK_SUM2_F_C.g_push_to_date
  );

 RETURN (1);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function WRAPUP : '||sqlerrm;
    g_retcode := sqlcode;
    RETURN(-1);
END wrapup;

      ---------------------
      -- Public Procedures
      ---------------------

Procedure load_fact(errbuf		IN OUT NOCOPY VARCHAR2,
                    retcode		IN OUT NOCOPY VARCHAR2) IS

l_failure		EXCEPTION;
l_start			DATE;
l_end			DATE;
l_period_from		DATE;
l_period_to		DATE;

l_row_count		NUMBER;
l_schema           	VARCHAR2(30);
l_status               	VARCHAR2(30);
l_industry             	VARCHAR2(30);

l_ont_schema		VARCHAR2(30);
l_stmt			VARCHAR2(2000);

BEGIN
  errbuf := NULL;
  retcode := '0';
  g_load_mode := 'INITIAL';

 BIS_COLLECTION_UTILITIES.Put_Line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Begin the ' || g_load_mode || ' load of the base summary ');

  IF (NOT BIS_COLLECTION_UTILITIES.setup('ISC_BOOK_SUM2_F')) THEN
     RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || errbuf);
     return;
  END IF;

  IF (CHECK_SETUP = -1)
     THEN RAISE l_failure;
  END IF;

  ISC_DBI_BOOK_SUM2_F_C.g_push_from_date := g_global_start_date;
  ISC_DBI_BOOK_SUM2_F_C.g_push_to_date := sysdate;

 BIS_COLLECTION_UTILITIES.put_line( 'The collection date range is from '||
	to_char(g_push_from_date,'MM/DD/YYYY HH24:MI:SS')||' to '||
	to_char(g_push_to_date,'MM/DD/YYYY HH24:MI:SS'));
 BIS_COLLECTION_UTILITIES.put_line(' ');

  EXECUTE IMMEDIATE 'alter session set hash_area_size=104857600';
  EXECUTE IMMEDIATE 'alter session set sort_area_size=104857600';

      --  --------------------------------------------
      --  Identify Change for Booked Orders Lines
      --  --------------------------------------------

  IF (FND_INSTALLATION.GET_APP_INFO('ONT', l_status, l_industry, l_ont_schema)) THEN
   l_stmt := 'TRUNCATE TABLE ' || l_ont_schema ||'.ONT_DBI_CHANGE_LOG';
   EXECUTE IMMEDIATE l_stmt;
  END IF;

  l_row_count := IDENTIFY_CHANGE_INIT;



 IF (l_row_count = -1)
    THEN RAISE l_failure;
 ELSIF (l_row_count = 0) THEN

    -- Fix bug 4150188
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line('Truncating the fact table');
    FII_UTIL.Start_Timer;

    IF (truncate_table('ISC_BOOK_SUM2_F') = -1) THEN
       RAISE l_failure;
    END IF;

    FII_UTIL.Stop_Timer;
    FII_UTIL.Print_Timer('Truncated the fact table in');

    g_row_count := 0;

 ELSE
      -- --------------
      -- Analyze tables
      -- --------------

 BIS_COLLECTION_UTILITIES.Put_Line(' ');
 BIS_COLLECTION_UTILITIES.Put_Line('Analyzing table ISC_TMP_BOOK_SUM2');
 FII_UTIL.Start_Timer;

  IF (FND_INSTALLATION.GET_APP_INFO('ISC', l_status, l_industry, l_schema)) THEN
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_schema,
				  TABNAME => 'ISC_TMP_BOOK_SUM2');
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_schema,
				  TABNAME => 'ISC_CURR_BOOK_SUM2');
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_schema,
				  TABNAME => 'ISC_SERVICE_BOOK_SUM2');
  END IF;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Analyzed the temp tables in ');



-- In DBI5.0, we determine if a PTO/KIT top model is shippable by scanning through all it's child lines
-- For DBI6.0, we do not support this logic anymore, so comment it out to improve performance

-- BIS_COLLECTION_UTILITIES.Put_Line(' ');
-- BIS_COLLECTION_UTILITIES.Put_Line('Identifying non-shippable CTO lines');
-- FII_UTIL.Start_Timer;

--  UPDATE /*+ PARALLEL(F) */ isc_tmp_book_sum2 F
--     SET view_type = 2
--   WHERE view_type = 3
--     AND PK1 is not null
--     AND pk1 NOT IN (select /*+ hash_aj parallel(l) */ top_model_line_id
--		       from oe_order_lines_all l
-- 		      where l.shippable_flag = 'Y'
--			and top_model_line_id is not null);
-- COMMIT;

-- FII_UTIL.Stop_Timer;
-- FII_UTIL.Print_Timer('Identified non-shippable CTO lines in ');


  IF (DANGLING_CHECK = -1) THEN
     RAISE l_failure;
  END IF;


      --  --------------------------------------------
      --  Truncate Sum2 table if it is an initial load
      --  --------------------------------------------

 BIS_COLLECTION_UTILITIES.put_line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Truncating the fact table');
 FII_UTIL.Start_Timer;

  IF (truncate_table('ISC_BOOK_SUM2_F') = -1) THEN
     RAISE l_failure;
  END IF;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Truncated the fact table in');

      --  --------------------------------------------
      --  Insert data into Sum2 table
      --  --------------------------------------------

 BIS_COLLECTION_UTILITIES.put_line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Inserting data into fact table');
 FII_UTIL.Start_Timer;

  g_row_count := Insert_fact;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Inserted '||nvl(g_row_count,0)||' rows into the fact table in');

 IF (g_row_count = -1) THEN
    RAISE l_failure;
 END IF;

 END IF;

 IF (WRAPUP = -1) THEN
    RAISE l_failure;
 END IF;

 IF (g_warning = 1) then
   retcode := '1';
 END IF;


 EXCEPTION

  WHEN L_FAILURE THEN
    ROLLBACK;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line(g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    g_row_count,
    g_errbuf,
    ISC_DBI_BOOK_SUM2_F_C.g_push_from_date,
    ISC_DBI_BOOK_SUM2_F_C.g_push_to_date
    );

  WHEN OTHERS THEN
    ROLLBACK;
    g_errbuf := sqlerrm ||' - '||sqlcode;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line('Other errors : '|| g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    g_row_count,
    g_errbuf,
    ISC_DBI_BOOK_SUM2_F_C.g_push_from_date,
    ISC_DBI_BOOK_SUM2_F_C.g_push_to_date
    );

END load_fact;

Procedure update_fact(errbuf			IN OUT NOCOPY VARCHAR2,
                      retcode			IN OUT NOCOPY VARCHAR2) IS

l_failure		EXCEPTION;
l_start			DATE;
l_end			DATE;
l_period_from		DATE;
l_period_to		DATE;
l_row_count		NUMBER		:= 0;
l_delete_count		NUMBER		:= 0;
l_schema           	VARCHAR2(30);
l_status               	VARCHAR2(30);
l_industry             	VARCHAR2(30);
l_sc_page_implemented	NUMBER		:= 0;

BEGIN
  errbuf  := NULL;
  retcode := '0';
  g_load_mode := 'INCREMENTAL';

 BIS_COLLECTION_UTILITIES.Put_Line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Begin the ' || g_load_mode || ' load of the base summary ');

  IF (NOT BIS_COLLECTION_UTILITIES.setup('ISC_BOOK_SUM2_F')) THEN
     RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || errbuf);
     return;
  END IF;

  BIS_COLLECTION_UTILITIES.get_last_refresh_dates('ISC_BOOK_SUM2_F', l_start, l_end, l_period_from, l_period_to);
  ISC_DBI_BOOK_SUM2_F_C.g_push_from_date := l_period_to;
  ISC_DBI_BOOK_SUM2_F_C.g_push_to_date := sysdate;

  IF (CHECK_SETUP = -1)
     THEN RAISE l_failure;
  END IF;

      --  --------------------------------------------
      --  Identify Change for Booked Orders Lines
      --  --------------------------------------------

 BIS_COLLECTION_UTILITIES.put_line('Identifying changed Booked orders lines');


  g_incre_start_date := sysdate;
 BIS_COLLECTION_UTILITIES.put_line('Last updated date is '|| to_char(g_incre_start_date,'MM/DD/YYYY HH24:MI:SS'));
  l_row_count := IDENTIFY_CHANGE_ICRL;



 IF (l_row_count = -1) THEN
    RAISE l_failure;
 ELSIF (l_row_count = 0) THEN
    g_row_count := 0;
 ELSE
      -- --------------
      -- Analyze tables
      -- --------------

 BIS_COLLECTION_UTILITIES.Put_Line(' ');
 BIS_COLLECTION_UTILITIES.Put_Line('Analyzing table ISC_TMP_BOOK_SUM2');
 FII_UTIL.Start_Timer;

  IF (FND_INSTALLATION.GET_APP_INFO('ISC', l_status, l_industry, l_schema)) THEN
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_schema,
				  TABNAME => 'ISC_TMP_BOOK_SUM2');
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_schema,
				  TABNAME => 'ISC_CURR_BOOK_SUM2');
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_schema,
				  TABNAME => 'ISC_SERVICE_BOOK_SUM2');
 END IF;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Analyzed the temp tables in ');




 -- In DBI5.0, we determine if a PTO/KIT top model is shippable by scanning through all it's child lines
 -- For DBI6.0, we do not support this logic anymore, so comment it out to improve performance

 -- BIS_COLLECTION_UTILITIES.Put_Line(' ');
 -- BIS_COLLECTION_UTILITIES.Put_Line('Identifying non-shippable CTO lines');
 -- FII_UTIL.Start_Timer;

 --  UPDATE /*+ PARALLEL(F) */ isc_tmp_book_sum2  F
 --     SET view_type = 2
 --   WHERE view_type = 3
 --     AND PK1 is not null
 --     AND pk1 NOT IN (select /*+ hash_aj parallel(l) */ top_model_line_id
 --		       from oe_order_lines_all l
 -- 		      where l.shippable_flag = 'Y'
 --			and top_model_line_id is not null);

 -- COMMIT;

 -- FII_UTIL.Stop_Timer;
 -- FII_UTIL.Print_Timer('Identified non-shippable CTO lines in ');






      --  ---------------------
      --  Dangling Checking
      --  ---------------------


  IF (DANGLING_CHECK = -1) THEN
     RAISE l_failure;
  END IF;


      --  --------------------------------------------
      --  Merge data into Sum2 table
      --  --------------------------------------------

 BIS_COLLECTION_UTILITIES.put_line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Merging data to fact table');


  g_row_count := Merge_fact(ceil(l_row_count/g_batch_size));

 BIS_COLLECTION_UTILITIES.put_line('Merged '||nvl(g_row_count,0)||' rows into the fact table');

  IF (g_row_count = -1) THEN
     RAISE l_failure;
  END IF;


      -- ------------------------------------
      -- Sales Credits INCREMENTAL collection
      -- ------------------------------------

  BIS_COLLECTION_UTILITIES.put_line('');
  BIS_COLLECTION_UTILITIES.put_line('');
  BIS_COLLECTION_UTILITIES.put_line('+--------------------------------------------+');
  BIS_COLLECTION_UTILITIES.put_line('Entering function Update_Sales_Fact.');



/* start of Sales Credits fact incremental collection */





  SELECT nvl(implementation_flag,0)
    INTO l_sc_page_implemented
    FROM (SELECT sum(decode(implementation_flag,'Y',1,0)) implementation_flag
  	    FROM bis_obj_properties
  	   WHERE object_name IN (SELECT distinct bis.object_name
				   FROM BIS_OBJ_DEPENDENCY bis,
					(SELECT object_name
					   FROM bis_obj_dependency
					  START WITH depend_object_name = 'ISC_SALES_CREDITS_F'
					CONNECT BY PRIOR object_name = depend_object_name
					  ORDER BY 1) inline
				  WHERE bis.object_name = inline.object_name
				    AND bis.object_type = 'PAGE'));

  IF l_sc_page_implemented = 0
    THEN
      NULL; -- no page using sales credits fact has been implemented, skip collection
       BIS_COLLECTION_UTILITIES.put_line('No implemented page is based on the Sales Credits fact.');
       BIS_COLLECTION_UTILITIES.put_line('Skipping the collection of Sales Credits fact.');
    ELSE
      BIS_COLLECTION_UTILITIES.put_line('Identified implemented pages using the Sales Credits fact.');
      BIS_COLLECTION_UTILITIES.put_line('Starting the Incremental collection of Sales Credits fact.');

      IF (update_sales_fact = -1) -- call of the sc_f incremental collection function
	THEN -- coll of sales credits fact errored out
          g_row_count := -1;
          BIS_COLLECTION_UTILITIES.put_line('Incremental collection of Sales Credits fact failed.');
	  RAISE l_failure;
	ELSE
          BIS_COLLECTION_UTILITIES.put_line('Incremental collection of Sales Fact finished.');
      END IF;

  END IF;
  BIS_COLLECTION_UTILITIES.put_line('Exiting function Update_Sales_Fact.');
  BIS_COLLECTION_UTILITIES.put_line('+--------------------------------------------+');




/* end of Sales Credits fact incremental collection*/



 END IF;

      -- -------------------------------------------------
      -- Delete rows from ONT_DBI_CHANGE_LOG base on rowid
      -- -------------------------------------------------

 BIS_COLLECTION_UTILITIES.put_line('Deleting rows from OM log table');
 FII_UTIL.Start_Timer;


  DELETE FROM ONT_DBI_CHANGE_LOG
   WHERE rowid IN (select log_rowid from isc_dbi_change_log)
     AND last_update_date < g_incre_start_date;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Deleted ' || sql%rowcount || ' rows from OM log table in');
 COMMIT;


  IF (WRAPUP = -1) THEN
     RAISE l_failure;
  END IF;

 IF (g_warning = 1) then
   retcode := '1';
 END IF;




 EXCEPTION

  WHEN L_FAILURE THEN
    ROLLBACK;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line(g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    g_row_count,
    g_errbuf,
    ISC_DBI_BOOK_SUM2_F_C.g_push_from_date,
    ISC_DBI_BOOK_SUM2_F_C.g_push_to_date
    );

  WHEN OTHERS THEN
    ROLLBACK;
    g_errbuf := sqlerrm ||' - '||sqlcode;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line('Other errors : '|| g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    g_row_count,
    g_errbuf,
    ISC_DBI_BOOK_SUM2_F_C.g_push_from_date,
    ISC_DBI_BOOK_SUM2_F_C.g_push_to_date
    );

END update_fact;

      -- ------------------------------------
      -- Sales Credits INITIAL collection
      -- ------------------------------------

Procedure load_sales_fact(errbuf	IN OUT NOCOPY VARCHAR2,
                     	  retcode	IN OUT NOCOPY VARCHAR2) IS

l_isc_schema            VARCHAR2(30);
l_status                VARCHAR2(30);
l_industry              VARCHAR2(30);
l_stmt                  VARCHAR2(32000);
l_failure		EXCEPTION;

BEGIN

 BIS_COLLECTION_UTILITIES.put_line(' ');

  IF (NOT BIS_COLLECTION_UTILITIES.setup('ISC_SALES_CREDITS_F')) THEN
     RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || errbuf);
     return;
  END IF;


 BIS_COLLECTION_UTILITIES.put_line('Truncating the sales fact table');
 FII_UTIL.Start_Timer;

  IF (truncate_table('ISC_SALES_CREDITS_F') = -1) THEN
     RAISE l_failure;
  END IF;

 FII_UTIL.Stop_Timer;
 FII_UTIL.Print_Timer('Truncated the sales fact table in');


/* Insert into ISC_SALES_CREDITS_F */
 BIS_COLLECTION_UTILITIES.put_line(' ');
 BIS_COLLECTION_UTILITIES.put_line('Inserting data into sales fact table');
 FII_UTIL.Start_Timer;

insert /*+ append parallel(f) */ into isc_sales_credits_f f
with s as (
select /*+ ordered use_hash(sc) parallel(sc) parallel(sr)
	   pq_distribute(sr,hash,hash) */
       sc.sales_credit_id, sc.percent, sc.sales_credit_type_id,
       sc.salesrep_id, sc.header_id, sc.line_id, sr.resource_id,
       sr.org_id, sc.sales_group_id group_id, sc.created_by, sc.creation_date,
       sc.last_updated_by, sc.last_update_date, sc.last_update_login
  from oe_sales_credit_types	sc_typ,
       oe_sales_credits 	sc,
       jtf_rs_salesreps 	sr
 where sc.sales_group_id is not null
   and sc.salesrep_id = sr.salesrep_id
   and sc.sales_credit_type_id = sc_typ.sales_credit_type_id
   and sc_typ.quota_flag = 'Y'
 union all
select /*+ ordered use_hash(sc) parallel(sc) parallel(sg)
	   pq_distribute(sg,hash,hash) */
       sc.sales_credit_id, sc.percent, sc.sales_credit_type_id,
       sc.salesrep_id, sc.header_id, sc.line_id, sg.resource_id,
       sg.org_id, sg.group_id, sc.created_by, sc.creation_date,
       sc.last_updated_by, sc.last_update_date, sc.last_update_login
  from oe_sales_credit_types sc_typ,
       oe_sales_credits sc,
       jtf_rs_srp_groups sg
 where sc.sales_group_id is null
   and sc.salesrep_id = sg.salesrep_id
   and sc.last_update_date between sg.start_date and sg.end_date
   and sc.sales_credit_type_id = sc_typ.sales_credit_type_id
   and sc_typ.quota_flag = 'Y')
select pk, sales_credit_id, resource_id, group_id, header_id, line_id,
       percent, sales_credit_type_id, created_by, creation_date,
       last_updated_by, last_update_date, last_update_login
  from (
select pk, sales_credit_id, resource_id, group_id, header_id, line_id,
       percent, sales_credit_type_id, created_by, creation_date,
       last_updated_by, last_update_date, last_update_login,
       rank() over (partition by line_id order by rnk) low_rnk
  from (
select /*+ parallel(s) */
       'DIRECT-'||s.sales_credit_id pk, s.sales_credit_id, s.group_id,
       t5.header_id, t5.line_id, 1 rnk, s.resource_id, s.percent,
       s.sales_credit_type_id, s.created_by, s.creation_date,
       s.last_updated_by, s.last_update_date, s.last_update_login
  from isc_book_sum2_f t5, s
 where s.line_id = t5.line_id
   and s.org_id = t5.org_ou_id
 union all
select /*+ parallel(s) parallel(t7a) use_hash(s) pq_distribute(s,hash,hash) */
       'SERVICE_PARENT-'||t7a.line_id||'-'||s.sales_credit_id pk,
       s.sales_credit_id, s.group_id, t7a.header_id, t7a.line_id, 2 rnk,
       s.resource_id, s.percent, s.sales_credit_type_id, s.created_by,
       s.creation_date, s.last_updated_by, s.last_update_date,
       s.last_update_login
  from isc_book_sum2_f t7a, s
 where s.line_id = t7a.service_parent_line_id
   and s.org_id = t7a.org_ou_id
   and t7a.item_type_code = 'SERVICE'
 union all
select /*+ parallel(s) parallel(t7b2) use_hash(s) pq_distribute(s,hash,hash)
           parallel(t7b1) use_hash(t7b1) pq_distribute(t7b1,hash,hash) */
       'SERVICE_PARENT_TOPMODEL-'||t7b2.line_id||'-'||s.sales_credit_id pk,
       s.sales_credit_id, s.group_id, t7b2.header_id, t7b2.line_id, 3 rnk,
       s.resource_id, s.percent, s.sales_credit_type_id, s.created_by,
       s.creation_date, s.last_updated_by, s.last_update_date,
       s.last_update_login
  from isc_book_sum2_f t7b2, isc_book_sum2_f t7b1, s
 where s.line_id = t7b1.top_model_line_id
   and s.org_id = t7b1.org_ou_id
   and t7b1.line_id = t7b2.service_parent_line_id
   and t7b2.item_type_code = 'SERVICE'
 union all
select /*+ ordered parallel(s) parallel(t7b1) use_hash(s) pq_distribute(s,hash,hash) */
       'TOPMODEL-'||t7b1.line_id||'-'||s.sales_credit_id pk,
       s.sales_credit_id, s.group_id, t7b1.header_id, t7b1.line_id, 4 rnk,
       s.resource_id, s.percent, s.sales_credit_type_id, s.created_by,
       s.creation_date, s.last_updated_by, s.last_update_date,
       s.last_update_login
  from isc_book_sum2_f t7b1, s
 where s.line_id = t7b1.top_model_line_id
   and s.org_id = t7b1.org_ou_id
 union all
select /*+ ordered parallel(s) parallel(t11) use_hash(s) pq_distribute(s,hash,hash) */
       'HEADER-'||t11.line_id||'-'||s.sales_credit_id pk,
       s.sales_credit_id, s.group_id, t11.header_id, t11.line_id, 5 rnk,
       s.resource_id, s.percent, s.sales_credit_type_id, s.created_by,
       s.creation_date, s.last_updated_by, s.last_update_date,
       s.last_update_login
  from isc_book_sum2_f t11, s
 where s.line_id is null
   and s.org_id = t11.org_ou_id
   and s.header_id = t11.header_id))
 where low_rnk = 1;

 FII_UTIL.Stop_Timer;
 g_row_count := sql%rowcount;
 FII_UTIL.Print_Timer('Inserted '||g_row_count||' rows into the sales fact table in');
 COMMIT;

      -- ----------------------------------------------
      -- No exception raised so far.  Successful.  Call
      -- Wrapup to commit and insert messages into logs
      -- ----------------------------------------------

  BIS_COLLECTION_UTILITIES.WRAPUP(
  TRUE,
  g_row_count,
  NULL,
  NULL,
  NULL
  );

EXCEPTION

  WHEN L_FAILURE THEN
    ROLLBACK;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line(g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    g_row_count,
    g_errbuf,
    NULL,
    NULL
    );

  WHEN OTHERS THEN
    ROLLBACK;
    g_errbuf := sqlerrm ||' - '||sqlcode;
    BIS_COLLECTION_UTILITIES.put_line(' ');
    BIS_COLLECTION_UTILITIES.put_line('Other errors : '|| g_errbuf);
    retcode := -1;
    errbuf := g_errbuf;

    BIS_COLLECTION_UTILITIES.WRAPUP(
    FALSE,
    g_row_count,
    g_errbuf,
    NULL,
    NULL
    );

END load_sales_fact;

Procedure update_sales_fact_dummy(errbuf	IN OUT NOCOPY VARCHAR2,
                     	  retcode	IN OUT NOCOPY VARCHAR2) IS
BEGIN
  null;
END update_sales_fact_dummy;

END ISC_DBI_BOOK_SUM2_F_C;


/
