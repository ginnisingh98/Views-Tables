--------------------------------------------------------
--  DDL for Package Body CSP_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_MERGE_PKG" AS
/* $Header: cspvmrgb.pls 120.0.12010000.4 2011/07/26 15:15:11 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_MERGE_PKG
-- Purpose          : Merges duplicate parties in Spares tables. The
--                    Spares tables that need to be considered for
--                    Party Merge are:
--                    CSP_MOVEORDER_HEADERS
--                    CSP_PACKLIST_HEADERS
--                    CSP_RS_CUST_RELATIONS

--
-- History
-- Date           NAME           MODIFICATIONS
-- -----------    -------------  ------------------------------------------
-- 23-JUL-2001    iouyang        Created.
--
--
-- End of Comments


G_PROC_NAME        CONSTANT  VARCHAR2(30)  := 'CSP_MERGE_PKG';
G_USER_ID          CONSTANT  NUMBER(15)    := FND_GLOBAL.USER_ID;
G_LOGIN_ID         CONSTANT  NUMBER(15)    := FND_GLOBAL.LOGIN_ID;

PROCEDURE sds_merge_party_site(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS

   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'merge_party_site';
   l_count                      NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   -- 1. Do all Validations

   -- Check the Merge reason. If Merge Reason is Duplicate Record then no
   -- validation is performed. Otherwise check if the resource is being used
   -- somewhere.
   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
	 -- if reason code is duplicate then allow the party merge to happen
	 -- without any validations.
	 null;
   else
	 -- if there are any validations to be done, include it in this section
	 null;
   end if;

   -- 2. Perform the Merge Operation.

   -- If the parent has NOT changed (ie.Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   if p_from_fk_id = p_to_fk_id then
	 x_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id

   if p_from_fk_id <> p_to_fk_id then
      begin
	    update csp_dedicated_sites
	    set    party_site_id = decode(party_site_id, p_from_fk_id, p_to_fk_id, party_site_id),
	           last_update_date    = SYSDATE,
	           last_updated_by     = G_USER_ID,
	           last_update_login   = G_LOGIN_ID
         where party_site_id = p_from_fk_id;

      Exception
	     when others then
	        FND_MESSAGE.SET_NAME('CSP', 'CSP_PARTY_MERGE_API_EXCEP');
    	        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    		FND_MSG_PUB.ADD;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	        raise;
      end;
   end if;
END sds_merge_party_site;

PROCEDURE mo_merge_party_site(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS

   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'merge_party_site';
   l_count                      NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   -- 1. Do all Validations

   -- Check the Merge reason. If Merge Reason is Duplicate Record then no validation is performed. Otherwise check if the resource is being used somewhere.
   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
   else
	 -- if there are any validations to be done, include it in this section
	 null;
   end if;

   -- 2. Perform the Merge Operation.

   -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   if p_from_fk_id = p_to_fk_id then
	 x_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id

   if p_from_fk_id <> p_to_fk_id then
      begin
	    update csp_moveorder_headers
	    set    party_site_id = decode(party_site_id, p_from_fk_id, p_to_fk_id, party_site_id),
	           last_update_date    = SYSDATE,
	           last_updated_by     = G_USER_ID,
	           last_update_login   = G_LOGIN_ID
         where party_site_id = p_from_fk_id;

      Exception
	     when others then
		    FND_MESSAGE.SET_NAME('CSP', 'CSP_PARTY_MERGE_API_EXCEP');
    	    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    		FND_MSG_PUB.ADD;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	        raise;
      end;
   end if;
END mo_merge_party_site;


PROCEDURE pl_merge_party_site(
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT NOCOPY  NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2)
IS

   l_merge_reason_code          VARCHAR2(30);
   l_api_name                   VARCHAR2(30) := 'merge_party_site';
   l_count                      NUMBER(10)   := 0;

   RESOURCE_BUSY                EXCEPTION;
   PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

BEGIN
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   -- 1. Do all Validations

   -- Check the Merge reason. If Merge Reason is Duplicate Record then no validation is performed. Otherwise check if the resource is being used somewhere.
   select merge_reason_code
   into   l_merge_reason_code
   from   hz_merge_batch
   where  batch_id  = p_batch_id;

   if l_merge_reason_code = 'DUPLICATE' then
	 -- if reason code is duplicate then allow the party merge to happen without
	 -- any validations.
	 null;
   else
	 -- if there are any validations to be done, include it in this section
	 null;
   end if;

   -- 2. Perform the Merge Operation.

   -- If the parent has NOT changed (ie. Parent getting transferred) then nothing
   -- needs to be done. Set Merged To Id is same as Merged From Id and return

   if p_from_fk_id = p_to_fk_id then
	 x_to_id := p_from_id;
      return;
   end if;

   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent. Before transferring check if a similar
   -- dependent record exists on the new parent. If a duplicate exists then do
   -- not transfer and return the id of the duplicate record as the Merged To Id

   if p_from_fk_id <> p_to_fk_id then
      begin
	    update csp_packlist_headers
	    set    party_site_id = decode(party_site_id, p_from_fk_id, p_to_fk_id, party_site_id),
	           last_update_date    = SYSDATE,
	           last_updated_by     = G_USER_ID,
	           last_update_login   = G_LOGIN_ID
         where party_site_id = p_from_fk_id;

      Exception
	     when others then
		    FND_MESSAGE.SET_NAME('CSP', 'CSP_PARTY_MERGE_API_EXCEP');
    	    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    		FND_MSG_PUB.ADD;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	        raise;
      end;
   end if;
END pl_merge_party_site;


PROCEDURE merge_cust_account (
        req_id      Number,
    set_num      Number,
    process_mode    Varchar2)  IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE RS_CUST_RELATION_ID_LIST_TYPE IS TABLE OF
         CSP_RS_CUST_RELATIONS.RS_CUST_RELATION_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST RS_CUST_RELATION_ID_LIST_TYPE;

  TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
         CSP_RS_CUST_RELATIONS.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUSTOMER_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUSTOMER_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct m.CUSTOMER_MERGE_HEADER_ID
              ,yt.RS_CUST_RELATION_ID
              ,yt.CUSTOMER_ID
         FROM CSP_RS_CUST_RELATIONS yt, ra_customer_merges m
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','CSP_RS_CUST_RELATIONS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          limit 1000 ;
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
         'CSP_RS_CUST_RELATIONS',
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
      UPDATE CSP_RS_CUST_RELATIONS yt SET
           CUSTOMER_ID=NUM_COL1_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE RS_CUST_RELATION_ID=PRIMARY_KEY_ID_LIST(I)
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
    arp_message.set_line( 'merge_cust_account');
    RAISE;
END merge_cust_account;

END CSP_MERGE_PKG;

/
