--------------------------------------------------------
--  DDL for Package Body AR_UNPOSTED_ITEM_UPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_UNPOSTED_ITEM_UPG" AS
/* $Header: ARCBUPGB.pls 120.2.12010000.2 2008/11/14 05:47:39 dgaurab ship $ */

g_ae_sys_rec    arp_acct_main.ae_sys_rec_type;

PROCEDURE Init_Curr_Details
(p_sob_id            IN NUMBER,
 p_org_id            IN NUMBER,
 x_accounting_method IN OUT NOCOPY ar_system_parameters.accounting_method%TYPE)
IS
BEGIN
  SELECT sob.set_of_books_id,
         sob.chart_of_accounts_id,
         sob.currency_code,
         c.precision,
         c.minimum_accountable_unit,
         sysp.code_combination_id_gain,
         sysp.code_combination_id_loss,
         sysp.code_combination_id_round,
         sysp.accounting_method
  INTO   g_ae_sys_rec.set_of_books_id,
         g_ae_sys_rec.coa_id,
         g_ae_sys_rec.base_currency,
         g_ae_sys_rec.base_precision,
         g_ae_sys_rec.base_min_acc_unit,
         g_ae_sys_rec.gain_cc_id,
         g_ae_sys_rec.loss_cc_id,
         g_ae_sys_rec.round_cc_id,
         x_accounting_method
  FROM   ar_system_parameters_all sysp,
         gl_sets_of_books         sob,
         fnd_currencies           c
  WHERE  sysp.org_id         = p_org_id
  AND    sob.set_of_books_id = sysp.set_of_books_id --would be the row returned from multi org view
  AND    sob.currency_code   = c.currency_code;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       NULL;
    WHEN OTHERS THEN
       RAISE;
END Init_Curr_Details;



PROCEDURE upgrade_11i_cash_basis
(l_table_owner  IN VARCHAR2, -- AR
 l_table_name   IN VARCHAR2, -- AR_RECEIVABLE_APPLICATIONS_ALL
 l_script_name  IN VARCHAR2, -- ar120cbupi.sql
 l_worker_id    IN VARCHAR2,
 l_num_workers  IN VARCHAR2,
 l_batch_size   IN VARCHAR2)
AS

l_start_rowid         rowid;
l_end_rowid           rowid;
l_any_rows_to_process boolean;
l_rows_processed      number := 0;

l_status     VARCHAR2(10);
l_industry   VARCHAR2(10);
l_res        BOOLEAN := FALSE;
no_global    EXCEPTION;


  CURSOR c_app(p_start_rowid    IN ROWID,
               p_end_rowid      IN ROWID)
  IS
  SELECT app.*
    FROM ar_receivable_applications_all  app,
         ar_system_parameters_all        ars
  WHERE app.status               = 'APP'
    AND app.upgrade_method       IS NULL
    AND app.org_id               = ars.org_id
    AND app.posting_control_id   = -3
    AND app.rowid                >= p_start_rowid
    AND app.rowid                <= p_end_rowid
    AND ars.accounting_method    = 'CASH'
    AND NOT EXISTS (SELECT '1'
                     FROM psa_trx_types_all   psa,
                          ra_customer_trx_all inv
                    WHERE inv.customer_trx_id  = app.applied_customer_trx_id
                      AND inv.cust_trx_type_id = psa.psa_trx_type_id)
  ORDER BY app.org_id;



  l_org_id              NUMBER := -9999;
  l_app_rec             ar_receivable_applications%ROWTYPE;
  l_line_acctd_amt      NUMBER;
  l_tax_acctd_amt       NUMBER;
  l_frt_acctd_amt       NUMBER;
  l_chrg_acctd_amt      NUMBER;
  l_ed_line_acctd_amt   NUMBER;
  l_ed_tax_acctd_amt    NUMBER;
  l_ed_frt_acctd_amt    NUMBER;
  l_ed_chrg_acctd_amt   NUMBER;
  l_ued_line_acctd_amt  NUMBER;
  l_ued_tax_acctd_amt   NUMBER;
  l_ued_frt_acctd_amt   NUMBER;
  l_ued_chrg_acctd_amt  NUMBER;
  dummy                 VARCHAR2(1);
  l_ra_list             DBMS_SQL.NUMBER_TABLE;
  erase_ra_list         DBMS_SQL.NUMBER_TABLE;
  i                     NUMBER := 0;

  g_ind_current   NUMBER := -9;
  g_run_tot       NUMBER := 0;
  g_run_acctd_tot NUMBER := 0;
  l_gt_id         NUMBER := 0;
  l_accounting_method   VARCHAR2(30);
  end_process_stop      EXCEPTION;

BEGIN

/* ------ Initialize the rowid ranges ------ */
ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           l_table_owner,
           l_table_name,
           l_script_name,
           l_worker_id,
           l_num_workers,
           l_batch_size, 0);

/* ------ Get rowid ranges ------ */
ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           l_batch_size,
           TRUE);


WHILE ( l_any_rows_to_process = TRUE )
LOOP

l_rows_processed := 0;



-------------------------------------------
-- Get all invoices for the applications
-------------------------------------------
   INSERT INTO RA_AR_GT
   ( GT_ID                       ,
     AMT                         ,
     ACCTD_AMT                   ,
     ACCOUNT_CLASS               ,
     CCID_SECONDARY              ,
     REF_CUST_TRX_LINE_GL_DIST_ID,
     REF_CUSTOMER_TRX_LINE_ID    ,
     REF_CUSTOMER_TRX_ID         ,
     TO_CURRENCY                 ,
     BASE_CURRENCY               ,
  -- ADJ and APP Elmt
     DIST_AMT                    ,
     DIST_ACCTD_AMT              ,
     DIST_CHRG_AMT               ,
     DIST_CHRG_ACCTD_AMT         ,
     DIST_FRT_AMT                ,
     DIST_FRT_ACCTD_AMT          ,
     DIST_TAX_AMT                ,
     DIST_TAX_ACCTD_AMT          ,
  -- Buc
     tl_alloc_amt          ,
     tl_alloc_acctd_amt    ,
     tl_chrg_alloc_amt     ,
     tl_chrg_alloc_acctd_amt,
     tl_frt_alloc_amt     ,
     tl_frt_alloc_acctd_amt,
     tl_tax_alloc_amt     ,
     tl_tax_alloc_acctd_amt,
  -- ED Elmt
     DIST_ed_AMT,
     DIST_ed_ACCTD_AMT,
     DIST_ed_chrg_AMT,
     DIST_ed_chrg_ACCTD_AMT,
     DIST_ed_frt_AMT      ,
     DIST_ed_frt_ACCTD_AMT,
     DIST_ed_tax_AMT      ,
     DIST_ed_tax_ACCTD_AMT,
     --
     tl_ed_alloc_amt          ,
     tl_ed_alloc_acctd_amt    ,
     tl_ed_chrg_alloc_amt     ,
     tl_ed_chrg_alloc_acctd_amt,
     tl_ed_frt_alloc_amt     ,
     tl_ed_frt_alloc_acctd_amt,
     tl_ed_tax_alloc_amt     ,
     tl_ed_tax_alloc_acctd_amt,
  -- UNED
     DIST_uned_AMT              ,
     DIST_uned_ACCTD_AMT        ,
     DIST_uned_chrg_AMT         ,
     DIST_uned_chrg_ACCTD_AMT   ,
     DIST_uned_frt_AMT          ,
     DIST_uned_frt_ACCTD_AMT    ,
     DIST_uned_tax_AMT          ,
     DIST_uned_tax_ACCTD_AMT    ,
     --
     tl_uned_alloc_amt          ,
     tl_uned_alloc_acctd_amt    ,
     tl_uned_chrg_alloc_amt     ,
     tl_uned_chrg_alloc_acctd_amt,
     tl_uned_frt_alloc_amt     ,
     tl_uned_frt_alloc_acctd_amt,
     tl_uned_tax_alloc_amt     ,
     tl_uned_tax_alloc_acctd_amt,
     --
     source_type               ,
     source_table              ,
     source_id                 ,
     line_type,
     --
     group_id,
     source_data_key1  ,
     source_data_key2  ,
     source_data_key3  ,
     source_data_key4  ,
     source_data_key5  ,
     gp_level,
     --
     set_of_books_id,
     sob_type,
     se_gt_id,
     tax_link_id,
     tax_inc_flag
     )
SELECT
      0      -- GT_ID
,     ctlgd.amount                -- AMT
,     ctlgd.acctd_amount          -- ACCTD_AMT
,     DECODE(ctl.line_type,'LINE','REV',
                           'TAX','TAX',
                           'FREIGHT','FREIGHT',
                           'CHARGES','CHARGES',
                           'CB','REV')      -- ACCOUNT_CLASS
,     DECODE(ctlgd.collected_tax_ccid,
              NULL, ctlgd.code_combination_id,
              0   , ctlgd.code_combination_id,
                 ctlgd.collected_tax_ccid)  -- CCID_SECONDARY
,     ctlgd.cust_trx_line_gl_dist_id --REF_CUST_TRX_LINE_GL_DIST_ID
,     DECODE(ctl.line_type,'LINE'   ,-6,
                           'TAX'    ,-8,
                           'FREIGHT',-9,
                           'CHARGES',-7,
                           'CB'     ,-6)
--,     ctlgd.customer_trx_line_id  -- REF_CUSTOMER_TRX_LINE_ID
,     trx.customer_trx_id         -- REF_CUSTOMER_TRX_ID
,     trx.invoice_currency_code   -- TO_CURRENCY
,     NULL  -- BASE_CURRENCY
  -- ADJ and APP Elmt
,     DECODE(ctl.line_type,'LINE',ctlgd.amount,0)          -- DIST_AMT
,     DECODE(ctl.line_type,'LINE',ctlgd.acctd_amount,0)    -- DIST_ACCTD_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.amount,0)       -- DIST_CHRG_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.acctd_amount,0) -- DIST_CHRG_ACCTD_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.amount,0)       -- DIST_FRT_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.acctd_amount,0) -- DIST_FRT_ACCTD_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.amount,0)           -- DIST_TAX_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.acctd_amount,0)     -- DIST_TAX_ACCTD_AMT
     -- Buc
,     0      -- tl_alloc_amt
,     0      -- tl_alloc_acctd_amt
,     0      -- tl_chrg_alloc_amt
,     0      -- tl_chrg_alloc_acctd_amt
,     0      -- tl_frt_alloc_amt
,     0      -- tl_frt_alloc_acctd_amt
,     0      -- tl_tax_alloc_amt
,     0      -- tl_tax_alloc_acctd_amt
  -- ED Elmt
,     DECODE(ctl.line_type,'LINE'   ,ctlgd.amount,0)       --DIST_ed_AMT
,     DECODE(ctl.line_type,'LINE'   ,ctlgd.acctd_amount,0) --DIST_ed_ACCTD_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.amount,0)       --DIST_ed_chrg_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.acctd_amount,0) --DIST_ed_chrg_ACCTD_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.amount,0)       --DIST_ed_frt_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.acctd_amount,0) --DIST_ed_frt_ACCTD_AMT
,     DECODE(ctl.line_type,'TAX'    ,ctlgd.amount,0)       --DIST_ed_tax_AMT
,     DECODE(ctl.line_type,'TAX'    ,ctlgd.acctd_amount,0) --DIST_ed_tax_ACCTD_AMT
     --
,    0          -- tl_ed_alloc_amt
,    0          -- tl_ed_alloc_acctd_amt
,    0          -- tl_ed_chrg_alloc_amt
,    0          -- tl_ed_chrg_alloc_acctd_amt
,    0          -- tl_ed_frt_alloc_amt
,    0          -- tl_ed_frt_alloc_acctd_amt
,    0          -- tl_ed_tax_alloc_amt
,    0          -- tl_ed_tax_alloc_acctd_amt
  -- UNED
,    DECODE(ctl.line_type,'LINE'   ,ctlgd.amount,0)       --DIST_uned_AMT
,    DECODE(ctl.line_type,'LINE'   ,ctlgd.acctd_amount,0) --DIST_uned_ACCTD_AMT
,    DECODE(ctl.line_type,'CHARGES',ctlgd.amount,0)       --DIST_uned_chrg_AMT
,    DECODE(ctl.line_type,'CHARGES',ctlgd.acctd_amount,0) --DIST_uned_chrg_ACCTD_AMT
,    DECODE(ctl.line_type,'FREIGHT',ctlgd.amount,0)       --DIST_uned_frt_AMT
,    DECODE(ctl.line_type,'FREIGHT',ctlgd.acctd_amount,0) --DIST_uned_frt_ACCTD_AMT
,    DECODE(ctl.line_type,'TAX'    ,ctlgd.amount,0)       --DIST_uned_tax_AMT
,    DECODE(ctl.line_type,'TAX'    ,ctlgd.acctd_amount,0) --DIST_uned_tax_ACCTD_AMT
     --
,    0          -- tl_uned_alloc_amt
,    0          -- tl_uned_alloc_acctd_amt
,    0          -- tl_uned_chrg_alloc_amt
,    0          -- tl_uned_chrg_alloc_acctd_amt
,    0          -- tl_uned_frt_alloc_amt
,    0          -- tl_uned_frt_alloc_acctd_amt
,    0          -- tl_uned_tax_alloc_amt
,    0          -- tl_uned_tax_alloc_acctd_amt
     --
,    NULL    -- source_type
,    'CTLGD' -- source_table
,    NULL    -- source_id
,    ctl.line_type  -- line_type
     --
,    NULL     -- group_id
,    '00'     -- source_data_key1
,    '00'     -- source_data_key2
,    '00'     -- source_data_key3
,    '00'     -- source_data_key4
,    '00'     -- source_data_key5
,    'D'      -- gp_level
     --
,    trx.set_of_books_id  -- set_of_books_id
,    'P'                  -- sob_type
,    USERENV('SESSIONID')   -- se_gt_id
,    NULL      -- tax_link_id
,    NULL      -- tax_inc_flag
FROM (SELECT applied_customer_trx_id,
             org_id
        FROM ar_receivable_applications_all
       WHERE status               = 'APP'
         AND upgrade_method       IS NULL
         AND posting_control_id   = -3
         AND rowid                >= l_start_rowid
         AND rowid                <= l_end_rowid
       GROUP BY applied_customer_trx_id,
                org_id                    )            app,
     ar_system_parameters_all                          ars,
     ra_customer_trx_all                               trx,
     ra_customer_trx_lines_all                         ctl,
     ra_cust_trx_line_gl_dist_all                      ctlgd
WHERE ars.accounting_method       = 'CASH'
  AND app.org_id                  = ars.org_id
  AND app.applied_customer_trx_id = trx.customer_trx_id
  AND trx.customer_trx_id         = ctl.customer_trx_id
  AND ctl.customer_trx_line_id    = ctlgd.customer_trx_line_id
  AND ctl.line_type               IN ('LINE','TAX','FREIGHT','CHARGES','CB')
  AND ctlgd.account_class         IN ('REV','SUSPENSE','UNBILL','UNEARN','FREIGHT','TAX')
  AND ctlgd.account_set_flag      = 'N'
  AND NOT EXISTS (SELECT '1'
                     FROM psa_trx_types_all   psa,
                          ra_customer_trx_all inv
                    WHERE inv.customer_trx_id  = app.applied_customer_trx_id
                      AND inv.cust_trx_type_id = psa.psa_trx_type_id);


-------------------------------------------------------
-- Get the adjustments on those invoice being applied
-------------------------------------------------------
   INSERT INTO RA_AR_GT
   ( GT_ID                       ,
     AMT                         ,
     ACCTD_AMT                   ,
     ACCOUNT_CLASS               ,
     CCID_SECONDARY              ,
     REF_CUST_TRX_LINE_GL_DIST_ID,
     REF_CUSTOMER_TRX_LINE_ID    ,
     REF_CUSTOMER_TRX_ID         ,
     TO_CURRENCY                 ,
     BASE_CURRENCY               ,
  -- ADJ and APP Elmt
     DIST_AMT                    ,
     DIST_ACCTD_AMT              ,
     DIST_CHRG_AMT               ,
     DIST_CHRG_ACCTD_AMT         ,
     DIST_FRT_AMT                ,
     DIST_FRT_ACCTD_AMT          ,
     DIST_TAX_AMT                ,
     DIST_TAX_ACCTD_AMT          ,
     -- Buc
     tl_alloc_amt          ,
     tl_alloc_acctd_amt    ,
     tl_chrg_alloc_amt     ,
     tl_chrg_alloc_acctd_amt,
     tl_frt_alloc_amt     ,
     tl_frt_alloc_acctd_amt,
     tl_tax_alloc_amt     ,
     tl_tax_alloc_acctd_amt,
  -- ED Elmt
     DIST_ed_AMT,
     DIST_ed_ACCTD_AMT,
     DIST_ed_chrg_AMT,
     DIST_ed_chrg_ACCTD_AMT,
     DIST_ed_frt_AMT      ,
     DIST_ed_frt_ACCTD_AMT,
     DIST_ed_tax_AMT      ,
     DIST_ed_tax_ACCTD_AMT,
     --
     tl_ed_alloc_amt          ,
     tl_ed_alloc_acctd_amt    ,
     tl_ed_chrg_alloc_amt     ,
     tl_ed_chrg_alloc_acctd_amt,
     tl_ed_frt_alloc_amt     ,
     tl_ed_frt_alloc_acctd_amt,
     tl_ed_tax_alloc_amt     ,
     tl_ed_tax_alloc_acctd_amt,
     --
  -- UNED
     DIST_uned_AMT              ,
     DIST_uned_ACCTD_AMT        ,
     DIST_uned_chrg_AMT         ,
     DIST_uned_chrg_ACCTD_AMT   ,
     DIST_uned_frt_AMT          ,
     DIST_uned_frt_ACCTD_AMT    ,
     DIST_uned_tax_AMT          ,
     DIST_uned_tax_ACCTD_AMT    ,
     --
     tl_uned_alloc_amt          ,
     tl_uned_alloc_acctd_amt    ,
     tl_uned_chrg_alloc_amt     ,
     tl_uned_chrg_alloc_acctd_amt,
     tl_uned_frt_alloc_amt     ,
     tl_uned_frt_alloc_acctd_amt,
     tl_uned_tax_alloc_amt     ,
     tl_uned_tax_alloc_acctd_amt,
     --
     source_type               ,
     source_table              ,
     source_id                 ,
     line_type,
     --
     group_id,
     source_data_key1  ,
     source_data_key2  ,
     source_data_key3  ,
     source_data_key4  ,
     source_data_key5  ,
     gp_level,
     --
     set_of_books_id,
     sob_type,
     se_gt_id,
     --{Taxable Amount
     tax_link_id,
     tax_inc_flag,
     --}
     ref_line_id
     )
SELECT
   0                                                -- GT_ID
,  NVL(ard.amount_cr,0)
        - NVL(ard.amount_dr,0)                      -- AMT
,  NVL(ard.acctd_amount_cr,0)
        - NVL(ard.acctd_amount_dr,0)                -- ACCTD_AMT
,  DECODE(adj.type,
         'LINE',DECODE(ard.source_type,'ADJ','REV',
                               'TAX','TAX',
                      'DEFERRED_TAX','TAX',
                   'ADJ_NON_REC_TAX','TAX','REV'),
         'TAX' ,DECODE(ard.source_type,'TAX','TAX',
                               'ADJ','TAX',
                      'DEFERRED_TAX','TAX',
                   'ADJ_NON_REC_TAX','TAX','TAX'),
         'FREIGHT' ,DECODE(ard.source_type,'ADJ',
                              'FREIGHT','FREIGHT'),
         'CHARGES',DECODE(ard.source_type,'FINCHRG',
                             'CHARGES','CHARGES'),
         'REV')                                   -- ACCOUNT_CLASS
,  ard.code_combination_id                        -- CCID_SECONDARY
,  DECODE(adj.type,
            'LINE',DECODE(ard.source_type,'ADJ',-6,
                               'TAX',-8,
                      'DEFERRED_TAX',-8,
                   'ADJ_NON_REC_TAX',-8,-6),
            'TAX' ,DECODE(ard.source_type,'TAX',-8,
                               'ADJ',-8,
                      'DEFERRED_TAX',-8,
                   'ADJ_NON_REC_TAX',-8,-8),
            'FREIGHT' ,DECODE(ard.source_type,'ADJ',
                              -9,-9),
            'CHARGES',DECODE(ard.source_type,'FINCHRG',
                              -7,-7),
            -6)                                  --REF_CUST_TRX_LINE_GL_DIST_ID
,  DECODE(adj.type,
            'LINE',DECODE(ard.source_type,'ADJ',-6,
                               'TAX',-8,
                      'DEFERRED_TAX',-8,
                   'ADJ_NON_REC_TAX',-8,-6),
            'TAX' ,DECODE(ard.source_type,'TAX',-8,
                               'ADJ',-8,
                      'DEFERRED_TAX',-8,
                   'ADJ_NON_REC_TAX',-8,-8),
            'FREIGHT' ,DECODE(ard.source_type,'ADJ',
                              -9,-9),
            'CHARGES',DECODE(ard.source_type,'FINCHRG',
                              -7,-7),
            -6)                                    --REF_CUSTOMER_TRX_LINE_ID
,  adj.customer_trx_id                             --REF_CUSTOMER_TRX_ID
,  trx.invoice_currency_code                       --TO_CURRENCY
,  NULL                      -- BASE_CURRENCY
  -- ADJ and APP Elmt
,  DECODE(adj.type,'LINE', DECODE(ard.source_type,
                                 'ADJ',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      --DIST_AMT
,DECODE(adj.type,'LINE', DECODE(ard.source_type,
                                'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      --DIST_ACCTD_AMT
   --
,DECODE(adj.type,'CHARGES',DECODE(ard.source_type,
                                 'FINCHRG',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                 'ADJ' ,   (NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      --DIST_CHRG_AMT
,DECODE(adj.type,'CHARGES',DECODE(ard.source_type,
                                  'FINCHRG',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
	                          'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      --DIST_CHRG_ACCTD_AMT
,  DECODE(adj.type,'FREIGHT',DECODE(ard.source_type,
                                   'ADJ',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      --DIST_FRT_AMT
,  DECODE(adj.type,'FREIGHT',DECODE(ard.source_type,
                                   'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      --DIST_FRT_ACCTD_AMT
,  DECODE(adj.type,'TAX',  DECODE(ard.source_type,
                                  'TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                  'DEFERRED_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                  'ADJ',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                   'LINE', DECODE(ard.source_type,
                                 'TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                 'ADJ_NON_REC_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                 'DEFERRED_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      --DIST_TAX_AMT
,  DECODE(adj.type,'TAX',  DECODE(ard.source_type,
                                   'TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                   'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                   'LINE', DECODE(ard.source_type,
                                   'TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_TAX_ACCTD_AMT
  -- Buc
,     0          -- tl_alloc_amt
,     0    -- tl_alloc_acctd_amt
,     0          -- tl_chrg_alloc_amt
,     0    -- tl_chrg_alloc_acctd_amt
,     0           -- tl_frt_alloc_amt
,     0     -- tl_frt_alloc_acctd_amt
,     0           -- tl_tax_alloc_amt
,     0     -- tl_tax_alloc_acctd_amt
  -- ED Elmt
,     0      -- DIST_ed_AMT
,     0      -- DIST_ed_ACCTD_AMT
,     0      -- DIST_ed_chrg_AMT
,     0      -- DIST_ed_chrg_ACCTD_AMT
,     0      -- DIST_ed_frt_AMT
,     0      -- DIST_ed_frt_ACCTD_AMT
,     0      -- DIST_ed_tax_AMT
,     0      -- DIST_ed_tax_ACCTD_AMT
     --
,     0      -- tl_ed_alloc_amt
,     0      -- tl_ed_alloc_acctd_amt
,     0      -- tl_ed_chrg_alloc_amt
,     0      -- tl_ed_chrg_alloc_acctd_amt
,     0      -- tl_ed_frt_alloc_amt
,     0      -- tl_ed_frt_alloc_acctd_amt
,     0      -- tl_ed_tax_alloc_amt
,     0      -- tl_ed_tax_alloc_acctd_amt
  -- UNED
,     0      -- DIST_uned_AMT
,     0      -- DIST_uned_ACCTD_AMT
,     0      -- DIST_uned_chrg_AMT
,     0      -- DIST_uned_chrg_ACCTD_AMT
,     0      -- DIST_uned_frt_AMT
,     0      -- DIST_uned_frt_ACCTD_AMT
,     0      -- DIST_uned_tax_AMT
,     0      -- DIST_uned_tax_ACCTD_AMT
     --
,     0      -- tl_uned_alloc_amt
,     0      -- tl_uned_alloc_acctd_amt
,     0      -- tl_uned_chrg_alloc_amt
,     0      -- tl_uned_chrg_alloc_acctd_amt
,     0      -- tl_uned_frt_alloc_amt
,     0      -- tl_uned_frt_alloc_acctd_amt
,     0      -- tl_uned_tax_alloc_amt
,     0      -- tl_uned_tax_alloc_acctd_amt
     --
,    ard.source_type      -- source_type
,    ard.source_table     -- source_table
,    ard.source_id        -- source_id
,    DECODE(adj.type,
          'LINE',DECODE(ard.source_type,'ADJ','LINE',
                                        'TAX','TAX',
                               'DEFERRED_TAX','TAX','LINE'),
           'TAX','TAX',
          'CHARGES','CHARGES',
          'FREIGHT','FREIGHT', 'LINE')      -- line_type
     --
,    NULL                                   -- group_id
,    '00'     -- source_data_key1
,    '00'     -- source_data_key2
,    '00'     -- source_data_key3
,    '00'     -- source_data_key4
,    '00'     -- source_data_key5
,    'D'      -- gp_level
     --
,    adj.set_of_books_id  -- set_of_books_id
,    'P'                  -- sob_type
,    USERENV('SESSIONID')      -- se_gt_id
,    NULL      -- tax_link_id
,    NULL      -- tax_inc_flag
,    ard.line_id  -- ref_line_id
  FROM ar_adjustments_all                               adj,
       ar_distributions_all                             ard,
       ar_system_parameters_all                         ars,
       (SELECT MAX(ref_customer_trx_id) ref_customer_trx_id,
               MAX(to_currency)         invoice_currency_code
         FROM  ra_ar_gt
         GROUP BY ref_customer_trx_id, to_currency)     trx
 WHERE adj.customer_trx_id = trx.ref_customer_trx_id
   AND adj.status          = 'A'
   AND adj.postable        = 'Y'
   AND adj.upgrade_method  = '11I'
   AND adj.adjustment_id   = ard.source_id
   AND ard.source_table    = 'ADJ'
   AND adj.type           IN  ('LINE','CHARGES','TAX','FREIGHT')
   AND adj.org_id          = ars.org_id
   AND ars.accounting_method = 'CASH'
   AND DECODE(adj.type, 'LINE',DECODE(ard.source_type,
                         'ADJ','Y',
                         'TAX','Y',
                         'DEFERRED_TAX','Y',
                         'ADJ_NON_REC_TAX','Y','N'),
                        'CHARGES',DECODE(ard.source_type,
                         'FINCHRG','Y',
                         'ADJ','Y','N'),
                        'TAX',DECODE(ard.source_type,
                         'TAX','Y',
                         'DEFERRED_TAX','Y',
                         'ADJ','Y',
                         'ADJ_NON_REC_TAX','Y','N'),
                        'FREIGHT',DECODE(ard.source_type,
                             'ADJ','Y','N'),
                        'N')  = 'Y';

--populate the base amounts
INSERT INTO ar_base_dist_amts_gt
(   gt_id,
    gp_level,
    ref_customer_trx_id ,
    ref_customer_trx_line_id,
    base_dist_amt           ,
    base_dist_acctd_amt     ,
    base_dist_chrg_amt           ,
    base_dist_chrg_acctd_amt     ,
    base_dist_frt_amt           ,
    base_dist_frt_acctd_amt     ,
    base_dist_tax_amt           ,
    base_dist_tax_acctd_amt     ,

    base_ed_dist_amt           ,
    base_ed_dist_acctd_amt     ,
    base_ed_dist_chrg_amt      ,
    base_ed_dist_chrg_acctd_amt,
    base_ed_dist_frt_amt       ,
    base_ed_dist_frt_acctd_amt ,
    base_ed_dist_tax_amt       ,
    base_ed_dist_tax_acctd_amt ,

    base_uned_dist_amt,
    base_uned_dist_acctd_amt,
    base_uned_dist_chrg_amt,
    base_uned_dist_chrg_acctd_amt,
    base_uned_dist_frt_amt,
    base_uned_dist_frt_acctd_amt,
    base_uned_dist_tax_amt,
    base_uned_dist_tax_acctd_amt,
    set_of_books_id,
    sob_type,
    source_table,
    source_type
)
SELECT DISTINCT
       a.gt_id,
       a.gp_level,
       a.ref_customer_trx_id ,
       a.ref_customer_trx_line_id,
       s.sum_dist_amt,
       s.sum_dist_acctd_amt,
       s.sum_dist_chrg_amt,
       s.sum_dist_chrg_acctd_amt,
       s.sum_dist_frt_amt,
       s.sum_dist_frt_acctd_amt,
       s.sum_dist_tax_amt,
       s.sum_dist_tax_acctd_amt,
       --
       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_acctd_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_chrg_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_chrg_acctd_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_frt_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_frt_acctd_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_tax_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_tax_acctd_amt,0),
       --
       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_acctd_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_chrg_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_chrg_acctd_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_frt_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_frt_acctd_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_tax_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_tax_acctd_amt,0),
       a.set_of_books_id,
       a.sob_type,
       a.source_table,
       a.source_type
  FROM (SELECT
        SUM(NVL(b.DIST_AMT,0))                 sum_dist_amt ,
        SUM(NVL(b.DIST_ACCTD_AMT,0))           sum_dist_acctd_amt,
        SUM(NVL(b.DIST_CHRG_AMT,0))            sum_dist_chrg_amt,
        SUM(NVL(b.DIST_CHRG_ACCTD_AMT,0))      sum_dist_chrg_acctd_amt,
        SUM(NVL(b.DIST_FRT_AMT,0))             sum_dist_frt_amt,
        SUM(NVL(b.DIST_FRT_ACCTD_AMT,0))       sum_dist_frt_acctd_amt,
        SUM(NVL(b.DIST_TAX_AMT,0))             sum_dist_tax_amt,
        SUM(NVL(b.DIST_TAX_ACCTD_AMT,0))       sum_dist_tax_acctd_amt,
        --
        SUM(NVL(b.DIST_ed_AMT,0))              sum_dist_ed_amt,
        SUM(NVL(b.DIST_ed_ACCTD_AMT,0))        sum_dist_ed_acctd_amt,
        SUM(NVL(b.DIST_ed_chrg_AMT,0))         sum_dist_ed_chrg_amt,
        SUM(NVL(b.DIST_ed_chrg_ACCTD_AMT,0))   sum_dist_ed_chrg_acctd_amt,
        SUM(NVL(b.DIST_ed_frt_AMT,0))          sum_dist_ed_frt_amt,
        SUM(NVL(b.DIST_ed_frt_ACCTD_AMT,0))    sum_dist_ed_frt_acctd_amt,
        SUM(NVL(b.DIST_ed_tax_AMT,0))          sum_dist_ed_tax_amt,
        SUM(NVL(b.DIST_ed_tax_ACCTD_AMT,0))    sum_dist_ed_tax_acctd_amt,
        --
        SUM(NVL(b.DIST_uned_AMT,0))            sum_dist_uned_amt,
        SUM(NVL(b.DIST_uned_ACCTD_AMT,0))      sum_dist_uned_acctd_amt,
        SUM(NVL(b.DIST_uned_chrg_AMT,0))       sum_dist_uned_chrg_amt,
        SUM(NVL(b.DIST_uned_chrg_ACCTD_AMT,0)) sum_dist_uned_chrg_acctd_amt,
        SUM(NVL(b.DIST_uned_frt_AMT,0))        sum_dist_uned_frt_amt,
        SUM(NVL(b.DIST_uned_frt_ACCTD_AMT,0))  sum_dist_uned_frt_acctd_amt,
        SUM(NVL(b.DIST_uned_tax_AMT,0))        sum_dist_uned_tax_amt,
        SUM(NVL(b.DIST_uned_tax_ACCTD_AMT,0))  sum_dist_uned_tax_acctd_amt,
        b.ref_customer_trx_id                  ref_customer_trx_id,
        b.gt_id                                gt_id
      FROM ra_ar_gt b
     GROUP BY b.ref_customer_trx_id,
              b.gt_id )      s,
           ra_ar_gt a
  WHERE a.ref_customer_trx_id = s.ref_customer_trx_id
    AND a.gt_id               = s.gt_id;

   -- Cash Basis
   OPEN c_app(l_start_rowid, l_end_rowid);
   LOOP
     FETCH c_app INTO l_app_rec;
     EXIT WHEN c_app%NOTFOUND;
     IF l_app_rec.org_id <> l_org_id THEN
--        fnd_client_info.set_currency_context(NULL);
        l_org_id := l_app_rec.org_id;
        Init_Curr_Details(p_sob_id            => l_app_rec.set_of_books_id,
                          p_org_id            => l_app_rec.org_id,
                          x_accounting_method => l_accounting_method);
--        fnd_client_info.set_currency_context(g_ae_sys_rec.set_of_books_id);
--        fnd_client_info.set_org_context(l_app_rec.org_id);

     END IF;

     g_ae_sys_rec.sob_type := 'P';

     l_gt_id        :=  l_gt_id + 1;

      -- proration
      arp_det_dist_pkg.prepare_for_ra
      (  p_gt_id                => l_gt_id,
         p_app_rec              => l_app_rec,
         p_ae_sys_rec           => g_ae_sys_rec,
         p_inv_cm               => 'I',
         p_cash_mfar            => 'CASH');


     l_ra_list(l_gt_id) := l_app_rec.receivable_application_id;

--     fnd_client_info.set_currency_context(NULL);

   END LOOP;
   CLOSE c_app;


   FORALL i IN l_ra_list.FIRST .. l_ra_list.LAST
    UPDATE ar_receivable_applications_all
       SET upgrade_method = 'R12_11ICASH_POST'
     WHERE receivable_application_id = l_ra_list(i);


   l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

   ad_parallel_updates_pkg.processed_rowid_range(
                       l_rows_processed,
                       l_end_rowid);

   commit;

   ad_parallel_updates_pkg.get_rowid_range(
                       l_start_rowid,
                       l_end_rowid,
                       l_any_rows_to_process,
                       l_batch_size,
                       FALSE);

   l_rows_processed := 0 ;

END LOOP ; /* end of WHILE loop */

END;







PROCEDURE upgrade_11i_cm_cash_basis
(l_table_owner  IN VARCHAR2, -- AR
 l_table_name   IN VARCHAR2, -- AR_RECEIVABLE_APPLICATIONS_ALL
 l_script_name  IN VARCHAR2, -- ar120cbupi.sql
 l_worker_id    IN VARCHAR2,
 l_num_workers  IN VARCHAR2,
 l_batch_size   IN VARCHAR2)
AS

l_start_rowid         rowid;
l_end_rowid           rowid;
l_any_rows_to_process boolean;
l_rows_processed      number := 0;

l_status     VARCHAR2(10);
l_industry   VARCHAR2(10);
l_res        BOOLEAN := FALSE;
no_global    EXCEPTION;


  CURSOR c_app(p_start_rowid    IN ROWID,
               p_end_rowid      IN ROWID)
  IS
  SELECT app.*
    FROM ar_receivable_applications_all  app,
         ar_system_parameters_all        ars
  WHERE app.status               = 'APP'
    AND app.upgrade_method       = 'R12_11ICASH_POST'
    AND app.org_id               = ars.org_id
    AND app.posting_control_id   = -3
    AND app.rowid                >= p_start_rowid
    AND app.rowid                <= p_end_rowid
    AND ars.accounting_method    = 'CASH'
    AND app.customer_trx_id     IS NOT NULL
    AND app.cash_receipt_id     IS NULL
    AND NOT EXISTS (SELECT '1'
                     FROM psa_trx_types_all   psa,
                          ra_customer_trx_all inv
                    WHERE inv.customer_trx_id  = app.customer_trx_id
                      AND inv.cust_trx_type_id = psa.psa_trx_type_id)
  ORDER BY app.org_id;



  l_org_id              NUMBER := -9999;
  l_app_rec             ar_receivable_applications%ROWTYPE;
  l_line_acctd_amt      NUMBER;
  l_tax_acctd_amt       NUMBER;
  l_frt_acctd_amt       NUMBER;
  l_chrg_acctd_amt      NUMBER;
  l_ed_line_acctd_amt   NUMBER;
  l_ed_tax_acctd_amt    NUMBER;
  l_ed_frt_acctd_amt    NUMBER;
  l_ed_chrg_acctd_amt   NUMBER;
  l_ued_line_acctd_amt  NUMBER;
  l_ued_tax_acctd_amt   NUMBER;
  l_ued_frt_acctd_amt   NUMBER;
  l_ued_chrg_acctd_amt  NUMBER;
  dummy                 VARCHAR2(1);
  l_ra_list             DBMS_SQL.NUMBER_TABLE;
  erase_ra_list         DBMS_SQL.NUMBER_TABLE;
  i                     NUMBER := 0;

  g_ind_current   NUMBER := -9;
  g_run_tot       NUMBER := 0;
  g_run_acctd_tot NUMBER := 0;
  l_gt_id         NUMBER := 0;
  l_accounting_method   VARCHAR2(30);
  end_process_stop      EXCEPTION;

BEGIN

/* ------ Initialize the rowid ranges ------ */
ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           l_table_owner,
           l_table_name,
           l_script_name,
           l_worker_id,
           l_num_workers,
           l_batch_size, 0);

/* ------ Get rowid ranges ------ */
ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           l_batch_size,
           TRUE);


WHILE ( l_any_rows_to_process = TRUE )
LOOP

l_rows_processed := 0;



-------------------------------------------
-- Get all invoices for the applications
-------------------------------------------
   INSERT INTO RA_AR_GT
   ( GT_ID                       ,
     AMT                         ,
     ACCTD_AMT                   ,
     ACCOUNT_CLASS               ,
     CCID_SECONDARY              ,
     REF_CUST_TRX_LINE_GL_DIST_ID,
     REF_CUSTOMER_TRX_LINE_ID    ,
     REF_CUSTOMER_TRX_ID         ,
     TO_CURRENCY                 ,
     BASE_CURRENCY               ,
  -- ADJ and APP Elmt
     DIST_AMT                    ,
     DIST_ACCTD_AMT              ,
     DIST_CHRG_AMT               ,
     DIST_CHRG_ACCTD_AMT         ,
     DIST_FRT_AMT                ,
     DIST_FRT_ACCTD_AMT          ,
     DIST_TAX_AMT                ,
     DIST_TAX_ACCTD_AMT          ,
  -- Buc
     tl_alloc_amt          ,
     tl_alloc_acctd_amt    ,
     tl_chrg_alloc_amt     ,
     tl_chrg_alloc_acctd_amt,
     tl_frt_alloc_amt     ,
     tl_frt_alloc_acctd_amt,
     tl_tax_alloc_amt     ,
     tl_tax_alloc_acctd_amt,
  -- ED Elmt
     DIST_ed_AMT,
     DIST_ed_ACCTD_AMT,
     DIST_ed_chrg_AMT,
     DIST_ed_chrg_ACCTD_AMT,
     DIST_ed_frt_AMT      ,
     DIST_ed_frt_ACCTD_AMT,
     DIST_ed_tax_AMT      ,
     DIST_ed_tax_ACCTD_AMT,
     --
     tl_ed_alloc_amt          ,
     tl_ed_alloc_acctd_amt    ,
     tl_ed_chrg_alloc_amt     ,
     tl_ed_chrg_alloc_acctd_amt,
     tl_ed_frt_alloc_amt     ,
     tl_ed_frt_alloc_acctd_amt,
     tl_ed_tax_alloc_amt     ,
     tl_ed_tax_alloc_acctd_amt,
  -- UNED
     DIST_uned_AMT              ,
     DIST_uned_ACCTD_AMT        ,
     DIST_uned_chrg_AMT         ,
     DIST_uned_chrg_ACCTD_AMT   ,
     DIST_uned_frt_AMT          ,
     DIST_uned_frt_ACCTD_AMT    ,
     DIST_uned_tax_AMT          ,
     DIST_uned_tax_ACCTD_AMT    ,
     --
     tl_uned_alloc_amt          ,
     tl_uned_alloc_acctd_amt    ,
     tl_uned_chrg_alloc_amt     ,
     tl_uned_chrg_alloc_acctd_amt,
     tl_uned_frt_alloc_amt     ,
     tl_uned_frt_alloc_acctd_amt,
     tl_uned_tax_alloc_amt     ,
     tl_uned_tax_alloc_acctd_amt,
     --
     source_type               ,
     source_table              ,
     source_id                 ,
     line_type,
     --
     group_id,
     source_data_key1  ,
     source_data_key2  ,
     source_data_key3  ,
     source_data_key4  ,
     source_data_key5  ,
     gp_level,
     --
     set_of_books_id,
     sob_type,
     se_gt_id,
     tax_link_id,
     tax_inc_flag
     )
SELECT
      0      -- GT_ID
,     ctlgd.amount                -- AMT
,     ctlgd.acctd_amount          -- ACCTD_AMT
,     DECODE(ctl.line_type,'LINE','REV',
                           'TAX','TAX',
                           'FREIGHT','FREIGHT',
                           'CHARGES','CHARGES',
                           'CB','REV')      -- ACCOUNT_CLASS
,     DECODE(ctlgd.collected_tax_ccid,
              NULL, ctlgd.code_combination_id,
              0   , ctlgd.code_combination_id,
                 ctlgd.collected_tax_ccid)  -- CCID_SECONDARY
,     ctlgd.cust_trx_line_gl_dist_id --REF_CUST_TRX_LINE_GL_DIST_ID
,     DECODE(ctl.line_type,'LINE'   ,-6,
                           'TAX'    ,-8,
                           'FREIGHT',-9,
                           'CHARGES',-7,
                           'CB'     ,-6)
--,     ctlgd.customer_trx_line_id  -- REF_CUSTOMER_TRX_LINE_ID
,     trx.customer_trx_id         -- REF_CUSTOMER_TRX_ID
,     trx.invoice_currency_code   -- TO_CURRENCY
,     NULL  -- BASE_CURRENCY
  -- ADJ and APP Elmt
,     DECODE(ctl.line_type,'LINE',ctlgd.amount,0)          -- DIST_AMT
,     DECODE(ctl.line_type,'LINE',ctlgd.acctd_amount,0)    -- DIST_ACCTD_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.amount,0)       -- DIST_CHRG_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.acctd_amount,0) -- DIST_CHRG_ACCTD_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.amount,0)       -- DIST_FRT_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.acctd_amount,0) -- DIST_FRT_ACCTD_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.amount,0)           -- DIST_TAX_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.acctd_amount,0)     -- DIST_TAX_ACCTD_AMT
     -- Buc
,     0      -- tl_alloc_amt
,     0      -- tl_alloc_acctd_amt
,     0      -- tl_chrg_alloc_amt
,     0      -- tl_chrg_alloc_acctd_amt
,     0      -- tl_frt_alloc_amt
,     0      -- tl_frt_alloc_acctd_amt
,     0      -- tl_tax_alloc_amt
,     0      -- tl_tax_alloc_acctd_amt
  -- ED Elmt
,     DECODE(ctl.line_type,'LINE'   ,ctlgd.amount,0)       --DIST_ed_AMT
,     DECODE(ctl.line_type,'LINE'   ,ctlgd.acctd_amount,0) --DIST_ed_ACCTD_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.amount,0)       --DIST_ed_chrg_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.acctd_amount,0) --DIST_ed_chrg_ACCTD_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.amount,0)       --DIST_ed_frt_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.acctd_amount,0) --DIST_ed_frt_ACCTD_AMT
,     DECODE(ctl.line_type,'TAX'    ,ctlgd.amount,0)       --DIST_ed_tax_AMT
,     DECODE(ctl.line_type,'TAX'    ,ctlgd.acctd_amount,0) --DIST_ed_tax_ACCTD_AMT
     --
,    0          -- tl_ed_alloc_amt
,    0          -- tl_ed_alloc_acctd_amt
,    0          -- tl_ed_chrg_alloc_amt
,    0          -- tl_ed_chrg_alloc_acctd_amt
,    0          -- tl_ed_frt_alloc_amt
,    0          -- tl_ed_frt_alloc_acctd_amt
,    0          -- tl_ed_tax_alloc_amt
,    0          -- tl_ed_tax_alloc_acctd_amt
  -- UNED
,    DECODE(ctl.line_type,'LINE'   ,ctlgd.amount,0)       --DIST_uned_AMT
,    DECODE(ctl.line_type,'LINE'   ,ctlgd.acctd_amount,0) --DIST_uned_ACCTD_AMT
,    DECODE(ctl.line_type,'CHARGES',ctlgd.amount,0)       --DIST_uned_chrg_AMT
,    DECODE(ctl.line_type,'CHARGES',ctlgd.acctd_amount,0) --DIST_uned_chrg_ACCTD_AMT
,    DECODE(ctl.line_type,'FREIGHT',ctlgd.amount,0)       --DIST_uned_frt_AMT
,    DECODE(ctl.line_type,'FREIGHT',ctlgd.acctd_amount,0) --DIST_uned_frt_ACCTD_AMT
,    DECODE(ctl.line_type,'TAX'    ,ctlgd.amount,0)       --DIST_uned_tax_AMT
,    DECODE(ctl.line_type,'TAX'    ,ctlgd.acctd_amount,0) --DIST_uned_tax_ACCTD_AMT
     --
,    0          -- tl_uned_alloc_amt
,    0          -- tl_uned_alloc_acctd_amt
,    0          -- tl_uned_chrg_alloc_amt
,    0          -- tl_uned_chrg_alloc_acctd_amt
,    0          -- tl_uned_frt_alloc_amt
,    0          -- tl_uned_frt_alloc_acctd_amt
,    0          -- tl_uned_tax_alloc_amt
,    0          -- tl_uned_tax_alloc_acctd_amt
     --
,    NULL    -- source_type
,    'CTLGD' -- source_table
,    NULL    -- source_id
,    ctl.line_type  -- line_type
     --
,    NULL     -- group_id
,    '00'     -- source_data_key1
,    '00'     -- source_data_key2
,    '00'     -- source_data_key3
,    '00'     -- source_data_key4
,    '00'     -- source_data_key5
,    'D'      -- gp_level
     --
,    trx.set_of_books_id  -- set_of_books_id
,    'P'                  -- sob_type
,    USERENV('SESSIONID')   -- se_gt_id
,    NULL      -- tax_link_id
,    NULL      -- tax_inc_flag
FROM (SELECT customer_trx_id,
             org_id
        FROM ar_receivable_applications_all
       WHERE status               = 'APP'
         AND upgrade_method       = 'R12_11ICASH_POST'
         AND posting_control_id   = -3
         AND customer_trx_id      IS NOT NULL
         AND cash_receipt_id      IS NULL
         AND rowid                >= l_start_rowid
         AND rowid                <= l_end_rowid
       GROUP BY customer_trx_id,
                org_id                    )            app,
     ar_system_parameters_all                          ars,
     ra_customer_trx_all                               trx,
     ra_customer_trx_lines_all                         ctl,
     ra_cust_trx_line_gl_dist_all                      ctlgd
WHERE ars.accounting_method       = 'CASH'
  AND app.org_id                  = ars.org_id
  AND app.customer_trx_id         = trx.customer_trx_id
  AND trx.customer_trx_id         = ctl.customer_trx_id
  AND ctl.customer_trx_line_id    = ctlgd.customer_trx_line_id
  AND ctl.line_type               IN ('LINE','TAX','FREIGHT','CHARGES','CB')
  AND ctlgd.account_class         IN ('REV','SUSPENSE','UNBILL','UNEARN','FREIGHT','TAX')
  AND ctlgd.account_set_flag      = 'N'
  AND NOT EXISTS (SELECT '1'
                     FROM psa_trx_types_all   psa,
                          ra_customer_trx_all inv
                    WHERE inv.customer_trx_id  = app.customer_trx_id
                      AND inv.cust_trx_type_id = psa.psa_trx_type_id);


--populate the base amounts
INSERT INTO ar_base_dist_amts_gt
(   gt_id,
    gp_level,
    ref_customer_trx_id ,
    ref_customer_trx_line_id,
    base_dist_amt           ,
    base_dist_acctd_amt     ,
    base_dist_chrg_amt           ,
    base_dist_chrg_acctd_amt     ,
    base_dist_frt_amt           ,
    base_dist_frt_acctd_amt     ,
    base_dist_tax_amt           ,
    base_dist_tax_acctd_amt     ,

    base_ed_dist_amt           ,
    base_ed_dist_acctd_amt     ,
    base_ed_dist_chrg_amt      ,
    base_ed_dist_chrg_acctd_amt,
    base_ed_dist_frt_amt       ,
    base_ed_dist_frt_acctd_amt ,
    base_ed_dist_tax_amt       ,
    base_ed_dist_tax_acctd_amt ,

    base_uned_dist_amt,
    base_uned_dist_acctd_amt,
    base_uned_dist_chrg_amt,
    base_uned_dist_chrg_acctd_amt,
    base_uned_dist_frt_amt,
    base_uned_dist_frt_acctd_amt,
    base_uned_dist_tax_amt,
    base_uned_dist_tax_acctd_amt,
    set_of_books_id,
    sob_type,
    source_table,
    source_type
)
SELECT DISTINCT
       a.gt_id,
       a.gp_level,
       a.ref_customer_trx_id ,
       a.ref_customer_trx_line_id,

       s.sum_dist_amt,
       s.sum_dist_acctd_amt,
       s.sum_dist_chrg_amt,
       s.sum_dist_chrg_acctd_amt,
       s.sum_dist_frt_amt,
       s.sum_dist_frt_acctd_amt,
       s.sum_dist_tax_amt,
       s.sum_dist_tax_acctd_amt,
       --
       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_acctd_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_chrg_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_chrg_acctd_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_frt_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_frt_acctd_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_tax_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_tax_acctd_amt,0),
       --
       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_acctd_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_chrg_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_chrg_acctd_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_frt_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_frt_acctd_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_tax_amt,0),
       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_tax_acctd_amt,0),

       a.set_of_books_id,
       a.sob_type,
       a.source_table,
       a.source_type
  FROM (SELECT
        SUM(NVL(b.DIST_AMT,0))                 sum_dist_amt ,
        SUM(NVL(b.DIST_ACCTD_AMT,0))           sum_dist_acctd_amt,
        SUM(NVL(b.DIST_CHRG_AMT,0))            sum_dist_chrg_amt,
        SUM(NVL(b.DIST_CHRG_ACCTD_AMT,0))      sum_dist_chrg_acctd_amt,
        SUM(NVL(b.DIST_FRT_AMT,0))             sum_dist_frt_amt,
        SUM(NVL(b.DIST_FRT_ACCTD_AMT,0))       sum_dist_frt_acctd_amt,
        SUM(NVL(b.DIST_TAX_AMT,0))             sum_dist_tax_amt,
        SUM(NVL(b.DIST_TAX_ACCTD_AMT,0))       sum_dist_tax_acctd_amt,
        --
        SUM(NVL(b.DIST_ed_AMT,0))              sum_dist_ed_amt,
        SUM(NVL(b.DIST_ed_ACCTD_AMT,0))        sum_dist_ed_acctd_amt,
        SUM(NVL(b.DIST_ed_chrg_AMT,0))         sum_dist_ed_chrg_amt,
        SUM(NVL(b.DIST_ed_chrg_ACCTD_AMT,0))   sum_dist_ed_chrg_acctd_amt,
        SUM(NVL(b.DIST_ed_frt_AMT,0))          sum_dist_ed_frt_amt,
        SUM(NVL(b.DIST_ed_frt_ACCTD_AMT,0))    sum_dist_ed_frt_acctd_amt,
        SUM(NVL(b.DIST_ed_tax_AMT,0))          sum_dist_ed_tax_amt,
        SUM(NVL(b.DIST_ed_tax_ACCTD_AMT,0))    sum_dist_ed_tax_acctd_amt,
        --
        SUM(NVL(b.DIST_uned_AMT,0))            sum_dist_uned_amt,
        SUM(NVL(b.DIST_uned_ACCTD_AMT,0))      sum_dist_uned_acctd_amt,
        SUM(NVL(b.DIST_uned_chrg_AMT,0))       sum_dist_uned_chrg_amt,
        SUM(NVL(b.DIST_uned_chrg_ACCTD_AMT,0)) sum_dist_uned_chrg_acctd_amt,
        SUM(NVL(b.DIST_uned_frt_AMT,0))        sum_dist_uned_frt_amt,
        SUM(NVL(b.DIST_uned_frt_ACCTD_AMT,0))  sum_dist_uned_frt_acctd_amt,
        SUM(NVL(b.DIST_uned_tax_AMT,0))        sum_dist_uned_tax_amt,
        SUM(NVL(b.DIST_uned_tax_ACCTD_AMT,0))  sum_dist_uned_tax_acctd_amt,
        b.ref_customer_trx_id                  ref_customer_trx_id,
        b.gt_id                                gt_id
      FROM ra_ar_gt b
     GROUP BY b.ref_customer_trx_id,
              b.gt_id )      s,
          ra_ar_gt a
  WHERE a.ref_customer_trx_id = s.ref_customer_trx_id
    AND a.gt_id               = s.gt_id;

   -- Cash Basis
   OPEN c_app(l_start_rowid, l_end_rowid);
   LOOP
     FETCH c_app INTO l_app_rec;
     EXIT WHEN c_app%NOTFOUND;
     IF l_app_rec.org_id <> l_org_id THEN
--        fnd_client_info.set_currency_context(NULL);
        l_org_id := l_app_rec.org_id;
        Init_Curr_Details(p_sob_id            => l_app_rec.set_of_books_id,
                          p_org_id            => l_app_rec.org_id,
                          x_accounting_method => l_accounting_method);
--        fnd_client_info.set_currency_context(g_ae_sys_rec.set_of_books_id);
--        fnd_client_info.set_org_context(l_app_rec.org_id);

     END IF;

     g_ae_sys_rec.sob_type := 'P';

     l_gt_id        :=  l_gt_id + 1;

      -- proration
      arp_det_dist_pkg.prepare_for_ra
      (  p_gt_id                => l_gt_id,
         p_app_rec              => l_app_rec,
         p_ae_sys_rec           => g_ae_sys_rec,
         p_inv_cm               => 'C',
         p_cash_mfar            => 'CASH');



--     fnd_client_info.set_currency_context(NULL);

   END LOOP;
   CLOSE c_app;



   l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

   ad_parallel_updates_pkg.processed_rowid_range(
                       l_rows_processed,
                       l_end_rowid);

   commit;

   ad_parallel_updates_pkg.get_rowid_range(
                       l_start_rowid,
                       l_end_rowid,
                       l_any_rows_to_process,
                       l_batch_size,
                       FALSE);

   l_rows_processed := 0 ;

END LOOP ; /* end of WHILE loop */

END;


END;

/
