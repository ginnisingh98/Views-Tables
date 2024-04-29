--------------------------------------------------------
--  DDL for Package Body IBE_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_MERGE_PVT" As
/* $Header: IBEVMRGB.pls 120.0 2005/05/30 02:40:49 appldev noship $ */

G_FETCH_LIMIT CONSTANT NUMBER := 1000;
/*----------------------------------------------------------------------------*
 | PRIVATE FUNCTION:                                                          |
 |                  Allow_merge                                               |
 | DESCRIPTION                                                                |
 |               This function takes customer_id and duplicate_id as inputs   |
 |			  returns 'Y' if the cust accounts belongs to same parties.    |
 | REQUIRES                                                                   |
 |                  			                                           |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |  Harish Ekkirala Created 03/27/2001.                                       |
 |                                                                            |
 *----------------------------------------------------------------------------*/
Function Allow_merge(p_customer_id 		NUMBER,
			   	 p_duplicate_id		NUMBER) Return Varchar2
IS
l_party_type          	HZ_PARTIES.PARTY_TYPE%TYPE;
l_party_id	      	HZ_PARTIES.PARTY_ID%TYPE;
l_dup_party_id			HZ_PARTIES.PARTY_ID%TYPE;
l_rel_party_id	      	HZ_PARTIES.PARTY_ID%TYPE;
l_user_id	      		FND_USER.USER_ID%TYPE;

CURSOR party_rel(p_party_id NUMBER) IS
   Select party_id
   From HZ_RELATIONSHIPS
   Where object_id = p_party_id
   and subject_type='PERSON' and object_type='ORGANIZATION';

Begin

	Select party_type,party_id into l_party_type,l_party_id
	From hz_parties
	Where party_id in (Select party_id from hz_cust_accounts
			   Where cust_account_id = p_customer_id);

	Select party_id into l_dup_party_id
	From hz_parties
	Where party_id in (Select party_id from hz_cust_accounts
			   Where cust_account_id = p_duplicate_id);


	If ((l_Party_type = 'ORGANIZATION') AND (l_party_id <> l_dup_party_id)) Then

		Open party_rel(l_party_id);
		Loop
			Fetch party_rel into l_rel_party_id;
			EXIT When party_rel%NOTFOUND;

			Begin

			  Select user_id into l_user_id
			  From  fnd_user_resp_groups
			  Where user_id in (Select user_id from fnd_user
			  Where customer_id = l_rel_party_id)
			  And responsibility_application_id = 671;
			Exception
			  When NO_DATA_FOUND Then
				 l_user_id := Null;
			End;

			If l_user_id is NOT NULL Then
				return ('N');
			End IF;
		End Loop;
		Close party_rel;
	End If;

	Return('Y');
End Allow_merge;


FUNCTION find_party (
       p_account_id NUMBER) RETURN NUMBER IS
    l_party_id NUMBER :=0 ;
  BEGIN
    select PARTY_ID INTO l_party_id
    from hz_cust_accounts
    where cust_account_id=p_account_id;
    IF l_party_id IS NULL THEN
      RETURN l_party_id;
    END IF;
    RETURN l_party_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return l_party_id;
  END;

/*-------------------------------------------------------------
|
|  PROCEDURE
|      acc_merge_oneclick
|  DESCRIPTION :
|      Account merge procedure for the table, IBE_ORD_ONECLICK_ALL
|
|
|--------------------------------------------------------------*/
procedure acc_merge_oneclick (
			 req_id 	NUMBER,
			 set_num 	NUMBER,
			 Process_MODE 	VARCHAR2)
        IS
  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE ORD_ONECLICK_ID_LIST_TYPE IS TABLE OF
         IBE_ORD_ONECLICK_ALL.ORD_ONECLICK_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST ORD_ONECLICK_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
         IBE_ORD_ONECLICK_ALL.CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  TYPE PARTY_ID_LIST_TYPE IS TABLE OF
         IBE_ORD_ONECLICK_ALL.PARTY_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST PARTY_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST PARTY_ID_LIST_TYPE;
  l_acct_id number;
  l_profile_val VARCHAR2(30);
  l_ord_oneclick_id IBE_ORD_ONECLICK_ALL.ORD_ONECLICK_ID%TYPE;

  --cursor to get <merge to> party, account ID and primary key for shopping lists
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,yt.ord_oneclick_id
              ,yt.CUST_ACCOUNT_ID
              ,yt.party_id
         FROM IBE_ORD_ONECLICK_ALL yt, ra_customer_merges m
         WHERE
             yt.CUST_ACCOUNT_ID = m.DUPLICATE_ID
         AND m.process_flag = 'N'
         AND m.request_id = req_id
         AND m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','IBE_SH_SHP_LISTS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');
    --cursor to get <merge to> party and account ID
    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
      limit G_FETCH_LIMIT;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;

      --fix 2899235: do not transfer exp chkout setting
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
            insert into HZ_CUSTOMER_MERGE_LOG (MERGE_LOG_ID, TABLE_NAME,
                    MERGE_HEADER_ID,request_id,PRIMARY_KEY_ID,DEL_COL1,DEL_COL2,DEL_COL3,
                    DEL_COL4,DEL_COL5,DEL_COL6,DEL_COL7,DEL_COL8,DEL_COL9,DEL_COL10,DEL_COL11,DEL_COL12,
                    DEL_COL13,DEL_COL14,DEL_COL15,DEL_COL16,DEL_COL17,DEL_COL18,DEL_COL19,DEL_COL20,DEL_COL21,
                    DEL_COL22,DEL_COL23,DEL_COL24,DEL_COL25,DEL_COL26,DEL_COL27,DEL_COL28,DEL_COL29,DEL_COL30,
                    DEL_COL31,DEL_COL32,DEL_COL33,DEL_COL34,DEL_COL35,ACTION_FLAG,CREATED_BY,CREATION_DATE,LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,LAST_UPDATED_BY)
            select HZ_CUSTOMER_MERGE_LOG_s.nextval,'IBE_ORD_ONECLICK_ALL',MERGE_HEADER_ID_LIST(I)
                    ,req_id,ORD_ONECLICK_ID,OBJECT_VERSION_NUMBER, CUST_ACCOUNT_ID, PARTY_ID, CREATED_BY, CREATION_DATE,
                     LAST_UPDATED_BY,LAST_UPDATE_DATE, LAST_UPDATE_LOGIN, ENABLED_FLAG, FREIGHT_CODE, PAYMENT_ID,
                     BILL_TO_PTY_SITE_ID, SHIP_TO_PTY_SITE_ID,ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3,
                     ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11,
                     ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, SECURITY_GROUP_ID, REQUEST_ID, PROGRAM_ID,
                     PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE, ORG_ID, 'D',hz_utility_pub.CREATED_BY,
                     hz_utility_pub.CREATION_DATE, hz_utility_pub.LAST_UPDATE_LOGIN, hz_utility_pub.LAST_UPDATE_DATE,
                     hz_utility_pub.LAST_UPDATED_BY
            from IBE_ORD_ONECLICK_ALL  where ORD_ONECLICK_ID=PRIMARY_KEY_ID_LIST(I);
         end if;
            delete IBE_ORD_ONECLICK_ALL
            where  ORD_ONECLICK_ID=PRIMARY_KEY_ID_LIST(I);

      END LOOP;
      --fix 2899235: do not transfer exp chkout setting
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;
    close merged_records;
    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'acc_merge_oneclick');
    RAISE;
END acc_merge_oneclick;



/*-------------------------------------------------------------
|
|  PROCEDURE
|      acc_merge_shp_lists
|  DESCRIPTION :
|      Account merge procedure for the table, IBE_SH_SHP_LISTS_ALL
|
|
|--------------------------------------------------------------*/
procedure acc_merge_shp_lists (
			 req_id 	NUMBER,
			 set_num 	NUMBER,
			 Process_MODE 	VARCHAR2,
             customer_type  VARCHAR2)
        IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE SHP_LIST_ID_LIST_TYPE IS TABLE OF
         IBE_SH_SHP_LISTS_ALL.SHP_LIST_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST SHP_LIST_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
         IBE_SH_SHP_LISTS_ALL.CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  TYPE PARTY_ID_LIST_TYPE IS TABLE OF
         IBE_SH_SHP_LISTS_ALL.PARTY_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST PARTY_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST PARTY_ID_LIST_TYPE;
  l_acct_id number;
  l_profile_val VARCHAR2(30);

  --cursor to get <merge to> party, account ID and primary key for shopping lists
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,yt.SHP_LIST_ID
              ,yt.CUST_ACCOUNT_ID
              ,yt.party_id
         FROM IBE_SH_SHP_LISTS_ALL yt, ra_customer_merges m
         WHERE
             yt.CUST_ACCOUNT_ID = m.DUPLICATE_ID
         AND m.process_flag = 'N'
         AND m.request_id = req_id
         AND m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','IBE_SH_SHP_LISTS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');
    --cursor to get <merge to> party and account ID
    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
      limit G_FETCH_LIMIT;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
        --get <merge to> party and account ID
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
         --fix for 2935845
         if customer_type = 'CUSTOMER_ORG' then
            --B2B, partyID stays the same
            NUM_COL2_NEW_LIST(I) := NUM_COL2_ORIG_LIST(I);
         else
            --B2C, partyID changes to what's tied to accountID
            NUM_COL2_NEW_LIST(I) := find_party(NUM_COL1_NEW_LIST(I));
         end if;
         UPDATE IBE_SH_SHP_LISTS_ALL yt SET
              CUST_ACCOUNT_ID=NUM_COL1_NEW_LIST(I)
              ,PARTY_ID=NUM_COL2_NEW_LIST(I)
              , LAST_UPDATE_DATE=SYSDATE
              , last_updated_by=arp_standard.profile.user_id
              , last_update_login=arp_standard.profile.last_update_login
              , REQUEST_ID=request_id
              , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
              , PROGRAM_ID=arp_standard.profile.program_id
              , PROGRAM_UPDATE_DATE=SYSDATE
          WHERE SHP_LIST_ID=PRIMARY_KEY_ID_LIST(I);

      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
         --if logging profile is ON, log data
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
         'IBE_SH_SHP_LISTS_ALL',
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
    END LOOP;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;
    close merged_records;
    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'acc_merge_shp_lists');
    RAISE;
END acc_merge_shp_lists;




/*-------------------------------------------------------------
|
|  PROCEDURE
|      acc_merge_active_quotes
|  DESCRIPTION :
|      Account merge procedure for the table, IBE_ACTIVE_QUOTES_ALL
|
|--------------------------------------------------------------*/

PROCEDURE acc_merge_active_quotes (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE ACTIVE_QUOTE_ID_LIST_TYPE IS TABLE OF
         IBE_ACTIVE_QUOTES_ALL.ACTIVE_QUOTE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST ACTIVE_QUOTE_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
         IBE_ACTIVE_QUOTES_ALL.CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  TYPE PARTY_ID_LIST_TYPE IS TABLE OF
         IBE_ACTIVE_QUOTES_ALL.PARTY_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST PARTY_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST PARTY_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  l_from_quote_id     NUMBER;
  l_from_party_id     NUMBER;
  l_from_acct_id      NUMBER;
  l_to_acct_id        NUMBER;
  l_from_quote_name   VARCHAR2(80);
  l_customer_merge_id number;

  --cursor to get <merge from> account and party IDs, quote name and quote_header_id
  Cursor  C_ACTIVE_QUOTE_FROM is
    Select  a.quote_header_id, a.cust_account_id, a.party_id, b.quote_name, racm.customer_merge_id
    from    IBE_ACTIVE_QUOTES_ALL a, ASO_QUOTE_HEADERS_ALL b, RA_CUSTOMER_MERGES RACM
    Where   a.quote_header_id = b.quote_header_id (+)
    and     a.party_id  = b.party_id (+)
    and     a.cust_account_id = b.cust_account_id (+)
    and     a.cust_account_id = racm.duplicate_id
    and     a.record_type     = 'CART'
    and     RACM.PROCESS_FLAG='N' AND  RACM.REQUEST_ID = req_id
    and     RACM.SET_NUMBER = set_num;

  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','IBE_ACTIVE_QUOTES',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open C_ACTIVE_QUOTE_FROM;
    loop
        --get active quote for <merge from> account
        Fetch C_ACTIVE_QUOTE_FROM into l_from_quote_id, l_from_acct_id,
        l_from_party_id, l_from_quote_name, l_customer_merge_id;
        EXIT When C_ACTIVE_QUOTE_FROM%NOTFOUND;
        Begin
            --2967340
            --if <merge from> has an unnamed cart, update it to be default
               update ASO_QUOTE_HEADERS_ALL
               set QUOTE_NAME = 'IBE_PRMT_SC_DEFAULTNAMED'
               where quote_header_id = l_from_quote_id
                AND quote_name = 'IBE_PRMT_SC_UNNAMED';
               --check profile, log when it's ON
               IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
                 INSERT INTO HZ_CUSTOMER_MERGE_LOG (
                   MERGE_LOG_ID,TABLE_NAME,MERGE_HEADER_ID,PRIMARY_KEY_ID,
                   VCHAR_COL1_ORIG,VCHAR_COL1_NEW,ACTION_FLAG,REQUEST_ID,CREATED_BY,
                   CREATION_DATE,LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,LAST_UPDATED_BY
                ) VALUES (
                 HZ_CUSTOMER_MERGE_LOG_s.nextval,'ASO_QUOTE_HEADERS_ALL',
                 l_customer_merge_id,l_from_quote_id,'IBE_PRMT_SC_UNNAMED','IBE_PRMT_SC_DEFAULTNAMED',
                 'U',req_id,hz_utility_pub.CREATED_BY,
                 hz_utility_pub.CREATION_DATE,hz_utility_pub.LAST_UPDATE_LOGIN,
                 hz_utility_pub.LAST_UPDATE_DATE,hz_utility_pub.LAST_UPDATED_BY
                );
               end if;

            --log data when audit profile is On
            IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
                insert into HZ_CUSTOMER_MERGE_LOG (MERGE_LOG_ID, TABLE_NAME,
                    MERGE_HEADER_ID,request_id,PRIMARY_KEY_ID,DEL_COL1,DEL_COL2,DEL_COL3,
                    DEL_COL4,DEL_COL5,DEL_COL6,DEL_COL7,DEL_COL8,DEL_COL9,DEL_COL10,DEL_COL11,ACTION_FLAG,
                    CREATED_BY,CREATION_DATE,LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,LAST_UPDATED_BY)
                select HZ_CUSTOMER_MERGE_LOG_s.nextval,'IBE_ACTIVE_QUOTES_ALL',l_customer_merge_id
                    ,req_id,ACTIVE_QUOTE_ID,PARTY_ID,CUST_ACCOUNT_ID,ORG_ID,CREATED_BY,CREATION_DATE
                    ,LAST_UPDATED_BY,LAST_UPDATE_DATE,OBJECT_VERSION_NUMBER,LAST_UPDATE_LOGIN
                    ,SECURITY_GROUP_ID,QUOTE_HEADER_ID,'D',hz_utility_pub.CREATED_BY,hz_utility_pub.CREATION_DATE,
                    hz_utility_pub.LAST_UPDATE_LOGIN, hz_utility_pub.LAST_UPDATE_DATE,hz_utility_pub.LAST_UPDATED_BY
                from ibe_active_quotes_all where quote_header_id=l_from_quote_id
                     and cust_account_id = l_from_acct_id and party_id=l_from_party_id;

            end if;
            --delete active quote row for <merge from>
            delete ibe_active_quotes_all
            where quote_header_id = l_from_quote_id
                  and cust_account_id = l_from_acct_id
                  and party_id=l_from_party_id;
        End;

   END LOOP;
   close C_ACTIVE_QUOTE_FROM;
    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'acc_merge_active_quotes');
    RAISE;
END acc_merge_active_quotes;


/*-------------------------------------------------------------
|
|  PROCEDURE
|      acc_merge_shared_quote
|  DESCRIPTION :
|      Account merge procedure for the table, IBE_SH_QUOTE_ACCESS
|
|--------------------------------------------------------------*/

PROCEDURE acc_merge_shared_quote (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2,
        customer_type                VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE QUOTE_SHAREE_ID_LIST_TYPE IS TABLE OF
         IBE_SH_QUOTE_ACCESS.QUOTE_SHAREE_ID%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST QUOTE_SHAREE_ID_LIST_TYPE;

  TYPE CUST_ACCOUNT_ID_LIST_TYPE IS TABLE OF
         IBE_SH_QUOTE_ACCESS.CUST_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST CUST_ACCOUNT_ID_LIST_TYPE;
  NUM_COL1_NEW_LIST CUST_ACCOUNT_ID_LIST_TYPE;

  TYPE PARTY_ID_LIST_TYPE IS TABLE OF
         IBE_SH_QUOTE_ACCESS.PARTY_ID%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST PARTY_ID_LIST_TYPE;
  NUM_COL2_NEW_LIST PARTY_ID_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  l_customer_merge_header_id number;
  l_quote_sharee_number number(15,0);
  l_request_id number;
  l_program_application_id number;
  l_program_id number;
  l_program_update_date date;
  l_object_version_number number(9,0);
  l_created_by number;
  l_creation_date date;
  l_last_updated_by number;
  l_last_update_date date;
  l_last_update_login number;
  l_quote_header_id number(15,0);
  l_to_quote_sharee_id number(15,0);
  l_from_quote_sharee_id number(15,0);
  l_update_privilege_type_code varchar2(30);
  l_security_group_id number;
  l_party_id number;
  l_cust_account_id number;
  l_start_date_active date;
  l_end_date_active date;
  l_recipient_name varchar2(2000);
  l_contact_point_id number;
  l_from_quote_id number;
  l_from_party_id number;
  l_from_acct_id number;
  l_to_acct_id number;
  l_to_party_id number;
  l_delete_flag boolean:=TRUE;
  /*retrive <merge from> account shared carts*/
   Cursor C_SHARED_QUOTE_FROM  is
        Select distinct customer_merge_header_id,quote_header_id,
                i.party_id, RACM.DUPLICATE_ID, RACM.CUSTOMER_ID,quote_sharee_id
        from   IBE_SH_QUOTE_ACCESS i, RA_CUSTOMER_MERGES RACM
        Where  i.cust_account_id = RACM.DUPLICATE_ID
           AND RACM.PROCESS_FLAG='N'
		   AND RACM.REQUEST_ID = req_id
		   AND RACM.SET_NUMBER = set_num;


   l_last_fetch BOOLEAN := FALSE;
   l_count NUMBER;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','IBE_SH_QUOTE_ACCESS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    --retrieve <merge from> shared carts
    Open C_SHARED_QUOTE_FROM;
    	Loop
    		Fetch C_SHARED_QUOTE_FROM into l_customer_merge_header_id,l_from_quote_id,
            l_from_party_id, l_from_acct_id, l_to_acct_id,l_from_quote_sharee_id;
			EXIT When C_SHARED_QUOTE_FROM%NOTFOUND;
			Begin
            l_delete_flag:=TRUE;
              --check if <merge to> has same share cart as merge from
			  Select quote_sharee_id, request_id,program_application_id,program_id,program_update_date,
                     object_version_number,created_by,creation_date,last_updated_by,last_update_date,
                     last_update_login,quote_header_id,quote_sharee_number,update_privilege_type_code,
                     security_group_id,party_id,cust_account_id,start_date_active,end_date_active,recipient_name,
                     contact_point_id
              into   l_to_quote_sharee_id,l_request_id,l_program_application_id,l_program_id,
                     l_program_update_date,l_object_version_number,l_created_by,l_creation_date,
                     l_last_updated_by,l_last_update_date,l_last_update_login,l_quote_header_id,
                     l_quote_sharee_number,l_update_privilege_type_code,l_security_group_id,l_party_id,
                     l_cust_account_id,l_start_date_active,l_end_date_active,l_recipient_name,l_contact_point_id
    		  From  IBE_SH_QUOTE_ACCESS
			  Where quote_header_id = l_from_quote_id
              and cust_account_id = l_to_acct_id
              --if multiple rows exist for with same quote header ID and account ID
              and rownum=1
              ;
            EXCEPTION
                When NO_DATA_FOUND Then
                l_delete_flag:=FALSE;
             END;

              /* Delete/end_date since it's a duplicate row in shared cart table
                 If both has same shared cart, delete <merge from> row.
                 Log delete info.*/
             --debug: need TCA profile for test
             --actual delete
             if l_delete_flag  then

                  delete IBE_SH_QUOTE_ACCESS
                  where  quote_header_id = l_from_quote_id
                  and cust_account_id = l_from_acct_id;
                  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
                    insert into HZ_CUSTOMER_MERGE_LOG (
                        MERGE_LOG_ID, TABLE_NAME,MERGE_HEADER_ID,PRIMARY_KEY_ID,
                        DEL_COL1,DEL_COL2,DEL_COL3,DEL_COL4,DEL_COL5,DEL_COL6,DEL_COL7,DEL_COL8,
                        DEL_COL9,DEL_COL10,DEL_COL11,DEL_COL12,DEL_COL13,DEL_COL14,DEL_COL15,
                        DEL_COL16,DEL_COL17,DEL_COL18,DEL_COL19,DEL_COL20,ACTION_FLAG,
                        REQUEST_ID,CREATED_BY,CREATION_DATE,LAST_UPDATE_LOGIN,LAST_UPDATE_DATE,
                        LAST_UPDATED_BY)
                    values(
                        HZ_CUSTOMER_MERGE_LOG_s.nextval,'IBE_SH_QUOTE_ACCESS',l_customer_merge_header_id,
                        l_from_quote_sharee_id,l_request_id,l_program_application_id,l_program_id,
                        l_program_update_date,l_object_version_number,l_created_by,l_creation_date,
                        l_last_updated_by,l_last_update_date,l_last_update_login,l_quote_header_id,
                        l_quote_sharee_number,l_update_privilege_type_code,l_security_group_id,l_party_id,
                        l_cust_account_id,l_start_date_active,l_end_date_active,l_recipient_name,
                        l_contact_point_id,'D',req_id,hz_utility_pub.CREATED_BY, hz_utility_pub.CREATION_DATE,
                        hz_utility_pub.LAST_UPDATE_LOGIN, hz_utility_pub.LAST_UPDATE_DATE,
                        hz_utility_pub.LAST_UPDATED_BY );
                   end if;
              else
                --if <merge from> shared cart not a duplicate of <merge to>, update party/account ID to merge to
         	    arp_message.set_name('AR', 'AR_UPDATING_TABLE');
                arp_message.set_token('TABLE_NAME', 'IBE_SH_QUOTE_ACCESS', FALSE);
                --fix for 2940366
                if customer_type = 'CUSTOMER_ORG' then
                --B2B, partyID stays the same
                   l_to_party_id := l_from_party_id;
                else
                --B2C, partyID changes to what's tied to accountID
                    l_to_party_id := find_party(l_to_acct_id);
                end if;
                --debug: need TCA profile for test
                IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN

                  INSERT INTO HZ_CUSTOMER_MERGE_LOG (
                       MERGE_LOG_ID,TABLE_NAME,MERGE_HEADER_ID,PRIMARY_KEY_ID,NUM_COL1_ORIG,NUM_COL1_NEW,
                       NUM_COL2_ORIG,NUM_COL2_NEW,ACTION_FLAG,REQUEST_ID,CREATED_BY,CREATION_DATE,LAST_UPDATE_LOGIN,
                       LAST_UPDATE_DATE,LAST_UPDATED_BY
                  ) VALUES (
                         HZ_CUSTOMER_MERGE_LOG_s.nextval,
                         'IBE_SH_QUOTE_ACCESS',l_customer_merge_header_id,l_from_quote_sharee_id,l_from_acct_id,
                         l_to_acct_id, l_from_party_id, l_to_party_id,'U',req_id,hz_utility_pub.CREATED_BY,
                         hz_utility_pub.CREATION_DATE,hz_utility_pub.LAST_UPDATE_LOGIN,hz_utility_pub.LAST_UPDATE_DATE,
                         hz_utility_pub.LAST_UPDATED_BY
                  );
                end if;
                --update shared cart

    		    UPDATE IBE_SH_QUOTE_ACCESS ISQ SET
         			party_id =  l_to_party_id,
                    cust_account_id = l_to_acct_id,
                    last_update_date = hz_utility_pub.last_update_date,
                    last_updated_by  = hz_utility_pub.user_id,
                    last_update_login = hz_utility_pub.last_update_login,
                    request_id = hz_utility_pub.request_id,
                    program_application_id = hz_utility_pub.program_application_id,
                    program_id = hz_utility_pub.program_id,
                    program_update_date = sysdate
                Where cust_account_id = l_from_acct_id
                And   party_id = l_from_party_id
                And   quote_header_id = l_from_quote_id;

              end if;
      END LOOP;
  CLOSE C_SHARED_QUOTE_FROM;
 END if;
END acc_merge_shared_quote;


/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURES                                                          |
 |                CUSTOMER_MERGE -- When in ERP Customers are merged the      |
 |                  The Foriegn keys to cust_account_id should also be updated|
 |                  in iStore tables.  This procedure will be invoked by      |
 |                  Customer Merge concurrent program.                        |
 | DESCRIPTION                                                                |
 |                                                                            |
 | REQUIRES                                                                   |
 |                                                                            |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |  Harish Ekkirala Created 11/06/2000.                                       |
 |                                                                            |
 *----------------------------------------------------------------------------*/

PROCEDURE CUSTOMER_MERGE(
			 Request_id 	NUMBER,
			 Set_Number 	NUMBER,
			 Process_MODE 	VARCHAR2
			)
IS

g_count 		NUMBER;
p_request_id	NUMBER;
p_customer_id	RA_CUSTOMER_MERGES.CUSTOMER_ID%TYPE;
p_duplicate_id	RA_CUSTOMER_MERGES.DUPLICATE_ID%TYPE;
p_allow_merge	VARCHAR2(1) := 'Y';
p_customer_type  RA_CUSTOMER_MERGES.CUSTOMER_TYPE%TYPE;
l_from_quote_id     NUMBER;
l_from_party_id     NUMBER;
l_from_acct_id      NUMBER;
l_to_acct_id        NUMBER;
l_sharee_id         NUMBER;
l_from_quote_name       VARCHAR2(80);
l_request_id         NUMBER := request_id;
l_set_number         NUMBER := set_number;
MERGE_NOT_ALLOWED EXCEPTION;

CURSOR C is
SELECT 'X' from IBE_SH_SHP_LISTS_ALL ISA
WHERE ISA.CUST_ACCOUNT_ID IN (SELECT RACM.DUPLICATE_ID
			      FROM RA_CUSTOMER_MERGES RACM
			      WHERE RACM.PROCESS_FLAG='N'
			      AND RACM.REQUEST_ID = request_id
			      AND RACM.SET_NUMBER = set_number)
FOR UPDATE NOWAIT;

CURSOR C1 is
SELECT 'X' from IBE_ORD_ONECLICK_ALL IOO
WHERE IOO.CUST_ACCOUNT_ID IN (SELECT RACM.DUPLICATE_ID
			      FROM RA_CUSTOMER_MERGES RACM
			      WHERE RACM.PROCESS_FLAG='N'
			      AND RACM.REQUEST_ID = request_id
			      AND RACM.SET_NUMBER = set_number)
FOR UPDATE NOWAIT;

CURSOR C2 is
SELECT 'X' from IBE_SH_QUOTE_ACCESS ISQ
WHERE ISQ.CUST_ACCOUNT_ID IN (SELECT RACM.DUPLICATE_ID
			      FROM RA_CUSTOMER_MERGES RACM
			      WHERE RACM.PROCESS_FLAG='N'
			      AND RACM.REQUEST_ID = request_id
			      AND RACM.SET_NUMBER = set_number)
FOR UPDATE NOWAIT;

CURSOR C3 is
SELECT 'X' from IBE_ACTIVE_QUOTES_ALL IAQ
WHERE IAQ.CUST_ACCOUNT_ID IN (SELECT RACM.DUPLICATE_ID
			      FROM RA_CUSTOMER_MERGES RACM
			      WHERE RACM.PROCESS_FLAG='N'
			      AND RACM.REQUEST_ID = Request_id
			      AND RACM.SET_NUMBER = Set_Number)
FOR UPDATE NOWAIT;

--2940366 add customer type, change requestID
CURSOR C_CUST (req_id NUMBER) is
SELECT RACM.CUSTOMER_ID,RACM.DUPLICATE_ID,RACM.CUSTOMER_TYPE
FROM RA_CUSTOMER_MERGES RACM
WHERE RACM.PROCESS_FLAG='N'
AND RACM.REQUEST_ID = req_id
AND RACM.SET_NUMBER = set_number;

BEGIN

	arp_message.set_line('IBE_MERGE_PVT.CUSTOMER_MERGE()+');

	p_request_id := request_id;

/* Check to See if you can allow the customer merge to happen */

	Open C_CUST(p_request_id);
	Loop
        --2940366
		Fetch C_CUST into p_customer_id,p_duplicate_id,p_customer_type;
		Exit When C_CUST%NOTFOUND;

		p_allow_merge := allow_merge(p_customer_id,p_duplicate_id);

		If p_allow_merge = 'N' Then
			Close c_cust;
			Raise MERGE_NOT_ALLOWED;
		End IF;

	End Loop;
	Close C_CUST;

    /*obsolete code after consulting with TCA, lock mode not used*/
    /*
	If process_mode = 'LOCK' then

		arp_message.set_name('AR','AR_LOCKING_TABLE');
		arp_message.set_token('TABLE_NAME','IBE_SH_SHP_LISTS_ALL',FALSE);

		open C;
		close C;

		arp_message.set_name('AR','AR_LOCKING_TABLE');
		arp_message.set_token('TABLE_NAME','IBE_ORD_ONECLICK_ALL',FALSE);

		open C1;
		close C1;

		arp_message.set_name('AR','AR_LOCKING_TABLE');
		arp_message.set_token('TABLE_NAME','IBE_SH_QUOTE_ACCESS',FALSE);

		open C2;
		close C2;

	End If; */

	arp_message.set_name('AR','AR_UPDATING_TABLE');
	arp_message.set_token('TABLE_NAME','IBE_SH_SHP_LISTS_ALL',FALSE);

    /* For updating IBE_SH_SHP_LISTS_ALL table*/
    --2940366
    acc_merge_shp_lists(request_id,set_number,process_mode,p_customer_type);
	g_count := sql%rowcount;
	arp_message.set_name('AR','AR_ROWS_UPDATED');
	arp_message.set_token('NUM_ROWS',to_char(g_count));

    /* For updating IBE_ORD_ONECLICK_ALL Table */
    /* 4/8/02
    If oneclick table already has entry for the merge to account, ignore and do nothing
    */
    acc_merge_oneclick(request_id,set_number,process_mode);
	arp_message.set_name('AR','AR_UPDATING_TABLE');
	arp_message.set_token('TABLE_NAME','IBE_ORD_ONECLICK_ALL',FALSE);
	g_count := sql%rowcount;


    /*  account merge for shared quote
        12/18/02
    */
    --2940366
    acc_merge_shared_quote(request_id,set_number,process_mode,p_customer_type);
  	arp_message.set_name('AR','AR_UPDATING_TABLE');
  	arp_message.set_token('TABLE_NAME','IBE_SH_QUOTE_ACCESS',FALSE);
	arp_message.set_name('AR','AR_ROWS_UPDATED');
	arp_message.set_token('NUM_ROWS',to_char(g_count));


  /*merge active cart
    12/18/02
  */
     acc_merge_active_quotes(request_id,set_number,process_mode);
     arp_message.set_name('AR','AR_UPDATING_TABLE');
	 arp_message.set_token('TABLE_NAME','IBE_ACTIVE_QUOTES_ALL',FALSE);
     arp_message.set_name('AR','AR_ROWS_UPDATED');
	 arp_message.set_token('NUM_ROWS',to_char(g_count));


 	arp_message.set_line('IBE_MERGE_PVT.CUSTOMER_MERGE()-');

EXCEPTION

	WHEN MERGE_NOT_ALLOWED THEN
		arp_message.set_name('IBE','IBE_MERGE_NOT_ALLOWED');
		arp_message.set_error('IBE_MERGE_PVT.CUSTOMER_MERGE');
		raise;

	WHEN OTHERS THEN
		arp_message.set_error('IBE_MERGE_PVT.CUSTOMER_MERGE');
		raise;

End Customer_Merge;

/*----------------------------------------------------------------------------*
| PUBLIC PROCEDURES                                                          |
|                  MERGE_SHP_LISTS -- 					           |
|			 When in ERP Parties are merged the	      	           |
|                  The Foriegn keys to party_id and other columns            |
|			 should also be updated in iStore tables.  		     |
|                  This procedure will update IBE_SH_SHP_LISTS_ALL table     |
|                  and will be called from party Merge concurrent program.   |
| DESCRIPTION                                                                |
|                                                                            |
| REQUIRES                                                                   |
|                                                                            |
|                                                                            |
| EXCEPTIONS RAISED                                                          |
|                                                                            |
| KNOWN BUGS                                                                 |
|                                                                            |
| NOTES                                                                      |
|                                                                            |
| HISTORY                                                                    |
|  Harish Ekkirala Created 02/12/2001.                                       |
|                                                                            |
*----------------------------------------------------------------------------*/

PROCEDURE MERGE_SHIP_LISTS(
			P_entity_name		IN		VARCHAR2,
			P_from_id			IN		NUMBER,
			X_to_id			OUT		NOCOPY NUMBER,
			P_from_fk_id		IN		NUMBER,
			P_to_fk_id			IN		NUMBER,
			P_parent_entity_name	IN		VARCHAR2,
			P_batch_id			IN		NUMBER,
			P_batch_party_id		IN		NUMBER,
			X_return_status		OUT		NOCOPY VARCHAR2
				)
IS

Cursor C1 is
Select 'X' from
IBE_SH_SHP_LISTS_ALL
Where party_id = p_from_fk_id
for update nowait;

l_merge_reason_code 	VARCHAR2(30);
l_count                 NUMBER(10)   := 0;

RESOURCE_BUSY           EXCEPTION;
PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);


Begin

arp_message.set_line('IBE_MERGE_PVT.MERGE_SHIP_LISTS()+');

x_return_status :=  FND_API.G_RET_STS_SUCCESS;



--Do All Validations

	--Check the Merge Reason code. If the merge reason is duplicate record, then no validation is required.
	-- Otherwise do the required validations.

-- Commenting this section for now as we are not doing any validations, if the reason is not 'Duplicate Record'.
--   In future if we need any validations we can un comment this sections and add validations.
/*
	Select merge_reason_code
	Into l_merge_reason_code
	From hz_merge_batch
	Where batch_id = p_batch_id;

	If l_merge_reason_code = 'DUPLICATE' Then
		null;
	Else
		null;
	End If;
*/

/* Perform the merge operation */

/* If the parent has NOT Changed(i.e Parent is getting transfered), then nothing needs to be done. Set Merge To id same
   as Merged from id and return */

   if p_from_fk_id = p_to_fk_id then
		x_to_id := p_from_id;
		return;
   End If;

/* If the Parent has changed(i.e. Parent is getting merged), then transfer the dependent record to the new parent. */

   if p_from_fk_id <> p_to_fk_id Then

 	arp_message.set_name('AR', 'AR_LOCKING_TABLE');
 	arp_message.set_token('TABLE_NAME', 'IBE_SH_SHP_LISTS_ALL', FALSE);

	Open C1;
	Close C1;

	arp_message.set_name('AR', 'AR_UPDATING_TABLE');
 	arp_message.set_token('TABLE_NAME', 'IBE_SH_SHP_LISTS_ALL', FALSE);

	UPDATE IBE_SH_SHP_LISTS_ALL isl SET
			party_id = p_to_fk_id,
			last_update_date = hz_utility_pub.last_update_date,
			last_updated_by  = hz_utility_pub.user_id,
			last_update_login = hz_utility_pub.last_update_login,
			request_id = hz_utility_pub.request_id,
			program_application_id = hz_utility_pub.program_application_id,
			program_id = hz_utility_pub.program_id,
			program_update_date = sysdate
	Where party_id = p_from_fk_id;


	l_count := sql%rowcount;

	arp_message.set_name('AR', 'AR_ROWS_UPDATED');
	arp_message.set_token('NUM_ROWS', to_char(l_count) );

	return;

   End If;

arp_message.set_line('IBE_MERGE_PVT.MERGE_SHIP_LISTS()-');


Exception
	When RESOURCE_BUSY Then
		arp_message.set_line('IBE_MERGE_PVT.MERGE_SHIP_LISTS; Could not obtain lock'||
					'on table IBE_SH_SHP_LISTS_ALL');

		 x_return_status :=  FND_API.G_RET_STS_ERROR;
		 raise;
	When Others Then

		arp_message.set_line('IBE_MERGE_PVT.MERGE_SHIP_LISTS'||sqlerrm);

		x_return_status :=  FND_API.G_RET_STS_ERROR;
		raise;

End MERGE_SHIP_LISTS;

/*----------------------------------------------------------------------------*
| PUBLIC PROCEDURES                                                          |
|		MERRGE_ONECLICK -- 					     		     	     |
|			 When in ERP Parties are merged the	      	           |
|                  The Foriegn keys to party_id and other columns            |
|			 should also be updated in iStore tables.  		     |
|                  This procedure will update					     |
|			 IBE_ORD_ONECLICK_ALL table and will be called from party      |
|			 Merge concurrent program.   					     |
| DESCRIPTION   						   				     |
|                                                                            |
| REQUIRES                                                                   |
|                                                                            |
|                                                                            |
| EXCEPTIONS RAISED                                                          |
|                                                                            |
| KNOWN BUGS                                                                 |
|                                                                            |
| NOTES                                                                      |
|                                                                            |
| HISTORY                                                                    |
|  Harish Ekkirala Created 02/12/2001.                                       |
|                                                                            |
*----------------------------------------------------------------------------*/
PROCEDURE MERGE_ONECLICK(
			P_entity_name		IN		VARCHAR2,
			P_from_id			IN		NUMBER,
			X_to_id			OUT		NOCOPY NUMBER,
			P_from_fk_id		IN		NUMBER,
			P_to_fk_id			IN		NUMBER,
			P_parent_entity_name	IN		VARCHAR2,
			P_batch_id			IN		NUMBER,
			P_batch_party_id		IN		NUMBER,
			X_return_status		OUT	NOCOPY 	VARCHAR2
				)
IS

Cursor C1 is
Select 'X' from
IBE_ORD_ONECLICK_ALL
where party_id = p_from_fk_id
for update nowait;

Cursor C2 is
Select 'X' from
IBE_ORD_ONECLICK_ALL
Where bill_to_pty_site_id = p_from_fk_id
Or ship_to_pty_site_id = p_from_fk_id
for update nowait;

l_ord_oneclick_id		IBE_ORD_ONECLICK_ALL.ORD_ONECLICK_ID%TYPE;
l_merge_reason_code 	VARCHAR2(30);
l_count                 NUMBER(10)   := 0;
RESOURCE_BUSY           EXCEPTION;
PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

Begin

arp_message.set_line('IBE_MERGE_PVT.MERGE_ONECLICK()+');

x_return_status :=  FND_API.G_RET_STS_SUCCESS;

--Do All Validations

	--Check the Merge Reason code. If the merge reason is duplicate record, then no validation is required.
	-- Otherwise do the required validations.

-- Commenting this section for now as we are not doing any validations, if the reason is not 'Duplicate Record'.
--   In future if we need any validations we can un comment this sections and add validations.

/*
	Select merge_reason_code
	Into l_merge_reason_code
	From hz_merge_batch
	Where batch_id = p_batch_id;

	If l_merge_reason_code = 'DUPLICATE' Then
		null;
	Else
		null;
	End If;
*/


/* Perform the merge operation */

/* If the parent has NOT Changed(i.e Parent is getting transfered), then nothing needs to be done. Set Merge To id same
   as Merged from id and return */


   if p_from_fk_id = p_to_fk_id then

		x_to_id := p_from_id;

		return;
   End If;


/* If the Parent has changed(i.e. Parent is getting merged), then transfer the dependent record to the new parent.
   Before transferring check if similar dependent record exists on the new parent. If the duplicate exists then do not
   transfer and and return the id of the duplicate record as the merged to id. */


   if p_from_fk_id <> p_to_fk_id Then

      if p_parent_entity_name = 'HZ_PARTIES' Then

            --fix 2899235: delete <merge from> only, don't change <merge to>
            delete IBE_ORD_ONECLICK_ALL
            where  party_id = p_from_fk_id;


/*		Begin
			select ord_oneclick_id
			into l_ord_oneclick_id
			from ibe_ord_oneclick_all
			where party_id = p_to_fk_id
			and rownum = 1;
		exception

			When no_data_found Then
				l_ord_oneclick_id := null;
		end;

		If l_ord_oneclick_id is null Then

       		-- Lock the table and update the record(s).

 			arp_message.set_name('AR', 'AR_LOCKING_TABLE');
	 		arp_message.set_token('TABLE_NAME', 'IBE_ORD_ONECLICK_ALL', FALSE);

			Open C1;
			Close C1;

			arp_message.set_name('AR', 'AR_UPDATING_TABLE');
 			arp_message.set_token('TABLE_NAME', 'IBE_ORD_ONECLICK_ALL', FALSE);


            -- 4/8/02
            -- If updating party_id results in uniqueness violation, means oneclick already has
            --  setting for express checkout, do nothing.

            BEGIN
  			  UPDATE IBE_ORD_ONECLICK_ALL SET
					party_id = p_to_fk_id,
					last_update_date = hz_utility_pub.last_update_date,
					last_updated_by  = hz_utility_pub.user_id,
					last_update_login = hz_utility_pub.last_update_login
			  Where party_id = p_from_fk_id;
            EXCEPTION WHEN OTHERS THEN
              NULL;
            END;
			l_count := sql%rowcount;

			arp_message.set_name('AR', 'AR_ROWS_UPDATED');
			arp_message.set_token('NUM_ROWS', to_char(l_count) );

			Return;

		Else
            --fix 2781213
            delete IBE_ORD_ONECLICK_ALL
            where  party_id = p_from_fk_id;

			return;

		End IF;
*/
--fix 2899235: don't update bill/ship party site ID ever
/*	Elsif p_parent_entity_name = 'HZ_PARTY_SITES' Then

				-- Lock the table and update the record(s).

 			arp_message.set_name('AR', 'AR_LOCKING_TABLE');
	 		arp_message.set_token('TABLE_NAME', 'IBE_ORD_ONECLICK_ALL', FALSE);

			Open C1;
			Close C1;

			arp_message.set_name('AR', 'AR_UPDATING_TABLE');
 			arp_message.set_token('TABLE_NAME', 'IBE_ORD_ONECLICK_ALL', FALSE);

			UPDATE IBE_ORD_ONECLICK_ALL SET
					bill_to_pty_site_id = decode(bill_to_pty_site_id,p_from_fk_id,p_to_fk_id,bill_to_pty_site_id),
					ship_to_pty_site_id = decode(ship_to_pty_site_id,p_from_fk_id,p_to_fk_id,ship_to_pty_site_id),
					last_update_date = hz_utility_pub.last_update_date,
					last_updated_by  = hz_utility_pub.user_id,
					last_update_login = hz_utility_pub.last_update_login
			Where	bill_to_pty_site_id= p_from_fk_id
			Or ship_to_pty_site_id = p_from_fk_id;

			l_count := sql%rowcount;

			arp_message.set_name('AR', 'AR_ROWS_UPDATED');
			arp_message.set_token('NUM_ROWS', to_char(l_count) );

			Return;
*/
   	End If;

End If;

arp_message.set_line('IBE_MERGE_PVT.MERGE_ONECLICK()-');

Exception
	When RESOURCE_BUSY Then
		arp_message.set_line('IBE_MERGE_PVT.MERGE_ONECLICK; Could not obtain lock'||
					'on table IBE_ORD_ONECLICK_ALL');
		 x_return_status :=  FND_API.G_RET_STS_ERROR;
		 raise;
	When Others Then
		arp_message.set_line('IBE_MERGE_PVT.MERGE_ONECLICK'||sqlerrm);
		x_return_status :=  FND_API.G_RET_STS_ERROR;
		raise;


END MERGE_ONECLICK;




/*----------------------------------------------------------------------------*
| PUBLIC PROCEDURES                                                          |
|                  MERGE_MSITE_PARTY_ACCESS -- 					       |
|			 When in ERP Parties are merged the	      	            |
|                  The Foriegn keys to party_id and other columns            |
|			 should also be updated in iStore tables.  		            |
|                  This procedure will update					       |
|			 IBE_MSITE_PRTY_ACCSS table and will be called from party     |
|			 Merge concurrent program.   					            |
| DESCRIPTION                                                                |
|                                                                            |
| REQUIRES                                                                   |
|                                                                            |
|                                                                            |
| EXCEPTIONS RAISED                                                          |
|                                                                            |
| KNOWN BUGS                                                                 |
|                                                                            |
| NOTES                                                                      |
|                                                                            |
| HISTORY                                                                    |
|  Harish Ekkirala Created 02/12/2001.                                       |
|                                                                            |
*----------------------------------------------------------------------------*/

PROCEDURE MERGE_MSITE_PARTY_ACCESS(
			P_entity_name			IN		VARCHAR2,
			P_from_id				IN		NUMBER,
			X_to_id				OUT		NOCOPY NUMBER,
			P_from_fk_id			IN		NUMBER,
			P_to_fk_id			IN		NUMBER,
			P_parent_entity_name	IN		VARCHAR2,
			P_batch_id			IN		NUMBER,
			P_batch_party_id		IN		NUMBER,
			X_return_status		OUT		NOCOPY VARCHAR2
			)
IS

Cursor C1 is
Select 'X' from
IBE_MSITE_PRTY_ACCSS
where party_id = p_from_fk_id
for update nowait;

CURSOR merge_records(p_party_id NUMBER) IS
  Select a.msite_id, b.party_access_code
  From ibe_msite_prty_accss a, ibe_msites_b b
  Where party_id = p_party_id and a.msite_id=b.msite_id and b.site_type = 'I';


l_msite_prty_accss_id	IBE_MSITE_PRTY_ACCSS.MSITE_PRTY_ACCSS_ID%TYPE;
l_merge_reason_code 	VARCHAR2(30);
l_count                 NUMBER(10)   := 0;
RESOURCE_BUSY           EXCEPTION;
l_msite_id	IBE_MSITE_PRTY_ACCSS.MSITE_ID%TYPE;
l_party_access_code	IBE_MSITES_B.PARTY_ACCESS_CODE%TYPE;
PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

Begin

arp_message.set_line('IBE_MERGE_PVT.MERGE_MSITE_PARTY_ACCESS()+');

x_return_status :=  FND_API.G_RET_STS_SUCCESS;



/* Perform the merge operation */

/* If the parent has NOT Changed(i.e Parent is getting transfered), then nothing needs to be done. Set Merge To id same
   as Merged from id and return */


   if p_from_fk_id = p_to_fk_id then

		x_to_id := p_from_id;

		return;
   End If;


/* If the Parent has changed(i.e. Parent is getting merged), then transfer the dependent record to the new parent.
   Before transferring check if similar dependent record exists on the new parent. If the duplicate exists then do not
   transfer and and return the id of the duplicate record as the merged to id. */


   if p_from_fk_id <> p_to_fk_id Then

      if p_parent_entity_name = 'HZ_PARTIES' Then

        --iterate each <merge from> record in the site access table
        open merge_records(p_from_fk_id);
            loop
                fetch merge_records into l_msite_id, l_party_access_code;
    			EXIT When merge_records%NOTFOUND;
    			Begin
        			arp_message.set_name('AR', 'AR_UPDATING_TABLE');
         			arp_message.set_token('TABLE_NAME', 'IBE_MSITE_PRTY_ACCSS', FALSE);
            		arp_message.set_line('IBE_MERGE_PVT.MERGE_MSITE_PARTY_ACCESS; '||
					' merging msite:'||l_msite_id||' both <merge from> & <merge to> are BOTH on');

                    -- only merge when both <merge from> & <merge to> are BOTH on
                    -- and <merge to> doesn't have restrictions on the <merge from> minisite
        			UPDATE IBE_MSITE_PRTY_ACCSS
        			SET	party_id = p_to_fk_id,
        				last_update_date = hz_utility_pub.last_update_date,
        				last_updated_by  = hz_utility_pub.user_id,
        				last_update_login = hz_utility_pub.last_update_login
        			Where party_id = p_from_fk_id and exists (
                            select 1 from IBE_MSITE_PRTY_ACCSS a, IBE_MSITES_B b
                            where party_id=p_to_fk_id and a.msite_id<>l_msite_id
                            and a.msite_id = b.msite_id and b.party_access_code = l_party_access_code
							and b.site_type = 'I'
                            );
        			l_count := sql%rowcount;
        			arp_message.set_name('AR', 'AR_ROWS_UPDATED');
        			arp_message.set_token('NUM_ROWS', to_char(l_count) );


                    -- for a given msite, if <merge from> has party access and <merge to> doesn't
                    -- then end_date <merge from> to prevent dangling party layer data
                    if (SQL%NOTFOUND) then
                        update IBE_MSITE_PRTY_ACCSS
                        set END_DATE_ACTIVE = trunc(sysdate)
                        where party_id = p_from_fk_id and msite_id=l_msite_id;
                    end if;

                Exception
                	When Others Then
                		arp_message.set_line('IBE_MERGE_PVT.MERGE_MSITE_PARTY_ACCESS'||sqlerrm);
                		x_return_status :=  FND_API.G_RET_STS_ERROR;
            		raise;
                end;
            end loop;
        close merge_records;

      End If;
   End If;

arp_message.set_line('IBE_MERGE_PVT.MERGE_MSITE_PARTY_ACCESS()-');

Exception
	When RESOURCE_BUSY Then
		arp_message.set_line('IBE_MERGE_PVT.MERGE_MSITE_PARTY_ACCESS; Could not obtain lock'||
					'on table IBE_MSITE_PRTY_ACCSS');
		 x_return_status :=  FND_API.G_RET_STS_ERROR;
		 raise;
	When Others Then
		arp_message.set_line('IBE_MERGE_PVT.MERGE_MSITE_PARTY_ACCESS'||sqlerrm);
		x_return_status :=  FND_API.G_RET_STS_ERROR;
		raise;


END MERGE_MSITE_PARTY_ACCESS;

/*----------------------------------------------------------------------------*
| PUBLIC PROCEDURES                                                          |
|                  MERGE_SHARED_QUOTE -- 					           |
|			 When in ERP Parties are merged the	      	           |
|                  The Foriegn keys to party_id and other columns            |
|			 should also be updated in iStore tables.  		     |
|                  This procedure will update IBE_SH_QUOTE table     |
|                  and will be called from party Merge concurrent program.   |
| DESCRIPTION                                                                |
|                                                                            |
| REQUIRES                                                                   |
|                                                                            |
|                                                                            |
| EXCEPTIONS RAISED                                                          |
|                                                                            |
| KNOWN BUGS                                                                 |
|                                                                            |
| NOTES                                                                      |
|                                                                            |
| HISTORY                                                                    |
|  Adam Wu Created 12/05/2002.                                               |
|                                                                            |
*----------------------------------------------------------------------------*/

PROCEDURE MERGE_SHARED_QUOTE(
			P_entity_name		IN		VARCHAR2,
			P_from_id			IN		NUMBER,
			X_to_id			OUT		NOCOPY NUMBER,
			P_from_fk_id		IN		NUMBER,
			P_to_fk_id			IN		NUMBER,
			P_parent_entity_name	IN		VARCHAR2,
			P_batch_id			IN		NUMBER,
			P_batch_party_id		IN		NUMBER,
			X_return_status		OUT		NOCOPY VARCHAR2
				)
IS

l_dummy VARCHAR2(1);
Cursor MERGE_FROM_SH is
Select quote_header_id, cust_account_id from
IBE_SH_QUOTE_ACCESS
Where party_id = p_from_fk_id
for update nowait;


cursor find_account(p_party_id number) is
select cust_account_id
from hz_cust_accounts
where party_id=p_party_id and rownum=1
for update nowait;

l_merge_reason_code 	VARCHAR2(30);
l_count              NUMBER(10)   := 0;
l_quote_header_id    NUMBER;
l_party_id    NUMBER;
l_from_cust_account_id    NUMBER;
l_to_cust_account_id    NUMBER;

RESOURCE_BUSY           EXCEPTION;
PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

Begin

arp_message.set_line('IBE_MERGE_PVT.MERGE_SHARED_QUOTE()+');

x_return_status :=  FND_API.G_RET_STS_SUCCESS;

/* Perform the merge operation */

/* If the parent has NOT Changed(i.e Parent is getting transfered), then nothing needs to be done. Set Merge To id same
   as Merged from id and return */

if p_from_fk_id = p_to_fk_id then
 		x_to_id := p_from_id;
	 	return;
End If;



if p_from_fk_id <> p_to_fk_id Then
   	arp_message.set_name('AR', 'AR_LOCKING_TABLE');
   	arp_message.set_token('TABLE_NAME', 'IBE_SH_QUOTE_ACCESS', FALSE);
    open find_account(p_to_fk_id);
    fetch find_account into l_to_cust_account_id  ;
    if p_parent_entity_name = 'HZ_PARTIES' Then
		Open MERGE_FROM_SH;
		Loop
			Fetch MERGE_FROM_SH into l_quote_header_id, l_from_cust_account_id;
			EXIT When merge_from_sh%NOTFOUND;
			Begin
			  Select party_id into l_party_id
			  From  IBE_SH_QUOTE_ACCESS
			  Where party_id = p_to_fk_id
                 and   cust_account_id = l_to_cust_account_id
                 And   quote_header_id = l_quote_header_id;
             -- delete/end_date since it's a duplicate row in quotes table

             delete IBE_SH_QUOTE_ACCESS
             where  quote_header_id = l_quote_header_id
             and    party_id = p_from_fk_id
             and    cust_account_id = l_from_cust_account_id;
			Exception
              --update party ID to merge to if not a duplicate for merge to party
			  When NO_DATA_FOUND Then
            	arp_message.set_name('AR', 'AR_UPDATING_TABLE');
                arp_message.set_token('TABLE_NAME', 'IBE_SH_QUOTE_ACCESS', FALSE);

    		    UPDATE IBE_SH_QUOTE_ACCESS SET
         			party_id = p_to_fk_id,
     			    last_update_date = hz_utility_pub.last_update_date,
         			last_updated_by  = hz_utility_pub.user_id,
              		last_update_login = hz_utility_pub.last_update_login,
         			request_id = hz_utility_pub.request_id,
         			program_application_id = hz_utility_pub.program_application_id,
         			program_id = hz_utility_pub.program_id,
         			program_update_date = sysdate
                Where party_id = p_from_fk_id
                    And   cust_account_id = l_from_cust_account_id
                    And   quote_header_id = l_quote_header_id;
            END;
          END LOOP;
          CLOSE MERGE_FROM_SH;
  --fix 2889340
  --fix 2920475
  elsif p_parent_entity_name = 'HZ_CONTACT_POINTS' Then
           BEGIN
                select 1
                into l_dummy
                from hz_contact_points
                where contact_point_id=p_from_fk_id and owner_table_name<>'IBE_SH_QUOTE_ACCESS';
    		    UPDATE IBE_SH_QUOTE_ACCESS SET
         			contact_point_id = p_to_fk_id,
     			    last_update_date = hz_utility_pub.last_update_date,
         			last_updated_by  = hz_utility_pub.user_id,
              		last_update_login = hz_utility_pub.last_update_login,
         			request_id = hz_utility_pub.request_id,
         			program_application_id = hz_utility_pub.program_application_id,
         			program_id = hz_utility_pub.program_id,
         			program_update_date = sysdate
                Where contact_point_id = p_from_fk_id;

           EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL;
           END;
  end if; --end if p_parent_entity_name = 'HZ_CONTACT_POINTS' Then

  l_count := sql%rowcount;

  arp_message.set_name('AR', 'AR_ROWS_UPDATED');
  arp_message.set_token('NUM_ROWS', to_char(l_count) );
  return;


End If; --end if p_from_fk_id <> p_to_fk_id Then

arp_message.set_line('IBE_MERGE_PVT.MERGE_SHIP_LISTS()-');


Exception
	When RESOURCE_BUSY Then
		arp_message.set_line('IBE_MERGE_PVT.MERGE_SH_QUOTE_ACCESS; Could not obtain lock'||
					'on table IBE_SH_QUOTE_ACCESS');
		 x_return_status :=  FND_API.G_RET_STS_ERROR;
		 raise;
	When Others Then
		arp_message.set_line('IBE_MERGE_PVT.MERGE_SH_QUOTE_ACCESS'||sqlerrm);
		x_return_status :=  FND_API.G_RET_STS_ERROR;
		raise;
End MERGE_SHARED_QUOTE;

/*----------------------------------------------------------------------------*
| PUBLIC PROCEDURES                                                          |
|                  MERGE_ACTIVE_QUOTE -- 					           |
|			 When in ERP Parties are merged the	      	           |
|                  The Foriegn keys to party_id and other columns            |
|			 should also be updated in iStore tables.  		     |
|                  This procedure will update IBE_ACTIVE_QUOTES_ALL table     |
|                  and will be called from party Merge concurrent program.   |
| DESCRIPTION                                                                |
|                                                                            |
| REQUIRES                                                                   |
|                                                                            |
|                                                                            |
| EXCEPTIONS RAISED                                                          |
|                                                                            |
| KNOWN BUGS                                                                 |
|                                                                            |
| NOTES                                                                      |
|                                                                            |
| HISTORY                                                                    |
|  Adam Wu Created 12/05/2002.                                               |
|                                                                            |
*----------------------------------------------------------------------------*/
procedure MERGE_ACTIVE_QUOTE(
			P_entity_name		IN		VARCHAR2,
			P_from_id			IN		NUMBER,
			X_to_id			OUT		NOCOPY NUMBER,
			P_from_fk_id		IN		NUMBER,
			P_to_fk_id			IN		NUMBER,
			P_parent_entity_name	IN		VARCHAR2,
			P_batch_id			IN		NUMBER,
			P_batch_party_id		IN		NUMBER,
			X_return_status		OUT		NOCOPY VARCHAR2
)
IS

l_merge_reason_code 	VARCHAR2(30);
l_count              NUMBER(10)   := 0;
l_quote_header_id    NUMBER;
l_party_id           NUMBER;
l_cust_account_id    NUMBER;
l_quote_name         VARCHAR2(80);

RESOURCE_BUSY           EXCEPTION;
PRAGMA EXCEPTION_INIT(RESOURCE_BUSY, -0054);

Cursor MERGE_FROM_ACTIVE is
Select a.quote_header_id, a.cust_account_id, b.quote_name
from   IBE_ACTIVE_QUOTES_ALL a, ASO_QUOTE_HEADERS_ALL b
Where  a.quote_header_id = b.quote_header_id (+) and a.party_id = b.party_id (+)
       and a.cust_account_id=b.cust_account_id (+) and a.party_id=P_from_fk_id
for update nowait;



BEGIN

arp_message.set_line('IBE_MERGE_PVT.MERGE_ACTIVE_QUOTE()+');

x_return_status :=  FND_API.G_RET_STS_SUCCESS;


if p_from_fk_id = p_to_fk_id then
    x_to_id := p_from_id;
	return;
end If;



if p_from_fk_id <> p_to_fk_id Then
  	arp_message.set_name('AR', 'AR_LOCKING_TABLE');
  	arp_message.set_token('TABLE_NAME', 'IBE_SH_SHP_LISTS_ALL', FALSE);
   open merge_from_active;
   loop
        Fetch merge_from_active into l_quote_header_id, l_cust_account_id, l_quote_name;
      		EXIT When merge_from_active%NOTFOUND;
        Begin
            --2967430
            update ASO_QUOTE_HEADERS_ALL
            set QUOTE_NAME = 'IBE_PRMT_SC_DEFAULTNAMED'
            where quote_header_id = l_quote_header_id
            AND quote_name = 'IBE_PRMT_SC_UNNAMED';

            delete ibe_active_quotes_all
            where quote_header_id = l_quote_header_id
                  and cust_account_id = l_cust_account_id
                  and party_id=P_from_fk_id;
/*        Exception
            null;
*/
        End;

   END LOOP;
   CLOSE MERGE_FROM_ACTIVE;
  	l_count := sql%rowcount;
  	arp_message.set_name('AR', 'AR_ROWS_UPDATED');
  	arp_message.set_token('NUM_ROWS', to_char(l_count) );

	return;

END IF;

arp_message.set_line('IBE_MERGE_PVT.MERGE_ACTIVE_QUOTE()-');


Exception
	When RESOURCE_BUSY Then
		arp_message.set_line('IBE_MERGE_PVT.MERGE_ACTIVE_QUOTE; Could not obtain lock'||
					'on table IBE_ACTIVE_QUOTES_ALL');
		 x_return_status :=  FND_API.G_RET_STS_ERROR;
		 raise;
	When Others Then
		arp_message.set_line('IBE_MERGE_PVT.MERGE_ACTIVE_QUOTE'||sqlerrm);
		x_return_status :=  FND_API.G_RET_STS_ERROR;
		raise;
END MERGE_ACTIVE_QUOTE;

End IBE_MERGE_PVT;


/
