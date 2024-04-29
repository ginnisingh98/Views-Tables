--------------------------------------------------------
--  DDL for Package Body FV_SLA_CST_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_SLA_CST_PROCESSING_PKG" AS
--$Header: FVXLACMB.pls 120.0.12010000.2 2010/03/03 19:49:02 sasukuma noship $

---------------------------------------------------------------------------
---------------------------------------------------------------------------

  c_FAILURE   CONSTANT  NUMBER := -1;
  c_SUCCESS   CONSTANT  NUMBER := 0;
  C_GL_APPLICATION CONSTANT NUMBER := 101;
  C_GL_APPL_SHORT_NAME CONSTANT VARCHAR2(30) := 'SQLGL';
  C_GL_FLEX_CODE   CONSTANT VARCHAR2(10) := 'GL#';
  CRLF CONSTANT VARCHAR2(1) := FND_GLOBAL.newline;
  g_path_name   CONSTANT VARCHAR2(200)  := 'fv.plsql.fvxlacmb.fv_sla_cst_processing_pkg';
  C_STATE_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_STATEMENT;
  C_PROC_LEVEL  CONSTANT  NUMBER       :=  FND_LOG.LEVEL_PROCEDURE;

  PROCEDURE trace
  (
    p_level             IN NUMBER,
    p_procedure_name    IN VARCHAR2,
    p_debug_info        IN VARCHAR2
  )
  IS
  BEGIN
    fv_sla_utl_processing_pkg.trace
    (
      p_level             => p_level,
      p_procedure_name    => p_procedure_name,
      p_debug_info        => p_debug_info
    );
  END trace;

  PROCEDURE stack_error
  (
    p_program_name  IN VARCHAR2,
    p_location      IN VARCHAR2,
    p_error_message IN VARCHAR2
  )
  IS
  BEGIN
    fv_sla_utl_processing_pkg.stack_error
    (
      p_program_name  => p_program_name,
      p_location      => p_location,
      p_error_message => p_error_message
    );
  END;

  PROCEDURE init
  IS
    l_procedure_name       VARCHAR2(100) :='.init';
  BEGIN
    trace(C_STATE_LEVEL, l_procedure_name, 'Package Information');
    trace(C_STATE_LEVEL, l_procedure_name, '$Header: FVXLACMB.pls 120.0.12010000.2 2010/03/03 19:49:02 sasukuma noship $');
  END;


  PROCEDURE cst_extract
  (
    p_application_id               IN            NUMBER,
    p_accounting_mode              IN            VARCHAR2
  )
  IS
    l_procedure_name    VARCHAR2(100):='.CST_EXTRACT';
    l_index             NUMBER;
    l_fv_extract_detail fv_sla_utl_processing_pkg.fv_ref_detail;
    l_ledger_info       fv_sla_utl_processing_pkg.LedgerRecType;
    l_error_code        NUMBER;
    l_gt_error_code     NUMBER;
    l_error_desc        VARCHAR2(1024);
    l_fund_value        VARCHAR(30);
    l_account_value     VARCHAR2(30);
    l_bfy_value         VARCHAR2(30);
    l_amount_remaining  NUMBER;

    CURSOR c_rcv_extract_lines IS
    SELECT *
      FROM cst_xla_rcv_lines_v;


    CURSOR c_rcv_extract_detail
    (
      c_event_id NUMBER,
      c_rcv_sub_ledger_id NUMBER
    )
    IS
    SELECT xeg.event_id event_id,
           ROW_NUMBER() OVER(PARTITION BY xeg.event_id ORDER BY xeg.event_id) line_number,
           DECODE(rrs.accounted_dr, NULL, -1*rrs.accounted_cr, rrs.accounted_dr) accounted_amount,
           DECODE(rrs.entered_dr, NULL, -1*rrs.entered_cr, rrs.entered_dr ) entered_amount,
           xeg.ledger_id,
           xeg.event_type_code,
           rae.transaction_date,
           pod.budget_account_id budget_account,
           pod.amount_ordered,
           pll.price_override,
           pod.rate,
           pod.amount_delivered,
           pod.amount_billed,
           pod.quantity_ordered,
           pod.quantity_delivered,
           pod.quantity_billed,
           pol.unit_price,
           pod.po_header_id,
           pod.po_distribution_id,
           rrs.currency_conversion_rate
      FROM rcv_receiving_sub_ledger rrs,
           xla_events_gt xeg,
           rcv_accounting_events rae,
           po_distributions_all pod,
           po_line_locations_all pll,
           po_lines_all pol
     WHERE xeg.source_id_int_1 = rrs.rcv_transaction_id
       AND xeg.source_id_int_2 = rrs.accounting_event_id
       AND xeg.entity_code = 'RCV_ACCOUNTING_EVENTS'
       AND rae.accounting_event_id = rrs.accounting_event_id
       AND rae.rcv_transaction_id = rrs.rcv_transaction_id
       AND ((xeg.budgetary_control_flag = 'N' AND xeg.event_type_code IN ('DELIVER_EXPENSE', 'RETURN_TO_RECEIVING')) OR
             (xeg.budgetary_control_flag = 'Y' AND xeg.event_type_code NOT IN ('DELIVER_EXPENSE', 'RETURN_TO_RECEIVING')))
       AND xeg.event_id = c_event_id
       AND rrs.rcv_sub_ledger_id = c_rcv_sub_ledger_id
       AND rrs.accounting_line_type = 'Charge'
       AND pod.po_header_id = rae.po_header_id
       AND pod.po_line_id = rae.po_line_id
       AND pod.line_location_id = rae.po_line_location_id
       AND pod.po_distribution_id = rae.po_distribution_id
       AND pll.po_header_id = pod.po_header_id
       AND pll.line_location_id = pod.line_location_id
       AND pll.po_line_id = pod.po_line_id
       AND pol.po_header_id = pll.po_header_id
       AND pol.po_line_id = pll.po_line_id
       AND xeg.event_type_code IN ('DELIVER_EXPENSE',
                                   'RETURN_TO_RECEIVING',
                                   'PO_DEL_INV',
                                   'RET_RI_INV')
     ORDER BY 1;

    l_treasury_symbol_id      fv_treasury_symbols.treasury_symbol_id%TYPE;
    l_treasury_symbol         fv_treasury_symbols.treasury_symbol%TYPE;
    l_amount_ordered          NUMBER;
    l_amount_delivered    NUMBER;
    l_amount_billed           NUMBER;
    l_pya                     VARCHAR2(1);
    l_pya_type                VARCHAR2(20);
    l_4801_bal           NUMBER;
    l_4802_bal           NUMBER;
    l_4901_bal           NUMBER;
    l_4902_bal           NUMBER;
    l_4610_bal           NUMBER;
    l_sign               NUMBER;

  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    l_error_code := C_SUCCESS;
    trace(C_STATE_LEVEL, l_procedure_name, 'Begin of procedure '||l_procedure_name);

    IF (p_application_id <> 707) THEN
      RETURN;
    END IF;

    l_index:=0;
    FOR l_rcv_extract_lines_rec IN c_rcv_extract_lines LOOP
      FOR l_rcv_extract_detail_rec IN c_rcv_extract_detail
          (
            l_rcv_extract_lines_rec.event_id,
            l_rcv_extract_lines_rec.distribution_identifier
          ) LOOP
        l_index := l_index + 1;
        l_fv_extract_detail(l_index).event_id := l_rcv_extract_detail_rec.event_id;
        l_fv_extract_detail(l_index).line_number := l_rcv_extract_lines_rec.Line_number;
        l_fv_extract_detail(l_index).prior_year_flag := 'N';
        fv_sla_utl_processing_pkg.init_extract_record(p_application_id, l_fv_extract_detail(l_index));
        l_sign := SIGN (l_rcv_extract_detail_rec.accounted_amount);

        trace(C_STATE_LEVEL, l_procedure_name, 'Calling get_ledger_info');
        trace(C_STATE_LEVEL, l_procedure_name, 'ledger_id='||l_rcv_extract_detail_rec.ledger_id);
        fv_sla_utl_processing_pkg.get_ledger_info
        (
          p_ledger_id  => l_rcv_extract_detail_rec.ledger_id,
          p_ledger_rec => l_ledger_info,
          p_error_code => l_error_code,
          p_error_desc => l_error_desc
        );

        IF (l_error_code = C_SUCCESS) THEN
          trace(C_STATE_LEVEL, l_procedure_name, 'Calling get_segment_values');
          trace(C_STATE_LEVEL, l_procedure_name, 'p_ledger_id='||l_ledger_info.ledger_id);
          trace(C_STATE_LEVEL, l_procedure_name, 'p_ccid='||l_rcv_extract_detail_rec.budget_account);
          fv_sla_utl_processing_pkg.get_segment_values
          (
            p_ledger_id     => l_ledger_info.ledger_id,
            p_ccid          => l_rcv_extract_detail_rec.budget_account,
            p_fund_value    => l_fund_value,
            p_account_value => l_account_value,
            p_bfy_value     => l_bfy_value,
            p_error_code    => l_error_code,
            p_error_desc    => l_error_desc
          );
        END IF;

        IF (l_error_code = C_SUCCESS) THEN
          trace(C_STATE_LEVEL, l_procedure_name, 'p_fund_value='||l_fund_value);
          trace(C_STATE_LEVEL, l_procedure_name, 'p_account_value='||l_account_value);
          trace(C_STATE_LEVEL, l_procedure_name, 'p_bfy_value='||l_bfy_value);
          l_fv_extract_detail(l_index).fund_value :=l_fund_value;

          trace(C_STATE_LEVEL, l_procedure_name, 'Calling get_fund_details');
          trace(C_STATE_LEVEL, l_procedure_name, 'p_application_id='||p_application_id);
          trace(C_STATE_LEVEL, l_procedure_name, 'p_ledger_id='||l_ledger_info.ledger_id);
          trace(C_STATE_LEVEL, l_procedure_name, 'p_fund_value='||l_fund_value);
          trace(C_STATE_LEVEL, l_procedure_name, 'p_gl_date='||l_rcv_extract_detail_rec.transaction_date);
          fv_sla_utl_processing_pkg.get_fund_details
          (
            p_application_id     => p_application_id,
            p_ledger_id          => l_ledger_info.ledger_id,
            p_fund_value         => l_fund_value,
            p_gl_date            => l_rcv_extract_detail_rec.transaction_date,
            p_fund_category      => l_fv_extract_detail(l_index).fund_category,
            p_fund_status        => l_fv_extract_detail(l_index).fund_expired_status,
            p_fund_time_frame    => l_fv_extract_detail(l_index).fund_time_frame,
            p_treasury_symbol_id => l_treasury_symbol_id,
            p_treasury_symbol    => l_treasury_symbol,
            p_error_code         => l_error_code,
            p_error_desc         => l_error_desc
          );
        END IF;

        IF (l_error_code = C_SUCCESS) THEN
          trace(C_STATE_LEVEL, l_procedure_name, 'fund_category='||l_fv_extract_detail(l_index).fund_category);
          trace(C_STATE_LEVEL, l_procedure_name, 'fund_expired_status='||l_fv_extract_detail(l_index).fund_expired_status);
          trace(C_STATE_LEVEL, l_procedure_name, 'fund_time_frame='||l_fv_extract_detail(l_index).fund_time_frame);
          trace(C_STATE_LEVEL, l_procedure_name, 'l_treasury_symbol_id='||l_treasury_symbol_id);
          trace(C_STATE_LEVEL, l_procedure_name, 'l_treasury_symbol='||l_treasury_symbol);

          trace(C_STATE_LEVEL, l_procedure_name, 'event_type_code='||l_rcv_extract_detail_rec.event_type_code);
          trace(C_STATE_LEVEL, l_procedure_name, 'accounted_amount='||l_rcv_extract_detail_rec.accounted_amount);
          trace(C_STATE_LEVEL, l_procedure_name, 'price_override='||l_rcv_extract_detail_rec.price_override);
          trace(C_STATE_LEVEL, l_procedure_name, 'amount_ordered='||l_rcv_extract_detail_rec.amount_ordered);
          trace(C_STATE_LEVEL, l_procedure_name, 'quantity_ordered='||l_rcv_extract_detail_rec.quantity_ordered);
          trace(C_STATE_LEVEL, l_procedure_name, 'amount_delivered='||l_rcv_extract_detail_rec.amount_delivered);
          trace(C_STATE_LEVEL, l_procedure_name, 'quantity_delivered='||l_rcv_extract_detail_rec.quantity_delivered);
          trace(C_STATE_LEVEL, l_procedure_name, 'amount_billed='||l_rcv_extract_detail_rec.amount_billed);
          trace(C_STATE_LEVEL, l_procedure_name, 'quantity_billed='||l_rcv_extract_detail_rec.quantity_billed);

          IF NVL(l_rcv_extract_detail_rec.amount_ordered, 0) = 0 THEN
            l_amount_ordered := l_rcv_extract_detail_rec.quantity_ordered*l_rcv_extract_detail_rec.price_override;
          ELSE
            l_amount_ordered := l_rcv_extract_detail_rec.amount_ordered;
          END IF;

          IF NVL(l_rcv_extract_detail_rec.amount_delivered, 0) = 0 THEN
            l_amount_delivered := l_rcv_extract_detail_rec.quantity_delivered*l_rcv_extract_detail_rec.price_override;
          ELSE
            l_amount_delivered := l_rcv_extract_detail_rec.amount_delivered;
          END IF;

          IF NVL(l_rcv_extract_detail_rec.amount_billed, 0) = 0 THEN
            l_amount_billed := l_rcv_extract_detail_rec.quantity_billed*l_rcv_extract_detail_rec.price_override;
          ELSE
            l_amount_billed := l_rcv_extract_detail_rec.amount_billed;
          END IF;

          trace(C_STATE_LEVEL, l_procedure_name, 'Amount Ordered  ' || l_amount_ordered);
          trace(C_STATE_LEVEL, l_procedure_name, 'Amount Delivered ' || l_amount_delivered);
          trace(C_STATE_LEVEL, l_procedure_name, 'Amount Billed ' || l_amount_billed);
          trace(C_STATE_LEVEL, l_procedure_name, 'Amount Accounted ' || l_rcv_extract_detail_rec.accounted_amount);

          IF (l_error_code = C_SUCCESS) THEN
            trace(C_STATE_LEVEL, l_procedure_name, 'Calling get_sla_doc_balances');
            fv_sla_utl_processing_pkg.get_sla_doc_balances
            (
              p_called_from        => 'CST',
              p_trx_amount         => l_rcv_extract_detail_rec.entered_amount,
              p_ordered_amount     => l_amount_ordered,
              p_delivered_amount   => l_amount_delivered,
              p_billed_amount      => l_amount_billed,
              p_4801_bal           => l_4801_bal,
              p_4802_bal           => l_4802_bal,
              p_4901_bal           => l_4901_bal,
              p_4902_bal           => l_4902_bal,
              p_error_code         => l_error_code,
              p_error_desc         => l_error_desc
            );
          END IF;

          IF (l_error_code = C_SUCCESS) THEN
            l_amount_remaining := ABS(l_rcv_extract_detail_rec.entered_amount);
            IF l_rcv_extract_detail_rec.event_type_code IN ('RETURN_TO_RECEIVING', 'RET_RI_INV') THEN
              l_4610_bal := (l_4801_bal + l_4802_bal + l_4901_bal + l_4902_bal) - l_amount_ordered;
              /* First try to use up all the 4610 amt */
              IF (l_4610_bal > 0) THEN
                trace(C_STATE_LEVEL, l_procedure_name, 'Using 4610 Balance');
                IF (l_4610_bal >= l_amount_remaining) THEN
                  l_fv_extract_detail(l_index).ent_unanticipated_bud_amount := l_amount_remaining;
                  l_4610_bal := l_4610_bal - l_amount_remaining;
                  l_amount_remaining := 0;
                ELSE
                  l_fv_extract_detail(l_index).ent_unanticipated_bud_amount := l_4610_bal;
                  l_amount_remaining :=  l_amount_remaining - l_4610_bal;
                  l_4610_bal := 0;
                END IF;
              END IF;

              IF (l_amount_remaining > 0) THEN
                IF (l_4901_bal > 0) THEN
                  trace(C_STATE_LEVEL, l_procedure_name, 'Using 4901 Balance');
                  IF (l_4901_bal >= l_amount_remaining) THEN
                    l_fv_extract_detail(l_index).ent_unpaid_obl_amount := l_amount_remaining;
                    l_4901_bal := l_4901_bal - l_amount_remaining;
                    l_amount_remaining := 0;
                  ELSE
                    l_fv_extract_detail(l_index).ent_unpaid_obl_amount := l_4901_bal;
                    l_amount_remaining :=  l_amount_remaining - l_4901_bal;
                    l_4901_bal := 0;
                  END IF;
                END IF;
              END IF;

              IF (l_amount_remaining > 0) THEN
                IF (l_4902_bal > 0) THEN
                  trace(C_STATE_LEVEL, l_procedure_name, 'Using 4902 Balance');
                  IF (l_4902_bal >= l_amount_remaining) THEN
                    l_fv_extract_detail(l_index).ent_paid_exp_amount := l_amount_remaining;
                    l_4902_bal := l_4902_bal - l_amount_remaining;
                    l_amount_remaining := 0;
                  ELSE
                    l_fv_extract_detail(l_index).ent_paid_exp_amount := l_4902_bal;
                    l_amount_remaining :=  l_amount_remaining - l_4902_bal;
                    l_4902_bal := 0;
                  END IF;
                END IF;
              END IF;

            ELSE
              /* First try to use up all the 4802 amt */
              IF (l_4802_bal > 0) THEN
                trace(C_STATE_LEVEL, l_procedure_name, 'Using 4802 Balance');
                IF (l_4802_bal >= l_amount_remaining) THEN
                  l_fv_extract_detail(l_index).ent_paid_exp_amount := l_amount_remaining;
                  l_4802_bal := l_4802_bal - l_amount_remaining;
                  l_amount_remaining := 0;
                ELSE
                  l_fv_extract_detail(l_index).ent_paid_exp_amount := l_4802_bal;
                  l_amount_remaining :=  l_amount_remaining - l_4802_bal;
                  l_4802_bal := 0;
                END IF;
              END IF;

              /* If any amount remaining use up all the 4801 amt */
              IF (l_amount_remaining > 0) THEN
                IF (l_4801_bal > 0) THEN
                  trace(C_STATE_LEVEL, l_procedure_name, 'Using 4801 Balance');
                  IF (l_4801_bal >= l_amount_remaining) THEN
                    l_fv_extract_detail(l_index).ent_unpaid_obl_amount := l_amount_remaining;
                    l_4801_bal := l_4801_bal - l_amount_remaining;
                    l_amount_remaining := 0;
                  ELSE
                    l_fv_extract_detail(l_index).ent_unpaid_obl_amount := l_4801_bal;
                    l_amount_remaining :=  l_amount_remaining - l_4801_bal;
                    l_4801_bal := 0;
                  END IF;
                END IF;
              END IF;

              /* Now use up all unaticipated amt */
              IF (l_amount_remaining > 0) THEN
                l_fv_extract_detail(l_index).ent_unanticipated_bud_amount := l_amount_remaining;
                l_amount_remaining := 0;
              END IF;
            END IF;

            l_fv_extract_detail(l_index).ent_unpaid_exp_amount := l_fv_extract_detail(l_index).ent_unpaid_obl_amount +
                                                                  l_fv_extract_detail(l_index).ent_unanticipated_bud_amount;
            l_fv_extract_detail(l_index).ent_charge_amount := l_rcv_extract_detail_rec.entered_amount;
            l_fv_extract_detail(l_index).acc_charge_amount := l_rcv_extract_detail_rec.accounted_amount;

            l_fv_extract_detail(l_index).acc_unpaid_exp_amount := l_rcv_extract_detail_rec.currency_conversion_rate *
                                                                  l_fv_extract_detail(l_index).ent_unpaid_exp_amount;
            l_fv_extract_detail(l_index).acc_unpaid_obl_amount := l_rcv_extract_detail_rec.currency_conversion_rate *
                                                                  l_fv_extract_detail(l_index).ent_unpaid_obl_amount;
            l_fv_extract_detail(l_index).ent_unanticipated_bud_amount := -1* l_fv_extract_detail(l_index).ent_unanticipated_bud_amount;
            l_fv_extract_detail(l_index).acc_unanticipated_bud_amount := l_rcv_extract_detail_rec.currency_conversion_rate *
                                                                  l_fv_extract_detail(l_index).ent_unanticipated_bud_amount;
            l_fv_extract_detail(l_index).acc_paid_exp_amount := l_rcv_extract_detail_rec.currency_conversion_rate *
                                                                  l_fv_extract_detail(l_index).ent_paid_exp_amount;
          END IF;



          trace(C_STATE_LEVEL, l_procedure_name, 'ent_unpaid_exp_amount=' || l_fv_extract_detail(l_index).ent_unpaid_exp_amount);
          trace(C_STATE_LEVEL, l_procedure_name, 'ent_charge_amount=' || l_fv_extract_detail(l_index).ent_charge_amount);
          trace(C_STATE_LEVEL, l_procedure_name, 'ent_unpaid_obl_amount=' || l_fv_extract_detail(l_index).ent_unpaid_obl_amount);
          trace(C_STATE_LEVEL, l_procedure_name, 'ent_unanticipated_bud_amount=' || l_fv_extract_detail(l_index).ent_unanticipated_bud_amount);
          trace(C_STATE_LEVEL, l_procedure_name, 'ent_paid_exp_amount=' || l_fv_extract_detail(l_index).ent_paid_exp_amount);

          trace(C_STATE_LEVEL, l_procedure_name, 'acc_unpaid_exp_amount=' || l_fv_extract_detail(l_index).acc_unpaid_exp_amount);
          trace(C_STATE_LEVEL, l_procedure_name, 'acc_charge_amount=' || l_fv_extract_detail(l_index).acc_charge_amount);
          trace(C_STATE_LEVEL, l_procedure_name, 'acc_unpaid_obl_amount=' || l_fv_extract_detail(l_index).acc_unpaid_obl_amount);
          trace(C_STATE_LEVEL, l_procedure_name, 'acc_unanticipated_bud_amount=' || l_fv_extract_detail(l_index).acc_unanticipated_bud_amount);
          trace(C_STATE_LEVEL, l_procedure_name, 'acc_paid_exp_amount=' || l_fv_extract_detail(l_index).acc_paid_exp_amount);

        END IF;

        IF (l_error_code = C_SUCCESS) THEN
          fv_sla_utl_processing_pkg.get_prior_year_status
          (
            p_application_id => 101,
            p_ledger_id      => l_ledger_info.ledger_id,
            p_bfy_value      => l_bfy_value,
            p_gl_date        => l_rcv_extract_detail_rec.transaction_date,
            p_pya            => l_pya,
            p_pya_type       => l_pya_type,
            p_error_code     => l_error_code,
            p_error_desc     => l_error_desc
          );
        END IF;
        IF (l_error_code = C_SUCCESS) THEN
          IF (l_pya = 'Y') THEN
            trace(C_STATE_LEVEL, l_procedure_name, 'PYA');
            l_fv_extract_detail(l_index).prior_year_flag := 'Y';
            l_fv_extract_detail(l_index).ent_unpaid_obl_pya_amount := -1*l_fv_extract_detail(l_index).ent_unanticipated_bud_amount;
            l_fv_extract_detail(l_index).acc_unpaid_obl_pya_amount := -1*l_fv_extract_detail(l_index).acc_unanticipated_bud_amount;
            l_fv_extract_detail(l_index).ent_unpaid_obl_amount := l_rcv_extract_detail_rec.accounted_amount;
            l_fv_extract_detail(l_index).acc_unpaid_obl_amount := l_rcv_extract_detail_rec.accounted_amount;
            trace(C_STATE_LEVEL, l_procedure_name, 'ent_unpaid_obl_pya_amount=' || l_fv_extract_detail(l_index).ent_unpaid_obl_pya_amount);
            trace(C_STATE_LEVEL, l_procedure_name, 'ent_unpaid_obl_amount=' || l_fv_extract_detail(l_index).ent_unpaid_obl_amount);
          END IF;
        END IF;

        IF (l_error_code = C_SUCCESS) THEN
          IF (l_sign = -1) THEN
            --Negate all numbers
            trace(C_STATE_LEVEL, l_procedure_name, 'Negating all numbers');
            l_fv_extract_detail(l_index).ent_unpaid_obl_amount := -1*l_fv_extract_detail(l_index).ent_unpaid_obl_amount;
            l_fv_extract_detail(l_index).acc_unpaid_obl_amount := -1*l_fv_extract_detail(l_index).acc_unpaid_obl_amount;
            l_fv_extract_detail(l_index).ent_unanticipated_bud_amount := -1*l_fv_extract_detail(l_index).ent_unanticipated_bud_amount;
            l_fv_extract_detail(l_index).acc_unanticipated_bud_amount := -1*l_fv_extract_detail(l_index).acc_unanticipated_bud_amount;
            l_fv_extract_detail(l_index).ent_unpaid_exp_amount := -1*l_fv_extract_detail(l_index).ent_unpaid_exp_amount;
            l_fv_extract_detail(l_index).acc_unpaid_exp_amount := -1*l_fv_extract_detail(l_index).acc_unpaid_exp_amount;
            l_fv_extract_detail(l_index).ent_paid_exp_amount := -1*l_fv_extract_detail(l_index).ent_paid_exp_amount;
            l_fv_extract_detail(l_index).acc_paid_exp_amount := -1*l_fv_extract_detail(l_index).acc_paid_exp_amount;
            l_fv_extract_detail(l_index).ent_unpaid_obl_pya_amount := -1*l_fv_extract_detail(l_index).ent_unpaid_obl_pya_amount;
            l_fv_extract_detail(l_index).acc_unpaid_obl_pya_amount := -1*l_fv_extract_detail(l_index).acc_unpaid_obl_pya_amount;
          END IF;
        END IF;

        IF (l_error_code <> C_SUCCESS) THEN
          EXIT;
        END IF;
      END LOOP;
    END LOOP;
    IF (l_error_code = C_SUCCESS) THEN
       FORALL l_index IN l_fv_extract_detail .first..l_fv_extract_detail.last
          INSERT INTO fv_extract_detail_gt VALUES l_fv_extract_detail(l_index);
    END IF;
    trace(C_STATE_LEVEL, l_procedure_name, 'Calling dump_gt_table');
    fv_sla_utl_processing_pkg.dump_gt_table
    (
      p_fv_extract_detail => l_fv_extract_detail,
      p_error_code        => l_gt_error_code,
      p_error_desc        => l_error_desc
    );

    IF (l_error_code <>  C_SUCCESS) OR (l_gt_error_code <> C_SUCCESS) THEN
       APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    trace(C_PROC_LEVEL, l_procedure_name, 'End of procedure'||l_procedure_name);
  EXCEPTION
    WHEN OTHERS THEN
      trace(C_STATE_LEVEL, l_procedure_name, 'Error in Federal CST SLA processing '||SQLERRM);
      FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE' , 'Procedure :fv_sla_processing_pkg.cst_extract'|| CRLF|| 'Error     :'||SQLERRM);
      FND_MSG_PUB.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END cst_extract;


  PROCEDURE extract
  (
    p_application_id               IN            NUMBER,
    p_accounting_mode              IN            VARCHAR2
  )
  IS
    l_debug_info                   VARCHAR2(240);
    l_procedure_name               VARCHAR2(100) :='.EXTRACT';

  BEGIN

    l_procedure_name := g_path_name || l_procedure_name;
    -------------------------------------------------------------------------
    l_debug_info := 'Begin of procedure '||l_procedure_name;
    trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------


    IF (p_application_id = 707) THEN
        cst_extract(p_application_id, p_accounting_mode);
    ELSE
        RETURN;
    END IF;

    -------------------------------------------------------------------------
    l_debug_info := 'End of procedure '||l_procedure_name;
    trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------------------

  EXCEPTION
    WHEN OTHERS THEN
      l_debug_info := 'Error in Federal SLA Processing ' || SQLERRM;
      trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
      FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE' ,
           'Procedure :fv_sla_processing_pkg.extract'|| CRLF||
          'Error     :'||SQLERRM);
      FND_MSG_PUB.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END extract;

  PROCEDURE preaccounting
  (
    p_application_id               IN            NUMBER,
    p_ledger_id                    IN            INTEGER,
    p_process_category             IN            VARCHAR2,
    p_end_date                     IN            DATE,
    p_accounting_mode              IN            VARCHAR2,
    p_valuation_method             IN            VARCHAR2,
    p_security_id_int_1            IN            INTEGER,
    p_security_id_int_2            IN            INTEGER,
    p_security_id_int_3            IN            INTEGER,
    p_security_id_char_1           IN            VARCHAR2,
    p_security_id_char_2           IN            VARCHAR2,
    p_security_id_char_3           IN            VARCHAR2,
    p_report_request_id            IN            INTEGER
  ) IS
  BEGIN
    NULL;
  END;

  PROCEDURE postprocessing
  (
    p_application_id               IN            NUMBER,
    p_accounting_mode              IN            VARCHAR2
  )
  IS
  BEGIN
    NULL;
  END;

  PROCEDURE postaccounting
  (
    p_application_id               IN            NUMBER,
    p_ledger_id                    IN            INTEGER,
    p_process_category             IN            VARCHAR2,
    p_end_date                     IN            DATE,
    p_accounting_mode              IN            VARCHAR2,
    p_valuation_method             IN            VARCHAR2,
    p_security_id_int_1            IN            INTEGER,
    p_security_id_int_2            IN            INTEGER,
    p_security_id_int_3            IN            INTEGER,
    p_security_id_char_1           IN            VARCHAR2,
    p_security_id_char_2           IN            VARCHAR2,
    p_security_id_char_3           IN            VARCHAR2,
    p_report_request_id            IN            INTEGER
  )
  IS
  BEGIN
    NULL;
  END;
BEGIN
  init;
END fv_sla_cst_processing_pkg;

/
