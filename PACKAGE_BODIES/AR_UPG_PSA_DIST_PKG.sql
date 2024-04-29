--------------------------------------------------------
--  DDL for Package Body AR_UPG_PSA_DIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_UPG_PSA_DIST_PKG" AS
/* $Header: ARPSAUPB.pls 120.8.12010000.2 2009/03/25 06:53:02 nproddut ship $ */



PROCEDURE upgrade_adjustments(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2)
IS
l_start_rowid         rowid;
l_end_rowid           rowid;
l_any_rows_to_process boolean;
l_rows_processed      number := 0;

CURSOR c(p_start_rowid IN ROWID,p_end_rowid IN ROWID) IS
SELECT count(*)
FROM psa_mf_adj_dist_all
WHERE rowid >= p_start_rowid
AND   rowid <= p_end_rowid;

l_nb_row     NUMBER;
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

-- 1) UPgrade Multi Fund AdJustment REversal AR distributions
INSERT INTO ar_distributions_all (
  LINE_ID
, SOURCE_ID
, SOURCE_TABLE
, SOURCE_TYPE
, CODE_COMBINATION_ID
, AMOUNT_DR
, AMOUNT_CR
, ACCTD_AMOUNT_DR
, ACCTD_AMOUNT_CR
, CREATION_DATE
, CREATED_BY
, LAST_UPDATED_BY
, LAST_UPDATE_DATE
, LAST_UPDATE_LOGIN
, ORG_ID
, SOURCE_TABLE_SECONDARY
, SOURCE_ID_SECONDARY
, CURRENCY_CODE
, CURRENCY_CONVERSION_RATE
, CURRENCY_CONVERSION_TYPE
, CURRENCY_CONVERSION_DATE
, TAXABLE_ENTERED_DR
, TAXABLE_ENTERED_CR
, TAXABLE_ACCOUNTED_DR
, TAXABLE_ACCOUNTED_CR
, TAX_LINK_ID
, THIRD_PARTY_ID
, THIRD_PARTY_SUB_ID
, REVERSED_SOURCE_ID
, TAX_CODE_ID
, LOCATION_SEGMENT_ID
, SOURCE_TYPE_SECONDARY
, TAX_GROUP_CODE_ID
, REF_CUSTOMER_TRX_LINE_ID
, REF_CUST_TRX_LINE_GL_DIST_ID
, REF_ACCOUNT_CLASS
, ACTIVITY_BUCKET
, REF_LINE_ID
, FROM_AMOUNT_DR
, FROM_AMOUNT_CR
, FROM_ACCTD_AMOUNT_DR
, FROM_ACCTD_AMOUNT_CR
, REF_MF_DIST_FLAG
, REF_DIST_CCID)
SELECT
  ar_distributions_s.nextval           -- LINE_ID
, ard.SOURCE_ID
, ard.SOURCE_TABLE
, ard.SOURCE_TYPE
, ard.CODE_COMBINATION_ID
, ard.AMOUNT_CR                            -- Switch DR to CR
, ard.AMOUNT_DR                            -- Switch CR to DR
, ard.ACCTD_AMOUNT_CR                      -- Switch DR to CR
, ard.ACCTD_AMOUNT_DR                      -- Switch CR to DR
, SYSDATE                              -- CREATION_DATE
, 0                                    -- CREATED_BY
, 0                                    -- LAST_UPDATED_BY
, SYSDATE                              -- LAST_UPDATE_DATE
, 0                                    -- LAST_UPDATE_LOGIN
, ard.ORG_ID
, 'UPMFAJREAR'                         -- SOURCE_TABLE_SECONDARY
, ard.SOURCE_ID_SECONDARY
, ard.CURRENCY_CODE
, ard.CURRENCY_CONVERSION_RATE
, ard.CURRENCY_CONVERSION_TYPE
, ard.CURRENCY_CONVERSION_DATE
, ard.TAXABLE_ENTERED_DR
, ard.TAXABLE_ENTERED_CR
, ard.TAXABLE_ACCOUNTED_DR
, ard.TAXABLE_ACCOUNTED_CR
, ard.TAX_LINK_ID
, ard.THIRD_PARTY_ID
, ard.THIRD_PARTY_SUB_ID
, ard.REVERSED_SOURCE_ID
, ard.TAX_CODE_ID
, ard.LOCATION_SEGMENT_ID
, 'PSA_MF_ADJ_DIST_ALL'                -- SOURCE_TYPE_SECONDARY
, ard.TAX_GROUP_CODE_ID
, ard.REF_CUSTOMER_TRX_LINE_ID
, ard.REF_CUST_TRX_LINE_GL_DIST_ID
, ard.REF_ACCOUNT_CLASS
, ard.ACTIVITY_BUCKET
, ard.REF_LINE_ID
, ard.FROM_AMOUNT_DR
, ard.FROM_AMOUNT_CR
, ard.FROM_ACCTD_AMOUNT_DR
, ard.FROM_ACCTD_AMOUNT_CR
, ard.REF_MF_DIST_FLAG
, ard.REF_DIST_CCID
FROM ar_adjustments_all                                    adj,
     ar_distributions_all                                  ard
WHERE adj.rowid              >= l_start_rowid
  AND adj.rowid              <= l_end_rowid
  AND ard.source_table       =  'ADJ'
  AND ard.source_id          = adj.adjustment_id
  AND EXISTS (SELECT NULL FROM psa_mf_adj_dist_all a
              WHERE a.adjustment_id = adj.adjustment_id);

   l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

-- 2) UPgrade Multi Fund AdJustment MIgrated to AR

INSERT INTO ar_distributions_all (
  LINE_ID
, SOURCE_ID
, SOURCE_TABLE
, SOURCE_TYPE
, CODE_COMBINATION_ID
, AMOUNT_DR
, AMOUNT_CR
, ACCTD_AMOUNT_DR
, ACCTD_AMOUNT_CR
, CREATION_DATE
, CREATED_BY
, LAST_UPDATED_BY
, LAST_UPDATE_DATE
, LAST_UPDATE_LOGIN
, ORG_ID
, SOURCE_TABLE_SECONDARY
, SOURCE_ID_SECONDARY
, CURRENCY_CODE
, CURRENCY_CONVERSION_RATE
, CURRENCY_CONVERSION_TYPE
, CURRENCY_CONVERSION_DATE
, TAXABLE_ENTERED_DR
, TAXABLE_ENTERED_CR
, TAXABLE_ACCOUNTED_DR
, TAXABLE_ACCOUNTED_CR
, TAX_LINK_ID
, THIRD_PARTY_ID
, THIRD_PARTY_SUB_ID
, REVERSED_SOURCE_ID
, TAX_CODE_ID
, LOCATION_SEGMENT_ID
, SOURCE_TYPE_SECONDARY
, TAX_GROUP_CODE_ID
, REF_CUSTOMER_TRX_LINE_ID
, REF_CUST_TRX_LINE_GL_DIST_ID
, REF_ACCOUNT_CLASS
, ACTIVITY_BUCKET
, REF_LINE_ID
, FROM_AMOUNT_DR
, FROM_AMOUNT_CR
, FROM_ACCTD_AMOUNT_DR
, FROM_ACCTD_AMOUNT_CR
, REF_MF_DIST_FLAG
, REF_DIST_CCID)
SELECT /*+ ordered rowid(adj) use_nl(psaadj,psatd,ctlgd,trx) INDEX(psaadj psa_mf_adj_dist_u1) INDEX(psatd psa_mf_trx_dist_u1)
 INDEX(ctlgd ra_cust_trx_line_gl_dist_u1) */
  ar_distributions_s.nextval                         -- LINE_ID
, psaadj.adjustment_id                               -- SOURCE_ID
, 'ADJ'                                              -- SOURCE_TABLE
, CASE WHEN doub.side = 'D' THEN
    DECODE(SIGN(psaadj.amount),
            -1 , 'ADJ',
                 'REC' )
  ELSE
    DECODE(SIGN(psaadj.amount),
            1,  'ADJ',
                'REC'  )
  END                                                -- SOURCE_TYPE
, CASE WHEN doub.side = 'D' THEN
    DECODE(SIGN(psaadj.amount),
            -1 , psaadj.mf_adjustment_ccid,
                 psatd.mf_receivables_ccid )
  ELSE
    DECODE(SIGN(psaadj.amount),
            1,  psaadj.mf_adjustment_ccid,
                psatd.mf_receivables_ccid  )
  END                                                -- CODE_COMBINATION_ID
, DECODE(doub.side,'D',ABS(psaadj.amount),NULL   )   -- AMOUNT_DR
, DECODE(doub.side,'C',ABS(psaadj.amount),NULL   )   -- AMOUNT_CR
, DECODE(doub.side,'D',ABS(psaadj.amount),NULL   )   -- ACCTD_AMOUNT_DR
, DECODE(doub.side,'C',ABS(psaadj.amount),NULL   )   -- ACCTD_AMOUNT_CR
, SYSDATE                                            -- CREATION_DATE
, 0                                                  -- CREATED_BY
, 0                                                  -- LAST_UPDATED_BY
, SYSDATE                                            -- LAST_UPDATE_DATE
, 0                                                  -- LAST_UPDATE_LOGIN
, trx.org_id                                         -- ORG_ID
, 'UPMFAJMIAR'                                       -- SOURCE_TABLE_SECONDARY
, NULL                                               -- SOURCE_ID_SECONDARY
, trx.invoice_currency_code                          -- CURRENCY_CODE
, NULL                                               -- CURRENCY_CONVERSION_RATE
, NULL                                               -- CURRENCY_CONVERSION_TYPE
, NULL                                               -- CURRENCY_CONVERSION_DATE
, NULL                                               -- TAXABLE_ENTERED_DR
, NULL                                               -- TAXABLE_ENTERED_CR
, NULL                                               -- TAXABLE_ACCOUNTED_DR
, NULL                                               -- TAXABLE_ACCOUNTED_CR
, NULL                                               -- TAX_LINK_ID
, NULL                                               -- THIRD_PARTY_ID
, NULL                                               -- THIRD_PARTY_SUB_ID
, NULL                                               -- REVERSED_SOURCE_ID
, NULL                                               -- TAX_CODE_ID
, NULL                                               -- LOCATION_SEGMENT_ID
, 'PSA_MF_ADJ_DIST_ALL'                              -- SOURCE_TYPE_SECONDARY
, NULL                                               -- TAX_GROUP_CODE_ID
, ctlgd.customer_trx_line_id                         -- REF_CUSTOMER_TRX_LINE_ID
, psatd.cust_trx_line_gl_dist_id                     -- REF_CUST_TRX_LINE_GL_DIST_ID
, ctlgd.account_class                                -- REF_ACCOUNT_CLASS
, 'ADJ_'||
--   DECODE(doub.type,'CHARGES','CHRG',
       DECODE(ctlgd.account_class,
                              'REV','LINE',
                              'TAX','TAX',
                              'FREIGHT','FRT',
                              'LINE')                -- ACTIVITY_BUCKET
--)
, NULL                                               -- REF_LINE_ID
, NULL   -- FROM_AMOUNT_DR
, NULL   -- FROM_AMOUNT_CR
, NULL   -- FROM_ACCTD_AMOUNT_DR
, NULL   -- FROM_ACCTD_AMOUNT_CR
, NULL                                               -- REF_MF_DIST_FLAG
, NULL                                               -- REF_DIST_CCID
FROM
          ar_adjustments_all                               adj,
          psa_mf_adj_dist_all                              psaadj,
          (SELECT a.flag             side,
                  b.adjustment_id    adj_id,
                  b.customer_trx_id  customer_trx_id,
                  b.type             type
             FROM
                (SELECT 'D' AS flag FROM DUAL
                 UNION ALL
                 SELECT 'C' AS flag  FROM DUAL) a,
                 ar_adjustments_all b)                     doub,
          psa_mf_trx_dist_all                              psatd,
          ra_customer_trx_all                              trx,
          ra_cust_trx_line_gl_dist_all                     ctlgd
WHERE adj.rowid                        >= l_start_rowid
  AND adj.rowid                        <= l_end_rowid
  AND adj.adjustment_id                = psaadj.adjustment_id
  AND doub.adj_id                      = psaadj.adjustment_id
  AND psaadj.cust_trx_line_gl_dist_id  = psatd.cust_trx_line_gl_dist_id
  AND psatd.cust_trx_line_gl_dist_id   = ctlgd.cust_trx_line_gl_dist_id
  AND doub.customer_trx_id             = trx.customer_trx_id;


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


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    RAISE;
END upgrade_adjustments;







PROCEDURE upgrade_applications(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2)
IS
l_start_rowid         rowid;
l_end_rowid           rowid;
l_any_rows_to_process boolean;
l_rows_processed      number := 0;
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

-- UPgrade Multi Fund Receivable Application REverse AR distributions

INSERT INTO ar_distributions_all
( LINE_ID
, SOURCE_ID
, SOURCE_TABLE
, SOURCE_TYPE
, CODE_COMBINATION_ID
, AMOUNT_DR
, AMOUNT_CR
, ACCTD_AMOUNT_DR
, ACCTD_AMOUNT_CR
, CREATION_DATE
, CREATED_BY
, LAST_UPDATED_BY
, LAST_UPDATE_DATE
, LAST_UPDATE_LOGIN
, ORG_ID
, SOURCE_TABLE_SECONDARY
, SOURCE_ID_SECONDARY
, CURRENCY_CODE
, CURRENCY_CONVERSION_RATE
, CURRENCY_CONVERSION_TYPE
, CURRENCY_CONVERSION_DATE
, TAXABLE_ENTERED_DR
, TAXABLE_ENTERED_CR
, TAXABLE_ACCOUNTED_DR
, TAXABLE_ACCOUNTED_CR
, TAX_LINK_ID
, THIRD_PARTY_ID
, THIRD_PARTY_SUB_ID
, REVERSED_SOURCE_ID
, TAX_CODE_ID
, LOCATION_SEGMENT_ID
, SOURCE_TYPE_SECONDARY
, TAX_GROUP_CODE_ID
, REF_CUSTOMER_TRX_LINE_ID
, REF_CUST_TRX_LINE_GL_DIST_ID
, REF_ACCOUNT_CLASS
, ACTIVITY_BUCKET
, REF_LINE_ID
, FROM_AMOUNT_DR
, FROM_AMOUNT_CR
, FROM_ACCTD_AMOUNT_DR
, FROM_ACCTD_AMOUNT_CR
, REF_MF_DIST_FLAG
, REF_DIST_CCID)
SELECT
  ar_distributions_s.nextval     -- LINE_ID
, ard.SOURCE_ID                  -- SOURCE_ID
, ard.source_table               -- SOURCE_TABLE
, ard.SOURCE_TYPE                -- SOURCE_TYPE
, DECODE(double.side,'CASH',
           crh.account_code_combination_id,
           ard.CODE_COMBINATION_ID)  -- code_combination_id
, DECODE(double.side,'APP',
         --
         DECODE(SIGN(NVL(ard.AMOUNT_CR,0)-NVL(ard.AMOUNT_DR,0)),1,
              ABS(NVL(ard.AMOUNT_CR,0)-NVL(ard.AMOUNT_DR,0)),NULL),
         --
         DECODE(SIGN(NVL(ard.AMOUNT_CR,0)-NVL(ard.AMOUNT_DR,0)),1,
              NULL, ABS(NVL(ard.AMOUNT_CR,0)-NVL(ard.AMOUNT_DR,0))))     --AMOUNT_DR
--
, DECODE(double.side,'APP',
         DECODE(SIGN(NVL(ard.AMOUNT_CR,0)-NVL(ard.AMOUNT_DR,0)),1,
              NULL,ABS(NVL(ard.AMOUNT_DR,0)-NVL(ard.AMOUNT_CR,0))),
         --
         DECODE(SIGN(NVL(ard.AMOUNT_CR,0)-NVL(ard.AMOUNT_DR,0)),1,
              ABS(NVL(ard.AMOUNT_CR,0)-NVL(ard.AMOUNT_DR,0)),NULL))     --AMOUNT_CR
--
, DECODE(double.side,'APP',
         --
         DECODE(SIGN(NVL(ard.ACCTD_AMOUNT_CR,0)-NVL(ard.ACCTD_AMOUNT_DR,0)),1,
              ABS(NVL(ard.ACCTD_AMOUNT_CR,0)-NVL(ard.ACCTD_AMOUNT_DR,0)),NULL),
         --
         DECODE(SIGN(NVL(ard.ACCTD_AMOUNT_CR,0)-NVL(ard.ACCTD_AMOUNT_DR,0)),1,
              NULL, ABS(NVL(ard.ACCTD_AMOUNT_CR,0)-NVL(ard.ACCTD_AMOUNT_DR,0))))     --ACCTD_AMOUNT_DR
--
, DECODE(double.side,'APP',
         DECODE(SIGN(NVL(ard.ACCTD_AMOUNT_CR,0)-NVL(ard.ACCTD_AMOUNT_DR,0)),1,
              NULL,ABS(NVL(ard.ACCTD_AMOUNT_DR,0)-NVL(ard.ACCTD_AMOUNT_CR,0))),
         --
         DECODE(SIGN(NVL(ard.ACCTD_AMOUNT_CR,0)-NVL(ard.ACCTD_AMOUNT_DR,0)),1,
              ABS(NVL(ard.ACCTD_AMOUNT_CR,0)-NVL(ard.ACCTD_AMOUNT_DR,0)),NULL))     --ACCTD_AMOUNT_CR
--
, SYSDATE                        -- CREATION_DATE
, 0                              -- CREATED_BY
, 0                              -- LAST_UPDATED_BY
, SYSDATE                        -- LAST_UPDATE_DATE
, 0                              -- LAST_UPDATE_LOGIN
, ard.ORG_ID
, DECODE(double.side,'APP',
           'UPMFRAREAR','UPMFCRREAR')    -- SOURCE_TABLE_SECONDARY
, DECODE(double.side,'CASH'
         , crh.cash_receipt_history_id
         , ard.SOURCE_ID)                -- SOURCE_ID_SECONDARY
, ard.CURRENCY_CODE
, ard.CURRENCY_CONVERSION_RATE
, ard.CURRENCY_CONVERSION_TYPE
, ard.CURRENCY_CONVERSION_DATE
, ard.TAXABLE_ENTERED_DR
, ard.TAXABLE_ENTERED_CR
, ard.TAXABLE_ACCOUNTED_DR
, ard.TAXABLE_ACCOUNTED_CR
, ard.TAX_LINK_ID
, ard.THIRD_PARTY_ID
, ard.THIRD_PARTY_SUB_ID
, ard.REVERSED_SOURCE_ID
, ard.TAX_CODE_ID
, ard.LOCATION_SEGMENT_ID
, 'PSA_MF_RCT_DIST_ALL'          -- SOURCE_TYPE_SECONDARY
, ard.TAX_GROUP_CODE_ID
, ard.REF_CUSTOMER_TRX_LINE_ID
, ard.REF_CUST_TRX_LINE_GL_DIST_ID
, ard.REF_ACCOUNT_CLASS
, ard.ACTIVITY_BUCKET
, ard.REF_LINE_ID
--
, DECODE(double.side,'APP',
         --
         DECODE(SIGN(NVL(ard.AMOUNT_CR,0)-NVL(ard.AMOUNT_DR,0)),1,
              ABS(NVL(ard.AMOUNT_CR,0)-NVL(ard.AMOUNT_DR,0)),NULL),
         --
         DECODE(SIGN(NVL(ard.AMOUNT_CR,0)-NVL(ard.AMOUNT_DR,0)),1,
              NULL, ABS(NVL(ard.AMOUNT_CR,0)-NVL(ard.AMOUNT_DR,0))))     --FROM_AMOUNT_DR
--
, DECODE(double.side,'APP',
         DECODE(SIGN(NVL(ard.AMOUNT_CR,0)-NVL(ard.AMOUNT_DR,0)),1,
              NULL,ABS(NVL(ard.AMOUNT_DR,0)-NVL(ard.AMOUNT_CR,0))),
         --
         DECODE(SIGN(NVL(ard.AMOUNT_CR,0)-NVL(ard.AMOUNT_DR,0)),1,
              ABS(NVL(ard.AMOUNT_CR,0)-NVL(ard.AMOUNT_DR,0)),NULL))     --FROM_AMOUNT_CR
--
, DECODE(double.side,'APP',
         --
         DECODE(SIGN(NVL(ard.ACCTD_AMOUNT_CR,0)-NVL(ard.ACCTD_AMOUNT_DR,0)),1,
              ABS(NVL(ard.ACCTD_AMOUNT_CR,0)-NVL(ard.ACCTD_AMOUNT_DR,0)),NULL),
         --
         DECODE(SIGN(NVL(ard.ACCTD_AMOUNT_CR,0)-NVL(ard.ACCTD_AMOUNT_DR,0)),1,
              NULL, ABS(NVL(ard.ACCTD_AMOUNT_CR,0)-NVL(ard.ACCTD_AMOUNT_DR,0))))     --FROM_ACCTD_AMOUNT_DR
--
, DECODE(double.side,'APP',
         DECODE(SIGN(NVL(ard.ACCTD_AMOUNT_CR,0)-NVL(ard.ACCTD_AMOUNT_DR,0)),1,
              NULL,ABS(NVL(ard.ACCTD_AMOUNT_DR,0)-NVL(ard.ACCTD_AMOUNT_CR,0))),
         --
         DECODE(SIGN(NVL(ard.ACCTD_AMOUNT_CR,0)-NVL(ard.ACCTD_AMOUNT_DR,0)),1,
              ABS(NVL(ard.ACCTD_AMOUNT_CR,0)-NVL(ard.ACCTD_AMOUNT_DR,0)),NULL))     --FROM_ACCTD_AMOUNT_CR
--
, DECODE(double.side,'CASH','N','Y')                 -- REF_MF_DIST_FLAG
, ard.REF_DIST_CCID
FROM ar_receivable_applications_all       app,
     ar_distributions_all                 ard,
     (SELECT 'CASH' side FROM DUAL UNION
      SELECT 'APP'  side FROM DUAL )      double,
     ar_cash_receipt_history_all          crh
WHERE app.rowid                      >= l_start_rowid
  AND app.rowid                      <= l_end_rowid
  AND app.receivable_application_id  = ard.source_id
  AND ard.source_table               = 'RA'
  AND app.cash_receipt_history_id    = crh.cash_receipt_history_id(+)
  AND DECODE(double.side,'CASH',
            DECODE(crh.cash_receipt_history_id,
			       NULL,'N','Y'),
                  'APP' ,'Y')        = 'Y'
  AND EXISTS (SELECT NULL FROM  psa_mf_rct_dist_all  psa
               WHERE psa.receivable_application_id = app.receivable_application_id);

l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

-- UPgrade Multi Fund Receipt Application MIgrated to AR

INSERT INTO ar_distributions_all (
  LINE_ID
, SOURCE_ID
, SOURCE_TABLE
, SOURCE_TYPE
, CODE_COMBINATION_ID
, AMOUNT_DR
, AMOUNT_CR
, ACCTD_AMOUNT_DR
, ACCTD_AMOUNT_CR
, CREATION_DATE
, CREATED_BY
, LAST_UPDATED_BY
, LAST_UPDATE_DATE
, LAST_UPDATE_LOGIN
, ORG_ID
, SOURCE_TABLE_SECONDARY
, SOURCE_ID_SECONDARY
, CURRENCY_CODE
, CURRENCY_CONVERSION_RATE
, CURRENCY_CONVERSION_TYPE
, CURRENCY_CONVERSION_DATE
, TAXABLE_ENTERED_DR
, TAXABLE_ENTERED_CR
, TAXABLE_ACCOUNTED_DR
, TAXABLE_ACCOUNTED_CR
, TAX_LINK_ID
, THIRD_PARTY_ID
, THIRD_PARTY_SUB_ID
, REVERSED_SOURCE_ID
, TAX_CODE_ID
, LOCATION_SEGMENT_ID
, SOURCE_TYPE_SECONDARY
, TAX_GROUP_CODE_ID
, REF_CUSTOMER_TRX_LINE_ID
, REF_CUST_TRX_LINE_GL_DIST_ID
, REF_ACCOUNT_CLASS
, ACTIVITY_BUCKET
, REF_LINE_ID
, FROM_AMOUNT_DR
, FROM_AMOUNT_CR
, FROM_ACCTD_AMOUNT_DR
, FROM_ACCTD_AMOUNT_CR
, REF_MF_DIST_FLAG
, REF_DIST_CCID)
SELECT /*+ ordered rowid(app) use_nl(a,psatd,ctlgd,trx,crh) INDEX(a psa_mf_rct_dist_u1) INDEX(psatd psa_mf_trx_dist_u1)
 INDEX(ctlgd ra_cust_trx_line_gl_dist_u1) */
  ar_distributions_s.nextval          -- LINE_ID
, a.receivable_application_id         --SOURCE_ID
, 'RA'                                -- SOURCE_TABLE
, b.source_type
, DECODE(doub.side,'D',
     DECODE(SIGN( DECODE(b.source_type,
                 'REC'    ,a.amount,
                 'EDISC'  ,a.discount_amount,
                 'UNEDISC',a.ue_discount_amount)),1,
           DECODE( b.source_type,
                     'REC'    ,a.mf_cash_ccid,
                     'EDISC'  ,a.discount_ccid,
                     'UNEDISC',a.ue_discount_ccid),
           psatd.mf_receivables_ccid),
      DECODE(SIGN(DECODE
            ( b.source_type,
                  'REC'    ,a.amount,
                  'EDISC'  ,a.discount_amount,
                  'UNEDISC',a.ue_discount_amount)
                  ), 1 , psatd.mf_receivables_ccid,
           DECODE( b.source_type,
                       'REC'    ,a.mf_cash_ccid,
                       'EDISC'  ,a.discount_ccid,
                       'UNEDISC',a.ue_discount_ccid)))            -- CODE_COMBINATION_ID
, TO_NUMBER(DECODE(doub.side,'C',
        DECODE(SIGN(
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount)),1,
            DECODE( b.source_type,
                       'REC'    ,NULL,
                       'EDISC'  ,NULL,
                       'UNEDISC',NULL),
            DECODE( b.source_type,
                       'REC'    ,-1 * a.amount,
                       'EDISC'  ,-1 * a.discount_amount,
                       'UNEDISC',-1 * a.ue_discount_amount)),
        DECODE(SIGN(
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount)),1,
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount),
            DECODE( b.source_type,
                       'REC'    ,NULL,
                       'EDISC'  ,NULL,
                       'UNEDISC',NULL))))                     -- AMOUNT_DR
, TO_NUMBER(DECODE(doub.side,'D',
        DECODE(SIGN(
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount)),1,
            DECODE( b.source_type,
                       'REC'    ,NULL,
                       'EDISC'  ,NULL, --a.discount_amount,
                       'UNEDISC',NULL),
            DECODE( b.source_type,
                       'REC'    ,-1 * a.amount,
                       'EDISC'  ,-1 * a.discount_amount,
                       'UNEDISC',-1 * a.ue_discount_amount)),
        DECODE(SIGN(
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount)),1,
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount),
            DECODE( b.source_type,
                       'REC'    ,NULL,
                       'EDISC'  ,NULL,
                       'UNEDISC',NULL))))                   -- AMOUNT_CR
, TO_NUMBER(DECODE(doub.side,'C',
        DECODE(SIGN(
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount)),1,
            DECODE( b.source_type,
                       'REC'    ,NULL,
                       'EDISC'  ,NULL, --a.discount_amount,
                       'UNEDISC',NULL), --a.ue_discount_amount),
            DECODE( b.source_type,
                       'REC'    ,-1 * a.amount,
                       'EDISC'  ,-1 * a.discount_amount, --NULL,
                       'UNEDISC',-1 * a.ue_discount_amount)),
        DECODE(SIGN(
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount)),1,
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount, --NULL,
                       'UNEDISC',a.ue_discount_amount),
            DECODE( b.source_type,
                       'REC'    ,NULL,
                       'EDISC'  ,NULL,
                       'UNEDISC',NULL)))) -- ACCTD_AMOUNT_DR
, TO_NUMBER(DECODE(doub.side,'D',
        DECODE(SIGN(
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount)),1,
            DECODE( b.source_type,
                       'REC'    ,NULL,
                       'EDISC'  ,NULL, --a.discount_amount,
                       'UNEDISC',NULL),
            DECODE( b.source_type,
                       'REC'    ,-1 * a.amount,
                       'EDISC'  ,-1 * a.discount_amount,
                       'UNEDISC',-1 * a.ue_discount_amount)),
        DECODE(SIGN(
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount)),1,
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount),
            DECODE( b.source_type,
                       'REC'    ,NULL,
                       'EDISC'  ,NULL,
                       'UNEDISC',NULL)))) -- ACCTD_AMOUNT_CR
, SYSDATE                                             -- CREATION_DATE
, 0                                                   -- CREATED_BY
, 0                                                   -- LAST_UPDATED_BY
, SYSDATE                                             -- LAST_UPDATE_DATE
, 0                                                   -- LAST_UPDATE_LOGIN
, app.org_id                                          -- ORG_ID
,DECODE(doub.side,'D',
     DECODE(SIGN( DECODE(b.source_type,
                 'REC'    ,a.amount,
                 'EDISC'  ,a.discount_amount,
                 'UNEDISC',a.ue_discount_amount)),1,
           DECODE( b.source_type,
                     'REC'    ,DECODE(crh.status,NULL,'UPMFRAMIAR','UPMFCHMIAR'),
                     'EDISC'  ,'UPMFRAMIAR' ,
                     'UNEDISC','UPMFRAMIAR' ),
           DECODE( b.source_type,
                     'REC'    ,'UPMFRAMIAR',
                     'EDISC'  ,'UPMFRAMIAR',
                     'UNEDISC','UPMFRAMIAR')),
     DECODE(SIGN( DECODE(b.source_type,
                 'REC'    ,a.amount,
                 'EDISC'  ,a.discount_amount,
                 'UNEDISC',a.ue_discount_amount)),1,
           DECODE( b.source_type,
                     'REC'    ,'UPMFRAMIAR',
                     'EDISC'  ,'UPMFRAMIAR',
                     'UNEDISC','UPMFRAMIAR'),
           DECODE( b.source_type,
                     'REC'    , DECODE(crh.status,NULL,'UPMFRAMIAR','UPMFCHMIAR'),
                     'EDISC'  ,'UPMFRAMIAR',
                     'UNEDISC','UPMFRAMIAR')))   -- SOURCE_TABLE_SECONDARY
,DECODE(doub.side,'D',
     DECODE(SIGN( DECODE(b.source_type,
                 'REC'    ,a.amount,
                 'EDISC'  ,a.discount_amount,
                 'UNEDISC',a.ue_discount_amount)),1,
           DECODE( b.source_type,
                     'REC'    ,DECODE(crh.status,NULL,
                                      a.receivable_application_id,
                                      crh.cash_receipt_history_id),
                     'EDISC'  ,a.receivable_application_id ,
                     'UNEDISC',a.receivable_application_id ),
           DECODE( b.source_type,
                     'REC'    ,  a.receivable_application_id,
                     'EDISC'  ,a.receivable_application_id ,
                     'UNEDISC',a.receivable_application_id )),
     DECODE(SIGN( DECODE(b.source_type,
                 'REC'    ,a.amount,
                 'EDISC'  ,a.discount_amount,
                 'UNEDISC',a.ue_discount_amount)),1,
           DECODE( b.source_type,
                     'REC'    ,  a.receivable_application_id,
                     'EDISC'  ,a.receivable_application_id ,
                     'UNEDISC',a.receivable_application_id ),
           DECODE( b.source_type,
                     'REC'    , DECODE(crh.status,NULL,
                                      a.receivable_application_id,
                                      crh.cash_receipt_history_id),
                     'EDISC'  ,a.receivable_application_id ,
                     'UNEDISC',a.receivable_application_id ))) -- SOURCE_ID_SECONDARY
, trx.invoice_currency_code                           -- CURRENCY_CODE
, NULL                                                -- CURRENCY_CONVERSION_RATE
, NULL                                                -- CURRENCY_CONVERSION_TYPE
, NULL                                                -- CURRENCY_CONVERSION_DATE
, NULL                                                -- TAXABLE_ENTERED_DR
, NULL                                                -- TAXABLE_ENTERED_CR
, NULL                                                -- TAXABLE_ACCOUNTED_DR
, NULL                                                -- TAXABLE_ACCOUNTED_CR
, NULL                                                -- TAX_LINK_ID
, NULL                                                -- THIRD_PARTY_ID
, NULL                                                -- THIRD_PARTY_SUB_ID
, NULL                                                -- REVERSED_SOURCE_ID
, NULL                                                -- TAX_CODE_ID
, NULL                                                -- LOCATION_SEGMENT_ID
, 'PSA_MF_RCT_DIST_ALL'                               -- SOURCE_TYPE_SECONDARY
, NULL                                                -- TAX_GROUP_CODE_ID
, ctlgd.customer_trx_line_id                          -- REF_CUSTOMER_TRX_LINE_ID
, ctlgd.cust_trx_line_gl_dist_id                      -- REF_CUST_TRX_LINE_GL_DIST_ID
, ctlgd.account_class                                 -- REF_ACCOUNT_CLASS
, CASE
   WHEN b.source_type = 'REC' THEN
    DECODE(ctlgd.account_class, 'REV', 'APP_LINE',
                                'TAX', 'APP_TAX',
                                'FREIGHT', 'APP_FRT','APP_LINE')
   WHEN b.source_type = 'EDISC' THEN
    DECODE(ctlgd.account_class, 'REV', 'ED_LINE',
                                'TAX', 'ED_TAX',
                                'FREIGHT', 'ED_FRT','ED_LINE')
   ELSE
    DECODE(ctlgd.account_class, 'REV', 'UNED_LINE',
                                'TAX', 'UNED_TAX',
                                'FREIGHT', 'UNED_FRT','UNED_LINE')
  END                                                 -- ACTIVITY_BUCKET
, NULL                                                -- REF_LINE_ID
, TO_NUMBER(DECODE(doub.side,'C',
        DECODE(SIGN(
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount)),1,
            DECODE( b.source_type,
                       'REC'    ,NULL,
                       'EDISC'  ,NULL,
                       'UNEDISC',NULL),
            DECODE( b.source_type,
                       'REC'    ,-1 * a.amount,
                       'EDISC'  ,-1 * a.discount_amount,
                       'UNEDISC',-1 * a.ue_discount_amount)),
        DECODE(SIGN(
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount)),1,
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount),
            DECODE( b.source_type,
                       'REC'    ,NULL,
                       'EDISC'  ,NULL,
                       'UNEDISC',NULL)))) --FROM_AMOUNT_DR
, TO_NUMBER(DECODE(doub.side,'D',
        DECODE(SIGN(
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount)),1,
            DECODE( b.source_type,
                       'REC'    ,NULL,
                       'EDISC'  ,NULL,
                       'UNEDISC',NULL),
            DECODE( b.source_type,
                       'REC'    ,-1 * a.amount,
                       'EDISC'  ,-1 * a.discount_amount,
                       'UNEDISC',-1 * a.ue_discount_amount)),
        DECODE(SIGN(
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount)),1,
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount),
            DECODE( b.source_type,
                       'REC'    ,NULL,
                       'EDISC'  ,NULL,
                       'UNEDISC',NULL))))    -- FROM_AMOUNT_CR
, TO_NUMBER(DECODE(doub.side,'C',
        DECODE(SIGN(
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount)),1,
            DECODE( b.source_type,
                       'REC'    ,NULL,
                       'EDISC'  ,NULL,
                       'UNEDISC',NULL),
            DECODE( b.source_type,
                       'REC'    ,-1 * a.amount,
                       'EDISC'  ,-1 * a.discount_amount,
                       'UNEDISC',-1 * a.ue_discount_amount)),
        DECODE(SIGN(
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount)),1,
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount),
            DECODE( b.source_type,
                       'REC'    ,NULL,
                       'EDISC'  ,NULL,
                       'UNEDISC',NULL))))  --FROM_ACCTD_AMOUNT_DR
, TO_NUMBER(DECODE(doub.side,'D',
        DECODE(SIGN(
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount)),1,
            DECODE( b.source_type,
                       'REC'    ,NULL,
                       'EDISC'  ,NULL,
                       'UNEDISC',NULL),
            DECODE( b.source_type,
                       'REC'    ,-1 * a.amount,
                       'EDISC'  ,-1 * a.discount_amount,
                       'UNEDISC',-1 * a.ue_discount_amount)),
        DECODE(SIGN(
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount)),1,
            DECODE( b.source_type,
                       'REC'    ,a.amount,
                       'EDISC'  ,a.discount_amount,
                       'UNEDISC',a.ue_discount_amount),
            DECODE( b.source_type,
                       'REC'    ,NULL,
                       'EDISC'  ,NULL,
                       'UNEDISC',NULL))))   --FROM_ACCTD_AMOUNT_CR
,DECODE(doub.side,'D',
     DECODE(SIGN( DECODE(b.source_type,
                 'REC'    ,a.amount,
                 'EDISC'  ,a.discount_amount,
                 'UNEDISC',a.ue_discount_amount)),1,
           DECODE( b.source_type,
                     'REC'    ,DECODE(crh.status,NULL,'Y','N'),
                     'EDISC'  ,'Y' ,
                     'UNEDISC','Y' ),
           DECODE( b.source_type,
                     'REC'    ,'Y',
                     'EDISC'  ,'Y',
                     'UNEDISC','Y')),
     DECODE(SIGN( DECODE(b.source_type,
                 'REC'    ,a.amount,
                 'EDISC'  ,a.discount_amount,
                 'UNEDISC',a.ue_discount_amount)),1,
           DECODE( b.source_type,
                     'REC'    ,'Y',
                     'EDISC'  ,'Y',
                     'UNEDISC','Y'),
           DECODE( b.source_type,
                     'REC'    , DECODE(crh.status,NULL,'Y','N'),
                     'EDISC'  ,'Y',
                     'UNEDISC','Y'))) -- REF_MF_DIST_FLAG
, NULL                                                -- REF_DIST_CCID
FROM
       ar_receivable_applications_all                  app,
       psa_mf_rct_dist_all                             a,
       psa_mf_trx_dist_all                             psatd,
       ra_cust_trx_line_gl_dist_all                    ctlgd,
       (SELECT 'REC'   source_type   FROM DUAL UNION
        SELECT 'EDISC' source_type   FROM DUAL UNION
        SELECT 'UNEDISC' source_type FROM DUAL       ) b,
       (SELECT 'D' side FROM DUAL UNION
        SELECT 'C' side FROM DUAL                    ) doub,
       ra_customer_trx_all                             trx,
       ar_cash_receipt_history_all                     crh
WHERE app.rowid                     >= l_start_rowid
AND   app.rowid                     <= l_end_rowid
AND   app.receivable_application_id  = a.receivable_application_id
AND   a.cust_trx_line_gl_dist_id     = psatd.cust_trx_line_gl_dist_id
AND   psatd.cust_trx_line_gl_dist_id = ctlgd.cust_trx_line_gl_dist_id
AND   app.applied_customer_trx_id    = trx.customer_trx_id
AND   app.cash_receipt_history_id    = crh.cash_receipt_history_id(+)
AND   NVL(DECODE(b.source_type, 'REC'    ,a.AMOUNT,
                                'EDISC'  ,a.DISCOUNT_AMOUNT,
                                'UNEDISC',a.UE_DISCOUNT_AMOUNT),0) <> 0;



UPDATE ar_receivable_applications_all app
  SET upgrade_method = '11I_MFAR_UPG'
WHERE app.rowid                      >= l_start_rowid
  AND app.rowid                      <= l_end_rowid
  AND EXISTS (SELECT NULL FROM  psa_mf_rct_dist_all  psa
               WHERE psa.receivable_application_id = app.receivable_application_id);


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


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    RAISE;
END upgrade_applications;








PROCEDURE upgrade_misc_cash_dist(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2)
IS
l_start_rowid         rowid;
l_end_rowid           rowid;
l_any_rows_to_process boolean;
l_rows_processed      number := 0;
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




-- UPgrade Multi Fund Misc Cash distributions MIgrated to AR
-- Only the posted MCD need to be upgraded - non posted AAD will do it
INSERT INTO ar_distributions_all (
  LINE_ID
, SOURCE_ID
, SOURCE_TABLE
, SOURCE_TYPE
, CODE_COMBINATION_ID
, AMOUNT_DR
, AMOUNT_CR
, ACCTD_AMOUNT_DR
, ACCTD_AMOUNT_CR
, CREATION_DATE
, CREATED_BY
, LAST_UPDATED_BY
, LAST_UPDATE_DATE
, LAST_UPDATE_LOGIN
, ORG_ID
, SOURCE_TABLE_SECONDARY
, SOURCE_ID_SECONDARY
, CURRENCY_CODE
, CURRENCY_CONVERSION_RATE
, CURRENCY_CONVERSION_TYPE
, CURRENCY_CONVERSION_DATE
, TAXABLE_ENTERED_DR
, TAXABLE_ENTERED_CR
, TAXABLE_ACCOUNTED_DR
, TAXABLE_ACCOUNTED_CR
, TAX_LINK_ID
, THIRD_PARTY_ID
, THIRD_PARTY_SUB_ID
, REVERSED_SOURCE_ID
, TAX_CODE_ID
, LOCATION_SEGMENT_ID
, SOURCE_TYPE_SECONDARY
, TAX_GROUP_CODE_ID
, REF_CUSTOMER_TRX_LINE_ID
, REF_CUST_TRX_LINE_GL_DIST_ID
, REF_ACCOUNT_CLASS
, ACTIVITY_BUCKET
, REF_LINE_ID
, FROM_AMOUNT_DR
, FROM_AMOUNT_CR
, FROM_ACCTD_AMOUNT_DR
, FROM_ACCTD_AMOUNT_CR
, REF_MF_DIST_FLAG
, REF_DIST_CCID)
SELECT /*+ ordered rowid(mcd) use_nl(psamcd,cr) INDEX(psamcd psa_mf_misc_dist_u1) */
  ar_distributions_s.nextval                         -- LINE_ID
, psamcd.misc_cash_distribution_id                   -- SOURCE_ID
, 'MCD'                                              -- SOURCE_TABLE
, 'MISCCASH'                                         -- SOURCE_TYPE
, CASE
    WHEN doub.side = 'C' THEN
          DECODE(SIGN(mcd.amount),
                  1, psamcd.cash_ccid,
                     psamcd.distribution_ccid)
    ELSE
          DECODE(SIGN(mcd.amount),
                 -1, psamcd.cash_ccid,
                     psamcd.distribution_ccid)
    END                                              -- CODE_COMBINATION_ID
, DECODE(doub.side,'D',ABS(mcd.amount),NULL   )      -- AMOUNT_DR
, DECODE(doub.side,'C',ABS(mcd.amount),NULL   )      -- AMOUNT_CR
, DECODE(doub.side,'D',ABS(mcd.amount),NULL   )      -- ACCTD_AMOUNT_DR
, DECODE(doub.side,'C',ABS(mcd.amount),NULL   )      -- ACCTD_AMOUNT_CR
, SYSDATE                                            -- CREATION_DATE
, 0                                                  -- CREATED_BY
, 0                                                  -- LAST_UPDATED_BY
, SYSDATE                                            -- LAST_UPDATE_DATE
, 0                                                  -- LAST_UPDATE_LOGIN
, mcd.org_id                                         -- ORG_ID
, CASE
    WHEN doub.side = 'C' THEN
          DECODE(SIGN(mcd.amount),
                  1, 'UPMFMCMIAR',
                     'UPMFMCREAR')
    ELSE
          DECODE(SIGN(mcd.amount),
                 -1, 'UPMFMCMIAR',
                     'UPMFMCREAR')
    END                                              -- SOURCE_TABLE_SECONDARY
, NULL                                               -- SOURCE_ID_SECONDARY
, cr.currency_code                                   -- CURRENCY_CODE
, NULL                                               -- CURRENCY_CONVERSION_RATE
, NULL                                               -- CURRENCY_CONVERSION_TYPE
, NULL                                               -- CURRENCY_CONVERSION_DATE
, NULL                                               -- TAXABLE_ENTERED_DR
, NULL                                               -- TAXABLE_ENTERED_CR
, NULL                                               -- TAXABLE_ACCOUNTED_DR
, NULL                                               -- TAXABLE_ACCOUNTED_CR
, NULL                                               -- TAX_LINK_ID
, NULL                                               -- THIRD_PARTY_ID
, NULL                                               -- THIRD_PARTY_SUB_ID
, NULL                                               -- REVERSED_SOURCE_ID
, NULL                                               -- TAX_CODE_ID
, NULL                                               -- LOCATION_SEGMENT_ID
, 'PSA_MF_MISC_DIST_ALL'                             -- SOURCE_TYPE_SECONDARY
, NULL                                               -- TAX_GROUP_CODE_ID
, NULL                                               -- REF_CUSTOMER_TRX_LINE_ID
, NULL                                               -- REF_CUST_TRX_LINE_GL_DIST_ID
, NULL                                               -- REF_ACCOUNT_CLASS
, NULL                                               -- ACTIVITY_BUCKET
, NULL                                               -- REF_LINE_ID
, DECODE(doub.side,'D',ABS(mcd.amount),NULL   )      -- FROM_AMOUNT_DR
, DECODE(doub.side,'C',ABS(mcd.amount),NULL   )      -- FROM_AMOUNT_CR
, DECODE(doub.side,'D',ABS(mcd.amount),NULL   )      -- FROM_ACCTD_AMOUNT_DR
, DECODE(doub.side,'C',ABS(mcd.amount),NULL   )      -- FROM_ACCTD_AMOUNT_CR
, NULL                                               -- REF_MF_DIST_FLAG
, NULL                                               -- REF_DIST_CCID
FROM ar_misc_cash_distributions_all mcd,
     psa_mf_misc_dist_all           psamcd,
     ar_cash_receipts_all           cr,
     (SELECT 'D' side FROM DUAL UNION ALL
      SELECT 'C' side FROM DUAL)    doub
WHERE mcd.rowid                     >= l_start_rowid
  AND mcd.rowid                     <= l_end_rowid
  AND mcd.misc_cash_distribution_id = psamcd.misc_cash_distribution_id
  AND mcd.cash_receipt_id           = cr.cash_receipt_id
  AND mcd.posting_control_id       <> -3;


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


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    RAISE;
END upgrade_misc_cash_dist;






PROCEDURE UPGRADE_TRANSACTIONS(
                       l_table_owner  IN VARCHAR2,
                       l_table_name   IN VARCHAR2,
                       l_script_name  IN VARCHAR2,
                       l_worker_id    IN VARCHAR2,
                       l_num_workers  IN VARCHAR2,
                       l_batch_size   IN VARCHAR2,
                       l_batch_id     IN NUMBER,
                       l_action_flag  IN VARCHAR2)
IS
ln_AE_HEADER_ID                 DBMS_SQL.NUMBER_TABLE;
ln_AE_LINE_NUM                  DBMS_SQL.NUMBER_TABLE;
ln_APPLICATION_ID               DBMS_SQL.NUMBER_TABLE;
ln_CODE_COMBINATION_ID          DBMS_SQL.NUMBER_TABLE;
ln_GL_TRANSFER_MODE_CODE        DBMS_SQL.VARCHAR2_TABLE;
ln_GL_SL_LINK_ID                DBMS_SQL.NUMBER_TABLE;
ln_ACCOUNTING_CLASS_CODE        DBMS_SQL.VARCHAR2_TABLE;
ln_PARTY_ID                     DBMS_SQL.NUMBER_TABLE;
ln_PARTY_SITE_ID                DBMS_SQL.NUMBER_TABLE;
ln_PARTY_TYPE_CODE              DBMS_SQL.VARCHAR2_TABLE;
ln_ENTERED_DR                   DBMS_SQL.NUMBER_TABLE;
ln_ENTERED_CR                   DBMS_SQL.NUMBER_TABLE;
ln_ACCOUNTED_DR                 DBMS_SQL.NUMBER_TABLE;
ln_ACCOUNTED_CR                 DBMS_SQL.NUMBER_TABLE;
ln_DESCRIPTION                  DBMS_SQL.VARCHAR2_TABLE;
ln_STATISTICAL_AMOUNT           DBMS_SQL.NUMBER_TABLE;
ln_CURRENCY_CODE                DBMS_SQL.VARCHAR2_TABLE;
ln_CURRENCY_CONVERSION_DATE     DBMS_SQL.DATE_TABLE;
ln_CURRENCY_CONVERSION_RATE     DBMS_SQL.NUMBER_TABLE;
ln_CURRENCY_CONVERSION_TYPE     DBMS_SQL.VARCHAR2_TABLE;
ln_USSGL_TRANSACTION_CODE       DBMS_SQL.VARCHAR2_TABLE;
ln_JGZZ_RECON_REF               DBMS_SQL.VARCHAR2_TABLE;
ln_CONTROL_BALANCE_FLAG         DBMS_SQL.VARCHAR2_TABLE;
ln_ANALYTICAL_BALANCE_FLAG      DBMS_SQL.VARCHAR2_TABLE;
ln_GL_SL_LINK_TABLE             DBMS_SQL.VARCHAR2_TABLE;
ln_DISPLAYED_LINE_NUMBER        DBMS_SQL.NUMBER_TABLE;
ln_UPG_BATCH_ID                 DBMS_SQL.NUMBER_TABLE;
ln_UNROUNDED_ACCOUNTED_DR       DBMS_SQL.NUMBER_TABLE;
ln_UNROUNDED_ACCOUNTED_CR       DBMS_SQL.NUMBER_TABLE;
ln_GAIN_OR_LOSS_FLAG            DBMS_SQL.VARCHAR2_TABLE;
ln_UNROUNDED_ENTERED_DR         DBMS_SQL.NUMBER_TABLE;
ln_UNROUNDED_ENTERED_CR         DBMS_SQL.NUMBER_TABLE;
ln_SUBSTITUTED_CCID             DBMS_SQL.NUMBER_TABLE;
ln_BUSINESS_CLASS_CODE          DBMS_SQL.VARCHAR2_TABLE;
ln_MPA_ACCRUAL_ENTRY_FLAG       DBMS_SQL.VARCHAR2_TABLE;
ln_ENCUMBRANCE_TYPE_ID          DBMS_SQL.NUMBER_TABLE;
ln_FUNDS_STATUS_CODE            DBMS_SQL.VARCHAR2_TABLE;
ln_MERGE_CODE_COMBINATION_ID    DBMS_SQL.NUMBER_TABLE;
ln_MERGE_PARTY_ID               DBMS_SQL.NUMBER_TABLE;
ln_MERGE_PARTY_SITE_ID          DBMS_SQL.NUMBER_TABLE;
ln_accounting_date              DBMS_SQL.DATE_TABLE;
ln_ledger_id                    DBMS_SQL.NUMBER_TABLE;

ev_EVENT_ID                     DBMS_SQL.NUMBER_TABLE;
ev_APPLICATION_ID               DBMS_SQL.NUMBER_TABLE;
ev_EVENT_TYPE_CODE              DBMS_SQL.VARCHAR2_TABLE;
ev_EVENT_DATE                   DBMS_SQL.DATE_TABLE;
ev_ENTITY_ID                    DBMS_SQL.NUMBER_TABLE;
ev_EVENT_STATUS_CODE            DBMS_SQL.VARCHAR2_TABLE;
ev_PROCESS_STATUS_CODE          DBMS_SQL.VARCHAR2_TABLE;
ev_REFERENCE_NUM_1              DBMS_SQL.NUMBER_TABLE;
ev_EVENT_NUMBER                 DBMS_SQL.NUMBER_TABLE;
ctlgd_CUST_TRX_LINE_GL_DIST_ID  DBMS_SQL.NUMBER_TABLE;
ctlgd_CUSTOMER_TRX_LINE_ID      DBMS_SQL.NUMBER_TABLE;
ctlgd_CODE_COMBINATION_ID       DBMS_SQL.NUMBER_TABLE;
ctlgd_SET_OF_BOOKS_ID           DBMS_SQL.NUMBER_TABLE;
ctlgd_AMOUNT                    DBMS_SQL.NUMBER_TABLE;
ctlgd_ACCTD_AMOUNT              DBMS_SQL.NUMBER_TABLE;
ctlgd_GL_DATE                   DBMS_SQL.DATE_TABLE;
ctlgd_GL_POSTED_DATE            DBMS_SQL.DATE_TABLE;
ctlgd_ACCOUNT_CLASS             DBMS_SQL.VARCHAR2_TABLE;
ctlgd_posting_control_id        DBMS_SQL.NUMBER_TABLE;
pd_CUST_TRX_LINE_GL_DIST_ID     DBMS_SQL.NUMBER_TABLE;
pd_MF_RECEIVABLES_CCID          DBMS_SQL.NUMBER_TABLE;
pd_POSTING_CONTROL_ID           DBMS_SQL.NUMBER_TABLE;
cnt_by_hdr                      DBMS_SQL.NUMBER_TABLE;
pdf_cust_trx_line_gl_dist_id    DBMS_SQL.NUMBER_TABLE;

CURSOR c(l_start_rowid ROWID, l_end_rowid ROWID) IS
SELECT /*+  leading(pd,ctlgd,gud) rowid(pd) use_nl(ctlgd,ct,ent,ev,hdr,ln,lnk) use_hash(gud) swap_join_inputs(gud)
	    INDEX(ent xla_transaction_entities_N1)
	    INDEX(ev XLA_EVENTS_U2)
	    INDEX(hdr XLA_AE_HEADERS_N2)
            INDEX (ln, XLA_AE_LINES_U1)
            INDEX (lnk, XLA_DISTRIBUTION_LINKS_N1) */
  ln.AE_HEADER_ID
, ln.AE_LINE_NUM
, ln.APPLICATION_ID
, ln.CODE_COMBINATION_ID
, ln.GL_TRANSFER_MODE_CODE
, ln.GL_SL_LINK_ID
, ln.ACCOUNTING_CLASS_CODE
, ln.PARTY_ID
, ln.PARTY_SITE_ID
, ln.PARTY_TYPE_CODE
, ln.ENTERED_DR
, ln.ENTERED_CR
, ln.ACCOUNTED_DR
, ln.ACCOUNTED_CR
, ln.DESCRIPTION
, ln.STATISTICAL_AMOUNT
, ln.CURRENCY_CODE
, ln.CURRENCY_CONVERSION_DATE
, ln.CURRENCY_CONVERSION_RATE
, ln.CURRENCY_CONVERSION_TYPE
, ln.USSGL_TRANSACTION_CODE
, ln.JGZZ_RECON_REF
, ln.CONTROL_BALANCE_FLAG
, ln.ANALYTICAL_BALANCE_FLAG
, ln.GL_SL_LINK_TABLE
, ln.DISPLAYED_LINE_NUMBER
, ln.UPG_BATCH_ID
, ln.UNROUNDED_ACCOUNTED_DR
, ln.UNROUNDED_ACCOUNTED_CR
, ln.GAIN_OR_LOSS_FLAG
, ln.UNROUNDED_ENTERED_DR
, ln.UNROUNDED_ENTERED_CR
, ln.SUBSTITUTED_CCID
, ln.BUSINESS_CLASS_CODE
, ln.MPA_ACCRUAL_ENTRY_FLAG
, ln.ENCUMBRANCE_TYPE_ID
, ln.FUNDS_STATUS_CODE
, ln.MERGE_CODE_COMBINATION_ID
, ln.MERGE_PARTY_ID
, ln.MERGE_PARTY_SITE_ID
, ev.EVENT_ID
, ev.APPLICATION_ID
, ev.EVENT_TYPE_CODE
, ev.EVENT_DATE
, ev.ENTITY_ID
, ev.EVENT_STATUS_CODE
, ev.PROCESS_STATUS_CODE
, ev.REFERENCE_NUM_1
, ev.EVENT_NUMBER
, ctlgd.CUST_TRX_LINE_GL_DIST_ID
, ctlgd.CUSTOMER_TRX_LINE_ID
, ctlgd.CODE_COMBINATION_ID
, ctlgd.SET_OF_BOOKS_ID
, ctlgd.AMOUNT
, ctlgd.ACCTD_AMOUNT
, ctlgd.GL_DATE
, ctlgd.GL_POSTED_DATE
, ctlgd.ACCOUNT_CLASS
, ctlgd.posting_control_id
, pd.CUST_TRX_LINE_GL_DIST_ID
, pd.MF_RECEIVABLES_CCID
, pd.POSTING_CONTROL_ID
, MAX(ln.ae_line_num) OVER (PARTITION BY ln.ae_header_id)  cnt_by_hdr
, pd.cust_trx_line_gl_dist_id
, ln.accounting_date
, ln.ledger_id
  FROM   ra_customer_trx_all            ct
       , ra_cust_trx_line_gl_dist_all   ctlgd
       , xla_upgrade_dates              gud
       , xla_transaction_entities_upg   ent
       , xla_events                     ev
       , xla_ae_headers                 hdr
       , xla_ae_lines                   ln
       , xla_distribution_links         lnk
       , psa_mf_trx_dist_all            pd
 WHERE pd.ROWID                      >= l_start_rowid
   AND pd.ROWID                      <= l_end_rowid
   AND ct.customer_trx_id            = ctlgd.customer_trx_id
   AND ctlgd.cust_trx_line_gl_dist_id = pd.cust_trx_line_gl_dist_id
   AND NVL(ct.ax_accounted_flag,'N') = 'N'
   AND ctlgd.account_set_flag        = 'N'
   AND trunc(ctlgd.gl_date)          BETWEEN gud.start_date AND gud.end_date
   AND CTLGD.set_of_books_id         = gud.ledger_id      -- changed this from ct to ctlgd to enable better join to GUD
   AND ent.ledger_id                 = ct.set_of_books_id
   AND ent.application_id            = 222
   AND ent.entity_code               = 'TRANSACTIONS'
   AND ev.application_id             = 222
   AND hdr.application_id            = 222
   AND ln.application_id             = 222
   AND lnk.application_id            = 222
   AND ent.entity_id                 = ev.entity_id
   AND ent.ledger_id                 = ct.set_of_books_id
   AND ev.upg_batch_id               = l_batch_id
   AND ev.event_id                   = hdr.event_id
   AND hdr.ledger_id                 = ent.ledger_id
   AND hdr.event_id                  = ev.event_id
   AND hdr.ae_header_id              = ln.ae_header_id
   AND hdr.ae_header_id              = lnk.ae_header_id
   AND ln.ae_line_num                = lnk.ae_line_num
   AND lnk.event_id                  = ev.event_id
   AND lnk.source_distribution_id_num_1 = ctlgd.cust_trx_line_gl_dist_id
   AND lnk.source_distribution_type     = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
   AND nvl(ent.source_id_int_1,-99)  = ct.customer_trx_id
   AND ev.reference_num_1            = ctlgd.posting_control_id
   AND NVL(TRUNC(ctlgd.gl_date), to_date('01-01-1900','DD-MM-YYYY')) = ev.event_date
UNION
SELECT /*+  leading(pd,ct,ctlgd,gud) rowid(pd) use_nl(ctlgd,ct,ent,ev,hdr,ln,lnk) use_hash(gud) swap_join_inputs(gud)
	    INDEX(ent xla_transaction_entities_N1)
	    INDEX(ev XLA_EVENTS_U2)
	    INDEX(hdr XLA_AE_HEADERS_N2)
            INDEX (ln, XLA_AE_LINES_U1)
            INDEX (lnk, XLA_DISTRIBUTION_LINKS_N1) */
  ln.AE_HEADER_ID
, ln.AE_LINE_NUM
, ln.APPLICATION_ID
, ln.CODE_COMBINATION_ID
, ln.GL_TRANSFER_MODE_CODE
, ln.GL_SL_LINK_ID
, ln.ACCOUNTING_CLASS_CODE
, ln.PARTY_ID
, ln.PARTY_SITE_ID
, ln.PARTY_TYPE_CODE
, ln.ENTERED_DR
, ln.ENTERED_CR
, ln.ACCOUNTED_DR
, ln.ACCOUNTED_CR
, ln.DESCRIPTION
, ln.STATISTICAL_AMOUNT
, ln.CURRENCY_CODE
, ln.CURRENCY_CONVERSION_DATE
, ln.CURRENCY_CONVERSION_RATE
, ln.CURRENCY_CONVERSION_TYPE
, ln.USSGL_TRANSACTION_CODE
, ln.JGZZ_RECON_REF
, ln.CONTROL_BALANCE_FLAG
, ln.ANALYTICAL_BALANCE_FLAG
, ln.GL_SL_LINK_TABLE
, ln.DISPLAYED_LINE_NUMBER
, ln.UPG_BATCH_ID
, ln.UNROUNDED_ACCOUNTED_DR
, ln.UNROUNDED_ACCOUNTED_CR
, ln.GAIN_OR_LOSS_FLAG
, ln.UNROUNDED_ENTERED_DR
, ln.UNROUNDED_ENTERED_CR
, ln.SUBSTITUTED_CCID
, ln.BUSINESS_CLASS_CODE
, ln.MPA_ACCRUAL_ENTRY_FLAG
, ln.ENCUMBRANCE_TYPE_ID
, ln.FUNDS_STATUS_CODE
, ln.MERGE_CODE_COMBINATION_ID
, ln.MERGE_PARTY_ID
, ln.MERGE_PARTY_SITE_ID
, ev.EVENT_ID
, ev.APPLICATION_ID
, ev.EVENT_TYPE_CODE
, ev.EVENT_DATE
, ev.ENTITY_ID
, ev.EVENT_STATUS_CODE
, ev.PROCESS_STATUS_CODE
, ev.REFERENCE_NUM_1
, ev.EVENT_NUMBER
, ctlgd.CUST_TRX_LINE_GL_DIST_ID
, ctlgd.CUSTOMER_TRX_LINE_ID
, ctlgd.CODE_COMBINATION_ID
, ctlgd.SET_OF_BOOKS_ID
, ctlgd.AMOUNT
, ctlgd.ACCTD_AMOUNT
, ctlgd.GL_DATE
, ctlgd.GL_POSTED_DATE
, ctlgd.ACCOUNT_CLASS
, ctlgd.posting_control_id
, ctlgd.CUST_TRX_LINE_GL_DIST_ID
, NULL
, ctlgd.POSTING_CONTROL_ID
, 999999999    cnt_by_hdr
, ctlgd.cust_trx_line_gl_dist_id
, ln.accounting_date
, ln.ledger_id
  FROM   ra_customer_trx_all                             ct
       , ra_cust_trx_line_gl_dist_all                    ctlgd
       , xla_upgrade_dates                               gud
       , xla_transaction_entities_upg                    ent
       , xla_events                                      ev
       , xla_ae_headers                                  hdr
       , xla_ae_lines                                    ln
       , xla_distribution_links                          lnk
       ,(SELECT /*+ rowid(pdist) use_nl(dist) no_merge */ dist.customer_trx_id
           FROM ra_cust_trx_line_gl_dist_all dist,
                psa_mf_trx_dist_all          pdist,
		xla_upgrade_dates            xud
          WHERE pdist.cust_trx_line_gl_dist_id = dist.cust_trx_line_gl_dist_id
          AND   trunc(dist.gl_date)  between xud.start_date and xud.end_date
	  AND   pdist.ROWID                      >= l_start_rowid
          AND   pdist.ROWID                      <= l_end_rowid
	  AND NOT EXISTS
	  (  SELECT /*+ordered */ 'x'
	     FROM xla_transaction_entities_upg xte,
		  xla_ae_headers xah,
		  xla_ae_lines xal
	     WHERE nvl(xte.source_id_int_1,-99)  = dist.customer_trx_id
	      AND xte.ledger_id                   = dist.set_of_books_id
	      AND xte.application_id              = 222
	      AND xte.entity_code                 = 'TRANSACTIONS'
	      AND xte.entity_id                   = xah.entity_id
	      AND xah.application_id              = 222
	      AND xte.ledger_id                   = xah.ledger_id
	      AND xah.ae_header_id                = xal.ae_header_id
	      AND xal.application_id              = 222
	      AND xal.accounting_class_code       = 'RECEIVABLE'
	      AND xal.ae_line_num                 > 999999999
	      AND xal.accounting_date between xud.start_date and xud.end_date
          )
          GROUP BY dist.customer_trx_id
        ) pd
   WHERE ct.customer_trx_id            = pd.customer_trx_id
   AND ct.customer_trx_id            = ctlgd.customer_trx_id
   AND ctlgd.account_class           = 'REC'
   AND ctlgd.account_set_flag        = 'N'
   AND NVL(ct.ax_accounted_flag,'N') = 'N'
   AND trunc(ctlgd.gl_date)          BETWEEN gud.start_date AND gud.end_date
   AND CTLGD.set_of_books_id            = gud.ledger_id   -- changed this from ct to ctlgd to enable better join to GUD
   AND ent.ledger_id                 = ct.set_of_books_id
   AND ent.application_id            = 222
   AND ent.entity_code               = 'TRANSACTIONS'
   AND ev.upg_batch_id               = l_batch_id
   AND ev.application_id             = 222
   AND hdr.application_id            = 222
   AND ln.application_id             = 222
   AND lnk.application_id            = 222
   AND ent.entity_id                 = ev.entity_id
   AND ent.ledger_id                 = ct.set_of_books_id
   AND ev.event_id                   = hdr.event_id
   AND hdr.ledger_id                 = ent.ledger_id
   AND hdr.event_id                  = ev.event_id
   AND hdr.ae_header_id              = ln.ae_header_id
   AND hdr.ae_header_id              = lnk.ae_header_id
   AND ln.ae_line_num                = lnk.ae_line_num
   AND lnk.event_id                  = ev.event_id
   AND lnk.source_distribution_id_num_1 = ctlgd.cust_trx_line_gl_dist_id
   AND lnk.source_distribution_type     = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
   AND nvl(ent.source_id_int_1,-99)  = ct.customer_trx_id
   AND ev.reference_num_1            = ctlgd.posting_control_id
   AND NVL(TRUNC(ctlgd.gl_date), to_date('01-01-1900','DD-MM-YYYY')) = ev.event_date;



--xla_ae_lines

 LAE_HEADER_ID                  DBMS_SQL.NUMBER_TABLE;
 LAE_LINE_NUM                   DBMS_SQL.NUMBER_TABLE;
 LAPPLICATION_ID                DBMS_SQL.NUMBER_TABLE;
 LCODE_COMBINATION_ID           DBMS_SQL.NUMBER_TABLE;
 LGL_TRANSFER_MODE_CODE         DBMS_SQL.VARCHAR2_TABLE;
 LGL_SL_LINK_ID                 DBMS_SQL.VARCHAR2_TABLE;
 LACCOUNTING_CLASS_CODE         DBMS_SQL.VARCHAR2_TABLE;
 LPARTY_ID                      DBMS_SQL.NUMBER_TABLE;
 LPARTY_SITE_ID                 DBMS_SQL.NUMBER_TABLE;
 LPARTY_TYPE_CODE               DBMS_SQL.VARCHAR2_TABLE;
 LENTERED_DR                    DBMS_SQL.NUMBER_TABLE;
 LENTERED_CR                    DBMS_SQL.NUMBER_TABLE;
 LACCOUNTED_DR                  DBMS_SQL.NUMBER_TABLE;
 LACCOUNTED_CR                  DBMS_SQL.NUMBER_TABLE;
 LDESCRIPTION                   DBMS_SQL.VARCHAR2_TABLE;
 LSTATISTICAL_AMOUNT            DBMS_SQL.NUMBER_TABLE;
 LCURRENCY_CODE                 DBMS_SQL.VARCHAR2_TABLE;
 LCURRENCY_CONVERSION_DATE      DBMS_SQL.DATE_TABLE;
 LCURRENCY_CONVERSION_RATE      DBMS_SQL.NUMBER_TABLE;
 LCURRENCY_CONVERSION_TYPE      DBMS_SQL.VARCHAR2_TABLE;
 LUSSGL_TRANSACTION_CODE        DBMS_SQL.VARCHAR2_TABLE;
 LJGZZ_RECON_REF                DBMS_SQL.VARCHAR2_TABLE;
 LCONTROL_BALANCE_FLAG          DBMS_SQL.VARCHAR2_TABLE;
 LANALYTICAL_BALANCE_FLAG       DBMS_SQL.VARCHAR2_TABLE;
 LGL_SL_LINK_TABLE              DBMS_SQL.VARCHAR2_TABLE;
 LDISPLAYED_LINE_NUMBER         DBMS_SQL.NUMBER_TABLE;
 LUPG_BATCH_ID                  DBMS_SQL.NUMBER_TABLE;
 LUNROUNDED_ACCOUNTED_DR        DBMS_SQL.NUMBER_TABLE;
 LUNROUNDED_ACCOUNTED_CR        DBMS_SQL.NUMBER_TABLE;
 LGAIN_OR_LOSS_FLAG             DBMS_SQL.VARCHAR2_TABLE;
 LUNROUNDED_ENTERED_DR          DBMS_SQL.NUMBER_TABLE;
 LUNROUNDED_ENTERED_CR          DBMS_SQL.NUMBER_TABLE;
 LBUSINESS_CLASS_CODE           DBMS_SQL.VARCHAR2_TABLE;
 laccounting_date               DBMS_SQL.DATE_TABLE;
 lledger_id                     DBMS_SQL.NUMBER_TABLE;


--xla_distribution_links

 DAPPLICATION_ID                DBMS_SQL.NUMBER_TABLE;
 DEVENT_ID                      DBMS_SQL.NUMBER_TABLE;
 DAE_HEADER_ID                  DBMS_SQL.NUMBER_TABLE;
 DAE_LINE_NUM                   DBMS_SQL.NUMBER_TABLE;
 DSOURCE_DISTRIBUTION_TYPE      DBMS_SQL.VARCHAR2_TABLE;
 DSOURCE_DISTRIBUTION_ID_NUM_1  DBMS_SQL.NUMBER_TABLE;
 DTAX_LINE_REF_ID               DBMS_SQL.NUMBER_TABLE;
 DREF_AE_HEADER_ID              DBMS_SQL.NUMBER_TABLE;
 DREF_TEMP_LINE_NUM             DBMS_SQL.NUMBER_TABLE;
 DACCOUNTING_LINE_CODE          DBMS_SQL.VARCHAR2_TABLE;
 DACCOUNTING_LINE_TYPE_CODE     DBMS_SQL.VARCHAR2_TABLE;
 DMERGE_DUPLICATE_CODE          DBMS_SQL.VARCHAR2_TABLE;
 DTEMP_LINE_NUM                 DBMS_SQL.NUMBER_TABLE;
 DREF_EVENT_ID                  DBMS_SQL.NUMBER_TABLE;
 DEVENT_CLASS_CODE              DBMS_SQL.VARCHAR2_TABLE;
 DEVENT_TYPE_CODE               DBMS_SQL.VARCHAR2_TABLE;
 DUPG_BATCH_ID                  DBMS_SQL.NUMBER_TABLE;
 DUNROUNDED_ENTERED_DR          DBMS_SQL.NUMBER_TABLE;
 DUNROUNDED_ENTERED_CR          DBMS_SQL.NUMBER_TABLE;
 DUNROUNDED_ACCOUNTED_CR        DBMS_SQL.NUMBER_TABLE;
 DUNROUNDED_ACCOUNTED_DR        DBMS_SQL.NUMBER_TABLE;

 empty_varchar2_list            DBMS_SQL.VARCHAR2_TABLE;
 empty_number_list              DBMS_SQL.NUMBER_TABLE;
 empty_date_list                DBMS_SQL.DATE_TABLE;


l_sys_date            DATE := SYSDATE;

l_start_rowid         rowid;
l_end_rowid           rowid;
l_any_rows_to_process BOOLEAN;
l_rows_processed      NUMBER  := 0;
l_last_fetch          BOOLEAN := FALSE;
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

  OPEN c(l_start_rowid, l_end_rowid);
  LOOP
    FETCH c BULK COLLECT INTO
                 ln_AE_HEADER_ID
                ,ln_AE_LINE_NUM
                ,ln_APPLICATION_ID
                ,ln_CODE_COMBINATION_ID
                ,ln_GL_TRANSFER_MODE_CODE
                ,ln_GL_SL_LINK_ID
                ,ln_ACCOUNTING_CLASS_CODE
                ,ln_PARTY_ID
                ,ln_PARTY_SITE_ID
                ,ln_PARTY_TYPE_CODE
                ,ln_ENTERED_DR
                ,ln_ENTERED_CR
                ,ln_ACCOUNTED_DR
                ,ln_ACCOUNTED_CR
                ,ln_DESCRIPTION
                ,ln_STATISTICAL_AMOUNT
                ,ln_CURRENCY_CODE
                ,ln_CURRENCY_CONVERSION_DATE
                ,ln_CURRENCY_CONVERSION_RATE
                ,ln_CURRENCY_CONVERSION_TYPE
                ,ln_USSGL_TRANSACTION_CODE
                ,ln_JGZZ_RECON_REF
                ,ln_CONTROL_BALANCE_FLAG
                ,ln_ANALYTICAL_BALANCE_FLAG
                ,ln_GL_SL_LINK_TABLE
                ,ln_DISPLAYED_LINE_NUMBER
                ,ln_UPG_BATCH_ID
                ,ln_UNROUNDED_ACCOUNTED_DR
                ,ln_UNROUNDED_ACCOUNTED_CR
                ,ln_GAIN_OR_LOSS_FLAG
                ,ln_UNROUNDED_ENTERED_DR
                ,ln_UNROUNDED_ENTERED_CR
                ,ln_SUBSTITUTED_CCID
                ,ln_BUSINESS_CLASS_CODE
                ,ln_MPA_ACCRUAL_ENTRY_FLAG
                ,ln_ENCUMBRANCE_TYPE_ID
                ,ln_FUNDS_STATUS_CODE
                ,ln_MERGE_CODE_COMBINATION_ID
                ,ln_MERGE_PARTY_ID
                ,ln_MERGE_PARTY_SITE_ID
                ,ev_EVENT_ID
                ,ev_APPLICATION_ID
                ,ev_EVENT_TYPE_CODE
                ,ev_EVENT_DATE
                ,ev_ENTITY_ID
                ,ev_EVENT_STATUS_CODE
                ,ev_PROCESS_STATUS_CODE
                ,ev_REFERENCE_NUM_1
                ,ev_EVENT_NUMBER
                ,ctlgd_CUST_TRX_LINE_GL_DIST_ID
                ,ctlgd_CUSTOMER_TRX_LINE_ID
                ,ctlgd_CODE_COMBINATION_ID
                ,ctlgd_SET_OF_BOOKS_ID
                ,ctlgd_AMOUNT
                ,ctlgd_ACCTD_AMOUNT
                ,ctlgd_GL_DATE
                ,ctlgd_GL_POSTED_DATE
                ,ctlgd_ACCOUNT_CLASS
                ,ctlgd_posting_control_id
                ,pd_CUST_TRX_LINE_GL_DIST_ID
                ,pd_MF_RECEIVABLES_CCID
                ,pd_POSTING_CONTROL_ID
                ,cnt_by_hdr
                ,pdf_cust_trx_line_gl_dist_id
                ,ln_accounting_date
                ,ln_ledger_id
    LIMIT 1000;

   IF c%NOTFOUND THEN
     l_last_fetch  := TRUE;
   END IF;
   IF (ctlgd_ACCOUNT_CLASS.COUNT = 0) AND (l_last_fetch) THEN
     EXIT;
   END IF;

 LAE_HEADER_ID                  := empty_number_list;
 LAE_LINE_NUM                   := empty_number_list;
 LAPPLICATION_ID                := empty_number_list;
 LCODE_COMBINATION_ID           := empty_number_list;
 LGL_TRANSFER_MODE_CODE         := empty_varchar2_list;
 LGL_SL_LINK_ID                 := empty_varchar2_list;
 LACCOUNTING_CLASS_CODE         := empty_varchar2_list;
 LPARTY_ID                      := empty_number_list;
 LPARTY_SITE_ID                 := empty_number_list;
 LPARTY_TYPE_CODE               := empty_varchar2_list;
 LENTERED_DR                    := empty_number_list;
 LENTERED_CR                    := empty_number_list;
 LACCOUNTED_DR                  := empty_number_list;
 LACCOUNTED_CR                  := empty_number_list;
 LDESCRIPTION                   := empty_varchar2_list;
 LSTATISTICAL_AMOUNT            := empty_number_list;
 LCURRENCY_CODE                 := empty_varchar2_list;
 LCURRENCY_CONVERSION_DATE      := empty_date_list;
 LCURRENCY_CONVERSION_RATE      := empty_number_list;
 LCURRENCY_CONVERSION_TYPE      := empty_varchar2_list;
 LUSSGL_TRANSACTION_CODE        := empty_varchar2_list;
 LJGZZ_RECON_REF                := empty_varchar2_list;
 LCONTROL_BALANCE_FLAG          := empty_varchar2_list;
 LANALYTICAL_BALANCE_FLAG       := empty_varchar2_list;
 LGL_SL_LINK_TABLE              := empty_varchar2_list;
 LDISPLAYED_LINE_NUMBER         := empty_number_list;
 LUPG_BATCH_ID                  := empty_number_list;
 LUNROUNDED_ACCOUNTED_DR        := empty_number_list;
 LUNROUNDED_ACCOUNTED_CR        := empty_number_list;
 LGAIN_OR_LOSS_FLAG             := empty_varchar2_list;
 LUNROUNDED_ENTERED_DR          := empty_number_list;
 LUNROUNDED_ENTERED_CR          := empty_number_list;
 LBUSINESS_CLASS_CODE           := empty_varchar2_list;
 laccounting_date               := empty_date_list;
 lledger_id                     := empty_number_list;


--xla_distribution_links

 DAPPLICATION_ID                := empty_number_list;
 DEVENT_ID                      := empty_number_list;
 DAE_HEADER_ID                  := empty_number_list;
 DAE_LINE_NUM                   := empty_number_list;
 DSOURCE_DISTRIBUTION_TYPE      := empty_varchar2_list;
 DSOURCE_DISTRIBUTION_ID_NUM_1  := empty_number_list;
 DTAX_LINE_REF_ID               := empty_number_list;
 DREF_AE_HEADER_ID              := empty_number_list;
 DREF_TEMP_LINE_NUM             := empty_number_list;
 DACCOUNTING_LINE_CODE          := empty_varchar2_list;
 DACCOUNTING_LINE_TYPE_CODE     := empty_varchar2_list;
 DMERGE_DUPLICATE_CODE          := empty_varchar2_list;
 DTEMP_LINE_NUM                 := empty_number_list;
 DREF_EVENT_ID                  := empty_number_list;
 DEVENT_CLASS_CODE              := empty_varchar2_list;
 DEVENT_TYPE_CODE               := empty_varchar2_list;
 DUPG_BATCH_ID                  := empty_number_list;
 DUNROUNDED_ENTERED_DR          := empty_number_list;
 DUNROUNDED_ENTERED_CR          := empty_number_list;
 DUNROUNDED_ACCOUNTED_CR        := empty_number_list;
 DUNROUNDED_ACCOUNTED_DR        := empty_number_list;


-- FOR PSA upgrade, only ae lines are necessary
-- No distribution links
-- no denormalization event
   FOR i IN ln_AE_HEADER_ID.FIRST .. ln_AE_HEADER_ID.LAST LOOP

    IF ctlgd_ACCOUNT_CLASS(i) = 'REC'  THEN

      -- Construct the reversal
      -- ae line

       LAE_HEADER_ID(i)              := ln_AE_HEADER_ID(i);
       LAE_LINE_NUM(i)               := cnt_by_hdr(i) + ln_AE_LINE_NUM(i);
       LAPPLICATION_ID(i)            := 222;
       LCODE_COMBINATION_ID(i)       := NVL(ln_CODE_COMBINATION_ID(i),-1);
       LGL_TRANSFER_MODE_CODE(i)     := ln_GL_TRANSFER_MODE_CODE(i);
       LGL_SL_LINK_ID(i)             := ln_GL_SL_LINK_ID(i);
       LACCOUNTING_CLASS_CODE(i)     := ln_ACCOUNTING_CLASS_CODE(i);
       LPARTY_ID(i)                  := ln_PARTY_ID(i);
       LPARTY_SITE_ID(i)             := ln_PARTY_SITE_ID(i);
       LPARTY_TYPE_CODE(i)           := ln_PARTY_TYPE_CODE(i);
       LENTERED_DR(i)                := ln_ENTERED_CR(i);
       LENTERED_CR(i)                := ln_ENTERED_DR(i);
       LACCOUNTED_DR(i)              := ln_ACCOUNTED_CR(i);
       LACCOUNTED_CR(i)              := ln_ACCOUNTED_DR(i);
       LDESCRIPTION(i)               := 'MFAR UPGRADE REVERSE AR RECEIVABLES';
       LSTATISTICAL_AMOUNT(i)        := ln_STATISTICAL_AMOUNT(i);
       LCURRENCY_CODE(i)             := ln_CURRENCY_CODE(i);
       LCURRENCY_CONVERSION_DATE(i)  := ln_CURRENCY_CONVERSION_DATE(i);
       LCURRENCY_CONVERSION_RATE(i)  := ln_CURRENCY_CONVERSION_RATE(i);
       LCURRENCY_CONVERSION_TYPE(i)  := ln_CURRENCY_CONVERSION_TYPE(i);
       LUSSGL_TRANSACTION_CODE(i)    := ln_USSGL_TRANSACTION_CODE(i);
       LJGZZ_RECON_REF(i)            := ln_JGZZ_RECON_REF(i);
       LCONTROL_BALANCE_FLAG(i)      := ln_CONTROL_BALANCE_FLAG(i);
       LANALYTICAL_BALANCE_FLAG(i)   := ln_ANALYTICAL_BALANCE_FLAG(i);
       LGL_SL_LINK_TABLE(i)          := ln_GL_SL_LINK_TABLE(i);
       LDISPLAYED_LINE_NUMBER(i)     := ln_DISPLAYED_LINE_NUMBER(i);
       LUPG_BATCH_ID(i)              := ln_UPG_BATCH_ID(i);
       LUNROUNDED_ACCOUNTED_DR(i)    := ln_UNROUNDED_ACCOUNTED_CR(i);
       LUNROUNDED_ACCOUNTED_CR(i)    := ln_UNROUNDED_ACCOUNTED_DR(i);
       LGAIN_OR_LOSS_FLAG(i)         := ln_GAIN_OR_LOSS_FLAG(i);
       LUNROUNDED_ENTERED_DR(i)      := ln_UNROUNDED_ENTERED_CR(i);
       LUNROUNDED_ENTERED_CR(i)      := ln_UNROUNDED_ENTERED_DR(i);
       LBUSINESS_CLASS_CODE(i)       := ln_BUSINESS_CLASS_CODE(i);
       laccounting_date(i)           := ln_accounting_date(i);
       lledger_id(i)                 := ln_ledger_id(i);



    ELSIF pdf_cust_trx_line_gl_dist_id(i) IS NOT NULL THEN

      -- Construct the MFAR REC
      -- ae line

       LAE_HEADER_ID(i)              := ln_AE_HEADER_ID(i);
       LAE_LINE_NUM(i)               := cnt_by_hdr(i) + ln_AE_LINE_NUM(i) + 1; /*bug 5837507*/
       LAPPLICATION_ID(i)            := 222;
       LCODE_COMBINATION_ID(i)       := NVL(pd_MF_RECEIVABLES_CCID(i),-1);
       LGL_TRANSFER_MODE_CODE(i)     := ln_GL_TRANSFER_MODE_CODE(i);
       LGL_SL_LINK_ID(i)             := ln_GL_SL_LINK_ID(i);
       LACCOUNTING_CLASS_CODE(i)     := 'RECEIVABLE';
       LPARTY_ID(i)                  := ln_PARTY_ID(i);
       LPARTY_SITE_ID(i)             := ln_PARTY_SITE_ID(i);
       LPARTY_TYPE_CODE(i)           := ln_PARTY_TYPE_CODE(i);
       IF ctlgd_AMOUNT(i) >= 0 THEN
           LENTERED_DR(i)                := ctlgd_AMOUNT(i);
           LENTERED_CR(i)                := NULL;
       ELSE
           LENTERED_DR(i)                := NULL;
           LENTERED_CR(i)                := ctlgd_AMOUNT(i);
       END IF;
       IF ctlgd_ACCTD_AMOUNT(i) >= 0 THEN
           LACCOUNTED_DR(i)              := ctlgd_ACCTD_AMOUNT(i);
           LACCOUNTED_CR(i)              := NULL;
       ELSE
           LACCOUNTED_DR(i)              := NULL;
           LACCOUNTED_CR(i)              := ctlgd_ACCTD_AMOUNT(i);
       END IF;
       LDESCRIPTION(i)               := 'MFAR UPGRADE CREATE MFAR RECEIVABLES';
       LSTATISTICAL_AMOUNT(i)        := ln_STATISTICAL_AMOUNT(i);
       LCURRENCY_CODE(i)             := ln_CURRENCY_CODE(i);
       LCURRENCY_CONVERSION_DATE(i)  := ln_CURRENCY_CONVERSION_DATE(i);
       LCURRENCY_CONVERSION_RATE(i)  := ln_CURRENCY_CONVERSION_RATE(i);
       LCURRENCY_CONVERSION_TYPE(i)  := ln_CURRENCY_CONVERSION_TYPE(i);
       LUSSGL_TRANSACTION_CODE(i)    := ln_USSGL_TRANSACTION_CODE(i);
       LJGZZ_RECON_REF(i)            := ln_JGZZ_RECON_REF(i);
       LCONTROL_BALANCE_FLAG(i)      := ln_CONTROL_BALANCE_FLAG(i);
       LANALYTICAL_BALANCE_FLAG(i)   := ln_ANALYTICAL_BALANCE_FLAG(i);
       LGL_SL_LINK_TABLE(i)          := ln_GL_SL_LINK_TABLE(i);
       LDISPLAYED_LINE_NUMBER(i)     := ln_DISPLAYED_LINE_NUMBER(i);
       LUPG_BATCH_ID(i)              := ln_UPG_BATCH_ID(i);
       IF ctlgd_ACCTD_AMOUNT(i) >= 0 THEN
           LUNROUNDED_ACCOUNTED_DR(i)    := ctlgd_ACCTD_AMOUNT(i);
           LUNROUNDED_ACCOUNTED_CR(i)    := NULL;
       ELSE
           LUNROUNDED_ACCOUNTED_DR(i)    := NULL;
           LUNROUNDED_ACCOUNTED_CR(i)    := ctlgd_ACCTD_AMOUNT(i);
       END IF;
       LGAIN_OR_LOSS_FLAG(i)         := ln_GAIN_OR_LOSS_FLAG(i);
       IF ctlgd_AMOUNT(i) >= 0 THEN
           LUNROUNDED_ENTERED_DR(i)      := ctlgd_AMOUNT(i);
           LUNROUNDED_ENTERED_CR(i)      := NULL;
       ELSE
           LUNROUNDED_ENTERED_DR(i)      := NULL;
           LUNROUNDED_ENTERED_CR(i)      := ctlgd_AMOUNT(i);
       END IF;
       LBUSINESS_CLASS_CODE(i)       := ln_BUSINESS_CLASS_CODE(i);
       laccounting_date(i)           := ln_accounting_date(i);
       lledger_id(i)                 := ln_ledger_id(i);

    END IF;

  END LOOP;


  FORALL i IN LAE_HEADER_ID.FIRST .. LAE_HEADER_ID.LAST
  INSERT INTO xla_ae_lines
  ( AE_HEADER_ID             ,
    AE_LINE_NUM              ,
    APPLICATION_ID           ,
    CODE_COMBINATION_ID      ,
    GL_TRANSFER_MODE_CODE    ,
    GL_SL_LINK_ID            ,
    ACCOUNTING_CLASS_CODE    ,
    PARTY_ID                 ,
    PARTY_SITE_ID            ,
    PARTY_TYPE_CODE          ,
    ENTERED_DR               ,
    ENTERED_CR               ,
    ACCOUNTED_DR             ,
    ACCOUNTED_CR             ,
    DESCRIPTION              ,
    STATISTICAL_AMOUNT       ,
    CURRENCY_CODE            ,
    CURRENCY_CONVERSION_DATE ,
    CURRENCY_CONVERSION_RATE ,
    CURRENCY_CONVERSION_TYPE ,
    USSGL_TRANSACTION_CODE   ,
    JGZZ_RECON_REF           ,
    CONTROL_BALANCE_FLAG     ,
    ANALYTICAL_BALANCE_FLAG  ,
    GL_SL_LINK_TABLE         ,
    DISPLAYED_LINE_NUMBER    ,
    UPG_BATCH_ID             ,
    UNROUNDED_ACCOUNTED_DR   ,
    UNROUNDED_ACCOUNTED_CR   ,
    GAIN_OR_LOSS_FLAG        ,
    UNROUNDED_ENTERED_DR     ,
    UNROUNDED_ENTERED_CR     ,
    BUSINESS_CLASS_CODE      ,
    CREATION_DATE            ,
    CREATED_BY               ,
    LAST_UPDATE_DATE         ,
    LAST_UPDATED_BY          ,
    accounting_date          ,
    ledger_id  ) VALUES
    (LAE_HEADER_ID(i),
     LAE_LINE_NUM(i),
     LAPPLICATION_ID(i),
     LCODE_COMBINATION_ID(i),
     LGL_TRANSFER_MODE_CODE(i),
     LGL_SL_LINK_ID(i),
     LACCOUNTING_CLASS_CODE(i),
     LPARTY_ID(i),
     LPARTY_SITE_ID(i),
     LPARTY_TYPE_CODE(i),
     LENTERED_DR(i),
     LENTERED_CR(i),
     LACCOUNTED_DR(i),
     LACCOUNTED_CR(i),
     LDESCRIPTION(i),
     LSTATISTICAL_AMOUNT(i),
     LCURRENCY_CODE(i),
     LCURRENCY_CONVERSION_DATE(i),
     LCURRENCY_CONVERSION_RATE(i),
     LCURRENCY_CONVERSION_TYPE(i),
     LUSSGL_TRANSACTION_CODE(i),
     LJGZZ_RECON_REF(i),
     LCONTROL_BALANCE_FLAG(i),
     LANALYTICAL_BALANCE_FLAG(i),
     LGL_SL_LINK_TABLE(i),
     LDISPLAYED_LINE_NUMBER(i),
     LUPG_BATCH_ID(i),
     LUNROUNDED_ACCOUNTED_DR(i),
     LUNROUNDED_ACCOUNTED_CR(i),
     LGAIN_OR_LOSS_FLAG(i),
     LUNROUNDED_ENTERED_DR(i),
     LUNROUNDED_ENTERED_CR(i),
     LBUSINESS_CLASS_CODE(i),
     l_sys_date,
     0,
     l_sys_date,
     0        ,
     laccounting_date(i),
     lledger_id(i));

    IF  l_last_fetch = TRUE THEN
     EXIT;
    END IF;



  END LOOP;
  CLOSE c;

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

commit;

EXCEPTION
 WHEN NO_DATA_FOUND THEN NULL;
 WHEN OTHERS THEN
 RAISE;
END UPGRADE_TRANSACTIONS;



END;

/
