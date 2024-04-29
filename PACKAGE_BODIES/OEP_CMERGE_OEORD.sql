--------------------------------------------------------
--  DDL for Package Body OEP_CMERGE_OEORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OEP_CMERGE_OEORD" AS
/* $Header: oeordpb.pls 115.1 99/07/26 11:08:35 porting shi $ */


/*---------------------------- PRIVATE VARIABLES ----------------------------*/
  g_count		NUMBER := 0;


/*--------------------------- PRIVATE ROUTINES ------------------------------*/


PROCEDURE oe_sh (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is

CURSOR c1 is
    select header_id
    from so_headers
    where  ship_to_site_use_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    for update nowait;

CURSOR c2 is
    select header_id
    from so_headers
    where  invoice_to_site_use_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    for update nowait;

CURSOR c3 is
    select header_id
    from so_headers
    where  customer_id in (select m.duplicate_id
                                 from   ra_customer_merges  m
                                 where  m.process_flag = 'N'
			         and    m.request_id = req_id
			         and    m.set_number = set_num)
    for update nowait;

BEGIN

  arp_message.set_line( 'OEP_CMERGE_OEORD.OE_SH()+' );

/*-----------------------------+
 | SO_HEADERS            |
 +-----------------------------*/
/* both customer and site level */

IF( process_mode = 'LOCK' ) THEN

  arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_HEADERS', FALSE );

  open c1;
  close c1;

  open c2;
  close c2;

  open c3;
  close c3;

ELSE


/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_HEADERS', FALSE );

    UPDATE SO_HEADERS  a
    set (ship_to_site_use_id) = (select distinct m.customer_site_id
                                   from   ra_customer_merges m
                                   where  a.ship_to_site_use_id =
                                                 m.duplicate_site_id
			           and    m.request_id = req_id
                                   and    m.process_flag = 'N'
			           and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where  ship_to_site_use_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num);

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_HEADERS', FALSE );

    UPDATE SO_HEADERS  a
    set (invoice_to_site_use_id) = (select distinct m.customer_site_id
                                   from   ra_customer_merges m
                                   where  a.invoice_to_site_use_id =
                                                 m.duplicate_site_id
			           and    m.request_id = req_id
                                   and    m.process_flag = 'N'
			           and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
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
  arp_message.set_token( 'TABLE_NAME', 'SO_HEADERS', FALSE );

    UPDATE SO_HEADERS  a
    set    customer_id = (select distinct m.customer_id
                                from   ra_customer_merges m
                                where  a.customer_id =
				 		m.duplicate_id
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
    where  customer_id in (select m.duplicate_id
                                 from   ra_customer_merges  m
                                 where  m.process_flag = 'N'
			         and    m.request_id = req_id
			         and    m.set_number = set_num);

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

  arp_message.set_line( 'OEP_CMERGE_OEORD.OE_SH()-' );


EXCEPTION
  when others then
    arp_message.set_error( 'OEP_CMERGE_OEORD.OE_SH');
    raise;

END;



PROCEDURE oe_sl (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is

CURSOR c1 is
    select line_id
    from so_lines
    where  ship_to_site_use_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    for update nowait;

BEGIN

  arp_message.set_line( 'OEP_CMERGE_OEORD.OE_SL()+' );

/*-----------------------------+
 | SO_LINES            |
 +-----------------------------*/
/* both customer and site level */

IF( process_mode = 'LOCK' ) THEN

  arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_LINES', FALSE );

  open c1;
  close c1;

ELSE


/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_LINES', FALSE );

    UPDATE SO_LINES  a
    set (ship_to_site_use_id) = (select distinct m.customer_site_id
                                   from   ra_customer_merges m
                                   where  a.ship_to_site_use_id =
                                                 m.duplicate_site_id
			           and    m.request_id = req_id
                                   and    m.process_flag = 'N'
			           and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login,
           request_id = req_id,
           program_application_id =arp_standard.profile.program_application_id,
           program_id = arp_standard.profile.program_id,
           program_update_date = sysdate
    where  ship_to_site_use_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num);

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

  arp_message.set_line( 'OEP_CMERGE_OEORD.OE_SL()-' );


EXCEPTION
  when others then
    arp_message.set_error( 'OEP_CMERGE_OEORD.OE_SL');
    raise;

END;

PROCEDURE oe_sd (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is

CURSOR c1 is
    select line_service_detail_id
    from so_line_service_details
    where  installation_site_use_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    for update nowait;

BEGIN

  arp_message.set_line( 'OEP_CMERGE_OEORD.OE_SD()+' );

/*-----------------------------+
 | SO_LINE_SERVICE_DETAILS            |
 +-----------------------------*/
/* both customer and site level */

IF( process_mode = 'LOCK' ) THEN

  arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_LINE_SERVICE_DETAILS', FALSE );

  open c1;
  close c1;

ELSE


/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_LINE_SERVICE_DETAILS', FALSE );

    UPDATE SO_LINE_SERVICE_DETAILS  a
    set (installation_site_use_id) = (select distinct m.customer_site_id
                                   from   ra_customer_merges m
                                   where  a.installation_site_use_id =
                                                 m.duplicate_site_id
			           and    m.request_id = req_id
                                   and    m.process_flag = 'N'
			           and    m.set_number = set_num),
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           last_update_login = arp_standard.profile.last_update_login
    where  installation_site_use_id in (select m.duplicate_site_id
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num);

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );

END IF;

  arp_message.set_line( 'OEP_CMERGE_OEORD.OE_SD()-' );


EXCEPTION
  when others then
    arp_message.set_error( 'OEP_CMERGE_OEORD.OE_SD');
    raise;

END;


PROCEDURE oe_oa (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is

CURSOR c1 is
    select order_approval_id
    from so_order_approvals
    where  customer_id in (select m.duplicate_id
                                 from   ra_customer_merges  m
                                 where  m.process_flag = 'N'
			         and    m.request_id = req_id
			         and    m.set_number = set_num)
    for update nowait;

BEGIN

  arp_message.set_line( 'OEP_CMERGE_OEORD.OE_OA()+' );

/*-----------------------------+
 | SO_ORDER_APPROVALS            |
 +-----------------------------*/
/* both customer and site level */

IF( process_mode = 'LOCK' ) THEN

  arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_ORDER_APPROVALS', FALSE );

  open c1;
  close c1;

ELSE

/* customer level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_ORDER_APPROVALS', FALSE );

    UPDATE SO_ORDER_APPROVALS  a
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

  arp_message.set_line( 'OEP_CMERGE_OEORD.OE_OA()-' );


EXCEPTION
  when others then
    arp_message.set_error( 'OEP_CMERGE_OEORD.OE_OA');
    raise;

END;


PROCEDURE oe_vr (req_id NUMBER, set_num NUMBER, process_mode VARCHAR2) is

CURSOR c1 is
    select standard_value_rule_id
    from so_standard_value_rules
    where  attribute_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    and standard_value_source_id = 1
    and attribute_id = 10026
    for update nowait;

CURSOR c2 is
    select standard_value_rule_id
    from so_standard_value_rules
    where  attribute_value in (select to_char(m.duplicate_site_id)
                                    from   ra_customer_merges  m
                                    where  m.process_flag = 'N'
			            and    m.request_id = req_id
			            and    m.set_number = set_num)
    and standard_value_source_id = 1
    and attribute_id = 10028
    for update nowait;


BEGIN

  arp_message.set_line( 'OEP_CMERGE_OEORD.OE_VR()+' );



/*-----------------------------+
 | SO_STANDARD_VALUE_RULES            |
 +-----------------------------*/
/* both customer and site level */

IF( process_mode = 'LOCK' ) THEN

  arp_message.set_name( 'AR', 'AR_LOCKING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_STANDARD_VALUE_RULES', FALSE );

  open c1;
  close c1;


  open c2;
  close c2;

ELSE


/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_STANDARD_VALUE_RULES', FALSE );



    UPDATE SO_STANDARD_VALUE_RULES  a
    set attribute_value = (select distinct to_char(m.customer_site_id)
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
    and standard_value_source_id = 1
    and attribute_id = 10026;

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );


/* site level update */
  arp_message.set_name( 'AR', 'AR_UPDATING_TABLE');
  arp_message.set_token( 'TABLE_NAME', 'SO_STANDARD_VALUE_RULES', FALSE );



    UPDATE SO_STANDARD_VALUE_RULES  a
    set attribute_value = (select distinct to_char(m.customer_site_id)
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
    and standard_value_source_id = 1
    and attribute_id = 10028;

  g_count := sql%rowcount;

  arp_message.set_name( 'AR', 'AR_ROWS_UPDATED' );
  arp_message.set_token( 'NUM_ROWS', to_char(g_count) );


END IF;

  arp_message.set_line( 'OEP_CMERGE_OEORD.OE_VR()-' );


EXCEPTION
  when others then
    arp_message.set_error( 'OEP_CMERGE_OEORD.OE_VR');
    raise;

END;



/*---------------------------- PUBLIC ROUTINES ------------------------------*/


  PROCEDURE MERGE (REQ_ID NUMBER, SET_NUM NUMBER, PROCESS_MODE VARCHAR2) IS
  BEGIN

  arp_message.set_line( 'OEP_CMERGE_OEORD.MERGE()+' );

  oe_sh( req_id, set_num, process_mode );
  oe_sl( req_id, set_num, process_mode );
  oe_oa( req_id, set_num, process_mode );
  oe_sd( req_id, set_num, process_mode );
  oe_vr( req_id, set_num, process_mode );

  arp_message.set_line( 'OEP_CMERGE_OEORD.MERGE()-' );

EXCEPTION
  when others then
    raise;

  END MERGE;
END OEP_CMERGE_OEORD;

/
