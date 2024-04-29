--------------------------------------------------------
--  DDL for Package Body ARRX_BRS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARRX_BRS" AS
/* $Header: ARRXBRB.pls 120.5 2006/04/24 12:08:49 ggadhams ship $ */

PROCEDURE arrxbrs_report(p_request_id                  IN NUMBER
                        ,p_user_id                     IN NUMBER
                        ,p_reporting_level             IN VARCHAR2
                        ,p_reporting_entity_id         IN NUMBER
                        ,p_status_as_of_date           IN DATE
                        ,p_first_status                IN VARCHAR2
                        ,p_second_status               IN VARCHAR2
                        ,p_third_status                IN VARCHAR2
                        ,p_excluded_status             IN VARCHAR2
                        ,p_transaction_type            IN VARCHAR2
                        ,p_maturity_date_from          IN DATE
                        ,p_maturity_date_to            IN DATE
                        ,p_drawee_name                 IN VARCHAR2
                        ,p_drawee_number_from          IN VARCHAR2
                        ,p_drawee_number_to            IN VARCHAR2
                        ,p_remittance_batch_name       IN VARCHAR2
                        ,p_remittance_bank_account     IN VARCHAR2
                        ,p_drawee_bank_name            IN VARCHAR2
                        ,p_original_amount_from        IN NUMBER
                        ,p_original_amount_to          IN NUMBER
                        ,p_transaction_issue_date_from IN DATE
                        ,p_transaction_issue_date_to   IN DATE
                        ,p_on_hold                     IN VARCHAR2
                        ,retcode                       OUT NOCOPY NUMBER
                        ,errbuf                        OUT NOCOPY VARCHAR2) AS

-- Declare local variables
  l_login_id                   NUMBER;
  l_creation_gl_date           DATE;
  l_original_maturity_date     DATE;
  l_unpaid_date                DATE;
  l_acceptance_date            DATE;
  l_remit_date                 DATE;
  l_as_of_date                 VARCHAR2(4000);
  l_remit_batch                VARCHAR2(4000);
  l_open_amount                VARCHAR2(4000);
  l_assigned_amount            VARCHAR2(4000);
  l_receipt_reversal           VARCHAR2(4000);
  l_status_where               VARCHAR2(200);
  l_excluded_status_where      VARCHAR2(100);
  l_transaction_type_where     VARCHAR2(100);
  l_maturity_date_where        VARCHAR2(200);
  l_drawee_name_where          VARCHAR2(300);
  l_drawee_number_where        VARCHAR2(200);
  l_drawee_bank_name_where     VARCHAR2(100);
  l_issue_date_where           VARCHAR2(200);
  l_on_hold_where              VARCHAR2(100);
  l_org_where_trx              VARCHAR2(2000);
  l_org_where_trl              VARCHAR2(2000);
  l_org_where_rabs             VARCHAR2(2000);
  l_org_where_ctt              VARCHAR2(2000);
  l_org_where_raa              VARCHAR2(2000);
  l_org_where_rasu             VARCHAR2(2000);
  l_org_where_aba              VARCHAR2(2000);
  l_org_where_raba             VARCHAR2(2000);
  l_org_where_rah              VARCHAR2(2000);
  l_org_where_rah1             VARCHAR2(2000);
  l_org_where_ps               VARCHAR2(2000);
  l_org_where_rab              VARCHAR2(2000);
  l_org_where_arb              VARCHAR2(2000);
  l_org_where_app              VARCHAR2(2000);
  l_org_where_cr               VARCHAR2(2000);
  l_books_id                   GL_SETS_OF_BOOKS.set_of_books_id%TYPE;
  l_currency_code              GL_SETS_OF_BOOKS.currency_code%TYPE;
  l_sob_name                   GL_SETS_OF_BOOKS.name%TYPE;
  l_populate                   VARCHAR2(1);
  l_populate_amt               VARCHAR2(1) := 'Y';
  l_new_ADR                    AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE;
  l_new_acctd_ADR              AR_PAYMENT_SCHEDULES.acctd_amount_due_remaining%TYPE;
  l_new_original_funct_amt     AR_PAYMENT_SCHEDULES.amount_due_original%TYPE;

-- Declare variables for Dynamic Cursors
  v_CursorID_main             INTEGER;
  v_Dummy_main                INTEGER;
  v_CursorID_date             INTEGER;
  v_Dummy_date                INTEGER;
  v_CursorID_rbatch           INTEGER;
  v_Dummy_rbatch              INTEGER;
  v_CursorID_amt              INTEGER;
  v_Dummy_amt                 INTEGER;
  v_CursorID_rev              INTEGER;
  v_Dummy_rev                 INTEGER;
  v_CursorID_asg              INTEGER;
  v_Dummy_asg                 INTEGER;

-- Declare the variables which will hold the results of the SELECT statements
  v_status                          AR_LOOKUPS.meaning%TYPE;
  v_status_date                     AR_TRANSACTION_HISTORY.trx_date%TYPE;
  v_customer_trx_id                 RA_CUSTOMER_TRX.customer_trx_id%TYPE;
  v_transaction_number              RA_CUSTOMER_TRX.trx_number%TYPE;
  v_document_number                 RA_CUSTOMER_TRX.doc_sequence_value%TYPE;
  v_document_sequence_name          FND_DOCUMENT_SEQUENCES.name%TYPE;
  v_currency_code                   RA_CUSTOMER_TRX.invoice_currency_code%TYPE;
  v_magnetic_format_code            RA_CUST_TRX_TYPES.magnetic_format_code%TYPE;
  v_original_entered_amount         AR_PAYMENT_SCHEDULES.amount_due_original%TYPE;
  v_open_entered_amount             AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE;
  v_open_functional_amount          AR_PAYMENT_SCHEDULES.acctd_amount_due_remaining%TYPE;
  v_assigned_entered_amount         RA_CUSTOMER_TRX_LINES.extended_amount%TYPE;
  v_assigned_functional_amount      RA_CUSTOMER_TRX_LINES.extended_acctd_amount%TYPE;
  v_drawee_name                     hz_parties.party_name%TYPE;
  v_drawee_number                   hz_cust_accounts.account_number%TYPE;
  v_drawee_taxpayer_id              hz_parties.jgzz_fiscal_code%TYPE;
  v_drawee_vat_reg_number           HZ_CUST_SITE_USES.tax_reference%TYPE;
  v_drawee_city                     HZ_LOCATIONS.city%TYPE;
  v_drawee_state                    HZ_LOCATIONS.state%TYPE;
  v_drawee_country                  HZ_LOCATIONS.country%TYPE;
  v_drawee_postal_code              HZ_LOCATIONS.postal_code%TYPE;
  v_drawee_class                    AR_LOOKUPS.meaning%TYPE;
  v_drawee_category                 AR_LOOKUPS.meaning%TYPE;
  v_drawee_location                 HZ_CUST_SITE_USES.location%TYPE;
  v_issue_date                      RA_CUSTOMER_TRX.trx_date%TYPE;
  v_status_gl_date                  AR_TRANSACTION_HISTORY.gl_date%TYPE;
  v_maturity_date                   RA_CUSTOMER_TRX.term_due_date%TYPE;
  v_issued_by_drawee                RA_CUST_TRX_TYPES.drawee_issued_flag%TYPE;
  v_signed_by_drawee                RA_CUST_TRX_TYPES.signed_flag%TYPE;
  v_transaction_type                RA_CUST_TRX_TYPES.name%TYPE;
  v_transaction_batch_source        RA_BATCH_SOURCES.name%TYPE;
  v_remit_bank_name                 ce_bank_branches_v.bank_name%TYPE;
  v_remit_bank_number               ce_bank_branches_v.bank_number%TYPE;
  v_remit_branch_name               ce_bank_branches_v.bank_branch_name%TYPE;
  v_remit_branch_number             ce_bank_branches_v.branch_number%TYPE;
  v_remit_bank_acc_name             ce_bank_accounts.bank_account_name%TYPE;
  v_remit_bank_acc_number           ce_bank_accounts.bank_account_num%TYPE;
  v_remit_bank_acc_id               ce_bank_accounts.bank_account_id%TYPE;
  v_remit_branch_city               ce_bank_branches_v.city%TYPE;
  v_remit_branch_state              ce_bank_branches_v.state%TYPE;
  v_remit_branch_country            ce_bank_branches_v.country%TYPE;
  v_remit_branch_postal_code        ce_bank_branches_v.zip%TYPE;
  v_remit_branch_address1           ce_bank_branches_v.address_line1%TYPE;
  v_remit_branch_address2           ce_bank_branches_v.address_line2%TYPE;
  v_remit_branch_address3           ce_bank_branches_v.address_line3%TYPE;
  v_remit_bank_allow_override       RA_CUSTOMER_TRX.override_remit_account_flag%TYPE;
  v_remit_bank_acc_check_digits     ce_bank_accounts.check_digits%TYPE;
  v_remit_bank_acc_curr             ce_bank_accounts.currency_code%TYPE;
  v_drawee_bank_name                ce_bank_branches_v.bank_name%TYPE;
  v_drawee_bank_number              ce_bank_branches_v.bank_number%TYPE;
  v_drawee_branch_name              ce_bank_branches_v.bank_branch_name%TYPE;
  v_drawee_branch_number            ce_bank_branches_v.branch_number%TYPE;
  v_drawee_bank_acc_name            AP_BANK_ACCOUNTS.bank_account_name%TYPE;
  v_drawee_bank_acc_number          AP_BANK_ACCOUNTS.bank_account_num%TYPE;
  v_drawee_branch_city              ce_bank_branches_v.city%TYPE;
  v_drawee_branch_state             ce_bank_branches_v.state%TYPE;
  v_drawee_branch_country           ce_bank_branches_v.country%TYPE;
  v_drawee_branch_postal_code       ce_bank_branches_v.zip%TYPE;
  v_drawee_branch_address1          ce_bank_branches_v.address_line1%TYPE;
  v_drawee_branch_address2          ce_bank_branches_v.address_line2%TYPE;
  v_drawee_branch_address3          ce_bank_branches_v.address_line3%TYPE;
  v_drawee_bank_acc_check_digits    AP_BANK_ACCOUNTS.check_digits%TYPE;
  v_drawee_bank_acc_curr            AP_BANK_ACCOUNTS.currency_code%TYPE;
  v_comments                        RA_CUSTOMER_TRX.comments%TYPE;
  v_days_late                       NUMBER;
  v_remittance_batch_name           AR_BATCHES.name%TYPE;
  v_remittance_method               AR_BATCHES.remit_method_code%TYPE;
  v_with_recourse                   AR_BATCHES.with_recourse_flag%TYPE;
  v_last_printed_date               RA_CUSTOMER_TRX.printing_last_printed%TYPE;
  v_unpaid_receipt_rev_reason       AR_LOOKUPS.meaning%TYPE;
  v_risk_elimination_days           AR_RECEIPT_METHOD_ACCOUNTS.risk_elimination_days%TYPE;
  v_remittance_date                 AR_TRANSACTION_HISTORY.trx_date%TYPE;
  v_remittance_payment_method       AR_RECEIPT_METHODS.name%TYPE;
  v_creation_batch_name             RA_BATCHES.name%TYPE;
  v_drawee_address1                 HZ_LOCATIONS.address1%TYPE;
  v_drawee_address2                 HZ_LOCATIONS.address2%TYPE;
  v_drawee_address3                 HZ_LOCATIONS.address3%TYPE;
  v_drawee_contact                  VARCHAR2(100);
  v_special_instructions            RA_CUSTOMER_TRX.special_instructions%TYPE;
  v_status_code                     AR_TRANSACTION_HISTORY.status%TYPE;
  v_amount_applied                  AR_RECEIVABLE_APPLICATIONS.amount_applied%TYPE;
  v_functional_amount_applied       AR_RECEIVABLE_APPLICATIONS.amount_applied%TYPE;
  v_ps_exchange_rate                AR_PAYMENT_SCHEDULES.exchange_rate%TYPE;



  BEGIN

  -- Initialise status parameters
  retcode := 2;
  errbuf  := 'Inner Package Failure';

  -- Initialize MO Reporting
  XLA_MO_REPORTING_API.Initialize(p_reporting_level, p_reporting_entity_id, 'AUTO');

  -- Initialize the org parameters for the ALL tables
  l_org_where_trx  := XLA_MO_REPORTING_API.Get_Predicate('trx', null);
  l_org_where_trl  := XLA_MO_REPORTING_API.Get_Predicate('trl', null);
  l_org_where_rabs := XLA_MO_REPORTING_API.Get_Predicate('rabs', null);
  l_org_where_ctt  := XLA_MO_REPORTING_API.Get_Predicate('ctt', null);
  l_org_where_raa  := XLA_MO_REPORTING_API.Get_Predicate('raa', null);
  l_org_where_rasu := XLA_MO_REPORTING_API.Get_Predicate('rasu', null);
  l_org_where_aba  := XLA_MO_REPORTING_API.Get_Predicate('aba', null);
  l_org_where_raba := XLA_MO_REPORTING_API.Get_Predicate('raba', null);
  l_org_where_rah  := XLA_MO_REPORTING_API.Get_Predicate('rah', null);
  l_org_where_rah1 := XLA_MO_REPORTING_API.Get_Predicate('rah1', null);
  l_org_where_ps   := XLA_MO_REPORTING_API.Get_Predicate('ps', null);
  l_org_where_rab  := XLA_MO_REPORTING_API.Get_Predicate('rab', null);
  l_org_where_arb  := XLA_MO_REPORTING_API.Get_Predicate('arb', null);
  l_org_where_app  := XLA_MO_REPORTING_API.Get_Predicate('app', null);
  l_org_where_cr   := XLA_MO_REPORTING_API.Get_Predicate('cr', null);


  -- Get the Login info
  fnd_profile.get('LOGIN_ID', l_login_id);

  -- Get functional currency

/* bug 2018415 replace fnd_profile call
  fnd_profile.get(name => 'GL_SET_OF_BKS_ID',
                   val => l_books_id);
*/

 -- l_books_id := arp_global.sysparam.set_of_books_id;
--Bug 5041260 Setting the Set Of Books based on the reporting level
 if p_reporting_level = 3000 then

    select set_of_books_id
      into l_books_id
    from ar_system_parameters_all
    where org_id = p_reporting_entity_id;

  elsif p_reporting_level = 1000 then
   l_books_id := p_reporting_entity_id;
  end if ;


  SELECT currency_code,
         name
  INTO   l_currency_code,
         l_sob_name
  FROM   gl_sets_of_books
  WHERE  set_of_books_id = l_books_id;

  -- As of Date cursor
  l_as_of_date := 'SELECT  arl.meaning,
                           rah.trx_date,
                           rah.gl_date,
                           rah.status
                   FROM    ar_transaction_history_all rah,
                           ar_lookups arl
                   WHERE   arl.lookup_code  = rah.status '||
                   l_org_where_rah ||
                  'AND     arl.lookup_type = ''TRANSACTION_HISTORY_STATUS'''||
                  'AND     rah.transaction_history_id = (SELECT  MAX(rah1.transaction_history_id)
                                                         FROM    ar_transaction_history_all rah1
                                                         WHERE   rah1.trx_date  <= to_char(:b_status_date) '||
                                                         l_org_where_rah1 ||
                                                        'AND     rah1.customer_trx_id = :b_trx_id)';

  -- Remittance Batch / Bank Acc Details cursor
  l_remit_batch := 'SELECT  arb.name
                           ,arb.remit_method_code
                           ,arb.with_recourse_flag
                           ,rm.name
                           ,rabb.bank_name remit_bank_name
                           ,rabb.bank_number remit_bank_number
                           ,rabb.bank_branch_name remit_branch_name
                           ,rabb.branch_number remit_branch_number
                           ,cba.bank_account_name remit_bank_acc_name
                           ,cba.bank_account_num remit_bank_acc_number
                           ,cba.bank_account_id remit_bank_acc_id
                           ,rabb.city remit_branch_city
                           ,rabb.state remit_branch_state
                           ,rabb.country remit_branch_country
                           ,rabb.zip remit_branch_postal_code
                           ,rabb.address_line1 remit_branch_address1
                           ,rabb.address_line2 remit_branch_address2
                           ,rabb.address_line3 remit_branch_address3
                           ,cba.check_digits
                           ,cba.currency_code remit_bank_acc_curr
                           ,rma.risk_elimination_days
                    FROM    ar_transaction_history_all rah
                           ,ar_batches_all arb
                           ,ar_receipt_methods rm
                           ,ar_receipt_method_accounts rma
                           ,ce_bank_accounts cba
                           ,ce_bank_acct_uses raba
                           ,ce_bank_branches_v rabb
                    WHERE   rah.batch_id = arb.batch_id
                    AND     arb.receipt_method_id = rm.receipt_method_id(+)
                    AND     rm.receipt_method_id = rma.receipt_method_id(+)
                    AND     arb.remit_bank_acct_use_id = raba.bank_acct_use_id(+)
                    AND     raba.bank_account_id = cba.bank_account_id (+)
                    AND     cba.bank_branch_id = rabb.branch_party_id(+) '||
                    l_org_where_rah ||
                    l_org_where_arb ||
                    l_org_where_raba ||
                   'AND     rah.transaction_history_id = (SELECT max(rah1.transaction_history_id)
                                                          FROM   ar_transaction_history_all rah1
                                                          WHERE  rah1.trx_date  <= to_char(:b_status_date) '||
                                                          l_org_where_rah1 ||
                                                         'AND    rah1.batch_id IS NOT NULL
                                                          AND    rah1.customer_trx_id = :b_trx_id)';

  -- Open Amounts Cursor
  l_open_amount := 'SELECT  nvl(SUM(app.amount_applied),0)
                    FROM    ra_customer_trx_all trx,
                            ar_receivable_applications_all app
                    WHERE   trx.customer_trx_id = app.applied_customer_trx_id
                    AND     app.applied_customer_trx_id = :b_trx_id '||
                    l_org_where_trx ||
                    l_org_where_app ||
                   'AND     app.status = ''APP'''||
                   'AND     trunc(app.apply_date) > :b_status_as_of_date';

   -- Unpaid Receipt Reversal Reason Cursor
   l_receipt_reversal := 'SELECT distinct DECODE(cr.reversal_reason_code, NULL, NULL
                                                                     , initcap(arl.meaning))
                          FROM   ar_cash_receipts_all cr,
                                 ar_receivable_applications_all app,
                                 ar_lookups arl
                          WHERE  cr.cash_receipt_id = app.cash_receipt_id '||
                          l_org_where_app ||
                          l_org_where_cr ||
                         'AND    cr.reversal_reason_code = arl.lookup_code (+)
                          AND    arl.lookup_type (+) = ''CKAJST_REASON'''||
                         'AND    app.applied_customer_trx_id = :b_trx_id';

    -- Assigned Amounts Cursor
    l_assigned_amount := 'SELECT nvl(sum(trl.extended_amount),0),
                                 nvl(sum(trl.extended_acctd_amount),0)
                          FROM   ra_customer_trx_lines_all trl
                          WHERE  trl.customer_trx_id = :b_trx_id '||
                          l_org_where_trl;


/*------------------------------------+
 |           Where Clauses            |
 +------------------------------------*/
  -- Where clause for statuses
  IF p_first_status IS NOT NULL THEN
    IF p_second_status IS NOT NULL THEN
      IF p_third_status IS NOT NULL THEN
        l_status_where := 'and rah.status in (:b_first_status, :b_second_status, :b_third_status)';
      ELSE
        l_status_where := 'AND rah.status in (:b_first_status, :b_second_status)';
      END IF;
    ELSE
      l_status_where := 'AND rah.status = :b_first_status ';
    END IF;
  END IF;

  -- Where clause for excluded status
  IF p_excluded_status IS NOT NULL THEN
    l_excluded_status_where := 'AND rah.status <> :b_excluded_status ';
  END IF;

  -- Where clause for Transaction Type
  IF p_transaction_type IS NOT NULL THEN
    l_transaction_type_where := 'AND ctt.name = :b_transaction_type ';
  END IF;

  -- Where clause for Maturity Dates
  IF p_maturity_date_from IS NOT NULL THEN
    IF p_maturity_date_to IS NOT NULL THEN
      l_maturity_date_where := 'AND trunc(trx.term_due_date) between :b_maturity_date_from AND :b_maturity_date_to ';
    ELSE
      l_maturity_date_where := 'AND trunc(trx.term_due_date) >= :b_maturity_date_from ';
    END IF;
  ELSIF p_maturity_date_to IS NOT NULL THEN
    l_maturity_date_where := 'AND trunc(trx.term_due_date) <= :b_maturity_date_to ';
  END IF;

  -- Where Clause for Drawee Name
  IF p_drawee_name IS NOT NULL THEN
    l_drawee_name_where := 'AND party.party_name = :b_drawee_name ';
  END IF;

  -- Where clause for Drawee Number
  IF p_drawee_number_from IS NOT NULL THEN
    IF p_drawee_number_to IS NOT NULL THEN
      l_drawee_number_where := 'AND cust_acct.account_number between :b_drawee_number_from and :b_drawee_number_to ';
    ELSE
      l_drawee_number_where := 'AND cust_acct.account_number >= :b_drawee_number_from ';
    END IF;
  ELSIF p_drawee_number_to IS NOT NULL THEN
    l_drawee_number_where := 'AND cust_acct.account_number <= :b_drawee_number_to ';
  END IF;

  -- Where clause for Drawee Bank
  IF p_drawee_bank_name IS NOT NULL THEN
    l_drawee_bank_name_where := 'AND abb.bank_name = :b_drawee_bank_name ';
  END IF;

  -- Where clause for Transaction Issue Dates
  IF p_transaction_issue_date_from IS NOT NULL THEN
    IF p_transaction_issue_date_to IS NOT NULL THEN
      l_issue_date_where := 'AND trunc(trx.trx_date) between :b_issue_date_from and :b_issue_date_to ';
    ELSE
      l_issue_date_where := 'AND trunc(trx.trx_date) >= :b_issue_date_from ';
    END IF;
  ELSIF p_transaction_issue_date_to IS NOT NULL THEN
    l_issue_date_where := 'AND trunc(trx.trx_date) <= :b_issue_date_to ';
  END IF;

  -- Where clause for BR On Hold Flag
  IF p_on_hold IS NOT NULL THEN
    l_on_hold_where := 'AND trx.br_on_hold_flag = :b_on_hold ';
  END IF;


/*------------------------------------------------------------------+
 |                       Parse the main cursor                      |
 +------------------------------------------------------------------*/
  -- Open the cursor for dynamic processing.
  v_CursorID_main := DBMS_SQL.OPEN_CURSOR;

  -- Parse the main query.
  DBMS_SQL.PARSE(v_CursorID_main,
                     'SELECT  trx.customer_trx_id
                             ,trx.trx_number transaction_number
                             ,trx.doc_sequence_value document_number
                             ,fds.name document_sequence_name
                             ,trx.invoice_currency_code currency_code
                             ,ctt.magnetic_format_code
                             ,nvl(ps.amount_due_original,0) original_entered_amount
                             ,nvl(ps.amount_due_remaining,0) open_entered_amount
                             ,nvl(ps.acctd_amount_due_remaining,0) open_functional_amount
                             ,substrb(party.party_name,1,50) drawee_name
                             ,cust_acct.account_number drawee_number
                             ,party.jgzz_fiscal_code drawee_taxpayer_id
                             ,rasu.tax_reference drawee_vat_reg_number
                             ,loc.city drawee_city
                             ,loc.state drawee_state
                             ,loc.country drawee_country
                             ,loc.postal_code drawee_postal_code
                             ,arl_class.meaning drawee_class
                             ,arl_category.meaning drawee_category
                             ,rasu.location drawee_location
                             ,trx.trx_date issue_date
                             ,trx.term_due_date maturity_date
                             ,ctt.drawee_issued_flag issued_by_drawee
                             ,ctt.signed_flag signed_by_drawee
                             ,ctt.name transaction_type
                             ,rabb.bank_name remit_bank_name
                             ,rabb.bank_number remit_bank_number
                             ,rabb.bank_branch_name remit_branch_name
                             ,rabb.branch_number remit_branch_number
                             ,cba.bank_account_name remit_bank_acc_name
                             ,cba.bank_account_num remit_bank_acc_number
                             ,cba.bank_account_id remit_bank_acc_id
                             ,rabb.city remit_branch_city
                             ,rabb.state remit_branch_state
                             ,rabb.country remit_branch_country
                             ,rabb.zip remit_branch_postal_code
                             ,rabb.address_line1 remit_branch_address1
                             ,rabb.address_line2 remit_branch_address2
                             ,rabb.address_line3 remit_branch_address3
                             ,trx.override_remit_account_flag remit_bank_allow_override
                             ,cba.check_digits remit_bank_acc_check_digits
                             ,cba.currency_code remit_bank_acc_curr
                             ,abb.bank_name drawee_bank_name
                             ,abb.bank_number drawee_bank_number
                             ,abb.bank_branch_name drawee_branch_name
                             ,abb.branch_number drawee_branch_number
                             ,aba.bank_account_name drawee_bank_acc_name
                             ,aba.bank_account_num drawee_bank_acc_number
                             ,abb.city drawee_branch_city
                             ,abb.state drawee_branch_state
                             ,abb.country drawee_branch_country
                             ,abb.zip drawee_branch_postal_code
                             ,abb.address_line1 drawee_branch_address1
                             ,abb.address_line2 drawee_branch_address2
                             ,abb.address_line3 drawee_branch_address3
                             ,aba.check_digits drawee_bank_acc_check_digits
                             ,aba.currency_code drawee_bank_acc_curr
                             ,trx.comments
                             ,decode(ps.amount_due_remaining, 0 , to_number(null)
                                                                , trunc(sysdate) - ps.due_date) days_late
                             ,trx.printing_last_printed last_printed_date
                             ,loc.address1 drawee_address1
                             ,loc.address2 drawee_address2
                             ,loc.address3 drawee_address3
                             ,substrb(party.person_first_name,1,40) ||'' ''||substrb(party.person_last_name,1,50) drawee_contact
                             ,trx.special_instructions
                             ,rah.status status_code
                             ,rab.name creation_batch_name
                             ,rabs.name transaction_batch_source
                             ,nvl(ps.exchange_rate,1)
                      FROM    ra_cust_trx_types_all ctt
                             ,ra_customer_trx_all trx
                             ,hz_cust_acct_sites raa
                             ,hz_party_sites party_site
                             ,hz_locations loc
			     ,hz_cust_account_roles acct_role
                             ,hz_parties rel_party
                             ,hz_relationships  rel
                             ,hz_cust_site_uses_all rasu
                             ,ap_bank_accounts_all aba
                             ,ce_bank_branches_v abb
                             ,hz_cust_accounts cust_acct
                             ,hz_parties party
                             ,ce_bank_branches_v rabb
                             ,ce_bank_accounts cba
                             ,ce_bank_acct_uses raba
                             ,ar_lookups arl
                             ,ar_lookups arl_class
                             ,ar_lookups arl_category
                             ,ar_transaction_history_all rah
                             ,fnd_document_sequences fds
                             ,ar_payment_schedules_all ps
                             ,ra_batches_all rab
                             ,ra_batch_sources_all rabs
                      WHERE   trx.cust_trx_type_id = ctt.cust_trx_type_id
                      AND     trx.batch_source_id = rabs.batch_source_id
                      AND     trx.drawee_site_use_id = rasu.site_use_id (+)
                      AND     rasu.cust_acct_site_id = raa.cust_acct_site_id (+)
                      AND     raa.party_site_id = party_site.party_site_id (+)
                      AND     loc.location_id(+) = party_site.location_id
                      AND     trx.drawee_bank_account_id = aba.bank_account_id (+)
                      AND     aba.bank_branch_id = abb.branch_party_id (+)
                      AND     trx.drawee_id = cust_acct.cust_account_id
                      AND     cust_acct.party_id = party.party_id
                      AND     trx.remit_bank_acct_use_id = raba.bank_acct_use_id (+)
                      AND     raba.bank_account_id = cba.bank_account_id (+)
                      AND     cba.bank_branch_id = rabb.branch_party_id	(+)
                      AND     trx.drawee_contact_id = acct_role.cust_account_role_id (+)
                      AND     acct_role.party_id = rel.party_id (+)
                      AND     rel.subject_id = rel_party.party_id(+)
                      AND     rel.subject_table_name(+) = ''HZ_PARTIES'''||
                     'AND     rel.object_table_name(+) = ''HZ_PARTIES'''||
                     'AND     rel.directional_flag(+) = ''F'''||
                     'AND     rah.customer_trx_id  = trx.customer_trx_id
                      AND     rah.current_record_flag = ''Y'''||
                     'AND     arl.lookup_code = rah.status
                      AND     arl.lookup_type = ''TRANSACTION_HISTORY_STATUS'''||
                     'AND     trx.doc_sequence_id = fds.doc_sequence_id(+)
                      AND     cust_acct.customer_class_code = arl_class.lookup_code(+)
                      AND     arl_class.lookup_type(+) = ''CUSTOMER_CLASS'''||
                     'AND     party.category_code = arl_category.lookup_code(+)
                      AND     arl_category.lookup_type(+) = ''CUSTOMER_CATEGORY'''||
                      l_org_where_trx ||
                      l_org_where_rabs ||
                      l_org_where_ctt ||
                      l_org_where_raa ||
                      l_org_where_raa ||
                      l_org_where_rasu ||
                      l_org_where_aba ||
                      l_org_where_raba ||
                      l_org_where_rah ||
                      l_org_where_ps ||
                      l_org_where_rab||
                      l_status_where ||
                      l_excluded_status_where ||
                      l_transaction_type_where ||
                      l_maturity_date_where ||
                      l_drawee_name_where ||
                      l_drawee_number_where ||
                      l_drawee_bank_name_where ||
                      l_issue_date_where ||
                      l_on_hold_where ||
                     'AND     trx.customer_trx_id = ps.customer_trx_id(+)
                      AND     trx.batch_id = rab.batch_id(+)
                      AND     rah.status <> ''INCOMPLETE''',
                 DBMS_SQL.native);



/*------------------------------------------------------------------+
 |                   Bind variables for main cursor                 |
 +------------------------------------------------------------------*/

  -- If the MO Reporting Get Predicate function returns a bind variable then
  -- we need to bind it.
  IF l_org_where_trx like '%:p_reporting_entity_id%' THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID_main, ':p_reporting_entity_id', p_reporting_entity_id);
  END IF;

  IF p_first_status IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID_main, ':b_first_status', p_first_status);
      IF p_second_status IS NOT NULL THEN
        DBMS_SQL.BIND_VARIABLE(v_CursorID_main, ':b_second_status', p_second_status);
          IF p_third_status IS NOT NULL THEN
            DBMS_SQL.BIND_VARIABLE(v_CursorID_main, ':b_third_status', p_third_status);
          END IF;
      END IF;
  END IF;

  IF p_excluded_status IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID_main, ':b_excluded_status', p_excluded_status);
  END IF;

  IF p_transaction_type IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID_main, ':b_transaction_type', p_transaction_type);
  END IF;

  IF p_maturity_date_from IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID_main, ':b_maturity_date_from', p_maturity_date_from);
  END IF;

  IF p_maturity_date_to IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID_main, ':b_maturity_date_to', p_maturity_date_to);
  END IF;

  IF p_drawee_name IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID_main, ':b_drawee_name', p_drawee_name);
  END IF;

  IF p_drawee_number_from IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID_main, ':b_drawee_number_from', p_drawee_number_from);
  END IF;

  IF p_drawee_number_to IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID_main, ':b_drawee_number_to', p_drawee_number_to);
  END IF;

  IF p_drawee_bank_name IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID_main, ':b_drawee_bank_name', p_drawee_bank_name);
  END IF;

  IF p_transaction_issue_date_from IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID_main, ':b_issue_date_from', p_transaction_issue_date_from);
  END IF;

  IF p_transaction_issue_date_to IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID_main, ':b_issue_date_to', p_transaction_issue_date_to);
  END IF;

  IF p_on_hold IS NOT NULL THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID_main, ':b_on_hold', p_on_hold);
  END IF;


/*------------------------------------------------------------------+
 |                   Define the output variables                    |
 +------------------------------------------------------------------*/

  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 1,  v_customer_trx_id);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 2,  v_transaction_number, 20);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 3,  v_document_number);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 4,  v_document_sequence_name, 30);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 5,  v_currency_code, 15);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 6,  v_magnetic_format_code, 30);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 7,  v_original_entered_amount);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 8,  v_open_entered_amount);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 9,  v_open_functional_amount);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 10, v_drawee_name, 255);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 11, v_drawee_number, 30);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 12, v_drawee_taxpayer_id, 20);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 13, v_drawee_vat_reg_number, 50);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 14, v_drawee_city, 60);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 15, v_drawee_state, 60);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 16, v_drawee_country, 60);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 17, v_drawee_postal_code, 60);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 18, v_drawee_class, 80);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 19, v_drawee_category, 80);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 20, v_drawee_location, 40);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 21, v_issue_date);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 22, v_maturity_date);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 23, v_issued_by_drawee, 1);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 24, v_signed_by_drawee, 1);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 25, v_transaction_type, 20);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 26, v_remit_bank_name, 60);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 27, v_remit_bank_number, 30);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 28, v_remit_branch_name, 60);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 29, v_remit_branch_number, 25);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 30, v_remit_bank_acc_name, 80);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 31, v_remit_bank_acc_number, 30);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 32, v_remit_bank_acc_id);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 33, v_remit_branch_city, 25);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 34, v_remit_branch_state, 25);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 35, v_remit_branch_country, 25);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 36, v_remit_branch_postal_code, 20);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 37, v_remit_branch_address1, 35);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 38, v_remit_branch_address2, 35);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 39, v_remit_branch_address3, 35);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 40, v_remit_bank_allow_override, 1);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 41, v_remit_bank_acc_check_digits, 30);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 42, v_remit_bank_acc_curr, 15);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 43, v_drawee_bank_name, 60);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 44, v_drawee_bank_number, 30);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 45, v_drawee_branch_name, 60);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 46, v_drawee_branch_number, 25);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 47, v_drawee_bank_acc_name, 80);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 48, v_drawee_bank_acc_number, 30);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 49, v_drawee_branch_city, 25);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 50, v_drawee_branch_state, 25);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 51, v_drawee_branch_country, 25);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 52, v_drawee_branch_postal_code, 20);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 53, v_drawee_branch_address1, 35);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 54, v_drawee_branch_address2, 35);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 55, v_drawee_branch_address3, 35);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 56, v_drawee_bank_acc_check_digits, 30);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 57, v_drawee_bank_acc_curr, 15);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 58, v_comments, 240);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 59, v_days_late);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 60, v_last_printed_date);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 61, v_drawee_address1, 240);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 62, v_drawee_address2, 240);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 63, v_drawee_address3, 240);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 64, v_drawee_contact, 100);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 65, v_special_instructions, 240);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 66, v_status_code, 30);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 67, v_creation_batch_name, 50);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 68, v_transaction_batch_source, 50);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 69, v_ps_exchange_rate);


  -- Execute the statement. We're not concerned about the return
  -- value, but we do need to declare a variable for it.
  v_Dummy_main := DBMS_SQL.EXECUTE(v_CursorID_main);

  -- This is the fetch loop.
  LOOP

    -- Fetch the rows into the buffer, and also check for the exit
    -- condition from the loop.
    IF DBMS_SQL.FETCH_ROWS(v_CursorID_main) = 0 THEN
      EXIT;
    END IF;

    -- Retrieve the rows from the buffer into PL/SQL variables.
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 1,  v_customer_trx_id);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 2,  v_transaction_number);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 3,  v_document_number);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 4,  v_document_sequence_name);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 5,  v_currency_code);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 6,  v_magnetic_format_code);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 7,  v_original_entered_amount);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 8,  v_open_entered_amount);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 9,  v_open_functional_amount);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 10, v_drawee_name);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 11, v_drawee_number);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 12, v_drawee_taxpayer_id);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 13, v_drawee_vat_reg_number);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 14, v_drawee_city);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 15, v_drawee_state);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 16, v_drawee_country);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 17, v_drawee_postal_code);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 18, v_drawee_class);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 19, v_drawee_category);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 20, v_drawee_location);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 21, v_issue_date);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 22, v_maturity_date);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 23, v_issued_by_drawee);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 24, v_signed_by_drawee);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 25, v_transaction_type);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 26, v_remit_bank_name);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 27, v_remit_bank_number);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 28, v_remit_branch_name);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 29, v_remit_branch_number);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 30, v_remit_bank_acc_name);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 31, v_remit_bank_acc_number);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 32, v_remit_bank_acc_id);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 33, v_remit_branch_city);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 34, v_remit_branch_state);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 35, v_remit_branch_country);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 36, v_remit_branch_postal_code);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 37, v_remit_branch_address1);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 38, v_remit_branch_address2);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 39, v_remit_branch_address3);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 40, v_remit_bank_allow_override);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 41, v_remit_bank_acc_check_digits);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 42, v_remit_bank_acc_curr);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 43, v_drawee_bank_name);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 44, v_drawee_bank_number);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 45, v_drawee_branch_name);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 46, v_drawee_branch_number);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 47, v_drawee_bank_acc_name);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 48, v_drawee_bank_acc_number);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 49, v_drawee_branch_city);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 50, v_drawee_branch_state);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 51, v_drawee_branch_country);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 52, v_drawee_branch_postal_code);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 53, v_drawee_branch_address1);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 54, v_drawee_branch_address2);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 55, v_drawee_branch_address3);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 56, v_drawee_bank_acc_check_digits);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 57, v_drawee_bank_acc_curr);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 58, v_comments);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 59, v_days_late);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 60, v_last_printed_date);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 61, v_drawee_address1);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 62, v_drawee_address2);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 63, v_drawee_address3);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 64, v_drawee_contact);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 65, v_special_instructions);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 66, v_status_code);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 67, v_creation_batch_name);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 68, v_transaction_batch_source);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 69, v_ps_exchange_rate);

    -- Calculate correct Orignal Entered Funcional Amount
   --Bug 5041260 replaced the call  arp_util.calc_acctd_amount with
   --	 arp_util.calc_accounted_amount.
    arp_util.calc_accounted_amount(l_currency_code,
                               NULL,
                               NULL,
                               v_ps_exchange_rate,
                               '-',
                               v_open_entered_amount,
                               v_open_functional_amount,
                               v_original_entered_amount,
                               l_new_ADR,
                               l_new_acctd_ADR,
                               l_new_original_funct_amt);

  -- Restrict by original amount parameters if populated
    IF p_original_amount_from IS NOT NULL THEN
      IF p_original_amount_to IS NOT NULL THEN
        IF l_new_original_funct_amt BETWEEN p_original_amount_from and p_original_amount_to THEN
          l_populate_amt := 'Y';
        ELSE
          l_populate_amt := 'N';
        END IF;
      ELSE
        IF l_new_original_funct_amt >= p_original_amount_from THEN
          l_populate_amt := 'Y';
        ELSE
          l_populate_amt := 'N';
        END IF;
      END IF;
    ELSIF p_original_amount_to IS NOT NULL THEN
      IF l_new_original_funct_amt <= p_original_amount_to THEN
        l_populate_amt := 'Y';
      ELSE
        l_populate_amt := 'N';
      END IF;
    END IF;

    IF l_populate_amt = 'Y' THEN

    /*------------------------------------------------------------------+
     |                   Remittance Batch Information                   |
     +------------------------------------------------------------------*/

      -- Remittance Batch ID will be taken from the Pending Remittance status
      -- since this is the first stage where it will be populated.
      -- Moved to after as of date processing so that remittance batch
      -- information is also date specific.
      -- Remittance Bank Info is also selected and will update previous info.

      BEGIN

        -- Initialize parameters
           v_remittance_batch_name :=null;
           v_remittance_method :=null;
           v_with_recourse :=null;
           v_remittance_payment_method :=null;
           v_risk_elimination_days := null;
           l_populate := 'Y';

          -- Open the As of Date cursor for dynamic processing.
          v_CursorID_rbatch := DBMS_SQL.OPEN_CURSOR;

          -- Parse the As of Date Cursor
          DBMS_SQL.PARSE(v_CursorID_rbatch, l_remit_batch, DBMS_SQL.native);

          -- Bind variables for cursor.
          DBMS_SQL.BIND_VARIABLE(v_CursorID_rbatch, ':b_status_date', p_status_as_of_date);
          DBMS_SQL.BIND_VARIABLE(v_CursorID_rbatch, ':b_trx_id', v_customer_trx_id);

          -- If the MO Reporting Get Predicate function returns a bind variable then
          -- we need to bind it.
          IF l_org_where_trx like '%:p_reporting_entity_id%' THEN
            DBMS_SQL.BIND_VARIABLE(v_CursorID_rbatch, ':p_reporting_entity_id', p_reporting_entity_id);
          END IF;

          -- Define the output variables.
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_rbatch, 1,  v_remittance_batch_name, 20);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_rbatch, 2,  v_remittance_method, 30);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_rbatch, 3,  v_with_recourse, 1);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_rbatch, 4,  v_remittance_payment_method, 30);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_rbatch, 5,  v_remit_bank_name, 60);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_rbatch, 6,  v_remit_bank_number, 30);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_rbatch, 7,  v_remit_branch_name, 60);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_rbatch, 8,  v_remit_branch_number, 25);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_rbatch, 9,  v_remit_bank_acc_name, 80);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_rbatch, 10, v_remit_bank_acc_number, 30);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_rbatch, 11, v_remit_bank_acc_id);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_rbatch, 12, v_remit_branch_city, 25);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_rbatch, 13, v_remit_branch_state, 25);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_rbatch, 14, v_remit_branch_country, 25);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_rbatch, 15, v_remit_branch_postal_code, 20);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_rbatch, 16, v_remit_branch_address1, 35);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_rbatch, 17, v_remit_branch_address2, 35);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_rbatch, 18, v_remit_branch_address3, 35);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_rbatch, 19, v_remit_bank_acc_check_digits, 30);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_rbatch, 20, v_remit_bank_acc_curr, 15);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_rbatch, 21, v_risk_elimination_days);

          -- Execute the statement.
          v_Dummy_rbatch := DBMS_SQL.EXECUTE(v_CursorID_rbatch);

          IF DBMS_SQL.FETCH_ROWS(v_CursorID_rbatch) > 0 THEN
            DBMS_SQL.COLUMN_VALUE(v_CursorID_rbatch, 1,  v_remittance_batch_name);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_rbatch, 2,  v_remittance_method);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_rbatch, 3,  v_with_recourse);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_rbatch, 4,  v_remittance_payment_method);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_rbatch, 5,  v_remit_bank_name);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_rbatch, 6,  v_remit_bank_number);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_rbatch, 7,  v_remit_branch_name);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_rbatch, 8,  v_remit_branch_number);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_rbatch, 9,  v_remit_bank_acc_name);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_rbatch, 10, v_remit_bank_acc_number);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_rbatch, 11, v_remit_bank_acc_id);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_rbatch, 12, v_remit_branch_city);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_rbatch, 13, v_remit_branch_state);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_rbatch, 14, v_remit_branch_country);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_rbatch, 15, v_remit_branch_postal_code);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_rbatch, 16, v_remit_branch_address1);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_rbatch, 17, v_remit_branch_address2);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_rbatch, 18, v_remit_branch_address3);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_rbatch, 19, v_remit_bank_acc_check_digits);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_rbatch, 20, v_remit_bank_acc_curr);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_rbatch, 21, v_risk_elimination_days);


          END IF;

          IF DBMS_SQL.IS_OPEN (v_CursorID_rbatch) THEN
            DBMS_SQL.CLOSE_CURSOR(v_CursorID_rbatch);
          END IF;

         -- Remitance Batch Name Restriction
         IF p_remittance_batch_name IS NOT NULL THEN
           IF p_remittance_batch_name <> v_remittance_batch_name
             OR v_remittance_batch_name IS NULL THEN
             l_populate := 'N';
           END IF;
         END IF;

         -- Remittance Bank Acc Restriction
         IF p_remittance_bank_account IS NOT NULL THEN
           IF p_remittance_bank_account <> v_remit_bank_acc_name
             OR v_remit_bank_acc_name IS NULL THEN
             l_populate := 'N';
           END IF;
         END IF;

      EXCEPTION
        WHEN OTHERS THEN
          -- Close both cursors, then raise the error again.
          DBMS_SQL.CLOSE_CURSOR(v_CursorID_rbatch);
          DBMS_SQL.CLOSE_CURSOR(v_CursorID_main);
          RAISE;

      END;

      IF l_populate = 'Y' THEN

      /*------------------------------------------------------------------+
       |            Determine the statuses from the as of date            |
       +------------------------------------------------------------------*/

        BEGIN

          -- Initialize parameters
          v_status := null;
          v_status_date := null;
          v_status_gl_date := null;

          -- Open the As of Date cursor for dynamic processing.
          v_CursorID_date := DBMS_SQL.OPEN_CURSOR;

          -- Parse the As of Date Cursor
          DBMS_SQL.PARSE(v_CursorID_date, l_as_of_date, DBMS_SQL.native);

          -- Bind variables for cursor
          DBMS_SQL.BIND_VARIABLE(v_CursorID_date, ':b_status_date', p_status_as_of_date);
          DBMS_SQL.BIND_VARIABLE(v_CursorID_date, ':b_trx_id', v_customer_trx_id);
          -- If the MO Reporting Get Predicate function returns a bind variable then
          -- we need to bind it.
          IF l_org_where_trx like '%:p_reporting_entity_id%' THEN
            DBMS_SQL.BIND_VARIABLE(v_CursorID_date, ':p_reporting_entity_id', p_reporting_entity_id);
          END IF;

          -- Define the output variables.
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_date, 1,  v_status, 30);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_date, 2,  v_status_date);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_date, 3,  v_status_gl_date);
          DBMS_SQL.DEFINE_COLUMN(v_CursorID_date, 4,  v_status_code, 30);

          -- Execute the statement.
          v_Dummy_date := DBMS_SQL.EXECUTE(v_CursorID_date);

          IF DBMS_SQL.FETCH_ROWS(v_CursorID_date) > 0 THEN
            DBMS_SQL.COLUMN_VALUE(v_CursorID_date, 1, v_status);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_date, 2, v_status_date);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_date, 3, v_status_gl_date);
            DBMS_SQL.COLUMN_VALUE(v_CursorID_date, 4, v_status_code);
          END IF;

          IF DBMS_SQL.IS_OPEN (v_CursorID_date) THEN
            DBMS_SQL.CLOSE_CURSOR(v_CursorID_date);
          END IF;

        EXCEPTION
          WHEN OTHERS THEN
            -- Close both cursors, then raise the error again.
            DBMS_SQL.CLOSE_CURSOR(v_CursorID_date);
            DBMS_SQL.CLOSE_CURSOR(v_CursorID_main);
            RAISE;

        END;

        -- If the record does not have a valid status for the data we do not want
        -- to do any further processing of the record.
        IF v_status IS NOT NULL THEN

       /*------------------------------------------------------------------+
        |                        Assigned Amounts                          |
        +------------------------------------------------------------------*/

          BEGIN

            -- Initialize variables
            v_assigned_entered_amount := 0;
            v_assigned_functional_amount := 0;

            -- Open the Assigned Amounts cursor for dynamic processing.
            v_CursorID_asg := DBMS_SQL.OPEN_CURSOR;

            -- Parse the Assigned Amounts Cursor
            DBMS_SQL.PARSE(v_CursorID_asg, l_assigned_amount, DBMS_SQL.native);

            -- Bind variables for cursor
            DBMS_SQL.BIND_VARIABLE(v_CursorID_asg, ':b_trx_id', v_customer_trx_id);
            -- If the MO Reporting Get Predicate function returns a bind variable then
            -- we need to bind it.

            IF l_org_where_trx like '%:p_reporting_entity_id%' THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID_asg, ':p_reporting_entity_id', p_reporting_entity_id);
            END IF;

            -- Define the output variables.
            DBMS_SQL.DEFINE_COLUMN(v_CursorID_asg, 1,  v_assigned_entered_amount);
            DBMS_SQL.DEFINE_COLUMN(v_CursorID_asg, 2,  v_assigned_functional_amount);

            -- Execute the statement.
            v_Dummy_asg := DBMS_SQL.EXECUTE(v_CursorID_asg);

            IF DBMS_SQL.FETCH_ROWS(v_CursorID_asg) > 0 THEN
              DBMS_SQL.COLUMN_VALUE(v_CursorID_asg, 1,  v_assigned_entered_amount);
              DBMS_SQL.COLUMN_VALUE(v_CursorID_asg, 2,  v_assigned_functional_amount);
            END IF;

            IF DBMS_SQL.IS_OPEN (v_CursorID_asg) THEN
              DBMS_SQL.CLOSE_CURSOR(v_CursorID_asg);
            END IF;

          EXCEPTION
            WHEN OTHERS THEN
              -- Close both cursors, then raise the error again.
              DBMS_SQL.CLOSE_CURSOR(v_CursorID_asg);
              DBMS_SQL.CLOSE_CURSOR(v_CursorID_main);
            RAISE;

          END;

         /*------------------------------------------------------------------+
          |         Calculate the Open Amounts from the as of date           |
          +------------------------------------------------------------------*/

          BEGIN

            -- Initialize variables
            v_amount_applied := null;
            v_functional_amount_applied := null;

            -- Open the Open Amt cursor for dynamic processing.
            v_CursorID_amt := DBMS_SQL.OPEN_CURSOR;

            -- Parse the Open Amt Cursor
            DBMS_SQL.PARSE(v_CursorID_amt, l_open_amount, DBMS_SQL.native);

            -- Bind variables for cursor
            DBMS_SQL.BIND_VARIABLE(v_CursorID_amt, ':b_status_as_of_date', p_status_as_of_date);
            DBMS_SQL.BIND_VARIABLE(v_CursorID_amt, ':b_trx_id', v_customer_trx_id);
            -- If the MO Reporting Get Predicate function returns a bind variable then
            -- we need to bind it.
            IF l_org_where_trx like '%:p_reporting_entity_id%' THEN
              DBMS_SQL.BIND_VARIABLE(v_CursorID_amt, ':p_reporting_entity_id', p_reporting_entity_id);
            END IF;

            -- Define the output variables.
            DBMS_SQL.DEFINE_COLUMN(v_CursorID_amt, 1,  v_amount_applied);

            -- Execute the statement.
            v_Dummy_amt := DBMS_SQL.EXECUTE(v_CursorID_amt);

            IF DBMS_SQL.FETCH_ROWS(v_CursorID_amt) > 0 THEN
              DBMS_SQL.COLUMN_VALUE(v_CursorID_amt, 1,  v_amount_applied);
            END IF;

            IF DBMS_SQL.IS_OPEN (v_CursorID_amt) THEN
              DBMS_SQL.CLOSE_CURSOR(v_CursorID_amt);
            END IF;

            IF v_amount_applied IS NOT NULL THEN
              v_open_entered_amount := v_amount_applied + v_open_entered_amount;

              -- Ensure we calculate Functional Acctd Amount correctly
              --Bug 5041260 replaced the call  arp_util.calc_acctd_amount with
             --  arp_util.calc_accounted_amount.

              arp_util.calc_accounted_amount(l_currency_code,
                                         NULL,
                                         NULL,
                                         v_ps_exchange_rate,
                                         '-',
                                         v_open_entered_amount,
                                         v_open_functional_amount,
                                         v_amount_applied,
                                         l_new_ADR,
                                         l_new_acctd_ADR,
                                         v_functional_amount_applied);

              v_open_functional_amount := v_functional_amount_applied  + v_open_functional_amount;

            END IF;

          EXCEPTION
            WHEN OTHERS THEN
              -- Close both cursors, then raise the error again.
              DBMS_SQL.CLOSE_CURSOR(v_CursorID_amt);
              DBMS_SQL.CLOSE_CURSOR(v_CursorID_main);
              RAISE;

          END;

         /*------------------------------------------------------------------+
          |                  Unpaid Receipt Reversal Reason                  |
          +------------------------------------------------------------------*/

          IF v_status_code = 'UNPAID' THEN

            BEGIN

              -- Initialize variables
              v_unpaid_receipt_rev_reason := null;

              -- Open the Unpaide Receipt Reversal Reason cursor for dynamic processing.
              v_CursorID_rev := DBMS_SQL.OPEN_CURSOR;

              -- Parse the Open Amt Cursor
              DBMS_SQL.PARSE(v_CursorID_rev, l_receipt_reversal, DBMS_SQL.native);

              -- Bind variables for cursor
              DBMS_SQL.BIND_VARIABLE(v_CursorID_rev, ':b_trx_id', v_customer_trx_id);
              -- If the MO Reporting Get Predicate function returns a bind variable then
              -- we need to bind it.
              IF l_org_where_trx like '%:p_reporting_entity_id%' THEN
                DBMS_SQL.BIND_VARIABLE(v_CursorID_rev, ':p_reporting_entity_id', p_reporting_entity_id);
              END IF;

              -- Define the output variables.
              DBMS_SQL.DEFINE_COLUMN(v_CursorID_rev, 1,  v_unpaid_receipt_rev_reason, 80);

              -- Execute the statement.
              v_Dummy_amt := DBMS_SQL.EXECUTE(v_CursorID_rev);

              IF DBMS_SQL.FETCH_ROWS(v_CursorID_rev) > 0 THEN
                DBMS_SQL.COLUMN_VALUE(v_CursorID_rev, 1,  v_unpaid_receipt_rev_reason);
              END IF;

              IF DBMS_SQL.IS_OPEN (v_CursorID_rev) THEN
                DBMS_SQL.CLOSE_CURSOR(v_CursorID_rev);
              END IF;

            EXCEPTION
              WHEN OTHERS THEN
                -- Close both cursors, then raise the error again.
                DBMS_SQL.CLOSE_CURSOR(v_CursorID_rev);
                DBMS_SQL.CLOSE_CURSOR(v_CursorID_main);
                RAISE;

            END;

          END IF;

         /*------------------------------------------------------------------+
          |                        Populate Dates                            |
          +------------------------------------------------------------------*/

          SELECT MIN(trx_date)
          INTO   l_creation_gl_date
          FROM   ar_transaction_history_all
          WHERE  event = 'COMPLETED'
          AND    customer_trx_id = v_customer_trx_id;

          SELECT MIN(maturity_date)
          INTO   l_original_maturity_date
          FROM   ar_transaction_history_all
          WHERE  customer_trx_id = v_customer_trx_id
          AND    status IN ('PENDING_REMITTANCE', 'PENDING_ACCEPTANCE')
          AND    event = 'COMPLETED';

          SELECT MAX(trx_date)
          INTO   l_unpaid_date
          FROM   ar_transaction_history_all
          WHERE  status = 'UNPAID'
          AND    customer_trx_id = v_customer_trx_id;

          SELECT MAX(trx_date)
          INTO   l_acceptance_date
          FROM   ar_transaction_history_all
          WHERE  event = 'ACCEPTED'
          AND    customer_trx_id = v_customer_trx_id;

          SELECT MAX(trx_date)
          INTO   l_remit_date
          FROM   ar_transaction_history_all
          WHERE  batch_id IS NOT NULL
          AND    customer_trx_id = v_customer_trx_id;


         /*------------------------------------------------------------------+
          |                Insert Data into Interface Table                  |
          +------------------------------------------------------------------*/

          INSERT INTO ar_br_status_rep_itf
            (creation_date
            ,created_by
            ,last_update_login
            ,last_update_date
            ,last_updated_by
            ,request_id
            ,status
            ,status_date
            ,transaction_number
            ,document_number
            ,document_sequence_name
            ,currency
            ,magnetic_format_code
            ,entered_amount
            ,functional_amount
            ,balance_due
            ,functional_balance_due
            ,drawee_name
            ,drawee_number
            ,jgzz_fiscal_code
            ,drawee_vat_reg_number
            ,drawee_city
            ,drawee_state
            ,drawee_country
            ,drawee_postal_code
            ,drawee_class
            ,drawee_category
            ,drawee_location
            ,issue_date
            ,creation_gl_date
            ,status_gl_date
            ,maturity_date
            ,original_maturity_date
            ,issued_by_drawee
            ,signed_by_drawee
            ,transaction_type
            ,transaction_batch_source
            ,remit_bank_name
            ,remit_bank_number
            ,remit_branch_name
            ,remit_branch_number
            ,remit_bank_acc_name
            ,remit_bank_acc_number
            ,remit_branch_city
            ,remit_branch_state
            ,remit_branch_country
            ,remit_branch_postal_code
            ,remit_branch_address1
            ,remit_branch_address2
            ,remit_branch_address3
            ,remit_bank_allow_override
            ,remit_bank_acc_check_digits
            ,remit_bank_acc_curr
            ,drawee_bank_name
            ,drawee_bank_number
            ,drawee_branch_name
            ,drawee_branch_number
            ,drawee_bank_acc_name
            ,drawee_bank_acc_number
            ,drawee_branch_city
            ,drawee_branch_state
            ,drawee_branch_country
            ,drawee_branch_postal_code
            ,drawee_branch_address1
            ,drawee_branch_address2
            ,drawee_branch_address3
            ,drawee_bank_acc_check_digits
            ,drawee_bank_acc_curr
            ,unpaid_date
            ,acceptance_date
            ,comments
            ,days_late
            ,last_printed_date
            ,remittance_date
            ,drawee_address1
            ,drawee_address2
            ,drawee_address3
            ,drawee_contact
            ,special_instructions
            ,remittance_batch_name
            ,remittance_method
            ,with_recourse
            ,remittance_payment_method
            ,risk_elimination_days
            ,creation_batch_name
            ,assigned_entered_amount
            ,assigned_functional_amount
            ,unpaid_receipt_reversal_reason
            ,functional_currency_code
            ,organization_name
            )
          VALUES
            (sysdate
            ,p_user_id
            ,l_login_id
            ,sysdate
            ,p_user_id
            ,p_request_id
            ,v_status
            ,v_status_date
            ,v_transaction_number
            ,v_document_number
            ,v_document_sequence_name
            ,v_currency_code
            ,v_magnetic_format_code
            ,v_original_entered_amount
            ,l_new_original_funct_amt
            ,v_open_entered_amount
            ,v_open_functional_amount
            ,v_drawee_name
            ,v_drawee_number
            ,v_drawee_taxpayer_id
            ,v_drawee_vat_reg_number
            ,v_drawee_city
            ,v_drawee_state
            ,v_drawee_country
            ,v_drawee_postal_code
            ,v_drawee_class
            ,v_drawee_category
            ,v_drawee_location
            ,v_issue_date
            ,l_creation_gl_date
            ,v_status_gl_date
            ,v_maturity_date
            ,l_original_maturity_date
            ,v_issued_by_drawee
            ,v_signed_by_drawee
            ,v_transaction_type
            ,v_transaction_batch_source
            ,v_remit_bank_name
            ,v_remit_bank_number
            ,v_remit_branch_name
            ,v_remit_branch_number
            ,v_remit_bank_acc_name
            ,v_remit_bank_acc_number
            ,v_remit_branch_city
            ,v_remit_branch_state
            ,v_remit_branch_country
            ,v_remit_branch_postal_code
            ,v_remit_branch_address1
            ,v_remit_branch_address2
            ,v_remit_branch_address3
            ,v_remit_bank_allow_override
            ,v_remit_bank_acc_check_digits
            ,v_remit_bank_acc_curr
            ,v_drawee_bank_name
            ,v_drawee_bank_number
            ,v_drawee_branch_name
            ,v_drawee_branch_number
            ,v_drawee_bank_acc_name
            ,v_drawee_bank_acc_number
            ,v_drawee_branch_city
            ,v_drawee_branch_state
            ,v_drawee_branch_country
            ,v_drawee_branch_postal_code
            ,v_drawee_branch_address1
            ,v_drawee_branch_address2
            ,v_drawee_branch_address3
            ,v_drawee_bank_acc_check_digits
            ,v_drawee_bank_acc_curr
            ,l_unpaid_date
            ,l_acceptance_date
            ,v_comments
            ,v_days_late
            ,v_last_printed_date
            ,l_remit_date
            ,v_drawee_address1
            ,v_drawee_address2
            ,v_drawee_address3
            ,v_drawee_contact
            ,v_special_instructions
            ,v_remittance_batch_name
            ,v_remittance_method
            ,v_with_recourse
            ,v_remittance_payment_method
            ,v_risk_elimination_days
            ,v_creation_batch_name
            ,v_assigned_entered_amount
            ,v_assigned_functional_amount
            ,v_unpaid_receipt_rev_reason
            ,l_currency_code
            ,l_sob_name
            );

        -- v_status
        END IF;

      -- l_populate
      END IF;

    -- l_populate_amt
    END IF;

  END LOOP;

  -- Close the cursor.
  DBMS_SQL.CLOSE_CURSOR(v_CursorID_main);

  -- Update status variables to successful completion
  retcode := 0;
  errbuf := '';

  -- Commit our work.
  COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      -- Close the cursor, then raise the error again.
      DBMS_SQL.CLOSE_CURSOR(v_CursorID_main);
      RAISE;
  END arrxbrs_report;

END arrx_brs;

/
