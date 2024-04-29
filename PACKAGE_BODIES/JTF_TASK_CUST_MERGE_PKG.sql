--------------------------------------------------------
--  DDL for Package Body JTF_TASK_CUST_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_CUST_MERGE_PKG" as
/* $Header: jtftkmgb.pls 115.15 2003/02/20 23:03:56 cjang ship $ */
--/**==================================================================*
--|   Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA   |
--|                        All rights reserved.                        |
--+====================================================================+
-- Package body for JTF_TASK_CUST_MERGE_PKG package
--
--      Version :  1.0
-- Performs an account merge for TASKS module.
-------------------------------------------------------------------------------------------
--                              History
-------------------------------------------------------------------------------------------
--      01-FEB-01       tivanov         Created.
--      29-OCT-01       tivanov         Added account merge for task's saved search
--                                      in jtf_perz_query_param
--      29-APR-02       sanjeev choudhary       Changed the update calls for bug  2288291
--                                              Customer merge issue
--      13-AUG-02       chanik jang     Added statments to log the change information
--                                         for the bug 2465855
--      12-FEB-03       Chanik Jang     1) Customer Account Merge allows to merge account
--                                         only in the same party
--                                      2) If you want to merge between different parties,
--                                         submit party merge first.
--                                      3) The lock mode is not implemented
--                                      4) For performance, the codes generated the perl script
--                                          is used. Refer http://www-apps.us.oracle.com/~csng/AMInstructions.html
--      19-FEB-03       Chanik Jang     Added LIMIT g_rows_fetched in BULK COLLECT clause
--      20-FEB-03       Chanik Jang     Modified merge_perz() to update account_number as char
--                                      Modified each procedures to update primary_key_id instead of primary_key_id1
---------------------------------------------------------------------------------
-- End of comments

    TYPE AccountNumberList IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    g_acctnum_list AccountNumberList;

    g_profile_val VARCHAR2(30);
    g_rows_fetched NUMBER := 1000;

    -- Load the new account number corresponding to the duplicate account
    PROCEDURE load_acct_number_set (
      p_set_num    IN NUMBER,
      p_request_id IN NUMBER)
    IS
    BEGIN
      g_acctnum_list.DELETE;

      FOR CUST IN (SELECT distinct m.customer_id, acct.account_number
                     FROM ra_customer_merges m
                        , hz_cust_accounts acct
                    WHERE m.set_number = p_set_num
                      AND m.request_id = p_request_id
                      AND m.process_flag = 'N'
                      AND acct.cust_account_id = m.customer_id
                  )
      LOOP

         g_acctnum_list(CUST.customer_id) := CUST.account_number;

      END LOOP;

    END;

    FUNCTION GETDUP_ACCOUNT_NUMBER (p_acct_id IN VARCHAR2)
    RETURN VARCHAR2
    IS
    BEGIN
      IF p_acct_id IS NULL THEN
        RETURN p_acct_id;
      END IF;

      RETURN g_acctnum_list(p_acct_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN p_acct_id;
    END;

    ----------------------------------------------------------------------
    -- merge_tasks(): merge cust_account_id in jtf_tasks_b table.
    ----------------------------------------------------------------------
    PROCEDURE merge_tasks (
            p_request_id   IN NUMBER,
            p_set_number   IN NUMBER,
            p_process_mode IN VARCHAR2
    )
    IS
      TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
           RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
           INDEX BY BINARY_INTEGER;
      MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

      TYPE task_id_LIST_TYPE IS TABLE OF
             JTF_TASKS_B.task_id%TYPE
            INDEX BY BINARY_INTEGER;
      PRIMARY_KEY_ID_LIST task_id_LIST_TYPE;

      TYPE cust_account_id_LIST_TYPE IS TABLE OF
             JTF_TASKS_B.cust_account_id%TYPE
            INDEX BY BINARY_INTEGER;
      NUM_COL1_ORIG_LIST cust_account_id_LIST_TYPE;
      NUM_COL1_NEW_LIST cust_account_id_LIST_TYPE;

      CURSOR merged_records IS
            SELECT distinct CUSTOMER_MERGE_HEADER_ID
                  ,task_id
                  ,cust_account_id
             FROM JTF_TASKS_B yt, ra_customer_merges m
             WHERE (
                yt.cust_account_id = m.DUPLICATE_ID
             ) AND    m.process_flag = 'N'
             AND    m.request_id = p_request_id
             AND    m.set_number = p_set_number;
      l_last_fetch BOOLEAN := FALSE;
      l_count NUMBER := 0;
    BEGIN
      IF p_process_mode='LOCK' THEN
        NULL;
      ELSE
        ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
        ARP_MESSAGE.SET_TOKEN('TABLE_NAME','JTF_TASKS_B',FALSE);

        HZ_ACCT_MERGE_UTIL.load_set(p_set_number, p_request_id);

        open merged_records;
        LOOP
          FETCH merged_records BULK COLLECT INTO
                MERGE_HEADER_ID_LIST
              , PRIMARY_KEY_ID_LIST
              , NUM_COL1_ORIG_LIST
          LIMIT g_rows_fetched;

          IF merged_records%NOTFOUND THEN
             l_last_fetch := TRUE;
          END IF;

          IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
            exit;
          END IF;

          FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
             NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
          END LOOP;

          IF g_profile_val IS NOT NULL AND g_profile_val = 'Y' THEN

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
          ) VALUES (
             HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'JTF_TASKS_B',
             MERGE_HEADER_ID_LIST(I),
             PRIMARY_KEY_ID_LIST(I),
             NUM_COL1_ORIG_LIST(I),
             NUM_COL1_NEW_LIST(I),
             'U',
             p_request_id,
             hz_utility_pub.CREATED_BY,
             hz_utility_pub.CREATION_DATE,
             hz_utility_pub.LAST_UPDATE_LOGIN,
             hz_utility_pub.LAST_UPDATE_DATE,
             hz_utility_pub.LAST_UPDATED_BY
          );

        END IF;

        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
          UPDATE JTF_TASKS_B yt SET
                cust_account_id=NUM_COL1_NEW_LIST(I)
              , LAST_UPDATE_DATE=SYSDATE
              , last_updated_by=arp_standard.profile.user_id
              , last_update_login=arp_standard.profile.last_update_login
          WHERE task_id=PRIMARY_KEY_ID_LIST(I);

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
        arp_message.set_line( 'merge_tasks');
        RAISE;
    END merge_tasks;

    ----------------------------------------------------------------------
    -- merge_audits(): merge old_cust_account_id, new_cust_account_id
    --   in jtf_task_audits_b table.
    ----------------------------------------------------------------------
    PROCEDURE merge_audits (
            p_request_id      IN NUMBER,
            p_set_number      IN NUMBER,
            p_process_mode    IN VARCHAR2)
    IS

      TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
           RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
           INDEX BY BINARY_INTEGER;
      MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

      TYPE task_audit_id_LIST_TYPE IS TABLE OF
             JTF_TASK_AUDITS_B.task_audit_id%TYPE
            INDEX BY BINARY_INTEGER;
      PRIMARY_KEY_ID_LIST task_audit_id_LIST_TYPE;

      TYPE old_cust_account_id_LIST_TYPE IS TABLE OF
             JTF_TASK_AUDITS_B.old_cust_account_id%TYPE
            INDEX BY BINARY_INTEGER;
      NUM_COL1_ORIG_LIST old_cust_account_id_LIST_TYPE;
      NUM_COL1_NEW_LIST old_cust_account_id_LIST_TYPE;

      TYPE new_cust_account_id_LIST_TYPE IS TABLE OF
             JTF_TASK_AUDITS_B.new_cust_account_id%TYPE
            INDEX BY BINARY_INTEGER;
      NUM_COL2_ORIG_LIST new_cust_account_id_LIST_TYPE;
      NUM_COL2_NEW_LIST new_cust_account_id_LIST_TYPE;

      CURSOR merged_records IS
            SELECT distinct CUSTOMER_MERGE_HEADER_ID
                  ,task_audit_id
                  ,old_cust_account_id
                  ,new_cust_account_id
             FROM JTF_TASK_AUDITS_B yt, ra_customer_merges m
             WHERE (
                yt.old_cust_account_id = m.DUPLICATE_ID
                OR yt.new_cust_account_id = m.DUPLICATE_ID
             ) AND    m.process_flag = 'N'
             AND    m.request_id = p_request_id
             AND    m.set_number = p_set_number;
      l_last_fetch BOOLEAN := FALSE;
      l_count NUMBER := 0;
    BEGIN
      IF p_process_mode='LOCK' THEN
        NULL;
      ELSE
        ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
        ARP_MESSAGE.SET_TOKEN('TABLE_NAME','JTF_TASK_AUDITS_B',FALSE);

        HZ_ACCT_MERGE_UTIL.load_set(p_set_number, p_request_id);

        open merged_records;
        LOOP
          FETCH merged_records BULK COLLECT INTO
             MERGE_HEADER_ID_LIST
              , PRIMARY_KEY_ID_LIST
              , NUM_COL1_ORIG_LIST
              , NUM_COL2_ORIG_LIST
          LIMIT g_rows_fetched;

          IF merged_records%NOTFOUND THEN
             l_last_fetch := TRUE;
          END IF;

          IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
            exit;
          END IF;

          FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
             NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
             NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL2_ORIG_LIST(I));
          END LOOP;

          IF g_profile_val IS NOT NULL AND g_profile_val = 'Y' THEN

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
          ) VALUES (
             HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'JTF_TASK_AUDITS_B',
             MERGE_HEADER_ID_LIST(I),
             PRIMARY_KEY_ID_LIST(I),
             NUM_COL1_ORIG_LIST(I),
             NUM_COL1_NEW_LIST(I),
             NUM_COL2_ORIG_LIST(I),
             NUM_COL2_NEW_LIST(I),
             'U',
             p_request_id,
             hz_utility_pub.CREATED_BY,
             hz_utility_pub.CREATION_DATE,
             hz_utility_pub.LAST_UPDATE_LOGIN,
             hz_utility_pub.LAST_UPDATE_DATE,
             hz_utility_pub.LAST_UPDATED_BY
          );

        END IF;

        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
          UPDATE JTF_TASK_AUDITS_B yt SET
                old_cust_account_id=NUM_COL1_NEW_LIST(I)
              , new_cust_account_id=NUM_COL2_NEW_LIST(I)
              , LAST_UPDATE_DATE=SYSDATE
              , last_updated_by=arp_standard.profile.user_id
              , last_update_login=arp_standard.profile.last_update_login
          WHERE task_audit_id=PRIMARY_KEY_ID_LIST(I)
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
        arp_message.set_line( 'merge_audits');
        RAISE;
    END merge_audits;

    ----------------------------------------------------------------------
    -- merge_perz(): merge parameter_value in jtf_perz_query_param table.
    ----------------------------------------------------------------------
    PROCEDURE merge_perz (
            p_request_id     IN NUMBER,
            p_set_number     IN NUMBER,
            p_process_mode   IN VARCHAR2)
    IS

      TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
           RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
           INDEX BY BINARY_INTEGER;
      MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

      TYPE QUERY_PARAM_ID_LIST_TYPE IS TABLE OF
             JTF_PERZ_QUERY_PARAM.QUERY_PARAM_ID%TYPE
            INDEX BY BINARY_INTEGER;
      PRIMARY_KEY_ID1_LIST QUERY_PARAM_ID_LIST_TYPE;
      PRIMARY_KEY_ID2_LIST QUERY_PARAM_ID_LIST_TYPE;

      TYPE PARAMETER_VALUE_LIST_TYPE IS TABLE OF
             JTF_PERZ_QUERY_PARAM.PARAMETER_VALUE%TYPE
            INDEX BY BINARY_INTEGER;
      VCHAR_COL1_ORIG_LIST PARAMETER_VALUE_LIST_TYPE;
      VCHAR_COL1_NEW_LIST PARAMETER_VALUE_LIST_TYPE;
      VCHAR_CN_ORIG_LIST PARAMETER_VALUE_LIST_TYPE;
      VCHAR_CN_NEW_LIST PARAMETER_VALUE_LIST_TYPE;

      CURSOR merged_records IS
            SELECT distinct CUSTOMER_MERGE_HEADER_ID
                  ,yt.QUERY_PARAM_ID
                  ,yt.PARAMETER_VALUE
                  ,cn.QUERY_PARAM_ID
                  ,cn.PARAMETER_VALUE
             FROM JTF_PERZ_QUERY_PARAM yt
                , JTF_PERZ_QUERY_PARAM cn
                , ra_customer_merges m
             WHERE yt.PARAMETER_VALUE = to_char(m.DUPLICATE_ID)
             AND m.process_flag = 'N'
             AND m.request_id = p_request_id
             AND m.set_number = p_set_number
             AND cn.query_id = yt.query_id
             AND cn.parameter_name = 'CUSTOMER_NAME'
             AND yt.parameter_name = 'CUSTOMER_ID'
             AND yt.query_id IN (SELECT q.query_id
                                   FROM jtf_perz_query q,
                                        jtf_perz_query_param p
                                  WHERE q.query_type= 'JTF_TASK'
                                    AND q.application_id = 690
                                    AND p.query_id = q.query_id
                                    AND p.parameter_name = 'CUSTOMER'
                                    AND p.parameter_value = 'ACCOUNT');
      l_last_fetch BOOLEAN := FALSE;
      l_count NUMBER := 0;
    BEGIN
      IF p_process_mode='LOCK' THEN
        NULL;
      ELSE
        ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
        ARP_MESSAGE.SET_TOKEN('TABLE_NAME','JTF_PERZ_QUERY_PARAM',FALSE);

        HZ_ACCT_MERGE_UTIL.load_set(p_set_number, p_request_id);
        load_acct_number_set(p_set_number, p_request_id);

        open merged_records;
        LOOP
          FETCH merged_records BULK COLLECT INTO
             MERGE_HEADER_ID_LIST
              , PRIMARY_KEY_ID1_LIST
              , VCHAR_COL1_ORIG_LIST
              , PRIMARY_KEY_ID2_LIST
              , VCHAR_CN_ORIG_LIST
          LIMIT g_rows_fetched;

          IF merged_records%NOTFOUND THEN
             l_last_fetch := TRUE;
          END IF;

          IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
            exit;
          END IF;

          FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
             VCHAR_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(VCHAR_COL1_ORIG_LIST(I));
             VCHAR_CN_NEW_LIST(I)   := GETDUP_ACCOUNT_NUMBER(VCHAR_COL1_NEW_LIST(I));
          END LOOP;

          IF g_profile_val IS NOT NULL AND g_profile_val = 'Y' THEN
            FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
                 -- Log account id
                 INSERT INTO HZ_CUSTOMER_MERGE_LOG (
                   MERGE_LOG_ID,
                   TABLE_NAME,
                   MERGE_HEADER_ID,
                   PRIMARY_KEY_ID,
                   VCHAR_COL1_ORIG,
                   VCHAR_COL1_NEW,
                   ACTION_FLAG,
                   REQUEST_ID,
                   CREATED_BY,
                   CREATION_DATE,
                   LAST_UPDATE_LOGIN,
                   LAST_UPDATE_DATE,
                   LAST_UPDATED_BY
                 ) VALUES (
                 HZ_CUSTOMER_MERGE_LOG_s.nextval,
                 'JTF_PERZ_QUERY_PARAM',
                 MERGE_HEADER_ID_LIST(I),
                 PRIMARY_KEY_ID1_LIST(I),
                 VCHAR_COL1_ORIG_LIST(I),
                 VCHAR_COL1_NEW_LIST(I),
                 'U',
                 p_request_id,
                 hz_utility_pub.CREATED_BY,
                 hz_utility_pub.CREATION_DATE,
                 hz_utility_pub.LAST_UPDATE_LOGIN,
                 hz_utility_pub.LAST_UPDATE_DATE,
                 hz_utility_pub.LAST_UPDATED_BY
                 );

            FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
                 -- Log account number
                 INSERT INTO HZ_CUSTOMER_MERGE_LOG (
                   MERGE_LOG_ID,
                   TABLE_NAME,
                   MERGE_HEADER_ID,
                   PRIMARY_KEY_ID,
                   VCHAR_COL1_ORIG,
                   VCHAR_COL1_NEW,
                   ACTION_FLAG,
                   REQUEST_ID,
                   CREATED_BY,
                   CREATION_DATE,
                   LAST_UPDATE_LOGIN,
                   LAST_UPDATE_DATE,
                   LAST_UPDATED_BY
                 ) VALUES (
                 HZ_CUSTOMER_MERGE_LOG_s.nextval,
                 'JTF_PERZ_QUERY_PARAM',
                 MERGE_HEADER_ID_LIST(I),
                 PRIMARY_KEY_ID2_LIST(I),
                 VCHAR_CN_ORIG_LIST(I),
                 VCHAR_CN_NEW_LIST(I),
                 'U',
                 p_request_id,
                 hz_utility_pub.CREATED_BY,
                 hz_utility_pub.CREATION_DATE,
                 hz_utility_pub.LAST_UPDATE_LOGIN,
                 hz_utility_pub.LAST_UPDATE_DATE,
                 hz_utility_pub.LAST_UPDATED_BY
                 );
        END IF;

        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
            -- Update account id
            UPDATE JTF_PERZ_QUERY_PARAM yt SET
                  PARAMETER_VALUE=VCHAR_COL1_NEW_LIST(I)
                , LAST_UPDATE_DATE=SYSDATE
                , last_updated_by=arp_standard.profile.user_id
                , last_update_login=arp_standard.profile.last_update_login
            WHERE QUERY_PARAM_ID=PRIMARY_KEY_ID1_LIST(I);
            l_count := l_count + SQL%ROWCOUNT;

        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
            -- Update account number
            UPDATE JTF_PERZ_QUERY_PARAM yt SET
                  PARAMETER_VALUE=VCHAR_CN_NEW_LIST(I)
                , LAST_UPDATE_DATE=SYSDATE
                , last_updated_by=arp_standard.profile.user_id
                , last_update_login=arp_standard.profile.last_update_login
            WHERE QUERY_PARAM_ID=PRIMARY_KEY_ID2_LIST(I);
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
        arp_message.set_line( 'merge_perz');
        RAISE;
    END merge_perz;

    PROCEDURE Task_Account_Merge(
                    p_request_id     IN NUMBER,
                    p_set_number  IN NUMBER,
                    p_process_mode   IN VARCHAR2) Is

    BEGIN
        arp_message.set_line('CRM_MERGE.JTF_TASK_CUST_MERGE_PKG()+');

        g_profile_val := FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

        merge_tasks (p_request_id   => p_request_id,
                     p_set_number   => p_set_number,
                     p_process_mode => p_process_mode);

        merge_audits(p_request_id   => p_request_id,
                     p_set_number   => p_set_number,
                     p_process_mode => p_process_mode);

        merge_perz  (p_request_id   => p_request_id,
                     p_set_number   => p_set_number,
                     p_process_mode => p_process_mode);
    EXCEPTION
        WHEN OTHERS THEN
            arp_message.set_error (SQLCODE || SQLERRM);
            arp_message.set_error ('CRM_MERGE.JTF_TASK_CUST_MERGE_PKG()');
            RAISE;
    END Task_Account_Merge;

END JTF_TASK_CUST_MERGE_PKG;

/
