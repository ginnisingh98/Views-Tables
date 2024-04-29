--------------------------------------------------------
--  DDL for Package Body ZX_TCM_GET_DEF_EXEMPTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TCM_GET_DEF_EXEMPTION" AS
/* $Header: zxcgetdefexemptb.pls 120.3 2006/07/28 00:28:28 dbetanco ship $ */

  -- Logging Infra
  G_CURRENT_RUNTIME_LEVEL      NUMBER;
  G_LEVEL_UNEXPECTED           CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR                CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT                CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE            CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(40) := 'ZX.PLSQL.ZX_TCM_GET_DEF_EXEMPTION';

PROCEDURE get_default_exemptions(
                             p_bill_to_cust_acct_id          IN NUMBER,
                             p_ship_to_cust_acct_id          IN NUMBER,
                             p_ship_to_site_use_id           IN NUMBER,
                             p_bill_to_site_use_id           IN NUMBER,
                             p_bill_to_party_id              IN NUMBER,
                             p_bill_to_party_site_id         IN NUMBER,
                             p_ship_to_party_site_id         IN NUMBER,
                             p_legal_entity_id               IN NUMBER,
                             p_org_id                        IN NUMBER,
                             p_trx_date                      IN DATE,
                             p_exempt_certificate_number     IN VARCHAR2,
                             p_reason_code                   IN VARCHAR2,
                             p_exempt_control_flag           IN VARCHAR2,
                             p_inventory_org_id              IN NUMBER,
                             p_inventory_item_id             IN NUMBER,
                             x_return_status                 OUT NOCOPY VARCHAR2,
                             x_exemption_rec_tbl             OUT NOCOPY exemption_rec_tbl_type) IS

    CURSOR get_default_exemptions(p_country_code IN VARCHAR2, p_ptp_id IN NUMBER) IS
      SELECT
           v.tax_exemption_id,
           v.exemption_type_code,
           v.exempt_certificate_number,
           v.exempt_reason_code,
	   v.meaning,
           v.Exemption_Status_code,
           v.tax_regime_code,
           v.Tax_status_code,
           v.Tax,
           v.Tax_Rate_Code,
	   v.cust_account_id,
   	   v.site_use_id,
           v.party_id,
           v.party_site_id,
           v.effective_from,
           v.effective_to,
           v.content_owner_id,
           v.PRODUCT_ID,
           v.INVENTORY_ORG_ID,
           v.RATE_MODIFIER,
           v.TAX_JURISDICTION_ID,
           v.PARTY_TAX_PROFILE_ID,
  	   decode(zxr.country_code, p_country_code, 1, 2) select_order
       FROM
	(SELECT
           ex.tax_exemption_id,
           ex.exemption_type_code,
           ex.exempt_certificate_number,
           ex.exempt_reason_code,
           lkp.Meaning,
           Ex.Exemption_Status_code,
           Ex.tax_regime_code,
           Ex.Tax_status_code,
           Ex.Tax,
           Ex.Tax_Rate_Code,
           Ex.Cust_account_id,
           Ex.Site_use_id,
           Ptp_party.party_id party_id,
           null party_site_id,
           Ex.effective_from,
           Ex.effective_to,
           Ex.content_owner_id,
           Ex.PRODUCT_ID,
           Ex.INVENTORY_ORG_ID,
           Ex.RATE_MODIFIER,
           Ex.TAX_JURISDICTION_ID,
           Ex.PARTY_TAX_PROFILE_ID
         FROM
           zx_exemptions ex, fnd_lookups lkp,
           zx_party_tax_profile ptp_party
         WHERE
           Ex.exempt_reason_code = lkp.lookup_code and
           Lkp.lookup_type = 'ZX_EXEMPTION_REASON_CODE' and
           ex.exemption_status_code in ( 'PRIMARY', 'MANUAL', 'UNAPPROVED' ) and
           ex.party_tax_profile_id = ptp_party.party_tax_profile_id and
           ptp_party.party_type_code = 'THIRD_PARTY'
        UNION
        SELECT
           ex.tax_exemption_id,
           ex.exemption_type_code,
           ex.exempt_certificate_number,
           ex.exempt_reason_code,
           lkp.Meaning,
           Ex.Exemption_Status_code,
           Ex.tax_regime_code,
           Ex.Tax_status_code,
           Ex.Tax,
           Ex.Tax_Rate_Code,
           Ex.Cust_account_id,
           Ex.Site_use_id,
           ps.party_id party_id,
           Ptp_party_site.party_id party_site_id,
           Ex.effective_from,
           Ex.effective_to,
           Ex.content_owner_id,
           Ex.PRODUCT_ID,
           Ex.INVENTORY_ORG_ID,
           Ex.RATE_MODIFIER,
           Ex.TAX_JURISDICTION_ID,
           Ex.PARTY_TAX_PROFILE_ID
         FROM
           zx_exemptions ex, fnd_lookups lkp,
           zx_party_tax_profile ptp_party_site, hz_party_sites ps
         WHERE
           Ex.exempt_reason_code = lkp.lookup_code and
           Lkp.lookup_type = 'ZX_EXEMPTION_REASON_CODE' and
           ex.exemption_status_code in ( 'PRIMARY', 'MANUAL', 'UNAPPROVED' ) and
           ex.party_tax_profile_id = ptp_party_site.party_tax_profile_id and
           ptp_party_site.party_type_code = 'THIRD_PARTY_SITE' and
           ptp_party_site.party_id = ps.party_site_id) v, zx_regimes_b zxr
      WHERE
           v.content_owner_id = p_ptp_id
      AND  v.tax_regime_code = zxr.tax_regime_code
      AND  nvl(v.EXEMPT_CERTIFICATE_NUMBER, -99)  = nvl(p_exempt_certificate_number, -99)
      AND  nvl(v.EXEMPT_REASON_CODE, -99) = nvl(p_reason_code,-99)
      AND nvl(v.site_use_id,nvl(p_ship_to_site_use_id,p_bill_to_site_use_id)) =
                           nvl(p_ship_to_site_use_id, p_bill_to_site_use_id)
      AND nvl(v.cust_account_id, p_bill_to_cust_acct_id) = p_bill_to_cust_acct_id
      AND nvl(v.PARTY_SITE_ID,nvl(p_ship_to_party_site_id, p_bill_to_party_site_id))=
                            nvl(p_ship_to_party_site_id, p_bill_to_party_site_id)
      and  v.party_id = p_bill_to_party_id
      AND v.EXEMPTION_STATUS_CODE = 'PRIMARY'
      AND TRUNC(NVL(p_trx_date,sysdate))
                      BETWEEN TRUNC(v.EFFECTIVE_FROM)
                           AND TRUNC(NVL(v.EFFECTIVE_TO,NVL(p_trx_date,sysdate)))
      ORDER BY select_order;

      TYPE l_exemption_rec_type IS RECORD
  	( TAX_EXEMPTION_ID                    NUMBER(15),
    	EXEMPTION_TYPE_CODE                 VARCHAR2(30),
    	EXEMPT_CERTIFICATE_NUMBER           VARCHAR2(80),
	EXEMPT_REASON_CODE                  VARCHAR2(30),
        MEANING				    VARCHAR2(80),
    	EXEMPTION_STATUS_CODE               VARCHAR2(30),
    	TAX_REGIME_CODE                     VARCHAR2(30),
    	TAX_STATUS_CODE                     VARCHAR2(30),
    	TAX                                 VARCHAR2(30),
    	TAX_RATE_CODE                       VARCHAR2(50),
        CUST_ACCT_ID			    NUMBER(15),
        SITE_USE_ID			    NUMBER(15),
        PARTY_ID			    NUMBER(15),
	PARTY_SITE_ID			    NUMBER(15),
    	EFFECTIVE_FROM                      DATE,
   	EFFECTIVE_TO                        DATE,
    	CONTENT_OWNER_ID                    NUMBER(15),
    	PRODUCT_ID                          NUMBER,
    	INVENTORY_ORG_ID                    NUMBER,
    	RATE_MODIFIER                       NUMBER,
    	TAX_JURISDICTION_ID                 NUMBER(15),
   	PARTY_TAX_PROFILE_ID                NUMBER(15),
        SELECT_ORDER			    NUMBER);

    TYPE l_exemption_rec_tbl_type IS TABLE of l_exemption_rec_type INDEX BY BINARY_INTEGER;
    l_exemption_rec_tbl l_exemption_rec_tbl_type;


    l_country_code VARCHAR2(60);
    l_ptp_id NUMBER;
     -- Logging Infra
    l_procedure_name CONSTANT VARCHAR2(30) := 'get_default_exemptions';
    l_log_msg FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
BEGIN

    -- Logging Infra: Setting up runtime level
    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := l_procedure_name||'(+)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
    END IF;

     -- Initialize API return status to success.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Logging Infra: Statement level: "B" means "B"reak point
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'B: SEL hz_locations: in: p_ship_to_party_site_id='||p_ship_to_party_site_id;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;

    SELECT hzl.COUNTRY
    INTO l_country_code
    FROM hz_locations hzl,
         hz_party_sites hzp
    WHERE hzl.location_id = hzp.location_id
    AND hzp.PARTY_SITE_ID = p_ship_to_party_site_id;

       -- Logging Infra: Statement level: "R" means "R"eturned value to a caller
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'R: SEL hz_locations:: out: l_country_code='||l_country_code;
          l_log_msg := l_log_msg ||' B: get_tax_subscriber: in: p_legal_entity_id, p_org_id='||p_legal_entity_id||p_org_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

    zx_tcm_ptp_pkg.get_tax_subscriber(  p_legal_entity_id,
					p_org_id,
					l_ptp_id,
					x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN get_default_exemptions(l_country_code,l_ptp_id);
    FETCH get_default_exemptions BULK COLLECT INTO l_exemption_rec_tbl;
    IF l_exemption_rec_tbl.count <> 0 THEN
  	  FOR i IN l_exemption_rec_tbl.first..l_exemption_rec_tbl.last LOOP
     		 x_exemption_rec_tbl(i).tax_exemption_id := l_exemption_rec_tbl(i).tax_exemption_id;
     		 x_exemption_rec_tbl(i).exemption_type_code := l_exemption_rec_tbl(i).exemption_type_code;
     		 x_exemption_rec_tbl(i).exemption_status_code:= l_exemption_rec_tbl(i).exemption_status_code;
     		 x_exemption_rec_tbl(i).exempt_certificate_number:= l_exemption_rec_tbl(i).exempt_certificate_number;
     		 x_exemption_rec_tbl(i).exempt_reason_code:= l_exemption_rec_tbl(i).exempt_reason_code;
     		 x_exemption_rec_tbl(i).tax_regime_code:= l_exemption_rec_tbl(i).tax_regime_code;
     		 x_exemption_rec_tbl(i).tax_status_code := l_exemption_rec_tbl(i).tax_status_code;
     		 x_exemption_rec_tbl(i).tax := l_exemption_rec_tbl(i).tax;
     		 x_exemption_rec_tbl(i).tax_rate_code := l_exemption_rec_tbl(i).tax_rate_code;
     		 x_exemption_rec_tbl(i).effective_from := l_exemption_rec_tbl(i).effective_from;
     		 x_exemption_rec_tbl(i).effective_to := l_exemption_rec_tbl(i).effective_to;
     		 x_exemption_rec_tbl(i).content_owner_id:= l_exemption_rec_tbl(i).content_owner_id;
     		 x_exemption_rec_tbl(i).product_id := l_exemption_rec_tbl(i).product_id;
     		 x_exemption_rec_tbl(i).inventory_org_id := l_exemption_rec_tbl(i).inventory_org_id;
     		 x_exemption_rec_tbl(i).rate_modifier:= l_exemption_rec_tbl(i).rate_modifier;
     		 x_exemption_rec_tbl(i).tax_jurisdiction_id := l_exemption_rec_tbl(i).tax_jurisdiction_id;
     		 x_exemption_rec_tbl(i).party_tax_profile_id := l_exemption_rec_tbl(i).party_tax_profile_id;
          END LOOP;
         l_exemption_rec_tbl.delete;
    END IF;
    close get_default_exemptions;

EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Logging Infra: Statement level
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, 'E: EXC: OTHERS: '
                               || SQLCODE||': '||SQLERRM);

                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;
END;
END;


/
