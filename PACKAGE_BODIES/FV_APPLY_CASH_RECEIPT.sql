--------------------------------------------------------
--  DDL for Package Body FV_APPLY_CASH_RECEIPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_APPLY_CASH_RECEIPT" AS
--$Header: FVXDCCRB.pls 120.18.12010000.3 2008/09/04 15:30:47 sasukuma ship $

  g_module_name VARCHAR2(100) := 'fv.plsql.fvxdccrb.fv_apply_cash_receipt.';
  g_org_id     NUMBER;
  g_sob_id     NUMBER;
--  g_debug      VARCHAR2(1);
  g_ErrorFound BOOLEAN := FALSE;

  g_DEBIT_MEMO NUMBER := 1;
  g_INVOICE    NUMBER := 2;


  ------------------------------------------------------------------------
  -- Output data structures
  ------------------------------------------------------------------------
  TYPE ErrorInfoRec IS RECORD
  (
    error_code NUMBER,
    error_desc VARCHAR2(1024)
  );

  TYPE ErrorInfoTbl IS TABLE OF ErrorInfoRec INDEX BY BINARY_INTEGER;

/*
  TYPE ErrorMessagesTblType IS TABLE OF VARCHAR2(2048) INDEX BY BINARY_INTEGER;
  g_ErrorMessages ErrorMessagesTblType;
  g_MaxErrorMessages NUMBER := 0;

  TYPE LogMessagesTblType IS TABLE OF VARCHAR2(2048) INDEX BY BINARY_INTEGER;
  g_LogMessages LogMessagesTblType;
  g_MaxLogMessages NUMBER := 0;
*/

  TYPE CashReceiptApplicationsRec IS RECORD
  (
    invoice_number          ra_customer_trx.trx_number%TYPE,
    line_number             ra_customer_trx_lines.line_number%TYPE,
    invoice_type            VARCHAR2(100),
    applied_amount          NUMBER,
    applied_currency        fnd_currencies_vl.name%TYPE,
    amt_applied_in_inv_curr NUMBER,
    invoice_amount_due      NUMBER,
    invoice_currency        fnd_currencies_vl.name%TYPE,
    exchange_rate           NUMBER,
    status                  VARCHAR2(1) DEFAULT 'A'
  );

  TYPE CashReceiptApplicationsTbl IS TABLE OF CashReceiptApplicationsRec INDEX BY BINARY_INTEGER;

  TYPE CashReceiptRec IS RECORD
  (
    receipt_number     fv_interim_cash_receipts.receipt_number%TYPE,
    customer_name      hz_parties.party_name%TYPE,
    receipt_amount     fv_interim_cash_receipts.amount%TYPE,
    applied_currency   fnd_currencies_vl.name%TYPE,
    actual_amount      NUMBER,
    actual_currency    fnd_currencies_vl.name%TYPE,
    total_applications NUMBER,
    total_errors       NUMBER
  );

  TYPE CashReceiptTbl IS TABLE OF CashReceiptRec INDEX BY BINARY_INTEGER;

  g_OutReceiptApplications CashReceiptApplicationsTbl;
  g_OutCashReceipts        CashReceiptRec;
  g_OutErrorInfo           ErrorInfoTbl;


  ------------------------------------------------------------------------
  -- Data Structures required for Calling API's
  ------------------------------------------------------------------------

  ------------------------------------------------------------------------
  -- Parameters Required for CreateCash API                             --
  ------------------------------------------------------------------------
  TYPE CreateCashRecType IS RECORD
  (
    usr_currency_code            fnd_currencies_vl.name%TYPE,
    currency_code                fnd_currencies_vl.name%TYPE,
    usr_exchange_rate_type       gl_daily_conversion_types.user_conversion_type%TYPE,
    exchange_rate_type           ar_cash_receipts.exchange_rate_type%TYPE,
    exchange_rate                ar_cash_receipts.exchange_rate%TYPE,
    exchange_rate_date           ar_cash_receipts.exchange_date%TYPE,
    amount                       ar_cash_receipts.amount%TYPE,
    factor_discount_amount       ar_cash_receipts.factor_discount_amount%TYPE,
    receipt_number               ar_cash_receipts.receipt_number%TYPE,
    receipt_date                 ar_cash_receipts.receipt_date%type,
    gl_date                      DATE,
    maturity_date                DATE,
    postmark_date                DATE,
    customer_id                  hz_parties.party_id%TYPE,
    customer_name                hz_parties.party_name%TYPE,
    customer_number              hz_cust_accounts.account_number%TYPE,
    customer_bank_account_id     ar_cash_receipts.customer_bank_account_id%TYPE,
    customer_bank_account_num    ce_bank_accounts.bank_account_num%TYPE,
    customer_bank_account_name   ce_bank_accounts.bank_account_name%TYPE,
    location                     hz_cust_site_uses.location%type,
    customer_site_use_id         hz_cust_site_uses.site_use_id%TYPE,
    customer_receipt_reference   ar_cash_receipts.customer_receipt_reference%TYPE,
    override_remit_account_flag  ar_cash_receipts.override_remit_account_flag%TYPE,
    remittance_bank_account_id   ar_cash_receipts.remit_bank_acct_use_id%TYPE,
    remittance_bank_account_num  ce_bank_accounts.bank_account_num%TYPE,
    remittance_bank_account_name ce_bank_accounts.bank_account_name%TYPE,
    deposit_date                 ar_cash_receipts.deposit_date%TYPE,
    receipt_method_id            ar_cash_receipts.receipt_method_id%TYPE,
    receipt_method_name          ar_receipt_methods.name%TYPE,
    doc_sequence_value           NUMBER,
--    ussgl_transaction_code       ar_cash_receipts.ussgl_transaction_code%TYPE,
    anticipated_clearing_date    ar_cash_receipts.anticipated_clearing_date%TYPE,
    called_from                  VARCHAR2(100),
    attribute_rec                ar_receipt_api_pub.attribute_rec_type,
    global_attribute_rec         ar_receipt_api_pub.global_attribute_rec_type,
    comments                     ar_receivable_applications.comments%TYPE,
    issuer_name                  ar_cash_receipts.issuer_name%TYPE,
    issue_date                   ar_cash_receipts.issue_date%TYPE,
    issuer_bank_branch_id        ar_cash_receipts.issuer_bank_branch_id%TYPE,
    org_id                       ar_Cash_receipts.org_id%TYPE
  );

  ------------------------------------------------------------------------
  -- Parameters Required for ApplyCash API                             --
  ------------------------------------------------------------------------
  TYPE ApplyCashRecType IS RECORD
  (
    cash_receipt_id              ar_cash_receipts.cash_receipt_id%TYPE,
    receipt_number               ar_cash_receipts.receipt_number%TYPE,
    customer_trx_id              ra_customer_trx.customer_trx_id%TYPE,
    trx_number                   ra_customer_trx.trx_number%TYPE,
    installment                  ar_payment_schedules.terms_sequence_number%TYPE,
    applied_payment_schedule_id  ar_payment_schedules.payment_schedule_id%TYPE,
    amount_applied               ar_receivable_applications.amount_applied%TYPE,
    amount_applied_from          ar_receivable_applications.amount_applied_from%TYPE,
    trans_to_receipt_rate        ar_receivable_applications.trans_to_receipt_rate%TYPE,
    discount                     ar_receivable_applications.earned_discount_taken%TYPE,
    apply_date                   ar_receivable_applications.apply_date%TYPE,
    apply_gl_date                ar_receivable_applications.gl_date%TYPE,
--    ussgl_transaction_code       ar_receivable_applications.ussgl_transaction_code%TYPE,
    org_id                       ar_receivable_applications.org_id%TYPE,
    customer_trx_line_id         ar_receivable_applications.applied_customer_trx_line_id%TYPE,
    line_number                  ra_customer_trx_lines.line_number%TYPE,
    show_closed_invoices         VARCHAR2(100),
    called_from                  VARCHAR2(100),
    move_deferred_tax            VARCHAR2(100),
    link_to_trx_hist_id          ar_receivable_applications.link_to_trx_hist_id%TYPE,
    attribute_rec                ar_receipt_api_pub.attribute_rec_type,
    global_attribute_rec         ar_receipt_api_pub.global_attribute_rec_type,
    comments                     ar_receivable_applications.comments%TYPE,
    payment_set_id               ar_receivable_applications.payment_set_id%TYPE,
    application_ref_type         ar_receivable_applications.application_ref_type%TYPE,
    application_ref_id           ar_receivable_applications.application_ref_id%TYPE,
    application_ref_num          ar_receivable_applications.application_ref_num%TYPE,
    secondary_application_ref_id ar_receivable_applications.secondary_application_ref_id%TYPE,
    application_ref_reason       ar_receivable_applications.application_ref_reason%TYPE,
    customer_reference           ar_receivable_applications.customer_reference%TYPE
  );

  ------------------------------------------------------------------------
  -- Parameters Required for OnAccount API                              --
  ------------------------------------------------------------------------
  TYPE OnAccountRecType IS RECORD
  (
    cash_receipt_id         ar_cash_receipts.cash_receipt_id%TYPE,
    receipt_number          ar_cash_receipts.receipt_number%TYPE,
    amount_applied          ar_receivable_applications.amount_applied%TYPE,
    apply_date              ar_receivable_applications.apply_date%TYPE,
    apply_gl_date           ar_receivable_applications.gl_date%TYPE,
--    ussgl_transaction_code  ar_receivable_applications.ussgl_transaction_code%TYPE,
    attribute_rec           ar_receipt_api_pub.attribute_rec_type,
    global_attribute_rec    ar_receipt_api_pub.global_attribute_rec_type,
    comments                ar_receivable_applications.comments%TYPE
  );

  ------------------------------------------------------------------------
  -- Data Structure Required for Debug.                                 --
  ------------------------------------------------------------------------
  TYPE DebugRecType IS RECORD
  (
    pkg_name    VARCHAR2(100),
    module_name VARCHAR2(100),
    intend_str  VARCHAR2(1024),
    error_code  NUMBER,
    error_desc  VARCHAR2(1024),
    error_loc   VARCHAR2(1024)
  );

  TYPE DebugTblType IS TABLE OF DebugRecType INDEX BY BINARY_INTEGER;

  g_DebugTbl DebugTblType;

  TYPE DebugMessagesTblType IS TABLE OF VARCHAR2(2048) INDEX BY BINARY_INTEGER;
  g_DebugMessages DebugMessagesTblType;

  g_MaxDebugProcs    NUMBER := 0;
  g_CurDebugProcs    NUMBER := 0;
  g_MaxDebugMessages NUMBER := 0;

  ------------------------------------------------------------------------
  -- Procedure Return Values                                            --
  ------------------------------------------------------------------------
  g_SUCCESS  NUMBER := 0;
  g_WARNING  NUMBER := 1;
  g_FAILURE  NUMBER := 2;

  --****************************************************************************************--
  --*          Name : log                                                                  *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This procedure writes log messages                                   *--
  --*    Parameters : p_pgm  The Program Name                                              *--
  --*               : p_loc  The location                                                  *--
  --*               : p_msg  The message that has to be written to the log file            *--
  --*   Global Vars : None                                                                     *--
  --*   Called from : None                                                                     *--
  --*         Calls : fnd_file.put_line                                                    *--
  --*   Tables Used : None                                                                 *--
  --*         Logic : Call fnd_file.put_line with the message as a parameter               *--
  --****************************************************************************************--
  PROCEDURE log_msg
  (
    p_ModuleName IN VARCHAR2,
    p_msg IN VARCHAR2
  ) IS
    l_module_name VARCHAR2(200) := g_module_name || 'log_msg';
    l_errbuf      VARCHAR2(1024);
  BEGIN
/*
    g_MaxLogMessages := g_MaxLogMessages + 1;
    g_LogMessages (g_MaxLogMessages) := p_msg;
*/
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, g_module_name||p_ModuleName,p_msg);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      l_errbuf := SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);

  END log_msg;

/*
  PROCEDURE log_write
  IS
  BEGIN
    fnd_file.put_line (fnd_file.log, '*********************Log Messages**********************');
    FOR l_Counter IN 1..g_MaxLogMessages LOOP
      fnd_file.put_line(fnd_file.log, g_LogMessages(l_Counter));
    END LOOP;
    fnd_file.put_line (fnd_file.log, '*******************************************************');
    fnd_file.put_line (fnd_file.log, ' ');
  END;
*/

  --****************************************************************************************--
  --*          Name : output                                                               *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This procedure writes log messages                                   *--
  --*    Parameters : p_msg  The message that has to be written to the output file         *--
  --*   Global Vars : None                                                                 *--
  --*   Called from : write_report_header                                                  *--
  --*               : write_report_for_a_receipt                                           *--
  --*         Calls : fnd_file.put_line                                                    *--
  --*   Tables Used : None                                                                 *--
  --*         Logic : Call fnd_file.put_line with the message as a parameter               *--
  --****************************************************************************************--
  PROCEDURE output
  (
    p_msg IN VARCHAR2
  ) IS
  BEGIN
    fnd_file.put_line(fnd_file.output, p_msg);
  END output;

  --****************************************************************************************--
  --*          Name : error                                                                *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This procedure writes error messages                                 *--
  --*    Parameters : p_error_type The Type of Error (ERROR or just WARNING)               *--
  --*               : p_pgm        The program Name                                        *--
  --*               : p_msg        The message that has to be written to the log file      *--
  --*               : p_loc        The location of error                                   *--
  --*   Global Vars : g_SUCCESS                                                            *--
  --*   Called from : To be filled in                                                      *--
  --*         Calls : fnd_file.put_line                                                    *--
  --*   Tables Used : None                                                                 *--
  --*         Logic : Call fnd_file.put_line with the message as a parameter               *--
  --****************************************************************************************--
  PROCEDURE error
  (
    p_error_type IN NUMBER, --ERROR or WARNING
    p_pgm        IN VARCHAR2,
    p_msg        IN VARCHAR2,
    p_loc        IN VARCHAR2
  ) IS
    l_Prefix VARCHAR2(100) := '';
    l_module_name VARCHAR2(200) := g_module_name || 'error';
    l_errbuf      VARCHAR2(1024);
  BEGIN
/*
    IF (p_error_type = g_FAILURE) THEN
      l_Prefix := 'ERROR: ';
    ELSIF (p_error_type = g_WARNING) THEN
      l_Prefix := 'WARNING: ';
    ELSE
      l_Prefix := NULL;
    END IF;
    g_MaxErrorMessages := g_MaxErrorMessages + 1;
    g_ErrorMessages (g_MaxErrorMessages) := l_Prefix||p_msg ||'['||p_pgm||':'||p_loc||']';
*/
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, g_module_name||p_pgm||'.'||p_loc,p_msg);
  EXCEPTION
    WHEN OTHERS THEN
      l_errbuf := SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);

  END error;

/*
  PROCEDURE error_write
  IS
  BEGIN
    fnd_file.put_line (fnd_file.log, '*****************Error Messages************************');
    FOR l_Counter IN 1..g_MaxErrorMessages LOOP
      fnd_file.put_line(fnd_file.log, g_ErrorMessages(l_Counter));
    END LOOP;
    fnd_file.put_line (fnd_file.log, '*******************************************************');
    fnd_file.put_line (fnd_file.log, ' ');
  END;
*/
  --****************************************************************************************--
  --*          Name : debug_msg                                                            *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : Used to display debug messages                                       *--
  --*    Parameters : p_msg                 IN The message that has to be written          *--
  --*   Called from : debug_init                                                           *--
  --*               : debug_exit                                                           *--
  --*               : write_report_for_a_receipt                                           *--
  --*               : dump_ar_batch                                                        *--
  --*               : apply_on_account                                                     *--
  --*               : apply_cash_receipt                                                   *--
  --*               : update_cash_receipt_hist                                             *--
  --*               : update_fv_batch_status                                               *--
  --*               : create_cash_receipt                                                  *--
  --*               : pay_the_invoice                                                      *--
  --*               : get_receipt_txn_code                                                 *--
  --*               : pay_debit_memos                                                      *--
  --*               : process_receipts                                                     *--
  --*               : main                                                                 *--
  --*         Calls : fnd_file.put_line                                                    *--
  --*   Tables Used : None                                                                 *--
  --*   Global Vars : g_debug          READ                                                *--
  --*               : FND_FILE.LOG     READ                                                *--
  --*               : g_DebugTbl       READ                                                *--
  --*               : g_CurDebugProcs  READ                                                *--
  --*         Logic : Call fnd_file.put_line with the message as a parameter.              *--
  --*               : The message will be displayed only if the debug flag is on           *--
  --*               : The package name, module name and the intendation string are used    *--
  --*               : from the global variable called g_DebugTbl. The procedures           *--
  --*               : debug_init and debug_exit inserts and modifies this table            *--
  --****************************************************************************************--
  PROCEDURE debug_msg
  (
    p_ModuleName IN VARCHAR2,
    p_Message    IN VARCHAR2
  ) IS
    l_module_name VARCHAR2(200) := g_module_name || 'debug_msg';
    l_errbuf      VARCHAR2(1024);
  BEGIN
/*
    IF (g_debug = 'Y') THEN
      g_MaxDebugMessages := g_MaxDebugMessages + 1;
      g_DebugMessages (g_MaxDebugMessages) :=
                                     '  (debug) |--'||
                                      g_DebugTbl(g_CurDebugProcs).intend_str||
                                      ' ('||
                                      g_DebugTbl(g_CurDebugProcs).pkg_name||
                                      '.'||
                                      g_DebugTbl(g_CurDebugProcs).module_name||
                                      ') : ' ||
                                      p_Message;
    END IF;
*/
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, g_module_name||p_ModuleName,p_Message);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      l_errbuf := SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);

  END;

/*
  PROCEDURE debug_write
  IS
  BEGIN
    IF (g_debug = 'Y') THEN
      fnd_file.put_line (fnd_file.log, '*****************Debug Messages************************');
      FOR l_Counter IN 1..g_MaxDebugMessages LOOP
        fnd_file.put_line(fnd_file.log, g_DebugMessages(l_Counter));
      END LOOP;
      fnd_file.put_line (fnd_file.log, '*******************************************************');
      fnd_file.put_line (fnd_file.log, ' ');
    END IF;
  END;
*/

  PROCEDURE debug_init
  (
    p_PkgName    IN VARCHAR2,
    p_ModuleName IN VARCHAR2
  ) IS
    l_module_name VARCHAR2(200) := g_module_name || 'debug_init';
    l_errbuf      VARCHAR2(1024);
  BEGIN
/*
    g_MaxDebugProcs := g_MaxDebugProcs + 1;
    g_CurDebugProcs := g_CurDebugProcs + 1;
    g_DebugTbl(0).pkg_name := NULL;
    g_DebugTbl(0).module_name := NULL;
    g_DebugTbl(0).intend_str := NULL;

    g_DebugTbl(g_CurDebugProcs).pkg_name    := p_PkgName;
    g_DebugTbl(g_CurDebugProcs).module_name := p_ModuleName;
    g_DebugTbl(g_CurDebugProcs).intend_str := g_DebugTbl(g_CurDebugProcs-1).intend_str || '--';
    debug_msg (l_module_name, 'Entering Program');
*/
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, p_ModuleName,'ENTERING');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      l_errbuf := SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);


  END;

  PROCEDURE debug_exit
  (
    p_ErrorCode  IN NUMBER,
    p_ErrorDesc  IN VARCHAR2,
    p_ErrorLoc   IN VARCHAR2
  ) IS
    l_module_name VARCHAR2(200) := 'debug_exit';
  BEGIN
    debug_msg (l_module_name, 'Returning from Program with Exit Code ='||p_ErrorCode);
    debug_msg (l_module_name, 'Returning from Program with Exit Desc ='||p_ErrorDesc);
    debug_msg (l_module_name, 'Returning from Program with Exit Loc  ='||p_ErrorLoc);
    debug_msg (l_module_name, 'Exiting Program');
/*
    g_DebugTbl(g_CurDebugProcs).error_code := p_ErrorCode;
    g_DebugTbl(g_CurDebugProcs).error_desc := p_ErrorDesc;
    g_DebugTbl(g_CurDebugProcs).error_loc  := p_ErrorLoc;

    g_CurDebugProcs := g_CurDebugProcs - 1;
*/
  END;

  --****************************************************************************************--
  --*          Name : init                                                                 *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This procedure initializes the required global variables             *--
  --*    Parameters : None                                                                 *--
  --*   Global Vars : g_org_id WRITE                                                       *--
  --*               : g_sob_id WRITE                                                       *--
  --*               : g_debug  WRITE                                                       *--
  --*   Called from : main                                                                 *--
  --*         Calls : fnd_profile.value                                                    *--
  --*   Tables Used : None                                                                 *--
  --*         Logic : Initialize Org Id SOB Id and Debug Flag.                             *--
  --****************************************************************************************--
  PROCEDURE init IS
    l_module_name VARCHAR2(200) := g_module_name || 'init';
    l_errbuf      VARCHAR2(1024);
    l_ledger_name VARCHAR2(30); --PSKI changes for BA and MOAC Uptake
  BEGIN
   -- g_org_id := to_number(fnd_profile.value('ORG_ID'));
   -- g_sob_id := to_number(fnd_profile.value('GL_SET_OF_BKS_ID'));
--    g_org_id := MO_GLOBAL.get_current_org_id;   -- PSKI Changes for BA and MOAC Uptake
--	MO_UTILS.get_ledger_info(g_org_id,g_sob_id,l_ledger_name);   -- PSKI Changes for BA and MOAC Uptake
--    g_debug  := NVL(UPPER(SUBSTR(FND_PROFILE.VALUE('FV_DEBUG_FLAG'), 1, 1)),'N');
  NULL;
  EXCEPTION
    WHEN OTHERS THEN
      l_errbuf := SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
  END;

  --****************************************************************************************--
  --*          Name : write_report_header                                                  *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This procedure Writes the Report Header information like batch name  *--
  --*               : date submitted etc.                                                  *--
  --*    Parameters : p_BatchName     IN  The name of the batch                            *--
  --*               : p_DateSubmitted IN  The Date batch was submitted                     *--
  --*               : p_ErrorCode     OUT The Error Code                                   *--
  --*               : p_ErrorDesc     OUT The Error Description                            *--
  --*               : p_ErrorLoc      OUT The Error Location                               *--
  --*   Global Vars : g_SUCCESS              READ                                          *--
  --*   Called from : process_receipts                                                     *--
  --*         Calls : debug_init                                                           *--
  --*               : debug_msg                                                            *--
  --*               : debug_exit                                                           *--
  --*               : output                                                               *--
  --*               : error                                                                *--
  --*   Tables Used : None                                                                 *--
  --*         Logic : Call output to write the Batch Name and the Date Submitted in the    *--
  --*               : required report format.                                              *--
  --****************************************************************************************--
  PROCEDURE write_report_header
  (
    p_BatchRec             IN  fv_ar_batches%ROWTYPE,
    p_ErrorCode            OUT NOCOPY VARCHAR2,
    p_ErrorDesc            OUT NOCOPY VARCHAR2,
    p_ErrorLoc             OUT NOCOPY VARCHAR2
  ) IS
    l_module_name           VARCHAR2(30) := 'write_report_header';
    l_WroteErrorHeader     BOOLEAN := FALSE;
  BEGIN
    p_ErrorCode  := g_SUCCESS;
    p_ErrorDesc  := NULL;
    p_ErrorLoc   := NULL;

    debug_init (g_PackageName, l_module_name);

    output ('        Batch Name: '||p_BatchRec.batch_name);
    output ('    Date Submitted: '||TO_CHAR(p_BatchRec.last_update_date, 'MM/DD/YYYY HH24:MI:SS'));
    output ('  Receipt Currency: '||p_BatchRec.currency_code);
    output ('     Exchange Rate: '||p_BatchRec.exchange_rate);
    output ('Exchange Rate Date: '||p_BatchRec.exchange_date);
    output ('Exchange Rate Type: '||p_BatchRec.exchange_rate_type);
    output (' ');
    output (RPAD('*', 100, '*'));
    output (' ');

    debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  EXCEPTION
    WHEN OTHERS THEN
      p_ErrorCode := g_FAILURE;
      p_ErrorDesc := SQLERRM;
      p_ErrorLoc  := 'Final Exception';
      error
      (
        p_error_type => p_ErrorCode,
        p_pgm        => l_module_name,
        p_msg        => p_ErrorDesc,
        p_loc        => p_ErrorLoc
      );
      debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  END;

  PROCEDURE del_report_line_for_a_receipt
  (
    p_InvoiceNumber        IN  VARCHAR2,
    p_ErrorCode            OUT NOCOPY  VARCHAR2,
    p_ErrorDesc            OUT  NOCOPY VARCHAR2,
    p_ErrorLoc             OUT NOCOPY  VARCHAR2
  ) IS
    l_module_name           VARCHAR2(30) := 'del_report_line_for_a_receipt';
    l_Counter              NUMBER;
  BEGIN
    p_ErrorCode  := g_SUCCESS;
    p_ErrorDesc  := NULL;
    p_ErrorLoc   := NULL;

    debug_init (g_PackageName, l_module_name);
    FOR l_Counter IN 1..g_OutCashReceipts.total_applications LOOP
      IF (g_OutReceiptApplications(l_Counter).invoice_number = p_InvoiceNumber) THEN
        g_OutReceiptApplications(l_Counter).status := 'D';
      END IF;
    END LOOP;
    debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  EXCEPTION
    WHEN OTHERS THEN
      p_ErrorCode := g_FAILURE;
      p_ErrorDesc := SQLERRM;
      p_ErrorLoc  := 'Final Exception';
      error
      (
        p_error_type => p_ErrorCode,
        p_pgm        => l_module_name,
        p_msg        => p_ErrorDesc,
        p_loc        => p_ErrorLoc
      );
      debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  END del_report_line_for_a_receipt;

  --****************************************************************************************--
  --*          Name : write_report_for_a_receipt                                           *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This procedure Writes the detailed Report for a particular receipt   *--
  --*    Parameters : p_ErrorCode     OUT The Error Code                                   *--
  --*               : p_ErrorDesc     OUT The Error Description                            *--
  --*               : p_ErrorLoc      OUT The Error Location                               *--
  --*   Global Vars : g_SUCCESS              READ                                          *--
  --*               : g_OutCashReceipts      READ                                          *--
  --*               : g_OutInvoiceDebitMemos READ                                          *--
  --*               : g_OutErrorInfo         READ                                          *--
  --*   Called from : process_receipts                                                     *--
  --*         Calls : debug_init                                                           *--
  --*               : debug_exit                                                           *--
  --*               : output                                                               *--
  --*   Tables Used : None                                                                 *--
  --*         Logic : Write the Receipt Information from g_OutCashReceipts                 *--
  --*               : Write the Debit Memo and Invoice Applications from                   *--
  --*               :                 g_OutInvoiceDebitMemos                               *--
  --*               : Write the Error Information from g_OutErrorInfo                      *--
  --****************************************************************************************--
  PROCEDURE write_report_for_a_receipt
  (
    p_ErrorCode            OUT NOCOPY  VARCHAR2,
    p_ErrorDesc            OUT NOCOPY  VARCHAR2,
    p_ErrorLoc             OUT NOCOPY  VARCHAR2
  ) IS
    l_module_name           VARCHAR2(30) := 'write_report_for_a_receipt';
    l_WroteErrorHeader     BOOLEAN := FALSE;
  BEGIN
    p_ErrorCode  := g_SUCCESS;
    p_ErrorDesc  := NULL;
    p_ErrorLoc   := NULL;

    debug_init (g_PackageName, l_module_name);

    ----------------------------------------------------------------------
    -- Write Receipt Details                                            --
    ----------------------------------------------------------------------
    output ('     Receipt Number: '||g_OutCashReceipts.receipt_number);
    output ('           Customer: '||g_OutCashReceipts.customer_name);
    output ('     Receipt Amount: '||g_OutCashReceipts.receipt_amount);
    output (' ');

    output ('     '||RPAD('=', 24, '='));
    output ('     Receipt Application');
    output (' ');
    output ('            -----------------------------------------------------------------------');
    output ('           |  Applied Against  | Line Number |  Invoice Type   |  Amount Applied  |');
    output ('            ----------------------------------------------------------------------');
    output ('           |                   |             |                 |                  |');
    ----------------------------------------------------------------------
    -- Write Receipt Application Details                                --
    ----------------------------------------------------------------------
    FOR l_Counter IN 1..g_OutCashReceipts.total_applications LOOP
      IF (NVL(g_OutReceiptApplications(l_Counter).status, 'A') = 'A') THEN
        output ('           |'||
                RPAD(SUBSTR(g_OutReceiptApplications(l_Counter).invoice_number, 1, 19), 19, ' ')||
                '|'||
                RPAD(SUBSTR(NVL(TO_CHAR(g_OutReceiptApplications(l_Counter).line_number), ' '), 1, 13), 13, ' ')||
                '|'||
                RPAD(SUBSTR(g_OutReceiptApplications(l_Counter).invoice_type, 1, 17), 17, ' ')||
                '|'||
                TO_CHAR(g_OutReceiptApplications(l_Counter).applied_amount, '99999999999990.00')||
                '|');
      END IF;
    END LOOP;

    output ('           |                   |             |                 |                  |');
    output ('            ----------------------------------------------------------------------');
    output (' ');
    output (' ');

    ----------------------------------------------------------------------
    -- Write Error Information                                          --
    ----------------------------------------------------------------------
    FOR l_Counter IN 1..g_OutCashReceipts.total_errors LOOP
      IF (l_WroteErrorHeader = FALSE) THEN
      output ('     '||RPAD('=', 24, '='));
      output ('     Error Messages');
      output (' ');
      l_WroteErrorHeader := TRUE;
      END IF;

      output ('            '||
              l_Counter ||
              '. ' ||
              g_OutErrorInfo(l_Counter).error_desc);
    END LOOP;
    output (' ');
    output (RPAD('*', 100, '*'));
    output (' ');

    debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  EXCEPTION
    WHEN OTHERS THEN
      p_ErrorCode := g_FAILURE;
      p_ErrorDesc := SQLERRM;
      p_ErrorLoc  := 'Final Exception';
      error
      (
        p_error_type => p_ErrorCode,
        p_pgm        => l_module_name,
        p_msg        => p_ErrorDesc,
        p_loc        => p_ErrorLoc
      );
      debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  END write_report_for_a_receipt;

  --****************************************************************************************--
  --*          Name : dump_ar_batch                                                        *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : Writes the data in the record for ar_batches using debug_msg         *--
  --*    Parameters : p_ARBatchRec   IN  ar_batches%ROWTYPE                                *--
  --*   Global Vars : None                                                                 *--
  --*   Called from : insert_ar_batch                                                      *--
  --*         Calls : debug_msg                                                            *--
  --*   Tables Used : None                                                                 *--
  --*         Logic : Call debug_msg and write the contents of p_ARBatchRec.               *--
  --****************************************************************************************--
  PROCEDURE dump_ar_batch
  (
    p_ARBatchRec           IN  ar_batches%ROWTYPE
  ) IS
    l_module_name VARCHAR2(30) := 'dump_ar_batch';
  BEGIN
    ----------------------------------------------------------------------
    -- For Debug purposes dump the contents of ar_batches record        --
    ----------------------------------------------------------------------
    debug_msg (l_module_name, '====> Contents of AR_BATCHES record <====');
    debug_msg (l_module_name, 'batch_id                   => '|| p_ARBatchRec.batch_id);
    debug_msg (l_module_name, 'last_updated_by            => '|| p_ARBatchRec.last_updated_by);
    debug_msg (l_module_name, 'last_update_date           => '|| TO_CHAR(p_ARBatchRec.last_update_date, 'MM/DD/YYYY HH24:MI:SS'));
    debug_msg (l_module_name, 'last_update_login          => '|| p_ARBatchRec.last_update_login);
    debug_msg (l_module_name, 'created_by                 => '|| p_ARBatchRec.created_by);
    debug_msg (l_module_name, 'creation_date              => '|| TO_CHAR(p_ARBatchRec.creation_date, 'MM/DD/YYYY HH24:MI:SS'));
    debug_msg (l_module_name, 'name                       => '|| p_ARBatchRec.name);
    debug_msg (l_module_name, 'batch_date                 => '|| TO_CHAR(p_ARBatchRec.batch_date, 'MM/DD/YYYY HH24:MI:SS'));
    debug_msg (l_module_name, 'gl_date                    => '|| TO_CHAR(p_ARBatchRec.gl_date, 'MM/DD/YYYY HH24:MI:SS'));
    debug_msg (l_module_name, 'status                     => '|| p_ARBatchRec.status);
    debug_msg (l_module_name, 'deposit_date               => '|| TO_CHAR(p_ARBatchRec.deposit_date, 'MM/DD/YYYY HH24:MI:SS'));
    debug_msg (l_module_name, 'type                       => '|| p_ARBatchRec.type);
    debug_msg (l_module_name, 'batch_source_id            => '|| p_ARBatchRec.batch_source_id);
    debug_msg (l_module_name, 'control_count              => '|| p_ARBatchRec.control_count);
    debug_msg (l_module_name, 'control_amount             => '|| p_ARBatchRec.control_amount);
    debug_msg (l_module_name, 'batch_applied_status       => '|| p_ARBatchRec.batch_applied_status);
    debug_msg (l_module_name, 'currency_code              => '|| p_ARBatchRec.currency_code);
    debug_msg (l_module_name, 'exchange_rate              => '|| p_ARBatchRec.exchange_rate);
    debug_msg (l_module_name, 'exchange_date              => '|| TO_CHAR(p_ARBatchRec.exchange_date, 'MM/DD/YYYY HH24:MI:SS'));
    debug_msg (l_module_name, 'exchange_rate_type         => '|| p_ARBatchRec.exchange_rate_type);
    debug_msg (l_module_name, 'attribute_category         => '|| p_ARBatchRec.attribute_category);
    debug_msg (l_module_name, 'attribute1                 => '|| p_ARBatchRec.attribute1);
    debug_msg (l_module_name, 'attribute2                 => '|| p_ARBatchRec.attribute2);
    debug_msg (l_module_name, 'attribute3                 => '|| p_ARBatchRec.attribute3);
    debug_msg (l_module_name, 'attribute4                 => '|| p_ARBatchRec.attribute4);
    debug_msg (l_module_name, 'attribute5                 => '|| p_ARBatchRec.attribute5);
    debug_msg (l_module_name, 'attribute6                 => '|| p_ARBatchRec.attribute6);
    debug_msg (l_module_name, 'attribute7                 => '|| p_ARBatchRec.attribute7);
    debug_msg (l_module_name, 'attribute8                 => '|| p_ARBatchRec.attribute8);
    debug_msg (l_module_name, 'attribute9                 => '|| p_ARBatchRec.attribute9);
    debug_msg (l_module_name, 'attribute10                => '|| p_ARBatchRec.attribute10);
    debug_msg (l_module_name, 'attribute11                => '|| p_ARBatchRec.attribute11);
    debug_msg (l_module_name, 'attribute12                => '|| p_ARBatchRec.attribute12);
    debug_msg (l_module_name, 'attribute13                => '|| p_ARBatchRec.attribute13);
    debug_msg (l_module_name, 'attribute14                => '|| p_ARBatchRec.attribute14);
    debug_msg (l_module_name, 'attribute15                => '|| p_ARBatchRec.attribute15);
    debug_msg (l_module_name, 'receipt_method_id          => '|| p_ARBatchRec.receipt_method_id);
    debug_msg (l_module_name, 'remittance_bank_account_id => '|| p_ARBatchRec.remit_bank_acct_use_id); --PSKI changes for BA and MOAC Uptake
    debug_msg (l_module_name, 'receipt_class_id           => '|| p_ARBatchRec.receipt_class_id);
    debug_msg (l_module_name, 'set_of_books_id            => '|| p_ARBatchRec.set_of_books_id);
    debug_msg (l_module_name, 'org_id                     => '|| p_ARBatchRec.org_id);
  END dump_ar_batch;

  --****************************************************************************************--
  --*          Name : insert_ar_batch                                                      *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This procedure inserts a record into the table ar_batches            *--
  --*    Parameters : p_BatchRec      IN  fv_ar_batches%ROWTYPE                            *--
  --*               : p_ErrorCode     OUT The Error Code                                   *--
  --*               : p_ErrorDesc     OUT The Error Description                            *--
  --*               : p_ErrorLoc      OUT The Error Location                               *--
  --*   Global Vars : g_SUCCESS              READ                                          *--
  --*   Called from : process_receipts                                                     *--
  --*         Calls : debug_init                                                           *--
  --*               : debug_exit                                                           *--
  --*               : dump_ar_batch                                                        *--
  --*               : log_msg                                                              *--
  --*   Tables Used : ar_batches (VIEW) INSERT                                             *--
  --*         Logic : Copy the FV_AR_BATCHES record into AR_BATCHES record.                *--
  --*               : Call dump_ar_batch to display the AR_BATCHES record in debug mode    *--
  --*               : Insert the AR_BATCHES record into the table ar_batches               *--
  --****************************************************************************************--
  PROCEDURE insert_ar_batch
  (
    p_BatchRec             IN  fv_ar_batches%ROWTYPE,
    p_ErrorCode            OUT NOCOPY  VARCHAR2,
    p_ErrorDesc            OUT NOCOPY  VARCHAR2,
    p_ErrorLoc             OUT NOCOPY  VARCHAR2
  ) IS
    l_module_name           VARCHAR2(30) := 'insert_ar_batch';

    l_ARBatchRec           ar_batches%ROWTYPE;

  BEGIN
    p_ErrorCode  := g_SUCCESS;
    p_ErrorDesc  := NULL;
    p_ErrorLoc   := NULL;

    debug_init (g_PackageName, l_module_name);

    log_msg(l_module_name,'Creating Receipt Batch '||p_BatchRec.batch_name);


    ----------------------------------------------------------------------
    -- Copy the fv_ar_batches record into ar_batches record             --
    ----------------------------------------------------------------------

    l_ARBatchRec.batch_id                   := p_BatchRec.batch_id;
    l_ARBatchRec.last_updated_by            := p_BatchRec.last_updated_by;
    l_ARBatchRec.last_update_date           := p_BatchRec.last_update_date;
    l_ARBatchRec.last_update_login          := p_BatchRec.last_update_login;
    l_ARBatchRec.created_by                 := p_BatchRec.created_by;
    l_ARBatchRec.creation_date              := p_BatchRec.creation_date;
    l_ARBatchRec.name                       := p_BatchRec.batch_name;
    l_ARBatchRec.batch_date                 := trunc(SYSDATE); --for Bug 5299453
    l_ARBatchRec.gl_date                    := p_BatchRec.gl_date;
    l_ARBatchRec.status                     := 'CL';
    l_ARBatchRec.deposit_date               := p_BatchRec.deposit_date;
    l_ARBatchRec.type                       := 'MANUAL';
    l_ARBatchRec.batch_source_id            := p_BatchRec.batch_source_id;
    l_ARBatchRec.control_count              := p_BatchRec.batch_count;
    l_ARBatchRec.control_amount             := p_BatchRec.batch_amount;
    l_ARBatchRec.batch_applied_status       := 'PROCESSED';
    l_ARBatchRec.currency_code              := p_BatchRec.currency_code;
    l_ARBatchRec.exchange_rate              := p_BatchRec.exchange_rate;
    l_ARBatchRec.exchange_date              := p_BatchRec.exchange_date;
    l_ARBatchRec.exchange_rate_type         := p_BatchRec.exchange_rate_type;
    l_ARBatchRec.attribute_category         := p_BatchRec.attribute_category;
    l_ARBatchRec.attribute1                 := p_BatchRec.attribute1;
    l_ARBatchRec.attribute2                 := p_BatchRec.attribute2;
    l_ARBatchRec.attribute3                 := p_BatchRec.attribute3;
    l_ARBatchRec.attribute4                 := p_BatchRec.attribute4;
    l_ARBatchRec.attribute5                 := p_BatchRec.attribute5;
    l_ARBatchRec.attribute6                 := p_BatchRec.attribute6;
    l_ARBatchRec.attribute7                 := p_BatchRec.attribute7;
    l_ARBatchRec.attribute8                 := p_BatchRec.attribute8;
    l_ARBatchRec.attribute9                 := p_BatchRec.attribute9;
    l_ARBatchRec.attribute10                := p_BatchRec.attribute10;
    l_ARBatchRec.attribute11                := p_BatchRec.attribute11;
    l_ARBatchRec.attribute12                := p_BatchRec.attribute12;
    l_ARBatchRec.attribute13                := p_BatchRec.attribute13;
    l_ARBatchRec.attribute14                := p_BatchRec.attribute14;
    l_ARBatchRec.attribute15                := p_BatchRec.attribute15;
    l_ARBatchRec.receipt_method_id          := p_BatchRec.receipt_method_id;
    l_ARBatchRec.remit_bank_acct_use_id     := p_BatchRec.ce_bank_acct_use_id;   --PSKI changes for BA and MOAC Uptake
    l_ARBatchRec.receipt_class_id           := p_BatchRec.receipt_class_id;
    l_ARBatchRec.set_of_books_id            := p_BatchRec.set_of_books_id;
    l_ARBatchRec.org_id                     := p_BatchRec.org_id;

    ----------------------------------------------------------------------
    -- Call dump_ar_batch to display ar_batches record in debug mode    --
    ----------------------------------------------------------------------
    dump_ar_batch (l_ARBatchRec);

    ----------------------------------------------------------------------
    -- Insert the ar_batches record into ar_batches table               --
    ----------------------------------------------------------------------
    debug_msg (l_module_name, 'Inserting data into ar_batches');
    INSERT INTO ar_batches
    (
      batch_id,
      last_updated_by,
      last_update_date,
      last_update_login,
      created_by,
      creation_date,
      name,
      batch_date,
      gl_date,
      status,
      deposit_date,
      type,
      batch_source_id,
      control_count,
      control_amount,
      batch_applied_status,
      currency_code,
      exchange_rate,
      exchange_date,
      exchange_rate_type,
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
      receipt_method_id,
      remit_bank_acct_use_id,   --PSKI changes for BA and MOAC Uptake
      receipt_class_id,
      set_of_books_id,
      org_id
    )
    VALUES
    (
      l_ARBatchRec.batch_id,
      l_ARBatchRec.last_updated_by,
      l_ARBatchRec.last_update_date,
      l_ARBatchRec.last_update_login,
      l_ARBatchRec.created_by,
      l_ARBatchRec.creation_date,
      l_ARBatchRec.name,
      l_ARBatchRec.batch_date,
      l_ARBatchRec.gl_date,
      l_ARBatchRec.status,
      l_ARBatchRec.deposit_date,
      l_ARBatchRec.type,
      l_ARBatchRec.batch_source_id,
      l_ARBatchRec.control_count,
      l_ARBatchRec.control_amount,
      l_ARBatchRec.batch_applied_status,
      l_ARBatchRec.currency_code,
      l_ARBatchRec.exchange_rate,
      l_ARBatchRec.exchange_date,
      l_ARBatchRec.exchange_rate_type,
      l_ARBatchRec.attribute_category,
      l_ARBatchRec.attribute1,
      l_ARBatchRec.attribute2,
      l_ARBatchRec.attribute3,
      l_ARBatchRec.attribute4,
      l_ARBatchRec.attribute5,
      l_ARBatchRec.attribute6,
      l_ARBatchRec.attribute7,
      l_ARBatchRec.attribute8,
      l_ARBatchRec.attribute9,
      l_ARBatchRec.attribute10,
      l_ARBatchRec.attribute11,
      l_ARBatchRec.attribute12,
      l_ARBatchRec.attribute13,
      l_ARBatchRec.attribute14,
      l_ARBatchRec.attribute15,
      l_ARBatchRec.receipt_method_id,
      l_ARBatchRec.remit_bank_acct_use_id,   --PSKI changes for BA and MOAC Uptake
      l_ARBatchRec.receipt_class_id,
      l_ARBatchRec.set_of_books_id,
      l_ARBatchRec.org_id
    );

    log_msg(l_module_name,'Successfully created Receipt Batch '||p_BatchRec.batch_name);
    debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  EXCEPTION
    WHEN OTHERS THEN
      p_ErrorCode := g_FAILURE;
      p_ErrorDesc := SQLERRM;
      p_ErrorLoc  := 'Final Exception';
      error
      (
        p_error_type => p_ErrorCode,
        p_pgm        => l_module_name,
        p_msg        => p_ErrorDesc,
        p_loc        => p_ErrorLoc
      );
      debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  END insert_ar_batch;

  --****************************************************************************************--
  --*          Name : apply_on_account                                                     *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : Calls the API ar_receipt_api_pub.Apply_on_account to Apply the       *--
  --*               : receipt amount to On Account for the customer                        *--
  --*    Parameters : p_OnAccountRec  IN  OnAccountRecType                                 *--
  --*               : p_ErrorCode     OUT The Error Code                                   *--
  --*               : p_ErrorDesc     OUT The Error Description                            *--
  --*               : p_ErrorLoc      OUT The Error Location                               *--
  --*   Global Vars : g_SUCCESS         READ                                               *--
  --*               : g_OutErrorInfo    WRITE                                              *--
  --*               : g_OutCashReceipts WRITE, READ                                        *--
  --*   Called from : process_receipts                                                     *--
  --*         Calls : ar_receipt_api_pub.Apply_on_account                                  *--
  --*               : fnd_msg_pub.get                                                      *--
  --*               : debug_msg                                                            *--
  --*               : debug_init                                                           *--
  --*               : debug_exit                                                           *--
  --*               : error                                                                *--
  --*   Tables Used : None                                                                 *--
  --*         Logic : Use the values in p_OnAccountRec and use them as parameters to call  *--
  --*               :      ar_receipt_api_pub.Apply_on_account                             *--
  --*               : If there is an error the return code in x_return_status will not be S*--
  --*               : If there is an error, check the contents of x_msg_count              *--
  --*               : If x_msg_count is 1 then the error message is obtained from          *--
  --*               :      x_msg_data                                                      *--
  --*               : If x_msg_count is > 1 then call fnd_msg_pub.get x_msg_count times to *--
  --*               :      get the error messages.                                         *--
  --****************************************************************************************--
  PROCEDURE apply_on_account
  (
    p_OnAccountRec         IN  OnAccountRecType,
    p_ErrorCode            OUT NOCOPY  VARCHAR2,
    p_ErrorDesc            OUT  NOCOPY VARCHAR2,
    p_ErrorLoc             OUT NOCOPY  VARCHAR2
  ) IS
    l_module_name           VARCHAR2(30) := 'apply_on_account ';
    l_api_version          CONSTANT NUMBER       := 1.0;
    l_ReturnStatus         VARCHAR2(10);
    l_MessageCount         NUMBER;
    l_MessageData          VARCHAR2(1024);
    l_CashReceiptId        NUMBER;

  BEGIN
    p_ErrorCode  := g_SUCCESS;
    p_ErrorDesc  := NULL;
    p_ErrorLoc   := NULL;

    debug_init (g_PackageName, l_module_name);

    ----------------------------------------------------------------------
    -- Print contents of P_OnAccountRec for debug purposes              --
    ----------------------------------------------------------------------
    debug_msg (l_module_name, 'Calling API ar_receipt_api_pub.Apply_on_account with the following paraeteres');
    debug_msg (l_module_name, 'p_api_version            => '||l_api_version);
    debug_msg (l_module_name, 'p_cash_receipt_id        => '||p_OnAccountRec.cash_receipt_id);
    debug_msg (l_module_name, 'p_receipt_number         => '||p_OnAccountRec.receipt_number);
    debug_msg (l_module_name, 'p_amount_applied         => '||p_OnAccountRec.amount_applied);
    debug_msg (l_module_name, 'p_apply_date             => '||TO_CHAR(p_OnAccountRec.apply_date, 'MM/DD/YYYY HH24:MI:SS'));
    debug_msg (l_module_name, 'p_apply_gl_date          => '||TO_CHAR(p_OnAccountRec.apply_gl_date, 'MM/DD/YYYY HH24:MI:SS'));
--    debug_msg (l_module_name, 'p_ussgl_transaction_code => '||p_OnAccountRec.ussgl_transaction_code);
    debug_msg (l_module_name, 'p_comments               => '||p_OnAccountRec.comments);

    ----------------------------------------------------------------------
    -- Call API ar_receipt_api_pub.Apply_on_account for applying        --
    -- p_OnAccountRec.amount_applied towards On account for the         --
    -- customer                                                         --
    ----------------------------------------------------------------------
    log_msg (l_module_name,'Applying On Account for an amount of '||p_OnAccountRec.amount_applied);
    ar_receipt_api_pub.Apply_on_account
    (
      p_api_version            => l_api_version,
      p_init_msg_list          => FND_API.G_TRUE,
      p_commit                 => FND_API.G_FALSE,
      p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
      x_return_status          => l_ReturnStatus,
      x_msg_count              => l_MessageCount,
      x_msg_data               => l_MessageData,
      p_cash_receipt_id        => p_OnAccountRec.cash_receipt_id,
      p_receipt_number         => p_OnAccountRec.receipt_number,
      p_amount_applied         => p_OnAccountRec.amount_applied,
      p_apply_date             => p_OnAccountRec.apply_date,
      p_apply_gl_date          => p_OnAccountRec.apply_gl_date,
--      p_ussgl_transaction_code => p_OnAccountRec.ussgl_transaction_code,
      p_ussgl_transaction_code => null,
      p_attribute_rec          => p_OnAccountRec.attribute_rec,
      p_global_attribute_rec   => p_OnAccountRec.global_attribute_rec,
      p_comments               => p_OnAccountRec.comments
    );
    debug_msg (l_module_name, 'After Calling API ar_receipt_api_pub.Apply_on_account (Return Values)');
    debug_msg (l_module_name, 'x_return_status          => '||l_ReturnStatus);
    debug_msg (l_module_name, 'x_msg_count              => '||l_MessageCount);
    debug_msg (l_module_name, 'x_msg_data               => '||l_MessageData);

    IF (l_ReturnStatus <> 'S') THEN
      log_msg (l_module_name,'Could not apply On Account');
      ----------------------------------------------------------------------
      -- There is an error                                                --
      ----------------------------------------------------------------------
      p_ErrorCode := g_FAILURE;
      p_ErrorLoc  := 'After Calling API ar_receipt_api_pub.Apply_on_account.';

      IF (l_MessageCount = 1) THEN
        ----------------------------------------------------------------------
        -- Message Count is 1, hence the error message is in x_msg_data     --
        ----------------------------------------------------------------------
        p_ErrorDesc := l_MessageData;
        g_OutCashReceipts.total_errors := g_OutCashReceipts.total_errors + 1;
        g_OutErrorInfo(g_OutCashReceipts.total_errors).error_desc := l_MessageData;
        error
        (
          p_error_type => p_ErrorCode,
          p_pgm        => l_module_name,
          p_msg        => p_ErrorDesc,
          p_loc        => p_ErrorLoc
        );
        debug_msg (l_module_name, 'Error Message is :'||l_MessageData);
      ELSE
        ----------------------------------------------------------------------
        -- Message Count is > 1, hence loop for x_msg_count times and call  --
        -- fnd_msg_pub.get to get the error messages                        --
        ----------------------------------------------------------------------
        FOR l_Counter IN 1..l_MessageCount LOOP
          l_MessageData := fnd_msg_pub.get (p_encoded => 'F');
          g_OutCashReceipts.total_errors := g_OutCashReceipts.total_errors + 1;
          g_OutErrorInfo(g_OutCashReceipts.total_errors).error_desc := l_MessageData;
          error
          (
            p_error_type => p_ErrorCode,
            p_pgm        => l_module_name,
            p_msg        => p_ErrorDesc,
            p_loc        => p_ErrorLoc
          );
          debug_msg (l_module_name, 'Error Message is :'||l_MessageData);
        END LOOP;
        p_ErrorDesc := 'Look at the Report to find the error';
      END IF;
    ELSE
      log_msg (l_module_name,'On Account Application Successfull');
    END IF;

    debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  EXCEPTION
    WHEN OTHERS THEN
      p_ErrorCode := g_FAILURE;
      p_ErrorDesc := SQLERRM;
      p_ErrorLoc  := 'Final Exception';
      error
      (
        p_error_type => p_ErrorCode,
        p_pgm        => l_module_name,
        p_msg        => p_ErrorDesc,
        p_loc        => p_ErrorLoc
      );
      debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  END apply_on_account ;

  --****************************************************************************************--
  --*          Name : unapply_if_already_applied                                           *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : Checks to see if the debit memo was already applied to a cash receipt*--
  --*               : If so the application is reversed and the amount is returned.        *--
  --*    Parameters : p_ReceiptId            IN  Cash Receipt                              *--
  --*               : p_InvoiceId            IN  Invoice Id to be unapplied                *--
  --*               : p_UnAppliedAmount      OUT The Unapplied amount is returned          *--
  --*               : p_ErrorCode            OUT The Error Code                            *--
  --*               : p_ErrorDesc            OUT The Error Description                     *--
  --*               : p_ErrorLoc             OUT The Error Location                        *--
  --*   Global Vars : g_SUCCESS         READ                                               *--
  --*               : g_OutErrorInfo    WRITE                                              *--
  --*               : g_OutCashReceipts WRITE, READ                                        *--
  --*   Called from : pay_debit_memos                                                      *--
  --*         Calls : ar_receipt_api_pub.unapply                                           *--
  --*               : fnd_msg_pub.get                                                      *--
  --*               : debug_msg                                                            *--
  --*               : debug_init                                                           *--
  --*               : debug_exit                                                           *--
  --*               : error                                                                *--
  --*   Tables Used : ar_receivable_applications SELECT                                    *--
  --*         Logic : For the specific Cash Receipt Id and Invoice Id see if there is any  *--
  --*               : data in the table ar_receivable_applications.                        *--
  --*               : If not exit.                                                         *--
  --*               : If there is any data in ar_receivable_applications, then call        *--
  --*               :      ar_receipt_api_pub.unapply to unapply the invoice               *--
  --*               : If there is an error the return code in x_return_status will not be S*--
  --*               : If there is an error, check the contents of x_msg_count              *--
  --*               : If x_msg_count is 1 then the error message is obtained from          *--
  --*               :      x_msg_data                                                      *--
  --*               : If x_msg_count is > 1 then call fnd_msg_pub.get x_msg_count times to *--
  --*               :      get the error messages.                                         *--
  --*               : Mark the row as erased in the report table.                          *--
  --*               : Return the unapplied amount.                                         *--
  --****************************************************************************************--
  PROCEDURE unapply_if_already_applied
  (
    p_ReceiptId            IN  NUMBER,
    p_InvoiceId            IN  NUMBER,
    p_UnAppliedAmount      OUT NOCOPY  NUMBER,
    p_ErrorCode            OUT NOCOPY  VARCHAR2,
    p_ErrorDesc            OUT NOCOPY  VARCHAR2,
    p_ErrorLoc             OUT NOCOPY  VARCHAR2
  ) IS
    l_module_name              VARCHAR2(30) := 'unapply_if_already_applied';
    l_api_version             CONSTANT NUMBER       := 1.0;
    l_ReturnStatus            VARCHAR2(10);
    l_MessageCount            NUMBER;
    l_MessageData             VARCHAR2(1024);
    l_PreviousAmount          NUMBER;
    l_ReceivableApplicationId NUMBER;

    l_Count NUMBER;

  BEGIN
    p_ErrorCode  := g_SUCCESS;
    p_ErrorDesc  := NULL;
    p_ErrorLoc   := NULL;

    debug_init (g_PackageName, l_module_name);
    debug_msg (l_module_name, 'p_Receiptid       =  '||p_Receiptid);
    debug_msg (l_module_name, 'p_InvoiceId       =  '||p_InvoiceId);

    BEGIN
      SELECT ara.amount_applied,
             ara.receivable_application_id
        INTO l_PreviousAmount,
             l_ReceivableApplicationId
        FROM ar_receivable_applications ara
       WHERE ara.cash_receipt_id = p_Receiptid
         AND ara.applied_customer_trx_id = p_InvoiceId;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_PreviousAmount := 0;
        debug_msg (l_module_name, 'No Data Found');
      WHEN OTHERS THEN
        p_ErrorCode := g_FAILURE;
        p_ErrorDesc := SQLERRM;
        p_ErrorLoc  := 'SELECT ar_receivable_applications';
        error
        (
          p_error_type => p_ErrorCode,
          p_pgm        => l_module_name,
          p_msg        => p_ErrorDesc,
          p_loc        => p_ErrorLoc
        );
        debug_msg (l_module_name, p_ErrorDesc||'at location'||p_ErrorLoc);
    END;

    debug_msg (l_module_name, 'l_ReceivableApplicationId       =  '||l_ReceivableApplicationId);
    debug_msg (l_module_name, 'l_PreviousAmount                =  '||l_PreviousAmount);

    IF (p_ErrorCode = g_SUCCESS) THEN
      IF (l_PreviousAmount <> 0) THEN
        ar_receipt_api_pub.unapply
        (
          p_api_version                 => l_api_version,
          p_init_msg_list               => FND_API.G_TRUE,
          p_commit                      => FND_API.G_FALSE,
          p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
          x_return_status               => l_ReturnStatus,
          x_msg_count                   => l_MessageCount,
          x_msg_data                    => l_MessageData,
          p_receipt_number              => NULL,
          p_cash_receipt_id             => NULL,
          p_trx_number                  => NULL,
          p_customer_trx_id             => NULL,
          p_installment                 => NULL,
          p_applied_payment_schedule_id => NULL,
          p_receivable_application_id   => l_ReceivableApplicationId,
          p_reversal_gl_date            => NULL,
          p_called_from                 => NULL,
          p_cancel_claim_flag           => NULL
        );

        debug_msg (l_module_name, 'After Calling API ar_receipt_api_pub.Unapply (Return Values)');
        debug_msg (l_module_name, 'x_return_status                => '||l_ReturnStatus);
        debug_msg (l_module_name, 'x_msg_count                    => '||l_MessageCount);
        debug_msg (l_module_name, 'x_msg_data                     => '||l_MessageData);

        IF (l_ReturnStatus <> 'S') THEN
          ----------------------------------------------------------------------
          -- There is an error                                                --
          ----------------------------------------------------------------------
          p_ErrorCode := g_FAILURE;
          p_ErrorLoc  := 'After Calling API ar_receipt_api_pub.UnApply.';

          IF (l_MessageCount = 1) THEN
            ----------------------------------------------------------------------
            -- Message Count is 1, hence the error message is in x_msg_data     --
            ----------------------------------------------------------------------
            p_ErrorDesc := l_MessageData;
            g_OutCashReceipts.total_errors := g_OutCashReceipts.total_errors + 1;
            g_OutErrorInfo(g_OutCashReceipts.total_errors).error_desc := l_MessageData;
            error
            (
              p_error_type => p_ErrorCode,
              p_pgm        => l_module_name,
              p_msg        => p_ErrorDesc,
              p_loc        => p_ErrorLoc
            );
            debug_msg (l_module_name, 'Error Message is :'||l_MessageData);
          ELSE
            ----------------------------------------------------------------------
            -- Message Count is > 1, hence loop for x_msg_count times and call  --
            -- fnd_msg_pub.get to get the error messages                        --
            ----------------------------------------------------------------------
            FOR l_Counter IN 1..l_MessageCount LOOP
              l_MessageData := fnd_msg_pub.get (p_encoded => 'F');
              g_OutCashReceipts.total_errors := g_OutCashReceipts.total_errors + 1;
              g_OutErrorInfo(g_OutCashReceipts.total_errors).error_desc := l_MessageData;
              debug_msg (l_module_name, 'Error Message is :'||l_MessageData);
              error
              (
                p_error_type => p_ErrorCode,
                p_pgm        => l_module_name,
                p_msg        => p_ErrorDesc,
                p_loc        => p_ErrorLoc
              );
            END LOOP;
            p_ErrorDesc := 'Look at the Report to find the error';
          END IF;
        END IF;
      END IF;
    END IF;

    p_UnAppliedAmount := l_PreviousAmount;

    debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  EXCEPTION
    WHEN OTHERS THEN
      p_ErrorCode := g_FAILURE;
      p_ErrorDesc := SQLERRM;
      p_ErrorLoc  := 'Final Exception';
      error
      (
        p_error_type => p_ErrorCode,
        p_pgm        => l_module_name,
        p_msg        => p_ErrorDesc,
        p_loc        => p_ErrorLoc
      );
      debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  END unapply_if_already_applied;

  --****************************************************************************************--
  --*          Name : CreateCashReceipt                                                    *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This procedure calls API ar_receipt_api_pub.Apply to apply the       *--
  --*               :   receipt against an invoice or debit memo.                          *--
  --*    Parameters : p_ApplyCashRec  IN  ApplyCashRecType                                 *--
  --*               : p_ErrorCode     OUT The Error Code                                   *--
  --*               : p_ErrorDesc     OUT The Error Description                            *--
  --*               : p_ErrorLoc      OUT The Error Location                               *--
  --*   Global Vars : g_SUCCESS         READ                                               *--
  --*               : g_OutErrorInfo    WRITE                                              *--
  --*               : g_OutCashReceipts WRITE, READ                                        *--
  --*   Called from : pay_the_invoice                                                      *--
  --*               : pay_debit_memos                                                      *--
  --*         Calls : ar_receipt_api_pub.Apply                                             *--
  --*               : fnd_msg_pub.get                                                      *--
  --*               : debug_msg                                                            *--
  --*               : debug_init                                                           *--
  --*               : debug_exit                                                           *--
  --*   Tables Used : None                                                                 *--
  --*         Logic : Use the values in p_OnAccountRec and use them as parameters to call  *--
  --*               :      ar_receipt_api_pub.Apply                                        *--
  --*               : If there is an error the return code in x_return_status will not be S*--
  --*               : If there is an error, check the contents of x_msg_count              *--
  --*               : If x_msg_count is 1 then the error message is obtained from          *--
  --*               :      x_msg_data                                                      *--
  --*               : If x_msg_count is > 1 then call fnd_msg_pub.get x_msg_count times to *--
  --*               :      get the error messages.                                         *--
  --****************************************************************************************--
  PROCEDURE apply_cash_receipt
  (
    p_ApplyCashRec         IN  ApplyCashRecType,
    p_ErrorCode            OUT NOCOPY  VARCHAR2,
    p_ErrorDesc            OUT  NOCOPY VARCHAR2,
    p_ErrorLoc             OUT NOCOPY  VARCHAR2
  ) IS
    l_module_name           VARCHAR2(30) := 'apply_cash_receipt';
    l_api_version          CONSTANT NUMBER       := 1.0;
    l_ReturnStatus         VARCHAR2(10);
    l_MessageCount         NUMBER;
    l_MessageData          VARCHAR2(1024);
    llca_def_trx_lines_tbl AR_RECEIPT_API_PUB.llca_trx_lines_tbl_type;


  BEGIN
    p_ErrorCode  := g_SUCCESS;
    p_ErrorDesc  := NULL;
    p_ErrorLoc   := NULL;

    debug_init (g_PackageName, l_module_name);

    IF (p_ErrorCode = g_SUCCESS) THEN
      ----------------------------------------------------------------------
      -- Print contents of p_ApplyCashRec for debug purposes              --
      ----------------------------------------------------------------------
      debug_msg (l_module_name, 'Calling API ar_receipt_api_pub.Apply/Apply_In_Detail with the following parameters');
      debug_msg (l_module_name, 'p_api_version                  => '||l_api_version);
      debug_msg (l_module_name, 'p_cash_receipt_id              => '||p_ApplyCashRec.cash_receipt_id);
      debug_msg (l_module_name, 'p_receipt_number               => '||p_ApplyCashRec.receipt_number);
      debug_msg (l_module_name, 'p_customer_trx_id              => '||p_ApplyCashRec.customer_trx_id);
      debug_msg (l_module_name, 'p_trx_number                   => '||p_ApplyCashRec.trx_number);
      debug_msg (l_module_name, 'p_installment                  => '||p_ApplyCashRec.installment);
      debug_msg (l_module_name, 'p_applied_payment_schedule_id  => '||p_ApplyCashRec.applied_payment_schedule_id);
      debug_msg (l_module_name, 'p_amount_applied               => '||p_ApplyCashRec.amount_applied);
      debug_msg (l_module_name, 'p_amount_applied_from          => '||p_ApplyCashRec.amount_applied_from);
      debug_msg (l_module_name, 'p_trans_to_receipt_rate        => '||p_ApplyCashRec.trans_to_receipt_rate);
      debug_msg (l_module_name, 'p_discount                     => '||p_ApplyCashRec.discount);
      debug_msg (l_module_name, 'p_apply_date                   => '||TO_CHAR(p_ApplyCashRec.apply_date, 'MM/DD/YYYY HH24:MI:SS'));
      debug_msg (l_module_name, 'p_apply_gl_date                => '||TO_CHAR(p_ApplyCashRec.apply_gl_date, 'MM/DD/YYYY HH24:MI:SS'));
--      debug_msg (l_module_name, 'p_ussgl_transaction_code       => '||p_ApplyCashRec.ussgl_transaction_code);
      debug_msg (l_module_name, 'p_customer_trx_line_id         => '||p_ApplyCashRec.customer_trx_line_id);
      debug_msg (l_module_name, 'p_line_number                  => '||p_ApplyCashRec.line_number);
      debug_msg (l_module_name, 'p_show_closed_invoices         => '||p_ApplyCashRec.show_closed_invoices);
      debug_msg (l_module_name, 'p_called_from                  => '||p_ApplyCashRec.called_from);
      debug_msg (l_module_name, 'p_move_deferred_tax            => '||p_ApplyCashRec.move_deferred_tax);
      debug_msg (l_module_name, 'p_link_to_trx_hist_id          => '||p_ApplyCashRec.link_to_trx_hist_id);
      debug_msg (l_module_name, 'p_comments                     => '||p_ApplyCashRec.comments);
      debug_msg (l_module_name, 'p_payment_set_id               => '||p_ApplyCashRec.payment_set_id);
      debug_msg (l_module_name, 'p_application_ref_type         => '||p_ApplyCashRec.application_ref_type);
      debug_msg (l_module_name, 'p_application_ref_id           => '||p_ApplyCashRec.application_ref_id);
      debug_msg (l_module_name, 'p_application_ref_num          => '||p_ApplyCashRec.application_ref_num);
      debug_msg (l_module_name, 'p_secondary_application_ref_id => '||p_ApplyCashRec.secondary_application_ref_id);
      debug_msg (l_module_name, 'p_application_ref_reason       => '||p_ApplyCashRec.application_ref_reason);
      debug_msg (l_module_name, 'p_customer_reference           => '||p_ApplyCashRec.customer_reference);
      debug_msg (l_module_name, 'p_org_id                       => '||p_ApplyCashRec.org_id);

      ---------------------------------------------------------------------
      -- 1. Check if the Receipt Applied is for line level application
      -- 2. If yes then call AR LLCA API
      ---------------------------------------------------------------------
      IF (p_ApplyCashRec.customer_trx_line_id IS NOT NULL) THEN

          log_msg (l_module_name,'Applying Invoice Id <'||p_ApplyCashRec.line_number||
                   '> for line Number <'||p_ApplyCashRec.line_number||
                   '> against Cash Receipt Id <'||p_ApplyCashRec.cash_receipt_id||'>');


          llca_def_trx_lines_tbl(1).customer_trx_line_id := p_ApplyCashRec.customer_trx_line_id;
          llca_def_trx_lines_tbl(1).line_number := p_ApplyCashRec.line_number;
          llca_def_trx_lines_tbl(1).line_amount := p_ApplyCashRec.amount_applied;
          llca_def_trx_lines_tbl(1).amount_applied := p_ApplyCashRec.amount_applied;
          llca_def_trx_lines_tbl(1).amount_applied_from := p_ApplyCashRec.amount_applied_from;

          ar_receipt_api_pub.Apply_In_Detail
          (
             p_api_version                  => l_api_version,
             p_init_msg_list                => FND_API.G_TRUE,
             p_commit                       => FND_API.G_TRUE,
             p_validation_level             => FND_API.G_VALID_LEVEL_FULL,
             x_return_status                => l_ReturnStatus,
             x_msg_count                    => l_MessageCount,
             x_msg_data                     => l_MessageData,
             p_llca_type                    => 'L',
             p_llca_trx_lines_tbl           => llca_def_trx_lines_tbl,
             p_line_amount                  => p_ApplyCashRec.amount_applied,
             p_cash_receipt_id              => p_ApplyCashRec.cash_receipt_id,
             p_receipt_number               => p_ApplyCashRec.receipt_number,
             p_customer_trx_id              => p_ApplyCashRec.customer_trx_id,
             p_trx_number                   => p_ApplyCashRec.trx_number,
             p_installment                  => p_ApplyCashRec.installment,
             p_applied_payment_schedule_id  => p_ApplyCashRec.applied_payment_schedule_id,
             p_amount_applied               => p_ApplyCashRec.amount_applied,
             p_amount_applied_from          => p_ApplyCashRec.amount_applied_from,
             p_trans_to_receipt_rate        => p_ApplyCashRec.trans_to_receipt_rate,
             p_discount                     => p_ApplyCashRec.discount,
             p_apply_date                   => p_ApplyCashRec.apply_date,
             p_apply_gl_date                => p_ApplyCashRec.apply_gl_date,
             p_ussgl_transaction_code       => null,
--             p_customer_trx_line_id         => p_ApplyCashRec.customer_trx_line_id,
--             p_line_number                  => p_ApplyCashRec.line_number,
             p_show_closed_invoices         => p_ApplyCashRec.show_closed_invoices,
             p_called_from                  => p_ApplyCashRec.called_from,
             p_move_deferred_tax            => p_ApplyCashRec.move_deferred_tax,
             p_link_to_trx_hist_id          => p_ApplyCashRec.link_to_trx_hist_id,
             p_attribute_rec                => p_ApplyCashRec.attribute_rec,
             p_global_attribute_rec         => p_ApplyCashRec.global_attribute_rec,
             p_comments                     => p_ApplyCashRec.comments,
             p_payment_set_id               => p_ApplyCashRec.payment_set_id,
             p_application_ref_type         => p_ApplyCashRec.application_ref_type,
             p_application_ref_id           => p_ApplyCashRec.application_ref_id,
             p_application_ref_num          => p_ApplyCashRec.application_ref_num,
             p_secondary_application_ref_id => p_ApplyCashRec.secondary_application_ref_id,
             p_application_ref_reason       => p_ApplyCashRec.application_ref_reason,
             p_customer_reference           => p_ApplyCashRec.customer_reference,
             p_org_id                       => p_ApplyCashRec.org_id
           );
          debug_msg (l_module_name, 'After Calling API ar_receipt_api_pub.Apply_In_Detail (Return Values)');
          debug_msg (l_module_name, 'x_return_status                => '||l_ReturnStatus);
          debug_msg (l_module_name, 'x_msg_count                    => '||l_MessageCount);
          debug_msg (l_module_name, 'x_msg_data                     => '||l_MessageData);

      ELSE
          ----------------------------------------------------------------------
          -- Call API ar_receipt_api_pub.Apply for applying the receipt amt  --
          -- p_ApplyCashRec.amount_applied, p_ApplyCashRec.amount_applied_from--
          -- towards the invoice or debit memo                                --
          ----------------------------------------------------------------------
          log_msg (l_module_name,'Applying Invoice Id <'||p_ApplyCashRec.customer_trx_id||
                   '> against Cash Receipt Id <'||p_ApplyCashRec.cash_receipt_id||'>');
          ar_receipt_api_pub.Apply
          (
            p_api_version                  => l_api_version,
            p_init_msg_list                => FND_API.G_TRUE,
            p_commit                       => FND_API.G_FALSE,
            p_validation_level             => FND_API.G_VALID_LEVEL_FULL,
            x_return_status                => l_ReturnStatus,
            x_msg_count                    => l_MessageCount,
            x_msg_data                     => l_MessageData,
            p_cash_receipt_id              => p_ApplyCashRec.cash_receipt_id,
            p_receipt_number               => p_ApplyCashRec.receipt_number,
            p_customer_trx_id              => p_ApplyCashRec.customer_trx_id,
            p_trx_number                   => p_ApplyCashRec.trx_number,
            p_installment                  => p_ApplyCashRec.installment,
            p_applied_payment_schedule_id  => p_ApplyCashRec.applied_payment_schedule_id,
            p_amount_applied               => p_ApplyCashRec.amount_applied,
            p_amount_applied_from          => p_ApplyCashRec.amount_applied_from,
            p_trans_to_receipt_rate        => p_ApplyCashRec.trans_to_receipt_rate,
            p_discount                     => p_ApplyCashRec.discount,
            p_apply_date                   => p_ApplyCashRec.apply_date,
            p_apply_gl_date                => p_ApplyCashRec.apply_gl_date,
--          p_ussgl_transaction_code       => p_ApplyCashRec.ussgl_transaction_code,
            p_ussgl_transaction_code       => null,
            p_customer_trx_line_id         => p_ApplyCashRec.customer_trx_line_id,
            p_line_number                  => p_ApplyCashRec.line_number,
            p_show_closed_invoices         => p_ApplyCashRec.show_closed_invoices,
            p_called_from                  => p_ApplyCashRec.called_from,
            p_move_deferred_tax            => p_ApplyCashRec.move_deferred_tax,
            p_link_to_trx_hist_id          => p_ApplyCashRec.link_to_trx_hist_id,
            p_attribute_rec                => p_ApplyCashRec.attribute_rec,
            p_global_attribute_rec         => p_ApplyCashRec.global_attribute_rec,
            p_comments                     => p_ApplyCashRec.comments,
            p_payment_set_id               => p_ApplyCashRec.payment_set_id,
            p_application_ref_type         => p_ApplyCashRec.application_ref_type,
            p_application_ref_id           => p_ApplyCashRec.application_ref_id,
            p_application_ref_num          => p_ApplyCashRec.application_ref_num,
            p_secondary_application_ref_id => p_ApplyCashRec.secondary_application_ref_id,
            p_application_ref_reason       => p_ApplyCashRec.application_ref_reason,
            p_customer_reference           => p_ApplyCashRec.customer_reference,
            p_org_id                       => p_ApplyCashRec.org_id
          );

          debug_msg (l_module_name, 'After Calling API ar_receipt_api_pub.Apply (Return Values)');
          debug_msg (l_module_name, 'x_return_status                => '||l_ReturnStatus);
          debug_msg (l_module_name, 'x_msg_count                    => '||l_MessageCount);
          debug_msg (l_module_name, 'x_msg_data                     => '||l_MessageData);

      END IF;

      IF (l_ReturnStatus <> 'S') THEN
        log_msg (l_module_name,'Cash Receipt Application Failed');
        ----------------------------------------------------------------------
        -- There is an error                                                --
        ----------------------------------------------------------------------
        p_ErrorCode := g_FAILURE;
        p_ErrorLoc  := 'After Calling API ar_receipt_api_pub.Apply.';

        IF (l_MessageCount = 1) THEN
          ----------------------------------------------------------------------
          -- Message Count is 1, hence the error message is in x_msg_data     --
          ----------------------------------------------------------------------
          p_ErrorDesc := l_MessageData;
          g_OutCashReceipts.total_errors := g_OutCashReceipts.total_errors + 1;
          g_OutErrorInfo(g_OutCashReceipts.total_errors).error_desc := l_MessageData;
          error
          (
            p_error_type => p_ErrorCode,
            p_pgm        => l_module_name,
            p_msg        => p_ErrorDesc,
            p_loc        => p_ErrorLoc
          );
          debug_msg (l_module_name, 'Error Message is :'||l_MessageData);
        ELSE
          ----------------------------------------------------------------------
          -- Message Count is > 1, hence loop for x_msg_count times and call  --
          -- fnd_msg_pub.get to get the error messages                        --
          ----------------------------------------------------------------------
          FOR l_Counter IN 1..l_MessageCount LOOP
            l_MessageData := fnd_msg_pub.get (p_encoded => 'F');
            g_OutCashReceipts.total_errors := g_OutCashReceipts.total_errors + 1;
            g_OutErrorInfo(g_OutCashReceipts.total_errors).error_desc := l_MessageData;
            error
            (
              p_error_type => p_ErrorCode,
              p_pgm        => l_module_name,
              p_msg        => p_ErrorDesc,
              p_loc        => p_ErrorLoc
            );
            debug_msg (l_module_name, 'Error Message is :'||l_MessageData);
          END LOOP;
          p_ErrorDesc := 'Look at the Report to find the error';
        END IF;
      END IF;
    ELSE
      log_msg (l_module_name,'Successfully Applied against the Cash Receipt');
    END IF;

    debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  EXCEPTION
    WHEN OTHERS THEN
      p_ErrorCode := g_FAILURE;
      p_ErrorDesc := SQLERRM;
      p_ErrorLoc  := 'Final Exception';
      error
      (
        p_error_type => p_ErrorCode,
        p_pgm        => l_module_name,
        p_msg        => p_ErrorDesc,
        p_loc        => p_ErrorLoc
      );
      debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  END apply_cash_receipt;

  --****************************************************************************************--
  --*          Name : update_cash_receipt_hist                                             *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : Currenty the APIs for Receipt process does not have an option to     *--
  --*               : receive batch_id, hence the fv_ar_batch details are entered into the *--
  --*               : table ar_batches and the batch_id obtained is used to update the     *--
  --*               : table ar_cash_receipt_history_all, so that it simulates the current  *--
  --*               : process of entering the receipt details through batch                *--
  --*    Parameters : p_BatchId       IN  The batch Id                                     *--
  --*               : p_CashReceiptId IN  The Cash Receipt Id                              *--
  --*               : p_ErrorCode     OUT The Error Code                                   *--
  --*               : p_ErrorDesc     OUT The Error Description                            *--
  --*               : p_ErrorLoc      OUT The Error Location                               *--
  --*   Global Vars : g_SUCCESS              READ                                          *--
  --*   Called from : create_cash_receipt                                                  *--
  --*         Calls : debug_msg                                                            *--
  --*               : debug_init                                                           *--
  --*               : debug_exit                                                           *--
  --*               : error                                                                *--
  --*               : log_msg                                                              *--
  --*   Tables Used : ar_cash_receipt_history_all UPDATE                                   *--
  --*         Logic : UPDATE ar_cash_receipt_history_all with value p_BatchId for the      *--
  --*               : receipt id p_CashReceiptId                                           *--
  --****************************************************************************************--
  PROCEDURE update_cash_receipt_hist
  (
    p_BatchId              IN  NUMBER,
    p_CashReceiptId        IN  NUMBER,
    p_ErrorCode            OUT NOCOPY  VARCHAR2,
    p_ErrorDesc            OUT NOCOPY  VARCHAR2,
    p_ErrorLoc             OUT NOCOPY  VARCHAR2
  ) IS
    l_module_name           VARCHAR2(30) := 'update_cash_receipt_hist';

  BEGIN
    p_ErrorCode  := g_SUCCESS;
    p_ErrorDesc  := NULL;
    p_ErrorLoc   := NULL;

    debug_init (g_PackageName, l_module_name);

    debug_msg (l_module_name, 'p_BatchId       =  '||p_BatchId);
    debug_msg (l_module_name, 'p_CashReceiptId =  '||p_CashReceiptId);

    log_msg (l_module_name,'Updating Cash Receipt History');

    BEGIN
      ----------------------------------------------------------------------
      -- Update the table ar_cash_receipt_history_all to link it with the --
      -- table ar_batches                                                 --
      ----------------------------------------------------------------------
      UPDATE ar_cash_receipt_history_all
         SET batch_id = p_BatchId
       WHERE cash_receipt_id = p_CashReceiptId;

    log_msg (l_module_name,'Successfully Updated Cash Receipt History');
    debug_msg (l_module_name, 'Updated '||SQL%ROWCOUNT||' rows.');
    EXCEPTION
      WHEN OTHERS THEN
        p_ErrorCode := g_FAILURE;
        p_ErrorDesc := SQLERRM;
        p_ErrorLoc  := 'UPDATE ar_cash_receipt_history_all';
        error
        (
          p_error_type => p_ErrorCode,
          p_pgm        => l_module_name,
          p_msg        => p_ErrorDesc,
          p_loc        => p_ErrorLoc
        );
        log_msg (l_module_name,'Error Updating Cash Receipt History');
        debug_msg (l_module_name, p_ErrorDesc||'at location'||p_ErrorLoc);
    END;

    debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  EXCEPTION
    WHEN OTHERS THEN
      p_ErrorCode := g_FAILURE;
      p_ErrorDesc := SQLERRM;
      p_ErrorLoc  := 'Final Exception';
      error
      (
        p_error_type => p_ErrorCode,
        p_pgm        => l_module_name,
        p_msg        => p_ErrorDesc,
        p_loc        => p_ErrorLoc
      );
      debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  END update_cash_receipt_hist;

  --****************************************************************************************--
  --*          Name : update_fv_batch_status                                               *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This procedure is used to update the status of the table             *--
  --*               : fv_ar_batches_all.
  --*    Parameters : p_BatchId       IN  The batch Id                                     *--
  --*               : p_Status        IN  The Status to which the table to be updated      *--
  --*               : p_ErrorCode     OUT The Error Code                                   *--
  --*               : p_ErrorDesc     OUT The Error Description                            *--
  --*               : p_ErrorLoc      OUT The Error Location                               *--
  --*   Global Vars : g_SUCCESS              READ                                          *--
  --*   Called from : main                                                                 *--
  --*         Calls : debug_msg                                                            *--
  --*               : debug_init                                                           *--
  --*               : debug_exit                                                           *--
  --*   Tables Used : fv_ar_batches_all UPDATE                                             *--
  --*         Logic : Update the table fv_ar_batches_all with the status p_Status for the  *--
  --*               : batch_id p_BatchId                                                   *--
  --****************************************************************************************--
  PROCEDURE update_fv_batch_status
  (
    p_BatchId    IN  NUMBER,
    p_Status     IN  VARCHAR2,
    p_ErrorCode  OUT NOCOPY  VARCHAR2,
    p_ErrorDesc  OUT NOCOPY  VARCHAR2,
    p_ErrorLoc   OUT NOCOPY  VARCHAR2
  ) IS
    l_module_name VARCHAR2(30) := 'update_fv_batch_status';

  BEGIN
    p_ErrorCode  := g_SUCCESS;
    p_ErrorDesc  := NULL;
    p_ErrorLoc   := NULL;

    debug_init (g_PackageName, l_module_name);

    debug_msg (l_module_name, 'p_BatchId = '||p_BatchId);
    debug_msg (l_module_name, 'p_Status  = '||p_Status);

    BEGIN
      debug_msg (l_module_name, 'Updating table fv_ar_batches_all');

      ----------------------------------------------------------------------
      -- Update the table fv_ar_batches_all to the status p_Status for    --
      -- batch_id p_BatchId                                               --
      ----------------------------------------------------------------------
      UPDATE fv_ar_batches_all
         SET transfer_status = p_status
       WHERE batch_id = p_BatchId;

      debug_msg (l_module_name, 'Updated '||SQL%ROWCOUNT||' rows.');

    EXCEPTION
      WHEN OTHERS THEN
        p_ErrorCode := g_FAILURE;
        p_ErrorDesc := SQLERRM;
        p_ErrorLoc  := 'UPDATE fv_ar_batches_all';
        error
        (
          p_error_type => p_ErrorCode,
          p_pgm        => l_module_name,
          p_msg        => p_ErrorDesc,
          p_loc        => p_ErrorLoc
        );
        debug_msg (l_module_name, p_ErrorDesc||'at location'||p_ErrorLoc);
    END;

    debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  EXCEPTION
    WHEN OTHERS THEN
      p_ErrorCode := g_FAILURE;
      p_ErrorDesc := SQLERRM;
      p_ErrorLoc  := 'Final Exception';
      error
      (
        p_error_type => p_ErrorCode,
        p_pgm        => l_module_name,
        p_msg        => p_ErrorDesc,
        p_loc        => p_ErrorLoc
      );
      debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  END update_fv_batch_status;

  --****************************************************************************************--
  --*          Name : create_cash_receipt                                                  *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This procedure creates a Cash Receipt ID by calling the API          *--
  --*               : ar_receipt_api_pub.Create_cash  and returns the Cash Receipt Id to   *--
  --*               : calling program. This procedure also calls update_cash_receipt_hist  *--
  --*               : to update the Cash Receipt History table with the batch_id           *--
  --*    Parameters : p_BatchId       IN  The batch Id                                     *--
  --*               : p_CreateCashRec IN  CreateCashRecType                                *--
  --*               : p_CashReceiptId OUT Cash Receipt Id                                  *--
  --*               : p_ErrorCode     OUT The Error Code                                   *--
  --*               : p_ErrorDesc     OUT The Error Description                            *--
  --*               : p_ErrorLoc      OUT The Error Location                               *--
  --*   Global Vars : g_SUCCESS         READ                                               *--
  --*               : g_OutErrorInfo    WRITE                                              *--
  --*               : g_OutCashReceipts WRITE, READ                                        *--
  --*   Called from : process_receipts                                                     *--
  --*         Calls : update_cash_receipt_hist                                             *--
  --*               : ar_receipt_api_pub.Create_cash                                       *--
  --*               : fnd_msg_pub.get                                                      *--
  --*               : debug_msg                                                            *--
  --*               : debug_init                                                           *--
  --*               : debug_exit                                                           *--
  --*               : error                                                                *--
  --*               : log_msg                                                              *--
  --*   Tables Used : None                                                                 *--
  --*         Logic : Use the values in p_CreateCashRec and use them as parameters to call *--
  --*               :      ar_receipt_api_pub.Create_cash                                  *--
  --*               : If there is an error the return code in x_return_status will not be S*--
  --*               : If there is an error, check the contents of x_msg_count              *--
  --*               : If x_msg_count is 1 then the error message is obtained from          *--
  --*               :      x_msg_data                                                      *--
  --*               : If x_msg_count is > 1 then call fnd_msg_pub.get x_msg_count times to *--
  --*               :      get the error messages.                                         *--
  --*               : Call update_cash_receipt_hist to update the Cash Receipt History     *--
  --*               : table.                                                               *--
  --****************************************************************************************--
  PROCEDURE create_cash_receipt
  (
    p_BatchId       IN  NUMBER,
    p_CreateCashRec IN  CreateCashRecType,
    p_CashReceiptId OUT NOCOPY  ar_cash_receipts.cash_receipt_id%TYPE,
    p_ErrorCode     OUT NOCOPY  VARCHAR2,
    p_ErrorDesc     OUT NOCOPY  VARCHAR2,
    p_ErrorLoc      OUT NOCOPY  VARCHAR2
  ) IS
    l_module_name    VARCHAR2(30) := 'create_cash_receipt';
    l_api_version   CONSTANT NUMBER       := 1.0;
    l_ReturnStatus  VARCHAR2(10);
    l_MessageCount  NUMBER;
    l_MessageData   VARCHAR2(1024);
    l_exchange_rate NUMBER;

  BEGIN
    p_ErrorCode  := g_SUCCESS;
    p_ErrorDesc  := NULL;
    p_ErrorLoc   := NULL;

    debug_init (g_PackageName, l_module_name);

    debug_msg (l_module_name, 'BatchId '||p_BatchId);

    ----------------------------------------------------------------------
    -- Print contents of p_CreateCashRec for debug purposes             --
    ----------------------------------------------------------------------
    debug_msg (l_module_name, 'Calling API ar_receipt_api_pub.Create_cash with the following paraeteres');
    debug_msg (l_module_name, '          p_api_version                  => '||l_api_version);
    debug_msg (l_module_name, '          p_usr_currency_code            => '||p_CreateCashRec.usr_currency_code);
    debug_msg (l_module_name, '          p_currency_code                => '||p_CreateCashRec.currency_code);
    debug_msg (l_module_name, '          p_usr_exchange_rate_type       => '||p_CreateCashRec.usr_exchange_rate_type);
    debug_msg (l_module_name, '          p_exchange_rate_type           => '||p_CreateCashRec.exchange_rate_type);

    -- if exchange rate type is not 'User' then we don't need to pass exchange rate
    IF p_CreateCashRec.exchange_rate_type <> 'User' THEN
       l_exchange_rate := null;
    ELSE
       l_exchange_rate := p_CreateCashRec.exchange_rate;
    END IF;

    debug_msg (l_module_name, '          p_exchange_rate                => '||l_exchange_rate);
    debug_msg (l_module_name, '          p_exchange_rate_date           => '||TO_CHAR(p_CreateCashRec.exchange_rate_date, 'MM/DD/YYYY'));
    debug_msg (l_module_name, '          p_amount                       => '||p_CreateCashRec.amount);
    debug_msg (l_module_name, '          p_factor_discount_amount       => '||p_CreateCashRec.factor_discount_amount);
    debug_msg (l_module_name, '          p_receipt_number               => '||p_CreateCashRec.receipt_number);
    debug_msg (l_module_name, '          p_receipt_date                 => '||TO_CHAR(p_CreateCashRec.receipt_date, 'MM/DD/YYYY'));
    debug_msg (l_module_name, '          p_gl_date                      => '||TO_CHAR(p_CreateCashRec.gl_date, 'MM/DD/YYYY'));
    debug_msg (l_module_name, '          p_maturity_date                => '||TO_CHAR(p_CreateCashRec.maturity_date, 'MM/DD/YYYY'));
    debug_msg (l_module_name, '          p_postmark_date                => '||TO_CHAR(p_CreateCashRec.postmark_date, 'MM/DD/YYYY'));
    debug_msg (l_module_name, '          p_customer_id                  => '||p_CreateCashRec.customer_id);
    debug_msg (l_module_name, '          p_customer_name                => '||p_CreateCashRec.customer_name);
    debug_msg (l_module_name, '          p_customer_number              => '||p_CreateCashRec.customer_number);
    debug_msg (l_module_name, '          p_customer_bank_account_id     => '||p_CreateCashRec.customer_bank_account_id);
    debug_msg (l_module_name, '          p_customer_bank_account_num    => '||p_CreateCashRec.customer_bank_account_num);
    debug_msg (l_module_name, '          p_customer_bank_account_name   => '||p_CreateCashRec.customer_bank_account_name);
    debug_msg (l_module_name, '          p_location                     => '||p_CreateCashRec.location);
    debug_msg (l_module_name, '          p_customer_site_use_id         => '||p_CreateCashRec.customer_site_use_id);
    debug_msg (l_module_name, '          p_customer_receipt_reference   => '||p_CreateCashRec.customer_receipt_reference);
    debug_msg (l_module_name, '          p_override_remit_account_flag  => '||p_CreateCashRec.override_remit_account_flag);
    debug_msg (l_module_name, '          p_remittance_bank_account_id   => '||p_CreateCashRec.remittance_bank_account_id);
    debug_msg (l_module_name, '          p_remittance_bank_account_num  => '||p_CreateCashRec.remittance_bank_account_num);
    debug_msg (l_module_name, '          p_remittance_bank_account_name => '||p_CreateCashRec.remittance_bank_account_name);
    debug_msg (l_module_name, '          p_deposit_date                 => '||TO_CHAR(p_CreateCashRec.deposit_date, 'MM/DD/YYYY'));
    debug_msg (l_module_name, '          p_receipt_method_id            => '||p_CreateCashRec.receipt_method_id);
    debug_msg (l_module_name, '          p_receipt_method_name          => '||p_CreateCashRec.receipt_method_name);
    debug_msg (l_module_name, '          p_doc_sequence_value           => '||p_CreateCashRec.doc_sequence_value);
--    debug_msg (l_module_name, '          p_ussgl_transaction_code       => '||p_CreateCashRec.ussgl_transaction_code);
    debug_msg (l_module_name, '          p_anticipated_clearing_date    => '||TO_CHAR(p_CreateCashRec.anticipated_clearing_date, 'MM/DD/YYYY'));
    debug_msg (l_module_name, '          p_called_from                  => '||p_CreateCashRec.called_from);
    debug_msg (l_module_name, '          p_comments                     => '||p_CreateCashRec.comments);
    debug_msg (l_module_name, '          p_issuer_name                  => '||p_CreateCashRec.issuer_name);
    debug_msg (l_module_name, '          p_issue_date                   => '||TO_CHAR(p_CreateCashRec.issue_date, 'MM/DD/YYYY'));
    debug_msg (l_module_name, '          p_issuer_bank_branch_id        => '||p_CreateCashRec.issuer_bank_branch_id);
    debug_msg (l_module_name, '          p_org_id                       => '||p_CreateCashRec.org_id);

    ----------------------------------------------------------------------
    -- Call API ar_receipt_api_pub.Create_cash to create a Cash Receipt --
    -- using the record p_CreateCashRec.                                --
    ----------------------------------------------------------------------
    log_msg (l_module_name,'Creating a Cash Receipt '||p_CreateCashRec.receipt_number);
    ar_receipt_api_pub.Create_cash
    (
      p_api_version                  => l_api_version,
      p_init_msg_list                => FND_API.G_TRUE,
      p_commit                       => FND_API.G_FALSE,
      p_validation_level             => FND_API.G_VALID_LEVEL_FULL,
      x_return_status                => l_ReturnStatus,
      x_msg_count                    => l_MessageCount,
      x_msg_data                     => l_MessageData,
      p_usr_currency_code            => p_CreateCashRec.usr_currency_code,
      p_currency_code                => p_CreateCashRec.currency_code,
      p_usr_exchange_rate_type       => p_CreateCashRec.usr_exchange_rate_type,
      p_exchange_rate_type           => p_CreateCashRec.exchange_rate_type,
      p_exchange_rate                => l_exchange_rate,
      p_exchange_rate_date           => p_CreateCashRec.exchange_rate_date,
      p_amount                       => p_CreateCashRec.amount,
      p_factor_discount_amount       => p_CreateCashRec.factor_discount_amount,
      p_receipt_number               => p_CreateCashRec.receipt_number,
      p_receipt_date                 => p_CreateCashRec.receipt_date,
      p_gl_date                      => p_CreateCashRec.gl_date,
      p_maturity_date                => p_CreateCashRec.maturity_date,
      p_postmark_date                => p_CreateCashRec.postmark_date,
      p_customer_id                  => p_CreateCashRec.customer_id,
      p_customer_name                => p_CreateCashRec.customer_name,
      p_customer_number              => p_CreateCashRec.customer_number,
      p_customer_bank_account_id     => p_CreateCashRec.customer_bank_account_id,
      p_customer_bank_account_num    => p_CreateCashRec.customer_bank_account_num,
      p_customer_bank_account_name   => p_CreateCashRec.customer_bank_account_name,
      p_location                     => p_CreateCashRec.location,
      p_customer_site_use_id         => p_CreateCashRec.customer_site_use_id,
      p_customer_receipt_reference   => p_CreateCashRec.customer_receipt_reference,
      p_override_remit_account_flag  => p_CreateCashRec.override_remit_account_flag,
      p_remittance_bank_account_id   => p_CreateCashRec.remittance_bank_account_id,
      p_remittance_bank_account_num  => p_CreateCashRec.remittance_bank_account_num,
      p_remittance_bank_account_name => p_CreateCashRec.remittance_bank_account_name,
      p_deposit_date                 => p_CreateCashRec.deposit_date,
      p_receipt_method_id            => p_CreateCashRec.receipt_method_id,
      p_receipt_method_name          => p_CreateCashRec.receipt_method_name,
      p_doc_sequence_value           => p_CreateCashRec.doc_sequence_value,
--      p_ussgl_transaction_code       => p_CreateCashRec.ussgl_transaction_code,
      p_ussgl_transaction_code       => null,
      p_anticipated_clearing_date    => p_CreateCashRec.anticipated_clearing_date,
      p_called_from                  => p_CreateCashRec.called_from,
      p_attribute_rec                => p_CreateCashRec.attribute_rec,
      p_global_attribute_rec         => p_CreateCashRec.global_attribute_rec,
      p_comments                     => p_CreateCashRec.comments,
      p_issuer_name                  => p_CreateCashRec.issuer_name,
      p_issue_date                   => p_CreateCashRec.issue_date,
      p_issuer_bank_branch_id        => p_CreateCashRec.issuer_bank_branch_id,
      p_cr_id                        => p_CashReceiptId,
      p_org_id                       => p_CreateCashRec.org_id
    );

    debug_msg (l_module_name, 'After Calling API ar_receipt_api_pub.Create_cash (Return Values)');
    debug_msg (l_module_name, '          p_cr_id                        => '||p_CashReceiptId);
    debug_msg (l_module_name, '          x_return_status                => '||l_ReturnStatus);
    debug_msg (l_module_name, '          x_msg_count                    => '||l_MessageCount);
    debug_msg (l_module_name, '          x_msg_data                     => '||l_MessageData);

    IF (l_ReturnStatus <> 'S') THEN
      log_msg (l_module_name,'Error creating Cash Receipt '||p_CreateCashRec.receipt_number);
      ----------------------------------------------------------------------
      -- There is an error                                                --
      ----------------------------------------------------------------------
      p_ErrorCode := g_FAILURE;
      p_ErrorLoc  := 'After Calling API ar_receipt_api_pub.Create_cash.';

      IF (l_MessageCount = 1) THEN
        ----------------------------------------------------------------------
        -- Message Count is 1, hence the error message is in x_msg_data     --
        ----------------------------------------------------------------------
        p_ErrorDesc := l_MessageData;
        g_OutCashReceipts.total_errors := g_OutCashReceipts.total_errors + 1;
        g_OutErrorInfo(g_OutCashReceipts.total_errors).error_desc := l_MessageData;
        error
        (
          p_error_type => p_ErrorCode,
          p_pgm        => l_module_name,
          p_msg        => p_ErrorDesc,
          p_loc        => p_ErrorLoc
        );
        debug_msg (l_module_name, 'Error Message is :'||l_MessageData);
      ELSE
        ----------------------------------------------------------------------
        -- Message Count is > 1, hence loop for x_msg_count times and call  --
        -- fnd_msg_pub.get to get the error messages                        --
        ----------------------------------------------------------------------
        FOR l_Counter IN 1..l_MessageCount LOOP
          l_MessageData := fnd_msg_pub.get (p_encoded => 'F');
          g_OutCashReceipts.total_errors := g_OutCashReceipts.total_errors + 1;
          g_OutErrorInfo(g_OutCashReceipts.total_errors).error_desc := l_MessageData;
          error
          (
            p_error_type => p_ErrorCode,
            p_pgm        => l_module_name,
            p_msg        => p_ErrorDesc,
            p_loc        => p_ErrorLoc
          );
          debug_msg (l_module_name, 'Error Message is :'||l_MessageData);
        END LOOP;
        p_ErrorDesc := 'Look at the Report to find the error';
      END IF;
    END IF;

    IF (p_ErrorCode = g_SUCCESS) THEN
      log_msg (l_module_name,'Successfully Created Cash Receipt '||p_CreateCashRec.receipt_number);
      ----------------------------------------------------------------------
      -- Call update_cash_receipt_hist to update the Cash Receipt History --
      -- table with the batch_id as p_BatchId for cash_receipt_id         --
      -- p_CashReceiptId                                                  --
      ----------------------------------------------------------------------
      debug_msg (l_module_name, 'Calling update_cash_receipt_hist.');
      update_cash_receipt_hist
      (
        p_BatchId           => p_BatchId,
        p_CashReceiptId     => p_CashReceiptId,
        p_ErrorCode         => p_ErrorCode,
        p_ErrorDesc         => p_ErrorDesc,
        p_ErrorLoc          => p_ErrorLoc
      );
    END IF;

    debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  EXCEPTION
    WHEN OTHERS THEN
      p_ErrorCode := g_FAILURE;
      p_ErrorDesc := SQLERRM;
      p_ErrorLoc  := 'Final Exception';
      error
      (
        p_error_type => p_ErrorCode,
        p_pgm        => l_module_name,
        p_msg        => p_ErrorDesc,
        p_loc        => p_ErrorLoc
      );
      debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  END create_cash_receipt;

  --****************************************************************************************--
  --*          Name : pay_the_invoice                                                      *--
  --*          Type : Procedure                                                            *--
  --*       Purpose :
  --*    Parameters : p_ReceiptNumber        IN The receipt Number                         *--
  --*               : p_CashReceiptId        IN Cash Receipt Id                            *--
  --*               : p_InvoiceNumber        IN Invoice Number                             *--
  --*               : p_InvoiceId            IN Invoice Id                                 *--
  --*               : p_InvoiceLineId        IN Invoice Line id                            *--
  --*               : p_CurrencyCode         IN Receipt Currency Code                      *--
  --*               : p_InvoiceCurrencyCode  IN Invoice Currency Code                      *--
  --*               : p_ExchangeRateDate     IN Exchange Rate Date                         *--
  --*               : p_ExchangeRate         IN Exchange Rate                              *--
  --*               : p_ExchangeRateType     IN Exchange Rate Type                         *--
  --*               : p_PaymentScheduleId    IN Payment Schedule Id                        *--
  --*               : p_InvoiceAmount        IN Invoice Amount                             *--
  --*               : p_ReceiptDate          IN Receipt Date                               *--
  --*               : p_GLDate               IN GL Date                                    *--
  --*               : p_USSGLTransactionCode IN USSGL Transaction Code                     *--
  --*               : p_RemaingReceiptAmount IN OUT The Remaining Receipt Amount           *--
  --*               : p_ErrorCode            OUT The Error Code                            *--
  --*               : p_ErrorDesc            OUT The Error Description                     *--
  --*               : p_ErrorLoc             OUT The Error Location                        *--
  --*   Global Vars : g_SUCCESS              READ                                          *--
  --*   Called from : process_receipts                                                     *--
  --*         Calls : apply_cash_receipt                                                   *--
  --*               : debug_msg                                                            *--
  --*               : debug_init                                                           *--
  --*               : debug_exit                                                           *--
  --*               : error                                                                *--
  --*   Tables Used : None                                                                 *--
  --*         Logic :                                                       .              *--
  --****************************************************************************************--
  PROCEDURE pay_the_invoice
  (
    p_ReceiptNumber          IN  fv_interim_cash_receipts.receipt_number%TYPE,
    p_CashReceiptId          IN  ar_cash_receipts.cash_receipt_id%TYPE,
    p_InvoiceNumber          IN  ra_customer_trx_all.trx_number%TYPE,
    p_LineNumber             IN  ra_customer_trx_lines_all.line_number%TYPE,
    p_InvoiceId              IN  ra_customer_trx_all.customer_trx_id%TYPE,
    p_InvoiceLineId          IN  ra_customer_trx_lines_all.customer_trx_line_id%TYPE,
    p_CurrencyCode           IN  fv_interim_cash_receipts.currency_code%TYPE,
    p_InvoiceCurrencyCode    IN  ra_customer_trx_all.invoice_currency_code%TYPE,
    p_ExchangeRateDate       IN  ar_batches.exchange_date%TYPE,
    p_ExchangeRate           IN  ar_batches.exchange_rate%TYPE,
    p_ExchangeRateType       IN  ar_batches.exchange_rate_type%TYPE,
    p_PaymentScheduleId      IN  ar_payment_schedules.payment_schedule_id%TYPE,
    p_InvoiceAmount          IN  NUMBER,
    p_InvoiceLineAmount      IN  NUMBER,
    p_ReceiptDate            IN  ar_cash_receipts.receipt_date%TYPE,
    p_GLDate                 IN  DATE,
--    p_USSGLTransactionCode   IN  ar_cash_receipts.ussgl_transaction_code%TYPE,
    p_org_id                 IN NUMBER,
    p_RemaingReceiptAmount   IN  OUT NOCOPY  NUMBER,
    p_ErrorCode              OUT NOCOPY  VARCHAR2,
    p_ErrorDesc              OUT NOCOPY  VARCHAR2,
    p_ErrorLoc               OUT NOCOPY  VARCHAR2
  ) IS
    l_module_name             VARCHAR2(30) := 'pay_the_invoice';

    l_AmountApplied          NUMBER;
    l_InvAmountApplied       NUMBER;
    l_ApplyCashRec           ApplyCashRecType;
    l_ConvertedInvoiceAmount NUMBER;
    l_ExchangeRate           NUMBER;
    l_OnAccountRec           OnAccountRecType;

    l_InvoiceAmount          NUMBER := p_InvoiceAmount;
    l_LineAmount             NUMBER;

  BEGIN
    p_ErrorCode  := g_SUCCESS;
    p_ErrorDesc  := NULL;
    p_ErrorLoc   := NULL;

    debug_init (g_PackageName, l_module_name);

    debug_msg (l_module_name, 'p_ReceiptNumber        = '||p_ReceiptNumber);
    debug_msg (l_module_name, 'p_CashReceiptId        = '||p_CashReceiptId);
    debug_msg (l_module_name, 'p_InvoiceId            = '||p_InvoiceId);
    debug_msg (l_module_name, 'p_InvoiceNumber        = '||p_InvoiceNumber);
    debug_msg (l_module_name, 'p_InvoiceLineId        = '||p_InvoiceLineId);
    debug_msg (l_module_name, 'p_CurrencyCode         = '||p_CurrencyCode);
    debug_msg (l_module_name, 'p_InvoiceCurrencyCode  = '||p_InvoiceCurrencyCode);
    debug_msg (l_module_name, 'p_ExchangeRateDate     = '||TO_CHAR(p_ExchangeRateDate, 'MM/DD/YYYY HH24:MI:SS'));
    debug_msg (l_module_name, 'p_ExchangeRate         = '||p_ExchangeRate);
    debug_msg (l_module_name, 'p_ExchangeRateType     = '||p_ExchangeRateType);
    debug_msg (l_module_name, 'p_PaymentScheduleId    = '||p_PaymentScheduleId);
    debug_msg (l_module_name, 'p_InvoiceAmount        = '||p_InvoiceAmount);
    debug_msg (l_module_name, 'p_ReceiptDate          = '||TO_CHAR(p_ReceiptDate, 'MM/DD/YYYY HH24:MI:SS'));
    debug_msg (l_module_name, 'p_GLDate               = '||TO_CHAR(p_GLDate, 'MM/DD/YYYY HH24:MI:SS'));
--    debug_msg (l_module_name, 'p_USSGLTransactionCode = '||p_USSGLTransactionCode);
    debug_msg (l_module_name, 'p_org_id = ' || p_org_id);
    debug_msg (l_module_name, 'p_RemaingReceiptAmount = '||p_RemaingReceiptAmount);


    IF (p_InvoiceCurrencyCode <> p_CurrencyCode) THEN
      l_ExchangeRate := p_ExchangeRate;
    ELSE
      l_ExchangeRate := NULL;
    END IF;

    IF (p_InvoiceLineId IS NOT NULL ) THEN
      BEGIN
        SELECT ctl.extended_amount * nvl(tl.relative_amount,1)/ nvl(t.base_amount,1) original_line_amount
          INTO l_LineAmount
          FROM ra_customer_trx_lines ctl ,
               ra_terms t,
               ra_terms_lines tl,
               ar_payment_schedules ps
         WHERE ps.payment_schedule_id = p_PaymentScheduleId
           AND ctl.customer_trx_id = p_InvoiceId
           AND ctl.line_type = 'LINE'
           AND tl.term_id(+) = ps.term_id
           AND tl.sequence_num(+) = ps.terms_sequence_number
           AND t.term_id(+) = tl.term_id
           AND ctl.customer_trx_line_id = p_InvoiceLineId;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_LineAmount := 0;
        debug_msg (l_module_name, 'No Data Found for payment_schedule_id <'||p_PaymentScheduleId||'>');
      WHEN OTHERS THEN
        p_ErrorCode := g_FAILURE;
        p_ErrorDesc := SQLERRM;
        p_ErrorLoc  := 'SELECT ra_customer_trx_lines, ra_terms...';
        error
        (
          p_error_type => p_ErrorCode,
          p_pgm        => l_module_name,
          p_msg        => p_ErrorDesc,
          p_loc        => p_ErrorLoc
        );
        debug_msg (l_module_name, p_ErrorDesc||'at location'||p_ErrorLoc);
      END;

      debug_msg (l_module_name, 'adjusted l_lineAmount  = '||l_lineAmount);

      IF (l_InvoiceAmount > l_LineAmount) THEN
        l_InvoiceAmount := l_LineAmount;
      END IF;
    END IF;

    l_ConvertedInvoiceAmount := l_InvoiceAmount*NVL(l_ExchangeRate, 1);
    debug_msg(l_module_name, 'l_convertedInvoiceAmount = '||l_convertedInvoiceAmount);

    IF (p_ErrorCode = g_SUCCESS) THEN
      IF (p_RemaingReceiptAmount <= l_ConvertedInvoiceAmount) THEN
        l_AmountApplied := p_RemaingReceiptAmount;
        p_RemaingReceiptAmount := 0;
      ELSE
        l_AmountApplied := l_ConvertedInvoiceAmount;
        p_RemaingReceiptAmount := p_RemaingReceiptAmount - l_ConvertedInvoiceAmount;
      END IF;

      l_InvAmountApplied := l_AmountApplied / NVL(l_ExchangeRate, 1);

      IF (p_InvoiceCurrencyCode <> p_CurrencyCode) THEN
        l_ApplyCashRec.amount_applied              := l_InvAmountApplied;
        l_ApplyCashRec.amount_applied_from         := l_AmountApplied;
      ELSE
        l_ApplyCashRec.amount_applied              := l_AmountApplied;
      END IF;

      l_ApplyCashRec.cash_receipt_id             := p_CashReceiptId;
      l_ApplyCashRec.customer_trx_id             := p_InvoiceId;
      l_ApplyCashRec.customer_trx_line_id        := p_InvoiceLineId;
      l_ApplyCashRec.line_number                 := p_LineNumber;
      l_ApplyCashRec.applied_payment_schedule_id := p_PaymentScheduleId;
      l_ApplyCashRec.apply_date                  := p_ReceiptDate;
      l_ApplyCashRec.apply_gl_date               := p_GLDate;
--      l_ApplyCashRec.ussgl_transaction_code      := p_USSGLTransactionCode;
      l_ApplyCashRec.org_id                      := p_org_id;
      l_ApplyCashRec.trans_to_receipt_rate       := l_ExchangeRate;


      apply_cash_receipt
      (
        p_ApplyCashRec       => l_ApplyCashRec,
        p_ErrorCode          => p_ErrorCode,
        p_ErrorDesc          => p_ErrorDesc,
        p_ErrorLoc           => p_ErrorLoc
      );
    END IF;

    IF (p_ErrorCode = g_SUCCESS) THEN
      g_OutCashReceipts.total_applications := g_OutCashReceipts.total_applications + 1;
      g_OutReceiptApplications(g_OutCashReceipts.total_applications).status := 'A';
      g_OutReceiptApplications(g_OutCashReceipts.total_applications).invoice_number := p_InvoiceNumber;
      g_OutReceiptApplications(g_OutCashReceipts.total_applications).line_number := p_LineNumber;
      g_OutReceiptApplications(g_OutCashReceipts.total_applications).applied_amount := l_AmountApplied;
      g_OutReceiptApplications(g_OutCashReceipts.total_applications).invoice_type := 'INVOICE';
      g_OutReceiptApplications(g_OutCashReceipts.total_applications).amt_applied_in_inv_curr := l_InvAmountApplied;
      g_OutReceiptApplications(g_OutCashReceipts.total_applications).invoice_currency := p_InvoiceCurrencyCode;
      g_OutReceiptApplications(g_OutCashReceipts.total_applications).invoice_amount_due := l_InvoiceAmount;
      g_OutReceiptApplications(g_OutCashReceipts.total_applications).applied_currency := p_CurrencyCode;
      g_OutReceiptApplications(g_OutCashReceipts.total_applications).exchange_rate := NVL(l_ExchangeRate, 1);
    END IF;

/*  commenting this section out because this is not needed currently.
    caused a problem when processing a mfar split term invoice.
    IF (p_ErrorCode = g_SUCCESS) THEN
      IF ((p_InvoiceLineId IS NOT NULL) AND (p_RemaingReceiptAmount > 0)) THEN


        --------------------------------------------------------------------------------------
        -- Initialize the Report Variables for the On Account Application                   --
        --------------------------------------------------------------------------------------
        l_OnAccountRec.cash_receipt_id        := P_CashReceiptId;
        l_OnAccountRec.amount_applied         := p_RemaingReceiptAmount;
        l_OnAccountRec.apply_date             := p_ReceiptDate;
        l_OnAccountRec.apply_gl_date          := p_GLDate;
        l_OnAccountRec.ussgl_transaction_code := p_USSGLTransactionCode;


        --------------------------------------------------------------------------------------
        -- Apply the remaining amount to On Account                                         --
        --------------------------------------------------------------------------------------
        apply_on_account
        (
          p_OnAccountRec => l_OnAccountRec,
          p_ErrorCode    => p_ErrorCode,
          p_ErrorDesc    => p_ErrorDesc,
          p_ErrorLoc     => p_ErrorLoc
        );

        IF (p_ErrorCode = g_SUCCESS) THEN
          g_OutCashReceipts.total_applications := g_OutCashReceipts.total_applications + 1;
          g_OutReceiptApplications(g_OutCashReceipts.total_applications).status := 'A';
          g_OutReceiptApplications(g_OutCashReceipts.total_applications).invoice_number := 'On Account';
          g_OutReceiptApplications(g_OutCashReceipts.total_applications).line_number := NULL;
          g_OutReceiptApplications(g_OutCashReceipts.total_applications).applied_amount := p_RemaingReceiptAmount;
          g_OutReceiptApplications(g_OutCashReceipts.total_applications).invoice_type := 'ON ACCOUNT';
          g_OutReceiptApplications(g_OutCashReceipts.total_applications).amt_applied_in_inv_curr := p_RemaingReceiptAmount;
          g_OutReceiptApplications(g_OutCashReceipts.total_applications).invoice_currency := '';
          g_OutReceiptApplications(g_OutCashReceipts.total_applications).invoice_amount_due := 0;
          g_OutReceiptApplications(g_OutCashReceipts.total_applications).applied_currency := '';
          g_OutReceiptApplications(g_OutCashReceipts.total_applications).exchange_rate := '';
        END IF;

        p_RemaingReceiptAmount := 0;

      END IF;
    END IF;
*/
    debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  EXCEPTION
    WHEN OTHERS THEN
      p_ErrorCode := g_FAILURE;
      p_ErrorDesc := SQLERRM;
      p_ErrorLoc  := 'Final Exception';
      error
      (
        p_error_type => p_ErrorCode,
        p_pgm        => l_module_name,
        p_msg        => p_ErrorDesc,
        p_loc        => p_ErrorLoc
      );
      debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  END pay_the_invoice;
  --*    Commented Out get_receipt_txn_code procedure for Transaction Codes Obsoletion     *--
  --****************************************************************************************--
  --*          Name : get_receipt_txn_code                                                 *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This Procedure is used to get the Receipt Transaction Code from the  *--
  --*               : mapping table for a Debit Memo.                                      *--
  --*    Parameters : p_DebitMemoId          IN  Debit Memo Id                             *--
  --*               :  p_EffectiveDate        IN  Effective Date                            *--
  --*               : p_ReceiptTxnCode       OUT Receipt Transaction Code                  *--
  --*               : p_ErrorCode            OUT The Error Code                            *--
  --*               : p_ErrorDesc            OUT The Error Description                     *--
  --*               : p_ErrorLoc             OUT The Error Location                        *--
  --*   Global Vars : g_SUCCESS              READ                                          *--
  --*   Called from : pay_debit_memos                                                      *--
  --*         Calls : debug_msg                                                            *--
  --*               : debug_init                                                           *--
  --*               : debug_exit                                                           *--
  --*               : error                                                                *--
  --*               : log_msg                                                              *--
  --*   Tables Used : ra_cust_trx_line_gl_dist SELECT                                      *--
  --*               : fv_tc_map_dtl            SELECT                                      *--
  --*               : fv_tc_map_hdr            SELECT                                      *--
  --*         Logic : 1. Get the Transaction Code from the Revenue side of the Debit Memo  *--
  --*               :    transcation.                                                      *--
  --*               : 2. Use that to get the receipt transaction code from the mapping     *--
  --*               :    table fv_tc_map_dtl.                                              *--
  --*               : 3. Return this value                                                 *--
  --****************************************************************************************--
/*--- Commented Out get_receipt_txn_code procedure for Transaction Codes Obsoletion
  PROCEDURE get_receipt_txn_code
  (
    p_DebitMemoId          IN  VARCHAR2,
    p_EffectiveDate        IN  DATE,
    p_ReceiptTxnCode       OUT NOCOPY  VARCHAR2,
    p_ErrorCode            OUT NOCOPY  VARCHAR2,
    p_ErrorDesc            OUT NOCOPY  VARCHAR2,
    p_ErrorLoc             OUT NOCOPY  VARCHAR2
  ) IS
    l_module_name           VARCHAR2(30) := 'get_receipt_txn_code';

    l_DebitMemoTxnCode     ra_cust_trx_line_gl_dist.ussgl_transaction_code%TYPE;

  BEGIN
    p_ErrorCode  := g_SUCCESS;
    p_ErrorDesc  := NULL;
    p_ErrorLoc   := NULL;

    debug_init (g_PackageName, l_module_name);

    BEGIN
     SELECT DISTINCT ussgl_transaction_code
       INTO l_DebitMemoTxnCode
       FROM ra_cust_trx_line_gl_dist
      WHERE customer_trx_id = p_DebitMemoId
        AND account_class = 'REV';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_DebitMemoTxnCode := NULL;
        debug_msg (l_module_name, 'No Data Found for p_DebitMemoId <'||p_DebitMemoId||'>');
      WHEN OTHERS THEN
        p_ErrorCode := g_FAILURE;
        p_ErrorDesc := SQLERRM;
        p_ErrorLoc  := 'SELECT ra_cust_trx_line_gl_dist';
        error
        (
          p_error_type => p_ErrorCode,
          p_pgm        => l_module_name,
          p_msg        => p_ErrorDesc,
          p_loc        => p_ErrorLoc
        );
        debug_msg (l_module_name, p_ErrorDesc||'at location'||p_ErrorLoc);
    END;


    IF (p_ErrorCode = g_SUCCESS) THEN
      debug_msg (l_module_name, 'Debit Memo Txn Code is <'||l_DebitMemoTxnCode||'>');
      log_msg (l_module_name,'Trying to Map Debit Memo Txn Code '||l_DebitMemoTxnCode);
      BEGIN
        SELECT receipt_txn_code
          INTO p_ReceiptTxnCode
          FROM fv_tc_map_dtl ftmd,
               fv_tc_map_hdr ftmh
         WHERE ftmh.document_type = 'RECEIPT'
           AND ftmd.tc_map_hdr_id = ftmh.tc_map_hdr_id
           AND ftmd.debit_memo_txn_code = l_DebitMemoTxnCode
           AND p_EffectiveDate BETWEEN ftmd.start_date AND NVL(ftmd.end_date, SYSDATE);
        log_msg (l_module_name,'Debit Memo Txn Code '||l_DebitMemoTxnCode||' mapped to Receipt Txn '||p_ReceiptTxnCode);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          p_ReceiptTxnCode := NULL;
          debug_msg (l_module_name, 'No Data Found for Debit Memo Txn Code <'||l_DebitMemoTxnCode||'>');
          log_msg (l_module_name,'Could not map Debit Memo Txn Code '||l_DebitMemoTxnCode);
        WHEN OTHERS THEN
          p_ErrorCode := g_FAILURE;
          p_ErrorDesc := SQLERRM;
          p_ErrorLoc  := 'SELECT fv_tc_map_dtl';
          error
          (
            p_error_type => p_ErrorCode,
            p_pgm        => l_module_name,
            p_msg        => p_ErrorDesc,
            p_loc        => p_ErrorLoc
          );
          debug_msg (l_module_name, p_ErrorDesc||'at location'||p_ErrorLoc);
      END;
    END IF;

    debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  EXCEPTION
    WHEN OTHERS THEN
      p_ErrorCode := g_FAILURE;
      p_ErrorDesc := SQLERRM;
      p_ErrorLoc  := 'Final Exception';
      error
      (
        p_error_type => p_ErrorCode,
        p_pgm        => l_module_name,
        p_msg        => p_ErrorDesc,
        p_loc        => p_ErrorLoc
      );
      debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  END get_receipt_txn_code;
-------------------- End of Cmmnets -----------------------------------------------*/
  --****************************************************************************************--
  --*          Name : pay_debit_memos                                                      *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This Procedure Pays of all the debit memos for an invoice            *--
  --*    Parameters : p_ReceiptNumber        IN  The Receipt Number                        *--
  --*               : p_CashReceiptId        IN  The Cash Receipt Id                       *--
  --*               : p_InvoiceId            IN  Invoice Id                                *--
  --*               : p_CurrencyCode         IN  Currency Code                             *--
  --*               : p_ExchangeRateDate     IN  Exchange Rate Date                        *--
  --*               : p_ExchangeRate         IN  Exchange Rate                             *--
  --*               : p_ExchangeRateType     IN  Exchange Rate Type                        *--
  --*               : p_ReceiptDate          IN  Receipt Date                              *--
  --*               : p_gldate               IN  GL Date                                   *--
  --*               : p_RemaingReceiptAmount IN  OUT The remaining rcpt amt after applying *--
  --*               : p_ErrorCode            OUT The Error Code                            *--
  --*               : p_ErrorDesc            OUT The Error Description                     *--
  --*               : p_ErrorLoc             OUT The Error Location                        *--
  --*   Global Vars : g_SUCCESS              READ                                          *--
  --*               : g_OutInvoiceDebitMemos WRITE                                         *--
  --*               : g_OutCashReceipts      READ WRITE                                    *--
  --*   Called from : process_receipts                                                     *--
  --*         Calls : get_receipt_txn_code                                                 *--
  --*               : unapply_if_already_applied                                           *--
  --*               : apply_cash_receipt                                                   *--
  --*               : debug_msg                                                            *--
  --*               : debug_init                                                           *--
  --*               : debug_exit                                                           *--
  --*               : error                                                                *--
  --*               : log_msg                                                              *--
  --*   Tables Used : ra_customer_trx            SELECT                                    *--
  --*               : ar_payment_schedules       SELECT                                    *--
  --*               : fv_finance_charge_controls SELECT                                    *--
  --*         Logic : 1. Loop and Process the following steps for every Debit Memos that   *--
  --*               :    exist for the invoice (That are due)                              *--
  --*               : 2. If the debit memo was procesed earlier using the same cash        *--
  --*               :    cash receipt, unapply the old application and apply once again    *--
  --*               : 3. Call the program get_receipt_txn_code to get the Debit Memo Txn   *--
  --*               :    code given the receipt transaction code                           *--
  --*               : 4. Convert the Debit Memo Amount into the Receipt Currency for       *--
  --*               :    finding out the application amount.                               *--
  --*               : 5. Populate the structure required to call the API for application   *--
  --*               : 6. Call the program apply_cash_receipt to Apply the receipt          *--
  --*               : 7. Populate the Report Varaibles for output                          *--
  --****************************************************************************************--
  PROCEDURE pay_debit_memos
  (
    p_ReceiptNumber        IN  fv_interim_cash_receipts.receipt_number%TYPE,
    p_CashReceiptId        IN  ar_cash_receipts_all.cash_receipt_id%TYPE,
    p_InvoiceId            IN  ra_customer_trx_all.customer_trx_id%TYPE,
    p_CurrencyCode         IN  fv_interim_cash_receipts.currency_code%TYPE,
    p_ExchangeRateDate     IN  ar_batches.exchange_date%TYPE,
    p_ExchangeRate         IN  ar_batches.exchange_rate%TYPE,
    p_ExchangeRateType     IN  ar_batches.exchange_rate_type%TYPE,
    p_ReceiptDate          IN  ar_cash_receipts.receipt_date%TYPE,
    p_gldate               IN  DATE,
    p_RemaingReceiptAmount IN  OUT NOCOPY  NUMBER,
    p_ErrorCode            OUT NOCOPY  VARCHAR2,
    p_ErrorDesc            OUT NOCOPY  VARCHAR2,
    p_ErrorLoc             OUT NOCOPY  VARCHAR2
  ) IS
    l_module_name             VARCHAR2(30) := 'pay_debit_memos';

    l_AmountApplied          NUMBER;
    l_InvAmountApplied       NUMBER;
    l_ApplyCashRec           ApplyCashRecType;
--    l_USSGLTransactionCode   ar_cash_receipts.ussgl_transaction_code%TYPE;
    l_ConvertedAmountDue     NUMBER;
    l_denominator            NUMBER;
    l_numerator              NUMBER;
    l_ExchangeRate           ar_batches.exchange_rate%TYPE;
    l_UnAppliedAmount        NUMBER := 0;

    CURSOR DebitMemo_Cur (c_invoice_id NUMBER) IS
    SELECT distinct aps.customer_trx_id invoice_id,
           aps.amount_due_remaining amount_due,
           fcc.priority,
           aps.payment_schedule_id,
           aps.cust_trx_type_id,
           aps.due_date,
           rct.trx_date invoice_date,
           rct.trx_number invoice_number,
           rct.invoice_currency_code
      FROM ra_customer_trx rct,
           ar_payment_schedules aps,
           fv_finance_charge_controls fcc
     WHERE rct.related_customer_trx_id = c_invoice_id
       AND aps.customer_trx_id = rct.customer_trx_id
       AND rct.interface_header_attribute3 = fcc.charge_type
       AND aps.amount_due_remaining > 0
     ORDER BY fcc.priority ;

  BEGIN
    p_ErrorCode  := g_SUCCESS;
    p_ErrorDesc  := NULL;
    p_ErrorLoc   := NULL;

    debug_init (g_PackageName, l_module_name);

    debug_msg (l_module_name, 'p_ReceiptNumber        = '||p_ReceiptNumber);
    debug_msg (l_module_name, 'p_CashReceiptId        = '||p_CashReceiptId);
    debug_msg (l_module_name, 'p_InvoiceId            = '||p_InvoiceId);
    debug_msg (l_module_name, 'p_CurrencyCode         = '||p_CurrencyCode);
    debug_msg (l_module_name, 'p_ExchangeRateDate     = '||TO_CHAR(p_ExchangeRateDate, 'MM/DD/YYYY HH24:MI:SS'));
    debug_msg (l_module_name, 'p_ExchangeRate         = '||p_ExchangeRate);
    debug_msg (l_module_name, 'p_ExchangeRateType     = '||p_ExchangeRateType);
    debug_msg (l_module_name, 'p_ReceiptDate          = '||TO_CHAR(p_ReceiptDate, 'MM/DD/YYYY HH24:MI:SS'));
    debug_msg (l_module_name, 'p_gldate               = '||TO_CHAR(p_gldate, 'MM/DD/YYYY HH24:MI:SS'));
    debug_msg (l_module_name, 'p_RemaingReceiptAmount = '||p_RemaingReceiptAmount);


    --------------------------------------------------------------------------------------
    -- Get the Debit Memos for the Invoice                                              --
    --------------------------------------------------------------------------------------
    FOR DebitMemo_Rec IN DebitMemo_Cur (p_InvoiceId) LOOP
      debug_msg (l_module_name, 'Processing Debit Memo <'||DebitMemo_Rec.invoice_number||'>');
      log_msg (l_module_name,'Processing Debit Memo <'||DebitMemo_Rec.invoice_number||'>');

      --------------------------------------------------------------------------------------
      -- The API does not allow duplicate applications on the same invoice.               --
      -- To avoid that, see if the debit memo was applied earlier due to a partial        --
      -- application in the same Cash Receipt. If so unapply that amount and              --
      -- apply once again with the total amount                                           --
      --------------------------------------------------------------------------------------
      unapply_if_already_applied
      (
        p_ReceiptId            => p_CashReceiptId,
        p_InvoiceId            => DebitMemo_Rec.invoice_id,
        p_UnAppliedAmount      => l_UnAppliedAmount,
        p_ErrorCode            => p_ErrorCode,
        p_ErrorDesc            => p_ErrorDesc,
        p_ErrorLoc             => p_ErrorLoc
      );

      IF (p_ErrorCode = g_SUCCESS) THEN
        IF (l_UnAppliedAmount <> 0) THEN
          debug_msg (l_module_name, 'Debit Memo Application <'||DebitMemo_Rec.invoice_number||'> Reversed for amount '||l_UnAppliedAmount||' for reapplication');
          --------------------------------------------------------------------------------------
          -- Change the Original Report Line in Output to Deleted                             --
          --------------------------------------------------------------------------------------
          del_report_line_for_a_receipt
          (
            p_InvoiceNumber        => DebitMemo_Rec.invoice_number,
            p_ErrorCode            => p_ErrorCode,
            p_ErrorDesc            => p_ErrorDesc,
            p_ErrorLoc             => p_ErrorLoc
          );
        END IF;
      END IF;

/*--- Commented Out for Transaction Codes Obsoletion-----------------------
      IF (p_ErrorCode = g_SUCCESS) THEN
        debug_msg (l_module_name, 'Calling get_receipt_txn_code');
        --------------------------------------------------------------------------------------
        -- Get the Transaction Code from the Mapping Table                                  --
        --------------------------------------------------------------------------------------
        get_receipt_txn_code
        (
          p_DebitMemoId     => DebitMemo_Rec.invoice_id,
          p_EffectiveDate   => DebitMemo_Rec.invoice_date,
          p_ReceiptTxnCode  => l_USSGLTransactionCode,
          p_ErrorCode       => p_ErrorCode,
          p_ErrorDesc       => p_ErrorDesc,
          p_ErrorLoc        => p_ErrorLoc
        );
      END IF;
--------End of Comments--------------------------------------------------*/

      IF (p_ErrorCode = g_SUCCESS) THEN
        --------------------------------------------------------------------------------------
        -- Convert the Debit Memo Invoice Amount into the Receipt Currency Code.            --
        --------------------------------------------------------------------------------------
        debug_msg (l_module_name, 'DebitMemo_Rec.invoice_currency_code='||DebitMemo_Rec.invoice_currency_code);
        IF (DebitMemo_Rec.invoice_currency_code <> p_CurrencyCode) THEN
          l_ExchangeRate := p_ExchangeRate;
        ELSE
          l_ExchangeRate := NULL;
        END IF;

        l_ConvertedAmountDue := DebitMemo_Rec.amount_due*NVL(l_ExchangeRate, 1);
        debug_msg (l_module_name, 'Converted Amount Due is '||l_ConvertedAmountDue);

        --------------------------------------------------------------------------------------
        -- Get the amount that needs receipt application                                    --
        -- If the Remaining Receipt Amount is less than the Amount due then the whole       --
        -- receipt amount is applied, else the amount due will be applied and the remaining --
        -- receipt amount will be reduced.                                                  --
        --------------------------------------------------------------------------------------
        IF (p_RemaingReceiptAmount <= l_ConvertedAmountDue) THEN
          l_AmountApplied := p_RemaingReceiptAmount;
          p_RemaingReceiptAmount := 0;
        ELSE
          l_AmountApplied := l_ConvertedAmountDue;
          p_RemaingReceiptAmount := p_RemaingReceiptAmount - l_ConvertedAmountDue;
        END IF;


        --------------------------------------------------------------------------------------
        -- Prepare the structure to call the API to apply against a receipt                 --
        --------------------------------------------------------------------------------------
        l_InvAmountApplied := l_AmountApplied/NVL(l_ExchangeRate, 1);

        IF (DebitMemo_Rec.invoice_currency_code <> p_CurrencyCode) THEN
          l_ApplyCashRec.amount_applied              := NULL;--l_InvAmountApplied+l_UnAppliedAmount;
          l_ApplyCashRec.amount_applied_from         := l_AmountApplied+l_UnAppliedAmount;
        ELSE
          l_ApplyCashRec.amount_applied              := l_AmountApplied+l_UnAppliedAmount;
        END IF;

        l_ApplyCashRec.cash_receipt_id             := p_CashReceiptId;
        l_ApplyCashRec.customer_trx_id             := DebitMemo_Rec.invoice_id;
        l_ApplyCashRec.customer_trx_line_id        := NULL;
        l_ApplyCashRec.applied_payment_schedule_id := DebitMemo_Rec.payment_schedule_id;
        l_ApplyCashRec.apply_date                  := p_ReceiptDate;
        l_ApplyCashRec.apply_gl_date               := p_GLDate;
--        l_ApplyCashRec.ussgl_transaction_code      := l_USSGLTransactionCode;
        l_ApplyCashRec.trans_to_receipt_rate       := l_ExchangeRate;

        --------------------------------------------------------------------------------------
        -- This program calls the API for receipt application                               --
        --------------------------------------------------------------------------------------
        apply_cash_receipt
        (
          p_ApplyCashRec       => l_ApplyCashRec,
          p_ErrorCode          => p_ErrorCode,
          p_ErrorDesc          => p_ErrorDesc,
          p_ErrorLoc           => p_ErrorLoc
        );

        IF (p_ErrorCode = g_SUCCESS) THEN
          --------------------------------------------------------------------------------------
          -- Process the Structure that generates the report for Output                       --
          --------------------------------------------------------------------------------------
          g_OutCashReceipts.total_applications := g_OutCashReceipts.total_applications + 1;
          g_OutReceiptApplications(g_OutCashReceipts.total_applications).status := 'A';
          g_OutReceiptApplications(g_OutCashReceipts.total_applications).invoice_number := DebitMemo_Rec.invoice_number;
          g_OutReceiptApplications(g_OutCashReceipts.total_applications).line_number := NULL;
          g_OutReceiptApplications(g_OutCashReceipts.total_applications).amt_applied_in_inv_curr := l_InvAmountApplied+l_UnAppliedAmount;
          g_OutReceiptApplications(g_OutCashReceipts.total_applications).invoice_currency := DebitMemo_Rec.invoice_currency_code;
          g_OutReceiptApplications(g_OutCashReceipts.total_applications).invoice_amount_due := DebitMemo_Rec.amount_due;
          g_OutReceiptApplications(g_OutCashReceipts.total_applications).applied_amount := l_AmountApplied+l_UnAppliedAmount;
          g_OutReceiptApplications(g_OutCashReceipts.total_applications).applied_currency := p_CurrencyCode;
          g_OutReceiptApplications(g_OutCashReceipts.total_applications).exchange_rate := NVL(l_ExchangeRate, 1);
          g_OutReceiptApplications(g_OutCashReceipts.total_applications).invoice_type := 'DEBIT MEMO';
        END IF;
      END IF;

      IF (p_ErrorCode <> g_SUCCESS) THEN
        EXIT;
      END IF;

      IF (p_RemaingReceiptAmount <= 0) THEN
        EXIT;
      END IF;
    END LOOP;

    debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  EXCEPTION
    WHEN OTHERS THEN
      p_ErrorCode := g_FAILURE;
      p_ErrorDesc := SQLERRM;
      p_ErrorLoc  := 'Final Exception';
      error
      (
        p_error_type => p_ErrorCode,
        p_pgm        => l_module_name,
        p_msg        => p_ErrorDesc,
        p_loc        => p_ErrorLoc
      );
      debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  END pay_debit_memos;


  --****************************************************************************************--
  --*          Name : process_receipts                                                     *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This is the procedure which starts processing a receipt batch        *--
  --*    Parameters : p_BatchRec    IN  The Complete record in fv_ar_batches for a batch_id*--
  --*               : p_ErrorCode   OUT The Error Code                                     *--
  --*               : p_ErrorDesc   OUT The Error Description                              *--
  --*               : p_ErrorLoc    OUT The Error Location                                 *--
  --*   Global Vars : g_SUCCESS              READ                                          *--
  --*               : g_OutCashReceipts      WRITE                                         *--
  --*   Called from : main                                                                 *--
  --*         Calls : write_report_header                                                  *--
  --*               : insert_ar_batch                                                      *--
  --*               : create_cash_receipt                                                  *--
  --*               : pay_debit_memos                                                      *--
  --*               : pay_the_invoice                                                      *--
  --*               : apply_on_account                                                     *--
  --*               : write_report_for_a_receipt                                           *--
  --*               : debug_msg                                                            *--
  --*               : debug_init                                                           *--
  --*               : debug_exit                                                           *--
  --*               : error                                                                *--
  --*               : log_msg                                                              *--
  --*   Tables Used : fv_interim_cash_receipts SELECT                                      *--
  --*               : ra_customer_trx          SELECT                                      *--
  --*               : ra_customer_trx_lines    SELECT                                      *--
  --*               : ra_customers             SELECT                                      *--
  --*               : ar_payment_schedules     SELECT                                      *--
  --*               : ra_cust_trx_types        SELECT                                      *--
  --*         Logic : 1. Write the Batch Information into the output report.               *--
  --*               : 2. Insert the fv_ar_batch details into the table ar_batches by       *--
  --*               :    calling the procedure insert_ar_batch                             *--
  --*               : 3. For each of the receipt in the batch fv_ar_batches do the         *--
  --*               :    following                                                         *--
  --*               : 4. Initialize the receipt report variables                           *--
  --*               : 5. If the invoice id is filled up, use the invoice and ignore the    *--
  --*               :    customer details as the receipt is against the invoice, else the  *--
  --*               :    receipt is made against all the invoices against the customer.    *--
  --*               : 6. Create a Cash Receipt. This Cash Receipt will be used for all the *--
  --*               :    receipt applications towards debit memos and the original invoices*--
  --*               : 7. Get the outstanding Invoice details, either for the invoice or    *--
  --*               :    for the customer. Do the following for each invoice obtained      *--
  --*               : 8. First Pay of all the outstanding debit memos                      *--
  --*               : 9. Next pay of the invoice                                           *--
  --*               :10. If there is any balance left, apply it against On Account         *--
  --*               :11. Write the output report for a receipt                             *--
  --****************************************************************************************--
  PROCEDURE process_receipts
  (
    p_BatchRec           IN  fv_ar_batches%ROWTYPE,
    p_ErrorCode          OUT NOCOPY  VARCHAR2,
    p_ErrorDesc          OUT  NOCOPY VARCHAR2,
    p_ErrorLoc           OUT NOCOPY  VARCHAR2
  ) IS
    l_module_name             VARCHAR2(30) := 'process_receipts';

    l_SiteUseId              ra_customer_trx.bill_to_site_use_id%TYPE;
    l_CustomerNumber         hz_parties.party_id%TYPE;
    l_RemainingReceiptAmount fv_interim_cash_receipts.amount%TYPE;
    l_CashReceiptId          ar_cash_receipts.cash_receipt_id%TYPE;

    l_CreateCashRec          CreateCashRecType;
    l_NullCreateCashRec      CreateCashRecType;
    l_OnAccountRec           OnAccountRecType;

    l_OldInvoiceId           NUMBER := 0;

    CURSOR C_DistinctReceipts_Cursor
    (
      c_batch_id NUMBER
    ) IS
SELECT ficr.receipt_number,
           ficr.customer_id,
           hzp.party_name customer_name,
           trunc(ficr.receipt_date) receipt_date,
           ficr.site_use_id,
           sum(ficr.amount) amount
      FROM fv_interim_cash_receipts ficr,
           hz_parties hzp, hz_cust_accounts hzca
     WHERE ficr.batch_id = c_batch_id
	   AND hzp.party_id = hzca.party_id
       AND ficr.customer_id = hzca.cust_account_id
     GROUP BY ficr.receipt_number,
              ficr.customer_id,
              hzp.party_name,
              ficr.receipt_date,
              ficr.site_use_id
     ORDER BY ficr.receipt_number;

    CURSOR C_Receipts_Cursor
    (
      c_batch_id       NUMBER,
      c_receipt_number VARCHAR2,
      c_customer_id    NUMBER,
      c_receipt_date   DATE
    ) IS
	SELECT ficr.batch_id,
           ficr.currency_code,
           ficr.receipt_number,
           ficr.customer_id,
           ficr.special_type,
           ficr.status,
           ficr.customer_trx_id,
           trunc(ficr.gl_date) gl_date,
           SUM(ficr.amount) amount,
           ficr.site_use_id,
           ficr.ce_bank_acct_use_id,    --PSKI changes for BA and MOAC Uptake
           ficr.set_of_books_id,
           trunc(ficr.receipt_date) receipt_date,
           ficr.related_invoice_id,
           ficr.receipt_method_id,
           ficr.payment_schedule_id,
--           ficr.ussgl_transaction_code,
           ficr.org_id,
           ficr.customer_trx_line_id,
           rct.trx_number invoice_number,
           rct.invoice_currency_code,
           rct.exchange_rate_type invoice_exchange_rate_type,
           rctl.line_number line_number,
           hzp.party_name,
           rctl.extended_amount line_amount
      FROM fv_interim_cash_receipts ficr,
           ra_customer_trx          rct,
           ra_customer_trx_lines    rctl,
           hz_parties hzp, hz_cust_accounts hzca
  WHERE ficr.batch_id = c_batch_id
      AND  hzp.party_id = hzca.party_id
       AND ficr.receipt_number = c_receipt_number
       AND ficr.customer_id = c_customer_id
       AND ficr.receipt_date = c_receipt_date
       AND rct.customer_trx_id (+) = ficr.customer_trx_id
       AND rctl.customer_trx_line_id (+) = ficr.customer_trx_line_id
       AND hzca.cust_account_id (+) =ficr.customer_id
 GROUP BY
           ficr.batch_id,
           ficr.currency_code,
           ficr.receipt_number,
           ficr.customer_id,
           ficr.special_type,
           ficr.status,
           ficr.customer_trx_id,
           trunc(ficr.gl_date),
           ficr.site_use_id,
           ficr.ce_bank_acct_use_id,    --PSKI changes for BA and MOAC Uptake
           ficr.set_of_books_id,
           trunc(ficr.receipt_date) ,
           ficr.related_invoice_id,
           ficr.receipt_method_id,
           ficr.payment_schedule_id,
--           ficr.ussgl_transaction_code,
           ficr.org_id,
           ficr.customer_trx_line_id,
           rct.trx_number ,
           rct.invoice_currency_code,
           rct.exchange_rate_type ,
           rctl.line_number ,
           hzp.party_name,
           rctl.extended_amount

    ORDER BY rct.trx_number ASC,
              rctl.line_number DESC;

    CURSOR C_Invoices_Cursor
    (
      c_cust_no    NUMBER,
      c_invoice_id NUMBER,
      c_sob        NUMBER,
      c_currency   VARCHAR2,
      c_site_use_id NUMBER
    ) IS
    SELECT aps.customer_trx_id,
           aps.amount_due_remaining amount_due,
           aps.payment_schedule_id,
           aps.cust_trx_type_id,
           aps.due_date,
           aps.trx_number invoice_number,
           rac.invoice_currency_code
      FROM ar_payment_schedules aps,
           ra_cust_trx_types    rct,
           ra_customer_trx      rac
     WHERE aps.amount_due_remaining > 0
       AND aps.status = 'OP'
       AND aps.customer_id      = NVL(c_cust_no,aps.customer_id)
       AND aps.customer_trx_id  = NVL(c_invoice_id,aps.customer_trx_id)
       AND aps.cust_trx_type_id = rct.cust_trx_type_id
       AND rct.type             = 'INV'
       AND aps.customer_trx_id  = rac.customer_trx_id
       AND rac.bill_to_site_use_id = nvl(c_site_use_id,rac.bill_to_site_use_id)
       AND rac.set_of_books_id  = c_sob
       AND rac.invoice_currency_code = c_currency
     ORDER BY aps.customer_trx_id,
              payment_schedule_id;

  BEGIN
    p_ErrorCode  := g_SUCCESS;
    p_ErrorDesc  := NULL;
    p_ErrorLoc   := NULL;

    debug_init (g_PackageName, l_module_name);

    debug_msg (l_module_name, 'Calling write_report_header');
    --------------------------------------------------------------------------------------
    -- Write the Report header. i.e. the batch details will be written at this point    --
    --------------------------------------------------------------------------------------
    write_report_header
    (
      p_BatchRec             => p_BatchRec,
      p_ErrorCode            => p_ErrorCode,
      p_ErrorDesc            => p_ErrorDesc,
      p_ErrorLoc             => p_ErrorLoc
    );

    IF (p_ErrorCode = g_SUCCESS) THEN
      debug_msg (l_module_name, 'Calling insert_ar_batch');
      --------------------------------------------------------------------------------------
      -- Insert the fv_ar_batch details into ar_batch table. Currently there is no API    --
      -- that does this. Until then a direct insert into the table is done                --
      --------------------------------------------------------------------------------------
      insert_ar_batch
      (
        p_BatchRec  => p_BatchRec,
        p_ErrorCode => p_ErrorCode,
        p_ErrorDesc => p_ErrorDesc,
        p_ErrorLoc  => p_ErrorLoc
      );
    END IF;

    IF (p_ErrorCode = g_SUCCESS) THEN

     --------------------------------------------------------------------------------------
     -- Get Distinct Cash Receipts                                                       --
     --------------------------------------------------------------------------------------
      FOR DisctinctReceiptsRec IN C_DistinctReceipts_Cursor (p_BatchRec.batch_id) LOOP

        --------------------------------------------------------------------------------------
        -- Initialize Receipt Report Variables                                              --
        --------------------------------------------------------------------------------------
        g_OutCashReceipts.receipt_number    := DisctinctReceiptsRec.receipt_number;
        g_OutCashReceipts.customer_name     := DisctinctReceiptsRec.customer_name;
        g_OutCashReceipts.receipt_amount    := DisctinctReceiptsRec.amount;
        g_OutCashReceipts.total_applications := 0;
        g_OutCashReceipts.total_errors      := 0;

        --------------------------------------------------------------------------------------
        -- Create a Cash Receipt. This Cash Receipt will be used for all the receipt        --
        -- applications towards debit memos and the original invoices.                      --
        --------------------------------------------------------------------------------------
        l_CreateCashRec                          := l_NullCreateCashRec;
        l_CreateCashRec.receipt_number           := DisctinctReceiptsRec.receipt_number;
        l_CreateCashRec.receipt_date             := DisctinctReceiptsRec.receipt_date;
        l_CreateCashRec.gl_date                  := trunc(p_BatchRec.gl_date);
        l_CreateCashRec.currency_code            := p_BatchRec.currency_code;
        l_CreateCashRec.exchange_rate            := p_BatchRec.exchange_rate;
        l_CreateCashRec.exchange_rate_type       := p_BatchRec.exchange_rate_type;
        l_CreateCashRec.exchange_rate_date       := p_BatchRec.exchange_date;
        l_CreateCashRec.amount                   := DisctinctReceiptsRec.amount;
        l_CreateCashRec.receipt_method_id        := p_BatchRec.receipt_method_id;
        l_CreateCashRec.customer_id              := DisctinctReceiptsRec.customer_id;
--        l_CreateCashRec.customer_bank_account_id := DisctinctReceiptsRec.bank_account_id;
        l_CreateCashRec.customer_site_use_id     := DisctinctReceiptsRec.site_use_id;
        l_CreateCashRec.deposit_date             := p_BatchRec.deposit_date;
--        l_CreateCashRec.ussgl_transaction_code := p_BatchRec.ussgl_transaction_code;
        l_CreateCashRec.org_id                   := p_BatchRec.org_id;

        debug_msg (l_module_name, 'Calling create_cash_receipt');
        create_cash_receipt
        (
          p_BatchId              => p_BatchRec.batch_id,
          p_CreateCashRec        => l_CreateCashRec,
          p_CashReceiptId        => l_CashReceiptId,
          p_ErrorCode            => p_ErrorCode,
          p_ErrorDesc            => p_ErrorDesc,
          p_ErrorLoc             => p_ErrorLoc
        );

        --------------------------------------------------------------------------------------
        -- Get Applications for the same Cash Receipt                                       --
        --------------------------------------------------------------------------------------
        FOR ReceiptsRec IN C_Receipts_Cursor
        (
          p_BatchRec.batch_id,
          DisctinctReceiptsRec.receipt_number,
          DisctinctReceiptsRec.customer_id,
          DisctinctReceiptsRec.receipt_date
        ) LOOP
          debug_msg (l_module_name, 'Currently Processing Receipt Number <'||ReceiptsRec.receipt_number||'>');
          log_msg (l_module_name,'Currently Processing Receipt Number <'||ReceiptsRec.receipt_number||'>');

          --------------------------------------------------------------------------------------
          -- If the invoice id is filled up, use the invoice and ignore the customer details  --
          -- as the receipt is against the invoice, else the receipt is made against all the  --
          -- invoices against the customer and site use id.                                   --
          --------------------------------------------------------------------------------------
          IF (ReceiptsRec.customer_trx_id IS NOT NULL) THEN
            debug_msg (l_module_name, 'Customer Id forced to NULL');
            l_CustomerNumber := NULL;
            l_SiteUseId      := NULL;
          ELSE
            debug_msg (l_module_name, 'Customer Id is '||ReceiptsRec.customer_id);
            l_CustomerNumber := ReceiptsRec.customer_id;
            l_SiteUseId      := ReceiptsRec.site_use_id;
          END IF;


          IF (p_ErrorCode = g_SUCCESS) THEN
            l_RemainingReceiptAmount := ReceiptsRec.amount;

            --------------------------------------------------------------------------------------
            -- Get the outstanding Invoice details, either for the invoice or for the customer  --
            --------------------------------------------------------------------------------------

            l_OldInvoiceId := 0;
            FOR InvoiceRec IN C_Invoices_Cursor
            (
              l_CustomerNumber,
              ReceiptsRec.customer_trx_id,
              p_BatchRec.set_of_books_id,
              p_BatchRec.currency_code,
              l_SiteUseId
            ) LOOP
              log_msg (l_module_name,'Currently Processing Invoice <'||InvoiceRec.invoice_number||'>');
              IF (l_OldInvoiceId <> InvoiceRec.customer_trx_id) THEN
                IF (l_RemainingReceiptAmount > 0) THEN
                  --------------------------------------------------------------------------------------
                  -- First Pay of all the outstanding debit memos                                     --
                  --------------------------------------------------------------------------------------
                  pay_debit_memos
                  (
                    p_ReceiptNumber        => ReceiptsRec.receipt_number,
                    p_CashReceiptId        => l_CashReceiptId,
                    p_CurrencyCode         => ReceiptsRec.currency_code,
                    p_ExchangeRateDate     => p_BatchRec.exchange_date,
                    p_ExchangeRate         => p_BatchRec.exchange_rate,
                    p_ExchangeRateType     => p_BatchRec.exchange_rate_type,
                    p_InvoiceId            => InvoiceRec.customer_trx_id,
                    p_ReceiptDate          => ReceiptsRec.receipt_date,
                    p_GLDate               => ReceiptsRec.gl_date,
                    p_RemaingReceiptAmount => l_RemainingReceiptAmount,
                    p_ErrorCode            => p_ErrorCode,
                    p_ErrorDesc            => p_ErrorDesc,
                    p_ErrorLoc             => p_ErrorLoc
                  );
                END IF;
              END IF;

              l_OldInvoiceId := InvoiceRec.customer_trx_id;

              IF (p_ErrorCode = g_SUCCESS) THEN
                IF (l_RemainingReceiptAmount > 0) THEN
                  --------------------------------------------------------------------------------------
                  -- Next pay of the Invoice                                                          --
                  --------------------------------------------------------------------------------------
                  pay_the_invoice
                  (
                    p_ReceiptNumber        => ReceiptsRec.receipt_number,
                    p_CashReceiptId        => l_CashReceiptId,
                    p_InvoiceNumber        => InvoiceRec.invoice_number,
                    p_LineNumber           => ReceiptsRec.line_number,
                    p_InvoiceId            => InvoiceRec.customer_trx_id,
                    p_InvoiceLineId        => ReceiptsRec.customer_trx_line_id,
                    p_CurrencyCode         => ReceiptsRec.currency_code,
                    p_InvoiceCurrencyCode  => InvoiceRec.invoice_currency_code,
                    p_ExchangeRateDate     => p_BatchRec.exchange_date,
                    p_ExchangeRate         => p_BatchRec.exchange_rate,
                    p_ExchangeRateType     => p_BatchRec.exchange_rate_type,
                    p_PaymentScheduleId    => InvoiceRec.payment_schedule_id,
                    p_InvoiceAmount        => InvoiceRec.amount_due,
                    p_InvoiceLineAmount    => ReceiptsRec.line_amount,
                    p_ReceiptDate          => ReceiptsRec.receipt_date,
                    p_GLDate               => ReceiptsRec.gl_date,
                    p_RemaingReceiptAmount => l_RemainingReceiptAmount,
--                    p_USSGLTransactionCode => ReceiptsRec.ussgl_transaction_code,
                    p_org_id               => ReceiptsRec.org_id,
                    p_ErrorCode            => p_ErrorCode,
                    p_ErrorDesc            => p_ErrorDesc,
                    p_ErrorLoc             => p_ErrorLoc
                  );
                END IF;
              END IF;

              IF (p_ErrorCode <> g_SUCCESS) THEN
                EXIT;
              END IF;
            END LOOP;

            IF (p_ErrorCode = g_SUCCESS) THEN
              IF (l_RemainingReceiptAmount > 0) THEN
                --------------------------------------------------------------------------------------
                -- After all the pay off there is still balance left                                --
                --------------------------------------------------------------------------------------

                l_OnAccountRec.cash_receipt_id        := l_CashReceiptId;
                l_OnAccountRec.receipt_number         := ReceiptsRec.receipt_number;
                l_OnAccountRec.amount_applied         := l_RemainingReceiptAmount;
                l_OnAccountRec.apply_date             := ReceiptsRec.receipt_date;
                l_OnAccountRec.apply_gl_date          := ReceiptsRec.gl_date;
--                l_OnAccountRec.ussgl_transaction_code := ReceiptsRec.ussgl_transaction_code;

                --------------------------------------------------------------------------------------
                -- Apply the remaining amount to On Account                                         --
                --------------------------------------------------------------------------------------
                apply_on_account
                (
                  p_OnAccountRec => l_OnAccountRec,
                  p_ErrorCode    => p_ErrorCode,
                  p_ErrorDesc    => p_ErrorDesc,
                  p_ErrorLoc     => p_ErrorLoc
                );

                IF (p_ErrorCode = g_SUCCESS) THEN
                  --------------------------------------------------------------------------------------
                  -- Initialize the Report Variables for the On Account Application                   --
                  --------------------------------------------------------------------------------------
                  g_OutCashReceipts.total_applications := g_OutCashReceipts.total_applications + 1;
                  g_OutReceiptApplications(g_OutCashReceipts.total_applications).status := 'A';
                  g_OutReceiptApplications(g_OutCashReceipts.total_applications).invoice_number := 'On Account';
                  g_OutReceiptApplications(g_OutCashReceipts.total_applications).line_number := NULL;
                  g_OutReceiptApplications(g_OutCashReceipts.total_applications).applied_amount := l_RemainingReceiptAmount;
                  g_OutReceiptApplications(g_OutCashReceipts.total_applications).invoice_type := 'ON ACCOUNT';
                  g_OutReceiptApplications(g_OutCashReceipts.total_applications).amt_applied_in_inv_curr := l_RemainingReceiptAmount;
                  g_OutReceiptApplications(g_OutCashReceipts.total_applications).invoice_currency := '';
                  g_OutReceiptApplications(g_OutCashReceipts.total_applications).invoice_amount_due := 0;
                  g_OutReceiptApplications(g_OutCashReceipts.total_applications).applied_currency := '';
                  g_OutReceiptApplications(g_OutCashReceipts.total_applications).exchange_rate := '';
                END IF;
              END IF;
            END IF;

          END IF;

          debug_msg (l_module_name, 'p_ErrorCode(1)='||p_ErrorCode);
          IF (p_ErrorCode <> g_SUCCESS) THEN
            g_ErrorFound := TRUE;
          END IF;

        END LOOP;

        debug_msg (l_module_name, 'Calling write_report_for_a_receipt');
        --------------------------------------------------------------------------------------
        -- Write the output report for a receipt                                            --
        --------------------------------------------------------------------------------------
        write_report_for_a_receipt
        (
          p_ErrorCode            => p_ErrorCode,
          p_ErrorDesc            => p_ErrorDesc,
          p_ErrorLoc             => p_ErrorLoc
        );

      END LOOP;
    END IF;

    IF (p_ErrorCode <> g_SUCCESS) THEN
      g_ErrorFound := TRUE;
    END IF;

    IF (g_ErrorFound = TRUE) THEN
      p_ErrorCode := g_FAILURE;
    END IF;

    debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  EXCEPTION
    WHEN OTHERS THEN
      p_ErrorCode := g_FAILURE;
      p_ErrorDesc := SQLERRM;
      p_ErrorLoc  := 'Final Exception';
      error
      (
        p_error_type => p_ErrorCode,
        p_pgm        => l_module_name,
        p_msg        => p_ErrorDesc,
        p_loc        => p_ErrorLoc
      );
      debug_exit (p_ErrorCode, p_ErrorDesc, p_ErrorLoc);
  END process_receipts;

  --****************************************************************************************--
  --*          Name : main                                                                 *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This is the main procedure                                           *--
  --*    Parameters : p_errbuf      OUT The Concurrent Program Error Buffer                *--
  --*               : p_retcode     OUT The Concurrent Program Return Code                 *--
  --*               : p_batch_name  IN  The Input Receipt Batch name                       *--
  --*   Global Vars : g_SUCCESS              READ                                          *--
  --*   Called from : Concurrent Program                                                   *--
  --*         Calls : init                                                                 *--
  --*               : process_receipts                                                     *--
  --*               : update_fv_batch_status                                               *--
  --*               : debug_msg                                                            *--
  --*               : debug_init                                                           *--
  --*               : debug_exit                                                           *--
  --*               : error                                                                *--
  --*   Tables Used : fv_ar_batches SELECT                                                 *--
  --*         Logic : 1. Given the batch name get the record from table fv_ar_batches      *--
  --*               : 2. Call process_receipts to Start Processing the receipts in the     *--
  --*               :     batch.                                                           *--
  --*               : 3. Call update_fv_batch_status to update the batch status            *--
  --****************************************************************************************--
  PROCEDURE main
  (
    p_errbuf     OUT NOCOPY VARCHAR2,
    p_retcode    OUT NOCOPY VARCHAR2,
    p_batch_name IN  VARCHAR2
  ) IS
    l_module_name VARCHAR2(30) := 'main';

    l_ErrorCode  NUMBER;
    l_ErrorDesc  VARCHAR2(1024);
    l_ErrorLoc   VARCHAR2(1024);

    l_BatchRec   fv_ar_batches%ROWTYPE;
  BEGIN
    l_ErrorCode := g_SUCCESS;
    l_ErrorDesc := '';
    l_ErrorLoc  := '';

    ----------------------------------------------------------------------
    -- Initialize
    ----------------------------------------------------------------------
    -- init;
    -- debug_init (g_PackageName, l_module_name);

    debug_msg (l_module_name, 'p_batch_name = '||p_batch_name);
    log_msg (l_module_name,'p_batch_name = '||p_batch_name);

    ----------------------------------------------------------------------
    -- Get the batch details from fv_ar_batches given the batch name
    -- If there is no data found then it is an error.
    ----------------------------------------------------------------------
    IF (l_ErrorCode = g_SUCCESS) THEN
      BEGIN
        debug_msg (l_module_name, 'Getting the Batch Details');
        SELECT *
          INTO l_BatchRec
          FROM fv_ar_batches fab
         WHERE batch_name = p_batch_name;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_ErrorCode := g_FAILURE;
          l_ErrorDesc := 'No Batch with name <'||p_batch_name||'> Exists.';
          l_ErrorLoc  := l_module_name || ':' || 'SELECT fv_ar_batches';
          error
          (
            p_error_type => l_ErrorCode,
            p_pgm        => l_module_name,
            p_msg        => l_ErrorDesc,
            p_loc        => l_ErrorLoc
          );
          debug_msg (l_module_name, 'No Data Found for the batch <'||p_batch_name);
        WHEN OTHERS THEN
          l_ErrorCode := g_FAILURE;
          l_ErrorDesc := SQLERRM;
          l_ErrorLoc  := l_module_name || ':' || 'SELECT fv_ar_batches';
          error
          (
            p_error_type => l_ErrorCode,
            p_pgm        => l_module_name,
            p_msg        => l_ErrorDesc,
            p_loc        => l_ErrorLoc
          );
          debug_msg (l_module_name, l_ErrorDesc||'at location'||l_ErrorLoc);
      END;
    END IF;

    IF (l_ErrorCode = g_SUCCESS) THEN
      debug_msg (l_module_name, 'Calling process_receipts');
      ----------------------------------------------------------------------
      -- Call process_receipts to Start Processing the receipts in the    --
      -- batch.                                                           --
      ----------------------------------------------------------------------
      process_receipts
      (
        p_BatchRec           => l_BatchRec,
        p_ErrorCode          => l_ErrorCode,
        p_ErrorDesc          => l_ErrorDesc,
        p_ErrorLoc           => l_ErrorLoc
      );
    END IF;

    IF (l_ErrorCode = g_SUCCESS) THEN
      debug_msg (l_module_name, 'Calling update_fv_batch_status with SUCCESS');

      ----------------------------------------------------------------------
      -- The Process was successful, hence update with status as          --
      -- COMPLETED.                                                       --
      ----------------------------------------------------------------------
      update_fv_batch_status
      (
        p_BatchId    => l_BatchRec.batch_id,
        p_Status     => 'COMPLETED',
        p_ErrorCode  => l_ErrorCode,
        p_ErrorDesc  => l_ErrorDesc,
        p_ErrorLoc   => l_ErrorLoc
      );
    ELSE
      ROLLBACK;
      debug_msg (l_module_name, 'Calling update_fv_batch_status with FAILURE');
      ----------------------------------------------------------------------
      -- The Process was failure, hence update with status as             --
      -- NEEDS RESUB.                                                       --
      ----------------------------------------------------------------------
      update_fv_batch_status
      (
        p_BatchId    => l_BatchRec.batch_id,
        p_Status     => 'NEEDS RESUBMISSION',
        p_ErrorCode  => l_ErrorCode,
        p_ErrorDesc  => l_ErrorDesc,
        p_ErrorLoc   => l_ErrorLoc
      );

      IF (l_ErrorCode = g_SUCCESS) THEN
        l_ErrorCode := g_FAILURE;
      END IF;
    END IF;

    COMMIT;

    p_retcode := l_ErrorCode;
    p_errbuf  := l_ErrorDesc;
    debug_exit (l_ErrorCode, l_ErrorDesc, l_ErrorLoc);
--    error_write;
--    log_write;
--    debug_write;
  EXCEPTION
    WHEN OTHERS THEN
      l_ErrorCode := g_FAILURE;
      l_ErrorDesc := SQLERRM;
      l_ErrorLoc  := l_module_name || ':' || 'Final Exception';
      error
      (
        p_error_type => l_ErrorCode,
        p_pgm        => l_module_name,
        p_msg        => l_ErrorDesc,
        p_loc        => l_ErrorLoc
      );
      debug_exit (l_ErrorCode, l_ErrorDesc, l_ErrorLoc);
      p_retcode := l_ErrorCode;
      p_errbuf  := l_ErrorDesc;
--      error_write;
--      log_write;
--      debug_write;
      ROLLBACK;
  END main;
END fv_apply_cash_receipt;

/
