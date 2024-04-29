--------------------------------------------------------
--  DDL for Package Body JL_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_CMERGE" AS
/* $Header: jlzzmrgb.pls 120.5.12010000.2 2009/04/21 10:16:59 nivnaray ship $ */

-----------------------Private Variables------------------------------------
g_count   NUMBER :=0;
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   jl_br_bnk_rtrn_upd                                                   --
--                                                                        --
-- DESCRIPTION                                                            --
--   Merge duplicate customer_id stored in column of  table               --
--   JL_BR_AR_BANK_RETURNS_ALL that refers to cust_account_id column of   --
--   HZ_CUST_ACCOUNTS                                                     --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.5                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--   req_id                                                               --
--   set_num                                                              --
--   process_mode                                                         --
--                                                                        --
-- HISTORY:                                                               --
--    06/08/01     Vidya Sidharthan    Created                            --
----------------------------------------------------------------------------
PROCEDURE jl_br_bank_rtrn_upd (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE RETURN_ID_LIST_TYPE IS TABLE OF
         JL_BR_AR_BANK_RETURNS.RETURN_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST RETURN_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         JL_BR_AR_BANK_RETURNS.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;


  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,RETURN_ID
              ,yt.CUSTOMER_ID
         FROM JL_BR_AR_BANK_RETURNS yt, ra_customer_merges m
         WHERE (
            yt.CUSTOMER_ID = m.DUPLICATE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','JL_BR_AR_BANK_RETURNS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          LIMIT 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'JL_BR_AR_BANK_RETURNS',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE JL_BR_AR_BANK_RETURNS yt SET
           CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE RETURN_ID=PRIMARY_KEY_ID_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'jl_br_bank_rtrn_upd');
    RAISE;
END jl_br_bank_rtrn_upd;



----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   jl_br_occ_doc_upd                                                    --
--                                                                        --
-- DESCRIPTION                                                            --
--   Merge duplicate customer_id and site_use_id stored in column of      --
--   JL_BR_AR_OCCURRENCE_DOCS_ALL that refers to site_use_id column of    --
--   HZ_CUST_ACCT_SITES_ALL  and cust_account_id of HZ_CUST_ACCOUNTS      --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.5                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--   req_id                                                               --
--   set_num                                                              --
--   process_mode                                                         --
--                                                                        --
-- HISTORY:                                                               --
--    06/08/01     Vidya Sidharthan    Created                            --
----------------------------------------------------------------------------
PROCEDURE jl_br_occ_doc_upd (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE OCCURRENCE_ID_LIST_TYPE IS TABLE OF
         JL_BR_AR_OCCURRENCE_DOCS.OCCURRENCE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST OCCURRENCE_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         JL_BR_AR_OCCURRENCE_DOCS.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  TYPE SITE_USE_ID_LIST_TYPE IS TABLE OF
         JL_BR_AR_OCCURRENCE_DOCS.SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST SITE_USE_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST SITE_USE_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,OCCURRENCE_ID
              ,yt.CUSTOMER_ID
              ,yt.SITE_USE_ID
         FROM JL_BR_AR_OCCURRENCE_DOCS yt, ra_customer_merges m
         WHERE (
           yt.CUSTOMER_ID = m.DUPLICATE_ID
           OR yt.SITE_USE_ID = m.DUPLICATE_SITE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','JL_BR_AR_OCCURRENCE_DOCS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          LIMIT 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
        NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
        NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           NUM_COL2_ORIG,
           NUM_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'JL_BR_AR_OCCURRENCE_DOCS',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         NUM_COL2_ORIG_LIST(I),
         NUM_COL2_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
    );
    END IF;

    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE JL_BR_AR_OCCURRENCE_DOCS yt SET
           CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
          ,SITE_USE_ID=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE OCCURRENCE_ID=PRIMARY_KEY_ID_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'jl_br_occ_doc_upd');
    RAISE;
END jl_br_occ_doc_upd;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--                                                                        --
--   jl_br_pay_sch_up
-- DESCRIPTION                                                            --
--   Merge duplicate site use id's stored in column of table              --
--   JL_BR_AR_PAY_SCH_UPD that refers to Site_Use_id column of            --
--   table HZ_CUST_ACCT_SITES_ALL                                         --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.5                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--   req_id                                                               --
--   set_num                                                              --
--   process_mode                                                         --
--                                                                        --
-- HISTORY:                                                               --
--    06/08/01     Vidya Sidharthan    Created                            --
----------------------------------------------------------------------------

PROCEDURE jl_br_pay_sch_upd (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE PAYMENT_SCHEDULE_ID_LIST_TYPE IS TABLE OF
         JL_BR_AR_PAY_SCHED_AUX.PAYMENT_SCHEDULE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST PAYMENT_SCHEDULE_ID_LIST_TYPE;

  TYPE CUSTOMER_SITE_USE_ID_LIST_TYPE IS TABLE OF
         JL_BR_AR_PAY_SCHED_AUX.CUSTOMER_SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_SITE_USE_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_SITE_USE_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,PAYMENT_SCHEDULE_ID
              ,yt.CUSTOMER_SITE_USE_ID
         FROM JL_BR_AR_PAY_SCHED_AUX yt, ra_customer_merges m
         WHERE (
            yt.CUSTOMER_SITE_USE_ID = m.DUPLICATE_SITE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','JL_BR_AR_PAY_SCHED_AUX',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
         LIMIT 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL1_ORIG_LIST(I));
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'JL_BR_AR_PAY_SCHED_AUX',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE JL_BR_AR_PAY_SCHED_AUX yt SET
           CUSTOMER_SITE_USE_ID=NUM_COL1_NEW_LIST(I)
      WHERE PAYMENT_SCHEDULE_ID=PRIMARY_KEY_ID_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'jl_br_pay_sch_upd');
    RAISE;
END jl_br_pay_sch_upd;



----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   jl_zz_tx_cus_cls_upd                                                 --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.5                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--   req_id                                                               --
--   set_num                                                              --
--   process_mode                                                         --
--                                                                        --
-- HISTORY:                                                               --
--                                                                        --
--    06/09/01     Sudhir Sekuri    Created                               --
--    07/05/01     Sudhir Sekuri    Replaced Update with Delete stmt.     --
--    08/23/02     Sudhir Sekuri    Stubbed. Condition handled in form    --
--                                  to filter merged customers.           --
----------------------------------------------------------------------------
PROCEDURE jl_zz_tx_cus_cls_upd (req_id NUMBER,
		                set_num NUMBER,
		                process_mode VARCHAR2)
IS

BEGIN
  NULL;
END jl_zz_tx_cus_cls_upd;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   jl_zz_tx_exc_cus_upd                                                 --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.5                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--   req_id                                                               --
--   set_num                                                              --
--   process_mode                                                         --
--                                                                        --
-- HISTORY:                                                               --
--                                                                        --
--    06/09/01     Sudhir Sekuri    Created                               --
--    07/05/01     Sudhir Sekuri    Replaced Update with Delete stmt.     --
--    08/23/02     Sudhir Sekuri    Stubbed. Condition handled in form    --
--                                  to filter merged customers.           --
----------------------------------------------------------------------------
PROCEDURE jl_zz_tx_exc_cus_upd (req_id NUMBER,
		                set_num NUMBER,
		                process_mode VARCHAR2)
IS

BEGIN
  NULL;
END jl_zz_tx_exc_cus_upd;


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   jl_zz_tx_lgl_msg_upd                                                 --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.5                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--   req_id                                                               --
--   set_num                                                              --
--   process_mode                                                         --
--                                                                        --
-- HISTORY:                                                               --
--                                                                        --
--    06/11/01     Sudhir Sekuri    Created                               --
--    07/05/01     Sudhir Sekuri    Replaced Update with Delete stmt.     --
--    08/23/02     Sudhir Sekuri    Stubbed. Condition handled in form    --
--                                  to filter merged customers.           --
----------------------------------------------------------------------------
PROCEDURE jl_zz_tx_lgl_msg_upd (req_id NUMBER,
                                set_num NUMBER,
                                process_mode VARCHAR2)
IS

BEGIN
  NULL;
END jl_zz_tx_lgl_msg_upd;


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   JL_BR_JOURNALS_UPD                                                   --
--                                                                        --
-- DESCRIPTION                                                            --
--   Merge duplicate customer_id stored in column of                      --
--   JL_BR_JOURNALS_ALL that refers to cust_account_id column of          --
--   HZ_CUST_ACCOUNTS                                                     --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.5                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--   req_id                                                               --
--   set_num                                                              --
--   process_mode                                                         --
--                                                                        --
-- HISTORY:                                                               --
--    06/26/01     Rafael Guerrero   Created                              --
----------------------------------------------------------------------------
PROCEDURE jl_br_journals_upd (req_id NUMBER,
		              set_num NUMBER,
		              process_mode VARCHAR2)
IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE application_id_LIST_TYPE IS TABLE OF
         JL_BR_JOURNALS_ALL.application_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY1_LIST application_id_LIST_TYPE;

  TYPE set_of_books_id_LIST_TYPE IS TABLE OF
         JL_BR_JOURNALS_ALL.set_of_books_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY2_LIST set_of_books_id_LIST_TYPE;

  TYPE code_combination_id_LIST_TYPE IS TABLE OF
         JL_BR_JOURNALS_ALL.code_combination_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY3_LIST code_combination_id_LIST_TYPE;

  TYPE personnel_id_LIST_TYPE IS TABLE OF
         JL_BR_JOURNALS_ALL.personnel_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY4_LIST personnel_id_LIST_TYPE;
  NUM_COL1_ORIG_LIST PERSONNEL_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST PERSONNEL_ID_LIST_TYPE;


  TYPE accounting_date_LIST_TYPE IS TABLE OF
         JL_BR_JOURNALS_ALL.accounting_date%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY5_LIST accounting_date_LIST_TYPE;

  TYPE trans_description_LIST_TYPE IS TABLE OF
         JL_BR_JOURNALS_ALL.trans_description%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY6_LIST trans_description_LIST_TYPE;


  TYPE trans_id_LIST_TYPE IS TABLE OF
         JL_BR_JOURNALS_ALL.trans_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY7_LIST trans_id_LIST_TYPE;

  TYPE installment_LIST_TYPE IS TABLE OF
         JL_BR_JOURNALS_ALL.installment%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY8_LIST installment_LIST_TYPE;

  TYPE period_set_name_LIST_TYPE IS TABLE OF
         JL_BR_JOURNALS_ALL.period_set_name%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY9_LIST period_set_name_LIST_TYPE;


  TYPE period_name_LIST_TYPE IS TABLE OF
         JL_BR_JOURNALS_ALL.period_name%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY10_LIST period_name_LIST_TYPE;

  TYPE JOURNAL_BALANCE_FLAG_LIST_TYPE IS TABLE OF
        JL_BR_JOURNALS_ALL.JOURNAL_BALANCE_FLAG%TYPE
        INDEX BY BINARY_INTEGER;
  VCHAR_COL1_ORIG_LIST JOURNAL_BALANCE_FLAG_LIST_TYPE;
  VCHAR_COL1_NEW_LIST  JOURNAL_BALANCE_FLAG_LIST_TYPE;

  l_profile_val VARCHAR2(30);

  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,application_id
              ,set_of_books_id
              ,code_combination_id
              ,personnel_id
              ,accounting_date
              ,trans_description
              ,trans_id
              ,installment
              ,period_set_name
              ,period_name
              ,personnel_id
              ,journal_balance_flag
 FROM JL_BR_JOURNALS_ALL yt, ra_customer_merges m
 WHERE yt.PERSONNEL_ID = m.duplicate_id
 AND m.process_flag = 'N'
 AND m.request_id = req_id
 AND m.set_number = set_num
 AND yt.application_id=222;

-- replaced by cursor above
-- CURSOR c1 IS
--  SELECT SET_OF_BOOKS_ID
--  FROM jl_br_journals_all
--  WHERE (personnel_id) IN (SELECT unique m.duplicate_id
--                           FROM ra_customer_merges m
--                           WHERE m.process_flag = 'N'
--                         AND m.request_id = req_id
--                           AND m.set_number = set_num)
-- AND application_id=222
-- FOR UPDATE NOWAIT;


  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;

BEGIN

  arp_message.set_line ('JL_CMERGE.JL_BR_JOURNALS_UPD()+');

  IF (process_mode = 'LOCK' ) THEN
    arp_message.set_name ('AR', 'AR_LOCKING_TABLE');
    arp_message.set_token ('TABLE_NAME','JL_BR_JOURNALS_ALL',FALSE);

--    open c1;
--    close c1;

    open merged_records;
    close merged_records;

  ELSE


  --customer level update--
/*
    UPDATE jl_br_journals_all j
    SET personnel_id = (SELECT distinct m.customer_id
                       FROM ra_customer_merges m
                       WHERE j.personnel_id = m.duplicate_id
                       AND m.process_flag = 'N'
                       AND m.request_id = req_id
                       AND m.set_number = set_num),
         last_update_date = SYSDATE,
         last_updated_by = arp_standard.profile.user_id,
         last_update_login = arp_standard.profile.last_update_login,
    JOURNAL_BALANCE_FLAG = 'N'
    WHERE (personnel_id) IN (SELECT unique m.duplicate_id
                            FROM ra_customer_merges m
                            WHERE m.process_flag = 'N'
                            AND m.request_id = req_id
                            AND m.set_number = set_num)
    AND application_id=222;
    g_count := SQL%ROWCOUNT;
*/

    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','JL_BR_JOURNALS_ALL',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

   l_count:=0;
    open merged_records;

    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY1_LIST
          , PRIMARY_KEY2_LIST
          , PRIMARY_KEY3_LIST
          , PRIMARY_KEY4_LIST
          , PRIMARY_KEY5_LIST
          , PRIMARY_KEY6_LIST
          , PRIMARY_KEY7_LIST
          , PRIMARY_KEY8_LIST
          , PRIMARY_KEY9_LIST
          , PRIMARY_KEY10_LIST
          , NUM_COL1_ORIG_LIST
          , VCHAR_COL1_ORIG_LIST
           LIMIT 1000;

      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;

      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP

         NUM_COL1_NEW_LIST(I) :=HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));

-- Is defaulted to N because, the journals need to added to the balance of the customer
         VCHAR_COL1_NEW_LIST(I) :='N';

      END LOOP;

      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID,
           PRIMARY_KEY_ID1,
           PRIMARY_KEY_ID2,
           PRIMARY_KEY_ID3,
           PRIMARY_KEY1,
           PRIMARY_KEY2,
           PRIMARY_KEY3,
           PRIMARY_KEY4,
           PRIMARY_KEY5,
           PRIMARY_KEY6,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'JL_BR_JOURNALS_ALL',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY1_LIST(I),
         PRIMARY_KEY2_LIST(I),
         PRIMARY_KEY3_LIST(I),
         PRIMARY_KEY4_LIST(I),
         to_char( PRIMARY_KEY5_LIST(I)),
         PRIMARY_KEY6_LIST(I),
         PRIMARY_KEY7_LIST(I),
         to_char( PRIMARY_KEY8_LIST(I)),
         PRIMARY_KEY9_LIST(I),
         PRIMARY_KEY10_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         VCHAR_COL1_ORIG_LIST(I),
         VCHAR_COL1_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;

   FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT

      UPDATE JL_BR_JOURNALS_ALL
      SET
           PERSONNEL_ID=NUM_COL1_NEW_LIST(I)
          ,JOURNAL_BALANCE_FLAG=VCHAR_COL1_NEW_LIST(I)
          ,last_update_date = SYSDATE
          ,last_updated_by = arp_standard.profile.user_id
          ,last_update_login = arp_standard.profile.last_update_login
      WHERE personnel_id = NUM_COL1_ORIG_LIST(I)
      AND application_id=222;

      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name ('AR','AR_ROWS_UPDATED');
    arp_message.set_token ('NUM_ROWS', to_char(l_count) );

  END IF ;
    arp_message.set_line('JL_CMERGE.JL_BR_JOURNALS_UPD()-');

  EXCEPTION
    WHEN OTHERS THEN
      arp_message.set_error ('JL_CMERGE.JL_BR_JOURNALS_UPD');
      RAISE;
END jl_br_journals_upd;


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   JL_BR_BALANCES_UPD                                                   --
--                                                                        --
-- DESCRIPTION                                                            --
--   Merge duplicate customer_id stored in column of                      --
--   JL_BR_BALANCES_ALL that refers to cust_account_id column of          --
--   HZ_CUST_ACCOUNTS                                                     --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.5                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--   req_id                                                               --
--   set_num                                                              --
--   process_mode                                                         --
--                                                                        --
-- HISTORY:                                                               --
--    06/26/01     Rafael Guerrero   Created                              --
----------------------------------------------------------------------------

PROCEDURE jl_br_balances_upd (req_id NUMBER,
		              set_num NUMBER,
		              process_mode VARCHAR2)
IS

/*
CURSOR c1 IS
  SELECT SET_OF_BOOKS_ID
  FROM jl_br_balances_all
  WHERE (personnel_id) IN (SELECT unique m.duplicate_id
                           FROM ra_customer_merges m
                           WHERE m.process_flag = 'N'
                           AND m.request_id = req_id
                           AND m.set_number = set_num)
  AND application_id=222
  FOR UPDATE NOWAIT;
*/

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE application_id_LIST_TYPE IS TABLE OF
         JL_BR_BALANCES_ALL.application_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY1_LIST application_id_LIST_TYPE;

  TYPE set_of_books_id_LIST_TYPE IS TABLE OF
         JL_BR_BALANCES_ALL.set_of_books_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY2_LIST set_of_books_id_LIST_TYPE;

  TYPE period_set_name_LIST_TYPE IS TABLE OF
         JL_BR_BALANCES_ALL.period_set_name%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY3_LIST period_set_name_LIST_TYPE;

  TYPE period_name_LIST_TYPE IS TABLE OF
         JL_BR_BALANCES_ALL.period_name%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY4_LIST period_name_LIST_TYPE;

  TYPE code_combination_id_LIST_TYPE IS TABLE OF
         JL_BR_BALANCES_ALL.code_combination_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY5_LIST code_combination_id_LIST_TYPE;

  TYPE personnel_id_LIST_TYPE IS TABLE OF
         JL_BR_BALANCES_ALL.personnel_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY6_LIST personnel_id_LIST_TYPE;

  NUM_COL1_ORIG_LIST personnel_id_LIST_TYPE;
  NUM_COL1_NEW_LIST personnel_id_LIST_TYPE;

  TYPE ending_balance_LIST_TYPE IS TABLE OF
         JL_BR_BALANCES_ALL.ending_balance%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST ending_balance_LIST_TYPE;
  NUM_COL2_NEW_LIST ending_balance_LIST_TYPE;

  TYPE org_id_LIST_TYPE IS TABLE OF
         JL_BR_BALANCES_ALL.org_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST org_id_LIST_TYPE;
  NUM_COL3_NEW_LIST org_id_LIST_TYPE;

  TYPE ending_balance_sign_LIST_TYPE IS TABLE OF
         JL_BR_BALANCES_ALL.ending_balance_sign%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL4_ORIG_LIST ending_balance_sign_LIST_TYPE;
  NUM_COL4_NEW_LIST ending_balance_sign_LIST_TYPE;

  TYPE period_year_LIST_TYPE IS TABLE OF
         JL_BR_BALANCES_ALL.period_year%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL5_ORIG_LIST period_year_LIST_TYPE;
  NUM_COL5_NEW_LIST period_year_LIST_TYPE;

  TYPE period_num_LIST_TYPE IS TABLE OF
         JL_BR_BALANCES_ALL.period_num%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL6_ORIG_LIST period_num_LIST_TYPE;
  NUM_COL6_NEW_LIST period_num_LIST_TYPE;

  l_profile_val VARCHAR2(30);

  CURSOR merged_records IS
        SELECT distinct
          m.CUSTOMER_MERGE_HEADER_ID
           ,yt.application_id
           ,yt.set_of_books_id
           ,yt.period_set_name
           ,yt.period_name
           ,yt.code_combination_id
           ,yt.personnel_id
           ,yt.personnel_id
           ,yt.ending_balance
           ,yt.org_id
           ,yt.ending_balance_sign
           ,yt.period_year
           ,yt.period_num
  FROM JL_BR_BALANCES_ALL yt,
       ra_customer_merges m
  WHERE (yt.personnel_id = m.duplicate_id)
        AND m.process_flag = 'N'
        AND m.request_id = req_id
        AND m.set_number = set_num
        and yt.application_id =222;

  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;

PROCEDURE BALANCES IS

/*------------------------------------------------------------*/
/*<<<<<            Balance Building Routine              >>>>>*/
/*------------------------------------------------------------*/

    pl_period_num       number;
    pl_sob              number;
    pl_per              varchar2(15);
    pl_per_set          varchar2(15);
    pl_min_pyear        number;
    pl_max_pyear        number;
    pl_min_pnum         number;
    pl_max_pnum         number;
    pl_pyear            number;
    pl_pnum             number;
    pl_ccid             number;
    pl_sign             varchar2(1);
    pl_val              number;
    pl_user             number;
    pl_personnel_id     number;

    pl_curr_per_set     varchar2(15);
    pl_curr_sob         number:=1;

    x_org		number;
    x_profile_org       number;

        cursor c_bmb is
        -- Summarize journals by period/account/customer
           SELECT /*+ ORDERED */
             jb.set_of_books_id sob,
             jb.period_set_name perset,
             gp.period_year pyear,
             gp.period_num pnum,
             jb.period_name per,
             jb.code_combination_id ccid,
             jb.personnel_id venid,
             SUM(DECODE(jb.trans_value_sign,'D',-1*jb.trans_value,jb.trans_value)) bal,
             jb.org_id org_id
           FROM jl_br_journals jb,
                gl_periods gp
           WHERE application_id=222
           AND journal_balance_flag='N'
           AND jb.period_name   = gp.period_name
           AND jb.period_set_name = gp.period_set_name
           AND jb.personnel_id = pl_personnel_id
           GROUP BY jb.set_of_books_id,
             jb.period_set_name,
             gp.period_year,
             gp.period_num,
             jb.period_name,
             jb.code_combination_id,
             jb.personnel_id,
             jb.org_id
            ORDER BY jb.set_of_books_id, gp.period_year, gp.period_num;

        -- Retrieves all periods between max posted period and period being treated
        cursor c_per is
                select period_name pername,
                       period_year peryear,
                       period_num pernum
                  from gl_periods
                 where period_set_name = pl_per_set
                   and (period_year = pl_max_pyear
                   and  period_num > pl_max_pnum)
                    or (period_year > pl_max_pyear
                   and  period_year < pl_pyear)
                    or (period_year = pl_pyear
                   and  period_num < pl_pnum)
              order by period_year, period_num;

          r_per c_per%rowtype;

      /* cursor c_org is
         Select unique org_id
         from jl_br_journals_all
         where application_id=222; */
      Cursor c_org is   -- bug 3563804
        Select org_id
        from ar_system_parameters_all
        where global_attribute_category = 'JL.BR.ARXSYSPA.Additional Info';


       CURSOR c_customer IS
       SELECT unique m.customer_id
       FROM ra_customer_merges m
       WHERE m.process_flag = 'N'
       AND m.request_id = req_id
       AND m.set_number = set_num;

  l_profile_val VARCHAR2(30);

BEGIN
  pl_curr_per_set:='<different>';

  Open c_customer;
  Fetch c_customer into pl_personnel_id;
  close c_customer;


   x_profile_org:=fnd_profile.value ('ORG_ID');

   ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
   ARP_MESSAGE.SET_TOKEN('TABLE_NAME','JL_BR_BALANCES_ALL',FALSE);
   HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);

   l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

-- For each Brazilian organization, update the balances.

   Open c_org;

   Loop
   Fetch c_org into x_org;
   Exit when c_org%notfound;

   Fnd_client_Info.set_org_context(x_org);

    FOR r_bmb IN c_bmb LOOP

        pl_user    := FND_GLOBAL.user_id;

        pl_sob     := r_bmb.sob;
        pl_per_set := r_bmb.perset;
        pl_pyear   := r_bmb.pyear;
        pl_pnum    := r_bmb.pnum;


        ---------------------------------------
        -- Get Balance sign and Balance amount
        ---------------------------------------

        pl_val :=ABS(r_bmb.bal);
        IF r_bmb.bal<0 THEN
            pl_sign:='D';
        ELSE
            pl_sign:='C';
        END IF;

/******************************************************************
 If per_set or sob are different, then query max pyear and pnum,
 else max pyear and pnum are equal to last value from cursor
 for pyear and pnum
******************************************************************/

if (pl_curr_per_set <> pl_per_set or pl_curr_sob <> pl_sob) then

        ----------------------------------------------------------
        -- Get the maximum period_year existing in balances table
        -- this is the max year posted from AR to GL
        ----------------------------------------------------------

        select nvl(max(period_year),0)
          into pl_max_pyear
          from jl_br_balances
         where application_id = 222
           and set_of_books_id = r_bmb.sob
           and period_set_name = r_bmb.perset;

        ---------------------------------------------------------------
        -- Get the maximum period_number existing in balances table
        -- this is the max period posted from AR to GL in the max year
        -- this is also the last period posted
        ---------------------------------------------------------------

        select nvl(max(period_num),0)
          into pl_max_pnum
          from jl_br_balances
         where application_id = 222
           and set_of_books_id = r_bmb.sob
           and period_set_name = r_bmb.perset
           and period_year = pl_max_pyear;


        ----------------------------------------------------------------------------
        -- Get the minimum period_year existing in balances table - this is the min
        -- year posted from AR to GL for the same account/customer
        ----------------------------------------------------------------------------

        select nvl(min(period_year),0)
          into pl_min_pyear
          from jl_br_balances
         where application_id = 222
           and set_of_books_id = r_bmb.sob
           and period_set_name = r_bmb.perset
           and code_combination_id = r_bmb.ccid
           and personnel_id = r_bmb.venid;

        -------------------------------------------------------------------------------
        -- Get the minimum period_number existing in balances table - this is the min
        -- period posted from AR to GL in the min year - this is also the first period
        -- posted for the same account/customer
        -------------------------------------------------------------------------------

        SELECT NVL(MIN(period_num),0)
          INTO pl_min_pnum
          FROM jl_br_balances
         WHERE application_id = 222
           AND set_of_books_id = r_bmb.sob
           AND period_set_name = r_bmb.perset
           AND code_combination_id = r_bmb.ccid
           AND personnel_id = r_bmb.venid
           AND period_year = pl_min_pyear;


      -- Update pl_curr_per_set and pl_curr to do a query for pl_max_pyear, pl_max_pnum, pl_min_pyear and
      -- pl_min_num, just if per_set or sob changes

      pl_curr_per_set   := pl_per_set;
      pl_curr_sob       := pl_sob;


end if;

        ---------------------------------------------------------------------------------
        -- If year being treated is greater than the max year posted in balances table
        -- or if year is the same but period being treated is greater than max period
        -- posted in balances table, then copy all balances of customer from last
        -- period posted in balances table to the new period being treated,
        -- later on this program this ending balance will be updated with amount being
        -- transferred
        ----------------------------------------------------------------------------------

        IF r_bmb.pyear > pl_max_pyear OR
           (r_bmb.pyear = pl_max_pyear AND
           r_bmb.pnum  > pl_max_pnum)  THEN

                   BEGIN

                    INSERT INTO jl_br_balances
                        (application_id,
                        set_of_books_id,
                        period_set_name,
                        period_name,
                        period_year,
                        period_num,
                        code_combination_id,
                        personnel_id,
                        ending_balance_sign,
                        ending_balance,
                        balance_error_flag,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        org_id)

                    SELECT
                        222,
                        r_bmb.sob,
                        r_bmb.perset,
                        r_bmb.per,
                        r_bmb.pyear,
                        r_bmb.pnum,
                        code_combination_id,
                        personnel_id,
                        ending_balance_sign,
                        ending_balance,
                        '',
                        sysdate,
                        pl_user,
                        sysdate,
                        pl_user,
                        r_bmb.org_id
                    FROM jl_br_balances
                    WHERE application_id = 222
                    AND set_of_books_id = r_bmb.sob
                    AND period_year = pl_max_pyear
                    AND period_num = pl_max_pnum;

                    -----------------------------------------------------------------------------------
                    -- When year being treated is equal to the max year already posted and period
                    --   being treated is greater than the max period posted, then program inserts
                    --   all these new periods between max period posted and period being treated so
                    --   that balances table can store the right amounts for all periods
                    -----------------------------------------------------------------------------------

                    IF r_bmb.pyear = pl_max_pyear THEN

                       INSERT INTO jl_br_balances
                          (application_id,
                          set_of_books_id,
                          period_set_name,
                          period_name,
                          period_year,
                          period_num,
                          code_combination_id,
                          personnel_id,
                          ending_balance_sign,
                          ending_balance,
                          balance_error_flag,
                          creation_date,
                          last_update_date,
                          last_updated_by,
                          org_id)
                       SELECT
                          222,
                          b.set_of_books_id,
                          b.period_set_name,
                          g.period_name,
                          g.period_year,
                          g.period_num,
                          b.code_combination_id,
                          b.personnel_id,
                          b.ending_balance_sign,
                          b.ending_balance,
                          b.balance_error_flag,
                          sysdate,
                          sysdate,
                          pl_user,
                          b.org_id
                       FROM jl_br_balances b,
                           gl_periods g
                       WHERE b.application_id = 222
                         and b.period_set_name = g.period_set_name
                         and b.period_year = g.period_year
                         and b.period_year = pl_max_pyear
                         and b.period_num = pl_max_pnum
                       and g.period_num > pl_max_pnum
                       and g.period_num < r_bmb.pnum;

                  ELSE

                    ---------------------------------------------------------------------------------
                    -- Here program also creates new records in balances table for periods between
                    -- max period already posted and new period being treated but for different
                    -- years (when year being treated is greater than year already posted
                    ---------------------------------------------------------------------------------

                    OPEN c_per;
                    LOOP
                      fetch c_per into r_per;
                      exit when c_per%NOTFOUND;

                      BEGIN

                        INSERT INTO jl_br_balances
                          (application_id,
                          set_of_books_id,
                          period_set_name,
                          period_name,
                          period_year,
                          period_num,
                          code_combination_id,
                          personnel_id,
                          ending_balance_sign,
                          ending_balance,
                          balance_error_flag,
                          creation_date,
                          last_update_date,
                          last_updated_by,
                          org_id)
                        SELECT
                          222,
                          set_of_books_id,
                          period_set_name,
                          r_per.pername,
                          r_per.peryear,
                          r_per.pernum,
                          code_combination_id,
                          personnel_id,
                          ending_balance_sign,
                          ending_balance,
                          balance_error_flag,
                          sysdate,
                          sysdate,
                          pl_user,
                          r_bmb.org_id
                       FROM jl_br_balances
                       WHERE application_id = 222
                         and set_of_books_id = r_bmb.sob
                         and period_set_name = r_bmb.perset
                         and period_year = pl_max_pyear
                         and period_num = pl_max_pnum;

                    EXCEPTION
                        when dup_val_on_index then null;
                    END;

                END LOOP;

                CLOSE c_per;

                END IF;

                   EXCEPTION
                      WHEN NO_DATA_FOUND THEN NULL;   -- Will be treated as First Insert
                      WHEN DUP_VAL_ON_INDEX THEN NULL;

                   END;

         /**************************************************************
          After insert new lines to jl_br_balances to new periods,
          update pl_max_pyear and pl_max_pnum.
          ***************************************************************/
          pl_max_pyear := pl_pyear;
          pl_max_pnum := pl_pnum;

        END IF;


        -------------------------------------------------------------------------------
        -- If year being treated is smaller than the min year posted in balances table
        -- or if year is the same but period being treated is smaller than min period
        -- posted in balances table, then create balance lines for next periods to
        -- the same account and the same customer till current period
        --------------------------------------------------------------------------------

        IF r_bmb.pyear < pl_min_pyear OR
           (r_bmb.pyear = pl_min_pyear AND
           r_bmb.pnum  < pl_min_pnum)  THEN

           BEGIN
                    INSERT INTO jl_br_balances
                        (application_id,
                        set_of_books_id,
                        period_set_name,
                        period_name,
                        period_year,
                        period_num,
                        code_combination_id,
                        personnel_id,
                        ending_balance_sign,
                        ending_balance,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        org_id)
                   SELECT
                        222,
                        r_bmb.sob,
                        period_set_name,
                        period_name,
                        period_year,
                        period_num,
                        r_bmb.ccid,
                        r_bmb.venid,
                        'C',
                        0,
                        sysdate,
                        pl_user,
                        sysdate,
                        pl_user,
                        r_bmb.org_id
                   FROM gl_periods
                   WHERE period_set_name = r_bmb.perset
                    AND (r_bmb.pyear = pl_min_pyear
                        AND  period_year = pl_min_pyear
                           AND  period_num >= r_bmb.pnum
                              AND  period_num < pl_min_pnum)
                     OR (r_bmb.pyear < pl_min_pyear
                        AND  period_year = r_bmb.pyear
                           AND  period_num >= r_bmb.pnum)
                     OR (r_bmb.pyear < pl_min_pyear
                        AND  period_year > r_bmb.pyear
                           AND  period_year < pl_min_pyear)
                     OR (r_bmb.pyear < pl_min_pyear
                        AND  period_year = pl_min_pyear
                           AND  period_num < pl_min_pnum);

           EXCEPTION
                    WHEN DUP_VAL_ON_INDEX THEN NULL; -- Account/Customer has already been created
                    WHEN NO_DATA_FOUND THEN NULL;    -- No periods to treat
           END;

        /**************************************************************
          After insert new lines to jl_br_balances to new periods,
          update pl_min_pyear and pl_min_pnum.
         ***************************************************************/
         pl_min_pyear := pl_pyear;
         pl_min_pnum := pl_pnum;

        END IF;


        -------------------------------------------------------
        -- Update balances with trasactions amount transferred
        -- This is done for current and further on periods
        -------------------------------------------------------

        UPDATE jl_br_balances
           SET ending_balance = ABS(ending_balance + r_bmb.bal),
           ending_balance_sign = decode(sign(ending_balance + r_bmb.bal),-1,'D','C'),
           balance_error_flag = '',
           last_update_date = sysdate,
           last_updated_by = pl_user,
           last_update_login = FND_GLOBAL.login_id
        WHERE application_id = 222
          and set_of_books_id = r_bmb.sob
          and period_set_name = r_bmb.perset
          and code_combination_id = r_bmb.ccid
          and personnel_id = r_bmb.venid
          and ((period_year = r_bmb.pyear
          and  period_num >= r_bmb.pnum)
           or period_year > r_bmb.pyear);


       IF SQL%NOTFOUND THEN
        BEGIN

        ---------------------------------------------------------------------------------
        -- First Insert of an account, customer or period.
        -- If it fails because of a duplication on index (balance record already exists
        -- for this account, customer or period), program will do nothing. because
        -- this situation was treated in previous update command, which treats the
        -- same account and the same customer not only for the same period but also
        -- for periods that come after the one being treated - this is the case for
        -- transactions being treated in previous periods
        ---------------------------------------------------------------------------------

         INSERT INTO jl_br_balances
                        (application_id,
                        set_of_books_id,
                        period_set_name,
                        period_name,
                        period_year,
                        period_num,
                        code_combination_id,
                        personnel_id,
                        ending_balance_sign,
                        ending_balance,
                        creation_date,
                        last_update_date,
                        last_updated_by,
                        last_update_login,
                        created_by,
                        org_id)
         VALUES (
                        222,
                        r_bmb.sob,
                        r_bmb.perset,
                        r_bmb.per,
                        r_bmb.pyear,
                        r_bmb.pnum,
                        r_bmb.ccid,
                        r_bmb.venid,
                        pl_sign,
                        pl_val,
                        sysdate,
                        sysdate,
                        pl_user,
                        FND_GLOBAL.login_id,
                        pl_user,
                        r_bmb.org_id);

        EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN NULL;
        END;

       END IF;

        -------------------------------------------------------
        -- Update journals, change journal_balance_flag to 'Y'
        -- meaning that those journals have been acummulated to
        -- balaces
        -------------------------------------------------------

        UPDATE jl_br_journals
        SET journal_balance_flag = 'Y'
        WHERE application_id = 222
          AND set_of_books_id = r_bmb.sob
          AND code_combination_id = r_bmb.ccid
          AND personnel_id = r_bmb.venid
          AND period_set_name = r_bmb.perset
          AND period_name     = r_bmb.per
          AND journal_balance_flag='N';

 END LOOP;

 END LOOP; -- Organization

 CLOSE c_org;

   fnd_client_Info.set_org_context(x_profile_org);

 EXCEPTION
        WHEN OTHERS THEN
        Fnd_client_Info.set_org_context(x_profile_org);

END BALANCES;

BEGIN

  arp_message.set_line ('JL_CMERGE.JL_BR_BALANCES_UPD()+');

  IF (process_mode = 'LOCK' ) THEN
    arp_message.set_name ('AR', 'AR_LOCKING_TABLE');
    arp_message.set_token ('TABLE_NAME','JL_BR_BALANCES_ALL',FALSE);

    open merged_records;
    close merged_records;

  ELSE
  --customer level update--

/*
    delete jl_br_balances_all
    where (personnel_id) IN (SELECT unique m.duplicate_id
                            FROM ra_customer_merges m
                            WHERE m.process_flag = 'N'
                            AND m.request_id = req_id
                            AND m.set_number = set_num)
    AND application_id=222;

    g_count := SQL%ROWCOUNT;

*/
-- Replaced with new logic that will generate log file.

    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','JL_BR_BALANCES_ALL',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

   l_count:=0;

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY1_LIST
          , PRIMARY_KEY2_LIST
          , PRIMARY_KEY3_LIST
          , PRIMARY_KEY4_LIST
          , PRIMARY_KEY5_LIST
          , PRIMARY_KEY6_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          , NUM_COL3_ORIG_LIST
          , NUM_COL4_ORIG_LIST
          , NUM_COL5_ORIG_LIST
          , NUM_COL6_ORIG_LIST
           LIMIT 1000;

      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;

      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
-- 5 stores the personnel id
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));

      END LOOP;


      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY1,
           PRIMARY_KEY2,
           PRIMARY_KEY3,
           PRIMARY_KEY4,
           PRIMARY_KEY5,
           PRIMARY_KEY6,
           DEL_COL1,
           DEL_COL2,
           DEL_COL3,
           DEL_COL4,
           DEL_COL5,
           DEL_COL6,
           DEL_COL7,
           DEL_COL8,
           DEL_COL9,
           DEL_COL10,
           DEL_COL11,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (
          HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'JL_BR_BALANCES_ALL',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY1_LIST(I),
         PRIMARY_KEY2_LIST(I),
         PRIMARY_KEY3_LIST(I),
         PRIMARY_KEY4_LIST(I),
         PRIMARY_KEY5_LIST(I),
         PRIMARY_KEY6_LIST(I),
         PRIMARY_KEY1_LIST(I),
         PRIMARY_KEY2_LIST(I),
         PRIMARY_KEY3_LIST(I),
         PRIMARY_KEY4_LIST(I),
         PRIMARY_KEY5_LIST(I),
         PRIMARY_KEY6_LIST(I),
         NUM_COL2_ORIG_LIST(I),
         NUM_COL3_ORIG_LIST(I),
         NUM_COL4_ORIG_LIST(I),
         NUM_COL5_ORIG_LIST(I),
         NUM_COL6_ORIG_LIST(I),
         'D',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;

      FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      DELETE JL_BR_BALANCES_ALL
      WHERE application_id=PRIMARY_KEY1_LIST(I)
      AND set_of_books_id=PRIMARY_KEY2_LIST(I)
      AND period_set_name=PRIMARY_KEY3_LIST(I)
      AND period_name=PRIMARY_KEY4_LIST(I)
      AND code_combination_id=PRIMARY_KEY5_LIST(I)
      AND personnel_id=PRIMARY_KEY6_LIST(I);

      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name ('AR','AR_ROWS_UPDATED');
    arp_message.set_token ('NUM_ROWS', to_char(l_count) );

-- Call Procedure to Update Balances with the journals from the duplicated customer,
-- now in the merged customer.
   Balances;

  END IF ;
    arp_message.set_line('JL_CMERGE.JL_BR_BALANCES_UPD()-');

  EXCEPTION
    WHEN OTHERS THEN
      arp_message.set_error ('JL_CMERGE.JL_BR_BALANCES_UPD');
      RAISE;
END jl_br_balances_upd ;



----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   merge								  --
--                                                                        --
-- DESCRIPTION      							  --
--   Public routine to make calls to update tables                        --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.5                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--   req_id                                                               --
--   set_num                                                              --
--   process_mode                                                         --
--                                                                        --
-- HISTORY:                                                               --
--    06/08/01     Vidya Sidharthan    Created                            --
----------------------------------------------------------------------------
PROCEDURE merge (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is
BEGIN

  /************************************************************
   Validate the Application just for Brazil
   Check if the country installed is Brazil
   We could not use fnd_profile.value('JGZZ_COUNTRY_CODE')
   *************************************************************/

 if fnd_profile.value('JGZZ_PRODUCT_CODE') <> 'JL' or  fnd_profile.value('JGZZ_COUNTRY_CODE') <> 'BR' then
    return;
 end if;


  arp_message.set_line ('JL_CMERGE.MERGE()+');
  jl_br_bank_rtrn_upd (req_id, set_num, process_mode);
  jl_br_occ_doc_upd (req_id, set_num, process_mode);
  jl_br_pay_sch_upd (req_id,set_num,process_mode);
  jl_zz_tx_cus_cls_upd (req_id,set_num,process_mode);
  jl_zz_tx_exc_cus_upd (req_id,set_num,process_mode);
  jl_zz_tx_lgl_msg_upd (req_id,set_num,process_mode);
  --jl_br_journals_upd (req_id,set_num,process_mode);     -- bug 8362076  Commented the call as the journals table is not in use
  --jl_br_balances_upd (req_id,set_num,process_mode);	  -- bug 8362076  Commented the call as the balances table is not in use
  arp_message.set_line ('JL_CMERGE.MERGE()-');

END merge;
END jl_cmerge;

/
