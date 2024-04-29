--------------------------------------------------------
--  DDL for Package AP_OPEN_ITEMS_REVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_OPEN_ITEMS_REVAL_PKG" AUTHID CURRENT_USER AS
/* $Header: apopitrs.pls 120.1.12010000.5 2009/04/30 10:55:02 kpasikan noship $ */

  /* Report input parameters which should be same as token names
  defined at concurrent program */
  P_ORG_ID                 ap_system_parameters_all.org_id%type;
  P_REVALUATION_PERIOD     gl_periods.period_name%type;
  P_DUE_DATE               gl_period_statuses.end_date%type;
  P_RATE_TYPE_LOOKUP_CODE  ap_lookup_codes.lookup_code%type;
  P_DAILY_RATE_TYPE        gl_daily_conversion_types.conversion_type%type;
  P_DAILY_RATE_DATE        gl_daily_rates.conversion_date%type;
  P_FROM_BALANCING_SEGMENT gl_code_combinations.segment1%type;
  P_TO_BALACING_SEGMENT    gl_code_combinations.segment1%type;
  P_TRANSFER_TO_GL_ONLY    varchar2(1);
  P_CLEARED_ONLY           varchar2(1);
  P_DEBUG_SWITCH           varchar2(1);
  P_TRACE_SWITCH           varchar2(1);

  /* Additional parameters */
  g_coa_id                 gl_ledgers.chart_of_accounts_id%type;
  g_ledger_id              gl_sets_of_books.set_of_books_id%type;
  g_base_precision         fnd_currencies_vl.precision%type;
  g_base_min_acct_unit     fnd_currencies_vl.minimum_accountable_unit%type;
  g_daily_rate_information varchar2(1) := 'N';
  g_daily_rate_error       varchar2(1) := 'N';

  /* Report displayed values*/
  g_operating_unit_dsp   hr_operating_units.name%type;
  g_gl_name_dsp          gl_sets_of_books.name%type;
  g_rate_type_dsp        ap_lookup_codes.displayed_field%type;
  g_daily_rate_type_dsp  gl_daily_conversion_types.user_conversion_type%type;
  g_trans_to_gl_only_dsp fnd_lookups.meaning%type;
  g_cleared_only_dsp     fnd_lookups.meaning%type;
  g_base_currency_code   gl_sets_of_books.currency_code%type;
  g_base_currency_desc   fnd_currencies_vl.description%type;
  g_revaluation_date     gl_period_statuses.end_date%type;

  /* Constants */
  c_application_id constant number := 200;

  /* xml query */
  G_SQL_STATEMENT varchar2(32000) := '
          select  balancing_segment   BALANCING_SEGMENT,
                  account_segment     ACCOUNT_SEGMENT,
                  opit.code_combination_id,
                  account             ACCOUNT,
                  &ACCOUNT_DESCRIPTION ACCOUNT_DESCRIPTION,
                  party_id            PARTY_ID,
                  party_site_id       PARTY_SITE_ID,
                  vendor_id           VENDOR_ID,
                  party_name          VENDOR_NAME,
                  vendor_number       VENDOR_NUMBER,
                  vendor_site_id      VENDOR_SITE_ID,
                  vendor_site_code    VENDOR_SITE_CODE,
                  txn_id              TXN_ID,
                  txn_number           TXN_NUMBER,
                  txn_type_lookup_code TXN_TYPE_LOOKUP_CODE,
                  txn_date             TXN_DATE,
                  txn_currency_code    TXN_CURRENCY_CODE,
                  payment_currency_code PMT_CURRENCY_CODE,
                  round(TXN_BASE_EXCHANGE_RATE, 5)         EXCHANGE_RATE,
                  payment_cross_rate             PAYMENT_CROSS_RATE,
                  decode(revaluation_rate,
                         null, ''No Rate'',
                               round(revaluation_rate, 5)) REVALUATION_RATE,
                  payment_status_flag   PAYMENT_STATUS_FLAG,
                  entered_amount        ENTERED_AMOUNT,
                  accounted_amount      ACCOUNTED_AMOUNT,
                  open_entered_amount   OPEN_ENTERED_AMOUNT,
                  open_accounted_amount OPEN_ACCOUNTED_AMOUNT,
                  nvl(TO_CHAR(round(open_entered_amount * revaluation_rate, :g_base_precision)), ''*'') REVALUED_AMOUNT_DSP,
                  nvl(round(open_entered_amount * revaluation_rate, :g_base_precision), 0) REVALUED_AMOUNT,
                  case when revaluation_rate is null
                            or open_accounted_amount > round(open_entered_amount * revaluation_rate, :g_base_precision)
                      then open_accounted_amount
                      else round(open_entered_amount * revaluation_rate, :g_base_precision)
                  end                     OPEN_REVALUED_AMOUNT,
                  AP_OPEN_ITEMS_REVAL_PKG.get_due_Date(txn_id, txn_type_lookup_code) DUE_dATE
          from(
              $open_items_query$
              ) opit
          order by balancing_segment,
                   account_segment,
                   account,
                   party_name,
                   vendor_number,
                   vendor_site_code,
                   txn_number,
                   txn_type_lookup_code,
                   txn_date';

  /* loacl procedure, can be usable only by the report */
  function get_revaluation_rate(l_currency_code IN gl_sets_of_books.currency_code%type)
    return number;

  /* loacl procedure, can be usable only by the report */
  function get_due_date(p_invoice_id IN number, p_type in varchar2)
    return date;

  /* Report triggers, which will be called from xml */
  function before_report return boolean;

END AP_OPEN_ITEMS_REVAL_PKG;

/
