--------------------------------------------------------
--  DDL for Package Body AP_BANKACCT_INACTIVE_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_BANKACCT_INACTIVE_WF_PKG" AS
/* $Header: apbainwb.pls 120.5 2006/02/07 13:26:01 mswamina noship $ */

   -- Package global
   -- FND_LOG related variables to enable logging for this package
   --
   G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_BANKACCT_INACTIVE_WF_PKG';
   G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
   G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
   G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
   G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
   G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
   G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
   G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

   G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
   G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
   G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
   G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
   G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
   G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
   G_MODULE_NAME           CONSTANT VARCHAR2(80) := 'AP.PLSQL.AP_BANKACCT_INACTIVE_WF_PKG.';

 ------ Procedure rule_function is called by the Subscription program. Rule Function determines
 ------ whether WorkFlow Program should be called.
 ------ event name  oracle.apps.iby.bankaccount.assignment_inactivated
 -------------------------------------------------------------------------------------------
 FUNCTION Rule_Function (P_Subscription IN RAW,
                         P_Event        IN OUT NOCOPY WF_EVENT_T) RETURN VARCHAR2 IS


 l_rule                  VARCHAR2(20);
 l_parameter_list        wf_parameter_list_t := wf_parameter_list_t();
 l_parameter_t           wf_parameter_t:= wf_parameter_t(null, null);
 i_parameter_name        l_parameter_t.name%type;
 i_parameter_value       l_parameter_t.value%type;
 i                       pls_integer;

 l_bank_acct_id          l_parameter_t.value%type;
 l_party_id              l_parameter_t.value%type;
 l_instr_assgn_id        l_parameter_t.value%type;

 BEGIN

   l_parameter_list := p_event.getParameterList();
   IF l_parameter_list is not null THEN
     i := l_parameter_list.FIRST;
     WHILE ( i <= l_parameter_list.LAST )
     LOOP
       i_parameter_name := null;
       i_parameter_value := null;

       i_parameter_name := l_parameter_list(i).getName();
       i_parameter_value := l_parameter_list(i).getValue();

       IF i_parameter_name is not null THEN
         IF  i_parameter_name = 'ExternalBankAccountID' THEN
           l_bank_acct_id := i_parameter_value;
         ELSIF i_parameter_name = 'PartyID' THEN
           l_party_id   := i_parameter_value;
         ELSIF  i_parameter_name = 'InstrumentAssignmentID' THEN
           l_instr_assgn_id := i_parameter_value;
         END IF;
       END IF;

       i := l_parameter_list.NEXT(i);
     END LOOP;
   END IF;

   -- If Update_Payment_Schedules True then only execute WF program

   IF Update_Payment_Schedules (l_bank_acct_id,
                                l_party_id,
                                l_instr_assgn_id,
                                'AP_BANKACCT_INACTIVE_WF_PKG.Rule_Function')
   THEN

     l_rule :=  WF_RULE.Default_Rule(p_subscription,p_event);

    END IF;

   RETURN ('SUCCESS');

 END Rule_Function;

 -- This procedure will be called from Rule_Function and Update the Payment
 -- Schedules for inactivated bank account

 FUNCTION Update_Payment_Schedules (
          P_bank_account_id       NUMBER,
          P_party_id              NUMBER,
          P_instr_assgn_id        NUMBER,
          P_calling_sequence      VARCHAR2) RETURN BOOLEAN IS

   l_party_site_id                NUMBER;
   l_supplier_site_id             NUMBER; /* bug 5000194, 4965233 */
   l_vendor_id                    AP_SUPPLIERS.Vendor_Id%TYPE;
   l_vendor_type_lookup_code      AP_SUPPLIERS.Vendor_Type_Lookup_Code%TYPE;
   l_payment_function             VARCHAR2(80);
   l_org_id                       NUMBER;
   l_currency_code                IBY_EXT_BANK_ACCOUNTS.Currency_Code%TYPE;
   l_extbank_acct_id              NUMBER;

   l_current_calling_sequence     VARCHAR2(2000);
   l_debug_info                   VARCHAR2(2000);
   l_api_name                     CONSTANT VARCHAR2(100) := 'Update_Payment_Schedules';

 BEGIN

  l_current_calling_sequence := p_calling_sequence||'->'||
           'AP_BANKACCT_INACTIVE_WF_PKG.Update_Payment_Shedules';
  --
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'Parameters: '
                     ||' P_bank_account_id: '|| p_bank_account_Id
                     ||', P_party_Id: '||p_party_id
                     ||', P_instr_assgn_id: '||p_instr_assgn_id);
  END IF;

  l_debug_info := 'Deriving Vendor_Site_Id, Org_Id from Iby_Payee_Assigned_Bankacct_v';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  BEGIN
    SELECT payment_function,
           party_site_id,
           supplier_site_id, /* bug 5000194, 4965233 */
           org_id,
           currency_code
    INTO   l_payment_function,
           l_party_site_id,
           l_supplier_site_id,
           l_org_id,
           l_currency_code
    FROM   Iby_Payee_Assigned_Bankacct_V
    WHERE  instr_assignment_id = p_instr_assgn_id
    AND    ext_bank_account_id = p_bank_account_id
    AND    party_id = p_party_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_debug_info := 'Iby_Payee_Assigned_Bankacct_V has no row for Assignment Id';
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
      RETURN FALSE;
  END;

  /* bug 5000194. 4965233 */
  BEGIN
    SELECT vendor_id,
           vendor_type_lookup_code
    INTO   l_vendor_id,
           l_vendor_type_lookup_code
    FROM   ap_suppliers
    WHERE  party_id = p_party_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_debug_info := 'This Payee is not a Supplier';
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
      NULL;
  END;

  l_debug_info := 'Calling Payables wrapper for deriving next available bank '||
                   'account from IBY';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  IF l_vendor_type_lookup_code = 'EMPLOYEE' THEN
    l_extbank_acct_id  := AP_IBY_UTILITY_PKG.Get_Default_Iby_Bank_Acct_Id
                         (l_vendor_id,
                          l_supplier_site_id,
                          l_payment_function,
                          l_org_id,
                          l_currency_code,
                          l_current_calling_sequence);
  ELSE
    l_extbank_acct_id  := AP_IBY_UTILITY_PKG.Get_Default_Iby_Bank_Acct_Id
                         (p_party_id,
                          l_payment_function,
                          l_party_site_id,
                          l_org_id,
                          l_currency_code,
                          l_current_calling_sequence);

  END IF;

  IF l_party_site_id IS NULL THEN

    IF l_org_id IS NOT NULL THEN

      l_debug_info := 'Update Payment Schedules when assignment is inactivated at '
                      ||'party level for specific org: '||l_org_id;
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      UPDATE ap_payment_schedules_all aps
      SET aps.external_bank_account_id = l_extbank_acct_id,
        aps.last_update_date  = SYSDATE,
        aps.last_updated_by   = FND_GLOBAL.user_id,
        aps.last_update_login = FND_GLOBAL.login_id
      WHERE aps.invoice_id IN
           (SELECT DISTINCT ai.invoice_id
            FROM   ap_invoices_all ai, ap_payment_schedules_all aps1
            WHERE  aps1.external_bank_account_id  = P_bank_account_id
            AND    ai.invoice_id                 = aps1.invoice_id
            AND    ai.org_id                     = l_org_id
            AND    ai.payment_status_flag        IN ('N','P')
            AND    ai.cancelled_date             IS NULL
            AND    ai.party_id                  = p_party_id
            AND    (l_supplier_site_id IS NULL
                    OR ai.vendor_site_id = l_supplier_site_id));

    ELSE

      l_debug_info := 'Update Payment Schedules when assignment is inactivated at '
                      ||'party level for all org';
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      UPDATE ap_payment_schedules_all aps
      SET aps.external_bank_account_id = l_extbank_acct_id,
          aps.last_update_date  = SYSDATE,
          aps.last_updated_by   = FND_GLOBAL.user_id,
          aps.last_update_login = FND_GLOBAL.login_id
      WHERE aps.invoice_id IN
           (SELECT DISTINCT ai.invoice_id
            FROM   ap_invoices_all ai, ap_payment_schedules_all aps1
            WHERE  aps1.external_bank_account_id  = P_bank_account_id
            AND    ai.invoice_id                 = aps1.invoice_id
            AND    ai.payment_status_flag        IN ('N','P')
            AND    ai.cancelled_date             IS NULL
            AND    ai.party_id                  = p_party_id
             AND    (l_supplier_site_id IS NULL
                    OR ai.vendor_site_id = l_supplier_site_id));

    END IF;

  ELSE

    l_debug_info := 'Update Payment Schedules when assignment is inactivated at '
                    ||'party site level';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    UPDATE ap_payment_schedules_all aps
    SET aps.external_bank_account_id = l_extbank_acct_id,
        aps.last_update_date  = SYSDATE,
        aps.last_updated_by   = FND_GLOBAL.user_id,
        aps.last_update_login = FND_GLOBAL.login_id
    WHERE aps.invoice_id IN
         (SELECT DISTINCT ai.invoice_id
          FROM   ap_invoices_all ai, ap_payment_schedules_all aps1
          WHERE  aps1.external_bank_account_id  = P_bank_account_id
          AND    ai.invoice_id                 = aps1.invoice_id
          AND    ai.payment_status_flag        IN ('N','P')
          AND    ai.cancelled_date             IS NULL
          AND    ai.party_site_id             = l_party_site_id
          AND    ai.party_id                  = p_party_id);

  END IF;

  RETURN TRUE;

 END Update_Payment_Schedules;

END AP_BANKACCT_INACTIVE_WF_PKG;

/
