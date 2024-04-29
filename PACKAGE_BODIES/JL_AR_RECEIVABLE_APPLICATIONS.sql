--------------------------------------------------------
--  DDL for Package Body JL_AR_RECEIVABLE_APPLICATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_AR_RECEIVABLE_APPLICATIONS" AS
/* $Header: jlbrrrab.pls 120.19 2006/12/15 22:51:47 appradha ship $ */

/*----------------------------------------------------------------------------*
 |   PRIVATE FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE adjustment_generation (
                                x_user_id IN NUMBER,
                                x_rectrx_id IN NUMBER,
	                            x_acc_id IN NUMBER,
                            	x_amount IN NUMBER,
	                            x_receipt_date IN DATE,
	                            x_payment_schedule_id IN NUMBER,
	                            x_cash_receipt_id IN NUMBER,
	                            x_customer_trx_id IN NUMBER
                                )
  IS

  adj_rec             ar_adjustments%ROWTYPE;
  x_approved_amount   VARCHAR2(1);
  x_adjustment_id     ar_adjustments.adjustment_id%TYPE;
  x_adjustment_number ar_adjustments.adjustment_number%TYPE;
  x_msg_count         NUMBER :=0;
  x_msg_data          VARCHAR2(2000);
  x_return_status     VARCHAR2(1);
  x_data              VARCHAR2(4000);
  x_msgindex_out      NUMBER;
  x_trans_date        Date;
  x_rcpt_out          Date;
  x_def_rule       varchar2(100);
  x_err_msg        varchar2(1000);
  l_result            boolean;


  BEGIN

  /* Check if the adjustment amount is within the limit from the user */
      fnd_file.put_line(fnd_file.log,'adjgen1');
    fnd_file.put_line(fnd_file.log,' adjustment generation');

    BEGIN
      SELECT 'Y'
      INTO x_approved_amount
      FROM ar_approval_user_limits araul,
        gl_sets_of_books glsb,
        ar_system_parameters arsp
      WHERE araul.user_id = x_user_id
      AND   araul.document_type = 'ADJ'
      AND   glsb.set_of_books_id = arsp.set_of_books_id
      AND   araul.currency_code = glsb.currency_code
      AND   araul.amount_to >= x_amount
      AND   araul.amount_from <= x_amount;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      x_approved_amount:= 'N';
    END;

   SELECT trx_date
   INTO x_trans_date
   FROM ra_customer_trx
   WHERE customer_trx_id = x_customer_trx_id;

 l_result := ARP_STANDARD.validate_and_default_gl_date(x_receipt_date,x_trans_date,null,null,null,null,null,null,null,null,null,null,x_rcpt_out,x_def_rule,x_err_msg);

      fnd_file.put_line(fnd_file.log,'After validate and def');
   SELECT x_user_id,
          sysdate,
          x_user_id,
          x_user_id,
          sysdate,
          x_amount,
          sysdate,
          x_rcpt_out,
          arsp.set_of_books_id,
          x_acc_id,
          'CHARGES',
          decode(x_approved_amount,'Y','A','M'),
          decode(x_approved_amount,'Y','A','W'),
          x_cash_receipt_id,
          x_customer_trx_id,
          x_payment_schedule_id,
          x_rectrx_id,
          'ARXCAERA',
          decode(x_approved_amount,'Y','Y','N'),
          decode(x_approved_amount,'Y',x_user_id,NULL),
          -3,
          x_amount,
          org_id
   INTO   adj_rec.LAST_UPDATED_BY,
          adj_rec.LAST_UPDATE_DATE,
          adj_rec.LAST_UPDATE_LOGIN,
          adj_rec.CREATED_BY,
          adj_rec.CREATION_DATE,
          adj_rec.AMOUNT,
          adj_rec.APPLY_DATE,
          adj_rec.GL_DATE,
          adj_rec.SET_OF_BOOKS_ID,
          adj_rec.CODE_COMBINATION_ID,
          adj_rec.TYPE,
          adj_rec.ADJUSTMENT_TYPE,
          adj_rec.STATUS,
          adj_rec.ASSOCIATED_CASH_RECEIPT_ID,
          adj_rec.CUSTOMER_TRX_ID,
          adj_rec.PAYMENT_SCHEDULE_ID,
          adj_rec.RECEIVABLES_TRX_ID,
          adj_rec.CREATED_FROM,
          adj_rec.POSTABLE,
          adj_rec.APPROVED_BY,
          adj_rec.POSTING_CONTROL_ID,
          adj_rec.ACCTD_AMOUNT,
          adj_rec.ORG_ID
    FROM ar_system_parameters arsp;
      fnd_file.put_line(fnd_file.log,'After ar_system_params');

    arp_util.enable_debug;

      fnd_file.put_line(fnd_file.log,'Before create_adjustment');
    ar_adjust_pub.create_adjustment( p_api_name => 'AR_ADJUST_PUB',
                                     p_api_version => 1.0,
                                     p_msg_count => x_msg_count,
                                     p_msg_data  => x_msg_data,
                                     p_return_status => x_return_status,
                                     p_adj_rec => adj_rec,
                                     p_new_adjust_number => x_adjustment_number,
                                     p_new_adjust_id => x_adjustment_id);
      fnd_file.put_line(fnd_file.log,'After create_adjustment');

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug ('adjustment_generation: ' || 'return status: ' || x_return_status);
       arp_util.debug ('adjustment_generation: ' || 'msg_count	: ' || x_msg_count);
       arp_util.debug ('adjustment_generation: ' || 'msg_data	: ' || x_msg_data);
    END IF;


    IF  (x_return_status <> 'S') THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('adjustment_generation: ' || '>>>>>>>>>> Problems during Adjustment Creation');
         arp_util.debug('adjustment_generation: ' || 'x_return_status : ' || x_return_status);
         arp_util.debug('adjustment_generation: ' || 'x_msg_count     : ' || x_msg_count);
         arp_util.debug('adjustment_generation: ' || 'x_msg_data      : ' || x_msg_data);
      END IF;

      IF (x_msg_count > 0) THEN
        FND_MSG_PUB.Get(FND_MSG_PUB.G_FIRST,FND_API.G_TRUE,x_data,x_msgindex_out);
        FND_MESSAGE.Set_Encoded(x_data);
        app_exception.raise_exception;
      ELSE
        app_exception.raise_exception;
      END IF;

    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug ('adjustment_generation: ' || 'Adjustment ID created : ' ||  x_adjustment_id);
       arp_util.debug ('adjustment_generation: ' || 'Adjustment Number created : ' ||  x_adjustment_number);
    END IF;

  END adjustment_generation;

  PROCEDURE get_accounts (x_rcpt_method_id IN NUMBER,
                          x_bank_acct_id IN NUMBER,
                          x_writeoff_tolerance IN OUT NOCOPY NUMBER,
                          x_writeoff_amount IN OUT NOCOPY NUMBER,
                          x_writeoff_ccid IN OUT NOCOPY NUMBER,
                          x_writeoff_rectrx_id IN OUT NOCOPY NUMBER,
                          x_calc_interest_ccid IN OUT NOCOPY NUMBER,
                          x_calc_interest_rectrx_id IN OUT NOCOPY NUMBER,
                          x_int_revenue_ccid IN OUT NOCOPY NUMBER,
                          x_int_revenue_rectrx_id IN OUT NOCOPY NUMBER,
                          x_return IN OUT NOCOPY NUMBER) IS
  BEGIN

    x_return := 0;
    SELECT writeoff_perc_tolerance,
      writeoff_amount_tolerance,
      interest_writeoff_rectrx_id,
      interest_writeoff_ccid,
      interest_revenue_rectrx_id,
      interest_revenue_ccid,
      calculated_interest_ccid,
      calculated_interest_rectrx_id
    INTO x_writeoff_tolerance,
      x_writeoff_amount,
      x_writeoff_rectrx_id,
      x_writeoff_ccid,
      x_int_revenue_rectrx_id,
      x_int_revenue_ccid,
      x_calc_interest_ccid,
      x_calc_interest_rectrx_id
    FROM jl_br_ar_rec_met_accts_ext
    WHERE receipt_method_id = x_rcpt_method_id
    AND   bank_acct_use_id = x_bank_acct_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN x_return := -1;
  END get_accounts;

  PROCEDURE get_ps_parameters(x_payment_schedule_id IN NUMBER,
                              x_amount_due_original IN OUT NOCOPY NUMBER,
                              x_amount_due_remaining IN OUT NOCOPY NUMBER,
                              x_return IN OUT NOCOPY NUMBER) IS
  BEGIN
    x_return := 0;
    SELECT amount_due_original, amount_due_remaining
    INTO x_amount_due_original, x_amount_due_remaining
    FROM ar_payment_schedules
    WHERE payment_schedule_id = x_payment_schedule_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN x_return := -1;
  END get_ps_parameters;

  PROCEDURE calc_greaterthan_rec( x_writeoff_tolerance IN NUMBER,
                                  x_writeoff_amount IN NUMBER,
                                  x_calculated_interest IN NUMBER,
                                  x_received_interest IN NUMBER,
                                  x_payment_amount IN NUMBER,
                                  x_rcpt_date IN DATE,
                                  x_invoice_amount IN NUMBER,
                                  x_payment_schedule_id IN NUMBER,
                                  x_writeoff_ccid IN NUMBER,
                                  x_writeoff_rectrx_id IN NUMBER,
                                  x_calc_interest_ccid IN NUMBER,
                                  x_calc_interest_rectrx_id IN NUMBER,
                                  x_cash_receipt_id IN NUMBER,
                                  x_trx_type_idm IN NUMBER,
                                  x_batch_source_idm IN NUMBER,
                                  x_receipt_method_idm IN NUMBER,
                                  x_user_id IN NUMBER,
                                  x_customer_trx_id IN NUMBER,
                                  x_interest_difference_action IN VARCHAR2,
                                  x_writeoff_date OUT NOCOPY VARCHAR2,
                                  x_int_revenue_ccid IN NUMBER) IS

    x_status VARCHAR2(1);
    x_return VARCHAR2(1);

    x_rcpt_date_char VARCHAR2(30);
    x_rcpt_date_mm             date;
    x_rcpt_date_mm_char        varchar2(11);
    l_error_code               NUMBER;
    l_error_msg                VARCHAR2(2000);
    l_error_token              VARCHAR2(100);

  BEGIN

    if NVL(x_interest_difference_action,'$') = 'WRITEOFF' then
      IF (( x_writeoff_tolerance IS NOT NULL ) AND
          (((x_calculated_interest  - x_received_interest )/
          x_invoice_amount) <= x_writeoff_tolerance ))
      OR
        (( x_writeoff_amount IS NOT NULL ) AND
         ((x_calculated_interest  - x_received_interest ) <=
        x_writeoff_amount ))
      THEN
    fnd_file.put_line(fnd_file.log,'Before adjustment generation(1)');
        adjustment_generation (
          fnd_global.user_id,
          x_calc_interest_rectrx_id,
          x_calc_interest_ccid,
          x_calculated_interest,
          x_rcpt_date,
          x_payment_schedule_id,
          x_cash_receipt_id,
          x_customer_trx_id
          );

    fnd_file.put_line(fnd_file.log,'Before adjustment generation(2)');
        adjustment_generation (
          fnd_global.user_id,
          x_writeoff_rectrx_id,
          x_writeoff_ccid,
          x_received_interest  - x_calculated_interest,
          x_rcpt_date,
          x_payment_schedule_id,
          x_cash_receipt_id,
          x_customer_trx_id
          );
      ELSE
    fnd_file.put_line(fnd_file.log,'Before adjustment generation(3)');
        adjustment_generation (
          fnd_global.user_id,
          x_calc_interest_rectrx_id,
          x_calc_interest_ccid,
          x_received_interest,
          x_rcpt_date,
          x_payment_schedule_id,
          x_cash_receipt_id,
          x_customer_trx_id
          );
    fnd_file.put_line(fnd_file.log,'Before adjustment generation(4)');
        adjustment_generation (
          fnd_global.user_id,
          x_calc_interest_rectrx_id,
          x_calc_interest_ccid,
          x_calculated_interest - x_received_interest,
          x_rcpt_date,
          x_payment_schedule_id,
          x_cash_receipt_id,
          x_customer_trx_id
         );
    fnd_file.put_line(fnd_file.log,'Before adjustment generation(5)');
        adjustment_generation (
          fnd_global.user_id,
          x_writeoff_rectrx_id,
          x_writeoff_ccid,
          x_received_interest  - x_calculated_interest,
          x_rcpt_date,
          x_payment_schedule_id,
          x_cash_receipt_id,
          x_customer_trx_id
          );
      END IF;
      x_writeoff_date := fnd_date.date_to_canonical(x_rcpt_date);

    elsif NVL(x_interest_difference_action,'$') = 'GENERATE_IDM' then
    fnd_file.put_line(fnd_file.log,'Before generate idm');
      adjustment_generation (
          fnd_global.user_id,
          x_calc_interest_rectrx_id,
          x_calc_interest_ccid,
          x_received_interest,
          x_rcpt_date,
          x_payment_schedule_id,
          x_cash_receipt_id,
          x_customer_trx_id
          );

      x_rcpt_date_char := to_char(x_rcpt_date,'DD-MON-YYYY');


        /* Date format for Stored Procedures */
      x_rcpt_date_mm             := to_date(x_rcpt_date_char,'DD-MM-YYYY');
      x_rcpt_date_mm_char        := to_char(x_rcpt_date_mm,'DD-MM-YYYY');

    fnd_file.put_line(fnd_file.log,'Before jlbrinterestdebitmemo');

      jl_br_ar_generate_debit_memo.jl_br_interest_debit_memo (x_customer_trx_id,
        x_calculated_interest  - x_received_interest ,
        x_user_id,
        x_trx_type_idm,
        x_batch_source_idm,
        x_receipt_method_idm,
        x_payment_schedule_id ,
        x_rcpt_date_mm_char,
        x_return,
        x_int_revenue_ccid,
        l_error_code,
        l_error_msg,
        l_error_token);
          fnd_file.put_line(fnd_file.log,'After jlbrinterestdebitmemo'||x_return);
      IF  x_return = '1' THEN
          fnd_file.put_line(fnd_file.log,'After jlbrinterestdebitmemo');
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('calc_greaterthan_rec: ' || 'PROBLEMA NA CRIACAO DA NOTA DE DEBITO DE JUROS !!!');
        END IF;
      END IF;

    end if;
  END calc_greaterthan_rec;


  PROCEDURE calc_greaterthan_rec_tol( x_writeoff_tolerance IN NUMBER,
                                      x_writeoff_amount IN NUMBER,
                                      x_calculated_interest IN NUMBER,
                                      x_received_interest IN NUMBER,
                                      x_payment_amount IN NUMBER,
                                      x_rcpt_date IN DATE,
                                      x_invoice_amount IN NUMBER,
                                      x_payment_schedule_id IN NUMBER,
                                      x_writeoff_ccid IN NUMBER,
                                      x_writeoff_rectrx_id IN NUMBER,
                                      x_calc_interest_ccid IN NUMBER,
                                      x_calc_interest_rectrx_id IN NUMBER,
                                      x_cash_receipt_id IN NUMBER,
                                      x_trx_type_idm IN NUMBER,
                                      x_batch_source_idm IN NUMBER,
                                      x_receipt_method_idm IN NUMBER,
                                      x_user_id IN NUMBER,
                                      x_customer_trx_id IN NUMBER,
                                      x_writeoff_date OUT NOCOPY VARCHAR2,
                                      x_int_revenue_ccid IN NUMBER) IS
  x_return	NUMBER;
l_error_code  NUMBER;
  l_error_msg   VARCHAR2(2000);
  l_error_token VARCHAR2(100);
  BEGIN
    fnd_file.put_line(fnd_file.log,'Before calc greaterthan rec tol');
    IF (( x_writeoff_tolerance IS NOT NULL ) AND
        (((x_calculated_interest  - x_received_interest )/
        x_invoice_amount) <= x_writeoff_tolerance ))
    OR
      (( x_writeoff_amount IS NOT NULL ) AND
       ((x_calculated_interest  - x_received_interest ) <=
      x_writeoff_amount ))
    THEN
    fnd_file.put_line(fnd_file.log,'Before adjustment generation 6');
      adjustment_generation (
      fnd_global.user_id,
      x_calc_interest_rectrx_id,
      x_calc_interest_ccid,
      x_calculated_interest,
      x_rcpt_date,
      x_payment_schedule_id,
      x_cash_receipt_id,
      x_customer_trx_id);

    fnd_file.put_line(fnd_file.log,'Before adjustment generation 7');
      fnd_file.put_line(fnd_file.log,'After 1st adjustment');
      adjustment_generation (
      fnd_global.user_id,
      x_writeoff_rectrx_id,
      x_writeoff_ccid,
      x_received_interest  - x_calculated_interest,
      x_rcpt_date,
      x_payment_schedule_id,
      x_cash_receipt_id,
      x_customer_trx_id);
      fnd_file.put_line(fnd_file.log,'After 2nd adjustment');

      x_writeoff_date := fnd_date.date_to_canonical(x_rcpt_date);

      fnd_file.put_line(fnd_file.log,'After 3rd adjustment');

    ELSE
      IF nvl(x_received_interest,0) > 0 THEN
    fnd_file.put_line(fnd_file.log,'Before adjustment generation 8');
        adjustment_generation (
        fnd_global.user_id,
        x_calc_interest_rectrx_id,
        x_calc_interest_ccid,
        x_received_interest,
        x_rcpt_date,
        x_payment_schedule_id,
        x_cash_receipt_id,
        x_customer_trx_id);
      END IF;

    fnd_file.put_line(fnd_file.log,'Before debit  memogeneration 8');
      jl_br_ar_generate_debit_memo.jl_br_interest_debit_memo (
        x_customer_trx_id,
        x_calculated_interest  - x_received_interest ,
        x_user_id,
        x_trx_type_idm,
        x_batch_source_idm,
        x_receipt_method_idm,
        x_payment_schedule_id ,
        to_char(x_rcpt_date,'DD-MM-YYYY'),
        x_return,
        x_int_revenue_ccid,
         l_error_code,
        l_error_msg,
        l_error_token
       );

      IF  x_return = '1' THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('calc_greaterthan_rec: ' || 'PROBLEMA NA CRIACAO DA NOTA DE DEBITO DE JUROS !!!');
        END IF;
      END IF;
    END IF;
  END calc_greaterthan_rec_tol;

  PROCEDURE calc_lessthan_rec( x_writeoff_tolerance IN NUMBER,
                               x_writeoff_amount IN NUMBER,
                               x_calculated_interest IN NUMBER,
                               x_received_interest IN NUMBER,
                               x_payment_amount IN NUMBER,
                               x_rcpt_date IN DATE,
                               x_payment_schedule_id IN NUMBER,
                               x_int_revenue_ccid IN NUMBER,
                               x_int_revenue_rectrx_id IN NUMBER,
                               x_calc_interest_ccid IN NUMBER,
                               x_calc_interest_rectrx_id IN NUMBER,
                               x_cash_receipt_id IN NUMBER,
                               x_user_id IN NUMBER,
                               x_customer_trx_id IN NUMBER) IS
  BEGIN
    IF NVL(x_calculated_interest ,0) > 0 THEN
    fnd_file.put_line(fnd_file.log,'Before adjustment generation 9');
      adjustment_generation (
        fnd_global.user_id,
        x_calc_interest_rectrx_id,
        x_calc_interest_ccid,
        x_calculated_interest ,
        x_rcpt_date,
        x_payment_schedule_id,
        x_cash_receipt_id,
        x_customer_trx_id );
    END IF;
    fnd_file.put_line(fnd_file.log,'Before adjustment generation 10');
    adjustment_generation (
      fnd_global.user_id,
      x_int_revenue_rectrx_id,
      x_int_revenue_ccid,
      x_received_interest - x_calculated_interest ,
      x_rcpt_date,
      x_payment_schedule_id,
      x_cash_receipt_id,
      x_customer_trx_id );
  END calc_lessthan_rec;

  PROCEDURE calc_equal_rec( x_writeoff_tolerance IN NUMBER,
                            x_writeoff_amount IN NUMBER,
                            x_calculated_interest IN NUMBER,
                            x_received_interest IN NUMBER,
                            x_payment_amount IN NUMBER,
                            x_rcpt_date IN DATE,
                            x_payment_schedule_id IN NUMBER,
                            x_int_revenue_ccid IN NUMBER,
                            x_int_revenue_rectrx_id IN NUMBER,
                            x_calc_interest_ccid IN NUMBER,
                            x_calc_interest_rectrx_id IN NUMBER,
                            x_cash_receipt_id IN NUMBER,
                            x_user_id IN NUMBER,
                            x_customer_trx_id IN NUMBER) IS
  BEGIN
    fnd_file.put_line(fnd_file.log,'Before adjustment generation 11');
    adjustment_generation (
      fnd_global.user_id,
      x_calc_interest_rectrx_id,
      x_calc_interest_ccid,
      x_calculated_interest ,
      x_rcpt_date,
      x_payment_schedule_id,
      x_cash_receipt_id,
      x_customer_trx_id );
  END calc_equal_rec;

  PROCEDURE interest_treatment (
        x_payment_schedule_id IN NUMBER,
	x_customer_trx_id IN NUMBER,
	x_payment_amount  IN NUMBER,
	x_due_date IN DATE,
	x_calc_interest IN VARCHAR2,
	x_rec_interest IN VARCHAR2,
        x_main_amount_received IN VARCHAR2,
        x_base_interest_calc IN VARCHAR2,
        x_interest_payment_date IN VARCHAR2,
        x_interest_diff_action VARCHAR2,
        x_cash_receipt_id IN NUMBER,
	x_rcpt_date IN DATE,
	x_rcpt_method_id IN NUMBER,
        x_trx_type_idm IN NUMBER,
        x_batch_source_idm IN NUMBER,
        x_receipt_method_idm IN NUMBER,
	x_user_id IN NUMBER,
	x_remit_bank_acct_id IN NUMBER,
        x_writeoff_date OUT NOCOPY VARCHAR2
       )
IS
  x_writeoff_tolerance NUMBER;
  x_writeoff_amount NUMBER;
  x_writeoff_ccid NUMBER(15);
  x_writeoff_rectrx_id NUMBER(15);
  x_calc_interest_ccid NUMBER(15);
  x_calc_interest_rectrx_id NUMBER(15);
  x_int_revenue_ccid NUMBER(15);
  x_int_revenue_rectrx_id NUMBER(15);
  x_return NUMBER;
  x_amount_due_original NUMBER;
  x_amount_due_remaining NUMBER;
  x_calculated_interest NUMBER;
  x_received_interest NUMBER;
  BEGIN

    x_calculated_interest := fnd_number.canonical_to_number(x_calc_interest);
    x_received_interest := fnd_number.canonical_to_number(x_rec_interest);

      fnd_file.put_line(fnd_file.log,'Inside Int treatment');
      fnd_file.put_line(fnd_file.log,'calc int'||to_char(x_calculated_interest));
    fnd_file.put_line(fnd_file.log,'rec int'||to_char(x_received_interest));

    fnd_file.put_line(fnd_file.log,'Before get_accounts()');
    get_accounts(x_rcpt_method_id,
      x_remit_bank_acct_id,
      x_writeoff_tolerance,
      x_writeoff_amount,
      x_writeoff_ccid,
      x_writeoff_rectrx_id,
      x_calc_interest_ccid,
      x_calc_interest_rectrx_id,
      x_int_revenue_ccid,
      x_int_revenue_rectrx_id,
        x_return);

    fnd_file.put_line(fnd_file.log,'After get_accounts');

    get_ps_parameters(x_payment_schedule_id,
      x_amount_due_original,
      x_amount_due_remaining,
      x_return);

    fnd_file.put_line(fnd_file.log,'After get_psparams');

    IF NVL(x_calculated_interest ,0) > NVL(x_received_interest ,0) THEN
      IF x_interest_diff_action is NOT NULL THEN
    fnd_file.put_line(fnd_file.log,'calc_greater_than_rec');
        calc_greaterthan_rec( x_writeoff_tolerance,
          x_writeoff_amount,
          x_calculated_interest,
          x_received_interest,
          x_payment_amount,
          x_rcpt_date,
          x_amount_due_original,
          x_payment_schedule_id,
          x_writeoff_ccid,
          x_writeoff_rectrx_id,
          x_calc_interest_ccid,
          x_calc_interest_rectrx_id,
          x_cash_receipt_id,
          x_trx_type_idm,
          x_batch_source_idm,
          x_receipt_method_idm,
          x_user_id,
          x_customer_trx_id,
          x_interest_diff_action,
          x_writeoff_date,
          x_int_revenue_ccid);
      ELSE
    fnd_file.put_line(fnd_file.log,'calc_greater_than_rec_tol');
        calc_greaterthan_rec_tol( x_writeoff_tolerance,
          x_writeoff_amount,
          x_calculated_interest,
          x_received_interest,
          x_payment_amount,
          x_rcpt_date,
          x_amount_due_original,
          x_payment_schedule_id,
          x_writeoff_ccid,
          x_writeoff_rectrx_id,
          x_calc_interest_ccid,
          x_calc_interest_rectrx_id,
          x_cash_receipt_id,
          x_trx_type_idm,
          x_batch_source_idm,
          x_receipt_method_idm,
          x_user_id,
          x_customer_trx_id,
          x_writeoff_date,
          x_int_revenue_ccid);
        END IF;

    ELSIF NVL(x_calculated_interest ,0) < NVL(x_received_interest ,0) THEN
    fnd_file.put_line(fnd_file.log,'calc_less_than_rec_tol');
      calc_lessthan_rec( x_writeoff_tolerance,
        x_writeoff_amount,
        x_calculated_interest,
        x_received_interest,
        x_payment_amount,
        x_rcpt_date,
        x_payment_schedule_id,
        x_int_revenue_ccid,
        x_int_revenue_rectrx_id,
        x_calc_interest_ccid,
        x_calc_interest_rectrx_id,
        x_cash_receipt_id,
        x_user_id,
        x_customer_trx_id);
    ELSIF x_received_interest  > 0 THEN
    fnd_file.put_line(fnd_file.log,'calc_equal_rec');
      calc_equal_rec( x_writeoff_tolerance,
        x_writeoff_amount,
        x_calculated_interest,
        x_received_interest,
        x_payment_amount,
        x_rcpt_date,
        x_payment_schedule_id,
        x_int_revenue_ccid,
        x_int_revenue_rectrx_id,
        x_calc_interest_ccid,
        x_calc_interest_rectrx_id,
        x_cash_receipt_id,
        x_user_id,
        x_customer_trx_id);
    END IF;
  END interest_treatment;

  PROCEDURE Apply_br(p_apply_before_after          IN     VARCHAR2 ,
                     p_global_attribute_category   IN     VARCHAR2 ,
                     p_set_of_books_id             IN     NUMBER   ,
                     p_cash_receipt_id             IN     VARCHAR2 ,
                     p_receipt_date                IN     DATE     ,
                     p_applied_payment_schedule_id IN     NUMBER   ,
                     p_amount_applied              IN     NUMBER   ,
                     p_unapplied_amount            IN     NUMBER   ,
                     p_due_date                    IN     DATE     ,
                     p_receipt_method_id           IN     NUMBER   ,
                     p_remittance_bank_account_id  IN     NUMBER   ,
                     p_global_attribute1           IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute2           IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute3           IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute4           IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute5           IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute6           IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute7           IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute8           IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute9           IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute10          IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute11          IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute12          IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute13          IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute14          IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute15          IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute16          IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute17          IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute18          IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute19          IN OUT NOCOPY VARCHAR2 ,
                     p_global_attribute20          IN OUT NOCOPY VARCHAR2 ,
                     p_return_status               OUT NOCOPY    VARCHAR2) IS

  validation_error   exception;

  x_amount_due_remaining     NUMBER;
  x_customer_trx_id          NUMBER;
  x_interest_type            VARCHAR2(30);
  x_interest_rate_amount     NUMBER(38,2);
  x_interest_period          NUMBER;
  x_interest_formula         VARCHAR2(30);
  x_interest_grace_days      NUMBER;
  x_penalty_type             VARCHAR2(30);
  x_penalty_rate_amount      NUMBER(38,2);
  x_invoice_amount           NUMBER(38,2);
  x_calculated_interest      NUMBER(38,2);
  x_calculated_interest_out  NUMBER(38,2);
  x_city                     VARCHAR2(80);
  x_state                    VARCHAR2(60);
  x_calendar                 VARCHAR2(30);
  x_payment_action           VARCHAR2(30);
  x_days_late                NUMBER;
  x_payment_date             DATE;
  x_trans_date               DATE;
  x_trx_type_idm             NUMBER;
  x_batch_source_idm         NUMBER;
  x_receipt_method_idm       NUMBER;
  x_exit_status              NUMBER;
  x_org_id                   ar_payment_schedules.org_id%TYPE;
  errcode                    NUMBER;
  l_ps_rec                   ar_payment_schedules%ROWTYPE;

  BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('jl_ar_receivable_applications.Apply_br()+');
    END IF;

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_apply_before_after = 'BEFORE' THEN

      IF p_due_date < p_receipt_date THEN


        x_calendar := jl_zz_sys_options_pkg.get_calendar(mo_global.get_current_org_id);

        /* Bug 2374054 : Multiorg changes */
        BEGIN
          SELECT org_id
          INTO   x_org_id
          FROM   ar_payment_schedules
          WHERE  payment_schedule_id = p_applied_payment_schedule_id;
        EXCEPTION
          WHEN OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_util.debug('Apply_br: ' || to_char(SQLCODE));
            END IF;
        END;
        -- fnd_profile.get('JLBR_PAYMENT_ACTION',x_payment_action);
        x_payment_action := jl_zz_sys_options_pkg.get_payment_action_AR(x_org_id);

        IF x_calendar IS Null THEN
          FND_MESSAGE.SET_NAME('JL','JL_BR_CALENDAR_PROFILE');
          FND_MSG_PUB.Add;
          RAISE validation_error;
        END IF;
        IF x_payment_action IS Null THEN
          FND_MESSAGE.SET_NAME('JL','JL_BR_PAYMENT_ACTION_PROFILE');
          FND_MSG_PUB.Add;
          RAISE validation_error;
        END IF;

        JL_ZZ_AR_LIBRARY_1_PKG.get_idm_profiles_from_syspa (
                                           x_trx_type_idm,
                                           x_batch_source_idm,
                                           x_receipt_method_idm,
                                           1,
                                           errcode);

        IF errcode <> 0 THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Apply_br: ' || to_char(SQLCODE));
          END IF;
          RAISE validation_error;
        END IF;

        IF x_trx_type_idm IS Null THEN
          FND_MESSAGE.SET_NAME('JL','JL_BR_AR_TRX_TYPE_PROFILE');
          FND_MSG_PUB.Add;
          RAISE validation_error;
        END IF;

        IF x_batch_source_idm IS Null THEN
          FND_MESSAGE.SET_NAME('JL','JL_BR_AR_BATCH_SOURCE_PROFILE');
          FND_MSG_PUB.Add;
          RAISE validation_error;
        END IF;

        IF x_receipt_method_idm IS Null THEN
          FND_MESSAGE.SET_NAME('JL','JL_BR_AR_REC_METHOD_PROFILE');
          FND_MSG_PUB.Add;
          RAISE validation_error;
        END IF;

        IF p_global_attribute1 < 0 THEN
            FND_MESSAGE.SET_NAME('JL','JL_BR_INVALID_MAIN_AMOUNT');
            FND_MSG_PUB.Add;
            RAISE validation_error;
        END IF;

        IF p_global_attribute4 < 0 THEN
          FND_MESSAGE.SET_NAME('JL','JL_BR_INVALID_INT_AMOUNT');
          FND_MSG_PUB.Add;
          RAISE validation_error;
        END IF;

        IF p_global_attribute1 is NULL THEN
          p_global_attribute1 := p_amount_applied - nvl(p_global_attribute4,0);
        END IF;

        IF p_global_attribute2 is NULL THEN
          p_global_attribute2 := 'TOTAL';
        END IF;

        IF p_global_attribute1 + nvl(p_global_attribute4,0) > p_amount_applied
        THEN
          FND_MESSAGE.SET_NAME('JL','JL_BR_INVALID_MAIN_RCVD_SUM');
          FND_MSG_PUB.Add;
          RAISE validation_error;
        END IF;

        BEGIN

         SELECT amount_due_remaining,
                global_attribute7
         INTO   x_amount_due_remaining,
                p_global_attribute11
         FROM   ar_payment_schedules
         WHERE  payment_schedule_id = p_applied_payment_schedule_id;

        EXCEPTION
          WHEN OTHERS THEN
            RAISE validation_error;
        END;

        x_payment_date := fnd_date.canonical_to_date(p_global_attribute11);

        JL_ZZ_AR_LIBRARY_1_PKG.get_customer_trx_id(
                               p_applied_payment_schedule_id,
                               x_customer_trx_id,
                               x_trans_date,
                               1,
                               errcode);
        IF errcode <> 0 THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Apply_br: ' || to_char(SQLCODE));
          END IF;
          RAISE validation_error;
        END IF;

        JL_ZZ_AR_LIBRARY_1_PKG.get_customer_interest_dtls (
                                                        x_customer_trx_id,
                                                        x_interest_type,
                                                        x_interest_rate_amount,
                                                        x_interest_period,
                                                        x_interest_formula,
                                                        x_interest_grace_days,
                                                        x_penalty_type,
                                                        x_penalty_rate_amount,
                                                        1,
                                                        errcode);
        IF errcode <> 0 THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Apply_br: ' || to_char(SQLCODE));
          END IF;
          RAISE validation_error;
        END IF;

        JL_ZZ_AR_LIBRARY_1_PKG.get_city_from_ra_addresses (
                                         p_applied_payment_schedule_id,
                                         x_city,
                                         1,
                                         errcode,
                                         x_state);  --Bug # 2319552
        IF errcode <> 0 THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('Apply_br: ' || to_char(SQLCODE));
          END IF;
          RAISE validation_error;
        END IF;

        IF p_global_attribute2 = 'TOTAL' THEN
          x_invoice_amount := x_amount_due_remaining;
        ELSIF p_global_attribute2 = 'PARTIAL' THEN
          x_invoice_amount := p_global_attribute1;
        END IF;

        JL_BR_INTEREST_HANDLING.JL_BR_INTEREST(
                         x_interest_type,
                         x_interest_rate_amount,
                         x_interest_period,
                         x_interest_formula,
                         x_interest_grace_days,
                         x_penalty_type,
                         x_penalty_rate_amount,
                         p_due_date,
                         x_payment_date,
                         x_invoice_amount,
                         x_calendar,
                         x_city,
                         x_payment_action,
                         x_calculated_interest,
                         x_days_late,
                         x_exit_status,
                         x_state);   --Bug # 2319552

       IF x_exit_status = 0 THEN
         x_calculated_interest_out := NVL(x_calculated_interest,0);
       ELSE
         FND_MESSAGE.SET_NAME('JL','JL_BR_INCONSISTENT_DATE');
         FND_MSG_PUB.Add;
         RAISE validation_error;
       END IF;

        p_global_attribute3 := x_calculated_interest_out;

        IF (p_global_attribute2 = 'TOTAL')
        AND (x_calculated_interest_out <> 0) THEN
          p_global_attribute7 := p_receipt_date;
        ELSE
          p_global_attribute7 := '';
        END IF;

        interest_treatment (
                  p_applied_payment_schedule_id,
	          x_customer_trx_id,
	          p_amount_applied,
	          p_due_date,
	          fnd_number.canonical_to_number(p_global_attribute3),
	          fnd_number.canonical_to_number(p_global_attribute4),
	          fnd_number.canonical_to_number(p_global_attribute1),
                  p_global_attribute2,
                  fnd_date.canonical_to_date(p_global_attribute7),
                  p_global_attribute5,
                  p_cash_receipt_id,
	          p_receipt_date,
	          p_receipt_method_id,
                  x_trx_type_idm,
                  x_batch_source_idm,
                  x_receipt_method_idm,
	          fnd_global.user_id,
	          p_remittance_bank_account_id,
                  p_global_attribute8);

      ELSE

        p_global_attribute1  := '';
        p_global_attribute2  := '';
        p_global_attribute3  := '';
        p_global_attribute4  := '';
        p_global_attribute5  := '';
        p_global_attribute6  := '';
        p_global_attribute7  := '';
        p_global_attribute8  := '';
        p_global_attribute9  := '';
        p_global_attribute10 := '';
        p_global_attribute11 := '';

      END IF;

    ELSIF p_apply_before_after = 'AFTER' THEN

/*      UPDATE ar_payment_schedules
      SET  global_attribute1   = p_global_attribute1,
           global_attribute2   = p_global_attribute2,
           global_attribute3   = p_global_attribute3,
           global_attribute4   = p_global_attribute4,
           global_attribute5   = p_global_attribute5,
           global_attribute6   = p_global_attribute6,
           global_attribute7   = nvl(p_global_attribute7,p_global_attribute11),
           global_attribute15  = p_global_attribute8
      WHERE  payment_schedule_id = p_applied_payment_schedule_id;
*/

/* Replace Update by AR's table handlers. Bug # 2249731 */

       arp_ps_pkg.fetch_p(p_applied_payment_schedule_id, l_ps_rec);
       arp_ps_pkg.lock_p(p_applied_payment_schedule_id);
       l_ps_rec.global_attribute1  := p_global_attribute1;
       l_ps_rec.global_attribute2  := p_global_attribute2;
       l_ps_rec.global_attribute3  := p_global_attribute3;
       l_ps_rec.global_attribute4  := p_global_attribute4;
       l_ps_rec.global_attribute5  := p_global_attribute5;
       l_ps_rec.global_attribute6  := p_global_attribute6;
       l_ps_rec.global_attribute7  := nvl(p_global_attribute7, p_global_attribute11);
       l_ps_rec.global_attribute15 := p_global_attribute8;
       arp_ps_pkg.update_p(l_ps_rec, p_applied_payment_schedule_id);

    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('jl_ar_receivable_applications.Apply_br()-');
    END IF;

  EXCEPTION
    WHEN validation_error THEN
      p_return_status := FND_API.G_RET_STS_ERROR;

  END Apply_br;
  PROCEDURE Unapply_br(
                       p_cash_receipt_id             IN     VARCHAR2 ,
                       p_applied_payment_schedule_id IN     NUMBER   ,
                       p_return_status               OUT NOCOPY    VARCHAR2) IS

  x_apply_date           DATE;
  x_main_amnt_rec        VARCHAR2(30);
  x_base_int_calc        VARCHAR2(30);
  x_calculated_interest  VARCHAR2(30);
  x_received_interest    VARCHAR2(30);
  x_int_diff_action      VARCHAR2(30);
  x_int_writeoff_reason  VARCHAR2(30);
  x_payment_date         VARCHAR2(30);
  x_writeoff_date        VARCHAR2(80);
  x_error_code           NUMBER;
  l_ps_rec               ar_payment_schedules%ROWTYPE;

  BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('jl_ar_receivable_applications.Unapply_br()+');
    END IF;

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
      SELECT apply_date
      INTO   x_apply_date
      FROM   ar_receivable_applications
      WHERE  cash_receipt_id = p_cash_receipt_id
      AND    applied_payment_schedule_id = p_applied_payment_schedule_id;
    EXCEPTION
      WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Unapply_br: ' || to_char(SQLCODE));
        END IF;
        p_return_status := FND_API.G_RET_STS_ERROR;
    END;

    IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN

  jl_zz_ar_library_1_pkg.get_prev_interest_values(p_applied_payment_schedule_id,
                                                  p_cash_receipt_id,
                                                  x_apply_date,
                                                  x_main_amnt_rec,
                                                  x_base_int_calc,
                                                  x_calculated_interest,
                                                  x_received_interest,
                                                  x_int_diff_action,
                                                  x_int_writeoff_reason,
                                                  x_payment_date,
                                                  x_writeoff_date,
                                                  x_error_code);

      IF x_error_code = 0 then

/*        UPDATE ar_payment_schedules
        SET    global_attribute1  = x_main_amnt_rec,
               global_attribute2  = x_base_int_calc,
               global_attribute3  = x_calculated_interest,
               global_attribute4  = x_received_interest,
               global_attribute5  = x_int_diff_action,
               global_attribute6  = x_int_writeoff_reason,
               global_attribute7  = x_payment_date,
               global_attribute15 = x_writeoff_date
        WHERE  payment_schedule_id = p_applied_payment_schedule_id;
*/

/* Replace Update by AR's table handlers. Bug # 2249731 */

       arp_ps_pkg.fetch_p(p_applied_payment_schedule_id, l_ps_rec);
       arp_ps_pkg.lock_p(p_applied_payment_schedule_id);
       l_ps_rec.global_attribute1  := x_main_amnt_rec;
       l_ps_rec.global_attribute2  := x_base_int_calc;
       l_ps_rec.global_attribute3  := x_calculated_interest;
       l_ps_rec.global_attribute4  := x_received_interest;
       l_ps_rec.global_attribute5  := x_int_diff_action;
       l_ps_rec.global_attribute6  := x_int_writeoff_reason;
       l_ps_rec.global_attribute7  := x_payment_date;
       l_ps_rec.global_attribute15 := x_writeoff_date;
       arp_ps_pkg.update_p(l_ps_rec, p_applied_payment_schedule_id);

      ELSE
        p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('jl_ar_receivable_applications.Unapply_br()-');
    END IF;

  END Unapply_br;

  PROCEDURE Reverse_br(
                       p_cash_receipt_id             IN     NUMBER,
                       p_return_status               OUT NOCOPY    VARCHAR2) IS

  Cursor pay_sched is
  Select applied_payment_schedule_id pay_sched_id,
         global_attribute3 calculated_interest,
         apply_date
  from   ar_receivable_applications
  where  status = 'APP'
  and    cash_receipt_id = p_cash_receipt_id;

  ps_rec  pay_sched%ROWTYPE;

  x_main_amnt_rec        VARCHAR2(30);
  x_base_int_calc        VARCHAR2(30);
  x_calculated_interest  VARCHAR2(30);
  x_received_interest    VARCHAR2(30);
  x_int_diff_action      VARCHAR2(30);
  x_int_writeoff_reason  VARCHAR2(30);
  x_payment_date         VARCHAR2(30);
  x_writeoff_date        VARCHAR2(30);

  x_error_code           NUMBER;
  x_interest_reversal    BOOLEAN;
  l_ps_rec               ar_payment_schedules%ROWTYPE;

  BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('jl_ar_receivable_applications.Reverse_br()+');
    END IF;

    jl_zz_ar_library_1_pkg.get_interest_reversal_flag(p_cash_receipt_id,
                                                      x_interest_reversal,
                                                      x_error_code);

    IF x_error_code = 0 then

      IF x_interest_reversal THEN
        p_return_status := FND_API.G_RET_STS_SUCCESS;
        OPEN pay_sched;
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Reverse_br: ' || 'Cursor pay_sched +');
        END IF;
        LOOP

          FETCH pay_sched INTO ps_rec;
          EXIT when pay_sched%NOTFOUND
            or pay_sched%NOTFOUND is NULL;

          IF ps_rec.calculated_interest IS NOT NULL THEN

            jl_zz_ar_library_1_pkg.get_prev_interest_values(ps_rec.pay_sched_id,
                                                            p_cash_receipt_id,
                                                            ps_rec.apply_date,
                                                            x_main_amnt_rec,
                                                            x_base_int_calc,
                                                            x_calculated_interest,
                                                            x_received_interest,
                                                            x_int_diff_action,
                                                            x_int_writeoff_reason,
                                                            x_payment_date,
                                                            x_writeoff_date,
                                                            x_error_code);

            IF x_error_code = 0 then
/*              UPDATE ar_payment_schedules
              SET    global_attribute1  = x_main_amnt_rec,
                     global_attribute2  = x_base_int_calc,
                     global_attribute3  = x_calculated_interest,
                     global_attribute4  = x_received_interest,
                     global_attribute5  = x_int_diff_action,
                     global_attribute6  = x_int_writeoff_reason,
                     global_attribute7  = x_payment_date,
                     global_attribute15 = x_writeoff_date
              WHERE  payment_schedule_id = ps_rec.pay_sched_id;
*/

/* Replace Update by AR's table handlers. Bug # 2249731 */

       arp_ps_pkg.fetch_p(ps_rec.pay_sched_id, l_ps_rec);
       arp_ps_pkg.lock_p(ps_rec.pay_sched_id);
       l_ps_rec.global_attribute1  := x_main_amnt_rec;
       l_ps_rec.global_attribute2  := x_base_int_calc;
       l_ps_rec.global_attribute3  := x_calculated_interest;
       l_ps_rec.global_attribute4  := x_received_interest;
       l_ps_rec.global_attribute5  := x_int_diff_action;
       l_ps_rec.global_attribute6  := x_int_writeoff_reason;
       l_ps_rec.global_attribute7  := x_payment_date;
       l_ps_rec.global_attribute15 := x_writeoff_date;
       arp_ps_pkg.update_p(l_ps_rec, ps_rec.pay_sched_id);

            ELSE
              p_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

          END IF;

        END LOOP;
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('Reverse_br: ' || 'Cursor pay_sched -');
        END IF;
        CLOSE pay_sched;
      ELSE
        FND_MESSAGE.SET_NAME('JL','JL_BR_AR_STD_REV');
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    ELSE
      p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('jl_ar_receivable_applications.Reverse_br()-');
    END IF;

  END Reverse_br;

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

  PROCEDURE Apply(p_apply_before_after          IN     VARCHAR2 ,
                  p_global_attribute_category   IN     VARCHAR2 ,
                  p_set_of_books_id             IN     NUMBER   ,
                  p_cash_receipt_id             IN     VARCHAR2 ,
                  p_receipt_date                IN     DATE     ,
                  p_applied_payment_schedule_id IN     NUMBER   ,
                  p_amount_applied              IN     NUMBER   ,
                  p_unapplied_amount            IN     NUMBER   ,
                  p_due_date                    IN     DATE     ,
                  p_receipt_method_id           IN     NUMBER   ,
                  p_remittance_bank_account_id  IN     NUMBER   ,
                  p_global_attribute1           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute2           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute3           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute4           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute5           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute6           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute7           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute8           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute9           IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute10          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute11          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute12          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute13          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute14          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute15          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute16          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute17          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute18          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute19          IN OUT NOCOPY VARCHAR2 ,
                  p_global_attribute20          IN OUT NOCOPY VARCHAR2 ,
                  p_return_status               OUT NOCOPY    VARCHAR2) IS


    l_country_code   VARCHAR2(2);
    l_org_id         NUMBER;
    x_gac_valid      BOOLEAN;

  BEGIN


    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('jl_ar_receivable_applications.Apply()+');
    END IF;

    --l_country_code := FND_PROFILE.VALUE('JGZZ_COUNTRY_CODE');
    l_org_id := MO_GLOBAL.get_current_org_id;

    l_country_code := JG_ZZ_SHARED_PKG.get_country(l_org_id,null);

    IF l_country_code IS NULL THEN

      p_return_status := FND_API.G_RET_STS_ERROR;

    ELSIF  l_country_code = 'BR' THEN

      jg_zz_global_flex_vald_pkg.validate_global_attb_cat(
                                              p_global_attribute_category,
                                              'JL',
                                              'BR',
                                              'ARXRWMAI',
                                              x_gac_valid);

      IF x_gac_valid THEN

        Apply_br(p_apply_before_after,
                 p_global_attribute_category,
                 p_set_of_books_id,
                 p_cash_receipt_id,
                 p_receipt_date,
                 p_applied_payment_schedule_id,
                 p_amount_applied,
                 p_unapplied_amount,
                 p_due_date,
                 p_receipt_method_id,
                 p_remittance_bank_account_id,
                 p_global_attribute1,
                 p_global_attribute2,
                 p_global_attribute3,
                 p_global_attribute4,
                 p_global_attribute5,
                 p_global_attribute6,
                 p_global_attribute7,
                 p_global_attribute8,
                 p_global_attribute9,
                 p_global_attribute10,
                 p_global_attribute11,
                 p_global_attribute12,
                 p_global_attribute13,
                 p_global_attribute14,
                 p_global_attribute15,
                 p_global_attribute16,
                 p_global_attribute17,
                 p_global_attribute18,
                 p_global_attribute19,
                 p_global_attribute20,
                 p_return_status);

      ELSE

        FND_MESSAGE.SET_NAME('JG','JG_ZZ_INVALID_GLOBAL_ATTB_CAT');
        FND_MSG_PUB.Add;
        p_return_status := FND_API.G_RET_STS_ERROR;

      END IF;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('jl_ar_receivable_applications.Apply()-');
    END IF;


  END Apply;

  PROCEDURE Unapply(
                    p_cash_receipt_id             IN     VARCHAR2 ,
                    p_applied_payment_schedule_id IN     NUMBER   ,
                    p_return_status               OUT NOCOPY    VARCHAR2) IS

    l_country_code   VARCHAR2(2);
    l_org_id         NUMBER;

  BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('jl_ar_receivable_applications.Unapply()+');
    END IF;

    l_org_id := MO_GLOBAL.get_current_org_id;

    l_country_code := JG_ZZ_SHARED_PKG.get_country(l_org_id,null);

    --l_country_code := FND_PROFILE.VALUE('JGZZ_COUNTRY_CODE');

    IF l_country_code IS NULL THEN
      p_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSIF  l_country_code = 'BR' THEN
      Unapply_br(
                 p_cash_receipt_id,
                 p_applied_payment_schedule_id,
                 p_return_status);
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('jl_ar_receivable_applications.Unapply()-');
    END IF;


  END Unapply;

  PROCEDURE Reverse(
                    p_cash_receipt_id             IN     NUMBER,
                    p_return_status               OUT NOCOPY    VARCHAR2) IS

    l_country_code   VARCHAR2(2);
    l_org_id         NUMBER;

  BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('jl_ar_receivable_applications.Reverse()+');
    END IF;

    l_org_id := MO_GLOBAL.get_current_org_id;

    l_country_code := JG_ZZ_SHARED_PKG.get_country(l_org_id,null);
    --l_country_code := FND_PROFILE.VALUE('JGZZ_COUNTRY_CODE');

    IF l_country_code IS NULL THEN
      p_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSIF  l_country_code = 'BR' THEN
      Reverse_br(
                 p_cash_receipt_id,
                 p_return_status);
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('jl_ar_receivable_applications.Reverse()-');
    END IF;

  END Reverse;

   PROCEDURE create_interest_adjustment (
                     p_post_quickcash_req_id IN NUMBER,
                     x_return_status OUT NOCOPY VARCHAR2) IS
   l_country_code VARCHAR2(2);
   l_interest_instruction VARCHAR2(2);
   l_interest_occurrence VARCHAR2(2);
   l_city VARCHAR2(100);
   l_state VARCHAR2(15);
   l_calculated_interest NUMBER;
   l_interest_type VARCHAR2(15);
   l_interest_rate_amount NUMBER;
   l_penalty_type VARCHAR2(15);
   l_penalty_rate_amount NUMBER;
   l_period_days NUMBER;
   l_interest_formula VARCHAR2(100);
   l_grace_days NUMBER;
   l_due_date DATE;
   l_occurrence_date DATE;
   l_days_late NUMBER;
   x_exit_code VARCHAR2(2);
   l_inttrxid NUMBER;
   l_intccid NUMBER;
   l_trx_type_id NUMBER;
   l_batch_source_id NUMBER;
   l_int_writeoff_rectrx_id NUMBER;
   l_int_writeoff_ccid NUMBER;
   l_writeoff_tolerance  NUMBER;
   l_writeoff_amount  NUMBER;
   l_writeoff_date  VARCHAR2(30);
   l_trade_note_amount  NUMBER;
   l_abate_rev_rectrx_id NUMBER;
   l_int_rev_rectrx_id NUMBER;
   l_int_rev_ccid NUMBER;
   l_abate_rev_ccid NUMBER;
   l_cust_trx_id NUMBER;
   l_amount_due_remaining NUMBER;
   l_payment_amount NUMBER;
   l_trx_type_idm             NUMBER;
   l_batch_source_idm         NUMBER;
   l_receipt_method_idm       NUMBER;
   x_return varchar2(1);
   l_error_code NUMBER;
   l_error_msg  VARCHAR2(2000);
   l_error_token VARCHAR2(100);
   l_ps_rec ar_payment_schedules%ROWTYPE;
   l_payment_action VARCHAR2(100);
   l_calendar_name  VARCHAR2(100);
   l_pay_sch_id     NUMBER;
   l_cash_rec_id    NUMBER;
   l_count    NUMBER;

     Cursor c_int(p_request_id IN NUMBER) is
   select ara.receivable_application_id,
          acr.cash_receipt_id,
          ara.applied_payment_schedule_id,
          acr.receipt_method_id,
          acr.receipt_date,
          acr.remit_bank_acct_use_id,
          aicl.global_attribute1,
          aicl.global_attribute2,
          aicl.global_attribute3,
          aicl.global_attribute4,
          aicl.global_attribute5,
          aicl.global_attribute6,
          aicl.global_attribute7,
          aicl.global_attribute8,
          aicl.global_attribute10
   from ar_receivable_applications_all ara,
        ar_cash_receipts_all acr,
        ar_interim_cash_rcpt_lines_all aicl
        --ar_interim_cash_receipts_all aic
   where ara.request_id = p_request_id
   AND ara.cash_receipt_id = acr.cash_receipt_id
   AND ara.cash_receipt_id = aicl.cash_receipt_id
   AND ara.applied_payment_schedule_id = aicl.payment_schedule_id
   AND ara.global_attribute_category is NULL;

   cursor p(p_request_id IN NUMBER) is
    select ara.cash_receipt_id,
           ara.applied_payment_schedule_id
    from  ar_receivable_applications_all ara
    where request_id = p_request_id;


  BEGIN

    --IF PG_DEBUG in ('Y', 'C') THEN
       fnd_file.put_line(fnd_file.log,'Inside3 jl_ar_receivable_applications.Create_interest_adjustment()+');
    --END IF;

    fnd_file.put_line(fnd_file.log,'Rec Appl Id :'||to_char(p_post_quickcash_req_id));

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    For rint in c_int(p_post_quickcash_req_id)
    Loop

    fnd_file.put_line(fnd_file.log,'After opening the cursor()+');

      update ar_receivable_applications_all
      set    global_attribute1 = rint.global_attribute3 ,
             global_attribute2 = rint.global_attribute4 ,
             global_attribute3 = rint.global_attribute1 ,
             global_attribute4 = rint.global_attribute2 ,
             global_attribute7 = rint.global_attribute5 ,
             global_attribute9 = rint.global_attribute6 ,
             global_attribute10 = rint.global_attribute7,
             global_attribute11 = rint.global_attribute8,
             global_attribute12 = rint.global_attribute10,
             global_attribute_category = 'JL.BR.ARXRWMAI.Additional Info'
      where receivable_application_id = rint.receivable_application_id;

      fnd_file.put_line(fnd_file.log,'After update statement()+');

    /* ---------------------------------------------------------------------- */
    /*                 Interest Treatment                                     */
    /* ---------------------------------------------------------------------- */
      fnd_file.put_line(fnd_file.log,'Before get_idm_profiles');
      fnd_file.put_line(fnd_file.log,'User Id '||to_char(fnd_global.user_id));

        JL_ZZ_AR_LIBRARY_1_PKG.get_idm_profiles_from_syspa (
                                           l_trx_type_idm,
                                           l_batch_source_idm,
                                           l_receipt_method_idm,
                                           1,
                                           l_error_code);

       SELECT  ract.cust_trx_type_id,
               ract.batch_source_id,
               arps.due_date,
               nvl(arps.amount_due_remaining,0),
               ract.customer_trx_id,
               arps.amount_applied
        INTO
               l_trx_type_id,
               l_batch_source_id,
               l_due_date,
               l_amount_due_remaining,
               l_cust_trx_id,
               l_payment_amount
          FROM ra_customer_trx ract,
               ar_payment_schedules arps
         WHERE arps.payment_schedule_id = rint.applied_payment_schedule_id
           AND ract.customer_trx_id = arps.customer_trx_id;

       fnd_file.put_line(fnd_file.log,'calc int'||rint.global_attribute1);
       fnd_file.put_line(fnd_file.log,'rec int'||rint.global_attribute2);
       fnd_file.put_line(fnd_file.log,'main amt'||rint.global_attribute3);

        Interest_treatment (
                  rint.applied_payment_schedule_id,
	          l_cust_trx_id,
	          l_payment_amount,
	          l_due_date,
	          nvl(rint.global_attribute1,0),
	          nvl(rint.global_attribute2,0),
	          nvl(rint.global_attribute3,0),
                  rint.global_attribute4,
                  rint.global_attribute5,
                  NULL,
                  rint.cash_receipt_id,
	          rint.receipt_date,
	          rint.receipt_method_id,
                  l_trx_type_idm,
                  l_batch_source_idm,
                  l_receipt_method_idm,
	          fnd_global.user_id,
	          rint.remit_bank_acct_use_id,
                  l_writeoff_date);

       fnd_file.put_line(fnd_file.log,'After interest_treatment');

      End Loop;

      --IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('jl_ar_receivable_applications.Create_interest_adjustments()-');
      --END IF;

  END Create_interest_adjustment;

  PROCEDURE delete_interest_adjustment (
                     p_cash_receipt_id IN NUMBER,
                     x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
    delete from ar_adjustments_all
    where associated_cash_receipt_id = p_cash_receipt_id;
  END delete_interest_adjustment;

END jl_ar_receivable_applications;

/
