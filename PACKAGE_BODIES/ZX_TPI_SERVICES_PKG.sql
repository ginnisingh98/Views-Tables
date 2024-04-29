--------------------------------------------------------
--  DDL for Package Body ZX_TPI_SERVICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TPI_SERVICES_PKG" AS
/* $Header: zxiftpisrvcpkgb.pls 120.79.12010000.13 2010/01/27 05:40:43 tsen ship $ */
/* ======================================================================*
 | Global Data Types                                                     |
 * ======================================================================*/

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'ZX_TPI_SERVICES_PKG';
G_CURRENT_RUNTIME_LEVEL     CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED          CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR               CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION           CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT               CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE           CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT           CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME               CONSTANT VARCHAR2(30) := 'ZX.PLSQL.ZX_TPI_SERVICES_PKG.';

NUMBER_DUMMY                CONSTANT NUMBER(15):= -999999999999999;


-- Bug 5417887: Tables to hold zx_lines_det_factor_attributes to avoid any further fetch on it.
TYPE varchar_30_idx_bi_tbl_type is table of VARCHAR2(30) index by BINARY_INTEGER;
   record_type_code_tbl        varchar_30_idx_bi_tbl_type;
   line_level_action_tbl       varchar_30_idx_bi_tbl_type;

TYPE varchar_1_idx_bi_tbl_type is table of VARCHAR2(1) index by BINARY_INTEGER;
   partner_migrated_flag_tbl   varchar_1_idx_bi_tbl_type;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_migrated_doc_info
--
--  DESCRIPTION
--  If the source document is migrated for an incoming adjusted document,
--  then applicable regimes may not have been populated in ZX_TRX_LINE_APP_REGIMES.
--  In this scenario, return the standard regime to be populated in
--  ZX_TRX_LINE_APP_REGIMES.
--
--  CALLED BY
--    popl_pvrdr_info_tax_reg_tbl
-----------------------------------------------------------------------

PROCEDURE get_migrated_doc_info (
  p_trx_line_index            IN         NUMBER,
  x_migrated_tax_provider_id  OUT NOCOPY NUMBER,
  x_migrated_tax_regime_code  OUT NOCOPY VARCHAR2,
  x_migrated_tax_regime_id    OUT NOCOPY NUMBER,
  x_migrated_effective_from   OUT NOCOPY DATE,    -- Bug 5557565
  x_migrated_effective_to     OUT NOCOPY DATE,    -- Bug 5557565
  x_migrated_country_code     OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2
) IS
  l_api_name           CONSTANT VARCHAR2(30) := 'GET_MIGRATED_DOC_INFO';
  l_context_info_rec   ZX_API_PUB.context_info_rec_type;
  l_mig_trx_date       zx_lines.trx_date%type;
  l_mig_first_pty_id   number;
  l_mig_exists         number;
  l_mig_glb_att_cat    zx_lines.global_attribute_category%type;
  BEGIN
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   /*Set the return status to Success */
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   IF ZX_API_PUB.G_PUB_SRVC in ('CALCULATE_TAX','IMPORT_DOCUMENT_WITH_TAX') THEN

     IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(p_trx_line_index) is not NULL THEN
       BEGIN --- bug6024643
         SELECT tax_provider_id,
            tax_regime_code
         INTO x_migrated_tax_provider_id,
           x_migrated_tax_regime_code
         FROM ZX_LINES
	 WHERE application_id   = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(p_trx_line_index)
	   AND entity_code      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_entity_code(p_trx_line_index)
	   AND event_class_code = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_event_class_code(p_trx_line_index)
	   AND trx_id           = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_id(p_trx_line_index)
	   AND trx_line_id      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_line_id(p_trx_line_index)
	   AND trx_level_type   = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_level_type(p_trx_line_index)
	   AND rownum           = 1;

    --- bug6024643
       EXCEPTION
		WHEN OTHERS THEN
		null;
      END;
     ELSIF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(p_trx_line_index) is not NULL THEN
       BEGIN --- bug6024643
         SELECT tax_provider_id,
                tax_regime_code,
                trx_date,
                content_owner_id,
                global_attribute_category
           INTO x_migrated_tax_provider_id,
                x_migrated_tax_regime_code,
                l_mig_trx_date,
                l_mig_first_pty_id,
                l_mig_glb_att_cat
           FROM ZX_LINES
	    WHERE application_id   = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(p_trx_line_index)
	      AND entity_code      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_entity_code(p_trx_line_index)
	      AND event_class_code = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_event_class_code(p_trx_line_index)
	      AND trx_id           = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_id(p_trx_line_index)
	      AND trx_line_id      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_line_id(p_trx_line_index)
	      AND trx_level_type   = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_level_type(p_trx_line_index)
	      AND rownum           = 1;
    --- bug6024643
       EXCEPTION
		WHEN OTHERS THEN
		null;
       END;
       IF x_migrated_tax_regime_code IS NOT NULL AND x_migrated_tax_provider_id > 0 THEN
         BEGIN
           SELECT 1
             INTO l_mig_exists
             FROM zx_srvc_subscriptions srvc,
                  zx_regimes_usages usg
            WHERE srvc.regime_usage_id = usg.regime_usage_id
              AND l_mig_trx_date between srvc.effective_from and nvl(srvc.effective_to,l_mig_trx_date)
              AND srvc.srvc_provider_id = x_migrated_tax_provider_id
              AND usg.first_pty_org_id = l_mig_first_pty_id
              AND usg.tax_regime_code = x_migrated_tax_regime_code
              AND rownum = 1;
         EXCEPTION
           WHEN OTHERS THEN
             l_mig_exists := 0;
         END;
         IF Nvl(l_mig_exists,0) = 0 AND l_mig_glb_att_cat IS NOT NULL THEN
           BEGIN
             SELECT usg.tax_regime_code
               into x_migrated_tax_regime_code
               from zx_srvc_subscriptions srvc,
                    zx_regimes_usages usg
              where srvc.regime_usage_id = usg.regime_usage_id
                and l_mig_trx_date between srvc.effective_from and nvl(srvc.effective_to,l_mig_trx_date)
                and srvc.enabled_flag = 'Y'
                and srvc_provider_id = x_migrated_tax_provider_id
                and usg.first_pty_org_id = l_mig_first_pty_id
                and rownum = 1;
           EXCEPTION
             WHEN OTHERS THEN NULL;
           END;
         END IF;
       END IF;
    END IF;
    IF x_migrated_tax_regime_code IS NOT NULL THEN --- bug6024643
       SELECT tax_regime_id
            , effective_from
            , effective_to
            , country_code
         INTO x_migrated_tax_regime_id
            , x_migrated_effective_from    -- Bug 5557565
            , x_migrated_effective_to      -- Bug 5557565
            , x_migrated_country_code
        FROM ZX_REGIMES_B
       WHERE tax_regime_code = x_migrated_tax_regime_code;
    END IF; --- bug6024643
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.END',
         G_PKG_NAME ||': '||l_api_name||'(-)'||' RETURN_STATUS = ' || x_return_status);
   END IF;

   EXCEPTION
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;
      RETURN;
  END get_migrated_doc_info;


-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  popl_all_regimes_tbl
--
--  DESCRIPTION
--  This procedure temporarily copies all applicable regimes for a line
--  into trx_line_app_regimes_tbl structure before bulk inserting into db
--  table ZX_TRX_LINE_APP_REGIMES
--
--  CALLED BY
--    popl_pvrdr_info_tax_reg_tbl
-----------------------------------------------------------------------
PROCEDURE popl_all_regimes_tbl (
 p_event_class_rec    IN  ZX_API_PUB.event_class_rec_type,
 p_trx_line_id        IN  NUMBER,
 p_trx_level_type     IN  VARCHAR2,
 p_tax_regime_id      IN  NUMBER,
 p_tax_regime_code    IN  VARCHAR2,
 p_tax_provider_id    IN  NUMBER,
 x_return_status      OUT NOCOPY VARCHAR2
 ) IS
  l_api_name          CONSTANT VARCHAR2(30) := 'POPL_ALL_REGIMES_TBL';
  l_count             NUMBER;
 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   /*Set the return status to Success */
   x_return_status := FND_API.G_RET_STS_SUCCESS;

/* Storing of eBTax regimes in zx_trx_line_app_regimes table is expensive from performance and storage perspective
   By not storing these regimes, we will not be able to handle scenario of eBTax to tax provider switch scenario */

   IF p_tax_provider_id IS NOT NULL THEN
      l_count :=ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.application_id.COUNT+1 ;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                ' l_count = ' || l_count);
      END IF;
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.application_id(l_count) :=
                                                     p_event_class_rec.application_id;
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.entity_code(l_count) :=
                                                     p_event_class_rec.entity_code;
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.event_class_code(l_count) :=
                                                     p_event_class_rec.event_class_code;
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.trx_id(l_count) := p_event_class_rec.trx_id;
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.trx_line_id(l_count) := p_trx_line_id;
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.trx_level_type(l_count) := p_trx_level_type;
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.tax_regime_id(l_count) := p_tax_regime_id;
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.tax_regime_code(l_count) := p_tax_regime_code;
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.tax_provider_id(l_count) := p_tax_provider_id;
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.allow_tax_calculation_flag(l_count) :=
                                                     p_event_class_rec.process_for_applicability_flag;
      ZX_GLOBAL_STRUCTURES_PKG.G_PTNR_SRVC_SUBSCR_FLAG := 'Y';
   END IF;
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;
 END popl_all_regimes_tbl;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  set_detail_tax_line_values
--
--  DESCRIPTION
--  This procedure assigns the values that need to be populated to
--  zx_detail_tax_lines_gt
--
--  CALLED BY
--    ptnr_post_processing_calc_tax
-----------------------------------------------------------------------
PROCEDURE set_detail_tax_line_values (
 p_event_class_rec       IN  ZX_API_PUB.event_class_rec_type,
 p_ptnr_tax_line_ind     IN  NUMBER,
 p_tax_provider_id       IN  NUMBER,
 x_return_status         OUT NOCOPY VARCHAR2
 ) IS
  l_api_name          CONSTANT VARCHAR2(30) := 'SET_DETAIL_TAX_LINE_VALUES';
  l_count             NUMBER;

  prev_tax_regime_code     zx_regimes_b.tax_regime_code%type;
  l_tax_regime_id          zx_regimes_b.tax_regime_id%type;

  prev_application_id      zx_lines_det_factors.application_id%type;
  prev_entity_code         zx_lines_det_factors.entity_code%type;
  prev_event_class_code    zx_lines_det_factors.event_class_code%type;
  prev_trx_id              zx_lines_det_factors.trx_id%type;
  prev_trx_line_id         zx_lines_det_factors.trx_line_id%type;
  prev_trx_level_type      zx_lines_det_factors.trx_level_type%type;
  l_lines_det_fact_rec     zx_lines_det_factors%rowtype;
  l_historical_flag        VARCHAR2(1);
  l_ptnr_exemption_indx    VARCHAR2(4000);
  l_tax_account_source_tax ZX_TAXES_B.TAX_ACCOUNT_SOURCE_TAX%TYPE;

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   /*Set the return status to Success */
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.internal_organization_id(p_ptnr_tax_line_ind)      := p_event_class_rec.internal_organization_id;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.application_id(p_ptnr_tax_line_ind)                := p_event_class_rec.application_id;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.entity_code(p_ptnr_tax_line_ind)                   := p_event_class_rec.entity_code;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.event_class_code(p_ptnr_tax_line_ind)              := p_event_class_rec.event_class_code;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.event_type_code(p_ptnr_tax_line_ind)               := p_event_class_rec.event_type_code;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.doc_event_status(p_ptnr_tax_line_ind)              := p_event_class_rec.doc_status_code;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_event_class_code(p_ptnr_tax_line_ind)          := p_event_class_rec.tax_event_class_code;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_event_type_code(p_ptnr_tax_line_ind)           := p_event_class_rec.tax_event_type_code;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.ledger_id(p_ptnr_tax_line_ind)                     := p_event_class_rec.ledger_id;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.legal_entity_id(p_ptnr_tax_line_ind)               := p_event_class_rec.legal_entity_id;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_provider_id(p_ptnr_tax_line_ind)               := p_tax_provider_id;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.cancel_flag(p_ptnr_tax_line_ind)                   := 'N';
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.compounding_tax_flag(p_ptnr_tax_line_ind)          := 'N';
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.reporting_only_flag(p_ptnr_tax_line_ind)           := 'N';
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.copied_from_other_doc_flag(p_ptnr_tax_line_ind)    := 'N';
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.historical_flag(p_ptnr_tax_line_ind)               := 'N';
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.offset_flag(p_ptnr_tax_line_ind)                   := 'N';
   -- Bug 8298174
   -- ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.process_for_recovery_flag(p_ptnr_tax_line_ind)     := 'N';
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.process_for_recovery_flag(p_ptnr_tax_line_ind)     := NVL(p_event_class_rec.tax_recovery_flag, 'N');
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.purge_flag(p_ptnr_tax_line_ind)                    := 'N';
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.freeze_until_overridden_flag(p_ptnr_tax_line_ind)  := 'N';
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.mrc_tax_line_flag(p_ptnr_tax_line_ind)             := 'N'; -- Bug 5162537
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_apportionment_flag(p_ptnr_tax_line_ind)        := 'N';
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_line_number(p_ptnr_tax_line_ind)               := NUMBER_DUMMY;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.taxable_amt_tax_curr(p_ptnr_tax_line_ind)          := ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.taxable_amount(p_ptnr_tax_line_ind);
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_determine_date(p_ptnr_tax_line_ind)            := ZX_SECURITY.G_EFFECTIVE_DATE;

   IF prev_trx_line_id          = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.transaction_line_id(p_ptnr_tax_line_ind)
      AND prev_trx_level_type   = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.trx_level_type(p_ptnr_tax_line_ind)
      AND prev_application_id   = p_event_class_rec.application_id
      AND prev_entity_code      = p_event_class_rec.entity_code
      AND prev_event_class_code = p_event_class_rec.event_class_code
      AND prev_trx_id           = p_event_class_rec.trx_id
   THEN
      null;
   ELSE
      BEGIN
         SELECT *
           INTO l_lines_det_fact_rec
           FROM zx_lines_det_factors
          WHERE application_id   = p_event_class_rec.application_id
            AND entity_code      = p_event_class_rec.entity_code
            AND event_class_code = p_event_class_rec.event_class_code
            AND trx_id           = p_event_class_rec.trx_id
            AND trx_line_id      = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.transaction_line_id(p_ptnr_tax_line_ind)
            AND trx_level_type   = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.trx_level_type(p_ptnr_tax_line_ind);
      END;
      prev_trx_line_id      := ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.transaction_line_id(p_ptnr_tax_line_ind);
      prev_trx_level_type   := ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.trx_level_type(p_ptnr_tax_line_ind);
      prev_application_id   := p_event_class_rec.application_id;
      prev_entity_code      := p_event_class_rec.entity_code;
      prev_event_class_code := p_event_class_rec.event_class_code;
      prev_trx_id           := p_event_class_rec.trx_id;
   END IF;

   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.trx_number(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.trx_number;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.trx_line_number(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.trx_line_number;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.trx_currency_code(p_ptnr_tax_line_ind) := nvl(l_lines_det_fact_rec.trx_currency_code, l_lines_det_fact_rec.trx_line_currency_code);
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.trx_date(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.trx_date;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.unit_price(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.unit_price;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.line_amt(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.line_amt;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.trx_line_quantity(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.trx_line_quantity;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_date(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.trx_date;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.trx_line_date(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.trx_line_date;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_currency_conversion_date(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.trx_date;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.applied_from_application_id(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.applied_from_application_id;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.applied_from_entity_code(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.applied_from_entity_code;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.applied_from_event_class_code(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.applied_from_event_class_code;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.applied_from_trx_id(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.applied_from_trx_id;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.applied_from_line_id(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.applied_from_line_id;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.applied_from_trx_level_type(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.applied_from_trx_level_type;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.applied_from_trx_number(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.applied_from_trx_number;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_application_id(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.adjusted_doc_application_id;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_entity_code(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.adjusted_doc_entity_code;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_event_class_code(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.adjusted_doc_event_class_code;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_trx_id(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.adjusted_doc_trx_id;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_line_id(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.adjusted_doc_line_id;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_trx_level_type(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.adjusted_doc_trx_level_type;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_number(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.adjusted_doc_number;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_date(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.adjusted_doc_date;
   record_type_code_tbl(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.record_type_code;
   line_level_action_tbl(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.line_level_action;
   partner_migrated_flag_tbl(p_ptnr_tax_line_ind) := l_lines_det_fact_rec.partner_migrated_flag;

   IF ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_application_id(p_ptnr_tax_line_ind) IS NOT NULL THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' adjusted_doc_application_id = ' || ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_application_id(p_ptnr_tax_line_ind));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' adjusted_doc_entity_code = ' || ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_entity_code(p_ptnr_tax_line_ind));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' adjusted_doc_event_class_code = ' || ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_event_class_code(p_ptnr_tax_line_ind));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' adjusted_doc_trx_id = ' || ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_trx_id(p_ptnr_tax_line_ind));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' adjusted_doc_line_id = ' || ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_line_id(p_ptnr_tax_line_ind));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
           ' trx_level_type = ' || ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.trx_level_type(p_ptnr_tax_line_ind));
    END IF;
     BEGIN
       SELECT historical_flag INTO l_historical_flag
       FROM ZX_LINES_DET_FACTORS
       WHERE application_id = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_application_id(p_ptnr_tax_line_ind)
       AND entity_code      = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_entity_code(p_ptnr_tax_line_ind)
       AND event_class_code = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_event_class_code(p_ptnr_tax_line_ind)
       AND trx_id           = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_trx_id(p_ptnr_tax_line_ind)
       AND trx_line_id      = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_line_id(p_ptnr_tax_line_ind)
       AND trx_level_type   = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_trx_level_type(p_ptnr_tax_line_ind);
     EXCEPTION
       WHEN OTHERS THEN
         l_historical_flag := NULL;
     END;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' l_historical_flag = ' || l_historical_flag);
     END IF;
     IF NVL(l_historical_flag,'N') = 'N' THEN
       BEGIN
         SELECT tax_line_id
         INTO ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_tax_line_id(p_ptnr_tax_line_ind)
         FROM zx_lines
         WHERE application_id = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_application_id(p_ptnr_tax_line_ind)
         AND entity_code      = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_entity_code(p_ptnr_tax_line_ind)
         AND event_class_code = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_event_class_code(p_ptnr_tax_line_ind)
         AND trx_id           = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_trx_id(p_ptnr_tax_line_ind)
         AND trx_line_id      = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_line_id(p_ptnr_tax_line_ind)
         AND trx_level_type   = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_trx_level_type(p_ptnr_tax_line_ind)
         AND tax_regime_code  = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.country_code(p_ptnr_tax_line_ind)
         AND tax              = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(p_ptnr_tax_line_ind);

       EXCEPTION
         WHEN TOO_MANY_ROWS THEN
           BEGIN
             SELECT tax_line_id
             INTO ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_tax_line_id(p_ptnr_tax_line_ind)
             FROM zx_lines
             WHERE application_id = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_application_id(p_ptnr_tax_line_ind)
             AND entity_code      = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_entity_code(p_ptnr_tax_line_ind)
             AND event_class_code = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_event_class_code(p_ptnr_tax_line_ind)
             AND trx_id           = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_trx_id(p_ptnr_tax_line_ind)
             AND trx_line_id      = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_line_id(p_ptnr_tax_line_ind)
             AND trx_level_type   = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_trx_level_type(p_ptnr_tax_line_ind)
             AND tax_regime_code  = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.country_code(p_ptnr_tax_line_ind)
             AND tax              = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(p_ptnr_tax_line_ind)
             AND tax_rate_code    = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_rate_code(p_ptnr_tax_line_ind);
           EXCEPTION
             WHEN OTHERS THEN
               ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_tax_line_id(p_ptnr_tax_line_ind) := NULL;
           END;
       WHEN OTHERS THEN
         ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_tax_line_id(p_ptnr_tax_line_ind) := NULL;
       END;
     ELSE
       BEGIN
            SELECT tax_line_id
            INTO ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_tax_line_id(p_ptnr_tax_line_ind)
            FROM zx_lines
            WHERE application_id = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_application_id(p_ptnr_tax_line_ind)
            AND entity_code      = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_entity_code(p_ptnr_tax_line_ind)
            AND event_class_code = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_event_class_code(p_ptnr_tax_line_ind)
            AND trx_id           = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_trx_id(p_ptnr_tax_line_ind)
            AND trx_line_id      = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_line_id(p_ptnr_tax_line_ind)
            AND trx_level_type   = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_trx_level_type(p_ptnr_tax_line_ind)
	          AND tax_regime_code  = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.country_code(p_ptnr_tax_line_ind);

       EXCEPTION
	       WHEN OTHERS THEN
	         ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_tax_line_id(p_ptnr_tax_line_ind) := NULL;
       END;
     END IF;
   ELSE
     ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_tax_line_id(p_ptnr_tax_line_ind) := NULL;
   END IF;
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' adjusted_doc_tax_line_id = ' || ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_tax_line_id(p_ptnr_tax_line_ind));
   END IF;
   IF prev_tax_regime_code IS NULL
      OR prev_tax_regime_code <> ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.country_code(p_ptnr_tax_line_ind) THEN
      BEGIN
         SELECT tax_regime_id
           INTO l_tax_regime_id
           FROM zx_regimes_b
           WHERE tax_regime_code = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.country_code(p_ptnr_tax_line_ind);
      END;
      prev_tax_regime_code := ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.country_code(p_ptnr_tax_line_ind);
   END IF;
   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_regime_id(p_ptnr_tax_line_ind) := l_tax_regime_id;

   BEGIN
      SELECT tax_jurisdiction_id
        INTO ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_jurisdiction_id(p_ptnr_tax_line_ind)
        FROM ZX_JURISDICTIONS_B
       WHERE tax_jurisdiction_code = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_jurisdiction(p_ptnr_tax_line_ind);
   EXCEPTION WHEN OTHERS THEN
      ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_jurisdiction_id(p_ptnr_tax_line_ind) := NULL;
   END;

   -- adding code to populate exemption details in partner calculated tax lines
   BEGIN
     SELECT TAX_ACCOUNT_SOURCE_TAX
     INTO l_tax_account_source_tax
     FROM ZX_SCO_TAXES_B_V
     WHERE tax_regime_code = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.country_code(p_ptnr_tax_line_ind)
     AND tax = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(p_ptnr_tax_line_ind)
     AND ( ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.trx_date(p_ptnr_tax_line_ind) >= effective_from
           AND (ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.trx_date(p_ptnr_tax_line_ind) <= effective_to
	        OR effective_to IS NULL));
   EXCEPTION
     WHEN OTHERS THEN
       NULL;
   END;
   l_ptnr_exemption_indx := to_char(ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.transaction_id(p_ptnr_tax_line_ind)) || '$' ||
                            to_char(ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.transaction_line_id(p_ptnr_tax_line_ind)) || '$' ||
			    NVL(l_tax_account_source_tax, ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(p_ptnr_tax_line_ind)) || '$' ||
			    ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.country_code(p_ptnr_tax_line_ind) || '$' ||
                            to_char(ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_provider_id(p_ptnr_tax_line_ind));

   IF ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl.EXISTS(l_ptnr_exemption_indx)
   AND ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).trx_id
                 = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.transaction_id(p_ptnr_tax_line_ind)
   AND ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).trx_line_id
                 = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.transaction_line_id(p_ptnr_tax_line_ind)
   AND ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).tax
                 = NVL(l_tax_account_source_tax, ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(p_ptnr_tax_line_ind))
   AND ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).tax_regime_code
                 = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.country_code(p_ptnr_tax_line_ind)
   AND ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).tax_provider_id
                 = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_provider_id(p_ptnr_tax_line_ind)
   THEN

     ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_exemption_id(p_ptnr_tax_line_ind) := ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).tax_exemption_id;
     ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.exempt_certificate_number(p_ptnr_tax_line_ind) := ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).exempt_certificate_number;

     IF ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(p_ptnr_tax_line_ind) = 'STATE' THEN
        ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.exempt_reason_code(p_ptnr_tax_line_ind) :=
          ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).st_exempt_reason_code;
        ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.exempt_reason(p_ptnr_tax_line_ind) :=
          ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).st_exempt_reason;
     ELSIF ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(p_ptnr_tax_line_ind) = 'COUNTY' THEN
        ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.exempt_reason_code(p_ptnr_tax_line_ind) :=
          ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).co_exempt_reason_code;
        ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.exempt_reason(p_ptnr_tax_line_ind) :=
          ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).co_exempt_reason;
     ELSIF ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(p_ptnr_tax_line_ind) = 'CITY' THEN
        ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.exempt_reason_code(p_ptnr_tax_line_ind) :=
          ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).ci_exempt_reason_code;
        ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.exempt_reason(p_ptnr_tax_line_ind) :=
          ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).ci_exempt_reason;
     ELSIF ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(p_ptnr_tax_line_ind) = 'DISTRICT' THEN
        ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.exempt_reason_code(p_ptnr_tax_line_ind) :=
          ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).di_exempt_reason_code;
        ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.exempt_reason(p_ptnr_tax_line_ind) :=
          ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).di_exempt_reason;
     ELSE
        ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.exempt_reason_code(p_ptnr_tax_line_ind) :=
          ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).st_exempt_reason_code;
        ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.exempt_reason(p_ptnr_tax_line_ind) :=
          ZX_GLOBAL_STRUCTURES_PKG.ptnr_exemption_tbl(l_ptnr_exemption_indx).st_exempt_reason;
     END IF;

   ELSE
     ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_exemption_id(p_ptnr_tax_line_ind) := NULL;
     ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.exempt_reason_code(p_ptnr_tax_line_ind) := NULL;

   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' tax_exemption_id = ' || ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_exemption_id(p_ptnr_tax_line_ind));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' exempt_reason_code = ' || ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.exempt_reason_code(p_ptnr_tax_line_ind));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' exempt_reason = ' || ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.exempt_reason(p_ptnr_tax_line_ind));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' exempt_certificate_number = ' || ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.exempt_certificate_number(p_ptnr_tax_line_ind));
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME ||': '||l_api_name||'(-)');
   END IF;

   EXCEPTION
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;
      RETURN;
 END set_detail_tax_line_values;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  exemption_handling
--
--  DESCRIPTION
--
--  CALLED BY
-----------------------------------------------------------------------
/*****************TBD*************************************************
PROCEDURE exemption_handling (
 p_event_class_rec    IN  ZX_API_PUB.event_class_rec_type,
 p_trx_line_id        IN  NUMBER,
 p_trx_level_type     IN  VARCHAR2,
 p_tax_regime_id      IN  NUMBER,
 p_tax_regime_code    IN  VARCHAR2,
 p_tax_provider_id    IN  NUMBER,
 x_return_status      OUT NOCOPY VARCHAR2
 ) IS
  l_api_name          CONSTANT VARCHAR2(30) := 'EXEMPTION_HANDLING';
  l_count             NUMBER;
 BEGIN
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   --Set the return status to Success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR exemption_index IN  ZX_PTNR_SRVC_INTGRTN_PKG.g_exemption_tbl.TAX.FIRST..
                           nvl(ZX_PTNR_SRVC_INTGRTN_PKG.g_exemption_tbl.TAX.LAST,0)
   LOOP
     SELECT exempt_certificate_number
       FROM ZX_EXEMPTIONS
      WHERE content_owner_id = p_event_class_rec.first_pty_org_id
        AND product_id       = ??
        AND inventory_org_id = ??
        AND exemption_status_code = ??
        AND exempt_certificate_number = ZX_PTNR_SRVC_INTGRTN_PKG.g_exemption_tbl(exemption_index).EXEMPT_CERTIFICATE_NUMBER
        AND exempt_reason_code        = ZX_PTNR_SRVC_INTGRTN_PKG.g_exemption_tbl(exemption_index).EXEMPT_REASON_CODE
        AND duplicate_exemption       = ??
        AND tax                       = ZX_PTNR_SRVC_INTGRTN_PKG.g_exemption_tbl(exemption_index).TAX
        AND tax_status_code           = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl(p_tax_line_index).TAX_STATUS_CODE
        AND tax_jurisdiction_id       = ??
        AND tax_rate_code             = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl(p_tax_line_index).TAX_STATUS_CODE
        AND effective_from            = G_EFFECTIVE_DATE
        AND tax_regime_code           = ??
        AND party_tax_profile_id      = ??

           ZX_TCM_GET_EXEMPT_PKG.get_tax_exemptions(
           p_bill_to_cust_site_use_id  => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_to_cust_acct_site_use_id(p_structure_index),
           p_bill_to_cust_acct_id      => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_third_pty_acct_id(p_structure_index),
           p_bill_to_party_site_ptp_id => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_to_site_tax_prof_id(p_structure_index),
           p_bill_to_party_ptp_id      => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.bill_to_party_tax_prof_id(p_structure_index),
           p_sold_to_party_site_ptp_id => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trading_hq_site_tax_prof_id(p_structure_index),
           p_sold_to_party_ptp_id      => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.trading_hq_party_tax_prof_id(p_structure_index),
           p_inventory_org_id          => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_org_id(p_structure_index),
           p_inventory_item_id         => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_id(p_structure_index),
           p_exempt_certificate_number  => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.exempt_certificate_number(p_structure_index),
           p_reason_code               => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.exempt_reason_code(p_structure_index),
           p_exempt_control_flag       => ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.exemption_control_flag(p_structure_index),
           p_tax_date                  => l_tax_date,
           p_tax_regime_code           => l_tax_regime_code,
           p_tax                       => l_tax,
           p_tax_status_code           => l_tax_status_code,
           p_tax_rate_code             => l_tax_rate_code,
           p_tax_jurisdiction_id       => l_tax_jurisdiction_id,
           p_multiple_jurisdictions_flag => l_multiple_jurisdictions_flag,
           p_event_class_rec           => p_event_class_rec,
           x_return_status             => p_return_status,
           x_exemption_rec             => l_exemption_rec);
   END LOOP;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME ||': '||l_api_name||'(-)');
   END IF;
 END exemption_handling;
*/

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  trx_line_app_regimes_tbl_hdl
--
--  DESCRIPTION
--  This is a table handler on ZX_TRX_LINE_APP_REGIMES
--
--  Argument of interest
--  p_event - takes following values
--   INSERT       inserts at end of post calculation
--   SET_FLAG     sets update_flag to indicate which transaction lines
--                are being updated;this will ease out the setting of partner
--                processing flag later
--   RESET_FLAG   resets update_flag at the end of processing
--   DELETE       Deletes all non-applicable regimes if provider not applicable
--
--  CALLED BY
--    ptnr_post_processing_calc_tax
--    ZX_SRVC_TYPS_PKG.calculate_tax_pvt
--    ZX_SRVC_TYPS_PKG.calculate_tax
-----------------------------------------------------------------------


PROCEDURE trx_line_app_regimes_tbl_hdl(
 p_event_class_rec        IN  ZX_API_PUB.event_class_rec_type,
 p_event                  IN  VARCHAR2,
 p_tax_regime_code        IN  VARCHAR2,
 p_provider_id            IN  NUMBER,
 p_trx_line_id            IN  NUMBER,
 p_trx_level_type         IN  VARCHAR2,
 x_return_status          OUT NOCOPY VARCHAR2
 )IS
  l_api_name             CONSTANT VARCHAR2(30):= 'TRX_LINE_APP_REGIMES_TBL_HDL';
  l_dummy                NUMBER;
  l_context_info_rec     ZX_API_PUB.context_info_rec_type;

  BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

    /*Set the return status to Success */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_event = 'INSERT' THEN
      FOR i IN nvl(ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.application_id.FIRST,0) .. nvl(ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.application_id.LAST,-1)
      LOOP
         IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.application_id(i) = p_event_class_rec.application_id
            AND ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.entity_code(i) = p_event_class_rec.entity_code
            AND ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.event_class_code(i) = p_event_class_rec.event_class_code
            AND ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.trx_id(i) = p_event_class_rec.trx_id THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                     ' Application Id = ' || p_event_class_rec.application_id ||
                     ' Entity code = ' || p_event_class_rec.entity_code ||
                     ' Event Class code = ' || p_event_class_rec.event_class_code ||
                     ' Trx Id           = ' || p_event_class_rec.trx_id ||
                     ' Trx Line Id      = ' || ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.trx_line_id(i) ||
                     ' Tax Regime code = ' || ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.tax_regime_code(i));
            END IF;

            BEGIN
               SELECT 1
                 INTO l_dummy
                 FROM zx_trx_line_app_regimes
                WHERE application_id   = p_event_class_rec.application_id
                  AND entity_code      = p_event_class_rec.entity_code
                  AND event_class_code = p_event_class_rec.event_class_code
                  AND trx_id           = p_event_class_rec.trx_id
                  AND trx_line_id      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.trx_line_id(i)
                  AND trx_level_type   =ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.trx_level_type(i)
                  AND tax_regime_code  = ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.tax_regime_code(i);
	    EXCEPTION
	       WHEN OTHERS THEN
                  BEGIN
                     INSERT INTO ZX_TRX_LINE_APP_REGIMES(APPLICATION_ID,
                                                     ENTITY_CODE,
                                                     EVENT_CLASS_CODE,
                                                     TRX_ID,
                                                     TRX_LINE_ID,
                                                     TRX_LEVEL_TYPE,
                                                     TAX_REGIME_ID,
                                                     TAX_REGIME_CODE,
                                                     TAX_PROVIDER_ID,
                                                     ALLOW_TAX_CALCULATION_FLAG,
                                                     PSEUDO_TAX_ONLY_LINE_FLAG,
                                                     CREATION_DATE,
                                                     CREATED_BY,
                                                     LAST_UPDATE_DATE,
                                                     LAST_UPDATED_BY,
                                                     LAST_UPDATE_LOGIN
					            )
			             VALUES         (ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.application_id(i),
			                             ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.entity_code(i),
				                     ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.event_class_code(i),
				                     ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.trx_id(i),
				                     ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.trx_line_id(i),
				                     ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.trx_level_type(i),
				                     ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.tax_regime_id(i),
				                     ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.tax_regime_code(i),
				                     ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.tax_provider_id(i),
				                     ZX_GLOBAL_STRUCTURES_PKG.trx_line_app_regime_tbl.allow_tax_calculation_flag(i),
                                                     'N',
					             sysdate,
                                                     fnd_global.user_id,
                                                     sysdate,
                                                     fnd_global.user_id,
                                                     fnd_global.conc_login_id
					             ) ;
	          EXCEPTION
	             WHEN OTHERS THEN
                        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                        IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
                           FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
                        END IF;
                  END;
            END;
        END IF;
      END LOOP;
    ELSIF p_event = 'DELETE' THEN
      DELETE from ZX_TRX_LINE_APP_REGIMES
       WHERE application_id   = p_event_class_rec.application_id
         AND entity_code      = p_event_class_rec.entity_code
         AND event_class_code = p_event_class_rec.event_class_code
         AND trx_id           = p_event_class_rec.trx_id
         AND tax_provider_id  = p_provider_id
	 AND tax_regime_code  = p_tax_regime_code;
    ELSIF p_event = 'SET_FLAG' THEN
      UPDATE zx_trx_line_app_regimes
        SET update_flag ='Y'
      WHERE application_id   = p_event_class_rec.application_id
        AND entity_code      = p_event_class_rec.entity_code
        AND event_class_code = p_event_class_rec.event_class_code
        AND trx_id           = p_event_class_rec.trx_id
        AND trx_line_id      = p_trx_line_id
        AND trx_level_type   = p_trx_level_type;
    ELSIF p_event = 'RESET_FLAG' THEN
      UPDATE zx_trx_line_app_regimes
        SET update_flag = null
      WHERE application_id   = p_event_class_rec.application_id
        AND entity_code      = p_event_class_rec.entity_code
        AND event_class_code = p_event_class_rec.event_class_code
        AND trx_id           = p_event_class_rec.trx_id
	AND update_flag      = 'Y';
    END IF;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
         G_PKG_NAME ||': '||l_api_name||'(-)'||' RETURN_STATUS = ' || x_return_status);
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
        END IF;
  END trx_line_app_regimes_tbl_hdl;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  popl_pvrdr_info_tax_reg_tbl
--
--  DESCRIPTION
--  This procedure loops over the returned detail tax regimes table to
--  determine if provider is applicable for the given regime for a given line.
--  On determining that a provider is applicable for a regime, it stamps the
--  provider id on the tax regime table so that TDS calculate tax process
--  may ignore it.
--  This procedure also invokes call to populate all the applicable regimes
--  for a line in trx_line_app_regime_tbl
--
--  CALLED BY
--     ZX_SRVC_TYPS_PKG.calculate_tax_pvt
--     ZX_SRVC_TYPS_PKG.import
-----------------------------------------------------------------------


PROCEDURE popl_pvrdr_info_tax_reg_tbl (
 p_event_class_rec    IN  ZX_API_PUB.event_class_rec_type,
 p_trx_line_index     IN  BINARY_INTEGER,
 x_return_status      OUT NOCOPY VARCHAR2
 ) IS
  l_api_name                   CONSTANT VARCHAR2(30) := 'POPL_PVRDR_INFO_TAX_REG_TBL';
  l_provider_id                NUMBER;
  l_ptnr_migrated_flag         VARCHAR2(1);
  l_migrated_tax_provider_id   NUMBER;
  l_migrated_tax_regime_id     NUMBER;
  l_migrated_tax_regime_code   VARCHAR2(30);
  l_migrated_effective_from    DATE;
  l_migrated_effective_to      DATE;
  l_return_status              VARCHAR2(1);
  l_tax_regime_id              NUMBER;
  l_migrated_country_code      ZX_REGIMES_B.country_code%TYPE;
  l_context_info_rec           ZX_API_PUB.context_info_rec_type;

/* Bug 5557565 */

  CURSOR app_doc_regime_csr(l_index NUMBER) IS
   SELECT ztlar.tax_regime_id,
          ztlar.tax_regime_code,
          ztlar.tax_provider_id,
          regimes.effective_from,
          regimes.effective_to,
          regimes.country_code
     FROM ZX_TRX_LINE_APP_REGIMES ztlar
        , zx_regimes_b regimes
    WHERE ztlar.application_id   = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(l_index)
      AND ztlar.entity_code      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_entity_code(l_index)
      AND ztlar.event_class_code = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_event_class_code(l_index)
      AND ztlar.trx_id           = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_id(l_index)
      AND ztlar.trx_line_id      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_line_id(l_index)
      AND ztlar.trx_level_type   = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_level_type(l_index)
      AND ztlar.tax_regime_id    = regimes.tax_regime_id;

  CURSOR adj_doc_regime_csr(l_index NUMBER) IS
   SELECT ztlar.tax_regime_id,
          ztlar.tax_regime_code,
          ztlar.tax_provider_id,
          regimes.effective_from,
          regimes.effective_to,
          regimes.country_code
     FROM ZX_TRX_LINE_APP_REGIMES ztlar
        , zx_regimes_b regimes
     WHERE ztlar.application_id   = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(l_index)
       AND ztlar.entity_code      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_entity_code(l_index)
       AND ztlar.event_class_code = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_event_class_code(l_index)
       AND ztlar.trx_id           = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_id(l_index)
       AND ztlar.trx_line_id      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_line_id(l_index)
       AND ztlar.trx_level_type   = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_level_type(l_index)
       AND ztlar.tax_regime_id    = regimes.tax_regime_id;

/* Bug 5557565 */

  app_docs   app_doc_regime_csr%ROWTYPE;
  adj_docs   adj_doc_regime_csr%ROWTYPE;


 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   --Set the return status to Success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Populate the product business group in the global variable - needed to determine the service provider
   ZX_TAX_PARTNER_PKG.G_BUSINESS_FLOW   := p_event_class_rec.prod_family_grp_code;

   --ZX_TDS_CALC_SERVICES_PUB_PKG.get_tax_regimes does not return any regimes for the transaction lines in the following conditions.
   --            applied_from_application_id is not null
   --            adjusted_doc_application_id is not null
   -- For these lines, fetch the applicable regimes from ZX_TRX_LINE_APP_REGIMES and
   -- Populate ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl if regime does not already exist

   --If applied from document

   IF ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl.COUNT=0
   AND ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(p_trx_line_index) is not NULL THEN
     --APPLIED_FROM_DOCUMENT - check if original document is migrated
     BEGIN
       SELECT nvl(partner_migrated_flag, 'N')     -- Bug 5007293
         INTO l_ptnr_migrated_flag
         FROM ZX_LINES_DET_FACTORS
         WHERE application_id   = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_application_id(p_trx_line_index)
           AND entity_code      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_entity_code(p_trx_line_index)
           AND event_class_code = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_event_class_code(p_trx_line_index)
           AND trx_id           = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_id(p_trx_line_index)
           AND trx_line_id      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_line_id(p_trx_line_index)
           AND trx_level_type   = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.applied_from_trx_level_type(p_trx_line_index);

     EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_ptnr_migrated_flag := 'N';
     END;

     IF l_ptnr_migrated_flag = 'Y' THEN
       --APPLIED_FROM_DOCUMENT - migrated: get information of regimes from ZX_LINES
       get_migrated_doc_info (p_trx_line_index,
                              l_migrated_tax_provider_id,
                              l_migrated_tax_regime_code,
                              l_migrated_tax_regime_id,
                              l_migrated_effective_from,   -- Bug 5557565
                              l_migrated_effective_to,     -- Bug 5557565
                              l_migrated_country_code,
                              l_return_status
                              );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' RETURN_STATUS = ' || x_return_status);
         END IF;
         RETURN;
       END IF;
       IF NOT ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl.EXISTS(l_migrated_tax_regime_id) THEN
          ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_migrated_tax_regime_id).tax_regime_id := l_migrated_tax_regime_id;
          ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_migrated_tax_regime_id).tax_regime_code := l_migrated_tax_regime_code;
          ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_migrated_tax_regime_id).tax_provider_id := l_migrated_tax_provider_id;
          ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_migrated_tax_regime_id).country_code := l_migrated_country_code;
/* Bug 5557565 */
          ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_migrated_tax_regime_id).effective_from := l_migrated_effective_from;
          ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_migrated_tax_regime_id).effective_to := l_migrated_effective_to;
          IF l_migrated_tax_provider_id is not null THEN
            ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_migrated_tax_regime_id).partner_processing_flag := 'C';
          END IF;
          popl_all_regimes_tbl (p_event_class_rec,
                                ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index),
                                ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index),
                                l_migrated_tax_regime_id,
                                l_migrated_tax_regime_code,
                                l_migrated_tax_provider_id,
                                l_return_status
                                );

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_return_status := l_return_status;
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
              ' RETURN_STATUS = ' || x_return_status);
            END IF;
            RETURN;
          END IF;
       END IF;
     ELSIF l_ptnr_migrated_flag ='N' THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' APPLIED_FROM_DOCUMENT :not migrated- retrieve the applicable regimes from zx_trx_line_app_regimes for original transaction');
       END IF;
       FOR app_docs IN app_doc_regime_csr(p_trx_line_index) LOOP
         IF  NOT ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl.EXISTS(app_docs.tax_regime_id) THEN
           ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(app_docs.tax_regime_id).tax_regime_id :=app_docs.tax_regime_id;
           ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(app_docs.tax_regime_id).tax_regime_code := app_docs.tax_regime_code;
           ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(app_docs.tax_regime_id).tax_provider_id := app_docs.tax_provider_id;
           ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(app_docs.tax_regime_id).country_code := app_docs.country_code;

/* Bug 5557565 */
           ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(app_docs.tax_regime_id).effective_from := app_docs.effective_from;
            ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(app_docs.tax_regime_id).effective_to := app_docs.effective_to;
           ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(app_docs.tax_regime_id).partner_processing_flag := 'C';
    	   popl_all_regimes_tbl (p_event_class_rec,
                                 ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index),
                                 ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index),
                                 ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(app_docs.tax_regime_id).tax_regime_id,
                                 ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(app_docs.tax_regime_id).tax_regime_code,
                                 ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(app_docs.tax_regime_id).tax_provider_id,
                                 l_return_status
                                 );
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             x_return_status := l_return_status;
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                ' RETURN_STATUS = ' || x_return_status);
             END IF;
             RETURN;
           END IF;
         END IF; --tax_regime_tbl exists
       END LOOP; --loop on app_docs
     END IF; --l_ptnr_migrated_flag
   --If adjusted document
   ELSIF ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl.COUNT=0
   AND ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(p_trx_line_index) is not NULL THEN
     --ADJUSTED_DOC - check if original document is migrated
     BEGIN
       SELECT nvl(partner_migrated_flag, 'N')     -- Bug 5007293
         INTO l_ptnr_migrated_flag
         FROM ZX_LINES_DET_FACTORS
        WHERE application_id   = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_application_id(p_trx_line_index)
          AND entity_code      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_entity_code(p_trx_line_index)
          AND event_class_code = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_event_class_code(p_trx_line_index)
          AND trx_id           = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_id(p_trx_line_index)
          AND trx_line_id      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_line_id(p_trx_line_index)
          AND trx_level_type   = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_trx_level_type(p_trx_line_index);
     EXCEPTION
     WHEN no_data_found THEN
       l_ptnr_migrated_flag := 'N';
     END;
     IF l_ptnr_migrated_flag = 'Y' THEN
       --ADJUSTED DOC - migrated: get information of regimes from ZX_LINES
       get_migrated_doc_info (p_trx_line_index,
                              l_migrated_tax_provider_id,
                              l_migrated_tax_regime_code,
                              l_migrated_tax_regime_id,
                              l_migrated_effective_from,   -- Bug 5557565
                              l_migrated_effective_to,     -- Bug 5557565
                              l_migrated_country_code,
                              l_return_status
                              );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
           ' RETURN_STATUS = ' || x_return_status);
         END IF;
         RETURN;
       END IF;

      IF l_migrated_tax_regime_id IS NOT NULL THEN --- bug6024643
       IF NOT ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl.EXISTS(l_migrated_tax_regime_id) THEN
          ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_migrated_tax_regime_id).tax_regime_id := l_migrated_tax_regime_id;
          ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_migrated_tax_regime_id).tax_regime_code := l_migrated_tax_regime_code;
          ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_migrated_tax_regime_id).tax_provider_id := l_migrated_tax_provider_id;
          ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_migrated_tax_regime_id).country_code := l_migrated_country_code;
/* Bug 5557565 */
          ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_migrated_tax_regime_id).effective_from := l_migrated_effective_from;
          ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_migrated_tax_regime_id).effective_to := l_migrated_effective_to;
          ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_migrated_tax_regime_id).partner_processing_flag := 'C';
          popl_all_regimes_tbl (p_event_class_rec,
                                ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index),
                                ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index),
                                l_migrated_tax_regime_id,
                                l_migrated_tax_regime_code,
                                l_migrated_tax_provider_id,
                                l_return_status
                                );

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_return_status := l_return_status;
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
              ' RETURN_STATUS = ' || x_return_status);
            END IF;
            RETURN;
          END IF;
       END IF;
     END IF; --- bug6024643
     ELSIF l_ptnr_migrated_flag ='N' THEN
       FOR adj_docs IN adj_doc_regime_csr(p_trx_line_index) LOOP
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' ADJ_DOC:not migrated - $' || adj_docs.tax_regime_code || '$' || adj_docs.effective_from);
         END IF;
         IF NOT ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl.EXISTS(adj_docs.tax_regime_id) THEN
            ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(adj_docs.tax_regime_id).tax_regime_id :=adj_docs.tax_regime_id;
            ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(adj_docs.tax_regime_id).tax_regime_code := adj_docs.tax_regime_code;
            ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(adj_docs.tax_regime_id).tax_provider_id := adj_docs.tax_provider_id;
            ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(adj_docs.tax_regime_id).country_code := adj_docs.country_code;
/* Bug 5557565 */
            ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(adj_docs.tax_regime_id).effective_from := adj_docs.effective_from;
            ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(adj_docs.tax_regime_id).effective_to := adj_docs.effective_to;
            ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(adj_docs.tax_regime_id).partner_processing_flag := 'C';
            popl_all_regimes_tbl (p_event_class_rec,
                                  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index),
                                  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index),
                                  ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(adj_docs.tax_regime_id).tax_regime_id,
                                  ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(adj_docs.tax_regime_id).tax_regime_code,
                                  ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(adj_docs.tax_regime_id).tax_provider_id,
                                  l_return_status
                                  );
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              x_return_status := l_return_status;
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                ' RETURN_STATUS = ' || x_return_status);
              END IF;
              RETURN;
            END IF;
          END IF;--tax regime tbl exists
       END LOOP; --loop on adj_docs
     END IF; --l_ptnr_migrated_flag
   END IF;--adjusted/applied

   -- The following logic will run only if detail_tax_regime_tbl structure.count <> 0
   IF ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl.count <> 0 THEN

      FOR  l_detail_regime_index IN nvl(ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl.FIRST,0)..nvl(ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl.LAST,-1)
      LOOP
         IF (ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl(l_detail_regime_index).trx_line_index=p_trx_line_index) THEN --Bug 4941881
        --In order to avoid unwanted multiple calls to the get_service_provider for same regime cache the hit regimes in a temporary structure
        l_tax_regime_id := ZX_GLOBAL_STRUCTURES_PKG.detail_tax_regime_tbl(l_detail_regime_index).tax_regime_id;

        --Call routine to check if provider is applicable

            get_service_provider (p_event_class_rec.application_id
                               ,p_event_class_rec.entity_code
                               ,p_event_class_rec.event_class_code
                               ,ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_tax_regime_id).tax_regime_code
                               ,l_provider_id
                               ,l_return_status
                               );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               x_return_status := l_return_status;
               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                         ' RETURN_STATUS = ' || x_return_status);
               END IF;
               RETURN;
            END IF;

            IF l_provider_id <> 0 THEN
               ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_tax_regime_id).tax_provider_id := l_provider_id;
               ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_tax_regime_id).partner_processing_flag := 'C';
            END IF;

        --Populate the table for all regimes applicable to transaction line
        --Call routine to populate all applicable regimes for line in ZX_TRX_LINE_APP_REGIMES
            popl_all_regimes_tbl (p_event_class_rec,
                              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index),
                              ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(p_trx_line_index),
                              ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_tax_regime_id).tax_regime_id,
                              ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_tax_regime_id).tax_regime_code,
                              ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_tax_regime_id).tax_provider_id,
                              l_return_status
                              );
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               x_return_status := l_return_status;
               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                         ' RETURN_STATUS = ' || x_return_status);
               END IF;
               RETURN;
            END IF;
         END IF;
      END LOOP; --on detail tax regimes

   ELSE
      FOR  l_trx_regime_index IN nvl(ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl.FIRST,0)..nvl(ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl.LAST,-1)
      LOOP
         IF ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl.EXISTS(l_trx_regime_index) THEN
            get_service_provider (p_event_class_rec.application_id
                                 ,p_event_class_rec.entity_code
                                 ,p_event_class_rec.event_class_code
                                 ,ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_trx_regime_index).tax_regime_code
                                 ,l_provider_id
                                 ,l_return_status
                                 );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              x_return_status := l_return_status;
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                  ' RETURN_STATUS = ' || x_return_status);
              END IF;
              RETURN;
            END IF;

            IF l_provider_id <> 0 THEN
              ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_trx_regime_index).tax_provider_id := l_provider_id;
              ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_trx_regime_index).partner_processing_flag := 'C';
            END IF;
         END IF;
      END LOOP; --on doc tax regimes

   END IF;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
         G_PKG_NAME ||': '||l_api_name||'(-)'||' RETURN_STATUS  = ' || x_return_status);
    END IF;

   EXCEPTION
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;
END popl_pvrdr_info_tax_reg_tbl;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_service_provider
--
--  DESCRIPTION
--  This procedure returns the service provider for a given regime
--  based on the subscription setup from ZX_SRVC_SUBSCRIPTIONS table
--
--  CALLED BY
--     popl_pvrdr_info_tax_reg_tbl
--     Tax forms
-----------------------------------------------------------------------

PROCEDURE get_service_provider (
 p_application_id     IN         NUMBER,
 p_entity_code        IN         VARCHAR2,
 p_event_class_code   IN         VARCHAR2,
 p_tax_regime_code    IN         VARCHAR2,
 x_provider_id        OUT NOCOPY NUMBER,
 x_return_status      OUT NOCOPY VARCHAR2
 ) IS

  l_api_name           CONSTANT VARCHAR2(30) := 'GET_SERVICE_PROVIDER';
  l_provider_name      VARCHAR2(50);
--  l_context_info_rec   ZX_API_PUB.context_info_rec_type;
  l_tbl_index          BINARY_INTEGER;

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
    END IF;

   --Set the return status to Success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' Application Id = ' || to_char(p_application_id) ||
            ' Entity code = ' || p_entity_code ||
            ' Event Class code = ' || p_event_class_code ||
            ' ZX_SECURITY.G_FIRST_PARTY_ORG_ID = ' || ZX_SECURITY.G_FIRST_PARTY_ORG_ID ||
            ' Tax Regime code = ' || p_tax_regime_code ||
            '  ZX_TAX_PARTNER_PKG.G_BUSINESS_FLOW ='  ||  ZX_TAX_PARTNER_PKG.G_BUSINESS_FLOW);
   END IF;

   l_tbl_index := dbms_utility.get_hash_value(to_char(p_application_id)||'$$'||p_entity_code||'$$'||p_event_class_code||'$$'||to_char(ZX_SECURITY.G_FIRST_PARTY_ORG_ID)||'$$'||p_tax_regime_code, 1, 8192);

   IF tax_regime_tmp_tbl.exists(l_tbl_index)
      AND tax_regime_tmp_tbl(l_tbl_index).application_id = p_application_id
      AND tax_regime_tmp_tbl(l_tbl_index).entity_code = p_entity_code
      AND tax_regime_tmp_tbl(l_tbl_index).event_class_code = p_event_class_code
      AND tax_regime_tmp_tbl(l_tbl_index).first_pty_org_id = ZX_SECURITY.G_FIRST_PARTY_ORG_ID
      AND tax_regime_tmp_tbl(l_tbl_index).tax_regime_code = p_tax_regime_code THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' Using tax_regime_tmp_tbl cache');
      END IF;

      x_provider_id := tax_regime_tmp_tbl(l_tbl_index).srvc_provider_id;
   ELSE
   --Check the service provider to call for calculating tax
      BEGIN
      SELECT srvc.srvc_provider_id
        INTO x_provider_id
        FROM ZX_SRVC_SUBSCRIPTIONS srvc,
             ZX_REGIMES_USAGES reg
       WHERE reg.tax_regime_code   = p_tax_regime_code
         AND srvc.regime_usage_id  = reg.regime_usage_id
         AND srvc.enabled_flag = 'Y'
         AND srvc.prod_family_grp_code = ZX_TAX_PARTNER_PKG.G_BUSINESS_FLOW
         AND ZX_SECURITY.G_EFFECTIVE_DATE between
             (srvc.effective_from) AND nvl( srvc.effective_to,ZX_SECURITY.G_EFFECTIVE_DATE)
         AND reg.first_pty_org_id  = ZX_SECURITY.G_FIRST_PARTY_ORG_ID
   	     AND NOT EXISTS (SELECT 1
	                  FROM ZX_SRVC_SBSCRPTN_EXCLS excl
                         WHERE excl.application_id   = p_application_id
                           AND excl.entity_code      = p_entity_code
                           AND excl.event_class_code = p_event_class_code
                           AND excl.srvc_subscription_id = srvc.srvc_subscription_id
                          );
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_provider_id := 0;  --eBTax is the tax provider
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' Tax Provider = eBTax' );
          END IF;
      END;
      tax_regime_tmp_tbl(l_tbl_index).srvc_provider_id := x_provider_id;
      tax_regime_tmp_tbl(l_tbl_index).application_id := p_application_id;
      tax_regime_tmp_tbl(l_tbl_index).entity_code := p_entity_code;
      tax_regime_tmp_tbl(l_tbl_index).event_class_code := p_event_class_code;
      tax_regime_tmp_tbl(l_tbl_index).first_pty_org_id := ZX_SECURITY.G_FIRST_PARTY_ORG_ID;
      tax_regime_tmp_tbl(l_tbl_index).tax_regime_code := p_tax_regime_code;

   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      IF x_provider_id <> 0 THEN
         BEGIN
            SELECT party_name
              INTO l_provider_name
              FROM HZ_PARTIES pty,
                   ZX_PARTY_TAX_PROFILE ptp
             WHERE pty.party_id = ptp.party_id
               AND ptp.party_tax_profile_id = x_provider_id;
         EXCEPTION
            WHEN OTHERS THEN
               l_provider_name := NULL;
         END;
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
           ' Tax Provider = ' || l_provider_name);
       END IF;
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
         G_PKG_NAME ||': '||l_api_name||'(-)'||' RETURN_STATUS = ' || x_return_status);
   END IF;

   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;
   END get_service_provider;


-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  Overloaded get_service_provider
--
--  DESCRIPTION
--  This is an overloaded procedure which returns the service provider
--  for a given regime  based on the subscription setup from
--  ZX_SRVC_SUBSCRIPTIONS table. It is called from the import exemptions
--  which does not have information of the document
--
--  CALLED BY
--     import_exemptions

-----------------------------------------------------------------------
PROCEDURE get_service_provider (
 p_tax_regime_code    IN         VARCHAR2,
 x_provider_id        OUT NOCOPY NUMBER,
 x_return_status      OUT NOCOPY VARCHAR2
 ) IS

  l_api_name           CONSTANT VARCHAR2(30) := 'GET_SERVICE_PROVIDER';
  l_context_info_rec   ZX_API_PUB.context_info_rec_type;
  l_product_family     VARCHAR2(30);
  l_provider_name      VARCHAR2(50);

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
    END IF;

    --Set the return status to Success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Check service provider to call for import exemptions
   SELECT srvc.srvc_provider_id
     INTO x_provider_id
     FROM ZX_SRVC_SUBSCRIPTIONS srvc,
          ZX_REGIMES_USAGES reg
    WHERE reg.tax_regime_code   = p_tax_regime_code
      AND srvc.regime_usage_id  = reg.regime_usage_id
      AND srvc.enabled_flag = 'Y'
      AND (ZX_TAX_PARTNER_PKG.G_BUSINESS_FLOW is null OR
           srvc.prod_family_grp_code = ZX_TAX_PARTNER_PKG.G_BUSINESS_FLOW)
      AND ZX_SECURITY.G_EFFECTIVE_DATE between
          (srvc.effective_from) AND nvl( srvc.effective_to,ZX_SECURITY.G_EFFECTIVE_DATE)
      AND reg.first_pty_org_id  = ZX_SECURITY.G_FIRST_PARTY_ORG_ID;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      SELECT party_name
        INTO l_provider_name
        FROM hz_parties pty,
             zx_party_tax_profile ptp
       WHERE pty.party_id = ptp.party_id
         AND ptp.party_tax_profile_id = x_provider_id;

       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
       ' Tax Provider  = ' || l_provider_name);
    END IF;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
         G_PKG_NAME ||': '||l_api_name||'(-)'||' RETURN_STATUS = ' || x_return_status);
    END IF;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       x_provider_id := 0;  --eBTax is the tax provider
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
         ' Tax Provider = eBTax' );
       END IF;
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;
  END get_service_provider;


-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  derive_ext_attrs
--
--  DESCRIPTION
--  This procedure calls the main wrapper code (generated) for the user
--  registered extensible procedures.
--
--  CALLED BY
--     ZX_SRVC_TYPS_PKG.calculate_tax
--     ZX_SRVC_TYPS_PKG.import
--     ZX_SRVC_TYPS_PKG.override_tax_lines
--     ZX_SRVC_TYPS_PKG.reverse_document
--     ZX_SRVC_TYPS_PKG.discard_tax_only_lines
--     ZX_SRVC_TYPS_PKG.synchronize_tax
--     ZX_SRVC_TYPS_PKG.partner_inclusive_tax_override
-----------------------------------------------------------------------

PROCEDURE derive_ext_attrs (
  p_event_class_rec   IN         ZX_API_PUB.event_class_rec_type,
  p_tax_regime_code   IN         VARCHAR2,
  p_provider_id       IN         NUMBER,
  p_service_type_code IN         VARCHAR2,
  x_return_status     OUT NOCOPY VARCHAR2
 ) IS
  l_api_name           CONSTANT VARCHAR2(30) := 'DERIVE_EXT_ATTRS';
  l_context_info_rec   ZX_API_PUB.context_info_rec_type;
  l_regime_index       NUMBER;
  l_service_type_id    NUMBER;
  l_context_ccid       NUMBER;
  l_data_transfer_mode VARCHAR2(30);
  l_return_status      VARCHAR2(1);
  l_user_extns         BOOLEAN;
  l_dummy              NUMBER;
  l_service_provider   VARCHAR2(360);

  CURSOR  get_service_provider_csr (c_provider_id  NUMBER) IS
   SELECT pty.party_name
     FROM zx_party_tax_profile ptp,
          hz_parties pty
    WHERE ptp.party_tax_profile_id = p_provider_id
      AND ptp.party_id = pty.party_id
      AND rownum = 1;

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
    END IF;

    --Set the return status to Success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Set the global variables
    ZX_TAX_PARTNER_PKG.G_TAX_REGIME_CODE   := p_tax_regime_code;
    ZX_TAX_PARTNER_PKG.G_EVENT_CLASS_REC   := p_event_class_rec;

    IF p_service_type_code = 'DERIVE_LINE_ATTRS' AND ZX_API_PUB.G_PUB_SRVC = 'DISCARD_TAX_ONLY_LINES' THEN
      null;
    ELSE
      BEGIN
        l_user_extns := TRUE;
        SELECT reg.service_type_id,
               reg.context_ccid,
               srvc.data_transfer_code
          INTO l_service_type_id,
               l_context_ccid,
               l_data_transfer_mode
          FROM ZX_API_REGISTRATIONS reg,
               ZX_SERVICE_TYPES     srvc,
               ZX_API_CODE_COMBINATIONS api
         WHERE api.code_combination_id = reg.context_ccid
           AND api.segment_attribute1  = p_tax_regime_code
           AND reg.api_owner_id        = p_event_class_rec.first_pty_org_id
           AND srvc.service_type_id    = reg.service_type_id
           AND srvc.service_type_code  = p_service_type_code;

       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_user_extns := FALSE;
       END;
     END IF;

     IF l_user_extns THEN
       --Populate the global attributes
--       ZX_USER_EXT_PKG.G_EXT_ATTRS_INPUT_REC.business_flow            := p_event_class_rec.prod_family_grp_code;
--       ZX_USER_EXT_PKG.G_EXT_ATTRS_INPUT_REC.country_code             := p_tax_regime_code;
--       ZX_USER_EXT_PKG.G_EXT_ATTRS_INPUT_REC.transaction_service_type := ZX_API_PUB.G_PUB_SRVC;
--       ZX_USER_EXT_PKG.G_EXT_ATTRS_INPUT_REC.derivation_level         := p_service_type_code;
--       ZX_USER_EXT_PKG.G_EXT_ATTRS_INPUT_REC.transaction_id           := p_event_class_rec.trx_id;
--       ZX_USER_EXT_PKG.G_EXT_ATTRS_INPUT_REC.event_id                 := p_event_class_rec.event_id;

       --Call the procedure to derive user extensible parameters
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
           ' Call the registered User extensibe procedure  ' || x_return_status);
       END IF;

       -- Added Begin-Exception-End Block around ZX_USER_EXT_PKG.invoke_third_party_interface for Error Handling
       BEGIN
          ZX_USER_EXT_PKG.invoke_third_party_interface (p_event_class_rec.first_pty_org_id
                                                       ,l_service_type_id
                                                       ,l_context_ccid
                                                       ,l_data_transfer_mode
                                                       ,l_return_status
                                                       );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
              ' RETURN_STATUS = ' || x_return_status);
            END IF;
            RETURN;
          END IF;
       EXCEPTION
          WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
            IF p_provider_id = 1 THEN
              l_service_provider := 'VERTEX';
            ELSIF p_provider_id = 2 THEN
              l_service_provider := 'TAXWARE';
            ELSIF p_provider_id IS NOT NULL THEN
              OPEN  get_service_provider_csr(p_provider_id);
              FETCH get_service_provider_csr INTO l_service_provider;
              CLOSE get_service_provider_csr;
            END IF;

            IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
            END IF;
            FND_MESSAGE.SET_NAME('ZX','ZX_PTNR_SERVICE_REQD');
            FND_MESSAGE.SET_TOKEN('SERVICE_PROVIDER',l_service_provider);
            ZX_API_PUB.add_msg(p_context_info_rec => ZX_TDS_CALC_SERVICES_PUB_PKG.g_msg_context_info_rec);
            RETURN;
       END;
    END IF;--no user extensible procedures defined

    --Insert dummy records so that partner views do not fail in case the extensible
    --tables are not populated by user/extensible procedures are not registered.
    --Based on service type code we need to insert data in header,line GT tables.
    IF(p_service_type_code = 'DERIVE_HDR_ATTRS') THEN
     BEGIN
      SELECT 1
        INTO l_dummy
        FROM ZX_PRVDR_HDR_EXTNS_GT
       WHERE application_id   = p_event_class_rec.application_id
         AND entity_code      = p_event_class_rec.entity_code
         AND event_class_code = p_event_class_rec.event_class_code
         AND trx_id           = p_event_class_rec.trx_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO ZX_PRVDR_HDR_EXTNS_GT(event_class_code,
                                            application_id,
                                            entity_code,
                                            trx_id,
                                            provider_id,
                                            tax_regime_code,
                                            creation_date,
                                            created_by,
                                            last_update_date,
                                            last_updated_by
                                            )
                                    values (p_event_class_rec.EVENT_CLASS_CODE,
                                            p_event_class_rec.APPLICATION_ID,
                                            p_event_class_rec.ENTITY_CODE,
                                            p_event_class_rec.TRX_ID,
                                            p_provider_id,
                                            p_tax_regime_code,
                                            sysdate,
                                            fnd_global.user_id,
                                            sysdate,
                                            fnd_global.user_id
                                            );
    END;
   ELSIF(p_service_type_code = 'DERIVE_LINE_ATTRS') THEN
    BEGIN
     INSERT INTO ZX_PRVDR_LINE_EXTNS_GT (event_class_code,
                                       application_id,
                                       entity_code,
                                       trx_id,
                                       trx_line_id,
                                       trx_level_type,
                                       provider_id,
                                       tax_regime_code,
                                       creation_date,
                                       created_by,
                                       last_update_date,
                                       last_updated_by
                                       )
                                SELECT lines.event_class_code,
                                       lines.application_id,
                                       lines.entity_code,
                                       lines.trx_id,
                                       lines.trx_line_id,
                                       lines.trx_level_type,
                                       p_provider_id,
                                       p_tax_regime_code,
                                       sysdate,
                                       fnd_global.user_id,
                                       sysdate,
                                       fnd_global.user_id
                                  FROM ZX_LINES_DET_FACTORS lines
                                 WHERE application_id   = p_event_class_rec.application_id
                                   AND entity_code      = p_event_class_rec.entity_code
                                   AND event_class_code = p_event_class_rec.event_class_code
                                   AND trx_id           = p_event_class_rec.trx_id
                                   AND NOT EXISTS (SELECT 1
                                                    FROM  ZX_PRVDR_LINE_EXTNS_GT ext
                                                   WHERE  ext.application_id   = lines.application_id
                                                     AND  ext.entity_code      = lines.entity_code
                                                     AND  ext.event_class_code = lines.event_class_code
                                                     AND  ext.trx_id           = lines.trx_id
                                                     AND  ext.trx_line_id      = lines.trx_line_id
                                                     AND  ext.trx_level_type   = lines.trx_level_type);

    END;
   END IF; --End of p_service_type_code

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
         G_PKG_NAME ||': '||l_api_name||'(-)'||' RETURN_STATUS = ' || x_return_status);
    END IF;

   EXCEPTION
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;
  END derive_ext_attrs;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  partner_pre_processing
--
--  DESCRIPTION
--  This procedure is used to prepare the information to be passed to the tax
--  partner services. It sets attributes in ZX_TRX_PRE_PROC_OPTIONS_GT so that
--  partner interface views pick the correct data for the transaction and
--  partner under consideration
--
--  CALLED BY
--     ZX_SRVC_TYPS_PKG.calculate_tax
--     ZX_SRVC_TYPS_PKG.import
--     ZX_SRVC_TYPS_PKG.reverse_document
--     ZX_SRVC_TYPS_PKG.synchronize_tax
--     ZX_SRVC_TYPS_PKG.partner_inclusive_tax_override
-----------------------------------------------------------------------

PROCEDURE partner_pre_processing(
  p_tax_regime_id         IN  NUMBER,
  p_tax_regime_code       IN  VARCHAR2,
  p_tax_provider_id       IN  NUMBER,
  p_ptnr_processing_flag  IN  VARCHAR2,
  p_event_class_rec       IN  ZX_API_PUB.event_class_rec_type,
  x_return_status         OUT NOCOPY VARCHAR2
  ) IS

  l_api_name           CONSTANT VARCHAR2(30) := 'PARTNER_PRE_PROCESSING';
  l_provider_found     NUMBER;
  l_return_status      VARCHAR2(1);
  l_line_level_action  VARCHAR2(30);
  l_context_info_rec   ZX_API_PUB.context_info_rec_type;
-- Bug# 4769082
  l_legal_entity_number    ZX_TRX_PRE_PROC_OPTIONS_GT.legal_entity_number%type;
  l_establishment_number   ZX_TRX_PRE_PROC_OPTIONS_GT.establishment_number%type;  -- Bug 5139731
  l_application_short_name FND_APPLICATION.application_short_name%type;
-- Bug# 4769082
  l_cnt_of_options_gt      NUMBER;
  l_hq_estb_ptp_id         ZX_LINES_DET_FACTORS.hq_estb_party_tax_prof_id%type;    --  Bug 5090593
  l_party_id               ZX_PARTY_TAX_PROFILE.party_id%type;                    --  Bug 5090593
  l_tax_provider_id        NUMBER;            --  Bug 5090593

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
    END IF;

    --Set the return status to Success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_tax_provider_id is NULL THEN

       get_service_provider (p_event_class_rec.application_id
                               ,p_event_class_rec.entity_code
                               ,p_event_class_rec.event_class_code
                               ,p_tax_regime_code
                               ,l_tax_provider_id
                               ,l_return_status
                               );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               x_return_status := l_return_status;
               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                         ' RETURN_STATUS = ' || x_return_status);
               END IF;
               RETURN;
           END IF;

       IF l_tax_provider_id > 0 THEN

         ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(p_tax_regime_id).tax_provider_id := l_tax_provider_id;

      END IF;

    ELSE

      l_tax_provider_id := p_tax_provider_id;

    END IF;

    DELETE from ZX_TRX_PRE_PROC_OPTIONS_GT;

    --Set the context for the partner interface views
    IF ZX_API_PUB.G_PUB_SRVC = 'SYNCHRONIZE_TAX_REPOSITORY' THEN
       BEGIN
          INSERT into ZX_TRX_PRE_PROC_OPTIONS_GT (INTERNAL_ORGANIZATION_ID,
	                                     APPLICATION_ID,
	                                     ENTITY_CODE,
	                                     EVENT_CLASS_CODE,
	                                     EVNT_CLS_MAPPING_ID,
	                                     TAX_EVENT_TYPE_CODE,
	                                     PROD_FAMILY_GRP_CODE,
	                                     TRX_ID,
	                                     TAX_REGIME_CODE,
	                                     PARTNER_PROCESSING_FLAG,
	                                     TAX_PROVIDER_ID,
	                                     EVENT_ID,
	                                     CREATION_DATE,
	                                     CREATED_BY,
	                                     LAST_UPDATE_DATE,
	                                     LAST_UPDATED_BY,
	                                     LAST_UPDATE_LOGIN
	                                    )
   	                            SELECT   p_event_class_rec.internal_organization_id,
   	                                     p_event_class_rec.application_id,
   	                                     p_event_class_rec.entity_code,
   	                                     p_event_class_rec.event_class_code,
   	                                     clsmap.event_class_mapping_id,
   	                                     p_event_class_rec.tax_event_type_code,
   	                                     clsmap.prod_family_grp_code,
   	                                     p_event_class_rec.trx_id,
   	                                     p_tax_regime_code,
   	                                     p_ptnr_processing_flag,
   	                                     p_tax_provider_id,
   	                                     p_event_class_rec.event_id,
                                             sysdate,
                                             fnd_global.user_id,
                                             sysdate,
                                             fnd_global.user_id,
                                             fnd_global.conc_login_id
                                        FROM ZX_EVNT_CLS_MAPPINGS clsmap
                                       WHERE clsmap.application_id  = p_event_class_rec.application_id
	                                 AND clsmap.entity_code = p_event_class_rec.entity_code
	                                 AND clsmap.event_class_code = p_event_class_rec.event_class_code;
       EXCEPTION WHEN OTHERS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                ' SYNCHRONIZE_TAX_REPOSITORY: Exception while inserting into ZX_TRX_PRE_PROC_OPTIONS_GT');
          END IF;
       END;
    ELSE
      SELECT line_level_action,
             hq_estb_party_tax_prof_id
        INTO l_line_level_action,
             l_hq_estb_ptp_id
        FROM zx_lines_det_factors
       WHERE application_id   = p_event_class_rec.application_id
         AND entity_code      = p_event_class_rec.entity_code
         AND event_class_code = p_event_class_rec.event_class_code
         AND trx_id           = p_event_class_rec.trx_id
         AND rownum           = 1;

-- Bug# 4769082
      BEGIN
         SELECT app.application_short_name
         INTO   l_application_short_name
         FROM   FND_APPLICATION app
         WHERE app.application_id  = p_event_class_rec.application_id;
      END;

/* Bug 5090593: Products may or may not pass establishment_id.
 In the case where product does not pass the establishment_id, the PTP of hq establishment is internally derived.
 So, we need to use this PTP to get the establishment info.
      IF p_event_class_rec.establishment_id IS NOT NULL THEN
         BEGIN
            SELECT  pty.party_number,
                    xletb.name
             INTO   l_legal_entity_number,
                    l_establishment_name
             FROM   XLE_ETB_PROFILES xletb,
                    XLE_ENTITY_PROFILES xlent,
                    HZ_PARTIES pty
             WHERE  xletb.establishment_id = p_event_class_rec.establishment_id
               AND  xlent.legal_entity_id = xletb.legal_entity_id
               AND  pty.party_id = xlent.party_id
               AND  xletb.main_establishment_flag = 'Y';
         EXCEPTION WHEN OTHERS THEN
            l_legal_entity_number := NULL;
            l_establishment_name := NULL;
         END;
      ELSE
         l_legal_entity_number := NULL;
         l_establishment_name := NULL;
      END IF;
*/
/* Bug 5139731: Derivation of Establishment number and Legal entity number */
      IF l_hq_estb_ptp_id IS NOT NULL THEN
         BEGIN
            SELECT  pty.party_number
                  , pty.party_id
             INTO   l_establishment_number
                  , l_party_id
             FROM   HZ_PARTIES pty,
                    ZX_PARTY_TAX_PROFILE ptp
             WHERE  ptp.party_tax_profile_id = l_hq_estb_ptp_id
               AND  pty.party_id             = ptp.party_id;
         EXCEPTION WHEN OTHERS THEN
            l_establishment_number := NULL;
         END;
         BEGIN
            SELECT  pty.party_number
             INTO   l_legal_entity_number
             FROM   XLE_ETB_PROFILES xletb,
                    HZ_PARTIES pty,
                    XLE_ENTITY_PROFILES xep
             WHERE  xletb.party_id        = l_party_id
               AND  xletb.legal_entity_id = xep.legal_entity_id
               AND  pty.party_id          = xep.party_id;
         EXCEPTION WHEN OTHERS THEN
            l_legal_entity_number := NULL;
         END;
      ELSE
         l_legal_entity_number  := NULL;
         l_establishment_number := NULL;
      END IF;
-- Bug# 4769082

      BEGIN
          INSERT into ZX_TRX_PRE_PROC_OPTIONS_GT (INTERNAL_ORGANIZATION_ID,
	                                       APPLICATION_ID,
	                                       ENTITY_CODE,
	                                       EVENT_CLASS_CODE,
	                                       EVNT_CLS_MAPPING_ID,
	                                       TAX_EVENT_TYPE_CODE,
	                                       PROD_FAMILY_GRP_CODE,
	                                       TRX_ID,
	                                       TAX_REGIME_CODE,
	                                       PARTNER_PROCESSING_FLAG,
	                                       TAX_PROVIDER_ID,
	                                       EVENT_ID,
	                                       QUOTE_FLAG,
	                                       RECORD_FLAG,
	                                       RECORD_FOR_PARTNERS_FLAG,
	                                       APPLICATION_SHORT_NAME,
	                                       LEGAL_ENTITY_NUMBER,
	                                       ESTABLISHMENT_NUMBER,      -- Bug 5139731
	                                       ALLOW_TAX_CALCULATION_FLAG,
   	                                       CREATION_DATE,
	                                       CREATED_BY,
	                                       LAST_UPDATE_DATE,
	                                       LAST_UPDATED_BY,
	                                       LAST_UPDATE_LOGIN
	                                       )
    	                              VALUES  (p_event_class_rec.internal_organization_id,
   	                                       p_event_class_rec.application_id,
   	                                       p_event_class_rec.entity_code,
   	                                       p_event_class_rec.event_class_code,
   	                                       p_event_class_rec.event_class_mapping_id,
   	                                       p_event_class_rec.tax_event_type_code,
   	                                       p_event_class_rec.prod_family_grp_code,
   	                                       p_event_class_rec.trx_id,
   	                                       p_tax_regime_code,
   	                                       p_ptnr_processing_flag,
   	                                       p_tax_provider_id,
   	                                       p_event_class_rec.event_id,
   	                                       nvl(p_event_class_rec.quote_flag,'N'),
                                               p_event_class_rec.record_flag,
   	                                       p_event_class_rec.record_for_partners_flag,
                                               l_application_short_name,
                                               l_legal_entity_number,
                                               l_establishment_number,    -- Bug 5139731
                                               decode(l_line_level_action,
                                                      'ALLOCATE_TAX_ONLY_ADJUSTMENT', 'N',
                                                      'ALLOCATE_LINE_ONLY_ADJUSTMENT', 'N',     -- Bug 5007293
                                                      'LINE_INFO_TAX_ONLY', 'N',     -- Bug
                                                      p_event_class_rec.process_for_applicability_flag),
                                               sysdate,
                                               fnd_global.user_id,
                                               sysdate,
                                               fnd_global.user_id,
                                               fnd_global.conc_login_id);
          EXCEPTION WHEN OTHERS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                ' Exception while inserting into ZX_TRX_PRE_PROC_OPTIONS_GT');
             END IF;
          END;

    END IF; -- API is synchronize_tax

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       BEGIN
	  SELECT count(*)
	    INTO l_cnt_of_options_gt
	    FROM ZX_TRX_PRE_PROC_OPTIONS_GT;
       EXCEPTION WHEN OTHERS THEN
          l_cnt_of_options_gt := 0;
       END;
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
         'The record is inserted in ZX_TRX_PRE_PROC_OPTIONS_GT = ' || l_cnt_of_options_gt);
    END IF;
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
         G_PKG_NAME ||': '||l_api_name||'(-)'||' RETURN_STATUS = ' || x_return_status);
    END IF;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(p_tax_regime_id).partner_processing_flag := 'F';
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;
  END partner_pre_processing;


-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  call_partner_service
--
--  DESCRIPTION
--  This procedure is used to prepare the call to the appropriate tax
--  partner service
--
--  CALLED BY
--     ZX_SRVC_TYPS_PKG.calculate_tax
--     ZX_SRVC_TYPS_PKG.import
--     ZX_SRVC_TYPS_PKG.override_tax_lines
--     ZX_SRVC_TYPS_PKG.document_level_changes
--     ZX_SRVC_TYPS_PKG.reverse_document
--     ZX_SRVC_TYPS_PKG.synchronize_tax
--     ZX_SRVC_TYPS_PKG.discard_tax_only_lines
--     ZX_SRVC_TYPS_PKG.partner_inclusive_tax_override
-----------------------------------------------------------------------


PROCEDURE call_partner_service(
  p_tax_regime_code       IN  VARCHAR2,
  p_tax_provider_id       IN  NUMBER,
  p_service_type_code     IN  VARCHAR2,
  p_event_class_rec       IN ZX_API_PUB.event_class_rec_type,
  x_return_status         OUT NOCOPY VARCHAR2
  ) IS

  l_api_name           CONSTANT VARCHAR2(30) := 'CALL_PARTNER_SERVICE';
  l_context_info_rec   ZX_API_PUB.context_info_rec_type;
  l_service_type_id    NUMBER;
  l_context_ccid       NUMBER;
  l_return_status      VARCHAR2(1);
  l_counter            NUMBER;
  l_to_amt             NUMBER;
  l_error_buffer       VARCHAR2(1000);

CURSOR currency_csr IS
   SELECT DISTINCT tax,            -- Bug#5395227
          tax_currency_code,
          exchange_rate_type
     FROM ZX_SCO_TAXES_B_V         -- Bug#5395227
    WHERE tax_regime_code = p_tax_regime_code;

--Currencies can be passed at either the header level/line level
CURSOR document_currency_csr IS
  SELECT nvl(trx_line_currency_code,trx_currency_code) trx_currency_code
    FROM ZX_LINES_DET_FACTORS
   WHERE application_id   = p_event_class_rec.application_id
     AND entity_code      = p_event_class_rec.entity_code
     AND event_class_code = p_event_class_rec.event_class_code
     AND trx_id           = p_event_class_rec.trx_id;

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

    --Set the return status to Success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   BEGIN
       SELECT reg.service_type_id,
              reg.context_ccid
         INTO l_service_type_id,
              l_context_ccid
         FROM ZX_API_REGISTRATIONS reg,
              ZX_SERVICE_TYPES     srvc,
              ZX_API_CODE_COMBINATIONS api
        WHERE api.code_combination_id = reg.context_ccid
          AND api.segment_attribute1  = p_tax_regime_code
          AND (api.segment_attribute2 is null
           OR api.segment_attribute2  = p_event_class_rec.prod_family_grp_code )
          AND reg.api_owner_id        = p_tax_provider_id
          AND srvc.service_type_id    = reg.service_type_id
          AND srvc.service_type_code  = p_service_type_code;
   EXCEPTION WHEN OTHERS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;  --tax returned by partner is not amongst candidate taxes
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                         ' The Partner Service '|| p_service_type_code || ' is not registered for ' ||
                          p_event_class_rec.prod_family_grp_code || ',' || p_tax_regime_code ||
                          ', and provider ' || p_tax_provider_id);
          RETURN;            -- Bug 5200373
       END IF;
   END;

     IF p_service_type_code = 'CALCULATE_TAX' THEN
       --Populate the tax currencies structure
       l_counter:=0;
       FOR currencies IN currency_csr LOOP
         FOR doc_curr IN document_currency_csr LOOP
           ZX_PTNR_SRVC_INTGRTN_PKG.G_TAX_CURRENCIES_TBL(l_counter).tax := currencies.tax;
           ZX_PTNR_SRVC_INTGRTN_PKG.G_TAX_CURRENCIES_TBL(l_counter).tax_currency_code := currencies.tax_currency_code;
           ZX_PTNR_SRVC_INTGRTN_PKG.G_TAX_CURRENCIES_TBL(l_counter).trx_line_currency_code := doc_curr.trx_currency_code;

           ZX_TDS_TAX_ROUNDING_PKG.convert_to_currency (p_from_currency         => doc_curr.trx_currency_code,
                                                        p_to_currency           => currencies.tax_currency_code,
                                                        p_conversion_date       => ZX_SECURITY.G_EFFECTIVE_DATE,
                                                        p_tax_conversion_type   => currencies.exchange_rate_type,
                                                        p_trx_conversion_type   => p_event_class_rec.currency_conversion_type,
                                                        p_to_curr_conv_rate     => ZX_PTNR_SRVC_INTGRTN_PKG.G_TAX_CURRENCIES_TBL(l_counter).exchange_rate,
                                                        p_from_amt              => 1,
                                                        p_to_amt                => l_to_amt,
                                                        p_return_status         => l_return_status,
                                                        p_error_buffer          => l_error_buffer,
                                                        p_trx_conversion_date   => ZX_SECURITY.G_EFFECTIVE_DATE); --Bug7183884

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             x_return_status := l_return_status;
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                ' RETURN_STATUS = ' || x_return_status);
             END IF;
             RETURN;
           END IF;
           l_counter := l_counter+1;
         END LOOP; --doc_curr
       END LOOP;--currencies
     ELSIF p_service_type_code = 'DOCUMENT_LEVEL_CHANGES' THEN
       --Populate trx_rec
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
          ' p_event_class_rec.event_class_mapping_id  ' || p_event_class_rec.event_class_mapping_id ||
          ' ZX_API_PUB.G_PUB_SRVC ' ||  ZX_API_PUB.G_PUB_SRVC ||
          ' p_event_class_rec.event_type_code  ' || p_event_class_rec.event_type_code ||
          ' p_event_class_rec.tax_event_type_code  ' || p_event_class_rec.tax_event_type_code);
       END IF;

       ZX_PTNR_SRVC_INTGRTN_PKG.G_TRX_REC.document_type_id      := p_event_class_rec.event_class_mapping_id;
       ZX_PTNR_SRVC_INTGRTN_PKG.G_TRX_REC.transaction_id        := p_event_class_rec.trx_id;
       IF ZX_API_PUB.G_PUB_SRVC = 'CALCULATE_TAX' THEN --called for partner processing flag = 'N'
         ZX_PTNR_SRVC_INTGRTN_PKG.G_TRX_REC.document_level_action := 'DELETE';
       ELSE
         ZX_PTNR_SRVC_INTGRTN_PKG.G_TRX_REC.document_level_action := p_event_class_rec.event_type_code;
       END IF;
     END IF;

     -- Call the partner service
     ZX_PTNR_SRVC_INTGRTN_PKG.invoke_third_party_interface (p_tax_provider_id,
                                                            l_service_type_id,
                                                            l_context_ccid ,
                                                            'PLS',
                                                            l_return_status
                                                           );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;

      FOR er_index IN NVL(ZX_PTNR_SRVC_INTGRTN_PKG.G_MESSAGES_TBL.ERROR_MESSAGE_STRING.FIRST,1) .. NVL(ZX_PTNR_SRVC_INTGRTN_PKG.G_MESSAGES_TBL.ERROR_MESSAGE_STRING.LAST,0)
      LOOP
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                  'Error Type: '||ZX_PTNR_SRVC_INTGRTN_PKG.G_MESSAGES_TBL.ERROR_MESSAGE_TYPE(er_index));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                  'Error Message: '||ZX_PTNR_SRVC_INTGRTN_PKG.G_MESSAGES_TBL.ERROR_MESSAGE_STRING(er_index));
        END IF;
        FND_MESSAGE.SET_NAME('ZX', 'GENERIC_MESSAGE');
	FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', ZX_PTNR_SRVC_INTGRTN_PKG.G_MESSAGES_TBL.ERROR_MESSAGE_STRING(er_index));
        l_context_info_rec.APPLICATION_ID   := p_event_class_rec.application_id;
        l_context_info_rec.ENTITY_CODE      := p_event_class_rec.entity_code;
        l_context_info_rec.EVENT_CLASS_CODE := p_event_class_rec.event_class_code;
        l_context_info_rec.TRX_ID           := p_event_class_rec.trx_id;
        ZX_API_PUB.add_msg( p_context_info_rec =>l_context_info_rec );
        --ZX_API_PUB.dump_msg;
      END LOOP;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' RETURN_STATUS = ' || x_return_status);
      END IF;
      RETURN;
    END IF;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
         G_PKG_NAME ||': '||l_api_name||'(-)'||' RETURN_STATUS = ' || x_return_status);
    END IF;

   EXCEPTION
     WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FOR er_index IN NVL(ZX_PTNR_SRVC_INTGRTN_PKG.G_MESSAGES_TBL.ERROR_MESSAGE_STRING.FIRST,1) .. NVL(ZX_PTNR_SRVC_INTGRTN_PKG.G_MESSAGES_TBL.ERROR_MESSAGE_STRING.LAST,0)
      LOOP
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                  'Error Type: '||ZX_PTNR_SRVC_INTGRTN_PKG.G_MESSAGES_TBL.ERROR_MESSAGE_TYPE(er_index));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                  'Error Message: '||ZX_PTNR_SRVC_INTGRTN_PKG.G_MESSAGES_TBL.ERROR_MESSAGE_STRING(er_index));
        END IF;
        FND_MESSAGE.SET_NAME('ZX', 'GENERIC_MESSAGE');
	FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', ZX_PTNR_SRVC_INTGRTN_PKG.G_MESSAGES_TBL.ERROR_MESSAGE_STRING(er_index));
        l_context_info_rec.APPLICATION_ID   := p_event_class_rec.application_id;
        l_context_info_rec.ENTITY_CODE      := p_event_class_rec.entity_code;
        l_context_info_rec.EVENT_CLASS_CODE := p_event_class_rec.event_class_code;
        l_context_info_rec.TRX_ID           := p_event_class_rec.trx_id;
        ZX_API_PUB.add_msg( p_context_info_rec =>l_context_info_rec );
        ZX_API_PUB.dump_msg;
      END LOOP;
      RETURN;
END call_partner_service;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  ptnr_post_processing_calc_tax
--
--  DESCRIPTION
--  This procedure is used to massage the tax results returned by the partner's
--  calculate tax service. The processing of tax results involve validation
--  of the data returned, mapping, further processing, and/or recording.
--
--  CALLED BY
--     ZX_SRVC_TYPS_PKG.calculate_tax
--     ZX_SRVC_TYPS_PKG.import
--     ZX_SRVC_TYPS_PKG.partner_inclusive_tax_override
-----------------------------------------------------------------------

PROCEDURE ptnr_post_processing_calc_tax(
  p_tax_regime_code       IN VARCHAR2,
  p_tax_provider_id       IN NUMBER,
  p_event_class_rec       IN ZX_API_PUB.event_class_rec_type,
  x_return_status         OUT NOCOPY VARCHAR2
  ) IS
  l_api_name                 CONSTANT VARCHAR2(30) := 'PTNR_POST_PROCESSING_CALC_TAX';
  l_context_info_rec         ZX_API_PUB.context_info_rec_type;
  l_app_regimes              NUMBER;
  l_tax_found                NUMBER;
  l_tax_index                VARCHAR2(100);
  l_prepay_tax_rate          NUMBER;
  l_prepay_tax_amt           NUMBER;
  l_prepay_line_amt          NUMBER;
  l_line_level_action        VARCHAR2(30);
  l_tax                      VARCHAR2(30);
  l_prorated_amt             NUMBER;
  l_sync_with_prvdr_flag     VARCHAR2(1);
  l_delete_flag              VARCHAR2(1);
  l_self_assessment_flag     VARCHAR2(1);
  l_return_status            VARCHAR2(1);
  l_tax_precision            NUMBER;
  l_threshold_indicator_flag VARCHAR2(1);
  l_partner_migrated_flag    VARCHAR2(1);
  l_ret_record_level         VARCHAR2(30);
  l_registration_rec         ZX_TCM_CONTROL_PKG.zx_registration_info_rec;
  l_allow_tax_calculation_flag  ZX_TRX_PRE_PROC_OPTIONS_GT.allow_tax_calculation_flag%type;

  --Table to derive the apportionment number in case the transaction line has same taxes
  TYPE tax_tbl_type is table of VARCHAR2(30) index by VARCHAR2(240);
  tax_tbl              tax_tbl_type;
/* Bug 5162537 */
  l_tax_rec                  ZX_TDS_UTILITIES_PKG.zx_tax_info_cache_rec;
  l_error_buffer             VARCHAR2(1000);

  l_tax_class          ZX_RATES_B.tax_class%TYPE;

  --
  -- Bug#5417753
  --
  CURSOR get_def_tax_rate_csr
    (c_tax_status_code         ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
     c_tax                     ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
     c_tax_regime_code         ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
     c_tax_class               ZX_RATES_B.TAX_CLASS%TYPE,
     c_tax_determine_date      ZX_LINES.TAX_DETERMINE_DATE%TYPE)
  IS
  SELECT rate.tax_rate_code,
         rate.rate_type_code,
         rate.tax_rate_id
    FROM  ZX_SCO_RATES_B_V rate
    WHERE rate.tax_regime_code   = c_tax_regime_code
     -- AND rate.default_rate_flag = 'Y'
      AND rate.active_flag       = 'Y'
      AND rate.tax               = c_tax
      AND rate.tax_status_code   = c_tax_status_code
      AND rate.tax_jurisdiction_code is null
      AND (rate.tax_class = c_tax_class or rate.tax_class IS NULL)
    --  AND rate.default_flg_effective_from <= c_tax_determine_date
    --  AND (rate.default_flg_effective_to >= c_tax_determine_date OR
      --     rate.default_flg_effective_to IS NULL)
      AND rate.effective_from <= c_tax_determine_date
      AND (rate.effective_to >= c_tax_determine_date OR
           rate.effective_to IS NULL)
  ORDER BY rate.tax_class NULLS LAST, rate.subscription_level_code;


  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
    END IF;

    --Set the return status to Success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Bug#5417753- determine tax_class value
    IF p_event_class_rec.prod_family_grp_code = 'O2C' THEN
      l_tax_class := 'OUTPUT';
    ELSIF p_event_class_rec.prod_family_grp_code = 'P2P' THEN
      l_tax_class := 'INPUT';
    END IF;

/* Bug 5131206: For tax only documents, partner tax calculation service is called
                for synchronization of the document information. Partner is
                expected NOT to calculate the tax.
                Hence, ptnr_post_processing_calc_tax should be skipped in this case.
                The tax lines are created by eBTax and are later synchronized with
                the partner.
*/
             BEGIN
                SELECT allow_tax_calculation_flag
                  INTO l_allow_tax_calculation_flag
                  FROM ZX_TRX_PRE_PROC_OPTIONS_GT
                 WHERE APPLICATION_ID   = p_event_class_rec.APPLICATION_ID
                   AND ENTITY_CODE      = p_event_class_rec.ENTITY_CODE
                   AND EVENT_CLASS_CODE = p_event_class_rec.EVENT_CLASS_CODE
                   AND TRX_ID           = p_event_class_rec.TRX_ID;
             END;

    IF l_allow_tax_calculation_flag = 'N' THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.END',
            G_PKG_NAME ||': '||l_api_name||'(-)'||' ptnr_post_processing_calc_tax is skipped for tax only documents');
       END IF;
       RETURN;
    END IF;

    --Call routine to bulk insert all Applicable regimes for line in db table ZX_TRX_LINE_APP_REGIMES
    --Insert into zx_trx_line_app_regimes(Point 5 in DLD)
    trx_line_app_regimes_tbl_hdl(p_event_class_rec  => p_event_class_rec,
                                 p_event            => 'INSERT',
                                 p_provider_id      => null,
                                 p_tax_regime_code  => null,
                                 p_trx_line_id      => null,
                                 p_trx_level_type   => null,
                                 x_return_status    => l_return_status
                                );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' RETURN_STATUS = ' || x_return_status);
      END IF;
      RETURN;
    END IF;

    --Point 3A in DLD
    IF ZX_API_PUB.G_PUB_SRVC = 'IMPORT_DOCUMENT_WITH_TAX' THEN
      IF p_event_class_rec.record_for_partners_flag = 'Y' THEN
        IF p_event_class_rec.process_for_applicability_flag = 'N' THEN
           l_sync_with_prvdr_flag := 'Y';
           l_delete_flag := 'Y';
        ELSIF p_event_class_rec.perf_addnl_appl_for_imprt_flag ='Y' THEN
           l_self_assessment_flag := 'Y';
           l_delete_flag := 'Y';
        END IF;
      END IF;
    END IF;

    FOR ptnr_tax_line_index IN  nvl(ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.document_type_id.FIRST, 1) .. nvl(ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.document_type_id.LAST,0)
    LOOP
        --Check to see if partner returned tax is a valid tax from the list of candidate taxes for the regime (Point 3b in DLD)
       /* Bug#5395227- use cache structure
        BEGIN
            SELECT tax_precision,
                   minimum_accountable_unit,
                   rounding_rule_code,
                   tax_id,
                   tax_type_code,
                   exchange_rate_type
              INTO l_tax_precision,
                   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.minimum_accountable_unit(ptnr_tax_line_index),
                   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.rounding_rule_code(ptnr_tax_line_index),
                   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_id(ptnr_tax_line_index),
                   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_type_code(ptnr_tax_line_index),
                   ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_currency_conversion_type(ptnr_tax_line_index)
              -- FROM ZX_SCO_TAXES -- Bug#5395227
              FROM ZX_SCO_TAXES_B_V
             WHERE tax_regime_code = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.country_code(ptnr_tax_line_index)
	       AND tax = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(ptnr_tax_line_index)
               AND rownum = 1
            ORDER BY subscription_level_code;      -- Bug#5395227

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;   --tax returned by partner is not amongst candidate taxes
               IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'Tax returned by the tax partner is invalid');
               END IF;
	       RETURN;
          END;

          */

          -- Bug#5395227- replace above code

          l_tax_rec       := NULL;
          l_return_status := FND_API.G_RET_STS_SUCCESS;

          ZX_TDS_UTILITIES_PKG.get_tax_cache_info(
                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.country_code(ptnr_tax_line_index),
                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(ptnr_tax_line_index),
                            ZX_SECURITY.G_EFFECTIVE_DATE,
                            l_tax_rec,
                            l_return_status,
                            l_error_buffer);

          IF l_return_status = FND_API.G_RET_STS_SUCCESS  THEN
            l_tax_precision := l_tax_rec.tax_precision;
            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.minimum_accountable_unit(ptnr_tax_line_index) := l_tax_rec.minimum_accountable_unit;
            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.rounding_rule_code(ptnr_tax_line_index) := l_tax_rec.rounding_rule_code;
            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_id(ptnr_tax_line_index) := l_tax_rec.tax_id;
            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_type_code(ptnr_tax_line_index) := l_tax_rec.tax_type_code;
            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_currency_conversion_type(ptnr_tax_line_index) := l_tax_rec.exchange_rate_type;

          ELSE
             IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                      'Incorrect return_status after calling ZX_TDS_UTILITIES_PKG.get_tax_cache_info for tax '
                   || ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(ptnr_tax_line_index)
                   || 'RETURN_STATUS = ' || l_return_status);
             END IF;
             RETURN;
          END IF;

          --PRECISION CHECK
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               ' Checking the preceision returned on tax line' || to_char(l_tax_precision));
          END IF;

          FOR i IN  ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_currencies_tbl.FIRST..  nvl(ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_currencies_tbl.LAST,0)
          LOOP
            IF ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_currencies_tbl(i).tax = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(ptnr_tax_line_index) THEN
	       IF ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_currencies_tbl(i).tax_currency_precision > l_tax_precision THEN     -- Bug 5288518
	          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;  --tax returned by partner is not amongst candidate taxes
                  IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,
                    ' Precision returned by the tax partner is invalid ');
                  END IF;
                  RETURN;            -- Bug 4769082
               END IF;
               ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_currency_code(ptnr_tax_line_index) := ZX_PTNR_SRVC_INTGRTN_PKG.G_TAX_CURRENCIES_TBL(i).tax_currency_code;
               ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_precision(ptnr_tax_line_index) := ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_currencies_tbl(i).tax_currency_precision;   -- Bug 5288518
               ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_currency_conversion_rate(ptnr_tax_line_index) := ZX_PTNR_SRVC_INTGRTN_PKG.G_TAX_CURRENCIES_TBL(i).exchange_rate;
               EXIT;            -- Bug 4769082
            END IF;
          END LOOP;


          --Check if multiple regimes applicable for transaction line and if inclusive flag set for tax line (Point 3d)
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               ' Inclusive Tax Line Flag: ' || ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.inclusive_tax_line_flag(ptnr_tax_line_index));
          END IF;
          IF ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.inclusive_tax_line_flag(ptnr_tax_line_index) = 'Y' THEN
             BEGIN
                SELECT  count(*)
                  INTO l_app_regimes
                  FROM ZX_TRX_LINE_APP_REGIMES
                 WHERE application_id = p_event_class_rec.application_id
                   AND entity_code = p_event_class_rec.entity_code
                   AND event_class_code = p_event_class_rec.event_class_code
                   AND trx_id = p_event_class_rec.trx_id
                   AND trx_line_id = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.transaction_line_id(ptnr_tax_line_index)
                   AND trx_level_type = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.trx_level_type(ptnr_tax_line_index);
             END;

             IF l_app_regimes > 1 THEN
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;  --tax returned by partner cannot be inclusive
               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                  ' Returned tax line for multiple regimes by the tax partner is invalid ' || x_return_status);
               END IF;
               RETURN;
             END IF;
          END IF;

          set_detail_tax_line_values(p_event_class_rec,
                                     ptnr_tax_line_index,
                                     p_tax_provider_id,
                                     l_return_status);

          --Max Tax condition handling (point 3C in DLD)
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               ' Threshold Indicator Flag: ' || ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.threshold_indicator_flag(ptnr_tax_line_index));
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               ' Exempt Certificate Number: ' || ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.exempt_certificate_number(ptnr_tax_line_index));
          END IF;

          -- Added the following code to check whether Global Attributes are initialized.
          -- Added the below 11 lines as part of vertex O series certification.
          BEGIN
            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.global_attribute_category(ptnr_tax_line_index)
             := ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.global_attribute_category(ptnr_tax_line_index);
          EXCEPTION
            WHEN OTHERS THEN
              ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.global_attribute2(ptnr_tax_line_index) := NULL;
              ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.global_attribute4(ptnr_tax_line_index) := NULL;
	      ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.global_attribute6(ptnr_tax_line_index) := NULL;
	      ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.global_attribute_category(ptnr_tax_line_index) := NULL;
          END;

          IF ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.threshold_indicator_flag(ptnr_tax_line_index) = 'Y'
            AND l_threshold_indicator_flag is null THEN
            l_threshold_indicator_flag := 'Y';
          END IF;

          --Resetting the partner migrated flag to indicate that, for subsequent updates on the same
          --document, we need not pass entire document information to the partner
          IF p_event_class_rec.tax_event_type_code = 'UPDATE'
            AND l_partner_migrated_flag is null
            AND record_type_code_tbl(ptnr_tax_line_index) = 'MIGRATED'
            AND partner_migrated_flag_tbl(ptnr_tax_line_index) = 'Y' THEN
                l_partner_migrated_flag := 'N';
          END IF;

          -- Bug 5162537:
          -- The tax lines created for partners did not have correct tax line numbering.
          -- The TDS procedure ZX_TDS_TAX_LINES_DETM_PKG: populate_tax_line_numbers
          -- expects the cache ZX_TDS_UTILITIES_PKG.zx_tax_info_cache_rec to be populated
          -- for the tax.
          -- Since, the taxes are determined by the partner, it is necessary that partner
          -- integration infrastructure populates this cache.
          --
         /* bug#5395227 don't need to call again here
          ZX_TDS_UTILITIES_PKG.get_tax_cache_info(
                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.country_code(ptnr_tax_line_index),
	                    ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(ptnr_tax_line_index),
                            ZX_SECURITY.G_EFFECTIVE_DATE,
                            l_tax_rec,
                            l_return_status,
                            l_error_buffer);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
             IF (g_level_statement >= g_current_runtime_level ) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                      'Incorrect return_status after calling ZX_TDS_UTILITIES_PKG.get_tax_cache_info for tax '
                   || ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(ptnr_tax_line_index)
                   || 'RETURN_STATUS = ' || l_return_status);
             END IF;
             RETURN;
          END IF;
          */

          --Populate other attributes of output structure(Points 3h and 3m)
          ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.sync_with_prvdr_flag(ptnr_tax_line_index):= l_sync_with_prvdr_flag;
          ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.delete_flag(ptnr_tax_line_index)         := l_delete_flag ;
          IF l_self_assessment_flag is not NULL THEN
             ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.use_tax_flag(ptnr_tax_line_index)     := l_self_assessment_flag ;
          END IF;

          /*Derivation of tax apportionment number (Point 3l in DLD) */

          --Store the taxes for line in a temp structure indexed by line id and tax to make comparisions easier
          l_tax_index := ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(ptnr_tax_line_index) ||
                         to_char(ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.transaction_line_id(ptnr_tax_line_index));
          IF (tax_tbl.EXISTS(l_tax_index)) THEN
             ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_apportionment_line_number(ptnr_tax_line_index) :=
             ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_apportionment_line_number(ptnr_tax_line_index)+1;
          ELSE
             tax_tbl(l_tax_index) := ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(ptnr_tax_line_index);
             ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_apportionment_line_number(ptnr_tax_line_index):=1;
    	  END IF;

          --Points 3j-3k in DLD
          -- Determine default tax status
          BEGIN
             SELECT status.tax_status_code,
                    status.tax_status_id
              INTO  ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_status_code(ptnr_tax_line_index),
                    ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_status_id(ptnr_tax_line_index)
              -- FROM  ZX_SCO_STATUS status -- Bug#5395227
              FROM  ZX_SCO_STATUS_B_V status
              WHERE status.tax_regime_code = p_tax_regime_code
                AND status.default_status_flag = 'Y'
                AND status.tax = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(ptnr_tax_line_index)
                AND (ZX_SECURITY.G_EFFECTIVE_DATE between status.default_flg_effective_from AND nvl(status.default_flg_effective_to,ZX_SECURITY.G_EFFECTIVE_DATE))
                AND rownum = 1
              ORDER BY subscription_level_code;     -- Bug#5395227
          EXCEPTION WHEN OTHERS THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               ' In exception of zx_sco_status');
            END IF;
            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_status_code(ptnr_tax_line_index) := NULL;
          END;

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               ' Determine default tax rate for status ' || ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_status_code(ptnr_tax_line_index));
          END IF;

         /* Bug#5417753- replace by the cursor below
          BEGIN
             SELECT rate.tax_rate_code,
                    rate.rate_type_code,
                    rate.tax_rate_id
              INTO  ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_rate_code(ptnr_tax_line_index),
                    ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.rate_type_code(ptnr_tax_line_index),
                    ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_rate_id(ptnr_tax_line_index)
              -- FROM  ZX_SCO_RATES rate -- Bug#5395227
              FROM  ZX_SCO_RATES_B_V rate
              WHERE rate.tax_regime_code   = p_tax_regime_code
                AND rate.default_rate_flag = 'Y'
                AND rate.active_flag       = 'Y'
                AND rate.tax               = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(ptnr_tax_line_index)
                AND rate.tax_status_code   = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_status_code(ptnr_tax_line_index)
                AND rate.tax_jurisdiction_code is null
                AND (rate.tax_class = l_tax_class or rate.tax_class IS NULL)
                AND (ZX_SECURITY.G_EFFECTIVE_DATE between rate.default_flg_effective_from AND nvl(rate.default_flg_effective_to,ZX_SECURITY.G_EFFECTIVE_DATE))
                AND rownum = 1
              ORDER BY rate.tax_class NULLS LAST, rate.subscription_level_code; -- Bug#5395227
          EXCEPTION WHEN OTHERS THEN
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                 ' In exception of zx_sco_rates');
              END IF;
              ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_rate_code(ptnr_tax_line_index)  := NULL;
              ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.rate_type_code(ptnr_tax_line_index) := NULL;
              ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_rate_id(ptnr_tax_line_index) := NULL;
          END;
         */

         -- Bug#5417753
         OPEN get_def_tax_rate_csr(
                ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_status_code(ptnr_tax_line_index),
                ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(ptnr_tax_line_index),
                p_tax_regime_code,
                l_tax_class,
                ZX_SECURITY.G_EFFECTIVE_DATE);

         FETCH get_def_tax_rate_csr INTO
           ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_rate_code(ptnr_tax_line_index),
           ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.rate_type_code(ptnr_tax_line_index),
           ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_rate_id(ptnr_tax_line_index);
	 IF get_def_tax_rate_csr%notfound THEN
            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_rate_code(ptnr_tax_line_index) := NULL;
            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.rate_type_code(ptnr_tax_line_index) := NULL;
            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_rate_id(ptnr_tax_line_index) := NULL;
         END IF;
         CLOSE get_def_tax_rate_csr;

          /*Pre-Payment Processing handling*/
          --Point 3e-3f in DLD
          BEGIN
            -- Need to check if pre-payment processing applicable for the line and this need to be done only once for every transaction line.
            -- although tax lines for that transaction lines may be many
           IF ZX_TAX_PARTNER_PKG.G_BUSINESS_FLOW = 'P2P' THEN
             IF ptnr_tax_line_index > 1 AND
                  ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.transaction_line_id(ptnr_tax_line_index-1) =
                  ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.transaction_line_id(ptnr_tax_line_index) THEN
                SELECT tax.tax_rate,
                       tax.tax_amt,
                       tax.line_amt
                 INTO  l_prepay_tax_rate,
                       l_prepay_tax_amt,
                       l_prepay_line_amt
                 FROM  ZX_LINES tax
                 WHERE tax.application_id = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.applied_from_application_id(ptnr_tax_line_index)
                   AND tax.entity_code = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.applied_from_entity_code(ptnr_tax_line_index)
                   AND tax.event_class_code = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.applied_from_event_class_code(ptnr_tax_line_index)
                   AND tax.trx_id = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.applied_from_trx_id(ptnr_tax_line_index)
                   AND tax.trx_line_id = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.applied_from_line_id(ptnr_tax_line_index)
                   AND tax.trx_level_type = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.applied_from_trx_level_type(ptnr_tax_line_index)
                   AND tax.tax_regime_code = p_tax_regime_code
                   AND tax.tax = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(ptnr_tax_line_index)
     	           AND tax.tax_apportionment_line_number = 1;

                  -- If difference in partner returned tax rate and tax rate on the pre-payment document,
             	  -- call TDM process to prorate the tax amount
                  IF l_prepay_tax_rate <> ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_rate_percentage(ptnr_tax_line_index) THEN
                    --Call TRD routine to prorate the tax amount
  	            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_amount(ptnr_tax_line_index) :=
                       ZX_TRD_SERVICES_PUB_PKG.get_prod_total_tax_amt(l_prepay_tax_amt,
                                                                      ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.line_amt(ptnr_tax_line_index),
                                                                      l_prepay_line_amt
                                                                     );
                  END IF;
               END IF; --ptnr_tax_line_index >1
             END IF; -- P2P flow
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
               null;
           END;

	  -- Mark the sync with provider flag(Point 3n in DLD)
          -- Retrieve line level action

          IF p_event_class_rec.record_for_partners_flag ='Y' AND
             p_event_class_rec.record_flag = 'Y' AND
             p_event_class_rec.quote_flag = 'N' THEN

             l_line_level_action := line_level_action_tbl(ptnr_tax_line_index);

             IF l_line_level_action  ='CREATE_TAX_ONLY' THEN
                ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.sync_with_prvdr_flag(ptnr_tax_line_index) := 'Y';
             END IF;

         END IF;

          -- Get the own_hq_tax_reg_number (Point 3i in DLD) - TBD
          /*
           --Call TCM routine to get first party tax registration number
          ZX_TCM_CONTROL_PKG.get_tax_registration (p_parent_ptp_id         => ZX_GLOBAL_STRUCTURES_PKG.hq_estb_ptp_id(1),
                                                   p_site_ptp_id           => null,
                                                   p_account_type_code     => null,
                                                   p_tax_determine_date    => ZX_SECURITY.G_EFFECTIVE_DATE,
                                                   p_tax                   => ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(ptnr_tax_line_index),
                                                   p_tax_regime_code       => p_tax_regime_code,
                                                   p_jurisdiction_code     => null,
                                                   p_account_id            => null,
                                                   p_account_site_id       => null,
                                                   p_site_use_id           => null,
                                                   p_zx_registration_rec   => l_registration_rec,
                                                   p_ret_record_level      => l_ret_record_level,
                                                   p_return_status         => l_return_status
                                                  );

          ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.party_tax_reg_number(ptnr_tax_line_index) := l_registration_rec.registration_number;

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            null; --ok if not first party tax registration registration number is not found
          END IF;
          */
    END LOOP; --looping over the tax lines

    --Populate zx_detail_tax_lines_gt with the taxes retured from partner*/

    BEGIN
      FORALL i IN  ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.application_id.FIRST.. nvl(ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.application_id.LAST,0)
        INSERT INTO ZX_DETAIL_TAX_LINES_GT (tax_line_id,
                                            internal_organization_id,
                                            application_id,
                                            entity_code,
                                            event_class_code,
                                            event_type_code,
                                            content_owner_id,
                                            trx_id,
                                            trx_line_id,
                                            trx_level_type,
                                            tax_regime_code,
                                            tax_line_number,
                                            tax,
                                            tax_status_code,
                                            tax_rate_code,
                                            tax_rate_type,
                                            tax_apportionment_line_number,
                                            place_of_supply_type_code,
                                            tax_jurisdiction_code,
                                            tax_currency_code,
                                            precision,
                                            minimum_accountable_unit,
                                            rounding_rule_code,
                                            tax_amt,
                                            unrounded_tax_amt,
                                            unrounded_taxable_amt,
                                            tax_amt_tax_curr,
                                            tax_rate,
                                            taxable_amt,
                                            --exempt_amt,
                                            exempt_certificate_number,
                                            exempt_rate_modifier,
                                            exempt_reason,
                                            exempt_reason_code,
                                            tax_exemption_id,
                                            applied_from_application_id,   -- Bug 5468010
                                            applied_from_entity_code,      -- Bug 5468010
                                            applied_from_event_class_code, -- Bug 5468010
                                            applied_from_trx_id,           -- Bug 5468010
                                            applied_from_line_id,          -- Bug 5468010
                                            applied_from_trx_level_type,   -- Bug 5468010
                                            applied_from_trx_number,       -- Bug 5468010
                                            adjusted_doc_application_id,   -- Bug 5468010
                                            adjusted_doc_entity_code,      -- Bug 5468010
                                            adjusted_doc_event_class_code, -- Bug 5468010
                                            adjusted_doc_trx_id,           -- Bug 5468010
                                            adjusted_doc_line_id,          -- Bug 5468010
                                            adjusted_doc_trx_level_type,   -- Bug 5468010
                                            adjusted_doc_number,           -- Bug 5468010
                                            adjusted_doc_date,             -- Bug 5468010
					    adjusted_doc_tax_line_id,      -- Bug 6130978
                                            sync_with_prvdr_flag,
                                            tax_only_line_flag,
                                            tax_amt_included_flag,
                                            self_assessed_flag,
                                            overridden_flag,
                                            last_manual_entry,
                                            tax_provider_id,
                                            manually_entered_flag,
                                            tax_registration_number,  -- Bug 5288518
                                            registration_party_type,  -- Bug 5288518
                                            cancel_flag,
                                            delete_flag,
                                            trx_line_number,
                                            trx_number,
                                            doc_event_status,
                                            tax_event_class_code,
                                            tax_event_type_code,
                                            tax_regime_id,
                                            tax_id,
                                            tax_status_id,
                                            tax_rate_id,
                                            mrc_tax_line_flag, -- Bug 5162537
                                            ledger_id,
                                            legal_entity_id,
                                            tax_currency_conversion_date,
                                            tax_currency_conversion_type,
                                            tax_currency_conversion_rate,
                                            trx_currency_code,
                                            trx_date,
                                            unit_price,
                                            line_amt,
                                            trx_line_quantity,
                                            offset_flag,
                                            process_for_recovery_flag,
					    reporting_only_flag,  -- Bug 8298174
                                            tax_jurisdiction_id,
                                            tax_date,
                                            tax_determine_date,
                                            trx_line_date,
                                            tax_type_code,
                                            compounding_tax_flag,
                                            taxable_amt_tax_curr,
                                            tax_apportionment_flag,
                                            historical_flag,
                                            purge_flag,
                                            freeze_until_overridden_flag,
                                            copied_from_other_doc_flag,
					    global_attribute2,
                                            global_attribute4,
					    global_attribute6,
					    global_attribute_category,
                                            record_type_code,
                                            object_version_number,
                                            creation_date,
                                            created_by,
                                            last_update_date,
                                            last_updated_by,
                                            last_update_login

				            )
                                    VALUES (--ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_line_id(i),
                                            ZX_LINES_S.nextval,
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.internal_organization_id(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.application_id(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.entity_code(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.event_class_code(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.event_type_code(i),
                                            p_event_class_rec.first_pty_org_id,
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.transaction_id(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.transaction_line_id(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.trx_level_type(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.country_code(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_line_number(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_status_code(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_rate_code(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.rate_type_code(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_apportionment_line_number(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.situs(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_jurisdiction(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_currency_code(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_precision(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.minimum_accountable_unit(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.rounding_rule_code(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_amount(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.unrounded_tax_amount(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.taxable_amount(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_curr_tax_amount(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_rate_percentage(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.taxable_amount(i),
                                            --ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.exempt_amt(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.exempt_certificate_number(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.exempt_rate_modifier(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.exempt_reason(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.exempt_reason_code(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_exemption_id(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.applied_from_application_id(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.applied_from_entity_code(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.applied_from_event_class_code(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.applied_from_trx_id(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.applied_from_line_id(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.applied_from_trx_level_type(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.applied_from_trx_number(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_application_id(i),   -- Bug 5468010
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_entity_code(i),   -- Bug 5468010
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_event_class_code(i),   -- Bug 5468010
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_trx_id(i),   -- Bug 5468010
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_line_id(i),   -- Bug 5468010
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_trx_level_type(i),   -- Bug 5468010
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_number(i),   -- Bug 5468010
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_date(i),   -- Bug 5468010
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.adjusted_doc_tax_line_id(i),  -- Bug 6130978
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.sync_with_prvdr_flag(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_only_line_flag(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.inclusive_tax_line_flag(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.use_tax_flag(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.user_override_flag(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.last_manual_entry(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_provider_id(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.manually_entered_flag(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.registration_party_type(i),  -- Bug 5288518
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.party_tax_reg_number(i),     -- Bug 5288518
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.cancel_flag(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.delete_flag(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.trx_line_number(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.trx_number(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.doc_event_status(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_event_class_code(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_event_type_code(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_regime_id(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_id(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_status_id(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_rate_id(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.mrc_tax_line_flag(i),   -- Bug 5162537
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.ledger_id(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.legal_entity_id(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_currency_conversion_date(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_currency_conversion_type(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_currency_conversion_rate(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.trx_currency_code(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.trx_date(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.unit_price(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.line_amt(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.trx_line_quantity(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.offset_flag(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.process_for_recovery_flag(i),
					    ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.reporting_only_flag(i),      -- Bug 8298174
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_jurisdiction_id(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_date(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_determine_date(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.trx_line_date(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_type_code(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.compounding_tax_flag(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.taxable_amt_tax_curr(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.tax_apportionment_flag(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.historical_flag(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.purge_flag(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.freeze_until_overridden_flag(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.copied_from_other_doc_flag(i),
					    ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.global_attribute2(i),
                                            ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.global_attribute4(i),
					    ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.global_attribute6(i),
					    ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.global_attribute_category(i),
                                            'ETAX_CREATED',
                                            1,
                                            sysdate,
                                            fnd_global.user_id,
                                            sysdate,
                                            fnd_global.user_id,
                                            fnd_global.conc_login_id
                                           );
    EXCEPTION WHEN OTHERS THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            ' Exception while Populate zx_detail_tax_lines_gt: ' || sqlerrm);
      END IF;
    END;

    -- Update THRESHOLD_INDICATOR_FLAG, partner migrated_flag  on ZX_LINES_DET_FACTORS for the whole document.
    IF l_threshold_indicator_flag = 'Y' OR l_partner_migrated_flag = 'N' THEN
      UPDATE zx_lines_det_factors
        SET threshold_indicator_flag = nvl(l_threshold_indicator_flag, threshold_indicator_flag),
            partner_migrated_flag    = nvl(l_partner_migrated_flag, partner_migrated_flag),
            line_amt_includes_tax_flag = ZX_PTNR_SRVC_INTGRTN_PKG.g_tax_lines_result_tbl.line_amt_includes_tax_flag(1)
      WHERE application_id = p_event_class_rec.application_id
        AND entity_code = p_event_class_rec.entity_code
        AND event_class_code = p_event_class_rec.event_class_code
        AND trx_id = p_event_class_rec.trx_id;
    END IF;

    --Reset any flags that may have been set during tax calculation for ease of coding in identifying the updated lines
    trx_line_app_regimes_tbl_hdl(p_event_class_rec  => p_event_class_rec,
                                 p_event            => 'RESET_FLAG',
                                 p_provider_id      => null,
                                 p_tax_regime_code  => null,
                                 p_trx_line_id      => null,
                                 p_trx_level_type   => null,
                                 x_return_status    => l_return_status
                                );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
         ' RETURN_STATUS = ' || x_return_status);
      END IF;
      RETURN;
    END IF;

    --Flush this table for subsequent calls
    tax_tbl.DELETE;
    record_type_code_tbl.DELETE;
    line_level_action_tbl.DELETE;
    partner_migrated_flag_tbl.DELETE;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME ||': '||l_api_name||'(-)'||' RETURN_STATUS = ' || x_return_status);
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
        END IF;
  END ptnr_post_processing_calc_tax;


-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  ptnr_post_proc_sync_tax
--
--  DESCRIPTION
--  This procedure is used to process the tax results returned by the
--  partner's tax synchronization service. The processing of
--  tax results involves validation of the data returned, and/or recording.
--
--  CALLED BY
--     ZX_SRVC_TYPS_PKG.calculate_tax
--     ZX_SRVC_TYPS_PKG.import
--     ZX_SRVC_TYPS_PKG.partner_inclusive_tax_override
-----------------------------------------------------------------------

PROCEDURE ptnr_post_proc_sync_tax(
  p_tax_regime_code       IN  VARCHAR2,
  p_tax_provider_id       IN  NUMBER,
  p_event_class_rec       IN ZX_API_PUB.event_class_rec_type,
  x_return_status         OUT NOCOPY VARCHAR2
  ) IS

  l_api_name                CONSTANT VARCHAR2(30) := 'PTNR_POST_PROC_SYNC_TAX';
  l_context_info_rec        ZX_API_PUB.context_info_rec_type;
  l_last_manual_entry       zx_lines.last_manual_entry%type;
  l_tax_line_id             zx_lines.tax_line_id%type;         -- Bug 4908196
  l_return_status           VARCHAR2(1);

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
    END IF;

    --Set the return status to Success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

/* Bug 4908196: Following assumption is true for tax partner integration.
                If partner needs to return more than one tax line of the same tax, the tax line with different situs will be sent. */

    FOR i IN  nvl(ZX_PTNR_SRVC_INTGRTN_PKG.g_sync_tax_lines_tbl.FIRST,0) .. nvl(ZX_PTNR_SRVC_INTGRTN_PKG.g_sync_tax_lines_tbl.LAST,-1)
    LOOP
      IF ZX_API_PUB.G_PUB_SRVC = 'OVERRIDE_TAX' THEN
        SELECT tax.last_manual_entry
             , tax.tax_line_id
          INTO l_last_manual_entry
             , l_tax_line_id
	 FROM  ZX_LINES tax
         WHERE tax.application_id                = p_event_class_rec.application_id
           AND tax.entity_code                   = p_event_class_rec.entity_code
           AND tax.event_class_code              = p_event_class_rec.event_class_code
           AND tax.trx_id                        = p_event_class_rec.trx_id
           AND tax.trx_line_id                   = ZX_PTNR_SRVC_INTGRTN_PKG.g_sync_tax_lines_tbl(i).transaction_line_id
           AND tax.trx_level_type                = ZX_PTNR_SRVC_INTGRTN_PKG.g_sync_tax_lines_tbl(i).trx_level_type
           AND tax.tax_regime_code               = p_tax_regime_code
   	   AND tax.tax                           = ZX_PTNR_SRVC_INTGRTN_PKG.g_sync_tax_lines_tbl(i).tax
   	   AND tax.place_of_supply_type_code     = ZX_PTNR_SRVC_INTGRTN_PKG.g_sync_tax_lines_tbl(i).situs;

            IF l_last_manual_entry = 'TAX_AMOUNT' THEN
              IF ZX_PTNR_SRVC_INTGRTN_PKG.g_sync_tax_lines_tbl(i).tax_rate_percentage is not null OR
                 ZX_PTNR_SRVC_INTGRTN_PKG.g_sync_tax_lines_tbl(i).taxable_amount is not null THEN
                 UPDATE ZX_LINES
                   SET tax_rate = ZX_PTNR_SRVC_INTGRTN_PKG.g_sync_tax_lines_tbl(i).tax_rate_percentage,
                       taxable_amt = ZX_PTNR_SRVC_INTGRTN_PKG.g_sync_tax_lines_tbl(i).taxable_amount
                 WHERE tax_line_id   = l_tax_line_id;
              END IF;
            ELSIF l_last_manual_entry = 'TAX_RATE' THEN
              IF ZX_PTNR_SRVC_INTGRTN_PKG.g_sync_tax_lines_tbl(i).tax_rate_percentage is not null THEN
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;  --tax rate cannot be modified
                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'The tax partner cannot modify an overridden tax rate');
                 END IF;
               ELSIF ZX_PTNR_SRVC_INTGRTN_PKG.g_sync_tax_lines_tbl(i).taxable_amount is not null THEN
                 UPDATE ZX_LINES
                   SET taxable_amt = ZX_PTNR_SRVC_INTGRTN_PKG.g_sync_tax_lines_tbl(i).taxable_amount
                 WHERE tax_line_id   = l_tax_line_id;
               END IF;
             END IF; --last_manual_entry
      ELSE
        UPDATE ZX_LINES
          SET tax_rate = ZX_PTNR_SRVC_INTGRTN_PKG.g_sync_tax_lines_tbl(i).tax_rate_percentage,
              taxable_amt = ZX_PTNR_SRVC_INTGRTN_PKG.g_sync_tax_lines_tbl(i).taxable_amount
         WHERE application_id                    = p_event_class_rec.application_id
           AND entity_code                       = p_event_class_rec.entity_code
           AND event_class_code                  = p_event_class_rec.event_class_code
           AND trx_id                            = p_event_class_rec.trx_id
           AND trx_line_id                       = ZX_PTNR_SRVC_INTGRTN_PKG.g_sync_tax_lines_tbl(i).transaction_line_id
           AND trx_level_type                    = ZX_PTNR_SRVC_INTGRTN_PKG.g_sync_tax_lines_tbl(i).trx_level_type
           AND tax_regime_code                   = p_tax_regime_code
           AND tax                               = ZX_PTNR_SRVC_INTGRTN_PKG.g_sync_tax_lines_tbl(i).tax
   	   AND place_of_supply_type_code         = ZX_PTNR_SRVC_INTGRTN_PKG.g_sync_tax_lines_tbl(i).situs;
   	  END IF;	  -- G_PUB_SRVC = OVERRIDE_TAX
    END LOOP;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
         G_PKG_NAME ||': '||l_api_name||'(-)'||' RETURN_STATUS = ' || x_return_status);
    END IF;

   EXCEPTION
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;
  END ptnr_post_proc_sync_tax;

FUNCTION get_incl_tax_amt (
  p_application_id   IN  NUMBER,
  p_entity_code      IN  VARCHAR2,
  p_event_class_code IN  VARCHAR2,
  p_trx_id           IN  NUMBER,
  p_trx_line_id      IN  NUMBER,
  p_trx_level_type   IN  VARCHAR2,
  p_tax_provider_id  IN  NUMBER
 )RETURN NUMBER
 IS
 l_api_name       CONSTANT VARCHAR2(30) := 'GET_INCL_TAX_AMT';
 l_tax_amount      NUMBER;
 BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
    END IF;

    SELECT /*+ INDEX (TAX ZX_LINES_U1) */
     sum(nvl(tax.tax_amt,0))
     INTO l_tax_amount
     FROM ZX_LINES tax
    WHERE tax.application_id = p_application_id
      AND tax.entity_code = p_entity_code
      AND tax.event_class_code = p_event_class_code
      AND tax.trx_id = p_trx_id
      AND tax.trx_line_id = p_trx_line_id
      AND tax.trx_level_type = p_trx_level_type
      AND tax_amt_included_flag = 'Y'
      AND tax_provider_id <> p_tax_provider_id;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME ||': '||l_api_name||'(-)');
   END IF;

   RETURN l_tax_amount;

   EXCEPTION
     WHEN OTHERS THEN
        IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME ||': '||l_api_name||'(-)');
        END IF;
        RETURN 0;
 END get_incl_tax_amt;


END ZX_TPI_SERVICES_PKG;

/
