--------------------------------------------------------
--  DDL for Package Body OPI_DBI_OPM_COGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_OPM_COGS_PKG" AS
/* $Header: OPIDMPRB.pls 115.22 2003/11/13 21:40:57 cdaly noship $ */

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
	      FROM opi_dbi_cogs_log l,
	      gl_subr_tst tst
	      WHERE l.extraction_type = 'COGS_SUBLEDGER'
	      AND tst.subledger_id  = l.transaction_id
              UNION
              SELECT tst.gl_trans_date from_date
	      FROM opi_dbi_cogs_log l,
	      gl_subr_led tst
	      WHERE l.extraction_type = 'COGS_SUBLEDGER'
	      AND tst.subledger_id  = l.transaction_id
	      UNION
	      SELECT aid.accounting_date from_date
	      FROM opi_dbi_cogs_log l,
	      ap_invoice_distributions_all aid
	      WHERE l.extraction_type = 'COGS_AP'
	      AND aid.invoice_distribution_id = l.transaction_id
	      );

      l_to_date  := sysdate;


--      IF l_from_date = global_start_date THEN
	 -- it might be the initial load. check min(trans_date) in ic_tran_pnd

--	 l_from_date:= Greatest(l_from_date, l_inception_date);
--      END IF;

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
FUNCTION Report_Missing_Rate return NUMBER  IS

   cursor get_missing_rate_c is
      select distinct cogs_currency_code,
                      decode(cogs_conversion_rate, -3, to_Date('01/01/1999', 'MM/DD/YYYY'), cogs_date) cogs_date
	from opi_dbi_cogs_stg
	where NVL(cogs_conversion_rate,-99) < 0 ;

   get_missing_rate_rec         get_missing_rate_c%ROWTYPE;

   l_stmt_num NUMBER;
   no_currency_rate_flag NUMBER := 0;
   i_err_num NUMBER;
   i_err_msg VARCHAR2(255);

BEGIN

   l_stmt_num := 20; /* call api to get get_global_rate_primary */
   OPEN get_missing_rate_c;
   LOOP
     FETCH get_missing_rate_c into get_missing_rate_rec;
     EXIT WHEN get_missing_rate_c%notfound;

     IF (no_currency_rate_flag = 0) THEN
         no_currency_rate_flag := 1;
     END IF;
     BIS_COLLECTION_UTILITIES.writeMissingRateHeader;
     BIS_COLLECTION_UTILITIES.writemissingrate
       (g_global_rate_type,
        get_missing_rate_rec.cogs_currency_code,
        global_currency_code,
	get_missing_rate_rec.cogs_date);

   END LOOP;

   CLOSE get_missing_rate_c;

   l_stmt_num := 30; /* check no_currency_rate_flag  */
   IF (no_currency_rate_flag = 1) THEN /* missing rate found */
    BIS_COLLECTION_UTILITIES.PUT_LINE('Please setup conversion rate for all missing rates reported');
    return (-1);
   END IF;
  return (0);

EXCEPTION
 WHEN OTHERS THEN
   rollback;
   i_err_num := SQLCODE;
   i_err_msg := 'REPORT_MISSING_RATE (' || to_char(l_stmt_num)
     || '): '|| substr(SQLERRM, 1,200);

   BIS_COLLECTION_UTILITIES.PUT_LINE('OPI_DBI_MARGIN_VALUE_PKG.REPORT_MISSING_RATE - Error at statement ('
                    || to_char(l_stmt_num)
                    || ')');

   BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  to_char(i_err_num));
   BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || i_err_msg);

   return -1;
END REPORT_MISSING_RATE ;

FUNCTION check_ici(p_ship_ou_id NUMBER, p_sell_ou_id NUMBER ) RETURN NUMBER IS
   l_ici_flag VARCHAR2(1);

BEGIN
	 SELECT 'Y' INTO l_ici_flag
	   FROM mtl_intercompany_parameters mip
	   WHERE mip.ship_organization_id = p_ship_ou_id
	   AND mip.sell_organization_id   = p_sell_ou_id ;

	 RETURN 1;

      EXCEPTION WHEN NO_DATA_FOUND THEN
	 RETURN 0;
END check_ici;


PROCEDURE refresh_opm_subl_org_cogs(
  				     p_last_id         IN         NUMBER,
				     p_newest_id       IN         NUMBER,
				     x_status          OUT NOCOPY NUMBER,
				     x_msg             OUT NOCOPY VARCHAR2 ) IS

  l_stmt NUMBER := 0;


BEGIN

   -- Regular sales order
   insert /*+ append */ into opi_dbi_opm_cogstst_current
   ( INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,MARGIN_OU_ID
    ,COGS_VAL_B
    ,COGS_DATE
    ,COGS_CURRENCY_CODE
    ,COGS_CONVERSION_RATE
    ,SHIP_OU_ID
    ,SELL_OU_ID
    ,TURNS_COGS_FLAG
    ,SOURCE
   )
    select
     INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,MARGIN_OU_ID
    ,sum(COGS_VAL_B)
    ,max(COGS_DATE)
    ,COGS_CURRENCY_CODE
    ,fii_currency.get_global_rate_primary
      (cogs_currency_code, max(cogs_date))       COGS_CONVERSION_RATE
    ,SHIP_OU_ID
    ,SELL_OU_ID
    ,TURNS_COGS_FLAG
    ,SOURCE
    from
     (         select
               lines.inventory_item_id                                                                     INVENTORY_ITEM_ID      ,
               whse.mtl_organization_id                                                                    ORGANIZATION_ID        ,
               tran.oe_order_line_id                                                                                 ORDER_LINE_ID          ,
               Decode(lines.source_type_code, 'EXTERNAL', lines.org_id, --drop ship
                      Decode(ou.ship_ou_id, lines.org_id, lines.org_id, -- Same OU,
                             Decode(check_ici(ou.ship_ou_id, lines.org_id), 1, ou.ship_ou_id, -- RO, ICI
                                    0, lines.org_id) -- RO, No ICI
               			   ) )                                                                     MARGIN_OU_ID           ,

               tst.debit_credit_sign*tst.amount_base                                                       COGS_VAL_B             ,
               trunc(GL_TRANS_DATE)                                                                        COGS_DATE              ,
               tst.currency_base                                                                           COGS_CURRENCY_CODE     ,
               ou.ship_ou_id                                                                                SHIP_OU_ID             ,
               lines.org_id                                                                                SELL_OU_ID             ,
               Decode(lines.source_type_code, 'EXTERNAL', 'N', --drop ship
                                                       'Y' )                                               TURNS_COGS_FLAG        ,
               Decode( lines.line_category_code, 'RETURN', 'OPM_RMA',
                  Decode(lines.source_type_code, 'EXTERNAL', 'OPM_RO_DROP', --drop ship
                      Decode(ou.ship_ou_id, lines.org_id, 'OPM_RO', -- Same OU,
                           Decode(check_ici(ou.ship_ou_id, lines.org_id), 1, 'OPM_RO_ICI',
               	   0, 'OPM_RO_NOICI', 'OPM') ) ) )                                                                SOURCE
               from gl_subr_tst            tst,
                    oe_order_lines_all     lines,
                    ic_whse_mst            whse,
                    (
                     SELECT hou.organization_id organization_id,
                            gsob.currency_code currency_code,
                            to_number(HOI.org_information3) ship_ou_id
                       FROM hr_all_organization_units hou,
                            hr_organization_information hoi,
                            gl_sets_of_books gsob
                     WHERE  hou.organization_id   = hoi.organization_id
                        AND ( hoi.org_information_context || '') ='Accounting Information'
                        AND hoi.org_information1    = to_char(gsob.set_of_books_id)
                    )                      OU,
                    (
                     select tran.doc_type,
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
                     select tran.doc_type,
                            rcv.oe_order_line_id  oe_order_line_id,
                            tran.line_id,
                            tran.orgn_code,
                            tran.whse_code
                     from ic_tran_cmp      tran,
                          rcv_transactions rcv
                     where doc_type = 'PORC'
                       and gl_posted_ind = 0
                       and tran.line_id = rcv.transaction_id
                       and rcv.oe_order_line_id is NOT NULL
                     group by doc_type, rcv.oe_order_line_id, line_id, orgn_code, whse_code
                    union all
                     select tran.doc_type,
                            tran.line_id oe_order_line_id,
                            tran.line_id,
                            tran.orgn_code,
                            tran.whse_code
                     from ic_tran_pnd      tran
                     where doc_type = 'OMSO'
                       and completed_ind = 1
                       and gl_posted_ind = 0
                     group by doc_type, line_id, line_id, orgn_code, whse_code
                    union all
                     select tran.doc_type,
                            tran.line_id oe_order_line_id,
                            tran.line_id,
                            tran.orgn_code,
                            tran.whse_code
                     from ic_tran_cmp      tran
                     where doc_type = 'OMSO'
                       and gl_posted_ind = 0
                     group by doc_type, line_id, line_id, orgn_code, whse_code )  tran
               where tst.doc_type in ( 'OMSO', 'PORC' )
                 and tst.acct_ttl_type = 5200
                 and lines.line_id = tran.oe_order_line_id
                 and tran.doc_type = tst.doc_type
                 and tran.line_id  = tst.line_id
                 and whse.whse_code = tran.whse_code
                 AND whse.mtl_organization_id =  ou.organization_id
            )
   group by
     INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,MARGIN_OU_ID
    ,COGS_CURRENCY_CODE
    ,SHIP_OU_ID
    ,SELL_OU_ID
    ,TURNS_COGS_FLAG
    ,SOURCE ;

   commit;
   fnd_stats.gather_table_stats( ownname => g_opi_schema,
                                 tabname => 'OPI_DBI_OPM_COGSTST_CURRENT',
                                 percent => 10);



   insert /*+ append */ into opi_dbi_opm_cogsled_current
   ( INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,MARGIN_OU_ID
    ,COGS_VAL_B
    ,COGS_DATE
    ,COGS_CURRENCY_CODE
    ,COGS_CONVERSION_RATE
    ,SHIP_OU_ID
    ,SELL_OU_ID
    ,TURNS_COGS_FLAG
    ,SOURCE
   )
    select
     INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,MARGIN_OU_ID
    ,sum(COGS_VAL_B)
    ,max(COGS_DATE)
    ,COGS_CURRENCY_CODE
    ,fii_currency.get_global_rate_primary
           (cogs_currency_code, max(cogs_date))          COGS_CONVERSION_RATE
    ,SHIP_OU_ID
    ,SELL_OU_ID
    ,TURNS_COGS_FLAG
    ,SOURCE
    from
     (         select
               lines.inventory_item_id                                                                     INVENTORY_ITEM_ID      ,
               whse.mtl_organization_id                                                                    ORGANIZATION_ID        ,
               tran.oe_order_line_id                                                                       ORDER_LINE_ID          ,
               Decode(lines.source_type_code, 'EXTERNAL', lines.org_id, --drop ship
                      Decode(ou.ship_ou_id, lines.org_id, lines.org_id, -- Same OU,
                             Decode(check_ici(ou.ship_ou_id, lines.org_id), 1, ou.ship_ou_id, -- RO, ICI
                                    0, lines.org_id) -- RO, No ICI
               			   ) )                                                                     MARGIN_OU_ID           ,
               tst.debit_credit_sign*tst.amount_base                                                       COGS_VAL_B             ,
               trunc(GL_TRANS_DATE)                                                                        COGS_DATE              ,
               tst.currency_base                                                                           COGS_CURRENCY_CODE     ,
               ou.ship_ou_id                                                                                SHIP_OU_ID             ,
               lines.org_id                                                                                SELL_OU_ID             ,
               Decode(lines.source_type_code, 'EXTERNAL', 'N', --drop ship
                                                       'Y' )                                               TURNS_COGS_FLAG        ,
               Decode( lines.line_category_code, 'RETURN', 'OPM_RMA',
                  Decode(lines.source_type_code, 'EXTERNAL', 'OPM_RO_DROP', --drop ship
                      Decode(ou.ship_ou_id, lines.org_id, 'OPM_RO', -- Same OU,
                           Decode(check_ici(ou.ship_ou_id, lines.org_id), 1, 'OPM_RO_ICI',
               	   0, 'OPM_RO_NOICI', 'OPM') ) ) )                                                                SOURCE
               from gl_subr_led            tst,
                    oe_order_lines_all     lines,
                    ic_whse_mst            whse,
                    (
                     SELECT hou.organization_id organization_id,
                            gsob.currency_code currency_code,
                            to_number(HOI.org_information3) ship_ou_id
                       FROM hr_all_organization_units hou,
                            hr_organization_information hoi,
                            gl_sets_of_books gsob
                     WHERE  hou.organization_id   = hoi.organization_id
                        AND ( hoi.org_information_context || '') ='Accounting Information'
                        AND hoi.org_information1    = to_char(gsob.set_of_books_id)
                    )                      OU,
                    (
                     select tran.doc_type,
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
                     select tran.doc_type,
                            rcv.oe_order_line_id  oe_order_line_id,
                            tran.line_id,
                            tran.orgn_code,
                            tran.whse_code
                     from ic_tran_cmp      tran,
                          rcv_transactions rcv
                     where doc_type = 'PORC'
                       and gl_posted_ind = 1
                       and tran.line_id = rcv.transaction_id
                       and rcv.oe_order_line_id is NOT NULL
                     group by doc_type, rcv.oe_order_line_id, line_id, orgn_code, whse_code
                    union all
                     select tran.doc_type,
                            tran.line_id oe_order_line_id,
                            tran.line_id,
                            tran.orgn_code,
                            tran.whse_code
                     from ic_tran_pnd      tran
                     where doc_type = 'OMSO'
                       and completed_ind = 1
                       and gl_posted_ind = 1
                     group by doc_type, line_id, line_id, orgn_code, whse_code
                    union all
                     select tran.doc_type,
                            tran.line_id oe_order_line_id,
                            tran.line_id,
                            tran.orgn_code,
                            tran.whse_code
                     from ic_tran_cmp      tran
                     where doc_type = 'OMSO'
                       and gl_posted_ind = 1
                     group by doc_type, line_id, line_id, orgn_code, whse_code )  tran
               where tst.doc_type in ( 'OMSO', 'PORC' )
                 and tst.acct_ttl_type = 5200
                 and lines.line_id = tran.oe_order_line_id
                 and tran.doc_type = tst.doc_type
                 and tran.line_id  = tst.line_id
                 and whse.whse_code = tran.whse_code
                 AND whse.mtl_organization_id =  ou.organization_id
                 and tst.subledger_id between  p_last_id and p_newest_id
            )
   group by
     INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,MARGIN_OU_ID
    ,COGS_CURRENCY_CODE
    ,SHIP_OU_ID
    ,SELL_OU_ID
    ,TURNS_COGS_FLAG
    ,SOURCE ;

   commit;
   fnd_stats.gather_table_stats( ownname => g_opi_schema,
                                 tabname => 'OPI_DBI_OPM_COGSLED_CURRENT',
                                 percent => 10);



   insert /*+ append */ INTO opi_dbi_cogs_stg
	 (inventory_item_id,
          organization_id,
          order_line_id,
          margin_ou_id,
          cogs_val_b, cogs_date,
          cogs_currency_code,
          cogs_conversion_rate,
          ship_ou_id,
          sell_ou_id,
          turns_cogs_flag,
          source,
          creation_date,
          last_update_date,
          created_by,
          last_updated_by,
          last_update_login)
      SELECT
                INVENTORY_ITEM_ID
               ,ORGANIZATION_ID
               ,ORDER_LINE_ID
               ,MARGIN_OU_ID
               ,sum(cogs_val_b)     COGS_VAL_B
               ,max(cogs_date)      COGS_DATE
               ,COGS_CURRENCY_CODE
               ,COGS_CONVERSION_RATE
               ,SHIP_OU_ID
               ,SELL_OU_ID
               ,TURNS_COGS_FLAG
               ,SOURCE
               , g_Sysdate, g_Sysdate, g_user_id, g_user_id, g_login_id
            FROM
            (select
                INVENTORY_ITEM_ID
               ,ORGANIZATION_ID
               ,ORDER_LINE_ID
               ,MARGIN_OU_ID
               ,COGS_VAL_B
               ,COGS_DATE
               ,COGS_CURRENCY_CODE
               ,COGS_CONVERSION_RATE
               ,SHIP_OU_ID
               ,SELL_OU_ID
               ,TURNS_COGS_FLAG
               ,SOURCE
               from opi_dbi_opm_cogstst_current
            union all
            select
                INVENTORY_ITEM_ID
               ,ORGANIZATION_ID
               ,ORDER_LINE_ID
               ,MARGIN_OU_ID
               ,-COGS_VAL_B
               ,COGS_DATE
               ,COGS_CURRENCY_CODE
               ,COGS_CONVERSION_RATE
               ,SHIP_OU_ID
               ,SELL_OU_ID
               ,TURNS_COGS_FLAG
               ,SOURCE
               from opi_dbi_opm_cogstst_prior
            union all
            select
                INVENTORY_ITEM_ID
               ,ORGANIZATION_ID
               ,ORDER_LINE_ID
               ,MARGIN_OU_ID
               ,COGS_VAL_B
               ,COGS_DATE
               ,COGS_CURRENCY_CODE
               ,COGS_CONVERSION_RATE
               ,SHIP_OU_ID
               ,SELL_OU_ID
               ,TURNS_COGS_FLAG
               ,SOURCE
               from opi_dbi_opm_cogsled_current
            )
             group by
                INVENTORY_ITEM_ID
               ,ORGANIZATION_ID
               ,ORDER_LINE_ID
               ,MARGIN_OU_ID
               ,COGS_CURRENCY_CODE
               ,COGS_CONVERSION_RATE
               ,SHIP_OU_ID
               ,SELL_OU_ID
               ,TURNS_COGS_FLAG
               ,SOURCE
               ,   g_Sysdate, g_Sysdate, g_user_id, g_user_id, g_login_id
          ;


   l_stmt := 1;

   execute immediate 'truncate table ' || g_opi_schema
	|| '.opi_dbi_opm_cogsled_current ';

   execute immediate 'truncate table ' || g_opi_schema
	|| '.opi_dbi_opm_cogstst_prior ';

   commit;
   fnd_stats.gather_table_stats( ownname => g_opi_schema,
                                 tabname => 'OPI_DBI_COGS_STG',
                                 percent => 10);


   insert /*+ append */  into opi_dbi_opm_cogstst_prior
   ( INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,MARGIN_OU_ID
    ,COGS_VAL_B
    ,COGS_DATE
    ,COGS_CURRENCY_CODE
    ,COGS_CONVERSION_RATE
    ,SHIP_OU_ID
    ,SELL_OU_ID
    ,TURNS_COGS_FLAG
    ,SOURCE
   )
    select
     INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,MARGIN_OU_ID
    ,COGS_VAL_B
    ,COGS_DATE
    ,COGS_CURRENCY_CODE
    ,COGS_CONVERSION_RATE
    ,SHIP_OU_ID
    ,SELL_OU_ID
    ,TURNS_COGS_FLAG
    ,SOURCE
    from opi_dbi_opm_cogstst_current;

   commit;
   fnd_stats.gather_table_stats( ownname => g_opi_schema,
                                 tabname => 'OPI_DBI_OPM_COGSTST_PRIOR',
                                 percent => 10);


   execute immediate 'truncate table ' || g_opi_schema
	|| '.opi_dbi_opm_cogstst_current ';

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

PROCEDURE refresh_opi_icap_cogs( p_last_dist_id IN         NUMBER,
				 p_new_dist_id  IN         NUMBER,
				 x_status       OUT NOCOPY NUMBER,
				 x_msg          OUT NOCOPY VARCHAR2) IS

BEGIN
   merge INTO opi_dbi_cogs_stg m
     using ( SELECT
	     pl.inventory_item_id     top_model_item_id,
	     pl.line_id               top_model_order_line_id,
	     pl.org_id                sell_ou_id,
	     to_number(HOI.org_information3) ship_ou_id,
	     pl.org_id                margin_ou_id,
	     'N' turns_cogs_flag,
	     trunc( max(aid.accounting_date)) cogs_date,
	     gsob.currency_code       currency_code,
	     fii_currency.get_global_rate_primary
	     (gsob.currency_code, trunc( max(aid.accounting_date)) ) cogs_conversion_rate,
	     SUM( Nvl(aid.base_amount, aid.amount) ) cogs_val_b
	     FROM ap_invoice_distributions_all    aid,
	     ap_invoices_all                 ai,
	     ra_customer_trx_lines_all       rcl,
	     oe_order_lines_all              l,
	     oe_order_lines_all              pl,
	     hr_organization_information hoi,
	     gl_sets_of_books gsob,
	     hr_organization_information hoi2
	     WHERE aid.invoice_distribution_id >= p_last_dist_id
	     AND aid.invoice_distribution_id < p_new_dist_id
	     AND ai.invoice_id = aid.invoice_id
	     AND ai.source = 'Intercompany'
	     and ai.org_id = aid.org_id
             and aid.line_type_lookup_code = 'ITEM'
     	     and translate( lower(aid.REFERENCE_1), 'abcdefghijklmnopqrstuvwxyz_ -+0123456789',
			    'abcdefghijklmnopqrstuvwxyz_ -+') is null
             and rcl.CUSTOMER_TRX_LINE_ID  = to_number(aid.REFERENCE_1)
             and l.line_id = rcl.interface_line_attribute6
             and pl.line_id = nvl(l.top_model_line_id, l.line_id)
       	     AND hoi.organization_id  = pl.org_id
             AND ( hoi.org_information_context || '')	='Accounting Information'
	     AND hoi.org_information1			= to_char(gsob.set_of_books_id)
	     AND hoi2.organization_id = rcl.interface_line_attribute3
	     AND ( hoi.org_information_context || '')	='Accounting Information'
	     group by pl.line_id, pl.inventory_item_id, pl.org_id, hoi.org_information3, gsob.currency_code ) c
     ON ( m.order_line_id          = c.top_model_order_line_id
	  AND m.margin_ou_id           = c.margin_ou_id )
     WHEN matched THEN UPDATE SET
       m.cogs_val_b = Nvl(m.cogs_val_b,0) + Nvl(c.cogs_val_b,0),
       m.cogs_date= Greatest( Nvl(m.cogs_date,c.cogs_date), c.cogs_date),
       m.cogs_conversion_rate = Decode(Sign(c.cogs_date - m.cogs_date),
				       1, c.cogs_conversion_rate,m.cogs_conversion_rate),
       m.cogs_currency_code   = Decode( Sign(c.cogs_conversion_rate), -1, c.currency_code, NULL),
       m.source = 'OPI_AP',
       m.last_update_date = Sysdate,
       m.last_updated_by  = g_user_id,
       m.last_update_login = g_login_id
     WHEN NOT matched THEN
	INSERT (m.inventory_item_id, m.organization_id, m.order_line_id,
		m.margin_ou_id, m.cogs_val_b, m.cogs_date, m.cogs_conversion_rate,
		m.cogs_currency_code,
		m.ship_ou_id, m.sell_ou_id, m.turns_cogs_flag,
		m.source, m.creation_date, m.last_update_date,
		m.created_by, m.last_updated_by, m.last_update_login)
	  VALUES (c.top_model_item_id, null, c.top_model_order_line_id,
		  c.margin_ou_id, c.cogs_val_b, c.cogs_date, c.cogs_conversion_rate,
		  Decode( Sign(c.cogs_conversion_rate), -1, c.currency_code, NULL),
		  c.ship_ou_id, c.sell_ou_id, c.turns_cogs_flag,
		  'OPI_AP', Sysdate, Sysdate,
		  g_user_id, g_user_id, g_login_id)
	  ;

	x_status := 1;
	x_msg := NULL;
EXCEPTION WHEN OTHERS THEN
   ROLLBACK;
   x_status := 0; -- error
   x_msg := Sqlerrm;
   BIS_COLLECTION_UTILITIES.PUT_LINE(' Error in Refresh_opi_icap_cogs ');
   BIS_COLLECTION_UTILITIES.PUT_LINE( Sqlerrm );

END refresh_opi_icap_cogs;

PROCEDURE initial_opm_subl_org_cogs(
  				     p_last_id         IN          NUMBER,
				     p_newest_id       IN          NUMBER,
				     x_status          OUT NOCOPY  NUMBER,
				     x_msg             OUT NOCOPY VARCHAR2,
                                     p_degree          IN    NUMBER  ) IS

  l_stmt NUMBER := 0;

BEGIN

--     execute immediate "alter session set sort_area_size=100000000" ;
--     execute immediate "alter session set hash_area_size=100000000" ;


--   execute immediate 'alter session force parallel query parallel '||p_degree ;

   -- Regular sales order
   insert /*+ APPEND PARALLEL(F) */
   into opi_dbi_opm_cogstst_current F
   ( INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,MARGIN_OU_ID
    ,COGS_VAL_B
    ,COGS_DATE
    ,COGS_CURRENCY_CODE
    ,COGS_CONVERSION_RATE
    ,SHIP_OU_ID
    ,SELL_OU_ID
    ,TURNS_COGS_FLAG
    ,SOURCE
   )
   select   /*+ PARALLEL(COGS)  PARALLEL(MIP) */
    INVENTORY_ITEM_ID
   ,ORGANIZATION_ID
   ,ORDER_LINE_ID
   ,Decode (margin_ou_id,
              0, Decode(mip.sell_organization_id,
                          NULL, sell_ou_id, -- NULL indicates no mip row set up, therefore no ici
                                ship_ou_id  -- else mip row set up, therefore ici
                       ),
                  margin_ou_id
            ) MARGIN_OU_ID
   ,COGS_VAL_B
   ,COGS_DATE
   ,COGS_CURRENCY_CODE
   ,COGS_CONVERSION_RATE
   ,SHIP_OU_ID
   ,SELL_OU_ID
   ,TURNS_COGS_FLAG
   ,decode (SOURCE, 'OPM_CHECK_ICI',
                     Decode(mip.sell_organization_id,
			            NULL, 'OPM_RO_NOICI',   --  RO, NO ICI
                                          'OPM_RO_ICI'),    --  RO, ICI
                     SOURCE )   SOURCE
   from
   (
    select    /*+ PARALLEL(A) */
     INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,MARGIN_OU_ID
    ,sum(COGS_VAL_B)       COGS_VAL_B
    ,max(COGS_DATE)        COGS_DATE
    ,COGS_CURRENCY_CODE
    ,    fii_currency.get_global_rate_primary
           (cogs_currency_code, max(cogs_date))               COGS_CONVERSION_RATE
    ,SHIP_OU_ID
    ,SELL_OU_ID
    ,TURNS_COGS_FLAG
    ,SOURCE
    from
     (         select /*+ FULL(tst)  PARALLEL(TST)  PARALLEL(LINES)  PARALLEL(WHSE)  PARALLEL(OU)  PARALLEL(TRAN) */
               lines.inventory_item_id                                                                     INVENTORY_ITEM_ID      ,
               whse.mtl_organization_id                                                                    ORGANIZATION_ID        ,
               tran.oe_order_line_id                                                                       ORDER_LINE_ID          ,
               Decode(lines.source_type_code, 'EXTERNAL', lines.org_id, --drop ship
                      Decode(ou.ship_ou_id, lines.org_id, lines.org_id, -- Same OU,
                             0                       -- if need to check ici, set OU in outer query
               			   ) )                                                                     MARGIN_OU_ID           ,
               tst.debit_credit_sign*tst.amount_base                                                       COGS_VAL_B             ,
               trunc(GL_TRANS_DATE)                                                                        COGS_DATE              ,
               tst.currency_base                                                                           COGS_CURRENCY_CODE     ,
               ou.ship_ou_id                                                                                SHIP_OU_ID             ,
               lines.org_id                                                                                SELL_OU_ID             ,
               Decode(lines.source_type_code, 'EXTERNAL', 'N', --drop ship
                                                       'Y' )                                               TURNS_COGS_FLAG        ,
               Decode( lines.line_category_code, 'RETURN', 'OPM_RMA',
                  Decode(lines.source_type_code, 'EXTERNAL', 'OPM_RO_DROP', --drop ship
                      Decode(ou.ship_ou_id, lines.org_id, 'OPM_RO', -- Same OU,
                           'OPM_CHECK_ICI' ) ) )                                                     SOURCE
               from gl_subr_tst                    tst,
                    oe_order_lines_all             lines,
                    ic_whse_mst                    whse,
                    (
                     SELECT /*+ PARALLEL(HOU)  PARALLEL(HOI)  PARALLEL(GSOB) */
                            hou.organization_id organization_id,
                            gsob.currency_code currency_code,
                            to_number(HOI.org_information3) ship_ou_id
                       FROM hr_all_organization_units hou,
                            hr_organization_information hoi,
                            gl_sets_of_books gsob
                     WHERE  hou.organization_id   = hoi.organization_id
                        AND ( hoi.org_information_context || '') ='Accounting Information'
                        AND hoi.org_information1    = to_char(gsob.set_of_books_id)
                    )                      OU,
                    (
                     select /*+ PARALLEL(TRAN)  PARALLEL(RCV) */
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
                     select /*+ PARALLEL(TRAN)  PARALLEL(RCV) */
                            tran.doc_type,
                            rcv.oe_order_line_id  oe_order_line_id,
                            tran.line_id,
                            tran.orgn_code,
                            tran.whse_code
                     from ic_tran_cmp      tran,
                          rcv_transactions rcv
                     where doc_type = 'PORC'
                       and gl_posted_ind = 0
                       and tran.line_id = rcv.transaction_id
                       and rcv.oe_order_line_id is NOT NULL
                     group by doc_type, rcv.oe_order_line_id, line_id, orgn_code, whse_code
                    union all
                     select /*+ PARALLEL(TRAN) */
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
                    union all
                     select /*+ PARALLEL(TRAN) */
                            tran.doc_type,
                            tran.line_id oe_order_line_id,
                            tran.line_id,
                            tran.orgn_code,
                            tran.whse_code
                     from ic_tran_cmp      tran
                     where doc_type = 'OMSO'
                       and gl_posted_ind = 0
                     group by doc_type, line_id, line_id, orgn_code, whse_code )  tran
               where tst.doc_type in ( 'OMSO', 'PORC' )
                 and tst.acct_ttl_type = 5200
                 and lines.line_id = tran.oe_order_line_id
                 and tran.doc_type = tst.doc_type
                 and tran.line_id  = tst.line_id
                 and whse.whse_code = tran.whse_code
                 AND whse.mtl_organization_id =  ou.organization_id
            )  A
   group by
     INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,MARGIN_OU_ID
    ,COGS_CURRENCY_CODE
    ,SHIP_OU_ID
    ,SELL_OU_ID
    ,TURNS_COGS_FLAG
    ,SOURCE
   )                           cogs,
   mtl_intercompany_parameters mip
   where mip.ship_organization_id(+) = cogs.ship_ou_id
     AND mip.sell_organization_id(+) = cogs.sell_ou_id
   ;

--   execute immediate 'alter session disable parallel query';

   commit;

   fnd_stats.gather_table_stats( ownname => g_opi_schema,
                                 tabname => 'OPI_DBI_OPM_COGSTST_CURRENT',
                                 percent => 10);

--   execute immediate 'alter session force parallel query parallel '||p_degree ;

   insert /*+ APPEND PARALLEL(F) */
   into opi_dbi_opm_cogsled_current F
   ( INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,MARGIN_OU_ID
    ,COGS_VAL_B
    ,COGS_DATE
    ,COGS_CURRENCY_CODE
    ,COGS_CONVERSION_RATE
    ,SHIP_OU_ID
    ,SELL_OU_ID
    ,TURNS_COGS_FLAG
    ,SOURCE
   )
   select   /*+ PARALLEL(COGS)  PARALLEL(MIP) */
    INVENTORY_ITEM_ID
   ,ORGANIZATION_ID
   ,ORDER_LINE_ID
   ,Decode (margin_ou_id,
              0, Decode(mip.sell_organization_id,
                          NULL, sell_ou_id, -- NULL indicates no mip row set up, therefore no ici
                                ship_ou_id  -- else mip row set up, therefore ici
                       ),
                  margin_ou_id
            ) MARGIN_OU_ID
   ,COGS_VAL_B
   ,COGS_DATE
   ,COGS_CURRENCY_CODE
   ,COGS_CONVERSION_RATE
   ,SHIP_OU_ID
   ,SELL_OU_ID
   ,TURNS_COGS_FLAG
   ,decode (SOURCE, 'OPM_CHECK_ICI',
                     Decode(mip.sell_organization_id,
                                    NULL, 'OPM_RO_NOICI',   --  RO, NOICI
                                          'OPM_RO_ICI'),     --  RO, ICI
                     SOURCE )   SOURCE
   from
   (
    select   /*+ PARALLEL(A) */
     INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,MARGIN_OU_ID
    ,sum(COGS_VAL_B)               COGS_VAL_B
    ,max(COGS_DATE)                COGS_DATE
    ,COGS_CURRENCY_CODE
    ,fii_currency.get_global_rate_primary
           (cogs_currency_code, max(cogs_date))                 COGS_CONVERSION_RATE
    ,SHIP_OU_ID
    ,SELL_OU_ID
    ,TURNS_COGS_FLAG
    ,SOURCE
    from
     (         select /*+ FULL(tst)  PARALLEL(TST)  PARALLEL(LINES)  PARALLEL(WHSE)  PARALLEL(OU)  PARALLEL(TRAN) */
               lines.inventory_item_id                                                                     INVENTORY_ITEM_ID      ,
               whse.mtl_organization_id                                                                    ORGANIZATION_ID        ,
               tran.oe_order_line_id                                                                       ORDER_LINE_ID          ,
               Decode(lines.source_type_code, 'EXTERNAL', lines.org_id, --drop ship
                      Decode(ou.ship_ou_id, lines.org_id, lines.org_id, -- Same OU,
                             0                       -- if need to check ici, set OU in outer query
               			   ) )                                                                     MARGIN_OU_ID           ,
               tst.debit_credit_sign*tst.amount_base                                                       COGS_VAL_B             ,
               trunc(GL_TRANS_DATE)                                                                        COGS_DATE              ,
               tst.currency_base                                                                           COGS_CURRENCY_CODE     ,
               ou.ship_ou_id                                                                                SHIP_OU_ID             ,
               lines.org_id                                                                                SELL_OU_ID             ,
               Decode(lines.source_type_code, 'EXTERNAL', 'N', --drop ship
                                                       'Y' )                                               TURNS_COGS_FLAG        ,
               Decode( lines.line_category_code, 'RETURN', 'OPM_RMA',
                  Decode(lines.source_type_code, 'EXTERNAL', 'OPM_RO_DROP', --drop ship
                      Decode(ou.ship_ou_id, lines.org_id, 'OPM_RO', -- Same OU,
                           'OPM_CHECK_ICI' ) ) )                                                     SOURCE
               from gl_subr_led            tst,
                    oe_order_lines_all     lines,
                    ic_whse_mst            whse,
                    (
                     SELECT /*+ PARALLEL(HOU)  PARALLEL(HOI)  PARALLEL(GSOB) */
                            hou.organization_id organization_id,
                            gsob.currency_code currency_code,
                            to_number(HOI.org_information3) ship_ou_id
                       FROM hr_all_organization_units hou,
                            hr_organization_information hoi,
                            gl_sets_of_books gsob
                     WHERE  hou.organization_id   = hoi.organization_id
                        AND ( hoi.org_information_context || '') ='Accounting Information'
                        AND hoi.org_information1    = to_char(gsob.set_of_books_id)
                    )                      OU,
                    (
                     select /*+ PARALLEL(TRAN)  PARALLEL(RCV) */
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
                     select /*+ PARALLEL(TRAN)  PARALLEL(RCV) */
                            tran.doc_type,
                            rcv.oe_order_line_id  oe_order_line_id,
                            tran.line_id,
                            tran.orgn_code,
                            tran.whse_code
                     from ic_tran_cmp      tran,
                          rcv_transactions rcv
                     where doc_type = 'PORC'
                       and gl_posted_ind = 1
                       and tran.line_id = rcv.transaction_id
                       and rcv.oe_order_line_id is NOT NULL
                     group by doc_type, rcv.oe_order_line_id, line_id, orgn_code, whse_code
                    union all
                     select /*+ PARALLEL(TRAN) */
                            tran.doc_type,
                            tran.line_id oe_order_line_id,
                            tran.line_id,
                            tran.orgn_code,
                            tran.whse_code
                     from ic_tran_pnd      tran
                     where doc_type = 'OMSO'
                       and completed_ind = 1
                       and gl_posted_ind = 1
                     group by doc_type, line_id, line_id, orgn_code, whse_code
                    union all
                     select /*+ PARALLEL(TRAN) */
                            tran.doc_type,
                            tran.line_id oe_order_line_id,
                            tran.line_id,
                            tran.orgn_code,
                            tran.whse_code
                     from ic_tran_cmp      tran
                     where doc_type = 'OMSO'
                       and gl_posted_ind = 1
                     group by doc_type, line_id, line_id, orgn_code, whse_code )  tran
               where tst.doc_type in ( 'OMSO', 'PORC' )
                 and tst.acct_ttl_type = 5200
                 and lines.line_id = tran.oe_order_line_id
                 and tran.doc_type = tst.doc_type
                 and tran.line_id  = tst.line_id
                 and whse.whse_code = tran.whse_code
                 AND whse.mtl_organization_id =  ou.organization_id
                 and tst.subledger_id between  p_last_id and p_newest_id
            )  A
   group by
     INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,MARGIN_OU_ID
    ,COGS_CURRENCY_CODE
    ,SHIP_OU_ID
    ,SELL_OU_ID
    ,TURNS_COGS_FLAG
    ,SOURCE
   )                           cogs,
   mtl_intercompany_parameters mip
   where mip.ship_organization_id(+) = cogs.ship_ou_id
     AND mip.sell_organization_id(+) = cogs.sell_ou_id
   ;

--   execute immediate 'alter session disable parallel query';

   commit;
   fnd_stats.gather_table_stats( ownname => g_opi_schema,
                                 tabname => 'OPI_DBI_OPM_COGSLED_CURRENT',
                                 percent => 10);


--   execute immediate 'alter session force parallel query parallel '||p_degree ;

   insert /*+ APPEND PARALLEL(F) */
   INTO opi_dbi_cogs_stg F
	 (inventory_item_id,
          organization_id,
          order_line_id,
          margin_ou_id,
          cogs_val_b, cogs_date,
          cogs_currency_code,
          cogs_conversion_rate,
          ship_ou_id,
          sell_ou_id,
          turns_cogs_flag,
          source,
          creation_date,
          last_update_date,
          created_by,
          last_updated_by,
          last_update_login)
      SELECT   /*+ PARALLEL(A) */
                INVENTORY_ITEM_ID
               ,ORGANIZATION_ID
               ,ORDER_LINE_ID
               ,MARGIN_OU_ID
               ,sum(cogs_val_b)     COGS_VAL_B
               ,max(cogs_date)      COGS_DATE
               ,COGS_CURRENCY_CODE
               ,COGS_CONVERSION_RATE
               ,SHIP_OU_ID
               ,SELL_OU_ID
               ,TURNS_COGS_FLAG
               ,SOURCE
               , g_Sysdate, g_Sysdate, g_user_id, g_user_id, g_login_id
            FROM
            (select     /*+ PARALLEL(TSTCURR) */
                INVENTORY_ITEM_ID
               ,ORGANIZATION_ID
               ,ORDER_LINE_ID
               ,MARGIN_OU_ID
               ,COGS_VAL_B
               ,COGS_DATE
               ,COGS_CURRENCY_CODE
               ,COGS_CONVERSION_RATE
               ,SHIP_OU_ID
               ,SELL_OU_ID
               ,TURNS_COGS_FLAG
               ,SOURCE
               from opi_dbi_opm_cogstst_current   TSTCURR
            union all
            select    /*+ PARALLEL(TSTPRIOR) */
                INVENTORY_ITEM_ID
               ,ORGANIZATION_ID
               ,ORDER_LINE_ID
               ,MARGIN_OU_ID
               ,-COGS_VAL_B
               ,COGS_DATE
               ,COGS_CURRENCY_CODE
               ,COGS_CONVERSION_RATE
               ,SHIP_OU_ID
               ,SELL_OU_ID
               ,TURNS_COGS_FLAG
               ,SOURCE
               from opi_dbi_opm_cogstst_prior     TSTPRIOR
            union all
            select    /*+ PARALLEL(LED) */
                INVENTORY_ITEM_ID
               ,ORGANIZATION_ID
               ,ORDER_LINE_ID
               ,MARGIN_OU_ID
               ,COGS_VAL_B
               ,COGS_DATE
               ,COGS_CURRENCY_CODE
               ,COGS_CONVERSION_RATE
               ,SHIP_OU_ID
               ,SELL_OU_ID
               ,TURNS_COGS_FLAG
               ,SOURCE
               from opi_dbi_opm_cogsled_current   LED
            ) A
             group by
                INVENTORY_ITEM_ID
               ,ORGANIZATION_ID
               ,ORDER_LINE_ID
               ,MARGIN_OU_ID
               ,COGS_CURRENCY_CODE
               ,COGS_CONVERSION_RATE
               ,SHIP_OU_ID
               ,SELL_OU_ID
               ,TURNS_COGS_FLAG
               ,SOURCE
               ,   g_Sysdate, g_Sysdate, g_user_id, g_user_id, g_login_id
          ;
--   execute immediate 'alter session disable parallel query';
   commit;


   l_stmt := 1;

   execute immediate 'truncate table ' || g_opi_schema
	|| '.opi_dbi_opm_cogsled_current ';

   execute immediate 'truncate table ' || g_opi_schema
	|| '.opi_dbi_opm_cogstst_prior ';

   fnd_stats.gather_table_stats( ownname => g_opi_schema,
                                 tabname => 'OPI_DBI_COGS_STG',
                                 percent => 10);


--   execute immediate 'alter session force parallel query parallel '||p_degree ;

   insert /*+ APPEND PARALLEL(F) */
   into opi_dbi_opm_cogstst_prior F
   ( INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,MARGIN_OU_ID
    ,COGS_VAL_B
    ,COGS_DATE
    ,COGS_CURRENCY_CODE
    ,COGS_CONVERSION_RATE
    ,SHIP_OU_ID
    ,SELL_OU_ID
    ,TURNS_COGS_FLAG
    ,SOURCE
   )
    select /*+ PARALLEL(CURR) FULL(curr) */
     INVENTORY_ITEM_ID
    ,ORGANIZATION_ID
    ,ORDER_LINE_ID
    ,MARGIN_OU_ID
    ,COGS_VAL_B
    ,COGS_DATE
    ,COGS_CURRENCY_CODE
    ,COGS_CONVERSION_RATE
    ,SHIP_OU_ID
    ,SELL_OU_ID
    ,TURNS_COGS_FLAG
    ,SOURCE
    from opi_dbi_opm_cogstst_current curr;

--   execute immediate 'alter session disable parallel query';

   commit;


   fnd_stats.gather_table_stats( ownname => g_opi_schema,
                                 tabname => 'OPI_DBI_OPM_COGSTST_PRIOR',
                                 percent => 10);



   execute immediate 'truncate table ' || g_opi_schema
	|| '.opi_dbi_opm_cogstst_current ';


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



procedure refresh_icap_cogs is
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

   l_ship_ou_id      NUMBER;

   x_row_count       NUMBER := 0;

begin
   BEGIN
      SELECT transaction_id INTO l_last_trx_id
	FROM opi_dbi_cogs_log
	WHERE extraction_type = 'COGS_ICAP';

   EXCEPTION
      WHEN no_data_found THEN
	 SELECT Nvl( MIN(invoice_distribution_id), 0) INTO l_last_trx_id
	   FROM ap_invoice_distributions_all
	   WHERE accounting_date >= global_start_date;

	 BIS_COLLECTION_UTILITIES.PUT_LINE('S, ICAP '|| l_last_trx_id );
	 --l_last_trx_id := 0;
   END;

   SELECT ap_invoice_distributions_s.NEXTVAL INTO l_new_trx_id
     FROM dual;

   l_batch_from_id := l_last_trx_id;

   BIS_COLLECTION_UTILITIES.PUT_LINE('OPI ICAP COGS at ' || TO_CHAR(SYSDATE, 'hh24:mi:ss'));
   LOOP

      BIS_COLLECTION_UTILITIES.PUT_LINE('batch_id ' || l_last_trx_id );

      IF (l_batch_from_id + l_rows_in_batch) >= l_new_trx_id THEN
	 l_batch_to_id := l_new_trx_id;
       ELSE
	 l_batch_to_id := l_batch_from_id + l_rows_in_batch;
      END IF;

      refresh_opi_icap_cogs( l_last_trx_id,
			     l_new_trx_id,
			     l_status,
			     l_msg );

      merge INTO opi_dbi_cogs_log l
	using ( SELECT 	'COGS_ICAP' extraction_type
		FROM dual ) d
	ON ( l.extraction_type = d.extraction_type )
	WHEN matched THEN UPDATE SET
	  l.transaction_id = Decode(l_status, 0, l_batch_from_id,
					1, l_batch_to_id ),
	  l.error_message = l_msg,
	  l.last_update_date = Sysdate,
	  l.last_updated_by  = g_user_id,
	  l.last_update_login = g_login_id
	  WHEN NOT matched THEN
	     INSERT (l.organization_id, l.transaction_id, l.extraction_type,
		     l.error_message, l.creation_date, l.last_update_date, l.created_by,
		     l.last_updated_by, l.last_update_login )
	       VALUES (null,
		       Decode(l_status, 0, l_batch_from_id,1, l_batch_to_id ) , d.extraction_type,
		       l_msg, Sysdate, Sysdate, g_user_id,
		       g_user_id, g_login_id );

	     COMMIT; -- commit per batch

	     l_batch_from_id := l_batch_to_id;
	     EXIT WHEN l_batch_to_id >= l_new_trx_id OR l_status = 0;

   END LOOP;

   BIS_COLLECTION_UTILITIES.PUT_LINE('   after ICAP time is ' || To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));
   BIS_COLLECTION_UTILITIES.PUT_LINE('after ICAP time is ' || To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

end refresh_icap_cogs;


procedure check_rates_and_truncate (errbuf        in out NOCOPY    varchar2,
                                    retcode       in out NOCOPY    VARCHAR2,
                                    x_row_count   in out NOCOPY    NUMBER) is

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


begin
   SELECT COUNT(*) INTO l_exception_count
     FROM opi_dbi_cogs_log
     WHERE error_message IS NOT NULL;

   l_missing_rate_count := report_missing_rate;

   BIS_COLLECTION_UTILITIES.PUT_LINE('completed report_missing_rate ');

   IF l_exception_count = 0 AND l_missing_rate_count = 0 THEN
      BIS_COLLECTION_UTILITIES.PUT_LINE('merging into fact table');
      merge INTO opi_dbi_margin_f m
	using (SELECT *
	       FROM opi_dbi_cogs_stg ) c
	ON ( m.order_line_id = c.order_line_id
	     AND m.margin_ou_id  = c.margin_ou_id )
	WHEN matched THEN UPDATE SET
	  inventory_item_id = c.inventory_item_id,
	  organization_id   = c.organization_id,
	  margin_date = Greatest( Nvl(margin_date, c.cogs_date), c.cogs_date),
	  cogs_val_b  = Nvl(cogs_val_b,0) + Nvl(c.cogs_val_b,0),
	  cogs_conversion_rate = Decode(Sign(c.cogs_date - Nvl(cogs_date, c.cogs_date)),
					-1, cogs_conversion_rate, c.cogs_conversion_rate),
	  cogs_date= Greatest( Nvl(cogs_date,c.cogs_date), c.cogs_date),
	  cogs_source       = c.source,
	  cogs_ship_ou_id   = c.ship_ou_id,
	  cogs_sell_ou_id   = c.sell_ou_id,
	  turns_cogs_flag   = c.turns_cogs_flag,
	  last_update_date = Sysdate,
	  last_updated_by  = g_user_id,
	  last_update_login = g_login_id
	  WHEN NOT matched THEN
	     INSERT (m.inventory_item_id, m.organization_id, m.order_line_id,
		     m.margin_date, m.margin_ou_id,
		     m.cogs_val_b, m.cogs_conversion_rate, m.cogs_date,
		     m.cogs_source, m.cogs_ship_ou_id, m.cogs_sell_ou_id,
		     m.turns_cogs_flag,m.creation_date, m.last_update_date,
		     m.created_by, m.last_updated_by, m.last_update_login)
	       VALUES ( c.inventory_item_id, c.organization_id, c.order_line_id,
			c.cogs_date, c.margin_ou_id,
			c.cogs_val_b, c.cogs_conversion_rate, c.cogs_date,
			c.source, c.ship_ou_id, c.sell_ou_id,
			c.turns_cogs_flag, Sysdate, Sysdate,
			g_user_id, g_user_id, g_login_id);

     BIS_COLLECTION_UTILITIES.PUT_LINE('merge completed');

     x_row_count := SQL%rowcount;

     -- truncate staging table
      execute immediate 'truncate table ' || g_opi_schema || '.opi_dbi_cogs_stg ';


     COMMIT;
    ELSE -- there is exception or missing rate
	     retcode := 1;
	     errbuf  := 'Please check log file for details. ';
	     BIS_COLLECTION_UTILITIES.PUT_LINE('There are either missing conversion rates or exeception happened.');
	     BIS_COLLECTION_UTILITIES.PUT_LINE('Please check the log file for details ');
   END IF;

   BIS_COLLECTION_UTILITIES.PUT_LINE('completed OPI COGS Merge time is ' || To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

end check_rates_and_truncate;


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

   -- 0. check if staging table is empty or not
   SELECT COUNT(*) INTO l_empty_count
     FROM opi_dbi_cogs_stg
     Where rownum = 1;



   IF l_empty_count > 0 THEN -- not empty, do a master update to remove missing rate
      UPDATE opi_dbi_cogs_stg
	SET  cogs_conversion_rate =
	fii_currency.get_global_rate_primary(cogs_currency_code,cogs_date),
	last_update_date = Sysdate,
	last_updated_by  = g_user_id,
	last_update_login = g_login_id
	WHERE NVL(cogs_conversion_rate,-99) < 0 ;
   END IF;


   -- 1. get subledger cogs

      BEGIN
	 SELECT transaction_id INTO l_last_trx_id
	   FROM opi_dbi_cogs_log
	   WHERE extraction_type = 'OPM_COGS_SUBLEDGER';


         SELECT Nvl(MAX(subledger_id),l_last_trx_id)
            INTO l_new_trx_id
            from gl_subr_led            tst
            where tst.doc_type      in ( 'OMSO', 'PORC')
              and tst.acct_ttl_type = 5200
              AND tst.gl_trans_date >= global_start_date
              AND tst.subledger_id  >= l_last_trx_id;


      EXCEPTION
	 WHEN no_data_found THEN



	    SELECT Nvl(MIN(subledger_id),0) - 1,
                   Nvl(MAX(subledger_id),0)
            INTO l_last_trx_id,
                 l_new_trx_id
            from gl_subr_led            tst
            where tst.doc_type in ( 'OMSO', 'PORC')
              and tst.acct_ttl_type = 5200
              AND tst.gl_trans_date >= global_start_date;

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

	    merge INTO opi_dbi_cogs_log l
	      using ( SELECT NULL organization_id,
		      'OPM_COGS_SUBLEDGER' extraction_type
		      FROM dual ) d
	      ON ( l.extraction_type = d.extraction_type )
	      WHEN matched THEN UPDATE SET
                l.organization_id = NULL,
	        l.transaction_id = Decode(l_status, 0, l_batch_from_id,
					      1, l_batch_to_id ),
		l.error_message = l_msg,
		l.last_update_date = Sysdate,
		l.last_updated_by  = g_user_id,
		l.last_update_login = g_login_id
		WHEN NOT matched THEN
		   INSERT (l.organization_id, l.transaction_id, l.extraction_type,
			   l.error_message, l.creation_date, l.last_update_date, l.created_by,
			   l.last_updated_by, l.last_update_login )
		     VALUES (d.organization_id,
			     Decode(l_status, 0, l_batch_from_id,1, l_batch_to_id ) , d.extraction_type,
			     l_msg, Sysdate, Sysdate, g_user_id,
			     g_user_id, g_login_id );

          COMMIT; -- commit per org

      BIS_COLLECTION_UTILITIES.PUT_LINE('   Subledger COGS completed at ' || TO_CHAR(SYSDATE, 'hh24:mi:ss'));

   -- 2. get Intercompany AP as COGS
   --   refresh_icap_cogs;   --removed and called from wrapper


   -- 3. check exception or missing rates
      check_rates_and_truncate(errbuf, retcode, x_row_count);
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

	    merge INTO opi_dbi_cogs_log l
	      using ( SELECT NULL organization_id,
		      'OPM_COGS_SUBLEDGER' extraction_type
		      FROM dual ) d
	      ON ( l.extraction_type = d.extraction_type )
	      WHEN matched THEN UPDATE SET
                l.organization_id = NULL,
	        l.transaction_id = Decode(l_status, 0, l_batch_from_id,
					      1, l_batch_to_id ),
		l.error_message = l_msg,
		l.last_update_date = Sysdate,
		l.last_updated_by  = g_user_id,
		l.last_update_login = g_login_id
		WHEN NOT matched THEN
		   INSERT (l.organization_id, l.transaction_id, l.extraction_type,
			   l.error_message, l.creation_date, l.last_update_date, l.created_by,
			   l.last_updated_by, l.last_update_login )
		     VALUES (d.organization_id,
			     Decode(l_status, 0, 0 /* if error then write 0 */, 1, l_batch_to_id ) , d.extraction_type,
			     l_msg, Sysdate, Sysdate, g_user_id,
			     g_user_id, g_login_id );

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
/*   IF BIS_COLLECTION_UTILITIES.SETUP( 'OPI_DBI_MARGIN_F' ) = false then
      RAISE_APPLICATION_ERROR(-20000, errbuf);
   END IF;
*/
   -- setup globals
   check_setup_globals(errbuf, retcode);

   IF retcode <> 0 THEN
      RETURN ;
   END IF;


/*  Deletes removed here and replaced in wrapper */
/*   delete from opi_dbi_cogs_log         */
/*     where extraction_type like 'OPM%'; */

/*   delete from opi_dbi_cogs_stg         */
/*     where source like 'OPM%';          */

/*   delete from opi_dbi_margin_f         */
/*     where cogs_source like 'OPM%';     */

   execute immediate 'truncate table ' || g_opi_schema
	|| '.opi_dbi_opm_cogstst_current ';
   execute immediate 'truncate table ' || g_opi_schema
	|| '.opi_dbi_opm_cogstst_prior ';
   execute immediate 'truncate table ' || g_opi_schema
	|| '.opi_dbi_opm_cogsled_current ';


   commit;

   l_cogs_count := complete_refresh_opm_cogs(errbuf, retcode, p_degree);

   IF retcode <> 0 THEN
      RETURN ;
    ELSE
      NULL;

      /* Removed call to refresh revenue, this will be performed in the wrapper package */
      /*     l_revenue_count := opi_dbi_cogs_margin_pkg.complete_refresh_revenue;  */

   END IF;

/*   bis_collection_utilities.WRAPUP( p_status => TRUE,
                                    p_count => 0,
				    p_message => 'successfully refreshed OPM performance Margin.'
				    );
*/
EXCEPTION WHEN OTHERS THEN

   Errbuf:= Sqlerrm;
   Retcode:= SQLCODE;

   ROLLBACK;
/*   bis_collection_utilities.wrapup(p_status => FALSE,
				   p_count => 0,
				   p_message => 'failed in refreshing Margin.'
				   );
*/
   RAISE_APPLICATION_ERROR(-20000,errbuf);

END complete_refresh_OPM_margin;



PROCEDURE refresh_OPM_margin(Errbuf      in out  NOCOPY   VARCHAR2,
		             Retcode     in out  NOCOPY   VARCHAR2 ) IS
   l_revenue_count NUMBER := 0;
   l_cogs_count    NUMBER := 0;
BEGIN

/*   IF BIS_COLLECTION_UTILITIES.SETUP( 'OPI_DBI_MARGIN_F' ) = false then
      RAISE_APPLICATION_ERROR(-20000, errbuf);
   END IF;
*/
   check_setup_globals(errbuf, retcode);

   IF retcode <> 0 THEN
      RETURN ;
    ELSE
      l_cogs_count := refresh_opm_cogs(errbuf, retcode);

      IF retcode <> 0 THEN
	 RETURN ;
       ELSE
	 NULL;
      /* Removed call to refresh revenue, this will be performed in the wrapper package */
      /*           l_revenue_count := opi_dbi_cogs_margin_pkg.refresh_revenue;    */
      END IF;
   END IF;

/*   bis_collection_utilities.WRAPUP( p_status => TRUE,
				    p_count => (l_revenue_count + l_cogs_count)/2,
				    p_message => 'successfully refreshed OPM performance Margin.'
				    );
*/

EXCEPTION WHEN OTHERS THEN

   Errbuf:= Sqlerrm;
   Retcode:= SQLCODE;

   ROLLBACK;
/*   bis_collection_utilities.wrapup(p_status => FALSE,
				   p_count => (l_revenue_count + l_cogs_count)/2,
				   p_message => 'failed in refreshing OPM Margin.'
				   );
*/
   RAISE_APPLICATION_ERROR(-20000,errbuf);

END refresh_OPM_margin;


END opi_dbi_opm_cogs_pkg;

/
