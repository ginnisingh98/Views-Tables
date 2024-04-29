--------------------------------------------------------
--  DDL for Package Body QP_CUST_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_CUST_MERGE" AS
/* $Header: QPXCMRGB.pls 120.0.12010000.2 2009/04/23 12:16:02 smbalara ship $ */


/*-------------------------------------------------------------
|
|  PROCEDURE
|      Agreement_Merge
|  DESCRIPTION :
|      Account merge procedure for the table, OE_AGREEMENTS_B
|
|  NOTES:
|  ******* Please delete these lines after modifications *******
|   This account merge procedure was generated using a perl script.
|
|   This is only suggested code. Please ensure that the code actually
|   works for you.
|
|   Please also address the additional notes inserted as comments in the
|   code below.
|  ******************************
|
|--------------------------------------------------------------*/

PROCEDURE Agreement_Merge (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE agreement_id_LIST_TYPE IS TABLE OF
         OE_AGREEMENTS_B.agreement_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST agreement_id_LIST_TYPE;

  TYPE invoice_to_org_id_LIST_TYPE IS TABLE OF
         OE_AGREEMENTS_B.invoice_to_org_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST invoice_to_org_id_LIST_TYPE;
  NUM_COL1_NEW_LIST invoice_to_org_id_LIST_TYPE;

  TYPE sold_to_org_id_LIST_TYPE IS TABLE OF
         OE_AGREEMENTS_B.sold_to_org_id%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL2_ORIG_LIST sold_to_org_id_LIST_TYPE;
  NUM_COL2_NEW_LIST sold_to_org_id_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,agreement_id
              ,invoice_to_org_id
              ,sold_to_org_id
         FROM OE_AGREEMENTS_B yt, ra_customer_merges m
         WHERE (
            yt.invoice_to_org_id = m.DUPLICATE_SITE_ID
            OR yt.sold_to_org_id = m.DUPLICATE_ID
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
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','OE_AGREEMENTS_B',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
            MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , NUM_COL1_ORIG_LIST
          , NUM_COL2_ORIG_LIST
          limit 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL1_ORIG_LIST(I));
         NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL2_ORIG_LIST(I));
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
         'OE_AGREEMENTS_B',
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

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE OE_AGREEMENTS_B yt SET
           invoice_to_org_id=NUM_COL1_NEW_LIST(I)
          ,sold_to_org_id=NUM_COL2_NEW_LIST(I)
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
      WHERE agreement_id=PRIMARY_KEY_ID_LIST(I)
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
    arp_message.set_line( 'Agreement_Merge');
    RAISE;
END Agreement_Merge;

--Below procedure added for bug 8399386
/*-------------------------------------------------------------
|
|  PROCEDURE : Check_Duplicate
|  DESCRIPTION :
|   Checks if duplicate qualifiers exist after a Customer Merge
|   is done.
|
|--------------------------------------------------------------*/

PROCEDURE Check_Duplicate(p_qualifier_id IN number,p_qualifier_attr_value IN varchar2) IS
l_qualifier_id number;
l_temp_date   DATE;
BEGIN
l_temp_date  := trunc(sysdate);
    BEGIN
      SELECT a.qualifier_id
      INTO   l_qualifier_id
      FROM   qp_qualifiers a
      WHERE  a.qualifier_attr_value = to_char(p_qualifier_attr_value)
      AND    trunc(l_temp_date) between nvl(trunc(start_date_active), trunc(l_temp_date)) and
             nvl(trunc(end_date_active), trunc(l_temp_date))
      AND   (a.qualifier_context,
             a.qualifier_attribute,
             nvl(a.list_header_id, -1),
             nvl(a.list_line_id, -1),
             nvl(qualifier_rule_id, -1),
             a.qualifier_grouping_no) IN
                      (SELECT b.qualifier_context, b.qualifier_attribute,
                              nvl(b.list_header_id, -1),
                              nvl(b.list_line_id, -1),
                              nvl(qualifier_rule_id, -1),
                              b.qualifier_grouping_no
                       FROM   qp_qualifiers b
                       WHERE  b.qualifier_id = p_qualifier_id
                       AND    b.qualifier_id <> a.qualifier_id)
      AND rownum = 1;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_qualifier_id := NULL;
    END;
   IF l_qualifier_id IS NOT NULL THEN /* Duplicate Exists. Therefore delete
					the duplicate qualifier */
      DELETE qp_qualifiers
      WHERE qualifier_id = l_qualifier_id;
    END IF;
END Check_Duplicate;
--End procedure for bug 8399386

/*-------------------------------------------------------------
|
|  PROCEDURE
|      Qualifier_Merge
|  DESCRIPTION :
|      Account merge procedure for the table, QP_QUALIFIERS
|
|  NOTES:
|  ******* Please delete these lines after modifications *******
|   This account merge procedure was generated using a perl script.
|
|   This is only suggested code. Please ensure that the code actually
|   works for you.
|
|   Please also address the additional notes inserted as comments in the
|   code below.
|  ******************************
|
|--------------------------------------------------------------*/

PROCEDURE Qualifier_Merge (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE qualifier_id_LIST_TYPE IS TABLE OF
         QP_QUALIFIERS.qualifier_id%TYPE
        INDEX BY BINARY_INTEGER;
  PRIMARY_KEY_ID_LIST qualifier_id_LIST_TYPE;

  TYPE qualifier_attr_value_LIST_TYPE IS TABLE OF
         QP_QUALIFIERS.qualifier_attr_value%TYPE
        INDEX BY BINARY_INTEGER;
  VCHAR_COL1_ORIG_LIST qualifier_attr_value_LIST_TYPE;
  VCHAR_COL1_NEW_LIST qualifier_attr_value_LIST_TYPE;

  --Begin code added for Bug fix 3649761
  VCHAR_COL2_ORIG_LIST qualifier_attr_value_LIST_TYPE;
  VCHAR_COL2_NEW_LIST qualifier_attr_value_LIST_TYPE;

  TYPE qualifier_context_LIST_TYPE IS TABLE OF
         QP_QUALIFIERS.qualifier_context%TYPE
        INDEX BY BINARY_INTEGER;
  QUALIFIER_CONTEXT_LIST qualifier_context_LIST_TYPE;

  TYPE qualifier_attribute_LIST_TYPE IS TABLE OF
         QP_QUALIFIERS.qualifier_attribute%TYPE
        INDEX BY BINARY_INTEGER;
  QUALIFIER_ATTRIBUTE_LIST qualifier_attribute_LIST_TYPE;
  --End code added for bug fix 3649761

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,qualifier_id
              ,qualifier_attr_value
              --Added following 3 select list columns for bug fix 3649761
              ,qualifier_attr_value
              ,qualifier_context
              ,qualifier_attribute
         FROM QP_QUALIFIERS yt, ra_customer_merges m
         WHERE
         /* (
            yt.qualifier_attr_value = to_char(m.DUPLICATE_SITE_ID)
         )*/
         -- above clause replaced by clause below for bug fix 3649761
         (
          yt.qualifier_attr_value = to_char(m.DUPLICATE_SITE_ID) AND
          (yt.qualifier_context = 'CUSTOMER' AND
           yt.qualifier_attribute = 'QUALIFIER_ATTRIBUTE11' --Ship To
           OR
           yt.qualifier_context = 'CUSTOMER' AND
           yt.qualifier_attribute = 'QUALIFIER_ATTRIBUTE5'  --Site Use
           OR
           yt.qualifier_context = 'CUSTOMER' AND
           yt.qualifier_attribute = 'QUALIFIER_ATTRIBUTE14'  --Bill To
          )
          OR
          yt.qualifier_attr_value = to_char(m.DUPLICATE_ID) AND
          (yt.qualifier_context = 'CUSTOMER' AND
           yt.qualifier_attribute = 'QUALIFIER_ATTRIBUTE2' --Customer Name
          )
         )
         AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','QP_QUALIFIERS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;
    LOOP
      FETCH merged_records BULK COLLECT INTO
            MERGE_HEADER_ID_LIST
          , PRIMARY_KEY_ID_LIST
          , VCHAR_COL1_ORIG_LIST
          , VCHAR_COL2_ORIG_LIST --Added for bug fix 3649761
          , QUALIFIER_CONTEXT_LIST
          , QUALIFIER_ATTRIBUTE_LIST
          limit 1000;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
       --Modified code for bug fix 3649761
       IF (QUALIFIER_CONTEXT_LIST(I) = 'CUSTOMER' AND
           QUALIFIER_ATTRIBUTE_LIST(I) = 'QUALIFIER_ATTRIBUTE2') --Customer Name
       THEN
         VCHAR_COL1_NEW_LIST(I) := to_char(HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(to_number(VCHAR_COL1_ORIG_LIST(I))));
	 --check for duplicate smbalara 8203178 / 8399386
	 Check_Duplicate(PRIMARY_KEY_ID_LIST(I),VCHAR_COL1_NEW_LIST(I));

         VCHAR_COL2_ORIG_LIST(I) := NULL;
         VCHAR_COL2_NEW_LIST(I) := NULL;
       ELSIF ((QUALIFIER_CONTEXT_LIST(I) = 'CUSTOMER' AND
               QUALIFIER_ATTRIBUTE_LIST(I) = 'QUALIFIER_ATTRIBUTE11') --Ship To
               OR
              (QUALIFIER_CONTEXT_LIST(I) = 'CUSTOMER' AND
               QUALIFIER_ATTRIBUTE_LIST(I) = 'QUALIFIER_ATTRIBUTE5') --Site Use
               OR
              (QUALIFIER_CONTEXT_LIST(I) = 'CUSTOMER' AND
               QUALIFIER_ATTRIBUTE_LIST(I) = 'QUALIFIER_ATTRIBUTE14') --Bill To
             )
       THEN
         VCHAR_COL2_NEW_LIST(I) := to_char(HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(to_number(VCHAR_COL2_ORIG_LIST(I))));

	 --check for duplicate smbalara 8203178 / 8399386
	 Check_Duplicate(PRIMARY_KEY_ID_LIST(I),VCHAR_COL2_NEW_LIST(I));

         VCHAR_COL1_ORIG_LIST(I) := NULL;
         VCHAR_COL1_NEW_LIST(I) := NULL;
       END IF;

      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID,
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           --Added the following 2 columns for bug fix 3649761
           VCHAR_COL2_ORIG,
           VCHAR_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'QP_QUALIFIERS',
         MERGE_HEADER_ID_LIST(I),
         PRIMARY_KEY_ID_LIST(I),
         VCHAR_COL1_ORIG_LIST(I),
         VCHAR_COL1_NEW_LIST(I),
         --Added the following 2 columns for bug fix 3649761
         VCHAR_COL2_ORIG_LIST(I),
         VCHAR_COL2_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

    END IF;    FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE QP_QUALIFIERS yt SET
          --Modified code for bug fix 3649761
           qualifier_attr_value=decode(nvl(VCHAR_COL1_NEW_LIST(I),'x'), 'x',
                                       VCHAR_COL2_NEW_LIST(I),
                                       VCHAR_COL1_NEW_LIST(I))
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
      WHERE qualifier_id=PRIMARY_KEY_ID_LIST(I);
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
    arp_message.set_line( 'Qualifier_Merge');
    RAISE;
END Qualifier_Merge;


PROCEDURE Merge (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) IS
BEGIN

  arp_message.set_line('QP_CUST_MERGE.Merge()+');

  Agreement_Merge(req_id, set_num, process_mode);
  Qualifier_Merge(req_id, set_num, process_mode);

  arp_message.set_line('QP_CUST_MERGE.Merge()-');

EXCEPTION
  when others then
    raise;

END Merge;

END QP_CUST_MERGE;

/
