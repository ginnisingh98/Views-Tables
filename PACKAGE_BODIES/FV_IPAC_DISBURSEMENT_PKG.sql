--------------------------------------------------------
--  DDL for Package Body FV_IPAC_DISBURSEMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_IPAC_DISBURSEMENT_PKG" AS
/* $Header: FVIPDISB.pls 120.21.12010000.2 2009/02/10 07:35:35 bnarang ship $*/
  g_module_name         VARCHAR2(100);
  g_FAILURE             NUMBER;
  g_SUCCESS             NUMBER;
  g_WARNING             NUMBER;
  g_request_id          NUMBER;
  g_user_id             NUMBER;
  g_login_id            NUMBER;
  g_org_id              NUMBER;
  g_set_of_books_id     NUMBER;
  g_status_preprocessed fv_ipac_import.record_status%TYPE;
  g_status_imported     fv_ipac_import.record_status%TYPE;
  g_status_no_process   fv_ipac_import.record_status%TYPE;
  g_status_processed    fv_ipac_import.record_status%TYPE;
  g_status_error        fv_ipac_import.record_status%TYPE;
  g_status_other_error  fv_ipac_import.record_status%TYPE;
  g_status_ap_imported  fv_ipac_import.record_status%TYPE;
  g_ia_paygroup         fv_operating_units.payables_ia_paygroup%TYPE;
  g_enter               VARCHAR2(10);
  g_exit                VARCHAR2(10);

-- variables used by "Update FV_INTERAGENCY_FUNDS Table" process
  parm_inv_creation_date_low  DATE;
  parm_inv_creation_date_high DATE;
  g_err_buf                   VARCHAR2(1024);
  g_err_code                  NUMBER(15);

  --****************************************************************************************--
  --*          Name : initialize_global_variables                                          *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : To initialize all global variables                                   *--
  --*    Parameters : None                                                                 *--
  --*   Global Vars : As in procedure                                                      *--
  --*   Called from : Called when initializing the package                                 *--
  --*         Calls : mo_global.get_current_org_id                                         *--
  --*                 mo_utils.get_ledger_info                                             *--
  --*   Tables Used : None                                                                 *--
  --*         Logic : No Logic                                                             *--
  --****************************************************************************************--
  PROCEDURE initialize_global_variables
   IS
    l_ledger_name            VARCHAR2(30);
  BEGIN
    g_module_name         := 'fv.plsql.fv_ipac_disbursement_pkg.';
    g_FAILURE             := -1;
    g_SUCCESS             := 0;
    g_WARNING             := -2;
    g_request_id          := fnd_global.conc_request_id;
    g_user_id             := fnd_global.user_id;
    g_login_id            := fnd_global.login_id;
    g_org_id              := mo_global.get_current_org_id;
    g_status_preprocessed := 'PRE_PROCESSED';
    g_status_imported     := 'IMPORTED';
    g_status_no_process   := 'NOTPROCESSED_YET';
    g_status_processed    := 'PROCESSED';
    g_status_error        := 'ERROR';
    g_status_other_error  := 'ERROR_IN_OTHER_LINES';
    g_status_ap_imported  := 'AP_IMPORTED';
    mo_utils.get_ledger_info( g_org_id, g_set_of_books_id, l_ledger_name);
    g_enter               := 'ENTER';
    g_exit                := 'EXIT';
  END;

  --****************************************************************************************--
  --*          Name : insert_ia_recs                                                       *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : Inserts record into fv_interagency_funds table                       *--
  --*    Parameters : inv_id                                                               *--
  --*               : inv_num                                                              *--
  --*               : ven_id                                                               *--
  --*               : ven_name                                                             *--
  --*   Global Vars : g_module_name                                                        *--
  --*   Called from : upd_ia_main                                                          *--
  --*         Calls : fv_utility.log_mesg                                                  *--
  --*   Tables Used : fv_interagency_funds INSERT                                          *--
  --*         Logic : Inserts record into fv_interagency_funds table                       *--
  --****************************************************************************************--
  PROCEDURE insert_ia_recs
  (
    inv_id   NUMBER ,
    inv_num  VARCHAR2 ,
    ven_id   NUMBER ,
    ven_name VARCHAR2
  )
  IS
    l_module_name VARCHAR2(200);

    retcode NUMBER;
    errbuf VARCHAR2(100);

  BEGIN
    l_module_name := g_module_name || 'insert_ia_recs';
    g_err_buf := '';
    g_err_code := 0;

    INSERT INTO fv_interagency_funds
    (
      interagency_fund_id,
      set_of_books_id,
      processed_flag,
      chargeback_flag,
      last_update_date,
      last_updated_by,
      created_by,
      creation_date,
      vendor_id,
      vendor_name,
      invoice_id,
      invoice_number
    )
    VALUES
    (
      fv_interagency_funds_s.nextval,
      g_set_of_books_id,
      'N',
      'N',
      SYSDATE,
      fnd_global.user_id,
      fnd_global.user_id,
      SYSDATE,
      ven_id,
      ven_name,
      inv_id,
      inv_num
    );
  EXCEPTION
    WHEN OTHERS THEN
      g_err_code := SQLCODE;
      g_err_buf  := SQLERRM;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_module_name||'.final_exception',g_err_buf) ;
      RAISE;
  END insert_ia_recs;

  --****************************************************************************************--
  --*          Name : upd_ia_main                                                          *--
  --*          Type : Procedure                                                            *--
  --*       Purpose :                                                                      *--
  --*    Parameters : errbuf                     Error returned to the concurrent process  *--
  --*               : retcode                    Return Code to concurrent process         *--
  --*               : invoice_creation_date_low                                            *--
  --*               : invoice_creation_date_high                                           *--
  --*   Global Vars : g_module_name                                                        *--
  --*               : g_set_of_books_id                                                    *--
  --*               : g_err_buf                                                            *--
  --*               : g_err_code                                                           *--
  --*               : fnd_log.level_unexpected                                             *--
  --*               : fnd_log.level_statement                                              *--
  --*               : fnd_log.g_current_runtime_level                                      *--
  --*   Called from : Concurrent program Update Interagency Transfers (FVIAUPDB)           *--
  --*         Calls : insert_ia_recs                                                       *--
  --*               : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*               : mo_global.get_current_org_id                                         *--
  --*               : mo_utils.get_ledger_info                                             *--
  --*               : fnd_date.canonical_to_date                                           *--
  --*   Tables Used : ap_invoices          SELECT                                          *--
  --*               : po_vendors           SELECT                                          *--
  --*               : fv_operating_units   SELECT                                          *--
  --*               : fv_interagency_funds SELECT                                          *--
  --*         Logic :                                                                      *--
  --****************************************************************************************--
  PROCEDURE upd_ia_main
  (
    errbuf OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2,
    invoice_creation_date_low VARCHAR2 ,
    invoice_creation_date_high VARCHAR2
  )
  IS
    l_module_name VARCHAR2(200);
    l_ledger_name VARCHAR2(30);
    l_org_id      NUMBER;

    CURSOR ia_trx_select_csr
    (
      p_sob_id NUMBER
    ) IS
    SELECT ai.invoice_id ,
           ai.invoice_num,
           ai.vendor_id ,
           pv.vendor_name,
           ai.creation_date
      FROM ap_invoices ai , po_vendors pv
     WHERE ai.vendor_id = pv.vendor_id
       AND ai.invoice_num LIKE 'IPAC%'
       AND ai.payment_method_lookup_code = 'CLEARING'
       AND EXISTS (SELECT 'X'
                     FROM fv_operating_units
                    WHERE set_of_books_id = p_sob_id
                      AND default_alc = 'Y'
                      AND payables_ia_paygroup = ai.pay_group_lookup_code)
                      AND TO_DATE(ai.creation_date,'DD-MM-YYYY') BETWEEN
                          TO_DATE(parm_inv_creation_date_low,'DD-MM-YYYY') AND
                          TO_DATE(parm_inv_creation_date_high,'DD-MM-YYYY')
       AND NOT EXISTS (SELECT 'X'
                         FROM fv_interagency_funds
                        WHERE set_of_books_id = p_sob_id
                          AND invoice_id IS NOT NULL
                          AND invoice_id = ai.invoice_id);

    l_count NUMBER :=0;

  BEGIN
    l_module_name := g_module_name || 'upd_ia_main';
    g_err_buf := '';
    g_err_code := 0;
    l_org_id := mo_global.get_current_org_id;
    mo_utils.get_ledger_info(l_org_id, g_set_of_books_id, l_ledger_name);
    parm_inv_creation_date_low := fnd_date.canonical_to_date(invoice_creation_date_low);
    parm_inv_creation_date_high := fnd_date.canonical_to_date(invoice_creation_date_high);


    FOR trx_select IN ia_trx_select_csr(g_set_of_books_id) LOOP
      l_count := l_count+1;
      insert_ia_recs(trx_select.invoice_id,
      trx_select.invoice_num,
      trx_select.vendor_id,
      trx_select.vendor_name);
      IF g_err_code <> 0 THEN
        ERRBUF := g_err_buf;
        retcode := g_err_code;
        RETURN;
      END IF;
    END LOOP ;

    IF l_count =0 THEN
      errbuf := 'No Invoices found for Upload.';
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,errbuf);
      END IF;
    ELSE
      errbuf := 'Total Number of records Uploaded : '||l_count||'.';
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,errbuf);
      END IF;
      COMMIT;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      g_err_code := SQLCODE;
      g_err_buf  := SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_err_buf) ;
  END upd_ia_main;

  --****************************************************************************************--
  --*          Name : insert_error                                                         *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This procedure inserts the import errors into the table              *--
  --*               : fv_ipac_import_errors table                                          *--
  --*    Parameters : p_ipac_import_id  IN  The import id                                  *--
  --*               : p_validation_code IN  The validation Code                            *--
  --*               : p_validation_err  IN  The Validation Error                           *--
  --*               : p_errbuf          OUT Error returned to the calling process          *--
  --*               : p_retcode         OUT Return Code to calling process                 *--
  --*   Global Vars : g_module_name                   READ                                 *--
  --*               : g_SUCCESS                       READ                                 *--
  --*               : g_ERROR                         READ                                 *--
  --*               : fnd_log.level_statement         READ                                 *--
  --*               : fnd_log.g_current_runtime_level READ                                 *--
  --*               : fnd_log.level_unexpected        READ                                 *--
  --*               : fnd_log.level_procedure         READ                                 *--
  --*               : g_enter                         READ                                 *--
  --*               : g_exit                          READ                                 *--
  --*   Called from : check_for_ap_import_errors                                           *--
  --*               : resolve_uom                                                          *--
  --*               : validate_duns                                                        *--
  --*               : validate_po                                                          *--
  --*         Calls : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*   Tables Used : fv_ipac_import_errors INSERT                                         *--
  --*         Logic : Inserts the record into table fv_ipac_import_errors                  *--
  --*               : using the input variables                                            *--
  --****************************************************************************************--
  PROCEDURE insert_error
  (
    p_ipac_import_id       IN  fv_ipac_import_errors.ipac_import_id%TYPE,
    p_validation_code      IN  fv_ipac_import_errors.error_code%TYPE,
    p_validation_err       IN  fv_ipac_import_errors.error_desc%TYPE,
    p_error_code           OUT NOCOPY NUMBER,
    p_error_desc           OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(400);
  BEGIN
    l_module_name := g_module_name || 'insert_error';
    p_error_code  := g_SUCCESS;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_ipac_import_id  = '||p_ipac_import_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_validation_code = '||p_validation_code);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_validation_err  = '||p_validation_err);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Inserting into fv_ipac_import_errors');
    END IF;
    INSERT INTO fv_ipac_import_errors
    (
      ipac_import_id,
      error_code,
      error_desc
    )
    VALUES
    (
      p_ipac_import_id,
      p_validation_code,
      p_validation_err
    );
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;

  --****************************************************************************************--
  --*          Name : insert_invoice_hdr                                                   *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : Inserts the Invoice Header record into ap_invoices_interface         *--
  --*    Parameters : p_invoice_hdr_rec The Header record that has to be inserted          *--
  --*               : p_errbuf          Error returned to the concurrent process           *--
  --*               : p_retcode         Return Code to concurrent process                  *--
  --*   Global Vars : g_module_name                   READ                                 *--
  --*               : g_SUCCESS                       READ                                 *--
  --*               : g_ERROR                         READ                                 *--
  --*               : fnd_log.level_statement         READ                                 *--
  --*               : fnd_log.g_current_runtime_level READ                                 *--
  --*               : fnd_log.level_unexpected        READ                                 *--
  --*               : fnd_log.level_procedure         READ                                 *--
  --*               : g_enter                         READ                                 *--
  --*               : g_exit                          READ                                 *--
  --*   Called from : save_or_erase_invoice                                                *--
  --*         Calls : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*   Tables Used : ap_invoices_interface INSERT                                         *--
  --*         Logic : Insert the record p_invoice_hdr_rec into table ap_invoices_interface *--
  --****************************************************************************************--
  PROCEDURE insert_invoice_hdr
  (
    p_invoice_hdr_rec      IN ap_invoices_interface%ROWTYPE,
    p_error_code           OUT NOCOPY NUMBER,
    p_error_desc           OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(400);
  BEGIN
    l_module_name := g_module_name || 'insert_invoice_hdr';
    p_error_code  := g_SUCCESS;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Inserting into ap_invoices_interface');
    END IF;
    INSERT INTO ap_invoices_interface
    (
      invoice_id,
      invoice_num,
      invoice_type_lookup_code,
      invoice_date,
      po_number,
      vendor_id,
      vendor_num,
      vendor_name,
      vendor_site_id,
      vendor_site_code,
      invoice_amount,
      invoice_currency_code,
      exchange_rate,
      exchange_rate_type,
      exchange_date,
      terms_id,
      terms_name,
      description,
      awt_group_id,
      awt_group_name,
      last_update_date,
      last_updated_by,
      last_update_login,
      creation_date,
      created_by,
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
      global_attribute_category,
      global_attribute1,
      global_attribute2,
      global_attribute3,
      global_attribute4,
      global_attribute5,
      global_attribute6,
      global_attribute7,
      global_attribute8,
      global_attribute9,
      global_attribute10,
      global_attribute11,
      global_attribute12,
      global_attribute13,
      global_attribute14,
      global_attribute15,
      global_attribute16,
      global_attribute17,
      global_attribute18,
      global_attribute19,
      global_attribute20,
      status,
      source,
      group_id,
      request_id,
      payment_cross_rate_type,
      payment_cross_rate_date,
      payment_cross_rate,
      payment_currency_code,
      workflow_flag,
      doc_category_code,
      voucher_num,
      payment_method_lookup_code,
      pay_group_lookup_code,
      goods_received_date,
      invoice_received_date,
      gl_date,
      accts_pay_code_combination_id,
--      ussgl_transaction_code,
      exclusive_payment_flag,
      org_id,
      amount_applicable_to_discount,
      prepay_num,
      prepay_dist_num,
      prepay_apply_amount,
      prepay_gl_date,
      invoice_includes_prepay_flag,
      no_xrate_base_amount,
      vendor_email_address,
      terms_date,
      requester_id,
      ship_to_location,
      external_doc_ref,
      payment_method_code
    )
    VALUES
    (
      p_invoice_hdr_rec.invoice_id,
      p_invoice_hdr_rec.invoice_num,
      p_invoice_hdr_rec.invoice_type_lookup_code,
      p_invoice_hdr_rec.invoice_date,
      p_invoice_hdr_rec.po_number,
      p_invoice_hdr_rec.vendor_id,
      p_invoice_hdr_rec.vendor_num,
      p_invoice_hdr_rec.vendor_name,
      p_invoice_hdr_rec.vendor_site_id,
      p_invoice_hdr_rec.vendor_site_code,
      p_invoice_hdr_rec.invoice_amount,
      p_invoice_hdr_rec.invoice_currency_code,
      p_invoice_hdr_rec.exchange_rate,
      p_invoice_hdr_rec.exchange_rate_type,
      p_invoice_hdr_rec.exchange_date,
      p_invoice_hdr_rec.terms_id,
      p_invoice_hdr_rec.terms_name,
      p_invoice_hdr_rec.description,
      p_invoice_hdr_rec.awt_group_id,
      p_invoice_hdr_rec.awt_group_name,
      p_invoice_hdr_rec.last_update_date,
      p_invoice_hdr_rec.last_updated_by,
      p_invoice_hdr_rec.last_update_login,
      p_invoice_hdr_rec.creation_date,
      p_invoice_hdr_rec.created_by,
      p_invoice_hdr_rec.attribute_category,
      p_invoice_hdr_rec.attribute1,
      p_invoice_hdr_rec.attribute2,
      p_invoice_hdr_rec.attribute3,
      p_invoice_hdr_rec.attribute4,
      p_invoice_hdr_rec.attribute5,
      p_invoice_hdr_rec.attribute6,
      p_invoice_hdr_rec.attribute7,
      p_invoice_hdr_rec.attribute8,
      p_invoice_hdr_rec.attribute9,
      p_invoice_hdr_rec.attribute10,
      p_invoice_hdr_rec.attribute11,
      p_invoice_hdr_rec.attribute12,
      p_invoice_hdr_rec.attribute13,
      p_invoice_hdr_rec.attribute14,
      p_invoice_hdr_rec.attribute15,
      p_invoice_hdr_rec.global_attribute_category,
      p_invoice_hdr_rec.global_attribute1,
      p_invoice_hdr_rec.global_attribute2,
      p_invoice_hdr_rec.global_attribute3,
      p_invoice_hdr_rec.global_attribute4,
      p_invoice_hdr_rec.global_attribute5,
      p_invoice_hdr_rec.global_attribute6,
      p_invoice_hdr_rec.global_attribute7,
      p_invoice_hdr_rec.global_attribute8,
      p_invoice_hdr_rec.global_attribute9,
      p_invoice_hdr_rec.global_attribute10,
      p_invoice_hdr_rec.global_attribute11,
      p_invoice_hdr_rec.global_attribute12,
      p_invoice_hdr_rec.global_attribute13,
      p_invoice_hdr_rec.global_attribute14,
      p_invoice_hdr_rec.global_attribute15,
      p_invoice_hdr_rec.global_attribute16,
      p_invoice_hdr_rec.global_attribute17,
      p_invoice_hdr_rec.global_attribute18,
      p_invoice_hdr_rec.global_attribute19,
      p_invoice_hdr_rec.global_attribute20,
      p_invoice_hdr_rec.status,
      p_invoice_hdr_rec.source,
      p_invoice_hdr_rec.group_id,
      p_invoice_hdr_rec.request_id,
      p_invoice_hdr_rec.payment_cross_rate_type,
      p_invoice_hdr_rec.payment_cross_rate_date,
      p_invoice_hdr_rec.payment_cross_rate,
      p_invoice_hdr_rec.payment_currency_code,
      p_invoice_hdr_rec.workflow_flag,
      p_invoice_hdr_rec.doc_category_code,
      p_invoice_hdr_rec.voucher_num,
      p_invoice_hdr_rec.payment_method_lookup_code,
      p_invoice_hdr_rec.pay_group_lookup_code,
      p_invoice_hdr_rec.goods_received_date,
      p_invoice_hdr_rec.invoice_received_date,
      p_invoice_hdr_rec.gl_date,
      p_invoice_hdr_rec.accts_pay_code_combination_id,
--      p_invoice_hdr_rec.ussgl_transaction_code,
      p_invoice_hdr_rec.exclusive_payment_flag,
      p_invoice_hdr_rec.org_id,
      p_invoice_hdr_rec.amount_applicable_to_discount,
      p_invoice_hdr_rec.prepay_num,
      p_invoice_hdr_rec.prepay_dist_num,
      p_invoice_hdr_rec.prepay_apply_amount,
      p_invoice_hdr_rec.prepay_gl_date,
      p_invoice_hdr_rec.invoice_includes_prepay_flag,
      p_invoice_hdr_rec.no_xrate_base_amount,
      p_invoice_hdr_rec.vendor_email_address,
      p_invoice_hdr_rec.terms_date,
      p_invoice_hdr_rec.requester_id,
      p_invoice_hdr_rec.ship_to_location,
      p_invoice_hdr_rec.external_doc_ref,
      p_invoice_hdr_rec.payment_method_code
    );
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;

  --****************************************************************************************--
  --*          Name : insert_invoice_line                                                  *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : Inserts the Invoice Line record into ap_invoice_lines_interface      *--
  --*    Parameters : p_invoice_lines_rec The Line record that has to be inserted          *--
  --*               : p_errbuf            Error returned to the concurrent process         *--
  --*               : p_retcode           Return Code to concurrent process                *--
  --*   Global Vars : g_module_name                   READ                                 *--
  --*               : g_SUCCESS                       READ                                 *--
  --*               : g_ERROR                         READ                                 *--
  --*               : fnd_log.level_statement         READ                                 *--
  --*               : fnd_log.g_current_runtime_level READ                                 *--
  --*               : fnd_log.level_unexpected        READ                                 *--
  --*               : fnd_log.level_procedure         READ                                 *--
  --*               : g_enter                         READ                                 *--
  --*               : g_exit                          READ                                 *--
  --*   Called from : process_data                                                         *--
  --*         Calls : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --* Sequence Used : ap_invoice_lines_interface_s                                         *--
  --*   Tables Used : ap_invoice_lines_interface INSERT                                    *--
  --*         Logic : Insert the record p_invoice_lines_rec into table                     *--
  --*               : ap_invoice_lines_interface                                           *--
  --*               : The invoice line id is returned in                                   *--
  --*               : p_invoice_lines_rec.invoice_line_id                                  *--
  --****************************************************************************************--
  PROCEDURE insert_invoice_line
  (
    p_invoice_lines_rec    IN OUT NOCOPY ap_invoice_lines_interface%ROWTYPE,
    p_error_code           OUT NOCOPY NUMBER,
    p_error_desc           OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(400);
  BEGIN
    l_module_name := g_module_name || 'insert_invoice_line';
    p_error_code  := g_SUCCESS;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Inserting into ap_invoice_lines_interface');
    END IF;
    INSERT INTO ap_invoice_lines_interface
    (
      invoice_id,
      invoice_line_id,
      line_number,
      line_type_lookup_code,
      line_group_number,
      amount,
      accounting_date,
      description,
      amount_includes_tax_flag,
      prorate_across_flag,
      tax_code,
      final_match_flag,
      po_header_id,
      po_number,
      po_line_id,
      po_line_number,
      po_line_location_id,
      po_shipment_num,
      po_distribution_id,
      po_distribution_num,
      po_unit_of_measure,
      inventory_item_id,
      item_description,
      quantity_invoiced,
      ship_to_location_code,
      unit_price,
      distribution_set_id,
      distribution_set_name,
      dist_code_concatenated,
      dist_code_combination_id,
      awt_group_id,
      awt_group_name,
      last_updated_by,
      last_update_date,
      last_update_login,
      created_by,
      creation_date,
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
      global_attribute_category,
      global_attribute1,
      global_attribute2,
      global_attribute3,
      global_attribute4,
      global_attribute5,
      global_attribute6,
      global_attribute7,
      global_attribute8,
      global_attribute9,
      global_attribute10,
      global_attribute11,
      global_attribute12,
      global_attribute13,
      global_attribute14,
      global_attribute15,
      global_attribute16,
      global_attribute17,
      global_attribute18,
      global_attribute19,
      global_attribute20,
      po_release_id,
      release_num,
      account_segment,
      balancing_segment,
      cost_center_segment,
      project_id,
      task_id,
      expenditure_type,
      expenditure_item_date,
      expenditure_organization_id,
      project_accounting_context,
      pa_addition_flag,
      pa_quantity,
--      ussgl_transaction_code,
      stat_amount,
      type_1099,
      income_tax_region,
      assets_tracking_flag,
      price_correction_flag,
      org_id,
      receipt_number,
      receipt_line_number,
      match_option,
      packing_slip,
      rcv_transaction_id,
      pa_cc_ar_invoice_id,
      pa_cc_ar_invoice_line_num,
      reference_1,
      reference_2,
      pa_cc_processed_code,
      tax_recovery_rate,
      tax_recovery_override_flag,
      tax_recoverable_flag,
      tax_code_override_flag,
      tax_code_id,
      credit_card_trx_id,
      award_id,
      vendor_item_num,
      taxable_flag,
      price_correct_inv_num,
      external_doc_line_ref
    )
    VALUES
    (
      p_invoice_lines_rec.invoice_id,
      ap_invoice_lines_interface_s.NEXTVAL,
      p_invoice_lines_rec.line_number,
      p_invoice_lines_rec.line_type_lookup_code,
      p_invoice_lines_rec.line_group_number,
      p_invoice_lines_rec.amount,
      p_invoice_lines_rec.accounting_date,
      p_invoice_lines_rec.description,
      p_invoice_lines_rec.amount_includes_tax_flag,
      p_invoice_lines_rec.prorate_across_flag,
      p_invoice_lines_rec.tax_code,
      p_invoice_lines_rec.final_match_flag,
      p_invoice_lines_rec.po_header_id,
      p_invoice_lines_rec.po_number,
      p_invoice_lines_rec.po_line_id,
      p_invoice_lines_rec.po_line_number,
      p_invoice_lines_rec.po_line_location_id,
      p_invoice_lines_rec.po_shipment_num,
      p_invoice_lines_rec.po_distribution_id,
      p_invoice_lines_rec.po_distribution_num,
      p_invoice_lines_rec.po_unit_of_measure,
      p_invoice_lines_rec.inventory_item_id,
      p_invoice_lines_rec.item_description,
      p_invoice_lines_rec.quantity_invoiced,
      p_invoice_lines_rec.ship_to_location_code,
      p_invoice_lines_rec.unit_price,
      p_invoice_lines_rec.distribution_set_id,
      p_invoice_lines_rec.distribution_set_name,
      p_invoice_lines_rec.dist_code_concatenated,
      p_invoice_lines_rec.dist_code_combination_id,
      p_invoice_lines_rec.awt_group_id,
      p_invoice_lines_rec.awt_group_name,
      p_invoice_lines_rec.last_updated_by,
      p_invoice_lines_rec.last_update_date,
      p_invoice_lines_rec.last_update_login,
      p_invoice_lines_rec.created_by,
      p_invoice_lines_rec.creation_date,
      p_invoice_lines_rec.attribute_category,
      p_invoice_lines_rec.attribute1,
      p_invoice_lines_rec.attribute2,
      p_invoice_lines_rec.attribute3,
      p_invoice_lines_rec.attribute4,
      p_invoice_lines_rec.attribute5,
      p_invoice_lines_rec.attribute6,
      p_invoice_lines_rec.attribute7,
      p_invoice_lines_rec.attribute8,
      p_invoice_lines_rec.attribute9,
      p_invoice_lines_rec.attribute10,
      p_invoice_lines_rec.attribute11,
      p_invoice_lines_rec.attribute12,
      p_invoice_lines_rec.attribute13,
      p_invoice_lines_rec.attribute14,
      p_invoice_lines_rec.attribute15,
      p_invoice_lines_rec.global_attribute_category,
      p_invoice_lines_rec.global_attribute1,
      p_invoice_lines_rec.global_attribute2,
      p_invoice_lines_rec.global_attribute3,
      p_invoice_lines_rec.global_attribute4,
      p_invoice_lines_rec.global_attribute5,
      p_invoice_lines_rec.global_attribute6,
      p_invoice_lines_rec.global_attribute7,
      p_invoice_lines_rec.global_attribute8,
      p_invoice_lines_rec.global_attribute9,
      p_invoice_lines_rec.global_attribute10,
      p_invoice_lines_rec.global_attribute11,
      p_invoice_lines_rec.global_attribute12,
      p_invoice_lines_rec.global_attribute13,
      p_invoice_lines_rec.global_attribute14,
      p_invoice_lines_rec.global_attribute15,
      p_invoice_lines_rec.global_attribute16,
      p_invoice_lines_rec.global_attribute17,
      p_invoice_lines_rec.global_attribute18,
      p_invoice_lines_rec.global_attribute19,
      p_invoice_lines_rec.global_attribute20,
      p_invoice_lines_rec.po_release_id,
      p_invoice_lines_rec.release_num,
      p_invoice_lines_rec.account_segment,
      p_invoice_lines_rec.balancing_segment,
      p_invoice_lines_rec.cost_center_segment,
      p_invoice_lines_rec.project_id,
      p_invoice_lines_rec.task_id,
      p_invoice_lines_rec.expenditure_type,
      p_invoice_lines_rec.expenditure_item_date,
      p_invoice_lines_rec.expenditure_organization_id,
      p_invoice_lines_rec.project_accounting_context,
      p_invoice_lines_rec.pa_addition_flag,
      p_invoice_lines_rec.pa_quantity,
--      p_invoice_lines_rec.ussgl_transaction_code,
      p_invoice_lines_rec.stat_amount,
      p_invoice_lines_rec.type_1099,
      p_invoice_lines_rec.income_tax_region,
      p_invoice_lines_rec.assets_tracking_flag,
      p_invoice_lines_rec.price_correction_flag,
      p_invoice_lines_rec.org_id,
      p_invoice_lines_rec.receipt_number,
      p_invoice_lines_rec.receipt_line_number,
      p_invoice_lines_rec.match_option,
      p_invoice_lines_rec.packing_slip,
      p_invoice_lines_rec.rcv_transaction_id,
      p_invoice_lines_rec.pa_cc_ar_invoice_id,
      p_invoice_lines_rec.pa_cc_ar_invoice_line_num,
      p_invoice_lines_rec.reference_1,
      p_invoice_lines_rec.reference_2,
      p_invoice_lines_rec.pa_cc_processed_code,
      p_invoice_lines_rec.tax_recovery_rate,
      p_invoice_lines_rec.tax_recovery_override_flag,
      p_invoice_lines_rec.tax_recoverable_flag,
      p_invoice_lines_rec.tax_code_override_flag,
      p_invoice_lines_rec.tax_code_id,
      p_invoice_lines_rec.credit_card_trx_id,
      p_invoice_lines_rec.award_id,
      p_invoice_lines_rec.vendor_item_num,
      p_invoice_lines_rec.taxable_flag,
      p_invoice_lines_rec.price_correct_inv_num,
      p_invoice_lines_rec.external_doc_line_ref
    ) RETURNING invoice_line_id INTO p_invoice_lines_rec.invoice_line_id;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;

  --****************************************************************************************--
  --*          Name : check_for_ap_import_errors                                           *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : Checks for ap import errors for the group id                         *--
  --*    Parameters : p_group_id       Group Id for which the errors have to be checked    *--
  --*               : p_errbuf         Error returned to the concurrent process            *--
  --*               : p_retcode        Return Code to concurrent process                   *--
  --*   Global Vars : g_module_name                   READ                                 *--
  --*               : g_SUCCESS                       READ                                 *--
  --*               : g_ERROR                         READ                                 *--
  --*               : fnd_log.level_statement         READ                                 *--
  --*               : fnd_log.g_current_runtime_level READ                                 *--
  --*               : fnd_log.level_unexpected        READ                                 *--
  --*               : fnd_log.level_procedure         READ                                 *--
  --*               : g_enter                         READ                                 *--
  --*               : g_exit                          READ                                 *--
  --*   Called from : main                                                                 *--
  --*         Calls : insert_error                                                         *--
  --*               : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*   Tables Used : ap_invoices_interface       SELECT                                   *--
  --*               : ap_invoice_lines_interface  SELECT                                   *--
  --*               : ap_interface_rejections     SELECT                                   *--
  --*               : fv_ipac_import              SELECT, UPDATE                           *--
  --*               : ap_lookup_codes             SELECT                                   *--
  --*         Logic : Go through ap_interface_rejections for the group id and see          *--
  --*               : if there are any header errors. If so insert the errors into         *--
  --*               : fv_ipac_import_errors and update the table fv_ipac_import with       *--
  --*               : error status.                                                        *--
  --*               : Go through ap_interface_rejections for the group id and see          *--
  --*               : if there are any line errors. If so insert the errors into           *--
  --*               : fv_ipac_import_errors and update the table fv_ipac_import with       *--
  --*               : error status.                                                        *--
  --****************************************************************************************--
  PROCEDURE check_for_ap_import_errors
  (
    p_group_id             ap_invoices_interface.group_id%TYPE,
    p_error_code           OUT NOCOPY NUMBER,
    p_error_desc           OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(400);
    l_rowcount            NUMBER;
  BEGIN
    l_module_name := g_module_name || 'check_for_ap_import_errors';
    p_error_code  := g_SUCCESS;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_group_id = '||p_group_id);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'About to get into invoices_rec');
    END IF;
    FOR invoices_rec IN (SELECT aii.invoice_id,
                                air.reject_lookup_code,
                                fii.ipac_import_id,
                                alc.description
                           FROM ap_invoices_interface aii,
                                ap_interface_rejections air,
                                fv_ipac_import fii,
                                ap_lookup_codes alc
                          WHERE aii.group_id = p_group_id
                            AND aii.status = 'REJECTED'
                            AND aii.invoice_id = air.parent_id
                            AND air.parent_table = 'AP_INVOICES_INTERFACE'
                            AND fii.group_id = p_group_id
                            AND fii.int_invoice_id = aii.invoice_id
                            AND alc.lookup_type = 'REJECT CODE'
                            AND alc.lookup_code = air.reject_lookup_code) LOOP
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'invoice_id='||invoices_rec.invoice_id);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'reject_lookup_code='||invoices_rec.reject_lookup_code);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'description='||invoices_rec.description);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'ipac_import_id='||invoices_rec.ipac_import_id);
      END IF;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling insert_error');
      END IF;
      insert_error
      (
        p_ipac_import_id       => invoices_rec.ipac_import_id,
        p_validation_code      => invoices_rec.reject_lookup_code,
        p_validation_err       => invoices_rec.description,
        p_error_code           => p_error_code,
        p_error_desc           => p_error_desc
      );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'insert_error returned with code'||p_error_code);
      END IF;

      IF (p_error_code = g_SUCCESS) THEN
        BEGIN
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'UPDATE fv_ipac_import1');
          END IF;
          UPDATE fv_ipac_import
             SET record_status = g_status_error
           WHERE ipac_import_id = invoices_rec.ipac_import_id;
          l_rowcount := SQL%ROWCOUNT;
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'UPDATED '||l_rowcount||' rows.');
          END IF;

        EXCEPTION
          WHEN OTHERS THEN
            p_error_code := g_FAILURE;
            p_error_desc := SQLERRM;
            l_location   := l_module_name||'.update_fv_ipac_import1';
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
        END;
      END IF;
      IF (p_error_code <> g_SUCCESS) THEN
        EXIT;
      END IF;
    END LOOP;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'invoices_rec processing finished');
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'About to get into invoice_lines_rec');
      END IF;
      FOR invoice_lines_rec IN (SELECT aii.invoice_id,
                                       air.reject_lookup_code,
                                       fii.ipac_import_id,
                                       alc.description
                                  FROM ap_invoices_interface aii,
                                       ap_invoice_lines_interface aili,
                                       ap_interface_rejections air,
                                       fv_ipac_import fii,
                                       ap_lookup_codes alc
                                 WHERE aii.group_id = p_group_id
                                   AND aii.status = 'REJECTED'
                                   AND aili.invoice_line_id = air.parent_id
                                   AND aii.invoice_id = aili.invoice_id
                                   AND air.parent_table = 'AP_INVOICE_LINES_INTERFACE'
                                   AND fii.group_id = p_group_id
                                   AND fii.int_invoice_id = aii.invoice_id
                                   AND fii.int_invoice_line_id = aili.invoice_line_id
                                   AND alc.lookup_type = 'REJECT CODE'
                                   AND alc.lookup_code = air.reject_lookup_code) LOOP
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'invoice_id='||invoice_lines_rec.invoice_id);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'reject_lookup_code='||invoice_lines_rec.reject_lookup_code);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'description='||invoice_lines_rec.description);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'ipac_import_id='||invoice_lines_rec.ipac_import_id);
        END IF;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling insert_error');
        END IF;
        insert_error
        (
          p_ipac_import_id       => invoice_lines_rec.ipac_import_id,
          p_validation_code      => invoice_lines_rec.reject_lookup_code,
          p_validation_err       => invoice_lines_rec.description,
          p_error_code           => p_error_code,
          p_error_desc           => p_error_desc
        );

        IF (p_error_code = g_SUCCESS) THEN
          BEGIN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'UPDATE fv_ipac_import2');
            END IF;
            UPDATE fv_ipac_import
               SET record_status = g_status_error
             WHERE ipac_import_id = invoice_lines_rec.ipac_import_id;
            l_rowcount := SQL%ROWCOUNT;
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'UPDATED '||l_rowcount||' rows.');
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              p_error_code := g_FAILURE;
              p_error_desc := SQLERRM;
              l_location   := l_module_name||'.update_fv_ipac_import2';
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
          END;
        END IF;
        IF (p_error_code <> g_SUCCESS) THEN
          EXIT;
        END IF;
      END LOOP;
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'invoice_lines_rec processing finished');
      END IF;

    END IF;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;

  --****************************************************************************************--
  --*          Name : kick_off_ipac_auto_pmt_process                                       *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : Procedure to kick of the concurrent process                          *--
  --*               : IPAC Automatic Payments Process (FVIPAPMT)                           *--
  --*    Parameters : p_batch_name     IN  Batch name to be passed into conc pgm           *--
  --*               : p_document_id    IN  Document Id to be passed into conc pgm          *--
  --*               : p_errbuf         OUT Error returned to the concurrent process        *--
  --*               : p_retcode        OUT Return Code to concurrent process               *--
  --*   Global Vars : g_org_id                        READ                                 *--
  --*               : g_module_name                   READ                                 *--
  --*               : g_SUCCESS                       READ                                 *--
  --*               : g_ERROR                         READ                                 *--
  --*               : fnd_log.level_statement         READ                                 *--
  --*               : fnd_log.g_current_runtime_level READ                                 *--
  --*               : fnd_log.level_unexpected        READ                                 *--
  --*               : fnd_log.level_procedure         READ                                 *--
  --*               : g_enter                         READ                                 *--
  --*               : g_exit                          READ                                 *--
  --*   Called from : main                                                                 *--
  --*         Calls : fnd_request.set_org_id                                               *--
  --*               : fnd_request.submit_request                                           *--
  --*               : fnd_concurrent.wait_for_request                                      *--
  --*               : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*   Tables Used : None                                                                 *--
  --*         Logic : Submit a request for FVIPAPMT using the parameters passed and wait   *--
  --*               : for the request to finish                                            *--
  --****************************************************************************************--
  PROCEDURE kick_off_ipac_auto_pmt_process
  (
    p_batch_name           IN  VARCHAR2,
    p_payment_bank_acct_id IN  NUMBER,
    p_payment_profile_id        IN  NUMBER,
    p_payment_document_id       IN  NUMBER,
    p_error_code           OUT NOCOPY NUMBER,
    p_error_desc           OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(400);
    l_request_id          NUMBER;
    l_request_wait_status BOOLEAN;
    l_phase               VARCHAR2(100);
    l_status              VARCHAR2(100);
    l_dev_phase           VARCHAR2(100);
    l_dev_status          VARCHAR2(100);
    l_message             VARCHAR2(100);
  BEGIN
    l_module_name := g_module_name || 'kick_off_ipac_auto_pmt_process';
    p_error_code  := g_SUCCESS;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_batch_name     = '||p_batch_name);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_payment_bank_acct_id    = '||p_payment_bank_acct_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_payment_profile_id    = '||p_payment_profile_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_payment_document_id    = '||p_payment_document_id);
 --     fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_pay_trans_code = '||p_pay_trans_code);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling  submit_request');
    END IF;

    fnd_request.set_org_id(g_org_id);
    l_request_id := fnd_request.submit_request
    (
      application => 'FV',
      program     => 'FVIPAPMT',
      description => '',
      start_time  => '',
      sub_request => FALSE ,
      argument1   => p_batch_name,
      argument2   => p_payment_bank_acct_id,
      argument3   => p_payment_profile_id,
      argument4   => p_payment_document_id,
      argument5   => g_org_id,
      argument6   => g_set_of_books_id
    );

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'submit_request retured');
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_request_id = '||l_request_id);
    END IF;

    IF (l_request_id = 0) THEN
      p_error_code := g_FAILURE;
      p_error_desc := 'Failed to submit request for IPAC Automatic Payment Process';
      fv_utility.log_mesg(fnd_log.level_error, l_module_name,p_error_desc) ;
    ELSE
      COMMIT;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling  wait_for_request');
      END IF;
      l_request_wait_status := fnd_concurrent.wait_for_request
      (
        request_id => l_request_id,
        interval   => 20,
        max_wait   => 0,
        phase      => l_phase,
        status     => l_status,
        dev_phase  => l_dev_phase,
        dev_status => l_dev_status,
        message    => l_message
      );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'wait_for_request retured');
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_phase      = '||l_phase);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_status     = '||l_status);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_dev_phase  = '||l_dev_phase);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_dev_status = '||l_dev_status);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_message    = '||l_message);
      END IF;

      COMMIT;

      IF l_request_wait_status = FALSE THEN
        p_error_code := g_FAILURE;
        p_error_desc := 'Failed to wait for IPAC Automatic Payment Process';
        fv_utility.log_mesg(fnd_log.level_error, l_module_name,p_error_desc) ;
      END IF;
    END IF;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;

  --****************************************************************************************--
  --*          Name : kick_off_ap_invoices_import                                          *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : Procedure to kick of the concurrent process                          *--
  --*               : Payables Open Interface Import (APXIIMPT)                            *--
  --*    Parameters : p_batch_name     IN  The batch name to be passed to conc pgm         *--
  --*               : p_group_id       IN  The group id to be passed to conc pgm           *--
  --*               : p_errbuf         OUT Error returned to the concurrent process        *--
  --*               : p_retcode        OUT Return Code to concurrent process               *--
  --*   Global Vars : g_org_id                        READ                                 *--
  --*               : g_module_name                   READ                                 *--
  --*               : g_SUCCESS                       READ                                 *--
  --*               : g_ERROR                         READ                                 *--
  --*               : fnd_log.level_statement         READ                                 *--
  --*               : fnd_log.g_current_runtime_level READ                                 *--
  --*               : fnd_log.level_unexpected        READ                                 *--
  --*               : fnd_log.level_procedure         READ                                 *--
  --*               : g_enter                         READ                                 *--
  --*               : g_exit                          READ                                 *--
  --*   Called from : main                                                                 *--
  --*         Calls : fnd_request.set_org_id                                               *--
  --*               : fnd_request.submit_request                                           *--
  --*               : fnd_concurrent.wait_for_request                                      *--
  --*               : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*   Tables Used : None                                                                 *--
  --*         Logic : Submit a request for APXIIMPT using the parameters passed and wait   *--
  --*               : for the request to finish                                            *--
  --****************************************************************************************--
  PROCEDURE kick_off_ap_invoices_import
  (
    p_batch_name           IN  VARCHAR2,
    p_group_id             IN  NUMBER,
    p_error_code           OUT NOCOPY NUMBER,
    p_error_desc           OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(400);
    l_request_id          NUMBER;
    l_request_wait_status BOOLEAN;
    l_phase               VARCHAR2(100);
    l_status              VARCHAR2(100);
    l_dev_phase           VARCHAR2(100);
    l_dev_status          VARCHAR2(100);
    l_message             VARCHAR2(100);
  BEGIN
    l_module_name := g_module_name || 'kick_off_ap_invoices_import';
    p_error_code  := g_SUCCESS;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_batch_name = '||p_batch_name);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_group_id   = '||p_group_id);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling  submit_request');
    END IF;


    fnd_request.set_org_id(g_org_id);
    l_request_id := fnd_request.submit_request
    (
      application => 'SQLAP',
      program     => 'APXIIMPT',
      description => '',
      start_time  => '',
      sub_request => FALSE ,
      argument1 => g_org_id ,
      argument2   => 'IPAC',
      argument3  => p_group_id,
      argument4  => p_batch_name,
      argument5   => '',
      argument6   => '',
      argument7   => '',
      argument8   => 'Y',
      argument9   => '',
      argument10   => '',
      argument11  => '',
      argument12  => '',
      argument13  => '',
      argument14  => ''
    ) ;


    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'submit_request retured');
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_request_id = '||l_request_id);
    END IF;

    IF (l_request_id = 0) THEN
      p_error_code := g_FAILURE;
      p_error_desc := 'Failed to submit request for "Payables Open Interface Import" Program';
      fv_utility.log_mesg(fnd_log.level_error, l_module_name,p_error_desc) ;
    ELSE
      COMMIT;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling  wait_for_request');
      END IF;
      l_request_wait_status := fnd_concurrent.wait_for_request
      (
        request_id => l_request_id,
        interval   => 20,
        max_wait   => 0,
        phase      => l_phase,
        status     => l_status,
        dev_phase  => l_dev_phase,
        dev_status => l_dev_status,
        message    => l_message
      );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'wait_for_request retured');
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_phase      = '||l_phase);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_status     = '||l_status);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_dev_phase  = '||l_dev_phase);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_dev_status = '||l_dev_status);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_message    = '||l_message);
      END IF;

      COMMIT;

      IF l_request_wait_status = FALSE THEN
        p_error_code := g_FAILURE;
        p_error_desc := 'Failed to wait for the payables open interface';
        fv_utility.log_mesg(fnd_log.level_error, l_module_name,p_error_desc) ;
      END IF;
    END IF;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;

  --****************************************************************************************--
  --*          Name : kick_off_exception_report                                            *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : Procedure to kick of the concurrent process                          *--
  --*               : IPAC Disbursement Exception Report (FVIPDISR)                        *--
  --*    Parameters : p_data_file_name       IN  The data file name passed to conc pgm     *--
  --*               : p_agency_location_code IN  The alc passed to the conc pgm            *--
  --*               : p_group_id             IN  The group id passed to tbe conc pgm       *--
  --*               : p_errbuf               OUT Error returned to the concurrent process  *--
  --*               : p_retcode              OUT Return Code to concurrent process         *--
  --*   Global Vars : g_org_id                        READ                                 *--
  --*               : g_module_name                   READ                                 *--
  --*               : g_SUCCESS                       READ                                 *--
  --*               : g_ERROR                         READ                                 *--
  --*               : fnd_log.level_statement         READ                                 *--
  --*               : fnd_log.g_current_runtime_level READ                                 *--
  --*               : fnd_log.level_procedure         READ                                 *--
  --*               : fnd_log.level_unexpected        READ                                 *--
  --*               : g_enter                         READ                                 *--
  --*               : g_exit                          READ                                 *--
  --*   Called from : main                                                                 *--
  --*         Calls : fnd_request.set_org_id                                               *--
  --*               : fnd_request.submit_request                                           *--
  --*               : fnd_concurrent.wait_for_request                                      *--
  --*               : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*   Tables Used : None                                                                 *--
  --*         Logic : Submit a request for FVIPDISR using the parameters passed and wait   *--
  --*               : for the request to finish                                            *--
  --****************************************************************************************--
  PROCEDURE kick_off_exception_report
  (
    p_data_file_name       IN  VARCHAR2,
    p_agency_location_code IN  VARCHAR2,
    p_group_id             IN  NUMBER,
    p_error_code           OUT NOCOPY NUMBER,
    p_error_desc           OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(400);
    l_request_id          NUMBER;
    l_request_wait_status BOOLEAN;
    l_phase               VARCHAR2(100);
    l_status              VARCHAR2(100);
    l_dev_phase           VARCHAR2(100);
    l_dev_status          VARCHAR2(100);
    l_message             VARCHAR2(100);
  BEGIN
    l_module_name := g_module_name || 'kick_off_exception_report';
    p_error_code  := g_SUCCESS;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_data_file_name       = '||p_data_file_name);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_agency_location_code = '||p_agency_location_code);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_group_id             = '||p_group_id);
    END IF;

    -- The request below submits the IPAC Disbursement Exception Report. The report should
    -- be submitted even if there are no valid records for the Payables Open Interface
    -- Import process
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling  submit_request');
    END IF;

    fnd_request.set_org_id(g_org_id);
    l_request_id := fnd_request.submit_request
    (
      application => 'FV',
      program     => 'FVIPDISR',
      description => '',
      start_time  => '',
      sub_request => FALSE ,
      argument1   => p_data_file_name,
      argument2   => p_agency_location_code,
      argument3   => p_group_id,
      argument4   => g_org_id,
      argument5   => g_set_of_books_id
    );

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'submit_request retured');
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_request_id = '||l_request_id);
    END IF;

    IF (l_request_id = 0) THEN
      p_error_code := g_FAILURE;
      p_error_desc := 'Failed to submit request for IPAC Disbursement Exception Report';
      fv_utility.log_mesg(fnd_log.level_error, l_module_name,p_error_desc) ;
    ELSE
      COMMIT;
    END IF;


    IF (p_error_code = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling  wait_for_request');
      END IF;
      l_request_wait_status := fnd_concurrent.wait_for_request
      (
        request_id => l_request_id,
        interval   => 20,
        max_wait   => 0,
        phase      => l_phase,
        status     => l_status,
        dev_phase  => l_dev_phase,
        dev_status => l_dev_status,
        message    => l_message
      );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'wait_for_request retured');
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_phase      = '||l_phase);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_status     = '||l_status);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_dev_phase  = '||l_dev_phase);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_dev_status = '||l_dev_status);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_message    = '||l_message);
      END IF;

      COMMIT;

      IF l_request_wait_status = FALSE THEN
        p_error_code := g_FAILURE;
        p_error_desc := 'Failed to wait for the exception report';
        fv_utility.log_mesg(fnd_log.level_error, l_module_name,p_error_desc) ;
      END IF;
    END IF;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;

  --****************************************************************************************--
  --*          Name : pre_process_data                                                     *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : Procedure used to preprocess the imported data so that it does not   *--
  --*               : get picked up by any other process                                   *--
  --*    Parameters : p_data_file_name       IN  The data file name                        *--
  --*               : p_agency_location_code IN  The agency location Code                  *--
  --*               : p_batch_name           OUT The batch name                            *--
  --*               : p_group_id             OUT The group id                              *--
  --*               : p_errbuf               OUT Error returned to the concurrent process  *--
  --*               : p_retcode              OUT Return Code to concurrent process         *--
  --*   Global Vars : g_module_name                   READ                                 *--
  --*               : g_SUCCESS                       READ                                 *--
  --*               : g_ERROR                         READ                                 *--
  --*               : fnd_log.level_statement         READ                                 *--
  --*               : fnd_log.g_current_runtime_level READ                                 *--
  --*               : fnd_log.level_unexpected        READ                                 *--
  --*               : fnd_log.level_procedure         READ                                 *--
  --*               : g_enter                         READ                                 *--
  --*               : g_exit                          READ                                 *--
  --*   Called from : process_data                                                         *--
  --*         Calls : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --* Sequence Used : ap_interface_groups_s                                                *--
  --*               : fv_ipac_batch_s                                                      *--
  --*   Tables Used : fv_ipac_import        DELETE, UPDATE                                 *--
  --*         Logic : 1. Get sequence number from fv_ipac_batch_s                          *--
  --*               : 2. Get sequence number from ap_interface_groups_s                    *--
  --*               : 3. Delete records from fv_ipac_import which does not belong to the   *--
  --*               :    parameter alc code.                                               *--
  --*               : 4. Delete records from fv_ipac_import where transction type is in    *--
  --*               :    A or P.                                                           *--
  --*               : 5. Update the who coulumns and other columns with relevant           *--
  --*               :    information                                                       *--
  --****************************************************************************************--
  PROCEDURE pre_process_data
  (
    p_data_file_name       IN  VARCHAR2,
    p_agency_location_code IN  VARCHAR2,
    p_batch_name           OUT NOCOPY VARCHAR2,
    p_group_id             OUT NOCOPY NUMBER,
    p_error_code           OUT NOCOPY NUMBER,
    p_error_desc           OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(400);
    l_rowcount            NUMBER;
  BEGIN
    l_module_name := g_module_name || 'pre_process_data';
    p_error_code  := g_SUCCESS;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_agency_location_code = '||p_agency_location_code);
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      -- determine batch name for ipac payment interface submission.
      BEGIN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Selecting ap_interface_groups_s');
        END IF;
        SELECT 'IPAC'||TO_CHAR(fv_ipac_batch_s.NEXTVAL),
               ap_interface_groups_s.NEXTVAL
          INTO p_batch_name,
               p_group_id
          FROM dual;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_batch_name = '||p_batch_name);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_group_id   = '||p_group_id);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'.select_fv_ipac_batch_s_nextval';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      BEGIN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Updating fv_ipac_import');
        END IF;
        UPDATE fv_ipac_import
           SET request_id = g_request_id,
               record_status = g_status_preprocessed,
               created_by = g_user_id,
               last_updated_by = g_user_id,
               last_update_date = SYSDATE,
               batch_name = p_batch_name,
               org_id = g_org_id,
               set_of_books_id = g_set_of_books_id,
               group_id = p_group_id,
               data_file = p_data_file_name
         WHERE request_id = -1
           AND record_status = g_status_imported;
        l_rowcount := SQL%ROWCOUNT;
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Updated '||l_rowcount||' rows.');
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'.update_fv_ipac_import';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;

/*
    IF (p_error_code = g_SUCCESS) THEN
      BEGIN
        -- Delete all 'A' and 'P' records and keep only valid disbursement records
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Deleting fv_ipac_import');
        END IF;
        DELETE fv_ipac_import
         WHERE group_id = p_group_id
           AND record_status = g_status_preprocessed
            AND (transaction_type IN ('A', 'P')
            OR customer_alc <> p_Agency_Location_Code);
        l_rowcount := SQL%ROWCOUNT;
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Deleted '||l_rowcount||' rows.');
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_module_name||'.update_fv_ipac_import',p_error_desc) ;
      END;
    END IF;
*/

    IF (p_error_code = g_SUCCESS) THEN
      -- Reject all 'A' and 'P' records and keep only valid disbursement records
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Rejecting fv_ipac_import for A and P records');
      END IF;
      FOR del_rec IN (SELECT ipac_import_id
                        FROM fv_ipac_import
                       WHERE group_id = p_group_id
                         AND record_status = g_status_preprocessed
                         AND transaction_type IN ('A', 'P')) LOOP
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling insert_error');
        END IF;
        insert_error
        (
          p_ipac_import_id  => del_rec.ipac_import_id,
          p_validation_code => 'INVALID_TXN_TYPE',
          p_validation_err  => 'Transaction type is A or P.',
          p_error_code      => p_error_code,
          p_error_desc      => p_error_desc
        );

        BEGIN
          UPDATE fv_ipac_import
             SET record_status = g_status_error
           WHERE ipac_import_id = del_rec.ipac_import_id;
        EXCEPTION
          WHEN OTHERS THEN
            p_error_code := g_FAILURE;
            p_error_desc := SQLERRM;
            l_location   := l_module_name||'.update_fv_ipac_import1';
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
        END;
      END LOOP;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      -- Reject all non selected ALC records
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Rejecting not selected ALC records');
      END IF;
      FOR del_rec IN (SELECT ipac_import_id
                        FROM fv_ipac_import
                       WHERE group_id = p_group_id
                         AND record_status = g_status_preprocessed
                         AND customer_alc <> p_Agency_Location_Code) LOOP
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling insert_error');
        END IF;
        insert_error
        (
          p_ipac_import_id  => del_rec.ipac_import_id,
          p_validation_code => 'INVALID_ALC',
          p_validation_err  => 'Customer ALC is not the selected one.',
          p_error_code      => p_error_code,
          p_error_desc      => p_error_desc
        );

        BEGIN
          UPDATE fv_ipac_import
             SET record_status = g_status_error
           WHERE ipac_import_id = del_rec.ipac_import_id;
        EXCEPTION
          WHEN OTHERS THEN
            p_error_code := g_FAILURE;
            p_error_desc := SQLERRM;
            l_location   := l_module_name||'.update_fv_ipac_import1';
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
        END;
      END LOOP;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;

  --****************************************************************************************--
  --*          Name : process_recurr_invoice                                               *--
  --*          Type : Procedure                                                            *--
  --*       Purpose :                                                                      *--
  --*    Parameters : p_po_num            IN  PO Number                                    *--
  --*               : p_po_line_num       IN  PO Line Number                               *--
  --*               : p_amount            IN  Amount                                       *--
  --*               : p_batch_name        IN  Batch Name                                   *--
  --*               : p_accomplished_date IN  Accomplished Date                            *--
  --*               : p_invoice_found     OUT If invoice is found                          *--
  --*               : p_validation_code   OUT Validation Code                              *--
  --*               : p_validation_err    OUT Validation Error                             *--
  --*               : p_errbuf            Error returned to the concurrent process         *--
  --*               : p_retcode           Return Code to concurrent process                *--
  --*   Global Vars : g_module_name                   READ                                 *--
  --*               : g_SUCCESS                       READ                                 *--
  --*               : g_WARNING                       READ                                 *--
  --*               : g_ERROR                         READ                                 *--
  --*               : fnd_log.level_statement         READ                                 *--
  --*               : fnd_log.g_current_runtime_level READ                                 *--
  --*               : fnd_log.level_unexpected        READ                                 *--
  --*               : fnd_log.level_procedure         READ                                 *--
  --*               : g_enter                         READ                                 *--
  --*               : g_exit                          READ                                 *--
  --*               : g_login_id                      READ                                 *--
  --*               : g_user_id                       READ                                 *--
  --*   Called from : validate_po                                                          *--
  --*         Calls : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*   Tables Used : ap_invoices_v           VIEW, SELECT                                 *--
  --*               : ap_recurring_payments_v VIEW, SELECT                                 *--
  --*               : ap_invoices             VIEW, SELECT                                 *--
  --*               : fv_ipac_recurring_inv   SELECT, INSERT                               *--
  --*         Logic : Already existing code                                                *--
  --****************************************************************************************--
  PROCEDURE process_recurr_invoice
  (
    p_po_num            IN VARCHAR2,
    p_po_line_num       IN NUMBER,
    p_amount            IN NUMBER,
    p_batch_name        IN VARCHAR2,
    p_accomplished_date IN DATE,
    p_invoice_id        OUT NOCOPY NUMBER,
    p_invoice_found     OUT NOCOPY VARCHAR2,
    p_validation_code   OUT NOCOPY VARCHAR2,
    p_validation_err    OUT NOCOPY VARCHAR2,
    p_error_code        OUT NOCOPY NUMBER,
    p_error_desc        OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name VARCHAR2(200);
    l_location    VARCHAR2(200);

    l_invoice_id      ap_invoices.invoice_id%TYPE;
    l_approval_code   ap_invoices_v.approval_status_lookup_code%TYPE;
    l_code            VARCHAR2(1);

    CURSOR invoice_cur
    (
      c_po_num      VARCHAR2,
      c_po_line_num NUMBER,
      c_amount      NUMBER
    )
    IS
    SELECT ai.invoice_id,
           ai.approval_status_lookup_code
      FROM ap_invoices_v ai,
           ap_recurring_payments_v arp
     WHERE arp.recurring_payment_id = ai.recurring_payment_id
       AND arp.set_of_books_id = ai.set_of_books_id
       AND arp.po_number = c_po_num
       AND arp.line_num = NVL(c_po_line_num, 1)
       AND ai.source = 'RECURRING INVOICE'
       AND ai.invoice_amount = c_amount
       AND ai.payment_status_flag = 'N'
       AND ai.set_of_books_id = g_set_of_books_id
       AND ai.invoice_date = (SELECT MIN(invoice_date)
                                FROM ap_invoices aib,
                                     ap_recurring_payments_v arpb
                               WHERE aib.source = 'RECURRING INVOICE'
                                 AND aib.set_of_books_id = g_set_of_books_id
                                 AND aib.payment_status_flag = 'N'
                                 AND aib.invoice_amount = c_amount
                                 AND aib.recurring_payment_id = arpb.recurring_payment_id
                                 AND aib.set_of_books_id = arpb.set_of_books_id
                                 AND arpb.po_number = c_po_num
                                 AND arp.line_num = NVL(c_po_line_num,1))
    UNION
    SELECT DISTINCT ai.invoice_id,
           ai.approval_status_lookup_code
      FROM ap_invoices_v ai,
           ap_invoice_distributions_v ali
     WHERE ali.po_number = c_po_num
       AND ai.invoice_id = ali.invoice_id
       AND ali.po_line_number = NVL(c_po_line_num,1)
       AND ai.invoice_amount = c_amount
       AND ai.payment_status_flag = 'N'
       AND ai.set_of_books_id = g_set_of_books_id
       AND ai.source <> 'RECURRING INVOICE'
       AND ai.invoice_type_lookup_code = 'STANDARD'
       AND ai.invoice_date = (SELECT MIN(invoice_date)
                                FROM ap_invoices_v ai1,
                                     ap_invoice_distributions_v ali1
                               WHERE ali1.po_number = c_po_num
                                 AND ai1.invoice_id = ali1.invoice_id
                                 AND ali1.po_line_number = NVL(c_po_line_num,1)
                                 AND ai1.invoice_amount = c_amount
                                 AND ai1.payment_status_flag = 'N'
                                 AND ai1.set_of_books_id = g_set_of_books_id
                                 AND ai1.source <> 'RECURRING INVOICE'
                                 AND ai1.invoice_type_lookup_code = 'STANDARD');

  BEGIN

    l_module_name := g_module_name || 'process_recurr_invoice';
    p_error_code      := g_SUCCESS;
    p_validation_code := NULL;
    p_error_desc      := NULL;
    p_invoice_found   := 'N';
    p_invoice_id      := NULL;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_po_num            = '||p_po_num);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_po_line_num       = '||p_po_line_num);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_amount            = '||p_amount);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_batch_name        = '||p_batch_name);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_accomplished_date = '||TO_CHAR(p_accomplished_date, 'MM/DD/YYYY'));
    END IF;

    -- find an invoice for this recurring payment template.
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Opening cursor invoice_cur');
    END IF;
    OPEN invoice_cur (p_po_num, p_po_line_num, p_amount);
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Fetching cursor invoice_cur');
    END IF;
    FETCH invoice_cur INTO l_invoice_id, l_approval_code;

    IF invoice_cur%NOTFOUND THEN
      NULL;
--      -- this is an exception since no invoice was found
--      fv_utility.log_mesg(fnd_log.level_exception, l_module_name,'No Invoice Found so exception.') ;
--      p_validation_err := 'Cannot find a valid recurring invoice for this Purchase Order';
--      p_validation_code := 'PO_NUM_FOUND_IN_RECURRING_INV';
    ELSE
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_invoice_id    = '||l_invoice_id);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_approval_code = '||l_approval_code);
      END IF;

      -- found an invoice. find approval status of invoice
      IF l_approval_code = 'APPROVED' THEN
        l_code := 'P';  -- create payment only
      ELSIF l_approval_code in ('UNAPPROVED','NEVER APPROVED') THEN
        l_code := 'V';  -- validate invoice and create payment
      ELSE
        l_code := NULL;
        -- this is an exception category since we can't find an invoice to use

        fv_utility.log_mesg(fnd_log.level_exception, l_module_name,'Cannot find an correct invoice');
        p_validation_err := 'Cannot find a valid recurring invoice for this Purchase Order';
        p_validation_code := 'PO_NUM_FOUND_IN_RECURRING_INV';
      END IF;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_code    = '||l_code);
      END IF;

      IF (l_code in ('V','P')) THEN
        -- insert this record if the invoice isn't already there
        -- the automatic payment program will refer to this table to create
        -- a payment for this invoice.
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Inserting into fv_ipac_recurring_inv');
        END IF;
        INSERT INTO fv_ipac_recurring_inv
        (
          batch_name,
          invoice_id,
          invoice_action,
          accomplish_date,
          creation_date,
          created_by,
          last_update_date,
          last_update_login,
          last_updated_by
        )
        SELECT p_batch_name,
               l_invoice_id,
               l_code,
               p_accomplished_date,  --using accomplish date (attribute11)of po
               SYSDATE,
               g_user_id,
               SYSDATE,
               g_login_id,
               g_user_id
          FROM dual
         WHERE NOT EXISTS (SELECT invoice_id
                             FROM fv_ipac_recurring_inv
                            WHERE invoice_id = l_invoice_id
                              AND batch_name = p_batch_name);

        p_invoice_found := 'Y';
        p_invoice_id := l_invoice_id;
      END IF;
    END IF;

    CLOSE invoice_cur;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END process_recurr_invoice;

  --****************************************************************************************--
  --*          Name : resolve_uom                                                          *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This procedure will try to resolve the Unit of Measure against the   *--
  --*               : table mtl_units_of_measure_vl                                        *--
  --*    Parameters : p_ipac_import_id  IN The ipac import id used to insert errors        *--
  --*               : p_uom_code        IN The file UOM code                               *--
  --*               : p_unit_of_measure IN OUT Resolved UOM code                           *--
  --*               : p_record_status   OUT Record Status                                  *--
  --*               : p_errbuf          Error returned to the concurrent process           *--
  --*               : p_retcode         Return Code to concurrent process                  *--
  --*   Global Vars : g_module_name                   READ                                 *--
  --*               : g_SUCCESS                       READ                                 *--
  --*               : g_ERROR                         READ                                 *--
  --*               : fnd_log.level_statement         READ                                 *--
  --*               : fnd_log.g_current_runtime_level READ                                 *--
  --*               : fnd_log.level_unexpected        READ                                 *--
  --*               : fnd_log.level_procedure         READ                                 *--
  --*               : g_enter                         READ                                 *--
  --*               : g_exit                          READ                                 *--
  --*   Called from : process_data                                                         *--
  --*         Calls : insert_error                                                         *--
  --*               : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*   Tables Used : mtl_units_of_measure_vl VIEW, SELECT                                 *--
  --*         Logic : 1. Check to see if the input UOM code is uom_code from table         *--
  --*               :    mtl_units_of_measure_vl                                           *--
  --*               : 2. If so return the unit of measure from the table in resolved UOM   *--
  --*               :    code and return                                                   *--
  --*               : 3. Check to see if the input UOM code is unit_of_measure from table  *--
  --*               :    mtl_units_of_measure_vl                                           *--
  --*               : 4. If so return the unit of measure from the table in resolved UOM   *--
  --*               :    code and return                                                   *--
  --*               : 5. If the UOM could not be resolved insert an error                  *--
  --****************************************************************************************--
  PROCEDURE resolve_uom
  (
    p_ipac_import_id     IN  fv_ipac_import.ipac_import_id%TYPE,
    p_uom_code           IN  mtl_units_of_measure_vl.uom_code%TYPE,
    p_unit_of_measure    IN OUT NOCOPY mtl_units_of_measure_vl.unit_of_measure%TYPE,
    p_record_status      OUT NOCOPY fv_ipac_import.record_status%TYPE,
    p_error_code         OUT NOCOPY NUMBER,
    p_error_desc         OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name              VARCHAR2(200);
    l_location                 VARCHAR2(200);
    l_unit_of_measure          mtl_units_of_measure_vl.unit_of_measure%TYPE;
  BEGIN
    l_module_name     := g_module_name || 'resolve_uom';
    p_error_code      := g_SUCCESS;
    l_unit_of_measure := NULL;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_uom_code        = '||p_uom_code);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_unit_of_measure = '||p_unit_of_measure);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Selecting from mtl_units_of_measure_vl1');
    END IF;

    BEGIN
      SELECT unit_of_measure
        INTO l_unit_of_measure
        FROM mtl_units_of_measure_vl
       WHERE uom_code = p_uom_code;
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_unit_of_measure='||l_unit_of_measure);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'no data found');
        END IF;
        l_unit_of_measure := NULL;
      WHEN OTHERS THEN
        p_error_code := g_FAILURE;
        p_error_desc := SQLERRM;
        l_location   := l_module_name||'.select_mtl_units_of_measure_vl1';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
    END;

    IF (p_error_code = g_SUCCESS) THEN
      IF (l_unit_of_measure IS NOT NULL) THEN
        p_unit_of_measure := l_unit_of_measure;
      ELSE
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Selecting from mtl_units_of_measure_vl1');
        END IF;
        BEGIN
          SELECT unit_of_measure
            INTO l_unit_of_measure
            FROM mtl_units_of_measure_vl
           WHERE unit_of_measure = p_unit_of_measure;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'no data found');
            END IF;
            l_unit_of_measure := NULL;
          WHEN OTHERS THEN
            p_error_code := g_FAILURE;
            p_error_desc := SQLERRM;
            l_location   := l_module_name||'.select_mtl_units_of_measure_vl2';
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
        END;
      END IF;
    END IF;
    IF (p_error_code = g_SUCCESS) THEN
      IF (l_unit_of_measure IS NULL) THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling insert_error');
        END IF;
        insert_error
        (
          p_ipac_import_id  => p_ipac_import_id,
          p_validation_code => 'INVALID_UOM',
          p_validation_err  => 'Invalid Unit of Measure',
          p_error_code      => p_error_code,
          p_error_desc      => p_error_desc
        );
        IF (p_error_code = g_SUCCESS) THEN
          p_record_status := g_status_error;
        END IF;
      END IF;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_unit_of_measure='||p_unit_of_measure);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_record_status='||p_record_status);
    END IF;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;


  --****************************************************************************************--
  --*          Name : validate_duns                                                        *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : Validated the DUNS and DUNS PLUS FOUR code against CCR               *--
  --*    Parameters : p_ipac_import_rec IN OUT The IPAC import record                      *--
  --*               : p_errbuf          OUT Error returned to the concurrent process       *--
  --*               : p_retcode         OUT Return Code to concurrent process              *--
  --*   Global Vars : g_module_name                   READ                                 *--
  --*               : g_SUCCESS                       READ                                 *--
  --*               : g_ERROR                         READ                                 *--
  --*               : fnd_log.level_statement         READ                                 *--
  --*               : fnd_log.g_current_runtime_level READ                                 *--
  --*               : fnd_log.level_unexpected        READ                                 *--
  --*               : fnd_log.level_procedure         READ                                 *--
  --*               : g_enter                         READ                                 *--
  --*               : g_exit                          READ                                 *--
  --*   Called from : process_data                                                         *--
  --*         Calls : insert_error                                                         *--
  --*               : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*   Tables Used : fv_ccr_vendors  SELECT                                               *--
  --*               : po_vendor_sites SELECT                                               *--
  --*         Logic : 1. Check against fv_ccr_vendors to see if a record exists with the   *--
  --*               :    specific vendor id duns and duns+4 combination                    *--
  --*               : 2. If no record exists then provide an error DUNS_NOT_SETUP and      *--
  --*               :    insert the error and return.                                      *--
  --*               : 3. Get the vendor site id using the duns and duns+4 combinatiion     *--
  --*               :    from po_vendor_sites table                                        *--
  --*               : 4. If no record exists then provide an error INAVALID_SITE_CODE and  *--
  --*               :    insert the error and return.                                      *--
  --*               : 5. If the site id does not match with the PO site id, then provide   *--
  --*               :    an error PO_SITE_MISMATCH and insert the error and return         *--
  --****************************************************************************************--
  PROCEDURE validate_duns
  (
    p_ipac_import_rec    IN OUT NOCOPY fv_ipac_import%ROWTYPE,
    p_error_code         OUT NOCOPY NUMBER,
    p_error_desc         OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name              VARCHAR2(200);
    l_location                 VARCHAR2(200);
    l_dummy                    VARCHAR2(1);
    l_validation_code          fv_ipac_import_errors.error_code%TYPE;
    l_validation_err           fv_ipac_import_errors.error_desc%TYPE;
    l_vendor_site_id           po_vendor_sites.vendor_site_id%TYPE;
  BEGIN
    l_module_name     := g_module_name || 'validate_duns';
    p_error_code      := g_SUCCESS;
    p_error_desc      := NULL;
    l_validation_code := NULL;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_ipac_import_rec.vendor_id='||p_ipac_import_rec.vendor_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_ipac_import_rec.receiver_duns='||p_ipac_import_rec.receiver_duns);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_ipac_import_rec.receiver_duns_4='||p_ipac_import_rec.receiver_duns_4);
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      BEGIN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Select fv_ccr_vendors');
        END IF;
        SELECT 'X'
          INTO l_dummy
          FROM fv_ccr_vendors fcv
         WHERE fcv.vendor_id = p_ipac_import_rec.vendor_id
           AND fcv.duns = p_ipac_import_rec.receiver_duns
           AND NVL(fcv.plus_four, '-1') = NVL(p_ipac_import_rec.receiver_duns_4, '-1');
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'no data found');
          END IF;
          l_validation_err := 'Invalid DUNS and DUNS PLUS FOUR combination';
          l_validation_code := 'DUNS_NOT_SETUP';
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'.select_po_headers';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;

    IF (p_error_code = g_SUCCESS AND l_validation_code IS NULL) THEN
      BEGIN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Select po_vendor_sites');
        END IF;
        SELECT vendor_site_id
          INTO l_vendor_site_id
          FROM po_vendor_sites pvs
         WHERE pvs.vendor_id = p_ipac_import_rec.vendor_id
           AND pvs.vendor_site_code = p_ipac_import_rec.receiver_duns||p_ipac_import_rec.receiver_duns_4;
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_vendor_site_id='||l_vendor_site_id);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'no data found');
          END IF;
          l_validation_err := 'Invalid Site Code for DUNS and DUNS PLUS FOUR combination';
          l_validation_code := 'INAVALID_SITE_CODE';
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'.select_po_headers';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;

    IF (p_error_code = g_SUCCESS AND l_validation_code IS NULL) THEN
      IF (l_vendor_site_id <> p_ipac_import_rec.vendor_site_id) THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'no match');
        END IF;
        l_validation_err := 'Purchase Order SITE does not match the DUNS Site';
        l_validation_code := 'PO_SITE_MISMATCH';
      END IF;
    END IF;

    IF (l_validation_code IS NOT NULL AND p_error_code = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling insert_error');
      END IF;
      insert_error
      (
        p_ipac_import_id  => p_ipac_import_rec.ipac_import_id,
        p_validation_code => l_validation_code,
        p_validation_err  => l_validation_err,
        p_error_code      => p_error_code,
        p_error_desc      => p_error_desc
      );
      IF (p_error_code = g_SUCCESS) THEN
        p_ipac_import_rec.record_status := g_status_error;
      END IF;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_ipac_import_rec.record_status='||p_ipac_import_rec.record_status);
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;

  --****************************************************************************************--
  --*          Name : validate_po                                                          *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This procedure validates the PO number and Line Number               *--
  --*    Parameters : p_ipac_import_rec  IN OUT The import record                          *--
  --*               : p_ap_inv_lines_rec IN OUT Invoice Lines record                       *--
  --*               : p_errbuf           OUT Error returned to the concurrent process      *--
  --*               : p_retcode          OUT Return Code to concurrent process             *--
  --*   Global Vars : g_module_name                   READ                                 *--
  --*               : g_SUCCESS                       READ                                 *--
  --*               : g_ERROR                         READ                                 *--
  --*               : fnd_log.level_statement         READ                                 *--
  --*               : fnd_log.g_current_runtime_level READ                                 *--
  --*               : fnd_log.level_unexpected        READ                                 *--
  --*               : fnd_log.level_procedure         READ                                 *--
  --*               : g_enter                         READ                                 *--
  --*               : g_exit                          READ                                 *--
  --*   Called from : process_data                                                         *--
  --*         Calls : process_recurr_invoice                                               *--
  --*               : insert_error                                                         *--
  --*               : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*   Tables Used : po_headers                   SELECT                                  *--
  --*               : po_distributions             SELECT                                  *--
  --*               : po_lines                     SELECT                                  *--
  --*               : ap_invoice_distributions     SELECT                                  *--
  --*               : ap_recurring_payments_v      SELECT                                  *--
  --*         Logic :                                                                      *--
  --****************************************************************************************--
  PROCEDURE validate_po
  (
    p_ipac_import_rec    IN OUT NOCOPY fv_ipac_import%ROWTYPE,
    p_ap_inv_lines_rec   IN OUT NOCOPY ap_invoice_lines_interface%ROWTYPE,
    p_error_code         OUT NOCOPY NUMBER,
    p_error_desc         OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name              VARCHAR2(200);
    l_location                 VARCHAR2(200);
    l_hdr_closed_code          po_headers.closed_code%TYPE;
    l_line_closed_code         po_lines.closed_code%TYPE;
    l_count_po_disb_lines      NUMBER;
    l_count_matched_disb_lines NUMBER;
    l_exists                   NUMBER;
    l_validation_code          fv_ipac_import_errors.error_code%TYPE;
    l_validation_err           fv_ipac_import_errors.error_desc%TYPE;
    l_invoice_found            VARCHAR2(1);
    l_amount                   NUMBER;
    l_recurr_invoice_id        NUMBER;
  BEGIN
    l_module_name     := g_module_name || 'validate_po';
    p_error_code      := g_SUCCESS;
    p_error_desc      := NULL;
    l_invoice_found   := 'N';

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'po_number         = '||p_ipac_import_rec.purchase_order_number);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'batch_name        = '||p_ipac_import_rec.batch_name);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'accomplished_date = '||p_ipac_import_rec.accomplished_date);
    END IF;

    -- Isolate the po_number if the po_number value contains both po_number and line_number
    IF INSTR(p_ipac_import_rec.purchase_order_number,'/',1,1) > 0 THEN
      p_ap_inv_lines_rec.po_number := SUBSTR(p_ipac_import_rec.purchase_order_number,1,INSTR(p_ipac_import_rec.purchase_order_number,'/',1,1)-1) ;
    ELSE
      p_ap_inv_lines_rec.po_number := p_ipac_import_rec.purchase_order_number;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'derived po_number = '||p_ap_inv_lines_rec.po_number);
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Selecting from po_headers');
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'segment1='||p_ap_inv_lines_rec.po_number);
      END IF;
      BEGIN
        SELECT po_header_id,
               closed_code,
               vendor_id,
               vendor_site_id
          INTO p_ap_inv_lines_rec.po_header_id,
               l_hdr_closed_code,
               p_ipac_import_rec.vendor_id,
               p_ipac_import_rec.vendor_site_id
          FROM po_headers
         WHERE segment1 = p_ap_inv_lines_rec.po_number;
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'po_header_id   = '||p_ap_inv_lines_rec.po_header_id);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'closed_code    = '||l_hdr_closed_code);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'vendor_id      = '||p_ipac_import_rec.vendor_id);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'vendor_site_id = '||p_ipac_import_rec.vendor_site_id);
        END IF;
        IF (l_hdr_closed_code IN ('CLOSED','FINALLY CLOSED')) THEN
          l_validation_err := 'Purchase Order is closed';
          l_validation_code := 'PO_CLOSED';
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Validation Error:'||l_validation_code);
          END IF;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_validation_err := 'Invalid Purchase Order';
          l_validation_code := 'INVALID_PO_NUM';
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'NO DATA Validation Error:'||l_validation_code);
          END IF;
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'.select_po_headers';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;

    IF (p_error_code = g_SUCCESS AND l_validation_code IS NULL) THEN
      BEGIN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Selecting from po_distributions and lines');
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'po_header_id='||p_ap_inv_lines_rec.po_header_id);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'set_of_books_id='||g_set_of_books_id);
        END IF;

        SELECT COUNT(*)
          INTO l_count_po_disb_lines
          FROM po_distributions pd,
               po_lines pl
         WHERE pd.po_header_id = p_ap_inv_lines_rec.po_header_id
           AND pl.po_line_id = pd.po_line_id
           AND pd.set_of_books_id = g_set_of_books_id;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_count_po_disb_lines='||l_count_po_disb_lines);
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'.select_po_distributions1';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;

    IF (p_error_code = g_SUCCESS AND l_validation_code IS NULL) THEN
      BEGIN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Selecting from po_distributions, lines and ap_invoice_distributions');
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'po_header_id='||p_ap_inv_lines_rec.po_header_id);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'set_of_books_id='||g_set_of_books_id);
        END IF;

        SELECT COUNT(*)
          INTO l_count_matched_disb_lines
          FROM ap_invoice_distributions aid ,
               po_distributions pd ,
               po_lines pl
         WHERE aid.po_distribution_id = pd.po_distribution_id
           AND pd.po_header_id = p_ap_inv_lines_rec.po_header_id
           AND pl.po_line_id = pd.po_line_id
           AND aid.final_match_flag = 'D'
           AND aid.set_of_books_id = pd.set_of_books_id
           AND aid.set_of_books_id = g_set_of_books_id ;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_count_matched_disb_lines='||l_count_matched_disb_lines);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'.select_po_distributions2';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;

    IF (p_error_code = g_SUCCESS AND l_validation_code IS NULL) THEN
      IF (l_count_po_disb_lines = l_count_matched_disb_lines) AND (l_count_matched_disb_lines <> 0) THEN
        l_validation_err := 'Purchase Order is finally matched';
        l_validation_code := 'PO_FINALLY_MATCHED';
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Validation Error:'||l_validation_code);
        END IF;
      END IF;
    END IF;

    IF (p_error_code = g_SUCCESS AND l_validation_code IS NULL) THEN
      IF INSTR(p_ipac_import_rec.purchase_order_number,'/',1,1) = 0 THEN
        p_ap_inv_lines_rec.po_line_number := NULL;
      ELSE
        BEGIN
          p_ap_inv_lines_rec.po_line_number := TO_NUMBER(SUBSTR(p_ipac_import_rec.purchase_order_number,INSTR(p_ipac_import_rec.purchase_order_number,'/',1,1)+1));
        EXCEPTION
          WHEN VALUE_ERROR THEN
            p_ap_inv_lines_rec.po_line_number := NULL;
            l_validation_err := 'Invalid Purchase Order Line Number';
            l_validation_code := 'INVALID_LINE_NUM';
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Validation Error:'||l_validation_code);
            END IF;
          WHEN OTHERS THEN
            p_error_code := g_FAILURE;
            p_error_desc := SQLERRM;
            l_location   := l_module_name||'.check_po_line_number';
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
        END;
      END IF;
    END IF;

    IF (p_error_code = g_SUCCESS AND l_validation_code IS NULL) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'po_line_number='||p_ap_inv_lines_rec.po_line_number);
      END IF;
      BEGIN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Selecting from po_lines');
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'po_header_id = '||p_ap_inv_lines_rec.po_header_id);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'line_num     = '||p_ap_inv_lines_rec.po_line_number);
        END IF;

        SELECT pl.po_line_id,
               pl.closed_code,
               pl.unit_meas_lookup_code
          INTO p_ap_inv_lines_rec.po_line_id,
               l_line_closed_code,
               p_ap_inv_lines_rec.po_unit_of_measure
          FROM po_lines pl
         WHERE po_header_id = p_ap_inv_lines_rec.po_header_id
           AND line_num = NVL(p_ap_inv_lines_rec.po_line_number, 1);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Selecting from po_lines');
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'po_line_id            = '||p_ap_inv_lines_rec.po_line_id);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'closed_code           = '||l_line_closed_code);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'unit_meas_lookup_code = '||p_ap_inv_lines_rec.po_unit_of_measure);
        END IF;

          IF (l_line_closed_code IN ('CLOSED','FINALLY CLOSED')) THEN
            l_validation_err := 'Purchase Order Line Number is closed';
            l_validation_code := 'PO_LINE_NUM_CLOSED';
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Validation Error:'||l_validation_code);
            END IF;
          END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_validation_err := 'Invalid Purchase Order Line Number';
          l_validation_code := 'INVALID_LINE_NUM';
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'NO DATA Validation Error:'||l_validation_code);
          END IF;
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'.select_po_lines';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;

    IF (p_error_code = g_SUCCESS AND l_validation_code IS NULL) THEN
      BEGIN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Selecting from po_distributions');
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'po_line_id = '||p_ap_inv_lines_rec.po_line_id);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'set_of_books_id = '||g_set_of_books_id);
        END IF;

        SELECT COUNT(*)
          INTO l_count_po_disb_lines
          FROM po_distributions pd
         WHERE pd.po_line_id = p_ap_inv_lines_rec.po_line_id
           AND pd.set_of_books_id = g_set_of_books_id;

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_count_po_disb_lines='||l_count_po_disb_lines);
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'.select_po_distributions3';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;

    IF (p_error_code = g_SUCCESS AND l_validation_code IS NULL) THEN
      BEGIN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Selecting from po_distributions and ap_invoice_distributions');
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'po_line_id = '||p_ap_inv_lines_rec.po_line_id);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'set_of_books_id = '||g_set_of_books_id);
        END IF;
        SELECT COUNT(*)
          INTO l_count_matched_disb_lines
          FROM ap_invoice_distributions aid ,
               po_distributions pd
         WHERE aid.po_distribution_id = pd.po_distribution_id
           AND pd.po_line_id = p_ap_inv_lines_rec.po_line_id
           AND aid.final_match_flag = 'D'
           AND aid.set_of_books_id = pd.set_of_books_id
           AND aid.set_of_books_id = g_set_of_books_id;
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_count_matched_disb_lines='||l_count_matched_disb_lines);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'.select_po_distributions4';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END;
    END IF;

    IF (p_error_code = g_SUCCESS AND l_validation_code IS NULL) THEN
      IF (l_count_po_disb_lines =  l_count_matched_disb_lines) AND (l_count_matched_disb_lines <> 0) THEN
        l_validation_err := 'Purchase Order Line Number is finally matched';
        l_validation_code := 'PO_LINE_NUM_FINALLY_MATCHED';
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Validation Error:'||l_validation_code);
        END IF;
      END IF;
    END IF;


    IF (p_error_code = g_SUCCESS AND l_validation_code IS NULL) THEN
/*
      --Check whether Recurring Invoice has been created for
      --the PO_NUMBER and LINE_NUMBER.
      BEGIN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Selecting from ap_recurring_payments_v');
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'po_line_id = '||p_ap_inv_lines_rec.po_line_id);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'po_header_id = '||p_ap_inv_lines_rec.po_header_id);
        END IF;
        l_exists := 0;
        SELECT COUNT(*)
          INTO l_exists
          FROM ap_recurring_payments_v aprpv
         WHERE aprpv.po_header_id = p_ap_inv_lines_rec.po_header_id
           AND aprpv.po_line_id  = p_ap_inv_lines_rec.po_line_id;
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_exists='||l_exists);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          p_error_code := g_FAILURE;
          p_error_desc := SQLERRM;
          l_location   := l_module_name||'.ap_recurring_payments_v';
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
          fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      END ;
*/
      --process recurring invoice;
--      IF (p_error_code = g_SUCCESS AND l_exists > 0) THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling process_recurr_invoice');
        END IF;
        process_recurr_invoice
        (
          p_po_num            => p_ap_inv_lines_rec.po_number,
          p_po_line_num       => p_ap_inv_lines_rec.po_line_number,
          p_amount            => p_ipac_import_rec.summary_amount,
          p_batch_name        => p_ipac_import_rec.batch_name,
          p_accomplished_date => p_ipac_import_rec.accomplished_date,
          p_invoice_id        => l_recurr_invoice_id,
          p_invoice_found     => l_invoice_found,
          p_validation_code   => l_validation_code,
          p_validation_err    => l_validation_err,
          p_error_code        => p_error_code,
          p_error_desc        => p_error_desc
        );
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'process_recurr_invoice returned');
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_code ='||p_error_code);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_desc ='||p_error_desc);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_invoice_found ='||l_invoice_found);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_validation_code ='||l_validation_code);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_validation_err ='||l_validation_err);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_recurr_invoice_id ='||l_recurr_invoice_id);
        END IF;
--      END IF;
    END IF;

    IF (l_validation_code IS NOT NULL AND p_error_code = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling insert_error');
      END IF;
      insert_error
      (
        p_ipac_import_id  => p_ipac_import_rec.ipac_import_id,
        p_validation_code => l_validation_code,
        p_validation_err  => l_validation_err,
        p_error_code      => p_error_code,
        p_error_desc      => p_error_desc
      );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'insert_error returned');
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_code ='||p_error_code);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_desc ='||p_error_desc);
      END IF;
      IF (p_error_code = g_SUCCESS) THEN
        p_ipac_import_rec.record_status := g_status_error;
      END IF;
    END IF;

    IF (l_invoice_found = 'Y') THEN
      p_ipac_import_rec.record_status := g_status_processed;
      p_ipac_import_rec.invoice_id := l_recurr_invoice_id;
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_ipac_import_rec.record_status ='||p_ipac_import_rec.record_status);
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;


  --****************************************************************************************--
  --*          Name : save_or_erase_invoice                                                *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This Procedure either saves the invoice or deletes it depending      *--
  --*               : on the flag p_okay_to_insert_inv                                     *--
  --*    Parameters : p_ap_inv_hdr_rec       IN  The invoice header record to be inserted  *--
  --*               : p_previous_inv_number  IN  Previous invoice number                   *--
  --*               : p_okay_to_insert_inv   IN  Is it okay to insert the invoice          *--
  --*               : p_total_invoice_lines  IN  Total Invoice Lines                       *--
  --*               : p_total_invoices       IN OUT Total Invoices                         *--
  --*               : p_errbuf               OUT Error returned to the concurrent process  *--
  --*               : p_retcode              OUT Return Code to concurrent process         *--
  --*   Global Vars : g_module_name                   READ                                 *--
  --*               : g_SUCCESS                       READ                                 *--
  --*               : g_WARNING                       READ                                 *--
  --*               : g_ERROR                         READ                                 *--
  --*               : fnd_log.level_statement         READ                                 *--
  --*               : fnd_log.g_current_runtime_level READ                                 *--
  --*               : fnd_log.level_unexpected        READ                                 *--
  --*               : fnd_log.level_procedure         READ                                 *--
  --*               : g_enter                         READ                                 *--
  --*               : g_exit                          READ                                 *--
  --*   Called from : process_data                                                         *--
  --*         Calls : insert_invoice_hdr                                                   *--
  --*               : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*   Tables Used : ap_invoice_lines_interface DELETE                                    *--
  --*         Logic : 1. If the previous invoice number is not null and if it is okay to   *--
  --*               :    insert the invoice, then insert the invoice header                *--
  --*               : 2. If the previous invoice number is not null and if it is not okay  *--
  --*               :    to insert the invoice and if there are more than 0 lines already  *--
  --*               :    inserted, delete them from ap_invoice_lines_interface             *--
  --****************************************************************************************--
  PROCEDURE save_or_erase_invoice
  (
    p_ap_inv_hdr_rec       IN  ap_invoices_interface%ROWTYPE,
    p_previous_inv_number  IN  ap_invoices_interface.invoice_num%TYPE,
    p_okay_to_insert_inv   IN  VARCHAR2,
    p_total_invoice_lines  IN  NUMBER,
    p_total_invoices       IN OUT NOCOPY NUMBER,
    p_error_code           OUT NOCOPY NUMBER,
    p_error_desc           OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name                  VARCHAR2(200);
    l_location                     VARCHAR2(200);
    l_rowcount                     NUMBER;
  BEGIN
    l_module_name := g_module_name || 'save_or_erase_invoice';
    p_error_code  := g_SUCCESS;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,'p_previous_inv_number = '||p_previous_inv_number);
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,'p_okay_to_insert_inv  = '||p_okay_to_insert_inv);
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,'p_total_invoice_lines = '||p_total_invoice_lines);
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,'p_total_invoices(IN)  = '||p_total_invoices);
    END IF;

    IF ((p_previous_inv_number IS NOT NULL) AND (p_okay_to_insert_inv = 'Y')) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling insert_invoice_hdr');
      END IF;
      insert_invoice_hdr
      (
        p_invoice_hdr_rec      => p_ap_inv_hdr_rec,
        p_error_code           => p_error_code,
        p_error_desc           => p_error_desc
      );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'insert_invoice_hdr returned');
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_code ='||p_error_code);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_desc ='||p_error_desc);
      END IF;
      p_total_invoices := p_total_invoices + 1;
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_total_invoices='||p_total_invoices);
      END IF;
    END IF;

    --****************************************************************************************--
    -- Delete all invoice lines for the previous invoice if there was an error               *--
    --****************************************************************************************--
    IF (p_error_code = g_SUCCESS) THEN
      IF ((p_previous_inv_number IS NOT NULL) AND (p_okay_to_insert_inv = 'N')) THEN
        IF (p_total_invoice_lines > 0) THEN
          BEGIN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Deleting ap_invoice_lines_interface');
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'invoice_id='||p_ap_inv_hdr_rec.invoice_id);
            END IF;

            DELETE ap_invoice_lines_interface
             WHERE invoice_id = p_ap_inv_hdr_rec.invoice_id;
            l_rowcount := SQL%ROWCOUNT;
            IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
              fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,'Deleted '||l_rowcount||' rows from ap_invoice_lines_interface.');
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              p_error_code := g_FAILURE;
              p_error_desc := SQLERRM;
              l_location   := l_module_name||'delete_ap_invoice_lines_interface';
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
          END;
        END IF;
      END IF;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,'p_total_invoices(OUT)  = '||p_total_invoices);
    END IF;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;

  --****************************************************************************************--
  --*          Name : process_data                                                         *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This is the main process that does all the data validations          *--
  --*    Parameters : p_data_file_name       IN  The data file name                        *--
  --*               : p_transaction_code     IN  The transaction code                      *--
  --*               : p_agency_location_code IN  The Agency location code                  *--
  --*               : p_batch_name           OUT Batch name                                *--
  --*               : p_group_id             OUT Group Id                                  *--
  --*               : p_ok_to_import         OUT Is it okay to do ap import                *--
  --*               : p_errbuf               OUT Error returned to the concurrent process  *--
  --*               : p_retcode              OUT Return Code to concurrent process         *--
  --*   Global Vars : g_module_name                   READ                                 *--
  --*               : g_SUCCESS                       READ                                 *--
  --*               : g_WARNING                       READ                                 *--
  --*               : g_ERROR                         READ                                 *--
  --*               : fnd_log.level_statement         READ                                 *--
  --*               : fnd_log.g_current_runtime_level READ                                 *--
  --*               : fnd_log.level_unexpected        READ                                 *--
  --*               : fnd_log.level_procedure         READ                                 *--
  --*               : g_enter                         READ                                 *--
  --*               : g_exit                          READ                                 *--
  --*   Called from : main                                                                 *--
  --*         Calls : save_or_erase_invoice                                                *--
  --*               : validate_po                                                          *--
  --*               : validate_duns                                                        *--
  --*               : resolve_uom                                                          *--
  --*               : insert_invoice_line                                                  *--
  --*               : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --* Sequence Used : ap_invoices_interface_s                                              *--
  --*   Tables Used : fv_ipac_import SELECT, UPDATE                                        *--
  --*         Logic : 1. Pre process the data to  get the group_id handle                  *--
  --*               : 2. Process every record from fv_ipac_import table                    *--
  --*               : 3. Validate the PO.                                                  *--
  --*               : 4. Validate the DUNS                                                 *--
  --*               : 5. Resolve the UOM                                                   *--
  --*               : 6. If all is well insert data into ap interface tables.              *--
  --****************************************************************************************--
  PROCEDURE process_data
  (
    p_data_file_name       IN  VARCHAR2,
    p_agency_location_code IN  VARCHAR2,
    p_batch_name           OUT NOCOPY VARCHAR2,
    p_group_id             OUT NOCOPY NUMBER,
    p_ok_to_import         OUT NOCOPY VARCHAR2,
    p_error_code           OUT NOCOPY NUMBER,
    p_error_desc           OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name                  VARCHAR2(200);
    l_location                     VARCHAR2(200);
    l_ipac_import_record           fv_ipac_import%ROWTYPE;
    l_inv_hdrs_interface_rec       ap_invoices_interface%ROWTYPE;
    l_inv_lines_interface_rec      ap_invoice_lines_interface%ROWTYPE;
    l_inv_hdrs_interface_rec_null  ap_invoices_interface%ROWTYPE;
    l_inv_lines_interface_rec_null ap_invoice_lines_interface%ROWTYPE;
    l_save_invoice_number          fv_ipac_import.invoice_number%TYPE;
    l_ok_to_insert_inv             VARCHAR2(1);
    l_current_inv_lines            NUMBER;
    l_no_of_invoices_inserted      NUMBER;
    l_rowcount                     NUMBER;

    CURSOR ipac_import_cursor
    (
      c_group_id NUMBER
    )IS
    SELECT *
      FROM fv_ipac_import fii
     WHERE fii.group_id = c_group_id
       AND fii.record_status = g_status_preprocessed
     ORDER BY fii.invoice_number;
  BEGIN
    l_module_name := g_module_name || 'process_data';
    p_error_code  := g_SUCCESS;
    l_save_invoice_number := NULL;
    p_ok_to_import := 'N';
    l_ok_to_insert_inv := 'Y';
    l_current_inv_lines := 0;
    l_no_of_invoices_inserted := 0;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_data_file_name       = '||p_data_file_name);
--      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_transaction_code     = '||p_transaction_code);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_agency_location_code = '||p_agency_location_code);
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      --****************************************************************************************--
      --* Pre process the data to get a group_id handle on the data and to update the who      *--
      --* who columns                                                                          *--
      --****************************************************************************************--
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling pre_process_data');
      END IF;
      pre_process_data
      (
        p_data_file_name       => p_data_file_name,
        p_agency_location_code => p_agency_location_code,
        p_batch_name           => p_batch_name,
        p_group_id             => p_group_id,
        p_error_code           => p_error_code,
        p_error_desc           => p_error_desc
      );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'pre_process_data returned');
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_code ='||p_error_code);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_desc ='||p_error_desc);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_group_id   ='||p_group_id);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_batch_name ='||p_batch_name);
      END IF;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      --****************************************************************************************--
      --* Initialize all contants values for invoice lines                                     *--
      --****************************************************************************************--
      l_inv_lines_interface_rec_null.last_updated_by := g_user_id;
      l_inv_lines_interface_rec_null.created_by := g_user_id;
      l_inv_lines_interface_rec_null.creation_date := SYSDATE;
      l_inv_lines_interface_rec_null.last_update_date := SYSDATE;
      l_inv_lines_interface_rec_null.line_type_lookup_code := 'ITEM';
      --****************************************************************************************--
      --* Initialize all contants values for invoice header                                    *--
      --****************************************************************************************--
      l_inv_hdrs_interface_rec_null.last_updated_by := g_user_id;
      l_inv_hdrs_interface_rec_null.created_by := g_user_id;
      l_inv_hdrs_interface_rec_null.creation_date := SYSDATE;
      l_inv_hdrs_interface_rec_null.last_update_date := SYSDATE;
      l_inv_hdrs_interface_rec_null.invoice_amount := 0;
      l_inv_hdrs_interface_rec_null.payment_method_code := 'CLEARING';
      l_inv_hdrs_interface_rec_null.pay_group_lookup_code := g_ia_paygroup;
      l_inv_hdrs_interface_rec_null.source := 'IPAC';
      l_inv_hdrs_interface_rec_null.invoice_received_date := SYSDATE;
      l_inv_hdrs_interface_rec_null.invoice_type_lookup_code := 'STANDARD';
      l_inv_hdrs_interface_rec_null.invoice_currency_code := 'USD';
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      --****************************************************************************************--
      --* Start processing all the ipac import records                                         *--
      --****************************************************************************************--
      FOR ipac_import_record IN ipac_import_cursor (p_group_id) LOOP
        l_ipac_import_record := ipac_import_record;
        l_ipac_import_record.record_status := g_status_no_process;
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Processing Invoice = '||l_ipac_import_record.invoice_number);
        END IF;

        IF (p_error_code = g_SUCCESS) THEN

          --****************************************************************************************--
          --* The current invoice is saved and written only once all the lines are identified.     *--
          --* This is to avoid another database access as the total invoice amount has to be       *--
          --* determined. Once the invoice number changes, the old invoice header has to be        *--
          --* written to the database.                                                             *--
          --****************************************************************************************--

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_save_invoice_number='||l_save_invoice_number);
          END IF;
          IF ((l_save_invoice_number IS NULL) OR
              (l_save_invoice_number <> l_ipac_import_record.invoice_number)) THEN

            --****************************************************************************************--
            --* Write the invoice header or delete invoice lines depending on the flag               *--
            --* l_ok_to_insert_inv                                                                   *--
            --****************************************************************************************--
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling save_or_erase_invoice');
            END IF;
            save_or_erase_invoice
            (
              p_ap_inv_hdr_rec       => l_inv_hdrs_interface_rec,
              p_previous_inv_number  => l_save_invoice_number,
              p_okay_to_insert_inv   => l_ok_to_insert_inv,
              p_total_invoice_lines  => l_current_inv_lines,
              p_total_invoices       => l_no_of_invoices_inserted,
              p_error_code           => p_error_code,
              p_error_desc           => p_error_desc
            );
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling save_or_erase_invoice returned');
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_code ='||p_error_code);
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_desc ='||p_error_desc);
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_no_of_invoices_inserted ='||l_no_of_invoices_inserted);
            END IF;

            --****************************************************************************************--
            --* Initialize all variables for processing a new invoice header                         *--
            --****************************************************************************************--
            IF (p_error_code = g_SUCCESS) THEN
              l_ok_to_insert_inv := 'Y';
              l_current_inv_lines := 0;

              l_inv_hdrs_interface_rec := l_inv_hdrs_interface_rec_null;
              l_inv_hdrs_interface_rec.group_id := p_group_id;
              l_save_invoice_number := l_ipac_import_record.invoice_number;
              l_inv_hdrs_interface_rec.invoice_num := l_ipac_import_record.invoice_number;
              l_inv_hdrs_interface_rec.invoice_date := l_ipac_import_record.accomplished_date;
            END IF;

            IF (p_error_code = g_SUCCESS) THEN
              BEGIN
                --****************************************************************************************--
                --* get the invoice header sequence number                                               *--
                --****************************************************************************************--
                SELECT ap_invoices_interface_s.NEXTVAL
                  INTO l_inv_hdrs_interface_rec.invoice_id
                  FROM DUAL;
                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                  fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'invoice_id ='||l_inv_hdrs_interface_rec.invoice_id);
                END IF;
              EXCEPTION
                WHEN OTHERS THEN
                  p_error_code := g_FAILURE;
                  p_error_desc := SQLERRM;
                  l_location   := l_module_name||'select_ap_invoices_interface_s';
                  fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
                  fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
              END;
            END IF;
          END IF;
        END IF;

        --****************************************************************************************--
        --* Store all interface lines record and also keep on adding invoice header amount       *--
        --****************************************************************************************--
        IF (p_error_code = g_SUCCESS) THEN
          l_inv_lines_interface_rec := l_inv_lines_interface_rec_null;
          l_inv_lines_interface_rec.invoice_id := l_inv_hdrs_interface_rec.invoice_id;
          l_inv_lines_interface_rec.line_number := l_ipac_import_record.detail_line_number;
          l_inv_lines_interface_rec.unit_price := l_ipac_import_record.unit_price;
          l_inv_lines_interface_rec.quantity_invoiced := l_ipac_import_record.quantity;
          l_inv_lines_interface_rec.amount := l_ipac_import_record.detail_amount;
          l_inv_hdrs_interface_rec.invoice_amount := l_inv_hdrs_interface_rec.invoice_amount +
                                                     l_ipac_import_record.detail_amount;
         --Bug 7213192
 	    l_inv_lines_interface_rec.description := SUBSTR(l_ipac_import_record.description,1,240);
          --l_inv_lines_interface_rec.description := l_ipac_import_record.description;
 -- TC Obsoletion
 --         l_inv_lines_interface_rec.ussgl_transaction_code := p_transaction_code;
          IF (l_inv_lines_interface_rec.description IS NULL) THEN
            l_inv_lines_interface_rec.description := 'IPAC Disbursement Ref. Number: '||
                                                     l_ipac_import_record.ipac_doc_ref_number||
                                                     ' Quantity: '||
                                                     l_inv_lines_interface_rec.quantity_invoiced||
                                                     ' Unit Price: '||
                                                     l_ipac_import_record.unit_price||
                                                     ' Contract Num: '||
                                                     l_ipac_import_record.contract_number;
          END IF;
        END IF;

        --****************************************************************************************--
        --* Validate the purchase order and populate the relevant information such as            *--
        --* po_header_id, po_line_id, po_number, po_line_number, vendor_id and vendor_site_id    *--
        --* back to l_ipac_import_record and l_inv_lines_interface_rec                           *--
        --****************************************************************************************--
        IF (p_error_code = g_SUCCESS) THEN
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling validate_po');
          END IF;
          validate_po
          (
            p_ipac_import_rec    => l_ipac_import_record,
            p_ap_inv_lines_rec   => l_inv_lines_interface_rec,
            p_error_code         => p_error_code,
            p_error_desc         => p_error_desc
          );
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling validate_po returned');
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_code ='||p_error_code);
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_desc ='||p_error_desc);
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'record_status ='||l_ipac_import_record.record_status);
          END IF;
        END IF;

        --****************************************************************************************--
        --* validate_po will set the status of l_ipac_import_record to ERROR if there was any    *--
        --* validation error. If the invoice is already part of reecurring invoice then the      *--
        --* status will be set to PROCESSED. In both these cases, no new invoice should be       *--
        --* created and hence the flag l_ok_to_insert_inv to be set to 'N'.                      *--
        --****************************************************************************************--
        IF (p_error_code = g_SUCCESS) THEN
          IF (l_ipac_import_record.record_status IN (g_status_error, g_status_processed)) THEN
            l_ok_to_insert_inv := 'N';
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Going to FINISHED_PROCESS');
            END IF;
            GOTO FINISHED_PROCESS;
          END IF;

          --****************************************************************************************--
          --* vendor_id and vendor_site_id was populated in l_ipac_import_record by validate_po    *--
          --* Since l_inv_hdrs_interface_rec was not passed to validate_po and since this info     *--
          --* is required by the header, populate them from l_ipac_import_record                   *--
          --****************************************************************************************--
          l_inv_hdrs_interface_rec.vendor_id := l_ipac_import_record.vendor_id;
          l_inv_hdrs_interface_rec.vendor_site_id := l_ipac_import_record.vendor_site_id;
        END IF;

        IF (l_ipac_import_record.receiver_duns IS NOT NULL) THEN
          --****************************************************************************************--
          --* Validate the receiver DUNS and DUNS+4 information.                                   *--
          --****************************************************************************************--
          IF (p_error_code = g_SUCCESS) THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling validate_duns');
            END IF;
            validate_duns
            (
              p_ipac_import_rec    => l_ipac_import_record,
              p_error_code         => p_error_code,
              p_error_desc         => p_error_desc
            );
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling validate_duns returned');
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_code ='||p_error_code);
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_desc ='||p_error_desc);
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'record_status ='||l_ipac_import_record.record_status);
            END IF;
          END IF;

          --****************************************************************************************--
          --* validate_duns will set the status of l_ipac_import_record to ERROR if there was any  *--
          --* validation error.                                                                    *--
          --****************************************************************************************--
          IF (p_error_code = g_SUCCESS) THEN
            IF (l_ipac_import_record.record_status = g_status_error) THEN
              l_ok_to_insert_inv := 'N';
              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Going to FINISHED_PROCESS');
              END IF;
              GOTO FINISHED_PROCESS;
            END IF;
          END IF;
        END IF;

        --****************************************************************************************--
        --* The UOM passed in the file is of 2 characters which possibly maps to the UOM in po   *--
        --* But the invoice lines interface requires unit_of_measure and not uom                 *--
        --* Also make sure that the PO UOM is same as File UOM                                   *--
        --****************************************************************************************--
        IF (p_error_code = g_SUCCESS AND l_ok_to_insert_inv = 'Y') THEN
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling resolve_uom');
          END IF;
          resolve_uom
          (
            p_ipac_import_id     => l_ipac_import_record.ipac_import_id,
            p_uom_code           => l_ipac_import_record.unit_of_issue,
            p_unit_of_measure    => l_inv_lines_interface_rec.po_unit_of_measure,
            p_record_status      => l_ipac_import_record.record_status,
            p_error_code         => p_error_code,
            p_error_desc         => p_error_desc
          );
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling resolve_uom returned');
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_code ='||p_error_code);
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_desc ='||p_error_desc);
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_unit_of_measure ='||l_inv_lines_interface_rec.po_unit_of_measure);
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'record_status ='||l_ipac_import_record.record_status);
          END IF;
        END IF;

        IF (p_error_code = g_SUCCESS) THEN
          IF (l_ipac_import_record.record_status = g_status_error) THEN
            l_ok_to_insert_inv := 'N';
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Going to FINISHED_PROCESS');
            END IF;
            GOTO FINISHED_PROCESS;
          END IF;
        END IF;

        --****************************************************************************************--
        --* If all is well, insert the invoice line                                              *--
        --* Remember we haven't inserted the header record unitl now. This happens when the      *--
        --* invoice number changes.                                                              *--
        --****************************************************************************************--
        IF (p_error_code = g_SUCCESS AND l_ok_to_insert_inv = 'Y') THEN
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling insert_invoice_line');
          END IF;
          insert_invoice_line
          (
            p_invoice_lines_rec    => l_inv_lines_interface_rec,
            p_error_code           => p_error_code,
            p_error_desc           => p_error_desc
          );
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling insert_invoice_line returned');
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_code ='||p_error_code);
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_desc ='||p_error_desc);
          END IF;
          l_current_inv_lines := l_current_inv_lines + 1;
          l_ipac_import_record.record_status := g_status_processed;
        ELSE
          l_ipac_import_record.record_status := g_status_other_error;
        END IF;

<<FINISHED_PROCESS>>
        IF (p_error_code = g_SUCCESS) THEN
          BEGIN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Updating fv_ipac_import');
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'record_status='||l_ipac_import_record.record_status);
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'invoice_id='||l_ipac_import_record.invoice_id);
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'invoice_line_id='||l_ipac_import_record.invoice_line_id);
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'actual_po_number='||l_ipac_import_record.actual_po_number);
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'actual_po_line_number='||l_ipac_import_record.actual_po_line_number);
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'vendor_id='||l_ipac_import_record.vendor_id);
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'vendor_site_id='||l_ipac_import_record.vendor_site_id);
              fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'ipac_import_id='||l_ipac_import_record.ipac_import_id);
            END IF;
            UPDATE fv_ipac_import fii
               SET record_status = l_ipac_import_record.record_status,
                   invoice_id = l_ipac_import_record.invoice_id,
                   int_invoice_id = l_inv_lines_interface_rec.invoice_id,
                   int_invoice_line_id = l_inv_lines_interface_rec.invoice_line_id,
                   actual_po_number = l_inv_lines_interface_rec.po_number,
                   actual_po_line_number = l_inv_lines_interface_rec.po_line_number,
                   vendor_id = l_inv_hdrs_interface_rec.vendor_id,
                   vendor_site_id = l_inv_hdrs_interface_rec.vendor_site_id
             WHERE fii.ipac_import_id = l_ipac_import_record.ipac_import_id;
            l_rowcount := SQL%ROWCOUNT;
            IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
              fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,'Updated '||l_rowcount||' rows in fv_ipac_import.');
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              p_error_code := g_FAILURE;
              p_error_desc := SQLERRM;
              l_location   := l_module_name||'update_fv_ipac_import';
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
              fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
          END;
        END IF;

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,'p_error_code1='||p_error_code);
        END IF;
        IF (p_error_code <> g_SUCCESS) THEN
          EXIT;
        END IF;

      END LOOP;

      --Insert the last invoice too.
      IF (p_error_code = g_SUCCESS) THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling save_or_erase_invoice1');
        END IF;
        save_or_erase_invoice
        (
          p_ap_inv_hdr_rec       => l_inv_hdrs_interface_rec,
          p_previous_inv_number  => l_save_invoice_number,
          p_okay_to_insert_inv   => l_ok_to_insert_inv,
          p_total_invoice_lines  => l_current_inv_lines,
          p_total_invoices       => l_no_of_invoices_inserted,
          p_error_code           => p_error_code,
          p_error_desc           => p_error_desc
        );
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling save_or_erase_invoice returned');
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_code ='||p_error_code);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_desc ='||p_error_desc);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_no_of_invoices_inserted ='||l_no_of_invoices_inserted);
        END IF;
      END IF;
    END IF;

    IF (l_no_of_invoices_inserted > 0) THEN
      p_ok_to_import := 'Y';
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_batch_name='||p_batch_name);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_group_id='||p_group_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_ok_to_import='||p_ok_to_import);
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;

  --****************************************************************************************--
  --*          Name : cleanup_previous_failed_run                                          *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : Cleanup previously failed run with records in status IMPORTED        *--
  --*    Parameters : p_errbuf         Error returned to the concurrent process            *--
  --*               : p_retcode        Return Code to concurrent process                   *--
  --*   Global Vars : g_module_name                   READ                                 *--
  --*               : g_SUCCESS                       READ                                 *--
  --*               : g_ERROR                         READ                                 *--
  --*               : fnd_log.level_statement         READ                                 *--
  --*               : fnd_log.g_current_runtime_level READ                                 *--
  --*               : fnd_log.level_unexpected        READ                                 *--
  --*               : fnd_log.level_procedure         READ                                 *--
  --*               : g_enter                         READ                                 *--
  --*               : g_exit                          READ                                 *--
  --*   Called from : load_data_file                                                       *--
  --*         Calls : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*   Tables Used : fv_ipac_import DELETE                                                *--
  --*         Logic : Delete all records from fv_ipac_import table with status IMPORTED    *--
  --****************************************************************************************--
  PROCEDURE cleanup_previous_failed_run
  (
    p_error_code     OUT NOCOPY NUMBER,
    p_error_desc     OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(200);
    l_rowcount            NUMBER;
  BEGIN
    l_module_name := g_module_name || 'cleanup_previous_failed_run';
    p_error_code := g_SUCCESS;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;

    BEGIN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Deleting fv_ipac_import');
      END IF;
      DELETE fv_ipac_import
       WHERE record_status = 'IMPORTED';
      l_rowcount := SQL%ROWCOUNT;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,'Deleted '||l_rowcount||' rows from fv_ipac_import.');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_error_code := g_FAILURE;
        p_error_desc := SQLERRM;
        l_location   := l_module_name||'.delete_fv_ipac_import';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
    END;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;

  --****************************************************************************************--
  --*          Name : cleanup_current_failed_run                                           *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This procedure removes data from ap_invoices_interface,              *--
  --*               : ap_invoice_lines_interface and ap_interface_rejections after a       *--
  --*               : failed run                                                           *--
  --*    Parameters : p_group_id       IN  The group id for which the data is processed    *--
  --*               : p_errbuf         OUT Error returned to the concurrent process        *--
  --*               : p_retcode        OUT Return Code to concurrent process               *--
  --*   Global Vars : g_module_name                   READ                                 *--
  --*               : g_SUCCESS                       READ                                 *--
  --*               : g_ERROR                         READ                                 *--
  --*               : fnd_log.level_statement         READ                                 *--
  --*               : fnd_log.g_current_runtime_level READ                                 *--
  --*               : fnd_log.level_unexpected        READ                                 *--
  --*               : fnd_log.level_procedure         READ                                 *--
  --*               : g_enter                         READ                                 *--
  --*               : g_exit                          READ                                 *--
  --*   Called from : main                                                                 *--
  --*         Calls : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*   Tables Used : fv_ipac_import             SELECT, UPDATE                            *--
  --*               : ap_interface_rejections    DELETE                                    *--
  --*               : ap_invoice_lines_interface DELETE                                    *--
  --*               : ap_invoices_interface      DELETE                                    *--
  --*         Logic : For each invoice number with status of ERROR in fv_ipac_import table *--
  --*               : do the following                                                     *--
  --*               : 1. Delete all data from ap_interface_rejections for lines            *--
  --*               : 2. Delete all data from ap_interface_rejections for header           *--
  --*               : 3. Delete all data from ap_invoice_lines_interface                   *--
  --*               : 4. Delete all data from ap_invoices_interface                        *--
  --*               : 5. Update all other records of fv_ipac_import table with same        *--
  --*               :    invoice and status of not ERROR to ERROR IN OTHER LINES           *--
  --****************************************************************************************--
  PROCEDURE cleanup_current_failed_run
  (
    p_group_id       IN  NUMBER,
    p_error_code     OUT NOCOPY NUMBER,
    p_error_desc     OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(200);
    l_rowcount            NUMBER;
  BEGIN
    l_module_name := g_module_name || 'cleanup_current_failed_run';
    p_error_code := g_SUCCESS;
    RETURN;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_group_id       = '||p_group_id);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Getting into cursor import_rec');
    END IF;

    FOR import_rec IN (SELECT invoice_number
                         FROM fv_ipac_import
                        WHERE group_id = p_group_id
                          AND record_status = g_status_error) LOOP

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Currently Processing Invoice Number = '||import_rec.invoice_number);
      END IF;

      IF (p_error_code = g_SUCCESS) THEN
        BEGIN
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Deleting ap_interface_rejections1');
          END IF;
          DELETE ap_interface_rejections
           WHERE parent_table = 'AP_INVOICE_LINES_INTERFACE'
             AND parent_id IN (SELECT invoice_line_id
                                  FROM ap_invoice_lines_interface aili,
                                       ap_invoices_interface aii
                                 WHERE aii.invoice_num = import_rec.invoice_number
                                   AND aii.group_id = p_group_id
                                   AND aii.invoice_id = aili.invoice_id);
          l_rowcount := SQL%ROWCOUNT;
          IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,'Deleted '||l_rowcount||' rows from ap_interface_rejections1.');
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            p_error_code := g_FAILURE;
            p_error_desc := SQLERRM;
            l_location   := l_module_name||'.delete_ap_interface_rejections1';
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
        END;
      END IF;

      IF (p_error_code = g_SUCCESS) THEN
        BEGIN
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Deleting ap_interface_rejections2');
          END IF;
          DELETE ap_interface_rejections
           WHERE parent_table = 'AP_INVOICES_INTERFACE'
             AND parent_id IN (SELECT invoice_id
                                  FROM ap_invoices_interface aii
                                 WHERE aii.invoice_num = import_rec.invoice_number
                                   AND aii.group_id = p_group_id);
          l_rowcount := SQL%ROWCOUNT;
          IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,'Deleted '||l_rowcount||' rows from ap_interface_rejections2.');
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            p_error_code := g_FAILURE;
            p_error_desc := SQLERRM;
            l_location   := l_module_name||'.delete_ap_interface_rejections2';
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
        END;
      END IF;

      IF (p_error_code = g_SUCCESS) THEN
        BEGIN
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Deleting ap_invoice_lines_interface');
          END IF;
          DELETE ap_invoice_lines_interface
           WHERE invoice_id IN (SELECT invoice_id
                                  FROM ap_invoices_interface
                                 WHERE invoice_num = import_rec.invoice_number
                                   AND group_id = p_group_id);
          l_rowcount := SQL%ROWCOUNT;
          IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,'Deleted '||l_rowcount||' rows from ap_invoice_lines_interface.');
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            p_error_code := g_FAILURE;
            p_error_desc := SQLERRM;
            l_location   := l_module_name||'.delete_ap_invoice_lines_interface';
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
        END;
      END IF;


      IF (p_error_code = g_SUCCESS) THEN
        BEGIN
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Deleting ap_invoices_interface');
          END IF;
          DELETE ap_invoices_interface
           WHERE invoice_num = import_rec.invoice_number
             AND group_id = p_group_id;
          l_rowcount := SQL%ROWCOUNT;
          IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,'Deleted '||l_rowcount||' rows from ap_invoices_interface.');
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            p_error_code := g_FAILURE;
            p_error_desc := SQLERRM;
            l_location   := l_module_name||'.delete_ap_invoices_interface';
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
        END;
      END IF;

      IF (p_error_code = g_SUCCESS) THEN
        BEGIN
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Updating fv_ipac_import');
          END IF;
          UPDATE fv_ipac_import
             SET record_status = g_status_other_error
           WHERE group_id = p_group_id
             AND invoice_number = import_rec.invoice_number
             AND record_status <> g_status_error;
          l_rowcount := SQL%ROWCOUNT;
          IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,'Updated '||l_rowcount||' rows in fv_ipac_import.');
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            p_error_code := g_FAILURE;
            p_error_desc := SQLERRM;
            l_location   := l_module_name||'.update_fv_ipac_import';
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
            fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
        END;
      END IF;

      IF (p_error_code <> g_SUCCESS) THEN
        EXIT;
      END IF;

    END LOOP;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Out of cursor import_rec');
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;
  --****************************************************************************************--
  --*          Name : move_data_to_history                                                 *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This procedure moves all the processsed records from fv_ipac_import  *--
  --*               : table into fv_ipac_import_history table                              *--
  --*    Parameters : p_group_id       IN  The group id for which the data is processed    *--
  --*               : p_errbuf         OUT Error returned to the concurrent process        *--
  --*               : p_retcode        OUT Return Code to concurrent process               *--
  --*   Global Vars : g_module_name                   READ                                 *--
  --*               : g_SUCCESS                       READ                                 *--
  --*               : g_ERROR                         READ                                 *--
  --*               : fnd_log.level_statement         READ                                 *--
  --*               : fnd_log.g_current_runtime_level READ                                 *--
  --*               : fnd_log.level_unexpected        READ                                 *--
  --*               : fnd_log.level_procedure         READ                                 *--
  --*               : g_enter                         READ                                 *--
  --*               : g_exit                          READ                                 *--
  --*   Called from : main                                                                 *--
  --*         Calls : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*   Tables Used : fv_ipac_import_history INSERT                                        *--
  --*               : fv_ipac_import         SELECT, DELETE                                *--
  --*         Logic : 1. Insert into fv_ipac_import_history by selecting all processed     *--
  --*               :    records from fv_ipac_import                                       *--
  --*               : 2. Delete all processed records from fv_ipac_import                  *--
  --****************************************************************************************--
  PROCEDURE move_data_to_history
  (
    p_group_id       IN  NUMBER,
    p_error_code     OUT NOCOPY NUMBER,
    p_error_desc     OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(200);
    l_rowcount            NUMBER;
  BEGIN
    l_module_name := g_module_name || 'move_data_to_history';
    p_error_code := g_SUCCESS;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_group_id       = '||p_group_id);
    END IF;

    BEGIN
      INSERT INTO fv_ipac_import_history
      (
        ipac_import_id,
        batch_name,
        transaction_id,
        submitter_alc,
        originating_alc,
        customer_alc,
        contact_name,
        contact_email_address,
        contact_phone_number,
        summary_amount,
        numer_of_detail_lines,
        accomplished_date,
        accounting_date,
        detail_line_number,
        contract_number,
        purchase_order_number,
        clin,
        invoice_number,
        requisition_number,
        quantity,
        unit_of_issue,
        unit_price,
        detail_amount,
        pay_flag,
        fy_obligation_id,
        receiver_tres_acct_symbol,
        receiver_betc,
        receiver_duns,
        receiver_duns_4,
        sender_tres_acct_symbol,
        sender_betc,
        sender_duns,
        sender_duns_4,
        receiver_department_code,
        accounting_class_code,
        acrn,
        job_project_number,
        jas_number,
        fsn_aaa_adsn,
        obligating_doc_number,
        act_trace_number,
        description,
        misc_information,
        transaction_type,
        ipac_doc_ref_number,
        sender_do_symbol,
        dodacc,
        transaction_contact,
        transcation_contact_phone,
        voucher_number,
        original_do_symbol,
        orig_accomplished_date,
        orig_accounting_date,
        orig_doc_ref_number,
        orig_transaction_type,
        sender_sgl_comment,
        receiver_sgl_comment,
        sgl_number1,
        sgl_sender_receiver_flag1,
        sgl_federal_flag1,
        sgl_debit_credit_flag1,
        sgl_amount1,
        sgl_number2,
        sgl_sender_receiver_flag2,
        sgl_federal_flag2,
        sgl_debit_credit_flag2,
        sgl_amount2,
        sgl_number3,
        sgl_sender_receiver_flag3,
        sgl_federal_flag3,
        sgl_debit_credit_flag3,
        sgl_amount3,
        sgl_number4,
        sgl_sender_receiver_flag4,
        sgl_federal_flag4,
        sgl_debit_credit_flag4,
        sgl_amount4,
        sgl_number5,
        sgl_sender_receiver_flag5,
        sgl_federal_flag5,
        sgl_debit_credit_flag5,
        sgl_amount5,
        sgl_number6,
        sgl_sender_receiver_flag6,
        sgl_federal_flag6,
        sgl_debit_credit_flag6,
        sgl_amount6,
        sgl_number7,
        sgl_sender_receiver_flag7,
        sgl_federal_flag7,
        sgl_debit_credit_flag7,
        sgl_amount7,
        sgl_number8,
        sgl_sender_receiver_flag8,
        sgl_federal_flag8,
        sgl_debit_credit_flag8,
        sgl_amount8,
        sgl_number9,
        sgl_sender_receiver_flag9,
        sgl_federal_flag9,
        sgl_debit_credit_flag9,
        sgl_amount9,
        sgl_number10,
        sgl_sender_receiver_flag10,
        sgl_federal_flag10,
        sgl_debit_credit_flag10,
        sgl_amount10,
        sgl_number11,
        sgl_sender_receiver_flag11,
        sgl_federal_flag11,
        sgl_debit_credit_flag11,
        sgl_amount11,
        sgl_number12,
        sgl_sender_receiver_flag12,
        sgl_federal_flag12,
        sgl_debit_credit_flag12,
        sgl_amount12,
        sgl_number13,
        sgl_sender_receiver_flag13,
        sgl_federal_flag13,
        sgl_debit_credit_flag13,
        sgl_amount13,
        sgl_number14,
        sgl_sender_receiver_flag14,
        sgl_federal_flag14,
        sgl_debit_credit_flag14,
        sgl_amount14,
        sgl_number15,
        sgl_sender_receiver_flag15,
        sgl_federal_flag15,
        sgl_debit_credit_flag15,
        sgl_amount15,
        sgl_number16,
        sgl_sender_receiver_flag16,
        sgl_federal_flag16,
        sgl_debit_credit_flag16,
        sgl_amount16,
        record_status,
        org_id,
        set_of_books_id,
        invoice_id,
        invoice_line_id,
        actual_po_number,
        actual_po_line_number,
        vendor_id,
        vendor_site_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        request_id,
        group_id,
        data_file,
        int_invoice_id,
        int_invoice_line_id
      )
      SELECT ipac_import_id,
             batch_name,
             transaction_id,
             submitter_alc,
             originating_alc,
             customer_alc,
             contact_name,
             contact_email_address,
             contact_phone_number,
             summary_amount,
             numer_of_detail_lines,
             accomplished_date,
             accounting_date,
             detail_line_number,
             contract_number,
             purchase_order_number,
             clin,
             invoice_number,
             requisition_number,
             quantity,
             unit_of_issue,
             unit_price,
             detail_amount,
             pay_flag,
             fy_obligation_id,
             receiver_tres_acct_symbol,
             receiver_betc,
             receiver_duns,
             receiver_duns_4,
             sender_tres_acct_symbol,
             sender_betc,
             sender_duns,
             sender_duns_4,
             receiver_department_code,
             accounting_class_code,
             acrn,
             job_project_number,
             jas_number,
             fsn_aaa_adsn,
             obligating_doc_number,
             act_trace_number,
             description,
             misc_information,
             transaction_type,
             ipac_doc_ref_number,
             sender_do_symbol,
             dodacc,
             transaction_contact,
             transcation_contact_phone,
             voucher_number,
             original_do_symbol,
             orig_accomplished_date,
             orig_accounting_date,
             orig_doc_ref_number,
             orig_transaction_type,
             sender_sgl_comment,
             receiver_sgl_comment,
             sgl_number1,
             sgl_sender_receiver_flag1,
             sgl_federal_flag1,
             sgl_debit_credit_flag1,
             sgl_amount1,
             sgl_number2,
             sgl_sender_receiver_flag2,
             sgl_federal_flag2,
             sgl_debit_credit_flag2,
             sgl_amount2,
             sgl_number3,
             sgl_sender_receiver_flag3,
             sgl_federal_flag3,
             sgl_debit_credit_flag3,
             sgl_amount3,
             sgl_number4,
             sgl_sender_receiver_flag4,
             sgl_federal_flag4,
             sgl_debit_credit_flag4,
             sgl_amount4,
             sgl_number5,
             sgl_sender_receiver_flag5,
             sgl_federal_flag5,
             sgl_debit_credit_flag5,
             sgl_amount5,
             sgl_number6,
             sgl_sender_receiver_flag6,
             sgl_federal_flag6,
             sgl_debit_credit_flag6,
             sgl_amount6,
             sgl_number7,
             sgl_sender_receiver_flag7,
             sgl_federal_flag7,
             sgl_debit_credit_flag7,
             sgl_amount7,
             sgl_number8,
             sgl_sender_receiver_flag8,
             sgl_federal_flag8,
             sgl_debit_credit_flag8,
             sgl_amount8,
             sgl_number9,
             sgl_sender_receiver_flag9,
             sgl_federal_flag9,
             sgl_debit_credit_flag9,
             sgl_amount9,
             sgl_number10,
             sgl_sender_receiver_flag10,
             sgl_federal_flag10,
             sgl_debit_credit_flag10,
             sgl_amount10,
             sgl_number11,
             sgl_sender_receiver_flag11,
             sgl_federal_flag11,
             sgl_debit_credit_flag11,
             sgl_amount11,
             sgl_number12,
             sgl_sender_receiver_flag12,
             sgl_federal_flag12,
             sgl_debit_credit_flag12,
             sgl_amount12,
             sgl_number13,
             sgl_sender_receiver_flag13,
             sgl_federal_flag13,
             sgl_debit_credit_flag13,
             sgl_amount13,
             sgl_number14,
             sgl_sender_receiver_flag14,
             sgl_federal_flag14,
             sgl_debit_credit_flag14,
             sgl_amount14,
             sgl_number15,
             sgl_sender_receiver_flag15,
             sgl_federal_flag15,
             sgl_debit_credit_flag15,
             sgl_amount15,
             sgl_number16,
             sgl_sender_receiver_flag16,
             sgl_federal_flag16,
             sgl_debit_credit_flag16,
             sgl_amount16,
             record_status,
             org_id,
             set_of_books_id,
             invoice_id,
             invoice_line_id,
             actual_po_number,
             actual_po_line_number,
             vendor_id,
             vendor_site_id,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             request_id,
             group_id,
             data_file,
             int_invoice_id,
             int_invoice_line_id
        FROM fv_ipac_import
       WHERE group_id = p_group_id
         AND record_status = g_status_processed;
      l_rowcount := SQL%ROWCOUNT;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,'Inserted '||l_rowcount||' rows into fv_ipac_import_history.');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_error_code := g_FAILURE;
        p_error_desc := SQLERRM;
        l_location   := l_module_name||'.insert_fv_ipac_import_history';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
    END;

    BEGIN
      DELETE FROM fv_ipac_import
       WHERE group_id = p_group_id
         AND record_status = g_status_processed;
      l_rowcount := SQL%ROWCOUNT;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,'Deleted '||l_rowcount||' rows from fv_ipac_import.');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_error_code := g_FAILURE;
        p_error_desc := SQLERRM;
        l_location   := l_module_name||'.delete_fv_ipac_import';
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
        fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
    END;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_location,g_exit||'('||p_error_code||')');
      END IF;
  END;

  --****************************************************************************************--
  --*          Name : load_data_file                                                       *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : Uploads the file into the table fv_ipac_import table                 *--
  --*    Parameters : p_data_file_name IN  The data file that is to be imported            *--
  --*               : p_errbuf         OUT Error returned to the concurrent process        *--
  --*               : p_retcode        OUT Return Code to concurrent process               *--
  --*   Global Vars : g_org_id                        READ                                 *--
  --*               : g_module_name                   READ                                 *--
  --*               : g_SUCCESS                       READ                                 *--
  --*               : g_ERROR                         READ                                 *--
  --*               : g_WARNING                       READ                                 *--
  --*               : fnd_log.level_statement         READ                                 *--
  --*               : fnd_log.g_current_runtime_level READ                                 *--
  --*               : fnd_log.level_unexpected        READ                                 *--
  --*               : fnd_log.level_procedure         READ                                 *--
  --*               : g_enter                         READ                                 *--
  --*               : g_exit                          READ                                 *--
  --*   Called from : main                                                                 *--
  --*         Calls : cleanup_previous_failed_run                                          *--
  --*               : fnd_request.set_org_id                                               *--
  --*               : fnd_request.submit_request                                           *--
  --*               : fnd_concurrent.wait_for_request                                      *--
  --*               : fnd_profile.value                                                    *--
  --*               : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*   Tables Used : None                                                                 *--
  --*         Logic : 1. Get the value of FV_DOWNLOAD_TREASURY_FILES_DIRECTORY profile     *--
  --*               :    This has the directory name where to look for the file            *--
  --*               : 2. Append the file name by determining if the OS is win or UNIX      *--
  --*               : 3. Remove all the records with status of IMPORTED that failed        *--
  --*               :    previous run somehow.                                             *--
  --*               : 4. Submit a request for FVSLRPRO using the parameters passed and     *--
  --*               :    wait for the request to finish                                    *--
  --****************************************************************************************--
  PROCEDURE load_data_file
  (
    p_data_file_name IN  VARCHAR2,
    p_error_code     OUT NOCOPY NUMBER,
    p_error_desc     OUT NOCOPY VARCHAR2
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(200);
    l_directory_path      VARCHAR2(1024);
    l_data_file           VARCHAR2(1024);
    l_request_id          NUMBER;
    l_request_wait_status BOOLEAN;
    l_phase               VARCHAR2(100);
    l_status              VARCHAR2(100);
    l_dev_phase           VARCHAR2(100);
    l_dev_status          VARCHAR2(100);
    l_message             VARCHAR2(100);
  BEGIN
    l_module_name := g_module_name || 'load_data_file';
    p_error_code := g_SUCCESS;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_data_file_name       = '||p_data_file_name);
    END IF;

    l_directory_path := fnd_profile.value('FV_DOWNLOAD_TREASURY_FILES_DIRECTORY');

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_directory_path = '||l_directory_path);
    END IF;

    IF (l_directory_path IS NULL) THEN
      p_error_code := g_FAILURE;
      p_error_desc :=  'The directory path is not set in the "FV:Download Treasury Files Directory" profile';
      fv_utility.log_mesg(fnd_log.level_error, l_module_name,p_error_desc) ;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      --
      -- Reformat the input file name ( '\\' --> for WINDOWS NT , '/' --> UNIX )
      --

      IF (INSTR(l_directory_path, '\') <> 0 ) THEN
        l_data_file := l_directory_path || '\\' || p_data_file_name;
      ELSE
        l_data_file := l_directory_path || '/' || p_data_file_name;
      END IF;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_data_file = '||l_data_file);
      END IF;

    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling cleanup_previous_failed_run');
      END IF;
      cleanup_previous_failed_run
      (
        p_error_code     => p_error_code,
        p_error_desc     => p_error_desc
      );
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      --
      -- Submit request to execute SQL*Loader.
      --
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Submitting request');
      END IF;


      fnd_request.set_org_id(g_org_id);
      l_request_id := fnd_request.submit_request
      (
        application => 'FV',
        program     => 'FVSLRPRO',
        description => '',
        start_time  => '',
        sub_request => FALSE ,
        argument1   => l_data_file
      ) ;
      IF (l_request_id = 0) THEN
        p_error_code := g_FAILURE;
        p_error_desc := 'Failed to submit request for SQL*LOADER';
        fv_utility.log_mesg(fnd_log.level_error, l_module_name,p_error_desc) ;
      ELSE
        COMMIT;
      END IF;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Waiting for request to finish');
      END IF;
      l_request_wait_status := fnd_concurrent.wait_for_request
      (
        request_id => l_request_id,
        interval   => 20,
        max_wait   => 0,
        phase      => l_phase,
        status     => l_status,
        dev_phase  => l_dev_phase,
        dev_status => l_dev_status,
        message    => l_message
      );

      COMMIT;
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'wait_for_request retured');
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_phase      = '||l_phase);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_status     = '||l_status);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_dev_phase  = '||l_dev_phase);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_dev_status = '||l_dev_status);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_message    = '||l_message);
      END IF;

      IF (l_request_wait_status = FALSE) THEN
        p_error_code := g_FAILURE;
        p_error_desc := 'Failed to load the IPAC Disbursement records-1.';
        fv_utility.log_mesg(fnd_log.level_error, l_module_name,p_error_desc) ;
      END IF;
    END IF;

    IF (p_error_code = g_SUCCESS) THEN
      IF ((l_dev_phase = 'COMPLETE') AND (l_dev_status IN ('NORMAL','WARNING'))) THEN
        NULL;
      ELSE
        p_error_code := g_FAILURE;
        p_error_desc := 'Failed to load the IPAC Disbursement records-2.';
        fv_utility.log_mesg(fnd_log.level_error, l_module_name,p_error_desc) ;
      END IF;
    END IF;
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := g_FAILURE;
      p_error_desc := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_error_desc) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_error_code||')');
      END IF;
  END;

  --****************************************************************************************--
  --*          Name : main                                                                 *--
  --*          Type : Procedure                                                            *--
  --*       Purpose : This is the main procedure called from the concurrent program        *--
  --*               :   Upload IPAC Disbursement (FVIPDISB)                                *--
  --*    Parameters : p_errbuf               Error returned to the concurrent process      *--
  --*               : p_retcode              Return Code to concurrent process             *--
  --*               : p_data_file_name       The input data file name to be imported       *--
  --*               : p_agency_location_code The Agency Location Code for which invoices   *--
  --*               :                        will be created.                              *--
  --*               : p_payment_bank_acct_id Payment bank account id.                      *--
  --*               : p_document_id          Document Id                                   *--
  --*   Global Vars : g_module_name                   READ                                 *--
  --*               : g_SUCCESS                       READ                                 *--
  --*               : g_WARNING                       READ                                 *--
  --*               : g_ERROR                         READ                                 *--
  --*               : fnd_log.level_procedure         READ                                 *--
  --*               : fnd_log.g_current_runtime_level READ                                 *--
  --*               : g_enter                         READ                                 *--
  --*               : g_exit                          READ                                 *--
  --*               : g_request_id                    READ                                 *--
  --*               : g_userid                        READ                                 *--
  --*               : g_login_id                      READ                                 *--
  --*               : g_org_id                        READ                                 *--
  --*               : g_set_of_books_id               READ                                 *--
  --*               : g_ia_paygroup                   WRITE                                *--
  --*   Called from : Concurrent Program Upload IPAC Disbursement (FVIPDISB)               *--
  --*         Calls : fv_utility.debug_mesg                                                *--
  --*               : fv_utility.log_mesg                                                  *--
  --*               : fnd_profile.value                                                    *--
  --*               : load_data_file                                                       *--
  --*               : process_data                                                         *--
  --*               : kick_off_ap_invoices_import                                          *--
  --*               : check_for_ap_import_errors                                           *--
  --*               : kick_off_exception_report                                            *--
  --*               : kick_off_ipac_auto_pmt_process                                       *--
  --*               : cleanup_current_failed_run                                           *--
  --*               : move_data_to_history                                                 *--
  --*   Tables Used : fv_operating_units SELECT                                            *--
  --*         Logic :                                                                      *--
  --****************************************************************************************--
  PROCEDURE main
  (
    p_errbuf	   	         OUT NOCOPY VARCHAR2,
    p_retcode              OUT NOCOPY NUMBER,
    p_data_file_name       IN  VARCHAR2,
    p_agency_location_code IN  VARCHAR2,
    p_payment_bank_acct_id IN  NUMBER,
    p_payment_profile_id        IN  NUMBER,
    p_payment_document_id       IN  NUMBER
    --p_document_id          IN  NUMBER
  )
  IS
    l_module_name         VARCHAR2(200);
    l_location            VARCHAR2(200);
    l_batch_control       VARCHAR2(1);
    l_batch_name          fv_ipac_import.batch_name%TYPE;
    l_ok_to_import        VARCHAR2(1);
    l_group_id            NUMBER;
  BEGIN
    l_module_name := g_module_name || 'main';
    p_retcode := g_SUCCESS;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_enter);
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_data_file_name       = '||p_data_file_name);
--      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_transaction_code     = '||p_transaction_code);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_agency_location_code = '||p_agency_location_code);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_payment_bank_acct_id = '||p_payment_bank_acct_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_payment_profile_id    = '||p_payment_profile_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_payment_document_id    = '||p_payment_document_id);
--      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_pay_trans_code       = '||p_pay_trans_code);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'g_request_id           = '||g_request_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'g_user_id              = '||g_user_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'g_login_id             = '||g_login_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'g_org_id_id            = '||g_org_id);
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'g_set_of_books_id      = '||g_set_of_books_id);
    END IF;

    /*
    *****************************************************************************
    * Check to see if the AP:Use Invoice Batch Controls is set                  *
    *****************************************************************************
    */
    l_batch_control := NVL(fnd_profile.value('AP_USE_INV_BATCH_CONTROLS'),'N');

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'l_batch_control        = '||l_batch_control);
    END IF;

    IF (l_batch_control = 'N') THEN
      p_retcode := g_FAILURE;
      p_errbuf  := 'The profile option, "AP:Use Invoice Batch Controls" must be set to Yes for the Federal Administrator.';
      fv_utility.log_mesg(fnd_log.level_error, l_module_name,p_errbuf) ;
    END IF;


    /*
    *****************************************************************************
    * Check to see if Pay Group is defined in Federal Options Window            *
    *****************************************************************************
    */
    IF (p_retcode = g_SUCCESS) THEN
      BEGIN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Selecting from fv_operating_units');
        END IF;
        SELECT payables_ia_paygroup
          INTO g_ia_paygroup
          FROM fv_operating_units
         WHERE set_of_books_id = g_set_of_books_id;
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'g_ia_paygroup          = '||g_ia_paygroup);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          p_retcode := g_FAILURE;
          p_errbuf := 'No Paygroup defined on Define Federal Options Window ';
          fv_utility.log_mesg(fnd_log.level_error, l_module_name,p_errbuf);
      END;
    END IF;

    /*
    *****************************************************************************
    * Load the data file into table fv_ipac_import                              *
    *****************************************************************************
    */
    IF (p_retcode = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling load_data_file');
      END IF;
      load_data_file
      (
        p_data_file_name    => p_data_file_name,
        p_error_code        => p_retcode,
        p_error_desc        => p_errbuf
      );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'load_data_file returned');
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_code = '||p_retcode);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_desc = '||p_errbuf);
      END IF;
    END IF;

    /*
    *****************************************************************************
    * Process the data                                                          *
    *****************************************************************************
    */
    IF (p_retcode = g_SUCCESS) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling process_data');
      END IF;
      process_data
      (
        p_data_file_name       => p_data_file_name,
        p_agency_location_code => p_agency_location_code,
        p_batch_name           => l_batch_name,
        p_group_id             => l_group_id,
        p_ok_to_import         => l_ok_to_import,
        p_error_code           => p_retcode,
        p_error_desc           => p_errbuf
      );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'process_data returned');
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_batch_name   = '||l_batch_name);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_group_id     = '||l_group_id);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_ok_to_import = '||l_ok_to_import);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_code   = '||p_retcode);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_desc   = '||p_errbuf);
      END IF;
    END IF;

    /*
    *****************************************************************************
    * Import AP Invoices                                                        *
    *****************************************************************************
    */
    IF (p_retcode = g_SUCCESS) THEN
      IF (l_ok_to_import = 'Y') THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling kick_off_ap_invoices_import');
        END IF;
        kick_off_ap_invoices_import
        (
          p_batch_name           => l_batch_name,
          p_group_id             => l_group_id,
          p_error_code           => p_retcode,
          p_error_desc           => p_errbuf
        );
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'kick_off_ap_invoices_import returned');
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_code   = '||p_retcode);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_desc   = '||p_errbuf);
        END IF;
      END IF;
    END IF;


    IF (p_retcode = g_SUCCESS) THEN
      IF (l_ok_to_import = 'Y') THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling check_for_ap_import_errors');
        END IF;
        check_for_ap_import_errors
        (
          p_group_id             => l_group_id,
          p_error_code           => p_retcode,
          p_error_desc           => p_errbuf
        );
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'check_for_ap_import_errors returned');
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_code   = '||p_retcode);
          fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_desc   = '||p_errbuf);
        END IF;
      END IF;
    END IF;
    /*
    *****************************************************************************
    * Kick off the exception report                                             *
    *****************************************************************************
    */
    IF (p_retcode = g_SUCCESS OR p_retcode = g_WARNING) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling kick_off_exception_report');
      END IF;
      kick_off_exception_report
      (
        p_data_file_name       => p_data_file_name,
        p_agency_location_code => p_agency_location_code,
        p_group_id             => l_group_id,
        p_error_code           => p_retcode,
        p_error_desc           => p_errbuf
      );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'kick_off_exception_report returned');
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_code   = '||p_retcode);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_desc   = '||p_errbuf);
      END IF;
    END IF;

    /*
    *****************************************************************************
    * Kick off the ipac auto payment process                                    *
    *****************************************************************************
    */
    IF (p_retcode = g_SUCCESS OR p_retcode = g_WARNING) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling kick_off_ipac_auto_pmt_process');
      END IF;
      kick_off_ipac_auto_pmt_process
      (
        p_batch_name           => l_batch_name,
        p_payment_bank_acct_id => p_payment_bank_acct_id,
        p_payment_profile_id   => p_payment_profile_id,
        p_payment_document_id  => p_payment_document_id,
--        p_document_id          => p_document_id,
        p_error_code           => p_retcode,
        p_error_desc           => p_errbuf
      );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'kick_off_ipac_auto_pmt_process returned');
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_code   = '||p_retcode);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_desc   = '||p_errbuf);
      END IF;
    END IF;

    IF (p_retcode = g_SUCCESS OR p_retcode = g_WARNING) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling cleanup_current_failed_run process');
      END IF;
      cleanup_current_failed_run
      (
        p_group_id       => l_group_id,
        p_error_code     => p_retcode,
        p_error_desc     => p_errbuf
      );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'cleanup_current_failed_run returned');
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_code   = '||p_retcode);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_desc   = '||p_errbuf);
      END IF;
    END IF;

    /*
    *****************************************************************************
    * Move data to history table                                                *
    *****************************************************************************
    */
    IF (p_retcode = g_SUCCESS OR p_retcode = g_WARNING) THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'Calling move_data_to_history process');
      END IF;
      move_data_to_history
      (
        p_group_id             => l_group_id,
        p_error_code           => p_retcode,
        p_error_desc           => p_errbuf
      );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'move_data_to_history returned');
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_code   = '||p_retcode);
        fv_utility.debug_mesg(fnd_log.level_statement, l_module_name,'p_error_desc   = '||p_errbuf);
      END IF;
    END IF;

    IF (p_retcode = g_SUCCESS OR p_retcode = g_WARNING) THEN
      COMMIT;
    ELSE
      ROLLBACK;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_retcode := g_FAILURE;
      p_errbuf := SQLERRM;
      l_location   := l_module_name||'.final_exception';
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,l_location) ;
      fv_utility.log_mesg(fnd_log.level_unexpected, l_location,p_errbuf) ;
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fv_utility.debug_mesg(fnd_log.level_procedure, l_module_name,g_exit||'('||p_retcode||')');
      END IF;
      ROLLBACK;
  END;

BEGIN
  initialize_global_variables;
END fv_ipac_disbursement_pkg;

/
