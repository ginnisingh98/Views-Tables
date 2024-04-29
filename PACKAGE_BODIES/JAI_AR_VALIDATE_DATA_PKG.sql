--------------------------------------------------------
--  DDL for Package Body JAI_AR_VALIDATE_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AR_VALIDATE_DATA_PKG" 
   /* $Header: jai_ar_val_data.plb 120.2.12010000.2 2008/11/06 11:55:22 csahoo ship $  */
AS

  /*
  CREATED BY       : Bgowrava
  CREATED DATE     : 08-JUN-2007
  BUG              : 5484865
  PURPOSE          : It is a datafix to fix data corruption issues in AR base tables.

  */
  /* ------------------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY:
  S.No      DATE                Author AND Details
  ---------------------------------------------------------------------------------------------------------------------------
  1     06-NOV-2008       CSahoo for bug#7445602, File Version 120.0.12000000.3
                          Issue: TAXES NOT FLOWING TO CREDIT MEMO WHEN INVOICNG RULE IS APPLIED FOR TRANSACTION
                          Fix: Modified the code in pre_validation. Added a cursor cur_chk_revrec_run_cm
  --------------------------------------------------------------------------------------------------------------------------*/

  PROCEDURE populate_error_table (p_error_table     OUT NOCOPY  jai_ar_validate_data_pkg.t_error_table,
                                  p_process_status  OUT NOCOPY  VARCHAR2,
                                  p_process_message OUT NOCOPY  VARCHAR2)
  IS
  BEGIN
    p_process_status := jai_constants.successful;

    FOR i in 1..13 LOOP
      p_error_table(i).type_of_error := 'Common';
    END LOOP;

    p_error_table(1).error_description := 'Difference in tax records in ra_customer_trx_lines_all and ja_in_ra_customer_trx_lines_all';
    p_error_table(1).enable            := 'Y';

    p_error_table(2).error_description := 'Difference in tax records in ra_cust_trx_line_gl_dist_all and JAI_AR_TRX_TAX_LINES';
    p_error_table(2).enable            := 'Y';

    p_error_table(3).error_description := 'ADO <> Amount in REC of ra_cust_trx_line_gl_dist_all';
    p_error_table(3).enable            := 'Y';

    p_error_table(4).error_description := 'TO <> Amount in TAX of ra_cust_trx_line_gl_dist_all';
    p_error_table(4).enable            := 'Y';

    p_error_table(5).error_description := 'FO <> Amount in FREIGHT of ra_cust_trx_line_gl_dist_all';
    p_error_table(5).enable            := 'Y';

    p_error_table(6).error_description := 'ADO <> ALIO + TO + FO';

    p_error_table(7).error_description := 'ADR <> ALIR + TR + FR';

    p_error_table(8).error_description := 'ADR * exchange_rate <> AADR';

    p_error_table(9).error_description := 'Status = CL and (AADR <> 0 OR ADR <> 0)';
    p_error_table(9).enable            := 'Y';

    p_error_table(10).error_description := 'Status = OP and gl_date_closed <> 31-DEC-4712';
    p_error_table(10).enable           := 'Y';

    p_error_table(11).error_description := 'Tax/Freight in GL Dist <> tax/freight in ra_customer_trx_lines_all';
    p_error_table(11).enable           := 'Y';

    p_error_table(12).error_description := 'Sum of taxes for a line <> Tax amount of the line';
    p_error_table(12).enable           := 'Y';

    p_error_table(13).error_description := 'Sum of taxes for an invoice <> Tax amount of the invoice';
    p_error_table(13).enable           := 'Y';

    FOR i in 21..26 LOOP
      p_error_table(i).type_of_error := 'CM';
    END LOOP;

    p_error_table(21).error_description := 'ADR, AADR, TR and FR should be 0 for CM';
    p_error_table(21).enable           := 'Y';

    p_error_table(22).error_description := 'ADO of CM should be equal to amount applied of CM';
    p_error_table(22).enable           := 'Y';

    p_error_table(23).error_description := 'ADO <> SUM(LA + TA + FA) for ar_receivable_applications_all';
    p_error_table(23).enable           := 'Y';

    p_error_table(24).error_description := 'Amount_applied <> LA + TA + FA for ar_receivable_applications_all';
    p_error_table(24).enable           := 'Y';

    p_error_table(25).error_description := 'AAAF <> AA * exchange_rate(CM) for ar_receivable_applications_all';
    p_error_table(25).enable           := 'Y';

    p_error_table(26).error_description := 'AAAT <> AA * exchange_rate(INV) for ar_receivable_applications_all';
    p_error_table(26).enable           := 'Y';

    FOR i in 41..42 LOOP
      p_error_table(i).type_of_error := 'Invoice';
    END LOOP;

    p_error_table(41).error_description := 'ADO <> ADR + SUM(LA + TA + FA) of ar_receivable_applications';
    p_error_table(42).error_description := 'Amount_credited <> SUM(amount_applied) of ar_receivable_applications';

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := jai_constants.unexpected_error;
      p_process_message := SUBSTR(SQLERRM,1,300);
  END populate_error_table;


  PROCEDURE display_error_summary(p_error_table     IN  jai_ar_validate_data_pkg.t_error_table,
                                  p_total_count     IN  NUMBER,
                                  p_filename        IN  VARCHAR2,
                                  p_process_status  OUT NOCOPY  VARCHAR2,
                                  p_process_message OUT NOCOPY  VARCHAR2)
  IS
    ln_slno   NUMBER := 0;
  BEGIN
    jai_cmn_utils_pkg.print_log(p_filename, fnd_global.local_chr(10));
    jai_cmn_utils_pkg.print_log(p_filename, LPAD('=',62,'=')||'Summary'||LPAD('=',62,'='));
    jai_cmn_utils_pkg.print_log(p_filename, 'Total number of Records processed : '||p_total_count);
    jai_cmn_utils_pkg.print_log(p_filename, fnd_global.local_chr(10));
    jai_cmn_utils_pkg.print_log(p_filename, LPAD('No.',3)||' '||RPAD('Error Description',120)||' '||LPAD('Count',6));
    jai_cmn_utils_pkg.print_log(p_filename, LPAD('-',3,'-')||' '||RPAD('-',120,'-')||' '||LPAD('-',6,'-'));

    For i IN p_error_table.first..p_error_table.last
    LOOP
      IF p_error_table.EXISTS(i) THEN

        IF p_error_table(i).error_record_count > 0 THEN
          ln_slno := ln_slno + 1;
          jai_cmn_utils_pkg.print_log(p_filename, LPAD(ln_slno,2)||') '||RPAD(p_error_table(i).error_description,120)||' '||LPAD(p_error_table(i).error_record_count,6));
        END IF;

      END IF;

    END LOOP;

    jai_cmn_utils_pkg.print_log(p_filename, LPAD('=',131,'='));

  END display_error_summary;

  PROCEDURE calc_term_apportion_ratio(p_invoice_type              IN  ar_payment_schedules_all.class%TYPE,
                                      p_term_id                   IN  ar_payment_schedules_all.term_id%TYPE,
                                      p_terms_sequence_number     IN  ar_payment_schedules_all.terms_sequence_number%TYPE,
                                      p_apportion_ratio           OUT NOCOPY NUMBER,
                                      p_first_installment_code    OUT NOCOPY ra_terms.first_installment_code%TYPE,
                                      p_process_status            OUT NOCOPY VARCHAR2,
                                      p_process_message           OUT NOCOPY VARCHAR2
                                         )
  IS

  CURSOR cur_get_ra_term_ratio
  IS
  SELECT  rtl.relative_amount/rt.base_amount apportion_ratio,
          rt.first_installment_code
  FROM    ra_terms      rt   ,
          ra_terms_lines rtl
  WHERE   rt.term_id          = rtl.term_id
  AND     rtl.term_id         = p_term_id
  AND     rtl.sequence_num    = p_terms_sequence_number;

  BEGIN
    p_process_status := jai_constants.successful;
    p_process_message := NULL;

    /*
      Process the records only for an invoice not for any other type.
    */
    p_apportion_ratio := 1;

    IF p_invoice_type = 'INV' THEN
      OPEN  cur_get_ra_term_ratio ;
      FETCH cur_get_ra_term_ratio INTO p_apportion_ratio,
                                       p_first_installment_code;
      CLOSE cur_get_ra_term_ratio ;

      IF p_first_installment_code <> 'ALLOCATE' THEN
        p_apportion_ratio := 1;
      END IF;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := jai_constants.unexpected_error;
      p_process_message := SUBSTR(SQLERRM,1,300);
  END calc_term_apportion_ratio;

  PROCEDURE rectify_ar_pay_sch(
                              p_customer_trx_id     IN  ar_payment_schedules_all.customer_trx_id%TYPE,
                              p_gl_rec_amount       IN  NUMBER DEFAULT NULL,
                              p_gl_tax_amount       IN  NUMBER DEFAULT NULL,
                              p_gl_freight_amount   IN  NUMBER DEFAULT NULL,
                              p_datafix_filename    IN  VARCHAR2,
                              p_process_status      OUT NOCOPY VARCHAR2,
                              p_process_message     OUT NOCOPY VARCHAR2)
  IS
    ln_apportion_ratio            NUMBER ;
    lv_first_installment_code     RA_TERMS.FIRST_INSTALLMENT_CODE%TYPE;
    lv_process_status             VARCHAR2(2);
    lv_process_message            VARCHAR2(2000);
    lv_sql_statement              VARCHAR2(4000);

  BEGIN
    p_process_status := jai_constants.successful;
    p_process_message := NULL;

    FOR i IN( SELECT  *
              FROM    ar_payment_schedules_all
              WHERE   customer_trx_id = p_customer_trx_id
              ORDER BY payment_schedule_id)
    LOOP

      ln_apportion_ratio        := null;
      lv_first_installment_code := null;
      lv_process_status         := jai_constants.successful;
      lv_process_message        := null;

      calc_term_apportion_ratio(p_invoice_type              => i.class   ,
                                p_term_id                   => i.term_id ,
                                p_terms_sequence_number     => i.terms_sequence_number ,
                                p_apportion_ratio           => ln_apportion_ratio      ,
                                p_first_installment_code    => lv_first_installment_code ,
                                p_process_status            => lv_process_status ,
                                p_process_message           => lv_process_message
                                );
      IF lv_process_status <> jai_constants.successful THEN
        p_process_status := lv_process_status;
        p_process_message := lv_process_message;
        EXIT;
      END IF;

      IF p_gl_rec_amount IS NOT NULL THEN

        UPDATE  ar_payment_schedules_all
        SET     amount_due_original   =  p_gl_rec_amount * ln_apportion_ratio,
                last_update_date      =  sysdate,
                last_updated_by       =  gn_bug_no
        WHERE   customer_trx_id       =  p_customer_trx_id
        AND     payment_schedule_id   =  i.payment_schedule_id;

        lv_sql_statement := fnd_global.local_chr(10)||
                            'UPDATE ar_payment_schedules_all
                            SET     amount_due_original   =  '||p_gl_rec_amount||' * '||ln_apportion_ratio||',
                                    last_update_date  = sysdate,
                                    last_updated_by   = '||gn_bug_no||'
                            WHERE   customer_trx_id       =  '||p_customer_trx_id||'
                            AND     payment_schedule_id   =  '||i.payment_schedule_id||';';

        jai_cmn_utils_pkg.print_log(p_datafix_filename, lv_sql_statement);

        lv_sql_statement := NULL;

      ELSIF p_gl_tax_amount IS NOT NULL THEN

        UPDATE  ar_payment_schedules_all
        SET     tax_original          =  p_gl_tax_amount * ln_apportion_ratio,
                last_update_date      =  sysdate,
                last_updated_by       =  gn_bug_no
        WHERE   customer_trx_id       =  p_customer_trx_id
        AND     payment_schedule_id   =  i.payment_schedule_id;

        lv_sql_statement := fnd_global.local_chr(10)||
                            'UPDATE ar_payment_schedules_all
                            SET     tax_original   =  '||p_gl_tax_amount||' * '||ln_apportion_ratio||',
                                    last_update_date  = sysdate,
                                    last_updated_by   = '||gn_bug_no||'
                            WHERE   customer_trx_id       =  '||p_customer_trx_id||'
                            AND     payment_schedule_id   =  '||i.payment_schedule_id||';';

        jai_cmn_utils_pkg.print_log(p_datafix_filename, lv_sql_statement);

        lv_sql_statement := NULL;

      ELSIF p_gl_freight_amount IS NOT NULL THEN

        UPDATE  ar_payment_schedules_all
        SET     freight_original      =  p_gl_freight_amount * ln_apportion_ratio,
                last_update_date      =  sysdate,
                last_updated_by       =  gn_bug_no
        WHERE   customer_trx_id       =  p_customer_trx_id
        AND     payment_schedule_id   =  i.payment_schedule_id;

        lv_sql_statement := fnd_global.local_chr(10)||
                            'UPDATE ar_payment_schedules_all
                            SET     freight_original   =  '||p_gl_freight_amount||' * '||ln_apportion_ratio||',
                                    last_update_date  = sysdate,
                                    last_updated_by   = '||gn_bug_no||'
                            WHERE   customer_trx_id       =  '||p_customer_trx_id||'
                            AND     payment_schedule_id   =  '||i.payment_schedule_id||';';

        jai_cmn_utils_pkg.print_log(p_datafix_filename, lv_sql_statement);

        lv_sql_statement := NULL;

      END IF;

      IF lv_first_installment_code <> 'ALLOCATE' THEN
        EXIT;
      END IF;

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := jai_constants.unexpected_error;
      p_process_message := SUBSTR(SQLERRM,1,300);
  END rectify_ar_pay_sch;

  PROCEDURE rectify_ar_rec_appl(
                              p_customer_trx_id     IN  ar_payment_schedules_all.customer_trx_id%TYPE,
                              p_previous_trx_id     IN  ar_payment_schedules_all.customer_trx_id%TYPE,
                              p_arps_ado            IN  NUMBER DEFAULT NULL,
                              p_arps_to             IN  NUMBER DEFAULT NULL,
                              p_arps_fo             IN  NUMBER DEFAULT NULL,
                              p_datafix_filename    IN  VARCHAR2,
                              p_process_status      OUT NOCOPY VARCHAR2,
                              p_process_message     OUT NOCOPY VARCHAR2)
  IS
    ln_apportion_ratio            NUMBER;
    lv_first_installment_code     RA_TERMS.FIRST_INSTALLMENT_CODE%TYPE;
    lv_process_status             VARCHAR2(2);
    lv_process_message            VARCHAR2(2000);
    lv_sql_statement              VARCHAR2(4000);

  BEGIN
    p_process_status := jai_constants.successful;
    p_process_message := NULL;

    FOR i IN( SELECT  *
              FROM    ar_payment_schedules_all
              WHERE   customer_trx_id = p_previous_trx_id
              ORDER BY payment_schedule_id)
    LOOP

      calc_term_apportion_ratio(p_invoice_type              => i.class   ,
                                p_term_id                   => i.term_id ,
                                p_terms_sequence_number     => i.terms_sequence_number ,
                                p_apportion_ratio           => ln_apportion_ratio      ,
                                p_first_installment_code    => lv_first_installment_code ,
                                p_process_status            => lv_process_status ,
                                p_process_message           => lv_process_message
                                );

      IF lv_process_status <> jai_constants.successful THEN
        p_process_status := lv_process_status;
        p_process_message := lv_process_message;
        EXIT;
      END IF;

      IF p_arps_ado IS NOT NULL THEN

        UPDATE  ar_receivable_applications_all
        SET     amount_applied                =  p_arps_ado * ln_apportion_ratio,
                last_update_date              =  sysdate,
                last_updated_by               =  gn_bug_no
        WHERE   customer_trx_id               =  p_customer_trx_id      -- CM
        AND     applied_customer_trx_id       =  p_previous_trx_id     -- INV
        AND     applied_payment_schedule_id   =  i.payment_schedule_id  -- payment_schedule_id of INV
        AND     display                       = 'Y'
        AND     status                        = 'APP'
        AND     application_type              = 'CM';

        lv_sql_statement := fnd_global.local_chr(10)||
                            'UPDATE ar_receivable_applications_all
                            SET     amount_applied                =  '||p_arps_ado||' * '||ln_apportion_ratio||',
                                    last_update_date              =  sysdate,
                                    last_updated_by               =  '||gn_bug_no||'
                            WHERE   customer_trx_id               =  '||p_customer_trx_id||'
                            AND     applied_customer_trx_id       =  '||p_previous_trx_id||'
                            AND     applied_payment_schedule_id   =  '||i.payment_schedule_id||'
                            AND     display                       = '||''''||'Y'||''''||'
                            AND     status                        = '||''''||'APP'||''''||'
                            AND     application_type              = '||''''||'CM'||''''||';';

        jai_cmn_utils_pkg.print_log(p_datafix_filename, lv_sql_statement);

        lv_sql_statement := NULL;

      ELSIF p_arps_to IS NOT NULL THEN

        UPDATE  ar_receivable_applications_all
        SET     tax_applied                   =  p_arps_to * ln_apportion_ratio,
                last_update_date              =  sysdate,
                last_updated_by               =  gn_bug_no
        WHERE   customer_trx_id               =  p_customer_trx_id      -- CM
        AND     applied_customer_trx_id       =  p_previous_trx_id     -- INV
        AND     applied_payment_schedule_id   =  i.payment_schedule_id  -- payment_schedule_id of INV
        AND     display                       = 'Y'
        AND     status                        = 'APP'
        AND     application_type              = 'CM';

        lv_sql_statement := fnd_global.local_chr(10)||
                            'UPDATE ar_receivable_applications_all
                            SET     tax_applied                   =  '||p_arps_to||' * '||ln_apportion_ratio||',
                                    last_update_date              =  sysdate,
                                    last_updated_by               =  '||gn_bug_no||'
                            WHERE   customer_trx_id               =  '||p_customer_trx_id||'
                            AND     applied_customer_trx_id       =  '||p_previous_trx_id||'
                            AND     applied_payment_schedule_id   =  '||i.payment_schedule_id||'
                            AND     display                       = '||''''||'Y'||''''||'
                            AND     status                        = '||''''||'APP'||''''||'
                            AND     application_type              = '||''''||'CM'||''''||';';

        jai_cmn_utils_pkg.print_log(p_datafix_filename, lv_sql_statement);

        lv_sql_statement := NULL;

      ELSIF p_arps_fo IS NOT NULL THEN

        UPDATE  ar_receivable_applications_all
        SET     freight_applied               =  p_arps_fo * ln_apportion_ratio,
                last_update_date              =  sysdate,
                last_updated_by               =  gn_bug_no
        WHERE   customer_trx_id               =  p_customer_trx_id      -- CM
        AND     applied_customer_trx_id       =  p_previous_trx_id     -- INV
        AND     applied_payment_schedule_id   =  i.payment_schedule_id  -- payment_schedule_id of INV
        AND     display                       = 'Y'
        AND     status                        = 'APP'
        AND     application_type              = 'CM';

        lv_sql_statement := fnd_global.local_chr(10)||
                            'UPDATE ar_receivable_applications_all
                            SET     freight_applied               =  '||p_arps_fo||' * '||ln_apportion_ratio||',
                                    last_update_date              =  sysdate,
                                    last_updated_by               =  '||gn_bug_no||'
                            WHERE   customer_trx_id               =  '||p_customer_trx_id||'
                            AND     applied_customer_trx_id       =  '||p_previous_trx_id||'
                            AND     applied_payment_schedule_id   =  '||i.payment_schedule_id||'
                            AND     display                       = '||''''||'Y'||''''||'
                            AND     status                        = '||''''||'APP'||''''||'
                            AND     application_type              = '||''''||'CM'||''''||';';

        jai_cmn_utils_pkg.print_log(p_datafix_filename, lv_sql_statement);

        lv_sql_statement := NULL;
      END IF;

      IF lv_first_installment_code <> 'ALLOCATE' THEN
        EXIT;
      END IF;

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := jai_constants.unexpected_error;
      p_process_message := SUBSTR(SQLERRM,1,300);
  END rectify_ar_rec_appl;


  PROCEDURE pre_validation( p_customer_trx_id IN  ra_customer_trx_all.customer_trx_id%TYPE,
                            p_process_status  OUT NOCOPY  VARCHAR2,
                            p_process_message OUT NOCOPY  VARCHAR2)
  IS
    CURSOR cur_chk_non_il_taxes(cp_customer_trx_id  ra_customer_trx_all.customer_trx_id%TYPE)
    IS
    SELECT  1
    FROM    ra_customer_trx_lines_all  rctl,
            ar_vat_tax_all             avtl
    WHERE   rctl.vat_tax_id       =  avtl.vat_tax_id
    AND     rctl.org_id           =  avtl.org_id
    AND     rctl.customer_trx_id  =  cp_customer_trx_id
    AND     avtl.tax_code         <> jai_constants.tax_code_localization--'Localization' --Added by Bgowrava for Bug#5484865
    AND     rctl.org_id           =  rctl.org_id
    AND     rctl.line_type        IN ('TAX','FREIGHT') ;

    CURSOR cur_revrec_run(cp_customer_trx_id  ra_customer_trx_all.customer_trx_id%TYPE)
    IS
    SELECT  1
    FROM    ra_cust_trx_line_gl_dist_all gl_dist,
            ra_customer_trx_all        rctx
    WHERE   rctx.customer_trx_id      =  gl_dist.customer_trx_id
    AND     rctx.invoicing_rule_id    IS NOT NULL
    AND     gl_dist.account_class     = 'REC'
    AND     gl_dist.account_set_flag  = 'N'
    AND     gl_dist.latest_rec_flag   = 'Y'
    AND     gl_dist.customer_trx_id   =  cp_customer_trx_id;

    --added this cursor for bug#7445602
    CURSOR cur_chk_revrec_run_cm(cp_customer_trx_id  ra_customer_trx_all.customer_trx_id%TYPE)
    IS
    SELECT  count(*)
    FROM    ra_customer_trx_all rcta,
            ra_customer_trx_lines_all rctla,
            ra_cust_trx_types_all rctta
    WHERE   rcta.customer_trx_id = rctla.customer_trx_id
    AND     rcta.cust_trx_type_id = rctta.cust_trx_type_id
    AND     rctta.type = 'CM'
    AND     rctla. previous_customer_trx_id IS NOT NULL
    AND     rcta.customer_trx_id = cp_customer_trx_id;

    CURSOR cur_chk_gl_posting(cp_customer_trx_id  ra_customer_trx_all.customer_trx_id%TYPE)
    IS
    SELECT  1
    FROM    ra_cust_trx_line_gl_dist_all
    WHERE   customer_trx_id    =  cp_customer_trx_id
    AND     account_set_flag   = 'N'
    AND     posting_control_id <> -3
    AND     rownum             = 1;

    ln_exists   NUMBER;
    ln_cnt      NUMBER; --added for bug#7445602

  BEGIN
    p_process_status := jai_constants.successful;
    p_process_message := NULL;

    OPEN  cur_chk_non_il_taxes(p_customer_trx_id);
    FETCH cur_chk_non_il_taxes INTO ln_exists;
    CLOSE cur_chk_non_il_taxes;

    IF ln_exists = 1 THEN
      p_process_status     := jai_constants.expected_error;
      p_process_message  := 'Invoice lines have taxes other than localization type of tax. Please delete it and reprocess the invoice';
      goto EXIT_POINT;
    END IF;

    OPEN  cur_revrec_run(p_customer_trx_id);
    FETCH cur_revrec_run INTO ln_exists ;
    CLOSE cur_revrec_run;

    IF ln_exists = 1 THEN
      --added for bug#7445602,start
      OPEN  cur_chk_revrec_run_cm(p_customer_trx_id);
      FETCH cur_chk_revrec_run_cm INTO ln_cnt;
      CLOSE cur_chk_revrec_run_cm;
      --bug#7445602,end

      IF ln_cnt = 0 THEN --added the IF condition for bug#7445602
        p_process_status     := jai_constants.expected_error;
        p_process_message  := 'Invoice has already been revenue recognised. Taxes related to invoice cannot be processed';
        goto EXIT_POINT;
      END IF;
    END IF;

    ln_exists := 0;

    OPEN  cur_chk_gl_posting(p_customer_trx_id);
    FETCH cur_chk_gl_posting INTO ln_exists ;
    CLOSE cur_chk_gl_posting;

    IF ln_exists = 1 THEN
      p_process_status     := jai_constants.expected_error;
      p_process_message  := 'Invoice has already been GL posted. Taxes related to this invoice cannot be processed';
      goto EXIT_POINT;
    END IF;

    <<EXIT_POINT>>
    NULL;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status  := jai_constants.unexpected_error;
      p_process_message := 'For Customer trx id - '||p_customer_trx_id||SUBSTR(SQLERRM,1,300);
  END pre_validation;

  PROCEDURE post_validation(p_start_date          IN  DATE      DEFAULT NULL,
                            p_end_date            IN  DATE      DEFAULT NULL,
                            p_customer_trx_id     IN  NUMBER    DEFAULT NULL,
                            p_validate_first      IN  VARCHAR2  DEFAULT 'N',
                            p_validate_all        IN  VARCHAR2  DEFAULT 'N',
                            p_generate_log        IN  VARCHAR2  DEFAULT 'N',
                            p_generate_detail_log IN  VARCHAR2  DEFAULT 'N',
                            p_fix_data            IN  VARCHAR2  DEFAULT 'N',
                            p_commit              IN  VARCHAR2  DEFAULT 'N',
                            p_log_filename        IN  VARCHAR2  DEFAULT NULL,
                            p_debug               IN  VARCHAR2  DEFAULT 'N',
                            p_process_status      OUT NOCOPY VARCHAR2,
                            p_process_message     OUT NOCOPY VARCHAR2)
  IS

    CURSOR cur_get_cust_trx(cp_start_date       DATE,
                            cp_end_date         DATE,
                            cp_customer_trx_id  NUMBER)
    IS
    SELECT  rcta.customer_trx_id,
            rcta.previous_customer_trx_id,
            rcta.set_of_books_id         ,
            rctta.type
    FROM    ra_customer_trx_all     rcta  ,
            JAI_AR_TRXS   jrcta ,
            ra_cust_trx_types_all   rctta  /* added by aiyer to check that only INV and CM type of transactions are picked up */
    WHERE   rcta.customer_trx_id  = jrcta.customer_trx_id
    AND     rcta.cust_trx_type_id = rctta.cust_trx_type_id
    AND     nvl(rctta.type,'###') IN ('INV','CM')
    AND     jrcta.customer_trx_id = NVL(cp_customer_trx_id, jrcta.customer_trx_id)
    AND     trunc(rcta.trx_date)  BETWEEN NVL(cp_start_date, trunc(rcta.trx_date)) AND NVL(cp_end_date, trunc(rcta.trx_date))
    AND     nvl(rcta.complete_flag,'N') = 'Y'
    ORDER BY rcta.customer_trx_id;

    --check if revenue recognition program has been run
    CURSOR cur_revrec_run(cp_customer_trx_id  ra_customer_trx_all.customer_trx_id%TYPE)
    IS
    SELECT  1
    FROM    ra_cust_trx_line_gl_dist_all gl_dist,
            ra_customer_trx_all        rctx
    WHERE   rctx.customer_trx_id      =  gl_dist.customer_trx_id
    AND     rctx.invoicing_rule_id    IS NOT NULL
    AND     gl_dist.account_class     = 'REC'
    AND     gl_dist.account_set_flag  = 'N'
    AND     gl_dist.latest_rec_flag   = 'Y'
    AND     gl_dist.customer_trx_id   =  cp_customer_trx_id;

    --Get 1 if record has not been posted else null if posted
    CURSOR cur_chk_gl_posting(cp_customer_trx_id  ra_customer_trx_all.customer_trx_id%TYPE)
    IS
    SELECT  1
    FROM    ra_cust_trx_line_gl_dist_all
    WHERE   customer_trx_id    =  cp_customer_trx_id
    AND     account_set_flag   = 'N'
    AND     account_class      = 'REC'
    AND     latest_rec_flag    = 'Y'
    AND     posting_control_id = -3;

    CURSOR cur_tot_payment_schedule(cp_customer_trx_id  ra_customer_trx_all.customer_trx_id%TYPE)
    IS
    SELECT  NVL(SUM(amount_due_remaining),0) amount_due_remaining,
            NVL(SUM(amount_due_original),0) amount_due_original,
            NVL(SUM(tax_original),0) tax_original,
            NVL(SUM(freight_original),0) freight_original,
            NVL(SUM(tax_remaining),0) tax_remaining,
            NVL(SUM(freight_remaining),0) freight_remaining,
            NVL(SUM(amount_applied),0) amount_applied,
            NVL(SUM(amount_credited),0) amount_credited,
            NVL(SUM(amount_line_items_original),0) amount_line_items_original,
            NVL(SUM(amount_line_items_remaining),0) amount_line_items_remaining,
            NVL(SUM(acctd_amount_due_remaining),0) acctd_amount_due_remaining,
            NVL(SUM( NVL(amount_due_remaining,0) * NVL(exchange_rate,1) ),0) acctd_amount_due_remain_calc
    FROM    ar_payment_schedules_all
    WHERE   customer_trx_id = cp_customer_trx_id;

    CURSOR cur_payment_schedules(cp_customer_trx_id ra_customer_trx_all.customer_trx_id%TYPE)
    IS
    SELECT  status,
            gl_date_closed,
            NVL(amount_due_remaining,0) amount_due_remaining,
            NVL(acctd_amount_due_remaining,0) acctd_amount_due_remaining,
            payment_schedule_id,
            exchange_rate
    FROM    ar_payment_schedules_all
    WHERE   customer_trx_id = cp_customer_trx_id;

    CURSOR cur_tot_cust_trx_gl_dist(cp_customer_trx_id        ra_customer_trx_all.customer_trx_id%TYPE,
                                    cp_account_class          ra_cust_trx_line_gl_dist_all.account_class%TYPE)
    IS
    SELECT  NVL(SUM(amount),0) amount,
            NVL(SUM(acctd_amount),0) acctd_amount
    FROM    ra_cust_trx_line_gl_dist_all
    WHERE   customer_trx_id = cp_customer_trx_id
    AND     (
              (     account_class = 'REC'
                AND latest_rec_flag = 'Y'
              )
            OR
              (account_class <> 'REC')
            )
    AND     account_class = NVL(cp_account_class, account_class);

    CURSOR cur_il_tax_amount(cp_customer_trx_id   JAI_AR_TRX_LINES.customer_trx_id%TYPE)
    IS
    SELECT  rctl.customer_trx_id,
            jrcttl.customer_trx_line_id,
            jrcttl.tax_amount
    FROM    JAI_AR_TRX_TAX_LINES jrcttl,
            JAI_AR_TRX_LINES jrctl,
            ra_customer_trx_lines_all rctl
    WHERE   jrcttl.link_to_cust_trx_line_id   = jrctl.customer_trx_line_id
    AND     jrcttl.customer_Trx_line_id       = rctl.customer_trx_line_id
    AND     nvl(jrcttl.tax_amount,0)          <> nvl(rctl.extended_amount,0)
    AND     rctl.customer_trx_id              = jrctl.customer_trx_id
    AND     jrctl.customer_trx_id             = cp_customer_trx_id
    AND     rctl.line_type                    IN ('TAX','FREIGHT');

    CURSOR cur_cust_trx_gl_dist_tax (cp_customer_trx_id   JAI_AR_TRX_LINES.customer_trx_id%TYPE)
    IS
    SELECT  gl_dist.customer_trx_id,
            jrcttl.customer_trx_line_id,
            jrcttl.tax_amount          ,
            jrcttl.func_tax_amount
    FROM    JAI_AR_TRX_TAX_LINES jrcttl,
            JAI_AR_TRX_LINES jrctl,
            ra_cust_trx_line_gl_dist_all gl_dist
    WHERE   jrcttl.link_to_cust_trx_line_id   = jrctl.customer_trx_line_id
    AND     jrcttl.customer_Trx_line_id       = gl_dist.customer_trx_line_id
    AND     (ROUND(nvl(jrcttl.tax_amount,0))        <> ROUND(nvl(gl_dist.amount,0))
             AND -- Need to check further if there is a way out in case tax amount in ja tax table itself is wrong ???
             ROUND(nvl(jrcttl.func_tax_amount,0))   <> ROUND(nvl(gl_dist.acctd_amount,0))
            )
    AND     gl_dist.customer_trx_id           = jrctl.customer_trx_id
    AND     jrctl.customer_trx_id             = cp_customer_trx_id
    AND     gl_dist.account_class             IN ('TAX','FREIGHT');



    CURSOR cur_chk_gl_dist_rctl (cp_customer_trx_id JAI_AR_TRX_LINES.customer_trx_id%TYPE)
    IS
    SELECT
           gl_dist.customer_trx_line_id ,
           gl_dist.amount                amount
    FROM   ra_cust_trx_line_gl_dist_all  gl_dist,
           ra_customer_trx_lines_all     rctl
    WHERE  gl_dist.customer_trx_id      = rctl.customer_trx_id
    AND    gl_dist.customer_trx_line_id = rctl.customer_trx_line_id
    AND    gl_dist.account_class        IN ('TAX','FREIGHT')
    AND    rctl.line_type               IN ('TAX','FREIGHT')
    AND    ROUND(nvl(gl_dist.amount,0))        <> ROUND(nvl(extended_amount,0))
    AND    gl_dist.customer_trx_id      = cp_customer_trx_id ;


    CURSOR cur_cm_ar_recv_appl( cp_customer_trx_id    ra_customer_trx_all.customer_trx_id%TYPE,
                                cp_exchange_rate      ra_customer_trx_all.exchange_rate%TYPE,
                                cp_exchange_rate_prev ra_customer_trx_all.exchange_rate%TYPE)
    IS
    SELECT  NVL(SUM(line_applied),0)                     line_applied,
            NVL(SUM(tax_applied),0)                      tax_applied,
            NVL(SUM(freight_applied),0)                  freight_applied,
            NVL(SUM(amount_applied),0)                   amount_applied,
            NVL(SUM(acctd_amount_applied_from),0)        acctd_amount_applied_from,
            NVL(SUM(acctd_amount_applied_to),0)          acctd_amount_applied_to,
            NVL(SUM( NVL(amount_applied,0) * cp_exchange_rate),0) acctd_amount_applied_from_calc,
            NVL(SUM( NVL(amount_applied,0) * cp_exchange_rate_prev),0) acctd_amount_applied_to_calc
    FROM    ar_receivable_applications_all
    WHERE   customer_trx_id   = cp_customer_trx_id
    AND     application_type  = 'CM'
    AND     display           = 'Y'
    AND     status            = 'APP';

    --Validate that a Invoice has a 'CM' type of receivable application.
    --This would be used for validating correctness of invoices w.r.t their receivable applications
    CURSOR cur_chk_cm_exists (cp_customer_trx_id    ra_customer_trx_all.customer_trx_id%TYPE)
    IS
    SELECT application_type
    FROM   ar_receivable_applications_all
    WHERE  applied_customer_trx_id  = cp_customer_trx_id
    AND    application_type         = 'CM'
    AND    display                  = 'Y'
    AND    status                   = 'APP';

    CURSOR cur_inv_cash_cm_recv_appl(cp_customer_trx_id    ra_customer_trx_all.customer_trx_id%TYPE)
    IS
    SELECT  NVL(SUM(line_applied),0) line_applied,
            NVL(SUM(tax_applied),0) tax_applied,
            NVL(SUM(freight_applied),0) freight_applied,
            NVL(SUM(amount_applied),0) amount_applied
    FROM    ar_receivable_applications_all
    WHERE   applied_customer_trx_id   = cp_customer_trx_id
    AND     application_type  IN ('CM' ,'CASH')
    AND     display           = 'Y'
    AND     status            = 'APP';

    CURSOR cur_inv_ar_recv_appl(cp_customer_trx_id    ra_customer_trx_all.customer_trx_id%TYPE)
    IS
    SELECT  NVL(SUM(line_applied),0) line_applied,
            NVL(SUM(tax_applied),0) tax_applied,
            NVL(SUM(freight_applied),0) freight_applied,
            NVL(SUM(amount_applied),0) amount_applied
    FROM    ar_receivable_applications_all
    WHERE   applied_customer_trx_id   = cp_customer_trx_id
    AND     application_type  = 'CM'
    AND     display           = 'Y'
    AND     status            = 'APP';

    CURSOR cur_ra_customer_trx(cp_customer_trx_id   ra_customer_trx_all.customer_trx_id%TYPE)
    IS
    SELECT  NVL(exchange_rate,1) exchange_rate,
            set_of_books_id
    FROM    ra_customer_trx_all
    WHERE   customer_trx_id = cp_customer_trx_id;

    CURSOR cur_utl_location
    IS
    SELECT  DECODE(SUBSTR (value,1,INSTR(value,',') -1),NULL,Value,SUBSTR (value,1,INSTR(value,',') -1)) utl_location
    FROM    v$parameter
    WHERE   name = 'utl_file_dir';

    CURSOR cur_sync_il_line_tax (cp_customer_trx_id  ra_customer_trx_all.customer_trx_id%TYPE)
    IS
    SELECT    jrctl.customer_trx_line_id,
              nvl(sum(jrcttl.tax_amount),0) tax_amount
    FROM      JAI_AR_TRX_LINES jrctl,
              JAI_AR_TRX_TAX_LINES jrcttl
    WHERE     jrctl.customer_trx_line_id = jrcttl.link_to_cust_trx_line_id
    AND       jrctl.customer_trx_id      = cp_customer_trx_id
    GROUP BY  jrctl.customer_trx_line_id
    HAVING    ROUND(nvl(sum(jrcttl.tax_amount),0)) <>(  SELECT  ROUND(NVL(tax_amount,0))
                                                        FROM    JAI_AR_TRX_LINES a
                                                        WHERE   a.customer_trx_line_id = jrctl.customer_trx_line_id);

    CURSOR cur_sync_il_hdr_tax (cp_customer_trx_id  ra_customer_trx_all.customer_trx_id%TYPE)
    IS
    SELECT    jtrx.customer_trx_id              ,
              NVL(SUM(jrctl.tax_amount),0) tax_amount
    FROM      JAI_AR_TRX_LINES jrctl,
              JAI_AR_TRXS jtrx
    WHERE     jrctl.customer_trx_id      = cp_customer_trx_id
    AND       jrctl.customer_trx_id      = jtrx.customer_trx_id
    GROUP BY  jtrx.customer_trx_id
    HAVING    ROUND(NVL(SUM(jrctl.tax_amount),0)) <> (  SELECT  ROUND(NVL(tax_amount,0))
                                                        FROM    JAI_AR_TRXS a
                                                        WHERE   a.customer_trx_id = jtrx.customer_trx_id);

    lv_utl_location     VARCHAR2(512);
    ln_file_hdl         UTL_FILE.FILE_TYPE;
    lv_process_status   VARCHAR2(2);
    lv_process_message  VARCHAR2(1000);

    rec_tot_payment_schedule      cur_tot_payment_schedule%ROWTYPE;
    rec_tot_payment_schedule_inv  cur_tot_payment_schedule%ROWTYPE;
    rec_tot_cust_trx_gl_dist_rec  cur_tot_cust_trx_gl_dist%ROWTYPE;
    rec_tot_cust_trx_gl_dist_tax  cur_tot_cust_trx_gl_dist%ROWTYPE;
    rec_tot_cust_trx_gl_dist_frt  cur_tot_cust_trx_gl_dist%ROWTYPE;
    rec_il_tax_amount             cur_il_tax_amount%ROWTYPE;
    rec_cust_trx_gl_dist_tax      cur_cust_trx_gl_dist_tax%ROWTYPE;
    rec_payment_schedules         cur_payment_schedules%ROWTYPE;
    rec_cm_ar_recv_appl           cur_cm_ar_recv_appl%ROWTYPE;
    rec_ra_customer_trx           cur_ra_customer_trx%ROWTYPE;
    rec_ra_customer_trx_prev      cur_ra_customer_trx%ROWTYPE;
    rec_inv_cash_cm_recv_appl     cur_inv_cash_cm_recv_appl%ROWTYPE;
    rec_inv_ar_recv_appl          cur_inv_ar_recv_appl%ROWTYPE;
    rec_chk_cm_exists             cur_chk_cm_exists%ROWTYPE;
    rec_chk_gl_dist_rctl          cur_chk_gl_dist_rctl%ROWTYPE;

    lv_validate_first             VARCHAR2(1);
    lv_validate_all               VARCHAR2(1);
    lv_generate_log               VARCHAR2(1);
    lv_generate_detail_log        VARCHAR2(1);
    lv_fix_data                   VARCHAR2(1);
    lv_commit                     VARCHAR2(1);
    lv_debug                      VARCHAR2(1);
    lv_log_filename               VARCHAR2(100);
    lv_datafix_filename           VARCHAR2(100);
    ln_total_count                NUMBER;
    ln_err_num                    NUMBER;
    ln_local_cnt                  NUMBER;
    ln_error_cnt                  NUMBER;
    ln_precision                  NUMBER;
    lv_sql_statement              VARCHAR2(4000);
    ln_exists                     NUMBER;

    lt_error_table                jai_ar_validate_data_pkg.t_error_table;

  BEGIN
    p_process_status := jai_constants.successful;
    p_process_message := NULL;

    lv_validate_first       :=  p_validate_first;
    lv_validate_all         :=  p_validate_all;
    lv_generate_log         :=  p_generate_log;
    lv_generate_detail_log  :=  p_generate_detail_log;
    lv_fix_data             :=  p_fix_data;
    lv_commit               :=  p_commit;
    lv_debug                :=  p_debug;
    lv_log_filename         :=  p_log_filename;

    --Check to insure that either the process runs for a particular customer_trx_id OR start_date and end_date should be specified
    IF p_customer_trx_id IS NULL THEN
      IF p_start_date IS NULL OR p_end_date IS NULL THEN
        p_process_status := jai_constants.expected_error;
        p_process_message := 'Problem in call to procedure post_validation. If customer_trx_id is not given, then both start_date and end_date are required';

        GOTO exit_point;
      END IF;
    END IF;

    If lv_validate_first = 'Y' AND lv_validate_all = 'Y' THEN
      p_process_status := jai_constants.expected_error;
      p_process_message := 'Problem in call to procedure post_validation. Only one of these parameter - p_validate_first, p_validate_all should be Y';

      GOTO exit_point;
    ELSIF lv_validate_first = 'N' AND lv_validate_all = 'N' THEN
      p_process_status := jai_constants.expected_error;
      p_process_message := 'Problem in call to procedure post_validation. Only one of these parameter - p_validate_first, p_validate_all should be N';

      GOTO exit_point;
    END IF;

    If lv_validate_first = 'Y' THEN
      lv_generate_log := 'N';
      lv_fix_data     := 'N';
      lv_commit       := 'N';
    END IF;

    If lv_fix_data = 'Y' THEN
      lv_generate_log := 'Y';
      lv_generate_detail_log := 'Y';
    END IF;

    If lv_commit = 'Y' AND lv_fix_data = 'N' THEN
      p_process_status := jai_constants.expected_error;
      p_process_message := 'Problem in call to procedure post_validation. p_commit can be Y only if fix_data = Y';

      GOTO exit_point;
      NULL;
    END IF;

    IF lv_generate_detail_log = 'Y' THEN
      lv_generate_log := 'Y';
    END IF;

    IF lv_generate_log = 'Y' THEN

      OPEN  cur_utl_location;
      FETCH cur_utl_location INTO lv_utl_location;
      CLOSE cur_utl_location;

      IF p_log_filename IS NULL THEN

        IF p_customer_trx_id IS NOT NULL THEN
          lv_log_filename := 'jai_ar_recon_'||p_customer_trx_id||'.log';
          lv_datafix_filename := 'jai_ar_recon_datafix_'||p_customer_trx_id||'.log';
        ELSIF p_start_date IS NOT NULL THEN
          lv_log_filename := 'jai_ar_recon_'||TO_CHAR(p_start_date,'YYYYMMDD')||'.log';
          lv_datafix_filename := 'jai_ar_recon_datafix_'||TO_CHAR(p_start_date,'YYYYMMDD')||'.log';
        ELSE
          lv_log_filename := 'jai_ar_recon.log';
          lv_datafix_filename := 'jai_ar_recon_datafix.log';
        END IF;

        ln_file_hdl := UTL_FILE.FOPEN (lv_utl_location, lv_log_filename,'W');
        UTL_FILE.FCLOSE (ln_file_hdl);

        ln_file_hdl := UTL_FILE.FOPEN (lv_utl_location, lv_datafix_filename,'W');
        UTL_FILE.FCLOSE (ln_file_hdl);

      ELSE
        lv_log_filename := p_log_filename;
        lv_datafix_filename := NVL(SUBSTR(lv_log_filename,1,instr(lv_log_filename,'.',1,1)-1),lv_log_filename)||'_datafix'||substr(lv_log_filename,instr(lv_log_filename,'.',1,1));
      END IF;
    END IF;

    IF lv_log_filename IS NULL THEN
      lv_log_filename := 'jai_ar_recon.log';
    END IF;

    SAVEPOINT start_program;

    IF lv_generate_log = 'Y' THEN
      jai_cmn_utils_pkg.print_log(lv_log_filename, 'Start of JAI AR Reconcilation program at '||TO_CHAR(sysdate,'DD-MON-YYYY HH24:MI:SS'));
    END IF;

    ln_total_count := 0;

    populate_error_table( p_error_table     =>  lt_error_table,
                          p_process_status  =>  lv_process_status,
                          p_process_message =>  lv_process_message);

    IF lv_process_status <> jai_constants.successful THEN
      p_process_status := lv_process_status;
      p_process_message := lv_process_message;

      GOTO exit_point;
    END IF;

    /**************************************
    ||Start of processing
    ***************************************/
    FOR rec_get_cust_trx IN cur_get_cust_trx( p_start_date,
                                              p_end_date,
                                              p_customer_trx_id)
    LOOP

      ln_error_cnt := 0;

      IF lv_generate_detail_log = 'Y' THEN
        jai_cmn_utils_pkg.print_log(lv_log_filename, fnd_global.local_chr(10));
        jai_cmn_utils_pkg.print_log(lv_log_filename, 'Started processing customer_trx_id : '||rec_get_cust_trx.customer_trx_id);
      END IF;

      ln_total_count := ln_total_count + 1;

      ln_exists := null;

      OPEN  cur_revrec_run(cp_customer_trx_id => rec_get_cust_trx.customer_trx_id );
      FETCH cur_revrec_run INTO ln_exists ;

      IF cur_revrec_run%found THEN

        --As revenue recognition program has already been run on this customer_trx_id hence skip this and go to next record.
        IF lv_generate_detail_log = 'Y' THEN
          jai_cmn_utils_pkg.print_log(lv_log_filename, fnd_global.local_chr(10));
          jai_cmn_utils_pkg.print_log(lv_log_filename, 'Revenue recognition program has already been run on the customer_trx_id : '||rec_get_cust_trx.customer_trx_id);
        END IF;

        CLOSE cur_revrec_run;
        goto exit_point;
      END IF;
      CLOSE cur_revrec_run;

      rec_il_tax_amount := NULL;

      OPEN cur_il_tax_amount(rec_get_cust_trx.customer_trx_id);
      FETCH cur_il_tax_amount INTO rec_il_tax_amount;
      CLOSE cur_il_tax_amount;

      rec_cust_trx_gl_dist_tax := NULL;

      OPEN cur_cust_trx_gl_dist_tax(rec_get_cust_trx.customer_trx_id);
      FETCH cur_cust_trx_gl_dist_tax INTO rec_cust_trx_gl_dist_tax;
      CLOSE cur_cust_trx_gl_dist_tax;

      OPEN cur_tot_payment_schedule(rec_get_cust_trx.customer_trx_id);
      FETCH cur_tot_payment_schedule INTO rec_tot_payment_schedule;
      CLOSE cur_tot_payment_schedule;

      OPEN cur_tot_cust_trx_gl_dist(rec_get_cust_trx.customer_trx_id,
                                    'REC');
      FETCH cur_tot_cust_trx_gl_dist INTO rec_tot_cust_trx_gl_dist_rec;
      CLOSE cur_tot_cust_trx_gl_dist;

      OPEN cur_tot_cust_trx_gl_dist(rec_get_cust_trx.customer_trx_id,
                                    'TAX');
      FETCH cur_tot_cust_trx_gl_dist INTO rec_tot_cust_trx_gl_dist_tax;
      CLOSE cur_tot_cust_trx_gl_dist;

      OPEN cur_tot_cust_trx_gl_dist(rec_get_cust_trx.customer_trx_id,
                                    'FREIGHT');
      FETCH cur_tot_cust_trx_gl_dist INTO rec_tot_cust_trx_gl_dist_frt;
      CLOSE cur_tot_cust_trx_gl_dist;

      OPEN cur_ra_customer_trx(rec_get_cust_trx.customer_trx_id);
      FETCH cur_ra_customer_trx INTO rec_ra_customer_trx;
      CLOSE cur_ra_customer_trx;

      OPEN cur_ra_customer_trx(rec_get_cust_trx.previous_customer_trx_id);
      FETCH cur_ra_customer_trx INTO rec_ra_customer_trx_prev;
      CLOSE cur_ra_customer_trx;

      rec_chk_cm_exists := null;

      OPEN  cur_chk_cm_exists (cp_customer_trx_id => rec_get_cust_trx.customer_trx_id);
      FETCH cur_chk_cm_exists INTO rec_chk_cm_exists;
      CLOSE cur_chk_cm_exists ;

      --=================================================================================================================--
                                              --Start of common validations--
      --=================================================================================================================--
      ln_exists := null;

      --Get 1 if record has not been posted else null if posted
      OPEN cur_chk_gl_posting(cp_customer_trx_id  => rec_get_cust_trx.customer_trx_id);
      FETCH cur_chk_gl_posting INTO ln_exists;
      CLOSE cur_chk_gl_posting;

      IF nvl(ln_exists,0) = 1 THEN

        --Record has not been posted hence process

        ln_err_num := 1;
        --To check if the data in ja_in_ra_cust_trx_tax_lines is in sync with 'TAX'/'FREIGHT' records in ra_customer_trx_lines_all
        IF lt_error_table(ln_err_num).enable = 'Y' THEN
          IF rec_il_tax_amount.customer_trx_line_id IS NOT NULL THEN
            lv_process_status := jai_constants.expected_error;
            lv_process_message := lt_error_table(ln_err_num).error_description;

            if lv_validate_first = 'Y' THEN
              goto EXIT_POINT;
            END IF;

            lt_error_table(ln_err_num).error_record_count :=  lt_error_table(ln_err_num).error_record_count + 1;

            If lv_generate_detail_log = 'Y' THEN
              jai_cmn_utils_pkg.print_log(lv_log_filename, '  Encountered the error - '||lt_error_table(ln_err_num).error_description);
            END IF;

            IF lv_generate_log = 'Y' THEN
              IF ln_error_cnt = 0 THEN
                jai_cmn_utils_pkg.print_log(lv_log_filename, fnd_global.local_chr(10));
                jai_cmn_utils_pkg.print_log(lv_datafix_filename, '--Datafix for customer_trx_id : '||rec_get_cust_trx.customer_trx_id);
              END IF;

              ln_error_cnt := 1;

              FOR i IN cur_il_tax_amount(rec_get_cust_trx.customer_trx_id)
              LOOP
                UPDATE  ra_customer_trx_lines_all
                SET     extended_amount = i.tax_amount,
                        last_update_date  = sysdate,
                        last_updated_by   = gn_bug_no
                WHERE   customer_trx_line_id = i.customer_trx_line_id
                AND     customer_trx_id      = i.customer_trx_id;

                lv_sql_statement :=  fnd_global.local_chr(10)||
                                    'UPDATE   ra_customer_trx_lines_all'||fnd_global.local_chr(10)||
                                    'SET      extended_amount = '||i.tax_amount||','||fnd_global.local_chr(10)||
                                    '         last_update_date  = sysdate,'||fnd_global.local_chr(10)||
                                    '         last_updated_by   = '||gn_bug_no||fnd_global.local_chr(10)||
                                    'WHERE  customer_trx_line_id = '||i.customer_trx_line_id||fnd_global.local_chr(10)||
                                    'AND    customer_trx_id      = '||i.customer_trx_id||';';

                jai_cmn_utils_pkg.print_log(lv_datafix_filename, lv_sql_statement);

                lv_sql_statement := NULL;

              END LOOP;

            END IF;

          END IF;
        END IF;

        ln_err_num := 2;
        --To check if the data is correct in ja_in_ra_cust_trx_tax_lines corresponding to records in ra_cust_trx_line_gl_dist_all
        IF lt_error_table(ln_err_num).enable = 'Y' THEN
          IF rec_cust_trx_gl_dist_tax.customer_trx_line_id IS NOT NULL THEN

            lv_process_status := jai_constants.expected_error;
            lv_process_message := lt_error_table(ln_err_num).error_description;

            if lv_validate_first = 'Y' THEN
              goto EXIT_POINT;
            END IF;

            lt_error_table(ln_err_num).error_record_count :=  lt_error_table(ln_err_num).error_record_count + 1;

            If lv_generate_detail_log = 'Y' THEN
              jai_cmn_utils_pkg.print_log(lv_log_filename, '  Encountered the error - '||lt_error_table(ln_err_num).error_description);
            END IF;

            IF lv_generate_log = 'Y' THEN

              IF ln_error_cnt = 0 THEN
                jai_cmn_utils_pkg.print_log(lv_log_filename, fnd_global.local_chr(10));
                jai_cmn_utils_pkg.print_log(lv_datafix_filename, '--Datafix for customer_trx_id : '||rec_get_cust_trx.customer_trx_id);
              END IF;

              ln_error_cnt := 1;

              ln_precision :=  null;

              OPEN  jai_ar_validate_data_pkg.cur_curr_precision(rec_ra_customer_trx.set_of_books_id);
              FETCH jai_ar_validate_data_pkg.cur_curr_precision INTO ln_precision;
              CLOSE jai_ar_validate_data_pkg.cur_curr_precision;

              /*
              || set ra_cust_trx_line_gl_dist_all.amount = il.tax_amount for all account_class in TAX and 'FREIGHT'
              */
              FOR i IN cur_cust_trx_gl_dist_tax(rec_get_cust_trx.customer_trx_id)
              LOOP
                UPDATE  ra_cust_trx_line_gl_dist_all
                SET     amount       = i.tax_amount,
                        acctd_amount = round(i.func_tax_amount,ln_precision),
                        last_update_date  = sysdate,
                        last_updated_by   = gn_bug_no
                WHERE   customer_trx_line_id = i.customer_trx_line_id
                AND     customer_trx_id      = i.customer_trx_id;

                lv_sql_statement := fnd_global.local_chr(10)||
                                    'UPDATE   ra_cust_trx_line_gl_dist_all'||fnd_global.local_chr(10)||
                                    'SET      amount       = '||i.tax_amount||','||fnd_global.local_chr(10)||
                                    '         acctd_amount = round('||i.func_tax_amount||','||ln_precision||'),'||fnd_global.local_chr(10)||
                                    '         last_update_date  = sysdate,'||fnd_global.local_chr(10)||
                                    '         last_updated_by   = '||gn_bug_no||fnd_global.local_chr(10)||
                                    'WHERE    customer_trx_line_id = '||i.customer_trx_line_id||fnd_global.local_chr(10)||
                                    'AND      customer_trx_id      = '||i.customer_trx_id||';';

                jai_cmn_utils_pkg.print_log(lv_datafix_filename, lv_sql_statement);

                lv_sql_statement := NULL;

              END LOOP;

              /*
              || set REC.extended_amt = SUM ( all rows except REC for that customer_trx_id ) and latest
              */
              UPDATE  ra_cust_trx_line_gl_dist_all rec
              SET     amount = (SELECT nvl(sum(amount),0)
                                FROM   ra_cust_trx_line_gl_dist_all rev_tax_frt
                                WHERE   rec.customer_trx_id = rev_tax_frt.customer_trx_id
                                AND     rev_tax_frt.account_class <> 'REC'
                               ),
                      acctd_amount        = (SELECT nvl(sum(acctd_amount),0)
                                             FROM   ra_cust_trx_line_gl_dist_all rev_tax_frt
                                             WHERE  rec.customer_trx_id = rev_tax_frt.customer_trx_id
                                             AND    rev_tax_frt.account_class <> 'REC'
                                            ),
                        last_update_date  = sysdate,
                        last_updated_by   = gn_bug_no
              WHERE   rec.account_class   = 'REC'
              AND     rec.latest_rec_flag = 'Y'
              AND     customer_trx_id     = rec_get_cust_trx.customer_trx_id;

              lv_sql_statement :=   fnd_global.local_chr(10)||
                                  'UPDATE   ra_cust_trx_line_gl_dist_all rec
                                  SET     amount = (SELECT nvl(sum(amount),0)
                                                    FROM   ra_cust_trx_line_gl_dist_all rev_tax_frt
                                                    WHERE   rec.customer_trx_id = rev_tax_frt.customer_trx_id
                                                    AND     rev_tax_frt.account_class <> '||''''||'REC'||''''||
                                                   '),
                                          acctd_amount        = (SELECT nvl(sum(acctd_amount),0)
                                                                 FROM   ra_cust_trx_line_gl_dist_all rev_tax_frt
                                                                 WHERE  rec.customer_trx_id = rev_tax_frt.customer_trx_id
                                                                 AND    rev_tax_frt.account_class <> '||''''||'REC'||''''||
                                                                '),
                                            last_update_date  = sysdate,
                                            last_updated_by   = '||gn_bug_no||'
                                  WHERE   rec.account_class   = '||''''||'REC'||''''||'
                                  AND     rec.latest_rec_flag = '||''''||'Y'||''''||'
                                  AND     customer_trx_id     = '||rec_get_cust_trx.customer_trx_id||';';

              jai_cmn_utils_pkg.print_log(lv_datafix_filename, lv_sql_statement);

              lv_sql_statement := NULL;


            END IF;

          END IF;
        END IF;
      END IF; -- End of Record has not been posted check


      OPEN cur_chk_gl_dist_rctl(cp_customer_trx_id  => rec_get_cust_trx.customer_trx_id);
      FETCH cur_chk_gl_dist_rctl INTO rec_chk_gl_dist_rctl;
      CLOSE cur_chk_gl_dist_rctl;

      ln_err_num := 11;

      --Check that ra_customer_Trx_lines_all is in sync with gl_dist
      IF lt_error_table(ln_err_num).enable = 'Y' THEN
        IF rec_chk_gl_dist_rctl.customer_trx_line_id IS NOT NULL THEN
          lv_process_status := jai_constants.expected_error;
          lv_process_message := lt_error_table(ln_err_num).error_description;

          if lv_validate_first = 'Y' THEN
            goto EXIT_POINT;
          END IF;

          lt_error_table(ln_err_num).error_record_count :=  lt_error_table(ln_err_num).error_record_count + 1;

          If lv_generate_detail_log = 'Y' THEN
            jai_cmn_utils_pkg.print_log(lv_log_filename, '  Encountered the error - '||lt_error_table(ln_err_num).error_description);
          END IF;

          IF lv_generate_log = 'Y' THEN

            IF ln_error_cnt = 0 THEN
              jai_cmn_utils_pkg.print_log(lv_log_filename, fnd_global.local_chr(10));
              jai_cmn_utils_pkg.print_log(lv_datafix_filename, '--Datafix for customer_trx_id : '||rec_get_cust_trx.customer_trx_id);
            END IF;

            ln_error_cnt := 1;

            FOR  rec_gl_dist_rctl in cur_chk_gl_dist_rctl (cp_customer_trx_id  => rec_get_cust_trx.customer_trx_id)
            LOOP
              UPDATE  ra_customer_trx_lines_all
              SET     extended_amount   = rec_gl_dist_rctl.amount,
                      last_update_date  = sysdate,
                      last_updated_by   = gn_bug_no
              WHERE   customer_trx_id       = rec_get_cust_trx.customer_trx_id
              AND     customer_trx_line_id  = rec_gl_dist_rctl.customer_trx_line_id;

              lv_sql_statement := fnd_global.local_chr(10)||
                                  'UPDATE ra_customer_trx_lines_all
                                  SET     extended_amount   = '||rec_gl_dist_rctl.amount||',
                                          last_update_date  = sysdate,
                                          last_updated_by   = '||gn_bug_no||'
                                  WHERE   customer_trx_id       = '||rec_get_cust_trx.customer_trx_id||'
                                  AND     customer_trx_line_id  = '||rec_gl_dist_rctl.customer_trx_line_id||';';

              jai_cmn_utils_pkg.print_log(lv_datafix_filename, lv_sql_statement);

              lv_sql_statement := NULL;

            END LOOP;
          END IF;
        END IF;
      END IF;

      ln_err_num := 3;
      --To check if ADO in ar_payment_schedules_all is equal to amount of REC in ra_cust_trx_line_gl_dist_all
      IF lt_error_table(ln_err_num).enable = 'Y' THEN
        IF rec_tot_payment_schedule.amount_due_original <> rec_tot_cust_trx_gl_dist_rec.amount THEN
          lv_process_status := jai_constants.expected_error;
          lv_process_message := lt_error_table(ln_err_num).error_description;

          if lv_validate_first = 'Y' THEN
            goto EXIT_POINT;
          END IF;

          lt_error_table(ln_err_num).error_record_count :=  lt_error_table(ln_err_num).error_record_count + 1;

          If lv_generate_detail_log = 'Y' THEN
            jai_cmn_utils_pkg.print_log(lv_log_filename, '  Encountered the error - '||lt_error_table(ln_err_num).error_description);
          END IF;

          /*
          ||arps.ado = gl_dist.rec
          */

          IF lv_generate_log = 'Y' THEN

            IF ln_error_cnt = 0 THEN
              jai_cmn_utils_pkg.print_log(lv_log_filename, fnd_global.local_chr(10));
              jai_cmn_utils_pkg.print_log(lv_datafix_filename, '--Datafix for customer_trx_id : '||rec_get_cust_trx.customer_trx_id);
            END IF;

            ln_error_cnt := 1;

            rectify_ar_pay_sch(p_customer_trx_id    => rec_get_cust_trx.customer_trx_id,
                              p_gl_rec_amount       => rec_tot_cust_trx_gl_dist_rec.amount,
                              p_datafix_filename    => lv_datafix_filename,
                              p_process_status      => lv_process_status,
                              p_process_message     => lv_process_message);
          END IF;
        END IF;
      END IF;

      ln_err_num := 4;
      --To check if TO in ar_payment_schedules_all is equal to amount of TAX in ra_cust_trx_line_gl_dist_all
      IF lt_error_table(ln_err_num).enable = 'Y' THEN
        IF rec_tot_payment_schedule.tax_original <> rec_tot_cust_trx_gl_dist_tax.amount THEN
          lv_process_status := jai_constants.expected_error;
          lv_process_message := lt_error_table(ln_err_num).error_description;

          if lv_validate_first = 'Y' THEN
            goto EXIT_POINT;
          END IF;

          lt_error_table(ln_err_num).error_record_count :=  lt_error_table(ln_err_num).error_record_count + 1;

          If lv_generate_detail_log = 'Y' THEN
            jai_cmn_utils_pkg.print_log(lv_log_filename, '  Encountered the error - '||lt_error_table(ln_err_num).error_description);
          END IF;

          /*
          ||arps.to  = gl_dist.tax
          */

          IF lv_generate_log = 'Y' THEN

            IF ln_error_cnt = 0 THEN
              jai_cmn_utils_pkg.print_log(lv_log_filename, fnd_global.local_chr(10));
              jai_cmn_utils_pkg.print_log(lv_datafix_filename, '--Datafix for customer_trx_id : '||rec_get_cust_trx.customer_trx_id);
            END IF;

            ln_error_cnt := 1;

            rectify_ar_pay_sch(p_customer_trx_id    => rec_get_cust_trx.customer_trx_id,
                              p_gl_tax_amount       => rec_tot_cust_trx_gl_dist_tax.amount,
                              p_datafix_filename    => lv_datafix_filename,
                              p_process_status      => lv_process_status,
                              p_process_message     => lv_process_message);
          END IF;
        END IF;
      END IF;

      ln_err_num := 5;
      --To check if FO in ar_payment_schedules_all is equal to amount of FREIGHT in ra_cust_trx_line_gl_dist_all
      IF lt_error_table(ln_err_num).enable = 'Y' THEN
        IF rec_tot_payment_schedule.freight_original <> rec_tot_cust_trx_gl_dist_frt.amount THEN
          lv_process_status := jai_constants.expected_error;
          lv_process_message := lt_error_table(ln_err_num).error_description;

          if lv_validate_first = 'Y' THEN
            goto EXIT_POINT;
          END IF;

          lt_error_table(ln_err_num).error_record_count :=  lt_error_table(ln_err_num).error_record_count + 1;

          If lv_generate_detail_log = 'Y' THEN
            jai_cmn_utils_pkg.print_log(lv_log_filename, '  Encountered the error - '||lt_error_table(ln_err_num).error_description);
          END IF;

          /*
          ||arps.FO  = gl_dist.FRT
          */

          IF lv_generate_log = 'Y' THEN

            IF ln_error_cnt = 0 THEN
              jai_cmn_utils_pkg.print_log(lv_log_filename, fnd_global.local_chr(10));
              jai_cmn_utils_pkg.print_log(lv_datafix_filename, '--Datafix for customer_trx_id : '||rec_get_cust_trx.customer_trx_id);
            END IF;

            ln_error_cnt := 1;

            rectify_ar_pay_sch(p_customer_trx_id    => rec_get_cust_trx.customer_trx_id,
                              p_gl_freight_amount   => rec_tot_cust_trx_gl_dist_frt.amount,
                              p_datafix_filename    => lv_datafix_filename,
                              p_process_status      => lv_process_status,
                              p_process_message     => lv_process_message);
          END IF;
        END IF;
      END IF;

      ln_err_num := 6;
      --To Check if ADO = ALIO + TO + FO in ar_payment_schedules_all
      IF lt_error_table(ln_err_num).enable = 'Y' THEN
        IF rec_tot_payment_schedule.amount_due_original <>  ( rec_tot_payment_schedule.amount_line_items_original
                                                            + rec_tot_payment_schedule.tax_original
                                                            + rec_tot_payment_schedule.freight_original)
        THEN
          lv_process_status := jai_constants.expected_error;
          lv_process_message := lt_error_table(ln_err_num).error_description;

          if lv_validate_first = 'Y' THEN
            goto EXIT_POINT;
          END IF;

          lt_error_table(ln_err_num).error_record_count :=  lt_error_table(ln_err_num).error_record_count + 1;

          If lv_generate_detail_log = 'Y' THEN
            jai_cmn_utils_pkg.print_log(lv_log_filename, '  Encountered the error - '||lt_error_table(ln_err_num).error_description);
          END IF;

          /*
          || rectified as a part of common (3,4,5). No seperate update required
          */
        END IF;
      END IF;

      ln_err_num := 7;
      --To Check if ADR = ALIR + TR + FR in ar_payment_schedules_all
      IF lt_error_table(ln_err_num).enable = 'Y' THEN
        IF rec_tot_payment_schedule.amount_due_remaining <> ( rec_tot_payment_schedule.amount_line_items_remaining
                                                            + rec_tot_payment_schedule.tax_remaining
                                                            + rec_tot_payment_schedule.freight_remaining)
        THEN
          lv_process_status := jai_constants.expected_error;
          lv_process_message := lt_error_table(ln_err_num).error_description;

          if lv_validate_first = 'Y' THEN
            goto EXIT_POINT;
          END IF;

          lt_error_table(ln_err_num).error_record_count :=  lt_error_table(ln_err_num).error_record_count + 1;

          If lv_generate_detail_log = 'Y' THEN
            jai_cmn_utils_pkg.print_log(lv_log_filename, '  Encountered the error - '||lt_error_table(ln_err_num).error_description);
          END IF;

          /*
          || rectified as a part of INVOICE  (1).
          || rectified as a part of CM  (1) No seperate update required
          */

        END IF;
      END IF;

      --=================================================================================================================--
                                              --Start of CM validations--
      --=================================================================================================================--

      IF rec_get_cust_trx.type  = 'CM' THEN
        ln_err_num := 21;
        --To check, if ADR, AADR, TR and FR are 0
        IF lt_error_table(ln_err_num).enable = 'Y' THEN
          IF rec_tot_payment_schedule.amount_due_remaining <> 0 OR
             rec_tot_payment_schedule.acctd_amount_due_remaining <> 0 OR
             rec_tot_payment_schedule.tax_remaining <> 0 OR
             rec_tot_payment_schedule.freight_remaining <> 0 THEN

            lv_process_status := jai_constants.expected_error;
            lv_process_message := lt_error_table(ln_err_num).error_description;

            if lv_validate_first = 'Y' THEN
              goto EXIT_POINT;
            END IF;

            lt_error_table(ln_err_num).error_record_count :=  lt_error_table(ln_err_num).error_record_count + 1;

            If lv_generate_detail_log = 'Y' THEN
              jai_cmn_utils_pkg.print_log(lv_log_filename, '  Encountered the error - '||lt_error_table(ln_err_num).error_description);
            END IF;

            /*
            ||set all these values to 0
            */

            IF lv_generate_log = 'Y' THEN

              IF ln_error_cnt = 0 THEN
                jai_cmn_utils_pkg.print_log(lv_log_filename, fnd_global.local_chr(10));
                jai_cmn_utils_pkg.print_log(lv_datafix_filename, '--Datafix for customer_trx_id : '||rec_get_cust_trx.customer_trx_id);
              END IF;

              ln_error_cnt := 1;

              UPDATE  ar_payment_schedules_all
              SET     amount_due_remaining        = 0,
                      acctd_amount_due_remaining  = 0,
                      tax_remaining               = 0,
                      freight_remaining           = 0,
                      last_update_date  = sysdate,
                      last_updated_by   = gn_bug_no
              WHERE   customer_trx_id             = rec_get_cust_trx.customer_trx_id;

              lv_sql_statement := fnd_global.local_chr(10)||
                                  'UPDATE  ar_payment_schedules_all
                                  SET     amount_due_remaining        = 0,
                                          acctd_amount_due_remaining  = 0,
                                          tax_remaining               = 0,
                                          freight_remaining           = 0,
                                          last_update_date  = sysdate,
                                          last_updated_by   = '||gn_bug_no||'
                                  WHERE   customer_trx_id             = '||rec_get_cust_trx.customer_trx_id||';';

              jai_cmn_utils_pkg.print_log(lv_datafix_filename, lv_sql_statement);

              lv_sql_statement := NULL;


            END IF;

          END IF;
        END IF;

        ln_err_num := 22;
        --To check, if ADO = amount applied
        IF lt_error_table(ln_err_num).enable = 'Y' THEN
          IF rec_tot_payment_schedule.amount_due_original <> rec_tot_payment_schedule.amount_applied THEN
            lv_process_status := jai_constants.expected_error;
            lv_process_message := lt_error_table(ln_err_num).error_description;

            if lv_validate_first = 'Y' THEN
              goto EXIT_POINT;
            END IF;

            lt_error_table(ln_err_num).error_record_count :=  lt_error_table(ln_err_num).error_record_count + 1;

            If lv_generate_detail_log = 'Y' THEN
              jai_cmn_utils_pkg.print_log(lv_log_filename, '  Encountered the error - '||lt_error_table(ln_err_num).error_description);
            END IF;

            /*
            ||set amt_applied = ADO as has been corrected earlier
            */

            IF lv_generate_log = 'Y' THEN

              IF ln_error_cnt = 0 THEN
                jai_cmn_utils_pkg.print_log(lv_log_filename, fnd_global.local_chr(10));
                jai_cmn_utils_pkg.print_log(lv_datafix_filename, '--Datafix for customer_trx_id : '||rec_get_cust_trx.customer_trx_id);
              END IF;

              ln_error_cnt := 1;

              UPDATE  ar_payment_schedules_all
              SET     amount_applied    = amount_due_original,
                      last_update_date  = sysdate,
                      last_updated_by   = gn_bug_no
              WHERE   customer_trx_id   = rec_get_cust_trx.customer_trx_id;

              lv_sql_statement := fnd_global.local_chr(10)||
                                  'UPDATE   ar_payment_schedules_all
                                  SET     amount_applied    = amount_due_original,
                                          last_update_date  = sysdate,
                                          last_updated_by   = '||gn_bug_no||
                                  ' WHERE   customer_trx_id   = '|| rec_get_cust_trx.customer_trx_id||';';

              jai_cmn_utils_pkg.print_log(lv_datafix_filename, lv_sql_statement);

              lv_sql_statement := NULL;

            END IF;

          END IF;
        END IF;

        OPEN cur_cm_ar_recv_appl( rec_get_cust_trx.customer_trx_id,
                                  rec_ra_customer_trx.exchange_rate,
                                  rec_ra_customer_trx_prev.exchange_rate);
        FETCH cur_cm_ar_recv_appl INTO rec_cm_ar_recv_appl;
        CLOSE cur_cm_ar_recv_appl;

        ln_err_num := 23;
        --To check, if ADO = SUM(LA + TA + FA) for ar_receivable_applications_all
        IF lt_error_table(ln_err_num).enable = 'Y' THEN
          IF ABS(rec_tot_payment_schedule.amount_due_original) <> ( ABS(rec_cm_ar_recv_appl.line_applied)
                                                                  + ABS(rec_cm_ar_recv_appl.tax_applied)
                                                                  + ABS(rec_cm_ar_recv_appl.freight_applied))
          THEN
            lv_process_status := jai_constants.expected_error;
            lv_process_message := lt_error_table(ln_err_num).error_description;

            if lv_validate_first = 'Y' THEN
              goto EXIT_POINT;
            END IF;

            lt_error_table(ln_err_num).error_record_count :=  lt_error_table(ln_err_num).error_record_count + 1;

            If lv_generate_detail_log = 'Y' THEN
              jai_cmn_utils_pkg.print_log(lv_log_filename, '  Encountered the error - '||lt_error_table(ln_err_num).error_description);
            END IF;

            /*
            ||IF CM has more than one applications then manual steps needs to be carried out else update and generate log
            ||For Single line -> ADO, FO,TO have already been corrected . Now set TA = TO, FA = FO
            */

            IF lv_generate_log = 'Y' THEN

              IF ln_error_cnt = 0 THEN
                jai_cmn_utils_pkg.print_log(lv_log_filename, fnd_global.local_chr(10));
                jai_cmn_utils_pkg.print_log(lv_datafix_filename, '--Datafix for customer_trx_id : '||rec_get_cust_trx.customer_trx_id);
              END IF;

              ln_error_cnt := 1;

              rectify_ar_rec_appl(
                            p_customer_trx_id     => rec_get_cust_trx.customer_trx_id,
                            p_previous_trx_id     => rec_get_cust_trx.previous_customer_trx_id,
                            p_arps_ado            => ABS(rec_tot_payment_schedule.amount_due_original),
                            p_arps_to             => ABS(rec_tot_payment_schedule.tax_original),
                            p_arps_fo             => ABS(rec_tot_payment_schedule.freight_original),
                            p_datafix_filename    => lv_datafix_filename,
                            p_process_status      => lv_process_status,
                            p_process_message     => lv_process_message)  ;
            END IF;

          END IF;

        END IF;

        ln_err_num := 24;
        --To check, if amount_applied <> LA + TA + FA
        IF lt_error_table(ln_err_num).enable = 'Y' THEN
          IF rec_cm_ar_recv_appl.amount_applied <>  ( rec_cm_ar_recv_appl.line_applied
                                                    + rec_cm_ar_recv_appl.tax_applied
                                                    + rec_cm_ar_recv_appl.freight_applied)
          THEN
            lv_process_status := jai_constants.expected_error;
            lv_process_message := lt_error_table(ln_err_num).error_description;

            if lv_validate_first = 'Y' THEN
              goto EXIT_POINT;
            END IF;

            lt_error_table(ln_err_num).error_record_count :=  lt_error_table(ln_err_num).error_record_count + 1;

            If lv_generate_detail_log = 'Y' THEN
              jai_cmn_utils_pkg.print_log(lv_log_filename, '  Encountered the error - '||lt_error_table(ln_err_num).error_description);
            END IF;

            IF lv_generate_log = 'Y' THEN
              UPDATE  ar_receivable_applications_all
              SET     amount_applied        = NVL(line_applied,0) + NVL(tax_applied,0)  + NVL(freight_applied,0),
                      last_update_date      = sysdate,
                      last_updated_by       = gn_bug_no
              WHERE   customer_trx_id       = rec_get_cust_trx.customer_trx_id
              AND     application_type      = 'CM'
              AND     display               = 'Y'
              AND     status                = 'APP';

              lv_sql_statement := fnd_global.local_chr(10)||
                                  'UPDATE ar_receivable_applications_all
                                  SET     amount_applied        = NVL(line_applied,0) + NVL(tax_applied,0)  + NVL(freight_applied,0),
                                          last_update_date      = sysdate,
                                          last_updated_by       = '||gn_bug_no||'
                                  WHERE   customer_trx_id       = '||rec_get_cust_trx.customer_trx_id||'
                                  AND     application_type      = '||''''||'CM'||''''||'
                                  AND     display               = '||''''||'Y'||''''||'
                                  AND     status                = '||''''||'APP'||''''||';';

              jai_cmn_utils_pkg.print_log(lv_datafix_filename, lv_sql_statement);

              lv_sql_statement := NULL;

            END IF;
            /*
            ||AA = LA + TA + FA
            */

          END IF;
        END IF;

        ln_precision :=  null;

        OPEN  jai_ar_validate_data_pkg.cur_curr_precision(rec_ra_customer_trx.set_of_books_id);
        FETCH jai_ar_validate_data_pkg.cur_curr_precision INTO ln_precision;
        CLOSE jai_ar_validate_data_pkg.cur_curr_precision;

        ln_err_num := 25;
        --To check, if AAAF = AA * exchange_rate(CM) for ar_receivable_applications_all
        IF lt_error_table(ln_err_num).enable = 'Y' THEN
          IF ROUND(rec_cm_ar_recv_appl.acctd_amount_applied_from,0) <> ROUND(rec_cm_ar_recv_appl.acctd_amount_applied_from_calc,0)
          THEN
            lv_process_status := jai_constants.expected_error;
            lv_process_message := lt_error_table(ln_err_num).error_description;

            if lv_validate_first = 'Y' THEN
              goto EXIT_POINT;
            END IF;

            lt_error_table(ln_err_num).error_record_count :=  lt_error_table(ln_err_num).error_record_count + 1;

            If lv_generate_detail_log = 'Y' THEN
              jai_cmn_utils_pkg.print_log(lv_log_filename, '  Encountered the error - '||lt_error_table(ln_err_num).error_description);
            END IF;

            /*
            ||set AAAF = AA * exchange_rate(CM)
            */

            IF lv_generate_log = 'Y' THEN

              IF ln_error_cnt = 0 THEN
                jai_cmn_utils_pkg.print_log(lv_log_filename, fnd_global.local_chr(10));
                jai_cmn_utils_pkg.print_log(lv_datafix_filename, '--Datafix for customer_trx_id : '||rec_get_cust_trx.customer_trx_id);
              END IF;

              ln_error_cnt := 1;


              UPDATE  ar_receivable_applications_all
              SET     acctd_amount_applied_from = ROUND(amount_applied * rec_ra_customer_trx.exchange_rate, ln_precision),
                      last_update_date  = sysdate,
                      last_updated_by   = gn_bug_no
              WHERE   customer_trx_id   = rec_get_cust_trx.customer_trx_id
              AND     application_type  = 'CM'
              AND     display           = 'Y'
              AND     status            = 'APP';

              lv_sql_statement := fnd_global.local_chr(10)||
                                  'UPDATE ar_receivable_applications_all
                                  SET     acctd_amount_applied_from = ROUND(amount_applied * '||rec_ra_customer_trx.exchange_rate||','|| ln_precision||'),
                                          last_update_date  = sysdate,
                                          last_updated_by   = '||gn_bug_no||'
                                  WHERE   customer_trx_id   = '||rec_get_cust_trx.customer_trx_id||'
                                  AND     application_type  = '||''''||'CM'||''''||'
                                  AND     display           = '||''''||'Y'||''''||'
                                  AND     status            = '||''''||'APP'||''''||';';

              jai_cmn_utils_pkg.print_log(lv_datafix_filename, lv_sql_statement);

              lv_sql_statement := NULL;

            END IF;

          END IF;
        END IF;

        ln_err_num := 26;
        --To check, if AAAT = AA * exchange_rate(INV) for ar_receivable_applications_all
        IF lt_error_table(ln_err_num).enable = 'Y' THEN
          IF ROUND(rec_cm_ar_recv_appl.acctd_amount_applied_to,0) <> ROUND(rec_cm_ar_recv_appl.acctd_amount_applied_to_calc,0)
          THEN
            lv_process_status := jai_constants.expected_error;
            lv_process_message := lt_error_table(ln_err_num).error_description;

            if lv_validate_first = 'Y' THEN
              goto EXIT_POINT;
            END IF;

            lt_error_table(ln_err_num).error_record_count :=  lt_error_table(ln_err_num).error_record_count + 1;

            If lv_generate_detail_log = 'Y' THEN
              jai_cmn_utils_pkg.print_log(lv_log_filename, '  Encountered the error - '||lt_error_table(ln_err_num).error_description);
            END IF;


            /*
            ||set AAAT = AA * exchange_rate(INV)
            */

            IF lv_generate_log = 'Y' THEN

              IF ln_error_cnt = 0 THEN
                jai_cmn_utils_pkg.print_log(lv_log_filename, fnd_global.local_chr(10));
                jai_cmn_utils_pkg.print_log(lv_datafix_filename, '--Datafix for customer_trx_id : '||rec_get_cust_trx.customer_trx_id);
              END IF;

              ln_error_cnt := 1;

              UPDATE  ar_receivable_applications_all
              SET     acctd_amount_applied_to = ROUND(amount_applied * rec_ra_customer_trx_prev.exchange_rate, ln_precision),
                      last_update_date  = sysdate,
                      last_updated_by   = gn_bug_no
              WHERE   customer_trx_id   = rec_get_cust_trx.customer_trx_id
              AND     application_type  = 'CM'
              AND     display           = 'Y'
              AND     status            = 'APP';

              lv_sql_statement := fnd_global.local_chr(10)||
                                  'UPDATE ar_receivable_applications_all
                                  SET     acctd_amount_applied_to = ROUND(amount_applied * '||rec_ra_customer_trx_prev.exchange_rate||','|| ln_precision||'),
                                          last_update_date  = sysdate,
                                          last_updated_by   = '||gn_bug_no||'
                                  WHERE   customer_trx_id   = '||rec_get_cust_trx.customer_trx_id||'
                                  AND     application_type  = '||''''||'CM'||''''||'
                                  AND     display           = '||''''||'Y'||''''||'
                                  AND     status            = '||''''||'APP'||''''||';';

              jai_cmn_utils_pkg.print_log(lv_datafix_filename, lv_sql_statement);

              lv_sql_statement := NULL;

            END IF;

          END IF;
        END IF;
      --=================================================================================================================--
                                              --End of CM validations--
      --=================================================================================================================--

      --=================================================================================================================--
                                              --Start of Invoice validations--
                                              --Valid the correctness of Invoice w.r.t to receivable applications only when only if the one has atleast one
                                              -- CM applied against it
      --=================================================================================================================--

      ELSIF rec_get_cust_trx.type              = 'INV'
      AND   rec_chk_cm_exists.application_type = 'CM'
      THEN

        OPEN cur_inv_cash_cm_recv_appl(rec_get_cust_trx.customer_trx_id);
        FETCH cur_inv_cash_cm_recv_appl INTO rec_inv_cash_cm_recv_appl;
        CLOSE cur_inv_cash_cm_recv_appl;


        ln_err_num := 41;
        --To check, if ADO = ADR + SUM(LA + TA + FA) of ar_receivable_applications
        IF lt_error_table(ln_err_num).enable = 'Y' THEN
          IF rec_tot_payment_schedule.amount_due_original <>  ( rec_tot_payment_schedule.amount_due_remaining
                                                              + rec_inv_cash_cm_recv_appl.line_applied
                                                              + rec_inv_cash_cm_recv_appl.tax_applied
                                                              + rec_inv_cash_cm_recv_appl.freight_applied)
          THEN
            lv_process_status := jai_constants.expected_error;
            lv_process_message := lt_error_table(ln_err_num).error_description;

            if lv_validate_first = 'Y' THEN
              goto EXIT_POINT;
            END IF;

            lt_error_table(ln_err_num).error_record_count :=  lt_error_table(ln_err_num).error_record_count + 1;

            If lv_generate_detail_log = 'Y' THEN
              jai_cmn_utils_pkg.print_log(lv_log_filename, '  Encountered the error - '||lt_error_table(ln_err_num).error_description);
            END IF;

            /*
            ||set TR = TO - SUM(TA) for the arps.payment_schedule_id = RECA.applied_payment_schedule_id AND ARPS.customer_trx_id = RECA.applied_customer_trx_id
            ||    FR = FO - SUM(FA) for the arps.payment_schedule_id = RECA.applied_payment_schedule_id AND ARPS.customer_trx_id = RECA.applied_customer_trx_id
            ||    ADR = ADO - SUM(AA) for the arps.payment_schedule_id = RECA.applied_payment_schedule_id AND ARPS.customer_trx_id = RECA.applied_customer_trx_id
            */

            IF lv_generate_log = 'Y' THEN

              IF ln_error_cnt = 0 THEN
                jai_cmn_utils_pkg.print_log(lv_log_filename, fnd_global.local_chr(10));
                jai_cmn_utils_pkg.print_log(lv_datafix_filename, '--Datafix for customer_trx_id : '||rec_get_cust_trx.customer_trx_id);
              END IF;

              ln_error_cnt := 1;

              UPDATE ar_payment_schedules_all inv_arps
              SET  tax_remaining        = nvl(tax_original,0) -         ( SELECT
                                                                                  nvl(sum(tax_applied),0) tot_tax_applied
                                                                          FROM
                                                                                  ar_receivable_applications_all reca
                                                                          WHERE
                                                                                  reca.applied_payment_schedule_id  = inv_arps.payment_schedule_id
                                                                          AND     reca.applied_customer_trx_id      = inv_arps.customer_trx_id
                                                                          AND     reca.display                      = 'Y'
                                                                          AND     reca.status                       = 'APP'
                                                                        ) ,
                   freight_remaining    = nvl(freight_original,0) -     ( SELECT
                                                                                  nvl(sum(freight_applied),0) tot_frt_applied
                                                                          FROM
                                                                                  ar_receivable_applications_all reca
                                                                          WHERE
                                                                                  reca.applied_payment_schedule_id = inv_arps.payment_schedule_id
                                                                          AND     reca.applied_customer_trx_id     = inv_arps.customer_trx_id
                                                                          AND     reca.display                     = 'Y'
                                                                          AND     reca.status                      = 'APP'
                                                                        ) ,
                   amount_due_remaining = nvl(amount_due_original,0) - ( SELECT
                                                                                nvl(sum(amount_applied),0) tot_amt_applied
                                                                         FROM
                                                                                ar_receivable_applications_all reca
                                                                         WHERE
                                                                                reca.applied_payment_schedule_id = inv_arps.payment_schedule_id
                                                                         AND    reca.applied_customer_trx_id     = inv_arps.customer_trx_id
                                                                         AND    reca.display                     = 'Y'
                                                                         AND    reca.status                      = 'APP'
                                                                        ) ,
                  last_update_date  = sysdate,
                  last_updated_by   = gn_bug_no
              WHERE
                  customer_trx_id = rec_get_cust_trx.customer_trx_id;


              lv_sql_statement := fnd_global.local_chr(10)||
                    'UPDATE ar_payment_schedules_all inv_arps
                    SET  tax_remaining        = nvl(tax_original,0) -         ( SELECT
                                                                                        nvl(sum(tax_applied),0) tot_tax_applied
                                                                                FROM
                                                                                        ar_receivable_applications_all reca
                                                                                WHERE
                                                                                        reca.applied_payment_schedule_id  = inv_arps.payment_schedule_id
                                                                                AND     reca.applied_customer_trx_id      = inv_arps.customer_trx_id
                                                                                AND     reca.display                      = '||''''||'Y'||''''||'
                                                                                AND     reca.status                       = '||''''||'APP'||''''||'
                                                                              ) ,
                         freight_remaining    = nvl(freight_original,0) -     ( SELECT
                                                                                        nvl(sum(freight_applied),0) tot_frt_applied
                                                                                FROM
                                                                                        ar_receivable_applications_all reca
                                                                                WHERE
                                                                                        reca.applied_payment_schedule_id = inv_arps.payment_schedule_id
                                                                                AND     reca.applied_customer_trx_id     = inv_arps.customer_trx_id
                                                                                AND     reca.display                      = '||''''||'Y'||''''||'
                                                                                AND     reca.status                       = '||''''||'APP'||''''||'
                                                                              ) ,
                         amount_due_remaining = nvl(amount_due_original,0) - ( SELECT
                                                                                      nvl(sum(amount_applied),0) tot_amt_applied
                                                                               FROM
                                                                                      ar_receivable_applications_all reca
                                                                               WHERE
                                                                                      reca.applied_payment_schedule_id = inv_arps.payment_schedule_id
                                                                               AND    reca.applied_customer_trx_id     = inv_arps.customer_trx_id
                                                                               AND     reca.display                       = '||''''||'Y'||''''||'
                                                                               AND     reca.status                        = '||''''||'APP'||''''||'
                                                                              ) ,
                        last_update_date  = sysdate,
                        last_updated_by   = '||gn_bug_no||'
                    WHERE
                        customer_trx_id = '||rec_get_cust_trx.customer_trx_id||';';


              jai_cmn_utils_pkg.print_log(lv_datafix_filename, lv_sql_statement);

              lv_sql_statement := NULL;


            END IF;

          END IF;
        END IF;

        OPEN cur_inv_ar_recv_appl(rec_get_cust_trx.customer_trx_id);
        FETCH cur_inv_ar_recv_appl INTO rec_inv_ar_recv_appl;
        CLOSE cur_inv_ar_recv_appl;

        ln_err_num := 42;
        --To check, if amount_credited = SUM(amount_applied) of ar_receivable_applications
        IF lt_error_table(ln_err_num).enable = 'Y' THEN
          IF ABS(rec_tot_payment_schedule.amount_credited) <> ABS(rec_inv_ar_recv_appl.amount_applied)
          THEN
            lv_process_status := jai_constants.expected_error;
            lv_process_message := lt_error_table(ln_err_num).error_description;

            if lv_validate_first = 'Y' THEN
              goto EXIT_POINT;
            END IF;

            lt_error_table(ln_err_num).error_record_count :=  lt_error_table(ln_err_num).error_record_count + 1;

            If lv_generate_detail_log = 'Y' THEN
              jai_cmn_utils_pkg.print_log(lv_log_filename, '  Encountered the error - '||lt_error_table(ln_err_num).error_description);
            END IF;


            /*
            ||SET AC = SUM(AA) for the arps.payment_schedule_id = RECA.applied_payment_schedule_id AND ARPS.customer_trx_id = RECA.applied_customer_trx_id
            */
            IF lv_generate_log = 'Y' THEN

              IF ln_error_cnt = 0 THEN
                jai_cmn_utils_pkg.print_log(lv_log_filename, fnd_global.local_chr(10));
                jai_cmn_utils_pkg.print_log(lv_datafix_filename, '--Datafix for customer_trx_id : '||rec_get_cust_trx.customer_trx_id);
              END IF;

              ln_error_cnt := 1;

              UPDATE  ar_payment_schedules_all inv_arps
              SET     amount_credited = (SELECT
                                               (nvl(sum(amount_applied),0) * (-1) )tot_amt_applied
                                        FROM
                                               ar_receivable_applications_all reca
                                        WHERE
                                               reca.applied_payment_schedule_id = inv_arps.payment_schedule_id
                                        AND    reca.applied_customer_trx_id     = inv_arps.customer_trx_id
                                        AND    reca.application_type            = 'CM'
                                        AND    reca.display                     = 'Y'
                                        AND    reca.status                      = 'APP'
                                       )  ,
                    last_update_date  = sysdate,
                    last_updated_by   = gn_bug_no
              WHERE
                    customer_trx_id = rec_get_cust_trx.customer_trx_id;


              lv_sql_statement := fnd_global.local_chr(10)||
                                  'UPDATE ar_payment_schedules_all inv_arps
                                  SET     amount_credited = (SELECT
                                                                   (nvl(sum(amount_applied),0) * (-1) )tot_amt_applied
                                                            FROM
                                                                   ar_receivable_applications_all reca
                                                            WHERE
                                                                   reca.applied_payment_schedule_id = inv_arps.payment_schedule_id
                                                            AND    reca.applied_customer_trx_id     = inv_arps.customer_trx_id
                                                            AND    reca.application_type            = '||''''||'CM'||''''||'
                                                            AND    reca.display                     = '||''''||'Y'||''''||'
                                                            AND    reca.status                      = '||''''||'APP'||'
                                                           )  ,
                                        last_update_date  = sysdate,
                                        last_updated_by   = '||gn_bug_no||'
                                  WHERE
                                        customer_trx_id = '||rec_get_cust_trx.customer_trx_id||';';

              jai_cmn_utils_pkg.print_log(lv_datafix_filename, lv_sql_statement);

              lv_sql_statement := NULL;


            END IF;

          END IF;
        END IF;
      END IF;

      --=================================================================================================================--
                                              --End of Invoice validations--
      --=================================================================================================================--

      --=================================================================================================================--
                                              --Some more common validations--
      --=================================================================================================================--

      OPEN  jai_ar_validate_data_pkg.cur_curr_precision(rec_get_cust_trx.set_of_books_id);
      FETCH jai_ar_validate_data_pkg.cur_curr_precision INTO ln_precision;
      CLOSE jai_ar_validate_data_pkg.cur_curr_precision;

      ln_local_cnt := 0;
      ln_err_num := 8;
      --To check if AADR = ADR * exchange_rate in ar_payment_schedules_all
      IF lt_error_table(ln_err_num).enable = 'Y' THEN
        FOR rec_payment_schedules IN cur_payment_schedules(rec_get_cust_trx.customer_trx_id)
        LOOP
          IF ROUND(rec_payment_schedules.acctd_amount_due_remaining)
              <> ROUND(rec_payment_schedules.amount_due_remaining * rec_payment_schedules.exchange_rate)
          THEN
            lv_process_status := jai_constants.expected_error;
            lv_process_message := lt_error_table(ln_err_num).error_description;

            ln_local_cnt := ln_local_cnt + 1;

            IF lv_validate_first = 'Y' THEN
              goto EXIT_POINT;
            END IF;

            IF ln_local_cnt = 1 THEN
              lt_error_table(ln_err_num).error_record_count :=  lt_error_table(ln_err_num).error_record_count + 1;

              If lv_generate_detail_log = 'Y' THEN
                jai_cmn_utils_pkg.print_log(lv_log_filename, '  Encountered the error - '||lt_error_table(ln_err_num).error_description);
              END IF;
            END IF;

            IF lv_generate_log = 'Y' THEN

              IF ln_error_cnt = 0 THEN
                jai_cmn_utils_pkg.print_log(lv_log_filename, fnd_global.local_chr(10));
                jai_cmn_utils_pkg.print_log(lv_datafix_filename, '--Datafix for customer_trx_id : '||rec_get_cust_trx.customer_trx_id);
              END IF;

              ln_error_cnt := 1;

              UPDATE  ar_payment_schedules_all
              SET     acctd_amount_due_remaining =  ROUND(rec_payment_schedules.amount_due_remaining * rec_payment_schedules.exchange_rate, ln_precision),
                      last_update_date  = sysdate,
                      last_updated_by   = gn_bug_no
              WHERE   customer_trx_id             = rec_get_cust_trx.customer_trx_id
              AND     payment_schedule_id         = rec_payment_schedules.payment_schedule_id;

              lv_sql_statement := fnd_global.local_chr(10)||
                                  'UPDATE ar_payment_schedules_all
                                  SET     acctd_amount_due_remaining =  ROUND('||rec_payment_schedules.amount_due_remaining||' * '||rec_payment_schedules.exchange_rate||', '||ln_precision||'),
                                          last_update_date  = sysdate,
                                          last_updated_by   = '||gn_bug_no||'
                                  WHERE   customer_trx_id             = '||rec_get_cust_trx.customer_trx_id||'
                                  AND     payment_schedule_id         = '||rec_payment_schedules.payment_schedule_id||';';


              jai_cmn_utils_pkg.print_log(lv_datafix_filename, lv_sql_statement);

              lv_sql_statement := NULL;

            END IF;

          END IF;

        END LOOP;
      END IF;

      ln_local_cnt := 0;
      ln_err_num := 9;

      IF lt_error_table(ln_err_num).enable = 'Y' THEN
        FOR rec_payment_schedules IN cur_payment_schedules(rec_get_cust_trx.customer_trx_id)
        LOOP
          --To check if status = 'CL' and AADR <> 0 and ADR <> 0
          IF rec_payment_schedules.status = 'CL' THEN
            IF ROUND(rec_payment_schedules.amount_due_remaining) <> 0 OR ROUND(rec_payment_schedules.acctd_amount_due_remaining) <> 0 THEN
              lv_process_status := jai_constants.expected_error;
              lv_process_message := lt_error_table(ln_err_num).error_description;

              ln_local_cnt := ln_local_cnt + 1;

              if lv_validate_first = 'Y' THEN
                goto EXIT_POINT;
              END IF;

              IF ln_local_cnt = 1 THEN
                lt_error_table(ln_err_num).error_record_count :=  lt_error_table(ln_err_num).error_record_count + 1;

                If lv_generate_detail_log = 'Y' THEN
                  jai_cmn_utils_pkg.print_log(lv_log_filename, '  Encountered the error - '||lt_error_table(ln_err_num).error_description);
                END IF;
              END IF;
              /*
              ||set the staus = 'OP and gl_date_closed ='31-DEC-4712' and actual_date_closed '31-DEC-4712'  as ADR and AADR
              ||have been set correctly
              */

              IF lv_generate_log = 'Y' THEN

                IF ln_error_cnt = 0 THEN
                  jai_cmn_utils_pkg.print_log(lv_log_filename, fnd_global.local_chr(10));
                  jai_cmn_utils_pkg.print_log(lv_datafix_filename, '--Datafix for customer_trx_id : '||rec_get_cust_trx.customer_trx_id);
                END IF;

                ln_error_cnt := 1;


                UPDATE  ar_payment_schedules_all
                SET     status                      = DECODE (amount_due_remaining, 0, 'CL', 'OP'),
                        gl_date_closed              = DECODE (amount_due_remaining, 0, SYSDATE, TO_DATE('31/12/4712','DD/MM/YYYY')) ,
                        actual_date_closed          = DECODE (amount_due_remaining, 0, SYSDATE, TO_DATE('31/12/4712','DD/MM/YYYY')),
                        last_update_date  = sysdate,
                        last_updated_by   = gn_bug_no
                WHERE   customer_trx_id             = rec_get_cust_trx.customer_trx_id
                AND     payment_schedule_id         = rec_payment_schedules.payment_schedule_id;

                lv_sql_statement := fnd_global.local_chr(10)||
                                    'UPDATE  ar_payment_schedules_all
                                    SET     status                      = DECODE (amount_due_remaining, 0, '||''''||'CL'||''''||', '||''''||'OP'||''''||'),
                                            gl_date_closed              = DECODE (amount_due_remaining, 0, SYSDATE, TO_DATE('||''''||'31/12/4712'||''''||','||''''||'DD/MM/YYYY'||''''||')) ,
                                            actual_date_closed          = DECODE (amount_due_remaining, 0, SYSDATE, TO_DATE('||''''||'31/12/4712'||''''||','||''''||'DD/MM/YYYY'||''''||')) ,
                                            last_update_date  = sysdate,
                                            last_updated_by   = '||gn_bug_no||'
                                    WHERE   customer_trx_id             = '||rec_get_cust_trx.customer_trx_id||'
                                    AND     payment_schedule_id         = '||rec_payment_schedules.payment_schedule_id||';';

                jai_cmn_utils_pkg.print_log(lv_datafix_filename, lv_sql_statement);

                lv_sql_statement := NULL;


              END IF;

            END IF;

          END IF;

        END LOOP;
      END IF;

      ln_local_cnt := 0;
      ln_err_num := 10;

      IF lt_error_table(ln_err_num).enable = 'Y' THEN
        FOR rec_payment_schedules IN cur_payment_schedules(rec_get_cust_trx.customer_trx_id)
        LOOP
          --To Check if status = 'OP' and gl_date_closed = '31-DEC-4712'
          IF rec_payment_schedules.status = 'OP' THEN
            IF rec_payment_schedules.gl_date_closed <> TO_DATE('31/12/4712','dd/mm/yyyy') THEN
              lv_process_status := jai_constants.expected_error;
              lv_process_message := lt_error_table(ln_err_num).error_description;

              ln_local_cnt := ln_local_cnt + 1;

              if lv_validate_first = 'Y' THEN
                goto EXIT_POINT;
              END IF;

              IF ln_local_cnt = 1 THEN
                lt_error_table(ln_err_num).error_record_count :=  lt_error_table(ln_err_num).error_record_count + 1;

                If lv_generate_detail_log = 'Y' THEN
                  jai_cmn_utils_pkg.print_log(lv_log_filename, '  Encountered the error - '||lt_error_table(ln_err_num).error_description);
                END IF;
              END IF;

              /*
              ||set gl_date_closed = '31-dec-4712' and actual_date_closed = '31-dec-4712'
              */

              IF lv_generate_log = 'Y' THEN

                IF ln_error_cnt = 0 THEN
                  jai_cmn_utils_pkg.print_log(lv_log_filename, fnd_global.local_chr(10));
                  jai_cmn_utils_pkg.print_log(lv_datafix_filename, '--Datafix for customer_trx_id : '||rec_get_cust_trx.customer_trx_id);
                END IF;

                ln_error_cnt := 1;

                UPDATE  ar_payment_schedules_all
                SET     status                      = DECODE (amount_due_remaining, 0, 'CL', 'OP'),
                        gl_date_closed              = DECODE (amount_due_remaining, 0, SYSDATE, TO_DATE('31/12/4712','DD/MM/YYYY')) ,
                        actual_date_closed          = DECODE (amount_due_remaining, 0, SYSDATE, TO_DATE('31/12/4712','DD/MM/YYYY')),
                        last_update_date  = sysdate,
                        last_updated_by   = gn_bug_no
                WHERE   customer_trx_id             = rec_get_cust_trx.customer_trx_id
                AND     payment_schedule_id         = rec_payment_schedules.payment_schedule_id;


                lv_sql_statement := fnd_global.local_chr(10)||
                                    'UPDATE  ar_payment_schedules_all
                                    SET     status                      = DECODE (amount_due_remaining, 0, '||''''||'CL'||''''||', '||''''||'OP'||''''||'),
                                            gl_date_closed              = DECODE (amount_due_remaining, 0, SYSDATE, TO_DATE('||''''||'31/12/4712'||''''||','||''''||'DD/MM/YYYY'||''''||')) ,
                                            actual_date_closed          = DECODE (amount_due_remaining, 0, SYSDATE, TO_DATE('||''''||'31/12/4712'||''''||','||''''||'DD/MM/YYYY'||''''||')) ,
                                            last_update_date  = sysdate,
                                            last_updated_by   = '||gn_bug_no||'
                                    WHERE   customer_trx_id             = '||rec_get_cust_trx.customer_trx_id||'
                                    AND     payment_schedule_id         = '||rec_payment_schedules.payment_schedule_id||';';

                jai_cmn_utils_pkg.print_log(lv_datafix_filename, lv_sql_statement);

                lv_sql_statement := NULL;

              END IF;

            END IF;

          END IF;

        END LOOP;
      END IF;

      ln_local_cnt := 0;

      ln_err_num := 12;

      IF lt_error_table(ln_err_num).enable = 'Y' THEN
        FOR    rec_cur_sync_il_line_tax IN cur_sync_il_line_tax( cp_customer_trx_id =>  rec_get_cust_trx.customer_trx_id)
        LOOP
          lv_process_status := jai_constants.expected_error;
          lv_process_message := lt_error_table(ln_err_num).error_description;

          ln_local_cnt := ln_local_cnt + 1;

          IF lv_validate_first = 'Y' THEN
            goto EXIT_POINT;
          END IF;

          IF ln_local_cnt = 1 THEN
            lt_error_table(ln_err_num).error_record_count :=  lt_error_table(ln_err_num).error_record_count + 1;

            If lv_generate_detail_log = 'Y' THEN
              jai_cmn_utils_pkg.print_log(lv_log_filename, '  Encountered the error - '||lt_error_table(ln_err_num).error_description);
            END IF;
          END IF;

          IF lv_generate_log = 'Y' THEN

            IF ln_error_cnt = 0 THEN
              jai_cmn_utils_pkg.print_log(lv_log_filename, fnd_global.local_chr(10));
              jai_cmn_utils_pkg.print_log(lv_datafix_filename, '--Datafix for customer_trx_id : '||rec_get_cust_trx.customer_trx_id);
            END IF;

            ln_error_cnt := 1;


            UPDATE  JAI_AR_TRX_LINES
            SET     tax_amount = rec_cur_sync_il_line_tax.tax_amount ,
                    total_amount = line_amount + rec_cur_sync_il_line_tax.tax_amount,
                    last_update_date  = sysdate,
                    last_updated_by   = gn_bug_no
            WHERE   customer_trx_line_id = rec_cur_sync_il_line_tax.customer_trx_line_id;

            lv_sql_statement := fnd_global.local_chr(10)||
                                'UPDATE JAI_AR_TRX_LINES
                                SET     tax_amount = '||rec_cur_sync_il_line_tax.tax_amount||' ,
                                        total_amount = line_amount + '||rec_cur_sync_il_line_tax.tax_amount||',
                                        last_update_date  = sysdate,
                                        last_updated_by   = '||gn_bug_no||'
                                WHERE   customer_trx_line_id = '||rec_cur_sync_il_line_tax.customer_trx_line_id||';';

            jai_cmn_utils_pkg.print_log(lv_datafix_filename, lv_sql_statement);

            lv_sql_statement := NULL;

          END IF;

        END LOOP;
      END IF;

      ln_local_cnt := 0;

      ln_err_num := 13;

      IF lt_error_table(ln_err_num).enable = 'Y' THEN
        FOR   rec_sync_il_hdr_tax IN cur_sync_il_hdr_tax(cp_customer_trx_id => rec_get_cust_trx.customer_trx_id)
        LOOP
          lv_process_status := jai_constants.expected_error;
          lv_process_message := lt_error_table(ln_err_num).error_description;

          ln_local_cnt := ln_local_cnt + 1;

          IF lv_validate_first = 'Y' THEN
            goto EXIT_POINT;
          END IF;

          IF ln_local_cnt = 1 THEN
            lt_error_table(ln_err_num).error_record_count :=  lt_error_table(ln_err_num).error_record_count + 1;

            If lv_generate_detail_log = 'Y' THEN
              jai_cmn_utils_pkg.print_log(lv_log_filename, '  Encountered the error - '||lt_error_table(ln_err_num).error_description);
            END IF;
          END IF;

          IF lv_generate_log = 'Y' THEN

            IF ln_error_cnt = 0 THEN
              jai_cmn_utils_pkg.print_log(lv_log_filename, fnd_global.local_chr(10));
              jai_cmn_utils_pkg.print_log(lv_datafix_filename, '--Datafix for customer_trx_id : '||rec_get_cust_trx.customer_trx_id);
            END IF;

            ln_error_cnt := 1;

            UPDATE JAI_AR_TRXS
            SET     tax_amount = rec_sync_il_hdr_tax.tax_amount ,
                    total_amount = line_amount + rec_sync_il_hdr_tax.tax_amount,
                    last_update_date  = sysdate,
                    last_updated_by   = gn_bug_no
             WHERE  CUSTOMER_TRX_ID = rec_sync_il_hdr_tax.customer_trx_id;

            lv_sql_statement := fnd_global.local_chr(10)||
                                'UPDATE JAI_AR_TRXS
                                SET     tax_amount = '||rec_sync_il_hdr_tax.tax_amount||' ,
                                        total_amount = line_amount + '||rec_sync_il_hdr_tax.tax_amount||',
                                        last_update_date  = sysdate,
                                        last_updated_by   = '||gn_bug_no||'
                                 WHERE  CUSTOMER_TRX_ID = '||rec_sync_il_hdr_tax.customer_trx_id||';';

            jai_cmn_utils_pkg.print_log(lv_datafix_filename, lv_sql_statement);

            lv_sql_statement := NULL;

          END IF;

        END LOOP;
      END IF;
      --=================================================================================================================--
                                              --End of common validations--
      --=================================================================================================================--
    END LOOP; --Main cursor Loop

    <<EXIT_POINT>>

    IF lv_validate_all = 'Y' THEN
      IF lv_fix_data = 'Y' THEN
        IF lv_commit = 'Y' THEN
          COMMIT;
        ELSE
          NULL;
        END IF;
      ELSE
        ROLLBACK TO start_program;
      END IF;
    ELSE
      NULL;
    END IF;

    IF lv_generate_log = 'Y' THEN
      display_error_summary(lt_error_table,
                            ln_total_count,
                            lv_log_filename,
                            lv_process_status,
                            lv_process_message);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status := jai_constants.unexpected_error;
      p_process_message := SUBSTR(sqlerrm,1,300);

      ROLLBACK to start_program;

      jai_cmn_utils_pkg.print_log(lv_log_filename, fnd_global.local_chr(10));
      jai_cmn_utils_pkg.print_log(lv_log_filename, 'Encountered an Oracle error : '||lv_process_message);

  END post_validation;

END jai_ar_validate_data_pkg;

/
