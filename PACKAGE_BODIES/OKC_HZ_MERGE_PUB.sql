--------------------------------------------------------
--  DDL for Package Body OKC_HZ_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_HZ_MERGE_PUB" AS
/* $Header: OKCPMRGB.pls 120.0.12010000.3 2009/12/04 10:34:12 vgujarat ship $ */
        l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
--
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
-- Start of Comments
-- API Name     :OKC_HZ_MERGE_PUB
-- Type         :Public
-- Purpose      :Manage customer and party merges
--
-- Modification History
-- 07-Dec-00    mconnors    created
-- 10-May-02    rbhandar    Modified Account merge logic. Accounts can be merged
--                          under two different parties when a predefined set of
--                          conditions were satisfied
-- 14-JAN-03    rbhandar    Bug 2446945 - Auditing during account merge
-- 04-01-03     rbhandar    Bug 2446945 Added who columns and action_flag to
--                          hz_customer_merge_log insert statement
-- 29-MAY-04     amhanda     Bug 3555739 Added code in party_merge,account_merge and
--                          account_site_merge procedure to take care of 11.5.10 rule
--                          migration changes for OKS
-- 01-NOV-04    who         Bug 3950642 Added code to take care of site use merge for OKE
--                          in the OKC_K_PARTY_ROLES tables.
-- 19-JAN-05    chkrishn    Bug 4105272 Added insert statement to OKC_K_VERS_NUMBERS_H
--                          in procedure PARTY_MERGE
-- 27-FEB-07    harchand    Bug 6861077. Added the code to the union query of cursor c_account_count
/* 04-DEC-2009  vgujarat    Bug9077092. Changed the procedure party_merge, account_merge and
			    account_site_merge to increment the minor version in
			    okc_k_vers_numbers accordingly.
*/
-- NOTES
-- Merging Rules:
--   Account merges across parties, when the "duplicate" or source party
--   is referenced in a contract are not allowed. (This logic has been
--   modified. Merge is possible even if the source party is referenced
--   in a contract)
--
--   Merges where the duplicate party is not referenced in a contract are
--   processed (account, site, site use).
--
--   Account merges within the same party are processed (account, site,
--   site use).
--
--   Site merges in the same account are processed (site, site use).
--
--   When merging accounts, customer account ids are looked for in:
--      OKC_K_PARTY_ROLES
--      OKC_RULES
--      OKC_K_ITEMS
--   For customer site merges, cust_acct_site_ids are looked for in:
--      OKC_RULES
--      OKC_K_ITEMS
--   For customer site use merges, site_use_ids are looked for in:
--      OKC_RULES
--      OKC_K_ITEMS
--      OKC_K_PARTY_ROLES (bug 3950642)
--
-- JTF Objects:
--   The merge depends upon the proper usages being set for the JTF objects used
--   as party roles, rules, and items.  These usages are as follows:
--          OKX_PARTY       This object is based on a view which returns the
--                          party_id as id1.
--          OKX_P_SITE      This object is based on a view which returns
--                          party_site_id as id1.
--          OKX_P_SITE_USE  This object is based on a view which returns
--                          party_site_use_id as id1.
--          OKX_ACCOUNT     This object is based on a view which returns
--                          cust_account_id as id1.
--          OKX_C_SITE      This object is based on a view which returns
--                          cust_acct_site_id as id1.
--          OKX_C_SITE_USE  This object is based on a view which returns
--                          site_use_id as id1.
--   The usages are how the merge determines which jtot_object_codes are candidates
--   for the different types of merges.
--
--
-- End of comments


-- Global constants
c_party             CONSTANT VARCHAR2(20) := 'OKX_PARTY';
c_p_site            CONSTANT VARCHAR2(20) := 'OKX_P_SITE';
c_p_site_use        CONSTANT VARCHAR2(20) := 'OKX_P_SITE_USE';
c_account           CONSTANT VARCHAR2(20) := 'OKX_ACCOUNT';
c_c_site            CONSTANT VARCHAR2(20) := 'OKX_C_SITE';
c_c_site_use        CONSTANT VARCHAR2(20) := 'OKX_C_SITE_USE';
-- New profile value for customer merge log purpose
l_profile_val       VARCHAR2(30) := FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

/*added for bug9077092 to check whether the minor version needs updation or not*/
g_minor_ver_upd_processed VARCHAR2(1) := 'N';
--
-- routine to lock tables when process mode = 'LOCK'
-- if table cannot be locked, goes back to caller as exception
PROCEDURE lock_tables (req_id IN NUMBER
                      ,set_number IN NUMBER) IS
--
-- cursors to lock tables
--
CURSOR c_lock_kpr(b_object_use VARCHAR2) IS
  SELECT 1
  FROM okc_k_party_roles_b kpr
  WHERE kpr.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = b_object_use
                                  )
    AND kpr.object1_id1 IN (SELECT to_char(cme.duplicate_id)
                            FROM ra_customer_merges cme
                            WHERE cme.process_flag = 'N'
                              AND cme.request_id   = req_id
                             AND cme.set_number   = set_number
                            )
  FOR UPDATE NOWAIT;




CURSOR c_lock_rle1(b_object_use VARCHAR2) IS
  SELECT 1
  FROM okc_rules_b rle
  WHERE rle.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = b_object_use
                                  )
    AND rle.object1_id1 IN (SELECT to_char(cme.duplicate_id)
                             FROM ra_customer_merges cme
                             WHERE cme.process_flag = 'N'
                               AND cme.request_id   = req_id
                               AND cme.set_number   = set_number
                            )
  FOR UPDATE NOWAIT;

CURSOR c_lock_rle2(b_object_use VARCHAR2) IS
  SELECT 1
  FROM okc_rules_b rle
  WHERE rle.jtot_object2_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = b_object_use
                                  )
    AND rle.object2_id1 IN (SELECT to_char(cme.duplicate_id)
                             FROM ra_customer_merges cme
                             WHERE cme.process_flag = 'N'
                               AND cme.request_id   = req_id
                               AND cme.set_number   = set_number
                            )
  FOR UPDATE NOWAIT;

CURSOR c_lock_rle3(b_object_use VARCHAR2) IS
  SELECT 1
  FROM okc_rules_b rle
  WHERE rle.jtot_object3_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = b_object_use
                                  )
    AND rle.object3_id1 IN (SELECT to_char(cme.duplicate_id)
                             FROM ra_customer_merges cme
                             WHERE cme.process_flag = 'N'
                               AND cme.request_id   = req_id
                               AND cme.set_number   = set_number
                            )
  FOR UPDATE NOWAIT;

CURSOR c_lock_cim(b_object_use VARCHAR2) IS
  SELECT 1
  FROM okc_k_items cim
  WHERE cim.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = b_object_use
                                  )
    AND cim.object1_id1 IN (SELECT to_char(cme.duplicate_id)
                            FROM ra_customer_merges cme
                            WHERE cme.process_flag = 'N'
                              AND cme.request_id   = req_id
                             AND cme.set_number   = set_number
                            )
  FOR UPDATE NOWAIT;

BEGIN
  arp_message.set_line('OKC_HZ_MERGE_PUB.LOCK_TABLES()+');

  -- party roles for accounts
  arp_message.set_name('AR','AR_LOCKING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_K_PARTY_ROLES_B',FALSE);
  arp_message.set_line('Locking for accounts');
  open c_lock_kpr(c_account);
  close c_lock_kpr;

  arp_message.set_line('Locking for site uses');
  open c_lock_kpr(c_c_site_use); -- added for bug 3950642
  close c_lock_kpr;

  -- rules for accounts
  arp_message.set_name('AR','AR_LOCKING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_RULES_B',FALSE);
  arp_message.set_line('Locking for accounts');
  open c_lock_rle1(c_account);
  close c_lock_rle1;
  open c_lock_rle2(c_account);
  close c_lock_rle2;
  open c_lock_rle3(c_account);
  close c_lock_rle3;

  -- rules for sites
  arp_message.set_name('AR','AR_LOCKING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_RULES_B',FALSE);
  arp_message.set_line('Locking for sites');
  open c_lock_rle1(c_c_site);
  close c_lock_rle1;
  open c_lock_rle2(c_c_site);
  close c_lock_rle2;
  open c_lock_rle3(c_c_site);
  close c_lock_rle3;

  -- rules for site uses
  arp_message.set_name('AR','AR_LOCKING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_RULES_B.OBJECT3_ID1',FALSE);
  arp_message.set_line('Locking for site uses');
  open c_lock_rle1(c_c_site_use);
  close c_lock_rle1;
  open c_lock_rle2(c_c_site_use);
  close c_lock_rle2;
  open c_lock_rle3(c_c_site_use);
  close c_lock_rle3;

  -- items for accounts (covered level in OKS)
  arp_message.set_name('AR','AR_LOCKING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_K_ITEMS',FALSE);
  arp_message.set_line('Locking for accounts');
  open c_lock_cim(c_account);
  close c_lock_cim;

  -- items for sites
  arp_message.set_name('AR','AR_LOCKING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_K_ITEMS',FALSE);
  arp_message.set_line('Locking for sites');
  open c_lock_cim(c_c_site);
  close c_lock_cim;

  -- items for site uses
  arp_message.set_name('AR','AR_LOCKING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_K_ITEMS',FALSE);
  arp_message.set_line('Locking for site uses');
  open c_lock_cim(c_c_site_use);
  close c_lock_cim;

  arp_message.set_line('OKC_HZ_MERGE_PUB.LOCK_TABLES()-');
EXCEPTION
  WHEN TIMEOUT_ON_RESOURCE THEN
	  arp_message.set_line('Could not obtain lock for records');
	  raise;
END; -- lock_tables

--
-- Updating the contract tables in case the source party has a contract
-- The source party should have only one account and that account should
-- be the merged account. This is when merging two accounts under different
-- parties
--

PROCEDURE party_merge(req_id IN NUMBER
                      ,set_number IN NUMBER
                      ,l_source_party_id IN NUMBER
                      ,l_target_party_id IN NUMBER
                      ,l_duplicate_id IN NUMBER) IS

--
-- cursor to find if any contract is with the party of the
-- merged account
--
CURSOR c_cpr (b_party_id NUMBER) IS
  SELECT kpr.dnz_chr_id
  FROM okc_k_party_roles_b kpr
  WHERE kpr.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_party
                                  )
    AND kpr.object1_id1 = to_char(b_party_id)
  ;

--
-- cursor to get all the acounts from rules for a particular
-- contract
-- Bug 3555739 modified the cursor to check for account info. in okc_k_lines_b and
-- okc_k_headers_b also

CURSOR c_rules (b_dnz_chr_id NUMBER) IS
  select object1_id1, object2_id1, object3_id1
  from okc_rules_b
  where dnz_chr_id = b_dnz_chr_id
  and  rule_information_category IN ('BTO', 'STO')
  union
  select to_char(bill_to_site_use_id), to_char(ship_to_site_use_id), to_char(cust_acct_id)
  from okc_k_headers_b
  where id = b_dnz_chr_id
  union
  select to_char(bill_to_site_use_id), to_char(ship_to_site_use_id), to_char(cust_acct_id)
  from okc_k_lines_b
  where chr_id = b_dnz_chr_id ;

--
-- cursor to check whether the source party has more than one
-- account in the contract
-- Bug 3555739 modified the cursor to check for account info. in okc_k_lines_b and
-- okc_k_headers_b also
CURSOR c_account_count (b_chr_id NUMBER) IS
  select count(*)
   from (select okr1.object1_id1 from okc_rules_b okr1
      where okr1.object1_id1 in (
            select TO_CHAR(cust_account_id) from hz_cust_accounts where party_id = l_source_party_id
      ) and okr1.dnz_chr_id = b_chr_id
        and okr1.rule_information_category IN ('BTO', 'STO')
      union
      select okr2.object2_id1 from okc_rules_b okr2
      where  okr2.object2_id1 in (
             select TO_CHAR(cust_account_id) from hz_cust_accounts where party_id = l_source_party_id
     ) and okr2.dnz_chr_id = b_chr_id
       and okr2.rule_information_category IN ('BTO', 'STO')
     union
     select okr3.object3_id1 from okc_rules_b okr3
     where  okr3.object3_id1 in (
            select TO_CHAR(cust_account_id) from hz_cust_accounts where party_id = l_source_party_id
     ) and okr3.dnz_chr_id = b_chr_id
       and okr3.rule_information_category IN ('BTO', 'STO')
     union
     (select to_char(cust_account_id) from OKX_CUST_SITE_USES_V
                       where id1 IN  (select bill_to_site_use_id
                                       from okc_k_headers_b where id = b_chr_id)
                         and party_id = l_source_party_id
                         and SITE_USE_CODE = 'BILL_TO')
     union
     (select to_char(cust_account_id) from OKX_CUST_SITE_USES_V
                       where id1 IN  (select ship_to_site_use_id
                                      from okc_k_headers_b where id = b_chr_id )
                         and party_id =l_source_party_id
                         and SITE_USE_CODE = 'SHIP_TO')
     union
     (select to_char(cust_account_id) from OKX_CUST_SITE_USES_V
                       where id1 IN  (select bill_to_site_use_id
                                       from okc_k_lines_b where dnz_chr_id = b_chr_id)
                         and party_id = l_source_party_id
                         and SITE_USE_CODE = 'BILL_TO')
     union
     (select to_char(cust_account_id) from OKX_CUST_SITE_USES_V
                       where id1 IN  (select ship_to_site_use_id
                                      from okc_k_lines_b where dnz_chr_id = b_chr_id )
                         and party_id =l_source_party_id
                         and SITE_USE_CODE = 'SHIP_TO')
     union
    (select to_char(cust_account_id) from hz_cust_accounts
                       where cust_account_id IN (select cust_acct_id
                                                 from okc_k_lines_b where dnz_chr_id = b_chr_id )
	 -- For Bug# 6861077
 	                          and party_id =l_source_party_id)
 	      union
 	      (select to_char(cust_account_id) from hz_cust_accounts
 	                         where cust_account_id IN (select cust_acct_id
 	                                                   from okc_k_headers_b where id = b_chr_id )
         -- Changes for Bug# 6861077 Ends
                         and party_id =l_source_party_id));

--
-- cursor to get the contract number and modifier for log purpose
--
CURSOR c_header_info (b_chr_id NUMBER) IS
  SELECT contract_number, contract_number_modifier
  FROM okc_k_headers_b
  WHERE id=b_chr_id;

CURSOR c_party_id_log(b_chr_id NUMBER) IS
   SELECT kpr.id
   FROM okc_k_party_roles_b kpr
   WHERE kpr.object1_id1 = l_target_party_id
     AND kpr.dnz_chr_id = b_chr_id;

 l_count                      NUMBER(10)   := 0;
 l_object_user_code           VARCHAR2(20);
 l_chr_id                     okc_k_party_roles_b.dnz_chr_id%type;
 l_object1_id1                okc_rules_b.object1_id1%type;
 l_object2_id1                okc_rules_b.object2_id1%type;
 l_object3_id1                okc_rules_b.object3_id1%type;
 l_account_count	      NUMBER(10) := 0;
 l_contract_number            okc_k_headers_b.contract_number%type;
 l_contract_number_modifier   okc_k_headers_b.contract_number_modifier%type;
 l_status                     VARCHAR2(1);
 l_error_msg                  VARCHAR2(2000);
 l_log_party_id               NUMBER;

 l_merge_not_allowed_excp     EXCEPTION;
BEGIN
 arp_message.set_line('OKC_HZ_MERGE_PUB.PARTY_MERGE()+');
 arp_message.set_line('At the begining of Party Merge procedure');

 --
 -- initialize the status to check whether any contract has more than one
 -- account for the source party and one of the accounts is merged acount.
 -- Merge should fail in the above scenario
 --
 l_status := 'Y';

 OPEN c_cpr (l_source_party_id);
 LOOP
    FETCH c_cpr INTO l_chr_id;
    EXIT WHEN c_cpr%NOTFOUND;
    OPEN c_account_count(l_chr_id);
    FETCH c_account_count INTO l_account_count;

    IF (l_account_count > 1) THEN
       OPEN c_rules(l_chr_id);
       LOOP
          FETCH c_rules INTO l_object1_id1, l_object2_id1, l_object3_id1;
          EXIT WHEN c_rules%NOTFOUND;
          IF ( (TO_CHAR(l_duplicate_id) = nvl(l_object1_id1,'*')) OR (TO_CHAR(l_duplicate_id) = nvl(l_object2_id1, '*')) OR
               (TO_CHAR(l_duplicate_id) = nvl(l_object3_id1, '*')) ) THEN
              l_status := 'N'; -- contract exists with more than one account for the source party
                               -- and one of the accounts is the merged account
              OPEN c_header_info(l_chr_id);
              FETCH c_header_info INTO l_contract_number, l_contract_number_modifier;
              CLOSE c_header_info;
              arp_message.set_line('Contract ' || l_contract_number || ' should be manually updated');

              EXIT;
          END IF;
        END LOOP;  -- cursor c_rules
        CLOSE c_rules;
     END IF;
     CLOSE c_account_count;
   END LOOP;
   CLOSE c_cpr;

   -- error message if any contract has more than one account and one of the
   -- accounts is the merged account. Merge will fail.

   IF l_status <> 'Y' THEN
      RAISE l_merge_not_allowed_excp;  -- do not allow merge
   END IF;

 OPEN c_cpr (l_source_party_id);
 LOOP
    FETCH c_cpr INTO l_chr_id;
    EXIT WHEN c_cpr%NOTFOUND;
    OPEN c_account_count(l_chr_id);
    FETCH c_account_count INTO l_account_count;

    IF (l_account_count = 1) THEN
       OPEN c_rules(l_chr_id);
       LOOP
          FETCH c_rules INTO l_object1_id1, l_object2_id1, l_object3_id1;
          EXIT WHEN c_rules%NOTFOUND;
          IF ( (TO_CHAR(l_duplicate_id) = nvl(l_object1_id1,'*')) OR (TO_CHAR(l_duplicate_id) = nvl(l_object2_id1, '*')) OR
               (TO_CHAR(l_duplicate_id) = nvl(l_object3_id1, '*')) ) THEN

               -- updating OKC_K_PARTY_ROLES_B
               UPDATE okc_k_party_roles_b kpr
                 SET kpr.object1_id1           = l_target_party_id
                     ,kpr.object_version_number = kpr.object_version_number + 1
                     ,kpr.last_update_date      = SYSDATE
                     ,kpr.last_updated_by       = arp_standard.profile.user_id
                     ,kpr.last_update_login     = arp_standard.profile.last_update_login
                 WHERE kpr.object1_id1 = l_source_party_id
                     AND kpr.dnz_chr_id = l_chr_id;

                 l_count := sql%rowcount;
                 IF l_count > 0 THEN
                    OPEN c_header_info(l_chr_id);
                    FETCH c_header_info INTO l_contract_number, l_contract_number_modifier;
                    CLOSE c_header_info;
                    arp_message.set_line('Contract ' || l_contract_number || ' is updated');

                    OPEN c_party_id_log(l_chr_id);
                    FETCH c_party_id_log INTO l_log_party_id;
                    CLOSE c_party_id_log;

                -- Insert into log table
                  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
                   INSERT INTO HZ_CUSTOMER_MERGE_LOG (
                      MERGE_LOG_ID,
                      TABLE_NAME,
                      PRIMARY_KEY_ID1
                   ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
                          'OKC_K_PARTY_ROLES_B',
                          l_log_party_id
                     FROM DUAL;

                   UPDATE HZ_CUSTOMER_MERGE_LOG hz
                   SET hz.MERGE_HEADER_ID = (SELECT distinct CUSTOMER_MERGE_HEADER_ID
                                             FROM ra_customer_merges rcm
                                             WHERE rcm.request_id = req_id
                                               and rcm.set_number = set_number
                                               and rcm.process_flag = 'N')
                      ,hz.VCHAR_COL1_ORIG = l_source_party_id
                      ,hz.VCHAR_COL1_NEW =  l_target_party_id
                      ,hz.REQUEST_ID = req_id
                      ,hz.CREATED_BY = hz_utility_pub.CREATED_BY
                      ,hz.CREATION_DATE = hz_utility_pub.CREATION_DATE
                      ,hz.LAST_UPDATE_LOGIN = hz_utility_pub.LAST_UPDATE_LOGIN
                      ,hz.LAST_UPDATE_DATE = hz_utility_pub.LAST_UPDATE_DATE
                      ,hz.LAST_UPDATED_BY = hz_utility_pub.LAST_UPDATED_BY
                      ,hz.ACTION_FLAG = 'U'
                    WHERE hz.PRIMARY_KEY_ID1 = l_log_party_id;
                 END IF;
	    -- Fix for bug 4105272 Insert into okc_k_vers_numbers_h
            INSERT INTO OKC_K_VERS_NUMBERS_H(
                chr_id,
                major_version,
                minor_version,
                object_version_number,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login)
            (SELECT
                chr_id,
                major_version,
                minor_version,
                object_version_number,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login
            FROM OKC_K_VERS_NUMBERS
            WHERE chr_id = l_chr_id);
                -- Updating okc_k_vers_numbers for Bug 3553330/3215231/3224957
                   UPDATE okc_k_vers_numbers ver
                   SET  ver.minor_version         = ver.minor_version + 1
                     ,ver.object_version_number = ver.object_version_number + 1
                     ,ver.last_update_date      = SYSDATE
                     ,ver.last_updated_by       = arp_standard.profile.user_id
                     ,ver.last_update_login     = arp_standard.profile.last_update_login
                   WHERE chr_id = l_chr_id;
                 -- Updating okc_k_vers_numbers for Bug 3553330/3215231/3224957
		g_minor_ver_upd_processed := 'Y'; /*bug9077092*/
                 END IF;

                 EXIT;
          END IF;
       END LOOP;  -- cursor c_rules
       CLOSE c_rules;
    END IF;
    CLOSE c_account_count;
  END LOOP;  -- cursor c_cpr
  CLOSE c_cpr;

  arp_message.set_line('At the end of Party Merge procedure');
  arp_message.set_line('OKC_HZ_MERGE_PUB.PARTY_MERGE()-');

EXCEPTION
  WHEN l_merge_not_allowed_excp THEN
    arp_message.set_line('Contract exists for duplicate party with more than one account, merge cannot proceed');
    arp_message.set_line('Please update the above mentioned contracts and run customer merge again');
    arp_message.set_error('OKC_HZ_MERGE_PUB.MERGE_ACCOUNT');
    RAISE;

  WHEN others THEN
    l_error_msg := substr(SQLERRM,1,70);
    arp_message.set_error('OKC_HZ_MERGE_PUB.MERGE_ACCOUNT', l_error_msg);
    RAISE;

END; -- party_merge


--
-- sub routine to merge accounts
-- exceptions are unhandled, sent back to caller
--
PROCEDURE account_merge(req_id IN NUMBER
                       ,set_number IN NUMBER) IS

l_count         NUMBER;
/*BUG9077092*/
 CURSOR contract_id IS
  SELECT distinct(okl.chr_id)
    FROM okc_k_lines_b okl
   WHERE okl.cust_acct_id IN (SELECT DISTINCT (rcm.duplicate_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number);
 TYPE chr_id_typ IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
 l_chr_id chr_id_typ;
 i NUMBER := 1;
 l_cum_count NUMBER := 0;
/*BUG9077092*/

BEGIN
  arp_message.set_line('OKC_HZ_MERGE_PUB.ACCOUNT_MERGE()+');

  -- contract party roles
  -- Insert into log table
   IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
    INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_K_PARTY_ROLES_B',
             CUSTOMER_MERGE_HEADER_ID,
              kpr.ID,
              kpr.object1_id1,
              to_char(rcm.customer_id),
              req_id,
              'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_K_PARTY_ROLES_B kpr, ra_customer_merges rcm
         WHERE (
              kpr.object1_id1 = to_char(rcm.duplicate_id)
         ) AND    rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND    kpr.object1_id1 IN (SELECT to_char(rcm.duplicate_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
         AND kpr.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_account);
   End If;

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_K_PARTY_ROLES',FALSE);
  UPDATE okc_k_party_roles_b kpr
  SET kpr.object1_id1 = (SELECT DISTINCT to_char(rcm.customer_id)
                         FROM ra_customer_merges rcm
                         WHERE kpr.object1_id1 = rcm.duplicate_id
                           AND rcm.process_flag = 'N'
                           AND rcm.request_id   = req_id
                           AND rcm.set_number   = set_number)
     ,kpr.object_version_number = kpr.object_version_number + 1
     ,kpr.last_update_date      = SYSDATE
     ,kpr.last_updated_by       = arp_standard.profile.user_id
     ,kpr.last_update_login     = arp_standard.profile.last_update_login
  WHERE kpr.object1_id1 IN (SELECT to_char(rcm.duplicate_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
    AND kpr.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_account)
  ;
  l_count := sql%rowcount;
  l_cum_count := l_cum_count + l_count; /*bug9077092*/
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));

  -- Rules ID1
  -- Insert into log table
  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
   INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_RULES_B',
             CUSTOMER_MERGE_HEADER_ID,
              rle.ID,
              rle.object1_id1,
              to_char(rcm.customer_id),
              req_id,
             'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_RULES_B rle, ra_customer_merges rcm
         WHERE (
              rle.object1_id1 = to_char(rcm.duplicate_id)
         ) AND    rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND    rle.object1_id1 IN (SELECT to_char(rcm.duplicate_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
         AND rle.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_account);
   End If;

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_RULES_B.OBJECT1_ID1',FALSE);
  UPDATE okc_rules_b rle
  SET rle.object1_id1 = (SELECT DISTINCT to_char(rcm.customer_id)
                         FROM ra_customer_merges rcm
                         WHERE rle.object1_id1 = rcm.duplicate_id
                           AND rcm.process_flag = 'N'
                           AND rcm.request_id   = req_id
                           AND rcm.set_number   = set_number)
     ,rle.object_version_number = rle.object_version_number + 1
     ,rle.last_update_date      = SYSDATE
     ,rle.last_updated_by       = arp_standard.profile.user_id
     ,rle.last_update_login     = arp_standard.profile.last_update_login
  WHERE rle.object1_id1 IN (SELECT to_char(rcm.duplicate_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
    AND rle.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_account)
  ;
  l_count := sql%rowcount;
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));


  -- Rules ID2
  -- Insert into log table
   IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
      INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_RULES_B',
             CUSTOMER_MERGE_HEADER_ID,
              rle.ID,
              rle.object2_id1,
              to_char(rcm.customer_id),
              req_id,
              'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_RULES_B rle, ra_customer_merges rcm
         WHERE (
              rle.object2_id1 = to_char(rcm.duplicate_id)
         ) AND    rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND    rle.object2_id1 IN (SELECT to_char(rcm.duplicate_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
         AND rle.jtot_object2_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_account);
  End If;

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_RULES_B.OBJECT2_ID1',FALSE);
  UPDATE okc_rules_b rle
  SET rle.object2_id1 = (SELECT DISTINCT to_char(rcm.customer_id)
                         FROM ra_customer_merges rcm
                         WHERE rle.object2_id1 = rcm.duplicate_id
                           AND rcm.process_flag = 'N'
                           AND rcm.request_id   = req_id
                           AND rcm.set_number   = set_number)
     ,rle.object_version_number = rle.object_version_number + 1
     ,rle.last_update_date      = SYSDATE
     ,rle.last_updated_by       = arp_standard.profile.user_id
     ,rle.last_update_login     = arp_standard.profile.last_update_login
  WHERE rle.object2_id1 IN (SELECT to_char(rcm.duplicate_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
    AND rle.jtot_object2_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_account)
  ;
  l_count := sql%rowcount;
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));


  -- Rules ID3
  -- Insert into log table
   IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
      INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_RULES_B',
             CUSTOMER_MERGE_HEADER_ID,
              rle.ID,
              rle.object3_id1,
              to_char(rcm.customer_id),
              req_id,
              'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_RULES_B rle, ra_customer_merges rcm
         WHERE (
              rle.object3_id1 = to_char(rcm.duplicate_id)
         ) AND    rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND     rle.object3_id1 IN (SELECT to_char(rcm.duplicate_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
        AND rle.jtot_object3_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_account);
   End If;

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_RULES_B.OBJECT3_ID1',FALSE);
  UPDATE okc_rules_b rle
  SET rle.object3_id1 = (SELECT DISTINCT to_char(rcm.customer_id)
                         FROM ra_customer_merges rcm
                         WHERE rle.object3_id1 = rcm.duplicate_id
                           AND rcm.process_flag = 'N'
                           AND rcm.request_id   = req_id
                           AND rcm.set_number   = set_number)
     ,rle.object_version_number = rle.object_version_number + 1
     ,rle.last_update_date      = SYSDATE
     ,rle.last_updated_by       = arp_standard.profile.user_id
     ,rle.last_update_login     = arp_standard.profile.last_update_login
  WHERE rle.object3_id1 IN (SELECT to_char(rcm.duplicate_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
    AND rle.jtot_object3_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_account)
  ;
  l_count := sql%rowcount;
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));

-- Start:Code added for Bug 3555739
-- Updating okc_k_headers_b
-- Cust_Acct_Id
-- Insert into log table
  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
     INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_K_HEADERS_B',
             CUSTOMER_MERGE_HEADER_ID,
              okh.ID,
              to_char(okh.cust_acct_id),
              to_char(rcm.customer_id),
              req_id,
              'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_K_HEADERS_B okh, ra_customer_merges rcm
         WHERE (
              okh.cust_acct_id = rcm.duplicate_id
         ) AND    rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND    okh.cust_acct_id IN (SELECT rcm.duplicate_id
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number);

  End If;

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_K_HEADERS_B.CUST_ACCT_ID',FALSE);

  UPDATE okc_k_headers_b okh
  SET okh.cust_acct_id = (SELECT DISTINCT (rcm.customer_id)
                         FROM ra_customer_merges rcm
                         WHERE okh.cust_acct_id =  rcm.duplicate_id
                         AND rcm.process_flag = 'N'
                         AND rcm.request_id   = req_id
                         AND rcm.set_number   = set_number)
     ,okh.object_version_number = okh.object_version_number + 1
     ,okh.last_update_date      = SYSDATE
     ,okh.last_updated_by       = arp_standard.profile.user_id
     ,okh.last_update_login     = arp_standard.profile.last_update_login
  WHERE okh.cust_acct_id IN (SELECT DISTINCT (rcm.duplicate_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number);

  l_count := sql%rowcount;
  l_cum_count := l_cum_count + l_count; /*bug9077092*/
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));



-- Updating okc_k_lines_b
-- Cust_Acct_Id
-- Insert into log table
  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
     INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_K_LINES_B',
             CUSTOMER_MERGE_HEADER_ID,
              okl.ID,
              to_char(okl.cust_acct_id),
              to_char(rcm.customer_id),
              req_id,
              'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_K_LINES_B okl, ra_customer_merges rcm
         WHERE (
              okl.cust_acct_id = rcm.duplicate_id
         ) AND    rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND    okl.cust_acct_id IN (SELECT rcm.duplicate_id
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number);

  End If;

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_K_LINES_B.CUST_ACCT_ID',FALSE);

  /*bug9077092*/
  FOR j IN contract_id LOOP
    l_chr_id(i) := j.chr_id;
    i := i+1;
   EXIT WHEN contract_id%NOTFOUND;
  END LOOP;
  /*bug9077092*/

  UPDATE okc_k_lines_b okl
  SET okl.cust_acct_id = (SELECT DISTINCT (rcm.customer_id)
                         FROM ra_customer_merges rcm
                         WHERE okl.cust_acct_id =  rcm.duplicate_id
                         AND rcm.process_flag = 'N'
                         AND rcm.request_id   = req_id
                         AND rcm.set_number   = set_number)
     ,okl.object_version_number = okl.object_version_number + 1
     ,okl.last_update_date      = SYSDATE
     ,okl.last_updated_by       = arp_standard.profile.user_id
     ,okl.last_update_login     = arp_standard.profile.last_update_login
  WHERE okl.cust_acct_id IN (SELECT DISTINCT (rcm.duplicate_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number);

  l_count := sql%rowcount;
  l_cum_count := l_cum_count + l_count; /*bug9077092*/
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));

-- Updating okc_k_party_roles_b
-- Cust_Acct_Id
-- Insert into log table
  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
     INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_K_PARTY_ROLES_B',
             CUSTOMER_MERGE_HEADER_ID,
              okpr.ID,
              to_char(okpr.cust_acct_id),
              to_char(rcm.customer_id),
              req_id,
              'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_K_PARTY_ROLES_B okpr, ra_customer_merges rcm
         WHERE (
              okpr.cust_acct_id = rcm.duplicate_id
         ) AND    rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND    okpr.cust_acct_id IN (SELECT rcm.duplicate_id
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number);

  End If;

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_K_PARTY_ROLES_B.CUST_ACCT_ID',FALSE);

  UPDATE okc_k_party_roles_b okpr
  SET okpr.cust_acct_id = (SELECT DISTINCT (rcm.customer_id)
                         FROM ra_customer_merges rcm
                         WHERE okpr.cust_acct_id =  rcm.duplicate_id
                         AND rcm.process_flag = 'N'
                         AND rcm.request_id   = req_id
                         AND rcm.set_number   = set_number)
     ,okpr.object_version_number = okpr.object_version_number + 1
     ,okpr.last_update_date      = SYSDATE
     ,okpr.last_updated_by       = arp_standard.profile.user_id
     ,okpr.last_update_login     = arp_standard.profile.last_update_login
  WHERE okpr.cust_acct_id IN (SELECT DISTINCT (rcm.duplicate_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number);

  l_count := sql%rowcount;
  l_cum_count := l_cum_count + l_count; /*bug9077092*/
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));

-- End:Code added for Bug 3555739

  -- contract items
  -- Insert into log table
  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
    INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_K_ITEMS',
             CUSTOMER_MERGE_HEADER_ID,
              cim.ID,
              cim.object1_id1,
              to_char(rcm.customer_id),
              req_id,
              'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_K_ITEMS cim, ra_customer_merges rcm
         WHERE (
              cim.object1_id1 = to_char(rcm.duplicate_id)
         ) AND    rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND    cim.object1_id1 IN (SELECT to_char(rcm.duplicate_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
         AND cim.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_account);
  End If;

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_K_ITEMS',FALSE);
  UPDATE okc_k_items cim
  SET cim.object1_id1 = (SELECT DISTINCT to_char(rcm.customer_id)
                         FROM ra_customer_merges rcm
                         WHERE cim.object1_id1 = rcm.duplicate_id
                           AND rcm.process_flag = 'N'
                           AND rcm.request_id   = req_id
                           AND rcm.set_number   = set_number)
     ,cim.object_version_number = cim.object_version_number + 1
     ,cim.last_update_date      = SYSDATE
     ,cim.last_updated_by       = arp_standard.profile.user_id
     ,cim.last_update_login     = arp_standard.profile.last_update_login
  WHERE cim.object1_id1 IN (SELECT to_char(rcm.duplicate_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
    AND cim.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_account)
  ;
  l_count := sql%rowcount;
  l_cum_count := l_cum_count + l_count; /*bug9077092*/
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));

  arp_message.set_line('OKC_HZ_MERGE_PUB.ACCOUNT_MERGE()-');

  /*bug9077092 - incrementing minor version even when account merge happens within the parties*/
  IF l_cum_count > 0 AND g_minor_ver_upd_processed = 'N' THEN

   IF l_chr_id.Count > 0 THEN
     FOR k IN l_chr_id.first..l_chr_id.last loop
     INSERT INTO OKC_K_VERS_NUMBERS_H(
                chr_id,
                major_version,
                minor_version,
                object_version_number,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login)
            (SELECT
                chr_id,
                major_version,
                minor_version,
                object_version_number,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login
            FROM OKC_K_VERS_NUMBERS
            WHERE chr_id = l_chr_id(k));

     UPDATE okc_k_vers_numbers ver
     SET  ver.minor_version         = ver.minor_version + 1
     ,ver.object_version_number = ver.object_version_number + 1
     ,ver.last_update_date      = SYSDATE
     ,ver.last_updated_by       = arp_standard.profile.user_id
     ,ver.last_update_login     = arp_standard.profile.last_update_login
     WHERE chr_id = l_chr_id(k);
     END LOOP;
     g_minor_ver_upd_processed := 'Y';
   END IF;
  END IF;
  /*bug9077092 - incrementing minor version even when account merge happens within the parties*/

END; -- account_merge

--
-- sub routine to merge account sites and site uses
-- exceptions are unhandled, sent back to caller
--
PROCEDURE account_site_merge (req_id IN NUMBER
                             ,set_number  IN NUMBER) IS

l_count         NUMBER;
/*BUG9077092*/
 CURSOR contract_id IS
  SELECT distinct(okl.chr_id)
    FROM okc_k_lines_b okl
   WHERE (okl.ship_to_site_use_id IN (SELECT DISTINCT (rcm.duplicate_site_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number))
      OR (okl.bill_to_site_use_id IN (SELECT DISTINCT (rcm.duplicate_site_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number));
 TYPE chr_id_typ IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
 l_chr_id chr_id_typ;
 i NUMBER := 1;
 l_cum_count NUMBER := 0;
/*BUG9077092*/

BEGIN
  arp_message.set_line('OKC_HZ_MERGE_PUB.ACCOUNT_SITE_MERGE()+');
  arp_message.set_line('Updating account sites');
  --
  -- Account Sites come first, then site uses
  --
  -- Account Sites in Rules.  There are three ids in rules that could hold the site id
  --

  -- Rules ID1
  -- Insert into log table
   IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
      INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_RULES_B',
             CUSTOMER_MERGE_HEADER_ID,
              rle.ID,
              rle.object1_id1,
              to_char(customer_address_id),
              req_id,
              'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_RULES_B rle, ra_customer_merges rcm
         WHERE (
              rle.object1_id1 = to_char(rcm.duplicate_address_id)
         ) AND    rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND    rle.object1_id1 IN (SELECT to_char(rcm.duplicate_address_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
         AND rle.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_c_site);
   End If;

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_RULES_B.OBJECT1_ID1',FALSE);
  UPDATE okc_rules_b rle
  SET rle.object1_id1 = (SELECT DISTINCT to_char(rcm.customer_address_id)
                         FROM ra_customer_merges rcm
                         WHERE rle.object1_id1 = rcm.duplicate_address_id
                           AND rcm.process_flag = 'N'
                           AND rcm.request_id   = req_id
                           AND rcm.set_number   = set_number
                           AND ROWNUM=1)
     ,rle.object_version_number = rle.object_version_number + 1
     ,rle.last_update_date      = SYSDATE
     ,rle.last_updated_by       = arp_standard.profile.user_id
     ,rle.last_update_login     = arp_standard.profile.last_update_login
  WHERE rle.object1_id1 IN (SELECT to_char(rcm.duplicate_address_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
    AND rle.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_c_site)
  ;
  l_count := sql%rowcount;
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));


  -- Rules ID2
  -- Insert into log table
  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
      INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_RULES_B',
             CUSTOMER_MERGE_HEADER_ID,
              rle.ID,
              rle.object2_id1,
              to_char(customer_address_id),
              req_id,
              'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_RULES_B rle, ra_customer_merges rcm
         WHERE (
              rle.object2_id1 = to_char(rcm.duplicate_address_id)
         ) AND    rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND    rle.object2_id1 IN (SELECT to_char(rcm.duplicate_address_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
         AND rle.jtot_object2_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_c_site);
   End If;

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_RULES_B.OBJECT2_ID1',FALSE);
  UPDATE okc_rules_b rle
  SET rle.object2_id1 = (SELECT DISTINCT to_char(rcm.customer_address_id)
                         FROM ra_customer_merges rcm
                         WHERE rle.object2_id1 = rcm.duplicate_address_id
                           AND rcm.process_flag = 'N'
                           AND rcm.request_id   = req_id
                           AND rcm.set_number   = set_number
                           AND ROWNUM=1)
     ,rle.object_version_number = rle.object_version_number + 1
     ,rle.last_update_date      = SYSDATE
     ,rle.last_updated_by       = arp_standard.profile.user_id
     ,rle.last_update_login     = arp_standard.profile.last_update_login
  WHERE rle.object2_id1 IN (SELECT to_char(rcm.duplicate_address_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
    AND rle.jtot_object2_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_c_site)
  ;
  l_count := sql%rowcount;
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));

  -- Rules ID3
  -- Insert into log table
   IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
      INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_RULES_B',
             CUSTOMER_MERGE_HEADER_ID,
              rle.ID,
              rle.object3_id1,
              to_char(customer_address_id),
              req_id,
              'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_RULES_B rle, ra_customer_merges rcm
         WHERE (
              rle.object3_id1 = to_char(rcm.duplicate_address_id)
         ) AND    rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND    rle.object3_id1 IN (SELECT to_char(rcm.duplicate_address_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
         AND rle.jtot_object3_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_c_site);
  End If;

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_RULES_B.OBJECT3_ID1',FALSE);
  UPDATE okc_rules_b rle
  SET rle.object3_id1 = (SELECT DISTINCT to_char(rcm.customer_address_id)
                         FROM ra_customer_merges rcm
                         WHERE rle.object3_id1 = rcm.duplicate_address_id
                           AND rcm.process_flag = 'N'
                           AND rcm.request_id   = req_id
                           AND rcm.set_number   = set_number
                           AND ROWNUM=1)
     ,rle.object_version_number = rle.object_version_number + 1
     ,rle.last_update_date      = SYSDATE
     ,rle.last_updated_by       = arp_standard.profile.user_id
     ,rle.last_update_login     = arp_standard.profile.last_update_login
  WHERE rle.object3_id1 IN (SELECT to_char(rcm.duplicate_address_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
    AND rle.jtot_object3_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_c_site)
  ;
  l_count := sql%rowcount;
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));


  --
  -- Account Sites in Items
  --
  -- Insert into log table
  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
     INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_K_ITEMS',
             CUSTOMER_MERGE_HEADER_ID,
              cim.ID,
              cim.object1_id1,
              to_char(rcm.customer_address_id),
              req_id,
              'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_K_ITEMS cim, ra_customer_merges rcm
         WHERE (
               cim.object1_id1 = to_char(rcm.duplicate_address_id)
         ) AND    rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND    cim.object1_id1 IN (SELECT to_char(rcm.duplicate_address_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
         AND cim.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_c_site);
   End If;

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_K_ITEMS',FALSE);
  UPDATE okc_k_items cim
  SET cim.object1_id1 = (SELECT DISTINCT to_char(rcm.customer_address_id)
                         FROM ra_customer_merges rcm
                         WHERE cim.object1_id1 = rcm.duplicate_address_id
                           AND rcm.process_flag = 'N'
                           AND rcm.request_id   = req_id
                           AND rcm.set_number   = set_number
                           AND ROWNUM=1)
     ,cim.object_version_number = cim.object_version_number + 1
     ,cim.last_update_date      = SYSDATE
     ,cim.last_updated_by       = arp_standard.profile.user_id
     ,cim.last_update_login     = arp_standard.profile.last_update_login
  WHERE cim.object1_id1 IN (SELECT to_char(rcm.duplicate_address_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
    AND cim.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_c_site)
  ;
  l_count := sql%rowcount;
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));

  --
  -- Account Site Uses
  --


  --
  -- Account Site Use in OKC_K_PARTY_ROLES_B (see Bug 3950642)
  -- OKE only uses the first object1_id1 to hold the site use id
  --
  --chkrishn 11/03/2004
 arp_message.set_line('Updating account site uses for OKE');
  -- Insert into log table
  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
     INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_K_PARTY_ROLES_B',
              CUSTOMER_MERGE_HEADER_ID,
              rle.ID,
              rle.object1_id1,
              to_char(rcm.customer_site_id),
              req_id,
              'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_K_PARTY_ROLES_B rle, ra_customer_merges rcm
         WHERE (
              rle.object1_id1 = to_char(rcm.duplicate_site_id)
         ) AND    rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND     rle.object1_id1 IN (SELECT to_char(rcm.duplicate_site_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
         AND rle.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_c_site_use);
  End If;

--chkrishn 11/03/2004

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_K_PARTY_ROLES_B',FALSE);

  UPDATE okc_k_party_roles_b rle
  SET rle.object1_id1 = (SELECT DISTINCT to_char(rcm.customer_site_id)
                 FROM ra_customer_merges rcm
                 WHERE rle.object1_id1 = rcm.duplicate_site_id
                 AND rcm.process_flag = 'N'
                 AND rcm.request_id = req_id
                 AND rcm.set_number = set_number)
         ,rle.object_version_number = rle.object_version_number + 1
         ,rle.last_update_date = SYSDATE
         ,rle.last_updated_by = arp_standard.profile.user_id
         ,rle.last_update_login = arp_standard.profile.last_update_login
  WHERE rle.object1_id1 IN ( SELECT to_char(rcm.duplicate_site_id)
                             FROM ra_customer_merges rcm
                             WHERE rcm.process_flag = 'N'
                             AND rcm.request_id = req_id
                             AND rcm.set_number = set_number)
  AND rle.jtot_object1_code IN (SELECT ojt.object_code
                                FROM jtf_objects_b ojt,jtf_object_usages oue
                                WHERE ojt.object_code =oue.object_code
                                AND oue.object_user_code = c_c_site_use)
  AND rle.dnz_chr_id in (select k_header_id from oke_k_headers);

--chkrishn 11/03/2004
  l_count := sql%rowcount;
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));

  --
  -- End of bug fix 3950642
  --


  --
  -- Account Sites Uses in Rules.  There are three ids in rules that
  -- could hold the site use id
  --


  arp_message.set_line('Updating account site uses');

  -- Rules ID1
  -- Insert into log table
  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
     INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_RULES_B',
             CUSTOMER_MERGE_HEADER_ID,
              rle.ID,
              rle.object1_id1,
              to_char(rcm.customer_site_id),
              req_id,
              'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_RULES_B rle, ra_customer_merges rcm
         WHERE (
              rle.object1_id1 = to_char(rcm.duplicate_site_id)
         ) AND    rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND     rle.object1_id1 IN (SELECT to_char(rcm.duplicate_site_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
         AND rle.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_c_site_use);
  End If;

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_RULES_B.OBJECT1_ID1',FALSE);
  UPDATE okc_rules_b rle
  SET rle.object1_id1 = (SELECT DISTINCT to_char(rcm.customer_site_id)
                         FROM ra_customer_merges rcm
                         WHERE rle.object1_id1 = rcm.duplicate_site_id
                           AND rcm.process_flag = 'N'
                           AND rcm.request_id   = req_id
                           AND rcm.set_number   = set_number)
     ,rle.object_version_number = rle.object_version_number + 1
     ,rle.last_update_date      = SYSDATE
     ,rle.last_updated_by       = arp_standard.profile.user_id
     ,rle.last_update_login     = arp_standard.profile.last_update_login
  WHERE rle.object1_id1 IN (SELECT to_char(rcm.duplicate_site_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
    AND rle.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_c_site_use)
  ;
  l_count := sql%rowcount;
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));

  -- Rules ID2
  -- Insert into log table
   IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
     INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_RULES_B',
             CUSTOMER_MERGE_HEADER_ID,
              rle.ID,
              rle.object2_id1,
              to_char(rcm.customer_site_id),
              req_id,
              'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_RULES_B rle, ra_customer_merges rcm
         WHERE (
              rle.object2_id1 = to_char(rcm.duplicate_site_id)
         ) AND    rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND     rle.object2_id1 IN (SELECT to_char(rcm.duplicate_site_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
         AND rle.jtot_object2_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_c_site_use);
   End If;

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_RULES_B.OBJECT2_ID1',FALSE);
  UPDATE okc_rules_b rle
  SET rle.object2_id1 = (SELECT DISTINCT to_char(rcm.customer_site_id)
                         FROM ra_customer_merges rcm
                         WHERE rle.object2_id1 = rcm.duplicate_site_id
                           AND rcm.process_flag = 'N'
                           AND rcm.request_id   = req_id
                           AND rcm.set_number   = set_number)
     ,rle.object_version_number = rle.object_version_number + 1
     ,rle.last_update_date      = SYSDATE
     ,rle.last_updated_by       = arp_standard.profile.user_id
     ,rle.last_update_login     = arp_standard.profile.last_update_login
  WHERE rle.object2_id1 IN (SELECT to_char(rcm.duplicate_site_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
    AND rle.jtot_object2_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_c_site_use)
  ;
  l_count := sql%rowcount;
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));


  -- Rules ID3
  -- Insert into log table
  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
     INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_RULES_B',
             CUSTOMER_MERGE_HEADER_ID,
              rle.ID,
              rle.object3_id1,
              to_char(rcm.customer_site_id),
              req_id,
              'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_RULES_B rle, ra_customer_merges rcm
         WHERE (
              rle.object3_id1 = to_char(rcm.duplicate_site_id)
         ) AND    rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND    rle.object3_id1 IN (SELECT to_char(rcm.duplicate_site_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
         AND rle.jtot_object3_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_c_site_use);
  End If;

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_RULES_B.OBJECT3_ID1',FALSE);
  UPDATE okc_rules_b rle
  SET rle.object3_id1 = (SELECT DISTINCT to_char(rcm.customer_site_id)
                         FROM ra_customer_merges rcm
                         WHERE rle.object3_id1 = rcm.duplicate_site_id
                           AND rcm.process_flag = 'N'
                           AND rcm.request_id   = req_id
                           AND rcm.set_number   = set_number)
     ,rle.object_version_number = rle.object_version_number + 1
     ,rle.last_update_date      = SYSDATE
     ,rle.last_updated_by       = arp_standard.profile.user_id
     ,rle.last_update_login     = arp_standard.profile.last_update_login
  WHERE rle.object3_id1 IN (SELECT to_char(rcm.duplicate_site_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
    AND rle.jtot_object3_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_c_site_use)
  ;
  l_count := sql%rowcount;
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));

-- Start:Code added for Bug 3555739
-- Updating okc_k_headers_b
-- Ship_to_site_use_id
-- Insert into log table
  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
     INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_K_HEADERS_B',
             CUSTOMER_MERGE_HEADER_ID,
              okh.ID,
              to_char(okh.ship_to_site_use_id),
              to_char(rcm.customer_site_id),
              req_id,
              'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_K_HEADERS_B okh, ra_customer_merges rcm
         WHERE (
              okh.ship_to_site_use_id = rcm.duplicate_site_id
         ) AND    rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND    okh.ship_to_site_use_id IN (SELECT rcm.duplicate_site_id
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number);

  End If;

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_K_HEADERS_B.SHIP_TO_SITE_USE_ID',FALSE);

  UPDATE okc_k_headers_b okh
  SET okh.ship_to_site_use_id = (SELECT DISTINCT (rcm.customer_site_id)
                         FROM ra_customer_merges rcm
                         WHERE okh.ship_to_site_use_id =  rcm.duplicate_site_id
                         AND rcm.process_flag = 'N'
                         AND rcm.request_id   = req_id
                         AND rcm.set_number   = set_number)
     ,okh.object_version_number = okh.object_version_number + 1
     ,okh.last_update_date      = SYSDATE
     ,okh.last_updated_by       = arp_standard.profile.user_id
     ,okh.last_update_login     = arp_standard.profile.last_update_login
  WHERE okh.ship_to_site_use_id IN (SELECT DISTINCT (rcm.duplicate_site_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number);
  l_count := sql%rowcount;
  l_cum_count := l_cum_count + l_count; /*bug9077092*/
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));


-- Updating okc_k_headers_b
-- Bill_to_site_use_id
-- Insert into log table
  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
     INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_K_HEADERS_B',
             CUSTOMER_MERGE_HEADER_ID,
              okh.ID,
              to_char(okh.bill_to_site_use_id),
              to_char(rcm.customer_site_id),
              req_id,
              'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_K_HEADERS_B okh, ra_customer_merges rcm
         WHERE (
              okh.bill_to_site_use_id = rcm.duplicate_site_id
         ) AND  rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND    okh.bill_to_site_use_id IN (SELECT rcm.duplicate_site_id
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number);

  End If;

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_K_LINES_B.BILL_TO_SITE_USE_ID',FALSE);

  UPDATE okc_k_headers_b okh
  SET okh.bill_to_site_use_id = (SELECT DISTINCT (rcm.customer_site_id)
                         FROM ra_customer_merges rcm
                         WHERE okh.bill_to_site_use_id =  rcm.duplicate_site_id
                         AND rcm.process_flag = 'N'
                         AND rcm.request_id   = req_id
                         AND rcm.set_number   = set_number)
     ,okh.object_version_number = okh.object_version_number + 1
     ,okh.last_update_date      = SYSDATE
     ,okh.last_updated_by       = arp_standard.profile.user_id
     ,okh.last_update_login     = arp_standard.profile.last_update_login
  WHERE okh.bill_to_site_use_id IN (SELECT DISTINCT (rcm.duplicate_site_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number);
  l_count := sql%rowcount;
  l_cum_count := l_cum_count + l_count; /*bug9077092*/
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));

-- Updating okc_k_lines_b
-- Ship_to_site_use_id
-- Insert into log table
  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
     INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_K_LINES_B',
             CUSTOMER_MERGE_HEADER_ID,
              okl.ID,
              to_char(okl.ship_to_site_use_id),
              to_char(rcm.customer_site_id),
              req_id,
              'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_K_LINES_B okl, ra_customer_merges rcm
         WHERE (
              okl.ship_to_site_use_id = rcm.duplicate_site_id
         ) AND    rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND    okl.ship_to_site_use_id IN (SELECT rcm.duplicate_site_id
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number);

  End If;

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_K_LINES_B.SHIP_TO_SITE_USE_ID',FALSE);

  /*bug9077092*/
  FOR j IN contract_id LOOP
    l_chr_id(i) := j.chr_id;
    i := i+1;
   EXIT WHEN contract_id%NOTFOUND;
  END LOOP;
  /*bug9077092*/

  UPDATE okc_k_lines_b okl
  SET okl.ship_to_site_use_id = (SELECT DISTINCT (rcm.customer_site_id)
                         FROM ra_customer_merges rcm
                         WHERE okl.ship_to_site_use_id =  rcm.duplicate_site_id
                         AND rcm.process_flag = 'N'
                         AND rcm.request_id   = req_id
                         AND rcm.set_number   = set_number)
     ,okl.object_version_number = okl.object_version_number + 1
     ,okl.last_update_date      = SYSDATE
     ,okl.last_updated_by       = arp_standard.profile.user_id
     ,okl.last_update_login     = arp_standard.profile.last_update_login
  WHERE okl.ship_to_site_use_id IN (SELECT DISTINCT (rcm.duplicate_site_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number);
  l_count := sql%rowcount;
  l_cum_count := l_cum_count + l_count; /*bug9077092*/
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));


-- Updating okc_k_lines_b
-- Bill_to_site_use_id
-- Insert into log table
  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
     INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_K_LINES_B',
             CUSTOMER_MERGE_HEADER_ID,
              okl.ID,
              to_char(okl.bill_to_site_use_id),
              to_char(rcm.customer_site_id),
              req_id,
              'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_K_LINES_B okl, ra_customer_merges rcm
         WHERE (
              okl.bill_to_site_use_id = rcm.duplicate_site_id
         ) AND  rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND    okl.bill_to_site_use_id IN (SELECT rcm.duplicate_site_id
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number);

  End If;

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_K_LINES_B.BILL_TO_SITE_USE_ID',FALSE);

  UPDATE okc_k_lines_b okl
  SET okl.bill_to_site_use_id = (SELECT DISTINCT (rcm.customer_site_id)
                         FROM ra_customer_merges rcm
                         WHERE okl.bill_to_site_use_id =  rcm.duplicate_site_id
                         AND rcm.process_flag = 'N'
                         AND rcm.request_id   = req_id
                         AND rcm.set_number   = set_number)
     ,okl.object_version_number = okl.object_version_number + 1
     ,okl.last_update_date      = SYSDATE
     ,okl.last_updated_by       = arp_standard.profile.user_id
     ,okl.last_update_login     = arp_standard.profile.last_update_login
  WHERE okl.bill_to_site_use_id IN (SELECT DISTINCT (rcm.duplicate_site_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number);
  l_count := sql%rowcount;
  l_cum_count := l_cum_count + l_count; /*bug9077092*/
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));


-- Updating okc_k_party_roles_b
-- Bill_to_site_use_id
-- Insert into log table
  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
     INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_K_PARTY_ROLES_B',
             CUSTOMER_MERGE_HEADER_ID,
              okpr.ID,
              to_char(okpr.bill_to_site_use_id),
              to_char(rcm.customer_site_id),
              req_id,
              'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_K_PARTY_ROLES_B okpr, ra_customer_merges rcm
         WHERE (
              okpr.bill_to_site_use_id = rcm.duplicate_site_id
         ) AND  rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND    okpr.bill_to_site_use_id IN (SELECT rcm.duplicate_site_id
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number);

  End If;

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_K_PARTY_ROLES_B.BILL_TO_SITE_USE_ID',FALSE);

  UPDATE okc_k_party_roles_b okpr
  SET okpr.bill_to_site_use_id = (SELECT DISTINCT (rcm.customer_site_id)
                         FROM ra_customer_merges rcm
                         WHERE okpr.bill_to_site_use_id =  rcm.duplicate_site_id
                         AND rcm.process_flag = 'N'
                         AND rcm.request_id   = req_id
                         AND rcm.set_number   = set_number)
     ,okpr.object_version_number = okpr.object_version_number + 1
     ,okpr.last_update_date      = SYSDATE
     ,okpr.last_updated_by       = arp_standard.profile.user_id
     ,okpr.last_update_login     = arp_standard.profile.last_update_login
  WHERE okpr.bill_to_site_use_id IN (SELECT DISTINCT (rcm.duplicate_site_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number);
  l_count := sql%rowcount;
  l_cum_count := l_cum_count + l_count; /*bug9077092*/
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));

 -- End:Code added for Bug 3555739

  --
  -- Account Sites Uses in Items
  --
  -- Insert into log table
  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
     INSERT INTO HZ_CUSTOMER_MERGE_LOG (
       MERGE_LOG_ID,
       TABLE_NAME,
       MERGE_HEADER_ID,
       PRIMARY_KEY_ID1,
       VCHAR_COL1_ORIG,
       VCHAR_COL1_NEW,
       REQUEST_ID,
       ACTION_FLAG,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY
    ) SELECT HZ_CUSTOMER_MERGE_LOG_s.nextval,
             'OKC_K_ITEMS',
             CUSTOMER_MERGE_HEADER_ID,
              cim.ID,
              cim.object1_id1,
              to_char(rcm.customer_site_id),
              req_id,
              'U',
              hz_utility_pub.CREATED_BY,
              hz_utility_pub.CREATION_DATE,
              hz_utility_pub.LAST_UPDATE_LOGIN,
              hz_utility_pub.LAST_UPDATE_DATE,
              hz_utility_pub.LAST_UPDATED_BY
      FROM OKC_K_ITEMS cim, ra_customer_merges rcm
         WHERE (
               cim.object1_id1 = to_char(rcm.duplicate_site_id)
         ) AND    rcm.process_flag = 'N'
         AND    rcm.request_id = req_id
         AND    rcm.set_number = set_number
         AND    cim.object1_id1 IN (SELECT to_char(rcm.duplicate_site_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
         AND cim.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_c_site_use);
  End If;

  arp_message.set_name('AR','AR_UPDATING_TABLE');
  arp_message.set_token('TABLE_NAME','OKC_K_ITEMS',FALSE);
  UPDATE okc_k_items cim
  SET cim.object1_id1 = (SELECT DISTINCT to_char(rcm.customer_site_id)
                         FROM ra_customer_merges rcm
                         WHERE cim.object1_id1 = rcm.duplicate_site_id
                           AND rcm.process_flag = 'N'
                           AND rcm.request_id   = req_id
                           AND rcm.set_number   = set_number)
     ,cim.object_version_number = cim.object_version_number + 1
     ,cim.last_update_date      = SYSDATE
     ,cim.last_updated_by       = arp_standard.profile.user_id
     ,cim.last_update_login     = arp_standard.profile.last_update_login
  WHERE cim.object1_id1 IN (SELECT to_char(rcm.duplicate_site_id)
                            FROM ra_customer_merges rcm
                            WHERE rcm.process_flag = 'N'
                              AND rcm.request_id   = req_id
                              AND rcm.set_number   = set_number)
    AND cim.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_c_site_use)
  ;
  l_count := sql%rowcount;
  l_cum_count := l_cum_count + l_count; /*bug9077092*/
  arp_message.set_name('AR','AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS',to_char(l_count));

  arp_message.set_line('OKC_HZ_MERGE_PUB.ACCOUNT_SITE_MERGE()-');

  /*bug9077092 - incrementing minor version even when account merge happens within the parties*/
  IF l_cum_count > 0 AND g_minor_ver_upd_processed = 'N' THEN

   IF l_chr_id.Count > 0 THEN
     FOR k IN l_chr_id.first..l_chr_id.last loop
     INSERT INTO OKC_K_VERS_NUMBERS_H(
                chr_id,
                major_version,
                minor_version,
                object_version_number,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login)
            (SELECT
                chr_id,
                major_version,
                minor_version,
                object_version_number,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login
            FROM OKC_K_VERS_NUMBERS
            WHERE chr_id = l_chr_id(k));

     UPDATE okc_k_vers_numbers ver
     SET  ver.minor_version         = ver.minor_version + 1
     ,ver.object_version_number = ver.object_version_number + 1
     ,ver.last_update_date      = SYSDATE
     ,ver.last_updated_by       = arp_standard.profile.user_id
     ,ver.last_update_login     = arp_standard.profile.last_update_login
     WHERE chr_id = l_chr_id(k);
     END LOOP;
     g_minor_ver_upd_processed := 'Y';
   END IF;
  END IF;
  /*bug9077092 - incrementing minor version even when account merge happens within the parties*/

END; -- account_site_merge

--
-- main account merge routine
--
PROCEDURE merge_account (req_id IN NUMBER
                        ,set_number  IN NUMBER
                        ,process_mode IN VARCHAR2) is

--
-- cursor to get merge reason from merge header
-- to be used later
--
CURSOR c_reason IS
  SELECT cmh.merge_reason_code
  FROM ra_customer_merge_headers cmh
      ,ra_customer_merges cme
  WHERE cmh.customer_merge_header_id = cme.customer_merge_header_id
    AND cme.request_id               = req_id
    AND cme.set_number               = set_number
    AND cme.process_flag             = 'N'
  ;

--
-- cursor to determine if the merge is an account merge,
-- or a site merge within the same account
--
CURSOR c_site_merge(b_request_id NUMBER, b_set_number NUMBER) IS
  SELECT customer_id, duplicate_id
  FROM ra_customer_merges cme
  WHERE cme.request_id   = b_request_id
    AND cme.set_number   = b_set_number
    AND cme.process_flag = 'N'
  ;

--
-- cursor to find party id given the account id
--
CURSOR c_party_id (b_account_id NUMBER) IS
  SELECT party_id
  FROM hz_cust_accounts
  WHERE cust_account_id = b_account_id
;
--
-- cursor to find if any contract is with the party of the
-- merged account
--
CURSOR c_cpr (b_party_id NUMBER) IS
  SELECT kpr.dnz_chr_id
  FROM okc_k_party_roles_b kpr
  WHERE kpr.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_party
                                  )
    AND kpr.object1_id1 = to_char(b_party_id)
  ;
--
-- cursor to find if any contract references a party of the
-- merged account in a contract line
--
CURSOR c_cim (b_party_id NUMBER) IS
  SELECT cim.dnz_chr_id
  FROM okc_k_items cim
  WHERE cim.jtot_object1_code IN (SELECT ojt.object_code
                                  FROM jtf_objects_b ojt
                                      ,jtf_object_usages oue
                                  WHERE ojt.object_code      = oue.object_code
                                    AND oue.object_user_code = c_party
                                  )
    AND cim.object1_id1 = to_char(b_party_id)
  ;
--
-- local variables
--
l_merge_reason              ra_customer_merge_headers.merge_reason_code%type;
l_customer_id               ra_customer_merge_headers.customer_id%type;
l_duplicate_id              ra_customer_merge_headers.duplicate_id%type;
l_source_party_id           hz_parties.party_id%type;
l_target_party_id           hz_parties.party_id%type;
l_chr_id                    okc_k_party_roles_b.dnz_chr_id%type;
l_error_msg                 VARCHAR2(2000);

l_merge_disallowed_excp     EXCEPTION;
l_no_data_found_excp        EXCEPTION;
l_lock_excp                 EXCEPTION;

BEGIN
  arp_message.set_line('OKC_HZ_MERGE_PUB.MERGE_ACCOUNT()+');

  --
  -- check process mode.  If LOCK, then just lock the tables
  --
  IF process_mode = 'LOCK' THEN
    lock_tables(req_id => req_id
               ,set_number => set_number);
    --
    -- that's it, exit
    --
    raise l_lock_excp;
  END IF;

  --
  -- determine if account merge or site merge within account
  --
  OPEN c_site_merge(req_id, set_number);
  FETCH c_site_merge INTO l_customer_id, l_duplicate_id;
  IF c_site_merge%NOTFOUND THEN
    CLOSE c_site_merge;
    RAISE l_no_data_found_excp;
  END IF;

  IF l_customer_id <> l_duplicate_id THEN -- this is an account merge
    --
    -- must first determine if accounts are merged within the same party
    -- so get the two party ids
    --
    OPEN c_party_id(l_duplicate_id);
    FETCH c_party_id INTO l_source_party_id;
    IF c_party_id%NOTFOUND THEN
      CLOSE c_party_id;
      RAISE l_no_data_found_excp;
    END IF;
    CLOSE c_party_id;

    OPEN c_party_id(l_customer_id);
    FETCH c_party_id INTO l_target_party_id;
    IF c_party_id%NOTFOUND THEN
      CLOSE c_party_id;
      RAISE l_no_data_found_excp;
    END IF;
    CLOSE c_party_id;

    IF l_source_party_id <> l_target_party_id THEN
      -- merge across parties, update party info if there is a contract for
      -- the source party
      OPEN c_cpr (l_source_party_id);
      FETCH c_cpr INTO l_chr_id;
      IF c_cpr%FOUND THEN
        party_merge(req_id     => req_id
                   ,set_number => set_number
                   ,l_source_party_id => l_source_party_id
                   ,l_target_party_id => l_target_party_id
                   ,l_duplicate_id    => l_duplicate_id );

        --CLOSE c_cpr;
        --RAISE l_merge_disallowed_excp;  -- do not allow merge
      END IF;
      CLOSE c_cpr;
      --
      -- Below code is commented on May 7 2002
      -- check to see if party is referenced in any line
      -- if so, disallow account merge
      --
      --OPEN c_cim (l_source_party_id);
      --FETCH c_cim INTO l_chr_id;
      --IF c_cim%FOUND THEN
        --CLOSE c_cim;
        --RAISE l_merge_disallowed_excp;  -- do not allow merge
      --END IF;
      --CLOSE c_cim;
      --
      -- party is not used in a contract
      --
    END IF; -- l_source_party_id <> l_target_party_id
    --
    -- to get here, either the party ids are the same
    -- or the "duplicate" party is not a contract party
    -- either way, do the account merge
    account_merge(req_id     => req_id
                 ,set_number => set_number);
    account_site_merge(req_id     => req_id
                      ,set_number => set_number);
  ELSE  -- customer ids the same, this is an account site merge
    account_site_merge(req_id     => req_id
                      ,set_number => set_number);
  END IF; -- if customer ids the same

  arp_message.set_line('OKC_HZ_MERGE_PUB.MERGE_ACCOUNT()-');

EXCEPTION
  WHEN l_merge_disallowed_excp THEN
    arp_message.set_line('Contract exists for duplicate party, merge cannot proceed');
    arp_message.set_error('OKC_HZ_MERGE_PUB.MERGE_ACCOUNT');
    RAISE;
  WHEN l_no_data_found_excp THEN
    arp_message.set_line('No data found for merge information');
    arp_message.set_error('OKC_HZ_MERGE_PUB.MERGE_ACCOUNT');
    RAISE;
  WHEN l_lock_excp THEN -- normal exit after locking
    arp_message.set_line('OKC_HZ_MERGE_PUB.MERGE_ACCOUNT()-');
  WHEN others THEN
    l_error_msg := substr(SQLERRM,1,70);
    arp_message.set_error('OKC_HZ_MERGE_PUB.MERGE_ACCOUNT', l_error_msg);
    RAISE;
END; -- merge_account

END; -- Package Body OKC_HZ_MERGE_PUB

/
