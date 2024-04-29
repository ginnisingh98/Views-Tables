--------------------------------------------------------
--  DDL for Package Body OEP_CMERGE_OEPIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OEP_CMERGE_OEPIC" AS
/* $Header: oepicpb.pls 115.1 99/07/16 08:27:54 porting shi $ */


/*---------------------------- PRIVATE VARIABLES ----------------------------*/
  g_count		NUMBER := 0;


/*--------------------------- PRIVATE ROUTINES ------------------------------*/

PROCEDURE oe_pr (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is

CURSOR c1 is
    select picking_rule
    from so_picking_rules
    where  site_use_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    for update nowait;

CURSOR c2 is
    select picking_rule
    from so_picking_rules
    where  customer_id in (select m.duplicate_id
                                 from   ra_customer_merges  m
                                 where  m.process_flag = 'N'
			         and    m.request_id = req_id
			         and    m.set_number = set_num)
    for update nowait;

BEGIN

  arp_message.set_line( 'OEP_CMERGE_OEPIC.OE_PR()+' );

/*-----------------------------+
 | SO_PICKING_RULES            |
 +-----------------------------*/
/* both customer and site level */

IF( process_mode = 'LOCK' ) THEN

  arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_PICKING_RULES', FALSE );

  open c1;
  close c1;

  open c2;
  close c2;

ELSE


/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_PICKING_RULES', FALSE );

    UPDATE SO_PICKING_RULES  a
    set (site_use_id) = (select distinct m.customer_site_id
                                   from   ra_customer_merges m
                                   where  a.site_use_id =
                                                 m.duplicate_site_id
			           and    m.request_id = req_id
                                   and    m.process_flag = 'N'
			           and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  site_use_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num);

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

/* customer level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_PICKING_RULES', FALSE );

    UPDATE SO_PICKING_RULES  a
    set    customer_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.customer_id =
				 		m.duplicate_id
                                and    m.process_flag = 'N'
			        and    m.request_id = req_id
			        and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  customer_id in (select m.duplicate_id
                                 from   ra_customer_merges  m
                                 where  m.process_flag = 'N'
			         and    m.request_id = req_id
			         and    m.set_number = set_num);

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

  arp_message.set_line( 'OEP_CMERGE_OEPIC.OE_PR()-' );


EXCEPTION
  when others then
    arp_message.set_error( 'OEP_CMERGE_OEPIC.OE_PR');
    raise;

END;


PROCEDURE oe_pb (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is

CURSOR c1 is
    select batch_id
    from so_picking_batches
    where  site_use_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    for update nowait;

CURSOR c2 is
    select batch_id
    from so_picking_batches
    where  customer_id in (select m.duplicate_id
                                 from   ra_customer_merges  m
                                 where  m.process_flag = 'N'
			         and    m.request_id = req_id
			         and    m.set_number = set_num)
    for update nowait;

BEGIN

  arp_message.set_line( 'OEP_CMERGE_OEPIC.OE_PB()+' );

/*-----------------------------+
 | SO_PICKING_BATCHES            |
 +-----------------------------*/
/* both customer and site level */

IF( process_mode = 'LOCK' ) THEN

  arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_PICKING_BATCHES', FALSE );

  open c1;
  close c1;

  open c2;
  close c2;

ELSE


/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_PICKING_BATCHES', FALSE );

    UPDATE SO_PICKING_BATCHES  a
    set (site_use_id) = (select distinct m.customer_site_id
                                   from   ra_customer_merges m
                                   where  a.site_use_id =
                                                 m.duplicate_site_id
			           and    m.request_id = req_id
                                   and    m.process_flag = 'N'
			           and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  site_use_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num);

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

/* customer level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_PICKING_BATCHES', FALSE );

    UPDATE SO_PICKING_BATCHES  a
    set    customer_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.customer_id =
				 		m.duplicate_id
                                and    m.process_flag = 'N'
			        and    m.request_id = req_id
			        and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  customer_id in (select m.duplicate_id
                                 from   ra_customer_merges  m
                                 where  m.process_flag = 'N'
			         and    m.request_id = req_id
			         and    m.set_number = set_num);

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

  arp_message.set_line( 'OEP_CMERGE_OEPIC.OE_PB()-' );


EXCEPTION
  when others then
    arp_message.set_error( 'OEP_CMERGE_OEPIC.OE_PB');
    raise;

END;



PROCEDURE oe_ph (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is

CURSOR c1 is
    select picking_header_id
    from so_picking_headers
    where  ship_to_site_use_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    for update nowait;

BEGIN

  arp_message.set_line( 'OEP_CMERGE_OEPIC.OE_PH()+' );

/*-----------------------------+
 | SO_PICKING_HEADERS            |
 +-----------------------------*/
/* both customer and site level */

IF( process_mode = 'LOCK' ) THEN

  arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_PICKING_HEADERS', FALSE );

  open c1;
  close c1;

ELSE


/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_PICKING_HEADERS', FALSE );

    UPDATE SO_PICKING_HEADERS  a
    set (ship_to_site_use_id) = (select distinct m.customer_site_id
                                   from   ra_customer_merges m
                                   where  a.ship_to_site_use_id =
                                                 m.duplicate_site_id
			           and    m.request_id = req_id
                                   and    m.process_flag = 'N'
			           and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  ship_to_site_use_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num);

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

  arp_message.set_line( 'OEP_CMERGE_OEPIC.OE_PH()-' );


EXCEPTION
  when others then
    arp_message.set_error( 'OEP_CMERGE_OEPIC.OE_PH');
    raise;

END;


PROCEDURE oe_pl (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is

CURSOR c1 is
    select picking_line_id
    from so_picking_lines
    where  ship_to_site_use_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    for update nowait;

BEGIN

  arp_message.set_line( 'OEP_CMERGE_OEPIC.OE_PL()+' );

/*-----------------------------+
 | SO_PICKING_LINES            |
 +-----------------------------*/
/* both customer and site level */

IF( process_mode = 'LOCK' ) THEN

  arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_PICKING_LINES', FALSE );

  open c1;
  close c1;

ELSE


/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_PICKING_LINES', FALSE );

    UPDATE SO_PICKING_LINES  a
    set (ship_to_site_use_id) = (select distinct m.customer_site_id
                                   from   ra_customer_merges m
                                   where  a.ship_to_site_use_id =
                                                 m.duplicate_site_id
			           and    m.request_id = req_id
                                   and    m.process_flag = 'N'
			           and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  ship_to_site_use_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num);

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

  arp_message.set_line( 'OEP_CMERGE_OEPIC.OE_PL()-' );


EXCEPTION
  when others then
    arp_message.set_error( 'OEP_CMERGE_OEPIC.OE_PL');
    raise;

END;


/*---------------------------- PUBLIC ROUTINES ------------------------------*/


  PROCEDURE MERGE (REQ_ID NUMBER, SET_NUM NUMBER, PROCESS_MODE VARCHAR2) IS
  BEGIN

  arp_message.set_line( 'OEP_CMERGE_OEPIC.MERGE()+' );

  oe_pr( req_id, set_num, process_mode );
  oe_pb( req_id, set_num, process_mode );
  oe_ph( req_id, set_num, process_mode );
  oe_pl( req_id, set_num, process_mode );

  arp_message.set_line( 'OEP_CMERGE_OEPIC.MERGE()-' );

EXCEPTION
  when others then
    raise;

  END MERGE;
END OEP_CMERGE_OEPIC;

/
