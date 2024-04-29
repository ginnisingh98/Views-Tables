--------------------------------------------------------
--  DDL for Package Body ISC_EDW_BACKLOGS_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_EDW_BACKLOGS_F_C" AS
/* $Header: ISCSCF1B.pls 115.17 2004/03/30 14:37:20 adwajan ship $ */

  g_row_count         	NUMBER	:= 0;
  g_rows_collected      NUMBER	:= 0;
  g_miss_conv		NUMBER	:= 0;
  g_seq_id_line		NUMBER	:= -1;

  g_push_from_date	DATE	:= NULL;
  g_push_to_date	DATE	:= NULL;

  g_errbuf		VARCHAR2(2000)	:= NULL;
 g_all_or_nothing_flag	VARCHAR2(5)	:= 'Y';


      -- -------------
      -- PUSH_TO_LOCAL
      -- -------------

 FUNCTION Push_To_Local(p_seq_id IN NUMBER) RETURN NUMBER IS

 BEGIN

  INSERT INTO ISC_EDW_BACKLOGS_FSTG(
	 BACKLOGS_PK,
	 BASE_UOM_FK,
	 BILL_BKLG_COST_G,
	 BILL_BKLG_COST_T,
	 BILL_BKLG_MRG_G,
	 BILL_BKLG_MRG_T,
	 BILL_BKLG_REV_G,
	 BILL_BKLG_REV_T,
	 BILL_TO_CUST_FK,
	 BILL_TO_LOCATION_FK,
	 CUSTOMER_FK,
	 DATE_BALANCE_FK,
	 DEMAND_CLASS_FK,
	 DLQT_BKLG_COST_G,
	 DLQT_BKLG_COST_T,
	 DLQT_BKLG_MRG_G,
	 DLQT_BKLG_MRG_T,
	 DLQT_BKLG_REV_G,
	 DLQT_BKLG_REV_T,
	 GL_BOOK_FK,
	 INSTANCE,
	 INSTANCE_FK,
	 INV_ORG_FK,
	 ITEM_ORG_FK,
	 LAST_UPDATE_DATE,
	 OPERATING_UNIT_FK,
	 ORDER_CATEGORY_FK,
	 ORDER_SOURCE_FK,
	 ORDER_TYPE_FK,
	 QTY_BILL_BKLG_B,
	 QTY_DLQT_BKLG_B,
	 QTY_SHIP_BKLG_B,
	 QTY_UNBILL_SHIP_B,
	 SALES_CHANNEL_FK,
	 SALES_PERSON_FK,
	 SHIP_BKLG_COST_G,
	 SHIP_BKLG_COST_T,
	 SHIP_BKLG_MRG_G,
	 SHIP_BKLG_MRG_T,
	 SHIP_BKLG_REV_G,
	 SHIP_BKLG_REV_T,
	 SHIP_TO_CUST_FK,
	 SHIP_TO_LOCATION_FK,
	 TASK_FK,
	 TOP_MODEL_ITEM_FK,
	 TRX_CURRENCY_FK,
	 UNBILL_SHIP_COST_G,
	 UNBILL_SHIP_COST_T,
	 UNBILL_SHIP_MRG_G,
	 UNBILL_SHIP_MRG_T,
	 UNBILL_SHIP_REV_G,
	 UNBILL_SHIP_REV_T,
	 USER_ATTRIBUTE1,
	 USER_ATTRIBUTE2,
	 USER_ATTRIBUTE3,
	 USER_ATTRIBUTE4,
	 USER_ATTRIBUTE5,
	 USER_ATTRIBUTE6,
	 USER_ATTRIBUTE7,
	 USER_ATTRIBUTE8,
	 USER_ATTRIBUTE9,
	 USER_ATTRIBUTE10,
	 USER_ATTRIBUTE11,
	 USER_ATTRIBUTE12,
	 USER_ATTRIBUTE13,
	 USER_ATTRIBUTE14,
	 USER_ATTRIBUTE15,
	 USER_ATTRIBUTE16,
	 USER_ATTRIBUTE17,
	 USER_ATTRIBUTE18,
	 USER_ATTRIBUTE19,
	 USER_ATTRIBUTE20,
	 USER_ATTRIBUTE21,
	 USER_ATTRIBUTE22,
	 USER_ATTRIBUTE23,
	 USER_ATTRIBUTE24,
	 USER_ATTRIBUTE25,
	 USER_FK1,
	 USER_FK2,
	 USER_FK3,
	 USER_FK4,
	 USER_FK5,
	 USER_MEASURE1,
	 USER_MEASURE2,
	 USER_MEASURE3,
	 USER_MEASURE4,
	 USER_MEASURE5,
	 OPERATION_CODE,
	 COLLECTION_STATUS)
  SELECT BACKLOGS_PK,
	 BASE_UOM_FK,
	 BILL_BKLG_COST_G,
	 BILL_BKLG_COST_T,
	 BILL_BKLG_MRG_G,
	 BILL_BKLG_MRG_T,
	 BILL_BKLG_REV_G,
	 BILL_BKLG_REV_T,
	 BILL_TO_CUST_FK,
	 BILL_TO_LOCATION_FK,
	 CUSTOMER_FK,
	 DATE_BALANCE_FK,
	 DEMAND_CLASS_FK,
	 DLQT_BKLG_COST_G,
	 DLQT_BKLG_COST_T,
	 DLQT_BKLG_MRG_G,
	 DLQT_BKLG_MRG_T,
	 DLQT_BKLG_REV_G,
	 DLQT_BKLG_REV_T,
	 GL_BOOK_FK,
	 INSTANCE,
	 INSTANCE_FK,
	 INV_ORG_FK,
	 ITEM_ORG_FK,
	 LAST_UPDATE_DATE,
	 OPERATING_UNIT_FK,
	 ORDER_CATEGORY_FK,
	 ORDER_SOURCE_FK,
	 ORDER_TYPE_FK,
	 QTY_BILL_BKLG_B,
	 QTY_DLQT_BKLG_B,
	 QTY_SHIP_BKLG_B,
	 QTY_UNBILL_SHIP_B,
	 SALES_CHANNEL_FK,
	 SALES_PERSON_FK,
	 SHIP_BKLG_COST_G,
	 SHIP_BKLG_COST_T,
	 SHIP_BKLG_MRG_G,
	 SHIP_BKLG_MRG_T,
	 SHIP_BKLG_REV_G,
	 SHIP_BKLG_REV_T,
	 SHIP_TO_CUST_FK,
	 SHIP_TO_LOCATION_FK,
	 TASK_FK,
	 TOP_MODEL_ITEM_FK,
	 TRX_CURRENCY_FK,
	 UNBILL_SHIP_COST_G,
	 UNBILL_SHIP_COST_T,
	 UNBILL_SHIP_MRG_G,
	 UNBILL_SHIP_MRG_T,
	 UNBILL_SHIP_REV_G,
	 UNBILL_SHIP_REV_T,
	 USER_ATTRIBUTE1,
	 USER_ATTRIBUTE2,
	 USER_ATTRIBUTE3,
	 USER_ATTRIBUTE4,
	 USER_ATTRIBUTE5,
	 USER_ATTRIBUTE6,
	 USER_ATTRIBUTE7,
	 USER_ATTRIBUTE8,
	 USER_ATTRIBUTE9,
	 USER_ATTRIBUTE10,
	 USER_ATTRIBUTE11,
	 USER_ATTRIBUTE12,
	 USER_ATTRIBUTE13,
	 USER_ATTRIBUTE14,
	 USER_ATTRIBUTE15,
	 USER_ATTRIBUTE16,
	 USER_ATTRIBUTE17,
	 USER_ATTRIBUTE18,
	 USER_ATTRIBUTE19,
	 USER_ATTRIBUTE20,
	 USER_ATTRIBUTE21,
	 USER_ATTRIBUTE22,
	 USER_ATTRIBUTE23,
	 USER_ATTRIBUTE24,
	 USER_ATTRIBUTE25,
	 nvl(USER_FK1,'NA_EDW'),
	 nvl(USER_FK2,'NA_EDW'),
	 nvl(USER_FK3,'NA_EDW'),
	 nvl(USER_FK4,'NA_EDW'),
	 nvl(USER_FK5,'NA_EDW'),
	 USER_MEASURE1,
	 USER_MEASURE2,
	 USER_MEASURE3,
	 USER_MEASURE4,
	 USER_MEASURE5,
	 NULL, -- OPERATION_CODE
	 'LOCAL READY'
    FROM ISC_EDW_BACKLOGS_F_FCV
   WHERE seq_id = p_seq_id;

  RETURN(sql%rowcount);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function Push_To_Local : '||sqlerrm;
    RETURN(-1);
END;


      -- ---------------
      -- IDENTIFY_CHANGE
      -- ---------------

FUNCTION Identify_Change( p_seq_id	IN  NUMBER,
                          p_count	OUT NOCOPY NUMBER) RETURN NUMBER IS

  l_seq_id	       NUMBER := -1;

BEGIN

  p_count := 0;
  SELECT isc_tmp_back_s.nextval
    INTO l_seq_id
    FROM dual;

   --  --------------------------------------------
   --  Populate rowid into isc_tmp_back table based
   --  on last update date
   --  --------------------------------------------

  INSERT INTO isc_tmp_back(
	 SEQ_ID,
	 PK1)
  SELECT /*+ PARALLEL(h) */
	 l_seq_id,
	 to_char(l.line_id)
    FROM oe_order_headers_all h,
	 oe_order_lines_all l
   WHERE h.last_update_date BETWEEN g_push_from_date AND g_push_to_date
     AND l.header_id = h.header_id
     AND nvl(l.ordered_quantity,0) > 0
     AND nvl(l.source_document_type_id,0) <> 10
     AND l.line_category_code =  ('ORDER')
   UNION
  SELECT /*+ PARALLEL(l) */
	 l_seq_id,
	 to_char(l.line_id)
    FROM oe_order_lines_all l
   WHERE l.last_update_date BETWEEN g_push_from_date AND g_push_to_date
     AND nvl(l.ordered_quantity,0) > 0
     AND nvl(l.source_document_type_id,0) <> 10
     AND l.line_category_code =  ('ORDER');

  p_count := sql%rowcount;

  UPDATE ISC_TMP_BACK
     SET seq_id = l_seq_id
   WHERE seq_id = -10
     AND pk1 NOT IN ( SELECT pk1
			FROM ISC_TMP_BACK
		       WHERE seq_id = l_seq_id) ;

  p_count := p_count + sql%rowcount;

  DELETE ISC_TMP_BACK
   WHERE seq_id = -10;

  RETURN(l_seq_id);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function Identify_Change : '||sqlerrm;
  RETURN(-1);

END;


      -- ---------------------
      -- IDENTIFY_MISSING_RATE
      -- ---------------------

FUNCTION Identify_Missing_Rate( p_count OUT NOCOPY NUMBER) RETURN NUMBER IS

BEGIN

  p_count := 0;

  INSERT INTO ISC_EDW_BACK_MISSING_RATE(
	 ID,
	 PK1,
	 PK2,
	 CURR_CONV_DATE,
	 FROM_CURRENCY,
	 TO_CURRENCY,
	 RATE_TYPE,
	 FROM_UOM_CODE,
	 TO_UOM_CODE,
	 INVENTORY_ITEM_ID,
	 ITEM_NAME,
	 STATUS)
  SELECT /* Reports Transaction to Base Conversion Currency Issue*/
	 g_seq_id_line				ID,
	 ftp.pk1					PK1,
	 ''					PK2,
	 decode( upper(h.conversion_type_code), 'USER',
		 h.conversion_rate_date,
		 h.booked_date)			CURR_CONV_DATE,
	 h.transactional_curr_code		FROM_CURRENCY,
	 gl.currency_code			TO_CURRENCY,
	 nvl(h.conversion_type_code,
	      edw_param.rate_type)		RATE_TYPE,
	 ''					FROM_UOM_CODE,
	 ''					TO_UOM_CODE,
	 ''					INVENTORY_ITEM_ID,
	 ''					ITEM_NAME,
	 decode( decode( upper(h.conversion_type_code), 'USER',
			 h.conversion_rate,
			 decode( h.transactional_curr_code, gl.currency_code,
				 1,
				 GL_CURRENCY_API.get_rate_sql(
					 h.transactional_curr_code,
					 gl.currency_code,
					 h.booked_date,
					 nvl(h.conversion_type_code, edw_param.rate_type)))),
		 -1,'RATE NOT AVAILABLE',
		 -2,'INVALID CURRENCY')		STATUS
    FROM EDW_LOCAL_INSTANCE			inst,
	 EDW_LOCAL_SYSTEM_PARAMETERS		edw_param,
  	 ISC_TMP_BACK				ftp,
  	 OE_ORDER_LINES_ALL			l,
  	 OE_ORDER_HEADERS_ALL			h,
  	 FINANCIALS_SYSTEM_PARAMS_ALL		fspa,
  	 GL_SETS_OF_BOOKS			gl
   WHERE ftp.pk1 = l.line_id
     AND ftp.seq_id = g_seq_id_line
     AND l.org_id = fspa.org_id
     AND l.header_id = h.header_id
     AND fspa.set_of_books_id = gl.set_of_books_id
     AND h.booked_flag = 'Y'
     AND h.booked_date IS NOT NULL
     AND decode( upper(h.conversion_type_code), 'USER',
		 h.conversion_rate,
		 decode( h.transactional_curr_code, gl.currency_code,
			 1,
			 GL_CURRENCY_API.get_rate_sql(
				 h.transactional_curr_code,
				 gl.currency_code,
				 h.booked_date,
				 nvl(h.conversion_type_code, edw_param.rate_type)))) < 0
   UNION
  SELECT /* Reports Base to Global Conversion Currency Issue */
	 g_seq_id_line				ID,
	 ftp.pk1				PK1,
	 ''					PK2,
	 decode( upper(h.conversion_type_code), 'USER',
		 h.conversion_rate_date,
		 h.booked_date)			CURR_CONV_DATE,
	 gl.currency_code			FROM_CURRENCY,
	 edw_param.warehouse_currency_code	TO_CURRENCY,
 	 nvl(h.conversion_type_code,
	     edw_param.rate_type)		RATE_TYPE,
	 ''					FROM_UOM_CODE,
	 ''					TO_UOM_CODE,
	 ''					INVENTORY_ITEM_ID,
	 ''					ITEM_NAME,
	 decode( EDW_CURRENCY.Get_Rate (gl.currency_code,h.booked_date),
		 -1,'RATE NOT AVAILABLE',
		 -2,'INVALID CURRENCY')		STATUS
    FROM EDW_LOCAL_INSTANCE			inst,
	 EDW_LOCAL_SYSTEM_PARAMETERS		edw_param,
	 ISC_TMP_BACK				ftp,
	 OE_ORDER_LINES_ALL			l,
	 OE_ORDER_HEADERS_ALL			h,
	 FINANCIALS_SYSTEM_PARAMS_ALL		fspa,
	 GL_SETS_OF_BOOKS			gl
   WHERE ftp.pk1 = l.line_id
     AND ftp.seq_id = g_seq_id_line
     AND l.org_id = fspa.org_id
     AND l.header_id = h.header_id
     AND fspa.set_of_books_id = gl.set_of_books_id
     AND h.booked_flag = 'Y'
     AND h.booked_date IS NOT NULL
     AND EDW_CURRENCY.Get_Rate (gl.currency_code,h.booked_date) < 0
   UNION
  SELECT /* Reports Base to Transaction Conversion Currency Issue */
	 g_seq_id_line				ID,
	 ftp.pk1					PK1,
	 ''					PK2,
	 decode( upper(h.conversion_type_code), 'USER',
		 h.conversion_rate_date,
		 h.booked_date)			CURR_CONV_DATE,
	 gl.currency_code			FROM_CURRENCY,
	 h.transactional_curr_code		TO_CURRENCY,
 	 nvl(h.conversion_type_code,
	     edw_param.rate_type)		RATE_TYPE,
	 ''					FROM_UOM_CODE,
	 ''					TO_UOM_CODE,
	 ''					INVENTORY_ITEM_ID,
	 ''					ITEM_NAME,
	 decode( decode( upper(h.conversion_type_code),'USER',
			 1/ h.conversion_rate,
			 decode( h.transactional_curr_code, gl.currency_code,
				 1,
				 GL_CURRENCY_API.get_rate_sql (
					     gl.currency_code,
					     h.transactional_curr_code,
					     h.booked_date,
 					     nvl(h.conversion_type_code, edw_param.rate_type)))),
		 -1,'RATE NOT AVAILABLE',
		 -2,'INVALID CURRENCY')		STATUS
    FROM EDW_LOCAL_INSTANCE			inst,
	 EDW_LOCAL_SYSTEM_PARAMETERS		edw_param,
	 ISC_TMP_BACK				ftp,
	 OE_ORDER_LINES_ALL			l,
	 OE_ORDER_HEADERS_ALL			h,
	 FINANCIALS_SYSTEM_PARAMS_ALL		fspa,
	 GL_SETS_OF_BOOKS			gl
   WHERE ftp.pk1 = l.line_id
     AND ftp.seq_id = g_seq_id_line
     AND l.org_id = fspa.org_id
     AND l.header_id = h.header_id
     AND fspa.set_of_books_id = gl.set_of_books_id
     AND h.booked_flag = 'Y'
     AND h.booked_date IS NOT NULL
     AND decode( upper(h.conversion_type_code),'USER',
 		 1/ h.conversion_rate,
 		 decode( h.transactional_curr_code, gl.currency_code,
 			 1,
 			 GL_CURRENCY_API.get_rate_sql (
 				gl.currency_code,
 				h.transactional_curr_code,
 				h.booked_date,
 				nvl(h.conversion_type_code, edw_param.rate_type)))) < 0
  UNION
  SELECT -- Reports "Ship from Org Base" to "Header Org Base" Conversion Currency Issue
	 g_seq_id_line				ID,
	 ftp.pk1				PK1,
  	 ''					PK2,
  	 h.booked_date				CURR_CONV_DATE,
  	 gl_cost.currency_code			FROM_CURRENCY,
  	 gl.currency_code			TO_CURRENCY,
	 edw_param.rate_type			RATE_TYPE,
	 ''					FROM_UOM_CODE,
	 ''					TO_UOM_CODE,
	 ''					INVENTORY_ITEM_ID,
	 ''					ITEM_NAME,
  	 decode(GL_CURRENCY_API.get_rate_sql (
 			     gl_cost.currency_code,
 			     gl.currency_code,
 			     h.booked_date,
 			     edw_param.rate_type),
 		 -1,'RATE NOT AVAILABLE',
 		 -2,'INVALID CURRENCY')		STATUS
    FROM EDW_LOCAL_SYSTEM_PARAMETERS		edw_param,
	 ISC_TMP_PK				ftp,
	 OE_ORDER_LINES_ALL			l,
	 OE_ORDER_HEADERS_ALL			h,
	 FINANCIALS_SYSTEM_PARAMS_ALL		fspa,
	 GL_SETS_OF_BOOKS			gl,
	 GL_SETS_OF_BOOKS			gl_cost,
	 HR_ORGANIZATION_INFORMATION		hoi
   WHERE ftp.pk1 = l.line_id
     AND ftp.seq_id = g_seq_id_line
     AND l.org_id = fspa.org_id
     AND l.header_id = h.header_id
     AND fspa.set_of_books_id = gl.set_of_books_id
     AND h.booked_flag = 'Y'
     AND h.booked_date IS NOT NULL
     AND l.ship_from_org_id = hoi.organization_id -- if ship_from_org_id is null, don't include row in the missing rates
     AND hoi.org_information_context = 'Accounting Information'
     AND hoi.org_information1 = to_char(gl_cost.set_of_books_id)
     AND GL_CURRENCY_API.get_rate_sql (
		gl_cost.currency_code,
		gl.currency_code,
		h.booked_date,
		edw_param.rate_type) < 0;

  p_count := sql%rowcount;

  INSERT INTO ISC_EDW_BACK_MISSING_RATE(
	 ID,
	 PK1,
	 PK2,
	 CURR_CONV_DATE,
	 FROM_CURRENCY,
	 TO_CURRENCY,
	 RATE_TYPE,
	 FROM_UOM_CODE,
	 TO_UOM_CODE,
	 INVENTORY_ITEM_ID,
	 ITEM_NAME,
	 STATUS)
  SELECT /* Reports UOM Conversion Issue */
	 g_seq_id_line				ID,
	 ftp.pk1					PK1,
	 ''					PK2,
	 to_date(NULL)				CURR_CONV_DATE,
	 ''					FROM_CURRENCY,
	 ''					TO_CURRENCY,
 	 ''					RATE_TYPE,
	 l.order_quantity_uom			FROM_UOM_CODE,
	 EDW_UTIL.Get_Edw_Base_Uom(
		l.order_quantity_uom,
		l.inventory_item_id)		TO_UOM_CODE,
	 l.inventory_item_id			INVENTORY_ITEM_ID,
	 nvl(mtl.segment1,'Item number unavailable')
	   ||' : '||nvl(description,'Description unavailable')
						ITEM_NAME,
	 'UOM ISSUE'				STATUS
    FROM EDW_LOCAL_INSTANCE			inst,
	 ISC_TMP_BACK				ftp,
	 OE_ORDER_LINES_ALL			l,
	 OE_ORDER_HEADERS_ALL			h,
	 MTL_SYSTEM_ITEMS_B			mtl
   WHERE ftp.pk1 = l.line_id
     AND ftp.seq_id = g_seq_id_line
     AND l.header_id = h.header_id
     AND h.booked_flag = 'Y'
     AND h.booked_date IS NOT NULL
     AND l.ship_from_org_id = mtl.organization_id
     AND l.inventory_item_id = mtl.inventory_item_id
     AND EDW_UTIL.Get_Uom_Conv_Rate(l.order_quantity_uom,l.inventory_item_id) IS NULL;

  p_count := p_count + sql%rowcount;

  RETURN(p_count);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function Identify_Missing_Rate : '||sqlerrm;
    RETURN(-1);
END;


      -- -------------------
      -- INSERT_ISC_TMP_BACK
      -- -------------------

FUNCTION Insert_Isc_Tmp_Back RETURN NUMBER IS

BEGIN

  INSERT INTO ISC_TMP_BACK (
	 seq_id,
	 pk1)
  SELECT -10 , ftp.pk1
    FROM ISC_EDW_BACK_MISSING_RATE conv,
         ISC_TMP_BACK ftp
   WHERE conv.pk1 = ftp.pk1
     AND ftp.seq_id = g_seq_id_line
     AND conv.id = g_seq_id_line ;

  RETURN(sql%rowcount);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function Insert_Tmp_Back : '||sqlerrm;
    RETURN(-1);
END;


      -- -------------------
      -- DELETE_ISC_TMP_BACK
      -- -------------------

FUNCTION Delete_Isc_Tmp_Back RETURN NUMBER IS

BEGIN

  DELETE FROM ISC_TMP_BACK
  	WHERE pk1 IN ( SELECT pk1
		         FROM ISC_EDW_BACK_MISSING_RATE
		        WHERE id = g_seq_id_line )
	  AND seq_id >0 ;

  RETURN(sql%rowcount);

EXCEPTION
  WHEN OTHERS THEN
    g_errbuf  := 'Error in Function Delete_Isc_Tmp_Back : '||sqlerrm;
    RETURN(-1);
END;


      -- -----------------
      -- PUBLIC PROCEDURES
      -- -----------------

      -- --------------
      -- PROCEDURE PUSH
      -- --------------

Procedure Push(	Errbuf		IN out NOCOPY VARCHAR2,
                Retcode		IN out NOCOPY VARCHAR2,
                p_from_date	IN	VARCHAR2,
                p_to_date	IN	VARCHAR2,
		p_coll_flag	IN	VARCHAR2) IS  -- 'Yes' = All or Nothing , 'No' = Collect >0 rows only

  l_fact_name		VARCHAR2(30)	:= 'ISC_EDW_BACKLOGS_F'  ;

  l_from_date		DATE		:= NULL;
  l_to_date	   	DATE		:= NULL;

  l_row_count		NUMBER		:= 0;

  l_failure		EXCEPTION;

  CURSOR Missing_Currency_Conversion IS
  SELECT DISTINCT trunc(curr_conv_date) curr_conv_date,
	 from_currency,
 	 to_currency,
	 rate_type,
 	 status
    FROM ISC_EDW_BACK_MISSING_RATE
   WHERE status NOT IN ('UOM ISSUE')
   ORDER BY status,from_currency,trunc(curr_conv_date);

  CURSOR Missing_UOM_Conversion IS
  SELECT DISTINCT from_uom_code,
	 to_uom_code,
	 inventory_item_id item_id,
	 substr(item_name,0,50) item_name
    FROM ISC_EDW_BACK_MISSING_RATE
   WHERE status = 'UOM ISSUE'
   ORDER BY item_name,from_uom_code;


      -- -------------------------------------------
      -- Put any additional developer variables here
      -- -------------------------------------------

BEGIN

  errbuf  := NULL;
  retcode := '0';

  l_from_date := to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS');
  l_to_date   := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');

  g_all_or_nothing_flag := upper(p_coll_flag);

  IF (Not EDW_COLLECTION_UTIL.Setup(l_fact_name))
    THEN
      g_errbuf := 'Error in function Setup : '||fnd_message.get;
      RAISE l_failure;
  END IF;

  ISC_EDW_BACKLOGS_F_C.G_Push_From_Date := nvl(l_from_date,
  	EDW_COLLECTION_UTIL.G_Local_Last_Push_Start_Date - EDW_COLLECTION_UTIL.G_Offset);
  ISC_EDW_BACKLOGS_F_C.G_Push_To_Date := nvl(l_to_date,EDW_COLLECTION_UTIL.G_Local_Curr_Push_Start_Date);

  EDW_LOG.Put_Line( 'The collection range is from '||
        to_char(g_push_from_date,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(g_push_to_date,'MM/DD/YYYY HH24:MI:SS'));
  EDW_LOG.Put_Line(' ');

      -- ---------------
      -- Identify Change
      -- ---------------

  EDW_LOG.Put_Line('Identifying changed Backlog lines');

FII_UTIL.Start_Timer;

  g_seq_id_line := IDENTIFY_CHANGE(-1,l_row_count);

FII_UTIL.Stop_Timer;

  IF (g_seq_id_line = -1)
    THEN RAISE l_failure;
  END IF;

FII_UTIL.Print_Timer('Identified '||l_row_count||' changed records in');


      -- ----------------------------------------------------------
      -- Identify Missing Rate into ISC_EDW_BACK_MISSING_RATE table
      -- ----------------------------------------------------------

  EDW_LOG.Put_Line(' ');
  EDW_LOG.Put_Line('Identifying the missing conversion rates (currency and UoM)');

FII_UTIL.Start_Timer;

  g_miss_conv := Identify_Missing_Rate(l_row_count);

FII_UTIL.Stop_Timer;

  IF (g_miss_conv = -1)
    THEN RAISE l_failure;
  END IF;

  FII_UTIL.Print_Timer('Inserted '||g_miss_conv||' rows into the ISC_EDW_BACK_MISSING_RATE table in ');
  EDW_LOG.Put_Line(' ');


      -- ----------------------------------------------------------------------
      -- Inserting into ISC_TMP_BACK rows having missing rate (with seq_id < 0)
      -- ----------------------------------------------------------------------

  EDW_LOG.Put_Line(' ');
  EDW_LOG.Put_Line('Inserting into ISC_TMP_BACK with < 0 seq_id the rows having missing conversion rates (currency and UoM)');

FII_UTIL.Start_Timer;

  g_row_count := Insert_Isc_Tmp_Back;

FII_UTIL.Stop_Timer;

  IF (g_row_count = -1)
    THEN RAISE l_failure;
  END IF;

  FII_UTIL.Print_Timer('Inserted '||g_row_count||' rows into the ISC_TMP_BACK table in ');
  EDW_LOG.Put_Line(' ');


      -- ----------------------------------------------
      -- Deleting ISC_TMP_BACK rows having missing rate
      -- ----------------------------------------------

  EDW_LOG.Put_Line(' ');
  EDW_LOG.Put_Line('Deleting the ISC_TMP_BACK rows having a missing conversion rates before collecting (currency and UoM)');

FII_UTIL.Start_Timer;

  g_row_count := Delete_Isc_Tmp_Back ;

FII_UTIL.Stop_Timer;

  IF (g_row_count = -1)
    THEN RAISE l_failure;
  END IF;

  FII_UTIL.Print_Timer('Deleted '||g_row_count||' rows from the ISC_TMP_BACK table in ');
  EDW_LOG.Put_Line(' ');


  IF NOT ((g_all_or_nothing_flag = 'Y') and (g_miss_conv > 0))  -- collect except when this condition applies
    THEN
      BEGIN -- IF NOT ((g_all_or_nothing_flag = 'Y') and (g_miss_conv > 0))

      -- ---------------------------
      -- Push to Local staging table
      -- ---------------------------

      EDW_LOG.Put_Line(' ');
      EDW_LOG.Put_Line('Pushing data to local staging');

      EDW_LOG.Put_Line( 'The collection range is from '||
        to_char(g_push_from_date,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(g_push_to_date,'MM/DD/YYYY HH24:MI:SS'));

FII_UTIL.Start_Timer;

      g_rows_collected := Push_To_Local(g_seq_id_line);

FII_UTIL.Stop_Timer;

      IF (g_rows_collected = -1)
	THEN RAISE l_failure;
      END IF;

      FII_UTIL.Print_Timer('Inserted '||g_rows_collected||' rows into the local staging table in ');
      EDW_LOG.Put_Line(' ');

      END;
  END IF; -- IF NOT ((g_all_or_nothing_flag = 'Y') and (g_miss_conv > 0))


      -- -------------------
      -- Delete ISC_TMP_BACK
      -- -------------------

  DELETE FROM isc_tmp_back
	WHERE seq_id = g_seq_id_line;


      -- -------------------------------------------
      -- Reporting of the missing currencies and UoM
      -- -------------------------------------------

  IF g_miss_conv > 0
    THEN
      BEGIN  -- begin IF g_miss_conv > 0

	IF g_all_or_nothing_flag = 'N' -- We collected and report missing conversions
	  THEN
	    retcode := 1;
	    EDW_LOG.Put_Line(' ');
	    EDW_LOG.Put_Line('Collection finished with a CONVERSION RATE WARNING.');
	    EDW_LOG.Put_Line(' ');
	ELSIF g_all_or_nothing_flag = 'Y'  -- We did not collect and report missing conversions
	  THEN
	    retcode := -1;
	    EDW_LOG.Put_Line(' ');
	    EDW_LOG.Put_Line('Collection finished with a CONVERSION RATE ERROR.');
	    EDW_LOG.Put_Line('Collection aborted because there are missing conversion rates.');
	    EDW_LOG.Put_Line(' ');
        END IF; --g_all_or_nothing_flag = 'N'

        EDW_LOG.Put_Line('Below is the list of the missing conversions.');
        EDW_LOG.Put_Line('Enter the missing currency rates in Oracle General Ledger.');
        EDW_LOG.Put_Line('To fix the missing UOM please refer to the EDW implementation guide - UOM Setup');
        EDW_LOG.Put_Line(' ');

        EDW_LOG.Put_Line('+---------------------------------------------------------------------------+');
        EDW_LOG.Put_Line('		REPORT FOR THE MISSING CURRENCY CONVERSION RATES');
        EDW_LOG.Put_Line('');
        EDW_LOG.Put_Line('CONV. DATE - FROM CURR. - TO CURR. - CONV. TYPE CODE - STATUS');
        EDW_LOG.Put_Line('---------- - ---------- - -------- - --------------- - ----------------------');

        l_row_count := 0;

        FOR line IN Missing_Currency_Conversion
  	LOOP
	  l_row_count := l_row_count + 1;
	  EDW_LOG.Put_Line( RPAD(line.curr_conv_date,10,' ')
		||' - '||RPAD(line.from_currency,10,' ')
    		||' - '||RPAD(line.to_currency,8,' ')
    		||' - '||RPAD(line.rate_type,15)
    		||' - '||RPAD(line.status,20));
	END LOOP;

	IF l_row_count = 0
	  THEN
	    EDW_LOG.Put_Line('');
	    EDW_LOG.Put_Line('           THERE IS NO MISSING CURRENCY CONVERSION RATE        ');
	    EDW_LOG.Put_Line('');
	END IF;

	EDW_LOG.Put_Line('+---------------------------------------------------------------------------+');
	EDW_LOG.Put_Line('');
	EDW_LOG.Put_Line('');
	EDW_LOG.Put_Line('');
	EDW_LOG.Put_Line('+---------------------------------------------------------------------------+');
	EDW_LOG.Put_Line('		REPORT FOR THE MISSING UNIT OF MEASURE CONVERSION RATES');
	EDW_LOG.Put_Line('');
	EDW_LOG.Put_Line('FROM UOM - TO UOM   - ITEM_ID  - ITEM NUMBER : ITEM DESCRIPTION');
	EDW_LOG.Put_Line('-------- - -------- - -------- - --------------------------------------------');

	l_row_count := 0;

	FOR line IN Missing_UOM_Conversion
	  LOOP
	    l_row_count := l_row_count + 1;
	    EDW_LOG.Put_Line( RPAD(line.from_uom_code,8,' ')
		||' - '||RPAD(line.to_uom_code,8,' ')
		||' - '||RPAD(line.item_id,8,' ')
		||' - '||RPAD(line.item_name,42));
	END LOOP;

	IF l_row_count = 0
	  THEN
	    EDW_LOG.Put_Line('');
	    EDW_LOG.Put_Line('           THERE IS NO MISSING UOM CONVERSION RATE        ');
	    EDW_LOG.Put_Line('');
	END IF;

	EDW_LOG.Put_Line('+---------------------------------------------------------------------------+');

      END; -- begin IF g_miss_conv > 0
  END IF; -- IF g_miss_conv > 0



      -- ------------------------------------------------------
      -- We are cleaning the table containing the missing rates
      -- ------------------------------------------------------


  DELETE FROM ISC_EDW_BACK_MISSING_RATE
	WHERE id = g_seq_id_line;

      -- ----------------------------------------------
      -- No exception raised so far.  Successful.  Call
      -- wrapup to commit and insert messages into logs
      -- ----------------------------------------------

  EDW_LOG.Put_Line(' ');
  EDW_LOG.Put_Line('Inserted '||g_rows_collected||' rows into the local staging table');
  EDW_LOG.Put_Line(' ');
  EDW_LOG.Put_Line('+---------------------------------------------------------------------------+');
  EDW_LOG.Put_Line(' ');
  EDW_LOG.Put_Line('Start of the Wrapup section ');
  EDW_LOG.Put_Line(' ');

  IF retcode = -1
    THEN
      EDW_COLLECTION_UTIL.Wrapup(
	FALSE,
	g_rows_collected,
	NULL,
	ISC_EDW_BACKLOGS_F_C.G_Push_From_Date,
	ISC_EDW_BACKLOGS_F_C.G_Push_To_Date);
    ELSE
      EDW_COLLECTION_UTIL.Wrapup(
	TRUE,
	g_rows_collected,
	NULL,
	ISC_EDW_BACKLOGS_F_C.G_Push_From_Date,
	ISC_EDW_BACKLOGS_F_C.G_Push_To_Date);
  END IF;

  COMMIT;

       -- --------------------------------------------------
       -- END OF Collection , Developer Customizable Section
       -- --------------------------------------------------

EXCEPTION

  WHEN L_FAILURE THEN
    ROLLBACK;
    EDW_LOG.Put_Line(g_errbuf);
    retcode := -1;
    EDW_COLLECTION_UTIL.Wrapup(
	FALSE,
	g_rows_collected,
	NULL,
	ISC_EDW_BACKLOGS_F_C.G_Push_From_Date,
	ISC_EDW_BACKLOGS_F_C.G_Push_To_Date);

  WHEN OTHERS THEN
    ROLLBACK;
    g_errbuf := sqlerrm ||' - '|| sqlcode;
    EDW_LOG.Put_Line('Other errors : '|| g_errbuf);
    retcode := -1;
    EDW_COLLECTION_UTIL.Wrapup(
	FALSE,
	g_rows_collected,
	NULL,
	ISC_EDW_BACKLOGS_F_C.G_Push_From_Date,
	ISC_EDW_BACKLOGS_F_C.G_Push_To_Date);

END;
END ISC_EDW_BACKLOGS_F_C;

/
