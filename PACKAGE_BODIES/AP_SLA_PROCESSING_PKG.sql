--------------------------------------------------------
--  DDL for Package Body AP_SLA_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_SLA_PROCESSING_PKG" AS
/* $Header: apslappb.pls 120.29.12010000.10 2009/12/29 13:54:47 kpasikan ship $ */

-------------------------------------------------------------------------------
--
--                 ap_invoice_payments_all
--                         \|/ \|/
--                          |   |
--  +-----------------------+   +------------------------+
--  |                                                    |
-- ap_checks_all                            ap_invoices_all
--  |                                                    |
--  |                                                    |
--  |                                                    |
-- /|\                                                  /|\
-- ap_payment_history_all              ap_invoice_lines_all
--  |                                                    |
--  |                                                    |
--  |                                                    |
--  |                                                   /|\
--  |                          ap_invoice_distributions_all
--  |                                                 |  |
--  |   +---------------------------------------------+  |
--  |   |                                                |
-- /|\ /|\                                              /|\
-- ap_payment_hist_dists                ap_prepay_app_dists
--
--
-- Each record in the AP_INVOICE_PAYMENTS_ALL table relates a portion of a
-- payment to an invoice.
--
-- Each record in the AP_INVOICE_DISTRIBUTIONS_ALL table relates a portion of
-- the cost of an invoice to an accounting cost object.
--
-- Each record in the AP_PAYMENT_HIST_DISTS table relates a payment
-- distribution to a distribution.
--
-- Each record in the AP_PREPAY_APP_DISTS table relates a prepayment
-- distribution to a distribution.
--
--
-- +-----------------+------------+---------------+
-- |                 | Batch Mode | Document Mode |
-- +-----------------+------------+---------------+
-- | Pre-accounting  | Yes        | No            |
-- | Extract         | Yes        | Yes           |
-- | Post-processing | Yes        | Yes           |
-- | Post-accounting | Yes        | No            |
-- +-----------------+------------+---------------+
--
-------------------------------------------------------------------------------

G_CURRENT_RUNTIME_LEVEL     NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR      CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION  CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT      CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE  CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT  CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME      CONSTANT VARCHAR2(50) :='AP.PLSQL.AP_SLA_PROCESSING_PKG.';
G_COMMIT_SIZE      CONSTANT NUMBER       := 10000;

TYPE l_event_ids_typ IS TABLE OF NUMBER(15)
                          INDEX BY PLS_INTEGER;
/*============================================================================
 |  PROCEDURE - TRACE (PRIVATE)
 |
 |  DESCRIPTION
 |    This procedure is used to trace the log information.
 |
 |  PRAMETERS
 |    p_level: The level of log message. The possible values are:
 |             G_LEVEL_UNEXPECTED
 |             G_LEVEL_ERROR
 |             G_LEVEL_EXCEPTION
 |             G_LEVEL_EVENT
 |             G_LEVEL_PROCEDURE
 |             G_LEVEL_STATEMENT
 |    p_procedure:  The procedure's name
 |    p_debug_info: The log message
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/
PROCEDURE trace (
      p_level             IN NUMBER,
      p_procedure_name    IN VARCHAR2,
      p_debug_info        IN VARCHAR2
)
IS

BEGIN
  IF (p_level >= G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(p_level,
                   G_MODULE_NAME||p_procedure_name,
                   p_debug_info);
  END IF;

END trace;

/*============================================================================
 |  PROCEDURE - Lock_Documents_autonomous  (PRIVATE)
 |
 |  DESCRIPTION
 |    This procedure is used to update posted flag of document such
 |    as invoice or payment, invoice payment so that user will not
 |    make changes during accounting process via form.
 |
 |  PRAMETERS
 |    p_level:
 |    p_procedure:  The procedure's name
 |    p_debug_info: The log message
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/
PROCEDURE lock_documents_autonomous (
    p_event_ids         IN    l_event_ids_typ,
    p_calling_sequence  IN    VARCHAR2
)
IS
-- PRAGMA AUTONOMOUS_TRANSACTION; bug 7351478

  l_debug_info                   VARCHAR2(240);
  l_procedure_name               CONSTANT VARCHAR2(30) :='LOCK_DOCUMENTS_AUTONOMOUS';
  l_curr_calling_sequence        VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence := 'ap_sla_processing_pkg'||l_procedure_name
                             ||'<-'||p_calling_sequence;
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  ---------------------------------------------------------------------
  l_debug_info := 'Begin of procedure '||l_procedure_name;
  trace(G_LEVEL_PROCEDURE, l_procedure_name, l_debug_info);
  ---------------------------------------------------------------------


  ---------------------------------------------------------------------
   l_debug_info := 'Mark payment history posted_flag';
   trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
  ---------------------------------------------------------------------

  FORALL i IN 1 .. p_event_ids.count
  UPDATE ap_payment_history_All APH
  SET    POSTED_FLAG = 'S'
  WHERE  APH.accounting_event_id = p_event_ids(i);

  ---------------------------------------------------------------------
  l_debug_info := 'Mark the payments posted_flag';
  trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
  -- Payments with a POSTED_FLAG of 'Y' won't have their POSTED_FLAGs
  -- updated to 'S' because events that have already been accounted are
  -- not in the XLA_ENTITY_EVENTS_V view (because no event is ever
  -- accounted more than once). Only payments with a POSTED_FLAG of 'N'
  -- or 'S' will their POSTED_FLAGs update to 'S'.
  ---------------------------------------------------------------------

  FORALL i IN 1 .. p_event_ids.count
  UPDATE ap_invoice_payments_all AIP
  SET    AIP.posted_flag = 'S'
  WHERE  AIP.accounting_event_id = p_event_ids(i);

  ---------------------------------------------------------------------
  l_debug_info := 'Mark the invoice distributions posted flag ' ;
  trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
  --
  -- Distributions with a POSTED_FLAG of 'Y' will not have their
  -- POSTED_FLAGs updated to 'S' because events that have already been
  -- accounted are not in the XLA_ENTITY_EVENTS_V view (because no event
  -- is ever accounted more than once). Only distributions with a
  -- POSTED_FLAG of 'N' or 'S' will their POSTED_FLAGs update to 'S'.
  ---------------------------------------------------------------------

  FORALL i IN 1 .. p_event_ids.count
  UPDATE ap_invoice_distributions_all AID
  SET AID.posted_flag = 'S'
  WHERE AID.accounting_event_id = p_event_ids(i);

  -- bug fix 6975868
  FORALL i IN 1 .. p_event_ids.count
  UPDATE ap_self_assessed_tax_dist_all STID
  SET STID.posted_flag = 'S'
  WHERE STID.accounting_event_id = p_event_ids(i);

  ---------------------------------------------------------------------
  l_debug_info := 'Mark prepayment history posted flag';
  trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
  ---------------------------------------------------------------------

  FORALL i IN 1 .. p_event_ids.count
  UPDATE  ap_prepay_history_all APPH
  SET     POSTED_FLAG = 'S'
  WHERE   APPH.accounting_event_id = p_event_ids(i);

--  COMMIT; bug 7351478
  ---------------------------------------------------------------------
  l_debug_info := 'END of procedure '||l_procedure_name;
  trace(G_LEVEL_PROCEDURE, l_procedure_name, l_debug_info);
  ---------------------------------------------------------------------
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
    END IF;

    ROLLBACK;

    APP_EXCEPTION.RAISE_EXCEPTION;
END lock_documents_autonomous;

/*============================================================================
 |  PROCEDURE -  PREACCOUNTING(PUBLIC)
 |
 |  DESCRIPTION
 |    This procedure is the AP SLA preaccounting procedure. This procedure
 |    will be called by SLA through an API.
 |
 |  PRAMETERS
 |    p_application_id:
 |      This parameter is the application ID of the application that the SLA
 |      workflow event is for. This procedure must exit without doing anything
 |      if this parameter is not 200 to ensure that this procedure is only
 |      executed when the workflow event is for AP. This parameter will never
 |       be NULL.
 |    p_ledger_id:
 |      This parameter is the ledger ID of the ledger to account.This
 |      parameter is purely informational. This procedure selects from the
 |      XLA_ENTITY_EVENTS_V view, which does not include events incompatible
 |      with this parameter. This parameter will never be NULL.
 |    p_process_category:
 |      This parameter is the "process category" of the events to account. This
 |      parameter is purely informational. This procedure selects from the
 |      XLA_ENTITY_EVENTS_V view, which does not include events incompatible
 |      with this parameter.Possible values are as following:
 |      +------------+------------------------------------------+
 |      | Value      | Meaning                                  |
 |      +------------+------------------------------------------+
 |      | 'Invoices' | process invoices                         |
 |      | 'Payments' | process payments and reconciled payments |
 |      | 'All'      | process everything                       |
 |      +------------+------------------------------------------+
 |    p_end_date
 |      This parameter is the maximum event date of the events to be processed
 |      in this run of the accounting. This procedure selects from the
 |      XLA_ENTITY_EVENTS_V view, which does not include events incompatible
 |      with this parameter. This parameter will never be NULL.
 |    p_accounting_mode
 |      This parameter is the "accounting mode" that the accounting is being
 |      run in. This parameter will never be NULL.
 |      +-------+------------------------------------------------------------+
 |      | Value | Meaning                                                    |
 |      +-------+------------------------------------------------------------+
 |      | 'D'   | The accounting is being run in "draft mode". Draft mode is |
 |      |       | used to examine what the accounting entries would look for |
 |      |       | an event without actually creating the accounting entries. |
 |      |       | without actually creating the accounting entries.          |
 |      | 'F'   | The accounting is being run in "final mode". Final mode is |
 |      |       | used to create accounting entries.                         |
 |      +-------+------------------------------------------------------------+
 |    p_valuation_method
 |      This parameter is unused by AP. This parameter is purely informational.
 |      This procedure selects from the XLA_ENTITY_EVENTS_V view, which does
 |      not include events incompatible with this parameter.
 |    p_security_id_int_1
 |      This parameter is unused by AP.
 |    p_security_id_int_2
 |      This parameter is unused by AP.
 |    p_security_id_int_3
 |      This parameter is unused by AP.
 |    p_security_id_char_1
 |      This parameter is unused by AP.
 |    p_security_id_char_2
 |      This parameter is unused by AP.
 |    p_security_id_char_3
 |      This parameter is unused by AP.
 |    p_report_request_id
 |      This parameter is the concurrent request ID of the concurrent request
 |      that is this run of the accounting. This parameter is used to specify
 |      which events in the XLA_ENTITY_EVENTS_V view are to be accounted in
 |      this run of the accounting. This parameter will never be NULL.
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |    1) This procedure is run in final mode and draft mode.
 |    2) This procedure is run in batch mode but not in document mode.
 |    3) This procedure is in its own commit cycle.
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/

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
)
IS
  l_debug_info                   VARCHAR2(240);
  l_procedure_name               CONSTANT VARCHAR2(30) :='PRE_ACCOUNTING_PROC';
  l_curr_calling_sequence        VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence := 'AP_SLA_PROCESSING_PKG.PRE_ACCOUNTING_PROC';
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  ---------------------------------------------------------------------
  l_debug_info := 'Begin of procedure '||l_procedure_name;
  trace(G_LEVEL_PROCEDURE, l_procedure_name, l_debug_info);
  ---------------------------------------------------------------------

  ---------------------------------------------------------------------
  -- This procedure should only called by 'AP', whose application id
  -- is 200. Otherwise exit the procedure.
  ---------------------------------------------------------------------
  IF (p_application_id <> 200) THEN
    RETURN;
  END IF;

  IF ( p_accounting_mode IS NOT NULL ) THEN

    CASE (p_accounting_mode)

      WHEN ('F') THEN -- p_accounting_mode
      -----------------------------------------------------------------------
      -- FINAL MODE
      l_debug_info := 'p_accounting_mode :=' ||p_accounting_mode;
      trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
      -----------------------------------------------------------------------
        NULL;
      WHEN ('D') THEN -- p_accounting_mode
        -----------------------------------------------------------------------
        l_debug_info := 'p_accounting_mode ='||p_accounting_mode;
        trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
        -- DRAFT MODE
        -----------------------------------------------------------------------
        NULL;

      WHEN ('FUNDS_CHECK') THEN -- p_accounting_mode

        -----------------------------------------------------------------------
        l_debug_info := 'p_accounting_mode ='||p_accounting_mode;
        trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
        --FUNDS CHECK MODE
        -----------------------------------------------------------------------
        NULL;

      WHEN ('FUNDS_RESERVE') THEN -- p_accounting_mode

        -----------------------------------------------------------------------
        l_debug_info := 'p_accounting_mode ='||p_accounting_mode;
        trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
        -- FUNDS RESERVE MODE
        -----------------------------------------------------------------------
        NULL;
      ELSE
        -----------------------------------------------------------------------
        l_debug_info := 'Wrong p_accounting_mode ='||p_accounting_mode;
        trace(G_LEVEL_EXCEPTION, l_procedure_name, l_debug_info);
        -----------------------------------------------------------------------
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR','Wrong p_accounting_mode');
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                              l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                   'p_process_category = '||p_process_category
                || 'p_accounting_mode = '||p_accounting_mode);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

        app_exception.raise_exception();

      END CASE; -- p_accounting_mode
    END IF;  -- END of checking p_accounting_mode
    -------------------------------------------------------------------------
    l_debug_info := 'End of procedure '||l_procedure_name;
    trace(G_LEVEL_PROCEDURE, l_procedure_name, l_debug_info);
    -------------------------------------------------------------------------
EXCEPTION

  WHEN OTHERS THEN

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
        'p_application_id='     || p_application_id     || ' ' ||
        'p_ledger_id='          || p_ledger_id          || ' ' ||
        'p_process_category='   || p_process_category   || ' ' ||
        'p_end_date='           || p_end_date           || ' ' ||
        'p_accounting_mode='    || p_accounting_mode    || ' ' ||
        'p_valuation_method='   || p_valuation_method   || ' ' ||
        'p_security_id_int_1='  || p_security_id_int_1  || ' ' ||
        'p_security_id_int_2='  || p_security_id_int_2  || ' ' ||
        'p_security_id_int_3='  || p_security_id_int_3  || ' ' ||
        'p_security_id_char_1=' || p_security_id_char_1 || ' ' ||
        'p_security_id_char_2=' || p_security_id_char_2 || ' ' ||
        'p_security_id_char_3=' || p_security_id_char_3 || ' ' ||
        'p_report_request_id='  || p_report_request_id);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;

    app_exception.raise_exception();

END preaccounting;


/*============================================================================
 |  PROCEDURE - POSTPROCESSING (PUBLIC)
 |
 |  DESCRIPTION
 |    This procedure is the AP SLA post-processing procedure. This procedure
 |    will be called by SLA thorugh an API.
 |
 |  PRAMETERS
 |    p_application_id
 |      This parameter is the application ID of the application that the SLA
 |      workflow event is for. This procedure must exit without doing anything
 |      if this parameter is not 200 to ensure that this procedure is only
 |      executed when the workflow event is for AP. This parameter will never
 |      be NULL.
 |   p_accounting_mode
 |     This parameter is the "accounting mode" that the accounting is being
 |     run in. This parameter will never be NULL.
 |     +-------+-----------------------------------------------------------+
 |     | Value | Meaning                                                   |
 |     +-------+-----------------------------------------------------------+
 |     | 'D'   | The accounting is being run in "draft mode". Draft mode is|
 |     |       | used TO examine what the accounting entries would look for|
 |     |       | an event without actually creating the accounting entries |
 |     | 'F'   | The accounting is being run in "final mode". Final mode is|
 |     |       | used to create accounting entries.                        |
 |     +-------+-----------------------------------------------------------+
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |    1) This procedure is run in final mode and draft mode.
 |    2) This procedure is run in batch mode and document mode.
 |    3) This procedure is part of the accounting commit cycle.
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/

PROCEDURE postprocessing
(
  p_application_id               IN            NUMBER,
  p_accounting_mode              IN            VARCHAR2
)
IS

  -----------------------------------------------------------------------------
  -- The XLA_POST_ACCTG_EVENTS_V view contains only the successfully accounted
  -- events.
  -----------------------------------------------------------------------------

  CURSOR l_events_cur IS
  SELECT  XPAE.event_id event_id,
          XPAE.event_type_code event_type_code,
          XPAE.SOURCE_ID_INT_1 source_id,
          GSOB.sla_ledger_cash_basis_flag cash_basis_flag,
          APSP.when_To_Account_pmt,
          XPAE.ledger_id ledger_id
   FROM   XLA_POST_ACCTG_EVENTS_V XPAE,
          XLA_TRANSACTION_ENTITIES XTE,
          GL_SETS_OF_BOOKS GSOB,
          AP_SYSTEM_PARAMETERS_ALL APSP
   WHERE XPAE.ledger_id = GSOB.set_of_books_id
     AND XPAE.entity_id = XTE.entity_id
     AND XTE.application_id = 200
     AND XTE.security_id_int_1 = APSP.org_id;

  TYPE event_tab_type IS TABLE OF l_events_cur%rowtype INDEX BY PLS_INTEGER;
  TYPE invIDType IS TABLE OF ap_invoice_lines_all.invoice_id%type INDEX BY PLS_INTEGER;
  TYPE checkIDType IS TABLE OF ap_checks_all.check_id%type INDEX BY PLS_INTEGER;

  TYPE checkStatusType IS TABLE OF
                     ap_checks_all.status_lookup_code%type INDEX BY PLS_INTEGER;

  l_Status                       AP_CHECKS_ALL.status_lookup_code%type;
  l_matched_flag                 AP_PAYMENT_HISTORY_ALL.matched_flag%type;
  l_debug_info                   VARCHAR2(240);
  l_procedure_name               CONSTANT VARCHAR2(30):='POSTPROCESSING_PROC';
  l_curr_calling_sequence        VARCHAR2(2000);

  l_event_rec                    l_events_cur%ROWTYPE;
  l_process_list                 event_tab_type;

  l_event_list                   l_event_ids_typ;
  l_accrual_event_ids            l_event_ids_typ;
  l_cash_event_ids               l_event_ids_typ;
  l_prepay_event_list            l_event_ids_typ;
  l_payclear_event_list          l_event_ids_typ;
  l_other_event_list             l_event_ids_typ;

  l_invID_list                   invIDType;
  l_check_status_list            checkStatusType;
  l_check_id_list                checkIDType;

  i                              BINARY_INTEGER := 1;
  j                              BINARY_INTEGER := 1;
  k                              BINARY_INTEGER := 1;
  m                              BINARY_INTEGER := 1;
  n                              BINARY_INTEGER := 1;
  ind                            BINARY_INTEGER := 1;
  dd                             BINARY_INTEGER := 1;
  l_dbi_count                    NUMBER := 0;
  l_tax_count                    NUMBER := 0;

  --Bug 4640244 DBI logging
  -- bug fix 5663077
  -- Add the ap_dbi_pkg.r_dbi_key_value_arr() to initialize the plsql table.
  l_dbi_key_value_list1          ap_dbi_pkg.r_dbi_key_value_arr := ap_dbi_pkg.r_dbi_key_value_arr();
  l_dbi_key_final_list           ap_dbi_pkg.r_dbi_key_value_arr := ap_dbi_pkg.r_dbi_key_value_arr();

  l_tax_dist_id_list1            zx_api_pub.tax_dist_id_tbl_type;
  l_tax_dist_id_final_list       zx_api_pub.tax_dist_id_tbl_type;
  l_return_status_service       VARCHAR2(4000);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(4000);


BEGIN

  l_curr_calling_sequence := 'AP_SLA_PROCESSING_PKG.POSTPROCESSING_PROC';
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -------------------------------------------------------------------------
  l_debug_info := 'Begin of procedure '||l_procedure_name;
  trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
  -------------------------------------------------------------------------
  ---------------------------------------------------------------------
  -- This procedure should only called by 'AP', whose application id
  -- is 200. Otherwise exit the procedure.
  ---------------------------------------------------------------------
  IF (p_application_id <> 200) THEN
    RETURN;
  END IF;

  ---------------------------------------------------------------------
  l_debug_info := 'p_accounting_mode =' ||p_accounting_mode;
  trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
  ---------------------------------------------------------------------
  IF ( p_accounting_mode IS NOT NULL ) THEN

    CASE (p_accounting_mode)

      WHEN ('F') THEN -- p_accounting_mode
        -------------------------------------------------------------------------
        l_debug_info := 'final mode';
        trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
        -- FINAL MODE
        -------------------------------------------------------------------------

        OPEN l_events_cur;
        LOOP
        FETCH l_events_cur
        BULK COLLECT INTO l_process_list LIMIT G_COMMIT_SIZE;

        IF ( l_process_list.COUNT <> 0 ) THEN

           -----------------------------------------------------------------------
           l_debug_info :=
            'loop to the events and build list for accrual/cash basis and count=' ||
            l_process_list.COUNT;
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------

           i := 1;
           j := 1;
           k := 1;
           m := 1;
           n := 1;
           ind := 1;
           dd := 1;
           l_dbi_count := 0;

           -----------------------------------------------------------------------
           l_debug_info :=
            'After initialize all the index numbers';
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------

           FOR num IN 1 .. l_process_list.COUNT LOOP
             l_event_rec := l_process_list(num);
             l_event_list(num) := l_event_rec.event_id;

             IF ( l_event_rec.cash_basis_flag = 'Y' ) THEN
               -- cash basis
               -----------------------------------------------------------------------
               l_debug_info :=
               'Add one event id to cash event id list and count =' ||
                l_cash_event_ids.COUNT;
               trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
               -----------------------------------------------------------------------
               l_cash_event_ids(n) := l_event_rec.event_id;
               n := n+1;

               --------------------------------------------------------------------
               l_debug_info :=
               'cash basis event:' || l_event_rec.event_id ||
               'cash basis event_type_code:' || l_event_rec.event_type_code ||
               'source_id:'|| l_event_rec.source_id ||
               'cash_basis_flag:'|| l_event_rec.cash_basis_flag ||
               'when_To_Account_pmt:'|| l_event_rec.when_To_Account_pmt ||
               'cash basis ledger_id:'|| l_event_rec.ledger_id;
               trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
               --------------------------------------------------------------------

               IF l_event_rec.event_type_code IN ('PREPAYMENT APPLIED',
                                                  'PREPAYMENT UNAPPLIED') THEN
                 l_prepay_event_list(j) :=  l_event_rec.event_id;
                 l_invID_list(j) := l_event_rec.source_id;
                 j := j+1;
               ELSIF (l_event_rec.When_to_Account_Pmt = 'ALWAYS' AND
                      l_event_rec.event_type_code in ('PAYMENT CANCELLED',
                                                      'PAYMENT ADJUSTED'))
                      OR (l_event_rec.When_to_Account_Pmt <> 'ALWAYS' AND
                          l_event_rec.event_type_code in ( 'PAYMENT CLEARED',
                                                           'PAYMENT UNCLEARED')) THEN
                 l_payclear_event_list(k) := l_event_rec.event_id;
                 k := k+1;
               ELSE
                 l_other_event_list(m) := l_event_rec.event_id;
                 m := m+1;

               END IF; -- end l_event_rec.event_type_code


             ELSE
               -- accrual basis event
               --------------------------------------------------------------------
               l_debug_info :=
               'accrual basis event:' || l_event_rec.event_id ||
               'accrual basis event_type_code:' || l_event_rec.event_type_code ||
               'source_id:'|| l_event_rec.source_id ||
               'cash_basis_flag:'|| l_event_rec.cash_basis_flag ||
               'when_To_Account_pmt:'|| l_event_rec.when_To_Account_pmt ||
               'accrual basis ledger_id:'|| l_event_rec.ledger_id;
               trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
               --------------------------------------------------------------------
               l_accrual_event_ids(i) := l_event_rec.event_id;
               i := i+1;

               -----------------------------------------------------------------------
               l_debug_info :=
               'After add one event id to accrual event id list and count =' ||
               l_accrual_event_ids.COUNT;
               trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
               -----------------------------------------------------------------------

             END IF;

             -- loop through the whole list to build list to update check
             IF (l_event_rec.event_type_code in ('PAYMENT CLEARED',
                                               'PAYMENT UNCLEARED')) THEN
             -----------------------------------------------------------------------
             l_debug_info :=
             'process all Events building list to update AP_CHECKS for event tyep' ||
             l_event_rec.event_type_code ||
             'event_id = ' || l_event_rec.event_id;
             trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
             -----------------------------------------------------------------------

               SELECT APH.matched_flag, AC.status_lookup_code
               INTO   l_matched_flag, l_status
               FROM   AP_Payment_History_all APH, AP_CHECKS_all AC
               WHERE  AC.check_id = APH.check_id
               AND    APH.accounting_Event_id = l_event_rec.event_id;

               IF  l_status in ('RECONCILED UNACCOUNTED',
                                'CLEARED BUT UNACCOUNTED') THEN

                 l_check_id_list(ind) := l_event_rec.source_id;

                 IF( l_matched_flag = 'Y' ) THEN

                   l_check_status_list(ind) := 'RECONCILED';
                 ELSE

                   IF ( l_status = 'RECONCILED UNACCOUNTED' ) THEN
                     l_check_status_list(ind) := 'RECONCILED';
                   ELSE
                     l_check_status_list(ind) := 'CLEARED';
                   END IF;  -- end of l_status
                 END IF; -- end of l_matched_flag
                 ind := ind+1;
               END IF; -- end of first check l_status

             END IF; -- end of check event type to build check list

           END LOOP;

           -- accrual basis
           -----------------------------------------------------------------------
           l_debug_info :=
            'start to update for accrual basis list and count=' ||
            l_accrual_event_ids.COUNT;
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------


           FORALL num in 1 .. l_accrual_event_ids.COUNT
           UPDATE AP_Invoice_Payments_all
           SET Posted_Flag = 'Y', Accrual_Posted_Flag = 'Y'
           WHERE Accounting_Event_ID = l_accrual_event_ids(num);

           FORALL num in 1 .. l_accrual_event_ids.COUNT
           UPDATE AP_Invoice_Distributions_all
           SET Posted_Flag = 'Y', Accrual_Posted_Flag = 'Y'
           WHERE Accounting_Event_ID = l_accrual_event_ids(num)
           RETURNING invoice_distribution_id,detail_tax_dist_id
           BULK COLLECT INTO l_dbi_key_value_list1,
                             l_tax_dist_id_list1;

           l_dbi_key_final_list := l_dbi_key_value_list1;
           l_tax_dist_id_final_list := l_tax_dist_id_list1;
           -- initialize the collection
           l_dbi_key_value_list1.delete;
           l_tax_dist_id_list1.delete;
           -----------------------------------------------------------------------
           l_debug_info :=
            'Initialize the final dbi list with l_dbi_key_value_list1 and count1=' ||
            l_dbi_key_final_list.COUNT;
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------

           -- bug fix 6975868 begin
           FORALL num in 1 .. l_accrual_event_ids.COUNT
           UPDATE ap_self_assessed_tax_dist_all
           SET Posted_Flag = 'Y', Accrual_Posted_Flag = 'Y'
           WHERE Accounting_Event_ID = l_accrual_event_ids(num)
           RETURNING detail_tax_dist_id
           BULK COLLECT INTO l_tax_dist_id_list1;

           -----------------------------------------------------------------------
           l_debug_info :=
            'Append the final tax deail list with l_tax_dist_id_list1 from self_assessed_tax dists';
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------

            IF ( l_tax_dist_id_list1.COUNT <> 0 ) THEN
           -----------------------------------------------------------------------
           l_debug_info :=
            'l_tax_dist_id_list1 is not null';
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------
             l_tax_count := l_tax_dist_id_final_list.COUNT;

             FOR  num in 1 .. l_tax_dist_id_list1.COUNT LOOP

             -----------------------------------------------------------------------
             l_debug_info :=
             'inside the loop to build  l_tax_dist_final_list';
             trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
             -----------------------------------------------------------------------
               dd :=  l_tax_count + num;
               l_tax_dist_id_final_list(dd) := l_tax_dist_id_list1(num);
             END LOOP;
             l_tax_dist_id_list1.delete;
           END IF;


           -----------------------------------------------------------------------
           l_debug_info :=
            'After append  self_assessed tax dists to the final tax list  and the  count ='||
            l_tax_dist_id_final_list.COUNT;
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------

           -- bug fix 6975868 end

           -- cash basis
           -----------------------------------------------------------------------
           l_debug_info :=
             'start to process event list for CASH basis list and count=' ||
             l_cash_event_ids.COUNT;
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------

           FORALL num in 1 .. l_cash_event_ids.COUNT
           UPDATE AP_Invoice_Payments_all
           SET Posted_Flag = 'Y', Accrual_Posted_Flag = 'N', Cash_Posted_Flag = 'Y'
           WHERE Accounting_Event_ID = l_cash_event_ids(num);

           -- update for prepay event

           -----------------------------------------------------------------------
           l_debug_info :=
             'update for cash basis prepay event list by event and count=' ||
             l_prepay_event_list.COUNT;
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------

           FORALL num in 1 .. l_prepay_event_list.COUNT
           UPDATE AP_Invoice_Distributions_ALL AID
              SET    AID.Posted_Flag = 'Y',
                     AID.Accrual_Posted_Flag = 'N',
                     AID.Cash_Posted_Flag = 'Y'
              WHERE  AID.Accounting_Event_ID = l_prepay_event_list(num)
              RETURNING invoice_distribution_id,detail_tax_dist_id
              BULK COLLECT INTO l_dbi_key_value_list1,
                                l_tax_dist_id_list1;


           -----------------------------------------------------------------------
           l_debug_info :=
            'Append the final dbi list with l_dbi_key_value_list1';
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------

          IF ( l_dbi_key_value_list1.COUNT <> 0 ) THEN
           -----------------------------------------------------------------------
           l_debug_info :=
            'l_dbi_key_value_list1 is not null';
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------
             l_dbi_count := l_dbi_key_final_list.COUNT;
             l_dbi_key_final_list.extend(l_dbi_key_value_list1.COUNT);  -- bug fix 5663077

             FOR  num in 1 .. l_dbi_key_value_list1.COUNT LOOP

             -----------------------------------------------------------------------
             l_debug_info :=
             'inside the loop to build  l_dbi_key_final_list';
             trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
             -----------------------------------------------------------------------
               dd :=  l_dbi_count + num;
               l_dbi_key_final_list(dd) := l_dbi_key_value_list1(num);
             END LOOP;
           -- initialize
           l_dbi_key_value_list1.delete;
           END IF;

           -----------------------------------------------------------------------
           l_debug_info :=
            'Append the final tax deail list with l_tax_dist_id_list1';
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------

            IF ( l_tax_dist_id_list1.COUNT <> 0 ) THEN
           -----------------------------------------------------------------------
           l_debug_info :=
            'l_tax_dist_id_list1 is not null';
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------
             l_tax_count := l_tax_dist_id_final_list.COUNT;

             FOR  num in 1 .. l_tax_dist_id_list1.COUNT LOOP

             -----------------------------------------------------------------------
             l_debug_info :=
             'inside the loop to build  l_tax_dist_final_list';
             trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
             -----------------------------------------------------------------------
               dd :=  l_tax_count + num;
               l_tax_dist_id_final_list(dd) := l_tax_dist_id_list1(num);
             END LOOP;
             l_tax_dist_id_list1.delete;
           END IF;


           -----------------------------------------------------------------------
           l_debug_info :=
            'After append the final dbi list  and the  count' ||
            l_dbi_key_final_list.COUNT ||
            'After append the final tas list  and the  count ='||
            l_tax_dist_id_final_list.COUNT;
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------

           -- bug fix 6975868  begin
           -----------------------------------------------------------------------
           l_debug_info :=
             'update self_assessed tax dists for cash basis prepay event list by event and count=' ||
             l_prepay_event_list.COUNT;
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------

           FORALL num in 1 .. l_prepay_event_list.COUNT
           UPDATE AP_SELF_ASSESSED_TAX_DIST_ALL STID
              SET    STID.Posted_Flag = 'Y',
                     STID.Accrual_Posted_Flag = 'N',
                     STID.Cash_Posted_Flag = 'Y'
              WHERE  STID.Accounting_Event_ID = l_prepay_event_list(num)
              RETURNING detail_tax_dist_id
              BULK COLLECT INTO l_tax_dist_id_list1;

           -----------------------------------------------------------------------
           l_debug_info :=
            'Append the final tax deail list with l_tax_dist_id_list1 from self_assessed tax dists';
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------

            IF ( l_tax_dist_id_list1.COUNT <> 0 ) THEN
           -----------------------------------------------------------------------
           l_debug_info :=
            'l_tax_dist_id_list1 is not null';
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------
             l_tax_count := l_tax_dist_id_final_list.COUNT;

             FOR  num in 1 .. l_tax_dist_id_list1.COUNT LOOP

             -----------------------------------------------------------------------
             l_debug_info :=
             'inside the loop to build  l_tax_dist_final_list';
             trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
             -----------------------------------------------------------------------
               dd :=  l_tax_count + num;
               l_tax_dist_id_final_list(dd) := l_tax_dist_id_list1(num);
             END LOOP;
             l_tax_dist_id_list1.delete;
           END IF;


           -----------------------------------------------------------------------
           l_debug_info :=
            'After append self assessed tax dists to the final tas list  and the  count ='||
            l_tax_dist_id_final_list.COUNT;
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------

           -- bug fix 6975868  end

           -----------------------------------------------------------------------
           l_debug_info :=
             'Update the all payment history records POSTED_FLAGs.';
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------

           FORALL num in 1 .. l_event_list.COUNT
           UPDATE ap_payment_history_all APH
           SET APH.posted_flag = 'Y'
           WHERE APH.accounting_event_id = l_event_list(num);

           -----------------------------------------------------------------------
           l_debug_info :=
            'Update the prepayment history records POSTED_FLAGs';
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------

           FORALL num in 1 .. l_event_list.COUNT
           UPDATE ap_prepay_history_all APPH
           SET    APPH.posted_flag = 'Y'
           WHERE  APPH.accounting_event_id = l_event_list(num);

           -----------------------------------------------------------------------
           l_debug_info :=
            'Update the check staus for  l_check_status_list and count=' ||
             l_check_id_list.COUNT;
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------
            FORALL num in 1 .. l_check_id_list.COUNT
            UPDATE AP_Checks_All
               SET status_lookup_code = l_check_status_list(num)
             WHERE check_id = l_check_id_list(num)
           --Bug 8973135 Start
               AND not exists (SELECT 1 FROM ap_payment_history_all   aph,
                                             ap_system_parameters_all asp
                                WHERE aph.check_id=l_check_id_list(num)
                                  AND posted_flag<>'Y'
                                  AND aph.org_id = asp.org_id
                                  AND (nvl(asp.when_to_account_pmt,'ALWAYS') ='ALWAYS'
                                        OR (asp.when_to_account_pmt          ='CLEARING ONLY'
                                            AND aph.transaction_type in ('PAYMENT CLEARING',
                                           'PAYMENT UNCLEARING','PAYMENT CLEARING ADJUSTED',
                                           'PAYMENT UNCLEARING ADJUSTED'))));
           --Bug 8973135 End

           -----------------------------------------------------------------------
           l_debug_info :=
             'update for cash basis prepay event list by invoice_id and count=' ||
             l_prepay_event_list.COUNT;
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------
           FORALL num in 1 .. l_prepay_event_list.COUNT
           UPDATE AP_Invoice_Distributions_all AID
              SET AID.Cash_Posted_Flag = Derive_Cash_Posted_Flag (
                                     l_prepay_event_list(num),
                                     AID.Invoice_Distribution_ID,
                                     AID.Amount,
                                     l_curr_calling_sequence)
              WHERE AID.Invoice_ID = l_invID_list(num)
              AND AID.Prepay_Distribution_ID IS NULL
              AND AID.prepay_tax_parent_id IS NULL
              AND nvl(AID.cancellation_flag,'N') <> 'Y'
              RETURNING invoice_distribution_id,detail_tax_dist_id
              BULK COLLECT INTO l_dbi_key_value_list1,
                                l_tax_dist_id_list1;

           -----------------------------------------------------------------------
           l_debug_info :=
            'Append the final dbi list with l_dbi_key_value_list1 and count3';
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------
           IF (  l_dbi_key_value_list1.COUNT <> 0 ) THEN
             l_dbi_count := l_dbi_key_final_list.COUNT;
             l_dbi_key_final_list.extend(l_dbi_key_value_list1.COUNT);  -- bug fix 5663077

             FOR  num in 1 .. l_dbi_key_value_list1.COUNT LOOP
               dd := l_dbi_count + num;
               l_dbi_key_final_list(dd) := l_dbi_key_value_list1(num);
             END LOOP;
              -- initialize
              l_dbi_key_value_list1.delete;
           END IF;

           -----------------------------------------------------------------------
           l_debug_info :=
            'Append the final tax list with l_tax_dist_id_list1 and count3';
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------
           IF (  l_tax_dist_id_list1.COUNT <> 0 ) THEN
             l_tax_count := l_tax_dist_id_final_list.COUNT;
             FOR  num in 1 .. l_tax_dist_id_list1.COUNT LOOP
               dd := l_tax_count + num;
               l_tax_dist_id_final_list(dd) := l_tax_dist_id_list1(num);
             END LOOP;
             l_tax_dist_id_list1.delete;
           END IF;

           -----------------------------------------------------------------------
           l_debug_info :=
            'After append the final dbi list  and the  count=' ||
            l_dbi_key_final_list.COUNT;
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------

           -- bug fix 6975868  begin
           -----------------------------------------------------------------------
           l_debug_info :=
             'update for cash basis prepay event list by invoice_id and count=' ||
             l_prepay_event_list.COUNT;
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------
           FORALL num in 1 .. l_prepay_event_list.COUNT
           UPDATE ap_self_assessed_tax_dist_all STID
              SET STID.Cash_Posted_Flag = Derive_Cash_Posted_Flag (
                                     l_prepay_event_list(num),
                                     STID.Invoice_Distribution_ID,
                                     STID.Amount,
                                     l_curr_calling_sequence)
              WHERE STID.Invoice_ID = l_invID_list(num)
              AND STID.Prepay_Distribution_ID IS NULL
              AND nvl(STID.cancellation_flag,'N') <> 'Y'
              RETURNING detail_tax_dist_id
              BULK COLLECT INTO l_tax_dist_id_list1;

           -----------------------------------------------------------------------
           l_debug_info :=
            'Append the final tax list with l_tax_dist_id_list1 from self_assessed tax dists and count3';
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------
           IF (  l_tax_dist_id_list1.COUNT <> 0 ) THEN
             l_tax_count := l_tax_dist_id_final_list.COUNT;
             FOR  num in 1 .. l_tax_dist_id_list1.COUNT LOOP
               dd := l_tax_count + num;
               l_tax_dist_id_final_list(dd) := l_tax_dist_id_list1(num);
             END LOOP;
             l_tax_dist_id_list1.delete;
           END IF;

           -----------------------------------------------------------------------
           l_debug_info :=
            'After append the l_tax_dist_id_final_list from self_assessed tax dists and the  count=' ||
            l_tax_dist_id_final_list.COUNT;
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------

           -- bug fix 6975868  end

           -----------------------------------------------------------------------
           l_debug_info :=
             'update for cash basis payclear event list and count=' ||
             l_payclear_event_list.COUNT;
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------
           FORALL num in 1 .. l_payclear_event_list.COUNT
           UPDATE AP_Invoice_Distributions_all AID --Bug 4659793
            SET AID.Posted_Flag = 'Y', AID.Accrual_Posted_Flag = 'N' ,
                AID.Cash_Posted_Flag = Derive_Cash_Posted_Flag (
                                        l_payclear_event_list(num),
                                        AID.Invoice_Distribution_ID,
                                        AID.Amount,
                                        l_curr_calling_sequence),
                AID.amount_to_post = AID.amount
                                      -nvl(Get_Amt_Already_Accounted(
                                           l_payclear_event_list(num),
                                           -1,
                                           AID.invoice_distribution_id,
                                           'SQL'),0)
           WHERE AID.Invoice_ID IN (SELECT distinct AIP.invoice_id
                                      FROM   Ap_Invoice_Payments_All AIP,
					     Ap_Payment_History_All APH   --bug 9151717
                                     WHERE AIP.check_id = APH.check_id
				       AND APH.Accounting_Event_ID
                                           = l_payclear_event_list(num))
             AND AID.Prepay_Distribution_ID IS NULL
             AND AID.prepay_tax_parent_id IS NULL
             AND nvl(AID.cancellation_flag,'N') <> 'Y' -- Bug 2587500
             RETURNING invoice_distribution_id,detail_tax_dist_id
             BULK COLLECT INTO l_dbi_key_value_list1,
                               l_tax_dist_id_list1;

           -----------------------------------------------------------------------
           l_debug_info :=
            'Append the final dbi list with l_dbi_key_value_list1 and count4';
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------

           IF (  l_dbi_key_value_list1.COUNT <> 0 ) THEN
             l_dbi_count := l_dbi_key_final_list.COUNT;
             l_dbi_key_final_list.extend(l_dbi_key_value_list1.COUNT);  -- bug fix 5663077

             FOR  num in 1 .. l_dbi_key_value_list1.COUNT LOOP
               dd := l_dbi_count + num;
               l_dbi_key_final_list(dd) := l_dbi_key_value_list1(num);
             END LOOP;
             -- initialize
             l_dbi_key_value_list1.delete;
           END IF;

           -----------------------------------------------------------------------
           l_debug_info :=
            'Append the final tax list with l_tax_dist_id_list1 and count4';
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------
           IF (  l_tax_dist_id_list1.COUNT <> 0 ) THEN
             l_tax_count := l_tax_dist_id_final_list.COUNT;
             FOR  num in 1 .. l_tax_dist_id_list1.COUNT LOOP
               dd := l_tax_count + num;
               l_tax_dist_id_final_list(dd) := l_tax_dist_id_list1(num);
             END LOOP;
             l_tax_dist_id_list1.delete;
           END IF;

           -----------------------------------------------------------------------
           l_debug_info :=
            'After append the final dbi list  and the  count=' ||
            l_dbi_key_final_list.COUNT;
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------

           -- bug fix 6975868  begin
           -----------------------------------------------------------------------
           l_debug_info :=
             'update self_assessed tax dists for cash basis payclear event list and count=' ||
             l_payclear_event_list.COUNT;
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------
           FORALL num in 1 .. l_payclear_event_list.COUNT
           UPDATE ap_self_assessed_tax_dist_all STID
            SET STID.Posted_Flag = 'Y', STID.Accrual_Posted_Flag = 'N' ,
                STID.Cash_Posted_Flag = Derive_Cash_Posted_Flag (
                                        l_payclear_event_list(num),
                                        STID.Invoice_Distribution_ID,
                                        STID.Amount,
                                        l_curr_calling_sequence)
           WHERE STID.Invoice_ID IN (SELECT distinct AIP.invoice_id
                                      FROM   Ap_Invoice_Payments_All AIP,
					     Ap_Payment_History_All APH   --bug 9151717
                                     WHERE AIP.check_id = APH.check_id
				       AND APH.Accounting_Event_ID
                                           = l_payclear_event_list(num))
             AND STID.Prepay_Distribution_ID IS NULL
             AND nvl(STID.cancellation_flag,'N') <> 'Y'
             RETURNING detail_tax_dist_id
             BULK COLLECT INTO l_tax_dist_id_list1;

           -----------------------------------------------------------------------
           l_debug_info :=
            'Append the final tax list with l_tax_dist_id_list1 from self_assessed tax dists and count4';
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------
           IF (  l_tax_dist_id_list1.COUNT <> 0 ) THEN
             l_tax_count := l_tax_dist_id_final_list.COUNT;
             FOR  num in 1 .. l_tax_dist_id_list1.COUNT LOOP
               dd := l_tax_count + num;
               l_tax_dist_id_final_list(dd) := l_tax_dist_id_list1(num);
             END LOOP;
             l_tax_dist_id_list1.delete;
           END IF;

           -----------------------------------------------------------------------
           l_debug_info :=
            'After append the l_tax_dist_id_final_list from self_assessed tax dists and the  count=' ||
            l_tax_dist_id_final_list.COUNT;
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------

           -- bug fix 6975868  end

             -- update for other payment accounting options
           -----------------------------------------------------------------------
            l_debug_info :=
            'update for cash basis other payment event list and count=' ||
            l_other_event_list.COUNT;
            trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------
           FORALL num in 1 .. l_other_event_list.COUNT
           UPDATE AP_Invoice_Distributions_all AID --Bug 4659793
              SET AID.Posted_Flag = 'Y', AID.Accrual_Posted_Flag = 'N' ,
                  AID.Cash_Posted_Flag = Derive_Cash_Posted_Flag (
                                           l_other_event_list(num),
                                           AID.Invoice_Distribution_ID,
                                           AID.Amount,
                                           l_curr_calling_sequence)
            WHERE AID.Invoice_ID IN (SELECT AIP.invoice_id
                                       FROM   Ap_Invoice_Payments_All AIP
                                      WHERE  AIP.Accounting_Event_ID
                                               = l_other_event_list(num))
              AND AID.Prepay_Distribution_ID IS NULL
              AND AID.prepay_tax_parent_id IS NULL
              AND nvl(AID.cancellation_flag,'N') <> 'Y'
              RETURNING invoice_distribution_id,detail_tax_dist_id
              BULK COLLECT INTO l_dbi_key_value_list1,
                                l_tax_dist_id_list1;

           -----------------------------------------------------------------------
           l_debug_info :=
            'Append the final dbi list with l_dbi_key_value_list1 and count5';
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------
           IF (  l_dbi_key_value_list1.COUNT <> 0 ) THEN
             l_dbi_count := l_dbi_key_final_list.COUNT;
             l_dbi_key_final_list.extend(l_dbi_key_value_list1.COUNT);  -- bug fix 5663077

             FOR  num in 1 .. l_dbi_key_value_list1.COUNT LOOP
               dd := l_dbi_count + num;
               l_dbi_key_final_list(dd) := l_dbi_key_value_list1(num);
             END LOOP;
             -- initialize
             l_dbi_key_value_list1.delete;
           END IF;

           -----------------------------------------------------------------------
           l_debug_info :=
            'Append the final tax list with l_tax_dist_id_list1 and count5';
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------
           IF (  l_tax_dist_id_list1.COUNT <> 0 ) THEN
             l_tax_count := l_tax_dist_id_final_list.COUNT;
             FOR  num in 1 .. l_tax_dist_id_list1.COUNT LOOP
               dd := l_tax_count + num;
               l_tax_dist_id_final_list(dd) := l_tax_dist_id_list1(num);
             END LOOP;
             l_tax_dist_id_list1.delete;
           END IF;


           -----------------------------------------------------------------------
           l_debug_info :=
            'After append the final dbi list  and the  count=' ||
            l_dbi_key_final_list.COUNT;
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------
           -- bug fix 6975868  begin

           -----------------------------------------------------------------------
            l_debug_info :=
            'update self_assessed tax dists for cash basis other payment event list and count=' ||
            l_other_event_list.COUNT;
            trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------
           FORALL num in 1 .. l_other_event_list.COUNT
           UPDATE ap_self_assessed_tax_dist_all STID
              SET STID.Posted_Flag = 'Y', STID.Accrual_Posted_Flag = 'N' ,
                  STID.Cash_Posted_Flag = Derive_Cash_Posted_Flag (
                                           l_other_event_list(num),
                                           STID.Invoice_Distribution_ID,
                                           STID.Amount,
                                           l_curr_calling_sequence)
            WHERE STID.Invoice_ID IN (SELECT AIP.invoice_id
                                       FROM   Ap_Invoice_Payments_All AIP
                                      WHERE  AIP.Accounting_Event_ID
                                               = l_other_event_list(num))
              AND STID.Prepay_Distribution_ID IS NULL
              AND nvl(STID.cancellation_flag,'N') <> 'Y'
              RETURNING detail_tax_dist_id
              BULK COLLECT INTO l_tax_dist_id_list1;

           -----------------------------------------------------------------------
           l_debug_info :=
            'Append the final tax list with l_tax_dist_id_list1 from self_assessed tax dists and count5';
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------
           IF (  l_tax_dist_id_list1.COUNT <> 0 ) THEN
             l_tax_count := l_tax_dist_id_final_list.COUNT;
             FOR  num in 1 .. l_tax_dist_id_list1.COUNT LOOP
               dd := l_tax_count + num;
               l_tax_dist_id_final_list(dd) := l_tax_dist_id_list1(num);
             END LOOP;
             l_tax_dist_id_list1.delete;
           END IF;

           -----------------------------------------------------------------------
           l_debug_info :=
            'After append the l_tax_dist_id_final_list from self_assessed tax dists and the  count=' ||
            l_tax_dist_id_final_list.COUNT;
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------
           -- bug fix 6975868  end

	   -----------------------------------------------------------------------
           l_debug_info :=
            'calling DBI API and fial list count =' ||
            l_dbi_key_final_list.COUNT;
           trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
           -----------------------------------------------------------------------

           AP_DBI_PKG.Maintain_DBI_Summary
                         (p_table_name => 'AP_INVOICE_DISTRIBUTIONS',
                          p_operation => 'U',
                          p_key_value1 => NULL,
                          p_key_value_list => l_dbi_key_final_list,
                          p_calling_sequence => l_curr_calling_sequence);

           IF (  l_tax_dist_id_final_list.COUNT <> 0 ) THEN
             -----------------------------------------------------------------------
             l_debug_info :='Need to call eTax api to update the posted flag';
             trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
             -----------------------------------------------------------------------

             zx_api_pub.update_posting_flag(
                p_api_version           => 1.0,
                p_init_msg_list         => FND_API.G_TRUE,
                p_commit                => FND_API.G_FALSE,
                p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                x_return_status         => l_return_status_service,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data,
                p_tax_dist_id_tbl       => l_tax_dist_id_final_list );

             l_tax_dist_id_final_list.DELETE;

             IF (  l_return_status_service <> FND_API.G_RET_STS_SUCCESS ) THEN

               FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
               FND_MESSAGE.SET_TOKEN('ERROR','calling etax api fails');
               FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
               FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
               app_exception.raise_exception();

             END IF;

           END IF;

         END IF ; -- end of l_process_list.COUNT<> 0

         -----------------------------------------------------------------------
         l_debug_info :=
         'Doing pl/sql table cleanup within the commit size cycle';
         trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
         -----------------------------------------------------------------------

         IF ( l_process_list.count <> 0 ) THEN
            l_process_list.DELETE;
         END IF;

         IF (  l_event_list.count <> 0 ) THEN
           l_event_list.DELETE;
         END IF;

         IF ( l_accrual_event_ids.count <> 0 ) THEN
           l_accrual_event_ids.DELETE;
         END IF;

         IF ( l_cash_event_ids.count <> 0 ) THEN
           l_cash_event_ids.DELETE;
         END IF;

         IF ( l_prepay_event_list.count <> 0 ) THEN
           l_prepay_event_list.DELETE;
         END IF;

         IF ( l_payclear_event_list.count <> 0 ) THEN
           l_payclear_event_list.DELETE;
         END IF;

         IF (   l_other_event_list.count <> 0 ) THEN
           l_other_event_list.DELETE;
         END IF;

         IF ( l_invID_list.count <> 0 ) THEN
           l_invID_list.DELETE;
         END IF;

         IF ( l_check_status_list.count <> 0 ) THEN
           l_check_status_list.DELETE;
         END IF;

         IF ( l_check_id_list.count <> 0 ) THEN
           l_check_id_list.DELETE;
         END IF;

        EXIT WHEN l_events_cur%NOTFOUND;
        END LOOP;
        CLOSE l_events_cur;


      WHEN ('D') THEN -- p_accounting_mode
      -----------------------------------------------------------------------
      l_debug_info := 'draft mode';
      trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
      -- DRAFT MODE
      ----------------------------------------------------------------------
        NULL;

      WHEN ('FUNDS_CHECK') THEN -- p_accounting_mode
      -----------------------------------------------------------------------
      l_debug_info :='funds check mode';
      trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
      -- FUNDS CHECK  MODE
      ----------------------------------------------------------------------
        NULL;

      WHEN ('FUNDS_RESERVE') THEN -- p_accounting_mode
      -----------------------------------------------------------------------
      l_debug_info := 'funds reserve mode';
      trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
      -- funds reserve mode
      ----------------------------------------------------------------------
        NULL;

      ELSE
        ---------------------------------------------------------------------
        l_debug_info := 'Others: p_accounting_mode = '|| p_accounting_mode;
        trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
        ---------------------------------------------------------------------
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR','Wrong p_accounting_mode');
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                'p_accounting_mode = '||p_accounting_mode);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

        app_exception.raise_exception();

    END CASE; -- p_accounting_mode

  END IF; -- end of checking p_accountinng_mode is not null

  -------------------------------------------------------------------------
  l_debug_info := 'End of procedure'||l_procedure_name;
  trace(G_LEVEL_PROCEDURE, l_procedure_name, l_debug_info);
  -------------------------------------------------------------------------

EXCEPTION

  WHEN OTHERS THEN

    IF (l_events_cur%ISOPEN) THEN

      CLOSE l_events_cur;

    END IF;

    ---------------------------------------------------------------------
    l_debug_info := 'clean up and set back posted flag value to N';
    trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
    ---------------------------------------------------------------------
   /* -- need to make the following autonmous commit
    UPDATE ap_payment_history_All APH
    SET    POSTED_FLAG = 'N'
    WHERE  APH.accounting_event_id in
           ( select event_id from xla_events_gt);

    UPDATE ap_invoice_distributions_All AID
    SET    POSTED_FLAG = 'N'
    WHERE  AID.accounting_event_id in
           ( select event_id from xla_events_gt);

    UPDATE ap_self_assessed_tax_dist_all AID
    SET    POSTED_FLAG = 'N'
    WHERE  AID.accounting_event_id in
           ( select event_id from xla_events_gt);

    UPDATE ap_invoice_payments_all AIP
    SET    POSTED_FLAG = 'N'
    WHERE  AIP.accounting_event_id in
           ( select event_id from xla_events_gt);

    UPDATE ap_prepay_history_all   APPH
    SET    APPH.posted_flag = 'N'
    WHERE  APPH.accounting_event_id in
           ( select event_id from xla_events_gt);
    -- */


    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
              'p_application_id  = '|| p_application_id ||' '||
              'p_accounting_mode = '|| p_accounting_mode);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;

    app_exception.raise_exception();

END postprocessing;

/*============================================================================
 |  PROCEDURE - EXTRACT (PUBLIC)
 |
 |  DESCRIPTION
 |    This procedure is the AP SLA extract procedure. This procedure
 |    will be called by SLA thorugh an API.
 |
 |  PRAMETERS
 |    p_application_id
 |      This parameter is the application ID of the application that the SLA
 |      workflow event is for. This procedure must exit without doing anything
 |      if this parameter is not 200 to ensure that this procedure is only
 |      executed when the workflow event is for AP. This parameter will never
 |      be NULL.
 |   p_accounting_mode
 |     This parameter is the "accounting mode" that the accounting is being
 |     run in. This parameter will never be NULL.
 |     +-------+-----------------------------------------------------------+
 |     | Value | Meaning                                                   |
 |     +-------+-----------------------------------------------------------+
 |     | 'D'   | The accounting is being run in "draft mode". Draft mode is|
 |     |       | used TO examine what the accounting entries would look for|
 |     |       | an event without actually creating the accounting entries |
 |     | 'F'   | The accounting is being run in "final mode". Final mode is|
 |     |       | used to create accounting entries.                        |
 |     +-------+-----------------------------------------------------------+
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |    1) This procedure is run in final mode and draft mode.
 |    2) This procedure is run in batch mode and document mode.
 |    3) This procedure is part of the accounting commit cycle.
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/

PROCEDURE extract
(
  p_application_id               IN            NUMBER,
  p_accounting_mode              IN            VARCHAR2
)
IS

  CURSOR l_events_cur IS
  SELECT XEG.event_id
  FROM   xla_events_gt XEG
  WHERE  XEG.application_id = 200;

  l_event_ids                    l_event_ids_typ;
  l_debug_info                   VARCHAR2(240);
  l_procedure_name               CONSTANT VARCHAR2(30):='EXTRACT';
  l_curr_calling_sequence        VARCHAR2(2000);

BEGIN

  l_curr_calling_sequence := 'AP_SLA_PROCESSING_PKG.EXTRACT';
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -------------------------------------------------------------------------
  l_debug_info := 'Begin of procedure '||l_procedure_name;
  trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
  -------------------------------------------------------------------------
  -------------------------------------------------------------------------
  -- This procedure should only called by 'AP', whose application id
  -- is 200. Otherwise exit the procedure.
  IF (p_application_id <> 200) THEN
    RETURN;
  END IF;

  -------------------------------------------------------------------------
  l_debug_info := 'About to call lock_documents to update posted flag';
  trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
  -------------------------------------------------------------------------

   IF ( p_accounting_mode IS NOT NULL AND p_accounting_mode = 'F') THEN

    OPEN l_events_cur;
      LOOP
        FETCH l_events_cur
        BULK COLLECT INTO l_event_ids LIMIT 1000;

          Lock_Documents_autonomous( p_event_ids => l_event_ids,
                                    p_calling_sequence => l_curr_calling_sequence);
        EXIT WHEN l_events_cur%NOTFOUND;
      END LOOP;
    CLOSE l_events_cur;

   END IF;

  -------------------------------------------------------------------------
  l_debug_info := 'About to call AP_ACCOUNTING_PAY_PKG.Do_Pay_Accounting';
  trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
  -------------------------------------------------------------------------

  -------------------------------------------------------------------------
  --  The call below will populate the prepayment distributions table
  --  and the payment distributions table for the events that are
  --  in xla_events_gt
  -------------------------------------------------------------------------

  AP_ACCOUNTING_PAY_PKG.Do_Pay_Accounting(l_curr_calling_sequence);

  -------------------------------------------------------------------------
  l_debug_info := 'End of procedure'||l_procedure_name;
  trace(G_LEVEL_PROCEDURE, l_procedure_name, l_debug_info);
  -------------------------------------------------------------------------

EXCEPTION

  WHEN OTHERS THEN

    IF (l_events_cur%ISOPEN) THEN

      CLOSE l_events_cur;

    END IF;

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
              'p_application_id  = '|| p_application_id ||' '||
              'p_accounting_mode = '|| p_accounting_mode);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;

    app_exception.raise_exception();

END extract;



/*============================================================================
 |  PROCEDURE -  POSTACCOUNTING(PUBLIC)
 |
 |  DESCRIPTION
 |    This procedure is the AP SLA post-accounting procedure. This procedure
 |    will be called by SLA through an API.
 |
 |  PRAMETERS
 |    p_application_id
 |      This parameter is the application ID of the application that the SLA
 |      workflow event is for. This procedure must exit without doing anything
 |      if this parameter is not 200 to ensure that this procedure is only
 |      executed when the workflow event is for AP. This parameter will never
 |      be NULL.
 |    p_ledger_id
 |      This parameter is the ledger ID of the ledger to account. This
 |      parameter is purely informational. This procedure selects from the
 |      XLA_ENTITY_EVENTS_V view, which does not include events incompatible
 |      with this parameter. This parameter will never be NULL.
 |    p_process_category
 |      This parameter is the "process category" of the events to account.
 |      This parameter is purely informational. This procedure selects from
 |      the XLA_ENTITY_EVENTS_V view, which does not include events
 |      incompatible with this parameter.Possible values are as following:
 |      +------------+-------------------------------+
 |      | Value      | Meaning                       |
 |      +------------+-------------------------------+
 |      | 'Invoices' | process invoices              |
 |      | 'Payments' | process payments and receipts |
 |      | 'All'      | process everything            |
 |      +------------+-------------------------------+
 |    p_end_date
 |      This parameter is the maximum event date of the events to be processed
 |      in this run of the accounting. This procedure selects from the
 |      XLA_ENTITY_EVENTS_V view, which does not include events incompatible
 |      with this parameter. This parameter will never be NULL.
 |    p_accounting_mode
 |      This parameter is the "accounting mode" that the accounting is being
 |      run in. This parameter will never be NULL.
 |      +-------+-------------------------------------------------------------+
 |      | Value | Meaning                                                     |
 |      +-------+-------------------------------------------------------------+
 |      | 'D'   | The accounting is being run in "draft mode". Draft mode is  |
 |      |       | used to examine what the accounting entries would look for  |
 |      |       | an event without actually creating the accounting entries.  |
 |      | 'F'   | The accounting is being run in "final mode". Final mode is  |
 |      |       | used to create accounting entries.                          |
 |      +-------+-------------------------------------------------------------+
 |    p_valuation_method
 |       This parameter is unused by AP. This parameter is purely informational
 |       This procedure selects from the XLA_ENTITY_EVENTS_V view, which does
 |       not include events incompatible with this parameter.
 |    p_security_id_int_1
 |      This parameter is unused by AP.
 |    p_security_id_int_2
 |      This parameter is unused by AP.
 |    p_security_id_int_3
 |      This parameter is unused by AP.
 |    p_security_id_char_1
 |      This parameter is unused by AP.
 |    p_security_id_char_2
 |      This parameter is unused by AP.
 |    p_security_id_char_3
 |      This parameter is unused by AP.
 |    p_report_request_id
 |      This parameter is the concurrent request ID of the concurrent request
 |      that is this run of the accounting. This parameter is used to specify
 |      which events in the XLA_ENTITY_EVENTS_V view are to be accounted in
 |      this run of the accounting. This parameter will never be NULL.
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |    1) This procedure is run in final mode and draft mode.
 |    2) This procedure is run in batch mode but not in document mode.
 |    3) This procedure is in its own commit cycle.
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/

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

  TYPE l_event_ids_typ IS
    TABLE OF NUMBER(15)
    INDEX BY PLS_INTEGER;

  TYPE l_event_status_typ IS
    TABLE OF xla_events.event_status_code%TYPE
    INDEX BY PLS_INTEGER;

  -----------------------------------------------------------------------------
  -- The XLA_EVENTS table contains all the events processed in this run
  -- of the accounting.
  -----------------------------------------------------------------------------

  CURSOR l_events_cur IS
  SELECT XEE.event_id, XEE.event_status_code
  FROM   xla_events XEE
  WHERE  XEE.application_id = 200
  AND    XEE.request_id = p_report_request_id
  AND    XEE.event_status_code <> 'P';

  l_event_status                 l_event_status_typ;
  l_event_ids                    l_event_ids_typ;
  l_debug_info                   VARCHAR2(240);
  l_procedure_name               CONSTANT VARCHAR2(30):='POST_ACCOUNTING_PROC';
  l_curr_calling_sequence        VARCHAR2(2000);

BEGIN
  l_curr_calling_sequence := 'AP_SLA_PROCESSING_PKG.POST_ACCOUNTING_PROC';
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  ---------------------------------------------------------------------
  l_debug_info := 'Begin of procedure '||l_procedure_name;
  trace(G_LEVEL_PROCEDURE, l_procedure_name, l_debug_info);
  ---------------------------------------------------------------------


  IF (p_application_id <> 200) THEN
    RETURN;
  END IF;

  ---------------------------------------------------------------------
  l_debug_info := 'case p_accounting_mode :='||p_accounting_mode;
  trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
  ---------------------------------------------------------------------

  IF (  p_accounting_mode IS NOT NULL ) THEN

  ---------------------------------------------------------------------
  l_debug_info := 'p_accounting_mode not null - not transfer only mode';
  trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
  ---------------------------------------------------------------------
  ---------------------------------------------------------------------
  l_debug_info := 'case p_accounting_mode :='||p_accounting_mode;
  trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
  ---------------------------------------------------------------------
    CASE (p_accounting_mode)

    -------------------------------------------------------------------------
    -- FINAL MODE
    -------------------------------------------------------------------------
      WHEN ('F') THEN -- p_accounting_mode
        OPEN l_events_cur;
        LOOP

          FETCH l_events_cur
          BULK COLLECT INTO
            l_event_ids,
            l_event_status
          LIMIT 1000;

          ---------------------------------------------------------------------
          l_debug_info :=
            'Update the payment distributions'' POSTED_FLAGs.';
          trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
          ---------------------------------------------------------------------
          -- rewrote for bug fix 5694577
          -- When payment accounting option is CLEAR ONLY, need to set the
          -- posted_flag to 'Y' for payment create and maturity event after
          -- Create Accounting program

          -- FORALL i IN 1 .. l_event_ids.count
          -- UPDATE ap_payment_history_all APH
          -- SET APH.posted_flag = 'N'
          -- WHERE APH.accounting_event_id = l_event_ids(i);

          -- Bug 7374984. Updating the posted flag to 'Y' if the events
          -- are set to no action.
          FORALL i IN 1 .. l_event_ids.count
          UPDATE ap_payment_history_all APH
            SET APH.POSTED_FLAG = CASE
                                        /* commented for the bug9245156
					WHEN
                                        l_event_status(i) in ('U','N')--added N for Bug 7594938
                                        AND EXISTS(SELECT 1
                                                     FROM ap_system_parameters asp
                                                    WHERE asp.when_to_account_pmt = 'CLEARING ONLY'
                                                    --  AND asp.org_id = l_org_ids(i)
                                                      AND asp.org_id = aph.org_id
                                                      AND aph.accounting_event_id = l_event_ids(i)
                                                      AND aph.transaction_type in ('PAYMENT CREATED', 'PAYMENT MATURITY','REFUND RECORDED')--REFUND RECORDED added in bug 7594938
                                                   )
                                       THEN 'Y'
                                      */
                                       WHEN l_event_status(i) = 'N' -- Bug 7374984
                                       THEN 'Y'
                                       ELSE 'N'
                                       END
          WHERE APH.accounting_event_id = l_event_ids(i);

          ---------------------------------------------------------------------
          l_debug_info :=
            'Update the prepayment header'' POSTED_FLAGs.';
          trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
          ---------------------------------------------------------------------

          FORALL i IN 1 .. l_event_ids.count
          UPDATE ap_prepay_history_all   APPH
          SET    APPH.posted_flag = 'N'
          WHERE  APPH.accounting_event_id = l_event_ids(i);

          ---------------------------------------------------------------------
          l_debug_info :=
            'Update the payments'' POSTED_FLAGs.';
          trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
          ---------------------------------------------------------------------
          -- rewrote for bug fix 5694577
          -- When payment accounting option is CLEAR ONLY, need to set the
          -- posted_flag to 'Y' for payment create and maturity event after
          -- Create Accounting program

          -- FORALL i IN 1 .. l_event_ids.count
          -- UPDATE ap_invoice_payments_all AIP
          -- SET AIP.posted_flag = 'N'
          -- WHERE AIP.accounting_event_id = l_event_ids(i);

          FORALL i IN 1 .. l_event_ids.count
          UPDATE ap_invoice_payments_all AIP
             SET AIP.POSTED_FLAG = CASE
                                      /* commented for bug9245156
                                       WHEN l_event_status(i) in ('U','N') --added N for Bug 7594938
                                         AND EXISTS(SELECT 1
                                                     FROM ap_system_parameters asp, ap_payment_history_all aph
                                                    WHERE asp.when_to_account_pmt = 'CLEARING ONLY'
                                                      --AND asp.org_id = l_org_id(i)
                                                      AND asp.org_id = aph.org_id
                                                      AND aph.accounting_event_id = l_event_ids(i)
                                                      AND aph.transaction_type in ('PAYMENT CREATED', 'PAYMENT MATURITY','REFUND RECORDED')--REFUND RECORDED added in bug 7594938
                                                   )
                                       THEN 'Y'
                                      */
                                       WHEN l_event_status(i) = 'N' -- Bug  8771563
                                       THEN 'Y'
                                       ELSE 'N'
                                       END
           WHERE AIP.accounting_event_id = l_event_ids(i);

          ---------------------------------------------------------------------
          l_debug_info :=
            'Update the distributions'' POSTED_FLAGs.';
          trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
          ---------------------------------------------------------------------

          FORALL i IN 1 .. l_event_ids.count
          UPDATE ap_invoice_distributions_all AID
          SET AID.posted_flag = 'N'
          WHERE AID.accounting_event_id = l_event_ids(i);

          FORALL i IN 1 .. l_event_ids.count
          UPDATE AP_SELF_ASSESSED_TAX_DIST_ALL STID
          SET STID.posted_flag = 'N'
          WHERE STID.accounting_event_id = l_event_ids(i);

          EXIT WHEN l_events_cur%NOTFOUND;
        END LOOP;
        CLOSE l_events_cur;

    -------------------------------------------------------------------------
    -- DRAFT MODE
    -------------------------------------------------------------------------
      WHEN ('D') THEN -- p_accounting_mode
        NULL;

      WHEN ('FUNDS_CHECK') THEN -- p_accounting_mode
        -----------------------------------------------------------------------
        l_debug_info := 'p_accounting_mode ='||p_accounting_mode;
        trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
        -- funds check
        -----------------------------------------------------------------------
        NULL;

      WHEN ('FUNDS_RESERVE') THEN -- p_accounting_mode
        -----------------------------------------------------------------------
        l_debug_info := 'p_accounting_mode ='||p_accounting_mode;
        trace(G_LEVEL_STATEMENT, l_procedure_name, l_debug_info);
        -- funds reserve
        -----------------------------------------------------------------------
        NULL;

      ELSE    -- different value for p_accounting_mode
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR','Wrong p_accounting_mode');
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                              l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                     'p_accounting_mode  = '|| p_accounting_mode);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

        app_exception.raise_exception();

    END CASE; -- p_accounting_mode

  END IF; -- END of checking p_accounting_mode
  ------------------------------------------------------------------------
  l_debug_info :=
        'End of procedure '||l_procedure_name;
  trace(G_LEVEL_PROCEDURE, l_procedure_name, l_debug_info);
  ------------------------------------------------------------------------
  COMMIT;

EXCEPTION

  WHEN OTHERS THEN

    IF (l_events_cur%ISOPEN) THEN

      CLOSE l_events_cur;

    END IF;

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
        'p_application_id='     || p_application_id     || ' ' ||
        'p_ledger_id='          || p_ledger_id          || ' ' ||
        'p_process_category='   || p_process_category   || ' ' ||
        'p_end_date='           || p_end_date           || ' ' ||
        'p_accounting_mode='    || p_accounting_mode    || ' ' ||
        'p_valuation_method='   || p_valuation_method   || ' ' ||
        'p_security_id_int_1='  || p_security_id_int_1  || ' ' ||
        'p_security_id_int_2='  || p_security_id_int_2  || ' ' ||
        'p_security_id_int_3='  || p_security_id_int_3  || ' ' ||
        'p_security_id_char_1=' || p_security_id_char_1 || ' ' ||
        'p_security_id_char_2=' || p_security_id_char_2 || ' ' ||
        'p_security_id_char_3=' || p_security_id_char_3 || ' ' ||
        'p_report_request_id='  || p_report_request_id);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;

    app_exception.raise_exception();

END postaccounting;


-------------------------------------------------------------------------------
-- FUNCTION Get_Amt_Already_Accounted RETURN NUMBER
-- RETURN the amount already accounted for a distribution in this set of books.
-- This function is primarily used in figuring out NOCOPY the amount of the
-- distribution that has already been accounted in Cash Basis.

-- Parameters
   ----------
   -- SOB_ID - The set of books in which this amount is to be calculated
   -- Invoice_Distribution_ID - The distribution for which this amount is
--    to be calculated
-------------------------------------------------------------------------------
FUNCTION Get_Amt_Already_Accounted
                  (P_event_id                  IN    NUMBER
                  ,P_invoice_payment_id        IN    NUMBER
                  ,P_invoice_distribution_id   IN    NUMBER
                  ,P_calling_sequence          IN    VARCHAR2
                  ) RETURN NUMBER IS

  l_amt_already_accounted    NUMBER := 0 ;
  l_curr_calling_sequence    VARCHAR2(2000);

  l_transaction_type         VARCHAR2(30);
  l_paid_acctd_amt           NUMBER;
  l_prepaid_acctd_amt        NUMBER;

BEGIN

  l_curr_calling_sequence :=
    'AP_SLA_PROCESSING_PKG.Get_Amt_Already_Accounted<-' || P_calling_sequence;

  BEGIN
    SELECT APH.Transaction_Type
    INTO   l_transaction_type
    FROM   AP_Payment_History_All APH
    WHERE  APH.Accounting_Event_ID = P_Event_ID;
  EXCEPTION
    WHEN others THEN
         l_transaction_type := 'PAYMENT CREATED';
  END;


  IF (l_transaction_type IN ('PAYMENT CLEARING', 'PAYMENT UNCLEARING',
                                      'PAYMENT CLEARING ADJUSTED')) THEN

      /* Getting the sum of dist amount for the given distribution */
      SELECT SUM(APHD.Invoice_Dist_Amount)
      INTO   l_paid_acctd_amt
      FROM   AP_Payment_Hist_Dists APHD,
             AP_Payment_History_All APH
      WHERE  APHD.Invoice_Distribution_ID = p_invoice_distribution_id
      AND    APH.Posted_Flag = 'Y'
      AND    APH.Payment_History_ID = APHD.Payment_History_ID
      AND    APH.Transaction_Type IN ('PAYMENT CLEARING', 'PAYMENT UNCLEARING',
                                      'PAYMENT CLEARING ADJUSTED');

  ELSIF (l_transaction_type IN ('PAYMENT MATURITY', 'PAYMENT MATURITY REVERSED',
                                'PAYMENT MATURITY ADJUSTED')) THEN

      /* Getting the sum of dist amount for the given distribution */
      SELECT SUM(APHD.Invoice_Dist_Amount)
      INTO   l_paid_acctd_amt
      FROM   AP_Payment_Hist_Dists APHD,
             AP_Payment_History_All APH
      WHERE  APHD.Invoice_Distribution_ID = p_invoice_distribution_id
      AND    APH.Posted_Flag = 'Y'
      AND    APH.Payment_History_ID = APHD.Payment_History_ID
      AND    APH.Transaction_Type IN ('PAYMENT MATURITY', 'PAYMENT MATURITY REVERSED',
                                      'PAYMENT MATURITY ADJUSTED');

  ELSE

      /* Getting the sum of dist amount for the given distribution */
      SELECT SUM(APHD.Invoice_Dist_Amount)
      INTO   l_paid_acctd_amt
      FROM   AP_Payment_Hist_Dists APHD,
             AP_Payment_History_All APH
      WHERE  APHD.Invoice_Distribution_ID = p_invoice_distribution_id
      AND    APH.Posted_Flag = 'Y'
      AND    APH.Payment_History_ID = APHD.Payment_History_ID
      AND    APH.Transaction_Type IN ('PAYMENT CREATED', 'PAYMENT CANCELLED', 'PAYMENT ADJUSTED',
                                      'MANUAL PAYMENT ADJUSTED',
                                      'REFUND RECORDED', 'REFUND ADJUSTED', 'REFUND CANCELLED');

  END IF;

  /* Get the total prepaid amount from the ap_prepay_app_dists table */
  SELECT SUM(APAD.Amount)
  INTO   l_prepaid_acctd_amt
  FROM   AP_Prepay_App_Dists APAD,
         AP_Prepay_History_All APH
  WHERE  APAD.Invoice_Distribution_ID = p_invoice_distribution_id
  AND    APAD.Prepay_History_ID = APH.Prepay_History_ID
  AND    APH.Posted_Flag = 'Y';

  l_amt_already_accounted := NVL(l_paid_acctd_amt,0) + NVL(l_prepaid_acctd_amt,0);

  RETURN nvl(l_amt_already_accounted,0) ;

END Get_Amt_Already_Accounted;


-------------------------------------------------------------------------------
-- FUNCTION Derive_Cash_Posted_Flag RETURN VARCHAR2
-- For a distribution, this function figures out NOCOPY the amount that has already
-- been accounted in Cash Basis and then RETURN the proper value for the
-- cash_posted_flag.

-- Parameters
   ----------
   -- SOB_ID - The cash SOB ID
   -- Distribution_ID - The Invoice Distribution for which the cash_posted_flag
--                      has to be derived
-------------------------------------------------------------------------------
FUNCTION Derive_Cash_Posted_Flag
                 (P_event_id          IN      NUMBER
                 ,P_distribution_id   IN      NUMBER
                 ,P_dist_amount       IN      NUMBER
                 ,P_calling_sequence  IN      VARCHAR2
                 ) RETURN VARCHAR2 IS

  l_already_accounted_amt      NUMBER;
  l_distribution_amount        NUMBER;
  l_curr_calling_sequence      VARCHAR2(2000);


BEGIN

  l_curr_calling_sequence := 'AP_SLA_PROCESSING_PKG.Derive_Cash_Posted_Flag<-'
                             || P_calling_sequence;

  /*
   Since accounting is done either for all SOB's or None, it is safe to assume
   that the accounted amount will be the same for all cash SOB's. Hence, we
   are taking the liberty of passing the Main Cash SOB ID and not bothering
   about its reporting SOB's.
  */
  l_already_accounted_amt := Get_Amt_Already_Accounted (P_event_id,
                               -1, P_distribution_id, l_curr_calling_sequence) ;


  IF l_already_accounted_amt = P_dist_amount THEN

    return ('Y') ;
  ELSIF l_already_accounted_amt = 0 THEN

    return ('N') ;

  ELSIF ABS(l_already_accounted_amt) < ABS(P_dist_amount) THEN

    return ('P') ;

  ELSE

    return ('Y') ;

  END IF;

END Derive_Cash_Posted_Flag;

END ap_sla_processing_pkg;

/
