--------------------------------------------------------
--  DDL for Package Body ARP_DATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_DATES" AS
/* $Header: ARTUDATB.pls 120.8.12010000.10 2014/09/26 07:01:36 ashlkuma ship $ */


   pg_ai_pds_exist_cursor		integer;
   pg_ai_overlapping_pds_cursor		integer;
   pg_form_pds_exist_cursor		integer;
   pg_form_overlapping_pds_cursor	integer;

   pg_set_of_books_id			binary_integer;
   pg_application_id			binary_integer;

   IN_ADVANCE CONSTANT NUMBER := -2;
   IN_ARREARS CONSTANT NUMBER := -3;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    prepare_val_gl_pds_sql_stmt					     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Constructs and parses the SQL statements that perform the GL date rule |
 |    validation.							     |
 |                                                                           |
 |    The cursor IDs are assigned to package level variables so that the     |
 |    parses can be reused.						     |
 |                                                                           |
 |    If the SQL statements have already been parsed, the procedure exits    |
 |    without doing anything.						     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    arp_util.print_fcn_label						     |
 |    dbms_sql.parse							     |
 |    dbms_sql.open_cursor						     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_ai_flag  					     |
 |              OUT:                                                         |
 |		      None						     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     26-JUL-95  Charlie Tomberg     Created                                |
 |     19-Dec-05  GyanaJyothi         Included the Partial Period Rule types |
 |                                                                           |
 +===========================================================================*/

PROCEDURE prepare_val_gl_pds_sql_stmt(
                                      p_ai_flag 		    IN boolean
                                       ) IS

   l_all_pds_exist_sql       varchar2(5000);
   l_overlapping_pds_sql     varchar2(2000);
   l_temp_duration           varchar2(40);
   l_temp_rule               varchar2(40);
   l_temp_sob                varchar2(40);
   l_temp_rule_start_date    varchar2(40);
   l_temp_bind	             varchar2(50);
   l_temp_end	             varchar2(40);
   l_temp_end2	             varchar2(40);

   l_all_pds_exist_cursor    integer;
   l_overlapping_pds_cursor  integer;

BEGIN

   arp_util.print_fcn_label('arp_dates.prepare_val_gl_pds_sql_stmt()+ ');

   arp_util.debug('p_ai_flag   = ' ||
                  arp_trx_util.boolean_to_varchar2(p_ai_flag) ,
                  arp_global.MSG_LEVEL_DEBUG);

  /*------------------------------------------------------------+
   |  Don't do anything if the desired statements have already  |
   |  been constructed and parsed.                              |
   +------------------------------------------------------------*/

   IF (
         (
           p_ai_flag = TRUE         AND
           pg_ai_pds_exist_cursor   IS NOT NULL
         )
       OR
         (
           p_ai_flag = FALSE        AND
           pg_form_pds_exist_cursor IS NOT NULL
         )
      )
   THEN
       arp_util.debug('No SQL statement constuction or parse is required',
                       arp_global.MSG_LEVEL_DEBUG);
       arp_util.print_fcn_label('arp_dates.construct_val_gl_pds_sql_stmt()- ');
        RETURN;

   END IF;

   l_all_pds_exist_sql := null;


  /*--------------------------------------------------+
   |  Set AutoInvoice and form specific SQL fragments |
   +--------------------------------------------------*/

    IF (p_ai_flag = TRUE)
    THEN
         l_temp_duration        := 'l.accounting_rule_duration';
         l_temp_rule            := 'l.accounting_rule_id';
         l_temp_sob             := 'l.set_of_books_id';
         l_temp_rule_start_date := 'l.rule_start_date';
         l_temp_bind            := '
            )
         AND 2 =
            (';
         l_temp_end             := '
            )
       )';
         l_temp_end2            := '
       )';
    ELSE
         l_temp_duration        := 'nvl(:accounting_rule_duration, 1)';
         l_temp_rule            := ':accounting_rule_id';
         l_temp_sob             := ':sob_id';
         l_temp_rule_start_date := ':rule_start_date';
         l_temp_bind            := '
               UNION ';
         l_temp_end             := '
               ORDER BY 1';
         l_temp_end2            := null;
    END IF;

  /*-----------------------------------------------+
   |  Validation #1: Check that all periods exist  |
   +-----------------------------------------------*/

   IF (p_ai_flag = TRUE)
   THEN  l_all_pds_exist_sql :=
'INSERT INTO ra_interface_errors
     (
       interface_line_id,
       message_text,
       invalid_value,
       org_id
     )
SELECT l.interface_line_id,
       :all_pds_error_msg,
       l.rule_start_date,
       l.org_id
FROM   ra_interface_lines_gt l
WHERE  l.request_id             = :request_id
AND    nvl(l.interface_status,
           ''~'')                <> ''P''
AND    l.customer_trx_id       IS NOT NULL
AND    l.invoicing_rule_id     IS NOT NULL
AND    l.rule_start_date       IS NOT NULL
AND    l.link_to_line_id       IS NULL
AND    (
         NOT EXISTS
            (
';
    END IF;


    l_all_pds_exist_sql := l_all_pds_exist_sql ||
'               SELECT 1
               FROM   gl_periods          p1, /* to get the first period */
                      gl_periods          p2, /* to get the last period */
                      gl_sets_of_books    b,
                      gl_period_types     t,
                      ra_rules            r
               WHERE  r.rule_id           = '  || l_temp_rule || '
               AND    b.set_of_books_id   = '  || l_temp_sob || '
               AND    ' || l_temp_rule_start_date || '    BETWEEN p1.start_date
                                              AND p1.end_date
               AND    r.frequency        <> ''SPECIFIC''
               AND    p1.period_set_name  = b.period_set_name
               AND    p1.adjustment_period_flag = ''N''
               AND    p2.adjustment_period_flag = ''N''
               AND    p1.period_type      = r.frequency
               AND    t.period_type       = p1.period_type
               AND    p2.period_set_name  = b.period_set_name
               AND    p2.period_type      = p1.period_type
               AND    ( p2.end_date,
                        ( TO_CHAR(p2.period_year,999999)||''-''||
                          TO_CHAR(p2.period_num,999999)||''-''||
                          TO_CHAR( DECODE(r.type, ''ACC_DUR'',
                                          ' || l_temp_duration ||',
                                            ''PP_DR_ALL'',
                                          ' || l_temp_duration ||',
					    ''PP_DR_PP'',
                                          ' || l_temp_duration ||',

                                          r.occurrences),
                                   9999)
                        )
                      ) =
                      ( select MAX(p.end_date),
                               MAX( TO_CHAR(p.period_year,999999)||''-''||
                                    TO_CHAR(p.period_num,999999)||''-''||
                                    TO_CHAR(rownum,9999)
                                  ) from
                                   (SELECT p9.end_Date end_Date,p9.period_year period_year,p9.period_num period_num,p9.period_set_name period_set_name,
				    p9.start_date start_date,p9.adjustment_period_flag adjustment_period_flag,p9.period_type period_type
                                    FROM   gl_periods p9
				    order by p9.end_Date)  p
                                 WHERE  p.period_set_name = p1.period_set_name
                                 AND    p.period_type = p1.period_type
                                 AND    p.adjustment_period_flag = ''N''
                                 AND    p.start_date >= p1.start_date
                                 AND    rownum <= ( DECODE( r.type, ''ACC_DUR'',
                                                   ' || l_temp_duration ||',
							 ''PP_DR_ALL'',
                                                   ' || l_temp_duration ||',
							 ''PP_DR_PP'',
                                                   ' || l_temp_duration ||',
                                                   r.occurrences)
                                         )
                      )
               AND    DECODE( r.type, ''ACC_DUR'',
                              ' || l_temp_duration ||',
		                ''PP_DR_ALL'',
                                ' || l_temp_duration ||',
                                 ''PP_DR_PP'',
                             ' || l_temp_duration ||',
                              r.occurrences) =
                      ( SELECT COUNT(p3.period_set_name)
                        FROM   gl_periods p3
                        WHERE  p3.period_set_name = b.period_set_name
                        AND    p3.period_type = p1.period_type
                        AND    p3.adjustment_period_flag = ''N''
                        AND    p3.start_date >= p1.start_date
                        AND    p3.start_date <= p2.start_date
                      ) ' ||
           l_temp_bind || '
               SELECT DECODE(
                               COUNT(*),
                               0,    2,
                                     DECODE(
                                               SUM( r.occurrences ) / COUNT(*),
                                               COUNT(*), 1,
                                                         2
                                           )
                            )
               FROM   gl_periods         p,
                      gl_sets_of_books   b,
                      ra_rules           r,
                      ra_rule_schedules  rl
               WHERE  r.rule_id          =' || l_temp_rule || '
               AND    r.frequency        =''SPECIFIC''
               AND    rl.rule_id         = r.rule_id
               AND    b.set_of_books_id  = ' || l_temp_sob  || '
               AND    p.period_set_name  = b.period_set_name
               AND    p.period_type      = b.accounted_period_type
               AND    p.adjustment_period_flag = ''N''
               AND    rl.rule_date BETWEEN p.start_date AND p.end_date
               GROUP BY r.frequency ' ||
               l_temp_end;

    /*------------------------------------------------------------+
     | Validation #2: Check for overlapping periods               |
     +------------------------------------------------------------*/

    l_overlapping_pds_sql := null;

    IF ( p_ai_flag = TRUE )
    THEN l_overlapping_pds_sql :=
'INSERT INTO ra_interface_errors
   (
       interface_line_id,
       message_text,
       invalid_value,
       org_id
   )
SELECT l.interface_line_id,
       :overlapping_pds_error_msg,
       l.rule_start_date,
       l.org_id
FROM   ra_interface_lines_gt l
WHERE  l.request_id          = :request_id
AND    nvl(
            l.interface_status,
            ''~''
          )                 <> ''P''
AND    l.invoicing_rule_id  IS NOT NULL
AND    l.rule_start_date    IS NOT NULL
AND    l.customer_trx_id    IS NOT NULL
AND    l.link_to_line_id    IS NULL
AND    EXISTS
       (
';
    END IF;


   l_overlapping_pds_sql := l_overlapping_pds_sql ||
'         SELECT 1
         FROM   gl_periods         p1,
                gl_periods         p2,
                gl_sets_of_books   b,
                ra_rules           r
         WHERE  r.rule_id          =  ' || l_temp_rule || '
         AND    b.set_of_books_id  =  ' || l_temp_sob || '
         AND    p1.period_set_name = b.period_set_name
         AND    p1.period_type     = DECODE(
                                             r.frequency,
                                          ''SPECIFIC'', b.accounted_period_type,
                                                          r.frequency
                                           )
         AND    p2.period_set_name = b.period_set_name
         AND    p2.period_type     = p1.period_type
         AND    p1.adjustment_period_flag = ''N''
         AND    p2.adjustment_period_flag = ''N''
         AND    p2.start_date     <= p1.end_date
         AND    p2.end_date       >= p1.end_date
                /* don''t check period with itself */
         AND    p2.period_set_name || p2.period_name <>
                p1.period_set_name || p1.period_name
               ' || l_temp_end2;


   arp_util.debug('', arp_global.MSG_LEVEL_DEBUG);
   arp_util.debug('------------------ All Periods Exist SQL ---------------',
                  arp_global.MSG_LEVEL_DEBUG);
   arp_util.debug(l_all_pds_exist_sql, arp_global.MSG_LEVEL_DEBUG);
   arp_util.debug('', arp_global.MSG_LEVEL_DEBUG);
   arp_util.debug('length:  ' || length(l_all_pds_exist_sql),
                  arp_global.MSG_LEVEL_DEBUG);

   arp_util.debug('', arp_global.MSG_LEVEL_DEBUG);
   arp_util.debug('', arp_global.MSG_LEVEL_DEBUG);
   arp_util.debug('----------------- Overlapping Periods SQL ---------------',
                  arp_global.MSG_LEVEL_DEBUG);
   arp_util.debug(l_overlapping_pds_sql, arp_global.MSG_LEVEL_DEBUG);
   arp_util.debug('', arp_global.MSG_LEVEL_DEBUG);
   arp_util.debug('length:  ' || length(l_overlapping_pds_sql),
                  arp_global.MSG_LEVEL_DEBUG);
   arp_util.debug('', arp_global.MSG_LEVEL_DEBUG);

  /*-----------------------------------------------+
   |  Open and Parse the All Periods Exist cursor  |
   +-----------------------------------------------*/

   l_all_pds_exist_cursor := dbms_sql.open_cursor;

   dbms_sql.parse( l_all_pds_exist_cursor ,
                   l_all_pds_exist_sql,
                   dbms_sql.v7 );

  /*-------------------------------------------------+
   |  Open and Parse the Overlapping Periods cursor  |
   +-------------------------------------------------*/

   l_overlapping_pds_cursor := dbms_sql.open_cursor;

   dbms_sql.parse( l_overlapping_pds_cursor,
                   l_overlapping_pds_sql,
                   dbms_sql.v7 );

  /*------------------------------------------------------------+
   |  Set the package globals to hold the newly parsed cursors  |
   +------------------------------------------------------------*/

   IF ( p_ai_flag = TRUE )
   THEN
         pg_ai_pds_exist_cursor         := l_all_pds_exist_cursor;
         pg_ai_overlapping_pds_cursor   := l_overlapping_pds_cursor;
   ELSE
         pg_form_pds_exist_cursor       := l_all_pds_exist_cursor;
         pg_form_overlapping_pds_cursor := l_overlapping_pds_cursor;
   END IF;

   arp_util.print_fcn_label('arp_dates.prepare_val_gl_pds_sql_stmt()- ');


EXCEPTION
  WHEN OTHERS THEN

  /*---------------------------------------------+
   |  Display parameters and raise the exception |
   +---------------------------------------------*/

   arp_util.debug(
               'EXCEPTION:  arp_dates.prepare_val_gl_pds_sql_stmt()');

   arp_util.debug('');
   arp_util.debug('---- parameters for prepare_val_gl_pds_sql_stmt() -----');
   arp_util.debug('p_ai_flag   = ' ||
                  arp_trx_util.boolean_to_varchar2(p_ai_flag) );

   RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    val_gl_periods_for_rules						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Validates for an accounting rule and rule start date, that:             |
 |     - GL periods exist                                                    |
 |     - that there are no overlapping periods                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    arp_util.print_fcn_label						     |
 |    dbms_sql.bind_variable						     |
 |    dbms_sql.define_column						     |
 |    dbms_sql.execute							     |
 |    dbms_sql.execute_and_fetch					     |
 |    dbms_sql.column_value						     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_line_rec  					     |
 |		      p_customer_trx_line_id				     |
 |              OUT:                                                         |
 |		      l_derive_gldate_flag 				     |
 |		      l_amount_changed_flag				     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE val_gl_periods_for_rules(
                      p_request_id       IN ra_customer_trx.request_id%type,
		      p_acc_rule_id      IN ra_rules.rule_id%type,
	    	      p_acc_duration     IN
                           ra_customer_trx_lines.accounting_rule_duration%type,
            	      p_rule_start_date  IN
				    ra_customer_trx_lines.rule_start_date%type,
            	      p_sob_id           IN
                                    gl_sets_of_books.set_of_books_id%type ) IS
   l_ai_flag   boolean;
   l_count     integer;
   l_result    integer;

BEGIN

   arp_util.print_fcn_label('arp_dates.val_gl_periods_for_rules()+ ');

  /*---------------------------------------------+
   |  Do nothing if the line does not use rules  |
   +---------------------------------------------*/

   IF     ( p_acc_rule_id IS NULL )
   THEN   arp_util.debug('accounting_rule_id is null - no action taken');
          arp_util.print_fcn_label('arp_dates.val_gl_periods_for_rules()- ');
          RETURN;
   END IF;

  /*-----------------------------------------------------------------+
   |  Set the AutoInvoice flag to TRUE if a request_id was provided  |
   +-----------------------------------------------------------------*/

   IF     (p_request_id IS NULL)
   THEN   l_ai_flag := FALSE;
   ELSE   l_ai_flag := TRUE;
   END IF;

  /*------------------------------------------------------------------------+
   |   Construct and parse the SQL statements for the two validation SQLs.  |
   |									    |
   |   If the required SQL statements have already been constructed and     |
   |   parsed in this session, they are not constructed and parsed again.   |
   |   In that case, this function returns without doing anything and the   |
   |   existing cursors will be used.					    |
   +------------------------------------------------------------------------*/

   prepare_val_gl_pds_sql_stmt( l_ai_flag );


  /*-----------------------------+
   |  Bind the parameter values  |
   +-----------------------------*/

   IF    (l_ai_flag = TRUE )
   THEN
         dbms_sql.bind_variable( pg_ai_pds_exist_cursor,
                                 ':all_pds_error_msg',
                                 'AR_RAXTRX-1783');

         dbms_sql.bind_variable( pg_ai_pds_exist_cursor,
                                 ':request_id',
                                 p_request_id);


         dbms_sql.bind_variable( pg_ai_overlapping_pds_cursor,
                                 ':overlapping_pds_error_msg',
                                 'AR_RAXTRX-1784');

         dbms_sql.bind_variable( pg_ai_overlapping_pds_cursor,
                                 ':request_id',
                                 p_request_id);
   ELSE

         dbms_sql.bind_variable( pg_form_pds_exist_cursor,
                                 ':accounting_rule_duration',
                                  p_acc_duration);

         dbms_sql.bind_variable( pg_form_pds_exist_cursor,
                                 ':accounting_rule_id',
                                  p_acc_rule_id);

         dbms_sql.bind_variable( pg_form_pds_exist_cursor,
                                 ':sob_id',
                                  p_sob_id);


         dbms_sql.bind_variable( pg_form_pds_exist_cursor,
                                 ':rule_start_date',
                                 p_rule_start_date);


         dbms_sql.bind_variable( pg_form_overlapping_pds_cursor,
                                 ':accounting_rule_id',
                                  p_acc_rule_id);

         dbms_sql.bind_variable( pg_form_overlapping_pds_cursor,
                                 ':sob_id',
                                  p_sob_id);

         dbms_sql.define_column(pg_form_pds_exist_cursor, 1, l_result);

   END IF;


  /*-------------------------------------+
   |  Execute the validation statements  |
   +-------------------------------------*/

   IF    ( l_ai_flag = TRUE )
   THEN

        l_count := dbms_sql.execute(pg_ai_pds_exist_cursor);

        arp_util.debug('AI periods exist validation count: ' || l_count,
                       arp_global.MSG_LEVEL_DEBUG);


        l_count := dbms_sql.execute(pg_ai_overlapping_pds_cursor);

        arp_util.debug('AI overlapping validation count  : ' || l_count,
                       arp_global.MSG_LEVEL_DEBUG );
   ELSE

       /*---------------------------------------------------------------+
        |  Execute the periods exist validation. 			|
        |  The validation fails if either no rows were returned by the 	|
        |  query or the query returned a value of 2.			|
	+---------------------------------------------------------------*/

        l_count := dbms_sql.execute_and_fetch( pg_form_pds_exist_cursor,
                                               FALSE);

        dbms_sql.column_value(pg_form_pds_exist_cursor, 1, l_result);

        arp_util.debug('Form periods exist validation count: ' || l_count ||
                       '   result: ' || l_result, arp_global.MSG_LEVEL_DEBUG);

        IF (
             l_count  = 0  OR
             l_result = 2
           )
        THEN
             arp_util.debug('Form periods exist validation failed');
             fnd_message.set_name('AR', 'AR_RAXTRX-1783');
             app_exception.raise_exception;
        END IF;


	/*----------------------------------------------+
        |  Execute the overlapping periods validation.  |
	+-----------------------------------------------*/

        l_count := dbms_sql.execute_and_fetch( pg_form_overlapping_pds_cursor,
                                               FALSE);

        arp_util.debug('Form overlapping validation count: ' || l_count,
		       arp_global.MSG_LEVEL_DEBUG);

        IF ( l_count  <> 0 )
        THEN
             arp_util.debug('Form overlapping periods validation failed');
	     fnd_message.set_name('AR', 'AR_RAXTRX-1784');
             app_exception.raise_exception;
        END IF;


   END IF;

   arp_util.print_fcn_label('arp_dates.val_gl_periods_for_rules()- ');


EXCEPTION
  WHEN OTHERS THEN

  /*---------------------------------------------+
   |  Display parameters and raise the exception |
   +---------------------------------------------*/

   arp_util.debug('EXCEPTION:  arp_dates.val_gl_periods_for_rules()');

   arp_util.debug('');
   arp_util.debug('------- parameters for val_gl_periods_for_rules() -------');

   arp_util.debug( 'p_request_id       = ' || p_request_id );
   arp_util.debug( 'p_acc_rule_id      = ' || p_acc_rule_id );
   arp_util.debug( 'p_acc_duration     = ' || p_acc_duration );
   arp_util.debug( 'p_rule_start_date  = ' || p_rule_start_date );
   arp_util.debug( 'p_sob_id           = ' || p_sob_id );

   RAISE;

END;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_date_based_on_rev_sched					     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Validates for an accounting rule and rule start date, that:             |
 |     - GL periods exist                                                    |
 |     - that there are no overlapping periods                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    arp_util.print_fcn_label						     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_customer_trx_id					     |
 |		      p_invoicing_rule_id				     |
 |              OUT:                                                         |
 |		      p_candidate_date 					     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-JUL-95  Charlie Tomberg     Created                                |
 |                                                                           |
 |     10-Nov-00  Y Rakotonirainy     Bug 1296673                            |
 |                                    Modified to exclude adjustment period  |
 |                                    while calculating gl periods           |                                                                              |
 |                                                                           |
 +===========================================================================*/

PROCEDURE get_date_based_on_rev_sched(
                           p_customer_trx_id     IN
                               ra_customer_trx.customer_trx_id%type,
                           p_invoicing_rule_id   IN
			       ra_customer_trx.invoicing_rule_id%type,
			   p_candidate_date     OUT NOCOPY  DATE
                                         ) IS

actual_num_fiscal_year 	   gl_periods.period_year%TYPE;

BEGIN

   arp_util.print_fcn_label('arp_dates.get_date_based_on_rev_sched()+ ');


   IF     (p_invoicing_rule_id = IN_ADVANCE )
   THEN

          arp_util.debug('Invoicing Rule: In Advance',
			 arp_global.MSG_LEVEL_DEBUG);

          SELECT MIN(rl.rule_start_date)
          INTO   p_candidate_date
          FROM   ra_customer_trx_lines rl
          WHERE  rl.customer_trx_id    = p_customer_trx_id
          AND    line_type             = 'LINE';

   ELSE

          arp_util.debug('Invoicing Rule: In Arrears',
			 arp_global.MSG_LEVEL_DEBUG);
	  /*Bug 2505767, Added an additional check in the where clause to pick up only
	    those periods which match with the type defined in the set of books*/
          SELECT COUNT(gp1.period_set_name)
          INTO   actual_num_fiscal_year
          FROM   ra_customer_trx_lines ctl,
                 gl_sets_of_books b,
                 gl_periods gp1
          WHERE  ctl.customer_trx_id = p_customer_trx_id
          AND    ctl.set_of_books_id = b.set_of_books_id
          AND    gp1.period_set_name = b.period_set_name
	  AND    gp1.period_type = b.accounted_period_type
          AND    gp1.period_year = to_number(to_char(ctl.rule_start_date,'YYYY'))
          AND    gp1.adjustment_period_flag ='N' ;

          SELECT MAX(
                      DECODE(
                             r.frequency,
                             'SPECIFIC', MAX(rl.rule_date),
                                         LEAST(
                                                 ctl.rule_start_date -
                                                   gp1.start_date +
                                                   gp2.start_date,
                                                   gp2.end_date,
						   nvl(ctl.rule_end_date,gp2.end_date) --Bug5022614
                                              )
                            )
                    )
          INTO   p_candidate_date
          FROM   ra_customer_trx_lines 	  ctl,
                 gl_periods 		  gp1,
                 gl_periods 		  gp2,
                 gl_sets_of_books 	  b,
                 gl_period_types 	  t,
                 ra_rules 		  r,
                 ra_rule_schedules  	  rl
          WHERE  ctl.customer_trx_id      = p_customer_trx_id
          AND    ctl.accounting_rule_id   = r.rule_id
          AND    rl.rule_id (+)           = decode(r.frequency,
                                                   'SPECIFIC', r.rule_id,
                                                               -9.9)
          AND    ctl.set_of_books_id      = b.set_of_books_id
          AND    ctl.set_of_books_id      = pg_set_of_books_id
          AND    ctl.rule_start_date      BETWEEN gp1.start_date
                                              AND gp1.end_date
          AND    gp1.period_set_name      = b.period_set_name
          AND    UPPER(gp1.period_type)   =
                        UPPER(
                               DECODE(r.frequency,
                                      'SPECIFIC', b.accounted_period_type,
                                                  r.frequency
                                     )
                             )
          AND    t.period_type            = gp1.period_type
          AND    gp2.period_set_name      = gp1.period_set_name
          AND    gp2.period_type          = gp1.period_type
          AND    gp2.period_year          =
                       gp1.period_year +
                       TRUNC(
                              (
                                gp1.period_num -1 +
                                DECODE(
                                       r.type,
                                       'ACC_DUR', ctl.accounting_rule_duration,
                                       'PP_DR_PP',ctl.accounting_rule_duration,
                                       'PP_DR_ALL',ctl.accounting_rule_duration,
                                                  r.occurrences
                                      ) -1
                              ) /
                             actual_num_fiscal_year
                            )
          AND   gp2.period_num =
                       MOD(
                            (
                              gp1.period_num -1 +
                              DECODE(
                                     r.type,
                                     'ACC_DUR', ctl.accounting_rule_duration,
				     'PP_DR_PP',ctl.accounting_rule_duration,
                                      'PP_DR_ALL',ctl.accounting_rule_duration,
                                       r.occurrences
                                    ) -1
                            ),
                            actual_num_fiscal_year
                          ) + 1
         GROUP BY
                  ctl.customer_trx_id,
                  r.frequency,
                  rl.rule_date,
                  ctl.rule_start_date,
                  gp1.start_date,
                  gp2.start_date,
                  gp2.end_date,
		  ctl.rule_end_Date;

   END IF;

   arp_util.print_fcn_label('arp_dates.get_date_based_on_rev_sched()- ');


EXCEPTION
  WHEN OTHERS THEN

  /*---------------------------------------------+
   |  Display parameters and raise the exception |
   +---------------------------------------------*/

   arp_util.debug('EXCEPTION:  arp_dates.get_date_based_on_rev_sched()');

   arp_util.debug('');
   arp_util.debug('---- parameters for get_date_based_on_rev_sched() ----');

   arp_util.debug('p_customer_trx_id    = ' || p_customer_trx_id );
   arp_util.debug('p_invoicing_rule_id  = ' || p_invoicing_rule_id );

   RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    derive_gl_trx_dates_from_rules					     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      This procedure accepts the customer trx id that is passed and Checks |
 |      to see whether there is a rule for this Customer trx id. If there    |
 |      are no rules then the user exit return to the calling module. If the |
 |      rule is of type Advanced Invoice then the minimum rule start date is |
 |      selected. If the rule is of type Arrears Invoice then the Maximum    |
 |      distributions GL dates for the transaction lines is selected. The    |
 |      candidate date is then validated. If it succeeds, that date is used. |
 |      if the validation fails, the default gl date is obtaioned and used.  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    arp_util.print_fcn_label						     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_customer_trx_id 				     |
 |              OUT:                                                         |
 |		      p_gl_date 					     |
 |		      p_trx_date					     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     31-JUL-95  Charlie Tomberg     Created                                |
 |     08-FEB-96  Martin Johnson      Removed updates to database.           |
 |                                    Removed set_names for displaying       |
 |                                    new dates.                             |
 |     29-MAY-96  Martin Johnson      BugNo:368206.  Fixed so that derived   |
 |                                    trx_date gets returned for Arrears     |
 |                                    case.                                  |
 |                                                                           |
 +===========================================================================*/

PROCEDURE derive_gl_trx_dates_from_rules (
                           p_customer_trx_id IN
                               ra_customer_trx.customer_trx_id%type,
			   p_gl_date IN OUT NOCOPY
			       ra_cust_trx_line_gl_dist.gl_date%type,
			   p_trx_date IN OUT NOCOPY
                               ra_customer_trx.trx_date%type,
                           p_recalculate_tax_flag IN OUT NOCOPY boolean,
                           P_created_from IN  ar_trx_header_gt.created_from%type default NULL,
                           p_defaulted_gl_date_flag IN ar_trx_header_gt.defaulted_gl_date_flag%type default NULL
                                         ) IS


   l_candidate_date	   date;
   l_db_trx_date           ra_customer_trx.trx_date%type;
   l_db_gl_date		   ra_cust_trx_line_gl_dist.gl_date%type;

   l_trx_date              ra_customer_trx.trx_date%type;
   l_gl_date		   ra_cust_trx_line_gl_dist.gl_date%type;

   l_exchange_rate	   ra_customer_trx.exchange_rate%type;
   l_currency_code	   ra_customer_trx.invoice_currency_code%type;

   l_period_name           varchar2(15);
   l_start_date            date;
   l_end_date              date;
   l_closing_status        varchar2(1);
   l_period_type           varchar2(15);
   l_period_year           number;
   l_period_num            number;
   l_quarter_num           number;
   l_allow_not_open_flag   varchar2(2);
   l_default_gl_date	   ra_cust_trx_line_gl_dist.gl_date%type;
   l_defaulting_rule_used  varchar2(100);
   l_error_message	   varchar2(100);

   l_invoicing_rule_id	   ra_customer_trx.invoicing_rule_id%type;

   l_trx_rec		   ra_customer_trx%rowtype;
   l_dist_rec		   ra_cust_trx_line_gl_dist%rowtype;


BEGIN

   arp_util.print_fcn_label('arp_dates.derive_gl_trx_dates_from_rules()+ ');


  /*---------------------------+
   |  Validate the parameters  |
   +---------------------------*/

   IF   ( p_customer_trx_id    IS NULL )
   THEN
         fnd_message.set_name('AR', 'AR_INV_ARGS');
         fnd_message.set_token('PROCEDURE',
                               'derive_gl_trx_dates_from_rules()');
         app_exception.raise_exception;

   END IF;


 /*--------------------------------------------------------------+
  |  Get the existing dates, currency and exchange information	 |
  |  from the database  					 |
  +--------------------------------------------------------------*/
/*In case,
    1. If the distributions are not passed to Invoice API,
	   then at this stage GLD doesn't contain any data.
	   So, separated the query in order to get the correct values
	   --added for bug 18081450 changed the single sql into two part.
	*/
   SELECT  MIN(ct.trx_date),
           MAX(ct.exchange_rate),
           MAX(ct.invoice_currency_code),
           MAX(ct.invoicing_rule_id)
   INTO    l_db_trx_date,
           l_exchange_rate,
           l_currency_code,
           l_invoicing_rule_id
   FROM    ra_customer_trx          ct
   WHERE   ct.customer_trx_id       = p_customer_trx_id;


   SELECT  MIN(ctlgd.gl_date)
   INTO    l_db_gl_date
   FROM    ra_cust_trx_line_gl_dist ctlgd
   WHERE   ctlgd.customer_trx_id    = p_customer_trx_id
   AND     ctlgd.account_class      = 'REC'
   AND     ctlgd.latest_rec_flag    = 'Y';

   arp_util.debug('DB trx_date: ' || l_db_trx_date ||
                  ',    DB gl_date:  ' || l_db_gl_date,
                  arp_global.MSG_LEVEL_DEBUG);
   arp_util.debug('exchange rate: ' || l_exchange_rate ||
                  ',    currency code: ' || l_currency_code,
                  arp_global.MSG_LEVEL_DEBUG);

   arp_util.debug('invoicing_rule_id:  ' ||  l_invoicing_rule_id,
		  arp_global.MSG_LEVEL_DEBUG);

 /*--------------------------------------------------------------------------+
  | If the rule is In Advance, get the first date that revenue is recognized |
  | If the rule is In Arrears, get the last date that revenue is recognized  |
  +--------------------------------------------------------------------------*/

   get_date_based_on_rev_sched(
                                 p_customer_trx_id,
                                 l_invoicing_rule_id,
                                 l_candidate_date
                              );
   arp_util.debug('candidate date: ' || l_candidate_date,
                  arp_global.MSG_LEVEL_DEBUG);

  /*-------------------------------------------------------------------------+
   | If  l_candidate_date is null, it means that all of the lines have 	     |
   | null rule_start_date, or there are no lines.  In this case just return  |
   | the current dates and return exit.					     |
   +-------------------------------------------------------------------------*/
--added for bug 18081450
IF (l_invoicing_rule_id = -3 AND l_candidate_date is null)
			THEN
						INSERT
						INTO    ar_trx_errors_gt (trx_header_id
						                        , error_message)
						SELECT  trx_header_id
						      , arp_standard.fnd_message('AR_TW_NO_PERIOD_DEFINED')
						FROM    ar_trx_header_gt
						WHERE   customer_trx_id = p_customer_trx_id;

		 		 arp_util.debug('Could not retrive End Date,No accounting period defined, customer_trx_id' ||
								to_char(p_customer_trx_id) ||
								'   In Arrears Invoice: ');
            RETURN;
			END IF;

--added for bug 18081450



   IF     (l_candidate_date IS NULL )
   THEN   l_trx_date := l_db_trx_date;
          l_gl_date  := l_db_gl_date;

          arp_util.debug('Candidate date is null - no action taken',
			  arp_global.MSG_LEVEL_DEBUG);
   ELSE

	 /*-------------------------------------------------------+
	  |  Determine the closing status of the candidate date.  |
	  +-------------------------------------------------------*/

          arp_standard.gl_period_info(  l_candidate_date,
                                        l_period_name,
                                        l_start_date,
                                        l_end_date,
                                        l_closing_status,
                                        l_period_type,
                                        l_period_year,
                                        l_period_num,
                                        l_quarter_num
                                     );

          arp_util.debug('closing status:  ' || l_closing_status,
			 arp_global.MSG_LEVEL_DEBUG);

          IF (
        	l_closing_status       = 'O'  OR
                l_closing_status       = 'F'  OR
               (
                 l_closing_status     = 'N'  AND
                 l_invoicing_rule_id  = IN_ARREARS
               )
             )
          THEN

                arp_util.debug('candidate date passed closing status ' ||
			       'validation', arp_global.MSG_LEVEL_DEBUG);
			  --added for bug 18081450

              arp_util.debug('l_gl_date:'||l_gl_date, arp_global.MSG_LEVEL_DEBUG);
              arp_util.debug('l_db_gl_date:'||l_db_gl_date, arp_global.MSG_LEVEL_DEBUG);
              arp_util.debug('l_candidate_date:'||l_candidate_date, arp_global.MSG_LEVEL_DEBUG);

               IF( ( l_invoicing_rule_id = IN_ARREARS ) AND
                   (l_db_gl_date is null)
                 ) THEN
                 l_db_gl_date := l_candidate_date;
                 l_gl_date := l_candidate_date;
              END if;
                        --added for bug 18081450




                IF (l_db_gl_date <> l_candidate_date )
                THEN
                 /* bug 5884520 Added condition to avoid re defaulting gl date*/
                 IF ((nvl(p_created_from,'X') = 'AR_INVOICE_API' ) AND
                     (nvl(p_defaulted_gl_date_flag,'Y') = 'N' ) AND
                     (l_invoicing_rule_id = IN_ADVANCE) ) THEN
                      l_gl_date := l_db_gl_date;
                 ELSE
                     l_gl_date := l_candidate_date;
                 END IF;
                END IF;

                IF   (
 			l_invoicing_rule_id = IN_ADVANCE   AND
                        l_db_trx_date > l_candidate_date
                     )
                     OR
                     (  l_invoicing_rule_id = IN_ARREARS   AND
                        l_db_trx_date <> l_candidate_date
                     )
                THEN
                     -- bug 6350680
                     --l_trx_date := l_candidate_date;
		       l_trx_date := l_db_trx_date;
                END IF;
          ELSE

                arp_util.debug('candidate date failed closing status ' ||
			       'validation', arp_global.MSG_LEVEL_DEBUG);

  	       /*----------------------------------------------------+
		|  If the candidate date is not in a closed period,  |
                |  then it cannot be used. Exit with an error.       |
	        +----------------------------------------------------*/

	 	/* Bug 858875: Check closing status 'W' (close pending) */
                IF ( nvl(l_closing_status, 'Z') not in ( 'C', 'N', 'W') )
                THEN
                     arp_util.debug('No accounting period defined for ' ||
                                    to_char( l_candidate_date ) ||
                                    '   closing status: ' ||
                                    l_closing_status);

                     fnd_message.set_name('AR', 'AR_TW_NO_PERIOD_DEFINED');
                     fnd_message.set_token('DATE',
                                           to_char( l_candidate_date ));
                     app_exception.raise_exception;
                END IF;

		IF     ( l_invoicing_rule_id = IN_ARREARS )
                THEN   l_allow_not_open_flag := 'Y';
                ELSE   l_allow_not_open_flag := 'N';
                END IF;

                arp_util.debug('app_id: ' || pg_application_id ||
                               ' ,  sob: ' || pg_set_of_books_id,
			       arp_global.MSG_LEVEL_DEBUG);

                IF (arp_standard.validate_and_default_gl_date(
                                        l_candidate_date,
				        null,
					null,
					null,
					null,
					null,
					null,
					null,
                                        l_allow_not_open_flag,
                                        l_invoicing_rule_id,
                                        pg_set_of_books_id,
                                        pg_application_id,
                                        l_default_gl_date,
                                        l_defaulting_rule_used,
                                        l_error_message
                                     ) = FALSE
                   )
                THEN fnd_message.set_name('AR', 'GENERIC_MESSAGE');
                     fnd_message.set_token('GENERIC_TEXT',
                                           l_error_message);
                     fnd_message.set_name('AR', 'AR_TW_DERIVE_FAILURE');
                     arp_util.debug(l_error_message);
                     app_exception.raise_exception;
                ELSE arp_util.debug('defaulting rule used: ' ||
				    l_defaulting_rule_used,
                                    arp_global.MSG_LEVEL_DEBUG);


                     arp_util.debug('validate_and_default_gl_date() returned '
                                    || ' date : ' || l_default_gl_date,
                                    arp_global.MSG_LEVEL_DEBUG);

                     IF (l_db_gl_date <> l_default_gl_date OR l_db_gl_date is NULL)
                     THEN
                          l_gl_date := l_default_gl_date;
                           arp_util.debug('Preparing to set gl_date to ' ||
                                          l_default_gl_date);
                     END IF;

                     IF (
  	     		   l_invoicing_rule_id = IN_ADVANCE   AND
                           l_db_trx_date       > l_default_gl_date
                        )
                        OR
                        (  l_invoicing_rule_id = IN_ARREARS   AND
                           l_db_trx_date <> l_default_gl_date
                        )
                     THEN
                          -- Bug 6350680
			  --l_trx_date := l_default_gl_date;
			  l_trx_date := l_db_trx_date;
                          arp_util.debug('Preparing to set trx_date to ' ||
                                         l_default_gl_date);

                     END IF;

                END IF;  /* Default date was generated */

          END IF;  /* Candidate date is not valid case */

   END IF;         /* Candidate date is not null case */

   IF ( l_db_trx_date <> nvl(l_trx_date, l_db_trx_date) )
   THEN
        p_recalculate_tax_flag := TRUE;
   END IF;

  /*---------------------------------------------+
   |  Copy the new dates to the out NOCOPY parameters.  |
   +---------------------------------------------*/

   p_trx_date := nvl(l_trx_date, p_trx_date);
   p_gl_date  := nvl(l_gl_date, p_gl_date);


   arp_util.print_fcn_label('arp_dates.derive_gl_trx_dates_from_rules()- ');

EXCEPTION
  WHEN OTHERS THEN

  /*---------------------------------------------+
   |  Display parameters and raise the exception |
   +---------------------------------------------*/

   arp_util.debug('EXCEPTION:  arp_dates.derive_gl_trx_dates_from_rules()');

   arp_util.debug('');
   arp_util.debug('---- parameters for derive_gl_trx_dates_from_rules() ----');

   arp_util.debug('p_customer_trx_id    = ' || p_customer_trx_id);
   arp_util.debug('l_invoicing_rule_id  = ' || l_invoicing_rule_id);

   RAISE;

END;

BEGIN
    pg_set_of_books_id :=
                 arp_trx_global.system_info.system_parameters.set_of_books_id;

    pg_application_id := 222;
--                 arp_trx_global.profile_info.application_id;

EXCEPTION
   WHEN OTHERS THEN
     arp_util.debug('EXCEPTION:  arp_dates');
     RAISE;

END ARP_DATES;

/
