--------------------------------------------------------
--  DDL for Package Body ARP_XLA_EXTRACT_MAIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_XLA_EXTRACT_MAIN_PKG" AS
/* $Header: ARPXLEXB.pls 120.83.12010000.64 2010/08/19 12:38:59 rmanikan ship $ */

TYPE  t_lock IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
l_lock t_lock;

l_multi_fund       VARCHAR2(1) DEFAULT 'N';
l_max_event_test   NUMBER      DEFAULT 10;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

 /*--------------------------------------------------------+
  |  Dummy constants for use in update and lock operations |
  +--------------------------------------------------------*/
  AR_TEXT_DUMMY   CONSTANT VARCHAR2(20) := '~~!@#$*&^';
  AR_FLAG_DUMMY   CONSTANT VARCHAR2(10) := '~';
  AR_NUMBER_DUMMY CONSTANT NUMBER(15)   := -999999999999999;
  AR_DATE_DUMMY   CONSTANT DATE         := to_date(1, 'J');

-- bug 7197528
TYPE glr_ccid_cache_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
g_glr_ccid_cache_tab  glr_ccid_cache_tab;

--bug9076896
TYPE cm_app_extract_record IS RECORD (
EVENT_ID                                            NUMBER(15)
,MFAR_ADDITIONAL_ENTRY                              VARCHAR2(30)
,LEDGER_ID                                          NUMBER(15)
,BASE_CURRENCY_CODE                                 VARCHAR2(15)
,ORG_ID                                             NUMBER(15)
,LINE_ID                                            NUMBER(15)
,SOURCE_ID                                          NUMBER(15)
,SOURCE_TABLE                                       VARCHAR2(10)
,HEADER_TABLE_ID                                    NUMBER(15)
,POSTING_ENTITY                                     VARCHAR2(20)
,XLA_ENTITY_ID                                      NUMBER(15)

,DIST_CCID                                          NUMBER(15)
,REF_DIST_CCID                                      NUMBER

,FROM_CURRENCY_CODE                                 VARCHAR2(30)
,FROM_EXCHANGE_RATE                                 NUMBER
,FROM_EXCHANGE_RATE_TYPE                            VARCHAR2(30)
,FROM_EXCHANGE_DATE                                 DATE
,CM_AMT_APP_TO_INV_LINE                             NUMBER
,CM_ACCTD_AMT_APP_TO_INV_LINE                       NUMBER

,TO_CURRENCY_CODE                                   VARCHAR2(30)
,EXCHANGE_RATE                                      NUMBER
,EXCHANGE_RATE_TYPE                                 VARCHAR2(30)
,EXCHANGE_DATE                                      DATE
,AMOUNT                                             NUMBER
,ACCTD_AMOUNT                                       NUMBER

,RECEIVABLE_APPLICATION_ID                          NUMBER(15)
,CUSTOMER_TRX_ID                                    NUMBER(15)
,CUSTOMER_TRX_LINE_ID                               NUMBER(15)
,CUST_TRX_LINE_GL_DIST_ID                           NUMBER(15)

,INVENTORY_ITEM_ID                                  NUMBER(15)
,SALES_TAX_ID                                       NUMBER(15)
,SET_OF_BOOKS_ID                                    NUMBER(15)
,BILL_SITE_USE_ID                                   NUMBER(15)
,SOLD_SITE_USE_ID                                   NUMBER(15)
,SHIP_SITE_USE_ID                                   NUMBER(15)
,BILL_CUSTOMER_ID                                   NUMBER(15)
,SOLD_CUSTOMER_ID                                   NUMBER(15)
,SHIP_CUSTOMER_ID                                   NUMBER(15)
,TAX_LINE_ID                                        NUMBER(15)

,SELECT_FLAG                                        VARCHAR2(1)
,LEVEL_FLAG                                         VARCHAR2(1)
,FROM_TO_FLAG                                       VARCHAR2(1)

,EVENT_TYPE_CODE                                    VARCHAR2(30)
,EVENT_CLASS_CODE                                   VARCHAR2(30)
,ENTITY_CODE                                        VARCHAR2(30)

,THIRD_PARTY_ID                                     NUMBER(15)
,THIRD_PARTY_SITE_ID                                NUMBER(15)
,THIRD_PARTY_TYPE                                   VARCHAR2(30)
,SOURCE_TYPE                                        VARCHAR2(30)

,CM_APP_LINE_AMT                                   NUMBER
,CM_APP_LINE_ACCTD_AMT                             NUMBER
,AMOUNT_APPLIED                                    NUMBER
,ACCTD_AMOUNT_APPLIED_FROM                         NUMBER
,FROM_DIST_LINE_ID                                  NUMBER(15)
,LINE_NUMBER                                       NUMBER(15)
);
TYPE cm_app_extract_record_type IS TABLE OF cm_app_extract_record
  INDEX BY BINARY_INTEGER;
-- end bug9076896

-- bug 7458133
TYPE crh_mfar_extract_record IS RECORD (
     EVENT_ID                                            NUMBER(15)
     ,MFAR_ADDITIONAL_ENTRY                              VARCHAR2(30)
     ,LEDGER_ID                                          NUMBER(15)
     ,BASE_CURRENCY_CODE                                 VARCHAR2(15)
     ,ORG_ID                                             NUMBER(15)
     ,LINE_ID                                            NUMBER(15)
     ,SOURCE_ID                                          NUMBER(15)
     ,SOURCE_TABLE                                       VARCHAR2(10)
     ,HEADER_TABLE_ID                                    NUMBER(15)
     ,POSTING_ENTITY                                     VARCHAR2(20)
     ,XLA_ENTITY_ID                                      NUMBER(15)
--
     ,DIST_CCID                                          NUMBER(15)
     ,REF_DIST_CCID                                      NUMBER
     ,REF_CTLGD_CCID                                     NUMBER(15)

     ,FROM_CURRENCY_CODE                                 VARCHAR2(30)
     ,FROM_EXCHANGE_RATE                                 NUMBER
     ,FROM_EXCHANGE_RATE_TYPE                            VARCHAR2(30)
     ,FROM_EXCHANGE_DATE                                 DATE
     ,FROM_AMOUNT                                        NUMBER
     ,FROM_ACCTD_AMOUNT                                  NUMBER
--
     ,TO_CURRENCY_CODE                                   VARCHAR2(30)
     ,EXCHANGE_RATE                                      NUMBER
     ,EXCHANGE_RATE_TYPE                                 VARCHAR2(30)
     ,EXCHANGE_DATE                                      DATE
     ,AMOUNT                                             NUMBER
     ,ACCTD_AMOUNT                                       NUMBER
--
     ,RECEIVABLE_APPLICATION_ID                          NUMBER(15)
     ,CASH_RECEIPT_ID                                    NUMBER(15)
     ,CUSTOMER_TRX_ID                                    NUMBER(15)
     ,CUSTOMER_TRX_LINE_ID                               NUMBER(15)
     ,CUST_TRX_LINE_GL_DIST_ID                           NUMBER(15)
--
     ,INVENTORY_ITEM_ID                                  NUMBER(15)
     ,SALES_TAX_ID                                       NUMBER(15)
     ,SET_OF_BOOKS_ID                                    NUMBER(15)
     ,BILL_SITE_USE_ID                                   NUMBER(15)
     ,SOLD_SITE_USE_ID                                   NUMBER(15)
     ,SHIP_SITE_USE_ID                                   NUMBER(15)
     ,BILL_CUSTOMER_ID                                   NUMBER(15)
     ,SOLD_CUSTOMER_ID                                   NUMBER(15)
     ,SHIP_CUSTOMER_ID                                   NUMBER(15)
     ,TAX_LINE_ID                                        NUMBER(15)
--
     ,SELECT_FLAG                                        VARCHAR2(1)
     ,LEVEL_FLAG                                         VARCHAR2(1)
     ,FROM_TO_FLAG                                       VARCHAR2(1)
     ,CRH_STATUS                                         VARCHAR2(30)
     ,APP_CRH_STATUS                                     VARCHAR2(30)
--
     ,EVENT_TYPE_CODE                                    VARCHAR2(30)
     ,EVENT_CLASS_CODE                                   VARCHAR2(30)
     ,ENTITY_CODE                                        VARCHAR2(30)
--
     ,THIRD_PARTY_ID                                     NUMBER(15)
     ,THIRD_PARTY_SITE_ID                                NUMBER(15)
     ,THIRD_PARTY_TYPE                                   VARCHAR2(30)
     ,SOURCE_TYPE                                        VARCHAR2(30)
--
     ,RECP_AMOUNT                                        NUMBER
     ,RECP_ACCTD_AMOUNT                                  NUMBER
     ,CRH_AMOUNT                                         NUMBER
     ,CRH_ACCTD_AMOUNT                                   NUMBER
     ,CRH_RECORD_ID                                      NUMBER(15)
     ,LINE_NUMBER                                        NUMBER(15)
     );
  TYPE crh_mfar_extract_record_type IS TABLE OF crh_mfar_extract_record
  INDEX BY BINARY_INTEGER;

TYPE ar_xla_extract_record IS RECORD (
      EVENT_ID                                           NUMBER(15)
      ,LINE_NUMBER                                        NUMBER(15)
      ,LANGUAGE                                           VARCHAR2(20)
      ,LEDGER_ID                                          NUMBER(15)
      ,SOURCE_ID                                          NUMBER(15)
      ,SOURCE_TABLE                                       VARCHAR2(10)
      ,SOURCE_TYPE                                        VARCHAR2(30)
      ,LINE_ID                                            NUMBER(15)
      ,TAX_CODE_ID                                        NUMBER(15)
      ,LOCATION_SEGMENT_ID                                NUMBER(15)
      ,BASE_CURRENCY_CODE                                 VARCHAR2(15)
      ,EXCHANGE_RATE_TYPE                                 VARCHAR2(30)
      ,EXCHANGE_RATE                                      NUMBER
      ,EXCHANGE_DATE                                      DATE
      ,ACCTD_AMOUNT                                       NUMBER
      ,TAXABLE_ACCTD_AMOUNT                               NUMBER
      ,ORG_ID                                             NUMBER(15)
      ,HEADER_TABLE_ID                                    NUMBER(15)
      ,POSTING_ENTITY                                     VARCHAR2(20)
      ,AMOUNT_APPLIED                                     NUMBER
      ,AMOUNT_APPLIED_FROM                                NUMBER
      ,ACCTD_AMOUNT_APPLIED_FROM                          NUMBER
      ,CASH_RECEIPT_ID                                    NUMBER(15)
      ,CUSTOMER_TRX_ID                                    NUMBER(15)
      ,CUSTOMER_TRX_LINE_ID                               NUMBER(15)
      ,CUST_TRX_LINE_GL_DIST_ID                           NUMBER(15)
      ,CUST_TRX_LINE_SALESREP_ID                          NUMBER(15)
      ,INVENTORY_ITEM_ID                                  NUMBER(15)
      ,SALES_TAX_ID                                       NUMBER(15)
      ,SO_ORGANIZATION_ID                                 NUMBER(15)
      ,TAX_EXEMPTION_ID                                   NUMBER(15)
      ,UOM_CODE                                           VARCHAR2(3)
      ,WAREHOUSE_ID                                       NUMBER(15)
      ,AGREEMENT_ID                                       NUMBER(15)
      ,CUSTOMER_BANK_ACCT_ID                              NUMBER(15)
      ,DRAWEE_BANK_ACCOUNT_ID                             NUMBER(15)
      ,REMITTANCE_BANK_ACCT_ID                            NUMBER(15)
      ,DISTRIBUTION_SET_ID                                NUMBER(15)
      ,PAYMENT_SCHEDULE_ID                                NUMBER(15)
      ,RECEIPT_METHOD_ID                                  NUMBER(15)
      ,RECEIVABLES_TRX_ID                                 NUMBER(15)
      ,ED_ADJ_RECEIVABLES_TRX_ID                          NUMBER(15)
      ,UNED_RECEIVABLES_TRX_ID                            NUMBER(15)
      ,SET_OF_BOOKS_ID                                    NUMBER(15)
      ,SALESREP_ID                                        NUMBER(15)
      ,BILL_SITE_USE_ID                                   NUMBER(15)
      ,DRAWEE_SITE_USE_ID                                 NUMBER(15)
      ,PAYING_SITE_USE_ID                                 NUMBER(15)
      ,SOLD_SITE_USE_ID                                   NUMBER(15)
      ,SHIP_SITE_USE_ID                                   NUMBER(15)
      ,RECEIPT_CUSTOMER_SITE_USE_ID                       NUMBER(15)
      ,BILL_CUST_ROLE_ID                                  NUMBER(15)
      ,DRAWEE_CUST_ROLE_ID                                NUMBER(15)
      ,SHIP_CUST_ROLE_ID                                  NUMBER(15)
      ,SOLD_CUST_ROLE_ID                                  NUMBER(15)
      ,BILL_CUSTOMER_ID                                   NUMBER(15)
      ,DRAWEE_CUSTOMER_ID                                 NUMBER(15)
      ,PAYING_CUSTOMER_ID                                 NUMBER(15)
      ,SOLD_CUSTOMER_ID                                   NUMBER(15)
      ,SHIP_CUSTOMER_ID                                   NUMBER(15)
      ,REMIT_ADDRESS_ID                                   NUMBER(15)
      ,RECEIPT_BATCH_ID                                   NUMBER(15)
      ,RECEIVABLE_APPLICATION_ID                          NUMBER(15)
      ,CUSTOMER_BANK_BRANCH_ID                            NUMBER(15)
      ,ISSUER_BANK_BRANCH_ID                              NUMBER(15)
      ,BATCH_SOURCE_ID                                    NUMBER(15)
      ,BATCH_ID                                           NUMBER(15)
      ,TERM_ID                                            NUMBER(15)
      ,SELECT_FLAG                                        VARCHAR2(1)
      ,LEVEL_FLAG                                         VARCHAR2(1)
      ,FROM_TO_FLAG                                       VARCHAR2(1)
      ,FROM_AMOUNT                                        NUMBER
      ,AMOUNT                                             NUMBER
      ,FROM_ACCTD_AMOUNT                                  NUMBER
      ,EVENT_TYPE_CODE                                    VARCHAR2(30)
      ,EVENT_CLASS_CODE                                   VARCHAR2(30)
      ,ENTITY_CODE                                        VARCHAR2(30)
      ,MFAR_ADDITIONAL_ENTRY                              VARCHAR2(30)
      ,REF_MF_DIST_FLAG                                   VARCHAR2(1)
     );
  TYPE ar_xla_extract_record_type IS TABLE OF ar_xla_extract_record
  INDEX BY BINARY_INTEGER;


TYPE ar_cm_from_record IS RECORD (
ENTITY_ID                                          NUMBER(15)
,RECEIVABLE_APPLICATION_ID                          NUMBER(15)
,LINE_ID                                            NUMBER(15)
,SOURCE_TYPE                                        VARCHAR2(30)
,CUSTOMER_TRX_ID                                    NUMBER(15)
,AMOUNT                                             NUMBER
,ACCTD_AMOUNT                                       NUMBER
,AMOUNT_APPLIED_FROM                                NUMBER
,ACCTD_AMOUNT_APPLIED_FROM                          NUMBER
,CODE_COMBINATION_ID                                NUMBER(15)
,EXCHANGE_DATE                                      DATE
,EXCHANGE_RATE                                      NUMBER
,EXCHANGE_RATE_TYPE                                 VARCHAR2(30)
,THIRD_PARTY_ID                                     NUMBER(15)
,THIRD_PARTY_SUB_ID                                 NUMBER(15)
,EVENT_ID                                           NUMBER(15)
,LEDGER_ID                                          NUMBER(15)
,CURRENCY_CODE                                      VARCHAR2(30)
,ORG_ID                                             NUMBER(15)
,BASE_CURRENCY_CODE                                 VARCHAR2(15)
);

TYPE ar_cm_to_record IS RECORD (
ENTITY_ID                                          NUMBER(15)
,RECEIVABLE_APPLICATION_ID                          NUMBER(15)
,LINE_ID                                            NUMBER(15)
,AMOUNT                                             NUMBER
,ACCTD_AMOUNT                                       NUMBER
,FROM_AMOUNT                                        NUMBER
,FROM_ACCTD_AMOUNT                                  NUMBER
,THIRD_PARTY_ID                                     NUMBER(15)
,THIRD_PARTY_SITE_ID                                NUMBER(15)
,THIRD_PARTY_TYPE                                   VARCHAR2(30)
,CURRENCY_CODE                                      VARCHAR2(30)
,EXCHANGE_RATE                                      NUMBER
,EXCHANGE_TYPE                                      VARCHAR2(30)
,EXCHANGE_DATE                                      DATE
,REF_CUSTOMER_TRX_LINE_ID                           NUMBER(15)
,REF_CUST_TRX_LINE_GL_DIST_ID                       NUMBER(15)
,CODE_COMBINATION_ID                                NUMBER(15)
,REF_DIST_CCID                                      NUMBER(15)
,ACTIVITY_BUCKET                                    VARCHAR2(30)
,SOURCE_TYPE                                        VARCHAR2(30)
,SOURCE_TABLE                                       VARCHAR2(30)
,RA_POST_INDICATOR                                  VARCHAR2(30)
,CUSTOMER_TRX_ID                                    NUMBER(15)
,INVENTORY_ITEM_ID                                  NUMBER(15)
,SALES_TAX_ID                                       NUMBER(15)
,TAX_LINE_ID                                        NUMBER(15)
,BILL_TO_CUSTOMER_ID                                NUMBER(15)
,BILL_TO_SITE_USE_ID                                NUMBER(15)
,SOLD_TO_CUSTOMER_ID                                NUMBER(15)
,SOLD_TO_SITE_USE_ID                                NUMBER(15)
,SHIP_TO_CUSTOMER_ID                                NUMBER(15)
,SHIP_TO_SITE_USE_ID                                NUMBER(15)
);

-- Added for bug 9860123 used for cm amount pro-ration
   TYPE ar_cm_from_tab IS TABLE OF ar_cm_from_record
      INDEX BY BINARY_INTEGER;
   TYPE ar_cm_to_tab IS TABLE OF ar_cm_to_record
      INDEX BY BINARY_INTEGER;


---------------------------
-- Local routine for MFAR
---------------------------
PROCEDURE mfar_hook(p_ledger_id IN NUMBER);
PROCEDURE mfar_app_dist_cr;
PROCEDURE mfar_crh_dist;
PROCEDURE mfar_produit_app_by_crh;
PROCEDURE mfar_get_ra;
PROCEDURE mfar_produit_mcd_by_crh;
PROCEDURE mfar_mcd_dist_cr;
PROCEDURE mfar_cmapp_from_to;
PROCEDURE mfar_cmapp_curr_round;
PROCEDURE mfar_rctapp_curr_round;


-- bug 7458133
PROCEDURE mfar_insert_crh_extract(p_crh_mfar_extract_record IN crh_mfar_extract_record_type);
PROCEDURE prorate_extract_acctd_amounts(p_extract_record IN ar_xla_extract_record_type);
PROCEDURE mfar_cm_app_insert_extract(p_ar_cm_from_rec IN ar_cm_from_tab, p_ar_cm_to_rec IN OUT NOCOPY ar_cm_to_tab);

--------------------------------------------------
-- Body of Procedures and functions             --
--------------------------------------------------

PROCEDURE diag_data;

-- Local logging to avoid arp_standard.debug

PROCEDURE log(
   message       IN VARCHAR2,
   newline       IN BOOLEAN DEFAULT TRUE) IS
BEGIN
  IF NVL(fnd_global.CONC_REQUEST_ID,0) <> 0 THEN
    IF message = 'NEWLINE' THEN
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
    ELSIF (newline) THEN
      FND_FILE.put_line(fnd_file.log,message);
    ELSE
      FND_FILE.put(fnd_file.log,message);
    END IF;
  END IF;
END log;

PROCEDURE local_log
(procedure_name    IN VARCHAR2,
 p_msg_text        IN VARCHAR2,
 p_msg_level       IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT)
IS
  l_module     VARCHAR2(255);
BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
     l_module := 'ar.xla.plsql.'||procedure_name;
     FND_LOG.STRING(fnd_log.level_procedure,
                    l_module,
                    p_msg_text);
  END IF;
  log(p_msg_text);
END;


PROCEDURE set_from_amt IS
CURSOR c IS
SELECT  CASE WHEN (NVL(a.amount_cr,0) - NVL(a.amount_dr,0)) < 0 THEN
            ABS(b.from_amount)        ELSE NULL END
       ,CASE WHEN (NVL(a.amount_cr,0) - NVL(a.amount_dr,0)) > 0 THEN
            ABS(b.from_amount)        ELSE NULL END
       ,CASE WHEN (NVL(a.acctd_amount_cr,0) - NVL(a.acctd_amount_dr,0)) < 0 THEN
            ABS(b.from_acctd_amount)  ELSE NULL END
       ,CASE WHEN (NVL(a.acctd_amount_cr,0) - NVL(a.acctd_amount_dr,0)) > 0 THEN
             ABS(b.from_acctd_amount) ELSE NULL END
       ,b.activity_bucket
       ,b.line_id
  FROM ar_line_app_detail_gt b,
       ar_distributions_all  a
 WHERE b.line_id = a.line_id;

  l_from_amount_dr          DBMS_SQL.NUMBER_TABLE;
  l_from_amount_cr          DBMS_SQL.NUMBER_TABLE;
  l_from_acctd_amount_dr    DBMS_SQL.NUMBER_TABLE;
  l_from_acctd_amount_cr    DBMS_SQL.NUMBER_TABLE;
  l_activity_bucket         DBMS_SQL.VARCHAR2_TABLE;
  l_line_id                 DBMS_SQL.NUMBER_TABLE;
  l_last_fetch              BOOLEAN := FALSE;
  l_found                   VARCHAR2(1);

BEGIN

  local_log( 'set_from_amt','set_from_amt +');
  OPEN c;
  LOOP
    FETCH c BULK COLLECT INTO l_from_amount_dr,
                              l_from_amount_cr,
                              l_from_acctd_amount_dr,
                              l_from_acctd_amount_cr,
                              l_activity_bucket,
                              l_line_id
                    LIMIT 10000;

      IF c%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF (l_line_id.COUNT = 0) AND (l_last_fetch) THEN
        local_log('set_from_amt',' COUNT = 0 and LAST FETCH ');
        EXIT;
      END IF;

      FORALL i IN l_line_id.FIRST .. l_line_id.LAST
      UPDATE ar_distributions_all a
         SET a.from_amount_dr         = l_from_amount_dr(i),
             a.from_amount_cr         = l_from_amount_cr(i),
             a.from_acctd_amount_dr   = l_from_acctd_amount_dr(i),
             a.from_acctd_amount_cr   = l_from_acctd_amount_cr(i),
             a.activity_bucket        = l_activity_bucket(i)
       WHERE a.line_id                = l_line_id(i);

   END LOOP;
   CLOSE c;
   local_log('set_from_amt','set_from_amt  -');

EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
    IF c%ISOPEN THEN CLOSE c; END IF;
    local_log('set_from_amt','EXCEPTION OTHERS in set_from_amt  :'||SQLERRM);
END set_from_amt;


PROCEDURE upgrade_11i_r12_post IS

  CURSOR cu_gt_info IS
  SELECT taxable_amount,        --amount_applied_from
         taxable_acctd_amount,  --acctd_amount_applied_from
         base_currency,         --sob_currency
         det_id,                --cash_receipt_id
         group_id,              --customer_trx_id CM
         gt_id,                 --receivable_application_id used also as gt_id
         to_currency            --invoice currency
    FROM ar_line_app_detail_gt
   GROUP BY
           (taxable_amount,        --amount_applied_from
            taxable_acctd_amount,  --acctd_amount_applied_from
            base_currency,         --sob_currency
            det_id,                --cash_receipt_id
            group_id,              --customer_trx_id CM
            gt_id,                 --receivable_application_id used also as gt_id
            to_currency);          --invoice currency


  l_amount_applied_from         NUMBER;
  l_acctd_amount_applied_from   NUMBER;
  l_base_currency               VARCHAR2(30);
  l_cash_receipt_id             NUMBER;
  l_customer_trx_id             NUMBER;
  l_receivable_application_id   NUMBER;
  l_to_currency                 VARCHAR2(30);
  l_ae_sys_rec                  arp_acct_main.ae_sys_rec_type;
  l_app_rec                     ar_receivable_applications%ROWTYPE;

BEGIN
  local_log(procedure_name => 'upgrade_11i_r12_post',
             p_msg_text     => 'Calling upgrade_11i_r12_post +');
   --Get 11i Applications to upgrade

  local_log(procedure_name => 'upgrade_11i_r12_post',
             p_msg_text     => '  Get 11i application to upgrade');
     INSERT INTO ar_line_app_detail_gt
      (gt_id,                --receivable_application_id
       source_data_key1,     --application_type CASH CM
       det_id,               --cash_receipt_id CASH
       group_id,             --customer_trx_id CM
       ref_customer_trx_id,  --applied_customer_trx_id INV
       line_id,              --line_id
       amount,
       acctd_amount,
       TO_CURRENCY,          --CURRENCY_CODE
       TAXABLE_AMOUNT,       --from_total_applied
       TAXABLE_ACCTD_AMOUNT, --from_total_accted_applied
       base_currency,        --sob_currency
       activity_bucket,
       from_amount,
       from_acctd_amount)
        SELECT app.RECEIVABLE_APPLICATION_ID,
               app.APPLICATION_TYPE         ,
               app.CASH_RECEIPT_ID          ,
               app.CUSTOMER_TRX_ID          ,
               app.APPLIED_CUSTOMER_TRX_ID  ,
               dist.LINE_ID                 ,
               NVL(dist.AMOUNT_CR,0)-NVL(dist.AMOUNT_DR,0),
               NVL(dist.ACCTD_AMOUNT_CR,0)-NVL(dist.ACCTD_AMOUNT_DR,0),
               dist.CURRENCY_CODE           ,
               NVL(app.AMOUNT_APPLIED_FROM  ,app.AMOUNT_APPLIED),
               app.ACCTD_AMOUNT_APPLIED_FROM,
               sob.currency_code            ,
               DECODE(dist.source_type,'EDISC'  ,'ED_LINE'  ,
                                       'UNEDISC','UNED_LINE',
                                       'REC'    ,'APP_LINE' , NULL),
               NVL(dist.AMOUNT_CR,0)-NVL(dist.AMOUNT_DR,0),
               NVL(dist.ACCTD_AMOUNT_CR,0)-NVL(dist.ACCTD_AMOUNT_DR,0)
          FROM xla_events_gt                  eve,
               ar_receivable_applications_all app,
               ar_distributions_all           dist,
               gl_ledgers                     sob
         WHERE eve.application_id         = 222
           AND eve.entity_code           IN ('RECEIPTS','TRANSACTIONS')
           AND eve.event_id               = app.event_id
           AND app.status                IN ('APP','ACTIVITY')
           AND app.posting_control_id     = -3
           AND NVL(app.postable,'Y')      ='Y'
           AND NVL(app.confirmed_flag,'Y')='Y'
           AND app.upgrade_method        IS NULL
           AND app.receivable_application_id = dist.source_id
           AND dist.source_table          = 'RA'
-- This is not required the app status should suffice
--           AND dist.source_type         IN ('REC','EDISC','UNEDISC','DEFERRED_TAX','TAX','ACTIVITY','SHORT_TERM_DEBT')
           AND app.set_of_books_id        = sob.ledger_id;



    IF SQL%ROWCOUNT > 0 THEN
  local_log(procedure_name => 'upgrade_11i_r12_post',
             p_msg_text     => '  Number application found :'||SQL%ROWCOUNT);

     --Calculate from amounts

     OPEN cu_gt_info;
     LOOP
       FETCH cu_gt_info INTO
         l_amount_applied_from      ,
         l_acctd_amount_applied_from,
         l_base_currency            ,
         l_cash_receipt_id          ,
         l_customer_trx_id          ,
         l_receivable_application_id,
         l_to_currency;
       EXIT WHEN cu_gt_info%NOTFOUND;

       l_ae_sys_rec.base_currency := l_base_currency;
       l_app_rec.receivable_application_id := l_receivable_application_id;
       l_app_rec.cash_receipt_id  := l_cash_receipt_id;
       l_app_rec.customer_trx_id  := l_customer_trx_id;

  local_log(procedure_name => 'upgrade_11i_r12_post',
             p_msg_text     => '  upgrading application_id :'|| l_receivable_application_id);

       arp_det_dist_pkg.update_from_gt
        (p_from_amt       => l_amount_applied_from,
         p_from_acctd_amt => l_acctd_amount_applied_from,
         p_ae_sys_rec     => l_ae_sys_rec,
         p_app_rec        => l_app_rec,
         p_gt_id          => l_receivable_application_id,
         p_inv_currency   => l_to_currency);

      END LOOP;
      CLOSE cu_gt_info;


   --Update from amounts in distributions
  local_log(procedure_name => 'upgrade_11i_r12_post',
             p_msg_text     => '  Updating distribution from amount');

  --BUG#5550040
  set_from_amt;

   --Update receivable applications
  local_log(procedure_name => 'upgrade_11i_r12_post',
             p_msg_text     => '  Set application upgrade_method 11I_R12_POST');

       UPDATE ar_receivable_applications_all
          SET upgrade_method = '11I_R12_POST'
        WHERE receivable_application_id IN
             (SELECT gt_id
                FROM ar_line_app_detail_gt
               GROUP BY gt_id);
    END IF;

  local_log(procedure_name => 'upgrade_11i_r12_post',
             p_msg_text     => 'End upgrade_11i_r12_post -');

EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
  local_log(procedure_name => 'upgrade_11i_r12_post',
            p_msg_text     => 'EXCEPTION OTHERS upgrade_11i_r12_post :'||SQLERRM);
  RAISE;
END;

/*-----------------------------------------------------------------+
 | Procedure Name : load_line_data_app_from_cr                     |
 | Description    : Extract the from application line attached to  |
 |                  a cash receipt event                           |
 +-----------------------------------------------------------------+
 | History        :                                                |
 | 23-FEB-2004     Herve Yu    Created due to bug#3419926          |
 +-----------------------------------------------------------------*/
PROCEDURE load_line_data_app_from_cr(p_application_id IN NUMBER DEFAULT 222)
IS

CURSOR inv_conv_rate_zero IS
 SELECT /*+LEADING(gt) USE_NL(gt,app)*/
           gt.event_id,                        -- EVENT_ID
           dist.line_id,                       -- LINE_NUMBER
           '',                                 -- LANGUAGE
           sob.set_of_books_id,                -- LEDGER_ID
           dist.source_id,                     -- SOURCE_ID
           dist.source_table,                  -- SOURCE_TABLE
           dist.source_type,
           dist.line_id,                       -- LINE_ID
           dist.tax_code_id,                   -- TAX_CODE_ID
           dist.location_segment_id,           -- LOCATION_SEGMENT_ID
           sob.currency_code,                  -- BASE_CURRENCY
           NVL(crh.exchange_rate_type,cr.exchange_rate_type),         -- EXCHANGE_RATE_TYPE
           NVL(crh.EXCHANGE_RATE,cr.exchange_rate)     ,              -- EXCHANGE_RATE
           NVL(crh.EXCHANGE_DATE,cr.exchange_date)     ,              -- EXCHANGE_DATE
--
           NVL(dist.acctd_amount_cr,0)
             - NVL(dist.acctd_amount_dr,0),      -- ACCTD_AMOUNT
           NVL(dist.taxable_accounted_cr,0)
             - NVL(dist.taxable_accounted_dr,0), -- TAXABLE_ACCTD_AMOUNT
           app.org_id,                         -- ORG_ID
           app.receivable_application_id,      -- HEADER_ID
           'APP',                              -- POSTING_ENTITY
           app.amount_applied,
           app.amount_applied_from,
           app.acctd_amount_applied_from,
           cr.cash_receipt_id,                 -- CASH_RECEIPT_ID
           NULL,                               -- CUSTOMER_TRX_ID
           NULL,                               -- CUSTOMER_TRX_LINE_ID
           NULL,                               -- CUST_TRX_LINE_GL_DIST_ID
           NULL,                               -- CUST_TRX_LINE_SALESREP_ID
           NULL,                               -- INVENTORY_ITEM_ID
           NULL,                               -- SALES_TAX_ID
           osp.master_organization_id,         -- SO_ORGANIZATION_ID
           NULL,                               -- TAX_EXEMPTION_ID
           NULL,                               -- UOM_CODE
           NULL,                               -- WAREHOUSE_ID
           NULL,                               -- AGREEMENT_ID
           cr.customer_bank_account_id,        -- CUSTOMER_BANK_ACCT_ID
           NULL,                               -- DRAWEE_BANK_ACCOUNT_ID
           cr.remit_bank_acct_use_id,          -- REMITTANCE_BANK_ACCT_ID
           cr.distribution_set_id,             -- DISTRIBUTION_SET_ID
           NULL,                               -- PAYMENT_SCHEDULE_ID
           cr.receipt_method_id,               -- RECEIPT_METHOD_ID
           cr.receivables_trx_id,              -- RECEIVABLES_TRX_ID
--           arp_xla_extract_main_pkg.ed_uned_trx('EDISC',app.org_id),       -- ED_ADJ_RECEIVABLES_TRX_ID
--           arp_xla_extract_main_pkg.ed_uned_trx('UNEDISC',app.org_id),     -- UNED_RECEIVABLES_TRX_ID
-- ED and UNED activity id should only be available on the to doc in application
           NULL,       -- ED_ADJ_RECEIVABLES_TRX_ID
           NULL,     -- UNED_RECEIVABLES_TRX_ID
           cr.set_of_books_id,                 -- SET_OF_BOOKS_ID
           NULL,                               -- SALESREP_ID
           cr.customer_site_use_id,            -- BILL_SITE_USE_ID
           NULL,                               -- DRAWEE_SITE_USE_ID
           cr.customer_site_use_id,            -- PAYING_SITE_USE_ID  -- synch with PAYING_CUSTOMER_ID
           NULL,                               -- SOLD_SITE_USE_ID
           NULL,                               -- SHIP_SITE_USE_ID
           cr.customer_site_use_id,            -- RECEIPT_CUSTOMER_SITE_USE_ID
           NULL,                               -- BILL_CUST_ROLE_ID
           NULL,                               -- DRAWEE_CUST_ROLE_ID
           NULL,                               -- SHIP_CUST_ROLE_ID
           NULL,                               -- SOLD_CUST_ROLE_ID
           NULL,                               -- BILL_CUSTOMER_ID
           NULL,                               -- DRAWEE_CUSTOMER_ID
           cr.pay_from_customer,               -- PAYING_CUSTOMER_ID
           NULL,                               -- SOLD_CUSTOMER_ID
           NULL,                               -- SHIP_CUSTOMER_ID
           NULL,                               -- REMIT_ADDRESS_ID
           cr.SELECTED_REMITTANCE_BATCH_ID,    -- RECEIPT_BATCH_ID
           app.receivable_application_id,      -- RECEIVABLE_APPLICATION_ID
           cr.customer_bank_branch_id,         -- CUSTOMER_BANK_BRANCH_ID
           cr.issuer_bank_branch_id,           -- ISSUER_BANK_BRANCH_ID
           NULL,                               -- BATCH_SOURCE_ID
           NULL,                               -- BATCH_ID
           NULL,                               -- TERM_ID
           'Y',                                -- SELECT_FLAG
           'L',                                -- LEVEL_FLAG
           'F',                                -- FROM_TO_FLAG
--BUG#5201086
--           NVL(dist.from_amount_cr,0)
--             -NVL(dist.from_amount_dr,0),      -- FROM_AMOUNT,
        CASE WHEN (app.upgrade_method IS NULL  AND app.status ='APP') THEN
           CASE WHEN (dist.from_amount_dr IS NOT NULL OR dist.from_amount_cr IS NOT NULL) THEN
              NVL(dist.from_amount_cr,0)-NVL(dist.from_amount_dr,0)
           ELSE
             CASE WHEN (dist.source_type NOT IN ('REC','EDISC','UNEDISC')) THEN
                NULL
             ELSE
               CASE WHEN (app.earned_discount_taken IS NOT NULL AND
                    app.earned_discount_taken = NVL(dist.amount_dr,0)-NVL(dist.amount_cr,0) AND
                    app.acctd_earned_discount_taken = NVL(dist.acctd_amount_dr,0)-NVL(dist.acctd_amount_cr,0)
                    AND dist.source_type = 'REC') THEN
                   NULL
               ELSE
                 CASE WHEN (trx.invoice_currency_code = cr.currency_code) THEN
                    NVL(dist.amount_cr,0)-NVL(dist.amount_dr,0)
                 ELSE
                   CASE WHEN (app.amount_applied <> 0 AND app.amount_applied_from <> 0) THEN
                     NVL(app.amount_applied_from / app.amount_applied * dist.amount_cr,0)-
                     NVL(app.amount_applied_from / app.amount_applied * dist.amount_dr,0)
                    ELSE  NULL END
                 END
               END
             END
           END
        ELSE
           NVL(dist.from_amount_cr,0)
             -NVL(dist.from_amount_dr,0)
        END,                     -- FROM_AMOUNT
           NVL(dist.amount_cr,0)
             -NVL(dist.amount_dr,0),           -- AMOUNT
--BUG#5201086
--           NVL(dist.from_acctd_amount_cr,0)
--             -NVL(dist.from_acctd_amount_dr,0), -- FROM_ACCTD_AMOUNT
        CASE WHEN (app.upgrade_method IS NULL AND app.status ='APP') THEN
           CASE WHEN (dist.from_acctd_amount_dr IS NOT NULL OR dist.from_acctd_amount_cr IS NOT NULL) THEN
              NVL(dist.from_acctd_amount_cr,0)-NVL(dist.from_acctd_amount_dr,0)
           ELSE
             CASE WHEN (dist.source_type NOT IN ('REC','EDISC','UNEDISC')) THEN
                NULL
             ELSE
               CASE WHEN (app.earned_discount_taken IS NOT NULL AND
                    app.earned_discount_taken = NVL(dist.amount_dr,0)-NVL(dist.amount_cr,0) AND
                    app.acctd_earned_discount_taken = NVL(dist.acctd_amount_dr,0)-NVL(dist.acctd_amount_cr,0)
                    AND dist.source_type = 'REC') THEN
                   NULL
               ELSE
                 CASE WHEN (trx.invoice_currency_code = sob.currency_code AND
                            cr.currency_code          = sob.currency_code ) THEN
                    NVL(dist.acctd_amount_cr,0)-NVL(dist.acctd_amount_dr,0)
                 ELSE
                   CASE WHEN (app.acctd_amount_applied_to <> 0 AND app.acctd_amount_applied_from <> 0) THEN
                   NVL(app.acctd_amount_applied_from / app.acctd_amount_applied_to * dist.acctd_amount_cr,0)-
                   NVL(app.acctd_amount_applied_from / app.acctd_amount_applied_to * dist.acctd_amount_dr,0)
                    ELSE  NULL END
                 END
               END
             END
           END
        ELSE
           NVL(dist.from_acctd_amount_cr,0)
             -NVL(dist.from_acctd_amount_dr,0)
        END,                     -- FROM_ACCTD_AMOUNT
         --{BUG#4356088
          gt.event_type_code
         ,gt.event_class_code
         ,gt.entity_code
         ,'N'                    --MFAR_ADDITIONAL_ENTRY
         ,nvl(dist.ref_mf_dist_flag,'N')  --REF_MF_DIST_FLAG
        FROM xla_events_gt                 gt,
           ar_receivable_applications_all app,
           ar_distributions_all           dist,
           gl_sets_of_books               sob,
           oe_system_parameters_all       osp,
           ar_cash_receipts_all           cr,
           --BUG#5201086
           ar_cash_receipt_history_all    crh,
           ra_customer_trx_all            trx
     WHERE gt.event_type_code IN (  'RECP_CREATE'          ,'RECP_UPDATE'      ,
                                    'RECP_RATE_ADJUST'     ) --,'RECP_REVERSE') uptake XLA transaction reversal
       AND gt.application_id              = p_application_id
	   AND gt.event_id                    = app.event_id
       AND dist.source_table              = 'RA' -- Don't need this join due to ar_app_dist_upg_v
       AND dist.source_id                 = app.receivable_application_id
       AND app.set_of_books_id            = sob.set_of_books_id
       AND DECODE(app.acctd_amount_applied_to,0,DECODE(app.acctd_amount_applied_from,0,'N','Y'),'N') = 'Y'
--
-- BUG#5366837
-- R12_11ICASH_POST is reserved for Upgraded 11i Cash basis not posted applications
-- We are not passing Cash basis at From Line level
-- the data for Cash Basis accounting upgraded will be at the To line level only
--
--       AND NVL(app.upgrade_method,'XX')   NOT IN ('R12_11ICASH_POST')
--
-- Need to incorporate PSA upgrade
--
       AND DECODE(app.upgrade_method,
                    'R12_11ICASH_POST','N',
                    '11I_MFAR_UPG'    ,DECODE(dist.source_table_secondary,'UPMFRAMIAR','Y','N'),
                    'Y')                  = 'Y'
       AND app.org_id                     = osp.org_id(+)
       AND app.cash_receipt_id            = cr.cash_receipt_id
       AND app.cash_receipt_history_id    = crh.cash_receipt_history_id(+)
       AND app.applied_customer_trx_id    = trx.customer_trx_id(+)
       AND dist.source_type               IN ('REC'
           ,'OTHER ACC','ACC','BANK_CHARGES','ACTIVITY','FACTOR','REMITTANCE',
            'TAX','DEFERRED_TAX','UNEDISC','EDISC','CURR_ROUND','SHORT_TERM_DEBT',
            'EXCH_LOSS','EXCH_GAIN','EDISC_NON_REC_TAX','UNEDISC_NON_REC_TAX');

  l_extract_record  ar_xla_extract_record_type;


BEGIN
   local_log(procedure_name => 'load_line_data_app_from_cr',
             p_msg_text     => 'arp_xla_extract_main_pkg.load_line_data_app_from_cr()+');
    -- Insert line level data in Line GT with
    -- selected_flag = Y
    -- level_flag    = L
    -- From_to_flag  = F


-- Special case handling for cases where application amount is non-zero
-- and invoice conversion rate is almost zero resulting into
-- zero accounted amount applications on invoice (Bug 8895061)

   OPEN inv_conv_rate_zero;

   LOOP
   FETCH inv_conv_rate_zero BULK COLLECT INTO l_extract_record LIMIT MAX_ARRAY_SIZE;
   IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug('inv_conv_rate_zero current fetch count   '|| l_extract_record.count);
   END IF;

   IF l_extract_record.count = 0 THEN
	  EXIT;
   END IF;

-- Calculate prorated from accounted amounts and insert data into extract
   prorate_extract_acctd_amounts(l_extract_record);

   END LOOP;

   CLOSE inv_conv_rate_zero;
-- Bug 8895061 Ends


    INSERT INTO ar_xla_lines_extract (
        EVENT_ID
       ,LINE_NUMBER
       ,LANGUAGE
       ,LEDGER_ID
       ,SOURCE_ID
       ,SOURCE_TABLE
       ,LINE_ID
       ,TAX_CODE_ID
       ,LOCATION_SEGMENT_ID
       ,BASE_CURRENCY_CODE
       ,EXCHANGE_RATE_TYPE
       ,EXCHANGE_RATE
       ,EXCHANGE_DATE
       ,ACCTD_AMOUNT
       ,TAXABLE_ACCTD_AMOUNT
       ,ORG_ID
       ,HEADER_TABLE_ID
       ,POSTING_ENTITY
       ,CASH_RECEIPT_ID
       ,CUSTOMER_TRX_ID
       ,CUSTOMER_TRX_LINE_ID
       ,CUST_TRX_LINE_GL_DIST_ID
       ,CUST_TRX_LINE_SALESREP_ID
       ,INVENTORY_ITEM_ID
       ,SALES_TAX_ID
       ,SO_ORGANIZATION_ID
       ,TAX_EXEMPTION_ID
       ,UOM_CODE
       ,WAREHOUSE_ID
       ,AGREEMENT_ID
       ,CUSTOMER_BANK_ACCT_ID
       ,DRAWEE_BANK_ACCOUNT_ID
       ,REMITTANCE_BANK_ACCT_ID
       ,DISTRIBUTION_SET_ID
       ,PAYMENT_SCHEDULE_ID
       ,RECEIPT_METHOD_ID
       ,RECEIVABLES_TRX_ID
       ,ED_ADJ_RECEIVABLES_TRX_ID
       ,UNED_RECEIVABLES_TRX_ID
       ,SET_OF_BOOKS_ID
       ,SALESREP_ID
       ,BILL_SITE_USE_ID
       ,DRAWEE_SITE_USE_ID
       ,PAYING_SITE_USE_ID
       ,SOLD_SITE_USE_ID
       ,SHIP_SITE_USE_ID
       ,RECEIPT_CUSTOMER_SITE_USE_ID
       ,BILL_CUST_ROLE_ID
       ,DRAWEE_CUST_ROLE_ID
       ,SHIP_CUST_ROLE_ID
       ,SOLD_CUST_ROLE_ID
       ,BILL_CUSTOMER_ID
       ,DRAWEE_CUSTOMER_ID
       ,PAYING_CUSTOMER_ID
       ,SOLD_CUSTOMER_ID
       ,SHIP_CUSTOMER_ID
       ,REMIT_ADDRESS_ID
       ,RECEIPT_BATCH_ID
       ,RECEIVABLE_APPLICATION_ID
       ,CUSTOMER_BANK_BRANCH_ID
       ,ISSUER_BANK_BRANCH_ID
       ,BATCH_SOURCE_ID
       ,BATCH_ID
       ,TERM_ID
       ,SELECT_FLAG
       ,LEVEL_FLAG
       ,FROM_TO_FLAG
       ,CRH_STATUS
       ,FROM_AMOUNT
       ,AMOUNT
       ,FROM_ACCTD_AMOUNT
       --{BUG#4356088
       ,event_type_code
       ,event_class_code
       ,entity_code
       --MFAR
       ,MFAR_ADDITIONAL_ENTRY
       )
      -- FROM document type Cash Receipt
       SELECT /*+LEADING(gt) USE_NL(gt,app)*/
           gt.event_id,                        -- EVENT_ID
           dist.line_id,                       -- LINE_NUMBER
           '',                                 -- LANGUAGE
           sob.set_of_books_id,                -- LEDGER_ID
           dist.source_id,                     -- SOURCE_ID
           dist.source_table,                  -- SOURCE_TABLE
           dist.line_id,                       -- LINE_ID
           dist.tax_code_id,                   -- TAX_CODE_ID
           dist.location_segment_id,           -- LOCATION_SEGMENT_ID
           sob.currency_code,                  -- BASE_CURRENCY
           NVL(crh.exchange_rate_type,cr.exchange_rate_type),         -- EXCHANGE_RATE_TYPE
           NVL(crh.EXCHANGE_RATE,cr.exchange_rate)     ,              -- EXCHANGE_RATE
           NVL(crh.EXCHANGE_DATE,cr.exchange_date)     ,              -- EXCHANGE_DATE
--
           NVL(dist.acctd_amount_cr,0)
             - NVL(dist.acctd_amount_dr,0),      -- ACCTD_AMOUNT
           NVL(dist.taxable_accounted_cr,0)
             - NVL(dist.taxable_accounted_dr,0), -- TAXABLE_ACCTD_AMOUNT
           app.org_id,                         -- ORG_ID
           app.receivable_application_id,      -- HEADER_ID
           'APP',                              -- POSTING_ENTITY
           cr.cash_receipt_id,                 -- CASH_RECEIPT_ID
           NULL,                               -- CUSTOMER_TRX_ID
           NULL,                               -- CUSTOMER_TRX_LINE_ID
           NULL,                               -- CUST_TRX_LINE_GL_DIST_ID
           NULL,                               -- CUST_TRX_LINE_SALESREP_ID
           NULL,                               -- INVENTORY_ITEM_ID
           NULL,                               -- SALES_TAX_ID
           osp.master_organization_id,         -- SO_ORGANIZATION_ID
           NULL,                               -- TAX_EXEMPTION_ID
           NULL,                               -- UOM_CODE
           NULL,                               -- WAREHOUSE_ID
           NULL,                               -- AGREEMENT_ID
           cr.customer_bank_account_id,        -- CUSTOMER_BANK_ACCT_ID
           NULL,                               -- DRAWEE_BANK_ACCOUNT_ID
           cr.remit_bank_acct_use_id,          -- REMITTANCE_BANK_ACCT_ID
           cr.distribution_set_id,             -- DISTRIBUTION_SET_ID
           NULL,                               -- PAYMENT_SCHEDULE_ID
           cr.receipt_method_id,               -- RECEIPT_METHOD_ID
           cr.receivables_trx_id,              -- RECEIVABLES_TRX_ID
--           arp_xla_extract_main_pkg.ed_uned_trx('EDISC',app.org_id),       -- ED_ADJ_RECEIVABLES_TRX_ID
--           arp_xla_extract_main_pkg.ed_uned_trx('UNEDISC',app.org_id),     -- UNED_RECEIVABLES_TRX_ID
-- ED and UNED activity id should only be available on the to doc in application
           NULL,       -- ED_ADJ_RECEIVABLES_TRX_ID
           NULL,     -- UNED_RECEIVABLES_TRX_ID
           cr.set_of_books_id,                 -- SET_OF_BOOKS_ID
           NULL,                               -- SALESREP_ID
           cr.customer_site_use_id,            -- BILL_SITE_USE_ID
           NULL,                               -- DRAWEE_SITE_USE_ID
           cr.customer_site_use_id,            -- PAYING_SITE_USE_ID  -- synch with PAYING_CUSTOMER_ID
           NULL,                               -- SOLD_SITE_USE_ID
           NULL,                               -- SHIP_SITE_USE_ID
           cr.customer_site_use_id,            -- RECEIPT_CUSTOMER_SITE_USE_ID
           NULL,                               -- BILL_CUST_ROLE_ID
           NULL,                               -- DRAWEE_CUST_ROLE_ID
           NULL,                               -- SHIP_CUST_ROLE_ID
           NULL,                               -- SOLD_CUST_ROLE_ID
           NULL,                               -- BILL_CUSTOMER_ID
           NULL,                               -- DRAWEE_CUSTOMER_ID
           cr.pay_from_customer,               -- PAYING_CUSTOMER_ID
           NULL,                               -- SOLD_CUSTOMER_ID
           NULL,                               -- SHIP_CUSTOMER_ID
           NULL,                               -- REMIT_ADDRESS_ID
           cr.SELECTED_REMITTANCE_BATCH_ID,    -- RECEIPT_BATCH_ID
           app.receivable_application_id,      -- RECEIVABLE_APPLICATION_ID
           cr.customer_bank_branch_id,         -- CUSTOMER_BANK_BRANCH_ID
           cr.issuer_bank_branch_id,           -- ISSUER_BANK_BRANCH_ID
           NULL,                               -- BATCH_SOURCE_ID
           NULL,                               -- BATCH_ID
           NULL,                               -- TERM_ID
           'Y',                                -- SELECT_FLAG
           'L',                                -- LEVEL_FLAG
           'F',                                -- FROM_TO_FLAG
           decode(app.status, 'APP', NULL,
                              'UNAPP', NULL,
                              'UNID', NULL, app.status), -- CRH_STATUS
--BUG#5201086
--           NVL(dist.from_amount_cr,0)
--             -NVL(dist.from_amount_dr,0),      -- FROM_AMOUNT,
        CASE WHEN (app.upgrade_method IS NULL  AND app.status ='APP') THEN
           CASE WHEN (dist.from_amount_dr IS NOT NULL OR dist.from_amount_cr IS NOT NULL) THEN
              NVL(dist.from_amount_cr,0)-NVL(dist.from_amount_dr,0)
           ELSE
             CASE WHEN (dist.source_type NOT IN ('REC','EDISC','UNEDISC')) THEN
                NULL
             ELSE
               CASE WHEN (app.earned_discount_taken IS NOT NULL AND
                    app.earned_discount_taken = NVL(dist.amount_dr,0)-NVL(dist.amount_cr,0) AND
                    app.acctd_earned_discount_taken = NVL(dist.acctd_amount_dr,0)-NVL(dist.acctd_amount_cr,0)
                    AND dist.source_type = 'REC') THEN
                   NULL
               ELSE
                 CASE WHEN (trx.invoice_currency_code = cr.currency_code) THEN
                    NVL(dist.amount_cr,0)-NVL(dist.amount_dr,0)
                 ELSE
                   CASE WHEN (app.amount_applied <> 0 AND app.amount_applied_from <> 0) THEN
                     NVL(app.amount_applied_from / app.amount_applied * dist.amount_cr,0)-
                     NVL(app.amount_applied_from / app.amount_applied * dist.amount_dr,0)
                    ELSE  NULL END
                 END
               END
             END
           END
        ELSE
           NVL(dist.from_amount_cr,0)
             -NVL(dist.from_amount_dr,0)
        END,                     -- FROM_AMOUNT
           NVL(dist.amount_cr,0)
             -NVL(dist.amount_dr,0),           -- AMOUNT
--BUG#5201086
--           NVL(dist.from_acctd_amount_cr,0)
--             -NVL(dist.from_acctd_amount_dr,0), -- FROM_ACCTD_AMOUNT
        CASE WHEN (app.upgrade_method IS NULL AND app.status ='APP') THEN
           CASE WHEN (dist.from_acctd_amount_dr IS NOT NULL OR dist.from_acctd_amount_cr IS NOT NULL) THEN
              NVL(dist.from_acctd_amount_cr,0)-NVL(dist.from_acctd_amount_dr,0)
           ELSE
             CASE WHEN (dist.source_type NOT IN ('REC','EDISC','UNEDISC')) THEN
                NULL
             ELSE
               CASE WHEN (app.earned_discount_taken IS NOT NULL AND
                    app.earned_discount_taken = NVL(dist.amount_dr,0)-NVL(dist.amount_cr,0) AND
                    app.acctd_earned_discount_taken = NVL(dist.acctd_amount_dr,0)-NVL(dist.acctd_amount_cr,0)
                    AND dist.source_type = 'REC') THEN
                   NULL
               ELSE
                 CASE WHEN (trx.invoice_currency_code = sob.currency_code AND
                            cr.currency_code          = sob.currency_code ) THEN
                    NVL(dist.acctd_amount_cr,0)-NVL(dist.acctd_amount_dr,0)
                 ELSE
                   CASE WHEN (app.acctd_amount_applied_to <> 0 AND app.acctd_amount_applied_from <> 0) THEN
                   NVL(app.acctd_amount_applied_from / app.acctd_amount_applied_to * dist.acctd_amount_cr,0)-
                   NVL(app.acctd_amount_applied_from / app.acctd_amount_applied_to * dist.acctd_amount_dr,0)
                    ELSE  NULL END
                 END
               END
             END
           END
        ELSE
           NVL(dist.from_acctd_amount_cr,0)
             -NVL(dist.from_acctd_amount_dr,0)
        END,                     -- FROM_ACCTD_AMOUNT
         --{BUG#4356088
          gt.event_type_code
         ,gt.event_class_code
         ,gt.entity_code
         ,'N'                    --MFAR_ADDITIONAL_ENTRY
        FROM xla_events_gt                 gt,
           ar_receivable_applications_all app,
           ar_distributions_all           dist,
           gl_sets_of_books               sob,
           oe_system_parameters_all       osp,
           ar_cash_receipts_all           cr,
           --BUG#5201086
           ar_cash_receipt_history_all    crh,
           ra_customer_trx_all            trx
     WHERE gt.event_type_code IN (  'RECP_CREATE'          ,'RECP_UPDATE'      ,
                                    'RECP_RATE_ADJUST'     ) --,'RECP_REVERSE') uptake XLA transaction reversal
       AND gt.application_id              = p_application_id
	   AND gt.event_id                    = app.event_id
       AND dist.source_table              = 'RA' -- Don't need this join due to ar_app_dist_upg_v
       AND dist.source_id                 = app.receivable_application_id
       AND app.set_of_books_id            = sob.set_of_books_id
       AND DECODE(app.acctd_amount_applied_to,0,DECODE(app.acctd_amount_applied_from,0,'N','Y'),'N') = 'N'
--
-- BUG#5366837
-- R12_11ICASH_POST is reserved for Upgraded 11i Cash basis not posted applications
-- We are not passing Cash basis at From Line level
-- the data for Cash Basis accounting upgraded will be at the To line level only
--
--       AND NVL(app.upgrade_method,'XX')   NOT IN ('R12_11ICASH_POST')
--
-- Need to incorporate PSA upgrade
--
       AND DECODE(app.upgrade_method,
                    'R12_11ICASH_POST','N',
                    '11I_MFAR_UPG'    ,DECODE(dist.source_table_secondary,'UPMFRAMIAR','Y','N'),
                    'Y')                  = 'Y'
       AND app.org_id                     = osp.org_id(+)
       AND app.cash_receipt_id            = cr.cash_receipt_id
       AND app.cash_receipt_history_id    = crh.cash_receipt_history_id(+)
       AND app.applied_customer_trx_id    = trx.customer_trx_id(+)
       AND dist.source_type               IN ('REC'
           ,'OTHER ACC','ACC','BANK_CHARGES','ACTIVITY','FACTOR','REMITTANCE',
            'TAX','DEFERRED_TAX','UNEDISC','EDISC','CURR_ROUND','SHORT_TERM_DEBT',
            'EXCH_LOSS','EXCH_GAIN','EDISC_NON_REC_TAX','UNEDISC_NON_REC_TAX');


--BUG#5366837 From document in cash basis
    INSERT INTO ar_xla_lines_extract (
        EVENT_ID
       ,LINE_NUMBER
       ,LANGUAGE
       ,LEDGER_ID
       ,SOURCE_ID
       ,SOURCE_TABLE
       ,LINE_ID
       ,TAX_CODE_ID
       ,LOCATION_SEGMENT_ID
       ,BASE_CURRENCY_CODE
       ,EXCHANGE_RATE_TYPE
       ,EXCHANGE_RATE
       ,EXCHANGE_DATE
       ,ACCTD_AMOUNT
       ,TAXABLE_ACCTD_AMOUNT
       ,ORG_ID
       ,HEADER_TABLE_ID
       ,POSTING_ENTITY
       ,CASH_RECEIPT_ID
       ,CUSTOMER_TRX_ID
       ,CUSTOMER_TRX_LINE_ID
       ,CUST_TRX_LINE_GL_DIST_ID
       ,CUST_TRX_LINE_SALESREP_ID
       ,INVENTORY_ITEM_ID
       ,SALES_TAX_ID
       ,SO_ORGANIZATION_ID
       ,TAX_EXEMPTION_ID
       ,UOM_CODE
       ,WAREHOUSE_ID
       ,AGREEMENT_ID
       ,CUSTOMER_BANK_ACCT_ID
       ,DRAWEE_BANK_ACCOUNT_ID
       ,REMITTANCE_BANK_ACCT_ID
       ,DISTRIBUTION_SET_ID
       ,PAYMENT_SCHEDULE_ID
       ,RECEIPT_METHOD_ID
       ,RECEIVABLES_TRX_ID
       ,ED_ADJ_RECEIVABLES_TRX_ID
       ,UNED_RECEIVABLES_TRX_ID
       ,SET_OF_BOOKS_ID
       ,SALESREP_ID
       ,BILL_SITE_USE_ID
       ,DRAWEE_SITE_USE_ID
       ,PAYING_SITE_USE_ID
       ,SOLD_SITE_USE_ID
       ,SHIP_SITE_USE_ID
       ,RECEIPT_CUSTOMER_SITE_USE_ID
       ,BILL_CUST_ROLE_ID
       ,DRAWEE_CUST_ROLE_ID
       ,SHIP_CUST_ROLE_ID
       ,SOLD_CUST_ROLE_ID
       ,BILL_CUSTOMER_ID
       ,DRAWEE_CUSTOMER_ID
       ,PAYING_CUSTOMER_ID
       ,SOLD_CUSTOMER_ID
       ,SHIP_CUSTOMER_ID
       ,REMIT_ADDRESS_ID
       ,RECEIPT_BATCH_ID
       ,RECEIVABLE_APPLICATION_ID
       ,CUSTOMER_BANK_BRANCH_ID
       ,ISSUER_BANK_BRANCH_ID
       ,BATCH_SOURCE_ID
       ,BATCH_ID
       ,TERM_ID
       ,SELECT_FLAG
       ,LEVEL_FLAG
       ,FROM_TO_FLAG
       ,FROM_AMOUNT
       ,AMOUNT
       ,FROM_ACCTD_AMOUNT
       ,event_type_code
       ,event_class_code
       ,entity_code
       ,additional_char1
       ,MFAR_ADDITIONAL_ENTRY
       )
       SELECT /*+LEADING(gt) USE_NL(gt,app)*/
           gt.event_id                         -- EVENT_ID
          ,dist.cash_basis_distribution_id     -- LINE_NUMBER
          ,''                                  -- LANGUAGE
          ,sob.set_of_books_id                 -- LEDGER_ID
          ,dist.receivable_application_id_cash -- SOURCE_ID
          ,'RA'                                -- SOURCE_TABLE
          ,dist.cash_basis_distribution_id     -- LINE_ID
          ,NULL                                -- TAX_CODE_ID
          ,NULL                                -- LOCATION_SEGMENT_ID
          ,sob.currency_code                   -- BASE_CURRENCY
          ,NVL(crh.exchange_rate_type,cr.exchange_rate_type)  -- EXCHANGE_RATE_TYPE
          ,NVL(crh.EXCHANGE_RATE,cr.exchange_rate)            -- EXCHANGE_RATE
          ,NVL(crh.EXCHANGE_DATE,cr.exchange_date)            -- EXCHANGE_DATE
          ,dist.acctd_amount                   -- ACCTD_AMOUNT
          ,0                                   -- TAXABLE_ACCTD_AMOUNT
          ,app.org_id                          -- ORG_ID
          ,app.receivable_application_id       -- HEADER_ID
          ,'APP'                               -- POSTING_ENTITY
          ,cr.cash_receipt_id                  -- CASH_RECEIPT_ID
          ,NULL                                -- CUSTOMER_TRX_ID
          ,NULL                                -- CUSTOMER_TRX_LINE_ID
          ,NULL                                -- CUST_TRX_LINE_GL_DIST_ID
          ,NULL                                -- CUST_TRX_LINE_SALESREP_ID
          ,NULL                                -- INVENTORY_ITEM_ID
          ,NULL                                -- SALES_TAX_ID
          ,osp.master_organization_id          -- SO_ORGANIZATION_ID
          ,NULL                                -- TAX_EXEMPTION_ID
          ,NULL                                -- UOM_CODE
          ,NULL                                -- WAREHOUSE_ID
          ,NULL                                -- AGREEMENT_ID
          ,cr.customer_bank_account_id         -- CUSTOMER_BANK_ACCT_ID
          ,NULL                                -- DRAWEE_BANK_ACCOUNT_ID
          ,cr.remit_bank_acct_use_id           -- REMITTANCE_BANK_ACCT_ID
          ,cr.distribution_set_id              -- DISTRIBUTION_SET_ID
          ,NULL                                -- PAYMENT_SCHEDULE_ID
          ,cr.receipt_method_id                -- RECEIPT_METHOD_ID
          ,cr.receivables_trx_id               -- RECEIVABLES_TRX_ID
          ,NULL                                -- ED_ADJ_RECEIVABLES_TRX_ID
          ,NULL                                -- UNED_RECEIVABLES_TRX_ID
          ,cr.set_of_books_id                  -- SET_OF_BOOKS_ID
          ,NULL                                -- SALESREP_ID
          ,cr.customer_site_use_id             -- BILL_SITE_USE_ID
          ,NULL                                -- DRAWEE_SITE_USE_ID
          ,cr.customer_site_use_id             -- PAYING_SITE_USE_ID  -- synch with PAYING_CUSTOMER_ID
          ,NULL                                -- SOLD_SITE_USE_ID
          ,NULL                                -- SHIP_SITE_USE_ID
          ,cr.customer_site_use_id             -- RECEIPT_CUSTOMER_SITE_USE_ID
          ,NULL                                -- BILL_CUST_ROLE_ID
          ,NULL                                -- DRAWEE_CUST_ROLE_ID
          ,NULL                                -- SHIP_CUST_ROLE_ID
          ,NULL                                -- SOLD_CUST_ROLE_ID
          ,NULL                                -- BILL_CUSTOMER_ID
          ,NULL                                -- DRAWEE_CUSTOMER_ID
          ,cr.pay_from_customer                -- PAYING_CUSTOMER_ID
          ,NULL                                -- SOLD_CUSTOMER_ID
          ,NULL                                -- SHIP_CUSTOMER_ID
          ,NULL                                -- REMIT_ADDRESS_ID
          ,cr.SELECTED_REMITTANCE_BATCH_ID     -- RECEIPT_BATCH_ID
          ,app.receivable_application_id       -- RECEIVABLE_APPLICATION_ID
          ,cr.customer_bank_branch_id          -- CUSTOMER_BANK_BRANCH_ID
          ,cr.issuer_bank_branch_id            -- ISSUER_BANK_BRANCH_ID
          ,NULL                                -- BATCH_SOURCE_ID
          ,NULL                                -- BATCH_ID
          ,NULL                                -- TERM_ID
          ,'Y'                                 -- SELECT_FLAG
          ,'L'                                 -- LEVEL_FLAG
          ,'F'                                 -- FROM_TO_FLAG
          ,dist.from_amount                    -- FROM_AMOUNT
          ,dist.amount                         -- AMOUNT
          ,dist.from_acctd_amount              -- FROM_ACCTD_AMOUNT
          ,gt.event_type_code
          ,gt.event_class_code
          ,gt.entity_code
          ,app.upgrade_method
         ,'N'                    --MFAR_ADDITIONAL_ENTRY
        FROM xla_events_gt                 gt,
           ar_receivable_applications_all app,
           ar_cash_basis_dists_all        dist,
           gl_sets_of_books               sob,
           oe_system_parameters_all       osp,
           ar_cash_receipts_all           cr,
           ar_cash_receipt_history_all    crh,
           ra_customer_trx_all            trx
     WHERE gt.event_type_code IN (  'RECP_CREATE'          ,'RECP_UPDATE'      ,
                                    'RECP_RATE_ADJUST')  -- Uptake XLA trx reversal     ,'RECP_REVERSE')
       AND gt.application_id              = 222
       AND gt.event_id                    = app.event_id
       AND dist.receivable_application_id = app.receivable_application_id
       AND app.set_of_books_id            = sob.set_of_books_id
       AND app.upgrade_method             = 'R12_11ICASH_POST'
       AND app.org_id                     = osp.org_id(+)
       AND app.cash_receipt_id            = cr.cash_receipt_id
       AND app.cash_receipt_history_id    = crh.cash_receipt_history_id
       AND app.applied_customer_trx_id    = trx.customer_trx_id;


   local_log(procedure_name => 'load_line_data_app_from_cr',
             p_msg_text     => 'arp_xla_extract_main_pkg.load_line_data_app_from_cr ()-');
EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'load_line_data_app_from_cr',
             p_msg_text     =>'EXCEPTION OTHERS in arp_xla_extract_main_pkg.load_line_data_app_from_cr '||
             arp_global.CRLF ||'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.load_line_data_app_from_cr'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;
END load_line_data_app_from_cr;

/*-----------------------------------------------------------------+
 | Procedure Name : load_line_data_app_from_cm                     |
 | Description    : Extract the from application line attached to  |
 |                  a credit memo event                            |
 +-----------------------------------------------------------------+
 | History        :                                                |
 | 23-FEB-2004     Herve Yu    Created due to bug#3419926          |
 +-----------------------------------------------------------------*/
PROCEDURE load_line_data_app_from_cm(p_application_id IN NUMBER DEFAULT 222)
IS
BEGIN
   local_log(procedure_name => 'load_line_data_app_from_cm',
             p_msg_text     => 'arp_xla_extract_main_pkg.load_line_data_app_from_cm ()+');
    -- Insert line level data in Line GT with
    -- selected_flag = Y
    -- level_flag    = L
    -- From_to_flag  = F
    INSERT INTO ar_xla_lines_extract (
        EVENT_ID
       ,LINE_NUMBER
       ,LANGUAGE
       ,LEDGER_ID
       ,SOURCE_ID
       ,SOURCE_TABLE
       ,LINE_ID
       ,TAX_CODE_ID
       ,LOCATION_SEGMENT_ID
       ,BASE_CURRENCY_CODE
       ,EXCHANGE_RATE_TYPE
       ,EXCHANGE_RATE
       ,EXCHANGE_DATE
       ,ACCTD_AMOUNT
       ,TAXABLE_ACCTD_AMOUNT
       ,ORG_ID
       ,HEADER_TABLE_ID
       ,POSTING_ENTITY
       ,CASH_RECEIPT_ID
       ,CUSTOMER_TRX_ID
       ,CUSTOMER_TRX_LINE_ID
       ,CUST_TRX_LINE_GL_DIST_ID
       ,CUST_TRX_LINE_SALESREP_ID
       ,INVENTORY_ITEM_ID
       ,SALES_TAX_ID
       ,SO_ORGANIZATION_ID
       ,TAX_EXEMPTION_ID
       ,UOM_CODE
       ,WAREHOUSE_ID
       ,AGREEMENT_ID
       ,CUSTOMER_BANK_ACCT_ID
       ,DRAWEE_BANK_ACCOUNT_ID
       ,REMITTANCE_BANK_ACCT_ID
       ,DISTRIBUTION_SET_ID
       ,PAYMENT_SCHEDULE_ID
       ,RECEIPT_METHOD_ID
       ,RECEIVABLES_TRX_ID
       ,ED_ADJ_RECEIVABLES_TRX_ID
       ,UNED_RECEIVABLES_TRX_ID
       ,SET_OF_BOOKS_ID
       ,SALESREP_ID
       ,BILL_SITE_USE_ID
       ,DRAWEE_SITE_USE_ID
       ,PAYING_SITE_USE_ID
       ,SOLD_SITE_USE_ID
       ,SHIP_SITE_USE_ID
       ,RECEIPT_CUSTOMER_SITE_USE_ID
       ,BILL_CUST_ROLE_ID
       ,DRAWEE_CUST_ROLE_ID
       ,SHIP_CUST_ROLE_ID
       ,SOLD_CUST_ROLE_ID
       ,BILL_CUSTOMER_ID
       ,DRAWEE_CUSTOMER_ID
       ,PAYING_CUSTOMER_ID
       ,SOLD_CUSTOMER_ID
       ,SHIP_CUSTOMER_ID
       ,REMIT_ADDRESS_ID
       ,RECEIPT_BATCH_ID
       ,RECEIVABLE_APPLICATION_ID
       ,CUSTOMER_BANK_BRANCH_ID
       ,ISSUER_BANK_BRANCH_ID
       ,BATCH_SOURCE_ID
       ,BATCH_ID
       ,TERM_ID
       ,SELECT_FLAG
       ,LEVEL_FLAG
       ,FROM_TO_FLAG
       ,FROM_AMOUNT
       ,AMOUNT
       ,FROM_ACCTD_AMOUNT
       ,event_type_code
       ,event_class_code
       ,entity_code
       ,tax_line_id
       ,additional_char1
         ,MFAR_ADDITIONAL_ENTRY
       ,source_type
       ,CM_APP_TO_TRX_LINE_ID)
    -- FROM document type CM
      SELECT /*+LEADING(gt) USE_NL(gt,app)*/
           gt.event_id,                      -- EVENT_ID
           dist.line_id,                     -- LINE_NUMBER
           '',                               -- LANGUAGE
           sob.set_of_books_id,              -- LEDGER_ID
           dist.source_id,                   -- SOURCE_ID
           dist.source_table,                -- SOURCE_TABLE
           dist.line_id,                     -- LINE_ID
           dist.tax_code_id,                 -- TAX_CODE_ID
           dist.location_segment_id,         -- LOCATION_SEGMENT_ID
           sob.currency_code,                -- BASE_CURRENCY
	   /* bug7311808 -vavenugo*/
           NVL(DIST.CURRENCY_CONVERSION_TYPE,trxf.exchange_rate_type),          -- EXCHANGE_RATE_TYPE
           NVL(DIST.CURRENCY_CONVERSION_RATE,trxf.exchange_rate),               -- EXCHANGE_RATE
           NVL(DIST.CURRENCY_CONVERSION_DATE,trxf.exchange_date),               -- EXCHANGE_DATE
           /* End bug7311808 -vavenugo */
           NVL(dist.acctd_amount_cr,0) -
                NVL(dist.acctd_amount_dr,0),      -- ACCTD_AMOUNT
           NVL(dist.taxable_accounted_cr,0) -
                NVL(dist.taxable_accounted_dr,0), -- TAXABLE_ACCTD_AMOUNT
           app.org_id,                       -- ORG_ID
           app.receivable_application_id,    -- HEADER_TABLE_ID
           'APP',                            -- POSTING_ENTITY
           NULL,                             -- CASH_RECEIPT_ID
           trxf.customer_trx_id,             -- CUSTOMER_TRX_ID
           tlf.customer_trx_line_id,         -- CUSTOMER_TRX_LINE_ID
           gldf.cust_trx_line_gl_dist_id,    -- CUST_TRX_LINE_GL_DIST_ID
           gldf.cust_trx_line_salesrep_id,   -- CUST_TRX_LINE_SALESREP_ID
           tlf.inventory_item_id,            -- INVENTORY_ITEM_ID
           tlf.sales_tax_id,                 -- SALES_TAX_ID
           osp.master_organization_id,       -- SO_ORGANIZATION_ID
           tlf.tax_exemption_id,             -- TAX_EXEMPTION_ID
           tlf.uom_code,                     -- UOM_CODE
           tlf.warehouse_id,                 -- WAREHOUSE_ID
           trxf.agreement_id,                -- AGREEMENT_ID
           trxf.customer_bank_account_id,    -- CUSTOMER_BANK_ACCT_ID
           trxf.drawee_bank_account_id,      -- DRAWEE_BANK_ACCOUNT_ID
           trxf.remit_bank_acct_use_id,  -- REMITTANCE_BANK_ACCT_ID
           NULL,                             -- DISTRIBUTION_SET_ID
           psch.payment_schedule_id,         -- PAYMENT_SCHEDULE_ID
           trxf.receipt_method_id,           -- RECEIPT_METHOD_ID
           NULL,                             -- RECEIVABLES_TRX_ID
           NULL,                             -- ED_ADJ_RECEIVABLES_TRX_ID
           NULL,                             -- UNED_RECEIVABLES_TRX_ID
           trxf.set_of_books_id,             -- SET_OF_BOOKS_ID
           trxf.primary_salesrep_id,         -- SALESREP_ID
           trxf.bill_to_site_use_id,         -- BILL_SITE_USE_ID
           trxf.drawee_site_use_id,          -- DRAWEE_SITE_USE_ID
           trxf.paying_site_use_id,          -- PAYING_SITE_USE_ID
           trxf.sold_to_site_use_id,         -- SOLD_SITE_USE_ID
           trxf.ship_to_site_use_id,         -- SHIP_SITE_USE_ID
           NULL,                             -- RECEIPT_CUSTOMER_SITE_USE_ID
           trxf.bill_to_contact_id,          -- BILL_CUST_ROLE_ID
           trxf.drawee_contact_id,           -- DRAWEE_CUST_ROLE_ID
           trxf.ship_to_contact_id,          -- SHIP_CUST_ROLE_ID
           trxf.sold_to_contact_id,          -- SOLD_CUST_ROLE_ID
           trxf.bill_to_customer_id,         -- BILL_CUSTOMER_ID
           trxf.drawee_id,                   -- DRAWEE_CUSTOMER_ID
           trxf.paying_customer_id,          -- PAYING_CUSTOMER_ID
           trxf.sold_to_customer_id,         -- SOLD_CUSTOMER_ID
           trxf.ship_to_customer_id,         -- SHIP_CUSTOMER_ID
           trxf.remit_to_address_id,         -- REMIT_ADDRESS_ID
           NULL,                             -- RECEIPT_BATCH_ID
           NULL,                             -- RECEIVABLE_APPLICATION_ID
           NULL,                             -- CUSTOMER_BANK_BRANCH_ID
           NULL,                             -- ISSUER_BANK_BRANCH_ID
           trxf.batch_source_id,             -- BATCH_SOURCE_ID
           trxf.batch_id,                    -- BATCH_ID
           trxf.term_id,                     -- TERM_ID
           'Y',                              -- SELECT_FLAG
           'L',                              -- LEVEL_FLAG
           'F',                              -- FROM_TO_FLAG
         CASE WHEN (dist.from_amount_cr IS NULL AND dist.from_amount_dr IS NULL) THEN
           NVL(dist.amount_cr,0) - NVL(dist.amount_dr,0)
         ELSE
           NVL(dist.from_amount_cr,0) - NVL(dist.from_amount_dr,0)
         END,                                                     -- FROM_AMOUNT
           NVL(dist.amount_cr,0) - NVL(dist.amount_dr,0),         -- AMOUNT
         CASE WHEN (dist.from_acctd_amount_cr IS NULL AND dist.from_acctd_amount_dr IS NULL) THEN
           NVL(dist.acctd_amount_cr,0) - NVL(dist.acctd_amount_dr,0)
         ELSE
           NVL(dist.from_acctd_amount_cr,0) - NVL(dist.from_acctd_amount_dr,0)
         END,                                                     -- FROM_ACCTD_MOUNT
           gt.event_type_code,
           gt.event_class_code,
           gt.entity_code,
           tlf.tax_line_id,                      --tax_line_id
           app.upgrade_method
         ,'N'                    --MFAR_ADDITIONAL_ENTRY
         , dist.source_type
         , dist.REF_PREV_CUST_TRX_LINE_ID     -- RAM 9860123
      FROM xla_events_gt                  gt,
           ar_receivable_applications_all app,
           ar_distributions_all           dist,
           gl_sets_of_books               sob,
           oe_system_parameters_all       osp,
           ra_customer_trx_all            trxf,
           ra_customer_trx_lines_all      tlf,
           ra_cust_trx_line_gl_dist_all   gldf,
           ar_payment_schedules_all       psch
     WHERE gt.event_type_code    IN ('CM_CREATE','CM_UPDATE' ) --BUG#3419926
       AND gt.application_id     =     p_application_id
	   AND gt.event_id                      = app.event_id
       AND dist.source_table                = 'RA'
       AND dist.source_id                   = app.receivable_application_id
       AND app.set_of_books_id              = sob.set_of_books_id
       AND app.org_id                       = osp.org_id(+)
       AND app.customer_trx_id              = trxf.customer_trx_id
--
-- R12_11ICASH_POST is reserved for Upgraded 11i Cash basis not posted applications
-- We are not passing Cash basis at From Line level
-- the data for Cash Basis accounting upgraded will be at the To line level only
--
--       AND NVL(app.upgrade_method,'XX')   NOT IN ('R12_11ICASH_POST')
-- Need to incorporate PSA upgrade
       AND DECODE(app.upgrade_method,
	                'R12_11ICASH_POST','N',
                    '11I_MFAR_UPG'    ,DECODE(dist.source_table_secondary,'UPMFRAMIAR','Y','N'),
                     'Y')                   = 'Y'
--       AND trxf.customer_trx_id             = tlf.customer_trx_id
--       AND trxf.customer_trx_id             = gldf.customer_trx_id
       AND dist.ref_customer_trx_line_id    = tlf.customer_trx_line_id(+)
                          -- ?? application we only want line actually applied
       AND dist.ref_cust_trx_line_gl_dist_id = gldf.cust_trx_line_gl_dist_id(+)
                          -- ?? application we only want line actually applied
       AND trxf.customer_trx_id              = psch.customer_trx_id
       AND NVL(psch.terms_sequence_number,1) = 1
       AND dist.source_type               in ('REC','DEFERRED_TAX','TAX','CURR_ROUND')    /* Bug 6119725 Start Changes */
       AND ((dist.ref_cust_trx_line_gl_dist_id IS NOT NULL
               AND dist.ref_cust_trx_line_gl_dist_id  NOT IN (SELECT cust_trx_line_gl_dist_id
                                                       FROM ra_cust_trx_line_gl_dist_all ctlgd
                                                       WHERE ctlgd.customer_trx_id =  app.applied_customer_trx_id)) -- Restrict To rows of Invoice
         OR  ((dist.ref_cust_trx_line_gl_dist_id IS NULL
              AND ((sign((app.amount_applied+nvl(app.earned_discount_taken,0)+nvl(app.unearned_discount_taken,0)))*-1 = sign(nvl(dist.amount_cr,0) * -1+nvl(dist.amount_dr,0)) AND dist.source_type = 'DEFERRED_TAX' )/* Bug 8269394 Changes */
              OR ( sign((app.acctd_amount_applied_from+nvl(app.acctd_earned_discount_taken,0)+nvl(app.acctd_unearned_discount_taken,0)))*-1 = sign(nvl(dist.acctd_amount_dr,0) * -1+nvl(dist.acctd_amount_cr,0)) AND dist.source_type = 'CURR_ROUND')
              OR
              (( sign((app.amount_applied+nvl(app.earned_discount_taken,0)+nvl(app.unearned_discount_taken,0)))*-1 = sign(nvl(dist.amount_dr,0) * -1+nvl(dist.amount_cr,0)) AND dist.source_type not in ('DEFERRED_TAX','CURR_ROUND'))
               /* Bug 8269394 Changes */
             AND (((sign((app.amount_applied+nvl(app.earned_discount_taken,0)+nvl(app.unearned_discount_taken,0)))*-1) <> 0)
                OR
                  ((sign((app.amount_applied+nvl(app.earned_discount_taken,0)+nvl(app.unearned_discount_taken,0)))*-1 = 0)
                    AND dist.amount_cr is not null)))))));

/* Bug 6119725 End  Changes */




    --BUG#5366837
    INSERT INTO ar_xla_lines_extract (
        EVENT_ID
       ,LINE_NUMBER
       ,LANGUAGE
       ,LEDGER_ID
       ,SOURCE_ID
       ,SOURCE_TABLE
       ,LINE_ID
       ,TAX_CODE_ID
       ,LOCATION_SEGMENT_ID
       ,BASE_CURRENCY_CODE
       ,EXCHANGE_RATE_TYPE
       ,EXCHANGE_RATE
       ,EXCHANGE_DATE
       ,ACCTD_AMOUNT
       ,TAXABLE_ACCTD_AMOUNT
       ,ORG_ID
       ,HEADER_TABLE_ID
       ,POSTING_ENTITY
       ,CASH_RECEIPT_ID
       ,CUSTOMER_TRX_ID
       ,CUSTOMER_TRX_LINE_ID
       ,CUST_TRX_LINE_GL_DIST_ID
       ,CUST_TRX_LINE_SALESREP_ID
       ,INVENTORY_ITEM_ID
       ,SALES_TAX_ID
       ,SO_ORGANIZATION_ID
       ,TAX_EXEMPTION_ID
       ,UOM_CODE
       ,WAREHOUSE_ID
       ,AGREEMENT_ID
       ,CUSTOMER_BANK_ACCT_ID
       ,DRAWEE_BANK_ACCOUNT_ID
       ,REMITTANCE_BANK_ACCT_ID
       ,DISTRIBUTION_SET_ID
       ,PAYMENT_SCHEDULE_ID
       ,RECEIPT_METHOD_ID
       ,RECEIVABLES_TRX_ID
       ,ED_ADJ_RECEIVABLES_TRX_ID
       ,UNED_RECEIVABLES_TRX_ID
       ,SET_OF_BOOKS_ID
       ,SALESREP_ID
       ,BILL_SITE_USE_ID
       ,DRAWEE_SITE_USE_ID
       ,PAYING_SITE_USE_ID
       ,SOLD_SITE_USE_ID
       ,SHIP_SITE_USE_ID
       ,RECEIPT_CUSTOMER_SITE_USE_ID
       ,BILL_CUST_ROLE_ID
       ,DRAWEE_CUST_ROLE_ID
       ,SHIP_CUST_ROLE_ID
       ,SOLD_CUST_ROLE_ID
       ,BILL_CUSTOMER_ID
       ,DRAWEE_CUSTOMER_ID
       ,PAYING_CUSTOMER_ID
       ,SOLD_CUSTOMER_ID
       ,SHIP_CUSTOMER_ID
       ,REMIT_ADDRESS_ID
       ,RECEIPT_BATCH_ID
       ,RECEIVABLE_APPLICATION_ID
       ,CUSTOMER_BANK_BRANCH_ID
       ,ISSUER_BANK_BRANCH_ID
       ,BATCH_SOURCE_ID
       ,BATCH_ID
       ,TERM_ID
       ,SELECT_FLAG
       ,LEVEL_FLAG
       ,FROM_TO_FLAG
       ,FROM_AMOUNT
       ,AMOUNT
       ,FROM_ACCTD_AMOUNT
       ,event_type_code
       ,event_class_code
       ,entity_code
       ,tax_line_id
       ,additional_char1
        ,MFAR_ADDITIONAL_ENTRY
       )
      SELECT /*+LEADING(gt) USE_NL(gt,app)*/
            gt.event_id                      -- EVENT_ID
           ,dist.cash_basis_distribution_id  -- LINE_NUMBER
           ,''                               -- LANGUAGE
           ,sob.set_of_books_id              -- LEDGER_ID
           ,dist.source_id                   -- SOURCE_ID
           ,'RA'                             -- SOURCE_TABLE
           ,dist.cash_basis_distribution_id  -- LINE_ID
           ,NULL                             -- TAX_CODE_ID
           ,NULL                             -- LOCATION_SEGMENT_ID
           ,sob.currency_code                -- BASE_CURRENCY
           ,trxf.exchange_rate_type          -- EXCHANGE_RATE_TYPE
           ,trxf.exchange_rate               -- EXCHANGE_RATE
           ,trxf.exchange_date               -- EXCHANGE_DATE
           ,dist.acctd_amount                -- ACCTD_AMOUNT
           ,0                                -- TAXABLE_ACCTD_AMOUNT
           ,app.org_id                       -- ORG_ID
           ,app.receivable_application_id    -- HEADER_TABLE_ID
           ,'APP'                            -- POSTING_ENTITY
           ,NULL                             -- CASH_RECEIPT_ID
           ,trxf.customer_trx_id             -- CUSTOMER_TRX_ID
           ,tlf.customer_trx_line_id         -- CUSTOMER_TRX_LINE_ID
           ,gldf.cust_trx_line_gl_dist_id    -- CUST_TRX_LINE_GL_DIST_ID
           ,gldf.cust_trx_line_salesrep_id   -- CUST_TRX_LINE_SALESREP_ID
           ,tlf.inventory_item_id            -- INVENTORY_ITEM_ID
           ,tlf.sales_tax_id                 -- SALES_TAX_ID
           ,osp.master_organization_id       -- SO_ORGANIZATION_ID
           ,tlf.tax_exemption_id             -- TAX_EXEMPTION_ID
           ,tlf.uom_code                     -- UOM_CODE
           ,tlf.warehouse_id                 -- WAREHOUSE_ID
           ,trxf.agreement_id                -- AGREEMENT_ID
           ,trxf.customer_bank_account_id    -- CUSTOMER_BANK_ACCT_ID
           ,trxf.drawee_bank_account_id      -- DRAWEE_BANK_ACCOUNT_ID
           ,trxf.remit_bank_acct_use_id      -- REMITTANCE_BANK_ACCT_ID
           ,NULL                             -- DISTRIBUTION_SET_ID
           ,psch.payment_schedule_id         -- PAYMENT_SCHEDULE_ID
           ,trxf.receipt_method_id           -- RECEIPT_METHOD_ID
           ,NULL                             -- RECEIVABLES_TRX_ID
           ,NULL                             -- ED_ADJ_RECEIVABLES_TRX_ID
           ,NULL                             -- UNED_RECEIVABLES_TRX_ID
           ,trxf.set_of_books_id             -- SET_OF_BOOKS_ID
           ,trxf.primary_salesrep_id         -- SALESREP_ID
           ,trxf.bill_to_site_use_id         -- BILL_SITE_USE_ID
           ,trxf.drawee_site_use_id          -- DRAWEE_SITE_USE_ID
           ,trxf.paying_site_use_id          -- PAYING_SITE_USE_ID
           ,trxf.sold_to_site_use_id         -- SOLD_SITE_USE_ID
           ,trxf.ship_to_site_use_id         -- SHIP_SITE_USE_ID
           ,NULL                             -- RECEIPT_CUSTOMER_SITE_USE_ID
           ,trxf.bill_to_contact_id          -- BILL_CUST_ROLE_ID
           ,trxf.drawee_contact_id           -- DRAWEE_CUST_ROLE_ID
           ,trxf.ship_to_contact_id          -- SHIP_CUST_ROLE_ID
           ,trxf.sold_to_contact_id          -- SOLD_CUST_ROLE_ID
           ,trxf.bill_to_customer_id         -- BILL_CUSTOMER_ID
           ,trxf.drawee_id                   -- DRAWEE_CUSTOMER_ID
           ,trxf.paying_customer_id          -- PAYING_CUSTOMER_ID
           ,trxf.sold_to_customer_id         -- SOLD_CUSTOMER_ID
           ,trxf.ship_to_customer_id         -- SHIP_CUSTOMER_ID
           ,trxf.remit_to_address_id         -- REMIT_ADDRESS_ID
           ,NULL                             -- RECEIPT_BATCH_ID
           ,NULL                             -- RECEIVABLE_APPLICATION_ID
           ,NULL                             -- CUSTOMER_BANK_BRANCH_ID
           ,NULL                             -- ISSUER_BANK_BRANCH_ID
           ,trxf.batch_source_id             -- BATCH_SOURCE_ID
           ,trxf.batch_id                    -- BATCH_ID
           ,trxf.term_id                     -- TERM_ID
           ,'Y'                              -- SELECT_FLAG
           ,'L'                              -- LEVEL_FLAG
           ,'F'                              -- FROM_TO_FLAG
           ,dist.from_amount                 -- FROM_AMOUNT
           ,dist.amount                      -- AMOUNT
           ,dist.from_acctd_amount           -- FROM_ACCTD_MOUNT
           ,gt.event_type_code
           ,gt.event_class_code
           ,gt.entity_code
           ,tlf.tax_line_id                  --tax_line_id
           ,app.upgrade_method
         ,'N'                    --MFAR_ADDITIONAL_ENTRY
      FROM xla_events_gt                  gt,
           ar_receivable_applications_all app,
           ar_cash_basis_dists_all        dist,
           gl_sets_of_books               sob,
           oe_system_parameters_all       osp,
           ra_customer_trx_all            trxf,
           ra_customer_trx_lines_all      tlf,
           ra_cust_trx_line_gl_dist_all   gldf,
           ar_payment_schedules_all       psch
     WHERE gt.event_type_code               IN ('CM_CREATE','CM_UPDATE' )
       AND gt.application_id                 = 222
       AND gt.event_id                       = app.event_id
       AND dist.receivable_application_id    = app.receivable_application_id
       AND app.set_of_books_id               = sob.set_of_books_id
       AND app.org_id                        = osp.org_id(+)
       AND app.customer_trx_id               = trxf.customer_trx_id
       AND app.upgrade_method                = 'R12_11ICASH_POST'
       AND trxf.customer_trx_id              = tlf.customer_trx_id
       AND trxf.customer_trx_id              = gldf.customer_trx_id
       AND dist.ref_customer_trx_line_id     = tlf.customer_trx_line_id(+)
       AND dist.ref_cust_trx_line_gl_dist_id = gldf.cust_trx_line_gl_dist_id(+)
       AND trxf.customer_trx_id              = psch.customer_trx_id
       AND NVL(psch.terms_sequence_number,1) = 1;


   local_log(procedure_name => 'load_line_data_app_from_cm',
             p_msg_text     => 'arp_xla_extract_main_pkg.load_line_data_app_from_cm ()-');
EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'load_line_data_app_from_cm',
             p_msg_text     => 'EXCEPTION OTHERS in arp_xla_extract_main_pkg.load_line_data_app_from_cm '||
			                    arp_global.CRLF || 'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.load_line_data_app_from_cm'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;
END load_line_data_app_from_cm;


---------------------------------
-- Header loading procedures   --
---------------------------------
/*-----------------------------------------------------------------+
 | Procedure Name : Load_header_data_ctlgd                         |
 | Description    : Extract header data for transaction events     |
 +-----------------------------------------------------------------+
 | History        :                                                |
 | 23-FEB-2004     Herve Yu    Created due to bug#3419926          |
 +-----------------------------------------------------------------*/
PROCEDURE Load_header_data_ctlgd(p_application_id  IN NUMBER DEFAULT 222)
IS
BEGIN
  local_log(procedure_name => 'load_header_data_ctlgd',
            p_msg_text     => 'arp_xla_extract_main_pkg.load_header_data_ctlgd ()+');
    -----------------------
    -- Insert header into ar_xla_lines_extract with
    -- selected_flg = 'Y'
    -- level_flg    = 'H'
    -- We also need to insert the header data into ar_xla_headers_extract
    -- because the view AR_LEDGER_EXT_H is a pure header level view but it is
    -- used by the transaction event_types posting with the entity CTLGD
    -----------------------
    -- Insert into Lines GT
     INSERT INTO AR_XLA_LINES_EXTRACT(
        EVENT_ID
       ,SOURCE_ID
       ,SOURCE_TABLE
       ,LINE_ID
       ,TAX_CODE_ID
       ,LOCATION_SEGMENT_ID
       ,BASE_CURRENCY_CODE
       ,EXCHANGE_RATE_TYPE
       ,EXCHANGE_RATE
       ,EXCHANGE_DATE
       ,ACCTD_AMOUNT
       ,TAXABLE_ACCTD_AMOUNT
       ,ORG_ID
       ,HEADER_TABLE_ID
       ,POSTING_ENTITY
       ,CASH_RECEIPT_ID
       ,CUSTOMER_TRX_ID
       ,CUSTOMER_TRX_LINE_ID
       ,CUST_TRX_LINE_GL_DIST_ID
       ,CUST_TRX_LINE_SALESREP_ID
       ,INVENTORY_ITEM_ID
       ,SALES_TAX_ID
       ,SO_ORGANIZATION_ID
       ,TAX_EXEMPTION_ID
       ,UOM_CODE
       ,WAREHOUSE_ID
       ,AGREEMENT_ID
       ,CUSTOMER_BANK_ACCT_ID
       ,DRAWEE_BANK_ACCOUNT_ID
       ,REMITTANCE_BANK_ACCT_ID
       ,DISTRIBUTION_SET_ID
       ,PAYMENT_SCHEDULE_ID
       ,RECEIPT_METHOD_ID
       ,RECEIVABLES_TRX_ID
       ,ED_ADJ_RECEIVABLES_TRX_ID
       ,UNED_RECEIVABLES_TRX_ID
       ,SET_OF_BOOKS_ID
       ,SALESREP_ID
       ,BILL_SITE_USE_ID
       ,DRAWEE_SITE_USE_ID
       ,PAYING_SITE_USE_ID
       ,SOLD_SITE_USE_ID
       ,SHIP_SITE_USE_ID
       ,RECEIPT_CUSTOMER_SITE_USE_ID
       ,BILL_CUST_ROLE_ID
       ,DRAWEE_CUST_ROLE_ID
       ,SHIP_CUST_ROLE_ID
       ,SOLD_CUST_ROLE_ID
       ,BILL_CUSTOMER_ID
       ,DRAWEE_CUSTOMER_ID
       ,PAYING_CUSTOMER_ID
       ,SOLD_CUSTOMER_ID
       ,SHIP_CUSTOMER_ID
       ,REMIT_ADDRESS_ID
       ,RECEIPT_BATCH_ID
       ,RECEIVABLE_APPLICATION_ID
       ,CUSTOMER_BANK_BRANCH_ID
       ,ISSUER_BANK_BRANCH_ID
       ,BATCH_SOURCE_ID
       ,BATCH_ID
       ,TERM_ID
       ,SELECT_FLAG
       ,LEVEL_FLAG
       ,FROM_TO_FLAG
       ,PAIRED_CCID
       --{BUG#4356088
       ,event_type_code
       ,event_class_code
       ,entity_code
         ,MFAR_ADDITIONAL_ENTRY
        )
       SELECT /*+ LEADING(gt,trx,ctlgd)  USE_NL(gt,trx,ctlgd)*/
          gt.event_id                -- EVENT_ID
         ,''                            -- SOURCE_ID
         ,''                            -- SOURCE_TABLE
         ,''                            -- LINE_ID
         ,''                            -- TAX_CODE_ID
         ,''                            -- LOCATION_SEGMENT_ID
         ,sob.currency_code             -- BASE_CURRENCY_CODE
         ,trx.exchange_rate_type        -- EXCHANGE_RATE_TYPE
         ,trx.exchange_rate             -- EXCHANGE_RATE
         ,trx.exchange_date             -- EXCHANGE_DATE
         ,''                            -- ACCTD_AMOUNT
         ,''                            -- TAXABLE_ACCTD_AMOUNT
         ,trx.org_id                    -- ORG_ID
         ,''                            -- HEADER_TABLE_ID
         ,'CTLGD'                       -- POSTING_ENTITY
         ,''                            -- CASH_RECEIPT_ID
         ,trx.customer_trx_id           -- CUSTOMER_TRX_ID
         ,''                            -- CUSTOMER_TRX_LINE_ID
         ,''                            -- CUST_TRX_LINE_GL_DIST_ID
         ,''                            -- CUST_TRX_LINE_SALESREP_ID
         ,''                            -- INVENTORY_ITEM_ID
         ,''                            -- SALES_TAX_ID
         ,''                            -- SO_ORGANIZATION_ID
         ,''                            -- TAX_EXEMPTION_ID
         ,''                            -- UOM_CODE
         ,''                            -- WAREHOUSE_ID
         ,trx.agreement_id              -- AGREEMENT_ID
         ,trx.customer_bank_account_id  -- CUSTOMER_BANK_ACCT_ID
         ,trx.drawee_bank_account_id    -- DRAWEE_BANK_ACCOUNT_ID
         ,trx.remit_bank_acct_use_id    -- REMITTANCE_BANK_ACCT_ID
         ,''                            -- DISTRIBUTION_SET_ID
         ,psch.payment_schedule_id      -- PAYMENT_SCHEDULE_ID
         ,trx.receipt_method_id         -- RECEIPT_METHOD_ID
         ,''                            -- RECEIVABLES_TRX_ID
         ,''                            -- ED_ADJ_RECEIVABLES_TRX_ID
         ,''                            -- UNED_RECEIVABLES_TRX_ID
         ,trx.set_of_books_id           -- SET_OF_BOOKS_ID
         ,trx.primary_salesrep_id       -- SALESREP_ID
         ,trx.bill_to_site_use_id       -- BILL_SITE_USE_ID
         ,trx.drawee_site_use_id        -- DRAWEE_SITE_USE_ID
         ,trx.paying_site_use_id        -- PAYING_SITE_USE_ID
         ,trx.sold_to_site_use_id       -- SOLD_SITE_USE_ID
         ,trx.ship_to_site_use_id       -- SHIP_SITE_USE_ID
         ,''                            -- RECEIPT_CUSTOMER_SITE_USE_ID
         ,trx.bill_to_contact_id        -- BILL_CUST_ROLE_ID
         ,trx.drawee_contact_id         -- DRAWEE_CUST_ROLE_ID
         ,trx.ship_to_contact_id        -- SHIP_CUST_ROLE_ID
         ,trx.sold_to_contact_id        -- SOLD_CUST_ROLE_ID
         ,trx.bill_to_customer_id       -- BILL_CUSTOMER_ID
         ,trx.drawee_id                 -- DRAWEE_CUSTOMER_ID
         ,trx.paying_customer_id        -- PAYING_CUSTOMER_ID
         ,trx.sold_to_customer_id       -- SOLD_CUSTOMER_ID
         ,trx.ship_to_customer_id       -- SHIP_CUSTOMER_ID
         ,trx.remit_to_address_id       -- REMIT_ADDRESS_ID
         ,''                            -- RECEIPT_BATCH_ID
         ,''                            -- RECEIVABLE_APPLICATION_ID
         ,''                            -- CUSTOMER_BANK_BRANCH_ID
         ,''                            -- ISSUER_BANK_BRANCH_ID
         ,trx.batch_source_id           -- BATCH_SOURCE_ID
         ,trx.batch_id                  -- BATCH_ID
         ,trx.term_id                   -- TERM_ID
         ,'Y'                           -- SELECT_FLAG
         ,'H'                           -- LEVEL_FLAG
         ,''                            -- FROM_TO_FLAG
         ,ctlgd.code_combination_id     -- paired_ccid
         --{BUG#4356088
         ,gt.event_type_code
         ,gt.event_class_code
         ,gt.entity_code
         ,'N'                    --MFAR_ADDITIONAL_ENTRY
      FROM ra_customer_trx_all            trx,
           gl_sets_of_books               sob,
           xla_events_gt                  gt,
           ar_payment_schedules_all       psch,
           ra_cust_trx_line_gl_dist_all   ctlgd
     WHERE gt.event_type_code IN ('INV_CREATE'     , 'INV_UPDATE'     ,
                                     'CM_CREATE'      , 'CM_UPDATE'      ,
                                     'DM_CREATE'      , 'DM_UPDATE'      ,
                                     'DEP_CREATE'     , 'DEP_UPDATE' ,
                                     'GUAR_CREATE'    , 'GUAR_UPDATE'    ,
                                     'CB_CREATE'      ) --BUG#3419926
       AND gt.application_id         = p_application_id
	   AND trx.customer_trx_id       = gt.source_id_int_1
       AND trx.set_of_books_id       = sob.set_of_books_id
       AND trx.customer_trx_id       = ctlgd.customer_trx_id
       AND ctlgd.account_class       = 'REC'
       AND ctlgd.account_set_flag    = 'N'
       AND trx.customer_trx_id       = psch.customer_trx_id(+)
       AND NVL(psch.terms_sequence_number,1) = 1;

     /*------------------------------------------------+
      | Due to unified accounting sources modal, the   |
      | data for header extract are already inserted   |
      | in the actract line table. The code in header  |
      | insertion is therefore not usefull. Unless it  |
      | a denormalised approach for header data for    |
      | performance reason. This needs to be evaluated.|
      | For now, I commented the header table insertion|
      | we might end up with removing the header table.|
      +------------------------------------------------*/
    /* to be removed at the end of the project*/
     -- Load_header_data_ctlgd_h ;
  local_log(procedure_name => 'load_header_data_ctlgd',
            p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.load_header_data_ctlgd()-');

EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
  local_log(procedure_name => 'load_header_data_ctlgd',
            p_msg_text     => 'EXCEPTION OTHERS in arp_xla_extract_main_pkg.load_header_data_ctlgd '||
			                   arp_global.CRLF ||'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.load_header_data_ctlgd'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;
END Load_header_data_ctlgd;

---------------------------
/*-----------------------------------------------------------------+
 | Procedure Name : Load_header_data_adj                           |
 | Description    : Extract header data for adjustment events      |
 +-----------------------------------------------------------------+
 | History        :                                                |
 | 23-FEB-2004     Herve Yu    Created due to bug#3419926          |
 +-----------------------------------------------------------------*/
PROCEDURE Load_header_data_adj(p_application_id  IN NUMBER DEFAULT 222)
IS
BEGIN
  local_log(procedure_name => 'load_header_data_adj',
            p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.load_header_data_adj()+');
    -- Insert into Lines GT for adjustments because header level
    -- shared sources can be used.
     INSERT INTO AR_XLA_LINES_EXTRACT(
        EVENT_ID
       ,SOURCE_ID
       ,SOURCE_TABLE
       ,LINE_ID
       ,TAX_CODE_ID
       ,LOCATION_SEGMENT_ID
       ,BASE_CURRENCY_CODE
       ,EXCHANGE_RATE_TYPE
       ,EXCHANGE_RATE
       ,EXCHANGE_DATE
       ,ACCTD_AMOUNT
       ,TAXABLE_ACCTD_AMOUNT
       ,ORG_ID
       ,HEADER_TABLE_ID
       ,POSTING_ENTITY
       ,CASH_RECEIPT_ID
       ,CUSTOMER_TRX_ID
       ,CUSTOMER_TRX_LINE_ID
       ,CUST_TRX_LINE_GL_DIST_ID
       ,CUST_TRX_LINE_SALESREP_ID
       ,INVENTORY_ITEM_ID
       ,SALES_TAX_ID
       ,SO_ORGANIZATION_ID
       ,TAX_EXEMPTION_ID
       ,UOM_CODE
       ,WAREHOUSE_ID
       ,AGREEMENT_ID
       ,CUSTOMER_BANK_ACCT_ID
       ,DRAWEE_BANK_ACCOUNT_ID
       ,REMITTANCE_BANK_ACCT_ID
       ,DISTRIBUTION_SET_ID
       ,PAYMENT_SCHEDULE_ID
       ,RECEIPT_METHOD_ID
       ,RECEIVABLES_TRX_ID
       ,ED_ADJ_RECEIVABLES_TRX_ID
       ,UNED_RECEIVABLES_TRX_ID
       ,SET_OF_BOOKS_ID
       ,SALESREP_ID
       ,BILL_SITE_USE_ID
       ,DRAWEE_SITE_USE_ID
       ,PAYING_SITE_USE_ID
       ,SOLD_SITE_USE_ID
       ,SHIP_SITE_USE_ID
       ,RECEIPT_CUSTOMER_SITE_USE_ID
       ,BILL_CUST_ROLE_ID
       ,DRAWEE_CUST_ROLE_ID
       ,SHIP_CUST_ROLE_ID
       ,SOLD_CUST_ROLE_ID
       ,BILL_CUSTOMER_ID
       ,DRAWEE_CUSTOMER_ID
       ,PAYING_CUSTOMER_ID
       ,SOLD_CUSTOMER_ID
       ,SHIP_CUSTOMER_ID
       ,REMIT_ADDRESS_ID
       ,RECEIPT_BATCH_ID
       ,RECEIVABLE_APPLICATION_ID
       ,CUSTOMER_BANK_BRANCH_ID
       ,ISSUER_BANK_BRANCH_ID
       ,BATCH_SOURCE_ID
       ,BATCH_ID
       ,TERM_ID
       ,SELECT_FLAG
       ,LEVEL_FLAG
       ,FROM_TO_FLAG
       ,paired_ccid
       --{BUG#4356088
       ,event_type_code
       ,event_class_code
       ,entity_code
       ,MFAR_ADDITIONAL_ENTRY
	    )
       SELECT /*+LEADING(gt) USE_NL(gt, adj)*/
          gt.event_id,                        -- EVENT_ID
          '',                                 -- SOURCE_ID
          '',                                 -- SOURCE_TABLE
          '',                                 -- LINE_ID
          '',                                 -- TAX_CODE_ID
          '',                                 -- LOCATION_SEGMENT_ID
          sob.currency_code,                  -- BASE_CURRENCY_CODE
          trxf.exchange_rate_type,            -- EXCHANGE_RATE_TYPE
          trxf.exchange_rate,                 -- EXCHANGE_RATE
          trxf.exchange_date,                 -- EXCHANGE_DATE
          '',                                 -- ACCTD_AMOUNT
          '',                                 -- TAXABLE_ACCTD_AMOUNT
          adj.org_id,                         -- ORG_ID
          adj.adjustment_id,                  -- HEADER_TABLE_ID
          'ADJ',                              -- POSTING_ENTITY
          '',                                 -- CASH_RECEIPT_ID
          adj.customer_trx_id,                -- CUSTOMER_TRX_ID
          '',                                 -- CUSTOMER_TRX_LINE_ID
          '',                                 -- CUST_TRX_LINE_GL_DIST_ID
          trxf.primary_salesrep_id,           -- SALESREP_ID
          '',                                 -- INVENTORY_ITEM_ID
          '',                                 -- SALES_TAX_ID
          '',                                 -- SO_ORGANIZATION_ID
          '',                                 -- TAX_EXEMPTION_ID
          '',                                 -- UOM_CODE
          '',                                 -- WAREHOUSE_ID
          trxf.agreement_id,                  -- AGREEMENT_ID
          trxf.customer_bank_account_id,      -- CUSTOMER_BANK_ACCT_ID
          '',                                 -- DRAWEE_BANK_ACCOUNT_ID
          trxf.remit_bank_acct_use_id,    -- REMITTANCE_BANK_ACCT_ID
          adj.distribution_set_id,            -- DISTRIBUTION_SET_ID
          adj.payment_schedule_id,            -- PAYMENT_SCHEDULE_ID
          trxf.receipt_method_id,             -- RECEIPT_METHOD_ID
          adj.receivables_trx_id,             -- RECEIVABLES_TRX_ID
          '',                                 -- ED_ADJ_RECEIVABLES_TRX_ID
          '',                                 -- UNED_RECEIVABLES_TRX_ID
          adj.set_of_books_id,                -- SET_OF_BOOKS_ID
          trxf.primary_salesrep_id,           -- SALESREP_ID
          trxf.bill_to_site_use_id,           -- BILL_SITE_USE_ID
          trxf.drawee_site_use_id,            -- DRAWEE_SITE_USE_ID
          trxf.paying_site_use_id,            -- PAYING_SITE_USE_ID
          trxf.sold_to_site_use_id,           -- SOLD_SITE_USE_ID
          trxf.ship_to_site_use_id,           -- SHIP_SITE_USE_ID
          '',                                 -- RECEIPT_CUSTOMER_SITE_USE_ID
          trxf.bill_to_contact_id,            -- BILL_CUST_ROLE_ID
          '',                                 -- DRAWEE_CUST_ROLE_ID
          trxf.ship_to_contact_id,            -- SHIP_CUST_ROLE_ID
          trxf.sold_to_contact_id,            -- SOLD_CUST_ROLE_ID
          trxf.bill_to_customer_id,           -- BILL_CUSTOMER_ID
          trxf.drawee_id,                     -- DRAWEE_CUSTOMER_ID
          trxf.paying_customer_id,            -- PAYING_CUSTOMER_ID
          trxf.sold_to_customer_id,           -- SOLD_CUSTOMER_ID
          trxf.ship_to_customer_id,           -- SHIP_CUSTOMER_ID
          trxf.remit_to_address_id,           -- REMIT_ADDRESS_ID
          '',                                 -- RECEIPT_BATCH_ID
          '',                                 -- RECEIVABLE_APPLICATION_ID
          '',                                 -- CUSTOMER_BANK_BRANCH_ID
          '',                                 -- ISSUER_BANK_BRANCH_ID
          trxf.batch_source_id,               -- BATCH_SOURCE_ID
          trxf.batch_id,                      -- BATCH_ID
          trxf.term_id,                       -- TERM_ID
          'Y',                                -- select_flag
          'H',                                -- level_flag
          '',                                 -- FROM_TO_FLAG
          ctlgd.code_combination_id           -- paired_ccid
         --{BUG#4356088
         ,gt.event_type_code
         ,gt.event_class_code
         ,gt.entity_code
         ,'N'                    --MFAR_ADDITIONAL_ENTRY
      FROM ar_adjustments_all             adj,
           gl_sets_of_books               sob,
           xla_events_gt                  gt,
           ra_customer_trx_all            trxf,
           ra_cust_trx_line_gl_dist_all   ctlgd
     WHERE gt.event_type_code             = 'ADJ_CREATE'
       AND gt.application_id              = p_application_id
	   AND adj.adjustment_id              = gt.source_id_int_1
       AND adj.set_of_books_id            = sob.set_of_books_id
       AND adj.customer_trx_id            = trxf.customer_trx_id(+)
       AND trxf.customer_trx_id           = ctlgd.customer_trx_id
       AND ctlgd.account_set_flag         = 'N'
       AND ctlgd.account_class            = 'REC'
       UNION ALL
      SELECT /*+LEADING(gt) USE_NL(gt, adj)*/
         gt.event_id,                        -- EVENT_ID
         '',                                 -- SOURCE_ID
         '',                                 -- SOURCE_TABLE
         '',                                 -- LINE_ID
         '',                                 -- TAX_CODE_ID
         '',                                 -- LOCATION_SEGMENT_ID
         sob.currency_code,                  -- BASE_CURRENCY_CODE
         trxf.exchange_rate_type,            -- EXCHANGE_RATE_TYPE
         trxf.exchange_rate,                 -- EXCHANGE_RATE
         trxf.exchange_date,                 -- EXCHANGE_DATE
         '',                                 -- ACCTD_AMOUNT
         '',                                 -- TAXABLE_ACCTD_AMOUNT
         adj.org_id,                         -- ORG_ID
         adj.adjustment_id,                  -- HEADER_TABLE_ID
         'ADJ',                              -- POSTING_ENTITY
         '',                                 -- CASH_RECEIPT_ID
         adj.customer_trx_id,                -- CUSTOMER_TRX_ID
         '',                                 -- CUSTOMER_TRX_LINE_ID
         '',                                 -- CUST_TRX_LINE_GL_DIST_ID
         trxf.primary_salesrep_id,           -- SALESREP_ID
         '',                                 -- INVENTORY_ITEM_ID
         '',                                 -- SALES_TAX_ID
         '',                                 -- SO_ORGANIZATION_ID
         '',                                 -- TAX_EXEMPTION_ID
         '',                                 -- UOM_CODE
         '',                                 -- WAREHOUSE_ID
         trxf.agreement_id,                  -- AGREEMENT_ID
         trxf.customer_bank_account_id,      -- CUSTOMER_BANK_ACCT_ID
         '',                                 -- DRAWEE_BANK_ACCOUNT_ID
         trxf.remit_bank_acct_use_id,    -- REMITTANCE_BANK_ACCT_ID
         adj.distribution_set_id,            -- DISTRIBUTION_SET_ID
         adj.payment_schedule_id,            -- PAYMENT_SCHEDULE_ID
         trxf.receipt_method_id,             -- RECEIPT_METHOD_ID
         adj.receivables_trx_id,             -- RECEIVABLES_TRX_ID
         '',                                 -- ED_ADJ_RECEIVABLES_TRX_ID
         '',                                 -- UNED_RECEIVABLES_TRX_ID
         adj.set_of_books_id,                -- SET_OF_BOOKS_ID
         trxf.primary_salesrep_id,           -- SALESREP_ID
         trxf.bill_to_site_use_id,           -- BILL_SITE_USE_ID
         trxf.drawee_site_use_id,            -- DRAWEE_SITE_USE_ID
         trxf.paying_site_use_id,            -- PAYING_SITE_USE_ID
         trxf.sold_to_site_use_id,           -- SOLD_SITE_USE_ID
         trxf.ship_to_site_use_id,           -- SHIP_SITE_USE_ID
         '',                                 -- RECEIPT_CUSTOMER_SITE_USE_ID
         trxf.bill_to_contact_id,            -- BILL_CUST_ROLE_ID
         '',                                 -- DRAWEE_CUST_ROLE_ID
         trxf.ship_to_contact_id,            -- SHIP_CUST_ROLE_ID
         trxf.sold_to_contact_id,            -- SOLD_CUST_ROLE_ID
         trxf.bill_to_customer_id,           -- BILL_CUSTOMER_ID
         trxf.drawee_id,                     -- DRAWEE_CUSTOMER_ID
         trxf.paying_customer_id,            -- PAYING_CUSTOMER_ID
         trxf.sold_to_customer_id,           -- SOLD_CUSTOMER_ID
         trxf.ship_to_customer_id,           -- SHIP_CUSTOMER_ID
         trxf.remit_to_address_id,           -- REMIT_ADDRESS_ID
         '',                                 -- RECEIPT_BATCH_ID
         '',                                 -- RECEIVABLE_APPLICATION_ID
         '',                                 -- CUSTOMER_BANK_BRANCH_ID
         '',                                 -- ISSUER_BANK_BRANCH_ID
         trxf.batch_source_id,               -- BATCH_SOURCE_ID
         trxf.batch_id,                      -- BATCH_ID
         trxf.term_id,                       -- TERM_ID
         'Y',                                -- select_flag
         'H',                                -- level_flag
         '',                                 -- FROM_TO_FLAG
         ard.code_combination_id           -- paired_ccid
        --{BUG#4356088
        ,gt.event_type_code
        ,gt.event_class_code
        ,gt.entity_code
        ,'N'                    --MFAR_ADDITIONAL_ENTRY
     FROM ar_adjustments_all             adj,
          gl_sets_of_books               sob,
          xla_events_gt                  gt,
          ra_customer_trx_all            trxf,
          ar_transaction_history_all     trh,
          ar_distributions_all           ard
    WHERE gt.event_type_code             = 'ADJ_CREATE'
      AND gt.application_id              = p_application_id
          AND adj.adjustment_id              = gt.source_id_int_1
      AND adj.set_of_books_id            = sob.set_of_books_id
      AND adj.customer_trx_id            = trxf.customer_trx_id(+)
      AND trxf.customer_trx_id           = trh.customer_trx_id
      AND trh.current_accounted_flag     = 'Y'
      AND trh.postable_flag              = 'Y'
      AND ard.source_table               = 'TH'
      AND ard.source_id                  = trh.transaction_history_id
      AND ard.source_type                = 'REC'
      AND ard.ref_customer_trx_line_id   is null
      AND ard.ref_cust_trx_line_gl_dist_id is null;

    -- Load_header_data_adj_h;
  local_log(procedure_name => 'load_header_data_adj',
            p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.load_header_data_adj()-');
EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
    local_log(procedure_name => 'load_header_data_adj',
              p_msg_text     => 'EXCEPTION OTHERS in arp_xla_extract_main_pkg.load_header_data_adj '||
                              arp_global.CRLF || 'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.load_header_data_adj'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;
END Load_header_data_adj;

-----------------------------------------------------------------------

/*-----------------------------------------------------------------+
 | Procedure Name : Load_header_data_crh                           |
 | Description    : Extract header data for cash receipt           |
 |                  and misc cash receipt events.                  |
 +-----------------------------------------------------------------+
 | History        :                                                |
 | 23-FEB-2004     Herve Yu    Created due to bug#3419926          |
 +-----------------------------------------------------------------*/
PROCEDURE Load_header_data_crh(p_application_id IN NUMBER DEFAULT 222)
IS
BEGIN
    local_log(procedure_name => 'load_header_data_crh',
              p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.load_header_data_crh()+');
     -- Insert header data to line level
     -- Pure Header sources and Shared header sources
     INSERT INTO AR_XLA_LINES_EXTRACT(
        EVENT_ID
       ,SOURCE_ID
       ,SOURCE_TABLE
       ,LINE_ID
       ,TAX_CODE_ID
       ,LOCATION_SEGMENT_ID
       ,BASE_CURRENCY_CODE
       ,EXCHANGE_RATE_TYPE
       ,EXCHANGE_RATE
       ,EXCHANGE_DATE
       ,ACCTD_AMOUNT
       ,TAXABLE_ACCTD_AMOUNT
       ,ORG_ID
       ,HEADER_TABLE_ID
       ,POSTING_ENTITY
       ,CASH_RECEIPT_ID
       ,CUSTOMER_TRX_ID
       ,CUSTOMER_TRX_LINE_ID
       ,CUST_TRX_LINE_GL_DIST_ID
       ,CUST_TRX_LINE_SALESREP_ID
       ,INVENTORY_ITEM_ID
       ,SALES_TAX_ID
       ,SO_ORGANIZATION_ID
       ,TAX_EXEMPTION_ID
       ,UOM_CODE
       ,WAREHOUSE_ID
       ,AGREEMENT_ID
       ,CUSTOMER_BANK_ACCT_ID
       ,DRAWEE_BANK_ACCOUNT_ID
       ,REMITTANCE_BANK_ACCT_ID
       ,DISTRIBUTION_SET_ID
       ,PAYMENT_SCHEDULE_ID
       ,RECEIPT_METHOD_ID
       ,RECEIVABLES_TRX_ID
       ,ED_ADJ_RECEIVABLES_TRX_ID
       ,UNED_RECEIVABLES_TRX_ID
       ,SET_OF_BOOKS_ID
       ,SALESREP_ID
       ,BILL_SITE_USE_ID
       ,DRAWEE_SITE_USE_ID
       ,PAYING_SITE_USE_ID
       ,SOLD_SITE_USE_ID
       ,SHIP_SITE_USE_ID
       ,RECEIPT_CUSTOMER_SITE_USE_ID
       ,BILL_CUST_ROLE_ID
       ,DRAWEE_CUST_ROLE_ID
       ,SHIP_CUST_ROLE_ID
       ,SOLD_CUST_ROLE_ID
       ,BILL_CUSTOMER_ID
       ,DRAWEE_CUSTOMER_ID
       ,PAYING_CUSTOMER_ID
       ,SOLD_CUSTOMER_ID
       ,SHIP_CUSTOMER_ID
       ,REMIT_ADDRESS_ID
       ,RECEIPT_BATCH_ID
       ,RECEIVABLE_APPLICATION_ID
       ,CUSTOMER_BANK_BRANCH_ID
       ,ISSUER_BANK_BRANCH_ID
       ,BATCH_SOURCE_ID
       ,BATCH_ID
       ,TERM_ID
       ,SELECT_FLAG
       ,LEVEL_FLAG
       ,FROM_TO_FLAG
       ,CRH_STATUS
       ,CRH_PRV_STATUS
       --{BUG#4356088
       ,event_type_code
       ,event_class_code
       ,entity_code
       --}
       ,reversal_code --Reversal at header should return 'Y' for RECP_REVERSAL
       ,MFAR_ADDITIONAL_ENTRY
       )
       SELECT /*+LEADING(gt) USE_NL(gt,cr)*/
          gt.event_id,        --EVENT_ID
          '',                 --SOURCE_ID
          '',                 --SOURCE_TABLE
          '',                 --LINE_ID
          '',                 --TAX_CODE_ID
          '',                 --LOCATION_SEGMENT_ID
          sob.currency_code,    -- BASE_CURRENCY_CODE
          cr.exchange_rate_type,-- EXCHANGE_RATE_TYPE
          cr.exchange_rate,     -- EXCHANGE_RATE
          cr.exchange_date,     -- EXCHANGE_DATE
          '',                 --ACCTD_AMOUNT
          '',                 --TAXABLE_ACCTD_AMOUNT
          cr.org_id,          --ORG_ID
          cr.cash_receipt_id, --HEADER_TABLE_ID
          'CR',               --POSTING_ENTITY
          cr.cash_receipt_id, --CASH_RECEIPT_ID
          '',                 --CUSTOMER_TRX_ID
          '',                 --CUSTOMER_TRX_LINE_ID
          '',                 --CUST_TRX_LINE_GL_DIST_ID
          '',                 --CUST_TRX_LINE_SALESREP_ID
          '',                 --INVENTORY_ITEM_ID
          '',                 --SALES_TAX_ID
          '',                 --SO_ORGANIZATION_ID
          '',                 --TAX_EXEMPTION_ID
          '',                 --UOM_CODE
          '',                 --WAREHOUSE_ID
          '',                 --AGREEMENT_ID
          cr.customer_bank_account_id,        -- CUSTOMER_BANK_ACCT_ID
          '',                                 -- DRAWEE_BANK_ACCOUNT_ID
          cr.remit_bank_acct_use_id,      -- REMITTANCE_BANK_ACCT_ID
          cr.distribution_set_id,             -- DISTRIBUTION_SET_ID
          '',                                 -- PAYMENT_SCHEDULE_ID
          cr.receipt_method_id,               -- RECEIPT_METHOD_ID
          cr.receivables_trx_id,              -- RECEIVABLES_TRX_ID
          '',                                 -- ED_ADJ_RECEIVABLES_TRX_ID
          '',                                 -- UNED_RECEIVABLES_TRX_ID
          cr.set_of_books_id,                 -- SET_OF_BOOKS_ID
          '',                                 -- SALESREP_ID
          cr.customer_site_use_id,            -- BILL_SITE_USE_ID
          '',                                 -- DRAWEE_SITE_USE_ID
          cr.customer_site_use_id,            -- PAYING_SITE_USE_ID -- HYU
          '',                                 -- SOLD_SITE_USE_ID
          '',                                 -- SHIP_SITE_USE_ID
          cr.customer_site_use_id,            -- RECEIPT_CUSTOMER_SITE_USE_ID
          '',                                 -- BILL_CUST_ROLE_ID
          '',                                 -- DRAWEE_CUST_ROLE_ID
          '',                                 -- SHIP_CUST_ROLE_ID
          '',                                 -- SOLD_CUST_ROLE_ID
          '',                                 -- BILL_CUSTOMER_ID
          '',                                 -- DRAWEE_CUSTOMER_ID
          cr.pay_from_customer,               -- PAYING_CUSTOMER_ID
          '',                                 -- SOLD_CUSTOMER_ID
          '',                                 -- SHIP_CUSTOMER_ID
          '',                                 -- REMIT_ADDRESS_ID
          cr.SELECTED_REMITTANCE_BATCH_ID,    -- RECEIPT_BATCH_ID
          '',                                 -- RECEIVABLE_APPLICATION_ID
          cr.customer_bank_branch_id,         -- CUSTOMER_BANK_BRANCH_ID
          cr.issuer_bank_branch_id,           -- ISSUER_BANK_BRANCH_ID
          '',                                 -- BATCH_SOURCE_ID
          '',                                 -- BATCH_ID
          '',                                 -- TERM_ID
          'Y',                                -- SELECT_FLAG
          'H',                                -- LEVEL_FLAG
          '',                                 -- FROM_TO_FLAG
--{BUG5332302
          '',                         --  CRH_STATUS
          ''                         --  CRH_PRV_STATUS
--}
         --{BUG#4356088
         ,gt.event_type_code
         ,gt.event_class_code
         ,gt.entity_code
         --}
         ,DECODE(gt.event_type_code,'RECP_REVERSE','Y',
                                    'MISC_RECP_REVERSE','Y','N') --reversal_code
         ,'N'                    --MFAR_ADDITIONAL_ENTRY
       FROM xla_events_gt                     gt,
           gl_sets_of_books                  sob,
           ar_cash_receipts_all              cr
     WHERE gt.event_type_code IN (  'RECP_CREATE'          ,'RECP_UPDATE'        ,
                                    'RECP_RATE_ADJUST'     ,'RECP_REVERSE'       ,--Header level view reversal stay
                                    'MISC_RECP_CREATE'     ,'MISC_RECP_UPDATE'   ,
                                    'MISC_RECP_RATE_ADJUST','MISC_RECP_REVERSE'  )--BUG#3419926
       AND gt.application_id              = p_application_id
	   AND gt.source_id_int_1             = cr.cash_receipt_id
       AND cr.set_of_books_id             = sob.set_of_books_id;

    local_log(procedure_name => 'load_header_data_crh',
              p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.load_header_data_crh()-');
EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
    local_log(procedure_name => 'load_header_data_crh',
              p_msg_text     => 'EXCEPTION OTHERS in arp_xla_extract_main_pkg.load_header_data_crh '||
              arp_global.CRLF ||'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.load_header_data_crh'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;
END Load_header_data_crh;

--------------------------------------------------------------------------------

/*-----------------------------------------------------------------+
 | Procedure Name : Load_header_data_th                            |
 | Description    : Extract header data for Bill Receivable events |
 +-----------------------------------------------------------------+
 | History        :                                                |
 | 23-FEB-2004     Herve Yu    Created due to bug#3419926          |
 +-----------------------------------------------------------------*/
PROCEDURE Load_header_data_th(p_application_id  IN NUMBER DEFAULT 222)
IS
BEGIN
    local_log(procedure_name => 'Load_header_data_th',
              p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.Load_header_data_th()+');
     INSERT INTO AR_XLA_LINES_EXTRACT(
        EVENT_ID
       ,SOURCE_ID
       ,SOURCE_TABLE
       ,LINE_ID
       ,TAX_CODE_ID
       ,LOCATION_SEGMENT_ID
       ,BASE_CURRENCY_CODE
       ,EXCHANGE_RATE_TYPE
       ,EXCHANGE_RATE
       ,EXCHANGE_DATE
       ,ACCTD_AMOUNT
       ,TAXABLE_ACCTD_AMOUNT
       ,ORG_ID
       ,HEADER_TABLE_ID
       ,POSTING_ENTITY
       ,CASH_RECEIPT_ID
       ,CUSTOMER_TRX_ID
       ,CUSTOMER_TRX_LINE_ID
       ,CUST_TRX_LINE_GL_DIST_ID
       ,CUST_TRX_LINE_SALESREP_ID
       ,INVENTORY_ITEM_ID
       ,SALES_TAX_ID
       ,SO_ORGANIZATION_ID
       ,TAX_EXEMPTION_ID
       ,UOM_CODE
       ,WAREHOUSE_ID
       ,AGREEMENT_ID
       ,CUSTOMER_BANK_ACCT_ID
       ,DRAWEE_BANK_ACCOUNT_ID
       ,REMITTANCE_BANK_ACCT_ID
       ,DISTRIBUTION_SET_ID
       ,PAYMENT_SCHEDULE_ID
       ,RECEIPT_METHOD_ID
       ,RECEIVABLES_TRX_ID
       ,ED_ADJ_RECEIVABLES_TRX_ID
       ,UNED_RECEIVABLES_TRX_ID
       ,SET_OF_BOOKS_ID
       ,SALESREP_ID
       ,BILL_SITE_USE_ID
       ,DRAWEE_SITE_USE_ID
       ,PAYING_SITE_USE_ID
       ,SOLD_SITE_USE_ID
       ,SHIP_SITE_USE_ID
       ,RECEIPT_CUSTOMER_SITE_USE_ID
       ,BILL_CUST_ROLE_ID
       ,DRAWEE_CUST_ROLE_ID
       ,SHIP_CUST_ROLE_ID
       ,SOLD_CUST_ROLE_ID
       ,BILL_CUSTOMER_ID
       ,DRAWEE_CUSTOMER_ID
       ,PAYING_CUSTOMER_ID
       ,SOLD_CUSTOMER_ID
       ,SHIP_CUSTOMER_ID
       ,REMIT_ADDRESS_ID
       ,RECEIPT_BATCH_ID
       ,RECEIVABLE_APPLICATION_ID
       ,CUSTOMER_BANK_BRANCH_ID
       ,ISSUER_BANK_BRANCH_ID
       ,BATCH_SOURCE_ID
       ,BATCH_ID
       ,TERM_ID
       ,SELECT_FLAG
       ,LEVEL_FLAG
       ,FROM_TO_FLAG
       ,paired_ccid
       --{BUG#4356088
       ,event_type_code
       ,event_class_code
       ,entity_code
       ,MFAR_ADDITIONAL_ENTRY
       )
       SELECT /*+LEADING(gt) USE_NL(gt,trx)*/
          gt.event_id,             --EVENT_ID
          '',                      --SOURCE_ID
          '',                      --SOURCE_TABLE
          '',                      --LINE_ID
          '',                      --TAX_CODE_ID
          '',                      --LOCATION_SEGMENT_ID
          sob.currency_code,             --   BASE_CURRENCY_CODE
          trx.exchange_rate_type,        --   EXCHANGE_RATE_TYPE
          trx.exchange_rate,             --   EXCHANGE_RATE
          trx.exchange_date,             --   EXCHANGE_DATE
          '',                      --ACCTD_AMOUNT
          '',                      --TAXABLE_ACCTD_AMOUNT
          trx.org_id,                    --   ORG_ID
          trx.customer_trx_id,     --HEADER_TABLE_ID
          'TH',                    --POSTING_ENTITY
          '',                          --   CASH_RECEIPT_ID
          trx.customer_trx_id,           --   CUSTOMER_TRX_ID
          '',                --CUSTOMER_TRX_LINE_ID
          '',                --CUST_TRX_LINE_GL_DIST_ID
          '',                --CUST_TRX_LINE_SALESREP_ID
          '',                --INVENTORY_ITEM_ID
          '',                --SALES_TAX_ID
          '',                --SO_ORGANIZATION_ID
          '',                --TAX_EXEMPTION_ID
          '',                --UOM_CODE
          '',                --WAREHOUSE_ID
          trx.agreement_id,              --   AGREEMENT_ID
          trx.customer_bank_account_id,  --   CUSTOMER_BANK_ACCT_ID
          trx.drawee_bank_account_id,    --   DRAWEE_BANK_ACCOUNT_ID
          '',                          --   DISTRIBUTION_SET_ID
          '',                          --   PAYMENT_SCHEDULE_ID
          trx.receipt_method_id,         --   RECEIPT_METHOD_ID
          trx.remit_bank_acct_use_id,--   REMITTANCE_BANK_ACCT_ID
          '',                          --   RECEIVABLES_TRX_ID
          '',                          --   ED_ADJ_RECEIVABLES_TRX_ID
          '',                          --   UNED_RECEIVABLES_TRX_ID
          trx.set_of_books_id,           --   SET_OF_BOOKS_ID
          trx.primary_salesrep_id,       --   SALESREP_ID
          trx.bill_to_site_use_id,       --   BILL_SITE_USE_ID
          trx.drawee_site_use_id,        --   DRAWEE_SITE_USE_ID
          trx.paying_site_use_id,        --   PAYING_SITE_USE_ID
          trx.sold_to_site_use_id,       --   SOLD_SITE_USE_ID
          trx.ship_to_site_use_id,       --   SHIP_SITE_USE_ID
          '',                          --   RECEIPT_CUSTOMER_SITE_USE_ID
          trx.bill_to_contact_id,        --   BILL_CUST_ROLE_ID
          trx.drawee_contact_id,         --   DRAWEE_CUST_ROLE_ID
          trx.ship_to_contact_id,        --   SHIP_CUST_ROLE_ID
          trx.sold_to_contact_id,        --   SOLD_CUST_ROLE_ID
          trx.bill_to_customer_id,       --   BILL_CUSTOMER_ID
          trx.drawee_id,                 --   DRAWEE_CUSTOMER_ID
          trx.paying_customer_id,        --   PAYING_CUSTOMER_ID
          trx.sold_to_customer_id,       --   SOLD_CUSTOMER_ID
          trx.ship_to_customer_id,       --   SHIP_CUSTOMER_ID
          trx.remit_to_address_id,       --   REMIT_ADDRESS_ID
          '',                          --   RECEIPT_BATCH_ID
          '',                          --   RECEIVABLE_APPLICATION_ID
          '',                          --   CUSTOMER_BANK_BRANCH_ID
          '',                          --   ISSUER_BANK_BRANCH_ID
          trx.batch_source_id,           --   BATCH_SOURCE_ID
          trx.batch_id,                  --   BATCH_ID
          trx.term_id,                   --   TERM_ID
          'Y',                           --   SELECT_FLAG
          'H',                           --   LEVEL_FLAG
          '',                            --   FROM_TO_FLAG
          ''                            --BUG#5204032 ard.code_combination_id      -- paired_ccid
         --{BUG#4356088
         ,gt.event_type_code
         ,gt.event_class_code
         ,gt.entity_code
         ,'N'                    --MFAR_ADDITIONAL_ENTRY
         --}
      FROM xla_events_gt                     gt,
           ra_customer_trx_all               trx,
           gl_sets_of_books                  sob
     WHERE gt.event_type_code             IN ('BILL_CREATE' ,'BILL_UPDATE' ,'BILL_REVERSE')
       AND gt.application_id              = p_application_id
       AND gt.source_id_int_1             = trx.customer_trx_id
       AND trx.set_of_books_id            = sob.set_of_books_id;

   --  Load_header_data_th_h;
   local_log(procedure_name => 'Load_header_data_th',
             p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.Load_header_data_th()-');
EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'Load_header_data_th',
             p_msg_text     => 'EXCEPTION OTHERS in arp_xla_extract_main_pkg.load_header_data_th'||
             arp_global.CRLF ||'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.load_header_data_th'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;
END Load_header_data_th;


-----------------------------------
-- Line data loading procedures  --
-----------------------------------

/*-----------------------------------------------------------------+
 | Procedure Name : load_line_data_ctlgd                           |
 | Description    : Extract line data for transaction events       |
 +-----------------------------------------------------------------+
 | History        :                                                |
 | 23-FEB-2004     Herve Yu    Created due to bug#3419926          |
 +-----------------------------------------------------------------*/
PROCEDURE load_line_data_ctlgd(p_application_id  IN NUMBER DEFAULT 222)
IS
BEGIN
   local_log(procedure_name => 'load_line_data_ctlgd',
             p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.load_line_data_ctlgd()+');
      -- Insert line level data in Line GT with
      -- level_flag    = L

      INSERT INTO ar_xla_lines_extract (
        EVENT_ID
       ,LINE_NUMBER
       ,LANGUAGE
       ,LEDGER_ID
       ,SOURCE_ID
       ,SOURCE_TABLE
       ,LINE_ID
       ,TAX_CODE_ID
       ,LOCATION_SEGMENT_ID
       ,BASE_CURRENCY_CODE
       ,EXCHANGE_RATE_TYPE
       ,EXCHANGE_RATE
       ,EXCHANGE_DATE
       ,ACCTD_AMOUNT
       ,TAXABLE_ACCTD_AMOUNT
       ,ORG_ID
       ,HEADER_TABLE_ID
       ,POSTING_ENTITY
       ,CASH_RECEIPT_ID
       ,CUSTOMER_TRX_ID
       ,CUSTOMER_TRX_LINE_ID
       ,CUST_TRX_LINE_GL_DIST_ID
       ,CUST_TRX_LINE_SALESREP_ID
       ,INVENTORY_ITEM_ID
       ,SALES_TAX_ID
       ,SO_ORGANIZATION_ID
       ,TAX_EXEMPTION_ID
       ,UOM_CODE
       ,WAREHOUSE_ID
       ,AGREEMENT_ID
       ,CUSTOMER_BANK_ACCT_ID
       ,DRAWEE_BANK_ACCOUNT_ID
       ,REMITTANCE_BANK_ACCT_ID
       ,DISTRIBUTION_SET_ID
       ,PAYMENT_SCHEDULE_ID
       ,RECEIPT_METHOD_ID
       ,RECEIVABLES_TRX_ID
       ,ED_ADJ_RECEIVABLES_TRX_ID
       ,UNED_RECEIVABLES_TRX_ID
       ,SET_OF_BOOKS_ID
       ,SALESREP_ID
       ,BILL_SITE_USE_ID
       ,DRAWEE_SITE_USE_ID
       ,PAYING_SITE_USE_ID
       ,SOLD_SITE_USE_ID
       ,SHIP_SITE_USE_ID
       ,RECEIPT_CUSTOMER_SITE_USE_ID
       ,BILL_CUST_ROLE_ID
       ,DRAWEE_CUST_ROLE_ID
       ,SHIP_CUST_ROLE_ID
       ,SOLD_CUST_ROLE_ID
       ,BILL_CUSTOMER_ID
       ,DRAWEE_CUSTOMER_ID
       ,PAYING_CUSTOMER_ID
       ,SOLD_CUSTOMER_ID
       ,SHIP_CUSTOMER_ID
       ,REMIT_ADDRESS_ID
       ,RECEIPT_BATCH_ID
       ,RECEIVABLE_APPLICATION_ID
       ,CUSTOMER_BANK_BRANCH_ID
       ,ISSUER_BANK_BRANCH_ID
       ,BATCH_SOURCE_ID
       ,BATCH_ID
       ,TERM_ID
       ,SELECT_FLAG
       ,LEVEL_FLAG
       ,FROM_TO_FLAG
       ,PAIRED_CCID
       ,PAIRE_DIST_ID
       --{BUG#4356088
       ,event_type_code
       ,event_class_code
       ,entity_code
       --BUG#4645389
       ,tax_line_id
       --}
         ,MFAR_ADDITIONAL_ENTRY
       )
       SELECT /*+LEADING(gt) USE_NL(gt,gld)*/
           gt.event_id,                   -- EVENT_ID
           -1 * gld.cust_trx_line_gl_dist_id,    --LINE_NUMBER
                                                 -- As in the case application are extracted along with the
                                                 -- transaction distributions the line number should be
                                                 -- unique without a event. For lines extracted from application
                                                 -- the line number is set by using the ard.line_id
                                                 -- and transaction by using the ctlgd.cust_trx_line_gl_dist_id
                                                 -- to avoid the same id to be extracted with in the same event
                                                 -- ids coming from ctlgd will be negative
           '',                              --LANGUAGE
           sob.set_of_books_id,             --LEDGER_ID
           '',                               -- SOURCE_ID
           '',                               -- SOURCE_TABLE
           '',                               -- LINE_ID
           li.vat_tax_id,                    -- TAX_CODE_ID
           li.location_segment_id,           -- LOCATION_SEGMENT_ID
           sob.currency_code,                -- BASE_CURRENCY
           hd.exchange_rate_type,            -- EXCHANGE_RATE_TYPE
           hd.exchange_rate,                 -- EXCHANGE_RATE
           hd.exchange_date,                 -- EXCHANGE_DATE
           gld.acctd_amount,                 -- ACCTD_AMOUNT
           '',                               -- TAXABLE_ACCTD_AMOUNT
           gld.org_id,                       -- ORG_ID
           gld.customer_trx_id,              -- HEADER_ID
           'CTLGD',                          -- POSTING_ENTITY
           '',                               -- CASH_RECEIPT_ID
           hd.customer_trx_id,               -- CUSTOMER_TRX_ID
           li.customer_trx_line_id,          -- CUSTOMER_TRX_LINE_ID
           gld.cust_trx_line_gl_dist_id,     -- CUST_TRX_LINE_GL_DIST_ID
           gld.cust_trx_line_salesrep_id,    -- CUST_TRX_LINE_SALESREP_ID
           li.inventory_item_id,             -- INVENTORY_ITEM_ID
           li.sales_tax_id,                  -- SALES_TAX_ID
           osp.master_organization_id,       -- SO_ORGANIZATION_ID
           li.tax_exemption_id,              -- TAX_EXEMPTION_ID
           li.uom_code,                      -- UOM_CODE
           li.warehouse_id,                  -- WAREHOUSE_ID
           '',                               -- AGREEMENT_ID
           '',                               -- CUSTOMER_BANK_ACCT_ID
           '',                               -- DRAWEE_BANK_ACCOUNT_ID
           '',                               -- REMITTANCE_BANK_ACCT_ID
           '',                               -- DISTRIBUTION_SET_ID
           '',                               -- PAYMENT_SCHEDULE_ID
           '',                               -- RECEIPT_METHOD_ID
           '',                               -- RECEIVABLES_TRX_ID
           '',                               -- ED_ADJ_RECEIVABLES_TRX_ID
           '',                               -- UNED_RECEIVABLES_TRX_ID
           '',                               -- SET_OF_BOOKS_ID
           '',                               -- SALESREP_ID
           '',                               -- BILL_SITE_USE_ID
           '',                               -- DRAWEE_SITE_USE_ID
           '',                               -- PAYING_SITE_USE_ID
           '',                               -- SOLD_SITE_USE_ID
           '',                               -- SHIP_SITE_USE_ID
           '',                               -- RECEIPT_CUSTOMER_SITE_USE_ID
           '',                               -- BILL_CUST_ROLE_ID
           '',                               -- DRAWEE_CUST_ROLE_ID
           '',                               -- SHIP_CUST_ROLE_ID
           '',                               -- SOLD_CUST_ROLE_ID
           '',                               -- BILL_CUSTOMER_ID
           '',                               -- DRAWEE_CUSTOMER_ID
           '',                               -- PAYING_CUSTOMER_ID
           '',                               -- SOLD_CUSTOMER_ID
           '',                               -- SHIP_CUSTOMER_ID
           '',                               -- REMIT_ADDRESS_ID
           '',                               -- RECEIPT_BATCH_ID
           '',                               -- RECEIVABLE_APPLICATION_ID
           '',                               -- CUSTOMER_BANK_BRANCH_ID
           '',                               -- ISSUER_BANK_BRANCH_ID
           '',                               -- BATCH_SOURCE_ID
           '',                               -- BATCH_ID
           '',                               -- TERM_ID
           'N',                              -- SELECT_FLAG -- This flag set to Y is probably ok
                                                            -- but as it is only used for
                                                            -- single document with application
                                                            -- driving by ctlgd, no shared views
                                                            -- should access to it
                                                            -- if we set this flag to Y still
                                                            -- it should not be a problem as the
                                                            -- line number will filter it out for
                                                            -- to be a source for a specific line
           'L',                              -- LEVEL_FLAG
           '' ,                              -- FROM_TO_FLAG
           NULL,       -- PAIRED_CCID
           NULL        -- PAIRE_DIST_ID
         --{BUG#4356088
         ,gt.event_type_code
         ,gt.event_class_code
         ,gt.entity_code
         --BUG#4645389
         ,li.tax_line_id       --tax_line_id
         ,'N'                    --MFAR_ADDITIONAL_ENTRY
         --}
      FROM xla_events_gt                      gt,
           ra_cust_trx_line_gl_dist_all       gld,
           ra_customer_trx_lines_all          li,
           ra_customer_trx_all                hd,
           gl_sets_of_books                   sob,
           oe_system_parameters_all           osp
     WHERE gt.event_type_code IN ('INV_CREATE'     , 'INV_UPDATE'     ,
                                     'CM_CREATE'      , 'CM_UPDATE'      ,
                                     'DM_CREATE'      , 'DM_UPDATE'      ,
                                     'DEP_CREATE'     , 'DEP_UPDATE' ,
                                     'GUAR_CREATE'    , 'GUAR_UPDATE'    ,
                                     'CB_CREATE'      ) --BUG#3419926
       AND gt.application_id        = p_application_id
       AND gld.event_id             = gt.event_id
       AND hd.customer_trx_id       = gt.source_id_int_1        --BUG#5517976
	   AND gld.customer_trx_line_id = li.customer_trx_line_id(+)
       AND gld.customer_trx_id      = hd.customer_trx_id
       AND gld.set_of_books_id      = sob.set_of_books_id
       AND gld.org_id               = osp.org_id(+)
       AND gld.account_set_flag     = 'N';
   local_log(procedure_name => 'load_line_data_ctlgd',
             p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.load_line_data_ctlgd()-');
EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'load_line_data_ctlgd',
             p_msg_text     => 'EXCEPTION OTHERS in arp_xla_extract_main_pkg.load_line_data_ctlgd '||
                               arp_global.CRLF ||'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.load_line_data_ctlgd'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;
END load_line_data_ctlgd;

---------------------------------------------------------------------

/*-----------------------------------------------------------------+
 | Procedure Name : load_line_data_adj                             |
 | Description    : Extract line data for adjustment events        |
 +-----------------------------------------------------------------+
 | History        :                                                |
 | 23-FEB-2004     Herve Yu    Created due to bug#3419926          |
 +-----------------------------------------------------------------*/
PROCEDURE load_line_data_adj(p_application_id  IN NUMBER DEFAULT 222)
IS
BEGIN
   local_log(procedure_name => 'load_line_data_adj',
             p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.load_line_data_adj()+');

      -- Insert line level data in Line GT with
      -- selected_flag = N
      -- level_flag    = L
      INSERT INTO ar_xla_lines_extract (
        EVENT_ID
       ,LINE_NUMBER
       ,LANGUAGE
       ,LEDGER_ID
       ,SOURCE_ID
       ,SOURCE_TABLE
       ,LINE_ID
       ,TAX_CODE_ID
       ,LOCATION_SEGMENT_ID
       ,BASE_CURRENCY_CODE
       ,EXCHANGE_RATE_TYPE
       ,EXCHANGE_RATE
       ,EXCHANGE_DATE
       ,ACCTD_AMOUNT
       ,TAXABLE_ACCTD_AMOUNT
       ,ORG_ID
       ,HEADER_TABLE_ID
       ,POSTING_ENTITY
       ,CASH_RECEIPT_ID
       ,CUSTOMER_TRX_ID
       ,CUSTOMER_TRX_LINE_ID
       ,CUST_TRX_LINE_GL_DIST_ID
       ,CUST_TRX_LINE_SALESREP_ID
       ,INVENTORY_ITEM_ID
       ,SALES_TAX_ID
       ,SO_ORGANIZATION_ID
       ,TAX_EXEMPTION_ID
       ,UOM_CODE
       ,WAREHOUSE_ID
       ,AGREEMENT_ID
       ,CUSTOMER_BANK_ACCT_ID
       ,DRAWEE_BANK_ACCOUNT_ID
       ,REMITTANCE_BANK_ACCT_ID
       ,DISTRIBUTION_SET_ID
       ,PAYMENT_SCHEDULE_ID
       ,RECEIPT_METHOD_ID
       ,RECEIVABLES_TRX_ID
       ,ED_ADJ_RECEIVABLES_TRX_ID
       ,UNED_RECEIVABLES_TRX_ID
       ,SET_OF_BOOKS_ID
       ,SALESREP_ID
       ,BILL_SITE_USE_ID
       ,DRAWEE_SITE_USE_ID
       ,PAYING_SITE_USE_ID
       ,SOLD_SITE_USE_ID
       ,SHIP_SITE_USE_ID
       ,RECEIPT_CUSTOMER_SITE_USE_ID
       ,BILL_CUST_ROLE_ID
       ,DRAWEE_CUST_ROLE_ID
       ,SHIP_CUST_ROLE_ID
       ,SOLD_CUST_ROLE_ID
       ,BILL_CUSTOMER_ID
       ,DRAWEE_CUSTOMER_ID
       ,PAYING_CUSTOMER_ID
       ,SOLD_CUSTOMER_ID
       ,SHIP_CUSTOMER_ID
       ,REMIT_ADDRESS_ID
       ,RECEIPT_BATCH_ID
       ,RECEIVABLE_APPLICATION_ID
       ,CUSTOMER_BANK_BRANCH_ID
       ,ISSUER_BANK_BRANCH_ID
       ,BATCH_SOURCE_ID
       ,BATCH_ID
       ,TERM_ID
       ,SELECT_FLAG
       ,LEVEL_FLAG
       ,FROM_TO_FLAG
       ,AMOUNT
       ,PAIRED_CCID
       --{BUG#4356088
       ,event_type_code
       ,event_class_code
       ,entity_code
       --BUG#4645389
       ,tax_line_id
         ,MFAR_ADDITIONAL_ENTRY
       --}
       )
        SELECT /*+LEADING(gt) USE_NL(gt,adj)*/
           gt.event_id,                      -- EVENT_ID
           dist.line_id,                     -- LINE_NUMBER
           '',                               -- LANGUAGE
           sob.set_of_books_id,              -- LEDGER_ID
           dist.source_id,                   -- SOURCE_ID
           dist.source_table,                -- SOURCE_TABLE
           dist.line_id,                     -- LINE_ID
           dist.tax_code_id,                 -- TAX_CODE_ID
           dist.location_segment_id,         -- LOCATION_SEGMENT_ID
           sob.currency_code,                -- BASE_CURRENCY
           trxt.exchange_rate_type,          -- EXCHANGE_RATE_TYPE
           trxt.exchange_rate,               -- EXCHANGE_RATE
           trxt.exchange_date,               -- EXCHANGE_DATE
           NVL(dist.acctd_amount_cr,0)-
                NVL(dist.acctd_amount_dr,0), -- ACCTD_AMOUNT
           NVL(dist.taxable_accounted_cr,0) -
                NVL(dist.taxable_accounted_dr,0), -- TAXABLE_ACCTD_AMOUNT
           adj.org_id,                       -- ORG_ID
           adj.adjustment_id,                -- HEADER_ID
           'ADJ',                            -- POSTING_ENTITY
           adj.associated_cash_receipt_id,   -- CASH_RECEIPT_ID
           adj.customer_trx_id,              -- CUSTOMER_TRX_ID
           tlt.customer_trx_line_id,         -- CUSTOMER_TRX_LINE_ID
           gldt.cust_trx_line_gl_dist_id,    -- CUST_TRX_LINE_GL_DIST_ID
           gldt.cust_trx_line_salesrep_id,   -- CUST_TRX_LINE_SALESREP_ID
           tlt.inventory_item_id,            -- INVENTORY_ITEM_ID
           tlt.sales_tax_id,                 -- SALES_TAX_ID
           osp.master_organization_id,       -- SO_ORGANIZATION_ID
           tlt.tax_exemption_id,             -- TAX_EXEMPTION_ID
           tlt.uom_code,                     -- UOM_CODE
           tlt.warehouse_id,                 -- WAREHOUSE_ID
           trxt.agreement_id ,               -- AGREEMENT_ID
           '',                               -- CUSTOMER_BANK_ACCT_ID
           '',                               -- DRAWEE_BANK_ACCOUNT_ID
           '',                               -- REMITTANCE_BANK_ACCT_ID
           '',                               -- DISTRIBUTION_SET_ID
           '',                               -- PAYMENT_SCHEDULE_ID
           '',                               -- RECEIPT_METHOD_ID
           '',                               -- RECEIVABLES_TRX_ID
           '',                               -- ED_ADJ_RECEIVABLES_TRX_ID
           '',                               -- UNED_RECEIVABLES_TRX_ID
           '',                               -- SET_OF_BOOKS_ID
           '',                               -- SALESREP_ID
           '',                               -- BILL_SITE_USE_ID
           '',                               -- DRAWEE_SITE_USE_ID
           '',                               -- PAYING_SITE_USE_ID
           '',                               -- SOLD_SITE_USE_ID
           '',                               -- SHIP_SITE_USE_ID
           '',                               -- RECEIPT_CUSTOMER_SITE_USE_ID
           '',                               -- BILL_CUST_ROLE_ID
           '',                               -- DRAWEE_CUST_ROLE_ID
           '',                               -- SHIP_CUST_ROLE_ID
           '',                               -- SOLD_CUST_ROLE_ID
           '',                               -- BILL_CUSTOMER_ID
           '',                               -- DRAWEE_CUSTOMER_ID
           '',                               -- PAYING_CUSTOMER_ID
           '',                               -- SOLD_CUSTOMER_ID
           '',                               -- SHIP_CUSTOMER_ID
           '',                               -- REMIT_ADDRESS_ID
           '',                               -- RECEIPT_BATCH_ID
           '',                               -- RECEIVABLE_APPLICATION_ID
           '',                               -- CUSTOMER_BANK_BRANCH_ID
           '',                               -- ISSUER_BANK_BRANCH_ID
           '',                               -- BATCH_SOURCE_ID
           '',                               -- BATCH_ID
           '',                               -- TERM_ID
           'N',                              -- SELECT_FLAG
           'L',                              -- LEVEL_FLAG
           '',                               -- FROM_TO_FLAG
           NVL(dist.amount_cr,0)
             -NVL(dist.amount_dr,0),         -- AMOUNT
           NULL       -- PAIRED_CCID
         --{BUG#4356088
         ,gt.event_type_code
         ,gt.event_class_code
         ,gt.entity_code
         --BUG#4645389
         ,tlt.tax_line_id       --tax_line_id
         ,'N'                    --MFAR_ADDITIONAL_ENTRY
         --}
      FROM xla_events_gt                  gt,
           ar_distributions_all           dist,
           ar_adjustments_all             adj,
           gl_sets_of_books               sob,
           ra_customer_trx_all            trxt,
           ra_customer_trx_lines_all      tlt,
           ra_cust_trx_line_gl_dist_all   gldt,
           oe_system_parameters_all       osp
     WHERE gt.event_type_code             = 'ADJ_CREATE'
       AND gt.application_id              = p_application_id
	   AND adj.event_id                   = gt.event_id
       AND adj.customer_trx_id            = trxt.customer_trx_id
       AND dist.source_table              = 'ADJ'
       AND dist.source_id                 = adj.adjustment_id
--{Pass adj distribution for the REC
--       AND dist.source_type              <> 'REC'
--}
-- Need to add PSA upgrade impact
       AND DECODE(adj.upgrade_method,
                    '11IMFAR',DECODE(dist.source_table_secondary,'UPMFAJMIAR','Y','N'),
                    'Y')                  = 'Y'
       AND dist.ref_customer_trx_line_id  = tlt.customer_trx_line_id(+)
       AND dist.ref_cust_trx_line_gl_dist_id = gldt.cust_trx_line_gl_dist_id(+)
       AND adj.set_of_books_id            = sob.set_of_books_id
       AND adj.org_id                     = osp.org_id(+);
   local_log(procedure_name => 'load_line_data_adj',
             p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.load_line_data_adj()-');
EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'load_line_data_adj',
             p_msg_text     => 'EXCEPTION OTHERS in arp_xla_extract_main_pkg.load_line_data_adj '||
                               arp_global.CRLF ||'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.load_line_data_adj'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;
END load_line_data_adj;

--------------------------------------------------------


/*-----------------------------------------------------------------+
 | Procedure Name : load_line_data_app_to_trx                      |
 | Description    : Extract the to application line attached to    |
 |                  the applied to transaction event               |
 +-----------------------------------------------------------------+
 | History        :                                                |
 | 23-FEB-2004     Herve Yu    Created due to bug#3419926          |
 +-----------------------------------------------------------------*/
PROCEDURE load_line_data_app_to_trx(p_application_id  IN NUMBER DEFAULT 222)
IS
BEGIN
   local_log(procedure_name => 'load_line_data_app_to_trx',
             p_msg_text     => 'arp_xla_extract_main_pkg.load_line_data_app_to_trx ()+');
    -- Insert line level data in Line GT with
    -- selected_flag = Y
    -- level_flag    = L
    -- from_to_flag  = T
    INSERT INTO ar_xla_lines_extract (
        EVENT_ID
       ,LINE_NUMBER
       ,LANGUAGE
       ,LEDGER_ID
       ,SOURCE_ID
       ,SOURCE_TABLE
       ,LINE_ID
       ,TAX_CODE_ID
       ,LOCATION_SEGMENT_ID
       ,BASE_CURRENCY_CODE
       ,EXCHANGE_RATE_TYPE
       ,EXCHANGE_RATE
       ,EXCHANGE_DATE
       ,ACCTD_AMOUNT
       ,TAXABLE_ACCTD_AMOUNT
       ,ORG_ID
       ,HEADER_TABLE_ID
       ,POSTING_ENTITY
       ,CASH_RECEIPT_ID
       ,CUSTOMER_TRX_ID
       ,CUSTOMER_TRX_LINE_ID
       ,CUST_TRX_LINE_GL_DIST_ID
       ,CUST_TRX_LINE_SALESREP_ID
       ,INVENTORY_ITEM_ID
       ,SALES_TAX_ID
       ,SO_ORGANIZATION_ID
       ,TAX_EXEMPTION_ID
       ,UOM_CODE
       ,WAREHOUSE_ID
       ,AGREEMENT_ID
       ,CUSTOMER_BANK_ACCT_ID
       ,DRAWEE_BANK_ACCOUNT_ID
       ,REMITTANCE_BANK_ACCT_ID
       ,DISTRIBUTION_SET_ID
       ,PAYMENT_SCHEDULE_ID
       ,RECEIPT_METHOD_ID
       ,RECEIVABLES_TRX_ID
       ,ED_ADJ_RECEIVABLES_TRX_ID
       ,UNED_RECEIVABLES_TRX_ID
       ,SET_OF_BOOKS_ID
       ,SALESREP_ID
       ,BILL_SITE_USE_ID
       ,DRAWEE_SITE_USE_ID
       ,PAYING_SITE_USE_ID
       ,SOLD_SITE_USE_ID
       ,SHIP_SITE_USE_ID
       ,RECEIPT_CUSTOMER_SITE_USE_ID
       ,BILL_CUST_ROLE_ID
       ,DRAWEE_CUST_ROLE_ID
       ,SHIP_CUST_ROLE_ID
       ,SOLD_CUST_ROLE_ID
       ,BILL_CUSTOMER_ID
       ,DRAWEE_CUSTOMER_ID
       ,PAYING_CUSTOMER_ID
       ,SOLD_CUSTOMER_ID
       ,SHIP_CUSTOMER_ID
       ,REMIT_ADDRESS_ID
       ,RECEIPT_BATCH_ID
       ,RECEIVABLE_APPLICATION_ID
       ,CUSTOMER_BANK_BRANCH_ID
       ,ISSUER_BANK_BRANCH_ID
       ,BATCH_SOURCE_ID
       ,BATCH_ID
       ,TERM_ID
       ,SELECT_FLAG
       ,LEVEL_FLAG
       ,FROM_TO_FLAG
       ,FROM_AMOUNT
       ,AMOUNT
       ,FROM_ACCTD_AMOUNT
       --{BUG#4356088
       ,event_type_code
       ,event_class_code
       ,entity_code
       --BUG#4645389
       ,tax_line_id
       --BUG#5366837
       ,additional_char1
         ,MFAR_ADDITIONAL_ENTRY
         ,SOURCE_TYPE
         ,CM_APP_TO_TRX_LINE_ID
       )
        SELECT /*+LEADING(gt) USE_NL(gt, app)*/
           gt.event_id,                      -- EVENT_ID
           dist.line_id,                     -- LINE_NUMBER
           '',                               -- LANGUAGE
           sob.set_of_books_id,              -- LEDGER_ID
           dist.source_id,                   -- SOURCE_ID
           dist.source_table,                -- SOURCE_TABLE
           dist.line_id,                     -- LINE_ID
           dist.tax_code_id,                 -- TAX_CODE_ID
           dist.location_segment_id,         -- LOCATION_SEGMENT_ID
           sob.currency_code,                -- BASE_CURRENCY
           trxt.exchange_rate_type,          -- EXCHANGE_RATE_TYPE
           trxt.exchange_rate,               -- EXCHANGE_RATE
           -- bug 7535858 Default Exch Date as Trx Date for Base Currency Line for ALC Calculation
           decode(trxt.invoice_currency_code,sob.currency_code,
                    trxt.trx_date, trxt.exchange_date),         -- EXCHANGE_DATE
           -- trxt.exchange_date,               -- EXCHANGE_DATE
           NVL(dist.acctd_amount_cr,0) -
                NVL(dist.acctd_amount_dr,0),      -- ACCTD_AMOUNT
           NVL(dist.taxable_accounted_cr,0) -
                NVL(dist.taxable_accounted_dr,0), -- TAXABLE_ACCTD_AMOUNT
           app.org_id,                       -- ORG_ID
           app.receivable_application_id,    -- HEADER_TABLE_ID
           'APP',                            -- POSTING_ENTITY
           NULL,                             -- CASH_RECEIPT_ID
           trxt.customer_trx_id,             -- CUSTOMER_TRX_ID
           tlt.customer_trx_line_id,         -- CUSTOMER_TRX_LINE_ID
           gldt.cust_trx_line_gl_dist_id,    -- CUST_TRX_LINE_GL_DIST_ID
           gldt.cust_trx_line_salesrep_id,   --  CUST_TRX_LINE_SALESREP_ID
           tlt.inventory_item_id,            -- INVENTORY_ITEM_ID
           tlt.sales_tax_id,                 -- SALES_TAX_ID
           osp.master_organization_id,       -- SO_ORGANIZATION_ID
           tlt.tax_exemption_id,             -- TAX_EXEMPTION_ID
           tlt.uom_code,                     -- UOM_CODE
           tlt.warehouse_id,                 -- WAREHOUSE_ID
           trxt.agreement_id,                -- AGREEMENT_ID
           trxt.customer_bank_account_id,    -- CUSTOMER_BANK_ACCT_ID
           trxt.drawee_bank_account_id,      -- DRAWEE_BANK_ACCOUNT_ID
           trxt.remit_bank_acct_use_id,  -- REMITTANCE_BANK_ACCT_ID
           NULL,                             -- DISTRIBUTION_SET_ID
           psch.payment_schedule_id,         -- PAYMENT_SCHEDULE_ID
           trxt.receipt_method_id,           -- RECEIPT_METHOD_ID
           NULL,                             -- RECEIVABLES_TRX_ID
           arp_xla_extract_main_pkg.ed_uned_trx('EDISC',app.org_id),       -- ED_ADJ_RECEIVABLES_TRX_ID
           arp_xla_extract_main_pkg.ed_uned_trx('UNEDISC',app.org_id),     -- UNED_RECEIVABLES_TRX_ID
           trxt.set_of_books_id,             -- SET_OF_BOOKS_ID
           trxt.primary_salesrep_id,         -- SALESREP_ID
           trxt.bill_to_site_use_id,         -- BILL_SITE_USE_ID
           trxt.drawee_site_use_id,          -- DRAWEE_SITE_USE_ID
           trxt.paying_site_use_id,          -- PAYING_SITE_USE_ID
           trxt.sold_to_site_use_id,         -- SOLD_SITE_USE_ID
           trxt.ship_to_site_use_id,         -- SHIP_SITE_USE_ID
           NULL,                             -- RECEIPT_CUSTOMER_SITE_USE_ID
           trxt.bill_to_contact_id,          -- BILL_CUST_ROLE_ID
           trxt.drawee_contact_id,           -- DRAWEE_CUST_ROLE_ID
           trxt.ship_to_contact_id,          -- SHIP_CUST_ROLE_ID
           trxt.sold_to_contact_id,          -- SOLD_CUST_ROLE_ID
           trxt.bill_to_customer_id,         -- BILL_CUSTOMER_ID
           trxt.drawee_id,                   -- DRAWEE_CUSTOMER_ID
           trxt.paying_customer_id,          -- PAYING_CUSTOMER_ID
           trxt.sold_to_customer_id,         -- SOLD_CUSTOMER_ID
           trxt.ship_to_customer_id,         -- SHIP_CUSTOMER_ID
           trxt.remit_to_address_id,         -- REMIT_ADDRESS_ID
           NULL,                             -- RECEIPT_BATCH_ID
           NULL,                             -- RECEIVABLE_APPLICATION_ID
           NULL,                             -- CUSTOMER_BANK_BRANCH_ID
           NULL,                             -- ISSUER_BANK_BRANCH_ID
           trxt.batch_source_id,             -- BATCH_SOURCE_ID
           trxt.batch_id,                    -- BATCH_ID
           trxt.term_id,                     -- TERM_ID
           'Y',                              -- SELECT_FLAG
           'L',                              -- LEVEL_FLAG
           'T',                              -- FROM_TO_FLAG
--           NVL(dist.from_amount_cr,0)
--             -NVL(dist.from_amount_dr,0),    -- FROM_AMOUNT,
        CASE WHEN (app.upgrade_method IS NULL  AND app.status ='APP') THEN
           CASE WHEN (dist.from_amount_dr IS NOT NULL OR dist.from_amount_cr IS NOT NULL) THEN
              NVL(dist.from_amount_cr,0)-NVL(dist.from_amount_dr,0)
           ELSE
             CASE WHEN (dist.source_type NOT IN ('REC','EDISC','UNEDISC')) THEN
                NULL
             ELSE
               CASE WHEN (app.earned_discount_taken IS NOT NULL AND
                    app.earned_discount_taken = NVL(dist.amount_dr,0)-NVL(dist.amount_cr,0) AND
                    app.acctd_earned_discount_taken = NVL(dist.acctd_amount_dr,0)-NVL(dist.acctd_amount_cr,0)
                    AND dist.source_type = 'REC') THEN
                   NULL
               ELSE
                 CASE WHEN (trxt.invoice_currency_code = cr.currency_code) THEN
                    NVL(dist.amount_cr,0)-NVL(dist.amount_dr,0)
                 ELSE
                   CASE WHEN (app.amount_applied <> 0 AND app.amount_applied_from <> 0) THEN
                     NVL(app.amount_applied_from / app.amount_applied * dist.amount_cr,0)-
                     NVL(app.amount_applied_from / app.amount_applied * dist.amount_dr,0)
                    ELSE  NULL END
                 END
               END
             END
           END
        ELSE
           NVL(dist.from_amount_cr,0)
             -NVL(dist.from_amount_dr,0)
        END,                     -- FROM_AMOUNT
           NVL(dist.amount_cr,0) - NVL(dist.amount_dr,0),          -- AMOUNT
--           NVL(dist.from_acctd_amount_cr,0)
--             -NVL(dist.from_acctd_amount_dr,0) -- FROM_ACCTD_AMOUNT
        CASE WHEN (app.upgrade_method IS NULL AND app.status ='APP') THEN
           CASE WHEN (dist.from_acctd_amount_dr IS NOT NULL OR dist.from_acctd_amount_cr IS NOT NULL) THEN
              NVL(dist.from_acctd_amount_cr,0)-NVL(dist.from_acctd_amount_dr,0)
           ELSE
             CASE WHEN (dist.source_type NOT IN ('REC','EDISC','UNEDISC')) THEN
                NULL
             ELSE
               CASE WHEN (app.earned_discount_taken IS NOT NULL AND
                    app.earned_discount_taken = NVL(dist.amount_dr,0)-NVL(dist.amount_cr,0) AND
                    app.acctd_earned_discount_taken = NVL(dist.acctd_amount_dr,0)-NVL(dist.acctd_amount_cr,0)
                    AND dist.source_type = 'REC') THEN
                   NULL
               ELSE
                 CASE WHEN (trxt.invoice_currency_code = sob.currency_code AND
                            cr.currency_code          = sob.currency_code ) THEN
                    NVL(dist.acctd_amount_cr,0)-NVL(dist.acctd_amount_dr,0)
                 ELSE
                   CASE WHEN (app.acctd_amount_applied_to <> 0 AND app.acctd_amount_applied_from <> 0) THEN
                   NVL(app.acctd_amount_applied_from / app.acctd_amount_applied_to * dist.acctd_amount_cr,0)-
                   NVL(app.acctd_amount_applied_from / app.acctd_amount_applied_to * dist.acctd_amount_dr,0)
                    ELSE  NULL END
                 END
               END
             END
           END
        ELSE
           NVL(dist.from_acctd_amount_cr,0)
             -NVL(dist.from_acctd_amount_dr,0)
        END,                     -- FROM_ACCTD_AMOUNT
         --{BUG#4356088
          gt.event_type_code
         ,gt.event_class_code
         ,gt.entity_code
         --BUG#4645389
         ,tlt.tax_line_id       --tax_line_id
         --BUG5366837
         ,app.upgrade_method
         ,'N'                    --MFAR_ADDITIONAL_ENTRY
         , NULL
         , to_number(NULL)
      FROM xla_events_gt                  gt,
           ar_receivable_applications_all app,
           ar_distributions_all           dist,
           gl_sets_of_books               sob,
           oe_system_parameters_all       osp,
           ra_customer_trx_all            trxt,
           ra_customer_trx_lines_all      tlt,
           ra_cust_trx_line_gl_dist_all   gldt,
           ar_payment_schedules_all       psch,
           ar_cash_receipts_all           cr
     WHERE gt.event_type_code IN (  'RECP_CREATE'      ,'RECP_UPDATE'      ,
                                    'RECP_RATE_ADJUST' ) -- Uptake XLA reversal, 'RECP_REVERSE')
-- Exclude 'RECP_REVERSE' for no extract at line level is reuired for Reversal
       AND gt.application_id                 = p_application_id
       AND gt.event_id                       = app.event_id
       AND (app.upgrade_method              IN ('R12_NLB','R12', 'R12_11IMFAR', 'R12_11ICASH','11I_R12_POST','R12_MERGE')
            OR (app.upgrade_method IS NULL AND app.status = 'APP')  --11i Accrual
			--Need to add PSA upgrade impact
			OR (DECODE(app.upgrade_method,
                       '11I_MFAR_UPG'    ,DECODE(dist.source_table_secondary,'UPMFRAMIAR','Y','N'),
                        'N')                  = 'Y'))
       AND app.set_of_books_id               = sob.set_of_books_id
       AND app.org_id                        = osp.org_id(+)
       AND app.applied_customer_trx_id       = trxt.customer_trx_id
       --5201086
       AND app.cash_receipt_id               = cr.cash_receipt_id
       AND dist.source_id                    = app.receivable_application_id
       AND dist.source_table                 = 'RA'
       AND dist.ref_customer_trx_line_id     = tlt.customer_trx_line_id(+)
       AND dist.ref_cust_trx_line_gl_dist_id = gldt.cust_trx_line_gl_dist_id(+)
       AND trxt.customer_trx_id              = psch.customer_trx_id
       AND NVL(psch.terms_sequence_number,1) = 1
--{Pass also the UNAPP UNID ... everything
--       AND dist.source_type                  IN ('REC','EDISC','UNEDISC')
--}
--}
--       AND dist.activity_bucket                       IS NOT NULL
    UNION ALL
        SELECT /*+LEADING(gt) USE_NL(gt, app)*/
           gt.event_id,                      -- EVENT_ID
           dist.line_id,                     -- LINE_NUMBER
           '',                               -- LANGUAGE
           sob.set_of_books_id,              -- LEDGER_ID
           dist.source_id,                   -- SOURCE_ID
           dist.source_table,                -- SOURCE_TABLE
           dist.line_id,                     -- LINE_ID
           dist.tax_code_id,                 -- TAX_CODE_ID
           dist.location_segment_id,         -- LOCATION_SEGMENT_ID
           sob.currency_code,                -- BASE_CURRENCY
           trxt.exchange_rate_type,          -- EXCHANGE_RATE_TYPE
           trxt.exchange_rate,               -- EXCHANGE_RATE
           trxt.exchange_date,               -- EXCHANGE_DATE
           NVL(dist.acctd_amount_cr,0) -
                NVL(dist.acctd_amount_dr,0),      -- ACCTD_AMOUNT
           NVL(dist.taxable_accounted_cr,0) -
                NVL(dist.taxable_accounted_dr,0), -- TAXABLE_ACCTD_AMOUNT
           app.org_id,                       -- ORG_ID
           app.receivable_application_id,    -- HEADER_TABLE_ID
           'APP',                            -- POSTING_ENTITY
           NULL,                             -- CASH_RECEIPT_ID
           trxt.customer_trx_id,             -- CUSTOMER_TRX_ID
           tlt.customer_trx_line_id,         -- CUSTOMER_TRX_LINE_ID
           gldt.cust_trx_line_gl_dist_id,    -- CUST_TRX_LINE_GL_DIST_ID
           gldt.cust_trx_line_salesrep_id,   --  CUST_TRX_LINE_SALESREP_ID
           tlt.inventory_item_id,            -- INVENTORY_ITEM_ID
           tlt.sales_tax_id,                 -- SALES_TAX_ID
           osp.master_organization_id,       -- SO_ORGANIZATION_ID
           tlt.tax_exemption_id,             -- TAX_EXEMPTION_ID
           tlt.uom_code,                     -- UOM_CODE
           tlt.warehouse_id,                 -- WAREHOUSE_ID
           trxt.agreement_id,                -- AGREEMENT_ID
           trxt.customer_bank_account_id,    -- CUSTOMER_BANK_ACCT_ID
           trxt.drawee_bank_account_id,      -- DRAWEE_BANK_ACCOUNT_ID
           trxt.remit_bank_acct_use_id,  -- REMITTANCE_BANK_ACCT_ID
           NULL,                             -- DISTRIBUTION_SET_ID
           psch.payment_schedule_id,         -- PAYMENT_SCHEDULE_ID
           trxt.receipt_method_id,           -- RECEIPT_METHOD_ID
           NULL,                             -- RECEIVABLES_TRX_ID
           NULL,                             -- ED_ADJ_RECEIVABLES_TRX_ID
           NULL,                             -- UNED_RECEIVABLES_TRX_ID
           trxt.set_of_books_id,             -- SET_OF_BOOKS_ID
           trxt.primary_salesrep_id,         -- SALESREP_ID
           trxt.bill_to_site_use_id,         -- BILL_SITE_USE_ID
           trxt.drawee_site_use_id,          -- DRAWEE_SITE_USE_ID
           trxt.paying_site_use_id,          -- PAYING_SITE_USE_ID
           trxt.sold_to_site_use_id,         -- SOLD_SITE_USE_ID
           trxt.ship_to_site_use_id,         -- SHIP_SITE_USE_ID
           NULL,                             -- RECEIPT_CUSTOMER_SITE_USE_ID
           trxt.bill_to_contact_id,          -- BILL_CUST_ROLE_ID
           trxt.drawee_contact_id,           -- DRAWEE_CUST_ROLE_ID
           trxt.ship_to_contact_id,          -- SHIP_CUST_ROLE_ID
           trxt.sold_to_contact_id,          -- SOLD_CUST_ROLE_ID
           trxt.bill_to_customer_id,         -- BILL_CUSTOMER_ID
           trxt.drawee_id,                   -- DRAWEE_CUSTOMER_ID
           trxt.paying_customer_id,          -- PAYING_CUSTOMER_ID
           trxt.sold_to_customer_id,         -- SOLD_CUSTOMER_ID
           trxt.ship_to_customer_id,         -- SHIP_CUSTOMER_ID
           trxt.remit_to_address_id,         -- REMIT_ADDRESS_ID
           NULL,                             -- RECEIPT_BATCH_ID
           NULL,                             -- RECEIVABLE_APPLICATION_ID
           NULL,                             -- CUSTOMER_BANK_BRANCH_ID
           NULL,                             -- ISSUER_BANK_BRANCH_ID
           trxt.batch_source_id,             -- BATCH_SOURCE_ID
           trxt.batch_id,                    -- BATCH_ID
           trxt.term_id,                     -- TERM_ID
           'Y',                              -- SELECT_FLAG
           'L',                              -- LEVEL_FLAG
           'T',                              -- FROM_TO_FLAG
--           NVL(dist.from_amount_cr,0) -NVL(dist.from_amount_dr,0),    -- FROM_AMOUNT,
         CASE WHEN (dist.from_amount_cr IS NULL AND dist.from_amount_dr IS NULL) THEN
           NVL(dist.amount_cr,0) - NVL(dist.amount_dr,0)
         ELSE
           NVL(dist.from_amount_cr,0) - NVL(dist.from_amount_dr,0)
         END,                                                     -- FROM_AMOUNT
           NVL(dist.amount_cr,0) -NVL(dist.amount_dr,0),          -- AMOUNT
--           NVL(dist.from_acctd_amount_cr,0) -NVL(dist.from_acctd_amount_dr,0) -- FROM_ACCTD_AMOUNT
         CASE WHEN (dist.from_acctd_amount_cr IS NULL AND dist.from_acctd_amount_dr IS NULL) THEN
           NVL(dist.acctd_amount_cr,0) - NVL(dist.acctd_amount_dr,0)
         ELSE
           NVL(dist.from_acctd_amount_cr,0) - NVL(dist.from_acctd_amount_dr,0)
         END,                                                     -- FROM_ACCTD_MOUNT
         --{BUG#4356088
          gt.event_type_code
         ,gt.event_class_code
         ,gt.entity_code
         --BUG#4645389
         ,tlt.tax_line_id       --tax_line_id
         --BUG#5366837
         ,app.upgrade_method
         ,'N'                    --MFAR_ADDITIONAL_ENTRY
         , dist.source_type
         ,decode(dist.REF_PREV_CUST_TRX_LINE_ID, NULL, to_number(NULL),dist.ref_customer_trx_line_id)     -- RAM 9860123
      FROM xla_events_gt                  gt,
           ar_receivable_applications_all app,
           ar_distributions_all           dist,
           gl_sets_of_books               sob,
           oe_system_parameters_all       osp,
           ra_customer_trx_all            trxt,
           ra_customer_trx_lines_all      tlt,
           ra_cust_trx_line_gl_dist_all   gldt,
           ar_payment_schedules_all       psch
     WHERE gt.event_type_code  IN (  'CM_CREATE','CM_UPDATE' )
       AND gt.application_id                 = p_application_id
       AND gt.event_id                       = app.event_id
       AND (app.upgrade_method IN ('R12_NLB','R12', 'R12_11IMFAR', 'R12_11ICASH','11I_R12_POST','R12_MERGE')
            OR (app.upgrade_method IS NULL AND app.status = 'APP')
            OR (DECODE(app.upgrade_method,
                       '11I_MFAR_UPG'    ,DECODE(dist.source_table_secondary,'UPMFRAMIAR','Y','N'),
                        'N')                 = 'Y'))
       AND dist.source_table                 = 'RA'
       AND dist.source_id                    = app.receivable_application_id
       AND app.set_of_books_id               = sob.set_of_books_id
       AND app.org_id                        = osp.org_id(+)
       AND app.applied_customer_trx_id       = trxt.customer_trx_id
       AND dist.ref_customer_trx_line_id     = tlt.customer_trx_line_id(+)
       AND dist.ref_cust_trx_line_gl_dist_id = gldt.cust_trx_line_gl_dist_id(+)
       AND trxt.customer_trx_id              = psch.customer_trx_id
       AND NVL(psch.terms_sequence_number,1) = 1
-- {Pass every distributions REC EDISC UNEDISC UNAPP UNID
--       AND dist.source_type                  IN ('REC','EDISC','UNEDISC')
-- }
--       AND dist.activity_bucket                       IS NOT NULL
/* Bug 6119725 Begin Changes */
         AND (( dist.ref_cust_trx_line_gl_dist_id IS NOT NULL
                        AND dist.ref_cust_trx_line_gl_dist_id IN (SELECT cust_trx_line_gl_dist_id
                                                       FROM ra_cust_trx_line_gl_dist_all ctlgd
                                                       WHERE ctlgd.customer_trx_id =  app.applied_customer_trx_id)) -- Select only TO rows which belong to Invoice
          OR  ((dist.ref_cust_trx_line_gl_dist_id IS NULL
            AND ((sign((app.amount_applied+nvl(app.earned_discount_taken,0)+nvl(app.unearned_discount_taken,0))) = sign(nvl(dist.amount_cr,0) * -1+nvl(dist.amount_dr,0)) AND dist.source_type = 'DEFERRED_TAX' )
                OR (sign((app.acctd_amount_applied_to+nvl(app.acctd_earned_discount_taken,0)+nvl(app.acctd_unearned_discount_taken,0))) = sign(nvl(dist.acctd_amount_dr,0) * -1+nvl(dist.acctd_amount_cr,0)) AND dist.source_type = 'CURR_ROUND')
                OR
               ( (sign((app.amount_applied+nvl(app.earned_discount_taken,0)+nvl(app.unearned_discount_taken,0))) = sign(nvl(dist.amount_dr,0) * -1+nvl(dist.amount_cr,0)) AND dist.source_type not in ('DEFERRED_TAX', 'CURR_ROUND'))
                AND (((sign((app.amount_applied+nvl(app.earned_discount_taken,0)+nvl(app.unearned_discount_taken,0)))*-1) <> 0)
                   OR
                    ((sign((app.amount_applied+nvl(app.earned_discount_taken,0)+nvl(app.unearned_discount_taken,0)))*-1 = 0)
                        AND dist.amount_dr is not null)))))))
/* Bug 6119725 End Changes */

UNION
--HYUCMACT
       SELECT /*+LEADING(gt) USE_NL(gt, app)*/
           gt.event_id,                      -- EVENT_ID
           dist.line_id,                     -- LINE_NUMBER
           '',                               -- LANGUAGE
           sob.set_of_books_id,              -- LEDGER_ID
           dist.source_id,                   -- SOURCE_ID
           dist.source_table,                -- SOURCE_TABLE
           dist.line_id,                     -- LINE_ID
           dist.tax_code_id,                 -- TAX_CODE_ID
           dist.location_segment_id,         -- LOCATION_SEGMENT_ID
           sob.currency_code,                -- BASE_CURRENCY
           trx.EXCHANGE_RATE_TYPE,               -- EXCHANGE_RATE_TYPE
           trx.EXCHANGE_RATE,               -- EXCHANGE_RATE
           trx.EXCHANGE_DATE,               -- EXCHANGE_DATE
           NVL(dist.acctd_amount_cr,0) -
                NVL(dist.acctd_amount_dr,0),      -- ACCTD_AMOUNT
           NVL(dist.taxable_accounted_cr,0) -
                NVL(dist.taxable_accounted_dr,0), -- TAXABLE_ACCTD_AMOUNT
           app.org_id,                       -- ORG_ID
           app.receivable_application_id,    -- HEADER_TABLE_ID
           'APP',                            -- POSTING_ENTITY
           NULL,                             -- CASH_RECEIPT_ID
           app.customer_trx_id,              -- CUSTOMER_TRX_ID
           NULL,         -- CUSTOMER_TRX_LINE_ID
           NULL,         -- CUST_TRX_LINE_GL_DIST_ID
           NULL,         --  CUST_TRX_LINE_SALESREP_ID
           NULL,         -- INVENTORY_ITEM_ID
           NULL,         -- SALES_TAX_ID
           NULL,         -- SO_ORGANIZATION_ID
           NULL,         -- TAX_EXEMPTION_ID
           NULL,         -- UOM_CODE
           NULL,         -- WAREHOUSE_ID
           NULL,         -- AGREEMENT_ID
           NULL,         -- CUSTOMER_BANK_ACCT_ID
           NULL,         -- DRAWEE_BANK_ACCOUNT_ID
           NULL,         -- REMITTANCE_BANK_ACCT_ID
           NULL,         -- DISTRIBUTION_SET_ID
           NULL,         -- PAYMENT_SCHEDULE_ID
           NULL,         -- RECEIPT_METHOD_ID
           app.receivables_trx_id,         -- RECEIVABLES_TRX_ID
           NULL,         -- ED_ADJ_RECEIVABLES_TRX_ID
           NULL,         -- UNED_RECEIVABLES_TRX_ID
           app.set_of_books_id,         -- SET_OF_BOOKS_ID
           NULL,         -- SALESREP_ID
           trx.BILL_TO_SITE_USE_ID,         -- BILL_SITE_USE_ID
           NULL,         -- DRAWEE_SITE_USE_ID
           NULL,         -- PAYING_SITE_USE_ID
           trx.SOLD_TO_SITE_USE_ID,         -- SOLD_SITE_USE_ID
           trx.SHIP_TO_SITE_USE_ID,         -- SHIP_SITE_USE_ID
           NULL,         -- RECEIPT_CUSTOMER_SITE_USE_ID
           NULL,         -- BILL_CUST_ROLE_ID
           NULL,         -- DRAWEE_CUST_ROLE_ID
           NULL,         -- SHIP_CUST_ROLE_ID
           NULL,         -- SOLD_CUST_ROLE_ID
           trx.BILL_TO_CUSTOMER_ID,         -- BILL_CUSTOMER_ID
           NULL,         -- DRAWEE_CUSTOMER_ID
           NULL,         -- PAYING_CUSTOMER_ID
           trx.SOLD_TO_CUSTOMER_ID,         -- SOLD_CUSTOMER_ID
           trx.SHIP_TO_CUSTOMER_ID,         -- SHIP_CUSTOMER_ID
           NULL,         -- REMIT_ADDRESS_ID
           NULL,         -- RECEIPT_BATCH_ID
           app.receivable_application_id,    -- RECEIVABLE_APPLICATION_ID
           NULL,                             -- CUSTOMER_BANK_BRANCH_ID
           NULL,                             -- ISSUER_BANK_BRANCH_ID
           NULL,                     -- BATCH_SOURCE_ID
           NULL,                     -- BATCH_ID
           NULL,                     -- TERM_ID
           'Y',                              -- SELECT_FLAG
           'L',                              -- LEVEL_FLAG
           'T',                              -- FROM_TO_FLAG
           NVL(dist.amount_cr,0) - NVL(dist.amount_dr,0),  -- FROM_AMOUNT
           NVL(dist.amount_cr,0) -NVL(dist.amount_dr,0),             -- AMOUNT
           NVL(dist.acctd_amount_cr,0) - NVL(dist.acctd_amount_dr,0), -- FROM_ACCTD_MOUNT
          gt.event_type_code
         ,gt.event_class_code
         ,gt.entity_code
         ,NULL       --tax_line_id
         --BUG#5366837
         ,app.upgrade_method
         ,'N'                    --MFAR_ADDITIONAL_ENTRY
         , dist.source_type
         , to_number(NULL)
      FROM xla_events_gt                  gt,
           ar_receivable_applications_all app,
           ar_distributions_all           dist,
           gl_sets_of_books               sob,
           ra_customer_trx_all            trx
     WHERE gt.event_type_code  IN (  'CM_CREATE','CM_UPDATE' )
       AND gt.application_id                 = p_application_id
       AND gt.event_id                       = app.event_id
       AND dist.source_table                 = 'RA'
       AND dist.source_id                    = app.receivable_application_id
       AND app.status                        = 'ACTIVITY'
       AND app.set_of_books_id               = sob.set_of_books_id
       AND trx.customer_trx_id               = app.customer_trx_id
       AND dist.source_type                  = 'ACTIVITY';



--BUG#5366837 Cash Basis
    INSERT INTO ar_xla_lines_extract (
        EVENT_ID
       ,LINE_NUMBER
       ,LANGUAGE
       ,LEDGER_ID
       ,SOURCE_ID
       ,SOURCE_TABLE
       ,LINE_ID
       ,TAX_CODE_ID
       ,LOCATION_SEGMENT_ID
       ,BASE_CURRENCY_CODE
       ,EXCHANGE_RATE_TYPE
       ,EXCHANGE_RATE
       ,EXCHANGE_DATE
       ,ACCTD_AMOUNT
       ,TAXABLE_ACCTD_AMOUNT
       ,ORG_ID
       ,HEADER_TABLE_ID
       ,POSTING_ENTITY
       ,CASH_RECEIPT_ID
       ,CUSTOMER_TRX_ID
       ,CUSTOMER_TRX_LINE_ID
       ,CUST_TRX_LINE_GL_DIST_ID
       ,CUST_TRX_LINE_SALESREP_ID
       ,INVENTORY_ITEM_ID
       ,SALES_TAX_ID
       ,SO_ORGANIZATION_ID
       ,TAX_EXEMPTION_ID
       ,UOM_CODE
       ,WAREHOUSE_ID
       ,AGREEMENT_ID
       ,CUSTOMER_BANK_ACCT_ID
       ,DRAWEE_BANK_ACCOUNT_ID
       ,REMITTANCE_BANK_ACCT_ID
       ,DISTRIBUTION_SET_ID
       ,PAYMENT_SCHEDULE_ID
       ,RECEIPT_METHOD_ID
       ,RECEIVABLES_TRX_ID
       ,ED_ADJ_RECEIVABLES_TRX_ID
       ,UNED_RECEIVABLES_TRX_ID
       ,SET_OF_BOOKS_ID
       ,SALESREP_ID
       ,BILL_SITE_USE_ID
       ,DRAWEE_SITE_USE_ID
       ,PAYING_SITE_USE_ID
       ,SOLD_SITE_USE_ID
       ,SHIP_SITE_USE_ID
       ,RECEIPT_CUSTOMER_SITE_USE_ID
       ,BILL_CUST_ROLE_ID
       ,DRAWEE_CUST_ROLE_ID
       ,SHIP_CUST_ROLE_ID
       ,SOLD_CUST_ROLE_ID
       ,BILL_CUSTOMER_ID
       ,DRAWEE_CUSTOMER_ID
       ,PAYING_CUSTOMER_ID
       ,SOLD_CUSTOMER_ID
       ,SHIP_CUSTOMER_ID
       ,REMIT_ADDRESS_ID
       ,RECEIPT_BATCH_ID
       ,RECEIVABLE_APPLICATION_ID
       ,CUSTOMER_BANK_BRANCH_ID
       ,ISSUER_BANK_BRANCH_ID
       ,BATCH_SOURCE_ID
       ,BATCH_ID
       ,TERM_ID
       ,SELECT_FLAG
       ,LEVEL_FLAG
       ,FROM_TO_FLAG
       ,FROM_AMOUNT
       ,AMOUNT
       ,FROM_ACCTD_AMOUNT
       ,event_type_code
       ,event_class_code
       ,entity_code
       ,tax_line_id
       ,ADDITIONAL_CHAR1
         ,MFAR_ADDITIONAL_ENTRY
       )
        SELECT /*+LEADING(gt) USE_NL(gt, app)*/
            gt.event_id                      -- EVENT_ID
           ,acb.cash_basis_distribution_id   -- LINE_NUMBER
           ,''                               -- LANGUAGE
           ,sob.set_of_books_id              -- LEDGER_ID
           ,app.receivable_application_id    -- SOURCE_ID
           ,'RA'                             -- SOURCE_TABLE
           ,acb.cash_basis_distribution_id   -- LINE_ID
           ,NULL                             -- TAX_CODE_ID
           ,NULL                             -- LOCATION_SEGMENT_ID
           ,sob.currency_code                -- BASE_CURRENCY
           ,trxt.exchange_rate_type          -- EXCHANGE_RATE_TYPE
           ,trxt.exchange_rate               -- EXCHANGE_RATE
           ,trxt.exchange_date               -- EXCHANGE_DATE
           ,acb.acctd_amount                 -- ACCTD_AMOUNT
           ,NULL                             -- TAXABLE_ACCTD_AMOUNT
           ,app.org_id                       -- ORG_ID
           ,app.receivable_application_id    -- HEADER_TABLE_ID
           ,'APP'                            -- POSTING_ENTITY
           ,NULL                             -- CASH_RECEIPT_ID
           ,trxt.customer_trx_id             -- CUSTOMER_TRX_ID
           ,tlt.customer_trx_line_id         -- CUSTOMER_TRX_LINE_ID
           ,gldt.cust_trx_line_gl_dist_id    -- CUST_TRX_LINE_GL_DIST_ID
           ,gldt.cust_trx_line_salesrep_id   --  CUST_TRX_LINE_SALESREP_ID
           ,tlt.inventory_item_id            -- INVENTORY_ITEM_ID
           ,tlt.sales_tax_id                 -- SALES_TAX_ID
           ,osp.master_organization_id       -- SO_ORGANIZATION_ID
           ,tlt.tax_exemption_id             -- TAX_EXEMPTION_ID
           ,tlt.uom_code                     -- UOM_CODE
           ,tlt.warehouse_id                 -- WAREHOUSE_ID
           ,trxt.agreement_id                -- AGREEMENT_ID
           ,trxt.customer_bank_account_id    -- CUSTOMER_BANK_ACCT_ID
           ,trxt.drawee_bank_account_id      -- DRAWEE_BANK_ACCOUNT_ID
           ,trxt.remit_bank_acct_use_id  -- REMITTANCE_BANK_ACCT_ID
           ,NULL                             -- DISTRIBUTION_SET_ID
           ,psch.payment_schedule_id         -- PAYMENT_SCHEDULE_ID
           ,trxt.receipt_method_id           -- RECEIPT_METHOD_ID
           ,NULL                             -- RECEIVABLES_TRX_ID
           ,NULL                             -- ED_ADJ_RECEIVABLES_TRX_ID
           ,NULL                             -- UNED_RECEIVABLES_TRX_ID
           ,trxt.set_of_books_id             -- SET_OF_BOOKS_ID
           ,trxt.primary_salesrep_id         -- SALESREP_ID
           ,trxt.bill_to_site_use_id         -- BILL_SITE_USE_ID
           ,trxt.drawee_site_use_id          -- DRAWEE_SITE_USE_ID
           ,trxt.paying_site_use_id          -- PAYING_SITE_USE_ID
           ,trxt.sold_to_site_use_id         -- SOLD_SITE_USE_ID
           ,trxt.ship_to_site_use_id         -- SHIP_SITE_USE_ID
           ,NULL                             -- RECEIPT_CUSTOMER_SITE_USE_ID
           ,trxt.bill_to_contact_id          -- BILL_CUST_ROLE_ID
           ,trxt.drawee_contact_id           -- DRAWEE_CUST_ROLE_ID
           ,trxt.ship_to_contact_id          -- SHIP_CUST_ROLE_ID
           ,trxt.sold_to_contact_id          -- SOLD_CUST_ROLE_ID
           ,trxt.bill_to_customer_id         -- BILL_CUSTOMER_ID
           ,trxt.drawee_id                   -- DRAWEE_CUSTOMER_ID
           ,trxt.paying_customer_id          -- PAYING_CUSTOMER_ID
           ,trxt.sold_to_customer_id         -- SOLD_CUSTOMER_ID
           ,trxt.ship_to_customer_id         -- SHIP_CUSTOMER_ID
           ,trxt.remit_to_address_id         -- REMIT_ADDRESS_ID
           ,NULL                             -- RECEIPT_BATCH_ID
           ,NULL                             -- RECEIVABLE_APPLICATION_ID
           ,NULL                             -- CUSTOMER_BANK_BRANCH_ID
           ,NULL                             -- ISSUER_BANK_BRANCH_ID
           ,trxt.batch_source_id             -- BATCH_SOURCE_ID
           ,trxt.batch_id                    -- BATCH_ID
           ,trxt.term_id                     -- TERM_ID
           ,'Y'                              -- SELECT_FLAG
           ,'L'                              -- LEVEL_FLAG
           ,'T'                              -- FROM_TO_FLAG
           ,acb.from_amount                  -- FROM_AMOUNT
           ,acb.amount                       -- AMOUNT
           ,acb.from_acctd_amount            -- FROM_ACCTD_AMOUNT
           ,gt.event_type_code
           ,gt.event_class_code
           ,gt.entity_code
           ,tlt.tax_line_id                  --tax_line_id
           ,app.upgrade_method
         ,'N'                    --MFAR_ADDITIONAL_ENTRY
      FROM xla_events_gt                  gt,
           ar_receivable_applications_all app,
           AR_CASH_BASIS_DISTS_ALL        acb,
           gl_sets_of_books               sob,
           oe_system_parameters_all       osp,
           ra_customer_trx_all            trxt,
           ra_customer_trx_lines_all      tlt,
           ra_cust_trx_line_gl_dist_all   gldt,
           ar_payment_schedules_all       psch,
           ar_system_parameters_all        ars
     WHERE gt.event_type_code IN (  'RECP_CREATE'      ,'RECP_UPDATE',
                                    'RECP_RATE_ADJUST' ) --Uptake XLA Reversal, 'RECP_REVERSE')
       AND gt.application_id                 = p_application_id
       AND gt.event_id                       = app.event_id
       AND app.receivable_application_id     = acb.receivable_application_id
       AND app.upgrade_method                = 'R12_11ICASH_POST'
       AND acb.receivable_application_id     = app.receivable_application_id
       AND app.set_of_books_id               = sob.set_of_books_id
       AND app.org_id                        = osp.org_id(+)
       AND app.applied_customer_trx_id       = trxt.customer_trx_id
       AND acb.REF_CUSTOMER_TRX_LINE_ID      = tlt.customer_trx_line_id(+)
       AND acb.ref_cust_trx_line_gl_dist_id  = gldt.cust_trx_line_gl_dist_id(+)
       AND trxt.customer_trx_id              = psch.customer_trx_id
       AND NVL(psch.terms_sequence_number,1) = 1
       AND ars.org_id                        = app.org_id
       AND ars.ACCOUNTING_METHOD             = 'CASH'
    UNION ALL
        SELECT /*+LEADING(gt) USE_NL(gt, app)*/
            gt.event_id                      -- EVENT_ID
           ,acb.cash_basis_distribution_id   -- LINE_NUMBER
           ,''                               -- LANGUAGE
           ,sob.set_of_books_id              -- LEDGER_ID
           ,app.receivable_application_id    -- SOURCE_ID
           ,'RA'                             -- SOURCE_TABLE
           ,acb.cash_basis_distribution_id   -- LINE_ID
           ,NULL                             -- TAX_CODE_ID
           ,NULL                             -- LOCATION_SEGMENT_ID
           ,sob.currency_code                -- BASE_CURRENCY
           ,trxt.exchange_rate_type          -- EXCHANGE_RATE_TYPE
           ,trxt.exchange_rate               -- EXCHANGE_RATE
           ,trxt.exchange_date               -- EXCHANGE_DATE
           ,acb.acctd_amount                 -- ACCTD_AMOUNT
           ,NULL                             -- TAXABLE_ACCTD_AMOUNT
           ,app.org_id                       -- ORG_ID
           ,app.receivable_application_id    -- HEADER_TABLE_ID
           ,'APP'                            -- POSTING_ENTITY
           ,NULL                             -- CASH_RECEIPT_ID
           ,trxt.customer_trx_id             -- CUSTOMER_TRX_ID
           ,tlt.customer_trx_line_id         -- CUSTOMER_TRX_LINE_ID
           ,gldt.cust_trx_line_gl_dist_id    -- CUST_TRX_LINE_GL_DIST_ID
           ,gldt.cust_trx_line_salesrep_id   --  CUST_TRX_LINE_SALESREP_ID
           ,tlt.inventory_item_id            -- INVENTORY_ITEM_ID
           ,tlt.sales_tax_id                 -- SALES_TAX_ID
           ,osp.master_organization_id       -- SO_ORGANIZATION_ID
           ,tlt.tax_exemption_id             -- TAX_EXEMPTION_ID
           ,tlt.uom_code                     -- UOM_CODE
           ,tlt.warehouse_id                 -- WAREHOUSE_ID
           ,trxt.agreement_id                -- AGREEMENT_ID
           ,trxt.customer_bank_account_id    -- CUSTOMER_BANK_ACCT_ID
           ,trxt.drawee_bank_account_id      -- DRAWEE_BANK_ACCOUNT_ID
           ,trxt.remit_bank_acct_use_id      -- REMITTANCE_BANK_ACCT_ID
           ,NULL                             -- DISTRIBUTION_SET_ID
           ,psch.payment_schedule_id         -- PAYMENT_SCHEDULE_ID
           ,trxt.receipt_method_id           -- RECEIPT_METHOD_ID
           ,NULL                             -- RECEIVABLES_TRX_ID
           ,NULL                             -- ED_ADJ_RECEIVABLES_TRX_ID
           ,NULL                             -- UNED_RECEIVABLES_TRX_ID
           ,trxt.set_of_books_id             -- SET_OF_BOOKS_ID
           ,trxt.primary_salesrep_id         -- SALESREP_ID
           ,trxt.bill_to_site_use_id         -- BILL_SITE_USE_ID
           ,trxt.drawee_site_use_id          -- DRAWEE_SITE_USE_ID
           ,trxt.paying_site_use_id          -- PAYING_SITE_USE_ID
           ,trxt.sold_to_site_use_id         -- SOLD_SITE_USE_ID
           ,trxt.ship_to_site_use_id         -- SHIP_SITE_USE_ID
           ,NULL                             -- RECEIPT_CUSTOMER_SITE_USE_ID
           ,trxt.bill_to_contact_id          -- BILL_CUST_ROLE_ID
           ,trxt.drawee_contact_id           -- DRAWEE_CUST_ROLE_ID
           ,trxt.ship_to_contact_id          -- SHIP_CUST_ROLE_ID
           ,trxt.sold_to_contact_id          -- SOLD_CUST_ROLE_ID
           ,trxt.bill_to_customer_id         -- BILL_CUSTOMER_ID
           ,trxt.drawee_id                   -- DRAWEE_CUSTOMER_ID
           ,trxt.paying_customer_id          -- PAYING_CUSTOMER_ID
           ,trxt.sold_to_customer_id         -- SOLD_CUSTOMER_ID
           ,trxt.ship_to_customer_id         -- SHIP_CUSTOMER_ID
           ,trxt.remit_to_address_id         -- REMIT_ADDRESS_ID
           ,NULL                             -- RECEIPT_BATCH_ID
           ,NULL                             -- RECEIVABLE_APPLICATION_ID
           ,NULL                             -- CUSTOMER_BANK_BRANCH_ID
           ,NULL                             -- ISSUER_BANK_BRANCH_ID
           ,trxt.batch_source_id             -- BATCH_SOURCE_ID
           ,trxt.batch_id                    -- BATCH_ID
           ,trxt.term_id                     -- TERM_ID
           ,'Y'                              -- SELECT_FLAG
           ,'L'                              -- LEVEL_FLAG
           ,'T'                              -- FROM_TO_FLAG
           ,NULL                             -- FROM_AMOUNT,
           ,acb.amount                       -- AMOUNT
           ,acb.from_acctd_Amount            -- FROM_ACCTD_AMOUNT
           ,gt.event_type_code
           ,gt.event_class_code
           ,gt.entity_code
           ,tlt.tax_line_id                  -- tax_line_id
           ,app.upgrade_method
         ,'N'                    --MFAR_ADDITIONAL_ENTRY
      FROM xla_events_gt                  gt,
           ar_receivable_applications_all app,
           AR_CASH_BASIS_DISTS_ALL        acb,
           gl_sets_of_books               sob,
           oe_system_parameters_all       osp,
           ra_customer_trx_all            trxt,
           ra_customer_trx_lines_all      tlt,
           ra_cust_trx_line_gl_dist_all   gldt,
           ar_payment_schedules_all       psch,
           ar_system_parameters_all        ars
     WHERE gt.event_type_code IN (  'CM_CREATE'        ,'CM_UPDATE'    )
       AND gt.application_id                 = p_application_id
       AND gt.event_id                       = app.event_id
       AND app.upgrade_method                = 'R12_11ICASH_POST'
       AND acb.receivable_application_id     = app.receivable_application_id
       AND app.set_of_books_id               = sob.set_of_books_id
       AND app.org_id                        = osp.org_id(+)
       AND app.applied_customer_trx_id       = trxt.customer_trx_id
       AND acb.ref_customer_trx_line_id     = tlt.customer_trx_line_id(+)
       AND acb.ref_cust_trx_line_gl_dist_id = gldt.cust_trx_line_gl_dist_id(+)
       AND trxt.customer_trx_id              = psch.customer_trx_id
       AND NVL(psch.terms_sequence_number,1) = 1
       AND ars.org_id                        = app.org_id
       AND ars.ACCOUNTING_METHOD             = 'CASH'
       AND acb.ref_cust_trx_line_gl_dist_id  NOT IN
           (SELECT cust_trx_line_gl_dist_id
              FROM ra_cust_trx_line_gl_dist_all
             WHERE customer_trx_id =  gt.source_id_int_1); --Excluding the receivable distribution of the CM



   local_log(procedure_name => 'load_line_data_app_to_trx',
             p_msg_text     => 'arp_xla_extract_main_pkg.load_line_data_app_to_trx ()-');
EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'load_line_data_app_to_trx',
             p_msg_text     => 'EXCEPTION OTHERS in arp_xla_extract_main_pkg.load_line_data_app_to_trx '||
             arp_global.CRLF || 'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.load_line_data_app_to_trx'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;
END load_line_data_app_to_trx;


--This is no longer usefull as we pass the UNID and the UNAPP as well
-- Leave it for now
PROCEDURE load_line_data_app_unid(p_application_id IN NUMBER DEFAULT 222)
IS
BEGIN
   local_log(procedure_name => 'load_line_data_app_unid',
             p_msg_text     => 'arp_xla_extract_main_pkg.load_line_data_app_unid ()+');
    -- Insert line level data in Line GT with
    -- selected_flag = Y
    -- level_flag    = L
    -- from_to_flag  = T
    INSERT INTO ar_xla_lines_extract (
        EVENT_ID
       ,LINE_NUMBER
       ,LANGUAGE
       ,LEDGER_ID
       ,SOURCE_ID
       ,SOURCE_TABLE
       ,LINE_ID
       ,TAX_CODE_ID
       ,LOCATION_SEGMENT_ID
       ,BASE_CURRENCY_CODE
       ,EXCHANGE_RATE_TYPE
       ,EXCHANGE_RATE
       ,EXCHANGE_DATE
       ,ACCTD_AMOUNT
       ,TAXABLE_ACCTD_AMOUNT
       ,ORG_ID
       ,HEADER_TABLE_ID
       ,POSTING_ENTITY
       ,CASH_RECEIPT_ID
       ,CUSTOMER_TRX_ID
       ,CUSTOMER_TRX_LINE_ID
       ,CUST_TRX_LINE_GL_DIST_ID
       ,CUST_TRX_LINE_SALESREP_ID
       ,INVENTORY_ITEM_ID
       ,SALES_TAX_ID
       ,SO_ORGANIZATION_ID
       ,TAX_EXEMPTION_ID
       ,UOM_CODE
       ,WAREHOUSE_ID
       ,AGREEMENT_ID
       ,CUSTOMER_BANK_ACCT_ID
       ,DRAWEE_BANK_ACCOUNT_ID
       ,REMITTANCE_BANK_ACCT_ID
       ,DISTRIBUTION_SET_ID
       ,PAYMENT_SCHEDULE_ID
       ,RECEIPT_METHOD_ID
       ,RECEIVABLES_TRX_ID
       ,ED_ADJ_RECEIVABLES_TRX_ID
       ,UNED_RECEIVABLES_TRX_ID
       ,SET_OF_BOOKS_ID
       ,SALESREP_ID
       ,BILL_SITE_USE_ID
       ,DRAWEE_SITE_USE_ID
       ,PAYING_SITE_USE_ID
       ,SOLD_SITE_USE_ID
       ,SHIP_SITE_USE_ID
       ,RECEIPT_CUSTOMER_SITE_USE_ID
       ,BILL_CUST_ROLE_ID
       ,DRAWEE_CUST_ROLE_ID
       ,SHIP_CUST_ROLE_ID
       ,SOLD_CUST_ROLE_ID
       ,BILL_CUSTOMER_ID
       ,DRAWEE_CUSTOMER_ID
       ,PAYING_CUSTOMER_ID
       ,SOLD_CUSTOMER_ID
       ,SHIP_CUSTOMER_ID
       ,REMIT_ADDRESS_ID
       ,RECEIPT_BATCH_ID
       ,RECEIVABLE_APPLICATION_ID
       ,CUSTOMER_BANK_BRANCH_ID
       ,ISSUER_BANK_BRANCH_ID
       ,BATCH_SOURCE_ID
       ,BATCH_ID
       ,TERM_ID
       ,SELECT_FLAG
       ,LEVEL_FLAG
       ,FROM_TO_FLAG
       ,FROM_AMOUNT
       ,AMOUNT
       ,FROM_ACCTD_AMOUNT
       --{BUG#4356088
       ,event_type_code
       ,event_class_code
       ,entity_code
       --}
         ,MFAR_ADDITIONAL_ENTRY
       )
        SELECT /*+LEADING(gt) USE_NL(gt, app)*/
           gt.event_id,                      -- EVENT_ID
           dist.line_id,                     -- LINE_NUMBER
           '',                               -- LANGUAGE
           sob.set_of_books_id,              -- LEDGER_ID
           dist.source_id,                   -- SOURCE_ID
           dist.source_table,                -- SOURCE_TABLE
           dist.line_id,                     -- LINE_ID
           dist.tax_code_id,                 -- TAX_CODE_ID
           dist.location_segment_id,         -- LOCATION_SEGMENT_ID
           sob.currency_code,                -- BASE_CURRENCY
           NULL,          -- EXCHANGE_RATE_TYPE
           NULL,               -- EXCHANGE_RATE
           NULL,               -- EXCHANGE_DATE
           NVL(dist.acctd_amount_cr,0) -
                NVL(dist.acctd_amount_dr,0),      -- ACCTD_AMOUNT
           NVL(dist.taxable_accounted_cr,0) -
                NVL(dist.taxable_accounted_dr,0), -- TAXABLE_ACCTD_AMOUNT
           app.org_id,                       -- ORG_ID
           app.receivable_application_id,    -- HEADER_TABLE_ID
           'APP',                            -- POSTING_ENTITY
           NULL,                             -- CASH_RECEIPT_ID
           NULL,             -- CUSTOMER_TRX_ID
           NULL,         -- CUSTOMER_TRX_LINE_ID
           NULL,    -- CUST_TRX_LINE_GL_DIST_ID
           NULL,   --  CUST_TRX_LINE_SALESREP_ID
           NULL,            -- INVENTORY_ITEM_ID
           NULL,                 -- SALES_TAX_ID
           NULL,       -- SO_ORGANIZATION_ID
           NULL,             -- TAX_EXEMPTION_ID
           NULL,                     -- UOM_CODE
           NULL,                 -- WAREHOUSE_ID
           NULL,                -- AGREEMENT_ID
           NULL,    -- CUSTOMER_BANK_ACCT_ID
           NULL,      -- DRAWEE_BANK_ACCOUNT_ID
           NULL,  -- REMITTANCE_BANK_ACCT_ID
           NULL,                             -- DISTRIBUTION_SET_ID
           NULL,         -- PAYMENT_SCHEDULE_ID
           NULL,           -- RECEIPT_METHOD_ID
           NULL,                             -- RECEIVABLES_TRX_ID
           NULL,                             -- ED_ADJ_RECEIVABLES_TRX_ID
           NULL,                             -- UNED_RECEIVABLES_TRX_ID
           NULL,             -- SET_OF_BOOKS_ID
           NULL,         -- SALESREP_ID
           NULL,         -- BILL_SITE_USE_ID
           NULL,          -- DRAWEE_SITE_USE_ID
           NULL,          -- PAYING_SITE_USE_ID
           NULL,         -- SOLD_SITE_USE_ID
           NULL,         -- SHIP_SITE_USE_ID
           NULL,                             -- RECEIPT_CUSTOMER_SITE_USE_ID
           NULL,          -- BILL_CUST_ROLE_ID
           NULL,           -- DRAWEE_CUST_ROLE_ID
           NULL,          -- SHIP_CUST_ROLE_ID
           NULL,          -- SOLD_CUST_ROLE_ID
           NULL,         -- BILL_CUSTOMER_ID
           NULL,                   -- DRAWEE_CUSTOMER_ID
           NULL,          -- PAYING_CUSTOMER_ID
           NULL,         -- SOLD_CUSTOMER_ID
           NULL,         -- SHIP_CUSTOMER_ID
           NULL,         -- REMIT_ADDRESS_ID
           NULL,                             -- RECEIPT_BATCH_ID
           NULL,                             -- RECEIVABLE_APPLICATION_ID
           NULL,                             -- CUSTOMER_BANK_BRANCH_ID
           NULL,                             -- ISSUER_BANK_BRANCH_ID
           NULL,             -- BATCH_SOURCE_ID
           NULL,                    -- BATCH_ID
           NULL,                     -- TERM_ID
           'Y',                              -- SELECT_FLAG
           'L',                              -- LEVEL_FLAG
           'T',                              -- FROM_TO_FLAG
           NVL(dist.from_amount_cr,0)
             -NVL(dist.from_amount_dr,0),    -- FROM_AMOUNT,
           NVL(dist.amount_cr,0)
             -NVL(dist.amount_dr,0),          -- AMOUNT
           NVL(dist.from_acctd_amount_cr,0)
             -NVL(dist.from_acctd_amount_dr,0) -- FROM_ACCTD_AMOUNT
         --{BUG#4356088
         ,gt.event_type_code
         ,gt.event_class_code
         ,gt.entity_code
         --}
         ,'N'                    --MFAR_ADDITIONAL_ENTRY
      FROM xla_events_gt                  gt,
           ar_receivable_applications_all app,
           ar_distributions_all           dist,  --ar_distributions_all dist,
           gl_sets_of_books               sob
     WHERE gt.event_type_code IN (  'RECP_CREATE'      ,'RECP_UPDATE'      ,
                                    'RECP_RATE_ADJUST' ) --Uptake XLA reversal,'RECP_REVERSE')
-- Exclude 'RECP_REVERSE' for no extract at line level is reuired for Reversal
       AND gt.application_id                 = p_application_id
       AND gt.event_id                       = app.event_id
       AND dist.source_table                 = 'RA'
       AND dist.source_id                    = app.receivable_application_id
       AND app.set_of_books_id               = sob.set_of_books_id
       AND dist.source_type                  = 'UNID';

   local_log(procedure_name => 'load_line_data_app_unid',
             p_msg_text     => 'arp_xla_extract_main_pkg.load_line_data_app_unid ()-');

EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'load_line_data_app_unid',
             p_msg_text     => 'EXCEPTION OTHERS in arp_xla_extract_main_pkg.load_line_data_app_unid '||
             arp_global.CRLF || 'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.load_line_data_app_to_trx'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;
END load_line_data_app_unid;
-------------------------------------------------------------------------------
/*-----------------------------------------------------------------+
 | Procedure Name : load_line_data_crh                             |
 | Description    : Extract line data for cash receipt and         |
 |                  misc cash receipt events                       |
 +-----------------------------------------------------------------+
 | History        :                                                |
 | 23-FEB-2004     Herve Yu    Created due to bug#3419926          |
 +-----------------------------------------------------------------*/
PROCEDURE load_line_data_crh(p_application_id IN NUMBER DEFAULT 222)
IS
BEGIN
   local_log(procedure_name => 'load_line_data_crh',
             p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.load_line_date_crh ()+');
      -- Line data CR in Line GT
      -- Selected_flag = N
      -- Level_flag    = L
   INSERT INTO ar_xla_lines_extract (
        EVENT_ID
       ,LINE_NUMBER
       ,LANGUAGE
       ,LEDGER_ID
       ,SOURCE_ID
       ,SOURCE_TABLE
       ,LINE_ID
       ,TAX_CODE_ID
       ,LOCATION_SEGMENT_ID
       ,BASE_CURRENCY_CODE
       ,EXCHANGE_RATE_TYPE
       ,EXCHANGE_RATE
       ,EXCHANGE_DATE
       ,ACCTD_AMOUNT
       ,TAXABLE_ACCTD_AMOUNT
       ,ORG_ID
       ,HEADER_TABLE_ID
       ,POSTING_ENTITY
       ,CASH_RECEIPT_ID
       ,CUSTOMER_TRX_ID
       ,CUSTOMER_TRX_LINE_ID
       ,CUST_TRX_LINE_GL_DIST_ID
       ,CUST_TRX_LINE_SALESREP_ID
       ,INVENTORY_ITEM_ID
       ,SALES_TAX_ID
       ,SO_ORGANIZATION_ID
       ,TAX_EXEMPTION_ID
       ,UOM_CODE
       ,WAREHOUSE_ID
       ,AGREEMENT_ID
       ,CUSTOMER_BANK_ACCT_ID
       ,DRAWEE_BANK_ACCOUNT_ID
       ,REMITTANCE_BANK_ACCT_ID
       ,DISTRIBUTION_SET_ID
       ,PAYMENT_SCHEDULE_ID
       ,RECEIPT_METHOD_ID
       ,RECEIVABLES_TRX_ID
       ,ED_ADJ_RECEIVABLES_TRX_ID
       ,UNED_RECEIVABLES_TRX_ID
       ,SET_OF_BOOKS_ID
       ,SALESREP_ID
       ,BILL_SITE_USE_ID
       ,DRAWEE_SITE_USE_ID
       ,PAYING_SITE_USE_ID
       ,SOLD_SITE_USE_ID
       ,SHIP_SITE_USE_ID
       ,RECEIPT_CUSTOMER_SITE_USE_ID
       ,BILL_CUST_ROLE_ID
       ,DRAWEE_CUST_ROLE_ID
       ,SHIP_CUST_ROLE_ID
       ,SOLD_CUST_ROLE_ID
       ,BILL_CUSTOMER_ID
       ,DRAWEE_CUSTOMER_ID
       ,PAYING_CUSTOMER_ID
       ,SOLD_CUSTOMER_ID
       ,SHIP_CUSTOMER_ID
       ,REMIT_ADDRESS_ID
       ,RECEIPT_BATCH_ID
       ,RECEIVABLE_APPLICATION_ID
       ,CUSTOMER_BANK_BRANCH_ID
       ,ISSUER_BANK_BRANCH_ID
       ,BATCH_SOURCE_ID
       ,BATCH_ID
       ,TERM_ID
       ,SELECT_FLAG
       ,LEVEL_FLAG
       ,FROM_TO_FLAG
       ,CRH_STATUS
       ,CRH_PRV_STATUS
       ,AMOUNT
       --{BUG#4356088
       ,event_type_code
       ,event_class_code
       ,entity_code
       --}
         ,MFAR_ADDITIONAL_ENTRY
       )
        SELECT /*+LEADING(gt) USE_NL(gt,crh)*/
           gt.event_id,                      -- EVENT_ID
           dist.line_id,                     -- LINE_NUMBER
           '',                               -- LANGUAGE
           sob.set_of_books_id,              -- LEDGER_ID
           dist.source_id,                   -- SOURCE_ID
           dist.source_table,                -- SOURCE_TABLE
           dist.line_id,                     -- LINE_ID
           dist.tax_code_id,                 -- TAX_CODE_ID
           dist.location_segment_id,         -- LOCATION_SEGMENT_ID
           sob.currency_code,                -- BASE_CURRENCY
           crh.exchange_rate_type,            -- EXCHANGE_RATE_TYPE
           crh.exchange_rate     ,            -- EXCHANGE_RATE
           crh.exchange_date     ,            -- EXCHANGE_DATE
           NVL(dist.acctd_amount_cr,0)
             - NVL(dist.acctd_amount_dr,0) ,      -- ACCTD_AMOUNT
           NVL(dist.taxable_accounted_cr,0)
             - NVL(dist.taxable_accounted_dr,0), -- TAXABLE_ACCTD_AMOUNT
           crh.org_id,                       -- ORG_ID
           crh.cash_receipt_history_id,      -- HEADER_TABLE_ID
           'CRH',                            -- POSTING_ENTITY
           crh.cash_receipt_id,               -- CASH_RECEIPT_ID
           NULL,                             -- CUSTOMER_TRX_ID
           NULL,                             -- CUSTOMER_TRX_LINE_ID
           NULL,                             -- CUST_TRX_LINE_GL_DIST_ID
           NULL,                             -- CUST_TRX_LINE_SALESREP_ID
           NULL,                             -- INVENTORY_ITEM_ID
           NULL,                             -- SALES_TAX_ID
           NULL,                             -- SO_ORGANIZATION_ID
           NULL,                             -- TAX_EXEMPTION_ID
           NULL,                             -- UOM_CODE
           NULL,                             -- WAREHOUSE_ID
           NULL,                             -- AGREEMENT_ID
           NULL,                             -- CUSTOMER_BANK_ACCT_ID
           NULL,                             -- DRAWEE_BANK_ACCOUNT_ID
           NULL,                             -- REMITTANCE_BANK_ACCT_ID
           NULL,                             -- DISTRIBUTION_SET_ID
           NULL,                             -- PAYMENT_SCHEDULE_ID
           NULL,                             -- RECEIPT_METHOD_ID
           NULL,                             -- RECEIVABLES_TRX_ID
           NULL,                             -- ED_ADJ_RECEIVABLES_TRX_ID
           NULL,                             -- UNED_RECEIVABLES_TRX_ID
           sob.set_of_books_id,              -- SET_OF_BOOKS_ID
           NULL,                               -- SALESREP_ID
           NULL,                               -- BILL_SITE_USE_ID
           NULL,                               -- DRAWEE_SITE_USE_ID
           NULL,                               -- PAYING_SITE_USE_ID
           NULL,                               -- SOLD_SITE_USE_ID
           NULL,                               -- SHIP_SITE_USE_ID
           NULL,                               -- RECEIPT_CUSTOMER_SITE_USE_ID
           NULL,                               -- BILL_CUST_ROLE_ID
           NULL,                               -- DRAWEE_CUST_ROLE_ID
           NULL,                               -- SHIP_CUST_ROLE_ID
           NULL,                               -- SOLD_CUST_ROLE_ID
           NULL,                               -- BILL_CUSTOMER_ID
           NULL,                               -- DRAWEE_CUSTOMER_ID
           NULL,                               -- PAYING_CUSTOMER_ID
           NULL,                               -- SOLD_CUSTOMER_ID
           NULL,                               -- SHIP_CUSTOMER_ID
           NULL,                               -- REMIT_ADDRESS_ID
           NULL,                               -- RECEIPT_BATCH_ID
           NULL,                               -- RECEIVABLE_APPLICATION_ID
           NULL,                               -- CUSTOMER_BANK_BRANCH_ID
           NULL,                               -- ISSUER_BANK_BRANCH_ID
           NULL,                               -- BATCH_SOURCE_ID
           NULL,                               -- BATCH_ID
           NULL,                               -- TERM_ID
           'N',                              -- SELECT_FLAG
           'L',                              -- LEVEL_FLAG
           '' ,                               -- FROM_TO_FLAG
           crh.status,                        -- CRH_STATUS
           pcrh.status,                       -- CRH_PRV_STATUS
           NVL(dist.amount_cr,0)
             - NVL(dist.amount_dr,0)          -- AMOUNT
         --{BUG#4356088
         ,gt.event_type_code
         ,gt.event_class_code
         ,gt.entity_code
         ,'N'                    --MFAR_ADDITIONAL_ENTRY
         --}
      FROM xla_events_gt                  gt,
           ar_cash_receipts_all           cr,
           ar_cash_receipt_history_all    crh,
           ar_distributions_all           dist,
           gl_sets_of_books               sob,
           ar_cash_receipt_history_all    pcrh
     WHERE gt.event_type_code IN (  'RECP_CREATE'          ,'RECP_UPDATE'        ,
                                    'MISC_RECP_CREATE'     ,'MISC_RECP_UPDATE'   ,
                                    --Uptake XLA Reversal  'RECP_REVERSE'         ,'MISC_RECP_REVERSE'  ,
                                    --5201086
                                    'RECP_RATE_ADJUST'     ,'MISC_RECP_RATE_ADJUST')
       AND gt.application_id                   = p_application_id
       AND gt.event_id                         = crh.event_id
       AND crh.cash_receipt_id                 = cr.cash_receipt_id
       AND dist.source_table                   = 'CRH'
       AND dist.source_id                      = crh.cash_receipt_history_id
       AND cr.set_of_books_id                  = sob.set_of_books_id
       AND crh.prv_stat_cash_receipt_hist_id   = pcrh.cash_receipt_history_id(+);
--RateAdj
--       AND crh.status                          = rateadj.status(+)
--       AND crh.cash_receipt_id                 = rateadj.cash_receipt_id(+);


--Extrating REVERSE
-- Needs to return 1 distribution row in case of Cash Receipt life cycle
--       AND DECODE(crh.status,'REVERSED','X',dist.source_type) =
--                                   DECODE(crh.status,'CLEARED','CASH',
--                                          'CONFIRMED','CONFIRMATION',
--                                          'REMITTED','REMITTANCE',
--                                         'REVERSED','Y');

--{Insertion of UNAPP and UNID
--Note all the UNAPP and UNID are inserted here
   INSERT INTO ar_xla_lines_extract (
        EVENT_ID
       ,LINE_NUMBER
       ,LANGUAGE
       ,LEDGER_ID
       ,SOURCE_ID
       ,SOURCE_TABLE
       ,LINE_ID
       ,TAX_CODE_ID
       ,LOCATION_SEGMENT_ID
       ,BASE_CURRENCY_CODE
       ,EXCHANGE_RATE_TYPE
       ,EXCHANGE_RATE
       ,EXCHANGE_DATE
       ,ACCTD_AMOUNT
       ,TAXABLE_ACCTD_AMOUNT
       ,ORG_ID
       ,HEADER_TABLE_ID
       ,POSTING_ENTITY
       ,CASH_RECEIPT_ID
       ,CUSTOMER_TRX_ID
       ,CUSTOMER_TRX_LINE_ID
       ,CUST_TRX_LINE_GL_DIST_ID
       ,CUST_TRX_LINE_SALESREP_ID
       ,INVENTORY_ITEM_ID
       ,SALES_TAX_ID
       ,SO_ORGANIZATION_ID
       ,TAX_EXEMPTION_ID
       ,UOM_CODE
       ,WAREHOUSE_ID
       ,AGREEMENT_ID
       ,CUSTOMER_BANK_ACCT_ID
       ,DRAWEE_BANK_ACCOUNT_ID
       ,REMITTANCE_BANK_ACCT_ID
       ,DISTRIBUTION_SET_ID
       ,PAYMENT_SCHEDULE_ID
       ,RECEIPT_METHOD_ID
       ,RECEIVABLES_TRX_ID
       ,ED_ADJ_RECEIVABLES_TRX_ID
       ,UNED_RECEIVABLES_TRX_ID
       ,SET_OF_BOOKS_ID
       ,SALESREP_ID
       ,BILL_SITE_USE_ID
       ,DRAWEE_SITE_USE_ID
       ,PAYING_SITE_USE_ID
       ,SOLD_SITE_USE_ID
       ,SHIP_SITE_USE_ID
       ,RECEIPT_CUSTOMER_SITE_USE_ID
       ,BILL_CUST_ROLE_ID
       ,DRAWEE_CUST_ROLE_ID
       ,SHIP_CUST_ROLE_ID
       ,SOLD_CUST_ROLE_ID
       ,BILL_CUSTOMER_ID
       ,DRAWEE_CUSTOMER_ID
       ,PAYING_CUSTOMER_ID
       ,SOLD_CUSTOMER_ID
       ,SHIP_CUSTOMER_ID
       ,REMIT_ADDRESS_ID
       ,RECEIPT_BATCH_ID
       ,RECEIVABLE_APPLICATION_ID
       ,CUSTOMER_BANK_BRANCH_ID
       ,ISSUER_BANK_BRANCH_ID
       ,BATCH_SOURCE_ID
       ,BATCH_ID
       ,TERM_ID
       ,SELECT_FLAG
       ,LEVEL_FLAG
       ,FROM_TO_FLAG
       ,CRH_STATUS
       ,CRH_PRV_STATUS
       ,AMOUNT
       --{BUG#4356088
       ,event_type_code
       ,event_class_code
       ,entity_code
       --}
         ,MFAR_ADDITIONAL_ENTRY
         ,FROM_ACCTD_AMOUNT         --Bug7255483 Added new column for acctd amount
       )
        SELECT /*+LEADING(gt) USE_NL(gt,cr)*/
           gt.event_id,                      -- EVENT_ID
           dist.line_id,                     -- LINE_NUMBER
           '',                               -- LANGUAGE
           sob.set_of_books_id,              -- LEDGER_ID
           dist.source_id,                   -- SOURCE_ID
           dist.source_table,                -- SOURCE_TABLE
           dist.line_id,                     -- LINE_ID
           dist.tax_code_id,                 -- TAX_CODE_ID
           dist.location_segment_id,         -- LOCATION_SEGMENT_ID
           sob.currency_code,                -- BASE_CURRENCY
--5201086
           crh.exchange_rate_type,            -- EXCHANGE_RATE_TYPE
           crh.exchange_rate     ,            -- EXCHANGE_RATE
           crh.exchange_date     ,            -- EXCHANGE_DATE
           NVL(dist.acctd_amount_cr,0)
             - NVL(dist.acctd_amount_dr,0),      -- ACCTD_AMOUNT
           NVL(dist.taxable_accounted_cr,0)
             - NVL(dist.taxable_accounted_dr,0), -- TAXABLE_ACCTD_AMOUNT
           cr.org_id,                       -- ORG_ID
           app.receivable_application_id,    -- HEADER_TABLE_ID
--{Although the UNAPP and UNID are distributions created from RA the posting entity is CRH
-- but the source_table will be RA
           'CRH',                            -- POSTING_ENTITY
--}
           cr.cash_receipt_id,               -- CASH_RECEIPT_ID
           NULL,                             -- CUSTOMER_TRX_ID
           NULL,                             -- CUSTOMER_TRX_LINE_ID
           NULL,                             -- CUST_TRX_LINE_GL_DIST_ID
           NULL,                             -- CUST_TRX_LINE_SALESREP_ID
           NULL,                             -- INVENTORY_ITEM_ID
           NULL,                             -- SALES_TAX_ID
           NULL,                             -- SO_ORGANIZATION_ID
           NULL,                             -- TAX_EXEMPTION_ID
           NULL,                             -- UOM_CODE
           NULL,                             -- WAREHOUSE_ID
           NULL,                             -- AGREEMENT_ID
           NULL,                             -- CUSTOMER_BANK_ACCT_ID
           NULL,                             -- DRAWEE_BANK_ACCOUNT_ID
           NULL,                             -- REMITTANCE_BANK_ACCT_ID
           NULL,                             -- DISTRIBUTION_SET_ID
           NULL,                             -- PAYMENT_SCHEDULE_ID
           NULL,                             -- RECEIPT_METHOD_ID
           app.receivables_trx_id,           -- RECEIVABLES_TRX_ID
           NULL,                             -- ED_ADJ_RECEIVABLES_TRX_ID
           NULL,                             -- UNED_RECEIVABLES_TRX_ID
           sob.set_of_books_id,              -- SET_OF_BOOKS_ID
           NULL,                               -- SALESREP_ID
           NULL,                               -- BILL_SITE_USE_ID
           NULL,                               -- DRAWEE_SITE_USE_ID
           NULL,                               -- PAYING_SITE_USE_ID
           NULL,                               -- SOLD_SITE_USE_ID
           NULL,                               -- SHIP_SITE_USE_ID
           NULL,                               -- RECEIPT_CUSTOMER_SITE_USE_ID
           NULL,                               -- BILL_CUST_ROLE_ID
           NULL,                               -- DRAWEE_CUST_ROLE_ID
           NULL,                               -- SHIP_CUST_ROLE_ID
           NULL,                               -- SOLD_CUST_ROLE_ID
           NULL,                               -- BILL_CUSTOMER_ID
           NULL,                               -- DRAWEE_CUSTOMER_ID
           NULL,                               -- PAYING_CUSTOMER_ID
           NULL,                               -- SOLD_CUSTOMER_ID
           NULL,                               -- SHIP_CUSTOMER_ID
           NULL,                               -- REMIT_ADDRESS_ID
           NULL,                               -- RECEIPT_BATCH_ID
           app.receivable_application_id,      -- RECEIVABLE_APPLICATION_ID
           NULL,                               -- CUSTOMER_BANK_BRANCH_ID
           NULL,                               -- ISSUER_BANK_BRANCH_ID
           NULL,                               -- BATCH_SOURCE_ID
           NULL,                               -- BATCH_ID
           NULL,                               -- TERM_ID
           'N',                              -- SELECT_FLAG
           'L',                              -- LEVEL_FLAG
           '' ,                               -- FROM_TO_FLAG
           app.status,                        -- CRH_STATUS
           '',                               -- CRH_PRV_STATUS
           NVL(dist.amount_cr,0)
             - NVL(dist.amount_dr,0)           -- AMOUNT
         --{BUG#4356088
         ,gt.event_type_code
         ,gt.event_class_code
         ,gt.entity_code
         ,'N'                    --MFAR_ADDITIONAL_ENTRY
         --}
         --Bug7255483 Added value for new column in the view
         ,DECODE(NVL(app.receivables_trx_id,0), -16,
                 NVL(dist.from_acctd_amount_cr,0) - NVL(dist.from_acctd_amount_dr,0),to_number(NULL))
      FROM xla_events_gt                  gt,
           ar_cash_receipts_all           cr,
           ar_cash_receipt_history_all    crh,
           ar_receivable_applications_all app,
           ar_distributions_all           dist,
           gl_sets_of_books               sob
     WHERE gt.event_type_code IN (  'RECP_CREATE'          ,'RECP_UPDATE' ,
                                    'RECP_RATE_ADJUST'     ) --Uptake XLA Reversal,'RECP_REVERSE'   )
       AND gt.application_id              = p_application_id
       AND cr.cash_receipt_id             = gt.source_id_int_1
       AND gt.event_id                    = app.event_id
       AND app.status                    IN ('UNAPP','UNID',
                     --{BUG#4960533
                      'OTHER ACC',
                      'ACC','BANK_CHARGES','ACTIVITY','SHORT_TERM_DEBT')
                     --}
       AND dist.source_table              = 'RA'
       AND dist.source_id                 = app.receivable_application_id
       AND cr.set_of_books_id             = sob.set_of_books_id
   --  AND gt.event_id                    = crh.event_id(+)
       AND app.event_id                    = crh.event_id(+)
       AND app.cash_receipt_history_id     = crh.cash_receipt_history_id (+)
       AND crh.status(+)                  NOT IN ('REVERSED');




   local_log(procedure_name => 'load_line_data_crh',
             p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.load_line_date_crh ()-');
EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'load_line_data_crh',
             p_msg_text     => 'EXCEPTION OTHERS in arp_xla_extract_main_pkg.load_line_data_crh '||
                                arp_global.CRLF || 'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.load_line_data_crh'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;
END load_line_data_crh;

--------------------------------------------------------
/*-----------------------------------------------------------------+
 | Procedure Name : mfar_hook                                      |
 | Description    : Extract line data for Cash Receipt events in MF|
 +-----------------------------------------------------------------+
 | History        :                                                |
 +-----------------------------------------------------------------*/

PROCEDURE mfar_hook(p_ledger_id IN NUMBER)
IS
 CURSOR c IS
 SELECT NULL
   FROM gl_ledgers             gl,
        xla_acctg_method_rules mr,
        xla_product_rules_tl   pr
  WHERE gl.ledger_id = p_ledger_id
    AND mr.application_id = 222
    AND mr.accounting_method_code = gl.SLA_ACCOUNTING_METHOD_CODE
    AND mr.product_rule_code      = pr.product_rule_code
    AND mr.product_rule_code      = 'MFAR_ACCRUAL_ACCOUNT'
    AND pr.language = USERENV('LANG')
    AND SYSDATE BETWEEN mr.start_date_active AND NVL(mr.end_date_active, SYSDATE);
  l_res        VARCHAR2(1);
  l_execution  VARCHAR2(1) := 'N';
BEGIN
  local_log(procedure_name => 'mfar_hook',
            p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.mfar_hook ()+');
  IF NVL(FND_PROFILE.value('AR_MFAR_ACTIVATED'), 'N') = 'N' THEN
    l_execution := 'N';
  ELSE
    l_execution := 'Y';
  END IF;

  IF l_execution = 'Y' THEN
     -- Get all the applications of receipts being processed
     mfar_app_dist_cr;
     -- Get all CRH being currently post
     mfar_crh_dist;
     -- Create the times of additional distributions for CRH
     mfar_produit_app_by_crh;
     --Create additional_distribution_for_ra
     mfar_get_ra;
     --Avoid contention between Cash Receipt and MCD
     DELETE FROM ar_crh_app_gt;
     -- Get all Misc Cash Distributions for the Misc receipts
     mfar_mcd_dist_cr;
     -- Create the times of addition distribution for MCD
     mfar_produit_mcd_by_crh;
     -- Calculate and insert prorated MFAR additional entries for On-Account CM Applications
     mfar_cmapp_from_to;
     -- Calculate the currency rounding accounted amounts at line level for CM Apps
     mfar_cmapp_curr_round;
     -- Calculate the currency rounding accounted amounts at line level for RCT Apps
     mfar_rctapp_curr_round;

  END IF;
  local_log(procedure_name => 'mfar_hook',
            p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.mfar_hook ()-');
EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'mfar_hook',
             p_msg_text     => 'EXCEPTION OTHERS in mfar_hook '||
                 arp_global.CRLF || 'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.mfar_hook'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;
END mfar_hook;

/*
   Bug 9860123 - This procedure calculates line level currency rounding
   for credit memo applications for MFAR customers
*/

PROCEDURE mfar_cmapp_curr_round
IS
BEGIN

  local_log(procedure_name => 'mfar_reg_cmapp_curr_round',
               p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.mfar_reg_cmapp_curr_round ()+');

-- Insert MFAR CURR_ROUND rows for regular Credit Memos
INSERT INTO ar_xla_lines_extract (
 EVENT_ID
,LINE_NUMBER
,LANGUAGE
,LEDGER_ID
,SOURCE_ID
,SOURCE_TABLE
,LINE_ID
,TAX_CODE_ID
,LOCATION_SEGMENT_ID
,BASE_CURRENCY_CODE
,EXCHANGE_RATE_TYPE
,EXCHANGE_RATE
,EXCHANGE_DATE
,ACCTD_AMOUNT
,TAXABLE_ACCTD_AMOUNT
,ORG_ID
,HEADER_TABLE_ID
,POSTING_ENTITY
,CASH_RECEIPT_ID
,CUSTOMER_TRX_ID
,CUSTOMER_TRX_LINE_ID
,CUST_TRX_LINE_GL_DIST_ID
,CUST_TRX_LINE_SALESREP_ID
,INVENTORY_ITEM_ID
,SALES_TAX_ID
,SO_ORGANIZATION_ID
,TAX_EXEMPTION_ID
,UOM_CODE
,WAREHOUSE_ID
,AGREEMENT_ID
,CUSTOMER_BANK_ACCT_ID
,DRAWEE_BANK_ACCOUNT_ID
,REMITTANCE_BANK_ACCT_ID
,DISTRIBUTION_SET_ID
,PAYMENT_SCHEDULE_ID
,RECEIPT_METHOD_ID
,RECEIVABLES_TRX_ID
,ED_ADJ_RECEIVABLES_TRX_ID
,UNED_RECEIVABLES_TRX_ID
,SET_OF_BOOKS_ID
,SALESREP_ID
,BILL_SITE_USE_ID
,DRAWEE_SITE_USE_ID
,PAYING_SITE_USE_ID
,SOLD_SITE_USE_ID
,SHIP_SITE_USE_ID
,RECEIPT_CUSTOMER_SITE_USE_ID
,BILL_CUST_ROLE_ID
,DRAWEE_CUST_ROLE_ID
,SHIP_CUST_ROLE_ID
,SOLD_CUST_ROLE_ID
,BILL_CUSTOMER_ID
,DRAWEE_CUSTOMER_ID
,PAYING_CUSTOMER_ID
,SOLD_CUSTOMER_ID
,SHIP_CUSTOMER_ID
,REMIT_ADDRESS_ID
,RECEIPT_BATCH_ID
,RECEIVABLE_APPLICATION_ID
,CUSTOMER_BANK_BRANCH_ID
,ISSUER_BANK_BRANCH_ID
,BATCH_SOURCE_ID
,BATCH_ID
,TERM_ID
,SELECT_FLAG
,LEVEL_FLAG
,FROM_TO_FLAG
,CRH_STATUS
,CRH_PRV_STATUS
,AMOUNT
,FROM_AMOUNT
,FROM_ACCTD_AMOUNT
,PREV_FUND_SEG_REPLACE
,APP_CRH_STATUS
,PAIRED_CCID
,PAIRE_DIST_ID
,REF_DIST_CCID
,REF_MF_DIST_FLAG
,ORIGIN_EXTRACT_TABLE
,EVENT_TYPE_CODE
,EVENT_CLASS_CODE
,ENTITY_CODE
,REVERSAL_CODE
,BUSINESS_FLOW_CODE
,TAX_LINE_ID
,ADDITIONAL_CHAR1
,ADDITIONAL_CHAR2
,ADDITIONAL_CHAR3
,ADDITIONAL_CHAR4
,ADDITIONAL_CHAR5
,CM_APP_TO_TRX_LINE_ID
,ADDITIONAL_ID2
,ADDITIONAL_ID3
,ADDITIONAL_ID4
,ADDITIONAL_ID5
,XLA_ENTITY_ID
,REF_CTLGD_CCID
,DIST_CCID
,FROM_EXCHANGE_RATE
,FROM_EXCHANGE_RATE_TYPE
,FROM_EXCHANGE_DATE
,FROM_CURRENCY_CODE
,TO_CURRENCY_CODE
,MFAR_ADDITIONAL_ENTRY
,THIRD_PARTY_ID
,THIRD_PARTY_SITE_ID
,THIRD_PARTY_TYPE
,SOURCE_TYPE )
SELECT l.EVENT_ID
,-1 * ar_mfar_extract_s.nextval
,l.LANGUAGE
,l.LEDGER_ID
,l.SOURCE_ID
,l.SOURCE_TABLE
,l.LINE_ID
,l.TAX_CODE_ID
,l.LOCATION_SEGMENT_ID
,l.BASE_CURRENCY_CODE
,l.EXCHANGE_RATE_TYPE
,l.EXCHANGE_RATE
,l.EXCHANGE_DATE
,curr.ACCTD_AMT
,l.TAXABLE_ACCTD_AMOUNT
,l.ORG_ID
,l.HEADER_TABLE_ID
,l.POSTING_ENTITY
,l.CASH_RECEIPT_ID
,l.CUSTOMER_TRX_ID
,l.CUSTOMER_TRX_LINE_ID
,l.CUST_TRX_LINE_GL_DIST_ID
,l.CUST_TRX_LINE_SALESREP_ID
,l.INVENTORY_ITEM_ID
,l.SALES_TAX_ID
,l.SO_ORGANIZATION_ID
,l.TAX_EXEMPTION_ID
,l.UOM_CODE
,l.WAREHOUSE_ID
,l.AGREEMENT_ID
,l.CUSTOMER_BANK_ACCT_ID
,l.DRAWEE_BANK_ACCOUNT_ID
,l.REMITTANCE_BANK_ACCT_ID
,l.DISTRIBUTION_SET_ID
,l.PAYMENT_SCHEDULE_ID
,l.RECEIPT_METHOD_ID
,l.RECEIVABLES_TRX_ID
,l.ED_ADJ_RECEIVABLES_TRX_ID
,l.UNED_RECEIVABLES_TRX_ID
,l.SET_OF_BOOKS_ID
,l.SALESREP_ID
,l.BILL_SITE_USE_ID
,l.DRAWEE_SITE_USE_ID
,l.PAYING_SITE_USE_ID
,l.SOLD_SITE_USE_ID
,l.SHIP_SITE_USE_ID
,l.RECEIPT_CUSTOMER_SITE_USE_ID
,l.BILL_CUST_ROLE_ID
,l.DRAWEE_CUST_ROLE_ID
,l.SHIP_CUST_ROLE_ID
,l.SOLD_CUST_ROLE_ID
,l.BILL_CUSTOMER_ID
,l.DRAWEE_CUSTOMER_ID
,l.PAYING_CUSTOMER_ID
,l.SOLD_CUSTOMER_ID
,l.SHIP_CUSTOMER_ID
,l.REMIT_ADDRESS_ID
,l.RECEIPT_BATCH_ID
,l.RECEIVABLE_APPLICATION_ID
,l.CUSTOMER_BANK_BRANCH_ID
,l.ISSUER_BANK_BRANCH_ID
,l.BATCH_SOURCE_ID
,l.BATCH_ID
,l.TERM_ID
,l.SELECT_FLAG
,l.LEVEL_FLAG
,l.FROM_TO_FLAG
,l.CRH_STATUS
,l.CRH_PRV_STATUS
,curr.AMOUNT
,curr.FROM_AMOUNT
,curr.FROM_ACCTD_AMT
,l.PREV_FUND_SEG_REPLACE
,l.APP_CRH_STATUS
,l.PAIRED_CCID
,l.PAIRE_DIST_ID
,l.REF_DIST_CCID
,l.REF_MF_DIST_FLAG
,l.ORIGIN_EXTRACT_TABLE
,l.EVENT_TYPE_CODE
,l.EVENT_CLASS_CODE
,l.ENTITY_CODE
,l.REVERSAL_CODE
,l.BUSINESS_FLOW_CODE
,l.TAX_LINE_ID
,l.ADDITIONAL_CHAR1
,l.ADDITIONAL_CHAR2
,l.ADDITIONAL_CHAR3
,l.ADDITIONAL_CHAR4
,l.ADDITIONAL_CHAR5
,l.CM_APP_TO_TRX_LINE_ID
,l.ADDITIONAL_ID2
,l.ADDITIONAL_ID3
,l.ADDITIONAL_ID4
,l.ADDITIONAL_ID5
,l.XLA_ENTITY_ID
,l.REF_CTLGD_CCID
,ard.code_combination_id
,l.FROM_EXCHANGE_RATE
,l.FROM_EXCHANGE_RATE_TYPE
,l.FROM_EXCHANGE_DATE
,l.FROM_CURRENCY_CODE
,l.TO_CURRENCY_CODE
,'Y'
,l.THIRD_PARTY_ID
,l.THIRD_PARTY_SITE_ID
,l.THIRD_PARTY_TYPE
,'CURR_ROUND'
FROM AR_XLA_LINES_EXTRACT l,
     (SELECT
      event_id,
      source_id,
      CM_APP_TO_TRX_LINE_ID,
      sum(-1*ACCTD_AMOUNT) ACCTD_AMT,
      sum(-1*FROM_ACCTD_AMOUNT) FROM_ACCTD_AMT,
      sum(AMOUNT) AMOUNT,
      sum(FROM_AMOUNT) FROM_AMOUNT
         FROM ar_xla_lines_extract
         WHERE POSTING_ENTITY = 'APP'
         AND CUSTOMER_TRX_LINE_ID is not null
         AND source_type = 'REC'
         AND MFAR_ADDITIONAL_ENTRY = 'N'
         GROUP BY event_id, source_id, CM_APP_TO_TRX_LINE_ID
         HAVING sum(ACCTD_AMOUNT)  <> 0 AND sum(AMOUNT) = 0
         ) curr,
        AR_DISTRIBUTIONS_ALL ard
WHERE l.MFAR_ADDITIONAL_ENTRY = 'N'
AND l.FROM_TO_FLAG = 'T'
AND l.LEVEL_FLAG = 'L'
AND l.event_id = curr.event_id
AND l.source_id = curr.source_id
AND l.CM_APP_TO_TRX_LINE_ID = curr.CM_APP_TO_TRX_LINE_ID
AND l.source_type = 'REC'
AND l.source_id = ard.source_id
AND ard.source_table = 'RA'
AND ard.source_type = 'CURR_ROUND';

-- Insert MFAR CURR_ROUND rows for on-account Credit Memos
INSERT INTO ar_xla_lines_extract (
 EVENT_ID
,LINE_NUMBER
,LANGUAGE
,LEDGER_ID
,SOURCE_ID
,SOURCE_TABLE
,LINE_ID
,TAX_CODE_ID
,LOCATION_SEGMENT_ID
,BASE_CURRENCY_CODE
,EXCHANGE_RATE_TYPE
,EXCHANGE_RATE
,EXCHANGE_DATE
,ACCTD_AMOUNT
,TAXABLE_ACCTD_AMOUNT
,ORG_ID
,HEADER_TABLE_ID
,POSTING_ENTITY
,CASH_RECEIPT_ID
,CUSTOMER_TRX_ID
,CUSTOMER_TRX_LINE_ID
,CUST_TRX_LINE_GL_DIST_ID
,CUST_TRX_LINE_SALESREP_ID
,INVENTORY_ITEM_ID
,SALES_TAX_ID
,SO_ORGANIZATION_ID
,TAX_EXEMPTION_ID
,UOM_CODE
,WAREHOUSE_ID
,AGREEMENT_ID
,CUSTOMER_BANK_ACCT_ID
,DRAWEE_BANK_ACCOUNT_ID
,REMITTANCE_BANK_ACCT_ID
,DISTRIBUTION_SET_ID
,PAYMENT_SCHEDULE_ID
,RECEIPT_METHOD_ID
,RECEIVABLES_TRX_ID
,ED_ADJ_RECEIVABLES_TRX_ID
,UNED_RECEIVABLES_TRX_ID
,SET_OF_BOOKS_ID
,SALESREP_ID
,BILL_SITE_USE_ID
,DRAWEE_SITE_USE_ID
,PAYING_SITE_USE_ID
,SOLD_SITE_USE_ID
,SHIP_SITE_USE_ID
,RECEIPT_CUSTOMER_SITE_USE_ID
,BILL_CUST_ROLE_ID
,DRAWEE_CUST_ROLE_ID
,SHIP_CUST_ROLE_ID
,SOLD_CUST_ROLE_ID
,BILL_CUSTOMER_ID
,DRAWEE_CUSTOMER_ID
,PAYING_CUSTOMER_ID
,SOLD_CUSTOMER_ID
,SHIP_CUSTOMER_ID
,REMIT_ADDRESS_ID
,RECEIPT_BATCH_ID
,RECEIVABLE_APPLICATION_ID
,CUSTOMER_BANK_BRANCH_ID
,ISSUER_BANK_BRANCH_ID
,BATCH_SOURCE_ID
,BATCH_ID
,TERM_ID
,SELECT_FLAG
,LEVEL_FLAG
,FROM_TO_FLAG
,CRH_STATUS
,CRH_PRV_STATUS
,AMOUNT
,FROM_AMOUNT
,FROM_ACCTD_AMOUNT
,PREV_FUND_SEG_REPLACE
,APP_CRH_STATUS
,PAIRED_CCID
,PAIRE_DIST_ID
,REF_DIST_CCID
,REF_MF_DIST_FLAG
,ORIGIN_EXTRACT_TABLE
,EVENT_TYPE_CODE
,EVENT_CLASS_CODE
,ENTITY_CODE
,REVERSAL_CODE
,BUSINESS_FLOW_CODE
,TAX_LINE_ID
,ADDITIONAL_CHAR1
,ADDITIONAL_CHAR2
,ADDITIONAL_CHAR3
,ADDITIONAL_CHAR4
,ADDITIONAL_CHAR5
,ADDITIONAL_ID1
,ADDITIONAL_ID2
,ADDITIONAL_ID3
,ADDITIONAL_ID4
,ADDITIONAL_ID5
,XLA_ENTITY_ID
,REF_CTLGD_CCID
,DIST_CCID
,FROM_EXCHANGE_RATE
,FROM_EXCHANGE_RATE_TYPE
,FROM_EXCHANGE_DATE
,FROM_CURRENCY_CODE
,TO_CURRENCY_CODE
,MFAR_ADDITIONAL_ENTRY
,THIRD_PARTY_ID
,THIRD_PARTY_SITE_ID
,THIRD_PARTY_TYPE
,SOURCE_TYPE )
SELECT l.EVENT_ID
,-1 * ar_mfar_extract_s.nextval
,l.LANGUAGE
,l.LEDGER_ID
,l.SOURCE_ID
,l.SOURCE_TABLE
,l.LINE_ID
,l.TAX_CODE_ID
,l.LOCATION_SEGMENT_ID
,l.BASE_CURRENCY_CODE
,l.EXCHANGE_RATE_TYPE
,l.EXCHANGE_RATE
,l.EXCHANGE_DATE
,curr.CURR_ROUND_ACCTD_AMT FROM_ACCTD_AMOUNT -- Currency Rounding Amount
,l.TAXABLE_ACCTD_AMOUNT
,l.ORG_ID
,l.HEADER_TABLE_ID
,l.POSTING_ENTITY
,l.CASH_RECEIPT_ID
,l.CUSTOMER_TRX_ID
,l.CUSTOMER_TRX_LINE_ID
,l.CUST_TRX_LINE_GL_DIST_ID
,l.CUST_TRX_LINE_SALESREP_ID
,l.INVENTORY_ITEM_ID
,l.SALES_TAX_ID
,l.SO_ORGANIZATION_ID
,l.TAX_EXEMPTION_ID
,l.UOM_CODE
,l.WAREHOUSE_ID
,l.AGREEMENT_ID
,l.CUSTOMER_BANK_ACCT_ID
,l.DRAWEE_BANK_ACCOUNT_ID
,l.REMITTANCE_BANK_ACCT_ID
,l.DISTRIBUTION_SET_ID
,l.PAYMENT_SCHEDULE_ID
,l.RECEIPT_METHOD_ID
,l.RECEIVABLES_TRX_ID
,l.ED_ADJ_RECEIVABLES_TRX_ID
,l.UNED_RECEIVABLES_TRX_ID
,l.SET_OF_BOOKS_ID
,l.SALESREP_ID
,l.BILL_SITE_USE_ID
,l.DRAWEE_SITE_USE_ID
,l.PAYING_SITE_USE_ID
,l.SOLD_SITE_USE_ID
,l.SHIP_SITE_USE_ID
,l.RECEIPT_CUSTOMER_SITE_USE_ID
,l.BILL_CUST_ROLE_ID
,l.DRAWEE_CUST_ROLE_ID
,l.SHIP_CUST_ROLE_ID
,l.SOLD_CUST_ROLE_ID
,l.BILL_CUSTOMER_ID
,l.DRAWEE_CUSTOMER_ID
,l.PAYING_CUSTOMER_ID
,l.SOLD_CUSTOMER_ID
,l.SHIP_CUSTOMER_ID
,l.REMIT_ADDRESS_ID
,l.RECEIPT_BATCH_ID
,l.RECEIVABLE_APPLICATION_ID
,l.CUSTOMER_BANK_BRANCH_ID
,l.ISSUER_BANK_BRANCH_ID
,l.BATCH_SOURCE_ID
,l.BATCH_ID
,l.TERM_ID
,l.SELECT_FLAG
,l.LEVEL_FLAG
,l.FROM_TO_FLAG
,l.CRH_STATUS
,l.CRH_PRV_STATUS
,(NVL(ard.amount_cr,0) - NVL(ard.amount_dr,0)) AMOUNT
,(NVL(ard.from_amount_cr,0) - NVL(ard.from_amount_dr,0)) FROM_AMOUNT
,curr.CURR_ROUND_ACCTD_AMT  FROM_ACCTD_AMOUNT -- Currency Rounding Amount
,l.PREV_FUND_SEG_REPLACE
,l.APP_CRH_STATUS
,l.PAIRED_CCID
,l.PAIRE_DIST_ID
,l.REF_DIST_CCID
,l.REF_MF_DIST_FLAG
,l.ORIGIN_EXTRACT_TABLE
,l.EVENT_TYPE_CODE
,l.EVENT_CLASS_CODE
,l.ENTITY_CODE
,l.REVERSAL_CODE
,l.BUSINESS_FLOW_CODE
,l.TAX_LINE_ID
,l.ADDITIONAL_CHAR1
,l.ADDITIONAL_CHAR2
,l.ADDITIONAL_CHAR3
,l.ADDITIONAL_CHAR4
,l.ADDITIONAL_CHAR5
,l.ADDITIONAL_ID1
,l.ADDITIONAL_ID2
,l.ADDITIONAL_ID3
,l.ADDITIONAL_ID4
,l.ADDITIONAL_ID5
,l.XLA_ENTITY_ID
,l.REF_CTLGD_CCID
,ard.code_combination_id
,l.FROM_EXCHANGE_RATE
,l.FROM_EXCHANGE_RATE_TYPE
,l.FROM_EXCHANGE_DATE
,l.FROM_CURRENCY_CODE
,l.TO_CURRENCY_CODE
,'Y'
,l.THIRD_PARTY_ID
,l.THIRD_PARTY_SITE_ID
,l.THIRD_PARTY_TYPE
,ard.source_type
FROM AR_XLA_LINES_EXTRACT l,
     AR_DISTRIBUTIONS_ALL ard,
     (select event_id,
             source_id,
               LINE_ID,
               sum(-1*ACCTD_AMOUNT) CURR_ROUND_ACCTD_AMT
       from ar_xla_lines_extract
       where POSTING_ENTITY = 'APP'
       AND CUSTOMER_TRX_LINE_ID is not null
       AND ((MFAR_ADDITIONAL_ENTRY = 'Y')
       OR (MFAR_ADDITIONAL_ENTRY = 'N' AND FROM_TO_FLAG = 'T'))
       group by event_id, source_id, LINE_ID
       having sum(-1*ACCTD_AMOUNT) <> 0) curr
WHERE l.MFAR_ADDITIONAL_ENTRY = 'N'
AND l.FROM_TO_FLAG = 'T'
AND l.CUSTOMER_TRX_LINE_ID IS NOT NULL
AND l.CM_APP_TO_TRX_LINE_ID IS NULL
AND nvl(l.Source_Type, 'XX') <> 'CURR_ROUND'
AND curr.source_id = ard.source_id
AND ard.source_type = 'CURR_ROUND'
AND ard.source_table = 'RA'
AND l.line_id = curr.line_id
AND l.event_id = curr.event_id
AND l.source_id = curr.source_id;

  local_log(procedure_name => 'mfar_reg_cmapp_curr_round',
              p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.mfar_reg_cmapp_curr_round ()-');

  EXCEPTION
  --  WHEN NO_DATA_FOUND THEN NULL;
    WHEN OTHERS THEN
     local_log(procedure_name => 'mfar_reg_cmapp_curr_round',
               p_msg_text     => 'EXCEPTION OTHERS in mfar_reg_cmapp_curr_round '||
                   arp_global.CRLF || 'Error      :'|| SQLERRM);
      FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE' ,
           'Procedure :arp_xla_extract_main_pkg.mfar_reg_cmapp_curr_round'|| arp_global.CRLF||
           'Error     :'||SQLERRM);
      FND_MSG_PUB.ADD;
    RAISE;
END;


/*

  Procedure to form the CM and Invoice REC records

*/
PROCEDURE mfar_cmapp_from_to is

   l_ar_cm_from_tab ar_cm_from_tab;
   l_ar_cm_to_tab  ar_cm_to_tab;

  cursor ar_cm_from_cur is
  SELECT xla.entity_id                           --entity_id
        ,ra.receivable_application_id            --receivable_application_id
        ,ard.line_id                             --line_id
        ,ard.source_type                         --source_type
        ,ra.customer_trx_id                      --customer_trx_id
        ,NVL(ard.amount_cr,0)-
            NVL(ard.amount_dr,0)                --amount
       ,NVL(ard.acctd_amount_cr,0)-
           NVL(ard.acctd_amount_dr,0)          --acctd_amount
       ,NVL(sign(ra.amount_applied)*ra.amount_applied,0)                      --amount_applied_from
       ,NVL(sign(ra.acctd_amount_applied_from)*ra.acctd_amount_applied_from,0)           --acctd_amount_applied_from
       ,ard.code_combination_id                 --code_combination_id
       ,ard.currency_conversion_date             --exchange_date
       ,ard.currency_conversion_rate             --exchange_rate
       ,ard.currency_conversion_type             --exchange_type
       ,ard.third_party_id                      --third_party_id
       ,ard.third_party_sub_id                  --third_party_site_id
       ,ra.event_id                             --event_id
       ,ra.set_of_books_id                      --ledger_id
       ,ard.currency_code                       --currency_code
       ,ra.org_id                               --org_id
       ,sob.currency_code                       --base currency code
 FROM  ar_receivable_applications_all ra
      ,ar_distributions_all           ard
      ,(SELECT entity_id,
               source_id_int_1,
               event_id,
               ledger_id
          FROM xla_events_gt
         WHERE application_id  = 222
           AND event_type_code IN ('CM_CREATE','CM_UPDATE')
         GROUP BY entity_id,
                  source_id_int_1,
                  event_id,
                  ledger_id)    xla
      ,gl_sets_of_books sob
 WHERE xla.source_id_int_1 = ra.customer_trx_id
 AND   xla.event_id = ra.event_id
 AND   ra.status = 'APP'
 AND   ra.receivable_application_id = ard.source_id
 AND   xla.ledger_id = sob.set_of_books_id
 AND   ard.source_table = 'RA'
 AND   ard.source_type = 'REC'
 AND   ard.REF_PREV_CUST_TRX_LINE_ID is NULL
 AND   ard.source_type NOT IN ('EXCH_GAIN','EXCH_LOSS','EDISC','UNEDISC','EDISC_NON_REC_TAX','UNEDISC_NON_REC_TAX','DEFERRED_TAX','TAX')
 AND ( ard.ref_cust_trx_line_gl_dist_id IS NOT NULL
                          AND ard.ref_cust_trx_line_gl_dist_id IN (SELECT cust_trx_line_gl_dist_id
                                                         FROM ra_cust_trx_line_gl_dist_all ctlgd
                                                         WHERE ctlgd.customer_trx_id =  ra.customer_trx_id)) -- Select only FROM rows which belong to Credit Memo
ORDER BY ra.receivable_application_id, ard.line_id;


  CURSOR ar_cm_to_cur is
  SELECT xla.entity_id                           --entity_id
        ,ra.receivable_application_id            --receivable_application_id
        ,ard.line_id                             --line_id
        ,NVL(ard.amount_cr,0)-
             NVL(ard.amount_dr,0)                --amount
       ,NVL(ard.acctd_amount_cr,0)-
           NVL(ard.acctd_amount_dr,0)          --acctd_amount
      ,NVL(ard.from_amount_cr,0)-
           NVL(ard.from_amount_dr,0)           --from_amount
      ,NVL(ard.from_acctd_amount_cr,0)-
           NVL(ard.from_acctd_amount_dr,0)     --from_acctd_amount
      ,ard.third_party_id                      --third_party_id
      ,ard.third_party_sub_id                  --third_party_site_id
      ,DECODE(ard.third_party_id,NULL,NULL,'C') --third_party_type
      ,ard.currency_code                        -- currency_code
      ,ard.currency_conversion_rate             --exchange_rate
      ,ard.currency_conversion_type             --exchange_type
      ,ard.currency_conversion_date             --exchange_date
      ,ard.ref_customer_trx_line_id             --ref_customer_trx_line_id
      ,ard.ref_cust_trx_line_gl_dist_id         --ref_cust_trx_line_gl_dist_id
      ,ard.code_combination_id                  --code_combination_id
      ,ard.ref_dist_ccid                       --ref_dist_ccid
      ,ard.activity_bucket                     --activity_bucket
      ,ard.source_type                         --source_type
      ,ard.source_table                            --source_table
      ,DECODE(ra.posting_control_id,-3,'N','Y')   --ra_post_indicator
      ,ra.applied_customer_trx_id              --customer_trx_id
      ,ctl.inventory_item_id                     --inventory_item_id
      ,ctl.sales_tax_id                           --sales_tax_id
      ,ctl.tax_line_id                            --tax_line_id
      ,ct.bill_to_customer_id                     --bill_to_customer_id
      ,ct.bill_to_site_use_id                     --bill_to_site_use_id
      ,ct.sold_to_customer_id                     --sold_to_customer_id
      ,ct.sold_to_site_use_id                     --sold_to_site_use_id
      ,ct.ship_to_customer_id                     --ship_to_customer_id
      ,ct.ship_to_site_use_id                     --ship_to_site_use_id
FROM ar_receivable_applications_all ra
      ,ar_distributions_all           ard
      ,ra_customer_trx_all            ct
      ,ra_customer_trx_lines_all      ctl
      ,(SELECT entity_id,
               source_id_int_1,
               event_id
          FROM xla_events_gt
         WHERE application_id  = 222
           AND event_type_code IN ('CM_CREATE','CM_UPDATE')
         GROUP BY entity_id,
                  source_id_int_1,
                  event_id)    xla
WHERE xla.source_id_int_1 = ra.customer_trx_id
AND   xla.event_id = ra.event_id
AND   ra.status = 'APP'
AND   ra.receivable_application_id = ard.source_id
AND   ard.source_table = 'RA'
AND   ard.source_type = 'REC'
AND   ard.REF_PREV_CUST_TRX_LINE_ID is NULL
AND   ra.applied_customer_trx_id = ct.customer_trx_id
AND   ct.customer_trx_id = ctl.customer_trx_id
AND   ctl.customer_trx_line_id = ard.ref_customer_trx_line_id
AND ard.source_type NOT IN ('EXCH_GAIN','EXCH_LOSS','EDISC','UNEDISC','EDISC_NON_REC_TAX','UNEDISC_NON_REC_TAX','DEFERRED_TAX','TAX')
AND ( ard.ref_cust_trx_line_gl_dist_id IS NOT NULL
                          AND ard.ref_cust_trx_line_gl_dist_id IN (SELECT cust_trx_line_gl_dist_id
                                                         FROM ra_cust_trx_line_gl_dist_all ctlgd
                                                         WHERE ctlgd.customer_trx_id =  ra.applied_customer_trx_id)) -- Select only TO rows which belong to Invoice
ORDER BY ra.receivable_application_id, ard.line_id;
begin
  local_log(procedure_name => 'mfar_cmapp_from_to',
               p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.mfar_cmapp_from_to ()+');

  -- Fetch the data of ar_cm_from_gt to the record l_ar_cm_from_tab
  open ar_cm_from_cur;
  loop
    fetch ar_cm_from_cur bulk collect into l_ar_cm_from_tab LIMIT MAX_ARRAY_SIZE;
    exit when ar_cm_from_cur%NOTFOUND;
  end loop;
  close ar_cm_from_cur;
  local_log(procedure_name => 'mfar_cmapp_from_to',
               p_msg_text     => 'l_ar_cm_from_tab.count:'|| l_ar_cm_from_tab.count);

  -- Fetch the data of ar_cm_from_gt to the record l_ar_cm_to_tab
  open ar_cm_to_cur;
  loop
    fetch ar_cm_to_cur bulk collect into l_ar_cm_to_tab LIMIT MAX_ARRAY_SIZE;
    exit when ar_cm_to_cur%NOTFOUND;
  end loop;
  close ar_cm_to_cur;
  local_log(procedure_name => 'mfar_cmapp_from_to',
               p_msg_text     => 'l_ar_cm_to_tab.count:'|| l_ar_cm_to_tab.count);

  IF l_ar_cm_from_tab.count > 0 AND l_ar_cm_to_tab.count > 0 THEN
      mfar_cm_app_insert_extract(l_ar_cm_from_tab, l_ar_cm_to_tab);
  END IF;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN NULL;
   WHEN OTHERS THEN
    local_log(procedure_name => 'mfar_cmapp_from_to',
              p_msg_text     => 'EXCEPTION OTHERS in mfar_cmapp_from_to '||
                  arp_global.CRLF || 'Error      :'|| SQLERRM);
     FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
     FND_MESSAGE.SET_TOKEN('MESSAGE' ,
          'Procedure :arp_xla_extract_main_pkg.mfar_cmapp_from_to'|| arp_global.CRLF||
          'Error     :'||SQLERRM);
     FND_MSG_PUB.ADD;
   RAISE;

END mfar_cmapp_from_to;

/*

Procedure to pro-rate the CM amount across the Invoice lines.

*/
PROCEDURE mfar_cm_app_insert_extract(p_ar_cm_from_rec IN ar_cm_from_tab, p_ar_cm_to_rec IN OUT NOCOPY ar_cm_to_tab) IS

-- run time variables for proration
  x_run_amt             number := 0;
  x_run_alloc_amt       number := 0;
  x_alloc_amt           number := 0;
  x_base_sum            number := 0;
  x_applied_amount      number := 0;
  x_base_acctd_sum      number := 0;
  x_applied_acctd_amount      number := 0;

  x_run_acctd_amt       number := 0;
  x_run_alloc_acctd_amt number := 0;
  x_alloc_acctd_amt     number := 0;

  i                     number := 0;
  j                     number := 0;
  k                     number := 1;
  x_app_id              number := 0;

  -- pl/sql table for ar_xla_lines_extract
   TYPE ar_xla_mfar_extract_gt_tab IS TABLE OF ar_xla_lines_extract%ROWTYPE
      INDEX BY BINARY_INTEGER;
   l_cm_app_mfar_extract_tab ar_xla_mfar_extract_gt_tab;

BEGIN

  local_log(procedure_name => 'mfar_cm_app_insert_extract',
              p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.mfar_cm_app_insert_extract()+');

FOR i in p_ar_cm_from_rec.FIRST..p_ar_cm_from_rec.LAST
LOOP

  x_run_amt       := 0;
  x_run_alloc_amt := 0;
  x_run_acctd_amt       := 0;
  x_run_alloc_acctd_amt := 0;

  if p_ar_cm_from_rec(i).receivable_application_id <> x_app_id then
    x_applied_amount := p_ar_cm_from_rec(i).amount_applied_from;
    x_applied_acctd_amount := p_ar_cm_from_rec(i).acctd_amount_applied_from;
  else
    x_applied_amount := abs(x_base_sum);
    x_applied_acctd_amount := abs(x_base_acctd_sum);
  end if;

  x_base_sum := 0;
  x_base_acctd_sum := 0;

  x_app_id := p_ar_cm_from_rec(i).receivable_application_id;

  local_log(procedure_name => 'mfar_cm_app_insert_extract',
              p_msg_text     => 'CM Line '||i||' Amount: '||p_ar_cm_from_rec(i).acctd_amount);

  FOR j in p_ar_cm_to_rec.FIRST..p_ar_cm_to_rec.LAST
  LOOP

       if p_ar_cm_from_rec(i).entity_id = p_ar_cm_to_rec(j).entity_id
          and p_ar_cm_from_rec(i).receivable_application_id = p_ar_cm_to_rec(j).receivable_application_id then

           IF x_applied_amount <> 0 THEN

            local_log(procedure_name => 'mfar_cm_app_insert_extract',
                        p_msg_text     => 'Invoice Line '||j||' Amount: '||p_ar_cm_to_rec(j).from_acctd_amount);

           -- Proration of Amounts
           x_run_amt       := x_run_amt + p_ar_cm_to_rec(j).from_amount;
           x_alloc_amt     := ar_unposted_item_util.currRound((x_run_amt/x_applied_amount)
                                    * sign(p_ar_cm_to_rec(j).from_amount) * p_ar_cm_from_rec(i).amount ,p_ar_cm_from_rec(i).CURRENCY_CODE)
                                         - x_run_alloc_amt;
           x_run_alloc_amt := x_run_alloc_amt + x_alloc_amt;
           p_ar_cm_to_rec(j).from_amount := p_ar_cm_to_rec(j).from_amount + x_alloc_amt;
           x_base_sum := x_base_sum + p_ar_cm_to_rec(j).from_amount;

           -- Proration of Accounted Amounts
           x_run_acctd_amt       := x_run_acctd_amt +  p_ar_cm_to_rec(j).from_acctd_amount;
           x_alloc_acctd_amt     := ar_unposted_item_util.currRound((x_run_acctd_amt/x_applied_acctd_amount)
                                               * sign(p_ar_cm_to_rec(j).from_acctd_amount) * p_ar_cm_from_rec(i).acctd_amount ,p_ar_cm_from_rec(i).CURRENCY_CODE) - x_run_alloc_acctd_amt;
           x_run_alloc_acctd_amt := x_run_alloc_acctd_amt + x_alloc_acctd_amt;
           p_ar_cm_to_rec(j).from_acctd_amount := p_ar_cm_to_rec(j).from_acctd_amount + x_alloc_acctd_amt;
           x_base_acctd_sum := x_base_acctd_sum + p_ar_cm_to_rec(j).from_acctd_amount;

           local_log(procedure_name => 'mfar_cm_app_insert_extract',
                      p_msg_text     => 'Prorated Amount: '||x_alloc_acctd_amt);

           END IF;

            -- Assign the values to extract table
            l_cm_app_mfar_extract_tab(k).EVENT_ID                := p_ar_cm_from_rec(i).EVENT_ID;
            l_cm_app_mfar_extract_tab(k).LINE_NUMBER             := -1 * ar_mfar_extract_s.nextval;
            l_cm_app_mfar_extract_tab(k).MFAR_ADDITIONAL_ENTRY   := 'Y';
            l_cm_app_mfar_extract_tab(k).LEDGER_ID               := p_ar_cm_from_rec(i).LEDGER_ID;
            l_cm_app_mfar_extract_tab(k).BASE_CURRENCY_CODE      := p_ar_cm_from_rec(i).base_currency_code;
            l_cm_app_mfar_extract_tab(k).ORG_ID                  := p_ar_cm_from_rec(i).ORG_ID;
            l_cm_app_mfar_extract_tab(k).LINE_ID                 := p_ar_cm_to_rec(j).LINE_ID;
            l_cm_app_mfar_extract_tab(k).SOURCE_ID               := p_ar_cm_from_rec(i).receivable_application_id;
            l_cm_app_mfar_extract_tab(k).SOURCE_TABLE            := 'RA';
            l_cm_app_mfar_extract_tab(k).HEADER_TABLE_ID         := p_ar_cm_from_rec(i).receivable_application_id;
            l_cm_app_mfar_extract_tab(k).POSTING_ENTITY          := 'APP';
            l_cm_app_mfar_extract_tab(k).XLA_ENTITY_ID           := p_ar_cm_to_rec(j).ENTITY_ID;
        --
            l_cm_app_mfar_extract_tab(k).DIST_CCID               := p_ar_cm_to_rec(j).code_combination_id;
            l_cm_app_mfar_extract_tab(k).REF_DIST_CCID           := p_ar_cm_to_rec(j).ref_dist_ccid;

        --
            l_cm_app_mfar_extract_tab(k).FROM_CURRENCY_CODE      := p_ar_cm_from_rec(i).CURRENCY_CODE;
            l_cm_app_mfar_extract_tab(k).FROM_EXCHANGE_RATE      := p_ar_cm_from_rec(i).EXCHANGE_RATE;
            l_cm_app_mfar_extract_tab(k).FROM_EXCHANGE_RATE_TYPE := p_ar_cm_from_rec(i).EXCHANGE_RATE_TYPE;
            l_cm_app_mfar_extract_tab(k).FROM_EXCHANGE_DATE      := p_ar_cm_from_rec(i).EXCHANGE_DATE;
        --
            l_cm_app_mfar_extract_tab(k).TO_CURRENCY_CODE        := p_ar_cm_from_rec(i).CURRENCY_CODE;
            l_cm_app_mfar_extract_tab(k).EXCHANGE_RATE           := p_ar_cm_from_rec(i).EXCHANGE_RATE;
            l_cm_app_mfar_extract_tab(k).EXCHANGE_RATE_TYPE      := p_ar_cm_from_rec(i).EXCHANGE_RATE_TYPE;
            l_cm_app_mfar_extract_tab(k).EXCHANGE_DATE           := p_ar_cm_from_rec(i).EXCHANGE_DATE;
            l_cm_app_mfar_extract_tab(k).AMOUNT                  := x_alloc_amt;
            l_cm_app_mfar_extract_tab(k).ACCTD_AMOUNT            := x_alloc_acctd_amt;
        --
            l_cm_app_mfar_extract_tab(k).RECEIVABLE_APPLICATION_ID := p_ar_cm_to_rec(j).RECEIVABLE_APPLICATION_ID;
            l_cm_app_mfar_extract_tab(k).CUSTOMER_TRX_ID           := p_ar_cm_from_rec(i).CUSTOMER_TRX_ID;
            l_cm_app_mfar_extract_tab(k).CUSTOMER_TRX_LINE_ID      := p_ar_cm_to_rec(j).ref_customer_trx_line_id;
            l_cm_app_mfar_extract_tab(k).CUST_TRX_LINE_GL_DIST_ID  := p_ar_cm_to_rec(j).ref_cust_trx_line_gl_dist_id;
        --
            l_cm_app_mfar_extract_tab(k).INVENTORY_ITEM_ID         := p_ar_cm_to_rec(j).INVENTORY_ITEM_ID;
            l_cm_app_mfar_extract_tab(k).SALES_TAX_ID              := p_ar_cm_to_rec(j).SALES_TAX_ID;
            l_cm_app_mfar_extract_tab(k).SET_OF_BOOKS_ID           := p_ar_cm_from_rec(i).ledger_id;
            l_cm_app_mfar_extract_tab(k).BILL_SITE_USE_ID          := p_ar_cm_to_rec(j).bill_to_site_use_id;
            l_cm_app_mfar_extract_tab(k).SOLD_SITE_USE_ID          := p_ar_cm_to_rec(j).sold_to_site_use_id;
            l_cm_app_mfar_extract_tab(k).SHIP_SITE_USE_ID          := p_ar_cm_to_rec(j).ship_to_site_use_id;
            l_cm_app_mfar_extract_tab(k).BILL_CUSTOMER_ID          := p_ar_cm_to_rec(j).bill_to_customer_id;
            l_cm_app_mfar_extract_tab(k).SOLD_CUSTOMER_ID          := p_ar_cm_to_rec(j).sold_to_customer_id;
            l_cm_app_mfar_extract_tab(k).SHIP_CUSTOMER_ID          := p_ar_cm_to_rec(j).ship_to_customer_id;
            l_cm_app_mfar_extract_tab(k).TAX_LINE_ID               := p_ar_cm_to_rec(j).tax_line_id;
        --
            l_cm_app_mfar_extract_tab(k).SELECT_FLAG               := 'Y';
            l_cm_app_mfar_extract_tab(k).LEVEL_FLAG                := 'L';
            l_cm_app_mfar_extract_tab(k).FROM_TO_FLAG              := 'F';
        --
        --  l_cm_app_mfar_extract_tab(k).EVENT_TYPE_CODE           := p_cm_app_extract_record(i).EVENT_TYPE_CODE;
            l_cm_app_mfar_extract_tab(k).EVENT_CLASS_CODE          := 'CREDIT_MEMO';
            l_cm_app_mfar_extract_tab(k).ENTITY_CODE               := 'TRANSACTIONS';
        --
            l_cm_app_mfar_extract_tab(k).third_party_id            := p_ar_cm_to_rec(j).third_party_id;
            l_cm_app_mfar_extract_tab(k).third_party_site_id       := p_ar_cm_to_rec(j).third_party_site_id;
            l_cm_app_mfar_extract_tab(k).third_party_type          := p_ar_cm_to_rec(j).third_party_type;
            l_cm_app_mfar_extract_tab(k).source_type               := p_ar_cm_to_rec(j).source_type;
            l_cm_app_mfar_extract_tab(k).paire_dist_id             := p_ar_cm_from_rec(i).line_id;

        k := k+1;
       end if;

  END LOOP;

END LOOP;

  FORALL r IN l_cm_app_mfar_extract_tab.first..l_cm_app_mfar_extract_tab.last
       INSERT INTO ar_xla_lines_extract VALUES l_cm_app_mfar_extract_tab(r);

  local_log(procedure_name => 'mfar_cm_app_insert_extract',
              p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.mfar_cm_app_insert_extract()-');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
    WHEN OTHERS THEN
     local_log(procedure_name => 'mfar_cm_app_insert_extract',
               p_msg_text     => 'EXCEPTION OTHERS in mfar_cm_app_insert_extract '||
                   arp_global.CRLF || 'Error      :'|| SQLERRM);
      FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE' ,
           'Procedure :arp_xla_extract_main_pkg.mfar_cm_app_insert_extract'|| arp_global.CRLF||
           'Error     :'||SQLERRM);
      FND_MSG_PUB.ADD;
    RAISE;


end mfar_cm_app_insert_extract;


PROCEDURE mfar_app_dist_cr IS
BEGIN
  local_log(procedure_name => 'mfar_app_dist_cr',
            p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.mfar_app_dist_cr ()+');
--
-- For a RECP_CREATE and RECP_UPDATE events
-- All application distributions are necessary for the MFAR CRH building
--
INSERT INTO ar_crh_app_gt (
 entity_id
,receivable_application_id
,cash_receipt_history_id
,cash_receipt_history_status
,line_id
,amount
,acctd_amount
,from_amount
,from_acctd_amount
,third_party_id
,third_party_site_id
,third_party_type
,from_currency_code
,from_exchange_rate
,from_exchange_type
,from_exchange_date
,to_currency_code
,to_exchange_rate
,to_exchange_type
,to_exchange_date
,ref_customer_trx_line_id
,ref_cust_trx_line_gl_dist_id
,code_combination_id
,ref_code_combination_id
,ref_dist_ccid
,activity_bucket
,source_type
,source_table
,ra_post_indicator
,crh_post_indicator
,customer_trx_id
,inventory_item_id
,sales_tax_id
,tax_line_id
,bill_to_customer_id
,bill_to_site_use_id
,sold_to_customer_id
,sold_to_site_use_id
,ship_to_customer_id
,ship_to_site_use_id
,event_id)
SELECT xla.entity_id                           --entity_id
      ,ra.receivable_application_id            --receivable_application_id
      ,crh.cash_receipt_history_id             --cash_receipt_history_id
      ,crh.status                              --cash_receipt_history_status
      ,ard.line_id                             --line_id
      ,NVL(ard.amount_cr,0)-
           NVL(ard.amount_dr,0)                --amount
      ,NVL(ard.acctd_amount_cr,0)-
           NVL(ard.acctd_amount_dr,0)          --acctd_amount
      ,NVL(ard.from_amount_cr,0)-
           NVL(ard.from_amount_dr,0)           --from_amount
      ,NVL(ard.from_acctd_amount_cr,0)-
           NVL(ard.from_acctd_amount_dr,0)     --from_acctd_amount
      ,ard.third_party_id                      --third_party_id
      ,ard.third_party_sub_id                  --third_party_site_id
      ,DECODE(ard.third_party_id,NULL,NULL,'C') --third_party_type
      ,cr.currency_code                        --from_currency_code
      ,crh.exchange_rate                       --from_exchange_rate
      ,crh.exchange_rate_type                  --from_exchange_type
      ,crh.exchange_date                       --from_exchange_date
      ,ct.invoice_currency_code                --to_currency_code
      ,ct.exchange_rate                        --to_exchange_rate
      ,ct.exchange_rate_type                   --to_exchange_type
      ,ct.exchange_date                        --to_exchange_date
      ,ard.ref_customer_trx_line_id            --ref_customer_trx_line_id
      ,ard.ref_cust_trx_line_gl_dist_id        --ref_cust_trx_line_gl_dist_id
      ,ard.code_combination_id                 --code_combination_id
      ,ctlgd.code_combination_id               --ref_code_combination_id
      ,ard.ref_dist_ccid                       --ref_dist_ccid
      ,ard.activity_bucket                     --activity_bucket
      ,ard.source_type                         --source_type
      ,source_table                            --source_table
      ,DECODE(ra.posting_control_id,-3,'N','Y')   --ra_post_indicator
      ,DECODE(crh.posting_control_id,-3,'N','Y')  --crh_post_indicator
      ,ra.applied_customer_trx_id              --customer_trx_id
      ,ctl.inventory_item_id
      ,ctl.sales_tax_id
      ,ctl.tax_line_id
      ,ct.bill_to_customer_id
      ,ct.bill_to_site_use_id
      ,ct.sold_to_customer_id
      ,ct.sold_to_site_use_id
      ,ct.ship_to_customer_id
      ,ct.ship_to_site_use_id
      ,ra.event_id
  FROM ar_cash_receipt_history_all    crh
      ,ar_cash_receipts_all           cr
      ,ar_receivable_applications_all ra
      ,ar_distributions_all           ard
      ,ra_customer_trx_all            ct
      ,ra_cust_trx_line_gl_dist_all   ctlgd
      ,ra_customer_trx_lines_all      ctl
      ,(SELECT entity_id,
               source_id_int_1
          FROM xla_events_gt
         WHERE application_id  = 222
           AND event_type_code IN ('RECP_CREATE','RECP_UPDATE','RECP_RATE_ADJUST')
         GROUP BY entity_id,
                  source_id_int_1)    xla
 WHERE xla.source_id_int_1              = crh.cash_receipt_id
   AND crh.cash_receipt_history_id      = ra.cash_receipt_history_id
   AND crh.cash_receipt_id              = cr.cash_receipt_id
   AND crh.cash_receipt_id              = ra.cash_receipt_id
   AND ra.status                        = 'APP'
   AND ra.receivable_application_id     = ard.source_id
   -- Add MFAR UPG impacts
   AND DECODE(ra.upgrade_method,
              '11I_MFAR_UPG',DECODE(ard.source_table_secondary,'UPMFRAMIAR','Y','N'),
              'R12_11ICASH' ,'N',
              '11I_R12_POST','N',
                        'Y')            = 'Y'
   AND ra.applied_customer_trx_id       = ct.customer_trx_id
   AND ard.source_table                 = 'RA'
   AND ard.source_type NOT IN ('EXCH_GAIN','EXCH_LOSS','EDISC','UNEDISC','EDISC_NON_REC_TAX','UNEDISC_NON_REC_TAX','DEFERRED_TAX','TAX', 'CURR_ROUND')
   AND decode(ard.source_type,'REC',decode(ard.ref_mf_dist_flag,'D','N','Y'),'Y')='Y'
   AND ard.ref_customer_trx_line_id     = ctl.customer_trx_line_id(+)
   AND ard.ref_cust_trx_line_gl_dist_id = ctlgd.cust_trx_line_gl_dist_id(+)
   ORDER BY ard.line_id;

  local_log(procedure_name => 'mfar_app_dist_cr',
            p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.mfar_app_dist_cr ()-');
EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'mfar_app_dist_cr',
             p_msg_text     => 'EXCEPTION OTHERS in mfar_app_dist_cr '||
                 arp_global.CRLF || 'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.mfar_app_dist_cr'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;
END;

PROCEDURE mfar_crh_dist IS
BEGIN
  local_log(procedure_name => 'mfar_crh_dist',
            p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.mfar_crh_dist ()+');
-- All CRH distribution part of the current posting will serve for the
-- Additional distribution building
INSERT INTO ar_crh_gt (
 cash_receipt_id        ,
 cash_receipt_history_id,
 source_type            ,
 posting_control_id     ,
 amount                 ,
 acctd_amount           ,
 code_combination_id    ,
 exchange_date          ,
 exchange_rate          ,
 exchange_rate_type     ,
 third_party_id         ,
 third_party_sub_id     ,
 third_party_flag       ,
 event_id               ,
 entity_id              ,
 ledger_id              ,
 base_currency_code     ,
 org_id                 ,
 status                 ,
 crh_line_id            ,
 recp_amount            ,
 recp_acctd_amount      ,
 DIST_LINE_STATUS)
SELECT crh.cash_receipt_id
      ,crh.cash_receipt_history_id
      ,ard.source_type
      ,crh.posting_control_id
      ,NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)
      ,NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)
      ,ard.code_combination_id
      ,crh.exchange_date
      ,crh.exchange_rate
      ,crh.exchange_rate_type
      ,ard.third_party_id
      ,ard.third_party_sub_id
      ,DECODE(third_party_id,NULL,'N','Y')
      ,gt.event_id
      ,gt.entity_id
      ,cr.set_of_books_id                        -- ledger_id
      ,lg.currency_code
      ,crh.org_id
      ,DECODE(ard.source_type,'CASH'        ,'CLEARED',
                              'REMITTANCE'  ,'REMITTED',
                              'CONFIRMATION','CONFIRMED'
                              ,'BANK_CHARGES','BANK_CHARGES'
                              ,'CASH')
    --   ,ard.line_id            crh_line_id
       ,crh.cash_receipt_history_id            crh_line_id
       ,(crh.amount+ nvl(crh.factor_discount_amount,0)) recp_amount
       ,(crh.acctd_amount+ nvl(crh.acctd_factor_discount_amount,0)) recp_acctd_amount
       ,decode(crh.status , DECODE(ard.source_type,'CASH','CLEARED',
						   'REMITTANCE','REMITTED',
			                           'CONFIRMATION','CONFIRMED',
						   'BANK_CHARGES','CLEARED'
                              ,'CASH'), 'ACTUAL','REVERSAL') DIST_LINE_STATUS
  FROM xla_events_gt                gt,
       ar_cash_receipt_history_all  crh,
       ar_cash_receipts_all         cr,
       ar_distributions_all         ard,
       gl_ledgers                   lg
 WHERE gt.application_id  = 222
   AND gt.event_type_code IN ('RECP_CREATE','RECP_UPDATE','MISC_RECP_CREATE','MISC_RECP_UPDATE','RECP_RATE_ADJUST')
   AND gt.event_id        = crh.event_id
   AND crh.postable_flag  = 'Y'
   AND crh.cash_receipt_id= cr.cash_receipt_id
   AND ard.source_id      = crh.cash_receipt_history_id
   AND ard.source_table   = 'CRH'
   AND (
   (ard.source_type   IN ('CASH','REMITTANCE','CONFIRMATION'))
   OR
   (ard.source_type ='BANK_CHARGES'
    AND crh.factor_discount_amount = ( nvl(ard.amount_dr,0) - nvl(ard.amount_cr,0)))
   )
   AND cr.set_of_books_id = lg.ledger_id
/*
    Whenever user updates the Bank Charges for a posted Receipt, the ar_distributions
    table calculates the differential amount and stores the difference
    But, for mfar accountin we need to build the detailed distributions with
    reversal entries and the new entries.

    The below select builds the detailed distributions for the bank charge changes
    when the previous distribution does not involve the change in bank charges
*/
UNION ALL
SELECT crh.cash_receipt_id
      ,crh.cash_receipt_history_id
      ,pairard.source_type
      ,crh.posting_control_id
      ,decode(pairard.source_type, 'BANK_CHARGES',
                   decode(state.status, 'ORG_DIST',
                           -1*crh.factor_discount_amount,
                           -1*paircrh.factor_discount_amount),
                     NVL(pairard.amount_cr,0)-NVL(pairard.amount_dr,0)) amount
      ,decode(pairard.source_type, 'BANK_CHARGES',
                     decode(state.status, 'ORG_DIST',
                            -1*crh.acctd_factor_discount_amount,
                            -1*paircrh.acctd_factor_discount_amount),
                     NVL(pairard.acctd_amount_cr,0)-NVL(pairard.acctd_amount_dr,0)) acctd_amount
      ,pairard.code_combination_id
      ,paircrh.exchange_date
      ,paircrh.exchange_rate
      ,paircrh.exchange_rate_type
      ,pairard.third_party_id
      ,pairard.third_party_sub_id
      ,DECODE(pairard.third_party_id,NULL,'N','Y')
      ,gt.event_id
      ,gt.entity_id
      ,cr.set_of_books_id                        -- ledger_id
      ,lg.currency_code
      ,paircrh.org_id
      ,DECODE(pairard.source_type,'CASH'        ,'CLEARED',
                              'REMITTANCE'  ,'REMITTED',
                              'CONFIRMATION','CONFIRMED'
                              ,'BANK_CHARGES','BANK_CHARGES'
                              ,'CASH')
       ,decode(state.status, 'ORG_DIST', paircrh.cash_receipt_history_id, -1*paircrh.cash_receipt_history_id) crh_line_id
       ,decode(state.status, 'ORG_DIST', (crh.amount+ nvl(crh.factor_discount_amount,0))
                           , 'REV_DIST', (paircrh.amount+ nvl(paircrh.factor_discount_amount,0))) recp_amount
        ,decode(state.status, 'ORG_DIST',(crh.acctd_amount+ nvl(crh.acctd_factor_discount_amount,0))
                            , 'REV_DIST',(paircrh.acctd_amount+ nvl(paircrh.acctd_factor_discount_amount,0))) recp_acctd_amount
       , decode(state.status, 'ORG_DIST','ACTUAL','REVERSAL') DIST_LINE_STATUS
  FROM xla_events_gt                gt,
       ar_cash_receipt_history_all  crh,
       ar_cash_receipts_all         cr,
       ar_distributions_all         ard,
       ar_cash_receipt_history_all  paircrh,
       ar_distributions_all         pairard,
       gl_ledgers                   lg,
       (SELECT 'ORG_DIST'    AS status   FROM DUAL UNION
        SELECT 'REV_DIST'    AS status   FROM DUAL)    state
 WHERE gt.application_id  = 222
   AND gt.event_type_code IN ('RECP_CREATE','RECP_UPDATE','MISC_RECP_CREATE','MISC_RECP_UPDATE','RECP_RATE_ADJUST')
   AND gt.event_id        = crh.event_id
   AND crh.postable_flag  = 'Y'
   AND crh.cash_receipt_id= cr.cash_receipt_id
   AND ard.source_id      = crh.cash_receipt_history_id
   AND ard.source_table   = 'CRH'
   AND ard.source_type  = 'BANK_CHARGES'
   AND paircrh.reversal_cash_receipt_hist_id = crh.cash_receipt_history_id
   AND paircrh.cash_receipt_history_id = pairard.source_id
   AND pairard.source_table = 'CRH'
   AND crh.factor_discount_amount <> ( nvl(ard.amount_dr,0) - nvl(ard.amount_cr,0) )
   AND cr.set_of_books_id = lg.ledger_id
UNION ALL
/*

Build CASH and  REMITTANCE Records
when ARD's Bank Charge Record is created as difference amount,
and previous CRH state also exists with a differential Bank Charge Amount

That means customer has updated the bank charges more than once consecutively
in receipt history.

*/
SELECT crh.cash_receipt_id
      ,crh.cash_receipt_history_id
      ,decode(paircrh.status, 'CLEARED', 'CASH'
                            , 'REMITTED', 'REMITTACE'
                            ,'CONFIRMED','CONFIRMATION'
                            ,'CASH')
      ,crh.posting_control_id
      ,decode(state.status, 'ORG_DIST',
                           -1*crh.amount,
                           -1*paircrh.amount) amount
      ,decode(state.status, 'ORG_DIST',
                            -1*crh.acctd_amount,
                            -1*paircrh.acctd_amount) acctd_amount
      ,pairard.code_combination_id
      ,paircrh.exchange_date
      ,paircrh.exchange_rate
      ,paircrh.exchange_rate_type
      ,pairard.third_party_id
      ,pairard.third_party_sub_id
      ,DECODE(pairard.third_party_id,NULL,'N','Y')
      ,gt.event_id
      ,gt.entity_id
      ,cr.set_of_books_id                        -- ledger_id
      ,lg.currency_code
      ,paircrh.org_id
      , paircrh.status
       ,decode(state.status, 'ORG_DIST', paircrh.cash_receipt_history_id, -1*paircrh.cash_receipt_history_id) crh_line_id
       ,decode(state.status, 'ORG_DIST', (crh.amount+ nvl(crh.factor_discount_amount,0))
                           , 'REV_DIST', (paircrh.amount+ nvl(paircrh.factor_discount_amount,0))) recp_amount
        ,decode(state.status, 'ORG_DIST',(crh.acctd_amount+ nvl(crh.acctd_factor_discount_amount,0))
                            , 'REV_DIST',(paircrh.acctd_amount+ nvl(paircrh.acctd_factor_discount_amount,0))) recp_acctd_amount
       , decode(state.status, 'ORG_DIST','ACTUAL','REVERSAL') DIST_LINE_STATUS
  FROM xla_events_gt                gt,
       ar_cash_receipt_history_all  crh,
       ar_cash_receipts_all         cr,
       ar_distributions_all         ard,
       ar_cash_receipt_history_all  paircrh,
       ar_distributions_all         pairard,
       gl_ledgers                   lg,
       (SELECT 'ORG_DIST'    AS status   FROM DUAL UNION
        SELECT 'REV_DIST'    AS status   FROM DUAL)    state
 WHERE gt.application_id  = 222
   AND gt.event_type_code IN ('RECP_CREATE','RECP_UPDATE','MISC_RECP_CREATE','MISC_RECP_UPDATE','RECP_RATE_ADJUST')
   AND gt.event_id        = crh.event_id
   AND crh.postable_flag  = 'Y'
   AND crh.cash_receipt_id= cr.cash_receipt_id
   AND ard.source_id      = crh.cash_receipt_history_id
   AND ard.source_table   = 'CRH'
   AND ard.source_type  = 'BANK_CHARGES'
   AND pairard.source_type  = ard.source_type
   AND paircrh.reversal_cash_receipt_hist_id = crh.cash_receipt_history_id
   AND paircrh.cash_receipt_history_id = pairard.source_id
   AND pairard.source_table = 'CRH'
   AND crh.factor_discount_amount <> ( nvl(ard.amount_dr,0) - nvl(ard.amount_cr,0) )
   AND paircrh.factor_discount_amount <> ( nvl(pairard.amount_dr,0) - nvl(pairard.amount_cr,0) )
   AND cr.set_of_books_id = lg.ledger_id;

  local_log(procedure_name => 'mfar_crh_dist',
            p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.mfar_app_dist_cr ()-');
EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'mfar_crh_dist',
             p_msg_text     => 'EXCEPTION OTHERS in mfar_crh_dist '||
                 arp_global.CRLF || 'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.mfar_crh_dist'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;
END;


PROCEDURE mfar_produit_app_by_crh  IS
--
-- Build the MFAR distribution for CRH
--
CURSOR mfar_extract_cur IS
  SELECT
        ordered_crh_by_app.*
       ,-1 * ar_mfar_extract_s.nextval            LINE_NUMBER
  FROM (SELECT
       crh.event_id                              event_id
   --   ,-1 * ar_mfar_extract_s.nextval            LINE_NUMBER
      ,'Y'                                       MFAR_ADDITIONAL_ENTRY
      ,crh.ledger_id                             LEDGER_ID
      ,crh.base_currency_code                    BASE_CURRENCY_CODE
      ,crh.org_id                                ORG_ID
      ,app.line_id                               LINE_ID
      ,app.receivable_application_id             SOURCE_ID
      ,'RA'                                      SOURCE_TABLE
      ,crh.cash_receipt_id                       HEADER_TABLE_ID
      ,'RECEIPT_HISTORY'                         POSTING_ENTITY
      ,crh.entity_id                             xla_entity_id
      --
      ,app.code_combination_id                   DIST_CCID
      ,app.ref_dist_ccid                         ref_dist_ccid
      ,app.ref_code_combination_id               REF_CTLGD_CCID
      --
      ,app.from_currency_code                    from_currency_code
      ,app.from_exchange_rate                    from_exchange_rate
      ,app.from_exchange_type                    FROM_EXCHANGE_RATE_TYPE
      ,app.from_exchange_date                    from_exchange_date
      ,decode(event_type_code, 'RECP_RATE_ADJUST',-app.from_amount,sign(crh.amount)*app.from_amount) from_amount
      ,decode(event_type_code, 'RECP_RATE_ADJUST',-app.from_acctd_amount,sign(crh.acctd_amount)*app.from_acctd_amount) from_acctd_amount
      --
      ,app.to_currency_code                      to_currency_code
      ,app.to_exchange_rate                      exchange_rate
      ,app.to_exchange_type                      EXCHANGE_RATE_TYPE
      ,app.to_exchange_date                      EXCHANGE_DATE
      ,decode(event_type_code, 'RECP_RATE_ADJUST',-app.amount,sign(crh.amount)*app.amount) amount
      ,decode(event_type_code, 'RECP_RATE_ADJUST',-app.acctd_amount,sign(crh.acctd_amount)*app.acctd_amount) acctd_amount
      --
      ,app.receivable_application_id             RECEIVABLE_APPLICATION_ID
      ,crh.cash_receipt_id                       CASH_RECEIPT_ID
      ,app.customer_trx_id                       CUSTOMER_TRX_ID
      ,app.ref_customer_trx_line_id              CUSTOMER_TRX_LINE_ID
      ,app.ref_cust_trx_line_gl_dist_id          CUST_TRX_LINE_GL_DIST_ID
      --
      ,app.inventory_item_id                     INVENTORY_ITEM_ID
      ,app.sales_tax_id                          SALES_TAX_ID
      ,crh.ledger_id                             SET_OF_BOOKS_ID
      ,app.bill_to_site_use_id                   BILL_SITE_USE_ID
      ,app.sold_to_site_use_id                   SOLD_SITE_USE_ID
      ,app.ship_to_site_use_id                   SHIP_SITE_USE_ID
      ,app.bill_to_customer_id                   BILL_CUSTOMER_ID
      ,app.sold_to_customer_id                   SOLD_CUSTOMER_ID
      ,app.ship_to_customer_id                   SHIP_CUSTOMER_ID
      ,app.tax_line_id                           TAX_LINE_ID
      --
      ,'Y'                                       SELECT_FLAG
      ,'L'                                       LEVEL_FLAG
      ,'T'                                       FROM_TO_FLAG
      ,crh.status                                CRH_STATUS
      ,app.cash_receipt_history_status           APP_CRH_STATUS
      --
      ,gt.event_type_code                        EVENT_TYPE_CODE
      ,gt.event_class_code                       EVENT_CLASS_CODE
      ,gt.entity_code                            ENTITY_CODE
      --
      ,app.third_party_id                        third_party_id
      ,app.third_party_site_id                   third_party_site_id
      ,app.third_party_type                      third_party_type
      ,app.source_type                           source_type
      ,crh.recp_amount                           recp_amount
      ,crh.recp_acctd_amount                     recp_acctd_amount
      ,decode(crh.DIST_LINE_STATUS,'REVERSAL', crh.amount, -1*(crh.amount)) crh_amount
      ,decode(crh.DIST_LINE_STATUS,'REVERSAL', crh.acctd_amount, -1*(crh.acctd_amount)) crh_acctd_amount
      ,crh.crh_line_id                           CRH_RECORD_ID
  FROM ar_crh_gt                                           crh,
       ar_crh_app_gt                                       app,
       xla_events_gt                                       gt
 WHERE crh.entity_id     = app.entity_id
   AND app.source_table  = 'RA'
/* Start fix for Bug 9644866 */
   AND decode (crh.cash_receipt_history_id,
                                app.cash_receipt_history_id,
                                    decode(app.event_id,
                                              crh.event_id, 'Y'
                                                           ,'N')
                                    ,'Y') = 'Y'
/* End fix for Bug 9644866 */
   AND crh.event_id = gt.event_id
   AND ((gt.event_type_code <>  'RECP_RATE_ADJUST' AND crh.DIST_LINE_STATUS  = 'ACTUAL'  AND crh.cash_receipt_history_id >= app.cash_receipt_history_id)
	OR
	(gt.event_type_code <>  'RECP_RATE_ADJUST' AND crh.DIST_LINE_STATUS  = 'REVERSAL'  AND crh.cash_receipt_history_id > app.cash_receipt_history_id)
	OR
	(gt.event_type_code =  'RECP_RATE_ADJUST' AND crh.cash_receipt_history_id = app.cash_receipt_history_id)
	)
   order by crh.cash_receipt_id, app.line_id, CRH_RECORD_ID) ordered_crh_by_app ;

-- crh_mfar_extract_record table type local variable
  l_crh_mfar_extract_record  crh_mfar_extract_record_type;

BEGIN
  local_log(procedure_name => 'mfar_produit_app_by_crh',
            p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.mfar_produit_app_by_crh ()+');

 OPEN mfar_extract_cur;
 LOOP
   FETCH mfar_extract_cur BULK COLLECT INTO l_crh_mfar_extract_record LIMIT MAX_ARRAY_SIZE;
   IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug('mfar_produit_app_by_crh current fetch count   '|| l_crh_mfar_extract_record.count);
   END IF;

   IF l_crh_mfar_extract_record.count = 0 THEN
	  EXIT;
   END IF;

-- Calculate prorated amounts and insert data into extract
   mfar_insert_crh_extract (l_crh_mfar_extract_record);

 END LOOP;

   CLOSE mfar_extract_cur;


  local_log(procedure_name => 'mfar_produit_app_by_crh',
            p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.mfar_produit_app_by_crh ()-');
EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'mfar_crh_dist',
             p_msg_text     => 'EXCEPTION OTHERS in mfar_produit_app_by_crh '||
                 arp_global.CRLF || 'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.mfar_produit_app_by_crh'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;
END;



PROCEDURE mfar_get_ra IS

CURSOR mfar_extract_app_cur IS
Select
ordered_crh.*
 ,-1 * ar_mfar_extract_s.NEXTVAL   LINE_NUMBER
FROM
(SELECT
       gt.event_id                      EVENT_ID
     -- ,-1 * ar_mfar_extract_s.NEXTVAL LINE_NUMBER
      ,'Y'                              MFAR_ADDITIONAL_ENTRY
      ,trx.set_of_books_id              LEDGER_ID
      ,lg.currency_code                 BASE_CURRENCY_CODE
      ,ra.org_id                        ORG_ID
      ,ard.line_id                      LINE_ID
      ,ra.receivable_application_id     SOURCE_ID
      ,'RA'                             SOURCE_TABLE
      ,ra.cash_receipt_id               HEADER_TABLE_ID
      ,'APPLICATION'                    POSTING_ENTITY
      ,gt.entity_id                     XLA_ENTITY_ID
      --
      ,ard.code_combination_id          DIST_CCID
      ,ard.ref_dist_ccid                REF_DIST_CCID
      ,ctlgd.code_Combination_id        REF_CTLGD_CCID
      --
      ,cr.currency_code                 FROM_CURRENCY_CODE
      ,crh.exchange_rate                FROM_EXCHANGE_RATE
      ,crh.exchange_rate_type           FROM_EXCHANGE_RATE_TYPE
      ,crh.exchange_date                FROM_EXCHANGE_DATE
      ,-1 * (NVL(ard.from_amount_cr,0)-NVL(ard.from_amount_dr,0))               FROM_AMOUNT
      ,-1 * (NVL(ard.from_acctd_amount_cr,0)-NVL(ard.from_acctd_amount_dr,0))   FROM_ACCTD_AMOUNT
      --
      ,trx.invoice_currency_code        TO_CURRENCY_CODE
      ,trx.exchange_rate                EXCHANGE_RATE
      ,trx.exchange_rate_type           EXCHANGE_RATE_TYPE
      ,trx.exchange_date                EXCHANGE_DATE
      ,-1 * (NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0))                 AMOUNT
      ,-1 * (NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0))     ACCTD_AMOUNT
      --
      ,ra.receivable_application_id     RECEIVABLE_APPLICATION_ID
      ,ra.cash_receipt_id               CASH_RECEIPT_ID
      ,ra.applied_customer_trx_id       CUSTOMER_TRX_ID
      ,ard.ref_customer_trx_line_id     CUSTOMER_TRX_LINE_ID
      ,ard.ref_cust_trx_line_gl_dist_id    CUST_TRX_LINE_GL_DIST_ID
      --
      ,ctl.inventory_item_id               INVENTORY_ITEM_ID
      ,ctl.sales_tax_id                    SALES_TAX_ID
      ,trx.set_of_books_id                 SET_OF_BOOKS_ID
      ,trx.bill_to_site_use_id             BILL_SITE_USE_ID
      ,trx.sold_to_site_use_id             SOLD_SITE_USE_ID
      ,trx.ship_to_site_use_id             SHIP_SITE_USE_ID
      ,trx.bill_to_customer_id             BILL_CUSTOMER_ID
      ,trx.sold_to_customer_id             SOLD_CUSTOMER_ID
      ,trx.ship_to_customer_id             SHIP_CUSTOMER_ID
      ,ctl.tax_line_id                     TAX_LINE_ID
      --
      ,'Y'                                 SELECT_FLAG
      ,'L'                                 LEVEL_FLAG
      ,'T'                                 FROM_TO_FLAG
      ,crhlatest.status                    CRH_STATUS
      ,crh.status                          APP_CRH_STATUS
      --
      ,gt.event_type_code                  EVENT_TYPE_CODE
      ,gt.event_class_code                 EVENT_CLASS_CODE
      ,gt.entity_code                      ENTITY_CODE
      --
      ,ard.third_party_id                  third_party_id
      ,ard.third_party_sub_id              third_party_site_id
      ,DECODE(ard.third_party_id,NULL,NULL,'C')           third_party_type
      ,ard.source_type                       source_type
      ,abs(crhlatest.amount+ nvl(crhlatest.factor_discount_amount,0)) RECP_AMOUNT
      ,abs(crhlatest.acctd_amount+ nvl(crhlatest.acctd_factor_discount_amount,0)) RECP_ACCTD_AMOUNT
      ,abs(crhlatest.amount) crh_amount
      ,abs(crhlatest.acctd_amount) crh_acctd_amount
      ,crhlatest.cash_receipt_history_id          CRH_RECORD_ID
  FROM xla_events_gt                      gt,
       ar_receivable_applications_all     ra,
       ar_cash_receipt_history_all        crh,
       ar_distributions_all               ard,
       ra_customer_trx_all                trx,
       ra_cust_trx_line_gl_dist_all       ctlgd,
       ra_customer_trx_lines_all          ctl,
       ar_cash_receipts_all               cr,
       gl_ledgers                         lg,
       ar_cash_receipt_history_all        crhlatest
 WHERE gt.application_id                = 222
   AND gt.event_type_code               IN ('RECP_CREATE','RECP_UPDATE')
   AND gt.event_id                      = ra.event_id
   AND ra.status                        = 'APP'
   AND ard.source_id                    = ra.receivable_application_id
   AND ard.source_table                 = 'RA'
   AND nvl(ard.REF_MF_DIST_FLAG, 'Z')   <> 'U'
   AND ard.source_type NOT IN ('EXCH_GAIN','EXCH_LOSS')
   AND ra.cash_receipt_history_id       = crh.cash_receipt_history_id
   AND ra.cash_receipt_id               = cr.cash_receipt_id
   AND trx.set_of_books_id              = lg.ledger_id
   AND crh.cash_receipt_id              = cr.cash_receipt_id
   AND crh.posting_control_id           <> -3
   AND crh.cash_receipt_id              = crhlatest.cash_receipt_id
   AND ard.ref_cust_trx_line_gl_dist_id = ctlgd.cust_trx_line_gl_dist_id(+)
   AND ard.ref_customer_trx_line_id     = ctl.customer_trx_line_id(+)
   AND ra.applied_customer_trx_id      = trx.customer_trx_id
   AND crhlatest.cash_receipt_id       = cr.cash_receipt_id
   AND crhlatest.cash_receipt_history_id =
        ( SELECT MAX(a.cash_receipt_history_id)
          FROM ar_cash_receipt_history_all a
          WHERE a.cash_receipt_id = cr.cash_receipt_id
          AND posting_control_id <> -3)
UNION ALL
SELECT
       gt.event_id                      EVENT_ID
     -- ,-1 * ar_mfar_extract_s.NEXTVAL LINE_NUMBER
      ,'Y'                              MFAR_ADDITIONAL_ENTRY
      ,trx.set_of_books_id              LEDGER_ID
      ,lg.currency_code                 BASE_CURRENCY_CODE
      ,ra.org_id                        ORG_ID
      ,ard.line_id                      LINE_ID
      ,ra.receivable_application_id     SOURCE_ID
      ,'RA'                             SOURCE_TABLE
      ,ra.cash_receipt_id               HEADER_TABLE_ID
      ,'APPLICATION'                    POSTING_ENTITY
      ,gt.entity_id                     XLA_ENTITY_ID
      --
      ,ard.code_combination_id          DIST_CCID
      ,ard.ref_dist_ccid                REF_DIST_CCID
      ,ctlgd.code_Combination_id        REF_CTLGD_CCID
      --
      ,cr.currency_code                 FROM_CURRENCY_CODE
      ,crh.exchange_rate                FROM_EXCHANGE_RATE
      ,crh.exchange_rate_type           FROM_EXCHANGE_RATE_TYPE
      ,crh.exchange_date                FROM_EXCHANGE_DATE
      ,-1 * (NVL(ard.from_amount_cr,0)-NVL(ard.from_amount_dr,0))               FROM_AMOUNT
      ,-1 * (NVL(ard.from_acctd_amount_cr,0)-NVL(ard.from_acctd_amount_dr,0))   FROM_ACCTD_AMOUNT
      --
      ,trx.invoice_currency_code        TO_CURRENCY_CODE
      ,trx.exchange_rate                EXCHANGE_RATE
      ,trx.exchange_rate_type           EXCHANGE_RATE_TYPE
      ,trx.exchange_date                EXCHANGE_DATE
      ,-1 * (NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0))                 AMOUNT
      ,-1 * (NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0))     ACCTD_AMOUNT
      --
      ,ra.receivable_application_id     RECEIVABLE_APPLICATION_ID
      ,ra.cash_receipt_id               CASH_RECEIPT_ID
      ,ra.applied_customer_trx_id       CUSTOMER_TRX_ID
      ,ard.ref_customer_trx_line_id     CUSTOMER_TRX_LINE_ID
      ,ard.ref_cust_trx_line_gl_dist_id    CUST_TRX_LINE_GL_DIST_ID
      --
      ,ctl.inventory_item_id               INVENTORY_ITEM_ID
      ,ctl.sales_tax_id                    SALES_TAX_ID
      ,trx.set_of_books_id                 SET_OF_BOOKS_ID
      ,trx.bill_to_site_use_id             BILL_SITE_USE_ID
      ,trx.sold_to_site_use_id             SOLD_SITE_USE_ID
      ,trx.ship_to_site_use_id             SHIP_SITE_USE_ID
      ,trx.bill_to_customer_id             BILL_CUSTOMER_ID
      ,trx.sold_to_customer_id             SOLD_CUSTOMER_ID
      ,trx.ship_to_customer_id             SHIP_CUSTOMER_ID
      ,ctl.tax_line_id                     TAX_LINE_ID
      --
      ,'Y'                                 SELECT_FLAG
      ,'L'                                 LEVEL_FLAG
      ,'T'                                 FROM_TO_FLAG
      ,crh.status                    CRH_STATUS
      ,crh.status                          APP_CRH_STATUS
      --
      ,gt.event_type_code                  EVENT_TYPE_CODE
      ,gt.event_class_code                 EVENT_CLASS_CODE
      ,gt.entity_code                      ENTITY_CODE
      --
      ,ard.third_party_id                  third_party_id
      ,ard.third_party_sub_id              third_party_site_id
      ,DECODE(ard.third_party_id,NULL,NULL,'C')           third_party_type
      ,ard.source_type                       source_type
      ,abs(crh.amount+ nvl(crh.factor_discount_amount,0)) RECP_AMOUNT
      ,abs(crh.acctd_amount+ nvl(crh.acctd_factor_discount_amount,0)) RECP_ACCTD_AMOUNT
      ,abs(crh.amount) crh_amount
      ,abs(crh.acctd_amount) crh_acctd_amount
      ,crh.cash_receipt_history_id          CRH_RECORD_ID
  FROM xla_events_gt                      gt,
       ar_receivable_applications_all     ra,
       ar_cash_receipt_history_all        crh,
       ar_distributions_all               ard,
       ra_customer_trx_all                trx,
       ra_cust_trx_line_gl_dist_all       ctlgd,
       ra_customer_trx_lines_all          ctl,
       ar_cash_receipts_all               cr,
       gl_ledgers                         lg
 WHERE gt.application_id                = 222
   AND gt.event_type_code               IN ('RECP_CREATE','RECP_UPDATE')
   AND gt.event_id                      = ra.event_id
   AND ra.status                        = 'APP'
   AND ard.source_id                    = ra.receivable_application_id
   AND ard.source_table                 = 'RA'
   AND nvl(ard.REF_MF_DIST_FLAG, 'Z')   <> 'U'
   AND ard.source_type NOT IN ('EXCH_GAIN','EXCH_LOSS')
   AND ra.cash_receipt_history_id       = crh.cash_receipt_history_id
   AND ra.cash_receipt_id               = cr.cash_receipt_id
   AND trx.set_of_books_id              = lg.ledger_id
   AND crh.cash_receipt_id              = cr.cash_receipt_id
/* Start fix for Bug 9644866 */
   AND crh.posting_control_id           = -3
   AND ra.cash_receipt_history_id = crh.cash_receipt_history_id
   AND ra.event_id <> crh.event_id
/* End fix for Bug 9644866 */
   AND ard.ref_cust_trx_line_gl_dist_id = ctlgd.cust_trx_line_gl_dist_id(+)
   AND ard.ref_customer_trx_line_id     = ctl.customer_trx_line_id(+)
   AND ra.applied_customer_trx_id      = trx.customer_trx_id
UNION ALL
 SELECT
       gt.event_id                      EVENT_ID
     -- ,-1 * ar_mfar_extract_s.NEXTVAL LINE_NUMBER
      ,'Y'                              MFAR_ADDITIONAL_ENTRY
      ,trx.set_of_books_id              LEDGER_ID
      ,lg.currency_code                 BASE_CURRENCY_CODE
      ,ra.org_id                        ORG_ID
      ,ard.line_id                      LINE_ID
      ,ra.receivable_application_id     SOURCE_ID
      ,'RA'                             SOURCE_TABLE
      ,ra.cash_receipt_id               HEADER_TABLE_ID
      ,'APPLICATION'                    POSTING_ENTITY
      ,gt.entity_id                     XLA_ENTITY_ID
      --
      ,ard.code_combination_id          DIST_CCID
      ,ard.ref_dist_ccid                REF_DIST_CCID
      ,ctlgd.code_Combination_id        REF_CTLGD_CCID
      --
      ,cr.currency_code                 FROM_CURRENCY_CODE
      ,crh.exchange_rate                FROM_EXCHANGE_RATE
      ,crh.exchange_rate_type           FROM_EXCHANGE_RATE_TYPE
      ,crh.exchange_date                FROM_EXCHANGE_DATE
      ,-1 * (NVL(ard.from_amount_cr,0)-NVL(ard.from_amount_dr,0))               FROM_AMOUNT
      ,-1 * (NVL(ard.from_acctd_amount_cr,0)-NVL(ard.from_acctd_amount_dr,0))   FROM_ACCTD_AMOUNT
      --
      ,trx.invoice_currency_code        TO_CURRENCY_CODE
      ,trx.exchange_rate                EXCHANGE_RATE
      ,trx.exchange_rate_type           EXCHANGE_RATE_TYPE
      ,trx.exchange_date                EXCHANGE_DATE
      ,-1 * (NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0))                 AMOUNT
      ,-1 * (NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0))     ACCTD_AMOUNT
      --
      ,ra.receivable_application_id     RECEIVABLE_APPLICATION_ID
      ,ra.cash_receipt_id               CASH_RECEIPT_ID
      ,ra.applied_customer_trx_id       CUSTOMER_TRX_ID
      ,ard.ref_customer_trx_line_id     CUSTOMER_TRX_LINE_ID
      ,ard.ref_cust_trx_line_gl_dist_id    CUST_TRX_LINE_GL_DIST_ID
      --
      ,ctl.inventory_item_id               INVENTORY_ITEM_ID
      ,ctl.sales_tax_id                    SALES_TAX_ID
      ,trx.set_of_books_id                 SET_OF_BOOKS_ID
      ,trx.bill_to_site_use_id             BILL_SITE_USE_ID
      ,trx.sold_to_site_use_id             SOLD_SITE_USE_ID
      ,trx.ship_to_site_use_id             SHIP_SITE_USE_ID
      ,trx.bill_to_customer_id             BILL_CUSTOMER_ID
      ,trx.sold_to_customer_id             SOLD_CUSTOMER_ID
      ,trx.ship_to_customer_id             SHIP_CUSTOMER_ID
      ,ctl.tax_line_id                     TAX_LINE_ID
      --
      ,'Y'                                 SELECT_FLAG
      ,'L'                                 LEVEL_FLAG
      ,'T'                                 FROM_TO_FLAG
      ,'BANK_CHARGES'                    CRH_STATUS
      ,crh.status                          APP_CRH_STATUS
      --
      ,gt.event_type_code                  EVENT_TYPE_CODE
      ,gt.event_class_code                 EVENT_CLASS_CODE
      ,gt.entity_code                      ENTITY_CODE
      --
      ,ard.third_party_id                  third_party_id
      ,ard.third_party_sub_id              third_party_site_id
      ,DECODE(ard.third_party_id,NULL,NULL,'C')           third_party_type
      ,ard.source_type                       source_type
      ,abs(crhlatest.amount+ nvl(crhlatest.factor_discount_amount,0)) RECP_AMOUNT
      ,abs(crhlatest.acctd_amount+ nvl(crhlatest.acctd_factor_discount_amount,0)) RECP_ACCTD_AMOUNT
      ,abs(crhlatest.factor_discount_amount) crh_amount
      ,abs(crhlatest.acctd_factor_discount_amount) crh_acctd_amount
      ,crhlatest.cash_receipt_history_id          CRH_RECORD_ID
  FROM xla_events_gt                      gt,
       ar_receivable_applications_all     ra,
       ar_cash_receipt_history_all        crh,
       ar_distributions_all               ard,
       ra_customer_trx_all                trx,
       ra_cust_trx_line_gl_dist_all       ctlgd,
       ra_customer_trx_lines_all          ctl,
       ar_cash_receipts_all               cr,
       gl_ledgers                         lg,
       ar_cash_receipt_history_all        crhlatest
 WHERE gt.application_id                = 222
   AND gt.event_type_code               IN ('RECP_CREATE','RECP_UPDATE')
   AND gt.event_id                      = ra.event_id
   AND ra.status                        = 'APP'
   AND ard.source_id                    = ra.receivable_application_id
   AND ard.source_table                 = 'RA'
   AND nvl(ard.REF_MF_DIST_FLAG, 'Z')   <> 'U'
   AND ard.source_type NOT IN ('EXCH_GAIN','EXCH_LOSS')
   AND ra.cash_receipt_history_id       = crh.cash_receipt_history_id
   AND ra.cash_receipt_id               = cr.cash_receipt_id
   AND trx.set_of_books_id              = lg.ledger_id
   AND crh.cash_receipt_id              = cr.cash_receipt_id
   AND crh.posting_control_id           <> -3
   AND crh.cash_receipt_id              = crhlatest.cash_receipt_id
   AND ard.ref_cust_trx_line_gl_dist_id = ctlgd.cust_trx_line_gl_dist_id(+)
   AND ard.ref_customer_trx_line_id     = ctl.customer_trx_line_id(+)
   AND ra.applied_customer_trx_id      = trx.customer_trx_id
   AND crhlatest.cash_receipt_id       = cr.cash_receipt_id
   AND crhlatest.cash_receipt_history_id =
     ( SELECT MAX(a.cash_receipt_history_id)
         FROM ar_cash_receipt_history_all a
        WHERE a.cash_receipt_id = cr.cash_receipt_id
          AND a.posting_control_id    <> -3)
   AND crhlatest.status = 'CLEARED'
   AND NVL(crhlatest.factor_discount_amount,0) <> 0
   AND NVL(crhlatest.acctd_factor_discount_amount,0) <> 0
UNION ALL
SELECT
       gt.event_id                      EVENT_ID
     -- ,-1 * ar_mfar_extract_s.NEXTVAL LINE_NUMBER
      ,'Y'                              MFAR_ADDITIONAL_ENTRY
      ,trx.set_of_books_id              LEDGER_ID
      ,lg.currency_code                 BASE_CURRENCY_CODE
      ,ra.org_id                        ORG_ID
      ,ard.line_id                      LINE_ID
      ,ra.receivable_application_id     SOURCE_ID
      ,'RA'                             SOURCE_TABLE
      ,ra.cash_receipt_id               HEADER_TABLE_ID
      ,'APPLICATION'                    POSTING_ENTITY
      ,gt.entity_id                     XLA_ENTITY_ID
      --
      ,ard.code_combination_id          DIST_CCID
      ,ard.ref_dist_ccid                REF_DIST_CCID
      ,ctlgd.code_Combination_id        REF_CTLGD_CCID
      --
      ,cr.currency_code                 FROM_CURRENCY_CODE
      ,crh.exchange_rate                FROM_EXCHANGE_RATE
      ,crh.exchange_rate_type           FROM_EXCHANGE_RATE_TYPE
      ,crh.exchange_date                FROM_EXCHANGE_DATE
      ,-1 * (NVL(ard.from_amount_cr,0)-NVL(ard.from_amount_dr,0))               FROM_AMOUNT
      ,-1 * (NVL(ard.from_acctd_amount_cr,0)-NVL(ard.from_acctd_amount_dr,0))   FROM_ACCTD_AMOUNT
      --
      ,trx.invoice_currency_code        TO_CURRENCY_CODE
      ,trx.exchange_rate                EXCHANGE_RATE
      ,trx.exchange_rate_type           EXCHANGE_RATE_TYPE
      ,trx.exchange_date                EXCHANGE_DATE
      ,-1 * (NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0))                 AMOUNT
      ,-1 * (NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0))     ACCTD_AMOUNT
      --
      ,ra.receivable_application_id     RECEIVABLE_APPLICATION_ID
      ,ra.cash_receipt_id               CASH_RECEIPT_ID
      ,ra.applied_customer_trx_id       CUSTOMER_TRX_ID
      ,ard.ref_customer_trx_line_id     CUSTOMER_TRX_LINE_ID
      ,ard.ref_cust_trx_line_gl_dist_id    CUST_TRX_LINE_GL_DIST_ID
      --
      ,ctl.inventory_item_id               INVENTORY_ITEM_ID
      ,ctl.sales_tax_id                    SALES_TAX_ID
      ,trx.set_of_books_id                 SET_OF_BOOKS_ID
      ,trx.bill_to_site_use_id             BILL_SITE_USE_ID
      ,trx.sold_to_site_use_id             SOLD_SITE_USE_ID
      ,trx.ship_to_site_use_id             SHIP_SITE_USE_ID
      ,trx.bill_to_customer_id             BILL_CUSTOMER_ID
      ,trx.sold_to_customer_id             SOLD_CUSTOMER_ID
      ,trx.ship_to_customer_id             SHIP_CUSTOMER_ID
      ,ctl.tax_line_id                     TAX_LINE_ID
      --
      ,'Y'                                 SELECT_FLAG
      ,'L'                                 LEVEL_FLAG
      ,'T'                                 FROM_TO_FLAG
      ,'BANK_CHARGES'                      CRH_STATUS
      ,crh.status                          APP_CRH_STATUS
      --
      ,gt.event_type_code                  EVENT_TYPE_CODE
      ,gt.event_class_code                 EVENT_CLASS_CODE
      ,gt.entity_code                      ENTITY_CODE
      --
      ,ard.third_party_id                  third_party_id
      ,ard.third_party_sub_id              third_party_site_id
      ,DECODE(ard.third_party_id,NULL,NULL,'C')           third_party_type
      ,ard.source_type                       source_type
      ,abs(crh.amount + nvl(crh.factor_discount_amount,0)) RECP_AMOUNT
      ,abs(crh.acctd_amount + nvl(crh.acctd_factor_discount_amount,0)) RECP_ACCTD_AMOUNT
      ,abs(crhgt.amount) crh_amount
      ,abs(crhgt.acctd_amount) crh_acctd_amount
      ,crh.cash_receipt_history_id          CRH_RECORD_ID
  FROM xla_events_gt                      gt,
       ar_receivable_applications_all     ra,
       ar_cash_receipt_history_all        crh,
       ar_distributions_all               ard,
       ra_customer_trx_all                trx,
       ra_cust_trx_line_gl_dist_all       ctlgd,
       ra_customer_trx_lines_all          ctl,
       ar_cash_receipts_all               cr,
       gl_ledgers                         lg,
       ar_crh_gt			  crhgt
 WHERE gt.application_id                = 222
   AND gt.event_type_code               IN ('RECP_CREATE','RECP_UPDATE')
   AND gt.event_id                      = ra.event_id
   AND ra.status                        = 'APP'
   AND ard.source_id                    = ra.receivable_application_id
   AND ard.source_table                 = 'RA'
   AND nvl(ard.REF_MF_DIST_FLAG, 'Z')   <> 'U'
   AND ard.source_type NOT IN ('EXCH_GAIN','EXCH_LOSS')
   AND ra.cash_receipt_history_id       = crh.cash_receipt_history_id
   AND ra.cash_receipt_id               = cr.cash_receipt_id
   AND trx.set_of_books_id              = lg.ledger_id
   AND crh.cash_receipt_id              = cr.cash_receipt_id
   AND crh.posting_control_id           = -3
   AND ra.event_id			<> crh.event_id
   AND ard.ref_cust_trx_line_gl_dist_id = ctlgd.cust_trx_line_gl_dist_id(+)
   AND ard.ref_customer_trx_line_id     = ctl.customer_trx_line_id(+)
   AND ra.applied_customer_trx_id	= trx.customer_trx_id
   AND crhgt.cash_receipt_id		= crh.cash_receipt_id
   AND crhgt.cash_receipt_history_id	= crh.cash_receipt_history_id
   AND crhgt.status			= 'BANK_CHARGES'
   AND sign(crhgt.CRH_LINE_ID)          <> -1
   AND crh.status			= 'CLEARED'
   AND NVL(crh.factor_discount_amount,0) <> 0
   AND NVL(crh.acctd_factor_discount_amount,0) <> 0
   order by CASH_RECEIPT_ID, LINE_ID, CRH_RECORD_ID, CRH_STATUS
          ) ordered_crh;


-- crh_mfar_extract_record table type local variable
  l_crh_mfar_extract_record crh_mfar_extract_record_type;


BEGIN
  local_log(procedure_name => 'mfar_get_ra',
            p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.mfar_get_ra ()+');

 OPEN mfar_extract_app_cur;
 LOOP
   FETCH mfar_extract_app_cur BULK COLLECT INTO l_crh_mfar_extract_record LIMIT MAX_ARRAY_SIZE;
   IF PG_DEBUG in ('Y', 'C') THEN
	   arp_standard.debug('mfar_produit_app_by_crh current fetch count   '|| l_crh_mfar_extract_record.count);
   END IF;

   IF l_crh_mfar_extract_record.count = 0 THEN
	  EXIT;
   END IF;

-- Calculate prorated amounts and insert data into extract
  mfar_insert_crh_extract (l_crh_mfar_extract_record);

 END LOOP;

   CLOSE mfar_extract_app_cur;

  local_log(procedure_name => 'mfar_get_ra',
            p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.mfar_get_ra ()-');
EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'mfar_get_ra',
             p_msg_text     => 'EXCEPTION OTHERS in mfar_get_ra '||
                 arp_global.CRLF || 'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.mfar_get_ra'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;
END mfar_get_ra;

/*-----------------------------------------------------------------+
 | Procedure Name : mfar_rctapp_curr_round                         |
 | Description    : Create Line Level CURR_ROUND distributions     |
 |                  for MFAR Accounting Customers                  |
 +-----------------------------------------------------------------+
 | History        :                                                |
 | 02-AUG-2010     Anshu Kaushal    Created due to bug#9761480     |
 +-----------------------------------------------------------------*/
PROCEDURE mfar_rctapp_curr_round
IS
BEGIN
   local_log(procedure_name => 'mfar_rctapp_curr_round',
             p_msg_text     => 'arp_xla_extract_main_pkg.mfar_rctapp_curr_round ()+');

INSERT INTO ar_xla_lines_extract (
        EVENT_ID
       ,LINE_NUMBER
       ,LANGUAGE
       ,LEDGER_ID
       ,SOURCE_ID
       ,SOURCE_TABLE
       ,LINE_ID
       ,TAX_CODE_ID
       ,LOCATION_SEGMENT_ID
       ,BASE_CURRENCY_CODE
       ,EXCHANGE_RATE_TYPE
       ,EXCHANGE_RATE
       ,EXCHANGE_DATE
       ,ACCTD_AMOUNT
       ,TAXABLE_ACCTD_AMOUNT
       ,ORG_ID
       ,HEADER_TABLE_ID
       ,POSTING_ENTITY
       ,CASH_RECEIPT_ID
       ,CUSTOMER_TRX_ID
       ,CUSTOMER_TRX_LINE_ID
       ,CUST_TRX_LINE_GL_DIST_ID
       ,CUST_TRX_LINE_SALESREP_ID
       ,INVENTORY_ITEM_ID
       ,SALES_TAX_ID
       ,SO_ORGANIZATION_ID
       ,TAX_EXEMPTION_ID
       ,UOM_CODE
       ,WAREHOUSE_ID
       ,AGREEMENT_ID
       ,CUSTOMER_BANK_ACCT_ID
       ,DRAWEE_BANK_ACCOUNT_ID
       ,REMITTANCE_BANK_ACCT_ID
       ,DISTRIBUTION_SET_ID
       ,PAYMENT_SCHEDULE_ID
       ,RECEIPT_METHOD_ID
       ,RECEIVABLES_TRX_ID
       ,ED_ADJ_RECEIVABLES_TRX_ID
       ,UNED_RECEIVABLES_TRX_ID
       ,SET_OF_BOOKS_ID
       ,SALESREP_ID
       ,BILL_SITE_USE_ID
       ,DRAWEE_SITE_USE_ID
       ,PAYING_SITE_USE_ID
       ,SOLD_SITE_USE_ID
       ,SHIP_SITE_USE_ID
       ,RECEIPT_CUSTOMER_SITE_USE_ID
       ,BILL_CUST_ROLE_ID
       ,DRAWEE_CUST_ROLE_ID
       ,SHIP_CUST_ROLE_ID
       ,SOLD_CUST_ROLE_ID
       ,BILL_CUSTOMER_ID
       ,DRAWEE_CUSTOMER_ID
       ,PAYING_CUSTOMER_ID
       ,SOLD_CUSTOMER_ID
       ,SHIP_CUSTOMER_ID
       ,REMIT_ADDRESS_ID
       ,RECEIPT_BATCH_ID
       ,RECEIVABLE_APPLICATION_ID
       ,CUSTOMER_BANK_BRANCH_ID
       ,ISSUER_BANK_BRANCH_ID
       ,BATCH_SOURCE_ID
       ,BATCH_ID
       ,TERM_ID
       ,SELECT_FLAG
       ,LEVEL_FLAG
       ,FROM_TO_FLAG
       ,FROM_AMOUNT
       ,AMOUNT
       ,FROM_ACCTD_AMOUNT
       ,CRH_STATUS
       ,event_type_code
       ,event_class_code
       ,entity_code
       ,tax_line_id
       ,additional_char1
       ,FROM_EXCHANGE_RATE
       ,FROM_EXCHANGE_RATE_TYPE
       ,FROM_EXCHANGE_DATE
       ,FROM_CURRENCY_CODE
       ,TO_CURRENCY_CODE
       ,MFAR_ADDITIONAL_ENTRY
       ,SOURCE_TYPE
       ,DIST_CCID
       ,REF_DIST_CCID
       )
SELECT /*+LEADING(gt) USE_NL(gt, app)*/
           gt.event_id,                      -- EVENT_ID
           -1 * ar_mfar_extract_s.nextval,                     -- LINE_NUMBER
           '',                               -- LANGUAGE
           sob.set_of_books_id,              -- LEDGER_ID
           dist.source_id,                   -- SOURCE_ID
           dist.source_table,                -- SOURCE_TABLE
           dist.line_id,                     -- LINE_ID
           dist.tax_code_id,                 -- TAX_CODE_ID
           dist.location_segment_id,         -- LOCATION_SEGMENT_ID
           sob.currency_code,                -- BASE_CURRENCY
           trxt.exchange_rate_type,          -- EXCHANGE_RATE_TYPE
           trxt.exchange_rate,               -- EXCHANGE_RATE
           decode(trxt.invoice_currency_code,sob.currency_code,
                    trxt.trx_date, trxt.exchange_date),         -- EXCHANGE_DATE
           (NVL(dist.acctd_amount_dr,0) -
                NVL(dist.acctd_amount_cr,0)) - ( NVL(dist.from_acctd_amount_dr,0) -
                NVL(dist.from_acctd_amount_cr,0)) ACCTD_AMOUNT
           ,NVL(dist.taxable_accounted_dr,0) -
                NVL(dist.taxable_accounted_cr,0), -- TAXABLE_ACCTD_AMOUNT
           app.org_id,                       -- ORG_ID
           app.receivable_application_id,    -- HEADER_TABLE_ID
           'APP_CURR_ROUND',              -- POSTING_ENTITY
           NULL,                             -- CASH_RECEIPT_ID
           trxt.customer_trx_id,             -- CUSTOMER_TRX_ID
           tlt.customer_trx_line_id,         -- CUSTOMER_TRX_LINE_ID
           gldt.cust_trx_line_gl_dist_id,    -- CUST_TRX_LINE_GL_DIST_ID
           gldt.cust_trx_line_salesrep_id,   --  CUST_TRX_LINE_SALESREP_ID
           tlt.inventory_item_id,            -- INVENTORY_ITEM_ID
           tlt.sales_tax_id,                 -- SALES_TAX_ID
           osp.master_organization_id,       -- SO_ORGANIZATION_ID
           tlt.tax_exemption_id,             -- TAX_EXEMPTION_ID
           tlt.uom_code,                     -- UOM_CODE
           tlt.warehouse_id,                 -- WAREHOUSE_ID
           trxt.agreement_id,                -- AGREEMENT_ID
           trxt.customer_bank_account_id,    -- CUSTOMER_BANK_ACCT_ID
           trxt.drawee_bank_account_id,      -- DRAWEE_BANK_ACCOUNT_ID
           trxt.remit_bank_acct_use_id,  -- REMITTANCE_BANK_ACCT_ID
           NULL,                             -- DISTRIBUTION_SET_ID
           psch.payment_schedule_id,         -- PAYMENT_SCHEDULE_ID
           trxt.receipt_method_id,           -- RECEIPT_METHOD_ID
           NULL,                             -- RECEIVABLES_TRX_ID
           arp_xla_extract_main_pkg.ed_uned_trx('EDISC',app.org_id),       -- ED_ADJ_RECEIVABLES_TRX_ID
           arp_xla_extract_main_pkg.ed_uned_trx('UNEDISC',app.org_id),     -- UNED_RECEIVABLES_TRX_ID
           trxt.set_of_books_id,             -- SET_OF_BOOKS_ID
           trxt.primary_salesrep_id,         -- SALESREP_ID
           trxt.bill_to_site_use_id,         -- BILL_SITE_USE_ID
           trxt.drawee_site_use_id,          -- DRAWEE_SITE_USE_ID
           trxt.paying_site_use_id,          -- PAYING_SITE_USE_ID
           trxt.sold_to_site_use_id,         -- SOLD_SITE_USE_ID
           trxt.ship_to_site_use_id,         -- SHIP_SITE_USE_ID
           NULL,                             -- RECEIPT_CUSTOMER_SITE_USE_ID
           trxt.bill_to_contact_id,          -- BILL_CUST_ROLE_ID
           trxt.drawee_contact_id,           -- DRAWEE_CUST_ROLE_ID
           trxt.ship_to_contact_id,          -- SHIP_CUST_ROLE_ID
           trxt.sold_to_contact_id,          -- SOLD_CUST_ROLE_ID
           trxt.bill_to_customer_id,         -- BILL_CUSTOMER_ID
           trxt.drawee_id,                   -- DRAWEE_CUSTOMER_ID
           trxt.paying_customer_id,          -- PAYING_CUSTOMER_ID
           trxt.sold_to_customer_id,         -- SOLD_CUSTOMER_ID
           trxt.ship_to_customer_id,         -- SHIP_CUSTOMER_ID
           trxt.remit_to_address_id,         -- REMIT_ADDRESS_ID
           NULL,                             -- RECEIPT_BATCH_ID
           NULL,                             -- RECEIVABLE_APPLICATION_ID
           NULL,                             -- CUSTOMER_BANK_BRANCH_ID
           NULL,                             -- ISSUER_BANK_BRANCH_ID
           trxt.batch_source_id,             -- BATCH_SOURCE_ID
           trxt.batch_id,                    -- BATCH_ID
           trxt.term_id,                     -- TERM_ID
           'Y',                              -- SELECT_FLAG
           'L',                              -- LEVEL_FLAG
           'T',                              -- FROM_TO_FLAG
            (NVL(dist.amount_dr,0) - NVL(dist.amount_cr,0))
              - (NVL(dist.from_amount_dr,0) - NVL(dist.from_amount_cr,0)) FROM_AMOUNT
           ,(NVL(dist.amount_dr,0) - NVL(dist.amount_cr,0))
              - (NVL(dist.from_amount_dr,0) - NVL(dist.from_amount_cr,0)) AMOUNT
           , (NVL(dist.acctd_amount_dr,0) -
                NVL(dist.acctd_amount_cr,0)) - ( NVL(dist.from_acctd_amount_dr,0) -
                NVL(dist.from_acctd_amount_cr,0)) FROM_ACCTD_AMOUNT
	 ,'CURR_ROUND'
         ,gt.event_type_code
         ,gt.event_class_code
         ,gt.entity_code
         ,tlt.tax_line_id
         ,app.upgrade_method
	 ,cr.exchange_rate
	 ,cr.exchange_rate_type
	 ,cr.exchange_date
	 ,cr.currency_code
	 ,trxt.invoice_currency_code
         ,'Y'                    --MFAR_ADDITIONAL_ENTRY
         , 'CURR_ROUND'
         , currard.code_combination_id
         , dist.ref_dist_ccid
      FROM xla_events_gt                  gt,
           ar_receivable_applications_all app,
           ar_distributions_all           dist,
           gl_sets_of_books               sob,
           oe_system_parameters_all       osp,
           ra_customer_trx_all            trxt,
           ra_customer_trx_lines_all      tlt,
           ra_cust_trx_line_gl_dist_all   gldt,
           ar_payment_schedules_all       psch,
           ar_cash_receipts_all           cr,
           ar_distributions_all           currard
     WHERE gt.event_type_code IN ('RECP_CREATE' ,'RECP_UPDATE', 'RECP_RATE_ADJUST' )
       AND gt.application_id                 = 222
       AND gt.event_id                       = app.event_id
       AND (app.upgrade_method              IN ('R12_NLB','R12', 'R12_11IMFAR', 'R12_11ICASH','11I_R12_POST','R12_MERGE')
            OR (app.upgrade_method IS NULL AND app.status = 'APP')
       OR (DECODE(app.upgrade_method,
                       '11I_MFAR_UPG'    ,DECODE(dist.source_table_secondary,'UPMFRAMIAR','Y','N'),
                        'N')                  = 'Y'))
       AND app.set_of_books_id               = sob.set_of_books_id
       AND app.org_id                        = osp.org_id(+)
       AND app.applied_customer_trx_id       = trxt.customer_trx_id
       AND app.cash_receipt_id               = cr.cash_receipt_id
       AND dist.source_id                    = app.receivable_application_id
       AND dist.source_table                 = 'RA'
       AND dist.ref_customer_trx_line_id     = tlt.customer_trx_line_id(+)
       AND dist.ref_cust_trx_line_gl_dist_id = gldt.cust_trx_line_gl_dist_id(+)
       AND trxt.customer_trx_id              = psch.customer_trx_id
       AND NVL(psch.terms_sequence_number,1) = 1
       AND (NVL(dist.acctd_amount_cr,0) - NVL(dist.acctd_amount_dr,0))
	<> (NVL(dist.from_acctd_amount_cr,0) - NVL(dist.from_acctd_amount_dr,0))
       AND dist.source_type = 'REC'
       AND dist.source_id = currard.source_id
       AND dist.source_table = currard.source_table
       AND currard.source_type = 'CURR_ROUND';


   local_log(procedure_name => 'mfar_rctapp_curr_round',
             p_msg_text     => 'arp_xla_extract_main_pkg.mfar_rctapp_curr_round ()-');

EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'mfar_rctapp_curr_round',
             p_msg_text     => 'EXCEPTION OTHERS in arp_xla_extract_main_pkg.mfar_rctapp_curr_round '||
             arp_global.CRLF || 'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.mfar_rctapp_curr_round'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;
END mfar_rctapp_curr_round;


PROCEDURE mfar_mcd_dist_cr IS
BEGIN
  local_log(procedure_name => 'mfar_mcd_dist_cr',
            p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.mfar_mcd_dist_cr ()+');
INSERT INTO ar_crh_app_gt (
 entity_id
,receivable_application_id
,cash_receipt_history_id
,cash_receipt_history_status
,line_id
,amount
,acctd_amount
,from_amount
,from_acctd_amount
,third_party_id
,third_party_site_id
,third_party_type
,from_currency_code
,from_exchange_rate
,from_exchange_type
,from_exchange_date
,to_currency_code
,to_exchange_rate
,to_exchange_type
,to_exchange_date
,ref_customer_trx_line_id
,ref_cust_trx_line_gl_dist_id
,code_combination_id
,ref_code_combination_id
,ref_dist_ccid
,activity_bucket
,source_type
,source_table
,ra_post_indicator
,crh_post_indicator
,customer_trx_id
,inventory_item_id
,sales_tax_id
,tax_line_id
,bill_to_customer_id
,bill_to_site_use_id
,sold_to_customer_id
,sold_to_site_use_id
,ship_to_customer_id
,ship_to_site_use_id
,signed_receipt_amount)
SELECT xla.entity_id                           --entity_id
      ,mcd.misc_cash_distribution_id           --receivable_application_id
      ,NULL                                    --cash_receipt_history_id
      ,NULL                                    --cash_receipt_history_status
      ,ard.line_id                             --line_id
      ,NVL(ard.amount_cr,0)-
           NVL(ard.amount_dr,0)                --amount
      ,NVL(ard.acctd_amount_cr,0)-
           NVL(ard.acctd_amount_dr,0)          --acctd_amount
      ,NVL(ard.from_amount_cr,0)-
           NVL(ard.from_amount_dr,0)           --from_amount
      ,NVL(ard.from_acctd_amount_cr,0)-
           NVL(ard.from_acctd_amount_dr,0)     --from_acctd_amount
      ,NULL                                    --third_party_id
      ,NULL                                    --third_party_site_id
      ,NULL                                    --third_party_type
      ,cr.currency_code                        --from_currency_code
      ,NVL(crh.exchange_rate,cr.exchange_rate) --from_exchange_rate
      ,NVL(crh.exchange_rate_type,cr.exchange_rate_type) --from_exchange_type
      ,NVL(crh.exchange_date,cr.exchange_date) --from_exchange_date
      ,NULL                                    --to_currency_code
      ,NULL                                    --to_exchange_rate
      ,NULL                                    --to_exchange_type
      ,NULL                                    --to_exchange_date
      ,NULL                                    --ref_customer_trx_line_id
      ,NULL                                    --ref_cust_trx_line_gl_dist_id
      ,ard.code_combination_id                 --code_combination_id
      ,NULL                                    --ref_code_combination_id
      ,ard.ref_dist_ccid                       --ref_dist_ccid
      ,ard.activity_bucket                     --activity_bucket
      ,ard.source_type                         --source_type
      ,ard.source_table                        --source_table
      ,NULL                                    --ra_post_indicator
      ,NULL                                    --crh_post_indicator
      ,NULL                                    --customer_trx_id
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,cr.amount
  FROM ar_cash_receipts_all           cr
      ,ar_misc_cash_distributions_all mcd
      ,ar_cash_receipt_history_all    crh
      ,ar_distributions_all           ard
      ,(SELECT entity_id,
               source_id_int_1
          FROM xla_events_gt
         WHERE application_id  = 222
           AND event_type_code IN ('MISC_RECP_CREATE','MISC_RECP_UPDATE')
         GROUP BY entity_id,
                  source_id_int_1)    xla
 WHERE xla.source_id_int_1              = cr.cash_receipt_id
   AND cr.cash_receipt_id               = mcd.cash_receipt_id
   AND nvl(mcd.event_id, -1)            <> NVL((select event_id from ar_cash_receipt_history_all crh1 where
                                            crh1.cash_receipt_id = cr.cash_receipt_id and
                                            crh1.status='REVERSED' and crh1.current_record_flag = 'Y'),0)
   AND mcd.cash_receipt_history_id      = crh.cash_receipt_history_id(+)
   AND mcd.misc_cash_distribution_id    = ard.source_id
   AND ard.source_table                 = 'MCD';
  local_log(procedure_name => 'mfar_mcd_dist_cr',
            p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.mfar_mcd_dist_cr ()-');
EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'mfar_mcd_dist_cr',
             p_msg_text     => 'EXCEPTION OTHERS in mfar_mcd_dist_cr '||
                 arp_global.CRLF || 'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.mfar_mcd_dist_cr'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;
END;

PROCEDURE mfar_produit_mcd_by_crh  IS
BEGIN
  local_log(procedure_name => 'mfar_produit_mcd_by_crh',
            p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.mfar_produit_mcd_by_crh ()+');

INSERT INTO ar_xla_lines_extract
(EVENT_ID
,LINE_NUMBER
,MFAR_ADDITIONAL_ENTRY
,LEDGER_ID
,BASE_CURRENCY_CODE
,ORG_ID
,LINE_ID
,SOURCE_ID
,SOURCE_TABLE
,HEADER_TABLE_ID
,POSTING_ENTITY
,XLA_ENTITY_ID
--
,DIST_CCID
,REF_DIST_CCID
,REF_CTLGD_CCID
--
,FROM_CURRENCY_CODE
,FROM_EXCHANGE_RATE
,FROM_EXCHANGE_RATE_TYPE
,FROM_EXCHANGE_DATE
,FROM_AMOUNT
,FROM_ACCTD_AMOUNT
--
,TO_CURRENCY_CODE
,EXCHANGE_RATE
,EXCHANGE_RATE_TYPE
,EXCHANGE_DATE
,AMOUNT
,ACCTD_AMOUNT
--
,RECEIVABLE_APPLICATION_ID
,CASH_RECEIPT_ID
,CUSTOMER_TRX_ID
,CUSTOMER_TRX_LINE_ID
,CUST_TRX_LINE_GL_DIST_ID
--
,INVENTORY_ITEM_ID
,SALES_TAX_ID
,SET_OF_BOOKS_ID
,BILL_SITE_USE_ID
,SOLD_SITE_USE_ID
,SHIP_SITE_USE_ID
,BILL_CUSTOMER_ID
,SOLD_CUSTOMER_ID
,SHIP_CUSTOMER_ID
,TAX_LINE_ID
--
,SELECT_FLAG
,LEVEL_FLAG
,FROM_TO_FLAG
,CRH_STATUS
,APP_CRH_STATUS
--
,EVENT_TYPE_CODE
,EVENT_CLASS_CODE
,ENTITY_CODE)
SELECT
       crh.event_id                              --event_id
      ,-1 * ar_mfar_extract_s.NEXTVAL            --LINE_NUMBER
      ,'Y'                                       --MFAR_ADDITIONAL_ENTRY
      ,crh.ledger_id                             --LEDGER_ID
      ,crh.base_currency_code                    --BASE_CURRENCY_CODE
      ,crh.org_id                                --ORG_ID
      ,mcd.line_id                               --LINE_ID
      ,mcd.receivable_application_id             --SOURCE_ID --This misc_cash_dist_id only
      ,'MCD'                                     --SOURCE_TABLE
      ,crh.cash_receipt_id                       --HEADER_TABLE_ID
      ,'MISC_RECEIPT_HISTORY'                    --POSTING_ENTITY
      ,crh.entity_id                             --xla_entity_id
      --
      ,mcd.code_combination_id                   --DIST_CCID
      ,mcd.code_combination_id                   --ref_dist_ccid
      ,mcd.code_combination_id                   --REF_CTLGD_CCID
      --
      ,mcd.from_currency_code                    --from_currency_code
      ,mcd.from_exchange_rate                    --from_exchange_rate
      ,mcd.from_exchange_type                    --FROM_EXCHANGE_RATE_TYPE
      ,mcd.from_exchange_date                    --from_exchange_date
      ,SIGN(crh.amount)*mcd.from_amount*SIGN(signed_receipt_amount) --from_amount
      ,SIGN(crh.acctd_amount)*mcd.from_acctd_amount*SIGN(signed_receipt_amount)--from_acctd_amount
      --
      ,mcd.from_currency_code                    --to_currency_code
      ,mcd.from_exchange_rate                    --exchange_rate
      ,mcd.from_exchange_type                    --EXCHANGE_RATE_TYPE
      ,mcd.from_exchange_date                    --EXCHANGE_DATE
      ,SIGN(crh.amount)*mcd.amount*SIGN(signed_receipt_amount)               --amount
      ,SIGN(crh.acctd_amount)*mcd.acctd_amount*SIGN(signed_receipt_amount)   --acctd_amount
      --
      ,mcd.receivable_application_id             --RECEIVABLE_APPLICATION_ID --MISC_CASH_DIST_ID
      ,crh.cash_receipt_id                       --CASH_RECEIPT_ID
      ,NULL                                      --CUSTOMER_TRX_ID
      ,NULL                                      --CUSTOMER_TRX_LINE_ID
      ,NULL                                      --CUST_TRX_LINE_GL_DIST_ID
      --
      ,NULL                                      --INVENTORY_ITEM_ID
      ,NULL                                      --SALES_TAX_ID
      ,crh.ledger_id                             --SET_OF_BOOKS_ID
      ,NULL                                      --BILL_SITE_USE_ID
      ,NULL                                      --SOLD_SITE_USE_ID
      ,NULL                                      --SHIP_SITE_USE_ID
      ,NULL                                      --BILL_CUSTOMER_ID
      ,NULL                                      --SOLD_CUSTOMER_ID
      ,NULL                                      --SHIP_CUSTOMER_ID
      ,NULL                                      --TAX_LINE_ID
      --
      ,'Y'                                       --SELECT_FLAG
      ,'L'                                       --LEVEL_FLAG
      ,'T'                                       --FROM_TO_FLAG
      ,crh.status                                --CRH_STATUS
      ,NULL                                      --APP_CRH_STATUS
      --
      ,gt.event_type_code                        --EVENT_TYPE_CODE
      ,gt.event_class_code                       --EVENT_CLASS_CODE
      ,gt.entity_code                            --ENTITY_CODE
  FROM ar_crh_gt                                           crh,
       ar_crh_app_gt                                       mcd,
       xla_events_gt                                       gt
 WHERE crh.entity_id     = mcd.entity_id
   AND mcd.source_table  = 'MCD'
   AND crh.event_id      = gt.event_id;
  local_log(procedure_name => 'mfar_produit_mcd_by_crh',
            p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.mfar_produit_mcd_by_crh ()-');
EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'mfar_mcd_dist_cr',
             p_msg_text     => 'EXCEPTION OTHERS in mfar_produit_mcd_by_crh '||
                 arp_global.CRLF || 'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.mfar_produit_mcd_by_crh'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;
END;



PROCEDURE load_line_data_crh_mf(p_application_id IN NUMBER DEFAULT 222) IS
BEGIN
  NULL;
END;

--------------------------------------------------------

/*-----------------------------------------------------------------+
 | Procedure Name : Load_line_data_th                              |
 | Description    : Extract line data for Bill Receivable events   |
 +-----------------------------------------------------------------+
 | History        :                                                |
 | 23-FEB-2004     Herve Yu    Created due to bug#3419926          |
 +-----------------------------------------------------------------*/
PROCEDURE load_line_data_th(P_APPLICATION_ID IN NUMBER DEFAULT 222)
IS
BEGIN
   local_log(procedure_name => 'load_line_data_th',
             p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.load_line_data_th()+');

    INSERT INTO ar_xla_lines_extract (
        EVENT_ID
       ,LINE_NUMBER
       ,LANGUAGE
       ,LEDGER_ID
       ,SOURCE_ID
       ,SOURCE_TABLE
       ,LINE_ID
       ,TAX_CODE_ID
       ,LOCATION_SEGMENT_ID
       ,BASE_CURRENCY_CODE
       ,EXCHANGE_RATE_TYPE
       ,EXCHANGE_RATE
       ,EXCHANGE_DATE
       ,ACCTD_AMOUNT
       ,TAXABLE_ACCTD_AMOUNT
       ,ORG_ID
       ,HEADER_TABLE_ID
       ,POSTING_ENTITY
       ,CASH_RECEIPT_ID
       ,CUSTOMER_TRX_ID
       ,CUSTOMER_TRX_LINE_ID
       ,CUST_TRX_LINE_GL_DIST_ID
       ,CUST_TRX_LINE_SALESREP_ID
       ,INVENTORY_ITEM_ID
       ,SALES_TAX_ID
       ,SO_ORGANIZATION_ID
       ,TAX_EXEMPTION_ID
       ,UOM_CODE
       ,WAREHOUSE_ID
       ,AGREEMENT_ID
       ,CUSTOMER_BANK_ACCT_ID
       ,DRAWEE_BANK_ACCOUNT_ID
       ,REMITTANCE_BANK_ACCT_ID
       ,DISTRIBUTION_SET_ID
       ,PAYMENT_SCHEDULE_ID
       ,RECEIPT_METHOD_ID
       ,RECEIVABLES_TRX_ID
       ,ED_ADJ_RECEIVABLES_TRX_ID
       ,UNED_RECEIVABLES_TRX_ID
       ,SET_OF_BOOKS_ID
       ,SALESREP_ID
       ,BILL_SITE_USE_ID
       ,DRAWEE_SITE_USE_ID
       ,PAYING_SITE_USE_ID
       ,SOLD_SITE_USE_ID
       ,SHIP_SITE_USE_ID
       ,RECEIPT_CUSTOMER_SITE_USE_ID
       ,BILL_CUST_ROLE_ID
       ,DRAWEE_CUST_ROLE_ID
       ,SHIP_CUST_ROLE_ID
       ,SOLD_CUST_ROLE_ID
       ,BILL_CUSTOMER_ID
       ,DRAWEE_CUSTOMER_ID
       ,PAYING_CUSTOMER_ID
       ,SOLD_CUSTOMER_ID
       ,SHIP_CUSTOMER_ID
       ,REMIT_ADDRESS_ID
       ,RECEIPT_BATCH_ID
       ,RECEIVABLE_APPLICATION_ID
       ,CUSTOMER_BANK_BRANCH_ID
       ,ISSUER_BANK_BRANCH_ID
       ,BATCH_SOURCE_ID
       ,BATCH_ID
       ,TERM_ID
       ,SELECT_FLAG
       ,LEVEL_FLAG
       ,FROM_TO_FLAG
       ,FROM_AMOUNT
       ,AMOUNT
       ,FROM_ACCTD_AMOUNT
       ,PAIRED_CCID
       --{BUG#4356088
       ,event_type_code
       ,event_class_code
       ,entity_code
       --BUG#4645389
       ,tax_line_id
       --}
,MFAR_ADDITIONAL_ENTRY
       )
        SELECT /*+LEADING(gt) USE_NL(gt,th)*/
           gt.event_id,                      -- EVENT_ID
           ar_mfar_extract_s.NEXTVAL,        --LINE_NUMBER
           '',                               -- LANGUAGE
           sob.set_of_books_id,              -- LEDGER_ID
           dist.source_id,                   -- SOURCE_ID
           dist.source_table,                -- SOURCE_TABLE
           dist.line_id,                     -- LINE_ID
           dist.tax_code_id,                 -- TAX_CODE_ID
           dist.location_segment_id,         -- LOCATION_SEGMENT_ID
           sob.currency_code,                -- BASE_CURRENCY
           trx.exchange_rate_type     ,      -- EXCHANGE_RATE_TYPE
           trx.exchange_rate     ,           -- EXCHANGE_RATE
           trx.exchange_date     ,           -- EXCHANGE_DATE
           NVL(dist.acctd_amount_cr,0) -
               NVL(dist.acctd_amount_dr,0),      -- ACCTD_AMOUNT
           NVL(dist.taxable_accounted_cr,0) -
               NVL(dist.taxable_accounted_dr,0), -- TAXABLE_ACCTD_AMOUNT
           th.org_id,                        -- ORG_ID
           th.transaction_history_id,        -- HEADER_ID
           'TH',                             -- POSTING_ENTITY
           '',                               -- CASH_RECEIPT_ID
           th.customer_trx_id,               -- CUSTOMER_TRX_ID
           dist.ref_customer_trx_line_id,    -- CUSTOMER_TRX_LINE_ID
           dist.ref_cust_trx_line_gl_dist_id,--CUST_TRX_LINE_GL_DIST_ID
           gld.cust_trx_line_salesrep_id,    -- CUST_TRX_LINE_SALESREP_ID
           tl.inventory_item_id,             --INVENTORY_ITEM_ID
           tl.sales_tax_id,                  --SALES_TAX_ID
           osp.master_organization_id,       --SO_ORGANIZATION_ID
           tl.tax_exemption_id,              --TAX_EXEMPTION_ID
           tl.uom_code,                      --UOM_CODE
           tl.warehouse_id,                  --WAREHOUSE_ID
           trx.agreement_id,                 --AGREEMENT_ID
           trx.customer_bank_account_id,     --CUSTOMER_BANK_ACCT_ID
           '',                               --DRAWEE_BANK_ACCOUNT_ID
           trx.remit_bank_acct_use_id,   --REMITTANCE_BANK_ACCT_ID
           '',                               --DISTRIBUTION_SET_ID
           psch.payment_schedule_id,         --PAYMENT_SCHEDULE_ID
           '',                               --RECEIPT_METHOD_ID
           '',                               --RECEIVABLES_TRX_ID
           '',                               --ED_ADJ_RECEIVABLES_TRX_ID
           '',                               --UNED_RECEIVABLES_TRX_ID
           sob.set_of_books_id,              --SET_OF_BOOKS_ID
           trx.primary_salesrep_id,          --SALESREP_ID
           trx.bill_to_site_use_id,          --BILL_SITE_USE_ID
           trx.drawee_site_use_id,           --DRAWEE_SITE_USE_ID
           trx.paying_site_use_id,           --PAYING_SITE_USE_ID
           trx.sold_to_site_use_id,          --SOLD_SITE_USE_ID
           trx.ship_to_site_use_id,          --SHIP_SITE_USE_ID
           '',                               --RECEIPT_CUSTOMER_SITE_USE_ID
           trx.bill_to_contact_id,           --BILL_CUST_ROLE_ID
           trx.drawee_contact_id,            --DRAWEE_CUST_ROLE_ID
           trx.ship_to_contact_id,           --SHIP_CUST_ROLE_ID
           trx.sold_to_contact_id,           --SOLD_CUST_ROLE_ID
           trx.bill_to_customer_id,          --BILL_CUSTOMER_ID
           trx.drawee_id,                    --DRAWEE_CUSTOMER_ID
           trx.paying_customer_id,           --PAYING_CUSTOMER_ID
           trx.sold_to_customer_id,          --SOLD_CUSTOMER_ID
           trx.ship_to_customer_id,          --SHIP_CUSTOMER_ID
           '',                               --REMIT_ADDRESS_ID
           '',                               --RECEIPT_BATCH_ID
           '',                               --RECEIVABLE_APPLICATION_ID
           '',                               --CUSTOMER_BANK_BRANCH_ID
           '',                               --ISSUER_BANK_BRANCH_ID
           trx.batch_source_id,              --BATCH_SOURCE_ID
           trx.batch_id,                     --BATCH_ID
           trx.term_id,                      --TERM_ID
           'N',                              --SELECT_FLAG
           'L',                              --LEVEL_FLAG
           '',                               --FROM_TO_FLAG
           NVL(dist.from_amount_cr,0)
             -NVL(dist.from_amount_dr,0),    -- FROM_AMOUNT,
           NVL(dist.amount_cr,0)
             -NVL(dist.amount_dr,0),         -- AMOUNT
           NVL(dist.from_acctd_amount_cr,0)
             -NVL(dist.from_acctd_amount_dr,0), -- FROM_ACCTD_AMOUNT
           NULL                           -- PAIRED_CCID
         --{BUG#4356088
         ,gt.event_type_code
         ,gt.event_class_code
         ,gt.entity_code
         --BUG#4645389
         ,tl.tax_line_id       --tax_line_id
         ,'N'
      FROM xla_events_gt                  gt,
           ar_transaction_history_all     th,
           ra_customer_trx_all            trx,
           ra_customer_trx_lines_all      tl,
           ra_cust_trx_line_gl_dist_all   gld,
           oe_system_parameters_all       osp,
           ar_distributions_all           dist,
           gl_sets_of_books               sob,
           ar_payment_schedules_all       psch
     WHERE gt.event_type_code             IN ('BILL_CREATE'  ,
                                              'BILL_UPDATE'  ,
                                              'BILL_REVERSE'   )
       AND gt.application_id              = p_application_id
       AND gt.event_id                    = th.event_id
       AND dist.source_table              = 'TH'
       AND dist.source_id                 = th.transaction_history_id
       AND th.customer_trx_id             = trx.customer_trx_id
--       AND trx.customer_trx_id            = tl.customer_trx_id
--       AND trx.customer_trx_id            = gld.customer_trx_id
       AND th.org_id                      = osp.org_id(+)
       /*Pass double entries accounting*/
       --AND (    ( dist.source_type = 'REC' AND dist.source_table_secondary = 'CTL')
       --      OR ( dist.source_type <> 'REC'))
       AND dist.ref_customer_trx_line_id  = tl.customer_trx_line_id(+)
       AND dist.ref_cust_trx_line_gl_dist_id = gld.cust_trx_line_gl_dist_id(+)
       AND trx.set_of_books_id            = sob.set_of_books_id
       AND trx.customer_trx_id            = psch.customer_trx_id
       AND NVL(psch.terms_sequence_number,1) = 1;
   local_log(procedure_name => 'load_line_data_th',
             p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.load_line_data_th()-');
EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'load_line_data_th',
             p_msg_text     => 'EXCEPTION OTHERS in arp_xla_extract_main_pkg.load_line_data_th '||
              arp_global.CRLF ||  'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.load_line_data_th'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;
END load_line_data_th;


PROCEDURE load_line_data_mcd(p_application_id  IN NUMBER DEFAULT 222)
IS
BEGIN
   local_log(procedure_name => 'load_line_data_mcd',
             p_msg_text     => 'arp_xla_extract_main_pkg.load_line_data_mcd()+');
    -- Insert line level data in Line GT with
    -- selected_flag = N
    -- level_flag    = L
    -- From_to_flag  = NULL
    INSERT INTO ar_xla_lines_extract (
        EVENT_ID
       ,LINE_NUMBER
       ,LANGUAGE
       ,LEDGER_ID
       ,SOURCE_ID
       ,SOURCE_TABLE
       ,LINE_ID
       ,TAX_CODE_ID
       ,LOCATION_SEGMENT_ID
       ,BASE_CURRENCY_CODE
       ,EXCHANGE_RATE_TYPE
       ,EXCHANGE_RATE
       ,EXCHANGE_DATE
       ,ACCTD_AMOUNT
       ,TAXABLE_ACCTD_AMOUNT
       ,ORG_ID
       ,HEADER_TABLE_ID
       ,POSTING_ENTITY
       ,CASH_RECEIPT_ID
       ,CUSTOMER_TRX_ID
       ,CUSTOMER_TRX_LINE_ID
       ,CUST_TRX_LINE_GL_DIST_ID
       ,CUST_TRX_LINE_SALESREP_ID
       ,INVENTORY_ITEM_ID
       ,SALES_TAX_ID
       ,SO_ORGANIZATION_ID
       ,TAX_EXEMPTION_ID
       ,UOM_CODE
       ,WAREHOUSE_ID
       ,AGREEMENT_ID
       ,CUSTOMER_BANK_ACCT_ID
       ,DRAWEE_BANK_ACCOUNT_ID
       ,REMITTANCE_BANK_ACCT_ID
       ,DISTRIBUTION_SET_ID
       ,PAYMENT_SCHEDULE_ID
       ,RECEIPT_METHOD_ID
       ,RECEIVABLES_TRX_ID
       ,ED_ADJ_RECEIVABLES_TRX_ID
       ,UNED_RECEIVABLES_TRX_ID
       ,SET_OF_BOOKS_ID
       ,SALESREP_ID
       ,BILL_SITE_USE_ID
       ,DRAWEE_SITE_USE_ID
       ,PAYING_SITE_USE_ID
       ,SOLD_SITE_USE_ID
       ,SHIP_SITE_USE_ID
       ,RECEIPT_CUSTOMER_SITE_USE_ID
       ,BILL_CUST_ROLE_ID
       ,DRAWEE_CUST_ROLE_ID
       ,SHIP_CUST_ROLE_ID
       ,SOLD_CUST_ROLE_ID
       ,BILL_CUSTOMER_ID
       ,DRAWEE_CUSTOMER_ID
       ,PAYING_CUSTOMER_ID
       ,SOLD_CUSTOMER_ID
       ,SHIP_CUSTOMER_ID
       ,REMIT_ADDRESS_ID
       ,RECEIPT_BATCH_ID
       ,RECEIVABLE_APPLICATION_ID
       ,CUSTOMER_BANK_BRANCH_ID
       ,ISSUER_BANK_BRANCH_ID
       ,BATCH_SOURCE_ID
       ,BATCH_ID
       ,TERM_ID
       ,SELECT_FLAG
       ,LEVEL_FLAG
       ,FROM_TO_FLAG
       ,FROM_AMOUNT
       ,AMOUNT
       ,FROM_ACCTD_AMOUNT
       ,reversal_code
       ,MFAR_ADDITIONAL_ENTRY
       )
      -- FROM document type Cash Receipt
       SELECT /*+LEADING(gt) USE_NL(gt,mcd)*/
           gt.event_id,                        -- EVENT_ID
           dist.line_id,                       -- LINE_NUMBER
           '',                                 -- LANGUAGE
           sob.set_of_books_id,                -- LEDGER_ID
           dist.source_id,                     -- SOURCE_ID
           dist.source_table,                  -- SOURCE_TABLE
           dist.line_id,                       -- LINE_ID
           dist.tax_code_id,                   -- TAX_CODE_ID
           dist.location_segment_id,           -- LOCATION_SEGMENT_ID
           sob.currency_code,                  -- BASE_CURRENCY
           NVL(crh.exchange_rate_type,cr.exchange_rate_type), -- EXCHANGE_RATE_TYPE
           NVL(crh.exchange_rate,cr.exchange_rate)     ,      -- EXCHANGE_RATE
           NVL(crh.exchange_date,cr.exchange_date)     ,      -- EXCHANGE_DATE
           NVL(dist.acctd_amount_cr,0)
             - NVL(dist.acctd_amount_dr,0),      -- ACCTD_AMOUNT
           NVL(dist.taxable_accounted_cr,0)
             - NVL(dist.taxable_accounted_dr,0), -- TAXABLE_ACCTD_AMOUNT
           mcd.org_id,                         -- ORG_ID
           mcd.cash_receipt_id,      -- HEADER_ID
           'MCD',                              -- POSTING_ENTITY
           cr.cash_receipt_id,                 -- CASH_RECEIPT_ID
           NULL,                               -- CUSTOMER_TRX_ID
           NULL,                               -- CUSTOMER_TRX_LINE_ID
           NULL,                               -- CUST_TRX_LINE_GL_DIST_ID
           NULL,                               -- CUST_TRX_LINE_SALESREP_ID
           NULL,                               -- INVENTORY_ITEM_ID
           NULL,                               -- SALES_TAX_ID
           NULL,                               -- SO_ORGANIZATION_ID
           NULL,                               -- TAX_EXEMPTION_ID
           NULL,                               -- UOM_CODE
           NULL,                               -- WAREHOUSE_ID
           NULL,                               -- AGREEMENT_ID
           cr.customer_bank_account_id,        -- CUSTOMER_BANK_ACCT_ID
           NULL,                               -- DRAWEE_BANK_ACCOUNT_ID
           cr.remit_bank_acct_use_id,      -- REMITTANCE_BANK_ACCT_ID
           cr.distribution_set_id,             -- DISTRIBUTION_SET_ID
           NULL,                               -- PAYMENT_SCHEDULE_ID
           cr.receipt_method_id,               -- RECEIPT_METHOD_ID
           cr.receivables_trx_id,              -- RECEIVABLES_TRX_ID
           NULL,                               -- ED_ADJ_RECEIVABLES_TRX_ID
           NULL,                               -- UNED_RECEIVABLES_TRX_ID
           cr.set_of_books_id,                 -- SET_OF_BOOKS_ID
           NULL,                               -- SALESREP_ID
           cr.customer_site_use_id,            -- BILL_SITE_USE_ID
           NULL,                               -- DRAWEE_SITE_USE_ID
           cr.customer_site_use_id,            -- PAYING_SITE_USE_ID  -- synch with PAYING_CUSTOMER_ID
           NULL,                               -- SOLD_SITE_USE_ID
           NULL,                               -- SHIP_SITE_USE_ID
           cr.customer_site_use_id,            -- RECEIPT_CUSTOMER_SITE_USE_ID
           NULL,                               -- BILL_CUST_ROLE_ID
           NULL,                               -- DRAWEE_CUST_ROLE_ID
           NULL,                               -- SHIP_CUST_ROLE_ID
           NULL,                               -- SOLD_CUST_ROLE_ID
           NULL,                               -- BILL_CUSTOMER_ID
           NULL,                               -- DRAWEE_CUSTOMER_ID
           cr.pay_from_customer,               -- PAYING_CUSTOMER_ID
           NULL,                               -- SOLD_CUSTOMER_ID
           NULL,                               -- SHIP_CUSTOMER_ID
           NULL,                               -- REMIT_ADDRESS_ID
           cr.SELECTED_REMITTANCE_BATCH_ID,    -- RECEIPT_BATCH_ID
           NULL,                              -- RECEIVABLE_APPLICATION_ID
           cr.customer_bank_branch_id,         -- CUSTOMER_BANK_BRANCH_ID
           cr.issuer_bank_branch_id,           -- ISSUER_BANK_BRANCH_ID
           NULL,                               -- BATCH_SOURCE_ID
           NULL,                               -- BATCH_ID
           NULL,                               -- TERM_ID
           'N',                                -- SELECT_FLAG
           'L',                                -- LEVEL_FLAG
           '',                                -- FROM_TO_FLAG
           NVL(dist.from_amount_cr,0)
             -NVL(dist.from_amount_dr,0),      -- FROM_AMOUNT,
           NVL(dist.amount_cr,0)
             -NVL(dist.amount_dr,0),           -- AMOUNT
           NVL(dist.from_acctd_amount_cr,0)
             -NVL(dist.from_acctd_amount_dr,0) -- AMOUNT
           ,DECODE(gt.event_type_code,'MISC_RECP_REVERSE' ,'Y','N') --reversal_code
           ,'N'
        FROM xla_events_gt                  gt,
             ar_misc_cash_distributions_all mcd,
             ar_distributions_all           dist,
             gl_sets_of_books               sob,
             ar_cash_receipts_all           cr,
             --5201086
             ar_cash_receipt_history_all    crh
     WHERE gt.event_type_code IN (  'MISC_RECP_CREATE','MISC_RECP_RATE_ADJUST',
                                    'MISC_RECP_UPDATE') --Uptake XLA Reversal 'MISC_RECP_REVERSE' )
--'MISC_RECP_REVERSE' REVERSAL only needs header level source
       AND gt.event_id                    = mcd.event_id
       AND gt.application_id              = p_application_id
       AND dist.source_table              = 'MCD'
       AND dist.source_id                 = mcd.misc_cash_distribution_id
       AND mcd.set_of_books_id            = sob.set_of_books_id
       AND mcd.cash_receipt_id            = cr.cash_receipt_id
       AND mcd.cash_receipt_history_id    = crh.cash_receipt_history_id(+);
--       AND dist.source_type               = 'MISCCASH';

   local_log(procedure_name => 'load_line_data_mcd',
             p_msg_text     => 'arp_xla_extract_main_pkg.load_line_data_mcd()-');
EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'load_line_data_mcd',
             p_msg_text     => 'EXCEPTION OTHERS in arp_xla_extract_main_pkg.load_line_data_mcd '||
                arp_global.CRLF ||  'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.load_line_data_mcd'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;
END load_line_data_mcd;


-------------------------
-- Extraction program  --
-------------------------
/*------------------------------------------------------+
 | Procedure name : Extract                             |
 +------------------------------------------------------+
 | Parameter : accounting mode                          |
 |              D for Draft                             |
 |              F for final                             |
 |                                                      |
 | Purpose : Extract the AR accounting lines based      |
 |           on xla events passed by XLA_EVENTS_GT      |
 |           This routine is launched by XLA accounting |
 |           program in extract phase                   |
 |                                                      |
 | Modification history                                 |
 | 23-FEB-2004  H. Yu  bug#3419926 restructuration      |
 +------------------------------------------------------*/
--BUG#4387467
PROCEDURE extract(p_application_id     IN NUMBER
                 ,p_accounting_mode    IN VARCHAR2)
IS
CURSOR c_sob IS
SELECT set_of_books_id
  FROM ar_xla_lines_extract   gt
 WHERE posting_entity  in ('CR','CTLGD')
   AND select_flag     = 'Y'
   AND level_flag      = 'H'
   AND set_of_books_id IS NOT NULL
   AND event_class_code in ('RECEIPT','MISC_RECEIPT','CREDIT_MEMO');
l_sob_id    NUMBER;
BEGIN
   local_log(procedure_name => 'extract',
             p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.extract()+');
   local_log(procedure_name => 'extract',
             p_msg_text     => '     p_application_id  :'|| p_application_id );
   local_log(procedure_name => 'extract',
             p_msg_text     => '     p_accounting_mode :'|| p_accounting_mode);

    upgrade_11i_r12_post;

    -- Posting transaction
    load_header_data_ctlgd(p_application_id => p_application_id);
    load_line_data_ctlgd(p_application_id => p_application_id);
    load_line_data_app_from_cm(p_application_id => p_application_id);

    -- Posting Cash Receipt or Misc cash receipt
    Load_header_data_crh(p_application_id => p_application_id);

    Load_line_data_crh(p_application_id => p_application_id);

    -- Posting from Cash Receipt
    load_line_data_app_from_cr(p_application_id => p_application_id);

    -- Posting Cash Receipt or Credit Memo
    -- Only execute once for both Cash receipt and Credit Memo
    -- If executed twice then duplication of data.
    load_line_data_app_to_trx(p_application_id => p_application_id);

    -- Mis Cash Receipt Distributions
    load_line_data_mcd(p_application_id => p_application_id);

    -- Posting Adjustment
    Load_header_data_adj(p_application_id => p_application_id);
    Load_line_data_adj(p_application_id => p_application_id);

    -- Posting Bill Receivable
    Load_header_data_th(p_application_id => p_application_id);
    Load_line_data_th(p_application_id => p_application_id);

    --{Execute MFAR extract if neceessary
    OPEN c_sob;
    FETCH c_sob INTO l_sob_id;
    IF c_sob%NOTFOUND THEN
      l_sob_id := -9999;
    END IF;
    CLOSE c_sob;

     local_log(procedure_name => 'extract',
               p_msg_text     => 'l_sob_id: '||l_sob_id);


    IF l_sob_id <> -9999 THEN
      mfar_hook(p_ledger_id => l_sob_id) ;
    END IF;
    --}

   --{Conditional run for JL callout
   IF JL_BR_AR_BANK_ACCT_PKG.check_if_upgrade_occs THEN
      local_log(procedure_name => 'extract',
                p_msg_text     => ' JL Callout JL_BR_AR_BANK_ACCT_PKG.load_occurrences_header_data');
      JL_BR_AR_BANK_ACCT_PKG.load_occurrences_header_data(p_application_id => p_application_id);
   END IF;

   --}
--   IF fnd_profile.value('AR_EXTRACT_DIAG') = 'Y' THEN
   IF PG_DEBUG = 'Y' THEN
     diag_data;
   END IF;
--   END IF;

   local_log(procedure_name => 'extract',
             p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.extract()-');
EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'extract',
             p_msg_text     => 'EXCEPTION OTHERS in arp_xla_extract_main_pkg.extract '|| arp_global.CRLF ||
                               'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.extract'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
END extract;

--Old extract for testing purposes
PROCEDURE extract(p_accounting_mode IN VARCHAR2) IS
BEGIN
 extract(p_application_id  => 222
        ,p_accounting_mode => p_accounting_mode);
END;

-----------------
-- Post processing with XLA no more posting control id
-- In posting Entity, we can either use a dummy id in the column posting
-- control when the posting is successful.
-- As we use the posting control id in AR posting entity to indicate if
-- a document has been posted or not.
-- For now we still use the posting control id sequence to stamp the posted
-- documents, we can think of how to avoid maintaining this id going forward.
-----------------
-- The table in which the posting_control_id is present in AR are:
-- AR_MC_CASH_BASIS_DISTS_ALL     Obsolete unified Accrual and Cash basis accounting
-- AR_CASH_BASIS_DISTS_ALL        Obsolete unified Accrual and Cash basis accounting
-- RA_CUSTOMER_TRX_ALL            Do not post
-- AR_RATE_ADJUSTMENTS_ALL        Do not post
-- AR_CASH_RECEIPT_HISTORY_ALL     A  Those 4 A entities will post together
-- AR_MC_CASH_RECEIPT_HIST         A  (Misc) Cash Receipt
-- AR_MISC_CASH_DISTRIBUTIONS_ALL  A
-- AR_MC_MISC_CASH_DISTS           A
-- RA_CUST_TRX_LINE_GL_DIST_ALL    B  Those 2 B entities will post tpgether
-- RA_MC_TRX_LINE_GL_DIST          B  (Transactions)
-- AR_ADJUSTMENTS_ALL              C  Those 2 C entities will post together
-- AR_MC_ADJUSTMENTS               C  (Adjustments)
-- AR_RECEIVABLE_APPLICATIONS_ALL  D  Those 2 D entities will post together
-- AR_MC_RECEIVABLE_APPS           D  (Applications)
-- AR_TRANSACTION_HISTORY_ALL      E  Those 2 E entities will post together
-- AR_MC_TRANSACTION_HISTORY       E  (Bill Receivables)
--                                    Question are there any side effect
--                                    from BR on TRX ?
------------------
/*------------------------------------------------------+
 | Procedure name : flag_the_posting_id                 |
 +------------------------------------------------------+
 | Parameter : accounting mode                          |
 |              D for Draft                             |
 |              F for final                             |
 |                                                      |
 | Purpose : Stamping the posting control id in AR      |
 |           AR posting entities only for Final mode.   |
 |           This is used in the post acctg process     |
 |                                                      |
 | Modification history                                 |
 | 23-FEB-2004  H. Yu  Bug#3419926                      |
 +------------------------------------------------------*/
--BUG#4387467
PROCEDURE postaccounting
  (p_application_id         IN  NUMBER,
   p_ledger_id              IN  NUMBER,
   p_process_category       IN  VARCHAR2,
   p_end_date               IN  DATE,
   p_accounting_mode        IN  VARCHAR2,
   p_valuation_method       IN  VARCHAR2,
   p_security_id_int_1      IN  NUMBER,
   p_security_id_int_2      IN  NUMBER,
   p_security_id_int_3      IN  NUMBER,
   p_security_id_char_1     IN  NUMBER,
   p_security_id_char_2     IN  NUMBER,
   p_security_id_char_3     IN  NUMBER,
   p_report_request_id      IN  NUMBER)
IS
BEGIN
  NULL;
END;

--BUG#4387467
PROCEDURE postprocessing
(p_application_id        IN NUMBER
,p_accounting_mode       IN VARCHAR2)
IS
  l_pst_id     NUMBER;
  l_date       DATE;
BEGIN
   local_log(procedure_name => 'postprocessing',
             p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.postprocessing()+');

    IF  p_accounting_mode = 'F' THEN

      SELECT ar_posting_control_s.NEXTVAL
        INTO l_pst_id
        FROM DUAL;

      SELECT trunc(sysdate) INTO l_date FROM SYS.DUAL;
      --
      -- CRH
      -- GL Posting entiting are
      --   AR_CASH_RECEIPT_HISTORY_ALL,
      --   AR_MISC_CASH_DISTRIBUTIONS_ALL,
      --
      UPDATE ar_cash_receipt_history_all
         SET posting_control_id = l_pst_id,
             gl_posted_date     = l_date,
	     last_updated_by = fnd_global.user_id,
	     last_update_date = sysdate,
             last_update_login = fnd_global.user_id
       WHERE posting_control_id = -3
         AND (cash_receipt_id, event_id) IN
           (SELECT ev.source_id_int_1, ev.event_id
              FROM xla_post_acctg_events_v ev
             WHERE ev.application_id    = p_application_id
               AND ev.process_status_code = 'P'
               AND ev.event_type_code   IN
                ('RECP_CREATE'        ,
                 'RECP_UPDATE'        ,
                 'RECP_RATE_ADJUST'   ,
                 'RECP_REVERSE'       ,
                 'MISC_RECP_CREATE'   ,
                 'MISC_RECP_UPDATE'   ,
                 'MISC_RECP_RATE_ADJUST',
                 'MISC_RECP_REVERSE'    ));

      UPDATE AR_MISC_CASH_DISTRIBUTIONS_ALL
         SET posting_control_id = l_pst_id,
             gl_posted_date     = l_date,
	     last_updated_by = fnd_global.user_id,
	     last_update_date = sysdate,
             last_update_login = fnd_global.user_id
       WHERE posting_control_id = -3
         AND (cash_receipt_id, event_id) IN
             (SELECT ev.source_id_int_1, ev.event_id
                FROM xla_post_acctg_events_v ev
               WHERE ev.application_id    = p_application_id
                 AND ev.process_status_code = 'P'
                 AND ev.event_type_code   IN
                ('MISC_RECP_CREATE'   ,
                 'MISC_RECP_UPDATE'   ,
                 'MISC_RECP_RATE_ADJUST',
                 'MISC_RECP_REVERSE'  ));

      --
      -- CTLGD
      -- GL Posting entiting are
      --   RA_CUST_TRX_LINE_GL_DIST_ALL,
      --
      UPDATE /*+ INDEX(ra_cust_trx_line_gl_dist_all ra_cust_trx_line_gl_dist_n6) */
             ra_cust_trx_line_gl_dist_all
         SET posting_control_id = l_pst_id,
             gl_posted_date     = l_date,
	     last_updated_by = fnd_global.user_id,
	     last_update_date = sysdate,
             last_update_login = fnd_global.user_id
       WHERE posting_control_id = -3
         AND (customer_trx_id, event_id) IN
             (SELECT ev.source_id_int_1, ev.event_id
                FROM xla_post_acctg_events_v ev
               WHERE ev.application_id    = p_application_id
                 AND ev.process_status_code = 'P'
                 AND ev.event_type_code   IN
                ('INV_CREATE'     , 'INV_UPDATE'     ,
                 'CM_CREATE'      , 'CM_UPDATE'      ,
                 'DM_CREATE'      , 'DM_UPDATE'      ,
                 'DEP_CREATE'     , 'DEP_UPDATE' ,
                 'GUAR_CREATE'    , 'GUAR_UPDATE'    ,
                 'CB_CREATE'      ));

      --
      -- ADJ
      -- GL Posting entiting are
      --   AR_ADJUSTMENTS_ALL,
      --
      UPDATE ar_adjustments_all
         SET posting_control_id = l_pst_id,
             gl_posted_date     = l_date,
	     last_updated_by = fnd_global.user_id,
	     last_update_date = sysdate,
             last_update_login = fnd_global.user_id
       WHERE posting_control_id = -3
         AND adjustment_id IN
             (SELECT ev.source_id_int_1
                FROM xla_post_acctg_events_v ev
               WHERE ev.application_id    = p_application_id
                 AND ev.process_status_code = 'P'
                 AND ev.event_type_code   = 'ADJ_CREATE');

      --
      -- APP
      -- GL Posting entiting are
      --   AR_RECEIVABLE_APPLICATIONS_ALL,
      --
      UPDATE ar_receivable_applications_all
         SET posting_control_id = l_pst_id,
             gl_posted_date     = l_date,
	     last_updated_by = fnd_global.user_id,
	     last_update_date = sysdate,
             last_update_login = fnd_global.user_id
       WHERE posting_control_id = -3
         AND event_id IN
             (SELECT ev.event_id
                FROM xla_post_acctg_events_v ev
               WHERE ev.application_id    = p_application_id
                 AND ev.process_status_code = 'P'
                 AND ev.event_type_code   IN
                  ('CM_CREATE'      ,'CM_UPDATE'      ,
                   'RECP_CREATE'    ,'RECP_UPDATE'    ,
                   'RECP_RATE_ADJUST','RECP_REVERSE'  ,
                   'MISC_RECP_RATE_ADJUST','MISC_RECP_REVERSE'  ));

      --
      -- TH
      -- GL Posting entiting are
      --   AR_TRANSACTION_HISTORY_ALL,
      --
      UPDATE AR_TRANSACTION_HISTORY_ALL
         SET posting_control_id = l_pst_id,
             gl_posted_date     = l_date,
	     last_updated_by = fnd_global.user_id,
	     last_update_date = sysdate,
             last_update_login = fnd_global.user_id
       WHERE posting_control_id = -3
         AND postable_flag='Y'
         AND event_id IN
             (SELECT ev.event_id
                FROM xla_post_acctg_events_v ev
               WHERE ev.application_id    = p_application_id
                 AND ev.process_status_code = 'P'
                 AND ev.event_type_code   IN
                 ( 'BILL_CREATE'    ,
                   'BILL_UPDATE'    ,
                   'BILL_REVERSE'   ));

    END IF;
   local_log(procedure_name => 'postprocessing',
             p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.postprocessing()-');
EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'postprocessing',
             p_msg_text     =>'EXCEPTION OTHERS in arp_xla_extract_main_pkg.postprocessing '|| arp_global.CRLF ||
       'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.postprocessing '|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
END postprocessing;



PROCEDURE flag_the_posting_id(p_accounting_mode IN VARCHAR2)
IS
BEGIN
   local_log(procedure_name => 'flag_the_posting_id',
             p_msg_text     =>'arp_xla_extract_main_pkg.flag_the_posting_id()+');

    postprocessing(p_application_id    => 222
                  ,p_accounting_mode   => p_accounting_mode);

   local_log(procedure_name => 'flag_the_posting_id',
             p_msg_text     =>'ARP_XLA_EXTRACT_MAIN_PKG.flag_the_posting_id()-');
END flag_the_posting_id;


/*-----------------------------------------------------------+
 | Procedure name : lock_documents_for_xla                   |
 +-----------------------------------------------------------+
 | Parameter : None                                          |
 |                                                           |
 | Purpose : Locking the records concerned in a              |
 |           particular accounting program process.          |
 |                                                           |
 | Modification history                                      |
 | 23-FEB-2004   H. Yu   Bug#3419926 Redesign of acct events |
 +-----------------------------------------------------------*/
PROCEDURE preaccounting
( p_application_id     IN NUMBER
 ,p_ledger_id          IN NUMBER
 ,p_process_category   IN VARCHAR2
 ,p_end_date           IN DATE
 ,p_accounting_mode    IN VARCHAR2
 ,p_valuation_method   IN VARCHAR2
 ,p_security_id_int_1  IN NUMBER
 ,p_security_id_int_2  IN NUMBER
 ,p_security_id_int_3  IN NUMBER
 ,p_security_id_char_1 IN VARCHAR2
 ,p_security_id_char_2 IN VARCHAR2
 ,p_security_id_char_3 IN VARCHAR2
 ,p_report_request_id  IN NUMBER)
IS
BEGIN
   local_log(procedure_name =>'preaccounting',
             p_msg_text     =>'arp_xla_extract_main_pkg.preaccounting()+');

   local_log(procedure_name =>'preaccounting',
             p_msg_text     =>'  p_application_id    :'||p_application_id);
   local_log(procedure_name =>'preaccounting',
             p_msg_text     =>'  p_ledger_id         :'||p_ledger_id);
   local_log(procedure_name =>'preaccounting',
             p_msg_text     =>'  p_process_category  :'||p_process_category);
   local_log(procedure_name =>'preaccounting',
             p_msg_text     =>'  p_end_date          :'||p_end_date);
   local_log(procedure_name =>'preaccounting',
             p_msg_text     =>'  p_accounting_mode   :'||p_accounting_mode);
   local_log(procedure_name =>'preaccounting',
             p_msg_text     =>'  p_valuation_method  :'||p_valuation_method);
   local_log(procedure_name =>'preaccounting',
             p_msg_text     =>'  p_security_id_int_1 :'||p_security_id_int_1);
   local_log(procedure_name =>'preaccounting',
             p_msg_text     =>'  p_security_id_int_2 :'||p_security_id_int_2);
   local_log(procedure_name =>'preaccounting',
             p_msg_text     =>'  p_security_id_int_3 :'||p_security_id_int_3);
   local_log(procedure_name =>'preaccounting',
             p_msg_text     =>'  p_security_id_char_1:'||p_security_id_char_1);
   local_log(procedure_name =>'preaccounting',
             p_msg_text     =>'  p_security_id_char_2:'||p_security_id_char_2);
   local_log(procedure_name =>'preaccounting',
             p_msg_text     =>'  p_security_id_char_3:'||p_security_id_char_3);
   local_log(procedure_name =>'preaccounting',
             p_msg_text     =>'  p_report_request_id :'||p_report_request_id);

--{
--BUG#5366837
--No need to run this code anymore as we upgrade unposted cash basis data and upgrade PSA dist to AR for adj - app -crh
--For transaction although not upgraded MFAR AAD will build the correct accounting
--{Unification of Cash Basis Accounting
-- local_log(procedure_name =>'preaccounting',
--           p_msg_text     =>'  call unification of cash basis : ar_upgrade_cash_accrual.create_cash_distributions');
--
--       ar_upgrade_cash_accrual.create_distributions;
--
-- local_log(procedure_name =>'preaccounting',
--           p_msg_text     =>'  locking distribution rows');
--}

       -- CTLGD
        SELECT 'lock'
          BULK COLLECT INTO l_lock
          FROM xla_entity_events_v          eve,
               ra_cust_trx_line_gl_dist_all ctlgd
         WHERE eve.request_id           = p_report_request_id
           AND eve.application_id       = p_application_id
           AND eve.entity_code          = 'TRANSACTIONS'
           AND eve.event_id             = ctlgd.event_id
           AND ctlgd.posting_control_id = -3
           AND ctlgd.account_set_flag   = 'N'
        FOR UPDATE OF ctlgd.cust_trx_line_gl_dist_id;

        -- ADJ
        SELECT 'lock'
          BULK COLLECT INTO l_lock
          FROM xla_entity_events_v          eve,
		       ar_adjustments_all           adj
         WHERE eve.request_id           = p_report_request_id
           AND eve.application_id       = p_application_id
           AND eve.entity_code          = 'ADJUSTMENTS'
           AND eve.event_id             = adj.event_id
           AND adj.posting_control_id   = -3
           AND NVL(adj.postable,'Y')    = 'Y'
        FOR UPDATE OF adjustment_id;

        -- APP
        SELECT 'lock'
          BULK COLLECT INTO l_lock
          FROM xla_entity_events_v            eve,
               ar_receivable_applications_all app
         WHERE eve.request_id             = p_report_request_id
           AND eve.application_id         = p_application_id
           AND eve.entity_code           IN ('RECEIPTS','TRANSACTIONS')
           AND eve.event_id               = app.event_id
           AND app.posting_control_id     = -3
           AND NVL(app.postable,'Y')      ='Y'
           AND NVL(app.confirmed_flag,'Y')='Y'
        FOR UPDATE OF receivable_application_id;

        -- CRH MCD
        SELECT 'lock'
          BULK COLLECT INTO l_lock
          FROM xla_entity_events_v         eve,
               ar_cash_receipt_history_all crh
         WHERE eve.request_id           = p_report_request_id
           AND eve.application_id       = p_application_id
           AND eve.entity_code          = 'RECEIPTS'
           AND eve.event_id             = crh.event_id
           AND crh.posting_control_id   = -3
        FOR UPDATE OF crh.cash_receipt_history_id;

        SELECT 'lock'
          BULK COLLECT INTO l_lock
          FROM xla_entity_events_v            eve,
               ar_misc_cash_distributions_all mcd
         WHERE eve.request_id           = p_report_request_id
           AND eve.application_id       = p_application_id
           AND eve.entity_code          = 'RECEIPTS'
           AND eve.event_id             = mcd.event_id
           AND mcd.posting_control_id   = -3
        FOR UPDATE OF misc_cash_distribution_id;

        --TRH
        SELECT 'lock'
          BULK COLLECT INTO l_lock
          FROM xla_entity_events_v            eve,
               ar_transaction_history_all     trh
         WHERE eve.request_id           = p_report_request_id
           AND eve.application_id       = p_application_id
           AND eve.entity_code          = 'BILLS_RECEIVABLE'
           AND eve.event_id             = trh.event_id
           AND trh.postable_flag        = 'Y'
           AND trh.posting_control_id   = -3
        FOR UPDATE OF trh.transaction_history_id;

   local_log(procedure_name =>'preaccounting',
             p_msg_text     =>'arp_xla_extract_main_pkg.preaccounting -');
EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name =>'preaccounting',
             p_msg_text     =>'EXCEPTION OTHERS in arp_xla_extract_main_pkg.lock_documents_for_xla '||
             arp_global.CRLF || 'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.lock_documents_for_xla'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
END preaccounting;


-- This routine is no longer usefull
-- Keep this routine in order not to break the current code
PROCEDURE lock_documents_for_xla IS
BEGIN
  NULL;
END;

/*------------------------------------------------------+
 | Procedure name : locking_status                      |
 +------------------------------------------------------+
 | Parameter : Workflow rule function subscription      |
 |             standard parameters.                     |
 |                                                      |
 | Purpose : Allow the procedure lock_documents_for_xla |
 |           to be called in Workflow 2.6               |
 |                                                      |
 | Modification history                                 |
 +------------------------------------------------------*/
FUNCTION locking_status(p_subscription_guid IN RAW,
                        p_event             IN OUT NOCOPY wf_event_t)
RETURN VARCHAR2
IS
  l_application_id   NUMBER;
BEGIN
  l_application_id  := p_event.GetValueForParameter('APPLICATION_ID');
  IF l_application_id = 222 THEN
    lock_documents_for_xla;
  END IF;
  RETURN 'SUCCESS';
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
'Procedure:arp_xla_extract_main_pkg.lock_documents_for_xla
Error:'||SQLERRM);
    FND_MSG_PUB.ADD;
--    APP_EXCEPTION.RAISE_EXCEPTION;
    RETURN 'ERROR';
END locking_status;


/*------------------------------------------------------+
 | Procedure name : extract_status                      |
 +------------------------------------------------------+
 | Parameter : Workflow rule function subscription      |
 |             standard parameters.                     |
 |                                                      |
 | Purpose : Allow the procedure extract                |
 |           to be called in Workflow 2.6               |
 |                                                      |
 | Modification history                                 |
 +------------------------------------------------------*/
FUNCTION extract_status(p_subscription_guid IN RAW,
                        p_event             IN OUT NOCOPY wf_event_t)
RETURN VARCHAR2
IS
  l_mode            VARCHAR2(30);
  l_application_id  NUMBER;
BEGIN
  l_application_id  := p_event.GetValueForParameter('APPLICATION_ID');
  IF l_application_id = 222 THEN
    l_mode := p_event.GetValueForParameter('ACCOUNTING_MODE');
    extract(p_accounting_mode => l_mode);
  END IF;
  RETURN 'SUCCESS';
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
'Procedure:arp_xla_extract_main_pkg.extract
Mode:'||l_mode||'
Error:'||SQLERRM);
    FND_MSG_PUB.ADD;
--    APP_EXCEPTION.RAISE_EXCEPTION;
    RETURN 'ERROR';
END extract_status;


/*------------------------------------------------------+
 | Procedure name : posting_ctl_status                  |
 +------------------------------------------------------+
 | Parameter : Workflow rule function subscription      |
 |             standard parameters.                     |
 |                                                      |
 | Purpose : Allow the procedure flag_the_posting_id    |
 |           to be called in Workflow 2.6               |
 |                                                      |
 | Modification history                                 |
 +------------------------------------------------------*/
FUNCTION posting_ctl_status(p_subscription_guid IN RAW,
                            p_event             IN OUT NOCOPY wf_event_t)
RETURN VARCHAR2
IS
  l_key              VARCHAR2(240) := p_event.GetEventKey();
  l_mode             VARCHAR2(30);
  l_application_id   NUMBER;
  l_mode_exception   EXCEPTION;
BEGIN
  l_application_id  := p_event.GetValueForParameter('APPLICATION_ID');
  IF l_application_id = 222 THEN
    l_mode := p_event.GetValueForParameter('ACCOUNTING_MODE');
    IF l_mode NOT IN ('D','F') THEN
      RAISE l_mode_exception;
    END IF;
    flag_the_posting_id(p_accounting_mode => l_mode);
  END IF;
  RETURN 'SUCCESS';
EXCEPTION
  WHEN l_mode_exception THEN
    -- As the error message is only useful for debugging and it has
    -- no functional impact. For now, the FND_GENERIC_MESSAGE is used
    -- We might need to end up seeded messages later.
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
'Procedure:arp_xla_extract_main_pkg.posting_ctl_status
Error: accounting is '||l_mode||' - mode should be D (Draft) or F (Final)');
    FND_MSG_PUB.ADD;
--    APP_EXCEPTION.RAISE_EXCEPTION;
    RETURN 'ERROR';
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
'Procedure:arp_xla_extract_main_pkg.posting_ctl_status
Mode:'||l_mode||'
Error:'||SQLERRM);
    FND_MSG_PUB.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
    RETURN 'ERROR';
END posting_ctl_status;


--{Get GL segment info
PROCEDURE  get_segment_value
(p_segment_name    IN VARCHAR2,
 p_coa_id          IN NUMBER,
 p_ccid            IN NUMBER,
 x_segment_value   OUT NOCOPY VARCHAR2)
IS
 l_c           INTEGER;
 l_exec        INTEGER;
 l_fetch_row   INTEGER;
 l_stmt        VARCHAR2(2000);
 l_xla_user    VARCHAR2(30);
BEGIN
--local_log('arp_xla_extract_main_pkg',' get_segment_value +');
    l_stmt :=
' SELECT '||p_segment_name||'
  FROM gl_code_combinations
 WHERE chart_of_accounts_id = :coa_id
   AND code_combination_id  = :ccid ';
--local_log('arp_xla_extract_main_pkg',' l_stmt :'||l_stmt);
    l_c  := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(l_c, l_stmt, DBMS_SQL.NATIVE);
    DBMS_SQL.BIND_VARIABLE(l_c,':coa_id',p_coa_id);
    DBMS_SQL.BIND_VARIABLE(l_c,':ccid',p_ccid);
    DBMS_SQL.DEFINE_COLUMN(l_c,1,x_segment_value,30);
    l_exec := DBMS_SQL.EXECUTE(l_c);
    l_fetch_row := DBMS_SQL.FETCH_ROWS(l_c);
    DBMS_SQL.COLUMN_VALUE(l_c, 1, x_segment_value);
    DBMS_SQL.CLOSE_CURSOR(l_c);
--local_log('arp_xla_extract_main_pkg',' get_segment_value -');
END;

PROCEDURE mfar_insert_crh_extract (p_crh_mfar_extract_record crh_mfar_extract_record_type)
IS
-- run time variables for proration
  x_run_amt             number := 0;
  x_run_alloc_amt       number := 0;
  x_alloc_amt           number := 0;

  x_run_acctd_amt       number := 0;
  x_run_alloc_acctd_amt number := 0;
  x_alloc_acctd_amt     number := 0;

  x_run_from_amt             number := 0;
  x_run_alloc_from_amt       number := 0;
  x_alloc_from_amt           number := 0;

  x_run_from_acctd_amt       number := 0;
  x_run_alloc_from_acctd_amt number := 0;
  x_alloc_from_acctd_amt     number := 0;

  x_CRH_RECORD_ID          number := 0;
  x_LINE_ID		             number := 0;
  i                        number := 0;

-- pl/sql table for ar_xla_lines_extract
   TYPE ar_xla_mfar_extract_gt_tab IS TABLE OF ar_xla_lines_extract%ROWTYPE
      INDEX BY BINARY_INTEGER;
   l_mfar_extract_tab ar_xla_mfar_extract_gt_tab;


BEGIN
local_log(procedure_name => 'mfar_insert_crh_extract',
            p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.mfar_insert_crh_extract ()+');

  FOR i IN p_crh_mfar_extract_record.FIRST..p_crh_mfar_extract_record.LAST
  LOOP

-- For CRH Sources Cash and Bank Charges, accounted amounts can be lesser than applied amounts.
-- In such cases we need to prorate the Cash and Bank Charge over applied to invoice distributions.

    IF p_crh_mfar_extract_record(i).CRH_STATUS IN ('CLEARED','BANK_CHARGES')
        AND p_crh_mfar_extract_record(i).crh_acctd_amount <> p_crh_mfar_extract_record(i).recp_acctd_amount THEN

-- Reset run time variables for a new CRH Source Line from ARD

    IF (p_crh_mfar_extract_record(i).LINE_ID <> x_LINE_ID OR
        p_crh_mfar_extract_record(i).CRH_RECORD_ID <> x_CRH_RECORD_ID)  THEN

 local_log(procedure_name => 'mfar_insert_crh_extract',
            p_msg_text     => 'Reset Run Amounts LINE_ID : '||p_crh_mfar_extract_record(i).LINE_ID||', CRH_RECORD_ID : '||p_crh_mfar_extract_record(i).CRH_RECORD_ID);

      x_run_amt       := 0;
      x_run_alloc_amt := 0;
      x_run_acctd_amt       := 0;
      x_run_alloc_acctd_amt := 0;
      x_run_from_amt       := 0;
      x_run_alloc_from_amt := 0;
      x_run_from_acctd_amt       := 0;
      x_run_alloc_from_acctd_amt := 0;

    END IF;

    x_LINE_ID   := p_crh_mfar_extract_record(i).LINE_ID;
    x_CRH_RECORD_ID      := p_crh_mfar_extract_record(i).CRH_RECORD_ID;


-- Proration of Amounts
    x_run_amt       := x_run_amt + p_crh_mfar_extract_record(i).crh_acctd_amount;
    x_alloc_amt     := ar_unposted_item_util.currRound((x_run_amt/p_crh_mfar_extract_record(i).recp_acctd_amount)
                             * p_crh_mfar_extract_record(i).amount,p_crh_mfar_extract_record(i).FROM_CURRENCY_CODE)
                                  - x_run_alloc_amt;
    x_run_alloc_amt := x_run_alloc_amt + x_alloc_amt;


-- Proration of Accounted Amounts
    x_run_acctd_amt       := x_run_acctd_amt + p_crh_mfar_extract_record(i).crh_acctd_amount;
    x_alloc_acctd_amt     := ar_unposted_item_util.currRound((x_run_acctd_amt/p_crh_mfar_extract_record(i).recp_acctd_amount)
                                        * p_crh_mfar_extract_record(i).acctd_amount,p_crh_mfar_extract_record(i).BASE_CURRENCY_CODE) - x_run_alloc_acctd_amt;
    x_run_alloc_acctd_amt := x_run_alloc_acctd_amt + x_alloc_acctd_amt;



-- Proration of From Amounts
    x_run_from_amt       := x_run_from_amt + p_crh_mfar_extract_record(i).crh_acctd_amount;
    x_alloc_from_amt     := ar_unposted_item_util.currRound((x_run_from_amt/p_crh_mfar_extract_record(i).recp_acctd_amount)
                             * p_crh_mfar_extract_record(i).from_amount,p_crh_mfar_extract_record(i).FROM_CURRENCY_CODE)
                                  - x_run_alloc_from_amt;
    x_run_alloc_from_amt := x_run_alloc_from_amt + x_alloc_from_amt;

-- Proration of From Accounted Amounts
   x_run_from_acctd_amt       := x_run_from_acctd_amt + p_crh_mfar_extract_record(i).crh_acctd_amount;
    x_alloc_from_acctd_amt     := ar_unposted_item_util.currRound((x_run_from_acctd_amt/p_crh_mfar_extract_record(i).recp_acctd_amount)
                                        * p_crh_mfar_extract_record(i).from_acctd_amount,p_crh_mfar_extract_record(i).BASE_CURRENCY_CODE) - x_run_alloc_from_acctd_amt;
    x_run_alloc_from_acctd_amt := x_run_alloc_from_acctd_amt + x_alloc_from_acctd_amt;


--
local_log(procedure_name => 'mfar_insert_crh_extract',
            p_msg_text     => 'crh_acctd_amount : '||p_crh_mfar_extract_record(i).crh_acctd_amount);
local_log(procedure_name => 'mfar_insert_crh_extract',
            p_msg_text     => 'recp_acctd_amount : '||p_crh_mfar_extract_record(i).recp_acctd_amount);
local_log(procedure_name => 'mfar_insert_crh_extract',
            p_msg_text     => 'amount : '||p_crh_mfar_extract_record(i).amount);
local_log(procedure_name => 'mfar_insert_crh_extract',
            p_msg_text     => 'acctd_amount : '||p_crh_mfar_extract_record(i).acctd_amount);
local_log(procedure_name => 'mfar_insert_crh_extract',
            p_msg_text     => 'from_amount : '||p_crh_mfar_extract_record(i).from_amount);
local_log(procedure_name => 'mfar_insert_crh_extract',
            p_msg_text     => 'from_acctd_amount : '||p_crh_mfar_extract_record(i).from_acctd_amount);


local_log(procedure_name => 'mfar_insert_crh_extract',p_msg_text  => '  x_run_amt                  : '||x_run_amt);
local_log(procedure_name => 'mfar_insert_crh_extract',p_msg_text  => '  x_alloc_amt                : '||x_alloc_amt);
local_log(procedure_name => 'mfar_insert_crh_extract',p_msg_text  => '  x_run_alloc_amt            : '||x_run_alloc_amt);
local_log(procedure_name => 'mfar_insert_crh_extract',p_msg_text  => '  x_run_acctd_amt            : '||x_run_acctd_amt);
local_log(procedure_name => 'mfar_insert_crh_extract',p_msg_text  => '  x_alloc_acctd_amt          : '||x_alloc_acctd_amt);
local_log(procedure_name => 'mfar_insert_crh_extract',p_msg_text  => '  x_run_alloc_acctd_amt      : '||x_run_alloc_acctd_amt);
local_log(procedure_name => 'mfar_insert_crh_extract',p_msg_text  => '  x_run_from_amt             : '||x_run_from_amt);
local_log(procedure_name => 'mfar_insert_crh_extract',p_msg_text  => '  x_alloc_from_amt           : '||x_alloc_from_amt);
local_log(procedure_name => 'mfar_insert_crh_extract',p_msg_text  => '  x_run_alloc_from_amt       : '||x_run_alloc_from_amt);
local_log(procedure_name => 'mfar_insert_crh_extract',p_msg_text  => '  x_run_from_acctd_amt       : '||x_run_from_acctd_amt);
local_log(procedure_name => 'mfar_insert_crh_extract',p_msg_text  => '  x_alloc_from_acctd_amt     : '||x_alloc_from_acctd_amt);
local_log(procedure_name => 'mfar_insert_crh_extract',p_msg_text  => '  x_run_alloc_from_acctd_amt : '||x_run_alloc_from_acctd_amt);
--
  ELSE
-- No calculation when proration is not required
    x_alloc_amt             := p_crh_mfar_extract_record(i).amount;
    x_alloc_acctd_amt       := p_crh_mfar_extract_record(i).acctd_amount;
    x_alloc_from_amt        := p_crh_mfar_extract_record(i).from_amount;
    x_alloc_from_acctd_amt  := p_crh_mfar_extract_record(i).from_acctd_amount;
  END IF;

-- Assign the values to extract table
    l_mfar_extract_tab(i).EVENT_ID                := p_crh_mfar_extract_record(i).EVENT_ID;
    l_mfar_extract_tab(i).LINE_NUMBER             := p_crh_mfar_extract_record(i).LINE_NUMBER;
    l_mfar_extract_tab(i).MFAR_ADDITIONAL_ENTRY   := p_crh_mfar_extract_record(i).MFAR_ADDITIONAL_ENTRY;
    l_mfar_extract_tab(i).LEDGER_ID               := p_crh_mfar_extract_record(i).LEDGER_ID;
    l_mfar_extract_tab(i).BASE_CURRENCY_CODE      := p_crh_mfar_extract_record(i).BASE_CURRENCY_CODE;
    l_mfar_extract_tab(i).ORG_ID                  := p_crh_mfar_extract_record(i).ORG_ID;
    l_mfar_extract_tab(i).LINE_ID                 := p_crh_mfar_extract_record(i).LINE_ID;
    l_mfar_extract_tab(i).SOURCE_ID               := p_crh_mfar_extract_record(i).SOURCE_ID;
    l_mfar_extract_tab(i).SOURCE_TABLE            := p_crh_mfar_extract_record(i).SOURCE_TABLE;
    l_mfar_extract_tab(i).HEADER_TABLE_ID         := p_crh_mfar_extract_record(i).HEADER_TABLE_ID;
    l_mfar_extract_tab(i).POSTING_ENTITY          := p_crh_mfar_extract_record(i).POSTING_ENTITY;
    l_mfar_extract_tab(i).XLA_ENTITY_ID           := p_crh_mfar_extract_record(i).XLA_ENTITY_ID;
--
    l_mfar_extract_tab(i).DIST_CCID               := p_crh_mfar_extract_record(i).DIST_CCID;
    l_mfar_extract_tab(i).REF_DIST_CCID           := p_crh_mfar_extract_record(i).REF_DIST_CCID;
    l_mfar_extract_tab(i).REF_CTLGD_CCID          := p_crh_mfar_extract_record(i).REF_CTLGD_CCID;
--
    l_mfar_extract_tab(i).FROM_CURRENCY_CODE      := p_crh_mfar_extract_record(i).FROM_CURRENCY_CODE;
    l_mfar_extract_tab(i).FROM_EXCHANGE_RATE      := p_crh_mfar_extract_record(i).FROM_EXCHANGE_RATE;
    l_mfar_extract_tab(i).FROM_EXCHANGE_RATE_TYPE := p_crh_mfar_extract_record(i).FROM_EXCHANGE_RATE_TYPE;
    l_mfar_extract_tab(i).FROM_EXCHANGE_DATE      := p_crh_mfar_extract_record(i).FROM_EXCHANGE_DATE;
    l_mfar_extract_tab(i).FROM_AMOUNT             := x_alloc_from_amt;
    l_mfar_extract_tab(i).FROM_ACCTD_AMOUNT       := x_alloc_from_acctd_amt;
--
    l_mfar_extract_tab(i).TO_CURRENCY_CODE        := p_crh_mfar_extract_record(i).TO_CURRENCY_CODE;
    l_mfar_extract_tab(i).EXCHANGE_RATE           := p_crh_mfar_extract_record(i).EXCHANGE_RATE;
    l_mfar_extract_tab(i).EXCHANGE_RATE_TYPE      := p_crh_mfar_extract_record(i).EXCHANGE_RATE_TYPE;
    l_mfar_extract_tab(i).EXCHANGE_DATE           := p_crh_mfar_extract_record(i).EXCHANGE_DATE;
    l_mfar_extract_tab(i).AMOUNT                  := x_alloc_amt;
    l_mfar_extract_tab(i).ACCTD_AMOUNT            := x_alloc_acctd_amt;
--
    l_mfar_extract_tab(i).RECEIVABLE_APPLICATION_ID := p_crh_mfar_extract_record(i).RECEIVABLE_APPLICATION_ID;
    l_mfar_extract_tab(i).CASH_RECEIPT_ID           := p_crh_mfar_extract_record(i).CASH_RECEIPT_ID;
    l_mfar_extract_tab(i).CUSTOMER_TRX_ID           := p_crh_mfar_extract_record(i).CUSTOMER_TRX_ID;
    l_mfar_extract_tab(i).CUSTOMER_TRX_LINE_ID      := p_crh_mfar_extract_record(i).CUSTOMER_TRX_LINE_ID;
    l_mfar_extract_tab(i).CUST_TRX_LINE_GL_DIST_ID  := p_crh_mfar_extract_record(i).CUST_TRX_LINE_GL_DIST_ID;
--
    l_mfar_extract_tab(i).INVENTORY_ITEM_ID         := p_crh_mfar_extract_record(i).INVENTORY_ITEM_ID;
    l_mfar_extract_tab(i).SALES_TAX_ID              := p_crh_mfar_extract_record(i).SALES_TAX_ID;
    l_mfar_extract_tab(i).SET_OF_BOOKS_ID           := p_crh_mfar_extract_record(i).SET_OF_BOOKS_ID;
    l_mfar_extract_tab(i).BILL_SITE_USE_ID          := p_crh_mfar_extract_record(i).BILL_SITE_USE_ID;
    l_mfar_extract_tab(i).SOLD_SITE_USE_ID          := p_crh_mfar_extract_record(i).SOLD_SITE_USE_ID;
    l_mfar_extract_tab(i).SHIP_SITE_USE_ID          := p_crh_mfar_extract_record(i).SHIP_SITE_USE_ID;
    l_mfar_extract_tab(i).BILL_CUSTOMER_ID          := p_crh_mfar_extract_record(i).BILL_CUSTOMER_ID;
    l_mfar_extract_tab(i).SOLD_CUSTOMER_ID          := p_crh_mfar_extract_record(i).SOLD_CUSTOMER_ID;
    l_mfar_extract_tab(i).SHIP_CUSTOMER_ID          := p_crh_mfar_extract_record(i).SHIP_CUSTOMER_ID;
    l_mfar_extract_tab(i).TAX_LINE_ID               := p_crh_mfar_extract_record(i).TAX_LINE_ID;
--
    l_mfar_extract_tab(i).SELECT_FLAG               := p_crh_mfar_extract_record(i).SELECT_FLAG;
    l_mfar_extract_tab(i).LEVEL_FLAG                := p_crh_mfar_extract_record(i).LEVEL_FLAG;
    l_mfar_extract_tab(i).FROM_TO_FLAG              := p_crh_mfar_extract_record(i).FROM_TO_FLAG;
    l_mfar_extract_tab(i).CRH_STATUS                := p_crh_mfar_extract_record(i).CRH_STATUS;
    l_mfar_extract_tab(i).APP_CRH_STATUS            := p_crh_mfar_extract_record(i).APP_CRH_STATUS;
--
    l_mfar_extract_tab(i).EVENT_TYPE_CODE           := p_crh_mfar_extract_record(i).EVENT_TYPE_CODE;
    l_mfar_extract_tab(i).EVENT_CLASS_CODE          := p_crh_mfar_extract_record(i).EVENT_CLASS_CODE;
    l_mfar_extract_tab(i).ENTITY_CODE               := p_crh_mfar_extract_record(i).ENTITY_CODE;
--
    l_mfar_extract_tab(i).third_party_id            := p_crh_mfar_extract_record(i).third_party_id;
    l_mfar_extract_tab(i).third_party_site_id       := p_crh_mfar_extract_record(i).third_party_site_id;
    l_mfar_extract_tab(i).third_party_type          := p_crh_mfar_extract_record(i).third_party_type;
    l_mfar_extract_tab(i).source_type               := p_crh_mfar_extract_record(i).source_type;

   END LOOP;

  FORALL r IN l_mfar_extract_tab.first..l_mfar_extract_tab.last
     INSERT INTO ar_xla_lines_extract VALUES l_mfar_extract_tab(r);

local_log(procedure_name => 'mfar_insert_crh_extract',
            p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.mfar_insert_crh_extract ()-');

EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'mfar_insert_crh_extract',
             p_msg_text     => 'EXCEPTION OTHERS in mfar_insert_crh_extract '||
                 arp_global.CRLF || 'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.mfar_insert_crh_extract'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;

END mfar_insert_crh_extract;

PROCEDURE prorate_extract_acctd_amounts (p_extract_record ar_xla_extract_record_type)
IS
-- run time variables for proration
  x_run_from_acctd_amt       number := 0;
  x_run_alloc_from_acctd_amt number := 0;
  x_alloc_from_acctd_amt     number := 0;

  x_APP_RECORD_ID         number := 0;

  i                     number := 0;

-- pl/sql table for ar_xla_lines_extract
   TYPE ar_xla_extract_gt_tab IS TABLE OF ar_xla_lines_extract%ROWTYPE
      INDEX BY BINARY_INTEGER;
   l_extract_tab ar_xla_extract_gt_tab;


BEGIN
local_log(procedure_name => 'prorate_extract_acctd_amounts',
            p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.prorate_extract_acctd_amounts()+');

  FOR i IN p_extract_record.FIRST..p_extract_record.LAST
  LOOP

-- Reset run time variables for a new CRH Source Line from ARD
    IF p_extract_record(i).SOURCE_ID <> x_APP_RECORD_ID THEN
      x_run_from_acctd_amt       := 0;
      x_run_alloc_from_acctd_amt := 0;
    END IF;

    x_APP_RECORD_ID   := p_extract_record(i).SOURCE_ID;

-- Proration of From Accounted Amounts
    x_run_from_acctd_amt       := x_run_from_acctd_amt + p_extract_record(i).FROM_AMOUNT;
    x_alloc_from_acctd_amt     := ar_unposted_item_util.currRound((x_run_from_acctd_amt/NVL(p_extract_record(i).AMOUNT_APPLIED_FROM,p_extract_record(i).AMOUNT_APPLIED))
                                        * p_extract_record(i).ACCTD_AMOUNT_APPLIED_FROM,p_extract_record(i).BASE_CURRENCY_CODE) - x_run_alloc_from_acctd_amt;
    x_run_alloc_from_acctd_amt := x_run_alloc_from_acctd_amt + x_alloc_from_acctd_amt;

-- Assign the values to extract table
    l_extract_tab(i).EVENT_ID                := p_extract_record(i).EVENT_ID;
    l_extract_tab(i).LINE_NUMBER             := p_extract_record(i).LINE_NUMBER;
    l_extract_tab(i).LANGUAGE                := p_extract_record(i).LANGUAGE;
    l_extract_tab(i).LEDGER_ID               := p_extract_record(i).LEDGER_ID;
    l_extract_tab(i).SOURCE_ID               := p_extract_record(i).SOURCE_ID;
    l_extract_tab(i).SOURCE_TABLE            := p_extract_record(i).SOURCE_TABLE;
    l_extract_tab(i).LINE_ID                 := p_extract_record(i).LINE_ID;
    l_extract_tab(i).TAX_CODE_ID             := p_extract_record(i).TAX_CODE_ID;
    l_extract_tab(i).LOCATION_SEGMENT_ID     := p_extract_record(i).LOCATION_SEGMENT_ID;
    l_extract_tab(i).BASE_CURRENCY_CODE      := p_extract_record(i).BASE_CURRENCY_CODE;
    l_extract_tab(i).EXCHANGE_RATE_TYPE      := p_extract_record(i).EXCHANGE_RATE_TYPE;
    l_extract_tab(i).EXCHANGE_RATE           := p_extract_record(i).EXCHANGE_RATE;
    l_extract_tab(i).EXCHANGE_DATE           := p_extract_record(i).EXCHANGE_DATE;
    l_extract_tab(i).ACCTD_AMOUNT            := p_extract_record(i).ACCTD_AMOUNT;
    l_extract_tab(i).TAXABLE_ACCTD_AMOUNT    := p_extract_record(i).TAXABLE_ACCTD_AMOUNT;
    l_extract_tab(i).ORG_ID                  := p_extract_record(i).ORG_ID;
    l_extract_tab(i).HEADER_TABLE_ID         := p_extract_record(i).HEADER_TABLE_ID;
    l_extract_tab(i).POSTING_ENTITY          := p_extract_record(i).POSTING_ENTITY;
    l_extract_tab(i).CASH_RECEIPT_ID         := p_extract_record(i).CASH_RECEIPT_ID;
    l_extract_tab(i).CUSTOMER_TRX_ID         := p_extract_record(i).CUSTOMER_TRX_ID;

    l_extract_tab(i).CUSTOMER_TRX_LINE_ID             := p_extract_record(i).CUSTOMER_TRX_LINE_ID;
    l_extract_tab(i).CUST_TRX_LINE_GL_DIST_ID         := p_extract_record(i).CUST_TRX_LINE_GL_DIST_ID;
    l_extract_tab(i).CUST_TRX_LINE_SALESREP_ID        := p_extract_record(i).CUST_TRX_LINE_SALESREP_ID;
    l_extract_tab(i).INVENTORY_ITEM_ID                := p_extract_record(i).INVENTORY_ITEM_ID;
    l_extract_tab(i).SALES_TAX_ID                     := p_extract_record(i).SALES_TAX_ID;
    l_extract_tab(i).SO_ORGANIZATION_ID               := p_extract_record(i).SO_ORGANIZATION_ID;
    l_extract_tab(i).TAX_EXEMPTION_ID                 := p_extract_record(i).TAX_EXEMPTION_ID;
    l_extract_tab(i).UOM_CODE                         := p_extract_record(i).UOM_CODE;
    l_extract_tab(i).WAREHOUSE_ID                     := p_extract_record(i).WAREHOUSE_ID;
    l_extract_tab(i).AGREEMENT_ID                     := p_extract_record(i).AGREEMENT_ID;
    l_extract_tab(i).CUSTOMER_BANK_ACCT_ID            := p_extract_record(i).CUSTOMER_BANK_ACCT_ID;
    l_extract_tab(i).DRAWEE_BANK_ACCOUNT_ID           := p_extract_record(i).DRAWEE_BANK_ACCOUNT_ID;
    l_extract_tab(i).REMITTANCE_BANK_ACCT_ID          := p_extract_record(i).REMITTANCE_BANK_ACCT_ID;
    l_extract_tab(i).DISTRIBUTION_SET_ID              := p_extract_record(i).DISTRIBUTION_SET_ID;
    l_extract_tab(i).PAYMENT_SCHEDULE_ID              := p_extract_record(i).PAYMENT_SCHEDULE_ID;
    l_extract_tab(i).RECEIPT_METHOD_ID                := p_extract_record(i).RECEIPT_METHOD_ID;

    l_extract_tab(i).RECEIVABLES_TRX_ID                := p_extract_record(i).RECEIVABLES_TRX_ID;
    l_extract_tab(i).ED_ADJ_RECEIVABLES_TRX_ID         := p_extract_record(i).ED_ADJ_RECEIVABLES_TRX_ID;
    l_extract_tab(i).UNED_RECEIVABLES_TRX_ID           := p_extract_record(i).UNED_RECEIVABLES_TRX_ID;
    l_extract_tab(i).SET_OF_BOOKS_ID                   := p_extract_record(i).SET_OF_BOOKS_ID;
    l_extract_tab(i).SALESREP_ID                       := p_extract_record(i).SALESREP_ID;
    l_extract_tab(i).BILL_SITE_USE_ID                  := p_extract_record(i).BILL_SITE_USE_ID;
    l_extract_tab(i).DRAWEE_SITE_USE_ID                := p_extract_record(i).DRAWEE_SITE_USE_ID;
    l_extract_tab(i).PAYING_SITE_USE_ID                := p_extract_record(i).PAYING_SITE_USE_ID;
    l_extract_tab(i).SOLD_SITE_USE_ID                  := p_extract_record(i).SOLD_SITE_USE_ID;
    l_extract_tab(i).SHIP_SITE_USE_ID                  := p_extract_record(i).SHIP_SITE_USE_ID;
    l_extract_tab(i).RECEIPT_CUSTOMER_SITE_USE_ID      := p_extract_record(i).RECEIPT_CUSTOMER_SITE_USE_ID;
    l_extract_tab(i).BILL_CUST_ROLE_ID                 := p_extract_record(i).BILL_CUST_ROLE_ID;
    l_extract_tab(i).DRAWEE_CUST_ROLE_ID               := p_extract_record(i).DRAWEE_CUST_ROLE_ID;
    l_extract_tab(i).SHIP_CUST_ROLE_ID                 := p_extract_record(i).SHIP_CUST_ROLE_ID;
    l_extract_tab(i).SOLD_CUST_ROLE_ID                 := p_extract_record(i).SOLD_CUST_ROLE_ID;
    l_extract_tab(i).BILL_CUSTOMER_ID                  := p_extract_record(i).BILL_CUSTOMER_ID;

    l_extract_tab(i).DRAWEE_CUSTOMER_ID         := p_extract_record(i).DRAWEE_CUSTOMER_ID;
    l_extract_tab(i).PAYING_CUSTOMER_ID         := p_extract_record(i).PAYING_CUSTOMER_ID;
    l_extract_tab(i).SOLD_CUSTOMER_ID           := p_extract_record(i).SOLD_CUSTOMER_ID;
    l_extract_tab(i).SHIP_CUSTOMER_ID           := p_extract_record(i).SHIP_CUSTOMER_ID;
    l_extract_tab(i).REMIT_ADDRESS_ID           := p_extract_record(i).REMIT_ADDRESS_ID;
    l_extract_tab(i).RECEIPT_BATCH_ID           := p_extract_record(i).RECEIPT_BATCH_ID;
    l_extract_tab(i).RECEIVABLE_APPLICATION_ID  := p_extract_record(i).RECEIVABLE_APPLICATION_ID;
    l_extract_tab(i).CUSTOMER_BANK_BRANCH_ID    := p_extract_record(i).CUSTOMER_BANK_BRANCH_ID;
    l_extract_tab(i).ISSUER_BANK_BRANCH_ID      := p_extract_record(i).ISSUER_BANK_BRANCH_ID;
    l_extract_tab(i).BATCH_SOURCE_ID            := p_extract_record(i).BATCH_SOURCE_ID;
    l_extract_tab(i).BATCH_ID                   := p_extract_record(i).BATCH_ID;
    l_extract_tab(i).TERM_ID                    := p_extract_record(i).TERM_ID;
    l_extract_tab(i).SELECT_FLAG                := p_extract_record(i).SELECT_FLAG;
    l_extract_tab(i).LEVEL_FLAG                 := p_extract_record(i).LEVEL_FLAG;
    l_extract_tab(i).FROM_TO_FLAG               := p_extract_record(i).FROM_TO_FLAG;
    l_extract_tab(i).AMOUNT                     := p_extract_record(i).AMOUNT;
    l_extract_tab(i).FROM_AMOUNT                := p_extract_record(i).FROM_AMOUNT;

    IF p_extract_record(i).SOURCE_TYPE = 'REC' AND p_extract_record(i).REF_MF_DIST_FLAG <> 'D' THEN
	l_extract_tab(i).FROM_ACCTD_AMOUNT      := x_alloc_from_acctd_amt;
    ELSE
	l_extract_tab(i).FROM_ACCTD_AMOUNT      := p_extract_record(i).FROM_ACCTD_AMOUNT;
    END If;

    l_extract_tab(i).EVENT_TYPE_CODE            := p_extract_record(i).EVENT_TYPE_CODE;
    l_extract_tab(i).EVENT_CLASS_CODE           := p_extract_record(i).EVENT_CLASS_CODE;
    l_extract_tab(i).ENTITY_CODE                := p_extract_record(i).ENTITY_CODE;
    l_extract_tab(i).MFAR_ADDITIONAL_ENTRY      := p_extract_record(i).MFAR_ADDITIONAL_ENTRY;

   END LOOP;

  FORALL r IN l_extract_tab.first..l_extract_tab.last
     INSERT INTO ar_xla_lines_extract VALUES l_extract_tab(r);

local_log(procedure_name => 'prorate_extract_acctd_amounts',
            p_msg_text     => 'ARP_XLA_EXTRACT_MAIN_PKG.prorate_extract_acctd_amounts ()-');

EXCEPTION
--  WHEN NO_DATA_FOUND THEN NULL;
  WHEN OTHERS THEN
   local_log(procedure_name => 'prorate_extract_acctd_amounts',
             p_msg_text     => 'EXCEPTION OTHERS in prorate_extract_acctd_amounts '||
                 arp_global.CRLF || 'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.prorate_extract_acctd_amounts'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;

END prorate_extract_acctd_amounts;

FUNCTION the_segment_value(p_coa_id     IN NUMBER,
                       p_qual_code  IN VARCHAR2,
                       p_ccid       IN NUMBER)
RETURN VARCHAR2
IS
  l_segment_name     VARCHAR2(30);
  l_segment_value    VARCHAR2(25);
  l_hash_value       NUMBER;
  CURSOR c IS
  SELECT application_column_name
    FROM FND_SEGMENT_ATTRIBUTE_VALUES
   WHERE id_flex_num            = p_coa_id
     AND segment_attribute_type = p_qual_code
     AND id_flex_code           = 'GL#'
     AND attribute_value        = 'Y';
BEGIN

  IF p_coa_id    IS NOT NULL AND
     p_qual_code IS NOT NULL AND
     p_ccid      IS NOT NULL
  THEN

    l_hash_value := DBMS_UTILITY.get_hash_value(
                                         'COA:'||p_coa_id||'@*?QUAL:'||p_qual_code||'@*?CCID:'||p_ccid||'@*?END:',
                                         1000,
                                         32768);


    IF p_qual_code = 'GL_BALANCING' THEN
       IF pg_bal_qual.EXISTS(l_hash_value) THEN
         l_segment_value := pg_bal_qual(l_hash_value);
       ELSE
         OPEN c;
           FETCH c INTO l_segment_name;
         CLOSE c;
         get_segment_value(p_segment_name    => l_segment_name,
                           p_coa_id          => p_coa_id,
                           p_ccid            => p_ccid,
                           x_segment_value   => l_segment_value);
         pg_bal_qual(l_hash_value) := l_segment_value;
       END IF;
    ELSIF p_qual_code = 'GL_ACCOUNT' THEN
       IF pg_nat_qual.EXISTS(l_hash_value) THEN
         l_segment_value := pg_nat_qual(l_hash_value);
       ELSE
         OPEN c;
           FETCH c INTO l_segment_name;
         CLOSE c;
         get_segment_value(p_segment_name    => l_segment_name,
                           p_coa_id          => p_coa_id,
                           p_ccid            => p_ccid,
                           x_segment_value   => l_segment_value);
         pg_nat_qual(l_hash_value) := l_segment_value;
       END IF;
    END IF;
  END IF;

  return(l_segment_value);

EXCEPTION
 WHEN no_data_found  THEN
  return(null);
 WHEN OTHERS THEN
  raise;
END;


FUNCTION ed_uned_trx(p_type IN VARCHAR2, p_org_id IN NUMBER) RETURN NUMBER
IS
  l_trx_id           NUMBER;
  l_hash_value       NUMBER;
  CURSOR c IS
  SELECT receivables_trx_id
    FROM ar_receivables_trx_all
   WHERE org_id  = p_org_id
     AND type    = p_type;
BEGIN
  IF p_org_id    IS NOT NULL AND
     p_type      IS NOT NULL
  THEN
    l_hash_value := DBMS_UTILITY.get_hash_value(
                                         'EDUNED:'||p_type||'@*?:'||p_org_id||'@*?END:',
                                         1000,
                                         32768);
    IF p_type = 'EDISC' THEN
       IF pg_ed_trx.EXISTS(l_hash_value) THEN
         l_trx_id := pg_ed_trx(l_hash_value);
       ELSE
         OPEN c;
           FETCH c INTO l_trx_id;
         CLOSE c;
         pg_ed_trx(l_hash_value) := l_trx_id;
       END IF;
    ELSIF p_type = 'UNEDISC' THEN
       IF pg_uned_trx.EXISTS(l_hash_value) THEN
         l_trx_id := pg_uned_trx(l_hash_value);
       ELSE
         OPEN c;
           FETCH c INTO l_trx_id;
         CLOSE c;
         pg_uned_trx(l_hash_value) := l_trx_id;
       END IF;
    END IF;
  END IF;
  return(l_trx_id);
EXCEPTION
 WHEN no_data_found  THEN
  return(null);
 WHEN OTHERS THEN
  raise;
END;


-- bug 7319548
FUNCTION get_glr_ccid (p_ra_id IN NUMBER,p_gain_loss_identifier IN VARCHAR) RETURN NUMBER
IS
 l_ccid NUMBER;
BEGIN

  IF ( g_glr_ccid_cache_tab.EXISTS(p_ra_id) = FALSE ) THEN

      select ard.code_combination_id
             into l_ccid
      from ar_distributions_all ard
      where ard.source_table = 'RA'
      and ard.source_type = p_gain_loss_identifier
      and ard.source_id = p_ra_id;
      -- bug 7694448 modified select to fetch ccid based on whether it is gain or loss

      g_glr_ccid_cache_tab(p_ra_id) := l_ccid;

   END IF;

   return g_glr_ccid_cache_tab(p_ra_id);

EXCEPTION
   WHEN NO_DATA_FOUND then return NULL;
   WHEN OTHERS THEN
   local_log(procedure_name => 'get_glr_ccid',
             p_msg_text     =>'EXCEPTION OTHERS in arp_xla_extract_main_pkg.get_glr_ccid '||
             arp_global.CRLF ||'Error      :'|| SQLERRM);
    FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :arp_xla_extract_main_pkg.get_glr_ccid'|| arp_global.CRLF||
         'Error     :'||SQLERRM);
    FND_MSG_PUB.ADD;
  RAISE;

END get_glr_ccid;



PROCEDURE diag_data
IS
CURSOR c IS
 SELECT *
   FROM ar_xla_lines_extract;
l_c    c%ROWTYPE;


CURSOR c2 IS
SELECT *
FROM xla_events_gt
WHERE application_id = 222;
l      c2%ROWTYPE;


l_text   VARCHAR2(4000);
cpt      NUMBER := 0;
BEGIN
--
/*
DELETE FROM ar_xla_event_tmp;
--
DELETE FROM ar_xla_lines_extract_tmp;
--
INSERT INTO ar_xla_event_tmp
  (LINE_NUMBER         ,
   ENTITY_ID           ,
   APPLICATION_ID      ,
   LEDGER_ID           ,
   LEGAL_ENTITY_ID     ,
   ENTITY_CODE         ,
   TRANSACTION_NUMBER  ,
   SOURCE_ID_INT_1     ,
   SOURCE_ID_INT_2     ,
   SOURCE_ID_INT_3     ,
   SOURCE_ID_INT_4     ,
   SOURCE_ID_CHAR_1    ,
   SOURCE_ID_CHAR_2    ,
   SOURCE_ID_CHAR_3    ,
   SOURCE_ID_CHAR_4    ,
   EVENT_ID            ,
   EVENT_CLASS_CODE    ,
   EVENT_TYPE_CODE     ,
   EVENT_NUMBER        ,
   EVENT_DATE          ,
   EVENT_STATUS_CODE   ,
   PROCESS_STATUS_CODE ,
   EVENT_CREATED_BY    ,
   REFERENCE_NUM_1     ,
   REFERENCE_NUM_2     ,
   REFERENCE_NUM_3     ,
   REFERENCE_NUM_4     ,
   REFERENCE_CHAR_1    ,
   REFERENCE_CHAR_2    ,
   REFERENCE_CHAR_3    ,
   REFERENCE_CHAR_4    ,
   REFERENCE_DATE_1    ,
   REFERENCE_DATE_2    ,
   REFERENCE_DATE_3    ,
   REFERENCE_DATE_4    ,
   VALUATION_METHOD    ,
   SECURITY_ID_INT_1   ,
   SECURITY_ID_INT_2   ,
   SECURITY_ID_INT_3   ,
   SECURITY_ID_CHAR_1  ,
   SECURITY_ID_CHAR_2  ,
   SECURITY_ID_CHAR_3  ,
   ON_HOLD_FLAG        ,
   TRANSACTION_DATE    ,
   BUDGETARY_CONTROL_FLAG   )
 SELECT
   LINE_NUMBER         ,
   ENTITY_ID           ,
   APPLICATION_ID      ,
   LEDGER_ID           ,
   LEGAL_ENTITY_ID     ,
   ENTITY_CODE         ,
   TRANSACTION_NUMBER  ,
   SOURCE_ID_INT_1     ,
   SOURCE_ID_INT_2     ,
   SOURCE_ID_INT_3     ,
   SOURCE_ID_INT_4     ,
   SOURCE_ID_CHAR_1    ,
   SOURCE_ID_CHAR_2    ,
   SOURCE_ID_CHAR_3    ,
   SOURCE_ID_CHAR_4    ,
   EVENT_ID            ,
   EVENT_CLASS_CODE    ,
   EVENT_TYPE_CODE     ,
   EVENT_NUMBER        ,
   EVENT_DATE          ,
   EVENT_STATUS_CODE   ,
   PROCESS_STATUS_CODE ,
   EVENT_CREATED_BY    ,
   REFERENCE_NUM_1     ,
   REFERENCE_NUM_2     ,
   REFERENCE_NUM_3     ,
   REFERENCE_NUM_4     ,
   REFERENCE_CHAR_1    ,
   REFERENCE_CHAR_2    ,
   REFERENCE_CHAR_3    ,
   REFERENCE_CHAR_4    ,
   REFERENCE_DATE_1    ,
   REFERENCE_DATE_2    ,
   REFERENCE_DATE_3    ,
   REFERENCE_DATE_4    ,
   VALUATION_METHOD    ,
   SECURITY_ID_INT_1   ,
   SECURITY_ID_INT_2   ,
   SECURITY_ID_INT_3   ,
   SECURITY_ID_CHAR_1  ,
   SECURITY_ID_CHAR_2  ,
   SECURITY_ID_CHAR_3  ,
   ON_HOLD_FLAG        ,
   TRANSACTION_DATE    ,
   BUDGETARY_CONTROL_FLAG
  FROM xla_events_gt
  WHERE application_id = 222;
--
INSERT INTO ar_xla_lines_extract_tmp
 ( EVENT_ID                  ,
   LINE_NUMBER               ,
   LANGUAGE                  ,
   LEDGER_ID                 ,
   SOURCE_ID                 ,
   SOURCE_TABLE              ,
   LINE_ID                   ,
   TAX_CODE_ID               ,
   LOCATION_SEGMENT_ID       ,
   BASE_CURRENCY_CODE        ,
   EXCHANGE_RATE_TYPE        ,
   EXCHANGE_RATE             ,
   EXCHANGE_DATE             ,
   ACCTD_AMOUNT              ,
   TAXABLE_ACCTD_AMOUNT      ,
   ORG_ID                    ,
   HEADER_TABLE_ID           ,
   POSTING_ENTITY            ,
   CASH_RECEIPT_ID           ,
   CUSTOMER_TRX_ID           ,
   CUSTOMER_TRX_LINE_ID      ,
   CUST_TRX_LINE_GL_DIST_ID  ,
   CUST_TRX_LINE_SALESREP_ID ,
   INVENTORY_ITEM_ID         ,
   SALES_TAX_ID              ,
   SO_ORGANIZATION_ID        ,
   TAX_EXEMPTION_ID          ,
   UOM_CODE                  ,
   WAREHOUSE_ID              ,
   AGREEMENT_ID              ,
   CUSTOMER_BANK_ACCT_ID     ,
   DRAWEE_BANK_ACCOUNT_ID    ,
   REMITTANCE_BANK_ACCT_ID   ,
   DISTRIBUTION_SET_ID       ,
   PAYMENT_SCHEDULE_ID       ,
   RECEIPT_METHOD_ID         ,
   RECEIVABLES_TRX_ID        ,
   ED_ADJ_RECEIVABLES_TRX_ID ,
   UNED_RECEIVABLES_TRX_ID   ,
   SET_OF_BOOKS_ID           ,
   SALESREP_ID               ,
   BILL_SITE_USE_ID          ,
   DRAWEE_SITE_USE_ID        ,
   PAYING_SITE_USE_ID        ,
   SOLD_SITE_USE_ID          ,
   SHIP_SITE_USE_ID          ,
   RECEIPT_CUSTOMER_SITE_USE_ID       ,
   BILL_CUST_ROLE_ID         ,
   DRAWEE_CUST_ROLE_ID       ,
   SHIP_CUST_ROLE_ID         ,
   SOLD_CUST_ROLE_ID         ,
   BILL_CUSTOMER_ID          ,
   DRAWEE_CUSTOMER_ID        ,
   PAYING_CUSTOMER_ID        ,
   SOLD_CUSTOMER_ID          ,
   SHIP_CUSTOMER_ID          ,
   REMIT_ADDRESS_ID          ,
   RECEIPT_BATCH_ID          ,
   RECEIVABLE_APPLICATION_ID ,
   CUSTOMER_BANK_BRANCH_ID   ,
   ISSUER_BANK_BRANCH_ID     ,
   BATCH_SOURCE_ID           ,
   BATCH_ID                  ,
   TERM_ID                   ,
   SELECT_FLAG               ,
   LEVEL_FLAG                ,
   FROM_TO_FLAG              ,
   CRH_STATUS                ,
   CRH_PRV_STATUS            ,
   AMOUNT                    ,
   FROM_AMOUNT               ,
   FROM_ACCTD_AMOUNT         ,
   PREV_FUND_SEG_REPLACE     ,
   APP_CRH_STATUS            ,
   PAIRED_CCID               ,
   PAIRE_DIST_ID             ,
   REF_DIST_CCID             ,
   REF_MF_DIST_FLAG          ,
   ORIGIN_EXTRACT_TABLE      ,
   EVENT_TYPE_CODE           ,
   EVENT_CLASS_CODE          ,
   ENTITY_CODE               ,
   REVERSAL_CODE             ,
   BUSINESS_FLOW_CODE        ,
   TAX_LINE_ID               ,
   ADDITIONAL_CHAR1          ,
   ADDITIONAL_CHAR2          ,
   ADDITIONAL_CHAR3          ,
   ADDITIONAL_CHAR4          ,
   ADDITIONAL_CHAR5          ,
   ADDITIONAL_ID1            ,
   ADDITIONAL_ID2            ,
   ADDITIONAL_ID3            ,
   ADDITIONAL_ID4            ,
   ADDITIONAL_ID5            ,
   XLA_ENTITY_ID
  ,REF_CTLGD_CCID
  ,DIST_CCID
  ,FROM_EXCHANGE_RATE
  ,FROM_EXCHANGE_RATE_TYPE
  ,FROM_EXCHANGE_DATE
  ,FROM_CURRENCY_CODE
  ,TO_CURRENCY_CODE
  ,MFAR_ADDITIONAL_ENTRY
  ,third_party_id
  ,third_party_site_id
  ,third_party_type
  ,source_type               )
 SELECT
   EVENT_ID                  ,
   LINE_NUMBER               ,
   LANGUAGE                  ,
   LEDGER_ID                 ,
   SOURCE_ID                 ,
   SOURCE_TABLE              ,
   LINE_ID                   ,
   TAX_CODE_ID               ,
   LOCATION_SEGMENT_ID       ,
   BASE_CURRENCY_CODE        ,
   EXCHANGE_RATE_TYPE        ,
   EXCHANGE_RATE             ,
   EXCHANGE_DATE             ,
   ACCTD_AMOUNT              ,
   TAXABLE_ACCTD_AMOUNT      ,
   ORG_ID                    ,
   HEADER_TABLE_ID           ,
   POSTING_ENTITY            ,
   CASH_RECEIPT_ID           ,
   CUSTOMER_TRX_ID           ,
   CUSTOMER_TRX_LINE_ID      ,
   CUST_TRX_LINE_GL_DIST_ID  ,
   CUST_TRX_LINE_SALESREP_ID ,
   INVENTORY_ITEM_ID         ,
   SALES_TAX_ID              ,
   SO_ORGANIZATION_ID        ,
   TAX_EXEMPTION_ID          ,
   UOM_CODE                  ,
   WAREHOUSE_ID              ,
   AGREEMENT_ID              ,
   CUSTOMER_BANK_ACCT_ID     ,
   DRAWEE_BANK_ACCOUNT_ID    ,
   REMITTANCE_BANK_ACCT_ID   ,
   DISTRIBUTION_SET_ID       ,
   PAYMENT_SCHEDULE_ID       ,
   RECEIPT_METHOD_ID         ,
   RECEIVABLES_TRX_ID        ,
   ED_ADJ_RECEIVABLES_TRX_ID ,
   UNED_RECEIVABLES_TRX_ID   ,
   SET_OF_BOOKS_ID           ,
   SALESREP_ID               ,
   BILL_SITE_USE_ID          ,
   DRAWEE_SITE_USE_ID        ,
   PAYING_SITE_USE_ID        ,
   SOLD_SITE_USE_ID          ,
   SHIP_SITE_USE_ID          ,
   RECEIPT_CUSTOMER_SITE_USE_ID       ,
   BILL_CUST_ROLE_ID         ,
   DRAWEE_CUST_ROLE_ID       ,
   SHIP_CUST_ROLE_ID         ,
   SOLD_CUST_ROLE_ID         ,
   BILL_CUSTOMER_ID          ,
   DRAWEE_CUSTOMER_ID        ,
   PAYING_CUSTOMER_ID        ,
   SOLD_CUSTOMER_ID          ,
   SHIP_CUSTOMER_ID          ,
   REMIT_ADDRESS_ID          ,
   RECEIPT_BATCH_ID          ,
   RECEIVABLE_APPLICATION_ID ,
   CUSTOMER_BANK_BRANCH_ID   ,
   ISSUER_BANK_BRANCH_ID     ,
   BATCH_SOURCE_ID           ,
   BATCH_ID                  ,
   TERM_ID                   ,
   SELECT_FLAG               ,
   LEVEL_FLAG                ,
   FROM_TO_FLAG              ,
   CRH_STATUS                ,
   CRH_PRV_STATUS            ,
   AMOUNT                    ,
   FROM_AMOUNT               ,
   FROM_ACCTD_AMOUNT         ,
   PREV_FUND_SEG_REPLACE     ,
   APP_CRH_STATUS            ,
   PAIRED_CCID               ,
   PAIRE_DIST_ID             ,
   REF_DIST_CCID             ,
   REF_MF_DIST_FLAG          ,
   ORIGIN_EXTRACT_TABLE      ,
   EVENT_TYPE_CODE           ,
   EVENT_CLASS_CODE          ,
   ENTITY_CODE               ,
   REVERSAL_CODE             ,
   BUSINESS_FLOW_CODE        ,
   TAX_LINE_ID               ,
   ADDITIONAL_CHAR1          ,
   ADDITIONAL_CHAR2          ,
   ADDITIONAL_CHAR3          ,
   ADDITIONAL_CHAR4          ,
   ADDITIONAL_CHAR5          ,
   ADDITIONAL_ID1            ,
   ADDITIONAL_ID2            ,
   ADDITIONAL_ID3            ,
   ADDITIONAL_ID4            ,
   ADDITIONAL_ID5
  ,XLA_ENTITY_ID
  ,REF_CTLGD_CCID
  ,DIST_CCID
  ,FROM_EXCHANGE_RATE
  ,FROM_EXCHANGE_RATE_TYPE
  ,FROM_EXCHANGE_DATE
  ,FROM_CURRENCY_CODE
  ,TO_CURRENCY_CODE
  ,MFAR_ADDITIONAL_ENTRY
  ,third_party_id
  ,third_party_site_id
  ,third_party_type
  ,source_type
FROM ar_xla_lines_extract;
*/
local_log('diag_data','+--------BEGIN READING XLA_EVENTS_GT--------------+');
OPEN c2;
LOOP
  FETCH c2 INTO l;
  EXIT WHEN c2%NOTFOUND;
  cpt := cpt + 1;
local_log('diag_data','|------------------EVENT#'||cpt||'----------------|');
local_log('diag_data','<LINE_NUMBER>'||l.LINE_NUMBER||'</LINE_NUMBER>');
local_log('diag_data','<ENTITY_ID>'||l.ENTITY_ID||'</ENTITY_ID>');
local_log('diag_data','<APPLICATION_ID>'||l.APPLICATION_ID||'</APPLICATION_ID>');
local_log('diag_data','<LEDGER_ID>'||l.LEDGER_ID||'</LEDGER_ID>');
local_log('diag_data','<LEGAL_ENTITY_ID>'||l.LEGAL_ENTITY_ID||'</LEGAL_ENTITY_ID>');
local_log('diag_data','<ENTITY_CODE>'||l.ENTITY_CODE||'</ENTITY_CODE>');
local_log('diag_data','<TRANSACTION_NUMBER>'||l.TRANSACTION_NUMBER||'</TRANSACTION_NUMBER>');
local_log('diag_data','<SOURCE_ID_INT_1>'||l.SOURCE_ID_INT_1||'</SOURCE_ID_INT_1>');
local_log('diag_data','<SOURCE_ID_INT_2>'||l.SOURCE_ID_INT_2||'</SOURCE_ID_INT_2>');
local_log('diag_data','<SOURCE_ID_INT_3>'||l.SOURCE_ID_INT_3||'</SOURCE_ID_INT_3>');
local_log('diag_data','<SOURCE_ID_INT_4>'||l.SOURCE_ID_INT_4||'</SOURCE_ID_INT_4>');
local_log('diag_data','<SOURCE_ID_CHAR_1>'||l.SOURCE_ID_CHAR_1||'</SOURCE_ID_CHAR_1>');
local_log('diag_data','<SOURCE_ID_CHAR_2>'||l.SOURCE_ID_CHAR_2||'</SOURCE_ID_CHAR_2>');
local_log('diag_data','<SOURCE_ID_CHAR_3>'||l.SOURCE_ID_CHAR_3||'</SOURCE_ID_CHAR_3>');
local_log('diag_data','<SOURCE_ID_CHAR_4>'||l.SOURCE_ID_CHAR_4||'</SOURCE_ID_CHAR_4>');
local_log('diag_data','<EVENT_ID>'||l.EVENT_ID||'</EVENT_ID>');
local_log('diag_data','<EVENT_CLASS_CODE>'||l.EVENT_CLASS_CODE||'</EVENT_CLASS_CODE>');
local_log('diag_data','<EVENT_TYPE_CODE>'||l.EVENT_TYPE_CODE||'</EVENT_TYPE_CODE>');
local_log('diag_data','<EVENT_NUMBER>'||l.EVENT_NUMBER||'</EVENT_NUMBER>');
local_log('diag_data','<EVENT_DATE>'||l.EVENT_DATE||'</EVENT_DATE>');
local_log('diag_data','<EVENT_STATUS_CODE>'||l.EVENT_STATUS_CODE||'</EVENT_STATUS_CODE>');
local_log('diag_data','<PROCESS_STATUS_CODE>'||l.PROCESS_STATUS_CODE||'</PROCESS_STATUS_CODE>');
local_log('diag_data','<EVENT_CREATED_BY>'||l.EVENT_CREATED_BY||'</EVENT_CREATED_BY>');
local_log('diag_data','<REFERENCE_NUM_1>'||l.REFERENCE_NUM_1||'</REFERENCE_NUM_1>');
local_log('diag_data','<REFERENCE_NUM_2>'||l.REFERENCE_NUM_2||'</REFERENCE_NUM_2>');
local_log('diag_data','<REFERENCE_NUM_3>'||l.REFERENCE_NUM_3||'</REFERENCE_NUM_3>');
local_log('diag_data','<REFERENCE_NUM_4>'||l.REFERENCE_NUM_4||'</REFERENCE_NUM_4>');
local_log('diag_data','<REFERENCE_CHAR_1>'||l.REFERENCE_CHAR_1||'</REFERENCE_CHAR_1>');
local_log('diag_data','<REFERENCE_CHAR_2>'||l.REFERENCE_CHAR_2||'</REFERENCE_CHAR_2>');
local_log('diag_data','<REFERENCE_CHAR_3>'||l.REFERENCE_CHAR_3||'</REFERENCE_CHAR_3>');
local_log('diag_data','<REFERENCE_CHAR_4>'||l.REFERENCE_CHAR_4||'</REFERENCE_CHAR_4>');
local_log('diag_data','<REFERENCE_DATE_4>'||l.REFERENCE_DATE_4||'</REFERENCE_DATE_4>');
local_log('diag_data','<VALUATION_METHOD>'||l.VALUATION_METHOD||'</VALUATION_METHOD>');
local_log('diag_data','<SECURITY_ID_INT_1>'||l.SECURITY_ID_INT_1||'</SECURITY_ID_INT_1>');
local_log('diag_data','<SECURITY_ID_INT_2>'||l.SECURITY_ID_INT_2||'</SECURITY_ID_INT_2>');
local_log('diag_data','<SECURITY_ID_INT_3>'||l.SECURITY_ID_INT_3||'</SECURITY_ID_INT_3>');
local_log('diag_data','<SECURITY_ID_CHAR_1>'||l.SECURITY_ID_CHAR_1||'</SECURITY_ID_CHAR_1>');
local_log('diag_data','<SECURITY_ID_CHAR_2>'||l.SECURITY_ID_CHAR_2||'</SECURITY_ID_CHAR_2>');
local_log('diag_data','<SECURITY_ID_CHAR_3>'||l.SECURITY_ID_CHAR_3||'</SECURITY_ID_CHAR_3>');
local_log('diag_data','<ON_HOLD_FLAG>'||l.ON_HOLD_FLAG||'</ON_HOLD_FLAG>');
local_log('diag_data','<TRANSACTION_DATE>'||l.TRANSACTION_DATE||'</TRANSACTION_DATE>');
local_log('diag_data','<BUDGETARY_CONTROL_FLAG>'||l.BUDGETARY_CONTROL_FLAG||'</BUDGETARY_CONTROL_FLAG>');
local_log('diag_data','<REFERENCE_DATE_1>'||l.REFERENCE_DATE_1||'</REFERENCE_DATE_1>');
local_log('diag_data','<REFERENCE_DATE_2>'||l.REFERENCE_DATE_2||'</REFERENCE_DATE_2>');
local_log('diag_data','<REFERENCE_DATE_3>'||l.REFERENCE_DATE_3||'</REFERENCE_DATE_3>');
END LOOP;
CLOSE c2;
local_log('diag_data','+--------END READING XLA_EVENTS_GT----------------+');


local_log('diag_data','+--------BEGIN READING AR_XLA_LINES_EXTRACT-------+');
cpt := 0;
OPEN c;
LOOP
  FETCH c INTO l_c;
  EXIT WHEN c%NOTFOUND;
cpt := cpt + 1;
local_log('diag_data','|---------LINE#'||cpt||'--------------------------|');
local_log('diag_data','<BILL_CUSTOMER_ID>'||l_c.BILL_CUSTOMER_ID||'</BILL_CUSTOMER_ID>');
local_log('diag_data','<DRAWEE_CUSTOMER_ID>'||l_c.DRAWEE_CUSTOMER_ID||'</DRAWEE_CUSTOMER_ID>');
local_log('diag_data','<PAYING_CUSTOMER_ID>'||l_c.PAYING_CUSTOMER_ID||'</PAYING_CUSTOMER_ID>');
local_log('diag_data','<SOLD_CUSTOMER_ID>'||l_c.SOLD_CUSTOMER_ID||'</SOLD_CUSTOMER_ID>');
local_log('diag_data','<SHIP_CUSTOMER_ID>'||l_c.SHIP_CUSTOMER_ID||'</SHIP_CUSTOMER_ID>');
local_log('diag_data','<REMIT_ADDRESS_ID>'||l_c.REMIT_ADDRESS_ID||'</REMIT_ADDRESS_ID>');
local_log('diag_data','<RECEIPT_BATCH_ID>'||l_c.RECEIPT_BATCH_ID||'</RECEIPT_BATCH_ID>');
local_log('diag_data','<RECEIVABLE_APPLICATION_ID>'||l_c.RECEIVABLE_APPLICATION_ID||'</RECEIVABLE_APPLICATION_ID>');
local_log('diag_data','<CUSTOMER_BANK_BRANCH_ID>'||l_c.CUSTOMER_BANK_BRANCH_ID||'</CUSTOMER_BANK_BRANCH_ID>');
local_log('diag_data','<ISSUER_BANK_BRANCH_ID>'||l_c.ISSUER_BANK_BRANCH_ID||'</ISSUER_BANK_BRANCH_ID>');
local_log('diag_data','<BATCH_SOURCE_ID>'||l_c.BATCH_SOURCE_ID||'</BATCH_SOURCE_ID>');
local_log('diag_data','<BATCH_ID>'||l_c.BATCH_ID||'</BATCH_ID>');
local_log('diag_data','<TERM_ID>'||l_c.TERM_ID||'</TERM_ID>');
local_log('diag_data','<SELECT_FLAG>'||l_c.SELECT_FLAG||'</SELECT_FLAG>');
local_log('diag_data','<LEVEL_FLAG>'||l_c.LEVEL_FLAG||'</LEVEL_FLAG>');
local_log('diag_data','<FROM_TO_FLAG>'||l_c.FROM_TO_FLAG||'</FROM_TO_FLAG>');
local_log('diag_data','<CRH_STATUS>'||l_c.CRH_STATUS||'</CRH_STATUS>');
local_log('diag_data','<CRH_PRV_STATUS>'||l_c.CRH_PRV_STATUS||'</CRH_PRV_STATUS>');
local_log('diag_data','<AMOUNT>'||l_c.AMOUNT||'</AMOUNT>');
local_log('diag_data','<FROM_AMOUNT>'||l_c.FROM_AMOUNT||'</FROM_AMOUNT>');
local_log('diag_data','<FROM_ACCTD_AMOUNT>'||l_c.FROM_ACCTD_AMOUNT||'</FROM_ACCTD_AMOUNT>');
local_log('diag_data','<PREV_FUND_SEG_REPLACE>'||l_c.PREV_FUND_SEG_REPLACE||'</PREV_FUND_SEG_REPLACE>');
local_log('diag_data','<APP_CRH_STATUS>'||l_c.APP_CRH_STATUS||'</APP_CRH_STATUS>');
local_log('diag_data','<PAIRED_CCID>'||l_c.PAIRED_CCID||'</PAIRED_CCID>');
local_log('diag_data','<PAIRE_DIST_ID>'||l_c.PAIRE_DIST_ID||'</PAIRE_DIST_ID>');
local_log('diag_data','<REF_DIST_CCID>'||l_c.REF_DIST_CCID||'</REF_DIST_CCID>');
local_log('diag_data','<REF_MF_DIST_FLAG>'||l_c.REF_MF_DIST_FLAG||'</REF_MF_DIST_FLAG>');
local_log('diag_data','<ORIGIN_EXTRACT_TABLE>'||l_c.ORIGIN_EXTRACT_TABLE||'</ORIGIN_EXTRACT_TABLE>');
local_log('diag_data','<EVENT_TYPE_CODE>'||l_c.EVENT_TYPE_CODE||'</EVENT_TYPE_CODE>');
local_log('diag_data','<EVENT_CLASS_CODE>'||l_c.EVENT_CLASS_CODE||'</EVENT_CLASS_CODE>');
local_log('diag_data','<ENTITY_CODE>'||l_c.ENTITY_CODE||'</ENTITY_CODE>');
local_log('diag_data','<REVERSAL_CODE>'||l_c.REVERSAL_CODE||'</REVERSAL_CODE>');
local_log('diag_data','<BUSINESS_FLOW_CODE>'||l_c.BUSINESS_FLOW_CODE||'</BUSINESS_FLOW_CODE>');
local_log('diag_data','<TAX_LINE_ID>'||l_c.TAX_LINE_ID||'</TAX_LINE_ID>');
local_log('diag_data','<ADDITIONAL_CHAR1>'||l_c.ADDITIONAL_CHAR1||'</ADDITIONAL_CHAR1>');
local_log('diag_data','<ADDITIONAL_CHAR2>'||l_c.ADDITIONAL_CHAR2||'</ADDITIONAL_CHAR2>');
local_log('diag_data','<ADDITIONAL_CHAR3>'||l_c.ADDITIONAL_CHAR3||'</ADDITIONAL_CHAR3>');
local_log('diag_data','<ADDITIONAL_CHAR4>'||l_c.ADDITIONAL_CHAR4||'</ADDITIONAL_CHAR4>');
local_log('diag_data','<ADDITIONAL_CHAR5>'||l_c.ADDITIONAL_CHAR5||'</ADDITIONAL_CHAR5>');
local_log('diag_data','<ADDITIONAL_ID1>'||l_c.ADDITIONAL_ID1||'</ADDITIONAL_ID1>');
local_log('diag_data','<ADDITIONAL_ID2>'||l_c.ADDITIONAL_ID2||'</ADDITIONAL_ID2>');
local_log('diag_data','<ADDITIONAL_ID3>'||l_c.ADDITIONAL_ID3||'</ADDITIONAL_ID3>');
local_log('diag_data','<ADDITIONAL_ID4>'||l_c.ADDITIONAL_ID4||'</ADDITIONAL_ID4>');
local_log('diag_data','<ADDITIONAL_ID5>'||l_c.ADDITIONAL_ID5||'</ADDITIONAL_ID5>');
local_log('diag_data','<EVENT_ID>'||l_c.EVENT_ID||'</EVENT_ID>');
local_log('diag_data','<LINE_NUMBER>'||l_c.LINE_NUMBER||'</LINE_NUMBER>');
local_log('diag_data','<LANGUAGE>'||l_c.LANGUAGE||'</LANGUAGE>');
local_log('diag_data','<LEDGER_ID>'||l_c.LEDGER_ID||'</LEDGER_ID>');
local_log('diag_data','<SOURCE_ID>'||l_c.SOURCE_ID||'</SOURCE_ID>');
local_log('diag_data','<SOURCE_TABLE>'||l_c.SOURCE_TABLE||'</SOURCE_TABLE>');
local_log('diag_data','<LINE_ID>'||l_c.LINE_ID||'</LINE_ID>');
local_log('diag_data','<TAX_CODE_ID>'||l_c.TAX_CODE_ID||'</TAX_CODE_ID>');
local_log('diag_data','<LOCATION_SEGMENT_ID>'||l_c.LOCATION_SEGMENT_ID||'</LOCATION_SEGMENT_ID>');
local_log('diag_data','<BASE_CURRENCY_CODE>'||l_c.BASE_CURRENCY_CODE||'</BASE_CURRENCY_CODE>');
local_log('diag_data','<EXCHANGE_RATE_TYPE>'||l_c.EXCHANGE_RATE_TYPE||'</EXCHANGE_RATE_TYPE>');
local_log('diag_data','<EXCHANGE_RATE>'||l_c.EXCHANGE_RATE||'</EXCHANGE_RATE>');
local_log('diag_data','<EXCHANGE_DATE>'||l_c.EXCHANGE_DATE||'</EXCHANGE_DATE>');
local_log('diag_data','<ACCTD_AMOUNT>'||l_c.ACCTD_AMOUNT||'</ACCTD_AMOUNT>');
local_log('diag_data','<TAXABLE_ACCTD_AMOUNT>'||l_c.TAXABLE_ACCTD_AMOUNT||'</TAXABLE_ACCTD_AMOUNT>');
local_log('diag_data','<ORG_ID>'||l_c.ORG_ID||'</ORG_ID>');
local_log('diag_data','<HEADER_TABLE_ID>'||l_c.HEADER_TABLE_ID||'</HEADER_TABLE_ID>');
local_log('diag_data','<POSTING_ENTITY>'||l_c.POSTING_ENTITY||'</POSTING_ENTITY>');
local_log('diag_data','<CASH_RECEIPT_ID>'||l_c.CASH_RECEIPT_ID||'</CASH_RECEIPT_ID>');
local_log('diag_data','<CUSTOMER_TRX_ID>'||l_c.CUSTOMER_TRX_ID||'</CUSTOMER_TRX_ID>');
local_log('diag_data','<CUSTOMER_TRX_LINE_ID>'||l_c.CUSTOMER_TRX_LINE_ID||'</CUSTOMER_TRX_LINE_ID>');
local_log('diag_data','<CUST_TRX_LINE_GL_DIST_ID>'||l_c.CUST_TRX_LINE_GL_DIST_ID||'</CUST_TRX_LINE_GL_DIST_ID>');
local_log('diag_data','<CUST_TRX_LINE_SALESREP_ID>'||l_c.CUST_TRX_LINE_SALESREP_ID||'</CUST_TRX_LINE_SALESREP_ID>');
local_log('diag_data','<INVENTORY_ITEM_ID>'||l_c.INVENTORY_ITEM_ID||'</INVENTORY_ITEM_ID>');
local_log('diag_data','<SALES_TAX_ID>'||l_c.SALES_TAX_ID||'</SALES_TAX_ID>');
local_log('diag_data','<SO_ORGANIZATION_ID>'||l_c.SO_ORGANIZATION_ID||'</SO_ORGANIZATION_ID>');
local_log('diag_data','<TAX_EXEMPTION_ID>'||l_c.TAX_EXEMPTION_ID||'</TAX_EXEMPTION_ID>');
local_log('diag_data','<UOM_CODE>'||l_c.UOM_CODE||'</UOM_CODE>');
local_log('diag_data','<WAREHOUSE_ID>'||l_c.WAREHOUSE_ID||'</WAREHOUSE_ID>');
local_log('diag_data','<AGREEMENT_ID>'||l_c.AGREEMENT_ID||'</AGREEMENT_ID>');
local_log('diag_data','<CUSTOMER_BANK_ACCT_ID>'||l_c.CUSTOMER_BANK_ACCT_ID||'</CUSTOMER_BANK_ACCT_ID>');
local_log('diag_data','<DRAWEE_BANK_ACCOUNT_ID>'||l_c.DRAWEE_BANK_ACCOUNT_ID||'</DRAWEE_BANK_ACCOUNT_ID>');
local_log('diag_data','<REMITTANCE_BANK_ACCT_ID>'||l_c.REMITTANCE_BANK_ACCT_ID||'</REMITTANCE_BANK_ACCT_ID>');
local_log('diag_data','<DISTRIBUTION_SET_ID>'||l_c.DISTRIBUTION_SET_ID||'</DISTRIBUTION_SET_ID>');
local_log('diag_data','<PAYMENT_SCHEDULE_ID>'||l_c.PAYMENT_SCHEDULE_ID||'</PAYMENT_SCHEDULE_ID>');
local_log('diag_data','<RECEIPT_METHOD_ID>'||l_c.RECEIPT_METHOD_ID||'</RECEIPT_METHOD_ID>');
local_log('diag_data','<RECEIVABLES_TRX_ID>'||l_c.RECEIVABLES_TRX_ID||'</RECEIVABLES_TRX_ID>');
local_log('diag_data','<ED_ADJ_RECEIVABLES_TRX_ID>'||l_c.ED_ADJ_RECEIVABLES_TRX_ID||'</ED_ADJ_RECEIVABLES_TRX_ID>');
local_log('diag_data','<UNED_RECEIVABLES_TRX_ID>'||l_c.UNED_RECEIVABLES_TRX_ID||'</UNED_RECEIVABLES_TRX_ID>');
local_log('diag_data','<SET_OF_BOOKS_ID>'||l_c.SET_OF_BOOKS_ID||'</SET_OF_BOOKS_ID>');
local_log('diag_data','<SALESREP_ID>'||l_c.SALESREP_ID||'</SALESREP_ID>');
local_log('diag_data','<BILL_SITE_USE_ID>'||l_c.BILL_SITE_USE_ID||'</BILL_SITE_USE_ID>');
local_log('diag_data','<DRAWEE_SITE_USE_ID>'||l_c.DRAWEE_SITE_USE_ID||'</DRAWEE_SITE_USE_ID>');
local_log('diag_data','<PAYING_SITE_USE_ID>'||l_c.PAYING_SITE_USE_ID||'</PAYING_SITE_USE_ID>');
local_log('diag_data','<SOLD_SITE_USE_ID>'||l_c.SOLD_SITE_USE_ID||'</SOLD_SITE_USE_ID>');
local_log('diag_data','<SHIP_SITE_USE_ID>'||l_c.SHIP_SITE_USE_ID||'</SHIP_SITE_USE_ID>');
local_log('diag_data','<RECEIPT_CUSTOMER_SITE_USE_ID>'||l_c.RECEIPT_CUSTOMER_SITE_USE_ID||'</RECEIPT_CUSTOMER_SITE_USE_ID>');
local_log('diag_data','<BILL_CUST_ROLE_ID>'||l_c.BILL_CUST_ROLE_ID||'</BILL_CUST_ROLE_ID>');
local_log('diag_data','<DRAWEE_CUST_ROLE_ID>'||l_c.DRAWEE_CUST_ROLE_ID||'</DRAWEE_CUST_ROLE_ID>');
local_log('diag_data','<SHIP_CUST_ROLE_ID>'||l_c.SHIP_CUST_ROLE_ID||'</SHIP_CUST_ROLE_ID>');
local_log('diag_data','<SOLD_CUST_ROLE_ID>'||l_c.SOLD_CUST_ROLE_ID||'</SOLD_CUST_ROLE_ID>');
END LOOP;
CLOSE c;
local_log('diag_data','+--------END READING AR_XLA_LINES_EXTRACT---------+');


END;


END arp_xla_extract_main_pkg;

/
