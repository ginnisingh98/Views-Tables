--------------------------------------------------------
--  DDL for Package Body AR_CC_LOCKBOX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CC_LOCKBOX" AS
/* $Header: ARCCLOCB.pls 120.11 2005/07/22 09:38:38 naneja ship $ */

/* Private procedures added for bug 2670619 */
/*Bug 44509019 used NOCOPY hint to remove GSCC warnings file.sql.39*/
PROCEDURE calc_amt_applied_from_fmt (
  p_currency_code IN VARCHAR2,
  p_amount_applied IN ar_payments_interface.amount_applied1%type,
  p_trans_to_receipt_rate IN ar_payments_interface.trans_to_receipt_rate1%type,
  amount_applied_from OUT NOCOPY ar_payments_interface.amount_applied_from1%type,
  p_format_amount IN VARCHAR2
        );

PROCEDURE calc_amt_applied_fmt (
  p_invoice_currency_code IN VARCHAR2,
  p_amount_applied_from IN ar_payments_interface.amount_applied_from1%type,
  p_trans_to_receipt_rate IN ar_payments_interface.trans_to_receipt_rate1%type,
  amount_applied OUT NOCOPY ar_payments_interface.amount_applied1%type,
  p_format_amount IN VARCHAR2
                           );
--

/*===========================================================================+
|  PROCEDURE
|       calc_cross_rate
|  DESCRIPTION
|       Populates the item "Rate".  This is calculated when
|       both the Amount Applied and Allocated Receipt Amount have both been
|       entered.  Calculated as Allocated Receipt Amount divided by the
|       Amount Applied, i.e. it is the rate that the Amount Applied is
|       multiplied by to get to the Allocated Receipt Amount.
|
|       The majority of this procedure was copied from the GUI applications
|       form.  This is the routine that was used for the Release 11
|       cross currency receipts enhancements.  It is being expanded for
|       cross currency lockbox/postbatch enhancements.
|
|       We are using an interesting algorithm to get to the "final"
|       or defaulted value.  The ultimate aim is to default a rate that
|       is the smallest possible number and we want to have a situation
|       where
|
|               rounded(amount_applied * trans_to_receipt_rate) =
|                               rounded(allocated_receipt_amount)
|
|       where rounding in based on the receipt currency.
|
|       For example:
|       Amount Applied = 90CND
|       Allocated Receipt Amount = 200USD
|
|       Cross Currency Rate = 200/90 = 2.222 recurring
|
|       The derived rate however will be 2.2222, as
|       2.2222 * 90 = 199.998 = 200 (rounded) which =
|             Allocted Receipt Amount 200
|
|       See notes in code to see how we actually do this!
|
|  SCOPE - PUBLIC
|
|  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE
|
|  ARGUMENTS   :   IN:
|                        amount_applied
|                        amount_applied_from
|                        p_inv_curr_code
|                        p_rec_curr_code
|
|                  IN OUT NOCOPY :
|
|                  OUT NOCOPY :
|                         trans_to_receipt_rate
|
|  RETURNS     :
|
|  NOTES       :   since this module calculates the most rounded rate to
|                  convert the 2 numbers, it will also be used by postbatch
|                  to calculate the receipt_to_trans_rate which is just the
|                  inverse of the trans_to_receipt_rate or the rate that
|                  can be used to convert the receipt amount to the
|                  transaction amount.   The difference is that the calling
|                  routine will pass the amount_applied_from as the amount
|                  applied and the amount_applied as the amount_applied_from
|  MODIFICATION HISTORY:
|  10/22/1998      Debbie Jancis   copied from ARXRWAPP and modified for use
|                                  with cross currency lockbox.
|  12/07/99        RYELURI         To fix bug numbers 1052313 and 1097549
|                                  Added the statement ps.status = 'OP'
|                                  and ps.class NOT IN ('PMT','GUAR')
|                                  in populate populate_add_inv_details proc
|  04/14/00        RYELURI         To fix bug number 1198572
|                                  Modifications done in populate_add_inv..
|                                  function in this package. Modifications
|                                  consist of a) Check to see if the current
|                                  invoice is duplicate transaction and if so
|                                  all the payment schedules on the original
|                                  transaction are closed. Otherwise Lockbox
|                                  will give the msg that the transaction is
|                                  a duplicate. b) If multiple payment terms
|                                  exist, then receipt is applied to the
|                                  minimum of the payment schedule that has
|                                  status is open, if overapplication is allowed
|                                  then status if of no concern.
|                                  These modifications are done as part of Lock
|                                  box enhancements to be able to apply receipts
|                                  to invoices with Multiple payment terms.
|  10/26/00	  Debbie Jancis	   Modified for tca uptake.  Removed all
|			           references to ar/ra customer tables and
|			           replaced with hz counterparts
+---------------------------------------------------------------------------*/


PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE calc_cross_rate (
      p_amount_applied IN ar_payments_interface.amount_applied1%TYPE,
      p_amount_applied_from IN ar_payments_interface.amount_applied_from1%TYPE,
      p_inv_curr_code IN ar_payments_interface.invoice_currency_code1%TYPE,
      p_rec_curr_code IN ar_payments_interface.currency_code%TYPE,
      p_cross_rate OUT NOCOPY NUMBER ) IS

ln_start_rounding		NUMBER;
ln_amount_applied		NUMBER;
ln_amount_applied_from		NUMBER;
ln_test_trans_to_receipt_rate	NUMBER;
ln_amount_applied_X_rate	NUMBER;
ln_trans_to_receipt_rate	NUMBER;
l_mau                           NUMBER;
l_precision                     NUMBER(1);
l_extended_precision            NUMBER;


BEGIN

  debug1( 'calc_cross_rate()+' );
  debug1('p_amount_applied = ' || to_char(p_amount_applied));
  debug1('p_amount_applied_from = ' || to_char(p_amount_applied_from));
  debug1('p inv curr cord = ' || p_inv_curr_code);
  debug1('p rec curr cord = ' || p_rec_curr_code);


   /* If we are applying a value of zero, copy null into the Cross Currency
      Rate item and exit the procedure. */

   IF (p_amount_applied = 0 OR
       p_amount_applied_from = 0) THEN
       p_cross_rate := null;
debug1('amount_applied or amount_applied from = 0');
   ELSE

     /* Populate "starting" values */
     debug1('populate starting values...');
     fnd_currency.Get_Info(p_inv_curr_code,
                           l_precision,
                           l_extended_precision,
                           l_mau);
     debug1('populate ln_amount_applied');
     IF l_mau IS NOT NULL
     THEN
           ln_amount_applied := ROUND(p_amount_applied / l_mau) * l_mau;
     ELSE
           ln_amount_applied := ROUND(p_amount_applied, l_precision);
     END IF;

     fnd_currency.Get_Info(p_rec_curr_code,
                           l_precision,
                           l_extended_precision,
                           l_mau);
     debug1('populate ln_amount_applied_from .. ');
     IF l_mau IS NOT NULL
     THEN
         ln_amount_applied_from := ROUND(p_amount_applied_from / l_mau) * l_mau;
     ELSE
         ln_amount_applied_from := ROUND(p_amount_applied_from, l_precision);
     END IF;

     ln_trans_to_receipt_rate := p_amount_applied_from / p_amount_applied;
     ln_amount_applied_X_rate := 0;


     /* -----------------------------------------------------------------------

      The following nightmare is as a result of the LOG number
      function not being
      available in PL/SQL version 1.0.
      What we are trying to do is to work out NOCOPY is at what
      point should we start
      rounding the rate.
      For example, if the start rate is 23.12345,
      will want to start rounding at
      -1, for a rate 123.12345, we need to start at -2 etc

      As the LOG function is not available, we have to work
      it out NOCOPY ourselves.
      Assuming that the maximum rate that should ever be
      calculated is 100000000000.
      If it is ever greater than this an error message is
      displayed indicating that
      this is an unusally large rate and something must be wrong!
      Going up to 100000000000 to cater for the "depression" times,
      when it costs
      a wheel barrow full of money just to buy a loaf of bread!

       --------------------------------------------------------------*/

      IF ln_trans_to_receipt_rate > 100000000000 THEN
         FND_MESSAGE.SET_NAME('AR','AR_RW_CROSS_CC_RATE_LARGE');
         app_exception.raise_exception;
      ELSIF ln_trans_to_receipt_rate >= 10000000000 and ln_trans_to_receipt_rate <= 99999999999 THEN
         ln_start_rounding := -10;
      ELSIF ln_trans_to_receipt_rate >= 1000000000 and ln_trans_to_receipt_rate <= 9999999999 THEN
         ln_start_rounding := -9;
      ELSIF ln_trans_to_receipt_rate >= 100000000 and ln_trans_to_receipt_rate <= 999999999 THEN
         ln_start_rounding := -8;
      ELSIF ln_trans_to_receipt_rate >= 10000000 and ln_trans_to_receipt_rate <= 99999999 THEN
         ln_start_rounding := -7;
      ELSIF ln_trans_to_receipt_rate >= 1000000 and ln_trans_to_receipt_rate <= 9999999 THEN
         ln_start_rounding := -6;
      ELSIF ln_trans_to_receipt_rate >= 100000 and ln_trans_to_receipt_rate <= 999999 THEN
         ln_start_rounding := -5;
      ELSIF ln_trans_to_receipt_rate >= 10000 and ln_trans_to_receipt_rate <= 99999 THEN
         ln_start_rounding := -4;
      ELSIF ln_trans_to_receipt_rate >= 1000 and ln_trans_to_receipt_rate <= 9999 THEN
         ln_start_rounding := -3;
      ELSIF ln_trans_to_receipt_rate >= 100 and ln_trans_to_receipt_rate <= 999 THEN
         ln_start_rounding := -2;
      ELSIF ln_trans_to_receipt_rate >= 10 and ln_trans_to_receipt_rate <= 99 THEN
         ln_start_rounding := -1;
      ELSE
         ln_start_rounding := 0;
      END IF;

      /* --------------------------------------------------------------------
         Once we know at what point to start we can then round
         this number until we reach a situation where
         rounded(amount_applied * trans_to_receipt_rate) =
      			rounded(allocated_receipt_amount)

         Only going to 32, as this is the maximum size of the
         field (plus 10 before decimal).

      -- Given our example:
      -- Amount Applied = 90CND
      -- Allocated Receipt Amount = 200USD
      --
      -- Start rate = 200/90 = 2.222 recurring
      -- Start rounding at 0
      --  0 Try rate 2 ... round(2 * 90) = 180 <> 200
      --  1 Try rate 2.2 ... round(2.2 * 90) = 198 <> 200
      --  2 Try rate 2.22 ... round(2.22 * 90) = 199.80 <> 200 ...
          getting closer though
      --  3 Try rate 2.222 ... round(2.222 * 90) = 199.98 <> 200 ... nearly there
      --  4 Try rate 2.2222 ... round(2.2222 * 90) = 200 ... made it!
      --------------------------------------------------------------- */
      FOR round_integer in ln_start_rounding .. 32
      LOOP
         ln_test_trans_to_receipt_rate := round(ln_trans_to_receipt_rate, round_integer);
         IF ln_test_trans_to_receipt_rate = 0
         THEN
            null;
         ELSE

            fnd_currency.Get_Info(p_inv_curr_code,
                           l_precision,
                           l_extended_precision,
                           l_mau);
            IF l_mau IS NOT NULL
               THEN
                ln_amount_applied_X_rate :=
                   ROUND((ln_amount_applied * ln_test_trans_to_receipt_rate)
                          / l_mau) * l_mau;
            ELSE
                ln_amount_applied_X_rate :=
                      ROUND((ln_amount_applied * ln_test_trans_to_receipt_rate),
                             l_precision);
            END IF;

            IF ln_amount_applied_X_rate = ln_amount_applied_from
            THEN
               exit;
            END IF;
         END IF;
      END LOOP;

      /* Copy the derived value into the item and set to valid. */
      p_cross_rate := ln_test_trans_to_receipt_rate;

   END IF;  /* Either amounts zero. */

   debug1 ('calc_cross_rate()-');

    EXCEPTION
        WHEN OTHERS THEN
           debug1( 'Exception: calc_cross_rate()');
    END calc_cross_rate;


/*===========================================================================+
|  PROCEDURE
|      populate_add_inv_details
|  DESCRIPTION
|      This procedure will populate additional details about an application
|      if required.   Because of the flexability that we allow in the
|      transmission file for lockbox, a user can give us limited details
|      of a cross currency /EURO application and we can calculate the
|      additional columns if needed.
|
|      For a Euro case, we assume that the user will give us either the
|      amount_applied or amount_applied_from.  Since it is a fixed rate,
|      we can calculate the other amount from the fixed rate that we will
|      get from GL.
|
|      For a standard cross currency Case, we expect to have 2 of the
|      following:  amount_applied, amount_applied_from, or the
|      trans_to_receipt_rate.  If we only have one amount, and the
|      profile is set to allow us to try to derive the rate from gl, and
|      there is a rate for this cross currency case, we can derive the
|      other amount value.   If two amounts are given, we can calculate
|      the rate.
|
|  SCOPE - PUBLIC
|
|  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE
|
|  ARGUMENTS   :   IN:
|
|                  IN OUT NOCOPY :
|
|                  OUT NOCOPY :
|
|  RETURNS     :
|
|  NOTES
|  MODIFICATION HISTORY:
|  10/26/1998      Debbie Jancis   original
|  01/04/1999      Debbie Jancis   Need to retrieve the receipt date from
|                                  the receipt record (as it is not present
|                                  on the overflow record).  This assumes that
|                                  there is only 1 receipt record with the same
|                                  item number.
|  12/12/00       Shin Matsuda     Bug 1519765.
|                                  We should reject cross-currency receipt if
|                                  only amount_applied of ammount_applied_from
|                                  (not both) is provided, and trans_to_receipt
|                                  rate is not provided, and not fixed rate,
|                                  and default_exchange_rate_type is not
|                                  defined.
|  12/12/2000     Debbie Jancis    fixed bug 1513671:  amount_applied was
|                                  being rounded with the receipt precision.
|  01/19/2001     Shin Matsuda     Bug 1585615.  Unhandled exception if
|                                  trans_to_receipt_rate is zero.
|                                  Fixed the problem by regarding zero-rate
|                                  as null.
|  05/21/2001     Debbie Jancis    Added bill_to_flag in all queries to
|                                  hz_cust_acct_relate to specifically check
|                           	   for a Bill_to Relationship instead of
|                           	   just the existance of a record in the table
|  10/20/2001     Chelvi B.        Bug 2066679 Instead of updating
|                                  invoice2_status with AR_PLB_CURRENCY_BAD
|                                  invoice1_status was updated wrongly.
|  10/23/2001     Shin Matsuda     There are some other places where it updates
|                                  invoice1_status instead of invoiceN_status.
|                                  Corrected all of them.
|  10/31/2001     Shin Matsuda     Bug 2066392.  Populate amount_appliedN with
|                                  amount_applied_fromN if single currency
|                                  application.
|  11/21/2001     Shin Matsuda     Bug 2057282.  Validate/populate currency
|                                  and amount info only if l_tot_trxN is 1.
|  11/23/2001     Shin Matsuda     Bug 2119596.  Backed out NOCOPY the previous fix.
|                                  Put exception clause for no_data_found case.
|  10/28/2002     Shin Matsuda     Bug 2626005.  Modified where clause of most
|                                  update statements.  We validate CC info row
|                                  by row and we know rowid of the record, thus
|                                  the where clause can be simple rowid=l_rowid
|  05/07/2003     Rahna Kader      Bug 2926664.Modified the select statement
|                                  which is used for setting AR_PLB_DUP_INV.
|                                  Also modified the select statement which selects
|                                  the invoice currency code and amount due
|                                  remaining.
|  08/14/2003     H Yoshihara      Bug 2980051. Replaced l_only_one_lb with
| 				   l_no_batch_or_lb in get_app_info cursor
|				   to identify record correctly.
|  22/10/2003     SAPN Sarma       Bug 3113104. Replaced the get_rate function with
|				   get_rate_sql function.Also, made a check for the
|				   exchange_rate_value that is returned.
+---------------------------------------------------------------------------*/


PROCEDURE populate_add_inv_details(
       p_transmission_id IN VARCHAR2,
       p_payment_rec_type IN VARCHAR2,
       p_overflow_rec_type IN VARCHAR2,
       p_item_num IN ar_payments_interface.item_number%type,
       p_batch_name IN ar_payments_interface.batch_name%type,
       p_lockbox_number IN ar_payments_interface.lockbox_number%type,
       p_batches IN VARCHAR2,
       p_only_one_lb IN VARCHAR2,
       p_pay_unrelated_invoices IN VARCHAR2,
       p_default_exchange_rate_type IN VARCHAR2,
       enable_cross_currency IN VARCHAR2,
       p_format_amount1  IN VARCHAR,
       p_format_amount2  IN VARCHAR,
       p_format_amount3  IN VARCHAR,
       p_format_amount4  IN VARCHAR,
       p_format_amount5  IN VARCHAR,
       p_format_amount6  IN VARCHAR,
       p_format_amount7  IN VARCHAR,
       p_format_amount8  IN VARCHAR,
       p_format_amount_applied_from1  IN VARCHAR,
       p_format_amount_applied_from2  IN VARCHAR,
       p_format_amount_applied_from3  IN VARCHAR,
       p_format_amount_applied_from4  IN VARCHAR,
       p_format_amount_applied_from5  IN VARCHAR,
       p_format_amount_applied_from6  IN VARCHAR,
       p_format_amount_applied_from7  IN VARCHAR,
       p_format_amount_applied_from8  IN VARCHAR
                     ) IS
--
l_transmission_id         VARCHAR2(50);
l_payment_rec_type        VARCHAR2(3);
l_overflow_rec_type       VARCHAR2(3);
l_item_num                ar_payments_interface.item_number%type;
l_batch_name              ar_payments_interface.batch_name%type;
l_lockbox_number          ar_payments_interface.lockbox_number%type;
l_batches                 VARCHAR2(2);
l_only_one_lb             VARCHAR2(2);
l_use_matching_date       ar_lockboxes.use_matching_date%type;
l_lockbox_matching_option ar_lockboxes.lockbox_matching_option%type;
l_match_flag              VARCHAR2(10);
l_rowid                   ROWID;
l_pay_unrelated_invoices  VARCHAR2(2);
l_is_fixed_rate           VARCHAR2(1);
l_default_exchange_rate_type  VARCHAR2(31);
l_enable_cross_currency   VARCHAR2(2);

--
l_format_amount1          VARCHAR2(2);
l_format_amount2          VARCHAR2(2);
l_format_amount3          VARCHAR2(2);
l_format_amount4          VARCHAR2(2);
l_format_amount5          VARCHAR2(2);
l_format_amount6          VARCHAR2(2);
l_format_amount7          VARCHAR2(2);
l_format_amount8          VARCHAR2(2);
l_format_amount_applied_from1 VARCHAR2(2);
l_format_amount_applied_from2 VARCHAR2(2);
l_format_amount_applied_from3 VARCHAR2(2);
l_format_amount_applied_from4 VARCHAR2(2);
l_format_amount_applied_from5 VARCHAR2(2);
l_format_amount_applied_from6 VARCHAR2(2);
l_format_amount_applied_from7 VARCHAR2(2);
l_format_amount_applied_from8 VARCHAR2(2);
--
l_mau                           NUMBER;
l_precision                     NUMBER(1);
l_extended_precision            NUMBER;
--
-- bug fix 1198572
l_tot_trx1            NUMBER;
l_tot_trx2            NUMBER;
l_tot_trx3            NUMBER;
l_tot_trx4            NUMBER;
l_tot_trx5            NUMBER;
l_tot_trx6            NUMBER;
l_tot_trx7            NUMBER;
l_tot_trx8            NUMBER;

/*  declare matching invoice numbers */
l_matching_number1        ar_payments_interface.invoice1%type;
l_matching_number2        ar_payments_interface.invoice2%type;
l_matching_number3        ar_payments_interface.invoice3%type;
l_matching_number4        ar_payments_interface.invoice4%type;
l_matching_number5        ar_payments_interface.invoice5%type;
l_matching_number6        ar_payments_interface.invoice6%type;
l_matching_number7        ar_payments_interface.invoice7%type;
l_matching_number8        ar_payments_interface.invoice8%type;
--
l_trans_to_receipt_rate1  ar_payments_interface.trans_to_receipt_rate1%type;
l_trans_to_receipt_rate2  ar_payments_interface.trans_to_receipt_rate2%type;
l_trans_to_receipt_rate3  ar_payments_interface.trans_to_receipt_rate3%type;
l_trans_to_receipt_rate4  ar_payments_interface.trans_to_receipt_rate4%type;
l_trans_to_receipt_rate5  ar_payments_interface.trans_to_receipt_rate5%type;
l_trans_to_receipt_rate6  ar_payments_interface.trans_to_receipt_rate6%type;
l_trans_to_receipt_rate7  ar_payments_interface.trans_to_receipt_rate7%type;
l_trans_to_receipt_rate8  ar_payments_interface.trans_to_receipt_rate8%type;
--
l_invoice_currency_code1  ar_payments_interface.invoice_currency_code1%type;
l_invoice_currency_code2  ar_payments_interface.invoice_currency_code2%type;
l_invoice_currency_code3  ar_payments_interface.invoice_currency_code3%type;
l_invoice_currency_code4  ar_payments_interface.invoice_currency_code4%type;
l_invoice_currency_code5  ar_payments_interface.invoice_currency_code5%type;
l_invoice_currency_code6  ar_payments_interface.invoice_currency_code6%type;
l_invoice_currency_code7  ar_payments_interface.invoice_currency_code7%type;
l_invoice_currency_code8  ar_payments_interface.invoice_currency_code8%type;
--
l_amount_applied1         ar_payments_interface.amount_applied1%type;
l_amount_applied2         ar_payments_interface.amount_applied2%type;
l_amount_applied3         ar_payments_interface.amount_applied3%type;
l_amount_applied4         ar_payments_interface.amount_applied4%type;
l_amount_applied5         ar_payments_interface.amount_applied5%type;
l_amount_applied6         ar_payments_interface.amount_applied6%type;
l_amount_applied7         ar_payments_interface.amount_applied7%type;
l_amount_applied8         ar_payments_interface.amount_applied8%type;
--
l_amount_applied_from1    ar_payments_interface.amount_applied_from1%type;
l_amount_applied_from2    ar_payments_interface.amount_applied_from2%type;
l_amount_applied_from3    ar_payments_interface.amount_applied_from3%type;
l_amount_applied_from4    ar_payments_interface.amount_applied_from4%type;
l_amount_applied_from5    ar_payments_interface.amount_applied_from5%type;
l_amount_applied_from6    ar_payments_interface.amount_applied_from6%type;
l_amount_applied_from7    ar_payments_interface.amount_applied_from7%type;
l_amount_applied_from8    ar_payments_interface.amount_applied_from8%type;
--
/* declare variable for currency code of the receipt */
l_currency_code           ar_payments_interface.currency_code%type;
--
/* declare variables to hold the currency code from payment schedules */
ps_currency_code1         ar_payment_schedules.invoice_currency_code%type;
ps_currency_code2         ar_payment_schedules.invoice_currency_code%type;
ps_currency_code3         ar_payment_schedules.invoice_currency_code%type;
ps_currency_code4         ar_payment_schedules.invoice_currency_code%type;
ps_currency_code5         ar_payment_schedules.invoice_currency_code%type;
ps_currency_code6         ar_payment_schedules.invoice_currency_code%type;
ps_currency_code7         ar_payment_schedules.invoice_currency_code%type;
ps_currency_code8         ar_payment_schedules.invoice_currency_code%type;
--
/* Bug 883345:  need to retrieve the amount_due_remaining of the transaction*/

trx_amt_due_rem1          ar_payment_schedules.amount_due_remaining%type;
trx_amt_due_rem2          ar_payment_schedules.amount_due_remaining%type;
trx_amt_due_rem3          ar_payment_schedules.amount_due_remaining%type;
trx_amt_due_rem4          ar_payment_schedules.amount_due_remaining%type;
trx_amt_due_rem5          ar_payment_schedules.amount_due_remaining%type;
trx_amt_due_rem6          ar_payment_schedules.amount_due_remaining%type;
trx_amt_due_rem7          ar_payment_schedules.amount_due_remaining%type;
trx_amt_due_rem8          ar_payment_schedules.amount_due_remaining%type;
amt_applied_from_tc       ar_payments_interface.amount_applied_from1%type;

l_receipt_date            ar_payments_interface.receipt_date%type;
--
/* temporary variables used to check if amount_applied, amount_applied_from
   and trans_to_receipt rates are given */
l_temp_amt_applied        ar_payments_interface.amount_applied1%type;
l_temp_amt_applied_from   ar_payments_interface.amount_applied_from1%type;
l_temp_trans_to_receipt_rate ar_payments_interface.trans_to_receipt_rate1%type;
--
/* Added to fix Bug 1052313 */
l_resolved_matching1_date ar_payments_interface.resolved_matching1_date%type;
l_resolved_matching2_date ar_payments_interface.resolved_matching1_date%type;
l_resolved_matching3_date ar_payments_interface.resolved_matching1_date%type;
l_resolved_matching4_date ar_payments_interface.resolved_matching1_date%type;
l_resolved_matching5_date ar_payments_interface.resolved_matching1_date%type;
l_resolved_matching6_date ar_payments_interface.resolved_matching1_date%type;
l_resolved_matching7_date ar_payments_interface.resolved_matching1_date%type;
l_resolved_matching8_date ar_payments_interface.resolved_matching1_date%type;

l_resolved_matching1_inst ar_payments_interface.resolved_matching1_installment%type;
l_resolved_matching2_inst ar_payments_interface.resolved_matching1_installment%type;
l_resolved_matching3_inst ar_payments_interface.resolved_matching1_installment%type;
l_resolved_matching4_inst ar_payments_interface.resolved_matching1_installment%type;
l_resolved_matching5_inst ar_payments_interface.resolved_matching1_installment%type;
l_resolved_matching6_inst ar_payments_interface.resolved_matching1_installment%type;
l_resolved_matching7_inst ar_payments_interface.resolved_matching1_installment%type;
l_resolved_matching8_inst ar_payments_interface.resolved_matching1_installment%type;

l_customer_id ar_payments_interface.customer_id%type;

/* Bugfix 1732391 */
l_no_batch_or_lb varchar2(2);

/* To fix bug 2066392 */
l_unformat_amount         ar_payments_interface.amount_applied1%type;
--

unexpected_program_error  EXCEPTION;
--
--
/* Modified cusrsor definition for bug 1052313 and 1087549. Added columns 3,4,5 to the
   select list */

   /*  Bug 1513671:  modified cursor because amount_applied was being rounded
       to precision of receipt currency */
   /*  Bug 2980051: Replaced l_only_one_lb with l_no_batch_or_lb  */

   CURSOR get_app_info IS
       select
         pi.rowid,
         pi.resolved_matching_number1,
	 pi.resolved_matching1_date,
	 pi.resolved_matching1_installment,
	 pi.customer_id,
         pi.trans_to_receipt_rate1,
         pi.invoice_currency_code1,
         pi.amount_applied1,
         decode(l_format_amount_applied_from1,'Y',
                round(pi.amount_applied_from1/power(10,fc.precision),
                      fc.precision),
                pi.amount_applied_from1),
         pi.resolved_matching_number2,
	 pi.resolved_matching2_date,
         pi.resolved_matching2_installment,
         pi.trans_to_receipt_rate2,
         pi.invoice_currency_code2,
         pi.amount_applied2,
         decode(l_format_amount_applied_from2,'Y',
                round(pi.amount_applied_from2/power(10,fc.precision),
                      fc.precision),
                pi.amount_applied_from2),
         pi.resolved_matching_number3,
	 pi.resolved_matching3_date,
         pi.resolved_matching3_installment,
         pi.trans_to_receipt_rate3,
         pi.invoice_currency_code3,
         pi.amount_applied3,
         decode(l_format_amount_applied_from3,'Y',
                round(pi.amount_applied_from3/power(10,fc.precision),
                      fc.precision),
                pi.amount_applied_from3),
         pi.resolved_matching_number4,
	 pi.resolved_matching4_date,
         pi.resolved_matching4_installment,
         pi.trans_to_receipt_rate4,
         pi.invoice_currency_code4,
         pi.amount_applied4,
         decode(l_format_amount_applied_from4,'Y',
                round(pi.amount_applied_from4/power(10,fc.precision),
                      fc.precision),
                pi.amount_applied_from4),
         pi.resolved_matching_number5,
	 pi.resolved_matching5_date,
         pi.resolved_matching5_installment,
         pi.trans_to_receipt_rate5,
         pi.invoice_currency_code5,
         pi.amount_applied5,
         decode(l_format_amount_applied_from5,'Y',
                round(pi.amount_applied_from5/power(10,fc.precision),
                      fc.precision),
                pi.amount_applied_from5),
         pi.resolved_matching_number6,
	 pi.resolved_matching6_date,
         pi.resolved_matching6_installment,
         pi.trans_to_receipt_rate6,
         pi.invoice_currency_code6,
         pi.amount_applied6,
         decode(l_format_amount_applied_from6,'Y',
                round(pi.amount_applied_from6/power(10,fc.precision),
                      fc.precision),
                pi.amount_applied_from6),
         pi.resolved_matching_number7,
	 pi.resolved_matching7_date,
         pi.resolved_matching7_installment,
         pi.trans_to_receipt_rate7,
         pi.invoice_currency_code7,
         pi.amount_applied7,
         decode(l_format_amount_applied_from7,'Y',
                round(pi.amount_applied_from7/power(10,fc.precision),
                      fc.precision),
                pi.amount_applied_from7),
         pi.resolved_matching_number8,
	 pi.resolved_matching8_date,
         pi.resolved_matching8_installment,
         pi.trans_to_receipt_rate8,
         pi.invoice_currency_code8,
         pi.amount_applied8,
         decode(l_format_amount_applied_from8,'Y',
                round(pi.amount_applied_from8/power(10,fc.precision),
                      fc.precision),
                pi.amount_applied_from8),
         pi.currency_code,         /* currency code of the receipt */
         pi.receipt_date
from   ar_payments_interface pi, fnd_currencies fc
       where  pi.transmission_id = l_transmission_id
       and    pi.record_type||'' in ( l_payment_rec_type, l_overflow_rec_type )
       and    pi.item_number = l_item_num
       and    pi.currency_code = fc.currency_code
       and    ( pi.batch_name = l_batch_name
                or
                ( pi.lockbox_number = l_lockbox_number
                  and
                  l_batches = 'N'
                )
                or
                l_no_batch_or_lb = 'Y'
              );
--
BEGIN
  l_format_amount1 := p_format_amount1;
  l_format_amount2 := p_format_amount2;
  l_format_amount3 := p_format_amount3;
  l_format_amount4 := p_format_amount4;
  l_format_amount5 := p_format_amount5;
  l_format_amount6 := p_format_amount6;
  l_format_amount7 := p_format_amount7;
  l_format_amount8 := p_format_amount8;
  l_format_amount_applied_from1 := p_format_amount_applied_from1;
  l_format_amount_applied_from2 := p_format_amount_applied_from2;
  l_format_amount_applied_from3 := p_format_amount_applied_from3;
  l_format_amount_applied_from4 := p_format_amount_applied_from4;
  l_format_amount_applied_from5 := p_format_amount_applied_from5;
  l_format_amount_applied_from6 := p_format_amount_applied_from6;
  l_format_amount_applied_from7 := p_format_amount_applied_from7;
  l_format_amount_applied_from8 := p_format_amount_applied_from8;
--
-- Assign Variables to local values:
--
  l_transmission_id := p_transmission_id;
  l_payment_rec_type := p_payment_rec_type;
  l_overflow_rec_type := p_overflow_rec_type;
  l_item_num := p_item_num;
  l_batch_name := p_batch_name;
  l_lockbox_number := p_lockbox_number;
  l_batches := p_batches;
  l_only_one_lb := p_only_one_lb;
  l_pay_unrelated_invoices := p_pay_unrelated_invoices;
  l_default_exchange_rate_type := p_default_exchange_rate_type;
  l_enable_cross_currency := enable_cross_currency;
/* Bugfix 1732391 */
  IF l_batches = 'N' AND l_only_one_lb = 'Y' THEN
      l_no_batch_or_lb := 'Y';
  ELSE
      l_no_batch_or_lb := 'N';
  END IF;

--

OPEN get_app_info;
  debug1('Opened cursor get_app_info.');
  --
  LOOP
  FETCH get_app_info INTO
      l_rowid,
      l_matching_number1,
      l_resolved_matching1_date,
      l_resolved_matching1_inst,
      l_customer_id,
      l_trans_to_receipt_rate1,
      l_invoice_currency_code1,
      l_amount_applied1,
      l_amount_applied_from1,
      l_matching_number2,
      l_resolved_matching2_date,
      l_resolved_matching2_inst,
      l_trans_to_receipt_rate2,
      l_invoice_currency_code2,
      l_amount_applied2,
      l_amount_applied_from2,
      l_matching_number3,
      l_resolved_matching3_date,
      l_resolved_matching3_inst,
      l_trans_to_receipt_rate3,
      l_invoice_currency_code3,
      l_amount_applied3,
      l_amount_applied_from3,
      l_matching_number4,
      l_resolved_matching4_date,
      l_resolved_matching4_inst,
      l_trans_to_receipt_rate4,
      l_invoice_currency_code4,
      l_amount_applied4,
      l_amount_applied_from4,
      l_matching_number5,
      l_resolved_matching5_date,
      l_resolved_matching5_inst,
      l_trans_to_receipt_rate5,
      l_invoice_currency_code5,
      l_amount_applied5,
      l_amount_applied_from5,
      l_matching_number6,
      l_resolved_matching6_date,
      l_resolved_matching6_inst,
      l_trans_to_receipt_rate6,
      l_invoice_currency_code6,
      l_amount_applied6,
      l_amount_applied_from6,
      l_matching_number7,
      l_resolved_matching7_date,
      l_resolved_matching7_inst,
      l_trans_to_receipt_rate7,
      l_invoice_currency_code7,
      l_amount_applied7,
      l_amount_applied_from7,
      l_matching_number8,
      l_resolved_matching8_date,
      l_resolved_matching8_inst,
      l_trans_to_receipt_rate8,
      l_invoice_currency_code8,
      l_amount_applied8,
      l_amount_applied_from8,
      l_currency_code,
      l_receipt_date;

  EXIT WHEN get_app_info%NOTFOUND;

/*   debug messages */
debug1('l_matching number 1 ' || l_matching_number1);
debug1('l_matching number 2 ' || l_matching_number2);
debug1('receipt_date  = ' || to_char(l_receipt_date));

 /* Bug 1585615.  Unhandled exception in calc_amt_applied if
 *  trans to receipt rate is zero.  If the rate is zero,
 *  we'll treat it as it is not specified (null).  */
 IF (l_trans_to_receipt_rate1 = 0) THEN
   l_trans_to_receipt_rate1 := NULL;
 END IF;
 IF (l_trans_to_receipt_rate2 = 0) THEN
   l_trans_to_receipt_rate2 := NULL;
 END IF;
 IF (l_trans_to_receipt_rate3 = 0) THEN
   l_trans_to_receipt_rate3 := NULL;
 END IF;
 IF (l_trans_to_receipt_rate4 = 0) THEN
   l_trans_to_receipt_rate4 := NULL;
 END IF;
 IF (l_trans_to_receipt_rate5 = 0) THEN
   l_trans_to_receipt_rate5 := NULL;
 END IF;
 IF (l_trans_to_receipt_rate6 = 0) THEN
   l_trans_to_receipt_rate6 := NULL;
 END IF;
 IF (l_trans_to_receipt_rate7 = 0) THEN
   l_trans_to_receipt_rate7 := NULL;
 END IF;
 IF (l_trans_to_receipt_rate8 = 0) THEN
   l_trans_to_receipt_rate8 := NULL;
 END IF;

 IF (l_receipt_date IS NULL ) THEN
  /*  need to get receipt_date */
/* Bugfix 1732391. Replaced l_only_one_lockbox with l_no_batch_or_lb  */
     SELECT receipt_date
        INTO l_receipt_date
     FROM ar_payments_interface pi
     WHERE       pi.transmission_id = l_transmission_id
          and    pi.record_type||'' in ( l_payment_rec_type )
          and    pi.item_number = l_item_num
          and    ( pi.batch_name = l_batch_name
                   or
                   ( pi.lockbox_number = l_lockbox_number
                     and
                     l_batches = 'N'
                   )
                   or
                   l_no_batch_or_lb = 'Y'
                  );
 END IF;

debug1('receipt_date  = ' || to_char(l_receipt_date));

/* checking 1st trx_number */
debug1('invoice1 is not null =  ' || l_matching_number1);
IF (l_matching_number1 is not NULL) THEN

   /*  added trx_amt_due_rem for bug 883345 */
   /*  Changed the where clause and added the exception for bug 1052313
       and 1097549 */
    /**************************************************************************
    *  Following SQL checks to see if there are more than one transactions
    *  having the same transaction number for the same customer. If the count
    *  of such transactions having sum(amt_due_remaining) > 0, then it implies
    *  that Lockbox will not know to which transaction the receipt should apply
    *  to.Lockbox should be able to apply receipts to duplicate invoices if and
    *  if all the payment terms on either of the duplicate transactions is
    *  closed. If there is only one transaction , then application should be
    *  done to the minimum of the payment schedule that has status 'OPEN'.
    *  The following logic has been provided for all of the eight invoices
    *  that may be applied through Lockbox in one transmission file.
    **************************************************************************/
   BEGIN
        SELECT  sum(count(distinct ps.customer_trx_id))
        INTO    l_tot_trx1
        FROM    ar_payment_schedules ps
        WHERE   ps.trx_number = l_matching_number1
        AND     ps.trx_date = l_resolved_matching1_date /* Bug fix 2926664 */
        AND    (ps.customer_id  IN
                (
                   select l_customer_id from dual
                   union
                   select related_cust_account_id
                   from   hz_cust_acct_relate rel
                   where  rel.cust_account_id = l_customer_id
                   and    rel.status = 'A'
                   and    rel.bill_to_flag = 'Y'
                   union
                   select rel.related_cust_account_id
                   from   ar_paying_relationships_v rel,
                          hz_cust_accounts acc
                   where  rel.party_id = acc.party_id
                   and    acc.cust_account_id = l_customer_id
                   and    l_receipt_date BETWEEN effective_start_date
                                             AND effective_end_date
                )
                or
                l_pay_unrelated_invoices = 'Y'
               )
        GROUP BY ps.customer_trx_id
        HAVING sum(ps.amount_due_remaining) <> 0;

        IF (l_tot_trx1 > 1) then
                update ar_payments_interface pi
                set    invoice1_status = 'AR_PLB_DUP_INV'
                where rowid = l_rowid;
                goto END_1;
        ELSE
                SELECT  invoice_currency_code,
                        amount_due_remaining
                INTO    ps_currency_code1,
                        trx_amt_due_rem1
                FROM    ar_payment_schedules ps,
                        ra_cust_trx_types    tt
                WHERE   ps.trx_number = l_matching_number1
                AND     ps.status = decode(tt.allow_overapplication_flag,
                               'N', 'OP',
                                ps.status)
                AND     ps.class NOT IN ('PMT','GUAR')
                AND     ps.payment_schedule_id =
                         (select min(ps.payment_schedule_id)
                          from   ar_payment_schedules ps,
                                 ra_cust_trx_types    tt
                          where  ps.trx_number = l_matching_number1
                          and    ps.trx_date = l_resolved_matching1_date /* Bug fix 2926664 */
                          and    (ps.customer_id  IN
                                   (
                                      select l_customer_id from dual
                                      union
                                      select related_cust_account_id
                                      from   hz_cust_acct_relate rel
                                      where  rel.cust_account_id
                                             = l_customer_id
                                      and    rel.status = 'A'
                                      and    rel.bill_to_flag = 'Y'
                                      union
                                      select rel.related_cust_account_id
                                      from   ar_paying_relationships_v rel,
                                             hz_cust_accounts acc
                                      where  rel.party_id = acc.party_id
                                      and    acc.cust_account_id
                                             = l_customer_id
                                      and    l_receipt_date
                                             BETWEEN effective_start_date
                                                 AND effective_end_date
                                   )
                                   or
                                   l_pay_unrelated_invoices = 'Y'
                                 )
                          and    ps.cust_trx_type_id = tt.cust_trx_type_id
                          and    ps.class NOT IN ('PMT','GUAR')
                          and    ps.status=decode(tt.allow_overapplication_flag,
                                                     'N', 'OP',
                                                     ps.status))
                AND    (ps.customer_id  IN
                 (
                   select l_customer_id from dual
                   union
                   select related_cust_account_id
                   from   hz_cust_acct_relate rel
                   where  rel.cust_account_id = l_customer_id
                   and    rel.status = 'A'
                   and    rel.bill_to_flag = 'Y'
                   union
                   select rel.related_cust_account_id
                   from   ar_paying_relationships_v rel,
                          hz_cust_accounts acc
                   where  rel.party_id = acc.party_id
                   and    acc.cust_account_id = l_customer_id
                   and    l_receipt_date BETWEEN effective_start_date
                                             AND effective_end_date
                 )
                 or
                 l_pay_unrelated_invoices = 'Y'
                )
                AND     ps.cust_trx_type_id = tt.cust_trx_type_id;
        END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       goto END_1;
   END;

  debug1('currency code1 of invoice from the ps = ' || ps_currency_code1);
  /********************************************************
   *   if transmission has null currency code use the one
   *   from Payment Schedules
   *********************************************************/
  IF (l_invoice_currency_code1 is NULL ) THEN
    debug1('currency code is null.. setting = ' || ps_currency_code1);
    l_invoice_currency_code1 := ps_currency_code1;

     /* update ar_payment_interface to have the invoice currency_code */
     UPDATE ar_payments_interface
        SET invoice_currency_code1 = l_invoice_currency_code1
     WHERE rowid = l_rowid ;
  END IF;   /* end if invoice currency code was null */

  /****************************************************************
   * check to see if the currency code matches or is was not included
   * in the transmission
   ****************************************************************/
   debug1('l_invoice_currency_code1 = ' || l_invoice_currency_code1);
   debug1('ps_currency_code = ' || ps_currency_code1);

   IF  (l_invoice_currency_code1 <> ps_currency_code1) then
    debug1('currency code give does not match payment schedules..');
    UPDATE AR_PAYMENTS_INTERFACE
        SET invoice1_status = 'AR_PLB_CURRENCY_BAD'
    WHERE rowid = l_rowid ;
   ELSE
       /* Bug:1513671 we know the invoice currency code so we can now format the
          amount applied if we need to */

       IF (p_format_amount1 = 'Y') THEN
          fnd_currency.Get_Info(l_invoice_currency_code1,
                                l_precision,
                                l_extended_precision,
                                l_mau);
          l_amount_applied1 := round(l_amount_applied1 / power(10, l_precision),
                                     l_precision);
       END IF;

      /*************************************************************
       * if the currency code of the transaction does not equal the
       *  currency code of the receipt, then check for cross currency
       *  or Euro case
       **************************************************************/
      IF ( l_invoice_currency_code1 <> l_currency_code) THEN
       debug1('currency code of receipt does not match currency code of inv');

       /***********************************************************
        * we need to check to see if we have cross currency
        * profile enabled or we are dealing with a fixed rate
        * currency
        ************************************************************/

         l_is_fixed_rate := gl_currency_api.is_fixed_rate(
                            l_currency_code,      /*receipt currency */
                            l_invoice_currency_code1,  /* inv currency */
                            nvl(l_receipt_date,sysdate));

         debug1('is this a fixed rate = ' || l_is_fixed_rate);
         debug1('is cross curr enabled??  ' || l_enable_cross_currency);

         IF ( (l_is_fixed_rate = 'Y')  or
              (l_enable_cross_currency = 'Y')) THEN
           /* we have to make sure that all fields are populated */

            IF ( (l_amount_applied_from1 IS NULL) or
                 (l_amount_applied1 IS NULL)  or
                 (l_trans_to_receipt_rate1 IS NULL) )  THEN

             /* we need to check the rate 1st.  If both amounts columns are
                populated, then we calculate the rate.   If one amount is
                missing and the rate is null, then we try to get the rate from
                GL based on the profile option */

                IF ( l_trans_to_receipt_rate1 is NULL) THEN
                     debug1('trans_to_receipt_rate1 is null');
                  /* if neither amount is null then we calculate the rate */

                     debug1('amount applied = ' || to_char(l_amount_applied1));
                     debug1('amount applied from = ' || to_char(l_amount_applied_from1));
                     IF ( (l_amount_applied1 IS NOT NULL) and
                          (l_amount_applied_from1 IS NOT NULL)) Then

                          /********************************************
                           *  if we have a fixed rate, we need to get the
                           *  rate from GL and verify the validity of the
                           *  2 amount columns with the rate that we get
                           **********************************************/
                          IF (l_is_fixed_rate = 'Y') THEN
                             /* get the fixed rate from GL */
                             l_trans_to_receipt_rate1 :=
                                    gl_currency_api.get_rate(
                                           l_invoice_currency_code1,
                                           l_currency_code,
                                           l_receipt_date);

                             /*************************************************
                              *  if all fields are populated, we need to
                              *  check to make sure that they are logically
                              *  correct.
                              ************************************************/
                              calc_amt_applied_fmt(l_invoice_currency_code1,
                                               l_amount_applied_from1,
                                               l_trans_to_receipt_rate1,
                                               l_temp_amt_applied,
					       'N');

                              calc_amt_applied_from_fmt(l_currency_code,
                                                    l_amount_applied1,
                                                    l_trans_to_receipt_rate1,
                                                    l_temp_amt_applied_from,
						    'N');

                              ar_cc_lockbox.calc_cross_rate(
                                                  l_amount_applied1,
                                                  l_amount_applied_from1,
                                                  l_invoice_currency_code1,
                                                  l_currency_code,
                                                  l_temp_trans_to_receipt_rate);
                              IF ( (l_temp_amt_applied = l_amount_applied1) OR
                                   (l_temp_amt_applied_from =
                                           l_amount_applied_from1)   OR
                                   (l_temp_trans_to_receipt_rate =
                                           l_trans_to_receipt_rate1)) THEN

                                /********************************************
                                 * since one or more of the conditions are
                                 * true then we assume that everything is
                                 * fine and we can write the rate to the
                                 * database
                                 *********************************************/
                                   debug1('validation passed ' );
                                   UPDATE ar_payments_interface
                                     SET trans_to_receipt_rate1 =
                                             l_trans_to_receipt_rate1
                                     WHERE rowid = l_rowid;
                                ELSE
                                  UPDATE AR_PAYMENTS_INTERFACE
                                    SET invoice1_status =
                                             'AR_PLB_CC_INVALID_VALUE'
                                   WHERE rowid = l_rowid;
                               END IF;

                          ELSE
                             /* calculate the least rate that would convert
                                the items */
                             ar_cc_lockbox.calc_cross_rate(
                                l_amount_applied1,
                                l_amount_applied_from1,
                                l_invoice_currency_code1,
                                l_currency_code,
                                l_trans_to_receipt_rate1);

                             /* once the rate has been calculated, we need
                                to write it to the table */
                             UPDATE ar_payments_interface
                                SET trans_to_receipt_rate1 =
                                   l_trans_to_receipt_rate1
                              WHERE rowid = l_rowid;
                          END IF;

                     ELSE
                       /* need to derive the rate if possible*/
                       debug1( 'need to derive rate ');
                       IF (p_default_exchange_rate_type IS NOT NULL or
                             l_is_fixed_rate = 'Y' ) THEN
                          l_trans_to_receipt_rate1 :=
                              gl_currency_api.get_rate_sql(
                                                l_invoice_currency_code1,
                                                l_currency_code,
                                                l_receipt_date,
                                                p_default_exchange_rate_type);
                     debug1('calculated rate = ' || to_char(l_trans_to_receipt_rate1));
                        /* if there is no rate in GL, there is nothing
                           more we can do */
                           IF (l_trans_to_receipt_rate1 < 0 )  THEN

                            UPDATE AR_PAYMENTS_INTERFACE
                               SET invoice1_status = 'AR_PLB_NO_EXCHANGE_RATE'
                                WHERE rowid = l_rowid;
                           ELSE
                             /* once the rate has been calculated, we need
                                to write it to the table */

                             debug1('writing rate to database ' || to_char(l_trans_to_receipt_rate1));

                             UPDATE ar_payments_interface
                                SET trans_to_receipt_rate1 =
                                   l_trans_to_receipt_rate1
                              WHERE rowid = l_rowid;

                             /* finish the calculation because we have a rate*/

                             IF (l_amount_applied_from1 IS NULL) THEN
                                calc_amt_applied_from_fmt(l_currency_code,
                                                      l_amount_applied1,
                                                      l_trans_to_receipt_rate1,
                                                      l_amount_applied_from1,
						      l_format_amount_applied_from1);
                                update ar_payments_interface
                                   set  amount_applied_from1 =
                                           l_amount_applied_from1
                                   where rowid = l_rowid;

                             ELSE
                              /* calculate amount applied and save to db */
                              calc_amt_applied_fmt(l_invoice_currency_code1,
                                               l_amount_applied_from1,
                                               l_trans_to_receipt_rate1,
                                               l_amount_applied1,
					       l_format_amount1);
                              debug1('calculated amt applied = ' || to_char(l_amount_applied1));

                              /* to deal with rounding errors that happen
                                 with fixed rate currencies, we need to
                                 take the amount_due_remaining of the trx
                                 convert it to the receipt currency and
                                 compare that value with the
                                 amount_applied_from original value

                                 ADDED for BUG 883345  */

                              IF (l_is_fixed_rate = 'Y') THEN

                                 calc_amt_applied_from_fmt(l_currency_code,
                                                       trx_amt_due_rem1,
                                                       l_trans_to_receipt_rate1,
                                                       amt_applied_from_tc,
						       'N');

 debug1('amt applied from tc = ' || to_char(amt_applied_from_tc));
 debug1('amt_applied_from1  = ' || to_char(l_amount_applied_from1));
 debug1('amt_applied_from with out NOCOPY  = ' || to_char(l_amount_applied_from1 * (10**l_precision) ));

                                  IF (amt_applied_from_tc =
                                       l_amount_applied_from1) THEN
				    IF (l_format_amount1 = 'Y') THEN
                                        fnd_currency.Get_Info(
                                             l_invoice_currency_code1,
                                             l_precision,
                                             l_extended_precision,
                                             l_mau);

                                     l_amount_applied1 :=
                                         trx_amt_due_rem1 * (10**l_precision);
				    ELSE
                                     l_amount_applied1 := trx_amt_due_rem1;
				    END IF;
                                  END IF;
                              END IF;

                               update ar_payments_interface
                                   set  amount_applied1 =
                                           l_amount_applied1
                                   where rowid = l_rowid;

                             END IF;   /* if amount_applied_From1 is null */
                           END IF;  /* if rate is null after it is calc */
                       ELSE /* bug 1519765 */
                            UPDATE AR_PAYMENTS_INTERFACE
                               SET invoice1_status = 'AR_PLB_NO_EXCHANGE_RATE'
                                WHERE rowid = l_rowid;
                       END IF;     /* if derive profile is not null */
                     END IF;

                  /*  we know that trans_to_receipt_rate1 is not null,
                      therefore, one of the amount values must be null and
                      we have to calculate it */
                  ELSE
                      /* is amount_applied_From null?? */
                      IF (l_amount_applied_from1 IS NULL) THEN
                         calc_amt_applied_from_fmt(l_currency_code,
                                               l_amount_applied1,
                                               l_trans_to_receipt_rate1,
                                               l_amount_applied_from1,
					       l_format_amount_applied_from1);
                          update ar_payments_interface
                            set  amount_applied_from1 =
                                      l_amount_applied_from1
                            where rowid = l_rowid;

                      ELSE
                         calc_amt_applied_fmt(l_invoice_currency_code1,
                                          l_amount_applied_from1,
                                          l_trans_to_receipt_rate1,
                                          l_amount_applied1,
					  l_format_amount1);

                         /* to deal with rounding errors that happen
                            with fixed rate currencies, we need to
                            take the amount_due_remaining of the trx
                            convert it to the receipt currency and
                            compare that value with the
                            amount_applied_from original value

                            ADDED for BUG 883345  */

                          IF (l_is_fixed_rate = 'Y') THEN

                             calc_amt_applied_from_fmt(l_currency_code,
                                                   trx_amt_due_rem1,
                                                   l_trans_to_receipt_rate1,
                                                   amt_applied_from_tc, 'N');

 debug1('amt applied from tc = ' || to_char(amt_applied_from_tc));
 debug1('amt_applied_from1  = ' || to_char(l_amount_applied_from1));
 debug1('amt_applied_from with out = ' || to_char(l_amount_applied_from1* (10**l_precision) ));

                             IF (amt_applied_from_tc =
                                  l_amount_applied_from1) THEN
			       IF (l_format_amount1 = 'Y') THEN
                                 fnd_currency.Get_Info(
                                         l_invoice_currency_code1,
                                         l_precision,
                                         l_extended_precision,
                                         l_mau);

                                 l_amount_applied1 :=
                                     trx_amt_due_rem1 * (10**l_precision);
			       ELSE
                                 l_amount_applied1 := trx_amt_due_rem1;
			       END IF;
                             END IF;
                          END IF;

                         UPDATE AR_PAYMENTS_INTERFACE
                              SET  amount_applied1 =
                                      l_amount_applied1
                              WHERE  rowid = l_rowid;

                      END IF;
                  END IF;   /* trans to receipt_rate 1 is null */
               ELSE
                  /*************************************************
                   *  if all fields are populated, we need to
                   *  check to make sure that they are logically
                   *  correct.
                   ***************************************************/

                   calc_amt_applied_fmt(l_invoice_currency_code1,
                                    l_amount_applied_from1,
                                    l_trans_to_receipt_rate1,
                                    l_temp_amt_applied,
				    'N');

                   calc_amt_applied_from_fmt(l_currency_code,
                                         l_amount_applied1,
                                         l_trans_to_receipt_rate1,
                                         l_temp_amt_applied_from,
					 'N');

                   ar_cc_lockbox.calc_cross_rate(
                                l_amount_applied1,
                                l_amount_applied_from1,
                                l_invoice_currency_code1,
                                l_currency_code,
                                l_temp_trans_to_receipt_rate);
                   IF ( (l_temp_amt_applied = l_amount_applied1) OR
                        (l_temp_amt_applied_from =
                                           l_amount_applied_from1)   OR
                        (l_temp_trans_to_receipt_rate =
                                           l_trans_to_receipt_rate1)) THEN

                       /* since one or more of the conditions are true
                          then we assume that everything is fine. */
                          debug1('validation passed ' );
                    ELSE
                         UPDATE AR_PAYMENTS_INTERFACE
                              SET invoice1_status = 'AR_PLB_CC_INVALID_VALUE'
                         WHERE rowid = l_rowid;
                    END IF;

               END IF;   /* if one of the 3 items is NULL */
            ELSE
                 /*****************************************************
                    currencies do not match, they are not fixed rate and
                    cross currency enabled profile is not on.
                    then set the status to be a currency conflict between
                    the invoice and receipt currencies
                   ***************************************************/
                 UPDATE AR_PAYMENTS_INTERFACE
                      SET invoice1_status = 'AR_PLB_CURR_CONFLICT'
                         WHERE rowid = l_rowid;
            END IF;
	  ELSE /* Bug 2066392.  Single currency */
	    IF l_amount_applied_from1 is not null THEN
	      IF l_amount_applied1 is not null THEN
		IF l_amount_applied_from1 <> l_amount_applied1 THEN
		  UPDATE AR_PAYMENTS_INTERFACE
		      SET invoice1_status = 'AR_PLB_CC_INVALID_VALUE'
		  WHERE rowid = l_rowid;
		END IF;
	      ELSE
		IF l_format_amount1 = 'Y' THEN
		  fnd_currency.Get_Info(l_invoice_currency_code1,
                                l_precision,
                                l_extended_precision,
                                l_mau);
		  l_unformat_amount := l_amount_applied_from1 * power(10, l_precision);
		ELSE
		  l_unformat_amount := l_amount_applied_from1;
		END IF;
		UPDATE AR_PAYMENTS_INTERFACE
		      SET  amount_applied1 = l_unformat_amount
		      WHERE  rowid = l_rowid;
	      END IF;
	    END IF;
          END IF;
      END IF;
   END IF;   /* if matching number 1 is not null */
<<END_1>>

   /****************   need to check matching number 2 *************/

/* checking 2st trx_number */
debug1('invoice2 is not null ' || l_matching_number2);
IF (l_matching_number2 IS NOT NULL) THEN

   /*  added trx_amt_due_rem2 for bug 883345 */
   /*  Changed the where clause and added the exception for bug 1052313
       and 1097549 */
   BEGIN
        SELECT  sum(count(distinct ps.customer_trx_id))
        INTO    l_tot_trx2
        FROM    ar_payment_schedules ps
        WHERE   ps.trx_number = l_matching_number2
        AND     ps.trx_date = l_resolved_matching2_date /* Bug fix 2926664 */
        AND    (ps.customer_id  IN
                (
                   select l_customer_id from dual
                   union
                   select related_cust_account_id
                   from   hz_cust_acct_relate rel
                   where  rel.cust_account_id = l_customer_id
                   and    rel.status = 'A'
                   and    rel.bill_to_flag = 'Y'
                   union
                   select rel.related_cust_account_id
                   from   ar_paying_relationships_v rel,
                          hz_cust_accounts acc
                   where  rel.party_id = acc.party_id
                   and    acc.cust_account_id = l_customer_id
                   and    l_receipt_date BETWEEN effective_start_date
                                             AND effective_end_date
                )
                or
                l_pay_unrelated_invoices = 'Y'
               )
        GROUP BY ps.customer_trx_id
        HAVING sum(ps.amount_due_remaining) <> 0;

        IF (l_tot_trx2 > 1) then
                update ar_payments_interface pi
                set    invoice2_status = 'AR_PLB_DUP_INV'
                where rowid = l_rowid;
                goto END_2;
        ELSE
                SELECT  invoice_currency_code,
                        amount_due_remaining
                INTO    ps_currency_code2,
                        trx_amt_due_rem2
                FROM    ar_payment_schedules ps,
                        ra_cust_trx_types    tt
                WHERE   ps.trx_number = l_matching_number2
                AND     ps.status = decode(tt.allow_overapplication_flag,
                               'N', 'OP',
                                ps.status)
                AND     ps.class NOT IN ('PMT','GUAR')
                AND     ps.payment_schedule_id =
                        (select min(ps.payment_schedule_id)
                         from   ar_payment_schedules ps,
                                ra_cust_trx_types    tt
                         where  ps.trx_number = l_matching_number2
                         and    ps.trx_date = l_resolved_matching2_date /* Bug fix 2926664 */
                         and    (ps.customer_id  IN
                                   (
                                      select l_customer_id from dual
                                      union
                                      select related_cust_account_id
                                      from   hz_cust_acct_relate rel
                                      where  rel.cust_account_id
                                             = l_customer_id
                                      and    rel.status = 'A'
                                      and    rel.bill_to_flag = 'Y'
                                      union
                                      select rel.related_cust_account_id
                                      from   ar_paying_relationships_v rel,
                                             hz_cust_accounts acc
                                      where  rel.party_id = acc.party_id
                                      and    acc.cust_account_id
                                             = l_customer_id
                                      and    l_receipt_date
                                             BETWEEN effective_start_date
                                                 AND effective_end_date
                                   )
                                   or
                                   l_pay_unrelated_invoices = 'Y'
                                 )
                         and    ps.cust_trx_type_id = tt.cust_trx_type_id
                         and    ps.class NOT IN ('PMT','GUAR')
                         and ps.status=decode(tt.allow_overapplication_flag,
						'N' , 'OP',
                                            ps.status))
                AND    (ps.customer_id  IN
                 (
                   select l_customer_id from dual
                   union
                   select related_cust_account_id
                   from   hz_cust_acct_relate rel
                   where  rel.cust_account_id = l_customer_id
                   and    rel.status = 'A'
                   and    rel.bill_to_flag = 'Y'
                   union
                   select rel.related_cust_account_id
                   from   ar_paying_relationships_v rel,
                          hz_cust_accounts acc
                   where  rel.party_id = acc.party_id
                   and    acc.cust_account_id = l_customer_id
                   and    l_receipt_date BETWEEN effective_start_date
                                             AND effective_end_date
                 )
                 or
                 l_pay_unrelated_invoices = 'Y'
                )
                AND     ps.cust_trx_type_id = tt.cust_trx_type_id;
        END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       goto END_2;
   END;

   debug1('currency code of ps = ' || ps_currency_code2);
  /********************************************************
   *   if transmission has null currency code use the one
   *   from Payment Schedules
   *********************************************************/
  IF (l_invoice_currency_code2 is NULL ) THEN
      debug1('currency code is null.. set equal to ps currency code');
      l_invoice_currency_code2 := ps_currency_code2;

      UPDATE ar_payments_interface pi
         SET pi.invoice_currency_code2 = l_invoice_currency_code2
       WHERE  rowid = l_rowid;
  END IF;  /* end if invoice currency is NULL */

  /****************************************************************
   * check to see if the currency code matches or is was not included
   * in the transmission
   ****************************************************************/
   debug1('l_invoice_currency_code2 = ' || l_invoice_currency_code2);
   debug1('ps_currency_code2 = ' || ps_currency_code2);

   /* ------------------ Bug# 2066679 --------------------- */

   IF  (l_invoice_currency_code2 <> ps_currency_code2) then
     debug1('currency code given does not match payment schedules..');
     UPDATE AR_PAYMENTS_INTERFACE
        SET invoice2_status = 'AR_PLB_CURRENCY_BAD'
     WHERE rowid = l_rowid;
   ELSE
       /* Bug:1513671 we know the invoice currency code so we can now format the
          amount applied if we need to */

       IF (p_format_amount2 = 'Y') THEN
          fnd_currency.Get_Info(l_invoice_currency_code2,
                                l_precision,
                                l_extended_precision,
                                l_mau);
          l_amount_applied2 := round(l_amount_applied2 / power(10, l_precision),
                                     l_precision);
       END IF;

      /*************************************************************
       * if the currency code of the transaction does not equal the
       *  currency code of the receipt, then check for cross currency
       *  or Euro case
       **************************************************************/
      IF ( l_invoice_currency_code2 <> l_currency_code) THEN
       debug1('currency code of receipt does not match currency code of inv');

      /***********************************************************
        * we need to check to see if we have cross currency
        * profile enabled or we are dealing with a fixed rate
        * currency
        ************************************************************/

         l_is_fixed_rate := gl_currency_api.is_fixed_rate(
                            l_currency_code,      /*receipt currency */
                            l_invoice_currency_code2,  /* inv currency */
                            nvl(l_receipt_date,sysdate));
         debug1('is this a fixed rate = ' || l_is_fixed_rate);
         debug1('is cross curr enabled??  ' || l_enable_cross_currency);
         IF ( (l_is_fixed_rate = 'Y')  or
              (l_enable_cross_currency = 'Y')) THEN
           /* we have to make sure that all fields are populated */

            IF ( (l_amount_applied_from2 IS NULL) or
                 (l_amount_applied2 IS NULL)  or
                 (l_trans_to_receipt_rate2 IS NULL) )  THEN

             /* we need to check the rate 1st.  If both amounts columns are
                populated, then we calculate the rate.   If one amount is
                missing and the rate is null, then we try to get the rate from
                GL based on the profile option */

                IF ( l_trans_to_receipt_rate2 is NULL) THEN
                   debug1('trans_to_receipt_rate2 is Null');
                  /* if neither amount is null then we calculate the rate */
                     IF ( (l_amount_applied2 IS NOT NULL) and
                          (l_amount_applied_from2 IS NOT NULL)) Then

                          /********************************************
                           *  if we have a fixed rate, we need to get the
                           *  rate from GL and verify the validity of the
                           *  2 amount columns with the rate that we get
                           **********************************************/

                          IF (l_is_fixed_rate = 'Y') THEN
                             /* get the fixed rate from GL */
                             l_trans_to_receipt_rate2 :=
                                    gl_currency_api.get_rate(
                                            l_invoice_currency_code2,
                                            l_currency_code,
                                            l_receipt_date);
                             /*************************************************
                              *  if all fields are populated, we need to
                              *  check to make sure that they are logically
                              *  correct.
                              ************************************************/

                              calc_amt_applied_fmt(l_invoice_currency_code2,
                                               l_amount_applied_from2,
                                               l_trans_to_receipt_rate2,
                                               l_temp_amt_applied,
					       'N');

                              calc_amt_applied_from_fmt(l_currency_code,
                                                    l_amount_applied2,
                                                    l_trans_to_receipt_rate2,
                                                    l_temp_amt_applied_from,
						    'N');

                              ar_cc_lockbox.calc_cross_rate(
                                                  l_amount_applied2,
                                                  l_amount_applied_from2,
                                                  l_invoice_currency_code2,
                                                  l_currency_code,
                                                  l_temp_trans_to_receipt_rate);

                              IF ( (l_temp_amt_applied = l_amount_applied2) OR
                                   (l_temp_amt_applied_from =
                                           l_amount_applied_from2)   OR
                                   (l_temp_trans_to_receipt_rate =
                                           l_trans_to_receipt_rate2)) THEN

                                 /********************************************
                                 * since one or more of the conditions are
                                 * true then we assume that everything is
                                 * fine and we can write the rate to the
                                 * database
                                 *********************************************/
                                   debug1('validation passed ' );

                                   UPDATE ar_payments_interface
                                     SET trans_to_receipt_rate2 =
                                             l_trans_to_receipt_rate2
                                     WHERE rowid = l_rowid;
                                ELSE
                                  UPDATE AR_PAYMENTS_INTERFACE
                                    SET invoice2_status =
                                             'AR_PLB_CC_INVALID_VALUE'
                                   WHERE rowid = l_rowid;
                               END IF;
                         ELSE
                            /* calculate the least rate that would convert
                            the items */
                            ar_cc_lockbox.calc_cross_rate(
                                l_amount_applied2,
                                l_amount_applied_from2,
                                l_invoice_currency_code2,
                                l_currency_code,
                                l_trans_to_receipt_rate2);

                             /* once the rate has been calculated, we need
                                to write it to the table */
                             UPDATE ar_payments_interface
                                SET trans_to_receipt_rate2 =
                                   l_trans_to_receipt_rate2
                              WHERE rowid = l_rowid;
                         END IF;

                     ELSE
                         /* need to derive the rate if possible*/
                       IF (p_default_exchange_rate_type IS NOT NULL or
                             l_is_fixed_rate = 'Y' ) THEN
                          l_trans_to_receipt_rate2 :=
                              gl_currency_api.get_rate_sql(
                                                l_invoice_currency_code2,
                                                l_currency_code,
                                                l_receipt_date,
                                                p_default_exchange_rate_type);
                          debug1('calculated rate = ' || to_char(l_trans_to_receipt_rate2));

                        /* if there is no rate in GL, there is nothing
                           more we can do */
                           IF (l_trans_to_receipt_rate2 < 0)  THEN

                            UPDATE AR_PAYMENTS_INTERFACE
                               SET invoice2_status = 'AR_PLB_NO_EXCHANGE_RATE'
                                WHERE rowid = l_rowid;
                           ELSE
                             /* once the rate has been calculated, we need
                                to write it to the table */

                             debug1('writing rate to database ' || to_char(l_trans_to_receipt_rate2));

                             UPDATE ar_payments_interface
                                SET trans_to_receipt_rate2 =
                                   l_trans_to_receipt_rate2
                              WHERE rowid = l_rowid;

                             /* finish the calculation because we have a rate*/
                             IF (l_amount_applied_from2 IS NULL) THEN
                                calc_amt_applied_from_fmt(l_currency_code,
                                                      l_amount_applied2,
                                                      l_trans_to_receipt_rate2,
                                                      l_amount_applied_from2,
						      l_format_amount_applied_from2);
                                /* once we calculate the value, we need
                                   to write it to the table */
                                 UPDATE ar_payments_interface
                                   SET  amount_applied_from2 =
                                             l_amount_applied_from2
                                   WHERE  rowid = l_rowid;

                              ELSE
                                calc_amt_applied_fmt(l_invoice_currency_code2,
                                               l_amount_applied_from2,
                                               l_trans_to_receipt_rate2,
                                               l_amount_applied2,
					       l_format_amount2);

                              /* to deal with rounding errors that happen
                                 with fixed rate currencies, we need to
                                 take the amount_due_remaining of the trx
                                 convert it to the receipt currency and
                                 compare that value with the
                                 amount_applied_from original value

                                 ADDED for BUG 883345  */

                              IF (l_is_fixed_rate = 'Y') THEN

                                 calc_amt_applied_from_fmt(l_currency_code,
                                                       trx_amt_due_rem2,
                                                       l_trans_to_receipt_rate2,
                                                       amt_applied_from_tc,
						       'N');

                                  IF (amt_applied_from_tc =
                                       l_amount_applied_from2) THEN
				    IF (l_format_amount2 = 'Y') THEN
                                        fnd_currency.Get_Info(
                                             l_invoice_currency_code2,
                                             l_precision,
                                             l_extended_precision,
                                             l_mau);

                                     l_amount_applied2 :=
                                         trx_amt_due_rem2 * (10**l_precision);
				    ELSE
                                     l_amount_applied2 := trx_amt_due_rem2;
				    END IF;
                                  END IF;
                              END IF;


                                 UPDATE ar_payments_interface
                                   SET  amount_applied2 =
                                             l_amount_applied2
                                   WHERE rowid = l_rowid;

                             END IF;   /* if amount_applied_From2 is null */
                           END IF;  /* if rate is null after it is calc */
                       ELSE       /* Bug 1519765 */
                            UPDATE AR_PAYMENTS_INTERFACE
                               SET invoice2_status = 'AR_PLB_NO_EXCHANGE_RATE'
                                WHERE rowid = l_rowid;
                       END IF;     /* if derive profile is not null */
                     END IF;

                  /*  we know that trans_to_receipt_rate2 is not null,
                      therefore, one of the amount values must be null and
                      we have to calculate it */
                  ELSE
                      /* is amount_applied_From null?? */
                      IF (l_amount_applied_from2 IS NULL) THEN
                         calc_amt_applied_from_fmt(l_currency_code,
                                               l_amount_applied2,
                                               l_trans_to_receipt_rate2,
                                               l_amount_applied_from2,
					       l_format_amount_applied_from2);
                          UPDATE ar_payments_interface
                             SET  amount_applied_from2 =
                                           l_amount_applied_from2
                             WHERE rowid = l_rowid;

                      ELSE
                         calc_amt_applied_fmt(l_invoice_currency_code2,
                                          l_amount_applied_from2,
                                          l_trans_to_receipt_rate2,
                                          l_amount_applied2,
					  l_format_amount2);


                         /* to deal with rounding errors that happen
                            with fixed rate currencies, we need to
                            take the amount_due_remaining of the trx
                            convert it to the receipt currency and
                            compare that value with the
                            amount_applied_from original value

                            ADDED for BUG 883345  */

                          IF (l_is_fixed_rate = 'Y') THEN

                             calc_amt_applied_from_fmt(l_currency_code,
                                                   trx_amt_due_rem2,
                                                   l_trans_to_receipt_rate2,
                                                   amt_applied_from_tc,
						   'N');

                             IF (amt_applied_from_tc =
                                  l_amount_applied_from2 ) THEN
			       IF (l_format_amount2 = 'Y') THEN
                                 fnd_currency.Get_Info(
                                         l_invoice_currency_code2,
                                         l_precision,
                                         l_extended_precision,
                                         l_mau);

                                 l_amount_applied2 :=
                                     trx_amt_due_rem2 * (10**l_precision);

			       ELSE
                                 l_amount_applied2 := trx_amt_due_rem2;
			       END IF;
                             END IF;
                          END IF;


                         UPDATE ar_payments_interface
                             SET  amount_applied2 =
                                         l_amount_applied2
                             WHERE rowid = l_rowid;

                      END IF;
                  END IF;   /* trans to receipt_rate 2 is null */
             ELSE
                  /*************************************************
                   *  if all fields are populated, we need to
                   *  check to make sure that they are logically
                   *  correct.
                   ***************************************************/

                   calc_amt_applied_fmt(l_invoice_currency_code2,
                                    l_amount_applied_from2,
                                    l_trans_to_receipt_rate2,
                                    l_temp_amt_applied,
				    'N');

                   calc_amt_applied_from_fmt(l_currency_code,
                                     l_amount_applied2,
                                     l_trans_to_receipt_rate2,
                                     l_temp_amt_applied_from,
				     'N');

                   ar_cc_lockbox.calc_cross_rate(
                                l_amount_applied2,
                                l_amount_applied_from2,
                                l_invoice_currency_code2,
                                l_currency_code,
                                l_temp_trans_to_receipt_rate);
                      IF ( (l_temp_amt_applied = l_amount_applied2) OR
                           (l_temp_amt_applied_from =
                                           l_amount_applied_from2)   OR
                           (l_temp_trans_to_receipt_rate =
                                           l_trans_to_receipt_rate2)) THEN

                           /* since one or more of the conditions are true
                            then we assume that everything is fine. */
                           debug1('validation passed ' );
                      ELSE
                         UPDATE AR_PAYMENTS_INTERFACE
                              SET invoice2_status = 'AR_PLB_CC_INVALID_VALUE'
                         WHERE rowid = l_rowid;
                      END IF;
               END IF;   /* if one of the 3 items is NULL */
            ELSE
                /*****************************************************
                 currencies do not match, they are not fixed rate and
                 cross currency enabled profile is not on.
                 then set the status to be a currency conflict between
                 the invoice and receipt currencies
                 ***************************************************/
              UPDATE AR_PAYMENTS_INTERFACE
                  SET invoice2_status = 'AR_PLB_CURR_CONFLICT'
                    WHERE rowid = l_rowid;
            END IF;
	  ELSE /* Bug 2066392.  Single currency */
	    IF l_amount_applied_from2 is not null THEN
	      IF l_amount_applied2 is not null THEN
		IF l_amount_applied_from2 <> l_amount_applied2 THEN
		  UPDATE AR_PAYMENTS_INTERFACE
		      SET invoice2_status = 'AR_PLB_CC_INVALID_VALUE'
		  WHERE rowid = l_rowid;
		END IF;
	      ELSE
		IF l_format_amount2 = 'Y' THEN
		  fnd_currency.Get_Info(l_invoice_currency_code2,
                                l_precision,
                                l_extended_precision,
                                l_mau);
		  l_unformat_amount := l_amount_applied_from2 * power(10, l_precision);
		ELSE
		  l_unformat_amount := l_amount_applied_from2;
		END IF;
		UPDATE AR_PAYMENTS_INTERFACE
		      SET  amount_applied2 = l_unformat_amount
		      WHERE  rowid = l_rowid;
	      END IF;
	    END IF;
          END IF;
      END IF;
   END IF;   /* if matching number 2 is not null */
<<END_2>>

/************************** checking 3rd trx_number *************************/

debug1('invoice3 is not null =  ' || l_matching_number3);
IF (l_matching_number3 is not NULL) THEN

   /*  added trx_amt_due_remX for bug 883345 */
   /*  Changed the where clause and added the exception for bug 1052313
       and 1097549 */
   BEGIN
        SELECT  sum(count(distinct ps.customer_trx_id))
        INTO    l_tot_trx3
        FROM    ar_payment_schedules ps
        WHERE   ps.trx_number = l_matching_number3
        AND     ps.trx_date = l_resolved_matching3_date /* Bug fix 2926664 */
        AND    (ps.customer_id  IN
                 (
                   select l_customer_id from dual
                   union
                   select related_cust_account_id
                   from   hz_cust_acct_relate rel
                   where  rel.cust_account_id = l_customer_id
                   and    rel.status = 'A'
                   and    rel.bill_to_flag = 'Y'
                   union
                   select rel.related_cust_account_id
                   from   ar_paying_relationships_v rel,
                          hz_cust_accounts acc
                   where  rel.party_id = acc.party_id
                   and    acc.cust_account_id = l_customer_id
                   and    l_receipt_date BETWEEN effective_start_date
                                             AND effective_end_date
                 )
                 or
                 l_pay_unrelated_invoices = 'Y'
                )
        GROUP BY ps.customer_trx_id
        HAVING sum(ps.amount_due_remaining) <> 0;

        IF (l_tot_trx3 > 1) then
                update ar_payments_interface pi
                set    invoice3_status = 'AR_PLB_DUP_INV'
                where rowid = l_rowid;
                goto END_3;
        ELSE
                SELECT  invoice_currency_code,
                        amount_due_remaining
                INTO    ps_currency_code3,
                        trx_amt_due_rem3
                FROM    ar_payment_schedules ps,
                        ra_cust_trx_types    tt
                WHERE   ps.trx_number = l_matching_number3
                AND     ps.status = decode(tt.allow_overapplication_flag,
                               'N', 'OP',
                                ps.status)
                AND     ps.class NOT IN ('PMT','GUAR')
                AND     ps.payment_schedule_id =
                        (select min(ps.payment_schedule_id)
                         from   ar_payment_schedules ps,
                                ra_cust_trx_types    tt
                         where  ps.trx_number = l_matching_number3
                         and    ps.trx_date = l_resolved_matching3_date /* Bug fix 2926664 */
                         and    (ps.customer_id  IN
                                   (
                                      select l_customer_id from dual
                                      union
                                      select related_cust_account_id
                                      from   hz_cust_acct_relate rel
                                      where  rel.cust_account_id
                                             = l_customer_id
                                      and    rel.status = 'A'
                                      and    rel.bill_to_flag = 'Y'
                                      union
                                      select rel.related_cust_account_id
                                      from   ar_paying_relationships_v rel,
                                             hz_cust_accounts acc
                                      where  rel.party_id = acc.party_id
                                      and    acc.cust_account_id
                                             = l_customer_id
                                      and    l_receipt_date
                                             BETWEEN effective_start_date
                                                 AND effective_end_date
                                   )
                                   or
                                   l_pay_unrelated_invoices = 'Y'
                                 )
                         and    ps.cust_trx_type_id = tt.cust_trx_type_id
                         and    ps.class NOT IN ('PMT','GUAR')
                         and ps.status=decode(tt.allow_overapplication_flag,
						'N','OP',
                                            ps.status))
                AND    (ps.customer_id  IN
                 (
                   select l_customer_id from dual
                   union
                   select related_cust_account_id
                   from   hz_cust_acct_relate rel
                   where  rel.cust_account_id = l_customer_id
                   and    rel.status = 'A'
                   and    rel.bill_to_flag = 'Y'
                   union
                   select rel.related_cust_account_id
                   from   ar_paying_relationships_v rel,
                          hz_cust_accounts acc
                   where  rel.party_id = acc.party_id
                   and    acc.cust_account_id = l_customer_id
                   and    l_receipt_date BETWEEN effective_start_date
                                             AND effective_end_date
                 )
                 or
                 l_pay_unrelated_invoices = 'Y'
                )
                AND     ps.cust_trx_type_id = tt.cust_trx_type_id;
        END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       goto END_3;
   END;

  debug1('currency code3 of invoice from the ps = ' || ps_currency_code3);
  /********************************************************
   *   if transmission has null currency code use the one
   *   from Payment Schedules
   *********************************************************/
  IF (l_invoice_currency_code3 is NULL ) THEN
    debug1('currency code is null.. setting = ' || ps_currency_code3);
    l_invoice_currency_code3 := ps_currency_code3;

     /* update ar_payment_interface to have the invoice currency_code */
     UPDATE ar_payments_interface
        SET invoice_currency_code3 = l_invoice_currency_code3
     WHERE rowid = l_rowid;
  END IF;   /* end if invoice currency code was null */

  /****************************************************************
   * check to see if the currency code matches or is was not included
   * in the transmission
   ****************************************************************/
   debug1('l_invoice_currency_code3 = ' || l_invoice_currency_code3);
   debug1('ps_currency_code = ' || ps_currency_code3);

   IF  (l_invoice_currency_code3 <> ps_currency_code3) then
    debug1('currency code give does not match payment schedules..');
    UPDATE AR_PAYMENTS_INTERFACE
        SET invoice3_status = 'AR_PLB_CURRENCY_BAD'
    WHERE rowid = l_rowid;
   ELSE
       /* Bug:1513671 we know the invoice currency code so we can now format the
          amount applied if we need to */

       IF (p_format_amount3 = 'Y') THEN
          fnd_currency.Get_Info(l_invoice_currency_code3,
                                l_precision,
                                l_extended_precision,
                                l_mau);
          l_amount_applied3 := round(l_amount_applied3 / power(10, l_precision),
                                     l_precision);
       END IF;

      /*************************************************************
       * if the currency code of the transaction does not equal the
       *  currency code of the receipt, then check for cross currency
       *  or Euro case
       **************************************************************/
      IF ( l_invoice_currency_code3 <> l_currency_code) THEN
       debug1('currency code of receipt does not match currency code of inv');

       /***********************************************************
        * we need to check to see if we have cross currency
        * profile enabled or we are dealing with a fixed rate
        * currency
        ************************************************************/

         l_is_fixed_rate := gl_currency_api.is_fixed_rate(
                            l_currency_code,      /*receipt currency */
                            l_invoice_currency_code3,  /* inv currency */
                            nvl(l_receipt_date,sysdate));

         debug1('is this a fixed rate = ' || l_is_fixed_rate);
         debug1('is cross curr enabled??  ' || l_enable_cross_currency);

         IF ( (l_is_fixed_rate = 'Y')  or
              (l_enable_cross_currency = 'Y')) THEN
           /* we have to make sure that all fields are populated */

            IF ( (l_amount_applied_from3 IS NULL) or
                 (l_amount_applied3 IS NULL)  or
                 (l_trans_to_receipt_rate3 IS NULL) )  THEN

             /* we need to check the rate 1st.  If both amounts columns are
                populated, then we calculate the rate.   If one amount is
                missing and the rate is null, then we try to get the rate from
                GL based on the profile option */

                IF ( l_trans_to_receipt_rate3 is NULL) THEN
                     debug1('trans_to_receipt_rate3 is null');
                  /* if neither amount is null then we calculate the rate */

                     debug1('amount applied = ' || to_char(l_amount_applied3));
                     debug1('amount applied from = ' || to_char(l_amount_applied_from3));
                     IF ( (l_amount_applied3 IS NOT NULL) and
                          (l_amount_applied_from3 IS NOT NULL)) Then

                          /********************************************
                           *  if we have a fixed rate, we need to get the
                           *  rate from GL and verify the validity of the
                           *  2 amount columns with the rate that we get
                           **********************************************/

                          IF (l_is_fixed_rate = 'Y') THEN
                             /* get the fixed rate from GL */
                             l_trans_to_receipt_rate3 :=
                                    gl_currency_api.get_rate(
                                           l_invoice_currency_code3,
                                           l_currency_code,
                                           l_receipt_date);

                             /*************************************************
                              *  if all fields are populated, we need to
                              *  check to make sure that they are logically
                              *  correct.
                              ************************************************/
                              calc_amt_applied_fmt(l_invoice_currency_code3,
                                               l_amount_applied_from3,
                                               l_trans_to_receipt_rate3,
                                               l_temp_amt_applied,
					       'N');

                              calc_amt_applied_from_fmt(l_currency_code,
                                                    l_amount_applied3,
                                                    l_trans_to_receipt_rate3,
                                                    l_temp_amt_applied_from,
						    'N');

                              ar_cc_lockbox.calc_cross_rate(
                                                  l_amount_applied3,
                                                  l_amount_applied_from3,
                                                  l_invoice_currency_code3,
                                                  l_currency_code,
                                                  l_temp_trans_to_receipt_rate);
                              IF ( (l_temp_amt_applied = l_amount_applied3) OR
                                   (l_temp_amt_applied_from =
                                           l_amount_applied_from3)   OR
                                   (l_temp_trans_to_receipt_rate =
                                           l_trans_to_receipt_rate3)) THEN

                                /********************************************
                                 * since one or more of the conditions are
                                 * true then we assume that everything is
                                 * fine and we can write the rate to the
                                 * database
                                 *********************************************/
                                   debug1('validation passed ' );
                                   UPDATE ar_payments_interface
                                     SET trans_to_receipt_rate3 =
                                             l_trans_to_receipt_rate3
                                     WHERE rowid = l_rowid;
                                ELSE
                                  UPDATE AR_PAYMENTS_INTERFACE
                                    SET invoice3_status =
                                             'AR_PLB_CC_INVALID_VALUE'
                                   WHERE rowid = l_rowid;
                               END IF;
                          ELSE
                             /* calculate the least rate that would convert
                                the items */
                             ar_cc_lockbox.calc_cross_rate(
                                l_amount_applied3,
                                l_amount_applied_from3,
                                l_invoice_currency_code3,
                                l_currency_code,
                                l_trans_to_receipt_rate3);

                             /* once the rate has been calculated, we need
                                to write it to the table */
                             UPDATE ar_payments_interface
                                SET trans_to_receipt_rate3 =
                                   l_trans_to_receipt_rate3
                              WHERE rowid = l_rowid;
                          END IF;

                     ELSE
                       /* need to derive the rate if possible*/
                       debug1( 'need to derive rate ');
                       IF (p_default_exchange_rate_type IS NOT NULL or
                             l_is_fixed_rate = 'Y' ) THEN
                          l_trans_to_receipt_rate3 :=
                              gl_currency_api.get_rate_sql(
                                                l_invoice_currency_code3,
                                                l_currency_code,
                                                l_receipt_date,
                                                p_default_exchange_rate_type);
                     debug1('calculated rate = ' || to_char(l_trans_to_receipt_rate3));
                        /* if there is no rate in GL, there is nothing
                           more we can do */
                           IF (l_trans_to_receipt_rate3 < 0 )  THEN

                            UPDATE AR_PAYMENTS_INTERFACE
                               SET invoice3_status = 'AR_PLB_NO_EXCHANGE_RATE'
                                WHERE rowid = l_rowid;

                           ELSE
                             /* once the rate has been calculated, we need
                                to write it to the table */

                             debug1('writing rate to database ' || to_char(l_trans_to_receipt_rate3));

                             UPDATE ar_payments_interface
                                SET trans_to_receipt_rate3 =
                                   l_trans_to_receipt_rate3
                              WHERE rowid = l_rowid;

                             /* finish the calculation because we have a rate*/

                             IF (l_amount_applied_from3 IS NULL) THEN
                                calc_amt_applied_from_fmt(l_currency_code,
                                                      l_amount_applied3,
                                                      l_trans_to_receipt_rate3,
                                                      l_amount_applied_from3,
						      l_format_amount_applied_from3);

                                update ar_payments_interface
                                   set  amount_applied_from3 =
                                           l_amount_applied_from3
                                   where rowid = l_rowid;

                             ELSE
                              /* calculate amount applied and save to db */
                              calc_amt_applied_fmt(l_invoice_currency_code3,
                                               l_amount_applied_from3,
                                               l_trans_to_receipt_rate3,
                                               l_amount_applied3,
					       l_format_amount3);
                              debug1('calculated amt applied = ' || to_char(l_amount_applied3));

                              /* to deal with rounding errors that happen
                                 with fixed rate currencies, we need to
                                 take the amount_due_remaining of the trx
                                 convert it to the receipt currency and
                                 compare that value with the
                                 amount_applied_from original value

                                 ADDED for BUG 883345  */

                              IF (l_is_fixed_rate = 'Y') THEN

                                 calc_amt_applied_from_fmt(l_currency_code,
                                                       trx_amt_due_rem3,
                                                       l_trans_to_receipt_rate3,
                                                       amt_applied_from_tc,
						       'N');

                                  IF (amt_applied_from_tc =
                                       l_amount_applied_from3 ) THEN
				    IF (l_format_amount3 = 'Y') THEN

                                        fnd_currency.Get_Info(
                                             l_invoice_currency_code3,
                                             l_precision,
                                             l_extended_precision,
                                             l_mau);

                                     l_amount_applied3 :=
                                         trx_amt_due_rem3 * (10**l_precision);
				    ELSE
                                     l_amount_applied3 := trx_amt_due_rem3 ;
				    END IF;
                                  END IF;
                              END IF;


                               update ar_payments_interface
                                   set  amount_applied3 =
                                           l_amount_applied3
                                   where rowid = l_rowid;

                             END IF;   /* if amount_applied_From3 is null */
                           END IF;  /* if rate is null after it is calc */
                       ELSE       /* Bug 1519765 */
                            UPDATE AR_PAYMENTS_INTERFACE
                               SET invoice3_status = 'AR_PLB_NO_EXCHANGE_RATE'
                                WHERE rowid = l_rowid;
                       END IF;     /* if derive profile is not null */
                     END IF;
                  /*  we know that trans_to_receipt_rate3 is not null,
                      therefore, one of the amount values must be null and
                      we have to calculate it */
                  ELSE
                      /* is amount_applied_From null?? */
                      IF (l_amount_applied_from3 IS NULL) THEN
                         calc_amt_applied_from_fmt(l_currency_code,
                                               l_amount_applied3,
                                               l_trans_to_receipt_rate3,
                                               l_amount_applied_from3,
					       l_format_amount_applied_from3);
                          update ar_payments_interface
                            set  amount_applied_from3 =
                                      l_amount_applied_from3
                            where rowid = l_rowid;

                      ELSE
                         calc_amt_applied_fmt(l_invoice_currency_code3,
                                          l_amount_applied_from3,
                                          l_trans_to_receipt_rate3,
                                          l_amount_applied3,
					  l_format_amount3);

                         /* to deal with rounding errors that happen
                            with fixed rate currencies, we need to
                            take the amount_due_remaining of the trx
                            convert it to the receipt currency and
                            compare that value with the
                            amount_applied_from original value

                            ADDED for BUG 883345  */

                         IF (l_is_fixed_rate = 'Y') THEN

                             calc_amt_applied_from_fmt(l_currency_code,
                                                   trx_amt_due_rem3,
                                                   l_trans_to_receipt_rate3,
                                                   amt_applied_from_tc,
						   'N');

                             IF (amt_applied_from_tc =
                                   l_amount_applied_from3 ) THEN
			       IF (l_format_amount3 = 'Y') THEN

                                fnd_currency.Get_Info(
                                         l_invoice_currency_code3,
                                         l_precision,
                                         l_extended_precision,
                                         l_mau);

                                 l_amount_applied3 :=
                                     trx_amt_due_rem3 * (10**l_precision);
				ELSE
                                 l_amount_applied3 := trx_amt_due_rem3 ;
				END IF;
                              END IF;
                          END IF;

                         UPDATE AR_PAYMENTS_INTERFACE
                              SET  amount_applied3 =
                                      l_amount_applied3
                              WHERE rowid = l_rowid;

                      END IF;
                  END IF;   /* trans to receipt_rate 3 is null */
               ELSE
                  /*************************************************
                   *  if all fields are populated, we need to
                   *  check to make sure that they are logically
                   *  correct.
                   ***************************************************/

                   calc_amt_applied_fmt(l_invoice_currency_code3,
                                    l_amount_applied_from3,
                                    l_trans_to_receipt_rate3,
                                    l_temp_amt_applied,
				    'N');

                   calc_amt_applied_from_fmt(l_currency_code,
                                         l_amount_applied3,
                                         l_trans_to_receipt_rate3,
                                         l_temp_amt_applied_from,
					 'N');

                   ar_cc_lockbox.calc_cross_rate(
                                l_amount_applied3,
                                l_amount_applied_from3,
                                l_invoice_currency_code3,
                                l_currency_code,
                                l_temp_trans_to_receipt_rate);
                   IF ( (l_temp_amt_applied = l_amount_applied3) OR
                        (l_temp_amt_applied_from =
                                           l_amount_applied_from3)   OR
                        (l_temp_trans_to_receipt_rate =
                                           l_trans_to_receipt_rate3)) THEN

                       /* since one or more of the conditions are true
                          then we assume that everything is fine. */
                          debug1('validation passed ' );
                          debug1('validation passed ' );
                    ELSE
                         UPDATE AR_PAYMENTS_INTERFACE
                              SET invoice3_status = 'AR_PLB_CC_INVALID_VALUE'
                         WHERE rowid = l_rowid;
                    END IF;

               END IF;   /* if one of the 3 items is NULL */
            ELSE
                 /*****************************************************
                    currencies do not match, they are not fixed rate and
                    cross currency enabled profile is not on.
                    then set the status to be a currency conflict between
                    the invoice and receipt currencies
                   ***************************************************/
                 UPDATE AR_PAYMENTS_INTERFACE
                      SET invoice3_status = 'AR_PLB_CURR_CONFLICT'
                         WHERE rowid = l_rowid;
            END IF;
	  ELSE /* Bug 2066392.  Single currency */
	    IF l_amount_applied_from3 is not null THEN
	      IF l_amount_applied3 is not null THEN
		IF l_amount_applied_from3 <> l_amount_applied3 THEN
		  UPDATE AR_PAYMENTS_INTERFACE
		      SET invoice3_status = 'AR_PLB_CC_INVALID_VALUE'
		  WHERE rowid = l_rowid;
		END IF;
	      ELSE
		IF l_format_amount3 = 'Y' THEN
		  fnd_currency.Get_Info(l_invoice_currency_code3,
                                l_precision,
                                l_extended_precision,
                                l_mau);
		  l_unformat_amount := l_amount_applied_from3 * power(10, l_precision);
		ELSE
		  l_unformat_amount := l_amount_applied_from3;
		END IF;
		UPDATE AR_PAYMENTS_INTERFACE
		      SET  amount_applied3 = l_unformat_amount
		      WHERE  rowid = l_rowid;
	      END IF;
	    END IF;
          END IF;
      END IF;
   END IF;   /* if matching number 3 is not null */
<<END_3>>

   /****************   need to check matching number 4 *************/

 /* checking 4th  trx_number */
debug1('invoice4 is not null =  ' || l_matching_number4);
IF (l_matching_number4 is not NULL) THEN

   /*  added trx_amt_due_remX for bug 883345 */
   /*  Changed the where clause and added the exception for bug 1052313
       and 1097549 */
   BEGIN
        SELECT  sum(count(distinct ps.customer_trx_id))
        INTO    l_tot_trx4
        FROM    ar_payment_schedules ps
        WHERE   ps.trx_number = l_matching_number4
        AND     ps.trx_date = l_resolved_matching4_date /* Bug fix 2926664 */
        AND    (ps.customer_id  IN
                 (
                   select l_customer_id from dual
                   union
                   select related_cust_account_id
                   from   hz_cust_acct_relate rel
                   where  rel.cust_account_id = l_customer_id
                   and    rel.status = 'A'
                   and    rel.bill_to_flag = 'Y'
                   union
                   select rel.related_cust_account_id
                   from   ar_paying_relationships_v rel,
                          hz_cust_accounts acc
                   where  rel.party_id = acc.party_id
                   and    acc.cust_account_id = l_customer_id
                   and    l_receipt_date BETWEEN effective_start_date
                                             AND effective_end_date
                 )
                 or
                 l_pay_unrelated_invoices = 'Y'
                )
        GROUP BY ps.customer_trx_id
        HAVING sum(ps.amount_due_remaining) <> 0;

        IF (l_tot_trx4 > 1) then
                update ar_payments_interface pi
                set    invoice4_status = 'AR_PLB_DUP_INV'
                where rowid = l_rowid;
                goto END_4;
        ELSE
                SELECT  invoice_currency_code,
                        amount_due_remaining
                INTO    ps_currency_code4,
                        trx_amt_due_rem4
                FROM    ar_payment_schedules ps,
                        ra_cust_trx_types    tt
                WHERE   ps.trx_number = l_matching_number4
                AND     ps.status = decode(tt.allow_overapplication_flag,
                               'N', 'OP',
                                ps.status)
                AND     ps.class NOT IN ('PMT','GUAR')
                AND     ps.payment_schedule_id =
                        (select min(ps.payment_schedule_id)
                         from   ar_payment_schedules ps,
                                ra_cust_trx_types    tt
                         where  ps.trx_number = l_matching_number4
                         and    ps.trx_date = l_resolved_matching4_date /* Bug fix 2926664 */
                         and    (ps.customer_id  IN
                                   (
                                      select l_customer_id from dual
                                      union
                                      select related_cust_account_id
                                      from   hz_cust_acct_relate rel
                                      where  rel.cust_account_id
                                             = l_customer_id
                                      and    rel.status = 'A'
                                      and    rel.bill_to_flag = 'Y'
                                      union
                                      select rel.related_cust_account_id
                                      from   ar_paying_relationships_v rel,
                                             hz_cust_accounts acc
                                      where  rel.party_id = acc.party_id
                                      and    acc.cust_account_id
                                             = l_customer_id
                                      and    l_receipt_date
                                             BETWEEN effective_start_date
                                                 AND effective_end_date
                                   )
                                   or
                                   l_pay_unrelated_invoices = 'Y'
                                 )
                         and    ps.cust_trx_type_id = tt.cust_trx_type_id
                         and    ps.class NOT IN ('PMT','GUAR')
                         and ps.status=decode(tt.allow_overapplication_flag,
						'N' , 'OP',
                                            ps.status))
                AND    (ps.customer_id  IN
                 (
                   select l_customer_id from dual
                   union
                   select related_cust_account_id
                   from   hz_cust_acct_relate rel
                   where  rel.cust_account_id = l_customer_id
                   and    rel.status = 'A'
                   and    rel.bill_to_flag = 'Y'
                   union
                   select rel.related_cust_account_id
                   from   ar_paying_relationships_v rel,
                          hz_cust_accounts acc
                   where  rel.party_id = acc.party_id
                   and    acc.cust_account_id = l_customer_id
                   and    l_receipt_date BETWEEN effective_start_date
                                             AND effective_end_date
                 )
                 or
                 l_pay_unrelated_invoices = 'Y'
                )
                AND     ps.cust_trx_type_id = tt.cust_trx_type_id;
        END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       goto END_4;
   END;

  debug1('currency code1 of invoice from the ps = ' || ps_currency_code4);
  /********************************************************
   *   if transmission has null currency code use the one
   *   from Payment Schedules
   *********************************************************/
  IF (l_invoice_currency_code4 is NULL ) THEN
    debug1('currency code is null.. setting = ' || ps_currency_code4);
    l_invoice_currency_code4 := ps_currency_code4;

     /* update ar_payment_interface to have the invoice currency_code */
     UPDATE ar_payments_interface
        SET invoice_currency_code4 = l_invoice_currency_code4
     WHERE  rowid = l_rowid;
  END IF;   /* end if invoice currency code was null */

  /****************************************************************
   * check to see if the currency code matches or is was not included
   * in the transmission
   ****************************************************************/
   debug1('l_invoice_currency_code4 = ' || l_invoice_currency_code4);
   debug1('ps_currency_code = ' || ps_currency_code4);

   IF  (l_invoice_currency_code4 <> ps_currency_code4) then
    debug1('currency code give does not match payment schedules..');
    UPDATE AR_PAYMENTS_INTERFACE
        SET invoice4_status = 'AR_PLB_CURRENCY_BAD'
    WHERE  rowid = l_rowid;
   ELSE
       /* Bug:1513671 we know the invoice currency code so we can now format the
          amount applied if we need to */

       IF (p_format_amount4 = 'Y') THEN
          fnd_currency.Get_Info(l_invoice_currency_code4,
                                l_precision,
                                l_extended_precision,
                                l_mau);
          l_amount_applied4 := round(l_amount_applied4 / power(10, l_precision),
                                     l_precision);
       END IF;

      /*************************************************************
       * if the currency code of the transaction does not equal the
       *  currency code of the receipt, then check for cross currency
       *  or Euro case
       **************************************************************/
      IF ( l_invoice_currency_code4 <> l_currency_code) THEN
       debug1('currency code of receipt does not match currency code of inv');

       /***********************************************************
        * we need to check to see if we have cross currency
        * profile enabled or we are dealing with a fixed rate
        * currency
        ************************************************************/

         l_is_fixed_rate := gl_currency_api.is_fixed_rate(
                            l_currency_code,      /*receipt currency */
                            l_invoice_currency_code4,  /* inv currency */
                            nvl(l_receipt_date,sysdate));

         debug1('is this a fixed rate = ' || l_is_fixed_rate);
         debug1('is cross curr enabled??  ' || l_enable_cross_currency);

         IF ( (l_is_fixed_rate = 'Y')  or
              (l_enable_cross_currency = 'Y')) THEN
           /* we have to make sure that all fields are populated */

            IF ( (l_amount_applied_from4 IS NULL) or
                 (l_amount_applied4 IS NULL)  or
                 (l_trans_to_receipt_rate4 IS NULL) )  THEN

             /* we need to check the rate 1st.  If both amounts columns are
                populated, then we calculate the rate.   If one amount is
                missing and the rate is null, then we try to get the rate from
                GL based on the profile option */

                IF ( l_trans_to_receipt_rate4 is NULL) THEN
                     debug1('trans_to_receipt_rate4 is null');
                  /* if neither amount is null then we calculate the rate */

                     debug1('amount applied = ' || to_char(l_amount_applied1));
                     debug1('amount applied from = ' || to_char(l_amount_applied_from4));
                     IF ( (l_amount_applied4 IS NOT NULL) and
                          (l_amount_applied_from4 IS NOT NULL)) Then

                          /********************************************
                           *  if we have a fixed rate, we need to get the
                           *  rate from GL and verify the validity of the
                           *  2 amount columns with the rate that we get
                           **********************************************/
                          IF (l_is_fixed_rate = 'Y') THEN
                             /* get the fixed rate from GL */
                             l_trans_to_receipt_rate4 :=
                                    gl_currency_api.get_rate(
                                           l_invoice_currency_code4,
                                           l_currency_code,
                                           l_receipt_date);

                             /*************************************************
                              *  if all fields are populated, we need to
                              *  check to make sure that they are logically
                              *  correct.
                              ************************************************/
                              calc_amt_applied_fmt(l_invoice_currency_code4,
                                               l_amount_applied_from4,
                                               l_trans_to_receipt_rate4,
                                               l_temp_amt_applied,
					       'N');

                              calc_amt_applied_from_fmt(l_currency_code,
                                                    l_amount_applied4,
                                                    l_trans_to_receipt_rate4,
                                                    l_temp_amt_applied_from,
						    'N');

                              ar_cc_lockbox.calc_cross_rate(
                                                  l_amount_applied4,
                                                  l_amount_applied_from4,
                                                  l_invoice_currency_code4,
                                                  l_currency_code,
                                                  l_temp_trans_to_receipt_rate);
                              IF ( (l_temp_amt_applied = l_amount_applied4) OR
                                   (l_temp_amt_applied_from =
                                           l_amount_applied_from4)   OR
                                   (l_temp_trans_to_receipt_rate =
                                           l_trans_to_receipt_rate4)) THEN

                                /********************************************
                                 * since one or more of the conditions are
                                 * true then we assume that everything is
                                 * fine and we can write the rate to the
                                 * database
                                 *********************************************/
                                   debug1('validation passed ' );
                                   UPDATE ar_payments_interface
                                     SET trans_to_receipt_rate4 =
                                             l_trans_to_receipt_rate4
                                     WHERE rowid = l_rowid;
                                ELSE
                                  UPDATE AR_PAYMENTS_INTERFACE
                                    SET invoice4_status =
                                             'AR_PLB_CC_INVALID_VALUE'
                                   WHERE rowid = l_rowid;
                               END IF;

                          ELSE
                             /* calculate the least rate that would convert
                                the items */
                             ar_cc_lockbox.calc_cross_rate(
                                l_amount_applied4,
                                l_amount_applied_from4,
                                l_invoice_currency_code4,
                                l_currency_code,
                                l_trans_to_receipt_rate4);

                             /* once the rate has been calculated, we need
                                to write it to the table */
                             UPDATE ar_payments_interface
                                SET trans_to_receipt_rate4 =
                                   l_trans_to_receipt_rate4
                              WHERE rowid = l_rowid;
                          END IF;

                     ELSE
                       /* need to derive the rate if possible*/
                       debug1( 'need to derive rate ');
                       IF (p_default_exchange_rate_type IS NOT NULL or
                             l_is_fixed_rate = 'Y' ) THEN
                          l_trans_to_receipt_rate4 :=
                              gl_currency_api.get_rate_sql(
                                                l_invoice_currency_code4,
                                                l_currency_code,
                                                l_receipt_date,
                                                p_default_exchange_rate_type);
                     debug1('calculated rate = ' || to_char(l_trans_to_receipt_rate4));
                        /* if there is no rate in GL, there is nothing
                           more we can do */
                           IF (l_trans_to_receipt_rate4 < 0 )  THEN

                            UPDATE AR_PAYMENTS_INTERFACE
                               SET invoice4_status = 'AR_PLB_NO_EXCHANGE_RATE'
                                WHERE rowid = l_rowid;

                           ELSE
                             /* once the rate has been calculated, we need
                                to write it to the table */

                             debug1('writing rate to database ' || to_char(l_trans_to_receipt_rate4));

                             UPDATE ar_payments_interface
                                SET trans_to_receipt_rate4 =
                                   l_trans_to_receipt_rate4
                              WHERE rowid = l_rowid;

                             /* finish the calculation because we have a rate*/

                             IF (l_amount_applied_from4 IS NULL) THEN
                                calc_amt_applied_from_fmt(l_currency_code,
                                                      l_amount_applied4,
                                                      l_trans_to_receipt_rate4,
                                                      l_amount_applied_from4,
						      l_format_amount_applied_from4);
                                update ar_payments_interface
                                   set  amount_applied_from4 =
                                           l_amount_applied_from4
                                   where rowid = l_rowid;

                             ELSE
                              /* calculate amount applied and save to db */
                              calc_amt_applied_fmt(l_invoice_currency_code4,
                                               l_amount_applied_from4,
                                               l_trans_to_receipt_rate4,
                                               l_amount_applied4,
					       l_format_amount4);
                              debug1('calculated amt applied = ' || to_char(l_amount_applied4));

                         /* to deal with rounding errors that happen
                            with fixed rate currencies, we need to
                            take the amount_due_remaining of the trx
                            convert it to the receipt currency and
                            compare that value with the
                            amount_applied_from original value

                            ADDED for BUG 883345  */

                          IF (l_is_fixed_rate = 'Y') THEN

                             calc_amt_applied_from_fmt(l_currency_code,
                                                   trx_amt_due_rem4,
                                                   l_trans_to_receipt_rate4,
                                                   amt_applied_from_tc,
						   'N');

                             IF (amt_applied_from_tc =
                                  l_amount_applied_from4 ) THEN
			       IF (l_format_amount4 = 'Y') THEN
                                 fnd_currency.Get_Info(
                                         l_invoice_currency_code4,
                                         l_precision,
                                         l_extended_precision,
                                         l_mau);

                                 l_amount_applied4 :=
                                     trx_amt_due_rem4 * (10**l_precision);
			       ELSE
                                 l_amount_applied4 := trx_amt_due_rem4 ;
			       END IF;
                             END IF;
                          END IF;


                               update ar_payments_interface
                                   set  amount_applied4 =
                                           l_amount_applied4
                                   where rowid = l_rowid;

                             END IF;   /* if amount_applied_From4 is null */
                           END IF;  /* if rate is null after it is calc */
                       ELSE       /* Bug 1519765 */
                            UPDATE AR_PAYMENTS_INTERFACE
                               SET invoice4_status = 'AR_PLB_NO_EXCHANGE_RATE'
                                WHERE rowid = l_rowid;
                       END IF;     /* if derive profile is not null */
                     END IF;

                  /*  we know that trans_to_receipt_rate4 is not null,
                      therefore, one of the amount values must be null and
                      we have to calculate it */
                  ELSE
                      /* is amount_applied_From null?? */
                      IF (l_amount_applied_from4 IS NULL) THEN
                         calc_amt_applied_from_fmt(l_currency_code,
                                               l_amount_applied4,
                                               l_trans_to_receipt_rate4,
                                               l_amount_applied_from4,
					       l_format_amount_applied_from4);
                          update ar_payments_interface
                            set  amount_applied_from4 =
                                      l_amount_applied_from4
                            where rowid = l_rowid;

                      ELSE
                         calc_amt_applied_fmt(l_invoice_currency_code4,
                                          l_amount_applied_from4,
                                          l_trans_to_receipt_rate4,
                                          l_amount_applied4,
					  l_format_amount4);

                         /* to deal with rounding errors that happen
                            with fixed rate currencies, we need to
                            take the amount_due_remaining of the trx
                            convert it to the receipt currency and
                            compare that value with the
                            amount_applied_from original value

                            ADDED for BUG 883345  */

                          IF (l_is_fixed_rate = 'Y') THEN

                             calc_amt_applied_from_fmt(l_currency_code,
                                                   trx_amt_due_rem4,
                                                   l_trans_to_receipt_rate4,
                                                   amt_applied_from_tc, 'N');

                             IF (amt_applied_from_tc =
                                  l_amount_applied_from4 ) THEN
			       IF (l_format_amount4 = 'Y') THEN
                                 fnd_currency.Get_Info(
                                         l_invoice_currency_code4,
                                         l_precision,
                                         l_extended_precision,
                                         l_mau);

                                 l_amount_applied4 :=
                                     trx_amt_due_rem4 * (10**l_precision);
			       ELSE
                                 l_amount_applied4 := trx_amt_due_rem4 ;
			       END IF;
                             END IF;
                          END IF;

                         UPDATE AR_PAYMENTS_INTERFACE
                              SET  amount_applied4 =
                                      l_amount_applied4
                              WHERE  rowid = l_rowid;

                      END IF;
                  END IF;   /* trans to receipt_rate 4 is null */
               ELSE
                  /*************************************************
                   *  if all fields are populated, we need to
                   *  check to make sure that they are logically
                   *  correct.
                   ***************************************************/

                   calc_amt_applied_fmt(l_invoice_currency_code4,
                                    l_amount_applied_from4,
                                    l_trans_to_receipt_rate4,
                                    l_temp_amt_applied,
				    'N');

                   calc_amt_applied_from_fmt(l_currency_code,
                                         l_amount_applied4,
                                         l_trans_to_receipt_rate4,
                                         l_temp_amt_applied_from,
					 'N');

                   ar_cc_lockbox.calc_cross_rate(
                                l_amount_applied4,
                                l_amount_applied_from4,
                                l_invoice_currency_code4,
                                l_currency_code,
                                l_temp_trans_to_receipt_rate);
                   IF ( (l_temp_amt_applied = l_amount_applied4) OR
                        (l_temp_amt_applied_from =
                                           l_amount_applied_from4)   OR
                        (l_temp_trans_to_receipt_rate =
                                           l_trans_to_receipt_rate4)) THEN

                       /* since one or more of the conditions are true
                          then we assume that everything is fine. */
                          debug1('validation passed ' );
                    ELSE
                         UPDATE AR_PAYMENTS_INTERFACE
                              SET invoice4_status = 'AR_PLB_CC_INVALID_VALUE'
                         WHERE rowid = l_rowid;
                    END IF;

               END IF;   /* if one of the 3 items is NULL */
            ELSE
                 /*****************************************************
                    currencies do not match, they are not fixed rate and
                    cross currency enabled profile is not on.
                    then set the status to be a currency conflict between
                    the invoice and receipt currencies
                   ***************************************************/
                 UPDATE AR_PAYMENTS_INTERFACE
                      SET invoice4_status = 'AR_PLB_CURR_CONFLICT'
                         WHERE rowid = l_rowid;
            END IF;
	  ELSE /* Bug 2066392.  Single currency */
	    IF l_amount_applied_from4 is not null THEN
	      IF l_amount_applied4 is not null THEN
		IF l_amount_applied_from4 <> l_amount_applied4 THEN
		  UPDATE AR_PAYMENTS_INTERFACE
		      SET invoice4_status = 'AR_PLB_CC_INVALID_VALUE'
		  WHERE rowid = l_rowid;
		END IF;
	      ELSE
		IF l_format_amount4 = 'Y' THEN
		  fnd_currency.Get_Info(l_invoice_currency_code4,
                                l_precision,
                                l_extended_precision,
                                l_mau);
		  l_unformat_amount := l_amount_applied_from4 * power(10, l_precision);
		ELSE
		  l_unformat_amount := l_amount_applied_from4;
		END IF;
		UPDATE AR_PAYMENTS_INTERFACE
		      SET  amount_applied4 = l_unformat_amount
		      WHERE  rowid = l_rowid;
	      END IF;
	    END IF;
          END IF;
      END IF;
   END IF;   /* if matching number 4 is not null */
<<END_4>>

   /****************   need to check matching number 5 *************/

/* checking 5th trx_number */
debug1('invoice5 is not null =  ' || l_matching_number5);
IF (l_matching_number5 is not NULL) THEN

   /*  added trx_amt_due_remX for bug 883345 */
   /*  Changed the where clause and added the exception for bug 1052313
       and 1097549 */
   BEGIN
        SELECT  sum(count(distinct ps.customer_trx_id))
        INTO    l_tot_trx5
        FROM    ar_payment_schedules ps
        WHERE   ps.trx_number = l_matching_number5
        AND     ps.trx_date = l_resolved_matching5_date /* Bug fix 2926664 */
        AND    (ps.customer_id  IN
                 (
                   select l_customer_id from dual
                   union
                   select related_cust_account_id
                   from   hz_cust_acct_relate rel
                   where  rel.cust_account_id = l_customer_id
                   and    rel.status = 'A'
                   and    rel.bill_to_flag = 'Y'
                   union
                   select rel.related_cust_account_id
                   from   ar_paying_relationships_v rel,
                          hz_cust_accounts acc
                   where  rel.party_id = acc.party_id
                   and    acc.cust_account_id = l_customer_id
                   and    l_receipt_date BETWEEN effective_start_date
                                             AND effective_end_date
                 )
                 or
                 l_pay_unrelated_invoices = 'Y'
                )
        GROUP BY ps.customer_trx_id
        HAVING sum(ps.amount_due_remaining) <> 0;

        IF (l_tot_trx5 > 1) then
                update ar_payments_interface pi
                set    invoice5_status = 'AR_PLB_DUP_INV'
                where rowid = l_rowid;
                goto END_5;
        ELSE
                SELECT  invoice_currency_code,
                        amount_due_remaining
                INTO    ps_currency_code5,
                        trx_amt_due_rem5
                FROM    ar_payment_schedules ps,
                        ra_cust_trx_types    tt
                WHERE   ps.trx_number = l_matching_number5
                AND     ps.status = decode(tt.allow_overapplication_flag,
                               'N', 'OP',
                                ps.status)
                AND     ps.class NOT IN ('PMT','GUAR')
                AND     ps.payment_schedule_id =
                        (select min(ps.payment_schedule_id)
                         from   ar_payment_schedules ps,
                                ra_cust_trx_types    tt
                         where  ps.trx_number = l_matching_number5
                         and    ps.trx_date = l_resolved_matching5_date /* Bug fix 2926664 */
                         and    (ps.customer_id  IN
                                   (
                                      select l_customer_id from dual
                                      union
                                      select related_cust_account_id
                                      from   hz_cust_acct_relate rel
                                      where  rel.cust_account_id
                                             = l_customer_id
                                      and    rel.status = 'A'
                                      and    rel.bill_to_flag = 'Y'
                                      union
                                      select rel.related_cust_account_id
                                      from   ar_paying_relationships_v rel,
                                             hz_cust_accounts acc
                                      where  rel.party_id = acc.party_id
                                      and    acc.cust_account_id
                                             = l_customer_id
                                      and    l_receipt_date
                                             BETWEEN effective_start_date
                                                 AND effective_end_date
                                   )
                                   or
                                   l_pay_unrelated_invoices = 'Y'
                                 )
                          and    ps.cust_trx_type_id = tt.cust_trx_type_id
                          and    ps.class NOT IN ('PMT','GUAR')
                          and ps.status=decode(tt.allow_overapplication_flag,
						'N', 'OP',
                                            ps.status))
                AND    (ps.customer_id  IN
                 (
                   select l_customer_id from dual
                   union
                   select related_cust_account_id
                   from   hz_cust_acct_relate rel
                   where  rel.cust_account_id = l_customer_id
                   and    rel.status = 'A'
                   and    rel.bill_to_flag = 'Y'
                   union
                   select rel.related_cust_account_id
                   from   ar_paying_relationships_v rel,
                          hz_cust_accounts acc
                   where  rel.party_id = acc.party_id
                   and    acc.cust_account_id = l_customer_id
                   and    l_receipt_date BETWEEN effective_start_date
                                             AND effective_end_date
                 )
                 or
                 l_pay_unrelated_invoices = 'Y'
                )
                AND     ps.cust_trx_type_id = tt.cust_trx_type_id;
        END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       goto END_5;
   END;

  debug1('currency code5 of invoice from the ps = ' || ps_currency_code5);
  /********************************************************
   *   if transmission has null currency code use the one
   *   from Payment Schedules
   *********************************************************/
  IF (l_invoice_currency_code5 is NULL ) THEN
    debug1('currency code is null.. setting = ' || ps_currency_code5);
    l_invoice_currency_code5 := ps_currency_code5;

     /* update ar_payment_interface to have the invoice currency_code */
     UPDATE ar_payments_interface
        SET invoice_currency_code5 = l_invoice_currency_code5
     WHERE  rowid = l_rowid;
  END IF;   /* end if invoice currency code was null */

  /****************************************************************
   * check to see if the currency code matches or is was not included
   * in the transmission
   ****************************************************************/
   debug1('l_invoice_currency_code5 = ' || l_invoice_currency_code5);
   debug1('ps_currency_code = ' || ps_currency_code5);

   IF  (l_invoice_currency_code5 <> ps_currency_code5) then
    debug1('currency code give does not match payment schedules..');
    UPDATE AR_PAYMENTS_INTERFACE
        SET invoice5_status = 'AR_PLB_CURRENCY_BAD'
    WHERE rowid = l_rowid;
   ELSE
       /* Bug:1513671 we know the invoice currency code so we can now format the
          amount applied if we need to */

       IF (p_format_amount5 = 'Y') THEN
          fnd_currency.Get_Info(l_invoice_currency_code5,
                                l_precision,
                                l_extended_precision,
                                l_mau);
          l_amount_applied5 := round(l_amount_applied5 / power(10, l_precision),
                                     l_precision);
       END IF;

      /*************************************************************
       * if the currency code of the transaction does not equal the
       *  currency code of the receipt, then check for cross currency
       *  or Euro case
       **************************************************************/
      IF ( l_invoice_currency_code5 <> l_currency_code) THEN
       debug1('currency code of receipt does not match currency code of inv');

       /***********************************************************
        * we need to check to see if we have cross currency
        * profile enabled or we are dealing with a fixed rate
        * currency
        ************************************************************/

         l_is_fixed_rate := gl_currency_api.is_fixed_rate(
                            l_currency_code,      /*receipt currency */
                            l_invoice_currency_code5,  /* inv currency */
                            nvl(l_receipt_date,sysdate));

         debug1('is this a fixed rate = ' || l_is_fixed_rate);
         debug1('is cross curr enabled??  ' || l_enable_cross_currency);

         IF ( (l_is_fixed_rate = 'Y')  or
              (l_enable_cross_currency = 'Y')) THEN
           /* we have to make sure that all fields are populated */

            IF ( (l_amount_applied_from5 IS NULL) or
                 (l_amount_applied5 IS NULL)  or
                 (l_trans_to_receipt_rate5 IS NULL) )  THEN

             /* we need to check the rate 1st.  If both amounts columns are
                populated, then we calculate the rate.   If one amount is
                missing and the rate is null, then we try to get the rate from
                GL based on the profile option */

                IF ( l_trans_to_receipt_rate5 is NULL) THEN
                     debug1('trans_to_receipt_rate5 is null');
                  /* if neither amount is null then we calculate the rate */

                     debug1('amount applied = ' || to_char(l_amount_applied5));
                     debug1('amount applied from = ' || to_char(l_amount_applied_from5));
                     IF ( (l_amount_applied5 IS NOT NULL) and
                          (l_amount_applied_from5 IS NOT NULL)) Then

                          /********************************************
                           *  if we have a fixed rate, we need to get the
                           *  rate from GL and verify the validity of the
                           *  2 amount columns with the rate that we get
                           **********************************************/
                          IF (l_is_fixed_rate = 'Y') THEN
                             /* get the fixed rate from GL */
                             l_trans_to_receipt_rate5 :=
                                    gl_currency_api.get_rate(
                                           l_invoice_currency_code5,
                                           l_currency_code,
                                           l_receipt_date);

                             /*************************************************
                              *  if all fields are populated, we need to
                              *  check to make sure that they are logically
                              *  correct.
                              ************************************************/
                              calc_amt_applied_fmt(l_invoice_currency_code5,
                                               l_amount_applied_from5,
                                               l_trans_to_receipt_rate5,
                                               l_temp_amt_applied,
					       'N');

                              calc_amt_applied_from_fmt(l_currency_code,
                                                    l_amount_applied5,
                                                    l_trans_to_receipt_rate5,
                                                    l_temp_amt_applied_from,
						    'N');

                              ar_cc_lockbox.calc_cross_rate(
                                                  l_amount_applied5,
                                                  l_amount_applied_from5,
                                                  l_invoice_currency_code5,
                                                  l_currency_code,
                                                  l_temp_trans_to_receipt_rate);
                              IF ( (l_temp_amt_applied = l_amount_applied5) OR
                                   (l_temp_amt_applied_from =
                                           l_amount_applied_from5)   OR
                                   (l_temp_trans_to_receipt_rate =
                                           l_trans_to_receipt_rate5)) THEN

                                /********************************************
                                 * since one or more of the conditions are
                                 * true then we assume that everything is
                                 * fine and we can write the rate to the
                                 * database
                                 *********************************************/
                                   debug1('validation passed ' );
                                   UPDATE ar_payments_interface
                                     SET trans_to_receipt_rate5 =
                                             l_trans_to_receipt_rate5
                                     WHERE rowid = l_rowid;
                                ELSE
                                  UPDATE AR_PAYMENTS_INTERFACE
                                    SET invoice5_status =
                                             'AR_PLB_CC_INVALID_VALUE'
                                   WHERE rowid = l_rowid;
                               END IF;

                          ELSE
                             /* calculate the least rate that would convert
                                the items */
                             ar_cc_lockbox.calc_cross_rate(
                                l_amount_applied5,
                                l_amount_applied_from5,
                                l_invoice_currency_code5,
                                l_currency_code,
                                l_trans_to_receipt_rate5);

                             /* once the rate has been calculated, we need
                                to write it to the table */
                             UPDATE ar_payments_interface
                                SET trans_to_receipt_rate5 =
                                   l_trans_to_receipt_rate5
                              WHERE rowid = l_rowid;
                          END IF;

                     ELSE
                       /* need to derive the rate if possible*/
                       debug1( 'need to derive rate ');
                       IF (p_default_exchange_rate_type IS NOT NULL or
                             l_is_fixed_rate = 'Y' ) THEN
                          l_trans_to_receipt_rate5 :=
                              gl_currency_api.get_rate_sql(
                                                l_invoice_currency_code5,
                                                l_currency_code,
                                                l_receipt_date,
                                                p_default_exchange_rate_type);
                     debug1('calculated rate = ' || to_char(l_trans_to_receipt_rate5));
                        /* if there is no rate in GL, there is nothing
                           more we can do */
                           IF (l_trans_to_receipt_rate5 < 0 )  THEN

                            UPDATE AR_PAYMENTS_INTERFACE
                               SET invoice5_status = 'AR_PLB_NO_EXCHANGE_RATE'
                                WHERE rowid = l_rowid;

                           ELSE
                             /* once the rate has been calculated, we need
                                to write it to the table */

                             debug1('writing rate to database ' || to_char(l_trans_to_receipt_rate5));

                             UPDATE ar_payments_interface
                                SET trans_to_receipt_rate5 =
                                   l_trans_to_receipt_rate5
                              WHERE rowid = l_rowid;

                             /* finish the calculation because we have a rate*/

                             IF (l_amount_applied_from5 IS NULL) THEN
                                calc_amt_applied_from_fmt(l_currency_code,
                                                      l_amount_applied5,
                                                      l_trans_to_receipt_rate5,
                                                      l_amount_applied_from5,
						      l_format_amount_applied_from5);
                                update ar_payments_interface
                                   set  amount_applied_from5 =
                                           l_amount_applied_from5
                                   where rowid = l_rowid;

                             ELSE
                              /* calculate amount applied and save to db */
                              calc_amt_applied_fmt(l_invoice_currency_code5,
                                               l_amount_applied_from5,
                                               l_trans_to_receipt_rate5,
                                               l_amount_applied5,
					       l_format_amount5);
                              debug1('calculated amt applied = ' || to_char(l_amount_applied5));
                              /* to deal with rounding errors that happen
                                  with fixed rate currencies, we need to
                                  take the amount_due_remaining of the trx
                                  convert it to the receipt currency and
                                  compare that value with the
                                  amount_applied_from original value

                                  ADDED for BUG 883345  */

                             IF (l_is_fixed_rate = 'Y') THEN

                                calc_amt_applied_from_fmt(l_currency_code,
                                                      trx_amt_due_rem5,
                                                      l_trans_to_receipt_rate5,
                                                      amt_applied_from_tc,
						      'N');

                                IF (amt_applied_from_tc =
                                     l_amount_applied_from5 ) THEN
				  IF (l_format_amount5 = 'Y') THEN
                                    fnd_currency.Get_Info(
                                            l_invoice_currency_code5,
                                            l_precision,
                                            l_extended_precision,
                                            l_mau);

                                    l_amount_applied5 :=
                                        trx_amt_due_rem5 * (10**l_precision);
				  ELSE
                                    l_amount_applied5 := trx_amt_due_rem5 ;
				  END IF;
                                END IF;
                             END IF;

                               update ar_payments_interface
                                   set  amount_applied5 =
                                           l_amount_applied5
                                   where rowid = l_rowid;

                             END IF;   /* if amount_applied_From5 is null */
                           END IF;  /* if rate is null after it is calc */
                       ELSE       /* Bug 1519765 */
                            UPDATE AR_PAYMENTS_INTERFACE
                               SET invoice5_status = 'AR_PLB_NO_EXCHANGE_RATE'
                                WHERE rowid = l_rowid;
                       END IF;     /* if derive profile is not null */
                     END IF;

                  /*  we know that trans_to_receipt_rate5 is not null,
                      therefore, one of the amount values must be null and
                      we have to calculate it */
                  ELSE
                      /* is amount_applied_From null?? */
                      IF (l_amount_applied_from5 IS NULL) THEN
                         calc_amt_applied_from_fmt(l_currency_code,
                                               l_amount_applied5,
                                               l_trans_to_receipt_rate5,
                                               l_amount_applied_from5,
					       l_format_amount_applied_from5);
                          update ar_payments_interface
                            set  amount_applied_from5 =
                                      l_amount_applied_from5
                            where rowid = l_rowid;

                      ELSE
                         calc_amt_applied_fmt(l_invoice_currency_code5,
                                          l_amount_applied_from5,
                                          l_trans_to_receipt_rate5,
                                          l_amount_applied5,
					  l_format_amount5);

                         /* to deal with rounding errors that happen
                            with fixed rate currencies, we need to
                            take the amount_due_remaining of the trx
                            convert it to the receipt currency and
                            compare that value with the
                            amount_applied_from original value

                            ADDED for BUG 883345  */

                            IF (l_is_fixed_rate = 'Y') THEN

                                calc_amt_applied_from_fmt(l_currency_code,
                                                      trx_amt_due_rem5,
                                                      l_trans_to_receipt_rate5,
                                                      amt_applied_from_tc,
						      'N');

                                IF (amt_applied_from_tc =
                                     l_amount_applied_from5 ) THEN
				  IF (l_format_amount5 = 'Y') THEN
                                    fnd_currency.Get_Info(
                                            l_invoice_currency_code5,
                                            l_precision,
                                            l_extended_precision,
                                            l_mau);

                                    l_amount_applied5 :=
                                        trx_amt_due_rem5 * (10**l_precision);
				  ELSE
                                    l_amount_applied5 := trx_amt_due_rem5 ;
				  END IF;
                                END IF;
                             END IF;

                         UPDATE AR_PAYMENTS_INTERFACE
                              SET  amount_applied5 =
                                      l_amount_applied5
                              WHERE  rowid = l_rowid;

                      END IF;
                  END IF;   /* trans to receipt_rate 5 is null */
               ELSE
                  /*************************************************
                   *  if all fields are populated, we need to
                   *  check to make sure that they are logically
                   *  correct.
                   ***************************************************/

                   calc_amt_applied_fmt(l_invoice_currency_code5,
                                    l_amount_applied_from5,
                                    l_trans_to_receipt_rate5,
                                    l_temp_amt_applied,
				    'N');

                   calc_amt_applied_from_fmt(l_currency_code,
                                         l_amount_applied5,
                                         l_trans_to_receipt_rate5,
                                         l_temp_amt_applied_from,
					 'N');

                   ar_cc_lockbox.calc_cross_rate(
                                l_amount_applied5,
                                l_amount_applied_from5,
                                l_invoice_currency_code5,
                                l_currency_code,
                                l_temp_trans_to_receipt_rate);
                   IF ( (l_temp_amt_applied = l_amount_applied5) OR
                        (l_temp_amt_applied_from =
                                           l_amount_applied_from5)   OR
                        (l_temp_trans_to_receipt_rate =
                                           l_trans_to_receipt_rate5)) THEN

                       /* since one or more of the conditions are true
                          then we assume that everything is fine. */
                          debug1('validation passed ' );
                    ELSE
                         UPDATE AR_PAYMENTS_INTERFACE
                              SET invoice5_status = 'AR_PLB_CC_INVALID_VALUE'
                         WHERE rowid = l_rowid;
                    END IF;

               END IF;   /* if one of the 3 items is NULL */
            ELSE
                 /*****************************************************
                    currencies do not match, they are not fixed rate and
                    cross currency enabled profile is not on.
                    then set the status to be a currency conflict between
                    the invoice and receipt currencies
                   ***************************************************/
                 UPDATE AR_PAYMENTS_INTERFACE
                      SET invoice5_status = 'AR_PLB_CURR_CONFLICT'
                         WHERE rowid = l_rowid;
            END IF;
	  ELSE /* Bug 2066392.  Single currency */
	    IF l_amount_applied_from5 is not null THEN
	      IF l_amount_applied5 is not null THEN
		IF l_amount_applied_from5 <> l_amount_applied5 THEN
		  UPDATE AR_PAYMENTS_INTERFACE
		      SET invoice5_status = 'AR_PLB_CC_INVALID_VALUE'
		  WHERE rowid = l_rowid;
		END IF;
	      ELSE
		IF l_format_amount5 = 'Y' THEN
		  fnd_currency.Get_Info(l_invoice_currency_code5,
                                l_precision,
                                l_extended_precision,
                                l_mau);
		  l_unformat_amount := l_amount_applied_from5 * power(10, l_precision);
		ELSE
		  l_unformat_amount := l_amount_applied_from5;
		END IF;
		UPDATE AR_PAYMENTS_INTERFACE
		      SET  amount_applied5 = l_unformat_amount
		      WHERE  rowid = l_rowid;
	      END IF;
	    END IF;
          END IF;
      END IF;
   END IF;   /* if matching number 5 is not null */
<<END_5>>

   /****************   need to check matching number 6 *************/

/* checking 6th trx_number */
debug1('invoice6 is not null =  ' || l_matching_number6);
IF (l_matching_number6 is not NULL) THEN

   /*  added trx_amt_due_remX for bug 883345 */
   /*  Changed the where clause and added the exception for bug 1052313
       and 1097549 */
   BEGIN
        SELECT  sum(count(distinct ps.customer_trx_id))
        INTO    l_tot_trx6
        FROM    ar_payment_schedules ps
        WHERE   ps.trx_number = l_matching_number6
        AND     ps.trx_date = l_resolved_matching6_date /* Bug fix 2926664 */
        AND    (ps.customer_id  IN
                 (
                   select l_customer_id from dual
                   union
                   select related_cust_account_id
                   from   hz_cust_acct_relate rel
                   where  rel.cust_account_id = l_customer_id
                   and    rel.status = 'A'
                   and    rel.bill_to_flag = 'Y'
                   union
                   select rel.related_cust_account_id
                   from   ar_paying_relationships_v rel,
                          hz_cust_accounts acc
                   where  rel.party_id = acc.party_id
                   and    acc.cust_account_id = l_customer_id
                   and    l_receipt_date BETWEEN effective_start_date
                                             AND effective_end_date
                 )
                 or
                 l_pay_unrelated_invoices = 'Y'
                )
        GROUP BY ps.customer_trx_id
        HAVING sum(ps.amount_due_remaining) <> 0;

        IF (l_tot_trx6 > 1) then
                update ar_payments_interface pi
                set    invoice6_status = 'AR_PLB_DUP_INV'
                where rowid = l_rowid;
                goto END_6;
        ELSE
                SELECT  invoice_currency_code,
                        amount_due_remaining
                INTO    ps_currency_code6,
                        trx_amt_due_rem6
                FROM    ar_payment_schedules ps,
                        ra_cust_trx_types    tt
                WHERE   ps.trx_number = l_matching_number6
                AND     ps.status = decode(tt.allow_overapplication_flag,
                               'N', 'OP',
                                ps.status)
                AND     ps.class NOT IN ('PMT','GUAR')
                AND     ps.payment_schedule_id =
                        (select min(ps.payment_schedule_id)
                         from   ar_payment_schedules ps,
                                ra_cust_trx_types    tt
                         where  ps.trx_number = l_matching_number6
                         and    ps.trx_date = l_resolved_matching6_date /* Bug fix 2926664 */
                         and    (ps.customer_id  IN
                                   (
                                      select l_customer_id from dual
                                      union
                                      select related_cust_account_id
                                      from   hz_cust_acct_relate rel
                                      where  rel.cust_account_id
                                             = l_customer_id
                                      and    rel.status = 'A'
                                      and    rel.bill_to_flag = 'Y'
                                      union
                                      select rel.related_cust_account_id
                                      from   ar_paying_relationships_v rel,
                                             hz_cust_accounts acc
                                      where  rel.party_id = acc.party_id
                                      and    acc.cust_account_id
                                             = l_customer_id
                                      and    l_receipt_date
                                             BETWEEN effective_start_date
                                                 AND effective_end_date
                                   )
                                   or
                                   l_pay_unrelated_invoices = 'Y'
                                 )
                         and    ps.cust_trx_type_id = tt.cust_trx_type_id
                         and    ps.class NOT IN ('PMT','GUAR')
                         and    ps.status=decode(tt.allow_overapplication_flag,
						'N', 'OP',
                                            ps.status))
                AND    (ps.customer_id  IN
                 (
                   select l_customer_id from dual
                   union
                   select related_cust_account_id
                   from   hz_cust_acct_relate rel
                   where  rel.cust_account_id = l_customer_id
                   and    rel.status = 'A'
                   and    rel.bill_to_flag = 'Y'
                   union
                   select rel.related_cust_account_id
                   from   ar_paying_relationships_v rel,
                          hz_cust_accounts acc
                   where  rel.party_id = acc.party_id
                   and    acc.cust_account_id = l_customer_id
                   and    l_receipt_date BETWEEN effective_start_date
                                             AND effective_end_date
                 )
                 or
                 l_pay_unrelated_invoices = 'Y'
                )
                AND     ps.cust_trx_type_id = tt.cust_trx_type_id;
        END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       goto END_6;
   END;

  debug1('currency code6 of invoice from the ps = ' || ps_currency_code6);
  /********************************************************
   *   if transmission has null currency code use the one
   *   from Payment Schedules
   *********************************************************/
  IF (l_invoice_currency_code6 is NULL ) THEN
    debug1('currency code is null.. setting = ' || ps_currency_code6);
    l_invoice_currency_code6 := ps_currency_code6;

     /* update ar_payment_interface to have the invoice currency_code */
     UPDATE ar_payments_interface
        SET invoice_currency_code6 = l_invoice_currency_code6
     WHERE  rowid = l_rowid;
  END IF;   /* end if invoice currency code was null */

  /****************************************************************
   * check to see if the currency code matches or is was not included
   * in the transmission
   ****************************************************************/
   debug1('l_invoice_currency_code6 = ' || l_invoice_currency_code6);
   debug1('ps_currency_code = ' || ps_currency_code6);

   IF  (l_invoice_currency_code6 <> ps_currency_code6) then
    debug1('currency code give does not match payment schedules..');
    UPDATE AR_PAYMENTS_INTERFACE
        SET invoice6_status = 'AR_PLB_CURRENCY_BAD'
    WHERE  rowid = l_rowid;
   ELSE
       /* Bug:1513671 we know the invoice currency code so we can now format the
          amount applied if we need to */

       IF (p_format_amount6 = 'Y') THEN
          fnd_currency.Get_Info(l_invoice_currency_code6,
                                l_precision,
                                l_extended_precision,
                                l_mau);
          l_amount_applied6 := round(l_amount_applied6 / power(10, l_precision),
                                     l_precision);
       END IF;

      /*************************************************************
       * if the currency code of the transaction does not equal the
       *  currency code of the receipt, then check for cross currency
       *  or Euro case
       **************************************************************/
      IF ( l_invoice_currency_code6 <> l_currency_code) THEN
       debug1('currency code of receipt does not match currency code of inv');

       /***********************************************************
        * we need to check to see if we have cross currency
        * profile enabled or we are dealing with a fixed rate
        * currency
        ************************************************************/

         l_is_fixed_rate := gl_currency_api.is_fixed_rate(
                            l_currency_code,      /*receipt currency */
                            l_invoice_currency_code6,  /* inv currency */
                            nvl(l_receipt_date,sysdate));

         debug1('is this a fixed rate = ' || l_is_fixed_rate);
         debug1('is cross curr enabled??  ' || l_enable_cross_currency);

         IF ( (l_is_fixed_rate = 'Y')  or
              (l_enable_cross_currency = 'Y')) THEN
           /* we have to make sure that all fields are populated */

            IF ( (l_amount_applied_from6 IS NULL) or
                 (l_amount_applied6 IS NULL)  or
                 (l_trans_to_receipt_rate6 IS NULL) )  THEN

             /* we need to check the rate 1st.  If both amounts columns are
                populated, then we calculate the rate.   If one amount is
                missing and the rate is null, then we try to get the rate from
                GL based on the profile option */

                IF ( l_trans_to_receipt_rate6 is NULL) THEN
                     debug1('trans_to_receipt_rate6 is null');
                  /* if neither amount is null then we calculate the rate */

                     debug1('amount applied = ' || to_char(l_amount_applied6));
                     debug1('amount applied from = ' || to_char(l_amount_applied_from6));
                     IF ( (l_amount_applied6 IS NOT NULL) and
                          (l_amount_applied_from6 IS NOT NULL)) Then

                          /********************************************
                           *  if we have a fixed rate, we need to get the
                           *  rate from GL and verify the validity of the
                           *  2 amount columns with the rate that we get
                           **********************************************/
                          IF (l_is_fixed_rate = 'Y') THEN
                             /* get the fixed rate from GL */
                             l_trans_to_receipt_rate6 :=
                                    gl_currency_api.get_rate(
                                           l_invoice_currency_code6,
                                           l_currency_code,
                                           l_receipt_date);

                             /*************************************************
                              *  if all fields are populated, we need to
                              *  check to make sure that they are logically
                              *  correct.
                              ************************************************/
                              calc_amt_applied_fmt(l_invoice_currency_code6,
                                               l_amount_applied_from6,
                                               l_trans_to_receipt_rate6,
                                               l_temp_amt_applied,
					       'N');

                              calc_amt_applied_from_fmt(l_currency_code,
                                                    l_amount_applied6,
                                                    l_trans_to_receipt_rate6,
                                                    l_temp_amt_applied_from,
						    'N');

                              ar_cc_lockbox.calc_cross_rate(
                                                  l_amount_applied6,
                                                  l_amount_applied_from6,
                                                  l_invoice_currency_code6,
                                                  l_currency_code,
                                                  l_temp_trans_to_receipt_rate);
                              IF ( (l_temp_amt_applied = l_amount_applied6) OR
                                   (l_temp_amt_applied_from =
                                           l_amount_applied_from6)   OR
                                   (l_temp_trans_to_receipt_rate =
                                           l_trans_to_receipt_rate6)) THEN

                                /********************************************
                                 * since one or more of the conditions are
                                 * true then we assume that everything is
                                 * fine and we can write the rate to the
                                 * database
                                 *********************************************/
                                   debug1('validation passed ' );
                                   UPDATE ar_payments_interface
                                     SET trans_to_receipt_rate6 =
                                             l_trans_to_receipt_rate6
                                     WHERE rowid = l_rowid;
                                ELSE
                                  UPDATE AR_PAYMENTS_INTERFACE
                                    SET invoice6_status =
                                             'AR_PLB_CC_INVALID_VALUE'
                                   WHERE rowid = l_rowid;
                               END IF;

                          ELSE
                             /* calculate the least rate that would convert
                                the items */
                             ar_cc_lockbox.calc_cross_rate(
                                l_amount_applied6,
                                l_amount_applied_from6,
                                l_invoice_currency_code6,
                                l_currency_code,
                                l_trans_to_receipt_rate6);

                             /* once the rate has been calculated, we need
                                to write it to the table */
                             UPDATE ar_payments_interface
                                SET trans_to_receipt_rate6 =
                                   l_trans_to_receipt_rate6
                              WHERE rowid = l_rowid;
                          END IF;

                     ELSE
                       /* need to derive the rate if possible*/
                       debug1( 'need to derive rate ');
                       IF (p_default_exchange_rate_type IS NOT NULL or
                             l_is_fixed_rate = 'Y' ) THEN
                          l_trans_to_receipt_rate6 :=
                              gl_currency_api.get_rate_sql(
                                                l_invoice_currency_code6,
                                                l_currency_code,
                                                l_receipt_date,
                                                p_default_exchange_rate_type);
                     debug1('calculated rate = ' || to_char(l_trans_to_receipt_rate6));
                        /* if there is no rate in GL, there is nothing
                           more we can do */
                           IF (l_trans_to_receipt_rate6 < 0 )  THEN

                            UPDATE AR_PAYMENTS_INTERFACE
                               SET invoice6_status = 'AR_PLB_NO_EXCHANGE_RATE'
                                WHERE rowid = l_rowid;

                           ELSE
                             /* once the rate has been calculated, we need
                                to write it to the table */

                             debug1('writing rate to database ' || to_char(l_trans_to_receipt_rate6));

                             UPDATE ar_payments_interface
                                SET trans_to_receipt_rate6 =
                                   l_trans_to_receipt_rate6
                              WHERE rowid = l_rowid;

                             /* finish the calculation because we have a rate*/

                             IF (l_amount_applied_from6 IS NULL) THEN
                                calc_amt_applied_from_fmt(l_currency_code,
                                                      l_amount_applied6,
                                                      l_trans_to_receipt_rate6,
                                                      l_amount_applied_from6,
						      l_format_amount_applied_from6);
                                update ar_payments_interface
                                   set  amount_applied_from6 =
                                           l_amount_applied_from6
                                   where rowid = l_rowid;

                             ELSE
                              /* calculate amount applied and save to db */
                              calc_amt_applied_fmt(l_invoice_currency_code6,
                                               l_amount_applied_from6,
                                               l_trans_to_receipt_rate6,
                                               l_amount_applied6,
					       l_format_amount6);
                              debug1('calculated amt applied = ' || to_char(l_amount_applied6));
                              /* to deal with rounding errors that happen
                                 with fixed rate currencies, we need to
                                 take the amount_due_remaining of the trx
                                 convert it to the receipt currency and
                                 compare that value with the
                                 amount_applied_from original value

                                 ADDED for BUG 883345  */

                             IF (l_is_fixed_rate = 'Y') THEN

                                calc_amt_applied_from_fmt(l_currency_code,
                                                      trx_amt_due_rem6,
                                                      l_trans_to_receipt_rate6,
                                                      amt_applied_from_tc,
						      'N');

                                 IF (amt_applied_from_tc =
                                     l_amount_applied_from6 ) THEN
				   IF (l_format_amount6 = 'Y') THEN
                                     fnd_currency.Get_Info(
                                            l_invoice_currency_code6,
                                            l_precision,
                                            l_extended_precision,
                                            l_mau);

                                     l_amount_applied6 :=
                                        trx_amt_due_rem6 * (10**l_precision);
				  ELSE
                                     l_amount_applied6 := trx_amt_due_rem6 ;
				  END IF;
                                END IF;
                             END IF;

                               update ar_payments_interface
                                   set  amount_applied6 =
                                           l_amount_applied6
                                   where rowid = l_rowid;

                             END IF;   /* if amount_applied_From6 is null */
                           END IF;  /* if rate is null after it is calc */
                       ELSE       /* Bug 1519765 */
                            UPDATE AR_PAYMENTS_INTERFACE
                               SET invoice6_status = 'AR_PLB_NO_EXCHANGE_RATE'
                                WHERE rowid = l_rowid;
                       END IF;     /* if derive profile is not null */
                     END IF;

                  /*  we know that trans_to_receipt_rate6 is not null,
                      therefore, one of the amount values must be null and
                      we have to calculate it */
                  ELSE
                      /* is amount_applied_From null?? */
                      IF (l_amount_applied_from6 IS NULL) THEN
                         calc_amt_applied_from_fmt(l_currency_code,
                                               l_amount_applied6,
                                               l_trans_to_receipt_rate6,
                                               l_amount_applied_from6,
					       l_format_amount_applied_from6);
                          update ar_payments_interface
                            set  amount_applied_from6 =
                                      l_amount_applied_from6
                            where rowid = l_rowid;

                      ELSE
                         calc_amt_applied_fmt(l_invoice_currency_code6,
                                          l_amount_applied_from6,
                                          l_trans_to_receipt_rate6,
                                          l_amount_applied6,
					  l_format_amount6);

                      /* to deal with rounding errors that happen
                         with fixed rate currencies, we need to
                         take the amount_due_remaining of the trx
                         convert it to the receipt currency and
                         compare that value with the
                         amount_applied_from original value

                         ADDED for BUG 883345  */

                          IF (l_is_fixed_rate = 'Y') THEN

                             calc_amt_applied_from_fmt(l_currency_code,
                                                   trx_amt_due_rem6,
                                                   l_trans_to_receipt_rate6,
                                                   amt_applied_from_tc, 'N');

                             IF (amt_applied_from_tc =
                                  l_amount_applied_from6 ) THEN
			       IF (l_format_amount6 = 'Y') THEN
                                 fnd_currency.Get_Info(
                                          l_invoice_currency_code6,
                                          l_precision,
                                          l_extended_precision,
                                          l_mau);

                                 l_amount_applied6 :=
                                        trx_amt_due_rem6 * (10**l_precision);
			       ELSE
                                 l_amount_applied6 := trx_amt_due_rem6 ;
			       END IF;
                             END IF;
                          END IF;

                         UPDATE AR_PAYMENTS_INTERFACE
                              SET  amount_applied6 =
                                      l_amount_applied6
                              WHERE  rowid = l_rowid;

                      END IF;
                  END IF;   /* trans to receipt_rate 6 is null */
               ELSE
                  /*************************************************
                   *  if all fields are populated, we need to
                   *  check to make sure that they are logically
                   *  correct.
                   ***************************************************/

                   calc_amt_applied_fmt(l_invoice_currency_code6,
                                    l_amount_applied_from6,
                                    l_trans_to_receipt_rate6,
                                    l_temp_amt_applied,
				    'N');

                   calc_amt_applied_from_fmt(l_currency_code,
                                         l_amount_applied6,
                                         l_trans_to_receipt_rate6,
                                         l_temp_amt_applied_from,
					 'N');

                   ar_cc_lockbox.calc_cross_rate(
                                l_amount_applied6,
                                l_amount_applied_from6,
                                l_invoice_currency_code6,
                                l_currency_code,
                                l_temp_trans_to_receipt_rate);
                   IF ( (l_temp_amt_applied = l_amount_applied6) OR
                        (l_temp_amt_applied_from =
                                           l_amount_applied_from6)   OR
                        (l_temp_trans_to_receipt_rate =
                                           l_trans_to_receipt_rate6)) THEN

                       /* since one or more of the conditions are true
                          then we assume that everything is fine. */
                          debug1('validation passed ' );
                    ELSE
                         UPDATE AR_PAYMENTS_INTERFACE
                              SET invoice6_status = 'AR_PLB_CC_INVALID_VALUE'
                         WHERE rowid = l_rowid;
                    END IF;

               END IF;   /* if one of the 3 items is NULL */
            ELSE
                 /*****************************************************
                    currencies do not match, they are not fixed rate and
                    cross currency enabled profile is not on.
                    then set the status to be a currency conflict between
                    the invoice and receipt currencies
                   ***************************************************/
                 UPDATE AR_PAYMENTS_INTERFACE
                      SET invoice6_status = 'AR_PLB_CURR_CONFLICT'
                         WHERE rowid = l_rowid;
            END IF;
	  ELSE /* Bug 2066392.  Single currency */
	    IF l_amount_applied_from6 is not null THEN
	      IF l_amount_applied6 is not null THEN
		IF l_amount_applied_from6 <> l_amount_applied6 THEN
		  UPDATE AR_PAYMENTS_INTERFACE
		      SET invoice6_status = 'AR_PLB_CC_INVALID_VALUE'
		  WHERE rowid = l_rowid;
		END IF;
	      ELSE
		IF l_format_amount6 = 'Y' THEN
		  fnd_currency.Get_Info(l_invoice_currency_code6,
                                l_precision,
                                l_extended_precision,
                                l_mau);
		  l_unformat_amount := l_amount_applied_from6 * power(10, l_precision);
		ELSE
		  l_unformat_amount := l_amount_applied_from6;
		END IF;
		UPDATE AR_PAYMENTS_INTERFACE
		      SET  amount_applied6 = l_unformat_amount
		      WHERE  rowid = l_rowid;
	      END IF;
	    END IF;
          END IF;
      END IF;
   END IF;   /* if matching number 6 is not null */
<<END_6>>

   /****************   need to check matching number 7 *************/

/* checking 7th trx_number */
debug1('invoice7 is not null =  ' || l_matching_number7);
IF (l_matching_number7 is not NULL) THEN

   /*  added trx_amt_due_remX for bug 883345 */
   /*  Changed the where clause and added the exception for bug 1052313
       and 1097549 */
   BEGIN
        SELECT  sum(count(distinct ps.customer_trx_id))
        INTO    l_tot_trx7
        FROM    ar_payment_schedules ps
        WHERE   ps.trx_number = l_matching_number7
        AND     ps.trx_date = l_resolved_matching7_date /* Bug fix 2926664 */
        AND    (ps.customer_id  IN
                 (
                   select l_customer_id from dual
                   union
                   select related_cust_account_id
                   from   hz_cust_acct_relate rel
                   where  rel.cust_account_id = l_customer_id
                   and    rel.status = 'A'
                   and    rel.bill_to_flag = 'Y'
                   union
                   select rel.related_cust_account_id
                   from   ar_paying_relationships_v rel,
                          hz_cust_accounts acc
                   where  rel.party_id = acc.party_id
                   and    acc.cust_account_id = l_customer_id
                   and    l_receipt_date BETWEEN effective_start_date
                                             AND effective_end_date
                 )
                 or
                 l_pay_unrelated_invoices = 'Y'
                )
        GROUP BY ps.customer_trx_id
        HAVING sum(ps.amount_due_remaining) <> 0;

        IF (l_tot_trx7 > 1) then
                update ar_payments_interface pi
                set    invoice7_status = 'AR_PLB_DUP_INV'
                where rowid = l_rowid;
                goto END_7;
        ELSE
                SELECT  invoice_currency_code,
                        amount_due_remaining
                INTO    ps_currency_code7,
                        trx_amt_due_rem7
                FROM    ar_payment_schedules ps,
                        ra_cust_trx_types    tt
                WHERE   ps.trx_number = l_matching_number7
                AND     ps.status = decode(tt.allow_overapplication_flag,
                               'N', 'OP',
                                ps.status)
                AND     ps.class NOT IN ('PMT','GUAR')
                AND     ps.payment_schedule_id =
                        (select min(ps.payment_schedule_id)
                         from   ar_payment_schedules ps,
                                ra_cust_trx_types    tt
                         where  ps.trx_number = l_matching_number7
                         and    ps.trx_date = l_resolved_matching7_date /* Bug fix 2926664 */
                         and    (ps.customer_id  IN
                                   (
                                      select l_customer_id from dual
                                      union
                                      select related_cust_account_id
                                      from   hz_cust_acct_relate rel
                                      where  rel.cust_account_id
                                             = l_customer_id
                                      and    rel.status = 'A'
                                      and    rel.bill_to_flag = 'Y'
                                      union
                                      select rel.related_cust_account_id
                                      from   ar_paying_relationships_v rel,
                                             hz_cust_accounts acc
                                      where  rel.party_id = acc.party_id
                                      and    acc.cust_account_id
                                             = l_customer_id
                                      and    l_receipt_date
                                             BETWEEN effective_start_date
                                                 AND effective_end_date
                                   )
                                   or
                                   l_pay_unrelated_invoices = 'Y'
                                 )
                         and    ps.cust_trx_type_id = tt.cust_trx_type_id
                         and    ps.class NOT IN ('PMT','GUAR')
                         and ps.status=decode(tt.allow_overapplication_flag,
						'N' , 'OP',
                                            ps.status))
                AND    (ps.customer_id  IN
                 (
                   select l_customer_id from dual
                   union
                   select related_cust_account_id
                   from   hz_cust_acct_relate rel
                   where  rel.cust_account_id = l_customer_id
                   and    rel.status = 'A'
                   and    rel.bill_to_flag = 'Y'
                   union
                   select rel.related_cust_account_id
                   from   ar_paying_relationships_v rel,
                          hz_cust_accounts acc
                   where  rel.party_id = acc.party_id
                   and    acc.cust_account_id = l_customer_id
                   and    l_receipt_date BETWEEN effective_start_date
                                             AND effective_end_date
                 )
                 or
                 l_pay_unrelated_invoices = 'Y'
                )
                AND     ps.cust_trx_type_id = tt.cust_trx_type_id;
        END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       goto END_7;
   END;

  debug1('currency code7 of invoice from the ps = ' || ps_currency_code7);
  /********************************************************
   *   if transmission has null currency code use the one
   *   from Payment Schedules
   *********************************************************/
  IF (l_invoice_currency_code7 is NULL ) THEN
    debug1('currency code is null.. setting = ' || ps_currency_code7);
    l_invoice_currency_code7 := ps_currency_code7;

     /* update ar_payment_interface to have the invoice currency_code */
     UPDATE ar_payments_interface
        SET invoice_currency_code7 = l_invoice_currency_code7
     WHERE  rowid = l_rowid;
  END IF;   /* end if invoice currency code was null */

  /****************************************************************
   * check to see if the currency code matches or is was not included
   * in the transmission
   ****************************************************************/
   debug1('l_invoice_currency_code7 = ' || l_invoice_currency_code7);
   debug1('ps_currency_code = ' || ps_currency_code7);

   IF  (l_invoice_currency_code7 <> ps_currency_code7) then
    debug1('currency code give does not match payment schedules..');
    UPDATE AR_PAYMENTS_INTERFACE
        SET invoice7_status = 'AR_PLB_CURRENCY_BAD'
    WHERE  rowid = l_rowid;
   ELSE
       /* Bug:1513671 we know the invoice currency code so we can now format the
          amount applied if we need to */

       IF (p_format_amount7 = 'Y') THEN
          fnd_currency.Get_Info(l_invoice_currency_code7,
                                l_precision,
                                l_extended_precision,
                                l_mau);
          l_amount_applied7 := round(l_amount_applied7 / power(10, l_precision),
                                     l_precision);
       END IF;

      /*************************************************************
       * if the currency code of the transaction does not equal the
       *  currency code of the receipt, then check for cross currency
       *  or Euro case
       **************************************************************/
      IF ( l_invoice_currency_code7 <> l_currency_code) THEN
       debug1('currency code of receipt does not match currency code of inv');

       /***********************************************************
        * we need to check to see if we have cross currency
        * profile enabled or we are dealing with a fixed rate
        * currency
        ************************************************************/

         l_is_fixed_rate := gl_currency_api.is_fixed_rate(
                            l_currency_code,      /*receipt currency */
                            l_invoice_currency_code7,  /* inv currency */
                            nvl(l_receipt_date,sysdate));

         debug1('is this a fixed rate = ' || l_is_fixed_rate);
         debug1('is cross curr enabled??  ' || l_enable_cross_currency);

         IF ( (l_is_fixed_rate = 'Y')  or
              (l_enable_cross_currency = 'Y')) THEN
           /* we have to make sure that all fields are populated */

            IF ( (l_amount_applied_from7 IS NULL) or
                 (l_amount_applied7 IS NULL)  or
                 (l_trans_to_receipt_rate7 IS NULL) )  THEN

             /* we need to check the rate 1st.  If both amounts columns are
                populated, then we calculate the rate.   If one amount is
                missing and the rate is null, then we try to get the rate from
                GL based on the profile option */

                IF ( l_trans_to_receipt_rate7 is NULL) THEN
                     debug1('trans_to_receipt_rate7 is null');
                  /* if neither amount is null then we calculate the rate */

                     debug1('amount applied = ' || to_char(l_amount_applied7));
                     debug1('amount applied from = ' || to_char(l_amount_applied_from7));
                     IF ( (l_amount_applied7 IS NOT NULL) and
                          (l_amount_applied_from7 IS NOT NULL)) Then

                          /********************************************
                           *  if we have a fixed rate, we need to get the
                           *  rate from GL and verify the validity of the
                           *  2 amount columns with the rate that we get
                           **********************************************/
                          IF (l_is_fixed_rate = 'Y') THEN
                             /* get the fixed rate from GL */
                             l_trans_to_receipt_rate7 :=
                                    gl_currency_api.get_rate(
                                           l_invoice_currency_code7,
                                           l_currency_code,
                                           l_receipt_date);

                             /*************************************************
                              *  if all fields are populated, we need to
                              *  check to make sure that they are logically
                              *  correct.
                              ************************************************/
                              calc_amt_applied_fmt(l_invoice_currency_code7,
                                               l_amount_applied_from7,
                                               l_trans_to_receipt_rate7,
                                               l_temp_amt_applied,
					       'N');

                              calc_amt_applied_from_fmt(l_currency_code,
                                                    l_amount_applied7,
                                                    l_trans_to_receipt_rate7,
                                                    l_temp_amt_applied_from,
						    'N');

                              ar_cc_lockbox.calc_cross_rate(
                                                  l_amount_applied7,
                                                  l_amount_applied_from7,
                                                  l_invoice_currency_code7,
                                                  l_currency_code,
                                                  l_temp_trans_to_receipt_rate);
                              IF ( (l_temp_amt_applied = l_amount_applied7) OR
                                   (l_temp_amt_applied_from =
                                           l_amount_applied_from7)   OR
                                   (l_temp_trans_to_receipt_rate =
                                           l_trans_to_receipt_rate7)) THEN

                                /********************************************
                                 * since one or more of the conditions are
                                 * true then we assume that everything is
                                 * fine and we can write the rate to the
                                 * database
                                 *********************************************/
                                   debug1('validation passed ' );
                                   UPDATE ar_payments_interface
                                     SET trans_to_receipt_rate7 =
                                             l_trans_to_receipt_rate7
                                     WHERE rowid = l_rowid;
                                ELSE
                                  UPDATE AR_PAYMENTS_INTERFACE
                                    SET invoice7_status =
                                             'AR_PLB_CC_INVALID_VALUE'
                                   WHERE rowid = l_rowid;
                               END IF;

                          ELSE
                             /* calculate the least rate that would convert
                                the items */
                             ar_cc_lockbox.calc_cross_rate(
                                l_amount_applied7,
                                l_amount_applied_from7,
                                l_invoice_currency_code7,
                                l_currency_code,
                                l_trans_to_receipt_rate7);

                             /* once the rate has been calculated, we need
                                to write it to the table */
                             UPDATE ar_payments_interface
                                SET trans_to_receipt_rate7 =
                                   l_trans_to_receipt_rate7
                              WHERE rowid = l_rowid;
                          END IF;

                     ELSE
                       /* need to derive the rate if possible*/
                       debug1( 'need to derive rate ');
                       IF (p_default_exchange_rate_type IS NOT NULL or
                             l_is_fixed_rate = 'Y' ) THEN
                          l_trans_to_receipt_rate7 :=
                              gl_currency_api.get_rate_sql(
                                                l_invoice_currency_code7,
                                                l_currency_code,
                                                l_receipt_date,
                                                p_default_exchange_rate_type);
                     debug1('calculated rate = ' || to_char(l_trans_to_receipt_rate7));
                        /* if there is no rate in GL, there is nothing
                           more we can do */
                           IF (l_trans_to_receipt_rate7 < 0 )  THEN

                            UPDATE AR_PAYMENTS_INTERFACE
                               SET invoice7_status = 'AR_PLB_NO_EXCHANGE_RATE'
                                WHERE rowid = l_rowid;

                           ELSE
                             /* once the rate has been calculated, we need
                                to write it to the table */

                             debug1('writing rate to database ' || to_char(l_trans_to_receipt_rate7));

                             UPDATE ar_payments_interface
                                SET trans_to_receipt_rate7 =
                                   l_trans_to_receipt_rate7
                              WHERE rowid = l_rowid;

                             /* finish the calculation because we have a rate*/

                             IF (l_amount_applied_from7 IS NULL) THEN
                                calc_amt_applied_from_fmt(l_currency_code,
                                                      l_amount_applied7,
                                                      l_trans_to_receipt_rate7,
                                                      l_amount_applied_from7,
						      l_format_amount_applied_from7);
                                update ar_payments_interface
                                   set  amount_applied_from7 =
                                           l_amount_applied_from7
                                   where rowid = l_rowid;

                             ELSE
                              /* calculate amount applied and save to db */
                              calc_amt_applied_fmt(l_invoice_currency_code7,
                                               l_amount_applied_from7,
                                               l_trans_to_receipt_rate7,
                                               l_amount_applied7,
					       l_format_amount7);
                              debug1('calculated amt applied = ' || to_char(l_amount_applied7));
                          /* to deal with rounding errors that happen
                             with fixed rate currencies, we need to
                             take the amount_due_remaining of the trx
                             convert it to the receipt currency and
                             compare that value with the
                             amount_applied_from original value

                             ADDED for BUG 883345  */

                              IF (l_is_fixed_rate = 'Y') THEN

                                 calc_amt_applied_from_fmt(l_currency_code,
                                                       trx_amt_due_rem7,
                                                       l_trans_to_receipt_rate7,
                                                       amt_applied_from_tc,
						       'N');

                                 IF (amt_applied_from_tc =
                                      l_amount_applied_from7 ) THEN
				   IF (l_format_amount7 = 'Y') THEN
                                     fnd_currency.Get_Info(
                                              l_invoice_currency_code7,
                                              l_precision,
                                              l_extended_precision,
                                              l_mau);

                                     l_amount_applied7 :=
                                           trx_amt_due_rem7 * (10**l_precision);
				   ELSE
                                     l_amount_applied7 := trx_amt_due_rem7 ;
				   END IF;
                                 END IF;
                              END IF;

                               update ar_payments_interface
                                   set  amount_applied7 =
                                           l_amount_applied7
                                   where rowid = l_rowid;

                             END IF;   /* if amount_applied_From7 is null */
                           END IF;  /* if rate is null after it is calc */
                       ELSE       /* Bug 1519765 */
                            UPDATE AR_PAYMENTS_INTERFACE
                               SET invoice7_status = 'AR_PLB_NO_EXCHANGE_RATE'
                                WHERE rowid = l_rowid;
                       END IF;     /* if derive profile is not null */
                     END IF;

                  /*  we know that trans_to_receipt_rate7 is not null,
                      therefore, one of the amount values must be null and
                      we have to calculate it */
                  ELSE
                      /* is amount_applied_From null?? */
                      IF (l_amount_applied_from7 IS NULL) THEN
                         calc_amt_applied_from_fmt(l_currency_code,
                                               l_amount_applied7,
                                               l_trans_to_receipt_rate7,
                                               l_amount_applied_from7,
					       l_format_amount_applied_from7);
                          update ar_payments_interface
                            set  amount_applied_from7 =
                                      l_amount_applied_from7
                            where rowid = l_rowid;

                      ELSE
                         calc_amt_applied_fmt(l_invoice_currency_code7,
                                          l_amount_applied_from7,
                                          l_trans_to_receipt_rate7,
                                          l_amount_applied7,
					  l_format_amount7);

                          /* to deal with rounding errors that happen
                             with fixed rate currencies, we need to
                             take the amount_due_remaining of the trx
                             convert it to the receipt currency and
                             compare that value with the
                             amount_applied_from original value

                             ADDED for BUG 883345  */

                              IF (l_is_fixed_rate = 'Y') THEN

                                 calc_amt_applied_from_fmt(l_currency_code,
                                                       trx_amt_due_rem7,
                                                       l_trans_to_receipt_rate7,
                                                       amt_applied_from_tc,
						       'N');

                                 IF (amt_applied_from_tc =
                                      l_amount_applied_from7 ) THEN
				   IF (l_format_amount7 = 'Y') THEN
                                     fnd_currency.Get_Info(
                                              l_invoice_currency_code7,
                                              l_precision,
                                              l_extended_precision,
                                              l_mau);

                                     l_amount_applied7 :=
                                           trx_amt_due_rem7 * (10**l_precision);
				   ELSE
                                     l_amount_applied7 := trx_amt_due_rem7 ;
				   END IF;
                                 END IF;
                              END IF;

                         UPDATE AR_PAYMENTS_INTERFACE
                              SET  amount_applied7 =
                                      l_amount_applied7
                              WHERE  rowid = l_rowid;

                      END IF;
                  END IF;   /* trans to receipt_rate 7 is null */
               ELSE
                  /*************************************************
                   *  if all fields are populated, we need to
                   *  check to make sure that they are logically
                   *  correct.
                   ***************************************************/

                   calc_amt_applied_fmt(l_invoice_currency_code7,
                                    l_amount_applied_from7,
                                    l_trans_to_receipt_rate7,
                                    l_temp_amt_applied,
				    'N');

                   calc_amt_applied_from_fmt(l_currency_code,
                                         l_amount_applied7,
                                         l_trans_to_receipt_rate7,
                                         l_temp_amt_applied_from,
					 'N');

                   ar_cc_lockbox.calc_cross_rate(
                                l_amount_applied7,
                                l_amount_applied_from7,
                                l_invoice_currency_code7,
                                l_currency_code,
                                l_temp_trans_to_receipt_rate);
                   IF ( (l_temp_amt_applied = l_amount_applied7) OR
                        (l_temp_amt_applied_from =
                                           l_amount_applied_from7)   OR
                        (l_temp_trans_to_receipt_rate =
                                           l_trans_to_receipt_rate7)) THEN

                       /* since one or more of the conditions are true
                          then we assume that everything is fine. */
                          debug1('validation passed ' );
                    ELSE
                         UPDATE AR_PAYMENTS_INTERFACE
                              SET invoice7_status = 'AR_PLB_CC_INVALID_VALUE'
                         WHERE rowid = l_rowid;
                    END IF;

               END IF;   /* if one of the 3 items is NULL */
            ELSE
                 /*****************************************************
                    currencies do not match, they are not fixed rate and
                    cross currency enabled profile is not on.
                    then set the status to be a currency conflict between
                    the invoice and receipt currencies
                   ***************************************************/
                 UPDATE AR_PAYMENTS_INTERFACE
                      SET invoice7_status = 'AR_PLB_CURR_CONFLICT'
                         WHERE rowid = l_rowid;
            END IF;
	  ELSE /* Bug 2066392.  Single currency */
	    IF l_amount_applied_from7 is not null THEN
	      IF l_amount_applied7 is not null THEN
		IF l_amount_applied_from7 <> l_amount_applied7 THEN
		  UPDATE AR_PAYMENTS_INTERFACE
		      SET invoice7_status = 'AR_PLB_CC_INVALID_VALUE'
		  WHERE rowid = l_rowid;
		END IF;
	      ELSE
		IF l_format_amount7 = 'Y' THEN
		  fnd_currency.Get_Info(l_invoice_currency_code7,
                                l_precision,
                                l_extended_precision,
                                l_mau);
		  l_unformat_amount := l_amount_applied_from7 * power(10, l_precision);
		ELSE
		  l_unformat_amount := l_amount_applied_from7;
		END IF;
		UPDATE AR_PAYMENTS_INTERFACE
		      SET  amount_applied7 = l_unformat_amount
		      WHERE  rowid = l_rowid;
	      END IF;
	    END IF;
          END IF;
      END IF;
   END IF;   /* if matching number 7 is not null */
<<END_7>>

   /****************   need to check matching number 8 *************/

/* checking 8th trx_number */
debug1('invoice8 is not null =  ' || l_matching_number8);
IF (l_matching_number8 is not NULL) THEN

   /*  added trx_amt_due_remX for bug 883345 */
   /*  Changed the where clause and added the exception for bug 1052313
       and 1097549 */
   BEGIN
        SELECT  sum(count(distinct ps.customer_trx_id))
        INTO    l_tot_trx8
        FROM    ar_payment_schedules ps
        WHERE   ps.trx_number = l_matching_number8
        AND     ps.trx_date = l_resolved_matching8_date /* Bug fix 2926664 */
        AND    (ps.customer_id  IN
                 (
                   select l_customer_id from dual
                   union
                   select related_cust_account_id
                   from   hz_cust_acct_relate rel
                   where  rel.cust_account_id = l_customer_id
                   and    rel.status = 'A'
                   and    rel.bill_to_flag = 'Y'
                   union
                   select rel.related_cust_account_id
                   from   ar_paying_relationships_v rel,
                          hz_cust_accounts acc
                   where  rel.party_id = acc.party_id
                   and    acc.cust_account_id = l_customer_id
                   and    l_receipt_date BETWEEN effective_start_date
                                             AND effective_end_date
                 )
                 or
                 l_pay_unrelated_invoices = 'Y'
                )
        GROUP BY ps.customer_trx_id
        HAVING sum(ps.amount_due_remaining) <> 0;

        IF (l_tot_trx8 > 1) then
                update ar_payments_interface pi
                set    invoice8_status = 'AR_PLB_DUP_INV'
                where rowid = l_rowid;
                goto END_8;
        ELSE
                SELECT  invoice_currency_code,
                        amount_due_remaining
                INTO    ps_currency_code8,
                        trx_amt_due_rem8
                FROM    ar_payment_schedules ps,
                        ra_cust_trx_types    tt
                WHERE   ps.trx_number = l_matching_number8
                AND     ps.status = decode(tt.allow_overapplication_flag,
                               'N', 'OP',
                                ps.status)
                AND     ps.class NOT IN ('PMT','GUAR')
                AND     ps.payment_schedule_id =
                        (select min(ps.payment_schedule_id)
                         from   ar_payment_schedules ps,
                                ra_cust_trx_types    tt
                         where  ps.trx_number = l_matching_number8
                         and    ps.trx_date = l_resolved_matching8_date /* Bug fix 2926664 */
                         and    (ps.customer_id  IN
                                   (
                                      select l_customer_id from dual
                                      union
                                      select related_cust_account_id
                                      from   hz_cust_acct_relate rel
                                      where  rel.cust_account_id
                                             = l_customer_id
                                      and    rel.status = 'A'
                                      and    rel.bill_to_flag = 'Y'
                                      union
                                      select rel.related_cust_account_id
                                      from   ar_paying_relationships_v rel,
                                             hz_cust_accounts acc
                                      where  rel.party_id = acc.party_id
                                      and    acc.cust_account_id
                                             = l_customer_id
                                      and    l_receipt_date
                                             BETWEEN effective_start_date
                                                 AND effective_end_date
                                   )
                                   or
                                   l_pay_unrelated_invoices = 'Y'
                                 )
                         and    ps.cust_trx_type_id = tt.cust_trx_type_id
                         and    ps.class NOT IN ('PMT','GUAR')
                         and ps.status=decode(tt.allow_overapplication_flag,
						'N', 'OP',
                                            ps.status))
                AND    (ps.customer_id  IN
                 (
                   select l_customer_id from dual
                   union
                   select related_cust_account_id
                   from   hz_cust_acct_relate rel
                   where  rel.cust_account_id = l_customer_id
                   and    rel.status = 'A'
                   and    rel.bill_to_flag = 'Y'
                   union
                   select rel.related_cust_account_id
                   from   ar_paying_relationships_v rel,
                          hz_cust_accounts acc
                   where  rel.party_id = acc.party_id
                   and    acc.cust_account_id = l_customer_id
                   and    l_receipt_date BETWEEN effective_start_date
                                             AND effective_end_date
                 )
                 or
                 l_pay_unrelated_invoices = 'Y'
                )
                AND     ps.cust_trx_type_id = tt.cust_trx_type_id;
        END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       goto END_8;
   END;

  debug1('currency code8 of invoice from the ps = ' || ps_currency_code8);
  /********************************************************
   *   if transmission has null currency code use the one
   *   from Payment Schedules
   *********************************************************/
  IF (l_invoice_currency_code8 is NULL ) THEN
    debug1('currency code is null.. setting = ' || ps_currency_code8);
    l_invoice_currency_code8 := ps_currency_code8;

     /* update ar_payment_interface to have the invoice currency_code */
     UPDATE ar_payments_interface
        SET invoice_currency_code8 = l_invoice_currency_code8
     WHERE  rowid = l_rowid;
  END IF;   /* end if invoice currency code was null */

  /****************************************************************
   * check to see if the currency code matches or is was not included
   * in the transmission
   ****************************************************************/
   debug1('l_invoice_currency_code8 = ' || l_invoice_currency_code8);
   debug1('ps_currency_code = ' || ps_currency_code8);

   IF  (l_invoice_currency_code8 <> ps_currency_code8) then
    debug1('currency code give does not match payment schedules..');
    UPDATE AR_PAYMENTS_INTERFACE
        SET invoice8_status = 'AR_PLB_CURRENCY_BAD'
    WHERE  rowid = l_rowid;
   ELSE
       /* Bug:1513671 we know the invoice currency code so we can now format the
          amount applied if we need to */

       IF (p_format_amount8 = 'Y') THEN
          fnd_currency.Get_Info(l_invoice_currency_code8,
                                l_precision,
                                l_extended_precision,
                                l_mau);
          l_amount_applied8 := round(l_amount_applied8 / power(10, l_precision),
                                     l_precision);
       END IF;

      /*************************************************************
       * if the currency code of the transaction does not equal the
       *  currency code of the receipt, then check for cross currency
       *  or Euro case
       **************************************************************/
      IF ( l_invoice_currency_code8 <> l_currency_code) THEN
       debug1('currency code of receipt does not match currency code of inv');

       /***********************************************************
        * we need to check to see if we have cross currency
        * profile enabled or we are dealing with a fixed rate
        * currency
        ************************************************************/

         l_is_fixed_rate := gl_currency_api.is_fixed_rate(
                            l_currency_code,      /*receipt currency */
                            l_invoice_currency_code8,  /* inv currency */
                            nvl(l_receipt_date,sysdate));

         debug1('is this a fixed rate = ' || l_is_fixed_rate);
         debug1('is cross curr enabled??  ' || l_enable_cross_currency);

         IF ( (l_is_fixed_rate = 'Y')  or
              (l_enable_cross_currency = 'Y')) THEN
           /* we have to make sure that all fields are populated */

            IF ( (l_amount_applied_from8 IS NULL) or
                 (l_amount_applied8 IS NULL)  or
                 (l_trans_to_receipt_rate8 IS NULL) )  THEN

             /* we need to check the rate 1st.  If both amounts columns are
                populated, then we calculate the rate.   If one amount is
                missing and the rate is null, then we try to get the rate from
                GL based on the profile option */

                IF ( l_trans_to_receipt_rate8 is NULL) THEN
                     debug1('trans_to_receipt_rate8 is null');
                  /* if neither amount is null then we calculate the rate */

                     debug1('amount applied = ' || to_char(l_amount_applied8));
                     debug1('amount applied from = ' || to_char(l_amount_applied_from8));
                     IF ( (l_amount_applied8 IS NOT NULL) and
                          (l_amount_applied_from8 IS NOT NULL)) Then

                          /********************************************
                           *  if we have a fixed rate, we need to get the
                           *  rate from GL and verify the validity of the
                           *  2 amount columns with the rate that we get
                           **********************************************/
                          IF (l_is_fixed_rate = 'Y') THEN
                             /* get the fixed rate from GL */
                             l_trans_to_receipt_rate8 :=
                                    gl_currency_api.get_rate(
                                           l_invoice_currency_code8,
                                           l_currency_code,
                                           l_receipt_date);

                             /*************************************************
                              *  if all fields are populated, we need to
                              *  check to make sure that they are logically
                              *  correct.
                              ************************************************/
                              calc_amt_applied_fmt(l_invoice_currency_code8,
                                               l_amount_applied_from8,
                                               l_trans_to_receipt_rate8,
                                               l_temp_amt_applied,
					       'N');

                              calc_amt_applied_from_fmt(l_currency_code,
                                                    l_amount_applied8,
                                                    l_trans_to_receipt_rate8,
                                                    l_temp_amt_applied_from,
						    'N');

                              ar_cc_lockbox.calc_cross_rate(
                                                  l_amount_applied8,
                                                  l_amount_applied_from8,
                                                  l_invoice_currency_code8,
                                                  l_currency_code,
                                                  l_temp_trans_to_receipt_rate);
                              IF ( (l_temp_amt_applied = l_amount_applied8) OR
                                   (l_temp_amt_applied_from =
                                           l_amount_applied_from8)   OR
                                   (l_temp_trans_to_receipt_rate =
                                           l_trans_to_receipt_rate8)) THEN

                                /********************************************
                                 * since one or more of the conditions are
                                 * true then we assume that everything is
                                 * fine and we can write the rate to the
                                 * database
                                 *********************************************/
                                   debug1('validation passed ' );
                                   UPDATE ar_payments_interface
                                     SET trans_to_receipt_rate8 =
                                             l_trans_to_receipt_rate8
                                     WHERE rowid = l_rowid;
                                ELSE
                                  UPDATE AR_PAYMENTS_INTERFACE
                                    SET invoice8_status =
                                             'AR_PLB_CC_INVALID_VALUE'
                                   WHERE rowid = l_rowid;
                               END IF;

                          ELSE
                             /* calculate the least rate that would convert
                                the items */
                             ar_cc_lockbox.calc_cross_rate(
                                l_amount_applied8,
                                l_amount_applied_from8,
                                l_invoice_currency_code8,
                                l_currency_code,
                                l_trans_to_receipt_rate8);

                             /* once the rate has been calculated, we need
                                to write it to the table */
                             UPDATE ar_payments_interface
                                SET trans_to_receipt_rate8 =
                                   l_trans_to_receipt_rate8
                              WHERE rowid = l_rowid;
                          END IF;

                     ELSE
                       /* need to derive the rate if possible*/
                       debug1( 'need to derive rate ');
                       IF (p_default_exchange_rate_type IS NOT NULL or
                             l_is_fixed_rate = 'Y' ) THEN
                          l_trans_to_receipt_rate8 :=
                              gl_currency_api.get_rate_sql(
                                                l_invoice_currency_code8,
                                                l_currency_code,
                                                l_receipt_date,
                                                p_default_exchange_rate_type);
                     debug1('calculated rate = ' || to_char(l_trans_to_receipt_rate8));
                        /* if there is no rate in GL, there is nothing
                           more we can do */
                           IF (l_trans_to_receipt_rate8 < 0 )  THEN

                            UPDATE AR_PAYMENTS_INTERFACE
                               SET invoice8_status = 'AR_PLB_NO_EXCHANGE_RATE'
                                WHERE rowid = l_rowid;

                           ELSE
                             /* once the rate has been calculated, we need
                                to write it to the table */

                             debug1('writing rate to database ' || to_char(l_trans_to_receipt_rate8));

                             UPDATE ar_payments_interface
                                SET trans_to_receipt_rate8 =
                                   l_trans_to_receipt_rate8
                              WHERE rowid = l_rowid;

                             /* finish the calculation because we have a rate*/

                             IF (l_amount_applied_from8 IS NULL) THEN
                                calc_amt_applied_from_fmt(l_currency_code,
                                                      l_amount_applied8,
                                                      l_trans_to_receipt_rate8,
                                                      l_amount_applied_from8,
						      l_format_amount_applied_from8);
                                update ar_payments_interface
                                   set  amount_applied_from8 =
                                           l_amount_applied_from8
                                   where rowid = l_rowid;

                             ELSE
                              /* calculate amount applied and save to db */
                              calc_amt_applied_fmt(l_invoice_currency_code8,
                                               l_amount_applied_from8,
                                               l_trans_to_receipt_rate8,
                                               l_amount_applied8,
					       l_format_amount8);
                              debug1('calculated amt applied = ' || to_char(l_amount_applied8));

                              /* to deal with rounding errors that happen
                                 with fixed rate currencies, we need to
                                 take the amount_due_remaining of the trx
                                 convert it to the receipt currency and
                                 compare that value with the
                                 amount_applied_from original value

                                 ADDED for BUG 883345  */

                              IF (l_is_fixed_rate = 'Y') THEN

                                 calc_amt_applied_from_fmt(l_currency_code,
                                                       trx_amt_due_rem8,
                                                       l_trans_to_receipt_rate8,
                                                       amt_applied_from_tc,
						       'N');

                                 IF (amt_applied_from_tc =
                                      l_amount_applied_from8 ) THEN
				   IF (l_format_amount8 = 'Y') THEN
                                     fnd_currency.Get_Info(
                                              l_invoice_currency_code8,
                                              l_precision,
                                              l_extended_precision,
                                              l_mau);

                                     l_amount_applied8 :=
                                           trx_amt_due_rem8 * (10**l_precision);
				   ELSE
                                     l_amount_applied8 := trx_amt_due_rem8 ;
				   END IF;
                                 END IF;
                              END IF;

                               update ar_payments_interface
                                   set  amount_applied8 =
                                           l_amount_applied8
                                   where rowid = l_rowid;

                             END IF;   /* if amount_applied_From8 is null */
                           END IF;  /* if rate is null after it is calc */
                       ELSE       /* Bug 1519765 */
                            UPDATE AR_PAYMENTS_INTERFACE
                               SET invoice8_status = 'AR_PLB_NO_EXCHANGE_RATE'
                                WHERE rowid = l_rowid;
                       END IF;     /* if derive profile is not null */
                     END IF;

                  /*  we know that trans_to_receipt_rate8 is not null,
                      therefore, one of the amount values must be null and
                      we have to calculate it */
                  ELSE
                      /* is amount_applied_From null?? */
                      IF (l_amount_applied_from8 IS NULL) THEN
                         calc_amt_applied_from_fmt(l_currency_code,
                                               l_amount_applied8,
                                               l_trans_to_receipt_rate8,
                                               l_amount_applied_from8,
					       l_format_amount_applied_from8);
                          update ar_payments_interface
                            set  amount_applied_from8 =
                                      l_amount_applied_from8
                            where rowid = l_rowid;

                      ELSE
                         calc_amt_applied_fmt(l_invoice_currency_code8,
                                          l_amount_applied_from8,
                                          l_trans_to_receipt_rate8,
                                          l_amount_applied8,
					  l_format_amount8);

                       /* to deal with rounding errors that happen
                          with fixed rate currencies, we need to
                          take the amount_due_remaining of the trx
                          convert it to the receipt currency and
                          compare that value with the
                          amount_applied_from original value

                          ADDED for BUG 883345  */

                          IF (l_is_fixed_rate = 'Y') THEN

                               calc_amt_applied_from_fmt(l_currency_code,
                                                     trx_amt_due_rem8,
                                                     l_trans_to_receipt_rate8,
                                                     amt_applied_from_tc,
						     'N');

                               IF (amt_applied_from_tc =
                                    l_amount_applied_from8 ) THEN
				 IF (l_format_amount8 = 'Y') THEN
                                   fnd_currency.Get_Info(
                                            l_invoice_currency_code8,
                                            l_precision,
                                            l_extended_precision,
                                            l_mau);

                                   l_amount_applied8 :=
                                         trx_amt_due_rem8 * (10**l_precision);
				 ELSE
                                   l_amount_applied8 := trx_amt_due_rem8 ;
				 END IF;
                               END IF;
                            END IF;

                         UPDATE AR_PAYMENTS_INTERFACE
                              SET  amount_applied8 =
                                      l_amount_applied8
                              WHERE  rowid = l_rowid;

                      END IF;
                  END IF;   /* trans to receipt_rate 8 is null */
               ELSE
                  /*************************************************
                   *  if all fields are populated, we need to
                   *  check to make sure that they are logically
                   *  correct.
                   ***************************************************/

                   calc_amt_applied_fmt(l_invoice_currency_code8,
                                    l_amount_applied_from8,
                                    l_trans_to_receipt_rate8,
                                    l_temp_amt_applied,
				    'N');

                   calc_amt_applied_from_fmt(l_currency_code,
                                         l_amount_applied8,
                                         l_trans_to_receipt_rate8,
                                         l_temp_amt_applied_from,
					 'N');

                   ar_cc_lockbox.calc_cross_rate(
                                l_amount_applied8,
                                l_amount_applied_from8,
                                l_invoice_currency_code8,
                                l_currency_code,
                                l_temp_trans_to_receipt_rate);
                   IF ( (l_temp_amt_applied = l_amount_applied8) OR
                        (l_temp_amt_applied_from =
                                           l_amount_applied_from8)   OR
                        (l_temp_trans_to_receipt_rate =
                                           l_trans_to_receipt_rate8)) THEN

                       /* since one or more of the conditions are true
                          then we assume that everything is fine. */
                          debug1('validation passed ' );
                    ELSE
                         UPDATE AR_PAYMENTS_INTERFACE
                              SET invoice8_status = 'AR_PLB_CC_INVALID_VALUE'
                         WHERE rowid = l_rowid;
                    END IF;

               END IF;   /* if one of the 3 items is NULL */
            ELSE
                 /*****************************************************
                    currencies do not match, they are not fixed rate and
                    cross currency enabled profile is not on.
                    then set the status to be a currency conflict between
                    the invoice and receipt currencies
                   ***************************************************/
                 UPDATE AR_PAYMENTS_INTERFACE
                      SET invoice8_status = 'AR_PLB_CURR_CONFLICT'
                         WHERE rowid = l_rowid;
            END IF;
	  ELSE /* Bug 2066392.  Single currency */
	    IF l_amount_applied_from8 is not null THEN
	      IF l_amount_applied8 is not null THEN
		IF l_amount_applied_from8 <> l_amount_applied8 THEN
		  UPDATE AR_PAYMENTS_INTERFACE
		      SET invoice8_status = 'AR_PLB_CC_INVALID_VALUE'
		  WHERE rowid = l_rowid;
		END IF;
	      ELSE
		IF l_format_amount8 = 'Y' THEN
		  fnd_currency.Get_Info(l_invoice_currency_code8,
                                l_precision,
                                l_extended_precision,
                                l_mau);
		  l_unformat_amount := l_amount_applied_from8 * power(10, l_precision);
		ELSE
		  l_unformat_amount := l_amount_applied_from8;
		END IF;
		UPDATE AR_PAYMENTS_INTERFACE
		      SET  amount_applied8 = l_unformat_amount
		      WHERE  rowid = l_rowid;
	      END IF;
	    END IF;
          END IF;
      END IF;
   END IF;   /* if matching number 8 is not null */
<<END_8>>
  null;

END LOOP;
END populate_add_inv_details;



/*===========================================================================+
|  PROCEDURE
|     calc_amt_applied_from
|  DESCRIPTION
|      This procedure will calculate the amount_applied_from column given
|      a rate, an amount_applied, and a currency code
|
|  SCOPE - PUBLIC
|
|  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE
|
|  ARGUMENTS   :   IN:  trans_to_receipt_rate
|                       currency_code
|                       amount_applied (in currency of transaction).
|
|                  IN OUT NOCOPY :
|
|                  OUT NOCOPY :  amount_applied_from
|
|  RETURNS     :
|
|  NOTES
|  MODIFICATION HISTORY:
|  11/13/1998      Debbie Jancis   original
|  02/02/1999      Debbie Jancis   Modified to have the amount_applied_from
|                                  without the decimal point because the
|                                  values stored in the interface table have
|                                  implied decimal places.
+---------------------------------------------------------------------------*/

PROCEDURE calc_amt_applied_from(
  p_currency_code IN VARCHAR2,
  p_amount_applied IN ar_payments_interface.amount_applied1%type,
  p_trans_to_receipt_rate IN ar_payments_interface.trans_to_receipt_rate1%type,
  amount_applied_from OUT NOCOPY ar_payments_interface.amount_applied_from1%type
                               ) IS
--
l_mau                           NUMBER;
l_precision                     NUMBER(1);
l_extended_precision            NUMBER;
--

BEGIN
--
  debug1( 'calc_amt_applied_from() +' );
  debug1('p_amount_applied = ' || to_char(p_amount_applied));
  debug1('p_trans_to_receipt_rate = ' || to_char(p_trans_to_receipt_rate));
  debug1('p curr code = ' || p_currency_code);

     fnd_currency.Get_Info(
                             p_currency_code,
                             l_precision,
                             l_extended_precision,
                             l_mau);
     IF (l_mau IS NOT NULL) THEN
            amount_applied_from :=
                  ROUND((p_amount_applied *
                         p_trans_to_receipt_rate) /
                         l_mau) * l_mau;
     ELSE
            amount_applied_from :=
                  ROUND((p_amount_applied *
                         p_trans_to_receipt_rate),
                         l_precision);
     END IF;  /* l_mau is not null */

  /* after amount_applied_from is calculated, we need to remove
     the decimal place since the value stored in the interim
     table and then transfered to the interface tables is stored
     with an implied decimal */

  debug1('p_amount_applied_from = ' || to_char(amount_applied_from));
     amount_applied_from := amount_applied_from * 10 ** l_precision;
  debug1('p_amount_applied_from = ' || to_char(amount_applied_from));
  debug1( 'calc_amt_applied_from() -' );

END calc_amt_applied_from;

/*===========================================================================+
|  PROCEDURE
|     calc_amt_applied
|  DESCRIPTION
|      This procedure will calculate the amount_applied column given
|      a rate, an amount_applied_from, and a currency code
|
|  SCOPE - PUBLIC
|
|  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE
|
|  ARGUMENTS   :   IN:  trans_to_receipt_rate
|                       invoice_currency_code
|                       amount_applied_from (in currency of receipt).
|
|                  IN OUT NOCOPY :
|
|                  OUT NOCOPY :  amount_applied
|
|  RETURNS     :
|
|  NOTES
|  MODIFICATION HISTORY:
|  11/13/1998      Debbie Jancis   original
|  02/02/1999      Debbie Jancis   Modified to have the amount_applied
|                                  without the decimal point because the
|                                  values stored in the interface table have
|                                  implied decimal places.
+---------------------------------------------------------------------------*/

PROCEDURE calc_amt_applied(
  p_invoice_currency_code IN VARCHAR2,
  p_amount_applied_from IN ar_payments_interface.amount_applied_from1%type,
  p_trans_to_receipt_rate IN ar_payments_interface.trans_to_receipt_rate1%type,
  amount_applied OUT NOCOPY ar_payments_interface.amount_applied1%type
                           ) IS

--
l_mau                           NUMBER;
l_precision                     NUMBER(1);
l_extended_precision            NUMBER;
--

BEGIN
  debug1( 'calc_amt_applied() +' );
  debug1('p_amount_applied_from = ' || to_char(p_amount_applied_from));
  debug1('p_trans_to_receipt_rate = ' || to_char(p_trans_to_receipt_rate));
  debug1('p inv curr code = ' || p_invoice_currency_code);

 fnd_currency.Get_Info(
                        p_invoice_currency_code,
                        l_precision,
                        l_extended_precision,
                        l_mau);
    IF (l_mau IS NOT NULL) THEN
          amount_applied :=
                 ROUND((p_amount_applied_from /
                        p_trans_to_receipt_rate) /
                        l_mau) * l_mau;
    ELSE
         amount_applied:=
                 ROUND((p_amount_applied_from /
                        p_trans_to_receipt_rate),
                        l_precision);
    END IF;  /* l_mau is not null */

   /* before we return to the calling routine, we need to remove the
      decimal place as values are stored in the interface tables with
       implied decimal places.  */

   amount_applied := amount_applied * 10 ** l_precision;
  debug1('p_amount_applied = ' || to_char(amount_applied));
  debug1( 'calc_amt_applied() -' );

END calc_amt_applied;


/*----------------------------------------------------------------------------
This procedure calls arp_util.debug for the string passed.
Till arp_util.debug is changed to provide an option to write to a
file, we can use this procedure to write to a file at the time of testing.
Un comment lines calling fnd_file package and that will write to a file.
Please change the directory name so that it does not raise any exception.
----------------------------------------------------------------------------*/
PROCEDURE debug1(str IN VARCHAR2) IS
-- myfile utl_file.file_type;
-- dir_name varchar2(100);
-- out_file_name varchar2(8);
-- log_file_name varchar2(8);
BEGIN
--
  -- Check for the directory name.
--   dir_name := '/sqlcom/log';
--   log_file_name := 'ar.log';
--   out_file_name := 'ar.out';
--   myfile := utl_file.fopen(dir_name, out_file_name, 'a');
--   utl_file.put(myfile, str);
--   utl_file.fclose(myfile);
--
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug(str);
  END IF;
END debug1;

/*************************************************************
    This procedure will populate all the temporary columns
    in the ar_payments_interface table with the original
    values in the table for the columns:
    amount_applied1-8, amount_applied_from1-8,
    invoice_currency_code1-8, and the trans_to_Receipt_rate1-8
    so that in the event of a problem with the validation
    stage, at a later point, the original values can be returned
    to the database so the user will be able to determine which
    values were included in the transmission and which columns
    were not.
*************************************************************/
PROCEDURE pop_temp_columns IS
BEGIN
   update ar_payments_interface pi
   set tmp_amt_applied_from1 = pi.amount_applied_from1,
       tmp_amt_applied_from2 = pi.amount_applied_from2,
       tmp_amt_applied_from3 = pi.amount_applied_from3,
       tmp_amt_applied_from4 = pi.amount_applied_from4,
       tmp_amt_applied_from5 = pi.amount_applied_from5,
       tmp_amt_applied_from6 = pi.amount_applied_from6,
       tmp_amt_applied_from7 = pi.amount_applied_from7,
       tmp_amt_applied_from8 = pi.amount_applied_from8,
       tmp_amt_applied1 = pi.amount_applied1,
       tmp_amt_applied2 = pi.amount_applied2,
       tmp_amt_applied3 = pi.amount_applied3,
       tmp_amt_applied4 = pi.amount_applied4,
       tmp_amt_applied5 = pi.amount_applied5,
       tmp_amt_applied6 = pi.amount_applied6,
       tmp_amt_applied7 = pi.amount_applied7,
       tmp_amt_applied8 = pi.amount_applied8,
       tmp_inv_currency_code1 = pi.invoice_currency_code1,
       tmp_inv_currency_code2 = pi.invoice_currency_code2,
       tmp_inv_currency_code3 = pi.invoice_currency_code3,
       tmp_inv_currency_code4 = pi.invoice_currency_code4,
       tmp_inv_currency_code5 = pi.invoice_currency_code5,
       tmp_inv_currency_code6 = pi.invoice_currency_code6,
       tmp_inv_currency_code7 = pi.invoice_currency_code7,
       tmp_inv_currency_code8 = pi.invoice_currency_code8,
       tmp_trans_to_rcpt_rate1 = pi.trans_to_receipt_rate1,
       tmp_trans_to_rcpt_rate2 = pi.trans_to_receipt_rate2,
       tmp_trans_to_rcpt_rate3 = pi.trans_to_receipt_rate3,
       tmp_trans_to_rcpt_rate4 = pi.trans_to_receipt_rate4,
       tmp_trans_to_rcpt_rate5 = pi.trans_to_receipt_rate5,
       tmp_trans_to_rcpt_rate6 = pi.trans_to_receipt_rate6,
       tmp_trans_to_rcpt_rate7 = pi.trans_to_receipt_rate7,
       tmp_trans_to_rcpt_rate8 = pi.trans_to_receipt_rate8;
END pop_temp_columns;

PROCEDURE restore_orig_values IS

BEGIN
   update ar_payments_interface
   set amount_applied_from1 = tmp_amt_applied_from1,
       amount_applied_from2 = tmp_amt_applied_from2,
       amount_applied_from3 = tmp_amt_applied_from3,
       amount_applied_from4 = tmp_amt_applied_from4,
       amount_applied_from5 = tmp_amt_applied_from5,
       amount_applied_from6 = tmp_amt_applied_from6,
       amount_applied_from7 = tmp_amt_applied_from7,
       amount_applied_from8 = tmp_amt_applied_from8,
       amount_applied1 = tmp_amt_applied1,
       amount_applied2 = tmp_amt_applied2,
       amount_applied3 = tmp_amt_applied3,
       amount_applied4 = tmp_amt_applied4,
       amount_applied5 = tmp_amt_applied5,
       amount_applied6 = tmp_amt_applied6,
       amount_applied7 = tmp_amt_applied7,
       amount_applied8 = tmp_amt_applied8,
       invoice_currency_code1 = tmp_inv_currency_code1,
       invoice_currency_code2 = tmp_inv_currency_code2,
       invoice_currency_code3 = tmp_inv_currency_code3,
       invoice_currency_code4 = tmp_inv_currency_code4,
       invoice_currency_code5 = tmp_inv_currency_code5,
       invoice_currency_code6 = tmp_inv_currency_code6,
       invoice_currency_code7 = tmp_inv_currency_code7,
       invoice_currency_code8 = tmp_inv_currency_code8,
       trans_to_receipt_rate1 = tmp_trans_to_rcpt_rate1,
       trans_to_receipt_rate2 = tmp_trans_to_rcpt_rate2,
       trans_to_receipt_rate3 = tmp_trans_to_rcpt_rate3,
       trans_to_receipt_rate4 = tmp_trans_to_rcpt_rate4,
       trans_to_receipt_rate5 = tmp_trans_to_rcpt_rate5,
       trans_to_receipt_rate6 = tmp_trans_to_rcpt_rate6,
       trans_to_receipt_rate7 = tmp_trans_to_rcpt_rate7,
       trans_to_receipt_rate8 = tmp_trans_to_rcpt_rate8
where status <> 'AR_PLB_TRANSFERRED';

END restore_orig_values;


PROCEDURE are_values_valid (
   p_invoice_currency_code IN VARCHAR2,
   p_amount_applied_from IN ar_payments_interface.amount_applied_from1%type,
   p_trans_to_receipt_rate IN ar_payments_interface.trans_to_receipt_rate1%type,
   p_amount_applied IN ar_payments_interface.amount_applied1%type,
   p_currency_code IN VARCHAR2,
   valid OUT NOCOPY VARCHAR2 ) IS

/* temporary variables used to check if amount_applied, amount_applied_from
   and trans_to_receipt rates are given */
l_temp_amt_applied        ar_payments_interface.amount_applied1%type;
l_temp_amt_applied_from   ar_payments_interface.amount_applied_from1%type;
l_temp_trans_to_receipt_rate ar_payments_interface.trans_to_receipt_rate1%type;

BEGIN
/*************************************************
 *  if all fields are populated, we need to
 *  check to make sure that they are logically
 *  correct.
 ************************************************/

 calc_amt_applied(p_invoice_currency_code,
                  p_amount_applied_from,
                  p_trans_to_receipt_rate,
                  l_temp_amt_applied);

 calc_amt_applied_from(p_currency_code,
                       p_amount_applied,
                       p_trans_to_receipt_rate,
                       l_temp_amt_applied_from);

 ar_cc_lockbox.calc_cross_rate(
                           p_amount_applied,
                           p_amount_applied_from,
                           p_invoice_currency_code,
                           p_currency_code,
                           l_temp_trans_to_receipt_rate);

 IF ( (l_temp_amt_applied = p_amount_applied) OR
      (l_temp_amt_applied_from = p_amount_applied_from)   OR
      (l_temp_trans_to_receipt_rate = p_trans_to_receipt_rate)) THEN
      VALID := 'Y';
 ELSE
      VALID := 'N';
 END IF;

END are_values_valid;

/*===========================================================================+
|  PROCEDURE
|     calc_amt_applied_from_fmt
|  DESCRIPTION
|      This procedure will calculate the amount_applied_from column given
|      a rate, an amount_applied, and a currency code
|      For USD 100.00, return 10000 if format_amount is 'Y', otherwise
|      return 100.
|
|  SCOPE - PRIVATE
|
|  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE
|
|  ARGUMENTS   :   IN:  trans_to_receipt_rate
|                       currency_code
|                       amount_applied (in currency of transaction).
|                       format_amount (Y/N)
|
|                  IN OUT NOCOPY :
|
|                  OUT NOCOPY :  amount_applied_from
|
|  RETURNS     :
|
|  NOTES
|  MODIFICATION HISTORY:
|  11/15/2002      Shin Matsuda    Created
+---------------------------------------------------------------------------*/

PROCEDURE calc_amt_applied_from_fmt(
  p_currency_code IN VARCHAR2,
  p_amount_applied IN ar_payments_interface.amount_applied1%type,
  p_trans_to_receipt_rate IN ar_payments_interface.trans_to_receipt_rate1%type,
  amount_applied_from OUT NOCOPY ar_payments_interface.amount_applied_from1%type,
  p_format_amount IN VARCHAR2
                               ) IS
--
l_mau                           NUMBER;
l_precision                     NUMBER(1);
l_extended_precision            NUMBER;
--

BEGIN
--
  debug1( 'calc_amt_applied_from_fmt() +' );
  debug1('p_amount_applied = ' || to_char(p_amount_applied));
  debug1('p_trans_to_receipt_rate = ' || to_char(p_trans_to_receipt_rate));
  debug1('p curr code = ' || p_currency_code);

     fnd_currency.Get_Info(
                             p_currency_code,
                             l_precision,
                             l_extended_precision,
                             l_mau);
     IF (l_mau IS NOT NULL) THEN
            amount_applied_from :=
                  ROUND((p_amount_applied *
                         p_trans_to_receipt_rate) /
                         l_mau) * l_mau;
     ELSE
            amount_applied_from :=
                  ROUND((p_amount_applied *
                         p_trans_to_receipt_rate),
                         l_precision);
     END IF;  /* l_mau is not null */

  /* after amount_applied_from is calculated, we need to remove
     the decimal place since the value stored in the interim
     table and then transfered to the interface tables is stored
     with an implied decimal */

  debug1('p_amount_applied_from = ' || to_char(amount_applied_from));
    IF p_format_amount = 'Y' THEN
     amount_applied_from := amount_applied_from * 10 ** l_precision;
    END IF;
  debug1('p_amount_applied_from = ' || to_char(amount_applied_from));
  debug1( 'calc_amt_applied_from_fmt() -' );

END calc_amt_applied_from_fmt;

/*===========================================================================+
|  PROCEDURE
|     calc_amt_applied_fmt
|  DESCRIPTION
|      This procedure will calculate the amount_applied column given
|      a rate, an amount_applied_from, and a currency code
|      For USD 100.00, return 10000 if format_amount is 'Y', otherwise
|      return 100.
|
|  SCOPE - PRIVATE
|
|  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE
|
|  ARGUMENTS   :   IN:  trans_to_receipt_rate
|                       invoice_currency_code
|                       amount_applied_from (in currency of receipt).
|                       format_amount (Y/N)
|
|                  IN OUT NOCOPY :
|
|                  OUT NOCOPY :  amount_applied
|
|  RETURNS     :
|
|  NOTES
|  MODIFICATION HISTORY:
|  11/15/2002      Shin Matsuda    Created
+---------------------------------------------------------------------------*/

PROCEDURE calc_amt_applied_fmt(
  p_invoice_currency_code IN VARCHAR2,
  p_amount_applied_from IN ar_payments_interface.amount_applied_from1%type,
  p_trans_to_receipt_rate IN ar_payments_interface.trans_to_receipt_rate1%type,
  amount_applied OUT NOCOPY ar_payments_interface.amount_applied1%type,
  p_format_amount IN VARCHAR2
                           ) IS

--
l_mau                           NUMBER;
l_precision                     NUMBER(1);
l_extended_precision            NUMBER;
--

BEGIN
  debug1( 'calc_amt_applied_fmt() +' );
  debug1('p_amount_applied_from = ' || to_char(p_amount_applied_from));
  debug1('p_trans_to_receipt_rate = ' || to_char(p_trans_to_receipt_rate));
  debug1('p inv curr code = ' || p_invoice_currency_code);

 fnd_currency.Get_Info(
                        p_invoice_currency_code,
                        l_precision,
                        l_extended_precision,
                        l_mau);
    IF (l_mau IS NOT NULL) THEN
          amount_applied :=
                 ROUND((p_amount_applied_from /
                        p_trans_to_receipt_rate) /
                        l_mau) * l_mau;
    ELSE
         amount_applied:=
                 ROUND((p_amount_applied_from /
                        p_trans_to_receipt_rate),
                        l_precision);
    END IF;  /* l_mau is not null */

   /* before we return to the calling routine, we need to remove the
      decimal place as values are stored in the interface tables with
       implied decimal places.  */

  IF p_format_amount = 'Y' THEN
   amount_applied := amount_applied * 10 ** l_precision;
  END IF;
  debug1('p_amount_applied = ' || to_char(amount_applied));
  debug1( 'calc_amt_applied_fmt() -' );

END calc_amt_applied_fmt;

END ar_cc_lockbox;



/
