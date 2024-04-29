--------------------------------------------------------
--  DDL for Package Body AR_MCC_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_MCC_MERGE" AS
/* $Header: ARXCMCRB.pls 120.0 2005/05/05 05:02:24 bdhotkar noship $ */
--+=======================================================================+
--|               Copyright (c) 2001 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     ARXCMCRB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Package body of AR_MCC_MERGE                                   |
--|                                                                       |
--| PUBLIC PROCEDURES                                                     |
--| Customer_Merge                                                        |
--| Note: This procedure will be called by the main Customer Merge(TCA)   |
--| feature                                                               |
--|                                                                       |
--| HISTORY                                                               |
--|     09/07/2001 apsndit        Created                                 |
--|                               Copied this file from OEXCMCRB.pls      |
--+======================================================================*/

--=================
-- CONSTANTS
--=================
G_AR_MCC_MERGE VARCHAR2(30) := 'AR_MCC_MERGE';

--====================
-- Debug log variables
--====================
g_log_level     NUMBER      := NULL;  -- 0 for manual test
g_log_mode      VARCHAR2(3) := 'OFF'; -- possible values: OFF, SQL, SRS

--=====================================
-- PRIVATE VARIABLES
--=====================================
  g_count               NUMBER := 0;

--========================================================================
-- PROCEDURE  : Log_Initialize   PRIVATE
-- COMMENT   : Initializes the log facility. It should be called from
--             the top level procedure of each concurrent program
--=======================================================================--
PROCEDURE Log_Initialize
IS
BEGIN
  g_log_level  := TO_NUMBER(FND_PROFILE.Value('AFLOG_LEVEL'));
  IF g_log_level IS NULL THEN
    g_log_mode := 'OFF';
  ELSE
/*Big Number3731144: Repalced FND_PROFILE.Value with  ARP_GLOBAL.request_id */
    IF ARP_GLOBAL.request_id IS NOT NULL THEN
      g_log_mode := 'SRS';
    ELSE
      g_log_mode := 'SQL';
    END IF;
  END IF;

END Log_Initialize;


--========================================================================
-- PROCEDURE : Log                        PRIVATE
-- PARAMETERS: p_level                IN  priority of the message - from
--                                        highest to lowest:
--                                          -- G_LOG_ERROR
--                                          -- G_LOG_EXCEPTION
--                                          -- G_LOG_EVENT
--                                          -- G_LOG_PROCEDURE
--                                          -- G_LOG_STATEMENT
--             p_msg                  IN  message to be print on the log
--                                        file
-- COMMENT   : Add an entry to the log
--========================================================================
PROCEDURE Log
( p_priority                    IN  NUMBER
, p_msg                         IN  VARCHAR2
)
IS
BEGIN
  IF ((g_log_mode <> 'OFF') AND (p_priority >= g_log_level))
  THEN
    IF g_log_mode = 'SQL'
    THEN
      -- SQL*Plus session: uncomment the next line during unit test
      -- DBMS_OUTPUT.put_line(p_msg);
      NULL;
    ELSE
      -- Concurrent request
      FND_FILE.put_line
      ( FND_FILE.log
      , p_msg
      );
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END Log;

--=========================================================================
-- PROCEDURE : Customer_merge      PUBLIC
-- PARAMETERS: req_id          IN  NUMBER    Concurrent process request id
--             set_number      IN  NUMBER    Set Number
--             process_mode    IN  VARCHAR2  Process mode of the called
--                                           program
-- COMMENT   : This procedure deletes the records from the table
--             HZ_CREDIT_USAGES for the corresponding customer Ids in
--             RA_CUSTOMER_MERGES
--=========================================================================
PROCEDURE  Customer_Merge
( req_id       IN NUMBER
 ,set_number   IN NUMBER
 ,process_mode IN VARCHAR2
) IS

-- Cursor to get the customer account being merged
-- duplicate_id is the Id identifying the customer account that is
-- being merged
-- for a given request id, more than one customer account can exist
-- for a given set number, more than one customer account can exist
-- for a combination of request id and set number, more than one customer
-- account can exist. Verified from Gautam Prothia,dev mgr, TCA.
CURSOR customer_account_dup_cur IS
  SELECT
    DISTINCT duplicate_id
  FROM
    RA_CUSTOMER_MERGES
  WHERE process_flag = 'N'
    AND request_id = req_id
    AND set_number = set_number;

-- Cursor to get the customer merge header id for the customer account
-- that is being merged
CURSOR customer_merge_header_cur(c_duplicate_id ra_customer_merges.duplicate_id%TYPE)
IS
  SELECT
    customer_merge_header_id
  FROM
    RA_CUSTOMER_MERGES
  WHERE duplicate_id = c_duplicate_id;


-- cursor to lock the rows in hz_credit_usages
CURSOR check_credit_usage_cur IS
  SELECT credit_usage_id
  FROM
    HZ_CREDIT_USAGES
  WHERE cust_acct_profile_amt_id IN
        (SELECT cust_acct_profile_amt_id
         FROM   HZ_CUST_PROFILE_AMTS
         WHERE  cust_account_id IN
                (SELECT DISTINCT duplicate_id
                 FROM   RA_CUSTOMER_MERGES
                 WHERE  process_flag = 'N'
                   AND  request_id = req_id
                   AND  set_number = set_number))
  FOR UPDATE OF credit_usage_id NOWAIT;

-- ====================================
-- Variables for BULK COLLECT operation
-- ====================================
TYPE credit_usage_tab IS TABLE OF
  hz_credit_usages.credit_usage_id%TYPE;

TYPE credit_profile_amt_tab IS TABLE OF
  hz_credit_usages.credit_profile_amt_id%TYPE;

TYPE cust_acct_profile_amt_tab IS TABLE OF
  hz_credit_usages.cust_acct_profile_amt_id%TYPE;

TYPE profile_class_amount_tab IS TABLE OF
  hz_credit_usages.profile_class_amount_id%TYPE;

TYPE credit_usage_rule_set_tab IS TABLE OF
  hz_credit_usages.credit_usage_rule_set_id%TYPE;


l_credit_usage_ids            credit_usage_tab;
l_credit_profile_amt_ids      credit_profile_amt_tab;
l_cust_acct_profile_amt_ids   cust_acct_profile_amt_tab;
l_profile_class_amount_ids    profile_class_amount_tab;
l_credit_usage_rule_set_ids   credit_usage_rule_set_tab;

-- index variables
l_min_usage_idx               BINARY_INTEGER;
l_max_usage_idx               BINARY_INTEGER;

--=================
-- LOCAL VARIABLES
--================
l_duplicate_id             RA_CUSTOMER_MERGES.duplicate_id%TYPE;
l_customer_merge_header_id RA_CUSTOMER_MERGES.customer_merge_header_id%TYPE;
l_total_count NUMBER;
-- variable to store the account merge profile option value
l_audit_acct_merge_flag VARCHAR2(3) := FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');
-- Delete flag
l_delete_flag VARCHAR2(1);


-- initialize maximum batch size
l_max_batch_size NUMBER := 1000;

-- error text variables
l_errorcode  NUMBER;
l_errortext  VARCHAR2(200);

BEGIN

  -- initialize log
  AR_MCC_MERGE.Log_Initialize;

  -- initialize the message stack
  FND_MSG_PUB.Initialize;

  arp_message.set_line('AR_MCC_MERGE.Customer_Merge()+');

   AR_MCC_MERGE.Log
      (AR_MCC_MERGE.G_LOG_PROCEDURE
         ,'Start of Proc:Customer Merge'
      );

  IF process_mode = 'LOCK' THEN
    arp_message.set_name('AR', 'AR_LOCKING_TABLE');
    arp_message.set_token('TABLE_NAME', 'HZ_CREDIT_USAGES', FALSE);

    open  check_credit_usage_cur;
    close check_credit_usage_cur;

    AR_MCC_MERGE.Log
                (AR_MCC_MERGE.G_LOG_EVENT
                 ,'Rows locked from HZ_CREDIT_USAGES'
                );
  ELSE
    arp_message.set_line('AR_MCC_MERGE.Customer_Merge()+');

    -- Get each customer account being merged
    FOR cust_dup IN customer_account_dup_cur LOOP

      l_duplicate_id := cust_dup.duplicate_id;
      AR_MCC_MERGE.Log
        (AR_MCC_MERGE.G_LOG_EVENT
           ,'Customer Account Id:' || to_char(l_duplicate_id)
        );

        -- Get Customer Merge Header Id
        OPEN customer_merge_header_cur(l_duplicate_id);

        FETCH customer_merge_header_cur
         INTO l_customer_merge_header_id;

        CLOSE customer_merge_header_cur;

      AR_MCC_MERGE.Log
        (AR_MCC_MERGE.G_LOG_EVENT
           ,'Customer Merge Header Id:' || to_char(l_customer_merge_header_id)
        );

        -- Select statement to get the columns of the credit usage belongs
        -- to customer account being merged
        -- These column values are used to store in the LOG table
        SELECT
          credit_usage_id
        , credit_profile_amt_id
        , cust_acct_profile_amt_id
        , profile_class_amount_id
        , credit_usage_rule_set_id
        BULK COLLECT INTO
          l_credit_usage_ids
        , l_credit_profile_amt_ids
        , l_cust_acct_profile_amt_ids
        , l_profile_class_amount_ids
        , l_credit_usage_rule_set_ids
        FROM  HZ_CREDIT_USAGES
        WHERE  cust_acct_profile_amt_id IN
               (SELECT cust_acct_profile_amt_id
                FROM   HZ_CUST_PROFILE_AMTS
                WHERE  cust_account_id = l_duplicate_id );

        IF SQL%FOUND THEN
          -- set the delete flag
          l_delete_flag := 'Y';
          -- intialize the index variables
          l_min_usage_idx := l_credit_usage_ids.FIRST;
          l_max_usage_idx := l_credit_usage_ids.LAST;
        ELSE
          l_delete_flag := 'N';
        END IF;

      AR_MCC_MERGE.Log
        (AR_MCC_MERGE.G_LOG_EVENT
           ,'Credit Usage Delete Flag:' || (l_delete_flag)
        );

      -- check audit account merge profile is enabled
      -- if the profile is enabled, then the value being deleted to
      -- be inserted into the LOG table
      IF l_audit_acct_merge_flag = 'ON' THEN
        IF l_delete_flag = 'Y' THEN
          FORALL l_usage_idx  IN l_min_usage_idx .. l_max_usage_idx
            INSERT INTO hz_customer_merge_log
            ( merge_log_id
            , table_name
            , merge_header_id
            , primary_key_id
            , del_col1
            , del_col2
            , del_col3
            , del_col4
            , action_flag
            , request_id
            , created_by
            , creation_date
            , last_update_login
            , last_update_date
            , last_updated_by
            )
            VALUES
            ( HZ_CUSTOMER_MERGE_LOG_S.nextval
            , 'HZ_CREDIT_USAGES'
            , l_customer_merge_header_id
            , l_credit_usage_ids(l_usage_idx)
            , l_credit_profile_amt_ids(l_usage_idx)
            , l_cust_acct_profile_amt_ids(l_usage_idx)
            , l_profile_class_amount_ids(l_usage_idx)
            , l_credit_usage_rule_set_ids(l_usage_idx)
            , 'D'
            , req_id
            , hz_utility_pub.created_by
            , hz_utility_pub.creation_date
            , hz_utility_pub.last_update_login
            , hz_utility_pub.last_update_date
            , hz_utility_pub.last_updated_by
            );

          AR_MCC_MERGE.Log
            (AR_MCC_MERGE.G_LOG_EVENT
              ,'Records inserted in LOG table'
            );

        END IF; -- delete flag check

      END IF; -- account merge audit profile

        -- delete only when the records exists
        IF l_delete_flag = 'Y' THEN
          -- Delete the records in full
          FORALL l_usage_idx  IN l_min_usage_idx .. l_max_usage_idx
            DELETE
              FROM  HZ_CREDIT_USAGES
             WHERE  credit_usage_id = l_credit_usage_ids(l_usage_idx);

          -- number of rows deleted
          -- summation of all %bulk_rowcount
          g_count := sql%rowcount;
          l_total_count := g_count;

          AR_MCC_MERGE.Log
                      (AR_MCC_MERGE.G_LOG_EVENT
                      ,'Total rows deleted: ' || to_char(l_total_count)
                      );

          -- Total number of rows deleted
          arp_message.set_name('AR', 'AR_ROWS_DELETED');
          arp_message.set_token('NUM_ROWS', to_char(l_total_count));

       END IF; -- delete flag check

    END LOOP; -- customer account loop

  END IF; -- check for process mode

  arp_message.set_line('AR_MCC_MERGE.Customer_Merge()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_error('AR_MCC_MERGE.Customer_Merge');
    l_errorcode := SQLCODE;
    l_errortext := SUBSTR(SQLERRM, 1,200);
    AR_MCC_MERGE.Log
      (AR_MCC_MERGE.G_LOG_EXCEPTION
       ,'Others:' || to_char(l_errorcode) || l_errortext
      );
    raise;

END Customer_Merge;



END AR_MCC_MERGE;

/
