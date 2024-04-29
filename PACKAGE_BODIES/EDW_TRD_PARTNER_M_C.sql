--------------------------------------------------------
--  DDL for Package Body EDW_TRD_PARTNER_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_TRD_PARTNER_M_C" AS
/* $Header: poapptpb.pls 120.1 2005/06/13 13:16:57 sriswami noship $ */

g_row_count	     Number:=0;
g_row_count_m        Number:=0;
g_exception_message  varchar2(10000):=NULL;


-- ---------------------------------
-- PRIVATE PROCEDURES
-- ---------------------------------

 Procedure populate_hierarchies (p_from_date  IN  DATE,
                                 p_to_date    IN  DATE) IS

/**********************************************************************
 *                                                                    *
 * This procedure will populate the EDW_PO_VENDOR_HIERARCHIES table   *
 *                                                                    *
 * Author: tom.olick      Date: April 3, 2002                         *
 *                                                                    *
 **********************************************************************/

l_push_date_range1 DATE  := p_from_date;
l_push_date_range2 DATE  := p_to_date;
l_rows_inserted    NUMBER := 0;
l_duration         NUMBER := 0;
l_temp_date        DATE;
Errbuf             VARCHAR2(1000) := NULL;
Retcode            NUMBER := 0;
g_stmt             VARCHAR2(200);
g_schema           VARCHAR2(30);
g_status           VARCHAR2(30);
g_industry         VARCHAR2(30);

Begin

   IF (NOT FND_INSTALLATION.GET_APP_INFO('PO', g_status, g_industry, g_schema)) THEN
       RAISE_APPLICATION_ERROR (-20001, '***There is not POA schema set up***');
   END IF;

   edw_log.put_line(' ');
   edw_log.put_line('Truncating Vendor Hierarchies table...');

   g_stmt := 'TRUNCATE TABLE ' || g_schema || '.EDW_PO_VENDOR_HIERARCHIES';
   EXECUTE IMMEDIATE g_stmt;

   edw_log.put_line(' ');
   edw_log.put_line('Populating Vendor Hierachies table...');

   l_temp_date := sysdate;

   Insert Into EDW_PO_VENDOR_HIERARCHIES (
	 hierarchy_level,
	 last_update_date,
	 vendor_id,
	 parent_vendor_id)
   select
	 level,
	 last_update_date,
	 vendor_id,
	 parent_vendor_id
   from po_vendors pov
   start with
   EXISTS (select 1
           from po_vendors pv_np
           where pv_np.parent_vendor_id is NULL
           and pv_np.vendor_id = pov.parent_vendor_id)
   connect by parent_vendor_id = PRIOR vendor_id;

   l_rows_inserted := sql%rowcount;
   l_duration := sysdate - l_temp_date;

   edw_log.put_line('Inserted ' || to_char(nvl(l_rows_inserted, 0))||
         ' rows into the HIERARCHY table: EDW_PO_VENDOR_HIERARCHIES');
   edw_log.put_line('Process Time: ' || edw_log.duration(l_duration));
   edw_log.put_line(' ');

Exception When others then
   Errbuf := sqlerrm;
   Retcode := sqlcode;

   EDW_TRD_PARTNER_M_C.g_exception_message := Retcode || ':' || Errbuf;

   rollback;
   raise;

End populate_hierarchies;



   Procedure update_hierarchy5 (p_from_date  IN  DATE,
                                p_to_date    IN  DATE) IS

/**********************************************************************
 *                                                                    *
 * This procedure updates the PL/SQL table t_hierarchyTable.          *
 * It will move all vendors with 5 or more levels parents to the      *
 * 4th level, their new parents will be the parents of their (grand)  *
 * parents who have 4 levels parents originally.                      *
 *                                                                    *
 * Author: phu         Date: Sep 23, 2000                             *
 **********************************************************************/

    updated_flag  BOOLEAN;
    level         NUMBER;
    id            NUMBER;
    pid           NUMBER;
    v_pid         NUMBER;
    v_index       NUMBER;
    v_change      BOOLEAN;
    v_instance    VARCHAR2(30);

    TYPE t_hierarchyRecord IS RECORD (
      to_change         BOOLEAN,
      hierarchy_level   NUMBER,
      vendor_id         NUMBER,
      parent_vendor_id  NUMBER);

    TYPE t_hierarchyTable IS TABLE of t_hierarchyRecord
         INDEX BY BINARY_INTEGER;

    v_hierarchyTable t_hierarchyTable;

    CURSOR h4_cur IS
      SELECT hierarchy_level, vendor_id, parent_vendor_id
        FROM EDW_PO_VENDOR_HIERARCHIES_V
       WHERE hierarchy_level >= 4
         AND last_update_date between p_from_date and p_to_date
       ORDER BY hierarchy_level;

   BEGIN

     updated_flag := FALSE;

     /* Fill in the PL/SQL table v_hierarchyTable */
     FOR h4_rec IN h4_cur LOOP
       v_index := h4_rec.vendor_id;

       if h4_rec.hierarchy_level > 4 then
         v_hierarchyTable(v_index).to_change := TRUE;
       else
         v_hierarchyTable(v_index).to_change := FALSE;
       end if;

       v_hierarchyTable(v_index).hierarchy_level  := h4_rec.hierarchy_level;
       v_hierarchyTable(v_index).vendor_id        := h4_rec.vendor_id ;
       v_hierarchyTable(v_index).parent_vendor_id := h4_rec.parent_vendor_id;
     END LOOP;


     FOR h4_rec IN h4_cur LOOP

      IF h4_rec.hierarchy_level >= 5 THEN
        id    := h4_rec.vendor_id;
        pid   := h4_rec.parent_vendor_id;

        /* update this record in (PL/SQL) table v_hierarchyTable */

        v_hierarchyTable(id).parent_vendor_id := v_hierarchyTable(pid).parent_vendor_id;
        v_hierarchyTable(id).hierarchy_level := v_hierarchyTable(pid).hierarchy_level;

        /* set flag to TRUE indicating that the hierarchy is changed */
        updated_flag := TRUE;

       END IF;

      END LOOP;

      /* Now, update the staging table */
      IF updated_flag THEN

       select instance_code into v_instance
         from edw_local_instance;

       v_index := v_hierarchyTable.FIRST;

      LOOP
        v_change := v_hierarchyTable(v_index).to_change;
        id       := v_hierarchyTable(v_index).vendor_id;
        pid      := v_hierarchyTable(v_index).parent_vendor_id;

        IF v_change THEN

          UPDATE EDW_TPRT_TRADE_PARTNER_LSTG
             SET PARENT_TPARTNER_FK = pid ||'-'|| v_instance ||'-'|| 'SUPPLIER'
           WHERE TRADE_PARTNER_PK   = id  ||'-'|| v_instance ||'-'|| 'SUPPLIER';

        END IF;

        EXIT WHEN v_index = v_hierarchyTable.LAST;

        v_index := v_hierarchyTable.NEXT(v_index);
      END LOOP;

     END IF;

  EXCEPTION
    when others then
      edw_log.put_line('***Exceptions in update_hierarchy5 : ' ||
                         sqlerrm || ' ***');
      return;
  END update_hierarchy5;

---------------------------------------------------------------------------

-- ---------------------------------
-- PUBLIC PROCEDURES
-- ---------------------------------

Procedure Push_TPartner_Loc(Errbuf           out NOCOPY Varchar2,
               Retcode              out NOCOPY Varchar2,
               p_from_date          Date := NULL,
               p_to_date            Date := NULL) IS
 l_staging_table_name   Varchar2(30) := 'EDW_TPRT_TPARTNER_LOC_LSTG';
 l_push_date_range1     Date := NULL;
 l_push_date_range2     Date := NULL;
 l_temp_date            Date := NULL;
 l_rows_inserted        Number := 0;
 l_duration		Number := 0;
 l_exception_msg        Varchar2(2000) := Null;
 l_tmp_str1 		VARCHAR2(120) := NULL;


 --  -------------------------------------------
 --  Put any additional developer variables here
 --  -------------------------------------------

Begin

   Errbuf :=NULL;
   Retcode:=0;

l_push_date_range1 := p_from_date;
l_push_date_range2 := p_to_date;

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Pushing data for TP Location Staging Table...');

   l_temp_date := sysdate;

   l_tmp_str1 := EDW_COLLECTION_UTIL.get_lookup_value ('EDW_LEVEL_PUSH_DOWN',
		'EDW_TRD_PARTNER_M_TPLO');

   if (l_tmp_str1 IS NULL)  THEN
     edw_log.put_line('***Warning*** : No Look Code Found From GET_LEVEL_DP in Pushing TP Location');
   end if;

   Insert Into EDW_TPRT_TPARTNER_LOC_LSTG(
 	TPARTNER_LOC_PK,
	TRADE_PARTNER_FK,
	ADDRESS_LINE1,
	ADDRESS_LINE2,
	ADDRESS_LINE3,
	ADDRESS_LINE4,
	CITY,
	COUNTY,
	STATE,
	POSTAL_CODE,
	PROVINCE,
	COUNTRY,
	BUSINESS_TYPE,
	TPARTNER_LOC_DP,
	NAME,
	DATE_FROM,
	DATE_TO,
	VNDR_PURCH_SITE,
	VNDR_RFQ_ONLY,
	VNDR_PAY_SITE,
	VNDR_PAY_TERMS,
	CUST_SITE_USE,
	CUST_LOCATION,
	CUST_PRIMARY_FLAG,
	CUST_STATUS,
	CUST_ORIG_SYS_REF,
	CUST_SIC_CODE,
	CUST_PAY_TERMS,
	CUST_GSA_IND,
	CUST_SHIP_PARTIAL,
	CUST_SHIP_VIA,
	CUST_FOB_POINT,
	CUST_ORDER_TYPE,
	CUST_PRICE_LIST,
	CUST_FREIGHT,
	CUST_TERRITORY,
	CUST_TAX_REF,
	CUST_SORT_PRTY,
	CUST_TAX_CODE,
	CUST_DEMAND_CLASS,
	CUST_TAX_CLASSFN,
	CUST_TAX_HDR_FLAG,
	CUST_TAX_ROUND,
	CUST_SALES_REP,
	INSTANCE,
	USER_ATTRIBUTE1,
	USER_ATTRIBUTE2,
	USER_ATTRIBUTE3,
	USER_ATTRIBUTE4,
	USER_ATTRIBUTE5,
	OPERATION_CODE,
	COLLECTION_STATUS,
        LAST_UPDATE_DATE,
	LEVEL_NAME)
   select
        TPARTNER_LOC_PK,
	nvl(TRADE_PARTNER_FK, 'NA_EDW'),
	ADDRESS_LINE1,
	ADDRESS_LINE2,
	ADDRESS_LINE3,
	ADDRESS_LINE4,
	CITY,
	COUNTY,
	STATE,
	POSTAL_CODE,
	PROVINCE,
	COUNTRY,
	BUSINESS_TYPE,
        decode(UPPER(level_name),
          'TRADE PARTNER', l_tmp_str1 || ' (' || TPARTNER_LOC_DP || ')',
  	  TPARTNER_LOC_DP),
        decode(UPPER(level_name),
          'TRADE PARTNER', l_tmp_str1 || ' (' || NAME || ')',
          NAME),
	DATE_FROM,
	DATE_TO,
	VNDR_PURCH_SITE,
	VNDR_RFQ_ONLY,
	VNDR_PAY_SITE,
	VNDR_PAY_TERMS,
	CUST_SITE_USE,
	CUST_LOCATION,
	CUST_PRIMARY_FLAG,
	CUST_STATUS,
	CUST_ORIG_SYS_REF,
	CUST_SIC_CODE,
	CUST_PAY_TERMS,
	CUST_GSA_IND,
	CUST_SHIP_PARTIAL,
	CUST_SHIP_VIA,
	CUST_FOB_POINT,
	CUST_ORDER_TYPE,
	CUST_PRICE_LIST,
	CUST_FREIGHT,
	CUST_TERRITORY,
	CUST_TAX_REF,
	CUST_SORT_PRTY,
	CUST_TAX_CODE,
	CUST_DEMAND_CLASS,
	CUST_TAX_CLASSFN,
	CUST_TAX_HDR_FLAG,
	CUST_TAX_ROUND,
	CUST_SALES_REP,
	INSTANCE,
	USER_ATTRIBUTE1,
	USER_ATTRIBUTE2,
	USER_ATTRIBUTE3,
	USER_ATTRIBUTE4,
	USER_ATTRIBUTE5,
	NULL,
	'READY',
        LAST_UPDATE_DATE,
	LEVEL_NAME
   from EDW_TPRT_TPARTNER_LOC_LCV
   where last_update_date between l_push_date_range1 and l_push_date_range2;

   l_rows_inserted := sql%rowcount;
   l_duration := sysdate - l_temp_date;

   edw_log.put_line('Inserted ' || to_char(nvl(l_rows_inserted, 0))||
         ' rows into the staging table: ' || l_staging_table_name);
   edw_log.put_line('Process Time: ' || edw_log.duration(l_duration));
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

 EDW_TRD_PARTNER_M_C.g_row_count := EDW_TRD_PARTNER_M_C.g_row_count+l_rows_inserted;

 EDW_TRD_PARTNER_M_C.g_row_count_m := l_rows_inserted;

 Exception When others then
   Errbuf := sqlerrm;
   Retcode := sqlcode;

EDW_TRD_PARTNER_M_C.g_exception_message := Retcode || ':' || Errbuf;

   rollback;
   raise;

End Push_TPartner_Loc;




Procedure Push_Trade_Partner(Errbuf           out NOCOPY Varchar2,
               Retcode          out NOCOPY Varchar2,
               p_from_date          Date := NULL,
               p_to_date            Date := NULL) IS
 l_staging_table_name   Varchar2(30) := 'EDW_TPRT_TRADE_PARTNER_LSTG';
 l_push_date_range1     Date := NULL;
 l_push_date_range2     Date := NULL;
 l_temp_date            Date := NULL;
 l_rows_inserted        Number := 0;
 l_duration		Number := 0;
 l_exception_msg        Varchar2(2000) := Null;

 -- -------------------------------------------
 -- Put any additional developer variables here
 -- -------------------------------------------

Begin
   Errbuf :=NULL;
   Retcode:=0;


-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Pushing data for Trading Partner Staging Table...');

l_push_date_range1 := p_from_date;
l_push_date_range2 := p_to_date;

   l_temp_date := sysdate;
   Insert Into EDW_TPRT_TRADE_PARTNER_LSTG(
     ALTERNATE_NAME,
     CUST_ACCESS_TMPL,
     CUST_ANALYSIS_FY,
     CUST_CAT_CODE,
     CUST_CLASS,
     CUST_COMPETITOR,
     CUST_COTERM_DATE,
     CUST_DO_NOT_MAIL,
     CUST_FISCAL_END,
     CUST_FOB_POINT,
     CUST_FREIGHT,
     CUST_GSA_IND,
     CUST_KEY,
     CUST_NUMBER,
     CUST_NUM_EMP,
     CUST_ORDER_TYPE,
     CUST_ORIG_SYS,
     CUST_ORIG_SYS_REF,
     CUST_PRICE_LIST,
     CUST_PROSPECT,
     CUST_REF_USE_FLAG,
     CUST_REVENUE_CURR,
     CUST_REVENUE_NEXT,
     CUST_SALES_CHNL,
     CUST_SALES_REP,
     CUST_SHIP_PARTIAL,
     CUST_SHIP_VIA,
     CUST_STATUS,
     CUST_TAX_CODE,
     CUST_TAX_HDR_FLAG,
     CUST_TAX_ROUND,
     CUST_THIRD_PARTY,
     CUST_TYPE,
     CUST_YEAR_EST,
     END_ACTIVE_DATE,
     INSTANCE,
     LAST_UPDATE_DATE,
     NAME,
     PARENT_TPARTNER_FK,
     PAYMENT_TERMS,
     SIC_CODE,
     START_ACTIVE_DATE,
     TAXPAYER_ID,
     TAX_REG_NUM,
     TRADE_PARTNER_DP,
     TRADE_PARTNER_PK,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     VNDR_HOLD_FLAG,
     VNDR_INSPECT_REQ,
     VNDR_MINORITY_GRP,
     VNDR_NUMBER,
     VNDR_ONE_TIME,
     VNDR_RECEIPT_REQ,
     VNDR_SMALL_BUS,
     VNDR_SUB_RECEIPT,
     VNDR_TYPE,
     VNDR_UNORDER_RCV,
     VNDR_WOMEN_OWNED,
     OPERATION_CODE,
     COLLECTION_STATUS)
   select
     ALTERNATE_NAME,
     CUST_ACCESS_TMPL,
     CUST_ANALYSIS_FY,
     CUST_CAT_CODE,
     CUST_CLASS,
     CUST_COMPETITOR,
     CUST_COTERM_DATE,
     CUST_DO_NOT_MAIL,
     CUST_FISCAL_END,
     CUST_FOB_POINT,
     CUST_FREIGHT,
     CUST_GSA_IND,
     CUST_KEY,
     CUST_NUMBER,
     CUST_NUM_EMP,
     CUST_ORDER_TYPE,
     CUST_ORIG_SYS,
     CUST_ORIG_SYS_REF,
     CUST_PRICE_LIST,
     CUST_PROSPECT,
     CUST_REF_USE_FLAG,
     CUST_REVENUE_CURR,
     CUST_REVENUE_NEXT,
     CUST_SALES_CHNL,
     CUST_SALES_REP,
     CUST_SHIP_PARTIAL,
     CUST_SHIP_VIA,
     CUST_STATUS,
     CUST_TAX_CODE,
     CUST_TAX_HDR_FLAG,
     CUST_TAX_ROUND,
     CUST_THIRD_PARTY,
     CUST_TYPE,
     CUST_YEAR_EST,
     END_ACTIVE_DATE,
     INSTANCE,
     LAST_UPDATE_DATE,
     NAME,
     nvl(PARENT_TPARTNER_FK, 'NA_EDW'),
     PAYMENT_TERMS,
     SIC_CODE,
     START_ACTIVE_DATE,
     TAXPAYER_ID,
     TAX_REG_NUM,
     TRADE_PARTNER_DP,
     TRADE_PARTNER_PK,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     VNDR_HOLD_FLAG,
     VNDR_INSPECT_REQ,
     VNDR_MINORITY_GRP,
     VNDR_NUMBER,
     VNDR_ONE_TIME,
     VNDR_RECEIPT_REQ,
     VNDR_SMALL_BUS,
     VNDR_SUB_RECEIPT,
     VNDR_TYPE,
     VNDR_UNORDER_RCV,
     VNDR_WOMEN_OWNED,
     NULL, -- OPERATION_CODE
     'READY'
   from EDW_TPRT_TRADE_PARTNER_LCV
   where last_update_date between l_push_date_range1 and l_push_date_range2;

-------------------------------------------------------------------------
-- to populate the partent_tpartner_fk of vendors with >4 levels parents
--

    update_hierarchy5 (l_push_date_range1, l_push_date_range2);

--
-------------------------------------------------------------------------

   l_rows_inserted := sql%rowcount;
   l_duration := sysdate - l_temp_date;

   edw_log.put_line('Inserted '||to_char(nvl(l_rows_inserted,0))||
         ' rows into the staging table: ' || l_staging_table_name);
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

EDW_TRD_PARTNER_M_C.G_row_count :=EDW_TRD_PARTNER_M_C.G_row_count+l_rows_inserted;

 Exception When others then
   Errbuf := sqlerrm;
   Retcode := sqlcode;
   EDW_TRD_PARTNER_M_C.g_exception_message := Retcode || ':' || Errbuf;
   rollback;
   raise;

End Push_Trade_Partner;


Procedure Push_P1_TPartner(Errbuf           out NOCOPY Varchar2,
               Retcode          out NOCOPY Varchar2,
               p_from_date          Date := NULL,
               p_to_date            Date := NULL) IS
 l_staging_table_name   Varchar2(30) := 'EDW_TPRT_P1_TPARTNER_LSTG';
 l_push_date_range1     Date := NULL;
 l_push_date_range2     Date := NULL;
 l_temp_date            Date := NULL;
 l_rows_inserted        Number := 0;
 l_duration		Number := 0;
 l_exception_msg        Varchar2(2000) := Null;

 -- -------------------------------------------
 -- Put any additional developer variables here
 -- -------------------------------------------

Begin
   Errbuf :=NULL;
   Retcode:=0;


-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

l_push_date_range1 := p_from_date;
l_push_date_range2 := p_to_date;

   edw_log.put_line(' ');
   edw_log.put_line('Pushing data for TP Parent 1 Staging Table...');

   l_temp_date := sysdate;
   Insert Into EDW_TPRT_P1_TPARTNER_LSTG(
     ALLOW_SUB_RECEIPT,
     ALLOW_UNORDER_RCV,
     ALTERNATE_NAME,
     END_ACTIVE_DATE,
     HOLD_FLAG,
     INSPECT_REQUIRED,
     INSTANCE,
     LAST_UPDATE_DATE,
     MINORITY_GROUP,
     NAME,
     ONE_TIME_FLAG,
     PARENT_TPARTNER_FK,
     PAYMENT_TERMS,
     RECEIPT_REQUIRED,
     SIC_CODE,
     SMALL_BUSINESS,
     START_ACTIVE_DATE,
     TAXPAYER_ID,
     TAX_REG_NUM,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     TPARTNER_DP,
     VENDOR_NUMBER,
     TPARTNER_PK,
     VENDOR_TYPE,
     WOMEN_OWNED,
     OPERATION_CODE,
     COLLECTION_STATUS)
   select
     ALLOW_SUB_RECEIPT,
     ALLOW_UNORDER_RCV,
     ALTERNATE_NAME,
     END_ACTIVE_DATE,
     HOLD_FLAG,
     INSPECT_REQUIRED,
     INSTANCE,
     LAST_UPDATE_DATE,
     MINORITY_GROUP,
     NAME,
     ONE_TIME_FLAG,
     nvl(PARENT_TPARTNER_FK, 'NA_EDW'),
     PAYMENT_TERMS,
     RECEIPT_REQUIRED,
     SIC_CODE,
     SMALL_BUSINESS,
     START_ACTIVE_DATE,
     TAXPAYER_ID,
     TAX_REG_NUM,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     TPARTNER_DP,
     VENDOR_NUMBER,
     TPARTNER_PK,
     VENDOR_TYPE,
     WOMEN_OWNED,
     NULL, -- OPERATION_CODE
     'READY'
   from EDW_TPRT_P1_TPARTNER_LCV
   where last_update_date between l_push_date_range1 and l_push_date_range2;

   l_rows_inserted := sql%rowcount;
   l_duration := sysdate - l_temp_date;

   edw_log.put_line('Inserted '||to_char(nvl(l_rows_inserted,0))||
         ' rows into the staging table: ' || l_staging_table_name);
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

   EDW_TRD_PARTNER_M_C.G_row_count:=EDW_TRD_PARTNER_M_C.G_row_count+l_rows_inserted;

 Exception When others then
   Errbuf := sqlerrm;
   Retcode := sqlcode;
   EDW_TRD_PARTNER_M_C.g_exception_message := Retcode || ':' || Errbuf;
   rollback;
   raise;

End Push_P1_TPartner;


Procedure Push_P2_TPartner(Errbuf           out NOCOPY Varchar2,
               Retcode          out NOCOPY Varchar2,
               p_from_date          Date := NULL,
               p_to_date            Date := NULL) IS
 l_staging_table_name   Varchar2(30) := 'EDW_TPRT_P2_TPARTNER_LSTG';
 l_push_date_range1     Date := NULL;
 l_push_date_range2     Date := NULL;
 l_temp_date            Date := NULL;
 l_rows_inserted        Number := 0;
 l_duration		Number := 0;
 l_exception_msg        Varchar2(2000) := Null;

 -- -------------------------------------------
 -- Put any additional developer variables here
 -- -------------------------------------------

Begin
   Errbuf :=NULL;
   Retcode:=0;

l_push_date_range1 := p_from_date;
l_push_date_range2 := p_to_date;

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Pushing data for TP Parent 2 Staging Table...');

   l_temp_date := sysdate;
   Insert Into EDW_TPRT_P2_TPARTNER_LSTG(
     ALLOW_SUB_RECEIPT,
     ALLOW_UNORDER_RCV,
     ALTERNATE_NAME,
     END_ACTIVE_DATE,
     HOLD_FLAG,
     INSPECT_REQUIRED,
     INSTANCE,
     LAST_UPDATE_DATE,
     MINORITY_GROUP,
     NAME,
     ONE_TIME_FLAG,
     PARENT_TPARTNER_FK,
     PAYMENT_TERMS,
     RECEIPT_REQUIRED,
     SIC_CODE,
     SMALL_BUSINESS,
     START_ACTIVE_DATE,
     TAXPAYER_ID,
     TAX_REG_NUM,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     TPARTNER_DP,
     VENDOR_NUMBER,
     TPARTNER_PK,
     VENDOR_TYPE,
     WOMEN_OWNED,
     OPERATION_CODE,
     COLLECTION_STATUS)
   select
     ALLOW_SUB_RECEIPT,
     ALLOW_UNORDER_RCV,
     ALTERNATE_NAME,
     END_ACTIVE_DATE,
     HOLD_FLAG,
     INSPECT_REQUIRED,
     INSTANCE,
     LAST_UPDATE_DATE,
     MINORITY_GROUP,
     NAME,
     ONE_TIME_FLAG,
     nvl(PARENT_TPARTNER_FK, 'NA_EDW'),
     PAYMENT_TERMS,
     RECEIPT_REQUIRED,
     SIC_CODE,
     SMALL_BUSINESS,
     START_ACTIVE_DATE,
     TAXPAYER_ID,
     TAX_REG_NUM,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     TPARTNER_DP,
     VENDOR_NUMBER,
     TPARTNER_PK,
     VENDOR_TYPE,
     WOMEN_OWNED,
     NULL, -- OPERATION_CODE
     'READY'
   from EDW_TPRT_P2_TPARTNER_LCV
   where last_update_date between l_push_date_range1 and l_push_date_range2;

   l_rows_inserted := sql%rowcount;
   l_duration := sysdate - l_temp_date;

   edw_log.put_line('Inserted '||to_char(nvl(l_rows_inserted,0))||
         ' rows into the staging table: ' || l_staging_table_name);
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------
   EDW_TRD_PARTNER_M_C.G_row_count:=EDW_TRD_PARTNER_M_C.G_row_count+l_rows_inserted;

 Exception When others then
   Errbuf := sqlerrm;
   Retcode := sqlcode;
   EDW_TRD_PARTNER_M_C.g_exception_message := Retcode || ':' || Errbuf;
   rollback;
   raise;


End Push_P2_TPartner;


Procedure Push_P3_TPartner(Errbuf           out NOCOPY Varchar2,
               Retcode          out NOCOPY Varchar2,
               p_from_date          Date := NULL,
               p_to_date            Date := NULL) IS
 l_staging_table_name   Varchar2(30) := 'EDW_TPRT_P3_TPARTNER_LSTG';
 l_push_date_range1     Date := NULL;
 l_push_date_range2     Date := NULL;
 l_temp_date            Date := NULL;
 l_rows_inserted        Number := 0;
 l_duration		Number := 0;
 l_exception_msg        Varchar2(2000) := Null;

 -- -------------------------------------------
 -- Put any additional developer variables here
 -- -------------------------------------------

Begin
   Errbuf :=NULL;
   Retcode:=0;

l_push_date_range1 := p_from_date;
l_push_date_range2 := p_to_date;

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Pushing data for TP Parent 3 Staging Table...');

   l_temp_date := sysdate;
   Insert Into EDW_TPRT_P3_TPARTNER_LSTG(
     ALLOW_SUB_RECEIPT,
     ALLOW_UNORDER_RCV,
     ALTERNATE_NAME,
     END_ACTIVE_DATE,
     HOLD_FLAG,
     INSPECT_REQUIRED,
     INSTANCE,
     LAST_UPDATE_DATE,
     MINORITY_GROUP,
     NAME,
     ONE_TIME_FLAG,
     PARENT_TPARTNER_FK,
     PAYMENT_TERMS,
     RECEIPT_REQUIRED,
     SIC_CODE,
     SMALL_BUSINESS,
     START_ACTIVE_DATE,
     TAXPAYER_ID,
     TAX_REG_NUM,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     TPARTNER_DP,
     VENDOR_NUMBER,
     TPARTNER_PK,
     VENDOR_TYPE,
     WOMEN_OWNED,
     OPERATION_CODE,
     COLLECTION_STATUS)
   select
     ALLOW_SUB_RECEIPT,
     ALLOW_UNORDER_RCV,
     ALTERNATE_NAME,
     END_ACTIVE_DATE,
     HOLD_FLAG,
     INSPECT_REQUIRED,
     INSTANCE,
     LAST_UPDATE_DATE,
     MINORITY_GROUP,
     NAME,
     ONE_TIME_FLAG,
     nvl(PARENT_TPARTNER_FK, 'NA_EDW'),
     PAYMENT_TERMS,
     RECEIPT_REQUIRED,
     SIC_CODE,
     SMALL_BUSINESS,
     START_ACTIVE_DATE,
     TAXPAYER_ID,
     TAX_REG_NUM,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     TPARTNER_DP,
     VENDOR_NUMBER,
     TPARTNER_PK,
     VENDOR_TYPE,
     WOMEN_OWNED,
     NULL, -- OPERATION_CODE
     'READY'
   from EDW_TPRT_P3_TPARTNER_LCV
   where last_update_date between l_push_date_range1 and l_push_date_range2;


   l_rows_inserted := sql%rowcount;
   l_duration := sysdate - l_temp_date;

   edw_log.put_line('Inserted '||to_char(nvl(l_rows_inserted, 0))||
         ' rows into the staging table: ' || l_staging_table_name);
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------
   EDW_TRD_PARTNER_M_C.G_row_count:=EDW_TRD_PARTNER_M_C.G_row_count+l_rows_inserted;

 Exception When others then
   Errbuf := sqlerrm;
   Retcode := sqlcode;
   EDW_TRD_PARTNER_M_C.g_exception_message:=Retcode || ':' || Errbuf;
   rollback;
   raise;


End Push_P3_TPartner;


Procedure Push_P4_TPartner(Errbuf           out NOCOPY Varchar2,
               Retcode          out NOCOPY Varchar2,
               p_from_date          Date := NULL,
               p_to_date            Date := NULL) IS
 l_staging_table_name   Varchar2(30) := 'EDW_TPRT_P4_TPARTNER_LSTG';
 l_push_date_range1     Date := NULL;
 l_push_date_range2     Date := NULL;
 l_temp_date            Date := NULL;
 l_rows_inserted        Number := 0;
 l_duration		Number := 0;
 l_exception_msg        Varchar2(2000) := Null;

 -- -------------------------------------------
 -- Put any additional developer variables here
 -- -------------------------------------------

Begin
   Errbuf :=NULL;
   Retcode:=0;

l_push_date_range1 := p_from_date;
l_push_date_range2 := p_to_date;

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Pushing data for TP Parent 4 Staging Table...');

   l_temp_date := sysdate;
   Insert Into EDW_TPRT_P4_TPARTNER_LSTG(
     ALLOW_SUB_RECEIPT,
     ALLOW_UNORDER_RCV,
     PARENT_TPARTNER_FK,
     ALTERNATE_NAME,
     END_ACTIVE_DATE,
     HOLD_FLAG,
     INSPECT_REQUIRED,
     INSTANCE,
     LAST_UPDATE_DATE,
     MINORITY_GROUP,
     NAME,
     ONE_TIME_FLAG,
     PAYMENT_TERMS,
     RECEIPT_REQUIRED,
     SIC_CODE,
     SMALL_BUSINESS,
     START_ACTIVE_DATE,
     TAXPAYER_ID,
     TAX_REG_NUM,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     TPARTNER_DP,
     VENDOR_NUMBER,
     TPARTNER_PK,
     VENDOR_TYPE,
     WOMEN_OWNED,
     OPERATION_CODE,
     COLLECTION_STATUS)
   select
     ALLOW_SUB_RECEIPT,
     ALLOW_UNORDER_RCV,
     nvl(PARENT_TPARTNER_FK, 'NA_EDW'),
     ALTERNATE_NAME,
     END_ACTIVE_DATE,
     HOLD_FLAG,
     INSPECT_REQUIRED,
     INSTANCE,
     LAST_UPDATE_DATE,
     MINORITY_GROUP,
     NAME,
     ONE_TIME_FLAG,
     PAYMENT_TERMS,
     RECEIPT_REQUIRED,
     SIC_CODE,
     SMALL_BUSINESS,
     START_ACTIVE_DATE,
     TAXPAYER_ID,
     TAX_REG_NUM,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     TPARTNER_DP,
     VENDOR_NUMBER,
     TPARTNER_PK,
     VENDOR_TYPE,
     WOMEN_OWNED,
     NULL, -- OPERATION_CODE
     'READY'
   from EDW_TPRT_P4_TPARTNER_LCV
   where last_update_date between l_push_date_range1 and l_push_date_range2;

   l_rows_inserted := sql%rowcount;
   l_duration := sysdate - l_temp_date;

   edw_log.put_line('Inserted '||to_char(nvl(l_rows_inserted,0))||
         ' rows into the staging table: ' || l_staging_table_name);
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------
   EDW_TRD_PARTNER_M_C.G_row_count:=EDW_TRD_PARTNER_M_C.G_row_count+l_rows_inserted;
 Exception When others then
   Errbuf := sqlerrm;
   Retcode := sqlcode;
   EDW_TRD_PARTNER_M_C.g_exception_message:= Retcode || ':' || Errbuf;
   rollback;
   raise;


End Push_P4_TPartner;


Procedure push( Errbuf           out NOCOPY Varchar2,
                Retcode          out NOCOPY Varchar2,
                p_from_date      IN Varchar2,
                p_to_date        IN Varchar2) IS
L_PUSH_DATE_RANGE1	Date:=NULL;
L_PUSH_DATE_RANGE2	Date:=NULL;
l_proc_name		varchar2(60);

 l_from_date            date;
 l_to_date              date;

Begin

   Errbuf := NULL;
   Retcode := 0;

IF (Not EDW_COLLECTION_UTIL.setup('EDW_TRD_PARTNER_M')) THEN
    errbuf := fnd_message.get;
    RAISE_APPLICATION_ERROR (-20000, 'Error in SETUP: ' || errbuf);
END IF;

  fnd_date.initialize('YYYY/MM/DD', 'YYYY/MM/DD HH24:MI:SS');

  l_from_date := fnd_date.displayDT_to_date(p_from_date);
  l_to_date := fnd_date.displayDT_to_date(p_to_date);

L_PUSH_DATE_RANGE1 := nvl (l_from_date,
  EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);
L_PUSH_DATE_RANGE2 := nvl(l_to_date,EDW_COLLECTION_UTIL.G_local_curr_push_start_date);
edw_log.put_line('The collection range is from ' ||
  to_char(l_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to ' ||
  to_char(l_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));
edw_log.put_line(' ');


   l_proc_name := 'EDW_TRD_PARTNER_M_C.populate_hierarchies';
   EDW_TRD_PARTNER_M_C.populate_hierarchies(L_PUSH_DATE_RANGE1,L_PUSH_DATE_RANGE2);

   l_proc_name := 'EDW_TRD_PARTNER_M_C.Push_TPartner_Loc';
   EDW_TRD_PARTNER_M_C.Push_TPartner_Loc(Errbuf,
               Retcode,
               L_PUSH_DATE_RANGE1,
               L_PUSH_DATE_RANGE2);
   l_proc_name := 'EDW_TRD_PARTNER_M_C.Push_Trade_Partner';
   EDW_TRD_PARTNER_M_C.Push_Trade_Partner(Errbuf,
                Retcode,
                L_PUSH_DATE_RANGE1,
		L_PUSH_DATE_RANGE2);
   l_proc_name := 'EDW_TRD_PARTNER_M_C.Push_P1_TPartner';
   EDW_TRD_PARTNER_M_C.Push_P1_TPartner(Errbuf,
                Retcode,
                L_PUSH_DATE_RANGE1,
		L_PUSH_DATE_RANGE2);
   l_proc_name := 'EDW_TRD_PARTNER_M_C.Push_P2_TPartner';
   EDW_TRD_PARTNER_M_C.Push_P2_TPartner(Errbuf,
                Retcode,
                L_PUSH_DATE_RANGE1,
		L_PUSH_DATE_RANGE2);
   l_proc_name := 'EDW_TRD_PARTNER_M_C.Push_P3_TPartner';
   EDW_TRD_PARTNER_M_C.Push_P3_TPartner(Errbuf,
                Retcode,
                L_PUSH_DATE_RANGE1,
 		L_PUSH_DATE_RANGE2);
   l_proc_name := 'EDW_TRD_PARTNER_M_C.Push_P4_TPartner';
   EDW_TRD_PARTNER_M_C.Push_P4_TPartner(Errbuf,
                Retcode,
                L_PUSH_DATE_RANGE1,
		L_PUSH_DATE_RANGE2);

 EDW_COLLECTION_UTIL.wrapup(TRUE, EDW_TRD_PARTNER_M_C.g_row_count_m,
        EDW_TRD_PARTNER_M_C.g_exception_message,
        L_PUSH_DATE_RANGE1, L_PUSH_DATE_RANGE2);


Exception When others then
   Errbuf := sqlerrm;
   Retcode := sqlcode;


EDW_TRD_PARTNER_M_C.g_exception_message :=
  EDW_TRD_PARTNER_M_C.g_exception_message || ' <> ' || Retcode ||
  ' : ' || Errbuf;

EDW_COLLECTION_UTIL.wrapup(FALSE,0,EDW_TRD_PARTNER_M_C.g_exception_message,
                              l_push_date_range1, l_push_date_range2);

FND_FILE.PUT_LINE(FND_FILE.LOG, l_proc_name || ' failed');

raise;

End push;

End EDW_TRD_PARTNER_M_C;

/
