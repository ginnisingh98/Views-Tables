--------------------------------------------------------
--  DDL for Package Body ZX_GL_TAX_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_GL_TAX_OPTIONS_PKG" AS
/* $Header: zxgltaxoptionb.pls 120.22 2006/09/22 17:00:53 nipatel ship $ */


  -- Logging Infra
  G_PKG_NAME                   CONSTANT VARCHAR2(30) := 'ZX_GL_TAX_OPTIONS_PKG';
  G_CURRENT_RUNTIME_LEVEL      NUMBER;
  G_LEVEL_UNEXPECTED           CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR                CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT                CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE            CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(60) := 'ZX.PLSQL.ZX_GL_TAX_OPTIONS_PKG.';

-- ***** PUBLIC PROCEDURES *****
/*===========================================================================+
 | PROCEDURE
 |    get_default_values
 |
 | IN
 |    p_ledger_id          : Ledger ID
 |    p_org_id             : Organization ID
 |    p_le_id              : Legal Entity ID
 |    p_account_segment    : Account Segment Number
 |    p_account_type       : 'I' for Input Tax Rate Codes migrated from AP
 |                           'O' for Output Tax Rate Codes migrated from AR
 |                           'T'  for newly created Tax Rate Codes
 |    p_trx_date           : Transaction Date
 |
 | OUT
 |    x_default_regime_code     : Tax Regime Code
 |    x_default_tax             : Tax
 |    x_default_tax_status_code : Tax Status Code
 |    x_default_tax_rate_code   : Tax Rate Code
 |    x_default_tax_rate_id     : Tax Rate ID
 |    x_default_rounding_code   : Rounding Code
 |    x_default_incl_tax_flag   : Inclusive Tax Flag
 |    x_return_status           : Either 'S' (Success), 'E' (Known Error),
 |                                'U' (Unexpected Error/Exception)
 |    x_msg_out                 : Output Message
 |                                When x_return_status is 'E' x_msg_out returns
 |                                message code.
 |                                When x_return_status is 'U' x_msg_out returns
 |                                SQLCODE.
 |                                When x_return_status is 'S' x_msg_out returns
 |                                NULL.
 |
 | DESCRIPTION
 |     This routine returns Regime to Rate tax information for a particular
 |     account segment value or a ledger.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |
 | NOTES
 | 1. Mapping between tax_type_code at journal line and tax_class in setup
 |
 |    TAX_TYPE_CODE    TAX_CLASS
 |    -------------    --------------
 |    'I'              'INPUT'
 |    'O'              'OUTPUT'
 |    'T'              NULL
 |    NULL             NON_TAXABLE
 |
 |
 | MODIFICATION HISTORY
 | 04/08/2005   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/
PROCEDURE get_default_values
(   p_api_version      IN   NUMBER  DEFAULT NULL,
    p_ledger_id        IN   NUMBER,
    p_org_id           IN   NUMBER,
    p_le_id            IN   NUMBER,
    p_account_segment  IN   VARCHAR2,
    p_account_type     IN   VARCHAR2,
    p_trx_date         IN   DATE,
    x_default_regime_code       OUT   NOCOPY  VARCHAR2,
    x_default_tax               OUT   NOCOPY  VARCHAR2,
    x_default_tax_status_code   OUT   NOCOPY  VARCHAR2,
    x_default_tax_rate_code     OUT   NOCOPY  VARCHAR2,
    x_default_tax_rate_id       OUT   NOCOPY  NUMBER,
    x_default_rounding_code     OUT   NOCOPY  VARCHAR2,
    x_default_incl_tax_flag     OUT   NOCOPY  VARCHAR2,
    x_return_status             OUT   NOCOPY  VARCHAR2,
    x_msg_out                   OUT   NOCOPY  VARCHAR2
) IS

  -- ***** CURSORS *****
  CURSOR acct_rate_cur (p_tax_class         VARCHAR2,
                        p_ledger_id         NUMBER,
                        p_account_segment   VARCHAR2)
  IS
  SELECT  acr.tax_regime_code,
          acr.tax,
          acr.tax_status_code,
          acr.tax_rate_code,
          nvl(rates.source_id, rates.tax_rate_id),
          acr.tax_class
  FROM    zx_account_rates       acr,
          zx_sco_rates           rates
  WHERE   rates.tax_regime_code = acr.tax_regime_code
  AND     rates.tax = acr.tax
  AND     rates.tax_status_code = acr.tax_status_code
  AND     rates.tax_rate_code = acr.tax_rate_code
  AND     rates.active_flag = 'Y'
  AND     nvl(acr.tax_class, p_tax_class) = p_tax_class
  AND     acr.ledger_id = p_ledger_id
  AND     acr.account_segment_value = p_account_segment
  AND     p_trx_date >= rates.effective_from and
          (p_trx_date <= rates.effective_to OR rates.effective_to IS NULL)
  AND exists ( select 1 from zx_sco_taxes taxes
      where taxes.tax_regime_code = rates.tax_regime_code
        AND taxes.tax = rates.tax
        AND taxes.live_for_applicability_flag = 'Y'
        AND taxes.live_for_processing_flag = 'Y'
        AND nvl(taxes.offset_tax_flag,'N') <> 'Y');


  CURSOR acct_rate_sob_cur (p_tax_class         VARCHAR2,
                            p_ledger_id         NUMBER)
  IS
  SELECT  acr.tax_regime_code,
          acr.tax,
          acr.tax_status_code,
          acr.tax_rate_code,
          nvl(rates.source_id, rates.tax_rate_id),
          acr.tax_class
  FROM    zx_account_rates       acr,
          zx_sco_rates           rates
  WHERE   rates.tax_regime_code = acr.tax_regime_code
  AND     rates.tax = acr.tax
  AND     rates.tax_status_code = acr.tax_status_code
  AND     rates.tax_rate_code = acr.tax_rate_code
  AND     rates.active_flag = 'Y'
  AND     nvl(acr.tax_class, p_tax_class) = p_tax_class
  AND     acr.ledger_id = p_ledger_id
  AND     acr.account_segment_value IS NULL
  AND     p_trx_date >= rates.effective_from and
          (p_trx_date <= rates.effective_to OR rates.effective_to IS NULL)
  AND exists ( select 1 from zx_sco_taxes taxes
      where taxes.tax_regime_code = rates.tax_regime_code
        AND taxes.tax = rates.tax
        AND taxes.live_for_applicability_flag = 'Y'
        AND taxes.live_for_processing_flag = 'Y'
        AND nvl(taxes.offset_tax_flag,'N') <> 'Y');

  -- ***** VARIABLES *****
  l_tax_type_code          VARCHAR2(30);
  l_tax_class              VARCHAR2(30);
  l_tax_class_tmp          VARCHAR2(30);
  l_tax_regime_code        VARCHAR2(30);
  l_tax                    VARCHAR2(50);
  l_tax_status_code        VARCHAR2(30);
  l_tax_rate_code          VARCHAR2(50);
  l_tax_rate_id            NUMBER(15);
  l_content_owner_id       NUMBER(15);
  l_rounding_rule_code     VARCHAR2(30);
  l_incl_tax_flag          VARCHAR2(1);
  l_ledger_flag            VARCHAR2(1);
  l_return_status          VARCHAR2(1);
  l_msg_out                VARCHAR2(30);

   -- Logging Infra
   l_api_name       CONSTANT   VARCHAR2(30) := 'GET_DEFAULT_VALUES';
   l_api_version    CONSTANT   NUMBER := 1.0;
   l_procedure_name CONSTANT VARCHAR2(30) := 'GET_DEFAULT_VALUES';
   l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
   -- Logging Infra
   l_set_security_context_flag VARCHAR2(1);

BEGIN

  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'get_default_values(+)');
  END IF;
  -- Logging Infra: Break point input parameters
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'B: IN: api_version=' || p_api_version ||
                   ', ledger_id=' || p_ledger_id ||
                   ', org_id=' || p_org_id ||
                   ', account_segment=' || p_account_segment ||
                   ', account_type=' || p_account_type ||
                   ', trx_date=' || p_trx_date;
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                    G_MODULE_NAME || l_procedure_name,
                    l_log_msg);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_account_type IN ('E', 'I') THEN
     l_tax_class_tmp := 'INPUT';
  ELSIF p_account_type IN ('R' , 'O') THEN
     l_tax_class_tmp := 'OUTPUT';
  ELSIF p_account_type = 'T' THEN
     l_tax_class_tmp := p_account_type;
  END IF;

  IF  ZX_SECURITY.g_first_party_org_id is NULL THEN
     l_set_security_context_flag := 'Y';
  ELSE
     l_set_security_context_flag := 'N';
  END IF;

  IF l_set_security_context_flag = 'Y' Then
    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,
                      G_MODULE_NAME || l_procedure_name,
                      'Setting Security Context');
    END IF;

    ZX_SECURITY.set_security_context(p_le_id, p_org_id, NULL, x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     -- Logging Infra: Statement level
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        'Error Setting Security Context');
      END IF;
      Return;
    END IF;
  END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'Fetching default tax rate info');
  END IF;

  -- Account Level
    -- Logging Infra: Break point acct_rate_cur
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'B: CUR: acct_rate_cur: tax_class=' || l_tax_class_tmp ||
                     ', ledger_id=' || p_ledger_id ||
                     ', account_segment=' || p_account_segment;
        FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      l_log_msg);
    END IF;

    OPEN acct_rate_cur (l_tax_class_tmp,
                        p_ledger_id,
                        p_account_segment);
    FETCH acct_rate_cur INTO x_default_regime_code,
                             x_default_tax,
                             x_default_tax_status_code,
                             x_default_tax_rate_code,
                             x_default_tax_rate_id,
                             l_tax_class;
    IF acct_rate_cur%FOUND THEN
     l_ledger_flag := 'N';
    ELSE
     l_ledger_flag := 'Y';
    END IF;

    CLOSE acct_rate_cur;

    -- Logging Infra: Break point acct_rate_cur
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'B: CUR: acct_rate_cur: tax_regime_code=' || x_default_regime_code ||
                     ', tax=' || x_default_tax ||
                     ', tax_status_code=' || x_default_tax_status_code ||
                     ', tax_rate_code=' || x_default_tax_rate_code ||
                     ', tax_rate_id=' || x_default_tax_rate_id ||
                     ', tax_class=' || l_tax_class;
        FND_LOG.STRING(G_LEVEL_STATEMENT,
                       G_MODULE_NAME || l_procedure_name,
                       l_log_msg);
    END IF;

  -- Ledger / Set Of Books Level
  IF l_ledger_flag = 'Y' THEN

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'B: CUR: acct_rate_sob_cur: tax_class=' || l_tax_class_tmp ||
                     ', ledger_id=' || p_ledger_id;
        FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      l_log_msg);
    END IF;

    OPEN acct_rate_sob_cur (l_tax_class_tmp,
                            p_ledger_id);

    FETCH acct_rate_sob_cur INTO x_default_regime_code,
                                 x_default_tax,
                                 x_default_tax_status_code,
                                 x_default_tax_rate_code,
                                 x_default_tax_rate_id,
                                 l_tax_class;
    CLOSE acct_rate_sob_cur;

    -- Logging Infra: Break point acct_rate_cur
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'B: CUR: acct_rate_sob_cur: tax_regime_code=' || x_default_regime_code ||
                     ', tax=' || x_default_tax ||
                     ', tax_status_code=' || x_default_tax_status_code ||
                     ', tax_rate_code=' || x_default_tax_rate_code ||
                     ', tax_rate_id=' || x_default_tax_rate_id ||
                     ', tax_class=' || l_tax_class;
        FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      l_log_msg);
    END IF;
  END IF;


  IF l_set_security_context_flag = 'Y' Then

    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,
                      G_MODULE_NAME || l_procedure_name,
                      'Resetting First Party Org context to NULL');
    END IF;

    ZX_SECURITY.G_FIRST_PARTY_ORG_ID := NULL;
     --dbms_session.set_context('my_ctx','FIRSTPTYORGID',to_char(ZX_SECURITY.G_FIRST_PARTY_ORG_ID));
     ZX_SECURITY.name_value('FIRSTPTYORGID',to_char(ZX_SECURITY.G_FIRST_PARTY_ORG_ID));
  END IF;

  -- Setting l_tax_type_code to pass to APIs that default rounding
  -- rule and default tax include flag

  IF l_tax_class IS NULL THEN
     l_tax_type_code := 'T';
  ELSIF l_tax_class = 'INPUT' THEN
     l_tax_type_code := 'I';
  ELSIF l_tax_class = 'OUTPUT' THEN
     l_tax_type_code := 'O';
  END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'Fetching default rounding rule');
  END IF;

  GET_ROUNDING_RULE_CODE(1.0,
                         p_ledger_id,
                         p_org_id,
                         p_le_id,
                         l_tax_type_code,
                         x_default_rounding_code,
                         x_return_status,
                         x_msg_out);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
   -- Logging Infra: Statement level
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      'Error from API to default rounding rule');
    END IF;
    Return;
  END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'Fetching default tax include flag');
  END IF;

  GET_DEFAULT_TAX_INCLUDE_FLAG(1.0,
                               p_ledger_id,
                               p_org_id,
                               p_le_id,
                               p_account_segment,
                               l_tax_type_code,
                               x_default_incl_tax_flag,
                               x_return_status,
                               x_msg_out);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
   -- Logging Infra: Statement level
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      'Error from API to default tax include flag');
    END IF;
    Return;
  END IF;

  IF x_default_regime_code IS NULL THEN
    IF x_default_rounding_code IS NULL THEN
      -- Logging Infra: Break point acct_rate_sob_cur
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
	  l_log_msg := 'B: tax_regime_code/rounding_rule_code IS NULL';
	  FND_LOG.STRING(G_LEVEL_STATEMENT,
			G_MODULE_NAME || l_procedure_name,
			l_log_msg);
      END IF;
      l_return_status := FND_API.G_RET_STS_ERROR;
      l_msg_out := 'ZX_GL_ROUNDING_CODE_NULL';
      Return;
    ELSE
      -- ledger level information (rounding_rule_code) has been derived
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
	  l_log_msg := 'B: tax_regime_code IS NULL but rounding_rule_code IS NOT NULL';
	  FND_LOG.STRING(G_LEVEL_STATEMENT,
			G_MODULE_NAME || l_procedure_name,
			l_log_msg);
      END IF;
    END IF;
  END IF;

  /* comment out as the user should be able to continue to enter journal even if
     default value is not found. This is consistent with 11i behaviour.
  IF x_default_tax_rate_id IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_out := 'ZX_GL_RATE_ID_NULL';
     -- Logging Infra: Statement level
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        x_msg_out);
      END IF;
      Return;
  END IF;
  */

   -- Logging Infra: Break point output parameters
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
       l_log_msg := 'B: OUT: return_status=' || x_return_status ||
                    ', tax_regime_code=' || x_default_regime_code ||
                    ', tax=' || x_default_tax ||
                    ', tax_status_code=' || x_default_tax_status_code ||
                    ', tax_rate_code=' || x_default_tax_rate_code ||
                    ', rounding_rule_code=' || x_default_rounding_code ||
                    ', incl_tax_flag=' || x_default_incl_tax_flag ||
                    ', tax_rate_id=' || x_default_tax_rate_id;
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME || l_procedure_name,
                     l_log_msg);
   END IF;
   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME,
                     'get_default_value(-)');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_out := TO_CHAR(SQLCODE);
    -- Logging Infra:
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      TO_CHAR(SQLCODE) || ': ' || SQLERRM);
    END IF;
    app_exception.raise_exception;
END get_default_values;


/*===========================================================================+
 | PROCEDURE
 |    get_tax_rate_and_account
 |
 | IN
 |    p_ledger_id          : Ledger ID
 |    p_org_id             : Organization ID
 |    p_tax_type_code      : 'I' for Input Tax Rate Codes migrated from AP
 |                           'O' for Output Tax Rate Codes migrated from AR
 |                           'T' for newly created Tax Rate Codes
 |    p_tax_rate_id        : Tax Rate ID
 |
 | OUT
 |    x_tax_rate_pct       : Tax Percentage Rate
 |    x_tax_account_ccid   : Tax Account CCID
 |    x_return_status      : Return Status. See get_default_value for details.
 |    x_msg_out            : Output Message. See get_default_value for
 |                           details.
 |
 | DESCRIPTION
 |     This routine returns tax percentage rate and its accounting CCID for
 |     a particular tax_rate_id.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | 04/08/2005   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/
PROCEDURE get_tax_rate_and_account
(   p_api_version       IN   NUMBER  DEFAULT NULL,
    p_ledger_id         IN   NUMBER,
    p_org_id            IN   NUMBER,
    p_tax_type_code     IN   VARCHAR2,
    p_tax_rate_id       IN   NUMBER,
    x_tax_rate_pct      OUT  NOCOPY   NUMBER,
    x_tax_account_ccid  OUT  NOCOPY   NUMBER,
    x_return_status     OUT  NOCOPY   VARCHAR2,
    x_msg_out           OUT  NOCOPY   VARCHAR2
) IS

  -- ***** CURSORS *****
  CURSOR get_pct_rate_ccid_cur (p_tax_rate_id  NUMBER,
                                p_org_id       NUMBER,
                                p_ledger_id    NUMBER)
  IS
  SELECT  zrb.percentage_rate,
          NVL(za.tax_account_ccid, za.non_rec_account_ccid)
          -- Bug 4766614
          -- Added NVL so that when tax_account_ccid is null
          -- the API returns non_rec_account_ccid
  FROM    zx_rates_b zrb,
          zx_accounts  za
  WHERE   nvl(zrb.source_id, zrb.tax_rate_id) = p_tax_rate_id
  AND     za.internal_organization_id(+) = p_org_id
  AND     za.ledger_id(+) = p_ledger_id
  AND     za.tax_account_entity_id(+) = zrb.tax_rate_id
  AND     za.tax_account_entity_code(+) = 'RATES';

  -- ***** VARIABLES *****
  l_pct_rate            NUMBER;
  l_tax_account_ccid    NUMBER;
  l_tax_rate_id         NUMBER(15);
  l_source_id           NUMBER(15);
  l_return_status       VARCHAR2(1);
  l_msg_out             VARCHAR2(30);

  -- Logging Infra
  l_api_name       CONSTANT   VARCHAR2(30) := 'GET_TAX_RATE_AND_ACCOUNT';
  l_api_version    CONSTANT   NUMBER := 1.0;
  l_procedure_name CONSTANT VARCHAR2(30) := 'GET_TAX_RATE_AND_ACCOUNT';
  l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  -- Logging Infra

BEGIN
  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'get_tax_rate_and_account(+)');
  END IF;
  -- Logging Infra: Break point input parameters
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'B: IN: api_version=' || p_api_version ||
                   ', tax_type_code=' || p_tax_type_code ||
                   ', tax_rate_id=' || p_tax_rate_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                    G_MODULE_NAME || l_procedure_name,
                    l_log_msg);
  END IF;

  OPEN get_pct_rate_ccid_cur (p_tax_rate_id, p_org_id, p_ledger_id);

  FETCH get_pct_rate_ccid_cur INTO l_pct_rate,
                                   l_tax_account_ccid;
  IF get_pct_rate_ccid_cur%FOUND THEN
    l_return_status := FND_API.G_RET_STS_SUCCESS;
  ELSE
    l_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_out := 'ZX_GL_OUT_RATE_CCID_NOTFOUND';
  END IF;

  CLOSE get_pct_rate_ccid_cur;

  -- Logging Infra: Break point get_pct_rate_ccid_cur
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'B: CUR: get_pct_rate_ccid_cur: pct_rate=' || l_pct_rate ||
                   ', tax_account_ccid=' || l_tax_account_ccid;
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                    G_MODULE_NAME || l_procedure_name,
                    l_log_msg);
  END IF;

  x_tax_rate_pct       := l_pct_rate;
  x_tax_account_ccid   := l_tax_account_ccid;
  x_return_status      := l_return_status;
  x_msg_out            := l_msg_out;

  -- Logging Infra: Break point output parameters
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'B: OUT: tax_rate_pct=' || l_pct_rate ||
                   ', tax_account_ccid=' || l_tax_account_ccid ||
                   ', return_status=' || l_return_status;
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                    G_MODULE_NAME || l_procedure_name,
                    l_log_msg);
  END IF;
  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'get_tax_rate_and_account(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_out := TO_CHAR(SQLCODE);
    -- Logging Infra:
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      TO_CHAR(SQLCODE) || ': ' || SQLERRM);
    END IF;
    app_exception.raise_exception;
END get_tax_rate_and_account;


/*===========================================================================+
 | PROCEDURE
 |    get_tax_ccid
 |
 | IN
 |    p_tax_rate_id        : Tax Rate ID
 |    p_org_id             : Organization ID
 |    p_ledger_id          : Ledger ID
 |
 | OUT
 |    x_tax_account_ccid   : Tax Account CCID
 |    x_return_status      : Return Status. See get_default_value for details.
 |    x_msg_out            : Output Message. See get_default_value for
 |                           details.
 |
 | DESCRIPTION
 |     This routine returns tax accounting CCID for a particular tax_rate_id.
 |
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | 04/08/2005   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/
PROCEDURE get_tax_ccid
(  p_api_version        IN   NUMBER,
   p_tax_rate_id        IN   NUMBER,
   p_org_id             IN   NUMBER,
   p_ledger_id          IN   NUMBER,
   x_tax_account_ccid   OUT  NOCOPY   NUMBER,
   x_return_status      OUT  NOCOPY   VARCHAR2,
   x_msg_out            OUT  NOCOPY   VARCHAR2
) IS

  -- ***** CURSORS *****
  CURSOR tax_acct_cur (p_tax_rate_id   NUMBER,
                       p_ledger_id     NUMBER,
                       p_org_id        NUMBER)
  IS
  SELECT  NVL(tax_account_ccid, non_rec_account_ccid)
          -- Bug 4766614
          -- Added NVL so that when tax_account_ccid is null
          -- the API returns non_rec_account_ccid
  FROM    zx_accounts   za, zx_rates_b rates
  WHERE   nvl(rates.source_id, rates.tax_rate_id) = p_tax_rate_id
  AND     za.tax_account_entity_id(+) = rates.tax_rate_id
  AND     za.tax_account_entity_code(+) = 'RATES'
  AND     za.ledger_id(+) = p_ledger_id
  AND     za.internal_organization_id(+) = p_org_id;

  -- ***** VARIABLES *****

  -- Logging Infra
  l_api_name       CONSTANT   VARCHAR2(30) := 'GET_TAX_CCID';
  l_api_version    CONSTANT   NUMBER := 1.0;
  l_procedure_name CONSTANT VARCHAR2(30) := 'GET_TAX_CCID';
  l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  -- Logging Infra

BEGIN
  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'get_tax_ccid(+)');
  END IF;

  -- Logging Infra: Break point input parameters
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'B: IN: api_version=' || p_api_version ||
                   ', tax_rate_id=' || p_tax_rate_id ||
                   ', org_id=' || p_org_id ||
                   ', ledger_id=' || p_ledger_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                    G_MODULE_NAME || l_procedure_name,
                    l_log_msg);
  END IF;

  OPEN tax_acct_cur (p_tax_rate_id,
                     p_ledger_id,
                     p_org_id);

  FETCH tax_acct_cur INTO x_tax_account_ccid;

  IF tax_acct_cur%FOUND THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  ELSE
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_out := 'ZX_GL_TAXCCID_NOT_FOUND';
  END IF;

  CLOSE tax_acct_cur;

  -- Logging Infra: Break point output parameters
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'B: OUT: tax_account_ccid=' || x_tax_account_ccid ||
                   ', return_status=' || x_return_status;
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                    G_MODULE_NAME || l_procedure_name,
                    l_log_msg);
  END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'get_tax_ccid(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_out := TO_CHAR(SQLCODE);
    -- Logging Infra:
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      TO_CHAR(SQLCODE) || ': ' || SQLERRM);
    END IF;
    app_exception.raise_exception;
END get_tax_ccid;


/*===========================================================================+
 | PROCEDURE
 |    get_tax_rate_id
 |
 | IN
 |    p_org_id             : Organization ID
 |    p_le_id              : Legal Entity ID
 |    p_tax_rate_code      : Tax Rate Code
 |    p_trx_date           : Transaction Date
 |    p_tax_type_code      : 'I' for Input Tax Rate Codes migrated from AP
 |                           'O' for Output Tax Rate Codes migrated from AR
 |                           'T' for newly created Tax Rate Codes
 |
 | OUT
 |    p_tax_type_code      : 'I' for Input Tax Rate Codes migrated from AP
 |                           'O' for Output Tax Rate Codes migrated from AR
 |                           'T' for newly created Tax Rate Codes
 |    x_tax_rate_id        : Tax Rate ID
 |    x_return_status      : Return Status. See get_default_value for details.
 |    x_msg_out            : Output Message. See get_default_value for details.
 |
 | DESCRIPTION
 |     This routine returns tax rate ID for active tax rate code at a particular
 |     point in time.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | 04/08/2005   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/
PROCEDURE get_tax_rate_id
(   p_api_version       IN   NUMBER DEFAULT NULL,
    p_org_id            IN   NUMBER,
    p_le_id             IN   NUMBER,
    p_tax_rate_code     IN   VARCHAR2,
    p_trx_date          IN   DATE,
    p_tax_type_code     IN OUT NOCOPY   VARCHAR2,
    x_tax_rate_id       OUT    NOCOPY   NUMBER,
    x_return_status     OUT    NOCOPY   VARCHAR2,
    x_msg_out           OUT    NOCOPY   VARCHAR2
) IS

  -- ***** CURSORS *****

  --
  --  IF tax_type_code IS 'T'
  --             THEN tax_class is NULL
  --
  -- This is the case for GL Tax Options records newly created after migration.
  --
  --
  --
  CURSOR rate_id_for_null_type_cur (p_tax_rate_code   VARCHAR2,
                                    p_trx_date        DATE)
  IS
  SELECT   rates.tax_rate_id,
           rates.tax_class
  FROM     zx_sco_rates rates,
           zx_taxes_b   taxes
  WHERE    rates.tax_rate_code = p_tax_rate_code
  AND      p_trx_date >= rates.effective_from
  AND      p_trx_date <= NVL(rates.effective_to, p_trx_date)
  AND      nvl(rates.active_flag,'Y') = 'Y'
  AND      rates.rate_type_code = 'PERCENTAGE'
  AND      taxes.tax_regime_code = rates.tax_regime_code
  AND      taxes.tax = rates.tax
  AND      taxes.source_tax_flag = 'Y'
  AND      nvl(taxes.offset_tax_flag, 'N') <> 'Y'
  AND      rates.tax_jurisdiction_code IS NULL;


  --
  -- Assumption: IF tax_type_code IS NOT NULL
  --             THEN tax_class IS NOT NULL
  --
  -- This is the case for migrated GL Tax Options records.
  --
  CURSOR rate_id_for_mig_cur (p_tax_rate_code   VARCHAR2,
                              p_tax_class       VARCHAR2,
                              p_trx_date        DATE)
  IS
  SELECT  rates.tax_rate_id
  FROM    zx_sco_rates rates,
          zx_taxes_b   taxes
  WHERE    rates.tax_rate_code = p_tax_rate_code
  AND      p_trx_date >= rates.effective_from
  AND      p_trx_date <= NVL(rates.effective_to, p_trx_date)
  AND      nvl(rates.active_flag,'Y') = 'Y'
  AND      rates.rate_type_code = 'PERCENTAGE'
  AND      taxes.tax_regime_code = rates.tax_regime_code
  AND      taxes.tax = rates.tax
  AND      taxes.source_tax_flag = 'Y'
  AND      nvl(taxes.offset_tax_flag, 'N') <> 'Y'
  AND      rates.tax_jurisdiction_code IS NULL
  AND      rates.tax_class = p_tax_class;

  -- ***** VARIABLES *****
  l_tax_type_code   VARCHAR2(1);
  l_tax_class       VARCHAR2(30);
  l_tax_rate_id     NUMBER(15);
  l_return_status   VARCHAR2(1);

  -- Logging Infra
  l_api_name       CONSTANT   VARCHAR2(30) := 'GET_TAX_RATE_ID';
  l_api_version    CONSTANT   NUMBER := 1.0;
  l_procedure_name CONSTANT VARCHAR2(30) := 'GET_TAX_RATE_ID';
  l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  -- Logging Infra
  l_set_security_context_flag VARCHAR2(1);

BEGIN
  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'get_tax_rate_id(+)');
  END IF;
  -- Logging Infra: Break point input parameters
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'B: IN: api_version=' || p_api_version ||
                   ', org_id=' || p_org_id ||
                   ', tax_rate_code=' || p_tax_rate_code ||
                   ', trx_date=' || p_trx_date ||
                   ', tax_type_code=' || p_tax_type_code;
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                    G_MODULE_NAME || l_procedure_name,
                    l_log_msg);
  END IF;


  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_tax_rate_code = 'STD_AR_INPUT' THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_out := 'ZX_GL_INVALID_TAX_RATE_CODE';
    -- Logging Infra:
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      'p_tax_rate_code is STD_AR_INPUT');
    END IF;
    Return;
  END IF;


  IF  ZX_SECURITY.g_first_party_org_id is NULL THEN
     l_set_security_context_flag := 'Y';
  ELSE
     l_set_security_context_flag := 'N';
  END IF;

  IF l_set_security_context_flag = 'Y' Then

      -- Logging Infra: Procedure level
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME || l_procedure_name,
                        'Setting Security Context');
      END IF;

      ZX_SECURITY.set_security_context(p_le_id, p_org_id, NULL, x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        -- Logging Infra: Statement level
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_procedure_name,
                          'Error Setting Security Context');
        END IF;
        Return;
      END IF;

  END IF; -- l_set_security_context_flag

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'Fetching Tax Rate Id');
  END IF;

  IF p_tax_type_code IS NULL OR p_tax_type_code = 'T' THEN
    OPEN rate_id_for_null_type_cur (p_tax_rate_code,
                                    p_trx_date);
    FETCH rate_id_for_null_type_cur INTO l_tax_rate_id,
                                         l_tax_class;
    CLOSE rate_id_for_null_type_cur;

    IF l_tax_class IS NULL THEN
      p_tax_type_code := 'T';
    ELSIF l_tax_class = 'INPUT' THEN
      p_tax_type_code := 'I';
    ELSIF l_tax_class = 'OUTPUT' THEN
      p_tax_type_code := 'O';
    END IF;

    -- Logging Infra: Break point rate_id_for_null_type_cur
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'B: CUR: rate_id_for_null_type: tax_rate_id=' || l_tax_rate_id ||
                     ', tax_type_code=' || p_tax_type_code;
        FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      l_log_msg);
    END IF;
  ELSIF p_tax_type_code IN ('I', 'O') THEN

    IF p_tax_type_code = 'I' THEN
      l_tax_class := 'INPUT';
    ELSIF p_tax_type_code = 'O' THEN
      l_tax_class := 'OUTPUT';
    END IF;

    OPEN rate_id_for_mig_cur (p_tax_rate_code,
                              l_tax_class,
                              p_trx_date);
    FETCH rate_id_for_mig_cur INTO l_tax_rate_id;
    CLOSE rate_id_for_mig_cur;

    -- Logging Infra: Break point rate_id_for_mig_cur
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'B: CUR: rate_id_for_mig_cur: tax_rate_id=' || l_tax_rate_id ||
                     ', tax_type_code=' || p_tax_type_code;
        FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      l_log_msg);
    END IF;

  END IF;

  x_tax_rate_id   := l_tax_rate_id;

  -- Logging Infra: Break point output parameters
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'B: OUT: tax_type_code=' || l_tax_type_code ||
                   ', tax_rate_id=' || l_tax_rate_id ||
                   ', return_status=' || x_return_status;
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                    G_MODULE_NAME || l_procedure_name,
                    l_log_msg);
  END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'Resetting First Party Org context to NULL');
  END IF;

  IF l_set_security_context_flag = 'Y' Then
    ZX_SECURITY.G_FIRST_PARTY_ORG_ID := NULL;
     --dbms_session.set_context('my_ctx','FIRSTPTYORGID',to_char(ZX_SECURITY.G_FIRST_PARTY_ORG_ID));
     ZX_SECURITY.name_value('FIRSTPTYORGID',to_char(ZX_SECURITY.G_FIRST_PARTY_ORG_ID));
  END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'get_tax_rate_id(-)');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_out := TO_CHAR(SQLCODE);
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      TO_CHAR(SQLCODE) || ': ' || SQLERRM);
    END IF;
    app_exception.raise_exception;
END get_tax_rate_id;



/*===========================================================================+
 | PROCEDURE
 |    get_tax_code
 |
 | IN
 |
 | OUT
 |
 | DESCRIPTION
 |    Will be obsolete.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | 04/08/2005   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/
PROCEDURE get_tax_code
(   p_api_version       IN   NUMBER  DEFAULT NULL,
    p_org_id            IN   NUMBER,
    p_tax_type_code     IN   VARCHAR2,
    p_tax_rate_id       IN   NUMBER,
    x_tax_rate_code     OUT  NOCOPY   VARCHAR2,
    x_return_status     OUT  NOCOPY   VARCHAR2,
    x_msg_out           OUT  NOCOPY   VARCHAR2
) IS
BEGIN
  NULL;
END  get_tax_code;


/*===========================================================================+
 | PROCEDURE
 |    get_tax_rate_code
 |
 | IN
 |    p_tax_type_code  :  'I' for Input Tax Rate Codes migrated from AP
 |                        'O' for Output Tax Rate Codes migrated from AR
 |                        'T' for newly created Tax Rate Codes
 |
 |    p_tax_rate_id    :  Tax Rate ID
 |
 | OUT
 |    x_tax_rate_code  :  Tax Rate Code
 |
 | DESCRIPTION
 |    This routine returns tax rate code for a particular tax_rate_id.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | 04/08/2005   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/
PROCEDURE get_tax_rate_code
(   p_api_version       IN   NUMBER  DEFAULT NULL,
    p_tax_type_code     IN   VARCHAR2,
    p_tax_rate_id       IN   NUMBER,
    x_tax_rate_code     OUT  NOCOPY   VARCHAR2,
    x_return_status     OUT  NOCOPY   VARCHAR2,
    x_msg_out           OUT  NOCOPY   VARCHAR2
) IS

  -- ***** CURSORS *****
  CURSOR get_tax_rate_code_cur (p_tax_rate_id  NUMBER)
  IS
  SELECT  zrb.tax_rate_code
  FROM    zx_rates_b zrb
  WHERE   zrb.tax_rate_id = p_tax_rate_id;

  CURSOR get_source_rate_code_cur (p_tax_rate_id  NUMBER)
  IS
  SELECT  zrb.tax_rate_code
  FROM    zx_rates_b zrb
  WHERE   zrb.source_id = p_tax_rate_id;

  -- ***** VARIABLES *****
  l_tax_rate_code       VARCHAR2(50);
  l_tax_rate_id         NUMBER(15);
  l_source_id           NUMBER(15);
  l_return_status       VARCHAR2(1);
  l_source_indicator    VARCHAR2(1);

  -- Logging Infra
  l_api_name       CONSTANT   VARCHAR2(30) := 'GET_TAX_RATE_CODE';
  l_api_version    CONSTANT   NUMBER := 1.0;
  l_procedure_name CONSTANT   VARCHAR2(30) := 'GET_TAX_RATE_CODE';
  l_log_msg                   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  -- Logging Infra

BEGIN
  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'get_tax_rate_code(+)');
  END IF;
  -- Logging Infra: Break point input parameters
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'B: IN: api_version=' || p_api_version ||
                   ', tax_type_code=' || p_tax_type_code ||
                   ', tax_rate_id=' || p_tax_rate_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                    G_MODULE_NAME || l_procedure_name,
                    l_log_msg);
  END IF;

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_tax_type_code = 'I' THEN

    OPEN get_source_rate_code_cur (p_tax_rate_id);
    FETCH get_source_rate_code_cur INTO l_tax_rate_code;
    IF get_source_rate_code_cur%FOUND THEN
       l_source_indicator := 'Y';
    ELSE
       l_source_indicator := 'N';
    END IF;
    CLOSE get_source_rate_code_cur;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'B: CUR: get_source_rate_code_cur: tax_rate_code=' ||
                   l_tax_rate_code;
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                    G_MODULE_NAME || l_procedure_name,
                    l_log_msg);
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                    G_MODULE_NAME || l_procedure_name,
                    'l_source_indicator : ' || l_source_indicator);

    END IF;

  ELSIF p_tax_type_code = 'O' or p_tax_type_code = 'T' THEN

    l_source_indicator := 'N';

  ELSE

    l_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_out := 'ZX_GL_INVALID_PARAM';
    -- Logging Infra:
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'B: Unexpected tax_type_code';
        FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      l_log_msg);
    END IF;
    Return;

  END IF;

  IF l_source_indicator = 'N' THEN

    OPEN get_tax_rate_code_cur (p_tax_rate_id);
    FETCH get_tax_rate_code_cur INTO l_tax_rate_code;
    CLOSE get_tax_rate_code_cur;

  END IF;

  -- Logging Infra: Break point get_tax_rate_code_cur
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'B: CUR: get_tax_rate_code_cur: tax_rate_code=' || l_tax_rate_code;
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                    G_MODULE_NAME || l_procedure_name,
                    l_log_msg);

  END IF;

  x_tax_rate_code      := l_tax_rate_code;
  x_return_status      := l_return_status;

  -- Logging Infra: Break point output parameters
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'B: OUT: tax_rate_code=' || l_tax_rate_code ||
                   ', return_status=' || l_return_status;
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                    G_MODULE_NAME || l_procedure_name,
                    l_log_msg);
  END IF;

 -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'get_tax_rate_and_account(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_out := TO_CHAR(SQLCODE);
    -- Logging Infra:
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      TO_CHAR(SQLCODE) || ': ' || SQLERRM);
    END IF;
    app_exception.raise_exception;
END get_tax_rate_code;

/*===========================================================================+
 | PROCEDURE
 |    get_rouding_rule_code
 |
 | IN
 |    p_api_version    : API Version
 |    p_ledger_id      : Ledger ID
 |    p_org_id         : Org ID
 |    p_le_id          : Legal Entity ID
 |    p_tax_class      : Tax Class/Tax Type
 |
 | OUT
 |    x_rouding_rule_code  :  Tax Rate Code
 |    x_return_status      :  Return Status
 |
 | DESCRIPTION
 |    This routine returns rounding_rule_code defined for a ledger.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | 06/30/2005   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/

PROCEDURE get_rounding_rule_code
( p_api_version         IN  NUMBER DEFAULT NULL,
  p_ledger_id           IN  NUMBER,
  p_org_id              IN  NUMBER,
  p_le_id               IN  NUMBER,
  p_tax_class           IN  VARCHAR2,
  x_rounding_rule_code  OUT NOCOPY VARCHAR2,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_out             OUT NOCOPY VARCHAR2
)
IS

l_return_status VARCHAR2(1);
l_tax_class     VARCHAR2(30);

CURSOR rounding_rule_cur (p_ledger_id   NUMBER,
                          p_tax_class   VARCHAR) IS
SELECT rounding_rule_code
FROM   zx_account_rates
WHERE  ledger_id = p_ledger_id
AND    account_segment_value IS NULL
AND    (tax_class = p_tax_class
        OR
        tax_class IS NULL);

  -- Logging Infrastructure
  l_api_name       CONSTANT   VARCHAR2(30) := 'GET_ROUNDING_RULE_CODE';
  l_api_version    CONSTANT   NUMBER := 1.0;
  l_procedure_name CONSTANT   VARCHAR2(30) := 'GET_ROUNDING_RULE_CODE';
  l_log_msg                   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  -- Logging Infrastructure
  l_set_security_context_flag VARCHAR2(1);

BEGIN

  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'get_rounding_rule_code(+)');
  END IF;

  -- Logging Infra: Break point input parameters
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'B: IN: api_version=' || p_api_version ||
                   ', ledger_id=' || p_ledger_id ||
                   ', org_id=' || p_org_id ||
                   ', le_id=' || p_le_id ||
                   ', tax_class=' || p_tax_class;
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                    G_MODULE_NAME || l_procedure_name,
                    l_log_msg);
  END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF  ZX_SECURITY.g_first_party_org_id is NULL then
     l_set_security_context_flag := 'Y';
  ELSE
     l_set_security_context_flag := 'N';
  END IF;

  IF l_set_security_context_flag = 'Y' Then

     -- Logging Infra: Procedure level
     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,
                       G_MODULE_NAME || l_procedure_name,
                       'Setting Security Context');
     END IF;

       ZX_SECURITY.set_security_context(p_le_id, p_org_id, NULL, x_return_status);

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       -- Logging Infra: Statement level
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_procedure_name,
                         'Error Setting Security Context');
       END IF;
       Return;
     END IF;
  END IF; -- l_set_security_context_flag

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'Fetching rounding rule code');
  END IF;


  IF p_tax_class = 'I' THEN
    l_tax_class := 'INPUT';
  END IF;

  IF p_tax_class = 'O' THEN
    l_tax_class := 'OUTPUT';
  END IF;

OPEN rounding_rule_cur (p_ledger_id, l_tax_class);
FETCH rounding_rule_cur INTO x_rounding_rule_code;

IF rounding_rule_cur%NOTFOUND THEN
  x_rounding_rule_code := NULL;
END IF;

CLOSE rounding_rule_cur;


  IF l_set_security_context_flag = 'Y' Then

    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,
                      G_MODULE_NAME || l_procedure_name,
                      'Resetting First Party Org context to NULL');
    END IF;

    ZX_SECURITY.G_FIRST_PARTY_ORG_ID := NULL;
     --dbms_session.set_context('my_ctx','FIRSTPTYORGID',to_char(ZX_SECURITY.G_FIRST_PARTY_ORG_ID));
     ZX_SECURITY.name_value('FIRSTPTYORGID',to_char(ZX_SECURITY.G_FIRST_PARTY_ORG_ID));
  END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'get_rounding_rule_code(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_out := TO_CHAR(SQLCODE);
    -- Logging Infra:
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      TO_CHAR(SQLCODE) || ': ' || SQLERRM);
    END IF;
    app_exception.raise_exception;

END get_rounding_rule_code;


/*===========================================================================+
 | PROCEDURE
 |    get_precision_mau
 |
 | IN
 |    p_ledger_id      : Ledger ID
 |    p_org_id         : Org ID
 |    p_le_id          : Legal Entity ID
 |
 | OUT
 |    x_precision  :  Precision
 |    x_mau        :  Minimum accountable unit
 |
 | DESCRIPTION
 |    This routine returns rounding_rule_code defined for a ledger.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 | 06/30/2005   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/
PROCEDURE get_precision_mau
(  p_api_version IN NUMBER DEFAULT NULL,
   p_ledger_id   IN  NUMBER,
   p_org_id      IN  NUMBER,
   p_le_id       IN  NUMBER,
   x_precision   OUT NOCOPY  NUMBER,
   x_mau         OUT NOCOPY  NUMBER,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_out       OUT NOCOPY VARCHAR2
) AS


l_return_status VARCHAR2(1);
l_first_pty_org_id NUMBER;


CURSOR precision_mau_cur (p_ledger_id  NUMBER)
IS
SELECT tax_precision,
       tax_mau
FROM   zx_account_rates
WHERE  ledger_id = p_ledger_id
AND    account_segment_value IS NULL
AND    rownum = 1;

  -- Logging Infrastructure
  l_api_name       CONSTANT   VARCHAR2(30) := 'GET_PRECISION_MAU';
  l_api_version    CONSTANT   NUMBER := 1.0;
  l_procedure_name CONSTANT   VARCHAR2(30) := 'GET_PRECISION_MAU';
  l_log_msg                   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  -- Logging Infrastructure
  l_set_security_context_flag VARCHAR2(1);

BEGIN

  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'get_precision_mau(+)');
  END IF;

  -- Logging Infra: Break point input parameters
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'B: IN: api_version=' || p_api_version ||
                   ', ledger_id=' || p_ledger_id ||
                   ', org_id=' || p_org_id ||
                   ', le_id=' || p_le_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                    G_MODULE_NAME || l_procedure_name,
                    l_log_msg);
  END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'Setting Security Context');
  END IF;

  IF  ZX_SECURITY.g_first_party_org_id is NULL then
     l_set_security_context_flag := 'Y';
  ELSE
     l_set_security_context_flag := 'N';
  END IF;

  IF l_set_security_context_flag = 'Y' Then

     -- l_first_pty_org_id  := ZX_SECURITY.G_FIRST_PARTY_ORG_ID;
     --dbms_session.set_context('my_ctx','FIRSTPTYORGID',to_char(ZX_SECURITY.G_FIRST_PARTY_ORG_ID));
     --ZX_SECURITY.name_value('FIRSTPTYORGID',to_char(ZX_SECURITY.G_FIRST_PARTY_ORG_ID));

    ZX_SECURITY.set_security_context(p_le_id, p_org_id, NULL, x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- Logging Infra: Statement level
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        'Error Setting Security Context');
      END IF;
      Return;
    END IF;
  END IF; -- l_set_security_context_flag

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'Fetching precision and mau');
  END IF;

  OPEN precision_mau_cur (p_ledger_id);

  FETCH precision_mau_cur INTO x_precision, x_mau;


  IF precision_mau_cur%NOTFOUND THEN
   x_precision := NULL;
   x_mau := NULL;
  END IF;

  CLOSE precision_mau_cur;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'Resetting First Party Org context to NULL');
  END IF;

-- This API gets called from the Journal Entry form also. So, resetting
-- the security context to what was set by the form before thsi API
-- got called.


   IF l_set_security_context_flag = 'Y' Then

      ZX_SECURITY.G_FIRST_PARTY_ORG_ID := NULL;
      --dbms_session.set_context('my_ctx','FIRSTPTYORGID',to_char(ZX_SECURITY.G_FIRST_PARTY_ORG_ID));
      ZX_SECURITY.name_value('FIRSTPTYORGID',to_char(ZX_SECURITY.G_FIRST_PARTY_ORG_ID));
   END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'get_precision_mau(-)');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_out := TO_CHAR(SQLCODE);
      -- Logging Infra:
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        TO_CHAR(SQLCODE) || ': ' || SQLERRM);
      END IF;
      app_exception.raise_exception;

END get_precision_mau;


PROCEDURE get_default_tax_include_flag
(
   p_api_version        IN NUMBER  DEFAULT NULL,
   p_ledger_id          IN NUMBER,
   p_org_id             IN NUMBER,
   p_le_id              IN NUMBER,
   p_account_value      IN VARCHAR2,
   p_tax_type_code      IN VARCHAR2,
   x_include_tax_flag       OUT NOCOPY  VARCHAR2,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_out            OUT NOCOPY  VARCHAR2
) IS

l_include_tax_flag  VARCHAR2(1);
l_return_status     VARCHAR2(1);
l_msg_out           VARCHAR2(30);
l_tax_class         VARCHAR2(30);

CURSOR rate_level_cur (p_ledger_id              NUMBER,
                       p_account_segment_value  VARCHAR2,
                       p_tax_class              VARCHAR2) IS
  SELECT amt_incl_tax_flag
  FROM   zx_account_rates
  WHERE  account_segment_value = p_account_segment_value
  AND    ledger_id = p_ledger_id
  AND    (tax_class = p_tax_class
          OR tax_class IS NULL);


CURSOR ledger_level_cur (p_ledger_id   NUMBER,
                         p_tax_class   VARCHAR2) IS
  SELECT amt_incl_tax_flag
  FROM   zx_account_rates
  WHERE  ledger_id = p_ledger_id
  AND    (tax_class = p_tax_class
          OR tax_class IS NULL)
  AND    account_segment_value IS NULL;

  -- Logging Infrastructure
  l_api_name       CONSTANT   VARCHAR2(30) := 'GET_DEFAULT_TAX_INCLUDE_FLAG';
  l_api_version    CONSTANT   NUMBER := 1.0;
  l_procedure_name CONSTANT   VARCHAR2(30) := 'GET_DEFAULT_TAX_INCLUDE_FLAG';
  l_log_msg                   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  -- Logging Infrastructure
  l_set_security_context_flag VARCHAR2(1);

BEGIN

  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'get_default_tax_include_flag(+)');
  END IF;

  -- Logging Infra: Break point input parameters
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'B: IN: api_version=' || p_api_version ||
                   ', ledger_id=' || p_ledger_id ||
                   ', org_id=' || p_org_id ||
                   ', le_id=' || p_le_id ||
                   ', account_value=' || p_account_value ||
                   ', tax_type_code=' || p_tax_type_code;
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                    G_MODULE_NAME || l_procedure_name,
                    l_log_msg);
  END IF;

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  IF  ZX_SECURITY.g_first_party_org_id is NULL then
     l_set_security_context_flag := 'Y';
  ELSE
     l_set_security_context_flag := 'N';
  END IF;

  IF l_set_security_context_flag = 'Y' Then

    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,
                      G_MODULE_NAME || l_procedure_name,
                      'Setting Security Context');
    END IF;

    ZX_SECURITY.set_security_context(p_le_id, p_org_id, NULL, x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- Logging Infra: Statement level
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        'Error Setting Security Context');
      END IF;
      Return;
    END IF;
  END IF; -- l_set_security_context_flag

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'Fetching amount includes tax flag');
  END IF;

  IF p_tax_type_code = 'I' THEN
     l_tax_class := 'INPUT';
  END IF;

  IF p_tax_type_code = 'O' THEN
     l_tax_class := 'OUTPUT';
  END IF;

  OPEN rate_level_cur (p_ledger_id,
                       p_account_value,
                       l_tax_class);
  FETCH rate_level_cur INTO l_include_tax_flag;

  IF rate_level_cur%NOTFOUND THEN
    IF ledger_level_cur%ISOPEN THEN
      CLOSE ledger_level_cur;
    END IF;

    OPEN ledger_level_cur (p_ledger_id,
                           l_tax_class);
    FETCH ledger_level_cur INTO l_include_tax_flag;

    IF ledger_level_cur%FOUND THEN
      l_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
      l_return_status := FND_API.G_RET_STS_ERROR;
      l_msg_out := 'ZX_GL_DEF_INCL_TAX_NOTFOUND';
    END IF;

    CLOSE ledger_level_cur;

  END IF;

  CLOSE rate_level_cur;

  x_include_tax_flag := l_include_tax_flag;
  x_return_status := l_return_status;
  x_msg_out := l_msg_out;


  IF l_set_security_context_flag = 'Y' Then

    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,
                      G_MODULE_NAME || l_procedure_name,
                      'Resetting First Party Org context to NULL');
    END IF;

    ZX_SECURITY.G_FIRST_PARTY_ORG_ID := NULL;
    --dbms_session.set_context('my_ctx','FIRSTPTYORGID',to_char(ZX_SECURITY.G_FIRST_PARTY_ORG_ID));
     ZX_SECURITY.name_value('FIRSTPTYORGID',to_char(ZX_SECURITY.G_FIRST_PARTY_ORG_ID));
  END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'get_default_tax_include_flag(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_out := TO_CHAR(SQLCODE);
    -- Logging Infra:
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      TO_CHAR(SQLCODE) || ': ' || SQLERRM);
    END IF;
    app_exception.raise_exception;
END;

PROCEDURE get_ledger_controls
(  p_api_version IN  NUMBER DEFAULT NULL,
   p_ledger_id   IN  NUMBER,
   p_org_id      IN  NUMBER,
   p_le_id       IN  NUMBER,
   x_calculation_level_code   OUT NOCOPY  VARCHAR2,
   x_tax_mau                  OUT NOCOPY  NUMBER,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_out                  OUT NOCOPY VARCHAR2
) IS

  -- Logging Infrastructure
  l_api_name       CONSTANT   VARCHAR2(30) := 'GET_LEDGER_CONTROLS';
  l_api_version    CONSTANT   NUMBER := 1.0;
  l_procedure_name CONSTANT   VARCHAR2(30) := 'GET_LEDGER_CONTROLS';
  l_log_msg                   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  -- Logging Infrastructure
  l_set_security_context_flag VARCHAR2(1);

BEGIN

  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'get_ledger_controls(+)');
  END IF;

  -- Logging Infra: Break point input parameters
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'B: IN: api_version=' || p_api_version ||
                   ', ledger_id=' || p_ledger_id ||
                   ', org_id=' || p_org_id ||
                   ', le_id=' || p_le_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                    G_MODULE_NAME || l_procedure_name,
                    l_log_msg);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF  ZX_SECURITY.g_first_party_org_id is NULL then
     l_set_security_context_flag := 'Y';
  ELSE
     l_set_security_context_flag := 'N';
  END IF;

  IF l_set_security_context_flag = 'Y' Then

     -- Logging Infra: Procedure level
     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,
                       G_MODULE_NAME || l_procedure_name,
                       'Setting Security Context');
     END IF;

     ZX_SECURITY.set_security_context(p_le_id, p_org_id, NULL, x_return_status);

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       -- Logging Infra: Statement level
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_procedure_name,
                         'Error Setting Security Context');
       END IF;
       Return;
     END IF;
  END IF; -- l_set_security_context_flag

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'Fetching calc level code and tax mau');
  END IF;

    SELECT calculation_level_code,
           decode(tax_mau, NULL, power(10,-1*tax_precision), tax_mau)
    INTO x_calculation_level_code,
         x_tax_mau
    FROM zx_account_rates
    WHERE ledger_id = p_ledger_id
    AND   account_segment_value IS NULL
    AND   rownum = 1;

  IF l_set_security_context_flag = 'Y' Then
    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,
                      G_MODULE_NAME || l_procedure_name,
                      'Resetting First Party Org context to NULL');
    END IF;

    ZX_SECURITY.G_FIRST_PARTY_ORG_ID := NULL;
    --dbms_session.set_context('my_ctx','FIRSTPTYORGID',to_char(ZX_SECURITY.G_FIRST_PARTY_ORG_ID));
     ZX_SECURITY.name_value('FIRSTPTYORGID',to_char(ZX_SECURITY.G_FIRST_PARTY_ORG_ID));
  END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,
                    G_MODULE_NAME || l_procedure_name,
                    'get_ledger_controls(-)');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_out := 'ZX_GL_LEDGER_CONTROLS_NOTFOUND';
    -- Logging Infra:
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      'NO_DATA_FOUND');
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_out := TO_CHAR(SQLCODE);
    -- Logging Infra:
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      TO_CHAR(SQLCODE) || ': ' || SQLERRM);
    END IF;
    app_exception.raise_exception;

END;


END zx_gl_tax_options_pkg;

/
