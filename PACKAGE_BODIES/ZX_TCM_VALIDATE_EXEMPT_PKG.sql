--------------------------------------------------------
--  DDL for Package Body ZX_TCM_VALIDATE_EXEMPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TCM_VALIDATE_EXEMPT_PKG" AS
/* $Header: zxcvalexemptb.pls 120.2 2005/12/21 02:59:09 sachandr ship $ */
  -- Logging Infra
  G_CURRENT_RUNTIME_LEVEL      NUMBER;
  G_LEVEL_UNEXPECTED           CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR                CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT                CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE            CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(30) := 'ZX.ZX_TCM_VAL_EXEMPT_PKG';

PROCEDURE VALIDATE_TAX_EXEMPTIONS
        (p_tax_exempt_number       IN VARCHAR2,
         p_tax_exempt_reason_code  IN VARCHAR2,
         p_ship_to_org_id          IN NUMBER,
         p_invoice_to_org_id       IN NUMBER,
         p_bill_to_cust_account_id IN NUMBER,
         p_ship_to_party_site_id   IN NUMBER,
         p_bill_to_party_site_id   IN NUMBER,
         p_org_id                  IN NUMBER,
         p_bill_to_party_id        IN NUMBER,
         p_legal_entity_id         IN NUMBER,
         p_trx_type_id             IN NUMBER,
         p_batch_source_id         IN NUMBER,
         p_trx_date                IN DATE,
         p_exemption_status        IN VARCHAR2 default 'P',
         x_valid_flag              OUT NOCOPY VARCHAR2,
         x_return_status           OUT NOCOPY VARCHAR2,
         x_msg_count               OUT NOCOPY NUMBER ,
         x_msg_data                OUT NOCOPY VARCHAR2) IS
  l_legal_entity_id NUMBER;
  l_effective_date DATE;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);
  -- Logging Infra
  l_procedure_name CONSTANT VARCHAR2(30) := 'validate_tax_exemptions';
  l_log_msg FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
BEGIN
  -- Logging Infra: Setting up runtime message level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_valid_flag := 'N';
  IF p_legal_entity_id IS NULL THEN
    IF p_trx_type_id IS NOT NULL AND p_batch_source_id IS NOT NULL AND p_org_id IS NOT NULL THEN
      BEGIN
       l_legal_entity_id := XLE_BUSINESSINFO_GRP.Get_OrdertoCash_Info(
                            p_customer_type => null,                           -- IN
                            p_customer_id => null,                     -- IN
                            p_transaction_type_id => p_trx_type_id,       -- IN
                            p_batch_source_id => p_batch_source_id,            -- IN
                            p_operating_unit_id => p_org_id    -- IN
                            );
      EXCEPTION WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Function XLE_BUSINESSINFO_GRP.Get_OrdertoCash_Info returned errors';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;

      END;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      ----- Unable to derive legal entity
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'Transaction Type Id or Batch source Id or Org Id is null.';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
    END IF;
  ELSE
    l_legal_entity_id := p_legal_entity_id;

  END IF;
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;

  END IF;
  IF l_legal_entity_id IS NOT NULL THEN

    zx_api_pub.set_tax_security_context(
                p_api_version => 1.0  ,
                p_init_msg_list =>NULL,
                p_commit        => 'N',
                p_validation_level => 1,
                x_msg_count =>x_msg_count,
                x_msg_data =>x_msg_data,
                p_internal_org_id => p_org_id,
                p_legal_entity_id => l_legal_entity_id,
                p_transaction_date => p_trx_date,
                p_related_doc_date => NULL,
                p_adjusted_doc_date =>NULL,
                x_effective_date    =>l_effective_date,
                x_return_status => x_return_status);
    IF p_exemption_status = 'P' THEN
    BEGIN
      SELECT 'Y'
      INTO x_valid_flag
      FROM ZX_EXEMPTIONS_V
      WHERE EXEMPT_CERTIFICATE_NUMBER = p_tax_exempt_number
      AND EXEMPT_REASON_CODE = p_tax_exempt_reason_code
      AND nvl(site_use_id,nvl(p_ship_to_org_id, p_invoice_to_org_id)) =  nvl(p_ship_to_org_id, p_invoice_to_org_id)
      AND nvl(cust_account_id, p_bill_to_cust_account_id) = p_bill_to_cust_account_id
      AND nvl(PARTY_SITE_ID,nvl(p_ship_to_party_site_id, p_bill_to_party_site_id))= nvl(p_ship_to_party_site_id,
                                     p_bill_to_party_site_id)
      AND  party_id = p_bill_to_party_id
      AND EXEMPTION_STATUS_CODE = 'PRIMARY'
      AND TRUNC(NVL(p_trx_date,sysdate)) BETWEEN TRUNC(EFFECTIVE_FROM)
      AND TRUNC(NVL(EFFECTIVE_TO,NVL(p_trx_date,sysdate)))
      AND ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      x_valid_flag := 'N';

    END;
  ELSIF p_exemption_status = 'PM' THEN
    BEGIN
      SELECT 'Y'
      INTO x_valid_flag
      FROM ZX_EXEMPTIONS_V
      WHERE EXEMPT_CERTIFICATE_NUMBER = p_tax_exempt_number
      AND EXEMPT_REASON_CODE = p_tax_exempt_reason_code
      AND nvl(site_use_id,nvl(p_ship_to_org_id, p_invoice_to_org_id)) =  nvl(p_ship_to_org_id, p_invoice_to_org_id)
      AND nvl(cust_account_id, p_bill_to_cust_account_id) = p_bill_to_cust_account_id
      AND nvl(PARTY_SITE_ID,nvl(p_ship_to_party_site_id, p_bill_to_party_site_id))= nvl(p_ship_to_party_site_id,
                                     p_bill_to_party_site_id)
      AND  party_id = p_bill_to_party_id
      AND EXEMPTION_STATUS_CODE IN ('PRIMARY', 'MANUAL')
      AND TRUNC(NVL(p_trx_date,sysdate)) BETWEEN TRUNC(EFFECTIVE_FROM)
      AND TRUNC(NVL(EFFECTIVE_TO,NVL(p_trx_date,sysdate)))
      AND ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      x_valid_flag := 'N';

    END;
  ELSIF p_exemption_status = 'PMU' THEN
    BEGIN
      SELECT 'Y'
      INTO x_valid_flag
      FROM ZX_EXEMPTIONS_V
      WHERE EXEMPT_CERTIFICATE_NUMBER = p_tax_exempt_number
      AND EXEMPT_REASON_CODE = p_tax_exempt_reason_code
      AND nvl(site_use_id,nvl(p_ship_to_org_id, p_invoice_to_org_id)) =  nvl(p_ship_to_org_id, p_invoice_to_org_id)
      AND nvl(cust_account_id, p_bill_to_cust_account_id) = p_bill_to_cust_account_id
      AND nvl(PARTY_SITE_ID,nvl(p_ship_to_party_site_id, p_bill_to_party_site_id))= nvl(p_ship_to_party_site_id,
                                     p_bill_to_party_site_id)
      AND  party_id = p_bill_to_party_id
      AND EXEMPTION_STATUS_CODE IN ('PRIMARY', 'MANUAL','UNAPPROVED')
      AND TRUNC(NVL(p_trx_date,sysdate)) BETWEEN TRUNC(EFFECTIVE_FROM)
      AND TRUNC(NVL(EFFECTIVE_TO,NVL(p_trx_date,sysdate)))
      AND ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      x_valid_flag := 'N';

    END;
  ELSE
    x_valid_flag := 'N';
  END IF;



  ELSE
    x_valid_flag := 'N';

  END IF;

EXCEPTION WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
       -- Logging Infra: Statement level
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'E: EXC: FND_API.G_EXC_ERROR';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
     -- Logging Infra: Statement level
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, 'E: EXC: OTHERS: '||SQLCODE||': '||SQLERRM);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;



END;

END;

/
