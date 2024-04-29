--------------------------------------------------------
--  DDL for Package Body OEP_CMERGE_OENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OEP_CMERGE_OENTS" AS
/* $Header: oentspb.pls 115.1 99/07/16 08:27:17 porting shi $ */


/*---------------------------- PRIVATE VARIABLES ----------------------------*/
  g_count		NUMBER := 0;


/*--------------------------- PRIVATE ROUTINES ------------------------------*/

PROCEDURE oe_ar (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is

CURSOR c1 is
    select note_id
    from so_note_addition_rules
    where  entity_value in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    and entity_id = 1009
    for update nowait;

CURSOR c2 is
    select note_id
    from so_note_addition_rules
    where  entity_value in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    and entity_id = 1008
    for update nowait;

CURSOR c3 is
    select note_id
    from so_note_addition_rules
    where  entity_value in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    and entity_id = 1007
    for update nowait;

CURSOR c4 is
    select note_id
    from so_note_addition_rules
    where  entity_value in (select m.duplicate_id
                                 from   ra_customer_merges  m
                                 where  m.process_flag = 'N'
			         and    m.request_id = req_id
			         and    m.set_number = set_num)
    and entity_id = 1000
    for update nowait;

BEGIN

  arp_message.set_line( 'OEP_CMERGE_OENTS.OE_AR()+' );

/*-----------------------------+
 | SO_NOTE_ADDITION_RULES            |
 +-----------------------------*/
/* both customer and site level */

IF( process_mode = 'LOCK' ) THEN

  arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_NOTE_ADDITION_RULES', FALSE );

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
  arp_message.set_token( 'TABLE_NAME', 'SO_NOTE_ADDITION_RULES', FALSE );

    UPDATE SO_NOTE_ADDITION_RULES  a
    set (entity_value) = (select distinct m.customer_site_id
                                   from   ra_customer_merges m
                                   where  a.entity_value =
                                                 m.duplicate_site_id
			           and    m.request_id = req_id
                                   and    m.process_flag = 'N'
			           and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  entity_value in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    and entity_id = 1009;

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );


/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_NOTE_ADDITION_RULES', FALSE );

    UPDATE SO_NOTE_ADDITION_RULES  a
    set (entity_value) = (select distinct m.customer_site_id
                                   from   ra_customer_merges m
                                   where  a.entity_value =
                                                 m.duplicate_site_id
			           and    m.request_id = req_id
                                   and    m.process_flag = 'N'
			           and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  entity_value in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    and entity_id = 1008;

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );


/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_NOTE_ADDITION_RULES', FALSE );

    UPDATE SO_NOTE_ADDITION_RULES  a
    set (entity_value) = (select distinct m.customer_site_id
                                   from   ra_customer_merges m
                                   where  a.entity_value =
                                                 m.duplicate_site_id
			           and    m.request_id = req_id
                                   and    m.process_flag = 'N'
			           and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  entity_value in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    and entity_id = 1003;

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );


/* customer level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_NOTE_ADDITION_RULES', FALSE );

    UPDATE SO_NOTE_ADDITION_RULES  a
    set    entity_value = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.entity_value =
				 		m.duplicate_id
                                and    m.process_flag = 'N'
			        and    m.request_id = req_id
			        and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  entity_value in (select m.duplicate_id
                                 from   ra_customer_merges  m
                                 where  m.process_flag = 'N'
			         and    m.request_id = req_id
			         and    m.set_number = set_num)
    and entity_id = 1000;

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

  arp_message.set_line( 'OEP_CMERGE_OENTS.OE_AR()-' );


EXCEPTION
  when others then
    arp_message.set_error( 'OEP_CMERGE_OENTS.OE_AR');
    raise;

END;


/*---------------------------- PUBLIC ROUTINES ------------------------------*/


  PROCEDURE MERGE (REQ_ID NUMBER, SET_NUM NUMBER, PROCESS_MODE VARCHAR2) IS
  BEGIN

  arp_message.set_line( 'OEP_CMERGE_OEORD.MERGE()+' );

  oe_ar( req_id, set_num, process_mode );

  arp_message.set_line( 'OEP_CMERGE_OENTS.MERGE()-' );

EXCEPTION
  when others then
    raise;

  END MERGE;
END OEP_CMERGE_OENTS;

/
