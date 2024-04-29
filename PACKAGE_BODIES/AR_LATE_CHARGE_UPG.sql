--------------------------------------------------------
--  DDL for Package Body AR_LATE_CHARGE_UPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_LATE_CHARGE_UPG" AS
/* $Header: ARLCUPB.pls 120.12.12010000.3 2009/08/20 10:28:36 rviriyal ship $ */

g_creation_date                DATE := SYSDATE;

FUNCTION f_number(p_val IN VARCHAR2) RETURN NUMBER IS
 l_num   NUMBER;
BEGIN
 IF p_val IS NULL THEN
   RETURN NULL;
 ELSE
   RETURN (TO_NUMBER(p_val));
 END IF;
EXCEPTION
 WHEN OTHERS THEN
   RETURN (NULL);
END;

FUNCTION f_date(p_value IN VARCHAR2) RETURN DATE
IS
BEGIN
  IF p_value IS NULL THEN
    RETURN NULL;
  ELSE
    RETURN (TO_DATE(p_value,'RRRR/MM/DD HH24:MI:SS'));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;


--Phase 5
PROCEDURE upgrade_schedule
(l_table_owner  IN VARCHAR2, -- JG
 l_table_name   IN VARCHAR2, -- JG_ZZ_II_INT_RATES_ALL
 l_script_name  IN VARCHAR2, -- ar120lcjgr.sql
 l_worker_id    IN VARCHAR2,
 l_num_workers  IN VARCHAR2,
 l_batch_size   IN VARCHAR2)
IS

l_start_rowid         rowid;
l_end_rowid           rowid;
l_any_rows_to_process boolean;
l_rows_processed      number := 0;

l_status     VARCHAR2(10);
l_industry   VARCHAR2(10);
l_res        BOOLEAN := FALSE;
no_global    EXCEPTION;
BEGIN

l_res := FND_INSTALLATION.GET(7003,7003,l_status,l_industry);

IF NOT(l_res) THEN
  RAISE no_global;
END IF;


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

INSERT ALL
 WHEN rk = 1 THEN
 INTO ar_charge_schedules(
   SCHEDULE_ID
  ,SCHEDULE_NAME
  ,SCHEDULE_DESCRIPTION
  ,OBJECT_VERSION_NUMBER
  ,CREATED_BY
  ,CREATION_DATE
  ,LAST_UPDATED_BY
  ,LAST_UPDATE_DATE
  ,LAST_UPDATE_LOGIN)
 VALUES
  (AR_CHARGE_SCHEDULES_S.NEXTVAL
  ,DECODE(lookup_type,'JGZZ_INT_INV_DAILY_RATE','D_UPG_','M_UPG_')||lookup_code
  ,jg_description
  ,1
  ,-1
  ,g_creation_date
  ,-1
  ,g_creation_date
  ,-1)
SELECT lookup_type
      ,lookup_code
      ,jg_meaning
      ,jg_description
      ,jg_enabled_flag
      ,jg_start_date
      ,jg_end_date
      ,rk
FROM
(SELECT lookup_type                               as lookup_type
       ,lookup_code                               as lookup_code
       ,meaning                                   as jg_meaning
       ,description                               as jg_description
       ,enabled_flag                              as jg_enabled_flag
       ,start_date_active                         as jg_start_date
       ,end_date_active                           as jg_end_date
       ,rank () over
         (partition by lookup_type,lookup_code order by start_date_active asc) as rk
   FROM JG_ZZ_II_INT_RATES_ALL
  WHERE lookup_type IN ('JGZZ_INT_INV_DAILY_RATE','JGZZ_INT_INV_MONTHLY_RATE')
   AND rowid >= l_start_rowid
   AND rowid <= l_end_rowid)
WHERE rk = 1;


INSERT ALL
 WHEN 1 = 1 THEN
 INTO ar_charge_schedule_hdrs(
   SCHEDULE_HEADER_ID
  ,SCHEDULE_ID
  ,SCHEDULE_HEADER_TYPE
  ,AGING_BUCKET_ID
  ,START_DATE
  ,END_DATE
  ,STATUS
  ,OBJECT_VERSION_NUMBER
  ,CREATED_BY
  ,CREATION_DATE
  ,LAST_UPDATED_BY
  ,LAST_UPDATE_DATE
  ,LAST_UPDATE_LOGIN)
 VALUES
  (AR_CHARGE_SCHEDULE_HDRS_S.NEXTVAL
  ,schedule_id
  ,'RATE'
  ,6
  ,jg_start_date
  ,jg_end_date
  ,'A'
  ,1
  ,-1
  ,g_creation_date
  ,-1
  ,g_creation_date
  ,-1)
SELECT jg.lookup_type                               as lookup_type
      ,jg.lookup_code                               as lookup_code
      ,jg.meaning                                   as jg_meaning
      ,jg.description                               as jg_description
      ,jg.enabled_flag                              as jg_enabled_flag
      ,jg.start_date_active                         as jg_start_date
      ,jg.end_date_active                           as jg_end_date
      ,cs.SCHEDULE_ID                               as schedule_id
  FROM JG_ZZ_II_INT_RATES_ALL  jg,
       ar_charge_schedules cs
 WHERE jg.lookup_type IN ('JGZZ_INT_INV_DAILY_RATE', 'JGZZ_INT_INV_MONTHLY_RATE')
   AND DECODE(jg.lookup_type,'JGZZ_INT_INV_DAILY_RATE','D_UPG_','M_UPG_')||jg.lookup_code = cs.SCHEDULE_NAME
   AND jg.rowid >= l_start_rowid
   AND jg.rowid <= l_end_rowid;

INSERT ALL
 WHEN 1 = 1 THEN
 INTO ar_charge_schedule_lines(
    SCHEDULE_LINE_ID
   ,SCHEDULE_HEADER_ID
   ,SCHEDULE_ID
   ,AGING_BUCKET_ID
   ,AGING_BUCKET_LINE_ID
   ,RATE
   ,OBJECT_VERSION_NUMBER
   ,CREATED_BY
   ,CREATION_DATE
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_DATE
   ,LAST_UPDATE_LOGIN)
 VALUES
  (AR_CHARGE_SCHEDULE_LINES_S.NEXTVAL
  ,schedule_header_id
  ,schedule_id
  ,6  --AGING_BUCKET_ID
  ,32 --AGING_BUCKET_LINE_ID
  ,f_number(jg_meaning)
  ,1
  ,-1
  ,g_creation_date
  ,-1
  ,g_creation_date
  ,-1)
SELECT jg.lookup_type                            as lookup_type
      ,jg.lookup_code                            as lookup_code
      ,jg.meaning                                as jg_meaning
      ,jg.description                            as jg_description
      ,jg.enabled_flag                           as jg_enabled_flag
      ,jg.start_date_active                      as jg_start_date
      ,jg.end_date_active                        as jg_end_date
      ,ch.schedule_id                            as schedule_id
      ,ch.schedule_header_id                     as schedule_header_id
  FROM JG_ZZ_II_INT_RATES_ALL         jg,
       ar_charge_schedules        cs,
       ar_charge_schedule_hdrs ch
 WHERE jg.lookup_type IN ('JGZZ_INT_INV_DAILY_RATE', 'JGZZ_INT_INV_MONTHLY_RATE')
   AND DECODE(jg.lookup_type,'JGZZ_INT_INV_DAILY_RATE','D_UPG_','M_UPG_')||jg.lookup_code = cs.SCHEDULE_NAME
   AND cs.schedule_id = ch.schedule_id
   AND jg.start_date_active   = ch.start_date
   AND ((jg.end_date_active   = ch.end_date) OR (jg.end_date_active IS NULL AND ch.end_date IS NULL))
   AND jg.rowid >= l_start_rowid
   AND jg.rowid <= l_end_rowid;

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
  WHEN no_global THEN NULL;

END;


--Phase 6
PROCEDURE upgrade_profile_amount
(l_table_owner  IN VARCHAR2, -- AR
 l_table_name   IN VARCHAR2, -- HZ_CUST_PROFILE_AMTS
 l_script_name  IN VARCHAR2, -- ar120lccpa.sql
 l_worker_id    IN VARCHAR2,
 l_num_workers  IN VARCHAR2,
 l_batch_size   IN VARCHAR2)
IS
l_start_rowid         rowid;
l_end_rowid           rowid;
l_any_rows_to_process boolean;
l_rows_processed      number := 0;

CURSOR c(p_start_rowid    IN ROWID, p_end_rowid      IN ROWID)
IS
SELECT /*+ ordered rowid(cpa) */
  cpa.rowid                                                    cpa_rowid
, cpa.JGZZ_ATTRIBUTE5                                          EXCHANGE_RATE_TYPE
, DECODE(
   NVL(f_number(cpa.JGZZ_ATTRIBUTE4),
                 cpa.MIN_FC_INVOICE_AMOUNT),
   NULL,NULL,'AMOUNT')                                         MIN_FC_INVOICE_OVERDUE_TYPE
, NVL(f_number(cpa.JGZZ_ATTRIBUTE4),cpa.MIN_FC_INVOICE_AMOUNT) MIN_FC_INVOICE_AMOUNT
, DECODE(cpa.min_fc_balance_amount,NULL,NULL,'AMOUNT')         MIN_FC_BALANCE_OVERDUE_TYPE
, f_number(cpa.JGZZ_ATTRIBUTE3)                                MIN_INTEREST_CHARGE
, DECODE(cpa.jgzz_attribute7,NULL,
         DECODE(cpa.interest_rate,NULL, NULL,'FIXED_RATE'),
                                       'CHARGES_SCHEDULE')     INTEREST_TYPE
, cs.schedule_id                                               INTEREST_SCHEDULE_ID
, DECODE(cpa.jgzz_attribute3,NULL,NULL,'FIXED_AMOUNT')         PENALTY_TYPE
, cpa.jgzz_attribute3                                          PENALTY_FIXED_AMOUNT
--{TCA Validation
, DECODE(cpa.jgzz_attribute7,NULL,cpa.interest_rate,NULL)      interest_rate
--}
FROM hz_cust_profile_amts cpa,
     ar_charge_schedules  cs
WHERE cpa.rowid           >= p_start_rowid
  AND cpa.rowid           <= p_end_rowid
  AND cs.SCHEDULE_NAME(+) = DECODE(cpa.jgzz_attribute7,
                                 'D','D_UPG_'||cpa.jgzz_attribute8,
                                 'M','M_UPG_'||cpa.jgzz_attribute9,NULL);

l_rowid_tab                             DBMS_SQL.VARCHAR2_TABLE;
l_EXCHANGE_RATE_TYPE                    DBMS_SQL.VARCHAR2_TABLE;
l_MIN_FC_INVOICE_OVERDUE_TYPE           DBMS_SQL.VARCHAR2_TABLE;
l_MIN_FC_INVOICE_AMOUNT                 DBMS_SQL.NUMBER_TABLE;
l_MIN_FC_BALANCE_OVERDUE_TYPE           DBMS_SQL.VARCHAR2_TABLE;
l_MIN_INTEREST_CHARGE                   DBMS_SQL.NUMBER_TABLE;
l_INTEREST_TYPE                         DBMS_SQL.VARCHAR2_TABLE;
l_INTEREST_SCHEDULE_ID                  DBMS_SQL.NUMBER_TABLE;
l_PENALTY_TYPE                          DBMS_SQL.VARCHAR2_TABLE;
l_PENALTY_FIXED_AMOUNT                  DBMS_SQL.NUMBER_TABLE;
l_interest_rate                         DBMS_SQL.NUMBER_TABLE;

g_bulk_fetch_rows   NUMBER   := 10000;
l_last_fetch        BOOLEAN  := FALSE;

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
         l_rowid_tab                  ,
         l_EXCHANGE_RATE_TYPE         ,
         l_MIN_FC_INVOICE_OVERDUE_TYPE,
         l_MIN_FC_INVOICE_AMOUNT      ,
         l_MIN_FC_BALANCE_OVERDUE_TYPE,
         l_MIN_INTEREST_CHARGE        ,
         l_INTEREST_TYPE              ,
         l_INTEREST_SCHEDULE_ID       ,
         l_PENALTY_TYPE               ,
         l_PENALTY_FIXED_AMOUNT       ,
         l_interest_rate
     LIMIT g_bulk_fetch_rows;

     IF c%NOTFOUND THEN
       l_last_fetch := TRUE;
     END IF;

     IF (l_rowid_tab.COUNT = 0) AND (l_last_fetch) THEN
       EXIT;
     END IF;

     FORALL i IN l_rowid_tab.FIRST .. l_rowid_tab.LAST
       UPDATE hz_cust_profile_amts
          SET EXCHANGE_RATE_TYPE          = l_EXCHANGE_RATE_TYPE(i),
              MIN_FC_INVOICE_OVERDUE_TYPE = l_MIN_FC_INVOICE_OVERDUE_TYPE(i),
              MIN_FC_INVOICE_AMOUNT       = l_MIN_FC_INVOICE_AMOUNT(i),
              MIN_FC_BALANCE_OVERDUE_TYPE = l_MIN_FC_BALANCE_OVERDUE_TYPE(i),
              MIN_INTEREST_CHARGE         = l_MIN_INTEREST_CHARGE(i),
              INTEREST_TYPE               = l_INTEREST_TYPE(i),
              INTEREST_SCHEDULE_ID        = l_INTEREST_SCHEDULE_ID(i),
              PENALTY_TYPE                = l_PENALTY_TYPE(i),
              PENALTY_FIXED_AMOUNT        = l_PENALTY_FIXED_AMOUNT(i),
              interest_rate               = l_interest_rate(i),
              last_update_date            = g_creation_date,
              last_updated_by             = -1
        WHERE rowid = l_rowid_tab(i);

     l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

     IF l_last_fetch THEN
       EXIT;
     END IF;

   END LOOP;

   CLOSE c;


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
    --arp_standard.debug('NO_DATA_FOUND EXCEPTION: upgrade_profile_amount');
    RAISE;

  WHEN OTHERS THEN
    --arp_standard.debug('OTHERS EXCEPTION: upgrade_profile_amount');
    RAISE;

END upgrade_profile_amount;


--Phase 7
PROCEDURE upgrade_profile
(l_table_owner  IN VARCHAR2, -- AR
 l_table_name   IN VARCHAR2, -- HZ_CUSTOMER_PROFILES
 l_script_name  IN VARCHAR2, -- ar120lccp.sql
 l_worker_id    IN VARCHAR2,
 l_num_workers  IN VARCHAR2,
 l_batch_size   IN VARCHAR2)
IS

l_start_rowid         rowid;
l_end_rowid           rowid;
l_any_rows_to_process boolean;
l_rows_processed      number := 0;

CURSOR c(p_start_rowid    IN ROWID, p_end_rowid      IN ROWID)  IS
SELECT /*+ ordered rowid(cp) */
  cp.ROWID                                            cp_rowid
, DECODE(JGZZ_ATTRIBUTE2,'LP','LATE',
                         'LO','OVERDUE_LATE',
                         'OI','OVERDUE','OVERDUE')         LATE_CHARGE_CALCULATION_TRX
, DECODE(JGZZ_ATTRIBUTE9,'Y','Y','N')                 CREDIT_ITEMS_FLAG
, 'N'                                                 DISPUTED_TRANSACTIONS_FLAG
, DECODE(JGZZ_ATTRIBUTE1,'Y','INV','ADJ')             LATE_CHARGE_TYPE
, f_NUMBER(JGZZ_ATTRIBUTE8)                           LATE_CHARGE_TERM_ID
, DECODE(cpa.dom,'M','MONTHLY','DAILY')               INTEREST_CALCULATION_PERIOD
, DECODE(JGZZ_ATTRIBUTE5,'Y','Y','N')                 HOLD_CHARGED_INVOICES_FLAG
, 'N'                                                 MULTIPLE_INTEREST_RATES_FLAG
, f_date(JGZZ_ATTRIBUTE6)                             CHARGE_BEGIN_DATE
, DECODE(JGZZ_ATTRIBUTE1,'Y','Y',
                        NVL(INTEREST_CHARGES,'N'))    INTEREST_CHARGES
, f_NUMBER(JGZZ_ATTRIBUTE4)                           Message_text_id
, decode(cons_inv_flag,'Y', decode(cons_bill_level,NULL,'SITE',NULL), NULL) cons_bill_level
FROM hz_customer_profiles                 cp,
     (SELECT MAX(jgzz_attribute7)    dom,
             CUST_ACCOUNT_PROFILE_ID
        FROM hz_cust_profile_amts
       WHERE jgzz_attribute7     = 'M'
       GROUP BY CUST_ACCOUNT_PROFILE_ID)  cpa
WHERE cp.rowid           >= p_start_rowid
  AND cp.rowid           <= p_end_rowid
  AND cp.CUST_ACCOUNT_PROFILE_ID  = cpa.CUST_ACCOUNT_PROFILE_ID(+);

l_rowid_tab                             DBMS_SQL.VARCHAR2_TABLE;
l_LATE_CHARGE_CALCULATION_TRX           DBMS_SQL.VARCHAR2_TABLE;
l_CREDIT_ITEMS_FLAG                     DBMS_SQL.VARCHAR2_TABLE;
l_DISPUTED_TRANSACTIONS_FLAG            DBMS_SQL.VARCHAR2_TABLE;
l_LATE_CHARGE_TYPE                      DBMS_SQL.VARCHAR2_TABLE;
l_LATE_CHARGE_TERM_ID                   DBMS_SQL.NUMBER_TABLE;
l_INTEREST_CALCULATION_PERIOD           DBMS_SQL.VARCHAR2_TABLE;
l_HOLD_CHARGED_INVOICES_FLAG            DBMS_SQL.VARCHAR2_TABLE;
l_MULTIPLE_INTEREST_RATES_FLAG          DBMS_SQL.VARCHAR2_TABLE;
l_CHARGE_BEGIN_DATE                     DBMS_SQL.DATE_TABLE;
l_INTEREST_CHARGES                      DBMS_SQL.VARCHAR2_TABLE;
l_Message_text_id                       DBMS_SQL.NUMBER_TABLE;
l_cons_bill_level                       DBMS_SQL.VARCHAR2_TABLE;


g_bulk_fetch_rows   NUMBER   := 10000;
l_last_fetch        BOOLEAN  := FALSE;

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
           l_rowid_tab,
           l_LATE_CHARGE_CALCULATION_TRX,
           l_CREDIT_ITEMS_FLAG,
           l_DISPUTED_TRANSACTIONS_FLAG,
           l_LATE_CHARGE_TYPE,
           l_LATE_CHARGE_TERM_ID,
           l_INTEREST_CALCULATION_PERIOD,
           l_HOLD_CHARGED_INVOICES_FLAG,
           l_MULTIPLE_INTEREST_RATES_FLAG,
           l_CHARGE_BEGIN_DATE,
           l_INTEREST_CHARGES,
           l_Message_text_id,
           l_cons_bill_level
     LIMIT g_bulk_fetch_rows;

     IF c%NOTFOUND THEN
       l_last_fetch := TRUE;
     END IF;

     IF (l_rowid_tab.COUNT = 0) AND (l_last_fetch) THEN
       EXIT;
     END IF;

     FORALL i IN l_rowid_tab.FIRST .. l_rowid_tab.LAST
       UPDATE hz_customer_profiles
          SET LATE_CHARGE_CALCULATION_TRX = l_LATE_CHARGE_CALCULATION_TRX(i),
              CREDIT_ITEMS_FLAG           = l_CREDIT_ITEMS_FLAG(i),
              DISPUTED_TRANSACTIONS_FLAG  = l_DISPUTED_TRANSACTIONS_FLAG(i),
              LATE_CHARGE_TYPE            = l_LATE_CHARGE_TYPE(i),
              LATE_CHARGE_TERM_ID         = l_LATE_CHARGE_TERM_ID(i),
              INTEREST_CALCULATION_PERIOD = l_INTEREST_CALCULATION_PERIOD(i),
              HOLD_CHARGED_INVOICES_FLAG  = l_HOLD_CHARGED_INVOICES_FLAG(i),
              MULTIPLE_INTEREST_RATES_FLAG= l_MULTIPLE_INTEREST_RATES_FLAG(i),
              CHARGE_BEGIN_DATE           = l_CHARGE_BEGIN_DATE(i),
              INTEREST_CHARGES            = l_INTEREST_CHARGES(i),
              Message_text_id             = l_Message_text_id(i),
              last_update_date            = g_creation_date,
              last_updated_by             = -1,
              cons_bill_level             = l_cons_bill_level(i)
        WHERE rowid = l_rowid_tab(i);

     l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

     IF l_last_fetch THEN
       EXIT;
     END IF;

   END LOOP;

   CLOSE c;


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
    --arp_standard.debug('NO_DATA_FOUND EXCEPTION: upgrade_profile');
    RAISE;

  WHEN OTHERS THEN
    --arp_standard.debug('OTHERS EXCEPTION: upgrade_profile');
    RAISE;

END upgrade_profile;


--Phase 6
PROCEDURE upgrade_profile_class_amount
(l_table_owner  IN VARCHAR2, -- AR
 l_table_name   IN VARCHAR2, -- HZ_CUST_PROF_CLASS_AMTS
 l_script_name  IN VARCHAR2, -- arlccpca.sql
 l_worker_id    IN VARCHAR2,
 l_num_workers  IN VARCHAR2,
 l_batch_size   IN VARCHAR2)
IS
l_start_rowid         rowid;
l_end_rowid           rowid;
l_any_rows_to_process boolean;
l_rows_processed      number := 0;

CURSOR c(p_start_rowid    IN ROWID, p_end_rowid      IN ROWID)
IS
SELECT /*+ ordered rowid(cpa) */
  cpa.rowid                                                    cpa_rowid
, cpa.JGZZ_ATTRIBUTE5                                          EXCHANGE_RATE_TYPE
, DECODE(
   NVL(f_number(cpa.JGZZ_ATTRIBUTE4),
                 cpa.MIN_FC_INVOICE_AMOUNT),
   NULL,NULL,'AMOUNT')                                         MIN_FC_INVOICE_OVERDUE_TYPE
, NVL(f_number(cpa.JGZZ_ATTRIBUTE4),cpa.MIN_FC_INVOICE_AMOUNT) MIN_FC_INVOICE_AMOUNT
, DECODE(cpa.min_fc_balance_amount,NULL,
      DECODE(cpa.min_fc_balance_percent,NULL,NULL,'PERCENT'),
	    'AMOUNT')                                              MIN_FC_BALANCE_OVERDUE_TYPE
, f_number(cpa.JGZZ_ATTRIBUTE3)                                MIN_INTEREST_CHARGE
, DECODE(cpa.jgzz_attribute7,NULL,
         DECODE(cpa.interest_rate,NULL,NULL,'FIXED_RATE'),
                                       'CHARGES_SCHEDULE')     INTEREST_TYPE
, cs.schedule_id                                               INTEREST_SCHEDULE_ID
, DECODE(cpa.jgzz_attribute3,NULL,NULL,'FIXED_AMOUNT')         PENALTY_TYPE
, cpa.jgzz_attribute3                                          PENALTY_FIXED_AMOUNT
--{TCA Validation
, DECODE(cpa.jgzz_attribute7,NULL,cpa.interest_rate,NULL)      interest_rate
--}
FROM hz_cust_prof_class_amts cpa,
     ar_charge_schedules     cs
WHERE cpa.rowid           >= p_start_rowid
  AND cpa.rowid           <= p_end_rowid
  AND cs.SCHEDULE_NAME(+) = DECODE(cpa.jgzz_attribute7,
                                 'D','D_UPG_'||cpa.jgzz_attribute8,
                                 'M','M_UPG_'||cpa.jgzz_attribute9,NULL);

l_rowid_tab                             DBMS_SQL.VARCHAR2_TABLE;
l_EXCHANGE_RATE_TYPE                    DBMS_SQL.VARCHAR2_TABLE;
l_MIN_FC_INVOICE_OVERDUE_TYPE           DBMS_SQL.VARCHAR2_TABLE;
l_MIN_FC_INVOICE_AMOUNT                 DBMS_SQL.NUMBER_TABLE;
l_MIN_FC_BALANCE_OVERDUE_TYPE           DBMS_SQL.VARCHAR2_TABLE;
l_MIN_INTEREST_CHARGE                   DBMS_SQL.NUMBER_TABLE;
l_INTEREST_TYPE                         DBMS_SQL.VARCHAR2_TABLE;
l_INTEREST_SCHEDULE_ID                  DBMS_SQL.NUMBER_TABLE;
l_PENALTY_TYPE                          DBMS_SQL.VARCHAR2_TABLE;
l_PENALTY_FIXED_AMOUNT                  DBMS_SQL.NUMBER_TABLE;
l_interest_rate                         DBMS_SQL.NUMBER_TABLE;

g_bulk_fetch_rows   NUMBER   := 10000;
l_last_fetch        BOOLEAN  := FALSE;

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
         l_rowid_tab                  ,
         l_EXCHANGE_RATE_TYPE         ,
         l_MIN_FC_INVOICE_OVERDUE_TYPE,
         l_MIN_FC_INVOICE_AMOUNT      ,
         l_MIN_FC_BALANCE_OVERDUE_TYPE,
         l_MIN_INTEREST_CHARGE        ,
         l_INTEREST_TYPE              ,
         l_INTEREST_SCHEDULE_ID       ,
         l_PENALTY_TYPE               ,
         l_PENALTY_FIXED_AMOUNT       ,
         l_interest_rate
     LIMIT g_bulk_fetch_rows;

     IF c%NOTFOUND THEN
       l_last_fetch := TRUE;
     END IF;

     IF (l_rowid_tab.COUNT = 0) AND (l_last_fetch) THEN
       EXIT;
     END IF;

     FORALL i IN l_rowid_tab.FIRST .. l_rowid_tab.LAST
       UPDATE hz_cust_prof_class_amts
          SET EXCHANGE_RATE_TYPE          = l_EXCHANGE_RATE_TYPE(i),
              MIN_FC_INVOICE_OVERDUE_TYPE = l_MIN_FC_INVOICE_OVERDUE_TYPE(i),
              MIN_FC_INVOICE_AMOUNT       = l_MIN_FC_INVOICE_AMOUNT(i),
              MIN_FC_BALANCE_OVERDUE_TYPE = l_MIN_FC_BALANCE_OVERDUE_TYPE(i),
              MIN_INTEREST_CHARGE         = l_MIN_INTEREST_CHARGE(i),
              INTEREST_TYPE               = l_INTEREST_TYPE(i),
              INTEREST_SCHEDULE_ID        = l_INTEREST_SCHEDULE_ID(i),
              PENALTY_TYPE                = l_PENALTY_TYPE(i),
              PENALTY_FIXED_AMOUNT        = l_PENALTY_FIXED_AMOUNT(i),
              last_update_date            = g_creation_date,
              last_updated_by             = -1,
              interest_rate               = l_interest_rate(i)
        WHERE rowid = l_rowid_tab(i);

     l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

     IF l_last_fetch THEN
       EXIT;
     END IF;

   END LOOP;

   CLOSE c;


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
    --arp_standard.debug('NO_DATA_FOUND EXCEPTION: upgrade_profile_class_amount');
    RAISE;

  WHEN OTHERS THEN
    --arp_standard.debug('OTHERS EXCEPTION: upgrade_profile_class_amount');
    RAISE;

END upgrade_profile_class_amount;


--Phase 7
PROCEDURE upgrade_profile_class
(l_table_owner  IN VARCHAR2, -- AR
 l_table_name   IN VARCHAR2, -- HZ_CUST_PROFILE_CLASSES
 l_script_name  IN VARCHAR2, -- ar120lccpc.sql
 l_worker_id    IN VARCHAR2,
 l_num_workers  IN VARCHAR2,
 l_batch_size   IN VARCHAR2)
IS

l_start_rowid         rowid;
l_end_rowid           rowid;
l_any_rows_to_process boolean;
l_rows_processed      number := 0;

CURSOR c(p_start_rowid    IN ROWID, p_end_rowid      IN ROWID)  IS
SELECT /*+ ordered rowid(cp) */
  cp.ROWID                                            cp_rowid
, DECODE(JGZZ_ATTRIBUTE2,'LP','LATE',
                         'LO','OVERDUE_LATE',
                         'OI','OVERDUE','OVERDUE')    LATE_CHARGE_CALCULATION_TRX
, DECODE(JGZZ_ATTRIBUTE9,'Y','Y','N')                 CREDIT_ITEMS_FLAG
, 'N'                                                 DISPUTED_TRANSACTIONS_FLAG
, DECODE(JGZZ_ATTRIBUTE1,'Y','INV','ADJ')             LATE_CHARGE_TYPE
, f_NUMBER(JGZZ_ATTRIBUTE8)                           LATE_CHARGE_TERM_ID
, DECODE(cpa.dom,'M','MONTHLY','DAILY')               INTEREST_CALCULATION_PERIOD
, DECODE(JGZZ_ATTRIBUTE5,'Y','Y','N')                 HOLD_CHARGED_INVOICES_FLAG
, 'N'                                                 MULTIPLE_INTEREST_RATES_FLAG
, f_date(JGZZ_ATTRIBUTE6)                             CHARGE_BEGIN_DATE
, DECODE(JGZZ_ATTRIBUTE1,'Y','Y',
                        NVL(INTEREST_CHARGES,'N'))    INTEREST_CHARGES
, f_NUMBER(JGZZ_ATTRIBUTE4)                           Message_text_id
FROM hz_cust_profile_classes                 cp,
     (SELECT MAX(jgzz_attribute7)  dom,
             PROFILE_CLASS_ID
        FROM hz_cust_prof_class_amts
       WHERE jgzz_attribute7     = 'M'
       GROUP BY PROFILE_CLASS_ID)     cpa
WHERE cp.rowid           >= p_start_rowid
  AND cp.rowid           <= p_end_rowid
  AND cp.PROFILE_CLASS_ID  = cpa.PROFILE_CLASS_ID(+);

l_rowid_tab                             DBMS_SQL.VARCHAR2_TABLE;
l_LATE_CHARGE_CALCULATION_TRX           DBMS_SQL.VARCHAR2_TABLE;
l_CREDIT_ITEMS_FLAG                     DBMS_SQL.VARCHAR2_TABLE;
l_DISPUTED_TRANSACTIONS_FLAG            DBMS_SQL.VARCHAR2_TABLE;
l_LATE_CHARGE_TYPE                      DBMS_SQL.VARCHAR2_TABLE;
l_LATE_CHARGE_TERM_ID                   DBMS_SQL.NUMBER_TABLE;
l_INTEREST_CALCULATION_PERIOD           DBMS_SQL.VARCHAR2_TABLE;
l_HOLD_CHARGED_INVOICES_FLAG            DBMS_SQL.VARCHAR2_TABLE;
l_MULTIPLE_INTEREST_RATES_FLAG          DBMS_SQL.VARCHAR2_TABLE;
l_CHARGE_BEGIN_DATE                     DBMS_SQL.DATE_TABLE;
l_INTEREST_CHARGES                      DBMS_SQL.VARCHAR2_TABLE;
l_Message_text_id                       DBMS_SQL.NUMBER_TABLE;



g_bulk_fetch_rows   NUMBER   := 10000;
l_last_fetch        BOOLEAN  := FALSE;

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
           l_rowid_tab,
           l_LATE_CHARGE_CALCULATION_TRX,
           l_CREDIT_ITEMS_FLAG,
           l_DISPUTED_TRANSACTIONS_FLAG,
           l_LATE_CHARGE_TYPE,
           l_LATE_CHARGE_TERM_ID,
           l_INTEREST_CALCULATION_PERIOD,
           l_HOLD_CHARGED_INVOICES_FLAG,
           l_MULTIPLE_INTEREST_RATES_FLAG,
           l_CHARGE_BEGIN_DATE,
           l_INTEREST_CHARGES,
           l_Message_text_id
     LIMIT g_bulk_fetch_rows;

     IF c%NOTFOUND THEN
       l_last_fetch := TRUE;
     END IF;

     IF (l_rowid_tab.COUNT = 0) AND (l_last_fetch) THEN
       EXIT;
     END IF;

     FORALL i IN l_rowid_tab.FIRST .. l_rowid_tab.LAST
       UPDATE hz_cust_profile_classes
          SET LATE_CHARGE_CALCULATION_TRX = l_LATE_CHARGE_CALCULATION_TRX(i),
              CREDIT_ITEMS_FLAG           = l_CREDIT_ITEMS_FLAG(i),
              DISPUTED_TRANSACTIONS_FLAG  = l_DISPUTED_TRANSACTIONS_FLAG(i),
              LATE_CHARGE_TYPE            = l_LATE_CHARGE_TYPE(i),
              LATE_CHARGE_TERM_ID         = l_LATE_CHARGE_TERM_ID(i),
              INTEREST_CALCULATION_PERIOD = l_INTEREST_CALCULATION_PERIOD(i),
              HOLD_CHARGED_INVOICES_FLAG  = l_HOLD_CHARGED_INVOICES_FLAG(i),
              MULTIPLE_INTEREST_RATES_FLAG= l_MULTIPLE_INTEREST_RATES_FLAG(i),
              CHARGE_BEGIN_DATE           = l_CHARGE_BEGIN_DATE(i),
              INTEREST_CHARGES            = l_INTEREST_CHARGES(i),
              Message_text_id             = l_Message_text_id(i),
              last_update_date            = g_creation_date,
              last_updated_by             = -1
        WHERE rowid = l_rowid_tab(i);

     l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

     IF l_last_fetch THEN
       EXIT;
     END IF;

   END LOOP;

   CLOSE c;


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
    --arp_standard.debug('NO_DATA_FOUND EXCEPTION: upgrade_profile_class');
    RAISE;

  WHEN OTHERS THEN
    --arp_standard.debug('OTHERS EXCEPTION: upgrade_profile_class');
    RAISE;

END upgrade_profile_class;



--Upgrade ar_payment_schedules_for_adj
--Phase 5
PROCEDURE upgrade_ps_for_adj
(l_table_owner  IN VARCHAR2, -- AR
 l_table_name   IN VARCHAR2, -- HZ_CUST_SITE_USES_ALL
 l_script_name  IN VARCHAR2, -- ar120lccsups.sql
 l_worker_id    IN VARCHAR2,
 l_num_workers  IN VARCHAR2,
 l_batch_size   IN VARCHAR2)
IS

l_start_rowid         rowid;
l_end_rowid           rowid;
l_any_rows_to_process boolean;
l_rows_processed      number := 0;

CURSOR c(p_start_rowid    IN ROWID, p_end_rowid      IN ROWID)  IS
SELECT trun.psch_rowid,
       trun.csu_last_charge_date
FROM
(SELECT /*+ ordered rowid(csu) use_nl(psch,adj)
         INDEX(psch ar_payment_schedules_n5)
         INDEX(adj  ar_adjustments_n3) */
        adj.adjustment_id              as adj_id,
        psch.rowid                     as psch_rowid,
        csu.last_accrue_charge_date    as csu_last_charge_date,
        rank () over (partition by adj.payment_schedule_id order by adjustment_id desc) as rk
  FROM hz_cust_site_uses_all    csu,
       ar_payment_schedules_all psch,
       ar_adjustments_all       adj
 WHERE csu.rowid                >= p_start_rowid
   AND csu.rowid                <= p_end_rowid
   AND csu.last_accrue_charge_date IS NOT NULL
   AND csu.SITE_USE_ID          = psch.CUSTOMER_SITE_USE_ID
   AND psch.status              = 'OP'
   AND psch.last_charge_date   IS NULL
   AND psch.payment_schedule_id = adj.payment_schedule_id
   AND adj.status               = 'A'
   AND adj.type                 = 'CHARGES'
 ) trun
WHERE trun.rk = 1;

l_rowid_tab                             DBMS_SQL.VARCHAR2_TABLE;
l_csu_last_charge_date                  DBMS_SQL.DATE_TABLE;

g_bulk_fetch_rows   NUMBER   := 10000;
l_last_fetch        BOOLEAN  := FALSE;

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
       l_rowid_tab            ,
       l_csu_last_charge_date
     LIMIT g_bulk_fetch_rows;

     IF c%NOTFOUND THEN
       l_last_fetch := TRUE;
     END IF;

     IF (l_rowid_tab.COUNT = 0) AND (l_last_fetch) THEN
       EXIT;
     END IF;

     FORALL i IN l_rowid_tab.FIRST .. l_rowid_tab.LAST
       UPDATE ar_payment_schedules_all
          SET last_charge_date  = l_csu_last_charge_date(i)
        WHERE rowid = l_rowid_tab(i);

     l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

     IF l_last_fetch THEN
       EXIT;
     END IF;

   END LOOP;

   CLOSE c;


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
    --arp_standard.debug('NO_DATA_FOUND EXCEPTION: upgrade_ps_for_adj');
    RAISE;

  WHEN OTHERS THEN
    --arp_standard.debug('OTHERS EXCEPTION: upgrade_ps_for_adj');
    RAISE;

END upgrade_ps_for_adj;





--Phase 5
PROCEDURE upgrade_lc_sysp
(l_table_owner  IN VARCHAR2, -- AR
 l_table_name   IN VARCHAR2, -- AR_SYSTEM_PARAMETERS_ALL
 l_script_name  IN VARCHAR2, -- ar120lcsysp.sql
 l_worker_id    IN VARCHAR2,
 l_num_workers  IN VARCHAR2,
 l_batch_size   IN VARCHAR2)
IS

l_start_rowid         rowid;
l_end_rowid           rowid;
l_any_rows_to_process boolean;
l_rows_processed      number := 0;

CURSOR c(p_start_rowid    IN ROWID, p_end_rowid      IN ROWID)  IS
SELECT /*+ ordered rowid(sysp) use_nl(rabatch,ractt)
         INDEX(rabatch ra_batch_sources_u1)
         INDEX(ractt  ra_cust_trx_types_u1) */
       sysp.rowid             ,
       rabatch.batch_source_id,
       ractt.cust_trx_type_id
  from ar_system_parameters_all sysp,
       ra_batch_sources_all     rabatch,
       ra_cust_trx_types_all    ractt
 WHERE sysp.org_id    =  rabatch.org_id(+)
   AND rabatch.name(+)= 'Interest Invoice'
   AND sysp.org_id    =  ractt.org_id(+)
   AND ractt.name(+)  = 'Interest Invoice'
   AND sysp.rowid     >= p_start_rowid
   AND sysp.rowid     <= p_end_rowid;

l_rowid_tab                        DBMS_SQL.VARCHAR2_TABLE;
l_batch_source_id                  DBMS_SQL.NUMBER_TABLE;
l_cust_trx_type_id                 DBMS_SQL.NUMBER_TABLE;

g_bulk_fetch_rows   NUMBER   := 10000;
l_last_fetch        BOOLEAN  := FALSE;

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
         l_rowid_tab       ,
         l_batch_source_id ,
         l_cust_trx_type_id
     LIMIT g_bulk_fetch_rows;

     IF c%NOTFOUND THEN
       l_last_fetch := TRUE;
     END IF;

     IF (l_rowid_tab.COUNT = 0) AND (l_last_fetch) THEN
       EXIT;
     END IF;

     FORALL i IN l_rowid_tab.FIRST .. l_rowid_tab.LAST
       UPDATE ar_system_parameters_all
          SET late_charge_inv_type_id      = l_cust_trx_type_id(i),
              late_charge_batch_source_id  = l_batch_source_id(i),
              allow_late_charges           = 'Y'
        WHERE rowid = l_rowid_tab(i);

     l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

     IF l_last_fetch THEN
       EXIT;
     END IF;

   END LOOP;

   CLOSE c;


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
    --arp_standard.debug('NO_DATA_FOUND EXCEPTION: upgrade_ps_for_adj');
    RAISE;

  WHEN OTHERS THEN
    --arp_standard.debug('OTHERS EXCEPTION: upgrade_ps_for_adj');
    RAISE;

END upgrade_lc_sysp;





PROCEDURE upgrade_lc_site_use
(l_table_owner  IN VARCHAR2,
 l_table_name   IN VARCHAR2,
 l_script_name  IN VARCHAR2,
 l_worker_id    IN VARCHAR2,
 l_num_workers  IN VARCHAR2,
 l_batch_size   IN VARCHAR2)
IS
l_start_rowid         rowid;
l_end_rowid           rowid;
l_any_rows_to_process boolean;
l_rows_processed      number := 0;

l_sys_date              DATE;
g_bulk_fetch_rows   NUMBER   := 10000;
l_last_fetch        BOOLEAN  := FALSE;
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


SELECT sysdate INTO l_sys_date FROM sys.dual;

WHILE ( l_any_rows_to_process = TRUE )
LOOP

   l_rows_processed := 0;

   INSERT INTO HZ_CUST_SITE_USES_ALL
       ( SITE_USE_ID      ,
         CUST_ACCT_SITE_ID,
         SITE_USE_CODE    ,
         PRIMARY_FLAG     ,
         STATUS           ,
         LOCATION         ,
         ORG_ID           ,
         OBJECT_VERSION_NUMBER,
         CREATED_BY_MODULE,
         LAST_UPDATE_DATE ,
         CREATION_DATE    ,
         LAST_UPDATED_BY  ,
         CREATED_BY       ,
         LAST_UPDATE_LOGIN)
       SELECT HZ_CUST_SITE_USES_S.NEXTVAL,
              l.cust_acct_site_id,
              'LATE_CHARGE',
              'Y',
              'A',
              TO_CHAR(HZ_CUST_SITE_USES_S.CURRVAL),
              l.org_id,
              1,
              'AR_LATE_CHARGE_UPG',
              l_sys_date,
              l_sys_date,
              -1551,
              -1551,
              -1551
         FROM (SELECT cas.cust_acct_site_id,
                      cas.org_id
                 FROM hz_cust_acct_sites_all           cas,
                      hz_cust_site_uses_all            csu
                WHERE cas.rowid             >= l_start_rowid
                  AND cas.rowid             <= l_end_rowid
                  AND cas.status            = 'A'
                  AND cas.cust_acct_site_id = csu.cust_acct_site_id
                  AND csu.status            = 'A'
                  AND ((     csu.site_use_code     = 'STMTS'
                         AND NOT EXISTS (SELECT NULL FROM hz_cust_site_uses_all b WHERE
                                            b.cust_acct_site_id = cas.cust_acct_site_id
                                            AND b.site_use_code     = 'DUN'
                                            AND b.status            = 'A'))
                      OR csu.site_use_code     = 'DUN')) l;



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

END LOOP ; /* end of WHILE loop */

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    --arp_standard.debug('NO_DATA_FOUND EXCEPTION: upgrade_lc_site_use');
    RAISE;

  WHEN OTHERS THEN
    --arp_standard.debug('OTHERS EXCEPTION: upgrade_lc_site_use');
    RAISE;

END upgrade_lc_site_use;


END;

/
