--------------------------------------------------------
--  DDL for Package Body FII_AR_TRX_DIST_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_TRX_DIST_F_C" AS
/* $Header: FIIAR06B.pls 120.8 2006/01/18 11:32:42 sgautam noship $ */

 g_debug_flag 		VARCHAR2(1) := NVL(FND_PROFILE.value('EDW_DEBUG'), 'N');
 g_errbuf		VARCHAR2(2000) := NULL;
 g_retcode		VARCHAR2(200) := NULL;
 g_row_count         	NUMBER:=0;
 g_push_from_date	DATE := NULL;
 g_push_to_date		DATE := NULL;
 g_seq_id               NUMBER:=0;
 g_missing_rates      Number:=0;
 g_acct_or_inv_date NUMBER;      -- Added for for Currency Conversion Date Enhancement
 G_TABLE_NOT_EXIST      EXCEPTION;
 PRAGMA EXCEPTION_INIT(G_TABLE_NOT_EXIST, -942);

-- ---------------------------------
-- PRIVATE PROCEDURES AND FUNCTIONS
-- ---------------------------------

---------------------------------------------------
-- PROCEDURE DROP_TABLE
---------------------------------------------------
procedure drop_table (p_table_name in varchar2) is
  l_stmt varchar2(400);
Begin

  l_stmt:='drop table '|| p_table_name;

  if g_debug_flag = 'Y' then
  	edw_log.put_line('');
  	edw_log.put_line('Dropping temp table '||p_table_name);
  	edw_log.debug_line('Going to execute statement:');
  	edw_log.debug_line(l_stmt);
  end if;

  execute immediate l_stmt;

Exception
  WHEN G_TABLE_NOT_EXIST THEN
    null;      -- Oracle 942, table does not exist, no actions
  WHEN OTHERS THEN
    g_errbuf:=sqlerrm;
    g_retcode:=sqlcode;
    if g_debug_flag = 'Y' then
    	edw_log.put_line('Error in drop_table procedure');
    end if;
    raise;
End;


------------------------------------------------------------
--PROCEDURE INSERT_INTO_MISSING_RATES
-------------------------------------------------------------
--Identify records that have missing rates and insert them in a temp table

PROCEDURE INSERT_INTO_MISSING_RATES
IS

 BEGIN
   INSERT INTO fii_ar_trx_msng_rt(
               Primary_Key1,
               Primary_Key2,
	       Primary_Key3  -- SLA Uptake
	       )
   SELECT
              TO_NUMBER(decode(substr(INVOICE_PK,1,2), 'D-',INVOICE_DIST_ID,
                                                       'OD',INVOICE_DIST_ID,
                                                       'OC',INVOICE_DIST_ID,
                                                       'R-',INVOICE_DIST_ID, NULL)),
	      TO_NUMBER(decode(substr(INVOICE_PK,1,2), 'A-',INVOICE_ID, NULL)),
	      fat.account_id  -- SLA Uptake

   FROM  FII_AR_TRX_DIST_FSTG fat

   WHERE
              fat.COLLECTION_STATUS in ('RATE NOT AVAILABLE', 'INVALID CURRENCY');

   IF (sql%rowcount > 0) THEN
        g_retcode := 1;
        g_missing_rates := 1;
   END IF;
-- Generates "Warning" message in the Status column of Concurrent Manager "Requests" table

      if g_debug_flag = 'Y' then
      	edw_log.put_line(' ');
      	edw_log.put_line('INSERTING ' || to_char(sql%rowcount) || ' rows into fii_ar_trx_msng_rt temp table');
      	edw_log.put_line('g_retcode is '||g_retcode);
      	edw_log.put_line('g_missing_rates is '||g_missing_rates);
      end if;
 END;

---------------------------------------------------
-- PROCEDURE CREATE_ITEM_ORG_TEMP
---------------------------------------------------
procedure create_item_org_temp(table_name IN VARCHAR2) is
  l_stmt varchar2(15000);
  l_stage varchar2(30);

begin

  drop_table(table_name);

  -- --------------------------------------------------------
  -- Had to remove the parallel sub clause to avoid ora 7260
  -- --------------------------------------------------------
  l_stage:='Creating ';

  l_stmt:= 'create table '|| table_name ||' storage (initial 5M next 1M pctincrease 0)
            parallel (degree 4) '||
           'as select rev.item_fk INVENTORY_ITEM_ID, ' ||
           '          NULL ORDER_LINE_ID, ' ||
           '          DECODE(mi.inventory_item_id, NULL, ''NA_EDW'', ' ||
           '             mi.inventory_item_id || ''-'' || to_char(max(mi.organization_id)) || ' ||
           '          ''-'' || rev.instance || ''-IORG'') ITEM_FK, ' ||
           '          NULL UOM_FK ' ||
           'FROM FII_AR_TRX_DIST_Fstg rev, mtl_system_items_b mi ' ||
           'WHERE to_number(rev.item_fk) = mi.inventory_item_id (+) ' ||
           'AND rev.item_fk not like ''%-%'' ' ||
           'AND rev.item_fk <> ''NA_EDW'' ' ||
           'GROUP BY rev.item_fk, mi.inventory_item_id, rev.instance ' ||
           'UNION ' ||
           'SELECT NULL INVENTORY_ITEM_ID, ' ||
           '       to_char(ood.line_id) ORDER_LINE_ID, ' ||
           '       decode(msi.inventory_item_id, NULL, ''NA_EDW'', ' ||
           '         msi.inventory_item_id||''-''||iwm.mtl_organization_id||''-''|| ' ||
           '       rev.instance||''-IORG'') ITEM_FK, ' ||
           '       edw_util.get_edw_base_uom(msi.primary_uom_code, ' ||
           '         msi.inventory_item_id) UOM_FK ' ||
           'FROM FII_AR_TRX_DIST_Fstg rev, op_ordr_dtl ood, ic_whse_mst iwm, ' ||
           '     ic_item_mst iim, mtl_system_items msi ' ||
           'WHERE rev.interface_line_context = ''GEMMS OP'' ' ||
           'AND rev.item_fk like ''OPM-%'' ' ||
           'AND substr(rev.order_line_id,1,instr(rev.order_line_id,''-'',1)-1)= ' ||
           'to_char(ood.line_id) ' ||
           'AND ood.item_id = iim.item_id ' ||
           'AND ood.from_whse = iwm.whse_code ' ||
           'AND iim.item_no = msi.segment1 ' ||
           'AND iwm.mtl_organization_id = msi.organization_id';

  if g_debug_flag = 'Y' then
  	edw_log.put_line('');
  	edw_log.put_line('Creating temp table '||table_name);
  	edw_log.debug_line('Going to execute statement:');
  	edw_log.debug_line(l_stmt);
  end if;

  execute immediate l_stmt;
  commit;

  l_stage:='Creating index for ';
  l_stmt:='Create index ' || table_name || '_u' || ' on ' || table_name ||
          '(inventory_item_id)';

  if g_debug_flag = 'Y' then
  	edw_log.put_line('');
  	edw_log.put_line('Creating index ' || table_name || '_u');
  	edw_log.debug_line('Going to execute statement: ');
  	edw_log.debug_line(l_stmt);
  end if;
  execute immediate l_stmt;
  if g_debug_flag = 'Y' then
  	edw_log.debug_line('Create index ' || table_name || '_u successfully');
  end if;

  l_stage:='Creating index for ';
  l_stmt:='Create index ' || table_name || '_u2' || ' on ' || table_name ||
          '(order_line_id)';

  if g_debug_flag = 'Y' then
  	edw_log.put_line('');
  	edw_log.put_line('Creating index ' || table_name || '_u2');
  	edw_log.debug_line('Going to execute statement: ');
  	edw_log.debug_line(l_stmt);
  end if;
  execute immediate l_stmt;
  if g_debug_flag = 'Y' then
  	edw_log.debug_line('Create index ' || table_name || '_u2 successfully');
  end if;

  commit;

exception
   when others then
     if g_debug_flag = 'Y' then
     	edw_log.put_line('error: '|| l_stage || table_name ||' table.');
     	edw_log.put_line('Dropping table ' || table_name);
     end if;
     drop_table(table_name);
     commit;
     raise;
end;

---------------------------------------------------
-- PROCEDURE UPDATE_ITEM_FK
---------------------------------------------------
FUNCTION update_item_fk RETURN NUMBER is
  l_stmt 	VARCHAR2(6000);
  l_row         NUMBER;
  l_table_name  VARCHAR2(40) := 'FII_AR_DL_TEMP_TABLE';
Begin

  create_item_org_temp(l_table_name);
  if g_debug_flag = 'Y' then
  	edw_log.debug_line('Ready to Update Item FK' );
  end if;
  l_stmt:=  'UPDATE FII_AR_TRX_DIST_FSTG rev ' ||
            'SET (rev.uom_fk, rev.item_fk, rev.parent_item_fk) = ' ||
            '    (SELECT DECODE(rev.interface_line_context, ''GEMMS OP'', ' ||
            '                   NVL(temp.uom_fk, ''NA_EDW''), rev.uom_fk) UOM_FK, ' ||
            'NVL(temp.item_fk, ''NA_EDW'') ITEM_FK, ' ||
            'NVL(temp.item_fk, ''NA_EDW'') PARENT_ITEM_FK ' ||
            'FROM ' || l_table_name || ' temp ' ||
            'WHERE (temp.inventory_item_id = rev.item_fk ' ||
            'OR (substr(rev.order_line_id,1,instr(rev.order_line_id,''-'',1)-1)= ' ||
            '    temp.order_line_id ' ||
            '    AND rev.interface_line_context = ''GEMMS OP''))) ' ||
            'WHERE rev.item_fk <> ''NA_EDW'' ' ||
            'AND   rev.collection_status = ''LOCAL READY'' ' ||
            'AND   INSTANCE = (SELECT INSTANCE_CODE FROM EDW_LOCAL_INSTANCE) ' ||
            'AND   rev.item_fk NOT LIKE ''%-IORG'' ';


  if g_debug_flag = 'Y' then
  	edw_log.put_line('');
  	edw_log.put_line('Updating item_fk');
  	edw_log.debug_line('Going to execute statement: ');
  	edw_log.debug_line(l_stmt);
  end if;

  execute immediate l_stmt;
  l_row := SQL%ROWCOUNT;

  drop_table(l_table_name);

  return(l_row);

exception
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     drop_table(l_table_name);
     return(-1);
end;

---------------------------------------------------
-- FUNCTION WAIT_FOR_REQUEST
---------------------------------------------------

 FUNCTION WAIT_FOR_REQUEST(p_request_id      	IN  	NUMBER,
			   p_dev_phase		OUT	NOCOPY VARCHAR2,
			   p_dev_status 	OUT	NOCOPY VARCHAR2
				) RETURN BOOLEAN
 IS

 l_phase	VARCHAR2(30);
 l_status 	VARCHAR2(30);
 l_message	VARCHAR2(30);

 BEGIN

       RETURN FND_CONCURRENT.WAIT_FOR_REQUEST
                              ( p_request_id,
                                10,
                                3600 * 10,  -- 10 hour, need to change later
                                l_phase,
                                l_status,
                                p_dev_phase,
                                p_dev_status,
                                l_message);


 END;


---------------------------------------------------
-- FUNCTION SUBMIT_REQUEST
---------------------------------------------------

 FUNCTION SUBMIT_REQUEST(p_view_type VARCHAR2,
                         p_req_id    NUMBER) RETURN NUMBER
 IS

   l_request_id NUMBER;

 BEGIN

   l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                          'FII',
                          'FII_AR_TRX_DIST_F_WORKER',
                          NULL,
                          NULL,
                          FALSE,         -- sub request,may need to set true
                          to_char(g_push_from_date,'YYYY/MM/DD HH24:MI:SS'),
                          to_char(g_push_to_date,'YYYY/MM/DD HH24:MI:SS'),
			  p_view_type,
                          to_char(p_req_id));

   IF (l_request_id = 0) THEN
      g_errbuf:=sqlerrm;
      g_retcode:=sqlcode;
      RETURN (-1);  -- request failed
   END IF;

   RETURN l_request_id;

 END SUBMIT_REQUEST;


-----------------------------------------------------------
--  PROCEDURE TRUNCATE_TABLE
-----------------------------------------------------------

 PROCEDURE TRUNCATE_TABLE (table_name varchar2)
 IS

  l_fii_schema          VARCHAR2(30);
  l_stmt  		VARCHAR2(200);
  l_status		VARCHAR2(30);
  l_industry		VARCHAR2(30);

 BEGIN

      IF (FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, l_fii_schema)) THEN
      l_stmt := 'TRUNCATE TABLE ' || l_fii_schema ||'.'||table_name;
      EXECUTE IMMEDIATE l_stmt;
      END IF;
      if g_debug_flag = 'Y' then
      	edw_log.put_line(' ');
      	edw_log.put_line('Truncating '|| table_name||' table');
      end if;

 END;


-----------------------------------------------------------
--  PROCEDURE DELETE_STG
-----------------------------------------------------------

 PROCEDURE DELETE_STG
 IS

 BEGIN

   DELETE FII_AR_TRX_DIST_FSTG
   WHERE  COLLECTION_STATUS = 'LOCAL READY' OR (COLLECTION_STATUS = 'RATE NOT AVAILABLE' OR COLLECTION_STATUS = 'INVALID CURRENCY')
   AND    INSTANCE = (SELECT INSTANCE_CODE
                     FROM   EDW_LOCAL_INSTANCE);

 END;

--------------------------------------------------
--FUNCTION LOCAL_SAME_AS_REMOTE
---------------------------------------------------

 FUNCTION LOCAL_SAME_AS_REMOTE RETURN BOOLEAN
 IS

 l_instance1                Varchar2(100) :=Null;
 l_instance2                Varchar2(100) :=Null;

 BEGIN


   SELECT instance_code
   INTO   l_instance1
   FROM   edw_local_instance;

   SELECT instance_code
   INTO   l_instance2
   FROM   edw_local_instance@edw_apps_to_wh;

   IF (l_instance1 = l_instance2) THEN
      RETURN TRUE;
   END IF;

   RETURN FALSE;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN

     RETURN FALSE;

 END;


--------------------------------------------------
--PROCEDURE SET_STATUS_READY
---------------------------------------------------

 FUNCTION SET_STATUS_READY RETURN NUMBER
 IS

 BEGIN

   UPDATE FII_AR_TRX_DIST_FSTG
   SET    COLLECTION_STATUS = 'READY'
   WHERE  COLLECTION_STATUS = 'LOCAL READY'
   AND    INSTANCE = (SELECT INSTANCE_CODE
                     FROM   EDW_LOCAL_INSTANCE);

   RETURN(sql%rowcount);

 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     RETURN(-1);

 END;


-----------------------------------------------------------
--PROCEDURE PUSH_TO_LOCAL
-----------------------------------------------------------

 FUNCTION PUSH_TO_LOCAL(p_view_type VARCHAR2) RETURN NUMBER IS
 l_mau                   NUMBER;


 BEGIN

  l_mau := nvl(edw_currency.get_mau, 0.01 );

   -- ------------------------------------------------
   -- We set the COLLECTION_STATUS to 'LOCAL READY'.
   -- In case of source=target, we need to separate
   -- out the records in progress vs the records which
   -- is ready to be picked up by collection enginee.
   -- In our case, we consider the records to be in
   -- progress until all the child processes have
   -- completed successfully.
   -- ------------------------------------------------

   Insert Into FII_AR_TRX_DIST_FSTG(
     ACCOUNT_ID,
     ACCOUNT_CLASS,
     ACCOUNT_TYPE,
     AGREEMENT_NAME,
     AGREEMENT_TYPE,
     AMT_B,
     AMT_G,
     AMT_T,
     BILL_TO_CUSTOMER_FK,
     BILL_TO_SITE_FK,
     CAMPAIGN_ACTL_FK,
     CAMPAIGN_INIT_FK,
     CAMPAIGN_STATUS_ACTL_FK,
     CAMPAIGN_STATUS_INIT_FK,
     CELL_ACTL_FK,
     CELL_INIT_FK,
     COMPANY_CC_ORG_FK,
     END_USER_CUSTOMER_FK,
     EVENT_OFFER_ACTL_FK,
     EVENT_OFFER_INIT_FK,
     EVENT_OFFER_REG_FK,
     EXCHANGE_DATE,
     EXCHANGE_RATE,
     EXCHANGE_RATE_TYPE,
     FUNCTIONAL_CURRENCY_FK,
     GL_ACCT1_FK,
     GL_ACCT2_FK,
     GL_ACCT3_FK,
     GL_ACCT4_FK,
     GL_ACCT5_FK,
     GL_ACCT6_FK,
     GL_ACCT7_FK,
     GL_ACCT8_FK,
     GL_ACCT9_FK,
     GL_ACCT10_FK,
     GL_DATE,
     GL_DATE_FK,
     INSTANCE,
     INSTANCE_FK,
     INTERFACE_LINE_CONTEXT,
     INTERNAL_FLAG,
     INVOICE_DATE,
     INVOICE_DATE_FK,
     INVOICE_DIST_ID,
     INVOICE_ID,
     INVOICE_LINE_ID,
     INVOICE_LINE_NUMBER,
     INVOICE_LINE_MEMO,
     INVOICE_NUMBER,
     INVOICE_REASON,
     INVOICE_SOURCE_NAME,
     ITEM_FK,
     QTY_CREDITED,
     INVOICE_LINE_QTY,
     ORDER_LINE_QTY,
     LINE_TYPE,
     MARKET_SEGMENT_FK,
     MEDIA_ACTL_FK,
     MEDIA_INIT_FK,
     OFFER_ACTL_FK,
     OFFER_INIT_FK,
     ORDER_LINE_ID,
     ORGANIZATION_FK,
     ORIGINAL_INVOICE_ID,
     ORIGINAL_INVOICE_LINE_ID,
     ORIGINAL_INVOICE_NUM,
     ORIGINAL_INVOICE_LINE_NUM,
     PARENT_ITEM_FK,
     PAYMENT_TERM_FK,
prim_salesrep_fk,
PRIM_SALESRESOURCE_FK,
     PROCESS_TYPE,
     PROJECT_FK,
     RESELLER_CUSTOMER_FK,
     INVOICE_PK,
     SALES_ORDER_DATE_FK,
     SALES_ORDER_LINE_NUMBER,
     SALES_ORDER_NUMBER,
     SALES_ORDER_SOURCE,
     SALESCHANNEL_FK,
salesrep_fk,
SALESRESOURCE_FK,
     SET_OF_BOOKS_FK,
     SHIP_TO_CUSTOMER_FK,
     SHIP_TO_SITE_FK,
     SIC_CODE_FK,
     SO_LINE_SELLING_PRICE,
     SOLD_TO_CUSTOMER_FK,
     SOLD_TO_SITE_FK,
     SOURCE_LIST_FK,
     TRANSACTION_CURRENCY_FK,
     UNIT_SELLING_PRICE,
     UOM_FK,
     GL_POSTED_DATE,
     TRANSACTION_STATUS,
     TRANSACTION_CLASS,
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
     CREATION_DATE,
     LAST_UPDATE_DATE,
     OPERATION_CODE,
     COLLECTION_STATUS)
   SELECT
     ACCOUNT_ID,
     ACCOUNT_CLASS,
     ACCOUNT_TYPE,
     AGREEMENT_NAME,
     AGREEMENT_TYPE,
     AMT_B,
    round(( AMT_B * GLOBAL_CURRENCY_RATE)/l_mau) * l_mau,
     AMT_T,
     BILL_TO_CUSTOMER_FK,
     BILL_TO_SITE_FK,
     CAMPAIGN_ACTL_FK,
     CAMPAIGN_INIT_FK,
     CAMPAIGN_STATUS_ACTL_FK,
     CAMPAIGN_STATUS_INIT_FK,
     CELL_ACTL_FK,
     CELL_INIT_FK,
     'NA_EDW', -- COMPANY_CC_ORG_FK,
     END_USER_CUSTOMER_FK,
     EVENT_OFFER_ACTL_FK,
     EVENT_OFFER_INIT_FK,
     EVENT_OFFER_REG_FK,
     EXCHANGE_DATE,
     EXCHANGE_RATE,
     EXCHANGE_RATE_TYPE,
     FUNCTIONAL_CURRENCY_FK,
     GL_ACCT1_FK,
     GL_ACCT2_FK,
     GL_ACCT3_FK,
     GL_ACCT4_FK,
     GL_ACCT5_FK,
     GL_ACCT6_FK,
     GL_ACCT7_FK,
     GL_ACCT8_FK,
     GL_ACCT9_FK,
     GL_ACCT10_FK,
     GL_DATE,
     GL_DATE_FK,
     INSTANCE,
     INSTANCE_FK,
     INTERFACE_LINE_CONTEXT,
     INTERNAL_FLAG,
     INVOICE_DATE,
     INVOICE_DATE_FK,
     INVOICE_DIST_ID,
     INVOICE_ID,
     INVOICE_LINE_ID,
     INVOICE_LINE_NUMBER,
     INVOICE_LINE_MEMO,
     INVOICE_NUMBER,
     INVOICE_REASON,
     INVOICE_SOURCE_NAME,
     ITEM_FK,
     QTY_CREDITED_NC * UOM_CONV_RATE,
     INVOICE_LINE_QTY_NC * UOM_CONV_RATE,
     ORDER_LINE_QTY_NC * UOM_CONV_RATE,
     LINE_TYPE,
     MARKET_SEGMENT_FK,
     MEDIA_ACTL_FK,
     MEDIA_INIT_FK,
     OFFER_ACTL_FK,
     OFFER_INIT_FK,
     ORDER_LINE_ID,
     ORGANIZATION_FK,
     ORIGINAL_INVOICE_ID,
     ORIGINAL_INVOICE_LINE_ID,
     ORIGINAL_INVOICE_NUM,
     ORIGINAL_INVOICE_LINE_NUM,
     PARENT_ITEM_FK,
     PAYMENT_TERM_FK,
prim_salesresource_fk, -- 'NA_EDW',
'NA_EDW',              -- PRIM_SALESRESOURCE_FK,
     PROCESS_TYPE,
     PROJECT_FK,
     RESELLER_CUSTOMER_FK,
     INVOICE_PK,
     SALES_ORDER_DATE_FK,
     SALES_ORDER_LINE_NUMBER,
     SALES_ORDER_NUMBER,
     SALES_ORDER_SOURCE,
     SALESCHANNEL_FK,
salesresource_fk, -- 'NA_EDW',
'NA_EDW',         -- SALESRESOURCE_FK,
     SET_OF_BOOKS_FK,
     SHIP_TO_CUSTOMER_FK,
     SHIP_TO_SITE_FK,
     SIC_CODE_FK,
     SO_LINE_SELLING_PRICE,
     SOLD_TO_CUSTOMER_FK,
     SOLD_TO_SITE_FK,
     SOURCE_LIST_FK,
     TRANSACTION_CURRENCY_FK,
     UNIT_SELLING_PRICE,
     UOM_FK,
     GL_POSTED_DATE,
     TRANSACTION_STATUS,
     TRANSACTION_CLASS,
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
     sysdate,
     sysdate,
     NULL,          -- OPERATION_CODE
     decode(invoice_id,'NO_INV_ID','INVOICE_ID UNAVAILABLE',
          decode(invoice_line_id,'NO_INV_LIN_ID','INVOICE_LINE_ID UNAVAILABLE',
          decode(original_invoice_id,'NO_OR_INV_ID','ORIGINAL_INVOICE_ID UNAVAILABLE',
          decode(original_invoice_line_id,'NO_OR_INV_LIN_ID','ORIGINAL_INVOICE_LINE_ID UNAVAILABLE',
         decode(GLOBAL_CURRENCY_RATE,-1,'RATE NOT AVAILABLE',
                 -2,'INVALID CURRENCY','LOCAL READY')))))
   FROM FII_AR_TRX_DIST_FCV
   WHERE view_type = p_view_type
   AND   seq_id    = g_seq_id;

   RETURN(sql%rowcount);

 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     RETURN(-1);

 END;


-----------------------------------------------------------
--  FUNCTION PUSH_REMOTE
-----------------------------------------------------------
 FUNCTION PUSH_REMOTE RETURN NUMBER
 IS

  BEGIN

      INSERT INTO FII_AR_TRX_DIST_FSTG@EDW_APPS_TO_WH(
        ACCOUNT_ID,
        ACCOUNT_CLASS,
        ACCOUNT_TYPE,
        AGREEMENT_NAME,
        AGREEMENT_TYPE,
        AMT_B,
        AMT_G,
        AMT_T,
        BILL_TO_CUSTOMER_FK,
        BILL_TO_SITE_FK,
        CAMPAIGN_ACTL_FK,
        CAMPAIGN_INIT_FK,
        CAMPAIGN_STATUS_ACTL_FK,
        CAMPAIGN_STATUS_INIT_FK,
        CELL_ACTL_FK,
        CELL_INIT_FK,
        COMPANY_CC_ORG_FK,
        END_USER_CUSTOMER_FK,
        EVENT_OFFER_ACTL_FK,
        EVENT_OFFER_INIT_FK,
        EVENT_OFFER_REG_FK,
        EXCHANGE_DATE,
        EXCHANGE_RATE,
        EXCHANGE_RATE_TYPE,
        FUNCTIONAL_CURRENCY_FK,
        GL_ACCT1_FK,
        GL_ACCT2_FK,
        GL_ACCT3_FK,
        GL_ACCT4_FK,
        GL_ACCT5_FK,
        GL_ACCT6_FK,
        GL_ACCT7_FK,
        GL_ACCT8_FK,
        GL_ACCT9_FK,
        GL_ACCT10_FK,
        GL_DATE,
        GL_DATE_FK,
        INSTANCE,
        INSTANCE_FK,
        INTERFACE_LINE_CONTEXT,
        INTERNAL_FLAG,
        INVOICE_DATE,
        INVOICE_DATE_FK,
        INVOICE_DIST_ID,
        INVOICE_ID,
        INVOICE_LINE_ID,
        INVOICE_LINE_NUMBER,
        INVOICE_LINE_MEMO,
        INVOICE_NUMBER,
        INVOICE_REASON,
        INVOICE_SOURCE_NAME,
        ITEM_FK,
        QTY_CREDITED,
        INVOICE_LINE_QTY,
        ORDER_LINE_QTY,
        LINE_TYPE,
        MARKET_SEGMENT_FK,
        MEDIA_ACTL_FK,
        MEDIA_INIT_FK,
        OFFER_ACTL_FK,
        OFFER_INIT_FK,
        ORDER_LINE_ID,
        ORGANIZATION_FK,
        ORIGINAL_INVOICE_ID,
        ORIGINAL_INVOICE_LINE_ID,
        ORIGINAL_INVOICE_NUM,
        ORIGINAL_INVOICE_LINE_NUM,
        PARENT_ITEM_FK,
        PAYMENT_TERM_FK,
prim_salesrep_fk,
PRIM_SALESRESOURCE_FK,
        PROCESS_TYPE,
        PROJECT_FK,
        RESELLER_CUSTOMER_FK,
        INVOICE_PK,
        SALES_ORDER_DATE_FK,
        SALES_ORDER_LINE_NUMBER,
        SALES_ORDER_NUMBER,
        SALES_ORDER_SOURCE,
        SALESCHANNEL_FK,
salesrep_fk,
SALESRESOURCE_FK,
        SET_OF_BOOKS_FK,
        SHIP_TO_CUSTOMER_FK,
        SHIP_TO_SITE_FK,
        SIC_CODE_FK,
        SO_LINE_SELLING_PRICE,
        SOLD_TO_CUSTOMER_FK,
        SOLD_TO_SITE_FK,
        SOURCE_LIST_FK,
        TRANSACTION_CURRENCY_FK,
        UNIT_SELLING_PRICE,
        UOM_FK,
        GL_POSTED_DATE,
        TRANSACTION_STATUS,
        TRANSACTION_CLASS,
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
        CREATION_DATE,
        LAST_UPDATE_DATE,
        OPERATION_CODE,
        COLLECTION_STATUS)
      SELECT
        ACCOUNT_ID,
        substrb(ACCOUNT_CLASS,1,3),
        substrb(ACCOUNT_TYPE,1,4),
        substrb(AGREEMENT_NAME,1,30),
        substrb(AGREEMENT_TYPE,1,30),
        AMT_B,
        AMT_G,
        AMT_T,
        BILL_TO_CUSTOMER_FK,
        BILL_TO_SITE_FK,
        CAMPAIGN_ACTL_FK,
        CAMPAIGN_INIT_FK,
        CAMPAIGN_STATUS_ACTL_FK,
        CAMPAIGN_STATUS_INIT_FK,
        CELL_ACTL_FK,
        CELL_INIT_FK,
        COMPANY_CC_ORG_FK,
        END_USER_CUSTOMER_FK,
        EVENT_OFFER_ACTL_FK,
        EVENT_OFFER_INIT_FK,
        EVENT_OFFER_REG_FK,
        EXCHANGE_DATE,
        EXCHANGE_RATE,
        substrb(EXCHANGE_RATE_TYPE,1,30),
        FUNCTIONAL_CURRENCY_FK,
        GL_ACCT1_FK,
        GL_ACCT2_FK,
        GL_ACCT3_FK,
        GL_ACCT4_FK,
        GL_ACCT5_FK,
        GL_ACCT6_FK,
        GL_ACCT7_FK,
        GL_ACCT8_FK,
        GL_ACCT9_FK,
        GL_ACCT10_FK,
        GL_DATE,
        GL_DATE_FK,
        substrb(INSTANCE,1,40),
        INSTANCE_FK,
        substrb(INTERFACE_LINE_CONTEXT,1,30),
        substrb(INTERNAL_FLAG,1,3),
        INVOICE_DATE,
        INVOICE_DATE_FK,
        substrb(INVOICE_DIST_ID,1,25),
        substrb(INVOICE_ID,1,25),
        substrb(INVOICE_LINE_ID,1,25),
        substrb(INVOICE_LINE_NUMBER,1,10),
        substrb(INVOICE_LINE_MEMO,1,15),
        substrb(INVOICE_NUMBER,1,30),
        substrb(INVOICE_REASON,1,30),
        substrb(INVOICE_SOURCE_NAME,1,50),
        ITEM_FK,
        QTY_CREDITED,
        INVOICE_LINE_QTY,
        ORDER_LINE_QTY,
        substrb(LINE_TYPE,1,3),
        MARKET_SEGMENT_FK,
        MEDIA_ACTL_FK,
        MEDIA_INIT_FK,
        OFFER_ACTL_FK,
        OFFER_INIT_FK,
        substrb(ORDER_LINE_ID,1,50),
        ORGANIZATION_FK,
        substrb(ORIGINAL_INVOICE_ID,1,15),
        substrb(ORIGINAL_INVOICE_LINE_ID,1,25),
        substrb(ORIGINAL_INVOICE_NUM,1,30),
        substrb(ORIGINAL_INVOICE_LINE_NUM,1,10),
        PARENT_ITEM_FK,
        PAYMENT_TERM_FK,
        prim_salesrep_fk,
        PRIM_SALESRESOURCE_FK,
        substrb(PROCESS_TYPE,1,1),
        PROJECT_FK,
        RESELLER_CUSTOMER_FK,
        substrb(INVOICE_PK,1,120),
        SALES_ORDER_DATE_FK,
        substrb(SALES_ORDER_LINE_NUMBER,1,30),
        substrb(SALES_ORDER_NUMBER,1,30),
        substrb(SALES_ORDER_SOURCE,1,50),
        SALESCHANNEL_FK,
        salesrep_fk,
        SALESRESOURCE_FK,
        SET_OF_BOOKS_FK,
        SHIP_TO_CUSTOMER_FK,
        SHIP_TO_SITE_FK,
        SIC_CODE_FK,
        SO_LINE_SELLING_PRICE,
        SOLD_TO_CUSTOMER_FK,
        SOLD_TO_SITE_FK,
        SOURCE_LIST_FK,
        TRANSACTION_CURRENCY_FK,
        UNIT_SELLING_PRICE,
        UOM_FK,
        GL_POSTED_DATE,
        substrb(TRANSACTION_STATUS,1,1),
        substrb(TRANSACTION_CLASS,1,3),
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
        sysdate,
        sysdate,
        substrb(OPERATION_CODE,1,30),
	'READY'
     FROM FII_AR_TRX_DIST_FSTG
    WHERE collection_status = 'LOCAL READY';
--ensures that only the records with collection status of local ready
--will be pushed to remote fstg

     RETURN(sql%rowcount);

 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     RETURN(-1);

 END;

---------------------------------------------------
-- FUNCTION IDENTIFY_CHANGE
---------------------------------------------------

 FUNCTION IDENTIFY_CHANGE(p_mode            IN  VARCHAR2,
                          p_count           OUT NOCOPY NUMBER,
			  p_parent_seq_id   IN  NUMBER DEFAULT -1) RETURN NUMBER
 IS

 l_seq_id	           NUMBER := -1;
 l_fii_schema          VARCHAR2(30);
 l_status              VARCHAR2(30);
 l_industry            VARCHAR2(30);

 BEGIN

   p_count := 0;
   select fii_tmp_pk_s.nextval into l_seq_id from dual;

   --  --------------------------------------------
   --  Populate rowid into fii_tmp_pk table based
   --  on last update date
   --  --------------------------------------------
   IF    (p_mode = 'AR INVL') THEN

     --  -----------------------------------------
     --  For ra_customer_trx_lines_all
     --  -----------------------------------------
     Insert into fii_tmp_pk(
             SEQ_ID,
             primary_key1,
             primary_key_char5)
     select  /*+ PARALLEL(CT,4) */
             l_seq_id,
             ctlx.customer_trx_line_id,
             p_mode
     from    ra_customer_trx_all ct,
             ra_customer_trx_lines_all ctlx
     where   ct.last_update_date between g_push_from_date and g_push_to_date
     and     ct.complete_flag = 'Y'
     and     ct.customer_trx_id = ctlx.customer_trx_id
     and   exists (select 1 from ra_cust_trx_line_gl_dist_all ctlgd
                        where ctlgd.customer_trx_line_id=ctlx.customer_trx_line_id
		   and ctlgd.posting_control_id <> -3)
		   --added exists clause for SLA Uptake

     UNION
     select  /*+ PARALLEL(CTLX,4) */
             l_seq_id,
             ctlx.customer_trx_line_id,
             p_mode
     from    ra_customer_trx_lines_all ctlx
     where   ctlx.last_update_date between g_push_from_date and g_push_to_date
     and   exists (select 1 from ra_cust_trx_line_gl_dist_all ctlgd
                        where ctlgd.customer_trx_line_id=ctlx.customer_trx_line_id
		   and ctlgd.posting_control_id <> -3);
		   --added exists clause for SLA Uptake


   ELSIF (p_mode = 'AR DL')   THEN
     --  -----------------------------------------
     --  For ra_cust_trx_line_gl_dist_all
     --  -----------------------------------------
     -- --------------------------------------------------------------------------------------------------
     -- The variable g_acct_or_inv_date is added in the below mentioned select statement.
     -- The profile option stored in the global variable g_acct_or_inv_date
     -- will be stored in the column Primary_Key5 . Modified for Currency Conversion Date Enhancement, 14-APR-03
     -----------------------------------------------------------------------------------------------------

     Insert into fii_tmp_pk(
             SEQ_ID,
             Primary_Key1,
             primary_key_char5,
	     primary_key5,
	     primary_key4) --ccid
     select l_seq_id,
            ctlgd.cust_trx_line_gl_dist_id,
            p_mode,
	    g_acct_or_inv_date,
	    xal.code_combination_id
     from   ra_cust_trx_line_gl_dist_all ctlgd,
            xla_ae_headers xah,
            xla_ae_lines xal,
            xla_distribution_links xdl
     where  ctlgd.last_update_date between g_push_from_date and g_push_to_date
     and    ctlgd.account_set_flag = 'N'
     and    xah.application_id=222
     and    xal.application_id=222
     and    xdl.application_id=222
     and    xah.ae_header_id=xal.ae_header_id
     and   xal.ae_line_num=xdl.ae_line_num
     and   xal.ae_header_id=xdl.ae_header_id
     and   xdl.SOURCE_DISTRIBUTION_ID_NUM_1=ctlgd.cust_trx_line_gl_dist_id
     and   xdl.source_distribution_type='RA_CUST_TRX_LINE_GL_DIST_ALL'
     and   xah.ledger_id=ctlgd.set_of_books_id
     and   xah.balance_type_code='A'

     UNION
     select /*+ INDEX (CTLGD RA_CUST_TRX_LINE_GL_DIST_N1) */
            l_seq_id,
            ctlgd.cust_trx_line_gl_dist_id,
            p_mode,
	    g_acct_or_inv_date,
            xal.code_combination_id
     from   fii_tmp_pk ftr,
            ra_cust_trx_line_gl_dist_all ctlgd,
	    xla_ae_headers xah,
            xla_ae_lines xal,
            xla_distribution_links xdl
     where  ftr.seq_id = p_parent_seq_id
     and    ftr.primary_key1 = ctlgd.customer_trx_line_id
     and    ctlgd.account_set_flag = 'N'
     and    xah.application_id=222
     and    xal.application_id=222
     and    xdl.application_id=222
     and    xah.ae_header_id=xal.ae_header_id
     and   xal.ae_line_num=xdl.ae_line_num
     and   xal.ae_header_id=xdl.ae_header_id
     and   xdl.SOURCE_DISTRIBUTION_ID_NUM_1=ctlgd.cust_trx_line_gl_dist_id
     and   xdl.source_distribution_type='RA_CUST_TRX_LINE_GL_DIST_ALL'
     and   xah.ledger_id=ctlgd.set_of_books_id
     and   xah.balance_type_code='A'
     UNION
     select  l_seq_id,
             primary_key1,
             p_mode,
	     g_acct_or_inv_date,
	     primary_key3 --ccid
     from    fii_ar_trx_msng_rt;



   ELSIF (p_mode = 'AR ADJ')  THEN
     --  ----------------------------------------
     --  For ar_adjustments_all
     --  ----------------------------------------

     Insert into fii_tmp_pk(
            SEQ_ID,
            primary_key1,
            primary_key_char5 ,
	    primary_key4) --ccid
     select
           distinct l_seq_id,
            adj.adjustment_id,
            p_mode,
	    xal.code_combination_id
     from   ar_adjustments_all adj,
            xla_ae_headers xah,
            xla_ae_lines xal,
            xla_distribution_links xdl,
            ar_distributions_all ad
     where  adj.last_update_date between g_push_from_date and g_push_to_date
     and    nvl(adj.status, 'A')  = 'A'
     and    nvl(adj.postable,'Y') = 'Y'
     and    adj.amount <> 0
     and    xah.application_id=222
     and    xal.application_id=222
     and    xdl.application_id=222
     and    xah.ae_header_id=xal.ae_header_id
     and   xal.ae_line_num=xdl.ae_line_num
     and   xal.ae_header_id=xdl.ae_header_id
     and   xdl.SOURCE_DISTRIBUTION_ID_NUM_1=ad.line_id
     and   source_distribution_type='AR_DISTRIBUTIONS_ALL'
     and  ad.source_id=adj.adjustment_id
     and  ad.source_table='ADJ'
     and   xah.ledger_id=adj.set_of_books_id
     and   xah.balance_type_code='A'

     UNION
     select /*+ ORDERED
               PARALLEL(CT,4)
               INDEX(ADJ AR_ADJUSTMENTS_N2) */
	   distinct l_seq_id,
            adj.adjustment_id,
            p_mode,
	    xal.code_combination_id
     from   ra_customer_trx_all ct,
            ar_adjustments_all  adj,
	    xla_ae_headers xah,
            xla_ae_lines xal,
            xla_distribution_links xdl,
            ar_distributions_all ad
     where  ct.last_update_date between g_push_from_date and g_push_to_date
     and    ct.complete_flag   = 'Y'
     and    ct.customer_trx_id = adj.customer_trx_id
     and    nvl(adj.status, 'A')  = 'A'
     and    nvl(adj.postable,'Y') = 'Y'
     and    adj.amount <> 0
     and    xah.application_id=222
     and    xal.application_id=222
     and    xdl.application_id=222
     and    xah.ae_header_id=xal.ae_header_id
     and   xal.ae_line_num=xdl.ae_line_num
     and   xal.ae_header_id=xdl.ae_header_id
     and   xdl.SOURCE_DISTRIBUTION_ID_NUM_1=ad.line_id
     and   source_distribution_type='AR_DISTRIBUTIONS_ALL'
     and  ad.source_id=adj.adjustment_id
     and  ad.source_table='ADJ'
     and   xah.ledger_id=adj.set_of_books_id
     and   xah.balance_type_code='A'

     UNION
     select  l_seq_id,
             primary_key2,
             p_mode ,
	     primary_key3 --ccid
     from    fii_ar_trx_msng_rt;


   END IF;

   p_count := sql%rowcount;

   IF (FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, l_fii_schema)) THEN
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_fii_schema,
				  TABNAME => 'FII_TMP_PK');
   END IF;

   -- ------------------------------------------
   -- Commit for the child process to pick up
   -- -----------------------------------------
   Commit;


   RETURN(l_seq_id);

 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     RETURN(-1);

 END;

-----------------------------------------------------------
--PROCEDURE CHILD_SETUP
-----------------------------------------------------------

PROCEDURE CHILD_SETUP(p_object_name VARCHAR2) IS
  l_dir 	VARCHAR2(400);
  l_stmt        varchar2(200);


BEGIN

  l_stmt := 'ALTER SESSION SET GLOBAL_NAMES = FALSE' ;
   execute immediate l_stmt;

 /* IF (fnd_profile.value('EDW_TRACE')='Y') THEN
     dbms_session.set_sql_trace(TRUE);
  END IF; */ -- Commented for bug 3304365

  IF (fnd_profile.value('EDW_DEBUG') = 'Y') THEN
     edw_log.g_debug := TRUE;
  ENd IF;

  l_dir:=fnd_profile.value('EDW_LOGFILE_DIR');
  if l_dir is null then
    l_dir:='/sqlcom/log';
  end if;
  if g_debug_flag = 'Y' then
  	edw_log.put_names(p_object_name||'.log',p_object_name||'.out',l_dir);
  end if;

END;


-- ---------------------------------
-- PUBLIC PROCEDURES
-- ---------------------------------

-----------------------------------------------------------
--  PROCEDURE PUSH
-----------------------------------------------------------

 PROCEDURE PUSH(Errbuf      	in out  NOCOPY Varchar2,
                Retcode     	in out  NOCOPY Varchar2,
                p_from_date  	IN 	Varchar2,
                p_to_date    	IN 	Varchar2,
 		    p_mode		IN 	Varchar2,
                p_seq_id      IN      Varchar2) IS

 l_fact_name                Varchar2(30) :='FII_AR_TRX_DIST_F';
 l_exception_msg            Varchar2(2400):=Null;
 l_from_date                Date:=Null;
 l_to_date                  Date:=Null;
 l_seq_id_line              NUMBER := -1;
 l_seq_id_dist_line         NUMBER := -1;
 l_seq_id_adjust_line	    NUMBER := -1;
 l_row_count                NUMBER := 0;

 l_request_id1 		       NUMBER;
 l_request_id2              NUMBER;
 l_request_id3              NUMBER;
 l_request_id4              NUMBER;
 l_request_id5              NUMBER;
 l_request_id6              NUMBER;
 l_request_id7              NUMBER;
 l_request_id8              NUMBER;


 l_call_status1             BOOLEAN;
 l_call_status2             BOOLEAN;
 l_call_status3             BOOLEAN;
 l_call_status4             BOOLEAN;
 l_call_status5             BOOLEAN;
 l_call_status6             BOOLEAN;
 l_call_status7             BOOLEAN;
 l_call_status8             BOOLEAN;

 l_dev_status1              VARCHAR2(30);
 l_dev_status2              VARCHAR2(30);
 l_dev_status3              VARCHAR2(30);
 l_dev_status4              VARCHAR2(30);
 l_dev_status5              VARCHAR2(30);
 l_dev_status6              VARCHAR2(30);
 l_dev_status7              VARCHAR2(30);
 l_dev_status8              VARCHAR2(30);

 l_dev_phase1               VARCHAR2(30);
 l_dev_phase2               VARCHAR2(30);
 l_dev_phase3               VARCHAR2(30);
 l_dev_phase4               VARCHAR2(30);
 l_dev_phase5               VARCHAR2(30);
 l_dev_phase6               VARCHAR2(30);
 l_dev_phase7               VARCHAR2(30);
 l_dev_phase8               VARCHAR2(30);


 l_launch_req_failure       EXCEPTION;
 l_child_req_failure        EXCEPTION;
 l_push_local_failure       EXCEPTION;
 l_push_remote_failure      EXCEPTION;
 l_set_status_failure       EXCEPTION;
 l_iden_change_failure      EXCEPTION;
 l_item_fk_failure          EXCEPTION;

 -- -------------------------------------------
 -- Put any additional developer variables here
 -- -------------------------------------------
 l_stmt 	varchar2(100);
 my_payment_currency    Varchar2(2000):=NULL;
 my_inv_date            Varchar2(2000) := NULL;
 my_collection_status   Varchar2(2000):=NULL;
 temp			Number;

 l_to_currency     VARCHAR2(15);  -- Added for Currency Conversion Date Enhancement , 14-APR-03
 l_msg             VARCHAR2(120):=NULL; -- Added for Currency Conversion Date Enhancement , 18-APR-03
 l_set_completion_status BOOLEAN; -- Added for bug#3077413

   ----------------------------------------------------------------------------------------------
   -- This cursor is for getting records where the CONVERSION_DATE (i.e. GL_DATE or INVOICE_DATE )
   -- is less than the sysdate i.e. in past.  Added for Currency Conversion Date Enhancement , 14-APR-03
   ----------------------------------------------------------------------------------------------


   cursor miss_curr_past is select DISTINCT FUNCTIONAL_CURRENCY_FK  FROM_CURRENCY,
		            DECODE(substr(invoice_pk,1,2),'A-',GL_DATE,
                                 DECODE(g_acct_or_inv_date,1,GL_DATE,INVOICE_DATE)) CONVERSION_DATE,
	                                 COLLECTION_STATUS
	                        From FII_AR_TRX_DIST_FSTG
	                       where (COLLECTION_STATUS='RATE NOT AVAILABLE'
	                                  OR COLLECTION_STATUS = 'INVALID CURRENCY')
	                                  AND trunc(DECODE(substr(invoice_pk,1,2),'A-',GL_DATE,
	                                               DECODE(g_acct_or_inv_date,1, GL_DATE,INVOICE_DATE))) <= trunc(sysdate);

   ----------------------------------------------------------------------------------------------
   -- This cursor is for getting records where the CONVERSION_DATE (i.e. GL_DATE or INVOICE_DATE )
   -- is greater than the sysdate i.e. in future.Added for Currency Conversion Date Enhancement ,14-APR-03
   ----------------------------------------------------------------------------------------------


   cursor miss_curr_future is select DISTINCT FUNCTIONAL_CURRENCY_FK  FROM_CURRENCY,
		            DECODE(substr(invoice_pk,1,2),'A-',GL_DATE,
                                 DECODE(g_acct_or_inv_date,1,GL_DATE,INVOICE_DATE)) CONVERSION_DATE,
	                                 COLLECTION_STATUS
	                        From FII_AR_TRX_DIST_FSTG
	                       where (COLLECTION_STATUS='RATE NOT AVAILABLE'
	                                  OR COLLECTION_STATUS = 'INVALID CURRENCY')
	                                  AND trunc(DECODE(substr(invoice_pk,1,2),'A-',GL_DATE,
	                                               DECODE(g_acct_or_inv_date,1, GL_DATE,INVOICE_DATE))) > trunc(sysdate);

--Cursor declartion required to generate output file

 BEGIN

   execute immediate 'alter session set global_names=false' ; --bug#3124326

   Errbuf :=NULL;
   Retcode:=0;

   l_from_date :=to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS');
   l_to_date   :=to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');
   g_seq_id := to_number(p_seq_id);
   g_push_from_date := l_from_date;
   g_push_to_date := l_to_date;

  -----------------------------------------------------------------
    -- See whether to use accounting date or invoice date
  -----------------------------------------------------------------
    IF NVL(FND_PROFILE.value('FII_ACCT_OR_INV_DATE'),'N') = 'Y' THEN
          g_acct_or_inv_date := 1;
    ELSE
          g_acct_or_inv_date := 0;
    END IF;


   -- -------------------------------------------
   -- Turn on parallel insert/dml for the session
   -- -------------------------------------------
   COMMIT;
   l_stmt:='ALTER SESSION ENABLE PARALLEL DML';
   execute immediate l_stmt;

   IF (p_mode = 'INIT') THEN
      -- --------------------------------------
      -- Running as parent monitoring process
      -- --------------------------------------

      IF (Not EDW_COLLECTION_UTIL.setup(l_fact_name)) THEN
	    errbuf := fnd_message.get;
	    RAISE_APPLICATION_ERROR(-20000,'Error in SETUP: ' || errbuf);
     END IF;

      -- --------------------------------------------
      -- Taking care of cases where the input from/to
      -- date is NULL.  Note, this is necessary only
      -- the parent process, ie p_mode = 'INIT'
      -- --------------------------------------------
      FII_AR_TRX_DIST_F_C.g_push_from_date := nvl(l_from_date,
          EDW_COLLECTION_UTIL.G_local_last_push_start_date -
          EDW_COLLECTION_UTIL.g_offset);

      FII_AR_TRX_DIST_F_C.g_push_to_date := nvl(l_to_date,
          EDW_COLLECTION_UTIL.G_local_curr_push_start_date);

      if g_debug_flag = 'Y' then
      	edw_log.put_line( 'The collection range is from '||
        	to_char(g_push_from_date,'MM/DD/YYYY HH24:MI:SS')||' to '||
       	 	to_char(g_push_to_date,'MM/DD/YYYY HH24:MI:SS'));
      	edw_log.put_line(' ');
      end if;

      IF (NOT LOCAL_SAME_AS_REMOTE) THEN
         TRUNCATE_TABLE('FII_AR_TRX_DIST_FSTG');
      ELSE
         DELETE_STG;
      END IF;

      --  -----------------------------------------------
      --  launching parallel request to push data for AR
      --  -----------------------------------------------

      if g_debug_flag = 'Y' then
      	edw_log.put_line(' ');
      end if;

      l_request_id8 := SUBMIT_REQUEST('AR', -1);
      if g_debug_flag = 'Y' then
      	edw_log.put_line('Submitted following parallel request to push '||
		       'AR revenue transactions '||l_request_id8);
      end if;


      IF (l_request_id8 = -1) THEN
	  RAISE l_launch_req_failure;
      END IF;

      commit;

      --  -----------------------------------------------
      --  launching parallel request to push data AR ADJ
      --  -----------------------------------------------

      if g_debug_flag = 'Y' then
      	edw_log.put_line(' ');
      end if;

      l_request_id3 := SUBMIT_REQUEST('AR ADJ',l_seq_id_adjust_line);
      if g_debug_flag = 'Y' then
      	edw_log.put_line('Submitted following parallel request to push '||
                       	'AR adjustments: '||l_request_id3);
      end if;

      IF (l_request_id3 = -1) THEN
        RAISE l_launch_req_failure;
      END IF;

      commit;

      --  -----------------------------------------------
      --  launching parallel request to detect deleted invoices
      --  -----------------------------------------------

      if g_debug_flag = 'Y' then
      	edw_log.put_line(' ');
      end if;

      l_request_id4 := SUBMIT_REQUEST('DELET',-1);
      if g_debug_flag = 'Y' then
      	edw_log.put_line('Submitted following parallel request to detect '||
                       	'deleted invoices: '||l_request_id4);
      end if;

      IF (l_request_id4 = -1) THEN
        RAISE l_launch_req_failure;
      END IF;

      commit;

      --  -------------------------------
      --  -------------------------------
      --  Waiting for requests to finish
      --  -------------------------------
      if g_debug_flag = 'Y' then
      	edw_log.put_line(' ');
      	edw_log.put_line('Waiting for child requests to finish');

      	fii_util.start_timer;
      end if;

      l_call_status8 := WAIT_FOR_REQUEST(l_request_id8, l_dev_phase8,
                                         l_dev_status8);
      l_call_status3 := WAIT_FOR_REQUEST(l_request_id3, l_dev_phase3,
                                         l_dev_status3);
      l_call_status4 := WAIT_FOR_REQUEST(l_request_id4, l_dev_phase4,
                                         l_dev_status4);


      if g_debug_flag = 'Y' then
      	edw_log.put_line(' ');
      	edw_log.put_line('All child requests have finished');
      	fii_util.stop_timer;
      	fii_util.print_timer('Duration');

	edw_log.put_line('Before call to truncate_table msng_rt');
      end if;
TRUNCATE_TABLE('fii_ar_trx_msng_rt');
--select count(*)into temp from fii_ar_trx_msng_rt;
--edw_log.put_line('Rows in msng rt table after truncate'|| to_char(temp));
INSERT_INTO_MISSING_RATES;

 ----------------------------------------------------------------------------------------------------------
 -- Read the warehouse currency. Added for Currency Conversion Enhancement 14-APR-03
 ----------------------------------------------------------------------------------------------------------
  select  /*+ FULL(SP) CACHE(SP) */
          warehouse_currency_code into l_to_currency
  from edw_local_system_parameters SP;

--edw_log.put_line('g_missing_rates is '||g_missing_rates);
if (g_missing_rates >0) then   Retcode:=g_retcode;

        --------------------------------------------------------------------
	-- Print Records where conversion date is in past
	---------------------------------------------------------------------
/*	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'        ***Information for Missing Currency Conversion Rates***        ');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'   ');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Following Section displays records where Conversion Dates are in Past.');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'To fix the issue , please enter rates for these Conversion Dates and re-collect the fact.');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  ');

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'FROM CURRENCY   TO CURRENCY     CONVERSION DATE    COLLECTION STATUS');
*/

        FND_MESSAGE.SET_NAME('FII','FII_MISS_CONV_RATES');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'        ***'||fnd_message.get||'***        ');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'   ');
        FND_MESSAGE.SET_NAME('FII','FII_PAST_CONV_RATES');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  ');
	FND_MESSAGE.SET_NAME('FII','FII_FROM_CURRENCY');
	l_msg := l_msg||fnd_message.get||'   ';
        FND_MESSAGE.SET_NAME('FII','FII_TO_CURRENCY');
	l_msg := l_msg||fnd_message.get||'     ';
        FND_MESSAGE.SET_NAME('FII','FII_MISS_CONV_DATES');
	l_msg := l_msg||fnd_message.get||'    ';
        FND_MESSAGE.SET_NAME('FII','FII_COLLECTION_STATUS');
	l_msg := l_msg||fnd_message.get;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_msg);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '-------------   -----------     ---------------    -----------------');

        FOR c in miss_curr_past loop
           my_payment_currency := c.FROM_CURRENCY;
           my_inv_date := c.CONVERSION_DATE;
           my_collection_status := c.COLLECTION_STATUS;

       FND_FILE.PUT_LINE(FND_FILE.OUTPUT, my_payment_currency||
          '             '||l_to_currency||'              '||my_inv_date||'         '||my_collection_status);

         if g_debug_flag = 'Y' then
		edw_log.put_line('Inside cursor for loop');
         end if;
       end loop;

        ------------------------------------------------------------------------------
	-- Print records where conversion date is in future
	-------------------------------------------------------------------------------
/*	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  ');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Following Section displays records where Conversion Dates are in Future.');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  ');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'FROM CURRENCY   TO CURRENCY     CONVERSION DATE    COLLECTION STATUS');
*/
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'   ');
        FND_MESSAGE.SET_NAME('FII','FII_FUTURE_CONV_RATES');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  ');
	l_msg := NULL;
	FND_MESSAGE.SET_NAME('FII','FII_FROM_CURRENCY');
	l_msg := l_msg||fnd_message.get||'   ';
        FND_MESSAGE.SET_NAME('FII','FII_TO_CURRENCY');
	l_msg := l_msg||fnd_message.get||'     ';
        FND_MESSAGE.SET_NAME('FII','FII_MISS_CONV_DATES');
	l_msg := l_msg||fnd_message.get||'    ';
        FND_MESSAGE.SET_NAME('FII','FII_COLLECTION_STATUS');
	l_msg := l_msg||fnd_message.get;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_msg);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '-------------   -----------     ---------------    -----------------');

       FOR d in miss_curr_future loop
           my_payment_currency := d.FROM_CURRENCY;
           my_inv_date := d.CONVERSION_DATE;
           my_collection_status := d.COLLECTION_STATUS;

       FND_FILE.PUT_LINE(FND_FILE.OUTPUT, my_payment_currency||
          '             '||l_to_currency||'              '||my_inv_date||'         '||my_collection_status);

         if g_debug_flag = 'Y' then
		edw_log.put_line('Inside cursor for loop1');
         end if;
       end loop;


   end if;

      --  -------------------------------
      --  check request status
      --  -------------------------------
      /* Even if the completion status is WARNING then also the code should behave the same as
         for completion status NORMAL. bug#3052562 */

      IF (NVL(l_dev_phase8='COMPLETE' AND (l_dev_status8 = 'NORMAL' OR l_dev_status8 = 'WARNING') AND
              l_dev_phase3='COMPLETE' AND (l_dev_status3 = 'NORMAL' OR l_dev_status3 = 'WARNING') AND
              l_dev_phase4='COMPLETE' AND (l_dev_status4 = 'NORMAL' OR l_dev_status4 = 'WARNING'), FALSE)) THEN

         -- --------------------------------
         -- Update the item foreign keys
         -- Note, in update_item_fk, we run ddl
         -- which results in a commit.
         -- --------------------------------
         if g_debug_flag = 'Y' then
        	 edw_log.put_line(' ');
         	edw_log.put_line('Updating Item foreign key with proper values');
         	edw_log.put_line('in the local staging table');

         	fii_util.start_timer;
         end if;
         g_row_count := update_item_fk;
         if g_debug_flag = 'Y' then
         	fii_util.stop_timer;
         	fii_util.print_timer('Duration');
         end if;

         IF (g_row_count = -1) THEN RAISE l_item_fk_failure; END IF;

	 if g_debug_flag = 'Y' then
        	 edw_log.put_line('Updated '||g_row_count||' records');
         end if;



         IF (NOT LOCAL_SAME_AS_REMOTE) THEN
           -- -----------------------------------------------
           -- The target warehouse is not the same database
           -- as the source OLTP, which is the typical case.
           -- We move data from local to remote staging table
           -- and clean up local staging
           -- -----------------------------------------------

	if g_debug_flag = 'Y' then
           edw_log.put_line(' ');
           edw_log.put_line('Moving data from local staging table to remote staging table');
           fii_util.start_timer;
        end if;
           g_row_count := PUSH_REMOTE;
        if g_debug_flag = 'Y' then
           fii_util.stop_timer;
           fii_util.print_timer('Duration');
        end if;

           IF (g_row_count = -1) THEN RAISE l_push_remote_failure; END IF;
	if g_debug_flag = 'Y' then
           edw_log.put_line(' ');
           edw_log.put_line('Cleaning local staging table');

           fii_util.start_timer;
        end if;
           TRUNCATE_TABLE('FII_AR_TRX_DIST_FSTG');
        if g_debug_flag = 'Y' then
           fii_util.stop_timer;
           fii_util.print_timer('Duration');
        end if;

         ELSE
           -- -----------------------------------------------
           -- The target warehouse is the same database
           -- as the source OLTP.  We set the status of all our
           -- records status 'LOCAL READY' to 'READY'
           -- -----------------------------------------------

           if g_debug_flag = 'Y' then
           	edw_log.put_line(' ');
           	edw_log.put_line('Marking records in staging table with READY status');
           	fii_util.start_timer;
	   end if;
	   -- Bug 4689098. Moved the call to SET_STATUS_READY out of the if statement
	   -- so that it gets called even when debug mode is set to No
           	g_row_count := SET_STATUS_READY;
	   if g_debug_flag = 'Y' then
           	fii_util.stop_timer;
           	fii_util.print_timer('Duration');
           end if;

           IF (g_row_count = -1) THEN RAISE l_set_status_failure; END IF;
         END IF;

      ELSE

         RAISE l_child_req_failure;

      END IF;

        DELETE_STG;

      -- -----------------------------------------------
      -- No exception raised so far.  Successful.  Call
      -- wrapup to commit and insert messages into logs
      -- -----------------------------------------------
      if g_debug_flag = 'Y' then
      	edw_log.put_line(' ');
      	edw_log.put_line('Inserted '||nvl(g_row_count,0)||
         	' rows into the staging table');
      	edw_log.put_line(' ');
      end if;
      EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count, l_exception_msg, g_push_from_date, g_push_to_date);


   ELSIF (p_mode = 'AR') THEN

      -- -----------------------------------------------
      -- We do this for child process because child
      -- process do not call setup routine from EDWCORE
      -- -----------------------------------------------
      CHILD_SETUP(l_fact_name||'_'||p_mode);

      --  --------------------------------------------
      --  Identify Change for AR Invoice Lines and
      --  launching parallel request to push data
      --  --------------------------------------------
      if g_debug_flag = 'Y' then
      	edw_log.put_line(' ');
      	edw_log.put_line('Identifying changed AR invoice lines');
      	fii_util.start_timer;
      end if;
      l_seq_id_line := IDENTIFY_CHANGE('AR INVL',l_row_count);
      if g_debug_flag = 'Y' then
      	fii_util.stop_timer;
     	 fii_util.print_timer('Identified '||l_row_count||' changed records in');
      end if;

      if (l_seq_id_line = -1) THEN
        RAISE l_iden_change_failure;
      end if;

      l_request_id2 := SUBMIT_REQUEST('AR INVL',l_seq_id_line);
      if g_debug_flag = 'Y' then
      	edw_log.put_line('Submitted following parallel request to push '||
                       'AR invoice lines: '||l_request_id2);
      end if;

      l_request_id7 := SUBMIT_REQUEST('AR OE INVL',l_seq_id_line);
      if g_debug_flag = 'Y' then
      	edw_log.put_line('Submitted following parallel request to push '||
                       'AR invoice lines (OE related invoices): '||
                        l_request_id7);
      end if;

      IF (l_request_id2 = -1 OR l_request_id7 = -1) THEN
        RAISE l_launch_req_failure;
      END IF;

      --  --------------------------------------------
      --  Identify Change for AR Invoice Distributions
      --  and launching parallel request to push data
      --  --------------------------------------------
      if g_debug_flag = 'Y' then
      	edw_log.put_line(' ');
      	edw_log.put_line('Identifying changed AR invoice distribution');
      	fii_util.start_timer;
      end if;
      l_seq_id_dist_line := IDENTIFY_CHANGE('AR DL', l_row_count,l_seq_id_line);
      fii_util.stop_timer;
      fii_util.print_timer('Identified '||l_row_count||' changed records in');

      if (l_seq_id_dist_line = -1) THEN
        RAISE l_iden_change_failure;
      end if;

      l_request_id1 := SUBMIT_REQUEST('AR DL',l_seq_id_dist_line);
      if g_debug_flag = 'Y' then
      	edw_log.put_line('Submitted following parallel request to push '||
                       'AR invoice details: '||l_request_id1);
      end if;

      l_request_id6 := SUBMIT_REQUEST('AR OE DL',l_seq_id_dist_line);
      if g_debug_flag = 'Y' then
      	edw_log.put_line('Submitted following parallel request to push '||
                       'AR invoice details (OE related invoices): '||
                        l_request_id6);
      end if;

      IF (l_request_id1 = -1 OR l_request_id6 = -1) THEN
        RAISE l_launch_req_failure;
      END IF;

      commit;

      --  -------------------------------
      --  Waiting for AR requests to finish
      --  -------------------------------
      if g_debug_flag = 'Y' then
      	edw_log.put_line(' ');
      	edw_log.put_line('Waiting for AR child requests to finish');

      	fii_util.start_timer;
      end if;

      l_call_status1 := WAIT_FOR_REQUEST(l_request_id1, l_dev_phase1,
                                         l_dev_status1);
      l_call_status2 := WAIT_FOR_REQUEST(l_request_id2, l_dev_phase2,
                                         l_dev_status2);
      l_call_status6 := WAIT_FOR_REQUEST(l_request_id6, l_dev_phase6,
                                         l_dev_status6);
      l_call_status7 := WAIT_FOR_REQUEST(l_request_id7, l_dev_phase7,
                                         l_dev_status7);

    if g_debug_flag = 'Y' then
      	edw_log.put_line(' ');
      	edw_log.put_line('All child requests have finished');
      	fii_util.stop_timer;
      	fii_util.print_timer('Duration');
      end if;



      -- -------------------------------------------------------------
      -- Delete all temp tables' record
      -- -------------------------------------------------------------

      if g_debug_flag = 'Y' then
      	fii_util.start_timer;
      	edw_log.put_line(' ');
     	 edw_log.put_line('Cleaning tmp table');
      end if;

      delete fii_tmp_pk
      where seq_id IN (	l_seq_id_line,
		        l_seq_id_dist_line);
      commit;

      if g_debug_flag = 'Y' then
     	 fii_util.stop_timer;
      	fii_util.print_timer('Duration');
      end if;

      --  -------------------------------
      --  check request status
      --  -------------------------------
      /* Even if the completion status is WARNING then also the code should behave the same as
         for completion status NORMAL. bug#3052562 */
      IF NOT(NVL(l_dev_phase1='COMPLETE' AND (l_dev_status1 = 'NORMAL' OR l_dev_status1 = 'WARNING') AND
                 l_dev_phase2='COMPLETE' AND (l_dev_status2 = 'NORMAL' OR l_dev_status2 = 'WARNING') AND
                 l_dev_phase6='COMPLETE' AND (l_dev_status6 = 'NORMAL' OR l_dev_status6 = 'WARNING') AND
                 l_dev_phase7='COMPLETE' AND (l_dev_status7 = 'NORMAL' OR l_dev_status7 = 'WARNING'), FALSE)) THEN

         RAISE l_child_req_failure;

      END IF;



   ELSE
      -- --------------------------------------
      -- p_mode <> 'INIT'
      -- Running as a child process
      -- --------------------------------------
      CHILD_SETUP(l_fact_name||'_'||p_mode);



      -- -----------------------------------------------
      -- We do this for child process because child
      -- process do not call setup routine from EDWCORE
      -- -----------------------------------------------


      -- -----------------------------------------------
      -- Initialize the cache in flex api
      -- -----------------------------------------------


     IF (p_mode = 'AR ADJ') THEN

        --  --------------------------------------------
        --  Identify Changed Records
        --  --------------------------------------------

	if g_debug_flag = 'Y' then
        	edw_log.put_line(' ');

        	edw_log.put_line(p_mode);

        	edw_log.put_line( 'The collection range is from '||
        	to_char(g_push_from_date,'MM/DD/YYYY HH24:MI:SS')||' to '||
        	to_char(g_push_to_date,'MM/DD/YYYY HH24:MI:SS'));


        	edw_log.put_line('Identifying changed records');
        	fii_util.start_timer;
        end if;
        g_seq_id := IDENTIFY_CHANGE(p_mode,l_row_count);
        if g_debug_flag = 'Y' then
        	fii_util.stop_timer;
        	fii_util.print_timer('Identified '||l_row_count||' changed records in');
        end if;

        if (g_seq_id = -1) THEN
          RAISE l_iden_change_failure;
        end if;

      END IF;

      if g_debug_flag = 'Y' then
      	edw_log.put_line(' ');
      	edw_log.put_line('Pushing to local staging table');
      	fii_util.start_timer;
      end if;
      g_row_count := PUSH_TO_LOCAL(p_mode);
      if g_debug_flag = 'Y' then
      	fii_util.stop_timer;
      	fii_util.print_timer('Duration');
      end if;

      IF (g_row_count = -1) THEN RAISE L_push_local_failure; END IF;

      IF (p_mode = 'AR ADJ') THEN

        -- --------------------------------------------
        -- Delete all temp tables' record
        -- --------------------------------------------
        if g_debug_flag = 'Y' then
        	fii_util.start_timer;
        	edw_log.put_line(' ');
        	edw_log.put_line('Cleaning tmp table');
        end if;

        delete fii_tmp_pk
        where seq_id = g_seq_id;
        commit;

        fii_util.stop_timer;
        fii_util.print_timer('Duration');

      END IF;
     if g_debug_flag = 'Y' then
      	edw_log.put_line('Inserted '||nvl(g_row_count,0)||
         	' rows into the local staging table');
      	edw_log.put_line(' ');
      end if;

      -- ---------------------------------------------------
      -- Commit records into local staging table. Needed
      -- because we don't call wrapup for child process
      -- ---------------------------------------------------
      COMMIT;
   -- --------------------------------------
      -- p_mode <> 'INIT'
      -- Running as a child process
      -- --------------------------------------

      IF (p_mode = 'DELET') THEN

     if g_debug_flag = 'Y' then
     	edw_log.put_line(' ');
     	edw_log.put_line(p_mode);

     	fii_util.put_timestamp;
     	edw_log.put_line('We are detecting invoices deleting from AR but are in warehouse');
     	edw_log.put_line(' ');
     	fii_util.put_timestamp;
     	edw_log.put_line('Clean and set up environment');
     end if;
     l_stmt := 'Begin  FII_AR_TRX_DIST_F_D.Init@EDW_APPS_TO_WH (edw_instance.get_code);  End; ';
     execute immediate l_stmt ;
     if g_debug_flag = 'Y' then
     	edw_log.put_line('Dropping OLTP temp table ');
     end if;
     l_stmt := 'Begin  FII_AR_TRX_DIST_F_D.Drop_Table@EDW_APPS_TO_WH(''FII_AR_OLTP_TMP_TRX_ID'');  End; ';
     execute immediate l_stmt;
     if g_debug_flag = 'Y' then
     	edw_log.put_line('Dropping EDW temp table ');
     end if;
     l_stmt := 'Begin  FII_AR_TRX_DIST_F_D.Drop_Table@EDW_APPS_TO_WH(''FII_AR_EDW_TMP_TRX_ID'');  End;  ';
     execute immediate l_stmt;
     l_stmt := 'Begin  FII_AR_TRX_DIST_F_D.Drop_Table@EDW_APPS_TO_WH(''FII_AR_EDW_EXTRA_ID'');  End;  ';
     execute immediate l_stmt;
     if g_debug_flag = 'Y' then
     	edw_log.put_line(' ');
     	fii_util.put_timestamp;
     	edw_log.put_line('Generate list of invoices in AR subledger');
     	fii_util.start_timer;
     end if;
     l_stmt := 'Begin  FII_AR_TRX_DIST_F_D.Create_OLTP_TRX_TMP_TABLE@EDW_APPS_TO_WH;  End;  ';
     execute immediate l_stmt;
     commit;
     l_stmt := 'Begin  FII_AR_TRX_DIST_F_D.Populate_OLTP_TRX_TMP_TABLE@EDW_APPS_TO_WH;  End;   ';
     execute immediate l_stmt;
     commit;
     if g_debug_flag = 'Y' then
     	fii_util.stop_timer;
     	fii_util.print_timer('Duration');

     	edw_log.put_line(' ');
     	fii_util.put_timestamp;
     	edw_log.put_line('Generate list of invoices in EDW');
     	fii_util.start_timer;
     end if;
     l_stmt := 'Begin  FII_AR_TRX_DIST_F_D.Create_EDW_TRX_TMP_TABLE@EDW_APPS_TO_WH;  End;   ';
     execute immediate l_stmt;
     commit;
     if g_debug_flag = 'Y' then
     	fii_util.stop_timer;
     	fii_util.print_timer('Duration');

     	edw_log.put_line(' ');
     	fii_util.put_timestamp;
     	edw_log.put_line('Finding extra invoices in EDW which should be deleted');
     	fii_util.start_timer;
     end if;
     l_stmt := 'Begin  FII_AR_TRX_DIST_F_D.Find_Extra_Trx_EDW@EDW_APPS_TO_WH;  End;  ';
     execute immediate l_stmt;
    commit;
    l_stmt := 'Begin  FII_AR_TRX_DIST_F_D.Count_Extra_Trx_EDW@EDW_APPS_TO_WH(:g_row_count);  End;   ';
     execute immediate l_stmt using out g_row_count;
     commit;
     if g_debug_flag = 'Y' then
     	edw_log.put_line('EDW has '||g_row_count||' extra invoices not found in OLTP');
     	fii_util.stop_timer;
     	fii_util.print_timer('Duration');

     	edw_log.put_line(' ');
     	fii_util.put_timestamp;
     	edw_log.put_line('Inserting into staging area');
     	fii_util.start_timer;
     end if;
     l_stmt := 'Begin  FII_AR_TRX_DIST_F_D.Insert_Staging@EDW_APPS_TO_WH(:g_row_count);  End;  ';
     execute immediate l_stmt using out g_row_count;
     commit;
     if g_debug_flag = 'Y' then
    	 edw_log.put_line('Inserting '||g_row_count||' records marked for deletion');
     	fii_util.stop_timer;
    	 fii_util.print_timer('Duration');
     end if;

     If (g_row_count = -1) THEN RAISE L_child_req_failure;  End if;

      l_stmt := 'Begin  FII_AR_TRX_DIST_F_D.Drop_Table@EDW_APPS_TO_WH(''FII_AR_OLTP_TMP_TRX_ID'');  End;   ';
     execute immediate l_stmt;
     l_stmt := 'Begin  FII_AR_TRX_DIST_F_D.Drop_Table@EDW_APPS_TO_WH(''FII_AR_EDW_TMP_TRX_ID'');  End;   ';
    execute immediate l_stmt;
     l_stmt := 'Begin  FII_AR_TRX_DIST_F_D.Drop_Table@EDW_APPS_TO_WH(''FII_AR_EDW_EXTRA_ID'');  End;  ';
     execute immediate l_stmt;
     fii_util.put_timestamp;


   END IF;
   END IF;



-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

 EXCEPTION

   WHEN L_LAUNCH_REQ_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;            -- rollback any submitted requests
      delete fii_tmp_pk    -- clean out fii_tmp_pk table
      where seq_id IN (	l_seq_id_line,
			l_seq_id_dist_line,
			l_seq_id_adjust_line);
      commit;
      if g_debug_flag = 'Y' then
      	edw_log.put_line('Failure when launching child requests');
      end if;
      /* Added the if condition. Wrapup should only be called by the
         main process not by the child processes. Bug#3077413 */
      if ( p_mode='INIT' ) then
         EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg, g_push_from_date, g_push_to_date);
      else
         edw_log.put_line('Failure occurred in mode : '||p_mode);
      end if;

      l_set_completion_status:=FND_CONCURRENT.Set_Completion_Status(status=>'ERROR',message=>l_exception_msg);
      -- raise; /* commented out for bug#3052562 */

   WHEN L_CHILD_REQ_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      DELETE_STG;      -- Cleanup local staging table
      if g_debug_flag = 'Y' then
      	edw_log.put_line('One of the child requests have failed');
      end if;
       /* Added the if condition. Wrapup should only be called by the
         main process not by the child processes. Bug#3077413 */
      if ( p_mode='INIT' ) then
        EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg, g_push_from_date, g_push_to_date);
      else
         edw_log.put_line('Failure occurred in mode : '||p_mode);
      end if;
      /* Set the completion status to error. bug#3207823 */
      l_set_completion_status:=FND_CONCURRENT.Set_Completion_Status(status=>'ERROR',message=>l_exception_msg);
      -- raise; /* commented out for bug#3052562 */

   WHEN L_PUSH_LOCAL_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;            -- Rollback insert into local staging
      delete fii_tmp_pk    -- clean out fii_tmp_pk table
      where seq_id = g_seq_id;
      commit;
      if g_debug_flag = 'Y' then
      	edw_log.put_line('Inserting into local staging have failed');
      end if;
       /* Added the if condition. Wrapup should only be called by the
         main process not by the child processes. Bug#3077413 */
      if ( p_mode='INIT' ) then
        EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg, g_push_from_date, g_push_to_date);
      else
         edw_log.put_line('Failure occurred in mode : '||p_mode);
      end if;
      /* Set the completion status to error. bug#3207823 */
      l_set_completion_status:=FND_CONCURRENT.Set_Completion_Status(status=>'ERROR',message=>l_exception_msg);
      -- raise; /* commented out for bug#3052562 */

   WHEN L_PUSH_REMOTE_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;      -- rollback any insert into remote site
      TRUNCATE_TABLE('FII_AR_TRX_DIST_FSTG');  -- Cleanup local staging table
      if g_debug_flag = 'Y' then
      	edw_log.put_line('Data migration from local to remote staging have failed');
      end if;
       /* Added the if condition. Wrapup should only be called by the
         main process not by the child processes. Bug#3077413 */
      if ( p_mode='INIT' ) then
        EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg, g_push_from_date, g_push_to_date);
      else
         edw_log.put_line('Failure occurred in mode : '||p_mode);
      end if;
      /* Set the completion status to error. bug#3207823 */
      l_set_completion_status:=FND_CONCURRENT.Set_Completion_Status(status=>'ERROR',message=>l_exception_msg);
      -- raise; /* commented out for bug#3052562 */

   WHEN L_SET_STATUS_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;      -- Rollback the status to 'LOCAL READY'
      DELETE_STG;    -- Delete records in staging with status 'LOCAL READY'
      commit;
      if g_debug_flag = 'Y' then
      	edw_log.put_line('Setting status to READY have failed');
      end if;
       /* Added the if condition. Wrapup should only be called by the
         main process not by the child processes. Bug#3077413 */
      if ( p_mode='INIT' ) then
         EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg, g_push_from_date, g_push_to_date);
      else
         edw_log.put_line('Failure occurred in mode : '||p_mode);
      end if;
      /* Set the completion status to error. bug#3207823 */
      l_set_completion_status:=FND_CONCURRENT.Set_Completion_Status(status=>'ERROR',message=>l_exception_msg);
      -- raise;  /* commented out for bug#3052562 */

   WHEN L_IDEN_CHANGE_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      delete fii_tmp_pk
      where seq_id IN (	l_seq_id_line,
			l_seq_id_dist_line,
			l_seq_id_adjust_line,
			g_seq_id);
      commit;
      if g_debug_flag = 'Y' then
      	edw_log.put_line('Identifying changed records have Failed');
      end if;
       /* Added the if condition. Wrapup should only be called by the
         main process not by the child processes. Bug#3077413 */
      if ( p_mode='INIT' ) then
         EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg, g_push_from_date, g_push_to_date);
      else
         edw_log.put_line('Failure occurred in mode : '||p_mode);
      end if;
      /* Set the completion status to error. bug#3207823 */
      l_set_completion_status:=FND_CONCURRENT.Set_Completion_Status(status=>'ERROR',message=>l_exception_msg);
      -- raise;  /* commented out for bug#3052562 */

   WHEN L_ITEM_FK_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      DELETE_STG;  -- Delete records in staging with status 'LOCAL READY'
      if g_debug_flag = 'Y' then
     	 edw_log.put_line('Error updating item foreign key');
      end if;
       /* Added the if condition. Wrapup should only be called by the
         main process not by the child processes. Bug#3077413 */
      if ( p_mode='INIT' ) then
         EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg, g_push_from_date, g_push_to_date);
      else
         edw_log.put_line('Failure occurred in mode : '||p_mode);
      end if;
      /* Set the completion status to error. bug#3207823 */
      l_set_completion_status:=FND_CONCURRENT.Set_Completion_Status(status=>'ERROR',message=>l_exception_msg);
      -- raise;  /* commented out for bug#3052562 */


   WHEN OTHERS THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;
      delete fii_tmp_pk
      where seq_id IN ( l_seq_id_line,
                        l_seq_id_dist_line,
                        l_seq_id_adjust_line,
                        g_seq_id);
      commit;
      if g_debug_flag = 'Y' then
      	edw_log.put_line('Other errors');
      end if;
       /* Added the if condition. Wrapup should only be called by the
         main process not by the child processes. Bug#3077413 */
      if ( p_mode='INIT' ) then
        EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg, g_push_from_date, g_push_to_date);
      else
         edw_log.put_line('Failure occurred in mode : '||p_mode);
      end if;
      /* Set the completion status to error. bug#3207823 */
      l_set_completion_status:=FND_CONCURRENT.Set_Completion_Status(status=>'ERROR',message=>l_exception_msg);
      -- raise; /* commented out for bug#3052562 */

 END;

END FII_AR_TRX_DIST_F_C;

/
