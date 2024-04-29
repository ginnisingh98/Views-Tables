--------------------------------------------------------
--  DDL for Package Body OKL_DRILLDOWN_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DRILLDOWN_PUB_PKG" AS
/* $Header: OKLPDRDB.pls 120.3 2007/06/13 13:42:55 abhsaxen noship $ */

  L_MODULE                   FND_LOG_MESSAGES.MODULE%TYPE;
  L_DEBUG_ENABLED            VARCHAR2(10);
  IS_DEBUG_PROCEDURE_ON      BOOLEAN;
  IS_DEBUG_STATEMENT_ON      BOOLEAN;

 /*============================================================================+
 | PROCEDURE:  DRILLDOWN
 | COMMENT:    DRILLDOWN procedure provides a public API for SLA to return
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
 +==========================================================================*/

PROCEDURE DRILLDOWN
(p_application_id      IN            INTEGER DEFAULT NULL
,p_ledger_id           IN            INTEGER DEFAULT NULL
,p_legal_entity_id     IN            INTEGER DEFAULT NULL
,p_entity_code         IN            VARCHAR2 DEFAULT NULL
,p_event_class_code    IN            VARCHAR2 DEFAULT NULL
,p_event_type_code     IN            VARCHAR2 DEFAULT NULL
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

  l_api_name         varchar2(15);
  l_trx_id              varchar2(100);
  l_org_id              varchar2(100);
  l_ledger_id         varchar2(100);
  l_dummy             number;
  l_scs_found        boolean;
  l_func_name       varchar2(50);

  CURSOR c_investor_scs_code (p_trx_id INTEGER)
  IS
  SELECT 1
  FROM OKL_TRX_CONTRACTS TRX, OKC_K_HEADERS_B CHR
  WHERE TRX.ID = p_trx_id
       AND TRX.KHR_ID = CHR.ID
       AND CHR.SCS_CODE = 'INVESTOR';

BEGIN
  l_api_name           := 'DRILLDOWN';
  L_MODULE := 'OKL.PLSQL.OKL_DRILLDOWN_PUB_PKG.DRILLDOWN';
  -- check for logging on PROCEDURE level
  L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
  IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
  -- check for logging on STATEMENT level
  IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

  --write to log
  IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, L_MODULE, 'begin debug call DRILLDOWN');
  END IF;
  IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, L_MODULE || ' Value of API Name', 'l_api_name: ' || l_api_name);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, L_MODULE || ' Value of Transaction ID', 'l_trx_id: ' || l_trx_id);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, L_MODULE || ' Value of event class code', 'p_event_class_code: ' || p_event_class_code);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, L_MODULE || ' Value of event type code', 'p_event_type_code: ' || p_event_type_code);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, L_MODULE || ' Value of entity code', 'p_entity_code: ' || p_entity_code);
  END IF;

  --Check whether application is OKL
  IF (p_application_id = 540) THEN
    l_trx_id := TO_CHAR(p_source_id_int_1);
    p_user_interface_type := 'HTML';
    l_ledger_id := TO_CHAR(p_ledger_id);
    l_org_id := TO_CHAR(p_security_id_int_1);
    --Set the parameters and form the URL for entity code CONTRACTS, TRANSACTIONS AND ASSETS
    IF  (p_entity_code IN ('CONTRACTS', 'TRANSACTIONS')) THEN
      --If event class in GLP or SLP then check the scs_code for that transaction
      --If scs_code is INVESTOR then form the URL pointing to Investor Agreement
      IF (p_event_class_code IN ('GENERAL_LOSS_PROVISION','SPECIFIC_LOSS_PROVISION')) THEN
        OPEN c_investor_scs_code(l_trx_id);
        FETCH c_investor_scs_code INTO l_dummy;
        l_scs_found := c_investor_scs_code%FOUND;
        CLOSE c_investor_scs_code;
        IF l_scs_found THEN
          l_func_name := 'OKL_IA_ACCT_TRANS';
        ELSE
          l_func_name := 'OKL_OP_ACCT_TRANS';
        END IF;
      ELSE
        l_func_name := 'OKL_OP_ACCT_TRANS';
      END IF;
      p_parameters := '/OA_HTML/OA.jsp?OAFunc=' || l_func_name || '&' || 'TRANSACTION_ID=' || l_trx_id
							|| '&' || 'LEDGER_ID=' || l_ledger_id
							|| '&' || 'OKL_ORGANIZATION_ID=' || l_org_id;
    --Set the parameters and form the URL for entity code INVESTOR
    ELSIF (p_entity_code = 'INVESTOR_AGREEMENTS')  THEN
      p_parameters := '/OA_HTML/OA.jsp?OAFunc=OKL_IA_ACCT_TRANS' || '&' || 'TRANSACTION_ID=' || l_trx_id
							|| '&' || 'LEDGER_ID=' || l_ledger_id
							|| '&' || 'OKL_ORGANIZATION_ID=' || l_org_id;
    ELSE
      p_user_interface_type := 'NONE';
    END IF;
  END IF;

  --write to log
  IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, L_MODULE || ' Value of API Name', 'l_api_name: ' || l_api_name);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, L_MODULE || ' Value of parameters', 'p_parameters: ' || p_parameters);
  END IF;
  IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, L_MODULE, 'end debug call DRILLDOWN');
  END IF;

END DRILLDOWN;

END OKL_DRILLDOWN_PUB_PKG;

/
