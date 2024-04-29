--------------------------------------------------------
--  DDL for Package Body ARP_CMA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CMA_PKG" AS
/* $Header: ARTICMAB.pls 115.6 2003/04/11 21:12:44 mraymond ship $ */

  /*--------------------------------------------------------+
   |  Dummy constants for use in update and lock operations |
   +--------------------------------------------------------*/

  AR_NUMBER_DUMMY CONSTANT NUMBER(15)   := -999999999999999;
  AR_DATE_DUMMY   CONSTANT DATE         := to_date(1, 'J');

  /*---------------------------------------------------------------+
   |  Package global variables to hold the parsed update cursors.  |
   |  This allows the cursors to be reused without being reparsed. |
   +---------------------------------------------------------------*/

  pg_cursor1  integer := '';
  pg_cursor2  integer := '';
  pg_cursor3  integer := '';
  pg_cursor4  integer := '';

  /*-------------------------------------+
   |  WHO column values from FND_GLOBAL  |
   +-------------------------------------*/

  pg_user_id          number;
  pg_conc_login_id    number;
  pg_login_id         number;
  pg_prog_appl_id     number;
  pg_conc_program_id  number;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    compare_cma_records						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function compares two ar_credit_memo_amounts records to 	     |
 |    determine if any columns in the two records are different. If a 	     |
 |    given column in the  p_old_cma_rec record contains the dummy 	     |
 |    constant, that column is not used in the comparison.                   |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug 	                                                     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_old_cma_rec	 - first cma record 		     |
 |                    p_new_cma_rec 	 - second cma record 		     |
 |              OUT:                                                         |
 |                    None					 	     |
 |                                                                           |
 | RETURNS    : TRUE   if all columns in the cma records are the same,       |
 |		FALSE  if any column in the cma records are different.	     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION  compare_cma_records( p_old_cma_rec IN
                                        ar_credit_memo_amounts%rowtype,
				p_new_cma_rec IN
                                        ar_credit_memo_amounts%rowtype)
                               RETURN BOOLEAN  IS
    l_result     boolean;
    l_sql_result varchar2(2);

BEGIN
    arp_util.debug('arp_cma_pkg.compare_cma_records()+');


    select DECODE(max(dummy),
                  '', 'N',
                      'Y')
    INTO   l_sql_result
    FROM   dual
    WHERE
        (
           p_old_cma_rec.credit_memo_amount_id ||
           p_old_cma_rec.last_updated_by ||
           p_old_cma_rec.last_update_date ||
           p_old_cma_rec.last_update_login ||
           p_old_cma_rec.created_by ||
           p_old_cma_rec.creation_date ||
           p_old_cma_rec.customer_trx_line_id ||
           p_old_cma_rec.gl_date ||
           p_old_cma_rec.amount ||
           p_old_cma_rec.program_application_id ||
           p_old_cma_rec.program_id ||
           p_old_cma_rec.program_update_date ||
           p_old_cma_rec.request_id
        =
           DECODE(p_old_cma_rec.credit_memo_amount_id,
                  AR_NUMBER_DUMMY, p_old_cma_rec.credit_memo_amount_id,
                                   p_new_cma_rec.credit_memo_amount_id) ||
           DECODE(p_old_cma_rec.last_updated_by,
                  AR_NUMBER_DUMMY, p_old_cma_rec.last_updated_by,
                                   p_new_cma_rec.last_updated_by) ||
           DECODE(p_old_cma_rec.last_update_date,
                  AR_DATE_DUMMY,   p_old_cma_rec.last_update_date,
                                   p_new_cma_rec.last_update_date) ||
           DECODE(p_old_cma_rec.last_update_login,
                  AR_NUMBER_DUMMY, p_old_cma_rec.last_update_login,
                                   p_new_cma_rec.last_update_login) ||
           DECODE(p_old_cma_rec.created_by,
                  AR_NUMBER_DUMMY, p_old_cma_rec.created_by,
                                   p_new_cma_rec.created_by) ||
           DECODE(p_old_cma_rec.creation_date,
                  AR_DATE_DUMMY,   p_old_cma_rec.creation_date,
                                   p_new_cma_rec.creation_date) ||
           DECODE(p_old_cma_rec.customer_trx_line_id,
                  AR_NUMBER_DUMMY, p_old_cma_rec.customer_trx_line_id,
                                   p_new_cma_rec.customer_trx_line_id) ||
           DECODE(p_old_cma_rec.gl_date,
                  AR_DATE_DUMMY,   p_old_cma_rec.gl_date,
                                   p_new_cma_rec.gl_date) ||
           DECODE(p_old_cma_rec.amount,
                  AR_NUMBER_DUMMY, p_old_cma_rec.amount,
                                   p_new_cma_rec.amount) ||
           DECODE(p_old_cma_rec.program_application_id,
                  AR_NUMBER_DUMMY, p_old_cma_rec.program_application_id,
                                   p_new_cma_rec.program_application_id) ||
           DECODE(p_old_cma_rec.program_id,
                  AR_NUMBER_DUMMY, p_old_cma_rec.program_id,
                                   p_new_cma_rec.program_id) ||
           DECODE(p_old_cma_rec.program_update_date,
                  AR_DATE_DUMMY,  p_old_cma_rec.program_update_date,
                                   p_new_cma_rec.program_update_date) ||
           DECODE(p_old_cma_rec.request_id,
                  AR_NUMBER_DUMMY, p_old_cma_rec.request_id,
                                   p_new_cma_rec.request_id)
       );


    if (l_sql_result = 'N')
    then l_result := FALSE;
         arp_util.debug(
                      'arp_cma_pkg.compare_cma_records(): result: FALSE');
    else l_result := TRUE;
         arp_util.debug(
                      'arp_cma_pkg.compare_cma_records(): result: TRUE');
    END IF;

    arp_util.debug('arp_cma_pkg.compare_cma_records()-');

    return(l_result);

    EXCEPTION
      WHEN  OTHERS THEN
         arp_util.debug( 'EXCEPTION: arp_cma_pkg.compare_cma_records' );
         RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    bind_cma_variables                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Binds variables from the record variable to the bind variables         |
 |    in the dynamic SQL update statement.                                   |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    dbms_sql.bind_variable                                                 |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_update_cursor  - ID of the update cursor             |
 |                    p_cma_rec       - ar_credit_memo_amounts record        |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE bind_cma_variables(p_update_cursor IN integer,
                              p_cma_rec IN ar_credit_memo_amounts%rowtype)
          IS

BEGIN

   arp_util.debug('arp_cma_pkg.bind_cma_variables()+');

  /*------------------+
   |  Dummy constants |
   +------------------*/

   dbms_sql.bind_variable(p_update_cursor, ':ar_number_dummy',
                          AR_NUMBER_DUMMY);

   dbms_sql.bind_variable(p_update_cursor, ':ar_date_dummy',
                          AR_DATE_DUMMY);

  /*------------------+
   |  WHO variables   |
   +------------------*/

   dbms_sql.bind_variable(p_update_cursor, ':pg_user_id',
                          pg_user_id);

   dbms_sql.bind_variable(p_update_cursor, ':pg_login_id',
                          pg_login_id);

   dbms_sql.bind_variable(p_update_cursor, ':pg_conc_login_id',
                          pg_conc_login_id);


  /*----------------------------------------------+
   |  Bind variables for all columns in the table |
   +----------------------------------------------*/


   dbms_sql.bind_variable(p_update_cursor, ':credit_memo_amount_id',
                          p_cma_rec.credit_memo_amount_id);

   dbms_sql.bind_variable(p_update_cursor, ':credit_memo_amount_id',
                          p_cma_rec.credit_memo_amount_id);

   dbms_sql.bind_variable(p_update_cursor, ':last_updated_by',
                          p_cma_rec.last_updated_by);

   dbms_sql.bind_variable(p_update_cursor, ':last_update_date',
                          p_cma_rec.last_update_date);

   dbms_sql.bind_variable(p_update_cursor, ':last_update_login',
                          p_cma_rec.last_update_login);

   dbms_sql.bind_variable(p_update_cursor, ':created_by',
                          p_cma_rec.created_by);

   dbms_sql.bind_variable(p_update_cursor, ':creation_date',
                          p_cma_rec.creation_date);

   dbms_sql.bind_variable(p_update_cursor, ':customer_trx_line_id',
                          p_cma_rec.customer_trx_line_id);

   dbms_sql.bind_variable(p_update_cursor, ':gl_date',
                          p_cma_rec.gl_date);

   dbms_sql.bind_variable(p_update_cursor, ':amount',
                          p_cma_rec.amount);

   dbms_sql.bind_variable(p_update_cursor, ':program_application_id',
                          p_cma_rec.program_application_id);

   dbms_sql.bind_variable(p_update_cursor, ':program_id',
                          p_cma_rec.program_id);

   dbms_sql.bind_variable(p_update_cursor, ':program_update_date',
                          p_cma_rec.program_update_date);

   dbms_sql.bind_variable(p_update_cursor, ':request_id',
                          p_cma_rec.request_id);


   arp_util.debug('arp_cma_pkg.bind_cma_variables()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_cma_pkg.bind_cma_variables()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    construct_cma_update_stmt 					     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Copies the text of the dynamic SQL update statement into the           |
 |    out NOCOPY paramater. The update statement does not contain a where clause    |
 |    since this is the dynamic part that is added later.                    |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    None.                                                  |
 |              OUT:                                                         |
 |                    update_text  - text of the update statement            |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |    This statement only updates columns in the cma record that do not      |
 |    contain the dummy values that indicate that they should not be changed.|
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE construct_cma_update_stmt( update_text OUT NOCOPY varchar2) IS

BEGIN
   arp_util.debug('arp_cma_pkg.construct_cma_update_stmt()+');

   update_text :=
 'UPDATE ar_credit_memo_amounts
   SET    credit_memo_amount_id =
               DECODE(:credit_memo_amount_id,
                      :ar_number_dummy, credit_memo_amount_id,
                                        :credit_memo_amount_id),
          last_updated_by =
               DECODE(:last_updated_by,
                      :ar_number_dummy, :pg_user_id,
                                        :last_updated_by),
          last_update_date =
               DECODE(:last_update_date,
                      :ar_date_dummy,   sysdate,
                                        :last_update_date),
          last_update_login =
               DECODE(:last_update_login,
                      :ar_number_dummy, nvl(:pg_conc_login_id,
                                            :pg_login_id),
                                        :last_update_login),
          created_by =
               DECODE(:created_by,
                      :ar_number_dummy, created_by,
                                        :created_by),
          creation_date =
               DECODE(:creation_date,
                      :ar_date_dummy, creation_date,
                                        :creation_date),
          customer_trx_line_id =
               DECODE(:customer_trx_line_id,
                      :ar_number_dummy, customer_trx_line_id,
                                        :customer_trx_line_id),
          gl_date =
               DECODE(:gl_date,
                      :ar_date_dummy,   gl_date,
                                        :gl_date),
          amount =
               DECODE(:amount,
                      :ar_number_dummy, amount,
                                        :amount),
          program_application_id =
               DECODE(:program_application_id,
                      :ar_number_dummy, program_application_id,
                                        :program_application_id),
          program_id =
               DECODE(:program_id,
                      :ar_number_dummy, program_id,
                                        :program_id),
          program_update_date =
               DECODE(:program_update_date,
                      :ar_date_dummy,   program_update_date,
                                        :program_update_date),
          request_id =
               DECODE(:request_id,
                      :ar_number_dummy, request_id,
                                        :request_id)';

   arp_util.debug('arp_cma_pkg.construct_cma_update_stmt()-');

EXCEPTION
    WHEN OTHERS THEN
       arp_util.debug('EXCEPTION:  arp_cma_pkg.construct_cma_update_stmt()');
       RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    generic_update                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure Updates records in ar_credit_memo_amounts  	     |
 |     identified by the where clause that is passed in as a parameter. Only |
 |     those columns in the cma record parameter that do not contain the     |
 |     special dummy values are updated. 				     |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |    dbms_sql.open_cursor 						     |
 |    dbms_sql.parse							     |
 |    dbms_sql.execute							     |
 |    dbms_sql.close_cursor						     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_update_cursor  - identifies the cursor to use 	     |
 |                    p_where_clause   - identifies which rows to update     |
 | 		      p_where1         - value to bind into where clause     |
 |		      p_cma_rec        - contains the new cma values         |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE generic_update(p_update_cursor IN OUT NOCOPY integer,
			 p_where_clause  IN varchar2,
			 p_where1        IN number,
                         p_cma_rec      IN ar_credit_memo_amounts%rowtype) IS

   l_count             number;
   l_update_statement  varchar2(25000);

BEGIN
   arp_util.debug('arp_cma_pkg.generic_update()+');

  /*--------------------------------------------------------------+
   |  If this update statement has not already been parsed, 	  |
   |  construct the statement and parse it.			  |
   |  Otherwise, use the already parsed statement and rebind its  |
   |  variables.						  |
   +--------------------------------------------------------------*/

   IF (p_update_cursor IS NULL)
   THEN

         p_update_cursor := dbms_sql.open_cursor;

         /*---------------------------------+
          |  Construct the update statement |
          +---------------------------------*/

         arp_cma_pkg.construct_cma_update_stmt(l_update_statement);

         l_update_statement := l_update_statement || p_where_clause;

         /*-----------------------------------------------+
          |  Parse, bind, execute and close the statement |
          +-----------------------------------------------*/

         dbms_sql.parse(p_update_cursor,
                        l_update_statement,
                        dbms_sql.v7);

   END IF;

   arp_cma_pkg.bind_cma_variables(p_update_cursor, p_cma_rec);

  /*-----------------------------------------+
   |  Bind the variables in the where clause |
   +-----------------------------------------*/

   dbms_sql.bind_variable(p_update_cursor, ':where_1',
                          p_where1);

   l_count := dbms_sql.execute(p_update_cursor);

   arp_util.debug( to_char(l_count) || ' rows updated');


   /*------------------------------------------------------------+
    |  Raise the NO_DATA_FOUND exception if no rows were updated |
    +------------------------------------------------------------*/

   IF (l_count = 0)
   THEN RAISE NO_DATA_FOUND;
   END IF;


   arp_util.debug('arp_cma_pkg.generic_update()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_cma_pkg.generic_update()');
        arp_util.debug(l_update_statement);
        arp_util.debug('Error at character: ' ||
                           to_char(dbms_sql.last_error_position));
        RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_to_dummy							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure initializes all columns in the parameter cma record     |
 |    to the appropriate dummy value for its datatype.			     |
 |    									     |
 |    The dummy values are defined in the following package level constants: |
 |	AR_NUMBER_DUMMY							     |
 |	AR_DATE_DUMMY							     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    None						     |
 |              OUT:                                                         |
 |                    p_cma_rec   - The record to initialize		     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE set_to_dummy( p_cma_rec OUT NOCOPY ar_credit_memo_amounts%rowtype) IS

BEGIN

    arp_util.debug('arp_cma_pkg.set_to_dummy()+');

    p_cma_rec.credit_memo_amount_id 	:= AR_NUMBER_DUMMY;
    p_cma_rec.last_updated_by 		:= AR_NUMBER_DUMMY;
    p_cma_rec.last_update_date 		:= AR_DATE_DUMMY;
    p_cma_rec.last_update_login 	:= AR_NUMBER_DUMMY;
    p_cma_rec.created_by 		:= AR_NUMBER_DUMMY;
    p_cma_rec.creation_date 		:= AR_DATE_DUMMY;
    p_cma_rec.customer_trx_line_id 	:= AR_NUMBER_DUMMY;
    p_cma_rec.gl_date		 	:= AR_DATE_DUMMY;
    p_cma_rec.amount 			:= AR_NUMBER_DUMMY;
    p_cma_rec.program_application_id 	:= AR_NUMBER_DUMMY;
    p_cma_rec.program_id 		:= AR_NUMBER_DUMMY;
    p_cma_rec.program_update_date 	:= AR_DATE_DUMMY;
    p_cma_rec.request_id 		:= AR_NUMBER_DUMMY;

    arp_util.debug('arp_cma_pkg.set_to_dummy()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_cma_pkg.set_to_dummy()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_credit_memo_amounts row identified by      |
 |    p_credit_memo_amount_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_credit_memo_amount_id - identifies the row to lock     |
 |              OUT:                                                         |
 |                  None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_p( p_credit_memo_amount_id
                  IN ar_credit_memo_amounts.credit_memo_amount_id%type
                )
          IS

    l_credit_memo_amount_id
                    ar_credit_memo_amounts.credit_memo_amount_id%type;

BEGIN
    arp_util.debug('arp_cma_pkg.lock_p()+');


    SELECT        credit_memo_amount_id
    INTO          l_credit_memo_amount_id
    FROM          ar_credit_memo_amounts
    WHERE         credit_memo_amount_id = p_credit_memo_amount_id
    FOR UPDATE OF credit_memo_amount_id NOWAIT;

    arp_util.debug('arp_cma_pkg.lock_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
	    arp_util.debug( 'EXCEPTION: arp_cma_pkg.lock_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_f_ctl_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_credit_memo_amounts rows identified by     |
 |    p_customer_trx_line_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_customer_trx_line_id - identifies the rows to lock     |
 |              OUT:                                                         |
 |                  None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_f_ctl_id( p_customer_trx_line_id
                           IN ra_customer_trx_lines.customer_trx_line_id%type)
          IS

    CURSOR lock_c IS
    SELECT        credit_memo_amount_id
    FROM          ar_credit_memo_amounts
    WHERE         customer_trx_line_id = p_customer_trx_line_id
    FOR UPDATE OF credit_memo_amount_id NOWAIT;

BEGIN
    arp_util.debug('arp_cma_pkg.lock_f_ctl_id()+');

    OPEN lock_c;
    CLOSE lock_c;

    arp_util.debug('arp_cma_pkg.lock_f_ctl_id()-');

    EXCEPTION
        WHEN  OTHERS THEN
	    arp_util.debug( 'EXCEPTION: arp_cma_pkg.lock_f_ctl_id' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_fetch_p							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_credit_memo_amounts row identified	     |
 |    by the p_credit_memo_amount_id parameter and populates the             |
 |    p_cma_rec parameter with the row that was locked.		 	     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_credit_memo_amount_id - identifies the row to lock     |
 |              OUT:                                                         |
 |                  p_cma_rec			- contains the locked row    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_fetch_p( p_cma_rec IN OUT NOCOPY ar_credit_memo_amounts%rowtype,
                        p_credit_memo_amount_id IN
		ar_credit_memo_amounts.credit_memo_amount_id%type) IS

BEGIN
    arp_util.debug('arp_cma_pkg.lock_fetch_p()+');

    SELECT        *
    INTO          p_cma_rec
    FROM          ar_credit_memo_amounts
    WHERE         credit_memo_amount_id = p_credit_memo_amount_id
    FOR UPDATE OF credit_memo_amount_id NOWAIT;

    arp_util.debug('arp_cma_pkg.lock_fetch_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: arp_cma_pkg.lock_fetch_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_compare_p							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_credit_memo_amounts row identified         |
 |    by the p_credit_memo_amount_id parameter only if no columns in         |
 |    that row have changed from when they were first selected in the form.  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_credit_memo_amount_id - identifies the row to lock      |
 | 		   p_cma_rec    	- cma record for comparison	     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_compare_p( p_cma_rec IN ar_credit_memo_amounts%rowtype,
                          p_credit_memo_amount_id IN
                  ar_credit_memo_amounts.credit_memo_amount_id%type) IS

    l_new_cma_rec  ar_credit_memo_amounts%rowtype;

BEGIN
    arp_util.debug('arp_cma_pkg.lock_compare_p()+');

    SELECT *
    INTO   l_new_cma_rec
    FROM   ar_credit_memo_amounts cma
    WHERE  cma.credit_memo_amount_id = p_credit_memo_amount_id
    AND
        (
           NVL(cma.credit_memo_amount_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_cma_rec.credit_memo_amount_id,
                        AR_NUMBER_DUMMY, cma.credit_memo_amount_id,
                                         p_cma_rec.credit_memo_amount_id),
                        AR_NUMBER_DUMMY
              )
         AND
           NVL(cma.last_updated_by, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_cma_rec.last_updated_by,
                        AR_NUMBER_DUMMY, cma.last_updated_by,
                                         p_cma_rec.last_updated_by),
                        AR_NUMBER_DUMMY
              )
         AND
           NVL(cma.last_update_date, AR_DATE_DUMMY) =
           NVL(
                 DECODE(p_cma_rec.last_update_date,
                        AR_DATE_DUMMY, cma.last_update_date,
                                         p_cma_rec.last_update_date),
                        AR_DATE_DUMMY
              )
         AND
           NVL(cma.last_update_login, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_cma_rec.last_update_login,
                        AR_NUMBER_DUMMY, cma.last_update_login,
                                         p_cma_rec.last_update_login),
                        AR_NUMBER_DUMMY
              )
         AND
           NVL(cma.created_by, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_cma_rec.created_by,
                        AR_NUMBER_DUMMY, cma.created_by,
                                         p_cma_rec.created_by),
                        AR_NUMBER_DUMMY
              )
         AND
           NVL(cma.creation_date, AR_DATE_DUMMY) =
           NVL(
                 DECODE(p_cma_rec.creation_date,
                        AR_DATE_DUMMY, cma.creation_date,
                                         p_cma_rec.creation_date),
                        AR_DATE_DUMMY
              )
         AND
           NVL(cma.customer_trx_line_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_cma_rec.customer_trx_line_id,
                        AR_NUMBER_DUMMY, cma.customer_trx_line_id,
                                         p_cma_rec.customer_trx_line_id),
                        AR_NUMBER_DUMMY
              )
         AND
           NVL(cma.gl_date, AR_DATE_DUMMY) =
           NVL(
                 DECODE(p_cma_rec.gl_date,
                        AR_DATE_DUMMY, cma.gl_date,
                                         p_cma_rec.gl_date),
                        AR_DATE_DUMMY
              )
         AND
           NVL(cma.amount, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_cma_rec.amount,
                        AR_NUMBER_DUMMY, cma.amount,
                                         p_cma_rec.amount),
                        AR_NUMBER_DUMMY
              )
         AND
           NVL(cma.program_application_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_cma_rec.program_application_id,
                        AR_NUMBER_DUMMY, cma.program_application_id,
                                         p_cma_rec.program_application_id),
                        AR_NUMBER_DUMMY
              )
         AND
           NVL(cma.program_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_cma_rec.program_id,
                        AR_NUMBER_DUMMY, cma.program_id,
                                         p_cma_rec.program_id),
                        AR_NUMBER_DUMMY
              )
         AND
           NVL(cma.program_update_date, AR_DATE_DUMMY) =
           NVL(
                 DECODE(p_cma_rec.program_update_date,
                        AR_DATE_DUMMY, cma.program_update_date,
                                         p_cma_rec.program_update_date),
                        AR_DATE_DUMMY
              )
         AND
           NVL(cma.request_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_cma_rec.request_id,
                        AR_NUMBER_DUMMY, cma.request_id,
                                         p_cma_rec.request_id),
                        AR_NUMBER_DUMMY
              )
       )
    FOR UPDATE OF credit_memo_amount_id NOWAIT;

    arp_util.debug('arp_cma_pkg.lock_compare_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: arp_cma_pkg.lock_compare_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    fetch_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure fetches a single row from ar_credit_memo_amounts        |
 |    into a variable specified as a parameter based on the table's primary  |
 |    key, credit_memo_amount_id					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              p_credit_memo_amount_id - identifies the record to fetch     |
 |              OUT:                                                         |
 |                    p_cma_rec  - contains the fetched record	     	     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE fetch_p( p_cma_rec         OUT NOCOPY ar_credit_memo_amounts%rowtype,
                   p_credit_memo_amount_id IN
                     ar_credit_memo_amounts.credit_memo_amount_id%type)
          IS

BEGIN
    arp_util.debug('arp_cma_pkg.fetch_p()+');

    SELECT *
    INTO   p_cma_rec
    FROM   ar_credit_memo_amounts
    WHERE  credit_memo_amount_id = p_credit_memo_amount_id;

    arp_util.debug('arp_cma_pkg.fetch_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: arp_cma_pkg.fetch_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ar_credit_memo_amounts row identified       |
 |    by the p_credit_memo_amount_id parameter.			             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              p_credit_memo_amount_id  - identifies the rows to delete     |
 |              OUT:                                                         |
 |              None						             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

procedure delete_p( p_credit_memo_amount_id
                IN ar_credit_memo_amounts.credit_memo_amount_id%type)
       IS


BEGIN


   arp_util.debug('arp_cma_pkg.delete_p()+');

   DELETE FROM ar_credit_memo_amounts
   WHERE       credit_memo_amount_id = p_credit_memo_amount_id;

   arp_util.debug('arp_cma_pkg.delete_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_cma_pkg.delete_p()');

	RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_f_ctl_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ar_credit_memo_amounts rows identified      |
 |    by the p_customer_trx_line_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |        	    p_customer_trx_line_id  - identifies the rows to delete  |
 |              OUT:                                                         |
 |                  None					             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

procedure delete_f_ctl_id( p_customer_trx_line_id
                         IN ra_customer_trx_lines.customer_trx_line_id%type)
       IS


BEGIN


   arp_util.debug('arp_cma_pkg.delete_f_ctl_id()+');

   DELETE FROM ar_credit_memo_amounts
   WHERE       customer_trx_line_id = p_customer_trx_line_id;

   arp_util.debug('arp_cma_pkg.delete_f_ctl_id()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_cma_pkg.delete_f_ctl_id()');

	RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_f_ct_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ar_credit_memo_amounts rows identified      |
 |    by the p_customer_trx_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |        	    p_customer_trx_id  - identifies the transactions
 |                      for which we then delete all CMA rows
 |              OUT:                                                         |
 |                  None					             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     11-APR-2003   M RAYMOND     Created                                |
 |                                                                           |
 +===========================================================================*/

procedure delete_f_ct_id( p_customer_trx_id
                         IN ra_customer_trx.customer_trx_id%type)
       IS


BEGIN

   arp_util.debug('arp_cma_pkg.delete_f_ct_id()+');

   DELETE FROM ar_credit_memo_amounts
   WHERE       customer_trx_line_id IN
       (SELECT customer_trx_line_id
        FROM   ra_customer_trx_lines
        WHERE  customer_trx_id = p_customer_trx_id);

   arp_util.debug('arp_cma_pkg.delete_f_ct_id()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_cma_pkg.delete_f_ct_id()');

	RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ar_credit_memo_amounts row identified       |
 |    by the p_credit_memo_amount_id parameter.			             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |               p_credit_memo_amount_id - identifies the row to update      |
 |               p_cma_rec                 - contains the new column values  |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_cma_rec are        |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_p( p_cma_rec IN ar_credit_memo_amounts%rowtype,
                    p_credit_memo_amount_id  IN
                     ar_credit_memo_amounts.credit_memo_amount_id%type)
          IS


BEGIN

   arp_util.debug('arp_cma_pkg.update_p()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));

   arp_cma_pkg.generic_update(  pg_cursor1,
			       ' WHERE credit_memo_amount_id = :where_1',
                               p_credit_memo_amount_id,
                               p_cma_rec);

   arp_util.debug('arp_cma_pkg.update_p()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_cma_pkg.update_p()');
        RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_f_ctl_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ar_credit_memo_amounts rows identified      |
 |    by the p_customer_trx_line_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |               p_customer_trx_line_id	    - identifies the rows to update  |
 |               p_cma_rec                 - contains the new column values  |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_cma_rec are        |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_f_ctl_id( p_cma_rec IN ar_credit_memo_amounts%rowtype,
                           p_customer_trx_line_id  IN
                               ra_customer_trx_lines.customer_trx_line_id%type)
          IS


BEGIN

   arp_util.debug('arp_cma_pkg.update_f_ctl_id()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));

   arp_cma_pkg.generic_update(  pg_cursor3,
			       ' WHERE customer_trx_line_id = :where_1',
                               p_customer_trx_line_id,
                               p_cma_rec);

   arp_util.debug('arp_cma_pkg.update_f_ctl_id()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_cma_pkg.update_f_ctl_id()');
        RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure inserts a row into ar_credit_memo_amounts that          |
 |    contains the column values specified in the p_cma_rec parameter.       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_cma_rec            - contains the new column values  |
 |              OUT:                                                         |
 |                    p_credit_memo_amount_id - unique ID of the new row     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_p(
             p_cma_rec          IN ar_credit_memo_amounts%rowtype,
             p_credit_memo_amount_id
                  OUT NOCOPY ar_credit_memo_amounts.credit_memo_amount_id%type

                  ) IS


    l_credit_memo_amount_id
                    ar_credit_memo_amounts.credit_memo_amount_id%type;


BEGIN

    arp_util.debug('arp_cma_pkg.insert_p()+');

    p_credit_memo_amount_id := '';

    /*---------------------------*
     | Get the unique identifier |
     *---------------------------*/

        SELECT AR_CREDIT_MEMO_AMOUNTS_S.NEXTVAL
        INTO   l_credit_memo_amount_id
        FROM   DUAL;


    /*-------------------*
     | Insert the record |
     *-------------------*/

     INSERT INTO ar_credit_memo_amounts
       (
          credit_memo_amount_id,
          customer_trx_line_id,
          gl_date,
          amount,
          last_updated_by,
          last_update_date,
          last_update_login,
          created_by,
          creation_date,
          program_application_id,
          program_id,
          program_update_date,
          request_id
       )
       VALUES
       (
          l_credit_memo_amount_id,
          p_cma_rec.customer_trx_line_id,
          p_cma_rec.gl_date,
          p_cma_rec.amount,
          pg_user_id,			/* last_updated_by */
          sysdate,   			/* last_update_date */
          nvl(pg_conc_login_id,
             pg_login_id),		/* last_update_login */
          pg_user_id,			/* created_by */
          sysdate, 			/* creation_date */
          pg_prog_appl_id,		/* program_application_id */
	  pg_conc_program_id,		/* program_id */
          sysdate,			/* program_update_date */
          p_cma_rec.request_id
       );



   p_credit_memo_amount_id := l_credit_memo_amount_id;

   arp_util.debug('arp_cma_pkg.insert_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_cma_pkg.insert_p()');
	RAISE;
END;


  /*---------------------------------------------+
   |   Package initialization section.           |
   |   Sets WHO column variables for later use.  |
   +---------------------------------------------*/

BEGIN

  pg_user_id          := fnd_global.user_id;
  pg_conc_login_id    := fnd_global.conc_login_id;
  pg_login_id         := fnd_global.login_id;
  pg_prog_appl_id     := fnd_global.prog_appl_id;
  pg_conc_program_id  := fnd_global.conc_program_id;


END ARP_CMA_PKG;

/
