--------------------------------------------------------
--  DDL for Package Body JL_ZZ_AR_LIBRARY_1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_AR_LIBRARY_1_PKG" AS
/* $Header: jlzzrl1b.pls 120.18.12010000.3 2009/02/09 09:48:40 nivnaray ship $ */

  -- Get customer_trx_id from ar_payment_schedules
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AR_ENABLE_DEBUG_OUTPUT'), 'N');

PROCEDURE get_customer_trx_id (pay_sched_id IN     NUMBER,
                               cust_trx_id  IN OUT NOCOPY NUMBER,
                               trans_date   IN OUT NOCOPY DATE,
                               row_number   IN     NUMBER,
                               Errcd        IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT arps.customer_trx_id,ract.trx_date
    INTO   cust_trx_id,trans_date
    FROM   ar_payment_schedules arps, ra_customer_trx ract
    WHERE  arps.payment_schedule_id = pay_sched_id
    AND    ract.customer_trx_id = arps.customer_trx_id
    AND    rownum = row_number;

  EXCEPTION
    WHEN OTHERS THEN
      Errcd := SQLCODE;
  END get_customer_trx_id;

  -- See if the amount is with in approval limits
  PROCEDURE get_amt_within_approval_limits (userid       IN     NUMBER,
                                            amt          IN     NUMBER,
                                            approved_amt IN OUT NOCOPY VARCHAR2,
                                            row_number   IN     NUMBER,
                                            Errcd IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT 'Y' approved_yes_no
    INTO   approved_amt
    FROM   ar_approval_user_limits araul,
           gl_sets_of_books glsb,
           ar_system_parameters arsp
    WHERE  araul.user_id = userid
    AND    araul.document_type = 'ADJ'
    AND    glsb.set_of_books_id =  arsp.set_of_books_id
    AND    araul.currency_code =  glsb.currency_code
    AND    araul.amount_to >= NVL(amt,0)
    AND    araul.amount_from <= NVL(amt,0)
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_amt_within_approval_limits;


  -- Select amounts from jl_br_ar_rec_met_accts_ext table
  PROCEDURE get_bank_account_amounts (rcpt_mthd          IN NUMBER,
                                      bnk_acct           IN NUMBER,
                                      perc_tol           IN OUT NOCOPY NUMBER,
                                      amt_tol            IN OUT NOCOPY NUMBER,
                                      writeoff_rectrx    IN OUT NOCOPY NUMBER,
                                      writeoff_ccid      IN OUT NOCOPY NUMBER,
                                      rev_rectrx         IN OUT NOCOPY NUMBER,
                                      rev_ccid           IN OUT NOCOPY NUMBER,
					        calc_intr_ccid     IN OUT NOCOPY NUMBER,
                                      calc_intr_rectx_id IN OUT NOCOPY NUMBER,
                                      row_number         IN     NUMBER,
                                      Errcd              IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT writeoff_perc_tolerance,
           writeoff_amount_tolerance,
           interest_writeoff_rectrx_id,
           interest_writeoff_ccid,
           interest_revenue_rectrx_id,
           interest_revenue_ccid,
           calculated_interest_ccid,
           calculated_interest_rectrx_id
    INTO   perc_tol, amt_tol, writeoff_rectrx,
           writeoff_ccid, rev_rectrx, rev_ccid,
	     calc_intr_ccid, calc_intr_rectx_id
    FROM  jl_br_ar_rec_met_accts_ext
    WHERE receipt_method_id =  rcpt_mthd
    AND   bank_acct_use_id = bnk_acct
    AND   rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_bank_account_amounts;


  PROCEDURE get_sum_adjustment_amounts (pay_sched_id    IN     NUMBER,
                                        amount_adjusted IN OUT NOCOPY NUMBER,
                                        row_number      IN     NUMBER,
                                        Errcd           IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT Sum(Amount)
    INTO   amount_adjusted
    FROM   ar_adjustments
    WHERE  payment_schedule_id = pay_sched_id;
  EXCEPTION
    WHEN OTHERS THEN
    Errcd := SQLCODE;
  END get_sum_adjustment_amounts;


  -- Get IDM profiles GA17/16/18 from ar_system_parameters
  PROCEDURE get_idm_profiles_from_syspa (trx_type       IN OUT NOCOPY VARCHAR2,
                                         batch_source   IN OUT NOCOPY VARCHAR2,
                                         receipt_method IN OUT NOCOPY VARCHAR2,
                                         row_number     IN     NUMBER,
                                         Errcd          IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT global_attribute17, global_attribute16, global_attribute18
    INTO   trx_type, batch_source, receipt_method
    FROM   ar_system_parameters
    WHERE  rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_idm_profiles_from_syspa;


  -- Get interest_payment_date from ar_payment_schedules
  PROCEDURE get_interest_payment_date (pay_schd_id           IN     NUMBER,
                                       interest_payment_date IN OUT NOCOPY VARCHAR2,
                                       row_number            IN     NUMBER,
                                       Errcd                 IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT MAX (global_attribute7)
    INTO   interest_payment_date
    FROM   ar_payment_schedules
    WHERE  payment_schedule_id = pay_schd_id;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_interest_payment_date;


  -- Get Global Attributes 1..7 from ra_customer_trx
  PROCEDURE get_customer_interest_dtls (cust_trx_id          IN     NUMBER,
                                        interest_type        IN OUT NOCOPY VARCHAR2,
                                        interest_rate_amount IN OUT NOCOPY NUMBER,
                                        interest_period      IN OUT NOCOPY NUMBER,
                                        interest_formula     IN OUT NOCOPY VARCHAR2,
                                        interest_grace_days  IN OUT NOCOPY NUMBER,
                                        penalty_type         IN OUT NOCOPY VARCHAR2,
                                        penalty_rate_amount  IN OUT NOCOPY NUMBER,
                                        row_number           IN     NUMBER,
                                        Errcd                IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    /* Bug 3465021 - Added fnd_number.canonical_to_number api to amount related GDFs */
    SELECT SUBSTR (global_attribute1, 1, 15),
           fnd_number.canonical_to_number(SUBSTR (global_attribute2, 1, 38)),
           fnd_number.canonical_to_number(SUBSTR (global_attribute3, 1, 15)),
           SUBSTR (global_attribute4, 1, 30),
           fnd_number.canonical_to_number(SUBSTR (global_attribute5, 1, 4)),
           SUBSTR (global_attribute6, 1, 15),
           fnd_number.canonical_to_number(SUBSTR (global_attribute7, 1, 38))
    INTO   interest_type,  interest_rate_amount, interest_period, interest_formula,
           interest_grace_days, penalty_type, penalty_rate_amount
    FROM   ra_customer_trx
    WHERE  customer_trx_id = cust_trx_id
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_customer_interest_dtls;


  PROCEDURE get_city_from_ra_addresses (pay_sched_id IN     NUMBER,
                                        city         IN OUT NOCOPY VARCHAR2,
                                        row_number   IN     NUMBER,
                                        Errcd        IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT loc.city
    INTO   city
    FROM   ar_payment_schedules arps,
           hz_cust_acct_sites ad,
           hz_cust_site_uses hzsu,
           ra_customer_trx ract,
        -- ra_site_uses rasu,
           hz_locations loc,
           hz_party_sites pty
    WHERE  arps.payment_schedule_id = pay_sched_id
    AND    ract.customer_trx_id     = arps.customer_trx_id
    AND    hzsu.site_use_id         = ract.bill_to_site_use_id
    AND    ad.cust_acct_site_id     = hzsu.cust_acct_site_id
    AND    ad.party_site_id         = pty.party_site_id
    AND    loc.location_id          = pty.location_id
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_city_from_ra_addresses;


  -- Get Record Count for the cash_receipt_id for LOOPing purposes
  PROCEDURE get_total_receipts (cash_rcpt_id IN     NUMBER,
                                tot_rec      IN OUT NOCOPY NUMBER,
                                row_number   IN     NUMBER,
                                Errcd        IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT COUNT (*)
    INTO   tot_rec
    FROM   ar_receivable_applications
    WHERE  cash_receipt_id = cash_rcpt_id;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_total_receipts;


  -- Get Status
  PROCEDURE get_status_amount_due (amt_due_remain_char IN     VARCHAR2,
                                   status              IN OUT NOCOPY VARCHAR2,
                                   row_number          IN     NUMBER,
                                   Errcd               IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT DECODE (amt_due_remain_char, '0', 'CL', 'OP')
    INTO   status
    FROM   dual
    WHERE  rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_status_amount_due;


  -- Get GL Date Closed
  PROCEDURE get_gl_date_closed (amt_due_remain_char IN     VARCHAR2,
                                gl_date             IN     VARCHAR2,
                                gl_date_closed      IN OUT NOCOPY VARCHAR2,
                                row_number          IN     NUMBER,
                                Errcd               IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT DECODE (amt_due_remain_char, '0', gl_date, NULL)
    INTO   gl_date_closed
    FROM   dual
    WHERE  rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_gl_date_closed;


  -- Get Actual date Closed
  PROCEDURE get_actual_date_closed (amt_due_remain_char IN     VARCHAR2,
                                    gl_date             IN     VARCHAR2,
                                    actual_date_closed  IN OUT NOCOPY VARCHAR2,
                                    row_number          IN     NUMBER,
                                    Errcd               IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT DECODE (amt_due_remain_char, '0', gl_date, NULL)
    INTO   actual_date_closed
    FROM   dual
    WHERE  rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_actual_date_closed;


  PROCEDURE get_count_of_receipt_methods (rcpt_class_id IN     NUMBER,
                                          total_rec     IN OUT NOCOPY NUMBER,
                                          row_number    IN     NUMBER,
                                          Errcd         IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT COUNT (ext.receipt_method_id)
    INTO   total_rec
    FROM   jl_br_ar_rec_met_accts_ext ext,
           ar_receipt_methods arm
    WHERE  arm.receipt_method_id = ext.receipt_method_id
    AND    arm.receipt_class_id  = rcpt_class_id;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_count_of_receipt_methods;


  PROCEDURE get_collection_method (rcpt_class_id     IN     NUMBER,
                                   collection_method IN OUT NOCOPY NUMBER,
                                   row_number        IN     NUMBER,
                                   Errcd             IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT global_attribute1
    INTO   collection_method
    FROM   ar_receipt_classes
    WHERE  receipt_class_id = rcpt_class_id
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_collection_method;


  PROCEDURE get_print_immediately_flag (print_immediately_flag IN OUT NOCOPY VARCHAR2,
                                        row_number             IN     NUMBER,
                                        Errcd                  IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT global_attribute12
    INTO   print_immediately_flag
    FROM   ar_system_parameters
    WHERE  rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_print_immediately_flag;


  PROCEDURE get_count_complete_flag (total_records IN OUT NOCOPY NUMBER,
                                     row_number    IN     NUMBER,
                                     Errcd         IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT COUNT (rct.complete_flag)
    INTO   total_records
    FROM   ra_customer_trx rct, ra_cust_trx_types rctt
    WHERE  rct.complete_flag = 'Y'
    AND    NVL (rct.printing_count,0) = 0
    AND    NVL (rct.status_trx, 'VD') <> 'VD'
    AND    rctt.cust_trx_type_id = rct.cust_trx_type_id
    AND    rctt.type = 'INV';
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_count_complete_flag;


  PROCEDURE get_cust_trx_type_status (p_cust_trx_type_id IN     NUMBER,
                                      class            IN OUT NOCOPY VARCHAR2,
                                      dfstatus         IN OUT NOCOPY VARCHAR2,
                                      row_number       IN     NUMBER,
                                      Errcd            IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT type, default_status
    INTO   class, dfstatus
    FROM   ra_cust_trx_types_all
    WHERE  cust_trx_type_id = p_cust_trx_type_id
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_cust_trx_type_status;

  -- Bug 3610797
  PROCEDURE get_inv_item_details ( fcc_code_type IN VARCHAR2,
                                  tran_nat_type IN     VARCHAR2,
                                  so_org_id     IN     VARCHAR2,
                                  inv_item_id   IN     NUMBER,
                                  fcc_code      IN OUT NOCOPY VARCHAR2,
                                  tran_nat      IN OUT NOCOPY VARCHAR2,
                                  item_org      IN OUT NOCOPY VARCHAR2,
                                  item_ft       IN OUT NOCOPY VARCHAR2,
                                  fed_trib      IN OUT NOCOPY VARCHAR2,
                                  sta_trib      IN OUT NOCOPY VARCHAR2,
                                  row_number    IN     NUMBER,
                                  Errcd         IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT fcc.meaning,
           tn.meaning,
           mtl.global_attribute3,
           mtl.global_attribute4,
           mtl.global_attribute5,
           mtl.global_attribute6
    INTO   fcc_code,
           tran_nat,
           item_org,
           item_ft,
           fed_trib,
           sta_trib
    FROM   mtl_system_items mtl,fnd_lookups fcc , fnd_lookups tn
    WHERE  fcc.lookup_code = SUBSTR(mtl.global_attribute1,1,25)
    AND    fcc.lookup_type = fcc_code_type
    AND    tn.lookup_code = substr(mtl.global_attribute2,1,25)
    AND    tn.lookup_type = tran_nat_type
    AND    mtl.organization_id = so_org_id
    AND    mtl.inventory_item_id = inv_item_id
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_inv_item_details;


  PROCEDURE get_memo_line_details (p_memo_line_id  IN   NUMBER,
                                   item_org      IN OUT NOCOPY VARCHAR2,
                                   item_ft       IN OUT NOCOPY VARCHAR2,
                                   fed_trib      IN OUT NOCOPY VARCHAR2,
                                   sta_trib      IN OUT NOCOPY VARCHAR2,
                                   row_number    IN     NUMBER,
                                   Errcd         IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT aml.global_attribute3,
           aml.global_attribute4,
           aml.global_attribute5,
           aml.global_attribute6
    INTO   item_org,
           item_ft,
           fed_trib,
           sta_trib
    FROM   ar_memo_lines aml
    WHERE  aml.memo_line_id = p_memo_line_id
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_memo_line_details;


  PROCEDURE get_next_seq_number (seq_name   IN     VARCHAR2,
                                 seq_no     IN OUT NOCOPY NUMBER,
                                 row_number IN     NUMBER,
                                 Errcd      IN OUT NOCOPY NUMBER) IS
  l_trx_num_cursor          INTEGER;
  l_count                   NUMBER;
  BEGIN
        Errcd := 0;
        l_trx_num_cursor := dbms_sql.open_cursor;
        dbms_sql.parse(l_trx_num_cursor,
                       'select '||
                       seq_name||'.nextval seq_number '||
                       'from dual ',
                       dbms_sql.NATIVE);

        dbms_sql.define_column(l_trx_num_cursor, 1, seq_no);

        l_count := dbms_sql.execute_and_fetch(l_trx_num_cursor,TRUE);

        dbms_sql.column_value(l_trx_num_cursor, 1, seq_no);
        dbms_sql.close_cursor(l_trx_num_cursor);

  END get_next_seq_number;



  PROCEDURE get_bearer_of_trade_note (pay_sched_id   IN     NUMBER,
                                      bearer_tr_note IN OUT NOCOPY VARCHAR2,
                                      row_number     IN     NUMBER,
                                      Errcd          IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT global_attribute2
    INTO   bearer_tr_note
    FROM   ar_payment_schedules
    WHERE  payment_schedule_id = pay_sched_id
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_bearer_of_trade_note;


  PROCEDURE get_customer_profile_dtls (bill_to_cust_id   IN     NUMBER,
                                       interest_type     IN OUT NOCOPY VARCHAR2,
                                       interest_rate_amt IN OUT NOCOPY VARCHAR2,
                                       interest_period   IN OUT NOCOPY VARCHAR2,
                                       interest_formula  IN OUT NOCOPY VARCHAR2,
                                       interest_grace    IN OUT NOCOPY VARCHAR2,
                                       penalty_type      IN OUT NOCOPY VARCHAR2,
                                       penalty_rate_amt  IN OUT NOCOPY VARCHAR2,
                                       row_number        IN     NUMBER,
                                       Errcd             IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT acpc.global_attribute3,
           acpc.global_attribute4,
           acpc.global_attribute5,
           acpc.global_attribute6,
           acpc.global_attribute7,
           acpc.global_attribute8,
           acpc.global_attribute9
    INTO   interest_type,
           interest_rate_amt,
           interest_period,
           interest_formula,
           interest_grace,
           penalty_type,
           penalty_rate_amt
     FROM  hz_cust_profile_classes acpc,
           hz_customer_profiles acp
     WHERE acp.cust_account_id = bill_to_cust_id
     AND   acp.profile_class_id = acpc.profile_class_id
     AND   acp.site_use_id is null
     AND   rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_customer_profile_dtls;


  PROCEDURE get_batch_id (p_batch_source_id IN     NUMBER,
                          batch_id          IN OUT NOCOPY NUMBER,
                          row_number        IN     NUMBER,
                          Errcd             IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT global_attribute1
    INTO   batch_id
    FROM   ra_batch_sources
    WHERE  batch_source_id = p_batch_source_id
    AND   rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_batch_id;


  PROCEDURE get_tax_base_rate_amt (cust_trx_id IN     NUMBER,
                                   base_amt    IN OUT NOCOPY NUMBER,
                                   base_rate   IN OUT NOCOPY NUMBER,
                                   row_number  IN     NUMBER,
                                   Errcd       IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT TO_NUMBER (global_attribute11),
           TO_NUMBER (global_attribute12)
    INTO   base_amt,
           base_rate
    FROM   ra_customer_trx_lines
    WHERE  customer_trx_line_id = cust_trx_id
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_tax_base_rate_amt;

  PROCEDURE get_issue_date (cust_trx_id IN     NUMBER,
                            iss_date    IN OUT NOCOPY DATE,
                            row_number  IN     NUMBER,
                            Errcd       IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT global_attribute8
    INTO   iss_date
    FROM   ra_customer_trx
    WHERE  customer_trx_id = cust_trx_id
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_issue_date;

  PROCEDURE get_customer_trx_dtls (cust_trx_id IN     NUMBER,
                                   status      IN OUT NOCOPY VARCHAR2,
                                   typ_class   IN OUT NOCOPY VARCHAR2,
                                   row_number  IN     NUMBER,
                                   Errcd       IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT rct.status_trx,
           rctt.type
    INTO   status,
           typ_class
    FROM   ra_customer_trx_all rct,
           ra_cust_trx_types_all rctt
    WHERE  rct.cust_trx_type_id = rctt.cust_trx_type_id
    AND    rct.customer_trx_id = cust_trx_id
    AND    rownum = row_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_customer_trx_dtls;

  PROCEDURE get_class      (p_trx_number  IN     VARCHAR2,
                            p_class       IN OUT NOCOPY VARCHAR2,
                            row_number   IN     NUMBER,
                            Errcd        IN OUT NOCOPY NUMBER) IS
  BEGIN
    Errcd := 0;
    SELECT class
    INTO   p_class
    FROM   ar_payment_schedules
    WHERE  trx_number = p_trx_number;
    EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;
  END get_class;

 PROCEDURE get_prev_interest_values(p_applied_payment_schedule_id IN NUMBER,
                                     p_cash_receipt_id IN NUMBER,
                                     p_apply_date IN DATE,
                                     p_main_amnt_rec OUT NOCOPY VARCHAR2,
                                     p_base_int_calc OUT NOCOPY VARCHAR2,
                                     p_calculated_interest OUT NOCOPY VARCHAR2,
                                     p_received_interest OUT NOCOPY VARCHAR2,
                                     p_int_diff_action OUT NOCOPY VARCHAR2,
                                     p_int_writeoff_reason OUT NOCOPY VARCHAR2,
                                     p_payment_date OUT NOCOPY VARCHAR2,
                                     p_writeoff_date OUT NOCOPY VARCHAR2,
                                     Errcd IN OUT NOCOPY NUMBER) IS

  x_apply_date  DATE;
  flag          BOOLEAN;

  BEGIN

  Errcd := 0;
  flag := TRUE;

  BEGIN

    SELECT MAX(apply_date)
    INTO  x_apply_date
    FROM ar_receivable_applications
    WHERE applied_payment_schedule_id = p_applied_payment_schedule_id
    AND   application_type = 'CASH'
    AND   status = 'APP'
    AND   confirmed_flag = 'Y'
    AND   reversal_gl_date IS NULL
    AND   apply_date < p_apply_date
    AND   cash_receipt_id <> p_cash_receipt_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      flag := FALSE;
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_util.debug('get_prev_interest_values: ' || to_char(SQLCODE));
      END IF;
      Errcd := SQLCODE;

  END;

  IF Errcd = 0 THEN
  IF flag THEN
    BEGIN
      SELECT global_attribute1,
             global_attribute2,
             global_attribute3,
             global_attribute4,
             global_attribute5,
             global_attribute6,
             global_attribute7,
             global_attribute8
       INTO  p_main_amnt_rec,
             p_base_int_calc,
             p_calculated_interest,
             p_received_interest,
             p_int_diff_action,
             p_int_writeoff_reason,
             p_payment_date,
             p_writeoff_date
      FROM ar_receivable_applications
      WHERE applied_payment_schedule_id = p_applied_payment_schedule_id
      AND   application_type = 'CASH'
      AND   status = 'APP'
      AND   confirmed_flag = 'Y'
      AND   reversal_gl_date IS NULL
      AND   apply_date = x_apply_date;
    EXCEPTION
      WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('get_prev_interest_values: ' || to_char(SQLCODE));
        END IF;
        Errcd := SQLCODE;
    END;
  ELSE
    p_main_amnt_rec := '';
    p_base_int_calc := '';
    p_calculated_interest := '';
    p_received_interest := '';
    p_int_diff_action := '';
    p_int_writeoff_reason := '';
    p_payment_date := '';
    p_writeoff_date := '';
  END IF;
  END IF;

  END get_prev_interest_values;

  PROCEDURE get_interest_reversal_flag(p_cash_receipt_id IN NUMBER,
                                       p_interest_reversal OUT NOCOPY BOOLEAN,
                                       Errcd IN OUT NOCOPY NUMBER) IS

  Cursor pay_sched is
  SELECT applied_payment_schedule_id,
         nvl(global_attribute3,0) calculated_interest,
         nvl(global_attribute4,0) received_interest,
         apply_date
  FROM   ar_receivable_applications
  where  cash_receipt_id = p_cash_receipt_id;

  ps_rec   pay_sched%ROWTYPE;
  revcode  NUMBER;

  BEGIN

  Errcd := 0;
  revcode := 0;

  OPEN pay_sched;
  LOOP
    FETCH pay_sched INTO ps_rec;
    EXIT WHEN pay_sched%NOTFOUND
      OR pay_sched%NOTFOUND IS NULL;
    IF ps_rec.calculated_interest = 0 THEN
      p_interest_reversal := TRUE;
    ELSE
      BEGIN
        SELECT 1
        INTO   revcode
        FROM ar_receivable_applications
        WHERE applied_payment_schedule_id = ps_rec.applied_payment_schedule_id
        AND   status = 'APP'
        AND   cash_receipt_id <> p_cash_receipt_id
        AND   apply_date between ps_rec.apply_date and sysdate
        AND   reversal_gl_date IS NULL;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          revcode := 0;
          p_interest_reversal := TRUE;
        WHEN TOO_MANY_ROWS THEN
          revcode := 0;
          p_interest_reversal := FALSE;
        WHEN OTHERS THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('get_interest_reversal_flag: ' || to_char(SQLCODE));
          END IF;
          Errcd := SQLCODE;
          revcode := 0;
      END;

      IF revcode = 1 THEN
        p_interest_reversal := FALSE;
      END IF;

      IF NOT p_interest_reversal THEN
        EXIT;
      END IF;

      BEGIN
        SELECT 1
        INTO revcode
        FROM ar_adjustments
        WHERE payment_schedule_id = ps_rec.applied_payment_schedule_id
        AND   associated_cash_receipt_id = p_cash_receipt_id
        AND   gl_posted_date IS NULL;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          revcode := 0;
          p_interest_reversal := FALSE;
        WHEN TOO_MANY_ROWS THEN
          revcode := 0;
          p_interest_reversal := TRUE;
        WHEN OTHERS THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_util.debug('get_interest_reversal_flag: ' || to_char(SQLCODE));
          END IF;
          revcode := 0;
          Errcd := -1;
      END;

      IF revcode = 1 THEN
        p_interest_reversal := TRUE;
      END IF;

      IF NOT p_interest_reversal THEN
        EXIT;
      END IF;

    END IF;
  END LOOP;
  CLOSE pay_sched;

  END get_interest_reversal_flag;

  PROCEDURE get_adjustment_record(p_adj_rec      IN OUT NOCOPY ar_adjustments%ROWTYPE,
                                  p_user_id         IN NUMBER,
                                  p_amount          IN NUMBER,
                                  p_receipt_date    IN DATE,
                                  p_cash_receipt_id IN NUMBER,
                                  p_customer_trx_id IN NUMBER,
                                  p_pay_sched_id    IN NUMBER,
                                  p_rectrx_id       IN NUMBER,
                                  p_status          IN VARCHAR2,
                                  Errcd          IN OUT NOCOPY NUMBER) IS
  BEGIN

    Errcd := 0;

    SELECT p_user_id,
           sysdate,
           p_user_id,
           p_user_id,
           sysdate,
           p_amount,
           sysdate,
           p_receipt_date,
           arsp.set_of_books_id,
           'CHARGES',
           decode( p_status,'Y','A','M'),
           p_status ,
           p_cash_receipt_id,
           p_customer_trx_id,
           p_pay_sched_id,
           p_rectrx_id,
           'ARXRWMAI',
           decode( p_status ,'Y','Y','N'),
           decode( p_status ,'Y',p_user_id,NULL),
           -3,
           p_amount
    INTO  p_adj_rec.LAST_UPDATED_BY,
          p_adj_rec.LAST_UPDATE_DATE,
          p_adj_rec.LAST_UPDATE_LOGIN,
          p_adj_rec.CREATED_BY,
          p_adj_rec.CREATION_DATE,
          p_adj_rec.AMOUNT,
          p_adj_rec.APPLY_DATE,
          p_adj_rec.GL_DATE,
          p_adj_rec.SET_OF_BOOKS_ID,
          p_adj_rec.TYPE,
          p_adj_rec.ADJUSTMENT_TYPE,
          p_adj_rec.STATUS,
          p_adj_rec.ASSOCIATED_CASH_RECEIPT_ID,
          p_adj_rec.CUSTOMER_TRX_ID,
          p_adj_rec.PAYMENT_SCHEDULE_ID,
          p_adj_rec.RECEIVABLES_TRX_ID,
          p_adj_rec.CREATED_FROM,
          p_adj_rec.POSTABLE,
          p_adj_rec.APPROVED_BY,
          p_adj_rec.POSTING_CONTROL_ID,
          p_adj_rec.ACCTD_AMOUNT
    FROM ar_system_parameters arsp;


  	BEGIN						--Bug 8231701

   	 SELECT code_combination_id
  	 INTO  p_adj_rec.code_combination_id
  	 FROM  ar_receivables_trx
  	 WHERE receivables_trx_id = p_adj_rec.receivables_trx_id;

        EXCEPTION
            WHEN OTHERS THEN
     	    NULL;
        END;


 EXCEPTION
      WHEN OTHERS THEN
        Errcd := SQLCODE;

 END get_adjustment_record;

 PROCEDURE get_warehouse_info(p_customer_trx_id IN NUMBER,
                              p_warehouse_count OUT NOCOPY NUMBER) IS

 BEGIN
   SELECT count(*)
   INTO  p_warehouse_count
   FROM  ra_customer_trx_lines
   WHERE customer_trx_id = p_customer_trx_id
   AND   line_type = 'LINE'
   AND   warehouse_id IS NULL
   AND   inventory_item_id IS NOT NULL;

 END get_warehouse_info;

 PROCEDURE get_warehouse_id(p_customer_trx_id IN NUMBER,
                            p_warehouse_id OUT NOCOPY NUMBER) IS

 BEGIN
   SELECT distinct warehouse_id
   INTO  p_warehouse_id
   FROM  ra_customer_trx_lines
   WHERE customer_trx_id = p_customer_trx_id
   AND   line_type = 'LINE'
   AND   inventory_item_id IS NOT NULL
   AND   rownum = 1;

 EXCEPTION WHEN OTHERS THEN
   p_warehouse_id := NULL;

 END get_warehouse_id;


 PROCEDURE get_void_trx_type_id(p_country_code IN VARCHAR2,
                                p_void_trx_type_id OUT NOCOPY NUMBER,
                                Errcd          IN OUT NOCOPY NUMBER) IS

    l_category VARCHAR2(30);

 BEGIN

    IF p_country_code = 'CL' THEN
      l_category := 'JL.CL.RAXSUCTT.CUST_TRX_TYPES';
    ELSIF p_country_code = 'AR' THEN
      l_category := 'JL.AR.RAXSUCTT.CUST_TRX_TYPES';
    ELSIF p_country_code = 'CO' THEN
      l_category := 'JL.CO.RAXSUCTT.CUST_TRX_TYPES';
    END IF;

    SELECT  cust_trx_type_id
    INTO p_void_trx_type_id
    FROM ra_cust_trx_types ct
    WHERE ct.global_attribute_category = l_category
    AND ct.global_attribute6 = 'Y';

 EXCEPTION
      WHEN no_data_found THEN
        p_void_trx_type_id := 0;
      WHEN OTHERS THEN
        Errcd := SQLCODE;

 END get_void_trx_type_id;

 PROCEDURE get_city_from_ra_addresses (pay_sched_id IN     NUMBER,
                                       city         IN OUT NOCOPY VARCHAR2,
                                       row_number   IN     NUMBER,
                                       Errcd        IN OUT NOCOPY NUMBER,
                                       state        IN OUT NOCOPY VARCHAR2) IS  --Bug 2319552
 BEGIN
   Errcd := 0;
   SELECT loc.city,
          loc.state --Bug 2319552
   INTO   city,
          state --Bug 2319552
   FROM   ar_payment_schedules arps,
          hz_cust_acct_sites ad,
          hz_cust_site_uses hzsu,
          ra_customer_trx ract,
          --ra_site_uses rasu,
          hz_locations loc,
          hz_party_sites pty
   WHERE  arps.payment_schedule_id = pay_sched_id
   AND    ract.customer_trx_id     = arps.customer_trx_id
   AND    hzsu.site_use_id         = ract.bill_to_site_use_id
   AND    ad.cust_acct_site_id     = hzsu.cust_acct_site_id
   AND    ad.party_site_id         = pty.party_site_id
   AND    loc.location_id          = pty.location_id
   AND    rownum = row_number;
   EXCEPTION
     WHEN OTHERS THEN
       Errcd := SQLCODE;
 END get_city_from_ra_addresses;

 PROCEDURE update_doc_status(p_cash_receipt_id IN NUMBER) IS
 Cursor c1(p_rec_id NUMBER) is SELECT receivable_application_id, global_attribute12
              FROM ar_receivable_applications_all
              WHERE cash_receipt_id = p_rec_id;
 BEGIN

   For rec in c1(p_cash_receipt_id) loop

     update jl_br_ar_collection_docs_all set document_status = 'SELECTED'
     where  document_id = to_number(rec.global_attribute12);

   END LOOP;
 EXCEPTION
   WHEN Others then
   null;
 END update_doc_status;

 PROCEDURE get_dbms_sql_native (x_dbms_sql_native OUT NOCOPY INTEGER) IS --Bugs 2952004 / 2939830
 BEGIN
    x_dbms_sql_native := DBMS_SQL.NATIVE;
 END get_dbms_sql_native;

END JL_ZZ_AR_LIBRARY_1_PKG;

/
