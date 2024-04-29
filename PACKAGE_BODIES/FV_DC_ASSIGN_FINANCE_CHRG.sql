--------------------------------------------------------
--  DDL for Package Body FV_DC_ASSIGN_FINANCE_CHRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_DC_ASSIGN_FINANCE_CHRG" as
/* $Header: FVDCAAFB.pls 120.22.12010000.23 2009/11/05 15:36:21 snama ship $ */

/*****************************************************************************/
/*****           Variable Declaration For All Processes                   ****/
/*****************************************************************************/
  g_module_name VARCHAR2(100) ;
  g_FAILURE             NUMBER;
  g_SUCCESS             NUMBER;
  g_WARNING             NUMBER;
  g_enter               VARCHAR2(10);
  g_exit                VARCHAR2(10);
  g_request_id          NUMBER;
  g_user_id             NUMBER;
  g_login_id            NUMBER;
  g_org_id              NUMBER;
  g_set_of_books_id     NUMBER;
  g_ledger_name         VARCHAR2(30);
  g_CURRENT_LOG_LEVEL   NUMBER;
  g_hi_date             DATE;
  g_lo_date             DATE;

  TYPE out_rec IS RECORD
  (
    invoice_id ra_customer_trx_all.customer_trx_id%TYPE,
    payment_schedule_id ar_payment_schedules.payment_schedule_id%TYPE,
    charge_type fv_finance_charge_controls.charge_type%TYPE,
    invoice_number ra_customer_trx_all.trx_number%TYPE,
    amount_due_remaining ar_payment_schedules.amount_due_remaining%TYPE,
    amount_due_original ar_payment_schedules.amount_due_original%TYPE,
    due_date ar_payment_schedules.due_date%TYPE,
    amount_based VARCHAR2(1),
    amount_or_rate NUMBER,
    first_accrual NUMBER,
    accrual_interval NUMBER,
    grace_period NUMBER,
    last_accrual_date DATE,
    base_date_type VARCHAR2(30),
    comments VARCHAR2(1024),
    accrual_date DATE,
    first_late_date DATE,
    finance_charges NUMBER,
    number_of_periods NUMBER
  );

  TYPE out_rec_tab IS TABLE OF out_rec INDEX BY BINARY_INTEGER;

  g_out_rec_tab out_rec_tab;
  g_out_rec_count NUMBER;

/****************************************************************************/


  PROCEDURE log
  (
    p_location IN VARCHAR2,
    p_message  IN VARCHAR2
  ) IS
  BEGIN
    fnd_file.put_line (fnd_file.log, p_location||':'||p_message);
  END;

  PROCEDURE output
  (
    p_message  IN VARCHAR2
  ) IS
  BEGIN
    fnd_file.put_line (fnd_file.output,p_message);
  END;

  PROCEDURE debug
  (
    p_module  IN VARCHAR2,
    p_message IN VARCHAR2
  ) IS
  BEGIN
    fv_utility.debug_mesg(fnd_log.level_statement, p_module,p_message);
  END;

  PROCEDURE initialize_global_variables
  IS
  BEGIN
    g_module_name         := 'fv.plsql.fv_dc_assign_finance_chrg.';
    g_FAILURE             := -1;
    g_SUCCESS             := 0;
    g_WARNING             := -2;
    g_request_id          := fnd_global.conc_request_id;
    g_user_id             := fnd_global.user_id;
    g_login_id            := fnd_global.login_id;
    g_org_id              := mo_global.get_current_org_id;
    mo_utils.get_ledger_info(g_org_id, g_set_of_books_id, g_ledger_name);
    g_enter               := 'ENTER';
    g_exit                := 'EXIT';
    g_CURRENT_LOG_LEVEL   := fnd_log.g_current_runtime_level;
    g_out_rec_count       := 0;
    g_lo_date             := TO_DATE('1-1-1900', 'DD-MM-YYYY');
    g_hi_date             := TO_DATE('31-12-4000', 'DD-MM-YYYY');
  END;

  PROCEDURE initialize_program_variables
  (
    p_gl_date              IN  DATE,
    p_term_id              OUT NOCOPY NUMBER,
    p_errbuf               OUT NOCOPY VARCHAR2,
    p_retcode              OUT NOCOPY NUMBER
  )
  IS
    l_module_name     VARCHAR2(200);
    l_location        VARCHAR2(200);
    l_ar_period_count NUMBER;
  BEGIN
    l_module_name := g_module_name || 'initialize_program_variables';
    p_retcode := g_SUCCESS;
    p_errbuf  := NULL;

    IF (fnd_log.level_procedure >= g_CURRENT_LOG_LEVEL) THEN
      debug(l_module_name,g_enter);
    END IF;

    BEGIN
      SELECT term_id
        INTO p_term_id
        FROM ra_terms a
       WHERE a.name = 'IMMEDIATE';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_retcode := g_FAILURE;
        p_errbuf := SQLERRM;
        l_location   := l_module_name||'.select_ra_terms';
        log(l_location, 'IMMEDIATE terms not defined');
        log(l_location,l_location) ;
        log(l_location,p_errbuf) ;
      WHEN OTHERS THEN
        p_retcode := g_FAILURE;
        p_errbuf := SQLERRM;
        l_location   := l_module_name||'.select_ra_terms';
        log(l_location,l_location) ;
        log(l_location,p_errbuf) ;
    END;

    IF (p_retcode = g_SUCCESS) THEN
      BEGIN
        IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
          debug(l_module_name,'SELECT gl_period_statuses');
        END IF;
        SELECT 1
          INTO l_ar_period_count
          FROM gl_period_statuses
         WHERE closing_status ='O'
           AND set_of_books_id = g_set_of_books_id
           AND application_id = 222
           AND p_gl_date between start_date and end_date;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_location := l_module_name||'.select_gl_period_statuses1';
          log (l_location, 'GL Date should be in an open period. ');
          log (l_location, 'Please Enter a GL Date which is in an open period ') ;
          p_retcode := g_FAILURE;
        WHEN OTHERS THEN
          p_retcode := g_FAILURE;
          p_errbuf := SQLERRM;
          l_location := l_module_name||'.select_gl_period_statuses2';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
      END;
    END IF;


    IF (fnd_log.level_procedure >= g_CURRENT_LOG_LEVEL) THEN
      debug(l_module_name,g_exit);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      log(l_location,l_location) ;
      log(l_location, p_errbuf);
  END;

  PROCEDURE write_output
  IS
    l_module_name    VARCHAR2(200);
    l_location       VARCHAR2(200);
    l_HTML_SPACE    VARCHAR2(100) := '&'||'nbsp;';

    PROCEDURE th
    (
      p_data IN VARCHAR2
    )
    IS
    BEGIN
      output ('<TH class=''OraTableColumnHeader'' style=''border-left:1px solid #c9cbd3''>');
      output (p_data);
      output ('</TH>');
    END;

    PROCEDURE td
    (
      p_data IN VARCHAR2
    )
    IS
    BEGIN
      output ('<TD class=''OraTableCellText'' style=''border:1px solid #c9cbd3''>');
      output (NVL(p_data, l_HTML_SPACE));
      output ('</TD>');
    END;


  BEGIN

    l_module_name := g_module_name || 'write_output';
    output ('<HTML>');
    output ('<STYLE TYPE="text/css">');
    output ('<!--');
    output ('.OraTable {background-color:#999966}');
    output ('.OraTableColumnHeader {font-family:Tahoma,Arial,Helvetica,Geneva,sans-serif;font-size:9pt;font-weight:bold;text-align:left;background-color:#cfe0f1;color:#3c3c3c;vertical-align:bottom}');
    output ('.OraTableCellText {font-family:Tahoma,Arial,Helvetica,Geneva,sans-serif;font-size:9pt;background-color:#f2f2f5;color:#3c3c3c;vertical-align:baseline}');
    output ('-->');
    output ('</STYLE>');
    output ('<TABLE class=''OraTable'' style=''border-collapse:collapse'' width=''100%'' cellpadding=1 cellspacing=0 border=0 >');
    output ('<TR>');
    th ('Invoice<BR>Id');
    th ('Invoice<BR> Schedule Id');
    th ('Invoice<BR>Number');
    th ('Charge<BR>Type');
    th ('Amount Due<BR>Remaining');
    th ('Amount Due<BR>Original');
    th ('Due Date');
    th ('Amount Based');
    th ('Amount/Rate');
    th ('First<BR>Accrual');
    th ('Accrual<BR>Interval');
    th ('Grace<BR>Period');
    th ('Base Date<BR>Type');
    th ('Last Accrual Date');
    th ('Accrual Date');
    th ('Finance Charges');
    th ('Number of Periods');
    th ('Comments');
    output ('</TH>');
    output ('</TR>');
    FOR i IN 1..g_out_rec_tab.COUNT LOOP
      output ('<TR>');
      td (TO_CHAR(g_out_rec_tab(i).invoice_id));
      td (TO_CHAR(g_out_rec_tab(i).payment_schedule_id));
      td (g_out_rec_tab(i).invoice_number);
      td (g_out_rec_tab(i).charge_type);
      td (TO_CHAR(g_out_rec_tab(i).amount_due_remaining));
      td (TO_CHAR(g_out_rec_tab(i).amount_due_original));
      td (TO_CHAR(g_out_rec_tab(i).due_date));
      td (g_out_rec_tab(i).amount_based);
      td (TO_CHAR(g_out_rec_tab(i).amount_or_rate));
      td (TO_CHAR(g_out_rec_tab(i).first_accrual));
      td (TO_CHAR(g_out_rec_tab(i).accrual_interval));
      td (TO_CHAR(g_out_rec_tab(i).grace_period));
      td (g_out_rec_tab(i).base_date_type);
      td (TO_CHAR(g_out_rec_tab(i).last_accrual_date));
      td (TO_CHAR(g_out_rec_tab(i).accrual_date));
      td (TO_CHAR(g_out_rec_tab(i).finance_charges));
      td (TO_CHAR(g_out_rec_tab(i).number_of_periods));
      td (g_out_rec_tab(i).comments);
      output ('</TR>');
    END LOOP;
    output ('</TABLE>');
    output ('</HTML>');
  EXCEPTION
    WHEN OTHERS THEN
      log(l_location,l_location) ;
      l_location   := l_module_name||'.final_exception';
      log(l_location,SQLERRM) ;
      log(l_location,l_location) ;
  END;

  PROCEDURE accrue_charges
  (
    p_accrue_as_of_date    IN DATE,
    p_last_date            IN DATE,
    p_customer_trx_id      IN ra_customer_trx.customer_trx_id%TYPE,
    p_amount_due_remaining IN OUT NOCOPY ar_payment_schedules.amount_due_remaining%TYPE,
    p_rate_amount          IN NUMBER,
    p_interval             IN fv_finance_charge_controls.accrual_interval%TYPE,
    p_charges              OUT NOCOPY NUMBER,
    p_errbuf               OUT NOCOPY VARCHAR2,
    p_retcode              OUT NOCOPY NUMBER
  )
  IS
    l_module_name    VARCHAR2(200);
    l_location       VARCHAR2(200);
    l_accrued_amount NUMBER;
    l_amt_due        NUMBER;
    l_ct_id          NUMBER;
  BEGIN
    l_module_name := g_module_name || 'accrue_charges';
    p_retcode := g_SUCCESS;
    p_errbuf  := NULL;

    IF (fnd_log.level_procedure >= g_CURRENT_LOG_LEVEL) THEN
      debug(l_module_name,g_enter);
    END IF;

    IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
      debug(l_module_name,'p_last_date='||p_last_date);
      debug(l_module_name,'p_customer_trx_id='||p_customer_trx_id);
      debug(l_module_name,'p_rate_amount='||p_rate_amount);
      debug(l_module_name,'p_interval='||p_interval);
      debug(l_module_name,'p_amount_due_remaining='||p_amount_due_remaining);
    END IF;

    IF (p_interval = 0) THEN
      -- sum the total amount_due_remaining for the invoice.  We want to
      -- apply the charge on the total amount of the invoice. This is really for
      -- invoices with split payment terms.  Because main query only is looking
      -- at the porition of the invoice that is late.  But when calculating
      -- for one time charges we want the total amount of the invoice not just
      -- the amount for the schedule that is late.

      l_ct_id := p_customer_trx_id;
      BEGIN
        IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
          debug(l_module_name,'l_ct_id='||l_ct_id);
        END IF;

        SELECT SUM(amount_due_remaining)
          INTO l_amt_due
          FROM ar_payment_schedules
         WHERE customer_trx_id = l_ct_id
           AND class = 'INV';

        IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
          debug(l_module_name,'l_amt_due='||l_amt_due);
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          p_retcode := g_FAILURE;
          p_errbuf := SQLERRM;
          l_location   := l_module_name||'.select_ar_payment_schedules';
          log(l_location,l_location) ;
          log(l_location,p_errbuf) ;
      END;

    ELSE
      l_amt_due := p_amount_due_remaining;
    END IF;

    IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
      debug(l_module_name,'l_amt_due(1)='||l_amt_due);
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      l_accrued_amount := round(l_amt_due * p_rate_amount *
      ((trunc(p_accrue_as_of_date) - trunc(p_last_date))/360),2);
      g_out_rec_tab(g_out_rec_count).comments := 'Accrued Amount = '||l_amt_due||'*'||p_rate_amount||'*('||(trunc(p_accrue_as_of_date) - trunc(p_last_date))||'/360)'||'='||l_accrued_amount;
      IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
        debug(l_module_name,'l_accrued_amount='||l_accrued_amount);
      END IF;
    END IF;

    IF (fnd_log.level_procedure >= g_CURRENT_LOG_LEVEL) THEN
      debug(l_module_name,g_exit);
    END IF;
    p_charges :=  l_accrued_amount;
  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      log(l_location,l_location) ;
      log(l_location, p_errbuf);
  end accrue_charges;

------------------------------------------------------------------------------

  PROCEDURE missed_intervals
  (
    p_accrue_as_of_date IN DATE,
    p_interval          IN fv_finance_charge_controls.accrual_interval%type,
    p_last_accrual_date IN DATE,
    p_first_late_day    IN OUT NOCOPY DATE,
    p_number_of_periods OUT NOCOPY NUMBER,
    p_errbuf            OUT NOCOPY VARCHAR2,
    p_retcode           OUT NOCOPY NUMBER
  )
  IS
    l_module_name VARCHAR2(200);
    l_location    VARCHAR2(200);
  BEGIN
    l_module_name := g_module_name || 'missed_intervals';
    p_retcode := g_SUCCESS;
    p_errbuf  := NULL;
    p_number_of_periods := 1;  -- starting at one takes in to consideration we must

    IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
      debug(l_module_name,'Inside '||l_module_name);
      debug(l_module_name,'p_interval='||p_interval);
      debug(l_module_name,'p_last_accrual_date='||p_last_accrual_date);
      debug(l_module_name,'p_first_late_day='||p_first_late_day);
    END IF;

    IF (p_last_accrual_date IS NOT NULL) THEN
      p_first_late_day := p_last_accrual_date;
    END IF;

    IF p_interval <> 0 THEN
       IF TRUNC(p_accrue_as_of_date) >= (trunc(p_first_late_day) + p_interval) THEN
         p_number_of_periods := trunc((trunc(p_accrue_as_of_date) - trunc(p_first_late_day))/p_interval);
       END IF;
    END IF;

    IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
      l_location := '6';
      debug(l_module_name,'p_number_of_periods='||p_number_of_periods);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      debug(l_module_name,'l_location='||l_location);
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location, p_errbuf);
  END missed_intervals;

  PROCEDURE submit_report
  (
    p_errbuf        OUT NOCOPY VARCHAR2,
    p_retcode       OUT NOCOPY NUMBER
  )
  IS
    l_module_name              VARCHAR2(200);
    l_location                 VARCHAR2(200);
    l_conc_req_id              NUMBER;
  BEGIN
    l_module_name := g_module_name || 'submit_report';
    p_retcode := g_SUCCESS;
    p_errbuf  := null;

    l_conc_req_id := fnd_request.submit_request
                     (
                       application => 'FV',
                       program => 'FVDCACCD',
                       description => NULL,
                       start_time => NULL,
                       sub_request => FALSE,
                       argument1 => g_request_id
                     );
    IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
      debug (l_module_name,'Submitting Detail report  '||l_conc_req_id);
    END IF;

    IF (l_conc_req_id = 0) THEN
      p_retcode := g_FAILURE;
      p_errbuf := 'Error in Submitting Accrue Finance charge Detail Report ';
      log (l_location,p_errbuf);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location, p_errbuf);
  END submit_report;

  PROCEDURE interpret_dm_error
  (
    p_trx_number    IN VARCHAR2,
    p_return_status IN VARCHAR2,
    p_message_count IN NUMBER,
    p_message_data  IN VARCHAR2,
    p_errbuf        OUT NOCOPY VARCHAR2,
    p_retcode       OUT NOCOPY NUMBER
  )
  IS
    l_module_name              VARCHAR2(200);
    l_location                 VARCHAR2(200);
    l_header_printed           BOOLEAN := FALSE;
    l_message_data             VARCHAR2(1024);
  BEGIN
    l_module_name := g_module_name || 'interpret_dm_error';
    p_retcode := g_SUCCESS;
    p_errbuf  := null;

    IF (NVL(p_return_status, 'S') <> 'S') THEN
      IF NOT l_header_printed THEN
        log ('', '*********** ERRORS FOR TRX NUMBER '||p_trx_number||' ***************');
        l_header_printed := TRUE;
      END IF;
      p_retcode := g_FAILURE;

      IF (p_message_count = 1) THEN
        ----------------------------------------------------------------------
        -- Message Count is 1, hence the error message is in x_msg_data     --
        ----------------------------------------------------------------------
        p_errbuf := p_message_data;
        log ('',p_message_data);
      ELSIF (p_message_count > 1) THEN
        ----------------------------------------------------------------------
        -- Message Count is > 1, hence loop for x_msg_count times and call  --
        -- fnd_msg_pub.get to get the error messages                        --
        ----------------------------------------------------------------------
        FOR l_counter IN 1..p_message_count LOOP
          l_message_data := fnd_msg_pub.get (p_encoded => 'F');
          log ('',l_message_data);
        END LOOP;
        p_errbuf := 'Too many errors.';
      END IF;
    END IF;

    FOR error_rec IN (SELECT *
                        FROM ar_trx_errors_gt) LOOP
      IF NOT l_header_printed THEN
        log ('', '*********** ERRORS FOR TRX NUMBER '||p_trx_number||' ***************');
        l_header_printed := TRUE;
      END IF;

      log ('', error_rec.error_message||':'||error_rec.invalid_value);
      p_retcode := g_FAILURE;
      p_errbuf := 'Too many errors.';
    END LOOP;
    IF l_header_printed THEN
      log ('', '*******************************************************');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location, p_errbuf);
  END interpret_dm_error;

  PROCEDURE check_and_correct_rounding
  (
    p_amount         IN NUMBER,
    p_trx_header_tbl IN OUT NOCOPY ar_invoice_api_pub.trx_header_tbl_type,
    p_trx_lines_tbl  IN OUT NOCOPY ar_invoice_api_pub.trx_line_tbl_type,
    p_trx_dist_tbl   IN OUT NOCOPY ar_invoice_api_pub.trx_dist_tbl_type,
    p_errbuf         OUT NOCOPY VARCHAR2,
    p_retcode        OUT NOCOPY NUMBER
  )
  IS
    l_module_name              VARCHAR2(200);
    l_location                 VARCHAR2(200);
    l_line_id NUMBER;
    l_dist_id NUMBER;
    l_last_dist_id NUMBER;
    l_total_line_amount NUMBER := 0;
    l_total_dist_amount NUMBER := 0;
    l_total_percent NUMBER := 0;
  BEGIN
    l_module_name := g_module_name || 'check_and_correct_rounding';
    p_retcode := g_SUCCESS;
    p_errbuf  := null;

    IF (fnd_log.level_procedure >= g_CURRENT_LOG_LEVEL) THEN
      debug(l_module_name,g_enter);
    END IF;

    /* First correct the line amount variations if any */
    l_total_line_amount := 0;
    l_line_id := 0;
    IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
      debug (l_module_name,'Checking if total of line changes are correct');
    END IF;
    FOR line IN 1..p_trx_lines_tbl.COUNT LOOP
      l_line_id := l_line_id + 1;
      l_total_line_amount := l_total_line_amount + p_trx_lines_tbl(l_line_id).amount;
    END LOOP;

    IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
      debug (l_module_name,'l_total_line_amount='||l_total_line_amount);
      debug (l_module_name,'p_amount='||p_amount);
      debug (l_module_name,'l_line_id='||l_line_id);
    END IF;

    IF (l_total_line_amount <> p_amount) THEN
      p_trx_lines_tbl(l_line_id).amount := p_trx_lines_tbl(l_line_id).amount + (p_amount-l_total_line_amount);
      p_trx_lines_tbl(l_line_id).unit_selling_price := p_trx_lines_tbl(l_line_id).amount;
      IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
        debug (l_module_name,'Changed the line amount');
        debug (l_module_name,'amount='||p_trx_lines_tbl(l_line_id).amount);
        debug (l_module_name,'unit_selling_price='||p_trx_lines_tbl(l_line_id).unit_selling_price);
      END IF;
    END IF;

    /* Now correct the dist amount variations if any */
    l_line_id := 0;
    IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
      debug (l_module_name,'Checking if total of dist changes are correct');
    END IF;
    FOR line IN 1..p_trx_lines_tbl.COUNT LOOP
      l_line_id := l_line_id + 1;
      l_dist_id := 0;
      l_total_dist_amount := 0;
      l_last_dist_id := 0;
      l_total_percent := 0;
      FOR dist IN 1..p_trx_dist_tbl.COUNT LOOP
        l_dist_id := l_dist_id + 1;
        IF (p_trx_dist_tbl(l_dist_id).trx_line_id = l_line_id) THEN
          l_total_dist_amount := l_total_dist_amount + p_trx_dist_tbl(l_dist_id).amount;
          p_trx_dist_tbl(l_dist_id).percent := ROUND((p_trx_dist_tbl(l_dist_id).amount/p_trx_lines_tbl(l_line_id).amount)*100, 4);
          l_total_percent := l_total_percent + p_trx_dist_tbl(l_dist_id).percent;
          l_last_dist_id := l_dist_id;
          IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
            debug (l_module_name,'Checking for dist amounts');
            debug (l_module_name,'percent='||p_trx_dist_tbl(l_dist_id).percent);
            debug (l_module_name,'Running l_total_dist_amount='||l_total_dist_amount);
            debug (l_module_name,'Running l_total_percent='||l_total_percent);
          END IF;
        END IF;
      END LOOP;

      IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
        debug (l_module_name,'l_total_dist_amount='||l_total_dist_amount);
        debug (l_module_name,'l_total_percent(1)='||l_total_percent);
        debug (l_module_name,'p_trx_lines_tbl(l_line_id).amount='||p_trx_lines_tbl(l_line_id).amount);
        debug (l_module_name,'l_last_dist_id='||l_last_dist_id);
      END IF;

      IF (l_total_dist_amount <> p_trx_lines_tbl(l_line_id).amount) THEN
        l_total_percent := l_total_percent - p_trx_dist_tbl(l_last_dist_id).percent;
        p_trx_dist_tbl(l_last_dist_id).amount := p_trx_dist_tbl(l_last_dist_id).amount + (p_trx_lines_tbl(l_line_id).amount - l_total_dist_amount);
        p_trx_dist_tbl(l_last_dist_id).percent := ROUND((p_trx_dist_tbl(l_last_dist_id).amount/p_trx_lines_tbl(l_line_id).amount)*100, 4);
        l_total_percent := l_total_percent + p_trx_dist_tbl(l_last_dist_id).percent;
        IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
          debug (l_module_name,'Changed the dist amount');
          debug (l_module_name,'amount='||p_trx_dist_tbl(l_last_dist_id).amount);
          debug (l_module_name,'percent='||p_trx_dist_tbl(l_last_dist_id).percent);
        END IF;
      END IF;

      IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
        debug (l_module_name,'l_total_percent(2)='||l_total_percent);
        debug (l_module_name,'l_last_dist_id='||l_last_dist_id);
      END IF;

      IF (l_total_percent <> 100) THEN
        p_trx_dist_tbl(l_last_dist_id).percent := p_trx_dist_tbl(l_last_dist_id).percent + (100-l_total_percent);
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location, p_errbuf);
  END;

  PROCEDURE create_dm
  (
    p_accrue_as_of_date IN DATE,
    p_parent_invoice_id IN NUMBER,
    p_trx_number IN VARCHAR2,
    p_prorate_charge IN VARCHAR2,
    p_invoice_date_type IN VARCHAR,
    p_trx_date IN DATE,
    p_due_date IN DATE,
    p_trx_currency IN VARCHAR2,
    p_trx_type_id IN NUMBER,
    p_gl_date IN DATE,
    p_bill_to_customer_id IN NUMBER,
    p_bill_to_contact_id IN NUMBER,
    p_bill_to_address_id IN NUMBER,
    p_term_id IN NUMBER,
    p_exchange_date IN ra_customer_trx.exchange_date%TYPE,
    p_exchange_rate IN ra_customer_trx.exchange_rate%TYPE,
    p_exchange_rate_type IN ra_customer_trx.exchange_rate_type%TYPE,
    p_root_invoice_id IN NUMBER,
    p_org_id IN NUMBER,
    p_rec_ccid IN NUMBER,
    p_rev_ccid IN NUMBER,
    p_legal_entity_id IN NUMBER,
    p_amount IN NUMBER,
    p_batch_source_id IN NUMBER,
    p_charge_type IN VARCHAR2,
    p_invoice_suffix IN VARCHAR2,
    p_dm_invoice_id OUT NOCOPY NUMBER,
    p_dm_trx_number OUT NOCOPY VARCHAR2,
    p_dm_trx_date OUT NOCOPY DATE,
    p_errbuf   OUT NOCOPY VARCHAR2,
    p_retcode  OUT NOCOPY NUMBER
  )
  IS
    l_module_name              VARCHAR2(200);
    l_location                 VARCHAR2(200);
    l_api_version              CONSTANT NUMBER := 1.0;
    l_batch_source_rec         ar_invoice_api_pub.batch_source_rec_type;
    l_trx_header_tbl           ar_invoice_api_pub.trx_header_tbl_type;
    l_trx_lines_tbl            ar_invoice_api_pub.trx_line_tbl_type;
    l_trx_dist_tbl             ar_invoice_api_pub.trx_dist_tbl_type;
    l_trx_salescredits_tbl     ar_invoice_api_pub.trx_salescredits_tbl_type;
    l_return_status            VARCHAR2(10);
    l_message_count            NUMBER;
    l_message_data             VARCHAR2(1024);
    l_dm_trx_number            ra_customer_trx_all.trx_number%TYPE;
    l_line_counter             NUMBER;
    l_dist_counter             NUMBER;
    l_prorated_line_amount     NUMBER;
    l_line_amount_due          NUMBER;
    l_total_line_amount        NUMBER;

  BEGIN
    l_module_name := g_module_name || 'create_dm';
    p_retcode := g_SUCCESS;
    p_errbuf  := null;

    IF (fnd_log.level_procedure >= g_CURRENT_LOG_LEVEL) THEN
      debug(l_module_name,g_enter);
    END IF;

    IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
      debug (l_module_name,'p_invoice_date_type='||p_invoice_date_type);
      debug (l_module_name,'p_trx_date='||p_trx_date);
      debug (l_module_name,'p_due_date='||p_due_date);
      debug (l_module_name,'p_trx_currency='||p_trx_currency);
      debug (l_module_name,'p_gl_date='||p_gl_date);
      debug (l_module_name,'p_bill_to_customer_id='||p_bill_to_customer_id);
      debug (l_module_name,'p_bill_to_contact_id='||p_bill_to_contact_id);
      debug (l_module_name,'p_bill_to_address_id='||p_bill_to_address_id);
      debug (l_module_name,'p_term_id='||p_term_id);
      debug (l_module_name,'p_exchange_date='||p_exchange_date);
      debug (l_module_name,'p_exchange_rate='||p_exchange_rate);
      debug (l_module_name,'p_exchange_rate_type='||p_exchange_rate_type);
      debug (l_module_name,'p_org_id='||p_org_id);
      debug (l_module_name,'p_rev_ccid='||p_rev_ccid);
      debug (l_module_name,'p_rec_ccid='||p_rec_ccid);
      debug (l_module_name,'p_batch_source_id='||p_batch_source_id);
      debug (l_module_name,'p_legal_entity_id='||p_legal_entity_id);
      debug (l_module_name,'p_invoice_suffix='||p_invoice_suffix);
      debug (l_module_name,'p_amount='||p_amount);
      debug (l_module_name,'p_root_invoice_id='||p_root_invoice_id);
      debug (l_module_name,'p_parent_invoice_id='||p_parent_invoice_id);
    END IF;

    IF (p_invoice_date_type='DUE')  THEN
      p_dm_trx_date  := trunc(p_due_date);
    ELSIF (p_invoice_date_type='ORI') THEN
      p_dm_trx_date := trunc(p_trx_date);
    ELSE
      p_dm_trx_date := trunc(p_accrue_as_of_date);
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      l_batch_source_rec.batch_source_id := p_batch_source_id;
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      BEGIN
        SELECT fv_ra_customer_trx_s.nextval
          INTO l_dm_trx_number
          FROM dual;
      EXCEPTION
        WHEN OTHERS THEN
          p_retcode := g_FAILURE;
          p_errbuf := SQLERRM;
          l_location := l_module_name||'.select_fv_ra_customer_trx_s';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
      END;
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      BEGIN
        SELECT SUM(NVL(rctl.amount_due_remaining, rctl.quantity_invoiced*rctl.unit_selling_price))
          INTO l_total_line_amount
          FROM ra_customer_trx_lines rctl
         WHERE rctl.customer_trx_id = p_parent_invoice_id;
        IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
          debug (l_module_name,'l_total_line_amount='||l_total_line_amount);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          p_retcode := g_FAILURE;
          p_errbuf := SQLERRM;
          l_location := l_module_name||'.select_ra_customer_trx_lines';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
      END;
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      l_trx_header_tbl(1).trx_header_id := 1;
      IF (p_invoice_suffix IS NOT NULL) THEN
        --Bug8922069
        --Debit Memo trx number should be suffixed by the invoice suffix
        --and not be prefixed.
        --l_trx_header_tbl(1).trx_number := p_invoice_suffix||'-';
        l_trx_header_tbl(1).trx_number := '-'||p_invoice_suffix;
      END IF;
      --l_trx_header_tbl(1).trx_number := l_trx_header_tbl(1).trx_number||l_dm_trx_number;
      l_trx_header_tbl(1).trx_number := l_dm_trx_number||l_trx_header_tbl(1).trx_number;
      p_dm_trx_number := l_trx_header_tbl(1).trx_number;
      l_trx_header_tbl(1).trx_date := p_dm_trx_date;
      l_trx_header_tbl(1).trx_currency := p_trx_currency;
      l_trx_header_tbl(1).trx_class := 'DM';
      l_trx_header_tbl(1).cust_trx_type_id := p_trx_type_id;
      l_trx_header_tbl(1).gl_date := p_gl_date;
      l_trx_header_tbl(1).bill_to_customer_id := p_bill_to_customer_id;
      l_trx_header_tbl(1).bill_to_contact_id := p_bill_to_contact_id;
      l_trx_header_tbl(1).bill_to_address_id := p_bill_to_address_id;
      l_trx_header_tbl(1).term_id := p_term_id;
      l_trx_header_tbl(1).exchange_rate_type := p_exchange_rate_type;
      l_trx_header_tbl(1).exchange_date := p_exchange_date;
      l_trx_header_tbl(1).exchange_rate := p_exchange_rate;
      --l_trx_header_tbl(1).related_customer_trx_id := p_root_invoice_id;
      l_trx_header_tbl(1).org_id := p_org_id;
      l_trx_header_tbl(1).legal_entity_id := p_legal_entity_id;
    END IF;

    IF (p_prorate_charge IN ('L', 'D')) THEN
      l_line_counter := 0;
      l_dist_counter := 0;

      FOR inv_dist_rec IN (SELECT *
                             FROM ra_cust_trx_line_gl_dist rctl
                            WHERE rctl.customer_trx_id = p_parent_invoice_id
                              AND rctl.customer_trx_line_id IS NULL) LOOP
        l_dist_counter := l_dist_counter + 1;
        l_trx_dist_tbl(l_dist_counter).trx_header_id := 1;
        l_trx_dist_tbl(l_dist_counter).trx_line_id := NULL;
        l_trx_dist_tbl(l_dist_counter).trx_dist_id := l_dist_counter;
        l_trx_dist_tbl(l_dist_counter).account_class := 'REC';
        l_trx_dist_tbl(l_dist_counter).amount := p_amount;
        --Currently AR allows only one Receivable line so putting the percent
        --at 100.
        l_trx_dist_tbl(l_dist_counter).percent := 100;
        l_trx_dist_tbl(l_dist_counter).code_combination_id := inv_dist_rec.code_combination_id;
        IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
          debug (l_module_name,'** DIST BEGIN **');
          debug (l_module_name,'trx_header_id='||l_trx_dist_tbl(l_dist_counter).trx_header_id);
          debug (l_module_name,'trx_line_id='||l_trx_dist_tbl(l_dist_counter).trx_line_id);
          debug (l_module_name,'trx_dist_id='||l_trx_dist_tbl(l_dist_counter).trx_dist_id);
          debug (l_module_name,'account_class='||l_trx_dist_tbl(l_dist_counter).account_class);
          debug (l_module_name,'amount='||l_trx_dist_tbl(l_dist_counter).amount);
          debug (l_module_name,'percent='||l_trx_dist_tbl(l_dist_counter).percent);
          debug (l_module_name,'code_combination_id='||l_trx_dist_tbl(l_dist_counter).code_combination_id);
          debug (l_module_name,'** DIST ENDS **');
        END IF;
      END LOOP;

      IF (p_prorate_charge = 'L') THEN
        FOR inv_lines_rec IN (SELECT *
                                FROM ra_customer_trx_lines rctl
                               WHERE rctl.customer_trx_id = p_parent_invoice_id) LOOP
          IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
            debug (l_module_name,'inv_lines_rec.amount_due_remaining='||inv_lines_rec.amount_due_remaining);
            debug (l_module_name,'inv_lines_rec.quantity_invoiced='||inv_lines_rec.quantity_invoiced);
            debug (l_module_name,'inv_lines_rec.unit_selling_price='||inv_lines_rec.unit_selling_price);
          END IF;
          l_line_amount_due := NVL(inv_lines_rec.amount_due_remaining, (inv_lines_rec.quantity_invoiced*inv_lines_rec.unit_selling_price));
          IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
            debug (l_module_name,'l_line_amount_due='||l_line_amount_due);
            debug (l_module_name,'l_total_line_amount='||l_total_line_amount);
            debug (l_module_name,'p_amount='||p_amount);
          END IF;
          l_prorated_line_amount := ROUND((l_line_amount_due/l_total_line_amount), 2)*p_amount;
          IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
            debug (l_module_name,'l_prorated_line_amount='||l_prorated_line_amount);
          END IF;
          l_line_counter := l_line_counter + 1;
          l_trx_lines_tbl(l_line_counter).trx_header_id := 1;
          l_trx_lines_tbl(l_line_counter).trx_line_id := l_line_counter;
          l_trx_lines_tbl(l_line_counter).line_number := l_line_counter;
          l_trx_lines_tbl(l_line_counter).description := 'Accrue Federal Finance Charges';
          l_trx_lines_tbl(l_line_counter).line_type := 'LINE';
          l_trx_lines_tbl(l_line_counter).uom_code := 'EA';
          l_trx_lines_tbl(l_line_counter).quantity_invoiced := 1;
          l_trx_lines_tbl(l_line_counter).amount := l_prorated_line_amount;
          l_trx_lines_tbl(l_line_counter).unit_selling_price := l_prorated_line_amount;

          IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
            debug (l_module_name,'** LINES BEGIN **');
            debug (l_module_name,'trx_header_id='||l_trx_lines_tbl(l_line_counter).trx_header_id);
            debug (l_module_name,'trx_line_id='||l_trx_lines_tbl(l_line_counter).trx_line_id);
            debug (l_module_name,'line_number='||l_trx_lines_tbl(l_line_counter).line_number);
            debug (l_module_name,'description='||l_trx_lines_tbl(l_line_counter).description);
            debug (l_module_name,'line_type='||l_trx_lines_tbl(l_line_counter).line_type);
            debug (l_module_name,'uom_code='||l_trx_lines_tbl(l_line_counter).uom_code);
            debug (l_module_name,'quantity_invoiced='||l_trx_lines_tbl(l_line_counter).quantity_invoiced);
            debug (l_module_name,'amount='||l_trx_lines_tbl(l_line_counter).amount);
            debug (l_module_name,'unit_selling_price='||l_trx_lines_tbl(l_line_counter).unit_selling_price);
            debug (l_module_name,'** LINES END **');
          END IF;

          FOR inv_dist_rec IN (SELECT *
                                 FROM ra_cust_trx_line_gl_dist rctl
                                WHERE rctl.customer_trx_id = p_parent_invoice_id
                                  AND rctl.customer_trx_line_id = inv_lines_rec.customer_trx_line_id) LOOP
            l_dist_counter := l_dist_counter + 1;
            IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
              debug (l_module_name,'REC');
              debug (l_module_name,'inv_dist_rec.percent='||inv_dist_rec.percent);
              debug (l_module_name,'l_prorated_line_amount='||l_prorated_line_amount);
              debug (l_module_name,'amount='||(l_prorated_line_amount*inv_dist_rec.percent)/100);
            END IF;
            l_trx_dist_tbl(l_dist_counter).trx_dist_id := l_dist_counter;
            l_trx_dist_tbl(l_dist_counter).trx_header_id := 1;
            l_trx_dist_tbl(l_dist_counter).trx_line_id := l_line_counter;
            l_trx_dist_tbl(l_dist_counter).account_class := 'REV';
            l_trx_dist_tbl(l_dist_counter).amount:= ROUND((l_prorated_line_amount*inv_dist_rec.percent)/100,2);

            --l_trx_dist_tbl(l_dist_counter).percent := NULL;
            l_trx_dist_tbl(l_dist_counter).percent := inv_dist_rec.percent;

            l_trx_dist_tbl(l_dist_counter).code_combination_id := inv_dist_rec.code_combination_id;
            IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
              debug (l_module_name,'** DIST BEGIN **');
              debug (l_module_name,'trx_header_id='||l_trx_dist_tbl(l_dist_counter).trx_header_id);
              debug (l_module_name,'trx_line_id='||l_trx_dist_tbl(l_dist_counter).trx_line_id);
              debug (l_module_name,'trx_dist_id='||l_trx_dist_tbl(l_dist_counter).trx_dist_id);
              debug (l_module_name,'account_class='||l_trx_dist_tbl(l_dist_counter).account_class);
              debug (l_module_name,'amount='||l_trx_dist_tbl(l_dist_counter).amount);
              debug (l_module_name,'percent='||l_trx_dist_tbl(l_dist_counter).percent);
              debug (l_module_name,'code_combination_id='||l_trx_dist_tbl(l_dist_counter).code_combination_id);
              debug (l_module_name,'** DIST ENDS **');
            END IF;
          END LOOP;
        END LOOP;
      ELSE -- It is D
        l_line_counter := l_line_counter + 1;
        l_trx_lines_tbl(l_line_counter).trx_header_id := 1;
        l_trx_lines_tbl(l_line_counter).trx_line_id := l_line_counter;
        l_trx_lines_tbl(l_line_counter).line_number := l_line_counter;
        l_trx_lines_tbl(l_line_counter).description := 'Accrue Federal Finance Charges';
        l_trx_lines_tbl(l_line_counter).line_type := 'LINE';
        l_trx_lines_tbl(l_line_counter).uom_code := 'EA';
        l_trx_lines_tbl(l_line_counter).quantity_invoiced := 1;
        l_trx_lines_tbl(l_line_counter).amount := p_amount;
        l_trx_lines_tbl(l_line_counter).unit_selling_price := p_amount;

        IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
          debug (l_module_name,'** LINES BEGIN **');
          debug (l_module_name,'trx_header_id='||l_trx_lines_tbl(l_line_counter).trx_header_id);
          debug (l_module_name,'trx_line_id='||l_trx_lines_tbl(l_line_counter).trx_line_id);
          debug (l_module_name,'line_number='||l_trx_lines_tbl(l_line_counter).line_number);
          debug (l_module_name,'description='||l_trx_lines_tbl(l_line_counter).description);
          debug (l_module_name,'line_type='||l_trx_lines_tbl(l_line_counter).line_type);
          debug (l_module_name,'uom_code='||l_trx_lines_tbl(l_line_counter).uom_code);
          debug (l_module_name,'quantity_invoiced='||l_trx_lines_tbl(l_line_counter).quantity_invoiced);
          debug (l_module_name,'amount='||l_trx_lines_tbl(l_line_counter).amount);
          debug (l_module_name,'unit_selling_price='||l_trx_lines_tbl(l_line_counter).unit_selling_price);
          debug (l_module_name,'** LINES END **');
        END IF;

        SELECT SUM(amount)
          INTO l_total_line_amount
          FROM ra_cust_trx_line_gl_dist rctl
         WHERE rctl.customer_trx_id = p_parent_invoice_id
           AND rctl.customer_trx_line_id IS NOT NULL;


        FOR inv_dist_rec IN (SELECT code_combination_id,
                                    sum (amount) amount,
                                    ROUND(sum (amount)/l_total_line_amount, 4) percent
                               FROM ra_cust_trx_line_gl_dist rctl
                              WHERE rctl.customer_trx_id = p_parent_invoice_id
                                AND rctl.customer_trx_line_id IS NOT NULL
                              GROUP BY code_combination_id
                              ORDER BY code_combination_id) LOOP

          l_dist_counter := l_dist_counter + 1;
          IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
            debug (l_module_name,'REC');
            debug (l_module_name,'inv_dist_rec.percent='||inv_dist_rec.percent);
            debug (l_module_name,'amount='||inv_dist_rec.amount);
          END IF;
          l_trx_dist_tbl(l_dist_counter).trx_dist_id := l_dist_counter;
          l_trx_dist_tbl(l_dist_counter).trx_header_id := 1;
          l_trx_dist_tbl(l_dist_counter).trx_line_id := l_line_counter;
          l_trx_dist_tbl(l_dist_counter).account_class := 'REV';
          l_trx_dist_tbl(l_dist_counter).amount:= p_amount*inv_dist_rec.percent;

          --l_trx_dist_tbl(l_dist_counter).percent := NULL;
          l_trx_dist_tbl(l_dist_counter).percent := inv_dist_rec.percent*100;

          l_trx_dist_tbl(l_dist_counter).code_combination_id := inv_dist_rec.code_combination_id;
          IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
            debug (l_module_name,'** DIST BEGIN **');
            debug (l_module_name,'trx_header_id='||l_trx_dist_tbl(l_dist_counter).trx_header_id);
            debug (l_module_name,'trx_line_id='||l_trx_dist_tbl(l_dist_counter).trx_line_id);
            debug (l_module_name,'trx_dist_id='||l_trx_dist_tbl(l_dist_counter).trx_dist_id);
            debug (l_module_name,'account_class='||l_trx_dist_tbl(l_dist_counter).account_class);
            debug (l_module_name,'amount='||l_trx_dist_tbl(l_dist_counter).amount);
            debug (l_module_name,'percent='||l_trx_dist_tbl(l_dist_counter).percent);
            debug (l_module_name,'code_combination_id='||l_trx_dist_tbl(l_dist_counter).code_combination_id);
            debug (l_module_name,'** DIST ENDS **');
          END IF;
        END LOOP;
      END IF;
      IF (p_retcode = g_SUCCESS) THEN
        check_and_correct_rounding
        (
          p_amount         => p_amount,
          p_trx_header_tbl => l_trx_header_tbl,
          p_trx_lines_tbl  => l_trx_lines_tbl,
          p_trx_dist_tbl   => l_trx_dist_tbl,
          p_errbuf         => p_errbuf,
          p_retcode        => p_retcode
        );
      END IF;
    ELSE
      l_trx_lines_tbl(1).trx_header_id := 1;
      l_trx_lines_tbl(1).trx_line_id := 1;
      l_trx_lines_tbl(1).line_number := 1;
      l_trx_lines_tbl(1).description := 'Accrue Federal Finance Charges';
      l_trx_lines_tbl(1).line_type := 'LINE';
      l_trx_lines_tbl(1).uom_code := 'EA';
      l_trx_lines_tbl(1).quantity_invoiced := 1;
      l_trx_lines_tbl(1).amount := p_amount;
      l_trx_lines_tbl(1).unit_selling_price := p_amount;

      l_trx_dist_tbl(1).trx_dist_id := 1;
      l_trx_dist_tbl(1).trx_header_id := 1;
      l_trx_dist_tbl(1).trx_line_id := NULL;
      l_trx_dist_tbl(1).account_class := 'REC';
      l_trx_dist_tbl(1).amount:= p_amount;
      l_trx_dist_tbl(1).percent := 100;
      l_trx_dist_tbl(1).code_combination_id := p_rec_ccid;

      l_trx_dist_tbl(2).trx_dist_id := 2;
      l_trx_dist_tbl(2).trx_header_id := 1;
      l_trx_dist_tbl(2).trx_line_id := 1;
      l_trx_dist_tbl(2).account_class := 'REV';
      l_trx_dist_tbl(2).amount := p_amount;
      l_trx_dist_tbl(2).percent := NULL;
      l_trx_dist_tbl(2).code_combination_id := p_rev_ccid;
    END IF;


    IF (p_retcode = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
        debug (l_module_name,'Calling ar_invoice_api_pub.create_single_invoice');
      END IF;

      ar_invoice_api_pub.create_single_invoice
      (
        p_api_version          => l_api_version,
        p_init_msg_list        => FND_API.G_TRUE,
        p_commit               => FND_API.G_FALSE,
        p_batch_source_rec     => l_batch_source_rec,
        p_trx_header_tbl       => l_trx_header_tbl,
        p_trx_lines_tbl        => l_trx_lines_tbl,
        p_trx_dist_tbl         => l_trx_dist_tbl,
        p_trx_salescredits_tbl => l_trx_salescredits_tbl,
        x_customer_trx_id      => p_dm_invoice_id,
        x_return_status        => l_return_status,
        x_msg_count            => l_message_count,
        x_msg_data             => l_message_data
      );

      IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
        debug (l_module_name,'l_return_status='||l_return_status);
        debug (l_module_name,'l_message_count='||l_message_count);
        debug (l_module_name,'l_message_data='||l_message_data);
        debug (l_module_name,'p_dm_invoice_id='||p_dm_invoice_id);
      END IF;

      interpret_dm_error
      (
        p_trx_number    => p_trx_number,
        p_return_status => l_return_status,
        p_message_count => l_message_count,
        p_message_data  => l_message_data,
        p_errbuf        => p_errbuf,
        p_retcode       => p_retcode
      );
    END IF;


    IF (p_retcode = g_SUCCESS) THEN
      -- There is no way to put p_related_invoice_id in the API
      -- as it is giving an error. For the time being as a
      -- workaround updating the filed directly.
      BEGIN
      UPDATE ra_customer_trx rct
         SET rct.related_customer_trx_id = p_root_invoice_id,
             rct.interface_header_attribute3 = p_charge_type
       WHERE rct.customer_trx_id = p_dm_invoice_id;
      EXCEPTION
        WHEN OTHERS THEN
          p_retcode := g_FAILURE;
          p_errbuf := SQLERRM;
          l_location := l_module_name||'.update_ra_customer_trx';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
      END;
    END IF;


  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location, p_errbuf);
  END create_dm;

  PROCEDURE process_and_create_dm
  (
    p_org_id IN NUMBER,
    p_set_of_books_id IN NUMBER,
    p_accrue_as_of_date IN DATE,
    p_finance_charges IN NUMBER,
    p_invoice_id IN NUMBER,
    p_customer_id IN NUMBER,
    p_trx_number IN VARCHAR2,
    p_trx_date IN DATE,
    p_charge_id IN NUMBER,
    p_finance_charge_group_hdr_id IN NUMBER,
    p_finance_charge_group_dtl_id IN NUMBER,
    p_invoice_currency_code IN VARCHAR2,
    p_trx_type_id IN NUMBER,
    p_gl_date IN DATE,
    p_bill_to_customer_id IN NUMBER,
    p_bill_to_contact_id IN NUMBER,
    p_bill_to_address_id IN NUMBER,
    p_invoice_due_date IN DATE,
    p_exchange_date IN ra_customer_trx.exchange_date%TYPE,
    p_exchange_rate IN ra_customer_trx.exchange_rate%TYPE,
    p_exchange_rate_type IN ra_customer_trx.exchange_rate_type%TYPE,
    p_root_invoice_id IN NUMBER,
    p_invoice_date_type IN VARCHAR2,
    p_immediate_term_id IN NUMBER,
    p_invoice_term_id IN NUMBER,
    p_gl_id_rec IN NUMBER,
    p_gl_id_rev IN NUMBER,
    p_prorate_charge IN VARCHAR2,
    p_batch_source_id IN NUMBER,
    p_inv_amount_due_remaining IN NUMBER,
    p_inv_amount_due_original IN NUMBER,
    p_charge_type IN VARCHAR2,
    p_invoice_suffix IN VARCHAR2,
    p_errbuf   OUT NOCOPY VARCHAR2,
    p_retcode  OUT NOCOPY NUMBER
  )
  IS
    l_module_name              VARCHAR2(200);
    l_location                 VARCHAR2(200);
    l_term_id                  NUMBER;
    l_dm_invoice_id            NUMBER;
    l_dm_trx_number            ra_customer_trx_all.trx_number%TYPE;
    l_dm_trx_date              ra_customer_trx_all.trx_date%TYPE;
    l_root_invoice_id          NUMBER;
  BEGIN
    l_module_name := g_module_name || 'process_and_create_dm';
    p_retcode := g_SUCCESS;
    p_errbuf  := null;

    -- There are finance charges. Hence a DM has to be created.
    IF (NVL(p_root_invoice_id, 0) = 0) THEN
      l_root_invoice_id := p_invoice_id;
    ELSE
      l_root_invoice_id := p_root_invoice_id;
    END IF;

    IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
      debug(l_module_name,'Calling create_dm');
    END IF;

    l_term_id := p_immediate_term_id;
    IF (p_invoice_date_type='ORI') THEN
      l_term_id := p_invoice_term_id;
    END IF;

    create_dm
    (
      p_accrue_as_of_date   => p_accrue_as_of_date,
      p_parent_invoice_id   => p_invoice_id,
      p_trx_number          => p_trx_number,
      p_prorate_charge      => p_prorate_charge,
      p_invoice_date_type   => p_invoice_date_type,
      p_trx_date            => p_trx_date,
      p_due_date            => p_invoice_due_date,
      p_trx_currency        => p_invoice_currency_code,
      p_trx_type_id         => p_trx_type_id,
      p_gl_date             => p_gl_date,
      p_bill_to_customer_id => p_bill_to_customer_id,
      p_bill_to_contact_id  => p_bill_to_contact_id,
      p_bill_to_address_id  => p_bill_to_address_id,
      p_term_id             => l_term_id,
      p_exchange_date       => p_exchange_date,
      p_exchange_rate       => p_exchange_rate,
      p_exchange_rate_type  => p_exchange_rate_type,
      p_root_invoice_id     => l_root_invoice_id,
      p_org_id              => p_org_id,
      p_rec_ccid            => p_gl_id_rec,
      p_rev_ccid            => p_gl_id_rev,
      p_legal_entity_id     => NULL,
      p_amount              => p_finance_charges,
      p_batch_source_id     => p_batch_source_id,
      p_charge_type         => p_charge_type,
      p_invoice_suffix      => p_invoice_suffix,
      p_dm_invoice_id       => l_dm_invoice_id,
      p_dm_trx_number       => l_dm_trx_number,
      p_dm_trx_date         => l_dm_trx_date,
      p_errbuf              => p_errbuf,
      p_retcode             => p_retcode
    );

    IF (p_retcode = g_SUCCESS) THEN
      BEGIN
        IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
          debug(l_module_name,'Insert fv_ar_fin_chrg_invoices');
        END IF;
        INSERT INTO fv_ar_fin_chrg_invoices
        (
          org_id,
          customer_id,
          invoice_id,
          invoice_number,
          invoice_date,
          invoice_amount,
          finance_charges,
          waive_flag,
          enabled_flag,
          parent_invoice_id,
          root_invoice_id,
          last_update_date,
          last_updated_by,
          created_by,
          creation_date,
          last_update_login,
          request_id,
          finance_charge_group_hdr_id,
          finance_charge_group_dtl_id,
          charge_id
        )
        VALUES
        (
          p_org_id,
          p_customer_id,
          l_dm_invoice_id,
          l_dm_trx_number,
          l_dm_trx_date,
          p_finance_charges,
          0,
          'N',
          'Y',
          p_invoice_id,
          l_root_invoice_id,
          SYSDATE,
          g_user_id,
          g_user_id,
          SYSDATE,
          g_login_id,
          g_request_id,
          p_finance_charge_group_hdr_id,
          p_finance_charge_group_dtl_id,
          p_charge_id
        );
      EXCEPTION
        WHEN OTHERS THEN
          p_retcode := g_FAILURE;
          p_errbuf := SQLERRM;
          l_location := l_module_name||'.insert_fv_ar_fin_chrg_invoices';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
      END;
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      BEGIN
        IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
          debug(l_module_name,'Insert fv_ar_fin_chrg_inv_lines');
        END IF;
        INSERT INTO fv_ar_fin_chrg_inv_lines
        (
          org_id,
          customer_id,
          invoice_id,
          line_number,
          gl_date,
          line_amount,
          last_update_date,
          last_updated_by,
          created_by,
          creation_date,
          last_update_login,
          request_id,
          finance_charge_group_hdr_id,
          finance_charge_group_dtl_id,
          charge_id
        )
        SELECT rctl.org_id,
               p_customer_id,
               rctl.customer_trx_id,
               rctl.line_number,
               p_gl_date,
               rctl.quantity_invoiced*rctl.unit_selling_price,
               SYSDATE,
               g_user_id,
               g_user_id,
               SYSDATE,
               g_login_id,
               g_request_id,
               p_finance_charge_group_hdr_id,
               p_finance_charge_group_dtl_id,
               p_charge_id
          FROM ra_customer_trx_lines rctl
         WHERE rctl.customer_trx_id = l_dm_invoice_id;
      EXCEPTION
        WHEN OTHERS THEN
          p_retcode := g_FAILURE;
          p_errbuf := SQLERRM;
          l_location := l_module_name||'.insert_fv_ar_fin_chrg_inv_lines';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
      END;
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
        debug(l_module_name,'Updating fv_ar_fin_chrg_invoices(1)');
      END IF;

      BEGIN
        UPDATE fv_ar_fin_chrg_invoices
           SET request_id=g_request_id,
               last_updated_by = g_user_id,
               last_update_date = SYSDATE,
               last_accrual_date = p_accrue_as_of_date,
               finance_charges = NVL(finance_charges, 0) + p_finance_charges,
               current_child_invoice_id = l_dm_invoice_id, --can be used in future for adjusting
               last_line_number = 1 --can be used in future for adjusting
         WHERE invoice_id = p_invoice_id;

          /* Bug 8515997: If p_invoice_id=l_root_invoice_id, then finance charges get doubled. Added condition to check it */
          IF (l_root_invoice_id <> p_invoice_id) THEN
            UPDATE fv_ar_fin_chrg_invoices
               SET last_updated_by = g_user_id,
                   last_update_date = SYSDATE,
                   finance_charges = NVL(finance_charges, 0) + p_finance_charges
             WHERE invoice_id = l_root_invoice_id;
          END IF;

      IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
        debug(l_module_name,'Updated '||SQL%ROWCOUNT||' rows.');
      END IF;
      EXCEPTION
        WHEN OTHERS THEN
          p_retcode := g_FAILURE;
          p_errbuf := SQLERRM;
          l_location := l_module_name||'.update_fv_ar_fin_chrg_invoices (1)';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
      END;
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      FOR dm_rec IN (SELECT fcgd.base_charge_id,
                            fcgd.assessed_charge_id
                       FROM fv_finance_charge_grp_dtls fcgd,
                            fv_finance_charge_grp_hdrs fcgh
                      WHERE fcgh.finance_charge_group_hdr_id = p_finance_charge_group_hdr_id
                        AND fcgd.finance_charge_group_hdr_id = fcgh.finance_charge_group_hdr_id
                        AND fcgd.base_charge_id = p_charge_id
                        AND fcgd.start_date <= sysdate
                        AND decode(fcgd.end_date,null,sysdate,fcgd.end_date) >= sysdate
                        ) LOOP
        BEGIN
          INSERT INTO fv_invoice_finance_chrgs_all
          (
            customer_trx_id,
            customer_id,
            charge_id,
            set_of_books_id,
            last_update_date,
            last_updated_by,
            created_by,
            creation_date,
            last_update_login,
            waive_flag,
            org_id,
            finance_charge_group_hdr_id,
            finance_charge_group_dtl_id,
            enabled_flag,
            base_charge_id,
            request_id
          )
          VALUES
          (
            l_dm_invoice_id,
            p_customer_id,
            dm_rec.assessed_charge_id,
            p_set_of_books_id,
            SYSDATE,
            g_user_id,
            g_user_id,
            SYSDATE,
            g_login_id,
            'N',
            p_org_id,
            p_finance_charge_group_hdr_id,
            p_finance_charge_group_dtl_id,
            'Y',
            dm_rec.base_charge_id,
            g_request_id
          );
        EXCEPTION
          WHEN OTHERS THEN
            p_retcode := g_FAILURE;
            p_errbuf := SQLERRM;
            l_location := l_module_name||'.insert_fv_invoice_finance_chrgs';
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
        END;
      END LOOP;
    END IF;

    IF (fnd_log.level_procedure >= g_CURRENT_LOG_LEVEL) THEN
      debug(l_module_name,g_enter);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location, p_errbuf);
  END process_and_create_dm;

  PROCEDURE get_cvf_rate
  (
    p_accrue_as_of_date IN  DATE,
    p_cvf_rate          OUT NOCOPY NUMBER,
    p_errbuf            OUT NOCOPY VARCHAR2,
    p_retcode           OUT NOCOPY NUMBER
  )
  IS
    l_module_name VARCHAR2(200);
    l_location    VARCHAR2(200);
  BEGIN
    l_module_name := g_module_name || 'get_cvf_rate';
    p_retcode := g_SUCCESS;
    p_errbuf  := NULL;
    p_cvf_rate := NULL;

    IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
      debug(l_module_name,'Inside '||l_module_name);
      debug(l_module_name,'p_accrue_as_of_date '||p_accrue_as_of_date);
    END IF;
    BEGIN
      SELECT a.curr_value_of_funds_percent
        INTO p_cvf_rate
        FROM fv_value_of_fund_periods a
       WHERE p_accrue_as_of_date BETWEEN a.effective_start_date AND NVL(a.effective_end_date, g_hi_date);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_cvf_rate := NULL;
    END;

  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      debug(l_module_name,'l_location='||l_location);
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location, p_errbuf);
  END get_cvf_rate;

  PROCEDURE get_last_accrual_date
  (
    p_payment_schedule_id IN NUMBER,
    p_charge_type         IN VARCHAR2,
    p_last_accrual_date   OUT NOCOPY DATE,
    p_errbuf              OUT NOCOPY VARCHAR2,
    p_retcode             OUT NOCOPY NUMBER
  )
  IS
    l_module_name VARCHAR2(200);
    l_location    VARCHAR2(200);
  BEGIN
    l_module_name := g_module_name || 'get_last_accrual_date';
    p_retcode := g_SUCCESS;
    p_errbuf  := NULL;
    p_last_accrual_date := NULL;

    IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
      debug(l_module_name,'Inside '||l_module_name);
      debug(l_module_name,'p_payment_schedule_id '||p_payment_schedule_id);
      debug(l_module_name,'p_charge_type '||p_charge_type);
    END IF;
    BEGIN
      SELECT a.last_accrual_date
        INTO p_last_accrual_date
        FROM fv_ar_controls a
       WHERE a.payment_schedule_id = p_payment_schedule_id
         AND a.created_from = p_charge_type;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_last_accrual_date := NULL;
    END;

  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      debug(l_module_name,'l_location='||l_location);
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location, p_errbuf);
  END get_last_accrual_date;

  PROCEDURE set_last_accrual_date
  (
    p_org_id              IN NUMBER,
    p_payment_schedule_id IN NUMBER,
    p_charge_type         IN VARCHAR2,
    p_last_accrual_date   IN DATE,
    p_errbuf              OUT NOCOPY VARCHAR2,
    p_retcode             OUT NOCOPY NUMBER
  )
  IS
    l_module_name VARCHAR2(200);
    l_location    VARCHAR2(200);
  BEGIN
    l_module_name := g_module_name || 'set_last_accrual_date';
    p_retcode := g_SUCCESS;
    p_errbuf  := NULL;

    IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
      debug(l_module_name,'Inside '||l_module_name);
      debug(l_module_name,'p_org_id '||p_org_id);
      debug(l_module_name,'p_payment_schedule_id '||p_payment_schedule_id);
      debug(l_module_name,'p_charge_type '||p_charge_type);
      debug(l_module_name,'p_last_accrual_date '||p_last_accrual_date);
    END IF;

    UPDATE fv_ar_controls a
       SET last_accrual_date = p_last_accrual_date
     WHERE a.payment_schedule_id = p_payment_schedule_id
       AND a.created_from = p_charge_type;

    IF (SQL%ROWCOUNT = 0) THEN
      INSERT INTO fv_ar_controls
      (
        payment_schedule_id,
        created_from,
        last_accrual_date,
        org_id
      )
      VALUES
      (
        p_payment_schedule_id,
        p_charge_type,
        p_last_accrual_date,
        p_org_id
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      debug(l_module_name,'l_location='||l_location);
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location, p_errbuf);
  END set_last_accrual_date;

----------------------------------------------------------------------------------------------

/*****************************************************************************/
/*                      Begin Accrue Finance Charge Process                  */
/*****************************************************************************/
  PROCEDURE accrue_finance_charge
  (
    p_errbuf             OUT NOCOPY VARCHAR2,
    p_retcode            OUT NOCOPY NUMBER,
    p_invoice_date_type  VARCHAR2,
    p_gl_date            VARCHAR2
  ) IS
    l_module_name                VARCHAR2(200);
    l_location                   VARCHAR2(200);
    l_message                    VARCHAR2(1024);
    l_gl_date                    DATE;
    l_old_charge_id              fv_finance_charge_controls.charge_id%TYPE;
    l_old_invoice_id             ra_customer_trx.customer_trx_id%TYPE;
    l_accrue_as_of_date          DATE;
    l_accrual_date               DATE;
    l_finance_charges            NUMBER;
    l_immediate_term_id          NUMBER;
    l_number_of_periods          NUMBER;
    l_first_late_day             DATE;
    l_inv_amount_due_original    NUMBER;
    l_inv_amount_due_remaining   NUMBER;
    l_cvf_rate                   NUMBER;

  BEGIN
    l_module_name := g_module_name || 'assign_finance_charge';
    p_retcode := g_SUCCESS;
    p_errbuf  := NULL;
    l_accrue_as_of_date := TRUNC(SYSDATE);
    IF (fnd_log.level_procedure >= g_CURRENT_LOG_LEVEL) THEN
      debug(l_module_name,g_enter);
    END IF;

    IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
      debug(l_module_name,'p_invoice_date_type='||p_invoice_date_type);
      debug(l_module_name,'p_gl_date='||p_gl_date);
    END IF;


    l_gl_date:= TO_DATE(p_gl_date,'YYYY/MM/DD HH24:MI:SS');

    initialize_program_variables
    (
      p_gl_date => l_gl_date,
      p_term_id => l_immediate_term_id,
      p_errbuf  => p_errbuf,
      p_retcode => p_retcode
    );

    IF (p_retcode = g_SUCCESS) THEN
      IF (p_retcode = g_SUCCESS) THEN
        IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
          debug(l_module_name,'Calling get_cvf_rate');
        END IF;
        /*
          Get the Current Value of Fund rate as this is not going to change
          per Invoice.
        */
        get_cvf_rate
        (
          p_accrue_as_of_date => l_accrue_as_of_date,
          p_cvf_rate          => l_cvf_rate,
          p_errbuf            => p_errbuf,
          p_retcode           => p_retcode
        );
        IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
          debug(l_module_name,'p_cvf_rate ='||l_cvf_rate);
        END IF;
      END IF;
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
        debug(l_module_name,'main_rec');
      END IF;
      FOR main_rec IN (SELECT aps.customer_trx_id invoice_id,
                              aps.amount_due_remaining,
                              aps.amount_due_original,
                              aps.payment_schedule_id,
                              fcc.charge_id,
                              fcc.charge_type,
                              fcc.batch_source_id,
                              aps.trx_number,
                              aps.due_date,
                              nvl(fch.amount, nvl(fch.rate,0)/100) rate_amount,
                              decode(fch.amount, NULL, 'Y', 'N') rate_flag,
                              fch.rate_base,
                              fch.rate_type,
                              nvl(fcc.accrue_at_invoice,'N') accrue_at_invoice,
                              fcc.trx_type_id,
                              fcc.first_accrual,
                              fcc.accrual_interval,
                              fcc.grace_period,
                              fcc.receivables_trx_id,
                              rct.bill_to_customer_id,
                              rct.bill_to_contact_id,
                              rct.invoice_currency_code,
                              rct.exchange_date,
                              rct.exchange_rate,
                              rct.exchange_rate_type,
                              aps.trx_date,
                              rctt.gl_id_rev,
                              rctt.gl_id_rec,
                              rsua.cust_acct_site_id bill_to_address_id,
                              fai.last_accrual_date,
                              fcc.base_date_type,
                              fai.root_invoice_id,
                              rct.org_id,
                              rct.term_id,
                              fifc.customer_id,
                              fifc.set_of_books_id,
                              fifc.finance_charge_group_hdr_id,
                              fifc.finance_charge_group_dtl_id,
                              NVL(fcc.prorate_charge, 'N') prorate_charge,
                              fcc.invoice_suffix
                         FROM ar_payment_schedules aps,
                              fv_invoice_finance_chrgs fifc,
                              fv_finance_charge_controls fcc,
                              fv_finance_charge_history fch,
                              ra_customer_trx rct,
                              ra_cust_trx_types rctt,
                              hz_cust_site_uses_all rsua,
                              fv_ar_fin_chrg_invoices fai
                        WHERE (due_date + first_accrual + grace_period) <= l_accrue_as_of_date
                          AND fifc.waive_flag = 'N'
                          AND aps.amount_due_remaining > 0
                          AND aps.status <> 'CL'
                          AND aps.customer_trx_id = rct.customer_trx_id

                         /* AND nvl(rct.interface_header_attribute3,'XX') NOT IN (SELECT charge_type
                                                                                  FROM fv_finance_charge_controls)*/

                          AND rct.set_of_books_id = g_set_of_books_id
                          AND aps.customer_trx_id = fifc.customer_trx_id
                          AND fifc.charge_id = fcc.charge_id
                          AND fcc.charge_id = fch.charge_id
                          AND fcc.enabled_flag = 'Y'
                          AND l_accrue_as_of_date  BETWEEN fch.start_date AND nvl(fch.end_date,to_date('31-12-4712','DD-MM-YYYY')) --Bug 8826086
                          AND rctt.cust_trx_type_id = fcc.trx_type_id
                          AND rsua.site_use_id = rct.bill_to_site_use_id
                          AND fai.invoice_id = fifc.customer_trx_id
                          AND EXISTS ( SELECT 'x'
                                         FROM fv_finance_chrg_cust_classes fccc,
                                              fv_finance_charge_grp_dtls fcgd,
                                              hz_cust_accounts hzca
                                        WHERE fccc.customer_class = hzca.customer_class_code
                                          AND fccc.enabled_flag = 'Y'
                                          AND fccc.finance_charge_group_hdr_id = fcgd.finance_charge_group_hdr_id
                                          AND fcgd.assessed_charge_id = fcc.charge_id
                                          AND set_of_books_id = g_set_of_books_id)
                        ORDER BY rct.customer_trx_id,
                                 fcc.charge_id,
                                 aps.payment_schedule_id)
      LOOP
        IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
          debug(l_module_name,'************************************************************');
          debug(l_module_name,'main_rec.invoice_id='||main_rec.invoice_id);
          debug(l_module_name,'main_rec.amount_due_remaining='||main_rec.amount_due_remaining);
          debug(l_module_name,'main_rec.payment_schedule_id='||main_rec.payment_schedule_id);
          debug(l_module_name,'main_rec.charge_id='||main_rec.charge_id);
          debug(l_module_name,'main_rec.charge_type='||main_rec.charge_type);
          debug(l_module_name,'main_rec.batch_source_id='||main_rec.batch_source_id);
          debug(l_module_name,'main_rec.trx_number='||main_rec.trx_number);
          debug(l_module_name,'main_rec.due_date='||main_rec.due_date);
          debug(l_module_name,'main_rec.amount='||main_rec.rate_amount);
          debug(l_module_name,'main_rec.rate_flag='||main_rec.rate_flag);
          debug(l_module_name,'main_rec.rate_base='||main_rec.rate_base);
          debug(l_module_name,'main_rec.rate_type='||main_rec.rate_type);
          debug(l_module_name,'main_rec.accrue_at_invoice='||main_rec.accrue_at_invoice);
          debug(l_module_name,'main_rec.trx_type_id='||main_rec.trx_type_id);
          debug(l_module_name,'main_rec.first_accrual='||main_rec.first_accrual);
          debug(l_module_name,'main_rec.accrual_interval='||main_rec.accrual_interval);
          debug(l_module_name,'main_rec.grace_period='||main_rec.grace_period);
          debug(l_module_name,'main_rec.receivables_trx_id='||main_rec.receivables_trx_id);
          debug(l_module_name,'main_rec.bill_to_customer_id='||main_rec.bill_to_customer_id);
          debug(l_module_name,'main_rec.bill_to_contact_id='||main_rec.bill_to_contact_id);
          debug(l_module_name,'main_rec.invoice_currency_code='||main_rec.invoice_currency_code);
          debug(l_module_name,'main_rec.exchange_date='||main_rec.exchange_date);
          debug(l_module_name,'main_rec.exchange_rate='||main_rec.exchange_rate);
          debug(l_module_name,'main_rec.exchange_rate_type='||main_rec.exchange_rate_type);
          debug(l_module_name,'main_rec.trx_date='||main_rec.trx_date);
          debug(l_module_name,'main_rec.gl_id_rev='||main_rec.gl_id_rev);
          debug(l_module_name,'main_rec.gl_id_rec='||main_rec.gl_id_rec);
          debug(l_module_name,'main_rec.bill_to_address_id='||main_rec.bill_to_address_id);
          debug(l_module_name,'main_rec.last_accrual_date='||main_rec.last_accrual_date);
          debug(l_module_name,'main_rec.base_date_type='||main_rec.base_date_type);
          debug(l_module_name,'main_rec.root_invoice_id='||main_rec.root_invoice_id);
          debug(l_module_name,'main_rec.org_id='||main_rec.org_id);
          debug(l_module_name,'main_rec.term_id='||main_rec.term_id);
          debug(l_module_name,'main_rec.customer_id='||main_rec.customer_id);
          debug(l_module_name,'main_rec.set_of_books_id='||main_rec.set_of_books_id);
          debug(l_module_name,'main_rec.finance_charge_group_hdr_id='||main_rec.finance_charge_group_hdr_id);
          debug(l_module_name,'main_rec.finance_charge_group_dtl_id='||main_rec.finance_charge_group_dtl_id);
          debug(l_module_name,'main_rec.prorate_charge='||main_rec.prorate_charge);
          debug(l_module_name,'main_rec.invoice_suffix='||main_rec.invoice_suffix);
          debug(l_module_name,'************************************************************');
        END IF;

        IF (main_rec.batch_source_id IS NULL) THEN
          p_retcode := g_FAILURE;
          p_errbuf := 'Please define Batch Source in Define Finance Charges for this finance charge '||main_rec.charge_type||'.';
          l_location   := l_module_name||'.main_rec.batch_source_id';
          log (l_location,l_location);
          log (l_location,p_errbuf);
        END IF;

        IF (main_rec.rate_type = 'CVFR' AND l_cvf_rate IS NULL) THEN
          p_retcode := g_FAILURE;
          p_errbuf := 'You have setup rate type as CVFR for charge type '||main_rec.charge_type||' but no rates are defined in Define Funds Rates.';
          l_location   := l_module_name||'.main_rec.rate_type';
          log (l_location,l_location);
          log (l_location,p_errbuf);
        END IF;

        IF (p_retcode = g_SUCCESS) THEN
          IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
            debug(l_module_name,'Calling get_last_accrual_date');
          END IF;
          get_last_accrual_date
          (
            p_payment_schedule_id => main_rec.payment_schedule_id,
            p_charge_type         => main_rec.charge_type,
            p_last_accrual_date   => main_rec.last_accrual_date,
            p_errbuf              => p_errbuf,
            p_retcode             => p_retcode
          );
          IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
            debug(l_module_name,'main_rec.last_accrual_date='||main_rec.last_accrual_date);
          END IF;
        END IF;

        IF (p_retcode = g_SUCCESS) THEN
          g_out_rec_count := g_out_rec_count + 1;
          g_out_rec_tab(g_out_rec_count).invoice_id := main_rec.invoice_id;
          g_out_rec_tab(g_out_rec_count).invoice_number := main_rec.trx_number;
          g_out_rec_tab(g_out_rec_count).amount_due_remaining := main_rec.amount_due_remaining;
          g_out_rec_tab(g_out_rec_count).amount_due_original := main_rec.amount_due_original;
          g_out_rec_tab(g_out_rec_count).due_date := main_rec.due_date;

          -- Bug 8947425
          IF ( main_rec.rate_flag IS NOT NULL) then
            IF (main_rec.rate_flag = 'Y') THEN
              g_out_rec_tab(g_out_rec_count).amount_based := 'N';
            ELSE
              g_out_rec_tab(g_out_rec_count).amount_based := 'Y';
            END IF;
          END IF;

          g_out_rec_tab(g_out_rec_count).amount_or_rate := main_rec.rate_amount;
          g_out_rec_tab(g_out_rec_count).first_accrual := main_rec.first_accrual;
          g_out_rec_tab(g_out_rec_count).accrual_interval := main_rec.accrual_interval;
          g_out_rec_tab(g_out_rec_count).grace_period := main_rec.grace_period;
          g_out_rec_tab(g_out_rec_count).last_accrual_date := main_rec.last_accrual_date;
          g_out_rec_tab(g_out_rec_count).base_date_type := main_rec.base_date_type;
          g_out_rec_tab(g_out_rec_count).payment_schedule_id := main_rec.payment_schedule_id;
          g_out_rec_tab(g_out_rec_count).charge_type := main_rec.charge_type;

          IF (main_rec.rate_type = 'CVFR' AND l_cvf_rate IS NOT NULL) THEN
            IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
              debug(l_module_name,'Changing the rates to CVFR');
            END IF;
            main_rec.rate_flag := 'Y';
            main_rec.rate_amount := l_cvf_rate/100;
          END IF;

          LOOP
            l_finance_charges := 0;
            IF (NVL(l_old_invoice_id, -999) <> main_rec.invoice_id) THEN
              BEGIN
                SELECT SUM(aps.amount_due_original),
                       SUM(aps.amount_due_remaining)
                  INTO l_inv_amount_due_original,
                       l_inv_amount_due_remaining
                  FROM ar_payment_schedules aps
                 WHERE aps.customer_trx_id = main_rec.invoice_id;
              EXCEPTION
                WHEN OTHERS THEN
                  p_retcode := g_FAILURE;
                  p_errbuf := SQLERRM;
                  l_location := l_module_name||'.select_ar_payment_schedules';
                  fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
                  fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
              END;
            END IF;

            IF (NVL(l_old_invoice_id, -999) = main_rec.invoice_id AND
                NVL(l_old_charge_id , -999) = main_rec.charge_id AND
                main_rec.accrue_at_invoice = 'Y') THEN
              l_location := '';
              l_message := 'Finance charges to be accrued at invoice level ,so skipping this payment schedule';
              g_out_rec_tab(g_out_rec_count).comments := l_message;
              log (l_location, l_message);
              EXIT;
            ELSIF (main_rec.accrual_interval = 0 AND main_rec.last_accrual_date IS NOT NULL) THEN
              l_location := '';
              l_message := 'Finance charges already accrued, so skipping this payment schedule';
              g_out_rec_tab(g_out_rec_count).comments := l_message;
              log (l_location, l_message);
              EXIT;

          --  ELSIF (main_rec.last_accrual_date + main_rec.accrual_interval >= l_accrue_as_of_date) THEN
          ELSIF (main_rec.last_accrual_date + main_rec.accrual_interval > l_accrue_as_of_date) THEN

              l_location := '';
              l_message := 'Accrual process already ran for today, so skipping';
              g_out_rec_tab(g_out_rec_count).comments := l_message;
              log (l_location, l_message);
              EXIT;
            ELSE
              /*
                Rate Type is valid only for Rate% and not for Amount
                But when Rate Type is FLAT, a flat charge is calculated based on the
                percentage. So it is equivalent to Amount based with
                rate * amount due. We have to convert this to rate_flag as N and put
                an amount to calculate for every missing period.
              */
              IF (main_rec.rate_flag = 'Y' AND main_rec.rate_base = 'FLAT') THEN
                main_rec.rate_flag := 'N';
                main_rec.rate_amount := main_rec.rate_amount * main_rec.amount_due_remaining;
              END IF;

              IF (main_rec.rate_flag = 'Y') THEN
                IF (main_rec.last_accrual_date IS NULL) THEN
                  IF (main_rec.base_date_type = 'INVOICE') THEN
                    l_accrual_date := main_rec.trx_date;
                  ELSE
                    l_accrual_date := main_rec.due_date;
                  END IF;
                ELSE
                  l_accrual_date := main_rec.last_accrual_date;
                END IF;

                IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
                  debug(l_module_name,'Calling accrue_charges');
                END IF;
--                l_first_late_day := trunc(main_rec.due_date) + main_rec.first_accrual + main_rec.grace_period + 1;
                g_out_rec_tab(g_out_rec_count).accrual_date := l_accrual_date;
                accrue_charges
                (
                  p_accrue_as_of_date     => l_accrue_as_of_date,
                  p_last_date             => l_accrual_date,
                  p_customer_trx_id       => main_rec.invoice_id,
                  p_amount_due_remaining  => main_rec.amount_due_remaining,
                  p_rate_amount           => main_rec.rate_amount,
                  p_interval              => main_rec.accrual_interval,
                  p_charges               => l_finance_charges,
                  p_errbuf                => p_errbuf,
                  p_retcode               => p_retcode
                );
                g_out_rec_tab(g_out_rec_count).finance_charges := l_finance_charges;

                IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
                  debug(l_module_name,'accrue_charges return code = '||p_retcode);
                  debug(l_module_name,'accrue_charges return buf = '||p_errbuf);
                END IF;

                IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
                  debug(l_module_name,'l_finance_charges='||l_finance_charges);
                END IF;

              ELSE

               --l_first_late_day := trunc(main_rec.due_date) + main_rec.first_accrual + main_rec.grace_period + 1;
               l_first_late_day := trunc(main_rec.due_date) + main_rec.first_accrual + main_rec.grace_period;

                g_out_rec_tab(g_out_rec_count).first_late_date := l_first_late_day;
                missed_intervals
                (
                  p_accrue_as_of_date => l_accrue_as_of_date,
                  p_interval          => main_rec.accrual_interval,
                  p_last_accrual_date => main_rec.last_accrual_date,
                  p_first_late_day    => l_first_late_day,
                  p_number_of_periods => l_number_of_periods,
                  p_errbuf            => p_errbuf,
                  p_retcode           => p_retcode
                );
                g_out_rec_tab(g_out_rec_count).number_of_periods := l_number_of_periods;
                IF (p_retcode = g_SUCCESS) THEN
                  l_finance_charges := main_rec.rate_amount * l_number_of_periods;
                  g_out_rec_tab(g_out_rec_count).comments := 'Finance Charges = '||main_rec.rate_amount||'*'||l_number_of_periods||'='||l_finance_charges;
                END IF;
                g_out_rec_tab(g_out_rec_count).finance_charges := l_finance_charges;

              END IF;


              IF (p_retcode = g_SUCCESS) THEN
                IF (l_finance_charges <> 0) THEN
                  process_and_create_dm
                  (
                    p_org_id => main_rec.org_id,
                    p_set_of_books_id => main_rec.set_of_books_id,
                    p_accrue_as_of_date => l_accrue_as_of_date,
                    p_finance_charges => l_finance_charges,
                    p_invoice_id => main_rec.invoice_id,
                    p_customer_id => main_rec.customer_id,
                    p_trx_number => main_rec.trx_number,
                    p_trx_date => main_rec.trx_date,
                    p_charge_id => main_rec.charge_id,
                    p_finance_charge_group_hdr_id => main_rec.finance_charge_group_hdr_id,
                    p_finance_charge_group_dtl_id => main_rec.finance_charge_group_dtl_id,
                    p_invoice_currency_code => main_rec.invoice_currency_code,
                    p_trx_type_id => main_rec.trx_type_id,
                    p_gl_date => l_gl_date,
                    p_bill_to_customer_id => main_rec.bill_to_customer_id,
                    p_bill_to_contact_id => main_rec.bill_to_contact_id,
                    p_bill_to_address_id => main_rec.bill_to_address_id,
                    p_invoice_due_date => main_rec.due_date,
                    p_exchange_date => main_rec.exchange_date,
                    p_exchange_rate => main_rec.exchange_rate,
                    p_exchange_rate_type => main_rec.exchange_rate_type,
                    p_root_invoice_id => main_rec.root_invoice_id,
                    p_invoice_date_type => p_invoice_date_type,
                    p_immediate_term_id => l_immediate_term_id,
                    p_invoice_term_id => main_rec.term_id,
                    p_gl_id_rec => main_rec.gl_id_rec,
                    p_gl_id_rev => main_rec.gl_id_rev,
                    p_prorate_charge => main_rec.prorate_charge,
                    p_batch_source_id => main_rec.batch_source_id,
                    p_inv_amount_due_remaining => l_inv_amount_due_remaining,
                    p_inv_amount_due_original => l_inv_amount_due_original,
                    p_charge_type =>main_rec.charge_type,
                    p_invoice_suffix => main_rec.invoice_suffix,
                    p_errbuf   => p_errbuf,
                    p_retcode  => p_retcode
                  );

                  IF (p_retcode = g_SUCCESS) THEN
                    set_last_accrual_date
                    (
                      p_org_id              => main_rec.org_id,
                      p_payment_schedule_id => main_rec.payment_schedule_id,
                      p_charge_type         => main_rec.charge_type,
                      p_last_accrual_date   => l_accrue_as_of_date,
                      p_errbuf              => p_errbuf,
                      p_retcode             => p_retcode
                    );
                  END IF;

                END IF;
              END IF;

            END IF;

            l_old_invoice_id := main_rec.invoice_id;
            l_old_charge_id := main_rec.charge_id;
            EXIT;
          END LOOP;
        END IF;
        IF (p_retcode <> g_SUCCESS) THEN
          EXIT;
        END IF;
      END LOOP;

      write_output;

      IF (p_retcode = g_SUCCESS) THEN
        COMMIT;
        submit_report
        (
          p_errbuf  => p_errbuf,
          p_retcode => p_retcode
        );
      ELSE
        ROLLBACK;
      END IF;


    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location, p_errbuf);
      ROLLBACK;
  END;


/*****************************************************************************/
/*                      Begin Assign Finance Charges Process                 */
/*****************************************************************************/
  PROCEDURE assign_finance_charge
  (
    p_errbuf  OUT NOCOPY VARCHAR2,
    p_retcode OUT NOCOPY NUMBER
  ) IS
    l_module_name              VARCHAR2(200);
    l_location                 VARCHAR2(200);
    l_currency_code gl_ledgers.currency_code%TYPE;
    l_req_id        NUMBER;

    CURSOR c1 (c_ledger_id NUMBER) IS
    SELECT DISTINCT hzca.cust_Account_id customer_id,
          hzca.customer_class_code cust_class_code
      FROM hz_cust_accounts hzca,
           fv_finance_charge_controls fcc
     WHERE fcc.enabled_flag = 'Y'
       AND fcc.set_of_books_id = c_ledger_id
       AND hzca.status = 'A'
       AND EXISTS (SELECT 'x'
                     FROM fv_cust_finance_chrgs
                    WHERE hzca.cust_account_id = customer_id
                      AND fcc.charge_id = charge_id
                      AND set_of_books_id = c_ledger_id)
       AND NOT EXISTS (SELECT 'x'
                         FROM fv_finance_chrg_cust_classes fccc,
                              fv_finance_charge_grp_dtls fcgd
                        WHERE fccc.customer_class = hzca.customer_class_code
                          AND fccc.enabled_flag = 'Y'
                          AND fccc.finance_charge_group_hdr_id = fcgd.finance_charge_group_hdr_id
                          AND SYSDATE between NVL(fcgd.start_date, g_lo_date) and NVL(fcgd.end_date, g_hi_date)
                          AND fcgd.assessed_charge_id = fcc.charge_id
                          AND set_of_books_id = c_ledger_id);
  BEGIN
    l_module_name := g_module_name || 'assign_finance_charge';
    p_retcode := g_SUCCESS;
    p_errbuf  := null;

    IF (fnd_log.level_procedure >= g_CURRENT_LOG_LEVEL) THEN
      debug(l_module_name,g_enter);
    END IF;


    BEGIN
      IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
        debug(l_module_name,'g_set_of_books_id='||g_set_of_books_id);
      END IF;

      SELECT currency_code
        INTO l_currency_code
        FROM gl_ledgers_public_v
       WHERE ledger_id = g_set_of_books_id;

      IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
        debug(l_module_name,'l_currency_code='||l_currency_code);
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        p_retcode := g_FAILURE;
        p_errbuf := SQLERRM;
        l_location   := l_module_name||'.select_gl_ledgers_public_v';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
    END;

    IF (p_retcode = g_SUCCESS) THEN
      FOR customer in c1 (g_set_of_books_id)
      LOOP
        IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Updating waive flag for: '||customer.customer_id);
        END IF;

        BEGIN


        -- commented the below UPDATE statement and added 3new UPDATE statements


        /*  UPDATE fv_cust_finance_chrgs
             SET waive_flag = 'Y'
           WHERE customer_id = customer.customer_id
             AND charge_id NOT IN (SELECT charge_id
                                     FROM fv_finance_chrg_cust_classes,
                                          hz_cust_accounts hzca
                                    WHERE hzca.cust_account_id = customer.customer_id
                                      AND customer_class = hzca.customer_class_code
                                      AND enabled_flag = 'Y'
                                      AND set_of_books_id = g_set_of_books_id);*/

	  /* Commented for bug 9089029
          UPDATE fv_cust_finance_chrgs a
             SET CUSTOMER_CLASS_CODE = customer.cust_class_code,
                 finance_charge_group_hdr_id = (SELECT finance_charge_group_hdr_id
                                                FROM fv_finance_chrg_cust_classes b
                                                WHERE customer_class= customer.cust_class_code
                                                  AND a.set_of_books_id = b.set_of_books_id
                                                  AND rownum =1)
          WHERE EXISTS(SELECT 'A'
                       FROM fv_finance_chrg_cust_classes c
                       WHERE customer_class= customer.cust_class_code
                         AND a.set_of_books_id = c.set_of_books_id)
            AND customer_id = customer.customer_id;
          */

          UPDATE fv_cust_finance_chrgs
             SET waive_flag = 'Y'
           WHERE customer_id = customer.customer_id
             AND charge_id  NOT IN (SELECT fcf.charge_id
                                     FROM fv_cust_finance_chrgs  fcf,
                                          fv_finance_chrg_cust_classes fcfc,
                                          hz_cust_accounts hzca,
                                          fv_finance_charge_grp_hdrs fcgh,
                                          fv_finance_charge_grp_dtls fcgd
                                    WHERE hzca.cust_account_id = customer.customer_id
                                      AND fcf.customer_id = hzca.cust_account_id
                                      AND fcf.customer_class_code = fcfc.customer_class
                                      AND fcf.customer_class_code = hzca.customer_class_code
                                      AND fcgh.finance_charge_group_hdr_id = fcfc.finance_charge_group_hdr_id
                                      AND fcgh.finance_charge_group_hdr_id = fcf.finance_charge_group_hdr_id
                                      AND fcgh.finance_charge_group_hdr_id = fcgd.finance_charge_group_hdr_id
                                      AND fcf.charge_id = fcgd.assessed_charge_id
                                      AND fcfc.enabled_flag = 'Y'
                                      AND fcf.set_of_books_id =g_set_of_books_id
                                      AND fcgd.start_date <= sysdate
                                      AND decode(fcgd.end_date,null,sysdate,fcgd.end_date) >= sysdate
                                      AND fcgd.base_charge_id = 0);

          UPDATE fv_cust_finance_chrgs
             SET waive_flag = 'N'
           WHERE customer_id = customer.customer_id
             AND charge_id  IN (SELECT fcf.charge_id
                                     FROM fv_cust_finance_chrgs  fcf,
                                          fv_finance_chrg_cust_classes fcfc,
                                          hz_cust_accounts hzca,
                                          fv_finance_charge_grp_hdrs fcgh,
                                          fv_finance_charge_grp_dtls fcgd
                                    WHERE hzca.cust_account_id = customer.customer_id
                                      AND fcf.customer_id = hzca.cust_account_id
                                      AND fcf.customer_class_code = fcfc.customer_class
                                      AND fcf.customer_class_code = hzca.customer_class_code
                                      AND fcgh.finance_charge_group_hdr_id = fcfc.finance_charge_group_hdr_id
                                      AND fcgh.finance_charge_group_hdr_id = fcf.finance_charge_group_hdr_id
                                      AND fcgh.finance_charge_group_hdr_id = fcgd.finance_charge_group_hdr_id
                                      AND fcf.charge_id = fcgd.assessed_charge_id
                                      AND fcfc.enabled_flag = 'Y'
                                      AND fcf.set_of_books_id =g_set_of_books_id
                                      AND fcgd.start_date <= sysdate
                                      AND decode(fcgd.end_date,null,sysdate,fcgd.end_date) >= sysdate
                                      AND fcgd.base_charge_id = 0);

        EXCEPTION
          WHEN OTHERS THEN
            p_retcode := g_FAILURE;
            p_errbuf := SQLERRM;
            l_location   := l_module_name||'.update_fv_cust_finance_chrgs';
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
        END;
      END LOOP;
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      BEGIN
        INSERT INTO fv_cust_finance_chrgs
        (
          customer_id,
          charge_id,
          waive_flag,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          set_of_books_id,
          org_id,
          enabled_flag,
          customer_class_code,
          finance_charge_group_hdr_id,
          base_charge_id,
          request_id
        )
        SELECT hzca.cust_account_id,
               fcgd.assessed_charge_id,
               'N',
               g_user_id,
               SYSDATE,
               g_user_id,
               SYSDATE,
               g_set_of_books_id,
               fcc.org_id,
               'Y',
               fccc.customer_class,
               fcgh.finance_charge_group_hdr_id,
               fcgd.base_charge_id,
               g_request_id
          FROM hz_cust_accounts hzca,
               fv_finance_charge_controls fcc,
               fv_finance_chrg_cust_classes fccc,
               fv_finance_charge_grp_dtls fcgd,
               fv_finance_charge_grp_hdrs fcgh
         WHERE fcc.enabled_flag = 'Y'
           AND fcc.set_of_books_id = g_set_of_books_id
           AND hzca.status = 'A'
           AND fccc.customer_class = hzca.customer_class_code
           AND fccc.finance_charge_group_hdr_id = fcgh.finance_charge_group_hdr_id
           AND fcgd.finance_charge_group_hdr_id = fcgh.finance_charge_group_hdr_id
           AND fcgh.enabled_flag = 'Y'
           AND fcgd.enabled_flag = 'Y'
           AND fcgd.assessed_charge_id = fcc.charge_id
           AND fccc.set_of_books_id = g_set_of_books_id
           AND fcgh.ledger_id = g_set_of_books_id
           AND fccc.enabled_flag = 'Y'
           AND fcgd.base_charge_id = 0
           AND NOT EXISTS (SELECT 'x'
                             FROM fv_cust_finance_chrgs fcfc
                            WHERE hzca.cust_account_id = fcfc.customer_id
                              AND fcc.charge_id   = fcfc.charge_id
                              AND fcgd.finance_charge_group_hdr_id = fcfc.finance_charge_group_hdr_id
                              and fcfc.customer_class_code = fccc.customer_class
                              AND fcfc.set_of_books_id = g_set_of_books_id);
      EXCEPTION
        WHEN OTHERS THEN
          p_retcode := g_FAILURE;
          p_errbuf := SQLERRM;
          l_location   := l_module_name||'.insert_fv_cust_finance_chrgs';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
      END;
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      BEGIN
        INSERT INTO fv_ar_fin_chrg_invoices
        (
          org_id,
          customer_id,
          invoice_id,
          invoice_number,
          invoice_date,
          invoice_amount,
          finance_charges,
          waive_flag,
          enabled_flag,
          parent_invoice_id,
          root_invoice_id,
          last_accrual_date,
          last_update_date,
          last_updated_by,
          created_by,
          creation_date,
          last_update_login,
          request_id
        )
        SELECT ract.org_id,
               ract.bill_to_customer_id,
               ract.customer_trx_id,
               ract.trx_number,
               ract.trx_date,
               0, --invoice amount
               0, --finance charges
               'N',
               'Y',
               0,
               0,
               NULL,
               SYSDATE,
               g_user_id,
               g_user_id,
               SYSDATE,
               g_login_id,
               g_request_id
          FROM ra_customer_trx ract,
               ra_cust_trx_types rctt
          WHERE ract.cust_trx_type_id = rctt.cust_trx_type_id
            AND ract.complete_flag = 'Y'
            AND rctt.type IN ('DM','INV')

           /* AND NVL(ract.interface_header_attribute3,'XX') NOT IN (SELECT charge_type
                                                                     FROM fv_finance_charge_controls
                                                                    WHERE set_of_books_id = g_set_of_books_id)*/

            AND EXISTS (SELECT 'x'
                          FROM fv_cust_finance_chrgs fcfc
                         WHERE ract.bill_to_customer_id = fcfc.customer_id
                           AND fcfc.enabled_flag = 'Y'
                           AND fcfc.waive_flag = 'N')
            AND NOT EXISTS (SELECT 'x'
                              FROM fv_ar_fin_chrg_invoices fai
                             WHERE ract.customer_trx_id = fai.invoice_id
                               AND ract.bill_to_customer_id=fai.customer_id);
      EXCEPTION
        WHEN OTHERS THEN
          p_retcode := g_FAILURE;
          p_errbuf := SQLERRM;
          l_location   := l_module_name||'.insert_fv_cust_finance_chrgs';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
      END;
    END IF;
    IF (p_retcode = g_SUCCESS) THEN
      BEGIN
        INSERT INTO fv_invoice_finance_chrgs
        (
          customer_id,
          customer_trx_id,
          charge_id,
          waive_flag,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          set_of_books_id,
          org_id,
          request_id,
          base_charge_id,
          finance_charge_group_hdr_id,
          finance_charge_group_dtl_id,
          enabled_flag
        )
        SELECT ract.bill_to_customer_id,
               ract.customer_trx_id,
               fcgd.assessed_charge_id,
               fcfc.waive_flag,
               g_user_id,
               SYSDATE,
               g_user_id,
               SYSDATE,
               g_set_of_books_id,
               fcfc.org_id,
               g_request_id,
               fcgd.base_charge_id,
               fcgh.finance_charge_group_hdr_id,
               fcgd.finance_charge_group_dtl_id,
               'Y'
          FROM ra_customer_trx ract,
               fv_cust_finance_chrgs fcfc,
               fv_finance_charge_controls fcc,
               ra_cust_trx_types rctt,
               fv_finance_charge_grp_dtls fcgd,
               fv_finance_charge_grp_hdrs fcgh
         WHERE ract.bill_to_customer_id = fcfc.customer_id
            AND fcfc.set_of_books_id = g_set_of_books_id
            AND ract.cust_trx_type_id = rctt.cust_trx_type_id
            AND ract.complete_flag = 'Y'
            AND fcc.enabled_flag = 'Y'
            AND fcc.charge_id = fcfc.charge_id
            AND fcgh.finance_charge_group_hdr_id = fcfc.finance_charge_group_hdr_id
            AND fcfc.enabled_flag = 'Y'
            AND fcfc.waive_flag = 'N'
            AND rctt.type IN ('DM','INV')
            AND fcgd.finance_charge_group_hdr_id = fcgh.finance_charge_group_hdr_id
            AND fcgh.enabled_flag = 'Y'
            AND fcgd.enabled_flag = 'Y'
            AND fcgd.assessed_charge_id = fcc.charge_id
            AND fcgd.base_charge_id = 0
            AND fcgh.ledger_id = g_set_of_books_id

           /* AND NVL(ract.interface_header_attribute3,'XX') NOT IN (SELECT charge_type
                                                                     FROM fv_finance_charge_controls
                                                                    WHERE set_of_books_id = g_set_of_books_id)*/

            AND NOT EXISTS (SELECT 'x'
                              FROM fv_invoice_finance_chrgs fifc
                             WHERE ract.customer_trx_id = fifc.customer_trx_id
                               AND ract.bill_to_customer_id=fifc.customer_id
                               AND fcgd.assessed_charge_id = fifc.charge_id
                               AND set_of_books_id = g_set_of_books_id);
      EXCEPTION
        WHEN OTHERS THEN
          p_retcode := g_FAILURE;
          p_errbuf := SQLERRM;
          l_location   := l_module_name||'.insert_fv_invoice_finance_chrgs';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
      END;
    END IF;

    IF (p_retcode = g_SUCCESS) THEN
      fnd_request.set_org_id(g_org_id);     -- PSKI MOAC Changes

      l_req_id := fnd_request.submit_request
      (
        application => 'FV',
        program     => 'FVDCAFCO',
        description => '',
        start_time  => '',
        sub_request => FALSE,
        argument1   => g_ledger_name,
        argument2   => l_currency_code,
        argument3   => g_request_id
      );

      IF (fnd_log.level_statement >= g_CURRENT_LOG_LEVEL) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name, 'l_req_id = '||l_req_id);
      END IF;


      IF l_req_id = 0 THEN
        p_retcode := g_FAILURE;
        p_errbuf := 'Submitting the concurrent process, FVDCAFCO, failed contact System Admin.';
        fv_utility.log_mesg(fnd_log.level_error, l_module_name, p_errbuf);
      END IF;
    END IF;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location   := l_module_name||'.insert_fv_invoice_finance_chrgs';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_module_name||'.final_exception', p_errbuf);
      ROLLBACK;
  END assign_finance_charge;
BEGIN
  initialize_global_variables;
END fv_dc_assign_finance_chrg;

/
