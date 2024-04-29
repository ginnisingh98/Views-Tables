--------------------------------------------------------
--  DDL for Package Body ZX_TCM_GET_EXCEPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TCM_GET_EXCEPT_PKG" AS
/* $Header: zxcgetexceptb.pls 120.8 2006/09/16 00:15:57 sachandr ship $ */
/* ======================================================================*
 | Global Data Types                                                     |
 * ======================================================================*/

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'ZX_TCM_GET_EXCEPT_PKG';
G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME           CONSTANT VARCHAR2(50) := 'ZX.PLSQL.ZX_TCM_GET_EXCEPT_PKG.';

G_LINES_PER_FETCH       CONSTANT  NUMBER:= 1000;
G_MAX_LINES_PER_FETCH   CONSTANT  NUMBER:= 1000000;


PROCEDURE get_tax_exceptions(p_inventory_item_id IN NUMBER,
                             p_inventory_organization_id IN NUMBER,
                             p_product_category  IN VARCHAR2,
                             p_tax_regime_code   IN VARCHAR2,
                             p_tax               IN VARCHAR2,
                             p_tax_status_code   IN VARCHAR2,
                             p_tax_rate_code     IN VARCHAR2,
                             p_trx_date          IN DATE,
                             p_tax_jurisdiction_id IN NUMBER,
                             p_multiple_jurisdictions_flag   IN VARCHAR2,
                             x_exception_rec     OUT NOCOPY exception_rec_type,
                             x_return_status     OUT NOCOPY VARCHAR2) IS

  CURSOR item_exceptions(p_inventory_item_id   NUMBER,
                         p_inventory_organization_id NUMBER,
                         p_tax_regime_code     VARCHAR2,
                         p_tax                 VARCHAR2,
                         p_tax_status_code     VARCHAR2,
                         p_tax_rate_code       VARCHAR2,
                         p_tax_jurisdiction_id NUMBER
                     ) IS
    SELECT tax_exception_id, exception_type_code, rate_modifier
    FROM zx_sco_exceptions
    WHERE product_id = p_inventory_item_id
    -- AND inventory_org_id = p_inventory_organization_id
    AND classification_type_code IS NULL
    AND classification_code IS NULL
    AND tax_regime_code = p_tax_regime_code
    AND NVL(tax, 'XX') IN (NVL(p_tax, 'XX'), 'XX')
    AND NVL(tax_status_code, 'XX') IN (NVL(p_tax_status_code, 'XX'), 'XX')
    AND NVL(tax_rate_code, 'XX') IN (NVL(p_tax_rate_code, 'XX'), 'XX')
    AND NVL(tax_jurisdiction_id, -99) IN (NVL(p_tax_jurisdiction_id, -99), -99)
    /* Added for bug 4619907 */
    AND duplicate_exception = 0
    AND effective_from <= p_trx_date
    AND (effective_to >= p_trx_date or effective_to is null);

  CURSOR fisc_exceptions(p_tax_regime_code          VARCHAR2,
                         p_tax                      VARCHAR2,
                         p_tax_status_code          VARCHAR2,
                         p_tax_rate_code            VARCHAR2,
                         p_tax_jurisdiction_id      NUMBER,
                         p_inventory_item_id        NUMBER,
                         p_inventory_organization_id NUMBER
                     ) IS
    SELECT ex.tax_exception_id, ex.exception_type_code, ex.rate_modifier
    FROM zx_sco_exceptions ex, mtl_categories_b_kfv mc, mtl_category_sets_b mcs,
         fnd_id_flex_structures_vl fifs, mtl_item_categories mic,
         zx_fc_types_b fc, zx_fc_types_reg_assoc fcreg
    WHERE ex.product_id IS NULL
    AND  ex.tax_regime_code = p_tax_regime_code
    AND  (ex.tax = p_tax or ex.tax is null)
    AND  (ex.tax_status_code = p_tax_status_code or ex.tax_status_code is null)
    AND  (ex.tax_rate_code = p_tax_rate_code or ex.tax_rate_code is null)
    AND  (ex.tax_jurisdiction_id = p_tax_jurisdiction_id or ex.tax_jurisdiction_id  is null)
    AND  ex.duplicate_exception = 0
    AND  ex.effective_from <= p_trx_date
    AND (ex.effective_to >= p_trx_date or ex.effective_to is null)
    AND  ex.classification_type_code = fc.classification_type_code
    AND  ex.classification_code = REPLACE(mc.concatenated_segments, fifs.concatenated_segment_delimiter,'')
    AND  mc.structure_id = fifs.id_flex_num
    AND  fifs.application_id = 401
    AND  fifs.id_flex_code = 'MCAT'
    AND  mc.enabled_flag = 'Y'
    AND  fifs.id_flex_num = mcs.structure_id
    AND  mcs.category_set_id = fc.owner_id_num
    AND  fc.classification_type_categ_code = 'PRODUCT_FISCAL_CLASS'
    AND  fc.classification_type_code = fcreg.classification_type_code
    AND  fcreg.tax_regime_code = p_tax_regime_code
    AND  fcreg.use_in_item_exceptions_flag = 'Y'
    AND  fcreg.effective_from <= p_trx_date
    AND (fcreg.effective_to >= p_trx_date OR fcreg.effective_to IS NULL) --Bug 5383505
    AND  mic.category_set_id = mcs.category_set_id
    AND  mc.category_id = mic.category_id
    AND  mic.inventory_item_id = p_inventory_item_id
    AND  mic.organization_id = p_inventory_organization_id;

  CURSOR fisc_exceptions_non_inv(p_product_category VARCHAR2,
                         p_tax_regime_code          VARCHAR2,
                         p_tax                      VARCHAR2,
                         p_tax_status_code          VARCHAR2,
                         p_tax_rate_code            VARCHAR2,
                         p_tax_jurisdiction_id      NUMBER
                     ) IS
    SELECT tax_exception_id, exception_type_code, rate_modifier
    FROM zx_sco_exceptions ex, zx_fc_types_b fct, zx_fc_types_reg_assoc fcreg, zx_fc_codes_b fcc
    WHERE ex.tax_regime_code = p_tax_regime_code
    AND  (ex.tax = p_tax or ex.tax is null)
    AND  (ex.tax_status_code = p_tax_status_code or ex.tax_status_code is null)
    AND  (ex.tax_rate_code = p_tax_rate_code or ex.tax_rate_code is null)
    AND  (ex.tax_jurisdiction_id = p_tax_jurisdiction_id or ex.tax_jurisdiction_id  is null)
    AND  ex.classification_type_code = fct.classification_type_code
    AND  ex.classification_code = fcc.classification_code
    AND  ex.duplicate_exception = 0
    AND  ex.effective_from <= p_trx_date
    AND (ex.effective_to >= p_trx_date or ex.effective_to is null)
    AND  fct.classification_type_categ_code = 'PRODUCT_GENERIC_CLASSIFICATION'
    AND  fct.classification_type_code = fcreg.classification_type_code
    AND  fcreg.tax_regime_code = p_tax_regime_code
    AND  fcreg.use_in_item_exceptions_flag = 'Y'
    AND  fct.classification_type_code = fcc.classification_type_code
    AND  p_trx_date BETWEEN fcreg.effective_from AND fcreg.effective_to
    AND  fcc.classification_code = p_product_category;

  l_tax_jurisdiction_id NUMBER;

  l_status VARCHAR2(1);
  l_db_status VARCHAR2(1);
  l_api_name           CONSTANT VARCHAR2(30):= 'GET_TAX_EXCEPTIONS';
  l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN
--  Get exception for inventory item;
--  If not found
--    find the fiscal classification type for the tax regime that is used to define exceptions;
--    Check if the inventory item passed belongs to the Fiscal classification type
--       find out the fiscal classification code(s).
--        check if an exception exists for that fiscal classification type and code(s)
--        If found pass it back to TDM
--      End if;
--    End if;
--  End if;
    ----- Add logic to use zx_jurisdictions_gt table
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN

      l_log_msg := 'Parameters '||
                   ' p_inventory_item_id: '||to_char(p_inventory_item_id)||
                   ' p_inventory_organization_id: '||p_inventory_organization_id||
                   ' p_product_category: '||to_char(p_product_category)||
                   ' p_tax_regime_code: '||to_char(p_tax_regime_code)||
		   ' p_tax            : '||to_char(p_tax)||
		   ' p_tax_status_code: '||to_char(p_tax_status_code)||
		   ' p_tax_rate_code  : '||to_char(p_tax_rate_code)||
		   ' p_tax_jurisdiction_id: '||to_char(p_tax_jurisdiction_id)||
		   ' p_multiple_jurisdictions_flag: '||to_char(p_multiple_jurisdictions_flag)||' ';

      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_api_name, l_log_msg);
    END IF;
    OPEN item_exceptions(p_inventory_item_id,
                         p_inventory_organization_id,
                         p_tax_regime_code,
                         p_tax,
                         p_tax_status_code,
                         p_tax_rate_code,
                         p_tax_jurisdiction_id);
    LOOP
      FETCH item_exceptions INTO x_exception_rec.tax_exception_id, x_exception_rec.exception_type_code,
                                 x_exception_rec.exception_rate;
      EXIT WHEN item_exceptions%NOTFOUND;
      IF x_exception_rec.tax_exception_id IS NOT NULL THEN
        EXIT;
      END IF;

    END LOOP;
    CLOSE item_exceptions;
    --
    IF x_exception_rec.tax_exception_id IS NULL THEN
      BEGIN
        SELECT STATUS, DB_STATUS
        INTO l_status, l_db_status
        FROM fnd_product_installations
        WHERE APPLICATION_ID = '401';
      EXCEPTION WHEN OTHERS THEN
       NULL;

      END;


     IF (nvl(l_status,'N') = 'I' or  nvl(l_db_status,'N') = 'I') THEN  --Bug 5383505
      OPEN fisc_exceptions( p_tax_regime_code,
                         p_tax,
                         p_tax_status_code,
                         p_tax_rate_code,
                         p_tax_jurisdiction_id,
                         p_inventory_item_id,
                         p_inventory_organization_id);
      LOOP
        FETCH fisc_exceptions INTO x_exception_rec.tax_exception_id, x_exception_rec.exception_type_code,
                                   x_exception_rec.exception_rate;
        EXIT WHEN fisc_exceptions%NOTFOUND;
        IF x_exception_rec.tax_exception_id IS NOT NULL THEN
          EXIT;
        END IF;
      END LOOP;
      CLOSE fisc_exceptions;

      IF x_exception_rec.tax_exception_id IS NULL THEN
        -- Exception not found;
        null;
      END IF;
 ELSE --l inventory is not installed then
       OPEN fisc_exceptions_non_inv(p_product_category,
                         p_tax_regime_code,
                         p_tax,
                         p_tax_status_code,
                         p_tax_rate_code,
                         p_tax_jurisdiction_id);
      LOOP
        FETCH fisc_exceptions_non_inv INTO x_exception_rec.tax_exception_id, x_exception_rec.exception_type_code, x_exception_rec.exception_rate;
        EXIT WHEN fisc_exceptions_non_inv%NOTFOUND;
        IF x_exception_rec.tax_exception_id IS NOT NULL THEN
          EXIT;
        END IF;
      END LOOP;
      CLOSE fisc_exceptions_non_inv;

      IF x_exception_rec.tax_exception_id IS NULL THEN
        -- Exception not found;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN

	  l_log_msg := 'No exception found ';

		 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_api_name, l_log_msg);
	 END IF;
      END IF;
    END IF;

 END IF;
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()-');
    END IF;
END;
END;

/
