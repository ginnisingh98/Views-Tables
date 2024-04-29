--------------------------------------------------------
--  DDL for Package Body PNP_CMERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNP_CMERGE" AS
/* $Header: PNCMERGB.pls 115.9 2004/05/07 03:51:12 kkhegde ship $ */

  ---------------------------------
  -- Private Variable(s)
  ---------------------------------
  PROCEDURE merge ( req_id         number,
                    set_num        number,
                    process_mode   varchar2
                  ) is

    /* Lock leases */
    CURSOR leases IS
    SELECT lease_id
    FROM   pn_leases
    WHERE  customer_id IN (SELECT racm.duplicate_id
                           FROM   ra_customer_merges racm
                           WHERE  racm.process_flag  = 'N'
                           AND    racm.request_id    = req_id
                           AND    racm.set_number    = set_num
                          )
    FOR UPDATE NOWAIT;
    /* Lock Tenancies */
    CURSOR tenencies IS
    SELECT tenancy_id
    FROM   pn_tenancies
    WHERE  customer_id IN (SELECT racm.duplicate_id
                           FROM   ra_customer_merges racm
                           WHERE  racm.process_flag  = 'N'
                           AND    racm.request_id    = req_id
                           AND    racm.set_number    = set_num
                          )
    FOR UPDATE NOWAIT;
    /* Lock Tenancies History */
    CURSOR tenencies_history IS
    SELECT tenancy_history_id
    FROM   pn_tenancies_history
    WHERE  customer_id IN (SELECT racm.duplicate_id
                           FROM   ra_customer_merges racm
                           WHERE  racm.process_flag  = 'N'
                           AND    racm.request_id    = req_id
                           AND    racm.set_number    = set_num
                          )
    FOR UPDATE NOWAIT;
    /* Lock Term Templates */
    CURSOR term_templates IS
    SELECT term_template_id
    FROM   pn_term_templates
    WHERE  customer_id IN (SELECT racm.duplicate_id
                           FROM   ra_customer_merges racm
                           WHERE  racm.process_flag  = 'N'
                           AND    racm.request_id    = req_id
                           AND    racm.set_number    = set_num
                          )
    FOR UPDATE NOWAIT;
    /* Lock Terms */
    CURSOR pmt_terms IS
    SELECT payment_term_id
    FROM   pn_payment_terms
    WHERE  customer_id IN (SELECT racm.duplicate_id
                           FROM   ra_customer_merges racm
                           WHERE  racm.process_flag  = 'N'
                           AND    racm.request_id    = req_id
                           AND    racm.set_number    = set_num
                          )
    FOR UPDATE NOWAIT;
    /* Lock Items */
    CURSOR pmt_items IS
    SELECT payment_item_id
    FROM   pn_payment_items
    WHERE  customer_id IN (SELECT racm.duplicate_id
                           FROM   ra_customer_merges racm
                           WHERE  racm.process_flag  = 'N'
                           AND    racm.request_id    = req_id
                           AND    racm.set_number    = set_num
                          )
    FOR UPDATE NOWAIT;
    /* Lock Recovery Agreements */
    CURSOR rec_agreements IS
    SELECT rec_agreement_id
    FROM   pn_rec_agreements
    WHERE  customer_id IN (SELECT racm.duplicate_id
                           FROM   ra_customer_merges racm
                           WHERE  racm.process_flag  = 'N'
                           AND    racm.request_id    = req_id
                           AND    racm.set_number    = set_num
                          )
    FOR UPDATE NOWAIT;
    /* Lock Area Class Line Details */
    CURSOR rec_arcl_dtlln IS
    SELECT area_class_dtl_id
    FROM   pn_rec_arcl_dtlln
    WHERE  cust_account_id IN
                          (SELECT racm.duplicate_id
                           FROM   ra_customer_merges racm
                           WHERE  racm.process_flag  = 'N'
                           AND    racm.request_id    = req_id
                           AND    racm.set_number    = set_num
                          )
    FOR UPDATE NOWAIT;
    /* Lock Expense Class Line Details */
    CURSOR rec_expcl_dtlln IS
    SELECT expense_class_dtl_id
    FROM   pn_rec_expcl_dtlln
    WHERE  cust_account_id IN
                          (SELECT racm.duplicate_id
                           FROM   ra_customer_merges racm
                           WHERE  racm.process_flag  = 'N'
                           AND    racm.request_id    = req_id
                           AND    racm.set_number    = set_num
                          )
    FOR UPDATE NOWAIT;
    /* Lock Recovery Period Lines */
    CURSOR rec_period_lines IS
    SELECT rec_period_lines_id
    FROM   pn_rec_period_lines
    WHERE  cust_account_id IN
                          (SELECT racm.duplicate_id
                           FROM   ra_customer_merges racm
                           WHERE  racm.process_flag  = 'N'
                           AND    racm.request_id    = req_id
                           AND    racm.set_number    = set_num
                          )
    FOR UPDATE NOWAIT;
    /* Lock Customer Assignments */
    CURSOR cust_assignments IS
    SELECT cust_space_assign_id
    FROM   pn_space_assign_cust
    WHERE  cust_account_id IN
                           (SELECT racm.duplicate_id
                            FROM   ra_customer_merges racm
                            WHERE  racm.process_flag  = 'N'
                            AND    racm.request_id    = req_id
                            AND    racm.set_number    = set_num
                           )
    FOR UPDATE NOWAIT;

  BEGIN

    arp_message.set_line ( 'PNP_CMERGE.MERGE()+');

    IF( process_mode = 'LOCK' ) THEN

      /* Lock leases */
      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'PN_LEASES', FALSE );

      OPEN leases;
      CLOSE leases;

      /* Lock Tenancies */
      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'PN_TENANCIES', FALSE );

      OPEN tenencies;
      CLOSE tenencies;

      /* Lock Tenancies History */
      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'PN_TENANCIES_HISTORY', FALSE );

      OPEN tenencies_history;
      CLOSE tenencies_history;

      /* Lock Term Templates */
      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'PN_TERM_TEMPLATES', FALSE );

      OPEN term_templates;
      CLOSE term_templates;

      /* Lock Terms */
      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'PN_PAYMENT_TERMS', FALSE );

      OPEN pmt_terms;
      CLOSE pmt_terms;

      /* Lock Items */
      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'PN_PAYMENT_ITEMS', FALSE );

      OPEN pmt_items;
      CLOSE pmt_items;

      /* Lock Recovery Agreements */
      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'PN_REC_AGREEMENTS', FALSE );

      OPEN rec_agreements;
      CLOSE rec_agreements;

      /* Lock Area Class Line Details */
      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'PN_REC_ARCL_DTLLN', FALSE );

      OPEN rec_arcl_dtlln;
      CLOSE rec_arcl_dtlln;

      /* Lock Expense Class Line Details */
      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'PN_REC_EXPCL_DTLLN', FALSE );

      OPEN rec_expcl_dtlln;
      CLOSE rec_expcl_dtlln;

      /* Lock Recovery Period Lines */
      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'PN_REC_PERIOD_LINES', FALSE );

      OPEN rec_period_lines;
      CLOSE rec_period_lines;

      /* Lock Customer Assignments */
      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'PN_SPACE_ASSIGN_CUST', FALSE );

      OPEN cust_assignments;
      CLOSE cust_assignments;

    ELSE

      update_leases ( req_id       => req_id,
                      set_num      => set_num,
                      process_mode => process_mode
                    );

      update_tenancies ( req_id       => req_id,
                         set_num      => set_num,
                         process_mode => process_mode
                       );

      update_tenancies_history ( req_id       => req_id,
                                 set_num      => set_num,
                                 process_mode => process_mode
                               );

      update_term_templates ( req_id       => req_id,
                              set_num      => set_num,
                              process_mode => process_mode
                            );

      update_payment_terms ( req_id       => req_id,
                             set_num      => set_num,
                             process_mode => process_mode
                           );

      update_payment_items ( req_id       => req_id,
                             set_num      => set_num,
                             process_mode => process_mode
                           );

      update_rec_agreements ( req_id       => req_id,
                              set_num      => set_num,
                              process_mode => process_mode
                            );

      update_rec_arcl_dtln ( req_id       => req_id,
                             set_num      => set_num,
                             process_mode => process_mode
                           );

      update_rec_expcl_dtln ( req_id       => req_id,
                              set_num      => set_num,
                              process_mode => process_mode
                            );

      update_rec_period_lines ( req_id       => req_id,
                                set_num      => set_num,
                                process_mode => process_mode
                              );

      update_space_assign_cust ( req_id       => req_id,
                                 set_num      => set_num,
                                 process_mode => process_mode
                               );

    END IF;

    arp_message.set_line ( 'PNP_CMERGE.MERGE()-');

    EXCEPTION
      WHEN OTHERS THEN
      arp_message.set_error( 'PNP_CMERGE.MERGE');
      RAISE;

  END MERGE;

/*===========================================================================+
 | PROCEDURE
 |    update_leases
 |
 | DESCRIPTION
 |    Account merge procedure for the table, pn_leases
 |    Column updated   Corresponding HZ table.column
 |    --------------   --------------------------------
 |    customer_id      HZ_CUST_ACCOUNTS.cust_account_id
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:  req_id, set_num, process_mode
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 | 29-apr-2004  Perl Script   Created
 | 29-apr-2004  Kiran         Finalised
 +===========================================================================*/

PROCEDURE update_leases (req_id       NUMBER,
                         set_num      NUMBER,
                         process_mode VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
  RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
  INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE LEASE_ID_LIST_TYPE IS TABLE OF
  PN_LEASES.LEASE_ID%TYPE
  INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST LEASE_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
  PN_LEASES.CUSTOMER_ID%TYPE
  INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
    SELECT DISTINCT m.CUSTOMER_MERGE_HEADER_ID
                   ,yt.LEASE_ID
                   ,yt.CUSTOMER_ID
    FROM PN_LEASES yt
       , RA_CUSTOMER_MERGES m
    WHERE yt.CUSTOMER_ID  = m.DUPLICATE_ID
    AND    m.process_flag = 'N'
    AND    m.request_id   = req_id
    AND    m.set_number   = set_num;

  l_last_fetch BOOLEAN;
  l_count NUMBER;

BEGIN
  /* init variables */
  l_last_fetch := FALSE;
  l_count := 0;

  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','PN_LEASES',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    OPEN merged_records;

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
           ) VALUES (
             HZ_CUSTOMER_MERGE_LOG_s.NEXTVAL,
             'PN_LEASES',
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

      END IF;

      FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
        UPDATE PN_LEASES yt SET
              CUSTOMER_ID      = NUM_COL1_NEW_LIST(I)
            , LAST_UPDATE_DATE = SYSDATE
            , last_updated_by  = arp_standard.profile.user_id
            , last_update_login= arp_standard.profile.last_update_login
        WHERE LEASE_ID=PRIMARY_KEY_ID_LIST(I);

      l_count := l_count + MERGE_HEADER_ID_LIST.COUNT;

      IF l_last_fetch THEN
        EXIT;
      END IF;

    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));

  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'update_leases');
    RAISE;
END update_leases;

/*===========================================================================+
 | PROCEDURE
 |    update_tenancies
 |
 | DESCRIPTION
 |    Account merge procedure for the table, pn_tenencies
 |    Column updated        Corresponding HZ table.column
 |    --------------------  -----------------------------
 |    customer_id           HZ_CUST_ACCOUNTS.cust_account_id
 |    customer_site_use_id  HZ_CUST_SITE_USES.site_use_id
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:  req_id, set_num, process_mode
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 | 29-apr-2004  Perl Script   Created
 | 29-apr-2004  Kiran         Finalised
 +===========================================================================*/

PROCEDURE update_tenancies (req_id       NUMBER,
                            set_num      NUMBER,
                            process_mode VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
  RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
  INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE TENANCY_ID_LIST_TYPE IS TABLE OF
  PN_TENANCIES.TENANCY_ID%TYPE
  INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST TENANCY_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
  PN_TENANCIES.CUSTOMER_ID%TYPE
  INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  TYPE CUSTOMER_SITE_USE_ID_LIST_TYPE IS TABLE OF
  PN_TENANCIES.CUSTOMER_SITE_USE_ID%TYPE
  INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST CUSTOMER_SITE_USE_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST CUSTOMER_SITE_USE_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
    SELECT distinct m.CUSTOMER_MERGE_HEADER_ID
                   ,yt.TENANCY_ID
                   ,yt.CUSTOMER_ID
                   ,yt.CUSTOMER_SITE_USE_ID
     FROM PN_TENANCIES yt
         ,RA_CUSTOMER_MERGES m
     WHERE ( yt.CUSTOMER_ID = m.DUPLICATE_ID
             OR yt.CUSTOMER_SITE_USE_ID = m.DUPLICATE_SITE_ID)
     AND    m.process_flag = 'N'
     AND    m.request_id   = req_id
     AND    m.set_number   = set_num;

  l_last_fetch BOOLEAN;
  l_count NUMBER;

BEGIN
  /* init variables */
  l_last_fetch := FALSE;
  l_count := 0;

  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','PN_TENANCIES',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    OPEN merged_records;

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
        EXIT;
      END IF;

      FOR I IN 1..MERGE_HEADER_ID_LIST.COUNT LOOP
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
          ) VALUES (
             HZ_CUSTOMER_MERGE_LOG_s.NEXTVAL,
            'PN_TENANCIES',
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

      FORALL I IN 1..MERGE_HEADER_ID_LIST.COUNT
        UPDATE PN_TENANCIES yt SET
              CUSTOMER_ID         = NUM_COL1_NEW_LIST(I)
            , CUSTOMER_SITE_USE_ID= NUM_COL2_NEW_LIST(I)
            , LAST_UPDATE_DATE    = SYSDATE
            , last_updated_by     = arp_standard.profile.user_id
            , last_update_login   = arp_standard.profile.last_update_login
        WHERE TENANCY_ID=PRIMARY_KEY_ID_LIST(I);

      l_count := l_count + MERGE_HEADER_ID_LIST.COUNT;

      IF l_last_fetch THEN
         EXIT;
      END IF;

    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'update_tenancies');
    RAISE;
END update_tenancies;

/*===========================================================================+
 | PROCEDURE
 |    update_tenancies_history
 |
 | DESCRIPTION
 |    Account merge procedure for the table, pn_tenancies_history
 |    Column updated        Corresponding HZ table.column
 |    --------------------  -----------------------------
 |    customer_id           HZ_CUST_ACCOUNTS.cust_account_id
 |    customer_site_use_id  HZ_CUST_SITE_USES.site_use_id
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:  req_id, set_num, process_mode
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 | 29-apr-2004  Perl Script   Created
 | 29-apr-2004  Kiran         Finalised
 +===========================================================================*/

PROCEDURE update_tenancies_history (req_id       NUMBER,
                                    set_num      NUMBER,
                                    process_mode VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
  RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
  INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE TENANCY_HISTORY_ID_LIST_TYPE IS TABLE OF
  PN_TENANCIES_HISTORY.TENANCY_HISTORY_ID%TYPE
  INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST TENANCY_HISTORY_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
  PN_TENANCIES_HISTORY.CUSTOMER_ID%TYPE
  INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  TYPE CUSTOMER_SITE_USE_ID_LIST_TYPE IS TABLE OF
  PN_TENANCIES_HISTORY.CUSTOMER_SITE_USE_ID%TYPE
  INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST CUSTOMER_SITE_USE_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST CUSTOMER_SITE_USE_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
    SELECT distinct m.CUSTOMER_MERGE_HEADER_ID
                   ,yt.TENANCY_HISTORY_ID
                   ,yt.CUSTOMER_ID
                   ,yt.CUSTOMER_SITE_USE_ID
     FROM PN_TENANCIES_HISTORY yt,
          RA_CUSTOMER_MERGES m
     WHERE ( yt.CUSTOMER_ID = m.DUPLICATE_ID
             OR yt.CUSTOMER_SITE_USE_ID = m.DUPLICATE_SITE_ID)
     AND    m.process_flag = 'N'
     AND    m.request_id   = req_id
     AND    m.set_number   = set_num;

  l_last_fetch BOOLEAN;
  l_count NUMBER;

BEGIN
  /* init variables */
  l_last_fetch := FALSE;
  l_count := 0;

  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','PN_TENANCIES_HISTORY',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    OPEN merged_records;

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
        EXIT;
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
          ) VALUES (
             HZ_CUSTOMER_MERGE_LOG_s.NEXTVAL,
             'PN_TENANCIES_HISTORY',
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

      FORALL I IN 1..MERGE_HEADER_ID_LIST.COUNT
        UPDATE PN_TENANCIES_HISTORY yt SET
              CUSTOMER_ID         = NUM_COL1_NEW_LIST(I)
            , CUSTOMER_SITE_USE_ID= NUM_COL2_NEW_LIST(I)
            , LAST_UPDATE_DATE    = SYSDATE
            , last_updated_by     = arp_standard.profile.user_id
            , last_update_login   = arp_standard.profile.last_update_login
        WHERE TENANCY_HISTORY_ID  = PRIMARY_KEY_ID_LIST(I);

      l_count := l_count + MERGE_HEADER_ID_LIST.COUNT;

      IF l_last_fetch THEN
         EXIT;
      END IF;

    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'update_tenancies_history');
    RAISE;
END update_tenancies_history;

/*===========================================================================+
 | PROCEDURE
 |    update_term_templates
 |
 | DESCRIPTION
 |    Account merge procedure for the table, pn_term_templates
 |    Column updated        Corresponding HZ table.column
 |    --------------------  -----------------------------
 |    customer_id           HZ_CUST_ACCOUNTS.cust_account_id
 |    customer_site_use_id  HZ_CUST_SITE_USES.site_use_id
 |    cust_ship_site_id     HZ_CUST_SITE_USES.site_use_id
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:  req_id, set_num, process_mode
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 | 29-apr-2004  Perl Script   Created
 | 29-apr-2004  Kiran         Finalised
 +===========================================================================*/

PROCEDURE update_term_templates (req_id       NUMBER,
                                 set_num      NUMBER,
                                 process_mode VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
  RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
  INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE TERM_TEMPLATE_ID_LIST_TYPE IS TABLE OF
  PN_TERM_TEMPLATES.TERM_TEMPLATE_ID%TYPE
  INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST TERM_TEMPLATE_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
  PN_TERM_TEMPLATES.CUSTOMER_ID%TYPE
  INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  TYPE CUSTOMER_SITE_USE_ID_LIST_TYPE IS TABLE OF
  PN_TERM_TEMPLATES.CUSTOMER_SITE_USE_ID%TYPE
  INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST CUSTOMER_SITE_USE_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST CUSTOMER_SITE_USE_ID_LIST_TYPE;

  TYPE CUST_SHIP_SITE_ID_LIST_TYPE IS TABLE OF
  PN_TERM_TEMPLATES.CUST_SHIP_SITE_ID%TYPE
  INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST CUST_SHIP_SITE_ID_LIST_TYPE;
  NUM_COL3_NEW_LIST CUST_SHIP_SITE_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);

  CURSOR merged_records IS
    SELECT DISTINCT  m.CUSTOMER_MERGE_HEADER_ID
                    ,yt.TERM_TEMPLATE_ID
                    ,yt.CUSTOMER_ID
                    ,yt.CUSTOMER_SITE_USE_ID
                    ,yt.CUST_SHIP_SITE_ID
    FROM PN_TERM_TEMPLATES yt,
         RA_CUSTOMER_MERGES m
    WHERE ( yt.CUSTOMER_ID = m.DUPLICATE_ID
            OR yt.CUSTOMER_SITE_USE_ID = m.DUPLICATE_SITE_ID
            OR yt.CUST_SHIP_SITE_ID = m.DUPLICATE_SITE_ID)
    AND    m.process_flag = 'N'
    AND    m.request_id   = req_id
    AND    m.set_number   = set_num;

  l_last_fetch BOOLEAN;
  l_count NUMBER;

BEGIN
  /* init variables */
  l_last_fetch := FALSE;
  l_count := 0;

  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','PN_TERM_TEMPLATES',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    OPEN merged_records;

    LOOP
      FETCH merged_records BULK COLLECT INTO
            MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          , NUM_COL3_ORIG_LIST
      LIMIT 1000;

      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        EXIT;
      END IF;

      FOR I IN 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
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
             NUM_COL2_ORIG,
             NUM_COL2_NEW,
             NUM_COL3_ORIG,
             NUM_COL3_NEW,
             ACTION_FLAG,
             REQUEST_ID,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATE_LOGIN,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY
          ) VALUES (
             HZ_CUSTOMER_MERGE_LOG_s.NEXTVAL,
             'PN_TERM_TEMPLATES',
             MERGE_HEADER_ID_LIST(I),
             PRIMARY_KEY_ID_LIST(I),
             NUM_COL1_ORIG_LIST(I),
             NUM_COL1_NEW_LIST(I),
             NUM_COL2_ORIG_LIST(I),
             NUM_COL2_NEW_LIST(I),
             NUM_COL3_ORIG_LIST(I),
             NUM_COL3_NEW_LIST(I),
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
        UPDATE PN_TERM_TEMPLATES yt SET
              CUSTOMER_ID         = NUM_COL1_NEW_LIST(I)
            , CUSTOMER_SITE_USE_ID= NUM_COL2_NEW_LIST(I)
            , CUST_SHIP_SITE_ID   = NUM_COL3_NEW_LIST(I)
            , LAST_UPDATE_DATE    = SYSDATE
            , last_updated_by     = arp_standard.profile.user_id
            , last_update_login   = arp_standard.profile.last_update_login
        WHERE TERM_TEMPLATE_ID = PRIMARY_KEY_ID_LIST(I);

      l_count := l_count + MERGE_HEADER_ID_LIST.COUNT;

      IF l_last_fetch THEN
         EXIT;
      END IF;

    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'update_term_templates');
    RAISE;
END update_term_templates;

/*===========================================================================+
 | PROCEDURE
 |    update_payment_terms
 |
 | DESCRIPTION
 |    Account merge procedure for the table, pn_payment_terms_all
 |    Column updated        Corresponding HZ table.column
 |    --------------------  -----------------------------
 |    customer_id           HZ_CUST_ACCOUNTS.cust_account_id
 |    customer_site_use_id  HZ_CUST_SITE_USES.site_use_id
 |    cust_ship_site_id     HZ_CUST_SITE_USES.site_use_id
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN: req_id, set_num, process_mode
 |
 |              OUT: none
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 | 18-FEB-2003  Perl Script   Created
 | 18-FEB-2003  Kiran         Finalised
 | 29-apr-2004  Kiran         Added code to update ship_site_id
 +===========================================================================*/

PROCEDURE update_payment_terms (req_id       NUMBER,
                                set_num      NUMBER,
                                process_mode VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
  RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
  INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE PAYMENT_TERM_ID_LIST_TYPE IS TABLE OF
  PN_PAYMENT_TERMS.PAYMENT_TERM_ID%TYPE
  INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST PAYMENT_TERM_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
  PN_PAYMENT_TERMS.CUSTOMER_ID%TYPE
  INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  TYPE CUSTOMER_SITE_USE_ID_LIST_TYPE IS TABLE OF
  PN_PAYMENT_TERMS.CUSTOMER_SITE_USE_ID%TYPE
  INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST CUSTOMER_SITE_USE_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST CUSTOMER_SITE_USE_ID_LIST_TYPE;

  TYPE CUST_SHIP_SITE_ID_LIST_TYPE IS TABLE OF
  PN_PAYMENT_TERMS.CUST_SHIP_SITE_ID%TYPE
  INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST CUST_SHIP_SITE_ID_LIST_TYPE;
  NUM_COL3_NEW_LIST CUST_SHIP_SITE_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);

  CURSOR merged_records IS
    SELECT DISTINCT  m.CUSTOMER_MERGE_HEADER_ID
                    ,yt.PAYMENT_TERM_ID
                    ,yt.CUSTOMER_ID
                    ,yt.CUSTOMER_SITE_USE_ID
                    ,yt.CUST_SHIP_SITE_ID
     FROM PN_PAYMENT_TERMS yt,
          RA_CUSTOMER_MERGES m
     WHERE ( yt.CUSTOMER_ID = m.DUPLICATE_ID
             OR yt.CUSTOMER_SITE_USE_ID = m.DUPLICATE_SITE_ID
             OR yt.CUST_SHIP_SITE_ID = m.DUPLICATE_SITE_ID)
     AND    m.process_flag = 'N'
     AND    m.request_id   = req_id
     AND    m.set_number   = set_num;

  l_last_fetch BOOLEAN;
  l_count NUMBER;
BEGIN
  /* init variables */
  l_last_fetch := FALSE;
  l_count := 0;

  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','PN_PAYMENT_TERMS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    OPEN merged_records;

    LOOP
      FETCH merged_records BULK COLLECT INTO
            MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          , NUM_COL3_ORIG_LIST
      LIMIT 1000;

      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        EXIT;
      END IF;

      FOR I IN 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
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
             NUM_COL2_ORIG,
             NUM_COL2_NEW,
             NUM_COL3_ORIG,
             NUM_COL3_NEW,
             ACTION_FLAG,
             REQUEST_ID,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATE_LOGIN,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY
          ) VALUES (
             HZ_CUSTOMER_MERGE_LOG_s.NEXTVAL,
             'PN_PAYMENT_TERMS',
             MERGE_HEADER_ID_LIST(I),
             PRIMARY_KEY_ID_LIST(I),
             NUM_COL1_ORIG_LIST(I),
             NUM_COL1_NEW_LIST(I),
             NUM_COL2_ORIG_LIST(I),
             NUM_COL2_NEW_LIST(I),
             NUM_COL3_ORIG_LIST(I),
             NUM_COL3_NEW_LIST(I),
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
        UPDATE PN_PAYMENT_TERMS yt SET
              CUSTOMER_ID         = NUM_COL1_NEW_LIST(I)
            , CUSTOMER_SITE_USE_ID= NUM_COL2_NEW_LIST(I)
            , CUST_SHIP_SITE_ID   = NUM_COL3_NEW_LIST(I)
            , LAST_UPDATE_DATE    = SYSDATE
            , last_updated_by     = arp_standard.profile.user_id
            , last_update_login   = arp_standard.profile.last_update_login
        WHERE PAYMENT_TERM_ID=PRIMARY_KEY_ID_LIST(I);

      l_count := l_count + MERGE_HEADER_ID_LIST.COUNT;

      IF l_last_fetch THEN
         EXIT;
      END IF;

    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'update_payment_terms');
    RAISE;
END update_payment_terms;

/*===========================================================================+
 | PROCEDURE
 |    update_payment_items
 |
 | DESCRIPTION
 |    Account merge procedure for the table, pn_payment_items_all
 |    Column updated        Corresponding HZ table.column
 |    --------------------  -----------------------------
 |    customer_id           HZ_CUST_ACCOUNTS.cust_account_id
 |    customer_site_use_id  HZ_CUST_SITE_USES.site_use_id
 |    cust_ship_site_id     HZ_CUST_SITE_USES.site_use_id
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN: req_id, set_num, process_mode
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 | 18-feb-2003  Perl Script    Created
 | 18-feb-2003  Kiran Hegde    Finalised
 | 29-apr-2004  Kiran          Added code to update ship_site_id
 +===========================================================================*/

PROCEDURE update_payment_items (req_id       NUMBER,
                                set_num      NUMBER,
                                process_mode VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
  RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
  INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE PAYMENT_ITEM_ID_LIST_TYPE IS TABLE OF
  PN_PAYMENT_ITEMS.PAYMENT_ITEM_ID%TYPE
  INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST PAYMENT_ITEM_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
  PN_PAYMENT_ITEMS.CUSTOMER_ID%TYPE
  INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  TYPE CUSTOMER_SITE_USE_ID_LIST_TYPE IS TABLE OF
  PN_PAYMENT_ITEMS.CUSTOMER_SITE_USE_ID%TYPE
  INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST CUSTOMER_SITE_USE_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST CUSTOMER_SITE_USE_ID_LIST_TYPE;

  TYPE CUST_SHIP_SITE_ID_LIST_TYPE IS TABLE OF
  PN_PAYMENT_ITEMS.CUST_SHIP_SITE_ID%TYPE
  INDEX BY BINARY_INTEGER;
  NUM_COL3_ORIG_LIST CUST_SHIP_SITE_ID_LIST_TYPE;
  NUM_COL3_NEW_LIST CUST_SHIP_SITE_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
    SELECT DISTINCT  m.CUSTOMER_MERGE_HEADER_ID
                    ,yt.PAYMENT_ITEM_ID
                    ,yt.CUSTOMER_ID
                    ,yt.CUSTOMER_SITE_USE_ID
                    ,yt.CUST_SHIP_SITE_ID
     FROM PN_PAYMENT_ITEMS yt
         ,RA_CUSTOMER_MERGES m
     WHERE ( yt.CUSTOMER_ID = m.DUPLICATE_ID
             OR yt.CUSTOMER_SITE_USE_ID = m.DUPLICATE_SITE_ID
             OR yt.CUST_SHIP_SITE_ID = m.DUPLICATE_SITE_ID )
     AND    m.process_flag = 'N'
     AND    m.request_id = req_id
     AND    m.set_number = set_num;

  l_last_fetch BOOLEAN;
  l_count NUMBER;

BEGIN
  /* init variables */
  l_last_fetch := FALSE;
  l_count := 0;

  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','PN_PAYMENT_ITEMS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    OPEN merged_records;

    LOOP

      FETCH merged_records BULK COLLECT INTO
            MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          , NUM_COL3_ORIG_LIST
      LIMIT 1000;

      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        EXIT;
      END IF;

      FOR I IN 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
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
             NUM_COL2_ORIG,
             NUM_COL2_NEW,
             NUM_COL3_ORIG,
             NUM_COL3_NEW,
             ACTION_FLAG,
             REQUEST_ID,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATE_LOGIN,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY
          ) VALUES (
             HZ_CUSTOMER_MERGE_LOG_s.NEXTVAL,
             'PN_PAYMENT_ITEMS',
             MERGE_HEADER_ID_LIST(I),
             PRIMARY_KEY_ID_LIST(I),
             NUM_COL1_ORIG_LIST(I),
             NUM_COL1_NEW_LIST(I),
             NUM_COL2_ORIG_LIST(I),
             NUM_COL2_NEW_LIST(I),
             NUM_COL3_ORIG_LIST(I),
             NUM_COL3_NEW_LIST(I),
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
        UPDATE PN_PAYMENT_ITEMS yt SET
              CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
            , CUSTOMER_SITE_USE_ID=NUM_COL2_NEW_LIST(I)
            , CUST_SHIP_SITE_ID=NUM_COL3_NEW_LIST(I)
            , LAST_UPDATE_DATE=SYSDATE
            , last_updated_by=arp_standard.profile.user_id
            , last_update_login=arp_standard.profile.last_update_login
        WHERE PAYMENT_ITEM_ID=PRIMARY_KEY_ID_LIST(I);

      l_count := l_count + MERGE_HEADER_ID_LIST.COUNT;

      IF l_last_fetch THEN
         EXIT;
      END IF;

    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'update_payment_items');
    RAISE;
END update_payment_items;

/*===========================================================================+
 | PROCEDURE
 |    update_rec_agreements
 |
 | DESCRIPTION
 |    Account merge procedure for the table, pn_rec_agreements
 |    Column updated        Corresponding HZ table.column
 |    --------------------  -----------------------------
 |    customer_id           HZ_CUST_ACCOUNTS.cust_account_id
 |    cust_site_id          HZ_CUST_SITE_USES.site_use_id
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:  req_id, set_num, process_mode
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 | 29-apr-2004  Perl Script   Created
 | 29-apr-2004  Kiran         Finalised
 +===========================================================================*/

PROCEDURE update_rec_agreements (req_id       NUMBER,
                                 set_num      NUMBER,
                                 process_mode VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
  RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
  INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE REC_AGREEMENT_ID_LIST_TYPE IS TABLE OF
  PN_REC_AGREEMENTS.REC_AGREEMENT_ID%TYPE
  INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST REC_AGREEMENT_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
  PN_REC_AGREEMENTS.CUSTOMER_ID%TYPE
  INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  TYPE CUST_SITE_ID_LIST_TYPE IS TABLE OF
  PN_REC_AGREEMENTS.CUST_SITE_ID%TYPE
  INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST CUST_SITE_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST CUST_SITE_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
    SELECT DISTINCT  m.CUSTOMER_MERGE_HEADER_ID
                    ,yt.REC_AGREEMENT_ID
                    ,yt.CUSTOMER_ID
                    ,yt.CUST_SITE_ID
     FROM PN_REC_AGREEMENTS yt
         ,RA_CUSTOMER_MERGES m
     WHERE ( yt.CUSTOMER_ID = m.DUPLICATE_ID
             OR yt.CUST_SITE_ID = m.DUPLICATE_SITE_ID)
     AND    m.process_flag = 'N'
     AND    m.request_id = req_id
     AND    m.set_number = set_num;

  l_last_fetch BOOLEAN;
  l_count NUMBER;
BEGIN
  /* init variables */
  l_last_fetch := FALSE;
  l_count := 0;

  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','PN_REC_AGREEMENTS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    OPEN merged_records;

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
        EXIT;
      END IF;

      FOR I IN 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
      END LOOP;

      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I IN 1..MERGE_HEADER_ID_LIST.COUNT
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
             HZ_CUSTOMER_MERGE_LOG_s.NEXTVAL,
             'PN_REC_AGREEMENTS',
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

      FORALL I IN 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE PN_REC_AGREEMENTS yt SET
            CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
          , CUST_SITE_ID=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE REC_AGREEMENT_ID=PRIMARY_KEY_ID_LIST(I);

      l_count := l_count + MERGE_HEADER_ID_LIST.COUNT;

      IF l_last_fetch THEN
         EXIT;
      END IF;

    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'update_rec_agreements');
    RAISE;
END update_rec_agreements;

/*===========================================================================+
 | PROCEDURE
 |    update_rec_arcl_dtln
 |
 | DESCRIPTION
 |    Account merge procedure for the table, pn_rec_arcl_dtln
 |    Column updated        Corresponding HZ table.column
 |    --------------------  -----------------------------
 |    cust_account_id       HZ_CUST_ACCOUNTS.cust_account_id
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:  req_id, set_num, process_mode
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 | 29-apr-2004  Perl Script   Created
 | 29-apr-2004  Kiran         Finalised
 +===========================================================================*/

PROCEDURE update_rec_arcl_dtln (req_id       NUMBER,
                                set_num      NUMBER,
                                process_mode VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
  RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
  INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE AREA_CLASS_DTL_ID_LIST_TYPE IS TABLE OF
  PN_REC_ARCL_DTLLN.AREA_CLASS_DTL_ID%TYPE
  INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST AREA_CLASS_DTL_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
  PN_REC_ARCL_DTLLN.CUST_ACCOUNT_ID%TYPE
  INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);

  CURSOR merged_records IS
    SELECT DISTINCT  m.CUSTOMER_MERGE_HEADER_ID
                    ,yt.AREA_CLASS_DTL_ID
                    ,yt.CUST_ACCOUNT_ID
     FROM PN_REC_ARCL_DTLLN yt
         ,RA_CUSTOMER_MERGES m
     WHERE yt.CUST_ACCOUNT_ID = m.DUPLICATE_ID
     AND    m.process_flag = 'N'
     AND    m.request_id = req_id
     AND    m.set_number = set_num;

  l_last_fetch BOOLEAN;
  l_count NUMBER;
BEGIN
  /* init variables */
  l_last_fetch := FALSE;
  l_count := 0;

  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','PN_REC_ARCL_DTLLN',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    OPEN merged_records;

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
        EXIT;
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
          ) VALUES (
             HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'PN_REC_ARCL_DTLLN',
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

      END IF;

      FORALL I IN 1..MERGE_HEADER_ID_LIST.COUNT
        UPDATE PN_REC_ARCL_DTLLN yt SET
              CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
            , LAST_UPDATE_DATE=SYSDATE
            , last_updated_by=arp_standard.profile.user_id
            , last_update_login=arp_standard.profile.last_update_login
        WHERE AREA_CLASS_DTL_ID=PRIMARY_KEY_ID_LIST(I);

      l_count := l_count + MERGE_HEADER_ID_LIST.COUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;

    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'update_rec_arcl_dtln');
    RAISE;
END update_rec_arcl_dtln;

/*===========================================================================+
 | PROCEDURE
 |    update_rec_expcl_dtln
 |
 | DESCRIPTION
 |    Account merge procedure for the table, pn_rec_expcl_dtln
 |    Column updated        Corresponding HZ table.column
 |    --------------------  -----------------------------
 |    cust_account_id       HZ_CUST_ACCOUNTS.cust_account_id
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:  req_id, set_num, process_mode
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 | 29-apr-2004  Perl Script   Created
 | 29-apr-2004  Kiran         Finalised
 +===========================================================================*/

PROCEDURE update_rec_expcl_dtln (req_id       NUMBER,
                                 set_num      NUMBER,
                                 process_mode VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
  RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
  INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE EXP_CLS_LINE_ID_LIST_TYPE IS TABLE OF
  PN_REC_EXPCL_DTLLN.EXPENSE_CLASS_LINE_ID%TYPE
  INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST EXP_CLS_LINE_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
  PN_REC_EXPCL_DTLLN.CUST_ACCOUNT_ID%TYPE
  INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
    SELECT DISTINCT  m.CUSTOMER_MERGE_HEADER_ID
                    ,yt.EXPENSE_CLASS_LINE_ID
                    ,yt.CUST_ACCOUNT_ID
    FROM PN_REC_EXPCL_DTLLN yt
        ,RA_CUSTOMER_MERGES M
    WHERE yt.CUST_ACCOUNT_ID = m.DUPLICATE_ID
    AND    m.process_flag = 'N'
    AND    m.request_id = req_id
    AND    m.set_number = set_num;

  l_last_fetch BOOLEAN;
  l_count NUMBER;
BEGIN
  /* init variables */
  l_last_fetch := FALSE;
  l_count := 0;

  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','PN_REC_EXPCL_DTLLN',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    OPEN merged_records;

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
        EXIT;
      END IF;

      FOR I IN 1..MERGE_HEADER_ID_LIST.COUNT LOOP
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
          ) VALUES (
             HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'PN_REC_EXPCL_DTLLN',
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

      END IF;

      FORALL I IN 1..MERGE_HEADER_ID_LIST.COUNT
        UPDATE PN_REC_EXPCL_DTLLN yt SET
              CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
            , LAST_UPDATE_DATE=SYSDATE
            , last_updated_by=arp_standard.profile.user_id
            , last_update_login=arp_standard.profile.last_update_login
        WHERE EXPENSE_CLASS_LINE_ID=PRIMARY_KEY_ID_LIST(I);

      l_count := l_count + MERGE_HEADER_ID_LIST.COUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'update_rec_expcl_dtln');
    RAISE;
END update_rec_expcl_dtln;

/*===========================================================================+
 | PROCEDURE
 |    update_rec_period_lines
 |
 | DESCRIPTION
 |    Account merge procedure for the table, pn_rec_period_lines
 |    Column updated        Corresponding HZ table.column
 |    --------------------  -----------------------------
 |    cust_account_id       HZ_CUST_ACCOUNTS.cust_account_id
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:  req_id, set_num, process_mode
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 | 29-apr-2004  Perl Script   Created
 | 29-apr-2004  Kiran         Finalised
 +===========================================================================*/

PROCEDURE update_rec_period_lines (req_id       NUMBER,
                                   set_num      NUMBER,
                                   process_mode VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
  RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
  INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE REC_PERIOD_LINES_ID_LIST_TYPE IS TABLE OF
  PN_REC_PERIOD_LINES.REC_PERIOD_LINES_ID%TYPE
  INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST REC_PERIOD_LINES_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
  PN_REC_PERIOD_LINES.CUST_ACCOUNT_ID%TYPE
  INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
    SELECT DISTINCT  m.CUSTOMER_MERGE_HEADER_ID
                    ,yt.REC_PERIOD_LINES_ID
                    ,yt.CUST_ACCOUNT_ID
     FROM PN_REC_PERIOD_LINES yt
         ,RA_CUSTOMER_MERGES m
     WHERE yt.CUST_ACCOUNT_ID = m.DUPLICATE_ID
     AND    m.process_flag = 'N'
     AND    m.request_id = req_id
     AND    m.set_number = set_num;

  l_last_fetch BOOLEAN;
  l_count NUMBER;
BEGIN
  /* init variables */
  l_last_fetch := FALSE;
  l_count := 0;

  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','PN_REC_PERIOD_LINES',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    OPEN merged_records;

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
        EXIT;
      END IF;

      FOR I IN 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
      END LOOP;

      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I IN 1..MERGE_HEADER_ID_LIST.COUNT
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
             'PN_REC_PERIOD_LINES',
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

      END IF;

      FORALL I IN 1..MERGE_HEADER_ID_LIST.COUNT
        UPDATE PN_REC_PERIOD_LINES yt SET
              CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
            , LAST_UPDATE_DATE=SYSDATE
            , last_updated_by=arp_standard.profile.user_id
            , last_update_login=arp_standard.profile.last_update_login
        WHERE REC_PERIOD_LINES_ID=PRIMARY_KEY_ID_LIST(I);

      l_count := l_count + MERGE_HEADER_ID_LIST.COUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'update_rec_period_lines');
    RAISE;
END update_rec_period_lines;

/*===========================================================================+
 | PROCEDURE
 |    update_space_assign_cust
 |
 | DESCRIPTION
 |    Account merge procedure for the table, pn_space_assign_cust_all
 |    Column updated        Corresponding HZ table.column
 |    --------------------  -----------------------------
 |    cust_account_id       HZ_CUST_ACCOUNTS.cust_account_id
 |    site_use_id           HZ_CUST_SITE_USES.site_use_id
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN: req_id, set_num, process_mode
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 | 18-feb-2003  Perl Script   Created
 | 18-feb-2003  Kiran Hegde   Finalised
 +===========================================================================*/

PROCEDURE update_space_assign_cust (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
  RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
  INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE cust_space_assign_id_LIST_TYPE IS TABLE OF
  PN_SPACE_ASSIGN_CUST.cust_space_assign_id%TYPE
  INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST cust_space_assign_id_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
  PN_SPACE_ASSIGN_CUST.CUST_ACCOUNT_ID%TYPE
  INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  TYPE SITE_USE_ID_LIST_TYPE IS TABLE OF
  PN_SPACE_ASSIGN_CUST.SITE_USE_ID%TYPE
  INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST SITE_USE_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST SITE_USE_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
    SELECT DISTINCT
           m.CUSTOMER_MERGE_HEADER_ID
          ,yt.cust_space_assign_id
          ,yt.CUST_ACCOUNT_ID
          ,yt.SITE_USE_ID
     FROM PN_SPACE_ASSIGN_CUST yt
         ,RA_CUSTOMER_MERGES m
     WHERE ( yt.CUST_ACCOUNT_ID = m.DUPLICATE_ID
             OR yt.SITE_USE_ID = m.DUPLICATE_SITE_ID )
     AND    m.process_flag = 'N'
     AND    m.request_id = req_id
     AND    m.set_number = set_num;

  l_last_fetch BOOLEAN;
  l_count NUMBER;

BEGIN
  /* init variables */
  l_last_fetch := FALSE;
  l_count := 0;

  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    arp_message.set_name('AR','AR_UPDATING_TABLE');
    arp_message.set_token('TABLE_NAME','PN_SPACE_ASSIGN_CUST',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    OPEN merged_records;

    LOOP

      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
        ,PRIMARY_KEY_ID_LIST
        ,NUM_COL1_ORIG_LIST
        ,NUM_COL2_ORIG_LIST
      LIMIT 1000;

      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch THEN
        EXIT;
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
           ) VALUES (
             HZ_CUSTOMER_MERGE_LOG_s.NEXTVAL,
             'PN_SPACE_ASSIGN_CUST',
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

      FORALL I IN 1..MERGE_HEADER_ID_LIST.COUNT
        UPDATE PN_SPACE_ASSIGN_CUST yt SET
           CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
          ,SITE_USE_ID=NUM_COL2_NEW_LIST(I)
          ,LAST_UPDATE_DATE=SYSDATE
          ,last_updated_by=arp_standard.profile.user_id
          ,last_update_login=arp_standard.profile.last_update_login
        WHERE cust_space_assign_id=PRIMARY_KEY_ID_LIST(I);

      l_count := l_count + MERGE_HEADER_ID_LIST.COUNT;

      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'update_space_assign_cust');
    RAISE;
END update_space_assign_cust;

END PNP_CMERGE;

/
