--------------------------------------------------------
--  DDL for Package Body IEX_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_MERGE_PVT" as
/* $Header: iexvmrgb.pls 120.3.12010000.3 2009/07/23 09:25:46 snuthala ship $ */

--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_Batch_Size  NUMBER := to_number(nvl(fnd_profile.value('IEX_BATCH_SIZE'), '1000'));
/*-------------------------------------------------------------
|
|  PROCEDURE
|      SCORE_HISTORY_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, IEX_SCORE_HISTORIES
|
|  NOTES:
|  ******* Please delete these lines after modifications *******
|   This account merge procedure was NOT generated using a perl script.
|
|  ******************************
|
|--------------------------------------------------------------*/

PROCEDURE SCORE_HISTORY_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE SCORE_HISTORY_ID_LIST_TYPE IS TABLE OF
         IEX_SCORE_HISTORIES.SCORE_HISTORY_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST SCORE_HISTORY_ID_LIST_TYPE;

  TYPE SCORE_OBJECT_ID_LIST_TYPE IS TABLE OF
         IEX_SCORE_HISTORIES.SCORE_OBJECT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST SCORE_OBJECT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST  SCORE_OBJECT_ID_LIST_TYPE;
  NUM_COL2_ORIG_LIST SCORE_OBJECT_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST  SCORE_OBJECT_ID_LIST_TYPE;
  NUM_COL3_ORIG_LIST SCORE_OBJECT_ID_LIST_TYPE;
  NUM_COL3_NEW_LIST  SCORE_OBJECT_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);

  CURSOR merged_records1 IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,SCORE_HISTORY_ID
              ,SCORE_OBJECT_ID
         FROM IEX_SCORE_HISTORIES yt, ra_customer_merges m
         WHERE yt.SCORE_OBJECT_ID = m.DUPLICATE_ID    AND
                m.process_flag = 'N'                  AND
                m.request_id = req_id                 AND
                m.set_number = set_num                AND
                yt.SCORE_OBJECT_CODE = 'IEX_ACCOUNT';

  CURSOR merged_records2 IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,SCORE_HISTORY_ID
              ,SCORE_OBJECT_ID
         FROM IEX_SCORE_HISTORIES yt, ra_customer_merges m
         WHERE yt.SCORE_OBJECT_ID = m.DUPLICATE_ADDRESS_ID AND
                m.process_flag = 'N'                  AND
                m.request_id = req_id                 AND
                m.set_number = set_num                AND
                yt.SCORE_OBJECT_CODE = 'IEX_ACCOUNT_SITE';

  CURSOR merged_records3 IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,SCORE_HISTORY_ID
              ,SCORE_OBJECT_ID
         FROM IEX_SCORE_HISTORIES yt, ra_customer_merges m
         WHERE yt.SCORE_OBJECT_ID = m.DUPLICATE_SITE_ID AND
                m.process_flag = 'N'                  AND
                m.request_id = req_id                 AND
                m.set_number = set_num                AND
                yt.SCORE_OBJECT_CODE = 'IEX_BILLTO';

  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN

  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
  IEX_DEBUG_PUB.logMessage('IEX_MERGE_PVT.SCORE_HISTORY_MERGE BEGIN');
  END IF;

  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','IEX_SCORE_HISTORIES',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    /* process IEX_SCORE_HISTORIES.SCORE_OBJECT_ID.OBJECT_CODE='IEX_ACCOUNT' */
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('IEX_SCORE_HISTORIES.SCORE_OBJECT_ID.OBJECT_CODE=IEX_ACCOUNT');
    END IF;
    open merged_records1;
    LOOP
      FETCH merged_records1 BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
      limit G_Batch_Size;
      IF merged_records1%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        goto iex_score_account_site;
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
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY) VALUES
        (HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'IEX_SCORE_HISTORIES',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         'IEX_ACCOUNT',
         'IEX_ACCOUNT',
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY);
      END IF;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('Merging ' || MERGE_HEADER_ID_LIST.COUNT || ' Records');
    END IF;
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE IEX_SCORE_HISTORIES yt SET
           SCORE_OBJECT_ID         = NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE       = SYSDATE
          , last_updated_by        = arp_standard.profile.user_id
          , last_update_login      = arp_standard.profile.last_update_login
          , REQUEST_ID             = req_id
          , PROGRAM_APPLICATION_ID = arp_standard.profile.program_application_id
          , PROGRAM_ID             = arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE    = SYSDATE
      WHERE SCORE_HISTORY_ID=PRIMARY_KEY_ID_LIST(I);
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         goto iex_score_account_site;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));

    <<iex_score_account_site>>
    /* process IEX_SCORE_HISTORIES.SCORE_OBJECT_ID where JTF_OBJECT_TYPE = 'IEX_ACCOUNT_SITE' */
    MERGE_HEADER_ID_LIST.delete;
    PRIMARY_KEY_ID_LIST.delete;
    l_count := 0;
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('IEX_SCORE_HISTORIES.SCORE_OBJECT_ID.OBJECT_CODE=IEX_ACCOUNT_SITE');
    END IF;
    open merged_records2;
    LOOP
      FETCH merged_records2 BULK COLLECT INTO
          MERGE_HEADER_ID_LIST
         ,PRIMARY_KEY_ID_LIST
         ,NUM_COL2_ORIG_LIST
      limit G_Batch_Size;
      IF merged_records2%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        goto iex_score_account_site_use;
      END IF;

      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL2_ORIG_LIST(I));
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
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY) VALUES
        (HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'IEX_SCORE_HISTORIES',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         'IEX_ACCOUNT_SITE',
         'IEX_ACCOUNT_SITE',
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY);
      END IF;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('Merging ' || MERGE_HEADER_ID_LIST.COUNT || ' Records');
    END IF;
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE IEX_SCORE_HISTORIES yt SET
            SCORE_OBJECT_ID        = NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE       = SYSDATE
          , last_updated_by        = arp_standard.profile.user_id
          , last_update_login      = arp_standard.profile.last_update_login
          , REQUEST_ID             = req_id
          , PROGRAM_APPLICATION_ID = arp_standard.profile.program_application_id
          , PROGRAM_ID             = arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE    = SYSDATE
      WHERE SCORE_HISTORY_ID=PRIMARY_KEY_ID_LIST(I);
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         goto iex_score_account_site_use;
      END IF;
    END LOOP;

    <<iex_score_account_site_use>>
    /* process IEX_SCORE_HISTORIES.SCORE_OBJECT_ID where JTF_OBJECT_TYPE = 'IEX_BILLTO' */
    MERGE_HEADER_ID_LIST.delete;
    PRIMARY_KEY_ID_LIST.delete;
    l_count := 0;
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('IEX_SCORE_HISTORIES.SCORE_OBJECT_ID.OBJECT_CODE=IEX_BILLTO');
    END IF;
    open merged_records3;
    LOOP
      FETCH merged_records1 BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL3_ORIG_LIST
      limit G_Batch_Size;
      IF merged_records3%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
         exit;
      END IF;

      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL3_ORIG_LIST(I));
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
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY) VALUES
        (HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'IEX_SCORE_HISTORIES',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL3_ORIG_LIST(I),
         NUM_COL3_NEW_LIST(I),
         'IEX_BILLTO',
         'IEX_BILLTO',
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY);
      END IF;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('Merging ' || MERGE_HEADER_ID_LIST.COUNT || ' Records');
    END IF;
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE IEX_SCORE_HISTORIES yt SET
            SCORE_OBJECT_ID        = NUM_COL3_NEW_LIST(I)
          , LAST_UPDATE_DATE       = SYSDATE
          , last_updated_by        = arp_standard.profile.user_id
          , last_update_login      = arp_standard.profile.last_update_login
          , REQUEST_ID             = req_id
          , PROGRAM_APPLICATION_ID = arp_standard.profile.program_application_id
          , PROGRAM_ID             = arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE    = SYSDATE
      WHERE SCORE_HISTORY_ID=PRIMARY_KEY_ID_LIST(I);
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
    arp_message.set_line('SCORE_HISTORY_MERGE');
    RAISE;
END SCORE_HISTORY_MERGE;

/*-------------------------------------------------------------
|
|  PROCEDURE
|      DUNNING_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, IEX_DUNNINGS
|
|  NOTES:
|  ******* Please delete these lines after modifications *******
|   This account merge procedure was NOT generated using a perl script.
|
|--------------------------------------------------------------*/
PROCEDURE DUNNING_MERGE (req_id       NUMBER,
                         set_num      NUMBER,
                         process_mode VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE DUNNING_ID_LIST_TYPE IS TABLE OF
         IEX_DUNNINGS.DUNNING_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST DUNNING_ID_LIST_TYPE;

  TYPE DUNNING_OBJECT_ID_LIST_TYPE IS TABLE OF
         IEX_DUNNINGS.DUNNING_OBJECT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST DUNNING_OBJECT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST  DUNNING_OBJECT_ID_LIST_TYPE;
  NUM_COL2_ORIG_LIST DUNNING_OBJECT_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST  DUNNING_OBJECT_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);

  /* this cursor is for IEX_DUNNINGS.OBJECT_ID column update if Object is IEX_ACCOUNT */
  CURSOR merged_records1 IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,DUNNING_ID
              ,DUNNING_OBJECT_ID
         FROM IEX_DUNNINGS yt, ra_customer_merges m
         WHERE yt.DUNNING_OBJECT_ID = m.DUPLICATE_ID AND
               m.process_flag = 'N'              AND
               m.request_id = req_id             AND
               m.set_number = set_num            AND
               yt.DUNNING_LEVEL = 'ACCOUNT';

  /* this cursor is for IEX_DUNNINGS.DUNNING_OBJECT_ID column update if Object is 'BILL_TO' */
  CURSOR merged_records2 IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,DUNNING_ID
              ,DUNNING_OBJECT_ID
         FROM IEX_DUNNINGS yt, ra_customer_merges m
         WHERE yt.DUNNING_OBJECT_ID = m.DUPLICATE_SITE_ID AND
               m.process_flag = 'N' AND
               m.request_id = req_id AND
               m.set_number = set_num AND
               yt.object_type = 'BILL_TO';

  l_last_fetch BOOLEAN := FALSE;
  l_count      NUMBER;

BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('IEX_MERGE_PVT.DUNNING_MERGE BEGIN');
    END IF;

    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','IEX_DUNNING',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val := FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    /* process IEX_STRATEGIES.CUST_ACCOUNT_ID */
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('IEX_DUNNING.DUNNING_OBJECT_ID');
    END IF;
    open merged_records1;
    LOOP
      FETCH merged_records1 BULK COLLECT INTO
            MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
      limit G_Batch_Size;

      IF merged_records1%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
         goto iex_account;
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
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY)
       VALUES
       (HZ_CUSTOMER_MERGE_LOG_s.nextval,
        'IEX_DUNNINGS',
        MERGE_HEADER_ID_LIST(I),
        PRIMARY_KEY_ID_LIST(I),
        NUM_COL1_ORIG_LIST(I),
        NUM_COL1_NEW_LIST(I),
        'ACCOUNT',
        'ACCOUNT',
        'U',
        req_id,
        hz_utility_pub.CREATED_BY,
        hz_utility_pub.CREATION_DATE,
        hz_utility_pub.LAST_UPDATE_LOGIN,
        hz_utility_pub.LAST_UPDATE_DATE,
        hz_utility_pub.LAST_UPDATED_BY);
      END IF;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('Merging ' || MERGE_HEADER_ID_LIST.COUNT || ' Records');
    END IF;
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE IEX_DUNNINGS yt SET
           DUNNING_OBJECT_ID       = NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE       = SYSDATE
          , last_updated_by        = arp_standard.profile.user_id
          , last_update_login      = arp_standard.profile.last_update_login
          , REQUEST_ID             = req_id
          , PROGRAM_APPLICATION_ID = arp_standard.profile.program_application_id
          , PROGRAM_ID             = arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE    = SYSDATE
      WHERE DUNNING_OBJECT_ID=PRIMARY_KEY_ID_LIST(I);
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         goto iex_account;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));

    <<iex_account>>
    /* process IEX_DUNNINGS.DUNNING_OBJECT_ID where DUNNING_LEVEL = 'BILLTO' */
    MERGE_HEADER_ID_LIST.delete;
    PRIMARY_KEY_ID_LIST.delete;
    l_count := 0;
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('IEX_DUNNINGS.DUNNING_OBJECT_ID.TYPE=ACCOUNT');
    END IF;
    open merged_records2;
    LOOP
      FETCH merged_records2 BULK COLLECT INTO
            MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL2_ORIG_LIST
      limit G_Batch_Size;

      IF merged_records2%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        EXIT;
      END IF;

      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         --NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL2_ORIG_LIST(I));
	     NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I)); -- 5874874 gnramasa 25-Apr-2007
	  END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID,
           NUM_COL2_ORIG,
           NUM_COL2_NEW,
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY)
         VALUES
         (HZ_CUSTOMER_MERGE_LOG_s.nextval,
          'IEX_DUNNINGS',
          MERGE_HEADER_ID_LIST(I),
          PRIMARY_KEY_ID_LIST(I),
          NUM_COL2_ORIG_LIST(I),
          NUM_COL2_NEW_LIST(I),
          'BILL_TO',
          'BILL_TO',
          'U',
          req_id,
          hz_utility_pub.CREATED_BY,
          hz_utility_pub.CREATION_DATE,
          hz_utility_pub.LAST_UPDATE_LOGIN,
          hz_utility_pub.LAST_UPDATE_DATE,
          hz_utility_pub.LAST_UPDATED_BY);
      END IF;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('Merging ' || MERGE_HEADER_ID_LIST.COUNT || ' Records');
    END IF;
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE IEX_DUNNINGS yt SET
           DUNNING_OBJECT_ID       = NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE       = SYSDATE
          , last_updated_by        = arp_standard.profile.user_id
          , last_update_login      = arp_standard.profile.last_update_login
          , REQUEST_ID             = req_id
          , PROGRAM_APPLICATION_ID = arp_standard.profile.program_application_id
          , PROGRAM_ID             = arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE    = SYSDATE
      WHERE DUNNING_ID=PRIMARY_KEY_ID_LIST(I);
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
        EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('IEX_MERGE_PVT.DUNNNING_MERGE END');
    END IF;

  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'DUNNNING_MERGE');
    RAISE;
END DUNNING_MERGE;

/*-------------------------------------------------------------
|
|  PROCEDURE
|      STRATEGY_MERGE
|  DESCRIPTION :
|      Account merge procedure for the table, IEX_STRATEGIES
|
|  NOTES:
|  ******* Please delete these lines after modifications *******
|   This account merge procedure was NOT generated using a perl script.
|
|--------------------------------------------------------------*/
PROCEDURE STRATEGY_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE STRATEGY_ID_LIST_TYPE IS TABLE OF
         IEX_STRATEGIES.STRATEGY_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST STRATEGY_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
         IEX_STRATEGIES.CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST  CUST_ACCOUNT_ID_LIST_TYPE;

  TYPE JTF_OBJECT_ID_LIST_TYPE IS TABLE OF
         IEX_STRATEGIES.JTF_OBJECT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST JTF_OBJECT_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST  JTF_OBJECT_ID_LIST_TYPE;
  NUM_COL3_ORIG_LIST JTF_OBJECT_ID_LIST_TYPE;
  NUM_COL3_NEW_LIST  JTF_OBJECT_ID_LIST_TYPE;


--Added for bug#6974531 by schekuri on 14-Aug-2008
  TYPE STATUS_CODE_LIST_TYPE IS TABLE OF
         IEX_STRATEGIES.STATUS_CODE%TYPE
        INDEX BY BINARY_INTEGER;
  STATUS_CODE_LIST STATUS_CODE_LIST_TYPE;
  TYPE PARTY_ID_LIST_TYPE IS TABLE OF
         IEX_STRATEGIES.PARTY_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PARTY_ID_LIST PARTY_ID_LIST_TYPE;


  l_profile_val VARCHAR2(30);

  /* this cursor is for IEX_STRATEGIES.CUST_ACCOUNT_ID column update */
  CURSOR merged_records1 IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,yt.STRATEGY_ID
              ,yt.CUST_ACCOUNT_ID
	      ,hca.party_id
	      ,yt.status_code  --Added for bug#6974531 by schekuri on 14-Aug-2008
         FROM IEX_STRATEGIES yt, ra_customer_merges m, hz_cust_accounts hca
         WHERE yt.CUST_ACCOUNT_ID = m.DUPLICATE_ID AND
	       hca.cust_account_id = m.customer_id AND
               m.process_flag = 'N'                AND
               m.request_id = req_id               AND
               m.set_number = set_num;


  /* this cursor is for IEX_STRATEGIES.JTF_OBJECT_ID column update if Object is IEX_ACCOUNT */
  CURSOR merged_records2 IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,STRATEGY_ID
              ,JTF_OBJECT_ID
	      ,yt.status_code  --Added for bug#6974531 by schekuri on 14-Aug-2008
         FROM IEX_STRATEGIES yt, ra_customer_merges m
         WHERE yt.JTF_OBJECT_ID = m.DUPLICATE_ID AND
               m.process_flag = 'N'              AND
               m.request_id = req_id             AND
               m.set_number = set_num            AND
               yt.jtf_object_type = 'IEX_ACCOUNT';

  /* this cursor is for IEX_STRATEGIES.JTF_OBJECT_ID column update if Object is IEX_BILLTO */
  CURSOR merged_records3 IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,STRATEGY_ID
              ,JTF_OBJECT_ID
	      ,yt.status_code --Added for bug#6974531 by schekuri on 14-Aug-2008
         FROM IEX_STRATEGIES yt, ra_customer_merges m
         WHERE yt.JTF_OBJECT_ID = m.DUPLICATE_SITE_ID AND
               m.process_flag = 'N' AND
               m.request_id = req_id AND
               m.set_number = set_num AND
               yt.jtf_object_type = 'IEX_BILLTO';

  l_last_fetch BOOLEAN := FALSE;
  l_count      NUMBER;

BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('IEX_MERGE_PVT.STRATEGY_MERGE BEGIN');
    END IF;

    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','IEX_STRATEGIES',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val := FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    /* process IEX_STRATEGIES.CUST_ACCOUNT_ID */
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('IEX_STRATEGIES.CUST_ACCOUNT_ID');
    END IF;
    open merged_records1;
    LOOP
      FETCH merged_records1 BULK COLLECT INTO
            MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
	  , PARTY_ID_LIST
	  , STATUS_CODE_LIST  --Added for bug#6974531 by schekuri on 14-Aug-2008
      limit G_Batch_Size;

      IF merged_records1%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
         goto iex_account;
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
           LAST_UPDATED_BY)
       VALUES
       (HZ_CUSTOMER_MERGE_LOG_s.nextval,
        'IEX_STRATEGIES',
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
        hz_utility_pub.LAST_UPDATED_BY);
      END IF;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('Merging ' || MERGE_HEADER_ID_LIST.COUNT || ' Records');
    END IF;
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE IEX_STRATEGIES yt SET
           CUST_ACCOUNT_ID         = NUM_COL1_NEW_LIST(I)
	  , PARTY_ID = PARTY_ID_LIST(I)
          , LAST_UPDATE_DATE       = SYSDATE
          , last_updated_by        = arp_standard.profile.user_id
          , last_update_login      = arp_standard.profile.last_update_login
          , REQUEST_ID             = req_id
          , PROGRAM_APPLICATION_ID = arp_standard.profile.program_application_id
          , PROGRAM_ID             = arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE    = SYSDATE
      WHERE STRATEGY_ID=PRIMARY_KEY_ID_LIST(I);
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         goto iex_account;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));

    <<iex_account>>
    /* process IEX_STRATEGIES.JTF_OBJECT_ID where JTF_OBJECT_TYPE = 'IEX_ACCOUNT' */
    MERGE_HEADER_ID_LIST.delete;
    PRIMARY_KEY_ID_LIST.delete;
    PARTY_ID_LIST.delete;
    STATUS_CODE_LIST.delete;    --Added for bug#6974531 by schekuri on 14-Aug-2008
    l_count := 0;
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('IEX_STRATEGIES.JTF_OBJECT_ID.TYPE=IEX_ACCOUNT');
    END IF;
    open merged_records2;
    LOOP
      FETCH merged_records2 BULK COLLECT INTO
            MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL2_ORIG_LIST
	  , STATUS_CODE_LIST  --Added for bug#6974531 by schekuri on 14-Aug-2008
      limit G_Batch_Size;

      IF merged_records2%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        goto iex_billto;
      END IF;

      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL2_ORIG_LIST(I));
	  END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID,
           NUM_COL2_ORIG,
           NUM_COL2_NEW,
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY)
         VALUES
         (HZ_CUSTOMER_MERGE_LOG_s.nextval,
          'IEX_STRATEGIES',
          MERGE_HEADER_ID_LIST(I),
          PRIMARY_KEY_ID_LIST(I),
          NUM_COL2_ORIG_LIST(I),
          NUM_COL2_NEW_LIST(I),
          'IEX_ACCOUNT',
          'IEX_ACCOUNT',
          'U',
          req_id,
          hz_utility_pub.CREATED_BY,
          hz_utility_pub.CREATION_DATE,
          hz_utility_pub.LAST_UPDATE_LOGIN,
          hz_utility_pub.LAST_UPDATE_DATE,
          hz_utility_pub.LAST_UPDATED_BY);
      END IF;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('Merging ' || MERGE_HEADER_ID_LIST.COUNT || ' Records');
    END IF;
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE IEX_STRATEGIES yt SET
          JTF_OBJECT_ID            = NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE       = SYSDATE
          , last_updated_by        = arp_standard.profile.user_id
          , last_update_login      = arp_standard.profile.last_update_login
          , REQUEST_ID             = req_id
          , PROGRAM_APPLICATION_ID = arp_standard.profile.program_application_id
          , PROGRAM_ID             = arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE    = SYSDATE
      WHERE STRATEGY_ID=PRIMARY_KEY_ID_LIST(I);
      l_count := l_count + SQL%ROWCOUNT;
      -- Begin Bug #6652858 bibeura 11-Dec-2007
      for I in MERGE_HEADER_ID_LIST.first..MERGE_HEADER_ID_LIST.last loop
       --Added filter for bug#8663669 by snuthala on 23-07-2009 to cancel only open and onhold strategies
      IF STATUS_CODE_LIST(I) in ('OPEN','ONHOLD') then
      IEX_STRATEGY_WF.SEND_SIGNAL(process     => 'IEXSTRY',
                  strategy_id => PRIMARY_KEY_ID_LIST(I),
                  status      => 'CANCELLED' ) ;
	end if;
      end loop;
      -- End Bug #6652858 bibeura 11-Dec-2007
      IF l_last_fetch THEN
        goto iex_billto;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));

    <<iex_billto>>

    /* process IEX_STRATEGIES.JTF_OBJECT_ID where JTF_OBJECT_TYPE = 'IEX_BILLTO' */
    MERGE_HEADER_ID_LIST.delete;
    PRIMARY_KEY_ID_LIST.delete;
    STATUS_CODE_LIST.delete;    --Added for bug#6974531 by schekuri on 14-Aug-2008
    l_count := 0;
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('IEX_STRATEGIES.JTF_OBJECT_ID.TYPE=IEX_BILLTO');
    END IF;
    open merged_records3;
    LOOP
      FETCH merged_records3 BULK COLLECT INTO
            MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL3_ORIG_LIST
	  , STATUS_CODE_LIST  --Added for bug#6974531 by schekuri on 14-Aug-2008
      limit G_Batch_Size;

      IF merged_records3%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;

      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL3_ORIG_LIST(I));
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID,
           NUM_COL2_ORIG,
           NUM_COL2_NEW,
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY)
        VALUES (
         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'IEX_STRATEGIES',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL3_ORIG_LIST(I),
         NUM_COL3_NEW_LIST(I),
         'IEX_BILLTO',
         'IEX_BILLTO',
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY);
      END IF;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('Merging ' || MERGE_HEADER_ID_LIST.COUNT || ' Records');
    END IF;
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE IEX_STRATEGIES yt SET
--           CUST_ACCOUNT_ID         = NUM_COL3_NEW_LIST(I) Updated for bug#6974531 by schekuri on 14-Aug-2008
            JTF_OBJECT_ID = NUM_COL3_NEW_LIST(I)
	  , CUSTOMER_SITE_USE_ID = NUM_COL3_NEW_LIST(I)
          , LAST_UPDATE_DATE       = SYSDATE
          , last_updated_by        = arp_standard.profile.user_id
          , last_update_login      = arp_standard.profile.last_update_login
          , REQUEST_ID             = req_id
          , PROGRAM_APPLICATION_ID = arp_standard.profile.program_application_id
          , PROGRAM_ID             = arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE    = SYSDATE
      WHERE STRATEGY_ID        =  PRIMARY_KEY_ID_LIST(I);
      l_count := l_count + SQL%ROWCOUNT;
      -- Begin Bug #6652858 bibeura 11-Dec-2007
      for I in MERGE_HEADER_ID_LIST.first..MERGE_HEADER_ID_LIST.last loop
       --Added filter for bug#6974531 by schekuri on 14-Aug-2008 to cancel only open and onhold strategies
      IF STATUS_CODE_LIST(I) in ('OPEN','ONHOLD') then
	IEX_STRATEGY_WF.SEND_SIGNAL(process     => 'IEXSTRY',
                  strategy_id => PRIMARY_KEY_ID_LIST(I),
                  status      => 'CANCELLED' ) ;
      end if;
      end loop;
      -- End Bug #6652858 bibeura 11-Dec-2007
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('IEX_MERGE_PVT.STRATEGY_MERGE END');
    END IF;

  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'STRATEGY_MERGE');
    RAISE;
END STRATEGY_MERGE;


PROCEDURE PROMISE_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE PROMISE_DETAIL_ID_LIST_TYPE IS TABLE OF
         IEX_PROMISE_DETAILS.PROMISE_DETAIL_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST PROMISE_DETAIL_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
         IEX_PROMISE_DETAILS.CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,PROMISE_DETAIL_ID
              ,CUST_ACCOUNT_ID
         FROM IEX_PROMISE_DETAILS yt, ra_customer_merges m
         WHERE yt.CUST_ACCOUNT_ID = m.DUPLICATE_ID AND
                m.process_flag = 'N' AND
                m.request_id = req_id AND
                m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','IEX_PROMISE_DETAILS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
      limit G_Batch_Size;

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
           LAST_UPDATED_BY)
      VALUES
      (HZ_CUSTOMER_MERGE_LOG_s.nextval,
       'IEX_PROMISE_DETAILS',
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
       hz_utility_pub.LAST_UPDATED_BY);

      END IF;
    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE IEX_PROMISE_DETAILS yt SET
           CUST_ACCOUNT_ID         = NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE       = SYSDATE
          , last_updated_by        = arp_standard.profile.user_id
          , last_update_login      = arp_standard.profile.last_update_login
          , REQUEST_ID             = req_id
          , PROGRAM_APPLICATION_ID = arp_standard.profile.program_application_id
          , PROGRAM_ID             = arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE    = SYSDATE
      WHERE PROMISE_DETAIL_ID=PRIMARY_KEY_ID_LIST(I);
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
    arp_message.set_line( 'PROMISE_MERGE');
    RAISE;
END PROMISE_MERGE;

PROCEDURE DELINQUENCY_MERGE (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE DELINQUENCY_ID_LIST_TYPE IS TABLE OF
         IEX_DELINQUENCIES_ALL.DELINQUENCY_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST DELINQUENCY_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
         IEX_DELINQUENCIES_ALL.CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  TYPE CUSTOMER_SITE_USE_ID_LIST_TYPE IS TABLE OF
         IEX_DELINQUENCIES_ALL.CUSTOMER_SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  TYPE PARTY_ID_LIST_TYPE IS TABLE OF
         IEX_DELINQUENCIES_ALL.PARTY_CUST_ID%TYPE
        INDEX BY BINARY_INTEGER;

  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL2_ORIG_LIST CUSTOMER_SITE_USE_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST CUSTOMER_SITE_USE_ID_LIST_TYPE;
  PARTY_LIST PARTY_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);

 /* CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,DELINQUENCY_ID
              ,CUST_ACCOUNT_ID
         FROM IEX_DELINQUENCIES yt, ra_customer_merges m
         WHERE yt.CUST_ACCOUNT_ID = m.DUPLICATE_ID AND
                m.process_flag = 'N' AND
                m.request_id = req_id AND
                m.set_number = set_num;

  CURSOR merged_records1 IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,DELINQUENCY_ID
              ,CUSTOMER_SITE_USE_ID
         FROM IEX_DELINQUENCIES yt, ra_customer_merges m
         WHERE yt.CUSTOMER_SITE_USE_ID = m.DUPLICATE_ID AND
                m.process_flag = 'N' AND
                m.request_id = req_id AND
                m.set_number = set_num;
 */
 CURSOR merged_records IS
        SELECT distinct m.CUSTOMER_MERGE_HEADER_ID
              ,yt.DELINQUENCY_ID
              ,yt.CUST_ACCOUNT_ID
              ,c.party_id
         FROM IEX_DELINQUENCIES_ALL yt, ra_customer_merges m, hz_cust_accounts c
         WHERE yt.CUST_ACCOUNT_ID = m.DUPLICATE_ID AND
                m.process_flag = 'N' AND
                m.request_id = req_id AND
                m.set_number = set_num and
                m.customer_id = c.cust_account_id;

  CURSOR merged_records1 IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,DELINQUENCY_ID
              ,CUSTOMER_SITE_USE_ID
         FROM IEX_DELINQUENCIES_ALL yt, ra_customer_merges m
         WHERE yt.CUSTOMER_SITE_USE_ID = m.DUPLICATE_SITE_ID AND
                m.process_flag = 'N' AND
                m.request_id = req_id AND
                m.set_number = set_num;

  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN

  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('IEX_MERGE_PVT.DELINQUENCY_MERGE BEGIN');
    IEX_DEBUG_PUB.logMessage('Input parameters:');
    IEX_DEBUG_PUB.logMessage('req_id = ' || req_id);
    IEX_DEBUG_PUB.logMessage('set_num = ' || set_num);
    IEX_DEBUG_PUB.logMessage('process_mode = ' || process_mode);
  END IF;

  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','IEX_DELINQUENCIES',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage('l_profile_val = ' || l_profile_val);
    END IF;

    l_count := 0;
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage('Searching for ACCOUNT records...');
    END IF;

    /* merging cust_account_id */
    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , PARTY_LIST
      limit G_Batch_Size;

      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage('Fetched ' || MERGE_HEADER_ID_LIST.COUNT || ' records');
      END IF;

      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.logMessage('Exiting fetch');
         END IF;
	goto iex_delinquency_acc_site_use;
      END IF;

      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
      END LOOP;

      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.logMessage('Inserting into HZ_CUSTOMER_MERGE_LOG...');
        END IF;
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
           LAST_UPDATED_BY)
        VALUES
        (HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'IEX_DELINQUENCIES_ALL',
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
         hz_utility_pub.LAST_UPDATED_BY);

	 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.logMessage('...done');
        END IF;

      END IF;
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage('Updating IEX_DELINQUENCIES_ALL...');
    END IF;

    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE IEX_DELINQUENCIES_ALL yt SET
           CUST_ACCOUNT_ID         = NUM_COL1_NEW_LIST(I)
          , PARTY_CUST_ID          = PARTY_LIST(I)
          , LAST_UPDATE_DATE       = SYSDATE
          , last_updated_by        = arp_standard.profile.user_id
          , last_update_login      = arp_standard.profile.last_update_login
          , REQUEST_ID             = req_id
          , PROGRAM_APPLICATION_ID = arp_standard.profile.program_application_id
          , PROGRAM_ID             = arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE    = SYSDATE
      WHERE DELINQUENCY_ID=PRIMARY_KEY_ID_LIST(I);
      l_count := l_count + SQL%ROWCOUNT;
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.logMessage('...done');
      END IF;

      IF l_last_fetch THEN
         goto iex_delinquency_acc_site_use;
      END IF;
    END LOOP;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage('Total processed ' || l_count || ' ACCOUNT  records');
    END IF;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));

    <<iex_delinquency_acc_site_use>>
    /* merging CUSTOMER_SITE_USE_ID */

    MERGE_HEADER_ID_LIST.delete;
    PRIMARY_KEY_ID_LIST.delete;
    l_count := 0;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage('Searching for CUSTOMER_SITE_USE_ID  records...');
    END IF;

    open merged_records1;
    LOOP
      FETCH merged_records1 BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL2_ORIG_LIST
      limit G_Batch_Size;

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage('Fetched ' || MERGE_HEADER_ID_LIST.COUNT || ' records');
      END IF;

      IF merged_records1%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.logMessage('Exiting fetch');
        END IF;
	exit;
      END IF;

      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         --NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL2_ORIG_LIST(I));
           NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
      END LOOP;

      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN

	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.logMessage('Inserting into HZ_CUSTOMER_MERGE_LOG...');
        END IF;

	FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID,
           NUM_COL2_ORIG,
           NUM_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY)
        VALUES
        (HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'IEX_DELINQUENCIES_ALL',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         NUM_COL2_ORIG_LIST(I),
         NUM_COL2_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY);

	 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.logMessage('...done');
        END IF;

      END IF;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage('Updating IEX_DELINQUENCIES_ALL...');
    END IF;

    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE IEX_DELINQUENCIES_ALL yt SET
           CUSTOMER_SITE_USE_ID    = NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE       = SYSDATE
          , last_updated_by        = arp_standard.profile.user_id
          , last_update_login      = arp_standard.profile.last_update_login
          , REQUEST_ID             = req_id
          , PROGRAM_APPLICATION_ID = arp_standard.profile.program_application_id
          , PROGRAM_ID             = arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE    = SYSDATE
      WHERE DELINQUENCY_ID=PRIMARY_KEY_ID_LIST(I);
      l_count := l_count + SQL%ROWCOUNT;
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.logMessage('...done');
        END IF;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.logMessage('Total processed ' || l_count || ' CUSTOMER_SITE_USE_ID records');
    END IF;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.logMessage('IEX_MERGE_PVT.DELINQUENCY_MERGE END');
    END IF;

  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.logMessage('In IEX_MERGE_PVT.DELINQUENCY_MERGE exception');
    END IF;
    arp_message.set_line('DELINQUENCY_MERGE');
    RAISE;
END DELINQUENCY_MERGE;

PROCEDURE MERGE_DELINQUENCY_PARTIES(p_entity_name    IN VARCHAR2,
                                    p_from_id        IN NUMBER,
                                    p_to_id          IN OUT NOCOPY NUMBER,
                                    p_from_fk_id     IN NUMBER,
                                    p_to_fk_id       IN NUMBER,
                                    p_parent_entity  IN VARCHAR2,
                                    p_batch_id       IN NUMBER,
                                    p_batch_party_id IN NUMBER,
                                    x_return_status  OUT NOCOPY VARCHAR2)
IS

v_merged_to_id NUMBER;
l_num_records  NUMBER;
l_merge_reason VARCHAR2(25);

-- Begin - 10/12/2005 - Andre Araujo - Add exception handling
e_NullParameters EXCEPTION;
-- End - 10/12/2005 - Andre Araujo - Add exception handling

BEGIN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LOGMESSAGE('MERGE_DELINQUENCY_PARTIES: Begin');
        IEX_DEBUG_PUB.LOGMESSAGE('MERGE_DELINQUENCY_PARTIES: p_from_id: ' || p_from_id );
        IEX_DEBUG_PUB.LOGMESSAGE('MERGE_DELINQUENCY_PARTIES: p_to_id: ' || p_to_id );
        IEX_DEBUG_PUB.LOGMESSAGE('MERGE_DELINQUENCY_PARTIES: p_from_fk_id: ' || p_from_fk_id );
        IEX_DEBUG_PUB.LOGMESSAGE('MERGE_DELINQUENCY_PARTIES: p_to_fk_id: ' || p_to_fk_id );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

/* 1. Do all Validations */

    /* Check the Merge reason. If Merge Reason is Duplicate Record then no validation is performed.
      Otherwise check if the resource is being used somewhere
     */
    SELECT merge_reason_code into l_merge_reason
    FROM hz_merge_batch
    WHERE batch_id = p_batch_id;

    IF l_merge_reason = 'DUPLICATE' THEN
       NULL;
    ELSE
       NULL;

    -- Begin - 10/12/2005 - Andre Araujo - Check if we received all the required parameters
    IF p_from_FK_id is null or p_to_fk_id is null THEN
        raise e_NullParameters;
    END IF;
    -- End - 10/12/2005 - Andre Araujo - Check if we received all the required parameters

    /* Check if the delinquency is being used some where. If so, do not allow  Merge */
    /*
      SELECT count(1) INTO l_num_records
      FROM IEX_DELINQUENCIES_ALL
      WHERE delinquency_id = p_from_id;
      IF l_num_records >= 1 THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('JTF','JTF_MERGE_NOTALLOWED');
		FND_MSG_PUB.ADD;
        RETURN;
      END IF;
    */
    END IF;


/* 2. Perform the Merge Operation. */

    /* If the Parent has NOT changed(i.e. Parent getting transferred)
    then nothing needs to be done. Set Merged To Id is same as Merged From Id
    and return
    */
    IF p_from_FK_id = p_to_FK_id  THEN
        p_to_id := p_from_id;
        RETURN;
    END IF;

    /* If the Parent has changed(i.e. Parent is getting merged),
       then transfer the dependent record to the new parent.
       Before transferring check if a similar dependent record exists on the new parent.
       If a duplicate exists then do not transfer and return the id of the duplicate record as the Merged To Id.
    */

    /* begin raverma 07242001
     */
    -- do we really care if something is being "merged" or transferred?? i think not
    -- lets just update the table to reflect the new party_id
        UPDATE IEX_DELINQUENCIES_ALL
           SET party_cust_id          = p_To_FK_id,
               last_update_date       = HZ_UTILITY_V2PUB.last_update_date,
               last_updated_by        = HZ_UTILITY_V2PUB.user_id,
               last_update_login      = HZ_UTILITY_V2PUB.last_update_login,
               request_id             = HZ_UTILITY_V2PUB.request_id,
               program_application_id = HZ_UTILITY_V2PUB.program_application_id,
               program_id             = HZ_UTILITY_V2PUB.program_id,
               program_update_date    = sysdate
        WHERE party_cust_id = p_from_fk_id;

        -- begin raverma 10232001       -- add this to update promise table
        UPDATE IEX_PROMISE_DETAILS
           SET Promise_Made_By        = p_To_FK_ID,
               last_update_date       = HZ_UTILITY_V2PUB.last_update_date,
               last_updated_by        = HZ_UTILITY_V2PUB.user_id,
               last_update_login      = HZ_UTILITY_V2PUB.last_update_login,
               request_id             = HZ_UTILITY_V2PUB.request_id,
               program_application_id = HZ_UTILITY_V2PUB.program_application_id,
               program_id             = HZ_UTILITY_V2PUB.program_id,
               program_update_date    = sysdate
        WHERE promise_made_by = p_from_fk_id;

        /* Begin raverma 02032003 add new party_merge entities
        IEX_REPOSSESIONS
        iex_del_third_parties
        iex_case_contacts
        iex_cases_all_b
        iex_writeoffs
        iex_bankruptcies
        iex_litigations
        -- 02182002 add IEX_SCORE_HISTORIES
                        IEX_STRATEGIES
        */
        UPDATE IEX_STRATEGIES
           SET JTF_OBJECT_ID = p_To_FK_ID,
               last_update_date       = HZ_UTILITY_V2PUB.last_update_date,
               last_updated_by        = HZ_UTILITY_V2PUB.user_id,
               last_update_login      = HZ_UTILITY_V2PUB.last_update_login,
               request_id             = HZ_UTILITY_V2PUB.request_id,
               program_application_id = HZ_UTILITY_V2PUB.program_application_id,
               program_id             = HZ_UTILITY_V2PUB.program_id,
               program_update_date    = sysdate,
               -- Begin - 10/12/2005 - Andre Araujo - Need to update party_id also
               PARTY_ID               = p_To_FK_ID
               -- End - 10/12/2005 - Andre Araujo - Need to update party_id also
        WHERE JTF_OBJECT_ID = p_from_fk_id AND
              JTF_OBJECT_TYPE = 'PARTY';

        -- Begin - 10/12/2005 - Andre Araujo - Need to update party_id also
        UPDATE IEX_STRATEGIES
           SET last_update_date       = HZ_UTILITY_V2PUB.last_update_date,
               last_updated_by        = HZ_UTILITY_V2PUB.user_id,
               last_update_login      = HZ_UTILITY_V2PUB.last_update_login,
               request_id             = HZ_UTILITY_V2PUB.request_id,
               program_application_id = HZ_UTILITY_V2PUB.program_application_id,
               program_id             = HZ_UTILITY_V2PUB.program_id,
               program_update_date    = sysdate,
               PARTY_ID               = p_To_FK_ID
        WHERE PARTY_ID = p_from_fk_id;
        -- End - 10/12/2005 - Andre Araujo - Need to update party_id also


        UPDATE IEX_SCORE_HISTORIES
           SET SCORE_OBJECT_ID = p_To_FK_ID,
               last_update_date       = HZ_UTILITY_V2PUB.last_update_date,
               last_updated_by        = HZ_UTILITY_V2PUB.user_id,
               last_update_login      = HZ_UTILITY_V2PUB.last_update_login,
               request_id             = HZ_UTILITY_V2PUB.request_id,
               program_application_id = HZ_UTILITY_V2PUB.program_application_id,
               program_id             = HZ_UTILITY_V2PUB.program_id,
               program_update_date    = sysdate
        WHERE SCORE_OBJECT_ID = p_from_fk_id AND
              SCORE_OBJECT_CODE = 'PARTY';

        UPDATE IEX_REPOSSESSIONS
           SET PARTY_ID               = p_To_FK_ID,
               last_update_date       = HZ_UTILITY_V2PUB.last_update_date,
               last_updated_by        = HZ_UTILITY_V2PUB.user_id,
               last_update_login      = HZ_UTILITY_V2PUB.last_update_login,
               request_id             = HZ_UTILITY_V2PUB.request_id,
               program_application_id = HZ_UTILITY_V2PUB.program_application_id,
               program_id             = HZ_UTILITY_V2PUB.program_id,
               program_update_date    = sysdate
        WHERE PARTY_ID = p_from_fk_id;

        UPDATE IEX_REPOSSESSIONS
           SET REPLEVIN_ATTORNEY      = p_To_FK_ID,
               last_update_date       = HZ_UTILITY_V2PUB.last_update_date,
               last_updated_by        = HZ_UTILITY_V2PUB.user_id,
               last_update_login      = HZ_UTILITY_V2PUB.last_update_login,
               request_id             = HZ_UTILITY_V2PUB.request_id,
               program_application_id = HZ_UTILITY_V2PUB.program_application_id,
               program_id             = HZ_UTILITY_V2PUB.program_id,
               program_update_date    = sysdate
        WHERE REPLEVIN_ATTORNEY = p_from_fk_id;

        UPDATE IEX_DEL_THIRD_PARTIES
           SET THIRD_PARTY_ID         = p_To_FK_ID,
               last_update_date       = HZ_UTILITY_V2PUB.last_update_date,
               last_updated_by        = HZ_UTILITY_V2PUB.user_id,
               last_update_login      = HZ_UTILITY_V2PUB.last_update_login,
               request_id             = HZ_UTILITY_V2PUB.request_id,
               program_application_id = HZ_UTILITY_V2PUB.program_application_id,
               program_id             = HZ_UTILITY_V2PUB.program_id,
               program_update_date    = sysdate
        WHERE THIRD_PARTY_ID  = p_from_fk_id;

        UPDATE IEX_CASE_CONTACTS
           SET CONTACT_PARTY_ID       = p_To_FK_ID,
               last_update_date       = HZ_UTILITY_V2PUB.last_update_date,
               last_updated_by        = HZ_UTILITY_V2PUB.user_id,
               last_update_login      = HZ_UTILITY_V2PUB.last_update_login,
               request_id             = HZ_UTILITY_V2PUB.request_id,
               program_application_id = HZ_UTILITY_V2PUB.program_application_id,
               program_id             = HZ_UTILITY_V2PUB.program_id,
               program_update_date    = sysdate
        WHERE CONTACT_PARTY_ID  = p_from_fk_id;

        UPDATE IEX_CASES_ALL_B
           SET PARTY_ID               = p_To_FK_ID,
               last_update_date       = HZ_UTILITY_V2PUB.last_update_date,
               last_updated_by        = HZ_UTILITY_V2PUB.user_id,
               last_update_login      = HZ_UTILITY_V2PUB.last_update_login,
               request_id             = HZ_UTILITY_V2PUB.request_id,
               program_application_id = HZ_UTILITY_V2PUB.program_application_id,
               program_id             = HZ_UTILITY_V2PUB.program_id,
               program_update_date    = sysdate
        WHERE PARTY_ID  = p_from_fk_id;

        UPDATE IEX_WRITEOFFS
           SET PARTY_ID               = p_To_FK_ID,
               last_update_date       = HZ_UTILITY_V2PUB.last_update_date,
               last_updated_by        = HZ_UTILITY_V2PUB.user_id,
               last_update_login      = HZ_UTILITY_V2PUB.last_update_login,
               request_id             = HZ_UTILITY_V2PUB.request_id,
               program_application_id = HZ_UTILITY_V2PUB.program_application_id,
               program_id             = HZ_UTILITY_V2PUB.program_id,
               program_update_date    = sysdate
        WHERE PARTY_ID  = p_from_fk_id;

        UPDATE IEX_BANKRUPTCIES
           SET PARTY_ID               = p_To_FK_ID,
               last_update_date       = HZ_UTILITY_V2PUB.last_update_date,
               last_updated_by        = HZ_UTILITY_V2PUB.user_id,
               last_update_login      = HZ_UTILITY_V2PUB.last_update_login,
               request_id             = HZ_UTILITY_V2PUB.request_id,
               program_application_id = HZ_UTILITY_V2PUB.program_application_id,
               program_id             = HZ_UTILITY_V2PUB.program_id,
               program_update_date    = sysdate
        WHERE PARTY_ID  = p_from_fk_id;

        UPDATE IEX_LITIGATIONS
           SET PARTY_ID               = p_To_FK_ID,
               last_update_date       = HZ_UTILITY_V2PUB.last_update_date,
               last_updated_by        = HZ_UTILITY_V2PUB.user_id,
               last_update_login      = HZ_UTILITY_V2PUB.last_update_login,
               request_id             = HZ_UTILITY_V2PUB.request_id,
               program_application_id = HZ_UTILITY_V2PUB.program_application_id,
               program_id             = HZ_UTILITY_V2PUB.program_id,
               program_update_date    = sysdate
        WHERE PARTY_ID  = p_from_fk_id;

        /* end raverma 02032003 */

        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LOGMESSAGE('MERGE_DELINQUENCY_PARTIES: End success!');
        END IF;

        RETURN;

    /*
    IF p_from_FK_id  <> p_to_FK_id THEN
        BEGIN
                SELECT party_cust_id
                INTO v_merged_to_id
                FROM IEX_DELINQUENCIES_ALL
                WHERE party_cust_id = p_To_FK_id
                --and category = p_parent_entity_name
                --and resource_name = (select resource_name
                --            from JTF_RS_RESOURCE_EXTNS
                --            where resource_id = p_from_id)
                and rownum =1;
            EXCEPTION
                WHEN no_data_found THEN
                v_merged_to_id := NULL;
        END;
    END IF;

    IF v_merged_to_id IS NULL THEN
        -- Duplicate Does Not exist. Therefore transfer
        UPDATE IEX_DELINQUENCIES_ALL
            SET  party_cust_id = p_To_FK_id,
                last_update_date = hz_utility_pub.last_update_date,
                    last_updated_by = hz_utility_pub.user_id,
                    last_update_login = hz_utility_pub.last_update_login,
                    --request_id =  hz_utility_pub.request_id,
                    --program_application_id = hz_utility_pub.program_application_id,
                    program_id = hz_utility_pub.program_id
                    --program_update_date = sysdate
        WHERE delinquency_id = p_from_id;
        RETURN;

    END IF;

    IF v_merged_to_id IS NOT NULL THEN
      /* Duplicate Exists. Therefore Merge */
    /*
      UPDATE IEX_DELINQUENCIES_ALL
            SET STATUS = 'CLOSED',
                last_update_date = hz_utility_pub.last_update_date,
                    last_updated_by = hz_utility_pub.user_id,
                    last_update_login = hz_utility_pub.last_update_login,
                    --request_id =  hz_utility_pub.request_id,
                    --program_application_id = hz_utility_pub.program_application_id,
                    program_id = hz_utility_pub.program_id
                    --program_update_date = sysdate
        WHERE delinquency_id = p_from_id;
        p_to_id := v_merged_to_id;

        RETURN;
    END IF;
     */

EXCEPTION
    -- Begin - 10/12/2005 - Andre Araujo - Check if we received all the required parameters
    When e_NullParameters THEN
        FND_MESSAGE.SET_NAME('IEX', 'IEX_API_ALL_NULL_PARAMETER');
        FND_MESSAGE.SET_TOKEN('API_NAME', 'MERGE_DELINQUENCY_PARTIES');
        FND_MESSAGE.SET_TOKEN('NULL_PARAM', null);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IEX_DEBUG_PUB.LOGMESSAGE('MERGE_DELINQUENCY_PARTIES: Null party_ids received!!!');
        IEX_DEBUG_PUB.LOGMESSAGE('MERGE_DELINQUENCY_PARTIES: p_from_id: ' || p_from_id );
        IEX_DEBUG_PUB.LOGMESSAGE('MERGE_DELINQUENCY_PARTIES: p_to_id: ' || p_to_id );
        IEX_DEBUG_PUB.LOGMESSAGE('MERGE_DELINQUENCY_PARTIES: p_from_fk_id: ' || p_from_fk_id );
        IEX_DEBUG_PUB.LOGMESSAGE('MERGE_DELINQUENCY_PARTIES: p_to_fk_id: ' || p_to_fk_id );

        FND_FILE.PUT_LINE(FND_FILE.LOG,'MERGE_DELINQUENCY_PARTIES: Null party_ids received!!!');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'MERGE_DELINQUENCY_PARTIES: p_from_id: ' || p_from_id );
        FND_FILE.PUT_LINE(FND_FILE.LOG,'MERGE_DELINQUENCY_PARTIES: p_to_id: ' || p_to_id );
        FND_FILE.PUT_LINE(FND_FILE.LOG,'MERGE_DELINQUENCY_PARTIES: p_from_fk_id: ' || p_from_fk_id );
        FND_FILE.PUT_LINE(FND_FILE.LOG,'MERGE_DELINQUENCY_PARTIES: p_to_fk_id: ' || p_to_fk_id );


    -- End - 10/12/2005 - Andre Araujo - Check if we received all the required parameters

    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        IEX_DEBUG_PUB.LOGMESSAGE('MERGE_DELINQUENCY_PARTIES: EXCEPTION!!!');
        IEX_DEBUG_PUB.LOGMESSAGE('MERGE_DELINQUENCY_PARTIES: ' || SQLERRM);

        FND_FILE.PUT_LINE(FND_FILE.LOG,'MERGE_DELINQUENCY_PARTIES: EXCEPTION!!!');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'MERGE_DELINQUENCY_PARTIES: ' || SQLERRM);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END MERGE_DELINQUENCY_PARTIES;

/* Begin - Andre Araujo - 05/04/03 - Add Contact points and Address Merge */

PROCEDURE CASE_CONTACT_MERGE
(   p_entity_name             IN       VARCHAR2
   ,p_from_id                 IN       NUMBER
   ,p_to_id                   IN OUT NOCOPY   NUMBER
   ,p_from_fk_id              IN       NUMBER
   ,p_to_fk_id                IN       NUMBER
   ,p_parent_entity_name      IN       VARCHAR2
   ,p_batch_id                IN       NUMBER
   ,p_batch_party_id          IN       NUMBER
   ,x_return_status           IN OUT NOCOPY   VARCHAR2
) is
  l_api_name            CONSTANT VARCHAR2(30) := 'CASE_CONTACT_MERGE';
  l_api_version_number  CONSTANT NUMBER       := 1.0;
  l_merge_reason_code   VARCHAR2(30);
BEGIN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('IEX_MERGE_PVT.CASE_CONTACT_MERGE BEGIN');
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select merge_reason_code into l_merge_reason_code
    from HZ_MERGE_BATCH
    where batch_id = p_batch_id;

    IF l_merge_reason_code = 'DUPLICATE' THEN
       -- ***************************************************************************
       -- if reason code is duplicate then allow the party merge to happen without
       -- any validations.
       -- ***************************************************************************
	  null;
    ELSE
       -- ***************************************************************************
       -- if there are any validations to be done, include it in this section
       -- ***************************************************************************
	  null;
    END IF;

    -- ***************************************************************************
    -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
    -- needs to be done. Set Merged To Id is same as Merged From Id and return
    -- ***************************************************************************
    if p_from_fk_id = p_to_fk_id then
       p_to_id := p_from_id;
       return;
    end if;

    -- ***************************************************************************
    -- If the parent has changed(ie. Parent is getting merged) then transfer the
    -- dependent record to the new parent. Before transferring check if a similar
    -- dependent record exists on the new parent. If a duplicate exists then do
    -- not transfer and return the id of the duplicate record as the Merged To Id
    -- ***************************************************************************

    -- ***************************************************************************
    -- Add your own logic if you need to take care of the following cases
    -- Check the if record duplicate if change party_id from merge-from
    -- to merge-to id.  E.g. : in AS_ACCESSES_ALL, if you have the following
    -- situation
    --
    -- customer_id    address_id     contact_id
    -- ===========    ==========     ==========
    --   1200           1100
    --   1300           1400
    --
    -- if p_from_fk_id = 1200, p_to_fk_id = 1300 for customer_id
    --    p_from_fk_id = 1100, p_to_fk_id = 1400 for address_id
    -- therefore, if changing 1200 to 1300 (customer_id)
    -- and 1100 to 1400 (address_id), then it will cause unique
    -- key violation assume that all other fields are the same
    -- So, please check if you need to check for record duplication
    -- ***************************************************************************

    IF p_from_fk_id <> p_to_fk_id THEN
       BEGIN
	     IF p_parent_entity_name = 'HZ_PARTY_SITES' THEN    -- merge party_site
		   UPDATE IEX_CASE_CONTACTS
		   set address_id = p_to_fk_id,
		       last_update_date       = HZ_UTILITY_V2PUB.last_update_date,
		       last_updated_by        = HZ_UTILITY_V2PUB.user_id,
		       last_update_login      = HZ_UTILITY_V2PUB.last_update_login,
		       request_id             = HZ_UTILITY_V2PUB.request_id,
		       program_application_id = HZ_UTILITY_V2PUB.program_application_id,
		       program_id             = HZ_UTILITY_V2PUB.program_id,
		       program_update_date    = sysdate
		   where address_id = p_from_fk_id;
	     ELSIF p_parent_entity_name = 'HZ_CONTACT_POINTS' THEN   -- merge contact_points
		   UPDATE IEX_CASE_CONTACTS
		   set phone_id = p_to_fk_id,
		       last_update_date       = HZ_UTILITY_V2PUB.last_update_date,
		       last_updated_by        = HZ_UTILITY_V2PUB.user_id,
		       last_update_login      = HZ_UTILITY_V2PUB.last_update_login,
		       request_id             = HZ_UTILITY_V2PUB.request_id,
		       program_application_id = HZ_UTILITY_V2PUB.program_application_id,
		       program_id             = HZ_UTILITY_V2PUB.program_id,
		       program_update_date    = sysdate
		   where phone_id = p_from_fk_id;
	     END IF;
       EXCEPTION
          WHEN OTHERS THEN
    	     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    	     IEX_DEBUG_PUB.logMessage('IEX_MERGE_PVT.CASE_CONTACT_MERGE EXCEPTION:');
    	     IEX_DEBUG_PUB.logMessage('IEX_MERGE_PVT' || '.' || l_api_name || ': ' || sqlerrm);
    	     END IF;
             arp_message.set_line('IEX_MERGE_PVT' || '.' || l_api_name || ': ' || sqlerrm);
             x_return_status :=  FND_API.G_RET_STS_ERROR;
             raise;
       END;
    END IF;

    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('IEX_MERGE_PVT.CASE_CONTACT_MERGE END');
    END IF;

END CASE_CONTACT_MERGE;

/* End - Andre Araujo - 05/04/03 - Add Contact points and Address Merge */


END IEX_MERGE_PVT;

/
