--------------------------------------------------------
--  DDL for Package Body FII_AR_TRX_DIST_F_D
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_TRX_DIST_F_D" AS
/* $Header: FIIAR07B.pls 120.3 2005/06/07 12:14:51 sgautam noship $ */

g_errbuf        varchar2(2000) := NULL;
g_retcode       varchar2(200)  := NULL;
g_fii_schema 	VARCHAR2(30);
g_instance_code VARCHAR2(30);
g_db_link       VARCHAR2(128);
g_tablespace    VARCHAR2(30);
G_TABLE_NOT_EXIST      EXCEPTION;
PRAGMA EXCEPTION_INIT(G_TABLE_NOT_EXIST, -942);


PROCEDURE Init(p_instance_code IN VARCHAR2) is
  l_stmt  		VARCHAR2(200);
  l_status		VARCHAR2(30);
  l_industry		VARCHAR2(30);
BEGIN

  -- --------------------------------------------------------
  -- Set instance code, database link name
  -- --------------------------------------------------------

  l_stmt := 'ALTER SESSION SET GLOBAL_NAMES = FALSE';
     execute immediate l_stmt;

  g_instance_code := p_instance_code;

  select warehouse_to_instance_link
  into   g_db_link
  from   edw_source_instances
  where  instance_code = g_instance_code;

  -- --------------------------------------------------------
  -- Find the schema owner and tablespace FII_AR_TRX_DIST_FSTG is using
  -- --------------------------------------------------------
  IF(FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, g_fii_schema))
  THEN NULL;
  END IF;

  SELECT tablespace_name
  INTO   g_tablespace
  FROM   all_tables
  WHERE  table_name = 'FII_AR_TRX_DIST_FSTG'
  AND    owner = g_fii_schema;

end Init;



---------------------------------------------------
-- PROCEDURE DROP_TABLE
---------------------------------------------------
procedure drop_table (p_table_name in varchar2) is
  l_stmt varchar2(400);
Begin

  l_stmt:='drop table '||g_fii_schema||'.'||p_table_name;
  execute immediate l_stmt;

Exception
  WHEN G_TABLE_NOT_EXIST THEN
    null;      -- Oracle 942, table does not exist, no actions
  WHEN OTHERS THEN
    raise;
End;


---------------------------------------------------
-- PROCEDURE Create_OLTP_TRX_TMP_TABLE
---------------------------------------------------
procedure Create_OLTP_TRX_TMP_TABLE is
  l_stmt varchar2(400);
Begin

  -- --------------------------------------------------------
  -- Had to remove the parallel sub clause to avoid ora 7260
  -- --------------------------------------------------------
  l_stmt := 'create table '||g_fii_schema||'.FII_AR_OLTP_TMP_TRX_ID '||
            '(trx_id NUMBER) tablespace '||g_tablespace||
            ' PCTFREE 5 storage (INITIAL 4K NEXT 1M)';


  execute immediate l_stmt;

End Create_OLTP_TRX_TMP_TABLE;

procedure Populate_OLTP_TRX_TMP_TABLE is
  l_stmt varchar2(400);
Begin
  -- --------------------------------------------------------
  -- We cannot combine this procedure with Create_OLTP_TRX_TMP_TABLE
  -- because we run into ora 2041.  Need to sepate create table and
  -- insert stmt into 2 separate transactions.  This is true even
  -- when we use create table as insert syntax.  This is because
  -- the insert clause references a database link
  -- --------------------------------------------------------
  l_stmt := 'insert into '||g_fii_schema||'.FII_AR_OLTP_TMP_TRX_ID '||
            'select /*+ PARALLEL(TRX,10) */ '||
            '     customer_trx_id trx_id '||
            'from   ra_customer_trx_all@'||g_db_link||' TRX';

  execute immediate l_stmt;
  commit;
end;


--------------------------------------------------
-- PROCEDURE Create_EDW_TRX_TMP_TABLE
---------------------------------------------------
procedure Create_EDW_TRX_TMP_TABLE  is
  l_stmt 	VARCHAR2(1000);

Begin

  -- --------------------------------------------------------
  -- Had to remove the parallel sub clause to avoid ora 7260
  -- --------------------------------------------------------
  l_stmt :='create table '||g_fii_schema||'.FII_AR_EDW_TMP_TRX_ID '||
          'tablespace '||g_tablespace||' parallel '||
          'PCTFREE 5 storage (INITIAL 4K NEXT 1M) '||
          'as select  /*+ PARALLEL(F,10) */  '||
          'distinct '||
          'to_number(invoice_id) trx_id '||
	  'from  fii_ar_trx_dist_f  F  '||
          'where transaction_class <> ''ADJ'' '||
          'and   invoice_pk like ''%'||g_instance_code||'%'' ';

  execute immediate l_stmt;
  commit;

End Create_EDW_TRX_TMP_TABLE;


---------------------------------------------------
-- PROCEDURE Find_Extra_Trx_EDW
---------------------------------------------------

PROCEDURE  Count_Extra_Trx_EDW (l_count OUT NOCOPY /* file.sql.39 change */ NUMBER)  is
  l_stmt 	VARCHAR2(100);

Begin
  l_stmt := 'select count(*) from '||g_fii_schema||'.FII_AR_EDW_EXTRA_ID ';

  execute immediate l_stmt into l_count;

End Count_Extra_Trx_EDW;

---------------------------------------------------
-- PROCEDURE Find_Extra_Trx_EDW
---------------------------------------------------
PROCEDURE Find_Extra_Trx_EDW is
  l_stmt 	VARCHAR2(1000);
Begin

  -- --------------------------------------------------------
  -- Had to remove the parallel sub clause to avoid ora 7260
  -- --------------------------------------------------------
  l_stmt := 'create table '||g_fii_schema||'.FII_AR_EDW_EXTRA_ID '||
            'tablespace '||g_tablespace||' parallel '||
	    'PCTFREE 5 storage (INITIAL 4K NEXT 1M) '||
	    'as select	trx_id '||
	    'from '||g_fii_schema||'.FII_AR_EDW_TMP_TRX_ID '||
	    'where	trx_id in '||
	    '       (select /*+ PARALLEL(EDW,5) */ trx_id '||
	    '        from '||g_fii_schema||'.FII_AR_EDW_TMP_TRX_ID EDW '||
	    '         minus '||
	    '        select /*+ PARALLEL(OLTP,5) */ trx_id '||
	    '        from '||g_fii_schema||'.FII_AR_OLTP_TMP_TRX_ID OLTP) ';

  execute immediate l_stmt;

  l_stmt := 'analyze table '||g_fii_schema||'.fii_ar_edw_extra_id estimate statistics';
  execute immediate l_stmt;

  commit;

End Find_Extra_Trx_EDW;


---------------------------------------------------
-- PROCEDURE Insert_Staging
---------------------------------------------------
PROCEDURE Insert_Staging (l_row OUT NOCOPY /* file.sql.39 change */ NUMBER)  IS
  l_stmt varchar2(2000);

Begin


l_stmt :=
   'insert into FII_AR_TRX_DIST_FSTG(  '||
' INVOICE_PK, '||
' OPERATION_CODE, '||
' COLLECTION_STATUS, '||
'INVOICE_ID, '||
' ORIGINAL_INVOICE_ID, '||
' ORIGINAL_INVOICE_LINE_ID, '||
' END_USER_CUSTOMER_FK, '||
' RESELLER_CUSTOMER_FK, '||
' INVOICE_DATE_FK, '||
' SALES_ORDER_DATE_FK, '||
' INVOICE_LINE_ID, '||
' FUNCTIONAL_CURRENCY_FK, '||
' BILL_TO_CUSTOMER_FK, '||
' BILL_TO_SITE_FK, '||
' CAMPAIGN_ACTL_FK, '||
' CAMPAIGN_INIT_FK, '||
' CELL_ACTL_FK, '||
' CELL_INIT_FK, '||
' EVENT_OFFER_ACTL_FK, '||
' EVENT_OFFER_INIT_FK, '||
' EVENT_OFFER_REG_FK, '||
' GL_ACCT10_FK, '||
' GL_ACCT1_FK, '||
' GL_ACCT2_FK, '||
' GL_ACCT3_FK, '||
' GL_ACCT4_FK, '||
' GL_ACCT5_FK, '||
' GL_ACCT6_FK, '||
' GL_ACCT7_FK, '||
' GL_ACCT8_FK, '||
' GL_ACCT9_FK, '||
' GL_DATE_FK , '||
' SET_OF_BOOKS_FK, '||
' INSTANCE_FK, '||
' ITEM_FK, '||
' MARKET_SEGMENT_FK, '||
' MEDIA_ACTL_FK, '||
' MEDIA_INIT_FK, '||
' OFFER_ACTL_FK, '||
' OFFER_INIT_FK, '||
' ORGANIZATION_FK, '||
' PARENT_ITEM_FK, '||
' PAYMENT_TERM_FK, '||
' PRIM_SALESREP_FK, '||
' PROJECT_FK, '||
' SALESCHANNEL_FK, '||
' SALESREP_FK, '||
' SHIP_TO_CUSTOMER_FK, '||
' SHIP_TO_SITE_FK, '||
' SIC_CODE_FK, '||
' SOLD_TO_CUSTOMER_FK, '||
' SOLD_TO_SITE_FK, '||
' SOURCE_LIST_FK, '||
' TRANSACTION_CURRENCY_FK, '||
' UOM_FK, '||
' USER_FK1, '||
' USER_FK2, '||
' USER_FK3, '||
' USER_FK4, '||
' USER_FK5, '||
' CAMPAIGN_STATUS_INIT_FK, '||
' CAMPAIGN_STATUS_ACTL_FK,  '||
' CREATION_DATE,  '||
' LAST_UPDATE_DATE)  '||
'select  '||
'f.invoice_pk, '||
'''DELETE'','||
'''READY'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'''NA_EDW'','||
'sysdate, '||
'sysdate  '||
'from '||g_fii_schema||'.FII_AR_EDW_EXTRA_ID extra, '||
'FII_AR_TRX_DIST_F f  '||
'where f.invoice_id = extra.trx_id  '||
'and  f.invoice_pk like ''%'||g_instance_code||'%'' ';

  execute immediate l_stmt;
  l_row := SQL%ROWCOUNT;

EXCEPTION
  WHEN OTHERS THEN
   g_errbuf :=sqlerrm;
   g_retcode :=sqlcode;

End Insert_Staging;


End FII_AR_TRX_DIST_F_D;

/
