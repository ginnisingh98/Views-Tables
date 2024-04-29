--------------------------------------------------------
--  DDL for Package Body ARP_ADJUSTMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_ADJUSTMENTS_PKG" AS
/* $Header: ARTIADJB.pls 120.7.12010000.2 2008/11/19 06:01:43 pbapna ship $ */

pg_base_curr_code     gl_sets_of_books.currency_code%type;
pg_base_precision     fnd_currencies.precision%type;
pg_base_min_acc_unit  fnd_currencies.minimum_accountable_unit%type;

pg_msg_level_debug   binary_integer;

  /*--------------------------------------------------------+
   |  Dummy constants for use in update and lock operations |
   +--------------------------------------------------------*/

  AR_TEXT_DUMMY   CONSTANT VARCHAR2(10) := '~~!@#$*&^';
  AR_TEXT3_DUMMY  CONSTANT VARCHAR2(10) := '~!@';
  AR_FLAG_DUMMY   CONSTANT VARCHAR2(10) := '~';
  AR_NUMBER_DUMMY CONSTANT NUMBER(15)   := -999999999999999;
  AR_DATE_DUMMY   CONSTANT DATE         := to_date(1, 'J');

  /*---------------------------------------------------------------+
   |  Package global variables to hold the parsed update cursors.  |
   |  This allows the cursors to be reused without being reparsed. |
   +---------------------------------------------------------------*/

  pg_cursor1  integer := NULL;
  pg_cursor2  integer := NULL;
  pg_cursor3  integer := NULL;
  pg_cursor4  integer := NULL;
  pg_cursor5  integer := NULL;

  /*-------------------------------------+
   |  WHO column values from FND_GLOBAL  |
   +-------------------------------------*/

  pg_conc_login_id    number;
  pg_login_id         number;
  pg_prog_appl_id     number;
  pg_conc_program_id  number;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    bind_adj_variables                                                     |
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
 |                    p_adj_rec       - ar_adjustments record  		     |
 |		      p_exchange_rate					     |
 |		      p_currency_code					     |
 |		      p_precision					     |
 |		      p_mau						     |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 |     03-FEB-00  Saloni Shah         Changes made for BR/BOE project.       |
 |                                    Need to get the value of accounting    |
 |                                    affect flag for the receivables trx    |
 |                                    to set the postable flag.              |
 |     20/11/2001 Veena Rao	      Bug 2098727 last_update_date is now    |
 |					set to sysdate in procedure          |
 |					construct_adj_update_stmt.           |
 |					Deleted the lines which bound        |
 |					last_update_date in this procedure   |
 |                                                                           |
 +===========================================================================*/


PROCEDURE bind_adj_variables(p_update_cursor IN integer,
                             p_adj_rec       IN ar_adjustments%rowtype,
                             p_exchange_rate IN
                                      ar_payment_schedules.exchange_rate%type,
                             p_currency_code IN
                                      fnd_currencies.currency_code%type,
                             p_precision     IN fnd_currencies.precision%type,
                             p_mau           IN
                               fnd_currencies.minimum_accountable_unit%type)
          IS

l_accounting_affect_flag ar_receivables_trx.accounting_affect_flag%type;
l_adj_post_to_gl_flag    ra_cust_trx_types.adj_post_to_gl%type;

BEGIN

   arp_util.debug('arp_adjustments_pkg.bind_adj_variables()+');


  /*----------------------------------------+
   |  Rounding and exchange rate variables  |
   +----------------------------------------*/

/*
  9/18/96 H.Kaukovuo
  Commented out NOCOPY because calculating accounted amount cannot be done
  at this level!

   dbms_sql.bind_variable(p_update_cursor, ':exchange_rate',
                          p_exchange_rate);

   dbms_sql.bind_variable(p_update_cursor, ':currency_code',
                          p_currency_code);

   dbms_sql.bind_variable(p_update_cursor, ':precision',
                          p_precision);

   dbms_sql.bind_variable(p_update_cursor, ':mau',
                          p_mau);
*/


  /*--------------------------------------------+
   |  Change made for BR/BOE project.           |
   |  Get the value for accounting_affect_flag  |
   +--------------------------------------------*/

     /*Bug 7461503 Changes for adjustment posting */
        SELECT decode(ctt.post_to_gl,'Y','Y' ,nvl(ctt.adj_post_to_gl,'N'))
        INTO   l_adj_post_to_gl_flag
        FROM   ra_customer_trx ct,ra_cust_trx_types ctt
        WHERE  ct.customer_trx_id=p_adj_rec.customer_trx_id
        AND    ctt.cust_trx_type_id=ct.cust_trx_type_id;

     IF l_adj_post_to_gl_flag  = 'Y' THEN
       SELECT NVL(accounting_affect_flag , 'Y')
       INTO  l_accounting_affect_flag
       FROM  ar_receivables_trx
       WHERE receivables_trx_id = p_adj_rec.receivables_trx_id;

     ELSE
        l_accounting_affect_flag := 'N';
     END IF;


  /*------------------+
   |  Dummy constants |
   +------------------*/

   dbms_sql.bind_variable(p_update_cursor, ':ar_text_dummy',
                          AR_TEXT_DUMMY);

   dbms_sql.bind_variable(p_update_cursor, ':ar_text3_dummy',
                          AR_TEXT3_DUMMY);

   dbms_sql.bind_variable(p_update_cursor, ':ar_flag_dummy',
                          AR_FLAG_DUMMY);

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


   /*---------------------------------------------+
    | Change made for BR/BOE project              |
    | Bind accounting_affect_flag.                |
    +---------------------------------------------*/

   dbms_sql.bind_variable(p_update_cursor, ':accounting_affect_flag',
                          l_accounting_affect_flag);

   dbms_sql.bind_variable(p_update_cursor, ':adjustment_id',
                          p_adj_rec.adjustment_id);

   dbms_sql.bind_variable(p_update_cursor, ':amount',
                          p_adj_rec.amount);

   -- 9/18/96 H.Kaukovuo	Added for bug fix 403019
   dbms_sql.bind_variable(p_update_cursor, ':acctd_amount',
                          p_adj_rec.acctd_amount);

   dbms_sql.bind_variable(p_update_cursor, ':apply_date',
                          p_adj_rec.apply_date);

   dbms_sql.bind_variable(p_update_cursor, ':gl_date',
                          p_adj_rec.gl_date);

   dbms_sql.bind_variable(p_update_cursor, ':gl_posted_date',
                          p_adj_rec.gl_posted_date);

   dbms_sql.bind_variable(p_update_cursor, ':set_of_books_id',
                          p_adj_rec.set_of_books_id);

   dbms_sql.bind_variable(p_update_cursor, ':code_combination_id',
                          p_adj_rec.code_combination_id);

   dbms_sql.bind_variable(p_update_cursor, ':type',
                          p_adj_rec.type);

   dbms_sql.bind_variable(p_update_cursor, ':adjustment_type',
                          p_adj_rec.adjustment_type);

   dbms_sql.bind_variable(p_update_cursor, ':status',
                          p_adj_rec.status);

   dbms_sql.bind_variable(p_update_cursor, ':line_adjusted',
                          p_adj_rec.line_adjusted);

   dbms_sql.bind_variable(p_update_cursor, ':freight_adjusted',
                          p_adj_rec.freight_adjusted);

   dbms_sql.bind_variable(p_update_cursor, ':tax_adjusted',
                          p_adj_rec.tax_adjusted);

   dbms_sql.bind_variable(p_update_cursor, ':receivables_charges_adjusted',
                          p_adj_rec.receivables_charges_adjusted);

   dbms_sql.bind_variable(p_update_cursor, ':batch_id',
                          p_adj_rec.batch_id);

   dbms_sql.bind_variable(p_update_cursor, ':customer_trx_id',
                          p_adj_rec.customer_trx_id);

   dbms_sql.bind_variable(p_update_cursor, ':subsequent_trx_id',
                          p_adj_rec.subsequent_trx_id);

   dbms_sql.bind_variable(p_update_cursor, ':customer_trx_line_id',
                          p_adj_rec.customer_trx_line_id);

   dbms_sql.bind_variable(p_update_cursor, ':associated_cash_receipt_id',
                          p_adj_rec.associated_cash_receipt_id);

   dbms_sql.bind_variable(p_update_cursor, ':chargeback_customer_trx_id',
                          p_adj_rec.chargeback_customer_trx_id);

   dbms_sql.bind_variable(p_update_cursor, ':payment_schedule_id',
                          p_adj_rec.payment_schedule_id);

   dbms_sql.bind_variable(p_update_cursor, ':receivables_trx_id',
                          p_adj_rec.receivables_trx_id);

   dbms_sql.bind_variable(p_update_cursor, ':distribution_set_id',
                          p_adj_rec.distribution_set_id);

   dbms_sql.bind_variable(p_update_cursor, ':associated_application_id',
                          p_adj_rec.associated_application_id);

   dbms_sql.bind_variable(p_update_cursor, ':comments',
                          p_adj_rec.comments);

   dbms_sql.bind_variable(p_update_cursor, ':automatically_generated',
                          p_adj_rec.automatically_generated);

   dbms_sql.bind_variable(p_update_cursor, ':created_from',
                          p_adj_rec.created_from);

   dbms_sql.bind_variable(p_update_cursor, ':reason_code',
                          p_adj_rec.reason_code);

   dbms_sql.bind_variable(p_update_cursor, ':adjustment_number',
                          p_adj_rec.adjustment_number);

   dbms_sql.bind_variable(p_update_cursor, ':doc_sequence_value',
                          p_adj_rec.doc_sequence_value);

   dbms_sql.bind_variable(p_update_cursor, ':doc_sequence_id',
                          p_adj_rec.doc_sequence_id);

   dbms_sql.bind_variable(p_update_cursor, ':ussgl_transaction_code',
                          p_adj_rec.ussgl_transaction_code);

   dbms_sql.bind_variable(p_update_cursor, ':ussgl_transaction_code_context',
                          p_adj_rec.ussgl_transaction_code_context);

   dbms_sql.bind_variable(p_update_cursor, ':attribute_category',
                          p_adj_rec.attribute_category);

   dbms_sql.bind_variable(p_update_cursor, ':attribute1',
                          p_adj_rec.attribute1);

   dbms_sql.bind_variable(p_update_cursor, ':attribute2',
                          p_adj_rec.attribute2);

   dbms_sql.bind_variable(p_update_cursor, ':attribute3',
                          p_adj_rec.attribute3);

   dbms_sql.bind_variable(p_update_cursor, ':attribute4',
                          p_adj_rec.attribute4);

   dbms_sql.bind_variable(p_update_cursor, ':attribute5',
                          p_adj_rec.attribute5);

   dbms_sql.bind_variable(p_update_cursor, ':attribute6',
                          p_adj_rec.attribute6);

   dbms_sql.bind_variable(p_update_cursor, ':attribute7',
                          p_adj_rec.attribute7);

   dbms_sql.bind_variable(p_update_cursor, ':attribute8',
                          p_adj_rec.attribute8);

   dbms_sql.bind_variable(p_update_cursor, ':attribute9',
                          p_adj_rec.attribute9);

   dbms_sql.bind_variable(p_update_cursor, ':attribute10',
                          p_adj_rec.attribute10);

   dbms_sql.bind_variable(p_update_cursor, ':attribute11',
                          p_adj_rec.attribute11);

   dbms_sql.bind_variable(p_update_cursor, ':attribute12',
                          p_adj_rec.attribute12);

   dbms_sql.bind_variable(p_update_cursor, ':attribute13',
                          p_adj_rec.attribute13);

   dbms_sql.bind_variable(p_update_cursor, ':attribute14',
                          p_adj_rec.attribute14);

   dbms_sql.bind_variable(p_update_cursor, ':attribute15',
                          p_adj_rec.attribute15);

   dbms_sql.bind_variable(p_update_cursor, ':posting_control_id',
                          p_adj_rec.posting_control_id);

   dbms_sql.bind_variable(p_update_cursor, ':last_update_login',
                          p_adj_rec.last_update_login);

   dbms_sql.bind_variable(p_update_cursor, ':created_by',
                          p_adj_rec.created_by);

   dbms_sql.bind_variable(p_update_cursor, ':creation_date',
                          p_adj_rec.creation_date);

   dbms_sql.bind_variable(p_update_cursor, ':program_application_id',
                          p_adj_rec.program_application_id);

   dbms_sql.bind_variable(p_update_cursor, ':program_id',
                          p_adj_rec.program_id);

   dbms_sql.bind_variable(p_update_cursor, ':program_update_date',
                          p_adj_rec.program_update_date);

   dbms_sql.bind_variable(p_update_cursor, ':request_id',
                          p_adj_rec.request_id);

   arp_util.debug('arp_adjustments_pkg.bind_adj_variables()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_adjustments_pkg.bind_adj_variables()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    construct_adj_update_stmt 					     |
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
 |    This statement only updates columns in the srep record that do not     |
 |    contain the dummy values that indicate that they should not be changed.|
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |     9/18/1996  Harri Kaukovuo      Bug fix 403019. Procedure was always
 |				      recalculating accounted amount (the
 |				      wrong way, BTW).
 |     20/11/2001 Veena Rao	      Bug 2098727 last_update_date should be |
 |					set to sysdate. This is in compliance|
 |					with INSERT operation now.           |
 +===========================================================================*/

PROCEDURE construct_adj_update_stmt( update_text OUT NOCOPY varchar2) IS


BEGIN

   arp_util.debug('arp_adjustments_pkg.construct_adj_update_stmt()+');

   update_text :=
 'UPDATE ar_adjustments
   SET    adjustment_id =
               DECODE(:adjustment_id,
                      :ar_number_dummy, adjustment_id,
                                        :adjustment_id),
          amount =
               DECODE(:amount,
                      :ar_number_dummy, amount,
                                        :amount),
          acctd_amount =
	       DECODE (:acctd_amount
			, :ar_number_dummy, acctd_amount
			, :acctd_amount),
          apply_date =
               DECODE(:apply_date,
                      :ar_date_dummy, apply_date,
                                        :apply_date),
          gl_date =
               DECODE(:gl_date,
                      :ar_date_dummy, gl_date,
                                        :gl_date),
          gl_posted_date =
               DECODE(:gl_posted_date,
                      :ar_date_dummy, gl_posted_date,
                                        :gl_posted_date),
          set_of_books_id =
               DECODE(:set_of_books_id,
                      :ar_number_dummy, set_of_books_id,
                                        :set_of_books_id),
          code_combination_id =
               DECODE(:code_combination_id,
                      :ar_number_dummy, code_combination_id,
                                        :code_combination_id),
          type =
               DECODE(:type,
                      :ar_text_dummy, type,
                                        :type),
          adjustment_type =
               DECODE(:adjustment_type,
                      :ar_text3_dummy, adjustment_type,
                                        :adjustment_type),
          status =
               DECODE(:status,
                      :ar_text_dummy, status,
                                        :status),
          line_adjusted =
               DECODE(:line_adjusted,
                      :ar_number_dummy, line_adjusted,
                                        :line_adjusted),
          freight_adjusted =
               DECODE(:freight_adjusted,
                      :ar_number_dummy, freight_adjusted,
                                        :freight_adjusted),
          tax_adjusted =
               DECODE(:tax_adjusted,
                      :ar_number_dummy, tax_adjusted,
                                        :tax_adjusted),
          receivables_charges_adjusted =
               DECODE(:receivables_charges_adjusted,
                      :ar_number_dummy, receivables_charges_adjusted,
                                        :receivables_charges_adjusted),
          batch_id =
               DECODE(:batch_id,
                      :ar_number_dummy, batch_id,
                                        :batch_id),
          customer_trx_id =
               DECODE(:customer_trx_id,
                      :ar_number_dummy, customer_trx_id,
                                        :customer_trx_id),
          subsequent_trx_id =
               DECODE(:subsequent_trx_id,
                      :ar_number_dummy, subsequent_trx_id,
                                        :subsequent_trx_id),
          customer_trx_line_id =
               DECODE(:customer_trx_line_id,
                      :ar_number_dummy, customer_trx_line_id,
                                        :customer_trx_line_id),
          associated_cash_receipt_id =
               DECODE(:associated_cash_receipt_id,
                      :ar_number_dummy, associated_cash_receipt_id,
                                        :associated_cash_receipt_id),
          chargeback_customer_trx_id =
               DECODE(:chargeback_customer_trx_id,
                      :ar_number_dummy, chargeback_customer_trx_id,
                                        :chargeback_customer_trx_id),
          payment_schedule_id =
               DECODE(:payment_schedule_id,
                      :ar_number_dummy, payment_schedule_id,
                                        :payment_schedule_id),
          receivables_trx_id =
               DECODE(:receivables_trx_id,
                      :ar_number_dummy, receivables_trx_id,
                                        :receivables_trx_id),
          distribution_set_id =
               DECODE(:distribution_set_id,
                      :ar_number_dummy, distribution_set_id,
                                        :distribution_set_id),
          associated_application_id =
               DECODE(:associated_application_id,
                      :ar_number_dummy, associated_application_id,
                                        :associated_application_id),
          comments =
               DECODE(:comments,
                      :ar_text_dummy, comments,
                                        :comments),
          automatically_generated =
               DECODE(:automatically_generated,
                      :ar_flag_dummy, automatically_generated,
                                        :automatically_generated),
          created_from =
               DECODE(:created_from,
                      :ar_text_dummy, created_from,
                                        :created_from),
          reason_code =
               DECODE(:reason_code,
                      :ar_text_dummy, reason_code,
                                        :reason_code),

          postable = DECODE(
                              DECODE(:status,
                                     :ar_text_dummy, status,
                                                     :status ),
                             ''A'', DECODE(NVL(:accounting_affect_flag,''Y''), ''N'', ''N'',''Y''),
                                   ''N''
                           ),

          approved_by =
                  DECODE(
                           DECODE(:adjustment_type,
                                  :ar_text3_dummy, adjustment_type,
                                                   :adjustment_type),
                           ''C'', NULL,
                                DECODE(
                                         DECODE(:status,
                                                :ar_text_dummy, status,
                                                                :status),
                                        ''A'', :pg_user_id,
                                             NULL
                                      )
                       ),
          adjustment_number =
               DECODE(:adjustment_number,
                      :ar_text_dummy, adjustment_number,
                                        :adjustment_number),
          doc_sequence_value =
               DECODE(:doc_sequence_value,
                      :ar_number_dummy, doc_sequence_value,
                                        :doc_sequence_value),
          doc_sequence_id =
               DECODE(:doc_sequence_id,
                      :ar_number_dummy, doc_sequence_id,
                                        :doc_sequence_id),
          ussgl_transaction_code =
               DECODE(:ussgl_transaction_code,
                      :ar_text_dummy, ussgl_transaction_code,
                                        :ussgl_transaction_code),
          ussgl_transaction_code_context =
               DECODE(:ussgl_transaction_code_context,
                      :ar_text_dummy, ussgl_transaction_code_context,
                                        :ussgl_transaction_code_context),
          attribute_category =
               DECODE(:attribute_category,
                      :ar_text_dummy, attribute_category,
                                        :attribute_category),
          attribute1 =
               DECODE(:attribute1,
                      :ar_text_dummy, attribute1,
                                        :attribute1),
          attribute2 =
               DECODE(:attribute2,
                      :ar_text_dummy, attribute2,
                                        :attribute2),
          attribute3 =
               DECODE(:attribute3,
                      :ar_text_dummy, attribute3,
                                        :attribute3),
          attribute4 =
               DECODE(:attribute4,
                      :ar_text_dummy, attribute4,
                                        :attribute4),
          attribute5 =
               DECODE(:attribute5,
                      :ar_text_dummy, attribute5,
                                        :attribute5),
          attribute6 =
               DECODE(:attribute6,
                      :ar_text_dummy, attribute6,
                                        :attribute6),
          attribute7 =
               DECODE(:attribute7,
                      :ar_text_dummy, attribute7,
                                        :attribute7),
          attribute8 =
               DECODE(:attribute8,
                      :ar_text_dummy, attribute8,
                                        :attribute8),
          attribute9 =
               DECODE(:attribute9,
                      :ar_text_dummy, attribute9,
                                        :attribute9),
          attribute10 =
               DECODE(:attribute10,
                      :ar_text_dummy, attribute10,
                                        :attribute10),
          attribute11 =
               DECODE(:attribute11,
                      :ar_text_dummy, attribute11,
                                        :attribute11),
          attribute12 =
               DECODE(:attribute12,
                      :ar_text_dummy, attribute12,
                                        :attribute12),
          attribute13 =
               DECODE(:attribute13,
                      :ar_text_dummy, attribute13,
                                        :attribute13),
          attribute14 =
               DECODE(:attribute14,
                      :ar_text_dummy, attribute14,
                                        :attribute14),
          attribute15 =
               DECODE(:attribute15,
                      :ar_text_dummy, attribute15,
                                        :attribute15),
          posting_control_id =
               DECODE(:posting_control_id,
                      :ar_number_dummy, posting_control_id,
                                        :posting_control_id),
          last_updated_by =
             NVL(
                  DECODE(
                           DECODE(:adjustment_type,
                                  :ar_text3_dummy, adjustment_type,
                                                   :adjustment_type),
                           ''C'', NULL,
                                DECODE(
                                         DECODE(:status,
                                                :ar_text_dummy, status,
                                                                :status),
                                        ''A'', :pg_user_id,
                                             NULL
                                      )
                        ),    -- approved_by
                  :pg_user_id
                ),
          last_update_date =  sysdate , --Bug 2098727

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
                      :ar_date_dummy, program_update_date,
                                        :program_update_date),
          request_id =
               DECODE(:request_id,
                      :ar_number_dummy, request_id,
                                        :request_id)';

   arp_util.debug('arp_adjustments_pkg.construct_adj_update_stmt()-');

EXCEPTION
    WHEN OTHERS THEN
       arp_util.debug('EXCEPTION:  arp_adjustments_pkg.construct_adj_update_stmt()');
       RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    generic_update                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This procedure Updates records in ar_adjustments  	             |
 |     identified by the where clause that is passed in as a parameter. Only |
 |     those columns in the srep record parameter that do not contain the    |
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
 |                    p_exchange_rate                                        |
 |		      p_adj_rec        - contains the new srep values        |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE generic_update(p_update_cursor IN OUT NOCOPY integer,
			 p_where_clause  IN varchar2,
			 p_where1        IN number,
                         p_exchange_rate IN
                                       ar_payment_schedules.exchange_rate%type,
                         p_adj_rec       IN ar_adjustments%rowtype)
          IS

   l_count             number;
   l_update_statement  varchar2(25000);
   l_adj_key_value_list   gl_ca_utility_pkg.r_key_value_arr;
   adj_array   dbms_sql.number_table;

BEGIN
   arp_util.debug('arp_adjustments_pkg.generic_update()+');

   arp_util.debug('');
   arp_util.debug('-------- parameters for generic_update() ------');

   arp_util.debug('p_update_cursor      = ' || p_update_cursor);
   arp_util.debug('p_where_clause       = ' || p_where_clause);
   arp_util.debug('p_where1             = ' || p_where1);
   arp_util.debug('p_exchange_rate      = ' || p_exchange_rate);

   arp_adjustments_pkg.display_adj_rec(p_adj_rec);

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

         arp_adjustments_pkg.construct_adj_update_stmt(l_update_statement);

         l_update_statement := l_update_statement || p_where_clause;

         /*  add on mrc variables for bulk collect */
         l_update_statement := l_update_statement ||
             ' RETURNING adjustment_id INTO :adj_key_value ';

         /*-----------------------------------------------+
          |  Parse, bind, execute and close the statement |
          +-----------------------------------------------*/

         dbms_sql.parse(p_update_cursor,
                        l_update_statement,
                        dbms_sql.v7);

   END IF;

   arp_adjustments_pkg.bind_adj_variables(p_update_cursor,
                                  p_adj_rec,
                                  p_exchange_rate,
                                  pg_base_curr_code,
                                  pg_base_precision,
                                  pg_base_min_acc_unit);

  /*---------------------------+
   | Bind output variable      |
   +---------------------------*/
   dbms_sql.bind_array(p_update_cursor,':adj_key_value',
                          adj_array);

  /*-----------------------------------------+
   |  Bind the variables in the where clause |
   +-----------------------------------------*/

   dbms_sql.bind_variable(p_update_cursor, ':where_1',
                          p_where1);

   l_count := dbms_sql.execute(p_update_cursor);

   arp_util.debug( to_char(l_count) || ' rows updated');

   /*------------------------------------------+
    | get RETURNING COLUMN into OUT NOCOPY bind array |
    +------------------------------------------*/

    dbms_sql.variable_value( p_update_cursor, ':adj_key_value', adj_array);


   /*------------------------------------------------------------+
    |  Raise the NO_DATA_FOUND exception if no rows were updated |
    +------------------------------------------------------------*/

   IF   (l_count = 0)
   THEN RAISE NO_DATA_FOUND;
   END IF;

--{BUG4301323
--    FOR I in adj_array.FIRST..adj_array.LAST LOOP
       /*---------------------------------------------+
        | call mrc engine to update AR_MC_ADJUSTMENTS |
        +---------------------------------------------*/
--       ar_mrc_engine.maintain_mrc_data(
--                        p_event_mode       => 'UPDATE',
--                        p_table_name       => 'AR_ADJUSTMENTS',
--                        p_mode             => 'SINGLE',
--                        p_key_value        => adj_array(I));
--   END LOOP;


   arp_util.debug('arp_adjustments_pkg.generic_update()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_adjustments_pkg.generic_update()');

        arp_util.debug('');
        arp_util.debug('-------- parameters for generic_update() ------');

        arp_util.debug('p_update_cursor      = ' || p_update_cursor);
        arp_util.debug('p_where_clause       = ' || p_where_clause);
        arp_util.debug('p_where1             = ' || p_where1);
        arp_adjustments_pkg.display_adj_rec(p_adj_rec);

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
 |    This procedure initializes all columns in the parameter srep record    |
 |    to the appropriate dummy value for its datatype.			     |
 |    									     |
 |    The dummy values are defined in the following package level constants: |
 |	AR_TEXT_DUMMY 							     |
 |	AR_TEXT3_DUMMY 							     |
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
 |                    p_adj_rec   - The record to initialize		     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE set_to_dummy( p_adj_rec OUT NOCOPY ar_adjustments%rowtype) IS

BEGIN

    arp_util.debug('arp_adjustments_pkg.set_to_dummy()+');

    p_adj_rec.adjustment_id			:= AR_NUMBER_DUMMY;
    p_adj_rec.amount				:= AR_NUMBER_DUMMY;
    p_adj_rec.acctd_amount			:= AR_NUMBER_DUMMY;
    p_adj_rec.apply_date			:= AR_DATE_DUMMY;
    p_adj_rec.gl_date				:= AR_DATE_DUMMY;
    p_adj_rec.gl_posted_date			:= AR_DATE_DUMMY;
    p_adj_rec.set_of_books_id			:= AR_NUMBER_DUMMY;
    p_adj_rec.code_combination_id		:= AR_NUMBER_DUMMY;
    p_adj_rec.type				:= AR_TEXT_DUMMY;
    p_adj_rec.adjustment_type			:= AR_TEXT3_DUMMY;
    p_adj_rec.status				:= AR_TEXT_DUMMY;
    p_adj_rec.line_adjusted			:= AR_NUMBER_DUMMY;
    p_adj_rec.freight_adjusted			:= AR_NUMBER_DUMMY;
    p_adj_rec.tax_adjusted			:= AR_NUMBER_DUMMY;
    p_adj_rec.receivables_charges_adjusted	:= AR_NUMBER_DUMMY;
    p_adj_rec.batch_id				:= AR_NUMBER_DUMMY;
    p_adj_rec.customer_trx_id			:= AR_NUMBER_DUMMY;
    p_adj_rec.subsequent_trx_id			:= AR_NUMBER_DUMMY;
    p_adj_rec.customer_trx_line_id		:= AR_NUMBER_DUMMY;
    p_adj_rec.associated_cash_receipt_id	:= AR_NUMBER_DUMMY;
    p_adj_rec.chargeback_customer_trx_id	:= AR_NUMBER_DUMMY;
    p_adj_rec.payment_schedule_id		:= AR_NUMBER_DUMMY;
    p_adj_rec.receivables_trx_id		:= AR_NUMBER_DUMMY;
    p_adj_rec.distribution_set_id		:= AR_NUMBER_DUMMY;
    p_adj_rec.associated_application_id		:= AR_NUMBER_DUMMY;
    p_adj_rec.comments				:= AR_TEXT_DUMMY;
    p_adj_rec.automatically_generated		:= AR_FLAG_DUMMY;
    p_adj_rec.created_from			:= AR_TEXT_DUMMY;
    p_adj_rec.reason_code			:= AR_TEXT_DUMMY;
    p_adj_rec.postable				:= AR_FLAG_DUMMY;
    p_adj_rec.approved_by			:= AR_NUMBER_DUMMY;
    p_adj_rec.adjustment_number			:= AR_TEXT_DUMMY;
    p_adj_rec.doc_sequence_value		:= AR_NUMBER_DUMMY;
    p_adj_rec.doc_sequence_id			:= AR_NUMBER_DUMMY;
    p_adj_rec.ussgl_transaction_code		:= AR_TEXT_DUMMY;
    p_adj_rec.ussgl_transaction_code_context	:= AR_TEXT_DUMMY;
    p_adj_rec.attribute_category		:= AR_TEXT_DUMMY;
    p_adj_rec.attribute1			:= AR_TEXT_DUMMY;
    p_adj_rec.attribute2			:= AR_TEXT_DUMMY;
    p_adj_rec.attribute3			:= AR_TEXT_DUMMY;
    p_adj_rec.attribute4			:= AR_TEXT_DUMMY;
    p_adj_rec.attribute5			:= AR_TEXT_DUMMY;
    p_adj_rec.attribute6			:= AR_TEXT_DUMMY;
    p_adj_rec.attribute7			:= AR_TEXT_DUMMY;
    p_adj_rec.attribute8			:= AR_TEXT_DUMMY;
    p_adj_rec.attribute9			:= AR_TEXT_DUMMY;
    p_adj_rec.attribute10			:= AR_TEXT_DUMMY;
    p_adj_rec.attribute11			:= AR_TEXT_DUMMY;
    p_adj_rec.attribute12			:= AR_TEXT_DUMMY;
    p_adj_rec.attribute13			:= AR_TEXT_DUMMY;
    p_adj_rec.attribute14			:= AR_TEXT_DUMMY;
    p_adj_rec.attribute15			:= AR_TEXT_DUMMY;
    p_adj_rec.posting_control_id		:= AR_NUMBER_DUMMY;
    p_adj_rec.last_updated_by			:= AR_NUMBER_DUMMY;
    p_adj_rec.last_update_date			:= AR_DATE_DUMMY;
    p_adj_rec.last_update_login			:= AR_NUMBER_DUMMY;
    p_adj_rec.created_by			:= AR_NUMBER_DUMMY;
    p_adj_rec.creation_date			:= AR_DATE_DUMMY;
    p_adj_rec.program_application_id		:= AR_NUMBER_DUMMY;
    p_adj_rec.program_id			:= AR_NUMBER_DUMMY;
    p_adj_rec.program_update_date		:= AR_DATE_DUMMY;
    p_adj_rec.request_id			:= AR_NUMBER_DUMMY;

    arp_util.debug('arp_adjustments_pkg.set_to_dummy()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_adjustments_pkg.set_to_dummy()');
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_adjustments row identified by  |
 |    p_adjustment_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_adjustment_id - identifies the row to lock |
 |              OUT:                                                         |
 |                  None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_p( p_adjustment_id IN ar_adjustments.adjustment_id%type
                )
          IS

    l_adjustment_id  ar_adjustments.adjustment_id%type;

BEGIN
    arp_util.debug('arp_adjustments_pkg.lock_p()+');


    SELECT        adjustment_id
    INTO          l_adjustment_id
    FROM          ar_adjustments
    WHERE         adjustment_id = p_adjustment_id
    FOR UPDATE OF adjustment_id NOWAIT;

    arp_util.debug('arp_adjustments_pkg.lock_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
	    arp_util.debug( 'EXCEPTION: arp_adjustments_pkg.lock_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_f_ct_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_adjustments rows identified by  	     |
 |    p_customer_trx_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_customer_trx_id 	- identifies the rows to lock	     |
 |              OUT:                                                         |
 |                  None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_f_ct_id( p_customer_trx_id
                           IN ra_customer_trx.customer_trx_id%type )
          IS

    CURSOR LOCK_C IS
    SELECT        adjustment_id
    FROM          ar_adjustments
    WHERE         customer_trx_id = p_customer_trx_id
    FOR UPDATE OF adjustment_id NOWAIT;


BEGIN
    arp_util.debug('arp_adjustments_pkg.lock_f_ct_id()+');

    OPEN lock_c;
    CLOSE lock_c;

    arp_util.debug('arp_adjustments_pkg.lock_f_ct_id()-');

    EXCEPTION
        WHEN  OTHERS THEN
	    arp_util.debug( 'EXCEPTION: arp_adjustments_pkg.lock_f_ct_id' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_f_st_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_adjustments rows identified by  	     |
 |    p_subsequent_trx_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                p_subsequent_trx_id - identifies the rows to lock	     |
 |              OUT:                                                         |
 |                  None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_f_st_id( p_subsequent_trx_id
                           IN ra_customer_trx.customer_trx_id%type )
          IS

    CURSOR LOCK_C IS
    SELECT        adjustment_id
    FROM          ar_adjustments
    WHERE         subsequent_trx_id = p_subsequent_trx_id
    FOR UPDATE OF adjustment_id NOWAIT;


BEGIN
    arp_util.debug('arp_adjustments_pkg.lock_f_st_id()+');

    OPEN lock_c;
    CLOSE lock_c;

    arp_util.debug('arp_adjustments_pkg.lock_f_st_id()-');

    EXCEPTION
        WHEN  OTHERS THEN
	    arp_util.debug( 'EXCEPTION: arp_adjustments_pkg.lock_f_st_id' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_f_ps_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_adjustments rows identified by  	     |
 |    p_payment_schedule_trx_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                p_payment_schedule_id - identifies the rows to lock	     |
 |              OUT:                                                         |
 |                  None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_f_ps_id( p_payment_schedule_id
                           IN ar_payment_schedules.payment_schedule_id%type )
          IS

    CURSOR LOCK_C IS
    SELECT        adjustment_id
    FROM          ar_adjustments
    WHERE         payment_schedule_id = p_payment_schedule_id
    FOR UPDATE OF adjustment_id NOWAIT;


BEGIN
    arp_util.debug('arp_adjustments_pkg.lock_f_ps_id()+');

    OPEN lock_c;
    CLOSE lock_c;

    arp_util.debug('arp_adjustments_pkg.lock_f_ps_id()-');

    EXCEPTION
        WHEN  OTHERS THEN
	    arp_util.debug( 'EXCEPTION: arp_adjustments_pkg.lock_f_ps_id' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_f_ctl_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_adjustments rows identified by 	     |
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
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_f_ctl_id( p_customer_trx_line_id
                           IN ra_customer_trx_lines.customer_trx_line_id%type)
          IS

    CURSOR lock_c IS
    SELECT        adjustment_id
    FROM          ar_adjustments
    WHERE         customer_trx_line_id = p_customer_trx_line_id
    FOR UPDATE OF adjustment_id NOWAIT;

BEGIN
    arp_util.debug('arp_adjustments_pkg.lock_f_ctl_id()+');

    OPEN lock_c;
    CLOSE lock_c;

    arp_util.debug('arp_adjustments_pkg.lock_f_ctl_id()-');

    EXCEPTION
        WHEN  OTHERS THEN
	    arp_util.debug( 'EXCEPTION: arp_adjustments_pkg.lock_f_ctl_id' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_fetch_p							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_adjustments row identified   		     |
 |    by the p_adjustment_id parameter and populates the         	     |
 |    p_adj_rec parameter with the row that was locked.		     	     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_adjustment_id - identifies the row to lock 	     |
 |              OUT:                                                         |
 |                  p_adj_rec			- contains the locked row    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_fetch_p( p_adj_rec IN OUT NOCOPY ar_adjustments%rowtype,
                        p_adjustment_id IN
		ar_adjustments.adjustment_id%type) IS

BEGIN
    arp_util.debug('arp_adjustments_pkg.lock_fetch_p()+');

    SELECT        *
    INTO          p_adj_rec
    FROM          ar_adjustments
    WHERE         adjustment_id = p_adjustment_id
    FOR UPDATE OF adjustment_id NOWAIT;

    arp_util.debug('arp_adjustments_pkg.lock_fetch_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: arp_adjustments_pkg.lock_fetch_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_compare_p							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_adjustments row identified 		     |
 |    by the p_adjustment_id parameter only if no columns in   		     |
 |    that row have changed from when they were first selected in the form.  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                 p_adjustment_id - identifies the row to lock 	     |
 | 		   p_adj_rec    	- srep record for comparison	     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_compare_p( p_adj_rec IN ar_adjustments%rowtype,
                          p_adjustment_id IN ar_adjustments.adjustment_id%type)
          IS

    l_new_adj_rec  ar_adjustments%rowtype;

BEGIN
    arp_util.debug('arp_adjustments_pkg.lock_compare_p()+');

    SELECT   *
    INTO     l_new_adj_rec
    FROM     ar_adjustments adj
    WHERE    adj.adjustment_id = p_adjustment_id
    AND
       (
           NVL(adj.adjustment_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.adjustment_id,
                        AR_NUMBER_DUMMY, adj.adjustment_id,
                                         p_adj_rec.adjustment_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.amount, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.amount,
                        AR_NUMBER_DUMMY, adj.amount,
                                         p_adj_rec.amount),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.acctd_amount, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.acctd_amount,
                        AR_NUMBER_DUMMY, adj.acctd_amount,
                                         p_adj_rec.acctd_amount),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(TRUNC(adj.apply_date), AR_DATE_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.apply_date,
                        AR_DATE_DUMMY, TRUNC(adj.apply_date),
                                         p_adj_rec.apply_date),
                 AR_DATE_DUMMY
              )
         AND
           NVL(TRUNC(adj.gl_date), AR_DATE_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.gl_date,
                        AR_DATE_DUMMY, TRUNC(adj.gl_date),
                                         p_adj_rec.gl_date),
                 AR_DATE_DUMMY
              )
         AND
           NVL(TRUNC(adj.gl_posted_date), AR_DATE_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.gl_posted_date,
                        AR_DATE_DUMMY, TRUNC(adj.gl_posted_date),
                                         p_adj_rec.gl_posted_date),
                 AR_DATE_DUMMY
              )
         AND
           NVL(adj.set_of_books_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.set_of_books_id,
                        AR_NUMBER_DUMMY, adj.set_of_books_id,
                                         p_adj_rec.set_of_books_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.code_combination_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.code_combination_id,
                        AR_NUMBER_DUMMY, adj.code_combination_id,
                                         p_adj_rec.code_combination_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.type, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.type,
                        AR_TEXT_DUMMY, adj.type,
                                         p_adj_rec.type),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.adjustment_type, AR_TEXT3_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.adjustment_type,
                        AR_TEXT3_DUMMY, adj.adjustment_type,
                                         p_adj_rec.adjustment_type),
                 AR_TEXT3_DUMMY
              )
         AND
           NVL(adj.status, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.status,
                        AR_TEXT_DUMMY, adj.status,
                                         p_adj_rec.status),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.line_adjusted, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.line_adjusted,
                        AR_NUMBER_DUMMY, adj.line_adjusted,
                                         p_adj_rec.line_adjusted),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.freight_adjusted, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.freight_adjusted,
                        AR_NUMBER_DUMMY, adj.freight_adjusted,
                                         p_adj_rec.freight_adjusted),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.tax_adjusted, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.tax_adjusted,
                        AR_NUMBER_DUMMY, adj.tax_adjusted,
                                         p_adj_rec.tax_adjusted),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.receivables_charges_adjusted, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.receivables_charges_adjusted,
                        AR_NUMBER_DUMMY, adj.receivables_charges_adjusted,
                                      p_adj_rec.receivables_charges_adjusted),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.batch_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.batch_id,
                        AR_NUMBER_DUMMY, adj.batch_id,
                                         p_adj_rec.batch_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.customer_trx_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.customer_trx_id,
                        AR_NUMBER_DUMMY, adj.customer_trx_id,
                                         p_adj_rec.customer_trx_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.subsequent_trx_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.subsequent_trx_id,
                        AR_NUMBER_DUMMY, adj.subsequent_trx_id,
                                         p_adj_rec.subsequent_trx_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.customer_trx_line_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.customer_trx_line_id,
                        AR_NUMBER_DUMMY, adj.customer_trx_line_id,
                                         p_adj_rec.customer_trx_line_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.associated_cash_receipt_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.associated_cash_receipt_id,
                        AR_NUMBER_DUMMY, adj.associated_cash_receipt_id,
                                         p_adj_rec.associated_cash_receipt_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.chargeback_customer_trx_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.chargeback_customer_trx_id,
                        AR_NUMBER_DUMMY, adj.chargeback_customer_trx_id,
                                         p_adj_rec.chargeback_customer_trx_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.payment_schedule_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.payment_schedule_id,
                        AR_NUMBER_DUMMY, adj.payment_schedule_id,
                                         p_adj_rec.payment_schedule_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.receivables_trx_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.receivables_trx_id,
                        AR_NUMBER_DUMMY, adj.receivables_trx_id,
                                         p_adj_rec.receivables_trx_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.distribution_set_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.distribution_set_id,
                        AR_NUMBER_DUMMY, adj.distribution_set_id,
                                         p_adj_rec.distribution_set_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.associated_application_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.associated_application_id,
                        AR_NUMBER_DUMMY, adj.associated_application_id,
                                         p_adj_rec.associated_application_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.comments, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.comments,
                        AR_TEXT_DUMMY, adj.comments,
                                         p_adj_rec.comments),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.automatically_generated, AR_FLAG_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.automatically_generated,
                        AR_FLAG_DUMMY, adj.automatically_generated,
                                         p_adj_rec.automatically_generated),
                 AR_FLAG_DUMMY
              )
         AND
           NVL(adj.created_from, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.created_from,
                        AR_TEXT_DUMMY, adj.created_from,
                                         p_adj_rec.created_from),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.reason_code, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.reason_code,
                        AR_TEXT_DUMMY, adj.reason_code,
                                         p_adj_rec.reason_code),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.postable, AR_FLAG_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.postable,
                        AR_FLAG_DUMMY, adj.postable,
                                         p_adj_rec.postable),
                 AR_FLAG_DUMMY
              )
         AND
           NVL(adj.approved_by, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.approved_by,
                        AR_NUMBER_DUMMY, adj.approved_by,
                                         p_adj_rec.approved_by),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.adjustment_number, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.adjustment_number,
                        AR_TEXT_DUMMY, adj.adjustment_number,
                                         p_adj_rec.adjustment_number),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.doc_sequence_value, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.doc_sequence_value,
                        AR_NUMBER_DUMMY, adj.doc_sequence_value,
                                         p_adj_rec.doc_sequence_value),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.doc_sequence_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.doc_sequence_id,
                        AR_NUMBER_DUMMY, adj.doc_sequence_id,
                                         p_adj_rec.doc_sequence_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.ussgl_transaction_code, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.ussgl_transaction_code,
                        AR_TEXT_DUMMY, adj.ussgl_transaction_code,
                                         p_adj_rec.ussgl_transaction_code),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.ussgl_transaction_code_context, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.ussgl_transaction_code_context,
                        AR_TEXT_DUMMY, adj.ussgl_transaction_code_context,
                                     p_adj_rec.ussgl_transaction_code_context),
                 AR_TEXT_DUMMY
              )
      )
   AND
      (
           NVL(adj.attribute_category, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.attribute_category,
                        AR_TEXT_DUMMY, adj.attribute_category,
                                         p_adj_rec.attribute_category),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.attribute1, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.attribute1,
                        AR_TEXT_DUMMY, adj.attribute1,
                                         p_adj_rec.attribute1),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.attribute2, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.attribute2,
                        AR_TEXT_DUMMY, adj.attribute2,
                                         p_adj_rec.attribute2),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.attribute3, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.attribute3,
                        AR_TEXT_DUMMY, adj.attribute3,
                                         p_adj_rec.attribute3),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.attribute4, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.attribute4,
                        AR_TEXT_DUMMY, adj.attribute4,
                                         p_adj_rec.attribute4),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.attribute5, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.attribute5,
                        AR_TEXT_DUMMY, adj.attribute5,
                                         p_adj_rec.attribute5),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.attribute6, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.attribute6,
                        AR_TEXT_DUMMY, adj.attribute6,
                                         p_adj_rec.attribute6),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.attribute7, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.attribute7,
                        AR_TEXT_DUMMY, adj.attribute7,
                                         p_adj_rec.attribute7),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.attribute8, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.attribute8,
                        AR_TEXT_DUMMY, adj.attribute8,
                                         p_adj_rec.attribute8),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.attribute9, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.attribute9,
                        AR_TEXT_DUMMY, adj.attribute9,
                                         p_adj_rec.attribute9),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.attribute10, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.attribute10,
                        AR_TEXT_DUMMY, adj.attribute10,
                                         p_adj_rec.attribute10),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.attribute11, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.attribute11,
                        AR_TEXT_DUMMY, adj.attribute11,
                                         p_adj_rec.attribute11),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.attribute12, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.attribute12,
                        AR_TEXT_DUMMY, adj.attribute12,
                                         p_adj_rec.attribute12),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.attribute13, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.attribute13,
                        AR_TEXT_DUMMY, adj.attribute13,
                                         p_adj_rec.attribute13),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.attribute14, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.attribute14,
                        AR_TEXT_DUMMY, adj.attribute14,
                                         p_adj_rec.attribute14),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.attribute15, AR_TEXT_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.attribute15,
                        AR_TEXT_DUMMY, adj.attribute15,
                                         p_adj_rec.attribute15),
                 AR_TEXT_DUMMY
              )
         AND
           NVL(adj.posting_control_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.posting_control_id,
                        AR_NUMBER_DUMMY, adj.posting_control_id,
                                         p_adj_rec.posting_control_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.last_updated_by, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.last_updated_by,
                        AR_NUMBER_DUMMY, adj.last_updated_by,
                                         p_adj_rec.last_updated_by),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(TRUNC(adj.last_update_date), AR_DATE_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.last_update_date,
                        AR_DATE_DUMMY, TRUNC(adj.last_update_date),
                                         p_adj_rec.last_update_date),
                 AR_DATE_DUMMY
              )
         AND
           NVL(adj.last_update_login, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.last_update_login,
                        AR_NUMBER_DUMMY, adj.last_update_login,
                                         p_adj_rec.last_update_login),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.created_by, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.created_by,
                        AR_NUMBER_DUMMY, adj.created_by,
                                         p_adj_rec.created_by),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(TRUNC(adj.creation_date), AR_DATE_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.creation_date,
                        AR_DATE_DUMMY, TRUNC(adj.creation_date),
                                         p_adj_rec.creation_date),
                 AR_DATE_DUMMY
              )
         AND
           NVL(adj.program_application_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.program_application_id,
                        AR_NUMBER_DUMMY, adj.program_application_id,
                                         p_adj_rec.program_application_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(adj.program_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.program_id,
                        AR_NUMBER_DUMMY, adj.program_id,
                                         p_adj_rec.program_id),
                 AR_NUMBER_DUMMY
              )
         AND
           NVL(TRUNC(adj.program_update_date), AR_DATE_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.program_update_date,
                        AR_DATE_DUMMY, TRUNC(adj.program_update_date),
                                         p_adj_rec.program_update_date),
                 AR_DATE_DUMMY
              )
         AND
           NVL(adj.request_id, AR_NUMBER_DUMMY) =
           NVL(
                 DECODE(p_adj_rec.request_id,
                        AR_NUMBER_DUMMY, adj.request_id,
                                         p_adj_rec.request_id),
                 AR_NUMBER_DUMMY
              )
       )
    FOR UPDATE OF adjustment_id NOWAIT;


    arp_util.debug('arp_adjustments_pkg.lock_compare_p()-');

    EXCEPTION
        WHEN  NO_DATA_FOUND THEN
                arp_util.debug(
             'EXCEPTION: arp_adjustments_pkg.l.lock_compare_p NO_DATA_FOUND' );

                arp_util.debug('');
                arp_util.debug('============= Old Record =============');
                display_adj_p(p_adjustment_id);
                arp_util.debug('');
                arp_util.debug('============= New Record =============');
                display_adj_rec(p_adj_rec);

                FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
                APP_EXCEPTION.Raise_Exception;

        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: arp_adjustments_pkg.lock_compare_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    lock_compare_cover                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure locks the ar_adjustments row identified                 |
 |    by the p_adjustment_id parameter only if no columns in                 |
 |    that row have changed from when they were first selected in the form.  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_adjustment_id                                          |
 |                  p_amount                                                 |
 |                  p_acctd_amount                                           |
 |                  p_apply_date                                             |
 |                  p_gl_date                                                |
 |                  p_gl_posted_date                                         |
 |                  p_set_of_books_id                                        |
 |                  p_code_combination_id                                    |
 |                  p_type                                                   |
 |                  p_adjustment_type                                        |
 |                  p_status                                                 |
 |                  p_line_adjusted                                          |
 |                  p_freight_adjusted                                       |
 |                  p_tax_adjusted                                           |
 |                  p_receivables_charges_adj                                |
 |                  p_batch_id                                               |
 |                  p_customer_trx_id                                        |
 |                  p_subsequent_trx_id                                      |
 |                  p_customer_trx_line_id                                   |
 |                  p_associated_cash_receipt_id                             |
 |                  p_chargeback_customer_trx_id                             |
 |                  p_payment_schedule_id                                    |
 |                  p_receivables_trx_id                                     |
 |                  p_distribution_set_id                                    |
 |                  p_associated_application_id                              |
 |                  p_comments                                               |
 |                  p_automatically_generated                                |
 |                  p_created_from                                           |
 |                  p_reason_code                                            |
 |                  p_postable                                               |
 |                  p_approved_by                                            |
 |                  p_adjustment_number                                      |
 |                  p_doc_sequence_value                                     |
 |                  p_doc_sequence_id                                        |
 |                  p_ussgl_transaction_code                                 |
 |                  p_ussgl_trans_code_context                               |
 |                  p_attribute_category                                     |
 |                  p_attribute1                                             |
 |                  p_attribute2                                             |
 |                  p_attribute3                                             |
 |                  p_attribute4                                             |
 |                  p_attribute5                                             |
 |                  p_attribute6                                             |
 |                  p_attribute7                                             |
 |                  p_attribute8                                             |
 |                  p_attribute9                                             |
 |                  p_attribute10                                            |
 |                  p_attribute11                                            |
 |                  p_attribute12                                            |
 |                  p_attribute13                                            |
 |                  p_attribute14                                            |
 |                  p_attribute15                                            |
 |                  p_posting_control_id                                     |
 |                  p_last_updated_by                                        |
 |                  p_last_update_date                                       |
 |                  p_last_update_login                                      |
 |                  p_created_by                                             |
 |                  p_creation_date                                          |
 |                  p_program_application_id                                 |
 |                  p_program_id                                             |
 |                  p_program_update_date                                    |
 |                  p_request_id                                             |
 |              OUT:                                                         |
 |                  None                                                     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-JUL-96  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE lock_compare_cover(
                              p_adjustment_id                   IN number,
                              p_amount                          IN number,
                              p_acctd_amount                    IN number,
                              p_apply_date                      IN date,
                              p_gl_date                         IN date,
                              p_gl_posted_date                  IN date,
                              p_set_of_books_id                 IN number,
                              p_code_combination_id             IN number,
                              p_type                            IN varchar2,
                              p_adjustment_type                 IN varchar2,
                              p_status                          IN varchar2,
                              p_line_adjusted                   IN number,
                              p_freight_adjusted                IN number,
                              p_tax_adjusted                    IN number,
                              p_receivables_charges_adj         IN number,
                              p_batch_id                        IN number,
                              p_customer_trx_id                 IN number,
                              p_subsequent_trx_id               IN number,
                              p_customer_trx_line_id            IN number,
                              p_associated_cash_receipt_id      IN number,
                              p_chargeback_customer_trx_id      IN number,
                              p_payment_schedule_id             IN number,
                              p_receivables_trx_id              IN number,
                              p_distribution_set_id             IN number,
                              p_associated_application_id       IN number,
                              p_comments                        IN varchar2,
                              p_automatically_generated         IN varchar2,
                              p_created_from                    IN varchar2,
                              p_reason_code                     IN varchar2,
                              p_postable                        IN varchar2,
                              p_approved_by                     IN number,
                              p_adjustment_number               IN varchar2,
                              p_doc_sequence_value              IN number,
                              p_doc_sequence_id                 IN number,
                              p_ussgl_transaction_code          IN varchar2,
                              p_ussgl_trans_code_context        IN varchar2,
                              p_attribute_category              IN varchar2,
                              p_attribute1                      IN varchar2,
                              p_attribute2                      IN varchar2,
                              p_attribute3                      IN varchar2,
                              p_attribute4                      IN varchar2,
                              p_attribute5                      IN varchar2,
                              p_attribute6                      IN varchar2,
                              p_attribute7                      IN varchar2,
                              p_attribute8                      IN varchar2,
                              p_attribute9                      IN varchar2,
                              p_attribute10                     IN varchar2,
                              p_attribute11                     IN varchar2,
                              p_attribute12                     IN varchar2,
                              p_attribute13                     IN varchar2,
                              p_attribute14                     IN varchar2,
                              p_attribute15                     IN varchar2,
                              p_posting_control_id              IN number,
                              p_last_updated_by                 IN number,
                              p_last_update_date                IN date,
                              p_last_update_login               IN number,
                              p_created_by                      IN number,
                              p_creation_date                   IN date,
                              p_program_application_id          IN number,
                              p_program_id                      IN number,
                              p_program_update_date             IN date,
                              p_request_id                      IN number )
          IS

    l_adj_rec  ar_adjustments%rowtype;

BEGIN
    arp_util.debug('arp_adjustments_pkg.lock_compare_cover()+');

  /*----------------------------------------------------+
   |  Populate the adjustment record with the values    |
   |  passed in as parameters.                          |
   +----------------------------------------------------*/

   set_to_dummy(l_adj_rec);


    l_adj_rec.adjustment_id                     := p_adjustment_id;
    l_adj_rec.amount                            := p_amount;
    l_adj_rec.acctd_amount                      := p_acctd_amount;
    l_adj_rec.apply_date                        := p_apply_date;
    l_adj_rec.gl_date                           := p_gl_date;
    l_adj_rec.gl_posted_date                    := p_gl_posted_date;
    l_adj_rec.set_of_books_id                   := p_set_of_books_id;
    l_adj_rec.code_combination_id               := p_code_combination_id;
    l_adj_rec.type                              := p_type;
    l_adj_rec.adjustment_type                   := p_adjustment_type;
    l_adj_rec.status                            := p_status;
    l_adj_rec.line_adjusted                     := p_line_adjusted;
    l_adj_rec.freight_adjusted                  := p_freight_adjusted;
    l_adj_rec.tax_adjusted                      := p_tax_adjusted;
    l_adj_rec.receivables_charges_adjusted      := p_receivables_charges_adj ;
    l_adj_rec.batch_id                          := p_batch_id;
    l_adj_rec.customer_trx_id                   := p_customer_trx_id;
    l_adj_rec.subsequent_trx_id                 := p_subsequent_trx_id;
    l_adj_rec.customer_trx_line_id              := p_customer_trx_line_id;
    l_adj_rec.associated_cash_receipt_id   := p_associated_cash_receipt_id;
    l_adj_rec.chargeback_customer_trx_id   := p_chargeback_customer_trx_id;
    l_adj_rec.payment_schedule_id               := p_payment_schedule_id;
    l_adj_rec.receivables_trx_id                := p_receivables_trx_id;
    l_adj_rec.distribution_set_id               := p_distribution_set_id;
    l_adj_rec.associated_application_id         := p_associated_application_id;
    l_adj_rec.comments                          := p_comments;
    l_adj_rec.automatically_generated           := p_automatically_generated;
    l_adj_rec.created_from                      := p_created_from;
    l_adj_rec.reason_code                       := p_reason_code;
    l_adj_rec.postable                          := p_postable;
    l_adj_rec.approved_by                       := p_approved_by;
    l_adj_rec.adjustment_number                 := p_adjustment_number;
    l_adj_rec.doc_sequence_value                := p_doc_sequence_value;
    l_adj_rec.doc_sequence_id                   := p_doc_sequence_id;
    l_adj_rec.ussgl_transaction_code            := p_ussgl_transaction_code;
    l_adj_rec.ussgl_transaction_code_context    := p_ussgl_trans_code_context;
    l_adj_rec.attribute_category                := p_attribute_category;
    l_adj_rec.attribute1                        := p_attribute1;
    l_adj_rec.attribute2                        := p_attribute2;
    l_adj_rec.attribute3                        := p_attribute3;
    l_adj_rec.attribute4                        := p_attribute4;
    l_adj_rec.attribute5                        := p_attribute5;
    l_adj_rec.attribute6                        := p_attribute6;
    l_adj_rec.attribute7                        := p_attribute7;
    l_adj_rec.attribute8                        := p_attribute8;
    l_adj_rec.attribute9                        := p_attribute9;
    l_adj_rec.attribute10                       := p_attribute10;
    l_adj_rec.attribute11                       := p_attribute11;
    l_adj_rec.attribute12                       := p_attribute12;
    l_adj_rec.attribute13                       := p_attribute13;
    l_adj_rec.attribute14                       := p_attribute14;
    l_adj_rec.attribute15                       := p_attribute15;
    l_adj_rec.posting_control_id                := p_posting_control_id;
    l_adj_rec.last_updated_by                   := p_last_updated_by;
    l_adj_rec.last_update_date                  := p_last_update_date;
    l_adj_rec.last_update_login                 := p_last_update_login;
    l_adj_rec.created_by                        := p_created_by;
    l_adj_rec.creation_date                     := p_creation_date;
    l_adj_rec.program_application_id            := p_program_application_id;
    l_adj_rec.program_id                        := p_program_id;
    l_adj_rec.program_update_date               := p_program_update_date;
    l_adj_rec.request_id                        := p_request_id;

  /*-----------------------------------------+
   |  Call the standard header table handler |
   +-----------------------------------------*/

   lock_compare_p( l_adj_rec, p_adjustment_id);

   arp_util.debug('arp_adjustments_pkg.lock_compare_cover()-');

EXCEPTION
  WHEN OTHERS THEN
    arp_util.debug('EXCEPTION : arp_adjustments_pkg.lock_compare_cover()');

    arp_util.debug('----- parameters for lock_compare_cover() ' ||
                   '-----');
    arp_util.debug('p_adjustment_id                     = ' ||
                   TO_CHAR(p_adjustment_id));
    arp_util.debug('p_amount                            = ' ||
                   TO_CHAR(p_amount));
    arp_util.debug('p_acctd_amount                      = ' ||
                   TO_CHAR(p_acctd_amount));
    arp_util.debug('p_apply_date                        = ' ||
                   TO_CHAR(p_apply_date, 'DD-MON-YYYY'));
    arp_util.debug('p_gl_date                           = ' ||
                   TO_CHAR(p_gl_date, 'DD-MON-YYYY'));
    arp_util.debug('p_gl_posted_date                    = ' ||
                   TO_CHAR(p_gl_posted_date, 'DD-MON-YYYY'));
    arp_util.debug('p_set_of_books_id                   = ' ||
                   TO_CHAR(p_set_of_books_id));
    arp_util.debug('p_code_combination_id               = ' ||
                   TO_CHAR(p_code_combination_id));
    arp_util.debug('p_type                              = ' ||
                   p_type);
    arp_util.debug('p_adjustment_type                   = ' ||
                   p_adjustment_type);
    arp_util.debug('p_status                            = ' ||
                   p_status);
    arp_util.debug('p_line_adjusted                     = ' ||
                   TO_CHAR(p_line_adjusted));
    arp_util.debug('p_freight_adjusted                  = ' ||
                   TO_CHAR(p_freight_adjusted));
    arp_util.debug('p_tax_adjusted                      = ' ||
                   TO_CHAR(p_tax_adjusted));
    arp_util.debug('p_receivables_charges_adj           = ' ||
                   TO_CHAR(p_receivables_charges_adj ));
    arp_util.debug('p_batch_id                          = ' ||
                   TO_CHAR(p_batch_id));
    arp_util.debug('p_customer_trx_id                   = ' ||
                   TO_CHAR(p_customer_trx_id));
    arp_util.debug('p_subsequent_trx_id                 = ' ||
                   TO_CHAR(p_subsequent_trx_id));
    arp_util.debug('p_customer_trx_line_id              = ' ||
                   TO_CHAR(p_customer_trx_line_id));
    arp_util.debug('p_associated_cash_receipt_id        = ' ||
                   TO_CHAR(p_associated_cash_receipt_id));
    arp_util.debug('p_chargeback_customer_trx_id        = ' ||
                   TO_CHAR(p_chargeback_customer_trx_id));
    arp_util.debug('p_payment_schedule_id               = ' ||
                   TO_CHAR(p_payment_schedule_id));
    arp_util.debug('p_receivables_trx_id                = ' ||
                   TO_CHAR(p_receivables_trx_id));
    arp_util.debug('p_distribution_set_id               = ' ||
                   TO_CHAR(p_distribution_set_id));
    arp_util.debug('p_associated_application_id         = ' ||
                   TO_CHAR(p_associated_application_id));
    arp_util.debug('p_comments                          = ' ||
                   p_comments);
    arp_util.debug('p_automatically_generated           = ' ||
                   p_automatically_generated);
    arp_util.debug('p_created_from                      = ' ||
                   p_created_from);
    arp_util.debug('p_reason_code                       = ' ||
                   p_reason_code);
    arp_util.debug('p_postable                          = ' ||
                   p_postable);
    arp_util.debug('p_approved_by                       = ' ||
                   TO_CHAR(p_approved_by));
    arp_util.debug('p_adjustment_number                 = ' ||
                   p_adjustment_number);
    arp_util.debug('p_doc_sequence_value                = ' ||
                   TO_CHAR(p_doc_sequence_value));
    arp_util.debug('p_doc_sequence_id                   = ' ||
                   TO_CHAR(p_doc_sequence_id));
    arp_util.debug('p_ussgl_transaction_code            = ' ||
                   p_ussgl_transaction_code);
    arp_util.debug('p_ussgl_trans_code_context          = ' ||
                   p_ussgl_trans_code_context);
    arp_util.debug('p_attribute_category                = ' ||
                   p_attribute_category);
    arp_util.debug('p_attribute1                        = ' ||
                   p_attribute1);
    arp_util.debug('p_attribute2                        = ' ||
                   p_attribute2);
    arp_util.debug('p_attribute3                        = ' ||
                   p_attribute3);
    arp_util.debug('p_attribute4                        = ' ||
                   p_attribute4);
    arp_util.debug('p_attribute5                        = ' ||
                   p_attribute5);
    arp_util.debug('p_attribute6                        = ' ||
                   p_attribute6);
    arp_util.debug('p_attribute7                        = ' ||
                   p_attribute7);
    arp_util.debug('p_attribute8                        = ' ||
                   p_attribute8);
    arp_util.debug('p_attribute9                        = ' ||
                   p_attribute9);
    arp_util.debug('p_attribute10                       = ' ||
                   p_attribute10);
    arp_util.debug('p_attribute11                       = ' ||
                   p_attribute11);
    arp_util.debug('p_attribute12                       = ' ||
                   p_attribute12);
    arp_util.debug('p_attribute13                       = ' ||
                   p_attribute13);
    arp_util.debug('p_attribute14                       = ' ||
                   p_attribute14);
    arp_util.debug('p_attribute15                       = ' ||
                   p_attribute15);
    arp_util.debug('p_posting_control_id                = ' ||
                   TO_CHAR(p_posting_control_id));
    arp_util.debug('p_last_updated_by                   = ' ||
                   TO_CHAR(p_last_updated_by));
    arp_util.debug('p_last_update_date                  = ' ||
                   TO_CHAR(p_last_update_date, 'DD-MON-YYYY'));
    arp_util.debug('p_last_update_login                 = ' ||
                   TO_CHAR(p_last_update_login));
    arp_util.debug('p_created_by                        = ' ||
                   TO_CHAR(p_created_by));
    arp_util.debug('p_creation_date                     = ' ||
                   TO_CHAR(p_creation_date, 'DD-MON-YYYY'));
    arp_util.debug('p_program_application_id            = ' ||
                   TO_CHAR(p_program_application_id));
    arp_util.debug('p_program_id                        = ' ||
                   TO_CHAR(p_program_id));
    arp_util.debug('p_program_update_date               = ' ||
                   TO_CHAR(p_program_update_date, 'DD-MON-YYYY'));
    arp_util.debug('p_request_id                        = ' ||
                   TO_CHAR(p_request_id));

    RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    fetch_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure fetches a single row from ar_adjustments  		     |
 |    into a variable specified as a parameter based on the table's primary  |
 |    key, adjustment_id					 	     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              p_adjustment_id - identifies the record to fetch 	     |
 |              OUT:                                                         |
 |                    p_adj_rec  - contains the fetched record	     	     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE fetch_p( p_adj_rec         OUT NOCOPY ar_adjustments%rowtype,
                   p_adjustment_id    IN ar_adjustments.adjustment_id%type)
          IS

BEGIN
    arp_util.debug('arp_adjustments_pkg.fetch_p()+');

    SELECT *
    INTO   p_adj_rec
    FROM   ar_adjustments
    WHERE  adjustment_id = p_adjustment_id;

    arp_util.debug('arp_adjustments_pkg.fetch_p()-');

    EXCEPTION
        WHEN  OTHERS THEN
            arp_util.debug( 'EXCEPTION: arp_adjustments_pkg.fetch_p' );
            RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ar_adjustments row identified 		     |
 |    by the p_adjustment_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              p_adjustment_id  - identifies the rows to delete	     |
 |              OUT:                                                         |
 |              None						             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |     16-OCT-00  Debbie Jancis       Added call to the central MRC library  |
 |                                    for MRC integration                    |
 |                                                                           |
 +===========================================================================*/

procedure delete_p( p_adjustment_id IN ar_adjustments.adjustment_id%type)
       IS


BEGIN


   arp_util.debug('arp_adjustments_pkg.delete_p()+');

   DELETE FROM ar_adjustments
   WHERE       adjustment_id = p_adjustment_id;

   /*---------------------------------+
    | Calling central MRC library     |
    | for MRC Integration             |
    +---------------------------------*/
/*BUG4301323
    ar_mrc_engine.maintain_mrc_data(
                        p_event_mode       => 'DELETE',
                        p_table_name       => 'AR_ADJUSTMENTS',
                        p_mode             => 'SINGLE',
                        p_key_value        => p_adjustment_id);
*/
   arp_util.debug('arp_adjustments_pkg.delete_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_adjustments_pkg.delete_p()');

	RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_f_ct_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ar_adjustments rows identified		     |
 |    by the p_customer_trx_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |           	      p_customer_trx_id  - identifies the rows to delete     |
 |              OUT:                                                         |
 |                    None					             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |     16-OCT-00  Debbie Jancis       Added call to the central MRC library  |
 |                                    for MRC integration                    |
 |                                                                           |
 +===========================================================================*/

procedure delete_f_ct_id( p_customer_trx_id
                            IN ra_customer_trx.customer_trx_id%type)
       IS

 l_adj_key_value_list  gl_ca_utility_pkg.r_key_value_arr;

BEGIN


   arp_util.debug('arp_adjustments_pkg.delete_f_ct_id()+');

   DELETE FROM ar_adjustments
   WHERE       customer_trx_id = p_customer_trx_id
   RETURNING adjustment_id
   BULK COLLECT INTO l_adj_key_value_list;

   /*---------------------------------+
    | Calling central MRC library     |
    | for MRC Integration             |
    +---------------------------------*/
/*4301323
    ar_mrc_engine.maintain_mrc_data(
                        p_event_mode       => 'DELETE',
                        p_table_name       => 'AR_ADJUSTMENTS',
                        p_mode             => 'BATCH',
                        p_key_value_list   => l_adj_key_value_list);
*/

   arp_util.debug('arp_adjustments_pkg.delete_f_ct_id()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_adjustments_pkg.delete_f_ct_id()');

	RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_f_st_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ar_adjustments rows identified		     |
 |    by the p_subsequent_trx_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |           	      p_subsequent_trx_id  - identifies the rows to delete   |
 |              OUT:                                                         |
 |                    None					             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |     16-OCT-00  Debbie Jancis       Added call to the central MRC library  |
 |                                    for MRC integration                    |
 |                                                                           |
 +===========================================================================*/

procedure delete_f_st_id( p_subsequent_trx_id
                            IN ra_customer_trx.customer_trx_id%type)
       IS

 l_adj_key_value_list  gl_ca_utility_pkg.r_key_value_arr;

BEGIN


   arp_util.debug('arp_adjustments_pkg.delete_f_st_id()+');

   DELETE FROM ar_adjustments
   WHERE       subsequent_trx_id = p_subsequent_trx_id
   RETURNING adjustment_id
   BULK COLLECT INTO l_adj_key_value_list;

   /*---------------------------------+
    | Calling central MRC library     |
    | for MRC Integration             |
    +---------------------------------*/
/*4301323
    ar_mrc_engine.maintain_mrc_data(
                        p_event_mode       => 'DELETE',
                        p_table_name       => 'AR_ADJUSTMENTS',
                        p_mode             => 'BATCH',
                        p_key_value_list   => l_adj_key_value_list);
*/

   arp_util.debug('arp_adjustments_pkg.delete_f_st_id()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_adjustments_pkg.delete_f_st_id()');

	RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_f_ps_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ar_adjustments rows identified		     |
 |    by the p_payment_schedule_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |           	      p_payment_schedule_id  - identifies the rows to delete |
 |              OUT:                                                         |
 |                    None					             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |     16-OCT-00  Debbie Jancis       Added call to the central MRC library  |
 |                                    for MRC integration                    |
 |                                                                           |
 +===========================================================================*/

procedure delete_f_ps_id( p_payment_schedule_id
                            IN ar_payment_schedules.payment_schedule_id%type)
       IS

 l_adj_key_value_list  gl_ca_utility_pkg.r_key_value_arr;

BEGIN


   arp_util.debug('arp_adjustments_pkg.delete_f_ps_id()+');

   DELETE FROM ar_adjustments
   WHERE       payment_schedule_id = p_payment_schedule_id
   RETURNING adjustment_id
   BULK COLLECT INTO l_adj_key_value_list;

   /*---------------------------------+
    | Calling central MRC library     |
    | for MRC Integration             |
    +---------------------------------*/
/*4301323
    ar_mrc_engine.maintain_mrc_data(
                        p_event_mode       => 'DELETE',
                        p_table_name       => 'AR_ADJUSTMENTS',
                        p_mode             => 'BATCH',
                        p_key_value_list   => l_adj_key_value_list);
*/

   arp_util.debug('arp_adjustments_pkg.delete_f_ps_id()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_adjustments_pkg.delete_f_ps_id()');

	RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_f_ctl_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes the ar_adjustments rows identified 	     |
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
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |     16-OCT-00  Debbie Jancis       Added call to the central MRC library  |
 |                                    for MRC integration                    |
 |                                                                           |
 +===========================================================================*/

procedure delete_f_ctl_id( p_customer_trx_line_id
                         IN ra_customer_trx_lines.customer_trx_line_id%type)
       IS

 l_adj_key_value_list  gl_ca_utility_pkg.r_key_value_arr;

BEGIN


   arp_util.debug('arp_adjustments_pkg.delete_f_ctl_id()+');

   DELETE FROM ar_adjustments
   WHERE       customer_trx_line_id = p_customer_trx_line_id
   RETURNING adjustment_id
   BULK COLLECT INTO l_adj_key_value_list;

   /*---------------------------------+
    | Calling central MRC library     |
    | for MRC Integration             |
    +---------------------------------*/
/*BUG4301323
    ar_mrc_engine.maintain_mrc_data(
                        p_event_mode       => 'DELETE',
                        p_table_name       => 'AR_ADJUSTMENTS',
                        p_mode             => 'BATCH',
                        p_key_value_list   => l_adj_key_value_list);
*/
   arp_util.debug('arp_adjustments_pkg.delete_f_ctl_id()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_adjustments_pkg.delete_f_ctl_id()');

	RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ar_adjustments row identified		     |
 |    by the p_adjustment_id parameter.					     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |               p_adjustment_id - identifies the row to update		     |
 |               p_exchange_rate                                             |
 |               p_adj_rec                 - contains the new column values  |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_adj_rec are        |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_p( p_adj_rec IN ar_adjustments%rowtype,
                    p_adjustment_id  IN  ar_adjustments.adjustment_id%type,
                    p_exchange_rate  IN ar_payment_schedules.exchange_rate%type
                  )
          IS


BEGIN

   arp_util.debug('arp_adjustments_pkg.update_p()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));

   arp_adjustments_pkg.generic_update(  pg_cursor1,
			       ' WHERE adjustment_id = :where_1',
                               p_adjustment_id,
                               p_exchange_rate,
                               p_adj_rec);

   arp_util.debug('arp_adjustments_pkg.update_p()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_adjustments_pkg.update_p()');
        RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_f_ct_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ar_adjustments rows identified		     |
 |    by the p_customer_trx_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |               p_customer_trx_id	    - identifies the rows to update  |
 |               p_exchange_rate                                             |
 |               p_adj_rec                 - contains the new column values  |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_adj_rec are        |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_f_ct_id( p_adj_rec IN ar_adjustments%rowtype,
                 p_customer_trx_id  IN ra_customer_trx.customer_trx_id%type,
                 p_exchange_rate  IN ar_payment_schedules.exchange_rate%type)
          IS


BEGIN

   arp_util.debug('arp_adjustments_pkg.update_f_ct_id()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));

   arp_adjustments_pkg.generic_update(  pg_cursor2,
			       ' WHERE customer_trx_id = :where_1',
                               p_customer_trx_id,
                               p_exchange_rate,
                               p_adj_rec);

   arp_util.debug('arp_adjustments_pkg.update_f_ct_id()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_adjustments_pkg.update_f_ct_id()');
        RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_f_st_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ar_adjustments rows identified		     |
 |    by the p_subsequent_trx_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |               p_subsequent_trx_id	    - identifies the rows to update  |
 |               p_exchange_rate                                             |
 |               p_adj_rec                 - contains the new column values  |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_adj_rec are        |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_f_st_id( p_adj_rec IN ar_adjustments%rowtype,
                 p_subsequent_trx_id  IN ra_customer_trx.customer_trx_id%type,
                 p_exchange_rate  IN ar_payment_schedules.exchange_rate%type)
          IS

BEGIN

   arp_util.debug('arp_adjustments_pkg.update_f_st_id()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));

   arp_adjustments_pkg.generic_update(  pg_cursor3,
			       ' WHERE subsequent_trx_id = :where_1',
                               p_subsequent_trx_id,
                               p_exchange_rate,
                               p_adj_rec);


   arp_util.debug('arp_adjustments_pkg.update_f_st_id()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_adjustments_pkg.update_f_st_id()');
        RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_f_ps_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ar_adjustments rows identified		     |
 |    by the p_payment_schedule_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |               p_payment_schedule_id	    - identifies the rows to update  |
 |               p_exchange_rate                                             |
 |               p_adj_rec                 - contains the new column values  |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_adj_rec are        |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_f_ps_id( p_adj_rec              IN ar_adjustments%rowtype,
                          p_payment_schedule_id  IN
                              ar_payment_schedules.payment_schedule_id%type,
                          p_exchange_rate        IN
                              ar_payment_schedules.exchange_rate%type)
          IS


BEGIN

   arp_util.debug('arp_adjustments_pkg.update_f_ps_id()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));

   arp_adjustments_pkg.generic_update(  pg_cursor4,
			       ' WHERE payment_schedule_id = :where_1',
                               p_payment_schedule_id,
                               p_exchange_rate,
                               p_adj_rec);

   arp_util.debug('arp_adjustments_pkg.update_f_ps_id()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_adjustments_pkg.update_f_ps_id()');
        RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_f_ctl_id							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure updates the ar_adjustments rows identified 	     |
 |    by the p_customer_trx_line_id parameter.				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |               p_customer_trx_line_id	    - identifies the rows to update  |
 |               p_exchange_rate                                             |
 |               p_adj_rec                 - contains the new column values  |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |     set_to_dummy must be called before the values in p_adj_rec are        |
 |     changed and this function is called.				     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_f_ctl_id( p_adj_rec IN ar_adjustments%rowtype,
                           p_customer_trx_line_id  IN
                               ra_customer_trx_lines.customer_trx_line_id%type,
                           p_exchange_rate         IN
                               ar_payment_schedules.exchange_rate%type)
          IS


BEGIN

   arp_util.debug('arp_adjustments_pkg.update_f_ctl_id()+  ' ||
                      to_char(sysdate, 'HH:MI:SS'));

   arp_adjustments_pkg.generic_update(  pg_cursor5,
			       ' WHERE customer_trx_line_id = :where_1',
                               p_customer_trx_line_id,
                               p_exchange_rate,
                               p_adj_rec);

   arp_util.debug('arp_adjustments_pkg.update_f_ctl_id()-  ' ||
                      to_char(sysdate, 'HH:MI:SS'));


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_adjustments_pkg.update_f_ctl_id()');
        RAISE;
END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_p								     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure inserts a row into ar_adjustments that   		     |
 |    contains the column values specified in the p_adj_rec parameter.       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_adj_rec            - contains the new column values  |
 |              OUT:                                                         |
 |                    p_adjustment_id - unique ID of the new row  	     |
 |                    p_adjustment_number                                    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-JUN-95  Charlie Tomberg     Created                                |
 |     24-AUG-95  Martin Johnson      Added parameter p_adjustment_number.   |
 |                                    Get adjustment_number from the sequence|
 |                                    Calculate acctd_amount if it's not     |
 |                                      passed in.                           |
 |     06-SEP-95  Martin Johnson      Replaced arp_standard.functional_amount|
 |                                      with arpcurr.functional_amount       |
 |                                                                           |
 |     03-FEB-00  Saloni Shah         Changes made for BR/BOE project.       |
 |                                    Need to get the value of accounting    |
 |                                    affect flag for the receivables trx    |
 |                                    to set the postable flag.              |
 |                                    The postable flag for an adjustment    |
 |                                    is set to 'N' if the                   |
 |                                    accounting_affect_flag of the          |
 |                                    receivables_trx is 'N'.                |
 |     15-OCT-00  Debbie Jancis       Enh:  MRC integration.   Called central|
 |                                    library for insertion of ar_adjustments|
 +===========================================================================*/

PROCEDURE insert_p( p_adj_rec            IN  ar_adjustments%rowtype,
                    p_exchange_rate      IN
                      ar_payment_schedules.exchange_rate%type,
                    p_adjustment_number OUT NOCOPY
                      ar_adjustments.adjustment_number%type,
                    p_adjustment_id     OUT NOCOPY  ar_adjustments.adjustment_id%type

                  ) IS

    l_adjustment_id     ar_adjustments.adjustment_id%type;
    l_adjustment_number ar_adjustments.adjustment_number%type;
    l_accounting_affect_flag ar_receivables_trx.accounting_affect_flag%type;
    l_adj_post_to_gl_flag    ra_cust_trx_types.adj_post_to_gl%type;

BEGIN

    arp_util.debug('arp_adjustments_pkg.insert_p()+');

    p_adjustment_id := NULL;
    p_adjustment_number := NULL;

    /*---------------------------*
     | Get the unique identifier |
     *---------------------------*/

        SELECT AR_ADJUSTMENTS_S.NEXTVAL,
               AR_ADJUSTMENT_NUMBER_S.NEXTVAL
        INTO   l_adjustment_id,
               l_adjustment_number
        FROM   DUAL;

       /*--------------------------------------------+
        |  Change made for BR/BOE project.           |
        |  Get the value for accounting_affect_flag  |
        +--------------------------------------------*/

          SELECT NVL(accounting_affect_flag , 'Y')
          INTO  l_accounting_affect_flag
          FROM  ar_receivables_trx
          WHERE receivables_trx_id = p_adj_rec.receivables_trx_id;

	/* Bug 7461503 get value of added flag in transaction types*/

	SELECT decode(ctt.post_to_gl,'Y','Y', nvl(ctt.adj_post_to_gl ,'N'))
        INTO   l_adj_post_to_gl_flag
	FROM   ra_customer_trx ct,ra_cust_trx_types ctt
        WHERE  ct.customer_trx_id=p_adj_rec.customer_trx_id
	AND    ctt.cust_trx_type_id=ct.cust_trx_type_id;


    /*-------------------*
     | Insert the record |
     *-------------------*/

      INSERT INTO ar_adjustments
       (
          adjustment_id,
          amount,
          acctd_amount,
          apply_date,
          gl_date,
          gl_posted_date,
          set_of_books_id,
          code_combination_id,
          type,
          adjustment_type,
          status,
          line_adjusted,
          freight_adjusted,
          tax_adjusted,
          receivables_charges_adjusted,
          batch_id,
          customer_trx_id,
          subsequent_trx_id,
          customer_trx_line_id,
          associated_cash_receipt_id,
          chargeback_customer_trx_id,
          payment_schedule_id,
          receivables_trx_id,
          distribution_set_id,
          associated_application_id,
          comments,
          automatically_generated,
          created_from,
          reason_code,
          postable,
          approved_by,
          adjustment_number,
          doc_sequence_value,
          doc_sequence_id,
          ussgl_transaction_code,
          ussgl_transaction_code_context,
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
          posting_control_id,
          last_updated_by,
          last_update_date,
          last_update_login,
          created_by,
          creation_date,
          program_application_id,
          program_id,
          program_update_date,
          request_id,org_id
--{Late Charge Project
,interest_header_id
,interest_line_id )
       VALUES
       (
         l_adjustment_id,
         p_adj_rec.amount,
         nvl(p_adj_rec.acctd_amount,
             decode(p_adj_rec.amount,
                    null, to_number(null),
                          arpcurr.functional_amount(
                                                    p_adj_rec.amount,
 				     		    pg_base_curr_code,
			  		            nvl(p_exchange_rate, 1),
					            pg_base_precision,
 					            pg_base_min_acc_unit)
                   )
            ),
         p_adj_rec.apply_date,
         p_adj_rec.gl_date,
         p_adj_rec.gl_posted_date,
         arp_global.set_of_books_id,
         p_adj_rec.code_combination_id,
         p_adj_rec.type,
         p_adj_rec.adjustment_type,
         p_adj_rec.status,
         p_adj_rec.line_adjusted,
         p_adj_rec.freight_adjusted,
         p_adj_rec.tax_adjusted,
         p_adj_rec.receivables_charges_adjusted,
         p_adj_rec.batch_id,
         p_adj_rec.customer_trx_id,
         p_adj_rec.subsequent_trx_id,
         p_adj_rec.customer_trx_line_id,
         p_adj_rec.associated_cash_receipt_id,
         p_adj_rec.chargeback_customer_trx_id,
         p_adj_rec.payment_schedule_id,
         p_adj_rec.receivables_trx_id,
         p_adj_rec.distribution_set_id,
         p_adj_rec.associated_application_id,
         p_adj_rec.comments,
         p_adj_rec.automatically_generated,
         p_adj_rec.created_from,
         p_adj_rec.reason_code,
     /*-----------------------------------------+
      |  The postable flag for an adjustment    |
      |  is set to 'N' if the                   |
      |  accounting_affect_flag of the          |
      |  receivables_trx is 'N'.                |
      +-----------------------------------------*/
      /* bug 7461503 added logic to select postable value based on new flag in transaction type*/
         decode(p_adj_rec.status,
                'A',decode(NVL(l_adj_post_to_gl_flag,'N'),'Y',decode(NVL(l_accounting_affect_flag,'Y'), 'N','N','Y'),'N'),
                     'N'),
         nvl(p_adj_rec.approved_by,
             decode(p_adj_rec.adjustment_type,
                    'C', null,
                         decode(p_adj_rec.status,
                                'A', pg_user_id,
                                     null))),
         l_adjustment_number,
         p_adj_rec.doc_sequence_value,
         p_adj_rec.doc_sequence_id,
         p_adj_rec.ussgl_transaction_code,
         p_adj_rec.ussgl_transaction_code_context,
         p_adj_rec.attribute_category,
         p_adj_rec.attribute1,
         p_adj_rec.attribute2,
         p_adj_rec.attribute3,
         p_adj_rec.attribute4,
         p_adj_rec.attribute5,
         p_adj_rec.attribute6,
         p_adj_rec.attribute7,
         p_adj_rec.attribute8,
         p_adj_rec.attribute9,
         p_adj_rec.attribute10,
         p_adj_rec.attribute11,
         p_adj_rec.attribute12,
         p_adj_rec.attribute13,
         p_adj_rec.attribute14,
         p_adj_rec.attribute15,
         -3,
         pg_user_id,			/* last_updated_by */
         sysdate,			/*last_update_date */
         nvl(pg_conc_login_id,
             pg_login_id),		/* last_update_login */
         pg_user_id,			/* created_by */
         sysdate, 			/* creation_date */
         pg_prog_appl_id,		/* program_application_id */
         pg_conc_program_id,		/* program_id */
         sysdate,			/* program_update_date */
         p_adj_rec.request_id		/* request_id */
         ,arp_global.sysparam.org_id
--{Late Charge Project
               ,p_adj_rec.interest_header_id
               ,p_adj_rec.interest_line_id
       );

   p_adjustment_id := l_adjustment_id;
   p_adjustment_number := l_adjustment_number;

   arp_util.debug('p_adjustment_id = ' || to_char(p_adjustment_id));
   arp_util.debug('l_adjust_id = ' || to_char(l_adjustment_id));
   /*-------------------------------------------+
    | Call central MRC library for insertion    |
    | into MRC tables                           |
    +-------------------------------------------*/
/*BUG4301323
   ar_mrc_engine.maintain_mrc_data( p_event_mode => 'INSERT',
                                    p_table_name => 'AR_ADJUSTMENTS',
                                    p_mode       => 'SINGLE',
                                    p_key_value  => p_adjustment_id);

*/
   arp_util.debug('arp_adjustments_pkg.insert_p()-');

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_adjustments_pkg.insert_p()');
	RAISE;
END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    merge_adj_rec							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Merges the changed columns in p_new_adj_rec into the same columns      |
 |    p_old_adj_rec and puts the result into p_out_adj_rec. Columns that     |
 |    contain the dummy values are not changed.				     |
 |    									     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_old_adj_rec					     |
 |                    p_new_adj_rec					     |
 |              OUT:                                                         |
 |                    p_new_adj_rec					     |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     11-SEP-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE  merge_adj_recs( p_old_adj_rec    IN  ar_adjustments%rowtype,
                           p_new_adj_rec    IN  ar_adjustments%rowtype,
                           p_out_adj_rec   OUT NOCOPY  ar_adjustments%rowtype ) IS

BEGIN

    arp_util.debug('arp_adjustments_pkg.merge_adj_recs()+');

    IF    (p_new_adj_rec.adjustment_id = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.adjustment_id  := p_old_adj_rec.adjustment_id;
    ELSE  p_out_adj_rec.adjustment_id  := p_new_adj_rec.adjustment_id;
    END IF;

    IF    (p_new_adj_rec.amount = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.amount  := p_old_adj_rec.amount;
    ELSE  p_out_adj_rec.amount  := p_new_adj_rec.amount;
    END IF;

    IF    (p_new_adj_rec.acctd_amount = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.acctd_amount  := p_old_adj_rec.acctd_amount;
    ELSE  p_out_adj_rec.acctd_amount  := p_new_adj_rec.acctd_amount;
    END IF;

    IF    (p_new_adj_rec.apply_date = AR_DATE_DUMMY)
    THEN  p_out_adj_rec.apply_date  := p_old_adj_rec.apply_date;
    ELSE  p_out_adj_rec.apply_date  := p_new_adj_rec.apply_date;
    END IF;

    IF    (p_new_adj_rec.gl_date = AR_DATE_DUMMY)
    THEN  p_out_adj_rec.gl_date  := p_old_adj_rec.gl_date;
    ELSE  p_out_adj_rec.gl_date  := p_new_adj_rec.gl_date;
    END IF;

    IF    (p_new_adj_rec.gl_posted_date = AR_DATE_DUMMY)
    THEN  p_out_adj_rec.gl_posted_date  := p_old_adj_rec.gl_posted_date;
    ELSE  p_out_adj_rec.gl_posted_date  := p_new_adj_rec.gl_posted_date;
    END IF;

    IF    (p_new_adj_rec.set_of_books_id = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.set_of_books_id  := p_old_adj_rec.set_of_books_id;
    ELSE  p_out_adj_rec.set_of_books_id  := p_new_adj_rec.set_of_books_id;
    END IF;

    IF    (p_new_adj_rec.code_combination_id = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.code_combination_id  :=
                                            p_old_adj_rec.code_combination_id;
    ELSE  p_out_adj_rec.code_combination_id  :=
                                            p_new_adj_rec.code_combination_id;
    END IF;

    IF    (p_new_adj_rec.type = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.type  := p_old_adj_rec.type;
    ELSE  p_out_adj_rec.type  := p_new_adj_rec.type;
    END IF;

    IF    (p_new_adj_rec.adjustment_type = AR_TEXT3_DUMMY)
    THEN  p_out_adj_rec.adjustment_type  := p_old_adj_rec.adjustment_type;
    ELSE  p_out_adj_rec.adjustment_type  := p_new_adj_rec.adjustment_type;
    END IF;

    IF    (p_new_adj_rec.status = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.status  := p_old_adj_rec.status;
    ELSE  p_out_adj_rec.status  := p_new_adj_rec.status;
    END IF;

    IF    (p_new_adj_rec.line_adjusted = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.line_adjusted  := p_old_adj_rec.line_adjusted;
    ELSE  p_out_adj_rec.line_adjusted  := p_new_adj_rec.line_adjusted;
    END IF;

    IF    (p_new_adj_rec.freight_adjusted = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.freight_adjusted  := p_old_adj_rec.freight_adjusted;
    ELSE  p_out_adj_rec.freight_adjusted  := p_new_adj_rec.freight_adjusted;
    END IF;

    IF    (p_new_adj_rec.tax_adjusted = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.tax_adjusted  := p_old_adj_rec.tax_adjusted;
    ELSE  p_out_adj_rec.tax_adjusted  := p_new_adj_rec.tax_adjusted;
    END IF;

    IF    (p_new_adj_rec.receivables_charges_adjusted = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.receivables_charges_adjusted  :=
                                   p_old_adj_rec.receivables_charges_adjusted;
    ELSE  p_out_adj_rec.receivables_charges_adjusted  :=
                                   p_new_adj_rec.receivables_charges_adjusted;
    END IF;

    IF    (p_new_adj_rec.batch_id = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.batch_id  := p_old_adj_rec.batch_id;
    ELSE  p_out_adj_rec.batch_id  := p_new_adj_rec.batch_id;
    END IF;

    IF    (p_new_adj_rec.customer_trx_id = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.customer_trx_id  := p_old_adj_rec.customer_trx_id;
    ELSE  p_out_adj_rec.customer_trx_id  := p_new_adj_rec.customer_trx_id;
    END IF;

    IF    (p_new_adj_rec.subsequent_trx_id = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.subsequent_trx_id  := p_old_adj_rec.subsequent_trx_id;
    ELSE  p_out_adj_rec.subsequent_trx_id  := p_new_adj_rec.subsequent_trx_id;
    END IF;

    IF    (p_new_adj_rec.customer_trx_line_id = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.customer_trx_line_id  :=
                                            p_old_adj_rec.customer_trx_line_id;
    ELSE  p_out_adj_rec.customer_trx_line_id  :=
                                            p_new_adj_rec.customer_trx_line_id;
    END IF;

    IF    (p_new_adj_rec.associated_cash_receipt_id = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.associated_cash_receipt_id  :=
                                      p_old_adj_rec.associated_cash_receipt_id;
    ELSE  p_out_adj_rec.associated_cash_receipt_id  :=
                                      p_new_adj_rec.associated_cash_receipt_id;
    END IF;

    IF    (p_new_adj_rec.chargeback_customer_trx_id = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.chargeback_customer_trx_id  :=
                                      p_old_adj_rec.chargeback_customer_trx_id;
    ELSE  p_out_adj_rec.chargeback_customer_trx_id  :=
                                      p_new_adj_rec.chargeback_customer_trx_id;
    END IF;

    IF    (p_new_adj_rec.payment_schedule_id = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.payment_schedule_id  :=
                                            p_old_adj_rec.payment_schedule_id;
    ELSE  p_out_adj_rec.payment_schedule_id  :=
                                            p_new_adj_rec.payment_schedule_id;
    END IF;

    IF    (p_new_adj_rec.receivables_trx_id = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.receivables_trx_id  :=
                                              p_old_adj_rec.receivables_trx_id;
    ELSE  p_out_adj_rec.receivables_trx_id  :=
                                              p_new_adj_rec.receivables_trx_id;
    END IF;

    IF    (p_new_adj_rec.distribution_set_id = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.distribution_set_id  :=
                                             p_old_adj_rec.distribution_set_id;
    ELSE  p_out_adj_rec.distribution_set_id  :=
                                             p_new_adj_rec.distribution_set_id;
    END IF;

    IF    (p_new_adj_rec.associated_application_id = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.associated_application_id  :=
                                       p_old_adj_rec.associated_application_id;
    ELSE  p_out_adj_rec.associated_application_id  :=
                                       p_new_adj_rec.associated_application_id;
    END IF;

    IF    (p_new_adj_rec.comments = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.comments  := p_old_adj_rec.comments;
    ELSE  p_out_adj_rec.comments  := p_new_adj_rec.comments;
    END IF;

    IF    (p_new_adj_rec.automatically_generated = AR_FLAG_DUMMY)
    THEN  p_out_adj_rec.automatically_generated  :=
                                       p_old_adj_rec.automatically_generated;
    ELSE  p_out_adj_rec.automatically_generated  :=
                                       p_new_adj_rec.automatically_generated;
    END IF;

    IF    (p_new_adj_rec.created_from = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.created_from  := p_old_adj_rec.created_from;
    ELSE  p_out_adj_rec.created_from  := p_new_adj_rec.created_from;
    END IF;

    IF    (p_new_adj_rec.reason_code = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.reason_code  := p_old_adj_rec.reason_code;
    ELSE  p_out_adj_rec.reason_code  := p_new_adj_rec.reason_code;
    END IF;

    IF    (p_new_adj_rec.postable = AR_FLAG_DUMMY)
    THEN  p_out_adj_rec.postable  := p_old_adj_rec.postable;
    ELSE  p_out_adj_rec.postable  := p_new_adj_rec.postable;
    END IF;

    IF    (p_new_adj_rec.approved_by = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.approved_by  := p_old_adj_rec.approved_by;
    ELSE  p_out_adj_rec.approved_by  := p_new_adj_rec.approved_by;
    END IF;

    IF    (p_new_adj_rec.adjustment_number = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.adjustment_number  := p_old_adj_rec.adjustment_number;
    ELSE  p_out_adj_rec.adjustment_number  := p_new_adj_rec.adjustment_number;
    END IF;

    IF    (p_new_adj_rec.doc_sequence_value = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.doc_sequence_value  :=
                                              p_old_adj_rec.doc_sequence_value;
    ELSE  p_out_adj_rec.doc_sequence_value  :=
                                              p_new_adj_rec.doc_sequence_value;
    END IF;

    IF    (p_new_adj_rec.doc_sequence_id = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.doc_sequence_id  := p_old_adj_rec.doc_sequence_id;
    ELSE  p_out_adj_rec.doc_sequence_id  := p_new_adj_rec.doc_sequence_id;
    END IF;

    IF    (p_new_adj_rec.ussgl_transaction_code = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.ussgl_transaction_code  :=
                                          p_old_adj_rec.ussgl_transaction_code;
    ELSE  p_out_adj_rec.ussgl_transaction_code  :=
                                          p_new_adj_rec.ussgl_transaction_code;
    END IF;

    IF    (p_new_adj_rec.ussgl_transaction_code_context = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.ussgl_transaction_code_context  :=
                                 p_old_adj_rec.ussgl_transaction_code_context;
    ELSE  p_out_adj_rec.ussgl_transaction_code_context  :=
                                 p_new_adj_rec.ussgl_transaction_code_context;
    END IF;

    IF    (p_new_adj_rec.attribute_category = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.attribute_category  :=
                                              p_old_adj_rec.attribute_category;
    ELSE  p_out_adj_rec.attribute_category  :=
                                              p_new_adj_rec.attribute_category;
    END IF;

    IF    (p_new_adj_rec.attribute1 = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.attribute1  := p_old_adj_rec.attribute1;
    ELSE  p_out_adj_rec.attribute1  := p_new_adj_rec.attribute1;
    END IF;

    IF    (p_new_adj_rec.attribute2 = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.attribute2  := p_old_adj_rec.attribute2;
    ELSE  p_out_adj_rec.attribute2  := p_new_adj_rec.attribute2;
    END IF;

    IF    (p_new_adj_rec.attribute3 = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.attribute3  := p_old_adj_rec.attribute3;
    ELSE  p_out_adj_rec.attribute3  := p_new_adj_rec.attribute3;
    END IF;

    IF    (p_new_adj_rec.attribute4 = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.attribute4  := p_old_adj_rec.attribute4;
    ELSE  p_out_adj_rec.attribute4  := p_new_adj_rec.attribute4;
    END IF;

    IF    (p_new_adj_rec.attribute5 = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.attribute5  := p_old_adj_rec.attribute5;
    ELSE  p_out_adj_rec.attribute5  := p_new_adj_rec.attribute5;
    END IF;

    IF    (p_new_adj_rec.attribute6 = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.attribute6  := p_old_adj_rec.attribute6;
    ELSE  p_out_adj_rec.attribute6  := p_new_adj_rec.attribute6;
    END IF;

    IF    (p_new_adj_rec.attribute7 = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.attribute7  := p_old_adj_rec.attribute7;
    ELSE  p_out_adj_rec.attribute7  := p_new_adj_rec.attribute7;
    END IF;

    IF    (p_new_adj_rec.attribute8 = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.attribute8  := p_old_adj_rec.attribute8;
    ELSE  p_out_adj_rec.attribute8  := p_new_adj_rec.attribute8;
    END IF;

    IF    (p_new_adj_rec.attribute9 = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.attribute9  := p_old_adj_rec.attribute9;
    ELSE  p_out_adj_rec.attribute9  := p_new_adj_rec.attribute9;
    END IF;

    IF    (p_new_adj_rec.attribute10 = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.attribute10  := p_old_adj_rec.attribute10;
    ELSE  p_out_adj_rec.attribute10  := p_new_adj_rec.attribute10;
    END IF;

    IF    (p_new_adj_rec.attribute11 = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.attribute11  := p_old_adj_rec.attribute11;
    ELSE  p_out_adj_rec.attribute11  := p_new_adj_rec.attribute11;
    END IF;

    IF    (p_new_adj_rec.attribute12 = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.attribute12  := p_old_adj_rec.attribute12;
    ELSE  p_out_adj_rec.attribute12  := p_new_adj_rec.attribute12;
    END IF;

    IF    (p_new_adj_rec.attribute13 = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.attribute13  := p_old_adj_rec.attribute13;
    ELSE  p_out_adj_rec.attribute13  := p_new_adj_rec.attribute13;
    END IF;

    IF    (p_new_adj_rec.attribute14 = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.attribute14  := p_old_adj_rec.attribute14;
    ELSE  p_out_adj_rec.attribute14  := p_new_adj_rec.attribute14;
    END IF;

    IF    (p_new_adj_rec.attribute15 = AR_TEXT_DUMMY)
    THEN  p_out_adj_rec.attribute15  := p_old_adj_rec.attribute15;
    ELSE  p_out_adj_rec.attribute15  := p_new_adj_rec.attribute15;
    END IF;

    IF    (p_new_adj_rec.posting_control_id = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.posting_control_id  :=
                                             p_old_adj_rec.posting_control_id;
    ELSE  p_out_adj_rec.posting_control_id  :=
                                             p_new_adj_rec.posting_control_id;
    END IF;

    IF    (p_new_adj_rec.last_updated_by = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.last_updated_by  := p_old_adj_rec.last_updated_by;
    ELSE  p_out_adj_rec.last_updated_by  := p_new_adj_rec.last_updated_by;
    END IF;

    IF    (p_new_adj_rec.last_update_date = AR_DATE_DUMMY)
    THEN  p_out_adj_rec.last_update_date  := p_old_adj_rec.last_update_date;
    ELSE  p_out_adj_rec.last_update_date  := p_new_adj_rec.last_update_date;
    END IF;

    IF    (p_new_adj_rec.last_update_login = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.last_update_login  := p_old_adj_rec.last_update_login;
    ELSE  p_out_adj_rec.last_update_login  := p_new_adj_rec.last_update_login;
    END IF;

    IF    (p_new_adj_rec.created_by = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.created_by  := p_old_adj_rec.created_by;
    ELSE  p_out_adj_rec.created_by  := p_new_adj_rec.created_by;
    END IF;

    IF    (p_new_adj_rec.creation_date = AR_DATE_DUMMY)
    THEN  p_out_adj_rec.creation_date  := p_old_adj_rec.creation_date;
    ELSE  p_out_adj_rec.creation_date  := p_new_adj_rec.creation_date;
    END IF;

    IF    (p_new_adj_rec.program_application_id = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.program_application_id  :=
                                         p_old_adj_rec.program_application_id;
    ELSE  p_out_adj_rec.program_application_id  :=
                                         p_new_adj_rec.program_application_id;
    END IF;

    IF    (p_new_adj_rec.program_id = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.program_id  := p_old_adj_rec.program_id;
    ELSE  p_out_adj_rec.program_id  := p_new_adj_rec.program_id;
    END IF;

    IF    (p_new_adj_rec.program_update_date = AR_DATE_DUMMY)
    THEN  p_out_adj_rec.program_update_date  :=
                                             p_old_adj_rec.program_update_date;
    ELSE  p_out_adj_rec.program_update_date  :=
                                             p_new_adj_rec.program_update_date;
    END IF;

    IF    (p_new_adj_rec.request_id = AR_NUMBER_DUMMY)
    THEN  p_out_adj_rec.request_id  := p_old_adj_rec.request_id;
    ELSE  p_out_adj_rec.request_id  := p_new_adj_rec.request_id;
    END IF;

    arp_util.debug('arp_adjustments_pkg.merge_adj_recs()-');


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_adjustments_pkg.merge_adj_recs()');

        arp_util.debug('------ old adjustment record ------');
        arp_adjustments_pkg.display_adj_rec( p_old_adj_rec );
        arp_util.debug('');
        arp_util.debug('------ new adjustment record ------');
        arp_adjustments_pkg.display_adj_rec( p_new_adj_rec );
        RAISE;

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_adj_rec                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except creation_date and            |
 |    last_update_date.                                                      |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                       p_adj_rec                                           |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-AUG-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE display_adj_rec(
            p_adj_rec IN ar_adjustments%rowtype) IS

BEGIN
   arp_util.debug('arp_adjustments_pkg.display_adj_rec()+',
                 pg_msg_level_debug);

   arp_util.debug('******** Dump of ar_adjustments record *********');

   arp_util.debug('adjustment_id                  : '||
                                     p_adj_rec.adjustment_id);
   arp_util.debug('acctd_amount                   : '||
                                     p_adj_rec.acctd_amount);
   arp_util.debug('adjustment_type                : '||
                                     p_adj_rec.adjustment_type);
   arp_util.debug('amount                         : '||
                                     p_adj_rec.amount);
   arp_util.debug('code_combination_id            : '||
                                     p_adj_rec.code_combination_id);
   arp_util.debug('created_by                     : '||
                                     p_adj_rec.created_by);
   arp_util.debug('gl_date                        : '||
                                     p_adj_rec.gl_date);
   arp_util.debug('last_updated_by                : '||
                                     p_adj_rec.last_updated_by);
   arp_util.debug('set_of_books_id                : '||
                                     p_adj_rec.set_of_books_id);
   arp_util.debug('status                         : '||
                                     p_adj_rec.status);
   arp_util.debug('type                           : '||
                                     p_adj_rec.type);
   arp_util.debug('created_from                   : '||
                                     p_adj_rec.created_from);
   arp_util.debug('adjustment_number              : '||
                                     p_adj_rec.adjustment_number);
   arp_util.debug('apply_date                     : '||
                                     p_adj_rec.apply_date);
   arp_util.debug('approved_by                    : '||
                                     p_adj_rec.approved_by);
   arp_util.debug('associated_cash_receipt_id     : '||
                                     p_adj_rec.associated_cash_receipt_id);
   arp_util.debug('automatically_generated        : '||
                                     p_adj_rec.automatically_generated);
   arp_util.debug('batch_id                       : '||
                                     p_adj_rec.batch_id);
   arp_util.debug('chargeback_customer_trx_id     : '||
                                     p_adj_rec.chargeback_customer_trx_id);
   arp_util.debug('comments                       : '||
                                     p_adj_rec.comments);
   arp_util.debug('customer_trx_id                : '||
                                     p_adj_rec.customer_trx_id);
   arp_util.debug('customer_trx_line_id           : '||
                                     p_adj_rec.customer_trx_line_id);
   arp_util.debug('distribution_set_id            : '||
                                     p_adj_rec.distribution_set_id);
   arp_util.debug('freight_adjusted               : '||
                                     p_adj_rec.freight_adjusted);
   arp_util.debug('gl_posted_date                 : '||
                                     p_adj_rec.gl_posted_date);
   arp_util.debug('last_update_login              : '||
                                     p_adj_rec.last_update_login);
   arp_util.debug('line_adjusted                  : '||
                                     p_adj_rec.line_adjusted);
   arp_util.debug('payment_schedule_id            : '||
                                     p_adj_rec.payment_schedule_id);
   arp_util.debug('postable                       : '||
                                     p_adj_rec.postable);
   arp_util.debug('posting_control_id             : '||
                                     p_adj_rec.posting_control_id);
   arp_util.debug('reason_code                    : '||
                                     p_adj_rec.reason_code);
   arp_util.debug('receivables_charges_adjusted   : '||
                                     p_adj_rec.receivables_charges_adjusted);
   arp_util.debug('receivables_trx_id             : '||
                                     p_adj_rec.receivables_trx_id);
   arp_util.debug('subsequent_trx_id              : '||
                                     p_adj_rec.subsequent_trx_id);
   arp_util.debug('tax_adjusted                   : '||
                                     p_adj_rec.tax_adjusted);
   arp_util.debug('attribute_category             : '||
                                     p_adj_rec.attribute_category);
   arp_util.debug('attribute1                     : '||
                                     p_adj_rec.attribute1);
   arp_util.debug('attribute2                     : '||
                                     p_adj_rec.attribute2);
   arp_util.debug('attribute3                     : '||
                                     p_adj_rec.attribute3);
   arp_util.debug('attribute4                     : '||
                                     p_adj_rec.attribute4);
   arp_util.debug('attribute5                     : '||
                                     p_adj_rec.attribute5);
   arp_util.debug('attribute6                     : '||
                                     p_adj_rec.attribute6);
   arp_util.debug('attribute7                     : '||
                                     p_adj_rec.attribute7);
   arp_util.debug('attribute8                     : '||
                                     p_adj_rec.attribute8);
   arp_util.debug('attribute9                     : '||
                                     p_adj_rec.attribute9);
   arp_util.debug('attribute10                    : '||
                                     p_adj_rec.attribute10);
   arp_util.debug('attribute11                    : '||
                                     p_adj_rec.attribute11);
   arp_util.debug('attribute12                    : '||
                                     p_adj_rec.attribute12);
   arp_util.debug('attribute13                    : '||
                                     p_adj_rec.attribute13);
   arp_util.debug('attribute14                    : '||
                                     p_adj_rec.attribute14);
   arp_util.debug('attribute15                    : '||
                                     p_adj_rec.attribute15);
   arp_util.debug('ussgl_transaction_code         : '||
                                     p_adj_rec.ussgl_transaction_code);
   arp_util.debug('ussgl_transaction_code_context : '||
                                     p_adj_rec.ussgl_transaction_code_context);
   arp_util.debug('request_id                     : '||
                                     p_adj_rec.request_id);
   arp_util.debug('program_update_date            : '||
                                     p_adj_rec.program_update_date);
   arp_util.debug('program_id                     : '||
                                     p_adj_rec.program_id);
   arp_util.debug('program_application_id         : '||
                                     p_adj_rec.program_application_id);
   arp_util.debug('doc_sequence_id                : '||
                                     p_adj_rec.doc_sequence_id);
   arp_util.debug('doc_sequence_value             : '||
                                     p_adj_rec.doc_sequence_value);
   arp_util.debug('associated_application_id      : '||
                                     p_adj_rec.associated_application_id);

   arp_util.debug('arp_adjustments_pkg.display_adj_rec()-',
                 pg_msg_level_debug);

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION: arp_adjustments_pkg.display_adj_rec()');
        RAISE;
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    display_adj_p                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Displays the values of all columns except creation_date and            |
 |    last_update_date.                                                      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                p_adjustment_id                                            |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     29-AUG-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE display_adj_p(p_adjustment_id IN ar_adjustments.adjustment_id%type)

IS

   l_adj_rec ar_adjustments%rowtype;

BEGIN
   arp_util.debug('arp_adjustments_pkg.display_adj_p()+',
                  pg_msg_level_debug);

   fetch_p(l_adj_rec, p_adjustment_id);

   display_adj_rec(l_adj_rec);

   arp_util.debug('arp_adjustments_pkg.display_adj_p()-',
                  pg_msg_level_debug);


EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION: arp_adjustments_pkg.display_adj_p()');

        arp_util.debug('');
        arp_util.debug('-------- parameters for display_adj_p() ------');
        arp_util.debug('p_adjustment_id  = ' || p_adjustment_id );

        RAISE;
END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_text_dummy							     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure returns the value of the AR_TEXT_DUMMY constant.        |
 |    									     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    None						     |
 |              OUT:                                                         |
 |                    None						     |
 |                                                                           |
 | RETURNS    : value of AR_TEXT_DUMMY                                       |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-SEP-95  Martin Johnson      Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_text_dummy(p_null IN NUMBER DEFAULT null) RETURN varchar2 IS

BEGIN

    arp_util.debug('arp_adjustments_pkg.get_text_dummy()+');

    arp_util.debug('arp_adjustments_pkg.get_text_dummy()-');

    return(AR_TEXT_DUMMY);

EXCEPTION
    WHEN OTHERS THEN
        arp_util.debug('EXCEPTION:  arp_adjustments_pkg.get_text_dummy()');
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

  pg_base_curr_code    := arp_global.functional_currency;
  pg_base_precision    := arp_global.base_precision;
  pg_base_min_acc_unit := arp_global.base_min_acc_unit;

  pg_msg_level_debug := arp_global.MSG_LEVEL_DEBUG;

END ARP_ADJUSTMENTS_PKG;

/
