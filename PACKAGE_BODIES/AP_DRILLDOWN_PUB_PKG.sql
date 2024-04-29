--------------------------------------------------------
--  DDL for Package Body AP_DRILLDOWN_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_DRILLDOWN_PUB_PKG" as
/* $Header: apsladrb.pls 120.6.12010000.7 2010/03/31 19:35:02 gagrawal ship $ */

-- Logging Infra
  G_CURRENT_RUNTIME_LEVEL      NUMBER                := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED           CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR                CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT                CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE            CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(50) := 'AP.PLSQL.AP_DRILLDOWN_PUB_PKG.';
-- Logging Infra

/*----------------------------------------------------------------
 |Private procedure: get_invoice_info
 +---------------------------------------------------------------*/
PROCEDURE get_invoice_info
( p_invoice_id IN NUMBER,
  p_org_id OUT NOCOPY NUMBER,
  p_legal_entity_id OUT NOCOPY NUMBER,
  p_ledger_id OUT NOCOPY NUMBER,
  p_calling_sequence IN VARCHAR2
);

/*----------------------------------------------------------------
 |Private procedure: get_payment_info
 +---------------------------------------------------------------*/
PROCEDURE get_payment_info
( p_check_id IN NUMBER,
  p_org_id OUT NOCOPY NUMBER,
  p_legal_entity_id OUT NOCOPY NUMBER,
  p_ledger_id OUT NOCOPY NUMBER,
  p_calling_sequence IN VARCHAR2
);

 /*---------------------------------------------------------------
 |Private procedure: get_invoice_event_source_info
 +---------------------------------------------------------------*/
FUNCTION get_invoice_event_source_info
( p_legal_entity_id IN NUMBER,
  p_ledger_id IN NUMBER,
  p_invoice_id IN NUMBER,
  p_calling_sequence IN VARCHAR2
) RETURN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO;

 /*---------------------------------------------------------------
 |Private procedure: get_payment_event_source_info
 +---------------------------------------------------------------*/
FUNCTION get_payment_event_source_info
( p_legal_entity_id IN NUMBER,
  p_ledger_id IN NUMBER,
  p_check_id IN NUMBER,
  p_calling_sequence IN VARCHAR2
) RETURN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO;

/*========================================================================
 | PROCEDURE:  DRILLDOWN
 | COMMENT:    DRILLDOWN procedure provides a public API for sla to return
 |             the appropriate information via OUT parameters to open the
 |             appropriate transaction form.
 | PARAMETERS:
 |   p_application_id     : Subledger application internal identifier
 |   p_ledger_id          : Event ledger identifier
 |   p_legal_entity_id    : Legal entity identifier
 |   p_entity_code        : Event entity internal code
 |   p_event_class_code   : Event class internal code
 |   p_event_type_code    : Event type internal code
 |   p_source_id_int_1    : Generic system transaction identifiers
 |   p_source_id_int_2    : Generic system transaction identifiers
 |   p_source_id_int_3    : Generic system transaction identifiers
 |   p_source_id_int_4    : Generic system transaction identifiers
 |   p_source_id_char_1   : Generic system transaction identifiers
 |   p_source_id_char_2   : Generic system transaction identifiers
 |   p_source_id_char_3   : Generic system transaction identifiers
 |   p_source_id_char_4   : Generic system transaction identifiers
 |   p_security_id_int_1  : Generic system transaction identifiers
 |   p_security_id_int_2  : Generic system transaction identifiers
 |   p_security_id_int_3  : Generic system transaction identifiers
 |   p_security_id_char_1 : Generic system transaction identifiers
 |   p_security_id_char_2 : Generic system transaction identifiers
 |   p_security_id_char_3 : Generic system transaction identifiers
 |   p_valuation_method   : Valuation Method internal identifier
 |   p_user_interface_type: This parameter determines the user interface type.
 |                          The possible values are FORM, HTML, or NONE.
 |   p_function_name      : The name of the Oracle Application Object
 |                          Library function defined to open the transaction
 |                          form. This parameter is used only if the page
 |                          is a FORM page.
 |   p_parameters         : An Oracle Application Object Library Function
 |                          can have its own arguments/parameters. SLA
 |                          expects developers to return these arguments via
 |                          p_parameters.
 |
 +===========================================================================*/

PROCEDURE DRILLDOWN
(p_application_id      IN            INTEGER
,p_ledger_id           IN            INTEGER
,p_legal_entity_id     IN            INTEGER DEFAULT NULL
,p_entity_code         IN            VARCHAR2
,p_event_class_code    IN            VARCHAR2
,p_event_type_code     IN            VARCHAR2
,p_source_id_int_1     IN            INTEGER DEFAULT NULL
,p_source_id_int_2     IN            INTEGER DEFAULT NULL
,p_source_id_int_3     IN            INTEGER DEFAULT NULL
,p_source_id_int_4     IN            INTEGER DEFAULT NULL
,p_source_id_char_1    IN            VARCHAR2 DEFAULT NULL
,p_source_id_char_2    IN            VARCHAR2 DEFAULT NULL
,p_source_id_char_3    IN            VARCHAR2 DEFAULT NULL
,p_source_id_char_4    IN            VARCHAR2 DEFAULT NULL
,p_security_id_int_1   IN            INTEGER DEFAULT NULL
,p_security_id_int_2   IN            INTEGER DEFAULT NULL
,p_security_id_int_3   IN            INTEGER DEFAULT NULL
,p_security_id_char_1  IN            VARCHAR2 DEFAULT NULL
,p_security_id_char_2  IN            VARCHAR2 DEFAULT NULL
,p_security_id_char_3  IN            VARCHAR2 DEFAULT NULL
,p_valuation_method    IN            VARCHAR2 DEFAULT NULL
,p_user_interface_type IN OUT NOCOPY VARCHAR2
,p_function_name       IN OUT NOCOPY VARCHAR2
,p_parameters          IN OUT NOCOPY VARCHAR2)

IS

BEGIN

-- To check whether the application is AP
IF (p_application_id =200) THEN

 IF(p_event_class_code = 'INVOICES') THEN
    p_user_interface_type := 'FORM';
    p_function_name := 'XLA_APXINWKB';
    p_parameters := ' INVOICE_ID="' ||TO_CHAR(p_source_id_int_1) ||'"'
                  ||' ORG_ID="' ||TO_CHAR(p_security_id_int_1) ||'"';

  ELSIF (p_event_class_code = 'CREDIT MEMOS') THEN
    p_user_interface_type := 'FORM';
    p_function_name := 'XLA_APXINWKB';
    p_parameters := ' INVOICE_ID="' || TO_CHAR(p_source_id_int_1)||'"'
                  ||' ORG_ID="'||TO_CHAR(p_security_id_int_1)||'"';

  ELSIF (p_event_class_code = 'DEBIT MEMOS') THEN
    p_user_interface_type := 'FORM';
    p_function_name := 'XLA_APXINWKB';
    p_parameters := ' INVOICE_ID="' || TO_CHAR(p_source_id_int_1)||'"'
                  ||' ORG_ID="'||TO_CHAR(p_security_id_int_1)||'"';

  ELSIF (p_event_class_code = 'PREPAYMENTS') THEN
    p_user_interface_type := 'FORM';
    p_function_name := 'XLA_APXINWKB';
    p_parameters := ' INVOICE_ID="' || TO_CHAR(p_source_id_int_1)||'"'
                  ||' ORG_ID="'||TO_CHAR(p_security_id_int_1)||'"';

  ELSIF (p_event_class_code = 'PREPAYMENT APPLICATIONS') THEN
    p_user_interface_type := 'FORM';
    p_function_name := 'XLA_APXINWKB';
    --bug 7020850
    p_parameters :=' INVOICE_ID="' || TO_CHAR(p_source_id_int_1)||'"'
                 ||' ORG_ID="'||TO_CHAR(p_security_id_int_1)||'"';
   /* p_parameters :=' AP_PREPAY_HISTORY_ID="' || TO_CHAR(p_source_id_int_1)||'"'
                 ||' AP_PREPAY_INVOICE_ID="'||TO_CHAR(p_security_id_int_2)||'"'
                 ||' INVOICE_ID="'||TO_CHAR(p_security_id_int_3)||'"'
                 ||' ORG_ID="'||TO_CHAR(p_security_id_int_1)||'"';*/

  ELSIF (p_event_class_code = 'INV SUPPLIER MODIFICATIONS') THEN
    p_user_interface_type := 'FORM';
    p_function_name := 'XLA_APXINWKB';
    p_parameters := ' INVOICE_ID="' || TO_CHAR(p_source_id_int_1)||'"'
                  ||' ORG_ID="'||TO_CHAR(p_security_id_int_1)||'"';

  ELSIF (p_event_class_code = 'PAYMENTS') THEN
    p_user_interface_type := 'FORM';
    p_function_name := 'XLA_APXPAWKB';
    p_parameters := ' CHECK_ID="' || TO_CHAR(p_source_id_int_1)||'"'
                  ||' ORG_ID="'||TO_CHAR(p_security_id_int_1)||'"';

  ELSIF (p_event_class_code = 'REFUNDS') THEN
    p_user_interface_type := 'FORM';
    p_function_name := 'XLA_APXPAWKB';
    p_parameters := 'CHECK_ID="' || TO_CHAR(p_source_id_int_1)||'"'
                 ||' ORG_ID="'||TO_CHAR(p_security_id_int_1)||'"';

  ELSIF (p_event_class_code = 'FUTURE DATED PAYMENTS') THEN
    p_user_interface_type := 'FORM';
    p_function_name := 'XLA_APXPAWKB';
    p_parameters := ' CHECK_ID="' || TO_CHAR(p_source_id_int_1)||'"'
                  ||' ORG_ID="'||TO_CHAR(p_security_id_int_1)||'"';

  ELSIF (p_event_class_code = 'RECONCILED PAYMENTS') THEN
    p_user_interface_type := 'FORM';
    p_function_name := 'XLA_APXPAWKB';
    p_parameters := ' CHECK_ID="' || TO_CHAR(p_source_id_int_1)||'"'
                  ||' ORG_ID="'||TO_CHAR(p_security_id_int_1)||'"';

  ELSIF (p_event_class_code = 'TREASURY PAYMENT ACCOMPLISHMENT') THEN
    p_user_interface_type := 'FORM';
    p_function_name := 'XLA_FVXITCRF';
    p_parameters := ' CHECK_ID="' ||    TO_CHAR (p_source_id_int_1)||'"'
                    ||' ORG_ID="'||TO_CHAR(p_security_id_int_1)||'"';

  ELSIF (p_event_class_code = 'PMT SUPPLIER MODIFICATIONS') THEN
    p_user_interface_type := 'FORM';
    p_function_name := 'XLA_APXPAWKB';
    p_parameters := ' CHECK_ID="' || TO_CHAR(p_source_id_int_1)||'"'
                  ||' ORG_ID="'||TO_CHAR(p_security_id_int_1)||'"';

  ELSE
    p_user_interface_type :='NONE';
  END IF;
END IF;

END DRILLDOWN;

/*========================================================================
 | PROCEDURE:  INVOICE_ONLINE_ACCOUNTING
 | COMMENT:    Invoice_online_accounting procedure will call the SLA public
 |             API to process the oneline accounting for specific invoice
 | PARAMETERS: p_invoice_id IN --the invoice will be accounted
 |             p_accounting IN 'D' --Draft mode
 |                             'F' --Final mode
 |                             'P' --Final and post in general ledger
 |             p_errbuf     OUT -- Error message
 |             p_retcode    OUT -- The retcode OUT prameter returns the success
 |                                 code back to the caller. If the call is
 |                                 completed successfully, the return value is
 |                                 0(Zero)
 |
 +===========================================================================*/

PROCEDURE INVOICE_ONLINE_ACCOUNTING
(p_invoice_id          IN  NUMBER,
 p_accounting_mode     IN  VARCHAR2,
 p_errbuf              OUT NOCOPY VARCHAR2,
 p_retcode             OUT NOCOPY NUMBER,
 p_calling_sequence    IN  VARCHAR2)

IS

TYPE t_event_ids_type IS TABLE OF xla_events.event_id%TYPE
                         INDEX BY PLS_INTEGER;
TYPE t_event_status_type IS TABLE OF xla_events.event_status_code%TYPE
                            INDEX BY PLS_INTEGER;  --bug 8547225

l_org_id                  NUMBER(15);
l_legal_entity_id         NUMBER(15);
l_ledger_id               NUMBER(15);
l_event_source_info       XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO;
l_accounting_mode         VARCHAR2(1);
l_accounting_flag         VARCHAR2(1);
l_gl_posting_flag         VARCHAR2(1);
l_transfer_flag           VARCHAR2(1);
l_accounting_batch_id     NUMBER(15);
l_request_id              NUMBER(15);
l_curr_calling_sequence   VARCHAR2(2000);
l_log_msg                 FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

ind                       BINARY_INTEGER := 1;
l_event_list              t_event_ids_type;
l_event_status_list       t_event_status_type;  --bug 8547225
l_t_array_event_info      xla_events_pub_pkg.t_array_event_info;
l_procedure_name CONSTANT VARCHAR2(30) := 'invoice_online_accounting';

BEGIN

   l_curr_calling_sequence :=
    p_calling_sequence || ' -> AP_DRILLDOWN_PUB_PKG.INVOICE_ONLINE_ACCOUNTING';


   -----------------------------------------------------------------
     l_log_msg := 'Step 1: Get invoice information';
   -----------------------------------------------------------------

     get_invoice_info
    ( p_invoice_id => p_invoice_id,
      p_org_id => l_org_id, -- OUT
      p_legal_entity_id => l_legal_entity_id, -- OUT
      p_ledger_id => l_ledger_id, -- OUT
      p_calling_sequence => l_curr_calling_sequence
    );
   -----------------------------------------------------------------
    l_log_msg := 'Step 2: get invoice event source info';
   -----------------------------------------------------------------

    l_event_source_info :=
      get_invoice_event_source_info
      ( p_legal_entity_id => l_legal_entity_id,
        p_ledger_id => l_ledger_id,
        p_invoice_id => p_invoice_id,
        p_calling_sequence => l_curr_calling_sequence
     );

   -----------------------------------------------------------------
    l_log_msg := 'Step 3: Check accounting method';
   -----------------------------------------------------------------
   IF p_accounting_mode  = 'D' THEN
      l_accounting_mode := 'D';
      l_accounting_flag := 'Y';
      l_gl_posting_flag := 'N';
      l_transfer_flag   := 'N';
   ELSIF p_accounting_mode = 'F' THEN
      l_accounting_mode := 'F';
      l_accounting_flag := 'Y';
      l_gl_posting_flag := 'N';
      l_transfer_flag   := 'N';
   ELSIF p_accounting_mode = 'P' THEN
      l_accounting_mode := 'F';
      l_accounting_flag := 'Y';
      l_gl_posting_flag := 'Y';
      l_transfer_flag   := 'Y';
   ELSE
      APP_EXCEPTION.RAISE_EXCEPTION();
   END IF;

   -----------------------------------------------------------------
    l_log_msg := 'Step 4: call SLA API';
   -----------------------------------------------------------------
   XLA_ACCOUNTING_PUB_PKG.ACCOUNTING_PROGRAM_DOCUMENT (
        P_event_source_info   => l_event_source_info,
        P_entity_id           => null,
        P_accounting_flag     => l_accounting_flag,
        P_accounting_mode     => l_accounting_mode,
        P_transfer_flag       => l_transfer_flag,
        P_gl_posting_flag     => l_gl_posting_flag,
        P_offline_flag        => 'N',
        P_accounting_batch_id => l_accounting_batch_id, --Out
        P_errbuf              => p_errbuf,              --Out
        P_retcode             => p_retcode,             --Out
        P_request_id          => l_request_id           --Out
   );

   -----------------------------------------------------------------
    l_log_msg := 'Step 5: Update the posted flag';
   -----------------------------------------------------------------

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'After calling online accounting api and out prameter:' ||
                  ' p_retcode =' || p_retcode ||
                  ' accounting_mode =' || l_accounting_mode;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,l_log_msg);
   END IF;


   IF (l_accounting_mode <> 'D') THEN

     l_t_array_event_info := xla_events_pub_pkg.get_array_event_info
         (p_event_source_info => l_event_source_info
          ,p_event_class_code => NULL
          ,p_event_type_code  => NULL
          ,p_event_date       => NULL
          ,p_event_status_code=> NULL
          ,p_valuation_method => NULL
          ,p_security_context => NULL);

     IF ( l_t_array_event_info.COUNT <> 0 ) THEN

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Event processed count is not 0';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                        l_procedure_name,l_log_msg);
       END IF;

       FOR num IN 1 .. l_t_array_event_info.COUNT LOOP
         IF ( l_t_array_event_info(num).event_status_code <> 'P') THEN
           l_event_list(ind) :=  l_t_array_event_info(num).event_id;
           l_event_status_list(ind) := l_t_array_event_info(num).event_status_code; --bug 8547225
           ind := ind+1;
         END IF;
       END LOOP;
     END IF;

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Events need to set the posted flag to n count='
                      || to_char(ind) ;
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                        l_procedure_name,l_log_msg);
     END IF;

     --bug 8547225, for event_status_code 'N' posted_flag updated to'Y'
     IF (l_event_list.count <> 0 ) THEN
       FORALL num in 1 .. l_event_list.COUNT
       UPDATE AP_INVOICE_DISTRIBUTIONS
       SET    POSTED_FLAG = CASE WHEN p_retcode <> 0
                                 THEN 'N'
                                 WHEN p_retcode = 0 and l_event_status_list(num) = 'N'
                                 THEN 'Y'
                                 ELSE 'N'        --bug9464912
                                 END
       WHERE Accounting_Event_ID = l_event_list(num);

       FORALL num in 1 .. l_event_list.COUNT
       UPDATE ap_prepay_history_all
       SET    POSTED_FLAG = CASE WHEN p_retcode <> 0
                                 THEN 'N'
                                 WHEN p_retcode = 0 and l_event_status_list(num) = 'N'
                                 THEN 'Y'
                                 ELSE 'N'       --bug9464912
                                 END
       WHERE Accounting_Event_ID = l_event_list(num);

       l_event_list.DELETE;
       l_event_status_list.DELETE;
       l_t_array_event_info.DELETE;
     END IF;

   END IF;

  EXCEPTION
   WHEN OTHERS THEN
     IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
       FND_MESSAGE.SET_TOKEN('PARAMETERS',
                ' p_invoice_id =      '||p_invoice_id
              ||' p_accounting_mode = '||p_accounting_mode );
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_log_msg);
     END IF;
     APP_EXCEPTION.RAISE_EXCEPTION();

END INVOICE_ONLINE_ACCOUNTING;


/*===========================================================================+
 | PROCEDURE:  PAYMENT_ONLINE_ACCOUNTING
 | COMMENT:    Payment_online_accounting procedure will call the SLA public
 |             API to process the oneline accounting for specific invoice
 | PARAMETERS: p_check_id        IN     --the invoice will be accounted
 |             p_accounting_mode IN 'D' --Draft mode
 |                                  'F' --Final mode
 |                                  'P' --Final and post in general ledger
 |             p_errbuf          OUT    --Error message
 |             p_ret_code        OUT    --The retcode OUT prameter returns
 |                                        the success code back to the caller.
 |                                        If the call is completed successfully
 |                                        the return value is 0(Zero)
 |
 +===========================================================================*/

PROCEDURE PAYMENT_ONLINE_ACCOUNTING
(p_check_id          IN  NUMBER,
 p_accounting_mode   IN  VARCHAR2,
 p_errbuf            OUT NOCOPY VARCHAR2,
 p_retcode           OUT NOCOPY NUMBER,
 p_calling_sequence  IN  VARCHAR2)

IS

TYPE t_event_ids_type IS TABLE OF xla_events.event_id%TYPE
                         INDEX BY PLS_INTEGER;

TYPE t_event_status_type IS TABLE OF xla_events.event_status_code%TYPE
                         INDEX BY PLS_INTEGER;
l_event_status_list      t_event_status_type;

l_org_id                  NUMBER(15);
l_legal_entity_id         NUMBER(15);
l_ledger_id               NUMBER(15);
l_event_source_info       XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO;
l_accounting_mode         VARCHAR2(1);
l_accounting_flag         VARCHAR2(1);
l_gl_posting_flag         VARCHAR2(1);
l_transfer_flag           VARCHAR2(1);
l_accounting_batch_id     NUMBER(15);
l_request_id              NUMBER(15);
l_curr_calling_sequence   VARCHAR2(2000);
l_log_msg                 FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

ind                       BINARY_INTEGER := 1;
l_event_list              t_event_ids_type;
l_t_array_event_info      xla_events_pub_pkg.t_array_event_info;
l_procedure_name CONSTANT VARCHAR2(30) := 'payment_online_accounting';


BEGIN

  l_curr_calling_sequence := p_calling_sequence
                     || ' -> AP_DRILLDOWN_PUB_PKG.PAYMENT_ONLINE_ACCOUNTING';
   -----------------------------------------------------------------
    l_log_msg := 'Step 1: Get payment information';
   -----------------------------------------------------------------

     get_payment_info
    ( p_check_id => p_check_id,
      p_org_id => l_org_id, -- OUT
      p_legal_entity_id => l_legal_entity_id, -- OUT
      p_ledger_id => l_ledger_id, -- OUT
      p_calling_sequence => l_curr_calling_sequence
    );
   -----------------------------------------------------------------
    l_log_msg := 'Step 2: get payment event source info';
   -----------------------------------------------------------------

    l_event_source_info :=
      get_payment_event_source_info
      ( p_legal_entity_id => l_legal_entity_id,
        p_ledger_id => l_ledger_id,
        p_check_id => p_check_id,
        p_calling_sequence => l_curr_calling_sequence
     );

   -----------------------------------------------------------------
    l_log_msg := 'Step 3: Check accounting method';
   -----------------------------------------------------------------
   IF p_accounting_mode = 'D' THEN
      L_accounting_mode := 'D';
      L_accounting_flag := 'Y';
      L_gl_posting_flag := 'N';
      L_transfer_flag   := 'N';
   ELSIF p_accounting_mode = 'F' THEN
      L_accounting_mode := 'F';
      L_accounting_flag := 'Y';
      L_gl_posting_flag := 'N';
      L_transfer_flag   := 'N';
   ELSIF p_accounting_mode = 'P' THEN
      L_accounting_mode := 'F';
      L_accounting_flag := 'Y';
      L_gl_posting_flag := 'Y';
      L_transfer_flag   := 'Y';
   ELSE
      APP_EXCEPTION.RAISE_EXCEPTION();
   END IF;

   -----------------------------------------------------------------
    l_log_msg := 'Step 4: call SLA API';
   -----------------------------------------------------------------
   XLA_ACCOUNTING_PUB_PKG.ACCOUNTING_PROGRAM_DOCUMENT (
        P_event_source_info   => l_event_source_info,
        P_entity_id           => null,
        P_accounting_flag     => l_accounting_flag,
        P_accounting_mode     => l_accounting_mode,
        P_transfer_flag       => l_transfer_flag,
        P_gl_posting_flag     => l_gl_posting_flag,
        P_offline_flag        => 'N',
        P_accounting_batch_id => l_accounting_batch_id, --Out
        P_errbuf              => p_errbuf,              --Out
        P_retcode             => p_retcode,             --Out
        P_request_id          => l_request_id           --Out
   );

   -----------------------------------------------------------------
    l_log_msg := 'Step 5: Update the posted flag';
   -----------------------------------------------------------------

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'After calling online accounting api and out prameter:' ||
                  ' p_retcode =' || p_retcode ||
                  ' accounting_mode =' || l_accounting_mode;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,l_log_msg);
   END IF;

   -- rewrote the following for bug fix 5694577
   -- When payment accounting option is CLEAR ONLY, need to set the
   -- posted_flag to 'Y' for payment create and maturity event after online
   -- accounting

   l_t_array_event_info := xla_events_pub_pkg.get_array_event_info
       (p_event_source_info => l_event_source_info
        ,p_event_class_code => NULL
        ,p_event_type_code  => NULL
        ,p_event_date       => NULL
        ,p_event_status_code=> NULL
        ,p_valuation_method => NULL
        ,p_security_context => NULL);

   IF ( l_t_array_event_info.COUNT <> 0 ) THEN

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       l_log_msg := 'Event processed count is not 0';
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,l_log_msg);
     END IF;

     FOR num IN 1 .. l_t_array_event_info.COUNT LOOP
         l_event_list(ind) :=  l_t_array_event_info(num).event_id;
         l_event_status_list(ind) := l_t_array_event_info(num).event_status_code;
         ind := ind+1;
     END LOOP;

     FORALL num in 1 .. l_event_list.COUNT
     UPDATE AP_invoice_payments_all
     SET    POSTED_FLAG = CASE WHEN l_accounting_mode <> 'D'
                                 AND p_retcode <> 0
                                 AND l_event_status_list(num) <> 'P'
                               THEN 'N'
                               WHEN l_accounting_mode <> 'D'
                                 AND p_retcode = 0
                                 AND l_event_status_list(num) in ('U','N')--added N in Bug 7594938
                                 AND EXISTS(SELECT 1
                                              FROM ap_system_parameters asp, ap_payment_history_all aph
                                             WHERE asp.when_to_account_pmt = 'CLEARING ONLY'
                                               --AND asp.org_id = l_org_id
                                               AND asp.org_id = aph.org_id
                                               AND aph.accounting_event_id = l_event_list(num)
                                               AND aph.transaction_type in ('PAYMENT CREATED', 'PAYMENT MATURITY','REFUND RECORDED') --added REFUND RECORDED in Bug 7594938
                                            )
                               THEN 'Y'
                               WHEN l_accounting_mode <> 'D' -- Bug 9135877
                                 AND p_retcode = 0
                                 AND l_event_status_list(num) = 'N'
                               THEN 'Y'
                               ELSE POSTED_FLAG
                               END
     WHERE Accounting_Event_ID = l_event_list(num);

     FORALL num in 1 .. l_event_list.COUNT
     UPDATE AP_payment_history_all APH
     SET    APH.POSTED_FLAG = CASE WHEN l_accounting_mode <> 'D'
                                 AND p_retcode <> 0
                                 AND l_event_status_list(num) <> 'P'
                               THEN 'N'
                               WHEN l_accounting_mode <> 'D'
                                 AND p_retcode = 0
                                 AND l_event_status_list(num)  in ('U','N')--added N in Bug 7594938
                                 AND EXISTS(SELECT 1
                                              FROM ap_system_parameters asp
                                             WHERE asp.when_to_account_pmt = 'CLEARING ONLY'
                                               --AND asp.org_id = l_org_id
                                               AND asp.org_id = aph.org_id
                                               AND aph.accounting_event_id = l_event_list(num)
                                               AND aph.transaction_type in ('PAYMENT CREATED', 'PAYMENT MATURITY','REFUND RECORDED') --added REFUND RECORDED in Bug 7594938
                                            )
                               THEN 'Y'
                               WHEN l_accounting_mode <> 'D' -- Bug 7374984
                                 AND p_retcode = 0
                                 AND l_event_status_list(num) = 'N'
                               THEN 'Y'
                               ELSE POSTED_FLAG
                               END
     WHERE APH.Accounting_Event_ID = l_event_list(num);

     l_event_list.DELETE;
     l_event_status_list.DELETE;
     l_t_array_event_info.DELETE;

   END IF;

  EXCEPTION
   WHEN OTHERS THEN
     IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
       FND_MESSAGE.SET_TOKEN('PARAMETERS',
                ' p_check_id =        '||p_check_id
              ||' p_accounting_mode = '||p_accounting_mode );
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_log_msg);
     END IF;
     APP_EXCEPTION.RAISE_EXCEPTION();

END PAYMENT_ONLINE_ACCOUNTING;

/*============================================================================
 |  FUNCTION  -  GET_INVOICE_EVENT_SOURCE_INFO(PRIVATE)
 |
 |  DESCRIPTION
 |    This function is used to get invoice event source information
 |
 |  PRAMETERS:
 |         p_legal_entity_id: Legal entity ID
 |         p_ledger_id: Ledger ID
 |         p_invoice_id: Invoice ID
 |         p_calling_sequence: Debug information
 |
 |  RETURN: XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/
FUNCTION get_invoice_event_source_info(
                p_legal_entity_id  IN   NUMBER,
                p_ledger_id        IN   NUMBER,
                p_invoice_id       IN   NUMBER,
                p_calling_sequence IN   VARCHAR2)
RETURN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO
IS

  l_invoice_num VARCHAR2(50);
  l_event_source_info XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO;
  l_curr_calling_sequence   VARCHAR2(2000);
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  l_curr_calling_sequence := p_calling_sequence
      || ' -> AP_DRILLDOWN_PUB_PKG.get_invoice_event_source_info';

  ----------------------------------------------------------------
   l_log_msg :='get invoice_num information';
  ----------------------------------------------------------------

  select invoice_num
  into l_invoice_num
  from ap_invoices
  where invoice_id = p_invoice_id;

  ----------------------------------------------------------------
   l_log_msg :='get event source information';
  ----------------------------------------------------------------

  l_event_source_info.application_id := 200;
  l_event_source_info.legal_entity_id := p_legal_entity_id;
  l_event_source_info.ledger_id := p_ledger_id;
  l_event_source_info.entity_type_code := 'AP_INVOICES';
  l_event_source_info.transaction_number := l_invoice_num;
  l_event_source_info.source_id_int_1 := p_invoice_id;

  RETURN l_event_source_info;

  EXCEPTION
   WHEN OTHERS THEN
     IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
       FND_MESSAGE.SET_TOKEN('PARAMETERS',
                ' p_ledger_id =       '||p_ledger_id
              ||' p_legal_entity_id = '||p_legal_entity_id
              ||' p_invoice_id =      '||p_invoice_id );
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_log_msg);
     END IF;
     APP_EXCEPTION.RAISE_EXCEPTION();

END get_invoice_event_source_info;


/*============================================================================
 |  FUNCTION  -  GET_PAYMENT_EVENT_SOURCE_INFO(PRIVATE)
 |
 |  DESCRIPTION
 |    This procedure is used to get payment event source information.
 |
 |  PRAMETERS:
 |         p_legal_entity_id: Legal Entity ID
 |         p_ledger_id: Ledger ID
 |         p_invoice_id: Invoice ID
 |         p_calling_sequence: Debug information
 |
 |  RETURN: XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/
FUNCTION get_payment_event_source_info(
           p_legal_entity_id    IN   NUMBER,
           p_ledger_id          IN   NUMBER,
           p_check_id           IN   NUMBER,
           p_calling_sequence   IN   VARCHAR2)
RETURN XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO
IS

  l_check_number      NUMBER(15);
  l_event_source_info XLA_EVENTS_PUB_PKG.T_EVENT_SOURCE_INFO;
  l_curr_calling_sequence   VARCHAR2(2000);
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  l_curr_calling_sequence := p_calling_sequence
      || ' -> AP_DRILLDOWN_PUB_PKG.get_payment_event_source_info';

  ---------------------------------------------------------------
   l_log_msg :='get check_number';
  ---------------------------------------------------------------
  select check_number
  into l_check_number
  from ap_checks
  where check_id = p_check_id;

  ---------------------------------------------------------------
   l_log_msg :='get event source information';
  ---------------------------------------------------------------
  l_event_source_info.application_id := 200;
  l_event_source_info.legal_entity_id := p_legal_entity_id;
  l_event_source_info.ledger_id := p_ledger_id;
  l_event_source_info.entity_type_code := 'AP_PAYMENTS';
  l_event_source_info.transaction_number := l_check_number;
  l_event_source_info.source_id_int_1 := p_check_id;


  RETURN l_event_source_info;

  EXCEPTION
   WHEN OTHERS THEN
     IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
       FND_MESSAGE.SET_TOKEN('PARAMETERS',
                ' p_ledger_id =       '||p_ledger_id
              ||' p_legal_entity_id = '||p_legal_entity_id
              ||' p_check_id =        '||p_check_id );
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_log_msg);
     END IF;
     APP_EXCEPTION.RAISE_EXCEPTION();

END get_payment_event_source_info;


/*============================================================================
 |  PROCEDURE  -  GET_INVOICE_INFO(PRIVATE)
 |
 |  DESCRIPTION
 |    This procedure is used to get invoice information.
 |
 |  PRAMETERS:
 |         p_invoice_id: Invoice ID
 |         p_org_id: Organization ID
 |         p_legal_entity_id: Legal Entity ID
 |         p_ledger_id: Ledger ID
 |         p_calling_sequence: Debug information
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/
PROCEDURE get_invoice_info(
         p_invoice_id         IN         NUMBER,
         p_org_id             OUT NOCOPY NUMBER,
         p_legal_entity_id    OUT NOCOPY NUMBER,
         p_ledger_id          OUT NOCOPY NUMBER,
         p_calling_sequence   IN         VARCHAR2)
IS

  l_curr_calling_sequence VARCHAR2(2000);
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  l_curr_calling_sequence :=
    p_calling_sequence || ' -> AP_ACCOUNTING_EVENTS_PKG.GET_INVOICE_INFO';

  ----------------------------------------------------------------------
  l_log_msg :='get org information';
  ----------------------------------------------------------------------
  SELECT
    AI.org_id,
    AI.legal_entity_id,
    AI.set_of_books_id
  INTO
    p_org_id,
    p_legal_entity_id,
    p_ledger_id
  FROM
    ap_invoices AI
  WHERE
    AI.invoice_id = p_invoice_id;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
       FND_MESSAGE.SET_TOKEN('PARAMETERS',
                'p_org_id = '||p_org_id);
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_log_msg);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION();
END get_invoice_info;


/*============================================================================
 |  PROCEDURE  -  GET_PAYMENT_INFO(PRIVATE)
 |
 |  DESCRIPTION
 |    This procedure is used to get payment information.
 |
 |  PRAMETERS:
 |         p_check_id: Check ID
 |         p_org_id: Organization ID
 |         p_legal_entity_id: Legal entity ID
 |         p_ledger_id: Ledger ID
 |         p_calling_sequence: Debug information
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *===========================================================================*/
PROCEDURE get_payment_info(
            p_check_id         IN NUMBER,
            p_org_id           OUT NOCOPY NUMBER,
            p_legal_entity_id  OUT NOCOPY NUMBER,
            p_ledger_id        OUT NOCOPY NUMBER,
            p_calling_sequence IN VARCHAR2)
IS

  l_curr_calling_sequence VARCHAR2(2000);
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  l_curr_calling_sequence :=
    p_calling_sequence || ' -> AP_ACCOUNTING_EVENTS_PKG.GET_PAYMENT_INFO';

  --------------------------------------------------------------------
   l_log_msg :='get org information';
  --------------------------------------------------------------------
  SELECT AC.org_id,
         AC.legal_entity_id
  INTO   p_org_id,
         p_legal_entity_id
  FROM   ap_checks AC
  WHERE  AC.check_id = p_check_id;

  --------------------------------------------------------------------
   l_log_msg :='get ledger information';
  --------------------------------------------------------------------
  SELECT AIP.set_of_books_id
  INTO   p_ledger_id
  FROM   ap_invoice_payments AIP
  WHERE  AIP.check_id = p_check_id
  AND    ROWNUM = 1;


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
       FND_MESSAGE.SET_TOKEN('PARAMETERS',
                'p_check_id = '||p_check_id);
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_log_msg);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION();
END get_payment_info;

END AP_DRILLDOWN_PUB_PKG;


/
