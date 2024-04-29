--------------------------------------------------------
--  DDL for Package Body ARP_CREDIT_MEMO_MODULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CREDIT_MEMO_MODULE" AS
/* $Header: ARTECMMB.pls 120.59.12010000.14 2010/03/22 10:16:15 aghoraka ship $ */
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'Y');

------------------------------------------------------------------------
-- Private types
------------------------------------------------------------------------
-- Constants
--
-- Linefeed character
--
CRLF            CONSTANT VARCHAR2(1) := arp_global.CRLF;

MSG_LEVEL_BASIC 	CONSTANT BINARY_INTEGER := arp_global.MSG_LEVEL_BASIC;
MSG_LEVEL_TIMING 	CONSTANT BINARY_INTEGER := arp_global.MSG_LEVEL_TIMING;
MSG_LEVEL_DEBUG 	CONSTANT BINARY_INTEGER := arp_global.MSG_LEVEL_DEBUG;
MSG_LEVEL_DEBUG2 	CONSTANT BINARY_INTEGER := arp_global.MSG_LEVEL_DEBUG2;
MSG_LEVEL_DEVELOP 	CONSTANT BINARY_INTEGER := arp_global.MSG_LEVEL_DEVELOP;

AI_MSG_LEVEL 	        CONSTANT BINARY_INTEGER := arp_global.sysparam.AI_LOG_FILE_MESSAGE_LEVEL;

YES			CONSTANT VARCHAR2(1) := arp_global.YES;
NO			CONSTANT VARCHAR2(1) := arp_global.NO;

PRORATE			CONSTANT VARCHAR2(1) := 'P';
LIFO			CONSTANT VARCHAR2(1) := 'L';
UNIT			CONSTANT VARCHAR2(1) := 'U';

I			CONSTANT VARCHAR2(1) := 'I';
U			CONSTANT VARCHAR2(1) := 'U';

--
-- User-defined exceptions
--
invalid_parameters		EXCEPTION;
invalid_mode	                EXCEPTION;
missing_periods			EXCEPTION;
overapp_not_allowed		EXCEPTION;
invalid_cm_method_for_rules     EXCEPTION;

error_defaulting_gl_date	EXCEPTION;
no_net_revenue			EXCEPTION;
cm_unit_overapp                 EXCEPTION;

inv_locked_by_another_session   EXCEPTION;
PRAGMA EXCEPTION_INIT(inv_locked_by_another_session,-54) ;
--
-- Translated error messages
--
MSG_INVALID_PARAMETERS		VARCHAR2(2000);
MSG_MISSING_PERIODS	 	VARCHAR2(2000);
MSG_OVERAPP_NOT_ALLOWED 	VARCHAR2(2000);
MSG_NO_NET_REVENUE	 	VARCHAR2(2000);

MSG_INV_LOCKED                  VARCHAR2(2000);
MSG_CM_UNIT_OVERAPP             VARCHAR2(2000);
MSG_INV_LOCKED_BY_JL            VARCHAR2(2000);



-- This record holds general information used by autoaccounting and
-- credit memo module.  Passed as argument to most functions/procs.
--
system_info arp_trx_global.system_info_rec_type :=
	arp_trx_global.system_info;

--
-- This record holds profile information used by autoaccounting and
-- credit memo module.  Passed as argument to most functions/procs.
--
profile_info arp_trx_global.profile_rec_type :=
	arp_trx_global.profile_info;


--
-- This record holds accounting flexfield information used by
-- autoaccounting and the credit memo module.  Passed as argument to
-- most functions/procs.
--
flex_info arp_trx_global.acct_flex_info_rec_type :=
	arp_trx_global.flex_info;

------------------------------------------------------------------------
-- Data structs for net revenue schedule
------------------------------------------------------------------------
TYPE net_rev_rec_type IS RECORD
(
  customer_trx_line_id	number,
  gl_date		DATE,
  amount		NUMBER,
  net_unit_price	NUMBER,
  inv_dist_exists	VARCHAR(1)
);
net_revenue_rec net_rev_rec_type;

net_rev_start_index BINARY_INTEGER;
net_rev_index BINARY_INTEGER;	-- keeps track of next row to insert

TYPE net_rev_ctlid_table_type IS
  TABLE OF net_revenue_rec.customer_trx_line_id%type
  INDEX BY BINARY_INTEGER;
net_rev_ctlid_t net_rev_ctlid_table_type;
null_net_rev_ctlid CONSTANT net_rev_ctlid_table_type := net_rev_ctlid_t;

TYPE net_rev_gl_date_table_type IS
  TABLE OF net_revenue_rec.gl_date%type
  INDEX BY BINARY_INTEGER;
net_rev_gl_date_t net_rev_gl_date_table_type;
null_net_rev_gl_date CONSTANT net_rev_gl_date_table_type := net_rev_gl_date_t;

TYPE net_rev_amount_table_type IS
  TABLE OF net_revenue_rec.amount%type
  INDEX BY BINARY_INTEGER;
net_rev_amount_t net_rev_amount_table_type;
null_net_rev_amount CONSTANT net_rev_amount_table_type := net_rev_amount_t;

TYPE net_rev_unit_table_type IS
  TABLE OF net_revenue_rec.net_unit_price%type
  INDEX BY BINARY_INTEGER;
net_rev_unit_t net_rev_unit_table_type;
null_net_rev_unit CONSTANT net_rev_unit_table_type := net_rev_unit_t;

TYPE net_rev_dist_exists_tab_type IS
  TABLE OF net_revenue_rec.inv_dist_exists%type
  INDEX BY BINARY_INTEGER;
net_rev_dist_exists_t net_rev_dist_exists_tab_type;
null_net_rev_dist_exists CONSTANT net_rev_dist_exists_tab_type :=
    net_rev_dist_exists_t;

------------------------------------------------------------------------
-- Data structs for cm schedule
------------------------------------------------------------------------
TYPE cm_schedule_rec_type IS RECORD
(
  customer_trx_line_id	NUMBER,
  gl_date		DATE,
  orig_gl_date		DATE,
  amount		NUMBER,
  insert_dist		VARCHAR2(1),
  insert_cma		VARCHAR2(1),
  insert_offset		VARCHAR2(1),
  check_gl_date		VARCHAR2(1)  -- for crediting rel9 immed invoices
);
cm_schedule_rec cm_schedule_rec_type;

cm_sched_start_index BINARY_INTEGER;
cm_sched_index BINARY_INTEGER := 0;	-- keeps track of next row to insert
cm_mrc_index INTEGER := 0;

TYPE cm_sched_ctlid_table_type IS
  TABLE OF cm_schedule_rec.customer_trx_line_id%type
  INDEX BY BINARY_INTEGER;
cm_sched_ctlid_t cm_sched_ctlid_table_type;
null_cm_sched_ctlid CONSTANT cm_sched_ctlid_table_type := cm_sched_ctlid_t;

TYPE cm_sched_gl_date_table_type IS
  TABLE OF cm_schedule_rec.gl_date%type
  INDEX BY BINARY_INTEGER;
cm_sched_gl_date_t cm_sched_gl_date_table_type;
null_cm_sched_gl_date CONSTANT cm_sched_gl_date_table_type :=
  cm_sched_gl_date_t;

TYPE cm_sched_ogl_date_table_type IS
  TABLE OF cm_schedule_rec.orig_gl_date%type
  INDEX BY BINARY_INTEGER;
cm_sched_orig_gl_date_t cm_sched_ogl_date_table_type;
null_cm_sched_orig_gl_date CONSTANT cm_sched_ogl_date_table_type :=
  cm_sched_orig_gl_date_t;

TYPE cm_sched_amount_table_type IS
  TABLE OF cm_schedule_rec.amount%type
  INDEX BY BINARY_INTEGER;
cm_sched_amount_t cm_sched_amount_table_type;
null_cm_sched_amount CONSTANT cm_sched_amount_table_type := cm_sched_amount_t;

TYPE cm_sched_insert_dist_tab_type IS
  TABLE OF cm_schedule_rec.insert_dist%type
  INDEX BY BINARY_INTEGER;
cm_sched_insert_dist_t cm_sched_insert_dist_tab_type;
null_cm_sched_insert_dist CONSTANT cm_sched_insert_dist_tab_type :=
    cm_sched_insert_dist_t;

TYPE cm_sched_insert_cma_tab_type IS
  TABLE OF cm_schedule_rec.insert_cma%type
  INDEX BY BINARY_INTEGER;
cm_sched_insert_cma_t cm_sched_insert_cma_tab_type;
null_cm_sched_insert_cma CONSTANT cm_sched_insert_cma_tab_type :=
    cm_sched_insert_cma_t;

TYPE cm_sched_ins_offset_tab_type IS
  TABLE OF cm_schedule_rec.insert_offset%type
  INDEX BY BINARY_INTEGER;
cm_sched_insert_offset_t cm_sched_ins_offset_tab_type;
null_cm_sched_insert_offset CONSTANT cm_sched_ins_offset_tab_type :=
    cm_sched_insert_offset_t;

TYPE cm_sched_check_gld_tab_type IS
  TABLE OF cm_schedule_rec.check_gl_date%type
  INDEX BY BINARY_INTEGER;
cm_sched_check_gl_date_t cm_sched_check_gld_tab_type;
null_cm_sched_check_gl_date CONSTANT cm_sched_check_gld_tab_type :=
    cm_sched_check_gl_date_t;

TYPE cm_mrc_cust_trx_line_id_type IS
  TABLE OF ra_customer_trx_lines.customer_trx_line_id%type
  INDEX BY BINARY_INTEGER;
mrc_cm_cust_trx_line_id cm_mrc_cust_trx_line_id_type;
mrc_cust_line_id  ra_customer_trx_lines.customer_trx_line_id%TYPE;


--
--
--
TYPE control_rec_type IS RECORD
(
  customer_trx_id		BINARY_INTEGER,
  customer_trx_line_id		NUMBER,
  prev_customer_trx_id		BINARY_INTEGER,
  prev_cust_trx_line_id		NUMBER,
  request_id			BINARY_INTEGER
);

--
-- To hold values fetched from the Select stmt
--
TYPE select_rec_type IS RECORD
(
  customer_trx_line_id		NUMBER,
  prev_cust_trx_line_id		NUMBER,
  allow_overapp_flag	ra_cust_trx_types.allow_overapplication_flag%type,
  cm_amount			NUMBER,
  credit_method_for_rules	VARCHAR2(1),
  last_period_to_credit   	NUMBER,
  currency_code			ra_customer_trx.invoice_currency_code%type,
  inv_acct_rule_duration	NUMBER,
  allow_not_open_flag		VARCHAR2(1),
  partial_period_flag		VARCHAR2(1),
  cm_gl_date			DATE,
  invoice_quantity		NUMBER,
  cm_quantity			NUMBER,
  invoice_sign			NUMBER, -- 3198525 from char(1) to number
  cm_sign			NUMBER, -- 3198525 from char(1) to number
  rule_start_date		DATE,  -- output only
  rule_end_date		        DATE,  -- output only
  cm_acct_rule_duration		NUMBER, -- output only
  inv_unit_price                NUMBER, -- 4621029
  cm_unit_price                 NUMBER, -- 4621029
  inv_rule_end_date		DATE    -- 9478772
);

/* Bug 2560036 - Control test of collectibility */
g_test_collectibility BOOLEAN;
/* Bug 2347001 - unique identifier for each use of global tmp table */
g_session_id      NUMBER := 0;
/* Bug 4633761 - stored inv line id for array processing */
g_prev_ctlid      NUMBER := 0;

/* 6678560 - booleans to control finds for dynamic sql */
g_bind_line_14     BOOLEAN;  -- line_id binds 1-4
g_bind_trx_12      BOOLEAN;  -- trx_id binds 1-2
g_bind_req_12      BOOLEAN;  -- req_id binds 1-2
g_bind_trx_3       BOOLEAN;  -- trx_id bind 3 (inline)
g_bind_req_3       BOOLEAN;  -- req_id bind 3

------------------------------------------------------------------------
-- Private cursors
------------------------------------------------------------------------
nonrule_insert_dist_c    	INTEGER;
nonrule_update_lines_c  	INTEGER;
nonrule_update_dist_c  	        INTEGER;
nonrule_update_dist2_c  	INTEGER;

rule_select_cm_lines_c  	INTEGER;
rule_update_cm_lines_c 		INTEGER;
rule_insert_dist_c 		INTEGER;
rule_insert_cma_c 		INTEGER;

net_revenue_line_c              INTEGER;

delete_header_dist_c		INTEGER;
delete_line_dist_c		INTEGER;
delete_header_cma_c		INTEGER;
delete_line_cma_c		INTEGER;
update_header_lines_c		INTEGER;
update_lines_c			INTEGER;

/*  Bug 3477990 */
pg_closed_period_exists 	VARCHAR2(1) := NULL;

------------------------------------------------------------------------
-- Covers
------------------------------------------------------------------------
PROCEDURE debug( p_line IN VARCHAR2 ) IS
BEGIN
     arp_standard.debug( p_line );
END;
--
PROCEDURE debug(
	p_str VARCHAR2,
	p_print_level BINARY_INTEGER ) IS
BEGIN
     arp_standard.debug( p_str );
END;
--
PROCEDURE enable_debug IS
BEGIN
  arp_standard.enable_debug;
END;
--
PROCEDURE enable_debug( buffer_size NUMBER ) IS
BEGIN
  arp_standard.enable_debug;
END;
--
PROCEDURE disable_debug IS
BEGIN
  arp_util.disable_debug;
END;
--
PROCEDURE print_fcn_label( p_label VARCHAR2 ) IS
BEGIN
     arp_standard.debug( p_label );
END;
--
PROCEDURE print_fcn_label2( p_label VARCHAR2 ) IS
BEGIN
     arp_standard.debug( p_label );
END;
--
PROCEDURE close_cursor( p_cursor_handle IN OUT NOCOPY INTEGER ) IS
BEGIN
    arp_util.close_cursor( p_cursor_handle );
END;


----------------------------------------------------------------------------
-- Functions and Procedures
----------------------------------------------------------------------------
PROCEDURE close_cursors IS
BEGIN
    close_cursor( nonrule_insert_dist_c );
    close_cursor( nonrule_update_lines_c );
    close_cursor( nonrule_update_dist_c );
    close_cursor( nonrule_update_dist2_c );

    close_cursor( rule_select_cm_lines_c );
    close_cursor( rule_update_cm_lines_c );
    close_cursor( rule_insert_dist_c );
    close_cursor( rule_insert_cma_c );

    close_cursor( net_revenue_line_c );
END;


PROCEDURE insert_into_error_table(
	p_interface_line_id NUMBER,
	p_message_text varchar2,
	p_invalid_value varchar2 )  IS

BEGIN

    INSERT INTO ra_interface_errors
    (interface_line_id,
     message_text,
     invalid_value,
     org_id)
    VALUES
    (p_interface_line_id,
     p_message_text,
     p_invalid_value,
     arp_standard.sysparm.org_id);

END insert_into_error_table;

----------------------------------------------------------------------------
PROCEDURE get_error_message_text is

    l_msg_name	   VARCHAR2(100);

BEGIN

    print_fcn_label( 'arp_credit_memo_module.get_error_message_text()+' );

    ---
    l_msg_name := 'AR-CREDMEMO_ACTION_PARAM';
    fnd_message.set_name('AR', l_msg_name);
    MSG_INVALID_PARAMETERS := fnd_message.get;

     ----
    l_msg_name := 'JL_BR_EI_CREDIT_ERROR';
    fnd_message.set_name('JL', l_msg_name);
    MSG_INV_LOCKED_BY_JL := fnd_message.get;

    ----
    l_msg_name := 'AR_RAXTRX-1783';
    fnd_message.set_name('AR', l_msg_name);
    MSG_MISSING_PERIODS := fnd_message.get;

    ----
    l_msg_name := 'AR_CKAP_OVERAPP';
    fnd_message.set_name('AR', l_msg_name);
    MSG_OVERAPP_NOT_ALLOWED := fnd_message.get;

    ----
    l_msg_name := 'AR_CREDMEMO_NO_NET_REV';
    fnd_message.set_name('AR', l_msg_name);
    MSG_NO_NET_REVENUE := fnd_message.get;

    ----
    l_msg_name := 'AR_RAXTRX-1801';
    fnd_message.set_name('AR', l_msg_name);
    MSG_INV_LOCKED := fnd_message.get;

    /* 4621029 */
    l_msg_name := 'AR_RAXTRX_UNIT_OVERAPP';
    fnd_message.set_name('AR', l_msg_name);
    MSG_CM_UNIT_OVERAPP := fnd_message.get;

    -- print
    debug( 'MSG_INVALID_PARAMETERS='||MSG_INVALID_PARAMETERS,
	MSG_LEVEL_DEBUG );
    debug( 'MSG_MISSING_PERIODS='||MSG_MISSING_PERIODS,
	MSG_LEVEL_DEBUG );
    debug( 'MSG_OVERAPP_NOT_ALLOWED='||MSG_OVERAPP_NOT_ALLOWED,
	MSG_LEVEL_DEBUG );
    debug( 'MSG_NO_NET_REVENUE='||MSG_NO_NET_REVENUE,
	MSG_LEVEL_DEBUG );

    debug( 'MSG_INV_LOCKED='||MSG_INV_LOCKED,
        MSG_LEVEL_DEBUG );
    debug( 'MSG_INV_LOCKED_BY_JL='||MSG_INV_LOCKED_BY_JL,
        MSG_LEVEL_DEBUG );
    debug( 'MSG_CM_UNIT_OVERAPP='||MSG_CM_UNIT_OVERAPP,
        MSG_LEVEL_DEBUG );

    print_fcn_label( 'arp_credit_memo_module.get_error_message_text()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_credit_memo_module.get_error_message_text()');
        RAISE;
END get_error_message_text;

/* 6129294 - function to validate gl_dates that were overridden
     by user in revenue accounting */
FUNCTION get_valid_date(p_gl_date IN DATE,
                        p_inv_rule_id IN NUMBER,
                        p_set_of_books_id IN NUMBER) RETURN date
IS
   l_gl_date              DATE;
   l_defaulting_rule_used VARCHAR2(100);
   l_error_message        VARCHAR2(512);
BEGIN
   IF arp_standard.validate_and_default_gl_date(
                                        p_gl_date,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        'N',
                                        p_inv_rule_id,
                                        p_set_of_books_id,
                                        222,
                                        l_gl_date,
                                        l_defaulting_rule_used,
                                        l_error_message)
   THEN
      IF PG_DEBUG in ('Y', 'C')
      THEN
          debug('get_valid_date() rule=' || l_defaulting_rule_used ||
                '  date=' || l_gl_date);
      END IF;
      RETURN l_gl_date;
   END IF;

   /* If it reaches here, then the date could not be defaulted, so
      return null */
   IF PG_DEBUG in ('Y','C')
   THEN
       debug('get_valid_date() failure - date=' || p_gl_date ||
             '  error=' || l_error_message);
   END IF;
   RETURN NULL;
END get_valid_date;

----------------------------------------------------------------------------
PROCEDURE build_update_mode_sql(
        p_delete_header_dist_c	 	IN OUT NOCOPY INTEGER,
        p_delete_line_dist_c	 	IN OUT NOCOPY INTEGER,
        p_delete_header_cma_c	 	IN OUT NOCOPY INTEGER,
        p_delete_line_cma_c	 	IN OUT NOCOPY INTEGER,
        p_update_header_lines_c	 	IN OUT NOCOPY INTEGER,
        p_update_lines_c	 	IN OUT NOCOPY INTEGER  ) IS

    l_delete_header_dist_sql   	VARCHAR2(1000);
    l_delete_line_dist_sql   	VARCHAR2(1000);
    l_delete_header_cma_sql   	VARCHAR2(1000);
    l_delete_line_cma_sql   	VARCHAR2(1000);
    l_update_header_lines_sql   VARCHAR2(1000);
    l_update_lines_sql   	VARCHAR2(1000);


BEGIN

    print_fcn_label( 'arp_credit_memo_module.build_update_mode_sql()+' );

    l_delete_header_dist_sql :=
'DELETE from ra_cust_trx_line_gl_dist
WHERE  customer_trx_id = :customer_trx_id
and    account_class    <> ''REC''
and    account_set_flag = ''N'' ';

    /* add returning clause for mrc */
    l_delete_header_dist_sql := l_delete_header_dist_sql ||
          ' RETURNING cust_trx_line_gl_dist_id INTO :gl_dist_key_value ';

    debug(l_delete_header_dist_sql);
    debug('  len(delete_header_dist_sql) = '||
          to_char(lengthb(l_delete_header_dist_sql)));


    l_delete_line_dist_sql :=
'DELETE from ra_cust_trx_line_gl_dist
WHERE  customer_trx_line_id = :customer_trx_line_id
AND    account_set_flag = ''N'' ';

    /* add returning clause for mrc */
    l_delete_line_dist_sql := l_delete_line_dist_sql ||
          ' RETURNING cust_trx_line_gl_dist_id INTO :gl_dist_key_value ';

    debug(l_delete_line_dist_sql);
    debug('  len(delete_line_dist_sql) = '||
          to_char(lengthb(l_delete_line_dist_sql)));

    l_delete_header_cma_sql :=
'DELETE from ar_credit_memo_amounts
WHERE  customer_trx_line_id in
(SELECT customer_trx_line_id
 FROM   ra_customer_trx_lines
 WHERE  line_type = ''LINE''
 and    customer_trx_id = :customer_trx_id)';

    debug(l_delete_header_cma_sql);
    debug('  len(delete_header_cma_sql) = '||
          to_char(lengthb(l_delete_header_cma_sql)));

    l_delete_line_cma_sql :=
'DELETE from ar_credit_memo_amounts
WHERE  customer_trx_line_id = :customer_trx_line_id';

    debug(l_delete_line_cma_sql);
    debug('  len(delete_line_cma_sql) = '||
          to_char(lengthb(l_delete_line_cma_sql)));

    l_update_header_lines_sql :=
'UPDATE ra_customer_trx_lines
SET
rule_start_date = null,
rule_end_date = null,
accounting_rule_duration = null
WHERE  customer_trx_id = :customer_trx_id
and    line_type       = ''LINE'' ';

    debug(l_update_header_lines_sql);
    debug('  len(update_header_lines_sql) = '||
          to_char(lengthb(l_update_header_lines_sql)));

    l_update_lines_sql :=
'UPDATE ra_customer_trx_lines
SET
rule_start_date = null,
rule_end_date = null,
accounting_rule_duration = null
WHERE  customer_trx_line_id = :customer_trx_line_id';

    debug(l_update_lines_sql);
    debug('  len(update_lines_sql) = '||
          to_char(lengthb(l_update_lines_sql)));


    ------------------------------------------------
    -- Parse sql stmts
    ------------------------------------------------
    BEGIN
	debug( '  Parsing update mode stmts', MSG_LEVEL_DEBUG );

        p_delete_header_dist_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_delete_header_dist_c, l_delete_header_dist_sql,
                        dbms_sql.v7 );

        p_delete_line_dist_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_delete_line_dist_c, l_delete_line_dist_sql,
                        dbms_sql.v7 );

        p_delete_header_cma_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_delete_header_cma_c, l_delete_header_cma_sql,
                        dbms_sql.v7 );

        p_delete_line_cma_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_delete_line_cma_c, l_delete_line_cma_sql,
                        dbms_sql.v7 );

        p_update_header_lines_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_update_header_lines_c, l_update_header_lines_sql,
                        dbms_sql.v7 );

        p_update_lines_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_update_lines_c, l_update_lines_sql,
                        dbms_sql.v7 );

    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error parsing update mode stmts' );
          RAISE;
    END;


    print_fcn_label( 'arp_credit_memo_module.build_update_mode_sql()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.build_update_mode_sql()' );

        RAISE;
END build_update_mode_sql;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  build_nonrule_sql
--
-- DECSRIPTION:
--
-- ARGUMENTS:
--      IN:
--        system_info
--        profile_info
--        cm_control
--
--      IN/OUT:
--        nonrule_insert_dist_c
--        nonrule_update_lines_c
--        nonrule_update_dist_c
--        nonrule_update_dist2_c
--
--      OUT:
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
/*   M Raymond   01-DEC-2004   Bug 4029814 - removed mock gl_dist_id
                               logic and allowed BRI trigger on table
                               to set IDs during insert.
*/

----------------------------------------------------------------------------
PROCEDURE build_nonrule_sql(
	p_system_info 		IN arp_trx_global.system_info_rec_type,
        p_profile_info 		IN arp_trx_global.profile_rec_type,
        p_cm_control 		IN control_rec_type,
        p_nonrule_insert_dist_c 	IN OUT NOCOPY INTEGER,
        p_nonrule_update_lines_c 	IN OUT NOCOPY INTEGER,
        p_nonrule_update_dist_c 	IN OUT NOCOPY INTEGER,
        p_nonrule_update_dist2_c 	IN OUT NOCOPY INTEGER  ) IS


    l_nonrule_insert_dist_sql   VARCHAR2(32767);
    l_nonrule_update_lines_sql  VARCHAR2(1000);
    l_nonrule_update_dist_sql   VARCHAR2(1000);
    l_nonrule_update_dist2_sql  VARCHAR2(2000);

    l_where_pred            VARCHAR2(500);
    l_rec_where_pred        VARCHAR2(500);
    l_amount_fragment       VARCHAR2(2500);
    l_dbg_buffer            VARCHAR2(500);

BEGIN

    print_fcn_label( 'arp_credit_memo_module.build_nonrule_sql()+' );

    ------------------------------------------------
    -- Initialize
    ------------------------------------------------
    g_bind_line_14 := FALSE; -- line_id (4 separate binds) used
    g_bind_trx_12  := FALSE; -- trx_id used
    g_bind_req_12  := FALSE; -- req_id used
    g_bind_trx_3   := FALSE; -- trx_id used (for inline srep join)
    g_bind_req_3   := FALSE; -- req_id used (for inline srep join)

    ------------------------------------------------
    -- Construct where predicate
    ------------------------------------------------
    IF( p_cm_control.customer_trx_line_id IS NOT NULL ) THEN
    	----------------------------------------------------
        -- Passed line id
    	----------------------------------------------------
/* bug fix 956189 */

        l_where_pred :=
'AND (ctl.customer_trx_line_id =
      :cm_cust_trx_line_id_1' || CRLF ||
'     OR
      ctl.link_to_cust_trx_line_id = :cm_cust_trx_line_id_2';

        l_rec_where_pred :=
'AND (ctl.customer_trx_line_id =
      :cm_cust_trx_line_id_3' || CRLF ||
'     OR
      ctl.link_to_cust_trx_line_id = :cm_cust_trx_line_id_4';

      g_bind_line_14 := TRUE;

        IF( p_cm_control.customer_trx_id IS NOT NULL ) THEN
    	    ------------------------------------------------
            -- Passed trx id
    	    ------------------------------------------------
/* bug fix 956189 */
            l_where_pred := l_where_pred || CRLF ||
'     OR
      ctl.link_to_cust_trx_line_id is null)
AND ctl.customer_trx_id = :cm_customer_trx_id_1';

            l_rec_where_pred := l_rec_where_pred || CRLF ||
'     OR
      ctl.link_to_cust_trx_line_id is null)
AND ctl.customer_trx_id = :cm_customer_trx_id_2';

        g_bind_trx_12 := TRUE;

        ELSE

            l_where_pred := l_where_pred || ')';
            l_rec_where_pred := l_rec_where_pred || ')';

        END IF;

    ELSE
    	----------------------------------------------------
        -- Did not pass line id
    	----------------------------------------------------
        IF( p_cm_control.customer_trx_id IS NOT NULL ) THEN

/* bug fix 956189 */
            l_where_pred :=
'AND ctl.customer_trx_id = :cm_customer_trx_id_1';

            l_rec_where_pred :=
'AND ctl.customer_trx_id = :cm_customer_trx_id_2';

            g_bind_trx_12 := TRUE;

        ELSE

            l_where_pred :=
'AND ctl.request_id = :request_id_1';

            l_rec_where_pred :=
'AND ctl.request_id = :request_id_2';

            g_bind_req_12 := TRUE;

        END IF;

    END IF;

    ------------------------------------------------
    -- Construct amount fragment
    ------------------------------------------------
    l_amount_fragment :=
'(
  nvl(
      prev_ctlgd.amount /
      decode(
             decode(prev_ctlgd.account_class,
                    ''REV'', prev_ctl.revenue_amount,
                    ''SUSPENSE'', (prev_ctl.extended_amount -
                                   prev_ctl.revenue_amount),
                    prev_ctl.extended_amount),
             0, 1,
             decode(prev_ctlgd.account_class,
                    ''REV'', prev_ctl.revenue_amount,
                    ''SUSPENSE'', (prev_ctl.extended_amount -
                                   prev_ctl.revenue_amount),
                    prev_ctl.extended_amount)
             ),
     1)) *
  decode(
         decode(prev_ctlgd.account_class,
                ''REV'',      ctl.revenue_amount,
                ''SUSPENSE'', (ctl.extended_amount -
                               ctl.revenue_amount),
                ctl.extended_amount),
         0, decode(
                   decode(prev_ctlgd.account_class,
                          ''REV'',      prev_ctl.revenue_amount,
                          ''SUSPENSE'', (ctl.extended_amount -
                                         prev_ctl.revenue_amount),
                          prev_ctl.extended_amount),
                   0, -1,
                   0),
         decode(prev_ctlgd.account_class,
                ''REV'',      ctl.revenue_amount,
                ''SUSPENSE'', (ctl.extended_amount -
                               ctl.revenue_amount),
                ctl.extended_amount)
         )' ;


    ------------------------------------------------
    -- Construct insert into ra_cust_trx_line_gl_dist
    ------------------------------------------------
    l_nonrule_insert_dist_sql :=
'INSERT into ra_cust_trx_line_gl_dist
(
  /* gl_dist_id used to be here - now populated by BRI trigger */
  customer_trx_id,               /* credit memo customer_trx_id */
  customer_trx_line_id,          /* credit memo customer_trx_line_id */
  cust_trx_line_salesrep_id,     /* id for cm srep line credited */
  request_id,
  set_of_books_id,
  last_update_date,
  last_updated_by,
  creation_date,
  created_by,
  last_update_login,
  program_application_id,
  program_id,
  program_update_date,
  account_class,               /* account class for the invoice */
                               /* assignment being credited */
  account_set_flag,
  percent,
  amount ,
  acctd_amount,
  gl_date,
  code_combination_id,
  posting_control_id,
  collected_tax_ccid,
  ussgl_transaction_code,      /*Bug 2246098*/
  revenue_adjustment_id,       /* Bug 2543675 - RAM id copied to CM dist */
  rec_offset_flag,              /* Bug 2560036 - non-collectible trans */
  org_id
) ';

    l_nonrule_insert_dist_sql := l_nonrule_insert_dist_sql || CRLF ||
'  /* Non Receivable account case */
SELECT
/* Bug 4029814 - removed gl_dist mock logic because of unique constraints */
ctl.customer_trx_id,
ctl.customer_trx_line_id,
ctls.cust_trx_line_salesrep_id,
ct.request_id,
ct.set_of_books_id,
sysdate,
ct.last_updated_by,
sysdate,
ct.created_by,
ct.last_update_login,
ct.program_application_id,            /* program_appl_id */
ct.program_id,                        /* program_id */
sysdate,                              /* program_update_date */
prev_ctlgd.account_class,
''N'',                                /* account set for rules flag */
decode(ctl.extended_amount,
       0, prev_ctlgd.percent,
       round(((decode(foreign_fc.minimum_accountable_unit,
                      null, round( ' || CRLF ||
l_amount_fragment || CRLF ||
'                                  , precision),
                      round( ' || CRLF ||
l_amount_fragment || CRLF ||
'                           / foreign_fc.minimum_accountable_unit) *
                      foreign_fc.minimum_accountable_unit
                      ) /
               decode(ctl.extended_amount, 0, 1, ctl.extended_amount)
               ) *  decode(ctl.extended_amount, 0, 0, 1)
             ) * 100, 4)
       ),                                             /* percent */
decode(foreign_fc.minimum_accountable_unit,
       null, round( ' || CRLF ||
l_amount_fragment || CRLF ||
'                   , precision),
       round( ' || CRLF ||
l_amount_fragment || CRLF ||
'              / foreign_fc.minimum_accountable_unit) *
       foreign_fc.minimum_accountable_unit
       ),                                           /* amount */';


    -------------------------------------------------------------------
    -- Construct the amounts differently depending on whether the
    -- minimum accountable unit is specified for the base currency.
    -------------------------------------------------------------------

    IF( p_system_info.base_min_acc_unit IS NULL ) THEN

        l_nonrule_insert_dist_sql := l_nonrule_insert_dist_sql || CRLF ||
'  round(decode(foreign_fc.minimum_accountable_unit,
               null, round(' || CRLF ||
l_amount_fragment || CRLF ||
'                             , precision),
               round( ' || CRLF ||
l_amount_fragment || CRLF ||
'                      / foreign_fc.minimum_accountable_unit) *
               foreign_fc.minimum_accountable_unit
               ) * nvl(ct.exchange_rate, 1),
         ' || p_system_info.base_precision || CRLF ||
'       ),                                       /* acctd_amount */';

    ELSE

        l_nonrule_insert_dist_sql := l_nonrule_insert_dist_sql || CRLF ||
'  round(decode(foreign_fc.minimum_accountable_unit,
               null, round( ' || CRLF ||
l_amount_fragment || CRLF ||
'                             , precision),
               round( ' || CRLF ||
l_amount_fragment || CRLF ||
'                      / foreign_fc.minimum_accountable_unit) *
               foreign_fc.minimum_accountable_unit
               ) * nvl(ct.exchange_rate, 1) / ' ||
fnd_number.number_to_canonical(system_info.base_min_acc_unit) || CRLF ||
'        ) * ' || fnd_number.number_to_canonical(system_info.base_min_acc_unit) || ',    /* acctd_amount */' ;


    END IF;

        l_nonrule_insert_dist_sql := l_nonrule_insert_dist_sql || CRLF ||
'  rec_ctlgd.gl_date,
  prev_ctlgd.code_combination_id,
 -3,
 prev_ctlgd.collected_tax_ccid,
 ct.default_ussgl_transaction_code,      /*Bug 2246098*/
 prev_ctlgd.revenue_adjustment_id,  /* Bug 2543675 */
 prev_ctlgd.rec_offset_flag,         /* Bug 2560036 */
 ct.org_id
FROM
fnd_currencies foreign_fc,
ar_lookups al_rules,
ra_customer_trx ct,
ra_customer_trx_lines ctl,
ra_cust_trx_line_gl_dist ctlgd,
ra_cust_trx_line_gl_dist rec_ctlgd,     /* cm rec dist */
ra_cust_trx_line_salesreps ctls,
ra_customer_trx prev_ct,
ra_customer_trx_lines prev_ctl,
ra_cust_trx_line_gl_dist prev_ctlgd,
ra_cust_trx_line_gl_dist prev_ctlgd2   /* inv rec dist */
WHERE  ct.customer_trx_id          = ctl.customer_trx_id
and    ctl.customer_trx_line_id    = ctlgd.customer_trx_line_id(+)
       /* only look at invoices without an invoicing rule */
and    al_rules.lookup_code        = ''N''
       /* join to the credit memo receivable account dist */
and    ct.customer_trx_id          = rec_ctlgd.customer_trx_id(+)
and    rec_ctlgd.account_class(+)           = ''REC''
and   rec_ctlgd.latest_rec_flag(+)         = ''Y''
       /* get currency information */
and    ct.invoice_currency_code    = foreign_fc.currency_code
       /* join to the invoice */
and    ctl.previous_customer_trx_line_id
                                   = prev_ctl.customer_trx_line_id
and    prev_ctl.customer_trx_id    = prev_ctlgd2.customer_trx_id
and    prev_ctl.customer_trx_line_id
                                 = prev_ctlgd.customer_trx_line_id
and    prev_ctl.customer_trx_id  = prev_ct.customer_trx_id
       /* join for cust_trx_line_salesrep_id */';

    -------------------------------------------------------------------
    --  Add predicate based on input parameters
    -------------------------------------------------------------------
    IF( p_cm_control.customer_trx_id IS NOT NULL ) THEN

/* bug fix 956189 */
        l_nonrule_insert_dist_sql := l_nonrule_insert_dist_sql || CRLF ||
'and    :cm_customer_trx_id_3 = ctls.customer_trx_id(+)';

        g_bind_trx_3 := TRUE;

    ELSE

        l_nonrule_insert_dist_sql := l_nonrule_insert_dist_sql || CRLF ||
'and    :request_id_3 = ctls.request_id(+)';

        g_bind_req_3 := TRUE;

    END IF;

    l_nonrule_insert_dist_sql := l_nonrule_insert_dist_sql || CRLF ||
'and    prev_ctlgd.cust_trx_line_salesrep_id
                        =   ctls.prev_cust_trx_line_salesrep_id(+)
       /* do not duplicate existing records */
and    ctlgd.account_set_flag(+)            = ''N''
and    ctlgd.customer_trx_id                is null
and    ctl.previous_customer_trx_line_id    is not null
and    al_rules.lookup_type                 =  ''YES/NO''
     /* Use the presence of an invoicing rule to determine if the invoice has
        accounting rules, not the presence of an UNEARN/UNBILL distribution */
and    al_rules.lookup_code = DECODE(prev_ct.invoicing_rule_id,NULL,''N'',''Y'')
     /* Do not backout account sets for rules records.
        However, do use the account set record if this
        is a header frt only CM against an invoice with rules. */
and    prev_ctlgd.account_set_flag  =
       decode(prev_ct.invoicing_rule_id, '''', ''N'', decode(al_rules.lookup_code,''N'',''N'',''Y''))
       /* insure that prev_ctlgd2 is the invoice rec record */
and    prev_ctlgd2.customer_trx_line_id+0   is null
and    prev_ctlgd2.account_class  = ''REC''
and    prev_ctlgd2.account_set_flag = al_rules.lookup_code
       /* only reverse records in the invoice header gl date */
and    (prev_ctl.accounting_rule_id is null
        OR
        nvl(prev_ctlgd.gl_date,
           nvl(prev_ctlgd2.gl_date,
               to_date(''2415386'', ''J'')) ) =
            nvl(prev_ctlgd2.gl_date,  to_date(''2415386'',
                                              ''J'')) )
       /* Accept all distributions for tax, freight and rec AND
          non revenue distributions with the same sign as the
          line.  This includes invoices that do not use rules and
          unbilled or unearned account in the invoice GL date
          from which revenue is reclassed. */
and    (
         prev_ctl.line_type <> ''LINE''
       OR
         (prev_ctl.line_type        = ''LINE'' AND
           prev_ctlgd.account_class = ''SUSPENSE'')
       OR
         ( prev_ctlgd.account_class NOT IN (''REV'',''UNEARN'') AND
           sign(prev_ctlgd.amount) =
              sign(prev_ctl.extended_amount))
       OR
         ( prev_ctl.accounting_rule_id is null OR
             al_rules.lookup_code = ''N'')
       )
and    decode(prev_ctlgd.account_class,
             ''SUSPENSE'', ctl.revenue_amount - ctl.extended_amount,
                         1) <> 0 ' || CRLF || l_where_pred;

   /* Bug 2560036/2639395 - Test for cash-based events before
      crediting RAM-created REV/UNEARN pairs */
   IF (g_test_collectibility) THEN

      l_nonrule_insert_dist_sql := l_nonrule_insert_dist_sql || CRLF ||
'and    (ar_revenue_management_pvt.line_collectible(prev_ctl.customer_trx_id,
                                               prev_ctl.customer_trx_line_id)
         IN (1,2) or
         prev_ctlgd.revenue_adjustment_id is null)';

   END IF;

l_nonrule_insert_dist_sql := l_nonrule_insert_dist_sql  || CRLF ||
'UNION
/*     Receivable account case */
SELECT
/* Bug 4029814 - removed gl_dist mock logic because of unique constraints */
ctl.customer_trx_id,
to_number(NULL),                 /* customer_trx_line_id */
to_number(NULL),            /* cust_trx_line_salesrep_id */
max(ctl.request_id),
max(ctl.set_of_books_id),
max(ctl.last_update_date),
max(ctl.last_updated_by),
max(ctl.creation_date),
max(ctl.created_by),
max(ctl.last_update_login),
max(ctl.program_application_id),      /* program_appl_id */
max(ctl.program_id),                       /* program_id */
sysdate,                        /* program_update_date */
''REC'',                                  /* account class */
''N'',                                 /* account_set_flag */
100,                                          /* percent */
sum(ctl.extended_amount),                      /* amount */
sum( ' ;


    IF( p_system_info.base_min_acc_unit IS NULL ) THEN

        l_nonrule_insert_dist_sql := l_nonrule_insert_dist_sql || CRLF ||
'    round(ctl.extended_amount * nvl(ct.exchange_rate, 1), ' ||
p_system_info.base_precision || ')';

    ELSE

        l_nonrule_insert_dist_sql := l_nonrule_insert_dist_sql || CRLF ||
'    round(ctl.extended_amount * nvl(ct.exchange_rate, 1) / ' ||
fnd_number.number_to_canonical(p_system_info.base_min_acc_unit) || ') * ' ||
fnd_number.number_to_canonical(p_system_info.base_min_acc_unit) ;

   END IF;

        l_nonrule_insert_dist_sql := l_nonrule_insert_dist_sql || CRLF ||
'    ),                                /* accounted amount */
cm_rec.gl_date,
inv_rec.code_combination_id,
-3,
inv_rec.collected_tax_ccid,
ct.default_ussgl_transaction_code,  /*Bug 2246098*/
inv_rec.revenue_adjustment_id,      /* Bug 2543675 */
null,                               /* Bug 2560036 */
ct.org_id
FROM
ra_customer_trx ct,
ar_lookups al_rules,
ra_cust_trx_line_gl_dist inv_rec,
ra_cust_trx_line_gl_dist cm_rec,
ra_cust_trx_line_gl_dist lgd,
ra_customer_trx_lines ctl
WHERE  ct.customer_trx_id  = ctl.customer_trx_id
and    ctl.customer_trx_id = lgd.customer_trx_id(+)
and    ''REC''               = lgd.account_class(+)
and    ''N''                 = lgd.account_set_flag(+)
and    ctl.customer_trx_id = cm_rec.customer_trx_id
and    ''REC''               = cm_rec.account_class
and    ''Y''                 = cm_rec.account_set_flag
and    lgd.customer_trx_id is null
       /* only create receivable records if the real invoice
          receivable record exists.                     */
and    ct.previous_customer_trx_id  = inv_rec.customer_trx_id
and    ''REC''               = inv_rec.account_class
and    ''N''                 = inv_rec.account_set_flag
and    al_rules.lookup_type                 =  ''YES/NO''
/* Use the presence of an invoicing rule to determine if the invoice has
   accounting rules, not the presence of an UNEARN or UNBILL distribution */
and    al_rules.lookup_code = DECODE(ct.invoicing_rule_id,NULL,''N'',''Y'')
and    al_rules.lookup_code = ''N'' ' || CRLF ||
l_rec_where_pred || CRLF ||
'GROUP BY
ctl.customer_trx_id,
inv_rec.cust_trx_line_gl_dist_id,
inv_rec.gl_date,
cm_rec.gl_date,
inv_rec.code_combination_id,
inv_rec.collected_tax_ccid,
ct.default_ussgl_transaction_code, /*Bug 2246098*/
inv_rec.revenue_adjustment_id,    /* Bug 2543675 */
ct.org_id'; /* 4156400 */

    debug(l_nonrule_insert_dist_sql);
    debug('  len(nonrule_insert_dist_sql) = '||
          to_char(lengthb(l_nonrule_insert_dist_sql)));

    /* 6678560 - dump booleans for binds */
    l_dbg_buffer := '  binds:';
    IF g_bind_trx_12
    THEN
       l_dbg_buffer := l_dbg_buffer || 'T~';
    ELSE
       l_dbg_buffer := l_dbg_buffer || 'F~';
    END IF;
    IF g_bind_trx_3
    THEN
       l_dbg_buffer := l_dbg_buffer || 'T~';
    ELSE
       l_dbg_buffer := l_dbg_buffer || 'F~';
    END IF;
    IF g_bind_line_14
    THEN
       l_dbg_buffer := l_dbg_buffer || 'T~';
    ELSE
       l_dbg_buffer := l_dbg_buffer || 'F~';
    END IF;
    IF g_bind_req_12
    THEN
       l_dbg_buffer := l_dbg_buffer || 'T~';
    ELSE
       l_dbg_buffer := l_dbg_buffer || 'F~';
    END IF;
    IF g_bind_req_3
    THEN
       l_dbg_buffer := l_dbg_buffer || 'T';
    ELSE
       l_dbg_buffer := l_dbg_buffer || 'F';
    END IF;

    debug(l_dbg_buffer);

    ------------------------------------------------------------------------
    -- If this is a Release 9 invoice with rules but no UNEARN or UNBILL
    -- accounts, set the autorule complete flag to null since the
    -- distributions will already have been created.
    -- Also set the latest_rec_flag to 'N' for the account set receivable.
    ------------------------------------------------------------------------

    ------------------------------------------------
    -- Construct the update lines sql
    ------------------------------------------------
    l_nonrule_update_lines_sql :=
'UPDATE ra_customer_trx_lines ctl
SET    autorule_complete_flag = '''',
       autorule_duration_processed = accounting_rule_duration
WHERE  ctl.accounting_rule_id is not null' || CRLF ||
l_where_pred || CRLF ||
'and   ctl.autorule_complete_flag||'''' = ''N''
and   exists
(
 SELECT ''x''
 FROM ra_cust_trx_line_gl_dist d
 WHERE d.customer_trx_id  = ctl.customer_trx_id
 and   d.account_class    = ''REC''
 and   d.account_set_flag = ''N''
)';

    --
    --
    debug(l_nonrule_update_lines_sql);
    debug('  len(nonrule_update_lines_sql) = '||
          to_char(lengthb(l_nonrule_update_lines_sql)));

    ------------------------------------------------
    -- Construct the update dist sql
    ------------------------------------------------
    l_nonrule_update_dist_sql :=
'UPDATE ra_cust_trx_line_gl_dist d
SET latest_rec_flag    = ''N''
WHERE account_class    = ''REC''
and d.latest_rec_flag  = ''Y''
and d.account_set_flag = ''Y''
and d.customer_trx_id in
(
 SELECT ctl.customer_trx_id
 FROM ra_customer_trx_lines ctl
 WHERE 1 = 1' || CRLF ||
l_where_pred || CRLF ||
')
and exists
(
 SELECT 1
 FROM ra_cust_trx_line_gl_dist d2
 WHERE d2.account_class   = ''REC''
 and   d2.latest_rec_flag = ''Y''
 and   d2.customer_trx_id = d.customer_trx_id
 and   d.rowid <> d2.rowid
)';

    --
    --
    debug(l_nonrule_update_dist_sql);
    debug('  len(nonrule_update_dist_sql) = '||
          to_char(lengthb(l_nonrule_update_dist_sql)));


    ------------------------------------------------
    -- Construct the update dist sql for rounding
    ------------------------------------------------

    IF( system_info.base_min_acc_unit ) IS NULL THEN

        l_amount_fragment :=
'round((ctl.extended_amount * nvl(ct.exchange_rate, 1)), ' ||
p_system_info.base_precision || ')';

    ELSE

        l_amount_fragment :=
'round((ctl.extended_amount * nvl(ct.exchange_rate, 1)) / ' ||
fnd_number.number_to_canonical(system_info.base_min_acc_unit) || ') * ' ||
fnd_number.number_to_canonical(system_info.base_min_acc_unit);

    END IF;

    l_nonrule_update_dist2_sql :=
'UPDATE ra_cust_trx_line_gl_dist lgd
set
(
 amount,
 acctd_amount
) =
(
 SELECT
 (ctl.extended_amount - sum(lgd2.amount) ) + lgd.amount,' || CRLF ||
' (' || l_amount_fragment || CRLF ||
'    - sum(lgd2.acctd_amount)) + lgd.acctd_amount
 FROM
 ra_customer_trx_lines ctl,
 ra_customer_trx ct,
 ra_cust_trx_line_gl_dist lgd2
 WHERE ctl.customer_trx_line_id = lgd2.customer_trx_line_id
 and   ctl.customer_trx_line_id = lgd.customer_trx_line_id
 and   ct.customer_trx_id = ctl.customer_trx_id
 GROUP BY
 ctl.customer_trx_line_id,
 ctl.line_number,
 ctl.extended_amount,
 ct.exchange_rate
)
WHERE lgd.cust_trx_line_gl_dist_id in
(
 SELECT min(cust_trx_line_gl_dist_id)
 from
 ra_customer_trx_lines ctl,
 ra_customer_trx ct,
 ra_cust_trx_line_gl_dist lgd3
 where ctl.customer_trx_line_id = lgd3.customer_trx_line_id';

    IF( p_cm_control.customer_trx_id IS NULL ) then

l_nonrule_update_dist2_sql := l_nonrule_update_dist2_sql || CRLF ||
' and   ctl.request_id = :request_id';

    ELSE

/* bug fix 956189 */
l_nonrule_update_dist2_sql := l_nonrule_update_dist2_sql || CRLF ||
' and   ctl.customer_trx_id = :cm_customer_trx_id';

    END IF;

    l_nonrule_update_dist2_sql := l_nonrule_update_dist2_sql || CRLF ||
' and   ct.customer_trx_id = ctl.customer_trx_id
 GROUP BY
 ctl.customer_trx_line_id,
 ctl.line_number,
 ctl.extended_amount
 HAVING
 (
  sum(lgd3.amount) <> ctl.extended_amount ) or
  (sum(lgd3.acctd_amount) <>
      sum( ' || CRLF ||
l_amount_fragment || CRLF ||
'         )
  )
)' ;

    --
    --
    debug(l_nonrule_update_dist2_sql);
    debug('  len(nonrule_update_dist2_sql) = '||
          to_char(lengthb(l_nonrule_update_dist2_sql)));

    ------------------------------------------------
    -- Parse sql stmts
    ------------------------------------------------
    BEGIN
	debug( '  Parsing nonrule stmts', MSG_LEVEL_DEBUG );

        p_nonrule_insert_dist_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_nonrule_insert_dist_c, l_nonrule_insert_dist_sql,
                        dbms_sql.v7 );

        p_nonrule_update_lines_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_nonrule_update_lines_c, l_nonrule_update_lines_sql,
                        dbms_sql.v7 );

        p_nonrule_update_dist_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_nonrule_update_dist_c, l_nonrule_update_dist_sql,
                        dbms_sql.v7 );

        p_nonrule_update_dist2_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_nonrule_update_dist2_c, l_nonrule_update_dist2_sql,
                        dbms_sql.v7 );
    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error parsing nonrule stmts' );
          RAISE;
    END;


    print_fcn_label( 'arp_credit_memo_module.build_nonrule_sql()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.build_nonrule_sql()' );
        RAISE;
END build_nonrule_sql;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  build_rule_sql
--
-- DECSRIPTION:
--
-- ARGUMENTS:
--      IN:
--        system_info
--        profile_info
--        cm_control
--
--      IN/OUT:
--        rule_select_cm_lines_c
--        rule_update_cm_lines_c
--        rule_insert_dist_c
--        rule_insert_cma_c
--
--      OUT:
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE build_rule_sql(
	p_system_info 		IN arp_trx_global.system_info_rec_type,
        p_profile_info 		IN arp_trx_global.profile_rec_type,
        p_cm_control		IN control_rec_type,
        p_rule_select_cm_lines_c 	IN OUT NOCOPY INTEGER,
        p_rule_update_cm_lines_c 	IN OUT NOCOPY INTEGER,
        p_rule_insert_dist_c 		IN OUT NOCOPY INTEGER,
        p_rule_insert_cma_c 		IN OUT NOCOPY INTEGER ) IS

    l_rule_select_cm_lines_sql  VARCHAR2(5000);
    l_rule_update_cm_lines_sql  VARCHAR2(2000);
    l_rule_insert_dist_sql      VARCHAR2(32767);
    l_rule_insert_cma_sql       VARCHAR2(2000);
    l_deferred_duration_sql     VARCHAR2(1000);
    l_deferred_complete_sql     VARCHAR2(1000);

    l_where_pred            VARCHAR2(1000);
    l_temp                  VARCHAR2(1000);


BEGIN

    print_fcn_label( 'arp_credit_memo_module.build_rule_sql()+' );

    ------------------------------------------------
    -- Initialize
    ------------------------------------------------

    ----------------------------------------------------
    -- Construct where predicate
    ----------------------------------------------------
    IF( p_cm_control.customer_trx_line_id IS NOT NULL ) THEN
        ----------------------------------------------------
        -- passed line id
        ----------------------------------------------------

/* bug fix 956189 */
        l_where_pred :=
'and       cm.customer_trx_line_id = :cm_cust_trx_line_id';

    ELSE
        ----------------------------------------------------
        -- Did not pass line id
        ----------------------------------------------------
        IF( p_cm_control.customer_trx_id IS NOT NULL ) THEN

/* bug fix 956189 */
            l_where_pred :=
'and       cm.customer_trx_id = :cm_customer_trx_id';

        ELSE

            l_where_pred :=
'and       cm.request_id = :request_id';

        END IF;


    END IF;


    ----------------------------------------------------
    -- Build select cm lines sql
    ----------------------------------------------------
    l_rule_select_cm_lines_sql :=
'SELECT
cm.customer_trx_line_id,
cm.previous_customer_trx_line_id,
inv_type.allow_overapplication_flag,
cm.revenue_amount,
decode(cmt.credit_method_for_rules,
       ''LIFO'',    ''L'',
       ''PRORATE'', ''P'',
       ''UNIT'',    ''U''),
decode(cmt.credit_method_for_rules,
       ''UNIT'', nvl(cm.last_period_to_credit,
                   nvl(inv.accounting_rule_duration,
                       rule.occurrences)),
       0),
cmt.invoice_currency_code,
/* If the invoice is a Release 9 immediate invoice
   with rules, set the duration to -1 so that it can
   be processed specially. */
decode(inv_trx.created_from || inv_rec.gl_date ||
       nvl(inv.accounting_rule_duration,
           rule.occurrences),
       ''RAXTRX_REL9'' || inv_rev.gl_date || ''1'', ''-1'',
        nvl(inv.accounting_rule_duration,
            rule.occurrences)),
''Y'',
cm_rec.gl_date,
decode(sign( nvl(inv.quantity_invoiced, 0)),
       sign(inv.extended_amount), nvl(inv.quantity_invoiced, 0),
       nvl(inv.quantity_invoiced, 0) * -1 ),
decode(sign( nvl(cm.quantity_credited, 0)),
       sign(cm.extended_amount), nvl(cm.quantity_credited, 0),
       nvl(cm.quantity_credited, 0) * -1 ),
to_char(sign(inv.revenue_amount)),
to_char(sign(cm.revenue_amount)),
CASE
   WHEN rule.type IN (''A'', ''ACC_DUR'') THEN
      ''N''
   ELSE
      ''Y''
   END  partial_period_flag,
inv.unit_selling_price,
cm.unit_selling_price,
inv.rule_end_date
FROM
ra_rules rule,
ra_cust_trx_line_gl_dist cm_rec,
ra_cust_trx_line_gl_dist inv_rec,
ra_cust_trx_line_gl_dist inv_rev,
ra_cust_trx_types inv_type,
ra_customer_trx inv_trx,
ra_customer_trx_lines inv,
ra_customer_trx cmt,
ra_customer_trx_lines cm
WHERE cm.previous_customer_trx_line_id = inv.customer_trx_line_id
and   inv.customer_trx_id      = inv_trx.customer_trx_id
and   inv_trx.cust_trx_type_id = inv_type.cust_trx_type_id
and   cm.customer_trx_id       = cmt.customer_trx_id
and   inv.accounting_rule_id   = rule.rule_id
and   cm.customer_trx_id       = cm_rec.customer_trx_id
and   inv_trx.customer_trx_id  = inv_rec.customer_trx_id
and   inv_rec.account_class    = ''REC''
and   inv_rec.latest_rec_flag  = ''Y''
and   cm_rec.account_class     = ''REC''
and   cm_rec.account_set_flag  = ''Y''
and   cm.rule_start_date       is null
and   cm.line_type             = ''LINE''
and   inv_rev.cust_trx_line_gl_dist_id =
(
  SELECT nvl(min(inv_dist2.cust_trx_line_gl_dist_id),
             inv_rec.cust_trx_line_gl_dist_id)
  FROM   ra_cust_trx_line_gl_dist inv_dist2
  WHERE  inv.customer_trx_line_id = inv_dist2.customer_trx_line_id
  and    inv_dist2.account_set_flag = ''N''
  and    inv_dist2.account_class IN (''REV'',''UNEARN'')
)
/* Do not create distributions for immediate lines if they
   already exist. */
and not exists
(
  SELECT ''dists exist''
  FROM   ra_cust_trx_line_gl_dist subdist
  WHERE  subdist.customer_trx_line_id = cm.customer_trx_line_id
  and    nvl(inv.accounting_rule_duration, 1) = 1
  and    subdist.account_class IN (''REV'',''UNEARN'')
  and    account_set_flag      = ''N''
) ' || CRLF ||
l_where_pred || CRLF ||
'ORDER BY
cm.previous_customer_trx_line_id,
cmt.trx_date,
cm_rec.gl_date,
cm.customer_trx_line_id';

    --
    --
    debug(l_rule_select_cm_lines_sql);
    debug('  len(rule_select_cm_lines_sql) = '||
          to_char(lengthb(l_rule_select_cm_lines_sql)));


    ----------------------------------------------------
    -- Build update cm lines sql
    ----------------------------------------------------
/* Bug 2142941 - removed l_deferred_duration_sql and l_deferred_complete_sql */
    l_rule_update_cm_lines_sql :=
'UPDATE ra_customer_trx_lines l
SET
l.rule_start_date = :rule_start_date,
l.rule_end_date = :rule_end_date,
l.accounting_rule_duration   = :cm_acct_rule_duration,
l.last_period_to_credit      = decode(:credit_method,
                                    ''U'', :last_period_to_credit,
                                    l.last_period_to_credit)
WHERE  l.customer_trx_line_id       = :customer_trx_line_id
and    :rule_start_date is not null
and    :cm_acct_rule_duration is not null ';
/* Bug 2142941 - removed clauses with l_deferred_duration_sql and
   l_deferred_complete_sql  from above code */

    --
    --
    debug(l_rule_update_cm_lines_sql);
    debug('  len(rule_update_cm_lines_sql) = '||
          to_char(lengthb(l_rule_update_cm_lines_sql)));


    --------------------------------------------------
    -- Build insert stmt for ra_cust_trx_line_gl_dist
    --------------------------------------------------
    l_rule_insert_dist_sql :=
'INSERT INTO ra_cust_trx_line_gl_dist
(
  cust_trx_line_gl_dist_id,
  created_by,
  creation_date,
  last_updated_by,
  last_update_date,
  last_update_login,
  program_application_id,
  program_id,
  program_update_date,
  request_id,
  posting_control_id,
  customer_trx_id,
  customer_trx_line_id,
  cust_trx_line_salesrep_id,
  gl_date,
  original_gl_date,
  set_of_books_id,
  code_combination_id,
  concatenated_segments,
  account_class,
  account_set_flag,
  amount,
  acctd_amount,
  percent,
  ussgl_transaction_code,
  ussgl_transaction_code_context,
  comments,
  attribute_category,
  attribute1,
  attribute2,
  attribute3,
  attribute4,
  attribute5,
  attribute6,
  attribute7,
  attribute8,
  attribute9,
  attribute10,
  attribute11,
  attribute12,
  attribute13,
  attribute14,
  attribute15,
  collected_tax_ccid,
  collected_tax_concat_seg,
  revenue_adjustment_id,     /* Bug 2543675 */
  org_id
)';

    --------------------------------------------------------
    -- Check Use invoice accounting profile
    --------------------------------------------------------
    IF( p_profile_info.use_inv_acct_for_cm_flag = YES ) THEN

        l_temp :=
'(decode(ara.amount, 0, 1, lgd.amount) /
               decode(ara.amount,
                      0, decode(lgd.amount, 0, 1,lgd.amount),
                         ara.amount) )';

 /* Bug 2347001 - Added ORDERED hint and changed ar_revenue_assignments to
    ar_revenue_assignments_v (which in turn uses a global temporary
    table called ar_revenue_assignments_gt */


 /* Bug 2837488 - Changed ctls.cust_trx_line_salesrep_id to
     ctls.prev_cust_trx_line_salesrep_id */

        l_rule_insert_dist_sql := l_rule_insert_dist_sql || CRLF ||
'(SELECT /*+ ORDERED
             INDEX (ara.ragt ar_revenue_assignments_gt_n1)
             INDEX (inv_rec  ra_cust_trx_line_gl_dist_n6) */
ra_cust_trx_line_gl_dist_s.nextval,  /* cust_trx_line_dist_id */
ctl.created_by,                      /* created_by */
sysdate,                             /* creation_date */
ctl.last_updated_by,                 /* last_updated_by */
sysdate,                             /* last_update_date */
ctl.last_update_login,               /* last_update_login */
ctl.program_application_id,          /* program_application_id */
ctl.program_id,                      /* program_id */
sysdate,                             /* program_update_date */
ctl.request_id,                      /* request _id */
-3,
ctl.customer_trx_id,                 /* customer_trx_id */
:customer_trx_line_id,               /* customer_trx_line_id */
ctls.cust_trx_line_salesrep_id,      /* cust_trx_line_srep_id */
/* Bug 2142941 - use lgd.gl_date and lgd.original_gl_date instead of bind
   variables :gl_date and :original_gl_date */
/* Bug 2194742 - Used bind variable for gl_date */
/* 6129294 - Honor inv gl_date for RAM dists when possible */
DECODE(lgd.revenue_adjustment_id, NULL, :gl_date,
    DECODE(:gl_date_2, lgd.gl_date, :gl_date_3,
         NVL(arp_credit_memo_module.get_valid_date(
                                     lgd.gl_date,
                                     ct.invoicing_rule_id,
                                     lgd.set_of_books_id),
     :gl_date_4))),                    /* gl_date */
lgd.original_gl_date,                /* original_gl_date */
lgd.set_of_books_id,                 /* set_of_books_id */
lgd.code_combination_id,             /* code_combination_id */
lgd.concatenated_segments,           /* concatenated_segments */
lgd.account_class,                   /* account class */
''N'',                                 /* account_set_flag */
decode( fc.minimum_accountable_unit,
         NULL, round( (:amount * ' || l_temp || ' ),
                      fc.precision),
               round( (:amount_1 * ' || l_temp || ' ) /
                      fc.minimum_accountable_unit ) *
               fc.minimum_accountable_unit
       ) * decode(lgd.account_class,
                  ''REV'',  1,
                         -1),         /* amount */';


        IF( p_system_info.base_min_acc_unit IS NULL ) THEN

            l_rule_insert_dist_sql := l_rule_insert_dist_sql || CRLF ||
'round( decode( fc.minimum_accountable_unit,
               null, round((:amount_2 * ' || l_temp || ' ),
                           fc.precision),
               round((:amount_3 * ' || l_temp || ' ) /
                     fc.minimum_accountable_unit)
                 * fc.minimum_accountable_unit )
        * nvl(ct.exchange_rate, 1) , ' || p_system_info.base_precision ||
      ' )';

        ELSE

            l_rule_insert_dist_sql := l_rule_insert_dist_sql || CRLF ||
'(round((decode( fc.minimum_accountable_unit,
                 null, round((:amount_2 * ' || l_temp || ' ),
                             fc.precision),
                 round((:amount_3 * ' || l_temp || ' ) /
                       fc.minimum_accountable_unit)
                   * fc.minimum_accountable_unit )
        * nvl(ct.exchange_rate, 1)
         ) / ' || fnd_number.number_to_canonical(p_system_info.base_min_acc_unit) || ' ) *' || CRLF ||
              fnd_number.number_to_canonical(p_system_info.base_min_acc_unit) || ')';

        END IF;

        l_rule_insert_dist_sql := l_rule_insert_dist_sql || CRLF ||
'       * decode(lgd.account_class,
                 ''REV'',  1,
                 -1),         /* acctd_amount */
decode(lgd.account_class,
       ''UNBILL'',  -1 * round( ( (:amount_4 * ' || l_temp || ' )
                                / decode(ctl.revenue_amount,
                                        0, 1, ctl.revenue_amount)
                                ) * 100, 4),
       ''UNEARN'',  -1 * round( ( (:amount_5 * ' || l_temp || ' )
                                / decode(ctl.revenue_amount,
                                         0, 1, ctl.revenue_amount)
                                ) * 100, 4),
                       round( ( (:amount_6 * ' || l_temp || ' )
                                / decode(ctl.revenue_amount,
                                        0, 1, ctl.revenue_amount)
                                ) * 100, 4)
       ),                            /* percent */
ct.default_ussgl_transaction_code,   /* ussgl_trx_code  */
ct.default_ussgl_trx_code_context,   /* ussgl_trx_code_context */
NULL,                                /* comments */
NULL,                                /* attribute_category */
NULL,                                /* attribute1 */
NULL,                                /* attribute2 */
NULL,                                /* attribute3 */
NULL,                                /* attribute4 */
NULL,                                /* attribute5 */
NULL,                                /* attribute6 */
NULL,                                /* attribute7 */
NULL,                                /* attribute8 */
NULL,                                /* attribute9 */
NULL,                                /* attribute10 */
NULL,                                /* attribute11 */
NULL,                                /* attribute12 */
NULL,                                /* attribute13 */
NULL,                                /* attribute14 */
NULL,                                /* attribute15 */
lgd.collected_tax_ccid,              /* collected tax */
lgd.collected_tax_concat_seg,        /* collected tax seg */
lgd.revenue_adjustment_id,           /* revenue_adjustment_id */ /*Bug 2543675*/
ct.org_id
FROM
ra_customer_trx_lines ctl,
ra_customer_trx ct,
fnd_currencies fc,
ar_revenue_assignments_v ara /* Bug 2347001 */,
ra_cust_trx_line_gl_dist inv_rec,
ra_cust_trx_line_gl_dist lgd,
ra_cust_trx_line_salesreps ctls
WHERE  lgd.customer_trx_line_id      =  ctl.previous_customer_trx_line_id
and    ctl.previous_customer_trx_line_id = ara.customer_trx_line_id
and    ara.session_id                in (:session_id, -99) /**Bug 2347001 */
and    ara.gl_date  = nvl(lgd.original_gl_date, lgd.gl_date)
and    ara.account_class             = lgd.account_class
and    ara.period_set_name           = :period_set_name /* 4254587 */
and    ct.customer_trx_id            = ctl.customer_trx_id
and    inv_rec.customer_trx_id       = ctl.previous_customer_trx_id
and    inv_rec.account_class         = ''REC''
and    inv_rec.latest_rec_flag       = ''Y''
       /* Bug 2899714 */
and    lgd.cust_trx_line_salesrep_id = ctls.prev_cust_trx_line_salesrep_id(+)
       /*7147479*/
and    ctls.customer_trx_line_id(+)  = :customer_trx_line_id_1
and    ctl.customer_trx_line_id      = :customer_trx_line_id_2
and    fc.currency_code              = ct.invoice_currency_code
and    lgd.account_set_flag          = ''N''
and    ( (lgd.account_class in (''REV'', ''UNEARN'', ''UNBILL'')  and
         :insert_offset_1 = ''Y'' ) or
         (lgd.account_class = ''REV''  and :insert_offset_2 = ''N'' ) )
       /* inv_dist_exists is set to "F" when crediting a release 9
          immediate invoice. In this case, the cm gl_date may not correspond
          to any inv gl_date, so the date check cannot be done. */
/* Bug 2142941 - include join onto lgd.original_gl_date */
and    (
         ( trunc(ara.gl_date)   = lgd.original_gl_date AND
           lgd.original_gl_date = :original_gl_date_1)
        OR
          :check_gl_date_1 = ''N''
       )
/* Bug 2535023 - Revamped fixes from bugs 1936152 and 2354805
   so that the insert now relies upon rec_offset_flag instead
   of that and-not stuff.  Forced routine to only
   copy conventional distributions. */
/* Bug 2543675 - include RAM distributions */
and    lgd.rec_offset_flag is null';

   /* Bug 2560036/2639395 - Test for cash-based events before
      crediting RAM-created REV/UNEARN pairs */
   /* 6060283 - test for collectibility rather than the more limited
        cash-based condition */
   IF (g_test_collectibility) THEN

      l_rule_insert_dist_sql := l_rule_insert_dist_sql || CRLF ||
'and    (ar_revenue_management_pvt.line_collectible(ctl.previous_customer_trx_id,
                                             ctl.previous_customer_trx_line_id)
         IN (1,2) or
         lgd.revenue_adjustment_id is null)';

   END IF;

   l_rule_insert_dist_sql := l_rule_insert_dist_sql || CRLF || ')';


    ELSE

        --------------------------------------------------------
        -- Don't use invoice accounting
        --------------------------------------------------------

        l_rule_insert_dist_sql := l_rule_insert_dist_sql || CRLF ||
' (SELECT
ra_cust_trx_line_gl_dist_s.nextval,  /* cust_trx_line_dist_id */
ct.created_by,                       /* created_by */
sysdate,                             /* creation_date */
ct.last_updated_by,                  /* last_updated_by */
sysdate,                             /* last_update_date */
ct.last_update_login,                /* last_update_login */
ct.program_application_id,           /* program_application_id */
ct.program_id,                       /* program_id */
sysdate,                             /* program_update_date */
ct.request_id,                       /* request _id */
-3,
ct.customer_trx_id,                  /* customer_trx_id */
:customer_trx_line_id,               /* customer_trx_line_id */
lgd.cust_trx_line_salesrep_id,       /* cust_trx_line_srep_id */
:gl_date,                            /* gl_date */
:original_gl_date,                   /* original_gl_date */
lgd.set_of_books_id,                 /* set_of_books_id */
lgd.code_combination_id,             /* code_combination_id */
lgd.concatenated_segments,           /* concatenated_segments */
lgd.account_class,                   /* account class */
''N'',                                 /* account_set_flag */
decode( fc.minimum_accountable_unit,
        NULL, round( (:amount * (lgd.percent / 100) ),
                     fc.precision),
              round( (:amount_1 * (lgd.percent / 100) ) /
                     fc.minimum_accountable_unit ) *
              fc.minimum_accountable_unit
      ) * decode(lgd.account_class,
                 ''REV'',  1,
                        -1),         /* amount */ ';


        IF( p_system_info.base_min_acc_unit IS NULL ) THEN

            l_rule_insert_dist_sql := l_rule_insert_dist_sql || CRLF ||
'round( decode( fc.minimum_accountable_unit,
                null, round((:amount_2 * (lgd.percent / 100) ),
                            fc.precision),
                round((:amount_3 * (lgd.percent / 100) ) /
                      fc.minimum_accountable_unit)
                  * fc.minimum_accountable_unit )
        * nvl(ct.exchange_rate, 1), ' || p_system_info.base_precision ||
      ' )';

        ELSE

            l_rule_insert_dist_sql := l_rule_insert_dist_sql || CRLF ||
'(round((decode( fc.minimum_accountable_unit,
                 null, round((:amount_2 * (lgd.percent / 100) ),
                             fc.precision),
                 round((:amount_3 * (lgd.percent / 100) ) /
                       fc.minimum_accountable_unit)
                   * fc.minimum_accountable_unit )
         * nvl(ct.exchange_rate, 1)
         ) / ' || fnd_number.number_to_canonical(p_system_info.base_min_acc_unit) || ' ) *' || CRLF ||
              fnd_number.number_to_canonical(p_system_info.base_min_acc_unit) || ')';

        END IF;

        l_rule_insert_dist_sql := l_rule_insert_dist_sql || CRLF ||
'       * decode(lgd.account_class,
                  ''REV'',  1,
                  -1),        /* acctd_amount */
decode(lgd.account_class,
       ''UNBILL'',  -1 * round( ( (:amount_4 * (lgd.percent / 100) )
                                / decode(ctl.revenue_amount,
                                        0, 1, ctl.revenue_amount)
                                ) * 100, 4),
       ''UNEARN'',  -1 * round( ( (:amount_5 * (lgd.percent / 100) )
                                / decode(ctl.revenue_amount,
                                         0, 1, ctl.revenue_amount)
                                ) * 100, 4),
                       round( ( (:amount_6 * (lgd.percent / 100) )
                                / decode(ctl.revenue_amount,
                                        0, 1, ctl.revenue_amount)
                                ) * 100, 4)
       ),                            /* percent */
ct.default_ussgl_transaction_code,   /* ussgl_trx_code  */
ct.default_ussgl_trx_code_context,   /* ussgl_trx_code_context */
lgd.comments,                   /* comments */
lgd.attribute_category,         /* attribute_category */
lgd.attribute1,                 /* attribute1 */
lgd.attribute2,                 /* attribute2 */
lgd.attribute3,                 /* attribute3 */
lgd.attribute4,                 /* attribute4 */
lgd.attribute5,                 /* attribute5 */
lgd.attribute6,                 /* attribute6 */
lgd.attribute7,                 /* attribute7 */
lgd.attribute8,                 /* attribute8 */
lgd.attribute9,                 /* attribute9 */
lgd.attribute10,                /* attribute10 */
lgd.attribute11,                /* attribute11 */
lgd.attribute12,                /* attribute12 */
lgd.attribute13,                /* attribute13 */
lgd.attribute14,                /* attribute14 */
lgd.attribute15,                /* attribute1 */
lgd.collected_tax_ccid,         /* collected tax */
lgd.collected_tax_concat_seg,   /* collected tax seg */
lgd.revenue_adjustment_id,      /* revenue_adjustment_id */ /*Bug 2543675*/
ct.org_id
FROM
ra_cust_trx_line_gl_dist lgd,
fnd_currencies fc,
ra_customer_trx_lines ctl,
ra_customer_trx ct,
ra_customer_trx_lines ictl,
ra_rules ir
WHERE  lgd.customer_trx_id        = ct.customer_trx_id
and    lgd.customer_trx_line_id   = :customer_trx_line_id_1
and    lgd.customer_trx_line_id   = ctl.customer_trx_line_id
and    fc.currency_code           = ct.invoice_currency_code
and    account_set_flag           = ''Y''
and    ( (lgd.account_class in (''REV'', ''UNEARN'', ''UNBILL'')  and
         :insert_offset_1 = ''Y'' ) or
         (lgd.account_class = ''REV''  and :insert_offset_2 = ''N'' ) )
/* Bug 2559653 - generate nothing for deferred rules
    unless it is an ARREARS transaction */
and    ctl.previous_customer_trx_line_id = ictl.customer_trx_line_id
and    ictl.accounting_rule_id = ir.rule_id
and    (nvl(ir.deferred_revenue_flag, ''N'') = ''N'' or
        ct.invoicing_rule_id = -3)
/* no-effect pred, for binding purposes */
and    :check_gl_date_1 = :check_gl_date_2
and    :gl_date_1                   is not null ';


   /* 4708369 - Do not create REV/UNEARN pairs if
       transaction is not collectible */
   /* 6060283 - test for the more general collectibility rather than
        the more narrow 'cash-based' condition */
   IF (g_test_collectibility) THEN

      l_rule_insert_dist_sql := l_rule_insert_dist_sql || CRLF ||
'and   ar_revenue_management_pvt.line_collectible(ctl.previous_customer_trx_id,
                  ctl.previous_customer_trx_line_id) IN (1,2) ';

   END IF;

   l_rule_insert_dist_sql := l_rule_insert_dist_sql || ')';

    END IF;

    /*--------------------------------------------------------+
     | added on variables for bulk collect for mrc processing |
     +--------------------------------------------------------*/

    debug( l_rule_insert_dist_sql);
    debug('  len(rule_insert_dist_sql) = '||
          to_char(lengthb(l_rule_insert_dist_sql)));

    ----------------------------------------------------
    -- Build insert stmt for ar_credit_memo_amounts
    ----------------------------------------------------
    l_rule_insert_cma_sql :=
'INSERT INTO ar_credit_memo_amounts
(
 credit_memo_amount_id,
 last_updated_by,
 last_update_date,
 last_update_login,
 created_by,
 creation_date,
 customer_trx_line_id,
 gl_date,
 amount,
 program_application_id,
 program_id,
 program_update_date,
 request_id
)
SELECT
ar_credit_memo_amounts_s.nextval,       /* credit_memo_amount_id */' || CRLF ||
p_profile_info.user_id || ',                      /* last_updated_by */
sysdate,                                 /* last_update_date */' || CRLF ||
p_profile_info.conc_login_id || ',          /* last_update_login */' || CRLF ||
p_profile_info.user_id || ',             /* created_by */
sysdate,                                      /* creation_date */
:customer_trx_line_id,                        /* customer_trx_line_id */
:gl_date,                                     /* gl_date */
:amount,                                      /* amount */' || CRLF ||
profile_info.application_id || ',                /* program_application_id */'
|| CRLF || profile_info.conc_program_id || ',               /* program_id */
sysdate,                                      /* program_update_date */';

    IF( p_cm_control.request_id IS NULL ) THEN
        l_rule_insert_cma_sql := l_rule_insert_cma_sql || CRLF ||
'0' || '     /* request_id */';
    ELSE
        l_rule_insert_cma_sql := l_rule_insert_cma_sql || CRLF ||
':request_id      /* request_id */';
    END IF;

    l_rule_insert_cma_sql := l_rule_insert_cma_sql || CRLF ||
'FROM   dual ';


    --
    --
    debug(l_rule_insert_cma_sql);
    debug('  len(rule_insert_cma_sql) = '||
          to_char(lengthb(l_rule_insert_cma_sql)));

    ------------------------------------------------
    -- Parse sql stmts
    ------------------------------------------------
    BEGIN
	debug( '  Parsing rule stmts', MSG_LEVEL_DEBUG );

        p_rule_select_cm_lines_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_rule_select_cm_lines_c, l_rule_select_cm_lines_sql,
                        dbms_sql.v7 );

        debug(' parsed p_rule_select_cm_lines_c');

        p_rule_update_cm_lines_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_rule_update_cm_lines_c, l_rule_update_cm_lines_sql,
                        dbms_sql.v7 );

        debug(' parsed p_rule_update_cm_lines_c');

        p_rule_insert_dist_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_rule_insert_dist_c, l_rule_insert_dist_sql,
                        dbms_sql.v7 );

        debug(' parsed p_rule_insert_dist_c');

        p_rule_insert_cma_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_rule_insert_cma_c, l_rule_insert_cma_sql,
                        dbms_sql.v7 );

        debug(' parsed p_rule_insert_cma_c');
     EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error parsing rule stmts' );
          RAISE;
    END;


    print_fcn_label( 'arp_credit_memo_module.build_rule_sql()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.build_rule_sql()' );
        RAISE;
END build_rule_sql;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  build_net_revenue_sql
--
-- DECSRIPTION:
--
-- ARGUMENTS:
--      IN:
--        system_info
--        profile_info
--        cm_control
--
--      IN/OUT:
--        net_revenue_line_c
--
--      OUT:
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE build_net_revenue_sql(
	p_system_info 		IN arp_trx_global.system_info_rec_type,
	p_profile_info 		IN arp_trx_global.profile_rec_type,
        p_cm_control 		IN control_rec_type,
        p_net_revenue_line_c 	IN OUT NOCOPY INTEGER ) IS

    l_net_revenue_line_sql      VARCHAR2(2000);

BEGIN

    print_fcn_label( 'arp_credit_memo_module.build_net_revenue_sql()+' );

    ------------------------------------------------
    -- Construct SELECT Statement
    ------------------------------------------------
    l_net_revenue_line_sql :=
'SELECT
distinct
cnr.previous_customer_trx_line_id,
cnr.gl_date,
cnr.amount,
cnr.net_unit_price,
decode(trx.created_from,
       ''RAXTRX_REL9'', ''Y'',
       decode(lgd.customer_trx_id,
              NULL,  ''N'',
              ''Y'')
       )      /* inv dist exists */
FROM ra_cust_trx_line_gl_dist lgd,
     ra_customer_trx trx,
     ar_cm_net_revenue_form cnr
WHERE  cnr.previous_customer_trx_line_id  = :start_prev_ctlid
and    cnr.previous_customer_trx_line_id  =  lgd.customer_trx_line_id(+)
and    cnr.previous_customer_trx_id       =  trx.customer_trx_id
and    cnr.gl_date                        =  lgd.original_gl_date(+)
and    ''N''                              =  lgd.account_set_flag(+)
and    cnr.period_set_name                = :period_set_name
ORDER BY
   cnr.previous_customer_trx_line_id,
   cnr.gl_date';

    debug(l_net_revenue_line_sql);
    debug('  len(net_revenue_line_sql) = '||
          to_char(lengthb(l_net_revenue_line_sql)));


    ------------------------------------------------
    -- Parse sql stmt
    ------------------------------------------------
    BEGIN
	debug( '  Parsing net revenue stmts', MSG_LEVEL_DEBUG );

        p_net_revenue_line_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_net_revenue_line_c, l_net_revenue_line_sql,
                        dbms_sql.v7 );

    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error parsing net revenue stmts' );
          RAISE;
    END;


    print_fcn_label( 'arp_credit_memo_module.build_net_revenue_sql()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.build_net_revenue_sql()' );
        RAISE;
END build_net_revenue_sql;


----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  load_net_revenue_schedule
--
-- DECSRIPTION:
--
-- ARGUMENTS:
--      IN:
--	  system_info
--        profile_info
--        cm_control
--        prev_cust_trx_line_id
--
--      IN/OUT:
--
--      OUT:
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
--  16-SEP-05   M Raymond  4602892 - Removed fix for bug 642590 as we needed
--                         to preserve net rev arrays.
----------------------------------------------------------------------------
PROCEDURE load_net_revenue_schedule(
	p_system_info 		IN arp_trx_global.system_info_rec_type,
        p_profile_info 		IN arp_trx_global.profile_rec_type,
        p_cm_control 		IN control_rec_type,
        p_prev_cust_trx_line_id IN NUMBER )  IS


    l_ignore INTEGER;


BEGIN

    print_fcn_label('arp_credit_memo_module.load_net_revenue_schedule()+' );

/*  bugfix : 642590 -- removed from here */

    --
    -- If net revenue for a line already exists, then no need to reload
    --
    BEGIN

        IF( net_rev_ctlid_t( 0 ) =  p_prev_cust_trx_line_id ) THEN
            print_fcn_label('arp_credit_memo_module.load_net_revenue_schedule()-' );
	    RETURN;
        END IF;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    null;
    END;

    ---------------------------------------------------------------
    --  Initialize tables
    ---------------------------------------------------------------

    net_rev_ctlid_t := null_net_rev_ctlid;
    net_rev_gl_date_t := null_net_rev_gl_date;
    net_rev_amount_t := null_net_rev_amount;
    net_rev_unit_t := null_net_rev_unit;
    net_rev_dist_exists_t := null_net_rev_dist_exists;

    net_rev_start_index := 0;
    net_rev_index := 0;

    ---------------------------------------------------------------
    -- Bind variables
    ---------------------------------------------------------------
    BEGIN
        dbms_sql.bind_variable( net_revenue_line_c,
                                'start_prev_ctlid',
                                p_prev_cust_trx_line_id );
        dbms_sql.bind_variable( net_revenue_line_c,
                                'period_set_name',
                                system_info.period_set_name );
    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error in binding net_revenue_line_c' );
          RAISE;
    END;

    ---------------------------------------------------------------
    -- Execute sql
    ---------------------------------------------------------------
    debug( '  Executing net revenue sql', MSG_LEVEL_DEBUG );

    BEGIN
        l_ignore := dbms_sql.execute( net_revenue_line_c );

    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error executing net revenue sql' );
          RAISE;
    END;


    ---------------------------------------------------------------
    -- Fetch rows
    ---------------------------------------------------------------
    BEGIN
        LOOP

            IF dbms_sql.fetch_rows( net_revenue_line_c ) > 0  THEN

	        debug('  Fetched a row', MSG_LEVEL_DEBUG );

		debug('  Load row into tables', MSG_LEVEL_DEBUG );

                -----------------------------------------------
                -- Load row into table
                -----------------------------------------------
	        dbms_sql.column_value( net_revenue_line_c, 1,
                                       net_rev_ctlid_t( net_rev_index ) );
	        dbms_sql.column_value( net_revenue_line_c, 2,
                                       net_rev_gl_date_t( net_rev_index ) );
	        dbms_sql.column_value( net_revenue_line_c, 3,
                                       net_rev_amount_t( net_rev_index ) );
	        dbms_sql.column_value( net_revenue_line_c, 4,
                                       net_rev_unit_t( net_rev_index ) );
	        dbms_sql.column_value( net_revenue_line_c, 5,
                                       net_rev_dist_exists_t( net_rev_index ));

                net_rev_index := net_rev_index + 1;

            ELSE
                EXIT;
            END IF;


        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: Error fetching net revenue cursor' );
            RAISE;

    END;

    ---------------------------------------------------------------
    -- Dump table
    ---------------------------------------------------------------
    IF PG_DEBUG in ('Y', 'C') THEN
       debug('Net Revenue schedule ***');
       FOR i IN net_rev_start_index..net_rev_index - 1 LOOP
           debug('['|| i || ']: Ctlid <' ||
           net_rev_ctlid_t(i) || '>  GL Date <' ||
           net_rev_gl_date_t(i) || '>  Rev Amt <' ||
           net_rev_amount_t(i) || '> Rev unit < ' ||
           net_rev_unit_t(i) || '>  Rev dist exists <' ||
           net_rev_dist_exists_t(i) || '>', MSG_LEVEL_DEBUG );
       END LOOP;
    END IF;

    print_fcn_label('arp_credit_memo_module.load_net_revenue_schedule()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_credit_memo_module.load_net_revenue_schedule('
              || to_char(p_prev_cust_trx_line_id) || ')' );
        RAISE;

END load_net_revenue_schedule;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  credit_nonrule_transactions
--
-- DECSRIPTION:
--
-- ARGUMENTS:
--      IN:
--        system_info
--        profile_info
--        cm_control
--
--      IN/OUT:
--
--      OUT:
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE credit_nonrule_transactions(
	p_system_info 	IN arp_trx_global.system_info_rec_type,
        p_profile_info 	IN arp_trx_global.profile_rec_type,
        p_cm_control 	IN control_rec_type ) IS

    l_ignore INTEGER;

    CURSOR mrc_gl_dist(p_trx_id NUMBER, p_trx_line_id NUMBER) IS
       SELECT cust_trx_line_gl_dist_id
       FROM   ra_cust_trx_line_gl_dist gld
       WHERE  gld.customer_trx_id = p_trx_id
       AND    gld.customer_trx_line_id =
                 nvl(p_trx_line_id, gld.customer_trx_line_id);

    l_gl_dist_key_value_list gl_ca_utility_pkg.r_key_value_arr;

BEGIN

    print_fcn_label('arp_credit_memo_module.credit_nonrule_transactions()+' );

    -----------------------------------------------------------------------
    -- Create dynamic sql
    -----------------------------------------------------------------------
    debug( '  Creating dynamic sql', MSG_LEVEL_DEBUG );

    build_nonrule_sql( p_system_info,
                       p_profile_info,
		       p_cm_control,
                       nonrule_insert_dist_c,
                       nonrule_update_lines_c,
                       nonrule_update_dist_c,
                       nonrule_update_dist2_c );
    ---------------------------------------------------------------
    -- Bind variables
    ---------------------------------------------------------------
/* bug fix 956189 */
  IF( p_cm_control.customer_trx_id IS NOT NULL ) THEN
    BEGIN
       IF g_bind_trx_12
       THEN
           /* INSERT */
           dbms_sql.bind_variable( nonrule_insert_dist_c,
                                   'cm_customer_trx_id_1',
                                   p_cm_control.customer_trx_id );

           dbms_sql.bind_variable( nonrule_insert_dist_c,
                                   'cm_customer_trx_id_2',
                                   p_cm_control.customer_trx_id );
           /* UPDATE LINE */
           dbms_sql.bind_variable( nonrule_update_lines_c,
                                   'cm_customer_trx_id_1',
                                   p_cm_control.customer_trx_id );

           /* UPDATE DIST */
           dbms_sql.bind_variable( nonrule_update_dist_c,
                                   'cm_customer_trx_id_1',
                                   p_cm_control.customer_trx_id );

       END IF;
       IF g_bind_trx_3
       THEN
           dbms_sql.bind_variable( nonrule_insert_dist_c,
                                   'cm_customer_trx_id_3',
                                   p_cm_control.customer_trx_id );

       END IF;
    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error in binding nonrule_insert_dist_c' );
          RAISE;
    END;

    BEGIN
        dbms_sql.bind_variable( nonrule_update_dist2_c,
                                'cm_customer_trx_id',
                                p_cm_control.customer_trx_id );
    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error in binding nonrule_update_dist2_c' );
          RAISE;
    END;
  ELSE /* bug 3525326 */
    BEGIN
       IF g_bind_req_12
       THEN
           /* INSERT */
           dbms_sql.bind_variable( nonrule_insert_dist_c,
	                           'request_id_1',
	   	  		   p_cm_control.request_id );
           dbms_sql.bind_variable( nonrule_insert_dist_c,
	                           'request_id_2',
	   	  		   p_cm_control.request_id );
           /* UPDATE LINES */
           dbms_sql.bind_variable( nonrule_update_lines_c,
                                   'request_id_1',
                                   p_cm_control.request_id );
           /* UPDATE DISTS */
           dbms_sql.bind_variable( nonrule_update_dist_c,
                                   'request_id_1',
                                   p_cm_control.request_id );

       END IF;

       IF g_bind_req_3
       THEN
           dbms_sql.bind_variable( nonrule_insert_dist_c,
	                           'request_id_3',
	   	  		   p_cm_control.request_id );
       END IF;

    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error in binding nonrule_insert_dist_c' );
	  RAISE;
    END;

    BEGIN
      dbms_sql.bind_variable( nonrule_update_dist2_c,
                              'request_id',
			      p_cm_control.request_id );
    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error in binding nonrule_update_dist2_c' );
	  RAISE;
    END;
  END IF;

/* bug fix 956189 */
  IF( p_cm_control.customer_trx_line_id IS NOT NULL ) THEN
    BEGIN
        IF g_bind_line_14
        THEN
           /* INSERT */
           dbms_sql.bind_variable( nonrule_insert_dist_c,
                                   'cm_cust_trx_line_id_1',
                                   p_cm_control.customer_trx_line_id );
           dbms_sql.bind_variable( nonrule_insert_dist_c,
                                   'cm_cust_trx_line_id_2',
                                   p_cm_control.customer_trx_line_id );
           dbms_sql.bind_variable( nonrule_insert_dist_c,
                                   'cm_cust_trx_line_id_3',
                                   p_cm_control.customer_trx_line_id );
           dbms_sql.bind_variable( nonrule_insert_dist_c,
                                   'cm_cust_trx_line_id_4',
                                   p_cm_control.customer_trx_line_id );
           /* UPDATE LINES */
           dbms_sql.bind_variable( nonrule_update_lines_c,
                                   'cm_cust_trx_line_id_1',
                                   p_cm_control.customer_trx_line_id );
           dbms_sql.bind_variable( nonrule_update_lines_c,
                                   'cm_cust_trx_line_id_2',
                                   p_cm_control.customer_trx_line_id );
           /* UPDATE DISTS */
           dbms_sql.bind_variable( nonrule_update_dist_c,
                                   'cm_cust_trx_line_id_1',
                                   p_cm_control.customer_trx_line_id );
           dbms_sql.bind_variable( nonrule_update_dist_c,
                                   'cm_cust_trx_line_id_2',
                                   p_cm_control.customer_trx_line_id );
        END IF;
    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error in binding nonrule_insert_dist_c' );
          RAISE;
    END;

  END IF;

    -----------------------------------------------------------------------
    -- Insert dist
    -----------------------------------------------------------------------
    debug( '  Inserting distributions', MSG_LEVEL_DEBUG );

    BEGIN
        l_ignore := dbms_sql.execute( nonrule_insert_dist_c );
        close_cursor( nonrule_insert_dist_c );

        debug( to_char(l_ignore) || ' row(s) inserted', MSG_LEVEL_DEBUG );

          /* Bug 4029814 - MRC call at end of this procedure */

    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error executing insert dist stmt' );
          RAISE;
    END;

    -----------------------------------------------------------------------
    -- Update lines
    -----------------------------------------------------------------------
    debug( '  Updating lines', MSG_LEVEL_DEBUG );

    BEGIN
        l_ignore := dbms_sql.execute( nonrule_update_lines_c );
        close_cursor( nonrule_update_lines_c );
        debug( to_char(l_ignore) || ' row(s) updated', MSG_LEVEL_DEBUG );

    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error executing update lines stmt' );
          RAISE;
    END;

    -----------------------------------------------------------------------
    -- Update dist
    -----------------------------------------------------------------------
    debug( '  Updating distributions', MSG_LEVEL_DEBUG );

    BEGIN
        l_ignore := dbms_sql.execute( nonrule_update_dist_c );
        close_cursor( nonrule_update_dist_c );

        debug( to_char(l_ignore) || ' row(s) updated', MSG_LEVEL_DEBUG );

          /* Bug 4029814 - MRC call at end of this procedure */

    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error executing update dist stmt' );
          RAISE;
    END;

    -----------------------------------------------------------------------
    -- Update dist for rounding
    -----------------------------------------------------------------------
    debug( '  Updating distributions for rounding errors', MSG_LEVEL_DEBUG );

    BEGIN
        l_ignore := dbms_sql.execute( nonrule_update_dist2_c );
        close_cursor( nonrule_update_dist2_c );

        debug( to_char(l_ignore) || ' row(s) updated', MSG_LEVEL_DEBUG );

          /* Bug 4029814 - MRC call at end of this procedure */

    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error executing update stmt' );
          RAISE;
    END;

    print_fcn_label('arp_credit_memo_module.credit_nonrule_transactions()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.credit_nonrule_transactions()' );
        RAISE;

END credit_nonrule_transactions;


----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  define_select_columns
--
-- DECSRIPTION:
--
-- ARGUMENTS:
--      IN:
--        select_c
--        select_rec
--
--      IN/OUT:
--
--      OUT:
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE define_select_columns(
	p_select_c   IN INTEGER,
        p_select_rec IN OUT NOCOPY select_rec_type ) IS

BEGIN

    print_fcn_label2( 'arp_credit_memo_module.define_select_columns()+' );

    dbms_sql.define_column( p_select_c, 1, p_select_rec.customer_trx_line_id );
    dbms_sql.define_column( p_select_c, 2,
                            p_select_rec.prev_cust_trx_line_id );
    dbms_sql.define_column( p_select_c, 3,
                            p_select_rec.allow_overapp_flag, 1 );
    dbms_sql.define_column( p_select_c, 4, p_select_rec.cm_amount );
    dbms_sql.define_column( p_select_c, 5,
                            p_select_rec.credit_method_for_rules, 1 );
    dbms_sql.define_column( p_select_c, 6,
                            p_select_rec.last_period_to_credit );
    dbms_sql.define_column( p_select_c, 7, p_select_rec.currency_code, 15 );
    dbms_sql.define_column( p_select_c, 8,
                            p_select_rec.inv_acct_rule_duration );
    dbms_sql.define_column( p_select_c, 9,
                            p_select_rec.allow_not_open_flag, 1 );
    dbms_sql.define_column( p_select_c, 10, p_select_rec.cm_gl_date );
    dbms_sql.define_column( p_select_c, 11, p_select_rec.invoice_quantity );
    dbms_sql.define_column( p_select_c, 12,
                            p_select_rec.cm_quantity );
    dbms_sql.define_column( p_select_c, 13,
                            p_select_rec.invoice_sign);
    dbms_sql.define_column( p_select_c, 14, p_select_rec.cm_sign);
    dbms_sql.define_column( p_select_c, 15, p_select_rec.partial_period_flag,1);
    /* 4621029 */
    dbms_sql.define_column( p_select_c, 16, p_select_rec.inv_unit_price);
    dbms_sql.define_column( p_select_c, 17, p_select_rec.cm_unit_price);
    /* 4621029 end */
    /* 9478772 */
    dbms_sql.define_column( p_select_c, 18, p_select_rec.inv_rule_end_date);
    print_fcn_label2( 'arp_credit_memo_module.define_select_columns()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_credit_memo_module.define_select_columns()');
        RAISE;
END define_select_columns;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  get_select_column_values
--
-- DECSRIPTION:
--
-- ARGUMENTS:
--      IN:
--        select_c
--        select_rec
--
--      IN/OUT:
--
--      OUT:
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE get_select_column_values(
	p_select_c   IN INTEGER,
        p_select_rec IN OUT NOCOPY select_rec_type ) IS
BEGIN

    print_fcn_label2( 'arp_credit_memo_module.get_select_column_values()+' );

    dbms_sql.column_value( p_select_c, 1, p_select_rec.customer_trx_line_id );
    dbms_sql.column_value( p_select_c, 2, p_select_rec.prev_cust_trx_line_id );
    dbms_sql.column_value( p_select_c, 3,
                           p_select_rec.allow_overapp_flag );
    dbms_sql.column_value( p_select_c, 4, p_select_rec.cm_amount );
    dbms_sql.column_value( p_select_c, 5,
                           p_select_rec.credit_method_for_rules );
    dbms_sql.column_value( p_select_c, 6, p_select_rec.last_period_to_credit );
    dbms_sql.column_value( p_select_c, 7, p_select_rec.currency_code );
    dbms_sql.column_value( p_select_c, 8,
                           p_select_rec.inv_acct_rule_duration );
    dbms_sql.column_value( p_select_c, 9, p_select_rec.allow_not_open_flag );
    dbms_sql.column_value( p_select_c, 10, p_select_rec.cm_gl_date );
    dbms_sql.column_value( p_select_c, 11, p_select_rec.invoice_quantity );
    dbms_sql.column_value( p_select_c, 12,
                           p_select_rec.cm_quantity );
    dbms_sql.column_value( p_select_c, 13,
                           p_select_rec.invoice_sign );
    dbms_sql.column_value( p_select_c, 14, p_select_rec.cm_sign );
    dbms_sql.column_value( p_select_c, 15, p_select_rec.partial_period_flag);
    /* 4621029 */
    dbms_sql.column_value( p_select_c, 16, p_select_rec.inv_unit_price);
    dbms_sql.column_value( p_select_c, 17, p_select_rec.cm_unit_price);
    /* 4621029 end */
    /* 9478772 */
    dbms_sql.column_value( p_select_c, 18, p_select_rec.inv_rule_end_date);


    print_fcn_label2( 'arp_credit_memo_module.get_select_column_values()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_credit_memo_module.get_select_column_values()');
        RAISE;
END get_select_column_values;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  dump_select_rec
--
-- DECSRIPTION:
--
-- ARGUMENTS:
--      IN:
--        select_rec
--
--      IN/OUT:
--
--      OUT:
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE dump_select_rec( p_select_rec IN select_rec_type ) IS
BEGIN

    print_fcn_label2( 'arp_credit_memo_module.dump_select_rec()+' );

    debug( '  Dumping select record: ', MSG_LEVEL_DEBUG );
    debug( '  customer_trx_line_id='
           || to_char( p_select_rec.customer_trx_line_id ), MSG_LEVEL_DEBUG );
    debug( '  prev_cust_trx_line_id='
           || to_char( p_select_rec.prev_cust_trx_line_id ), MSG_LEVEL_DEBUG );
    debug( '  allow_overapp_flag=' || p_select_rec.allow_overapp_flag ,
          MSG_LEVEL_DEBUG );
    debug( '  cm_amount='
           || to_char( p_select_rec.cm_amount ), MSG_LEVEL_DEBUG );
    debug( '  credit_method_for_rules='
           || p_select_rec.credit_method_for_rules, MSG_LEVEL_DEBUG );
    debug( '  last_period_to_credit='
           || to_char( p_select_rec.last_period_to_credit ), MSG_LEVEL_DEBUG );
    debug( '  currency_code=' || p_select_rec.currency_code, MSG_LEVEL_DEBUG );
    debug( '  inv_acct_rule_duration='
          || to_char( p_select_rec.inv_acct_rule_duration ), MSG_LEVEL_DEBUG );
    debug( '  allow_not_open_flag=' ||
           p_select_rec.allow_not_open_flag, MSG_LEVEL_DEBUG );
    debug( '  cm_gl_date=' || to_char( p_select_rec.cm_gl_date ),
           MSG_LEVEL_DEBUG );
    debug( '  invoice_quantity='
           || to_char( p_select_rec.invoice_quantity ), MSG_LEVEL_DEBUG );
    debug( '  cm_quantity=' ||
           to_char( p_select_rec.cm_quantity ), MSG_LEVEL_DEBUG );
    debug( '  invoice_sign='
           || p_select_rec.invoice_sign, MSG_LEVEL_DEBUG );
    debug( '  cm_sign='
           || p_select_rec.cm_sign, MSG_LEVEL_DEBUG );
    debug( '  inv_unit_price='
           || p_select_rec.inv_unit_price, MSG_LEVEL_DEBUG );
    debug( '  cm_unit_price='
           || p_select_rec.cm_unit_price, MSG_LEVEL_DEBUG );

    debug( '  partial_period_flag='
           || p_select_rec.partial_period_flag, MSG_LEVEL_DEBUG );
    debug( ' invoice_rule_end_date='
           || p_select_rec.inv_rule_end_date, MSG_LEVEL_DEBUG );

    print_fcn_label2( 'arp_credit_memo_module.dump_select_rec()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.dump_select_rec()' );
        RAISE;
END dump_select_rec;

----------------------------------------------------------------------------
--
-- FUNCTION NAME:  find_cm_schedule
--
-- DECSRIPTION:
--   Given a line_id and search date, searches the cm schedule
--   line_id and orig_gl_date tables for a match.
--   Updates match_index with the index that matched.
--
-- ARGUMENTS:
--      IN:
--        line_id
--        search_date
--
--      IN/OUT:
--        match_index
--
--      OUT:
--
-- RETURNS:
--   TRUE if found a match, FALSE otherwise
--
-- NOTES:
--
-- HISTORY:
--
----------------------------------------------------------------------------
FUNCTION find_cm_schedule(
	p_line_id 	IN NUMBER,
        p_search_date 	IN DATE,
        p_match_index 	IN OUT NOCOPY BINARY_INTEGER )

    RETURN BOOLEAN  IS

BEGIN

    print_fcn_label2('arp_credit_memo_module.find_cm_schedule()+' );

    BEGIN

        FOR i IN 0..cm_sched_index  LOOP
            IF( cm_sched_ctlid_t( i ) = p_line_id AND
                cm_sched_orig_gl_date_t( i ) = p_search_date ) THEN

    	        p_match_index := i;
    	        debug( '  Match at index ' || i, MSG_LEVEL_DEBUG );
                print_fcn_label('arp_credit_memo_module.find_cm_schedule()-' );

	        RETURN TRUE;  -- Done

            END IF;
        END LOOP;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
		null;  -- table not set up yet
    END;

    debug( '  No match', MSG_LEVEL_DEBUG );
    print_fcn_label2('arp_credit_memo_module.find_cm_schedule()-' );

    RETURN FALSE;

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.find_cm_schedule('
	       || to_char(p_line_id) || ', '
	       || to_char(p_search_date) || ')' );
        RAISE;

END find_cm_schedule;

------------------------------------------------------------------------

PROCEDURE write_cm_sched_to_table IS
    /*------------------------------------------------------------
     | Bug # 2988282 - ORASHID: 07-07-2003
     | The following cursor takes the credit memo line id and
     | fetches its extended amount, and does a self join to
     | the corresponding invoice line and invoice line's rule id
     | and rule start date.
     +------------------------------------------------------------*/

    CURSOR lines (p_cm_line_id NUMBER) IS
      SELECT invline.accounting_rule_id,
             invline.rule_start_date,
             cmline.extended_amount line_amount
      FROM   ra_customer_trx_lines_all cmline,
             ra_customer_trx_lines_all invline
      WHERE  cmline.previous_customer_trx_line_id =
             invline.customer_trx_line_id
      AND    cmline.customer_trx_line_id = p_cm_line_id;

    l_ignore             INTEGER;
    l_accounting_rule_id ra_customer_trx_lines_all.accounting_rule_id%TYPE;
    l_line_amount        ra_customer_trx_lines_all.extended_amount%TYPE;
    l_rule_start_date    ra_customer_trx_lines_all.rule_start_date%TYPE;
    l_original_gl_date   ra_customer_trx_lines_all.rule_start_date%TYPE;
    gl_dist_id          ra_cust_trx_line_gl_dist.cust_trx_line_gl_dist_id%TYPE;

BEGIN

    print_fcn_label2('arp_credit_memo_module.write_cm_sched_to_table()+' );

   /* Bug 1956518: Added 'REVERSE' for the 'FOR LOOP' so that the
      distribution lines will be inserted in ascending order of
      gl_date when the rules method is 'PRORATE'. */
   /* Bug 2136455: Added 'REVERSE' for all rule methods */

    debug('cm_sched_index = ' || cm_sched_index);

    FOR i in REVERSE 0..cm_sched_index - 1 LOOP

        debug('  customer_trx_line_id='||cm_sched_ctlid_t( i ),
                MSG_LEVEL_DEBUG);
        debug('  gl_date='||cm_sched_gl_date_t( i ),
                MSG_LEVEL_DEBUG);
        debug('  original_gl_date='||cm_sched_orig_gl_date_t( i ),
                MSG_LEVEL_DEBUG);
        debug('  amount='||cm_sched_amount_t( i ), MSG_LEVEL_DEBUG);
        debug('  insert_offset='||cm_sched_insert_offset_t( i ),
                MSG_LEVEL_DEBUG);
        debug('  check_gl_date='||cm_sched_check_gl_date_t( i ),
                MSG_LEVEL_DEBUG);


        IF( cm_sched_insert_dist_t( i ) = YES ) THEN
            -------------------------------------------------------------
            -- Insert into ra_cust_trx_line_gl_dist
            -------------------------------------------------------------
            -------------------------------------------------------------
            -- Bind vars
            -------------------------------------------------------------
            BEGIN
                debug( '  Binding rule_insert_dist_c', MSG_LEVEL_DEBUG );

                dbms_sql.bind_variable( rule_insert_dist_c,
                                        'customer_trx_line_id',
                                        cm_sched_ctlid_t( i ) );
                /*7147479 added binding for customer_trx_line_id_1*/
                dbms_sql.bind_variable( rule_insert_dist_c,
                                        'customer_trx_line_id_1',
                                        cm_sched_ctlid_t( i ) );
                dbms_sql.bind_variable( rule_insert_dist_c,
                                        'gl_date',
                                        cm_sched_gl_date_t( i ) );
                dbms_sql.bind_variable( rule_insert_dist_c,
                                        'amount',
                                        cm_sched_amount_t( i ) );
                dbms_sql.bind_variable( rule_insert_dist_c,
                                        'amount_1',
                                        cm_sched_amount_t( i ) );
                dbms_sql.bind_variable( rule_insert_dist_c,
                                        'amount_2',
                                        cm_sched_amount_t( i ) );
                dbms_sql.bind_variable( rule_insert_dist_c,
                                        'amount_3',
                                        cm_sched_amount_t( i ) );
                dbms_sql.bind_variable( rule_insert_dist_c,
                                        'amount_4',
                                        cm_sched_amount_t( i ) );
                dbms_sql.bind_variable( rule_insert_dist_c,
                                        'amount_5',
                                        cm_sched_amount_t( i ) );
                dbms_sql.bind_variable( rule_insert_dist_c,
                                        'amount_6',
                                        cm_sched_amount_t( i ) );
                /*7147479 changed bind variable insert_offset_1*/
                dbms_sql.bind_variable( rule_insert_dist_c,
                                        'insert_offset_1',
                                        cm_sched_insert_offset_t( i ) );
                /*7147479 added extra bind variable insert_offset_2*/
                dbms_sql.bind_variable( rule_insert_dist_c,
                                        'insert_offset_2',
                                        cm_sched_insert_offset_t( i ) );

                 dbms_sql.bind_variable( rule_insert_dist_c,
                                          'check_gl_date_1',
                                          cm_sched_check_gl_date_t( i ) );


                /* Bug 2899714 - bind variable not defined when
                   use_inv_acct set to no */
                IF( profile_info.use_inv_acct_for_cm_flag = YES ) THEN
                   /* 4254587 */
                   dbms_sql.bind_variable( rule_insert_dist_c,
                                        'period_set_name',
                                        system_info.period_set_name );

                   /* Bug 2347001 - session_id */
                   dbms_sql.bind_variable( rule_insert_dist_c,
                                           'session_id',
                                           g_session_id);

                   /*7147479 - added new bind variables*/
		   dbms_sql.bind_variable( rule_insert_dist_c,
                                           'customer_trx_line_id_2',
                                           cm_sched_ctlid_t( i ) );
                   dbms_sql.bind_variable( rule_insert_dist_c,
                                           'original_gl_date_1',
                                           cm_sched_orig_gl_date_t( i ) );
                dbms_sql.bind_variable( rule_insert_dist_c,
                                        'gl_date_2',
                                        cm_sched_gl_date_t( i ) );
                dbms_sql.bind_variable( rule_insert_dist_c,
                                        'gl_date_3',
                                        cm_sched_gl_date_t( i ) );
                dbms_sql.bind_variable( rule_insert_dist_c,
                                        'gl_date_4',
                                        cm_sched_gl_date_t( i ) );
		/*bug-7147479 added For Use Invoice Accounting for CM is NO*/
		ELSE
		   /* in SELECT portion of statement */
                   dbms_sql.bind_variable( rule_insert_dist_c,
                                           'original_gl_date',
                                           cm_sched_orig_gl_date_t( i ) );
                   /* in WHERE portion of statement */
                   dbms_sql.bind_variable( rule_insert_dist_c,
                                           'gl_date_1',
                                           cm_sched_gl_date_t( i ) );

                   dbms_sql.bind_variable( rule_insert_dist_c,
                                           'check_gl_date_2',
                                           cm_sched_check_gl_date_t( i ) );
                END IF;

            EXCEPTION
              WHEN OTHERS THEN
                debug( 'EXCEPTION: Error in binding rule_insert_dist_c' );
                RAISE;
            END;

            -------------------------------------------------------------
            -- Execute
            -------------------------------------------------------------
            BEGIN
             debug( '  Inserting distributions', MSG_LEVEL_DEBUG);
                l_ignore := dbms_sql.execute( rule_insert_dist_c );
             debug(to_char(l_ignore) || ' row(s) inserted', MSG_LEVEL_DEBUG);
            EXCEPTION
              WHEN OTHERS THEN
                debug( 'EXCEPTION: Error executing insert dist stmt' );
                RAISE;
            END;
        END IF;

        IF( cm_sched_insert_cma_t( i ) = YES ) THEN
            -------------------------------------------------------------
            -- Insert into ar_credit_memo_amounts
            -------------------------------------------------------------

           /*--------------------------------------------------------------
            | Bug # 2988282 - ORASHID: 07-07-2003
            | If the credit memo line amount is zero and the corresponding
            | invoice line is rule based then use the invoice line's
            | rule start date as the gl date, otherwise continue with
            | exisitng flow.
            +--------------------------------------------------------------*/

            OPEN lines(cm_sched_ctlid_t(i));
            FETCH lines INTO l_accounting_rule_id,
                             l_rule_start_date,
                             l_line_amount;
            CLOSE lines;

            debug('Accounting Rule ID : ' || l_accounting_rule_id);
            debug('Rule Start Date    : ' || l_rule_start_date);
            debug('Line Amount        : ' || l_line_amount);

            IF (l_line_amount = 0 AND l_accounting_rule_id IS NOT NULL) THEN
              l_original_gl_date := l_rule_start_date;
            ELSE
              l_original_gl_date := cm_sched_orig_gl_date_t(i);
            END IF;

            -------------------------------------------------------------
            -- Bind vars
            -------------------------------------------------------------
            dbms_sql.bind_variable( rule_insert_cma_c,
                                    'customer_trx_line_id',
                                    cm_sched_ctlid_t( i ) );
            dbms_sql.bind_variable( rule_insert_cma_c,
                                    'gl_date',
                                    l_original_gl_date);
            dbms_sql.bind_variable( rule_insert_cma_c,
                                    'amount',
                                    cm_sched_amount_t( i ) );
            -------------------------------------------------------------
            -- Execute
            -------------------------------------------------------------
            BEGIN

                debug( '  Inserting CM amounts', MSG_LEVEL_DEBUG );
                l_ignore := dbms_sql.execute( rule_insert_cma_c );
                debug( to_char(l_ignore) || ' row(s) inserted',
                       MSG_LEVEL_DEBUG );

            EXCEPTION
              WHEN OTHERS THEN
                debug( 'EXCEPTION: Error executing insert cma stmt' );
                RAISE;
            END;

        END IF;

    END LOOP;

    print_fcn_label2('arp_credit_memo_module.write_cm_sched_to_table()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.write_cm_sched_to_table()' );
        RAISE;
END write_cm_sched_to_table;

------------------------------------------------------------------------

PROCEDURE clear_cm_sched_tables IS

BEGIN
    print_fcn_label2('arp_credit_memo_module.clear_cm_sched_tables()+' );

    cm_sched_ctlid_t := null_cm_sched_ctlid;
    cm_sched_gl_date_t:= null_cm_sched_gl_date;
    cm_sched_orig_gl_date_t:=null_cm_sched_orig_gl_date;
    cm_sched_amount_t:=null_cm_sched_amount;
    cm_sched_insert_dist_t:=null_cm_sched_insert_dist;
    cm_sched_insert_cma_t:=null_cm_sched_insert_cma;
    cm_sched_insert_offset_t:=null_cm_sched_insert_offset;
    cm_sched_check_gl_date_t:=null_cm_sched_check_gl_date;

    cm_sched_index := 0;

    /* 4602892 - reset net_rev arrays */
    net_rev_ctlid_t( 0 ) := 0;

    print_fcn_label2('arp_credit_memo_module.clear_cm_sched_tables()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.clear_cm_sched_tables()' );
        RAISE;
END clear_cm_sched_tables;


----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  insert_cm_schedule
--
-- DECSRIPTION:
--
--
--
-- ARGUMENTS:
--      IN:
--        line_id
--        gl_date
--        orig_gl_date
--        amount
--	  insert_dist_flag
--	  insert_cma_flag
--        insert_offset_flag
--        check_gl_date_flag
--
--      IN/OUT:
--
--      OUT:
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE insert_cm_schedule(
	p_line_id 		IN NUMBER,
	p_gl_date 		IN DATE,
	p_orig_gl_date 		IN DATE,
	p_amount 		IN NUMBER,
	p_insert_dist_flag 	IN VARCHAR,
	p_insert_cma_flag 	IN VARCHAR,
	p_insert_offset_flag 	IN VARCHAR,
	p_check_gl_date_flag 	IN VARCHAR )  IS

    l_index BINARY_INTEGER;

BEGIN

    print_fcn_label('arp_credit_memo_module.insert_cm_schedule()+' );

    /* 4633761 - removed write and clear logic... It was
       interferring with LIFO CM processing.  Moved to
       main processing area in credit_rule_transactions */

    debug('  cm_sched_index='||cm_sched_index, MSG_LEVEL_DEBUG);
    debug('  p_line_id='||p_line_id, MSG_LEVEL_DEBUG);
    debug('  p_gl_date='||p_gl_date, MSG_LEVEL_DEBUG);
    debug('  p_orig_gl_date='||p_orig_gl_date, MSG_LEVEL_DEBUG);
    debug('  p_amount='||p_amount, MSG_LEVEL_DEBUG);
    debug('  p_insert_dist-flag='||p_insert_dist_flag, MSG_LEVEL_DEBUG);
    debug('  p_insert_cma_flag='||p_insert_cma_flag, MSG_LEVEL_DEBUG);
    debug('  p_insert_offset_flag='||p_insert_offset_flag, MSG_LEVEL_DEBUG);
    debug('  p_check_gl_date_flag='||p_check_gl_date_flag, MSG_LEVEL_DEBUG);


    cm_sched_ctlid_t( cm_sched_index ) 		:= p_line_id;
    cm_sched_gl_date_t( cm_sched_index ) 	:= p_gl_date;
    cm_sched_orig_gl_date_t( cm_sched_index ) 	:= p_orig_gl_date;
    cm_sched_amount_t( cm_sched_index ) 	:= p_amount;
    cm_sched_insert_dist_t( cm_sched_index ) 	:= p_insert_dist_flag;
    cm_sched_insert_cma_t( cm_sched_index ) 	:= p_insert_cma_flag;
    cm_sched_insert_offset_t( cm_sched_index ) 	:= p_insert_offset_flag;
    cm_sched_check_gl_date_t( cm_sched_index ) 	:= p_check_gl_date_flag;

    cm_sched_index := cm_sched_index + 1;

    print_fcn_label('arp_credit_memo_module.insert_cm_schedule()-' );


EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.insert_cm_schedule('
		|| to_char(p_line_id) || ', '
		|| to_char(p_gl_date) || ', '
		|| to_char(p_orig_gl_date) || ', '
		|| to_char(p_amount) || ', '
		|| p_insert_dist_flag || ', '
		|| p_insert_cma_flag || ', '
		|| p_insert_offset_flag || ', '
		|| p_check_gl_date_flag || ')' );
        RAISE;

END insert_cm_schedule;

----------------------------------------------------------------------------
--
-- FUNCTION NAME:  update_cm_schedule
--
-- DECSRIPTION:
--
--
--
-- ARGUMENTS:
--      IN:
--        line_id
--        gl_date
--        amount
--
--      IN/OUT:
--
--      OUT:
--
-- RETURNS:
--   TRUE if record is found, else FALSE
--
-- NOTES:
--
-- HISTORY:
--
----------------------------------------------------------------------------
FUNCTION update_cm_schedule(
	p_line_id 	IN NUMBER,
	p_gl_date 	IN DATE,
	p_amount 	IN NUMBER )

    RETURN BOOLEAN  IS

    l_index BINARY_INTEGER;

BEGIN

    print_fcn_label('arp_credit_memo_module.update_cm_schedule()+' );

    IF( find_cm_schedule( p_line_id,
                          p_gl_date,
	  	          l_index ) = FALSE ) THEN

        print_fcn_label('arp_credit_memo_module.update_cm_schedule()-' );

        RETURN FALSE;  -- didn't find record

    ELSE
        cm_sched_amount_t(l_index) := cm_sched_amount_t(l_index) +
						p_amount;
        RETURN TRUE;

    END IF;

    print_fcn_label('arp_credit_memo_module.update_cm_schedule()-' );


EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.update_cm_schedule('
		|| to_char(p_line_id) || ', '
		|| to_char(p_gl_date) || ', '
		|| to_char(p_amount) || ')' );
        RAISE;

END update_cm_schedule;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  process_cm_schedule
--
-- DECSRIPTION:
--
--
--
-- ARGUMENTS:
--      IN:
--        mode
--        line_id
--        gl_date
--        amount
--        allow_not_open_flag
--	  insert_dist_flag
--	  insert_cma_flag
--        insert_offset_flag
--        check_gl_date_flag
--
--      IN/OUT:
--
--      OUT:
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE process_cm_schedule(
	p_mode 			IN VARCHAR,
	p_line_id 		IN NUMBER,
	p_gl_date 		IN DATE,
	p_amount 		IN NUMBER,
	p_allow_not_open_flag 	IN VARCHAR,
	p_insert_dist_flag 	IN VARCHAR,
	p_insert_cma_flag 	IN VARCHAR,
	p_insert_offset_flag 	IN VARCHAR,
	p_check_gl_date_flag 	IN VARCHAR )
IS

    l_gl_date DATE;
    l_bool BOOLEAN;

    /* bug 3477990 */
    l_rule_id NUMBER;
    l_result_flag BOOLEAN;
    l_defaulting_rule_used  varchar2(300);
    l_error_message         varchar2(300);

BEGIN

    print_fcn_label('arp_credit_memo_module.process_cm_schedule()+' );

    debug('  p_mode='||p_mode, MSG_LEVEL_DEBUG);
    debug('  p_line_id='||p_line_id, MSG_LEVEL_DEBUG);
    debug('  p_gl_date='||to_char(p_gl_date), MSG_LEVEL_DEBUG);
    debug('  p_amount='||p_amount, MSG_LEVEL_DEBUG);
    debug('  p_allow_not_open_flag='||p_allow_not_open_flag, MSG_LEVEL_DEBUG);
    debug('  p_insert_dist_flag='||p_insert_dist_flag, MSG_LEVEL_DEBUG);
    debug('  p_insert_cma_flag='||p_insert_cma_flag, MSG_LEVEL_DEBUG);
    debug('  p_check_gl_date_flag='||p_check_gl_date_flag, MSG_LEVEL_DEBUG);

    ------------------------------------------------------------------------
    -- For inserts only
    ------------------------------------------------------------------------
    /* Bug 3477990 */

    IF( arp_util.is_gl_date_valid( p_gl_date,
                                   p_allow_not_open_flag ) )  THEN

        --------------------------------------------------------------------
        -- p_gl_date is good, use it
        --------------------------------------------------------------------
       IF pg_closed_period_exists = 'Y' THEN
          debug('setting pg_closed_period_exists to NULL 1');
          pg_closed_period_exists := NULL;
          g_error_buffer := MSG_MISSING_PERIODS;
          debug( 'EXCEPTION: '||g_error_buffer, MSG_LEVEL_BASIC );
          RAISE missing_periods;

       ELSE
          l_gl_date := p_gl_date;
       END IF;

    ELSE
       BEGIN
          SELECT invoicing_rule_id
          INTO l_rule_id
          FROM ra_customer_trx ct, ra_customer_trx_lines ctl
          WHERE ct.customer_trx_id = ctl.customer_trx_id
          AND ctl.customer_trx_line_id = p_line_id;

          l_result_flag := arp_util.validate_and_default_gl_date(
                                        p_gl_date,
                                        NULL,
                                        NULL,
                                        NULL,
                                        null,
                                        NULL,
                                        null,
                                        null,
                                        p_allow_not_open_flag,
                                        l_rule_id,
                                        system_info.system_parameters.set_of_books_id ,
                                        222,
                                        l_gl_date,
                                        l_defaulting_rule_used,
                                        l_error_message);
       EXCEPTION
          WHEN OTHERS THEN
             debug( 'EXCEPTION: arp_credit_memo_module.process_cm_schedule Validate GL Date ');
             RAISE;
       END;
       debug('setting pg_closed_period_exists to Y');
       pg_closed_period_exists := 'Y';
    END IF;

    /* End Bug 3477990 */

    IF( p_mode = I ) THEN
	--------------------------------------------------------------------
        -- Insert mode
	--------------------------------------------------------------------
        insert_cm_schedule( p_line_id,
			    l_gl_date,
			    p_gl_date,  -- orig_gl_date
			    p_amount,
			    p_insert_dist_flag,
			    p_insert_cma_flag,
			    p_insert_offset_flag,
			    p_check_gl_date_flag );

    ELSIF( p_mode = U ) THEN
	--------------------------------------------------------------------
        -- Update (overapplication) mode
	--------------------------------------------------------------------
        l_bool := update_cm_schedule( p_line_id,
			     	      p_gl_date,
			     	      p_amount );


        IF( l_bool = FALSE ) THEN
	    ----------------------------------------------------------------
	    -- gl_date not in cm schedule tables, update the database
	    ----------------------------------------------------------------
	    BEGIN
		debug( '  Updating ar_credit_memo_amounts table',
			MSG_LEVEL_DEBUG );

	        UPDATE ar_credit_memo_amounts
	        SET amount = amount + p_amount
	        WHERE customer_trx_line_id = p_line_id
	        and gl_date = p_gl_date;

		debug( SQL%ROWCOUNT||' row(s) updated', MSG_LEVEL_DEBUG );

		IF( SQL%FOUND ) THEN
		    ----------------------------------------------------
		    -- Update successful
		    --
		    -- Only create REV dist,
		    -- don't create cm amounts rec
		    ----------------------------------------------------
		    debug( '  Update successful', MSG_LEVEL_DEBUG );
                    insert_cm_schedule( p_line_id,
			     	        l_gl_date,
			     	        p_gl_date,  -- orig_gl_date
			     	        p_amount,
			     	        p_insert_dist_flag,
				        NO,  -- p_insert_cma_flag
				        NO,  -- p_insert_offset_flag
				        YES  -- p_check_gl_date_flag
                                      );

		ELSE
		    ----------------------------------------------------
        	    -- No cma record to update.
        	    -- Entire cm line is an overapplication
		    -- Insert a cma record into array and increment
		    -- cm_acct_rule_duration
                    -- Create REV and UNEARN dist
		    ----------------------------------------------------

		    debug( '  Update unsuccessful', MSG_LEVEL_DEBUG );
                    debug( '  Entire cm line overapp',
				MSG_LEVEL_DEBUG );
        	    insert_cm_schedule( p_line_id,
			    		l_gl_date,
			    		p_gl_date,  -- orig_gl_date
			    		p_amount,
			    		p_insert_dist_flag,
			    		YES,        -- p_insert_cma_flag
			    		YES,        -- p_insert_offset_flag
			    		YES         -- p_check_gl_date_flag
			  	      );


--		    p_cm_acct_rule_duration := p_cm_acct_rule_duration +1;

		END IF;

	    END;

        END IF;


    ELSE
	--------------------------------------------------------------------
	-- Invalid mode
	--------------------------------------------------------------------
        debug( '  raising invalid_mode', MSG_LEVEL_DEBUG );
	g_error_buffer := 'Invalid mode: ' || p_mode;
	debug( 'EXCEPTION: '||g_error_buffer, MSG_LEVEL_BASIC );
	RAISE invalid_mode;

    END IF;


    print_fcn_label('arp_credit_memo_module.process_cm_schedule()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.process_cm_schedule('
		|| p_mode || ', '
		|| to_char(p_line_id) || ', '
		|| to_char(p_gl_date) || ', '
		|| to_char(p_amount) || ', '
		|| p_insert_dist_flag || ', '
		|| p_insert_cma_flag || ', '
		|| p_insert_offset_flag || ', '
		|| p_check_gl_date_flag || ')' );
        RAISE;

END process_cm_schedule;


----------------------------------------------------------------------------
--
-- FUNCTION NAME:  find_net_revenue
--
-- DECSRIPTION:
--   Given a line_id and search date, searches the net revenue
--   gl_date table for a match.
--   Updates match_index with the index that matched.
--
-- ARGUMENTS:
--      IN:
--        line_id
--        search_date
--
--      IN/OUT:
--        match_index
--
--      OUT:
--
-- RETURNS:
--   TRUE if found a match, FALSE otherwise
--
-- NOTES:
--
-- HISTORY:
--
----------------------------------------------------------------------------
FUNCTION find_net_revenue(
	p_line_id 	IN NUMBER,
        p_search_date 	IN DATE,
        p_match_index 	IN OUT NOCOPY BINARY_INTEGER )

    RETURN BOOLEAN  IS

BEGIN

    print_fcn_label2('arp_credit_memo_module.find_net_revenue()+' );

    debug( 'p_line_id='||p_line_id, MSG_LEVEL_DEBUG );
    debug( 'p_search_date='||to_char(p_search_date, 'DD-MON-YYYY'),
		MSG_LEVEL_DEBUG );

    FOR i IN REVERSE net_rev_start_index..net_rev_index - 1  LOOP
        IF( net_rev_ctlid_t(i) = p_line_id AND
            net_rev_gl_date_t(i) = p_search_date ) THEN

	    p_match_index := i;
	    debug( '  Match at index ' || i, MSG_LEVEL_DEBUG );
            print_fcn_label2('arp_credit_memo_module.find_net_revenue()-' );

	    RETURN TRUE;

        END IF;
    END LOOP;

    debug( '  No match', MSG_LEVEL_DEBUG );
    print_fcn_label2('arp_credit_memo_module.find_net_revenue()-' );

    RETURN FALSE;

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.find_net_revenue('
		|| to_char(p_line_id) || ', '
		|| to_char(p_search_date) || ')' );
        RAISE;

END find_net_revenue;

------------------------------------------------------------------------

FUNCTION get_net_rev_dist_exists( p_index IN BINARY_INTEGER )

    RETURN VARCHAR  IS

BEGIN

    RETURN net_rev_dist_exists_t( p_index );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.get_net_rev_dist_exists('
		|| to_char(p_index) || ')' );
        RAISE;

END get_net_rev_dist_exists;

------------------------------------------------------------------------

FUNCTION get_net_rev_gl_date( p_index IN BINARY_INTEGER )

    RETURN DATE  IS

BEGIN

    RETURN net_rev_gl_date_t( p_index );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.get_net_rev_gl_date('
		|| to_char(p_index) || ')' );
        RAISE;

END get_net_rev_gl_date;

------------------------------------------------------------------------

FUNCTION get_net_rev_amount( p_index IN BINARY_INTEGER )

    RETURN NUMBER  IS

BEGIN

    RETURN net_rev_amount_t( p_index );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.get_net_rev_amount('
		|| to_char(p_index) || ')' );
        RAISE;

END get_net_rev_amount;

------------------------------------------------------------------------

FUNCTION get_net_rev_total_amount(
	p_start_index 	IN BINARY_INTEGER,
	p_end_index 	IN BINARY_INTEGER )

    RETURN NUMBER  IS

    l_amount NUMBER := 0;

BEGIN

    FOR i IN p_start_index..p_end_index  LOOP
        l_amount := l_amount +  net_rev_amount_t(i);
    END LOOP;

    RETURN l_amount;

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.get_net_rev_total_amount('
		|| to_char(p_start_index) || ', '
		|| to_char(p_end_index) || ')' );
        RAISE;

END get_net_rev_total_amount;

------------------------------------------------------------------------

FUNCTION get_net_rev_unit( p_index IN BINARY_INTEGER )

    RETURN NUMBER  IS

BEGIN

    RETURN net_rev_unit_t( p_index );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.get_net_rev_unit('
		|| to_char(p_index) || ')' );
        RAISE;

END get_net_rev_unit;

------------------------------------------------------------------------

PROCEDURE update_net_revenue(
	p_index 	IN BINARY_INTEGER,
	p_amount 	IN NUMBER ) IS

BEGIN

    net_rev_amount_t( p_index ) := p_amount;

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.update_net_revenue('
		|| to_char(p_index) || ')' );
        RAISE;

END update_net_revenue;

------------------------------------------------------------------------

PROCEDURE update_net_rev_unit(
	p_index 	IN BINARY_INTEGER,
	p_amount 	IN NUMBER ) IS

BEGIN

    net_rev_unit_t( p_index ) := p_amount;

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.update_net_rev_unit('
		|| to_char(p_index) || ')' );
        RAISE;

END update_net_rev_unit;

------------------------------------------------------------------------

PROCEDURE process_prorate_cm(
	p_select_rec  		IN OUT NOCOPY select_rec_type,
	p_start_index 		IN BINARY_INTEGER,
	p_end_index 		IN BINARY_INTEGER,
	p_cm_amt_remaining 	IN OUT NOCOPY NUMBER ) IS

    l_amount 			NUMBER;
    l_period_cm_amount 		NUMBER;
    l_inv_line_amt_remaining  	NUMBER;
    l_prorate_total_amount 	NUMBER;

    l_found_last_nonzero_period  BOOLEAN := FALSE;

BEGIN

    print_fcn_label('arp_credit_memo_module.process_prorate_cm()+' );

    debug( '  p_start_index='||p_start_index, MSG_LEVEL_DEBUG );
    debug( '  p_end_index='||p_end_index, MSG_LEVEL_DEBUG );
    -----------------------------------------------------------------
    -- Loop thru revenue schedule
    -----------------------------------------------------------------
    FOR i IN REVERSE p_start_index..p_end_index  LOOP

    debug('  i='||i, MSG_LEVEL_DEBUG);
    debug('  p_cm_amt_remaining='||p_cm_amt_remaining,
	    MSG_LEVEL_DEBUG);
    debug('  get_net_rev_gl_date(i)='||get_net_rev_gl_date(i),
	    MSG_LEVEL_DEBUG);
    debug('  get_net_rev_amount(i)='||get_net_rev_amount(i),
	    MSG_LEVEL_DEBUG);

        -------------------------------------------------------------
        -- Look for the last non-zero period
        -------------------------------------------------------------
	IF( l_found_last_nonzero_period = FALSE ) THEN

            IF( get_net_rev_amount(i) <> 0 )  THEN

        	-----------------------------------------------------
		-- Set flag
        	-----------------------------------------------------
		debug( '  Found last nonzero period', MSG_LEVEL_DEBUG );
	        l_found_last_nonzero_period := TRUE;

        	-----------------------------------------------------
    		-- Compute remaining revenue for this line
        	-----------------------------------------------------
    		l_inv_line_amt_remaining :=
		  get_net_rev_total_amount( p_start_index, i );

		debug( '  l_inv_line_amt_remaining = ' ||
		       l_inv_line_amt_remaining, MSG_LEVEL_DEBUG );

        	-----------------------------------------------------
    		-- Update rule_start_date and rule_duration
        	-----------------------------------------------------
		p_select_rec.rule_start_date :=
		    get_net_rev_gl_date( p_start_index );
		p_select_rec.cm_acct_rule_duration := i - p_start_index + 1;


                IF( SIGN( l_inv_line_amt_remaining ) =
	            SIGN( l_inv_line_amt_remaining +
                          p_select_rec.cm_amount )) THEN

                    -----------------------------------------------------
		    -- cm amount < amt remaining: use total cm amount
                    -----------------------------------------------------
                    l_prorate_total_amount := p_select_rec.cm_amount;

                ELSE

                    -----------------------------------------------------
		    -- cm amount > amt remaining: use amt remaining
                    -----------------------------------------------------
                    l_prorate_total_amount := - l_inv_line_amt_remaining;

                END IF;

            ELSE  -- loop until you find last nonzero period

                GOTO continue;

            END IF;

	END IF;

        -------------------------------------------------------------
	-- Compute amount to credit and round
        -------------------------------------------------------------
	/***********
	l_period_cm_amount :=
		arp_util.CurrRound( l_prorate_total_amount *
		                      (get_net_rev_amount(i) /
				       l_inv_line_amt_remaining),
				    p_select_rec.currency_code );
	***********/
	l_period_cm_amount := ( l_prorate_total_amount *
				  (get_net_rev_amount(i) /
				       l_inv_line_amt_remaining));



        -------------------------------------------------------------
        -- Check for rounding error
        -------------------------------------------------------------
        IF( SIGN( p_cm_amt_remaining ) <>
            SIGN( p_cm_amt_remaining - l_period_cm_amount ) ) THEN

            l_period_cm_amount := p_cm_amt_remaining;

        END IF;


	debug( '  l_period_cm_amount = ' || l_period_cm_amount,
	       MSG_LEVEL_DEBUG );

        -------------------------------------------------------------
	-- Update cm amount remaining
        -------------------------------------------------------------
        p_cm_amt_remaining := p_cm_amt_remaining - l_period_cm_amount;

	debug( '  p_cm_amt_remaining = ' || p_cm_amt_remaining,
	       MSG_LEVEL_DEBUG );

        -------------------------------------------------------------
	-- Update net revenue amount
        -------------------------------------------------------------
	update_net_revenue( i, get_net_rev_amount(i) + l_period_cm_amount );

        IF( get_net_rev_unit(i) <> 0 ) THEN

            update_net_rev_unit( i,
                                 get_net_rev_unit(i) +
                                   (l_period_cm_amount /
                                    p_select_rec.invoice_quantity) );

        END IF;

	----------------------------------------------------------
	-- Insert into cm schedule array
	-- (mode=I, array)
	----------------------------------------------------------
	process_cm_schedule( 'I',
	     		     p_select_rec.customer_trx_line_id,
	     		     get_net_rev_gl_date(i),
	     		     l_period_cm_amount,
	     		     p_select_rec.allow_not_open_flag,
	     		     get_net_rev_dist_exists( i ),
	     		     YES,	-- insert_cma_flag
	     		     YES, 	-- insert_offset_flag
	     		     YES	-- check_gl_date_flag
	   		   );


<<continue>>

        null;

    END LOOP;

    print_fcn_label('arp_credit_memo_module.process_prorate_cm()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.process_prorate_cm('
		|| to_char(p_start_index) || ', '
		|| to_char(p_end_index) || ')' );
        RAISE;
END;

------------------------------------------------------------------------

PROCEDURE process_lifo_cm(
	p_select_rec  		IN OUT NOCOPY select_rec_type,
	p_start_index 		IN BINARY_INTEGER,
	p_end_index 		IN BINARY_INTEGER,
	p_cm_amt_remaining 	IN OUT NOCOPY NUMBER ) IS

    l_amount NUMBER;
BEGIN

    print_fcn_label('arp_credit_memo_module.process_lifo_cm()+' );

    debug( '  p_start_index='||p_start_index, MSG_LEVEL_DEBUG );
    debug( '  p_end_index='||p_end_index, MSG_LEVEL_DEBUG );

    FOR i IN REVERSE p_start_index..p_end_index  LOOP

        debug('  i='||i, MSG_LEVEL_DEBUG);
        debug('  p_cm_amt_remaining='||p_cm_amt_remaining, MSG_LEVEL_DEBUG);
        debug('  get_net_rev_gl_date(i)='||get_net_rev_gl_date(i),
		MSG_LEVEL_DEBUG);
        debug('  get_net_rev_amount(i)='||get_net_rev_amount(i),
		MSG_LEVEL_DEBUG);
        debug('  SIGN( get_net_rev_amount(i) )='||
		SIGN( get_net_rev_amount(i) ), 	MSG_LEVEL_DEBUG);
        debug('  SIGN( get_net_rev_unit(i) )='||SIGN( get_net_rev_unit(i) ),
		MSG_LEVEL_DEBUG);

       /* Bug 2853961 - We were using sign(qty) to test for overapp.
          this does not work if inv qty is negative.  Changed code
          to use true sign(amt) from p_select_rec instead.

          Bug 3198525 - Revised p_select_rec sign variables to be numbers
          to resolve 10g certification issue.  That meant that we no
          longer needed to convert the char signs to numbers. */

        -------------------------------------------------------------
        -- If the net amount remaining in this period is zero, or
        -- the invoice is aleady overapplied in this period
        -- then go to previous period
        -------------------------------------------------------------
	IF( NOT ( get_net_rev_amount(i) = 0 OR
                  SIGN( get_net_rev_amount(i) ) <>
		    SIGN(p_select_rec.invoice_sign) ) ) THEN

	    IF( SIGN( get_net_rev_amount(i) ) =
                SIGN( get_net_rev_amount(i) + p_cm_amt_remaining ) ) THEN

                ------------------------------------------------------------
                -- The array amount + the cm_remaining is the same sign
                -- as the array amount. Therefore, this is a partial
                -- application of this period and no more processing will
                -- be done for this credit memo line.
                -- Set array_amount = array_amount + cm_remaining
                ------------------------------------------------------------
		debug( '  Partial application case', MSG_LEVEL_DEBUG );
		debug('  CM amount = ' || p_cm_amt_remaining, MSG_LEVEL_DEBUG);

       	        ------------------------------------------------------------
		-- Update net revenue amount
       	        ------------------------------------------------------------
		update_net_revenue( i, get_net_rev_amount(i) +
				       p_cm_amt_remaining );

       	        ------------------------------------------------------------
		-- Update rule_start_date, rule_duration
		-- Only increment if not (net=0 or overapp)
       	        ------------------------------------------------------------
		p_select_rec.rule_start_date := get_net_rev_gl_date( i );
		p_select_rec.cm_acct_rule_duration :=
			p_select_rec.cm_acct_rule_duration + 1;


		----------------------------------------------------------
		-- Insert into cm schedule array
		-- (mode=I, array)
		----------------------------------------------------------
		process_cm_schedule(
			     'I',
	     		     p_select_rec.customer_trx_line_id,
	     		     get_net_rev_gl_date( i ),
	     		     p_cm_amt_remaining,
	     		     p_select_rec.allow_not_open_flag,
	     		     get_net_rev_dist_exists( i ),
	     		     YES,	-- insert_cma_flag
	     		     YES, 	-- insert_offset_flag
	     		     YES	-- check_gl_date_flag
	   		   );


                p_cm_amt_remaining := 0;

		GOTO done;

	    ELSE
       	        ------------------------------------------------------------
                -- The array amount + the cm_remaining is not the same sign
                -- as the array amount. Therefore, this is a full
                -- application of this period.
                -- cm_remaining = cm_remaining + array_amount
 	        ------------------------------------------------------------
		debug( '  Full application case', MSG_LEVEL_DEBUG );
		debug( '  CM amount = ' || -get_net_rev_amount(i),
		       MSG_LEVEL_DEBUG );

       	        ------------------------------------------------------------
		-- Update remaining_amount
       	        ------------------------------------------------------------
                p_cm_amt_remaining := p_cm_amt_remaining +
					get_net_rev_amount(i);

       	        ------------------------------------------------------------
		-- Increment rule_duration
       	        ------------------------------------------------------------
		p_select_rec.cm_acct_rule_duration :=
			p_select_rec.cm_acct_rule_duration + 1;

		----------------------------------------------------------
		-- Insert into cm schedule array
		-- (mode=I, array)
		----------------------------------------------------------
		process_cm_schedule(
			     'I',
	     		     p_select_rec.customer_trx_line_id,
	     		     get_net_rev_gl_date( i ),
	     		     -get_net_rev_amount( i ),
	     		     p_select_rec.allow_not_open_flag,
	     		     get_net_rev_dist_exists( i ),
	     		     YES,	-- insert_cma_flag
	     		     YES, 	-- insert_offset_flag
	     		     YES	-- check_gl_date_flag
	   		   );

       	        ------------------------------------------------------------
		-- Update net revenue amount
       	        ------------------------------------------------------------
		update_net_revenue( i, 0 );

       	        ------------------------------------------------------------
                -- If the remaining amount is zero, then all of the cm
                -- amount has been used up and we are done.
                -- Set the rule_start_date and accounting_rule_duration
	        ------------------------------------------------------------
                IF( p_cm_amt_remaining = 0 ) THEN

		    p_select_rec.rule_start_date := get_net_rev_gl_date( i );

		    GOTO done;

		END IF;

	    END IF;

	END IF;

    END LOOP;

<<done>>
    print_fcn_label('arp_credit_memo_module.process_lifo_cm()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.process_lifo_cm('
		|| to_char(p_start_index) || ', '
		|| to_char(p_end_index) || ')' );
        RAISE;
END;

------------------------------------------------------------------------

PROCEDURE process_unit_cm(
	p_select_rec  		IN OUT NOCOPY select_rec_type,
	p_start_index 		IN BINARY_INTEGER,
	p_end_index 		IN BINARY_INTEGER,
	p_cm_amt_remaining 	IN OUT NOCOPY NUMBER ) IS

    l_amount            NUMBER;
    l_period_cm_amount  NUMBER;
    l_last_period_ratio NUMBER;

BEGIN

    print_fcn_label('arp_credit_memo_module.process_unit_cm()+' );

    FOR i IN REVERSE p_start_index..p_end_index  LOOP

        debug('  i='||i, MSG_LEVEL_DEBUG);
        debug('  p_cm_amt_remaining='||p_cm_amt_remaining,
	        MSG_LEVEL_DEBUG);
        debug('  get_net_rev_gl_date(i)='||get_net_rev_gl_date(i),
	        MSG_LEVEL_DEBUG);
        debug('  get_net_rev_amount(i)='||get_net_rev_amount(i),
	        MSG_LEVEL_DEBUG);
        debug('  get_net_rev_unit(i)='||get_net_rev_unit(i),
	        MSG_LEVEL_DEBUG);

        -------------------------------------------------------------
        -- If the net amount remaining in this period is zero, or
        -- the invoice is aleady overapplied in this period
        -- then go to previous period
        -------------------------------------------------------------

       /* Bug 2853961 - We were using sign(qty) to test for overapp.
          this does not work if inv qty is negative.  Changed code
          to use true sign(amt) from p_select_rec instead.

          Bug 3198525 - Original code converted char sign to
          number.  To avoid 10g cert issue, we revised sql
          and structure to store sign as number.*/

        IF( NOT ( get_net_rev_amount(i) = 0 OR
                  SIGN( get_net_rev_amount(i) ) <>
		    SIGN(p_select_rec.invoice_sign) ) ) THEN

	    l_period_cm_amount :=
                arp_util.CurrRound( p_select_rec.cm_quantity *
					get_net_rev_unit(i),
				    p_select_rec.currency_code );

            -------------------------------------------------------------
	    -- If invoice negative, make cm_amount positive
            -------------------------------------------------------------
            /* Bug 2853961 - The original logic here was based on the sign
               of the invoice line.  This goes on the mistaken assumption
               that the unit_cost of the invoice line is always positive.
               When the unit cost goes negative, then the sign of the
               line might be negative or positive depending on the sign
               of the quantity (+,+ +; +,- -; -,+ -; -,- +)

               The calculation of l_period_cm_amount above uses a quantity
               that has already been reversed and the unit cost (from the inv).
               This can result in false values if the unit cost of the original
               invoice was negative.

               We now reverse the sign of l_period_cm_amount when the unit cost
               (from the invoice) is negative. */

	    IF( sign(get_net_rev_unit(i)) = -1 ) THEN
	      debug('   reverse sign!');
		    l_period_cm_amount := - l_period_cm_amount;
	    END IF;

            -------------------------------------------------------------
	    -- Check if at last period
            -------------------------------------------------------------
	    IF( i = p_end_index ) THEN


                ---------------------------------------------------------
	        -- Get fractional part, if applicable
                ---------------------------------------------------------
		l_last_period_ratio :=
			p_select_rec.last_period_to_credit -
			TRUNC( p_select_rec.last_period_to_credit );

		IF( l_last_period_ratio <> 0 ) THEN

		    l_period_cm_amount :=
			arp_util.CurrRound( l_period_cm_amount *
						l_last_period_ratio,
					    p_select_rec.currency_code );

		END IF;

	    END IF;


            -------------------------------------------------------------
	    -- If remaining cm amount < amount to credit,
	    -- use remaining cm amount for amount to credit
            -------------------------------------------------------------
	    IF( SIGN( p_cm_amt_remaining ) <>
		SIGN( p_cm_amt_remaining - l_period_cm_amount ) ) THEN

		l_period_cm_amount := p_cm_amt_remaining;

	    END IF;

            -------------------------------------------------------------
	    -- If net amount for this period < amount to credit,
	    -- set amount to credit = - net_amount
            -------------------------------------------------------------
	    IF( SIGN( get_net_rev_amount(i) ) <>
		SIGN( get_net_rev_amount(i) + l_period_cm_amount ) ) THEN

		l_period_cm_amount := - get_net_rev_amount(i);

	    END IF;


	    debug( '  l_period_cm_amount = ' || l_period_cm_amount,
		   MSG_LEVEL_DEBUG );
	    p_cm_amt_remaining := p_cm_amt_remaining - l_period_cm_amount;

            -------------------------------------------------------------
	    -- Update rule_start_date, rule_duration
            -------------------------------------------------------------
	    p_select_rec.rule_start_date := get_net_rev_gl_date( i );
	    p_select_rec.cm_acct_rule_duration :=
			p_select_rec.cm_acct_rule_duration + 1;

	    ----------------------------------------------------------
	    -- Insert into cm schedule array
	    -- (mode=I, array)
	    ----------------------------------------------------------
	    process_cm_schedule( 'I',
				 p_select_rec.customer_trx_line_id,
	     		     	 get_net_rev_gl_date( i ),
	     		     	 l_period_cm_amount,
	     		     	 p_select_rec.allow_not_open_flag,
	     		     	 get_net_rev_dist_exists( i ),
	     		     	 YES,	-- insert_cma_flag
	     		     	 YES, 	-- insert_offset_flag
	     		     	 YES	-- check_gl_date_flag
	   		       );


            -------------------------------------------------------------
	    -- Update net revenue amount
            -------------------------------------------------------------
	    update_net_revenue( i, get_net_rev_amount(i) +
				   l_period_cm_amount );


	    IF( p_cm_amt_remaining = 0 ) THEN
                -----------------------------------------------------
		-- Credit exhausted, done
                -----------------------------------------------------
		debug( '  Credit exhausted', MSG_LEVEL_DEBUG );
		EXIT;

	    END IF;

	END IF;

    END LOOP;

    print_fcn_label('arp_credit_memo_module.process_unit_cm()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.process_unit_cm('
		|| to_char(p_start_index) || ', '
		|| to_char(p_end_index) || ')' );
        RAISE;
END;


----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  process_line
--
-- DECSRIPTION:
--
-- ARGUMENTS:
--      IN:
--        system_info
--        profile_info
--        cm_control
--
--      IN/OUT:
--        select_rec
--
--      OUT:
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE process_line(
	p_system_info 	IN arp_trx_global.system_info_rec_type,
        p_profile_info 	IN arp_trx_global.profile_rec_type,
        p_cm_control 	IN control_rec_type,
        p_select_rec  	IN OUT NOCOPY select_rec_type ) IS

    l_start_index BINARY_INTEGER;
    l_end_index BINARY_INTEGER;
    l_overapp_index BINARY_INTEGER;
    l_amount NUMBER;
    l_cm_amt_remaining NUMBER;
    l_net_rev_gl_date DATE;

BEGIN

    print_fcn_label('arp_credit_memo_module.process_line()+' );

    -----------------------------------------------------------------------
    -- Initialize
    -----------------------------------------------------------------------
    l_cm_amt_remaining := p_select_rec.cm_amount;
    p_select_rec.cm_acct_rule_duration := 0;

    -----------------------------------------------------------------------
    -- Get net revenue information for a line
    -----------------------------------------------------------------------
    load_net_revenue_schedule( p_system_info,
                              p_profile_info,
                              p_cm_control,
                              p_select_rec.prev_cust_trx_line_id );

    l_start_index := net_rev_start_index;

    -----------------------------------------------------------------------
    -- If all of the invoice's gl_dates are not present in the
    -- net revenue array, then the invoice is a Release 9 invoice
    -- that has gl_dates in gl_periods that do not exist for the
    -- period_type referenced in its rule. In this case, we bomb
    -- and tell the users to define periods for all of the invoice's
    -- gl_dates.
    --
    -- Don't do this check if the imvoice is a Release 9 invoice with
    -- immediate rules, however.
    -----------------------------------------------------------------------
    IF( p_select_rec.inv_acct_rule_duration <> -1 AND
        net_rev_index <> p_select_rec.inv_acct_rule_duration AND
        p_select_rec.cm_amount <> 0 ) THEN

        --
        -- Error: missing_periods
        --
        debug( '  raising missing_periods', MSG_LEVEL_DEBUG );
        g_error_buffer := MSG_MISSING_PERIODS;
	debug( 'EXCEPTION: '||g_error_buffer, MSG_LEVEL_BASIC );
        RAISE missing_periods;

    END IF;
    --
    -- Set the rule_end_date for the partial period CMs
    --
    IF p_select_rec.partial_period_flag = 'Y' THEN
       debug('setting rule_end_date');
       debug('  inv_rule_end_date = ' || p_select_rec.inv_rule_end_date);

       l_net_rev_gl_date := get_net_rev_gl_date( net_rev_index - 1);

       debug('  cm_rule_end_date  = ' || l_net_rev_gl_date || ' SUGGESTED');

       SELECT NVL(inv.accounting_date, cm.accounting_date)
       INTO   p_select_rec.rule_end_date
       FROM   gl_sets_of_books sob,
              gl_date_period_map inv,
              gl_date_period_map cm
       WHERE  sob.set_of_books_id = system_info.system_parameters.set_of_books_id
       AND    cm.period_set_name = sob.period_Set_name
       AND    cm.period_type = sob.accounted_period_type
       AND    cm.accounting_date = l_net_rev_gl_date
       AND    inv.period_set_name (+) = cm.period_set_name
       AND    inv.period_type (+) = cm.period_type
       AND    inv.accounting_date (+) = p_select_rec.inv_rule_end_date
       AND    inv.period_name (+) = cm.period_name;

       debug('  cm.rule_end_date  = ' || p_select_rec.rule_end_date || ' FINAL');
    ELSE
       p_select_rec.rule_end_date := null;
    END IF;

    -----------------------------------------------------------------------
    -- Set ending period to credit.
    -- If this is a unit credit memo, set ending_period to the last period
    -- to credit.  If the last period to credit is not an integer, use
    -- CEIL( last period to credit)
    -----------------------------------------------------------------------
    IF( p_select_rec.credit_method_for_rules = UNIT ) THEN

        l_end_index := CEIL( p_select_rec.last_period_to_credit ) - 1;

        /* 4621029 - check for mismatch of unit_selling_price
           and raise exception or error if CM exceeds INV */
        IF ABS(p_select_rec.inv_unit_price) -
           ABS(p_select_rec.cm_unit_price) < 0
        THEN
           debug( '  raising cm_unit_overapp, ' ||
                p_select_rec.inv_unit_price || ' vs ' ||
                p_select_rec.cm_unit_price, MSG_LEVEL_DEBUG );
           g_error_buffer := MSG_CM_UNIT_OVERAPP;
	   debug( 'EXCEPTION: '||g_error_buffer, MSG_LEVEL_BASIC );
           RAISE cm_unit_overapp;
        END IF;

    ELSE

        l_end_index := net_rev_index - 1;

    END IF;



    -----------------------------------------------------------------------
    -- If the invoice and the credit memo amounts have the same sign,
    -- put the total amount in the period that corresponds to the
    -- credit memo's rule start date.
    -- bug 745945 : added OR p_select_rec.invoice_sign = '0'
    -----------------------------------------------------------------------
    IF( p_select_rec.invoice_sign = p_select_rec.cm_sign OR
        p_select_rec.cm_sign = 0 OR
        p_select_rec.invoice_sign = 0) THEN

	debug( '  Overapplication case', MSG_LEVEL_DEBUG );

        ------------------------------------------------------------
        -- Error if overapplications are not allowed.
        ------------------------------------------------------------
        IF( p_select_rec.allow_overapp_flag = NO AND
            p_select_rec.cm_sign <> 0 ) THEN

            --
            -- Error: overapplication not allowed
            --
            debug( '  overapp_not_allowed', MSG_LEVEL_DEBUG );
	    g_error_buffer := MSG_OVERAPP_NOT_ALLOWED;
	    debug( 'EXCEPTION: '||g_error_buffer, MSG_LEVEL_BASIC );
	    RAISE overapp_not_allowed;

        END IF;

        --------------------------------------------------------------------
        --  Get the date of the period to put the overapplication in.
        --  For LIFO credit memo lines, this is the invoice line's
        --  rule start date.
        --  For Unit credit memo lines, it is the last period to credit.
        --  For Prorate credit memo lines, it is the  credit memo's
        --  rule start date.
        --------------------------------------------------------------------
        IF( p_select_rec.credit_method_for_rules = LIFO ) THEN

            l_overapp_index := l_start_index;

        ELSIF( p_select_rec.credit_method_for_rules = UNIT ) THEN

            l_overapp_index := l_end_index;

        ELSIF( p_select_rec.credit_method_for_rules = PRORATE ) THEN

            -----------------------------------------------------------------
            -- Find gl_date in net rev array which matches cm header gl_date
	    --   (search backwards)
            -----------------------------------------------------------------
            IF( find_net_revenue( p_select_rec.prev_cust_trx_line_id,
                                      p_select_rec.cm_gl_date,
				      l_overapp_index ) = FALSE ) THEN

	    	p_select_rec.rule_start_date := p_select_rec.cm_gl_date;
	    	p_select_rec.cm_acct_rule_duration := 1;

		----------------------------------------------------------
		-- Add to cm schedule array: cm amounts only
		-- (mode=I, N)
		----------------------------------------------------------
		process_cm_schedule( 'I',
		     		     p_select_rec.customer_trx_line_id,
		     		     p_select_rec.cm_gl_date,
		     		     p_select_rec.cm_amount,
		     		     p_select_rec.allow_not_open_flag,
		     		     NO,	-- insert_dist_flag
		     		     YES,	-- insert_cma_flag
		     		     NO, 	-- insert_offset_flag
		     		     NO		-- check_gl_date_flag
		   		   );

		GOTO done;

	    END IF;

        ELSE

            ---------------------------------------------------------------
            -- ERROR: Invalid Credit Method For Rules
            ---------------------------------------------------------------
	    debug( '  raising invalid_cm_method_for_rules', MSG_LEVEL_DEBUG );

	    g_error_buffer := 'Invalid Credit Method for rules';
	    debug( 'EXCEPTION: '|| g_error_buffer, MSG_LEVEL_BASIC );
	    RAISE invalid_cm_method_for_rules;

        END IF;

	/*  Bug 3477990 */
        debug('setting pg_closed_period_exists to NULL 2');
        pg_closed_period_exists := NULL;

	debug( '  l_overapp_index = ' || l_overapp_index, MSG_LEVEL_DEBUG );

        ---------------------------------------------------------------
	-- Update net rev array: amount
        ---------------------------------------------------------------
        update_net_revenue( l_overapp_index,
                            get_net_rev_amount( l_overapp_index ) +
                              p_select_rec.cm_amount );

        -------------------------------------------------------------------
	-- Update rule_start_date = net rev gl_date, acct_rule_duration = 1
        -------------------------------------------------------------------
	p_select_rec.rule_start_date := get_net_rev_gl_date( l_overapp_index );
	p_select_rec.cm_acct_rule_duration := 1;

	----------------------------------------------------------
	-- Update cm schedule array:  (mode=T, array)
	----------------------------------------------------------
	process_cm_schedule( 'U',
	     		     p_select_rec.customer_trx_line_id,
	     		     get_net_rev_gl_date( l_overapp_index ),
	     		     p_select_rec.cm_amount,
	     		     p_select_rec.allow_not_open_flag,
	     		     get_net_rev_dist_exists( l_overapp_index ),
	     		     YES,	-- insert_cma_flag
	     		     YES, 	-- insert_offset_flag
	     		     YES	-- check_gl_date_flag
	   		   );

	GOTO done;

    ELSE  -- inv and cm different signs

        ---------------------------------------------------------------
        -- Release 9 optimization:
        -- If this CM is crediting an immediate Release 9 invoice
        -- whose rule_start_date is equal to its receivable gl_date,
        -- then no unearned or unbilled records exist.
        -- In this case, set the credit memo's gl_date to the cm's
        -- receivable gl_date.
        ---------------------------------------------------------------
	IF( p_select_rec.inv_acct_rule_duration = -1 ) THEN

	    ----------------------------------------------------------
	    -- Insert into cm schedule array:  (mode=I, F)
	    ----------------------------------------------------------
	    process_cm_schedule( 'I',
	     		         p_select_rec.customer_trx_line_id,
	     		         p_select_rec.cm_gl_date,
	     		         p_select_rec.cm_amount,
	     		         p_select_rec.allow_not_open_flag,
	     		         YES,       -- insert_dist_flag
	     		         YES,	-- insert_cma_flag
	     		         YES, 	-- insert_offset_flag
	     		         NO		-- check_gl_date_flag
	   		       );


            ---------------------------------------------------------------
	    -- set rule start date = cm_gl_date
	    -- rule_duration = 1
            ---------------------------------------------------------------
	    p_select_rec.rule_start_date :=  p_select_rec.cm_gl_date;
	    p_select_rec.cm_acct_rule_duration := 1;

   	    GOTO done;

	END IF;

	/*  Bug 4278110/4352354 - we were not resetting this variable
            prior to the process calls below (which in turn call
            process_cm_schedule.  This was causing the module to
            raise a closed_periods error if the previous line
            was accounted entirely in closed periods. */
        debug('setting pg_closed_period_exists to NULL 3');
        pg_closed_period_exists := NULL;

        ---------------------------------------------------------------
	-- Check credit method
        ---------------------------------------------------------------
	IF( p_select_rec.credit_method_for_rules = PRORATE ) THEN

            process_prorate_cm( p_select_rec,
				l_start_index,
				l_end_index,
				l_cm_amt_remaining );

	ELSIF( p_select_rec.credit_method_for_rules = LIFO ) THEN

	    process_lifo_cm( 	p_select_rec,
				l_start_index,
				l_end_index,
				l_cm_amt_remaining );

        ELSIF( p_select_rec.credit_method_for_rules = UNIT ) THEN

	    process_unit_cm( 	p_select_rec,
				l_start_index,
				l_end_index,
				l_cm_amt_remaining );

	ELSE
            ---------------------------------------------------------------
            -- ERROR: Invalid Credit Method For Rules
            ---------------------------------------------------------------
	    debug( '  raising invalid_cm_method_for_rules', MSG_LEVEL_DEBUG );

	    g_error_buffer := 'Invalid Credit Method for rules';
	    debug( 'EXCEPTION: '|| g_error_buffer, MSG_LEVEL_BASIC );
	    RAISE invalid_cm_method_for_rules;

        END IF;

	debug( '  l_cm_amt_remaining = ' || l_cm_amt_remaining,
	       MSG_LEVEL_DEBUG );

	/*  Bug 3477990 */
        debug('setting pg_closed_period_exists to NULL 4');
        pg_closed_period_exists := NULL;

        IF( l_cm_amt_remaining <> 0 ) THEN

            -------------------------------------------------------------
            -- Not all of the cm line amount has been applied to the
            -- invoice. Therefore, this is an overapplication or a
            -- rounding error correction.
            -------------------------------------------------------------

	    IF( p_select_rec.credit_method_for_rules = LIFO ) THEN

                l_overapp_index := l_start_index;

                ---------------------------------------------------------
                -- Update the rule start date for LIFO case
                ---------------------------------------------------------
            	p_select_rec.rule_start_date :=
			get_net_rev_gl_date( l_overapp_index );

            ELSE  -- PRORATE / UNIT case

                IF( find_net_revenue( p_select_rec.prev_cust_trx_line_id,
                                      p_select_rec.rule_start_date,
				      l_overapp_index ) = FALSE ) THEN

                 -- Bug Fix 624157
                 -- Do not raise an exception, instead populate rule_start_date
                 -- with the credit memo gl_date and  rule_durration = 1
                 /**********************************************************
		    --
		    -- ERROR: No net revenue
		    --
	    	    debug( '  raising no_net_revenue',
			   MSG_LEVEL_DEBUG );

        	    g_error_buffer := MSG_NO_NET_REVENUE;
		    debug( 'EXCEPTION '|| g_error_buffer, MSG_LEVEL_BASIC );
		    RAISE no_net_revenue;
                  *********************************************************/

                p_select_rec.rule_start_date := p_select_rec.cm_gl_date;
                p_select_rec.cm_acct_rule_duration := 1;

                -- End Bug Fix

		END IF;

	    END IF;

            -------------------------------------------------------------
            -- Bug 348948 :
            -- the following assignment statement will force all rounding
            -- differences to be put into the last period
            -------------------------------------------------------------
            l_overapp_index := l_end_index;

            -------------------------------------------------------------
	    -- Update net rev array
            -------------------------------------------------------------
            update_net_revenue( l_overapp_index,
				get_net_rev_amount( l_overapp_index ) +
                        	  l_cm_amt_remaining );

	    ----------------------------------------------------------
	    -- Update cm schedule array:  (mode=U, array)
	    ----------------------------------------------------------
	    process_cm_schedule( 'U',
	     		         p_select_rec.customer_trx_line_id,
	     		         get_net_rev_gl_date( l_overapp_index ),
	     		         l_cm_amt_remaining,
	     		         p_select_rec.allow_not_open_flag,
	     		         get_net_rev_dist_exists( l_overapp_index ),
	     		         YES,	-- insert_cma_flag
	     		         YES, 	-- insert_offset_flag
	     		         YES	-- check_gl_date_flag
	   		       );

        END IF;


    END IF;    -- if inv and cm same sign

<<done>>

    /* 4357664 - pg_closed not getting reset for some overapp cases */
    debug('Resetting pg_closed_period_exists to NULL 5');
    pg_closed_period_exists := NULL;
    /* End 4357764 */

    print_fcn_label('arp_credit_memo_module.process_line()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.process_line()' );
        RAISE;
END process_line;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  credit_rule_transactions
--
-- DECSRIPTION:
--
-- ARGUMENTS:
--      IN:
--        system_info
--        profile_info
--        cm_control
--
--      IN/OUT:
--        rule_start_date
--        accounting_rule_duration
--
--      OUT:
--
-- RETURNS:
--
-- NOTES:
--
-- HISTORY:
--  27-SEP-2005  MRAYMOND  4633761 - Added conditional call to
--                          write_cm_sched and clear_cm_sched
--                          based on prev_ctlid
----------------------------------------------------------------------------
PROCEDURE credit_rule_transactions(
	p_system_info 		IN arp_trx_global.system_info_rec_type,
        p_profile_info 		IN arp_trx_global.profile_rec_type,
	p_cm_control 		IN control_rec_type,
	p_failure_count			IN OUT NOCOPY NUMBER,
        p_rule_start_date		IN OUT NOCOPY DATE,
        p_accounting_rule_duration	IN OUT NOCOPY NUMBER  ) IS

    l_ignore INTEGER;
    l_first_fetch		BOOLEAN;

    l_select_rec select_rec_type;
    l_null_rec   CONSTANT select_rec_type := l_select_rec;


BEGIN

    print_fcn_label('arp_credit_memo_module.credit_rule_transactions()+' );

    ---------------------------------------------------------------
    -- Create dynamic sql
    ---------------------------------------------------------------
    debug( '  Creating dynamic sql', MSG_LEVEL_DEBUG );

    build_rule_sql(p_system_info,
                      p_profile_info,
                      p_cm_control,
                      rule_select_cm_lines_c,
                      rule_update_cm_lines_c,
                      rule_insert_dist_c,
                      rule_insert_cma_c );

    define_select_columns( rule_select_cm_lines_c, l_select_rec );


    ---------------------------------------------------------------
    -- Create dynamic sql for net revenue
    ---------------------------------------------------------------
    debug( '  Creating dynamic sql', MSG_LEVEL_DEBUG );

    build_net_revenue_sql(p_system_info,
                      p_profile_info,
                      p_cm_control,
                      net_revenue_line_c );

    BEGIN
	debug( '  Defining columns for net_revenue_line_c', MSG_LEVEL_BASIC );

        dbms_sql.define_column( net_revenue_line_c, 1,
                                net_revenue_rec.customer_trx_line_id );
        dbms_sql.define_column( net_revenue_line_c, 2,
                                net_revenue_rec.gl_date );
        dbms_sql.define_column( net_revenue_line_c, 3,
                                net_revenue_rec.amount );
        dbms_sql.define_column( net_revenue_line_c, 4,
                                net_revenue_rec.net_unit_price );
        dbms_sql.define_column( net_revenue_line_c, 5,
                                net_revenue_rec.inv_dist_exists, 1 );
    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error defining columns for net_revenue_line_c' );
          RAISE;
    END;

/* bug fix 956189 */
  IF( p_cm_control.customer_trx_line_id IS NOT NULL ) THEN
    BEGIN
        dbms_sql.bind_variable( rule_select_cm_lines_c,
                                'cm_cust_trx_line_id',
                                p_cm_control.customer_trx_line_id );
    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error in binding rule_select_cm_lines_c' );
          RAISE;
    END;

  ELSE
    IF( p_cm_control.customer_trx_id IS NOT NULL ) THEN
      BEGIN
        dbms_sql.bind_variable( rule_select_cm_lines_c,
                                'cm_customer_trx_id',
                                p_cm_control.customer_trx_id );
      EXCEPTION
        WHEN OTHERS THEN
          debug( 'EXCEPTION: Error in binding rule_select_cm_lines_c' );
          RAISE;
      END;
    ELSE /* bug 3525326 */
      BEGIN
        dbms_sql.bind_variable( rule_select_cm_lines_c,
	                        'request_id',
				p_cm_control.request_id );
      EXCEPTION
        WHEN OTHERS THEN
	  debug( 'EXCEPTION: Error in binding rule_select_cm_lines_c' );
	  RAISE;
      END;
    END IF;
  END IF;

  /* bug 3525326 */
  IF (p_cm_control.request_id IS NOT NULL) THEN
    BEGIN
      dbms_sql.bind_variable( rule_insert_cma_c,
                              'request_id',
			      p_cm_control.request_id );
    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error in binding rule_insert_cma_c' );
	  RAISE;
    END;
  END IF;

    ---------------------------------------------------------------
    -- Populate ar_revenue_assignments_gt
    --  per bug 2347001
    ---------------------------------------------------------------
    BEGIN
        /* Increment session ID */
        g_session_id := g_session_id + 1;

        /* Now populate gt table with unique session id */
        arp_revenue_assignments.build_for_credit(
                            g_session_id,
                            system_info.period_set_name,
                            p_profile_info.use_inv_acct_for_cm_flag,
                            p_cm_control.request_id,
                            p_cm_control.customer_trx_id,
                            p_cm_control.customer_trx_line_id
                                      );

    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error populating ar_revenue_assignment_gt' );
          RAISE;
    END;


    ---------------------------------------------------------------
    -- Execute sql
    ---------------------------------------------------------------
    debug( '  Executing select sql', MSG_LEVEL_DEBUG );

    BEGIN
        l_ignore := dbms_sql.execute( rule_select_cm_lines_c );

    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error executing select cm lines sql' );
          RAISE;
    END;

    l_first_fetch := TRUE;

    ---------------------------------------------------------------
    -- Fetch rows
    ---------------------------------------------------------------
    debug( '  Fetching select stmt', MSG_LEVEL_DEBUG );

    BEGIN
        LOOP


            IF dbms_sql.fetch_rows( rule_select_cm_lines_c ) > 0  THEN

		debug('  fetched a row', MSG_LEVEL_DEBUG );

		l_first_fetch := FALSE;

                ------------------------------------------------------------
	        -- Get column values
                ------------------------------------------------------------
                l_select_rec := l_null_rec;
                get_select_column_values( rule_select_cm_lines_c,
                                          l_select_rec );

                dump_select_rec( l_select_rec );

            ELSE
                ------------------------------------------------------------
                -- No more rows to fetch
                ------------------------------------------------------------
		debug( '  Done fetching', MSG_LEVEL_DEBUG );

		IF( l_first_fetch ) THEN
                    --------------------------------------------------------
		    -- No rows selected
                    --------------------------------------------------------
		    debug( '  raising NO_DATA_FOUND', MSG_LEVEL_DEBUG );
		    EXIT;
		END IF;

                EXIT;
            END IF;

            ------------------------------------------------------------
            -- Process the line
            ------------------------------------------------------------
	    DECLARE
	        PROCEDURE insert_error_if_autoinv IS
                BEGIN
	            insert_into_error_table(
			l_select_rec.customer_trx_line_id,
                        g_error_buffer,
			NULL );
		END;

            BEGIN
                /* 4633761 - Write to DB and clear when the
                   invoice line changes */
                IF g_prev_ctlid <> l_select_rec.prev_cust_trx_line_id
                THEN
                   debug('write arrays to db and clear arrays...');
                   g_prev_ctlid := l_select_rec.prev_cust_trx_line_id;
                   write_cm_sched_to_table;
                   clear_cm_sched_tables;
                END IF;

                process_line( p_system_info,
                              p_profile_info,
                              p_cm_control,
                              l_select_rec );
	    EXCEPTION
	      WHEN missing_periods OR
		   overapp_not_allowed OR
		   invalid_cm_method_for_rules OR
		   no_net_revenue OR
                   cm_unit_overapp THEN

		  IF( p_cm_control.request_id IS NOT NULL ) THEN

		      p_failure_count := p_failure_count + 1;
		      insert_error_if_autoinv;

		  ELSE
		      RAISE;
		  END IF;

	      WHEN OTHERS THEN
		RAISE;
	    END;

            ------------------------------------------------------------
            -- Bind variables for update
            ------------------------------------------------------------
            BEGIN
		debug('  Binding variables for update', MSG_LEVEL_DEBUG);
		debug('  customer_trx_line_id='||
			l_select_rec.customer_trx_line_id,
			MSG_LEVEL_DEBUG);
		debug('  rule_start_date='||
			to_char(l_select_rec.rule_start_date),
			MSG_LEVEL_DEBUG);
		debug('  rule_end_date='||
			to_char(l_select_rec.rule_end_date),
			MSG_LEVEL_DEBUG);
		debug('  cm_acct_rule_duration='||
			l_select_rec.cm_acct_rule_duration,
			MSG_LEVEL_DEBUG);

                dbms_sql.bind_variable( rule_update_cm_lines_c,
                                        'rule_start_date',
                                        l_select_rec.rule_start_date );
                dbms_sql.bind_variable( rule_update_cm_lines_c,
                                        'rule_end_date',
                                        l_select_rec.rule_end_date );
                dbms_sql.bind_variable( rule_update_cm_lines_c,
                                        'cm_acct_rule_duration',
                                        l_select_rec.cm_acct_rule_duration );
                dbms_sql.bind_variable( rule_update_cm_lines_c,
                                        'credit_method',
                                        l_select_rec.credit_method_for_rules);
                dbms_sql.bind_variable( rule_update_cm_lines_c,
                                        'last_period_to_credit',
                                        l_select_rec.last_period_to_credit );
                dbms_sql.bind_variable( rule_update_cm_lines_c,
                                        'customer_trx_line_id',
                                        l_select_rec.customer_trx_line_id );
            EXCEPTION
              WHEN OTHERS THEN
                  debug('EXCEPTION: Error in binding rule_update_cm_lines_c');
                  RAISE;
            END;

            -----------------------------------------------------------
            -- Execute the update
            -----------------------------------------------------------
            debug( '  Updating lines', MSG_LEVEL_DEBUG );

            BEGIN
                l_ignore := dbms_sql.execute( rule_update_cm_lines_c );

                debug( to_char(l_ignore) || ' row(s) updated',
                       MSG_LEVEL_DEBUG );

            EXCEPTION
              WHEN OTHERS THEN
                  debug( 'EXCEPTION: Error executing update lines stmt' );
                  RAISE;
            END;


            -----------------------------------------------------------
            -- Return the rule_start_date and acct rule duration
	    -- derived if calling the CM module at the line level
            -----------------------------------------------------------
	    IF( p_cm_control.customer_trx_line_id IS NOT NULL ) THEN

		p_rule_start_date := l_select_rec.rule_start_date;
		p_accounting_rule_duration :=
				l_select_rec.cm_acct_rule_duration;
	    END IF;


        END LOOP;

        -----------------------------------------------------------
	-- Flush out remaining data in cm sched tables to disk
        -----------------------------------------------------------
	write_cm_sched_to_table;
        clear_cm_sched_tables;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    RAISE;
        WHEN OTHERS THEN
            debug( 'EXCEPTION: Error fetching select cm lines' );
            RAISE;

    END;



    print_fcn_label('arp_credit_memo_module.credit_rule_transactions()-' );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	RAISE;
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.credit_rule_transactions()');
        RAISE;

END credit_rule_transactions;


----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  credit_transactions_ins_mode
--
-- DECSRIPTION:
--   Main internal procedure which credits transactions
--
-- ARGUMENTS:
--      IN:
--        customer_trx_id
--        customer_trx_line_id
--        prev_customer_trx_id
--        prev_cust_trx_line_id
--        request_id
--
--      IN/OUT:
--        failure_count
--	  rule_start_date
--	  accounting_rule_duration
--
--      OUT:
--
-- NOTES:
--   Raises the exception arp_credit_memo_module.no_ccid if autoaccounting
--   could not derive a valid code combination.  The public variable
--   g_error_buffer is populated for more information.
--
--   Raises the exception NO_DATA_FOUND if no rows were selected for
--   processing.
--
--   Exception raised if Oracle error.
--   App_exception is raised for all other fatal errors and a message
--   is put on the AOL stack.  The public variable g_error_buffer is
--   populated for both types of errors.
--
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE credit_transactions_ins_mode(
	p_customer_trx_id 		IN NUMBER,
        p_customer_trx_line_id 		IN NUMBER,
        p_prev_customer_trx_id 		IN NUMBER,
        p_prev_cust_trx_line_id 	IN NUMBER,
        p_request_id 			IN NUMBER,
        p_failure_count	 		IN OUT NOCOPY NUMBER,
        p_rule_start_date 		IN OUT NOCOPY DATE,
        p_accounting_rule_duration	IN OUT NOCOPY NUMBER ,
        p_run_autoaccounting_flag       IN BOOLEAN
 ) IS

    l_ignore INTEGER;

    l_cm_control control_rec_type;
    l_null_rec   CONSTANT control_rec_type := l_cm_control;

    l_rule_flag  VARCHAR2(1) := NO;

    l_ccid BINARY_INTEGER;
    l_concat_segments VARCHAR2(1000);

    l_gl_dist_key_value_list gl_ca_utility_pkg.r_key_value_arr;

    rows NUMBER := 0;

    l_result NUMBER;
    NO_REC_OFFSET_EXCEPTION EXCEPTION;

    /* Bug 9037241 */
    l_is_reg_cm         NUMBER;
    pg_use_inv_acctg	VARCHAR2(1);

BEGIN

    print_fcn_label('arp_credit_memo_module.credit_transactions_ins_mode()+' );

    ------------------------------
    -- Populate control record
    ------------------------------
    l_cm_control := l_null_rec;

    l_cm_control.customer_trx_id := p_customer_trx_id;
    l_cm_control.customer_trx_line_id := p_customer_trx_line_id;
    l_cm_control.prev_customer_trx_id := p_prev_customer_trx_id;
    l_cm_control.prev_cust_trx_line_id := p_prev_cust_trx_line_id;
    l_cm_control.request_id := p_request_id;

    SAVEPOINT ar_credit_memo_module;

    --------------------------------------------------------------------
    -- Check parameters
    --------------------------------------------------------------------
    IF( ( p_customer_trx_id IS NULL AND
	  p_customer_trx_line_id IS NULL AND
	  p_request_id IS NULL )
        OR
        ( p_request_id IS NOT NULL AND
          ( p_customer_trx_id IS NOT NULL OR
	    p_customer_trx_line_id IS NOT NULL OR
	    p_prev_cust_trx_line_id IS NOT NULL )
        )
      ) THEN

        ----------------------------------------------------------------
	-- Invalid parameters
        ----------------------------------------------------------------
        debug( '  raising invalid_parameters', MSG_LEVEL_DEBUG );

	g_error_buffer := MSG_INVALID_PARAMETERS;
	debug( 'EXCEPTION: '||g_error_buffer, MSG_LEVEL_BASIC );
	RAISE invalid_parameters;

    END IF;

    --------------------------------------------------------------------
    -- For regular CMs , lock the corresponding invoice payment schedule
    -- before processing the CM ( Bug Fix : 1121920 )
    --------------------------------------------------------------------

    IF p_request_id IS NOT NULL THEN

       DECLARE

         -- Get all the CMs being processed in this run

         CURSOR int_regular_cms IS
           SELECT ps.payment_schedule_id,
                  int.previous_customer_trx_id,
                  int.interface_line_id,
		  ps.selected_for_receipt_batch_id
           FROM   ra_interface_lines int,
                  ar_payment_schedules ps
           WHERE  int.request_id = p_request_id
           AND    int.previous_customer_trx_id IS NOT NULL
           AND    int.previous_customer_trx_id = ps.customer_trx_id ;

          l_locked             VARCHAR2(1) := 'N' ;
          l_interface_line_id  NUMBER ;

          PROCEDURE insert_errors(p_selected_for_rcpt_batch_id IN NUMBER) IS
		l_jgzz_product_code VARCHAR2(100);
          BEGIN
              debug( '  inv_locked_by_another_session ', MSG_LEVEL_DEBUG );
	      l_jgzz_product_code := AR_GDF_VALIDATION.is_jg_installed;
	      if (l_jgzz_product_code is not null) and
		(p_selected_for_rcpt_batch_id = -999) then
                        g_error_buffer := MSG_INV_LOCKED_BY_JL;
                        debug(  'EXCEPTION: '||g_error_buffer, MSG_LEVEL_BASIC);
                        insert_into_error_table( l_interface_line_id ,
                                       g_error_buffer,
                                       NULL ) ;
              else
              		g_error_buffer := MSG_INV_LOCKED ;
              		debug(  'EXCEPTION: '||g_error_buffer, MSG_LEVEL_BASIC );
              		insert_into_error_table( l_interface_line_id ,
                                       g_error_buffer,
                                       NULL ) ;
              end if;
          END ;


       BEGIN

          FOR i IN int_regular_cms
          LOOP
             l_interface_line_id := i.interface_line_id ;

             BEGIN
                SELECT 'Y'
                INTO   l_locked
                FROM   ar_payment_schedules
                WHERE  payment_schedule_id = i.payment_schedule_id
                --AND    selected_for_receipt_batch_id IS NULL  /* Bug fix 3142217 */
                --Commented The Above Line And Added The Following 3 Lines For Bug Fix 6339084
                /*Bug Fix 6339084 Starts */
                AND (selected_for_receipt_batch_id IS NULL
                 OR (selected_for_receipt_batch_id IS NOT NULL
                 AND NVL(global_attribute20,'~XX~X') = 'COLLECTION'))
              /*Ends*/

                FOR UPDATE OF payment_schedule_id NOWAIT ;


             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    debug(  'EXCEPTION: Autorec is locking the invoice');
                    p_failure_count := p_failure_count + 1 ;
                    insert_errors(i.selected_for_receipt_batch_id);

                WHEN inv_locked_by_another_session THEN

                    p_failure_count := p_failure_count + 1 ;
                    insert_errors(i.selected_for_receipt_batch_id);

                WHEN OTHERS THEN
                    debug(  'EXCEPTION: Error locking invoice payment schedule');
                    RAISE ;
             END ;

          END LOOP ;

       END ;
    END IF;

    --------------------------------------------------------------------
    -- If the request_id was not specified, find out if CM uses rules
    --------------------------------------------------------------------
    IF( p_customer_trx_id IS NOT NULL ) THEN

        BEGIN

            SELECT decode( trx.invoicing_rule_id, null, 'N', 'Y'),
                   previous_customer_trx_id
            INTO   l_rule_flag,
                   l_is_reg_cm
            FROM   ra_customer_trx trx
            WHERE  trx.customer_trx_id   = p_customer_trx_id;

        EXCEPTION
          WHEN OTHERS THEN
	    debug( 'EXCEPTION: Error in selecting into l_rule_flag' );

	    RAISE;

        END;

    END IF;

    debug('  p_customer_trx_id : '|| p_customer_trx_id);
    debug('  l_rule_flag       : '|| l_rule_flag);
    debug('  l_is_reg_cm       : '|| l_is_reg_cm);

    --------------------------------------------------------------------
    -- Call autoaccounting to create account sets
    --------------------------------------------------------------------
    IF ( p_run_autoaccounting_flag = TRUE)
    THEN
         BEGIN

          /* l_is_reg_cm will be null for autoinvoice batches */
	  IF (profile_info.use_inv_acct_for_cm_flag = YES) AND
	        l_is_reg_cm IS NOT NULL THEN

	     ARP_ETAX_SERVICES_PKG.copy_inv_tax_dists(p_customer_trx_id);

	  ELSE

             arp_auto_accounting.do_autoaccounting(
			I,	-- mode
			'ALL',	-- account_class
			p_customer_trx_id,
			p_customer_trx_line_id,
			NULL,	-- salesrep_id
			p_request_id,
			NULL,	-- gl_date
			NULL,	-- original_gl_date
			NULL,	-- total_trx_amount
			NULL,	-- passed_ccid
			'N',	-- force_account_set_no
			NULL,	-- cust_trx_type_id
			NULL,	-- primary_salesrep_id
			NULL,	-- inventory_item_id
			NULL,	-- memo_line_id
			l_ccid,	-- ccid
			l_concat_segments,	-- concat_segments
			p_failure_count );
	  END IF;

	 EXCEPTION
                WHEN arp_auto_accounting.no_ccid THEN
                    g_error_buffer := arp_auto_accounting.g_error_buffer;
                    RAISE no_ccid;
                WHEN NO_DATA_FOUND THEN
                    debug( '  arp_auto_accounting raises NO_DATA_FOUND',
                           MSG_LEVEL_DEBUG );
                    NULL;         -- ignore this exception
         END;

         /* Check for header level rounding and create model ROUND row if
            one is needed */

         IF (arp_global.sysparam.TRX_HEADER_LEVEL_ROUNDING = 'Y')
         THEN

             DECLARE

                 rows_processed NUMBER;
                 error_message  VARCHAR2(255);
             BEGIN

                 IF (arp_rounding.insert_round_records(
                         p_request_id,
                         p_customer_trx_id,
                         rows_processed,
                         error_message,
                         0,
                         0,
                         'CM', -- this doesn't matter!
                         arp_global.sysparam.TRX_HEADER_ROUND_CCID) <> 0)
                 THEN
                   debug('arp_rounding.insert_round_rows returned FALSE');
                   debug('  error: ' || error_message);
                 END IF;

             EXCEPTION
                 WHEN OTHERS THEN
                   debug('arp_rounding.insert_round_records raised EXCEPTION');
                   debug('  error: ' || error_message);

                   /*Note that this exception will not halt the program
                     and ultimately, line-level rounding will be enforced
                     on the credit memo. */

             END;

         END IF;


    END IF;

    -----------------------------------
    -- Credit non-rule transactions
    -----------------------------------
    IF( profile_info.use_inv_acct_for_cm_flag = YES AND
        l_rule_flag = NO AND
        ( p_prev_customer_trx_id IS NOT NULL OR
          p_request_id IS NOT NULL )
      )  THEN

        credit_nonrule_transactions( system_info,
                                     profile_info,
                                     l_cm_control );
    END IF;


    ---------------------------------
    -- Credit rule transactions
    ---------------------------------
    IF(  l_rule_flag = YES OR p_request_id IS NOT NULL ) THEN

        /* Bug 2535023 - set rec_offset_flags on older invoices
           before we attempt to clone the distributions */
        IF (profile_info.use_inv_acct_for_cm_flag = YES) THEN
           IF (p_request_id is NOT NULL) THEN
              arp_rounding.set_rec_offset_flag(null, p_request_id, l_result);
           ELSE
              arp_rounding.set_rec_offset_flag(p_prev_customer_trx_id, null, l_result);
           END IF;

           /* 6782405 - Check result of set_rec_offset call and raise exception if
              it is unsuccessful

              This particular call is only important for old transactions that
              have been through Rev rec.  New ones (that have not) won't
              do anything in this call and will return l_result of zero
              since there was nothing to be done */
           IF l_result = -1
           THEN
              RAISE NO_REC_OFFSET_EXCEPTION;
           END IF;

        END IF;

        credit_rule_transactions( system_info,
                                  profile_info,
                                  l_cm_control,
				  p_failure_count,
				  p_rule_start_date,
				  p_accounting_rule_duration );

    END IF;

    /* Bug 4029814 - removed followon MRC call.  We no longer
       update the gl_dist_id this late.  MRC calls will have to occur
       inline */

    close_cursors;

    print_fcn_label('arp_credit_memo_module.credit_transactions_ins_mode()-' );

EXCEPTION
    WHEN NO_REC_OFFSET_EXCEPTION THEN
       /* set_rec_offset_flag executed and was unable to set
          the flag even though none were set, so stopping to prevent
          data corruption */
        close_cursors;
        debug( 'EXCEPTION: set_rof - credit_transactions_ins_mode('
		|| to_char(p_customer_trx_id) || ', '
		|| to_char(p_customer_trx_line_id) || ', '
		|| to_char(p_prev_customer_trx_id) || ', '
		|| to_char(p_prev_cust_trx_line_id) || ', '
		|| to_char(p_request_id) || ')' );
	close_cursors;
	ROLLBACK TO ar_credit_memo_module;
    WHEN no_ccid OR NO_DATA_FOUND THEN

	close_cursors;

	IF( p_request_id IS NOT NULL ) THEN

	    NULL;	-- Don't raise for Autoinvoice,
			-- otherwise the IN/OUT variables
			-- ccid, concat_segments and failure_count
			-- do not get populated.
	ELSE
	    RAISE;
	END IF;

    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_credit_memo_module.credit_transactions_ins_mode('
		|| to_char(p_customer_trx_id) || ', '
		|| to_char(p_customer_trx_line_id) || ', '
		|| to_char(p_prev_customer_trx_id) || ', '
		|| to_char(p_prev_cust_trx_line_id) || ', '
		|| to_char(p_request_id) || ')' );

	close_cursors;
	ROLLBACK TO ar_credit_memo_module;

	IF( sqlcode = 1 ) THEN
            ----------------------------------------------------------------
	    -- User-defined exception
            ----------------------------------------------------------------
	    FND_MESSAGE.set_name( 'AR', 'GENERIC_MESSAGE' );
	    FND_MESSAGE.set_token( 'GENERIC_TEXT', g_error_buffer );
	    APP_EXCEPTION.raise_exception;

	ELSE
            ----------------------------------------------------------------
	    -- Oracle error
            ----------------------------------------------------------------
	    g_error_buffer := SQLERRM;

            RAISE;

	END IF;

END credit_transactions_ins_mode;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  credit_transactions
--
-- DECSRIPTION:
--   Server-side entry point for the CM module.
--
-- ARGUMENTS:
--      IN:
--        customer_trx_id
--        customer_trx_line_id
--        prev_customer_trx_id
--        prev_cust_trx_line_id
--        request_id
--	  process_mode 		(I)nsert or (U)pdate
--
--      IN/OUT:
--        failure_count
--	  rule_start_date
--	  accounting_rule_duration
--
--      OUT:
--
-- NOTES:
--   Calls credit_transactions_ins_mode.
--
--   Raises the exception arp_credit_memo_module.no_ccid if autoaccounting
--   could not derive a valid code combination.  The public variable
--   g_error_buffer is populated for more information.
--
--   Raises the exception NO_DATA_FOUND if no rows were selected for
--   processing.
--
--   Exception raised if Oracle error.
--   App_exception is raised for all other fatal errors and a message
--   is put on the AOL stack.  The public variable g_error_buffer is
--   populated for both types of errors.
--
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE credit_transactions(
	p_customer_trx_id 		IN NUMBER,
        p_customer_trx_line_id 		IN NUMBER,
        p_prev_customer_trx_id 		IN NUMBER,
        p_prev_cust_trx_line_id 	IN NUMBER,
        p_request_id 			IN NUMBER,
        p_failure_count	 		IN OUT NOCOPY NUMBER,
        p_rule_start_date 		IN OUT NOCOPY DATE,
        p_accounting_rule_duration	IN OUT NOCOPY NUMBER,
	p_process_mode			IN VARCHAR2,
        p_run_autoaccounting_flag       IN BOOLEAN
  ) IS

    l_ignore INTEGER;
    gl_header_dist_array    dbms_sql.number_table;  /* mrc */
    gl_line_dist_array      dbms_sql.number_table;  /* mrc */
    l_xla_ev_rec            ARP_XLA_EVENTS.XLA_EVENTS_TYPE; -- bug5870933

BEGIN
    print_fcn_label('arp_credit_memo_module.credit_transactions()+' );


    --------------------------------------------------------------------
    -- Check parameters
    --------------------------------------------------------------------
    IF( ( p_customer_trx_id IS NULL AND
	  p_customer_trx_line_id IS NULL AND
	  p_request_id IS NULL )
        OR
        ( p_request_id IS NOT NULL AND
          ( p_customer_trx_id IS NOT NULL OR
	    p_customer_trx_line_id IS NOT NULL OR
	    p_prev_cust_trx_line_id IS NOT NULL )
        )
      ) THEN

        --------------------------------------------------------------------
	-- Invalid parameters
        --------------------------------------------------------------------
        debug( '  raising invalid_parameters', MSG_LEVEL_DEBUG );
	g_error_buffer := MSG_INVALID_PARAMETERS;
	debug( 'EXCEPTION: '||g_error_buffer, MSG_LEVEL_BASIC );
	RAISE invalid_parameters;

    END IF;


    IF( p_process_mode = U ) THEN
        ------------------------------
        -- Process Update mode
        ------------------------------
	debug( '  Update mode', MSG_LEVEL_DEBUG );

	IF( NOT( dbms_sql.is_open( delete_header_dist_c ) AND
		 dbms_sql.is_open( delete_line_dist_c ) AND
		 dbms_sql.is_open( delete_header_cma_c ) AND
		 dbms_sql.is_open( delete_line_cma_c ) AND
		 dbms_sql.is_open( update_header_lines_c ) AND
		 dbms_sql.is_open( update_lines_c ) ) )  THEN

    	    ----------------------------------------------------------------
	    -- Build dynamic sql
    	    ----------------------------------------------------------------
	    build_update_mode_sql(
		delete_header_dist_c,
		delete_line_dist_c,
		delete_header_cma_c,
		delete_line_cma_c,
		update_header_lines_c,
		update_lines_c );

	END IF;

	SAVEPOINT ar_credit_memo_module2;

	BEGIN

    	    ----------------------------------------------------------------
	    -- Delete distributions, credit_memo_amounts
	    -- and update lines (rule_start_date, accounting_rule_duration)
    	    ----------------------------------------------------------------
	    IF( p_customer_trx_line_id IS NOT NULL ) THEN

	        ---------------------------------------------------------------
	        -- Line-level processing
                ---------------------------------------------------------------
		debug( '  Line-level processing', MSG_LEVEL_DEBUG );

	        ---------------------------------------------------------------
	        -- Bind variables
                ---------------------------------------------------------------
                dbms_sql.bind_variable(
			delete_line_dist_c,
			'customer_trx_line_id',
			p_customer_trx_line_id );

                dbms_sql.bind_variable(
			delete_line_cma_c,
			'customer_trx_line_id',
			p_customer_trx_line_id );

                dbms_sql.bind_variable(
			update_lines_c,
			'customer_trx_line_id',
			p_customer_trx_line_id );

                --------------------------------------------------------------
                --  Bind output variables
                --------------------------------------------------------------
                dbms_sql.bind_array(delete_line_dist_c, ':gl_dist_key_value',
                                    gl_line_dist_array);


	        ---------------------------------------------------------------
	        -- Execute sql
	        ---------------------------------------------------------------
                debug( '  Executing delete dist sql', MSG_LEVEL_DEBUG );
                BEGIN
                    l_ignore := dbms_sql.execute( delete_line_dist_c );

                    debug( to_char(l_ignore) || ' row(s) deleted',
		           MSG_LEVEL_DEBUG );

                   /*------------------------------------------+
                    | get RETURNING COLUMN into OUT NOCOPY bind array |
                    +------------------------------------------*/

                    dbms_sql.variable_value( delete_line_dist_c,
                                            ':gl_dist_key_value',
                                            gl_line_dist_array);
                EXCEPTION
                  WHEN OTHERS THEN
                      debug( 'EXCEPTION: Error executing delete dist sql' );
                      RAISE;
                END;

                debug( '  Executing delete cma sql', MSG_LEVEL_DEBUG );
                BEGIN
                    l_ignore := dbms_sql.execute( delete_line_cma_c );

                    debug( to_char(l_ignore) || ' row(s) deleted',
		           MSG_LEVEL_DEBUG );
                EXCEPTION
                  WHEN OTHERS THEN
                      debug( 'EXCEPTION: Error executing delete cma sql' );
                      RAISE;
                END;

                debug( '  Executing update lines sql', MSG_LEVEL_DEBUG );
                BEGIN
                    l_ignore := dbms_sql.execute( update_lines_c );

                    debug( to_char(l_ignore) || ' row(s) updated',
		           MSG_LEVEL_DEBUG );
                EXCEPTION
                  WHEN OTHERS THEN
                      debug( 'EXCEPTION: Error executing update lines sql' );
                      RAISE;
                END;

            ELSE

	        ---------------------------------------------------------------
	        -- Header-level processing
                ---------------------------------------------------------------
		debug( '  Header-level processing', MSG_LEVEL_DEBUG );

	        ---------------------------------------------------------------
	        -- Bind variables
                ---------------------------------------------------------------
                dbms_sql.bind_variable(
			delete_header_dist_c,
			'customer_trx_id',
			p_customer_trx_id );

                dbms_sql.bind_variable(
			delete_header_cma_c,
			'customer_trx_id',
			p_customer_trx_id );

                dbms_sql.bind_variable(
			update_header_lines_c,
			'customer_trx_id',
			p_customer_trx_id );

                --------------------------------------------------------------
                --  Bind output variables
                --------------------------------------------------------------
                dbms_sql.bind_array(delete_header_dist_c, ':gl_dist_key_value',
                                    gl_header_dist_array);

	        ---------------------------------------------------------------
	        -- Execute sql
	        ---------------------------------------------------------------
                debug( '  Executing delete dist sql', MSG_LEVEL_DEBUG );
                BEGIN
                    l_ignore := dbms_sql.execute( delete_header_dist_c );

                    debug( to_char(l_ignore) || ' row(s) deleted',
		           MSG_LEVEL_DEBUG );
                   /*------------------------------------------+
                    | get RETURNING COLUMN into OUT NOCOPY bind array |
                    +------------------------------------------*/

                    dbms_sql.variable_value( delete_header_dist_c,
                                            ':gl_dist_key_value',
                                            gl_header_dist_array);
                EXCEPTION
                  WHEN OTHERS THEN
                      debug( 'EXCEPTION: Error executing delete dist sql' );
                      RAISE;
                END;

                debug( '  Executing delete cma sql', MSG_LEVEL_DEBUG );
                BEGIN
                    l_ignore := dbms_sql.execute( delete_header_cma_c );

                    debug( to_char(l_ignore) || ' row(s) deleted',
		           MSG_LEVEL_DEBUG );
                EXCEPTION
                  WHEN OTHERS THEN
                      debug( 'EXCEPTION: Error executing delete cma sql' );
                      RAISE;
                END;

                debug( '  Executing update lines sql', MSG_LEVEL_DEBUG );
                BEGIN
                    l_ignore := dbms_sql.execute( update_header_lines_c );

                    debug( to_char(l_ignore) || ' row(s) updated',
		           MSG_LEVEL_DEBUG );
                EXCEPTION
                  WHEN OTHERS THEN
                      debug( 'EXCEPTION: Error executing update lines sql' );
                      RAISE;
                END;


	    END IF;

	EXCEPTION
	    WHEN OTHERS THEN

		ROLLBACK TO ar_credit_memo_module2;
	        g_error_buffer := SQLERRM;
                RAISE;

	END;


    END IF;


    --------------------------------------------------------------------
    -- Call cm module in I mode
    --------------------------------------------------------------------
    credit_transactions_ins_mode(
		p_customer_trx_id,
        	p_customer_trx_line_id,
        	p_prev_customer_trx_id,
        	p_prev_cust_trx_line_id,
        	p_request_id,
        	p_failure_count,
        	p_rule_start_date,
        	p_accounting_rule_duration,
                p_run_autoaccounting_flag
		);

   --bug 5870933
        /*-----------------------------------------------------+
         | Need to call ARP_XLA for denormalizing the event_id |
         | on rev distribution from CM Workflow                |
         +-----------------------------------------------------*/
      IF( p_customer_trx_id IS NOT NULL ) THEN
          l_xla_ev_rec.xla_from_doc_id := p_customer_trx_id;
          l_xla_ev_rec.xla_to_doc_id := p_customer_trx_id;
          l_xla_ev_rec.xla_doc_table := 'CT';
          l_xla_ev_rec.xla_mode := 'O';
          l_xla_ev_rec.xla_call := 'D';
          arp_xla_events.create_events(l_xla_ev_rec);
        END IF;


    print_fcn_label('arp_credit_memo_module.credit_transactions()-' );

END credit_transactions;

----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  credit_transactions
--
-- DECSRIPTION:
--   Server-side entry point for the CM module.
--
--
-- ARGUMENTS:
--      IN:
--        customer_trx_id
--        customer_trx_line_id
--        prev_customer_trx_id
--        prev_cust_trx_line_id
--        request_id
--	  process_mode 		(I)nsert or (U)pdate
--
--      IN/OUT:
--        failure_count
--
--      OUT:
--
-- NOTES:
--   This is the older version of the API and is a cover to the new version.
--   It exists for backward compatibillity.
--
--   Raises the exception arp_credit_memo_module.no_ccid if autoaccounting
--   could not derive a valid code combination.  The public variable
--   g_error_buffer is populated for more information.
--
--   Raises the exception NO_DATA_FOUND if no rows were selected for
--   processing.
--
--   Exception raised if Oracle error.
--   App_exception is raised for all other fatal errors and a message
--   is put on the AOL stack.  The public variable g_error_buffer is
--   populated for both types of errors.
--
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE credit_transactions(
	p_customer_trx_id 		IN NUMBER,
        p_customer_trx_line_id 		IN NUMBER,
        p_prev_customer_trx_id 		IN NUMBER,
        p_prev_cust_trx_line_id 	IN NUMBER,
        p_request_id 			IN NUMBER,
        p_failure_count	 		IN OUT NOCOPY NUMBER,
	p_process_mode			IN VARCHAR2
 ) IS

    l_date	DATE;
    l_number	NUMBER;

BEGIN

    print_fcn_label('arp_credit_memo_module.credit_transactions_cover()+' );

    credit_transactions(
	p_customer_trx_id,
        p_customer_trx_line_id,
        p_prev_customer_trx_id,
        p_prev_cust_trx_line_id,
        p_request_id,
        p_failure_count,
	l_date,			-- rule_start_date
	l_number,  		-- accounting_rule_duration
	p_process_mode
    );

    print_fcn_label('arp_credit_memo_module.credit_transactions_cover()-' );

END credit_transactions;


---------------------------------------------------------------------------
-- Test Functions
---------------------------------------------------------------------------
PROCEDURE test_build_nonrule_sql is

  l_cm_control control_rec_type;
  l_null_rec control_rec_type := l_cm_control;

BEGIN

    -- enable_debug( 1000000 );


-- sys info
debug( 'coa_id='||to_char(system_info.chart_of_accounts_id), MSG_LEVEL_DEBUG);
debug( 'curr='||system_info.base_currency, MSG_LEVEL_DEBUG);
debug( 'prec='||to_char(system_info.base_precision), MSG_LEVEL_DEBUG);
debug( 'mau='||to_char(system_info.base_min_acc_unit), MSG_LEVEL_DEBUG);

-- profile info
debug( 'login_id='||profile_info.conc_login_id, MSG_LEVEL_DEBUG );
debug( 'program_id='||profile_info.conc_program_id, MSG_LEVEL_DEBUG );
debug( 'user_id='||profile_info.user_id, MSG_LEVEL_DEBUG );
debug( 'use_inv_acct='||profile_info.use_inv_acct_for_cm_flag,
       MSG_LEVEL_DEBUG );
debug( 'org_id='||oe_profile.value('SO_ORGANIZATION_ID',arp_global.sysparam.org_id), MSG_LEVEL_DEBUG );

-- flex info
debug( 'nsegs='||to_char(flex_info.number_segments), MSG_LEVEL_DEBUG);
debug( 'delim='||flex_info.delim, MSG_LEVEL_DEBUG);

    debug('PASS LINE ID');

    l_cm_control.customer_trx_id := 1001;
    l_cm_control.customer_trx_line_id := 2001;
    l_cm_control.request_id := null;

    build_nonrule_sql(system_info,
                      profile_info,
                      l_cm_control,
                       nonrule_insert_dist_c,
                       nonrule_update_lines_c,
                       nonrule_update_dist_c,
                       nonrule_update_dist2_c );

    debug('PASS TRX ID');

    l_cm_control.customer_trx_id := 1001;
    l_cm_control.customer_trx_line_id := null;
    l_cm_control.request_id := null;

    build_nonrule_sql(system_info,
                      profile_info,
                      l_cm_control,
                       nonrule_insert_dist_c,
                       nonrule_update_lines_c,
                       nonrule_update_dist_c,
                       nonrule_update_dist2_c );

    debug('PASS REQ ID');

    l_cm_control.customer_trx_id := null;
    l_cm_control.customer_trx_line_id := null;
    l_cm_control.request_id := 101;

    build_nonrule_sql(system_info,
                      profile_info,
                      l_cm_control,
                       nonrule_insert_dist_c,
                       nonrule_update_lines_c,
                       nonrule_update_dist_c,
                       nonrule_update_dist2_c );

    disable_debug;


END;


--
--
--
PROCEDURE test_build_rule_sql is

  l_cm_control control_rec_type;
  l_null_rec control_rec_type := l_cm_control;

BEGIN

    -- enable_debug;


-- sys info
debug( 'coa_id='||to_char(system_info.chart_of_accounts_id), MSG_LEVEL_DEBUG);
debug( 'curr='||system_info.base_currency, MSG_LEVEL_DEBUG);
debug( 'prec='||to_char(system_info.base_precision), MSG_LEVEL_DEBUG);
debug( 'mau='||to_char(system_info.base_min_acc_unit), MSG_LEVEL_DEBUG);

-- profile info
debug( 'login_id='||profile_info.conc_login_id, MSG_LEVEL_DEBUG );
debug( 'program_id='||profile_info.conc_program_id, MSG_LEVEL_DEBUG );
debug( 'user_id='||profile_info.user_id, MSG_LEVEL_DEBUG );
debug( 'use_inv_acct='||profile_info.use_inv_acct_for_cm_flag,
       MSG_LEVEL_DEBUG );
debug( 'org_id='||oe_profile.value('SO_ORGANIZATION_ID',arp_global.sysparam.org_id), MSG_LEVEL_DEBUG );

-- flex info
debug( 'nsegs='||to_char(flex_info.number_segments), MSG_LEVEL_DEBUG);
debug( 'delim='||flex_info.delim, MSG_LEVEL_DEBUG);


-- system_info.base_min_acc_unit := .009;

    debug('PASS LINE ID');

    l_cm_control.customer_trx_id := 1001;
    l_cm_control.customer_trx_line_id := 2001;
    l_cm_control.request_id := null;

    build_rule_sql(system_info,
                      profile_info,
                      l_cm_control,
                      rule_select_cm_lines_c,
                      rule_update_cm_lines_c,
                      rule_insert_dist_c,
                      rule_insert_cma_c );

    debug('PASS TRX ID');

    l_cm_control.customer_trx_id := 1001;
    l_cm_control.customer_trx_line_id := null;
    l_cm_control.request_id := null;

    build_rule_sql(system_info,
                      profile_info,
                      l_cm_control,
                      rule_select_cm_lines_c,
                      rule_update_cm_lines_c,
                      rule_insert_dist_c,
                      rule_insert_cma_c );

    debug('PASS REQ ID');

    l_cm_control.customer_trx_id := null;
    l_cm_control.customer_trx_line_id := null;
    l_cm_control.request_id := 101;

    build_rule_sql(system_info,
                      profile_info,
                      l_cm_control,
                      rule_select_cm_lines_c,
                      rule_update_cm_lines_c,
                      rule_insert_dist_c,
                      rule_insert_cma_c );

    disable_debug;


END;


--
--
--
PROCEDURE test_build_net_revenue_sql is

  l_cm_control control_rec_type;
  l_null_rec control_rec_type := l_cm_control;

BEGIN

    -- enable_debug;


    debug('PASS LINE ID');
    l_cm_control.prev_customer_trx_id := NULL;
    l_cm_control.customer_trx_line_id := 2001;
    l_cm_control.prev_cust_trx_line_id := 3001;
    l_cm_control.request_id := null;

    build_net_revenue_sql(system_info,
                      profile_info,
                      l_cm_control,
                      net_revenue_line_c );


    debug('PASS TRX ID');
    l_cm_control.prev_customer_trx_id := 1001;
    l_cm_control.customer_trx_line_id := NULL;
    l_cm_control.prev_cust_trx_line_id := NULL;
    l_cm_control.request_id := NULL;

   build_net_revenue_sql(system_info,
                      profile_info,
                      l_cm_control,
                      net_revenue_line_c );

    debug('PASS REQUEST ID');
    l_cm_control.prev_customer_trx_id := NULL;
    l_cm_control.customer_trx_line_id := NULL;
    l_cm_control.prev_cust_trx_line_id := NULL;
    l_cm_control.request_id := 101;

    build_net_revenue_sql(system_info,
                      profile_info,
                      l_cm_control,
                      net_revenue_line_c );

    disable_debug;


END;


PROCEDURE test_build_update_mode_sql is

  l_cm_control control_rec_type;
  l_null_rec control_rec_type := l_cm_control;

BEGIN

    -- enable_debug( 1000000 );

    build_update_mode_sql(
		delete_header_dist_c,
		delete_line_dist_c,
		delete_header_cma_c,
		delete_line_cma_c,
		update_header_lines_c,
		update_lines_c );


END;


--
--
--
PROCEDURE test_load_net_revenue( p_prev_ctlid NUMBER ) is

  l_cm_control control_rec_type;
  l_null_rec control_rec_type := l_cm_control;

BEGIN

    -- enable_debug;

    l_cm_control.prev_customer_trx_id := NULL;
    l_cm_control.customer_trx_line_id := 2001;
    l_cm_control.prev_cust_trx_line_id := p_prev_ctlid;
    l_cm_control.request_id := NULL;

    load_net_revenue_schedule(
                      system_info,
                      profile_info,
                      l_cm_control, p_prev_ctlid );

    disable_debug;


END;

--
--
--
PROCEDURE test_credit_nonrule_trxs(
	p_customer_trx_id 	NUMBER,
	p_customer_trx_line_id 	NUMBER,
	p_request_id 		NUMBER
)  IS

  l_cm_control control_rec_type;
  l_null_rec control_rec_type := l_cm_control;

BEGIN

    -- enable_debug( 1000000 );
    arp_global.msg_level := 99;

    l_cm_control.customer_trx_id := p_customer_trx_id;
    l_cm_control.customer_trx_line_id := p_customer_trx_line_id;
    l_cm_control.request_id := p_request_id;

    credit_nonrule_transactions( system_info,
                                 profile_info,
                                 l_cm_control );



    disable_debug;


END;
--
--
--
PROCEDURE test_credit_rule_trxs(
	p_customer_trx_id 	NUMBER,
        p_prev_customer_trx_id	NUMBER,
	p_customer_trx_line_id 	NUMBER,
        p_prev_cust_trx_line_id NUMBER,
	p_request_id 		NUMBER
)  IS

  l_cm_control control_rec_type;
  l_null_rec control_rec_type := l_cm_control;
  l_rule_start_date		DATE;
  l_accounting_rule_duration 	NUMBER;
  l_number			NUMBER;

BEGIN

    -- enable_debug( 1000000 );
    arp_global.msg_level := MSG_LEVEL_DEBUG;

    l_cm_control.customer_trx_id := p_customer_trx_id;
    l_cm_control.prev_customer_trx_id := p_prev_customer_trx_id;
    l_cm_control.customer_trx_line_id := p_customer_trx_line_id;
    l_cm_control.prev_cust_trx_line_id := p_prev_cust_trx_line_id;
    l_cm_control.request_id := p_request_id;

    credit_rule_transactions( system_info,
                              profile_info,
                              l_cm_control,
			      l_number,
			      l_rule_start_date,
			      l_accounting_rule_duration );



    disable_debug;


END;

--
-- Constructor code
--
PROCEDURE init IS
BEGIN

    print_fcn_label( 'arp_credit_memo_module.constructor()+' );

    /* Bug 2560036 - determine if collectibility is enabled */
    g_test_collectibility :=
         ar_revenue_management_pvt.revenue_management_enabled;

    get_error_message_text;

    print_fcn_label( 'arp_credit_memo_module.constructor()-' );


EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_credit_memo_module.constructor()');
        debug(SQLERRM);
        RAISE;
END init;

BEGIN
  init;

END arp_credit_memo_module;

/
