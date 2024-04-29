--------------------------------------------------------
--  DDL for Package Body OPI_DBI_COGS_OPM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_COGS_OPM_PKG" AS
/* $Header: OPIDECOGSPB.pls 115.4 2004/06/22 06:01:39 sberi noship $ */

OPI_SOURCE CONSTANT NUMBER := 1;
OPM_SOURCE CONSTANT NUMBER := 2;

INCLUDE_FOR_TURNS CONSTANT NUMBER := 1;
DO_NOT_INCLUDE_FOR_TURNS CONSTANT NUMBER := 2;

g_cogs_error        BOOLEAN := FALSE;
g_cogs_rate_error   EXCEPTION;

g_login_id    NUMBER;
g_user_id     NUMBER;
g_sysdate  date;
g_global_rate_type   varchar2(15);
GLOBAL_CURRENCY_CODE varchar2(10);
g_opi_schema      VARCHAR2(30);
g_opi_status      VARCHAR2(30);
g_opi_industry    VARCHAR2(30);

global_start_date DATE;

PROCEDURE check_setup_globals(errbuf IN OUT NOCOPY  VARCHAR2 , retcode IN OUT NOCOPY  VARCHAR2) IS

   l_list dbms_sql.varchar2_table;

   l_from_date  DATE;
   l_to_date    DATE;
   l_missing_day_flag BOOLEAN := FALSE;
   l_err_num    NUMBER;
   l_err_msg    VARCHAR2(255);
   l_min_miss_date DATE;
   l_max_miss_date DATE;

   l_inception_date DATE;
BEGIN

   retcode   := 0;
   l_list(1) := 'BIS_PRIMARY_CURRENCY_CODE';
   l_list(2) := 'BIS_GLOBAL_START_DATE';

   IF (bis_common_parameters.check_global_parameters(l_list)) THEN
      g_login_id := fnd_global.login_id;
      g_user_id  := fnd_global.user_id;
      global_start_date := Trunc(bis_common_parameters.get_global_start_date);
      global_currency_code := bis_common_parameters.get_currency_code;

      if (g_global_rate_type is null)
        then g_global_rate_type := bis_common_parameters.get_rate_type;
      end if;

      g_sysdate := sysdate;

      if not fnd_installation.get_app_info (application_short_name => 'OPI',
                                                            status => g_opi_status,
                                                          industry => g_opi_industry,
                                                     oracle_schema => g_opi_schema)
        then
          RAISE_APPLICATION_ERROR(-20000, errbuf);
       END IF;


      SELECT NVL(MIN(from_date), global_start_date) INTO l_from_date
	FROM (SELECT tst.gl_trans_date from_date
	      FROM opi_dbi_cogs_run_log l,
	      gl_subr_tst tst
	      WHERE l.source = OPM_SOURCE
	      AND tst.subledger_id  = l.start_txn_id
              UNION
            SELECT tst.gl_trans_date from_date
	      FROM opi_dbi_cogs_run_log l,
	      gl_subr_led tst
	      WHERE l.source = OPM_SOURCE
	      AND tst.subledger_id  = l.start_txn_id
	      );

      l_to_date  := sysdate;



      -- check_missing_date

      fii_time_api.check_missing_date( l_from_date, l_to_date, l_missing_day_flag,
				       l_min_miss_date, l_max_miss_date);

      IF l_missing_day_flag THEN
	 retcode := 1;
	 errbuf  := 'Please check log file for details. ';
	 BIS_COLLECTION_UTILITIES.PUT_LINE('There are missing dates in Time Dimension.');

	 BIS_COLLECTION_UTILITIES.PUT_LINE('The range is from ' || l_min_miss_date
					   ||' to ' || l_max_miss_date );
      END IF;
    ELSE
      retcode := 1;
      errbuf  := 'Please check log file for details. ';
      BIS_COLLECTION_UTILITIES.PUT_LINE('Global Parameters are not setup.');

      BIS_COLLECTION_UTILITIES.PUT_LINE('Please check that the profile options: BIS_PRIMARY_CURRENCY_CODE and BIS_GLOBAL_START_DATE are setup.');

   END  IF;

EXCEPTION
   WHEN OTHERS THEN
      retcode := 1;
      l_err_num := SQLCODE;
      l_err_msg := 'ERROR in OPI_DBI_OPM_COGS_PKG.CHECK_SETUP_GLOBALS '
	|| substr(SQLERRM, 1,200);

      BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  to_char(l_err_num));
      BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || l_err_msg);

END check_setup_globals;

-- return 0 -- normal
-- return -1 -- missing rate found



PROCEDURE refresh_opm_subl_org_cogs(
  				     p_last_id         IN         NUMBER,
				     p_newest_id       IN         NUMBER,
				     x_status          OUT NOCOPY NUMBER,
				     x_msg             OUT NOCOPY VARCHAR2 ) IS

  l_stmt NUMBER := 0;


BEGIN
     bis_collection_utilities.put_line('Load incremental OPM Test Subr cogs into stg '
                        || To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

   -- Regular sales order
   insert into opi_dbi_cogs_fstg
   (
    INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,TOP_MODEL_LINE_ID
    ,TOP_MODEL_ITEM_ID
    ,TOP_MODEL_ITEM_UOM
    ,TOP_MODEL_ORG_ID
    ,CUSTOMER_ID
    ,COGS_VAL_B
    ,COGS_DATE
    ,SOURCE
    ,TURNS_COGS_FLAG
   )
    select
     INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,ORDER_LINE_ID
    ,INVENTORY_ITEM_ID
    ,TOP_MODEL_ITEM_UOM
    ,ORGANIZATION_ID
    ,SOLD_TO_ORG_ID
    ,sum(COGS_VAL_B)
    ,max(COGS_DATE)
    ,SOURCE
    ,TURNS_COGS_FLAG
    from
     (     select /*+ leading(whse) use_nl(msi,cust_acct) */
             lines.inventory_item_id INVENTORY_ITEM_ID,
             whse.mtl_organization_id ORGANIZATION_ID,
             tran.oe_order_line_id ORDER_LINE_ID,
             msi.primary_uom_code TOP_MODEL_ITEM_UOM,
             tran.cogs_val_b COGS_VAL_B,
             trunc(tran.gl_trans_date) COGS_DATE,
             nvl(cust_acct.party_id, -1) SOLD_TO_ORG_ID,
             Decode(lines.source_type_code, 'EXTERNAL', DO_NOT_INCLUDE_FOR_TURNS,INCLUDE_FOR_TURNS) TURNS_COGS_FLAG,
             OPM_SOURCE                   SOURCE
        from oe_order_lines_all lines,
             hz_cust_accounts cust_acct,
             ic_whse_mst whse,
             mtl_system_items_b msi,
             (select /*+ leading(tst) index(tran,IC_TRAN_PNDI2) use_nl(tran) */ rcv.oe_order_line_id  oe_order_line_id,
                     tran.line_id,
                     tran.orgn_code,
                     tran.whse_code,
                     tst.gl_trans_date,
                     avg(tst.cogs_val_b) COGS_VAL_B
                from ic_tran_pnd tran,
                     rcv_transactions rcv,
                     (select /*+index(tst,gl_subr_tst_n2) */
		             tst.line_id, tst.doc_type, tst.gl_trans_date,
                             sum(tst.debit_credit_sign*tst.amount_base) COGS_VAL_B
                       from gl_subr_tst tst
                      where tst.doc_type = 'PORC'
                        and tst.acct_ttl_type = 5200
                        and tst.gl_trans_date >= global_start_date
                   group by tst.line_id, tst.doc_type, tst.gl_trans_date) tst
                where tran.completed_ind = 1
                  and tran.gl_posted_ind = 0
                  and tran.line_id = rcv.transaction_id
                  and rcv.oe_order_line_id is NOT NULL
                  and tran.doc_type = tst.doc_type
                  and tran.line_id  = tst.line_id
             group by rcv.oe_order_line_id, tran.line_id, tran.orgn_code, tran.whse_code, tst.gl_trans_date
            union all
              select /*+ leading(tst) index(tran,IC_TRAN_PNDI2) use_nl(tran) */ tran.line_id oe_order_line_id,
                     tran.line_id,
                     tran.orgn_code,
                     tran.whse_code,
                     tst.gl_trans_date,
                     avg(tst.cogs_val_b) COGS_VAL_B
                from ic_tran_pnd tran,
                      (select /*+index(tst,gl_subr_tst_n2) */
		              tst.line_id, tst.doc_type, tst.gl_trans_date,
                              sum(tst.debit_credit_sign*tst.amount_base) COGS_VAL_B
                         from gl_subr_tst tst
                        where tst.doc_type = 'OMSO'
                          and tst.acct_ttl_type = 5200
                          and tst.gl_trans_date >= global_start_date
                     group by tst.line_id, tst.doc_type, tst.gl_trans_date) tst
               where tran.completed_ind = 1
                 and tran.gl_posted_ind = 0
                 and tran.doc_type = tst.doc_type
                 and tran.line_id  = tst.line_id
            group by tran.line_id, tran.line_id, tran.orgn_code, tran.whse_code, tst.gl_trans_date)  tran
where lines.line_id = tran.oe_order_line_id
  and lines.sold_to_org_id = cust_acct.cust_account_id(+)
  and whse.whse_code = tran.whse_code
  and msi.inventory_item_id=lines.inventory_item_id
  and msi.organization_id=lines.ship_from_org_id)
group by
     INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,TOP_MODEL_ITEM_UOM
    ,SOLD_TO_ORG_ID
    ,ORDER_LINE_ID
    ,TURNS_COGS_FLAG
    ,SOURCE ;

commit;
     bis_collection_utilities.put_line('Load incremental OPM Final Subr cogs into stg '
                        || To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

   insert into opi_dbi_cogs_fstg
   (
     INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,TOP_MODEL_LINE_ID
    ,TOP_MODEL_ITEM_ID
    ,TOP_MODEL_ITEM_UOM
    ,TOP_MODEL_ORG_ID
    ,CUSTOMER_ID
    ,COGS_VAL_B
    ,COGS_DATE
    ,SOURCE
    ,TURNS_COGS_FLAG
   )
    select
     INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,ORDER_LINE_ID
    ,INVENTORY_ITEM_ID
    ,TOP_MODEL_ITEM_UOM
    ,ORGANIZATION_ID
    ,SOLD_TO_ORG_ID
    ,sum(COGS_VAL_B)
    ,max(COGS_DATE)
    ,SOURCE
    ,TURNS_COGS_FLAG
    from
     (         select /*+ index(cust_acct, HZ_CUST_ACCOUNTS_U1) use_nl(cust_acct) */
                 lines.inventory_item_id INVENTORY_ITEM_ID,
                 whse.mtl_organization_id ORGANIZATION_ID,
                 tran.oe_order_line_id ORDER_LINE_ID,
                 msi.primary_uom_code TOP_MODEL_ITEM_UOM,
                 tran.cogs_val_b COGS_VAL_B,
                 trunc(tran.gl_trans_date) COGS_DATE,
                 nvl(cust_acct.party_id, -1) SOLD_TO_ORG_ID,
                 Decode(lines.source_type_code, 'EXTERNAL', DO_NOT_INCLUDE_FOR_TURNS,INCLUDE_FOR_TURNS) TURNS_COGS_FLAG,
                 OPM_SOURCE                    SOURCE
            from oe_order_lines_all     lines,
                 hz_cust_accounts       cust_acct,
                 ic_whse_mst            whse,
                 mtl_system_items_b     msi,
                 (select
		         rcv.oe_order_line_id  oe_order_line_id,
                         tran.line_id,
                         tran.orgn_code,
                         tran.whse_code,
                         tst.gl_trans_date,
                         avg(tst.cogs_val_b) COGS_VAL_B
                    from ic_tran_pnd tran,
                         rcv_transactions rcv,
                         (select /*+ index(tst,GL_SUBR_LED_PK) */
			         tst.line_id, tst.doc_type, tst.gl_trans_date,
                                 sum(tst.debit_credit_sign*tst.amount_base) COGS_VAL_B
                             from gl_subr_led tst
                            where tst.doc_type = 'PORC'
                              and tst.acct_ttl_type = 5200
                              and tst.subledger_id between   p_last_id and p_newest_id
			      and tst.GL_TRANS_DATE  >= global_start_date
                            group by tst.line_id, tst.doc_type, tst.gl_trans_date
                           ) tst
                     where tran.completed_ind = 1
                       and tran.gl_posted_ind = 1
                       and tran.line_id = rcv.transaction_id
                       and rcv.oe_order_line_id is NOT NULL
                       and tran.doc_type = tst.doc_type
                       and tran.line_id  = tst.line_id
                     group by rcv.oe_order_line_id, tran.line_id, tran.orgn_code, tran.whse_code, tst.gl_trans_date
                    union all
                      select
		            tran.line_id oe_order_line_id,
                            tran.line_id,
                            tran.orgn_code,
                            tran.whse_code,
                            tst.gl_trans_date,
                            avg(tst.cogs_val_b) COGS_VAL_B
                     from ic_tran_pnd tran,
                          (select /*+ index(tst,GL_SUBR_LED_PK) */
			          tst.line_id, tst.doc_type, tst.gl_trans_date,
                                  sum(tst.debit_credit_sign*tst.amount_base) COGS_VAL_B
                             from gl_subr_led tst
                            where tst.doc_type = 'OMSO'
                              and tst.acct_ttl_type = 5200
                              and tst.subledger_id between   p_last_id and p_newest_id
			      and tst.GL_TRANS_DATE  >= global_start_date
                            group by tst.line_id, tst.doc_type, tst.gl_trans_date
                           ) tst
                     where tran.completed_ind = 1
                       and tran.gl_posted_ind = 1
                       and tran.doc_type = tst.doc_type
                       and tran.line_id  = tst.line_id
                     group by tran.line_id, tran.line_id, tran.orgn_code, tran.whse_code, tst.gl_trans_date
                     )  tran
               where lines.line_id = tran.oe_order_line_id
                 and lines.sold_to_org_id = cust_acct.cust_account_id(+)
                 and whse.whse_code = tran.whse_code
                 and msi.inventory_item_id=lines.inventory_item_id
                 and msi.organization_id=lines.ship_from_org_id
            )
   group by
     INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,TOP_MODEL_ITEM_UOM
    ,SOLD_TO_ORG_ID
    ,ORDER_LINE_ID
    ,TURNS_COGS_FLAG
    ,SOURCE ;

   l_stmt := 1;

   fnd_stats.gather_table_stats( ownname => g_opi_schema,
                                 tabname => 'OPI_DBI_COGS_FSTG',
                                 percent => 10);



   x_status := 1; -- complete successfully
   x_msg  := NULL;
EXCEPTION WHEN OTHERS THEN
   ROLLBACK;

   BIS_COLLECTION_UTILITIES.PUT_LINE(' Error in Refresh_opm_subl_org_cogs at statement  ' || l_stmt);
   BIS_COLLECTION_UTILITIES.PUT_LINE( Sqlerrm );
   BIS_COLLECTION_UTILITIES.PUT_LINE(' Error in Refresh_opm_subl_org_cogs at statement  ' || l_stmt);
   BIS_COLLECTION_UTILITIES.PUT_LINE( Sqlerrm );
   x_status := 0; -- error
   x_msg := Sqlerrm;

END refresh_opm_subl_org_cogs;


PROCEDURE initial_opm_subl_org_cogs(
  				     p_last_id         IN          NUMBER,
				     p_newest_id       IN          NUMBER,
				     x_status          OUT NOCOPY  NUMBER,
				     x_msg             OUT NOCOPY VARCHAR2,
                                     p_degree          IN    NUMBER  ) IS

  l_stmt NUMBER := 0;

BEGIN
   bis_collection_utilities.put_line('Load OPM Test Subr cogs into stg '
                        || To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));


   -- Regular sales order
   insert /*+ append parallel(opi_dbi_cogs_fstg) */ into opi_dbi_cogs_fstg
   (
     INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,TOP_MODEL_LINE_ID
    ,TOP_MODEL_ITEM_ID
    ,TOP_MODEL_ITEM_UOM
    ,TOP_MODEL_ORG_ID
    ,CUSTOMER_ID
    ,COGS_VAL_B
    ,COGS_DATE
    ,SOURCE
    ,TURNS_COGS_FLAG
   )
    select
     INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,ORDER_LINE_ID
    ,INVENTORY_ITEM_ID
    ,TOP_MODEL_ITEM_UOM
    ,ORGANIZATION_ID
    ,SOLD_TO_ORG_ID
    ,COGS_VAL_B
    ,COGS_DATE
    ,SOURCE
    ,TURNS_COGS_FLAG
    from
      (
          select
             INVENTORY_ITEM_ID
            ,ORGANIZATION_ID
            ,ORDER_LINE_ID
	    ,TOP_MODEL_ITEM_UOM
            ,SOLD_TO_ORG_ID
            ,sum(COGS_VAL_B)       COGS_VAL_B
            ,max(COGS_DATE)        COGS_DATE
            ,TURNS_COGS_FLAG
            ,SOURCE
         from
              (  select /*+ use_hash(whse,lines,cust_acct,msi) parallel(tst) parallel(lines) parallel(cust_acct) parallel(msi) parallel(whse)  */
                   lines.inventory_item_id                                                          INVENTORY_ITEM_ID      ,
                   whse.mtl_organization_id                                                         ORGANIZATION_ID        ,
                   tran.oe_order_line_id                                                            ORDER_LINE_ID          ,
                   msi.primary_uom_code                                                             TOP_MODEL_ITEM_UOM     ,
		   tst.debit_credit_sign*tst.amount_base                                            COGS_VAL_B             ,
                   trunc(GL_TRANS_DATE)                                                             COGS_DATE              ,
                   nvl(cust_acct.party_id, -1)                                                      SOLD_TO_ORG_ID         ,
                   Decode(lines.source_type_code, 'EXTERNAL', DO_NOT_INCLUDE_FOR_TURNS,INCLUDE_FOR_TURNS )                             TURNS_COGS_FLAG        ,
                   OPM_SOURCE                                SOURCE
               from gl_subr_tst                    tst,
                    oe_order_lines_all             lines,
                    hz_cust_accounts       cust_acct,
                    ic_whse_mst                    whse,
		    mtl_system_items_b             msi,
                    (
                     select /*+ full(tran) full(rcv) use_hash(tran) parallel(tran) parallel(rcv) */
                            tran.doc_type,
                            rcv.oe_order_line_id  oe_order_line_id,
                            tran.line_id,
                            tran.orgn_code,
                            tran.whse_code
                     from ic_tran_pnd      tran,
                          rcv_transactions rcv
                     where doc_type = 'PORC'
                       and completed_ind = 1
                       and gl_posted_ind = 0
                       and tran.line_id = rcv.transaction_id
                       and rcv.oe_order_line_id is NOT NULL
                     group by doc_type, rcv.oe_order_line_id, line_id, orgn_code, whse_code
                    union all
                      select /*+ parallel(tran) */
                            tran.doc_type,
                            tran.line_id oe_order_line_id,
                            tran.line_id,
                            tran.orgn_code,
                            tran.whse_code
                     from ic_tran_pnd      tran
                     where doc_type = 'OMSO'
                       and completed_ind = 1
                       and gl_posted_ind = 0
                     group by doc_type, line_id, line_id, orgn_code, whse_code
                     )  tran
               where tst.doc_type in ( 'OMSO', 'PORC' )
                 and tst.acct_ttl_type = 5200
                 and lines.line_id = tran.oe_order_line_id
                 and lines.sold_to_org_id = cust_acct.cust_account_id(+)
                 and tran.doc_type = tst.doc_type
                 and tran.line_id  = tst.line_id
                 and whse.whse_code = tran.whse_code
                 and msi.inventory_item_id=lines.inventory_item_id
		 and msi.organization_id=lines.ship_from_org_id
                 and tst.GL_TRANS_DATE  >= global_start_date
            )  A
   group by
     INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,TOP_MODEL_ITEM_UOM
    ,SOLD_TO_ORG_ID
    ,ORDER_LINE_ID
    ,TURNS_COGS_FLAG
    ,SOURCE
   )
   ;
   bis_collection_utilities.put_line('Load OPM Final Subr cogs into stg '
                        || To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

commit;
   insert /*+ append parallel(opi_dbi_cogs_fstg) */ into opi_dbi_cogs_fstg
   (
     INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,TOP_MODEL_LINE_ID
    ,TOP_MODEL_ITEM_ID
    ,TOP_MODEL_ITEM_UOM
    ,TOP_MODEL_ORG_ID
    ,CUSTOMER_ID
    ,COGS_VAL_B
    ,COGS_DATE
    ,SOURCE
    ,TURNS_COGS_FLAG
   )
    (select
       INVENTORY_ITEM_ID,
       ORGANIZATION_ID,
       ORDER_LINE_ID,
       ORDER_LINE_ID,
       INVENTORY_ITEM_ID,
       TOP_MODEL_ITEM_UOM,
       ORGANIZATION_ID,
       SOLD_TO_ORG_ID,
       sum(COGS_VAL_B),
       max(COGS_DATE),
       SOURCE,
       TURNS_COGS_FLAG
 from
 ( select
 /*+ full(tst) use_hash(tst, lines,cust_acct,msi,whse) parallel(tst) parallel(lines) parallel(cust_acct) parallel(msi) parallel(whse)  */
              lines.inventory_item_id INVENTORY_ITEM_ID,
	      whse.mtl_organization_id ORGANIZATION_ID ,
	      tran.oe_order_line_id ORDER_LINE_ID,
              msi.primary_uom_code TOP_MODEL_ITEM_UOM ,
              tst.debit_credit_sign*tst.amount_base COGS_VAL_B ,
              trunc(GL_TRANS_DATE) COGS_DATE ,
              nvl(cust_acct.party_id, -1) SOLD_TO_ORG_ID ,
              Decode(lines.source_type_code, 'EXTERNAL', DO_NOT_INCLUDE_FOR_TURNS,INCLUDE_FOR_TURNS)  TURNS_COGS_FLAG ,
              OPM_SOURCE                                          SOURCE
          from gl_subr_led tst,
               (select /*+ full(tran) full(rcv) use_hash(tran) parallel(tran) parallel(rcv) */
	               tran.doc_type,
                       rcv.oe_order_line_id  oe_order_line_id,
                       tran.line_id,
                       tran.orgn_code,
                       tran.whse_code
                  from ic_tran_pnd      tran,
                       rcv_transactions rcv
                 where doc_type = 'PORC'
                   and completed_ind = 1
                   and gl_posted_ind = 1
                   and tran.line_id = rcv.transaction_id
                   and rcv.oe_order_line_id is NOT NULL
              group by doc_type, rcv.oe_order_line_id, line_id, orgn_code, whse_code
             union all
                select /*+ full(tran) parallel(tran) */
		       tran.doc_type,
                       tran.line_id oe_order_line_id,
                       tran.line_id,
                       tran.orgn_code,
                       tran.whse_code
                  from ic_tran_pnd      tran
                 where doc_type = 'OMSO'
                   and completed_ind = 1
                   and gl_posted_ind = 1
              group by doc_type, line_id, line_id, orgn_code, whse_code)  tran,
             oe_order_lines_all     lines,
             hz_cust_accounts       cust_acct,
             mtl_system_items_b     msi,
             ic_whse_mst            whse
       where tst.doc_type in ( 'OMSO', 'PORC' )
         and tst.acct_ttl_type = 5200
         and lines.line_id = tran.oe_order_line_id
         and lines.sold_to_org_id = cust_acct.cust_account_id(+)
         and tran.doc_type = tst.doc_type
         and tran.line_id  = tst.line_id
         and whse.whse_code = tran.whse_code
         and msi.inventory_item_id=lines.inventory_item_id
         and msi.organization_id=lines.ship_from_org_id
         and tst.subledger_id >= p_last_id and tst.subledger_id +0 <= p_newest_id
	 and tst.GL_TRANS_DATE  >= global_start_date
)
   group by
     INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,TOP_MODEL_ITEM_UOM
    ,SOLD_TO_ORG_ID
    ,ORDER_LINE_ID
    ,TURNS_COGS_FLAG
    ,SOURCE );




   l_stmt := 1;

   fnd_stats.gather_table_stats( ownname => g_opi_schema,
                                 tabname => 'OPI_DBI_COGS_FSTG',
                                 percent => 10);

   commit;


   x_status := 1; -- complete successfully
   x_msg  := NULL;
EXCEPTION WHEN OTHERS THEN
   ROLLBACK;

   BIS_COLLECTION_UTILITIES.PUT_LINE(' Error in Initial_opm_subl_org_cogs at statement  ' || l_stmt);
   BIS_COLLECTION_UTILITIES.PUT_LINE( Sqlerrm );
   BIS_COLLECTION_UTILITIES.PUT_LINE(' Error in Initial_opm_subl_org_cogs at statement  ' || l_stmt);
   BIS_COLLECTION_UTILITIES.PUT_LINE( Sqlerrm );
   x_status := 0; -- error
   x_msg := Sqlerrm;

END initial_opm_subl_org_cogs;


FUNCTION refresh_opm_cogs (errbuf   in out  NOCOPY  varchar2,
                           retcode  in out  NOCOPY  VARCHAR2
                          ) RETURN NUMBER IS

   l_last_trx_id NUMBER :=0;
   l_new_trx_id  NUMBER :=0;

   l_rows_in_batch   NUMBER := 100000;
   l_status          NUMBER := 1;
   l_msg             VARCHAR2(4000);

   l_batch_from_id   NUMBER;
   l_batch_to_id     NUMBER;

   l_empty_count     NUMBER;
   l_missing_rate_count NUMBER;
   l_exception_count NUMBER;

   l_opi_schema      VARCHAR2(30);
   l_industry        VARCHAR2(30);
   l_opi_status      VARCHAR2(30);


   x_row_count       NUMBER := 0;

BEGIN

   retcode := 0;

   BIS_COLLECTION_UTILITIES.PUT_LINE('OPM COGS refresh started at ' || TO_CHAR(SYSDATE, 'hh24:mi:ss'));


   -- 1. get subledger cogs

      BEGIN
	  SELECT start_txn_id INTO l_last_trx_id
	  FROM opi_dbi_cogs_run_log
	  WHERE source = OPM_SOURCE;


         SELECT NVL(MAX(subledger_id),l_last_trx_id)
            INTO l_new_trx_id
            from gl_subr_led            led
            where led.doc_type      in ( 'OMSO', 'PORC')
              and led.acct_ttl_type = 5200
              AND led.gl_trans_date >= global_start_date
              AND led.subledger_id  >= l_last_trx_id;


      EXCEPTION
	 WHEN no_data_found THEN

	    SELECT Nvl(MIN(subledger_id),0) - 1,
                   Nvl(MAX(subledger_id),0)
            INTO l_last_trx_id,
                 l_new_trx_id
            from gl_subr_led            led
            where led.doc_type in ( 'OMSO', 'PORC')
              and led.acct_ttl_type = 5200
              AND led.gl_trans_date >= global_start_date;

	    BIS_COLLECTION_UTILITIES.PUT_LINE('S, ' ||l_last_trx_id );
	    BIS_COLLECTION_UTILITIES.PUT_LINE ('Incremental Refresh chosen, but Initial Load may be faster'  );
      END;



      BIS_COLLECTION_UTILITIES.PUT_LINE
	('Collecting OPM Subledger COGS for transaction ID range: ' || to_char(l_last_trx_id + 1) ||' -  ' || l_new_trx_id);



	 BIS_COLLECTION_UTILITIES.PUT_LINE( '   Start at ' || To_char(Sysdate, 'hh24:mi:ss'));

           l_batch_from_id := l_last_trx_id;
           l_batch_to_id   := l_new_trx_id;

           BIS_COLLECTION_UTILITIES.PUT_LINE('batch_id ' || l_batch_from_id);

           refresh_opm_subl_org_cogs(
                                     l_batch_from_id + 1,
                                     l_batch_to_id,
				     l_status,
				     l_msg );

	    merge INTO opi_dbi_cogs_run_log l
	      using ( SELECT NULL organization_id,
		      OPM_SOURCE extraction_type
		      FROM dual ) d
	      ON ( l.source = d.extraction_type )
	      WHEN matched THEN UPDATE SET
                l.organization_id   = NULL,
	        l.start_txn_id      =  l_batch_from_id,
	        l.next_start_txn_id =  l_batch_to_id
		WHEN NOT matched THEN
		   INSERT ( l.ORGANIZATION_ID
                       ,l.SOURCE
                       ,l.LAST_COLLECTION_DATE
                       ,l.INIT_TXN_ID
                       ,l.START_TXN_ID
                       ,l.NEXT_START_TXN_ID
                       ,l.STOP_REASON_CODE
                       ,l.LAST_TRANSACTION_DATE)
		     VALUES (d.organization_id,
                         OPM_SOURCE,
                         null,
                         Decode(l_status, 0, 0 ,l_batch_from_id),
			       Decode(l_status, 0, 0 ,l_batch_from_id),
                         Decode(l_status, 0, 0 ,l_batch_to_id)  ,
                         null,
                         null);

          COMMIT; -- commit per org

      BIS_COLLECTION_UTILITIES.PUT_LINE('   Subledger COGS completed at ' || TO_CHAR(SYSDATE, 'hh24:mi:ss'));

     RETURN x_row_count;
EXCEPTION WHEN OTHERS THEN
   ROLLBACK;

   BIS_COLLECTION_UTILITIES.PUT_LINE('Error in refresh_opm_cogs ' || Sqlerrm );
   errbuf  := Sqlerrm;
   retcode := 1;
   RETURN x_row_count;
END refresh_opm_cogs;


FUNCTION complete_refresh_opm_cogs (errbuf   in out  NOCOPY  varchar2,
                                    retcode  in out  NOCOPY  VARCHAR2,
                                    p_degree IN      NUMBER ) RETURN NUMBER IS

   l_last_trx_id NUMBER :=0;
   l_new_trx_id  NUMBER :=0;

   l_rows_in_batch   NUMBER := 100000;
   l_status          NUMBER := 1;
   l_msg             VARCHAR2(4000);

   l_batch_from_id   NUMBER;
   l_batch_to_id     NUMBER;

   l_empty_count     NUMBER;
   l_missing_rate_count NUMBER;
   l_exception_count NUMBER;

   l_opi_schema      VARCHAR2(30);
   l_industry        VARCHAR2(30);
   l_opi_status      VARCHAR2(30);


   x_row_count       NUMBER := 0;

BEGIN

   retcode := 0;

   BIS_COLLECTION_UTILITIES.PUT_LINE('OPM COGS refresh started at ' || TO_CHAR(SYSDATE, 'hh24:mi:ss'));


   -- 1. get subledger cogs

	    SELECT Nvl(MIN(subledger_id),0),
                   Nvl(MAX(subledger_id),0)
            INTO l_last_trx_id,
                 l_new_trx_id
            from gl_subr_led            tst
            where tst.doc_type in ( 'OMSO', 'PORC' )
              and tst.acct_ttl_type = 5200
              AND tst.gl_trans_date >= global_start_date;

      BIS_COLLECTION_UTILITIES.PUT_LINE('Initial Refresh'  );


      BIS_COLLECTION_UTILITIES.PUT_LINE
	('Collecting OPM Subledger COGS for transaction ID range: ' || l_last_trx_id ||' -  ' || l_new_trx_id);


	 BIS_COLLECTION_UTILITIES.PUT_LINE( '   Start at ' || To_char(Sysdate, 'hh24:mi:ss'));

           l_batch_from_id := l_last_trx_id;
           l_batch_to_id   := l_new_trx_id;

           BIS_COLLECTION_UTILITIES.PUT_LINE('batch_id ' || l_batch_from_id);

           initial_opm_subl_org_cogs(
                                     l_batch_from_id,
                                     l_batch_to_id,
				     l_status,
				     l_msg ,
                                     p_degree);

	    merge INTO opi_dbi_cogs_run_log l
	      using ( SELECT NULL organization_id,
		      OPM_SOURCE extraction_type
		      FROM dual ) d
	      ON ( l.source = d.extraction_type )
	      WHEN matched THEN UPDATE SET
                l.organization_id   = NULL,
	        l.start_txn_id      =  l_batch_to_id,
	        l.next_start_txn_id =  NULL
		WHEN NOT matched THEN
		   INSERT ( l.ORGANIZATION_ID
                       ,l.SOURCE
                       ,l.LAST_COLLECTION_DATE
                       ,l.INIT_TXN_ID
                       ,l.START_TXN_ID
                       ,l.NEXT_START_TXN_ID
                       ,l.STOP_REASON_CODE
                       ,l.LAST_TRANSACTION_DATE)
		     VALUES (d.organization_id,
                         OPM_SOURCE,
                         null,
                         Decode(l_status, 0, 0 ,l_batch_from_id),
			       Decode(l_status, 0, 0 ,l_batch_to_id),
                         Decode(l_status, 0, 0 ,NULL)  ,
                         null,
                         null);
         COMMIT;

      BIS_COLLECTION_UTILITIES.PUT_LINE('   Subledger COGS completed at ' || TO_CHAR(SYSDATE, 'hh24:mi:ss'));

      RETURN x_row_count;
EXCEPTION WHEN OTHERS THEN
   ROLLBACK;

   BIS_COLLECTION_UTILITIES.PUT_LINE('Error in refresh_opm_cogs ' || Sqlerrm );
   errbuf  := Sqlerrm;
   retcode := 1;
   RETURN 0;  --x_row_count;
END complete_refresh_opm_cogs;


PROCEDURE complete_refresh_OPM_margin(Errbuf      in out NOCOPY  VARCHAR2,
			              Retcode     in out NOCOPY  VARCHAR2,
                                      p_degree    IN     NUMBER ) IS

   l_opi_schema      VARCHAR2(30);
   l_status          VARCHAR2(30);
   l_industry        VARCHAR2(30);
   l_revenue_count   NUMBER := 0;
   l_cogs_count      NUMBER := 0;
BEGIN

   -- setup globals
   check_setup_globals(errbuf, retcode);

   IF retcode <> 0 THEN
      retcode:= -1;

   ELSE

      l_cogs_count := complete_refresh_opm_cogs(errbuf, retcode, p_degree);

      IF retcode <> 0 THEN
      retcode:= -1;

      END IF;
  END IF;
  RETURN;

EXCEPTION WHEN OTHERS THEN

   Errbuf:= SQLCODE||':'||Sqlerrm;
   retcode:= -1;

   ROLLBACK;


END complete_refresh_OPM_margin;



PROCEDURE refresh_OPM_margin(Errbuf      in out  NOCOPY   VARCHAR2,
		             Retcode     in out  NOCOPY   VARCHAR2 ) IS
   l_revenue_count NUMBER := 0;
   l_cogs_count    NUMBER := 0;
BEGIN
   check_setup_globals(errbuf, retcode);

   IF retcode <> 0 THEN
      retcode:= -1;

   ELSE
      l_cogs_count := refresh_opm_cogs(errbuf, retcode);

      IF retcode <> 0 THEN
         retcode:= -1;

      END IF;
   END IF;
   RETURN;
EXCEPTION WHEN OTHERS THEN
   Errbuf:= SQLCODE||':'||Sqlerrm;
   retcode:= -1;

   ROLLBACK;


END refresh_OPM_margin;


END opi_dbi_cogs_opm_pkg;

/
