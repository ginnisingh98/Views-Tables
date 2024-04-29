--------------------------------------------------------
--  DDL for Package Body OE_CUST_MERGE_DATA_FIX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CUST_MERGE_DATA_FIX" AS
/* $Header: OEXCMDFB.pls 120.0 2005/06/01 01:15:27 appldev noship $ */

/*---------------------------- PRIVATE VARIABLES ----------------------------*/
  g_count               NUMBER := 0;


/*--------------------------- PRIVATE ROUTINES ------------------------------*/

/*------------------------------------------------*/
/*--- PRIVATE Procedure OE_Merge_Headers       ---*/
/*------------------------------------------------*/

 Procedure OE_Merge_Headers (Req_Id          IN NUMBER,
                             Set_Num         IN NUMBER,
                             Process_Mode    IN VARCHAR2)
 IS
 CURSOR c1 is
    select HEADER_ID
      from oe_order_headers_all
     where ship_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c2 is
    select HEADER_ID
      from oe_order_headers_all
     where invoice_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c3 is
    select HEADER_ID
      from oe_order_headers_all
     where deliver_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;

 CURSOR c4 is
    select HEADER_ID
      from oe_order_headers_all
     where sold_to_org_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;




--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
 BEGIN
    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Headers()+' );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEGIN OE_CUST_MERGE_DATA_FIX.OE_MERGE_HEADERS' ) ;
    END IF;

    /* both customer and site level */

    IF( process_mode = 'LOCK' ) THEN

      -- arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      -- arp_message.set_token( 'TABLE_NAME', 'oe_order_headers_all', FALSE );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LOCKING TABLE OE_ORDER_HEADERS_ALL' ) ;
      END IF;

      open c1;
      close c1;

      open c2;
      close c2;

      open c3;
      close c3;

      open c4;
      close c4;


ELSE

    /* site level update */
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SITE LEVEL UPDATE' ) ;
    END IF;
    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_headers_all', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_ORDER_HEADERS_ALL.SHIP_TO_ORG_ID' ) ;
    END IF;

    UPDATE oe_order_headers_all  a
    set ship_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.ship_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where ship_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_headers_all', FALSE );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_ORDER_HEADERS_ALL.INVOICE_TO_ORG_ID' ) ;
    END IF;

    UPDATE oe_order_headers_all  a
    set invoice_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.invoice_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where invoice_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_headers_all', FALSE );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_ORDER_HEADERS_ALL.DELIVER_TO_ORG_ID' ) ;
    END IF;

    UPDATE oe_order_headers_all  a
    set deliver_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.deliver_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where deliver_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;
    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_headers_all', FALSE );


   /* customer level update */
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CUSTOMER LEVEL UPDATE' ) ;
   END IF;
    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_headers_all', FALSE );
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'UPDATING OE_ORDER_HEADERS_ALL.SOLD_TO_ORG_ID' ) ;
   END IF;

    UPDATE oe_order_headers_all  a
    set    sold_to_org_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.sold_to_org_id = m.duplicate_id
                                and    m.process_flag = 'Y'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           request_id = req_id,
           program_application_id =fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate
    where  sold_to_org_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'Y'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num);

    g_count := sql%rowcount;

    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;


END IF;

    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Headers()-' );
    	IF l_debug_level  > 0 THEN
    	    oe_debug_pub.add(  'END OE_CUST_MERGE_DATA_FIX.OE_MERGE_HEADERS' ) ;
    	END IF;

    EXCEPTION
    When others then
      -- arp_message.set_error( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Headers-' );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR IN OE_CUST_MERGE_DATA_FIX.OE_MERGE_HEADERS' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 2000 ) ) ;
      END IF;
      raise;

 END OE_Merge_Headers;


/*-------------------------------------------------*/
/*--- PRIVATE Procedure OE_Merge_Header_History ---*/
/*-------------------------------------------------*/

/* ---- To be released with the Audit Trail Project -------
 Procedure OE_Merge_Header_History (Req_Id          IN NUMBER,
                             Set_Num         IN NUMBER,
                             Process_Mode    IN VARCHAR2)
 IS
 CURSOR c1 is
    select HEADER_ID
      from oe_order_header_history
     where ship_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c2 is
    select HEADER_ID
      from oe_order_header_history
     where invoice_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c3 is
    select HEADER_ID
      from oe_order_header_history
     where deliver_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;

 CURSOR c4 is
    select HEADER_ID
      from oe_order_header_history
     where sold_to_org_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;




 BEGIN
    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Header_History()+' );

    --  both customer and site level

    IF( process_mode = 'LOCK' ) THEN

      -- arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      -- arp_message.set_token( 'TABLE_NAME', 'oe_order_header_history', FALSE );

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
    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_header_history', FALSE );

    UPDATE oe_order_header_history  a
    set ship_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.ship_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where ship_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_header_history', FALSE );

    UPDATE oe_order_header_history  a
    set invoice_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.invoice_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where invoice_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_header_history', FALSE );

    UPDATE oe_order_header_history  a
    set deliver_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.deliver_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where deliver_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_header_history', FALSE );


   -- customer level update --

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_header_history', FALSE );

    UPDATE oe_order_header_history  a
    set    sold_to_org_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.sold_to_org_id = m.duplicate_id
                                and    m.process_flag = 'Y'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           request_id = req_id,
           program_application_id =fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate
    where  sold_to_org_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'Y'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num);

    g_count := sql%rowcount;

    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Header_History()-' );

    EXCEPTION
    When others then
      -- arp_message.set_error( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Header_History-' );
      raise;

 END OE_Merge_Header_History;

To be released with the Audit Trail project */

/*------------------------------------------------*/
/*--- PRIVATE PROCEDURE OE_Merge_Headers_IFACE ---*/
/*------------------------------------------------*/

/* -- Interface tables need not be updated

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
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c2 is
    select HEADER_ID
      from oe_headers_iface_all
     where invoice_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c3 is
    select HEADER_ID
      from oe_headers_iface_all
     where deliver_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;

 CURSOR c4 is
    select HEADER_ID
      from oe_headers_iface_all
     where sold_to_org_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;




 BEGIN
    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Headers_IFACE()+' );

    --  both customer and site level

    IF( process_mode = 'LOCK' ) THEN

      -- arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      -- arp_message.set_token( 'TABLE_NAME', 'oe_headers_iface_all', FALSE );

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
    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_headers_iface_all', FALSE );

    UPDATE oe_headers_iface_all  a
    set ship_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.ship_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where ship_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_headers_iface_all', FALSE );

    UPDATE oe_headers_iface_all  a
    set invoice_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.invoice_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where invoice_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_headers_iface_all', FALSE );

    UPDATE oe_headers_iface_all  a
    set deliver_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.deliver_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where deliver_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_headers_iface_all', FALSE );


   -- customer level update
    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_headers_iface_all', FALSE );

    UPDATE oe_headers_iface_all  a
    set    sold_to_org_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.sold_to_org_id = m.duplicate_id
                                and    m.process_flag = 'Y'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           request_id = req_id,
           program_application_id =fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate
    where  sold_to_org_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'Y'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num);

    g_count := sql%rowcount;

    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Headers_IFACE()-' );

    EXCEPTION
    When others then
      -- arp_message.set_error( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Headers_IFACE-' );
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
             where m.process_flag = 'Y'
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
             where m.process_flag = 'Y'
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
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
    for update nowait;

 CURSOR c4 is
    select HEADER_ID
      from OE_HEADER_ACKS
     where sold_to_org_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
    for update nowait;




--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
 BEGIN
    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Header_ACKS()+' );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEGIN OE_CUST_MERGE_DATA_FIX.OE_MERGE_HEADER_ACKS' ) ;
    END IF;

    /* both customer and site level */

    IF( process_mode = 'LOCK' ) THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LOCKING TABLE OE_HEADER_ACKS' ) ;
      END IF;
      -- arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      -- arp_message.set_token( 'TABLE_NAME', 'OE_HEADER_ACKS', FALSE );

      open c1;
      close c1;

      open c2;
      close c2;

      open c3;
      close c3;

      open c4;
      close c4;


ELSE

    /* site level update */
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SITE LEVEL UPDATE' ) ;
    END IF;

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'OE_HEADER_ACKS', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_HEADER_ACKS.SHIP_TO_ORG_ID' ) ;
    END IF;

    UPDATE OE_HEADER_ACKS  a
    set ship_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.ship_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where ship_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'OE_HEADER_ACKS', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_HEADER_ACKS.INVOICE_TO_ORG_ID' ) ;
    END IF;

    UPDATE OE_HEADER_ACKS  a
    set invoice_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.invoice_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where invoice_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'OE_HEADER_ACKS', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_HEADER_ACKS.DELIVER_TO_ORG_ID' ) ;
    END IF;

    UPDATE OE_HEADER_ACKS  a
    set deliver_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.deliver_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where deliver_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'OE_HEADER_ACKS', FALSE );


   /* customer level update */
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CUSTOMER LEVEL UPDATE' ) ;
   END IF;
    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'OE_HEADER_ACKS', FALSE );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_HEADER_ACKS.SOLD_TO_ORG_ID' ) ;
    END IF;

    UPDATE OE_HEADER_ACKS  a
    set    sold_to_org_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.sold_to_org_id = m.duplicate_id
                                and    m.process_flag = 'Y'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           request_id = req_id,
           program_application_id =fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate
    where  sold_to_org_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'Y'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';

    g_count := sql%rowcount;

    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;

END IF;

    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Header_ACKS()-' );
    	IF l_debug_level  > 0 THEN
    	    oe_debug_pub.add(  'END OE_CUST_MERGE_DATA_FIX.OE_MERGE_HEADER_ACKS' ) ;
    	END IF;

    EXCEPTION
    When others then
      -- arp_message.set_error( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Header_ACKS-' );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR IN OE_CUST_MERGE_DATA_FIX.OE_MERGE_HEADER_ACKS' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 2000 ) ) ;
      END IF;
      raise;

 END OE_Merge_Header_ACKS;

/*------------------------------------------------*/
/*--- PRIVATE PROCEDURE OE_Merge_Lines         ---*/
/*------------------------------------------------*/

 Procedure OE_Merge_Lines (Req_Id          IN NUMBER,
                             Set_Num         IN NUMBER,
                             Process_Mode    IN VARCHAR2)
 IS
 CURSOR c1 is
    select line_id
      from oe_order_lines_all
     where ship_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c2 is
    select line_id
      from oe_order_lines_all
     where invoice_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c3 is
    select line_id
      from oe_order_lines_all
     where deliver_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c4 is
    select line_id
      from oe_order_lines_all
     where intmed_ship_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;

 CURSOR c5 is
    select line_id
      from oe_order_lines_all
     where sold_to_org_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
 BEGIN
    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Lines()+' );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEGIN OE_CUST_MERGE_DATA_FIX.OE_MERGE_LINES' ) ;
    END IF;

    /* both customer and site level */

    IF( process_mode = 'LOCK' ) THEN

      -- arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      -- arp_message.set_token( 'TABLE_NAME', 'oe_order_lines_all', FALSE );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LOCKING TABLE OE_ORDER_LINES_ALL' ) ;
      END IF;

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
    /* site level update */
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SITE LEVEL UPDATE' ) ;
    END IF;

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_lines_all', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_ORDER_LINES_ALL.SHIP_TO_ORG_ID' ) ;
    END IF;

    UPDATE oe_order_lines_all  a
    set ship_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.ship_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where ship_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;
    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_lines_all', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_ORDER_LINES_ALL.INVOICE_TO_ORG_ID' ) ;
    END IF;

    UPDATE oe_order_lines_all  a
    set invoice_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.invoice_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where invoice_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_lines_all', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_ORDER_LINES_ALL.DELIVER_TO_ORG_ID' ) ;
    END IF;

    UPDATE oe_order_lines_all  a
    set deliver_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.deliver_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where deliver_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_lines_all', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_ORDER_LINES_ALL.INTMED_TO_ORG_ID' ) ;
    END IF;

    UPDATE oe_order_lines_all  a
    set intmed_ship_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.intmed_ship_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where intmed_ship_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_lines_all', FALSE );

   /* customer level update */
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CUSTOMER LEVEL UPDATE' ) ;
   END IF;
    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_lines_all', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_ORDER_LINES_ALL.SOLD_TO_ORG_ID' ) ;
    END IF;

    UPDATE oe_order_lines_all  a
    set    sold_to_org_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.sold_to_org_id = m.duplicate_id
                                and    m.process_flag = 'Y'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           request_id = req_id,
           program_application_id =fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate
    where  sold_to_org_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'Y'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num);

    g_count := sql%rowcount;

    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;

END IF;

    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Lines()-' );
    	IF l_debug_level  > 0 THEN
    	    oe_debug_pub.add(  'END OE_CUST_MERGE_DATA_FIX.OE_MERGE_LINES' ) ;
    	END IF;

    EXCEPTION
    When others then
      -- arp_message.set_error( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Lines-' );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR IN OE_CUST_MERGE_DATA_FIX.OE_MERGE_LINES' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 2000 ) ) ;
      END IF;
      raise;

 END OE_Merge_Lines;

/*-------------------------------------------------*/
/*--- PRIVATE PROCEDURE OE_Merge_Lines_History  ---*/
/*-------------------------------------------------*/

 Procedure OE_Merge_Lines_History (Req_Id          IN NUMBER,
                                   Set_Num         IN NUMBER,
                                   Process_Mode    IN VARCHAR2)
 IS
 CURSOR c1 is
    select line_id
      from oe_order_lines_history
     where ship_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c2 is
    select line_id
      from oe_order_lines_history
     where invoice_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c3 is
    select line_id
      from oe_order_lines_history
     where deliver_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c4 is
    select line_id
      from oe_order_lines_history
     where intmed_ship_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;

 CURSOR c5 is
    select line_id
      from oe_order_lines_history
     where sold_to_org_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
 BEGIN
    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Lines_History()+' );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEGIN OE_CUST_MERGE_DATA_FIX.OE_MERGE_LINES_HISTORY' ) ;
    END IF;

    /* both customer and site level */

    IF( process_mode = 'LOCK' ) THEN

      -- arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      -- arp_message.set_token( 'TABLE_NAME', 'oe_order_lines_history', FALSE );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LOCKING TABLE OE_ORDER_LINES_HISTORY' ) ;
      END IF;

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
    /* site level update */
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SITE LEVEL UPDATE' ) ;
    END IF;

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_lines_history', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_ORDER_LINES_HISTORY.SHIP_TO_ORG_ID' ) ;
    END IF;

    UPDATE oe_order_lines_history  a
    set ship_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.ship_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where ship_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_lines_history', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_ORDER_LINES_HISTORY.INVOICE_TO_ORG_ID' ) ;
    END IF;

    UPDATE oe_order_lines_history  a
    set invoice_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.invoice_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where invoice_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_lines_history', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_ORDER_LINES_HISTORY.DELIVER_TO_ORG_ID' ) ;
    END IF;

    UPDATE oe_order_lines_history  a
    set deliver_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.deliver_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where deliver_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_lines_history', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_ORDER_LINES_HISTORY.INTMED_TO_ORG_ID' ) ;
    END IF;


    UPDATE oe_order_lines_history  a
    set intmed_ship_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.intmed_ship_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where intmed_ship_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_lines_history', FALSE );


   /* customer level update */
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CUSTOMER LEVEL UPDATE' ) ;
   END IF;
    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_order_lines_history', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_ORDER_LINES_HISTORY.SOLD_TO_ORG_ID' ) ;
    END IF;

    UPDATE oe_order_lines_history  a
    set    sold_to_org_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.sold_to_org_id = m.duplicate_id
                                and    m.process_flag = 'Y'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           request_id = req_id,
           program_application_id =fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate
    where  sold_to_org_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'Y'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num);

    g_count := sql%rowcount;

    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;

END IF;

    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Lines_History()-' );
    	IF l_debug_level  > 0 THEN
    	    oe_debug_pub.add(  'END OE_CUST_MERGE_DATA_FIX.OE_MERGE_LINES_HISTORY' ) ;
    	END IF;

    EXCEPTION
    When others then
      -- arp_message.set_error( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Lines_History-' );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR IN OE_CUST_MERGE_DATA_FIX.OE_MERGE_LINES_HISTORY' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 2000 ) ) ;
      END IF;
      raise;

 END OE_Merge_Lines_History;

/*-------------------------------------------------*/
/*--- PRIVATE PROCEDURE OE_Merge_Lines_IFACE    ---*/
/*-------------------------------------------------*/

/*  Interface tables need not be updated

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
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c2 is
    select line_id
      from oe_lines_iface_all
     where invoice_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c3 is
    select line_id
      from oe_lines_iface_all
     where deliver_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


 CURSOR c4 is
    select line_id
      from oe_lines_iface_all
     where sold_to_org_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;

 BEGIN
    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Lines_IFACE()+' );

    -- both customer and site level

    IF( process_mode = 'LOCK' ) THEN

      -- arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      -- arp_message.set_token( 'TABLE_NAME', 'oe_lines_iface_all', FALSE );

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
    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_lines_iface_all', FALSE );

    UPDATE oe_lines_iface_all  a
    set ship_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.ship_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where ship_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_lines_iface_all', FALSE );

    UPDATE oe_lines_iface_all  a
    set invoice_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.invoice_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where invoice_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_lines_iface_all', FALSE );

    UPDATE oe_lines_iface_all  a
    set deliver_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.deliver_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where deliver_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_lines_iface_all', FALSE );

   -- customer level update
    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_lines_iface_all', FALSE );

    UPDATE oe_lines_iface_all  a
    set    sold_to_org_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.sold_to_org_id = m.duplicate_id
                                and    m.process_flag = 'Y'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           request_id = req_id,
           program_application_id =fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate
    where  sold_to_org_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'Y'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num);

    g_count := sql%rowcount;

    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Lines_IFACE()-' );

    EXCEPTION
    When others then
      -- arp_message.set_error( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Lines_IFACE-' );
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
             where m.process_flag = 'Y'
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
             where m.process_flag = 'Y'
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
             where m.process_flag = 'Y'
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
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
    for update nowait;

 CURSOR c5 is
    select line_id
      from oe_line_acks
     where sold_to_org_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
       and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y'
    for update nowait;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
 BEGIN
    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Line_ACKS()+' );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEGIN OE_CUST_MERGE_DATA_FIX.OE_MERGE_LINE_ACKS' ) ;
    END IF;

    /* both customer and site level */

    IF( process_mode = 'LOCK' ) THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LOCKING TABLE OE_LINE_ACKS' ) ;
      END IF;
      -- arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      -- arp_message.set_token( 'TABLE_NAME', 'oe_line_acks', FALSE );

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
    /* site level update */
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SITE LEVEL UPDATE' ) ;
    END IF;

    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_line_acks', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_LINE_ACKS.SHIP_TO_ORG_ID' ) ;
    END IF;

    UPDATE oe_line_acks  a
    set ship_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.ship_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where ship_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;
    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_line_acks', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_LINE_ACKS.INVOICE_TO_ORG_ID' ) ;
    END IF;

    UPDATE oe_line_acks  a
    set invoice_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.invoice_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where invoice_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;
    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_line_acks', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_LINE_ACKS.DELIVER_TO_ORG_ID' ) ;
    END IF;

    UPDATE oe_line_acks  a
    set deliver_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.deliver_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where deliver_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;
    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_line_acks', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_LINE_ACKS.INTMED_TO_ORG_ID' ) ;
    END IF;

    UPDATE oe_line_acks  a
    set intmed_ship_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.intmed_ship_to_org_id = m.duplicate_site_id
			              and m.request_id = req_id
                             and m.process_flag = 'Y'
			              and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id,
          request_id = req_id,
          program_application_id =fnd_global.prog_appl_id,
          program_id = fnd_global.conc_program_id,
          program_update_date = sysdate
    where intmed_ship_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
			                 and m.request_id = req_id
			                 and m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
	END IF;
    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_line_acks', FALSE );


   /* customer level update */
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'CUSTOMER LEVEL UPDATE' ) ;
   END IF;
    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'oe_line_acks', FALSE );
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'UPDATING OE_LINE_ACKS.SOLD_TO_ORG_ID' ) ;
	END IF;

    UPDATE oe_line_acks  a
    set    sold_to_org_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.sold_to_org_id = m.duplicate_id
                                and    m.process_flag = 'Y'
                                and    m.request_id = req_id
                                and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id,
           request_id = req_id,
           program_application_id =fnd_global.prog_appl_id,
           program_id = fnd_global.conc_program_id,
           program_update_date = sysdate
    where  sold_to_org_id in (select m.duplicate_id
                                from   ra_customer_merges  m
                               where  m.process_flag = 'Y'
                                 and    m.request_id = req_id
                                 and    m.set_number = set_num)
      and NVL(ACKNOWLEDGMENT_FLAG,'N') <> 'Y';

    g_count := sql%rowcount;

    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;

END IF;

    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Line_ACKS()-' );
    	IF l_debug_level  > 0 THEN
    	    oe_debug_pub.add(  'END OE_CUST_MERGE_DATA_FIX.OE_MERGE_LINE_ACKS' ) ;
    	END IF;

    EXCEPTION
    When others then
      -- arp_message.set_error( 'OE_CUST_MERGE_DATA_FIX.OE_Merge_Line_ACKS-' );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR IN OE_CUST_MERGE_DATA_FIX.OE_MERGE_LINE_ACKS' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 2000 ) ) ;
      END IF;
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
			    Process_Mode    IN VARCHAR2)
  IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
  BEGIN

    /* this part will be calling other internal procedures */
    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.Merg()+' );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEGIN OE_CUST_MERGE_DATA_FIX.MERGE' ) ;
    END IF;

    OE_CUST_MERGE_DATA_FIX.OE_Attachment_Merge (Req_Id, Set_Num, Process_Mode);
    OE_CUST_MERGE_DATA_FIX.OE_Defaulting_Merge (Req_Id, Set_Num, Process_Mode);
    OE_CUST_MERGE_DATA_FIX.OE_Hold_Merge (Req_Id, Set_Num, Process_Mode);
    OE_CUST_MERGE_DATA_FIX.OE_Constraints_Merge (Req_Id, Set_Num, Process_Mode);
    OE_CUST_MERGE_DATA_FIX.OE_Sets_Merge (Req_Id, Set_Num, Process_Mode);
    -- OE_CUST_MERGE_DATA_FIX.OE_Drop_Ship_Merge (Req_Id, Set_Num, Process_Mode);
    OE_CUST_MERGE_DATA_FIX.OE_Ship_Tolerance_Merge (Req_Id, Set_Num, Process_Mode);
    OE_CUST_MERGE_DATA_FIX.OE_Order_Merge (Req_Id, Set_Num, Process_Mode);

    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.Merg()-' );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'END OE_CUST_MERGE_DATA_FIX.MERGE' ) ;
    END IF;

    EXCEPTION
    When others then
      -- arp_message.set_error( 'OE_CUST_MERGE_DATA_FIX.Merg-' );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR IN OE_CUST_MERGE_DATA_FIX.MERGE' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 2000 ) ) ;
      END IF;
      raise;


  END Merge;


 Procedure OE_Attachment_Merge(Req_Id          IN NUMBER,
					   Set_Num         IN NUMBER,
					   Process_Mode    IN VARCHAR2)
IS
CURSOR c1 is
    select RULE_ELEMENT_ID
    from oe_attachment_rule_elements
    where  attribute_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code  = 'SHIP_TO_ORG_ID'
    for update nowait;

CURSOR c2 is
    select RULE_ELEMENT_ID
    from oe_attachment_rule_elements
    where  attribute_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code  = 'INVOICE_TO_ORG_ID'
    for update nowait;

CURSOR c3 is
    select RULE_ELEMENT_ID
    from oe_attachment_rule_elements
    where  attribute_value in (select to_char(m.duplicate_id)
                                 from   ra_customer_merges  m
                                 where  m.process_flag = 'Y'
                        and    m.request_id = req_id
                        and    m.set_number = set_num)
    and attribute_code  = 'SOLD_TO_ORG_ID'
    for update nowait;


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
 BEGIN
	-- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Attachment_Merge()+' );
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'BEGIN OE_CUST_MERGE_DATA_FIX.OE_ATTACHMENT_MERGE' ) ;
	END IF;

/*-----------------------------+
 | OE_ATTACHMENTS_RULE_ELEMENTS|
 +-----------------------------*/
/* both customer and site level */

IF( process_mode = 'LOCK' ) THEN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LOCKING TABLE OE_ATTACHMENT_RULE_ELEMENTS' ) ;
  END IF;
  -- arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'OE_ATTACHMENT_RULE_ELEMENTS', FALSE );

  open c1;
  close c1;

  open c2;
  close c2;

  open c3;
  close c3;


ELSE


/* site level update */
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SITE LEVEL UPDATE' ) ;
END IF;

  -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'OE_ATTACHMENT_RULE_ELEMENTS', FALSE );
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'UPDATING OE_ATTACHMENT_RULE_ELEMENTS.ATTRIBUTE_VALUE FOR ATTRIBUTE_CODE SHIP_TO_ORG_ID' ) ;
	END IF;
    UPDATE OE_ATTACHMENT_RULE_ELEMENTS  a
    set (attribute_value) = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.attribute_value =
                                                 to_char(m.duplicate_site_id)
                          and    m.request_id = req_id
                                   and    m.process_flag = 'Y'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
    where  attribute_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'SHIP_TO_ORG_ID';

  g_count := sql%rowcount;

  -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
  END IF;

  /* site level update */
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SITE LEVEL UPDATE' ) ;
  END IF;

  -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'OE_ATTACHMENT_RULE_ELEMENTS', FALSE );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'UPDATING OE_ATTACHMENT_RULE_ELEMENTS.ATTRIBUTE_VALUE FOR ATTRIBUTE_CODE INVOICE_TO_ORG_ID' ) ;
  END IF;
    UPDATE OE_ATTACHMENT_RULE_ELEMENTS  a
    set (attribute_value) = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.attribute_value =
                                                 to_char(m.duplicate_site_id)
                          and    m.request_id = req_id
                                   and    m.process_flag = 'Y'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
    where  attribute_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'INVOICE_TO_ORG_ID';

  g_count := sql%rowcount;

  -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
  END IF;


/* customer level update */
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'CUSTOMER LEVEL UPDATE' ) ;
END IF;
  -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'OE_ATTACHMENT_RULE_ELEMENTS', FALSE );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'UPDATING OE_ATTACHMENT_RULE_ELEMENTS.ATTRIBUTE_VALUE FOR ATTRIBUTE_CODE SOLD_TO_ORG_ID' ) ;
  END IF;

    UPDATE OE_ATTACHMENT_RULE_ELEMENTS  a
    set (attribute_value) = (select distinct to_char(m.customer_id)
                                   from   ra_customer_merges m
                                   where  a.attribute_value =
                                                 to_char(m.duplicate_id)
                          and    m.request_id = req_id
                                   and    m.process_flag = 'Y'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
    where  attribute_value in (select to_char(m.duplicate_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'SOLD_TO_ORG_ID';


  g_count := sql%rowcount;

  -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
  END IF;

END IF;

	-- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Attachment_Merge()-' );
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'END OE_CUST_MERGE_DATA_FIX.OE_ATTACHMENT_MERGE' ) ;
		END IF;


EXCEPTION
  when others then
	-- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Attachment_Merge' );
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ERROR IN OE_CUST_MERGE_DATA_FIX.OE_ATTACHMENT_MERGE' ) ;
	END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 2000 ) ) ;
    END IF;
    raise;


END OE_Attachment_Merge;


 Procedure OE_Defaulting_Merge (Req_Id          IN NUMBER,
				Set_Num         IN NUMBER,
				Process_Mode    IN VARCHAR2)
 IS
CURSOR c1 is
    select CONDITION_ELEMENT_ID
    from oe_def_condn_elems
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code  = 'SHIP_TO_ORG_ID'
    for update nowait;

CURSOR c2 is
    select CONDITION_ELEMENT_ID
    from oe_def_condn_elems
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code  = 'INVOICE_TO_ORG_ID'
    for update nowait;

CURSOR c4 is
    select CONDITION_ELEMENT_ID
    from oe_def_condn_elems
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code  = 'INTMED_SHIP_TO_ORG_ID'
    for update nowait;

CURSOR c3 is
    select CONDITION_ELEMENT_ID
    from oe_def_condn_elems
    where  value_string in (select to_char(m.duplicate_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code  = 'SOLD_TO_ORG_ID'
    for update nowait;

CURSOR c5 is
    select ATTR_DEF_RULE_ID
    from oe_def_attr_def_rules
    where  src_constant_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code  = 'SHIP_TO_ORG_ID'
    for update nowait;

CURSOR c6 is
    select ATTR_DEF_RULE_ID
    from oe_def_attr_def_rules
    where  src_constant_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code  = 'INVOICE_TO_ORG_ID'
    for update nowait;

CURSOR c7 is
    select ATTR_DEF_RULE_ID
    from oe_def_attr_def_rules
    where  src_constant_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code  = 'INTMED_SHIP_TO_ORG_ID'
    for update nowait;

CURSOR c8 is
    select ATTR_DEF_RULE_ID
    from oe_def_attr_def_rules
    where  src_constant_value in (select to_char(m.duplicate_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code  = 'SOLD_TO_ORG_ID'
    for update nowait;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
 BEGIN
     -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Defaulting_Merge()+' );
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEGIN OE_CUST_MERGE_DATA_FIX.OE_DEFAULTING_MERGE' ) ;
     END IF;

/*-----------------------------+
 | OE_DEF_CONDN_ELEMS|
 +-----------------------------*/
/* both customer and site level */

IF( process_mode = 'LOCK' ) THEN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LOCKING TABLE OE_DEF_CONDN_ELEMENTS' ) ;
  END IF;
  -- arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'OE_DEF_CONDN_ELEMS', FALSE );


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


/* site level update */
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SITE LEVEL UPDATE' ) ;
END IF;

  -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'OE_DEF_CONDN_ELEMS', FALSE );
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'UPDATING OE_DEF_CONDN_ELEMENTS.VALUE_STRING FOR ATTRIBUTE CODE SHIP_TO_ORG_ID' ) ;
	END IF;
    UPDATE OE_DEF_CONDN_ELEMS  a
    set value_string = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.value_string =
                                                 to_char(m.duplicate_site_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'Y'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'SHIP_TO_ORG_ID';

  g_count := sql%rowcount;

  -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
  END IF;

  /* site level update */
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'SITE LEVEL UPDATE' ) ;
  END IF;
  -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'OE_DEF_CONDN_ELEMS', FALSE );
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'UPDATING OE_DEF_CONDN_ELEMENTS.VALUE_STRING FOR ATTRIBUTE CODE INVOICE_TO_ORG_ID' ) ;
	END IF;
    UPDATE OE_DEF_CONDN_ELEMS  a
    set value_string = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.value_string =
                                                 to_char(m.duplicate_site_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'Y'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'INVOICE_TO_ORG_ID';

  g_count := sql%rowcount;

  -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
  END IF;

/* site level update */
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SITE LEVEL UPDATE' ) ;
END IF;
  -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'OE_DEF_CONDN_ELEMS', FALSE );
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'UPDATING OE_DEF_CONDN_ELEMENTS.VALUE_STRING FOR ATTRIBUTE CODE INTMED_TO_ORG_ID' ) ;
END IF;
    UPDATE OE_DEF_CONDN_ELEMS  a
    set value_string = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.value_string =
                                                 to_char(m.duplicate_site_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'Y'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'INTMED_SHIP_TO_ORG_ID';

  g_count := sql%rowcount;

  -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
  END IF;

/* customer level update */
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'CUSTOMER LEVEL UPDATE' ) ;
END IF;
  -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'OE_DEF_CONDN_ELEMS', FALSE );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'UPDATING OE_DEF_CONDN_ELEMENTS.VALUE_STRING FOR ATTRIBUTE CODE SOLD_TO_ORG_ID' ) ;
  END IF;

    UPDATE OE_DEF_CONDN_ELEMS  a
    set value_string = (select distinct to_char(m.customer_id)
                                   from   ra_customer_merges m
                                   where  a.value_string =
                                                 to_char(m.duplicate_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'Y'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
    where  value_string in (select to_char(m.duplicate_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'SOLD_TO_ORG_ID';


  g_count := sql%rowcount;

  -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
  END IF;

/* site level update */
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SITE LEVEL UPDATE' ) ;
END IF;
  -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'OE_DEF_ATTR_DEF_RULES', FALSE );

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'UPDATING OE_DEF_ATTR_DEF_RULES.SRC_CONSTANT_VALUE FOR ATTRIBUTE CODE SHIP_TO_ORG_ID' ) ;
  END IF;

    UPDATE OE_DEF_ATTR_DEF_RULES  a
    set src_constant_value = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.src_constant_value =
                                                 to_char(m.duplicate_site_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'Y'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
    where  src_constant_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'SHIP_TO_ORG_ID';

  g_count := sql%rowcount;

  -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
  END IF;

/* site level update */
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SITE LEVEL UPDATE' ) ;
END IF;
  -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'OE_DEF_ATTR_DEF_RULES', FALSE );
  	IF l_debug_level  > 0 THEN
  	    oe_debug_pub.add(  'UPDATING OE_DEF_ATTR_DEF_RULES.SRC_CONSTANT_VALUE FOR ATTRIBUTE CODE INVOICE_TO_ORG_ID' ) ;
  	END IF;

    UPDATE OE_DEF_ATTR_DEF_RULES  a
    set src_constant_value = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.src_constant_value =
                                                 to_char(m.duplicate_site_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'Y'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
    where  src_constant_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'INVOICE_TO_ORG_ID';

  g_count := sql%rowcount;

  -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
  END IF;

/* site level update */
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SITE LEVEL UPDATE' ) ;
END IF;
  -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'OE_DEF_ATTR_DEF_RULES', FALSE );
  	IF l_debug_level  > 0 THEN
  	    oe_debug_pub.add(  'UPDATING OE_DEF_ATTR_DEF_RULES.SRC_CONSTANT_VALUE FOR ATTRIBUTE CODE INTMED_TO_ORG_ID' ) ;
  	END IF;

    UPDATE OE_DEF_ATTR_DEF_RULES  a
    set src_constant_value = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.src_constant_value =
                                                 to_char(m.duplicate_site_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'Y'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
    where  src_constant_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'INTMED_SHIP_TO_ORG_ID';

  g_count := sql%rowcount;

  -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
  END IF;

/* customer level update */
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'CUSTOMER LEVEL UPDATE' ) ;
END IF;
  -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'OE_DEF_ATTR_DEF_RULES', FALSE );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'UPDATING OE_DEF_ATTR_DEF_RULES.SRC_CONSTANT_VALUE FOR ATTRIBUTE CODE SOLD_TO_ORG_ID' ) ;
  END IF;

    UPDATE OE_DEF_ATTR_DEF_RULES  a
    set src_constant_value = (select distinct to_char(m.customer_id)
                                   from   ra_customer_merges m
                                   where  a.src_constant_value =
                                                 to_char(m.duplicate_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'Y'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
    where  src_constant_value in (select to_char(m.duplicate_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and attribute_code = 'SOLD_TO_ORG_ID';


  g_count := sql%rowcount;

  -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
  END IF;



END IF;

     -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Defaulting_Merge()-' );
     	IF l_debug_level  > 0 THEN
     	    oe_debug_pub.add(  'END OE_CUST_MERGE_DATA_FIX.OE_DEFAULTING_MERGE' ) ;
     	END IF;


EXCEPTION
  when others then
     -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Defaulting_Merge' );
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ERROR IN OE_CUST_MERGE_DATA_FIX.OE_DEFAULTING_MERGE' ) ;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 2000 ) ) ;
     END IF;
    raise;



END OE_Defaulting_Merge;

Procedure OE_Constraints_Merge (Req_Id          IN NUMBER,
					   Set_Num         IN NUMBER,
					   Process_Mode    IN VARCHAR2)
IS
CURSOR c1 is
    select VALIDATION_TMPLT_ID
    from oe_pc_vtmplt_cols
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and column_name  = 'SHIP_TO_ORG_ID'
    for update nowait;

CURSOR c2 is
    select VALIDATION_TMPLT_ID
    from oe_pc_vtmplt_cols
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and column_name  = 'INVOICE_TO_ORG_ID'
    for update nowait;

CURSOR c4 is
    select VALIDATION_TMPLT_ID
    from oe_pc_vtmplt_cols
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and column_name  = 'INTMED_SHIP_TO_ORG_ID'
    for update nowait;

CURSOR c3 is
    select VALIDATION_TMPLT_ID
    from oe_pc_vtmplt_cols
    where  value_string in (select to_char(m.duplicate_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and column_name  = 'SOLD_TO_ORG_ID'
    for update nowait;


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
 BEGIN
     -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.Constraints_Merge()+' );
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEGIN OE_CUST_MERGE_DATA_FIX.OE_CONSTRAINTS_MERGE' ) ;
     END IF;

/*-----------------------------+
 | oe_pc_vtmplt_cols|
 +-----------------------------*/
/* both customer and site level */

IF( process_mode = 'LOCK' ) THEN

  -- arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'OE_PC_VTMPLT_COLS', FALSE );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LOCKING TABLE OE_PC_VTMPLT_COLS' ) ;
  END IF;

  open c1;
  close c1;

  open c2;
  close c2;

  open c3;
  close c3;

  open c4;
  close c4;


ELSE


/* site level update */
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SITE LEVEL UPDATE' ) ;
END IF;
  -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'OE_PC_VTMPLT_COLS', FALSE );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'UPDATING OE_PC_VTMPLT_COLS.VALUE_STRING FOR COLUMN_NAME SHIP_TO_ORG_ID' ) ;
  END IF;

    UPDATE OE_PC_VTMPLT_COLS  a
    set value_string = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.value_string =
                                                 to_char(m.duplicate_site_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'Y'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and column_name = 'SHIP_TO_ORG_ID';

  g_count := sql%rowcount;

  -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
  END IF;

/* site level update */
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SITE LEVEL UPDATE' ) ;
END IF;
  -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'OE_PC_VTMPLT_COLS', FALSE );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'UPDATING OE_PC_VTMPLT_COLS.VALUE_STRING FOR COLUMN_NAME INVOICE_TO_ORG_ID' ) ;
  END IF;

    UPDATE OE_PC_VTMPLT_COLS  a
    set value_string = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.value_string =
                                                 to_char(m.duplicate_site_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'Y'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and column_name = 'INVOICE_TO_ORG_ID';

  g_count := sql%rowcount;

  -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
  END IF;

/* site level update */
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SITE LEVEL UPDATE' ) ;
END IF;
  -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'OE_PC_VTMPLT_COLS', FALSE );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'UPDATING OE_PC_VTMPLT_COLS.VALUE_STRING FOR COLUMN_NAME INTMED_TO_ORG_ID' ) ;
  END IF;

    UPDATE OE_PC_VTMPLT_COLS  a
    set value_string = (select distinct to_char(m.customer_site_id)
                                   from   ra_customer_merges m
                                   where  a.value_string =
                                                 to_char(m.duplicate_site_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'Y'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
    where  value_string in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and column_name = 'INTMED_SHIP_TO_ORG_ID';

  g_count := sql%rowcount;

  -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
  END IF;


/* customer level update */
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'CUSTOMER LEVEL UPDATE' ) ;
END IF;
  -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'OE_PC_VTMPLT_COLS', FALSE );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'UPDATING OE_PC_VTMPLT_COLS.VALUE_STRING FOR COLUMN_NAME SOLD_TO_ORG_ID' ) ;
  END IF;

    UPDATE OE_PC_VTMPLT_COLS  a
    set value_string = (select distinct to_char(m.customer_id)
                                   from   ra_customer_merges m
                                   where  a.value_string =
                                                 to_char(m.duplicate_id)

                          and    m.request_id = req_id
                                   and    m.process_flag = 'Y'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
    where  value_string in (select to_char(m.duplicate_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and column_name = 'SOLD_TO_ORG_ID';


  g_count := sql%rowcount;

  -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
  END IF;

END IF;

     -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Constraints_Merge()-' );
     	IF l_debug_level  > 0 THEN
     	    oe_debug_pub.add(  'END OE_CUST_MERGE_DATA_FIX.OE_CONSTRAINTS_MERGE' ) ;
     	END IF;


EXCEPTION
  when others then
     -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Constraints_Merge' );
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ERROR IN OE_CUST_MERGE_DATA_FIX.OE_CONSTRAINTS_MERGE' ) ;
     END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 2000 ) ) ;
      END IF;
    raise;

END OE_Constraints_Merge;




Procedure OE_Hold_Merge      (Req_Id          IN NUMBER,
					   Set_Num         IN NUMBER,
					   Process_Mode    IN VARCHAR2)
 IS
CURSOR c1 is
    select hold_source_id
    from oe_hold_sources
    where  hold_entity_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and hold_entity_code = 'S'
    for update nowait;

CURSOR c2 is
    select hold_source_id
    from oe_hold_sources
    where  hold_entity_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and hold_entity_code = 'B'
    for update nowait;


CURSOR c3 is
    select hold_source_id
    from oe_hold_sources
    where  hold_entity_id in (select m.duplicate_id
                                 from   ra_customer_merges  m
                                 where  m.process_flag = 'Y'
                        and    m.request_id = req_id
                        and    m.set_number = set_num)
    and hold_entity_code = 'C'
    for update nowait;



--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
 BEGIN

		-- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Hold_Merge()+' );
		IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  'BEGIN OE_CUST_MERGE_DATA_FIX.OE_HOLD_MERGE' ) ;
		END IF;
/*-----------------------------+
 | OE_HOLD_SOURCES             |
 +-----------------------------*/
/* both customer and site level */

IF( process_mode = 'LOCK' ) THEN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LOCKING TABLE OE_HOLD_SOURCES' ) ;
  END IF;
  -- arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'OE_HOLD_SOURCES', FALSE );

  open c1;
  close c1;

  open c2;
  close c2;

  open c3;
  close c3;

ELSE


/* site level update */
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SITE LEVEL UPDATE' ) ;
END IF;
  -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'OE_HOLD_SOURCES', FALSE );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'UPDATING OE_HOLD_SOURCES.HOLD_ENTITY_ID FOR HOLD_ENTITY_CODE S' ) ;
  END IF;

    UPDATE OE_HOLD_SOURCES  a
    set (hold_entity_id) = (select distinct m.customer_site_id
                                   from   ra_customer_merges m
                                   where  a.hold_entity_id =
                                                 m.duplicate_site_id
                          and    m.request_id = req_id
                                   and    m.process_flag = 'Y'
                          and    m.set_number = set_num),
           last_update_date = sysdate,

           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
    where  hold_entity_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and hold_entity_code = 'S';

  g_count := sql%rowcount;

  -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
  END IF;


/* site level update */
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'SITE LEVEL UPDATE' ) ;
END IF;
  -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'SO_HOLD_SOURCES', FALSE );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'UPDATING OE_HOLD_SOURCES.HOLD_ENTITY_ID FOR HOLD_ENTITY_CODE B' ) ;
  END IF;

    UPDATE OE_HOLD_SOURCES  a
    set (hold_entity_id) = (select distinct m.customer_site_id
                                   from   ra_customer_merges m
                                   where  a.hold_entity_id =

                                                 m.duplicate_site_id
                          and    m.request_id = req_id
                                   and    m.process_flag = 'Y'
                          and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
    where  hold_entity_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'Y'
                           and    m.request_id = req_id
                           and    m.set_number = set_num)
    and hold_entity_code = 'B';

  g_count := sql%rowcount;

  -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
  END IF;



/* customer level update */
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'CUSTOMER LEVEL UPDATE' ) ;
END IF;
  -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  -- arp_message.set_token( 'TABLE_NAME', 'SO_HOLD_SOURCES', FALSE );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'UPDATING OE_HOLD_SOURCES.HOLD_ENTITY_ID FOR HOLD_ENTITY_CODE C' ) ;
  END IF;

    UPDATE OE_HOLD_SOURCES  a
    set    hold_entity_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.hold_entity_id =
                              m.duplicate_id
                                and    m.process_flag = 'Y'
                       and    m.request_id = req_id
                       and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
    where  hold_entity_id in (select m.duplicate_id
                                 from   ra_customer_merges  m
                                 where  m.process_flag = 'Y'
                        and    m.request_id = req_id
                        and    m.set_number = set_num)
    and hold_entity_code = 'C';

  g_count := sql%rowcount;

  -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
  END IF;

END IF;

	-- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Hold_Merge()-' );
	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'END OE_CUST_MERGE_DATA_FIX.OE_HOLD_MERGE' ) ;
	    END IF;


EXCEPTION
  when others then
	-- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Hold_Merge' );
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ERROR IN OE_CUST_MERGE_DATA_FIX.OE_HOLD_MERGE' ) ;
	END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 2000 ) ) ;
      END IF;
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
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
 BEGIN
    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Drop_SHip_Merge()+' );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEGIN OE_CUST_MERGE_DATA_FIX.OE_DROP_SHIP_MERGE' ) ;
    END IF;

    /* both customer and site level */

    IF( process_mode = 'LOCK' ) THEN

      -- arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      -- arp_message.set_token( 'TABLE_NAME', 'OE_DROP_SHIP_SOURCES', FALSE );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LOCKING TABLE OE_DROP_SHIP_SOURCES' ) ;
      END IF;

      open c1;
      close c1;

ELSE

    /* site level update */
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SITE LEVEL UPDATE' ) ;
    END IF;
    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'OE_DROP_SHIP_SOURCES', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_DROP_SHIP_SOURCES.LINE_LOCATION_ID' ) ;
    END IF;

    UPDATE OE_DROP_SHIP_SOURCES  a
    set line_location_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.line_location_id = m.duplicate_site_id
                             and m.request_id = req_id
                             and m.process_flag = 'Y'
                             and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id
    where line_location_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
                                and m.request_id = req_id
                                and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;

END IF;

    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Drop_SHip_Merge()-' );
    	IF l_debug_level  > 0 THEN
    	    oe_debug_pub.add(  'END OE_CUST_MERGE_DATA_FIX.OE_DROP_SHIP_MERGE' ) ;
    	END IF;

    EXCEPTION
    When others then
      -- arp_message.set_error( 'OE_CUST_MERGE_DATA_FIX.OE_Drop_SHip_Merge-' );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR IN OE_CUST_MERGE_DATA_FIX.OE_DROP_SHIP_MERGE' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 2000 ) ) ;
      END IF;
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
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;

 CURSOR c2 is
    select CUST_ITEM_SETTING_ID
      from oe_cust_item_settings
     where customer_id in
           (select m.duplicate_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;



--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
 BEGIN
    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_ship_tolerance_merge()+' );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEGIN OE_CUST_MERGE_DATA_FIX.OE_SHIP_TOLERANCE_MERGE' ) ;
    END IF;

    /* both customer and site level */

    IF( process_mode = 'LOCK' ) THEN

      -- arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      -- arp_message.set_token( 'TABLE_NAME', 'OE_CUST_ITEM_SETTINGS', FALSE );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LOCKING TABLE OE_CUST_ITEM_SETTINGS' ) ;
      END IF;

      open c1;
      close c1;

      open c2;
      close c2;



ELSE

    /* site level update */
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SITE LEVEL UPDATE' ) ;
    END IF;
    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'OE_CUST_ITEM_SETTINGS', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_CUST_ITEM_SETTINGS.SITE_USE_ID' ) ;
    END IF;

    UPDATE OE_CUST_ITEM_SETTINGS  a
    set site_use_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.site_use_id = m.duplicate_site_id
                             and m.request_id = req_id
                             and m.process_flag = 'Y'
                             and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id
    where site_use_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
                                and m.request_id = req_id
                                and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;

    /* customer level update */
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CUSTOMER LEVEL UPDATE' ) ;
    END IF;
    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'OE_CUST_ITEM_SETTINGS', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_CUST_ITEM_SETTINGS.CUSTOMER_ID' ) ;
    END IF;

    UPDATE OE_CUST_ITEM_SETTINGS  a
    set customer_id = (select distinct m.customer_id
                            from ra_customer_merges m
                           where a.customer_id = m.duplicate_id
                             and m.request_id = req_id
                             and m.process_flag = 'Y'
                             and m.set_number = set_num),
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id
    where customer_id in (select m.duplicate_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
                                and m.request_id = req_id
                                and m.set_number = set_num);
    g_count := sql%rowcount;
    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;

END IF;

    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Ship_Tolerance_Merge()-' );
    	IF l_debug_level  > 0 THEN
    	    oe_debug_pub.add(  'END OE_CUST_MERGE_DATA_FIX.OE_SHIP_TOLERANCE_MERGE' ) ;
    	END IF;



    EXCEPTION
    When others then
      -- arp_message.set_error( 'OE_CUST_MERGE_DATA_FIX.OE_Ship_Tolerance_Merge-' );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR IN OE_CUST_MERGE_DATA_FIX.OE_SHIP_TOLERANCE_MERGE' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 2000 ) ) ;
      END IF;
      raise;

 END OE_Ship_Tolerance_Merge;


 Procedure OE_Sets_Merge (Req_Id          IN NUMBER,
                             Set_Num         IN NUMBER,
                             Process_Mode    IN VARCHAR2)
 IS
 CURSOR c1 is
    select Set_Id
      from oe_sets
     where ship_to_org_id in
           (select m.duplicate_site_id
              from ra_customer_merges m
             where m.process_flag = 'Y'
               and m.request_id = req_id
               and m.set_number = set_num)
    for update nowait;


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
 BEGIN
    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Sets_Merge()+' );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEGIN OE_CUST_MERGE_DATA_FIX.OE_SETS_MERGE' ) ;
    END IF;

    /* both customer and site level */

    IF( process_mode = 'LOCK' ) THEN

      -- arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
      -- arp_message.set_token( 'TABLE_NAME', 'OE_SETS', FALSE );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'LOCKING TABLE OE_SETS' ) ;
      END IF;

      open c1;
      close c1;

	ELSE

    /* site level update */
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SITE LEVEL UPDATE' ) ;
    END IF;
    -- arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
    -- arp_message.set_token( 'TABLE_NAME', 'OE_SETS', FALSE );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'UPDATING OE_SETS.SHIP_TO_ORG_ID' ) ;
    END IF;

    UPDATE oe_sets  a
    set ship_to_org_id = (select distinct m.customer_site_id
                            from ra_customer_merges m
                           where a.ship_to_org_id = m.duplicate_site_id
                             and m.request_id = req_id
                             and m.process_flag = 'Y'
                             and m.set_number = set_num),
          update_date = sysdate,
          updated_by = fnd_global.user_id,
          update_login = fnd_global.login_id
    where ship_to_org_id in (select m.duplicate_site_id
                               from ra_customer_merges  m
                              where m.process_flag = 'Y'
                                and m.request_id = req_id
                                and m.set_number = set_num);
    g_count := sql%rowcount;

    -- arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
    -- arp_message.set_token( 'NUM_ROWS', to_char(g_count) );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  G_COUNT || ' ROWS UPDATED' ) ;
    END IF;

END IF;

    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Sets_Merge()-' );
    	IF l_debug_level  > 0 THEN
    	    oe_debug_pub.add(  'END OE_CUST_MERGE_DATA_FIX.OE_SETS_MERGE' ) ;
    	END IF;

    EXCEPTION
      when others then
      -- arp_message.set_error( 'OE_CUST_MERGE_DATA_FIX.OE_Sets_Merge-' );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR IN OE_CUST_MERGE_DATA_FIX.OE_SETS_MERGE' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 2000 ) ) ;
      END IF;

      raise;

 END OE_Sets_merge;



 Procedure OE_Order_Merge     (Req_Id          IN NUMBER,
					   Set_Num         IN NUMBER,
					   Process_Mode    IN VARCHAR2)
 IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
 BEGIN
    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.OE_Order_Merge()+' );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEGIN OE_CUST_MERGE_DATA_FIX.OE_ORDER_MERGE' ) ;
    END IF;

    OE_Merge_Headers(Req_Id, Set_Num, Process_Mode);
    OE_Merge_Lines(Req_Id, Set_Num, Process_Mode);
    -- OE_Merge_Header_History(Req_Id, Set_Num, Process_Mode);  -- To be released with the Audit Trail project
    OE_Merge_Lines_History(Req_Id, Set_Num, Process_Mode);
    -- OE_Merge_Headers_IFACE(Req_Id, Set_Num, Process_Mode);   -- Interface tables need not be updated
    -- OE_Merge_Lines_IFACE(Req_Id, Set_Num, Process_Mode);     -- Interface tables need not be updated
    OE_Merge_Header_ACKS(Req_Id, Set_Num, Process_Mode);
    OE_Merge_Line_ACKS(Req_Id, Set_Num, Process_Mode);

    -- arp_message.set_line( 'OE_CUST_MERGE_DATA_FIX.Order_Merge()-' );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'END OE_CUST_MERGE_DATA_FIX.OE_ORDER_MERGE' ) ;
    END IF;

    EXCEPTION
    When others then
    -- arp_message.set_error( 'OE_CUST_MERGE_DATA_FIX.OE_Order_Merge-' );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ERROR IN OE_CUST_MERGE_DATA_FIX.OE_ORDER_MERGE' ) ;
      END IF;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  SUBSTR ( SQLERRM , 1 , 2000 ) ) ;
      END IF;

      raise;

 END OE_Order_Merge;


 Procedure OE_Workflow_Merge  (Req_Id          IN NUMBER,
					   Set_Num         IN NUMBER,
					   Process_Mode    IN VARCHAR2)
 IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
 BEGIN

   NULL;

 END OE_Workflow_Merge;


END OE_CUST_MERGE_DATA_FIX;


/
