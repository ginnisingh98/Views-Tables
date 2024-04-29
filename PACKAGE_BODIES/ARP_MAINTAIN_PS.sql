--------------------------------------------------------
--  DDL for Package Body ARP_MAINTAIN_PS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_MAINTAIN_PS" AS
/* $Header: ARTEMPSB.pls 120.15.12010000.3 2009/08/20 11:09:02 spdixit ship $ */
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

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
MSG_LEVEL_DEVELOP 	CONSTANT BINARY_INTEGER :=
				arp_global.MSG_LEVEL_DEVELOP;

YES			CONSTANT VARCHAR2(1) := arp_global.YES;
NO			CONSTANT VARCHAR2(1) := arp_global.NO;

DEP			CONSTANT VARCHAR2(10) := 'DEP';
GUAR			CONSTANT VARCHAR2(10) := 'GUAR';

I			CONSTANT VARCHAR2(10) := 'I';
U			CONSTANT VARCHAR2(10) := 'U';
D			CONSTANT VARCHAR2(10) := 'D';

--
-- User-defined exceptions
--
invalid_parameters		EXCEPTION;
invalid_mode	                EXCEPTION;


--
-- Translated error messages
--
MSG_INVALID_PARAMETERS		VARCHAR2(240);


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


TYPE control_rec_type IS RECORD
(
  process_mode			VARCHAR2(1),
  customer_trx_id		BINARY_INTEGER,
  payment_schedule_id		BINARY_INTEGER,
  line_amount			NUMBER,
  tax_amount			NUMBER,
  freight_amount		NUMBER,
  charge_amount			NUMBER,
  reversed_cash_receipt_id	NUMBER,
  trx_type			ra_cust_trx_types.type%type,
  is_open_receivable		BOOLEAN,
  is_postable			BOOLEAN,
  is_child			BOOLEAN,
  is_onacct_cm			BOOLEAN,
  previous_customer_trx_id	BINARY_INTEGER,
  initial_customer_trx_id	BINARY_INTEGER,
  initial_trx_type		ra_cust_trx_types.type%type
);

/* VAT changes */
SUBTYPE ae_doc_rec_type   IS arp_acct_main.ae_doc_rec_type;

------------------------------------------------------------------------
-- Private cursors
------------------------------------------------------------------------


------------------------------------------------------------------------
-- Covers
------------------------------------------------------------------------
PROCEDURE debug( p_line IN VARCHAR2 ) IS
BEGIN
  arp_util.debug( p_line );
END;
--
PROCEDURE debug(
	p_str VARCHAR2,
	p_print_level BINARY_INTEGER ) IS
BEGIN
  arp_util.debug( p_str, p_print_level );
END;
--
PROCEDURE enable_debug IS
BEGIN
  arp_util.enable_debug;
END;
--
PROCEDURE enable_debug( buffer_size NUMBER ) IS
BEGIN
  arp_util.enable_debug( buffer_size );
END;
--
PROCEDURE disable_debug IS
BEGIN
  arp_util.disable_debug;
END;
--
PROCEDURE print_fcn_label( p_label VARCHAR2 ) IS
BEGIN
  arp_util.print_fcn_label( p_label );
END;
--
PROCEDURE print_fcn_label2( p_label VARCHAR2 ) IS
BEGIN
  arp_util.print_fcn_label2( p_label );
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

    close_cursor( arp_maintain_ps2.ips_insert_ps_c );
    close_cursor( arp_maintain_ps2.ips_select_c );

    close_cursor( arp_maintain_ps2.ira_insert_ps_c );
    close_cursor( arp_maintain_ps2.ira_insert_ra_c );
    close_cursor( arp_maintain_ps2.ira_update_ps_c );
    close_cursor( arp_maintain_ps2.ira_select_c );

    close_cursor( arp_maintain_ps2.ups_insert_adj_c );
    close_cursor( arp_maintain_ps2.ups_update_ps_c );
    close_cursor( arp_maintain_ps2.ups_select_c );

    close_cursor( arp_maintain_ps2.iad_insert_adj_c );
    close_cursor( arp_maintain_ps2.iad_update_ps_c );
    close_cursor( arp_maintain_ps2.iad_select_c );

END;


----------------------------------------------------------------------------
PROCEDURE get_error_message_text is

    l_msg_name	   VARCHAR2(100);

BEGIN

    print_fcn_label( 'arp_maintain_ps.get_error_message_text()+' );

    ---
    l_msg_name := 'AR_INV_ARGS';
    fnd_message.set_name('AR', l_msg_name);
    fnd_message.set_token('PROCEDURE','arp_maintain_ps.get_error_message_text()');
    MSG_INVALID_PARAMETERS := fnd_message.get;

    -- print
    debug( 'MSG_INVALID_PARAMETERS='||MSG_INVALID_PARAMETERS,
	MSG_LEVEL_DEBUG );

    print_fcn_label( 'arp_maintain_ps.get_error_message_text()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_maintain_ps.get_error_message_text()');
        RAISE;
END get_error_message_text;

----------------------------------------------------------------------------

PROCEDURE do_setup( p_control_rec IN OUT NOCOPY control_rec_type ) IS

    l_open_rec 		VARCHAR2(1);
    l_post_to_gl 	VARCHAR2(1);
    l_onacct_cm 	VARCHAR2(1);


BEGIN

    print_fcn_label( 'arp_maintain_ps.do_setup()+' );

    BEGIN

        SELECT
        ctt.type,
        ctt.accounting_affect_flag,
        ctt.post_to_gl,
        decode(ctt.type,
               'CM', decode(ct.previous_customer_trx_id,
                            null, 'Y','N'),
               'N'),  			/* determine if onacct cm */
        ct.previous_customer_trx_id,
        ct.initial_customer_trx_id,
        ctt_init.type
        INTO
        p_control_rec.trx_type,
        l_open_rec,
        l_post_to_gl,
        l_onacct_cm,
        p_control_rec.previous_customer_trx_id,
        p_control_rec.initial_customer_trx_id,
        p_control_rec.initial_trx_type
        FROM
        ra_cust_trx_types ctt_init,
        ra_customer_trx ct_init,
        ra_cust_trx_types ctt,
        ra_customer_trx ct
        WHERE  ct.customer_trx_id   = p_control_rec.customer_trx_id
        and    ct.cust_trx_type_id  = ctt.cust_trx_type_id
        and    ct.initial_customer_trx_id = ct_init.customer_trx_id(+)
        and    ct_init.cust_trx_type_id = ctt_init.cust_trx_type_id(+);


    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error executing select stmt #1',
		 MSG_LEVEL_BASIC );
          RAISE;
    END;
    --
    --
    IF( l_open_rec = YES ) THEN
	p_control_rec.is_open_receivable := TRUE;
    ELSE
	p_control_rec.is_open_receivable := FALSE;
    END IF;
    --
    --
    IF( l_post_to_gl = YES ) THEN
	p_control_rec.is_postable := TRUE;
    ELSE
	p_control_rec.is_postable := FALSE;
    END IF;
    --
    --
    IF( l_onacct_cm = YES ) THEN
	p_control_rec.is_onacct_cm := TRUE;
    ELSE
	p_control_rec.is_onacct_cm := FALSE;
    END IF;
    --
    --

    -- check if regular CM
    IF( p_control_rec.previous_customer_trx_id IS NOT NULL ) THEN


	BEGIN
            SELECT
            ct_prev.initial_customer_trx_id,
            ctt_init.type
            INTO
            p_control_rec.initial_customer_trx_id,
            p_control_rec.initial_trx_type
            FROM
            ra_customer_trx ct,
            ra_customer_trx ct_prev,
            ra_customer_trx ct_init,
            ra_cust_trx_types ctt_init
            WHERE ct.customer_trx_id = p_control_rec.customer_trx_id
            and ct.previous_customer_trx_id = ct_prev.customer_trx_id
            and ct_prev.initial_customer_trx_id = ct_init.customer_trx_id(+)
            and ct_init.cust_trx_type_id = ctt_init.cust_trx_type_id(+);

        EXCEPTION
          WHEN OTHERS THEN
              debug( 'EXCEPTION: Error executing select stmt #2',
		 	MSG_LEVEL_BASIC );
              RAISE;
        END;

    END IF;


    IF( p_control_rec.initial_customer_trx_id IS NOT NULL ) THEN

       /* Bugfix 2742877.
          Check if adjustments exist before actually setting the flag.
          - For invoices, at this stage, there will be no adjustments.
	  - We should check for existence of commitments adjustments
	    against invoices,ONLY for regular CMs before setting the
	    is_child flag.
          - The commitment adj will be against guarantee's customer_trx_id
	    for GUAR
          - It will be against invoice's customer_trx_id for the DEP type
	    commitment.
	 Bug 2808262. When the CM is for lesser amount than the inv balance,
	 the cmtmt adj is not reversed. Set the is_child flag accordingly.
       */

       IF( p_control_rec.previous_customer_trx_id IS NOT NULL ) THEN

	  DECLARE
	     l_adj_exists NUMBER;
	  BEGIN

          /* salladi 3118714 */
               IF p_control_rec.process_mode = 'I' THEN

                SELECT 1
                INTO l_adj_exists
                FROM  ar_adjustments
                WHERE customer_trx_id = p_control_rec.previous_customer_trx_id
                AND   adjustment_type = 'C'
                AND   receivables_trx_id = -1
                AND   rownum = 1
                UNION ALL
                SELECT 1
                FROM  ar_adjustments
                WHERE subsequent_trx_id = p_control_rec.previous_customer_trx_id
                AND   adjustment_type = 'C'
                AND   receivables_trx_id = -1
                AND   rownum = 1;
             ELSE


 	     /* IF p_control_rec.process_mode = 'I' THEN
		IF p_control_rec.initial_trx_type = 'DEP' THEN
	           SELECT 1
	           INTO l_adj_exists
	           FROM  ar_adjustments
	           WHERE customer_trx_id = p_control_rec.previous_customer_trx_id
	           AND   adjustment_type = 'C'
	           AND   receivables_trx_id = -1
	           AND   rownum = 1;
                ELSIF p_control_rec.initial_trx_type = 'GUAR' THEN
                   SELECT 1
	           INTO l_adj_exists
                   FROM  ar_adjustments
                   WHERE subsequent_trx_id = p_control_rec.previous_customer_trx_id
                   AND   adjustment_type = 'C'
                   AND   receivables_trx_id = -1
                   AND   rownum = 1;
 		END IF;
	     ELSE          */
            /* salladi */

             IF p_control_rec.initial_trx_type = 'DEP' THEN
                   SELECT 1
                   INTO l_adj_exists
                   FROM  ar_adjustments
                   WHERE customer_trx_id = p_control_rec.previous_customer_trx_id
                   AND   subsequent_trx_id = p_control_rec.customer_trx_id
                   AND   adjustment_type = 'C'
                   AND   receivables_trx_id = -1
                   AND   rownum = 1;
                ELSIF p_control_rec.initial_trx_type = 'GUAR' THEN
                   SELECT 1
	           INTO l_adj_exists
                   FROM  ar_adjustments
                   WHERE customer_trx_id = p_control_rec.initial_customer_trx_id
                   AND   subsequent_trx_id = p_control_rec.customer_trx_id
                   AND   adjustment_type = 'C'
                   AND   receivables_trx_id = -1
                   AND   rownum = 1;
	        END IF;
	     END IF;

	     p_control_rec.is_child := TRUE;
	  EXCEPTION
	     WHEN NO_DATA_FOUND THEN
	        p_control_rec.is_child := FALSE;
             WHEN OTHERS THEN
                debug( 'EXCEPTION: Error executing select stmt for check for adjustments',
		 	MSG_LEVEL_BASIC );
                RAISE;
	  END;

       ELSE
          p_control_rec.is_child := TRUE;
       END IF;

    ELSE
	p_control_rec.is_child := FALSE;
    END IF;


    print_fcn_label( 'arp_maintain_ps.do_setup()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps.do_setup()',
	       MSG_LEVEL_BASIC );
        RAISE;

END do_setup;


----------------------------------------------------------------------------
PROCEDURE build_doc_combo_sql(
	p_system_info 		IN arp_trx_global.system_info_rec_type,
        p_profile_info 		IN arp_trx_global.profile_rec_type,
        p_select_c 		IN OUT NOCOPY INTEGER ) IS

    l_select_sql	VARCHAR2(500);


BEGIN

    print_fcn_label( 'arp_maintain_ps.build_doc_combo_sql()+' );

    ------------------------------------------------
    -- Select sql
    ------------------------------------------------
    l_select_sql :=
'SELECT
ct.set_of_books_id,
ct.trx_date,
rt.name
FROM
ra_customer_trx ct,
ar_receivables_trx rt
WHERE  rt.receivables_trx_id = -1
and    ct.customer_trx_id = :customer_trx_id';


    ------------------------------------------------
    -- Parse sql stmts
    ------------------------------------------------
    BEGIN
	debug( '  Parsing stmts', MSG_LEVEL_DEBUG );

        p_select_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_select_c, l_select_sql,
                        dbms_sql.v7 );

    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error parsing stmts', MSG_LEVEL_BASIC );
          RAISE;
    END;

    print_fcn_label( 'arp_maintain_ps.build_doc_combo_sql()-' );


EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps.build_doc_combo_sql()',
	       MSG_LEVEL_BASIC );

        RAISE;
END build_doc_combo_sql;


----------------------------------------------------------------------------
PROCEDURE build_doc_insert_audit_sql(
	p_system_info 		IN arp_trx_global.system_info_rec_type,
        p_profile_info 		IN arp_trx_global.profile_rec_type,
	p_where_clause		IN VARCHAR2,
        p_insert_audit_c 	IN OUT NOCOPY INTEGER ) IS

    l_insert_audit_sql	VARCHAR2(1000);


BEGIN

    print_fcn_label( 'arp_maintain_ps.build_doc_insert_audit_sql()+' );

    ------------------------------------------------
    -- Insert audit table sql
    ------------------------------------------------
    l_insert_audit_sql :=
'INSERT INTO ar_doc_sequence_audit
(
doc_sequence_id,
doc_sequence_assignment_id,
doc_sequence_value,
creation_date,
created_by
)
SELECT
doc_sequence_id,
:sequence_assignment_id,
doc_sequence_value,
creation_date,
created_by
FROM AR_ADJUSTMENTS'||CRLF||p_where_clause;


    ------------------------------------------------
    -- Parse sql stmts
    ------------------------------------------------
    BEGIN
	debug( '  Parsing stmts', MSG_LEVEL_DEBUG );

        p_insert_audit_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_insert_audit_c, l_insert_audit_sql,
                        dbms_sql.v7 );

    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error parsing stmts', MSG_LEVEL_BASIC );
          RAISE;
    END;

    print_fcn_label( 'arp_maintain_ps.build_doc_insert_audit_sql()-' );


EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps.build_doc_insert_audit_sql()',
	       MSG_LEVEL_BASIC );

        RAISE;
END build_doc_insert_audit_sql;


----------------------------------------------------------------------------
PROCEDURE build_doc_update_adj_sql(
	p_system_info 		IN arp_trx_global.system_info_rec_type,
        p_profile_info 		IN arp_trx_global.profile_rec_type,
	p_sequence_name		IN VARCHAR2,
	p_sequence_id		IN BINARY_INTEGER,
	p_where_clause		IN VARCHAR2,
        p_update_adj_c 		IN OUT NOCOPY INTEGER ) IS

    l_update_adj_sql	VARCHAR2(1000);



BEGIN

    print_fcn_label( 'arp_maintain_ps.build_doc_update_adj_sql()+' );

    ------------------------------------------------
    -- Update adjustments sql
    ------------------------------------------------
    --Bug 1508981 - Update statement modified to take the sequence value
    --provided, rather than getting the sequence_name.nextval. Previous method
    --did not work for gaples sequence.
    --p_sequence_name contains the sequence value now.

    l_update_adj_sql :=
'UPDATE ar_adjustments adj
SET
doc_sequence_value = ' || p_sequence_name || ',' || CRLF ||
'doc_sequence_id = ' || p_sequence_id || CRLF || p_where_clause;


    ------------------------------------------------
    -- Parse sql stmts
    ------------------------------------------------
    BEGIN
	debug( '  Parsing stmts', MSG_LEVEL_DEBUG );

        p_update_adj_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_update_adj_c, l_update_adj_sql,
                        dbms_sql.v7 );


    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error parsing stmts', MSG_LEVEL_BASIC );
          RAISE;
    END;

    print_fcn_label( 'arp_maintain_ps.build_doc_update_adj_sql()-' );


EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps.build_doc_update_adj_sql()',
	       MSG_LEVEL_BASIC );

        RAISE;
END build_doc_update_adj_sql;


----------------------------------------------------------------------------
PROCEDURE update_adj_document_number(
		p_system_info 	IN arp_trx_global.system_info_rec_type,
        	p_profile_info 		IN arp_trx_global.profile_rec_type,
		p_customer_trx_id 	BINARY_INTEGER,
		p_bind1          	BINARY_INTEGER,
		p_bind2          	BINARY_INTEGER,
		p_bind3          	BINARY_INTEGER,
		p_update_where_clause	VARCHAR2 ) IS



    l_set_of_books_id           BINARY_INTEGER;
    l_trx_date                  DATE;
    l_type                      VARCHAR2(500);

    l_sequence_name             VARCHAR2(500);
    l_sequence_id               BINARY_INTEGER;
    l_sequence_assignment_id    BINARY_INTEGER;
    l_sequence_value            NUMBER;
    l_dummy                     NUMBER;
    l_sequence_type             VARCHAR2(100);
    l_db_sequence_name          VARCHAR2(100);
    l_prod_table_name           VARCHAR2(50);
    l_audit_table_name          VARCHAR2(50);
    l_mesg_flag                 VARCHAR2(1);
    l_ignore                    INTEGER;
    v_profVal       varchar2(40);--Bug 1796816
    --BugFix 2095183 Added the Following 2 Statements.
    l_update_where_clause varchar2(2000) default NULL;
/* bugfix 2454787 */
    cursor c_ar_adjustments(cust_trx_id BINARY_INTEGER) is
           select adjustment_id from ar_adjustments where customer_trx_id=cust_trx_id
           UNION
           select adjustment_id from ar_adjustments where subsequent_trx_id = cust_trx_id;

BEGIN

    print_fcn_label( 'arp_maintain_ps.update_adj_document_number()+' );

    ---------------------------------------------------------------
    -- Build dynamic sql
    ---------------------------------------------------------------
    IF( NOT( dbms_sql.is_open( doc_combo_select_c ) ) ) THEN

        build_doc_combo_sql(
		system_info,
		profile_info,
		doc_combo_select_c );

    END IF;

    build_doc_insert_audit_sql(
		system_info,
		profile_info,
		p_update_where_clause,
		doc_insert_audit_c );

    ---------------------------------------------------------------
    -- Bind variables
    ---------------------------------------------------------------
    dbms_sql.bind_variable( doc_combo_select_c,
			    'customer_trx_id',
			    p_customer_trx_id );

    if (p_bind1 is not null) then
	dbms_sql.bind_variable( doc_insert_audit_c,':bind1',p_bind1);
    end if;

    if (p_bind2 is not null) then
	dbms_sql.bind_variable( doc_insert_audit_c,':bind2',p_bind2);
    end if;

    if (p_bind3 is not null) then
	dbms_sql.bind_variable( doc_insert_audit_c,':bind3',p_bind3);
    end if;

    ---------------------------------------------------------------
    -- Define columns
    ---------------------------------------------------------------
    dbms_sql.define_column( doc_combo_select_c, 1, l_set_of_books_id );
    dbms_sql.define_column( doc_combo_select_c, 2, l_trx_date );
    dbms_sql.define_column( doc_combo_select_c, 3, l_type, 30 );

    ---------------------------------------------------------------
    -- Execute sql
    ---------------------------------------------------------------
    debug( '  Executing select sql', MSG_LEVEL_DEBUG );

    BEGIN
        l_ignore := dbms_sql.execute( doc_combo_select_c );

    EXCEPTION
      WHEN OTHERS THEN
          debug( 'EXCEPTION: Error executing select sql',
		 MSG_LEVEL_BASIC );
          RAISE;
    END;


    ---------------------------------------------------------------
    -- Fetch rows
    ---------------------------------------------------------------
    BEGIN
        LOOP

            IF dbms_sql.fetch_rows( doc_combo_select_c ) > 0  THEN

	        debug('  Fetched a row', MSG_LEVEL_DEBUG );

    		-----------------------------------------------------------
		-- Get variables:
    		-----------------------------------------------------------
		dbms_sql.column_value( doc_combo_select_c,
					1, l_set_of_books_id );
		dbms_sql.column_value( doc_combo_select_c, 2, l_trx_date );
		dbms_sql.column_value( doc_combo_select_c, 3, l_type );

		debug('  set_of_books_id='||l_set_of_books_id,
			MSG_LEVEL_DEVELOP );
		debug('  trx_date='||l_trx_date, MSG_LEVEL_DEVELOP );
		debug('  type='||l_type, MSG_LEVEL_DEVELOP );

    		-----------------------------------------------------------
		-- Call AOL sequential numbers API
    		-----------------------------------------------------------
		BEGIN

  /********************************************
   *  Bug 1097459.                            *
   *  Changing all fnd sequnce calls          *
   *  to the new ones.                        *
   *  We are using FND_SEQNUM.GET_SEQ_NAME    *
   *  Instead of FND_SEQNUM.GET_SEQ_INFO      *
   *******************************************/

/*                  fnd_seqnum.get_seq_name(
                        222,                    -- application_id
                        l_type,                 -- category_code
                        l_set_of_books_id,
                        'A',                    -- method_code
                        l_trx_date,
                        l_sequence_name,
                        l_sequence_id,
                        l_sequence_assignment_id );
*/

/* Bug NO:1796816-Passed parameters supress_error,supress_warning
		 as 'Y','Y' so taht FND error message will be supressed
		 when sequence numbering profile option is  set to Partial
		  used.
*/

	FND_PROFILE.GET( 'UNIQUE:SEQ_NUMBERS', v_profVal );
        debug('  v_profVal='||v_profVal, MSG_LEVEL_DEVELOP );
        if(v_profVal = 'P') THEN
                l_dummy:= FND_SEQNUM.GET_SEQ_INFO(
                                222,                    -- application_id
                                l_type,                 -- category_code
                                l_set_of_books_id,
                                'A',                    -- method_code
                                l_trx_date,
                                l_sequence_id,
                                l_sequence_type,
                                l_sequence_name,
                                l_db_sequence_name,
                                l_sequence_assignment_id,
                                l_prod_table_name,
                                l_audit_table_name,
                                l_mesg_flag,'y','y');

	else
                l_dummy:= FND_SEQNUM.GET_SEQ_INFO(
                                222,                    -- application_id
                                l_type,                 -- category_code
                                l_set_of_books_id,
                                'A',                    -- method_code
                                l_trx_date,
                                l_sequence_id,
                                l_sequence_type,
                                l_sequence_name,
                                l_db_sequence_name,
                                l_sequence_assignment_id,
                                l_prod_table_name,
                                l_audit_table_name,
                                l_mesg_flag);
		END IF;


                        debug('  sequence_name='||l_sequence_name, MSG_LEVEL_DEVELOP );
                        debug('  sequence_id='||l_sequence_id, MSG_LEVEL_DEVELOP );
                        debug('  sequence_assignment_id='|| l_sequence_assignment_id, MSG_LEVEL_DEVELOP );

/* Bug 1535839 : When 'Sequential Numbering' is 'Not Used' , the
adjustment record must not be updated  */


                IF ( l_dummy = -7 or l_sequence_id is NULL ) THEN
                    GOTO skip;
                END IF;

		EXCEPTION
		    WHEN NO_DATA_FOUND THEN
			debug('  doc assignment does not exist',
				MSG_LEVEL_DEBUG );

			GOTO skip;

		END;

/*
		l_sequence_value :=
			fnd_seqnum.get_next_auto_seq( l_sequence_name );

		debug('  sequence_value='||
				l_sequence_value, MSG_LEVEL_DEVELOP );
*/
               --BugFix 2095183 Added the Following For Loop For Fetching
               --AR_ADJUSTMENTS Records for the Corresponding customer_trx_id.

             For adj_rec in c_ar_adjustments(p_customer_trx_id) loop

                --Bug 1508981 - Added the call to get the next sequence number

                l_sequence_value := FND_SEQNUM.get_next_sequence (222,
                                    l_type,
                                    l_set_of_books_id,
                                    'A',
                                    l_trx_date,
                                    l_db_sequence_name,
                                    l_sequence_assignment_id);

    		-----------------------------------------------------------
		-- Update the ar_adjustments table
    		-----------------------------------------------------------
		BEGIN

    		    -------------------------------------------------------
		    -- Build update stmt
    		    -------------------------------------------------------
                --BugFix 2095183 Added the Following Statement in order to add
                --an Extra condition for p_update_where_clause.

                l_update_where_clause := p_update_where_clause || ' and adjustment_id = :adjustment_id ';
		    build_doc_update_adj_sql(
				system_info,
				profile_info,
				l_sequence_value, --Bug 1508981 Modified to pass the value
				l_sequence_id,
				l_update_where_clause, --BugFix 2095183.Changed the parameter
				doc_update_adj_c );

                    -- Bind Variables
                        if (p_bind1 is not null) then
				dbms_sql.bind_variable( doc_update_adj_c ,':bind1',p_bind1);
			end if;

			if (p_bind2 is not null) then
				dbms_sql.bind_variable( doc_update_adj_c ,':bind2',p_bind2);
			end if;

			if (p_bind3 is not null) then
				dbms_sql.bind_variable( doc_update_adj_c ,':bind3',p_bind3);
			end if;
                        dbms_sql.bind_variable( doc_update_adj_c ,':adjustment_id',adj_rec.adjustment_id);



		    l_ignore := dbms_sql.execute( doc_update_adj_c );

                    /* MRC call not required because update only affects
                       doc_sequence_value and doc_sequence_id - Ie. no
                       accounting columns */

            	    debug( to_char(l_ignore) || ' row(s) updated',
		           MSG_LEVEL_DEBUG );

		EXCEPTION
        	    WHEN OTHERS THEN
            		debug( 'EXCEPTION: Error updating ar_adjustments',
                   		MSG_LEVEL_BASIC );
            		RAISE;

    		END;
            --BugFix 2095183 Added the following Statement.
            END LOOP; /* For c_ar_adjustments Cursor */


    		-----------------------------------------------------------
		-- Insert into the audit table: ar_doc_sequence_audit
    		-----------------------------------------------------------
		BEGIN
    		    -------------------------------------------------------
    		    -- Bind variables
    		    -------------------------------------------------------
    		    dbms_sql.bind_variable(
				doc_insert_audit_c,
			 	'sequence_assignment_id',
			    	l_sequence_assignment_id );

		    l_ignore := dbms_sql.execute( doc_insert_audit_c );

            	    debug( to_char(l_ignore) || ' row(s) inserted',
		           MSG_LEVEL_DEBUG );


		EXCEPTION
        	    WHEN OTHERS THEN
            		debug( 'EXCEPTION: Error inserting audit table',
                   		MSG_LEVEL_BASIC );
            		RAISE;

    		END;

	    ELSE	-- no more rows to fetch
		EXIT;

            END IF;	-- if row was fetched


<<skip>>
	    NULL;

        END LOOP;	-- end fetching

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: Error fetching select cursor',
                   MSG_LEVEL_BASIC );
            RAISE;

    END;


    print_fcn_label( 'arp_maintain_ps.update_adj_document_number()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps.update_adj_document_number()',
	       MSG_LEVEL_BASIC );
        RAISE;

END update_adj_document_number;


----------------------------------------------------------------------------
PROCEDURE delete_payment_schedule( p_customer_trx_id IN BINARY_INTEGER ) IS

   l_ar_ps_key_value_list gl_ca_utility_pkg.r_key_value_arr;

BEGIN

    print_fcn_label( 'arp_maintain_ps.delete_payment_schedule()+' );

    --
    --
    BEGIN

        DELETE
        FROM ar_payment_schedules ps
        WHERE ps.customer_trx_id = p_customer_trx_id
        RETURNING ps.payment_schedule_id
        BULK COLLECT INTO l_ar_ps_key_value_list;

        debug( SQL%ROWCOUNT||' row(s) deleted', MSG_LEVEL_DEBUG );

        /*-------------------------------+
         | Calling central MRC library   |
         | for MRC integration           |
         +-------------------------------*/

         ar_mrc_engine.maintain_mrc_data(
                p_event_mode        => 'DELETE',
                p_table_name        => 'AR_PAYMENT_SCHEDULES',
                p_mode              => 'BATCH',
                p_key_value_list    => l_ar_ps_key_value_list);

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing delete stmt',
		 	MSG_LEVEL_BASIC );
            RAISE;
    END;

    print_fcn_label( 'arp_maintain_ps.delete_payment_schedule()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps.delete_payment_schedule()',
	       MSG_LEVEL_BASIC );
        RAISE;

END delete_payment_schedule;


----------------------------------------------------------------------------
PROCEDURE delete_applications( p_customer_trx_id IN BINARY_INTEGER ) IS

CURSOR del_app IS
       select app.receivable_application_id app_id,
              app.customer_trx_id           trx_id
       from  ar_receivable_applications app
       where app.customer_trx_id = p_customer_trx_id
       and   nvl(app.confirmed_flag,'Y') = 'Y' --accounting exists in ar_distributions only if confirmed
       and   exists (select 'x'
                     from  ar_distributions ard
                     where ard.source_table = 'RA'
                     and   ard.source_id    = app.receivable_application_id); --delete only necessary records

l_rec_del_app del_app%ROWTYPE;
l_ae_doc_rec ae_doc_rec_type;

l_rec_app_key_value_list   gl_ca_utility_pkg.r_key_value_arr;   /* MRC */

BEGIN

    print_fcn_label( 'arp_maintain_ps.delete_applications()+' );

    BEGIN

        FOR l_rec_del_app in del_app LOOP
            --
            --Release 11.5 VAT changes, delete accounting for Applications
            --
             l_ae_doc_rec.document_type           := 'CREDIT_MEMO';
             l_ae_doc_rec.document_id             := l_rec_del_app.trx_id;
             l_ae_doc_rec.accounting_entity_level := 'ONE';
             l_ae_doc_rec.source_table            := 'RA';
             l_ae_doc_rec.source_id               := l_rec_del_app.app_id;
             l_ae_doc_rec.source_id_old           := '';
             l_ae_doc_rec.other_flag              := '';

             arp_acct_main.Delete_Acct_Entry(l_ae_doc_rec);

        END LOOP;

      --Now delete parent application record
        DELETE
        FROM ar_receivable_applications ra
        WHERE ra.customer_trx_id = p_customer_trx_id
        RETURNING receivable_application_id
        BULK COLLECT INTO l_rec_app_key_value_list;

        debug( SQL%ROWCOUNT||' row(s) deleted', MSG_LEVEL_DEBUG );

        /*---------------------------------+
         | Calling central MRC library     |
         | for MRC Integration             |
         +---------------------------------*/

         ar_mrc_engine.maintain_mrc_data(
                        p_event_mode        => 'DELETE',
                        p_table_name        => 'AR_RECEIVABLE_APPLICATIONS',
                        p_mode              => 'BATCH',
                        p_key_value_list    => l_rec_app_key_value_list);

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing delete stmt',
		 	MSG_LEVEL_BASIC );
            RAISE;
    END;

    print_fcn_label( 'arp_maintain_ps.delete_applications()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps.delete_applications()',
	       MSG_LEVEL_BASIC );
        RAISE;

END delete_applications;


----------------------------------------------------------------------------
PROCEDURE delete_adjustments(
	p_customer_trx_id 	IN BINARY_INTEGER,
	p_subsequent_trx_id 	IN BINARY_INTEGER
) IS
    l_adj_key_value_list  gl_ca_utility_pkg.r_key_value_arr;

BEGIN

    print_fcn_label( 'arp_maintain_ps.delete_adjustments()+' );

    --
    --
    BEGIN

	IF( p_subsequent_trx_id IS NULL ) THEN

            DELETE
            FROM ar_adjustments adj
            WHERE adj.customer_trx_id = p_customer_trx_id
            and adj.receivables_trx_id = -1
            RETURNING adjustment_id
            BULK COLLECT INTO l_adj_key_value_list;

           /*---------------------------------+
            | Calling central MRC library     |
            | for MRC Integration             |
            +---------------------------------*/

            ar_mrc_engine.maintain_mrc_data(
                        p_event_mode        => 'DELETE',
                        p_table_name        => 'AR_ADJUSTMENTS',
                        p_mode              => 'BULK',
                        p_key_value_list    => l_adj_key_value_list);

        ELSE

            DELETE
            FROM ar_adjustments adj
            WHERE adj.customer_trx_id = p_customer_trx_id
            and adj.subsequent_trx_id = p_subsequent_trx_id
            and adj.receivables_trx_id = -1
            RETURNING adjustment_id
            BULK COLLECT INTO l_adj_key_value_list;

           /*---------------------------------+
            | Calling central MRC library     |
            | for MRC Integration             |
            +---------------------------------*/

            ar_mrc_engine.maintain_mrc_data(
                        p_event_mode        => 'DELETE',
                        p_table_name        => 'AR_ADJUSTMENTS',
                        p_mode              => 'BULK',
                        p_key_value_list    => l_adj_key_value_list);

        END IF;

        debug( SQL%ROWCOUNT||' row(s) deleted', MSG_LEVEL_DEBUG );

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing delete stmt',
		 	MSG_LEVEL_BASIC );
            RAISE;
    END;

    print_fcn_label( 'arp_maintain_ps.delete_adjustments()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps.delete_adjustments()',
	       MSG_LEVEL_BASIC );
        RAISE;

END delete_adjustments;

----------------------------------------------------------------------------
PROCEDURE reverse_adjustments(
	p_system_info 		IN arp_trx_global.system_info_rec_type,
	p_profile_info 		IN arp_trx_global.profile_rec_type,
	p_customer_trx_id 	IN BINARY_INTEGER,
	p_subsequent_trx_id 	IN BINARY_INTEGER
) IS
    /* VAT changes */
    l_ae_doc_rec         ae_doc_rec_type;
    l_adjustment_id	 ar_adjustments.adjustment_id%type;

    l_ar_ps_key_value_list gl_ca_utility_pkg.r_key_value_arr;

BEGIN

    print_fcn_label( 'arp_maintain_ps.reverse_adjustments()+' );

    BEGIN

        UPDATE ar_payment_schedules ps
        SET (
        ps.status,
        ps.gl_date_closed,
        ps.actual_date_closed,
        ps.amount_adjusted,
        ps.amount_due_remaining,
        ps.acctd_amount_due_remaining,
        ps.amount_line_items_remaining,
        ps.tax_remaining,
        ps.freight_remaining,
        ps.receivables_charges_remaining,
        last_updated_by,
        last_update_date,
        last_update_login) = (
        SELECT
        decode(ps2.amount_due_remaining - adj.amount, 0, 'CL', 'OP'),
        decode(ps2.amount_due_remaining - adj.amount,
               0,
               greatest(nvl(max(decode(ra2.confirmed_flag,
			               'N', ps2.gl_date,
			               ra2.gl_date)),
                            ps2.gl_date),
		        max(decode(adj2.customer_trx_id,
			           p_customer_trx_id,
                                   decode(adj2.subsequent_trx_id,
				          p_subsequent_trx_id,
			                  decode( adj2.receivables_trx_id,
				                 -1, ps2.gl_date,
                                                 adj2.gl_date ),
                                          adj2.gl_date),
                                   adj2.gl_date)
                            )
                       ),
                TO_DATE('4712/12/31', 'YYYY/MM/DD')),
        decode(ps2.amount_due_remaining - adj.amount,
               0,
               greatest(nvl(max(decode(ra2.confirmed_flag,
			               'N', ps2.trx_date,
			               ra2.apply_date)),
                            ps2.trx_date),
		        max(decode(adj2.customer_trx_id,
		                   p_customer_trx_id,
                                   decode(adj2.subsequent_trx_id,
			                  p_subsequent_trx_id,
				          decode(adj2.receivables_trx_id,
					         -1, ps2.trx_date,
                                                 adj2.apply_date),
                                          adj2.apply_date),
                                   adj2.apply_date)
                           )
                       ),
               TO_DATE('4712/12/31', 'YYYY/MM/DD')),
        nvl(ps2.amount_adjusted, 0) - adj.amount,
        ps2.amount_due_remaining - adj.amount,
        ps2.acctd_amount_due_remaining - adj.acctd_amount,
        nvl(ps2.amount_line_items_remaining, 0) -
            nvl(adj.line_adjusted, decode(adj.type, 'LINE', adj.amount, 0)),
        nvl(ps2.tax_remaining, 0) -
            nvl(adj.tax_adjusted, decode(adj.type, 'TAX', adj.amount, 0)),
        nvl(ps2.freight_remaining, 0) -
            nvl(adj.freight_adjusted,
                decode(adj.type, 'FREIGHT', adj.amount, 0)),
        nvl(ps2.receivables_charges_remaining, 0) -
            nvl(adj.receivables_charges_adjusted,
                decode(adj.type, 'CHARGES', adj.amount, 0)),
        p_profile_info.user_id,
        trunc(sysdate),
        p_profile_info.conc_login_id
        FROM
        ar_adjustments adj,
        ar_payment_schedules ps2,
        ar_adjustments adj2,
        ar_receivable_applications ra2
        WHERE adj.receivables_trx_id =-1
        and adj.customer_trx_id = p_customer_trx_id
        and adj.subsequent_trx_id = p_subsequent_trx_id
        and adj.payment_schedule_id = ps2.payment_schedule_id
        and ps2.payment_schedule_id = ps.payment_schedule_id
        and ps2.payment_schedule_id = adj2.payment_schedule_id
        and adj2.status = 'A'
        and ps2.payment_schedule_id = ra2.applied_payment_schedule_id(+)
        GROUP BY
        ps2.payment_schedule_id,
        ra2.applied_payment_schedule_id,
        adj2.payment_schedule_id,
        ps2.amount_due_remaining,
        adj.amount,
        ps2.gl_date,
        ps2.trx_date,
        ps2.amount_adjusted,
        ps2.acctd_amount_due_remaining,
        adj.acctd_amount,
        ps2.amount_line_items_remaining,
        adj.line_adjusted,
        adj.type,
        ps2.tax_remaining,
        adj.tax_adjusted,
        ps2.freight_remaining,
        adj.freight_adjusted,
        ps2.receivables_charges_remaining,
        adj.receivables_charges_adjusted )
        WHERE ps.payment_schedule_id in
        (
          SELECT
          adj3.payment_schedule_id
          FROM ar_adjustments adj3
          WHERE adj3.customer_trx_id = p_customer_trx_id
          and adj3.subsequent_trx_id = p_subsequent_trx_id
          and adj3.receivables_trx_id = -1
        )
       RETURNING ps.payment_schedule_id
       BULK COLLECT INTO l_ar_ps_key_value_list;

       debug( SQL%ROWCOUNT||' row(s) updated', MSG_LEVEL_DEBUG );

      /*---------------------------------+
       | Calling central MRC library     |
       | for MRC Integration             |
       +---------------------------------*/

       ar_mrc_engine.maintain_mrc_data(
             p_event_mode        => 'UPDATE',
             p_table_name        => 'AR_PAYMENT_SCHEDULES',
             p_mode              => 'BATCH',
             p_key_value_list    => l_ar_ps_key_value_list);

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing update stmt',
		 	MSG_LEVEL_BASIC );
            RAISE;
    END;

    --
    --
    /* VAT changes: delete acct entry */
    /* bug 2808262. Changed the code to have a cursor */

    DECLARE
       CURSOR c1 IS SELECT adj.adjustment_id
      		    FROM ar_adjustments adj
      		    WHERE adj.customer_trx_id = p_customer_trx_id
            	    AND adj.receivables_trx_id = -1;
    BEGIN
       FOR i IN c1 LOOP
          delete_adjustments( p_customer_trx_id, p_subsequent_trx_id );

       END LOOP;
    END;
    print_fcn_label( 'arp_maintain_ps.reverse_adjustments()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps.reverse_adjustments()',
	       MSG_LEVEL_BASIC );
        RAISE;

END reverse_adjustments;


----------------------------------------------------------------------------
PROCEDURE reverse_cm_effect(
	p_system_info 		IN arp_trx_global.system_info_rec_type,
	p_profile_info 		IN arp_trx_global.profile_rec_type,
	p_customer_trx_id 	IN BINARY_INTEGER
) IS

     l_ar_ps_key_value_list gl_ca_utility_pkg.r_key_value_arr;

BEGIN

    print_fcn_label( 'arp_maintain_ps.reverse_cm_effect()+' );

    BEGIN

        UPDATE ar_payment_schedules ps
        SET (
        status,
        gl_date_closed,
        actual_date_closed,
        amount_credited,
        amount_due_remaining,
        acctd_amount_due_remaining,
        amount_line_items_remaining,
        tax_remaining,
        freight_remaining,
        receivables_charges_remaining,
        last_updated_by,
        last_update_date,
        last_update_login) = (
        SELECT
        decode(ps2.amount_due_remaining + ra.amount_applied,0,'CL','OP'),
        decode(ps2.amount_due_remaining + ra.amount_applied,
               0,
               greatest(max(decode(ra2.customer_trx_id,
	                           p_customer_trx_id, ps2.gl_date,
			           ra2.gl_date)),
                        max(decode(adj2.status,
		                   'A', adj2.gl_date,
			           ps2.gl_date))),
               to_date('31-12-4712','DD-MM-YYYY')),--Added default date 31-12-4712 as per Bug:5514315
        decode(ps2.amount_due_remaining + ra.amount_applied,
               0,
               greatest(max(decode(ra2.customer_trx_id,
                                   p_customer_trx_id, ps2.trx_date,
			           ra2.apply_date)),
		        max(decode(adj2.status,
			           'A', adj2.apply_date,
			           ps2.trx_date))),
               to_date('31-12-4712','DD-MM-YYYY')),--Added default date 31-12-4712 as per Bug:5514315
        nvl(ps2.amount_credited, 0) + ra.amount_applied,
        ps2.amount_due_remaining + ra.amount_applied,
        ps2.acctd_amount_due_remaining + nvl(ra.acctd_amount_applied_to, 0),
        nvl(ps2.amount_line_items_remaining, 0) + nvl(ra.line_applied, 0),
        nvl(ps2.tax_remaining, 0) + nvl(ra.tax_applied,0),
        nvl(ps2.freight_remaining, 0) + nvl(ra.freight_applied, 0),
        nvl(ps2.receivables_charges_remaining, 0) +
	        nvl(ra.receivables_charges_applied, 0),
        p_profile_info.user_id,
        trunc(sysdate),
        p_profile_info.conc_login_id
        FROM
        ar_receivable_applications ra,
        ar_payment_schedules ps2,
        ar_adjustments adj2,
        ar_receivable_applications ra2
        WHERE ra.customer_trx_id = p_customer_trx_id
        and ra.status||'' = 'APP'
        and ra.applied_payment_schedule_id = ps2.payment_schedule_id
        and ps2.payment_schedule_id =ps.payment_schedule_id
               and ps2.payment_schedule_id = adj2.payment_schedule_id(+)
        and ps2.payment_schedule_id = ra2.applied_payment_schedule_id
        and nvl(ra2.confirmed_flag,'Y')= 'Y'
        GROUP BY
        ps2.payment_schedule_id,
        ra2.applied_payment_schedule_id,
        adj2.payment_schedule_id,
        ps2.amount_due_remaining,
        ra.amount_applied,
        ps2.gl_date,
        ps2.trx_date,
        ps2.amount_credited,
        ps2.acctd_amount_due_remaining,
        ra.acctd_amount_applied_to,
        ps2.amount_line_items_remaining,
        ra.line_applied,
        ps2.tax_remaining,
        ra.tax_applied,
        ps2.freight_remaining,
        ra.freight_applied,
        ps2.receivables_charges_remaining,
        ra.receivables_charges_applied)
        WHERE ps.payment_schedule_id in
        (
          SELECT ra3.applied_payment_schedule_id
          FROM ar_receivable_applications ra3
          WHERE ra3.customer_trx_id = p_customer_trx_id
          and ra3.status='APP'
        )
       RETURNING ps.payment_schedule_id
       BULK COLLECT INTO l_ar_ps_key_value_list;

        debug( SQL%ROWCOUNT||' row(s) updated', MSG_LEVEL_DEBUG );

      /*---------------------------------+
       | Calling central MRC library     |
       | for MRC Integration             |
       +---------------------------------*/

       ar_mrc_engine.maintain_mrc_data(
               p_event_mode        => 'UPDATE',
               p_table_name        => 'AR_PAYMENT_SCHEDULES',
               p_mode              => 'BATCH',
               p_key_value_list    => l_ar_ps_key_value_list);

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing update stmt',
		 	MSG_LEVEL_BASIC );
            RAISE;
    END;



    print_fcn_label( 'arp_maintain_ps.reverse_cm_effect()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps.reverse_cm_effect()',
	       MSG_LEVEL_BASIC );
        RAISE;

END reverse_cm_effect;


----------------------------------------------------------------------------
PROCEDURE update_payment_schedule(
	p_system_info 		IN arp_trx_global.system_info_rec_type,
	p_profile_info 		IN arp_trx_global.profile_rec_type,
	p_control 		IN control_rec_type
) IS

--BUG#5324129
CURSOR del_app(p_app_id  IN NUMBER) IS
       select app.receivable_application_id app_id,
              app.customer_trx_id           trx_id
       from  ar_receivable_applications app
       where app.applied_payment_schedule_id  = p_control.payment_schedule_id --inv ps
       and   app.customer_trx_id              = p_control.customer_trx_id     --cm trx id
       and   nvl(app.confirmed_flag,'Y')      = 'Y' --accounting exists in ar_distributions only if confirmed
       and   app.reversal_gl_date            IS NULL
       and   app.receivable_application_id   = p_app_id
       and   exists (select 'x'
                     from  ar_distributions ard
                     where ard.source_table = 'RA'
                     and   ard.source_id    = app.receivable_application_id); --delete only necessary records

--BUG#5324129
CURSOR cre_app(p_app_id  IN NUMBER) IS
       select app.receivable_application_id app_id,
              app.customer_trx_id           trx_id
       from  ar_receivable_applications app
       where app.applied_payment_schedule_id  = p_control.payment_schedule_id
       and   app.customer_trx_id              = p_control.customer_trx_id
       and   nvl(app.confirmed_flag,'Y')      = 'Y'
       and   app.reversal_gl_date            IS NULL
       and   app.receivable_application_id   = p_app_id
       and   not exists (select 'x'
                     from  ar_distributions ard
                     where ard.source_table = 'RA'
                     and   ard.source_id    = app.receivable_application_id);

--BUG#5324129
CURSOR cu_posted IS
       select *
       from  ar_receivable_applications
       where applied_payment_schedule_id  = p_control.payment_schedule_id
       and   customer_trx_id              = p_control.customer_trx_id
       and   nvl(confirmed_flag,'Y')      = 'Y'
       and   reversal_gl_date             IS NULL;


CURSOR get_app_id(p_app_id  IN NUMBER) IS
   select  app.receivable_application_id,
           app.amount_applied
     from  ar_receivable_applications app
    where  app.applied_payment_schedule_id = p_control.payment_schedule_id
      and  app.customer_trx_id             = p_control.customer_trx_id
      and  app.receivable_application_id   = p_app_id;


    l_ae_doc_rec ae_doc_rec_type;

    l_cm_adr 			NUMBER;
    l_cm_acctd_adr 		NUMBER;
    l_cm_rate			NUMBER;
    l_new_amount_applied	NUMBER;
    l_new_acctd_amt_applied_from	NUMBER;
    l_new_acctd_amt_applied_to	NUMBER;
    l_inv_adr			NUMBER;
    l_inv_acctd_adr		NUMBER;
    l_new_inv_acctd_adr		NUMBER;
    l_inv_rate			NUMBER;

    l_dummy			NUMBER;
    l_foreign_transaction	VARCHAR2(1) := NO;

    l_ar_ps_key_value_list gl_ca_utility_pkg.r_key_value_arr;

    --BUG#5324129
    l_app_id             NUMBER;
    l_amount_applied     NUMBER;
    l_ra_id              NUMBER;
    l_del_app_rec        del_app%ROWTYPE;
    l_cre_app_rec        cre_app%ROWTYPE;
    old_rec_app          ar_receivable_Applications%ROWTYPE;
    ins_ra_rec           ar_receivable_Applications%ROWTYPE;
    no_app_found         EXCEPTION;

BEGIN

    print_fcn_label( 'arp_maintain_ps.update_payment_schedule()+' );

    --BUG#5324129
    OPEN  cu_posted;
    FETCH cu_posted INTO old_rec_app;
    IF cu_posted%NOTFOUND THEN
       RAISE no_app_found;
    END IF;
    CLOSE cu_posted;

    arp_standard.debug(' old_rec_app.receivable_application_id:'||old_rec_app.receivable_application_id);
    arp_standard.debug(' old_rec_app.posting_control_id:'||old_rec_app.posting_control_id);


    BEGIN

        SELECT
        ps_cm.amount_due_remaining - ra.amount_applied,
        ps_cm.acctd_amount_due_remaining - ra.acctd_amount_applied_from,
        ps_cm.exchange_rate,
        -( p_control.line_amount +
           p_control.tax_amount +
           p_control.freight_amount +
           p_control.charge_amount ),
        ps_inv.amount_due_remaining + ra.amount_applied,
        ps_inv.acctd_amount_due_remaining + ra.acctd_amount_applied_to,
        ps_inv.exchange_rate
        INTO
        l_cm_adr,
        l_cm_acctd_adr,
        l_cm_rate,
        l_new_amount_applied,
        l_inv_adr,
        l_inv_acctd_adr,
        l_inv_rate
        FROM
        ar_payment_schedules ps_cm,
        ar_payment_schedules ps_inv,
        ar_receivable_applications ra
        WHERE  p_system_info.base_currency <> ps_inv.invoice_currency_code
        and  ra.applied_payment_schedule_id = ps_inv.payment_schedule_id
        and  ps_inv.payment_schedule_id     = p_control.payment_schedule_id
        and  ra.payment_schedule_id         = ps_cm.payment_schedule_id
        and  ps_cm.customer_trx_id          = p_control.customer_trx_id
        and  ra.reversal_gl_date            IS NULL
        and  ra.receivable_application_id   = old_rec_app.receivable_application_id;

        l_foreign_transaction := YES;


    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    l_foreign_transaction := NO;

        WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing select stmt',
		 	MSG_LEVEL_BASIC );
            RAISE;
    END;

    IF( l_foreign_transaction = YES ) THEN

	------------------------------------------------------------------
	-- Compute accounted amounts for ps and applications
	------------------------------------------------------------------
	arp_util.calc_acctd_amount(
		p_system_info.base_currency,
		NULL,			-- precision
		NULL,			-- mau
		l_inv_rate,
		'-',			-- type
		l_inv_adr,		-- master_from
		l_inv_acctd_adr,	-- acctd_master_from
		l_new_amount_applied,	-- detail
		l_dummy,		-- master_to
		l_new_inv_acctd_adr,	-- acctd_master_to
		l_new_acctd_amt_applied_to  	-- acctd_detail
	);

	arp_util.calc_acctd_amount(
		p_system_info.base_currency,
		NULL,			-- precision
		NULL,			-- mau
		l_cm_rate,
		'+',			-- type
		l_cm_adr,		-- master_from
		l_cm_acctd_adr,		-- acctd_master_from
		l_new_amount_applied,	-- detail
		l_dummy,		-- master_to
		l_dummy,		-- acctd_master_to
		l_new_acctd_amt_applied_from 	-- acctd_detail
	);

    END IF;

    BEGIN
        ----------------------------------------------------------------
        -- Reverse the origial CM application amounts and use the new
        -- amounts passed in for the invoice's payment schedule.
        ----------------------------------------------------------------
        UPDATE ar_payment_schedules ps
        SET (
        ps.status,
        ps.gl_date_closed,
        ps.actual_date_closed,
        ps.amount_credited,
        ps.amount_due_remaining,
        ps.acctd_amount_due_remaining,
        ps.amount_line_items_remaining,
        ps.tax_remaining,
        ps.freight_remaining,
        ps.receivables_charges_remaining,
        ps.last_updated_by,
        ps.last_update_date,
        ps.last_update_login) = (
        SELECT
        decode( ps2.amount_due_remaining + ra.amount_applied +
                 (p_control.line_amount +
	          p_control.tax_amount +
	          p_control.freight_amount +
	          p_control.charge_amount ),
                0, 'CL', 'OP'),
        decode( ps2.amount_due_remaining + ra.amount_applied +
                 (p_control.line_amount +
	          p_control.tax_amount +
	          p_control.freight_amount +
	          p_control.charge_amount ),
                0,
                greatest(max(ra2.gl_date), max(decode(adj2.status,
				                      'A', adj2.gl_date,
				                      ps2.gl_date))),
                ''),
        decode(ps2.amount_due_remaining + ra.amount_applied +
                 (p_control.line_amount +
	          p_control.tax_amount +
	          p_control.freight_amount +
	          p_control.charge_amount ),
               0, greatest(max(ra2.apply_date),
                           max(decode(adj2.status,
		                      'A', adj2.apply_date,
                                      ps2.trx_date))),
               ''),
        nvl(ps2.amount_credited, 0) + ra.amount_applied +
                 (p_control.line_amount +
	          p_control.tax_amount +
	          p_control.freight_amount +
	          p_control.charge_amount ),
        ps2.amount_due_remaining + ra.amount_applied +
                 (p_control.line_amount +
	          p_control.tax_amount +
	          p_control.freight_amount +
	          p_control.charge_amount ),
        decode(l_foreign_transaction,
               'N',
               ps2.amount_due_remaining + ra.amount_applied +
                 (p_control.line_amount +
	          p_control.tax_amount +
	          p_control.freight_amount +
	          p_control.charge_amount ),
               'Y', to_number(nvl(l_new_inv_acctd_adr, 0))),
        nvl(ps2.amount_line_items_remaining, 0) + nvl(ra.line_applied, 0) +
                                      p_control.line_amount,
        nvl(ps2.tax_remaining, 0) + nvl(ra.tax_applied, 0) +
                                      p_control.tax_amount,
        nvl(ps2.freight_remaining, 0) + nvl(ra.freight_applied, 0) +
                                      p_control.freight_amount,
        nvl(ps2.receivables_charges_remaining, 0) +
                                      nvl(ra.receivables_charges_applied, 0) +
                                      p_control.charge_amount,
        p_profile_info.user_id,
        trunc(sysdate),
        p_profile_info.conc_login_id
        FROM
        ar_receivable_applications ra,
        ar_payment_schedules ps2,
        ar_receivable_applications ra2,
        ar_adjustments adj2
        WHERE ra.customer_trx_id = p_control.customer_trx_id
        and   ra.status||''      = 'APP'
        and   ra.reversal_gl_date IS NULL
        and   ra.applied_payment_schedule_id = ps2.payment_schedule_id
        and   ps.payment_schedule_id = ps2.payment_schedule_id
        and   ps2.payment_schedule_id = adj2.payment_schedule_id(+)
        and   ps2.payment_schedule_id = ra2.applied_payment_schedule_id
        and   ra2.reversal_gl_date IS NULL
        and   nvl(ra2.confirmed_flag, 'Y') = 'Y'
        and   ra.receivable_application_id = old_rec_app.receivable_application_id
        GROUP BY
        ps2.payment_schedule_id,
        ra2.applied_payment_schedule_id,
        adj2.payment_schedule_id,
        ps2.amount_due_remaining,
        ra.amount_applied,
        ps2.gl_date,
        ps2.trx_date,
        ps2.amount_credited,
        ps2.acctd_amount_due_remaining,
        ra.acctd_amount_applied_to,
        ps2.amount_line_items_remaining,
        ra.line_applied,
        ps2.tax_remaining,
        ra.tax_applied,
        ps2.freight_remaining,
        ra.freight_applied,
        ps2.receivables_charges_remaining,
        ra.receivables_charges_applied,
        ps2.exchange_rate)
        WHERE ps.payment_schedule_id in
        (
          SELECT ra3.applied_payment_schedule_id
          FROM ar_receivable_applications ra3
          WHERE ra3.customer_trx_id = p_control.customer_trx_id
          and ra3.status = 'APP'
          and ra3.applied_payment_schedule_id = p_control.payment_schedule_id
          and ra3.reversal_gl_date IS NULL
        )
        RETURNING payment_schedule_id
                BULK COLLECT INTO l_ar_ps_key_value_list;

        debug( SQL%ROWCOUNT||' row(s) updated', MSG_LEVEL_DEBUG );

        /*---------------------------------+
         | Calling central MRC library     |
         | for MRC Integration             |
         +---------------------------------*/

        ar_mrc_engine.maintain_mrc_data(
                p_event_mode        => 'UPDATE',
                p_table_name        => 'AR_PAYMENT_SCHEDULES',
                p_mode              => 'BATCH',
                p_key_value_list    => l_ar_ps_key_value_list);

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing update stmt #1',
		 	MSG_LEVEL_BASIC );
            RAISE;
    END;


    BEGIN
        ----------------------------------------------------------------
        -- Release 11.5, plug in changes delete the accounting for the
        -- updated CM and then recreate the same. Direct updates are not
        -- done for child accounting records.
        ----------------------------------------------------------------
        IF old_rec_app.posting_control_id = -3 THEN


        arp_standard.debug('Path Update CM RA and recreate distributions');
        arp_standard.debug('1 Delete current RA distributions');

        OPEN del_app(old_rec_app.receivable_application_id);
        LOOP
           FETCH del_app INTO l_del_app_rec;
           EXIT WHEN del_app%NOTFOUND;
            --
            --Release 11.5 VAT changes, delete accounting for Applications
            --
	     arp_standard.debug('  Current distributions exist delete distributions +');
             l_ae_doc_rec.document_type           := 'CREDIT_MEMO';
             l_ae_doc_rec.document_id             := l_del_app_rec.trx_id;
             l_ae_doc_rec.accounting_entity_level := 'ONE';
             l_ae_doc_rec.source_table            := 'RA';
             l_ae_doc_rec.source_id               := l_del_app_rec.app_id;
             l_ae_doc_rec.source_id_old           := '';
             l_ae_doc_rec.other_flag              := '';
           --Bug 1329091 - PS is updated before Accounting Engine Call

             l_ae_doc_rec.pay_sched_upd_yn := 'Y';

             arp_acct_main.Delete_Acct_Entry(l_ae_doc_rec);
	     arp_standard.debug('  delete distributions -');

         END LOOP;
         CLOSE del_app;


        ----------------------------------------------------------------
        -- Update the CM application record to the correct amount
        ----------------------------------------------------------------
	arp_standard.debug('Update the CM app ra_id '|| old_rec_app.receivable_application_id || '+');

        UPDATE ar_receivable_applications ra
        SET
        acctd_amount_applied_from =
          decode(l_foreign_transaction,
                 'N',
                 -( p_control.line_amount +
	            p_control.tax_amount +
	            p_control.freight_amount +
	            p_control.charge_amount ),
                 'Y', to_number( nvl(l_new_acctd_amt_applied_from, 0) ) ),
        acctd_amount_applied_to =
          decode(l_foreign_transaction,
                 'N',
                 -(p_control.line_amount +
	           p_control.tax_amount +
	           p_control.freight_amount +
	           p_control.charge_amount),
                 'Y', to_number(nvl(l_new_acctd_amt_applied_to, 0))),
        amount_applied =
          -(p_control.line_amount +
            p_control.tax_amount +
            p_control.freight_amount +
            p_control.charge_amount),
        line_applied =  -p_control.line_amount,
        tax_applied = -p_control.tax_amount,
        freight_applied = -p_control.freight_amount,
        receivables_charges_applied = -p_control.charge_amount,
        last_updated_by = p_profile_info.user_id,
        last_update_date = trunc(sysdate),
        last_update_login = p_profile_info.conc_login_id
        WHERE ra.applied_payment_schedule_id  = p_control.payment_schedule_id
        and ra.customer_trx_id                = p_control.customer_trx_id
        and ra.reversal_gl_date               IS NULL
        and ra.receivable_application_id      = old_rec_app.receivable_application_id;

        debug( SQL%ROWCOUNT||' row(s) updated', MSG_LEVEL_DEBUG );


       arp_standard.debug('MRC plugins ');
        OPEN get_app_id(old_rec_app.receivable_application_id);
        LOOP
           FETCH get_app_id INTO l_app_id, l_amount_applied;
           EXIT WHEN get_app_id%NOTFOUND;
           -- Call mrc engine to process update:
           ar_mrc_engine3.update_cm_application(
                     l_app_id,
                     p_control.payment_schedule_id,  /* p_app_ps_id */
                     p_control.customer_trx_id,     /* p_ct_id */
                     l_amount_applied);
        END LOOP;
	CLOSE get_app_id;

        arp_standard.debug('End update the CM app ra_id');
        ----------------------------------------------------------------
        -- Release 11.5, plug in changes recreate the accounting for the
        -- updated CM once parent records have been updated.Only one APP
        -- for the credit memo should get updated in previous statement.
        ----------------------------------------------------------------
        arp_standard.debug('Creation of new distributions');
        OPEN cre_app(old_rec_app.receivable_application_id);
        LOOP
           FETCH cre_app INTO l_cre_app_rec;
           EXIT WHEN cre_app%NOTFOUND;
            --
            --Release 11.5 VAT changes, recreate accounting for Applications
            --
	     arp_standard.debug('   recreate distributions +:'||l_cre_app_rec.app_id);
             l_ae_doc_rec.document_type           := 'CREDIT_MEMO';
             l_ae_doc_rec.document_id             := l_cre_app_rec.trx_id;
             l_ae_doc_rec.accounting_entity_level := 'ONE';
             l_ae_doc_rec.source_table            := 'RA';
             l_ae_doc_rec.source_id               := l_cre_app_rec.app_id;
             l_ae_doc_rec.source_id_old           := '';
             l_ae_doc_rec.other_flag              := '';

          --Bug 1329091 - PS is updated before Accounting Engine Call

            l_ae_doc_rec.pay_sched_upd_yn := 'Y';
	    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

    	    /*bug-6976549*/
    	    arp_balance_check.CHECK_APPLN_BALANCE(l_cre_app_rec.app_id,
					  NULL,
					  'N');

            arp_standard.debug('   recreate distributions -');
        END LOOP;
        CLOSE cre_app;
        arp_standard.debug('End Path Update CM RA and recreate distributions');

    ELSE

      arp_standard.debug('Path Reverse CM RA and create new CM RA');
      --BUG#5324129
      -- Insert RA to reverse the posted one
      ins_ra_rec                       := old_rec_app;
      ins_ra_rec.acctd_amount_applied_from := -1 * old_rec_app.acctd_amount_applied_from;
      ins_ra_rec.amount_applied        :=  -1 * old_rec_app.amount_applied;
      ins_ra_rec.amount_applied_from   :=  -1 * old_rec_app.amount_applied_from;
      ins_ra_rec.trans_to_receipt_rate := old_rec_app.trans_to_receipt_rate;
      ins_ra_rec.application_type      := old_rec_app.application_type;
      ins_ra_rec.apply_date            := TRUNC(SYSDATE);
      ins_ra_rec.code_combination_id   := old_rec_app.code_combination_id;
      ins_ra_rec.display               :=  'N';
      ins_ra_rec.gl_date               := TRUNC(SYSDATE);
      ins_ra_rec.payment_schedule_id   := old_rec_app.payment_schedule_id;
      ins_ra_rec.set_of_books_id       := old_rec_app.set_of_books_id;
      ins_ra_rec.status                := old_rec_app.status;
      ins_ra_rec.acctd_amount_applied_to       := -1 * old_rec_app.acctd_amount_applied_to;
      ins_ra_rec.acctd_earned_discount_taken   := -1 * old_rec_app.acctd_earned_discount_taken;
      ins_ra_rec.acctd_unearned_discount_taken :=  -1 * old_rec_app.acctd_unearned_discount_taken;
      ins_ra_rec.applied_customer_trx_id      := old_rec_app.applied_customer_trx_id;
      ins_ra_rec.applied_customer_trx_line_id := old_rec_app.applied_customer_trx_line_id;
      ins_ra_rec.applied_payment_schedule_id  := old_rec_app.applied_payment_schedule_id;
      ins_ra_rec.cash_receipt_id              := old_rec_app.cash_receipt_id;
      ins_ra_rec.comments            := old_rec_app.comments;
      ins_ra_rec.confirmed_flag      := old_rec_app.confirmed_flag;
      ins_ra_rec.customer_trx_id     := old_rec_app.customer_trx_id;
      ins_ra_rec.days_late           := old_rec_app.days_late;
      ins_ra_rec.earned_discount_taken := -1 * old_rec_app.earned_discount_taken;
      ins_ra_rec.freight_applied       := -1 * old_rec_app.freight_applied;
      ins_ra_rec.gl_posted_date        := NULL;
      ins_ra_rec.line_applied          := -1 * old_rec_app.line_applied;
      ins_ra_rec.on_account_customer   := old_rec_app.on_account_customer;
      ins_ra_rec.postable              := old_rec_app.postable;
      ins_ra_rec.posting_control_id    := -3;
      ins_ra_rec.program_application_id := NULL;
      ins_ra_rec.program_id             := NULL;
      ins_ra_rec.program_update_date    := NULL;
      ins_ra_rec.receivables_charges_applied := -1 * old_rec_app.receivables_charges_applied;
      ins_ra_rec.receivables_trx_id          := old_rec_app.receivables_trx_id;
      ins_ra_rec.request_id                  := NULL;
      ins_ra_rec.tax_applied                 := -1 * old_rec_app.tax_applied;
      ins_ra_rec.unearned_discount_taken     := -1 * old_rec_app.unearned_discount_taken;
      ins_ra_rec.unearned_discount_ccid      := old_rec_app.unearned_discount_ccid;
      ins_ra_rec.earned_discount_ccid        := old_rec_app.earned_discount_ccid;
      ins_ra_rec.ussgl_transaction_code      := old_rec_app.ussgl_transaction_code;
      ins_ra_rec.ussgl_transaction_code_context := old_rec_app.ussgl_transaction_code_context;
      ins_ra_rec.reversal_gl_date            := TRUNC(SYSDATE);
      ins_ra_rec.LINE_EDISCOUNTED            := -1 * old_rec_app.LINE_EDISCOUNTED;
      ins_ra_rec.LINE_UEDISCOUNTED           := -1 * old_rec_app.LINE_UEDISCOUNTED;
      ins_ra_rec.TAX_EDISCOUNTED             := -1 * old_rec_app.TAX_EDISCOUNTED;
      ins_ra_rec.TAX_UEDISCOUNTED            := -1 * old_rec_app.TAX_UEDISCOUNTED;
      ins_ra_rec.FREIGHT_EDISCOUNTED         := -1 * old_rec_app.FREIGHT_EDISCOUNTED;
      ins_ra_rec.FREIGHT_UEDISCOUNTED        := -1 * old_rec_app.FREIGHT_UEDISCOUNTED;
      ins_ra_rec.CHARGES_EDISCOUNTED         := -1 * old_rec_app.CHARGES_EDISCOUNTED;
      ins_ra_rec.CHARGES_UEDISCOUNTED        := -1 * old_rec_app.CHARGES_UEDISCOUNTED;
      ins_ra_rec.APPLICATION_REF_TYPE        := old_rec_app.APPLICATION_REF_TYPE;
      ins_ra_rec.application_ref_id          := old_rec_app.application_ref_id;
      ins_ra_rec.application_ref_num         := old_rec_app.application_ref_num;
      ins_ra_rec.application_ref_reason      := old_rec_app.application_ref_reason;
      ins_ra_rec.customer_reference          := old_rec_app.customer_reference;
      ins_ra_rec.link_to_customer_trx_id     := old_rec_app.link_to_customer_trx_id;
      ins_ra_rec.customer_reason             := old_rec_app.customer_reason;
      ins_ra_rec.applied_rec_app_id          := old_rec_app.applied_rec_app_id;
      ins_ra_rec.application_rule            := 'CREDIT MEMO REVERSAL';
      ins_ra_rec.receivable_application_id   := NULL;

      arp_app_pkg.insert_p( ins_ra_rec, l_ra_id );
      arp_standard.debug('Reverse application inserted ra_id :'||l_ra_id);

      --Update the reversal app record reversal_gl_date
      UPDATE ar_receivable_applications
      SET reversal_gl_date = TRUNC(SYSDATE),
          display          = 'N'
      WHERE receivable_application_id =  old_rec_app.receivable_application_id;

      arp_standard.debug('The old ra record '|| old_rec_app.receivable_application_id ||' reversal_gl_date updated ');

      -- MRC cm app record inserted
      -- need to call mrc engine to process rec apps row
      arp_standard.debug('Plugin MRC call for ra reversal ');
      ar_mrc_engine3.reversal_insert_oppos_ra_recs(
               ins_ra_rec,
               old_rec_app.receivable_application_id,
               l_ra_id);
      -----------------
      -- Create reversal distributions
      -----------------
      arp_standard.debug('create the distribution for reversal app :'||l_ra_id);
      l_ae_doc_rec.source_table  := 'RA';
      l_ae_doc_rec.accounting_entity_level := 'ONE';
      l_ae_doc_rec.other_flag    := 'REVERSE';
      l_ae_doc_rec.source_id_old := old_rec_app.receivable_application_id;
      l_ae_doc_rec.source_id     := l_ra_id;
      l_ae_doc_rec.document_type := 'CREDIT_MEMO';

      arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);
    	    /*bug-6976549*/
    	    arp_balance_check.CHECK_APPLN_BALANCE(l_ra_id,
					  NULL,
					  'N');


      ----------------------------------------------------------------
      -- create the new CM application record to the correct amount
      ----------------------------------------------------------------
      arp_standard.debug('create the new CM APP record ');

      ins_ra_rec                           := old_rec_app;
      IF l_foreign_transaction = 'N' THEN
         ins_ra_rec.acctd_amount_applied_from :=  -( p_control.line_amount +
                                                         p_control.tax_amount +
                                                         p_control.freight_amount +
                                                         p_control.charge_amount );
      ELSE
         ins_ra_rec.acctd_amount_applied_from := to_number( nvl(l_new_acctd_amt_applied_from, 0));
      END IF;

      IF l_foreign_transaction = 'N' THEN
         ins_ra_rec.acctd_amount_applied_to   := -(p_control.line_amount +
                                                        p_control.tax_amount +
                                                        p_control.freight_amount +
                                                        p_control.charge_amount);
      ELSE
         ins_ra_rec.acctd_amount_applied_to   :=  to_number(nvl(l_new_acctd_amt_applied_to, 0));
      END IF;

      ins_ra_rec.amount_applied            := -(p_control.line_amount +
                                                p_control.tax_amount +
                                                p_control.freight_amount +
                                                p_control.charge_amount);
      ins_ra_rec.line_applied              := -p_control.line_amount;
      ins_ra_rec.tax_applied               := -p_control.tax_amount;
      ins_ra_rec.freight_applied           := -p_control.freight_amount;
      ins_ra_rec.receivables_charges_applied := -p_control.charge_amount;
      ins_ra_rec.posting_control_id        := -3;
      ins_ra_rec.gl_posted_date            := NULL;
      ins_ra_rec.reversal_gl_date          := NULL;
      ins_ra_rec.gl_date                   := TRUNC(SYSDATE);
      ins_ra_rec.display                   :=  'Y';
      ins_ra_rec.receivable_application_id := NULL;

      arp_app_pkg.insert_p( ins_ra_rec, l_ra_id );
      arp_standard.debug('CM APP record created :'||l_ra_id);


      arp_standard.debug('MRC plugin call for the app record '||l_ra_id);
      ar_mrc_engine3.cm_application(
       p_cm_ps_id       => old_rec_app.payment_schedule_id,
       p_invoice_ps_id  => old_rec_app.applied_payment_schedule_id,
       p_inv_ra_rec     => ins_ra_rec,
       p_ra_id          => l_ra_id);

      arp_standard.debug('Create the distributions for '||l_ra_id);
      -- Create the distributions
      l_ae_doc_rec.document_id             := ins_ra_rec.customer_trx_id;
      l_ae_doc_rec.accounting_entity_level := 'ONE';
      l_ae_doc_rec.source_table            := 'RA';
      l_ae_doc_rec.source_id               := l_ra_id;
      l_ae_doc_rec.source_id_old           := '';
      l_ae_doc_rec.other_flag              := '';
      l_ae_doc_rec.pay_sched_upd_yn        := 'Y';

             arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);
    	    /*bug-6976549*/
    	    arp_balance_check.CHECK_APPLN_BALANCE(l_ra_id,
					  NULL,
					  'N');

         END IF;

   EXCEPTION
        WHEN no_app_found THEN
            arp_standard.debug('No app found');
        WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing update stmt #2',
		 	MSG_LEVEL_BASIC );
            RAISE;
    END;

    print_fcn_label( 'arp_maintain_ps.update_payment_schedule()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps.update_payment_schedule()',
	       MSG_LEVEL_BASIC );
        RAISE;

END update_payment_schedule;


----------------------------------------------------------------------------
PROCEDURE update_adjustments(
	p_system_info 		IN arp_trx_global.system_info_rec_type,
	p_profile_info 		IN arp_trx_global.profile_rec_type,
	p_control 		IN control_rec_type
) IS

CURSOR del_app IS
       select app.receivable_application_id app_id,
              app.customer_trx_id           trx_id
       from  ar_receivable_applications app
       where app.applied_payment_schedule_id  = p_control.payment_schedule_id
       and   app.customer_trx_id = p_control.customer_trx_id
       and   nvl(app.confirmed_flag,'Y') = 'Y' --accounting exists in ar_distributions only if confirmed
       and   app.status = 'APP'
       and   exists (select 'x'
                     from  ar_distributions ard
                     where ard.source_table = 'RA'
                     and   ard.source_id    = app.receivable_application_id); --delete only necessary records

    l_rec_del_app del_app%ROWTYPE;

    l_cm_adr 				NUMBER;
    l_cm_acctd_adr 			NUMBER;
    l_cm_rate				NUMBER;
    l_inv_adr				NUMBER;
    l_inv_acctd_adr			NUMBER;
    l_inv_rate				NUMBER;

    l_new_inv_adr			NUMBER;
    l_new_inv_acctd_adr			NUMBER;
    l_new2_inv_acctd_adr		NUMBER;

    l_new_adj_amount			NUMBER;
    l_new_adj_acctd_amount		NUMBER;
    l_new_amount_applied		NUMBER;
    l_new_acctd_amt_applied_from	NUMBER;
    l_new_acctd_amt_applied_to		NUMBER;

    l_update_inv_adr			NUMBER;
    l_update_inv_acctd_adr		NUMBER;
    l_update_new_adj_amount		NUMBER;

    l_dummy				NUMBER;
    l_foreign_transaction		VARCHAR2(1) := NO;
    l_no_adjustments			BOOLEAN;

    l_doc_where_clause			VARCHAR2(1000);
    /* VAT changes */
    l_ae_doc_rec         ae_doc_rec_type;
    l_adjustment_id      ar_adjustments.adjustment_id%type;
    l_ccid		 ar_adjustments.code_combination_id%type;

BEGIN

    print_fcn_label( 'arp_maintain_ps.update_adjustments()+' );

    BEGIN

        --
	-- Determine if adjustments exist on child invoice
        --
        SELECT adj.adjustment_id
        INTO l_dummy
        FROM ar_adjustments adj
        WHERE adj.receivables_trx_id = -1
        and adj.customer_trx_id = p_control.previous_customer_trx_id
        and adj.subsequent_trx_id = p_control.customer_trx_id
        and rownum = 1;

	l_no_adjustments := FALSE;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    l_no_adjustments := TRUE;
        WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing select stmt #1',
		 	MSG_LEVEL_BASIC );
            RAISE;
    END;

    IF( l_no_adjustments ) THEN

	------------------------------------------------------------
        -- If there is no adjustment on the child invoice,
        -- call update_payment_schedule():
        -- Update the invoice payment schedule with new amounts,
        -- Update the CM application record with new amounts
        -----------------------------------------------------------
	update_payment_schedule(
		p_system_info,
		p_profile_info,
		p_control );
	RETURN;

    END IF;


    BEGIN

        SELECT
        /* reverse old cm app */
        ps_cm.amount_due_remaining - ra.amount_applied,
        ps_cm.acctd_amount_due_remaining - ra.acctd_amount_applied_from,
        ps_cm.exchange_rate,
        -( p_control.line_amount +
           p_control.tax_amount +
           p_control.freight_amount +
           p_control.charge_amount ),
        /* reverse old cm app */
        ps_inv.amount_due_remaining + ra.amount_applied,
        ps_inv.acctd_amount_due_remaining + ra.acctd_amount_applied_to,
        ps_inv.exchange_rate,
        (-ra.line_applied - p_control.line_amount)
        INTO
        l_cm_adr,
        l_cm_acctd_adr,
        l_cm_rate,
        l_new_amount_applied,
        l_inv_adr,
        l_inv_acctd_adr,
        l_inv_rate,
        l_new_adj_amount
        FROM
        ar_payment_schedules ps_cm,
        ar_payment_schedules ps_inv,
        ar_receivable_applications ra
        WHERE  p_system_info.base_currency <> ps_inv.invoice_currency_code
        and  ra.applied_payment_schedule_id = ps_inv.payment_schedule_id
        and  ps_inv.payment_schedule_id = p_control.payment_schedule_id
        and  ra.payment_schedule_id = ps_cm.payment_schedule_id
        and  ps_cm.customer_trx_id = p_control.customer_trx_id;

        l_foreign_transaction := YES;


    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    l_foreign_transaction := NO;
        WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing select stmt #2',
		 	MSG_LEVEL_BASIC );
            RAISE;

    END;

    IF( l_foreign_transaction = YES ) THEN

	------------------------------------------------------------------
	-- Compute accounted amounts for ps and applications
	------------------------------------------------------------------

        ------------------------------------------------------------------
        -- Get New Acctd Amt Applied To and New Acctd Amt Due Remaining
        ------------------------------------------------------------------
	arp_util.calc_acctd_amount(
		p_system_info.base_currency,
		NULL,			-- precision
		NULL,			-- mau
		l_inv_rate,
		'-',			-- type
		l_inv_adr,		-- master_from
		l_inv_acctd_adr,	-- acctd_master_from
		l_new_amount_applied,	-- detail
		l_new_inv_adr,		-- master_to
		l_new_inv_acctd_adr,	-- acctd_master_to
		l_new_acctd_amt_applied_to  	-- acctd_detail
	);

        ---------------------------------------------------------------
        -- Get New Acctd Amt Applied From
        ---------------------------------------------------------------
	arp_util.calc_acctd_amount(
		p_system_info.base_currency,
		NULL,			-- precision
		NULL,			-- mau
		l_cm_rate,
		'+',			-- type
		l_cm_adr,		-- master_from
		l_cm_acctd_adr,		-- acctd_master_from
		l_new_amount_applied,	-- detail
		l_dummy,		-- master_to
		l_dummy,		-- acctd_master_to
		l_new_acctd_amt_applied_from 	-- acctd_detail
	);

    END IF;

    BEGIN

        ------------------------------------------------------------
        -- If no commitment adj exists by this CM, insert one,
        -- Otherwise, update the existing record with the new amount
        ------------------------------------------------------------

        SELECT
        /* reverse adj effect */
        to_number(nvl(l_new_inv_adr, 0)) - adj.amount,
        to_number(nvl(l_new_inv_acctd_adr, 0)) - adj.acctd_amount,
        adj.amount + to_number(nvl(l_new_adj_amount, 0))
        INTO
        l_update_inv_adr,
        l_update_inv_acctd_adr,
        l_update_new_adj_amount
        FROM ar_adjustments adj
        WHERE adj.customer_trx_id = p_control.previous_customer_trx_id
        and adj.subsequent_trx_id = p_control.customer_trx_id
        and adj.receivables_trx_id = -1
        and adj.payment_schedule_id = p_control.payment_schedule_id;

	l_no_adjustments := FALSE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
	    l_no_adjustments := TRUE;
        WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing select stmt #3',
		 	MSG_LEVEL_BASIC );
            RAISE;

    END;


    IF( l_no_adjustments ) THEN

        ------------------------------------------------------------------
        -- Insert the adjustment
        ------------------------------------------------------------------

	IF( l_foreign_transaction = YES ) THEN

            ------------------------------------------------------------------
            -- Get acctd amt for the adj
            ------------------------------------------------------------------
	    arp_util.calc_acctd_amount(
		    p_system_info.base_currency,
		    NULL,			-- precision
		    NULL,			-- mau
		    l_inv_rate,
		    '+',			-- type
		    l_new_inv_adr,		-- master_from
		    l_new_inv_acctd_adr,	-- acctd_master_from
		    l_new_adj_amount,		-- detail
		    l_dummy,			-- master_to
		    l_new2_inv_acctd_adr,	-- acctd_master_to
		    l_new_adj_acctd_amount 	-- acctd_detail
	    );

	END IF;

        -- do the insert
	BEGIN

	    select ar_adjustments_s.nextval into l_adjustment_id
	    from dual;

	    INSERT INTO ar_adjustments
	    (
	    created_by,
	    creation_date,
	    last_updated_by,
	    last_update_date,
	    last_update_login,
	    set_of_books_id,
	    receivables_trx_id,
	    automatically_generated,
	    type,
	    adjustment_type,
	    status,
	    apply_date,
	    adjustment_id,
	    amount,
	    gl_date,
	    code_combination_id,
	    customer_trx_id,
	    payment_schedule_id,
	    subsequent_trx_id,
	    postable,
	    acctd_amount,
	    adjustment_number,
	    created_from,
	    posting_control_id
            ,org_id
	    )
	    SELECT
	    p_profile_info.user_id,
	    trunc(sysdate),
	    p_profile_info.user_id,
	    trunc(sysdate),
	    p_profile_info.conc_login_id,
	    adj2.set_of_books_id,
	    -1,
	    'Y',
	    'LINE',
	    'C',
	    'A',
	    adj2.apply_date,
            l_adjustment_id,
	    nvl(-ra.line_applied, 0) - p_control.line_amount,
	    adj2.gl_date,
	    adj2.code_combination_id,
	    p_control.previous_customer_trx_id,
	    p_control.payment_schedule_id,
	    p_control.customer_trx_id,
	    adj2.postable,
	    decode(l_foreign_transaction,
       	    'N', nvl(-ra.line_applied, 0) - p_control.line_amount,
       	    'Y', to_number(nvl(l_new_adj_acctd_amount, 0))),
	    to_char(ar_adjustment_number_s.nextval),
	    'ARAPSI',
	    -3
            ,arp_standard.sysparm.org_id /* SSA changes anuj */
	    FROM
	    ar_adjustments adj2,
	    ar_receivable_applications ra,
	    ra_customer_trx ct
	    WHERE adj2.receivables_trx_id= -1
	    and adj2.customer_trx_id = p_control.previous_customer_trx_id
	    and adj2.subsequent_trx_id = p_control.customer_trx_id
	    and ra.customer_trx_id = adj2.subsequent_trx_id
	    and ra.applied_payment_schedule_id = p_control.payment_schedule_id
	    and ct.customer_trx_id = ra.applied_customer_trx_id
	    and adj2.payment_schedule_id =
	    (
  	      /* find an adjustment against the invoice by the CM */
  	      SELECT max(payment_schedule_id)
  	      FROM ar_adjustments adj3
  	      WHERE adj3.receivables_trx_id=-1
  	      and   adj3.customer_trx_id = p_control.previous_customer_trx_id
  	      and   adj3.subsequent_trx_id = p_control.customer_trx_id
	    );

            debug( SQL%ROWCOUNT||' row(s) inserted', MSG_LEVEL_DEBUG );

           /*---------------------------------+
            | Calling central MRC library     |
            | for MRC Integration             |
            +---------------------------------*/

            ar_mrc_engine.maintain_mrc_data(
                        p_event_mode        => 'INSERT',
                        p_table_name        => 'AR_ADJUSTMENTS',
                        p_mode              => 'SINGLE',
                        p_key_value         => l_adjustment_id
                       );


            /* VAT changes: create acct entry */
            l_ae_doc_rec.document_type := 'ADJUSTMENT';
            l_ae_doc_rec.document_id   := l_adjustment_id;
            l_ae_doc_rec.accounting_entity_level := 'ONE';
            l_ae_doc_rec.source_table  := 'ADJ';
            l_ae_doc_rec.source_id     := l_adjustment_id;

          --Bug 1329091 - PS is updated before Accounting Engine Call

            l_ae_doc_rec.pay_sched_upd_yn := 'Y';

            arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

        EXCEPTION
            WHEN OTHERS THEN
                debug( 'EXCEPTION: Error executing insert stmt',
		 	MSG_LEVEL_BASIC );
                RAISE;

	END;

        ------------------------------------------------------------------
        -- Fill in document number in the ar_adjustments table
        ------------------------------------------------------------------

	l_doc_where_clause :=
'WHERE customer_trx_id = :bind1 '|| CRLF ||
'and subsequent_trx_id = :bind2 '|| CRLF ||
'and receivables_trx_id = -1 and payment_schedule_id = :bind3 ';

        ----------------------------------------------------------
        -- Update adjustments with document number
        ----------------------------------------------------------
	update_adj_document_number(
		p_system_info,
		p_profile_info,
		p_control.customer_trx_id,
                p_control.previous_customer_trx_id,
                p_control.customer_trx_id,
                p_control.payment_schedule_id,
		l_doc_where_clause );


    ELSE

        ----------------------------------------------------------------
        -- Update old adjustment record with new adjustment amounts
        ----------------------------------------------------------------

	IF( l_foreign_transaction = YES ) THEN

            ------------------------------------------------------------------
            -- Get acctd amt for the adj
            ------------------------------------------------------------------
	    arp_util.calc_acctd_amount(
		    p_system_info.base_currency,
		    NULL,			-- precision
		    NULL,			-- mau
		    l_inv_rate,
		    '+',			-- type
		    l_update_inv_adr,		-- master_from
		    l_update_inv_acctd_adr,	-- acctd_master_from
		    l_update_new_adj_amount,		-- detail
		    l_dummy,			-- master_to
		    l_new2_inv_acctd_adr,	-- acctd_master_to
		    l_new_adj_acctd_amount 	-- acctd_detail
	    );

	END IF;

	-- do the update
        DECLARE
             l_adj_key_value_list    gl_ca_utility_pkg.r_key_value_arr;
	BEGIN

	    UPDATE ar_adjustments adj
	    SET
	    (
  	    amount,
  	    acctd_amount,
  	    line_adjusted,
  	    last_updated_by,
  	    last_update_date,
  	    last_update_login
	    ) =
	    (
  	    SELECT
  	    nvl(adj.amount, 0) - ra.line_applied - p_control.line_amount,
  	    decode(l_foreign_transaction,
         	    'N', nvl(adj.amount, 0) - ra.line_applied -
				p_control.line_amount,
         	    'Y', to_number(nvl(l_new_adj_acctd_amount, 0))),
  	    nvl(adj.amount, 0) - ra.line_applied - p_control.line_amount,
  	    p_profile_info.user_id,
  	    trunc(sysdate),
  	    p_profile_info.conc_login_id
  	    FROM
  	    ar_receivable_applications ra,
  	    ra_customer_trx ct
  	    WHERE ra.customer_trx_id = p_control.customer_trx_id
  	    and ra.status||'' = 'APP'
  	    and ra.applied_payment_schedule_id = p_control.payment_schedule_id
  	    and ct.customer_trx_id = ra.applied_customer_trx_id
	    )
	    WHERE adj.customer_trx_id = p_control.previous_customer_trx_id
	    and    adj.subsequent_trx_id = p_control.customer_trx_id
	    and    adj.receivables_trx_id = -1
	    and    adj.payment_schedule_id = p_control.payment_schedule_id
            RETURNING adj.adjustment_id
            BULK COLLECT INTO l_adj_key_value_list;

            debug( SQL%ROWCOUNT||' row(s) updated', MSG_LEVEL_DEBUG );

           /*---------------------------------+
            | Calling central MRC library     |
            | for MRC Integration             |
            +---------------------------------*/

            ar_mrc_engine.maintain_mrc_data(
                    p_event_mode        => 'UPDATE',
                    p_table_name        => 'AR_ADJUSTMENTS',
                    p_mode              => 'BATCH',
                    p_key_value_list    => l_adj_key_value_list);

        EXCEPTION
            WHEN OTHERS THEN
                debug( 'EXCEPTION: Error executing update stmt',
		 	MSG_LEVEL_BASIC );
                RAISE;

	END;

	/* VAT changes: update accounting entry */
        SELECT adjustment_id
	INTO l_adjustment_id
        FROM ar_adjustments adj
        WHERE adj.customer_trx_id = p_control.previous_customer_trx_id
        and    adj.subsequent_trx_id = p_control.customer_trx_id
        and    adj.receivables_trx_id = -1
        and    adj.payment_schedule_id = p_control.payment_schedule_id;

	l_ae_doc_rec.document_type := 'ADJUSTMENT';
     	l_ae_doc_rec.document_id   := l_adjustment_id;
    	l_ae_doc_rec.accounting_entity_level := 'ONE';
        l_ae_doc_rec.source_table  := 'ADJ';
     	l_ae_doc_rec.source_id     := l_adjustment_id;
     	arp_acct_main.Delete_Acct_Entry(l_ae_doc_rec);
     	l_ae_doc_rec.source_id_old := l_ccid;
     	l_ae_doc_rec.other_flag    := 'OVERRIDE';

     	arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

    END IF;


    ----------------------------------------------------------------------
    -- We know that there's commitment adj done on this
    -- invoice, this means, the line remaining amt is not to be changed.
    -- Reverse the origial CM application amounts and use the new
    -- amounts passed in for the invoice's payment schedule.
    ----------------------------------------------------------------------
    DECLARE
       l_ar_ps_key_value_list gl_ca_utility_pkg.r_key_value_arr;

    BEGIN

        UPDATE ar_payment_schedules ps
        SET (
        ps.status,
        ps.gl_date_closed,
        ps.actual_date_closed,
        ps.amount_credited,
        ps.amount_adjusted,
        ps.amount_due_remaining,
        ps.acctd_amount_due_remaining,
        ps.tax_remaining,
        ps.freight_remaining,
        ps.receivables_charges_remaining,
        ps.last_updated_by,
        ps.last_update_date,
        ps.last_update_login) = (
        SELECT
        decode(ps2.amount_due_remaining + nvl(ra.tax_applied, 0) +
                 nvl(ra.freight_applied, 0) +
                 nvl(ra.receivables_charges_applied, 0) +
                 p_control.tax_amount +
	         p_control.freight_amount +
	         p_control.charge_amount,
               0, 'CL', 'OP'),
        decode(ps2.amount_due_remaining + nvl(ra.tax_applied, 0) +
                 nvl(ra.freight_applied,0) +
                 nvl(ra.receivables_charges_applied, 0) +
                 p_control.tax_amount +
	         p_control.freight_amount +
	         p_control.charge_amount,
               0, greatest(max(ra2.gl_date),
	                   max(decode(adj2.status,
		                      'A', adj2.gl_date,
			              ps2.gl_date))),
               ''),
        decode(ps2.amount_due_remaining + nvl(ra.tax_applied, 0) +
                 nvl(ra.freight_applied, 0) +
                 nvl(ra.receivables_charges_applied,0) +
                 p_control.tax_amount +
	         p_control.freight_amount +
	         p_control.charge_amount,
               0, greatest(max(ra2.apply_date),
		           max(decode(adj2.status,
		                      'A', adj2.apply_date,
			              ps2.trx_date))),
               ''),
        nvl(ps2.amount_credited, 0) + ra.amount_applied +
          (p_control.line_amount +
           p_control.tax_amount +
           p_control.freight_amount +
           p_control.charge_amount),
        nvl(ps2.amount_adjusted, 0) - ra.line_applied - p_control.line_amount,
        ps2.amount_due_remaining + nvl(ra.tax_applied, 0) +
          nvl(ra.freight_applied, 0) +
          nvl(ra.receivables_charges_applied, 0) +
          p_control.tax_amount +
          p_control.freight_amount +
          p_control.charge_amount,
        decode(l_foreign_transaction,
               'N',
               ps2.amount_due_remaining + nvl(ra.tax_applied, 0) +
                 nvl(ra.freight_applied, 0) +
                 nvl(ra.receivables_charges_applied, 0) +
                 p_control.tax_amount +
                 p_control.freight_amount +
                 p_control.charge_amount,
               'Y', to_number(nvl(l_new2_inv_acctd_adr, 0))),
        nvl(ps2.tax_remaining, 0) + nvl(ra.tax_applied, 0) +
	  p_control.tax_amount,
        nvl(ps2.freight_remaining, 0) + nvl(ra.freight_applied, 0) +
          p_control.freight_amount,
        nvl(ps2.receivables_charges_remaining, 0) +
          nvl(ra.receivables_charges_applied,0) + p_control.charge_amount,
        p_profile_info.user_id,
        trunc(sysdate),
        p_profile_info.conc_login_id
        FROM
        ar_receivable_applications ra,
        ar_payment_schedules ps2,
        ar_receivable_applications ra2,
        ar_adjustments adj2
        WHERE ra.customer_trx_id = p_control.customer_trx_id
        and ra.status||'' = 'APP'
        and ra.applied_payment_schedule_id = ps2.payment_schedule_id
        and ps.payment_schedule_id = ps2.payment_schedule_id
        and ps2.payment_schedule_id = adj2.payment_schedule_id(+)
        and ps2.payment_schedule_id = ra2.applied_payment_schedule_id
        and nvl(ra2.confirmed_flag,'Y')='Y'
        GROUP BY
        ps2.payment_schedule_id,
        ra2.applied_payment_schedule_id,
        adj2.payment_schedule_id,
        ps2.amount_due_remaining,
        ra.amount_applied,
        ps2.gl_date,
        ps2.trx_date,
        ps2.amount_credited,
        ps2.amount_adjusted,
        ps2.acctd_amount_due_remaining,
        ra.acctd_amount_applied_to,
        ps2.amount_line_items_remaining,
        ra.line_applied,
        ps2.tax_remaining,
        ra.tax_applied,
        ps2.freight_remaining,
        ra.freight_applied,
        ps2.receivables_charges_remaining,
        ra.receivables_charges_applied,
        ps2.exchange_rate)
        WHERE ps.payment_schedule_id = p_control.payment_schedule_id
        RETURNING ps.payment_schedule_id
        BULK COLLECT INTO l_ar_ps_key_value_list;

        debug( SQL%ROWCOUNT||' row(s) updated', MSG_LEVEL_DEBUG );

       /*---------------------------------+
        | Calling central MRC library     |
        | for MRC Integration             |
        +---------------------------------*/

       ar_mrc_engine.maintain_mrc_data(
                p_event_mode        => 'UPDATE',
                p_table_name        => 'AR_PAYMENT_SCHEDULES',
                p_mode              => 'BATCH',
                p_key_value_list    => l_ar_ps_key_value_list);

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing update stmt',
	 	    MSG_LEVEL_BASIC );
            RAISE;

    END;


    ----------------------------------------------------------
    -- Update CM app with new line, frt, tax amount
    ----------------------------------------------------------
    DECLARE
      CURSOR get_app_id IS
       select  app.receivable_application_id,
               app.amount_applied
          from  ar_receivable_applications app
         where  app.applied_payment_schedule_id = p_control.payment_schedule_id
           and  app.customer_trx_id = p_control.customer_trx_id
           and  app.status = 'APP';

    BEGIN

        FOR l_rec_del_app in del_app LOOP
            --
            --Release 11.5 VAT changes, delete accounting for Applications
            --
             l_ae_doc_rec.document_type           := 'CREDIT_MEMO';
             l_ae_doc_rec.document_id             := l_rec_del_app.trx_id;
             l_ae_doc_rec.accounting_entity_level := 'ONE';
             l_ae_doc_rec.source_table            := 'RA';
             l_ae_doc_rec.source_id               := l_rec_del_app.app_id;
             l_ae_doc_rec.source_id_old           := '';
             l_ae_doc_rec.other_flag              := '';

           --Bug 1329091 - PS is updated before Accounting Engine Call

             l_ae_doc_rec.pay_sched_upd_yn := 'Y';

             arp_acct_main.Delete_Acct_Entry(l_ae_doc_rec);

         END LOOP;

        UPDATE ar_receivable_applications ra
        SET
        acctd_amount_applied_from =
          decode(l_foreign_transaction,
                 'N',
                 -(p_control.line_amount +
	           p_control.tax_amount +
	           p_control.freight_amount +
	           p_control.charge_amount),
                 'Y', to_number(nvl(l_new_acctd_amt_applied_from, 0))),
        acctd_amount_applied_to =
          decode(l_foreign_transaction,
                 'N',
                 -(p_control.line_amount +
                   p_control.tax_amount +
	           p_control.freight_amount +
	           p_control.charge_amount),
                 'Y', to_number(nvl(l_new_acctd_amt_applied_to, 0))),
        amount_applied =
          -(p_control.line_amount +
            p_control.tax_amount +
            p_control.freight_amount +
            p_control.charge_amount),
        line_applied = -to_number(p_control.line_amount),
        tax_applied = -to_number(p_control.tax_amount),
        freight_applied = -to_number(p_control.freight_amount),
        receivables_charges_applied = -to_number(p_control.charge_amount),
        last_updated_by = p_profile_info.user_id,
        last_update_date = trunc(sysdate),
        last_update_login = p_profile_info.conc_login_id
        WHERE ra.applied_payment_schedule_id  = p_control.payment_schedule_id
        and ra.status||'' = 'APP'
        and ra.customer_trx_id = p_control.customer_trx_id;

        debug( SQL%ROWCOUNT||' row(s) updated', MSG_LEVEL_DEBUG );

        FOR l_app_id in get_app_id
           LOOP
              -- Call mrc engine to process update:
              ar_mrc_engine3.update_cm_application(
                     l_app_id.receivable_application_id,
                     p_control.payment_schedule_id,  /* p_app_ps_id */
                     p_control.customer_trx_id,     /* p_ct_id */
                     l_app_id.amount_applied);
        END LOOP;

        FOR l_rec_del_app in del_app LOOP
            --
            --Release 11.5 VAT changes, recreate accounting for Applications
            --
             l_ae_doc_rec.document_type           := 'CREDIT_MEMO';
             l_ae_doc_rec.document_id             := l_rec_del_app.trx_id;
             l_ae_doc_rec.accounting_entity_level := 'ONE';
             l_ae_doc_rec.source_table            := 'RA';
             l_ae_doc_rec.source_id               := l_rec_del_app.app_id;
             l_ae_doc_rec.source_id_old           := '';
             l_ae_doc_rec.other_flag              := '';
           --Bug 1329091 - PS is updated before Accounting Engine Call

             l_ae_doc_rec.pay_sched_upd_yn := 'Y';

             arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);
    	    /*bug-6976549*/
    	    arp_balance_check.CHECK_APPLN_BALANCE(l_rec_del_app.app_id,
					  NULL,
					  'N');

         END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing update stmt',
	 	    MSG_LEVEL_BASIC );
            RAISE;

    END;


    print_fcn_label( 'arp_maintain_ps.update_adjustments()-' );

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps.update_adjustments()',
	       MSG_LEVEL_BASIC );
        RAISE;

END update_adjustments;


----------------------------------------------------------------------------
PROCEDURE dump_control_rec( p_control	control_rec_type ) IS
BEGIN

    debug( 'control.process_mode='||p_control.process_mode,
		MSG_LEVEL_DEBUG );
    debug( 'control.customer_trx_id='||p_control.customer_trx_id,
		MSG_LEVEL_DEBUG );
    debug( 'control.payment_schedule_id='||p_control.payment_schedule_id,
		MSG_LEVEL_DEBUG );
    debug( 'control.line_amount='||p_control.line_amount,
		MSG_LEVEL_DEBUG );
    debug( 'control.tax_amount='||p_control.tax_amount,
		MSG_LEVEL_DEBUG );
    debug( 'control.freight_amount='||p_control.freight_amount,
		MSG_LEVEL_DEBUG );
    debug( 'control.charge_amount='||p_control.charge_amount,
		MSG_LEVEL_DEBUG );
    debug( 'control.trx_type='||p_control.trx_type, MSG_LEVEL_DEBUG );
    debug( 'control.previous_customer_trx_id='||
		p_control.previous_customer_trx_id, MSG_LEVEL_DEBUG );
    debug( 'control.initial_customer_trx_id='||
		p_control.initial_customer_trx_id, MSG_LEVEL_DEBUG );
    debug( 'control.initial_trx_type='||p_control.initial_trx_type,
		MSG_LEVEL_DEBUG );

    IF( p_control.is_open_receivable ) THEN
        debug( 'control.is_open_receivable=TRUE', MSG_LEVEL_DEBUG );
    ELSE
        debug( 'control.is_open_receivable=FALSE', MSG_LEVEL_DEBUG );
    END IF;

    IF( p_control.is_postable ) THEN
        debug( 'control.is_postable=TRUE', MSG_LEVEL_DEBUG );
    ELSE
        debug( 'control.is_postable=FALSE', MSG_LEVEL_DEBUG );
    END IF;

    IF( p_control.is_child ) THEN
        debug( 'control.is_child=TRUE', MSG_LEVEL_DEBUG );
    ELSE
        debug( 'control.is_child=FALSE', MSG_LEVEL_DEBUG );
    END IF;

    IF( p_control.is_onacct_cm ) THEN
        debug( 'control.is_onacct_cm=TRUE', MSG_LEVEL_DEBUG );
    ELSE
        debug( 'control.is_onacct_cm=FALSE', MSG_LEVEL_DEBUG );
    END IF;


EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps.dump_control_rec()',
	       MSG_LEVEL_BASIC );
        RAISE;

END dump_control_rec;

----------------------------------------------------------------------------
FUNCTION get_applied_commitment_amount(
	p_control IN control_rec_type )

    RETURN NUMBER IS

    l_temp NUMBER;

BEGIN

    print_fcn_label( 'arp_maintain_ps.get_applied_commitment_amount()+' );

    BEGIN

        SELECT
        nvl( sum( nvl(-adj.amount, 0) ), 0 )
        INTO l_temp
        FROM ar_adjustments adj
        WHERE adj.customer_trx_id =
            decode( p_control.initial_trx_type,
                    'DEP', p_control.customer_trx_id,
                    'GUAR', p_control.initial_customer_trx_id )
        and (
          ( p_control.initial_trx_type = 'DEP'
            and
            adj.subsequent_trx_id is null )
          or
          ( p_control.initial_trx_type = 'GUAR'
            and
            adj.subsequent_trx_id = p_control.customer_trx_id ) )
        and   adj.receivables_trx_id = -1;

    EXCEPTION
        WHEN OTHERS THEN
            debug( 'EXCEPTION: Error executing select stmt',
	 	    MSG_LEVEL_BASIC );
            RAISE;

    END;


    print_fcn_label( 'arp_maintain_ps.get_applied_commitment_amount()-' );

    RETURN l_temp;

EXCEPTION
    WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps.get_applied_commitment_amount()',
	       MSG_LEVEL_BASIC );
        RAISE;

END get_applied_commitment_amount;


----------------------------------------------------------------------------
FUNCTION ps_records_exist( p_customer_trx_id IN BINARY_INTEGER )

    RETURN BOOLEAN IS

    l_temp NUMBER;

BEGIN

    print_fcn_label( 'arp_maintain_ps.ps_records_exist()+' );

    SELECT 1
    INTO l_temp
    FROM ar_payment_schedules
    WHERE customer_trx_id = p_customer_trx_id;

    print_fcn_label( 'arp_maintain_ps.ps_records_exist()-' );

  RETURN( TRUE );

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      print_fcn_label( 'arp_maintain_ps.ps_records_exist()-' );
      RETURN( FALSE );
  WHEN TOO_MANY_ROWS THEN
      print_fcn_label( 'arp_maintain_ps.ps_records_exist()-' );
      RETURN( TRUE );
  WHEN OTHERS THEN
      debug( 'EXCEPTION: arp_maintain_ps.ps_records_exist()',
	       MSG_LEVEL_BASIC );
      RAISE;

END ps_records_exist;


----------------------------------------------------------------------------
--
-- PROCEDURE NAME:  maintain_payment_schedules
--
-- DECSRIPTION:
--   Server-side entry point for the Maintain Payment Schedules.
--
-- ARGUMENTS:
--      IN:
--	  mode			(I)nsert, (D)elete or (U)pdate
--	  customer_trx_id	Transaction's payment sched to be modified
--	  payment_schedule_id	Specific id to be changed.
--				For U mode only and regular CM only.
--				Must pass value for amount parameters.
--	  line_amount		New CM line amount
--	  tax_amount		New CM tax amount
--	  freight_amount	New CM freight amount
--	  charge_amount		New CM charges amount
--	  reversed_cash_receipt_id	For DM reversals, I mode only
--
--      IN/OUT:
--	  applied_commitment_amount	Amount of invoice applied to commitment
--
--      OUT:
--
-- NOTES:
--   Exception raised if Oracle error.
--   App_exception is raised for all other fatal errors and a message
--   is put on the AOL stack.  The public variable g_error_buffer is
--   populated for both types of errors.
--
--
-- HISTORY:
--
----------------------------------------------------------------------------
PROCEDURE maintain_payment_schedules(
	p_mode				IN VARCHAR2,
	p_customer_trx_id		IN NUMBER,
	p_payment_schedule_id		IN NUMBER,
	p_line_amount			IN NUMBER,
	p_tax_amount			IN NUMBER,
	p_freight_amount		IN NUMBER,
	p_charge_amount			IN NUMBER,
	p_applied_commitment_amount	IN OUT NOCOPY NUMBER,
	p_reversed_cash_receipt_id	IN NUMBER DEFAULT NULL
) IS

    l_doc_where_clause 		VARCHAR2(1000);
    l_control_rec		control_rec_type;
    /* VAT changes */
    l_ae_doc_rec         ae_doc_rec_type;
    l_adjustment_id      ar_adjustments.adjustment_id%type;

BEGIN

    print_fcn_label( 'arp_maintain_ps.maintain_payment_schedules()+' );

    -- Validate parameters
    IF( p_mode IS NULL OR
        p_mode NOT IN (I, U, D) OR
        p_customer_trx_id IS NULL OR
        (p_payment_schedule_id IS NOT NULL AND p_mode <> U) )  THEN

    	g_error_buffer := MSG_INVALID_PARAMETERS;
	debug( 'EXCEPTION: '||g_error_buffer, MSG_LEVEL_BASIC );
	RAISE invalid_parameters;

    END IF;

    --------------------------------------------------------------------
    -- Assign values to control_rec
    --------------------------------------------------------------------
    l_control_rec.process_mode := p_mode;
    l_control_rec.customer_trx_id := p_customer_trx_id;
    l_control_rec.payment_schedule_id := p_payment_schedule_id;
    l_control_rec.line_amount := nvl( p_line_amount, 0);
    l_control_rec.tax_amount := nvl( p_tax_amount, 0);
    l_control_rec.freight_amount := nvl( p_freight_amount, 0);
    l_control_rec.charge_amount := nvl( p_charge_amount, 0);
    l_control_rec.reversed_cash_receipt_id := p_reversed_cash_receipt_id;


    SAVEPOINT ar_payment_schedule;

    --------------------------------------------------------------------
    -- Get other info from tables for control_rec
    --------------------------------------------------------------------
    do_setup( l_control_rec );

    --------------------------------------------------------------------
    -- Print out NOCOPY control_rec
    --------------------------------------------------------------------
    dump_control_rec( l_control_rec );

    --------------------------------------------------------------------
    -- Do nothing if open_rec = N
    -- or I mode and ps records exist
    --------------------------------------------------------------------
    -- Case where the transaction CM does not have a open Receivable
    -- and mode is <> Deletion
    -- no need to process

    IF( NOT l_control_rec.is_open_receivable
        AND l_control_rec.process_mode <> 'D' ) THEN

       RETURN;

    END IF;

    IF( l_control_rec.process_mode = I AND
        ps_records_exist( l_control_rec.customer_trx_id ) ) THEN

       RETURN;

    END IF;

    --------------------------------------------------------------------
    -- Process all transactions except for regular CMs
    --------------------------------------------------------------------
    IF( l_control_rec.previous_customer_trx_id IS NULL ) THEN

        debug( '  Process non CM transactions', MSG_LEVEL_DEBUG );

        ----------------------------------------------------------------
	-- Update, Delete case
        ----------------------------------------------------------------
        IF( l_control_rec.process_mode in ( U, D ) ) THEN

            debug( '  Update, Delete mode', MSG_LEVEL_DEBUG );

	    IF( l_control_rec.initial_trx_type = DEP ) THEN

                debug( '  DEP case', MSG_LEVEL_DEBUG );

	        /* VAT changes: delete accounting entry for adjustment */
      		SELECT adj.adjustment_id into l_adjustment_id
      		FROM ar_adjustments adj
      		WHERE adj.customer_trx_id = l_control_rec.customer_trx_id
            	  and adj.receivables_trx_id = -1;

	        l_ae_doc_rec.document_type := 'ADJUSTMENT';
    	 	l_ae_doc_rec.document_id   := l_adjustment_id;
    		l_ae_doc_rec.accounting_entity_level := 'ONE';
    		l_ae_doc_rec.source_table  := 'ADJ';
    		l_ae_doc_rec.source_id     := l_adjustment_id;
    		arp_acct_main.Delete_Acct_Entry(l_ae_doc_rec);

	        -- arabdep: delete invoice adjustments
	        delete_adjustments( l_control_rec.customer_trx_id, NULL );

            ELSIF( l_control_rec.initial_trx_type = GUAR ) THEN

                debug( '  GUAR case', MSG_LEVEL_DEBUG );

	        -- arabaj: delete guar adj, update guar ps created by child
		reverse_adjustments(
			system_info,
			profile_info,
			l_control_rec.initial_customer_trx_id,
			l_control_rec.customer_trx_id );

	    END IF;

	    -- aradps: delete old ps
	    delete_payment_schedule( l_control_rec.customer_trx_id );

        END IF;

        ----------------------------------------------------------------
	-- Insert, Update case
        ----------------------------------------------------------------
        IF( p_mode in ( I, U ) ) THEN

            debug( '  Insert, Update mode', MSG_LEVEL_DEBUG );

            --------------------------------------------------------------
            -- araips: call raaips
            --------------------------------------------------------------
	    arp_maintain_ps2.insert_inv_ps_private(
			system_info,
			profile_info,
			l_control_rec.customer_trx_id,
			l_control_rec.reversed_cash_receipt_id );


	    IF( l_control_rec.is_child ) THEN

                ----------------------------------------------------------
                -- araips: call raaups to insert adjustments for
		-- commitment invoices
                ----------------------------------------------------------
	        arp_maintain_ps2.insert_child_adj_private(
			system_info,
			profile_info,
			l_control_rec.customer_trx_id );

                ----------------------------------------------------------
                -- arapca: get invoice amount that was applied to commitment
                ----------------------------------------------------------
		p_applied_commitment_amount :=
			get_applied_commitment_amount( l_control_rec );

                ----------------------------------------------------------
                -- Update adjustments with document number
                ----------------------------------------------------------
                ----------------------------------------------------------
                -- Construct where clause
                ----------------------------------------------------------
	        IF( l_control_rec.initial_trx_type = DEP ) THEN

		    l_doc_where_clause :=
'WHERE customer_trx_id = :bind1 '|| CRLF ||
'and receivables_trx_id = -1';

                ----------------------------------------------------------
                -- Update adjustments with document number
                ----------------------------------------------------------
		update_adj_document_number(
			system_info,
			profile_info,
			l_control_rec.customer_trx_id,
                        l_control_rec.customer_trx_id,
                        null,
                        null,
			l_doc_where_clause );



		ELSE	-- GUAR

		    l_doc_where_clause :=
'WHERE customer_trx_id = :bind1 '|| CRLF ||
'and subsequent_trx_id = :bind2 '|| CRLF ||
'and receivables_trx_id = -1';



                ----------------------------------------------------------
                -- Update adjustments with document number
                ----------------------------------------------------------
		update_adj_document_number(
			system_info,
			profile_info,
			l_control_rec.customer_trx_id,
                        l_control_rec.initial_customer_trx_id,
                        l_control_rec.customer_trx_id,
                        null,
			l_doc_where_clause );

		END IF;

	    END IF;
        END IF;

    --------------------------------------------------------------------
    -- Process regular CMs where payment_schedule_id is NOT specified
    --------------------------------------------------------------------
    -- Process regular CM
    --
    ELSIF( l_control_rec.previous_customer_trx_id IS NOT NULL AND
	   l_control_rec.payment_schedule_id IS NULL ) THEN

        debug( '  Process regular CMs (payment_schedule_id = NULL)',
		MSG_LEVEL_DEBUG );

	--
	-- Update, Delete case
	--

        IF( l_control_rec.process_mode in ( U, D ) ) THEN

            debug( '  Update, Delete mode', MSG_LEVEL_DEBUG );

	   /* Bug 2808262 Check if the CM being incompleted, is actually
	   having any adjustments records or not. If not, there is no
	   need for the updation of payment schedule, or deletion of
	   adjustment record and its corresponding distributions.
	   */

	   IF ( l_control_rec.initial_trx_type = DEP
                AND
        /*salladi 3118714*/
      l_control_rec.is_child=TRUE ) THEN

                debug( '  DEP case', MSG_LEVEL_DEBUG );

	        -- arabaj: delete invoice adj (created by cm), update inv ps
		reverse_adjustments(
			system_info,
			profile_info,
			l_control_rec.previous_customer_trx_id,
			l_control_rec.customer_trx_id );


            ELSIF ( l_control_rec.initial_trx_type = GUAR
                    AND
              l_control_rec.is_child ) THEN

                debug( '  GUAR case', MSG_LEVEL_DEBUG );

	        -- arabaj: delete guar adj (created by cm), update guar ps
		reverse_adjustments(
			system_info,
			profile_info,
			l_control_rec.initial_customer_trx_id,
			l_control_rec.customer_trx_id );

	    END IF;

	    -- arabcm: update inv ps (reverse cm effect)
	    arp_standard.debug('   reverse_cm_effect+');
	    reverse_cm_effect(
		system_info,
		profile_info,
		l_control_rec.customer_trx_id );
	     arp_standard.debug('   reverse_cm_effect-');

	    -- aradra: delete cm app recs
	    arp_standard.debug('   delete_applications+');
	    delete_applications( l_control_rec.customer_trx_id );
	    arp_standard.debug('   delete_applications-');
	    -- aradps: delete cm ps
	    arp_standard.debug('   delete_payment_schedule+');
	    delete_payment_schedule( l_control_rec.customer_trx_id );
	    arp_standard.debug('   delete_payment_schedule-');
        END IF;

        IF( l_control_rec.process_mode in ( I, U ) ) THEN

            debug( '  Insert, Update mode', MSG_LEVEL_DEBUG );

	    IF( l_control_rec.is_child ) THEN

                ----------------------------------------------------------
		-- araiad: create adj, update ps
                ----------------------------------------------------------
	        arp_standard.debug('   arp_maintain_ps2.insert_cm_child_adj_private+');
		arp_maintain_ps2.insert_cm_child_adj_private(
			system_info,
			profile_info,
			l_control_rec.customer_trx_id );
		arp_standard.debug('   arp_maintain_ps2.insert_cm_child_adj_private-');


                ----------------------------------------------------------
                -- Update adjustments with document number
                ----------------------------------------------------------
                ----------------------------------------------------------
                -- Construct where clause
                ----------------------------------------------------------
	        IF( l_control_rec.initial_trx_type = DEP ) THEN

		    l_doc_where_clause :=
'WHERE customer_trx_id = :bind1 '|| CRLF ||
'and subsequent_trx_id = :bind2 '|| CRLF ||
'and receivables_trx_id = -1';

                ----------------------------------------------------------
                -- Update adjustments with document number
                ----------------------------------------------------------

		update_adj_document_number(
			system_info,
			profile_info,
			l_control_rec.customer_trx_id,
                        l_control_rec.previous_customer_trx_id,
                        l_control_rec.customer_trx_id,
                        null,
			l_doc_where_clause );

		ELSE	-- GUAR

		     l_doc_where_clause :=
'WHERE customer_trx_id = :bind1 '|| CRLF ||
'and subsequent_trx_id = :bind2 '|| CRLF ||
'and receivables_trx_id = -1';



                ----------------------------------------------------------
                -- Update adjustments with document number
                ----------------------------------------------------------
		arp_standard.debug('   update_adj_document_number+');
		update_adj_document_number(
			system_info,
			profile_info,
			l_control_rec.customer_trx_id,
                        l_control_rec.initial_customer_trx_id,
                        l_control_rec.customer_trx_id,
                        null,
			l_doc_where_clause );
		arp_standard.debug('   update_adj_document_number-');
		END IF;




	    END IF;

            -- araira: create cm ps, apps
	    arp_standard.debug('   arp_maintain_ps2.insert_cm_ps_private+');
	    arp_maintain_ps2.insert_cm_ps_private(
			system_info,
			profile_info,
			l_control_rec.customer_trx_id );
	    arp_standard.debug('   arp_maintain_ps2.insert_cm_ps_private-');


        END IF;


    --------------------------------------------------------------------
    -- Process regular CMs where payment_schedule_id is specified
    --------------------------------------------------------------------
    ELSIF( l_control_rec.previous_customer_trx_id IS NOT NULL AND
	   l_control_rec.payment_schedule_id IS NOT NULL ) THEN

        debug( '  Process regular CMs (payment_schedule_id <> NULL)',
		MSG_LEVEL_DEBUG );

        IF( l_control_rec.process_mode <> U ) THEN

            -- >> ERROR: bad mode for this case

		debug( '  Bad mode', MSG_LEVEL_DEBUG );
		null;
	END IF;

	IF( l_control_rec.initial_trx_type = DEP ) THEN

            debug( '  DEP case', MSG_LEVEL_DEBUG );

	    -- araudps: insert dep adj, if not exists, else update adj
	    update_adjustments( system_info, profile_info, l_control_rec );

	ELSE
            debug( '  non-DEP case', MSG_LEVEL_DEBUG );

	    -- araups: correct round error, update inv ps, update cm app
	    arp_standard.debug('   update_payment_schedule+');
	    update_payment_schedule(
		system_info,
		profile_info,
		l_control_rec );
	     arp_standard.debug('   update_payment_schedule-');

	END IF;

    END IF;


    print_fcn_label( 'arp_maintain_ps.maintain_payment_schedules()-' );

EXCEPTION
  WHEN OTHERS THEN
        debug( 'EXCEPTION: arp_maintain_ps.maintain_payment_schedules()',
	           MSG_LEVEL_BASIC );

  	close_cursors;
	ROLLBACK TO ar_payment_schedule;

	IF( sqlcode = 1 ) THEN
	    --
	    -- User-defined exception
	    --
	    FND_MESSAGE.set_name( 'AR', 'GENERIC_MESSAGE' );
	    FND_MESSAGE.set_token( 'GENERIC_TEXT', g_error_buffer );
	    APP_EXCEPTION.raise_exception;

	ELSE
	    --
	    -- Oracle error
	    --
	    g_error_buffer := SQLERRM;

            RAISE;

	END IF;

        RAISE;

END maintain_payment_schedules;

---------------------------------------------------------------------------
-- Test Functions
---------------------------------------------------------------------------
PROCEDURE test_build_doc_combo_sql
IS

BEGIN

    enable_debug( 1000000 );

    build_doc_combo_sql(
		system_info,
		profile_info,
		doc_combo_select_c );


END;


---------------------------------------------------------------------------
PROCEDURE test_build_doc_ins_audit_sql( p_where_clause VARCHAR2 )
IS

BEGIN

    enable_debug( 1000000 );

    build_doc_insert_audit_sql(
		system_info,
		profile_info,
		p_where_clause,
		doc_insert_audit_c );

END;

---------------------------------------------------------------------------
PROCEDURE test_build_doc_update_adj_sql( p_where_clause VARCHAR2 )
IS

BEGIN

    enable_debug( 1000000 );

    build_doc_update_adj_sql(
		system_info,
		profile_info,
		'my_seq',	-- seq name
		1,		-- seq id
		p_where_clause,
		doc_update_adj_c );


END;

---------------------------------------------------------------------------
PROCEDURE test_update_adj_doc_number(
		p_customer_trx_id 	BINARY_INTEGER,
		p_update_where_clause	VARCHAR2 ) 	IS

BEGIN

    enable_debug( 1000000 );


    update_adj_document_number(
		system_info,
        	profile_info,
		p_customer_trx_id,
                null,
                null,
                null,
		p_update_where_clause );




END;



---------------------------------------------------------------------------
--
-- Constructor code
--
PROCEDURE init IS
BEGIN

    print_fcn_label( 'arp_maintain_ps.constructor()+' );

    get_error_message_text;

    print_fcn_label( 'arp_maintain_ps.constructor()-' );


EXCEPTION
    WHEN OTHERS THEN
        debug('EXCEPTION: arp_maintain_ps.constructor()');
        debug(SQLERRM);
        RAISE;
END init;

BEGIN
   init;
END arp_maintain_ps;

/
