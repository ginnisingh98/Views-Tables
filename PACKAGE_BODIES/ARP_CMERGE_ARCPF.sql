--------------------------------------------------------
--  DDL for Package Body ARP_CMERGE_ARCPF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CMERGE_ARCPF" as
/* $Header: ARPLCPFB.pls 120.3.12010000.2 2009/01/27 10:36:37 vsegu ship $ */

g_count		                  NUMBER := 0;

--merge ar_credit_histories
procedure ar_ch (
        req_id             NUMBER,
        set_num            NUMBER,
        process_mode       VARCHAR2
);

--merge hz_customer_profiles
procedure ar_cp (
        req_id             NUMBER,
        set_num            NUMBER,
        process_mode       VARCHAR2
);

--merge hz_customer_profile_amts
procedure ar_cpa (
        req_id             NUMBER,
        set_num            NUMBER,
        process_mode       VARCHAR2
);

/*===========================================================================+
 | PROCEDURE
 |              merge
 |
 | DESCRIPTION
 |              main merge routine.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |                    process_mod
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  20-DEC-00  Bug 1535542: ar_ch procedure works only in
 |                        delete mode. Move the call to 'delete_rows'.
 |
 +===========================================================================*/

PROCEDURE merge (
          req_id               NUMBER,
          set_num              NUMBER,
          process_mode         VARCHAR2
) IS

BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCPF.MERGE()+' );

    --merge hz_customer_profiles
    ar_cp( req_id, set_num, process_mode );

    --merge hz_customer_profile_amts
    ar_cpa( req_id, set_num, process_mode );

    arp_message.set_line( 'ARP_CMERGE_ARCPF.MERGE()-' );

END merge;

/*===========================================================================+
 | PROCEDURE
 |              ar_ch
 |
 | DESCRIPTION
 |              merge in AR_CREDIT_HISTORIES
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |                    process_mod
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  20-DEC-00  Bug 1535542: ar_ch procedure works only in
 |                        delete mode. Move the call to 'delete_rows'.
 |     Jianying Huang  09-APR-00  Bug 1725662: Modified 'ar_ch' to use index.
 |
 +===========================================================================*/

PROCEDURE ar_ch (
          req_id                      NUMBER,
          set_num                     NUMBER,
          process_mode                VARCHAR2
) IS

    CURSOR c1 is
       SELECT CREDIT_HISTORY_ID
       FROM AR_CREDIT_HISTORIES yt, ra_customer_merges m
       WHERE yt.customer_id = m.duplicate_id
       AND   yt.site_use_id = m.duplicate_site_id
       AND   m.process_flag = 'N'
       AND   m.request_id = req_id
       AND   m.set_number = set_num
       AND   m.delete_duplicate_flag = 'Y'
       FOR UPDATE NOWAIT;

    CURSOR c2 is
       SELECT CREDIT_HISTORY_ID
       FROM AR_CREDIT_HISTORIES yt, ra_customer_merges m
       WHERE yt.customer_id = m.duplicate_id
       AND   m.process_flag = 'N'
       AND   m.request_id = req_id
       AND   m.set_number = set_num
       AND   m.delete_duplicate_flag = 'Y'
       AND   site_use_id IS NULL
       AND   NOT EXISTS (
                 SELECT 'accounts exist'
                 FROM   hz_cust_accounts acct
                 WHERE  acct.cust_account_id = yt.customer_id
                 AND    acct.status <> 'D' )
       FOR UPDATE NOWAIT;

BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCPF.AR_CH()+' );

    --delete only if delete = 'Y', otherwise leave in as historical data
    --lock table
    OPEN c1;
    CLOSE c1;

    OPEN c2;
    CLOSE c2;

    --site level delete

    arp_message.set_name( 'AR', 'AR_DELETING_TABLE' );
    arp_message.set_token( 'TABLE_NAME', 'AR_CREDIT_HISTORIES', FALSE );

--Bug 1725662: Modified 'ar_ch' to use index.

    DELETE FROM AR_CREDIT_HISTORIES yt
    WHERE (customer_id, site_use_id) IN (
               SELECT m.duplicate_id, m.duplicate_site_id
               FROM   ra_customer_merges m
               WHERE  m.process_flag = 'N'
               AND    m.request_id = req_id
               AND    m.set_number = set_num
               AND  m.delete_duplicate_flag = 'Y');

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_DELETED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    --customer level delete

    arp_message.set_name( 'AR', 'AR_DELETING_TABLE' );
    arp_message.set_token( 'TABLE_NAME', 'AR_CREDIT_HISTORIES', FALSE );

    DELETE FROM AR_CREDIT_HISTORIES yt
    WHERE customer_id IN (
             SELECT m.duplicate_id
             FROM   ra_customer_merges m
             WHERE  m.process_flag = 'N'
             AND    m.request_id = req_id
             AND    m.set_number = set_num
             AND    m.delete_duplicate_flag = 'Y' )
    AND   site_use_id IS NULL
    AND   NOT EXISTS (
             SELECT 'accounts exist'
             FROM   hz_cust_accounts acct
             WHERE  acct.cust_account_id = yt.customer_id
             AND    acct.status <> 'D' );

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_DELETED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_line( 'ARP_CMERGE_ARCPF.AR_CH()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCPF.AR_CH');
      RAISE;

END ar_ch;

/*===========================================================================+
 | PROCEDURE
 |              ar_cp
 |
 | DESCRIPTION
 |              merge in HZ_CUSTOMER_PROFILES
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |                    process_mod
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  20-DEC-00  Bug 1535542: Since we need to change
 |                        the merging order, merge HZ tables before merging
 |                        products, we need to mark deleted rows here
 |                        first and physically delete them after merging one
 |                        set in 'delete_rows'.
 |
 +===========================================================================*/

PROCEDURE ar_cp (
          req_id                        NUMBER,
          set_num                       NUMBER,
          process_mode                  VARCHAR2
) IS

    --cursor c1 and c2 work in inactive mode.
    CURSOR c1 is
       SELECT cust_account_profile_id
       FROM hz_customer_profiles, ra_customer_merges m
       WHERE site_use_id = m.duplicate_site_id
       AND   m.process_flag = 'N'
       AND   m.request_id = req_id
       AND   m.set_number = set_num
       FOR UPDATE NOWAIT;

    CURSOR c2 is
       SELECT cust_account_profile_id
       FROM hz_customer_profiles yt, ra_customer_merges m
       WHERE cust_account_id = m.duplicate_id
       AND   m.process_flag = 'N'
       AND   m.request_id = req_id
       AND   m.set_number = set_num
       AND   m.delete_duplicate_flag = 'N'
       AND site_use_id IS NULL
       AND NOT EXISTS (
                  SELECT 'active accounts exist'
                  FROM   hz_cust_accounts acct
                  WHERE  acct.cust_account_id = yt.cust_account_id
                  AND    acct.status = 'A')
       FOR UPDATE NOWAIT;

    --cursor c3 work in 'delete' mode.
    CURSOR c3 is
       SELECT cust_account_profile_id
       FROM hz_customer_profiles yt, ra_customer_merges m
       WHERE cust_account_id = m.duplicate_id
       AND   m.process_flag = 'N'
       AND   m.request_id = req_id
       AND   m.set_number = set_num
       AND   m.delete_duplicate_flag = 'Y'
       AND   site_use_id IS NULL
       AND   NOT EXISTS (
                  SELECT 'accounts exist'
                  FROM   hz_cust_accounts acct
                  WHERE  acct.cust_account_id = yt.cust_account_id
                  AND    acct.status <> 'D' )
       FOR UPDATE NOWAIT;

BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCPF.AR_CP()+' );

    IF process_mode = 'LOCK' THEN

       arp_message.set_name( 'AR', 'AR_LOCKING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUSTOMER_PROFILES', FALSE );

       OPEN c1;
       CLOSE c1;

       OPEN c2;
       CLOSE c2;

       OPEN c3;
       CLOSE c3;

    ELSE

       /*************** 'inactivate' mode ***************/

       --site level inactivate
       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUSTOMER_PROFILES', FALSE );

       UPDATE hz_customer_profiles yt
       SET status = 'I',
           last_update_date = sysdate,
           last_updated_by = hz_utility_v2pub.user_id,
           last_update_login = hz_utility_v2pub.last_update_login,
           request_id =  req_id,
           program_application_id = hz_utility_v2pub.program_application_id,
           program_id = hz_utility_v2pub.program_id,
           program_update_date = sysdate
       WHERE site_use_id IN (
                  SELECT m.duplicate_site_id
                  FROM   ra_customer_merges m
                  WHERE  m.process_flag = 'N'
                  AND    m.request_id = req_id
                  AND    m.set_number = set_num
                  AND    m.delete_duplicate_flag = 'N' ) ;

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

       --customer level inactivate
       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUSTOMER_PROFILES', FALSE );

       UPDATE hz_customer_profiles yt
       SET status = 'I',
           last_update_date = sysdate,
           last_updated_by = hz_utility_v2pub.user_id,
           last_update_login = hz_utility_v2pub.last_update_login,
           request_id =  req_id,
           program_application_id = hz_utility_v2pub.program_application_id,
           program_id = hz_utility_v2pub.program_id,
           program_update_date = sysdate
       WHERE cust_account_id IN (
                  SELECT m.duplicate_id
                  FROM   ra_customer_merges m
                  WHERE  m.process_flag = 'N'
                  AND    m.request_id = req_id
                  AND    m.set_number = set_num
                  AND    m.delete_duplicate_flag = 'N' )
       AND site_use_id IS NULL
       AND NOT EXISTS (
                  SELECT 'active accounts exist'
                  FROM   hz_cust_accounts acct
                  WHERE  acct.cust_account_id = yt.cust_account_id
                  AND    acct.status = 'A');

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

       /*************** 'delete' mode ***************/
--Bug 1535542: Mark the rows need to be deleted by setting status to 'D'.
--Physically delete them after merge.

       --site level 'delete'
       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUSTOMER_PROFILES', FALSE );

       UPDATE hz_customer_profiles
       SET status = 'D'
       WHERE site_use_id IN (
                  SELECT m.duplicate_site_id
                  FROM   ra_customer_merges m
                  WHERE  m.process_flag = 'N'
                  AND    m.request_id = req_id
                  AND    m.set_number = set_num
                  AND    m.delete_duplicate_flag = 'Y' ) ;

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

       --customer level 'delete'
       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUSTOMER_PROFILES', FALSE );

       UPDATE hz_customer_profiles yt
       SET status = 'D'
       WHERE cust_account_id IN (
                  SELECT m.duplicate_id
                  FROM   ra_customer_merges m
                  WHERE  m.process_flag = 'N'
                  AND    m.request_id = req_id
                  AND    m.set_number = set_num
                  AND    m.delete_duplicate_flag = 'Y' )
       AND   site_use_id IS NULL
       AND   NOT EXISTS (
                  SELECT 'accounts exist'
                  FROM   hz_cust_accounts acct
                  WHERE  acct.cust_account_id = yt.cust_account_id
                  AND    acct.status <> 'D' );

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    END IF;

    arp_message.set_line( 'ARP_CMERGE_ARCPF.AR_CP()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCPF.AR_CP');
      RAISE;

END ar_cp;

/*===========================================================================+
 | PROCEDURE
 |              ar_cpa
 |
 | DESCRIPTION
 |              merge in HZ_CUSTOMER_PROFILE_AMTS
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |                    process_mod
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  20-DEC-00  Bug 1535542: Since we need to change
 |                        the merging order, merge HZ tables before merging
 |                        products, we need to move the delete part to
 |                        'delete rows' in which we do physically delete after
 |                        merging one set.
 |
 +===========================================================================*/

PROCEDURE ar_cpa (
          req_id                      NUMBER,
          set_num                     NUMBER,
          process_mode                VARCHAR2
) IS

    --cursor c1 and c2 work in inactive mode.
    CURSOR c1 is
       SELECT CUST_ACCT_PROFILE_AMT_ID
       FROM HZ_CUST_PROFILE_AMTS, ra_customer_merges m
       WHERE site_use_id = m.duplicate_site_id
       AND   m.process_flag = 'N'
       AND   m.request_id = req_id
       AND   m.set_number = set_num
       AND   m.delete_duplicate_flag = 'N'
       FOR UPDATE NOWAIT;

    CURSOR c2 is
       SELECT CUST_ACCT_PROFILE_AMT_ID
       FROM HZ_CUST_PROFILE_AMTS yt, ra_customer_merges m
       WHERE cust_account_id = m.duplicate_id
       AND   m.process_flag = 'N'
       AND   m.request_id = req_id
       AND   m.set_number = set_num
       AND   m.delete_duplicate_flag = 'N'
       AND   site_use_id IS NULL
       AND NOT EXISTS (
                  SELECT 'active accounts exist'
                  FROM   hz_cust_accounts acct
                  WHERE  acct.cust_account_id = yt.cust_account_id
                  AND    acct.status = 'A')
       FOR UPDATE NOWAIT;

BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCPF.AR_CPA()+' );

    IF process_mode = 'LOCK' THEN

       arp_message.set_name( 'AR', 'AR_LOCKING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_PROFILE_AMTS', FALSE );

       OPEN c1;
       CLOSE c1;

       OPEN c2;
       CLOSE c2;

    ELSE

       /*************** 'inactivate' mode ***************/

       --site level inactivate
       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_PROFILE_AMTS', FALSE );

       UPDATE HZ_CUST_PROFILE_AMTS yt
       SET last_update_date = sysdate,
           last_updated_by = hz_utility_v2pub.user_id,
           last_update_login = hz_utility_v2pub.last_update_login,
           request_id =  req_id,
           program_application_id = hz_utility_v2pub.program_application_id,
           program_id = hz_utility_v2pub.program_id,
           program_update_date = sysdate
       WHERE site_use_id IN (
                  SELECT m.duplicate_site_id
                  FROM   ra_customer_merges m
                  WHERE  m.process_flag = 'N'
                  AND    m.request_id = req_id
                  AND    m.set_number = set_num
                  AND    m.delete_duplicate_flag = 'N' );

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

       --customer level inactivate
       arp_message.set_name( 'AR', 'AR_UPDATING_TABLE' );
       arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_PROFILE_AMTS', FALSE );

       UPDATE HZ_CUST_PROFILE_AMTS yt
       SET last_update_date = sysdate,
           last_updated_by = hz_utility_v2pub.user_id,
           last_update_login = hz_utility_v2pub.last_update_login,
           request_id =  req_id,
           program_application_id = hz_utility_v2pub.program_application_id,
           program_id = hz_utility_v2pub.program_id,
           program_update_date = sysdate
       WHERE cust_account_id IN (
                  SELECT m.duplicate_id
                  FROM   ra_customer_merges m
                  WHERE  m.process_flag = 'N'
                  AND    m.request_id = req_id
                  AND    m.set_number = set_num
                  AND    m.delete_duplicate_flag = 'N' )
       AND site_use_id IS NULL
       AND NOT EXISTS (
                  SELECT 'active accounts exist'
                  FROM   hz_cust_accounts acct
                  WHERE  acct.cust_account_id = yt.cust_account_id
                  AND    acct.status = 'A') ;

       g_count := sql%rowcount;

       arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
       arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    END IF;

    arp_message.set_line( 'ARP_CMERGE_ARCPF.AR_CPA()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCPF.AR_CPA');
      RAISE;

END ar_cpa;

/*===========================================================================+
 | PROCEDURE
 |              delete_rows
 |
 | DESCRIPTION  physically delete the rows we marked in customer tables after
 |              we merging each set.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |     Jianying Huang  20-DEC-00  Created for bug 1535542: physically delete
 |                        rows in customer tables after merging each set.
 |     Jianying Huang  29-DEC-00  Modified 'delete_rows' for performance issue.
 |
 +===========================================================================*/

PROCEDURE delete_rows(
          req_id                    NUMBER,
          set_num                   NUMBER
) IS

    CURSOR profiles IS
       SELECT cust_account_profile_id
       FROM HZ_CUSTOMER_PROFILES, ra_customer_merges m
       WHERE cust_account_id = m.duplicate_id
       AND   m.process_flag = 'N'
       AND   m.request_id = req_id
       AND   m.set_number = set_num
       AND   m.delete_duplicate_flag = 'Y'
       AND status = 'D'
       FOR UPDATE NOWAIT;

    CURSOR profile_amt_site IS
       SELECT CUST_ACCT_PROFILE_AMT_ID
       FROM HZ_CUST_PROFILE_AMTS, ra_customer_merges m
       WHERE site_use_id = m.duplicate_site_id
       AND   m.process_flag = 'N'
       AND   m.request_id = req_id
       AND   m.set_number = set_num
       AND   m.delete_duplicate_flag = 'Y'
       FOR UPDATE NOWAIT;

    CURSOR profile_amt_acct IS
       SELECT CUST_ACCT_PROFILE_AMT_ID
       FROM HZ_CUST_PROFILE_AMTS yt, ra_customer_merges m
       WHERE cust_account_id = m.duplicate_id
       AND   m.process_flag = 'N'
       AND   m.request_id = req_id
       AND   m.set_number = set_num
       AND   m.delete_duplicate_flag = 'Y'
       AND   site_use_id IS NULL
       AND   NOT EXISTS (
                  SELECT 'accounts exist'
                  FROM   hz_cust_acct_sites_all acct --SSUptake
                  WHERE  acct.cust_account_id = yt.cust_account_id
		  AND    acct.org_id  = m.org_id --SSUptake
                  AND    status <> 'D' )

       FOR UPDATE NOWAIT;

BEGIN

    arp_message.set_line( 'ARP_CMERGE_ARCPF.delete_rows()+' );

    /*****************************************************/

--Bug 1535542: Because ar_ch procedure works only in delete mode, we call it here
--instead of in 'merge' procedure.

    ar_ch( req_id, set_num, 'DUMMY' );

    /*****************************************************/

    arp_message.set_name( 'AR', 'AR_DELETING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'HZ_CUSTOMER_PROFILES', FALSE );

    OPEN profiles;
    CLOSE profiles;

    DELETE FROM HZ_CUSTOMER_PROFILES
    WHERE cust_account_id IN (
                  SELECT m.duplicate_id
                  FROM   ra_customer_merges m
                  WHERE  m.process_flag = 'N'
                  AND    m.request_id = req_id
                  AND    m.set_number = set_num
                  AND    m.delete_duplicate_flag = 'Y' )
    AND status = 'D';

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_DELETED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    /*****************************************************/

    arp_message.set_name( 'AR', 'AR_DELETING_TABLE' );
    arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_PROFILE_AMTS', FALSE );

    OPEN profile_amt_site;
    CLOSE profile_amt_site;

    OPEN profile_amt_acct;
    CLOSE profile_amt_acct;

    --site level
    DELETE FROM HZ_CUST_PROFILE_AMTS yt
    WHERE site_use_id IN (
               SELECT m.duplicate_site_id
               FROM   ra_customer_merges m
               WHERE  m.process_flag = 'N'
               AND    m.request_id = req_id
               AND    m.set_number = set_num
               AND m.delete_duplicate_flag = 'Y' );

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_DELETED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_name( 'AR', 'AR_DELETING_TABLE' );
    arp_message.set_token( 'TABLE_NAME', 'HZ_CUST_PROFILE_AMTS', FALSE );

    --account level
    DELETE FROM HZ_CUST_PROFILE_AMTS yt
    WHERE cust_account_id IN (
               SELECT m.duplicate_id
               FROM   ra_customer_merges m
               WHERE  m.process_flag = 'N'
	       AND    m.request_id = req_id
               AND    m.set_number = set_num
               AND    m.delete_duplicate_flag = 'Y' )
    AND   site_use_id IS NULL
    AND   NOT EXISTS (
               SELECT 'accounts exist'
               FROM   hz_cust_accounts acct
               WHERE  acct.cust_account_id = yt.cust_account_id
               AND    acct.status <> 'D' );

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_DELETED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_line( 'ARP_CMERGE_ARCPF.delete_rows()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_ARCPF.delete_rows' );
      RAISE;

END delete_rows;

END ARP_CMERGE_ARCPF;

/
