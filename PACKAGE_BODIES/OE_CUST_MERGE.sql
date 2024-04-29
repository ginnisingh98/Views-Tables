--------------------------------------------------------
--  DDL for Package Body OE_CUST_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CUST_MERGE" AS
/* $Header: OEXCMOEB.pls 120.8.12010000.6 2010/04/15 19:02:01 ckasera ship $ */

/*---------------------------- PRIVATE VARIABLES ----------------------------*/

  G_BINARY_LIMIT CONSTANT NUMBER := OE_GLOBALS.G_BINARY_LIMIT; --bug8541941

  TYPE num_table IS VARRAY(20000) OF NUMBER;
  TYPE vchar240_table is VARRAY(20000) of varchar2(240);
  g_count               NUMBER := 0;
  TYPE MERGE_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;

  TYPE num_bin_table IS TABLE OF NUMBER;
  TYPE var_bin_table IS TABLE OF VARCHAR2(1);
  TYPE date_bin_table IS TABLE OF DATE;

  dbi_header_header_id_tab num_bin_table := num_bin_table();
  dbi_header_update_date_tab date_bin_table := date_bin_table();

  dbi_line_header_id_tab num_bin_table := num_bin_table();
  dbi_line_line_id_tab num_bin_table := num_bin_table();
  dbi_line_update_date_tab date_bin_table := date_bin_table();
  dbi_line_status_tab  var_bin_table := var_bin_table();

  TYPE num_binary_int IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  dbi_header_id_tab        num_binary_int;

  l_dbi_profile varchar2(10);

  -- Bug 7379750
  l_run_parallel_query  VARCHAR2(5) := NVL(FND_PROFILE.VALUE('PARALLEL_QUERIES_IN_CUST_MERGE'), 'Y');

 PROCEDURE Oe_Update_DBI_log;

/*--------------------------- PRIVATE ROUTINES ------------------------------*/

/*------------------------------------------------*/
/*--- PRIVATE Procedure OE_Merge_Headers       ---*/
/*------------------------------------------------*/

 Procedure OE_Merge_Headers (Req_Id          IN NUMBER,
                             Set_Num         IN NUMBER,
                             Process_Mode    IN VARCHAR2)
 IS

 CURSOR MERGE_SITES IS
   select duplicate_id, customer_id, duplicate_site_id, customer_site_id
     from ra_customer_merges m
     where m.process_flag = 'N'
     and m.request_id = req_id
     and m.set_number = set_num;

 --bug6071855
 CURSOR MERGE_HEADERS IS
      SELECT /*+ PARALLEL (H) PARALLEL (M1) PARALLEL(M2)
           PARALLEL (M3) PARALLEL (M4) PARALLEL (M5)
           PARALLEL (M6) PARALLEL (M7) */
       H.HEADER_ID , H.LAST_UPDATE_DATE, H.HEADER_ID, H.SOLD_TO_ORG_ID,
       H.INVOICE_TO_ORG_ID, H.SHIP_TO_ORG_ID, H.DELIVER_TO_ORG_ID,
       H.SOLD_TO_SITE_USE_ID, H.END_CUSTOMER_SITE_USE_ID,
       H.END_CUSTOMER_ID, 'N' ,
       NVL(M1.CUSTOMER_MERGE_ID,NVL(M2.CUSTOMER_MERGE_ID,NVL(M3.CUSTOMER_MERGE_ID,
       NVL(M4.CUSTOMER_MERGE_ID,nvl(M5.CUSTOMER_MERGE_ID,
       NVL(M6.CUSTOMER_MERGE_ID,M7.CUSTOMER_MERGE_ID))))))
  FROM RA_CUSTOMER_MERGES M1,
       RA_CUSTOMER_MERGES M2,
       RA_CUSTOMER_MERGES M3,
       RA_CUSTOMER_MERGES M4,
       RA_CUSTOMER_MERGES M5,
       RA_CUSTOMER_MERGES M6,
       RA_CUSTOMER_MERGES M7,
       OE_ORDER_HEADERS H
 WHERE ( H.SOLD_TO_ORG_ID = M1.DUPLICATE_ID(+)
   AND H.INVOICE_TO_ORG_ID = M2.DUPLICATE_SITE_ID(+)
   AND H.SHIP_TO_ORG_ID = M3.DUPLICATE_SITE_ID(+)
   AND H.SOLD_TO_SITE_USE_ID = M4.DUPLICATE_SITE_ID(+)
   AND H.DELIVER_TO_ORG_ID = M5.DUPLICATE_SITE_ID(+)
   AND H.END_CUSTOMER_SITE_USE_ID = M6.DUPLICATE_SITE_ID(+)
   AND H.END_CUSTOMER_ID = M7.DUPLICATE_ID(+) )
   AND (M1.DUPLICATE_SITE_ID IS NOT NULL
    OR M2.DUPLICATE_ID IS NOT NULL
    OR M3.DUPLICATE_ID IS NOT NULL
    OR M4.DUPLICATE_ID IS NOT NULL
    OR M5.DUPLICATE_ID IS NOT NULL
    OR M6.DUPLICATE_ID IS NOT NULL
    OR M7.DUPLICATE_SITE_ID IS NOT NULL)
   AND M1.PROCESS_FLAG(+) = 'N'
   AND M2.PROCESS_FLAG(+) = 'N'
   AND M3.PROCESS_FLAG(+) = 'N'
   AND M4.PROCESS_FLAG(+) = 'N'
   AND M5.PROCESS_FLAG(+) = 'N'
   AND M6.PROCESS_FLAG(+) = 'N'
   AND M7.PROCESS_FLAG(+) = 'N'
   AND M1.REQUEST_ID(+) =req_id
   AND M2.REQUEST_ID(+) =req_id
   AND M3.REQUEST_ID(+) =req_id
   AND M4.REQUEST_ID(+) =req_id
   AND M5.REQUEST_ID(+) =req_id
   AND M6.REQUEST_ID(+) =req_id
   AND M7.REQUEST_ID(+) =req_id
   AND M1.SET_NUMBER(+) =set_num
   AND M2.SET_NUMBER(+) =set_num
   AND M3.SET_NUMBER(+) =set_num
   AND M4.SET_NUMBER(+) =set_num
   AND M5.SET_NUMBER(+) =set_num
   AND M6.SET_NUMBER(+) =set_num
   AND M7.SET_NUMBER(+) =set_num
   for update nowait;

 --bug6071855
 CURSOR MERGE_HEADERS_2 IS
SELECT /*+ PARALLEL (H) PARALLEL (M1) PARALLEL(M2)
           PARALLEL (M3) PARALLEL (M4) PARALLEL (M5)
           PARALLEL (M6) PARALLEL (M7) */
       H.HEADER_ID , H.LAST_UPDATE_DATE, H.HEADER_ID, H.SOLD_TO_ORG_ID,
       H.INVOICE_TO_ORG_ID, H.SHIP_TO_ORG_ID, H.DELIVER_TO_ORG_ID,
       H.SOLD_TO_SITE_USE_ID, H.END_CUSTOMER_SITE_USE_ID,
       H.END_CUSTOMER_ID,'N',
       NVL(M1.CUSTOMER_MERGE_ID,NVL(M2.CUSTOMER_MERGE_ID,NVL(M3.CUSTOMER_MERGE_ID,
       NVL(M4.CUSTOMER_MERGE_ID,nvl(M5.CUSTOMER_MERGE_ID,
       NVL(M6.CUSTOMER_MERGE_ID,M7.CUSTOMER_MERGE_ID))))))
  FROM RA_CUSTOMER_MERGES M1,
       RA_CUSTOMER_MERGES M2,
       RA_CUSTOMER_MERGES M3,
       RA_CUSTOMER_MERGES M4,
       RA_CUSTOMER_MERGES M5,
       RA_CUSTOMER_MERGES M6,
       RA_CUSTOMER_MERGES M7,
       OE_ORDER_HEADERS H
 WHERE ( H.SOLD_TO_ORG_ID = M1.DUPLICATE_ID(+)
   AND H.INVOICE_TO_ORG_ID = M2.DUPLICATE_SITE_ID(+)
   AND H.SHIP_TO_ORG_ID = M3.DUPLICATE_SITE_ID(+)
   AND H.SOLD_TO_SITE_USE_ID = M4.DUPLICATE_SITE_ID(+)
   AND H.DELIVER_TO_ORG_ID = M5.DUPLICATE_SITE_ID(+)
   AND H.END_CUSTOMER_SITE_USE_ID = M6.DUPLICATE_SITE_ID(+)
   AND H.END_CUSTOMER_ID = M7.DUPLICATE_ID(+) )
   AND (M1.DUPLICATE_SITE_ID IS NOT NULL
    OR M2.DUPLICATE_ID IS NOT NULL
    OR M3.DUPLICATE_ID IS NOT NULL
    OR M4.DUPLICATE_ID IS NOT NULL
    OR M5.DUPLICATE_ID IS NOT NULL
    OR M6.DUPLICATE_ID IS NOT NULL
    OR M7.DUPLICATE_SITE_ID IS NOT NULL)
   AND M1.PROCESS_FLAG(+) = 'N'
   AND M2.PROCESS_FLAG(+) = 'N'
   AND M3.PROCESS_FLAG(+) = 'N'
   AND M4.PROCESS_FLAG(+) = 'N'
   AND M5.PROCESS_FLAG(+) = 'N'
   AND M6.PROCESS_FLAG(+) = 'N'
   AND M7.PROCESS_FLAG(+) = 'N'
   AND M1.REQUEST_ID(+) =req_id
   AND M2.REQUEST_ID(+) =req_id
   AND M3.REQUEST_ID(+) =req_id
   AND M4.REQUEST_ID(+) =req_id
   AND M5.REQUEST_ID(+) =req_id
   AND M6.REQUEST_ID(+) =req_id
   AND M7.REQUEST_ID(+) =req_id
   AND M1.SET_NUMBER(+) =set_num
   AND M2.SET_NUMBER(+) =set_num
   AND M3.SET_NUMBER(+) =set_num
   AND M4.SET_NUMBER(+) =set_num
   AND M5.SET_NUMBER(+) =set_num
   AND M6.SET_NUMBER(+) =set_num
   AND M7.SET_NUMBER(+) =set_num;


    CURSOR MERGE_HEADERS_2_NP IS
   	SELECT
	       H.HEADER_ID , H.LAST_UPDATE_DATE, H.HEADER_ID, H.SOLD_TO_ORG_ID,
	       H.INVOICE_TO_ORG_ID, H.SHIP_TO_ORG_ID, H.DELIVER_TO_ORG_ID,
	       H.SOLD_TO_SITE_USE_ID, H.END_CUSTOMER_SITE_USE_ID,
	       H.END_CUSTOMER_ID,'N',M1.CUSTOMER_MERGE_ID
	FROM
	OE_CUST_MERGES_GTT M1, OE_ORDER_HEADERS H
	WHERE H.SOLD_TO_ORG_ID = M1.DUPLICATE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	UNION ALL
	SELECT
	       H.HEADER_ID , H.LAST_UPDATE_DATE, H.HEADER_ID, H.SOLD_TO_ORG_ID,
	       H.INVOICE_TO_ORG_ID, H.SHIP_TO_ORG_ID, H.DELIVER_TO_ORG_ID,
	       H.SOLD_TO_SITE_USE_ID, H.END_CUSTOMER_SITE_USE_ID,
	       H.END_CUSTOMER_ID,'N',M1.CUSTOMER_MERGE_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_ORDER_HEADERS H
	WHERE H.INVOICE_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	UNION ALL
	SELECT
	       H.HEADER_ID , H.LAST_UPDATE_DATE, H.HEADER_ID, H.SOLD_TO_ORG_ID,
	       H.INVOICE_TO_ORG_ID, H.SHIP_TO_ORG_ID, H.DELIVER_TO_ORG_ID,
	       H.SOLD_TO_SITE_USE_ID, H.END_CUSTOMER_SITE_USE_ID,
	       H.END_CUSTOMER_ID,'N',M1.CUSTOMER_MERGE_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_ORDER_HEADERS H
	WHERE H.SHIP_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	UNION ALL
	SELECT
	       H.HEADER_ID , H.LAST_UPDATE_DATE, H.HEADER_ID, H.SOLD_TO_ORG_ID,
	       H.INVOICE_TO_ORG_ID, H.SHIP_TO_ORG_ID, H.DELIVER_TO_ORG_ID,
	       H.SOLD_TO_SITE_USE_ID, H.END_CUSTOMER_SITE_USE_ID,
	       H.END_CUSTOMER_ID,'N',M1.CUSTOMER_MERGE_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_ORDER_HEADERS H
	WHERE H.SOLD_TO_SITE_USE_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	UNION ALL
	SELECT
	       H.HEADER_ID , H.LAST_UPDATE_DATE, H.HEADER_ID, H.SOLD_TO_ORG_ID,
	       H.INVOICE_TO_ORG_ID, H.SHIP_TO_ORG_ID, H.DELIVER_TO_ORG_ID,
	       H.SOLD_TO_SITE_USE_ID, H.END_CUSTOMER_SITE_USE_ID,
	       H.END_CUSTOMER_ID,'N',M1.CUSTOMER_MERGE_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_ORDER_HEADERS H
	WHERE H.DELIVER_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	UNION ALL
	SELECT
	       H.HEADER_ID , H.LAST_UPDATE_DATE, H.HEADER_ID, H.SOLD_TO_ORG_ID,
	       H.INVOICE_TO_ORG_ID, H.SHIP_TO_ORG_ID, H.DELIVER_TO_ORG_ID,
	       H.SOLD_TO_SITE_USE_ID, H.END_CUSTOMER_SITE_USE_ID,
	       H.END_CUSTOMER_ID,'N',M1.CUSTOMER_MERGE_ID
        FROM
	RA_CUSTOMER_MERGES M1,  OE_ORDER_HEADERS H
	WHERE H.END_CUSTOMER_SITE_USE_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	UNION ALL
	SELECT
	       H.HEADER_ID , H.LAST_UPDATE_DATE, H.HEADER_ID, H.SOLD_TO_ORG_ID,
	       H.INVOICE_TO_ORG_ID, H.SHIP_TO_ORG_ID, H.DELIVER_TO_ORG_ID,
	       H.SOLD_TO_SITE_USE_ID, H.END_CUSTOMER_SITE_USE_ID,
	       H.END_CUSTOMER_ID,'N',M1.CUSTOMER_MERGE_ID
	FROM
	OE_CUST_MERGES_GTT M1,OE_ORDER_HEADERS H
	WHERE H.END_CUSTOMER_ID= M1.DUPLICATE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num;


  hdr_header_id_tab          num_table;
  hdr_sold_to_org_id_tab     num_table;
  hdr_invoice_to_org_id_tab  num_table;
  hdr_ship_to_org_id_tab     num_table;
  hdr_deliver_to_org_id_tab  num_table;
  hdr_sold_to_site_use_id_tab  num_table;
  hdr_end_cust_site_use_id_tab  num_table;
  hdr_end_cust_id_tab  num_table;

  old_hdr_sold_to_org_id_tab     num_table;
  old_hdr_invoice_to_org_id_tab  num_table;
  old_hdr_ship_to_org_id_tab     num_table;
  old_hdr_deliver_to_org_id_tab  num_table;
  old_hdr_sold_to_site_id_tab  num_table;
  old_hdr_end_cust_site_tab  num_table;
  old_hdr_end_cust_id_tab  num_table;

 TYPE num_table_binary_int IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 customer_id_tab        num_table_binary_int;
 customer_site_id_tab   num_table_binary_int;
 MERGE_HEADER_ID_LIST MERGE_ID_LIST_TYPE;
  --Added for Duplicate Check bug 8883694,9349882 ,9558975
     hdr_duplicate_flag_tab var_bin_table;
    l_header_id_tab        num_binary_int;

 l_profile_val VARCHAR2(30);

  dbi_local_hdr_header_id_tab num_bin_table := num_bin_table();
  dbi_local_hdr_update_date_tab date_bin_table := date_bin_table();
  l_global_count number :=0;

 BEGIN

 arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Headers()+' );

 IF (process_mode = 'LOCK') THEN

    -- try to open table for update, if it fails the exception will
    -- tell us that the merge was going to block

    arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'OE_ORDER_HEADERS_ALL', FALSE );

    open  merge_headers;
    close merge_headers;

 ELSE

   FOR C IN MERGE_SITES LOOP
      IF c.duplicate_id IS NOT NULL
	    AND NOT customer_id_tab.EXISTS(MOD(c.duplicate_id,G_BINARY_LIMIT)) THEN --bug8541941
	    	customer_id_tab(MOD(c.duplicate_id,G_BINARY_LIMIT)) := c.customer_id;
	    END IF;

    IF c.duplicate_site_id IS NOT NULL
	  AND NOT customer_site_id_tab.EXISTS(MOD(c.duplicate_site_id,G_BINARY_LIMIT)) THEN
		  customer_site_id_tab(MOD(c.duplicate_site_id,G_BINARY_LIMIT)) := c.customer_site_id;
	  END IF;
   END LOOP;


  HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
  l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

   -- GTT insertion , bug 8883694 ,9349882 ,9558975
       IF l_run_parallel_query = 'N' THEN
                                                                        ----bug 8883694,9349882  Inserting unique duplicate_id into GTT for a request .
      INSERT INTO  OE_CUST_MERGES_GTT(duplicate_id,request_id,set_number,process_flag,customer_merge_id)
      SELECT duplicate_id,request_id,set_number,process_flag, customer_merge_id
      FROM  	RA_CUSTOMER_MERGES M1
    	WHERE M1.PROCESS_FLAG='N'
    	AND M1.REQUEST_ID = req_id
    	AND M1.SET_NUMBER = set_num
      and m1.customer_merge_id=(select min(m2.customer_merge_id)
               from ra_customer_merges m2
    					where  M2.PROCESS_FLAG='N'
    					AND M2.REQUEST_ID = m1.request_id
    					AND M2.SET_NUMBER = m1.SET_NUMBER
    					and M2.DUPLICATE_ID = M1.DUPLICATE_ID
    				)      ;

       END IF ;


   -- Bug 7379750
   IF l_run_parallel_query = 'Y' THEN
	OPEN merge_headers_2;
   ELSE
	OPEN merge_headers_2_NP;
   END IF;


   LOOP

  -- Bug 7379750
   IF l_run_parallel_query = 'Y' THEN
     FETCH merge_headers_2
      BULK COLLECT INTO hdr_header_id_tab,
                        dbi_local_hdr_update_date_tab,
                        dbi_local_hdr_header_id_tab,
                        hdr_sold_to_org_id_tab,
                        hdr_invoice_to_org_id_tab,
                        hdr_ship_to_org_id_tab,
                        hdr_deliver_to_org_id_tab,
			hdr_sold_to_site_use_id_tab,
	                hdr_end_cust_site_use_id_tab,
	                hdr_end_cust_id_tab,
	                 hdr_duplicate_flag_tab, --Added for Duplicate Check bug 8883694,9349882,9558975
			MERGE_HEADER_ID_LIST
                        LIMIT 20000;
     ELSE
     FETCH merge_headers_2_NP
      BULK COLLECT INTO hdr_header_id_tab,
                        dbi_local_hdr_update_date_tab,
                        dbi_local_hdr_header_id_tab,
                        hdr_sold_to_org_id_tab,
                        hdr_invoice_to_org_id_tab,
                        hdr_ship_to_org_id_tab,
                        hdr_deliver_to_org_id_tab,
			hdr_sold_to_site_use_id_tab,
	                hdr_end_cust_site_use_id_tab,
	                hdr_end_cust_id_tab,
	                 hdr_duplicate_flag_tab, --Added for Duplicate Check bug 8883694,9349882,9558975
			MERGE_HEADER_ID_LIST
                        LIMIT 20000;
    END IF;


     old_hdr_sold_to_org_id_tab    :=  hdr_sold_to_org_id_tab;
     old_hdr_invoice_to_org_id_tab :=  hdr_invoice_to_org_id_tab;
     old_hdr_ship_to_org_id_tab    :=  hdr_ship_to_org_id_tab;
     old_hdr_deliver_to_org_id_tab :=  hdr_deliver_to_org_id_tab;
     old_hdr_sold_to_site_id_tab   := hdr_sold_to_site_use_id_tab;
     old_hdr_end_cust_site_tab := hdr_end_cust_site_use_id_tab;
     old_hdr_end_cust_id_tab   := hdr_end_cust_id_tab;


    IF  l_dbi_profile = 'Y' then
     arp_message.set_line(' update_date_tab_count for hdr='||dbi_local_hdr_update_date_tab.COUNT);
     IF dbi_local_hdr_update_date_tab.COUNT > 0 then


       IF dbi_header_update_date_tab.COUNT > 0 then
        l_global_count := dbi_header_update_date_tab.COUNT;
       ELSE
        l_global_count := 0;
       END IF;

       dbi_header_update_date_tab.EXTEND(dbi_local_hdr_update_date_tab.COUNT);
       dbi_header_header_id_tab.EXTEND(dbi_local_hdr_update_date_tab.COUNT);

     END IF;
     END IF;


    if hdr_header_id_tab.COUNT <> 0  then
     for i in  hdr_header_id_tab.FIRST..hdr_header_id_tab.LAST LOOP

     IF  l_dbi_profile = 'Y' then
        dbi_header_id_tab(hdr_header_id_tab(i)) := 1;
        dbi_header_update_date_tab(l_global_count + i) := dbi_local_hdr_update_date_tab(i);
        dbi_header_header_id_tab(l_global_count + i) := dbi_local_hdr_header_id_tab(i);
     END IF;

	    -- Access directly by the index position of the ids in the
	          -- values stored in customer_id_tab and customer_site_id_tab tables

	          if customer_id_tab.exists(MOD(hdr_sold_to_org_id_tab(i),G_BINARY_LIMIT)) then
	             hdr_sold_to_org_id_tab(i):= customer_id_tab(MOD(hdr_sold_to_org_id_tab(i),G_BINARY_LIMIT)); --bug8541941
	          end if;

	          if customer_site_id_tab.exists(MOD(hdr_invoice_to_org_id_tab(i),G_BINARY_LIMIT)) then
	 	    hdr_invoice_to_org_id_tab(i):= customer_site_id_tab(MOD(hdr_invoice_to_org_id_tab(i),G_BINARY_LIMIT)); --bug8541941
	          end if;

	          if customer_site_id_tab.exists(MOD(hdr_ship_to_org_id_tab(i),G_BINARY_LIMIT)) then
	 	    hdr_ship_to_org_id_tab(i):= customer_site_id_tab(MOD(hdr_ship_to_org_id_tab(i),G_BINARY_LIMIT)); --bug8541941
	          end if;

	          if customer_site_id_tab.exists(MOD(hdr_deliver_to_org_id_tab(i),G_BINARY_LIMIT)) then
	 	    hdr_deliver_to_org_id_tab(i):= customer_site_id_tab(MOD(hdr_deliver_to_org_id_tab(i),G_BINARY_LIMIT)); --bug8541941
	          end if;

		  if customer_site_id_tab.exists(MOD(hdr_sold_to_site_use_id_tab(i),G_BINARY_LIMIT)) then
	 	    hdr_sold_to_site_use_id_tab(i):= customer_site_id_tab(MOD(hdr_sold_to_site_use_id_tab(i),G_BINARY_LIMIT)); --bug8541941
	          end if;

		   if customer_site_id_tab.exists(MOD(hdr_end_cust_site_use_id_tab(i),G_BINARY_LIMIT)) then
	 	    hdr_end_cust_site_use_id_tab(i):= customer_site_id_tab(MOD(hdr_end_cust_site_use_id_tab(i),G_BINARY_LIMIT)); --bug8541941
	          end if;

		  if customer_id_tab.exists(MOD(hdr_end_cust_id_tab(i),G_BINARY_LIMIT)) then
	             hdr_end_cust_id_tab(i):= customer_id_tab(MOD(hdr_end_cust_id_tab(i),G_BINARY_LIMIT)); --bug8541941
	          end if;
	             --Added for Duplicate Check bug 8883694 ,9349882 ,9558975
		  	  		-- Code for marking the Duplicate Header_id's
		  			IF l_header_id_tab.EXISTS(MOD(hdr_header_id_tab(i),G_BINARY_LIMIT)) THEN
		  		  		  			hdr_duplicate_flag_tab(i) := 'Y';
		  	  		ELSE
		  	  		  			l_header_id_tab(MOD(hdr_header_id_tab(i),G_BINARY_LIMIT)):=1;
	                            END IF;


     end loop;
   end if;
arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Headers():3' );
   --insert audit information for customer merge
     IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	IF hdr_header_id_tab.COUNT <> 0 THEN
	forall i in  hdr_header_id_tab.FIRST..hdr_header_id_tab.LAST
	                   INSERT INTO HZ_CUSTOMER_MERGE_LOG (
				MERGE_LOG_ID,
				TABLE_NAME,
				MERGE_HEADER_ID,
				PRIMARY_KEY_ID1,
				NUM_COL1_ORIG,
				NUM_COL1_NEW,
				NUM_COL2_ORIG,
				NUM_COL2_NEW,
				NUM_COL3_ORIG,
				NUM_COL3_NEW,
				NUM_COL4_ORIG,
				NUM_COL4_NEW,
				NUM_COL5_ORIG,
				NUM_COL5_NEW,
				NUM_COL6_ORIG,
				NUM_COL6_NEW,
				NUM_COL7_ORIG,
				NUM_COL7_NEW,
				ACTION_FLAG,
				REQUEST_ID,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATE_LOGIN,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY
				) VALUES (
				HZ_CUSTOMER_MERGE_LOG_s.nextval,
				'OE_ORDER_HEADERS_ALL',
				MERGE_HEADER_ID_LIST(I),
				hdr_header_id_tab(I),
				old_hdr_sold_to_org_id_tab(I),
				decode(hdr_sold_to_org_id_tab(I),NULL,old_hdr_sold_to_org_id_tab(I),hdr_sold_to_org_id_tab(i)),
				old_hdr_invoice_to_org_id_tab(I),
				decode(hdr_invoice_to_org_id_tab(I),NULL,old_hdr_invoice_to_org_id_tab(I),hdr_invoice_to_org_id_tab(i)),
				old_hdr_ship_to_org_id_tab(I),
				decode(hdr_ship_to_org_id_tab(I),NULL,old_hdr_ship_to_org_id_tab(I),hdr_ship_to_org_id_tab(i)),
				old_hdr_deliver_to_org_id_tab(I),
				decode(hdr_deliver_to_org_id_tab(I),NULL,old_hdr_deliver_to_org_id_tab(I),hdr_deliver_to_org_id_tab(i)),
				old_hdr_sold_to_site_id_tab(I),
				decode(hdr_sold_to_site_use_id_tab(I),NULL,old_hdr_sold_to_site_id_tab(I),hdr_sold_to_site_use_id_tab(i)),
				old_hdr_end_cust_site_tab(I),
				decode(hdr_end_cust_site_use_id_tab(I),NULL,old_hdr_end_cust_site_tab(I),hdr_end_cust_site_use_id_tab(i)),
				old_hdr_end_cust_id_tab(I),
				decode(hdr_end_cust_id_tab(I),NULL,old_hdr_end_cust_id_tab(I),hdr_end_cust_id_tab(i)),
				'U',
				req_id,
				hz_utility_pub.CREATED_BY,
				hz_utility_pub.CREATION_DATE,
				hz_utility_pub.LAST_UPDATE_LOGIN,
				hz_utility_pub.LAST_UPDATE_DATE,
				hz_utility_pub.LAST_UPDATED_BY
				);

		   end if;
		end if;


     arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
     arp_message.set_token( 'TABLE_NAME', 'oe_order_headers_all', FALSE );
    IF hdr_header_id_tab.COUNT <> 0 THEN

      FORALL i in hdr_header_id_tab.FIRST..hdr_header_id_tab.LAST
        UPDATE OE_ORDER_HEADERS_ALL H
	  SET  sold_to_org_id    	  = decode(hdr_sold_to_org_id_tab(i),null,sold_to_org_id,hdr_sold_to_org_id_tab(i)),
	  invoice_to_org_id 	  = decode(hdr_invoice_to_org_id_tab(i),null,invoice_to_org_id,hdr_invoice_to_org_id_tab(i)),
            ship_to_org_id    	  = decode(hdr_ship_to_org_id_tab(i),null,ship_to_org_id,hdr_ship_to_org_id_tab(i)),
            deliver_to_org_id 	  = decode(hdr_deliver_to_org_id_tab(i),null,deliver_to_org_id,hdr_deliver_to_org_id_tab(i)),
	  sold_to_site_use_id   = decode(hdr_sold_to_site_use_id_tab(i),null,sold_to_site_use_id,hdr_sold_to_site_use_id_tab(i)),
	  end_customer_site_use_id   = decode(hdr_end_cust_site_use_id_tab(i),null,end_customer_site_use_id,hdr_end_cust_site_use_id_tab(i)),
   end_customer_id   = decode(hdr_end_cust_id_tab(i),null,end_customer_id,hdr_end_cust_id_tab(i)),
 	  last_update_date 	  = sysdate,
 	  last_updated_by 	  = arp_standard.profile.user_id,
 	  last_update_login      = arp_standard.profile.last_update_login,
 	  request_id             = req_id,
          program_application_id = arp_standard.profile.program_application_id ,
          program_id             = arp_standard.profile.program_id,
          program_update_date    = SYSDATE,
          lock_control           = lock_control+1
        WHERE header_id = hdr_header_id_tab(i)
        and hdr_duplicate_flag_tab(i) = 'N'; --Added for Duplicate Check bug 8883694,9349882 ,9558975
       ---duplicate check RETURNING last_update_date bulk collect into dbi_header_update_date_tab;

       g_count := sql%rowcount;
    ELSE
     g_count := 0;
    END IF;
     arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
     arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  -- Bug 7379750
     IF l_run_parallel_query = 'Y' THEN
	     EXIT WHEN merge_headers_2%NOTFOUND;
     ELSE
	     EXIT WHEN merge_headers_2_NP%NOTFOUND;
     END IF;
     hdr_header_id_tab.DELETE;
     hdr_sold_to_org_id_tab.DELETE;
     hdr_invoice_to_org_id_tab.DELETE;
     hdr_ship_to_org_id_tab.DELETE;
     hdr_deliver_to_org_id_tab.DELETE;
     hdr_sold_to_site_use_id_tab.DELETE;
     hdr_end_cust_site_use_id_tab.DELETE;
     hdr_end_cust_id_tab.DELETE;
      hdr_duplicate_flag_tab.DELETE; --Added for Duplicate Check bug 8883694,9349882 ,9558975

     old_hdr_sold_to_org_id_tab.DELETE;
     old_hdr_invoice_to_org_id_tab.DELETE;
     old_hdr_ship_to_org_id_tab.DELETE;
     old_hdr_deliver_to_org_id_tab.DELETE;
     old_hdr_sold_to_site_id_tab.DELETE;
     old_hdr_end_cust_site_tab.DELETE;
     old_hdr_end_cust_id_tab.DELETE;

   END LOOP;  -- cursor merge_headers_2

   -- Bug 7379750

   IF l_run_parallel_query = 'Y' THEN
	CLOSE merge_headers_2;
   ELSE
	CLOSE MERGE_HEADERS_2_NP;
   END IF;


 END IF;
    customer_id_tab.DELETE;
    customer_site_id_tab.DELETE;
    dbi_local_hdr_header_id_tab.DELETE;
    dbi_local_hdr_update_date_tab.DELETE;

    arp_message.set_line(' header_id_tab_count for hdr='||dbi_header_header_id_tab.COUNT);
    arp_message.set_line(' update_date_tab_count for hdr='||dbi_header_update_date_tab.COUNT);

    arp_message.set_line( ' END OE_CUST_MERGE.OE_Merge_Headers()-' );


 EXCEPTION
 when others then
 	arp_message.set_error( 'OE_CUST_MERGE.OE_Merge_Headers-' );
    raise;

 END OE_Merge_Headers;


/*-------------------------------------------------*/
/*--- PRIVATE Procedure OE_Merge_Header_History ---*/
/*-------------------------------------------------*/

Procedure OE_Merge_Header_History (Req_Id          IN NUMBER,
                             Set_Num         IN NUMBER,
                             Process_Mode    IN VARCHAR2)
 IS
--3196900
 CURSOR MERGE_SITES IS
     select duplicate_id, customer_id, duplicate_site_id, customer_site_id
       from ra_customer_merges m
       where m.process_flag = 'N'
       and m.request_id = req_id
     and m.set_number = set_num;
 /* MOAC_SQL_CHANGE */
 CURSOR MERGE_HEADERS_HISTORY IS
 SELECT /*+ PARALLEL(L)
            PARALLEL(M1)
            PARALLEL(M2)
            PARALLEL(M3)
            PARALLEL(M4)
            PARALLEL(M5)
            PARALLEL(M6)
            PARALLEL(M7) */
  hist.header_id ,
  hist.sold_to_org_id,
  hist.invoice_to_org_id,
  hist.ship_to_org_id,
  hist.sold_to_site_use_id,
  hist.deliver_to_org_id,
  hist.end_customer_site_use_id,
  hist.end_customer_id
 FROM RA_CUSTOMER_MERGES M1,
      RA_CUSTOMER_MERGES M2,
      RA_CUSTOMER_MERGES M3,
      RA_CUSTOMER_MERGES M4,
      RA_CUSTOMER_MERGES M5,
      RA_CUSTOMER_MERGES M6,
      RA_CUSTOMER_MERGES M7,
      OE_ORDER_HEADER_HISTORY HIST,
     -- Changed by Srini for MOAC
     -- This MOAC change has been reverted.
     -- For more information please
     -- see the bug #5050382
      OE_ORDER_HEADERS   H
 WHERE
     ( hist.sold_to_org_id        = m1.duplicate_id(+)
   and hist.invoice_to_org_id     = m2.duplicate_site_id(+)
   and hist.ship_to_org_id        = m3.duplicate_site_id(+)
   and hist.sold_to_site_use_id   = m4.duplicate_site_id(+)
   and hist.deliver_to_org_id     = m5.duplicate_site_id(+)
   and hist.end_customer_site_use_id   = m6.duplicate_site_id(+)
   and hist.end_customer_id       = m7.duplicate_id(+)
 )
   and
   (m1.duplicate_site_id is not null or
    m2.duplicate_id is not null or
    m3.duplicate_id is not null or
    m4.duplicate_id is not null or
    m5.duplicate_id is not null  or
    m6.duplicate_id is not null or
    m7.duplicate_site_id is not null)
   and m1.process_flag(+) = 'N'
   and m2.process_flag(+) = 'N'
   and m3.process_flag(+) = 'N'
   and m4.process_flag(+) = 'N'
   and m5.process_flag(+) = 'N'
   and m6.process_flag(+) = 'N'
   and m7.process_flag(+) = 'N'
   and m1.request_id(+) =req_id
   and m2.request_id(+) =req_id
   and m3.request_id(+) =req_id
   and m4.request_id(+) =req_id
   and m5.request_id(+) =req_id
   and m6.request_id(+) =req_id
   and m7.request_id(+) =req_id
   and m1.set_number(+) =set_num
   and m2.set_number(+) =set_num
   and m3.set_number(+) =set_num
   and m4.set_number(+) =set_num
   and m5.set_number(+) =set_num
   and m6.set_number(+) =set_num
   and m7.set_number(+) =set_num
   and hist.header_id=h.header_id
 for update nowait;

 /* MOAC_SQL_CHANGE */
 CURSOR MERGE_HEADERS_HISTORY_2 IS
 SELECT /*+ PARALLEL(L)
            PARALLEL(M1)
            PARALLEL(M2)
            PARALLEL(M3)
            PARALLEL(M4)
            PARALLEL(M5)
            PARALLEL(M6)
            PARALLEL(M7) */
  hist.header_id ,
  hist.sold_to_org_id,
  hist.invoice_to_org_id,
  hist.ship_to_org_id,
  hist.sold_to_site_use_id,
  hist.deliver_to_org_id,
  hist.end_customer_site_use_id,
  hist.end_customer_id
 FROM RA_CUSTOMER_MERGES M1,
      RA_CUSTOMER_MERGES M2,
      RA_CUSTOMER_MERGES M3,
      RA_CUSTOMER_MERGES M4,
      RA_CUSTOMER_MERGES M5,
      RA_CUSTOMER_MERGES M6,
      RA_CUSTOMER_MERGES M7,
      OE_ORDER_HEADER_HISTORY HIST,
      --Changed for MOAC
      OE_ORDER_HEADERS_ALL   H
 WHERE
     ( hist.sold_to_org_id        = m1.duplicate_id(+)
   and hist.invoice_to_org_id     = m2.duplicate_site_id(+)
   and hist.ship_to_org_id        = m3.duplicate_site_id(+)
   and hist.sold_to_site_use_id   = m4.duplicate_site_id(+)
   and hist.deliver_to_org_id     = m5.duplicate_site_id(+)
   and hist.end_customer_site_use_id   = m6.duplicate_site_id(+)
   and hist.end_customer_id       = m7.duplicate_id(+)
 )
   and
   (m1.duplicate_site_id is not null or
    m2.duplicate_id is not null or
    m3.duplicate_id is not null or
    m4.duplicate_id is not null or
    m5.duplicate_id is not null  or
    m6.duplicate_id is not null or
    m7.duplicate_site_id is not null)
   and m1.process_flag(+) = 'N'
   and m2.process_flag(+) = 'N'
   and m3.process_flag(+) = 'N'
   and m4.process_flag(+) = 'N'
   and m5.process_flag(+) = 'N'
   and m6.process_flag(+) = 'N'
   and m7.process_flag(+) = 'N'
   and m1.request_id(+) =req_id
   and m2.request_id(+) =req_id
   and m3.request_id(+) =req_id
   and m4.request_id(+) =req_id
   and m5.request_id(+) =req_id
   and m6.request_id(+) =req_id
   and m7.request_id(+) =req_id
   and m1.set_number(+) =set_num
   and m2.set_number(+) =set_num
   and m3.set_number(+) =set_num
   and m4.set_number(+) =set_num
   and m5.set_number(+) =set_num
   and m6.set_number(+) =set_num
   and m7.set_number(+) =set_num
   and hist.header_id=h.header_id ;

 CURSOR MERGE_HEADERS_HISTORY_2_NP IS
	SELECT
	  HIST.HEADER_ID ,  HIST.SOLD_TO_ORG_ID,  HIST.INVOICE_TO_ORG_ID,
	  HIST.SHIP_TO_ORG_ID,  HIST.SOLD_TO_SITE_USE_ID,  HIST.DELIVER_TO_ORG_ID,
	  HIST.END_CUSTOMER_SITE_USE_ID,  HIST.END_CUSTOMER_ID
	FROM
	OE_CUST_MERGES_GTT  M1, OE_ORDER_HEADERS_ALL H, OE_ORDER_HEADER_HISTORY HIST
	WHERE HIST.SOLD_TO_ORG_ID = M1.DUPLICATE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
        AND HIST.HEADER_ID=H.HEADER_ID
	UNION ALL
	SELECT
	  HIST.HEADER_ID ,  HIST.SOLD_TO_ORG_ID,  HIST.INVOICE_TO_ORG_ID,
	  HIST.SHIP_TO_ORG_ID,  HIST.SOLD_TO_SITE_USE_ID,  HIST.DELIVER_TO_ORG_ID,
	  HIST.END_CUSTOMER_SITE_USE_ID,  HIST.END_CUSTOMER_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_ORDER_HEADERS_ALL H, OE_ORDER_HEADER_HISTORY HIST
	WHERE HIST.INVOICE_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
        AND HIST.HEADER_ID=H.HEADER_ID
	UNION ALL
	SELECT
	  HIST.HEADER_ID ,  HIST.SOLD_TO_ORG_ID,  HIST.INVOICE_TO_ORG_ID,
	  HIST.SHIP_TO_ORG_ID,  HIST.SOLD_TO_SITE_USE_ID,  HIST.DELIVER_TO_ORG_ID,
	  HIST.END_CUSTOMER_SITE_USE_ID,  HIST.END_CUSTOMER_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_ORDER_HEADERS_ALL H, OE_ORDER_HEADER_HISTORY HIST
	WHERE HIST.SHIP_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
        AND HIST.HEADER_ID=H.HEADER_ID
	UNION ALL
	SELECT
	  HIST.HEADER_ID ,  HIST.SOLD_TO_ORG_ID,  HIST.INVOICE_TO_ORG_ID,
	  HIST.SHIP_TO_ORG_ID,  HIST.SOLD_TO_SITE_USE_ID,  HIST.DELIVER_TO_ORG_ID,
	  HIST.END_CUSTOMER_SITE_USE_ID,  HIST.END_CUSTOMER_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_ORDER_HEADERS_ALL H, OE_ORDER_HEADER_HISTORY HIST
	WHERE HIST.SOLD_TO_SITE_USE_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
        AND HIST.HEADER_ID=H.HEADER_ID
	UNION ALL
	SELECT
	  HIST.HEADER_ID ,  HIST.SOLD_TO_ORG_ID,  HIST.INVOICE_TO_ORG_ID,
	  HIST.SHIP_TO_ORG_ID,  HIST.SOLD_TO_SITE_USE_ID,  HIST.DELIVER_TO_ORG_ID,
	  HIST.END_CUSTOMER_SITE_USE_ID,  HIST.END_CUSTOMER_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_ORDER_HEADERS_ALL H, OE_ORDER_HEADER_HISTORY HIST
	WHERE HIST.DELIVER_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
        AND HIST.HEADER_ID=H.HEADER_ID
	UNION ALL
	SELECT
	  HIST.HEADER_ID ,  HIST.SOLD_TO_ORG_ID,  HIST.INVOICE_TO_ORG_ID,
	  HIST.SHIP_TO_ORG_ID,  HIST.SOLD_TO_SITE_USE_ID,  HIST.DELIVER_TO_ORG_ID,
	  HIST.END_CUSTOMER_SITE_USE_ID,  HIST.END_CUSTOMER_ID
        FROM
	RA_CUSTOMER_MERGES M1,  OE_ORDER_HEADERS_ALL H, OE_ORDER_HEADER_HISTORY HIST
	WHERE HIST.END_CUSTOMER_SITE_USE_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
        AND HIST.HEADER_ID=H.HEADER_ID
	UNION ALL
	SELECT
	  HIST.HEADER_ID ,  HIST.SOLD_TO_ORG_ID,  HIST.INVOICE_TO_ORG_ID,
	  HIST.SHIP_TO_ORG_ID,  HIST.SOLD_TO_SITE_USE_ID,  HIST.DELIVER_TO_ORG_ID,
	  HIST.END_CUSTOMER_SITE_USE_ID,  HIST.END_CUSTOMER_ID
	FROM
	OE_CUST_MERGES_GTT M1,OE_ORDER_HEADERS_ALL H, OE_ORDER_HEADER_HISTORY HIST
	WHERE HIST.END_CUSTOMER_ID= M1.DUPLICATE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
        AND HIST.HEADER_ID=H.HEADER_ID	;


  hhst_header_id_tab	      num_table;
  hhst_sold_to_org_id_tab     num_table;
  hhst_invoice_to_org_id_tab  num_table;
  hhst_ship_to_org_id_tab     num_table;
  hhst_sold_to_site_use_id_tab     num_table;
  hhst_deliver_to_org_id_tab  num_table;
  hhst_end_cust_site_use_id_tab  num_table;
  hhst_end_cust_id_tab  num_table;

  TYPE num_table_binary_int IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  customer_id_tab        num_table_binary_int;
  customer_site_id_tab   num_table_binary_int;

 BEGIN

 arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_HEADER_History()+' );

 IF (process_mode = 'LOCK') THEN

   arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
   arp_message.set_token( 'TABLE_NAME', 'oe_order_header_history', FALSE );

   open  merge_headers_history;
   close merge_headers_history;

 ELSE

 FOR C IN MERGE_SITES LOOP
          IF c.duplicate_id IS NOT NULL
             AND NOT customer_id_tab.EXISTS(MOD(c.duplicate_id,G_BINARY_LIMIT)) THEN
             customer_id_tab(MOD(c.duplicate_id,G_BINARY_LIMIT)) := c.customer_id; --bug8541941
          END IF;

          IF c.duplicate_site_id IS NOT NULL
             AND NOT customer_site_id_tab.EXISTS(MOD(c.duplicate_site_id,G_BINARY_LIMIT)) THEN
             customer_site_id_tab(MOD(c.duplicate_site_id,G_BINARY_LIMIT)) := c.customer_site_id;--bug8541941
          END IF;

  END LOOP;


  -- Bug 7379750
  IF l_run_parallel_query = 'Y' THEN
	OPEN merge_headers_history_2;
  ELSE
	OPEN merge_headers_history_2_NP;
  END IF;

  LOOP

  -- Bug 7379750
  IF l_run_parallel_query = 'Y' THEN
     FETCH merge_headers_history_2
      BULK COLLECT INTO hhst_header_id_tab,
                        hhst_sold_to_org_id_tab,
                        hhst_invoice_to_org_id_tab,
                        hhst_ship_to_org_id_tab,
                        hhst_sold_to_site_use_id_tab,
                        hhst_deliver_to_org_id_tab,
	                hhst_end_cust_site_use_id_tab,
	                hhst_end_cust_id_tab
                        LIMIT 20000;
   ELSE
     FETCH merge_headers_history_2_NP
      BULK COLLECT INTO hhst_header_id_tab,
                        hhst_sold_to_org_id_tab,
                        hhst_invoice_to_org_id_tab,
                        hhst_ship_to_org_id_tab,
                        hhst_sold_to_site_use_id_tab,
                        hhst_deliver_to_org_id_tab,
	                hhst_end_cust_site_use_id_tab,
	                hhst_end_cust_id_tab
                        LIMIT 20000;
  END IF;



      if hhst_header_id_tab.COUNT <> 0 then
       for i in  hhst_header_id_tab.FIRST..hhst_header_id_tab.LAST LOOP
	        -- Access directly by the index position of the ids in the
	          -- values stored in customer_id_tab and customer_site_id_tab tables

	          if customer_id_tab.exists(MOD(hhst_sold_to_org_id_tab(i),G_BINARY_LIMIT)) then
	             hhst_sold_to_org_id_tab(i):= customer_id_tab(MOD(hhst_sold_to_org_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;

	          if customer_site_id_tab.exists(MOD(hhst_invoice_to_org_id_tab(i),G_BINARY_LIMIT)) then
	 	        hhst_invoice_to_org_id_tab(i):= customer_site_id_tab(MOD(hhst_invoice_to_org_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;

	          if customer_site_id_tab.exists(MOD(hhst_ship_to_org_id_tab(i),G_BINARY_LIMIT)) then
	 	       hhst_ship_to_org_id_tab(i):= customer_site_id_tab(MOD(hhst_ship_to_org_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;

	          if customer_site_id_tab.exists(MOD(hhst_sold_to_site_use_id_tab(i),G_BINARY_LIMIT)) then
		  	hhst_sold_to_site_use_id_tab(i):= customer_site_id_tab(MOD(hhst_sold_to_site_use_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;

	          if customer_site_id_tab.exists(MOD(hhst_deliver_to_org_id_tab(i),G_BINARY_LIMIT)) then
	 	        hhst_deliver_to_org_id_tab(i):= customer_site_id_tab(MOD(hhst_deliver_to_org_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;

		  if customer_site_id_tab.exists(MOD(hhst_end_cust_site_use_id_tab(i),G_BINARY_LIMIT)) then
	 	        hhst_end_cust_site_use_id_tab(i):= customer_site_id_tab(MOD(hhst_end_cust_site_use_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;

		  if customer_id_tab.exists(MOD(hhst_end_cust_id_tab(i),G_BINARY_LIMIT)) then
	             hhst_end_cust_id_tab(i):= customer_id_tab(MOD(hhst_end_cust_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;


     end loop;
     end if;


     arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
     arp_message.set_token( 'TABLE_NAME', 'oe_order_header_history', FALSE );

    IF hhst_header_id_tab.COUNT <> 0 THEN
     FORALL i in hhst_header_id_tab.FIRST..hhst_header_id_tab.LAST
       UPDATE OE_ORDER_HEADER_HISTORY HHIST
       SET  sold_to_org_id    	  = decode(hhst_sold_to_org_id_tab(i),null,sold_to_org_id,hhst_sold_to_org_id_tab(i)),
            invoice_to_org_id 	  = decode(hhst_invoice_to_org_id_tab(i),null,invoice_to_org_id,hhst_invoice_to_org_id_tab(i)),
            ship_to_org_id    	  = decode(hhst_ship_to_org_id_tab(i),null,ship_to_org_id,hhst_ship_to_org_id_tab(i)),
            sold_to_site_use_id  = decode(hhst_sold_to_site_use_id_tab(i),null,sold_to_site_use_id,hhst_sold_to_site_use_id_tab(i)),
            deliver_to_org_id 	  = decode(hhst_deliver_to_org_id_tab(i),null,deliver_to_org_id,hhst_deliver_to_org_id_tab(i)),
            end_customer_site_use_id = decode(hhst_end_cust_site_use_id_tab(i),null,end_customer_site_use_id,hhst_end_cust_site_use_id_tab(i)),
	    end_customer_id    	  = decode(hhst_end_cust_id_tab(i),null,end_customer_id,hhst_end_cust_id_tab(i)),
 	   last_update_date 	  = sysdate,
 	   last_updated_by 	  = arp_standard.profile.user_id,
 	   last_update_login      = arp_standard.profile.last_update_login,
 	   request_id             = req_id,
            program_application_id = arp_standard.profile.program_application_id ,
            program_id             = arp_standard.profile.program_id,
            program_update_date    = SYSDATE
        WHERE header_id = hhst_header_id_tab(i);

     g_count := sql%rowcount;

    ELSE
      g_count := 0;
    END IF;

     arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
     arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  -- Bug 7379750
  IF l_run_parallel_query = 'Y' THEN
     EXIT WHEN merge_headers_history_2%NOTFOUND;
  ELSE
     EXIT WHEN merge_headers_history_2_NP%NOTFOUND;
  END IF;

     hhst_header_id_tab.DELETE;
     hhst_sold_to_org_id_tab.DELETE;
     hhst_invoice_to_org_id_tab.DELETE;
     hhst_ship_to_org_id_tab.DELETE;
     hhst_sold_to_site_use_id_tab.DELETE;
     hhst_deliver_to_org_id_tab.DELETE;
     hhst_end_cust_site_use_id_tab.DELETE;
     hhst_end_cust_id_tab.DELETE;

   END LOOP;  -- cursor merge_headers_history_2

  -- Bug 7379750
  IF l_run_parallel_query = 'Y' THEN
	CLOSE merge_headers_history_2;
  ELSE
	CLOSE merge_headers_history_2_NP;
  END IF;

 END IF;
    customer_id_tab.DELETE;
    customer_site_id_tab.DELETE;
    arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Header_History()-' );

 EXCEPTION
 when others then
 	arp_message.set_error( 'OE_CUST_MERGE.OE_Merge_Header_History-' );
     raise;

 END OE_MERGE_HEADER_HISTORY; -- 3196900

/* CURSOR c1 is
    select HEADER_ID
      from oe_order_header_history
     where ship_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c2 is
    select HEADER_ID
      from oe_order_header_history
     where invoice_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c3 is
    select HEADER_ID
      from oe_order_header_history
     where deliver_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c4 is
    select HEADER_ID
      from oe_order_header_history
     where sold_to_org_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;

  CURSOR c5 is
    select HEADER_ID
      from oe_order_header_history
     where sold_to_site_use_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;

  CURSOR c6 is
    select HEADER_ID
      from oe_order_header_history
     where end_customer_site_use_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;

CURSOR c7 is
    select HEADER_ID
      from oe_order_header_history
     where end_customer_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;

 BEGIN
    arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Header_History()+' );

    --  both customer and site level

    IF( process_mode = 'LOCK' ) THEN

      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'OE_ORDER_HEADER_HISTORY', FALSE );

      open c1;
      close c1;

      open c2;
      close c2;

      open c3;
      close c3;

      open c4;
      close c4;

      open c5;
      close c5;

      open c6;
      close c6;

      open c7;
      close c7;

ELSE


    -- site level update
    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'OE_ORDER_HEADER_HISTORY', FALSE );

    UPDATE oe_order_header_history  a
    set ship_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.ship_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'N'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login,
          request_id = req_id,
          program_application_id =arp_standard.profile.program_application_id,
          program_id = arp_standard.profile.program_id,
          program_update_date = sysdate
    where ship_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );


    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'OE_ORDER_HEADER_HISTORY', FALSE );

    UPDATE oe_order_header_history  a
    set invoice_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.invoice_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'N'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login,
          request_id = req_id,
          program_application_id =arp_standard.profile.program_application_id,
          program_id = arp_standard.profile.program_id,
          program_update_date = sysdate
    where invoice_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'OE_ORDER_HEADER_HISTORY', FALSE );

    UPDATE oe_order_header_history  a
    set deliver_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.deliver_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'N'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login,
          request_id = req_id,
          program_application_id =arp_standard.profile.program_application_id,
          program_id = arp_standard.profile.program_id,
          program_update_date = sysdate
    where deliver_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'OE_ORDER_HEADER_HISTORY', FALSE );


   -- customer level update --

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_order_header_history', FALSE );

    UPDATE oe_order_header_history  a
    set    sold_to_org_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.sold_to_org_id = m.duplicate_id
                                and    m.process_flag = 'N'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where  sold_to_org_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'N'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num);

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'OE_ORDER_HEADER_HISTORY', FALSE );

    UPDATE oe_order_header_history  a
    set    sold_to_site_use_id = (select distinct m.customer_id
				    from   ra_customer_merges m
				   where  a.sold_to_site_use_id = m.duplicate_id
				     and    m.process_flag = 'N'
				     and    m.request_id = req_id
				     and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where  sold_to_site_use_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'N'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num);

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'OE_ORDER_HEADER_HISTORY', FALSE );

    UPDATE oe_order_header_history  a
    set    end_customer_site_use_id = (select distinct m.customer_id
				    from   ra_customer_merges m
				   where  a.end_customer_site_use_id = m.duplicate_id
				     and    m.process_flag = 'N'
				     and    m.request_id = req_id
				     and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where  end_customer_site_use_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'N'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num);

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    -- customer level update --

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_order_header_history', FALSE );

    UPDATE oe_order_header_history  a
    set    end_customer_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.end_customer_id = m.duplicate_id
                                and    m.process_flag = 'N'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where  end_customer_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'N'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num);

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

    arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Header_History()-' );

    EXCEPTION
    When others then
      arp_message.set_error( 'OE_CUST_MERGE.OE_Merge_Header_History-' );
      raise;

 END OE_Merge_Header_History; */

/*------------------------------------------------*/
/*--- PRIVATE PROCEDURE OE_Merge_Headers_IFACE ---*/
/*------------------------------------------------*/

/* -- Interface tables need not be updated
   -- Not logging merge for Interface tables

 Procedure OE_Merge_Headers_IFACE (Req_Id          IN NUMBER,
                                   Set_Num         IN NUMBER,
                                   Process_Mode    IN VARCHAR2)
 IS
 CURSOR c1 is
    select HEADER_ID
      from oe_headers_iface_all
     where ship_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c2 is
    select HEADER_ID
      from oe_headers_iface_all
     where invoice_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c3 is
    select HEADER_ID
      from oe_headers_iface_all
     where deliver_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;

 CURSOR c4 is
    select HEADER_ID
      from oe_headers_iface_all
     where sold_to_org_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;




 BEGIN
    arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Headers_IFACE()+' );

    --  both customer and site level

    IF( process_mode = 'LOCK' ) THEN

      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'oe_headers_iface_all', FALSE );

      open c1;
      close c1;

      open c2;
      close c2;

      open c3;
      close c3;

      open c4;
      close c4;


ELSE

    --  site level update
    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_headers_iface_all', FALSE );

    UPDATE oe_headers_iface_all  a
    set ship_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.ship_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'N'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login,
          request_id = req_id,
          program_application_id =arp_standard.profile.program_application_id,
          program_id = arp_standard.profile.program_id,
          program_update_date = sysdate
    where ship_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_headers_iface_all', FALSE );

    UPDATE oe_headers_iface_all  a
    set invoice_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.invoice_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'N'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login,
          request_id = req_id,
          program_application_id =arp_standard.profile.program_application_id,
          program_id = arp_standard.profile.program_id,
          program_update_date = sysdate
    where invoice_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_headers_iface_all', FALSE );

    UPDATE oe_headers_iface_all  a
    set deliver_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.deliver_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'N'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login,
          request_id = req_id,
          program_application_id =arp_standard.profile.program_application_id,
          program_id = arp_standard.profile.program_id,
          program_update_date = sysdate
    where deliver_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_headers_iface_all', FALSE );


   -- customer level update
    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_headers_iface_all', FALSE );

    UPDATE oe_headers_iface_all  a
    set    sold_to_org_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.sold_to_org_id = m.duplicate_id
                                and    m.process_flag = 'N'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where  sold_to_org_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'N'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num);

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

    arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Headers_IFACE()-' );

    EXCEPTION
    When others then
      arp_message.set_error( 'OE_CUST_MERGE.OE_Merge_Headers_IFACE-' );
      raise;

 END OE_Merge_Headers_IFACE;

Interface tables need not be updated */

/*------------------------------------------------*/
/*--- PRIVATE PROCEDURE OE_Merge_Header_ACKS   ---*/
/*------------------------------------------------*/


 Procedure OE_Merge_Header_ACKS (Req_Id          IN NUMBER,
                                 Set_Num         IN NUMBER,
                                 Process_Mode    IN VARCHAR2)
 IS
 CURSOR c1 is
    select HEADER_ID
      from OE_HEADER_ACKS
     where ship_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
    for update nowait;


 CURSOR c2 is
    select HEADER_ID
      from OE_HEADER_ACKS
     where invoice_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
    for update nowait;


 CURSOR c3 is
    select HEADER_ID
      from OE_HEADER_ACKS
     where deliver_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
    for update nowait;

 CURSOR c4 is
--changed for bug 3196900
    select /* MOAC_SQL_CHANGE */ a.HEADER_ID
    from OE_HEADER_ACKS a, OE_ORDER_HEADERS_all h
     where a.sold_to_org_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
--changed for bug 3196900
  and a.header_id=h.header_id
  for update nowait;

CURSOR c5 is
    select HEADER_ID
      from OE_HEADER_ACKS
     where sold_to_site_use_id in
     (select m.duplicate_id
	from ra_customer_merges m
       where m.process_flag = 'N'
	 and m.request_id = req_id
	 and m.set_number = set_num)
       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
	   for update nowait;

  CURSOR c6 is
    select HEADER_ID
      from OE_HEADER_ACKS
     where end_customer_site_use_id in
     (select m.duplicate_id
	from ra_customer_merges m
       where m.process_flag = 'N'
	 and m.request_id = req_id
	 and m.set_number = set_num)
       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
	   for update nowait;

CURSOR c7 is
--changed for bug 3196900
    select a.HEADER_ID
      from OE_HEADER_ACKS a,OE_ORDER_HEADERS h
     where a.end_customer_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
-- changed for bug 3196900
  and a.header_id=h.header_id
  for update nowait;

l_profile_val VARCHAR2(30);

 BEGIN
    arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Header_ACKS()+' );

    /* both customer and site level */

    IF( process_mode = 'LOCK' ) THEN

      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'OE_HEADER_ACKS', FALSE );

      open c1;
      close c1;

      open c2;
      close c2;

      open c3;
      close c3;

      open c4;
      close c4;

 open c5;
      close c5;

      open c6;
      close c6;

      open c7;
      close c7;

ELSE

    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       insert into  HZ_CUSTOMER_MERGE_LOG (
		MERGE_LOG_ID,
		TABLE_NAME,
		MERGE_HEADER_ID,
		PRIMARY_KEY1,
		NUM_COL3_ORIG,
		NUM_COL3_NEW,
		ACTION_FLAG,
		REQUEST_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY
		)
		select
		HZ_CUSTOMER_MERGE_LOG_s.nextval,
		'OE_HEADER_ACKS',
		m.CUSTOMER_MERGE_HEADER_ID,
		h.ORIG_SYS_DOCUMENT_REF,
		h.ship_to_org_id,
		m.customer_site_id,
		'U',
		req_id,
		hz_utility_pub.CREATED_BY,
		hz_utility_pub.CREATION_DATE,
		hz_utility_pub.LAST_UPDATE_LOGIN,
		hz_utility_pub.LAST_UPDATE_DATE,
		hz_utility_pub.LAST_UPDATED_BY
	        from oe_header_acks h,
		     ra_customer_merges m
               where h.ship_to_org_id=m.duplicate_site_id
                 and m.process_flag = 'N'
                 and m.request_id = req_id
                 and m.set_number = set_num
		 and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
  end if;

    /* site level update */
    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'OE_HEADER_ACKS', FALSE );

    UPDATE OE_HEADER_ACKS  a
    set ship_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.ship_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'N'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login,
          request_id = req_id,
          program_application_id =arp_standard.profile.program_application_id,
          program_id = arp_standard.profile.program_id,
          program_update_date = sysdate
    where ship_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
			                 and m.request_id = req_id
			                 and m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
    g_count := sql%rowcount;
    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       insert into  HZ_CUSTOMER_MERGE_LOG (
		MERGE_LOG_ID,
		TABLE_NAME,
		MERGE_HEADER_ID,
		PRIMARY_KEY1,
		NUM_COL2_ORIG,
		NUM_COL2_NEW,
		ACTION_FLAG,
		REQUEST_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY
		)
		select
		HZ_CUSTOMER_MERGE_LOG_s.nextval,
		'OE_HEADERS_ACKS',
		m.CUSTOMER_MERGE_HEADER_ID,
		h.ORIG_SYS_DOCUMENT_REF,
		h.invoice_to_org_id,
		m.customer_site_id,
		'U',
		req_id,
		hz_utility_pub.CREATED_BY,
		hz_utility_pub.CREATION_DATE,
		hz_utility_pub.LAST_UPDATE_LOGIN,
		hz_utility_pub.LAST_UPDATE_DATE,
		hz_utility_pub.LAST_UPDATED_BY
	        from oe_header_acks h,
		     ra_customer_merges m
               where h.invoice_to_org_id=m.duplicate_site_id
                 and m.process_flag = 'N'
                 and m.request_id = req_id
                 and m.set_number = set_num
		 and NVL(h.ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
  end if;

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'OE_HEADER_ACKS', FALSE );

    UPDATE OE_HEADER_ACKS  a
    set invoice_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.invoice_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'N'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login,
          request_id = req_id,
          program_application_id =arp_standard.profile.program_application_id,
          program_id = arp_standard.profile.program_id,
          program_update_date = sysdate
    where invoice_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
			                 and m.request_id = req_id
			                 and m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
    g_count := sql%rowcount;
    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'OE_HEADER_ACKS', FALSE );

  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       insert into  HZ_CUSTOMER_MERGE_LOG (
		MERGE_LOG_ID,
		TABLE_NAME,
		MERGE_HEADER_ID,
		PRIMARY_KEY1,
		NUM_COL4_ORIG,
		NUM_COL4_NEW,
		ACTION_FLAG,
		REQUEST_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY
		)
		select
		HZ_CUSTOMER_MERGE_LOG_s.nextval,
		'OE_HEADER_ACKS',
		m.CUSTOMER_MERGE_HEADER_ID,
		h.ORIG_SYS_DOCUMENT_REF,
		h.deliver_to_org_id,
		m.customer_site_id,
		'U',
		req_id,
		hz_utility_pub.CREATED_BY,
		hz_utility_pub.CREATION_DATE,
		hz_utility_pub.LAST_UPDATE_LOGIN,
		hz_utility_pub.LAST_UPDATE_DATE,
		hz_utility_pub.LAST_UPDATED_BY
	        from oe_header_acks h,
		     ra_customer_merges m
               where h.deliver_to_org_id=m.duplicate_site_id
                 and m.process_flag = 'N'
                 and m.request_id = req_id
                 and m.set_number = set_num
		 and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
  end if;

    UPDATE OE_HEADER_ACKS  a
    set deliver_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.deliver_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'N'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login,
          request_id = req_id,
          program_application_id =arp_standard.profile.program_application_id,
          program_id = arp_standard.profile.program_id,
          program_update_date = sysdate
    where deliver_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
			                 and m.request_id = req_id
			                 and m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
    g_count := sql%rowcount;
    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'OE_HEADER_ACKS', FALSE );


   /* customer level update */
    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'OE_HEADER_ACKS', FALSE );

  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       insert into  HZ_CUSTOMER_MERGE_LOG (
		MERGE_LOG_ID,
		TABLE_NAME,
		MERGE_HEADER_ID,
		PRIMARY_KEY1,
		NUM_COL1_ORIG,
		NUM_COL1_NEW,
		ACTION_FLAG,
		REQUEST_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY
		)
		select
		HZ_CUSTOMER_MERGE_LOG_s.nextval,
		'OE_HEADER_ACKS',
		m.CUSTOMER_MERGE_HEADER_ID,
		h.ORIG_SYS_DOCUMENT_REF,
		h.sold_to_org_id,
		m.customer_site_id,
		'U',
		req_id,
		hz_utility_pub.CREATED_BY,
		hz_utility_pub.CREATION_DATE,
		hz_utility_pub.LAST_UPDATE_LOGIN,
		hz_utility_pub.LAST_UPDATE_DATE,
		hz_utility_pub.LAST_UPDATED_BY
	        from oe_header_acks h,
		     ra_customer_merges m
               where h.sold_to_org_id=m.duplicate_site_id
                 and m.process_flag = 'N'
                 and m.request_id = req_id
                 and m.set_number = set_num
		 and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
  end if;

    UPDATE OE_HEADER_ACKS  a
    set    sold_to_org_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.sold_to_org_id = m.duplicate_id
                                and    m.process_flag = 'N'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where  sold_to_org_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'N'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
--changed for bug 3196900
      and a.header_id in (select header_id from oe_order_headers);

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    -- sold_to_site_use_id merge

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'OE_HEADER_ACKS', FALSE );

  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       insert into  HZ_CUSTOMER_MERGE_LOG (
		MERGE_LOG_ID,
		TABLE_NAME,
		MERGE_HEADER_ID,
		PRIMARY_KEY1,
		NUM_COL5_ORIG,
		NUM_COL5_NEW,
		ACTION_FLAG,
		REQUEST_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY
		)
		select
		HZ_CUSTOMER_MERGE_LOG_s.nextval,
		'OE_HEADER_ACKS',
		m.CUSTOMER_MERGE_HEADER_ID,
		h.ORIG_SYS_DOCUMENT_REF,
		h.sold_to_site_use_id,
		m.customer_site_id,
		'U',
		req_id,
		hz_utility_pub.CREATED_BY,
		hz_utility_pub.CREATION_DATE,
		hz_utility_pub.LAST_UPDATE_LOGIN,
		hz_utility_pub.LAST_UPDATE_DATE,
		hz_utility_pub.LAST_UPDATED_BY
	        from oe_header_acks h,
		     ra_customer_merges m
               where
 h.sold_to_site_use_id=m.duplicate_site_id
                and
 m.process_flag = 'N'
                 and m.request_id = req_id
                 and m.set_number = set_num
		 and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
  end if;

   UPDATE OE_HEADER_ACKS  a
    set    sold_to_site_use_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.sold_to_site_use_id = m.duplicate_id
                                and    m.process_flag = 'N'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where  sold_to_site_use_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'N'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );


    -- end_customer_site_use_id merge

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'OE_HEADER_ACKS', FALSE );

  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       insert into  HZ_CUSTOMER_MERGE_LOG (
		MERGE_LOG_ID,
		TABLE_NAME,
		MERGE_HEADER_ID,
		PRIMARY_KEY1,
		NUM_COL6_ORIG,
		NUM_COL6_NEW,
		ACTION_FLAG,
		REQUEST_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY
		)
		select
		HZ_CUSTOMER_MERGE_LOG_s.nextval,
		'OE_HEADER_ACKS',
		m.CUSTOMER_MERGE_HEADER_ID,
		h.ORIG_SYS_DOCUMENT_REF,
		h.end_customer_site_use_id,
		m.customer_site_id,
		'U',
		req_id,
		hz_utility_pub.CREATED_BY,
		hz_utility_pub.CREATION_DATE,
		hz_utility_pub.LAST_UPDATE_LOGIN,
		hz_utility_pub.LAST_UPDATE_DATE,
		hz_utility_pub.LAST_UPDATED_BY
	        from oe_header_acks h,
		     ra_customer_merges m
               where
 h.end_customer_site_use_id=m.duplicate_site_id
                and
 m.process_flag = 'N'
                 and m.request_id = req_id
                 and m.set_number = set_num
		 and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
  end if;

    UPDATE OE_HEADER_ACKS  a
    set    end_customer_site_use_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.end_customer_site_use_id = m.duplicate_id
                                and    m.process_flag = 'N'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where
end_customer_site_use_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'N'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num)
      and
 NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

/* customer level update */
    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'OE_HEADER_ACKS', FALSE );

  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       insert into  HZ_CUSTOMER_MERGE_LOG (
		MERGE_LOG_ID,
		TABLE_NAME,
		MERGE_HEADER_ID,
		PRIMARY_KEY1,
		NUM_COL7_ORIG,
		NUM_COL7_NEW,
		ACTION_FLAG,
		REQUEST_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY
		)
		select
		HZ_CUSTOMER_MERGE_LOG_s.nextval,
		'OE_HEADER_ACKS',
		m.CUSTOMER_MERGE_HEADER_ID,
		h.ORIG_SYS_DOCUMENT_REF,
		h.end_customer_id,
		m.customer_site_id,
		'U',
		req_id,
		hz_utility_pub.CREATED_BY,
		hz_utility_pub.CREATION_DATE,
		hz_utility_pub.LAST_UPDATE_LOGIN,
		hz_utility_pub.LAST_UPDATE_DATE,
		hz_utility_pub.LAST_UPDATED_BY
	        from oe_header_acks h,
		     ra_customer_merges m
               where
h.end_customer_id=m.duplicate_site_id
               and
 m.process_flag = 'N'
                 and m.request_id = req_id
                 and m.set_number = set_num
		 and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
  end if;

    UPDATE OE_HEADER_ACKS  a
    set    end_customer_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.end_customer_id = m.duplicate_id
                                and    m.process_flag = 'N'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where  end_customer_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'N'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
--changed for bug 3196900
      and a.header_id in (select header_id from oe_order_headers);

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

    arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Header_ACKS()-' );

    EXCEPTION
    When others then
      arp_message.set_error( 'OE_CUST_MERGE.OE_Merge_Header_ACKS-' );
      raise;

 END OE_Merge_Header_ACKS;

/*------------------------------------------------*/
/*--- PRIVATE PROCEDURE OE_Merge_Lines         ---*/
/*------------------------------------------------*/

 Procedure OE_Merge_Lines (Req_Id          IN NUMBER,
                             Set_Num         IN NUMBER,
                             Process_Mode    IN VARCHAR2)
 IS

 CURSOR MERGE_SITES IS
    select duplicate_id, customer_id, duplicate_site_id, customer_site_id
      from ra_customer_merges m
      where m.process_flag = 'N'
      and m.request_id = req_id
     and m.set_number = set_num;

/* Commented for bug 6449945
 --bug6071855
 CURSOR MERGE_LINES IS
 SELECT / *+ LEADING (M) PARALLEL (L) PARALLEL (M) * /
  l.line_id ,
  l.header_id,
  l.last_update_date,
  l.line_id,
  'Y',
  sold_to_org_id,
  invoice_to_org_id,
  ship_to_org_id,
  intmed_ship_to_org_id,
  deliver_to_org_id,
  end_customer_site_use_id,
  end_customer_id,
  m.customer_merge_id
 FROM RA_CUSTOMER_MERGES M,
-- change for bug 3196900
--    OE_ORDER_LINES_ALL L
      OE_ORDER_LINES L
 WHERE
     (l.sold_to_org_id = m.duplicate_id
             or l.invoice_to_org_id = m.duplicate_site_id
             or l.ship_to_org_id = m.duplicate_site_id
             or l.intmed_ship_to_org_id = m.duplicate_site_id
             or l.end_customer_site_use_id = m.duplicate_site_id
             or l.end_customer_id = m.duplicate_id
             or l.deliver_to_org_id = m.duplicate_site_id)
             and m.process_flag = 'N'
             and m.request_id = req_id
             and m.set_number = set_num
 for update nowait;
*/

CURSOR MERGE_LINES IS
SELECT /*+ PARALLEL (L) PARALLEL (M1) PARALLEL(M2)
           PARALLEL (M3) PARALLEL (M4) PARALLEL (M5)
           PARALLEL (M6) PARALLEL (M7) */
       L.LINE_ID , L.HEADER_ID, L.LAST_UPDATE_DATE, L.LINE_ID, 'Y',
       SOLD_TO_ORG_ID, INVOICE_TO_ORG_ID, SHIP_TO_ORG_ID,
       INTMED_SHIP_TO_ORG_ID, DELIVER_TO_ORG_ID,
       END_CUSTOMER_SITE_USE_ID, END_CUSTOMER_ID,
       NVL(M1.CUSTOMER_MERGE_ID,NVL(M2.CUSTOMER_MERGE_ID,NVL(M3.CUSTOMER_MERGE_ID,
          NVL(M4.CUSTOMER_MERGE_ID,NVL(M5.CUSTOMER_MERGE_ID,
          NVL(M6.CUSTOMER_MERGE_ID,M7.CUSTOMER_MERGE_ID))))))
  FROM RA_CUSTOMER_MERGES M1,
       RA_CUSTOMER_MERGES M2,
       RA_CUSTOMER_MERGES M3,
       RA_CUSTOMER_MERGES M4,
       RA_CUSTOMER_MERGES M5,
       RA_CUSTOMER_MERGES M6,
       RA_CUSTOMER_MERGES M7,
       OE_ORDER_LINES L
 WHERE ( L.SOLD_TO_ORG_ID = M1.DUPLICATE_ID(+)
   AND L.INVOICE_TO_ORG_ID = M2.DUPLICATE_SITE_ID(+)
   AND L.SHIP_TO_ORG_ID = M3.DUPLICATE_SITE_ID(+)
   AND L.INTMED_SHIP_TO_ORG_ID = M4.DUPLICATE_SITE_ID(+)
   AND L.END_CUSTOMER_SITE_USE_ID = M5.DUPLICATE_SITE_ID(+)
   AND L.END_CUSTOMER_ID = M6.DUPLICATE_SITE_ID(+)
   AND L.DELIVER_TO_ORG_ID = M7.DUPLICATE_ID(+) )
   AND (M1.DUPLICATE_SITE_ID IS NOT NULL
    OR M2.DUPLICATE_ID IS NOT NULL
    OR M3.DUPLICATE_ID IS NOT NULL
    OR M4.DUPLICATE_ID IS NOT NULL
    OR M5.DUPLICATE_ID IS NOT NULL
    OR M6.DUPLICATE_ID IS NOT NULL
    OR M7.DUPLICATE_SITE_ID IS NOT NULL)
   AND M1.PROCESS_FLAG(+) = 'N'
   AND M2.PROCESS_FLAG(+) = 'N'
   AND M3.PROCESS_FLAG(+) = 'N'
   AND M4.PROCESS_FLAG(+) = 'N'
   AND M5.PROCESS_FLAG(+) = 'N'
   AND M6.PROCESS_FLAG(+) = 'N'
   AND M7.PROCESS_FLAG(+) = 'N'
   AND M1.REQUEST_ID(+) = req_id
   AND M2.REQUEST_ID(+) = req_id
   AND M3.REQUEST_ID(+) = req_id
   AND M4.REQUEST_ID(+) = req_id
   AND M5.REQUEST_ID(+) = req_id
   AND M6.REQUEST_ID(+) = req_id
   AND M7.REQUEST_ID(+) = req_id
   AND M1.SET_NUMBER(+) = set_num
   AND M2.SET_NUMBER(+) = set_num
   AND M3.SET_NUMBER(+) = set_num
   AND M4.SET_NUMBER(+) = set_num
   AND M5.SET_NUMBER(+) = set_num
   AND M6.SET_NUMBER(+) = set_num
   AND M7.SET_NUMBER(+) = set_num
   FOR UPDATE NOWAIT;

/* Commented for bug 6449945
 --bug6071855
 CURSOR MERGE_LINES_2 IS
 SELECT / *+ LEADING (M) PARALLEL (L) PARALLEL (M) * /
  l.line_id ,
  l.header_id,
  l.last_update_date,
  l.line_id,
  'Y',
  sold_to_org_id,
  invoice_to_org_id,
  ship_to_org_id,
  intmed_ship_to_org_id,
  deliver_to_org_id,
  end_customer_site_use_id,
  end_customer_id,
  m.customer_merge_id
 FROM RA_CUSTOMER_MERGES M,
-- changed for bug 3196900
--      OE_ORDER_LINES_ALL L
      OE_ORDER_LINES L
 WHERE
                (l.sold_to_org_id = m.duplicate_id
             or l.invoice_to_org_id = m.duplicate_site_id
             or l.ship_to_org_id = m.duplicate_site_id
             or l.intmed_ship_to_org_id = m.duplicate_site_id
             or l.end_customer_site_use_id = m.duplicate_site_id
             or l.end_customer_id = m.duplicate_id
             or l.deliver_to_org_id = m.duplicate_site_id)
             and m.process_flag = 'N'
             and m.request_id = req_id
             and m.set_number = set_num;
*/

 CURSOR MERGE_LINES_2 IS
 SELECT /*+ PARALLEL (L) PARALLEL (M1) PARALLEL(M2)
           PARALLEL (M3) PARALLEL (M4) PARALLEL (M5)
           PARALLEL (M6) PARALLEL (M7) */
       L.LINE_ID , L.HEADER_ID, L.LAST_UPDATE_DATE, L.LINE_ID, 'Y',
       SOLD_TO_ORG_ID, INVOICE_TO_ORG_ID, SHIP_TO_ORG_ID,
       INTMED_SHIP_TO_ORG_ID, DELIVER_TO_ORG_ID,
       END_CUSTOMER_SITE_USE_ID, END_CUSTOMER_ID,'N',
       NVL(M1.CUSTOMER_MERGE_ID,NVL(M2.CUSTOMER_MERGE_ID,NVL(M3.CUSTOMER_MERGE_ID,
          NVL(M4.CUSTOMER_MERGE_ID,NVL(M5.CUSTOMER_MERGE_ID,
          NVL(M6.CUSTOMER_MERGE_ID,M7.CUSTOMER_MERGE_ID))))))
  FROM RA_CUSTOMER_MERGES M1,
       RA_CUSTOMER_MERGES M2,
       RA_CUSTOMER_MERGES M3,
       RA_CUSTOMER_MERGES M4,
       RA_CUSTOMER_MERGES M5,
       RA_CUSTOMER_MERGES M6,
       RA_CUSTOMER_MERGES M7,
       OE_ORDER_LINES L
 WHERE ( L.SOLD_TO_ORG_ID = M1.DUPLICATE_ID(+)
   AND L.INVOICE_TO_ORG_ID = M2.DUPLICATE_SITE_ID(+)
   AND L.SHIP_TO_ORG_ID = M3.DUPLICATE_SITE_ID(+)
   AND L.INTMED_SHIP_TO_ORG_ID = M4.DUPLICATE_SITE_ID(+)
   AND L.END_CUSTOMER_SITE_USE_ID = M5.DUPLICATE_SITE_ID(+)
   AND L.END_CUSTOMER_ID = M6.DUPLICATE_SITE_ID(+)
   AND L.DELIVER_TO_ORG_ID = M7.DUPLICATE_ID(+) )
   AND (M1.DUPLICATE_SITE_ID IS NOT NULL
    OR M2.DUPLICATE_ID IS NOT NULL
    OR M3.DUPLICATE_ID IS NOT NULL
    OR M4.DUPLICATE_ID IS NOT NULL
    OR M5.DUPLICATE_ID IS NOT NULL
    OR M6.DUPLICATE_ID IS NOT NULL
    OR M7.DUPLICATE_SITE_ID IS NOT NULL)
   AND M1.PROCESS_FLAG(+) = 'N'
   AND M2.PROCESS_FLAG(+) = 'N'
   AND M3.PROCESS_FLAG(+) = 'N'
   AND M4.PROCESS_FLAG(+) = 'N'
   AND M5.PROCESS_FLAG(+) = 'N'
   AND M6.PROCESS_FLAG(+) = 'N'
   AND M7.PROCESS_FLAG(+) = 'N'
   AND M1.REQUEST_ID(+) = req_id
   AND M2.REQUEST_ID(+) = req_id
   AND M3.REQUEST_ID(+) = req_id
   AND M4.REQUEST_ID(+) = req_id
   AND M5.REQUEST_ID(+) = req_id
   AND M6.REQUEST_ID(+) = req_id
   AND M7.REQUEST_ID(+) = req_id
   AND M1.SET_NUMBER(+) = set_num
   AND M2.SET_NUMBER(+) = set_num
   AND M3.SET_NUMBER(+) = set_num
   AND M4.SET_NUMBER(+) = set_num
   AND M5.SET_NUMBER(+) = set_num
   AND M6.SET_NUMBER(+) = set_num
   AND M7.SET_NUMBER(+) = set_num;

    CURSOR MERGE_LINES_2_NP IS
	SELECT
	   L.LINE_ID , L.HEADER_ID, L.LAST_UPDATE_DATE, L.LINE_ID,
	  'Y', SOLD_TO_ORG_ID, INVOICE_TO_ORG_ID,  SHIP_TO_ORG_ID, INTMED_SHIP_TO_ORG_ID,
	  DELIVER_TO_ORG_ID,  END_CUSTOMER_SITE_USE_ID,  END_CUSTOMER_ID,'N', M1.CUSTOMER_MERGE_ID
	FROM
	OE_CUST_MERGES_GTT M1, OE_ORDER_LINES L
	WHERE L.SOLD_TO_ORG_ID = M1.DUPLICATE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	UNION ALL
	SELECT
	   L.LINE_ID , L.HEADER_ID, L.LAST_UPDATE_DATE, L.LINE_ID,
	  'Y', SOLD_TO_ORG_ID, INVOICE_TO_ORG_ID,  SHIP_TO_ORG_ID, INTMED_SHIP_TO_ORG_ID,
	  DELIVER_TO_ORG_ID,  END_CUSTOMER_SITE_USE_ID,  END_CUSTOMER_ID, 'N',M1.CUSTOMER_MERGE_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_ORDER_LINES L
	WHERE L.INVOICE_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	UNION ALL
	SELECT
	   L.LINE_ID , L.HEADER_ID, L.LAST_UPDATE_DATE, L.LINE_ID,
	  'Y', SOLD_TO_ORG_ID, INVOICE_TO_ORG_ID,  SHIP_TO_ORG_ID, INTMED_SHIP_TO_ORG_ID,
	  DELIVER_TO_ORG_ID,  END_CUSTOMER_SITE_USE_ID,  END_CUSTOMER_ID, 'N',M1.CUSTOMER_MERGE_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_ORDER_LINES L
	WHERE L.SHIP_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	UNION ALL
	SELECT
	   L.LINE_ID , L.HEADER_ID, L.LAST_UPDATE_DATE, L.LINE_ID,
	  'Y', SOLD_TO_ORG_ID, INVOICE_TO_ORG_ID,  SHIP_TO_ORG_ID, INTMED_SHIP_TO_ORG_ID,
	  DELIVER_TO_ORG_ID,  END_CUSTOMER_SITE_USE_ID,  END_CUSTOMER_ID,'N', M1.CUSTOMER_MERGE_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_ORDER_LINES L
	WHERE L.INTMED_SHIP_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	UNION ALL
	SELECT
	   L.LINE_ID , L.HEADER_ID, L.LAST_UPDATE_DATE, L.LINE_ID,
	  'Y', SOLD_TO_ORG_ID, INVOICE_TO_ORG_ID,  SHIP_TO_ORG_ID, INTMED_SHIP_TO_ORG_ID,
	  DELIVER_TO_ORG_ID,  END_CUSTOMER_SITE_USE_ID,  END_CUSTOMER_ID, 'N',M1.CUSTOMER_MERGE_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_ORDER_LINES L
	WHERE L.DELIVER_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	UNION ALL
	SELECT
	   L.LINE_ID , L.HEADER_ID, L.LAST_UPDATE_DATE, L.LINE_ID,
	  'Y', SOLD_TO_ORG_ID, INVOICE_TO_ORG_ID,  SHIP_TO_ORG_ID, INTMED_SHIP_TO_ORG_ID,
	  DELIVER_TO_ORG_ID,  END_CUSTOMER_SITE_USE_ID,  END_CUSTOMER_ID, 'N',M1.CUSTOMER_MERGE_ID
	FROM
	RA_CUSTOMER_MERGES M1,  OE_ORDER_LINES L
	WHERE L.END_CUSTOMER_SITE_USE_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	UNION ALL
	SELECT
	   L.LINE_ID , L.HEADER_ID, L.LAST_UPDATE_DATE, L.LINE_ID,
	  'Y', SOLD_TO_ORG_ID, INVOICE_TO_ORG_ID,  SHIP_TO_ORG_ID, INTMED_SHIP_TO_ORG_ID,
	  DELIVER_TO_ORG_ID,  END_CUSTOMER_SITE_USE_ID,  END_CUSTOMER_ID, 'N',M1.CUSTOMER_MERGE_ID
	FROM
	OE_CUST_MERGES_GTT  M1, OE_ORDER_LINES L
	WHERE L.END_CUSTOMER_ID= M1.DUPLICATE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num;


  line_line_id_tab	             num_table;
  line_sold_to_org_id_tab            num_table;
  line_invoice_to_org_id_tab         num_table;
  line_ship_to_org_id_tab            num_table;
  line_intmed_ship_to_org_id_tab     num_table;
  line_deliver_to_org_id_tab         num_table;
  line_end_cust_site_use_id         num_table;
  line_end_cust_id_tab              num_table;

  old_line_sold_to_org_id_tab           num_table;
  old_line_invoice_to_org_id_tab        num_table;
  old_line_ship_to_org_id_tab           num_table;
  old_intmed_ship_to_org_id_tab         num_table;
  old_line_deliver_to_org_id_tab        num_table;
  old_line_end_cust_site_use_id         num_table;
  old_line_end_cust_id_tab              num_table;
     --Added for Duplicate Check  bug 8883694,9349882 ,9558975
        line_duplicate_flag_tab var_bin_table;
  l_line_id_tab           num_binary_int;

  MERGE_HEADER_ID_LIST MERGE_ID_LIST_TYPE;
  l_profile_val VARCHAR2(30);

  TYPE num_table_binary_int IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   customer_id_tab        num_table_binary_int;
   customer_site_id_tab   num_table_binary_int;

  dbi_local_line_header_id_tab num_bin_table :=num_bin_table();
  dbi_local_line_update_date_tab date_bin_table :=date_bin_table();
  dbi_local_line_line_id_tab num_bin_table :=num_bin_table();
  dbi_local_line_status_tab var_bin_table :=var_bin_table();
  l_global_count number :=0;

 BEGIN

 arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Lines()+' );

 IF (process_mode = 'LOCK') THEN

   arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
   arp_message.set_token( 'TABLE_NAME', 'oe_order_lines_all', FALSE );

   open  merge_lines;
   close merge_lines;

 ELSE

 FOR C IN MERGE_SITES LOOP
         IF c.duplicate_id IS NOT NULL
            AND NOT customer_id_tab.EXISTS(MOD(c.duplicate_id,G_BINARY_LIMIT)) THEN --bug8477340
            customer_id_tab(MOD(c.duplicate_id,G_BINARY_LIMIT)) := c.customer_id;
         END IF;

         IF c.duplicate_site_id IS NOT NULL
            AND NOT customer_site_id_tab.EXISTS(MOD(c.duplicate_site_id,G_BINARY_LIMIT)) THEN
            customer_site_id_tab(MOD(c.duplicate_site_id,G_BINARY_LIMIT)) := c.customer_site_id;--bug8477340
         END IF;

  END LOOP;


  HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
  l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

  arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Lines():1' );
  -- Bug 7379750
   IF l_run_parallel_query = 'Y' THEN
      OPEN merge_lines_2;
   ELSE
      OPEN merge_lines_2_NP;
   END IF;

   LOOP
  -- Bug 7379750
   IF l_run_parallel_query = 'Y' THEN
     FETCH merge_lines_2
      BULK COLLECT INTO line_line_id_tab,
                        dbi_local_line_header_id_tab,
                        dbi_local_line_update_date_tab,
                        dbi_local_line_line_id_tab,
                        dbi_local_line_status_tab,
                        line_sold_to_org_id_tab,
                        line_invoice_to_org_id_tab,
                        line_ship_to_org_id_tab,
                        line_intmed_ship_to_org_id_tab,
                        line_deliver_to_org_id_tab,
	                line_end_cust_site_use_id,
	                line_end_cust_id_tab,
	                line_duplicate_flag_tab, --Added for Duplicate Check bug 8883694,9349882 ,9558975
			MERGE_HEADER_ID_LIST
                        LIMIT 20000;
    ELSE
     FETCH merge_lines_2_NP
      BULK COLLECT INTO line_line_id_tab,
                        dbi_local_line_header_id_tab,
                        dbi_local_line_update_date_tab,
                        dbi_local_line_line_id_tab,
                        dbi_local_line_status_tab,
                        line_sold_to_org_id_tab,
                        line_invoice_to_org_id_tab,
                        line_ship_to_org_id_tab,
                        line_intmed_ship_to_org_id_tab,
                        line_deliver_to_org_id_tab,
	                line_end_cust_site_use_id,
	                line_end_cust_id_tab,
	                line_duplicate_flag_tab, --Added for Duplicate Check bug 8883694,9349882 ,9558975
			MERGE_HEADER_ID_LIST
                        LIMIT 20000;
    END IF;


     arp_message.set_line('local line_hdr_id_count='||dbi_local_line_header_id_tab.COUNT);
     arp_message.set_line('local line_line__id_count='||dbi_local_line_line_id_tab.COUNT);
     arp_message.set_line('local line_date_count='||dbi_local_line_update_date_tab.COUNT);
     arp_message.set_line('local line_status_count='||dbi_local_line_status_tab.COUNT);
     IF  l_dbi_profile = 'Y' then
     IF dbi_local_line_update_date_tab.COUNT > 0 then


       IF dbi_line_update_date_tab.COUNT > 0 then
        l_global_count := dbi_line_update_date_tab.COUNT;
       ELSE
        l_global_count := 0;
       END IF;

       dbi_line_update_date_tab.EXTEND(dbi_local_line_update_date_tab.COUNT);
       dbi_line_header_id_tab.EXTEND(dbi_local_line_update_date_tab.COUNT);
       dbi_line_line_id_tab.EXTEND(dbi_local_line_update_date_tab.COUNT);
       dbi_line_status_tab.EXTEND(dbi_local_line_update_date_tab.COUNT);

     END IF;
     END IF;
     old_intmed_ship_to_org_id_tab      := line_intmed_ship_to_org_id_tab;
     old_line_sold_to_org_id_tab        := line_sold_to_org_id_tab;
     old_line_invoice_to_org_id_tab     := line_invoice_to_org_id_tab;
     old_line_ship_to_org_id_tab        := line_ship_to_org_id_tab;
     old_line_deliver_to_org_id_tab     := line_deliver_to_org_id_tab;
     old_line_end_cust_site_use_id      := line_end_cust_site_use_id;
     old_line_end_cust_id_tab           := line_end_cust_id_tab;

    if line_line_id_tab.COUNT <> 0 then
    for i in  line_line_id_tab.FIRST..line_line_id_tab.LAST LOOP

      IF  l_dbi_profile = 'Y' then
        dbi_line_update_date_tab(l_global_count + i):=dbi_local_line_update_date_tab(i);
        dbi_line_header_id_tab(l_global_count + i):=dbi_local_line_header_id_tab(i);
        dbi_line_line_id_tab(l_global_count + i):=dbi_local_line_line_id_tab(i);
        dbi_line_status_tab(l_global_count + i):=dbi_local_line_status_tab(i);
      END IF;

		  -- Access directly by the index position of the ids in the
	          -- values stored in customer_id_tab and customer_site_id_tab tables

	          if customer_id_tab.exists(MOD(line_sold_to_org_id_tab(i),G_BINARY_LIMIT)) then
	             line_sold_to_org_id_tab(i):= customer_id_tab(MOD(line_sold_to_org_id_tab(i),G_BINARY_LIMIT)); --bug8477340
	          end if;

	          if customer_site_id_tab.exists(MOD(line_invoice_to_org_id_tab(i),G_BINARY_LIMIT)) then
	 	        line_invoice_to_org_id_tab(i):= customer_site_id_tab(MOD(line_invoice_to_org_id_tab(i),G_BINARY_LIMIT)); --bug8477340
	          end if;

	          if customer_site_id_tab.exists(MOD(line_ship_to_org_id_tab(i),G_BINARY_LIMIT)) then
	 	       line_ship_to_org_id_tab(i):= customer_site_id_tab(MOD(line_ship_to_org_id_tab(i),G_BINARY_LIMIT)); --bug8477340
	          end if;

	          if customer_site_id_tab.exists(MOD(line_intmed_ship_to_org_id_tab(i),G_BINARY_LIMIT)) then
			  	line_intmed_ship_to_org_id_tab(i):= customer_site_id_tab(MOD(line_intmed_ship_to_org_id_tab(i),G_BINARY_LIMIT)); --bug8477340
	          end if;

	          if customer_site_id_tab.exists(MOD(line_deliver_to_org_id_tab(i),G_BINARY_LIMIT)) then
	 	        line_deliver_to_org_id_tab(i):= customer_site_id_tab(MOD(line_deliver_to_org_id_tab(i),G_BINARY_LIMIT)); --bug8477340
	          end if;

		  if customer_site_id_tab.exists(MOD(line_end_cust_site_use_id(i),G_BINARY_LIMIT)) then
	 	        line_end_cust_site_use_id(i):= customer_site_id_tab(MOD(line_end_cust_site_use_id(i),G_BINARY_LIMIT)); --bug8477340
	          end if;

		  if customer_id_tab.exists(MOD(line_end_cust_id_tab(i),G_BINARY_LIMIT)) then
	             line_end_cust_id_tab(i):= customer_id_tab(MOD(line_end_cust_id_tab(i),G_BINARY_LIMIT)); --bug8477340
	          end if;

                  --Added for Duplicate Check 8883694 ,9558975
				-- Code for marking the Duplicate line_id's
			        	IF l_line_id_tab.EXISTS(MOD(line_line_id_tab(i),G_BINARY_LIMIT)) THEN
			 			line_duplicate_flag_tab(i) := 'Y';
					ELSE
			  			l_line_id_tab(MOD(line_line_id_tab(i),G_BINARY_LIMIT)):=1;
	           	END IF;

     end loop;
     end if;

     IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	IF line_line_id_tab.COUNT <> 0 THEN
	   forall i in  line_line_id_tab.FIRST..line_line_id_tab.LAST
	   --insert audit information for customer merge
	                   INSERT INTO HZ_CUSTOMER_MERGE_LOG (
				MERGE_LOG_ID,
				TABLE_NAME,
				MERGE_HEADER_ID,
				PRIMARY_KEY_ID1,
				NUM_COL1_ORIG,
				NUM_COL1_NEW,
				NUM_COL2_ORIG,
				NUM_COL2_NEW,
				NUM_COL3_ORIG,
				NUM_COL3_NEW,
				NUM_COL4_ORIG,
				NUM_COL4_NEW,
				NUM_COL5_ORIG,
				NUM_COL5_NEW,
				NUM_COL6_ORIG,
				NUM_COL6_NEW,
				ACTION_FLAG,
				REQUEST_ID,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATE_LOGIN,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY
				) VALUES (
				HZ_CUSTOMER_MERGE_LOG_s.nextval,
				'OE_ORDER_LINES_ALL',
				MERGE_HEADER_ID_LIST(I),
				line_line_id_tab(I),
				line_sold_to_org_id_tab(I),
				decode(line_sold_to_org_id_tab(I),NULL,old_line_sold_to_org_id_tab(I),line_sold_to_org_id_tab(i)),
				line_invoice_to_org_id_tab(I),
				decode(line_invoice_to_org_id_tab(I),NULL,old_line_invoice_to_org_id_tab(I),line_invoice_to_org_id_tab(i)),
				line_ship_to_org_id_tab(I),
				decode(line_ship_to_org_id_tab(I),NULL,old_line_ship_to_org_id_tab(I),line_ship_to_org_id_tab(i)),
				line_deliver_to_org_id_tab(I),
				decode(line_deliver_to_org_id_tab(I),NULL,old_line_deliver_to_org_id_tab(I),line_deliver_to_org_id_tab(i)),
				line_end_cust_site_use_id(I),
				decode(line_end_cust_site_use_id(I),NULL,old_line_end_cust_site_use_id(I),line_end_cust_site_use_id(i)),
				line_end_cust_id_tab(I),
				decode(line_end_cust_id_tab(I),NULL,old_line_end_cust_id_tab(I),line_end_cust_id_tab(i)),
				'U',
				req_id,
				hz_utility_pub.CREATED_BY,
				hz_utility_pub.CREATION_DATE,
				hz_utility_pub.LAST_UPDATE_LOGIN,
				hz_utility_pub.LAST_UPDATE_DATE,
				hz_utility_pub.LAST_UPDATED_BY
				);

			  end if;
		       end if;

     arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
     arp_message.set_token( 'TABLE_NAME', 'oe_order_lines_all', FALSE );
    IF line_line_id_tab.COUNT <> 0 THEN
      FORALL i in line_line_id_tab.FIRST..line_line_id_tab.LAST
        UPDATE OE_ORDER_LINES_ALL L
        SET  sold_to_org_id    	  = decode(line_sold_to_org_id_tab(i),null,sold_to_org_id,line_sold_to_org_id_tab(i)),
            invoice_to_org_id 	  = decode(line_invoice_to_org_id_tab(i),null,invoice_to_org_id,line_invoice_to_org_id_tab(i)),
            ship_to_org_id    	  = decode(line_ship_to_org_id_tab(i),null,ship_to_org_id,line_ship_to_org_id_tab(i)),
            intmed_ship_to_org_id  = decode(line_intmed_ship_to_org_id_tab(i),null,intmed_ship_to_org_id,line_intmed_ship_to_org_id_tab(i)),
            deliver_to_org_id 	  = decode(line_deliver_to_org_id_tab(i),null,deliver_to_org_id,line_deliver_to_org_id_tab(i)),
            end_customer_site_use_id 	  = decode(line_end_cust_site_use_id(i),null,end_customer_site_use_id,line_end_cust_site_use_id(i)),
            end_customer_id 	  = decode(line_end_cust_id_tab(i),null,end_customer_id,line_end_cust_id_tab(i)),
 	    last_update_date 	  = sysdate,
 	    last_updated_by 	  = arp_standard.profile.user_id,
 	    last_update_login      = arp_standard.profile.last_update_login,
 	    request_id             = req_id,
            program_application_id = arp_standard.profile.program_application_id ,
            program_id             = arp_standard.profile.program_id,
            program_update_date    = SYSDATE,
            lock_control           = lock_control+1
        WHERE line_id = line_line_id_tab(i)
        AND line_duplicate_flag_tab(i) = 'N'; --Added for Duplicate Check
      ---duplicate bug 8883694,9349882 ,9558975  RETURNING last_update_date bulk collect into dbi_line_update_date_tab;

        g_count := sql%rowcount;

     ELSE
       g_count := 0;
     END IF;
     arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
     arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  -- Bug 7379750
     IF l_run_parallel_query = 'Y' THEN
	EXIT WHEN merge_lines_2%NOTFOUND;
     ELSE
	EXIT WHEN merge_lines_2_NP%NOTFOUND;
     END IF;
     line_line_id_tab.DELETE;
     line_sold_to_org_id_tab.DELETE;
     line_invoice_to_org_id_tab.DELETE;
     line_ship_to_org_id_tab.DELETE;
     line_intmed_ship_to_org_id_tab.DELETE;
     line_deliver_to_org_id_tab.DELETE;
     line_end_cust_site_use_id.DELETE;
     line_end_cust_id_tab.DELETE;
      line_duplicate_flag_tab.DELETE;  --Added for Duplicate Check

     old_line_sold_to_org_id_tab.DELETE;
     old_line_invoice_to_org_id_tab.DELETE;
     old_line_ship_to_org_id_tab.DELETE;
     old_intmed_ship_to_org_id_tab.DELETE;
     old_line_deliver_to_org_id_tab.DELETE;
     old_line_end_cust_site_use_id.DELETE;
     old_line_end_cust_id_tab.DELETE;

   END LOOP;  -- cursor merge_lines_2
  -- Bug 7379750
   IF l_run_parallel_query = 'Y' THEN
	CLOSE merge_lines_2;
   ELSE
        CLOSE merge_lines_2_NP;
   END IF;
 END IF;
    customer_id_tab.DELETE;
    customer_site_id_tab.DELETE;
    dbi_local_line_header_id_tab.DELETE;
    dbi_local_line_update_date_tab.DELETE;
    dbi_local_line_line_id_tab.DELETE;
    dbi_local_line_status_tab.DELETE;

    arp_message.set_line(' line_hdr_id_count='||dbi_line_header_id_tab.COUNT);
    arp_message.set_line(' line_line__id_count='||dbi_line_line_id_tab.COUNT);
    arp_message.set_line(' line_date_count='||dbi_line_update_date_tab.COUNT);
    arp_message.set_line(' line_status_count='||dbi_line_status_tab.COUNT);
    arp_message.set_line( ' END OE_CUST_MERGE.OE_Merge_Lines()-' );

 EXCEPTION
 when others then
 	arp_message.set_error( 'OE_CUST_MERGE.OE_Merge_Lines-' );
    raise;

 END OE_Merge_Lines;

/*-------------------------------------------------*/
/*--- PRIVATE PROCEDURE OE_Merge_Lines_History  ---*/
/*-------------------------------------------------*/

 Procedure OE_Merge_Lines_History (Req_Id          IN NUMBER,
                                   Set_Num         IN NUMBER,
                                   Process_Mode    IN VARCHAR2)
 IS

 CURSOR MERGE_SITES IS
     select duplicate_id, customer_id, duplicate_site_id, customer_site_id
       from ra_customer_merges m
       where m.process_flag = 'N'
       and m.request_id = req_id
     and m.set_number = set_num;
 /* MOAC_SQL_CHANGE */
 --bug6071855
 CURSOR MERGE_LINES_HISTORY IS
 SELECT /*+ ordered PARALLEL(L) PARALLEL (LN)
           PARALLEL(M1) PARALLEL(M2) PARALLEL(M3) PARALLEL(M4)
           PARALLEL (M5) PARALLEL(M6) PARALLEL(M7)
           PARALLEL (LN) */
  l.line_id ,
-- changed for bug 3196900 added l. for every attribute
  l.sold_to_org_id,
  l.invoice_to_org_id,
  l.ship_to_org_id,
  l.intmed_ship_to_org_id,
  l.deliver_to_org_id,
  l.end_customer_site_use_id,
  l.end_customer_id
 FROM OE_ORDER_LINES_HISTORY L,
      RA_CUSTOMER_MERGES M1,
      RA_CUSTOMER_MERGES M2,
      RA_CUSTOMER_MERGES M3,
      RA_CUSTOMER_MERGES M4,
      RA_CUSTOMER_MERGES M5,
      RA_CUSTOMER_MERGES M6,
      RA_CUSTOMER_MERGES M7,
-- changed for bug 3196900
--      OE_ORDER_LINES_HISTORY L
       OE_ORDER_LINES_ALL LN
    -- Changed for MOAC
 WHERE
     ( l.sold_to_org_id        = m1.duplicate_id(+)
   and l.invoice_to_org_id     = m2.duplicate_site_id(+)
   and l.ship_to_org_id        = m3.duplicate_site_id(+)
   and l.intmed_ship_to_org_id = m4.duplicate_site_id(+)
   and l.deliver_to_org_id     = m5.duplicate_site_id(+)
   and l.end_customer_site_use_id   = m6.duplicate_site_id(+)
   and l.end_customer_id       = m7.duplicate_id(+) )
   and
   (m1.duplicate_site_id is not null or
    m2.duplicate_id is not null or
    m3.duplicate_id is not null or
    m4.duplicate_id is not null or
    m5.duplicate_id is not null  or
    m6.duplicate_id is not null or
    m7.duplicate_site_id is not null)
   and m1.process_flag(+) = 'N'
   and m2.process_flag(+) = 'N'
   and m3.process_flag(+) = 'N'
   and m4.process_flag(+) = 'N'
   and m5.process_flag(+) = 'N'
   and m6.process_flag(+) = 'N'
   and m7.process_flag(+) = 'N'
   and m1.request_id(+) =req_id
   and m2.request_id(+) =req_id
   and m3.request_id(+) =req_id
   and m4.request_id(+) =req_id
   and m5.request_id(+) =req_id
   and m6.request_id(+) =req_id
   and m7.request_id(+) =req_id
   and m1.set_number(+) =set_num
   and m2.set_number(+) =set_num
   and m3.set_number(+) =set_num
   and m4.set_number(+) =set_num
   and m5.set_number(+) =set_num
   and m6.set_number(+) =set_num
   and m7.set_number(+) =set_num
-- added for bug 3196900
   and l.line_id=ln.line_id
 for update nowait;

 /* MOAC_SQL_CHANGE */
 --bug6071855
 CURSOR MERGE_LINES_HISTORY_2 IS
 SELECT /*+ ordered PARALLEL(L) PARALLEL (LN)
           PARALLEL(M1) PARALLEL(M2) PARALLEL(M3) PARALLEL(M4)
           PARALLEL (M5) PARALLEL(M6) PARALLEL(M7)
           PARALLEL (LN) */
  l.line_id ,
--changed for bug 3196900 , added l. for every attribute
  l.sold_to_org_id,
  l.invoice_to_org_id,
  l.ship_to_org_id,
  l.intmed_ship_to_org_id,
  l.deliver_to_org_id,
  l.end_customer_site_use_id,
  l.end_customer_id
 FROM OE_ORDER_LINES_HISTORY L ,
      RA_CUSTOMER_MERGES M1,
      RA_CUSTOMER_MERGES M2,
      RA_CUSTOMER_MERGES M3,
      RA_CUSTOMER_MERGES M4,
      RA_CUSTOMER_MERGES M5,
      RA_CUSTOMER_MERGES M6,
      RA_CUSTOMER_MERGES M7,
--changed for bug 3196900
--      OE_ORDER_LINES_HISTORY L
      OE_ORDER_LINES_ALL LN
  --Changed for MOAC
 WHERE
     ( l.sold_to_org_id        = m1.duplicate_id(+)
   and l.invoice_to_org_id     = m2.duplicate_site_id(+)
   and l.ship_to_org_id        = m3.duplicate_site_id(+)
   and l.intmed_ship_to_org_id = m4.duplicate_site_id(+)
   and l.deliver_to_org_id     = m5.duplicate_site_id(+)
   and l.end_customer_site_use_id   = m6.duplicate_site_id(+)
   and l.end_customer_id       = m7.duplicate_id(+) )
   and
   (m1.duplicate_site_id is not null or
    m2.duplicate_id is not null or
    m3.duplicate_id is not null or
    m4.duplicate_id is not null or
    m5.duplicate_id is not null  or
    m6.duplicate_id is not null or
    m7.duplicate_site_id is not null)
   and m1.process_flag(+) = 'N'
   and m2.process_flag(+) = 'N'
   and m3.process_flag(+) = 'N'
   and m4.process_flag(+) = 'N'
   and m5.process_flag(+) = 'N'
   and m6.process_flag(+) = 'N'
   and m7.process_flag(+) = 'N'
   and m1.request_id(+) =req_id
   and m2.request_id(+) =req_id
   and m3.request_id(+) =req_id
   and m4.request_id(+) =req_id
   and m5.request_id(+) =req_id
   and m6.request_id(+) =req_id
   and m7.request_id(+) =req_id
   and m1.set_number(+) =set_num
   and m2.set_number(+) =set_num
   and m3.set_number(+) =set_num
   and m4.set_number(+) =set_num
   and m5.set_number(+) =set_num
   and m6.set_number(+) =set_num
   and m7.set_number(+) =set_num
-- added for bug 3196900
   and l.line_id=ln.line_id;

 CURSOR MERGE_LINES_HISTORY_2_NP IS
	SELECT L.LINE_ID , L.SOLD_TO_ORG_ID, L.INVOICE_TO_ORG_ID, L.SHIP_TO_ORG_ID,
	  L.INTMED_SHIP_TO_ORG_ID, L.DELIVER_TO_ORG_ID, L.END_CUSTOMER_SITE_USE_ID,
	  L.END_CUSTOMER_ID
	FROM
	OE_CUST_MERGES_GTT M1, OE_ORDER_LINES_HISTORY L, OE_ORDER_LINES_ALL LN
	WHERE L.SOLD_TO_ORG_ID = M1.DUPLICATE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	AND L.LINE_ID=LN.LINE_ID
	UNION ALL
	SELECT L.LINE_ID , L.SOLD_TO_ORG_ID, L.INVOICE_TO_ORG_ID, L.SHIP_TO_ORG_ID,
	  L.INTMED_SHIP_TO_ORG_ID, L.DELIVER_TO_ORG_ID, L.END_CUSTOMER_SITE_USE_ID,
	  L.END_CUSTOMER_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_ORDER_LINES_HISTORY L, OE_ORDER_LINES_ALL LN
	WHERE L.INVOICE_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	AND L.LINE_ID=LN.LINE_ID
	UNION ALL
	SELECT L.LINE_ID , L.SOLD_TO_ORG_ID, L.INVOICE_TO_ORG_ID, L.SHIP_TO_ORG_ID,
	  L.INTMED_SHIP_TO_ORG_ID, L.DELIVER_TO_ORG_ID, L.END_CUSTOMER_SITE_USE_ID,
	  L.END_CUSTOMER_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_ORDER_LINES_HISTORY L, OE_ORDER_LINES_ALL LN
	WHERE L.SHIP_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	AND L.LINE_ID=LN.LINE_ID
	UNION ALL
	SELECT L.LINE_ID , L.SOLD_TO_ORG_ID, L.INVOICE_TO_ORG_ID, L.SHIP_TO_ORG_ID,
	  L.INTMED_SHIP_TO_ORG_ID, L.DELIVER_TO_ORG_ID, L.END_CUSTOMER_SITE_USE_ID,
	  L.END_CUSTOMER_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_ORDER_LINES_HISTORY L, OE_ORDER_LINES_ALL LN
	WHERE L.INTMED_SHIP_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	AND L.LINE_ID=LN.LINE_ID
	UNION ALL
	SELECT L.LINE_ID , L.SOLD_TO_ORG_ID, L.INVOICE_TO_ORG_ID, L.SHIP_TO_ORG_ID,
	  L.INTMED_SHIP_TO_ORG_ID, L.DELIVER_TO_ORG_ID, L.END_CUSTOMER_SITE_USE_ID,
	  L.END_CUSTOMER_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_ORDER_LINES_HISTORY L, OE_ORDER_LINES_ALL LN
	WHERE L.DELIVER_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	AND L.LINE_ID=LN.LINE_ID
	UNION ALL
	SELECT L.LINE_ID , L.SOLD_TO_ORG_ID, L.INVOICE_TO_ORG_ID, L.SHIP_TO_ORG_ID,
	  L.INTMED_SHIP_TO_ORG_ID, L.DELIVER_TO_ORG_ID, L.END_CUSTOMER_SITE_USE_ID,
	  L.END_CUSTOMER_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_ORDER_LINES_HISTORY L, OE_ORDER_LINES_ALL LN
	WHERE L.END_CUSTOMER_SITE_USE_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	AND L.LINE_ID=LN.LINE_ID
	UNION ALL
	SELECT L.LINE_ID , L.SOLD_TO_ORG_ID, L.INVOICE_TO_ORG_ID, L.SHIP_TO_ORG_ID,
	  L.INTMED_SHIP_TO_ORG_ID, L.DELIVER_TO_ORG_ID, L.END_CUSTOMER_SITE_USE_ID,
	  L.END_CUSTOMER_ID
	FROM
	OE_CUST_MERGES_GTT M1, OE_ORDER_LINES_HISTORY L, OE_ORDER_LINES_ALL LN
	WHERE L.END_CUSTOMER_ID= M1.DUPLICATE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	AND L.LINE_ID=LN.LINE_ID;

  lhst_line_id_tab	      num_table;
  lhst_sold_to_org_id_tab     num_table;
  lhst_invoice_to_org_id_tab  num_table;
  lhst_ship_to_org_id_tab     num_table;
  lhst_intmed_ship_to_org_id_tab     num_table;
  lhst_deliver_to_org_id_tab  num_table;
  lhst_end_cust_site_use_id_tab  num_table;
  lhst_end_cust_id_tab  num_table;

  TYPE num_table_binary_int IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  customer_id_tab        num_table_binary_int;
  customer_site_id_tab   num_table_binary_int;

 BEGIN

 arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Lines_History()+' );

 IF (process_mode = 'LOCK') THEN

   arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
   arp_message.set_token( 'TABLE_NAME', 'oe_order_lines_history', FALSE );

   open  merge_lines_history;
   close merge_lines_history;

 ELSE

 FOR C IN MERGE_SITES LOOP
          IF c.duplicate_id IS NOT NULL
             AND NOT customer_id_tab.EXISTS(MOD(c.duplicate_id,G_BINARY_LIMIT))THEN
             customer_id_tab(MOD(c.duplicate_id,G_BINARY_LIMIT)) := c.customer_id; --bug8541941
          END IF;

          IF c.duplicate_site_id IS NOT NULL
             AND NOT customer_site_id_tab.EXISTS(MOD(c.duplicate_site_id,G_BINARY_LIMIT)) THEN
             customer_site_id_tab(MOD(c.duplicate_site_id,G_BINARY_LIMIT)) := c.customer_site_id; --bug8541941
          END IF;

  END LOOP;


  -- Bug 7379750
  IF l_run_parallel_query = 'Y' THEN
	OPEN merge_lines_history_2;
  ELSE
	OPEN merge_lines_history_2_NP;
  END IF;

  LOOP

  -- Bug 7379750
  IF l_run_parallel_query = 'Y' THEN
     FETCH merge_lines_history_2
      BULK COLLECT INTO lhst_line_id_tab,
                        lhst_sold_to_org_id_tab,
                        lhst_invoice_to_org_id_tab,
                        lhst_ship_to_org_id_tab,
                        lhst_intmed_ship_to_org_id_tab,
                        lhst_deliver_to_org_id_tab,
	                lhst_end_cust_site_use_id_tab,
	                lhst_end_cust_id_tab
                        LIMIT 20000;
  ELSE
     FETCH merge_lines_history_2_NP
      BULK COLLECT INTO lhst_line_id_tab,
                        lhst_sold_to_org_id_tab,
                        lhst_invoice_to_org_id_tab,
                        lhst_ship_to_org_id_tab,
                        lhst_intmed_ship_to_org_id_tab,
                        lhst_deliver_to_org_id_tab,
	                lhst_end_cust_site_use_id_tab,
	                lhst_end_cust_id_tab
                        LIMIT 20000;
  END IF;



      if lhst_line_id_tab.COUNT <> 0 then
       for i in  lhst_line_id_tab.FIRST..lhst_line_id_tab.LAST LOOP

	          -- Access directly by the index position of the ids in the
	          -- values stored in customer_id_tab and customer_site_id_tab tables

	          if customer_id_tab.exists(MOD(lhst_sold_to_org_id_tab(i),G_BINARY_LIMIT)) then
	             lhst_sold_to_org_id_tab(i):= customer_id_tab(MOD(lhst_sold_to_org_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;

	          if customer_site_id_tab.exists(MOD(lhst_invoice_to_org_id_tab(i),G_BINARY_LIMIT)) then
	 	        lhst_invoice_to_org_id_tab(i):= customer_site_id_tab(MOD(lhst_invoice_to_org_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;

	          if customer_site_id_tab.exists(MOD(lhst_ship_to_org_id_tab(i),G_BINARY_LIMIT)) then
	 	       lhst_ship_to_org_id_tab(i):= customer_site_id_tab(MOD(lhst_ship_to_org_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;

	          if customer_site_id_tab.exists(MOD(lhst_intmed_ship_to_org_id_tab(i),G_BINARY_LIMIT)) then
		  	lhst_intmed_ship_to_org_id_tab(i):= customer_site_id_tab(MOD(lhst_intmed_ship_to_org_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;

	          if customer_site_id_tab.exists(MOD(lhst_deliver_to_org_id_tab(i),G_BINARY_LIMIT)) then
	 	        lhst_deliver_to_org_id_tab(i):= customer_site_id_tab(MOD(lhst_deliver_to_org_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;

		  if customer_site_id_tab.exists(MOD(lhst_end_cust_site_use_id_tab(i),G_BINARY_LIMIT)) then
	 	        lhst_end_cust_site_use_id_tab(i):= customer_site_id_tab(MOD(lhst_end_cust_site_use_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;

		  if customer_id_tab.exists(MOD(lhst_end_cust_id_tab(i),G_BINARY_LIMIT)) then
	             lhst_end_cust_id_tab(i):= customer_id_tab(MOD(lhst_end_cust_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;


     end loop;
     end if;


     arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
     arp_message.set_token( 'TABLE_NAME', 'oe_order_lines_history', FALSE );

    IF lhst_line_id_tab.COUNT <> 0 THEN
     FORALL i in lhst_line_id_tab.FIRST..lhst_line_id_tab.LAST
       UPDATE OE_ORDER_LINES_HISTORY LHIST
       SET  sold_to_org_id    	  = decode(lhst_sold_to_org_id_tab(i),null,sold_to_org_id,lhst_sold_to_org_id_tab(i)),
            invoice_to_org_id 	  = decode(lhst_invoice_to_org_id_tab(i),null,invoice_to_org_id,lhst_invoice_to_org_id_tab(i)),
            ship_to_org_id    	  = decode(lhst_ship_to_org_id_tab(i),null,ship_to_org_id,lhst_ship_to_org_id_tab(i)),
            intmed_ship_to_org_id  = decode(lhst_intmed_ship_to_org_id_tab(i),null,intmed_ship_to_org_id,lhst_intmed_ship_to_org_id_tab(i)),
            deliver_to_org_id 	  = decode(lhst_deliver_to_org_id_tab(i),null,deliver_to_org_id,lhst_deliver_to_org_id_tab(i)),
            end_customer_site_use_id = decode(lhst_end_cust_site_use_id_tab(i),null,end_customer_site_use_id,lhst_end_cust_site_use_id_tab(i)),
	    end_customer_id    	  = decode(lhst_end_cust_id_tab(i),null,end_customer_id,lhst_end_cust_id_tab(i)),
 	   last_update_date 	  = sysdate,
 	   last_updated_by 	  = arp_standard.profile.user_id,
 	   last_update_login      = arp_standard.profile.last_update_login,
 	   request_id             = req_id,
            program_application_id = arp_standard.profile.program_application_id ,
            program_id             = arp_standard.profile.program_id,
            program_update_date    = SYSDATE
        WHERE line_id = lhst_line_id_tab(i);

     g_count := sql%rowcount;

    ELSE
      g_count := 0;
    END IF;

     arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
     arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  -- Bug 7379750
     IF l_run_parallel_query = 'Y' THEN
	   EXIT WHEN merge_lines_history_2%NOTFOUND;
     ELSE
	   EXIT WHEN merge_lines_history_2_NP%NOTFOUND;
     END IF;

     lhst_line_id_tab.DELETE;
     lhst_sold_to_org_id_tab.DELETE;
     lhst_invoice_to_org_id_tab.DELETE;
     lhst_ship_to_org_id_tab.DELETE;
     lhst_intmed_ship_to_org_id_tab.DELETE;
     lhst_deliver_to_org_id_tab.DELETE;
     lhst_end_cust_site_use_id_tab.DELETE;

   END LOOP;  -- cursor merge_lines_history_2

  -- Bug 7379750
  IF l_run_parallel_query = 'Y' THEN
   CLOSE merge_lines_history_2;
  ELSE
   CLOSE merge_lines_history_2_NP;
  END IF;

 END IF;
    customer_id_tab.DELETE;
    customer_site_id_tab.DELETE;
    arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Lines_History()-' );

 EXCEPTION
 when others then
 	arp_message.set_error( 'OE_CUST_MERGE.OE_Merge_Lines_History-' );
     raise;

 END OE_Merge_Lines_History;

/*-------------------------------------------------*/
/*--- PRIVATE PROCEDURE OE_Merge_Lines_IFACE    ---*/
/*-------------------------------------------------*/

/*  Interface tables need not be updated
    Not logging merge for Interface tables

 Procedure OE_Merge_Lines_IFACE (Req_Id          IN NUMBER,
                                 Set_Num         IN NUMBER,
                                 Process_Mode    IN VARCHAR2)
 IS
 CURSOR c1 is
    select line_id
      from oe_lines_iface_all
     where ship_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c2 is
    select line_id
      from oe_lines_iface_all
     where invoice_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c3 is
    select line_id
      from oe_lines_iface_all
     where deliver_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c4 is
    select line_id
      from oe_lines_iface_all
     where sold_to_org_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;

 BEGIN
    arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Lines_IFACE()+' );

    -- both customer and site level

    IF( process_mode = 'LOCK' ) THEN

      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'oe_lines_iface_all', FALSE );

      open c1;
      close c1;

      open c2;
      close c2;

      open c3;
      close c3;

      open c4;
      close c4;

ELSE
    -- site level update
    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_lines_iface_all', FALSE );

    UPDATE oe_lines_iface_all  a
    set ship_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.ship_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'N'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login,
          request_id = req_id,
          program_application_id =arp_standard.profile.program_application_id,
          program_id = arp_standard.profile.program_id,
          program_update_date = sysdate
    where ship_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_lines_iface_all', FALSE );

    UPDATE oe_lines_iface_all  a
    set invoice_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.invoice_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'N'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login,
          request_id = req_id,
          program_application_id =arp_standard.profile.program_application_id,
          program_id = arp_standard.profile.program_id,
          program_update_date = sysdate
    where invoice_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_lines_iface_all', FALSE );

    UPDATE oe_lines_iface_all  a
    set deliver_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.deliver_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'N'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login,
          request_id = req_id,
          program_application_id =arp_standard.profile.program_application_id,
          program_id = arp_standard.profile.program_id,
          program_update_date = sysdate
    where deliver_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_lines_iface_all', FALSE );

   -- customer level update
    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_lines_iface_all', FALSE );

    UPDATE oe_lines_iface_all  a
    set    sold_to_org_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.sold_to_org_id = m.duplicate_id
                                and    m.process_flag = 'N'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where  sold_to_org_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'N'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num);

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

    arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Lines_IFACE()-' );

    EXCEPTION
    When others then
      arp_message.set_error( 'OE_CUST_MERGE.OE_Merge_Lines_IFACE-' );
      raise;

 END OE_Merge_Lines_IFACE;

Interface tables need not be updated  */

/*-------------------------------------------------*/
/*--- PRIVATE PROCEDURE OE_Merge_Line_ACKS      ---*/
/*-------------------------------------------------*/
 Procedure OE_Merge_Line_ACKS (Req_Id          IN NUMBER,
                               Set_Num         IN NUMBER,
                               Process_Mode    IN VARCHAR2)
 IS
 CURSOR c1 is
    select line_id
      from oe_line_acks
     where ship_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
    for update nowait;


 CURSOR c2 is
    select line_id
      from oe_line_acks
     where invoice_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
    for update nowait;


 CURSOR c3 is
    select line_id
      from oe_line_acks
     where deliver_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
    for update nowait;


 CURSOR c4 is
    select line_id
      from oe_line_acks
     where intmed_ship_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
    for update nowait;

 CURSOR c5 is
--changed for bug 3196900
    select a.line_id
      from oe_line_acks a, oe_order_lines l
     where a.sold_to_org_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
--changed for bug 3196900
    and a.line_id=l.line_id
    for update nowait;

 CURSOR c6 is
    select line_id
      from oe_line_acks
     where end_customer_site_use_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
    for update nowait;

 CURSOR c7 is
--changed for bug 3196900
    select a.line_id
      from oe_line_acks a,oe_order_lines l
     where a.end_customer_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
--changed for bug 3196900
    and a.line_id=l.line_id
    for update nowait;

 l_profile_val VARCHAR2(30);

 BEGIN
    arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Line_ACKS()+' );

    /* both customer and site level */

    IF( process_mode = 'LOCK' ) THEN

      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'oe_line_acks', FALSE );

      open c1;
      close c1;

      open c2;
      close c2;

      open c3;
      close c3;

      open c4;
      close c4;

      open c5;
      close c5;

      open c6;
      close c6;

      open c7;
      close c7;

ELSE

    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	    insert into  HZ_CUSTOMER_MERGE_LOG (
		MERGE_LOG_ID,
		TABLE_NAME,
		MERGE_HEADER_ID,
		PRIMARY_KEY1,
		PRIMARY_KEY2,
		NUM_COL3_ORIG,
		NUM_COL3_NEW,
		ACTION_FLAG,
		REQUEST_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY
		)
	    select
		HZ_CUSTOMER_MERGE_LOG_s.nextval,
		'OE_LINE_ACKS',
		m.CUSTOMER_MERGE_HEADER_ID,
		a.ORIG_SYS_DOCUMENT_REF,
	        a.ORIG_SYS_LINE_REF,
		a.ship_to_org_id,
		m.customer_site_id,
		'U',
		req_id,
		hz_utility_pub.CREATED_BY,
		hz_utility_pub.CREATION_DATE,
		hz_utility_pub.LAST_UPDATE_LOGIN,
		hz_utility_pub.LAST_UPDATE_DATE,
		hz_utility_pub.LAST_UPDATED_BY
	      from oe_line_acks a,
		   ra_customer_merges m
	     where m.process_flag = 'N'
	       and a.ship_to_org_id = m.duplicate_site_id
	       and m.request_id = req_id
	       and m.set_number = set_num
	       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
       end if;

    /* site level update */
    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_line_acks', FALSE );

    UPDATE oe_line_acks  a
    set ship_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.ship_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'N'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login,
          request_id = req_id,
          program_application_id =arp_standard.profile.program_application_id,
          program_id = arp_standard.profile.program_id,
          program_update_date = sysdate
    where ship_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
			                 and m.request_id = req_id
			                 and m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
    g_count := sql%rowcount;
    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	    insert into  HZ_CUSTOMER_MERGE_LOG (
		MERGE_LOG_ID,
		TABLE_NAME,
		MERGE_HEADER_ID,
		PRIMARY_KEY1,
		PRIMARY_KEY2,
		NUM_COL2_ORIG,
		NUM_COL2_NEW,
		ACTION_FLAG,
		REQUEST_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY
		)
	    select
		HZ_CUSTOMER_MERGE_LOG_s.nextval,
		'OE_LINE_ACKS',
		m.CUSTOMER_MERGE_HEADER_ID,
		a.ORIG_SYS_DOCUMENT_REF,
	        a.ORIG_SYS_LINE_REF,
		a.invoice_to_org_id,
		m.customer_site_id,
		'U',
		req_id,
		hz_utility_pub.CREATED_BY,
		hz_utility_pub.CREATION_DATE,
		hz_utility_pub.LAST_UPDATE_LOGIN,
		hz_utility_pub.LAST_UPDATE_DATE,
		hz_utility_pub.LAST_UPDATED_BY
	      from oe_line_acks a,
		   ra_customer_merges m
	     where m.process_flag = 'N'
	       and a.invoice_to_org_id = m.duplicate_site_id
	       and m.request_id = req_id
	       and m.set_number = set_num
	       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
       end if;

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_line_acks', FALSE );

    UPDATE oe_line_acks  a
    set invoice_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.invoice_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'N'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login,
          request_id = req_id,
          program_application_id =arp_standard.profile.program_application_id,
          program_id = arp_standard.profile.program_id,
          program_update_date = sysdate
    where invoice_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
			                 and m.request_id = req_id
			                 and m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
    g_count := sql%rowcount;
    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	    insert into  HZ_CUSTOMER_MERGE_LOG (
		MERGE_LOG_ID,
		TABLE_NAME,
		MERGE_HEADER_ID,
		PRIMARY_KEY1,
		PRIMARY_KEY2,
		NUM_COL4_ORIG,
		NUM_COL4_NEW,
		ACTION_FLAG,
		REQUEST_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY
		)
	    select
		HZ_CUSTOMER_MERGE_LOG_s.nextval,
		'OE_LINE_ACKS',
		m.CUSTOMER_MERGE_HEADER_ID,
		a.ORIG_SYS_DOCUMENT_REF,
	        a.ORIG_SYS_LINE_REF,
		a.deliver_to_org_id,
		m.customer_site_id,
		'U',
		req_id,
		hz_utility_pub.CREATED_BY,
		hz_utility_pub.CREATION_DATE,
		hz_utility_pub.LAST_UPDATE_LOGIN,
		hz_utility_pub.LAST_UPDATE_DATE,
		hz_utility_pub.LAST_UPDATED_BY
	      from oe_line_acks a,
		   ra_customer_merges m
	     where m.process_flag = 'N'
	       and a.deliver_to_org_id = m.duplicate_site_id
	       and m.request_id = req_id
	       and m.set_number = set_num
	       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
       end if;

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_line_acks', FALSE );

    UPDATE oe_line_acks  a
    set deliver_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.deliver_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'N'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login,
          request_id = req_id,
          program_application_id =arp_standard.profile.program_application_id,
          program_id = arp_standard.profile.program_id,
          program_update_date = sysdate
    where deliver_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
			                 and m.request_id = req_id
			                 and m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
    g_count := sql%rowcount;
    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	    insert into  HZ_CUSTOMER_MERGE_LOG (
		MERGE_LOG_ID,
		TABLE_NAME,
		MERGE_HEADER_ID,
		PRIMARY_KEY1,
		PRIMARY_KEY2,
		NUM_COL5_ORIG,
		NUM_COL5_NEW,
		ACTION_FLAG,
		REQUEST_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY
		)
	    select
		HZ_CUSTOMER_MERGE_LOG_s.nextval,
		'OE_LINE_ACKS',
		m.CUSTOMER_MERGE_HEADER_ID,
		a.ORIG_SYS_DOCUMENT_REF,
	        a.ORIG_SYS_LINE_REF,
		a.intmed_ship_to_org_id,
		m.customer_site_id,
		'U',
		req_id,
		hz_utility_pub.CREATED_BY,
		hz_utility_pub.CREATION_DATE,
		hz_utility_pub.LAST_UPDATE_LOGIN,
		hz_utility_pub.LAST_UPDATE_DATE,
		hz_utility_pub.LAST_UPDATED_BY
	      from oe_line_acks a,
		   ra_customer_merges m
	     where m.process_flag = 'N'
	       and a.intmed_ship_to_org_id = m.duplicate_site_id
	       and m.request_id = req_id
	       and m.set_number = set_num
	       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
       end if;

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_line_acks', FALSE );


    UPDATE oe_line_acks  a
    set intmed_ship_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.intmed_ship_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'N'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login,
          request_id = req_id,
          program_application_id =arp_standard.profile.program_application_id,
          program_id = arp_standard.profile.program_id,
          program_update_date = sysdate
    where intmed_ship_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
			                 and m.request_id = req_id
			                 and m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_line_acks', FALSE );


    IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	    insert into  HZ_CUSTOMER_MERGE_LOG (
		MERGE_LOG_ID,
		TABLE_NAME,
		MERGE_HEADER_ID,
		PRIMARY_KEY1,
		PRIMARY_KEY2,
		NUM_COL1_ORIG,
		NUM_COL1_NEW,
		ACTION_FLAG,
		REQUEST_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY
		)
	    select
		HZ_CUSTOMER_MERGE_LOG_s.nextval,
		'OE_LINE_ACKS',
		m.CUSTOMER_MERGE_HEADER_ID,
		a.ORIG_SYS_DOCUMENT_REF,
	        a.ORIG_SYS_LINE_REF,
		a.sold_to_org_id,
		m.customer_site_id,
		'U',
		req_id,
		hz_utility_pub.CREATED_BY,
		hz_utility_pub.CREATION_DATE,
		hz_utility_pub.LAST_UPDATE_LOGIN,
		hz_utility_pub.LAST_UPDATE_DATE,
		hz_utility_pub.LAST_UPDATED_BY
	      from oe_line_acks a,
		   ra_customer_merges m
	     where m.process_flag = 'N'
	       and a.sold_to_org_id = m.duplicate_site_id
	       and m.request_id = req_id
	       and m.set_number = set_num
	       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
       end if;

   /* customer level update */
    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_line_acks', FALSE );

    UPDATE oe_line_acks  a
    set    sold_to_org_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.sold_to_org_id = m.duplicate_id
                                and    m.process_flag = 'N'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where  sold_to_org_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'N'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
--added for bug 3196900
      and a.line_id in (select line_id from oe_order_lines);

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_line_acks', FALSE );


    IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	    insert into  HZ_CUSTOMER_MERGE_LOG (
		MERGE_LOG_ID,
		TABLE_NAME,
		MERGE_HEADER_ID,
		PRIMARY_KEY1,
		PRIMARY_KEY2,
		NUM_COL6_ORIG,
		NUM_COL6_NEW,
		ACTION_FLAG,
		REQUEST_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY
		)
	    select
		HZ_CUSTOMER_MERGE_LOG_s.nextval,
		'OE_LINE_ACKS',
		m.CUSTOMER_MERGE_HEADER_ID,
		a.ORIG_SYS_DOCUMENT_REF,
	        a.ORIG_SYS_LINE_REF,
		a.end_customer_site_use_id,
		m.customer_site_id,
		'U',
		req_id,
		hz_utility_pub.CREATED_BY,
		hz_utility_pub.CREATION_DATE,
		hz_utility_pub.LAST_UPDATE_LOGIN,
		hz_utility_pub.LAST_UPDATE_DATE,
		hz_utility_pub.LAST_UPDATED_BY
	      from oe_line_acks a,
		   ra_customer_merges m
	     where m.process_flag = 'N'
	       and a.sold_to_org_id = m.duplicate_site_id
	       and m.request_id = req_id
	       and m.set_number = set_num
	       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
       end if;

   /* customer level update */
    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_line_acks', FALSE );

    UPDATE oe_line_acks  a
    set    end_customer_site_use_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.end_customer_site_use_id = m.duplicate_id
                                and    m.process_flag = 'N'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where  end_customer_site_use_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'N'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_line_acks', FALSE );


    IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	    insert into  HZ_CUSTOMER_MERGE_LOG (
		MERGE_LOG_ID,
		TABLE_NAME,
		MERGE_HEADER_ID,
		PRIMARY_KEY1,
		PRIMARY_KEY2,
		NUM_COL7_ORIG,
		NUM_COL7_NEW,
		ACTION_FLAG,
		REQUEST_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY
		)
	    select
		HZ_CUSTOMER_MERGE_LOG_s.nextval,
		'OE_LINE_ACKS',
		m.CUSTOMER_MERGE_HEADER_ID,
		a.ORIG_SYS_DOCUMENT_REF,
	        a.ORIG_SYS_LINE_REF,
		a.end_customer_id,
		m.customer_site_id,
		'U',
		req_id,
		hz_utility_pub.CREATED_BY,
		hz_utility_pub.CREATION_DATE,
		hz_utility_pub.LAST_UPDATE_LOGIN,
		hz_utility_pub.LAST_UPDATE_DATE,
		hz_utility_pub.LAST_UPDATED_BY
	      from oe_line_acks a,
		   ra_customer_merges m
	     where m.process_flag = 'N'
	       and a.end_customer_id = m.duplicate_site_id
	       and m.request_id = req_id
	       and m.set_number = set_num
	       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
       end if;

   /* customer level update */
    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_line_acks', FALSE );

    UPDATE oe_line_acks  a
    set    end_customer_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.end_customer_id = m.duplicate_id
                                and    m.process_flag = 'N'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where  end_customer_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'N'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
--added for bug 3196900
      and a.line_id in (select line_id from oe_order_lines);

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

    arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Line_ACKS()-' );

    EXCEPTION
    When others then
      arp_message.set_error( 'OE_CUST_MERGE.OE_Merge_Line_ACKS-' );
      raise;

 END OE_Merge_Line_ACKS;
  -----------------------------------------------------------------
  --
  --	MAIN PROCEDURE
  --
  -- Procedure Name: Merge
  -- Parameter:      Req_id, Set_Num, Process_Mode
  --
  -- This is the main procedure to do customer merge for ONT product.
  -- This procedure will call other internal procedures to process
  -- the merging based on the functional areas.  Please see the HLD for
  -- Customer Merge for detail information (cmerge_hld.rtf).
  --
  --------------------------------------------------------------------

  Procedure Merge (Req_Id          IN NUMBER,
  			    Set_Num         IN NUMBER,
			    Process_Mode    IN VARCHAR2
			    ) IS
  sql_stmnt varchar2(200);

  BEGIN

    arp_message.set_line( 'OE_CUST_MERGE.Merge()+' );
  --  sql_stmnt := 'Alter Session set hash_area_size=61440000';
  --  EXECUTE IMMEDIATE sql_stmnt;
    l_dbi_profile :=  NVL(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'), 'Y');
    arp_message.set_line(' Dbi Profile='||l_dbi_profile);
    OE_CUST_MERGE.OE_Attachment_Merge (Req_Id, Set_Num, Process_Mode);
    OE_CUST_MERGE.OE_Defaulting_Merge (Req_Id, Set_Num, Process_Mode);
    OE_CUST_MERGE.OE_Hold_Merge (Req_Id, Set_Num, Process_Mode);
    OE_CUST_MERGE.OE_Constraints_Merge (Req_Id, Set_Num, Process_Mode);
    OE_CUST_MERGE.OE_Sets_Merge (Req_Id, Set_Num, Process_Mode);
    -- drop ship are po line location id and not site ids of accounts
    --OE_CUST_MERGE.OE_Drop_Ship_Merge (Req_Id, Set_Num, Process_Mode);
    OE_CUST_MERGE.OE_Ship_Tolerance_Merge (Req_Id, Set_Num, Process_Mode);
    OE_CUST_MERGE.OE_Order_Merge (Req_Id, Set_Num, Process_Mode);
    arp_message.set_line( 'OE_CUST_MERGE.Merge()-' );

    /* this part will be calling other internal procedures */

    EXCEPTION
    When others then
      arp_message.set_error( 'OE_CUST_MERGE.Merge-' );
      raise;


  END Merge;


 Procedure OE_Attachment_Merge(Req_Id          IN NUMBER,
					   Set_Num         IN NUMBER,
					   Process_Mode    IN VARCHAR2
					  )
IS
CURSOR c1 is
    select RULE_ELEMENT_ID
    from oe_attachment_rule_elements
    where  attribute_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code  = 'SHIP_TO_ORG_ID'
    for update nowait;

CURSOR c2 is
    select RULE_ELEMENT_ID
    from oe_attachment_rule_elements
    where  attribute_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code  = 'INVOICE_TO_ORG_ID'
    for update nowait;

CURSOR c3 is
    select RULE_ELEMENT_ID
    from oe_attachment_rule_elements
    where  attribute_value in (select to_char(m.duplicate_id)
                                 from   ra_customer_merges  m
                                 where  m.process_flag = 'N'
                        and    m.request_id = req_id
                        and    m.set_number = set_num)
    and attribute_code  = 'SOLD_TO_ORG_ID'
    for update nowait;

  l_profile_val VARCHAR2(30);

 BEGIN
	arp_message.set_line( 'OE_CUST_MERGE.OE_Attachment_Merge()+' );

/*-----------------------------+
 | OE_ATTACHMENTS_RULE_ELEMENTS|
 +-----------------------------*/
/* both customer and site level */

IF( process_mode = 'LOCK' ) THEN

  arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'OE_ATTACHMENT_RULE_ELEMENTS', FALSE );

  open c1;
  close c1;

  open c2;
  close c2;

  open c3;
  close c3;


ELSE

  HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
  l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           VCHAR_COL3_ORIG,
           VCHAR_COL3_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
	   )
       select
	HZ_CUSTOMER_MERGE_LOG_s.nextval,
	'OE_ATTACHMENT_RULE_ELEMENTS',
	m.customer_merge_header_id,
	a.rule_element_id,
	a.attribute_value,
	to_char(m.customer_site_id),
	'U',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY
	from OE_ATTACHMENT_RULE_ELEMENTS a,
	     ra_customer_merges m
	where a.attribute_value = to_char(m.duplicate_site_id)
	  and m.process_flag = 'N'
	  and m.request_id = req_id
	  and m.set_number = set_num
	  and a.attribute_code = 'SHIP_TO_ORG_ID';

    END IF;

/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'OE_ATTACHMENT_RULE_ELEMENTS', FALSE );

    UPDATE OE_ATTACHMENT_RULE_ELEMENTS  a
    set (attribute_value) = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.attribute_value =
                                                 to_char(m.duplicate_site_id)
                          and    m.request_id = req_id
                                   and    m.process_flag = 'N'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  attribute_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'SHIP_TO_ORG_ID';

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );


  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           VCHAR_COL2_ORIG,
           VCHAR_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
	   )
       select
	HZ_CUSTOMER_MERGE_LOG_s.nextval,
	'OE_ATTACHMENT_RULE_ELEMENTS',
	m.customer_merge_header_id,
	a.rule_element_id,
	a.attribute_value,
	 to_char(m.customer_site_id),
	'U',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY
	from OE_ATTACHMENT_RULE_ELEMENTS a,
	     ra_customer_merges m
	where a.attribute_value = to_char(m.duplicate_site_id)
	  and m.process_flag = 'N'
	  and m.request_id = req_id
	  and m.set_number = set_num
	  and a.attribute_code = 'INVOICE_TO_ORG_ID';

    END IF;

/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'OE_ATTACHMENT_RULE_ELEMENTS', FALSE );

    UPDATE OE_ATTACHMENT_RULE_ELEMENTS  a
    set (attribute_value) = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.attribute_value =
                                                 to_char(m.duplicate_site_id)
                          and    m.request_id = req_id
                                   and    m.process_flag = 'N'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  attribute_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'INVOICE_TO_ORG_ID';

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );



  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
	   )
       select
	HZ_CUSTOMER_MERGE_LOG_s.nextval,
	'OE_ATTACHMENT_RULE_ELEMENTS',
	m.customer_merge_header_id,
	a.rule_element_id,
	a.attribute_value,
	to_char(m.customer_site_id),
	'U',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY
	from OE_ATTACHMENT_RULE_ELEMENTS a,
	     ra_customer_merges m
	where a.attribute_value = to_char(m.duplicate_site_id)
	  and m.process_flag = 'N'
	  and m.request_id = req_id
	  and m.set_number = set_num
	  and a.attribute_code = 'SOLD_TO_ORG_ID';

    END IF;

/* customer level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'OE_ATTACHMENT_RULE_ELEMENTS', FALSE );

    UPDATE OE_ATTACHMENT_RULE_ELEMENTS  a
    set (attribute_value) = (select distinct to_char(m.customer_id)
                                   from   ra_customer_merges m
                                   where  a.attribute_value =
                                                 to_char(m.duplicate_id)
                          and    m.request_id = req_id
                                   and    m.process_flag = 'N'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  attribute_value in (select to_char(m.duplicate_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'SOLD_TO_ORG_ID';


  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

	arp_message.set_line( 'OE_CUST_MERGE.OE_Attachment_Merge()-' );


EXCEPTION
  when others then
	arp_message.set_line( 'OE_CUST_MERGE.OE_Attachment_Merge' );
    raise;


END OE_Attachment_Merge;


 Procedure OE_Defaulting_Merge (Req_Id          IN NUMBER,
					   Set_Num         IN NUMBER,
					   Process_Mode    IN VARCHAR2
					  )
 IS
CURSOR c1 is
    select CONDITION_ELEMENT_ID
    from oe_def_condn_elems
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code  = 'SHIP_TO_ORG_ID'
    for update nowait;

CURSOR c2 is
    select CONDITION_ELEMENT_ID
    from oe_def_condn_elems
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code  = 'INVOICE_TO_ORG_ID'
    for update nowait;

CURSOR c4 is
    select CONDITION_ELEMENT_ID
    from oe_def_condn_elems
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code  = 'INTMED_SHIP_TO_ORG_ID'
    for update nowait;

CURSOR c3 is
    select CONDITION_ELEMENT_ID
    from oe_def_condn_elems
    where  value_string in (select to_char(m.duplicate_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code  = 'SOLD_TO_ORG_ID'
    for update nowait;

CURSOR c5 is
    select ATTR_DEF_RULE_ID
    from oe_def_attr_def_rules
    where  src_constant_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code  = 'SHIP_TO_ORG_ID'
    for update nowait;

CURSOR c6 is
    select ATTR_DEF_RULE_ID
    from oe_def_attr_def_rules
    where  src_constant_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code  = 'INVOICE_TO_ORG_ID'
    for update nowait;

CURSOR c7 is
    select ATTR_DEF_RULE_ID
    from oe_def_attr_def_rules
    where  src_constant_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code  = 'INTMED_SHIP_TO_ORG_ID'
    for update nowait;

CURSOR c8 is
    select ATTR_DEF_RULE_ID
    from oe_def_attr_def_rules
    where  src_constant_value in (select to_char(m.duplicate_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code  = 'SOLD_TO_ORG_ID'
    for update nowait;

  l_profile_val VARCHAR2(30);

 BEGIN
     arp_message.set_line( 'OE_CUST_MERGE.OE_Defaulting_Merge()+' );

/*-----------------------------+
 | OE_DEF_CONDN_ELEMS|
 +-----------------------------*/
/* both customer and site level */

IF( process_mode = 'LOCK' ) THEN

  arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'OE_DEF_CONDN_ELEMS', FALSE );


  open c1;
  close c1;

  open c2;
  close c2;

  open c3;
  close c3;

  open c4;
  close c4;

  open c5;
  close c5;

  open c6;
  close c6;

  open c7;
  close c7;

  open c8;
  close c8;


ELSE

  HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
  l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');
 IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
	   )
       select
	HZ_CUSTOMER_MERGE_LOG_s.nextval,
	'OE_DEF_CONDN_ELEMS',
	m.customer_merge_header_id,
	a.condition_element_id,
	a.value_string,
	 to_char(m.customer_site_id),
	'U',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY
	 from OE_DEF_CONDN_ELEMS  a,
	      ra_customer_merges m
	where a.value_string = to_char(m.duplicate_site_id)
	  and m.process_flag = 'N'
	  and m.request_id = req_id
	  and m.set_number = set_num
	  and a.attribute_code = 'SHIP_TO_ORG_ID';

    END IF;

/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'OE_DEF_CONDN_ELEMS', FALSE );

    UPDATE OE_DEF_CONDN_ELEMS  a
    set value_string = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.value_string =
                                                 to_char(m.duplicate_site_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'N'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'SHIP_TO_ORG_ID';

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
	   )
       select
	HZ_CUSTOMER_MERGE_LOG_s.nextval,
	'OE_DEF_CONDN_ELEMS',
	m.customer_merge_header_id,
	a.condition_element_id,
	a.value_string,
	 to_char(m.customer_site_id),
	'U',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY
	 from OE_DEF_CONDN_ELEMS  a,
	      ra_customer_merges m
	where a.value_string = to_char(m.duplicate_site_id)
	  and m.process_flag = 'N'
	  and m.request_id = req_id
	  and m.set_number = set_num
	  and a.attribute_code = 'INVOICE_TO_ORG_ID';

    END IF;


/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'OE_DEF_CONDN_ELEMS', FALSE );

    UPDATE OE_DEF_CONDN_ELEMS  a
    set value_string = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.value_string =
                                                 to_char(m.duplicate_site_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'N'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'INVOICE_TO_ORG_ID';

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
	   )
       select
	HZ_CUSTOMER_MERGE_LOG_s.nextval,
	'OE_DEF_CONDN_ELEMS',
	m.customer_merge_header_id,
	a.condition_element_id,
	a.value_string,
	 to_char(m.customer_site_id),
	'U',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY
	 from OE_DEF_CONDN_ELEMS  a,
	      ra_customer_merges m
	where a.value_string = to_char(m.duplicate_site_id)
	  and m.process_flag = 'N'
	  and m.request_id = req_id
	  and m.set_number = set_num
	  and a.attribute_code = 'INTMED_SHIP_TO_ORG_ID';

    END IF;

/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'OE_DEF_CONDN_ELEMS', FALSE );

    UPDATE OE_DEF_CONDN_ELEMS  a
    set value_string = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.value_string =
                                                 to_char(m.duplicate_site_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'N'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'INTMED_SHIP_TO_ORG_ID';

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
	   )
       select
	HZ_CUSTOMER_MERGE_LOG_s.nextval,
	'OE_DEF_CONDN_ELEMS',
	m.customer_merge_header_id,
	a.condition_element_id,
	a.value_string,
	 to_char(m.customer_id),
	'U',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY
	 from OE_DEF_CONDN_ELEMS  a,
	      ra_customer_merges m
	where a.value_string = to_char(m.duplicate_id)
	  and m.process_flag = 'N'
	  and m.request_id = req_id
	  and m.set_number = set_num
	  and a.attribute_code = 'SOLD_TO_ORG_ID';

    END IF;

/* customer level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'OE_DEF_CONDN_ELEMS', FALSE );

    UPDATE OE_DEF_CONDN_ELEMS  a
    set value_string = (select distinct to_char(m.customer_id)
                                   from   ra_customer_merges m
                                   where  a.value_string =
                                                 to_char(m.duplicate_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'N'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  value_string in (select to_char(m.duplicate_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'SOLD_TO_ORG_ID';


  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );


  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           VCHAR_COL2_ORIG,
           VCHAR_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
	   )
       select
	HZ_CUSTOMER_MERGE_LOG_s.nextval,
	'OE_DEF_ATTR_DEF_RULES',
	m.customer_merge_header_id,
	a.attr_def_rule_id,
	a.src_constant_value,
	 to_char(m.customer_site_id),
	'U',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY
	 from OE_DEF_ATTR_DEF_RULES  a,
	      ra_customer_merges m
	where a.src_constant_value = to_char(m.duplicate_site_id)
	  and m.process_flag = 'N'
	  and m.request_id = req_id
	  and m.set_number = set_num
	  and a.attribute_code = 'SHIP_TO_ORG_ID';

    END IF;

/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'OE_DEF_ATTR_DEF_RULES', FALSE );



    UPDATE OE_DEF_ATTR_DEF_RULES  a
    set src_constant_value = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.src_constant_value =
                                                 to_char(m.duplicate_site_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'N'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  src_constant_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'SHIP_TO_ORG_ID';

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           VCHAR_COL2_ORIG,
           VCHAR_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
	   )
       select
	HZ_CUSTOMER_MERGE_LOG_s.nextval,
	'OE_DEF_ATTR_DEF_RULES',
	m.customer_merge_header_id,
	a.attr_def_rule_id,
	a.src_constant_value,
	 to_char(m.customer_site_id),
	'U',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY
	 from OE_DEF_ATTR_DEF_RULES  a,
	      ra_customer_merges m
	where a.src_constant_value = to_char(m.duplicate_site_id)
	  and m.process_flag = 'N'
	  and m.request_id = req_id
	  and m.set_number = set_num
	  and a.attribute_code = 'INVOICE_TO_ORG_ID';

    END IF;

/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'OE_DEF_ATTR_DEF_RULES', FALSE );

    UPDATE OE_DEF_ATTR_DEF_RULES  a
    set src_constant_value = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.src_constant_value =
                                                 to_char(m.duplicate_site_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'N'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  src_constant_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'INVOICE_TO_ORG_ID';

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           VCHAR_COL2_ORIG,
           VCHAR_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
	   )
       select
	HZ_CUSTOMER_MERGE_LOG_s.nextval,
	'OE_DEF_ATTR_DEF_RULES',
	m.customer_merge_header_id,
	a.attr_def_rule_id,
	a.src_constant_value,
	 to_char(m.customer_site_id),
	'U',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY
	 from OE_DEF_ATTR_DEF_RULES  a,
	      ra_customer_merges m
	where a.src_constant_value = to_char(m.duplicate_site_id)
	  and m.process_flag = 'N'
	  and m.request_id = req_id
	  and m.set_number = set_num
	  and a.attribute_code = 'INTMED_SHIP_TO_ORG_ID';

    END IF;

/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'OE_DEF_ATTR_DEF_RULES', FALSE );

    UPDATE OE_DEF_ATTR_DEF_RULES  a
    set src_constant_value = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.src_constant_value =
                                                 to_char(m.duplicate_site_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'N'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  src_constant_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'INTMED_SHIP_TO_ORG_ID';

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );


  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           VCHAR_COL2_ORIG,
           VCHAR_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
	   )
       select
	HZ_CUSTOMER_MERGE_LOG_s.nextval,
	'OE_DEF_ATTR_DEF_RULES',
	m.customer_merge_header_id,
	a.attr_def_rule_id,
	a.src_constant_value,
	 to_char(m.customer_site_id),
	'U',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY
	 from OE_DEF_ATTR_DEF_RULES  a,
	      ra_customer_merges m
	where a.src_constant_value = to_char(m.duplicate_site_id)
	  and m.process_flag = 'N'
	  and m.request_id = req_id
	  and m.set_number = set_num
	  and a.attribute_code = 'SOLD_TO_ORG_ID';

    END IF;

/* customer level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'OE_DEF_ATTR_DEF_RULES', FALSE );

    UPDATE OE_DEF_ATTR_DEF_RULES  a
    set src_constant_value = (select distinct to_char(m.customer_id)
                                   from   ra_customer_merges m
                                   where  a.src_constant_value =
                                                 to_char(m.duplicate_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'N'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  src_constant_value in (select to_char(m.duplicate_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'SOLD_TO_ORG_ID';


  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );



END IF;

     arp_message.set_line( 'OE_CUST_MERGE.OE_Defaulting_Merge()-' );


EXCEPTION
  when others then
     arp_message.set_line( 'OE_CUST_MERGE.OE_Defaulting_Merge' );
    raise;



END OE_Defaulting_Merge;

Procedure OE_Constraints_Merge (Req_Id          IN NUMBER,
					   Set_Num         IN NUMBER,
					   Process_Mode    IN VARCHAR2
					  )
IS
CURSOR c1 is
    select VALIDATION_TMPLT_ID
    from oe_pc_vtmplt_cols
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and column_name  = 'SHIP_TO_ORG_ID'
    for update nowait;

CURSOR c2 is
    select VALIDATION_TMPLT_ID
    from oe_pc_vtmplt_cols
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and column_name  = 'INVOICE_TO_ORG_ID'
    for update nowait;

CURSOR c4 is
    select VALIDATION_TMPLT_ID
    from oe_pc_vtmplt_cols
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and column_name  = 'INTMED_SHIP_TO_ORG_ID'
    for update nowait;

CURSOR c3 is
    select VALIDATION_TMPLT_ID
    from oe_pc_vtmplt_cols
    where  value_string in (select to_char(m.duplicate_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and column_name  = 'SOLD_TO_ORG_ID'
    for update nowait;

  l_profile_val VARCHAR2(30);

 BEGIN
     arp_message.set_line( 'OE_CUST_MERGE.Constraints_Merge()+' );

/*-----------------------------+
 | oe_pc_vtmplt_cols|
 +-----------------------------*/
/* both customer and site level */

IF( process_mode = 'LOCK' ) THEN

  arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'OE_PC_VTMPLT_COLS', FALSE );


  open c1;
  close c1;

  open c2;
  close c2;

  open c3;
  close c3;

  open c4;
  close c4;


ELSE

 HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
  l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
	   )
       select
	HZ_CUSTOMER_MERGE_LOG_s.nextval,
	'OE_PC_VTMPLT_COLS',
	m.customer_merge_header_id,
	a.validation_tmplt_id,
	a.value_string,
	 to_char(m.customer_site_id),
	'U',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY
	 from OE_PC_VTMPLT_COLS  a,
	      ra_customer_merges m
	where a.value_string = to_char(m.duplicate_site_id)
	  and m.process_flag = 'N'
	  and m.request_id = req_id
	  and m.set_number = set_num
	  and a.column_name = 'SHIP_TO_ORG_ID';

    END IF;

/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'OE_PC_VTMPLT_COLS', FALSE );

    UPDATE OE_PC_VTMPLT_COLS  a
    set value_string = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.value_string =
                                                 to_char(m.duplicate_site_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'N'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and column_name = 'SHIP_TO_ORG_ID';

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
	   )
       select
	HZ_CUSTOMER_MERGE_LOG_s.nextval,
	'OE_PC_VTMPLT_COLS',
	m.customer_merge_header_id,
	a.validation_tmplt_id,
	a.value_string,
	 to_char(m.customer_site_id),
	'U',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY
	 from OE_PC_VTMPLT_COLS  a,
	      ra_customer_merges m
	where a.value_string = to_char(m.duplicate_site_id)
	  and m.process_flag = 'N'
	  and m.request_id = req_id
	  and m.set_number = set_num
	  and a.column_name = 'INVOICE_TO_ORG_ID';

    END IF;

/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'OE_PC_VTMPLT_COLS', FALSE );

    UPDATE OE_PC_VTMPLT_COLS  a
    set value_string = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.value_string =
                                                 to_char(m.duplicate_site_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'N'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and column_name = 'INVOICE_TO_ORG_ID';

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
	   )
       select
	HZ_CUSTOMER_MERGE_LOG_s.nextval,
	'OE_PC_VTMPLT_COLS',
	m.customer_merge_header_id,
	a.validation_tmplt_id,
	a.value_string,
	 to_char(m.customer_site_id),
	'U',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY
	 from OE_PC_VTMPLT_COLS  a,
	      ra_customer_merges m
	where a.value_string = to_char(m.duplicate_site_id)
	  and m.process_flag = 'N'
	  and m.request_id = req_id
	  and m.set_number = set_num
	  and a.column_name = 'INTMED_SHIP_TO_ORG_ID';

    END IF;

/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'OE_PC_VTMPLT_COLS', FALSE );

    UPDATE OE_PC_VTMPLT_COLS  a
    set value_string = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.value_string =
                                                 to_char(m.duplicate_site_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'N'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and column_name = 'INTMED_SHIP_TO_ORG_ID';

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );


  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           VCHAR_COL2_ORIG,
           VCHAR_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
	   )
       select
	HZ_CUSTOMER_MERGE_LOG_s.nextval,
	'OE_PC_VTMPLT_COLS',
	m.customer_merge_header_id,
	a.validation_tmplt_id,
	a.value_string,
	 to_char(m.customer_id),
	'U',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY
	 from OE_PC_VTMPLT_COLS  a,
	      ra_customer_merges m
	where a.value_string = to_char(m.duplicate_id)
	  and m.process_flag = 'N'
	  and m.request_id = req_id
	  and m.set_number = set_num
	  and a.column_name = 'SOLD_TO_ORG_ID';

    END IF;

/* customer level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'OE_PC_VTMPLT_COLS', FALSE );

    UPDATE OE_PC_VTMPLT_COLS  a
    set value_string = (select distinct to_char(m.customer_id)
                                   from   ra_customer_merges m
                                   where  a.value_string =
                                                 to_char(m.duplicate_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'N'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  value_string in (select to_char(m.duplicate_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and column_name = 'SOLD_TO_ORG_ID';


  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

     arp_message.set_line( 'OE_CUST_MERGE.OE_Constraints_Merge()-' );


EXCEPTION
  when others then
     arp_message.set_line( 'OE_CUST_MERGE.OE_Constraints_Merge' );
    raise;

END OE_Constraints_Merge;




Procedure OE_Hold_Merge      (Req_Id          IN NUMBER,
					   Set_Num         IN NUMBER,
					   Process_Mode    IN VARCHAR2
					  )
 IS
CURSOR c1 is
    select hold_source_id
    from oe_hold_sources
    where  hold_entity_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and hold_entity_code = 'S'
    for update nowait;

CURSOR c2 is
    select hold_source_id
    from oe_hold_sources
    where  hold_entity_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and hold_entity_code = 'B'
    for update nowait;


CURSOR c3 is
    select hold_source_id
    from oe_hold_sources
    where  hold_entity_id in (select m.duplicate_id
                                 from   ra_customer_merges  m
                                 where  m.process_flag = 'N'
                        and    m.request_id = req_id
                        and    m.set_number = set_num)
    and hold_entity_code = 'C'
    for update nowait;

 l_profile_val VARCHAR2(30);

 BEGIN

		arp_message.set_line( 'OE_CUST_MERGE.OE_Hold_Merge()+' );
/*-----------------------------+
 | OE_HOLD_SOURCES         |
 +-----------------------------*/
/* both customer and site level */

IF( process_mode = 'LOCK' ) THEN

  arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'OE_HOLD_SOURCES', FALSE );

  open c1;
  close c1;

  open c2;
  close c2;

  open c3;
  close c3;

ELSE

  HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
  l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

   IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
	   )
       select
	HZ_CUSTOMER_MERGE_LOG_s.nextval,
	'OE_HOLD_SOURCES',
	m.customer_merge_header_id,
	a.hold_source_id,
	to_char(a.hold_entity_id),
	to_char(m.customer_site_id),
	'U',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY
	 from OE_HOLD_SOURCES  a,
	      ra_customer_merges m
	where a.hold_entity_id = to_char(m.duplicate_site_id)
	  and m.process_flag = 'N'
	  and m.request_id = req_id
	  and m.set_number = set_num
	  and a.hold_entity_code = 'S';

    END IF;

/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'OE_HOLD_SOURCES', FALSE );

    UPDATE OE_HOLD_SOURCES  a
    set (hold_entity_id) = (select distinct to_char(m.customer_site_id)		--Bug 8866783
                                   from   ra_customer_merges m
                                   where  a.hold_entity_id =
                                                 m.duplicate_site_id
                          and    m.request_id = req_id
                                   and    m.process_flag = 'N'
                          and    m.set_number = set_num),
           last_update_date = sysdate,

           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  hold_entity_id in (select to_char(m.duplicate_site_id)		--Bug 8866783
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and hold_entity_code = 'S';

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
	   )
       select
	HZ_CUSTOMER_MERGE_LOG_s.nextval,
	'OE_HOLD_SOURCES',
	m.customer_merge_header_id,
	a.hold_source_id,
	to_char(a.hold_entity_id),
	to_char(m.customer_site_id),
	'U',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY
	 from OE_HOLD_SOURCES  a,
	      ra_customer_merges m
	where a.hold_entity_id = to_char(m.duplicate_site_id)
	  and m.process_flag = 'N'
	  and m.request_id = req_id
	  and m.set_number = set_num
	  and a.hold_entity_code = 'B';

    END IF;

/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_HOLD_SOURCES', FALSE );

    UPDATE OE_HOLD_SOURCES  a
    set (hold_entity_id) = (select distinct to_char(m.customer_site_id)		--Bug 8866783
                                   from   ra_customer_merges m
                                   where  a.hold_entity_id =

                                                 m.duplicate_site_id
                          and    m.request_id = req_id
                                   and    m.process_flag = 'N'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  hold_entity_id in (select to_char(m.duplicate_site_id)		--Bug 8866783
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and hold_entity_code = 'B';

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );


  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
	   )
       select
	HZ_CUSTOMER_MERGE_LOG_s.nextval,
	'OE_HOLD_SOURCES',
	m.customer_merge_header_id,
	a.hold_source_id,
	to_char(a.hold_entity_id),
	 to_char(m.customer_id),
	'U',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY
	 from OE_HOLD_SOURCES  a,
	      ra_customer_merges m
	where a.hold_entity_id = to_char(m.duplicate_id)
	  and m.process_flag = 'N'
	  and m.request_id = req_id
	  and m.set_number = set_num
	  and a.hold_entity_code = 'S';

    END IF;

/* customer level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_HOLD_SOURCES', FALSE );

    UPDATE OE_HOLD_SOURCES  a
    set    hold_entity_id = (select distinct to_char(m.customer_id)		--Bug 8866783
                                from   ra_customer_merges m
                                where  a.hold_entity_id =
                              m.duplicate_id
                                and    m.process_flag = 'N'
                       and    m.request_id = req_id
                       and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  hold_entity_id in (select to_char(m.duplicate_id)			--Bug 8866783
                                 from   ra_customer_merges  m
                                 where  m.process_flag = 'N'
                        and    m.request_id = req_id
                        and    m.set_number = set_num)
    and hold_entity_code = 'C';

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

	arp_message.set_line( 'OE_CUST_MERGE.OE_Hold_Merge()-' );


EXCEPTION
  when others then
	arp_message.set_line( 'OE_CUST_MERGE.OE_Hold_Merge' );
    raise;

END OE_Hold_Merge;

 Procedure OE_Drop_SHip_Merge (Req_Id          IN NUMBER,
                             Set_Num         IN NUMBER,
                             Process_Mode    IN VARCHAR2)
 IS
 CURSOR c1 is
    select DROP_SHIP_SOURCE_ID
      from oe_drop_ship_sources
     where LINE_LOCATION_ID in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;

  l_profile_val VARCHAR2(30);

 BEGIN
    arp_message.set_line( 'OE_CUST_MERGE.OE_Drop_SHip_Merge()+' );

    /* both customer and site level */

    IF( process_mode = 'LOCK' ) THEN

      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'OE_DROP_SHIP_SOURCES', FALSE );

      open c1;
      close c1;

ELSE

   HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
   l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

   IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           VCHAR_COL1_ORIG,
           VCHAR_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
	   )
       select
	HZ_CUSTOMER_MERGE_LOG_s.nextval,
	'OE_DROP_SHIP_SOURCES',
	m.customer_merge_header_id,
	a.drop_ship_source_id,
	to_char(a.line_location_id),
	to_char(m.customer_site_id),
	'U',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY
	 from OE_DROP_SHIP_SOURCES  a,
	      ra_customer_merges m
	where a.line_location_id = to_char(m.duplicate_site_id)
	  and m.process_flag = 'N'
	  and m.request_id = req_id
	  and m.set_number = set_num;

    END IF;

    /* site level update */
    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'OE_DROP_SHIP_SOURCES', FALSE );

    UPDATE OE_DROP_SHIP_SOURCES  a
    set line_location_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.line_location_id = m.duplicate_site_id
                             and m.request_id = req_id
                             and m.process_flag = 'N'
                             and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login
    where line_location_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
                                and m.request_id = req_id
                                and m.set_number = set_num);
    g_count := sql%rowcount;
    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

    arp_message.set_line( 'OE_CUST_MERGE.OE_Drop_SHip_Merge()-' );

    EXCEPTION
    When others then
      arp_message.set_error( 'OE_CUST_MERGE.OE_Drop_SHip_Merge-' );
      raise;

 END OE_Drop_Ship_Merge;

 Procedure OE_Ship_Tolerance_Merge (Req_Id          IN NUMBER,
                             Set_Num         IN NUMBER,
                             Process_Mode    IN VARCHAR2)
 IS
 CURSOR c1 is
    select CUST_ITEM_SETTING_ID
      from oe_cust_item_settings
     where site_use_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;

 CURSOR c2 is
    select CUST_ITEM_SETTING_ID
      from oe_cust_item_settings
     where customer_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;

 l_profile_val VARCHAR2(30);

 BEGIN
    arp_message.set_line( 'OE_CUST_MERGE.OE_ship_tolerance_merge()+' );

    /* both customer and site level */

    IF( process_mode = 'LOCK' ) THEN

      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'OE_CUST_ITEM_SETTINGS', FALSE );

      open c1;
      close c1;

      open c2;
      close c2;



ELSE

   HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
   l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

   IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
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
	   )
       select
	HZ_CUSTOMER_MERGE_LOG_s.nextval,
	'OE_CUST_ITEM_SETTINGS',
	m.customer_merge_header_id,
	a.cust_item_setting_id,
	a.site_use_id,
	m.customer_site_id,
	'U',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY
	 from OE_CUST_ITEM_SETTINGS  a,
	      ra_customer_merges m
	where a.site_use_id = m.duplicate_site_id
	  and m.process_flag = 'N'
	  and m.request_id = req_id
	  and m.set_number = set_num;

    END IF;

    /* site level update */
    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'OE_CUST_ITEM_SETTINGS', FALSE );

    UPDATE OE_CUST_ITEM_SETTINGS  a
    set site_use_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.site_use_id = m.duplicate_site_id
                             and m.request_id = req_id
                             and m.process_flag = 'N'
                             and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login
    where site_use_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
                                and m.request_id = req_id
                                and m.set_number = set_num);
    g_count := sql%rowcount;
    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

 IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
           NUM_COL2_ORIG,
           NUM_COL2_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
	   )
       select
	HZ_CUSTOMER_MERGE_LOG_s.nextval,
	'OE_CUST_ITEM_SETTINGS',
	m.customer_merge_header_id,
	a.cust_item_setting_id,
	a.customer_id,
	m.customer_id,
	'U',
	req_id,
	hz_utility_pub.CREATED_BY,
	hz_utility_pub.CREATION_DATE,
	hz_utility_pub.LAST_UPDATE_LOGIN,
	hz_utility_pub.LAST_UPDATE_DATE,
	hz_utility_pub.LAST_UPDATED_BY
	 from OE_CUST_ITEM_SETTINGS  a,
	      ra_customer_merges m
	where a.customer_id = m.duplicate_id
	  and m.process_flag = 'N'
	  and m.request_id = req_id
	  and m.set_number = set_num;

    END IF;

    /* customer level update */
    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'OE_CUST_ITEM_SETTINGS', FALSE );

    UPDATE OE_CUST_ITEM_SETTINGS  a
    set customer_id = (select distinct m.customer_id
                            from ra_customer_merges m
                           where a.customer_id = m.duplicate_id
                             and m.request_id = req_id
                             and m.process_flag = 'N'
                             and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login
    where customer_id in (select m.duplicate_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
                                and m.request_id = req_id
                                and m.set_number = set_num);
    g_count := sql%rowcount;
    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

    arp_message.set_line( 'OE_CUST_MERGE.OE_Ship_Tolerance_Merge()-' );

    EXCEPTION
    When others then
      arp_message.set_error( 'OE_CUST_MERGE.OE_Ship_Tolerance_Merge-' );
      raise;

 END OE_Ship_Tolerance_Merge;


 Procedure OE_Sets_Merge (Req_Id          IN NUMBER,
                             Set_Num         IN NUMBER,
                             Process_Mode    IN VARCHAR2)
 IS
 CURSOR SETS_MERGE IS
 SELECT /*+ FULL(M)
            FULL(S)
            PARALLEL(S,30)
            PARALLEL(M,30)
            USE_HASH(M,S) */
  s.set_id , s.ship_to_org_id , m.customer_merge_id
 FROM RA_CUSTOMER_MERGES M, OE_SETS S
 WHERE
   s.ship_to_org_id = m.duplicate_site_id
   and m.process_flag = 'N'
   and m.request_id = req_id
   and m.set_number = set_num
 for update nowait;

 CURSOR SETS_MERGE_2 IS
 SELECT /*+ FULL(M)
            FULL(S)
            PARALLEL(S,30)
            PARALLEL(M,30)
            USE_HASH(M,S) */
  s.set_id , s.ship_to_org_id ,m.customer_merge_id
 FROM RA_CUSTOMER_MERGES M, OE_SETS S
 WHERE
   s.ship_to_org_id = m.duplicate_site_id
   and m.process_flag = 'N'
   and m.request_id = req_id
   and m.set_number = set_num;

  sets_set_id_tab	         num_table;
  sets_ship_to_org_id_tab     num_table;

  MERGE_HEADER_ID_LIST MERGE_ID_LIST_TYPE;
  l_profile_val VARCHAR2(30);

  BEGIN

 arp_message.set_line( 'OE_CUST_MERGE.OE_Sets_Merge()+' );

 IF (process_mode = 'LOCK') THEN

   arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
   arp_message.set_token( 'TABLE_NAME', 'oe_sets', FALSE );

   open  sets_merge;
   close sets_merge;

 ELSE

    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

   OPEN sets_merge_2;
   LOOP
     FETCH sets_merge_2
      BULK COLLECT INTO sets_set_id_tab,
                        sets_ship_to_org_id_tab,
			MERGE_HEADER_ID_LIST
                        LIMIT 20000;

 IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
    IF sets_set_id_tab.COUNT <> 0 THEN
       forall i in  sets_set_id_tab.FIRST..sets_set_id_tab.LAST
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
				'OE_SETS',
				MERGE_HEADER_ID_LIST(I),
				sets_set_id_tab(I),
				sets_ship_to_org_id_tab(I),
				sets_ship_to_org_id_tab(I),
				'U',
				req_id,
				hz_utility_pub.CREATED_BY,
				hz_utility_pub.CREATION_DATE,
				hz_utility_pub.LAST_UPDATE_LOGIN,
				hz_utility_pub.LAST_UPDATE_DATE,
				hz_utility_pub.LAST_UPDATED_BY
				);
    end if;
 end if;


     arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
     arp_message.set_token( 'TABLE_NAME', 'oe_sets', FALSE );

    IF sets_set_id_tab.COUNT <> 0 THEN
     FORALL i in sets_set_id_tab.FIRST..sets_set_id_tab.LAST
       UPDATE OE_SETS S
       SET  ship_to_org_id  	  = sets_ship_to_org_id_tab(i),
 	       update_date 	     = sysdate,
 	       updated_by 	    = arp_standard.profile.user_id,
 	       update_login      = arp_standard.profile.last_update_login
 	  WHERE set_id = sets_set_id_tab(i);

     g_count := sql%rowcount;

    ELSE
     g_count := 0;
    END IF;

     arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
     arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
     EXIT WHEN sets_merge_2%NOTFOUND;

     sets_set_id_tab.DELETE;
     sets_ship_to_org_id_tab.DELETE;
     MERGE_HEADER_ID_LIST.DELETE;

   END LOOP;  -- cursor sets_merge_2

   CLOSE sets_merge_2;

 END IF;
    arp_message.set_line( 'OE_CUST_MERGE.OE_Sets_Merge()-' );

 EXCEPTION
 when others then
 	arp_message.set_error( 'OE_CUST_MERGE.OE_Sets_Merge-' );
     raise;

 END OE_Sets_merge;

 Procedure OE_Merge_Price_Adj_Attribs     (Req_Id          IN NUMBER,
                                           Set_Num         IN NUMBER,
                                           Process_Mode    IN VARCHAR2
                                          )
 IS
 -- For 'Ship To' Qualifier Attribute
 --bug6071855
 CURSOR c1 IS
 SELECT /*+ USE_NL (M A)
           INDEX (A,OE_PRICE_ADJ_ATTRIBS_N2) */
  a.price_adj_attrib_id ,
  decode(a.pricing_attribute, 'QUALIFIER_ATTRIBUTE2',
                               m.customer_id, m.customer_site_id) attrib_value_from, a.pricing_attr_value_from,
  m.customer_merge_id
--changed for bug 3196900
--  FROM RA_CUSTOMER_MERGES M, OE_PRICE_ADJ_ATTRIBS A
  FROM RA_CUSTOMER_MERGES M, OE_PRICE_ADJ_ATTRIBS A,OE_PRICE_ADJUSTMENTS P,OE_ORDER_HEADERS H
 WHERE
   a.pricing_context = 'CUSTOMER'
   and ((a.pricing_attribute in ('QUALIFIER_ATTRIBUTE11',
                               'QUALIFIER_ATTRIBUTE5',
                               'QUALIFIER_ATTRIBUTE14')
   and a.pricing_attr_value_from = to_char(m.duplicate_site_id))
OR (a.pricing_attribute = 'QUALIFIER_ATTRIBUTE2'
    and a.pricing_attr_value_from = to_char(m.duplicate_id)))
   and m.process_flag = 'N'
   and m.request_id = req_id
   and m.set_number = set_num
--added for bug 3196900
   and a.price_adjustment_id=p.price_adjustment_id
   and p.header_id=h.header_id
 for update nowait;

 --bug6071855
 CURSOR c1_2 IS
 SELECT /*+ USE_NL (M A)
           INDEX (A,OE_PRICE_ADJ_ATTRIBS_N2) */
  a.price_adj_attrib_id ,
  decode(a.pricing_attribute, 'QUALIFIER_ATTRIBUTE2',
                               m.customer_id, m.customer_site_id) attrib_value_from, a.pricing_attr_value_from,
  m.customer_merge_id
--changed for bug 3196900
 -- FROM RA_CUSTOMER_MERGES M, OE_PRICE_ADJ_ATTRIBS A
  FROM RA_CUSTOMER_MERGES M, OE_PRICE_ADJ_ATTRIBS A , OE_PRICE_ADJUSTMENTS P,
  OE_ORDER_HEADERS H
 WHERE
   a.pricing_context = 'CUSTOMER'
   and ((a.pricing_attribute in ('QUALIFIER_ATTRIBUTE11',
                               'QUALIFIER_ATTRIBUTE5',
                               'QUALIFIER_ATTRIBUTE14')
   and a.pricing_attr_value_from = to_char(m.duplicate_site_id))
OR (a.pricing_attribute = 'QUALIFIER_ATTRIBUTE2'
    and a.pricing_attr_value_from = to_char(m.duplicate_id)))
   and m.process_flag = 'N'
   and m.request_id = req_id
   and m.set_number = set_num
--added for bug 3196900
   and a.price_adjustment_id=p.price_adjustment_id
   and p.header_id=h.header_id;

  attrib_id_tab                num_table;
  attrib_value_from_tab        num_table;
  pricing_attr_value_from_tab  vchar240_table;
  merge_header_id_list         merge_id_list_type;

  l_profile_val                varchar2(30);

  BEGIN

 arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Price_Adj_Attribs()+' );
 IF (process_mode = 'LOCK') THEN

   arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
   arp_message.set_token( 'TABLE_NAME', 'oe_price_adj_attribs', FALSE );

    open c1;
    close c1;

 ELSE

    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

   OPEN c1_2;
   LOOP
     FETCH c1_2
      BULK COLLECT INTO attrib_id_tab,
                        attrib_value_from_tab,
			pricing_attr_value_from_tab,
 			MERGE_HEADER_ID_LIST
                        LIMIT 20000;

     IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	IF attrib_id_tab.COUNT <> 0 THEN
        FORALL I in attrib_id_tab.FIRST..attrib_id_tab.LAST
	  INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           PRIMARY_KEY_ID1,
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
         'OE_PRICE_ADJ_ATTRIBS',
         MERGE_HEADER_ID_LIST(I),
         attrib_id_tab(I),
         pricing_attr_value_from_tab(I),
         to_char(attrib_value_from_tab(I)),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );

		   END IF;
		end if;

     arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
     arp_message.set_token( 'TABLE_NAME', 'oe_price_adj_attribs', FALSE );

    IF attrib_id_tab.COUNT <> 0 THEN
     FORALL i in attrib_id_tab.FIRST..attrib_id_tab.LAST
       UPDATE OE_PRICE_ADJ_ATTRIBS S
       SET  pricing_attr_value_from = to_char(attrib_value_from_tab(i)),
               last_update_date           = sysdate,
               last_updated_by           = arp_standard.profile.user_id,
               last_update_login      = arp_standard.profile.last_update_login
          WHERE price_adj_attrib_id = attrib_id_tab(i);

     g_count := sql%rowcount;

    ELSE
     g_count := 0;
    END IF;

     arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
     arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
     EXIT WHEN c1_2%NOTFOUND;

     attrib_id_tab.DELETE;
     attrib_value_from_tab.DELETE;
     pricing_attr_value_from_tab.DELETE;
     merge_header_id_list.DELETE;

   END LOOP;  -- cursor c1_2

   CLOSE c1_2;

 END IF;
    arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Price_Adj_Attribs()-' );

 EXCEPTION
 when others then
        arp_message.set_error( 'OE_CUST_MERGE.OE_Merge_Price_Adj_Attribs-' );
     raise;

 END OE_Merge_Price_Adj_Attribs;

 -- Bug 2814785 => Enable account/account site merge for blankets tables
/*------------------------------------------------*/
/*--- PRIVATE Procedure OE_Merge_Blanket_Headers       ---*/
/*------------------------------------------------*/

 Procedure OE_Merge_Blanket_Headers (Req_Id          IN NUMBER,
                             Set_Num         IN NUMBER,
                             Process_Mode    IN VARCHAR2)
 IS

 CURSOR MERGE_SITES IS
   select duplicate_id, customer_id, duplicate_site_id, customer_site_id
     from ra_customer_merges m
     where m.process_flag = 'N'
     and m.request_id = req_id
     and m.set_number = set_num;


 CURSOR MERGE_HEADERS IS
 SELECT /*+ PARALLEL(H)
            PARALLEL(M1)
            PARALLEL(M2)
            PARALLEL(M3)
            PARALLEL(M4)
            PARALLEL(M5) */
  h.header_id ,
  h.sold_to_org_id,
  h.invoice_to_org_id,
  h.ship_to_org_id,
  h.deliver_to_org_id,
  h.sold_to_site_use_id,
  nvl(m1.customer_merge_id,nvl(m2.customer_merge_id,nvl(m3.customer_merge_id,nvl(m4.customer_merge_id,m5.customer_merge_id))))
 FROM RA_CUSTOMER_MERGES M1,
      RA_CUSTOMER_MERGES M2,
      RA_CUSTOMER_MERGES M3,
      RA_CUSTOMER_MERGES M4,
      RA_CUSTOMER_MERGES M5,
-- changed for bug 3196900
--      OE_BLANKET_HEADERS_ALL H
      OE_BLANKET_HEADERS H
 WHERE
     ( h.sold_to_org_id        = m1.duplicate_id(+)
   and h.invoice_to_org_id     = m2.duplicate_site_id(+)
   and h.ship_to_org_id        = m3.duplicate_site_id(+)
   and h.deliver_to_org_id     = m4.duplicate_site_id(+)
   and h.sold_to_site_use_id   = m5.duplicate_site_id(+) )
   and
   (m1.duplicate_site_id is not null or
    m2.duplicate_id is not null or
    m3.duplicate_id is not null or
    m4.duplicate_id is not null or
    m5.duplicate_id is not null   )
   and m1.process_flag(+) = 'N'
   and m2.process_flag(+) = 'N'
   and m3.process_flag(+) = 'N'
   and m4.process_flag(+) = 'N'
   and m5.process_flag(+) = 'N'
   and m1.request_id(+) =req_id
   and m2.request_id(+) =req_id
   and m3.request_id(+) =req_id
   and m4.request_id(+) =req_id
   and m5.request_id(+) =req_id
   and m1.set_number(+) =set_num
   and m2.set_number(+) =set_num
   and m3.set_number(+) =set_num
   and m4.set_number(+) =set_num
   and m5.set_number(+) =set_num
 for update nowait;


 CURSOR MERGE_HEADERS_2 IS
 SELECT /*+ PARALLEL(H)
            PARALLEL(M1)
            PARALLEL(M2)
            PARALLEL(M3)
            PARALLEL(M4)
            PARALLEL(M5) */
  h.header_id ,
  h.sold_to_org_id,
  h.invoice_to_org_id,
  h.ship_to_org_id,
  h.deliver_to_org_id,
  h.sold_to_site_use_id,
  nvl(m1.customer_merge_id,nvl(m2.customer_merge_id,nvl(m3.customer_merge_id,nvl(m4.customer_merge_id,m5.customer_merge_id))))
 FROM RA_CUSTOMER_MERGES M1,
      RA_CUSTOMER_MERGES M2,
      RA_CUSTOMER_MERGES M3,
      RA_CUSTOMER_MERGES M4,
      RA_CUSTOMER_MERGES M5,
-- changed for bug 3196900
--      OE_BLANKET_HEADERS_ALL H
      OE_BLANKET_HEADERS H
 WHERE
     ( h.sold_to_org_id        = m1.duplicate_id(+)
   and h.invoice_to_org_id     = m2.duplicate_site_id(+)
   and h.ship_to_org_id        = m3.duplicate_site_id(+)
   and h.deliver_to_org_id     = m4.duplicate_site_id(+)
   and h.sold_to_site_use_id   = m5.duplicate_site_id(+) )
   and
   (m1.duplicate_site_id is not null or
    m2.duplicate_id is not null or
    m3.duplicate_id is not null or
    m4.duplicate_id is not null or
    m5.duplicate_id is not null )
   and m1.process_flag(+) = 'N'
   and m2.process_flag(+) = 'N'
   and m3.process_flag(+) = 'N'
   and m4.process_flag(+) = 'N'
   and m5.process_flag(+) = 'N'
   and m1.request_id(+) =req_id
   and m2.request_id(+) =req_id
   and m3.request_id(+) =req_id
   and m4.request_id(+) =req_id
   and m5.request_id(+) =req_id
   and m1.set_number(+) =set_num
   and m2.set_number(+) =set_num
   and m3.set_number(+) =set_num
   and m4.set_number(+) =set_num
   and m5.set_number(+) =set_num;

    CURSOR MERGE_HEADERS_2_NP IS
   	SELECT
	  H.HEADER_ID, H.SOLD_TO_ORG_ID, H.INVOICE_TO_ORG_ID,
	  H.SHIP_TO_ORG_ID, H.DELIVER_TO_ORG_ID,
	  H.SOLD_TO_SITE_USE_ID, M1.CUSTOMER_MERGE_ID
	FROM
	OE_CUST_MERGES_GTT M1, OE_BLANKET_HEADERS H
	WHERE H.SOLD_TO_ORG_ID = M1.DUPLICATE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	UNION ALL
	SELECT
	  H.HEADER_ID, H.SOLD_TO_ORG_ID, H.INVOICE_TO_ORG_ID,
	  H.SHIP_TO_ORG_ID, H.DELIVER_TO_ORG_ID,
	  H.SOLD_TO_SITE_USE_ID, M1.CUSTOMER_MERGE_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_BLANKET_HEADERS H
	WHERE H.INVOICE_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	UNION ALL
	SELECT
	  H.HEADER_ID, H.SOLD_TO_ORG_ID, H.INVOICE_TO_ORG_ID,
	  H.SHIP_TO_ORG_ID, H.DELIVER_TO_ORG_ID,
	  H.SOLD_TO_SITE_USE_ID, M1.CUSTOMER_MERGE_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_BLANKET_HEADERS H
	WHERE H.SHIP_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	UNION ALL
	SELECT
	  H.HEADER_ID, H.SOLD_TO_ORG_ID, H.INVOICE_TO_ORG_ID,
	  H.SHIP_TO_ORG_ID, H.DELIVER_TO_ORG_ID,
	  H.SOLD_TO_SITE_USE_ID, M1.CUSTOMER_MERGE_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_BLANKET_HEADERS H
	WHERE H.SOLD_TO_SITE_USE_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	UNION ALL
	SELECT
	  H.HEADER_ID, H.SOLD_TO_ORG_ID, H.INVOICE_TO_ORG_ID,
	  H.SHIP_TO_ORG_ID, H.DELIVER_TO_ORG_ID,
	  H.SOLD_TO_SITE_USE_ID, M1.CUSTOMER_MERGE_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_BLANKET_HEADERS H
	WHERE H.DELIVER_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num;


  hdr_header_id_tab          num_table;
  hdr_sold_to_org_id_tab     num_table;
  hdr_invoice_to_org_id_tab  num_table;
  hdr_ship_to_org_id_tab     num_table;
  hdr_deliver_to_org_id_tab  num_table;
  hdr_sold_to_site_use_id_tab  num_table;
  old_hdr_sold_to_org_id_tab     num_table;
  old_hdr_invoice_to_org_id_tab  num_table;
  old_hdr_ship_to_org_id_tab     num_table;
  old_hdr_deliver_to_org_id_tab  num_table;
  old_hdr_sold_to_site_id_tab  num_table;

 TYPE num_table_binary_int IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 customer_id_tab        num_table_binary_int;
 customer_site_id_tab   num_table_binary_int;
 MERGE_HEADER_ID_LIST MERGE_ID_LIST_TYPE;

 l_profile_val VARCHAR2(30);
 BEGIN

 arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Blanket_Headers()+' );

 IF (process_mode = 'LOCK') THEN

   arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
   arp_message.set_token( 'TABLE_NAME', 'OE_BLANKET_HEADERS_ALL', FALSE );

   open  merge_headers;
   close merge_headers;

 ELSE

  FOR C IN MERGE_SITES LOOP
      IF c.duplicate_id IS NOT NULL
         AND NOT customer_id_tab.EXISTS(MOD(c.duplicate_id,G_BINARY_LIMIT)) THEN
         customer_id_tab(MOD(c.duplicate_id,G_BINARY_LIMIT)) := c.customer_id; --bug8541941
      END IF;

      IF c.duplicate_site_id IS NOT NULL
         AND NOT customer_site_id_tab.EXISTS(MOD(c.duplicate_site_id,G_BINARY_LIMIT)) THEN
         customer_site_id_tab(MOD(c.duplicate_site_id,G_BINARY_LIMIT)) := c.customer_site_id; --bug8541941
      END IF;

  END LOOP;

  HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
  l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

  -- Bug 7379750
  IF l_run_parallel_query = 'Y' THEN
	OPEN merge_headers_2;
  ELSE
	OPEN merge_headers_2_NP;
  END IF;

  LOOP

  -- Bug 7379750
  IF l_run_parallel_query = 'Y' THEN
     FETCH merge_headers_2
      BULK COLLECT INTO hdr_header_id_tab,
                        hdr_sold_to_org_id_tab,
                        hdr_invoice_to_org_id_tab,
                        hdr_ship_to_org_id_tab,
                        hdr_deliver_to_org_id_tab,
                        hdr_sold_to_site_use_id_tab,
			MERGE_HEADER_ID_LIST
                        LIMIT 20000;
   ELSE
     FETCH merge_headers_2_NP
      BULK COLLECT INTO hdr_header_id_tab,
                        hdr_sold_to_org_id_tab,
                        hdr_invoice_to_org_id_tab,
                        hdr_ship_to_org_id_tab,
                        hdr_deliver_to_org_id_tab,
                        hdr_sold_to_site_use_id_tab,
			MERGE_HEADER_ID_LIST
                        LIMIT 20000;
    END IF;


     old_hdr_sold_to_org_id_tab    :=  hdr_sold_to_org_id_tab;
     old_hdr_invoice_to_org_id_tab :=  hdr_invoice_to_org_id_tab;
     old_hdr_ship_to_org_id_tab    :=  hdr_ship_to_org_id_tab;
     old_hdr_deliver_to_org_id_tab :=  hdr_deliver_to_org_id_tab;
     old_hdr_sold_to_site_id_tab :=  hdr_sold_to_site_use_id_tab;

    if hdr_header_id_tab.COUNT <> 0  then
     for i in  hdr_header_id_tab.FIRST..hdr_header_id_tab.LAST LOOP

		 -- Access directly by the index position of the ids in the
	          -- values stored in customer_id_tab and customer_site_id_tab tables

	          if customer_id_tab.exists(MOD(hdr_sold_to_org_id_tab(i),G_BINARY_LIMIT)) then
	             hdr_sold_to_org_id_tab(i):= customer_id_tab(MOD(hdr_sold_to_org_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;

	          if customer_site_id_tab.exists(MOD(hdr_invoice_to_org_id_tab(i),G_BINARY_LIMIT)) then
	 	    hdr_invoice_to_org_id_tab(i):= customer_site_id_tab(MOD(hdr_invoice_to_org_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;

	          if customer_site_id_tab.exists(MOD(hdr_ship_to_org_id_tab(i),G_BINARY_LIMIT)) then
	 	    hdr_ship_to_org_id_tab(i):= customer_site_id_tab(MOD(hdr_ship_to_org_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;

	          if customer_site_id_tab.exists(MOD(hdr_deliver_to_org_id_tab(i),G_BINARY_LIMIT)) then
	 	    hdr_deliver_to_org_id_tab(i):= customer_site_id_tab(MOD(hdr_deliver_to_org_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;

		  if customer_site_id_tab.exists(MOD(hdr_sold_to_site_use_id_tab(i),G_BINARY_LIMIT)) then
		     hdr_sold_to_site_use_id_tab(i):= customer_site_id_tab(MOD(hdr_sold_to_site_use_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;

     end loop;
   end if;

   --insert audit information for customer merge
     IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	IF hdr_header_id_tab.COUNT <> 0 THEN
	forall i in  hdr_header_id_tab.FIRST..hdr_header_id_tab.LAST
	                   INSERT INTO HZ_CUSTOMER_MERGE_LOG (
				MERGE_LOG_ID,
				TABLE_NAME,
				MERGE_HEADER_ID,
				PRIMARY_KEY_ID1,
				NUM_COL1_ORIG,
				NUM_COL1_NEW,
				NUM_COL2_ORIG,
				NUM_COL2_NEW,
				NUM_COL3_ORIG,
				NUM_COL3_NEW,
				NUM_COL4_ORIG,
				NUM_COL4_NEW,
				NUM_COL5_ORIG,
				NUM_COL5_NEW,
				ACTION_FLAG,
				REQUEST_ID,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATE_LOGIN,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY
				) VALUES (
				HZ_CUSTOMER_MERGE_LOG_s.nextval,
				'OE_BLANKET_HEADERS_ALL',
				MERGE_HEADER_ID_LIST(I),
				hdr_header_id_tab(I),
				old_hdr_sold_to_org_id_tab(I),
				decode(hdr_sold_to_org_id_tab(I),NULL,old_hdr_sold_to_org_id_tab(I),hdr_sold_to_org_id_tab(i)),
				old_hdr_invoice_to_org_id_tab(I),
				decode(hdr_invoice_to_org_id_tab(I),NULL,old_hdr_invoice_to_org_id_tab(I),hdr_invoice_to_org_id_tab(i)),
				old_hdr_ship_to_org_id_tab(I),
				decode(hdr_ship_to_org_id_tab(I),NULL,old_hdr_ship_to_org_id_tab(I),hdr_ship_to_org_id_tab(i)),
				old_hdr_deliver_to_org_id_tab(I),
				decode(hdr_deliver_to_org_id_tab(I),NULL,old_hdr_deliver_to_org_id_tab(I),hdr_deliver_to_org_id_tab(i)),
				old_hdr_sold_to_site_id_tab(I),
				decode(hdr_sold_to_site_use_id_tab(I),NULL,old_hdr_sold_to_site_id_tab(I),hdr_sold_to_site_use_id_tab(i)),
				'U',
				req_id,
				hz_utility_pub.CREATED_BY,
				hz_utility_pub.CREATION_DATE,
				hz_utility_pub.LAST_UPDATE_LOGIN,
				hz_utility_pub.LAST_UPDATE_DATE,
				hz_utility_pub.LAST_UPDATED_BY
				);

		   end if;
		end if;


     arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
     arp_message.set_token( 'TABLE_NAME', 'oe_blanket_headers_all', FALSE );

    IF hdr_header_id_tab.COUNT <> 0 THEN

      FORALL i in hdr_header_id_tab.FIRST..hdr_header_id_tab.LAST
        UPDATE OE_BLANKET_HEADERS_ALL H
        SET  sold_to_org_id    	  = decode(hdr_sold_to_org_id_tab(i),null,sold_to_org_id,hdr_sold_to_org_id_tab(i)),
             invoice_to_org_id 	  = decode(hdr_invoice_to_org_id_tab(i),null,invoice_to_org_id,hdr_invoice_to_org_id_tab(i)),
            ship_to_org_id    	  = decode(hdr_ship_to_org_id_tab(i),null,ship_to_org_id,hdr_ship_to_org_id_tab(i)),
            deliver_to_org_id 	  = decode(hdr_deliver_to_org_id_tab(i),null,deliver_to_org_id,hdr_deliver_to_org_id_tab(i)),
            sold_to_site_use_id	  = decode(hdr_sold_to_site_use_id_tab(i),null,sold_to_site_use_id,hdr_sold_to_site_use_id_tab(i)),
 	   last_update_date 	  = sysdate,
 	   last_updated_by 	  = arp_standard.profile.user_id,
 	   last_update_login      = arp_standard.profile.last_update_login,
 	   request_id             = req_id,
            program_application_id = arp_standard.profile.program_application_id ,
            program_id             = arp_standard.profile.program_id,
            program_update_date    = SYSDATE,
            lock_control           = lock_control+1
        WHERE header_id = hdr_header_id_tab(i);


       g_count := sql%rowcount;
    ELSE
     g_count := 0;
    END IF;

     arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
     arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  -- Bug 7379750
     IF l_run_parallel_query = 'Y' THEN
	EXIT WHEN merge_headers_2%NOTFOUND;
     ELSE
	EXIT WHEN merge_headers_2_NP%NOTFOUND;
     END IF;


     hdr_header_id_tab.DELETE;
     hdr_sold_to_org_id_tab.DELETE;
     hdr_invoice_to_org_id_tab.DELETE;
     hdr_ship_to_org_id_tab.DELETE;
     hdr_deliver_to_org_id_tab.DELETE;
     hdr_sold_to_site_use_id_tab.DELETE;

     old_hdr_sold_to_org_id_tab.DELETE;
     old_hdr_invoice_to_org_id_tab.DELETE;
     old_hdr_ship_to_org_id_tab.DELETE;
     old_hdr_deliver_to_org_id_tab.DELETE;
     old_hdr_sold_to_site_id_tab.DELETE;

   END LOOP;  -- cursor merge_headers_2

  -- Bug 7379750
  IF l_run_parallel_query = 'Y' THEN
	CLOSE merge_headers_2;
  ELSE
	CLOSE merge_headers_2_NP;
  END IF;

 END IF;
    customer_id_tab.DELETE;
    customer_site_id_tab.DELETE;
    arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Blanket_Headers()-' );

 EXCEPTION
 when others then
 	arp_message.set_error( 'OE_CUST_MERGE.OE_Merge_Blanket_Headers-' );
    raise;

 END OE_Merge_Blanket_Headers;


/*-------------------------------------------------*/
/*--- PRIVATE Procedure OE_Merge_Blkt_Hdrs_Hist ---*/
/*-------------------------------------------------*/

Procedure OE_Merge_Blkt_Hdrs_Hist (Req_Id          IN NUMBER,
                             Set_Num         IN NUMBER,
                             Process_Mode    IN VARCHAR2)
 IS
 CURSOR c1 is
--changed for bug 3196900
    select hist.HEADER_ID
      from oe_blanket_headers_hist hist,oe_blanket_headers h
     where hist.ship_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
 --added for bug 3196900
    and hist.header_id=h.header_id
    for update nowait;


 CURSOR c2 is
--changed for bug 3196900
    select hist.HEADER_ID
      from oe_blanket_headers_hist hist,oe_blanket_headers h
     where hist.invoice_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
--changed for bug 3196900
  and hist.header_id=h.header_id
    for update nowait;


 CURSOR c3 is
--changed for bug 3196900
    select hist.HEADER_ID
      from oe_blanket_headers_hist hist, oe_blanket_headers h
     where hist.deliver_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
--added for bug 3196900
  and hist.header_id=h.header_id
    for update nowait;


 CURSOR c4 is
--changed for bug 3196900
    select hist.HEADER_ID
      from oe_blanket_headers_hist hist, oe_blanket_headers h
     where hist.sold_to_org_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
--added for bug 3196900
   and hist.header_id=h.header_id
    for update nowait;

  CURSOR c5 is
--changed for bug 3196900
    select hist.HEADER_ID
      from oe_blanket_headers_hist hist,oe_blanket_headers h
     where hist.sold_to_site_use_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
--added for bug 3196900
  and hist.header_id=h.header_id
    for update nowait;

l_profile_val VARCHAR2(30);

 BEGIN
    arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Blkt_Hdrs_Hist()+' );

    --  both customer and site level

    IF( process_mode = 'LOCK' ) THEN

      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'oe_blanket_headers_hist', FALSE );

      open c1;
      close c1;

      open c2;
      close c2;

      open c3;
      close c3;

      open c4;
      close c4;

      open c5;
      close c5;

ELSE

   HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
   l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

  IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	 insert into  HZ_CUSTOMER_MERGE_LOG (
		MERGE_LOG_ID,
		TABLE_NAME,
		MERGE_HEADER_ID,
		PRIMARY_KEY_ID1,
		PRIMARY_KEY_ID2,
		NUM_COL3_ORIG,
		NUM_COL3_NEW,
		ACTION_FLAG,
		REQUEST_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY
		)
		select
		HZ_CUSTOMER_MERGE_LOG_s.nextval,
		'OE_BLANKET_HEADERS_HIST',
		m.customer_merge_header_id,
		h.header_id,
                h.version_number,
		h.ship_to_org_id,
		m.customer_site_id,
		'U',
		req_id,
		hz_utility_pub.CREATED_BY,
		hz_utility_pub.CREATION_DATE,
		hz_utility_pub.LAST_UPDATE_LOGIN,
		hz_utility_pub.LAST_UPDATE_DATE,
		hz_utility_pub.LAST_UPDATED_BY
                from oe_blanket_headers_hist h,
		     ra_customer_merges m
               where h.ship_to_org_id=m.duplicate_site_id
                 and m.process_flag = 'N'
                 and m.request_id = req_id
                 and m.set_number = set_num;
        end if;

    -- site level update
    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_blanket_headers_hist', FALSE );

    UPDATE oe_blanket_headers_hist  a
    set ship_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.ship_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'N'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login,
          request_id = req_id,
          program_application_id =arp_standard.profile.program_application_id,
          program_id = arp_standard.profile.program_id,
          program_update_date = sysdate
    where ship_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	 insert into  HZ_CUSTOMER_MERGE_LOG (
		MERGE_LOG_ID,
		TABLE_NAME,
		MERGE_HEADER_ID,
		PRIMARY_KEY_ID1,
		PRIMARY_KEY_ID2,
		NUM_COL2_ORIG,
		NUM_COL2_NEW,
		ACTION_FLAG,
		REQUEST_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY
		)
		select
		HZ_CUSTOMER_MERGE_LOG_s.nextval,
		'OE_BLANKET_HEADERS_HIST',
		m.CUSTOMER_MERGE_HEADER_ID,
                h.version_number,
		h.header_id,
		h.invoice_to_org_id,
		m.customer_site_id,
		'U',
		req_id,
		hz_utility_pub.CREATED_BY,
		hz_utility_pub.CREATION_DATE,
		hz_utility_pub.LAST_UPDATE_LOGIN,
		hz_utility_pub.LAST_UPDATE_DATE,
		hz_utility_pub.LAST_UPDATED_BY
                from oe_blanket_headers_hist h,
		     ra_customer_merges m
               where h.invoice_to_org_id=m.duplicate_site_id
                 and m.process_flag = 'N'
                 and m.request_id = req_id
                 and m.set_number = set_num;
        end if;

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_blanket_headers_hist', FALSE );

    UPDATE oe_blanket_headers_hist  a
    set invoice_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.invoice_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'N'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login,
          request_id = req_id,
          program_application_id =arp_standard.profile.program_application_id,
          program_id = arp_standard.profile.program_id,
          program_update_date = sysdate
    where invoice_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );


      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	 insert into  HZ_CUSTOMER_MERGE_LOG (
		MERGE_LOG_ID,
		TABLE_NAME,
		MERGE_HEADER_ID,
		PRIMARY_KEY_ID1,
		PRIMARY_KEY_ID2,
		NUM_COL4_ORIG,
		NUM_COL4_NEW,
		ACTION_FLAG,
		REQUEST_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY
		)
		select
		HZ_CUSTOMER_MERGE_LOG_s.nextval,
		'OE_BLANKET_HEADERS_HIST',
		m.CUSTOMER_MERGE_HEADER_ID,
		h.header_id,
                h.version_number,
		h.deliver_to_org_id,
		m.customer_site_id,
		'U',
		req_id,
		hz_utility_pub.CREATED_BY,
		hz_utility_pub.CREATION_DATE,
		hz_utility_pub.LAST_UPDATE_LOGIN,
		hz_utility_pub.LAST_UPDATE_DATE,
		hz_utility_pub.LAST_UPDATED_BY
                from oe_blanket_headers_hist h,
		     ra_customer_merges m
               where h.deliver_to_org_id=m.duplicate_site_id
                 and m.process_flag = 'N'
                 and m.request_id = req_id
                 and m.set_number = set_num;
        end if;
    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_blanket_headers_hist', FALSE );

    UPDATE oe_blanket_headers_hist  a
    set deliver_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.deliver_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'N'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = arp_standard.profile.user_id,
          last_update_login = arp_standard.profile.last_update_login,
          request_id = req_id,
          program_application_id =arp_standard.profile.program_application_id,
          program_id = arp_standard.profile.program_id,
          program_update_date = sysdate
    where deliver_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'N'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_blanket_headers_hist', FALSE );


    IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	 insert into  HZ_CUSTOMER_MERGE_LOG (
		MERGE_LOG_ID,
		TABLE_NAME,
		MERGE_HEADER_ID,
		PRIMARY_KEY_ID1,
		PRIMARY_KEY_ID2,
		NUM_COL1_ORIG,
		NUM_COL1_NEW,
		ACTION_FLAG,
		REQUEST_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY
		)
                select
		HZ_CUSTOMER_MERGE_LOG_s.nextval,
		'OE_BLANKET_HEADERS_HIST',
		m.customer_merge_header_id,
		h.header_id,
                h.version_number,
		h.sold_to_org_id,
		m.customer_site_id,
		'U',
		req_id,
		hz_utility_pub.CREATED_BY,
		hz_utility_pub.CREATION_DATE,
		hz_utility_pub.LAST_UPDATE_LOGIN,
		hz_utility_pub.LAST_UPDATE_DATE,
		hz_utility_pub.LAST_UPDATED_BY
                from oe_blanket_headers_hist h,
		     ra_customer_merges m
               where h.sold_to_org_id=m.duplicate_site_id
                 and m.process_flag = 'N'
                 and m.request_id = req_id
                 and m.set_number = set_num;
        end if;
   -- customer level update --

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'oe_blanket_headers_hist', FALSE );

    UPDATE oe_blanket_headers_hist  a
    set    sold_to_org_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.sold_to_org_id = m.duplicate_id
                                and    m.process_flag = 'N'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where  sold_to_org_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'N'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num);

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'OE_BLANKET_HEADERS_HIST', FALSE );


    IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	 insert into  HZ_CUSTOMER_MERGE_LOG (
		MERGE_LOG_ID,
		TABLE_NAME,
		MERGE_HEADER_ID,
		PRIMARY_KEY_ID1,
		PRIMARY_KEY_ID2,
		NUM_COL5_ORIG,
		NUM_COL5_NEW,
		ACTION_FLAG,
		REQUEST_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY
		)
                select
		HZ_CUSTOMER_MERGE_LOG_s.nextval,
		'OE_BLANKET_HEADERS_HIST',
		m.customer_merge_header_id,
		h.header_id,
                h.version_number,
		h.sold_to_site_use_id,
		m.customer_site_id,
		'U',
		req_id,
		hz_utility_pub.CREATED_BY,
		hz_utility_pub.CREATION_DATE,
		hz_utility_pub.LAST_UPDATE_LOGIN,
		hz_utility_pub.LAST_UPDATE_DATE,
		hz_utility_pub.LAST_UPDATED_BY
                from oe_blanket_headers_hist h,
		     ra_customer_merges m
               where h.sold_to_org_id=m.duplicate_site_id
                 and m.process_flag = 'N'
                 and m.request_id = req_id
                 and m.set_number = set_num;
        end if;
   -- customer level update --

    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'OE_BLANKET_HEADERS_HIST', FALSE );

    UPDATE oe_blanket_headers_hist  a
    set    sold_to_site_use_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.sold_to_site_use_id = m.duplicate_id
                                and    m.process_flag = 'N'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where  sold_to_site_use_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'N'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num);

    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

    arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Blkt_Hdrs_Hist()-' );

    EXCEPTION
    When others then
      arp_message.set_error( 'OE_CUST_MERGE.OE_Merge_Blkt_Hdrs_Hist-' );
      raise;

 END OE_Merge_Blkt_Hdrs_Hist;

/*------------------------------------------------*/
/*--- PRIVATE PROCEDURE OE_Merge_Blanket_Lines         ---*/
/*------------------------------------------------*/

 Procedure OE_Merge_Blanket_Lines (Req_Id          IN NUMBER,
                             Set_Num         IN NUMBER,
                             Process_Mode    IN VARCHAR2)
 IS

 CURSOR MERGE_SITES IS
    select duplicate_id, customer_id, duplicate_site_id, customer_site_id
      from ra_customer_merges m
      where m.process_flag = 'N'
      and m.request_id = req_id
     and m.set_number = set_num;

 CURSOR MERGE_LINES IS
 SELECT /*+ PARALLEL(L)
            PARALLEL(M1)
            PARALLEL(M2)
            PARALLEL(M3)
            PARALLEL(M4)
            PARALLEL(M5) */
  l.line_id ,
  sold_to_org_id,
  invoice_to_org_id,
  ship_to_org_id,
  intmed_ship_to_org_id,
  deliver_to_org_id,
  nvl(m1.customer_merge_id,nvl(m2.customer_merge_id,nvl(m3.customer_merge_id,nvl(m4.customer_merge_id,m5.customer_merge_id))))
 FROM RA_CUSTOMER_MERGES M1,
      RA_CUSTOMER_MERGES M2,
      RA_CUSTOMER_MERGES M3,
      RA_CUSTOMER_MERGES M4,
      RA_CUSTOMER_MERGES M5,
-- changed for bug 3196900
--      OE_BLANKET_LINES_ALL L
      OE_BLANKET_LINES L
 WHERE
     ( l.sold_to_org_id        = m1.duplicate_id(+)
   and l.invoice_to_org_id     = m2.duplicate_site_id(+)
   and l.ship_to_org_id        = m3.duplicate_site_id(+)
   and l.intmed_ship_to_org_id = m4.duplicate_site_id(+)
   and l.deliver_to_org_id     = m5.duplicate_site_id(+) )
   and
   (m1.duplicate_site_id is not null or
    m2.duplicate_id is not null or
    m3.duplicate_id is not null or
    m4.duplicate_id is not null or
    m5.duplicate_id is not null )
   and m1.process_flag(+) = 'N'
   and m2.process_flag(+) = 'N'
   and m3.process_flag(+) = 'N'
   and m4.process_flag(+) = 'N'
   and m5.process_flag(+) = 'N'
   and m1.request_id(+) =req_id
   and m2.request_id(+) =req_id
   and m3.request_id(+) =req_id
   and m4.request_id(+) =req_id
   and m5.request_id(+) =req_id
   and m1.set_number(+) =set_num
   and m2.set_number(+) =set_num
   and m3.set_number(+) =set_num
   and m4.set_number(+) =set_num
   and m5.set_number(+) =set_num
 for update nowait;


 CURSOR MERGE_LINES_2 IS
 SELECT /*+ PARALLEL(L)
            PARALLEL(M1)
            PARALLEL(M2)
            PARALLEL(M3)
            PARALLEL(M4)
            PARALLEL(M5) */
  l.line_id ,
  sold_to_org_id,
  invoice_to_org_id,
  ship_to_org_id,
  intmed_ship_to_org_id,
  deliver_to_org_id,
  nvl(m1.customer_merge_id,nvl(m2.customer_merge_id,nvl(m3.customer_merge_id,nvl(m4.customer_merge_id,m5.customer_merge_id))))
 FROM RA_CUSTOMER_MERGES M1,
      RA_CUSTOMER_MERGES M2,
      RA_CUSTOMER_MERGES M3,
      RA_CUSTOMER_MERGES M4,
      RA_CUSTOMER_MERGES M5,
--changed for bug 3196900
--      OE_BLANKET_LINES_ALL L
      OE_BLANKET_LINES L
 WHERE
     ( l.sold_to_org_id        = m1.duplicate_id(+)
   and l.invoice_to_org_id     = m2.duplicate_site_id(+)
   and l.ship_to_org_id        = m3.duplicate_site_id(+)
   and l.intmed_ship_to_org_id = m4.duplicate_site_id(+)
   and l.deliver_to_org_id     = m5.duplicate_site_id(+) )
   and
   (m1.duplicate_site_id is not null or
    m2.duplicate_id is not null or
    m3.duplicate_id is not null or
    m4.duplicate_id is not null or
    m5.duplicate_id is not null )
   and m1.process_flag(+) = 'N'
   and m2.process_flag(+) = 'N'
   and m3.process_flag(+) = 'N'
   and m4.process_flag(+) = 'N'
   and m5.process_flag(+) = 'N'
   and m1.request_id(+) =req_id
   and m2.request_id(+) =req_id
   and m3.request_id(+) =req_id
   and m4.request_id(+) =req_id
   and m5.request_id(+) =req_id
   and m1.set_number(+) =set_num
   and m2.set_number(+) =set_num
   and m3.set_number(+) =set_num
   and m4.set_number(+) =set_num
   and m5.set_number(+) =set_num;


       CURSOR MERGE_LINES_2_NP IS
	SELECT
	  L.LINE_ID, SOLD_TO_ORG_ID,
	  INVOICE_TO_ORG_ID, SHIP_TO_ORG_ID,
	  INTMED_SHIP_TO_ORG_ID, DELIVER_TO_ORG_ID,
	  M1.CUSTOMER_MERGE_ID
	FROM
	OE_CUST_MERGES_GTT M1, OE_BLANKET_LINES L
	WHERE L.SOLD_TO_ORG_ID = M1.DUPLICATE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	UNION ALL
	SELECT
	  L.LINE_ID, SOLD_TO_ORG_ID,
	  INVOICE_TO_ORG_ID, SHIP_TO_ORG_ID,
	  INTMED_SHIP_TO_ORG_ID, DELIVER_TO_ORG_ID,
	  M1.CUSTOMER_MERGE_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_BLANKET_LINES L
	WHERE L.INVOICE_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	UNION ALL
	SELECT
	  L.LINE_ID, SOLD_TO_ORG_ID,
	  INVOICE_TO_ORG_ID, SHIP_TO_ORG_ID,
	  INTMED_SHIP_TO_ORG_ID, DELIVER_TO_ORG_ID,
	  M1.CUSTOMER_MERGE_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_BLANKET_LINES L
	WHERE L.SHIP_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	UNION ALL
	SELECT
	  L.LINE_ID, SOLD_TO_ORG_ID,
	  INVOICE_TO_ORG_ID, SHIP_TO_ORG_ID,
	  INTMED_SHIP_TO_ORG_ID, DELIVER_TO_ORG_ID,
	  M1.CUSTOMER_MERGE_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_BLANKET_LINES L
	WHERE L.INTMED_SHIP_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	UNION ALL
	SELECT
	  L.LINE_ID, SOLD_TO_ORG_ID,
	  INVOICE_TO_ORG_ID, SHIP_TO_ORG_ID,
	  INTMED_SHIP_TO_ORG_ID, DELIVER_TO_ORG_ID,
	  M1.CUSTOMER_MERGE_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_BLANKET_LINES L
	WHERE L.DELIVER_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num;



  line_line_id_tab	             num_table;
  line_sold_to_org_id_tab            num_table;
  line_invoice_to_org_id_tab         num_table;
  line_ship_to_org_id_tab            num_table;
  line_intmed_ship_to_org_id_tab     num_table;
  line_deliver_to_org_id_tab         num_table;

  old_line_sold_to_org_id_tab        num_table;
  old_line_invoice_to_org_id_tab     num_table;
  old_line_ship_to_org_id_tab        num_table;
  old_intmed_ship_to_org_id_tab      num_table;
  old_line_deliver_to_org_id_tab     num_table;

  MERGE_HEADER_ID_LIST MERGE_ID_LIST_TYPE;
  l_profile_val VARCHAR2(30);

  TYPE num_table_binary_int IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   customer_id_tab        num_table_binary_int;
   customer_site_id_tab   num_table_binary_int;

 BEGIN

 arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Blanket_Lines()+' );

 IF (process_mode = 'LOCK') THEN

   arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
   arp_message.set_token( 'TABLE_NAME', 'oe_blanket_lines_all', FALSE );

   open  merge_lines;
   close merge_lines;

 ELSE

   FOR C IN MERGE_SITES LOOP
         IF c.duplicate_id IS NOT NULL
            AND NOT customer_id_tab.EXISTS(MOD(c.duplicate_id,G_BINARY_LIMIT)) THEN
            customer_id_tab(MOD(c.duplicate_id,G_BINARY_LIMIT)) := c.customer_id; --bug8541941
         END IF;

         IF c.duplicate_site_id IS NOT NULL
            AND NOT customer_site_id_tab.EXISTS(MOD(c.duplicate_site_id,G_BINARY_LIMIT)) THEN
            customer_site_id_tab(MOD(c.duplicate_site_id,G_BINARY_LIMIT)) := c.customer_site_id; --bug8541941
         END IF;

  END LOOP;


  HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
  l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

  -- Bug 7379750
   IF l_run_parallel_query = 'Y' THEN
	OPEN merge_lines_2;
   ELSE
	OPEN merge_lines_2_NP;
   END IF;

   LOOP

  -- Bug 7379750
   IF l_run_parallel_query = 'Y' THEN
     FETCH merge_lines_2
      BULK COLLECT INTO line_line_id_tab,
                        line_sold_to_org_id_tab,
                        line_invoice_to_org_id_tab,
                        line_ship_to_org_id_tab,
                        line_intmed_ship_to_org_id_tab,
                        line_deliver_to_org_id_tab,
			MERGE_HEADER_ID_LIST
                        LIMIT 20000;
     ELSE
     FETCH merge_lines_2_NP
      BULK COLLECT INTO line_line_id_tab,
                        line_sold_to_org_id_tab,
                        line_invoice_to_org_id_tab,
                        line_ship_to_org_id_tab,
                        line_intmed_ship_to_org_id_tab,
                        line_deliver_to_org_id_tab,
			MERGE_HEADER_ID_LIST
                        LIMIT 20000;
      END IF;



     old_intmed_ship_to_org_id_tab      := line_intmed_ship_to_org_id_tab;
     old_line_sold_to_org_id_tab        := line_sold_to_org_id_tab;
     old_line_invoice_to_org_id_tab     := line_invoice_to_org_id_tab;
     old_line_ship_to_org_id_tab        := line_ship_to_org_id_tab;
     old_line_deliver_to_org_id_tab     := line_deliver_to_org_id_tab;

    if line_line_id_tab.COUNT <> 0 then
    for i in  line_line_id_tab.FIRST..line_line_id_tab.LAST LOOP

	   -- Access directly by the index position of the ids in the
	   -- values stored in customer_id_tab and customer_site_id_tab tables

	          if customer_id_tab.exists(MOD(line_sold_to_org_id_tab(i),G_BINARY_LIMIT)) then
	             line_sold_to_org_id_tab(i):= customer_id_tab(MOD(line_sold_to_org_id_tab(i),G_BINARY_LIMIT));
	          end if;

	          if customer_site_id_tab.exists(MOD(line_invoice_to_org_id_tab(i),G_BINARY_LIMIT)) then
	 	        line_invoice_to_org_id_tab(i):= customer_site_id_tab(MOD(line_invoice_to_org_id_tab(i),G_BINARY_LIMIT));
	          end if;

	          if customer_site_id_tab.exists(MOD(line_ship_to_org_id_tab(i),G_BINARY_LIMIT)) then
	 	       line_ship_to_org_id_tab(i):= customer_site_id_tab(MOD(line_ship_to_org_id_tab(i),G_BINARY_LIMIT));
	          end if;

	          if customer_site_id_tab.exists(MOD(line_intmed_ship_to_org_id_tab(i),G_BINARY_LIMIT)) then
			  	line_intmed_ship_to_org_id_tab(i):= customer_site_id_tab(MOD(line_intmed_ship_to_org_id_tab(i),G_BINARY_LIMIT));
	          end if;

	          if customer_site_id_tab.exists(MOD(line_deliver_to_org_id_tab(i),G_BINARY_LIMIT)) then
	 	        line_deliver_to_org_id_tab(i):= customer_site_id_tab(MOD(line_deliver_to_org_id_tab(i),G_BINARY_LIMIT));
	          end if;


     end loop;
     end if;

     IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	IF line_line_id_tab.COUNT <> 0 THEN
	   forall i in  line_line_id_tab.FIRST..line_line_id_tab.LAST
	   --insert audit information for customer merge
	                   INSERT INTO HZ_CUSTOMER_MERGE_LOG (
				MERGE_LOG_ID,
				TABLE_NAME,
				MERGE_HEADER_ID,
				PRIMARY_KEY_ID1,
				NUM_COL1_ORIG,
				NUM_COL1_NEW,
				NUM_COL2_ORIG,
				NUM_COL2_NEW,
				NUM_COL3_ORIG,
				NUM_COL3_NEW,
				NUM_COL4_ORIG,
				NUM_COL4_NEW,
				ACTION_FLAG,
				REQUEST_ID,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATE_LOGIN,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY
				) VALUES (
				HZ_CUSTOMER_MERGE_LOG_s.nextval,
				'OE_BLANKET_LINES_ALL',
				MERGE_HEADER_ID_LIST(I),
				line_line_id_tab(I),
				line_sold_to_org_id_tab(I),
				decode(line_sold_to_org_id_tab(I),NULL,old_line_sold_to_org_id_tab(I),line_sold_to_org_id_tab(i)),
				line_invoice_to_org_id_tab(I),
				decode(line_invoice_to_org_id_tab(I),NULL,old_line_invoice_to_org_id_tab(I),line_invoice_to_org_id_tab(i)),
				line_ship_to_org_id_tab(I),
				decode(line_ship_to_org_id_tab(I),NULL,old_line_ship_to_org_id_tab(I),line_ship_to_org_id_tab(i)),
				line_deliver_to_org_id_tab(I),
				decode(line_deliver_to_org_id_tab(I),NULL,old_line_deliver_to_org_id_tab(I),line_deliver_to_org_id_tab(i)),
				'U',
				req_id,
				hz_utility_pub.CREATED_BY,
				hz_utility_pub.CREATION_DATE,
				hz_utility_pub.LAST_UPDATE_LOGIN,
				hz_utility_pub.LAST_UPDATE_DATE,
				hz_utility_pub.LAST_UPDATED_BY
				);

			  end if;
		       end if;

     arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
     arp_message.set_token( 'TABLE_NAME', 'oe_blanket_lines_all', FALSE );

    IF line_line_id_tab.COUNT <> 0 THEN
      FORALL i in line_line_id_tab.FIRST..line_line_id_tab.LAST
        UPDATE OE_BLANKET_LINES_ALL L
        SET  sold_to_org_id    	  = decode(line_sold_to_org_id_tab(i),null,sold_to_org_id,line_sold_to_org_id_tab(i)),
            invoice_to_org_id 	  = decode(line_invoice_to_org_id_tab(i),null,invoice_to_org_id,line_invoice_to_org_id_tab(i)),
            ship_to_org_id    	  = decode(line_ship_to_org_id_tab(i),null,ship_to_org_id,line_ship_to_org_id_tab(i)),
            intmed_ship_to_org_id  = decode(line_intmed_ship_to_org_id_tab(i),null,intmed_ship_to_org_id,line_intmed_ship_to_org_id_tab(i)),
            deliver_to_org_id 	  = decode(line_deliver_to_org_id_tab(i),null,deliver_to_org_id,line_deliver_to_org_id_tab(i)),
 	    last_update_date 	  = sysdate,
 	    last_updated_by 	  = arp_standard.profile.user_id,
 	    last_update_login      = arp_standard.profile.last_update_login,
 	    request_id             = req_id,
            program_application_id = arp_standard.profile.program_application_id ,
            program_id             = arp_standard.profile.program_id,
            program_update_date    = SYSDATE,
            lock_control           = lock_control+1
        WHERE line_id = line_line_id_tab(i);

        g_count := sql%rowcount;

     ELSE
       g_count := 0;
     END IF;

     arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
     arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

  -- Bug 7379750
     IF l_run_parallel_query = 'Y' THEN
	EXIT WHEN merge_lines_2%NOTFOUND;
     ELSE
	EXIT WHEN merge_lines_2_NP%NOTFOUND;
     END IF;


     line_line_id_tab.DELETE;
     line_sold_to_org_id_tab.DELETE;
     line_invoice_to_org_id_tab.DELETE;
     line_ship_to_org_id_tab.DELETE;
     line_intmed_ship_to_org_id_tab.DELETE;
     line_deliver_to_org_id_tab.DELETE;

     old_line_sold_to_org_id_tab.DELETE;
     old_line_invoice_to_org_id_tab.DELETE;
     old_line_ship_to_org_id_tab.DELETE;
     old_intmed_ship_to_org_id_tab.DELETE;
     old_line_deliver_to_org_id_tab.DELETE;

   END LOOP;  -- cursor merge_lines_2
  -- Bug 7379750
   IF l_run_parallel_query = 'Y' THEN
	CLOSE merge_lines_2;
   ELSE
	CLOSE merge_lines_2_NP;
   END IF;
 END IF;
    customer_id_tab.DELETE;
    customer_site_id_tab.DELETE;
    arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Blanket_Lines()-' );

 EXCEPTION
 when others then
 	arp_message.set_error( 'OE_CUST_MERGE.OE_Merge_Blanket_Lines-' );
    raise;

 END OE_Merge_Blanket_Lines;

/*-------------------------------------------------*/
/*--- PRIVATE PROCEDURE OE_Merge_Blkt_Lines_Hist  ---*/
/*-------------------------------------------------*/

 Procedure OE_Merge_Blkt_Lines_Hist (Req_Id          IN NUMBER,
                                   Set_Num         IN NUMBER,
                                   Process_Mode    IN VARCHAR2)
 IS

 CURSOR MERGE_SITES IS
     select duplicate_id, customer_id, duplicate_site_id, customer_site_id
       from ra_customer_merges m
       where m.process_flag = 'N'
       and m.request_id = req_id
     and m.set_number = set_num;
 /* MOAC_SQL_CHANGE */
 CURSOR MERGE_LINES_HISTORY IS
 SELECT /*+ PARALLEL(L)
            PARALLEL(M1)
            PARALLEL(M2)
            PARALLEL(M3)
            PARALLEL(M4)
            PARALLEL(M5) */
  l.line_id ,
--changed for bug 3196900 , added l. for all the attributes
  l.sold_to_org_id,
  l.invoice_to_org_id,
  l.ship_to_org_id,
  l.intmed_ship_to_org_id,
  l.deliver_to_org_id,
  l.version_number,
 nvl(m1.customer_merge_id,nvl(m2.customer_merge_id,nvl(m3.customer_merge_id,nvl(m4.customer_merge_id,m5.customer_merge_id))))
 FROM RA_CUSTOMER_MERGES M1,
      RA_CUSTOMER_MERGES M2,
      RA_CUSTOMER_MERGES M3,
      RA_CUSTOMER_MERGES M4,
      RA_CUSTOMER_MERGES M5,
--changed for bug 3196900
--      OE_BLANKET_LINES_HIST L
      OE_BLANKET_LINES_HIST L , OE_BLANKET_LINES_ALL LN
  -- Changed for MOAC
 WHERE
     ( l.sold_to_org_id        = m1.duplicate_id(+)
   and l.invoice_to_org_id     = m2.duplicate_site_id(+)
   and l.ship_to_org_id        = m3.duplicate_site_id(+)
   and l.intmed_ship_to_org_id = m4.duplicate_site_id(+)
   and l.deliver_to_org_id     = m5.duplicate_site_id(+) )
   and
   (m1.duplicate_site_id is not null or
    m2.duplicate_id is not null or
    m3.duplicate_id is not null or
    m4.duplicate_id is not null or
    m5.duplicate_id is not null )
   and m1.process_flag(+) = 'N'
   and m2.process_flag(+) = 'N'
   and m3.process_flag(+) = 'N'
   and m4.process_flag(+) = 'N'
   and m5.process_flag(+) = 'N'
   and m1.request_id(+) =req_id
   and m2.request_id(+) =req_id
   and m3.request_id(+) =req_id
   and m4.request_id(+) =req_id
   and m5.request_id(+) =req_id
   and m1.set_number(+) =set_num
   and m2.set_number(+) =set_num
   and m3.set_number(+) =set_num
   and m4.set_number(+) =set_num
   and m5.set_number(+) =set_num
--added for bug 3196900
   and l.line_id=ln.line_id
 for update nowait;

 /* MOAC_SQL_CHANGE */
 CURSOR MERGE_LINES_HISTORY_2 IS
 SELECT /*+ PARALLEL(L)
            PARALLEL(M1)
            PARALLEL(M2)
            PARALLEL(M3)
            PARALLEL(M4)
            PARALLEL(M5) */
  l.line_id ,
--changed for bug 3196900, added l. for all the attributes
  l.sold_to_org_id,
  l.invoice_to_org_id,
  l.ship_to_org_id,
  l.intmed_ship_to_org_id,
  l.deliver_to_org_id,
  l.version_number,
  nvl(m1.customer_merge_id,nvl(m2.customer_merge_id,nvl(m3.customer_merge_id,nvl(m4.customer_merge_id,m5.customer_merge_id))))
 FROM RA_CUSTOMER_MERGES M1,
      RA_CUSTOMER_MERGES M2,
      RA_CUSTOMER_MERGES M3,
      RA_CUSTOMER_MERGES M4,
      RA_CUSTOMER_MERGES M5,
--changed for bug 3196900
--      OE_BLANKET_LINES_HIST L
      OE_BLANKET_LINES_HIST L , OE_BLANKET_LINES_all LN
   -- Changed for MOAC
 WHERE
     ( l.sold_to_org_id        = m1.duplicate_id(+)
   and l.invoice_to_org_id     = m2.duplicate_site_id(+)
   and l.ship_to_org_id        = m3.duplicate_site_id(+)
   and l.intmed_ship_to_org_id = m4.duplicate_site_id(+)
   and l.deliver_to_org_id     = m5.duplicate_site_id(+) )
   and
   (m1.duplicate_site_id is not null or
    m2.duplicate_id is not null or
    m3.duplicate_id is not null or
    m4.duplicate_id is not null or
    m5.duplicate_id is not null )
   and m1.process_flag(+) = 'N'
   and m2.process_flag(+) = 'N'
   and m3.process_flag(+) = 'N'
   and m4.process_flag(+) = 'N'
   and m5.process_flag(+) = 'N'
   and m1.request_id(+) =req_id
   and m2.request_id(+) =req_id
   and m3.request_id(+) =req_id
   and m4.request_id(+) =req_id
   and m5.request_id(+) =req_id
   and m1.set_number(+) =set_num
   and m2.set_number(+) =set_num
   and m3.set_number(+) =set_num
   and m4.set_number(+) =set_num
   and m5.set_number(+) =set_num
--added for bug 3196900
   and l.line_id=ln.line_id;


 CURSOR MERGE_LINES_HISTORY_2_NP IS
        SELECT	L.LINE_ID , L.SOLD_TO_ORG_ID, L.INVOICE_TO_ORG_ID,
		L.SHIP_TO_ORG_ID, L.INTMED_SHIP_TO_ORG_ID, L.DELIVER_TO_ORG_ID,
		L.VERSION_NUMBER, M1.CUSTOMER_MERGE_ID
	FROM
	OE_CUST_MERGES_GTT M1, OE_BLANKET_LINES_HIST L , OE_BLANKET_LINES_all LN
	WHERE L.SOLD_TO_ORG_ID = M1.DUPLICATE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	AND L.LINE_ID=LN.LINE_ID
	UNION ALL
        SELECT	L.LINE_ID , L.SOLD_TO_ORG_ID, L.INVOICE_TO_ORG_ID,
		L.SHIP_TO_ORG_ID, L.INTMED_SHIP_TO_ORG_ID, L.DELIVER_TO_ORG_ID,
		L.VERSION_NUMBER, M1.CUSTOMER_MERGE_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_BLANKET_LINES_HIST L , OE_BLANKET_LINES_all LN
	WHERE L.INVOICE_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	AND L.LINE_ID=LN.LINE_ID
	UNION ALL
        SELECT	L.LINE_ID , L.SOLD_TO_ORG_ID, L.INVOICE_TO_ORG_ID,
		L.SHIP_TO_ORG_ID, L.INTMED_SHIP_TO_ORG_ID, L.DELIVER_TO_ORG_ID,
		L.VERSION_NUMBER, M1.CUSTOMER_MERGE_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_BLANKET_LINES_HIST L , OE_BLANKET_LINES_all LN
	WHERE L.SHIP_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	AND L.LINE_ID=LN.LINE_ID
	UNION ALL
        SELECT	L.LINE_ID , L.SOLD_TO_ORG_ID, L.INVOICE_TO_ORG_ID,
		L.SHIP_TO_ORG_ID, L.INTMED_SHIP_TO_ORG_ID, L.DELIVER_TO_ORG_ID,
		L.VERSION_NUMBER, M1.CUSTOMER_MERGE_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_BLANKET_LINES_HIST L , OE_BLANKET_LINES_all LN
	WHERE L.INTMED_SHIP_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	AND L.LINE_ID=LN.LINE_ID
	UNION ALL
        SELECT	L.LINE_ID , L.SOLD_TO_ORG_ID, L.INVOICE_TO_ORG_ID,
		L.SHIP_TO_ORG_ID, L.INTMED_SHIP_TO_ORG_ID, L.DELIVER_TO_ORG_ID,
		L.VERSION_NUMBER, M1.CUSTOMER_MERGE_ID
	FROM
	RA_CUSTOMER_MERGES M1, OE_BLANKET_LINES_HIST L , OE_BLANKET_LINES_all LN
	WHERE L.DELIVER_TO_ORG_ID= M1.DUPLICATE_SITE_ID
	AND M1.PROCESS_FLAG='N'
	AND M1.REQUEST_ID = req_id
	AND M1.SET_NUMBER = set_num
	AND L.LINE_ID=LN.LINE_ID;



  lhst_line_id_tab	      num_table;
  lhst_sold_to_org_id_tab     num_table;
  lhst_invoice_to_org_id_tab  num_table;
  lhst_ship_to_org_id_tab     num_table;
  lhst_intmed_ship_to_org_id_tab     num_table;
  lhst_deliver_to_org_id_tab  num_table;
  lhst_version_number_tab     num_table;

  old_lhst_sold_to_org_id_tab            num_table;
  old_lhst_invoice_to_org_id_tab         num_table;
  old_lhst_ship_to_org_id_tab            num_table;
  old_intmed_ship_to_org_id_tab          num_table;
  old_lhst_deliver_to_org_id_tab         num_table;

  TYPE num_table_binary_int IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  customer_id_tab        num_table_binary_int;
  customer_site_id_tab   num_table_binary_int;

  MERGE_HEADER_ID_LIST MERGE_ID_LIST_TYPE;
  l_profile_val VARCHAR2(30);

 BEGIN

 arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Blkt_Lines_Hist()+' );

 IF (process_mode = 'LOCK') THEN

   arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
   arp_message.set_token( 'TABLE_NAME', 'oe_blanket_lines_hist', FALSE );

   open  merge_lines_history;
   close merge_lines_history;

 ELSE

FOR C IN MERGE_SITES LOOP
          IF c.duplicate_id IS NOT NULL
             AND NOT customer_id_tab.EXISTS(MOD(c.duplicate_id,G_BINARY_LIMIT)) THEN
             customer_id_tab(MOD(c.duplicate_id,G_BINARY_LIMIT)) := c.customer_id; --bug8541941
          END IF;

          IF c.duplicate_site_id IS NOT NULL
             AND NOT customer_site_id_tab.EXISTS(MOD(c.duplicate_site_id,G_BINARY_LIMIT)) THEN
             customer_site_id_tab(MOD(c.duplicate_site_id,G_BINARY_LIMIT)) := c.customer_site_id; --bug8541941
          END IF;

  END LOOP;


  HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
  l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

  -- Bug 7379750
   IF l_run_parallel_query = 'Y' THEN
	OPEN merge_lines_history_2;
   ELSE
	OPEN merge_lines_history_2_NP;
   END IF;

   LOOP

  -- Bug 7379750
   IF l_run_parallel_query = 'Y' THEN
     FETCH merge_lines_history_2
      BULK COLLECT INTO lhst_line_id_tab,
                        lhst_sold_to_org_id_tab,
                        lhst_invoice_to_org_id_tab,
                        lhst_ship_to_org_id_tab,
                        lhst_intmed_ship_to_org_id_tab,
                        lhst_deliver_to_org_id_tab,
			lhst_version_number_tab,
			MERGE_HEADER_ID_LIST
                        LIMIT 20000;
     ELSE
     FETCH merge_lines_history_2_NP
      BULK COLLECT INTO lhst_line_id_tab,
                        lhst_sold_to_org_id_tab,
                        lhst_invoice_to_org_id_tab,
                        lhst_ship_to_org_id_tab,
                        lhst_intmed_ship_to_org_id_tab,
                        lhst_deliver_to_org_id_tab,
			lhst_version_number_tab,
			MERGE_HEADER_ID_LIST
                        LIMIT 20000;
     END IF;

     old_intmed_ship_to_org_id_tab := lhst_intmed_ship_to_org_id_tab;
     old_lhst_sold_to_org_id_tab        := lhst_sold_to_org_id_tab;
     old_lhst_invoice_to_org_id_tab     := lhst_invoice_to_org_id_tab;
     old_lhst_ship_to_org_id_tab        := lhst_ship_to_org_id_tab;
     old_lhst_deliver_to_org_id_tab     := lhst_deliver_to_org_id_tab;

      if lhst_line_id_tab.COUNT <> 0 then
       for i in  lhst_line_id_tab.FIRST..lhst_line_id_tab.LAST LOOP

		 -- Access directly by the index position of the ids in the
	          -- values stored in customer_id_tab and customer_site_id_tab tables

	          if customer_id_tab.exists(MOD(lhst_sold_to_org_id_tab(i),G_BINARY_LIMIT)) then
	             lhst_sold_to_org_id_tab(i):= customer_id_tab(MOD(lhst_sold_to_org_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;

	          if customer_site_id_tab.exists(MOD(lhst_invoice_to_org_id_tab(i),G_BINARY_LIMIT)) then
	 	        lhst_invoice_to_org_id_tab(i):= customer_site_id_tab(MOD(lhst_invoice_to_org_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;

	          if customer_site_id_tab.exists(MOD(lhst_ship_to_org_id_tab(i),G_BINARY_LIMIT)) then
	 	       lhst_ship_to_org_id_tab(i):= customer_site_id_tab(MOD(lhst_ship_to_org_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;

	          if customer_site_id_tab.exists(MOD(lhst_intmed_ship_to_org_id_tab(i),G_BINARY_LIMIT)) then
		  	lhst_intmed_ship_to_org_id_tab(i):= customer_site_id_tab(MOD(lhst_intmed_ship_to_org_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;

	          if customer_site_id_tab.exists(MOD(lhst_deliver_to_org_id_tab(i),G_BINARY_LIMIT)) then
	 	        lhst_deliver_to_org_id_tab(i):= customer_site_id_tab(MOD(lhst_deliver_to_org_id_tab(i),G_BINARY_LIMIT));--bug8541941
	          end if;


     end loop;
     end if;

     --insert audit information for customer merge
     IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
	IF lhst_line_id_tab.COUNT <> 0 THEN
	     forall i in  lhst_line_id_tab.FIRST..lhst_line_id_tab.LAST
	                   INSERT INTO HZ_CUSTOMER_MERGE_LOG (
				MERGE_LOG_ID,
				TABLE_NAME,
				MERGE_HEADER_ID,
				PRIMARY_KEY_ID1,
				PRIMARY_KEY_ID2,
				NUM_COL1_ORIG,
				NUM_COL1_NEW,
				NUM_COL2_ORIG,
				NUM_COL2_NEW,
				NUM_COL3_ORIG,
				NUM_COL3_NEW,
				NUM_COL4_ORIG,
				NUM_COL4_NEW,
				ACTION_FLAG,
				REQUEST_ID,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATE_LOGIN,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY
				) VALUES (
				HZ_CUSTOMER_MERGE_LOG_s.nextval,
				'OE_BLANKET_LINES_HIST',
				MERGE_HEADER_ID_LIST(I),
				lhst_line_id_tab(I),
				lhst_version_number_tab(I),
				lhst_sold_to_org_id_tab(I),
				decode(lhst_sold_to_org_id_tab(I),NULL,old_lhst_sold_to_org_id_tab(I),lhst_sold_to_org_id_tab(i)),
				lhst_invoice_to_org_id_tab(I),
				decode(lhst_invoice_to_org_id_tab(I),NULL,old_lhst_invoice_to_org_id_tab(I),lhst_invoice_to_org_id_tab(i)),
				lhst_ship_to_org_id_tab(I),
				decode(lhst_ship_to_org_id_tab(I),NULL,old_lhst_ship_to_org_id_tab(I),lhst_ship_to_org_id_tab(i)),
				lhst_deliver_to_org_id_tab(I),
				decode(lhst_deliver_to_org_id_tab(I),NULL,old_lhst_deliver_to_org_id_tab(I),lhst_deliver_to_org_id_tab(i)),
				'U',
				req_id,
				hz_utility_pub.CREATED_BY,
				hz_utility_pub.CREATION_DATE,
				hz_utility_pub.LAST_UPDATE_LOGIN,
				hz_utility_pub.LAST_UPDATE_DATE,
				hz_utility_pub.LAST_UPDATED_BY
				);

		   end if;
		end if;

     arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
     arp_message.set_token( 'TABLE_NAME', 'oe_blanket_lines_hist', FALSE );

    IF lhst_line_id_tab.COUNT <> 0 THEN
     FORALL i in lhst_line_id_tab.FIRST..lhst_line_id_tab.LAST
       UPDATE OE_BLANKET_LINES_HIST LHIST
       SET  sold_to_org_id    	  = decode(lhst_sold_to_org_id_tab(i),null,sold_to_org_id,lhst_sold_to_org_id_tab(i)),
            invoice_to_org_id 	  = decode(lhst_invoice_to_org_id_tab(i),null,invoice_to_org_id,lhst_invoice_to_org_id_tab(i)),
            ship_to_org_id    	  = decode(lhst_ship_to_org_id_tab(i),null,ship_to_org_id,lhst_ship_to_org_id_tab(i)),
            intmed_ship_to_org_id  = decode(lhst_intmed_ship_to_org_id_tab(i),null,intmed_ship_to_org_id,lhst_intmed_ship_to_org_id_tab(i)),
            deliver_to_org_id 	  = decode(lhst_deliver_to_org_id_tab(i),null,deliver_to_org_id,lhst_deliver_to_org_id_tab(i)),
 	   last_update_date 	  = sysdate,
 	   last_updated_by 	  = arp_standard.profile.user_id,
 	   last_update_login      = arp_standard.profile.last_update_login,
 	   request_id             = req_id,
            program_application_id = arp_standard.profile.program_application_id ,
            program_id             = arp_standard.profile.program_id,
            program_update_date    = SYSDATE
        WHERE line_id = lhst_line_id_tab(i);

     g_count := sql%rowcount;

    ELSE
      g_count := 0;
    END IF;

     arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
     arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

  -- Bug 7379750
     IF l_run_parallel_query = 'Y' THEN
	EXIT WHEN merge_lines_history_2%NOTFOUND;
     ELSE
	EXIT WHEN merge_lines_history_2_NP%NOTFOUND;
     END IF;



     lhst_line_id_tab.DELETE;
     lhst_sold_to_org_id_tab.DELETE;
     lhst_invoice_to_org_id_tab.DELETE;
     lhst_ship_to_org_id_tab.DELETE;
     lhst_intmed_ship_to_org_id_tab.DELETE;
     lhst_deliver_to_org_id_tab.DELETE;
     lhst_version_number_tab.DELETE;

     old_lhst_sold_to_org_id_tab.DELETE;
     old_lhst_invoice_to_org_id_tab.DELETE;
     old_lhst_ship_to_org_id_tab.DELETE;
     old_intmed_ship_to_org_id_tab.DELETE;
     old_lhst_deliver_to_org_id_tab.DELETE;

   END LOOP;  -- cursor merge_lines_history_2

  -- Bug 7379750
   IF l_run_parallel_query = 'Y' THEN
	CLOSE merge_lines_history_2;
   ELSE
	CLOSE merge_lines_history_2_NP;
   END IF;

 END IF;
    customer_id_tab.DELETE;
    customer_site_id_tab.DELETE;
    arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_Blkt_Lines_Hist()-' );

 EXCEPTION
 when others then
 	arp_message.set_error( 'OE_CUST_MERGE.OE_Merge_Blkt_Lines_Hist-' );
     raise;

 END OE_Merge_Blkt_Lines_Hist;


/*-------------------------------------------------------*/
/*--- PRIVATE PROCEDURE OE_Merge_OI_Tracking */
/*-------------------------------------------------------*/


 Procedure OE_Merge_OI_Tracking (Req_Id          IN NUMBER,
                                 Set_Num         IN NUMBER,
                                 Process_Mode    IN VARCHAR2)
 IS

 CURSOR c1 is
    select header_id
--changed for bug 3196900
--      from OE_EM_INFORMATION_ALL
     from OE_EM_INFORMATION
     where sold_to_org_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'N'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 l_profile_val VARCHAR2(30);

 BEGIN
    arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_OI_Tracking()+' );
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL < '110510' THEN
       arp_message.set_line( 'OE_CUST_MERGE.OE_Merge_OI_Tracking()-' );
       Return;
    END IF;

    -- both customer and site level

 IF( process_mode = 'LOCK' ) THEN

      arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      arp_message.set_token( 'TABLE_NAME', 'OE_EM_INFORMATION_ALL', FALSE );

      open c1;
      close c1;


 ELSE

    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');


   -- customer level update
    arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    arp_message.set_token( 'TABLE_NAME', 'OE_EM_INFORMATION_ALL', FALSE );

    IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
       insert into  HZ_CUSTOMER_MERGE_LOG (
		MERGE_LOG_ID,
		TABLE_NAME,
		MERGE_HEADER_ID,
		PRIMARY_KEY1,
		NUM_COL1_ORIG,
		NUM_COL1_NEW,
		ACTION_FLAG,
		REQUEST_ID,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATE_LOGIN,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY)

		SELECT
		HZ_CUSTOMER_MERGE_LOG_s.nextval,
		'OE_EM_INFORMATION_ALL',
		m.CUSTOMER_MERGE_HEADER_ID,
		h.ORIG_SYS_DOCUMENT_REF,
		h.sold_to_org_id,
		m.customer_site_id,
		'U',
		req_id,
		hz_utility_pub.CREATED_BY,
		hz_utility_pub.CREATION_DATE,
		hz_utility_pub.LAST_UPDATE_LOGIN,
		hz_utility_pub.LAST_UPDATE_DATE,
		hz_utility_pub.LAST_UPDATED_BY
	        from oe_em_information_All h,
		     ra_customer_merges m
               where h.sold_to_org_id=m.duplicate_site_id
                 and m.process_flag = 'N'
                 and m.request_id = req_id
                 and m.set_number = set_num;

    end if;

    UPDATE OE_EM_INFORMATION_ALL  a
    set    sold_to_org_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.sold_to_org_id = m.duplicate_id
                                and    m.process_flag = 'N'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where  sold_to_org_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'N'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num)
--added for bug3196900
   and (a.document_id,a.em_transaction_type_code) in
  (select document_id,em_transaction_type_code from oe_em_information);


    g_count := sql%rowcount;

    arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

  END IF;

  arp_message.set_line( 'OE_CUST_MERGE. OE_Merge_OI_Tracking()-' );

  EXCEPTION
    When others then
      arp_message.set_error( 'OE_CUST_MERGE. OE_Merge_OI_Tracking-' );
      raise;

 END OE_Merge_OI_Tracking;



 Procedure OE_Order_Merge     (Req_Id          IN NUMBER,
					   Set_Num         IN NUMBER,
					   Process_Mode    IN VARCHAR2
					  )
 IS

 BEGIN
    arp_message.set_line( 'OE_CUST_MERGE.OE_Order_Merge()+' );

    OE_Merge_Headers(Req_Id, Set_Num, Process_Mode);
    OE_Merge_Lines(Req_Id, Set_Num, Process_Mode);
    OE_Merge_Header_History(Req_Id, Set_Num, Process_Mode);
    OE_Merge_Lines_History(Req_Id, Set_Num, Process_Mode);
    -- OE_Merge_Headers_IFACE(Req_Id, Set_Num, Process_Mode);   -- Interface tables need not be updated
    -- OE_Merge_Lines_IFACE(Req_Id, Set_Num, Process_Mode);     -- Interface tables need not be updated
    OE_Merge_Header_ACKS(Req_Id, Set_Num, Process_Mode);
    OE_Merge_Line_ACKS(Req_Id, Set_Num, Process_Mode);
    OE_Merge_Price_Adj_Attribs(Req_Id, Set_Num, Process_Mode);
    OE_Merge_Blanket_Headers(Req_Id, Set_Num, Process_Mode);
    OE_Merge_Blanket_Lines(Req_Id, Set_Num, Process_Mode);
    OE_Merge_Blkt_Hdrs_Hist(Req_Id, Set_Num, Process_Mode);
    OE_Merge_Blkt_Lines_Hist(Req_Id, Set_Num, Process_Mode);
    OE_Merge_OI_Tracking (Req_Id, Set_Num, Process_Mode);
    arp_message.set_line( 'calling dbi now...' );
    oe_update_dbi_log();
    arp_message.set_line( 'OE_CUST_MERGE.Order_Merge()-' );

    EXCEPTION
    When others then
      arp_message.set_error( 'OE_CUST_MERGE.OE_Order_Merge-' );
      raise;

 END OE_Order_Merge;


 Procedure OE_Workflow_Merge  (Req_Id          IN NUMBER,
					   Set_Num         IN NUMBER,
					   Process_Mode    IN VARCHAR2
					  )
 IS

 BEGIN

   NULL;

 END OE_Workflow_Merge;

 PROCEDURE Oe_Update_DBI_log IS

 CURSOR c_get_lines(p_header_id number) IS
   SELECT l.line_id
     FROM oe_order_lines_all l
    WHERE l.header_id = p_header_id;

 CURSOR c_set_of_books_id IS
   SELECT  SYS.SET_OF_BOOKS_ID
     FROM  AR_SYSTEM_PARAMETERS SYS;

l_line_id number;
l_set_of_books_id number;
l_update_date date;

BEGIN

   IF  l_dbi_profile = 'Y' then
     arp_message.set_line(' inside update_dbi count hder_id_tab='||dbi_header_header_id_tab.COUNT);
     arp_message.set_line(' count lin hdr_id_tab='||dbi_line_header_id_tab.COUNT);


     IF dbi_header_header_id_tab.COUNT <> 0  then
      FOR i in  dbi_header_header_id_tab.FIRST..dbi_header_header_id_tab.LAST
      LOOP
	 arp_message.set_line('header.header_id:'||dbi_header_header_id_tab(i));
      end loop;
     end if;

     IF dbi_line_header_id_tab.COUNT <> 0  then
      FOR i in  dbi_line_header_id_tab.FIRST..dbi_line_header_id_tab.LAST
      LOOP
	 arp_message.set_line('line.header_id:'||dbi_line_header_id_tab(i));
      end loop;
     end if;

     IF dbi_line_line_id_tab.COUNT <> 0  then
      FOR i in  dbi_line_line_id_tab.FIRST..dbi_line_line_id_tab.LAST
      LOOP
	 arp_message.set_line('line.line_id:'||dbi_line_line_id_tab(i));
      end loop;
     end if;



     -- Removing Those Line Ids for whose headers already exists from hdr merge
     IF dbi_line_header_id_tab.COUNT <> 0  then

       arp_message.set_line('count line_header_id_tab='||dbi_line_header_id_tab.COUNT);
       FOR i in  dbi_line_header_id_tab.FIRST..dbi_line_header_id_tab.LAST
       LOOP

          arp_message.set_line('count header_id_tab='||dbi_header_id_tab.COUNT);
          IF dbi_header_id_tab.EXISTS(dbi_line_header_id_tab(i)) THEN
	      arp_message.set_line( 'DBI:matched line.header_id and header.header_id of '||dbi_line_header_id_tab(i)||', deleting');
             dbi_line_status_tab(i) := 'N';
           END IF;

       END LOOP;
     END IF; -- if line header id tab is not null

     IF dbi_line_status_tab.COUNT <> 0 then
       FOR i in dbi_line_status_tab.FIRST..dbi_line_status_tab.LAST
       LOOP
         arp_message.set_line( 'status '||i|| '='||dbi_line_status_tab(i));
       END LOOP;
     END IF;

     OPEN c_set_of_books_id;
     FETCH c_set_of_books_id
      INTO l_set_of_books_id;
     CLOSE c_set_of_books_id;

     IF l_set_of_books_id is NULL THEN
       l_set_of_books_id := -99;
     END IF;

     -- Updating DBI LOG for Header Id and Line Ids from Header Merge
     IF dbi_header_header_id_tab.COUNT > 0 then
       FORALL i in dbi_header_header_id_tab.FIRST..dbi_header_header_id_tab.LAST

             INSERT INTO ONT_DBI_CHANGE_LOG
              (HEADER_ID
              ,LINE_ID
              ,SET_OF_BOOKS_ID
              ,CURRENCY_CODE
              ,LAST_UPDATE_DATE
              )

             SELECT
             dbi_header_header_id_tab(i)
             ,l.line_id
             ,l_set_of_books_id
             ,'XXX'
             ,l.last_update_date ----dbi_header_update_date_tab(i)  bug 9349882,9558975

             FROM OE_ORDER_LINES_ALL l, oe_order_headers_all h
            WHERE l.header_id = dbi_header_header_id_tab(i)
              AND h.header_id = l.header_id
              AND h.booked_flag = 'Y';

     arp_message.set_line(' Hdr insert count='||sql%rowcount);

     END IF; -- because of hdr merge


     -- Updating DBI LOG for Line Ids from Line Merge
     IF dbi_line_line_id_tab.COUNT > 0 then
       FORALL i in  dbi_line_line_id_tab.FIRST..dbi_line_line_id_tab.LAST

       INSERT INTO ONT_DBI_CHANGE_LOG
              (HEADER_ID
              ,LINE_ID
              ,SET_OF_BOOKS_ID
              ,CURRENCY_CODE
              ,LAST_UPDATE_DATE
              )

             SELECT
             dbi_line_header_id_tab(i)
             ,l.line_id
             ,l_set_of_books_id
             ,'XXX'
             ,l.last_update_date  ---dbi_line_update_date_tab(i) bug 9349882,9558975
             FROM OE_ORDER_LINES_ALL l
            WHERE l.line_id = dbi_line_line_id_tab(i)
              AND l.booked_flag = 'Y'
              AND dbi_line_status_tab(i) = 'Y';
     arp_message.set_line(' line insert count='||sql%rowcount);

     END IF; -- because of line merge

   END IF; -- if dbi is installed

   dbi_header_id_tab.DELETE;
   dbi_header_header_id_tab.DELETE;
   dbi_header_update_date_tab.DELETE;

   dbi_line_header_id_tab.DELETE;
   dbi_line_line_id_tab.DELETE;
   dbi_line_update_date_tab.DELETE;
   dbi_line_status_tab.DELETE;
   dbi_header_id_tab.DELETE;

   arp_message.set_line(' End Update DBI');

 EXCEPTION
   WHEN OTHERS THEN
     oe_debug_pub.add('when others oe_cust_merge.update_dbi_log'||SQLERRM||
                      SQLCODE);

 END oe_update_dbi_log;

END OE_CUST_MERGE;

/
