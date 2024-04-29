--------------------------------------------------------
--  DDL for Package Body AP_FUNDS_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_FUNDS_CONTROL_PKG" AS
/* $Header: aprfundb.pls 120.44.12010000.12 2010/01/19 06:11:19 ssontine ship $ */

  -- Logging Infra
  G_CURRENT_RUNTIME_LEVEL       NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED   CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR        CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION    CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_UNEXPECTED   CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_EVENT        CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE    CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT    CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME        CONSTANT VARCHAR2(50) := 'AP.PLSQL.AP_FUNDS_CONTROL_PKG.';
  G_LEVEL_LOG_DISABLED CONSTANT NUMBER := 99;
  --1-STATEMENT, 2-PROCEDURE, 3-EVENT, 4-EXCEPTION, 5-ERROR, 6-UNEXPECTED

  g_log_level           NUMBER;
  g_log_enabled         BOOLEAN;

/*=============================================================================
 |Private (Non Public) Procedure Specifications
 *===========================================================================*/
--Bug 5487757. Added org_id as parameter
FUNCTION Encumbrance_Enabled(p_org_id IN NUMBER)  RETURN BOOLEAN;

PROCEDURE Setup_Gl_FundsCtrl_Params(
              p_bc_mode              IN OUT NOCOPY VARCHAR2,
              p_called_by            IN            VARCHAR2,
              p_calling_sequence     IN            VARCHAR2);

PROCEDURE FundsReserve_Init(
              p_invoice_id           IN NUMBER,
              p_system_user          IN NUMBER,
              p_override_mode        IN OUT NOCOPY VARCHAR2,
              p_fundschk_user_id     IN OUT NOCOPY NUMBER,
              p_fundschk_resp_id     IN OUT NOCOPY NUMBER,
              p_calling_sequence     IN            VARCHAR2);


PROCEDURE FundsCheck_Init(
              p_invoice_id           IN            NUMBER,
              p_set_of_books_id      IN OUT NOCOPY NUMBER,
              p_xrate_gain_ccid      IN OUT NOCOPY NUMBER,
              p_xrate_loss_ccid      IN OUT NOCOPY NUMBER,
              p_base_currency_code   IN OUT NOCOPY VARCHAR2,
              p_inv_enc_type_id      IN OUT NOCOPY NUMBER,
              p_gl_user_id           IN OUT NOCOPY NUMBER,
              p_calling_sequence     IN            VARCHAR2);

PROCEDURE Get_GL_FundsChk_Result_Code(
              p_fc_result_code      IN OUT NOCOPY VARCHAR2);


/*=============================================================================
 | Procedure Definitions
 *===========================================================================*/

/*============================================================================
 |  PRIVATE PROCEDURE  ENCUMBRANCE_ENABLED
 |
 |  DESCRIPTION
 |       It is a function that returns boolean. True if encumbrance is
 |       enabled, false otherwise
 |
 |  PARAMETERS
 |
 |  NOTE
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *==========================================================================*/



FUNCTION Encumbrance_Enabled (p_org_id IN NUMBER)
  RETURN BOOLEAN IS

  l_enc_enabled  VARCHAR2(1);

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Encumbrance_Enabled';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >=  g_log_level ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name||'.begin', l_log_msg);
  END IF;

  BEGIN
    SELECT nvl(purch_encumbrance_flag,'N')
      INTO l_enc_enabled
      FROM FINANCIALS_SYSTEM_PARAMS_ALL
      WHERE org_id = p_org_id;  -- Bug 5487757
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(FALSE);
  END;

  IF (l_enc_enabled = 'N') THEN
    RETURN(FALSE);
  ELSE
    RETURN(TRUE);
  END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >=  g_log_level  ) THEN
      l_log_msg := 'End of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Encumbrance_Enabled;

/*=============================================================================
 | Procedure Definitions
 *===========================================================================*/
  --procedure added for bug 8733916
/*==============================================================================
 |  PROCEDURE   ENCUM_UNPROCESSED_EVENTS_DEL
 |
 |  DESCRIPTION
 |      It is a procedure that checks all the unprocessed bc events for
 |      for an invoice and deletes the events from xla.
 |      Also we null out the bc event values in all tables corresponding to the
 |      invoice
 |  PARAMETERS
 |      p_invoice_id - Invoice_id
 |      p_line_number- Invoice line number which we are discarding
 |      p_calling_mode - to check if it called during CANCELING or DISCARDING
 |      p_calling_sequence -Debugging string to indicate path of module
 |
 |  NOTE
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *==========================================================================*/

 PROCEDURE Encum_Unprocessed_Events_Del(
                          p_invoice_id IN NUMBER,
                          p_calling_sequence IN VARCHAR2 DEFAULT NULL)
 IS
  l_curr_calling_sequence  VARCHAR2(2000);
  l_procedure_name         CONSTANT VARCHAR2(30) := 'Encum_Unprocessed_Events_Del';
  l_log_msg                FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  l_enc_enabled            VARCHAR2(1);
  l_org_id                 NUMBER;

 CURSOR c_get_unprocessed_events IS
   SELECT xla.event_id
   FROM xla_events xla,
        xla_transaction_entities xte
   WHERE NVL(xla.budgetary_control_flag, 'N') ='Y'
   AND   xla.application_id = 200
   AND   xla.event_status_code = 'U'
   AND   xla.process_status_code <> 'P'
   AND   xla.entity_id = xte.entity_id
   AND   xla.application_id = xte.application_id
   AND   xte.application_id = 200
   AND   xte.source_id_int_1=p_invoice_id
   AND   xte.entity_code='AP_INVOICES';

 BEGIN

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >=  g_log_level   ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
  END IF;

  l_curr_calling_sequence := 'AP_FUNDS_CONTROL_PKG.'||'<-'||p_calling_sequence;

  SELECT org_id
    INTO l_org_id
    FROM ap_invoices_all
  where invoice_id=p_invoice_id;

  SELECT nvl(purch_encumbrance_flag,'N')
    INTO l_enc_enabled
    FROM financials_system_params_all
   WHERE org_id = l_org_id;

  IF (l_enc_enabled='Y') THEN

    IF (G_LEVEL_PROCEDURE >=  g_log_level  ) THEN
      l_log_msg := 'Before deletion of unprocessed events';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name, l_log_msg);
    END IF;

     FOR rec_event IN c_get_unprocessed_events
     LOOP

       AP_ACCOUNTING_EVENTS_PKG.delete_invoice_event
                 (p_accounting_event_id => rec_event.event_id,
                          p_Invoice_Id => p_invoice_id,
                          p_calling_sequence => l_curr_calling_sequence);

       UPDATE ap_prepay_app_dists
            SET bc_event_id = NULL
        WHERE prepay_history_id in
                 (SELECT prepay_history_id
                  FROM ap_prepay_history_all
                 WHERE invoice_id = p_invoice_id)
          AND bc_event_id =rec_event.event_id;

       UPDATE ap_prepay_history_all
          SET bc_event_id = NULL
        WHERE invoice_id = p_invoice_id
          AND bc_event_id = rec_event.event_id;

        UPDATE ap_invoice_distributions
           SET bc_event_id=NULL
         WHERE invoice_id = p_invoice_id
           AND bc_event_id=rec_event.event_id
           AND nvl(encumbered_flag,'N') <> 'Y';

        UPDATE ap_self_assessed_tax_dist_all
           SET bc_event_id=NULL
         WHERE invoice_id = p_invoice_id
           AND bc_event_id=rec_event.event_id
           AND nvl(encumbered_flag,'N') <> 'Y';

     END LOOP;

        IF (G_LEVEL_PROCEDURE >=  g_log_level ) THEN
           l_log_msg := 'End of procedure '|| l_procedure_name;
           FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
        END IF;
   END IF;

 EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id ='|| p_invoice_id);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

 END Encum_Unprocessed_Events_Del;

 --End of bug 8733916



/*============================================================================
 |  PRIVATE PROCEDURE Setup_Gl_FundsCtrl_Params
 |
 |  DESCRIPTION
 |      Procedure that sets up parameters needed by gl_fundschecker, such as
 |      retrieving the packet_id, setting the appropriate mode and
 |      partial_reservation_flag depending on whether it is for fundschecking
 |      or approval's funds reservation.
 |
 |  PARAMETERS
 |      p_packet_id - Get one from sequence for Invoice level funds reserve
 |                    or funds check
 |      p_status_code - C for Fundscheck and P for Funds reserve
 |      p_bc_mode - GL Fundschecking mode to be populated by this procedure
 |               ('C' for funds check and 'R' for  funds reservation)
 |      p_partial_resv_flag - GL Fundschecking partial reservation flag
 |                            to be populated by this procedure.
 |                             ('Y' for fundschecking,
 |                              'N' for approval's funds reservation.)
 |      p_called_by - Which Program this api is called by
 |                    ( APPRVOAL' or 'FUNDSCHKER')
 |      p_calling_sequence - Debugging string to indicate path of module
 |                           calls to be printed out NOCOPY upon error.
 |
 |  NOTE
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *==========================================================================*/

PROCEDURE Setup_Gl_FundsCtrl_Params(
              p_bc_mode              IN OUT NOCOPY VARCHAR2,
              p_called_by            IN            VARCHAR2,
              p_calling_sequence     IN            VARCHAR2) IS

  l_curr_calling_sequence  VARCHAR2(2000);


  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Setup_Gl_FundsCtrl_Params';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >=  g_log_level   ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
  END IF;

   /*-----------------------------------------------------------------+
    |Init p_bc_mode and p_partial_resv_flag depends on calling program|
    +-----------------------------------------------------------------*/

  IF (p_called_by in ( 'APPROVE', 'CANCEL') ) THEN


    IF (G_LEVEL_PROCEDURE >=  g_log_level  ) THEN
      l_log_msg := 'Calling mode is ' || p_called_by  ;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
    END IF;

    p_bc_mode := 'P';                   -- reserve funds --

  ELSE

    IF (G_LEVEL_PROCEDURE >=  g_log_level  ) THEN
      l_log_msg := 'Called by Funds Check';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name||'.begin', l_log_msg);
    END IF;

    p_bc_mode := 'C';                   -- check funds --

  END IF;

  IF (G_LEVEL_PROCEDURE >=  g_log_level ) THEN
      l_log_msg := 'End of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Called_by  = '|| p_called_by
              ||', Mode = '|| p_bc_mode);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Setup_Gl_FundsCtrl_Params;

/*============================================================================
 |  PRIVATE PROCEDURE FundsReserve_Init
 |
 |  DESCRIPTION
 |      Procedure initialize the parameter values needed by funds reserve
 |
 |  PARAMETERS
 |      p_invoice_id - invoice id
 |      p_system_user - caller's user id
 |      p_override_mode - Out parameter
 |      p_fundschk_user_id  - out and set to the one who release the hold
 |      p_fundschk_resp_id  - out and set to the responsibilty who release
 |                            the hold
 |      p_calling_sequence - Debugging string to indicate path of module
 |                           calls to be printed out NOCOPY upon error.
 |  NOTE
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *==========================================================================*/

PROCEDURE FundsReserve_Init(
              p_invoice_id           IN NUMBER,
              p_system_user          IN NUMBER,
              p_override_mode        IN OUT NOCOPY VARCHAR2,
              p_fundschk_user_id     IN OUT NOCOPY NUMBER,
              p_fundschk_resp_id     IN OUT NOCOPY NUMBER,
              p_calling_sequence     IN            VARCHAR2) IS

  l_curr_calling_sequence   VARCHAR2(2000);
  l_hold_reason             VARCHAR2(240);
  l_hold_status             VARCHAR2(25);
  l_user_id                 NUMBER;
  l_resp_id                 NUMBER;

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'FundsReserve_Init';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  l_curr_calling_sequence := 'AP_FUNDS_CONTROL_PKG.'||
                             '<-'||p_calling_sequence;

   /*-----------------------------------------------------------------+
    |  Step 1 - Set the override mode for funds reserve               |
    |           Note - Bug 2184558 Indicates we always want the       |
    |           override mode to be set to 'Y'                        |
    +-----------------------------------------------------------------*/

    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >=  g_log_level ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
    END IF;

    p_override_mode := 'Y';

   /*-----------------------------------------------------------------+
    |  Step 2 - Get hold status and set the user and resp id          |
    |           Check if insufficient funds hold was user released    |
    +-----------------------------------------------------------------*/


    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >=  g_log_level   ) THEN
      l_log_msg := 'Check if insufficient funds hold was user released';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
    END IF;

    AP_APPROVAL_PKG.Get_Hold_Status(
        p_invoice_id,
        null,
        null,
        'INSUFFICIENT FUNDS',
        p_system_user,
        l_hold_status,
        l_hold_reason,
        l_user_id,
        l_resp_id,
        l_curr_calling_sequence);

   /*-----------------------------------------------------------------+
    |  Step 3 - fundschecking to Forced Mode if hold is released by   |
    |           user                                                  |
    +-----------------------------------------------------------------*/

    IF (l_hold_status = 'RELEASED BY USER') THEN


      -- Logging Infra: Procedure level
      IF (G_LEVEL_PROCEDURE >=  g_log_level  ) THEN
        l_log_msg := 'Hold was released by user.';
        FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME|| l_procedure_name, l_log_msg);
      END IF;

      IF (l_resp_id IS NOT NULL) THEN

        p_fundschk_user_id := l_user_id;
        p_fundschk_resp_id := l_resp_id;

      END IF; -- end of check l_resp_id

    END IF; -- l_hold_status = 'RELEASED BY USER' --

    IF (G_LEVEL_PROCEDURE >=  g_log_level  ) THEN
      l_log_msg := 'End of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', system_user = '|| to_char(p_system_user) );
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END FundsReserve_Init;


/*============================================================================
 |  PRIVATE PROCEDURE FUNDSCHECK_INIT
 |
 |  DESCRIPTION
 |      Procedure to retrieve system parameters to be used in fundschecker
 |
 |  PARAMETERS
 |      p_chart_of_accounts_id - Variable for the procedure to populate with
 |                               the chart of accounts id
 |      p_set_of_books_id - Variable for the procedure to populate with the
 |                          set of books id
 |      p_xrate_gain_ccid - Variable for the procedure to populate with the
 |                          exchange rate variance gain ccid
 |      p_xrate_loss_ccid - Variable for the procedure to populate with the
 |                           exchange rate variance loss ccid
 |      p_base_currency_code - Variable for the procedure to populate with the
 |                             base currency code
 |      p_inv_enc_type_id - Variable for the procedure to populate with the
 |                          invoice encumbrance type id
 |      p_gl_user_id - Variable for the procedure to populate with the
 |                     profile option user_id to be used for the
 |                     gl_fundschecker
 |      p_calling_sequence - Debugging string to indicate path of module calls
 |                          to be printed out NOCOPY upon error.
 |
 |  NOTE
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *==========================================================================*/
PROCEDURE FundsCheck_Init(
              p_invoice_id            IN            NUMBER,
              p_set_of_books_id       IN OUT NOCOPY NUMBER,
              p_xrate_gain_ccid       IN OUT NOCOPY NUMBER,
              p_xrate_loss_ccid       IN OUT NOCOPY NUMBER,
              p_base_currency_code    IN OUT NOCOPY VARCHAR2,
              p_inv_enc_type_id       IN OUT NOCOPY NUMBER,
              p_gl_user_id            IN OUT NOCOPY NUMBER,
              p_calling_sequence      IN            VARCHAR2) IS

  l_curr_calling_sequence   VARCHAR2(2000);
  l_procedure_name CONSTANT VARCHAR2(30) := 'Fundscheck_Init';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  -- Update the calling sequence --

  l_curr_calling_sequence := 'AP_FUNDS_CONTROL_PKG.'||l_procedure_name||
                             '<-'||p_calling_sequence;

    /*----------------------------------------------------------------+
    |  Retrieving system parameters for fundschecker                  |
    +-----------------------------------------------------------------*/

  IF (G_LEVEL_PROCEDURE >=  g_log_level ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
  END IF;

  BEGIN

    SELECT sp.set_of_books_id,
           nvl(sp.rate_var_gain_ccid, -1),
           nvl(sp.rate_var_loss_ccid, -1),
           nvl(sp.base_currency_code, 'USD'),
           nvl(fp.inv_encumbrance_type_id, -1)
      INTO p_set_of_books_id,
           p_xrate_gain_ccid,
           p_xrate_loss_ccid,
           p_base_currency_code,
           p_inv_enc_type_id
      FROM ap_system_parameters sp,
           financials_system_parameters fp,
           gl_sets_of_books gls,
           ap_invoices ai
    WHERE  sp.set_of_books_id = gls.set_of_books_id
      AND  sp.set_of_books_id = ai.set_of_books_id
      AND  ai.invoice_id = p_invoice_id;

  EXCEPTION WHEN NO_DATA_FOUND THEN
    NULL;
  END;

    /*-----------------------------------------------------------------+
    |  Retrieving profile optpon user id                              |
    +-----------------------------------------------------------------*/

  FND_PROFILE.GET('USER_ID', p_gl_user_id);

  IF (G_LEVEL_PROCEDURE >=  g_log_level ) THEN
      l_log_msg := 'End of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_log_msg);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END FundsCheck_Init;

/*============================================================================
 |  PRIVATE PROCEDURE  GET_GL_FUNDSCHK_RESULT_CODE
 |
 |  DESCRIPTION
 |      Procedure to retrieve the GL_Fundschecker result code after the
 |      GL_Fundschecker has been run.
 |
 |  PARAMETERS
 |      p_fc_result_code :  Variable to contain the gl funds checker result
 |                          code
 |
 |  NOTE
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *==========================================================================*/

PROCEDURE Get_GL_FundsChk_Result_Code(
              p_fc_result_code  IN OUT NOCOPY VARCHAR2) IS

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Get_GL_FundsChk_Result_Code';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  ---------------------------------------------------------------
  -- Retrieve GL Fundschecker Failure Result Code              --
  ---------------------------------------------------------------

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >=  g_log_level  ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
  END IF;

  BEGIN
    SELECT l.lookup_code
    INTO   p_fc_result_code
    FROM   gl_lookups l
    WHERE  lookup_type = 'FUNDS_CHECK_RESULT_CODE'
    AND EXISTS ( SELECT 'x'
                 FROM   gl_bc_packets bc,
                        xla_events_gt e
                 WHERE  bc.event_id = e.event_id
                 AND    result_code like 'F%'
                 AND    bc.result_code = l.lookup_code)
    AND rownum = 1;
  EXCEPTION
    WHEN OTHERS THEN
    NULL;
  END;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >=  g_log_level ) THEN
      l_log_msg := 'End of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Get_GL_FundsChk_Result_Code;

/*=============================================================================
 |Public Procedure Definition
 *===========================================================================*/

/*============================================================================
 |  PUBLIC PROCEDURE  FUNDS_RESERVE
 |
 |  DESCRIPTION
 |       Procedure to performs funds reservations.
 |
 |  PARAMETERS
 |       p_invoice_id - Invoice Id
 |       p_unique_packet_id_per - ('INVOICE' or 'DISTRIBUTION')
 |       p_set_of_books_id - Set of books Id
 |       p_base_currency_code - Base Currency Code
 |       p_conc_flag ('Y' or 'N') - indicating if procedure is to be called as
 |                                  a concurrent program or userexit.
 |       p_system_user - Approval Program User Id
 |       p_holds - Holds Array
 |       p_hold_count - Holds Count Array
 |       p_release_count - Release Count Array
 |       p_calling_sequence - Debugging string to indicate path of module calls
 |                           to be printed out NOCOPY upon error.
 |  NOTE
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  15-OCT-2009 GAGRAWAL            bug9026201, instead of raising an API EXCEPTION
 |                                  in case of PSA api returning a failure or
 |                                  giving an Exception, we would be putting the
 |                                  invoice on a hold.
 *==========================================================================*/

PROCEDURE Funds_Reserve(
              p_calling_mode          IN            VARCHAR2 DEFAULT 'APPROVE',
              p_invoice_id            IN            NUMBER,
              p_set_of_books_id       IN            NUMBER,
              p_base_currency_code    IN            VARCHAR2,
              p_conc_flag             IN            VARCHAR2,
              p_system_user           IN            NUMBER,
              p_holds                 IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
              p_hold_count            IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_release_count         IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_funds_return_code     OUT NOCOPY    VARCHAR2, -- 4276409 (3462325)
              p_calling_sequence      IN            VARCHAR2) IS


  CURSOR cur_fc_dist IS --bc FundsReserve_Inv_Dist_Cur IS
   SELECT I.invoice_id,                      -- invoice_id
          I.invoice_num,                     -- invoice_num
          I.legal_entity_id,                 -- BCPSA bug
          I.invoice_type_lookup_code,        -- invoice_type_code
          D.invoice_line_number,             -- inv_line_num
          D.invoice_distribution_id ,        -- inv_distribution_id
          D.accounting_date,                 -- accounting_date
          D.LINE_TYPE_LOOKUP_CODE,           -- distribution_type
          D.amount,                          -- distribution_amount
          D.set_of_books_id,                 -- set_of_books_id
          D.bc_event_id,                     -- bc_event_id
          D.org_id,                          -- org_id
          NULL,                              --result_code
          NULL,                               --status_code
          'N' self_assessed_flag             --self_assessed_flag --bug7109594
  FROM   gl_period_statuses PER,
         ap_invoices I,
         ap_invoice_distributions_all D,
         ap_invoice_lines L
  WHERE  D.invoice_id = I.invoice_id
  AND    D.invoice_line_number = L.line_number
  AND    L.invoice_id = D.invoice_id
  AND    D.posted_flag in ('N', 'P')
  AND    nvl(D.encumbered_flag, 'N') in ('N', 'H', 'P')
  AND    L.line_type_lookup_code NOT IN ('AWT')
  AND    D.period_name = PER.period_name
  AND    PER.set_of_books_id = p_set_of_books_id
  AND    PER.application_id = 200
  AND    NVL(PER.adjustment_period_flag, 'N') = 'N'
  AND    I.invoice_id = p_invoice_id
  AND    D.po_distribution_id is NULL
  AND    (( D.match_status_flag = 'S')
            AND  (NOT EXISTS (SELECT 'X'
                            FROM   ap_holds H,
                                   ap_hold_codes C
                            WHERE  H.invoice_id = D.invoice_id
                            AND    H.line_location_id is null
                            AND    H.hold_lookup_code = C.hold_lookup_code
                            AND   ((H.release_lookup_code IS NULL)
                                    AND ((C.postable_flag = 'N') OR
                                        (C.postable_flag = 'X')))
                            AND H.hold_lookup_code <> 'CANT FUNDS CHECK'
                            AND H.hold_lookup_code <> 'INSUFFICIENT FUNDS'
							AND H.hold_lookup_code <> 'Encumbrance Acctg Fail'))) --Bug 9136390
UNION ALL
   SELECT I.invoice_id,                      -- invoice_id
          I.invoice_num,                     -- invoice_num
          I.legal_entity_id,                 -- BCPSA bug
          I.invoice_type_lookup_code,        -- invoice_type_code
          D.invoice_line_number,             -- inv_line_num
          D.invoice_distribution_id ,        -- inv_distribution_id
          D.accounting_date,                 -- accounting_date
          D.LINE_TYPE_LOOKUP_CODE,           -- distribution_type
          D.amount,                          -- distribution_amount
          D.set_of_books_id,                 -- set_of_books_id
          D.bc_event_id,                     -- bc_event_id
          D.org_id,                          -- org_id
          NULL,                              --result_code
          NULL,                              --status_code
          'N' self_assessed_flag             --self_assessed_flag --bug7109594
  FROM   gl_period_statuses PER,
         ap_invoices I,
         ap_invoice_distributions_all D,
         ap_invoice_lines L,
         po_distributions_all pod
  WHERE  D.invoice_id = I.invoice_id
  AND    D.invoice_line_number = L.line_number
  AND    L.invoice_id = D.invoice_id
  AND    ( (D.line_type_lookup_code = 'ITEM' AND
            NVL(pod.accrue_on_receipt_flag,'N') <> 'Y')
           OR
           (D.line_type_lookup_code NOT IN
            ( 'RETAINAGE', 'ACCRUAL', 'ITEM' )) )
  AND    D.posted_flag in ('N', 'P')
  AND    nvl(D.encumbered_flag, 'N') in ('N', 'H', 'P')
  AND    L.line_type_lookup_code NOT IN ('AWT')
  AND    D.period_name = PER.period_name
  AND    PER.set_of_books_id = p_set_of_books_id
  AND    PER.application_id = 200
  AND    NVL(PER.adjustment_period_flag, 'N') = 'N'
  AND    I.invoice_id = p_invoice_id
  AND    (( D.match_status_flag = 'S')
            AND  (NOT EXISTS (SELECT 'X'
                            FROM   ap_holds H,
                                   ap_hold_codes C
                            WHERE  H.invoice_id = D.invoice_id
                            AND    H.line_location_id is null
                            AND    H.hold_lookup_code = C.hold_lookup_code
                            AND   ((H.release_lookup_code IS NULL)
                                    AND ((C.postable_flag = 'N') OR
                                        (C.postable_flag = 'X')))
                            AND H.hold_lookup_code <> 'CANT FUNDS CHECK'
                            AND H.hold_lookup_code <> 'INSUFFICIENT FUNDS'
							AND H.hold_lookup_code <> 'Encumbrance Acctg Fail'))) --Bug 9136390
  AND   D.po_distribution_id IS NOT NULL
  AND   D.po_distribution_id = pod.po_distribution_id
  AND NOT EXISTS ( select 'Advance Exists'
                     from  po_distributions_all         pod,
                           po_headers_all               poh,
                           ap_invoice_distributions_all ainvd,
                           ap_invoices_all              ainv,
                           po_doc_style_headers         pdsa
                     where pod.po_distribution_id   = D.po_distribution_id
                       and poh.po_header_id         = pod.po_header_id
                       and poh.style_id             = pdsa.style_id
                       and ainv.invoice_id          = D.invoice_id
                       and ainv.invoice_id          = ainvd.invoice_id
                       and ainvd.po_distribution_id = pod.po_distribution_id
                       and nvl(pdsa.advances_flag, 'N') = 'Y'
                       and (ainvd.line_type_lookup_code = 'PREPAY'
                            OR
                            ainv.invoice_type_lookup_code = 'PREPAYMENT') )
UNION ALL
   SELECT I.invoice_id,                      -- invoice_id
          I.invoice_num,                     -- invoice_num
          I.legal_entity_id,                 -- BCPSA bug
          I.invoice_type_lookup_code,        -- invoice_type_code
          T.invoice_line_number,             -- inv_line_num
          T.invoice_distribution_id ,        -- inv_distribution_id
          T.accounting_date,                 -- accounting_date
          T.LINE_TYPE_LOOKUP_CODE,           -- distribution_type
          T.amount,                          -- distribution_amount
          T.set_of_books_id,                 -- set_of_books_id
          T.bc_event_id,                     -- bc_event_id
          T.org_id,                          -- org_id
          NULL,                              --result_code
          NULL,                               --status_code
          T.self_assessed_flag               --self_assessed_flag --bug7109594
  FROM   gl_period_statuses PER,
         ap_invoices I,
         ap_self_assessed_tax_dist_all T
  WHERE  T.invoice_id = I.invoice_id
  AND    T.posted_flag in ('N', 'P')
  AND    nvl(T.encumbered_flag, 'N') in ('N', 'H', 'P')
  AND    T.period_name = PER.period_name
  AND    PER.set_of_books_id = p_set_of_books_id
  AND    PER.application_id = 200
  AND    NVL(PER.adjustment_period_flag, 'N') = 'N'
  AND    I.invoice_id = p_invoice_id
  AND    T.po_distribution_id is NULL
  AND    (( T.match_status_flag = 'S')
            AND  (NOT EXISTS (SELECT 'X'
                            FROM   ap_holds H,
                                   ap_hold_codes C
                            WHERE  H.invoice_id = T.invoice_id
                            AND    H.line_location_id is null
                            AND    H.hold_lookup_code = C.hold_lookup_code
                            AND   ((H.release_lookup_code IS NULL)
                                    AND ((C.postable_flag = 'N') OR
                                        (C.postable_flag = 'X')))
                            AND H.hold_lookup_code <> 'CANT FUNDS CHECK'
                            AND H.hold_lookup_code <> 'INSUFFICIENT FUNDS'
							AND H.hold_lookup_code <> 'Encumbrance Acctg Fail'))) --Bug 9136390
UNION ALL
   SELECT I.invoice_id,                      -- invoice_id
          I.invoice_num,                     -- invoice_num
          I.legal_entity_id,                 -- BCPSA bug
          I.invoice_type_lookup_code,        -- invoice_type_code
          T.invoice_line_number,             -- inv_line_num
          T.invoice_distribution_id ,        -- inv_distribution_id
          T.accounting_date,                 -- accounting_date
          T.LINE_TYPE_LOOKUP_CODE,           -- distribution_type
          T.amount,                          -- distribution_amount
          T.set_of_books_id,                 -- set_of_books_id
          T.bc_event_id,                     -- bc_event_id
          T.org_id,                          -- org_id
          NULL,                              --result_code
          NULL,                               --status_code
          T.self_assessed_flag               --self_assessed_flag --bug7109594
  FROM   gl_period_statuses PER,
         ap_invoices I,
         ap_self_assessed_tax_dist_all T
  WHERE  T.invoice_id = I.invoice_id
  AND    T.posted_flag in ('N', 'P')
  AND    nvl(T.encumbered_flag, 'N') in ('N', 'H', 'P')
  AND    T.period_name = PER.period_name
  AND    PER.set_of_books_id = p_set_of_books_id
  AND    PER.application_id = 200
  AND    NVL(PER.adjustment_period_flag, 'N') = 'N'
  AND    I.invoice_id = p_invoice_id
  AND    (( T.match_status_flag = 'S')
            AND  (NOT EXISTS (SELECT 'X'
                            FROM   ap_holds H,
                                   ap_hold_codes C
                            WHERE  H.invoice_id = T.invoice_id
                            AND    H.line_location_id is null
                            AND    H.hold_lookup_code = C.hold_lookup_code
                            AND   ((H.release_lookup_code IS NULL)
                                    AND ((C.postable_flag = 'N') OR
                                        (C.postable_flag = 'X')))
                            AND H.hold_lookup_code <> 'CANT FUNDS CHECK'
                            AND H.hold_lookup_code <> 'INSUFFICIENT FUNDS'
							AND H.hold_lookup_code <> 'Encumbrance Acctg Fail'))) --Bug 9136390
  AND    T.po_distribution_id is NOT NULL
  AND NOT EXISTS ( select 'Advance Exists'
                     from  po_distributions_all         pod,
                           po_headers_all               poh,
                           ap_invoice_distributions_all ainvd,
                           ap_invoices_all              ainv,
                           po_doc_style_headers         pdsa
                    where  pod.po_distribution_id   = T.po_distribution_id
                      and  poh.po_header_id         = pod.po_header_id
                      and  poh.style_id             = pdsa.style_id
                      and  ainv.invoice_id          = T.invoice_id
                      and  ainv.invoice_id          = ainvd.invoice_id
                      and  ainvd.po_distribution_id = pod.po_distribution_id
                      and  nvl(pdsa.advances_flag, 'N') = 'Y'
                      and  (ainvd.line_type_lookup_code = 'PREPAY'
                            OR
                            ainv.invoice_type_lookup_code = 'PREPAYMENT') );

  l_debug_loc               VARCHAR2(2000) := 'Funds_Reserve';
  l_curr_calling_sequence   VARCHAR2(2000);
  l_debug_info              VARCHAR2(2000);

  l_partial_reserv_flag     VARCHAR2(1);
  l_insuff_funds_exists     VARCHAR2(1);
  l_cant_fundsck_exists     VARCHAR2(1);
  l_enc_acctg_fail_exists   VARCHAR2(1); --Bug 9136390
  l_fundschk_user_id        NUMBER(15);
  l_fundschk_resp_id        NUMBER(15);
  l_user_id                 NUMBER;
  l_resp_id                 NUMBER;
  l_bc_mode                 VARCHAR2(1) := 'R';
  l_status_code             VARCHAR2(1);
  l_override_mode           VARCHAR2(1) := 'N';
  l_return_code             VARCHAR2(30);

  t_funds_dist_tab         PSA_AP_BC_PVT.Funds_Dist_Tab_Type;

  l_dist_rec_count          NUMBER := 0;
  i                         BINARY_INTEGER := 1;
  j                         BINARY_INTEGER := 1;
  ind                       BINARY_INTEGER := 1;
  num                                   BINARY_INTEGER := 1;

  l_return_status               VARCHAR2(30);
  l_msg_count                   NUMBER;
  l_cfc_hold_cnt                NUMBER; --Bug 9168747
  l_msg_data                    VARCHAR2(2000);
  l_result_code                 VARCHAR2(30);
  l_packet_id                   NUMBER; --Bug 4535804
  l_bc_event_id                 XLA_EVENTS.EVENT_ID%TYPE;
  l_bc_event_status             XLA_EVENTS.EVENT_STATUS_CODE%TYPE;
  l_count_unproc                NUMBER;

  l_org_id                      NUMBER; --Bug 5487757

  PSA_API_EXCEPTION         EXCEPTION;

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Funds_Reserve';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;


BEGIN
  l_curr_calling_sequence := 'AP_FUNDS_CONTROL_PKG.'||l_debug_loc||
                             '<-'||p_calling_sequence;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >=  g_log_level ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
  END IF;
  l_debug_info := 'Initialize other variables';

  l_insuff_funds_exists := 'N';
  l_cant_fundsck_exists := 'N';
  l_enc_acctg_fail_exists := 'N'; --Bug 9136390
  l_fundschk_user_id := NULL;
  l_fundschk_resp_id := NULL;

  --Bug 5487757
  IF (G_LEVEL_PROCEDURE >=  g_log_level ) THEN
      l_log_msg := 'Selecting Org_Id for determining Encumbrance Enabled or not' ;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
  END IF;

  SELECT org_id
  INTO   l_org_id
  FROM   AP_INVOICES_ALL
  WHERE  invoice_id = p_invoice_id;

  IF (Encumbrance_Enabled(l_org_id)) THEN

    ------------------------------------------------------------
    -- Encumbrance enabled, setup gl_fundschecker parameters  --
    ------------------------------------------------------------

    IF (G_LEVEL_PROCEDURE >=  g_log_level ) THEN
      l_log_msg := 'FUNDSRESERVE - Encumbrance enabled and ' ||
                      'setup gl_fundschecker parameters ';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
    END IF;

   /*-----------------------------------------------------------------+
    |  Step 1 - Set Funds Control Parameters                          |
    +-----------------------------------------------------------------*/

    Setup_Gl_FundsCtrl_Params(
        l_bc_mode,
        p_calling_mode,
        l_curr_calling_sequence);

   /*-----------------------------------------------------------------+
    |  Step 2 - Get override mode and re-set the userid and           |
    |           responsibility id to who ever release the invoice     |
    |           hold                                                  |
    +-----------------------------------------------------------------*/


    IF (G_LEVEL_PROCEDURE >=  g_log_level ) THEN
      l_log_msg := ' call api to get override mode ' ||
                      'ID informaiton';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
    END IF;

    FundsReserve_Init(
        p_invoice_id         => p_invoice_id,
        p_system_user        => p_system_user,
        p_override_mode      => l_override_mode,
        p_fundschk_user_id   => l_fundschk_user_id,
        p_fundschk_resp_id   => l_fundschk_resp_id,
        p_calling_sequence   => l_curr_calling_sequence );

   /*-----------------------------------------------------------------+
    |  Step 2.5 - Update the encumbered_flag for recoverable tax      |
    |           distributions to R so that these are not sent to PSA  |
    |           for encumbering                                       |
    +-----------------------------------------------------------------*/


    IF (G_LEVEL_PROCEDURE >=  g_log_level ) THEN
      l_log_msg := ' Update encumbered flag of recoverable ' ||
                   'tax distributions to R';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
    END IF;

        Update ap_invoice_distributions_all
           set encumbered_flag = 'R'
         where invoice_id = p_invoice_id
           and line_type_lookup_code = 'REC_TAX';


   /*-----------------------------------------------------------------+
    |  Step 3 - Get all the selected distributions for processing     |
    +-----------------------------------------------------------------*/

    IF (G_LEVEL_STATEMENT >=  g_log_level ) THEN
      l_log_msg := 'Step 3 - Open FundsCntrl_Inv_Dist_Cur Cursor';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                     l_procedure_name, l_log_msg);
    END IF;

    OPEN cur_fc_dist;
    FETCH cur_fc_dist BULK COLLECT INTO t_funds_dist_tab;
    CLOSE cur_fc_dist;



   /*-----------------------------------------------------------------+
    |  Step 4 - Accounting Event Handling - Create, Stamp, Cleanup    |
    +-----------------------------------------------------------------*/

    IF (G_LEVEL_STATEMENT >=  g_log_level ) THEN
      l_log_msg := 'Step 3 - Call psa_ap_bc_pvt.Create_Events';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                     l_procedure_name, l_log_msg);
    END IF;

    IF ( t_funds_dist_tab.COUNT <> 0 ) THEN


      --
      -- Bug 5376406
      -- Modified the code as discussed with Anne/Jayanta
      -- The code used to be called after the create events
      -- which had the problems dscribed in bug 5374571.
      -- Bug 5455072
      -- Commented p_calling_mode check. Reinstate API
      -- should be called irrespective of the mode. API
      -- should do the necessary checks to reinstate PO
      -- encumbrance.
      --IF ( P_calling_mode = 'CANCEL') THEN

      -- bug 9026201
      BEGIN
        psa_ap_bc_pvt.Reinstate_PO_Encumbrance(
                p_calling_mode     => p_calling_mode,
                p_tab_fc_dist      => t_funds_dist_tab,
                p_calling_sequence => l_curr_calling_sequence,
                x_return_status    => l_return_status,
                x_msg_count        => l_msg_count,
                x_msg_data         => l_msg_data);

        IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
          l_log_msg := 'Call psa_ap_bc_pvt.reinstate_po_encumbrance returned' ||
                         'l_return_status =' || l_return_status;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                           l_procedure_name, l_log_msg);
        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          l_cant_fundsck_exists := 'Y';
          RAISE PSA_API_EXCEPTION;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
            l_log_msg := 'Call psa_ap_bc_pvt.reinstate_po_encumbrance '||
                         'raised an Exception' ||SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                           l_procedure_name, l_log_msg);
          END IF;

          l_cant_fundsck_exists := 'Y';
          RAISE PSA_API_EXCEPTION;

      END;

      -- bug9026201
      BEGIN
        psa_ap_bc_pvt.Create_Events (
                p_init_msg_list    => fnd_api.g_true,
                p_tab_fc_dist      => t_funds_dist_tab,
                p_calling_mode     => p_calling_mode,
                p_bc_mode          => l_bc_mode,
                p_calling_sequence => l_curr_calling_sequence,
                x_return_status    => l_return_status,
                x_msg_count        => l_msg_count,
                x_msg_data         => l_msg_data);

          IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
            l_log_msg := 'Call psa_ap_bc_pvt.Create_Events returned' ||
                           'l_return_status =' || l_return_status;
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                             l_procedure_name, l_log_msg);
          END IF;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           l_cant_fundsck_exists := 'Y';
           RAISE PSA_API_EXCEPTION;
         END IF;

      EXCEPTION
        WHEN OTHERS THEN
          IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
            l_log_msg := 'Call psa_ap_bc_pvt.Create_Events '||
                         'raised an Exception' ||SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                           l_procedure_name, l_log_msg);
          END IF;

          l_cant_fundsck_exists := 'Y';
          RAISE PSA_API_EXCEPTION;

      END;


   /*-----------------------------------------------------------------+
    |  Step 5 - Call PSA BUDGETARY CONTROL API                        |
    +-----------------------------------------------------------------*/

      IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
        l_log_msg := 'Step 4 - Call PSA_BC_XLA_PUB.Budgetary_Control';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                       l_procedure_name, l_log_msg);
      END IF;

      -- bug9026201
      BEGIN
        PSA_BC_XLA_PUB.Budgetary_Control(
                p_api_version            => 1.0,
                p_init_msg_list          => Fnd_Api.G_False,
                x_return_status          => l_return_status,
                x_msg_count              => l_msg_count,
                x_msg_data               => l_msg_data,
                p_application_id         => 200,
                p_bc_mode                => l_bc_mode,
                p_override_flag          => l_override_mode,
                P_user_id                => l_fundschk_user_id,
                P_user_resp_id           => l_fundschk_resp_id,
                x_status_code            => l_return_code,
                x_Packet_ID              => l_packet_id );

          IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
            l_log_msg := 'Call psa_ap_bc_pvt.Budgetary_Control returned' ||
                           'l_return_status =' || l_return_status ||
                           'l_packet_id =' || to_char(l_packet_id);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                             l_procedure_name, l_log_msg);
          END IF;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           l_cant_fundsck_exists := 'Y';
           RAISE PSA_API_EXCEPTION;
         END IF;

      EXCEPTION
        WHEN OTHERS THEN
          IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
            l_log_msg := 'Call psa_ap_bc_pvt.Budgetary_Control '||
                         'raised an Exception' ||SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                           l_procedure_name, l_log_msg);
          END IF;

          l_cant_fundsck_exists := 'Y';
          RAISE PSA_API_EXCEPTION;

      END;


      IF (l_return_code in ('FATAL', 'FAIL', 'PARTIAL',
                          'XLA_ERROR','XLA_NO_JOURNAL' )) THEN

   /*-----------------------------------------------------------------+
    |  Funds Reserve failed for the whole invoice                     |
    +-----------------------------------------------------------------*/

        IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
          l_log_msg := 'Step 6.1 - process return code =' || l_return_code ;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                         l_procedure_name, l_log_msg);
        END IF;

  --Bug 9136390 Starts
        IF ( l_return_code IN ('XLA_ERROR','XLA_NO_JOURNAL' )) THEN
          l_enc_acctg_fail_exists := 'Y';
          IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
            l_log_msg := 'l_enc_acctg_fail_exists is set' ||
                         'l_enc_acctg_fail_exists' || l_enc_acctg_fail_exists;
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                         l_procedure_name, l_log_msg);
          END IF;
  --Bug 9136390 Ends
		ELSIF ( l_return_code = 'FATAL' ) THEN  --Bug 9136390

          l_cant_fundsck_exists := 'Y';
          IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
            l_log_msg := 'l_cant_fundsck_exists is set' ||
                         'l_cant_fundsck_exists' || l_cant_fundsck_exists;
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                         l_procedure_name, l_log_msg);
          END IF;

        ELSE

          l_insuff_funds_exists := 'Y';
          IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
            l_log_msg := 'l_insuff_funds_exists is set' ||
                         'l_insuff_funds_exists' || l_insuff_funds_exists;
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                         l_procedure_name, l_log_msg);
          END IF;

        END IF;

        IF l_return_code = 'PARTIAL' THEN

          IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
            l_log_msg := 'funds reservation returned Partial and calling '||
                         'psa_ap_bc_pvt.Get_Detailed_Results';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                         l_procedure_name, l_log_msg);
          END IF;

          -- bug9026201
          BEGIN
            psa_ap_bc_pvt.Get_Detailed_Results (
                      p_init_msg_list    => FND_API.g_true,
                      p_tab_fc_dist      => t_funds_dist_tab,
                      p_calling_sequence => l_curr_calling_sequence,
                      x_return_status    => l_return_status,
                      x_msg_count        => l_msg_count,
                      x_msg_data         => l_msg_data);

            IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
              l_log_msg := 'Call psa_ap_bc_pvt.Get_Detailed_Results returned' ||
                             'l_return_status =' || l_return_status;

              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                             l_procedure_name, l_log_msg);
            END IF;

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_cant_fundsck_exists := 'Y';
              RAISE PSA_API_EXCEPTION;
            END IF;

          EXCEPTION
            WHEN OTHERS THEN
              IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
                l_log_msg := 'Call psa_ap_bc_pvt.Get_Detailed_Results '||
                             'raised an Exception' ||SQLERRM;
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                               l_procedure_name, l_log_msg);
              END IF;

              l_cant_fundsck_exists := 'Y';
              RAISE PSA_API_EXCEPTION;

          END;

          IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
              l_log_msg := 'process t_funds_dist_tab touched by PSA' ||
                           'PL/SQL TABLE COUNT IS' || to_char(t_funds_dist_tab.COUNT)||
                           'now beginning to check the data sanity';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                           l_procedure_name, l_log_msg);
          END IF;


          l_count_unproc := 0;
          FOR i IN 1..t_funds_dist_tab.COUNT LOOP
            IF t_funds_dist_tab(i).result_code = 'S' THEN

              BEGIN
                SELECT aid.bc_event_id
                  INTO l_bc_event_id
                  FROM ap_invoice_distributions_all aid
                 WHERE aid.invoice_distribution_id = t_funds_dist_tab(i).inv_distribution_id;

                IF l_bc_event_id IS NOT NULL THEN
                  SELECT xe.event_status_code
                    INTO l_bc_event_status
                    FROM xla_events xe
                   WHERE xe.application_id = 200
                     AND xe.event_id = l_bc_event_id;

                  IF l_bc_event_status <> 'P' THEN

                   IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
                      l_log_msg := 'for the invoice_distribution_id' ||t_funds_dist_tab(i).inv_distribution_id||
                                   'the BC event_id '||l_bc_event_id||
                                   'has a status '||l_bc_event_status||
                                   'thus existing the loop for sanity check, AP will not update distributions'||
                                   'to encumbered';
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                                       l_procedure_name, l_log_msg);
                    END IF;

                    l_count_unproc := l_count_unproc + 1;
                    exit;
                  END IF;
                END IF;

              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            END IF;
          END LOOP;

          IF l_count_unproc = 0 THEN

            IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
              l_log_msg := 'none of the BC events for the distributions returned as Successfully '||
                           'encumbered by PSA were unprocessed';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                               l_procedure_name, l_log_msg);
            END IF;


            FOR i IN 1..t_funds_dist_tab.COUNT LOOP
              IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
                l_log_msg := 'in the loop to update encumbrance flag' ||
                             'for distribution table for distribution_id=' ||
                              to_char(t_funds_dist_tab(i).inv_distribution_id);
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                               l_procedure_name, l_log_msg);
              END IF;

              IF t_funds_dist_tab(i).result_code = 'S' THEN
                -- Bug 6695993 added additional where clause
                -- at the suggestion of the PSA team.

                --Bug7153696 modified the below update to catter the self accessed tax invoices
                IF nvl(t_funds_dist_tab(i).SELF_ASSESSED_FLAG , 'N') = 'N' THEN

                   UPDATE ap_invoice_distributions_all aid
                      SET aid.encumbered_flag = 'Y'
                    WHERE aid.invoice_distribution_id = t_funds_dist_tab(i).inv_distribution_id
                      AND aid.bc_event_id is not null;

                ELSE

                    UPDATE ap_self_assessed_tax_dist_all sad
                       SET sad.encumbered_flag = 'Y'
                     WHERE sad.invoice_distribution_id = t_funds_dist_tab(i).inv_distribution_id
                       AND sad.bc_event_id is not null;

                END IF;

              END IF;

            END LOOP;

          ELSE
            IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
              l_log_msg := 'PSA returned an incorrect status for atleast one distribution '||
                           'setting up the variable for CANT FUNDS CHECK hold';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                               l_procedure_name, l_log_msg);
            END IF;

            l_cant_fundsck_exists := 'Y';
          END IF;

        END IF; -- end of dealing partial

      ELSE

        l_count_unproc := 0;
        FOR i IN 1..t_funds_dist_tab.COUNT LOOP
          BEGIN
            SELECT aid.bc_event_id
              INTO l_bc_event_id
              FROM ap_invoice_distributions_all aid
             WHERE aid.invoice_distribution_id = t_funds_dist_tab(i).inv_distribution_id;

            IF l_bc_event_id IS NOT NULL THEN
              SELECT xe.event_status_code
                INTO l_bc_event_status
                FROM xla_events xe
               WHERE xe.application_id = 200
                 AND xe.event_id = l_bc_event_id;

              IF l_bc_event_status <> 'P' THEN

                IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
                  l_log_msg := 'for the invoice_distribution_id' ||t_funds_dist_tab(i).inv_distribution_id||
                               'PSA returned a status code ' ||t_funds_dist_tab(i).result_code||
                               'but the BC event_id '||l_bc_event_id||
                               'has a status '||l_bc_event_status||
                               'thus existing the loop for sanity check, AP will not update distributions'||
                               'to encumbered';

                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                                   l_procedure_name, l_log_msg);
                END IF;

                l_count_unproc := l_count_unproc + 1;
                exit;
              END IF;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
        END LOOP;

   /*-----------------------------------------------------------------+
    |  Step 6.2 - Funds Reserve success for whole invoice             |
    |             We need to do clean up - update the invoice         |
    |             distributions packetid and encumbered flag          |
    |             should be SUCCESS and ADVISORY                      |
    +-----------------------------------------------------------------*/
        IF l_count_unproc = 0 THEN

          IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
            l_log_msg := 'none of the BC events for the distributions returned as Successfully '||
                         'encumbered by PSA were unprocessed';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                           l_procedure_name, l_log_msg);
          END IF;

          IF (G_LEVEL_STATEMENT >=  g_log_level ) THEN
            l_log_msg := 'Step 6.2 - funds reserve is done fully' ||
                         ' and process sucess return code =' || l_return_code ;
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                           l_procedure_name, l_log_msg);
          END IF;

          IF (G_LEVEL_STATEMENT >=  g_log_level ) THEN
            l_log_msg := 'number of distributions get funds reserved=' ||
                          to_char(t_funds_dist_tab.COUNT);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                           l_procedure_name, l_log_msg);
          END IF;

          BEGIN
            FOR i IN 1..t_funds_dist_tab.COUNT LOOP
             IF (G_LEVEL_STATEMENT >=  g_log_level ) THEN
               l_log_msg := 'update encumbered flag for distribution id=' ||
                             to_char(t_funds_dist_tab(i).inv_distribution_id);
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                           l_procedure_name, l_log_msg);
             END IF;

             -- Bug 6695993 added additional where clause
             -- at the suggestion of the PSA team.

             --Bug7153696 modified the below update to catter the self accessed tax invoices
             IF nvl(t_funds_dist_tab(i).SELF_ASSESSED_FLAG , 'N') = 'N' THEN

                UPDATE ap_invoice_distributions_all aid
                   SET aid.encumbered_flag = 'Y'
                 WHERE aid.invoice_distribution_id = t_funds_dist_tab(i).inv_distribution_id
                   AND aid.bc_event_id is not null;

             ELSE

                 UPDATE ap_self_assessed_tax_dist_all sad
                    SET sad.encumbered_flag = 'Y'
                  WHERE sad.invoice_distribution_id = t_funds_dist_tab(i).inv_distribution_id
                    AND sad.bc_event_id is not null;

             END IF;
            END LOOP;

          END;

        ELSE
          IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
            l_log_msg := 'PSA returned an incorrect status for atleast one distribution '||
                         'setting up the variable for CANT FUNDS CHECK hold';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                             l_procedure_name, l_log_msg);
          END IF;

          l_cant_fundsck_exists := 'Y';
        END IF;

      END IF;  -- check Funds Reservation Passed --


      p_funds_return_code := l_return_code;

      IF (G_LEVEL_STATEMENT >=  g_log_level ) THEN
        l_log_msg := 'p_funds_return_code out param is set' ||
                     'p_funds_return_code = ' || l_return_code ;
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                       l_procedure_name, l_log_msg);
      END IF;

   /*-----------------------------------------------------------------+
    |  Step 7 - Process Hold if insufficient funds hold exists        |
    +-----------------------------------------------------------------*/

      IF (G_LEVEL_PROCEDURE >=  g_log_level ) THEN
          l_log_msg := 'step 7 - process hold if exists';
          FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                         l_procedure_name, l_log_msg);
      END IF;


      AP_APPROVAL_PKG.Process_Inv_Hold_Status(
          p_invoice_id,
          null,
          null,
          'INSUFFICIENT FUNDS',
          l_insuff_funds_exists,
          null,
          p_system_user,
          p_holds,
          p_hold_count,
          p_release_count,
          l_curr_calling_sequence);
  --Bug 9136390 Starts
   /*----------------------------------------------------------------------+
    |  Step 7.1 - Process Hold if PSA Accounging fails hold exists        |
    +------------------------------------------------------------------------*/
      IF (G_LEVEL_PROCEDURE >=  g_log_level ) THEN
          l_log_msg := 'step 7.1 - process PSA accoutning hold if exists';
          FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                         l_procedure_name, l_log_msg);
      END IF;
      AP_APPROVAL_PKG.Process_Inv_Hold_Status(
          p_invoice_id,
          null,
          null,
          'Encumbrance Acctg Fail',
          l_enc_acctg_fail_exists,
          null,
          p_system_user,
          p_holds,
          p_hold_count,
          p_release_count,
          l_curr_calling_sequence);
  --Bug 9136390 Ends

   /*-----------------------------------------------------------------+
    |  Step 8  - Process Hold if can not do funds check hold exists   |
    +-----------------------------------------------------------------*/

      IF (G_LEVEL_PROCEDURE >=  g_log_level ) THEN
        l_log_msg := 'Step 8 - put CANT FUNDS CHECK';
        FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                       l_procedure_name, l_log_msg);
      END IF;


      AP_APPROVAL_PKG.Process_Inv_Hold_Status(
          p_invoice_id,
          null,
          null,
          'CANT FUNDS CHECK',
          l_cant_fundsck_exists,
          null,
          p_system_user,
          p_holds,
          p_hold_count,
          p_release_count,
          l_curr_calling_sequence);
    ELSE

   /*-----------------------------------------------------------------+
    |   NO distribution needs to be funds checked or reserved.        |
    |   Bug 9168747 Starts                                            |
    |    and releasing any existing CANT FUNDS CHECK hold.            |
    +-----------------------------------------------------------------*/

      SELECT COUNT(*)
        INTO l_cfc_hold_cnt
        FROM ap_holds_all
       WHERE invoice_id = p_invoice_id
         AND hold_lookup_code='CANT FUNDS CHECK'
         AND release_lookup_code is NULL;

      IF l_cfc_hold_cnt > 0 THEN

        IF (G_LEVEL_PROCEDURE >=  g_log_level ) THEN
          l_log_msg := 'Step 3 - Process CANT FUNDS CHECK';
          FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                         l_procedure_name, l_log_msg);
        END IF;

        AP_APPROVAL_PKG.Process_Inv_Hold_Status(
            p_invoice_id,
            null,
            null,
            'CANT FUNDS CHECK',
            l_cant_fundsck_exists,
            null,
            p_system_user,
            p_holds,
            p_hold_count,
            p_release_count,
            l_curr_calling_sequence);

      END IF; -- l_cfc_hold_cnt end
    --Bug 9168747 Ends

       IF (G_LEVEL_STATEMENT >=  g_log_level ) THEN
         l_log_msg := 'Step 3 - no Call of psa_ap_bc_pvt.Create_Events' ||
                     'distribution cursor count = 0';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                       l_procedure_name, l_log_msg);
       END IF;

    END IF;

  ELSE

   /*-----------------------------------------------------------------+
    |   Encumbrance accounting option is turned on                    |
    +-----------------------------------------------------------------*/
   NULL;

   IF (G_LEVEL_PROCEDURE >=  g_log_level ) THEN
    l_log_msg := 'encumbered flag is not enabled for the OU';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                   l_procedure_name, l_log_msg);
   END IF;

  END IF;  -- Encumbrance Enabled --


  IF (G_LEVEL_PROCEDURE >=  g_log_level ) THEN
    l_log_msg := 'End of '|| l_procedure_name;
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                   l_procedure_name, l_log_msg);
  END IF;

EXCEPTION
  WHEN PSA_API_EXCEPTION THEN
   IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
     l_log_msg := 'Encountered an Exception in  the PSA api, inside the exception block';
     FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_procedure_name, l_log_msg);
   END IF;

   AP_APPROVAL_PKG.Process_Inv_Hold_Status(
          p_invoice_id,
          null,
          null,
          'CANT FUNDS CHECK',
          l_cant_fundsck_exists,
          null,
          p_system_user,
          p_holds,
          p_hold_count,
          p_release_count,
          l_curr_calling_sequence);

  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
                ||' Set of books id = '||to_char(p_set_of_books_id)
                ||' System user = '||to_char(p_system_user));
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Funds_Reserve;


/*=============================================================================
 |  PUBLIC PROCEDURE GET_ERV_CCID
 |
 |  DESCRIPTION
 |      Procedure to retrieve exchange rate variance ccid depending on the po
 |      distribution destination type.  If the destination type is EXPENSE,
 |      erv_ccid equals to po distribution variance ccid or distribution ccid
 |      depends on the accrue_on_receipt_flag value.  If the destination
 |      type is INVENDTORY, the erv_ccid depends on whether it is a gain or
 |      loss to be assigned to the system level exchange rate variance
 |      gain/loss ccid.
 |
 |  PARAMETERS
 |      p_chart_of_account_id:  Chart of Accounts Id
 |      p_sys_xrate_gain_ccid:  System level Exchange Rate Variance Gain Ccid
 |      p_sys_xrate_loss_ccid:  System level Exchange Rate Variance Loss Ccid
 |      p_dist_ccid:  Invoice Distribution Line Ccid
 |      p_expense_ccid:  PO Distribution Expense Ccid
 |      p_variance_ccid:  PO Distribution Variance Ccid
 |      p_destination_type:  PO Distribution Destination Type
 |      p_price_var_ccid:  Variable to contain the invoice price variance ccid
 |                         that is determined by the po distribution
 |                         destination type.
 |      p_erv:  Variable to contain the exchange rate variacne calculated by
 |              the procedure.
 |      p_erv_ccid:  Variable to contains the exchange rate variance ccid that
 |                   is determined by the po distribution destination type and
 |                   if automatic offsets is on or not.
 |      p_calling_sequence:  Debugging string to indicate path of module calls
 |                           to be printed out NOCOPY upon error.
 |
 |  NOTE
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *==========================================================================*/

PROCEDURE GET_ERV_CCID(
              p_sys_xrate_gain_ccid       IN            NUMBER,
              p_sys_xrate_loss_ccid       IN            NUMBER,
              p_dist_ccid                 IN            NUMBER,
              p_variance_ccid             IN            NUMBER,
              p_destination_type          IN            VARCHAR2,
              p_inv_distribution_id       IN            NUMBER,
              p_related_id                IN            NUMBER,
              p_erv                       IN            NUMBER,
              p_erv_ccid                  IN OUT NOCOPY NUMBER,
              p_calling_sequence          IN            VARCHAR2) IS

  l_debug_loc                   VARCHAR2(2000) := 'GET_ERV_CCID';
  l_curr_calling_sequence       VARCHAR2(2000);
  l_debug_info                  VARCHAR2(2000);


  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'GET_ERV_CCID';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;



BEGIN

  -- Update the calling sequence --
  l_curr_calling_sequence := 'AP_FUNDS_CONTROL_PKG.'||l_debug_loc||
                             '<-'||p_calling_sequence;


   /*-----------------------------------------------------------------+
    |  Determine erv_ccid - if existing no need to overlay            |
    |  Just query, otherwise build the account                        |
    +-----------------------------------------------------------------*/

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >=  g_log_level  ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
  END IF;


  IF (p_related_id is not null and
      p_inv_distribution_id = p_related_id  and
      nvl(p_erv, 0 ) <> 0 ) THEN

      IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
          l_log_msg := 'GET_ERV_CCID - Query the exising erv ccid';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

    BEGIN
        SELECT D.dist_code_combination_id
          INTO p_erv_ccid
          FROM ap_invoice_distributions D
         WHERE D.related_id = p_related_id
           AND D.line_type_lookup_code = 'ERV';
      EXCEPTION
          WHEN NO_DATA_FOUND THEN
            p_erv_ccid := -1;
    END;
  END IF;

  IF ( nvl( p_erv_ccid, -1) = -1 ) THEN

    IF (g_debug_mode = 'Y') THEN
      l_debug_info := 'GET_ERV_CCID - try to find erv ccid';
      AP_Debug_Pkg.Print(g_debug_mode, l_debug_info);
    END IF;

    IF ( nvl(p_erv,0 ) <> 0 ) THEN

      IF (p_destination_type = 'EXPENSE') THEN

        ---------------------------------------------------------------
        -- expense line, so erv account should equal expense account --
        -- bug 1666428 states that this should always be equal to the--
        -- dist_ccid on the invoice distribution making the change   --
        -- Fix for 2122441 commented above statement and wrote
        -- the below one,the FundsCntrl_Inv_Dist_Cur cursor takes
        -- care that in case of accure on receipt is Y then the
        -- charge account of PO is taken
        ---------------------------------------------------------------

        IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
          l_log_msg := 'GET_ERV_CCID - expense item ';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||l_procedure_name, l_log_msg);
        END IF;

         p_erv_ccid := p_variance_ccid ;

      ELSE

        ---------------------------------------------------------------------
        -- 1. if it is not expense destination type, we will populate the line
        --    with its related distribution line ccid. please note, this could
        --    could be either the accrual account or expense account. Due to
        --    checking 11i behavior, it is as above. We have decide to use
        --    use accrual or expense account pending on the "accrual on
        --    receipt option.
        -- 2. when the item destination type is "inventory", we still need
        --    flex build the distribution account with system rate gain/loss
        --    account depending on automatic offset value. This operation now
        --    is moved to SLA accounting rule
        -- 3. please see the changes detail in bug 5545704
        ---------------------------------------------------------------------

        p_erv_ccid := p_dist_ccid;

        -- the following code is comment out for bug 5545704
        -- put is here for future reference.
        /* IF ( p_erv < 0) THEN
          -------------------------
          -- exchange rate gain --
          -------------------------
          p_erv_ccid := p_sys_xrate_gain_ccid;

        ELSE
          ------------------------
          -- exchange rate loss --
          ------------------------
          p_erv_ccid := p_sys_xrate_loss_ccid;

        END IF; */

      END IF; -- destination_type = 'EXPENSE' --
    END IF; -- end of p_erv <> 0 check
  END IF; -- end of p_erv_ccid check

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >=  g_log_level ) THEN
      l_log_msg := 'End of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END GET_ERV_CCID;


/*=============================================================================
 |  PUBLIC PROCEDURE CALC_QV
 |
 |  DESCRIPTION
 |      Procedure to calculate the quantity variance and base quantity
 |      variance and also return the invoice distribution line number
 |      and parent line number that the quantity variances should
 |      be applied to.
 |
 |  PARAMETERS
 |      p_invoice_id:  Invoice Id
 |      p_po_dist_id:  Po Distribution Id that the invoice is matched to
 |      p_inv_currency_code:  Invoice Currency Code
 |      p_base_currency_code:  Base Currency Code
 |      p_po_price:  Po Price
 |      p_po_qty:  Po Quantity
 |      p_match_option:
 |      p_rtxn_uom:
 |      p_po_uom:
 |      p_item_id:
 |      p_qv:  Variable to contain the quantity variance of the invoice to be
 |             calculated by the procedure
 |      p_bqv:  Variable to contain the base quantity variance of the invoice to
 |              be calculated by the procedure
 |
 |      p_update_line_num:  Variable to contain the distribution parent line
 |                          number of the invoice that the qv should be
 |                          applied to
 |      p_update_dist_num:  Variable to contain the distribution line number
 |                          of the invoice that the qv should be applied to
 |      p_calling_sequence:  Debugging string to indicate path of module calls
 |                           to be printed out NOCOPY upon error
 |
 |  NOTE
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *==========================================================================*/

PROCEDURE Calc_QV(
              p_invoice_id          IN            NUMBER,
              p_po_dist_id          IN            NUMBER,
              p_inv_currency_code   IN            VARCHAR2,
              p_base_currency_code  IN            VARCHAR2,
              p_po_price            IN            NUMBER,
              p_po_qty              IN            NUMBER,
              p_match_option        IN            VARCHAR2,
              p_po_uom              IN            VARCHAR2,
              p_item_id             IN            NUMBER,
              p_qv                  IN OUT NOCOPY NUMBER,
              p_bqv                 IN OUT NOCOPY NUMBER,
              p_update_line_num     IN OUT NOCOPY NUMBER,
              p_update_dist_num     IN OUT NOCOPY NUMBER,
              p_calling_sequence    IN            VARCHAR2) IS

  l_old_qty_var           NUMBER;
  l_old_base_qty_var      NUMBER;
  l_new_qty_var           NUMBER;
  l_new_base_qty_var      NUMBER;
  l_unapproved_qty        NUMBER;
  l_unapproved_amt        NUMBER;
  l_debug_loc             VARCHAR2(2000) := 'Calc_QV';
  l_curr_calling_sequence VARCHAR2(2000);
  l_debug_info            VARCHAR2(2000);
  l_rate                  NUMBER;
  l_accr_on_receipt_flag  VARCHAR2(1);
  l_qty_received          NUMBER;


  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Calc_QV';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;


BEGIN

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >=  g_log_level   ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
  END IF;

  l_curr_calling_sequence := 'AP_FUNDS_CONTROL_PKG.'||l_debug_loc||
                             '<-'||p_calling_sequence;

  -----------------------------------------------------------------------
  -- new_qty_variance = (inv_qty - po_qty)*po_price - qty_variance     --
  --    where inv_qty = inv_qty for all approved invoice distributions --
  --                    matched to current po_distribution +           --
  --                    inv_qty of current invoice.                    --

  -- Change during coding of receipt matching project
  -- The QV was calulated and stored even when accrue_on_receipt = 'Y'
  -- but was not being used anywhere else , when accrue_on_receipt = 'N'
  -- we encumber the extra qty var between the Invoice and the PO, and this
  -- is the same whether we match to PO or Receipt.
  -- therefore changed the following in the select statement
  --       greatest(to_number(p_po_qty),
  --                decode(pd.accrue_on_receipt_flag,
  --                       'Y',poll.quantity_received,
  --                        p_po_qty)))
  -- to just p_po_qty
  -----------------------------------------------------------------------

  -- If matched to the receipt the UOM may be different, so we need to
  -- convert the quantity_invoiced to the PO UOM before multiplying
  -- with the PO price

  -----------------------------------------------------------------------
  -- Bug 2455810 Code modified by MSWAMINA on 11-July-02
  --
  -- The Select statement below would identify the cumulative QV
  -- for the invoices matched to the one po_distribution_id.
  -- If the Invoice is matched to receipt or in cases like ERS, and if it
  -- has TAX distributions, the TAX distributions will not have the
  -- PO attributes like UOM, etc.
  -- When the PO API is called for the Tax distribution it will fail.
  --
  -- As discussed with Bob, Jayanta on 11-July-02, Added a NVL to the
  -- D.matched_uom_lookup_code to the p_po_uom itself. By this way,
  -- the PO API to get the conversion rate will never fail.
  ----------------------------------------------------------------------

  select  decode(p_inv_currency_code,
                 p_base_currency_code,1,
                 nvl(PD.rate,1)),  -- l_rate
          -- l_accrue_on_receipt_flag
          PD.accrue_on_receipt_flag,
          -- l_quantity_received,
          POLL.quantity_received,
          -- old_qty_variance
          sum(nvl(D.quantity_variance,0)),
          -- 0ld_base_qty_variance
           decode(p_inv_currency_code,
                  p_base_currency_code,1,
                  nvl(PD.rate,1)) * sum(nvl(d.quantity_variance,0)),
          --new_qty_variance
          (((sum(decode(d.match_status_flag,
                        'A',nvl(decode(p_match_option,
                                       'R', (d.quantity_invoiced *
                                             po_uom_s.po_uom_convert(
                                               nvl(d.matched_uom_lookup_code,
                                               p_po_uom), p_po_uom
                                               ,p_item_id)),
                                        d.quantity_invoiced), 0),
                               decode(d.invoice_id, p_invoice_id,
                                      nvl(decode(p_match_option,
                                                 'R',
                                                 (d.quantity_invoiced *
                                                  po_uom_s.po_uom_convert(
                                                           nvl(d.matched_uom_lookup_code, p_po_uom), p_po_uom, p_item_id)),
                                                  d.quantity_invoiced), 0),
                                      decode(d.match_status_flag, 'A', 0,
                                             nvl(decode(p_match_option,
                                                        'R',
                                                        (d.quantity_invoiced *
                                                         po_uom_s.po_uom_convert(
                                                                  nvl(d.matched_uom_lookup_code, p_po_uom), p_po_uom, p_item_id)),
                                                        d.quantity_invoiced), 0)))
                                      )) - p_po_qty ) * p_po_price)
           - sum(nvl(d.quantity_variance,0))),
          -- new_base_qty_variance
          decode(p_inv_currency_code,
                 p_base_currency_code,1,
                 nvl(PD.rate,1)) *
                 (((sum(decode(d.match_status_flag,
                               'A',nvl(decode(p_match_option,
                                             'R',(d.quantity_invoiced *
                                                  po_uom_s.po_uom_convert(
                                                  nvl(d.matched_uom_lookup_code
                                                  ,p_po_uom), p_po_uom
                                                  ,p_item_id)),
                                              d.quantity_invoiced),
                                        0),
                               decode(d.invoice_id, p_invoice_id,
                                      nvl(decode(p_match_option,
                                                 'R',
                                                 (d.quantity_invoiced *
                                                  po_uom_s.po_uom_convert(
                                                           nvl(d.matched_uom_lookup_code, p_po_uom), p_po_uom, p_item_id)),
                                                  d.quantity_invoiced), 0),
                                      decode(d.match_status_flag, 'A', 0,
                                             nvl(decode(p_match_option,
                                                        'R',
                                                        (d.quantity_invoiced *
                                                         po_uom_s.po_uom_convert(
                                                                  nvl(d.matched_uom_lookup_code, p_po_uom), p_po_uom, p_item_id)),
                                                        d.quantity_invoiced), 0)))
                                      )) - p_po_qty ) * p_po_price)
          - sum(nvl(d.quantity_variance,0))),
          -- l_unapproved_qty
          sum(decode(d.invoice_id, p_invoice_id,
              decode(match_status_flag,
                     'A',0,
                     nvl(decode(p_match_option, 'R', (quantity_invoiced *
                                po_uom_s.po_uom_convert(
                                nvl(d.matched_uom_lookup_code,
                                    p_po_uom), p_po_uom, p_item_id))
                                ,quantity_invoiced),0)),
                     0)),
         -- l_unapproved_amount
         (p_po_price * sum(decode(d.invoice_id, p_invoice_id,
                             decode(match_status_flag,
                                    'A',0,
                                    nvl(decode(p_match_option,'R',
                                               (quantity_invoiced *
                                                po_uom_s.po_uom_convert(
                                                 nvl(d.matched_uom_lookup_code,
                                                 p_po_uom), p_po_uom
                                                 , p_item_id))
                                                ,quantity_invoiced),0)),
                                   0)) )
    into    l_rate,                 --bug:1826323
            l_accr_on_receipt_flag, --bug:1826323
            l_qty_received,         --bug:1826323
            l_old_qty_var,
            l_old_base_qty_var,
            l_new_qty_var,
            l_new_base_qty_var,
            l_unapproved_qty,
            l_unapproved_amt
    from    ap_invoice_distributions d,
            po_distributions pd,
            po_line_locations poll
   where    pd.po_distribution_id = d.po_distribution_id
    and     d.po_distribution_id  = p_po_dist_id
    and     d.line_type_lookup_code NOT IN ('NONREC_TAX','TRV','TIPV')
    and     poll.line_location_id = pd.line_location_id
    group by decode(p_inv_currency_code,
                    p_base_currency_code,1,
                    nvl(PD.rate,1)),
             pd.accrue_on_receipt_flag,
             poll.quantity_received;

   /*-----------------------------------------------------------------+
    |  round all amounts                                              |
    +-----------------------------------------------------------------*/

  l_old_qty_var := AP_UTILITIES_PKG.ap_round_currency(l_old_qty_var,
                       p_inv_currency_code);

  l_old_base_qty_var := AP_UTILITIES_PKG.ap_round_currency(l_old_base_qty_var,
                            p_base_currency_code);

  l_new_qty_var := AP_UTILITIES_PKG.ap_round_currency(l_new_qty_var,
                       p_inv_currency_code);

  l_new_base_qty_var := AP_UTILITIES_PKG.ap_round_currency(l_new_base_qty_var,
                            p_base_currency_code);

  l_unapproved_amt := AP_UTILITIES_PKG.ap_round_currency(l_unapproved_amt,
                          p_inv_currency_code);

  p_qv  := l_new_qty_var;
  p_bqv := l_new_base_qty_var;


  IF ((l_unapproved_qty < 0) AND (l_old_qty_var > 0)) THEN

    -----------------------------------------------------------------------
    --  Aggregate quantity_invoiced for this invoice is negative, which  --
    --  means that reversals exceed any new positive quantity            --
    --  distributions.  Book it to the distribution with the LOWEST      --
    --  unapproved quantity.                                             --
    --  Note:  We only book a negative quantity variance if there has    --
    --         been a reversal AND there was an existing positive        --
    --         quantity variance.                                        --
    -----------------------------------------------------------------------

    ---------------------------------------------------
    --Do not allow total qty variance to be negative --
    ---------------------------------------------------

    IF (l_unapproved_amt < -l_old_qty_var) THEN

      -----------------------------------------------------------------
      -- Book a qv that is the additive inverse of total approved qv --
      -----------------------------------------------------------------

      p_qv  := -l_old_qty_var;
      p_bqv := -l_old_base_qty_var;

    END IF;

    ----------------------------------------------------------------------
    -- Retrieve the dist_line_num with the SMALLEST unapproved quantity --
    ----------------------------------------------------------------------
    l_debug_info := 'CALC_QV - find dist line with min qty for ' ||
                    'negative qty_variance';

-- bug 7458713: modify start
/*
    select nvl(distribution_line_number,0),
           nvl(invoice_line_number,0)
    into   p_update_dist_num,
           p_update_line_num
    from   ap_invoice_distributions
    where  (invoice_line_number, distribution_line_number) =
           (select nvl(min(invoice_line_number),0), nvl(min(distribution_line_number),0)
              from ap_invoice_distributions
             where invoice_id = p_invoice_id
               and po_distribution_id = p_po_dist_id
               and nvl(encumbered_flag,'N') in ('N','H','P')
               and (match_status_flag is null or
                    match_status_flag <> 'A')
               and quantity_invoiced =
                  (select min(quantity_invoiced)
                     from ap_invoice_distributions
                    where invoice_id = p_invoice_id
                      and po_distribution_id = p_po_dist_id
                      and nvl(encumbered_flag,'N') in ('N','H','P')
                      and (match_status_flag is null or
                           match_status_flag <> 'A')) )
    and    (match_status_flag is null or match_status_flag <> 'A')
    and    invoice_id = p_invoice_id
    and    po_distribution_id = p_po_dist_id
    and    rownum < 2;
*/

   SELECT line_number,
          dist_line_number
     INTO p_update_line_num,
              p_update_dist_num
     FROM (SELECT nvl(invoice_line_number,0) line_number, nvl(distribution_line_number,0) dist_line_number,
          row_number() OVER (ORDER BY invoice_line_number,distribution_line_number) R
          FROM ap_invoice_distributions_all
          WHERE invoice_id = p_invoice_id
          AND po_distribution_id = p_po_dist_id
          AND nvl(encumbered_flag,'N') IN ('N','H','P')
          AND (match_status_flag IS NULL OR match_status_flag <> 'A')
          AND quantity_invoiced =
              (SELECT min(quantity_invoiced)
                 FROM ap_invoice_distributions_all
                 WHERE invoice_id = p_invoice_id
                 AND po_distribution_id = p_po_dist_id
                 AND nvl(encumbered_flag,'N') IN ('N','H','P')
                 AND (match_status_flag IS NULL OR match_status_flag <> 'A'))
                  )
         WHERE R = 1;
-- bug 7458713: modify end

  ELSIF (l_new_qty_var > 0) THEN

    --------------------------------------------------------------
    -- If new_qty_variance > 0 then there are positive quantity --
    -- variances.  Book a positive-quantity variance on the     --
    -- distribution with the LARGEST unapproved quantity        --
    --------------------------------------------------------------
    l_debug_info := 'CALC_QV - find dist line with max qty for ' ||
                    'positive qty_variance';

    select nvl(distribution_line_number,0),
           invoice_line_number
      into p_update_dist_num,
           p_update_line_num
      from ap_invoice_distributions
     where (invoice_line_number, distribution_line_number) =
           (select nvl(min(invoice_line_number),0), nvl(min(distribution_line_number),0)
              from ap_invoice_distributions
             where invoice_id = p_invoice_id
               and po_distribution_id = p_po_dist_id
               and nvl(encumbered_flag,'N') in ('N','H','P')
               and (match_status_flag is null or
                    match_status_flag <> 'A')
               and quantity_invoiced =
                  (select max(quantity_invoiced)
                     from ap_invoice_distributions
                    where invoice_id = p_invoice_id
                      and po_distribution_id = p_po_dist_id
                      and nvl(encumbered_flag,'N') in ('N','H','P')
                      and (match_status_flag is null or
                           match_status_flag <> 'A')) )
       and (match_status_flag is null or match_status_flag <> 'A')
       and  invoice_id = p_invoice_id
       and  po_distribution_id = p_po_dist_id
       and  rownum < 2;

  ELSE
    -------------------------------------------------------
    -- No quantity variance for this invoice and PO dist --
    -------------------------------------------------------

    l_debug_info := 'CALC_QV - NO quantity variance exists';
    p_qv  := 0;
    p_bqv := 0;

  END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >=  g_log_level   ) THEN
      l_log_msg := 'End of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Po_dist_id = '|| to_char(p_po_dist_id)
              ||', Inv_currency_code = '|| p_inv_currency_code
              ||', Po_price = '|| to_char(p_po_price)
              ||', Po_qty = '|| to_char(p_po_qty));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Calc_QV;

/*=============================================================================
 |  PUBLIC PROCEDURE CALC_AV
 |
 |  DESCRIPTION
 |      Procedure to calculate the amount variance and base amount
 |      variance and also return the invoice distribution line number
 |      and parent line number that the amount variances should
 |      be applied to.
 |
 |  PARAMETERS
 |      p_invoice_id:  Invoice Id
 |      p_po_dist_id:  Po Distribution Id that the invoice is matched to
 |      p_inv_currency_code:  Invoice Currency Code
 |      p_base_currency_code:  Base Currency Code
 |      p_po_amt:  Po Amount
 |      p_match_option:
 |      p_rtxn_uom:
 |      p_po_uom:
 |      p_item_id:
 |      p_av:  Variable to contain the amount variance of the invoice to be
 |             calculated by the procedure
 |      p_bav:  Variable to contain the base amount variance of the invoice to
 |              be calculated by the procedure
 |
 |      p_update_line_num:  Variable to contain the distribution parent line
 |                          number of the invoice that the av should be
 |                          applied to
 |      p_update_dist_num:  Variable to contain the distribution line number
 |                          of the invoice that the av should be applied to
 |      p_calling_sequence:  Debugging string to indicate path of module calls
 |                           to be printed out NOCOPY upon error
 |
 |  NOTE
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *==========================================================================*/


PROCEDURE Calc_AV(
              p_invoice_id          IN            NUMBER,
              p_po_dist_id          IN            NUMBER,
              p_inv_currency_code   IN            VARCHAR2,
              p_base_currency_code  IN            VARCHAR2,
              p_po_amt              IN            NUMBER,
              p_av                  IN OUT NOCOPY NUMBER,
              p_bav                 IN OUT NOCOPY NUMBER,
              p_update_line_num     IN OUT NOCOPY NUMBER,
              p_update_dist_num     IN OUT NOCOPY NUMBER,
              p_calling_sequence    IN            VARCHAR2) IS

  l_old_amt_var           NUMBER;
  l_old_base_amt_var      NUMBER;
  l_new_amt_var           NUMBER;
  l_new_base_amt_var      NUMBER;
  l_unapproved_amt        NUMBER;
  l_debug_loc             VARCHAR2(2000) := 'Calc_AV';
  l_curr_calling_sequence VARCHAR2(2000);
  l_debug_info            VARCHAR2(2000);
  l_rate                  NUMBER;
  l_accr_on_receipt_flag  VARCHAR2(1);
  l_amt_received          NUMBER;

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Calc_AV';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  -- Update the calling sequence --

  l_curr_calling_sequence := 'AP_FUNDS_CONTROL_PKG.'||l_debug_loc||
                             '<-'||p_calling_sequence;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >=  g_log_level  ) THEN
      l_log_msg := 'Begin of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
  END IF;

  -----------------------------------------------------------------------
  -- new_amt_variance = (inv_amt - po_amt) - amt_variance     --
  --    where inv_amt = inv_amt for all approved invoice distributions --
  --                    matched to current po_distribution +           --
  --                    inv_amt of current invoice.                    --

  -----------------------------------------------------------------------

   select  decode(p_inv_currency_code,
                 p_base_currency_code,1,
                 nvl(PD.rate,1)),
          pd.accrue_on_receipt_flag,
          poll.amount_received,
          -- old_amt_variance
          sum(nvl(d.amount_variance,0)),
          -- 0ld_base_amt_variance
          decode(p_inv_currency_code,
                 p_base_currency_code,1,nvl(PD.rate,1))
                                         * sum(nvl(d.amount_variance,0)),
          --new_amt_variance
          ((sum (decode(d.match_status_flag,
                        'A',nvl(d.amount,0),
                        decode(d.invoice_id,
                               p_invoice_id,nvl(d.amount,0),
                               0)
                       )
                ) - p_po_amt
            ) - sum(nvl(d.amount_variance,0))
           ),
          -- new_base_amt_variance
          decode(p_inv_currency_code,
                 p_base_currency_code,1,nvl(PD.rate,1))
                                         *((sum(decode (d.match_status_flag,
                                                       'A',nvl(d.amount,0),
                                                        decode(d.invoice_id,
                                                               p_invoice_id,nvl(d.amount,0),
                                                              0)
                                                        )
                                               )-p_po_amt
                                           ) - sum(nvl(d.amount_variance,0))
                                         ),
         -- l_unapproved_amount
         sum(decode(d.invoice_id,
                    p_invoice_id,decode(match_status_flag,
                                        'A',0,nvl(d.amount,0)
                                         ),
                    0)
            )
          into    l_rate,
                  l_accr_on_receipt_flag,
                  l_amt_received,
                  l_old_amt_var,
                  l_old_base_amt_var,
                  l_new_amt_var,
                  l_new_base_amt_var,
                  l_unapproved_amt
          from    ap_invoice_distributions d,
                  po_distributions pd,
                  po_line_locations poll
          where   pd.po_distribution_id = d.po_distribution_id
          and     d.po_distribution_id  = p_po_dist_id
          and     poll.line_location_id = pd.line_location_id
          and     d.line_type_lookup_code IN ('ITEM','ACCRUAL') --bugfix:3881673
          group by decode(p_inv_currency_code,
                          p_base_currency_code,1,
                          nvl(PD.rate,1)),
                  pd.accrue_on_receipt_flag, poll.amount_received;

-- round all amounts

  l_old_amt_var := AP_UTILITIES_PKG.ap_round_currency(l_old_amt_var, p_inv_currency_code);

  l_old_base_amt_var := AP_UTILITIES_PKG.ap_round_currency(l_old_base_amt_var, p_base_currency_code);

  l_new_amt_var := AP_UTILITIES_PKG.ap_round_currency(l_new_amt_var, p_inv_currency_code);

  l_new_base_amt_var := AP_UTILITIES_PKG.ap_round_currency(l_new_base_amt_var, p_base_currency_code);

  l_unapproved_amt := AP_UTILITIES_PKG.ap_round_currency(l_unapproved_amt, p_inv_currency_code);

  p_av  := l_new_amt_var;
  p_bav := l_new_base_amt_var;

  IF ((l_unapproved_amt < 0) AND (l_old_amt_var > 0)) THEN

    -----------------------------------------------------------------------
    --  Aggregate amount_invoiced for this invoice is negative, which  --
    --  means that reversals exceed any new positive amount              --
    --  distributions.  Book it to the distribution with the LOWEST      --
    --  unapproved amount.                                               --
    --  Note:  We only book a negative amount variance if there has    --
    --         been a reversal AND there was an existing positive        --
    --         amount variance.                                  --
    -----------------------------------------------------------------------

    ---------------------------------------------------
    --Do not allow total amt variance to be negative --
    ---------------------------------------------------

    IF (l_unapproved_amt < -l_old_amt_var) THEN

      -----------------------------------------------------------------
      -- Book a av that is the additive inverse of total approved av --
      -----------------------------------------------------------------

      p_av  := -l_old_amt_var;
      p_bav := -l_old_base_amt_var;

    END IF;

    ----------------------------------------------------------------------
    -- Retrieve the dist_line_num with the SMALLEST unapproved amount --
    ----------------------------------------------------------------------

     IF (G_LEVEL_PROCEDURE >=  g_log_level  ) THEN
      l_log_msg := 'CALC_AV - find dist line with min amt for ' ||
                    'negative amt_variance';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
     END IF;

    select nvl(distribution_line_number,0),
           nvl(invoice_line_number,0)
    into   p_update_dist_num,
           p_update_line_num
    from   ap_invoice_distributions
    where  (invoice_line_number, distribution_line_number) =
           (select nvl(min(invoice_line_number),0), nvl(min(distribution_line_number),0)
              from ap_invoice_distributions
             where invoice_id = p_invoice_id
               and po_distribution_id = p_po_dist_id
               and nvl(encumbered_flag,'N') in ('N','H','P')
               and (match_status_flag is null or
                    match_status_flag <> 'A')
               and amount =
                  (select min(amount)
                     from ap_invoice_distributions
                    where invoice_id = p_invoice_id
                      and po_distribution_id = p_po_dist_id
                      and nvl(encumbered_flag,'N') in ('N','H','P')
                      and (match_status_flag is null or
                           match_status_flag <> 'A')) )
    and    (match_status_flag is null or match_status_flag <> 'A')
    and    invoice_id = p_invoice_id
    and    po_distribution_id = p_po_dist_id
    and    rownum < 2;

  ELSIF (l_new_amt_var > 0) THEN

    --------------------------------------------------------------
    -- If new_amt_variance > 0 then there are positive amount --
    -- variances.  Book a positive-amount variance on the     --
    -- distribution with the LARGEST unapprived amount        --
    --------------------------------------------------------------
    l_debug_info := 'CALC_AV - find dist line with max amt for ' ||
                    'positive amt_variance';

    select nvl(distribution_line_number,0),
           invoice_line_number
    into   p_update_dist_num,
           p_update_line_num
    from   ap_invoice_distributions
    where  (invoice_line_number, distribution_line_number) =
           (select nvl(min(invoice_line_number),0), nvl(min(distribution_line_number),0)
              from ap_invoice_distributions
             where invoice_id = p_invoice_id
               and po_distribution_id = p_po_dist_id
               and nvl(encumbered_flag,'N') in ('N','H','P')
               and (match_status_flag is null or
                    match_status_flag <> 'A')
               and amount =
                  (select max(amount)
                     from ap_invoice_distributions
                    where invoice_id = p_invoice_id
                      and po_distribution_id = p_po_dist_id
                      and nvl(encumbered_flag,'N') in ('N','H','P')
                      and (match_status_flag is null or
                           match_status_flag <> 'A')) )
    and (match_status_flag is null or match_status_flag <> 'A')
    and  invoice_id = p_invoice_id
    and  po_distribution_id = p_po_dist_id
    and  rownum < 2;

  ELSE
       -------------------------------------------------------
       -- No amount variance for this invoice and PO dist --
       -------------------------------------------------------

    p_av  := 0;
    p_bav := 0;

  END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >=  g_log_level  ) THEN
      l_log_msg := 'End of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Po_dist_id = '|| to_char(p_po_dist_id)
              ||', Inv_currency_code = '|| p_inv_currency_code
              ||', Po_amt = '|| to_char(p_po_amt));
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Calc_AV;

/*=============================================================================
 |  PUBLIC PROCEDURE Funds_Check
 |
 |  DESCRIPTION
 |      Procedure to perform fundschecking on a whole invoice if p_line_num
 |      and p_dist_line_num are null or a particular invoice line or invoice
 |      distribution line if p_dist_line_num is provided
 |
 |  PARAMETERS
 |      p_invoice_id:  Invoice_Id to perform funds_checking on
 |      p_line_num:  Invoice Line Number represents the parent line of
 |                   distribution
 |      p_dist_line_num:  Invoice Distribution Line Number if populated,
 |                        tells the api to fundscheck a particular invoice
 |                        distribution instead of all the distribution lines
 |                        of the invoice
 |      p_return_message_name:  Message returned to the calling module of
 |                              status of invoice
 |      p_calling_sequence:  Debugging string to indicate path of module calls
 |                           to  be printed out NOCOPY upon error.
 |
 |  NOTE
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |
 *==========================================================================*/

PROCEDURE Funds_Check(
              p_invoice_id           IN            NUMBER,
              p_inv_line_num         IN            NUMBER,
              p_dist_line_num        IN            NUMBER,
              p_return_message_name  IN OUT NOCOPY VARCHAR2,
              p_calling_sequence     IN            VARCHAR2) IS

CURSOR funds_check_dist_cursor IS
   SELECT AI.invoice_id,                      -- invoice_id
          AI.invoice_num,                     -- invoice_num
          AI.legal_entity_id,                 -- BCPSA bug
          AI.invoice_type_lookup_code,        -- invoice_type_code
          AID.invoice_line_number,             -- inv_line_num
          AID.invoice_distribution_id ,        -- inv_distribution_id
          AID.accounting_date,                 -- accounting_date
          AID.LINE_TYPE_LOOKUP_CODE,           -- distribution_type
          AID.amount,                          -- distribution_amount
          AID.set_of_books_id,                 -- set_of_books_id
          AID.bc_event_id,                     -- bc_event_id
          AID.org_id,                          -- org_id
          NULL,                                --result_code
          NULL,                                --status_code
          'N' self_assessed_flag               --self_assessed_flag --bug7109594
FROM ap_invoice_distributions_all aid,
     ap_invoices_all ai,
     ap_invoice_lines_all ail,
     gl_period_statuses per
WHERE ai.invoice_id = p_invoice_id
AND aid.invoice_id = ai.invoice_id
AND ail.invoice_id = aid.invoice_id
AND ail.line_number = aid.invoice_line_number
AND (p_dist_line_num IS NULL OR
     (p_dist_line_num IS NOT NULL
      AND aid.distribution_line_number = p_dist_line_num))
AND ( p_inv_line_num IS NULL OR
     (p_inv_line_num IS NOT NULL
     AND aid.invoice_line_number = p_inv_line_num))
AND nvl(aid.encumbered_flag, 'N') in ('N', 'H', 'P')
AND aid.posted_flag in ('N', 'P')
AND ail.line_type_lookup_code NOT IN ('AWT')
AND aid.period_name = per.period_name
AND per.set_of_books_id = ai.set_of_books_id
AND per.application_id = 200
AND nvl(per.adjustment_period_flag, 'N') = 'N'
AND aid.po_distribution_id is NULL
UNION ALL
SELECT    AI.invoice_id,                      -- invoice_id
          AI.invoice_num,                     -- invoice_num
          AI.legal_entity_id,                 -- BCPSA bug
          AI.invoice_type_lookup_code,        -- invoice_type_code
          AID.invoice_line_number,             -- inv_line_num
          AID.invoice_distribution_id ,        -- inv_distribution_id
          AID.accounting_date,                 -- accounting_date
          AID.LINE_TYPE_LOOKUP_CODE,           -- distribution_type
          AID.amount,                          -- distribution_amount
          AID.set_of_books_id,                 -- set_of_books_id
          AID.bc_event_id,                     -- bc_event_id
          AID.org_id,                          -- org_id
          NULL,                                -- result_code
          NULL,                                -- status_code
          'N' self_assessed_flag               -- self_assessed_flag --bug7109594
FROM ap_invoice_distributions_all aid,
     ap_invoices_all ai,
     ap_invoice_lines_all ail,
     gl_period_statuses per,
     po_distributions_all pod
WHERE ai.invoice_id = p_invoice_id
AND aid.invoice_id = ai.invoice_id
AND ail.invoice_id = aid.invoice_id
AND ail.line_number = aid.invoice_line_number
AND (p_dist_line_num IS NULL OR
     (p_dist_line_num IS NOT NULL
      AND aid.distribution_line_number = p_dist_line_num))
AND ( p_inv_line_num IS NULL OR
     (p_inv_line_num IS NOT NULL
     AND aid.invoice_line_number = p_inv_line_num))
AND ( (aid.line_type_lookup_code = 'ITEM' AND
       NVL(pod.accrue_on_receipt_flag,'N') <> 'Y')
       OR
      (aid.line_type_lookup_code NOT IN
       ( 'RETAINAGE', 'ACCRUAL','ITEM' )) )
AND nvl(aid.encumbered_flag, 'N') in ('N', 'H', 'P')
AND aid.posted_flag in ('N', 'P')
AND ail.line_type_lookup_code NOT IN ('AWT')
AND aid.period_name = per.period_name
AND per.set_of_books_id = ai.set_of_books_id
AND per.application_id = 200
AND nvl(per.adjustment_period_flag, 'N') = 'N'
AND aid.po_distribution_id is not NULL
AND aid.po_distribution_id = pod.po_distribution_id
AND NOT EXISTS ( select 'Advance Exists'
                   from  po_distributions_all         pod,
                         po_headers_all               poh,
                         ap_invoice_distributions_all ainvd,
                         ap_invoices_all              ainv,
                         po_doc_style_headers         pdsa
                   where pod.po_distribution_id   = aid.po_distribution_id
                     and poh.po_header_id           = pod.po_header_id
                     and poh.style_id             = pdsa.style_id
                     and ainv.invoice_id          = ai.invoice_id
                                 and ainv.invoice_id          = ainvd.invoice_id
                                 and ainvd.po_distribution_id = pod.po_distribution_id
                     and nvl(pdsa.advances_flag, 'N') = 'Y'
                     and (ainvd.line_type_lookup_code = 'PREPAY'
                          OR
                          ainv.invoice_type_lookup_code = 'PREPAYMENT') )
UNION ALL
   SELECT AI.invoice_id,                      -- invoice_id
          AI.invoice_num,                     -- invoice_num
          AI.legal_entity_id,                 -- BCPSA bug
          AI.invoice_type_lookup_code,        -- invoice_type_code
          T.invoice_line_number,              -- inv_line_num
          T.invoice_distribution_id ,         -- inv_distribution_id
          T.accounting_date,                  -- accounting_date
          T.LINE_TYPE_LOOKUP_CODE,            -- distribution_type
          T.amount,                           -- distribution_amount
          T.set_of_books_id,                  -- set_of_books_id
          T.bc_event_id,                      -- bc_event_id
          T.org_id,                           -- org_id
          NULL,                               --result_code
          NULL,                               --status_code
          T.self_assessed_flag                --self_assessed_flag --bug7109594
FROM ap_self_assessed_tax_dist_all t,
     ap_invoices_all ai,
     gl_period_statuses per
WHERE ai.invoice_id = p_invoice_id
AND t.invoice_id = ai.invoice_id
AND (p_inv_line_num IS NULL OR
     (p_inv_line_num IS NOT NULL
      AND t.invoice_line_number = p_inv_line_num))
AND (p_dist_line_num IS NULL OR
     (p_dist_line_num IS NOT NULL
      AND t.distribution_line_number = p_dist_line_num))
AND nvl(t.encumbered_flag, 'N') in ('N', 'H', 'P')
AND t.posted_flag in ('N', 'P')
AND t.period_name = per.period_name
AND per.set_of_books_id = ai.set_of_books_id
AND per.application_id = 200
AND nvl(per.adjustment_period_flag, 'N') = 'N'
AND t.po_distribution_id is NULL
UNION ALL
   SELECT AI.invoice_id,                     -- invoice_id
          AI.invoice_num,                    -- invoice_num
          AI.legal_entity_id,                -- BCPSA bug
          AI.invoice_type_lookup_code,       -- invoice_type_code
          T.invoice_line_number,             -- inv_line_num
          T.invoice_distribution_id ,        -- inv_distribution_id
          T.accounting_date,                 -- accounting_date
          T.LINE_TYPE_LOOKUP_CODE,           -- distribution_type
          T.amount,                          -- distribution_amount
          T.set_of_books_id,                 -- set_of_books_id
          T.bc_event_id,                     -- bc_event_id
          T.org_id,                          -- org_id
          NULL,                              -- result_code
          NULL,                              -- status_code
          T.self_assessed_flag               -- self_assessed_flag --bug7109594
FROM ap_self_assessed_tax_dist_all t,
     ap_invoices_all ai,
     gl_period_statuses per
WHERE ai.invoice_id = p_invoice_id
AND t.invoice_id = ai.invoice_id
AND (p_inv_line_num IS NULL OR
     (p_inv_line_num IS NOT NULL
      AND t.invoice_line_number = p_inv_line_num))
AND (p_dist_line_num IS NULL OR
     (p_dist_line_num IS NOT NULL
      AND t.distribution_line_number = p_dist_line_num))
AND nvl(t.encumbered_flag, 'N') in ('N', 'H', 'P')
AND t.posted_flag in ('N', 'P')
AND t.period_name = per.period_name
AND per.set_of_books_id = ai.set_of_books_id
AND per.application_id = 200
AND nvl(per.adjustment_period_flag, 'N') = 'N'
AND t.po_distribution_id is NOT NULL
AND NOT EXISTS ( select 'Advance Exists'
                   from  po_distributions_all         pod,
                         po_headers_all               poh,
                         ap_invoice_distributions_all ainvd,
                         ap_invoices_all              ainv,
                         po_doc_style_headers         pdsa
                   where pod.po_distribution_id   = t.po_distribution_id
                     and poh.po_header_id         = pod.po_header_id
                     and poh.style_id             = pdsa.style_id
                     and ainv.invoice_id          = t.invoice_id
                     and ainv.invoice_id          = ainvd.invoice_id
                     and ainvd.po_distribution_id = pod.po_distribution_id
                     and nvl(pdsa.advances_flag, 'N') = 'Y'
                     and (ainvd.line_type_lookup_code = 'PREPAY'
                          OR
                          ainv.invoice_type_lookup_code = 'PREPAYMENT') );

  l_debug_loc                   VARCHAR2(2000) := 'Funds_Check';
  l_curr_calling_sequence       VARCHAR2(2000);
  l_debug_info                  VARCHAR2(2000);

  l_return_code                 VARCHAR(30);

  l_status_code                 VARCHAR2(1);

  t_funds_dist_tab              PSA_AP_BC_PVT.Funds_Dist_Tab_Type;--bc

  l_bc_mode                     VARCHAR2(1) := 'C'; --bc
  l_set_of_books_id             NUMBER;
  l_chart_of_accounts_id        NUMBER;
  l_flex_method                 VARCHAR2(25);
  l_auto_offsets_flag           VARCHAR2(1);
  l_sys_xrate_gain_ccid         NUMBER;
  l_sys_xrate_loss_ccid         NUMBER;
  l_base_currency_code          VARCHAR2(15);
  l_inv_enc_type_id             NUMBER;
  l_gl_user                     NUMBER;

  l_dist_rec_count              NUMBER;
  l_return_status               VARCHAR2(30); --bc
  l_msg_count                   NUMBER; --bc
  l_msg_data                    VARCHAR2(2000);  --bc
  l_packet_id                   NUMBER; -- Bug 4535804

  l_org_id                      NUMBER; -- Bug 5487757
  PSA_API_EXCEPTION             EXCEPTION;

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'Funds_Check';
  l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

  -- Update the calling sequence --

  l_curr_calling_sequence := 'AP_FUNDS_CONTROL_PKG.'||l_debug_loc||
                             '<-'||p_calling_sequence;

   -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >=  g_log_level  ) THEN
        l_log_msg := 'Begin of procedure '|| l_procedure_name;
        FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                       l_procedure_name, l_log_msg);
  END IF;

  --Bug 5487757
  IF (G_LEVEL_PROCEDURE >=  g_log_level ) THEN
      l_log_msg := 'Selecting Org_Id for determining Encumbrance Enabled or not' ;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
  END IF;

  SELECT org_id
  INTO   l_org_id
  FROM   AP_INVOICES_ALL
  WHERE  invoice_id = p_invoice_id;


   /*-----------------------------------------------------------------+
    |  Check if System Encumbrance option is turned on                |
    +-----------------------------------------------------------------*/

  IF (Encumbrance_Enabled(l_org_id)) THEN

   /*-----------------------------------------------------------------+
    |  Step 1 - setup gl_fundschecker parameters                      |
    +-----------------------------------------------------------------*/

    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >=  g_log_level  ) THEN
        l_log_msg := 'Setup Gl Fundsctrl Param';
        FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                       l_procedure_name, l_log_msg);
    END IF;

    Setup_Gl_FundsCtrl_Params(
        l_bc_mode,
        'FUNDSCHECK',
        l_curr_calling_sequence);


   /*-----------------------------------------------------------------+
    |  Step 1.5 - Update the encumbered_flag for recoverable tax      |
    |           distributions to R so that these are not sent to PSA  |
    |           for encumbering -- added for bug#8936952              |
    +-----------------------------------------------------------------*/
    IF (G_LEVEL_PROCEDURE >=  g_log_level ) THEN
      l_log_msg := ' Update encumbered flag of recoverable ' ||
                   'tax distributions to R';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
    END IF;
        Update ap_invoice_distributions_all
	   set encumbered_flag = 'R'
         where invoice_id = p_invoice_id
	   and line_type_lookup_code = 'REC_TAX';

   /*-----------------------------------------------------------------+
    |  Step 2 - Get all the selected distributions for processing     |
    +-----------------------------------------------------------------*/

    IF (G_LEVEL_STATEMENT >=  g_log_level ) THEN
      l_log_msg := 'Step 2 - Open FundsCntrl_Inv_Dist_Cur Cursor';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                     l_procedure_name, l_log_msg);
    END IF;

    OPEN Funds_Check_Dist_Cursor;
    FETCH Funds_Check_Dist_Cursor
    BULK COLLECT INTO t_funds_dist_tab;
    CLOSE Funds_Check_Dist_Cursor;

   /*-----------------------------------------------------------------+
    |  Step 3 - Accounting Event Handling - Create, Stamp, Cleanup    |
    +-----------------------------------------------------------------*/

    IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
      l_log_msg := 'Step 3 - Call psa_ap_bc_pvt.Create_Events';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                     l_procedure_name, l_log_msg);
    END IF;

    IF ( t_funds_dist_tab.COUNT <> 0 ) THEN

      psa_ap_bc_pvt.Create_Events (
          p_init_msg_list    => fnd_api.g_true,
          p_tab_fc_dist      => t_funds_dist_tab,
          p_calling_mode     => 'APPROVE',
          p_bc_mode          => l_bc_mode,
          p_calling_sequence => l_curr_calling_sequence,
          x_return_status    => l_return_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data);

      IF (G_LEVEL_STATEMENT >=  g_log_level ) THEN
        l_log_msg := 'Call psa_ap_bc_pvt.Create_Events status result ' ||
                     'l_return_status =' || l_return_status;
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                       l_procedure_name, l_log_msg);
      END IF;

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        IF (G_LEVEL_STATEMENT >=  g_log_level ) THEN
          l_log_msg := 'Step 3 - Call psa_ap_bc_pvt.Create_Events not success ' ||
                       'l_return_status =' || l_return_status;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                         l_procedure_name, l_log_msg);
        END IF;

        RAISE PSA_API_EXCEPTION;

      END IF;

    /*-------------------------------------------------------------------+
    |  Step 4 - Call PSA BUDGETARY CONTROL API                           |
    +-------------------------------------------------------------------*/

      IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
        l_log_msg := 'Step 4 - Call PSA_BC_XLA_PUB.Budgetary_Control';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                       l_procedure_name, l_log_msg);
      END IF;

      PSA_BC_XLA_PUB.Budgetary_Control(
          p_api_version            => 1.0,
          p_init_msg_list          => Fnd_Api.G_False,
          x_return_status          => l_return_status,
          x_msg_count              => l_msg_count,
          x_msg_data               => l_msg_data,
          p_application_id             => 200,
          p_bc_mode                => l_bc_mode,
          p_override_flag          => 'N',
          P_user_id                => NULL,
          P_user_resp_id           => NULL,
          x_status_code            => l_return_code,
          x_Packet_ID              => l_packet_id );


      IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
        l_log_msg := 'Call PSA_BC_XLA_PUB.Budgetary_Control success' ||
                     'l_return_code =' || l_return_code ||
                     'l_packet_id =' || to_char(l_packet_id);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                         l_procedure_name, l_log_msg);
      END IF;


      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
          l_log_msg := 'Call PSA_BC_XLA_PUB.Budgetary_Control not success' ||
                       'l_return_status =' || l_return_status;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                       l_procedure_name, l_log_msg);
        END IF;

        RAISE PSA_API_EXCEPTION;
      END IF;



   /*-------------------------------------------------------------------+
    |  Step 5 - Process PSA BUDGETARY CONTROL return codes              |
    +-------------------------------------------------------------------*/

      IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
        l_log_msg := 'FUNDSCHECK - Process_Return_Code of GL funds check';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      IF (l_return_code in ('FAIL', 'PARTIAL')) THEN

      -------------------------------------------------------------------
      -- Step 5a - Process PSA BUDGETARY CONTROL FAILED
      -------------------------------------------------------------------

        p_return_message_name := 'AP_FCK_INSUFFICIENT_FUNDS';

      ELSIF l_return_code = 'FATAL' THEN
      -------------------------------------------------------------------
      -- Step 5b - Process PSA BUDGETARY CONTROL SUCCESS
      -------------------------------------------------------------------
        p_return_message_name := 'AP_FCK_FAILED_FUNDSCHECKER';

      ELSIF l_return_code = 'XLA_ERROR' THEN
      -------------------------------------------------------------------
      -- Step 5C - Process PSA BUDGETARY CONTROL SUCCESS
      -------------------------------------------------------------------
        p_return_message_name := 'AP_FCK_XLA_ERROR';

      ELSIF l_return_code = 'XLA_NO_JOURNAL'  THEN

        p_return_message_name := 'AP_FCK_XLA_NO_JOURNAL';

      ELSE
      -------------------------------------------------------------------
      -- Step 5d - Process PSA BUDGETARY CONTROL SUCCESS
      -------------------------------------------------------------------

        IF (l_return_code = 'ADVISORY') THEN
          p_return_message_name := 'AP_FCK_PASSED_FUNDS_ADVISORY';
        ELSE
          p_return_message_name := 'AP_FCK_PASSED_FUNDSCHECKER';
        END IF;
      END IF; -- end of check Fundscheck passed --

      IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
        l_log_msg := 'returned message to form is ' ||
                     'p_return_message_name =' || p_return_message_name;
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                         l_procedure_name, l_log_msg);
      END IF;

    ELSE

   /*-------------------------------------------------------------------+
    |   Process PSA BUDGETARY CONTROL return codes                      |
    +-------------------------------------------------------------------*/
      p_return_message_name := 'AP_ENC_NO_DIST_APPL';  --added for bug 8639979
      IF (G_LEVEL_STATEMENT >=  g_log_level ) THEN
        l_log_msg := 'no Call of psa_ap_bc_pvt.Create_Events' ||
                     'distribution cursor count = 0';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                       l_procedure_name, l_log_msg);
      END IF;

    END IF;

  ELSE
   /*-------------------------------------------------------------------+
    |  System Encumbrance option is turned off                          |
    +-------------------------------------------------------------------*/

     IF (G_LEVEL_STATEMENT >=  g_log_level  ) THEN
      l_log_msg := 'encumberance is off';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME ||
                         l_procedure_name, l_log_msg);
     END IF;

    p_return_message_name := 'AP_ALL_ENC_OFF';


  END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >=  g_log_level   ) THEN
      l_log_msg := 'End of procedure '|| l_procedure_name;
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||
                     l_procedure_name, l_log_msg);
  END IF;

EXCEPTION
  WHEN PSA_API_EXCEPTION THEN
    FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
    FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
    FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'invoice_id  = '|| to_char(p_invoice_id) );
    FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_msg_data);
    APP_EXCEPTION.RAISE_EXCEPTION;

  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id)
              ||', Invoice_line_num  = '|| to_char(p_inv_line_num)
              ||', Dist_line_num = '|| to_char(p_dist_line_num));
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Funds_Check;


-- ETAX: Validation
-- Added the Funds_Check_Processor as part of ETAX: Validation project.
-- This is called from Check Funds Menu Option.
/*-----------------------------------------------------------------------
|                     FUNDS CHECK PROCESSOR                             |
------------------------------------------------------------------------*/
FUNCTION Funds_Check_Processor (  P_Invoice_Id               IN NUMBER,
                                  P_Invoice_Line_Number      IN NUMBER,
                                  p_dist_line_num            IN NUMBER,
                                  P_Invoice_Needs_Validation IN VARCHAR2,
                                  P_Error_Code               OUT NOCOPY VARCHAR2,
                                  P_Token1                   OUT NOCOPY NUMBER,
                                  P_Calling_Sequence         IN VARCHAR2) RETURN BOOLEAN IS

  CURSOR Invoice_Lines_Cursor(P_Line_Number NUMBER) IS
  SELECT INVOICE_ID,
         LINE_NUMBER,
         LINE_TYPE_LOOKUP_CODE,
         REQUESTER_ID,
         DESCRIPTION,
         LINE_SOURCE,
         ORG_ID,
         LINE_GROUP_NUMBER,
         INVENTORY_ITEM_ID,
         ITEM_DESCRIPTION,
         SERIAL_NUMBER,
         MANUFACTURER,
         MODEL_NUMBER,
         WARRANTY_NUMBER,
         GENERATE_DISTS,
         MATCH_TYPE,
         DISTRIBUTION_SET_ID,
         ACCOUNT_SEGMENT,
         BALANCING_SEGMENT,
         COST_CENTER_SEGMENT,
         OVERLAY_DIST_CODE_CONCAT,
         DEFAULT_DIST_CCID,
         PRORATE_ACROSS_ALL_ITEMS,
         ACCOUNTING_DATE,
         PERIOD_NAME ,
         DEFERRED_ACCTG_FLAG ,
         DEF_ACCTG_START_DATE ,
         DEF_ACCTG_END_DATE,
         DEF_ACCTG_NUMBER_OF_PERIODS,
         DEF_ACCTG_PERIOD_TYPE ,
         SET_OF_BOOKS_ID,
         AMOUNT,
         BASE_AMOUNT,
         ROUNDING_AMT,
         QUANTITY_INVOICED,
         UNIT_MEAS_LOOKUP_CODE ,
         UNIT_PRICE,
         WFAPPROVAL_STATUS,
         DISCARDED_FLAG,
         ORIGINAL_AMOUNT,
         ORIGINAL_BASE_AMOUNT ,
         ORIGINAL_ROUNDING_AMT ,
         CANCELLED_FLAG ,
         INCOME_TAX_REGION,
         TYPE_1099   ,
         STAT_AMOUNT  ,
         PREPAY_INVOICE_ID ,
         PREPAY_LINE_NUMBER  ,
         INVOICE_INCLUDES_PREPAY_FLAG ,
         CORRECTED_INV_ID ,
         CORRECTED_LINE_NUMBER ,
         PO_HEADER_ID,
         PO_LINE_ID  ,
         PO_RELEASE_ID ,
         PO_LINE_LOCATION_ID ,
         PO_DISTRIBUTION_ID,
         RCV_TRANSACTION_ID,
         FINAL_MATCH_FLAG,
         ASSETS_TRACKING_FLAG ,
         ASSET_BOOK_TYPE_CODE ,
         ASSET_CATEGORY_ID ,
         PROJECT_ID ,
         TASK_ID ,
         EXPENDITURE_TYPE ,
         EXPENDITURE_ITEM_DATE ,
         EXPENDITURE_ORGANIZATION_ID ,
         PA_QUANTITY,         PA_CC_AR_INVOICE_ID ,
         PA_CC_AR_INVOICE_LINE_NUM ,
         PA_CC_PROCESSED_CODE ,
         AWARD_ID,
         AWT_GROUP_ID ,
         REFERENCE_1 ,
         REFERENCE_2 ,
         RECEIPT_VERIFIED_FLAG  ,
         RECEIPT_REQUIRED_FLAG ,
         RECEIPT_MISSING_FLAG ,
         JUSTIFICATION  ,
         EXPENSE_GROUP ,
         START_EXPENSE_DATE ,
         END_EXPENSE_DATE ,
         RECEIPT_CURRENCY_CODE  ,
         RECEIPT_CONVERSION_RATE,
         RECEIPT_CURRENCY_AMOUNT ,
         DAILY_AMOUNT ,
         WEB_PARAMETER_ID ,
         ADJUSTMENT_REASON ,
         MERCHANT_DOCUMENT_NUMBER ,
         MERCHANT_NAME ,
         MERCHANT_REFERENCE ,
         MERCHANT_TAX_REG_NUMBER,
         MERCHANT_TAXPAYER_ID  ,
         COUNTRY_OF_SUPPLY,
         CREDIT_CARD_TRX_ID ,
         COMPANY_PREPAID_INVOICE_ID,
         CC_REVERSAL_FLAG ,
         CREATION_DATE ,
         CREATED_BY,
         LAST_UPDATED_BY ,
         LAST_UPDATE_DATE ,
         LAST_UPDATE_LOGIN ,
         PROGRAM_APPLICATION_ID ,
         PROGRAM_ID ,
         PROGRAM_UPDATE_DATE,
         REQUEST_ID ,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         GLOBAL_ATTRIBUTE_CATEGORY,
         GLOBAL_ATTRIBUTE1,
         GLOBAL_ATTRIBUTE2,
         GLOBAL_ATTRIBUTE3,
         GLOBAL_ATTRIBUTE4,
         GLOBAL_ATTRIBUTE5,
         GLOBAL_ATTRIBUTE6,
         GLOBAL_ATTRIBUTE7,
         GLOBAL_ATTRIBUTE8,
         GLOBAL_ATTRIBUTE9,
         GLOBAL_ATTRIBUTE10,
         GLOBAL_ATTRIBUTE11,
         GLOBAL_ATTRIBUTE12,
         GLOBAL_ATTRIBUTE13,
         GLOBAL_ATTRIBUTE14,
         GLOBAL_ATTRIBUTE15,
         GLOBAL_ATTRIBUTE16,
         GLOBAL_ATTRIBUTE17,
         GLOBAL_ATTRIBUTE18,
         GLOBAL_ATTRIBUTE19,
         GLOBAL_ATTRIBUTE20,
         --ETAX: Invwkb
         INCLUDED_TAX_AMOUNT,
         PRIMARY_INTENDED_USE,
             --Bugfix:4673607
             APPLICATION_ID,
             PRODUCT_TABLE,
             REFERENCE_KEY1,
             REFERENCE_KEY2,
             REFERENCE_KEY3,
             REFERENCE_KEY4,
             REFERENCE_KEY5,
             --bugfix:4674194
             SHIP_TO_LOCATION_ID,
             --bug 7022001
             PAY_AWT_GROUP_ID
    FROM ap_invoice_lines
   WHERE invoice_id = p_invoice_id
   AND   line_number = nvl(p_line_number,line_number)
   --Invoice Lines: Distributions
   ORDER BY decode(line_type_lookup_code,'ITEM',1,2), line_number;

  l_result                      NUMBER;
  l_success                     BOOLEAN := TRUE;
  t_inv_lines_table             AP_INVOICES_PKG.t_invoice_lines_table;
  i                             NUMBER;
  l_holds                       AP_APPROVAL_PKG.HOLDSARRAY;
  l_hold_count                  AP_APPROVAL_PKG.COUNTARRAY;
  l_release_count               AP_APPROVAL_PKG.COUNTARRAY;
  l_system_user                 NUMBER := 5;
  l_chart_of_accounts_id        NUMBER;
  l_auto_offsets_flag           VARCHAR2(1);
  l_sys_xrate_gain_ccid         NUMBER;
  l_sys_xrate_loss_ccid         NUMBER;
  l_base_currency_code          FND_CURRENCIES.CURRENCY_CODE%TYPE;
  l_xrate_flex_qualifier_name   VARCHAR2(12);
  l_xrate_flex_seg_delimiter    VARCHAR2(1);
  l_xrate_flex_segment_number   NUMBER;
  l_xrate_flex_num_of_segments  NUMBER;
  l_xrate_gain_segments         FND_FLEX_EXT.SEGMENTARRAY;
  l_xrate_loss_segments         FND_FLEX_EXT.SEGMENTARRAY;
  l_xrate_cant_flexbuild_flag   BOOLEAN;
  l_xrate_cant_flexbuild_reason VARCHAR2(2000);
  l_flex_method                 VARCHAR2(25);
  l_inv_env_type_id             NUMBER;
  l_gl_user_id                  NUMBER;
  l_set_of_books_id             NUMBER;
  l_error_code                  VARCHAR2(4000);
  l_insufficient_data_exist     BOOLEAN := FALSE;
  l_batch_id                    AP_BATCHES.BATCH_ID%TYPE;
  l_invoice_date                AP_INVOICES.INVOICE_DATE%TYPE;
  l_vendor_id                   AP_INVOICES.VENDOR_ID%TYPE;
  l_invoice_currency_code       AP_INVOICES.INVOICE_CURRENCY_CODE%TYPE;
  l_exchange_rate               AP_INVOICES.EXCHANGE_RATE%TYPE;
  l_exchange_rate_type          AP_INVOICES.EXCHANGE_RATE_TYPE%TYPE;
  l_exchange_date               AP_INVOICES.EXCHANGE_DATE%TYPE;
  l_return_message_name         FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
  l_line_type_lookup_code       AP_INVOICE_LINES.LINE_TYPE_LOOKUP_CODE%TYPE;
  l_line_number                 AP_INVOICE_LINES.LINE_NUMBER%TYPE;
  l_debug_info                  VARCHAR2(1000);
  l_curr_calling_sequence       VARCHAR2(2000);

  l_api_name                   VARCHAR2(50);

BEGIN

   l_api_name := 'Funds_Check_Processor';

   l_curr_calling_sequence := 'Funds_Check_Processor <-'||p_calling_sequence;

   IF (p_invoice_needs_validation = 'Y') THEN

         l_debug_info := 'Calculate Tax';
         l_success := ap_etax_pkg.calling_etax(
                                    p_invoice_id  => p_invoice_id,
                                    p_calling_mode => 'CALCULATE',
                                    p_all_error_messages => 'N',
                                    p_error_code =>  l_error_code,
                                    p_calling_sequence => l_curr_calling_sequence);

         IF (NOT l_success) THEN

            p_error_code := l_error_code;
            return(FALSE);

         END IF;

         SELECT batch_id,
                vendor_id,
                invoice_date,
                invoice_currency_code,
                exchange_rate,
                exchange_rate_type,
                exchange_date
         INTO l_batch_id,
              l_vendor_id,
              l_invoice_date,
              l_invoice_currency_code,
              l_exchange_rate,
              l_exchange_rate_type,
              l_exchange_date
         FROM ap_invoices
         WHERE invoice_id = p_invoice_id;

         --If the funds check is called for a ITEM line, then
         --generate the candidate distributions for just that line,
         --else of a charge line we will generate candidate distributions
         --for all the lines due to the dependency between distribution generation
         --of charge lines on the item lines.

         IF (p_invoice_line_number IS NOT NULL) THEN

            SELECT line_type_lookup_code
            INTO  l_line_type_lookup_code
            FROM ap_invoice_lines ail
            WHERE ail.invoice_id = p_invoice_id
            AND ail.line_number = p_invoice_line_number;

            IF (l_line_type_lookup_code = 'ITEM') THEN
              l_line_number := p_invoice_line_number;
            END IF;

         END IF;

         Fundscheck_init(p_invoice_id => p_invoice_id,
                         p_set_of_books_id => l_set_of_books_id,
                         p_xrate_gain_ccid => l_sys_xrate_gain_ccid,
                         p_xrate_loss_ccid => l_sys_xrate_loss_ccid,
                         p_base_currency_code => l_base_currency_code,
                         p_inv_enc_type_id => l_inv_env_type_id,
                         p_gl_user_id      => l_gl_user_id,
                         p_calling_sequence => l_curr_calling_sequence);


         OPEN Invoice_Lines_Cursor(l_line_number);
         FETCH Invoice_Lines_Cursor BULK COLLECT INTO t_inv_lines_table;
         CLOSE Invoice_Lines_Cursor;

         FOR i in t_inv_lines_table.first .. t_inv_lines_table.count LOOP

            IF ( t_inv_lines_table(i).line_type_lookup_code <> 'TAX' AND
                 t_inv_lines_table(i).generate_dists = 'Y' ) THEN

               AP_Approval_Pkg.Check_Insufficient_Line_Data(
                        p_inv_line_rec            => t_inv_lines_table(i),
                        p_system_user             => l_system_user,
                        p_holds                   => l_holds,
                        p_holds_count             => l_hold_count,
                        p_release_count           => l_release_count,
                        p_insufficient_data_exist => l_insufficient_data_exist,
                        p_calling_mode            => 'CANDIDATE_DISTRIBUTIONS',
                        p_calling_sequence        => l_curr_calling_sequence );

               IF ( NOT l_insufficient_data_exist ) THEN

                  l_success := AP_Approval_Pkg.Execute_Dist_Generation_Check(
                                p_batch_id           => l_batch_id,
                                p_invoice_date       => l_invoice_date,
                                p_vendor_id          => l_vendor_id,
                                p_invoice_currency   => l_invoice_currency_code,
                                p_exchange_rate      => l_exchange_rate,
                                p_exchange_rate_type => l_exchange_rate_type,
                                p_exchange_date      => l_exchange_date,
                                p_inv_line_rec       => t_inv_lines_table(i),
                                p_system_user        => l_system_user,
                                p_holds              => l_holds,
                                p_holds_count        => l_hold_count,
                                p_release_count      => l_release_count,
                                p_generate_permanent => 'N',
                                p_calling_mode       => 'CANDIDATE_DISTRIBUTIONS',
                                p_error_code         => l_error_code,
                                p_curr_calling_sequence => l_curr_calling_sequence);

                   l_debug_info := 'Distributions could not be generated for' ||
                                   'this Invoice line, return FALSE';

                   IF (NOT l_success) THEN
                      p_error_code := l_error_code;
                      return(FALSE);
                   END IF;

                ELSE   -- Insufficient line data exists

                   p_error_code := 'AP_INSUFFICIENT_LINE_DATA';
                   p_token1 := t_inv_lines_table(i).line_number;
                   return(FALSE);

                END IF; -- end of sufficient data check

             END IF; -- end of generate_dist check

             --Calculate IPV, ERV for po/rcv matched lines
             IF (t_inv_lines_table(i).match_type in ('ITEM_TO_PO',
                                                 'ITEM_TO_RECEIPT',
                                                 'PRICE_CORRECTION',
                                                 'QTY_CORRECTION' ) ) THEN

                l_debug_info := 'Calculate Matched Variances';
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                END IF;

                AP_APPROVAL_MATCHED_PKG.Exec_Matched_Variance_Checks(
                     p_invoice_id                => p_invoice_id,
                     p_inv_line_number           => t_inv_lines_table(i).line_number,
                     p_base_currency_code        => l_base_currency_code,
                     p_inv_currency_code         => l_invoice_currency_code,
                     p_sys_xrate_gain_ccid       => l_sys_xrate_gain_ccid,
                     p_sys_xrate_loss_ccid       => l_sys_xrate_loss_ccid,
                     p_system_user               => l_system_user,
                     p_holds                     => l_holds,
                     p_hold_count                => l_hold_count,
                     p_release_count             => l_release_count,
                     p_calling_sequence          => l_curr_calling_sequence );

             END IF;

          END LOOP;

          l_debug_info := 'Calculate Quantity Variance: '||p_invoice_id;
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;

          AP_APPROVAL_MATCHED_PKG.Exec_Qty_Variance_Check(
                               p_invoice_id         => p_invoice_id,
                               p_base_currency_code => l_base_currency_code,
                               p_inv_currency_code  => l_invoice_currency_code,
                               p_system_user        => l_system_user,
                               p_calling_sequence   => l_curr_calling_sequence );

          l_debug_info := 'Create Tax Distributions';
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;

          l_success := ap_etax_pkg.calling_etax (
                               p_invoice_id         => p_invoice_id,
                               p_calling_mode       => 'DISTRIBUTE',
                               p_all_error_messages => 'N',
                               p_error_code         => l_error_code,
                               p_calling_sequence   => l_curr_calling_sequence);

          IF (NOT l_success) THEN
             p_error_code := l_error_code;
             return(FALSE);
          END IF;

    END IF;  -- p_invoice_needs_validation

    l_debug_info := 'Before calling funds_check';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    ap_funds_control_pkg.funds_check(
                        p_invoice_id          => p_invoice_id,
                        p_inv_line_num        => p_invoice_line_number,
                        p_dist_line_num       => p_dist_line_num,
                        p_return_message_name => l_return_message_name,
                        p_calling_sequence    => l_curr_calling_sequence);

    l_debug_info := 'After calling funds_check: l_return_message_name: '||l_return_message_name;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    p_error_code := l_return_message_name;
    return(TRUE);

EXCEPTION
WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
       FND_MESSAGE.SET_TOKEN('PARAMETERS',
                  'Invoice_id  = '|| to_char(p_invoice_id));
    END IF;

    APP_EXCEPTION.RAISE_EXCEPTION;

END Funds_Check_Processor;


BEGIN
   g_log_level      := G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => G_MODULE_NAME);

   IF NOT g_log_enabled  THEN
      g_log_level := G_LEVEL_LOG_DISABLED;
   END IF;

END AP_FUNDS_CONTROL_PKG;



/
