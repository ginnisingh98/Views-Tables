--------------------------------------------------------
--  DDL for Package Body LNS_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_MERGE_PKG" as
/* $Header: LNS_MERGE_B.pls 120.0.12010000.2 2009/02/03 15:21:07 mbolli ship $ */


/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
    G_PKG_NAME                      CONSTANT VARCHAR2(30):= 'LNS_MERGE_PKG';
    G_LOG_ENABLED                   varchar2(5);
    G_MSG_LEVEL                     NUMBER;

/*========================================================================
 | PRIVATE PROCEDURE LogMessage
 |
 | DESCRIPTION
 |      This procedure logs debug messages to db and to CM log
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      MERGE_LOAN_HEADERS_ACC
 |      MERGE_PARTICIPANTS_ACC
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      p_msg_level     IN      Debug msg level
 |      p_msg           IN      Debug msg itself
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-01-2009            mbolli            Created
 |
 *=======================================================================*/
Procedure LogMessage(p_msg_level IN NUMBER, p_msg in varchar2)
IS
BEGIN
    if (p_msg_level >= G_MSG_LEVEL) then

        FND_LOG.STRING(p_msg_level, G_PKG_NAME, p_msg);
        if FND_GLOBAL.Conc_Request_Id is not null then
            fnd_file.put_line(FND_FILE.LOG, p_msg);
        end if;

    end if;

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: ' || sqlerrm);
END;


/*========================================================================
 | PRIVATE PROCEDURE init
 |
 | DESCRIPTION
 |      This procedure inits data needed for processing
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      MERGE_LOAN_HEADERS_ACC
 |      MERGE_PARTICIPANTS_ACC
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      LogMessage
 |
 | PARAMETERS
 |      None
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 13-01-2009            mbolli            Created
 |
 *=======================================================================*/
Procedure init
IS
    l_api_name                      CONSTANT VARCHAR2(30) := 'INIT';
    l_org_status                    varchar2(1);
BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    /* getting msg logging info */
    G_LOG_ENABLED := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');
    G_MSG_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_LOG_ENABLED: ' || G_LOG_ENABLED);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_MSG_LEVEL: ' || G_MSG_LEVEL);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

END;



PROCEDURE MERGE_LOAN_HEADERS(p_entity_name    IN VARCHAR2,
                            p_from_id        IN NUMBER,
                            p_to_id          IN OUT NOCOPY NUMBER,
                            p_from_fk_id     IN NUMBER,
                            p_to_fk_id       IN NUMBER,
                            p_parent_entity  IN VARCHAR2,
                            p_batch_id       IN NUMBER,
                            p_batch_party_id IN NUMBER,
                            x_return_status  OUT NOCOPY VARCHAR2)
IS
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*
        If the Parent has NOT changed(i.e. Parent getting transferred)
        then nothing needs to be done. Set Merged To Id is same as Merged From Id
        and return
    */

    IF p_from_FK_id = p_to_FK_id  THEN
        p_to_id := p_from_id;
        RETURN;
    END IF;

    /*
        If the Parent has changed(i.e. Parent is getting merged),
        then transfer the dependent record to the new parent.
        Before transferring check if a similar dependent record exists on the new parent.
        If a duplicate exists then do not transfer and return the id of the duplicate record as the Merged To Id.
    */

    /* updating PRIMARY_BORROWER_ID column */
    UPDATE LNS_LOAN_HEADERS_ALL
    SET PRIMARY_BORROWER_ID    = p_To_FK_id,
        last_update_date       = HZ_UTILITY_V2PUB.last_update_date,
        last_updated_by        = HZ_UTILITY_V2PUB.user_id,
        last_update_login      = HZ_UTILITY_V2PUB.last_update_login,
        request_id             = HZ_UTILITY_V2PUB.request_id,
        program_id             = HZ_UTILITY_V2PUB.program_id
    WHERE PRIMARY_BORROWER_ID = p_from_fk_id;

    /* updating CONTACT_PERS_PARTY_ID column */
    UPDATE LNS_LOAN_HEADERS_ALL
    SET CONTACT_PERS_PARTY_ID  = p_To_FK_id,
        last_update_date       = HZ_UTILITY_V2PUB.last_update_date,
        last_updated_by        = HZ_UTILITY_V2PUB.user_id,
        last_update_login      = HZ_UTILITY_V2PUB.last_update_login,
        request_id             = HZ_UTILITY_V2PUB.request_id,
        program_id             = HZ_UTILITY_V2PUB.program_id
    WHERE CONTACT_PERS_PARTY_ID = p_from_fk_id;

    /* updating CONTACT_REL_PARTY_ID column */
    UPDATE LNS_LOAN_HEADERS_ALL
    SET CONTACT_REL_PARTY_ID   = p_To_FK_id,
        last_update_date       = HZ_UTILITY_V2PUB.last_update_date,
        last_updated_by        = HZ_UTILITY_V2PUB.user_id,
        last_update_login      = HZ_UTILITY_V2PUB.last_update_login,
        request_id             = HZ_UTILITY_V2PUB.request_id,
        program_id             = HZ_UTILITY_V2PUB.program_id
    WHERE CONTACT_REL_PARTY_ID = p_from_fk_id;

    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END MERGE_LOAN_HEADERS;



PROCEDURE MERGE_PARTICIPANTS(p_entity_name    IN VARCHAR2,
                            p_from_id        IN NUMBER,
                            p_to_id          IN OUT NOCOPY NUMBER,
                            p_from_fk_id     IN NUMBER,
                            p_to_fk_id       IN NUMBER,
                            p_parent_entity  IN VARCHAR2,
                            p_batch_id       IN NUMBER,
                            p_batch_party_id IN NUMBER,
                            x_return_status  OUT NOCOPY VARCHAR2)
IS
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*
        If the Parent has NOT changed(i.e. Parent getting transferred)
        then nothing needs to be done. Set Merged To Id is same as Merged From Id
        and return
    */

    IF p_from_FK_id = p_to_FK_id  THEN
        p_to_id := p_from_id;
        RETURN;
    END IF;

    /*
        If the Parent has changed(i.e. Parent is getting merged),
        then transfer the dependent record to the new parent.
        Before transferring check if a similar dependent record exists on the new parent.
        If a duplicate exists then do not transfer and return the id of the duplicate record as the Merged To Id.
    */

    /* updating HZ_PARTY_ID column */
    UPDATE LNS_PARTICIPANTS
    SET HZ_PARTY_ID            = p_To_FK_id,
        last_update_date       = HZ_UTILITY_V2PUB.last_update_date,
        last_updated_by        = HZ_UTILITY_V2PUB.user_id,
        last_update_login      = HZ_UTILITY_V2PUB.last_update_login
    WHERE HZ_PARTY_ID = p_from_fk_id;

    /* updating CONTACT_PERS_PARTY_ID column */
    UPDATE LNS_PARTICIPANTS
    SET CONTACT_PERS_PARTY_ID  = p_To_FK_id,
        last_update_date       = HZ_UTILITY_V2PUB.last_update_date,
        last_updated_by        = HZ_UTILITY_V2PUB.user_id,
        last_update_login      = HZ_UTILITY_V2PUB.last_update_login
    WHERE CONTACT_PERS_PARTY_ID = p_from_fk_id;

    /* updating CONTACT_REL_PARTY_ID column */
    UPDATE LNS_PARTICIPANTS
    SET CONTACT_REL_PARTY_ID   = p_To_FK_id,
        last_update_date       = HZ_UTILITY_V2PUB.last_update_date,
        last_updated_by        = HZ_UTILITY_V2PUB.user_id,
        last_update_login      = HZ_UTILITY_V2PUB.last_update_login
    WHERE CONTACT_REL_PARTY_ID = p_from_fk_id;

    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END MERGE_PARTICIPANTS;



PROCEDURE MERGE_LOAN_HEADERS_ACC (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2)
IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE LOAN_ID_LIST_TYPE IS TABLE OF
         LNS_LOAN_HEADERS.LOAN_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST LOAN_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
         LNS_LOAN_HEADERS.CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;

  TYPE CUST_ACCT_SITE_ID_LIST_TYPE IS TABLE OF
         LNS_LOAN_HEADERS.BILL_TO_ACCT_SITE_ID%TYPE
        INDEX BY BINARY_INTEGER;

  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL2_ORIG_LIST CUST_ACCT_SITE_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST CUST_ACCT_SITE_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,LOAN_ID
              ,CUST_ACCOUNT_ID
         FROM LNS_LOAN_HEADERS yt, ra_customer_merges m
         WHERE
            (yt.CUST_ACCOUNT_ID = m.DUPLICATE_ID)
            AND    m.process_flag = 'N'
            AND    m.request_id = req_id
            AND    m.set_number = set_num;

  CURSOR merged_records2 IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,LOAN_ID
              ,CUSTOMER_ADDRESS_ID
         FROM LNS_LOAN_HEADERS yt, ra_customer_merges m
         WHERE
            (yt.BILL_TO_ACCT_SITE_ID = m.DUPLICATE_ADDRESS_ID)
            AND    m.process_flag = 'N'
            AND    m.request_id = req_id
            AND    m.set_number = set_num;

  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
  l_api_name   CONSTANT VARCHAR2(30) := 'MERGE_LOAN_HEADERS_ACC';

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' BEGIN +');
    LogMessage(FND_LOG.LEVEL_STATEMENT,'Input parameters:');
    LogMessage(FND_LOG.LEVEL_STATEMENT,'req_id = ' || req_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT,'set_num = ' || set_num);
    LogMessage(FND_LOG.LEVEL_STATEMENT,'process_mode = ' || process_mode );

  IF process_mode='LOCK' THEN
    NULL;
  ELSE

    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','LNS_LOAN_HEADERS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');


    LogMessage(FND_LOG.LEVEL_STATEMENT,'Searching for ACCOUNT records...');

    /* merging cust_account_id */
    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID1_LIST
          , NUM_COL1_ORIG_LIST;

      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
	LogMessage(FND_LOG.LEVEL_STATEMENT,'Exiting fetch');
        exit;
      END IF;

      LogMessage(FND_LOG.LEVEL_PROCEDURE,'Fetched ' || MERGE_HEADER_ID_LIST.COUNT || ' records');

      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
      END LOOP;

      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	LogMessage(FND_LOG.LEVEL_STATEMENT,'Inserting into HZ_CUSTOMER_MERGE_LOG...');

        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
            MERGE_LOG_ID,
            TABLE_NAME,
            MERGE_HEADER_ID,
            PRIMARY_KEY_ID1,
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
            'LNS_LOAN_HEADERS',
            MERGE_HEADER_ID_LIST(I),
            PRIMARY_KEY_ID1_LIST(I),
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

      LogMessage(FND_LOG.LEVEL_STATEMENT,'Insertion Completed');

      	LogMessage(FND_LOG.LEVEL_STATEMENT,'Updating LNS_LOAN_HEADERS Table ...');

      FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE LNS_LOAN_HEADERS yt SET
           CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_ID=arp_standard.profile.program_id
      WHERE LOAN_ID=PRIMARY_KEY_ID1_LIST(I);

      l_count := l_count + SQL%ROWCOUNT;

      LogMessage(FND_LOG.LEVEL_STATEMENT,'Updation Completed');

      IF l_last_fetch THEN
         EXIT;
      END IF;

    END LOOP;
    LogMessage(FND_LOG.LEVEL_STATEMENT,'Total processed ' || l_count || ' ACCOUNT  records');
    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));

      <<bill_to_acct_site_id>>
    /* merging CUST_ACCT_SITE_ID */

    MERGE_HEADER_ID_LIST.delete;
    PRIMARY_KEY_ID1_LIST.delete;
    l_count := 0;
    l_last_fetch := FALSE;

    LogMessage(FND_LOG.LEVEL_STATEMENT,'Searching for CUST_ACCT_SITE_ID  records...');

    open merged_records2;
    LOOP
      FETCH merged_records2 BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID1_LIST
          , NUM_COL2_ORIG_LIST;

    LogMessage(FND_LOG.LEVEL_STATEMENT,'Fetched ' || MERGE_HEADER_ID_LIST.COUNT || ' records');

      IF merged_records2%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
	LogMessage(FND_LOG.LEVEL_STATEMENT,'Exiting fetch of  CustActSites');
        exit;
      END IF;

      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL2_ORIG_LIST(I));
      END LOOP;

      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	LogMessage(FND_LOG.LEVEL_STATEMENT,'Inserting CustActSites into HZ_CUSTOMER_MERGE_LOG...');

        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
            MERGE_LOG_ID,
            TABLE_NAME,
            MERGE_HEADER_ID,
            PRIMARY_KEY_ID1,
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
            'LNS_LOAN_HEADERS',
            MERGE_HEADER_ID_LIST(I),
            PRIMARY_KEY_ID1_LIST(I),
            NUM_COL2_ORIG_LIST(I),
            NUM_COL2_NEW_LIST(I),
            'U',
            req_id,
            hz_utility_pub.CREATED_BY,
            hz_utility_pub.CREATION_DATE,
            hz_utility_pub.LAST_UPDATE_LOGIN,
            hz_utility_pub.LAST_UPDATE_DATE,
            hz_utility_pub.LAST_UPDATED_BY);

      END IF;

      LogMessage(FND_LOG.LEVEL_STATEMENT,'Insertion of custAcctSites Completed');

      LogMessage(FND_LOG.LEVEL_STATEMENT,'Updating custAcctSites in LNS_LOAN_HEADERS Table ...');

      FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE LNS_LOAN_HEADERS yt SET
           BILL_TO_ACCT_SITE_ID=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_ID=arp_standard.profile.program_id
      WHERE LOAN_ID=PRIMARY_KEY_ID1_LIST(I);

      l_count := l_count + SQL%ROWCOUNT;

      LogMessage(FND_LOG.LEVEL_STATEMENT,'Updation of custAcctSites Completed');

      IF l_last_fetch THEN
         EXIT;
      END IF;

    END LOOP;
    LogMessage(FND_LOG.LEVEL_STATEMENT,'Total processed ' || l_count || ' CUST_ACCT_SITES  records');
    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));

  END IF;

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' END -');

EXCEPTION
  WHEN OTHERS THEN
    LogMessage(FND_LOG.LEVEL_PROCEDURE,  G_PKG_NAME || '.' || l_api_name || ' EXCEPTION');
    arp_message.set_line( 'MERGE_LOAN_HEADERS_ACC');
    RAISE;
END MERGE_LOAN_HEADERS_ACC;


PROCEDURE MERGE_PARTICIPANTS_ACC (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2)
IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE PARTICIPANT_ID_LIST_TYPE IS TABLE OF
         LNS_PARTICIPANTS.PARTICIPANT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID1_LIST PARTICIPANT_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
         LNS_PARTICIPANTS.CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;

  TYPE CUST_ACCT_SITE_ID_LIST_TYPE IS TABLE OF
         LNS_LOAN_HEADERS.BILL_TO_ACCT_SITE_ID%TYPE
        INDEX BY BINARY_INTEGER;

  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL2_ORIG_LIST CUST_ACCT_SITE_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST CUST_ACCT_SITE_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,PARTICIPANT_ID
              ,CUST_ACCOUNT_ID
         FROM LNS_PARTICIPANTS yt, ra_customer_merges m
         WHERE (
            yt.CUST_ACCOUNT_ID = m.DUPLICATE_ID
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;

  CURSOR merged_records2 IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,PARTICIPANT_ID
              ,CUSTOMER_ADDRESS_ID
         FROM LNS_PARTICIPANTS yt, ra_customer_merges m
         WHERE
            (yt.BILL_TO_ACCT_SITE_ID = m.DUPLICATE_ADDRESS_ID)
            AND    m.process_flag = 'N'
            AND    m.request_id = req_id
            AND    m.set_number = set_num;

  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
  l_api_name   CONSTANT VARCHAR2(30) := 'MERGE_PARTICIPANTS_ACC';

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' BEGIN +');
    LogMessage(FND_LOG.LEVEL_STATEMENT,'Input parameters:');
    LogMessage(FND_LOG.LEVEL_STATEMENT,'req_id = ' || req_id);
    LogMessage(FND_LOG.LEVEL_STATEMENT,'set_num = ' || set_num);
    LogMessage(FND_LOG.LEVEL_STATEMENT,'process_mode = ' || process_mode );

  IF process_mode='LOCK' THEN
    NULL;

  ELSE

    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','LNS_PARTICIPANTS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    LogMessage(FND_LOG.LEVEL_STATEMENT,'Searching for ACCOUNT records...');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID1_LIST
          , NUM_COL1_ORIG_LIST;

      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        LogMessage(FND_LOG.LEVEL_STATEMENT,'Exiting fetch');
        exit;
      END IF;

      LogMessage(FND_LOG.LEVEL_PROCEDURE,'Fetched ' || MERGE_HEADER_ID_LIST.COUNT || ' records');

      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
      END LOOP;

      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	LogMessage(FND_LOG.LEVEL_STATEMENT,'Inserting into HZ_CUSTOMER_MERGE_LOG...');

        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
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
            'LNS_PARTICIPANTS',
            MERGE_HEADER_ID_LIST(I),
            PRIMARY_KEY_ID1_LIST(I),
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

      LogMessage(FND_LOG.LEVEL_STATEMENT,'Insertion Completed');

      LogMessage(FND_LOG.LEVEL_STATEMENT,'Updating LNS_LOAN_HEADERS Table ...');


      FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE LNS_PARTICIPANTS yt SET
           CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE PARTICIPANT_ID=PRIMARY_KEY_ID1_LIST(I);

      l_count := l_count + SQL%ROWCOUNT;

      LogMessage(FND_LOG.LEVEL_STATEMENT,'Updation Completed');

      IF l_last_fetch THEN
         EXIT;
      END IF;

    END LOOP;
    LogMessage(FND_LOG.LEVEL_STATEMENT,'Total processed ' || l_count || ' ACCOUNT  records');
    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));


      <<bill_to_acct_site_id>>
    /* merging CUST_ACCT_SITE_ID */

    MERGE_HEADER_ID_LIST.delete;
    PRIMARY_KEY_ID1_LIST.delete;
    l_count := 0;
    l_last_fetch := FALSE;

    LogMessage(FND_LOG.LEVEL_STATEMENT,'Searching for CUST_ACCT_SITE_ID  records...');

    open merged_records2;
    LOOP
      FETCH merged_records2 BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID1_LIST
          , NUM_COL2_ORIG_LIST;

    LogMessage(FND_LOG.LEVEL_STATEMENT,'Fetched ' || MERGE_HEADER_ID_LIST.COUNT || ' records');

      IF merged_records2%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
	LogMessage(FND_LOG.LEVEL_STATEMENT,'Exiting fetch of  CustActSites');
        exit;
      END IF;

      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE(NUM_COL2_ORIG_LIST(I));
      END LOOP;

      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	LogMessage(FND_LOG.LEVEL_STATEMENT,'Inserting CustActSites into HZ_CUSTOMER_MERGE_LOG...');

        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
            MERGE_LOG_ID,
            TABLE_NAME,
            MERGE_HEADER_ID,
            PRIMARY_KEY_ID1,
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
            'LNS_PARTICIPANTS',
            MERGE_HEADER_ID_LIST(I),
            PRIMARY_KEY_ID1_LIST(I),
            NUM_COL2_ORIG_LIST(I),
            NUM_COL2_NEW_LIST(I),
            'U',
            req_id,
            hz_utility_pub.CREATED_BY,
            hz_utility_pub.CREATION_DATE,
            hz_utility_pub.LAST_UPDATE_LOGIN,
            hz_utility_pub.LAST_UPDATE_DATE,
            hz_utility_pub.LAST_UPDATED_BY);

      END IF;

      LogMessage(FND_LOG.LEVEL_STATEMENT,'Insertion of custAcctSites Completed');

      LogMessage(FND_LOG.LEVEL_STATEMENT,'Updating custAcctSites in LNS_LOAN_HEADERS Table ...');

      FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE LNS_PARTICIPANTS yt SET
           BILL_TO_ACCT_SITE_ID=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE PARTICIPANT_ID=PRIMARY_KEY_ID1_LIST(I);

      l_count := l_count + SQL%ROWCOUNT;

      LogMessage(FND_LOG.LEVEL_STATEMENT,'Updation of custAcctSites Completed');

      IF l_last_fetch THEN
         EXIT;
      END IF;

    END LOOP;
    LogMessage(FND_LOG.LEVEL_STATEMENT,'Total processed ' || l_count || ' CUST_ACCT_SITES  records');
    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));

  END IF;

  LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' END -');

EXCEPTION
  WHEN OTHERS THEN
    LogMessage(FND_LOG.LEVEL_PROCEDURE,  G_PKG_NAME || '.' || l_api_name || ' EXCEPTION');
    arp_message.set_line( 'MERGE_PARTICIPANTS_ACC');
    RAISE;
END MERGE_PARTICIPANTS_ACC;


END LNS_MERGE_PKG;

/
