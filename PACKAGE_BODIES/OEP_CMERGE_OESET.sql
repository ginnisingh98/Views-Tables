--------------------------------------------------------
--  DDL for Package Body OEP_CMERGE_OESET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OEP_CMERGE_OESET" AS
/* $Header: oesetpb.pls 115.1 99/07/16 08:28:03 porting shi $ */

/*---------------------------- PRIVATE VARIABLES ----------------------------*/
  g_count		NUMBER := 0;


/*--------------------------- PRIVATE ROUTINES ------------------------------*/

PROCEDURE oe_ag (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is

CURSOR c1 is
    select agreement_id
    from so_agreements
    where  invoice_to_site_use_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    for update nowait;

CURSOR c2 is
    select agreement_id
    from so_agreements
    where  customer_id in (select m.duplicate_id
                                 from   ra_customer_merges  m
                                 where  m.process_flag = 'N'
			         and    m.request_id = req_id
			         and    m.set_number = set_num)
    for update nowait;

BEGIN

  arp_message.set_line( 'OEP_CMERGE_OESET.OE_AG()+' );

/*-----------------------------+
 | SO_AGREEMENTS            |
 +-----------------------------*/
/* both customer and site level */

IF( process_mode = 'LOCK' ) THEN

  arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_AGREEMENTS', FALSE );

  open c1;
  close c1;

  open c2;
  close c2;

ELSE


/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_AGREEMENTS', FALSE );

    UPDATE SO_AGREEMENTS  a
    set (invoice_to_site_use_id) = (select distinct m.customer_site_id
                                   from   ra_customer_merges m
                                   where  a.invoice_to_site_use_id =
                                                 m.duplicate_site_id
			           and    m.request_id = req_id
                                   and    m.process_flag = 'N'
			           and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  invoice_to_site_use_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num);

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

/* customer level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_AGREEMENTS', FALSE );

    UPDATE SO_AGREEMENTS  a
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

  arp_message.set_line( 'OEP_CMERGE_OESET.OE_AG()-' );


EXCEPTION
  when others then
    arp_message.set_error( 'OEP_CMERGE_OESET.OE_AG');
    raise;

END;


/*---------------------------- PUBLIC ROUTINES ------------------------------*/

  PROCEDURE MERGE (REQ_ID NUMBER, SET_NUM NUMBER, PROCESS_MODE VARCHAR2) IS
  BEGIN

  arp_message.set_line( 'OEP_CMERGE_OESET.MERGE()+' );

  oe_ag( req_id, set_num, process_mode );

  arp_message.set_line( 'OEP_CMERGE_OESET.MERGE()-' );

EXCEPTION
  when others then
    raise;

END merge;
END OEP_CMERGE_OESET;

/
