--------------------------------------------------------
--  DDL for Package Body OEP_CMERGE_OEHLD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OEP_CMERGE_OEHLD" AS
/* $Header: oehldpb.pls 115.1 99/07/16 08:26:03 porting shi $ */

/*---------------------------- PRIVATE VARIABLES ----------------------------*/
  g_count		NUMBER := 0;


/*--------------------------- PRIVATE ROUTINES ------------------------------*/

PROCEDURE oe_hs (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is

CURSOR c1 is
    select hold_source_id
    from so_hold_sources
    where  hold_entity_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    and hold_entity_code = 'STS'
    for update nowait;

CURSOR c2 is
    select hold_source_id
    from so_hold_sources
    where  hold_entity_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    and hold_entity_code = 'ITS'
    for update nowait;

CURSOR c3 is
    select hold_source_id
    from so_hold_sources
    where  hold_entity_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    and hold_entity_code = 'S'
    for update nowait;

CURSOR c4 is
    select hold_source_id
    from so_hold_sources
    where  hold_entity_id in (select m.duplicate_id
                                 from   ra_customer_merges  m
                                 where  m.process_flag = 'N'
			         and    m.request_id = req_id
			         and    m.set_number = set_num)
    and hold_entity_code = 'C'
    for update nowait;

BEGIN

  arp_message.set_line( 'OEP_CMERGE_OEHLD.OE_HS()+' );

/*-----------------------------+
 | SO_HOLD_SOURCES            |
 +-----------------------------*/
/* both customer and site level */

IF( process_mode = 'LOCK' ) THEN

  arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_HOLD_SOURCES', FALSE );

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
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_HOLD_SOURCES', FALSE );

    UPDATE SO_HOLD_SOURCES  a
    set (hold_entity_id) = (select distinct m.customer_site_id
                                   from   ra_customer_merges m
                                   where  a.hold_entity_id =
                                                 m.duplicate_site_id
			           and    m.request_id = req_id
                                   and    m.process_flag = 'N'
			           and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  hold_entity_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    and hold_entity_code = 'STS';

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );


/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_HOLD_SOURCES', FALSE );

    UPDATE SO_HOLD_SOURCES  a
    set (hold_entity_id) = (select distinct m.customer_site_id
                                   from   ra_customer_merges m
                                   where  a.hold_entity_id =
                                                 m.duplicate_site_id
			           and    m.request_id = req_id
                                   and    m.process_flag = 'N'
			           and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  hold_entity_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    and hold_entity_code = 'ITS';

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );


/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_HOLD_SOURCES', FALSE );

    UPDATE SO_HOLD_SOURCES  a
    set (hold_entity_id) = (select distinct m.customer_site_id
                                   from   ra_customer_merges m
                                   where  a.hold_entity_id =
                                                 m.duplicate_site_id
			           and    m.request_id = req_id
                                   and    m.process_flag = 'N'
			           and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  hold_entity_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    and hold_entity_code = 'S';

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );


/* customer level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_HOLD_SOURCES', FALSE );

    UPDATE SO_HOLD_SOURCES  a
    set    hold_entity_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.hold_entity_id =
				 		m.duplicate_id
                                and    m.process_flag = 'N'
			        and    m.request_id = req_id
			        and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  hold_entity_id in (select m.duplicate_id
                                 from   ra_customer_merges  m
                                 where  m.process_flag = 'N'
			         and    m.request_id = req_id
			         and    m.set_number = set_num)
    and hold_entity_code = 'C';

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

  arp_message.set_line( 'OEP_CMERGE_OEHLD.OE_HS()-' );


EXCEPTION
  when others then
    arp_message.set_error( 'OEP_CMERGE_OEHLD.OE_HS');
    raise;

END;



/*---------------------------- PUBLIC ROUTINES ------------------------------*/


  PROCEDURE MERGE (REQ_ID NUMBER, SET_NUM NUMBER, PROCESS_MODE VARCHAR2) IS
  BEGIN

  arp_message.set_line( 'OEP_CMERGE_OEHLD.MERGE()+' );

  oe_hs( req_id, set_num, process_mode );

  arp_message.set_line( 'OEP_CMERGE_OEHLD.MERGE()-' );

EXCEPTION
  when others then
    raise;

  END MERGE;
END OEP_CMERGE_OEHLD;

/
