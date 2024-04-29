--------------------------------------------------------
--  DDL for Package Body ZX_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_API_PUB" AS
/* $Header: zxifpubsrvcspubb.pls 120.291.12010000.22 2010/11/24 14:53:28 ssanka ship $ */

/* ======================================================================*
 | Global Data Types                                                     |
 * ======================================================================*/

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'ZX_API_PUB';
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
G_MODULE_NAME           CONSTANT VARCHAR2(30) := 'ZX.PLSQL.ZX_API_PUB.';

TYPE evnt_cls_rec_type is RECORD
( event_class_code            VARCHAR2_30_tbl_type,
  application_id              NUMBER_tbl_type,
  entity_code                 VARCHAR2_30_tbl_type,
  internal_organization_id    NUMBER_tbl_type,
  precedence                  NUMBER_tbl_type
);

l_evnt_cls evnt_cls_rec_type;

 /*Lock the rows for entire document*/
 CURSOR lock_line_det_factors_for_doc(trx_rec IN event_class_rec_type) IS
      SELECT *
        FROM ZX_LINES_DET_FACTORS
       WHERE application_id = trx_rec.application_id
         AND entity_code    = trx_rec.entity_code
         AND event_class_code = trx_rec.event_class_code
    	 AND trx_id = trx_rec.trx_id
      FOR UPDATE NOWAIT;


/***********************
PRIVATE PROCEDURES
************************/
/* =======================================================================*
 | Overloaded FUNCTION  determine_effective_date :  LEASE MANAGEMENT      |
 | Created since wasnt sure if the existing determine_effective_Date was  |
 | being used by products. Although cookbook doesnt mention it, didnt want|
 | take a chance since its too will create chaos should there be invalids |
 | now after xbuiild1                                                     |
 * =======================================================================*/

 FUNCTION determine_effective_date
 ( p_transaction_date      IN  DATE,
   p_related_doc_date      IN  DATE,
   p_adjusted_doc_date     IN  DATE,
   p_provnl_tax_det_date   IN  DATE
 ) RETURN DATE IS

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||'DETERMINE_EFFECTIVE_DATE.BEGIN','ZX_API_PUB: DETERMINE_EFFECTIVE_DATE()+');
   END IF;

   IF p_related_doc_date IS NOT NULL THEN
     return(p_related_doc_date);
   ELSIF p_provnl_tax_det_date IS NOT NULL THEN
      return(p_provnl_tax_det_date);
   ELSIF p_adjusted_doc_date IS NOT NULL THEN
      return(p_adjusted_doc_date);
   ELSIF p_transaction_date IS NOT NULL THEN
      return(p_transaction_date);
   ELSE
      return(SYSDATE);
   END IF;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||'DETERMINE_EFFECTIVE_DATE.END','ZX_API_PUB: DETERMINE_EFFECTIVE_DATE()-');
    END IF;

 END determine_effective_date;

-- Added following procedure as a fix for Bug 5159017

/* =============================================================*
 | PROCEDURE    Update total_inc_tax_amt if present            |
 * ============================================================*/

 PROCEDURE update_total_inc_tax_amt (
 p_event_class_rec    IN  event_class_rec_type ,
 x_return_status      OUT NOCOPY VARCHAR2
 )IS
   l_trx_line_tbl          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl%TYPE;
   l_count                 BINARY_INTEGER := 0;
   l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_TOTAL_INC_TAX_AMT';
  BEGIN
     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: update_total_inc_tax_amt(+)');
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_event_class_rec.prod_family_grp_code = 'P2P' THEN

       FOR i IN nvl(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id.FIRST,0) .. nvl(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id.LAST,-99)

       LOOP

          IF (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_amt_included_flag(i) = 'Y')
           AND (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.total_inc_tax_amt(i) IS NOT NULL) THEN
             l_count := l_count + 1;
             l_trx_line_tbl.trx_line_id(l_count) := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(i);
             l_trx_line_tbl.trx_level_type(l_count) := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(i);
             l_trx_line_tbl.total_inc_tax_amt(l_count) := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.total_inc_tax_amt(i);
          END IF;

       END LOOP;

       IF l_count > 0 THEN

         FORALL j IN 1 .. l_count

             UPDATE zx_lines_det_factors
             SET total_inc_tax_amt = l_trx_line_tbl.total_inc_tax_amt(j)
             WHERE application_id = p_event_class_rec.application_id
             AND   entity_code = p_event_class_rec.entity_code
             AND   event_class_code = p_event_class_rec.event_class_code
             AND   trx_id = p_event_class_rec.trx_id
             AND   trx_line_id = l_trx_line_tbl.trx_line_id(j)
             AND   trx_level_type = l_trx_line_tbl.trx_level_type(j);

        END IF;

    END IF;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',
        'ZX_API_PUB: update_total_inc_tax_amt(-)'||' RETURN_STATUS = ' || x_return_status);
    END IF;

EXCEPTION
        WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;

 END update_total_inc_tax_amt;

/* =============================================================*
 | PROCEDURE  	set_ptnr_srvc_subscr_flag                       |
 | Sets zx_global_structures_pkg.g_ptnr_srvc_subscr_flag. This  |
 | will improve the performance of non-partner implementations  |
 * ============================================================*/

 PROCEDURE set_ptnr_srvc_subscr_flag (
 p_event_class_rec    IN  event_class_rec_type ,
 x_return_status      OUT NOCOPY VARCHAR2
 )IS
   l_api_name              CONSTANT VARCHAR2(30) := 'SET_PTNR_SRVC_SUBSCR_FLAG';
  BEGIN
     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     BEGIN
        SELECT 'Y'
          INTO zx_global_structures_pkg.g_ptnr_srvc_subscr_flag
          FROM zx_srvc_subscriptions zss
         WHERE zss.enabled_flag = 'Y'
           AND zss.prod_family_grp_code = nvl(p_event_class_rec.prod_family_grp_code, zss.prod_family_grp_code)
           AND exists (select zru.regime_usage_id
                         from zx_regimes_usages zru
                        where zru.regime_usage_id = zss.regime_usage_id
                          and zru.first_pty_org_id = nvl(p_event_class_rec.first_pty_org_id, zru.first_pty_org_id))
           AND rownum       = 1;
     EXCEPTION WHEN OTHERS THEN
        zx_global_structures_pkg.g_ptnr_srvc_subscr_flag := 'N';
     END;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                  'Setting zx_global_structures_pkg.g_ptnr_srvc_subscr_flag to : '|| zx_global_structures_pkg.g_ptnr_srvc_subscr_flag);
     END IF;

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME || ': ' || l_api_name||'(-)');
     END IF;

 END set_ptnr_srvc_subscr_flag;


/* =============================================================*
 | PROCEDURE  	Perform Partner repository synchronization      |
 * ============================================================*/

 PROCEDURE ptnr_sync_calc_tax (
 p_event_class_rec    IN  event_class_rec_type ,
 x_return_status      OUT NOCOPY VARCHAR2
 )IS
   l_sync_needed           BOOLEAN;
   l_return_status         VARCHAR2(1);
   l_event_class_rec       event_class_rec_type;
   l_sync_with_prvdr_flag  ZX_LINES.sync_with_prvdr_flag%type; -- Bug 5131206
   l_api_name              CONSTANT VARCHAR2(30) := 'PTNR_SYNC_CALC_TAX';
  BEGIN
     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*Partner Synchronization process*/
     IF p_event_class_rec.record_flag = 'Y' AND
        p_event_class_rec.record_for_partners_flag = 'Y' AND
        nvl(p_event_class_rec.quote_flag,'N') = 'N' THEN               -- Bug 5131206
        FOR l_regime_index IN nvl(ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl.FIRST,0)..nvl(ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl.LAST,-99)
        LOOP
/* Bug 5131206 */
           IF ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl.EXISTS(l_regime_index) AND
              ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_regime_index).tax_provider_id IS NOT NULL THEN
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                  'Regime: '|| ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_regime_index).tax_regime_code||
                  ', Partner: '|| ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_regime_index).tax_provider_id);
              END IF;
              BEGIN
                 SELECT sync_with_prvdr_flag
                   INTO l_sync_with_prvdr_flag
                   FROM zx_detail_tax_lines_gt
                  WHERE application_id       = p_event_class_rec.application_id
                    AND entity_code          = p_event_class_rec.entity_code
                    AND event_class_code     = p_event_class_rec.event_class_code
                    AND trx_id               = p_event_class_rec.trx_id
                    AND tax_provider_id      = ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_regime_index).tax_provider_id
                    AND sync_with_prvdr_flag = 'Y'
                    AND rownum               = 1;
              EXCEPTION
                 WHEN OTHERS THEN
                    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                         'Others: l_sync_with_prvdr_flag = '|| l_sync_with_prvdr_flag);
                    END IF;
                    l_sync_with_prvdr_flag := 'N';
              END;
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                 'l_sync_with_prvdr_flag = '|| l_sync_with_prvdr_flag);
              END IF;
              IF l_sync_with_prvdr_flag = 'Y' THEN
                 l_sync_needed := TRUE;
                 ZX_TPI_SERVICES_PKG.call_partner_service(ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_regime_index).tax_regime_code,
                                                          ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_regime_index).tax_provider_id,
                                                          'SYNCHRONIZE_FOR_TAX',
                                                          p_event_class_rec,
                                                          l_return_status
                     			            );

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    x_return_status := l_return_status ;
                    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TPI_SERVICES_PKG.call_partner_service returned errors');
                    END IF;
                    RETURN;
                 END IF;

                 --Calling Post processing for synchronization with partner
                 ZX_TPI_SERVICES_PKG.ptnr_post_proc_sync_tax(ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_regime_index).tax_regime_code,
                                                             ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(l_regime_index).tax_provider_id,
                                                             p_event_class_rec,
                                                             l_return_status
                                		               );
                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    x_return_status := l_return_status ;
                    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||' :ZX_TPI_SERVICES_PKG.ptnr_post_proc_sync_tax returned errors');
                    END IF;
                    RETURN;
                 END IF;

              END IF; --sync_with_prvdr_flag
           END IF;    -- tax_provider_id is not null
        END LOOP;
      END IF;

      /* RE-INITIALISE SYNCHRONIZATION FLAG in ZX_LINES TO 'N' */
      IF l_sync_needed THEN
        --Call zx_lines table handler for updating the sync_with_prvdr_flag to N

        ZX_SRVC_TYP_PKG.zx_lines_table_handler(p_event_class_rec  => l_event_class_rec,
                                               p_event            => 'UPDATE',
                                               p_tax_regime_code  => null,
                                               p_provider_id      => null,
                                               x_return_status    => l_return_status
                                               );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_return_status := l_return_status;
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||' ZX_SRVC_TYPS.PKG.zx_lines_table_handler returned errors');
           END IF;
           RETURN;
         END IF;
      END IF; --l_sync_needed

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME || ': ' || l_api_name||'(-)');
      END IF;
 END ptnr_sync_calc_tax;


/* =============================================================*
 | PROCEDURE  	Perform Partner repository bulk synchronization |
 * ============================================================*/

 PROCEDURE ptnr_bulk_sync_calc_tax (
 p_event_class_rec    IN  event_class_rec_type ,
 x_return_status      OUT NOCOPY VARCHAR2
 )IS
   l_return_status         VARCHAR2(1);
   l_event_class_rec       event_class_rec_type;
   l_api_name              CONSTANT VARCHAR2(30) := 'PTNR_BULK_SYNC_CALC_TAX';
 BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR l_trx_id_index IN nvl(ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl.FIRST,0) .. nvl(ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl.LAST,-99)
       LOOP

          l_event_class_rec.application_id   := ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_trx_id_index).application_id;
          l_event_class_rec.event_class_code := ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_trx_id_index).event_class_code;
          l_event_class_rec.trx_id           := ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_trx_id_index).trx_id;
          l_event_class_rec.entity_code      := ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_trx_id_index).entity_code;
          l_event_class_rec.event_class_mapping_id := ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_trx_id_index).event_class_mapping_id;
          l_event_class_rec.event_type_code  := ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_trx_id_index).event_type_code;
          l_event_class_rec.record_flag      := ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_trx_id_index).record_flag;
          l_event_class_rec.quote_flag       := ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_trx_id_index).quote_flag;
          l_event_class_rec.record_for_partners_flag := ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_trx_id_index).record_for_partners_flag;
          l_event_class_rec.prod_family_grp_code := ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_trx_id_index).prod_family_grp_code;

          ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl := ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_trx_id_index).tax_regime_tbl;

   /*--------------------------------------------+
    |   Call to zx_security.set_security_context |
    +--------------------------------------------*/
          ZX_SECURITY.set_security_context(ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_trx_id_index).legal_entity_id,
                                     ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_trx_id_index).internal_organization_id,
                                     ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_trx_id_index).effective_date,
                                     l_return_status
                                     );

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
             'application_id: '||to_char(l_event_class_rec.application_id)||
             ', entity_code: '||l_event_class_rec.entity_code||
             ', event_class_code: '||l_event_class_rec.event_class_code||
             ', event_type_code: '||l_event_class_rec.event_type_code||
             ', trx_id: '||to_char(l_event_class_rec.trx_id)||
             ', internal_organization_id: '||to_char(l_event_class_rec.internal_organization_id)||
             ', ledger_id: '||to_char(l_event_class_rec.ledger_id)||
             ', legal_entity_id: '||to_char(l_event_class_rec.legal_entity_id)||
             ', trx_date: '||to_char(l_event_class_rec.trx_date)||
             ', related_document_date: '||to_char(l_event_class_rec.rel_doc_date)||
             ', provnl_tax_determination_date: '||to_char(l_event_class_rec.provnl_tax_determination_date)||
             ', trx_currency_code: '||l_event_class_rec.trx_currency_code||
             ', currency_conversion_type: '||l_event_class_rec.currency_conversion_type||
             ', currency_conversion_rate: '||to_char(l_event_class_rec.currency_conversion_rate)||
             ', currency_conversion_date: '||to_char(l_event_class_rec.currency_conversion_date)||
             ', rounding_ship_to_party_id: '||to_char(l_event_class_rec.rounding_ship_to_party_id)||
             ', rounding_ship_from_party_id: '||to_char(l_event_class_rec.rounding_ship_from_party_id)||
             ', rounding_bill_to_party_id: '||to_char(l_event_class_rec.rounding_bill_to_party_id)||
             ', rounding_bill_from_party_id: '||to_char(l_event_class_rec.rounding_bill_from_party_id)||
             ', rndg_ship_to_party_site_id: '||to_char(l_event_class_rec.rndg_ship_to_party_site_id)||
             ', rndg_ship_from_party_site_id: '||to_char(l_event_class_rec.rndg_ship_from_party_site_id)||
             ', rndg_bill_to_party_site_id: '||to_char(l_event_class_rec.rndg_bill_to_party_site_id)||
             ', rndg_bill_from_party_site_id: '||to_char(l_event_class_rec.rndg_bill_from_party_site_id)||
             ', quote_flag: '||l_event_class_rec.quote_flag ||
             ', establishment_id: '||to_char(l_event_class_rec.establishment_id)||
             ', icx_session_id: '||to_char(l_event_class_rec.icx_session_id));
    END IF;

          ptnr_sync_calc_tax ( p_event_class_rec   => l_event_class_rec ,
                               x_return_status     => l_return_status
                             );
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TRL_PUB_PKG.manage_taxlines returned errors');
                END IF;
                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
          END IF;

       END LOOP;
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME || ': ' || l_api_name||'(-)');
    END IF;
 END ptnr_bulk_sync_calc_tax;


PROCEDURE calculate_tax_pvt
 ( p_transaction_header_rec IN            transaction_header_rec_type,
   p_api_name               IN            VARCHAR2,
   p_event_id               IN            NUMBER,
   p_index                  IN            NUMBER,
   p_api_version            IN            NUMBER,
   p_init_msg_list          IN            VARCHAR2,
   p_commit                 IN            VARCHAR2,
   p_validation_level       IN            NUMBER,
   x_return_status          IN OUT NOCOPY VARCHAR2,
   x_msg_count              IN OUT NOCOPY NUMBER,
   x_msg_data               IN OUT NOCOPY VARCHAR2
 ) IS
   l_sync_needed           BOOLEAN;
   l_return_status         VARCHAR2(30);
   l_event_class_rec       event_class_rec_type;
   l_record_tax_lines      VARCHAR2(1);
   l_error_buffer          VARCHAR2(1000);

  BEGIN
     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||p_api_name||'.BEGIN','ZX_API_PUB: calculate_tax_pvt()+');
     END IF;
   /*------------------------------------------------------+
    |   Copy to Event Class Record                         |
    +------------------------------------------------------*/
    l_event_class_rec.EVENT_ID                     :=  p_event_id;
    l_event_class_rec.INTERNAL_ORGANIZATION_ID     :=  p_transaction_header_rec.INTERNAL_ORGANIZATION_ID(p_index);
    l_event_class_rec.APPLICATION_ID               :=  p_transaction_header_rec.APPLICATION_ID(p_index);
    l_event_class_rec.ENTITY_CODE                  :=  p_transaction_header_rec.ENTITY_CODE(p_index);
    l_event_class_rec.EVENT_CLASS_CODE             :=  p_transaction_header_rec.EVENT_CLASS_CODE(p_index);
    l_event_class_rec.ICX_SESSION_ID               :=  p_transaction_header_rec.ICX_SESSION_ID(p_index);
    l_event_class_rec.QUOTE_FLAG		   :=  nvl(p_transaction_header_rec.QUOTE_FLAG(p_index),'N');

/*
    l_event_class_rec.LEGAL_ENTITY_ID              :=  p_transaction_header_rec.LEGAL_ENTITY_ID(p_index);
    l_event_class_rec.LEDGER_ID                    :=  p_transaction_header_rec.LEDGER_ID(p_index);
    l_event_class_rec.EVENT_TYPE_CODE              :=  p_transaction_header_rec.EVENT_TYPE_CODE(p_index);
    l_event_class_rec.CTRL_TOTAL_HDR_TX_AMT        :=  p_transaction_header_rec.CTRL_TOTAL_HDR_TX_AMT(p_index);
    l_event_class_rec.TRX_ID                       :=  p_transaction_header_rec.TRX_ID(p_index);
    l_event_class_rec.TRX_DATE                     :=  p_transaction_header_rec.TRX_DATE(p_index);
    l_event_class_rec.REL_DOC_DATE                 :=  p_transaction_header_rec.REL_DOC_DATE(p_index);
    l_event_class_rec.PROVNL_TAX_DETERMINATION_DATE:=  p_transaction_header_rec.PROVNL_TAX_DETERMINATION_DATE(p_index);
    l_event_class_rec.TRX_CURRENCY_CODE            :=  p_transaction_header_rec.TRX_CURRENCY_CODE(p_index);
    l_event_class_rec.PRECISION                    :=  p_transaction_header_rec.PRECISION(p_index);
    l_event_class_rec.CURRENCY_CONVERSION_TYPE     :=  p_transaction_header_rec.CURRENCY_CONVERSION_TYPE(p_index);
    l_event_class_rec.CURRENCY_CONVERSION_RATE     :=  p_transaction_header_rec.CURRENCY_CONVERSION_RATE(p_index);
    l_event_class_rec.CURRENCY_CONVERSION_DATE     :=  p_transaction_header_rec.CURRENCY_CONVERSION_DATE(p_index);
    l_event_class_rec.ROUNDING_SHIP_TO_PARTY_ID    :=  p_transaction_header_rec.ROUNDING_SHIP_TO_PARTY_ID(p_index);
    l_event_class_rec.ROUNDING_SHIP_FROM_PARTY_ID  :=  p_transaction_header_rec.ROUNDING_SHIP_FROM_PARTY_ID(p_index);
    l_event_class_rec.ROUNDING_BILL_TO_PARTY_ID    :=  p_transaction_header_rec.ROUNDING_BILL_TO_PARTY_ID(p_index);
    l_event_class_rec.ROUNDING_BILL_FROM_PARTY_ID  :=  p_transaction_header_rec.ROUNDING_BILL_FROM_PARTY_ID(p_index);
    l_event_class_rec.RNDG_SHIP_TO_PARTY_SITE_ID   :=  p_transaction_header_rec.RNDG_SHIP_TO_PARTY_SITE_ID(p_index);
    l_event_class_rec.RNDG_SHIP_FROM_PARTY_SITE_ID :=  p_transaction_header_rec.RNDG_SHIP_FROM_PARTY_SITE_ID(p_index);
    l_event_class_rec.RNDG_BILL_TO_PARTY_SITE_ID   :=  p_transaction_header_rec.RNDG_BILL_TO_PARTY_SITE_ID(p_index);
    l_event_class_rec.RNDG_BILL_FROM_PARTY_SITE_ID :=  p_transaction_header_rec.RNDG_BILL_FROM_PARTY_SITE_ID(p_index);
    l_event_class_rec.ESTABLISHMENT_ID             :=  p_transaction_header_rec.ESTABLISHMENT_ID(p_index);

*/

    IF l_event_class_rec.QUOTE_FLAG = 'Y' and
       l_event_class_rec.ICX_SESSION_ID is not null THEN
        ZX_SECURITY.G_ICX_SESSION_ID := l_event_class_rec.ICX_SESSION_ID;
      --dbms_session.set_context('my_ctx','SESSIONID',to_char(ZX_SECURITY.G_ICX_SESSION_ID));
        ZX_SECURITY.name_value('SESSIONID',to_char(ZX_SECURITY.G_ICX_SESSION_ID));

    END IF;

    -- Bug 4948674: Following Delete will not work when there are different dbms sessions used for the same user
    -- session when call originates from a FWK UI. Moved the following Delete logic to the end of this API for O2C
    -- products and to the end of determine_recovery API for P2P products.

    --If the user calls calculate_tax twice using same db session for the same icx session, then we will have
    -- un-deleted data in the Det Factors table for the previousc all. So, we need to clean it up first before
    -- starting to process the input lines of the new call.We should at first always attempt to remove any rows
    --sitting in Det Factors table for that icx session
/*    IF  l_event_class_rec.ICX_SESSION_ID is not null THEN
       DELETE from zx_lines_det_factors
         WHERE application_id   = l_event_class_rec.application_id and
               entity_code      = l_event_class_rec.entity_code and
               event_class_code = l_event_class_rec.event_class_code and
               trx_id           = l_event_class_rec.trx_id;
    END IF;
*/

    /*-------------------------------------------------------+
     |Lock the tax lines table to prevent another             |
     |user from updating same line via the forms/UIs while    |
     |calculation is in progress                              |
     +------------------------------------------------------*/
/*

    IF l_event_class_rec.tax_event_type_code ='UPDATE' THEN

      ZX_TRL_DETAIL_OVERRIDE_PKG.lock_dtl_tax_lines_for_doc(p_application_id      => l_event_class_rec.application_id,
                                                            p_entity_code         => l_event_class_rec.entity_code,
                                                            p_event_class_code    => l_event_class_rec.event_class_code,
                                                            p_trx_id              => l_event_class_rec.trx_id,
                                                            x_return_status       => l_return_status,
                                                            x_error_buffer        => l_error_buffer
                                                            );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||p_api_name,
                 ' RETURN_STATUS = ' || x_return_status);
        END IF;
        RETURN;
      END IF;

      ZX_TRL_SUMMARY_OVERRIDE_PKG.lock_summ_tax_lines_for_doc(p_application_id      => l_event_class_rec.application_id,
                                                              p_entity_code         => l_event_class_rec.entity_code,
                                                              p_event_class_code    => l_event_class_rec.event_class_code,
                                                              p_trx_id              => l_event_class_rec.trx_id,
                                                              x_return_status       => l_return_status,
                                                              x_error_buffer        => l_error_buffer
                                                              );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||p_api_name,
                 ' RETURN_STATUS = ' || x_return_status);
        END IF;
        RETURN;
      END IF;

      ZX_TRL_DISTRIBUTIONS_PKG.lock_rec_nrec_dist_for_doc (p_application_id      => l_event_class_rec.application_id,
                                                           p_entity_code         => l_event_class_rec.entity_code,
                                                           p_event_class_code    => l_event_class_rec.event_class_code,
                                                           p_trx_id              => l_event_class_rec.trx_id,
                                                           x_return_status       => l_return_status,
                                                           x_error_buffer        => l_error_buffer
                                                           );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||p_api_name,
                 ' RETURN_STATUS = ' || x_return_status);
        END IF;
        RETURN;
      END IF;
    END IF; --tax event type ='UPDATE'
*/


     /*------------------------------------------------------+
      |   Validate and Initializate parameters for Calculate |
      |   tax                                                |
      +------------------------------------------------------*/

         ZX_GLOBAL_STRUCTURES_PKG.g_party_tax_prof_id_info_tbl.DELETE;
    ZX_VALID_INIT_PARAMS_PKG.calculate_tax(p_event_class_rec => l_event_class_rec,
                                           x_return_status   => l_return_status
                                          );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status ;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||p_api_name,G_PKG_NAME||': '||p_api_name||':ZX_VALID_INIT_PARAMS_PKG.calculate_tax returned errors');
       END IF;
       RETURN;
    END IF;

    /* ===============================================================================*
    |Initialize the global structures/global temp tables owned by TDM at line level |
    * =============================================================================*/
    ZX_TDS_CALC_SERVICES_PUB_PKG.initialize (l_event_class_rec ,
                                             'HEADER',
                                              l_return_status
                                            );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||p_api_name,G_PKG_NAME||': '||p_api_name||':ZX_TDS_CALC_SERVICES_PUB_PKG.initialize returned errors');
       END IF;
       RETURN;
    END IF;


    /*----------------------------------------------------+
     |Call to service type Calculate Tax                  |
     +---------------------------------------------------*/
      ZX_SRVC_TYP_PKG.calculate_tax(p_event_class_rec    => l_event_class_rec,
                                    x_return_status      => l_return_status
                                   );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status ;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||p_api_name,G_PKG_NAME||': '||p_api_name||':ZX_SRVC_TYP_PKG.calculate_tax returned errors');
        END IF;
        RETURN;
      END IF;


        /*---------------------------------------------------------+
         | Delete from the global structures for every loop on the |
         | header document so that there are no hanging/redundant  |
         | records sitting there                                   |
         +--------------------------------------------------------*/
         --Calling routine to delete the global structures
         ZX_GLOBAL_STRUCTURES_PKG.delete_trx_line_dist_tbl;

         --Also delete the location caching global structures
         --** execute the following code only when tax partners are used.
         ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.EVENT_CLASS_MAPPING_ID.DELETE;
         ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.TRX_ID.DELETE;
         ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.TRX_LINE_ID.DELETE;
         ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.TRX_LEVEL_TYPE.DELETE;
         ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.LOCATION_TYPE.DELETE;
         ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.LOCATION_TABLE_NAME.DELETE;
         ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.LOCATION_ID.DELETE;
         ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.GEOGRAPHY_TYPE.DELETE;
         ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.GEOGRAPHY_VALUE.DELETE;
         ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.GEOGRAPHY_ID.DELETE;
         ZX_GLOBAL_STRUCTURES_PKG.LOCATION_HASH_TBL.DELETE;

         IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||p_api_name||'.END','ZX_API_PUB: '||'calculate_tax_pvt'||'()-');
         END IF;
  END calculate_tax_pvt;


PROCEDURE import_tax_pvt
 ( p_evnt_cls               IN            evnt_cls_rec_type,
   p_api_name               IN            VARCHAR2,
   p_event_id               IN            NUMBER,
   p_index                  IN            NUMBER,
   p_api_version            IN            NUMBER,
   p_init_msg_list          IN            VARCHAR2,
   p_commit                 IN            VARCHAR2,
   p_validation_level       IN            NUMBER,
   x_return_status          IN OUT NOCOPY VARCHAR2,
   x_msg_count              IN OUT NOCOPY NUMBER,
   x_msg_data               IN OUT NOCOPY VARCHAR2
  ) IS
   l_sync_needed                 BOOLEAN;
   l_return_status               VARCHAR2(30);
   l_event_class_rec             event_class_rec_type;

  BEGIN
   /*------------------------------------------------------+
    |   Copy to Event Class Record                         |
    +------------------------------------------------------*/
     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||p_api_name||'.BEGIN','ZX_API_PUB: import_tax_pvt()+');
     END IF;

    l_event_class_rec.EVENT_ID                     :=  p_event_id;
    l_event_class_rec.INTERNAL_ORGANIZATION_ID     :=  p_evnt_cls.INTERNAL_ORGANIZATION_ID(p_index);
    l_event_class_rec.APPLICATION_ID               :=  p_evnt_cls.APPLICATION_ID(p_index);
    l_event_class_rec.ENTITY_CODE                  :=  p_evnt_cls.ENTITY_CODE(p_index);
    l_event_class_rec.EVENT_CLASS_CODE             :=  p_evnt_cls.EVENT_CLASS_CODE(p_index);


   /*------------------------------------------------------+
    |   Validate Input Paramerters and Fetch Tax Options   |
    +------------------------------------------------------*/

    ZX_VALID_INIT_PARAMS_PKG.import_document_with_tax(p_event_class_rec =>l_event_class_rec,
                                                      x_return_status   =>l_return_status
                                                      );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||p_api_name,G_PKG_NAME||': '||p_api_name||':ZX_VALID_INIT_PARAMS_PKG.import_document_with_tax returned errors');
       END IF;
       RETURN;
    END IF;


     /*--------------------------------------------------+
      |   Call Service Type Import Document with Tax     |
      +--------------------------------------------------*/

      ZX_SRVC_TYP_PKG.import(p_event_class_rec  => l_event_class_rec,
                             x_return_status    => l_return_status
                            );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||p_api_name,G_PKG_NAME||': '||p_api_name||':ZX_SRVC_TYP_PKG.import returned errors');
        END IF;
        RETURN;
      END IF;


        /*---------------------------------------------------------+
         | Delete from the global structures for every loop on the |
         | header document so that there are no hanging/redundant  |
         | records sitting there                                   |
         +--------------------------------------------------------*/
         --Calling routine to delete the global structures
         ZX_GLOBAL_STRUCTURES_PKG.delete_trx_line_dist_tbl;

         --Also delete the location caching global structures
         --** Execute this code only when partners are used
         IF zx_global_structures_pkg.g_ptnr_srvc_subscr_flag = 'Y' THEN
	      ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.EVENT_CLASS_MAPPING_ID.DELETE;
              ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.TRX_ID.DELETE;
              ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.TRX_LINE_ID.DELETE;
	      ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.TRX_LEVEL_TYPE.DELETE;
	      ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.LOCATION_TYPE.DELETE;
              ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.LOCATION_TABLE_NAME.DELETE;
              ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.LOCATION_ID.DELETE;
              ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.GEOGRAPHY_TYPE.DELETE;
              ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.GEOGRAPHY_VALUE.DELETE;
              ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.GEOGRAPHY_ID.DELETE;
              ZX_GLOBAL_STRUCTURES_PKG.LOCATION_HASH_TBL.DELETE;

              ZX_GLOBAL_STRUCTURES_PKG.g_party_tax_prof_id_info_tbl.DELETE;
         END IF;

         IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||p_api_name||'.END','ZX_API_PUB: '||'import_tax_pvt'||'()-');
         END IF;

END import_tax_pvt;

/* ======================================================================*
 | PROCEDURE calculate_tax : Calculates and records tax info             |
 | There exists a pl/sql version of same API for performance             |
 | This API also supports processing for multiple event classes          |
 | GTT involved : ZX_TRX_HEADERS_GT, ZX_TRANSACTION_LINES_GT             |
 * ======================================================================*/

 PROCEDURE Calculate_tax
   ( p_api_version           IN         NUMBER,
     p_init_msg_list         IN         VARCHAR2,
     p_commit                IN         VARCHAR2,
     p_validation_level      IN         NUMBER,
     x_return_status         OUT NOCOPY VARCHAR2,
     x_msg_count             OUT NOCOPY NUMBER,
     x_msg_data              OUT NOCOPY VARCHAR2
   ) IS

   l_api_name          CONSTANT  VARCHAR2(30) := 'CALCULATE_TAX';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_event_id                    NUMBER;
   l_transaction_header_rec      transaction_header_rec_type;
   l_context_info_rec            context_info_rec_type;
   l_index                       BINARY_INTEGER;
   l_precedence                  NUMBER_tbl_type;
   l_init_msg_list               VARCHAR2(1);
   l_record_tax_lines            VARCHAR2(1);
   l_ptnr_index                       NUMBER;

 CURSOR common_header_info IS
     SELECT
            INTERNAL_ORGANIZATION_ID,
            APPLICATION_ID,
          --  ENTITY_CODE,
          --  EVENT_CLASS_CODE,
            QUOTE_FLAG,
            ICX_SESSION_ID
       FROM ZX_TRX_HEADERS_GT
      WHERE rownum = 1;

    CURSOR event_classes IS
     SELECT distinct
            header.event_class_code,
            header.application_id,
            header.entity_code,
            header.internal_organization_id,
            evntmap.processing_precedence
       FROM ZX_EVNT_CLS_MAPPINGS evntmap,
            ZX_TRX_HEADERS_GT header
      WHERE header.application_id = evntmap.application_id
        AND header.entity_code = evntmap.entity_code
        AND header.event_class_code = evntmap.event_class_code
   ORDER BY evntmap.processing_precedence;

    CURSOR c_headers is
    SELECT APPLICATION_ID,
           ENTITY_CODE,
           EVENT_CLASS_CODE,
           TRX_ID,
           ICX_SESSION_ID,
           EVENT_TYPE_CODE,
           TAX_EVENT_TYPE_CODE,
           DOC_EVENT_STATUS
    FROM ZX_TRX_HEADERS_GT;

    l_application_id_tbl     	NUMBER_tbl_type;
    l_entity_code_tbl    	VARCHAR2_30_tbl_type;
    l_event_class_code_tbl	VARCHAR2_30_tbl_type;
    l_trx_id_tbl		NUMBER_tbl_type;
    l_icx_session_id_tbl	NUMBER_tbl_type;
    l_event_type_code_tbl	VARCHAR2_30_tbl_type;
    l_tax_event_type_code_tbl	VARCHAR2_30_tbl_type;
    l_doc_event_status_tbl	VARCHAR2_30_tbl_type;

   BEGIN
     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: CALCULATE_TAX()+');
     END IF;

    /*--------------------------------------------------+
    |   Standard start of API savepoint                 |
    +--------------------------------------------------*/
    SAVEPOINT Calculate_tax_PVT;

    /*--------------------------------------------------+
    |   Standard call to check for call compatibility   |
    +--------------------------------------------------*/

    IF NOT FND_API.Compatible_API_Call(
                                       l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       )  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    /*--------------------------------------------------------------+
    |   Initialize message list if p_init_msg_list is set to TRUE  |
    +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
	   l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;


    /*-----------------------------------------+
    |   Initialize return status to SUCCESS   |
    +-----------------------------------------*/

     x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*-----------------------------------------+
    |   Populate Global Variable              |
    +-----------------------------------------*/

     G_PUB_SRVC := l_api_name;
     G_PUB_CALLING_SRVC := l_api_name;
     G_DATA_TRANSFER_MODE := 'TAB';
     G_EXTERNAL_API_CALL  := 'N';

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
             'Data Transfer Mode: '||G_DATA_TRANSFER_MODE);
     END IF;

     --Call TDS process to reset the session for previous calculate tax calls if any
      ZX_TDS_CALC_SERVICES_PUB_PKG.initialize (p_event_class_rec => NULL,
                                               p_init_level      => 'SESSION',
                                               x_return_status   => l_return_status
                                              );

      set_ptnr_srvc_subscr_flag (p_event_class_rec => NULL,
                                 x_return_status   => l_return_status
                                );
      /*---------------------------------------------------------+
      |  Initialize the trx line app regimes table for every doc|
      +--------------------------------------------------------*/

      IF zx_global_structures_pkg.g_ptnr_srvc_subscr_flag = 'Y' THEN
         ZX_GLOBAL_STRUCTURES_PKG.init_trx_line_app_regime_tbl;
      END IF;

        ZX_GLOBAL_STRUCTURES_PKG.LOC_GEOGRAPHY_INFO_TBL.DELETE;
        ZX_GLOBAL_STRUCTURES_PKG.g_registration_info_tbl.DELETE;
     /*-----------------------------------------+
     | Get the event id for the whole document |
     +-----------------------------------------*/
     --Bug 7650433
     --select ZX_LINES_DET_FACTORS_S.nextval
     --into l_event_id
     --from dual;

     OPEN event_classes;
       LOOP
        FETCH event_classes BULK COLLECT INTO
          l_evnt_cls.event_class_code,
          l_evnt_cls.application_id,
          l_evnt_cls.entity_code,
          l_evnt_cls.internal_organization_id,
          l_evnt_cls.precedence
        LIMIT G_LINES_PER_FETCH;
        EXIT WHEN event_classes%NOTFOUND;
       END LOOP;
     CLOSE event_classes;

     --Event classes such as SALES_TRANSACTION_TAX_QUOTE/PURCHASE_TRANSACTION_TAX_QUOTE
     --are not seeded in zx_evnt_cls_mappings so cursor event classes will not
     --return any rows for such event classes passed.
     IF l_evnt_cls.event_class_code.LAST is null THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
             'Event class information does not exist - indicates SALES_TRANSACTION_TAX_QUOTE/PURCHASE_TRANSACTION_TAX_QUOTE');
       END IF;

       select event_class_code,
              application_id,
              entity_code,
              internal_organization_id
         into l_evnt_cls.event_class_code(1),
              l_evnt_cls.application_id(1),
              l_evnt_cls.entity_code(1),
              l_evnt_cls.internal_organization_id(1)
         from ZX_TRX_HEADERS_GT
         where rownum=1;
     END IF;

     -- added for bug fix 5417887

-- Assumption for multiple docs: application_id, event class and OU
-- will be same for all transactions in a call.

     OPEN common_header_info;
     FETCH common_header_info BULK COLLECT INTO
             l_transaction_header_rec.INTERNAL_ORGANIZATION_ID,
             l_transaction_header_rec.APPLICATION_ID,
          --   l_transaction_header_rec.ENTITY_CODE,
          --   l_transaction_header_rec.EVENT_CLASS_CODE,
             l_transaction_header_rec.QUOTE_FLAG,
             l_transaction_header_rec.ICX_SESSION_ID;

     CLOSE common_header_info;

    FOR i IN 1..nvl(l_evnt_cls.event_class_code.LAST,0)
    LOOP

         --Bug 7650433
         select ZX_LINES_DET_FACTORS_S.nextval
         into l_event_id
         from dual;

         IF l_evnt_cls.event_class_code(i) = 'CREDIT_MEMO' THEN
           ZX_GLOBAL_STRUCTURES_PKG.g_credit_memo_exists_flg := 'Y';
         END IF;

         -- Bug 5704675- need to use index here to avoid entity_code
         -- and event_class_code in l_transaction_header_rec always
         -- using the entity_code and event_class_code from the 1st
         -- record of l_evnt_cls
         --
         l_transaction_header_rec.ENTITY_CODE(1)      := l_evnt_cls.entity_code(i);
         l_transaction_header_rec.EVENT_CLASS_CODE(1) := l_evnt_cls.event_class_code(i);

         --BEGIN
         --    SAVEPOINT Calculate_Tax_Doc_Norel_PVT;
               calculate_tax_pvt (l_transaction_header_rec,
                                  l_api_name,
                                  l_event_id,
                                  1,
                                  p_api_version,
                                  l_init_msg_list,
                                  p_commit,
                                  p_validation_level,
                                  l_return_status,
                                  x_msg_count,
                                  x_msg_data
                                 );

               IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

          /*
               EXCEPTION
                 WHEN FND_API.G_EXC_ERROR THEN
                  -- ROLLBACK TO Calculate_Tax_Doc_Norel_PVT;
                   x_return_status := FND_API.G_RET_STS_ERROR ;
                   --Call API to dump into zx_errors_gt
                   IF ( errors_tbl.application_id.LAST is NOT NULL) THEN
                      DUMP_MSG;
                   END IF;
                   IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
                   END IF;
             END;
         */


     -- bug fix 5417887 begin 17-Aug-2006
     -- Following code for tail end services/TRL/ptnr sync code, is moved from calculte_tax_pvt
     -- and should be handled for each event_class_code. At present, all product integrations call etax
     -- for one event class at a time, hence we put these processed out of the event class loop.
     -- In the future, if there are cases that etax handle multiple event_class batch, we need to
     -- revisist the following code and change accordingly.

     -- For furture LTE features, there are could cases that related documents was imported together
     -- with original document. For this case, we need to make sure the tail end service for the original
     -- docs must be handled before the calculation process of the related docs.

     /*-----------------------------------------------------+
      |   Call to eTax service Dump Detail Tax Lines Into GT|
      +-----------------------------------------------------*/

     --IF nvl(l_event_class_rec.PROCESS_FOR_APPLICABILITY_FLAG,'Y') = 'Y' THEN
     ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt(x_return_status => l_return_status);


     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
        --DUMP_MSG;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt returned errors');
        END IF;
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
     END IF;

     /*--------------------------------------------------+
      |   Call to eTax Service Tax Lines Determination   |
      +--------------------------------------------------*/
     ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination(p_event_class_rec => zx_global_structures_pkg.g_event_class_rec,
                                                          x_return_status   => l_return_status
							   );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status ;
       --DUMP_MSG;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;

     --  Replace the below call with a merge statement

     /*--------------------------------------------------+
      |   Call to Update Total Inclusive Tax Amount      |
      +--------------------------------------------------*/

     /* Replace the call to update_total_inc_tax_amt with the merge statement below

     update_total_inc_tax_amt(p_event_class_rec => zx_global_structures_pkg.g_event_class_rec,
                              x_return_status   => l_return_status
	                      );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status ;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||p_api_name,G_PKG_NAME||': '||p_api_name||':update_total_inc_tax_amt returned errors');
       END IF;
       RETURN;
     END IF;
     */

     IF zx_global_structures_pkg.g_event_class_rec.prod_family_grp_code = 'P2P' THEN
        MERGE INTO  ZX_LINES_DET_FACTORS     lines_dt
        USING (SELECT
                     application_id,
                     entity_code,
                     event_class_code,
                     trx_id,
                     trx_level_type,
                     trx_line_id,
                     sum(tax_amt)   incl_tax_amt
               FROM
                    zx_detail_tax_lines_gt TaxLines
               WHERE
                     tax_amt_included_flag = 'Y'
           --    AND mrc_tax_line_flag = 'N'
     	         AND cancel_flag <> 'Y'
           GROUP BY
                     application_id,
                     entity_code,
                     event_class_code,
                     trx_id,
                     trx_level_type,
                     trx_line_id
             ) Temp
         ON  (      lines_dt.tax_amt_included_flag = 'Y'
               --AND  lines_dt.total_inc_tax_amt is NULL
               AND  lines_dt.application_id   = temp.application_id
               AND  lines_dt.entity_code      = temp.entity_code
               AND  lines_dt.event_class_code = temp.event_class_code
               AND  lines_dt.trx_id           = temp.trx_id
               AND  Lines_dt.trx_level_type   = temp.trx_level_type
               AND  Lines_dt.trx_line_id      = temp.trx_line_id
              )
         WHEN MATCHED THEN
           UPDATE SET
                  total_inc_tax_amt   = incl_tax_amt;

     END IF;


     /*--------------------------------------------------+
      |   Call to eTax Service Manage Tax Lines          |
      +--------------------------------------------------*/
     --Rounding and Summarizing Tax Lines for Transaction
     /*Bug 3649502 - Check for record flag before calling TRR service*/
     /*Bug 4232918 - If record flag =Y and quote flag =Y then do not
       record in zx_lines */
     l_record_tax_lines := ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.record_flag;
     IF ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.record_flag = 'Y' and
        ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.quote_flag = 'Y' THEN
        l_record_tax_lines := 'N';
     END IF;
     IF l_record_tax_lines = 'Y' THEN
        ZX_TRL_PUB_PKG.manage_taxlines(p_event_class_rec  =>zx_global_structures_pkg.g_event_class_rec,
                                       x_return_status    =>l_return_status
                                      );
     END IF;

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status ;
        --DUMP_MSG;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TRL_PUB_PKG.manage_taxlines returned errors');
        END IF;
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
     END IF;
     --END IF; --process_applicability_flag is 'Y'

     /*******************************PARTNER CODE START****************************/
     -- check with Santosh for a compatible API
     IF zx_global_structures_pkg.g_ptnr_srvc_subscr_flag = 'Y' THEN
       ptnr_bulk_sync_calc_tax ( p_event_class_rec   => zx_global_structures_pkg.g_event_class_rec ,
                            x_return_status     => l_return_status
                          );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_return_status := l_return_status;
           --DUMP_MSG;
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ptnr_bulk_sync_calc_tax returned errors');
           END IF;
           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
       END IF;
     END IF;

     /*-----------------------------------------------------------+
     | Do not record lines based on following condition           |
     +-----------------------------------------------------------*/
     IF (ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.RECORD_FLAG = 'Y' and
         ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.quote_flag = 'Y' and
         ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.icx_session_id is null)
         OR
        (ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.RECORD_FLAG = 'N' and
         ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.quote_flag = 'Y' and
         ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.intgrtn_det_factors_ui_flag = 'N' and
         ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.icx_session_id is null)
         OR
         /*------------------------------------------------------------------------------+
          |  Bug 4948674: Handle delete for O2C products when icx_session_id is NOT NULL |
          +------------------------------------------------------------------------------*/
        (zx_global_structures_pkg.g_event_class_rec.ICX_SESSION_ID is not null AND
         zx_global_structures_pkg.g_event_class_rec.PROD_FAMILY_GRP_CODE = 'O2C')
      THEN

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                  'Delete lines for transaction header which need not be recorded');
         END IF;

         BEGIN
/*
             OPEN C_HEADERS;
             LOOP
                FETCH c_HEADERS BULK COLLECT INTO
                    l_application_id_tbl,
                    l_entity_code_tbl,
                    l_event_class_code_tbl,
                    l_trx_id_tbl,
                    l_icx_session_id_tbl,
                    l_event_type_code_tbl,
                    l_tax_event_type_code_tbl,
                    l_doc_event_status_tbl
                LIMIT G_LINES_PER_FETCH;


                FORALL i IN l_trx_id_tbl.FIRST .. l_trx_id_tbl.LAST
*/
                    DELETE FROM zx_lines_det_factors
                    WHERE  (APPLICATION_ID, ENTITY_CODE, EVENT_CLASS_CODE, TRX_ID)
                           IN (SELECT /*+ cardinality (ZX_TRX_HEADERS_GT 1) */ APPLICATION_ID, ENTITY_CODE, EVENT_CLASS_CODE, TRX_ID
                               FROM ZX_TRX_HEADERS_GT);



/*
                exit when c_HEADERS%NOTFOUND;
             END LOOP;

             close c_HEADERS;
*/
         EXCEPTION
              WHEN OTHERS THEN

                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||': returned errors');
                     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name, SQLCODE||' ; '||SQLERRM);
                END IF;

                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
                FND_MSG_PUB.Add;

                IF  c_HEADERS%ISOPEN THEN
                      close c_HEADERS;
                END IF;
         END;
     ELSE

        /*-----------------------------------------------------+
         |  Handle delete for mark tax lines deleted           |
         +-----------------------------------------------------*/
         --Remove all lines marked for delete by the mark_tax_lines_deleted API
         BEGIN
/*
             OPEN C_HEADERS;
             LOOP
                FETCH c_HEADERS BULK COLLECT INTO
                    l_application_id_tbl,
                    l_entity_code_tbl,
                    l_event_class_code_tbl,
                    l_trx_id_tbl,
                    l_icx_session_id_tbl,
                    l_event_type_code_tbl,
                    l_tax_event_type_code_tbl,
                    l_doc_event_status_tbl
                LIMIT G_LINES_PER_FETCH;

                FORALL i IN l_trx_id_tbl.FIRST .. l_trx_id_tbl.LAST

                     DELETE from zx_lines_det_factors
                     WHERE APPLICATION_ID   = l_application_id_tbl(i)
                      AND ENTITY_CODE       = l_entity_code_tbl(i)
                      AND EVENT_CLASS_CODE  = l_event_class_code_tbl(i)
                      AND TRX_ID            = l_trx_id_tbl(i)
                      AND line_level_action ='DELETE';

*/
                    DELETE  /*+ ORDERED USE_NL_WITH_INDEX (Z,ZX_LINES_DET_FACTORS_U1) */ FROM zx_lines_det_factors Z
                    WHERE  (Z.APPLICATION_ID, Z.ENTITY_CODE, Z.EVENT_CLASS_CODE, Z.TRX_ID)
                           IN (SELECT  /*+ unnest cardinality (ZX_TRX_HEADERS_GT 1) */
                               APPLICATION_ID, ENTITY_CODE, EVENT_CLASS_CODE, TRX_ID
                               FROM ZX_TRX_HEADERS_GT)
                      AND  Z.line_level_action ='DELETE';


/*
                exit when c_HEADERS%NOTFOUND;
             END LOOP;

             close c_HEADERS;
*/
           EXCEPTION
              WHEN OTHERS THEN

                IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||': returned errors');
                     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name, SQLCODE||' ; '||SQLERRM);
                END IF;

                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
                FND_MSG_PUB.Add;

                IF  c_HEADERS%ISOPEN THEN
                      close c_HEADERS;
                END IF;
            END;

     END IF;


     /*----------------------------------------------------------------+
     | Set the tax_reporting_flag to 'N' for documents called for quote|
     +----------------------------------------------------------------*/
-- Bug Fix for 5155481 - Commented out the following update. Reporting flag is set during the
-- insert itself based on the record_flag.

/*         IF l_event_class_rec.QUOTE_FLAG = 'Y' THEN
	       UPDATE zx_lines_det_factors
	         SET tax_reporting_flag ='N'
           WHERE application_id       = l_event_class_rec.application_id
	         AND entity_code      = l_event_class_rec.entity_code
	         AND event_class_code = l_event_class_rec.event_class_code
  		 AND trx_id           = l_event_class_rec.trx_id;
          END IF;
*/
     -- bug fix 5417887 end

     -- bug#6594730
     -- need to flush ZX_DETAIL_TAX_LINES_GT before the procedure
     -- calculate_tax_pvt is called for the next event class

     IF l_record_tax_lines = 'Y' THEN
       DELETE FROM ZX_DETAIL_TAX_LINES_GT;
     END IF;

     -- bug 6824850
     ZX_GLOBAL_STRUCTURES_PKG.PTNR_TAX_REGIME_TBL.DELETE;
     ZX_GLOBAL_STRUCTURES_PKG.lte_trx_tbl.DELETE;

    END LOOP;  -- i IN 1..nvl(l_evnt_cls.event_class_code.LAST,0)

     /*---------------------------------------------------------+
     | Set the out parameter                                   |
     +--------------------------------------------------------*/
     BEGIN
        UPDATE ZX_TRX_HEADERS_GT headers
	   SET doc_level_recalc_flag = (SELECT distinct(lines.threshold_indicator_flag)
  	                                FROM ZX_LINES_DET_FACTORS lines
                                        WHERE lines.application_id = headers.application_id
                                          AND lines.event_class_code = headers.event_class_code
                                          AND lines.entity_code  = headers.entity_code
                                          AND lines.trx_id = headers.trx_id
	                                  AND lines.threshold_indicator_flag = 'Y' -- Bug 5210984
                                       );
     EXCEPTION WHEN OTHERS THEN
        null;
     END;

     --Reset the icx_session_id at end of API
     ZX_SECURITY.G_ICX_SESSION_ID := null;
     ZX_SECURITY.name_value('SESSIONID',to_char(ZX_SECURITY.G_ICX_SESSION_ID));
     --dbms_session.set_context('my_ctx','SESSIONID',to_char(ZX_SECURITY.G_ICX_SESSION_ID));


     --Reset G_PUB_CALLING_SRVC at end of API
     ZX_API_PUB.G_PUB_CALLING_SRVC := null;

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: CALCULATE_TAX()-');
     END IF;

     EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO Calculate_tax_PVT;
         --Close all open cursors
         IF common_header_info%ISOPEN THEN CLOSE common_header_info; END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         DUMP_MSG;
         IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
         END IF;

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO Calculate_tax_PVT;
         --Close all open cursors
         IF common_header_info%ISOPEN THEN CLOSE common_header_info; END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         DUMP_MSG;
         FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
         FND_MSG_PUB.add;
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count   =>      x_msg_count,
                                   p_data    =>      x_msg_data
                                  );
         IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
         END IF;

       WHEN OTHERS THEN
          ROLLBACK TO Calculate_tax_PVT;
          --Close all open cursors
          IF common_header_info%ISOPEN THEN CLOSE common_header_info; END IF;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          DUMP_MSG;
          FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
          FND_MSG_PUB.add;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count   =>      x_msg_count,
                                   p_data    =>      x_msg_data
                                   );
          IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;
    END calculate_tax; --gtt version

  /*======================================================================*
 | PROCEDURE calculate_tax : Calculates and records tax info             |
 | PL/sql tables: trx_line_dist_tbl   , transaction_rec                  |
 |                                                                       |
 | This API will be also called by products who uptake the               |
 | determining factors UI window by which the transaction lines are      |
 | already recorded into the eBTax repository , however the tax on them  |
 | is not calculated. They will pass p_data_transfer_mode as WIN         |
 * ======================================================================*/

  PROCEDURE calculate_tax
  ( p_api_version           IN         NUMBER,
    p_init_msg_list         IN         VARCHAR2,
    p_commit                IN         VARCHAR2,
    p_validation_level      IN         NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2 ,
    x_msg_count             OUT NOCOPY NUMBER ,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_transaction_rec       IN         transaction_rec_type,
    p_quote_flag            IN         VARCHAR2,
    p_data_transfer_mode    IN         VARCHAR2,
    x_doc_level_recalc_flag OUT NOCOPY VARCHAR2
   )
    IS

   l_api_name          CONSTANT  VARCHAR2(30) := 'CALCULATE_TAX';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_event_class_rec             event_class_rec_type;
   l_init_msg_list               VARCHAR2(1);
   l_record_tax_lines            VARCHAR2(1);
   l_error_buffer                VARCHAR2(1000);

   l_ptnr_index                       NUMBER;
   BEGIN
     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: CALCULATE_TAX()+');
     END IF;

    /*--------------------------------------------------+
    |   Standard start of API savepoint                 |
    +--------------------------------------------------*/
    SAVEPOINT Calculate_tax_PVT;

    /*--------------------------------------------------+
    |   Standard call to check for call compatibility   |
    +--------------------------------------------------*/

    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       )  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /*--------------------------------------------------------------+
    |   Initialize message list if p_init_msg_list is set to TRUE  |
    +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
       l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

    /*-----------------------------------------+
    |   Initialize return status to SUCCESS   |
    +-----------------------------------------*/

     x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*-----------------------------------------+
    |   Populate Global Variable              |
    +-----------------------------------------*/

     G_PUB_SRVC := l_api_name;
     G_PUB_CALLING_SRVC := l_api_name;
     G_DATA_TRANSFER_MODE := p_data_transfer_mode;
     G_EXTERNAL_API_CALL  := 'N';


     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
             'Data Transfer Mode: '||G_DATA_TRANSFER_MODE);
     END IF;

     --Call TDS process to reset the session for previous calculate tax calls if any
     ZX_TDS_CALC_SERVICES_PUB_PKG.initialize (p_event_class_rec => NULL,
                                              p_init_level      => 'SESSION',
                                              x_return_status   => l_return_status
                                             );
     set_ptnr_srvc_subscr_flag (p_event_class_rec => NULL,
                                x_return_status   => l_return_status
                               );

        ZX_GLOBAL_STRUCTURES_PKG.LOC_GEOGRAPHY_INFO_TBL.DELETE;
        ZX_GLOBAL_STRUCTURES_PKG.g_registration_info_tbl.DELETE;
     /*------------------------------------------------------+
      |   Copy to Event Class Record                         |
      +------------------------------------------------------*/

       /*Fetch the event id for the document*/
       select ZX_LINES_DET_FACTORS_S.nextval
         into l_event_class_rec.event_id
         from dual;

       /*Populate the event class record structure*/
       IF G_DATA_TRANSFER_MODE = 'PLS' THEN
         l_event_class_rec.INTERNAL_ORGANIZATION_ID     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID(1);
         l_event_class_rec.LEGAL_ENTITY_ID              :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEGAL_ENTITY_ID(1);
         l_event_class_rec.LEDGER_ID                    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEDGER_ID(1);
         l_event_class_rec.APPLICATION_ID               :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLICATION_ID(1);
         l_event_class_rec.ENTITY_CODE                  :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ENTITY_CODE(1);
         l_event_class_rec.EVENT_CLASS_CODE             :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_CLASS_CODE(1);
         l_event_class_rec.EVENT_TYPE_CODE              :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_TYPE_CODE(1);
         l_event_class_rec.CTRL_TOTAL_HDR_TX_AMT        :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CTRL_TOTAL_HDR_TX_AMT(1);
         l_event_class_rec.TRX_ID                       :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID(1);
         l_event_class_rec.TRX_DATE                     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DATE(1);
         l_event_class_rec.REL_DOC_DATE                 :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_DATE(1);
         l_event_class_rec.PROVNL_TAX_DETERMINATION_DATE:=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PROVNL_TAX_DETERMINATION_DATE(1);
         l_event_class_rec.TRX_CURRENCY_CODE            :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_CURRENCY_CODE(1);
         l_event_class_rec.PRECISION                    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRECISION(1);
         l_event_class_rec.CURRENCY_CONVERSION_TYPE     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_TYPE(1);
         l_event_class_rec.CURRENCY_CONVERSION_RATE     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_RATE(1);
         l_event_class_rec.CURRENCY_CONVERSION_DATE     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_DATE(1);
         l_event_class_rec.ROUNDING_SHIP_TO_PARTY_ID    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_SHIP_TO_PARTY_ID(1);
         l_event_class_rec.ROUNDING_SHIP_FROM_PARTY_ID  :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_SHIP_FROM_PARTY_ID(1);
         l_event_class_rec.ROUNDING_BILL_TO_PARTY_ID    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_BILL_TO_PARTY_ID(1);
         l_event_class_rec.ROUNDING_BILL_FROM_PARTY_ID  :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_BILL_FROM_PARTY_ID(1);
         l_event_class_rec.RNDG_SHIP_TO_PARTY_SITE_ID   :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_SHIP_TO_PARTY_SITE_ID(1);
         l_event_class_rec.RNDG_SHIP_FROM_PARTY_SITE_ID :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_SHIP_FROM_PARTY_SITE_ID(1);
         l_event_class_rec.RNDG_BILL_TO_PARTY_SITE_ID   :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_BILL_TO_PARTY_SITE_ID(1);
         l_event_class_rec.RNDG_BILL_FROM_PARTY_SITE_ID :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_BILL_FROM_PARTY_SITE_ID(1);
         l_event_class_rec.QUOTE_FLAG                   :=  nvl(p_quote_flag,'N');
         l_event_class_rec.ICX_SESSION_ID               :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ICX_SESSION_ID(1);
       ELSIF G_DATA_TRANSFER_MODE ='WIN' THEN
         l_event_class_rec.internal_organization_id     :=  p_transaction_rec.internal_organization_id;
         l_event_class_rec.APPLICATION_ID               :=  p_transaction_rec.application_id;
         l_event_class_rec.ENTITY_CODE                  :=  p_transaction_rec.entity_code;
         l_event_class_rec.EVENT_CLASS_CODE             :=  p_transaction_rec.event_class_code;
         l_event_class_rec.EVENT_TYPE_CODE              :=  p_transaction_rec.event_type_code;
         l_event_class_rec.TRX_ID                       :=  p_transaction_rec.trx_id;
         l_event_class_rec.QUOTE_FLAG                   :=  p_quote_flag;

         BEGIN
         SELECT legal_entity_id,
                ledger_id,
                trx_date,
                related_doc_date,
                trx_currency_code,
                precision,
                currency_conversion_type,
                currency_conversion_rate,
                currency_conversion_date,
                Rdng_ship_to_pty_tx_prof_id,
                Rdng_ship_from_pty_tx_prof_id,
                Rdng_bill_to_pty_tx_prof_id,
                Rdng_bill_from_pty_tx_prof_id,
                Rdng_ship_to_pty_tx_p_st_id,
                Rdng_ship_from_pty_tx_p_st_id,
                Rdng_bill_to_pty_tx_p_st_id,
                Rdng_bill_from_pty_tx_p_st_id
           INTO l_event_class_rec.legal_entity_id,
                l_event_class_rec.ledger_id,
                l_event_class_rec.trx_date,
                l_event_class_rec.rel_doc_date,
                l_event_class_rec.trx_currency_code,
                l_event_class_rec.precision,
                l_event_class_rec.currency_conversion_type,
                l_event_class_rec.currency_conversion_rate,
                l_event_class_rec.currency_conversion_date,
                l_event_class_rec.RDNG_SHIP_TO_PTY_TX_PROF_ID,
                l_event_class_rec.RDNG_SHIP_FROM_PTY_TX_PROF_ID,
                l_event_class_rec.RDNG_BILL_TO_PTY_TX_PROF_ID,
                l_event_class_rec.RDNG_BILL_FROM_PTY_TX_PROF_ID,
                l_event_class_rec.RDNG_SHIP_TO_PTY_TX_P_ST_ID,
                l_event_class_rec.RDNG_SHIP_FROM_PTY_TX_P_ST_ID,
                l_event_class_rec.RDNG_BILL_TO_PTY_TX_P_ST_ID,
                l_event_class_rec.RDNG_BILL_FROM_PTY_TX_P_ST_ID
           FROM ZX_LINES_DET_FACTORS
          WHERE application_id   = p_transaction_rec.application_id
            AND entity_code      = p_transaction_rec.entity_code
            AND event_class_code = p_transaction_rec.event_class_code
            AND trx_id           = p_transaction_rec.trx_id
            AND rownum           = 1;
         EXCEPTION
           WHEN OTHERS THEN
             IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'Data is expected to be in eBTax Repository for this call');
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;
       END IF;
       --Set a flag to indicate if currency information passed at header/line
       IF l_event_class_rec.trx_currency_code is not null AND
          l_event_class_rec.precision is not null THEN
          l_event_class_rec.header_level_currency_flag := 'Y';
       END IF;

       --Set the global variable if icx_session_id is not null
       IF l_event_class_rec.QUOTE_FLAG = 'Y' and
          l_event_class_rec.ICX_SESSION_ID is not null THEN
          ZX_SECURITY.G_ICX_SESSION_ID := l_event_class_rec.ICX_SESSION_ID;
          ZX_SECURITY.name_value('SESSIONID',to_char(ZX_SECURITY.G_ICX_SESSION_ID));
          -- dbms_session.set_context('my_ctx','SESSIONID',to_char(ZX_SECURITY.G_ICX_SESSION_ID));
       ELSE
          ZX_SECURITY.G_ICX_SESSION_ID := null;
          -- dbms_session.set_context('my_ctx','SESSIONID',to_char(ZX_SECURITY.G_ICX_SESSION_ID));
          ZX_SECURITY.name_value('SESSIONID',to_char(ZX_SECURITY.G_ICX_SESSION_ID));
       END IF;

    -- Bug 4948674: Following Delete will not work when there are different dbms sessions used for the same user
    -- session when call originates from a FWK UI. Moved the following Delete logic to the end of this API for O2C
    -- products and to the end of determine_recovery API for P2P products.

       --If the user calls calculate_tax twice using same db session for the same icx session, then we will have
       -- un-deleted data in the Det Factors table for the previousc all. So, we need to clean it up first before
       -- starting to process the input lines of the new call.We should at first always attempt to remove any rows
       --sitting in Det Factors table for that icx session
    /*   IF l_event_class_rec.ICX_SESSION_ID is not null THEN
          DELETE from zx_lines_det_factors
          WHERE application_id = l_event_class_rec.application_id and
                entity_code    = l_event_class_rec.entity_code and
                event_class_code = l_event_class_rec.event_class_code and
                trx_id = l_event_class_rec.trx_id;
       END IF;
    */

       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
             'application_id: '||to_char(l_event_class_rec.application_id)||
             ', entity_code: '||l_event_class_rec.entity_code||
             ', event_class_code: '||l_event_class_rec.event_class_code||
             ', event_type_code: '||l_event_class_rec.event_type_code||
             ', trx_id: '||to_char(l_event_class_rec.trx_id)||
             ', internal_organization_id: '||to_char(l_event_class_rec.internal_organization_id)||
             ', ledger_id: '||to_char(l_event_class_rec.ledger_id)||
             ', legal_entity_id: '||to_char(l_event_class_rec.legal_entity_id)||
             ', trx_date: '||to_char(l_event_class_rec.trx_date)||
             ', related_document_date: '||to_char(l_event_class_rec.rel_doc_date)||
             ', trx_currency_code: '||l_event_class_rec.trx_currency_code||
             ', currency_conversion_type: '||l_event_class_rec.currency_conversion_type||
             ', currency_conversion_rate: '||to_char(l_event_class_rec.currency_conversion_rate)||
             ', currency_conversion_date: '||to_char(l_event_class_rec.currency_conversion_date)||
             ', rounding_ship_to_party_id: '||to_char(l_event_class_rec.rounding_ship_to_party_id)||
             ', rounding_ship_from_party_id: '||to_char(l_event_class_rec.rounding_ship_from_party_id)||
             ', rounding_bill_to_party_id: '||to_char(l_event_class_rec.rounding_bill_to_party_id)||
             ', rounding_bill_from_party_id: '||to_char(l_event_class_rec.rounding_bill_from_party_id)||
             ', rndg_ship_to_party_site_id: '||to_char(l_event_class_rec.rndg_ship_to_party_site_id)||
             ', rndg_ship_from_party_site_id: '||to_char(l_event_class_rec.rndg_ship_from_party_site_id)||
             ', rndg_bill_to_party_site_id: '||to_char(l_event_class_rec.rndg_bill_to_party_site_id)||
             ', rndg_bill_from_party_site_id: '||to_char(l_event_class_rec.rndg_bill_from_party_site_id)||
             ', quote_flag: '||l_event_class_rec.quote_flag ||
             ', icx_session_id: '||to_char(l_event_class_rec.icx_session_id) );
       END IF;

       /*-------------------------------------------------------+
       |Lock the tax lines table to prevent another             |
       |user from updating same line via the forms/UIs while    |
       |calculation is in progress                              |
       +-------------------------------------------------------*/
       IF l_event_class_rec.tax_event_type_code ='UPDATE' THEN
         ZX_TRL_DETAIL_OVERRIDE_PKG.lock_dtl_tax_lines_for_doc(p_application_id      => l_event_class_rec.application_id,
                                                               p_entity_code         => l_event_class_rec.entity_code,
                                                               p_event_class_code    => l_event_class_rec.event_class_code,
                                                               p_trx_id              => l_event_class_rec.trx_id,
                                                               x_return_status       => l_return_status,
                                                               x_error_buffer        => l_error_buffer
                                                               );

         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         ZX_TRL_SUMMARY_OVERRIDE_PKG.lock_summ_tax_lines_for_doc(p_application_id      => l_event_class_rec.application_id,
                                                                 p_entity_code         => l_event_class_rec.entity_code,
                                                                 p_event_class_code    => l_event_class_rec.event_class_code,
                                                                 p_trx_id              => l_event_class_rec.trx_id,
                                                                 x_return_status       => l_return_status,
                                                                 x_error_buffer        => l_error_buffer
                                                                 );
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         ZX_TRL_DISTRIBUTIONS_PKG.lock_rec_nrec_dist_for_doc (p_application_id      => l_event_class_rec.application_id,
                                                              p_entity_code         => l_event_class_rec.entity_code,
                                                              p_event_class_code    => l_event_class_rec.event_class_code,
                                                              p_trx_id              => l_event_class_rec.trx_id,
                                                              x_return_status       => l_return_status,
                                                              x_error_buffer        => l_error_buffer
                                                              );
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
       END IF; --tax event type is UPDATE

       IF l_event_class_rec.event_class_code = 'CREDIT_MEMO' THEN
         ZX_GLOBAL_STRUCTURES_PKG.g_credit_memo_exists_flg := 'Y';
       END IF;

       /*------------------------------------------------------+
       |   Validate and Initializate parameters for Calculate |
       |   tax                                                |
       +------------------------------------------------------*/

         ZX_VALID_INIT_PARAMS_PKG.calculate_tax(p_event_class_rec => l_event_class_rec,
                                                x_return_status   => l_return_status
                                               );

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_VALID_INIT_PARAMS_PKG.calculate_tax returned errors');
            END IF;
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

        /* ===============================================================================*
        |Initialize the global structures/global temp tables owned by TDM at header level |
        * ===============================================================================*/

         ZX_TDS_CALC_SERVICES_PUB_PKG.initialize (l_event_class_rec ,
                                                  'HEADER',
                                                  l_return_status
                                                 );

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TDS_CALC_SERVICES_PUB_PKG.initialize returned errors');
            END IF;
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;


         /*--------------------------------------------------+
          |   Call to service type Calculate Tax             |
          +--------------------------------------------------*/
          /* ----------------------------------------------------+
           | Bug 3922920 - Perfrom tail end processes regardless |
           | of process_for_applicability_flag                   |
           + ---------------------------------------------------*/
          --IF nvl(l_event_class_rec.PROCESS_FOR_APPLICABILITY_FLAG,'Y') = 'Y' THEN

            ZX_SRVC_TYP_PKG.calculate_tax(p_event_class_rec    => l_event_class_rec,
                                          x_return_status      => l_return_status
                                         );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_SRVC_TYP_PKG.calculate_tax  returned errors');
              END IF;
              IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
              ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            END IF;

            -- populate the tax_regime_tbl cache structure for partner
            IF zx_global_structures_pkg.g_ptnr_srvc_subscr_flag = 'Y' THEN
	     IF nvl(ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl.FIRST,0) = 0 THEN
              l_ptnr_index := NVL(ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl.LAST, 0) + 1;
              ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_ptnr_index).application_id
                        := l_event_class_rec.application_id;
              ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_ptnr_index).entity_code
                        := l_event_class_rec.entity_code;
              ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_ptnr_index).event_class_code
                        := l_event_class_rec.event_class_code;
              ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_ptnr_index).trx_id
                        := l_event_class_rec.trx_id;
               ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_ptnr_index).event_class_mapping_id
                        := l_event_class_rec.event_class_mapping_id;
               ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_ptnr_index).event_type_code
                        := l_event_class_rec.event_type_code;
               ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_ptnr_index).record_flag
                        := l_event_class_rec.record_flag;
               ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_ptnr_index).quote_flag
                        := l_event_class_rec.quote_flag;
               ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_ptnr_index).record_for_partners_flag
                        := l_event_class_rec.record_for_partners_flag;
               ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_ptnr_index).prod_family_grp_code
                        := l_event_class_rec.prod_family_grp_code;
               ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_ptnr_index).internal_organization_id
                         := l_event_class_rec.internal_organization_id;
               ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_ptnr_index).legal_entity_id
                         := l_event_class_rec.legal_entity_id;
               ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_ptnr_index).effective_date
                        := zx_security.g_effective_date;
              ZX_GLOBAL_STRUCTURES_PKG.ptnr_tax_regime_tbl(l_ptnr_index).tax_regime_tbl
                        := ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl;
	     END IF;
            END IF;

           /*-----------------------------------------------------+
            |   Call to eTax service Dump Detail Tax Lines Into GT|
            +-----------------------------------------------------*/
           ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt(x_return_status  => l_return_status);


           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt returned errors');
              END IF;
              IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
              ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            END IF;

           /*--------------------------------------------------+
            |   Call to eTax Service Tax Lines Determination   |
            +--------------------------------------------------*/
            ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination(p_event_class_rec => l_event_class_rec,
                                                                x_return_status   => l_return_status
                                                               );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination returned errors');
              END IF;
              IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
              ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            END IF;

            /*--------------------------------------------------+
             |   Call to Update Total Inclusive Tax Amount      |
             +--------------------------------------------------*/
            /* Replace the call to update_total_inc_tax_amt with the merge statement below
            update_total_inc_tax_amt(p_event_class_rec => l_event_class_rec,
                                     x_return_status   => l_return_status
	                            );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              x_return_status := l_return_status ;
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':update_total_inc_tax_amt returned errors');
              END IF;
                 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
                 ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
            END IF;
            */

            IF zx_global_structures_pkg.g_event_class_rec.prod_family_grp_code = 'P2P' THEN
              MERGE INTO  ZX_LINES_DET_FACTORS     lines_dt
              USING (SELECT
                           application_id,
                           entity_code,
                           event_class_code,
                           trx_id,
                           trx_level_type,
                           trx_line_id,
                           sum(tax_amt)   incl_tax_amt
                     FROM
                          zx_detail_tax_lines_gt TaxLines
                     WHERE
                           tax_amt_included_flag = 'Y'
                 --    AND mrc_tax_line_flag = 'N'
     	               AND cancel_flag <> 'Y'
                 GROUP BY
                           application_id,
                           entity_code,
                           event_class_code,
                           trx_id,
                           trx_level_type,
                           trx_line_id
                   ) Temp
               ON  (      lines_dt.tax_amt_included_flag = 'Y'
                     --AND  lines_dt.total_inc_tax_amt is NULL
                     AND  lines_dt.application_id   = temp.application_id
                     AND  lines_dt.entity_code      = temp.entity_code
                     AND  lines_dt.event_class_code = temp.event_class_code
                     AND  lines_dt.trx_id           = temp.trx_id
                     AND  Lines_dt.trx_level_type   = temp.trx_level_type
                     AND  Lines_dt.trx_line_id      = temp.trx_line_id
                    )
               WHEN MATCHED THEN
                 UPDATE SET
                        total_inc_tax_amt   = incl_tax_amt;

            END IF;

           /*--------------------------------------------------+
            |   Call to eTax Service Manage Tax Lines          |
            +--------------------------------------------------*/

            --Rounding and Summarizing Tax Lines for Transaction
            /*Bug 3649502 - Check for record flag before calling TRR service*/
            /*Bug 4232918 - If record flag =Y and quote flag =Y then do not
                            record in zx_lines */
            l_record_tax_lines := l_event_class_rec.record_flag;
            IF l_event_class_rec.record_flag = 'Y' and
               l_event_class_rec.quote_flag = 'Y' THEN
               l_record_tax_lines := 'N';
            END IF;
            IF l_record_tax_lines = 'Y' THEN
              ZX_TRL_PUB_PKG.manage_taxlines(p_event_class_rec  =>l_event_class_rec,
                                             x_return_status    =>l_return_status
                                            );
            END IF;

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TRL_PUB_PKG.manage_taxlines returned errors');
              END IF;
              IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
              ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            END IF;
        --  END IF; -- process_applicability_flag is N

   	    /*******************************PARTNER CODE START****************************/
            IF zx_global_structures_pkg.g_ptnr_srvc_subscr_flag = 'Y' THEN

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                   'Calling partner routine to synchronize the tax'||
                   ', ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl.count = '||ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl.count);
              END IF;
              ptnr_bulk_sync_calc_tax ( p_event_class_rec   => l_event_class_rec ,
                                   x_return_status     => l_return_status
                                 );
              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TRL_PUB_PKG.manage_taxlines returned errors');
                END IF;
                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
              END IF;
            END IF;
   	    /*******************************PARTNER CODE END****************************/
        /*---------------------------------------------------------+
         | End Loop for Transaction Headers                        |
         +---------------------------------------------------------*/

       /*---------------------------------------------------------+
        | Set the out parameter                                   |
        +--------------------------------------------------------*/
         BEGIN
            SELECT threshold_indicator_flag
              INTO  x_doc_level_recalc_flag
              FROM  ZX_LINES_DET_FACTORS
              WHERE application_id           = l_event_class_rec.application_id
                AND event_class_code         = l_event_class_rec.event_class_code
                AND entity_code              = l_event_class_rec.entity_code
                AND trx_id                   = l_event_class_rec.trx_id
                AND threshold_indicator_flag = 'Y'                 -- Bug 5210984
                AND rownum                   = 1;
         EXCEPTION WHEN OTHERS THEN
                x_doc_level_recalc_flag := 'N'; --bug6062224
		--null;
         END;

       /*-------------------------------------------------------------+
        | Do not record lines based on following condition            |
        +------------------------------------------------------------*/
         IF (l_event_class_rec.RECORD_FLAG = 'Y' and
             l_event_class_rec.quote_flag = 'Y' and
             l_event_class_rec.icx_session_id is null) OR
            (l_event_class_rec.RECORD_FLAG = 'N' and
             l_event_class_rec.quote_flag = 'Y' and
             l_event_class_rec.intgrtn_det_factors_ui_flag = 'N' and
             l_event_class_rec.icx_session_id is null) THEN
            --Delete lines for transaction header which need not be recorded
            DELETE from zx_lines_det_factors
             WHERE application_id = l_event_class_rec.application_id
               AND entity_code    = l_event_class_rec.entity_code
               AND event_class_code = l_event_class_rec.event_class_code
               AND trx_id = l_event_class_rec.trx_id;
        END IF;
        /*----------------------------------------------------------------+
        | Set the tax_reporting_flag to 'N' for documents called for quote|
        +----------------------------------------------------------------*/
-- Bug Fix for 5155481 - Commented out the following update. Reporting flag is set during the
-- insert itself based on the record_flag.

/*        IF l_event_class_rec.QUOTE_FLAG = 'Y' THEN
	     UPDATE zx_lines_det_factors
	        SET tax_reporting_flag ='N'
              WHERE application_id   = l_event_class_rec.application_id
	        AND entity_code      = l_event_class_rec.entity_code
	        AND event_class_code = l_event_class_rec.event_class_code
	        AND trx_id           = l_event_class_rec.trx_id;
        END IF;

*/

        /*-----------------------------------------------------+
         |  Handle delete for mark tax lines deleted           |
         +-----------------------------------------------------*/
        DELETE FROM ZX_LINES_DET_FACTORS
    	   WHERE line_level_action ='DELETE'
             AND application_id   = l_event_class_rec.application_id
             AND entity_code      = l_event_class_rec.entity_code
             AND event_class_code = l_event_class_rec.event_class_code
             AND trx_id           = l_event_class_rec.trx_id;

        /*------------------------------------------------------------------------------+
         |  Bug 4948674: Handle delete for O2C products when icx_session_id is NOT NULL |
         +------------------------------------------------------------------------------*/
        IF  l_event_class_rec.ICX_SESSION_ID is not null AND
            l_event_class_rec.PROD_FAMILY_GRP_CODE = 'O2C' THEN
           DELETE from zx_lines_det_factors
             WHERE application_id   = l_event_class_rec.application_id and
                   entity_code      = l_event_class_rec.entity_code and
                   event_class_code = l_event_class_rec.event_class_code and
                   trx_id           = l_event_class_rec.trx_id and
                   icx_session_id   = l_event_class_rec.icx_session_id;
        END IF;

        /*---------------------------------------------------------+
         |  Initialize the trx line app regimes table for every doc|
         +--------------------------------------------------------*/
        IF zx_global_structures_pkg.g_ptnr_srvc_subscr_flag = 'Y' THEN
           ZX_GLOBAL_STRUCTURES_PKG.init_trx_line_app_regime_tbl;
        END IF;

        --Delete from the global structures so that there are no hanging/redundant
        --records sitting there
        ZX_GLOBAL_STRUCTURES_PKG.delete_trx_line_dist_tbl;
        ZX_GLOBAL_STRUCTURES_PKG.LOC_GEOGRAPHY_INFO_TBL.DELETE;
        ZX_GLOBAL_STRUCTURES_PKG.g_registration_info_tbl.DELETE;
        ZX_GLOBAL_STRUCTURES_PKG.g_party_tax_prof_id_info_tbl.DELETE;

        --Also delete the location caching global structures
	      ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.EVENT_CLASS_MAPPING_ID.DELETE;
        ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.TRX_ID.DELETE;
        ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.TRX_LINE_ID.DELETE;
	      ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.TRX_LEVEL_TYPE.DELETE;
	      ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.LOCATION_TYPE.DELETE;
        ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.LOCATION_TABLE_NAME.DELETE;
        ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.LOCATION_ID.DELETE;
        ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.GEOGRAPHY_TYPE.DELETE;
        ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.GEOGRAPHY_VALUE.DELETE;
        ZX_GLOBAL_STRUCTURES_PKG.location_info_tbl.GEOGRAPHY_ID.DELETE;
        ZX_GLOBAL_STRUCTURES_PKG.LOCATION_HASH_TBL.DELETE;

        --Reset the icx_session_id at end of API
        ZX_SECURITY.G_ICX_SESSION_ID := null;
        ZX_SECURITY.name_value('SESSIONID',to_char(ZX_SECURITY.G_ICX_SESSION_ID));
        -- dbms_session.set_context('my_ctx','SESSIONID',to_char(ZX_SECURITY.G_ICX_SESSION_ID));

        --Reset the calling API info at end of API
        ZX_API_PUB.G_PUB_CALLING_SRVC := null;

        IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: CALCULATE_TAX()-');
        END IF;

        EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Calculate_tax_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            DUMP_MSG;
           /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count  =>      x_msg_count,
                                      p_data   =>      x_msg_data
                                      );

             IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
             END IF;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Calculate_tax_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            DUMP_MSG;
            FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
            FND_MSG_PUB.Add;
          /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count   =>      x_msg_count,
                                      p_data    =>      x_msg_data
                                      );
            IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
            END IF;

          WHEN OTHERS THEN
             ROLLBACK TO Calculate_tax_PVT;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
             FND_MSG_PUB.Add;
           /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
             FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                       p_count  =>      x_msg_count,
                                       p_data   =>      x_msg_data
                                       );

             IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
             END IF;

   END calculate_tax; --pl/sql version

/* ======================================================================*
 | PROCEDURE import_document_with_tax : Imports document with tax        |
 | This API also supports processing for multiple event classes          |
 | GTT involved : ZX_TRX_HEADERS_GT, ZX_TRANSACTION_LINES_GT ,           |
 |                ZX_IMPORT_TAX_LINES_GT and ZX_TRX_TAX_LINK_GT          |
 * ======================================================================*/
  PROCEDURE Import_document_with_tax
  ( p_api_version           IN         NUMBER,
    p_init_msg_list         IN         VARCHAR2,
    p_commit                IN         VARCHAR2,
    p_validation_level      IN         NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2 ,
    x_msg_count             OUT NOCOPY NUMBER ,
    x_msg_data              OUT NOCOPY VARCHAR2
  ) IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'IMPORT_DOCUMENT_WITH_TAX';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_context_info_rec            context_info_rec_type;
   l_transaction_header_rec      transaction_header_rec_type;
   l_event_id                    NUMBER;
   l_precedence                  NUMBER_tbl_type;
   l_index                       BINARY_INTEGER;
   l_init_msg_list               VARCHAR2(1);
   l_record_tax_lines            VARCHAR2(1);


    CURSOR event_classes IS
     SELECT distinct
            header.event_class_code,
            header.application_id,
            header.entity_code,
            header.internal_organization_id,
            evntmap.processing_precedence
       FROM ZX_EVNT_CLS_MAPPINGS evntmap,
            ZX_TRX_HEADERS_GT header
      WHERE header.application_id = evntmap.application_id
        AND header.entity_code = evntmap.entity_code
        AND header.event_class_code = evntmap.event_class_code
      ORDER BY evntmap.processing_precedence;

      /*Get all the tax lines passed in import process for external tax provider */
      CURSOR detail_tax_lines_csr IS
      SELECT distinct
             r.tax_regime_id,
             t.tax_regime_code,
             t.tax_provider_id,
             r.effective_from,
             r.effective_to
        FROM ZX_IMPORT_TAX_LINES_GT t, zx_regimes_b r
        WHERE t.tax_provider_id is not null
          AND r.tax_regime_code = t.tax_regime_code
          AND r.effective_to is null;

     dtl_tax_lines  detail_tax_lines_csr%ROWTYPE;
     l_ptnr_index        NUMBER;
 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

   /*--------------------------------------------------+
    |   Standard start of API savepoint                |
    +--------------------------------------------------*/
    SAVEPOINT import_document_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
	   l_init_msg_list := p_init_msg_list;
	 END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;


    /*-----------------------------------------+
     |   Initialize return status to SUCCESS   |
     +-----------------------------------------*/
     x_return_status := FND_API.G_RET_STS_SUCCESS;


    /*-----------------------------------------+
     |   Populate Global Variable              |
     +-----------------------------------------*/
     G_PUB_SRVC := l_api_name;
     G_DATA_TRANSFER_MODE := 'TAB';
     G_EXTERNAL_API_CALL  := 'N';

     /*-----------------------------------------+
     | Get the event id for the whole document |
     +-----------------------------------------*/
     --Bug 7650433
     --select ZX_LINES_DET_FACTORS_S.nextval
     --into l_event_id
     --from dual;

     OPEN event_classes;
       LOOP
        FETCH event_classes BULK COLLECT INTO
          l_evnt_cls.event_class_code,
          l_evnt_cls.application_id,
          l_evnt_cls.entity_code,
          l_evnt_cls.internal_organization_id,
          l_evnt_cls.precedence
        LIMIT G_LINES_PER_FETCH;
        EXIT WHEN event_classes%NOTFOUND;
       END LOOP;
     CLOSE event_classes;

     --Event classes such as SALES_TRANSACTION_TAX_QUOTE/PURCHASE_TRANSACTION_TAX_QUOTE
     --are not seeded in zx_evnt_cls_mappings so cursor event classes will not
     --return any rows for such event classes passed.
     IF l_evnt_cls.event_class_code.LAST is null THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
             'Event class information does not exist - indicates SALES_TRANSACTION_TAX_QUOTE/PURCHASE_TRANSACTION_TAX_QUOTE');
       END IF;

       select event_class_code,
              application_id,
              entity_code,
              internal_organization_id
         into l_evnt_cls.event_class_code(1),
              l_evnt_cls.application_id(1),
              l_evnt_cls.entity_code(1),
              l_evnt_cls.internal_organization_id(1)
         from ZX_TRX_HEADERS_GT
         where rownum=1;
     END IF;


     -- added init for bug fix 5417887
     /* ===============================================================================*
     |Initialize the global structures/global temp tables owned by TDM at header level |
      * =============================================================================*/
     ZX_TDS_CALC_SERVICES_PUB_PKG.initialize (p_event_class_rec => NULL,
                                              p_init_level      => 'SESSION',
                                              x_return_status   => l_return_status
                                             );

     set_ptnr_srvc_subscr_flag (p_event_class_rec => NULL,
                                x_return_status   => l_return_status
                               );

      /*---------------------------------------------------------+
      |  Initialize the trx line app regimes table for every doc|
      +--------------------------------------------------------*/

      IF zx_global_structures_pkg.g_ptnr_srvc_subscr_flag = 'Y' THEN

         -- Partner code, Point 2 (add a logic to conditionall execute this loop only
         -- when partner is installed
         -- IF p_event_class_rec.record_flag = 'Y' AND
         --   p_event_class_rec.record_for_partners_flag = 'Y' THEN
         /*Dump into tax regime table only after existence check */

         FOR dtl_tax_lines in detail_tax_lines_csr LOOP
             IF NOT ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl.EXISTS(dtl_tax_lines.tax_regime_id) THEN
                ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(dtl_tax_lines.tax_regime_id).tax_regime_id :=  dtl_tax_lines.tax_regime_id;
                ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(dtl_tax_lines.tax_regime_id).tax_regime_code:=  dtl_tax_lines.tax_regime_code;
                ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(dtl_tax_lines.tax_regime_id).tax_provider_id :=  dtl_tax_lines.tax_provider_id;
/* Bug 5557565 */
                ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(dtl_tax_lines.tax_regime_id).effective_from := dtl_tax_lines.effective_from;
                ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(dtl_tax_lines.tax_regime_id).effective_to := dtl_tax_lines.effective_to;
                ZX_GLOBAL_STRUCTURES_PKG.tax_regime_tbl(dtl_tax_lines.tax_regime_id).partner_processing_flag :=  'C';
             END IF;
         END LOOP;
         --END IF;

         ZX_GLOBAL_STRUCTURES_PKG.init_trx_line_app_regime_tbl;
      END IF;

        ZX_GLOBAL_STRUCTURES_PKG.LOC_GEOGRAPHY_INFO_TBL.DELETE;
        ZX_GLOBAL_STRUCTURES_PKG.g_registration_info_tbl.DELETE;
        ZX_GLOBAL_STRUCTURES_PKG.tax_calc_flag_tbl.DELETE;
     /*-----------------------------------------+
      |   Loop for each transaction header      |
      +-----------------------------------------*/
     FOR i IN 1..nvl(l_evnt_cls.event_class_code.LAST,0)
       LOOP
         --Bug 7650433
         select ZX_LINES_DET_FACTORS_S.nextval
          into l_event_id
         from dual;
         -- added for bug fix 5417887
         IF l_evnt_cls.event_class_code(i) = 'CREDIT_MEMO' THEN
           ZX_GLOBAL_STRUCTURES_PKG.g_credit_memo_exists_flg := 'Y';
         END IF;

           BEGIN
               --SAVEPOINT Import_Doc_Rel_PVT;
               import_tax_pvt (l_evnt_cls,
                               l_api_name,
                               l_event_id,
                               i,
                               p_api_version,
                               l_init_msg_list,
                               p_commit,
                               p_validation_level,
                               l_return_status,
                               x_msg_count,
                               x_msg_data
                              );

               IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

               EXCEPTION
                 WHEN FND_API.G_EXC_ERROR THEN
                   --ROLLBACK TO Import_Doc_Rel_PVT;
                   x_return_status := FND_API.G_RET_STS_ERROR ;
                   --Call API to dump into zx_errors_gt
                   IF ( errors_tbl.application_id.LAST is NOT NULL) THEN
                     DUMP_MSG;
                   END IF;
                   IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
                   END IF;
               END;


     -- bug fix 5417887 begin 17-Aug-2006
     -- Following code for tail end services/TRL/ptnr sync code, is moved from calculte_tax_pvt
     -- and should be handled for each event_class_code. At present, all product integrations call etax
     -- for one event class at a time, hence we put these processed out of the event class loop.
     -- In the future, if there are cases that etax handle multiple event_class batch, we need to
     -- revisist the following code and change accordingly.

     -- For furture LTE features, there are could cases that related documents was imported together
     -- with original document. For this case, we need to make sure the tail end service for the original
     -- docs must be handled before the calculation process of the related docs.

      /*-----------------------------------------------------+
       |   Call to eTax service Dump Detail Tax Lines Into GT|
       +-----------------------------------------------------*/
       ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt(x_return_status  => l_return_status );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status ;
          --DUMP_MSG;
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt returned errors');
          END IF;
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

        /*--------------------------------------------------+
         |   Call to eTax Service Tax Lines Determination   |
         +--------------------------------------------------*/
         ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination(
                              p_event_class_rec => zx_global_structures_pkg.g_event_class_rec,
                              x_return_status   => l_return_status
                                                            );

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            --DUMP_MSG;
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination returned errors');
            END IF;
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END IF;

         /*--------------------------------------------------+
          |   Call to eTax Service Manage Tax Lines          |
          +--------------------------------------------------*/
          /*Bug 3649502 - Check for record flag before calling TRR service*/
         --IF zx_global_structures_pkg.g_event_class_rec.record_flag = 'Y' THEN
         l_record_tax_lines := ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.record_flag;
         IF ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.record_flag = 'Y' and
            ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.quote_flag = 'Y' THEN
            l_record_tax_lines := 'N';
         END IF;
         IF l_record_tax_lines = 'Y' THEN
            ZX_TRL_PUB_PKG.manage_taxlines(p_event_class_rec  =>zx_global_structures_pkg.g_event_class_rec,
                                           x_return_status    =>l_return_status
                                          );
         END IF;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            --DUMP_MSG;
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TRL_PUB_PKG.manage_taxlines returned errors');
            END IF;
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

     -- bug#6389189
     -- need to flush ZX_DETAIL_TAX_LINES_GT before the procedure
     -- import_tax_pvt is called for the next event class

     -- Bug fix 7506576 Included additional condition flag quote_flag when
     -- deleting records from GT TABLES

     --IF zx_global_structures_pkg.g_event_class_rec.record_flag = 'Y'  AND ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.quote_flag = 'N'
     -- Reimplemented the fix done in bug#7506576
     IF l_record_tax_lines = 'Y' THEN
       DELETE FROM ZX_DETAIL_TAX_LINES_GT;
     END IF;


    /*******************************PARTNER CODE START****************************/
     IF zx_global_structures_pkg.g_ptnr_srvc_subscr_flag = 'Y' THEN
       ptnr_bulk_sync_calc_tax ( p_event_class_rec   => zx_global_structures_pkg.g_event_class_rec ,
                                 x_return_status     => l_return_status
                               );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         --DUMP_MSG;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ptnr_bulk_sync_calc_tax returned errors');
         END IF;
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;
     END IF;
    /*******************************PARTNER CODE END****************************/

     -- bug fix 6824850
     ZX_GLOBAL_STRUCTURES_PKG.PTNR_TAX_REGIME_TBL.DELETE;
     ZX_GLOBAL_STRUCTURES_PKG.lte_trx_tbl.DELETE;

     -- bug fix 5417887 end 17-Aug-2006
     END LOOP;--event_classes cursor


      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
      END IF;

        EXCEPTION
           WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Import_Document_PVT;
            --Close all open cursors
            x_return_status := FND_API.G_RET_STS_ERROR;
            DUMP_MSG;
            IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
            END IF;

           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Import_Document_PVT;
            --Close all open cursors
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            DUMP_MSG;
            FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
            FND_MSG_PUB.Add;
           /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count   =>      x_msg_count,
                                      p_data    =>      x_msg_data
                                      );
            IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
            END IF;

          WHEN OTHERS THEN
             ROLLBACK TO Import_Document_PVT;
             --Close all open cursors
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
             FND_MSG_PUB.Add;
           /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
             FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                       p_count  =>      x_msg_count,
                                       p_data   =>      x_msg_data
                                       );

             IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
             END IF;
 END import_document_with_tax;

 /* ======================================================================*
 | PROCEDURE synchronize_tax_repository : Updates tax repository         |
 | There exists only pl/sql version for API                              |
 * ======================================================================*/

 PROCEDURE synchronize_tax_repository
 (  p_api_version           IN         NUMBER,
    p_init_msg_list         IN         VARCHAR2,
    p_commit                IN         VARCHAR2,
    p_validation_level      IN         NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_sync_trx_rec          IN         sync_trx_rec_type,
    p_sync_trx_lines_tbl    IN         sync_trx_lines_tbl_type%type
  ) IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'SYNCHRONIZE_TAX_REPOSITORY';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_index                       BINARY_INTEGER;
   l_event_id                    NUMBER;
   l_event_class_rec             event_class_rec_type;
   l_init_msg_list               VARCHAR2(1);
   l_upg_trx_info_rec            ZX_ON_FLY_TRX_UPGRADE_PKG.zx_upg_trx_info_rec_type;
 BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

   /*--------------------------------------------------+
    |   Standard start of API savepoint                |
    +--------------------------------------------------*/
    SAVEPOINT Synchronize_tax_PVT;

    /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/

    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                      ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   /*--------------------------------------------------------------+
   |   Initialize message list if p_init_msg_list is set to TRUE  |
   +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
	   l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

   /*-----------------------------------------+
    |   Initialize return status to SUCCESS   |
    +-----------------------------------------*/

    x_return_status := FND_API.G_RET_STS_SUCCESS;

   /*-----------------------------------------+
    |   Populate Global Variable              |
    +-----------------------------------------*/

    G_PUB_SRVC := l_api_name;
    G_DATA_TRANSFER_MODE := 'PLS';
    G_EXTERNAL_API_CALL  := 'N';

   /*------------------------------------------+
     |Populate the event class record          |
     +-----------------------------------------*/
     l_event_class_rec.APPLICATION_ID              :=  p_sync_trx_rec.APPLICATION_ID;
     l_event_class_rec.ENTITY_CODE                 :=  p_sync_trx_rec.ENTITY_CODE;
     l_event_class_rec.EVENT_CLASS_CODE            :=  p_sync_trx_rec.EVENT_CLASS_CODE;
     l_event_class_rec.EVENT_TYPE_CODE             :=  p_sync_trx_rec.EVENT_TYPE_CODE;
     l_event_class_rec.TRX_ID                      :=  p_sync_trx_rec.TRX_ID;
     l_event_class_rec.record_flag                 := 'Y';
     l_event_class_rec.record_for_partners_flag    := 'Y';

     BEGIN

       SELECT prod_family_grp_code into l_event_class_rec.prod_family_grp_code
       FROM
       zx_evnt_cls_mappings
       WHERE
       application_id = p_sync_trx_rec.application_id
       AND entity_code = p_sync_trx_rec.entity_code
       AND event_class_code = p_sync_trx_rec.event_class_code;

     EXCEPTION
       WHEN OTHERS THEN
        --NULL;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Incorrect event_class_code passed: ' || p_sync_trx_rec.event_class_code);
        END IF;
        RETURN;
     END;



     BEGIN

       SELECT tax_event_type_code into l_event_class_rec.tax_event_type_code
       FROM
       ZX_EVNT_TYP_MAPPINGS
       WHERE
       application_id = p_sync_trx_rec.application_id
       AND entity_code = p_sync_trx_rec.entity_code
       AND event_class_code = p_sync_trx_rec.event_class_code
       AND event_type_code = p_sync_trx_rec.event_type_code;

     EXCEPTION
       WHEN OTHERS THEN
        --NULL;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Incorrect event_type_code passed: ' || p_sync_trx_rec.event_type_code);
        END IF;
        RETURN;
     END;

     BEGIN

       SELECT distinct internal_organization_id into
       l_event_class_rec.internal_organization_id
       FROM
       zx_lines_det_factors
       WHERE
       application_id = p_sync_trx_rec.application_id
       AND entity_code = p_sync_trx_rec.entity_code
       AND event_class_code = p_sync_trx_rec.event_class_code
       AND trx_id = p_sync_trx_rec.trx_id;

     EXCEPTION
       WHEN OTHERS THEN
        NULL;
     END;

    /*--------------------------------------------------+
     |   Update zx_lines_det_factors                    |
     +--------------------------------------------------*/
     /*Retrieve the sequence id since it has to be same for all updated rows*/
     select ZX_LINES_DET_FACTORS_S.nextval
       INTO l_event_class_rec.event_id
       FROM dual;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
             'application_id: '||to_char(p_sync_trx_rec.application_id)||
             ', entity_code: '||p_sync_trx_rec.entity_code||
             ', event_class_code: '||p_sync_trx_rec.event_class_code||
             ', event_type_code: '||p_sync_trx_rec.event_type_code||
             ', tax_event_type_code: '||l_event_class_rec.tax_event_type_code||
             ', trx_id: '||to_char(p_sync_trx_rec.trx_id)||
             ', trx_number: '||p_sync_trx_rec.trx_number||
             ', trx_description: '||p_sync_trx_rec.trx_description||
             ', trx_communicated_date: '||to_char(p_sync_trx_rec.trx_communicated_date)||
             ', batch_source_id: '||to_char(p_sync_trx_rec.batch_source_id)||
             ', batch_source_name: '||p_sync_trx_rec.batch_source_name||
             ', doc_seq_id: '||to_char(p_sync_trx_rec.doc_seq_id)||
             ', doc_seq_name: '||p_sync_trx_rec.doc_seq_name||
             ', doc_seq_name: '||p_sync_trx_rec.doc_seq_value||
             ', trx_due_date: '||to_char(p_sync_trx_rec.trx_due_date)||
             ', trx_type_description: '||to_char(p_sync_trx_rec.trx_type_description)||
             ', supplier_tax_invoice_number: '||p_sync_trx_rec.supplier_tax_invoice_number||
             ', supplier_exchange_rate: '||to_char(p_sync_trx_rec.supplier_exchange_rate)||
             ', supplier_tax_invoice_date: '||to_char(p_sync_trx_rec.supplier_tax_invoice_date)||
             ', tax_invoice_date: '||to_char(p_sync_trx_rec.tax_invoice_date)||
             ', tax_invoice_number: '||p_sync_trx_rec.tax_invoice_number||
             ', port_of_entry_code: '||p_sync_trx_rec.port_of_entry_code);

        FOR i IN 1..nvl(p_sync_trx_lines_tbl.APPLICATION_ID.LAST,-99)
        LOOP
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
             'trx_line_id: '||to_char(p_sync_trx_lines_tbl.trx_line_id(i))||
             ', trx_level_type: '||p_sync_trx_lines_tbl.trx_level_type(i)||
             ', trx_waybill_number: '||p_sync_trx_lines_tbl.trx_waybill_number(i)||
             ', trx_line_description: '||p_sync_trx_lines_tbl.trx_line_description(i)||
             ', product_description: '||p_sync_trx_lines_tbl.product_description(i)||
             ', trx_line_gl_date: '||to_char(p_sync_trx_lines_tbl.trx_line_gl_date(i))||
             ', merchant_party_name: '||p_sync_trx_lines_tbl.merchant_party_name(i)||
             ', merchant_party_document_number: '||p_sync_trx_lines_tbl.merchant_party_document_number(i)||
             ', merchant_party_reference: '||p_sync_trx_lines_tbl.merchant_party_reference(i)||
             ', merchant_party_taxpayer_id: '||p_sync_trx_lines_tbl.merchant_party_taxpayer_id(i)||
             ', merchant_party_tax_reg_number: '||p_sync_trx_lines_tbl.merchant_party_tax_reg_number(i)||
             ', asset_number: '||to_char(p_sync_trx_lines_tbl.asset_number(i)));
        END LOOP;
     END IF;

     /* Fixed as part of 6826754 */
     UPDATE ZX_LINES
	      SET TRX_NUMBER = p_sync_trx_rec.TRX_NUMBER
      WHERE APPLICATION_ID            = p_sync_trx_rec.APPLICATION_ID
        AND ENTITY_CODE               = p_sync_trx_rec.ENTITY_CODE
        AND EVENT_CLASS_CODE          = p_sync_trx_rec.EVENT_CLASS_CODE
        AND TRX_ID                    = p_sync_trx_rec.TRX_ID;

	 /* update the header level attributes*/
     UPDATE ZX_LINES_DET_FACTORS SET
           EVENT_ID                       = l_event_class_rec.event_id,
           --EVENT_TYPE_CODE              = p_sync_trx_rec.EVENT_TYPE_CODE, /*bug 3922983*/
           TRX_NUMBER                     = p_sync_trx_rec.TRX_NUMBER,
           TRX_DESCRIPTION                = p_sync_trx_rec.TRX_DESCRIPTION,
           TRX_COMMUNICATED_DATE          = p_sync_trx_rec.TRX_COMMUNICATED_DATE,
           BATCH_SOURCE_ID                = p_sync_trx_rec.BATCH_SOURCE_ID,
           BATCH_SOURCE_NAME              = p_sync_trx_rec.BATCH_SOURCE_NAME,
           DOC_SEQ_ID                     = p_sync_trx_rec.DOC_SEQ_ID,
           DOC_SEQ_NAME                   = p_sync_trx_rec.DOC_SEQ_NAME,
           DOC_SEQ_VALUE                  = p_sync_trx_rec.DOC_SEQ_VALUE,
           TRX_DUE_DATE                   = p_sync_trx_rec.TRX_DUE_DATE,
           TRX_TYPE_DESCRIPTION           = p_sync_trx_rec.TRX_TYPE_DESCRIPTION,
           SUPPLIER_TAX_INVOICE_NUMBER    = decode(p_sync_trx_rec.SUPPLIER_TAX_INVOICE_NUMBER,FND_API.G_MISS_CHAR,SUPPLIER_TAX_INVOICE_NUMBER,p_sync_trx_rec.SUPPLIER_TAX_INVOICE_NUMBER), --Bug 5910475
           SUPPLIER_TAX_INVOICE_DATE      = decode(p_sync_trx_rec.SUPPLIER_TAX_INVOICE_DATE,FND_API.G_MISS_DATE,SUPPLIER_TAX_INVOICE_DATE,p_sync_trx_rec.SUPPLIER_TAX_INVOICE_DATE),       --Bug 5910475
           SUPPLIER_EXCHANGE_RATE         = decode(p_sync_trx_rec.SUPPLIER_EXCHANGE_RATE,FND_API.G_MISS_NUM,SUPPLIER_EXCHANGE_RATE,p_sync_trx_rec.SUPPLIER_EXCHANGE_RATE),                 --Bug 5910475
           TAX_INVOICE_DATE               = decode(p_sync_trx_rec.TAX_INVOICE_DATE,FND_API.G_MISS_DATE,TAX_INVOICE_DATE,p_sync_trx_rec.TAX_INVOICE_DATE),                                  --Bug 5910475
           TAX_INVOICE_NUMBER             = decode(p_sync_trx_rec.TAX_INVOICE_NUMBER,FND_API.G_MISS_CHAR,TAX_INVOICE_NUMBER,p_sync_trx_rec.TAX_INVOICE_NUMBER),                            --Bug 5910475
           PORT_OF_ENTRY_CODE             = decode(p_sync_trx_rec.PORT_OF_ENTRY_CODE,FND_API.G_MISS_CHAR,PORT_OF_ENTRY_CODE,p_sync_trx_rec.PORT_OF_ENTRY_CODE) ,                           --Bug 5910475
           APPLICATION_DOC_STATUS         = decode(p_sync_trx_rec.APPLICATION_DOC_STATUS,FND_API.G_MISS_CHAR,APPLICATION_DOC_STATUS,p_sync_trx_rec.APPLICATION_DOC_STATUS)                 --Bug 5910475
         WHERE  APPLICATION_ID            = p_sync_trx_rec.APPLICATION_ID
            AND ENTITY_CODE               = p_sync_trx_rec.ENTITY_CODE
            AND EVENT_CLASS_CODE          = p_sync_trx_rec.EVENT_CLASS_CODE
            AND TRX_ID                    = p_sync_trx_rec.TRX_ID;

     --Bugfix 4486946 -Call on the fly upgrade if the transaction if not found
     IF sql%notfound THEN
       l_upg_trx_info_rec.application_id   := l_event_class_rec.application_id;
       l_upg_trx_info_rec.entity_code      := l_event_class_rec.entity_code;
       l_upg_trx_info_rec.event_class_code := l_event_class_rec.event_class_code;
       l_upg_trx_info_rec.trx_id           := l_event_class_rec.trx_id;
       ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly(p_upg_trx_info_rec   =>  l_upg_trx_info_rec,
                                                    x_return_status      =>  l_return_status
                                                   );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly returned errors');
         END IF;
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
       END IF;
	   /* update the header level attributes*/
       UPDATE ZX_LINES_DET_FACTORS SET
           EVENT_ID                       = l_event_class_rec.event_id,
           --EVENT_TYPE_CODE              = p_sync_trx_rec.EVENT_TYPE_CODE, /*bug 3922983*/
           TRX_NUMBER                     = p_sync_trx_rec.TRX_NUMBER,
           TRX_DESCRIPTION                = p_sync_trx_rec.TRX_DESCRIPTION,
           TRX_COMMUNICATED_DATE          = p_sync_trx_rec.TRX_COMMUNICATED_DATE,
           BATCH_SOURCE_ID                = p_sync_trx_rec.BATCH_SOURCE_ID,
           BATCH_SOURCE_NAME              = p_sync_trx_rec.BATCH_SOURCE_NAME,
           DOC_SEQ_ID                     = p_sync_trx_rec.DOC_SEQ_ID,
           DOC_SEQ_NAME                   = p_sync_trx_rec.DOC_SEQ_NAME,
           DOC_SEQ_VALUE                  = p_sync_trx_rec.DOC_SEQ_VALUE,
           TRX_DUE_DATE                   = p_sync_trx_rec.TRX_DUE_DATE,
           TRX_TYPE_DESCRIPTION           = p_sync_trx_rec.TRX_TYPE_DESCRIPTION,
           SUPPLIER_TAX_INVOICE_NUMBER    = decode(p_sync_trx_rec.SUPPLIER_TAX_INVOICE_NUMBER,FND_API.G_MISS_CHAR,SUPPLIER_TAX_INVOICE_NUMBER,p_sync_trx_rec.SUPPLIER_TAX_INVOICE_NUMBER), --Bug 5910475
           SUPPLIER_TAX_INVOICE_DATE      = decode(p_sync_trx_rec.SUPPLIER_TAX_INVOICE_DATE,FND_API.G_MISS_DATE,SUPPLIER_TAX_INVOICE_DATE,p_sync_trx_rec.SUPPLIER_TAX_INVOICE_DATE),       --Bug 5910475
           SUPPLIER_EXCHANGE_RATE         = decode(p_sync_trx_rec.SUPPLIER_EXCHANGE_RATE,FND_API.G_MISS_NUM,SUPPLIER_EXCHANGE_RATE,p_sync_trx_rec.SUPPLIER_EXCHANGE_RATE),                 --Bug 5910475
           TAX_INVOICE_DATE               = decode(p_sync_trx_rec.TAX_INVOICE_DATE,FND_API.G_MISS_DATE,TAX_INVOICE_DATE,p_sync_trx_rec.TAX_INVOICE_DATE),                                  --Bug 5910475
           TAX_INVOICE_NUMBER             = decode(p_sync_trx_rec.TAX_INVOICE_NUMBER,FND_API.G_MISS_CHAR,TAX_INVOICE_NUMBER,p_sync_trx_rec.TAX_INVOICE_NUMBER),                            --Bug 5910475
           PORT_OF_ENTRY_CODE             = decode(p_sync_trx_rec.PORT_OF_ENTRY_CODE,FND_API.G_MISS_CHAR,PORT_OF_ENTRY_CODE,p_sync_trx_rec.PORT_OF_ENTRY_CODE) ,                           --Bug 5910475
           APPLICATION_DOC_STATUS         = decode(p_sync_trx_rec.APPLICATION_DOC_STATUS,FND_API.G_MISS_CHAR,APPLICATION_DOC_STATUS,p_sync_trx_rec.APPLICATION_DOC_STATUS)                 --Bug 5910475
	        WHERE APPLICATION_ID            = p_sync_trx_rec.APPLICATION_ID
            AND ENTITY_CODE               = p_sync_trx_rec.ENTITY_CODE
            AND EVENT_CLASS_CODE          = p_sync_trx_rec.EVENT_CLASS_CODE
            AND TRX_ID                    = p_sync_trx_rec.TRX_ID;
     /* Fixed as part of 6826754 */
       UPDATE ZX_LINES
	        SET TRX_NUMBER = p_sync_trx_rec.TRX_NUMBER
        WHERE APPLICATION_ID            = p_sync_trx_rec.APPLICATION_ID
          AND ENTITY_CODE               = p_sync_trx_rec.ENTITY_CODE
          AND EVENT_CLASS_CODE          = p_sync_trx_rec.EVENT_CLASS_CODE
          AND TRX_ID                    = p_sync_trx_rec.TRX_ID;

     END IF; --sql%notfound
     --Bugfix 4486946 - on-the-fly upgrade end

     /* update the line level attributes if passed*/
     IF  (p_sync_trx_lines_tbl.APPLICATION_ID.EXISTS(1)) THEN
       FORALL i IN 1..nvl(p_sync_trx_lines_tbl.APPLICATION_ID.LAST,-99)
         UPDATE ZX_LINES_DET_FACTORS SET
           TRX_LEVEL_TYPE                 = p_sync_trx_lines_tbl.TRX_LEVEL_TYPE(i),
           TRX_LINE_ID                    = p_sync_trx_lines_tbl.TRX_LINE_ID(i),
           TRX_WAYBILL_NUMBER             = p_sync_trx_lines_tbl.TRX_WAYBILL_NUMBER(i),
           TRX_LINE_DESCRIPTION           = p_sync_trx_lines_tbl.TRX_LINE_DESCRIPTION(i),
           PRODUCT_DESCRIPTION            = p_sync_trx_lines_tbl.PRODUCT_DESCRIPTION(i),
           TRX_LINE_GL_DATE               = p_sync_trx_lines_tbl.TRX_LINE_GL_DATE(i),
           MERCHANT_PARTY_NAME            = p_sync_trx_lines_tbl.MERCHANT_PARTY_NAME(i),
           MERCHANT_PARTY_DOCUMENT_NUMBER = p_sync_trx_lines_tbl.MERCHANT_PARTY_DOCUMENT_NUMBER(i),
           MERCHANT_PARTY_REFERENCE       = p_sync_trx_lines_tbl.MERCHANT_PARTY_REFERENCE(i),
           MERCHANT_PARTY_TAXPAYER_ID     = p_sync_trx_lines_tbl.MERCHANT_PARTY_TAXPAYER_ID(i),
           MERCHANT_PARTY_TAX_REG_NUMBER  = p_sync_trx_lines_tbl.MERCHANT_PARTY_TAX_REG_NUMBER(i),
           ASSET_NUMBER                   = p_sync_trx_lines_tbl.ASSET_NUMBER(i)
         WHERE APPLICATION_ID            = p_sync_trx_rec.APPLICATION_ID
           AND ENTITY_CODE               = p_sync_trx_rec.ENTITY_CODE
           AND EVENT_CLASS_CODE          = p_sync_trx_rec.EVENT_CLASS_CODE
     	     AND TRX_ID                    = p_sync_trx_rec.TRX_ID
           AND TRX_LINE_ID               = p_sync_trx_lines_tbl.TRX_LINE_ID(i)
           AND TRX_LEVEL_TYPE            = p_sync_trx_lines_tbl.TRX_LEVEL_TYPE(i);
     END IF;


     /*********Partner code Start************************/
     ZX_SRVC_TYP_PKG.synchronize_tax(l_event_class_rec,
                                     l_return_status
                                     );
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_SRVC_TYP_PKG.synchronize_tax returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;

     /********Partner Code End *************************/

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
    END IF;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Synchronize_tax_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        DUMP_MSG;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count  => x_msg_count,
                                  p_data   => x_msg_data
                                  );
        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Synchronize_tax_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        DUMP_MSG;
        FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
        FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count  => x_msg_count,
                                  p_data   => x_msg_data
                                  );
        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN OTHERS THEN
         ROLLBACK TO Synchronize_tax_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
         FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count       =>      x_msg_count,
                                   p_data        =>      x_msg_data
                                   );
         IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;
 END synchronize_tax_repository;

/* ======================================================================*
 | PROCEDURE override_tax : Overrides tax lines                          |
 | There exists only pl/sql version for this API                         |
 * ======================================================================*/

 PROCEDURE Override_tax
 ( p_api_version           IN         NUMBER,
   p_init_msg_list         IN         VARCHAR2,
   p_commit                IN         VARCHAR2,
   p_validation_level      IN         NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   p_transaction_rec       IN         transaction_rec_type,
   p_override_level        IN         VARCHAR2,
   p_event_id              IN         NUMBER
  ) IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'OVERRIDE_TAX';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_init_msg_list               VARCHAR2(1);
   l_event_class_rec             event_class_rec_type;
   l_transaction_header_rec      transaction_header_rec_type;
   l_context_info_rec            context_info_rec_type;
   l_index                       BINARY_INTEGER;
   l_record_tax_lines            VARCHAR2(1);

  CURSOR  get_trx_date_csr
            (c_application_id     zx_lines_det_factors.application_id%TYPE,
             c_entity_code     zx_lines_det_factors.entity_code%TYPE,
             c_event_class_code     zx_lines_det_factors.event_class_code%TYPE,
             c_trx_id     zx_lines_det_factors.trx_id%TYPE,
             c_event_id     zx_lines_det_factors.event_id%TYPE
             ) IS
   SELECT trx_date,
          related_doc_date,
          provnl_tax_determination_date
     FROM zx_lines_det_factors
    WHERE application_id = c_application_id
      AND entity_code = c_entity_code
      AND event_class_code = c_event_class_code
      AND trx_id = c_trx_id
      AND event_id = c_event_id
      AND ROWNUM = 1;

 BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

   /*--------------------------------------------------+
    |   Standard start of API savepoint                |
    +--------------------------------------------------*/
    SAVEPOINT Override_Tax_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/

    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


   /*--------------------------------------------------------------+
   |   Initialize message list if p_init_msg_list is set to TRUE  |
   +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
	   l_init_msg_list := p_init_msg_list;
	 END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

   /*-----------------------------------------+
    |   Initialize return status to SUCCESS   |
    +-----------------------------------------*/

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*-----------------------------------------+
    |   Populate Global Variable              |
    +-----------------------------------------*/

     G_PUB_SRVC := l_api_name;
     G_DATA_TRANSFER_MODE := 'PLS';
     G_EXTERNAL_API_CALL  := 'N';

     --Call TDS process to reset the session for previous override tax calls if any
     ZX_TDS_CALC_SERVICES_PUB_PKG.initialize (p_event_class_rec => NULL,
                                              p_init_level      => 'SESSION',
                                              x_return_status   => l_return_status
                                             );

     set_ptnr_srvc_subscr_flag (p_event_class_rec => NULL,
                                x_return_status   => l_return_status
                               );

        ZX_GLOBAL_STRUCTURES_PKG.LOC_GEOGRAPHY_INFO_TBL.DELETE;
        ZX_GLOBAL_STRUCTURES_PKG.g_registration_info_tbl.DELETE;
    /*------------------------------------------------------+
     |   Copy to Event Class Record                         |
     +------------------------------------------------------*/
     l_event_class_rec.event_id                    :=  p_event_id;
     l_event_class_rec.INTERNAL_ORGANIZATION_ID    :=  p_transaction_rec.INTERNAL_ORGANIZATION_ID;
     l_event_class_rec.APPLICATION_ID              :=  p_transaction_rec.APPLICATION_ID;
     l_event_class_rec.ENTITY_CODE                 :=  p_transaction_rec.ENTITY_CODE;
     l_event_class_rec.EVENT_CLASS_CODE            :=  p_transaction_rec.EVENT_CLASS_CODE;
     l_event_class_rec.EVENT_TYPE_CODE             :=  p_transaction_rec.EVENT_TYPE_CODE;
     l_event_class_rec.TRX_ID                      :=  p_transaction_rec.TRX_ID;

     -- bug 5684123
     --
     OPEN  get_trx_date_csr
            (l_event_class_rec.application_id,
             l_event_class_rec.entity_code,
             l_event_class_rec.event_class_code,
             l_event_class_rec.trx_id,
             l_event_class_rec.event_id);
     FETCH get_trx_date_csr INTO l_event_class_rec.trx_date,
                                 l_event_class_rec.rel_doc_date,
                                 l_event_class_rec.provnl_tax_determination_date;
     CLOSE get_trx_date_csr;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
             'application_id: '||to_char(l_event_class_rec.application_id)||
             ', entity_code: '||l_event_class_rec.entity_code||
             ', event_class_code: '||l_event_class_rec.event_class_code||
             ', event_type_code: '||l_event_class_rec.event_type_code||
             ', trx_id: '||to_char(l_event_class_rec.trx_id)||
             ', internal_organization_id: '||to_char(l_event_class_rec.internal_organization_id) ||
             ', trx_date: '||to_char(l_event_class_rec.trx_date, 'MM-DD-YYYY'));
     END IF;

     IF l_event_class_rec.event_class_code = 'CREDIT_MEMO' THEN
       ZX_GLOBAL_STRUCTURES_PKG.g_credit_memo_exists_flg := 'Y';
     END IF;

     /*------------------------------------------------------+
      |   Validate and Initializate parameters for Override  |
      |   tax                                                |
      +------------------------------------------------------*/
     ZX_VALID_INIT_PARAMS_PKG.override_tax(x_return_status   => l_return_status ,
                                           p_override        => p_override_level,
                                           p_event_class_rec => l_event_class_rec,
                                           p_trx_rec         => p_transaction_rec
                                           );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_VALID_INIT_PARAMS_PKG.override_tax returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;

     /*===============================================================================*
      |Initialize the global structures/global temp tables owned by TDM at header level |
      *================================================================================*/
     ZX_TDS_CALC_SERVICES_PUB_PKG.initialize (l_event_class_rec,
                                              'HEADER',
                                               l_return_status
                                             );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TDS_CALC_SERVICES_PUB_PKG.initialize  returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;

     /*--------------------------------------------------+
      |   Call Service Type Override Summary or Override |
      |   Detail Tax Lines depending of the overriding   |
      |   level.                                         |
      +--------------------------------------------------*/
     ZX_SRVC_TYP_PKG.override_tax_lines(p_event_class_rec    => l_event_class_rec,
                                        p_override_level     => p_override_level,
                                        x_return_status      => l_return_status
                                        );
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TDS_CALC_SERVICES_PUB_PKG.initialize  returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;

     /*-----------------------------------------------------+
      |   Call to eTax service Dump Detail Tax Lines Into GT|
      +-----------------------------------------------------*/
     ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt(x_return_status => l_return_status);

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TDS_CALC_SERVICES_PUB_PKG.dump_detail_tax_lines_into_gt returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;

     /*--------------------------------------------------+
      |   Call to eTax Service Tax Lines Determination   |
      +--------------------------------------------------*/
     ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination(p_event_class_rec => l_event_class_rec,
                                                         x_return_status   => l_return_status
                                                         );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TDS_CALC_SERVICES_PUB_PKG.tax_line_determination returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;

     /*--------------------------------------------------+
      |   Call to eTax Service Manage Tax Lines          |
      +--------------------------------------------------*/
     --Rounding and Summarization of Tax Lines for Transaction
     /*Bug 3649502 - Check for record flag before calling TRR service*/
     --IF l_event_class_rec.record_flag = 'Y' THEN

     l_record_tax_lines := l_event_class_rec.record_flag;
     IF l_event_class_rec.record_flag = 'Y' and
        l_event_class_rec.quote_flag = 'Y' THEN
        l_record_tax_lines := 'N';
     END IF;
     IF l_record_tax_lines = 'Y' THEN
       ZX_TRL_PUB_PKG.manage_taxlines(p_event_class_rec  =>l_event_class_rec,
                                      x_return_status    =>l_return_status
                                      );
     END IF;

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TRL_PUB_PKG.manage_taxlines returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;

     --Delete from the global structures so that there are no hanging/redundant
     --records sitting there
     ZX_GLOBAL_STRUCTURES_PKG.delete_trx_line_dist_tbl;

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
     END IF;

     EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Override_Tax_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        DUMP_MSG;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count  => x_msg_count,
                                  p_data   => x_msg_data
                                  );
        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Override_Tax_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        DUMP_MSG;
        FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
        FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count  => x_msg_count,
                                  p_data   => x_msg_data
                                  );
        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN OTHERS THEN
         ROLLBACK TO Override_Tax_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
         FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count       =>      x_msg_count,
                                   p_data        =>      x_msg_data
                                   );
         IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;
  END override_tax;


/* ======================================================================*
 | PROCEDURE global_document_update :                                    |
 * ======================================================================*/

 PROCEDURE Global_document_update
 ( p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2,
   p_commit                IN  VARCHAR2 ,
   p_validation_level      IN  NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   p_transaction_rec       IN OUT NOCOPY transaction_rec_type
  ) IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'GLOBAL_DOCUMENT_UPDATE';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_validation_status           ZX_API_PUB.validation_status_tbl_type;
   l_init_msg_list               VARCHAR2(1);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

   /*--------------------------------------------------+
    |   Standard start of API savepoint                |
    +--------------------------------------------------*/
    SAVEPOINT global_document_update_PVT;

    /*--------------------------------------------------+
     |   Standard call to check for call compatibility  |
     +--------------------------------------------------*/

     IF NOT FND_API.Compatible_API_Call(l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                        ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
	   l_init_msg_list := p_init_msg_list;
	 END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

     /*-----------------------------------------+
      |   Initialize return status to SUCCESS   |
      +-----------------------------------------*/

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      /*-----------------------------------------+
      |   Populate Global Variable              |
      +-----------------------------------------*/
       G_PUB_SRVC := l_api_name;
       G_DATA_TRANSFER_MODE := 'PLS';
       G_EXTERNAL_API_CALL  := 'N';

      /*-----------------------------------------------+
       |   Calling Global Document Update with         |
       |   with validation status                      |
       +-----------------------------------------------*/

       ZX_API_PUB.global_document_update(p_api_version,
                                         l_init_msg_list,
                                         p_commit,
                                         p_validation_level,
                                         l_return_status,
                                         x_msg_count,
                                         x_msg_data,
                                         p_transaction_rec,
                                         l_validation_status
                                         );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_API_PUB.global_document_update returned errors');
         END IF;
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
       END IF;

       IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
       END IF;

       EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO global_document_update_PVT;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         DUMP_MSG;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count   =>      x_msg_count,
                                   p_data    =>      x_msg_data
                                   );
         IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
         END IF;

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO global_document_update_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         DUMP_MSG;
         FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
         FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count       =>      x_msg_count,
                                   p_data        =>      x_msg_data
                                   );
         IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
         END IF;

        WHEN OTHERS THEN
           ROLLBACK TO global_document_update_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
           FND_MSG_PUB.Add;
          /*---------------------------------------------------------+
           | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
           | in the message stack. If there is only one message in   |
           | the stack it retrieves this message                     |
           +---------------------------------------------------------*/
           FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                     p_count       =>      x_msg_count,
                                     p_data        =>      x_msg_data
                                    );

           IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;
  END global_document_update;

/* ======================================================================*
 | PROCEDURE global_document_update :                                    |
 * ======================================================================*/

 PROCEDURE global_document_update
 ( p_api_version           IN            NUMBER,
   p_init_msg_list         IN            VARCHAR2,
   p_commit                IN            VARCHAR2,
   p_validation_level      IN            NUMBER,
   x_return_status         OUT NOCOPY    VARCHAR2,
   x_msg_count             OUT NOCOPY    NUMBER,
   x_msg_data              OUT NOCOPY    VARCHAR2,
   p_transaction_rec       IN OUT NOCOPY transaction_rec_type,
   p_validation_status     IN            ZX_API_PUB.validation_status_tbl_type
  ) IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'GLOBAL_DOCUMENT_UPDATE';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_event_class_rec             event_class_rec_type;
   l_return_status               VARCHAR2(30);
   l_context_info_rec            context_info_rec_type;
   l_init_msg_list               VARCHAR2(1);
   l_upg_trx_info_rec            ZX_ON_FLY_TRX_UPGRADE_PKG.zx_upg_trx_info_rec_type;
   l_lines_det_rec    zx_lines_det_factors%rowtype;
 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

   /*--------------------------------------------------+
    |   Standard start of API savepoint                |
    +--------------------------------------------------*/
    SAVEPOINT global_document_update_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
	   l_init_msg_list := p_init_msg_list;
	 END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

    /*-----------------------------------------+
     |   Initialize return status to SUCCESS   |
     +-----------------------------------------*/
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     /*-----------------------------------------+
      |   Populate Global Variable              |
      +-----------------------------------------*/
      G_PUB_SRVC := l_api_name;
      G_DATA_TRANSFER_MODE := 'PLS';
      G_EXTERNAL_API_CALL  := 'N';


      /*------------------------------------------------------+
       |   Validate Input Paramerters and Fetch Tax Options   |
       +------------------------------------------------------*/
       ZX_VALID_INIT_PARAMS_PKG.global_document_update(x_return_status   => l_return_status,
                                                       p_event_class_rec => l_event_class_rec,
                                                       p_trx_rec         => p_transaction_rec
                                                      );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_VALID_INIT_PARAMS_PKG.global_document_update returned errors');
         END IF;
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
       END IF;



      /*------------------------------------------------+
       |  Update zx_lines_det_factors                   |
       +------------------------------------------------*/
       IF l_event_class_rec.tax_event_type_code IN ('DELETE','PURGE') THEN
          -- Bug 5200373: Incarporated missing hook to take snapshot of zx_lines_det_factors so that
          --              upgraded R11i partner softwares can handle the header level document delete
          --              sceanrio.
          zx_r11i_tax_partner_pkg.copy_trx_line_for_ptnr_bef_upd(NULL
                                       , l_event_class_rec
                                       , NULL
                                       , 'N'
                                       , NULL
                                       , NULL
                                       , l_return_status);
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':zx_r11i_tax_partner_pkg.copy_trx_line_for_ptnr_bef_upd returned errors');
             END IF;
             IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
          END IF;

          -- Bug 5237826: Explicitly check if the resource is busy prior to making the delete. Resource can
          --              become busy if calling products fail to issue a COMMIT or ROLLBACK immediately
          --              after call to this API.
          BEGIN
            /*Lock trx line det factors for delete*/
             SELECT *
              INTO l_lines_det_rec
              FROM ZX_LINES_DET_FACTORS
             WHERE application_id   = p_transaction_rec.application_id
               AND entity_code      = p_transaction_rec.entity_code
               AND event_class_code = p_transaction_rec.event_class_code
               AND trx_id           = p_transaction_rec.trx_id
               AND rownum           = 1
             FOR UPDATE NOWAIT;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              NULL;
            WHEN OTHERS THEN
               IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
               END IF;
               IF (SQLCODE = 54) THEN
                  FND_MESSAGE.SET_NAME('ZX','ZX_RESOURCE_BUSY');
                  l_context_info_rec.APPLICATION_ID   := p_transaction_rec.APPLICATION_ID;
                  l_context_info_rec.ENTITY_CODE      := p_transaction_rec.ENTITY_CODE;
                  l_context_info_rec.EVENT_CLASS_CODE := p_transaction_rec.EVENT_CLASS_CODE;
                  l_context_info_rec.TRX_ID           := p_transaction_rec.TRX_ID;
                  ZX_API_PUB.add_msg( p_context_info_rec => l_context_info_rec );
                  RAISE FND_API.G_EXC_ERROR;
               ELSE
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
          END;

          DELETE from ZX_LINES_DET_FACTORS
           WHERE APPLICATION_ID  = p_transaction_rec.APPLICATION_ID
             AND ENTITY_CODE       = p_transaction_rec.ENTITY_CODE
             AND EVENT_CLASS_CODE  = p_transaction_rec.EVENT_CLASS_CODE
             AND TRX_ID            = p_transaction_rec.TRX_ID;

       ELSIF l_event_class_rec.tax_event_type_code NOT IN ('RELEASE_HOLD') THEN
          UPDATE ZX_LINES_DET_FACTORS
             SET EVENT_TYPE_CODE     = l_event_class_rec.event_type_code,
                 TAX_EVENT_TYPE_CODE = l_event_class_rec.tax_event_type_code,
                 DOC_EVENT_STATUS    = l_event_class_rec.doc_status_code
             WHERE APPLICATION_ID    = p_transaction_rec.APPLICATION_ID
               AND ENTITY_CODE       = p_transaction_rec.ENTITY_CODE
               AND EVENT_CLASS_CODE  = p_transaction_rec.EVENT_CLASS_CODE
               AND TRX_ID            = p_transaction_rec.TRX_ID;

          --Bugfix 4486946 -Call on the fly upgrade if the transaction if not found
          IF sql%notfound THEN
            l_upg_trx_info_rec.application_id   := l_event_class_rec.application_id;
            l_upg_trx_info_rec.entity_code      := l_event_class_rec.entity_code;
            l_upg_trx_info_rec.event_class_code := l_event_class_rec.event_class_code;
            l_upg_trx_info_rec.trx_id           := l_event_class_rec.trx_id;
            ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly(p_upg_trx_info_rec   =>  l_upg_trx_info_rec,
                                                         x_return_status      =>  l_return_status
                                                        );
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly returned errors');
              END IF;
              IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
              ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            END IF;
            UPDATE ZX_LINES_DET_FACTORS
               SET EVENT_TYPE_CODE     = l_event_class_rec.event_type_code,
                   TAX_EVENT_TYPE_CODE = l_event_class_rec.tax_event_type_code,
                   DOC_EVENT_STATUS    = l_event_class_rec.doc_status_code
             WHERE APPLICATION_ID    = p_transaction_rec.APPLICATION_ID
               AND ENTITY_CODE       = p_transaction_rec.ENTITY_CODE
               AND EVENT_CLASS_CODE  = p_transaction_rec.EVENT_CLASS_CODE
               AND TRX_ID            = p_transaction_rec.TRX_ID;
          END IF; --sql%notfound
        END IF; --not in (RELEASE_HOLD)
        --Bugfix 4486946 - on-the-fly upgrade end

      /*--------------------------------------------------+
       |   Call to Service Type Document Level Changes    |
       +--------------------------------------------------*/
       --Bug 4463450: Do not carry out any reversals for tax lines and dists for
       --event classes not reportable for tax
       IF l_event_class_rec.tax_event_type_code = 'CANCEL' AND
          l_event_class_rec.tax_reporting_flag = 'N'  THEN
          null;
       ELSE

         ZX_SRVC_TYP_PKG.document_level_changes(x_return_status          => l_return_status,
                                                p_event_class_rec        => l_event_class_rec,
                                                p_tax_hold_released_code => p_validation_status
                                               );

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_VALID_INIT_PARAMS_PKG.global_document_update returned errors');
           END IF;
           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
         END IF;
       END IF;


       IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
       END IF;

       EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO global_document_update_PVT;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         DUMP_MSG;
         /*---------------------------------------------------------+
          | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
          | in the message stack. If there is only one message in   |
          | the stack it retrieves this message                     |
          +---------------------------------------------------------*/
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                    p_count       =>      x_msg_count,
                                    p_data        =>      x_msg_data
                                   );
         IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
         END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO global_document_update_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          DUMP_MSG;
          FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
          FND_MSG_PUB.Add;
         /*---------------------------------------------------------+
          | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
          | in the message stack. If there is only one message in   |
          | the stack it retrieves this message                     |
          +---------------------------------------------------------*/
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                    p_count       =>      x_msg_count,
                                    p_data        =>      x_msg_data
                                   );

          IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
          END IF;

        WHEN OTHERS THEN
           ROLLBACK TO global_document_update_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
           FND_MSG_PUB.Add;
         /*---------------------------------------------------------+
          | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
          | in the message stack. If there is only one message in   |
          | the stack it retrieves this message                     |
          +---------------------------------------------------------*/
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                    p_count       =>      x_msg_count,
                                    p_data        =>      x_msg_data
                                   );
           IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;
 END global_document_update;


/* ======================================================================*
 | PROCEDURE Mark_tax_lines_deleted :                                    |
 * ======================================================================*/

 PROCEDURE Mark_tax_lines_deleted
 ( p_api_version           IN            NUMBER,
   p_init_msg_list         IN            VARCHAR2,
   p_commit                IN            VARCHAR2,
   p_validation_level      IN            NUMBER,
   x_return_status         OUT NOCOPY    VARCHAR2 ,
   x_msg_count             OUT NOCOPY    NUMBER ,
   x_msg_data              OUT NOCOPY    VARCHAR2 ,
   p_transaction_line_rec  IN OUT NOCOPY transaction_line_rec_type
  ) IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'MARK_TAX_LINES_DELETED';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_init_msg_list               VARCHAR2(1);
   l_event_type_code             VARCHAR2(30);
 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

   /*--------------------------------------------------+
    |   Standard start of API savepoint                |
    +--------------------------------------------------*/
    SAVEPOINT mark_tax_lines_del_PVT;

    /*--------------------------------------------------+
     |   Standard call to check for call compatibility  |
     +--------------------------------------------------*/
     IF NOT FND_API.Compatible_API_Call(l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                        ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     /*--------------------------------------------------------------+
      |   Initialize message list if p_init_msg_list is set to TRUE  |
      +--------------------------------------------------------------*/
      IF p_init_msg_list is null THEN
        l_init_msg_list := FND_API.G_FALSE;
      ELSE
	    l_init_msg_list := p_init_msg_list;
	  END IF;

      IF FND_API.to_Boolean(l_init_msg_list) THEN
        FND_MSG_PUB.initialize;
      END IF;

      /*-----------------------------------------+
       |   Initialize return status to SUCCESS   |
       +-----------------------------------------*/
       x_return_status := FND_API.G_RET_STS_SUCCESS;


       /*-----------------------------------------+
        |   Populate Global Variable              |
        +-----------------------------------------*/
        G_PUB_SRVC := l_api_name;
        G_DATA_TRANSFER_MODE := 'PLS';
        G_EXTERNAL_API_CALL  := 'N';

       /*------------------------------------------------------+
        |   Validate Input Paramerters and Fetch Tax Options   |
        +------------------------------------------------------*/
        ZX_VALID_INIT_PARAMS_PKG.mark_tax_lines_deleted( x_return_status        => l_return_status,
                                                         p_transaction_line_rec => p_transaction_line_rec
                                                       );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_VALID_INIT_PARAMS_PKG.mark_tax_lines_deleted returned errors');
          END IF;
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

        /*--------------------------------------------------+
         |   Call Service Type Mark Tax Lines Deleted       |
         +--------------------------------------------------*/
         ZX_SRVC_TYP_PKG.mark_tax_lines_deleted( p_trx_line_rec       => p_transaction_line_rec,
                                                 x_return_status      => l_return_status
                                               );

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_SRVC_TYP_PKG.mark_tax_lines_deleted returned errors');
           END IF;
           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
         END IF;
        /*--------------------------------------------------+
         |   Update line level action to  Deleted           |
         +--------------------------------------------------*/
         IF p_transaction_line_rec.event_type_code is null THEN
           BEGIN
             SELECT event_type_code
               INTO l_event_type_code
               FROM ZX_EVNT_TYP_MAPPINGS
              WHERE application_id      = p_transaction_line_rec.application_id
                AND entity_code         = p_transaction_line_rec.entity_code
                AND event_class_code    = p_transaction_line_rec.event_class_code
                AND tax_event_type_code = 'UPDATE';
           EXCEPTION
              WHEN NO_DATA_FOUND  THEN
                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':Event information passed is incorrect');
                 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END;
         END IF;

         BEGIN
           UPDATE ZX_LINES_DET_FACTORS
             SET LINE_LEVEL_ACTION   = 'DELETE',
                 EVENT_TYPE_CODE     = nvl(p_transaction_line_rec.event_type_code, l_event_type_code),
                 TAX_EVENT_TYPE_CODE = 'UPDATE'
           WHERE application_id   = p_transaction_line_rec.application_id
             AND entity_code      = p_transaction_line_rec.entity_code
             AND event_class_code = p_transaction_line_rec.event_class_code
             AND trx_id           = p_transaction_line_rec.trx_id
             AND trx_line_id      = p_transaction_line_rec.trx_line_id;
           EXCEPTION
              WHEN NO_DATA_FOUND  THEN
                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':Event information passed is incorrect');
                 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END;


       IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
       END IF;

    /* Bug 3704651 - No need to uptake error handling as it is a PLS API*/
       EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO mark_tax_lines_del_PVT;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         DUMP_MSG;
         /*---------------------------------------------------------+
          | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
          | in the message stack. If there is only one message in   |
          | the stack it retrieves this message                     |
          +---------------------------------------------------------*/
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data
                                    );
         IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
         END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO mark_tax_lines_del_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          DUMP_MSG;
          FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
          FND_MSG_PUB.Add;
         /*---------------------------------------------------------+
          | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
          | in the message stack. If there is only one message in   |
          | the stack it retrieves this message                     |
          +---------------------------------------------------------*/
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data
                                    );

          IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
          END IF;

        WHEN OTHERS THEN
           ROLLBACK TO mark_tax_lines_del_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
           FND_MSG_PUB.Add;
          /*---------------------------------------------------------+
           | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
           | in the message stack. If there is only one message in   |
           | the stack it retrieves this message                     |
           +---------------------------------------------------------*/
           FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                     p_count   => x_msg_count,
                                     p_data    => x_msg_data
                                     );
           IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;

 END mark_tax_lines_deleted;


/* ======================================================================*
 | PROCEDURE reverse_document : Reverses the base document               |
 | GTT involved : ZX_REV_TRX_HEADERS_GT, ZX_REVERSE_TRX_LINES_GT         |
 | This API has been coded with the assumption that it will receive only |
 | only document in a call                                               |
 * ======================================================================*/
 PROCEDURE reverse_document
 ( p_api_version            IN         NUMBER,
   p_init_msg_list          IN         VARCHAR2,
   p_commit                 IN         VARCHAR2,
   p_validation_level       IN         NUMBER,
   x_return_status          OUT NOCOPY VARCHAR2 ,
   x_msg_count              OUT NOCOPY NUMBER ,
   x_msg_data               OUT NOCOPY VARCHAR2
  ) IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'REVERSE_DOCUMENT';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_event_class_rec             event_class_rec_type;
   l_context_info_rec            context_info_rec_type;
   l_init_msg_list               VARCHAR2(1);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

   /*--------------------------------------------------+
    |   Standard start of API savepoint                |
    +--------------------------------------------------*/
    SAVEPOINT reverse_document_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/

    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   /*--------------------------------------------------------------+
    |   Initialize message list if p_init_msg_list is set to TRUE  |
    +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
	   l_init_msg_list := p_init_msg_list;
	 END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

   /*-----------------------------------------+
    |   Initialize return status to SUCCESS   |
    +-----------------------------------------*/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*-----------------------------------------+
     |   Populate Global Variable              |
     +-----------------------------------------*/
     G_PUB_SRVC := l_api_name;
     G_DATA_TRANSFER_MODE := 'TAB';
     G_EXTERNAL_API_CALL  := 'N';

     /*-----------------------------------------+
     | Get the event id for the whole document |
     +-----------------------------------------*/
     select ZX_LINES_DET_FACTORS_S.nextval
      into l_event_class_rec.event_id
      from dual;

     /*------------------------------------------------------+
     |   Validate Input Paramerters and Fetch Tax Options   |
     +------------------------------------------------------*/
     ZX_VALID_INIT_PARAMS_PKG.reverse_document(x_return_status   => l_return_status,
                                               p_event_class_rec => l_event_class_rec
                                              );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_VALID_INIT_PARAMS_PKG.reverse_document returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;

    /*-----------------------------------------+
     |   Bug 5662795                           |
     +-----------------------------------------*/
     set_ptnr_srvc_subscr_flag (p_event_class_rec => NULL,
                                x_return_status   => l_return_status
                               );

    /*--------------------------------------------------+
     |   Call Service Reverse Type Document             |
     +--------------------------------------------------*/
     ZX_SRVC_TYP_PKG.reverse_document(p_event_class_rec => l_event_class_rec,
                                      x_return_status   => l_return_status
                                     );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_SRVC_TYP_PKG.reverse_document returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;

     --Delete from the global structures so that there are no hanging/redundant
     --records sitting there
     ZX_GLOBAL_STRUCTURES_PKG.delete_trx_line_dist_tbl;

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
     END IF;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO reverse_document_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        --Call API to dump into zx_errors_gt if not already inserted.
        DUMP_MSG;
        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO reverse_document_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        DUMP_MSG;
        FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
        FND_MSG_PUB.Add;
       /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data
                                  );

        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN OTHERS THEN
         ROLLBACK TO reverse_document_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
         FND_MSG_PUB.Add;
       /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data
                                  );

         IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;
 END reverse_document;


/* ======================================================================*
 | PROCEDURE Reverse_distributions : Reverses the base distribution      |
 | GTT involved : ZX_REVERSE_DIST_GT                                     |
 * ======================================================================*/
 PROCEDURE reverse_distributions
 ( p_api_version            IN         NUMBER,
   p_init_msg_list          IN         VARCHAR2,
   p_commit                 IN         VARCHAR2,
   p_validation_level       IN         NUMBER,
   x_return_status          OUT NOCOPY VARCHAR2 ,
   x_msg_count              OUT NOCOPY NUMBER ,
   x_msg_data               OUT NOCOPY VARCHAR2
  ) IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'REVERSE_DISTRIBUTIONS';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_context_info_rec            context_info_rec_type;
   l_init_msg_list               VARCHAR2(1);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT reverse_distributions_PVT;

  /*--------------------------------------------------+
   |   Standard call to check for call compatibility  |
   +--------------------------------------------------*/
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   /*--------------------------------------------------------------+
    |   Initialize message list if p_init_msg_list is set to TRUE  |
    +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
	   l_init_msg_list := p_init_msg_list;
	 END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

   /*-----------------------------------------+
    |   Initialize return status to SUCCESS   |
    +-----------------------------------------*/
    x_return_status := FND_API.G_RET_STS_SUCCESS;


   /*-----------------------------------------+
    |   Populate Global Variable              |
    +-----------------------------------------*/
    G_PUB_SRVC := l_api_name;
    G_DATA_TRANSFER_MODE := 'TAB';
    G_EXTERNAL_API_CALL  := 'N';

   /*------------------------------------------------------+
    |   Validate Input Paramerters and Fetch Tax Options   |
    +------------------------------------------------------*/
    IF ( G_LEVEL_EVENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_EVENT,G_MODULE_NAME||l_api_name,
        'Validating Reversing Document Distributions'
          );
    END IF;

    ZX_VALID_INIT_PARAMS_PKG.reverse_distributions(x_return_status  =>l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_VALID_INIT_PARAMS_PKG.reverse_distributions returned errors');
      END IF;
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    /*--------------------------------------------------+
     |   Call Service Reverse Distributions             |
     +--------------------------------------------------*/
     ZX_SRVC_TYP_PKG.reverse_distributions(x_return_status   => l_return_status );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_SRVC_TYP_PKG.reverse_distributions returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
     END IF;

     EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO reverse_distributions_PVT;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         --Call API to dump into zx_errors_gt
         DUMP_MSG;
         IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
         END IF;

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO reverse_distributions_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         DUMP_MSG;
         FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
         FND_MSG_PUB.ADD;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count   => x_msg_count,
                                   p_data    => x_msg_data
                                   );
         IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
         END IF;

       WHEN OTHERS THEN
          ROLLBACK TO reverse_distributions_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
          FND_MSG_PUB.ADD;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count   => x_msg_count,
                                   p_data    => x_msg_data
                                   );
          IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;
 END reverse_distributions;

/* ================================================================================*
 | PROCEDURE Reverse_document_distribution: Reverses the base reversing event class|
 | GTT involved : ZX_REV_TRX_HEADERS_GT, ZX_REVERSE_TRX_LINES_GT                   |
 * ================================================================================*/
 PROCEDURE reverse_document_distribution
 ( p_api_version            IN  NUMBER,
   p_init_msg_list          IN  VARCHAR2,
   p_commit                 IN  VARCHAR2,
   p_validation_level       IN  NUMBER,
   x_return_status          OUT NOCOPY VARCHAR2 ,
   x_msg_count              OUT NOCOPY NUMBER ,
   x_msg_data               OUT NOCOPY VARCHAR2
  ) IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'REVERSE_DOCUMENT_DISTRIBUTION';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_event_class_rec             event_class_rec_type;
   l_context_info_rec            context_info_rec_type;
   l_init_msg_list               VARCHAR2(1);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT reverse_doc_distribution_PVT;

  /*--------------------------------------------------+
   |   Standard call to check for call compatibility  |
   +--------------------------------------------------*/
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  /*--------------------------------------------------------------+
   |   Initialize message list if p_init_msg_list is set to TRUE  |
   +--------------------------------------------------------------*/
   IF p_init_msg_list is null THEN
      l_init_msg_list := FND_API.G_FALSE;
   ELSE
      l_init_msg_list := p_init_msg_list;
   END IF;

   IF FND_API.to_Boolean(l_init_msg_list) THEN
     FND_MSG_PUB.initialize;
   END IF;

   /*-----------------------------------------+
   |   Initialize return status to SUCCESS   |
   +-----------------------------------------*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*-----------------------------------------+
   |   Populate Global Variable              |
   +-----------------------------------------*/
   G_PUB_SRVC := l_api_name;
   G_DATA_TRANSFER_MODE := 'TAB';
   G_EXTERNAL_API_CALL  := 'N';

    /*-----------------------------------------+
    | Get the event id for the whole document |
    +-----------------------------------------*/
     select zx_lines_det_factors_s.nextval
      into l_event_class_rec.event_id
      from dual;

  /*------------------------------------------------------+
   |   Validate Input Paramerters and Fetch Tax Options   |
   +------------------------------------------------------*/
   ZX_VALID_INIT_PARAMS_PKG.reverse_document( x_return_status        => l_return_status ,
                                              p_event_class_rec      => l_event_class_rec
                                            );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_VALID_INIT_PARAMS_PKG.reverse_document returned errors');
     END IF;
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;

    /*-----------------------------------------+
     |   Bug 5662795                           |
     +-----------------------------------------*/
     set_ptnr_srvc_subscr_flag (p_event_class_rec => NULL,
                                x_return_status   => l_return_status
                               );

  /*--------------------------------------------------+
   |   Call Service Reverse Document                  |
   +--------------------------------------------------*/
   ZX_SRVC_TYP_PKG.reverse_document( p_event_class_rec => l_event_class_rec,
                                     x_return_status   => l_return_status
                                   );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_SRVC_TYP_PKG.reverse_document returned errors');
     END IF;
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;

  /*------------------------------------------------------+
   |   Validate Input Paramerters and Fetch Tax Options   |
   +------------------------------------------------------*/
   ZX_VALID_INIT_PARAMS_PKG.reverse_distributions(x_return_status  => l_return_status );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_VALID_INIT_PARAMS_PKG.reverse_distributions returned errors');
     END IF;
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;
  /*--------------------------------------------------+
   |   Call Service Reverse Distributions             |
   +--------------------------------------------------*/
   ZX_SRVC_TYP_PKG.reverse_distributions(x_return_status => l_return_status );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_SRVC_TYP_PKG.reverse_distributions returned errors');
     END IF;
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
   END IF;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO reverse_doc_distribution_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        --Call API to dump into zx_errors_gt if not already inserted.
        DUMP_MSG;
        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO reverse_doc_distribution_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        DUMP_MSG;
        FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
        FND_MSG_PUB.ADD;
       /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data
                                  );
        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN OTHERS THEN
        ROLLBACK TO reverse_doc_distribution_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
        FND_MSG_PUB.ADD;
       /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data
                                  );
        IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
        END IF;

 END reverse_document_distribution;

/* =======================================================================*
 | PROCEDURE  determine_recovery : Calculate the distribution of tax amounts
 | into recoverable and/or non-recoverable tax amounts.                   |
 | This API also supports processing for multiple event classes           |
 | GTT involved : ZX_TRX_HEADERS_GT, ZX_ITM_DISTRIBUTIONS_GT              |
 * =======================================================================*/

 PROCEDURE Determine_recovery
  ( p_api_version           IN         NUMBER,
    p_init_msg_list         IN         VARCHAR2,
    p_commit                IN         VARCHAR2,
    p_validation_level      IN         NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2 ,
    x_msg_count             OUT NOCOPY NUMBER ,
    x_msg_data              OUT NOCOPY VARCHAR2
  ) IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'DETERMINE_RECOVERY';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_error_buffer                VARCHAR2(1000);
   l_context_info_rec            context_info_rec_type;
   l_event_class_rec             event_class_rec_type;
   l_transaction_header_rec      transaction_header_rec_type;
   l_index                       BINARY_INTEGER;
   l_precedence                  NUMBER_tbl_type;
   l_init_msg_list               VARCHAR2(1);
   l_event_id                    NUMBER;
   l_related_doc_date            DATE;
   l_adjusted_doc_date           DATE;
   l_trx_date                    DATE;
   l_prov_tax_det_date           DATE;
   l_effective_date              DATE;
   l_call_evnt_cls_options      VARCHAR2(1);
   l_record_dist_lines           VARCHAR2(1);

    CURSOR event_classes IS
     SELECT distinct
           header.event_class_code,
           header.application_id,
           header.entity_code,
           header.internal_organization_id,
           evntmap.processing_precedence
      FROM ZX_EVNT_CLS_MAPPINGS evntmap,
           ZX_TRX_HEADERS_GT header
     WHERE header.application_id = evntmap.application_id
       AND header.entity_code = evntmap.entity_code
       AND header.event_class_code = evntmap.event_class_code
   ORDER BY evntmap.processing_precedence;

   CURSOR headers (p_event_class_code VARCHAR2,
                   p_application_id   NUMBER,
                   p_entity_code      VARCHAR2 ) IS
     SELECT INTERNAL_ORGANIZATION_ID,
            APPLICATION_ID,
            LEGAL_ENTITY_ID,
            ENTITY_CODE,
            EVENT_TYPE_CODE,
            EVENT_CLASS_CODE,
            TRX_ID,
            QUOTE_FLAG,
            ICX_SESSION_ID
       FROM ZX_TRX_HEADERS_GT
      WHERE event_class_code = p_event_class_code
        AND application_id   = p_application_id
        AND entity_code      = p_entity_code
        AND (validation_check_flag is null OR
             validation_check_flag <> 'N');

   -- added for bug fix 5417887
    CURSOR c_headers is
    SELECT APPLICATION_ID, ENTITY_CODE, EVENT_CLASS_CODE, TRX_ID, ICX_SESSION_ID,
           EVENT_TYPE_CODE, TAX_EVENT_TYPE_CODE, DOC_EVENT_STATUS
    FROM ZX_TRX_HEADERS_GT;

    l_application_id_tbl     	NUMBER_tbl_type;
    l_entity_code_tbl    	VARCHAR2_30_tbl_type;
    l_event_class_code_tbl	VARCHAR2_30_tbl_type;
    l_trx_id_tbl		NUMBER_tbl_type;
    l_icx_session_id_tbl	NUMBER_tbl_type;
    l_event_type_code_tbl	VARCHAR2_30_tbl_type;
    l_tax_event_type_code_tbl	VARCHAR2_30_tbl_type;
    l_doc_event_status_tbl	VARCHAR2_30_tbl_type;

    CURSOR check_trx_line_dist_qty
    IS
    SELECT  APPLICATION_ID,
            ENTITY_CODE,
            EVENT_CLASS_CODE,
            TRX_ID,
            TRX_LINE_ID,
            TRX_LEVEL_TYPE
    FROM
            ZX_ITM_DISTRIBUTIONS_GT
    WHERE application_id   = l_event_class_rec.application_id
      AND entity_code      = l_event_class_rec.entity_code
      AND event_class_code = l_event_class_rec.event_class_code
      AND nvl(tax_variance_calc_flag,l_event_class_rec.tax_variance_calc_flag) = 'Y'
      AND ref_doc_application_id is not null
      AND trx_line_dist_qty is null;

-- Bug 5516630: Move unit price validation to determine_recovery

    CURSOR check_trx_line_dist_unit_price
    IS
    SELECT  APPLICATION_ID,
            ENTITY_CODE,
            EVENT_CLASS_CODE,
            TRX_ID,
            TRX_LINE_ID,
            TRX_LEVEL_TYPE
    FROM
            ZX_ITM_DISTRIBUTIONS_GT
    WHERE application_id   = l_event_class_rec.application_id
      AND entity_code      = l_event_class_rec.entity_code
      AND event_class_code = l_event_class_rec.event_class_code
      AND nvl(tax_variance_calc_flag,l_event_class_rec.tax_variance_calc_flag) = 'Y'
      AND ref_doc_application_id is not null
      AND unit_price is null;

   -- This cursor is used to update event info on lines det factors
   CURSOR  c_event_info(c_application_id number,
                        c_entity_code varchar2,
                        c_event_class_code varchar2)
   is
   SELECT
          l_event_id   			EVENT_ID,
          h.EVENT_TYPE_CODE 		EVENT_TYPE_CODE,
          zxevntmap.TAX_EVENT_TYPE_CODE TAX_EVENT_TYPE_CODE,
          zxevnttyp.status_code 	DOC_EVENT_STATUS,
          H.application_id  		application_id,
          H.entity_code  		entity_code,
          h.event_class_code  		event_class_code,
          H.trx_id 			trx_id,
          H.quote_flag                  quote_flag    -- Bug 5646787
   from
          ZX_TRX_HEADERS_GT h,
          ZX_EVNT_TYP_MAPPINGS zxevntmap,
          ZX_EVNT_CLS_TYPS     zxevnttyp
   where
             zxevntmap.event_class_code = h.event_class_code
        AND  zxevntmap.application_id   = h.application_id
        AND  zxevntmap.entity_code      = h.entity_code
        AND  zxevntmap.event_type_code  = h.event_type_code
        AND  zxevnttyp.tax_event_type_code  = zxevntmap.tax_event_type_code
        AND  zxevnttyp.tax_event_class_code = zxevntmap.tax_event_class_code
        AND  zxevntmap.enabled_flag = 'Y'
	    	AND  h.application_id = c_application_id
		    AND  h.entity_code = c_entity_code
		    AND  h.event_class_code = c_event_class_code;


 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

   /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT determine_recovery_PVT;

  /*--------------------------------------------------+
   |   Standard call to check for call compatibility  |
   +--------------------------------------------------*/
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  /*--------------------------------------------------------------+
   |   Initialize message list if p_init_msg_list is set to TRUE  |
   +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
	   l_init_msg_list := p_init_msg_list;
	 END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

  /*-----------------------------------------+
   |   Initialize return status to SUCCESS   |
   +-----------------------------------------*/

   x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*-----------------------------------------+
   |   Populate Global Variable              |
   +-----------------------------------------*/
   G_PUB_SRVC := l_api_name;
   G_DATA_TRANSFER_MODE := 'TAB';
   G_EXTERNAL_API_CALL  := 'N';

   --Call TDS process to initialise distributions for previous calls to determine recovery
   --if any
   ZX_TDS_CALC_SERVICES_PUB_PKG.initialize (p_event_class_rec => NULL,
                                            p_init_level      => 'TAX_DISTRIBUTION',
                                            x_return_status   => l_return_status
                                            );

    l_call_evnt_cls_options := 'Y';

    /*-----------------------------------------+
    | Get the event id for the whole document |
    +-----------------------------------------*/
     --Bug 7650433
     --select ZX_LINES_DET_FACTORS_S.nextval
     --into l_event_id
     --from dual;

  /*------------------------------------------------+
   |  Update zx_lines_det_factors                   |
   +------------------------------------------------*/

   --FOR c_rec in c_event_info loop
   --   IF c_rec.quote_flag <> 'Y' THEN     -- Bug 5646787
   --
   --      UPDATE ZX_LINES_DET_FACTORS  D
   --         SET  EVENT_ID = c_rec.EVENT_ID,
   --              EVENT_TYPE_CODE  = c_rec.EVENT_TYPE_CODE,
   --              TAX_EVENT_TYPE_CODE = c_rec.TAX_EVENT_TYPE_CODE,
   --              DOC_EVENT_STATUS = c_rec.DOC_EVENT_STATUS
   --      WHERE
   --        D.APPLICATION_ID = c_rec.application_id
   --        AND D.ENTITY_CODE = c_rec.ENTITY_CODE
   --        AND D.EVENT_CLASS_CODE = c_rec.EVENT_CLASS_CODE
   --        AND D.TRX_ID = c_rec.TRX_ID;
   --   END IF;
   --END LOOP;

   OPEN event_classes;
     LOOP
       FETCH event_classes BULK COLLECT INTO
          l_evnt_cls.event_class_code,
          l_evnt_cls.application_id,
          l_evnt_cls.entity_code,
          l_evnt_cls.internal_organization_id,
          l_evnt_cls.precedence
       LIMIT G_LINES_PER_FETCH;
     EXIT WHEN event_classes%NOTFOUND;
     END LOOP;
   CLOSE event_classes;

   --Event classes such as SALES_TRANSACTION_TAX_QUOTE/PURCHASE_TRANSACTION_TAX_QUOTE
   --are not seeded in zx_evnt_cls_mappings so cursor event classes will not
   --return any rows for such event classes passed. This flag to keep track of this
   IF l_evnt_cls.event_class_code.LAST is null THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
           'Event class information does not exist - indicates SALES_TRANSACTION_TAX_QUOTE/PURCHASE_TRANSACTION_TAX_QUOTE');
     END IF;
     SELECT event_class_code,
            application_id,
            internal_organization_id,
            entity_code
       INTO l_evnt_cls.event_class_code(1),
            l_evnt_cls.application_id(1),
            l_evnt_cls.internal_organization_id(1),
            l_evnt_cls.entity_code(1)
       FROM ZX_TRX_HEADERS_GT
       WHERE rownum=1;
   END IF;

   /*-----------------------------------------+
   |   Loop for each transaction header      |
   +-----------------------------------------*/
   FOR i IN 1..nvl(l_evnt_cls.event_class_code.LAST,0)
     LOOP
      --Bug 7650433
      select ZX_LINES_DET_FACTORS_S.nextval
      into l_event_id
      from dual;

      FOR c_rec in c_event_info(l_evnt_cls.application_id(i),
                                l_evnt_cls.entity_code(i),
                                l_evnt_cls.event_class_code(i)) loop
        IF c_rec.quote_flag <> 'Y' THEN     -- Bug 5646787
         UPDATE ZX_LINES_DET_FACTORS  D
            SET  EVENT_ID = c_rec.EVENT_ID,
                 EVENT_TYPE_CODE  = c_rec.EVENT_TYPE_CODE,
                 TAX_EVENT_TYPE_CODE = c_rec.TAX_EVENT_TYPE_CODE,
                 DOC_EVENT_STATUS = c_rec.DOC_EVENT_STATUS
         WHERE
           D.APPLICATION_ID = c_rec.application_id
           AND D.ENTITY_CODE = c_rec.ENTITY_CODE
           AND D.EVENT_CLASS_CODE = c_rec.EVENT_CLASS_CODE
           AND D.TRX_ID = c_rec.TRX_ID;
        END IF;
      END LOOP;
      l_event_class_rec.event_id := l_event_id;
      l_event_class_rec.INTERNAL_ORGANIZATION_ID     :=  l_evnt_cls.INTERNAL_ORGANIZATION_ID(i);
      l_event_class_rec.APPLICATION_ID               :=  l_evnt_cls.APPLICATION_ID(i);
      l_event_class_rec.ENTITY_CODE                  :=  l_evnt_cls.ENTITY_CODE(i);
      l_event_class_rec.EVENT_CLASS_CODE             :=  l_evnt_cls.EVENT_CLASS_CODE(i);

       ZX_TRD_SERVICES_PUB_PKG.g_variance_calc_flag := 'N';

       /*------------------------------------------------------+
       |   Validate Input Paramerters and Fetch Tax Options   |
       +------------------------------------------------------*/
       ZX_VALID_INIT_PARAMS_PKG.determine_recovery(x_return_status   =>l_return_status,
                                                   p_event_class_rec =>l_event_class_rec
                                                  );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_VALID_INIT_PARAMS_PKG.determine_recovery returned errors');
         END IF;
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
       END IF;

       select  ICX_SESSION_ID,QUOTE_FLAG
       INTO l_event_class_rec.ICX_SESSION_ID,l_event_class_rec.QUOTE_FLAG
       FROM ZX_TRX_HEADERS_GT
       where rownum = 1;

       IF l_event_class_rec.QUOTE_FLAG = 'Y' and
         l_event_class_rec.ICX_SESSION_ID is not null THEN
         ZX_SECURITY.G_ICX_SESSION_ID := l_event_class_rec.ICX_SESSION_ID;
         ZX_SECURITY.name_value('SESSIONID',to_char(ZX_SECURITY.G_ICX_SESSION_ID));
         -- dbms_session.set_context('my_ctx','SESSIONID',to_char(ZX_SECURITY.G_ICX_SESSION_ID));

       ELSE
         ZX_SECURITY.G_ICX_SESSION_ID := null;
         ZX_SECURITY.name_value('SESSIONID',to_char(ZX_SECURITY.G_ICX_SESSION_ID));
         --dbms_session.set_context('my_ctx','SESSIONID',to_char(ZX_SECURITY.G_ICX_SESSION_ID));

      END IF;

      -- Check if trx line dist qty is passed when variance calc flag is 'Y'

           FOR invalid_rec IN check_trx_line_dist_qty
           LOOP

            --  x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('ZX','ZX_TRX_LINE_DIST_QTY_REQD');
              l_context_info_rec.APPLICATION_ID   := invalid_rec.APPLICATION_ID;
              l_context_info_rec.ENTITY_CODE      := invalid_rec.ENTITY_CODE;
              l_context_info_rec.EVENT_CLASS_CODE := invalid_rec.EVENT_CLASS_CODE;
              l_context_info_rec.TRX_ID           := invalid_rec.TRX_ID;
              ZX_API_PUB.add_msg( p_context_info_rec =>l_context_info_rec );
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Transaction line distribution quantity is required');
              END IF;
          END LOOP;

      -- Check if trx line dist unit price is passed when variance calc flag is 'Y'

           FOR invalid_rec IN check_trx_line_dist_unit_price
           LOOP

            --  x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('ZX','ZX_UNIT_PRICE_REQD');
              l_context_info_rec.APPLICATION_ID   := invalid_rec.APPLICATION_ID;
              l_context_info_rec.ENTITY_CODE      := invalid_rec.ENTITY_CODE;
              l_context_info_rec.EVENT_CLASS_CODE := invalid_rec.EVENT_CLASS_CODE;
              l_context_info_rec.TRX_ID           := invalid_rec.TRX_ID;
              ZX_API_PUB.add_msg( p_context_info_rec =>l_context_info_rec );
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Transaction line distribution unit price is required');
              END IF;
          END LOOP;


       OPEN headers(l_evnt_cls.event_class_code(i),
                    l_evnt_cls.application_id(i),
                    l_evnt_cls.entity_code(i)
                   );
       LOOP
         FETCH headers BULK COLLECT INTO
           l_transaction_header_rec.INTERNAL_ORGANIZATION_ID,
           l_transaction_header_rec.APPLICATION_ID,
           l_transaction_header_rec.LEGAL_ENTITY_ID,
           l_transaction_header_rec.ENTITY_CODE,
           l_transaction_header_rec.EVENT_TYPE_CODE,
           l_transaction_header_rec.EVENT_CLASS_CODE,
           l_transaction_header_rec.TRX_ID,
           l_transaction_header_rec.QUOTE_FLAG,
           l_transaction_header_rec.ICX_SESSION_ID
         LIMIT G_LINES_PER_FETCH;

         FOR l_index IN 1..nvl(l_transaction_header_rec.application_id.LAST,0)
         LOOP
           BEGIN
             SAVEPOINT Determine_Recovery_Hdr_PVT;
             --Copy to event class record
             l_event_class_rec.INTERNAL_ORGANIZATION_ID :=  l_transaction_header_rec.INTERNAL_ORGANIZATION_ID(l_index);
             l_event_class_rec.APPLICATION_ID           :=  l_transaction_header_rec.APPLICATION_ID(l_index);
             l_event_class_rec.LEGAL_ENTITY_ID          :=  l_transaction_header_rec.LEGAL_ENTITY_ID(l_index);
             l_event_class_rec.ENTITY_CODE              :=  l_transaction_header_rec.ENTITY_CODE(l_index);
             l_event_class_rec.EVENT_CLASS_CODE         :=  l_transaction_header_rec.EVENT_CLASS_CODE(l_index);
             l_event_class_rec.EVENT_TYPE_CODE          :=  l_transaction_header_rec.EVENT_TYPE_CODE(l_index);
             l_event_class_rec.TRX_ID                   :=  l_transaction_header_rec.TRX_ID(l_index);
             l_event_class_rec.ICX_SESSION_ID           :=  l_transaction_header_rec.ICX_SESSION_ID(l_index);
             l_event_class_rec.QUOTE_FLAG               :=  l_transaction_header_rec.QUOTE_FLAG(l_index);


              /* ----------------------------------------------------------------------+
              | Bug 3129063 - Setting the Security Context for Subscription           |
              + ----------------------------------------------------------------------*/
              ZX_VALID_INIT_PARAMS_PKG.get_tax_subscriber
                                (l_event_class_rec,
                                 l_return_status);

             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               --DUMP_MSG;
               x_return_status := l_return_status;
               IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
             END IF;


             /* ----------------------------------------------------------------------+
             |      Get Tax Event Type                                               |
             + ----------------------------------------------------------------------*/
             ZX_VALID_INIT_PARAMS_PKG.get_tax_event_type (l_return_status
                                ,l_event_class_rec.event_class_code
                                ,l_event_class_rec.application_id
                                ,l_event_class_rec.entity_code
                                ,l_event_class_rec.event_type_code
                                ,l_event_class_rec.tax_event_class_code
                                ,l_event_class_rec.tax_event_type_code
                                ,l_event_class_rec.doc_status_code
                               );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              x_return_status := l_return_status;
              --DUMP_MSG;
              IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
              ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            END IF;
           -- Bug 6135079, SDSU - enforce_tax_from_ref_doc should be picked up from event class instead of event mappings
           -- This can be achieved by calling populate_event_class_options as we have done it in calculate_tax

          BEGIN
             BEGIN
                SELECT first_pty_org_id ,
                       related_doc_date,
         	             adjusted_doc_date,
         	             trx_date,
         	             provnl_tax_determination_date
                INTO   l_event_class_rec.first_pty_org_id,
  		                 l_related_doc_date,
  		                 l_adjusted_doc_date,
  		                 l_trx_date,
  		                 l_prov_tax_det_date
  		          FROM   ZX_LINES_DET_FACTORS
  		          WHERE  application_id   = l_event_class_rec.application_id
  		            AND  entity_code      = l_event_class_rec.entity_code
  		            AND  event_class_code = l_event_class_rec.event_class_code
  		            AND  trx_id           = l_event_class_rec.trx_id
  		            AND  rownum           = 1;
            EXCEPTION
               when no_data_found then
                 l_call_evnt_cls_options := 'N';
            END;

            l_effective_date := determine_effective_date (l_trx_date,
                                                          l_related_doc_date,
     		                                                  l_adjusted_doc_date,
                                                          l_prov_tax_det_date
		   			                                             );
            EXCEPTION
	     WHEN OTHERS THEN
	       l_effective_date := SYSDATE;
	     END;
	    /* ----------------------------------------------------------------------+
            |      Populate Event Class Options                                     |
            + ----------------------------------------------------------------------*/
        IF l_call_evnt_cls_options = 'Y' THEN
            ZX_VALID_INIT_PARAMS_PKG.populate_event_class_options(l_return_status,
                              l_effective_date,
                              l_event_class_rec
                             );
        END IF;

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             x_return_status := l_return_status;
             --DUMP_MSG;
             IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
            END IF;

            ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := l_event_class_rec;

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                'application_id: '||to_char(l_event_class_rec.application_id)||
                ' entity_code: '||l_event_class_rec.entity_code||
                ' event_class_code: '||l_event_class_rec.event_class_code||
                ' event_type_code: '||l_event_class_rec.event_type_code||
                ' trx_id: '||to_char(l_event_class_rec.trx_id)||
                ' internal_organization_id: '||to_char(l_event_class_rec.internal_organization_id)||
                ' quote_flag: '||to_char(l_event_class_rec.quote_flag)||
                ' icx_session_id: '||to_char(l_event_class_rec.icx_session_id));
             END IF;


            /* ===============================================================================*
            |Initialize the global structures/global temp tables owned by TDM at header level |
            * =============================================================================*/
             ZX_TDS_CALC_SERVICES_PUB_PKG.initialize (l_event_class_rec ,
                                                      'HEADER',
                                                      l_return_status
                                                     );

             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TDS_CALC_SERVICES_PUB_PKG.initialize  returned errors');
               END IF;
               IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
             END IF;

             ZX_GLOBAL_STRUCTURES_PKG.rec_nrec_ccid_tbl.DELETE;
            /*--------------------------------------------------+
             |   Call Service Type Determine Recovery           |
             +--------------------------------------------------*/
             ZX_SRVC_TYP_PKG.determine_recovery(p_event_class_rec    => l_event_class_rec,
                                                x_return_status      => l_return_status
                                               );

             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_SRVC_TYP_PKG.determine_recovery  returned errors');
               END IF;
               IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
             END IF;

             EXCEPTION
               WHEN FND_API.G_EXC_ERROR THEN
                 ROLLBACK TO Determine_Recovery_Hdr_PVT;
                 x_return_status := FND_API.G_RET_STS_ERROR ;
                 --Call API to dump into zx_errors_gt
                 DUMP_MSG;
                 IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
                 END IF;
             END;
         END LOOP; --end loop for transaction headers
         EXIT WHEN headers%NOTFOUND;
        END LOOP;
      CLOSE headers;

       -- bug fix 3313938: add tax_variance_calc_flag check.
       --
       IF ZX_TRD_SERVICES_PUB_PKG.g_variance_calc_flag = 'Y' THEN

         ZX_TRD_INTERNAL_SERVICES_PVT.calc_variance_factors(
                  l_return_status,
                  l_error_buffer);

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           IF (g_level_statement >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_statement,
                           G_MODULE_NAME||l_api_name,
                           'After calling calc_variance_factors ' ||
                           ' l_return_status = ' || l_return_status);
             FND_LOG.STRING(g_level_statement,
                           G_MODULE_NAME||l_api_name,
                           'ZX_API_PUB.DETERMINE_RECOVERY(-)');
           END IF;
          --DUMP_MSG;
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
         END IF;
       END IF;


    -- Bug fix 5417887 begin

   /*--------------------------------------------------+
    |   Call to eTax Service Manage Tax Distributions  |
    +--------------------------------------------------*/
   /*-----------------------------------------------------------------+
    | Bug 3649502 - Check for record flag before calling TRR service  |
    +----------------------------------------------------------------*/
    --IF zx_global_structures_pkg.g_event_class_rec.record_flag = 'Y' THEN

    l_record_dist_lines := ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.record_flag;

    IF zx_global_structures_pkg.g_event_class_rec.record_flag = 'Y' and
       ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.quote_flag = 'Y' THEN
       l_record_dist_lines := 'N';
    END IF;

    IF l_record_dist_lines = 'Y' THEN
      ZX_TRL_PUB_PKG.manage_taxdistributions(x_return_status    =>l_return_status,
                                             p_event_class_rec  =>zx_global_structures_pkg.g_event_class_rec
                                            );
    END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TRL_PUB_PKG.manage_taxdistributions  returned errors');
      END IF;
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        --DUMP_MSG;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    -- Bug fix 7506576 Included additional condition flag quote_flag when
    -- deleting records from GT TABLES

    --IF zx_global_structures_pkg.g_event_class_rec.record_flag = 'Y'  AND ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.quote_flag = 'N'

    --Reimplemented the fix done in bug#7506576
    IF l_record_dist_lines = 'Y' THEN
       DELETE FROM ZX_REC_NREC_DIST_GT;
    END IF;

 END LOOP;--event_classes cursor

    /*------------------------------------------------+
     |  Update zx_lines_det_factors                   |
     +------------------------------------------------*/

     IF zx_global_structures_pkg.g_event_class_rec.quote_flag <> 'Y'  OR
        zx_global_structures_pkg.g_event_class_rec.ICX_SESSION_ID is not null
     THEN

       -- ICX_SESSION_ID / QUOTE_FLAG should be same for all rows
      IF zx_global_structures_pkg.g_event_class_rec.ICX_SESSION_ID is not null THEN

       BEGIN
        OPEN C_HEADERS;
        LOOP
           FETCH c_HEADERS BULK COLLECT INTO
               l_application_id_tbl,
               l_entity_code_tbl,
               l_event_class_code_tbl,
               l_trx_id_tbl,
               l_icx_session_id_tbl,
               l_event_type_code_tbl,
               l_tax_event_type_code_tbl,
               l_doc_event_status_tbl
           LIMIT G_LINES_PER_FETCH;


              /*------------------------------------------------------------------------------+
               |  Bug 4948674: Handle delete for P2P products when icx_session_id is NOT NULL |
               +------------------------------------------------------------------------------*/

              FORALL i IN l_application_id_tbl.FIRST .. l_application_id_tbl.LAST
                DELETE from zx_lines_det_factors
		            WHERE APPLICATION_ID   = l_application_id_tbl(i)
                 AND ENTITY_CODE       = l_entity_code_tbl(i)
                 AND EVENT_CLASS_CODE  = l_event_class_code_tbl(i)
                 AND TRX_ID            = l_trx_id_tbl(i)
                 AND ICX_SESSION_ID    = l_icx_session_id_tbl(i);

           exit when c_HEADERS%NOTFOUND;
        END LOOP;

        close c_HEADERS;
      EXCEPTION
         WHEN OTHERS THEN

           IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TRL_PUB_PKG.manage_taxdistributions  returned errors');
                FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name, SQLCODE||' ; '||SQLERRM);
           END IF;

           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
           FND_MSG_PUB.Add;

           IF  c_HEADERS%ISOPEN THEN
                 close c_HEADERS;
           END IF;
       END;
     END IF; -- icx_session_id


    END IF;

    -- Bug fix 5417887 end

    --Reset the icx_session_id at end of API
    ZX_SECURITY.G_ICX_SESSION_ID := null;
    ZX_SECURITY.name_value('SESSIONID',to_char(ZX_SECURITY.G_ICX_SESSION_ID));
    -- dbms_session.set_context('my_ctx','SESSIONID',to_char(ZX_SECURITY.G_ICX_SESSION_ID));


    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
    END IF;

    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO Determine_Recovery_PVT;
         --Close all open cursors
         IF headers%ISOPEN THEN CLOSE headers; END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         DUMP_MSG;
         IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
         END IF;

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO Determine_Recovery_PVT;
         --Close all open cursors
         IF headers%ISOPEN THEN CLOSE headers; END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         DUMP_MSG;
         FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
         FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count  => x_msg_count,
                                   p_data   => x_msg_data
                                   );
         IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
         END IF;

       WHEN OTHERS THEN
          ROLLBACK TO Determine_Recovery_PVT;
          --Close all open cursors
          IF headers%ISOPEN THEN CLOSE headers; END IF;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
          FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count  => x_msg_count,
                                   p_data   => x_msg_data
                                   );
          IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;

 END determine_recovery;

/* =======================================================================*
 | PROCEDURE  override_recovery :Overrides the tax recovery rate code     |
 * =======================================================================*/

 PROCEDURE Override_recovery
 ( p_api_version           IN            NUMBER,
   p_init_msg_list         IN            VARCHAR2,
   p_commit                IN            VARCHAR2,
   p_validation_level      IN            NUMBER,
   x_return_status         OUT    NOCOPY VARCHAR2 ,
   x_msg_count             OUT    NOCOPY NUMBER ,
   x_msg_data              OUT    NOCOPY VARCHAR2,
   p_transaction_rec       IN OUT NOCOPY transaction_rec_type
 ) IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'OVERRIDE_RECOVERY';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_event_class_rec             event_class_rec_type;
   l_trans_rec                   transaction_rec_type;
   l_init_msg_list               VARCHAR2(1);
   l_record_dist_lines           VARCHAR2(1);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

   /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT override_recovery_PVT;

  /*--------------------------------------------------+
   |   Standard call to check for call compatibility  |
   +--------------------------------------------------*/
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                      ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  /*--------------------------------------------------------------+
   |   Initialize message list if p_init_msg_list is set to TRUE  |
   +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
	   l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

  /*-----------------------------------------+
   |   Initialize return status to SUCCESS   |
   +-----------------------------------------*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*-----------------------------------------+
   |   Populate Global Variable              |
   +-----------------------------------------*/
   G_PUB_SRVC := l_api_name;
   G_DATA_TRANSFER_MODE := 'PLS';
   G_EXTERNAL_API_CALL  := 'N';

   --Call TDS process to initialise distributions for previous calls to determine recovery
   --if any
   ZX_TDS_CALC_SERVICES_PUB_PKG.initialize (p_event_class_rec => NULL,
                                            p_init_level      => 'TAX_DISTRIBUTION',
                                            x_return_status   => l_return_status
                                            );
  /*------------------------------------------------------+
   |   Validate Input Paramerters and Fetch Tax Options   |
   +------------------------------------------------------*/
   ZX_VALID_INIT_PARAMS_PKG.override_recovery(x_return_status   => l_return_status,
                                              p_event_class_rec => l_event_class_rec,
                                              p_trx_rec         => p_transaction_rec
                                             );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_VALID_INIT_PARAMS_PKG.override_recovery returned errors');
     END IF;
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;

  /*--------------------------------------------------+
   |   Call Service Type Override Recovery            |
   +--------------------------------------------------*/
   ZX_SRVC_TYP_PKG.override_recovery(p_event_class_rec    => l_event_class_rec,
                                     x_return_status      => l_return_status
                                    );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_SRVC_TYP_PKG.override_recovery returned errors');
     END IF;
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;

  /*--------------------------------------------------+
   |   Call to eTax Service Manage Tax Distributions  |
   +--------------------------------------------------*/
   --IF l_event_class_rec.record_flag = 'Y' THEN

   l_record_dist_lines := l_event_class_rec.record_flag;

   IF l_event_class_rec.record_flag = 'Y' and
      l_event_class_rec.quote_flag = 'Y' THEN
      l_record_dist_lines := 'N';
   END IF;
   IF l_record_dist_lines = 'Y' THEN
     ZX_TRL_PUB_PKG.manage_taxdistributions(x_return_status    => l_return_status,
                                            p_event_class_rec  => l_event_class_rec
                                           );
   END IF;

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TRL_PUB_PKG.manage_taxdistributions returned errors');
     END IF;
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
   END IF;

    /* Bug 3704651 - No need to uptake error handling as it is a PLS API*/
    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO override_recovery_PVT;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         DUMP_MSG;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count   => x_msg_count,
                                   p_data    => x_msg_data
                                   );
         IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
         END IF;

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO override_recovery_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         DUMP_MSG;
         FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
         FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count   => x_msg_count,
                                   p_data    => x_msg_data
                                   );
         IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
         END IF;

       WHEN OTHERS THEN
         /*-------------------------------------------------------+
          |  Handle application errors that result from trapable  |
          |  error conditions. The error messages have already    |
          |  been put on the error stack.                         |
          +-------------------------------------------------------*/
          ROLLBACK TO override_recovery_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
          FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                    p_count  => x_msg_count,
                                    p_data   => x_msg_data
                                    );
          IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;
 END override_recovery;


 /* =======================================================================*
 | PROCEDURE  freeze_tax_distributions :                                  |
 * =======================================================================*/

 PROCEDURE freeze_tax_distributions
 ( p_api_version           IN            NUMBER,
   p_init_msg_list         IN            VARCHAR2,
   p_commit                IN            VARCHAR2,
   p_validation_level      IN            NUMBER,
   x_return_status         OUT NOCOPY    VARCHAR2 ,
   x_msg_count             OUT NOCOPY    NUMBER ,
   x_msg_data              OUT NOCOPY    VARCHAR2,
   p_transaction_rec       IN OUT NOCOPY transaction_rec_type
 ) IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'FREEZE_TAX_DISTRIBUTIONS';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_event_class_rec             event_class_rec_type;
   l_init_msg_list               VARCHAR2(1);

CURSOR get_event_class_info
IS
SELECT dist.application_id,
       dist.entity_code,
       dist.event_class_code,
       evnttyp.event_type_code,
       dist.tax_event_class_code,
       'UPDATE' tax_event_type_code,
       'UPDATED' doc_status_code,
       evntcls.summarization_flag,
       evntcls.retain_summ_tax_line_id_flag
 FROM zx_rec_nrec_dist dist,
      zx_evnt_cls_mappings evntcls,
      zx_evnt_typ_mappings evnttyp,
      zx_tax_dist_id_gt distgt
 WHERE dist.application_id = evntcls.application_id
   AND dist.entity_code = evntcls.entity_code
   AND dist.event_class_code = evntcls.event_class_code
   AND evnttyp.application_id = evntcls.application_id
   AND evnttyp.entity_code = evntcls.entity_code
   AND evnttyp.event_class_code = evntcls.event_class_code
   AND evnttyp.tax_event_type_code = 'UPDATE'
   AND dist.REC_NREC_TAX_DIST_ID = distgt.tax_dist_id;


 BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT FREEZE_TAX_DISTRIBUTIONS_PVT;

  /*--------------------------------------------------+
   |   Standard call to check for call compatibility  |
   +--------------------------------------------------*/
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                      ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  /*--------------------------------------------------------------+
   |   Initialize message list if p_init_msg_list is set to TRUE  |
   +--------------------------------------------------------------*/
   IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
   ELSE
       l_init_msg_list := p_init_msg_list;
   END IF;

   IF FND_API.to_Boolean(l_init_msg_list) THEN
     FND_MSG_PUB.initialize;
   END IF;

  /*-----------------------------------------+
   |   Initialize return status to SUCCESS   |
   +-----------------------------------------*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*-----------------------------------------+
   |   Populate Global Variable              |
   +-----------------------------------------*/
   G_PUB_SRVC := l_api_name;
   G_DATA_TRANSFER_MODE := 'PLS';
   G_EXTERNAL_API_CALL  := 'N';

  /*-----------------------------------------------------+
   |   Validate Input Parameters and Fetch Tax Options   |
   +-----------------------------------------------------*/
-- Bug 5580045 - Commented out the call to valid intit package so that necessary
-- information can be retrieved for BULK processing
/*
   ZX_VALID_INIT_PARAMS_PKG.freeze_distribution_lines(x_return_status   => l_return_status,
                                                      p_event_class_rec => l_event_class_rec,
                                                      p_trx_rec         => p_transaction_rec
                                                     );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_VALID_INIT_PARAMS_PKG.freeze_distribution_lines returned errors');
     END IF;
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;
*/

-- Get Event Class Info.

     OPEN get_event_class_info;
     FETCH get_event_class_info INTO
             l_event_class_rec.APPLICATION_ID,
             l_event_class_rec.ENTITY_CODE,
             l_event_class_rec.EVENT_CLASS_CODE,
             l_event_class_rec.EVENT_TYPE_CODE,
             l_event_class_rec.TAX_EVENT_CLASS_CODE,
             l_event_class_rec.TAX_EVENT_TYPE_CODE,
             l_event_class_rec.DOC_STATUS_CODE,
             l_event_class_rec.summarization_flag,
             l_event_class_rec.retain_summ_tax_line_id_flag;

     IF get_event_class_info%notfound THEN

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN

          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_api_name, G_PKG_NAME||':'||l_api_name
                        ||': Event Class Info not retreived');
      END IF;

     END IF;

     CLOSE get_event_class_info;

-- Begin Bug fix 5552750: Stamp event_id for only trx lines for which
--                        tax distributions are being frozen

   /*-----------------------------------------+
    | Get the event id for the whole document |
    +-----------------------------------------*/
    select ZX_LINES_DET_FACTORS_S.nextval
    into l_event_class_rec.event_id
    from dual;

  /*------------------------------------------------+
   |  Update zx_lines_det_factors                   |
   +------------------------------------------------*/

   UPDATE ZX_LINES_DET_FACTORS
     SET EVENT_TYPE_CODE     = l_event_class_rec.event_type_code,
         TAX_EVENT_TYPE_CODE = l_event_class_rec.tax_event_type_code,
         EVENT_ID            = l_event_class_rec.event_id,
         DOC_EVENT_STATUS    = l_event_class_rec.doc_status_code
   WHERE APPLICATION_ID    = p_transaction_rec.APPLICATION_ID
     AND ENTITY_CODE       = p_transaction_rec.ENTITY_CODE
     AND EVENT_CLASS_CODE  = p_transaction_rec.EVENT_CLASS_CODE
--     AND TRX_ID            = p_transaction_rec.TRX_ID
     AND (TRX_ID,TRX_LINE_ID,TRX_LEVEL_TYPE) IN (Select dist.trx_id, dist.trx_line_id,
                             dist.trx_level_type from zx_rec_nrec_dist dist,
                             zx_tax_dist_id_gt zxgt
                            where dist.rec_nrec_tax_dist_id = zxgt.tax_dist_id);

-- End Bug fix 5552750

  /*--------------------------------------------------+
   |   Call Service Type Freeze Distribution Lines    |
   +--------------------------------------------------*/
   ZX_SRVC_TYP_PKG.freeze_distribution_lines(x_return_status   => l_return_status,
                                             p_event_class_rec => l_event_class_rec
                                            );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_SRVC_TYP_PKG.freeze_distribution_lines returned errors');
     END IF;
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;


   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
   END IF;

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO FREEZE_TAX_DISTRIBUTIONS_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       DUMP_MSG;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count       =>      x_msg_count,
                                 p_data        =>      x_msg_data
                                 );

       IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
       END IF;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO FREEZE_TAX_DISTRIBUTIONS_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       DUMP_MSG;
       FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
       FND_MSG_PUB.Add;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count       =>      x_msg_count,
                                 p_data        =>      x_msg_data
                                 );
       IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
       END IF;

     WHEN OTHERS THEN
       ROLLBACK TO FREEZE_TAX_DISTRIBUTIONS_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
       FND_MSG_PUB.Add;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count       =>      x_msg_count,
                                 p_data        =>      x_msg_data
                                );
      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
 END freeze_tax_distributions;

/* ======================================================================*
 | PROCEDURE get_tax_distribution_ccids : Products call this API if they |
 |                                        need to determine the code     |
 |                                        combination identifiers for    |
 |                                        tax liability and tax recovery/|
 |                                        nonrecovery accounts           |
 | There exists only the pl/sql version of the API                       |
 * ======================================================================*/
 PROCEDURE get_tax_distribution_ccids
 ( p_api_version             IN            NUMBER,
   p_init_msg_list           IN            VARCHAR2,
   p_commit                  IN            VARCHAR2,
   p_validation_level        IN            NUMBER,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2,
   p_dist_ccid_rec           IN OUT NOCOPY distccid_det_facts_rec_type
  ) IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'GET_TAX_DISTRIBUTION_CCIDS';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_init_msg_list               VARCHAR2(1);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

    /*--------------------------------------------------+
    |   Standard start of API savepoint                |
    +--------------------------------------------------*/
    SAVEPOINT Get_Tax_Distribution_ccids_PVT;

    /*-----------------------------------------+
     |   Initialize return status to SUCCESS   |
     +-----------------------------------------*/

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*--------------------------------------------------+
     |   Standard call to check for call compatibility  |
     +--------------------------------------------------*/
     IF NOT FND_API.Compatible_API_Call( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME
                                        ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
       l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

     /*-----------------------------------------+
      |   Populate Global Variable              |
      +-----------------------------------------*/
      G_PUB_SRVC := l_api_name;
      G_DATA_TRANSFER_MODE := 'PLS';
      G_EXTERNAL_API_CALL  := 'N';

      /*---------------------------------------------+
      |   Missing Gl Date                           |
      +---------------------------------------------*/
      IF p_dist_ccid_rec.gl_date is NULL THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
          'GL date of tax distribution is required');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     /*---------------------------------------------+
      |   Missing Tax Rate Id                       |
      +---------------------------------------------*/
      IF p_dist_ccid_rec.tax_rate_id is NULL THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
          'Tax rate ID of tax distribution is required');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     /*---------------------------------------------+
      |   Missing Rec Rate Id                       |
      +---------------------------------------------*/
      IF p_dist_ccid_rec.recoverable_flag = 'Y' and
         p_dist_ccid_rec.rec_rate_id is NULL THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
          'Recovery rate ID of tax distribution is required');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     /*---------------------------------------------+
      |   Missing Self Assessed Flag                |
      +---------------------------------------------*/

      IF p_dist_ccid_rec.self_assessed_flag is NULL THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
          'Self-assessed flag of tax distribution is required');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     /*---------------------------------------------+
      |   Missing Recoverable Flag                  |
      +---------------------------------------------*/

      IF p_dist_ccid_rec.recoverable_flag is NULL THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
          'Recoverable flag of tax distribution is required');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     /*---------------------------------------------+
      |   Missing Tax Jurisdiction Id               |
      +---------------------------------------------*/

      /*IF p_dist_ccid_rec.tax_jurisdiction_id is NULL THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
          'Tax jurisdiction ID of tax distribution is required');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      */

     /*---------------------------------------------+
      |   Missing Tax Regime Id                     |
      +---------------------------------------------*/

      IF p_dist_ccid_rec.tax_regime_id is NULL THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
          'Tax regime ID of tax distribution is required');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     /*---------------------------------------------+
      |   Missing Tax Id                            |
      +---------------------------------------------*/

      IF p_dist_ccid_rec.tax_id is NULL THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
          'Tax id of tax distribution is required');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     /*---------------------------------------------+
      |   Missing Tax Status Id                     |
      +---------------------------------------------*/

      IF p_dist_ccid_rec.tax_status_id is NULL THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
          'Tax status ID of tax distribution is required');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     /*---------------------------------------------+
      |   Missing Org Id                            |
      +---------------------------------------------*/

      IF p_dist_ccid_rec.internal_organization_id is NULL THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
          'Operating Unit is required');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     /*---------------------------------------------+
      |   Missing Revenue Expense CCID              |
      +---------------------------------------------*/

      IF p_dist_ccid_rec.revenue_expense_ccid is NULL THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
          'Revenue account of tax distribution is required');
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      /*-----------------------------------------+
       |   Get CCID                              |
       +-----------------------------------------*/
       ZX_TRD_SERVICES_PUB_PKG.get_ccid(p_gl_date              => p_dist_ccid_rec.gl_date,
                                        p_tax_rate_id          => p_dist_ccid_rec.tax_rate_id,
                                        p_rec_rate_id          => p_dist_ccid_rec.rec_rate_id,
                                        p_Self_Assessed_Flag   => p_dist_ccid_rec.self_assessed_flag,
                                        p_Recoverable_Flag     => p_dist_ccid_rec.recoverable_flag,
                                        p_tax_jurisdiction_id  => p_dist_ccid_rec.tax_jurisdiction_id,
                                        p_tax_regime_id        => p_dist_ccid_rec.tax_regime_id,
                                        p_tax_id               => p_dist_ccid_rec.tax_id,
                                        p_tax_status_id        => p_dist_ccid_rec.tax_status_id,
                                        p_org_id               => p_dist_ccid_rec.internal_organization_id,
                                        p_revenue_expense_ccid => p_dist_ccid_rec.revenue_expense_ccid,
                                        p_ledger_id            => p_dist_ccid_rec.ledger_id,
        				p_account_source_tax_rate_id  => p_dist_ccid_rec.account_source_tax_rate_id,
        				p_rec_nrec_tax_dist_id => p_dist_ccid_rec.rec_nrec_tax_dist_id,
                                        p_rec_nrec_ccid        => p_dist_ccid_rec.rec_nrec_ccid,
                                        p_tax_liab_ccid        => p_dist_ccid_rec.tax_liab_ccid,
                                        x_return_status        => l_return_status
                                        );


       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TRD_SERVICES_PUB_PKG.get_ccid returned errors');
         END IF;
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
       ELSE
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
             'Recovery/NonRecovery CCID : ' ||
              to_char(p_dist_ccid_rec.revenue_expense_ccid) ||
             'Tax liability CCID : ' ||
             to_char(p_dist_ccid_rec.tax_liab_ccid) ||
             'Revenue CCID : ' ||
             to_char(p_dist_ccid_rec.tax_liab_ccid)
             );
           END IF;
         END IF;

       IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
       END IF;

     /* Bug 3704651 - No need to uptake error handling as it is a PLS API*/
       EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO Get_Tax_Distribution_Ccids_PVT;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         DUMP_MSG;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count   =>      x_msg_count,
                                   p_data    =>      x_msg_data
                                   );

         IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
         END IF;

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO Get_Tax_Distribution_Ccids_PVT;
         --Bug 8410923
         --Assigning the return status properly
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         DUMP_MSG;
         FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
         FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count       =>      x_msg_count,
                                   p_data        =>      x_msg_data
                                   );
         IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
         END IF;

        WHEN OTHERS THEN
          ROLLBACK TO Get_Tax_Distribution_Ccids_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
          FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                    p_count       =>      x_msg_count,
                                    p_data        =>      x_msg_data
                                   );

          IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;

 END get_tax_distribution_ccids;


/* ===================================================================================*
 | PROCEDURE Update_tax_dist_gl_date : Updates gl date of a list of Tax Distributions |
 | GTT involved : ZX_TAX_DIST_ID_GT                                                   |
 * ====================================================================================*/

 PROCEDURE Update_Tax_dist_gl_date
 (  p_api_version           IN         NUMBER,
    p_init_msg_list         IN         VARCHAR2,
    p_commit                IN         VARCHAR2,
    p_validation_level      IN         NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_gl_date               IN         DATE
  ) IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'UPDATE_TAX_DIST_GL_DATE';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_context_info_rec            context_info_rec_type;
   l_init_msg_list               VARCHAR2(1);

 BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
    END IF;

	/*--------------------------------------------------+
     |   Standard start of API savepoint                |
     +--------------------------------------------------*/
     SAVEPOINT Update_Tax_Dist_GL_Date_PVT;

    /*--------------------------------------------------+
     |   Standard call to check for call compatibility  |
     +--------------------------------------------------*/
     IF NOT FND_API.Compatible_API_Call( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME
                                        ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
       l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

     /*-----------------------------------------+
      |   Initialize return status to SUCCESS   |
      +-----------------------------------------*/

      x_return_status := FND_API.G_RET_STS_SUCCESS;

     /*-----------------------------------------+
      |   Populate Global Variable              |
      +-----------------------------------------*/

      G_PUB_SRVC := l_api_name;
      G_DATA_TRANSFER_MODE := 'PLS';
      G_EXTERNAL_API_CALL  := 'N';

     /*--------------------------------+
      |   Update gl date               |
      +-------------------------------*/
      ZX_TRL_PUB_PKG.update_gl_date(p_gl_date =>p_gl_date,
                                    x_return_status =>l_return_status
                                    );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TRL_PUB_PKG.update_gl_date returned errors');
         END IF;
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
       END IF;

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()+');
      END IF;

      EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Update_Tax_Dist_Gl_Date_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        DUMP_MSG;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   =>      x_msg_count,
                                  p_data    =>      x_msg_data
                                  );
        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO Update_Tax_Dist_GL_Date_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         DUMP_MSG;
         FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
         FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count       =>      x_msg_count,
                                   p_data        =>      x_msg_data
                                   );
         IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
         END IF;

        WHEN OTHERS THEN
         ROLLBACK TO Update_tax_dist_gl_date_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
         FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count       =>      x_msg_count,
                                   p_data        =>      x_msg_data
                                   );
         IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;

 END update_tax_dist_gl_date;

 /* =====================================================================*
 | PROCEDURE Update_exchange_rate : Updates Exchange Rate                |
 +========================================================================*/

 PROCEDURE update_exchange_rate
  ( p_api_version           IN         NUMBER,
    p_init_msg_list         IN         VARCHAR2,
    p_commit                IN         VARCHAR2,
    p_validation_level      IN         NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_transaction_rec       IN         transaction_rec_type,
    p_curr_conv_rate        IN         NUMBER,
    p_curr_conv_date        IN         DATE,
    p_curr_conv_type        IN         VARCHAR2
   ) IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'UPDATE_EXCHANGE_RATE';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_event_class_rec             event_class_rec_type;
   l_return_status               VARCHAR2(30);
   l_ledger_id                   NUMBER;
   l_init_msg_list               VARCHAR2(1);

 BEGIN

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
     END IF;

     /*--------------------------------------------------+
      |   Standard start of API savepoint                |
      +--------------------------------------------------*/
      SAVEPOINT Update_Exchange_Rate_PVT;

     /*--------------------------------------------------+
      |   Standard call to check for call compatibility  |
      +--------------------------------------------------*/
     IF NOT FND_API.Compatible_API_Call( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME
                                        ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

     /*--------------------------------------------------------------+
      |   Initialize message list if p_init_msg_list is set to TRUE  |
      +--------------------------------------------------------------*/
      IF p_init_msg_list is null THEN
        l_init_msg_list := FND_API.G_FALSE;
      ELSE
	l_init_msg_list := p_init_msg_list;
      END IF;

      IF FND_API.to_Boolean(l_init_msg_list) THEN
        FND_MSG_PUB.initialize;
      END IF;

     /*-----------------------------------------+
      |   Initialize return status to SUCCESS   |
      +-----------------------------------------*/

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      /*-----------------------------------------+
      |   Populate Global Variable              |
      +-----------------------------------------*/

      G_PUB_SRVC := l_api_name;
      G_DATA_TRANSFER_MODE := 'PLS';
      G_EXTERNAL_API_CALL  := 'N';

      /*---------------------------------------------+
       |   Missing Currency Conversion Rate          |
       +---------------------------------------------*/
       IF p_curr_conv_rate is NULL THEN
         FND_MESSAGE.SET_NAME('ZX','ZX_CURRENCY_CONVERSION_RATE_REQD');
         FND_MSG_PUB.Add;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
            'Currency conversion rate is passed as null');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       END IF;

      /*---------------------------------------------+
       |   Missing Currency Conversion Date          |
       +---------------------------------------------*/
       IF p_curr_conv_date is NULL THEN
         FND_MESSAGE.SET_NAME('ZX','ZX_CURRENCY_CONVERSION_DATE_REQD');
         FND_MSG_PUB.Add;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
            'Currency conversion date is passed as null');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       END IF;

       /*---------------------------------------------+
        |   Missing Currency Conversion Type          |
        +---------------------------------------------*/
        IF p_curr_conv_type is NULL THEN
          FND_MESSAGE.SET_NAME('ZX','ZX_CURRENCY_CONVERSION_TYPE_REQD');
          FND_MSG_PUB.Add;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
            'Currency conversion type is passed as null');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
        END IF;

       /*-----------------------------------------+
        |   Call Check Trx Rec                    |
        +-----------------------------------------*/
        ZX_CHECK_REQUIRED_PARAMS_PKG.check_trx_rec(l_return_status,
                                                   p_transaction_rec
                                                  );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TRL_PUB_PKG.update_gl_date returned errors');
          END IF;
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

        l_event_class_rec.APPLICATION_ID              := p_transaction_rec.APPLICATION_ID;
        l_event_class_rec.ENTITY_CODE                 := p_transaction_rec.ENTITY_CODE;
        l_event_class_rec.EVENT_CLASS_CODE            := p_transaction_rec.EVENT_CLASS_CODE;
        l_event_class_rec.EVENT_TYPE_CODE             := p_transaction_rec.EVENT_TYPE_CODE;
        l_event_class_rec.TRX_ID                      := p_transaction_rec.TRX_ID;
        l_event_class_rec.record_flag                 := NULL;
        l_event_class_rec.record_for_partners_flag    := 'N';

        BEGIN
          SELECT prod_family_grp_code
            INTO l_event_class_rec.prod_family_grp_code
            FROM zx_evnt_cls_mappings
           WHERE application_id   = p_transaction_rec.application_id
             AND entity_code      = p_transaction_rec.entity_code
             AND event_class_code = p_transaction_rec.event_class_code;
        EXCEPTION
          WHEN OTHERS THEN
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Incorrect event_class_code passed: ' || p_transaction_rec.event_class_code);
           END IF;
           RETURN;
        END;

        BEGIN
          SELECT tax_event_type_code
            INTO l_event_class_rec.tax_event_type_code
            FROM zx_evnt_typ_mappings
           WHERE application_id   = p_transaction_rec.application_id
             AND entity_code      = p_transaction_rec.entity_code
             AND event_class_code = p_transaction_rec.event_class_code
             AND event_type_code  = p_transaction_rec.event_type_code;
        EXCEPTION
          WHEN OTHERS THEN
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Incorrect event_type_code passed: ' || p_transaction_rec.event_type_code);
           END IF;
           RETURN;
        END;
       /*-------------------------------------------------+
        |  Retrieve the ledger id to pass to TDS process  |
        +------------------------------------------------*/
        SELECT ledger_id
          INTO l_ledger_id
          FROM ZX_LINES_DET_FACTORS
         WHERE application_id   = p_transaction_rec.application_id
           AND entity_code      = p_transaction_rec.entity_code
           AND event_class_code = p_transaction_rec.event_class_code
           AND trx_id           = p_transaction_rec.trx_id
           AND rownum           = 1;

       /*-------------------------------------------------+
        |  Call TDS routine update_exchange_rate          |
        +------------------------------------------------*/
        ZX_TDS_CALC_SERVICES_PUB_PKG.update_exchange_rate(p_event_class_rec          => l_event_class_rec,
                                                          p_ledger_id                => l_ledger_id,
                                                          p_currency_conversion_rate => p_curr_conv_rate,
                                                          p_currency_conversion_type => p_curr_conv_type,
                                                          p_currency_conversion_date => p_curr_conv_date,
                                                          x_return_status            => l_return_status
                                                         );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TDS_CALC_SERVICES_PUB_PKG.update_exchange_rate returned errors');
          END IF;
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;
       /*------------------------------------------------+
        |  Update zx_lines_det_factors for currency info  |
        +------------------------------------------------*/
         UPDATE ZX_LINES_DET_FACTORS SET
            CURRENCY_CONVERSION_DATE  = p_curr_conv_date,
            CURRENCY_CONVERSION_RATE  = p_curr_conv_rate,
            CURRENCY_CONVERSION_TYPE  = p_curr_conv_type
         WHERE  APPLICATION_ID    = p_transaction_rec.APPLICATION_ID
            AND ENTITY_CODE       = p_transaction_rec.ENTITY_CODE
            AND EVENT_CLASS_CODE  = p_transaction_rec.EVENT_CLASS_CODE
            AND TRX_ID            = p_transaction_rec.TRX_ID;

        IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()+');
        END IF;

       EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO Update_Exchange_Rate_PVT;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         DUMP_MSG;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count   =>      x_msg_count,
                                   p_data    =>      x_msg_data
                                   );

         IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO Update_Exchange_Rate_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         DUMP_MSG;
         FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
         FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count       =>      x_msg_count,
                                   p_data        =>      x_msg_data
                                   );
         IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;

        WHEN OTHERS THEN
           ROLLBACK TO Update_Exchange_Rate_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
           FND_MSG_PUB.Add;
          /*---------------------------------------------------------+
           | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
           | in the message stack. If there is only one message in   |
           | the stack it retrieves this message                     |
           +---------------------------------------------------------*/
           FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                     p_count       =>      x_msg_count,
                                     p_data        =>      x_msg_data
                                     );

           IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;

 END Update_Exchange_Rate;

/* =============================================================================*
 | PROCEDURE  Discard_tax_only_lines : Called when the whole document containing|
 |                                     tax only lines is cancelled              |
 * =============================================================================*/
 PROCEDURE discard_tax_only_lines
 ( p_api_version           IN         NUMBER,
   p_init_msg_list         IN         VARCHAR2,
   p_commit                IN         VARCHAR2,
   p_validation_level      IN         NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   p_transaction_rec       IN         transaction_rec_type
   ) IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'DISCARD_TAX_ONLY_LINES';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_event_class_rec             event_class_rec_type;
   l_init_msg_list               VARCHAR2(1);

 CURSOR get_event_class_info IS
 SELECT summarization_flag,
        retain_summ_tax_line_id_flag
   FROM zx_evnt_cls_mappings
  WHERE application_id = p_transaction_rec.application_id
    AND entity_code = p_transaction_rec.entity_code
    AND event_class_code = p_transaction_rec.event_class_code;

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;


   /*--------------------------------------------------+
    |   Standard start of API savepoint                |
    +--------------------------------------------------*/
    SAVEPOINT discard_tax_only_lines_PVT;

    /*--------------------------------------------------+
     |   Standard call to check for call compatibility  |
     +--------------------------------------------------*/
     IF NOT FND_API.Compatible_API_Call( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME
                                         ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
      IF p_init_msg_list is null THEN
        l_init_msg_list := FND_API.G_FALSE;
      ELSE
	l_init_msg_list := p_init_msg_list;
      END IF;

      IF FND_API.to_Boolean(l_init_msg_list) THEN
        FND_MSG_PUB.initialize;
      END IF;

      /*-----------------------------------------+
       |   Initialize return status to SUCCESS   |
       +-----------------------------------------*/
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       /*-----------------------------------------+
        |   Populate Global Variable              |
        +-----------------------------------------*/
        G_PUB_SRVC := l_api_name;
        G_DATA_TRANSFER_MODE := 'PLS';
        G_EXTERNAL_API_CALL  := 'N';

       /*------------------------------------------------------+
        |   Validate Input Paramerters and Fetch Tax Options   |
        +------------------------------------------------------*/
        ZX_VALID_INIT_PARAMS_PKG.discard_tax_only_lines(x_return_status  => l_return_status ,
                                                        p_trx_rec        => p_transaction_rec
                                                       );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_VALID_INIT_PARAMS_PKG.discard_tax_only_lines returned errors');
          END IF;
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

        l_event_class_rec.application_id       := p_transaction_rec.application_id;
        l_event_class_rec.entity_code          := p_transaction_rec.entity_code;
        l_event_class_rec.event_class_code     := p_transaction_rec.event_class_code;
        l_event_class_rec.event_type_code      := p_transaction_rec.event_type_code;
        l_event_class_rec.trx_id               := p_transaction_rec.trx_id;
        l_event_class_rec.first_pty_org_id     := p_transaction_rec.first_pty_org_id;
        l_event_class_rec.tax_event_class_code := p_transaction_rec.tax_event_class_code;
        l_event_class_rec.tax_event_type_code  := p_transaction_rec.tax_event_type_code;

         -- Get Event Class Info.

        OPEN  get_event_class_info;
        FETCH get_event_class_info INTO
              l_event_class_rec.summarization_flag,
              l_event_class_rec.retain_summ_tax_line_id_flag;

        IF get_event_class_info%NOTFOUND THEN

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN

             FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME || l_api_name,
                     G_PKG_NAME||':'||l_api_name||': Event Class Info not retreived');
         END IF;

        END IF;

        CLOSE get_event_class_info;

       /*--------------------------------------------------+
        |   Call to Service Type Discard Tax Only Lines    |
        +--------------------------------------------------*/
        IF ( G_LEVEL_EVENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EVENT,G_MODULE_NAME||l_api_name,
             'Updating Tax Lines for Transaction: '||
             to_char(p_transaction_rec.trx_id)||
             ' of Application: '||
             to_char(p_transaction_rec.application_id)||
             ' and Event Class: '||
             p_transaction_rec.event_class_code
            );
        END IF;

        ZX_SRVC_TYP_PKG.discard_tax_only_lines(p_event_class_rec    => l_event_class_rec,
                                               x_return_status      => l_return_status
                                               );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_SRVC_TYP_PKG.discard_tax_only_lines returned errors');
          END IF;
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

        IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
        END IF;

       EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
           ROLLBACK TO discard_tax_only_lines_PVT;
           x_return_status := FND_API.G_RET_STS_ERROR ;
           DUMP_MSG;
          /*---------------------------------------------------------+
           | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
           | in the message stack. If there is only one message in   |
           | the stack it retrieves this message                     |
           +---------------------------------------------------------*/
           FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                     p_count   =>      x_msg_count,
                                     p_data    =>      x_msg_data
                                     );
           IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
           END IF;

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO discard_tax_only_lines_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            DUMP_MSG;
            FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
            FND_MSG_PUB.Add;
           /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count   =>      x_msg_count,
                                      p_data    =>      x_msg_data
                                      );
            IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
            END IF;

         WHEN OTHERS THEN
            ROLLBACK TO discard_tax_only_lines_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
            FND_MSG_PUB.Add;
           /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count       =>      x_msg_count,
                                      p_data        =>      x_msg_data
                                      );
            IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
            END IF;
 END discard_tax_only_lines;


/* =======================================================================*
 | PROCEDURE  validate_document_for_tax :                                 |
 * =======================================================================*/

 PROCEDURE Validate_document_for_tax
 ( p_api_version           IN            NUMBER,
   p_init_msg_list         IN            VARCHAR2 ,
   p_commit                IN            VARCHAR2,
   p_validation_level      IN            NUMBER,
   x_return_status         OUT    NOCOPY VARCHAR2 ,
   x_msg_count             OUT    NOCOPY NUMBER ,
   x_msg_data              OUT    NOCOPY VARCHAR2,
   p_transaction_rec       IN OUT NOCOPY transaction_rec_type,
   x_validation_status     OUT    NOCOPY VARCHAR2,
   x_hold_codes_tbl        OUT    NOCOPY ZX_API_PUB.hold_codes_tbl_type
  ) IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'VALIDATE_DOCUMENT_FOR_TAX';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_init_msg_list               VARCHAR2(1);
   l_event_class_rec             event_class_rec_type;

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;


   /*--------------------------------------------------+
    |   Standard start of API savepoint                |
    +--------------------------------------------------*/
   SAVEPOINT Validate_Document_PVT;

    /*--------------------------------------------------+
     |   Standard call to check for call compatibility  |
     +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                        ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
        l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

    /*-----------------------------------------+
     |   Initialize return status to SUCCESS   |
     +-----------------------------------------*/

     x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*-----------------------------------------+
     |   Populate Global Variable              |
     +-----------------------------------------*/
     G_PUB_SRVC := l_api_name;
     G_DATA_TRANSFER_MODE := 'PLS';
     G_EXTERNAL_API_CALL  := 'N';

    /*------------------------------------------------------+
     |   Validate Input Paramerters and Fetch Tax Options   |
     +------------------------------------------------------*/
     ZX_VALID_INIT_PARAMS_PKG.validate_document_for_tax(x_return_status   => l_return_status,
                                                        p_event_class_rec => l_event_class_rec,
                                                        p_trx_rec         => p_transaction_rec
                                                       );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_VALID_INIT_PARAMS_PKG.validate_document_for_tax returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;

    /*--------------------------------------------------+
     |   Call Service Type Validate Document for Tax    |
     +--------------------------------------------------*/
     ZX_SRVC_TYP_PKG.validate_document_for_tax(p_trx_rec             => p_transaction_rec,
                                               p_event_class_rec     => l_event_class_rec,
                                               x_validation_status   => x_validation_status,
                                               x_hold_status_code    => x_hold_codes_tbl,
                                               x_return_status       => l_return_status
                                              );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_SRVC_TYP_PKG.validate_document_for_tax returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;

    /*------------------------------------------------+
     |  Update zx_lines_det_factors                   |
     +------------------------------------------------*/
     UPDATE ZX_LINES_DET_FACTORS
       SET TAX_EVENT_TYPE_CODE = l_event_class_rec.tax_event_type_code,
           DOC_EVENT_STATUS    = l_event_class_rec.doc_status_code
     WHERE APPLICATION_ID  = p_transaction_rec.APPLICATION_ID
      AND ENTITY_CODE       = p_transaction_rec.ENTITY_CODE
      AND EVENT_CLASS_CODE  = p_transaction_rec.EVENT_CLASS_CODE
      AND TRX_ID            = p_transaction_rec.TRX_ID;

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
     END IF;

     EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO Validate_Document_PVT;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         DUMP_MSG;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count   => x_msg_count,
                                   p_data    => x_msg_data
                                   );
         IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
         END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Validate_Document_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          DUMP_MSG;
          FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
          FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                    p_count   => x_msg_count,
                                    p_data    => x_msg_data
                                    );
          IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
          END IF;


        WHEN OTHERS THEN
           ROLLBACK TO Validate_Document_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
           FND_MSG_PUB.Add;
          /*---------------------------------------------------------+
           | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
           | in the message stack. If there is only one message in   |
           | the stack it retrieves this message                     |
           +---------------------------------------------------------*/
           FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                     p_count   => x_msg_count,
                                     p_data    => x_msg_data
                                    );

           IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;

 END validate_document_for_tax;


/* =======================================================================*
 | PROCEDURE  validate_document_for_tax for Receivables Autoinvoice       |
 |            and recurring invoice.                                      |
 |            Bug 5518807                                                 |
 * =======================================================================*/

 PROCEDURE Validate_document_for_tax
 ( p_api_version           IN            NUMBER,
   p_init_msg_list         IN            VARCHAR2 ,
   p_commit                IN            VARCHAR2,
   p_validation_level      IN            NUMBER,
   x_return_status         OUT    NOCOPY VARCHAR2 ,
   x_msg_count             OUT    NOCOPY NUMBER ,
   x_msg_data              OUT    NOCOPY VARCHAR2
  ) IS
    l_api_name          CONSTANT  VARCHAR2(30) := 'BULK_VALIDATE_DOCUMENT_FOR_TAX';
    l_api_version       CONSTANT  NUMBER := 1.0;
    l_return_status               VARCHAR2(30);
    l_init_msg_list               VARCHAR2(1);

    CURSOR c_headers is
       SELECT zthg.application_id
            , zthg.entity_code
            , zthg.event_class_code
            , zthg.trx_id
            , zetm.event_type_code  -- Bug 5598384
            , zect.tax_event_type_code
            , zect.status_code
         FROM ZX_TRX_HEADERS_GT zthg
            , ZX_EVNT_TYP_MAPPINGS zetm
            , ZX_EVNT_CLS_TYPS zect
        WHERE zthg.event_class_code     = zetm.event_class_code
          AND zthg.entity_code          = zetm.entity_code
          AND zthg.application_id       = zetm.application_id
          AND zetm.event_type_code      = DECODE(zetm.event_class_code,   -- Bug 5598384
                                          'INVOICE', 'INV_COMPLETE',
                                          'DEBIT_MEMO', 'DM_COMPLETE',
                                          'CREDIT_MEMO', 'CM_COMPLETE'
                                          )
          AND zect.tax_event_class_code = zetm.tax_event_class_code
          AND zect.tax_event_type_code  = zetm.tax_event_type_code
          AND (validation_check_flag is null OR
               validation_check_flag <> 'N');

    l_application_id_tbl     	NUMBER_tbl_type;
    l_entity_code_tbl    	VARCHAR2_30_tbl_type;
    l_event_class_code_tbl	VARCHAR2_30_tbl_type;
    l_trx_id_tbl		NUMBER_tbl_type;
    l_event_type_code_tbl	VARCHAR2_30_tbl_type;
    l_tax_event_type_code_tbl	VARCHAR2_30_tbl_type;
    l_doc_event_status_tbl	VARCHAR2_30_tbl_type;


 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'(+)');
   END IF;


   /*--------------------------------------------------+
    |   Standard start of API savepoint                |
    +--------------------------------------------------*/
   SAVEPOINT Validate_Document_PVT;

    /*--------------------------------------------------+
     |   Standard call to check for call compatibility  |
     +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                        ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
        l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

    /*-----------------------------------------+
     |   Initialize return status to SUCCESS   |
     +-----------------------------------------*/

     x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*-----------------------------------------+
     |   Populate Global Variable              |
     +-----------------------------------------*/
     G_PUB_SRVC := l_api_name;
     G_DATA_TRANSFER_MODE := 'PLS';
     G_EXTERNAL_API_CALL  := 'N';

     BEGIN
        OPEN C_HEADERS;
        LOOP
           FETCH c_HEADERS BULK COLLECT INTO
               l_application_id_tbl,
               l_entity_code_tbl,
               l_event_class_code_tbl,
               l_trx_id_tbl,
               l_event_type_code_tbl,
               l_tax_event_type_code_tbl,
               l_doc_event_status_tbl
           LIMIT G_LINES_PER_FETCH;


           FORALL i IN l_application_id_tbl.FIRST .. l_application_id_tbl.LAST
              UPDATE ZX_LINES_DET_FACTORS
                 SET EVENT_TYPE_CODE     = l_event_type_code_tbl(i),
                     TAX_EVENT_TYPE_CODE = l_tax_event_type_code_tbl(i),
                     DOC_EVENT_STATUS    = l_doc_event_status_tbl(i)
               WHERE
                     APPLICATION_ID    = l_application_id_tbl(i)
                 AND ENTITY_CODE       = l_entity_code_tbl(i)
                 AND EVENT_CLASS_CODE  = l_event_class_code_tbl(i)
                 AND TRX_ID            = l_trx_id_tbl(i);

           exit when c_HEADERS%NOTFOUND;
        END LOOP;

        close c_HEADERS;
     END;

     EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO Validate_Document_PVT;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         DUMP_MSG;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count   => x_msg_count,
                                   p_data    => x_msg_data
                                   );
         IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
         END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Validate_Document_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          DUMP_MSG;
          FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
          FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                    p_count   => x_msg_count,
                                    p_data    => x_msg_data
                                    );
          IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
          END IF;


        WHEN OTHERS THEN
           ROLLBACK TO Validate_Document_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
           FND_MSG_PUB.Add;
          /*---------------------------------------------------------+
           | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
           | in the message stack. If there is only one message in   |
           | the stack it retrieves this message                     |
           +---------------------------------------------------------*/
           FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                     p_count   => x_msg_count,
                                     p_data    => x_msg_data
                                    );

           IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;

 END validate_document_for_tax;


/* ============================================================================*
 | PROCEDURE get_default_tax_line_attribs : default the tax status and tax rate|
 |                                       based on the tax regime and tax       |
 * ===========================================================================*/
 PROCEDURE get_default_tax_line_attribs
 ( p_api_version            IN         NUMBER,
   p_init_msg_list          IN         VARCHAR2,
   p_commit                 IN         VARCHAR2,
   p_validation_level       IN         NUMBER,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2,
   p_tax_regime_code	    IN	       VARCHAR2,
   p_tax 	            IN	       VARCHAR2,
   p_effective_date	    IN	       DATE,
   x_tax_status_code	    OUT	NOCOPY VARCHAR2,
   x_tax_rate_code          OUT NOCOPY VARCHAR2
 )  IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'GET_DEFAULT_TAX_LINE_ATTRIBS';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_error_buffer                VARCHAR2(1000);
   l_tax_method                  VARCHAR2(30);
   l_init_msg_list               VARCHAR2(1);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;


  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Get_Default_Tax_Line_Attrs_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
       l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;


   /*-----------------------------------------+
    |   Initialize return status to SUCCESS   |
    +-----------------------------------------*/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   /*-----------------------------------------+
    |   Populate Global Variable              |
    +-----------------------------------------*/
    G_PUB_SRVC := l_api_name;
    G_DATA_TRANSFER_MODE := 'PLS';
    G_EXTERNAL_API_CALL  := 'N';

  /*-----------------------------------------+
   |   Get the tax status and tax rate       |
   +-----------------------------------------*/
     ZX_TCM_EXT_SERVICES_PUB.get_default_status_rates(p_tax_regime_code   => p_tax_regime_code,
                                                      p_tax               => p_tax,
                                                      p_date              => p_effective_date,
                                                      p_tax_status_code   => x_tax_status_code,
                                                      p_tax_rate_code     => x_tax_rate_code,
                                                      p_return_status     => l_return_status
                                                     );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TCM_EXT_SERVICES_PUB.get_default_status_rates returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;


   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Get_Default_Tax_Line_Attrs_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       DUMP_MSG;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data
                                 );
       IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
       END IF;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Get_Default_Tax_Line_Attrs_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       DUMP_MSG;
       FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
       FND_MSG_PUB.Add;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data
                                 );
       IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
       END IF;

     WHEN OTHERS THEN
       ROLLBACK TO Get_Default_Tax_Line_Attrs_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
       FND_MSG_PUB.Add;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data
                                 );

       IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;

 END get_default_tax_line_attribs;

/* =================================================================================*
 | OVERLOADED version till XBUILD 2 so that AP processes do not get invalidated     |
 | NEED TO REMOVE THIS PROCEDURE ONCE AP CHANGES GO IN                                |
 |                                                                                  |
 | Procedure  get_default_tax_det_attribs : default the following product fiscal     |
 | classification based on the relevant default taxation country, application event  |
 | class, inventory organization and inventory item values:                          |
 |             *	trx_business_category                                        |
 |             *	primary_intended_use                                         |
 |             *	product_fisc_classification                                  |
 |             *	product_category                                             |
 * ================================================================================*/


 PROCEDURE get_default_tax_det_attribs
 ( p_api_version            IN         NUMBER,
   p_init_msg_list          IN         VARCHAR2,
   p_commit                 IN         VARCHAR2,
   p_validation_level       IN         NUMBER,
   x_return_status          OUT NOCOPY VARCHAR2 ,
   x_msg_count              OUT NOCOPY NUMBER ,
   x_msg_data               OUT NOCOPY VARCHAR2,
   p_application_id	    IN	       NUMBER,
   p_entity_code	    IN	       VARCHAR2,
   p_event_class_code	    IN	       VARCHAR2,
   p_org_id	            IN	       NUMBER,
   p_item_id	            IN	       NUMBER,
   p_country_code	    IN	       VARCHAR2,
   p_effective_date	    IN	       DATE,
   x_trx_biz_category	    OUT	NOCOPY VARCHAR2,
   x_intended_use	    OUT	NOCOPY VARCHAR2,
   x_prod_category	    OUT	NOCOPY VARCHAR2,
   x_prod_fisc_class_code   OUT	NOCOPY VARCHAR2,
   x_product_type           OUT NOCOPY VARCHAR2
 )  IS
 BEGIN
   NULL;
 END get_default_tax_det_attribs;


/* =================================================================================*
 | Procedure  get_default_tax_det_attribs : default the following product fiscal    |
 | classification based on the relevant default taxation country, application event |
 | class, inventory organization and inventory item values:                         |
 |             *	trx_business_category                                       |
 |             *	primary_intended_use                                        |
 |             *	product_fisc_classification                                 |
 |             *	product_category                                            |
 * ================================================================================*/


 PROCEDURE get_default_tax_det_attribs
 ( p_api_version            IN         NUMBER,
   p_init_msg_list          IN         VARCHAR2,
   p_commit                 IN         VARCHAR2,
   p_validation_level       IN         NUMBER,
   x_return_status          OUT NOCOPY VARCHAR2 ,
   x_msg_count              OUT NOCOPY NUMBER ,
   x_msg_data               OUT NOCOPY VARCHAR2,
   p_application_id	    IN	       NUMBER,
   p_entity_code	    IN	       VARCHAR2,
   p_event_class_code	    IN	       VARCHAR2,
   p_org_id	            IN	       NUMBER,
   p_item_id	            IN	       NUMBER,
   p_country_code	    IN	       VARCHAR2,
   p_effective_date	    IN	       DATE,
   p_source_event_class_code IN        VARCHAR2,
   x_trx_biz_category	    OUT	NOCOPY VARCHAR2,
   x_intended_use	    OUT	NOCOPY VARCHAR2,
   x_prod_category	    OUT	NOCOPY VARCHAR2,
   x_prod_fisc_class_code   OUT	NOCOPY VARCHAR2,
   x_product_type           OUT NOCOPY VARCHAR2,
   p_inventory_org_id       IN NUMBER
 )  IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'GET_DEFAULT_TAX_DET_ATTRIBS';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_error_buffer                VARCHAR2(1000);
   l_tax_method                  VARCHAR2(30);
   l_init_msg_list               VARCHAR2(1);
   l_internal_org_id             NUMBER;
   l_application_id              NUMBER;
   l_entity_code                 zx_evnt_cls_mappings.entity_code%TYPE;
   l_event_class_code            zx_evnt_cls_mappings.event_class_code%TYPE;
   l_zx_product_options_rec      ZX_GLOBAL_STRUCTURES_PKG.zx_product_options_rec_type;

  CURSOR c_trx_biz_cat_csr (c_application_id NUMBER,
                            c_entity_code zx_evnt_cls_mappings.entity_code%TYPE,
                            c_event_class_code zx_evnt_cls_mappings.event_class_code%TYPE) IS
  SELECT tax_event_class_code, intrcmp_tx_evnt_cls_code
  FROM   zx_evnt_cls_mappings
  WHERE  application_id = c_application_id
  AND    entity_code = c_entity_code
  AND    event_class_code = c_event_class_code;

  CURSOR c_intrcmp_code (c_application_id NUMBER,
                        c_entity_code zx_evnt_cls_mappings.entity_code%TYPE,
                        c_event_class_code zx_evnt_cls_mappings.event_class_code%TYPE) IS
  SELECT  DEF_INTRCMP_TRX_BIZ_CATEGORY
  FROM  ZX_EVNT_CLS_OPTIONS op, zx_party_tax_profile ptp
  WHERE  op.application_id = c_application_id
  AND    op.entity_code = c_entity_code
  AND    op.event_class_code = c_event_class_code
  AND    op.FIRST_PTY_ORG_ID = ptp.party_tax_profile_id
  AND    op.effective_from <= p_effective_date
  AND   (op.effective_to >= p_effective_date OR op.effective_to IS NULL)
  AND    ptp.party_id = p_org_id
  AND    ptp.party_type_code = 'OU';

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Get_Default_Tax_Det_Attrs_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

   /*--------------------------------------------------------------+
    |   Initialize message list if p_init_msg_list is set to TRUE  |
    +--------------------------------------------------------------*/
    IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
    ELSE
       l_init_msg_list := p_init_msg_list;
    END IF;

    IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

  /*-----------------------------------------+
   |   Initialize return status to SUCCESS   |
   +-----------------------------------------*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;


  /*-----------------------------------------+
   |   Populate Global Variable              |
   +-----------------------------------------*/
   --Currently this procedure is being called from internal TDS services when defaulting the determining
   --attributes in case of calculate_tax, insert_line_det_factors,etc. So need to set the parameters only
   --if direct call to this API and not via other published APIs
   IF G_PUB_CALLING_SRVC is null THEN
     G_PUB_SRVC := l_api_name;
     G_DATA_TRANSFER_MODE := 'PLS';
     G_EXTERNAL_API_CALL  := 'N';
   --ELSE
   --   G_PUB_CALLING_SRVC := null;
   END IF;

  /*-----------------------------------------------------------------+
   |   Populate Global Event Class Rec If Not Populated              |
   +-----------------------------------------------------------------*/

   l_application_id := p_application_id; --bug# 6662504

   IF ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.application_id IS NULL THEN

     IF p_event_class_code = 'SALES_TRANSACTION_TAX_QUOTE' THEN
       l_application_id := 222;
       l_entity_code := 'TRANSACTIONS';
       l_event_class_code := 'INVOICE';
     ELSIF p_event_class_code = 'PURCHASE_TRANSACTION_TAX_QUOTE' THEN
       l_application_id := 200;
       l_entity_code := 'AP_INVOICES';
       l_event_class_code := 'STANDARD INVOICES';
     ELSE
       l_application_id := p_application_id;
       l_entity_code := p_entity_code;
       l_event_class_code := p_event_class_code;
     END IF;


     -- Fetch tax event class and intercompany tax event class

     OPEN c_trx_biz_cat_csr(l_application_id, l_entity_code, l_event_class_code);
     FETCH c_trx_biz_cat_csr INTO ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.tax_event_class_code,
                                  ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.intrcmp_tx_evnt_cls_code;
     CLOSE c_trx_biz_cat_csr;

     -- Fetch default transaction business category

     OPEN c_intrcmp_code(l_application_id, l_entity_code, l_event_class_code);
     FETCH c_intrcmp_code INTO ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.DEF_INTRCMP_TRX_BIZ_CATEGORY;
     CLOSE c_intrcmp_code;

   END IF;


    -- Fetch tax method
    -- Fix for bug 5102996: Fetch tax method from zx_product_options only if it is not found in the cache

    ZX_GLOBAL_STRUCTURES_PKG.get_product_options_info
                   (p_application_id      => l_application_id,
                    p_org_id              => p_org_id,
                    x_product_options_rec => l_zx_product_options_rec,
                    x_return_status       => x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR then

        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'Incorrect return status after calling '||
                          'ZX_GLOBAL_STRUCTURES_PKG.get_product_options_info');
        END IF;
        ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.tax_method_code := 'EBTAX';

    ELSE
        ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.tax_method_code := nvl(l_zx_product_options_rec.tax_method_code,'EBTAX'); --6841552
    END IF;

    l_tax_method := ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec.tax_method_code;


   IF l_tax_method = 'EBTAX' THEN

    /*---------------------------------------------------------+
     |   Get the default value for trx business category        |
     +---------------------------------------------------------*/
     ZX_TCM_EXT_SERVICES_PUB.get_default_classif_code(p_fiscal_type_code  =>  'TRX_BUSINESS_CATEGORY',
                                                      p_country_code      =>  p_country_code,
                                                      p_application_id    =>  p_application_id,
                                                      p_entity_code       =>  p_entity_code,
                                                      p_event_class_code  =>  p_event_class_code,
                                                      p_source_event_class_code  =>  p_source_event_class_code,
                                                      p_org_id            =>  p_org_id,
                                                      p_item_id           =>  p_item_id,
                                                      p_default_code      =>  x_trx_biz_category,
                                                      p_return_status     =>  l_return_status
                                                     );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TCM_EXT_SERVICES_PUB.get_default_classif_code returned errors');
        END IF;
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
     ELSE
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
          'Transaction Business Category:' || x_trx_biz_category);
        END IF;
     END IF;

    /*---------------------------------------------------------+
     |   Get the default value for Intended use                 |
     +---------------------------------------------------------*/
     ZX_TCM_EXT_SERVICES_PUB.get_default_classif_code(p_fiscal_type_code  =>  'INTENDED_USE',
                                                      p_country_code      =>  p_country_code,
                                                      p_application_id    =>  p_application_id,
                                                      p_entity_code       =>  p_entity_code,
                                                      p_event_class_code  =>  p_event_class_code,
                                                      p_source_event_class_code  =>  p_source_event_class_code,
                                                      p_org_id            =>  p_org_id,
                                                      p_item_id           =>  p_item_id,
                                                      p_default_code      =>  x_intended_use,
                                                      p_return_status     =>  l_return_status
                                                     );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TCM_EXT_SERVICES_PUB.get_default_classif_code returned errors');
        END IF;
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      ELSE
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
          'Intended Use :' || x_intended_use);
        END IF;
      END IF;

      --Bug 6841552
      /*-----------------------------------------------------+
        |   Get the default value for product category        |
        +-----------------------------------------------------*/
        ZX_TCM_EXT_SERVICES_PUB.get_default_classif_code(p_fiscal_type_code  =>  'PRODUCT_CATEGORY',
                                                         p_country_code      =>  p_country_code,
                                                         p_application_id    =>  p_application_id,
                                                         p_entity_code       =>  p_entity_code,
                                                         p_event_class_code  =>  p_event_class_code,
                                                         p_source_event_class_code  =>  p_source_event_class_code,
                                                         p_item_id           =>  p_item_id,
                                                         p_org_id            =>  p_org_id,
                                                         p_default_code      =>  x_prod_category ,
                                                         p_return_status     =>  l_return_status
                                                         );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TCM_EXT_SERVICES_PUB.get_default_classif_code returned errors');
          END IF;
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        ELSE
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
            'Product Category :' || x_prod_category);
          END IF;
        END IF;

      IF p_item_id is not null THEN
       /*---------------------------------------------------------+
        |   Get the value for fiscal product classification        |
        +---------------------------------------------------------*/
	ZX_TCM_EXT_SERVICES_PUB.get_default_product_classif(p_country_code    =>  p_country_code,
                                                            p_item_id         =>  p_item_id,
                                                            p_org_id          =>  p_org_id,
                                                            p_default_code    =>  x_prod_fisc_class_code,
                                                            p_return_status   =>  l_return_status
                                                            );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||': ZX_TCM_EXT_SERVICES_PUB.get_default_product_classif returned errors');
          END IF;
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        ELSE
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
            'Product Fiscal Classification :'|| x_prod_fisc_class_code);
          END IF;
        END IF;

       /*-----------------------------------------------------+
        |   Get the default value for product type            |
        +-----------------------------------------------------*/
        ZX_TCM_EXT_SERVICES_PUB.get_default_classif_code(p_fiscal_type_code  =>  'PRODUCT_TYPE',
                                                         p_country_code      =>  p_country_code,
                                                         p_application_id    =>  p_application_id,
                                                         p_entity_code       =>  p_entity_code,
                                                         p_event_class_code  =>  p_event_class_code,
                                                         p_source_event_class_code  =>  p_source_event_class_code,
                                                         p_item_id           =>  p_item_id,
                                                         p_org_id            =>  nvl(p_inventory_org_id,p_org_id),
                                                         p_default_code      =>  x_product_type ,
                                                         p_return_status     =>  l_return_status
                                                         );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TCM_EXT_SERVICES_PUB.get_default_classif_code returned errors');
          END IF;
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        ELSE
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
            'Product Type :' || x_product_type);
          END IF;
        END IF;

     ELSE --p_item_id is null
       x_product_type := null;
       x_prod_fisc_class_code := null;

       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
         'Product Type :' || x_product_type||
         ', Product Fiscal Classification :' || x_prod_fisc_class_code);
       END IF;
     END IF; --p_item_id is not null
   ELSIF l_tax_method = 'LTE' THEN
      JL_ZZ_TAX_VALIDATE_PKG.default_tax_attr(x_return_status => l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TCM_EXT_SERVICES_PUB.get_default_classif_code returned errors');
        END IF;
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
   END IF; --tax method condition

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Get_Default_Tax_Det_Attrs_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       DUMP_MSG;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data
                                );
       IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Get_Default_Tax_Det_Attrs_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       DUMP_MSG;
       FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
       FND_MSG_PUB.Add;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data
                                 );

       IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;

     WHEN OTHERS THEN
       ROLLBACK TO Get_Default_Tax_Det_Attrs_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
       FND_MSG_PUB.Add;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data
                                 );
       IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;
 END get_default_tax_det_attribs;



/* =================================================================================*
 | Overloaded Procedure  get_default_tax_det_attribs- for products that do not call |
 | ARP_TAX.get_default_tax_classification                                           |
 | Default the following product fiscal                                             |
 | classification based on the relevant default taxation country, application event |
 | class, inventory organization and inventory item values:                         |
 |             *	trx_business_category                                       |
 |             *	primary_intended_use                                        |
 |             *	product_fisc_classification                                 |
 |             *	product_category                                            |
 | Also default the tax classification code                                         |
 * ================================================================================*/

 PROCEDURE get_default_tax_det_attribs
 (
   p_api_version                   IN         NUMBER,
   p_init_msg_list                 IN         VARCHAR2,
   p_commit                        IN         VARCHAR2,
   p_validation_level              IN         NUMBER,
   x_return_status                 OUT NOCOPY VARCHAR2 ,
   x_msg_count                     OUT NOCOPY NUMBER ,
   x_msg_data                      OUT NOCOPY VARCHAR2,
   p_defaulting_rec_type           IN         det_fact_defaulting_rec_type,
   x_trx_biz_category	           OUT NOCOPY VARCHAR2,
   x_intended_use	           OUT NOCOPY VARCHAR2,
   x_prod_category	           OUT NOCOPY VARCHAR2,
   x_prod_fisc_class_code          OUT NOCOPY VARCHAR2,
   x_product_type                  OUT NOCOPY VARCHAR2,
   x_tax_classification_code       OUT NOCOPY VARCHAR2
 )  IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'GET_DEFAULT_TAX_DET_ATTRIBS';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_error_buffer                VARCHAR2(1000);
   l_init_msg_list               VARCHAR2(1);
   l_redef_tax_class_code_rec    def_tax_cls_code_info_rec_type;

BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Get_Default_Tax_Det_Attrs_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

   /*--------------------------------------------------------------+
    |   Initialize message list if p_init_msg_list is set to TRUE  |
    +--------------------------------------------------------------*/
    IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
    ELSE
       l_init_msg_list := p_init_msg_list;
    END IF;

    IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

   /*-----------------------------------------+
    |   Initialize return status to SUCCESS   |
    +-----------------------------------------*/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   /*-----------------------------------------+
    |   Populate Global Variable              |
    +-----------------------------------------*/
    G_PUB_SRVC := l_api_name;
    G_DATA_TRANSFER_MODE := 'PLS';
    G_EXTERNAL_API_CALL  := 'N';

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
      'application_id: ' || to_char(p_defaulting_rec_type.application_id)||
      ', entity_code: ' || p_defaulting_rec_type.entity_code||
      ', event_class_code: ' || p_defaulting_rec_type.event_class_code||
      ', org_id: ' || to_char(p_defaulting_rec_type.org_id)||
      ', item_id: ' || to_char(p_defaulting_rec_type.item_id)||
      ', country_code: ' || p_defaulting_rec_type.country_code||
      ', effective_date: ' || to_char(p_defaulting_rec_type.effective_date)||
      ', trx_id: ' || to_char(p_defaulting_rec_type.trx_id)||
      ', item_id: ' || to_char(p_defaulting_rec_type.item_id)||
      ', trx_date: ' || to_char(p_defaulting_rec_type.trx_date)||
      ', ledger_id: ' || to_char(p_defaulting_rec_type.ledger_id)||
      ', ship_from_party_id: ' || to_char(p_defaulting_rec_type.ship_from_party_id)||
      ', ship_to_party_id: ' || to_char(p_defaulting_rec_type.ship_to_party_id)||
      ', bill_to_party_id: ' || to_char(p_defaulting_rec_type.bill_to_party_id)||
      ', ship_from_pty_site_id: ' || to_char(p_defaulting_rec_type.ship_from_pty_site_id)||
      ', ship_to_location_id: ' || to_char(p_defaulting_rec_type.ship_to_location_id)||
      ', ship_to_acct_site_use_id: ' || to_char(p_defaulting_rec_type.ship_to_acct_site_use_id)||
      ', bill_to_acct_site_use_id: ' || to_char(p_defaulting_rec_type.bill_to_acct_site_use_id)||
      ', account_ccid: ' || to_char(p_defaulting_rec_type.account_ccid)||
      ', account_string: ' || p_defaulting_rec_type.account_string||
      ', ship_third_pty_acct_id: ' || to_char(p_defaulting_rec_type.ship_third_pty_acct_id)||
      ', bill_third_pty_acct_id: ' || to_char(p_defaulting_rec_type.bill_third_pty_acct_id)||
      ', ref_doc_application_id: ' || to_char(p_defaulting_rec_type.application_id)||
      ', ref_doc_entity_code: ' || p_defaulting_rec_type.ref_doc_entity_code||
      ', ref_doc_event_class_code: ' || p_defaulting_rec_type.ref_doc_event_class_code||
      ', ref_doc_trx_id: ' || to_char(p_defaulting_rec_type.ref_doc_trx_id)||
      ', ref_doc_line_id: ' || to_char(p_defaulting_rec_type.ref_doc_line_id)||
      ', ref_doc_trx_level_type: ' || p_defaulting_rec_type.ref_doc_trx_level_type||
      ', defaulting_attribute1: ' || p_defaulting_rec_type.defaulting_attribute1||
      ', defaulting_attribute2: ' || p_defaulting_rec_type.defaulting_attribute2||
      ', defaulting_attribute3: ' || p_defaulting_rec_type.defaulting_attribute3||
      ', defaulting_attribute4: ' || p_defaulting_rec_type.defaulting_attribute4||
      ', defaulting_attribute5: ' || p_defaulting_rec_type.defaulting_attribute5||
      ', defaulting_attribute6: ' || p_defaulting_rec_type.defaulting_attribute6||
      ', defaulting_attribute7: ' || p_defaulting_rec_type.defaulting_attribute7||
      ', defaulting_attribute8: ' || p_defaulting_rec_type.defaulting_attribute8||
      ', defaulting_attribute9: ' || p_defaulting_rec_type.defaulting_attribute9||
      ', defaulting_attribute10: ' || p_defaulting_rec_type.defaulting_attribute10||
      ', legal_entity_id: ' || to_char(p_defaulting_rec_type.legal_entity_id)||
      ', source_event_class_code: ' || to_char(p_defaulting_rec_type.source_event_class_code));
    END IF;

  /*------------------------------------------------------------------------------------------+
   |   Call original get_default_tax_line_attribs to get the values of fiscal classifications |
   +-----------------------------------------------------------------------------------------*/
   get_default_tax_det_attribs (p_api_version,
                                l_init_msg_list,
                                p_commit,
                                p_validation_level,
                                l_return_status,
                                x_msg_count,
                                x_msg_data,
                                p_defaulting_rec_type.application_id,
                                p_defaulting_rec_type.entity_code,
                                p_defaulting_rec_type.event_class_code,
                                p_defaulting_rec_type.org_id,
                                p_defaulting_rec_type.item_id,
                                p_defaulting_rec_type.country_code,
                                p_defaulting_rec_type.effective_date,
                                p_defaulting_rec_type.source_event_class_code,
                                x_trx_biz_category,
                                x_intended_use,
                                x_prod_category,
                                x_prod_fisc_class_code ,
                                x_product_type
                                ) ;

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':get_default_tax_det_attribs returned errors');
     END IF;
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;

  /*---------------------------------------------------------------------------------+
   |   Copy from input structure before calling API to default the tax classification|
   +--------------------------------------------------------------------------------*/
   l_redef_tax_class_code_rec.application_id                := p_defaulting_rec_type.application_id;
   l_redef_tax_class_code_rec.entity_code                   := p_defaulting_rec_type.entity_code;
   l_redef_tax_class_code_rec.event_class_code              := p_defaulting_rec_type.event_class_code;
   l_redef_tax_class_code_rec.internal_organization_id      := p_defaulting_rec_type.org_id;
   l_redef_tax_class_code_rec.trx_id                        := p_defaulting_rec_type.trx_id;
   l_redef_tax_class_code_rec.trx_line_id                   := p_defaulting_rec_type.trx_line_id;
   l_redef_tax_class_code_rec.trx_level_type                := p_defaulting_rec_type.trx_level_type;
   l_redef_tax_class_code_rec.ledger_id                     := p_defaulting_rec_type.ledger_id;
   l_redef_tax_class_code_rec.trx_date                      := p_defaulting_rec_type.trx_date;
   l_redef_tax_class_code_rec.ref_doc_application_id        := p_defaulting_rec_type.ref_doc_application_id;
   l_redef_tax_class_code_rec.ref_doc_event_class_code      := p_defaulting_rec_type.ref_doc_event_class_code;
   l_redef_tax_class_code_rec.ref_doc_entity_code           := p_defaulting_rec_type.ref_doc_entity_code;
   l_redef_tax_class_code_rec.ref_doc_trx_id                := p_defaulting_rec_type.ref_doc_trx_id;
   l_redef_tax_class_code_rec.ref_doc_line_id               := p_defaulting_rec_type.ref_doc_line_id;
   l_redef_tax_class_code_rec.ref_doc_trx_level_type        := p_defaulting_rec_type.ref_doc_trx_level_type;
   l_redef_tax_class_code_rec.account_ccid                  := p_defaulting_rec_type.account_ccid;
   l_redef_tax_class_code_rec.account_string                := p_defaulting_rec_type.account_string;
   l_redef_tax_class_code_rec.product_id                    := p_defaulting_rec_type.item_id;
   l_redef_tax_class_code_rec.product_org_id                := p_defaulting_rec_type.item_org_id;
   l_redef_tax_class_code_rec.receivables_trx_type_id       := p_defaulting_rec_type.application_id;
   l_redef_tax_class_code_rec.ship_third_pty_acct_id        := p_defaulting_rec_type.ship_third_pty_acct_id;
   l_redef_tax_class_code_rec.bill_third_pty_acct_id        := p_defaulting_rec_type.bill_third_pty_acct_id;
   l_redef_tax_class_code_rec.ship_to_cust_acct_site_use_id := p_defaulting_rec_type.ship_to_acct_site_use_id;
   l_redef_tax_class_code_rec.bill_to_cust_acct_site_use_id := p_defaulting_rec_type.bill_to_acct_site_use_id;
   l_redef_tax_class_code_rec.ship_to_location_id           := p_defaulting_rec_type.ship_to_location_id;
   l_redef_tax_class_code_rec.receivables_trx_type_id       := p_defaulting_rec_type.trx_type_id;
   l_redef_tax_class_code_rec.defaulting_attribute1         := p_defaulting_rec_type.defaulting_attribute1;
   l_redef_tax_class_code_rec.defaulting_attribute2         := p_defaulting_rec_type.defaulting_attribute2;
   l_redef_tax_class_code_rec.defaulting_attribute3         := p_defaulting_rec_type.defaulting_attribute3;
   l_redef_tax_class_code_rec.defaulting_attribute4         := p_defaulting_rec_type.defaulting_attribute4;
   l_redef_tax_class_code_rec.defaulting_attribute5         := p_defaulting_rec_type.defaulting_attribute5;
   l_redef_tax_class_code_rec.defaulting_attribute6         := p_defaulting_rec_type.defaulting_attribute6;
   l_redef_tax_class_code_rec.defaulting_attribute7         := p_defaulting_rec_type.defaulting_attribute7;
   l_redef_tax_class_code_rec.defaulting_attribute8         := p_defaulting_rec_type.defaulting_attribute8;
   l_redef_tax_class_code_rec.defaulting_attribute9         := p_defaulting_rec_type.defaulting_attribute9;
   l_redef_tax_class_code_rec.defaulting_attribute10        := p_defaulting_rec_type.defaulting_attribute10;
   l_redef_tax_class_code_rec.legal_entity_id               := p_defaulting_rec_type.legal_entity_id;


  /*-------------------------------------------------+
   |   Call TDM API to default the tax classification|
   +-------------------------------------------------*/
   IF ( G_LEVEL_EVENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_EVENT,G_MODULE_NAME||l_api_name,
     'Call TDM to default tax classfication'
      );
   END IF;

   ZX_TAX_DEFAULT_PKG.get_default_tax_classification (p_definfo        =>  l_redef_tax_class_code_rec,
                                                      p_return_status  =>  l_return_status,
                                                      p_error_buffer   =>  l_error_buffer
                                                      );
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TAX_DEFAULT_PKG.get_default_tax_classification returned errors');
     END IF;
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   ELSE
      x_tax_classification_code := l_redef_tax_class_code_rec.x_tax_classification_code;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
        'Tax Classification: ' || x_tax_classification_code
        );
      END IF;
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Get_Default_Tax_Det_Attrs_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       DUMP_MSG;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data
                                 );
       IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Get_Default_Tax_Det_Attrs_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       DUMP_MSG;
       FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
       FND_MSG_PUB.Add;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data
                                 );

       IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;

     WHEN OTHERS THEN
       ROLLBACK TO Get_Default_Tax_Det_Attrs_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
       FND_MSG_PUB.Add;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count   => x_msg_count,
                                 p_data    => x_msg_data
                                 );
       IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;

 END get_default_tax_det_attribs;

/* =======================================================================*
 | PROCEDURE  set_tax_security_context :  Sets the security context based |
 |                                        on OU and LE of transaction     |
 * =======================================================================*/
 PROCEDURE set_tax_security_context
 ( p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2,
   p_commit                IN  VARCHAR2,
   p_validation_level      IN  NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2 ,
   x_msg_count             OUT NOCOPY NUMBER ,
   x_msg_data              OUT NOCOPY VARCHAR2,
   p_internal_org_id       IN  NUMBER,
   p_legal_entity_id       IN  NUMBER,
   p_transaction_date      IN  DATE,
   p_related_doc_date      IN  DATE,
   p_adjusted_doc_date     IN  DATE,
   x_effective_date        OUT NOCOPY DATE
  )IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'SET_TAX_SECURITY_CONTEXT';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_init_msg_list               VARCHAR2(1);

   l_effective_date              DATE;

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Set_Tax_Security_Context_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

   /*--------------------------------------------------------------+
    |   Initialize message list if p_init_msg_list is set to TRUE  |
    +--------------------------------------------------------------*/
    IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
    ELSE
	   l_init_msg_list := p_init_msg_list;
    END IF;

    IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

   /*-----------------------------------------+
    |   Initialize return status to SUCCESS   |
    +-----------------------------------------*/
    x_return_status := FND_API.G_RET_STS_SUCCESS;


   /*--------------------------------------------+
    |   Call to zx_security.set_security_context |
    +--------------------------------------------*/

    x_effective_date := determine_effective_date(p_transaction_date,
                                                 p_related_doc_date,
                                                 p_adjusted_doc_date);
    l_effective_date := x_effective_date;

    ZX_SECURITY.set_security_context(p_legal_entity_id,
                                     p_internal_org_id,
                                     l_effective_date,
                                     l_return_status
                                     );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_SECURITY.set_security_context returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;

    /*---------------------------------------------------------+
     | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
     | in the message stack. If there is only one message in   |
     | the stack it retrieves this message                     |
     +---------------------------------------------------------*/
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data
                               );

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
     END IF;

     EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Set_Tax_Security_Context_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        DUMP_MSG;
       /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data
                                  );

        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Set_Tax_Security_Context_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        DUMP_MSG;
        FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
        FND_MSG_PUB.Add;
       /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data
                                  );

        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN OTHERS THEN
         ROLLBACK TO set_tax_security_context_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
         FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count   => x_msg_count,
                                   p_data    => x_msg_data
                                   );
         IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;
  END set_tax_security_context;



/* =======================================================================*
 | Overloaded PROCEDURE  set_tax_security_context: for Lease Management   |
 | Also includes setting the date based on provnl_tax_determination_date  |
 * =======================================================================*/
 PROCEDURE set_tax_security_context
 ( p_api_version           IN         NUMBER,
   p_init_msg_list         IN         VARCHAR2,
   p_commit                IN         VARCHAR2,
   p_validation_level      IN         NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2 ,
   x_msg_count             OUT NOCOPY NUMBER ,
   x_msg_data              OUT NOCOPY VARCHAR2,
   p_internal_org_id       IN         NUMBER,
   p_legal_entity_id       IN         NUMBER,
   p_transaction_date      IN         DATE,
   p_related_doc_date      IN         DATE,
   p_adjusted_doc_date     IN         DATE,
   p_provnl_tax_det_date   IN         DATE,
   x_effective_date        OUT NOCOPY DATE
  )IS
   l_api_name          CONSTANT  VARCHAR2(30) := 'SET_TAX_SECURITY_CONTEXT';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_init_msg_list               VARCHAR2(1);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Set_Tax_Security_Context_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

   /*--------------------------------------------------------------+
    |   Initialize message list if p_init_msg_list is set to TRUE  |
    +--------------------------------------------------------------*/
    IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
    ELSE
       l_init_msg_list := p_init_msg_list;
    END IF;

    IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

   /*-----------------------------------------+
    |   Initialize return status to SUCCESS   |
    +-----------------------------------------*/
    x_return_status := FND_API.G_RET_STS_SUCCESS;


   /*--------------------------------------------+
    |   Call to zx_security.set_security_context |
    +--------------------------------------------*/
     ZX_SECURITY.set_security_context(p_legal_entity_id,
                                      p_internal_org_id,
                                      determine_effective_date(p_transaction_date,
                                                               p_related_doc_date,
                                                               p_adjusted_doc_date,
                                                               p_provnl_tax_det_date),
                                      l_return_status
                                      );

     x_effective_date := ZX_SECURITY.G_EFFECTIVE_DATE;

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_SECURITY.set_security_context returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;

    /*---------------------------------------------------------+
     | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
     | in the message stack. If there is only one message in   |
     | the stack it retrieves this message                     |
     +---------------------------------------------------------*/
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data
                               );

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
     END IF;

     EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Set_Tax_Security_Context_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        DUMP_MSG;
       /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data
                                  );

        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Set_Tax_Security_Context_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        DUMP_MSG;
        FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
        FND_MSG_PUB.Add;
       /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data
                                  );

        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN OTHERS THEN
         ROLLBACK TO set_tax_security_context_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
         FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count   => x_msg_count,
                                   p_data    => x_msg_data
                                   );
         IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;
  END set_tax_security_context;



 /* =======================================================================*
 | PROCEDURE  validate_and_default_tax_attr :                              |
 | This api supports multiple document processing                          |
 * =======================================================================*/
 PROCEDURE validate_and_default_tax_attr
 (
  p_api_version           IN         NUMBER,
  p_init_msg_list         IN         VARCHAR2,
  p_commit                IN         VARCHAR2,
  p_validation_level      IN         NUMBER,
  x_return_status         OUT NOCOPY VARCHAR2 ,
  x_msg_count             OUT NOCOPY NUMBER ,
  x_msg_data              OUT NOCOPY VARCHAR2
  ) IS
  l_api_name          CONSTANT  VARCHAR2(30) := 'VALIDATE_AND_DEFAULT_TAX_ATTR';
  l_api_version       CONSTANT  NUMBER := 1.0;
  l_tax_method                  VARCHAR2(30);
  l_app_id                      NUMBER;
  l_return_status               VARCHAR2(30);
  l_context_info_rec            context_info_rec_type;
  l_init_msg_list               VARCHAR2(1);
  l_internal_organization_id    NUMBER;
  l_zx_product_options_rec      ZX_GLOBAL_STRUCTURES_PKG.zx_product_options_rec_type;

 BEGIN
  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Validate_And_Default_Tax_Attr;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   /*--------------------------------------------------------------+
    |   Initialize message list if p_init_msg_list is set to TRUE  |
    +--------------------------------------------------------------*/
    IF p_init_msg_list is null THEN
      l_init_msg_list := FND_API.G_FALSE;
    ELSE
      l_init_msg_list := p_init_msg_list;
    END IF;

    IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

   /*-----------------------------------------+
    |   Initialize return status to SUCCESS   |
    +-----------------------------------------*/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   /*-----------------------------------------+
    |   Populate Global Variable              |
    +-----------------------------------------*/
    G_PUB_SRVC := l_api_name;
    G_DATA_TRANSFER_MODE := 'TAB';
    G_EXTERNAL_API_CALL  := 'N';

    BEGIN
      SELECT internal_organization_id,
             application_id
        INTO l_internal_organization_id,
             l_app_id
        FROM ZX_TRX_HEADERS_GT headers
       WHERE rownum =1;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
 	     l_tax_method := 'EBTAX';
    END;

   ZX_GLOBAL_STRUCTURES_PKG.get_product_options_info
                   (p_application_id      => l_app_id,
                    p_org_id              => l_internal_organization_id,
                    x_product_options_rec => l_zx_product_options_rec,
                    x_return_status       => x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR then

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Incorrect return status after calling '||
                          'ZX_GLOBAL_STRUCTURES_PKG.get_product_options_info');
        END IF;
        l_tax_method := 'EBTAX';
    ELSE
        -- Bug 7528340
        l_tax_method := NVL(l_zx_product_options_rec.tax_method_code,'EBTAX');
    END IF;

    IF l_app_id = 200 AND l_tax_method IS NULL THEN
      l_tax_method := 'EBTAX';
    END IF;

    IF l_tax_method = 'EBTAX' THEN
     ZX_VALIDATE_API_PKG.default_and_validate_tax_attr(p_api_version,
                                                       l_init_msg_list,
                                                       p_commit,
                                                       p_validation_level,
                                                       l_return_status,
                                                       x_msg_count,
                                                       x_msg_data
                                                      );
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_VALIDATE_API_PKG.default_and_validate_tax_attr returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;
    ELSIF l_tax_method = 'LTE' THEN
    JL_ZZ_TAX_VALIDATE_PKG.default_and_validate_tax_attr(p_api_version,
                                                         l_init_msg_list,
                                                         p_commit,
                                                         p_validation_level,
                                                         l_return_status,
                                                         x_msg_count,
                                                         x_msg_data
                                                        );
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':JL_ZZ_TAX_VALIDATE_PKG.default_and_validate_tax_attr returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;
    END IF;  --l_tax_method


    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        --Since this API only inserts into the errors GT and updates the header and line GTTs
        --we shouldnt be rolling back here as that data too will be lost
        --ROLLBACK TO Validate_And_Default_Tax_Attr;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        --Messages are inserted into ZX_VALIDATION_ERRORS_GT for this API
        DUMP_MSG;
        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Validate_And_Default_Tax_Attr;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        DUMP_MSG;
        FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
        FND_MSG_PUB.Add;
       /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data
                                  );

        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN OTHERS THEN
         ROLLBACK TO Validate_And_Default_Tax_Attr;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
         FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;
 END validate_and_default_tax_attr;



/* ==========================================================================*
 | PROCEDURE  rollback_for_tax :  Communicate to the Tax Partners to rollback|
 |                                transactions in their system               |
 * =========================================================================*/
 PROCEDURE rollback_for_tax
 ( p_api_version           IN         NUMBER,
   p_init_msg_list         IN         VARCHAR2,
   p_commit                IN         VARCHAR2,
   p_validation_level      IN         NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2 ,
   x_msg_count             OUT NOCOPY NUMBER ,
   x_msg_data              OUT NOCOPY VARCHAR2
 )IS
  l_api_name          CONSTANT  VARCHAR2(30) := 'ROLLBACK_FOR_TAX';
  l_api_version       CONSTANT  NUMBER := 1.0;

 BEGIN
  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
  END IF;

 END rollback_for_tax;

/* ========================================================================*
 | PROCEDURE  commit_for_tax :  Communicate to the Tax Partners to commit  |
 |                              transactions in their system               |
 * =======================================================================*/

 PROCEDURE commit_for_tax
 ( p_api_version           IN         NUMBER,
   p_init_msg_list         IN         VARCHAR2,
   p_commit                IN         VARCHAR2,
   p_validation_level      IN         NUMBER ,
   x_return_status         OUT NOCOPY VARCHAR2 ,
   x_msg_count             OUT NOCOPY NUMBER ,
   x_msg_data              OUT NOCOPY VARCHAR2
 )IS
  l_api_name          CONSTANT  VARCHAR2(30) := 'COMMIT_FOR_TAX';
  l_api_version       CONSTANT  NUMBER := 1.0;

 BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
    END IF;

 END commit_for_tax;

/* =======================================================================*
 | PROCEDURE  add_msg : Adds the message to the fnd message stack or      |
 |                      local plsql table to be dumped later into the     |
 |                      errors GT.                                        |
 * =======================================================================*/

  PROCEDURE add_msg (p_context_info_rec IN context_info_rec_type)
  IS
    l_count     BINARY_INTEGER;
    l_mesg      VARCHAR2(2000);
    l_api_name  CONSTANT VARCHAR2(30) := 'ADD_MSG';
  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
    END IF;
    --Add unexpected errors to fnd_stack
    IF p_context_info_rec.application_id is null THEN
      FND_MSG_PUB.Add();
    END IF;

    IF G_DATA_TRANSFER_MODE = 'PLS' OR
       G_DATA_TRANSFER_MODE = 'WIN' THEN
      /*If G_EXTERNAL_API_CALL is 'Y' reset it back to 'N' and no need to add to stack
        since message is already in stack.*/
      IF G_EXTERNAL_API_CALL  = 'Y' THEN
        G_EXTERNAL_API_CALL  := 'N';
      ELSE
        FND_MSG_PUB.Add();
      END IF;
    ELSIF G_DATA_TRANSFER_MODE = 'TAB' THEN
       l_count:= errors_tbl.application_id.COUNT;
       IF G_EXTERNAL_API_CALL  = 'Y' THEN
         LOOP
           l_mesg := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT, FND_API.G_FALSE);
           IF  l_mesg IS NULL THEN
             EXIT;
           ELSE
             errors_tbl.application_id(l_count+1)   := p_context_info_rec.application_id;
             errors_tbl.entity_code(l_count+1)      := p_context_info_rec.entity_code;
             errors_tbl.event_class_code(l_count+1) := p_context_info_rec.event_class_code;
             errors_tbl.trx_id(l_count+1)           := p_context_info_rec.trx_id;
             errors_tbl.trx_level_type(l_count+1)   := p_context_info_rec.trx_level_type;
             errors_tbl.trx_line_id(l_count+1)      := p_context_info_rec.trx_line_id;
             errors_tbl.summary_tax_line_number(l_count+1) := p_context_info_rec.summary_tax_line_number;
             errors_tbl.tax_line_id(l_count+1)      := p_context_info_rec.tax_line_id;
             errors_tbl.trx_line_dist_id(l_count+1) := p_context_info_rec.trx_line_dist_id;
             errors_tbl.message_text(l_count+1)     := l_mesg;
           END IF;
         END LOOP;
         G_EXTERNAL_API_CALL := 'N'; -- reset G_EXTERNAL_API_CALL
       ELSE --G_EXTERNAL_API_CALL is 'N' then retrieve message from fnd_stack
         errors_tbl.application_id(l_count+1)   := p_context_info_rec.application_id;
         errors_tbl.entity_code(l_count+1)      := p_context_info_rec.entity_code;
         errors_tbl.event_class_code(l_count+1) := p_context_info_rec.event_class_code;
         errors_tbl.trx_id(l_count+1)           := p_context_info_rec.trx_id;
         errors_tbl.trx_level_type(l_count+1)   := p_context_info_rec.trx_level_type;
         errors_tbl.trx_line_id(l_count+1)      := p_context_info_rec.trx_line_id;
         errors_tbl.summary_tax_line_number(l_count+1) := p_context_info_rec.summary_tax_line_number;
         errors_tbl.tax_line_id(l_count+1)      := p_context_info_rec.tax_line_id;
         errors_tbl.trx_line_dist_id(l_count+1) := p_context_info_rec.trx_line_dist_id;
         errors_tbl.message_text(l_count+1)     := fnd_message.get();
       END IF; --G_EXTERNAL_API_CALL
       l_count:=errors_tbl.application_id.COUNT;
    END IF; --G_DATA_TRANSFER_MODE

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
    END IF;
  END add_msg;

 /* ============================================================================*
 | PROCEDURE  dump_msg : Dump all error messages from pl/sql structure to table |
 * ============================================================================*/
  PROCEDURE dump_msg
  IS
     l_api_name   CONSTANT VARCHAR2(30) := 'DUMP_MSG';
  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
    END IF;
    FORALL i IN 1 .. nvl(errors_tbl.application_id.LAST,-99)
        INSERT INTO ZX_ERRORS_GT            (application_id,
                                             entity_code,
                                             event_class_code,
                                             trx_id,
                                             trx_line_id,
                                             trx_level_type,
                                             summary_tax_line_number,
                                             tax_line_id,
                                             trx_line_dist_id,
                                             message_text)
                                      values (errors_tbl.application_id(i),
                                              errors_tbl.entity_code(i),
                                              errors_tbl.event_class_code(i),
                                              errors_tbl.trx_id(i),
                                              errors_tbl.trx_line_id(i),
                                              errors_tbl.trx_level_type(i),
                                              errors_tbl.summary_tax_line_number(i),
                                              errors_tbl.tax_line_id(i),
                                              errors_tbl.trx_line_dist_id(i),
                                              NVL(errors_tbl.message_text(i),'UNEXPECTED_ERROR_DUMP_MSG')
                                             );

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,SQL%ROWCOUNT||' Error Message(s) dumped into Zx_Errors_GT.');
    END IF;

   errors_tbl.application_id.delete;
   errors_tbl.entity_code.delete;
   errors_tbl.event_class_code.delete;
   errors_tbl.trx_id.delete;
   errors_tbl.trx_line_id.delete;
   errors_tbl.trx_level_type.delete;
   errors_tbl.summary_tax_line_number.delete;
   errors_tbl.tax_line_id.delete;
   errors_tbl.trx_line_dist_id.delete;
   errors_tbl.message_text.delete;
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()-');
   END IF;
  END dump_msg;

/* =======================================================================*
 | FUNCTION  determine_effective_date :                                   |
 * =======================================================================*/

 FUNCTION determine_effective_date
 ( p_transaction_date      IN  DATE,
   p_related_doc_date      IN  DATE,
   p_adjusted_doc_date     IN  DATE
 ) RETURN DATE IS

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||'DETERMINE_EFFECTIVE_DATE.BEGIN','ZX_API_PUB: DETERMINE_EFFECTIVE_DATE()+');
   END IF;

   IF p_related_doc_date IS NOT NULL THEN
     return(p_related_doc_date);
   ELSIF p_adjusted_doc_date IS NOT NULL THEN
      return(p_adjusted_doc_date);
   ELSIF p_transaction_date IS NOT NULL THEN
      return(p_transaction_date);
   ELSE
      return(SYSDATE);
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||'DETERMINE_EFFECTIVE_DATE.END','ZX_API_PUB: DETERMINE_EFFECTIVE_DATE()-');
   END IF;

 END determine_effective_date;


/* =======================================================================*
 | Function  Get_Default_Tax_Reg : Returns the Default Registration Number|
 |                                 for a Given Party                      |
 * =======================================================================*/

 FUNCTION get_default_tax_reg(
  p_api_version       IN         NUMBER,
  p_init_msg_list     IN         VARCHAR2,
  p_commit            IN         VARCHAR2,
  p_validation_level  IN         NUMBER,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2,
  p_party_id          IN         ZX_PARTY_TAX_PROFILE.party_id%type,
  p_party_type        IN         ZX_PARTY_TAX_PROFILE.party_type_code%type,
  p_effective_date    IN         ZX_REGISTRATIONS.effective_from%type
 ) RETURN Varchar2 IS
  l_api_name          CONSTANT  VARCHAR2(30) := 'GET_DEFAULT_TAX_REG';
  l_api_version       CONSTANT  NUMBER := 1.0;
  l_reg_number                  VARCHAR2(50);
  l_return_status               VARCHAR2(1);
  l_context_info_rec            context_info_rec_type;
  l_init_msg_list               VARCHAR2(1);
 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   -- Commenting this save point as per bug# 5395191
   --  SAVEPOINT Get_Default_Tax_Reg_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   /*--------------------------------------------------------------+
    |   Initialize message list if p_init_msg_list is set to TRUE  |
    +--------------------------------------------------------------*/
    IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
    ELSE
       l_init_msg_list := p_init_msg_list;
    END IF;

    IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

   /*-----------------------------------------+
    |   Initialize return status to SUCCESS   |
    +-----------------------------------------*/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   /*-----------------------------------------+
    |   Populate Global Variable              |
    +-----------------------------------------*/
    G_PUB_SRVC := l_api_name;
    G_DATA_TRANSFER_MODE := 'PLS';
    G_EXTERNAL_API_CALL  := 'N';


   /*-----------------------------------------------------+
    |   Get the default value for product category        |
    +-----------------------------------------------------*/
    l_reg_number:= ZX_TCM_EXT_SERVICES_PUB.get_default_tax_reg(p_party_id,
                                                               p_party_type,
                                                               p_effective_date,
                                                               l_return_status
                                                               );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_TCM_EXT_SERVICES_PUB.get_default_tax_reg returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    ELSE
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
         'Registration Number: '|| l_reg_number
         );
       END IF;
       RETURN l_reg_number;
    END IF;


    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
    END IF;

    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
          -- Commented rollback as per bug 5395191
          -- ROLLBACK TO Get_Default_Tax_Reg_PVT;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          DUMP_MSG;
         /*---------------------------------------------------------+
          | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
          | in the message stack. If there is only one message in   |
          | the stack it retrieves this message                     |
          +---------------------------------------------------------*/
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                    p_count   =>      x_msg_count,
                                    p_data    =>      x_msg_data
                                    );
          IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
          END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          -- Commented rollback as per bug 5395191
          -- ROLLBACK TO Get_Default_Tax_Reg_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          DUMP_MSG;
          FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
          FND_MSG_PUB.Add;
         /*---------------------------------------------------------+
          | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
          | in the message stack. If there is only one message in   |
          | the stack it retrieves this message                     |
          +---------------------------------------------------------*/
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                    p_count   =>      x_msg_count,
                                    p_data    =>      x_msg_data
                                    );
          IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
          END IF;

        WHEN OTHERS THEN
          -- Commented rollback as per bug 5395191
          --  ROLLBACK TO Get_Default_Tax_Reg_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
           FND_MSG_PUB.Add;
          /*---------------------------------------------------------+
           | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
           | in the message stack. If there is only one message in   |
           | the stack it retrieves this message                     |
           +---------------------------------------------------------*/
           FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                     p_count  =>      x_msg_count,
                                     p_data   =>      x_msg_data
                                     );
           IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;

  END get_default_tax_reg;

 /* ========================================================================*
 | PROCEDURE  insert_line_det_factors : This procedure should be called by |
 | products when creating a document or inserting a new transaction line   |
 | for existing document. This line will be flagged to be picked up by the |
 | tax calculation process                                                 |
 * =======================================================================*/
PROCEDURE insert_line_det_factors (
  p_api_version        IN         NUMBER,
  p_init_msg_list      IN         VARCHAR2,
  p_commit             IN         VARCHAR2,
  p_validation_level   IN         NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2,
  p_duplicate_line_rec IN         transaction_line_rec_type
 )  IS
  l_api_name                  CONSTANT  VARCHAR2(30) := 'INSERT_LINE_DET_FACTORS';
  l_api_version               CONSTANT  NUMBER := 1.0;
  l_return_status             VARCHAR2(1);
  l_event_class_rec           event_class_rec_type;
  l_line_det_rec              ZX_LINES_DET_FACTORS%rowtype;
  l_line_exists               NUMBER;
  l_record_exists             BOOLEAN;
  l_init_msg_list             VARCHAR2(1);
  l_tax_classification_code   VARCHAR2(50);
  l_do_defaulting             BOOLEAN;
  l_upg_trx_info_rec          ZX_ON_FLY_TRX_UPGRADE_PKG.zx_upg_trx_info_rec_type;
 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'1()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Insert_Line_Det_Factors_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   /*--------------------------------------------------------------+
    |   Initialize message list if p_init_msg_list is set to TRUE  |
    +--------------------------------------------------------------*/
    IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
    ELSE
       l_init_msg_list := p_init_msg_list;
    END IF;

    IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

   /*-----------------------------------------+
    |   Initialize return status to SUCCESS   |
    +-----------------------------------------*/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   /*-----------------------------------------+
    |   Populate Global Variable              |
    +-----------------------------------------*/
    G_PUB_SRVC := l_api_name;
    G_PUB_CALLING_SRVC := l_api_name;
    G_DATA_TRANSFER_MODE := 'PLS';
    G_EXTERNAL_API_CALL  := 'N';

   /*-----------------------------------------+
    |Populate the event class record structure|
    +-----------------------------------------*/
   l_event_class_rec.INTERNAL_ORGANIZATION_ID     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID(1);
   l_event_class_rec.LEGAL_ENTITY_ID              :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEGAL_ENTITY_ID(1);
   l_event_class_rec.LEDGER_ID                    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEDGER_ID(1);
   l_event_class_rec.APPLICATION_ID               :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLICATION_ID(1);
   l_event_class_rec.ENTITY_CODE                  :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ENTITY_CODE(1);
   l_event_class_rec.EVENT_CLASS_CODE             :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_CLASS_CODE(1);
   l_event_class_rec.EVENT_TYPE_CODE              :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_TYPE_CODE(1);
   l_event_class_rec.CTRL_TOTAL_HDR_TX_AMT        :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CTRL_TOTAL_HDR_TX_AMT(1);
   l_event_class_rec.TRX_ID                       :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID(1);
   l_event_class_rec.TRX_DATE                     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DATE(1);
   l_event_class_rec.REL_DOC_DATE                 :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_DATE(1);
   l_event_class_rec.PROVNL_TAX_DETERMINATION_DATE:=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PROVNL_TAX_DETERMINATION_DATE(1);
   l_event_class_rec.TRX_CURRENCY_CODE            :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_CURRENCY_CODE(1);
   l_event_class_rec.PRECISION                    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRECISION(1);
   l_event_class_rec.CURRENCY_CONVERSION_TYPE     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_TYPE(1);
   l_event_class_rec.CURRENCY_CONVERSION_RATE     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_RATE(1);
   l_event_class_rec.CURRENCY_CONVERSION_DATE     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_DATE(1);
   l_event_class_rec.ROUNDING_SHIP_TO_PARTY_ID    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_SHIP_TO_PARTY_ID(1);
   l_event_class_rec.ROUNDING_SHIP_FROM_PARTY_ID  :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_SHIP_FROM_PARTY_ID(1);
   l_event_class_rec.ROUNDING_BILL_TO_PARTY_ID    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_BILL_TO_PARTY_ID(1);
   l_event_class_rec.ROUNDING_BILL_FROM_PARTY_ID  :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_BILL_FROM_PARTY_ID(1);
   l_event_class_rec.RNDG_SHIP_TO_PARTY_SITE_ID   :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_SHIP_TO_PARTY_SITE_ID(1);
   l_event_class_rec.RNDG_SHIP_FROM_PARTY_SITE_ID :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_SHIP_FROM_PARTY_SITE_ID(1);
   l_event_class_rec.RNDG_BILL_TO_PARTY_SITE_ID   :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_BILL_TO_PARTY_SITE_ID(1);
   l_event_class_rec.RNDG_BILL_FROM_PARTY_SITE_ID :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_BILL_FROM_PARTY_SITE_ID(1);

   --Check if need to upgrade
   l_record_exists := FALSE;
   IF l_event_class_rec.event_type_code = 'INV_UPDATE' THEN
      FOR l_line_det_rec in lock_line_det_factors_for_doc(l_event_class_rec)
      LOOP
        l_record_exists := TRUE;
        l_event_class_rec.event_id := l_line_det_rec.event_id;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.default_taxation_country(1) := l_line_det_rec.default_taxation_country;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.document_sub_type(1)        := l_line_det_rec.document_sub_type;
        EXIT;
      END LOOP;
      IF NOT(l_record_exists) THEN
        --Bugfix 4486946 -Call on the fly upgrade if the transaction if not found
        l_upg_trx_info_rec.application_id   := l_event_class_rec.application_id;
        l_upg_trx_info_rec.entity_code      := l_event_class_rec.entity_code;
        l_upg_trx_info_rec.event_class_code := l_event_class_rec.event_class_code;
        l_upg_trx_info_rec.trx_id           := l_event_class_rec.trx_id;
        ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly(p_upg_trx_info_rec   =>  l_upg_trx_info_rec,
                                                     x_return_status      =>  l_return_status
                                                    );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly returned errors');
          END IF;
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;
        FOR l_line_det_rec in lock_line_det_factors_for_doc(l_event_class_rec)
        LOOP
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               'Lock the document so that no updates can happen for transaction :' || to_char(l_event_class_rec.trx_id));
          END IF;
          l_record_exists := TRUE;
          l_event_class_rec.event_id := l_line_det_rec.event_id;
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.default_taxation_country(1) := l_line_det_rec.default_taxation_country;
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.document_sub_type(1)        := l_line_det_rec.document_sub_type;
          EXIT;
        END LOOP;
      END IF; --record does not exist so upgrade
    --Bugfix 4486946 - on-the-fly upgrade end
   END IF;    --event_type_code

   IF NOT(l_record_exists) THEN
     SELECT ZX_LINES_DET_FACTORS_S.nextval
       INTO l_event_class_rec.event_id
       FROM dual;
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            'application_id: '||to_char(l_event_class_rec.application_id)||
             ', entity_code: '||l_event_class_rec.entity_code||
             ', event_class_code: '||l_event_class_rec.event_class_code||
             ', event_type_code: '||l_event_class_rec.event_type_code||
             ', trx_id: '||to_char(l_event_class_rec.trx_id)||
             ', internal_organization_id: '||to_char(l_event_class_rec.internal_organization_id)||
             ', ledger_id: '||to_char(l_event_class_rec.ledger_id)||
             ', legal_entity_id: '||to_char(l_event_class_rec.legal_entity_id)||
             ', trx_date: '||to_char(l_event_class_rec.trx_date)||
             ', related_document_date: '||to_char(l_event_class_rec.rel_doc_date)||
             ', provnl_tax_determination_date: '||to_char(l_event_class_rec.provnl_tax_determination_date)||
             ', trx_currency_code: '||l_event_class_rec.trx_currency_code||
             ', currency_conversion_type: '||l_event_class_rec.currency_conversion_type||
             ', currency_conversion_rate: '||to_char(l_event_class_rec.currency_conversion_rate)||
             ', currency_conversion_date: '||to_char(l_event_class_rec.currency_conversion_date)||
             ', rounding_ship_to_party_id: '||to_char(l_event_class_rec.rounding_ship_to_party_id)||
             ', rounding_ship_from_party_id: '||to_char(l_event_class_rec.rounding_ship_from_party_id)||
             ', rounding_bill_to_party_id: '||to_char(l_event_class_rec.rounding_bill_to_party_id)||
             ', rounding_bill_from_party_id: '||to_char(l_event_class_rec.rounding_bill_from_party_id)||
             ', rndg_ship_to_party_site_id: '||to_char(l_event_class_rec.rndg_ship_to_party_site_id)||
             ', rndg_ship_from_party_site_id: '||to_char(l_event_class_rec.rndg_ship_from_party_site_id)||
             ', rndg_bill_to_party_site_id: '||to_char(l_event_class_rec.rndg_bill_to_party_site_id)||
             ', rndg_bill_from_party_site_id: '||to_char(l_event_class_rec.rndg_bill_from_party_site_id)
            );
   END IF;

   -- Bug 5676960: Set a flag to indicate if currency information passed at header/line
   IF l_event_class_rec.trx_currency_code is not null AND
      l_event_class_rec.precision is not null THEN
      l_event_class_rec.header_level_currency_flag := 'Y';
   END IF;

   /*------------------------------------------------------+
   |   Validate and Initializate parameters for Inserting |
   |   into line_det_factors                              |
   +------------------------------------------------------*/
   ZX_VALID_INIT_PARAMS_PKG.insupd_line_det_factors(p_event_class_rec =>l_event_class_rec,
                                                    p_trx_line_index  => 1,
                                                    x_return_status   =>l_return_status
                                                    );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_VALID_INIT_PARAMS_PKG.insupd_line_det_factors returned errors');
     END IF;
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;

-- Fix for Bug 5038953
   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_EVENT_CLASS_CODE(1) := l_event_class_rec.TAX_EVENT_CLASS_CODE;
-- End fix for Bug 5038953

 /* ==============================================*
   |Determine if we need to default the parameters|
   * ============================================*/
   l_do_defaulting := ZX_SRVC_TYP_PKG.decide_call_redefault_APIs (p_trx_line_index  => 1);

   IF l_do_defaulting THEN
   /*If the Duplicate Source Document Line identifiers are passed, then derive the values
     of the tax determining factors from ZX_LINES_DET_FACTORS for the duplicate source document line.*/
     IF p_duplicate_line_rec.application_id is not null THEN
       --Default determining factors from Duplicated Line
       SELECT
            default_taxation_country,
  	    document_sub_type,
	    trx_business_category,
	    line_intended_use,
	    user_defined_fisc_class,
	    product_fisc_classification,
	    product_category,
	    assessable_value,
            product_type,
            decode(l_event_class_rec.prod_family_grp_code,'P2P',input_tax_classification_code,
                                                          'O2C',output_tax_classification_code)
       INTO
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.default_taxation_country(1),
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.document_sub_type(1),
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_business_category(1),
	    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_intended_use(1),
	    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.user_defined_fisc_class(1),
	    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_fisc_classification(1),
	    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_category(1),
	    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.assessable_value(1),
	    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_type(1),
            l_tax_classification_code
       FROM ZX_LINES_DET_FACTORS
       WHERE application_id   = p_duplicate_line_rec.application_id
         AND entity_code      = p_duplicate_line_rec.entity_code
         AND event_class_code = p_duplicate_line_rec.event_class_code
         AND trx_id           = p_duplicate_line_rec.trx_id
         AND trx_line_id      = p_duplicate_line_rec.trx_line_id
         AND trx_level_type   = p_duplicate_line_rec.trx_level_type;

       --AR always passes the tax classification code so do not override the passed value
       IF l_event_class_rec.prod_family_grp_code = 'P2P' THEN
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.input_tax_classification_code(1) := l_tax_classification_code;
       ELSIF l_event_class_rec.prod_family_grp_code = 'O2C' AND
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.output_tax_classification_code is null THEN
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.output_tax_classification_code(1) := l_tax_classification_code;
       END IF;
     /*If  the applied from, adjusted, source document information is passed with
       the transaction line, then derive the values tax determining factors from
       ZX_LINES_DET_FACTORS or call TDS defaulting API*/
     ELSE ZX_SRVC_TYP_PKG.default_tax_attrs_wrapper (p_trx_line_index  => 1,
                                                     p_event_class_rec => l_event_class_rec,
                                                     x_return_status   => l_return_status
                                                    );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_SRVC_TYP_PKG.default_tax_attrs_wrapper returned errors');
          END IF;
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;
     END IF; --duplicate check
   END IF; --l_do_defaulting


   /*------------------------------------------+
   |Call to insert the lines                   |
   +------------------------------------------*/
   ZX_SRVC_TYP_PKG.insupd_line_det_factors(p_event_class_rec  => l_event_class_rec,
                                           x_return_status    => l_return_status
                                          );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_SRVC_TYP_PKG.insupd_line_det_factors returned errors');
     END IF;
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;

   --Delete from the global structures so that there are no hanging/redundant
   --records sitting there
   ZX_GLOBAL_STRUCTURES_PKG.delete_trx_line_dist_tbl;

   --Reset G_PUB_CALLING_SRVC at end of API
   ZX_API_PUB.G_PUB_CALLING_SRVC := null;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
   END IF;

   EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Insert_Line_Det_Factors_PVT;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          DUMP_MSG;
         /*---------------------------------------------------------+
          | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
          | in the message stack. If there is only one message in   |
          | the stack it retrieves this message                     |
          +---------------------------------------------------------*/
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                    p_count  =>      x_msg_count,
                                    p_data   =>      x_msg_data
                                    );

           IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
           END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Insert_Line_Det_Factors_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          DUMP_MSG;
          FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
          FND_MSG_PUB.Add;
         /*---------------------------------------------------------+
          | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
          | in the message stack. If there is only one message in   |
          | the stack it retrieves this message                     |
          +---------------------------------------------------------*/
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                    p_count   =>      x_msg_count,
                                    p_data    =>      x_msg_data
                                    );
          IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
          END IF;

        WHEN OTHERS THEN
           ROLLBACK TO Insert_Line_Det_Factors_PVT;
           IF (SQLCODE = 54) THEN
             x_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MESSAGE.SET_NAME('ZX','ZX_RESOURCE_BUSY');
           ELSE
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
           END IF;
           FND_MSG_PUB.Add;
         /*---------------------------------------------------------+
          | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
          | in the message stack. If there is only one message in   |
          | the stack it retrieves this message                     |
          +---------------------------------------------------------*/
           FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                     p_count  =>      x_msg_count,
                                     p_data   =>      x_msg_data
                                     );

           IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;
   END insert_line_det_factors;

 /* ============================================================================*
 | PROCEDURE  insert_line_det_factors : This overloaded procedure will be called|
 | by iProcurement to insert all the transaction lines with defaulted tax       |
 | determining attributes into zx_lines_det_factors after complying with the    |
 | validation process                                                           |
 * ============================================================================*/
PROCEDURE insert_line_det_factors (
  p_api_version        IN         NUMBER,
  p_init_msg_list      IN         VARCHAR2,
  p_commit             IN         VARCHAR2,
  p_validation_level   IN         NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2
 )  IS
  l_api_name          CONSTANT  VARCHAR2(30) := 'INSERT_LINE_DET_FACTORS';
  l_api_version       CONSTANT  NUMBER := 1.0;
  l_return_status     VARCHAR2(1);
  l_event_class_rec   event_class_rec_type;
  l_line_det_rec      ZX_LINES_DET_FACTORS%rowtype;
  l_line_exists       NUMBER;
  l_record_exists     BOOLEAN;
  l_init_msg_list     VARCHAR2(1);
  l_upg_trx_info_rec  ZX_ON_FLY_TRX_UPGRADE_PKG.zx_upg_trx_info_rec_type;

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'2()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Insert_Line_Det_Factors_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

   /*--------------------------------------------------------------+
    |   Initialize message list if p_init_msg_list is set to TRUE  |
    +--------------------------------------------------------------*/
    IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
    ELSE
       l_init_msg_list := p_init_msg_list;
    END IF;

    IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

   /*-----------------------------------------+
    |   Initialize return status to SUCCESS   |
    +-----------------------------------------*/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   /*-----------------------------------------+
    |   Populate Global Variable              |
    +-----------------------------------------*/
    G_PUB_SRVC := l_api_name;
    G_DATA_TRANSFER_MODE := 'PLS';
    G_EXTERNAL_API_CALL  := 'N';


   /*-----------------------------------------+
    |Populate the event class record structure|
    +-----------------------------------------*/
    l_event_class_rec.INTERNAL_ORGANIZATION_ID     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID(1);
    l_event_class_rec.LEGAL_ENTITY_ID              :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEGAL_ENTITY_ID(1);
    l_event_class_rec.LEDGER_ID                    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEDGER_ID(1);
    l_event_class_rec.APPLICATION_ID               :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLICATION_ID(1);
    l_event_class_rec.ENTITY_CODE                  :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ENTITY_CODE(1);
    l_event_class_rec.EVENT_CLASS_CODE             :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_CLASS_CODE(1);
    l_event_class_rec.EVENT_TYPE_CODE              :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_TYPE_CODE(1);
    l_event_class_rec.CTRL_TOTAL_HDR_TX_AMT        :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CTRL_TOTAL_HDR_TX_AMT(1);
    l_event_class_rec.TRX_ID                       :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID(1);
    l_event_class_rec.TRX_DATE                     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DATE(1);
    l_event_class_rec.REL_DOC_DATE                 :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_DATE(1);
    l_event_class_rec.PROVNL_TAX_DETERMINATION_DATE:=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PROVNL_TAX_DETERMINATION_DATE(1);
    l_event_class_rec.TRX_CURRENCY_CODE            :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_CURRENCY_CODE(1);
    l_event_class_rec.PRECISION                    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRECISION(1);
    l_event_class_rec.CURRENCY_CONVERSION_TYPE     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_TYPE(1);
    l_event_class_rec.CURRENCY_CONVERSION_RATE     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_RATE(1);
    l_event_class_rec.CURRENCY_CONVERSION_DATE     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_DATE(1);
    l_event_class_rec.ROUNDING_SHIP_TO_PARTY_ID    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_SHIP_TO_PARTY_ID(1);
    l_event_class_rec.ROUNDING_SHIP_FROM_PARTY_ID  :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_SHIP_FROM_PARTY_ID(1);
    l_event_class_rec.ROUNDING_BILL_TO_PARTY_ID    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_BILL_TO_PARTY_ID(1);
    l_event_class_rec.ROUNDING_BILL_FROM_PARTY_ID  :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_BILL_FROM_PARTY_ID(1);
    l_event_class_rec.RNDG_SHIP_TO_PARTY_SITE_ID   :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_SHIP_TO_PARTY_SITE_ID(1);
    l_event_class_rec.RNDG_SHIP_FROM_PARTY_SITE_ID :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_SHIP_FROM_PARTY_SITE_ID(1);
    l_event_class_rec.RNDG_BILL_TO_PARTY_SITE_ID   :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_BILL_TO_PARTY_SITE_ID(1);
    l_event_class_rec.RNDG_BILL_FROM_PARTY_SITE_ID :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_BILL_FROM_PARTY_SITE_ID(1);

    --Check if need to upgrade
    l_record_exists := FALSE;
    IF l_event_class_rec.event_type_code = 'INV_UPDATE' THEN
      FOR l_line_det_rec in lock_line_det_factors_for_doc(l_event_class_rec)
      LOOP
        l_record_exists := TRUE;
        l_event_class_rec.event_id := l_line_det_rec.event_id;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.default_taxation_country(1) := l_line_det_rec.default_taxation_country;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.document_sub_type(1)        := l_line_det_rec.document_sub_type;
        EXIT;
      END LOOP;
      IF NOT(l_record_exists) THEN
        --Bugfix 4486946 -Call on the fly upgrade if the transaction if not found
        l_upg_trx_info_rec.application_id   := l_event_class_rec.application_id;
        l_upg_trx_info_rec.entity_code      := l_event_class_rec.entity_code;
        l_upg_trx_info_rec.event_class_code := l_event_class_rec.event_class_code;
        l_upg_trx_info_rec.trx_id           := l_event_class_rec.trx_id;
        ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly(p_upg_trx_info_rec   =>  l_upg_trx_info_rec,
                                                     x_return_status      =>  l_return_status
                                                    );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly returned errors');
          END IF;
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;
        FOR l_line_det_rec in lock_line_det_factors_for_doc(l_event_class_rec)
        LOOP
          l_record_exists := TRUE;
          l_event_class_rec.event_id := l_line_det_rec.event_id;
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.default_taxation_country(1) := l_line_det_rec.default_taxation_country;
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.document_sub_type(1)        := l_line_det_rec.document_sub_type;
          EXIT;
        END LOOP;
      END IF; --record does not exist so upgrade
    --Bugfix 4486946 - on-the-fly upgrade end
    END IF;    --event_type_code

   /*------------------------------------------------------------------------------------------+
    | Set the event id for the whole document- Since this API is called for each transaction   |
    | line, the event id needs to be generated from the sequence only for the first transaction|
    | line. For other lines, we need to retrieve the event id from the table.                  |
    +-----------------------------------------------------------------------------------------*/
    IF NOT(l_record_exists) THEN
      SELECT ZX_LINES_DET_FACTORS_S.nextval
       INTO l_event_class_rec.event_id
       FROM dual;
    END IF;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
            'application_id: '||to_char(l_event_class_rec.application_id)||
             ', entity_code: '||l_event_class_rec.entity_code||
             ', event_class_code: '||l_event_class_rec.event_class_code||
             ', event_type_code: '||l_event_class_rec.event_type_code||
             ', trx_id: '||to_char(l_event_class_rec.trx_id)||
             ', internal_organization_id: '||to_char(l_event_class_rec.internal_organization_id)||
             ', ledger_id: '||to_char(l_event_class_rec.ledger_id)||
             ', legal_entity_id: '||to_char(l_event_class_rec.legal_entity_id)||
             ', trx_date: '||to_char(l_event_class_rec.trx_date)||
             ', related_document_date: '||to_char(l_event_class_rec.rel_doc_date)||
             ', provnl_tax_determination_date: '||to_char(l_event_class_rec.provnl_tax_determination_date)||
             ', trx_currency_code: '||l_event_class_rec.trx_currency_code||
             ', currency_conversion_type: '||l_event_class_rec.currency_conversion_type||
             ', currency_conversion_rate: '||to_char(l_event_class_rec.currency_conversion_rate)||
             ', currency_conversion_date: '||to_char(l_event_class_rec.currency_conversion_date)||
             ', rounding_ship_to_party_id: '||to_char(l_event_class_rec.rounding_ship_to_party_id)||
             ', rounding_ship_from_party_id: '||to_char(l_event_class_rec.rounding_ship_from_party_id)||
             ', rounding_bill_to_party_id: '||to_char(l_event_class_rec.rounding_bill_to_party_id)||
             ', rounding_bill_from_party_id: '||to_char(l_event_class_rec.rounding_bill_from_party_id)||
             ', rndg_ship_to_party_site_id: '||to_char(l_event_class_rec.rndg_ship_to_party_site_id)||
             ', rndg_ship_from_party_site_id: '||to_char(l_event_class_rec.rndg_ship_from_party_site_id)||
             ', rndg_bill_to_party_site_id: '||to_char(l_event_class_rec.rndg_bill_to_party_site_id)||
             ', rndg_bill_from_party_site_id: '||to_char(l_event_class_rec.rndg_bill_from_party_site_id)
            );
    END IF;

    /*------------------------------------------------------+
    |   Validate and Initializate parameters for Inserting |
    |   into line_det_factors                              |
    +------------------------------------------------------*/
    ZX_VALID_INIT_PARAMS_PKG.insupd_line_det_factors(p_event_class_rec =>l_event_class_rec,
                                                     p_trx_line_index  =>1,
                                                     x_return_status   =>l_return_status
                                                    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_VALID_INIT_PARAMS_PKG.insupd_line_det_factors returned errors');
      END IF;
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    /*------------------------------------------+
    |Call to insert the lines                   |
    +------------------------------------------*/
    ZX_SRVC_TYP_PKG.insupd_line_det_factors(p_event_class_rec  => l_event_class_rec,
                                            x_return_status    => l_return_status
                                           );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_SRVC_TYP_PKG.insupd_line_det_factors returned errors');
      END IF;
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    --Delete from the global structures so that there are no hanging/redundant
    --records sitting there
    ZX_GLOBAL_STRUCTURES_PKG.delete_trx_line_dist_tbl;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
    END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Insert_Line_Det_Factors_PVT;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          DUMP_MSG;
         /*---------------------------------------------------------+
          | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
          | in the message stack. If there is only one message in   |
          | the stack it retrieves this message                     |
          +---------------------------------------------------------*/
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                    p_count  =>      x_msg_count,
                                    p_data   =>      x_msg_data
                                    );

           IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
           END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Insert_Line_Det_Factors_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          DUMP_MSG;
          FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
          FND_MSG_PUB.Add;
         /*---------------------------------------------------------+
          | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
          | in the message stack. If there is only one message in   |
          | the stack it retrieves this message                     |
          +---------------------------------------------------------*/
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                    p_count   =>      x_msg_count,
                                    p_data    =>      x_msg_data
                                    );
          IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
          END IF;

        WHEN OTHERS THEN
          /*-------------------------------------------------------+
           |  Handle application errors that result from trapable  |
           |  error conditions. The error messages have already    |
           |  been put on the error stack.                         |
           +-------------------------------------------------------*/
           ROLLBACK TO Insert_Line_Det_Factors_PVT;
           IF (SQLCODE = 54) THEN
             x_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MESSAGE.SET_NAME('ZX','ZX_RESOURCE_BUSY');
           ELSE
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
           END IF;
           FND_MSG_PUB.Add;
         /*---------------------------------------------------------+
          | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
          | in the message stack. If there is only one message in   |
          | the stack it retrieves this message                     |
          +---------------------------------------------------------*/
           FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                     p_count  =>      x_msg_count,
                                     p_data   =>      x_msg_data
                                     );

           IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;
  END insert_line_det_factors;


/* ========================================================================*
 | PROCEDURE  update_det_factors_hdr: This procedure should be called by   |
 | products when updating any of the header attributes on the transaction  |
 | so that the tax repository is also in sync with the header level updates|
 |                                                                         |
 | NOTES: Products will pass intended nullable values as null while they   |
 | will pass G_MISS_NUM/G_MISS_DATE/G_MISS_CHAR for the attributes where   |
 | intention is to retain the original values as stored in tax repository  |
 * =======================================================================*/

 PROCEDURE update_det_factors_hdr
 (
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2,
  p_commit              IN  VARCHAR2,
  p_validation_level    IN  NUMBER,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_hdr_det_factors_rec IN  header_det_factors_rec_type
 )IS
  l_api_name                   CONSTANT  VARCHAR2(30) := 'UPDATE_DET_FACTORS_HDR';
  l_api_version                CONSTANT  NUMBER := 1.0;
  l_return_status              VARCHAR2(1);
  l_event_class_rec            event_class_rec_type;
  l_init_msg_list              VARCHAR2(1);
  l_rdng_ship_to_ptp_id        NUMBER;
  l_rdng_bill_to_ptp_id        NUMBER;
  l_rdng_ship_from_ptp_id      NUMBER;
  l_rdng_bill_from_ptp_id      NUMBER;
  l_rdng_bill_to_ptp_st_id     NUMBER;
  l_rdng_bill_from_ptp_st_id   NUMBER;
  l_rdng_ship_to_ptp_st_id     NUMBER;
  l_rdng_ship_from_ptp_st_id   NUMBER;
  l_ship_to_ptp_id             NUMBER;
  l_ship_from_ptp_id           NUMBER;
  l_bill_to_ptp_id             NUMBER;
  l_bill_from_ptp_id           NUMBER;
  l_ship_to_ptp_site_id        NUMBER;
  l_ship_from_ptp_site_id      NUMBER;
  l_bill_to_ptp_site_id        NUMBER;
  l_bill_from_ptp_site_id      NUMBER;
  l_poa_ptp_id                 NUMBER;
  l_poo_ptp_id                 NUMBER;
  l_poo_ptp_site_id            NUMBER;
  l_poa_ptp_site_id            NUMBER;
  l_hq_estb_ptp_id             NUMBER;
  l_party_type                 VARCHAR2(30);
  l_transaction_rec            transaction_rec_type;
  l_upg_trx_info_rec           ZX_ON_FLY_TRX_UPGRADE_PKG.zx_upg_trx_info_rec_type;
  l_incomplete_scenario        number;

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Update_Det_Factors_Hdr_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   /*--------------------------------------------------------------+
    |   Initialize message list if p_init_msg_list is set to TRUE  |
    +--------------------------------------------------------------*/
    IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
    ELSE
       l_init_msg_list := p_init_msg_list;
    END IF;

    IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

   /*-----------------------------------------+
    |   Initialize return status to SUCCESS   |
    +-----------------------------------------*/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   /*-----------------------------------------+
    |   Populate Global Variable              |
    +-----------------------------------------*/
    G_PUB_SRVC := 'UPDATE_DET_FACTORS_HDR';
    G_DATA_TRANSFER_MODE := 'PLS';
    G_EXTERNAL_API_CALL  := 'N';
    /*
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Passed in data: APPLICATION_ID: '||to_char(p_hdr_det_factors_rec.application_id)||
              ', ENTITY_CODE: '||p_hdr_det_factors_rec.entity_code||
              ', EVENT_CLASS_CODE: '||p_hdr_det_factors_rec.event_class_code||
	      ', EVENT_TYPE_CODE: '||p_hdr_det_factors_rec.event_type_code||
              ', TRX_ID: '||to_char(p_hdr_det_factors_rec.trx_id)||
              ', INTERNAL_ORGANIZATION_ID: '|| to_char(p_hdr_det_factors_rec.internal_organization_id)||
	      ', INTERNAL_ORG_LOCATION_ID : '|| to_char(p_hdr_det_factors_rec.internal_org_location_id)||
	      ', LEGAL_ENTITY_ID :'||to_char(p_hdr_det_factors_rec.legal_entity_id)||
              ', LEDGER_ID :' ||to_char(p_hdr_det_factors_rec.ledger_id)||
              ', TRX_DATE :' ||to_char(p_hdr_det_factors_rec.trx_date)||
              ', TRX_DOC_REVISION :' ||p_hdr_det_factors_rec.trx_doc_revision||
              ', TRX_CURRENCY_CODE :' ||p_hdr_det_factors_rec.trx_currency_code ||
              ', CURRENCY_CONVERSION_TYPE  :' ||p_hdr_det_factors_rec.currency_conversion_type ||
              ', CURRENCY_CONVERSION_RATE :' ||to_char(p_hdr_det_factors_rec.currency_conversion_rate) ||
              ', CURRENCY_CONVERSION_DATE :' ||to_char(p_hdr_det_factors_rec.currency_conversion_date) ||
              ', MINIMUM_ACCOUNTABLE_UNIT: ' ||to_char(p_hdr_det_factors_rec.minimum_accountable_unit)||
              ', PRECISION:' ||to_char(p_hdr_det_factors_rec.precision) ||
              ', ROUNDING_SHIP_TO_PARTY_ID : '||to_char(p_hdr_det_factors_rec.rounding_ship_to_party_id)||
              ', ROUNDING_SHIP_FROM_PARTY_ID: '||to_char(p_hdr_det_factors_rec.rounding_ship_from_party_id)||
              ', ROUNDING_BILL_TO_PARTY_ID: '||to_char(p_hdr_det_factors_rec.rounding_bill_to_party_id)||
              ', ROUNDING_BILL_FROM_PARTY_ID :'||to_char(p_hdr_det_factors_rec.rounding_bill_from_party_id)||
              ', RNDG_SHIP_TO_PARTY_SITE_ID :'||to_char(p_hdr_det_factors_rec.rndg_ship_to_party_site_id)||
              ', RNDG_SHIP_FROM_PARTY_SITE_ID :'||to_char(p_hdr_det_factors_rec.rndg_ship_from_party_site_id)||
              ', RNDG_BILL_TO_PARTY_SITE_ID :'||to_char(p_hdr_det_factors_rec.rndg_bill_to_party_site_id)||
              ', RNDG_BILL_FROM_PARTY_SITE_ID :'||to_char(p_hdr_det_factors_rec.rndg_bill_from_party_site_id)||
              ', QUOTE_FLAG :'||p_hdr_det_factors_rec.quote_flag||
              ', ESTABLISHMENT_ID :'||to_char(p_hdr_det_factors_rec.establishment_id)||
              ', RECEIVABLES_TRX_TYPE_ID :'||to_char(p_hdr_det_factors_rec.receivables_trx_type_id)||
              ', RELATED_DOC_APPLICATION_ID :'||to_char(p_hdr_det_factors_rec.related_doc_application_id)||
              ', RELATED_DOC_ENTITY_CODE :'||p_hdr_det_factors_rec.related_doc_entity_code||
              ', RELATED_DOC_EVENT_CLASS_CODE :'||p_hdr_det_factors_rec.related_doc_event_class_code||
              ', RELATED_DOC_TRX_ID :'||to_char(p_hdr_det_factors_rec.related_doc_trx_id)||
              ', RELATED_DOC_NUMBER :'||to_char(p_hdr_det_factors_rec.related_doc_number)||
              ', RELATED_DOC_DATE :'||to_char(p_hdr_det_factors_rec.related_doc_date)||
              ', DEFAULT_TAXATION_COUNTRY :'||p_hdr_det_factors_rec.default_taxation_country||
              ', CTRL_TOTAL_HDR_TX_AMT :'||to_char(p_hdr_det_factors_rec.ctrl_total_hdr_tx_amt)||
              ', TRX_NUMBER :'||p_hdr_det_factors_rec.trx_number||
              ', TRX_DESCRIPTION :'||p_hdr_det_factors_rec.trx_description||
              ', TRX_COMMUNICATED_DATE :'||to_char(p_hdr_det_factors_rec.trx_communicated_date)||
              ', BATCH_SOURCE_ID :'||to_char(p_hdr_det_factors_rec.batch_source_id)||
              ', BATCH_SOURCE_NAME :'||p_hdr_det_factors_rec.batch_source_name||
              ', DOC_SEQ_ID :'||to_char(p_hdr_det_factors_rec.doc_seq_id)||
              ', DOC_SEQ_NAME :'||p_hdr_det_factors_rec.doc_seq_id||
              ', DOC_SEQ_VALUE :'||p_hdr_det_factors_rec.doc_seq_value||
              ', TRX_DUE_DATE :'||to_char(p_hdr_det_factors_rec.trx_due_date)||
              ', TRX_TYPE_DESCRIPTION :'||p_hdr_det_factors_rec.trx_type_description
              );
    END IF;
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
              ', DOCUMENT_SUB_TYPE :'||p_hdr_det_factors_rec.document_sub_type||
              ', SUPPLIER_TAX_INVOICE_NUMBER :'||p_hdr_det_factors_rec.supplier_tax_invoice_number||
              ', SUPPLIER_TAX_INVOICE_DATE :'||to_char(p_hdr_det_factors_rec.supplier_tax_invoice_date)||
              ', SUPPLIER_EXCHANGE_RATE :'||to_char(p_hdr_det_factors_rec.supplier_exchange_rate)||
              ', TAX_INVOICE_DATE :'||to_char(p_hdr_det_factors_rec.tax_invoice_date)||
              ', TAX_INVOICE_NUMBER :'||p_hdr_det_factors_rec.tax_invoice_date||
              ', FIRST_PTY_ORG_ID :'||to_char(p_hdr_det_factors_rec.first_pty_org_id)||
              ', TAX_EVENT_CLASS_CODE :'||p_hdr_det_factors_rec.tax_event_class_code||
              ', TAX_EVENT_TYPE_CODE :'||p_hdr_det_factors_rec.tax_event_type_code||
              ', DOC_EVENT_STATUS :'||p_hdr_det_factors_rec.doc_event_status||
              ', PORT_OF_ENTRY_CODE :'||p_hdr_det_factors_rec.port_of_entry_code||
              ', TAX_REPORTING_FLAG :'||p_hdr_det_factors_rec.tax_reporting_flag||
              ', PROVNL_TAX_DETERMINATION_DATE :'||to_char(p_hdr_det_factors_rec.provnl_tax_determination_date)||
              ', SHIP_THIRD_PTY_ACCT_ID :'||to_char(p_hdr_det_factors_rec.ship_third_pty_acct_id)||
              ', BILL_THIRD_PTY_ACCT_ID :'||to_char(p_hdr_det_factors_rec.bill_third_pty_acct_id)||
              ', SHIP_THIRD_PTY_ACCT_SITE_ID :'||to_char(p_hdr_det_factors_rec.ship_third_pty_acct_site_id)||
              ', BILL_THIRD_PTY_ACCT_SITE_ID :'||to_char(p_hdr_det_factors_rec.bill_third_pty_acct_site_id)||
              ', SHIP_TO_CUST_ACCT_SITE_USE_ID :'||to_char(p_hdr_det_factors_rec.ship_to_cust_acct_site_use_id)||
              ', BILL_TO_CUST_ACCT_SITE_USE_ID :'||to_char(p_hdr_det_factors_rec.bill_to_cust_acct_site_use_id)||
              ', TRX_BATCH_ID :'||to_char(p_hdr_det_factors_rec.trx_batch_id)||
              ', APPLIED_TO_TRX_NUMBER :'||p_hdr_det_factors_rec.applied_to_trx_number||
              ', APPLICATION_DOC_STATUS :'||p_hdr_det_factors_rec.application_doc_status||
              ', SHIP_TO_PARTY_ID :'||to_char(p_hdr_det_factors_rec.ship_to_party_id)||
              ', SHIP_FROM_PARTY_ID :'||to_char(p_hdr_det_factors_rec.ship_from_party_id)||
              ', POA_PARTY_ID :'||to_char(p_hdr_det_factors_rec.poa_party_id)||
              ', POO_PARTY_ID :'||to_char(p_hdr_det_factors_rec.poo_party_id)||
              ', BILL_TO_PARTY_ID :'||to_char(p_hdr_det_factors_rec.bill_to_party_id)||
              ', BILL_FROM_PARTY_ID :'||to_char(p_hdr_det_factors_rec.bill_from_party_id)||
              ', MERCHANT_PARTY_ID :'||to_char(p_hdr_det_factors_rec.merchant_party_id)||
              ', SHIP_TO_PARTY_SITE_ID :'||to_char(p_hdr_det_factors_rec.ship_to_party_site_id)||
              ', SHIP_FROM_PARTY_SITE_ID :'||to_char(p_hdr_det_factors_rec.ship_from_party_site_id)||
              ', POA_PARTY_SITE_ID :'||to_char(p_hdr_det_factors_rec.poa_party_site_id)||
              ', POO_PARTY_SITE_ID :'||to_char(p_hdr_det_factors_rec.poo_party_site_id)||
              ', BILL_TO_PARTY_SITE_ID :'||to_char(p_hdr_det_factors_rec.bill_to_party_site_id)||
              ', BILL_FROM_PARTY_SITE_ID :'||to_char(p_hdr_det_factors_rec.bill_from_party_site_id)||
              ', SHIP_TO_LOCATION_ID :'||to_char(p_hdr_det_factors_rec.ship_to_location_id)||
              ', SHIP_FROM_LOCATION_ID :'||to_char(p_hdr_det_factors_rec.ship_from_location_id)||
              ', POA_LOCATION_ID :'||to_char(p_hdr_det_factors_rec.poa_location_id)||
              ', POO_LOCATION_ID :'||to_char(p_hdr_det_factors_rec.poo_location_id)||
              ', BILL_TO_LOCATION_ID :'||to_char(p_hdr_det_factors_rec.bill_to_location_id)||
              ', BILL_FROM_LOCATION_ID :'||to_char(p_hdr_det_factors_rec.bill_from_location_id)||
              ', PAYING_PARTY_ID :'||to_char(p_hdr_det_factors_rec.paying_party_id)||
              ', OWN_HQ_PARTY_ID :'||to_char(p_hdr_det_factors_rec.own_hq_party_id)||
              ', TRADING_HQ_PARTY_ID :'||to_char(p_hdr_det_factors_rec.trading_hq_party_id)||
              ', POI_PARTY_ID :'||to_char(p_hdr_det_factors_rec.poi_party_id)
              );
    END IF;
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
              ', POD_PARTY_ID :'||to_char(p_hdr_det_factors_rec.pod_party_id)||
              ', TITLE_TRANSFER_PARTY_ID :'||to_char(p_hdr_det_factors_rec.title_transfer_party_id)||
              ', PAYING_PARTY_SITE_ID :'||to_char(p_hdr_det_factors_rec.paying_party_site_id)||
              ', OWN_HQ_PARTY_SITE_ID :'||to_char(p_hdr_det_factors_rec.own_hq_party_site_id)||
              ', TRADING_HQ_PARTY_SITE_ID :'||to_char(p_hdr_det_factors_rec.trading_hq_party_site_id)||
              ', POI_PARTY_SITE_ID :'||to_char(p_hdr_det_factors_rec.poi_party_site_id)||
              ', POD_PARTY_SITE_ID :'||to_char(p_hdr_det_factors_rec.pod_party_site_id)||
              ', TITLE_TRANSFER_PARTY_SITE_ID :'||to_char(p_hdr_det_factors_rec.title_transfer_party_site_id)||
              ', PAYING_LOCATION_ID :'||to_char(p_hdr_det_factors_rec.paying_location_id)||
              ', OWN_HQ_LOCATION_ID :'||to_char(p_hdr_det_factors_rec.own_hq_location_id)||
              ', TRADING_HQ_LOCATION_ID :'||to_char(p_hdr_det_factors_rec.trading_hq_location_id)||
              ', POC_LOCATION_ID :'||to_char(p_hdr_det_factors_rec.poc_location_id)||
              ', POI_LOCATION_ID :'||to_char(p_hdr_det_factors_rec.poi_location_id)||
              ', POD_LOCATION_ID :'||to_char(p_hdr_det_factors_rec.pod_location_id)||
              ', TITLE_TRANSFER_LOCATION_ID :'||to_char(p_hdr_det_factors_rec.title_transfer_location_id)
              );
     END IF;
     */
   /*------------------------------------------------------+
    |   Populate the event class record structure          |
    +------------------------------------------------------*/
    l_event_class_rec.application_id               :=  p_hdr_det_factors_rec.application_id;
    l_event_class_rec.entity_code                  :=  p_hdr_det_factors_rec.entity_code;
    l_event_class_rec.event_class_code             :=  p_hdr_det_factors_rec.event_class_code;
    l_event_class_rec.event_type_code              :=  p_hdr_det_factors_rec.event_type_code;
    l_event_class_rec.trx_id                       :=  p_hdr_det_factors_rec.trx_id;
    l_event_class_rec.trx_date                     :=  p_hdr_det_factors_rec.trx_date;
    l_event_class_rec.internal_organization_id     :=  p_hdr_det_factors_rec.internal_organization_id;
    l_event_class_rec.legal_entity_id              :=  p_hdr_det_factors_rec.legal_entity_id;
    l_event_class_rec.rel_doc_date                 :=  p_hdr_det_factors_rec.related_doc_date;
    l_event_class_rec.trx_currency_code            :=  p_hdr_det_factors_rec.trx_currency_code;
    l_event_class_rec.precision                    :=  p_hdr_det_factors_rec.precision;
    l_event_class_rec.currency_conversion_type     :=  p_hdr_det_factors_rec.currency_conversion_type;
    l_event_class_rec.currency_conversion_rate     :=  p_hdr_det_factors_rec.currency_conversion_rate;
    l_event_class_rec.currency_conversion_date     :=  p_hdr_det_factors_rec.currency_conversion_date;
    l_event_class_rec.rounding_ship_to_party_id    :=  p_hdr_det_factors_rec.rounding_ship_to_party_id;
    l_event_class_rec.rounding_ship_from_party_id  :=  p_hdr_det_factors_rec.rounding_ship_from_party_id;
    l_event_class_rec.rounding_bill_to_party_id    :=  p_hdr_det_factors_rec.rounding_bill_to_party_id;
    l_event_class_rec.rounding_bill_from_party_id  :=  p_hdr_det_factors_rec.rounding_bill_from_party_id;
    l_event_class_rec.rndg_ship_to_party_site_id   :=  p_hdr_det_factors_rec.rndg_ship_to_party_site_id;
    l_event_class_rec.rndg_ship_from_party_site_id :=  p_hdr_det_factors_rec.rndg_ship_from_party_site_id;
    l_event_class_rec.rndg_bill_to_party_site_id   :=  p_hdr_det_factors_rec.rndg_bill_to_party_site_id;
    l_event_class_rec.rndg_bill_from_party_site_id :=  p_hdr_det_factors_rec.rndg_bill_from_party_site_id;

    OPEN lock_line_det_factors_for_doc(l_event_class_rec);
    CLOSE lock_line_det_factors_for_doc;

   /*------------------------------------------------------+
    |   Bug 5371288: Check if AR has called this API       |
    |   to incomplete the transaction                      |
    +------------------------------------------------------*/

    IF p_hdr_det_factors_rec.application_id = 222 THEN
       l_incomplete_scenario := 0;
       BEGIN
          SELECT 1
            INTO l_incomplete_scenario
            FROM zx_lines_det_factors
          WHERE  event_class_code    = p_hdr_det_factors_rec.event_class_code
            AND  application_id      = p_hdr_det_factors_rec.application_id
            AND  entity_code         = p_hdr_det_factors_rec.entity_code
            AND  trx_id              = p_hdr_det_factors_rec.trx_id
            AND  tax_event_type_code = 'VALIDATE_FOR_TAX'
            AND  rownum              = 1;
       EXCEPTION
          WHEN OTHERS THEN
                 l_incomplete_scenario := 0;
       END;

       IF l_incomplete_scenario = 1 THEN
          BEGIN
             SELECT zxevnttyp.tax_event_type_code,
                    zxevnttyp.status_code
               INTO l_event_class_rec.tax_event_type_code,
                    l_event_class_rec.doc_status_code
               FROM ZX_EVNT_TYP_MAPPINGS zxevntmap,
                    ZX_EVNT_CLS_TYPS zxevnttyp
             WHERE  zxevntmap.event_class_code     = p_hdr_det_factors_rec.event_class_code
               AND  zxevntmap.application_id       = p_hdr_det_factors_rec.application_id
               AND  zxevntmap.entity_code          = p_hdr_det_factors_rec.entity_code
               AND  zxevntmap.event_type_code      = p_hdr_det_factors_rec.event_type_code
               AND  zxevnttyp.tax_event_type_code  = zxevntmap.tax_event_type_code
               AND  zxevnttyp.tax_event_class_code = zxevntmap.tax_event_class_code
               AND  zxevntmap.enabled_flag = 'Y';
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                    ' Incorrect event information passed in for event type :' ||p_hdr_det_factors_rec.event_type_code ||' Please Check!');
                 END IF;
          END;
          BEGIN
             UPDATE ZX_LINES_DET_FACTORS
               SET TAX_EVENT_TYPE_CODE = l_event_class_rec.tax_event_type_code,
                   DOC_EVENT_STATUS    = l_event_class_rec.doc_status_code
             WHERE APPLICATION_ID   = p_hdr_det_factors_rec.APPLICATION_ID
              AND ENTITY_CODE       = p_hdr_det_factors_rec.ENTITY_CODE
              AND EVENT_CLASS_CODE  = p_hdr_det_factors_rec.EVENT_CLASS_CODE
              AND TRX_ID            = p_hdr_det_factors_rec.TRX_ID;
          END;
          RETURN;
       END IF;
    END IF;

   /*------------------------------------------------------+
    |   Validate and Initializate parameters for Inserting |
    |   into line_det_factors                              |
    +------------------------------------------------------*/
    ZX_VALID_INIT_PARAMS_PKG.insupd_line_det_factors(p_event_class_rec =>l_event_class_rec,
                                                     p_trx_line_index  => NULL,
                                                     x_return_status   =>l_return_status
                                                    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_VALID_INIT_PARAMS_PKG.insupd_line_det_factors returned errors');
      END IF;
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

   /*-----------------------------------------+
    |Derive the PTPs                          |
    +-----------------------------------------*/
    IF p_hdr_det_factors_rec.rounding_ship_to_party_id is NOT NULL AND
       p_hdr_det_factors_rec.rounding_ship_to_party_id <> FND_API.G_MISS_NUM THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' Call TCM API to get ptp for rounding_ship_to_party_id: '||
                                                                       to_char(p_hdr_det_factors_rec.rounding_ship_to_party_id));
       END IF;
       ZX_TCM_PTP_PKG.get_ptp(p_hdr_det_factors_rec.rounding_ship_to_party_id
                             ,ZX_VALID_INIT_PARAMS_PKG.source_rec.ship_to_party_type
                             ,p_hdr_det_factors_rec.legal_entity_id
                             ,p_hdr_det_factors_rec.ship_to_location_id
                             ,l_rdng_ship_to_ptp_id
                             ,l_return_status
                             );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
             ':ZX_TCM_PTP_PKG.get_ptp for rounding_ship_to_party_id returned errors');
           END IF;
           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
         END IF;
    END IF;

    IF p_hdr_det_factors_rec.rounding_ship_from_party_id is NOT NULL AND
       p_hdr_det_factors_rec.rounding_ship_from_party_id <> FND_API.G_MISS_NUM THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' Call TCM API to get ptp for rounding_ship_from_party_id: '||
                                                                       to_char(p_hdr_det_factors_rec.rounding_ship_from_party_id));
       END IF;
       ZX_TCM_PTP_PKG.get_ptp(p_hdr_det_factors_rec.rounding_ship_from_party_id
                             ,ZX_VALID_INIT_PARAMS_PKG.source_rec.ship_from_party_type
                             ,p_hdr_det_factors_rec.legal_entity_id
                             ,p_hdr_det_factors_rec.ship_from_location_id
                             ,l_rdng_ship_from_ptp_id
                             ,l_return_status
                             );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
             ':ZX_TCM_PTP_PKG.get_ptp for rounding_ship_from_party_id returned errors');
           END IF;
           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
         END IF;
    END IF;

    IF p_hdr_det_factors_rec.rndg_ship_to_party_site_id is NOT NULL AND
       p_hdr_det_factors_rec.rndg_ship_to_party_site_id <> FND_API.G_MISS_NUM THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' Call TCM API to get ptp for rndg_ship_to_party_site_id: '||
                                                                       to_char(p_hdr_det_factors_rec.rndg_ship_to_party_site_id));
       END IF;
       ZX_TCM_PTP_PKG.get_ptp( p_hdr_det_factors_rec.rndg_ship_to_party_site_id
                              ,ZX_VALID_INIT_PARAMS_PKG.source_rec.ship_to_pty_site_type
                              ,p_hdr_det_factors_rec.legal_entity_id
                              ,null
                              ,l_rdng_ship_to_ptp_st_id
                              ,l_return_status
                              );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
             ':ZX_TCM_PTP_PKG.get_ptp for rndg_ship_to_party_site_id returned errors');
           END IF;
           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
         END IF;
    END IF;

    IF p_hdr_det_factors_rec.rndg_ship_from_party_site_id is NOT NULL AND
       p_hdr_det_factors_rec.rndg_ship_from_party_site_id <> FND_API.G_MISS_NUM THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' Call TCM API to get ptp for rndg_ship_from_party_site_id: '||
                                                                       to_char(p_hdr_det_factors_rec.rndg_ship_from_party_site_id));
       END IF;
       ZX_TCM_PTP_PKG.get_ptp( p_hdr_det_factors_rec.rndg_ship_from_party_site_id
                               ,ZX_VALID_INIT_PARAMS_PKG.source_rec.ship_from_pty_site_type
                               ,p_hdr_det_factors_rec.legal_entity_id
                               ,null
                               ,l_rdng_ship_from_ptp_st_id
                               ,l_return_status
                               );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
             ':ZX_TCM_PTP_PKG.get_ptp for rndg_ship_from_party_site_id returned errors');
           END IF;
           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
         END IF;
      END IF;

      IF p_hdr_det_factors_rec.rounding_bill_to_party_id is NOT NULL  AND
       p_hdr_det_factors_rec.rounding_bill_to_party_id <> FND_API.G_MISS_NUM THEN
        IF (p_hdr_det_factors_rec.rounding_bill_to_party_id <> p_hdr_det_factors_rec.rounding_ship_to_party_id)
           OR (ZX_VALID_INIT_PARAMS_PKG.source_rec.ship_to_party_type <> ZX_VALID_INIT_PARAMS_PKG.source_rec.bill_to_party_type)
		   OR  p_hdr_det_factors_rec.rounding_ship_to_party_id is null THEN
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' Call TCM API to get ptp for rounding_bill_to_party_id: '||
                                                                       to_char(p_hdr_det_factors_rec.rounding_bill_to_party_id));
           END IF;
           ZX_TCM_PTP_PKG.get_ptp(p_hdr_det_factors_rec.rounding_bill_to_party_id
                                 ,ZX_VALID_INIT_PARAMS_PKG.source_rec.bill_to_party_type
                                 ,p_hdr_det_factors_rec.legal_entity_id
                                 ,p_hdr_det_factors_rec.bill_to_location_id
                                 ,l_rdng_bill_to_ptp_id
                                 ,l_return_status
                                 );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
                ':ZX_TCM_PTP_PKG.get_ptp for rounding_bill_to_party_id returned errors');
             END IF;
             IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
           END IF;
        ELSE
          l_rdng_bill_to_ptp_id := l_rdng_ship_to_ptp_id;
        END IF;
      END IF;

      IF p_hdr_det_factors_rec.rounding_bill_from_party_id is NOT NULL AND
         p_hdr_det_factors_rec.rounding_bill_from_party_id <> FND_API.G_MISS_NUM THEN
         IF (p_hdr_det_factors_rec.rounding_bill_from_party_id <> p_hdr_det_factors_rec.rounding_ship_from_party_id)
           OR (ZX_VALID_INIT_PARAMS_PKG.source_rec.ship_from_party_type <> ZX_VALID_INIT_PARAMS_PKG.source_rec.bill_from_party_type)
		   OR  p_hdr_det_factors_rec.rounding_ship_from_party_id is null THEN
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' Call TCM API to get ptp for rounding_bill_from_party_id: '||
                                                                       to_char(p_hdr_det_factors_rec.rounding_bill_from_party_id));
           END IF;
           ZX_TCM_PTP_PKG.get_ptp(p_hdr_det_factors_rec.rounding_bill_from_party_id
                                 ,ZX_VALID_INIT_PARAMS_PKG.source_rec.bill_from_party_type
                                 ,p_hdr_det_factors_rec.legal_entity_id
                                 ,p_hdr_det_factors_rec.bill_from_location_id
                                 ,l_rdng_bill_from_ptp_id
                                 ,l_return_status
                                 );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
                ':ZX_TCM_PTP_PKG.get_ptp for rounding_bill_from_party_id returned errors');
             END IF;
             IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
           END IF;
        ELSE
          l_rdng_bill_from_ptp_id := l_rdng_ship_from_ptp_id;
        END IF;
      END IF;

      IF p_hdr_det_factors_rec.rndg_bill_to_party_site_id is NOT NULL AND
         p_hdr_det_factors_rec.rndg_bill_to_party_site_id <> FND_API.G_MISS_NUM THEN
         IF (p_hdr_det_factors_rec.rndg_bill_to_party_site_id <> p_hdr_det_factors_rec.rndg_ship_to_party_site_id)
           OR (ZX_VALID_INIT_PARAMS_PKG.source_rec.ship_to_pty_site_type <> ZX_VALID_INIT_PARAMS_PKG.source_rec.bill_to_pty_site_type)
		   OR  p_hdr_det_factors_rec.rndg_ship_to_party_site_id is null THEN
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' Call TCM API to get ptp for rndg_bill_to_party_site_id: '||
                                                                       to_char(p_hdr_det_factors_rec.rndg_bill_to_party_site_id));
           END IF;
           ZX_TCM_PTP_PKG.get_ptp(p_hdr_det_factors_rec.rndg_bill_to_party_site_id
                                 ,ZX_VALID_INIT_PARAMS_PKG.source_rec.bill_to_pty_site_type
                                 ,p_hdr_det_factors_rec.legal_entity_id
                                 ,null
                                 ,l_rdng_bill_to_ptp_st_id
                                 ,l_return_status
                                );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
                ':ZX_TCM_PTP_PKG.get_ptp for rndg_bill_to_party_site_id returned errors');
             END IF;
             IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
           END IF;
        ELSE
          l_rdng_bill_to_ptp_st_id := l_rdng_ship_to_ptp_st_id;
        END IF;
      END IF;

      IF p_hdr_det_factors_rec.rndg_bill_from_party_site_id is NOT NULL AND
         p_hdr_det_factors_rec.rndg_bill_to_party_site_id <> FND_API.G_MISS_NUM THEN
        IF p_hdr_det_factors_rec.rndg_bill_from_party_site_id <> p_hdr_det_factors_rec.rndg_ship_from_party_site_id
           OR (ZX_VALID_INIT_PARAMS_PKG.source_rec.ship_from_pty_site_type <> ZX_VALID_INIT_PARAMS_PKG.source_rec.bill_from_pty_site_type)
		   OR  p_hdr_det_factors_rec.rndg_ship_from_party_site_id is null THEN
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' Call TCM API to get ptp for rndg_bill_from_party_site_id: '||
                                                                       to_char(p_hdr_det_factors_rec.rndg_bill_from_party_site_id));
           END IF;
           ZX_TCM_PTP_PKG.get_ptp(p_hdr_det_factors_rec.rndg_bill_from_party_site_id
                                 ,ZX_VALID_INIT_PARAMS_PKG.source_rec.bill_from_pty_site_type
                                 ,p_hdr_det_factors_rec.legal_entity_id
                                 ,null
                                 ,l_rdng_bill_from_ptp_st_id
                                 ,l_return_status
                                 );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
                ':ZX_TCM_PTP_PKG.get_ptp for rndg_bill_from_party_site_id returned errors');
             END IF;
             IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
           END IF;
        ELSE
          l_rdng_bill_from_ptp_st_id := l_rdng_ship_from_ptp_st_id;
        END IF;
      END IF;

      --get_tax_profile_ids expects the following data legal entity id in zx_global_structures table.
      zx_global_structures_pkg.trx_line_dist_tbl.LEGAL_ENTITY_ID(1) := p_hdr_det_factors_rec.legal_entity_id;

      IF p_hdr_det_factors_rec.ship_to_party_id is not NULL AND
         p_hdr_det_factors_rec.ship_to_party_id <> FND_API.G_MISS_NUM THEN
        IF ((p_hdr_det_factors_rec.rounding_ship_to_party_id is NULL)
          OR ((p_hdr_det_factors_rec.rounding_ship_to_party_id is NOT NULL)
          AND (p_hdr_det_factors_rec.ship_to_party_id <>
              p_hdr_det_factors_rec.rounding_ship_to_party_id))) THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Get PTP Id for Ship To Party Id: '||
                                                                        to_char(p_hdr_det_factors_rec.ship_to_party_id));
          END IF;
          l_party_type := ZX_VALID_INIT_PARAMS_PKG.source_rec.ship_to_party_type;
          ZX_SRVC_TYP_PKG.get_tax_profile_ids(l_return_status,
                                               l_party_type,
                                               p_hdr_det_factors_rec.ship_to_party_id,
                                               p_hdr_det_factors_rec.ship_to_location_id,
                                               NULL,
                                               l_ship_to_ptp_id
                                              );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
                ':ZX_TCM_PTP_PKG.get_ptp for ship_to_party_id returned errors');
             END IF;
             IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
           END IF;
        ELSE /* Ship To Party is same as Rounding Ship To Party */
          l_ship_to_ptp_id := l_rdng_ship_to_ptp_id;
        END IF;
      END IF; /* Completed Condition Check for Ship To Party */


      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Call TCM API to get ptp for Legal Entity: '||
                                                                    to_char(p_hdr_det_factors_rec.legal_entity_id));
      END IF;

      ZX_TCM_PTP_PKG.get_ptp_hq(p_hdr_det_factors_rec.legal_entity_id,
                                l_hq_estb_ptp_id,
                                l_return_status
                                );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
             ':ZX_TCM_PTP_PKG.get_ptp for legal_entity_id returned errors');
        END IF;
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

      IF p_hdr_det_factors_rec.ship_from_party_id is NOT NULL AND
         p_hdr_det_factors_rec.ship_from_party_id <> FND_API.G_MISS_NUM THEN
         IF ((p_hdr_det_factors_rec.rounding_ship_from_party_id is NULL)
          OR ((p_hdr_det_factors_rec.rounding_ship_from_party_id is NOT NULL)
          AND (p_hdr_det_factors_rec.ship_from_party_id  <> p_hdr_det_factors_rec.rounding_ship_from_party_id))) THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Get PTP Id for Ship From Party Id: '||
                                                                       to_char(p_hdr_det_factors_rec.ship_from_party_id));
          END IF;
          l_party_type := ZX_VALID_INIT_PARAMS_PKG.source_rec.ship_from_party_type;
          ZX_SRVC_TYP_PKG.get_tax_profile_ids(l_return_status,
                                              l_party_type,
                                              p_hdr_det_factors_rec.ship_from_party_id,
                                              p_hdr_det_factors_rec.ship_from_location_id,
                                              NULL,
                                              l_ship_from_ptp_id
                                             );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
                ':ZX_TCM_PTP_PKG.get_ptp for ship_from_party_id returned errors');
            END IF;
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END IF;
        ELSE /* Ship from party is same as rounding ship from party */
          l_ship_from_ptp_id := l_rdng_ship_from_ptp_id;
        END IF;
     END IF; /* Completed condition check for ship from party */

    IF p_hdr_det_factors_rec.poa_party_tax_prof_id is NOT NULL  AND
       p_hdr_det_factors_rec.poa_party_tax_prof_id <> FND_API.G_MISS_NUM THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Get PTP Id for POA Party Id: '
                                                                     || to_char(p_hdr_det_factors_rec.poa_party_id));
       END IF;

       l_party_type := ZX_VALID_INIT_PARAMS_PKG.source_rec.poa_party_type;
       ZX_SRVC_TYP_PKG.get_tax_profile_ids(l_return_status,
                                           l_party_type ,
                                           p_hdr_det_factors_rec.poa_party_id,
                                           p_hdr_det_factors_rec.poa_location_id,
                                           NULL,
                                           l_poa_ptp_id
                                          );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
             ':ZX_TCM_PTP_PKG.get_ptp for poa_party_id returned errors');
         END IF;
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
        END IF;
      END IF; /* Completed condition check for poa party */


      IF p_hdr_det_factors_rec.poo_party_id is NOT NULL AND
        p_hdr_det_factors_rec.poa_party_tax_prof_id <> FND_API.G_MISS_NUM THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Get PTP Id for POO Party Id: '||
                                                                      to_char(p_hdr_det_factors_rec.poo_party_id));
        END IF;

        l_party_type := ZX_VALID_INIT_PARAMS_PKG.source_rec.poo_party_type;
        ZX_SRVC_TYP_PKG.get_tax_profile_ids(l_return_status,
                                            l_party_type,
                                            p_hdr_det_factors_rec.poo_party_id,
                                            p_hdr_det_factors_rec.poo_location_id,
                                            NULL,
                                            l_poo_ptp_id
                                           );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
             ':ZX_TCM_PTP_PKG.get_ptp for poo_party_id returned errors');
         END IF;
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
        END IF;
      END IF; /* Completed condition check for poo party */

      IF p_hdr_det_factors_rec.bill_to_party_id is NOT NULL AND
        p_hdr_det_factors_rec.bill_to_party_id <> FND_API.G_MISS_NUM THEN
        IF ((p_hdr_det_factors_rec.rounding_bill_to_party_id is NULL)
        OR ((p_hdr_det_factors_rec.rounding_bill_to_party_id is NOT NULL)
        AND (p_hdr_det_factors_rec.bill_to_party_id
         <> p_hdr_det_factors_rec.rounding_bill_to_party_id))) THEN

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Get PTP Id for Bill To Party Id: '||
                                                                       to_char(p_hdr_det_factors_rec.bill_to_party_id));
          END IF;

          l_party_type := ZX_VALID_INIT_PARAMS_PKG.source_rec.bill_to_party_type;
          ZX_SRVC_TYP_PKG.get_tax_profile_ids(l_return_status,
                                              l_party_type,
                                              p_hdr_det_factors_rec.bill_to_party_id,
                                              p_hdr_det_factors_rec.bill_to_location_id,
                                              NULL,
                                             l_bill_to_ptp_id
                                             );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
                ':ZX_TCM_PTP_PKG.get_ptp for bill_to_party_id returned errors');
            END IF;
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END IF;
        ELSE /* Bill to party is same as rounding bill to party */
          l_bill_to_ptp_id := l_rdng_bill_to_ptp_id;
        END IF;
      END IF; /* Completed condition check for bill to party */


      IF p_hdr_det_factors_rec.bill_from_party_id is NOT NULL AND
        p_hdr_det_factors_rec.bill_from_party_id <> FND_API.G_MISS_NUM THEN
        IF ((p_hdr_det_factors_rec.rounding_bill_from_party_id is NULL)
        OR ((p_hdr_det_factors_rec.rounding_bill_from_party_id is NOT NULL)
        AND (p_hdr_det_factors_rec.bill_from_party_id
          <> p_hdr_det_factors_rec.rounding_bill_from_party_id))) THEN

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Get PTP Id for Bill From Party Id: '||
                                                                        to_char(p_hdr_det_factors_rec.bill_from_party_id));
          END IF;

          l_party_type := ZX_VALID_INIT_PARAMS_PKG.source_rec.bill_from_party_type;
          ZX_SRVC_TYP_PKG.get_tax_profile_ids(l_return_status,
                                              l_party_type,
                                              p_hdr_det_factors_rec.bill_from_party_id,
                                              p_hdr_det_factors_rec.bill_from_location_id ,
                                              NULL,
                                              l_bill_from_ptp_id
                                             );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
                ':ZX_TCM_PTP_PKG.get_ptp for bill_from_party_id returned errors');
            END IF;
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END IF;
        ELSE /* Bill from party is same as rounding bill from party */
          l_bill_from_ptp_id := l_rdng_bill_from_ptp_id;
        END IF;
      END IF; /* Completed condition check for bill from party */

      IF p_hdr_det_factors_rec.ship_to_party_site_id is NOT NULL AND
        p_hdr_det_factors_rec.ship_to_party_site_id <> FND_API.G_MISS_NUM THEN
        IF ((p_hdr_det_factors_rec.rndg_ship_to_party_site_id is NULL)
        OR ((p_hdr_det_factors_rec.rndg_ship_to_party_site_id is NOT NULL)
        AND (p_hdr_det_factors_rec.ship_to_party_site_id
          <> p_hdr_det_factors_rec.rndg_ship_to_party_site_id))) THEN

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Get PTP Id for Ship To Party Site Id: '||
                                                                       to_char(p_hdr_det_factors_rec.ship_to_party_site_id));
          END IF;
          l_party_type := ZX_VALID_INIT_PARAMS_PKG.source_rec.ship_to_pty_site_type;
          ZX_SRVC_TYP_PKG.get_tax_profile_ids(l_return_status,
                                              l_party_type,
                                              NULL,
                                              NULL,
                                              p_hdr_det_factors_rec.ship_to_party_site_id ,
                                              l_ship_to_ptp_site_id
                                              );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
                ':ZX_TCM_PTP_PKG.get_ptp for ship_to_party_site_id returned errors');
            END IF;
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END IF;
        ELSE /* Ship to site is same as rounding ship to site */
          l_ship_to_ptp_site_id := l_rdng_ship_to_ptp_st_id;
        END IF;
      END IF; /* Completed condition check for ship to party site */

      IF p_hdr_det_factors_rec.ship_from_party_site_id is NOT NULL AND
        p_hdr_det_factors_rec.ship_to_party_site_id <> FND_API.G_MISS_NUM THEN
        IF ((p_hdr_det_factors_rec.rndg_ship_from_party_site_id is NULL)
        OR ((p_hdr_det_factors_rec.rndg_ship_from_party_site_id is NOT NULL)
        AND (p_hdr_det_factors_rec.ship_from_party_site_id
          <> p_hdr_det_factors_rec.rndg_ship_from_party_site_id))) THEN

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Get PTP Id for Ship From Party Site Id: '||
                                                                        to_char(p_hdr_det_factors_rec.ship_from_party_site_id));
          END IF;

          l_party_type := ZX_VALID_INIT_PARAMS_PKG.source_rec.ship_from_pty_site_type;
          ZX_SRVC_TYP_PKG.get_tax_profile_ids(l_return_status,
                                              l_party_type,
                                              NULL,
                                              NULL,
                                              p_hdr_det_factors_rec.ship_from_party_site_id,
                                              l_ship_from_ptp_site_id
                                             );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
                ':ZX_TCM_PTP_PKG.get_ptp for ship_from_party_site_id returned errors');
            END IF;
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END IF;
        ELSE /* Ship from site is same as rounding ship from site */
          l_ship_from_ptp_site_id := l_rdng_ship_from_ptp_st_id;
        END IF;
      END IF; /* Completed condition check for ship from site*/

      IF p_hdr_det_factors_rec.poa_party_site_id is NOT NULL AND
        p_hdr_det_factors_rec.poa_party_site_id <> FND_API.G_MISS_NUM THEN

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Get PTP Id for POA Party Site Id: '||
                                                                      to_char(p_hdr_det_factors_rec.poa_party_site_id));
        END IF;
        l_party_type := ZX_VALID_INIT_PARAMS_PKG.source_rec.poa_pty_site_type;
        ZX_SRVC_TYP_PKG.get_tax_profile_ids(l_return_status,
                                            l_party_type,
                                            NULL,
                                            NULL,
                                            p_hdr_det_factors_rec.poa_party_site_id,
                                            l_poa_ptp_site_id
                                           );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
                ':ZX_TCM_PTP_PKG.get_ptp for poa_party_site_id returned errors');
            END IF;
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END IF;
      END IF; /* Completed condition check for poa party site */


      IF p_hdr_det_factors_rec.poo_party_site_id is NOT NULL AND
        p_hdr_det_factors_rec.poo_party_site_id <> FND_API.G_MISS_NUM THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Get PTP Id for POO Party Site Id: '||
                                                                      to_char(p_hdr_det_factors_rec.poo_party_site_id));
        END IF;
        l_party_type := ZX_VALID_INIT_PARAMS_PKG.source_rec.poo_pty_site_type;
        ZX_SRVC_TYP_PKG.get_tax_profile_ids(l_return_status,
                                            l_party_type,
                                            NULL,
                                            NULL,
                                            p_hdr_det_factors_rec.poo_party_site_id,
                                            l_poo_ptp_site_id
                                           );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
                ':ZX_TCM_PTP_PKG.get_ptp for poo_party_site_id returned errors');
            END IF;
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END IF;
      END IF; /* Completed condition check for poo party site */

      IF p_hdr_det_factors_rec.bill_to_party_site_id is NOT NULL AND
        p_hdr_det_factors_rec.bill_to_party_site_id <> FND_API.G_MISS_NUM THEN
      IF ((p_hdr_det_factors_rec.rndg_bill_to_party_site_id is NULL)
      OR ((p_hdr_det_factors_rec.rndg_bill_to_party_site_id is NOT NULL)
       AND (p_hdr_det_factors_rec.bill_to_party_site_id
         <> p_hdr_det_factors_rec.rndg_bill_to_party_site_id))) THEN

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Get PTP Id for Bill To Party Site Id: '||
                                                                        to_char(p_hdr_det_factors_rec.bill_to_party_site_id));
          END IF;
          l_party_type := ZX_VALID_INIT_PARAMS_PKG.source_rec.bill_to_pty_site_type;
          ZX_SRVC_TYP_PKG.get_tax_profile_ids(l_return_status,
                                              l_party_type,
                                              NULL,
                                              NULL,
                                              p_hdr_det_factors_rec.bill_to_party_site_id,
                                              l_bill_to_ptp_site_id
                                             );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
                ':ZX_TCM_PTP_PKG.get_ptp for bill_to_party_site_id returned errors');
            END IF;
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END IF;
        ELSE  /* Bill to site is same as rounding bill to site */
          l_bill_to_ptp_site_id := l_rdng_bill_to_ptp_st_id;
        END IF;
      END IF; /* Completed condition check for bill to site */


      IF p_hdr_det_factors_rec.bill_from_party_site_id is NOT NULL AND
        p_hdr_det_factors_rec.bill_from_party_site_id <> FND_API.G_MISS_NUM THEN
        IF ((p_hdr_det_factors_rec.rndg_bill_from_party_site_id is NULL)
        OR ((p_hdr_det_factors_rec.rndg_bill_from_party_site_id is NOT NULL)
        AND (p_hdr_det_factors_rec.bill_from_party_site_id
          <> p_hdr_det_factors_rec.rndg_bill_from_party_site_id))) THEN

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Get PTP Id for Bill From Party Site Id: '||
                                                                         to_char(p_hdr_det_factors_rec.bill_from_party_site_id));
          END IF;
          l_party_type := ZX_VALID_INIT_PARAMS_PKG.source_rec.bill_from_pty_site_type;
          ZX_SRVC_TYP_PKG.get_tax_profile_ids(l_return_status,
                                              l_party_type,
                                              NULL,
                                              NULL,
                                              p_hdr_det_factors_rec.bill_from_party_site_id,
                                              l_bill_from_ptp_site_id
                                             );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
                ':ZX_TCM_PTP_PKG.get_ptp for bill_from_party_site_id returned errors');
            END IF;
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END IF;
        ELSE /* Bill from site is same as rounding bill from site */
          l_bill_from_ptp_site_id := l_rdng_bill_from_ptp_st_id;
        END IF;
      END IF; /* Completed condition check for rounding bill from site */

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                   ' RETURN_STATUS = ' || x_return_status);
          END IF;
          RETURN;
      END IF;

      ZX_R11I_TAX_PARTNER_PKG.copy_trx_line_for_ptnr_bef_upd(NULL,
                                                            l_event_class_rec,
                                                            NULL,
                                                            'N',
                                                            NULL,
            	   		                            NULL,
                                                            l_return_status
                                                            );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status ;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_R11I_TAX_PARTNER_PKG.copy_trx_line_for_ptnr_bef_upd  returned errors');
         END IF;
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

   /*-----------------------------------------------+
    |Update the headers only in zx_line_det_factors |
    +----------------------------------------------*/
   UPDATE ZX_LINES_DET_FACTORS SET
         APPLICATION_ID                    = p_hdr_det_factors_rec.APPLICATION_ID,
         ENTITY_CODE                       = p_hdr_det_factors_rec.ENTITY_CODE,
         EVENT_CLASS_CODE                  = p_hdr_det_factors_rec.EVENT_CLASS_CODE,
         EVENT_TYPE_CODE                   = p_hdr_det_factors_rec.EVENT_TYPE_CODE,
         INTERNAL_ORGANIZATION_ID          = p_hdr_det_factors_rec.INTERNAL_ORGANIZATION_ID,
         LEGAL_ENTITY_ID                   = p_hdr_det_factors_rec.LEGAL_ENTITY_ID,
         TRX_ID                            = p_hdr_det_factors_rec.TRX_ID,
         TRX_DOC_REVISION	           = decode(p_hdr_det_factors_rec.TRX_DOC_REVISION,FND_API.G_MISS_CHAR,
                                                                                                   TRX_DOC_REVISION,
                                                                                                   p_hdr_det_factors_rec.TRX_DOC_REVISION),
         TRX_DATE                          = decode(p_hdr_det_factors_rec.TRX_DATE,FND_API.G_MISS_DATE,
                                                                                                   TRX_DATE,
                                                                                                   p_hdr_det_factors_rec.TRX_DATE),
         LEDGER_ID                         = decode(p_hdr_det_factors_rec.LEDGER_ID,FND_API.G_MISS_NUM,
                                                                                                   LEDGER_ID,
                                                                                                   p_hdr_det_factors_rec.LEDGER_ID),
         INTERNAL_ORG_LOCATION_ID          = decode(p_hdr_det_factors_rec.INTERNAL_ORG_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   INTERNAL_ORG_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.INTERNAL_ORG_LOCATION_ID),
         TRX_CURRENCY_CODE                 = decode(p_hdr_det_factors_rec.TRX_CURRENCY_CODE,FND_API.G_MISS_CHAR,
                                                                                                   TRX_CURRENCY_CODE,
                                                                                                   p_hdr_det_factors_rec.TRX_CURRENCY_CODE),
         CURRENCY_CONVERSION_TYPE          = decode(p_hdr_det_factors_rec.CURRENCY_CONVERSION_TYPE,FND_API.G_MISS_CHAR,
                                                                                                   CURRENCY_CONVERSION_TYPE,
                                                                                                   p_hdr_det_factors_rec.CURRENCY_CONVERSION_TYPE),
         CURRENCY_CONVERSION_RATE          = decode(p_hdr_det_factors_rec.CURRENCY_CONVERSION_RATE,FND_API.G_MISS_NUM,
                                                                                                   CURRENCY_CONVERSION_RATE,
                                                                                                   p_hdr_det_factors_rec.CURRENCY_CONVERSION_RATE),
         CURRENCY_CONVERSION_DATE          = decode(p_hdr_det_factors_rec.CURRENCY_CONVERSION_DATE,FND_API.G_MISS_DATE,
                                                                                                   CURRENCY_CONVERSION_DATE,
                                                                                                   p_hdr_det_factors_rec.CURRENCY_CONVERSION_DATE),
         MINIMUM_ACCOUNTABLE_UNIT	   = decode(p_hdr_det_factors_rec.MINIMUM_ACCOUNTABLE_UNIT,FND_API.G_MISS_NUM,
                                                                                                   MINIMUM_ACCOUNTABLE_UNIT,
                                                                                                   p_hdr_det_factors_rec.MINIMUM_ACCOUNTABLE_UNIT),
         PRECISION                         =  decode(p_hdr_det_factors_rec.PRECISION,FND_API.G_MISS_NUM,
                                                                                                   PRECISION,
                                                                                                   p_hdr_det_factors_rec.PRECISION),
         ESTABLISHMENT_ID                  = decode(p_hdr_det_factors_rec.ESTABLISHMENT_ID,FND_API.G_MISS_NUM,
                                                                                                    ESTABLISHMENT_ID,
                                                                                                    p_hdr_det_factors_rec.ESTABLISHMENT_ID),
         RECEIVABLES_TRX_TYPE_ID	   = decode(p_hdr_det_factors_rec.RECEIVABLES_TRX_TYPE_ID,FND_API.G_MISS_NUM,
                                                                                                    RECEIVABLES_TRX_TYPE_ID,
                                                                                                    p_hdr_det_factors_rec.RECEIVABLES_TRX_TYPE_ID),
         RELATED_DOC_APPLICATION_ID	   = decode(p_hdr_det_factors_rec.RELATED_DOC_APPLICATION_ID,FND_API.G_MISS_NUM,
                                                                                                    RELATED_DOC_APPLICATION_ID,
                                                                                                    p_hdr_det_factors_rec.RELATED_DOC_APPLICATION_ID),
         RELATED_DOC_ENTITY_CODE	   = decode(p_hdr_det_factors_rec.RELATED_DOC_ENTITY_CODE,FND_API.G_MISS_CHAR,
                                                                                                    RELATED_DOC_ENTITY_CODE,
                                                                                                    p_hdr_det_factors_rec.RELATED_DOC_ENTITY_CODE),
         RELATED_DOC_EVENT_CLASS_CODE	   = decode(p_hdr_det_factors_rec.RELATED_DOC_EVENT_CLASS_CODE,FND_API.G_MISS_CHAR,
                                                                                                    RELATED_DOC_EVENT_CLASS_CODE,
                                                                                                    p_hdr_det_factors_rec.RELATED_DOC_EVENT_CLASS_CODE),
         RELATED_DOC_TRX_ID	           = decode(p_hdr_det_factors_rec.RELATED_DOC_TRX_ID,FND_API.G_MISS_NUM,
                                                                                                    RELATED_DOC_TRX_ID,
                                                                                                    p_hdr_det_factors_rec.RELATED_DOC_TRX_ID),
         RELATED_DOC_NUMBER	           = decode(p_hdr_det_factors_rec.RELATED_DOC_NUMBER,FND_API.G_MISS_CHAR,
                                                                                                    RELATED_DOC_NUMBER,
                                                                                                    p_hdr_det_factors_rec.RELATED_DOC_NUMBER),
         RELATED_DOC_DATE                  = decode(p_hdr_det_factors_rec.RELATED_DOC_DATE,FND_API.G_MISS_DATE,
                                                                                                    RELATED_DOC_DATE,
                                                                                                    p_hdr_det_factors_rec.RELATED_DOC_DATE),
         DEFAULT_TAXATION_COUNTRY	   = decode(p_hdr_det_factors_rec.DEFAULT_TAXATION_COUNTRY,FND_API.G_MISS_CHAR,
                                                                                                    DEFAULT_TAXATION_COUNTRY,
                                                                                                    p_hdr_det_factors_rec.DEFAULT_TAXATION_COUNTRY),
         TRX_NUMBER	                   = decode(p_hdr_det_factors_rec.TRX_NUMBER,FND_API.G_MISS_CHAR,
                                                                                                    TRX_NUMBER,
                                                                                                    p_hdr_det_factors_rec.TRX_NUMBER),
         TRX_DESCRIPTION	           = decode(p_hdr_det_factors_rec.TRX_DESCRIPTION,FND_API.G_MISS_CHAR,
                                                                                                   TRX_DESCRIPTION,
                                                                                                   p_hdr_det_factors_rec.TRX_DESCRIPTION),
         TRX_COMMUNICATED_DATE	           = decode(p_hdr_det_factors_rec.TRX_COMMUNICATED_DATE,FND_API.G_MISS_DATE,
                                                                                                   TRX_COMMUNICATED_DATE,
                                                                                                   p_hdr_det_factors_rec.TRX_COMMUNICATED_DATE),
         BATCH_SOURCE_ID	           = decode(p_hdr_det_factors_rec.BATCH_SOURCE_ID,FND_API.G_MISS_NUM,
                                                                                                   BATCH_SOURCE_ID,
                                                                                                   p_hdr_det_factors_rec.BATCH_SOURCE_ID),
         BATCH_SOURCE_NAME	           = decode(p_hdr_det_factors_rec.BATCH_SOURCE_NAME,FND_API.G_MISS_CHAR,
                                                                                                   BATCH_SOURCE_NAME,
                                                                                                   p_hdr_det_factors_rec.BATCH_SOURCE_NAME),
         DOC_SEQ_ID	                   = decode(p_hdr_det_factors_rec.DOC_SEQ_ID,FND_API.G_MISS_NUM,
                                                                                                   DOC_SEQ_ID,
                                                                                                   p_hdr_det_factors_rec.DOC_SEQ_ID),
         DOC_SEQ_NAME	                   = decode(p_hdr_det_factors_rec.DOC_SEQ_NAME,FND_API.G_MISS_CHAR,
                                                                                                   DOC_SEQ_NAME,
                                                                                                   p_hdr_det_factors_rec.DOC_SEQ_NAME),
         DOC_SEQ_VALUE	                   = decode(p_hdr_det_factors_rec.DOC_SEQ_VALUE,FND_API.G_MISS_CHAR,
                                                                                                   DOC_SEQ_VALUE,
                                                                                                   p_hdr_det_factors_rec.DOC_SEQ_VALUE),
         TRX_DUE_DATE	                   = decode(p_hdr_det_factors_rec.TRX_DUE_DATE,FND_API.G_MISS_DATE,
                                                                                                   TRX_DUE_DATE,
                                                                                                   p_hdr_det_factors_rec.TRX_DUE_DATE),
         TRX_TYPE_DESCRIPTION	           = decode(p_hdr_det_factors_rec.TRX_TYPE_DESCRIPTION,FND_API.G_MISS_CHAR,
                                                                                                   TRX_TYPE_DESCRIPTION,
                                                                                                   p_hdr_det_factors_rec.TRX_TYPE_DESCRIPTION),
         DOCUMENT_SUB_TYPE	           = decode(p_hdr_det_factors_rec.DOCUMENT_SUB_TYPE,FND_API.G_MISS_CHAR,
                                                                                                   DOCUMENT_SUB_TYPE,
                                                                                                   p_hdr_det_factors_rec.DOCUMENT_SUB_TYPE),
         SUPPLIER_TAX_INVOICE_NUMBER	   = decode(p_hdr_det_factors_rec.SUPPLIER_TAX_INVOICE_NUMBER,FND_API.G_MISS_CHAR,
                                                                                                   SUPPLIER_TAX_INVOICE_NUMBER,
                                                                                                   p_hdr_det_factors_rec.SUPPLIER_TAX_INVOICE_NUMBER),
         SUPPLIER_TAX_INVOICE_DATE	   = decode(p_hdr_det_factors_rec.SUPPLIER_TAX_INVOICE_DATE,FND_API.G_MISS_DATE,
                                                                                                   SUPPLIER_TAX_INVOICE_DATE,
                                                                                                   p_hdr_det_factors_rec.SUPPLIER_TAX_INVOICE_DATE),
         SUPPLIER_EXCHANGE_RATE	           = decode(p_hdr_det_factors_rec.SUPPLIER_EXCHANGE_RATE,FND_API.G_MISS_NUM,
                                                                                                   SUPPLIER_EXCHANGE_RATE,
                                                                                                   p_hdr_det_factors_rec.SUPPLIER_EXCHANGE_RATE),
         TAX_INVOICE_DATE	           = decode(p_hdr_det_factors_rec.TAX_INVOICE_DATE,FND_API.G_MISS_DATE,
                                                                                                   TAX_INVOICE_DATE,
                                                                                                   p_hdr_det_factors_rec.TAX_INVOICE_DATE),
         TAX_INVOICE_NUMBER	           = decode(p_hdr_det_factors_rec.TAX_INVOICE_NUMBER,FND_API.G_MISS_CHAR,
                                                                                                   TAX_INVOICE_NUMBER,
                                                                                                   p_hdr_det_factors_rec.TAX_INVOICE_NUMBER),
         CTRL_TOTAL_HDR_TX_AMT             = decode(p_hdr_det_factors_rec.CTRL_TOTAL_HDR_TX_AMT,FND_API.G_MISS_NUM,
                                                                                                   ctrl_total_hdr_tx_amt,
                                                                                                   p_hdr_det_factors_rec.CTRL_TOTAL_HDR_TX_AMT),
         FIRST_PTY_ORG_ID	           = l_event_class_rec.first_pty_org_id,
         TAX_EVENT_CLASS_CODE	           = l_event_class_rec.TAX_EVENT_CLASS_CODE,
         TAX_EVENT_TYPE_CODE	           = l_event_class_rec.TAX_EVENT_TYPE_CODE,
         DOC_EVENT_STATUS	           = l_event_class_rec.DOC_STATUS_CODE,
         TRX_BATCH_ID                      = decode(p_hdr_det_factors_rec.TRX_BATCH_ID,FND_API.G_MISS_NUM,
                                                                                                   TRX_BATCH_ID,
                                                                                                   p_hdr_det_factors_rec.TRX_BATCH_ID),
         APPLIED_TO_TRX_NUMBER             = decode(p_hdr_det_factors_rec.APPLIED_TO_TRX_NUMBER,FND_API.G_MISS_CHAR,
                                                                                                   APPLIED_TO_TRX_NUMBER,
                                                                                                   p_hdr_det_factors_rec.APPLIED_TO_TRX_NUMBER),
         APPLICATION_DOC_STATUS            = decode(p_hdr_det_factors_rec.APPLICATION_DOC_STATUS,FND_API.G_MISS_CHAR,
                                                                                                   APPLICATION_DOC_STATUS,
                                                                                                   p_hdr_det_factors_rec.APPLICATION_DOC_STATUS),
         RDNG_SHIP_TO_PTY_TX_PROF_ID	   = decode(p_hdr_det_factors_rec.ROUNDING_SHIP_TO_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   RDNG_SHIP_TO_PTY_TX_PROF_ID,
                                                                                                   l_rdng_ship_to_ptp_id),
         RDNG_SHIP_FROM_PTY_TX_PROF_ID	   = decode(p_hdr_det_factors_rec.ROUNDING_SHIP_FROM_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   RDNG_SHIP_FROM_PTY_TX_PROF_ID,
                                                                                                   l_rdng_ship_from_ptp_id),
         RDNG_BILL_TO_PTY_TX_PROF_ID	   = decode(p_hdr_det_factors_rec.ROUNDING_BILL_TO_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   RDNG_BILL_TO_PTY_TX_PROF_ID,
                                                                                                   l_rdng_bill_to_ptp_id),
         RDNG_BILL_FROM_PTY_TX_PROF_ID	   = decode(p_hdr_det_factors_rec.ROUNDING_BILL_FROM_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   RDNG_BILL_FROM_PTY_TX_PROF_ID,
                                                                                                   l_rdng_bill_from_ptp_id),
         RDNG_SHIP_TO_PTY_TX_P_ST_ID	   = decode(p_hdr_det_factors_rec.RNDG_SHIP_TO_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   RDNG_SHIP_TO_PTY_TX_P_ST_ID,
                                                                                                   l_rdng_ship_to_ptp_st_id),
         RDNG_SHIP_FROM_PTY_TX_P_ST_ID	   = decode(p_hdr_det_factors_rec.RNDG_SHIP_FROM_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   RDNG_SHIP_FROM_PTY_TX_P_ST_ID,
                                                                                                   l_rdng_ship_from_ptp_st_id),
         RDNG_BILL_TO_PTY_TX_P_ST_ID	   = decode(p_hdr_det_factors_rec.RNDG_BILL_TO_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   RDNG_BILL_TO_PTY_TX_P_ST_ID,
                                                                                                   l_rdng_bill_to_ptp_st_id),
         RDNG_BILL_FROM_PTY_TX_P_ST_ID 	   = decode(p_hdr_det_factors_rec.RNDG_BILL_FROM_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   RDNG_BILL_FROM_PTY_TX_P_ST_ID,
                                                                                                   l_rdng_bill_from_ptp_st_id),
         PORT_OF_ENTRY_CODE                =  decode(p_hdr_det_factors_rec.PORT_OF_ENTRY_CODE,FND_API.G_MISS_CHAR,
                                                                                                   PORT_OF_ENTRY_CODE,
                                                                                                   p_hdr_det_factors_rec.PORT_OF_ENTRY_CODE),
         TAX_REPORTING_FLAG                = decode(p_hdr_det_factors_rec.TAX_REPORTING_FLAG,FND_API.G_MISS_CHAR,
                                                                                                   TAX_REPORTING_FLAG,
                                                                                                   p_hdr_det_factors_rec.TAX_REPORTING_FLAG),
         PROVNL_TAX_DETERMINATION_DATE     = decode(p_hdr_det_factors_rec.PROVNL_TAX_DETERMINATION_DATE,FND_API.G_MISS_DATE,
                                                                                                   PROVNL_TAX_DETERMINATION_DATE,
                                                                                                   p_hdr_det_factors_rec.PROVNL_TAX_DETERMINATION_DATE),
         SHIP_THIRD_PTY_ACCT_ID            = decode(p_hdr_det_factors_rec.SHIP_THIRD_PTY_ACCT_ID,FND_API.G_MISS_NUM,
                                                                                                   SHIP_THIRD_PTY_ACCT_ID,
                                                                                                   p_hdr_det_factors_rec.SHIP_THIRD_PTY_ACCT_ID),
         BILL_THIRD_PTY_ACCT_ID            = decode(p_hdr_det_factors_rec.BILL_THIRD_PTY_ACCT_ID,FND_API.G_MISS_NUM,
                                                                                                   BILL_THIRD_PTY_ACCT_ID,
                                                                                                   p_hdr_det_factors_rec.BILL_THIRD_PTY_ACCT_ID),
         SHIP_THIRD_PTY_ACCT_SITE_ID       = decode(p_hdr_det_factors_rec.SHIP_THIRD_PTY_ACCT_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   SHIP_THIRD_PTY_ACCT_SITE_ID,
                                                                                                   p_hdr_det_factors_rec.SHIP_THIRD_PTY_ACCT_SITE_ID),
         BILL_THIRD_PTY_ACCT_SITE_ID       = decode(p_hdr_det_factors_rec.BILL_THIRD_PTY_ACCT_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   BILL_THIRD_PTY_ACCT_SITE_ID,
                                                                                                   p_hdr_det_factors_rec.BILL_THIRD_PTY_ACCT_SITE_ID),
         SHIP_TO_CUST_ACCT_SITE_USE_ID     = decode(p_hdr_det_factors_rec.SHIP_TO_CUST_ACCT_SITE_USE_ID,FND_API.G_MISS_NUM,
                                                                                                   SHIP_TO_CUST_ACCT_SITE_USE_ID,
                                                                                                   p_hdr_det_factors_rec.SHIP_TO_CUST_ACCT_SITE_USE_ID),
         BILL_TO_CUST_ACCT_SITE_USE_ID     = decode(p_hdr_det_factors_rec.BILL_TO_CUST_ACCT_SITE_USE_ID,FND_API.G_MISS_NUM,
                                                                                                   BILL_TO_CUST_ACCT_SITE_USE_ID,
                                                                                                   p_hdr_det_factors_rec.BILL_TO_CUST_ACCT_SITE_USE_ID),
         SHIP_TO_LOCATION_ID               = decode(p_hdr_det_factors_rec.SHIP_TO_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   SHIP_TO_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.SHIP_TO_LOCATION_ID),
         SHIP_FROM_LOCATION_ID             = decode(p_hdr_det_factors_rec.SHIP_FROM_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   SHIP_FROM_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.SHIP_FROM_LOCATION_ID),
         BILL_TO_LOCATION_ID               = decode(p_hdr_det_factors_rec.BILL_TO_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   BILL_TO_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.BILL_TO_LOCATION_ID),
         BILL_FROM_LOCATION_ID             = decode(p_hdr_det_factors_rec.BILL_FROM_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   BILL_FROM_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.BILL_FROM_LOCATION_ID),
         POA_LOCATION_ID                   = decode(p_hdr_det_factors_rec.POA_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   POA_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.POA_LOCATION_ID),
         POO_LOCATION_ID                   = decode(p_hdr_det_factors_rec.POO_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   POO_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.POO_LOCATION_ID),
         PAYING_LOCATION_ID                = decode(p_hdr_det_factors_rec.PAYING_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   PAYING_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.PAYING_LOCATION_ID),
         OWN_HQ_LOCATION_ID                = decode(p_hdr_det_factors_rec.OWN_HQ_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   OWN_HQ_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.OWN_HQ_LOCATION_ID),
         TRADING_HQ_LOCATION_ID            = decode(p_hdr_det_factors_rec.TRADING_HQ_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   TRADING_HQ_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.TRADING_HQ_LOCATION_ID),
         POC_LOCATION_ID                   = decode(p_hdr_det_factors_rec.POC_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   POC_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.POC_LOCATION_ID),
         POI_LOCATION_ID                   = decode(p_hdr_det_factors_rec.POI_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   POI_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.POI_LOCATION_ID),
         POD_LOCATION_ID                   = decode(p_hdr_det_factors_rec.POD_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   POD_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.POD_LOCATION_ID),
         TITLE_TRANSFER_LOCATION_ID        = decode(p_hdr_det_factors_rec.TITLE_TRANSFER_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   TITLE_TRANSFER_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.TITLE_TRANSFER_LOCATION_ID),
         SHIP_TO_PARTY_TAX_PROF_ID         = decode(p_hdr_det_factors_rec.SHIP_TO_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   SHIP_TO_PARTY_TAX_PROF_ID,
                                                                                                   l_ship_to_ptp_id),
         SHIP_FROM_PARTY_TAX_PROF_ID       = decode(p_hdr_det_factors_rec.SHIP_FROM_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   SHIP_FROM_PARTY_TAX_PROF_ID,
                                                                                                   l_ship_from_ptp_id),
         POA_PARTY_TAX_PROF_ID             = decode(p_hdr_det_factors_rec.POA_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   POA_PARTY_TAX_PROF_ID,
                                                                                                   l_poa_ptp_id),
         POO_PARTY_TAX_PROF_ID             = decode(p_hdr_det_factors_rec.POO_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   POO_PARTY_TAX_PROF_ID,
                                                                                                   l_poo_ptp_id),
         PAYING_PARTY_TAX_PROF_ID          = decode(p_hdr_det_factors_rec.PAYING_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   PAYING_PARTY_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.PAYING_PARTY_TAX_PROF_ID),
         OWN_HQ_PARTY_TAX_PROF_ID          = decode(p_hdr_det_factors_rec.OWN_HQ_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   OWN_HQ_PARTY_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.OWN_HQ_PARTY_TAX_PROF_ID),
         TRADING_HQ_PARTY_TAX_PROF_ID      = decode(p_hdr_det_factors_rec.TRADING_HQ_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   TRADING_HQ_PARTY_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.TRADING_HQ_PARTY_TAX_PROF_ID),
         POI_PARTY_TAX_PROF_ID             = decode(p_hdr_det_factors_rec.POI_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   POI_PARTY_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.POI_PARTY_TAX_PROF_ID),
         POD_PARTY_TAX_PROF_ID             = decode(p_hdr_det_factors_rec.POD_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   POD_PARTY_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.POD_PARTY_TAX_PROF_ID),
         BILL_TO_PARTY_TAX_PROF_ID         = decode(p_hdr_det_factors_rec.BILL_TO_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   BILL_TO_PARTY_TAX_PROF_ID,
                                                                                                   l_bill_to_ptp_id),
         BILL_FROM_PARTY_TAX_PROF_ID       = decode(p_hdr_det_factors_rec.BILL_FROM_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   BILL_FROM_PARTY_TAX_PROF_ID,
                                                                                                   l_bill_from_ptp_id),
         TITLE_TRANS_PARTY_TAX_PROF_ID     = decode(p_hdr_det_factors_rec.TITLE_TRANSFER_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   TITLE_TRANS_PARTY_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.TITLE_TRANS_PARTY_TAX_PROF_ID),
         SHIP_TO_SITE_TAX_PROF_ID          = decode(p_hdr_det_factors_rec.SHIP_TO_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   SHIP_TO_SITE_TAX_PROF_ID,
                                                                                                   l_ship_to_ptp_site_id),
         SHIP_FROM_SITE_TAX_PROF_ID        = decode(p_hdr_det_factors_rec.SHIP_FROM_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   SHIP_FROM_SITE_TAX_PROF_ID,
                                                                                                   l_ship_from_ptp_site_id),
         BILL_TO_SITE_TAX_PROF_ID          = decode(p_hdr_det_factors_rec.BILL_TO_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   BILL_TO_SITE_TAX_PROF_ID,
                                                                                                   l_bill_to_ptp_site_id),
         BILL_FROM_SITE_TAX_PROF_ID        = decode(p_hdr_det_factors_rec.BILL_FROM_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   BILL_FROM_SITE_TAX_PROF_ID,
                                                                                                   l_bill_from_ptp_site_id),
         POA_SITE_TAX_PROF_ID              = decode(p_hdr_det_factors_rec.POA_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   POA_SITE_TAX_PROF_ID,
                                                                                                   l_poa_ptp_site_id),
         POO_SITE_TAX_PROF_ID              = decode(p_hdr_det_factors_rec.POO_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   POO_SITE_TAX_PROF_ID,
                                                                                                   l_poo_ptp_site_id),
         PAYING_SITE_TAX_PROF_ID           = decode(p_hdr_det_factors_rec.PAYING_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   PAYING_SITE_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.PAYING_SITE_TAX_PROF_ID),
         OWN_HQ_SITE_TAX_PROF_ID           = decode(p_hdr_det_factors_rec.OWN_HQ_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   OWN_HQ_SITE_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.OWN_HQ_SITE_TAX_PROF_ID),
         POI_SITE_TAX_PROF_ID              = decode(p_hdr_det_factors_rec.POI_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   POI_SITE_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.POI_SITE_TAX_PROF_ID),
         POD_SITE_TAX_PROF_ID              = decode(p_hdr_det_factors_rec.POD_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   POD_SITE_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.POD_SITE_TAX_PROF_ID),
         TITLE_TRANS_SITE_TAX_PROF_ID      = decode(p_hdr_det_factors_rec.TITLE_TRANSFER_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   TITLE_TRANS_SITE_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.TITLE_TRANS_SITE_TAX_PROF_ID),
         HQ_ESTB_PARTY_TAX_PROF_ID         = l_hq_estb_ptp_id,
         LINE_LEVEL_ACTION                 = decode(LINE_LEVEL_ACTION, 'CREATE','UPDATE',
                                                                       'SYNCHRONIZE','UPDATE',
                                                                       'COPY_AND_CREATE','UPDATE',
                                                                       LINE_LEVEL_ACTION),
         TAX_PROCESSING_COMPLETED_FLAG     = 'N',
         LAST_UPDATE_DATE                  = sysdate,
         LAST_UPDATED_BY                   = fnd_global.user_id,
         LAST_UPDATE_LOGIN                 = fnd_global.conc_login_id
    WHERE APPLICATION_ID   = p_hdr_det_factors_rec.APPLICATION_ID
      AND ENTITY_CODE      = p_hdr_det_factors_rec.ENTITY_CODE
      AND EVENT_CLASS_CODE = p_hdr_det_factors_rec.EVENT_CLASS_CODE
      AND TRX_ID           = p_hdr_det_factors_rec.TRX_ID;
     --Bugfix 4486946 -Call on the fly upgrade if the transaction if not found
    IF sql%NOTFOUND THEN
       l_upg_trx_info_rec.application_id   := l_event_class_rec.application_id;
       l_upg_trx_info_rec.entity_code      := l_event_class_rec.entity_code;
       l_upg_trx_info_rec.event_class_code := l_event_class_rec.event_class_code;
       l_upg_trx_info_rec.trx_id           := l_event_class_rec.trx_id;
       ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly(p_upg_trx_info_rec   =>  l_upg_trx_info_rec,
                                                    x_return_status      =>  l_return_status
                                                   );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly returned errors');
         END IF;
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
       END IF;

       ZX_R11I_TAX_PARTNER_PKG.copy_trx_line_for_ptnr_bef_upd(NULL,
                                                            l_event_class_rec,
                                                            NULL,
                                                            'N',
                                                            NULL,
            	   		                            NULL,
                                                            l_return_status
                                                            );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status ;
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_R11I_TAX_PARTNER_PKG.copy_trx_line_for_ptnr_bef_upd  returned errors');
          END IF;
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;

      /*-----------------------------------------------+
       |Update the headers only in zx_line_det_factors |
       +----------------------------------------------*/
       UPDATE ZX_LINES_DET_FACTORS SET
         APPLICATION_ID                    = p_hdr_det_factors_rec.APPLICATION_ID,
         ENTITY_CODE                       = p_hdr_det_factors_rec.ENTITY_CODE,
         EVENT_CLASS_CODE                  = p_hdr_det_factors_rec.EVENT_CLASS_CODE,
         EVENT_TYPE_CODE                   = p_hdr_det_factors_rec.EVENT_TYPE_CODE,
         INTERNAL_ORGANIZATION_ID          = p_hdr_det_factors_rec.INTERNAL_ORGANIZATION_ID,
         LEGAL_ENTITY_ID                   = p_hdr_det_factors_rec.LEGAL_ENTITY_ID,
         TRX_ID                            = p_hdr_det_factors_rec.TRX_ID,
         TRX_DOC_REVISION	           = decode(p_hdr_det_factors_rec.TRX_DOC_REVISION,FND_API.G_MISS_CHAR,
                                                                                                   TRX_DOC_REVISION,
                                                                                                   p_hdr_det_factors_rec.TRX_DOC_REVISION),
         TRX_DATE                          = decode(p_hdr_det_factors_rec.TRX_DATE,FND_API.G_MISS_DATE,
                                                                                                   TRX_DATE,
                                                                                                   p_hdr_det_factors_rec.TRX_DATE),
         LEDGER_ID                         = decode(p_hdr_det_factors_rec.LEDGER_ID,FND_API.G_MISS_NUM,
                                                                                                   LEDGER_ID,
                                                                                                   p_hdr_det_factors_rec.LEDGER_ID),
         INTERNAL_ORG_LOCATION_ID          = decode(p_hdr_det_factors_rec.INTERNAL_ORG_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   INTERNAL_ORG_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.INTERNAL_ORG_LOCATION_ID),
         TRX_CURRENCY_CODE                 = decode(p_hdr_det_factors_rec.TRX_CURRENCY_CODE,FND_API.G_MISS_CHAR,
                                                                                                   TRX_CURRENCY_CODE,
                                                                                                   p_hdr_det_factors_rec.TRX_CURRENCY_CODE),
         CURRENCY_CONVERSION_TYPE          = decode(p_hdr_det_factors_rec.CURRENCY_CONVERSION_TYPE,FND_API.G_MISS_CHAR,
                                                                                                   CURRENCY_CONVERSION_TYPE,
                                                                                                   p_hdr_det_factors_rec.CURRENCY_CONVERSION_TYPE),
         CURRENCY_CONVERSION_RATE          = decode(p_hdr_det_factors_rec.CURRENCY_CONVERSION_RATE,FND_API.G_MISS_NUM,
                                                                                                   CURRENCY_CONVERSION_RATE,
                                                                                                   p_hdr_det_factors_rec.CURRENCY_CONVERSION_RATE),
         CURRENCY_CONVERSION_DATE          = decode(p_hdr_det_factors_rec.CURRENCY_CONVERSION_DATE,FND_API.G_MISS_DATE,
                                                                                                   CURRENCY_CONVERSION_DATE,
                                                                                                   p_hdr_det_factors_rec.CURRENCY_CONVERSION_DATE),
         MINIMUM_ACCOUNTABLE_UNIT	   = decode(p_hdr_det_factors_rec.MINIMUM_ACCOUNTABLE_UNIT,FND_API.G_MISS_NUM,
                                                                                                   MINIMUM_ACCOUNTABLE_UNIT,
                                                                                                   p_hdr_det_factors_rec.MINIMUM_ACCOUNTABLE_UNIT),
         PRECISION                         =  decode(p_hdr_det_factors_rec.PRECISION,FND_API.G_MISS_NUM,
                                                                                                   PRECISION,
                                                                                                   p_hdr_det_factors_rec.PRECISION),
         ESTABLISHMENT_ID                  = decode(p_hdr_det_factors_rec.ESTABLISHMENT_ID,FND_API.G_MISS_NUM,
                                                                                                    ESTABLISHMENT_ID,
                                                                                                    p_hdr_det_factors_rec.ESTABLISHMENT_ID),
         RECEIVABLES_TRX_TYPE_ID	   = decode(p_hdr_det_factors_rec.RECEIVABLES_TRX_TYPE_ID,FND_API.G_MISS_NUM,
                                                                                                    RECEIVABLES_TRX_TYPE_ID,
                                                                                                    p_hdr_det_factors_rec.RECEIVABLES_TRX_TYPE_ID),
         RELATED_DOC_APPLICATION_ID	   = decode(p_hdr_det_factors_rec.RELATED_DOC_APPLICATION_ID,FND_API.G_MISS_NUM,
                                                                                                    RELATED_DOC_APPLICATION_ID,
                                                                                                    p_hdr_det_factors_rec.RELATED_DOC_APPLICATION_ID),
         RELATED_DOC_ENTITY_CODE	   = decode(p_hdr_det_factors_rec.RELATED_DOC_ENTITY_CODE,FND_API.G_MISS_CHAR,
                                                                                                    RELATED_DOC_ENTITY_CODE,
                                                                                                    p_hdr_det_factors_rec.RELATED_DOC_ENTITY_CODE),
         RELATED_DOC_EVENT_CLASS_CODE	   = decode(p_hdr_det_factors_rec.RELATED_DOC_EVENT_CLASS_CODE,FND_API.G_MISS_CHAR,
                                                                                                    RELATED_DOC_EVENT_CLASS_CODE,
                                                                                                    p_hdr_det_factors_rec.RELATED_DOC_EVENT_CLASS_CODE),
         RELATED_DOC_TRX_ID	           = decode(p_hdr_det_factors_rec.RELATED_DOC_TRX_ID,FND_API.G_MISS_NUM,
                                                                                                    RELATED_DOC_TRX_ID,
                                                                                                    p_hdr_det_factors_rec.RELATED_DOC_TRX_ID),
         RELATED_DOC_NUMBER	           = decode(p_hdr_det_factors_rec.RELATED_DOC_NUMBER,FND_API.G_MISS_CHAR,
                                                                                                    RELATED_DOC_NUMBER,
                                                                                                    p_hdr_det_factors_rec.RELATED_DOC_NUMBER),
         RELATED_DOC_DATE                  = decode(p_hdr_det_factors_rec.RELATED_DOC_DATE,FND_API.G_MISS_DATE,
                                                                                                    RELATED_DOC_DATE,
                                                                                                    p_hdr_det_factors_rec.RELATED_DOC_DATE),
         DEFAULT_TAXATION_COUNTRY	   = decode(p_hdr_det_factors_rec.DEFAULT_TAXATION_COUNTRY,FND_API.G_MISS_CHAR,
                                                                                                    DEFAULT_TAXATION_COUNTRY,
                                                                                                    p_hdr_det_factors_rec.DEFAULT_TAXATION_COUNTRY),
         TRX_NUMBER	                   = decode(p_hdr_det_factors_rec.TRX_NUMBER,FND_API.G_MISS_CHAR,
                                                                                                    TRX_NUMBER,
                                                                                                    p_hdr_det_factors_rec.TRX_NUMBER),
         TRX_DESCRIPTION	           = decode(p_hdr_det_factors_rec.TRX_DESCRIPTION,FND_API.G_MISS_CHAR,
                                                                                                   TRX_DESCRIPTION,
                                                                                                   p_hdr_det_factors_rec.TRX_DESCRIPTION),
         TRX_COMMUNICATED_DATE	           = decode(p_hdr_det_factors_rec.TRX_COMMUNICATED_DATE,FND_API.G_MISS_DATE,
                                                                                                   TRX_COMMUNICATED_DATE,
                                                                                                   p_hdr_det_factors_rec.TRX_COMMUNICATED_DATE),
         BATCH_SOURCE_ID	           = decode(p_hdr_det_factors_rec.BATCH_SOURCE_ID,FND_API.G_MISS_NUM,
                                                                                                   BATCH_SOURCE_ID,
                                                                                                   p_hdr_det_factors_rec.BATCH_SOURCE_ID),
         BATCH_SOURCE_NAME	           =  decode(p_hdr_det_factors_rec.BATCH_SOURCE_NAME,FND_API.G_MISS_CHAR,
                                                                                                   BATCH_SOURCE_NAME,
                                                                                                   p_hdr_det_factors_rec.BATCH_SOURCE_NAME),
         DOC_SEQ_ID	                   = decode(p_hdr_det_factors_rec.DOC_SEQ_ID,FND_API.G_MISS_NUM,
                                                                                                   DOC_SEQ_ID,
                                                                                                   p_hdr_det_factors_rec.DOC_SEQ_ID),
         DOC_SEQ_NAME	                   = decode(p_hdr_det_factors_rec.DOC_SEQ_NAME,FND_API.G_MISS_CHAR,
                                                                                                   DOC_SEQ_NAME,
                                                                                                   p_hdr_det_factors_rec.DOC_SEQ_NAME),
         DOC_SEQ_VALUE	                   = decode(p_hdr_det_factors_rec.DOC_SEQ_VALUE,FND_API.G_MISS_CHAR,
                                                                                                   DOC_SEQ_VALUE,
                                                                                                   p_hdr_det_factors_rec.DOC_SEQ_VALUE),
         TRX_DUE_DATE	                   = decode(p_hdr_det_factors_rec.TRX_DUE_DATE,FND_API.G_MISS_DATE,
                                                                                                   TRX_DUE_DATE,
                                                                                                   p_hdr_det_factors_rec.TRX_DUE_DATE),
         TRX_TYPE_DESCRIPTION	           = decode(p_hdr_det_factors_rec.TRX_TYPE_DESCRIPTION,FND_API.G_MISS_CHAR,
                                                                                                   TRX_TYPE_DESCRIPTION,
                                                                                                   p_hdr_det_factors_rec.TRX_TYPE_DESCRIPTION),
         DOCUMENT_SUB_TYPE	           = decode(p_hdr_det_factors_rec.DOCUMENT_SUB_TYPE,FND_API.G_MISS_CHAR,
                                                                                                   DOCUMENT_SUB_TYPE,
                                                                                                   p_hdr_det_factors_rec.DOCUMENT_SUB_TYPE),
         SUPPLIER_TAX_INVOICE_NUMBER	   = decode(p_hdr_det_factors_rec.SUPPLIER_TAX_INVOICE_NUMBER,FND_API.G_MISS_CHAR,
                                                                                                   SUPPLIER_TAX_INVOICE_NUMBER,
                                                                                                   p_hdr_det_factors_rec.SUPPLIER_TAX_INVOICE_NUMBER),
         SUPPLIER_TAX_INVOICE_DATE	   = decode(p_hdr_det_factors_rec.SUPPLIER_TAX_INVOICE_DATE,FND_API.G_MISS_DATE,
                                                                                                   SUPPLIER_TAX_INVOICE_DATE,
                                                                                                   p_hdr_det_factors_rec.SUPPLIER_TAX_INVOICE_DATE),
         SUPPLIER_EXCHANGE_RATE	           = decode(p_hdr_det_factors_rec.SUPPLIER_EXCHANGE_RATE,FND_API.G_MISS_NUM,
                                                                                                   SUPPLIER_EXCHANGE_RATE,
                                                                                                   p_hdr_det_factors_rec.SUPPLIER_EXCHANGE_RATE),
         TAX_INVOICE_DATE	           = decode(p_hdr_det_factors_rec.TAX_INVOICE_DATE,FND_API.G_MISS_DATE,
                                                                                                   TAX_INVOICE_DATE,
                                                                                                   p_hdr_det_factors_rec.TAX_INVOICE_DATE),
         TAX_INVOICE_NUMBER	           = decode(p_hdr_det_factors_rec.TAX_INVOICE_NUMBER,FND_API.G_MISS_CHAR,
                                                                                                   TAX_INVOICE_NUMBER,
                                                                                                   p_hdr_det_factors_rec.TAX_INVOICE_NUMBER),
         CTRL_TOTAL_HDR_TX_AMT             = decode(p_hdr_det_factors_rec.CTRL_TOTAL_HDR_TX_AMT,FND_API.G_MISS_NUM,
                                                                                                   ctrl_total_hdr_tx_amt,
                                                                                                   p_hdr_det_factors_rec.CTRL_TOTAL_HDR_TX_AMT),
         FIRST_PTY_ORG_ID	           = l_event_class_rec.first_pty_org_id,
         TAX_EVENT_CLASS_CODE	           = l_event_class_rec.TAX_EVENT_CLASS_CODE,
         TAX_EVENT_TYPE_CODE	           = l_event_class_rec.TAX_EVENT_TYPE_CODE,
         DOC_EVENT_STATUS	           = l_event_class_rec.DOC_STATUS_CODE,
         TRX_BATCH_ID                      = decode(p_hdr_det_factors_rec.TRX_BATCH_ID,FND_API.G_MISS_NUM,
                                                                                                   TRX_BATCH_ID,
                                                                                                   p_hdr_det_factors_rec.TRX_BATCH_ID),
         APPLIED_TO_TRX_NUMBER             = decode(p_hdr_det_factors_rec.APPLIED_TO_TRX_NUMBER,FND_API.G_MISS_CHAR,
                                                                                                   APPLIED_TO_TRX_NUMBER,
                                                                                                   p_hdr_det_factors_rec.APPLIED_TO_TRX_NUMBER),
         APPLICATION_DOC_STATUS            = decode(p_hdr_det_factors_rec.APPLICATION_DOC_STATUS,FND_API.G_MISS_CHAR,
                                                                                                   APPLICATION_DOC_STATUS,
                                                                                                   p_hdr_det_factors_rec.APPLICATION_DOC_STATUS),
         RDNG_SHIP_TO_PTY_TX_PROF_ID	   = decode(p_hdr_det_factors_rec.ROUNDING_SHIP_TO_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   RDNG_SHIP_TO_PTY_TX_PROF_ID,
                                                                                                   l_rdng_ship_to_ptp_id),
         RDNG_SHIP_FROM_PTY_TX_PROF_ID	   = decode(p_hdr_det_factors_rec.ROUNDING_SHIP_FROM_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   RDNG_SHIP_FROM_PTY_TX_PROF_ID,
                                                                                                   l_rdng_ship_from_ptp_id),
         RDNG_BILL_TO_PTY_TX_PROF_ID	   = decode(p_hdr_det_factors_rec.ROUNDING_BILL_TO_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   RDNG_BILL_TO_PTY_TX_PROF_ID,
                                                                                                   l_rdng_bill_to_ptp_id),
         RDNG_BILL_FROM_PTY_TX_PROF_ID	   = decode(p_hdr_det_factors_rec.ROUNDING_BILL_FROM_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   RDNG_BILL_FROM_PTY_TX_PROF_ID,
                                                                                                   l_rdng_bill_from_ptp_id),
         RDNG_SHIP_TO_PTY_TX_P_ST_ID	   = decode(p_hdr_det_factors_rec.RNDG_SHIP_TO_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   RDNG_SHIP_TO_PTY_TX_P_ST_ID,
                                                                                                   l_rdng_ship_to_ptp_st_id),
         RDNG_SHIP_FROM_PTY_TX_P_ST_ID	   = decode(p_hdr_det_factors_rec.RNDG_SHIP_FROM_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   RDNG_SHIP_FROM_PTY_TX_P_ST_ID,
                                                                                                   l_rdng_ship_from_ptp_st_id),
         RDNG_BILL_TO_PTY_TX_P_ST_ID	   = decode(p_hdr_det_factors_rec.RNDG_BILL_TO_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   RDNG_BILL_TO_PTY_TX_P_ST_ID,
                                                                                                   l_rdng_bill_to_ptp_st_id),
         RDNG_BILL_FROM_PTY_TX_P_ST_ID 	   = decode(p_hdr_det_factors_rec.RNDG_BILL_FROM_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   RDNG_BILL_FROM_PTY_TX_P_ST_ID,
                                                                                                   l_rdng_bill_from_ptp_st_id),
         PORT_OF_ENTRY_CODE                =  decode(p_hdr_det_factors_rec.PORT_OF_ENTRY_CODE,FND_API.G_MISS_CHAR,
                                                                                                   PORT_OF_ENTRY_CODE,
                                                                                                   p_hdr_det_factors_rec.PORT_OF_ENTRY_CODE),
         TAX_REPORTING_FLAG                = decode(p_hdr_det_factors_rec.TAX_REPORTING_FLAG,FND_API.G_MISS_CHAR,
                                                                                                   TAX_REPORTING_FLAG,
                                                                                                   p_hdr_det_factors_rec.TAX_REPORTING_FLAG),
         PROVNL_TAX_DETERMINATION_DATE     = decode(p_hdr_det_factors_rec.PROVNL_TAX_DETERMINATION_DATE,FND_API.G_MISS_DATE,
                                                                                                   PROVNL_TAX_DETERMINATION_DATE,
                                                                                                   p_hdr_det_factors_rec.PROVNL_TAX_DETERMINATION_DATE),
         SHIP_THIRD_PTY_ACCT_ID            = decode(p_hdr_det_factors_rec.SHIP_THIRD_PTY_ACCT_ID,FND_API.G_MISS_NUM,
                                                                                                   SHIP_THIRD_PTY_ACCT_ID,
                                                                                                   p_hdr_det_factors_rec.SHIP_THIRD_PTY_ACCT_ID),
         BILL_THIRD_PTY_ACCT_ID            = decode(p_hdr_det_factors_rec.BILL_THIRD_PTY_ACCT_ID,FND_API.G_MISS_NUM,
                                                                                                   BILL_THIRD_PTY_ACCT_ID,
                                                                                                   p_hdr_det_factors_rec.BILL_THIRD_PTY_ACCT_ID),
         SHIP_THIRD_PTY_ACCT_SITE_ID       = decode(p_hdr_det_factors_rec.SHIP_THIRD_PTY_ACCT_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   SHIP_THIRD_PTY_ACCT_SITE_ID,
                                                                                                   p_hdr_det_factors_rec.SHIP_THIRD_PTY_ACCT_SITE_ID),
         BILL_THIRD_PTY_ACCT_SITE_ID       = decode(p_hdr_det_factors_rec.BILL_THIRD_PTY_ACCT_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   BILL_THIRD_PTY_ACCT_SITE_ID,
                                                                                                   p_hdr_det_factors_rec.BILL_THIRD_PTY_ACCT_SITE_ID),
         SHIP_TO_CUST_ACCT_SITE_USE_ID     = decode(p_hdr_det_factors_rec.SHIP_TO_CUST_ACCT_SITE_USE_ID,FND_API.G_MISS_NUM,
                                                                                                   SHIP_TO_CUST_ACCT_SITE_USE_ID,
                                                                                                   p_hdr_det_factors_rec.SHIP_TO_CUST_ACCT_SITE_USE_ID),
         BILL_TO_CUST_ACCT_SITE_USE_ID     = decode(p_hdr_det_factors_rec.BILL_TO_CUST_ACCT_SITE_USE_ID,FND_API.G_MISS_NUM,
                                                                                                   BILL_TO_CUST_ACCT_SITE_USE_ID,
                                                                                                   p_hdr_det_factors_rec.BILL_TO_CUST_ACCT_SITE_USE_ID),
         SHIP_TO_LOCATION_ID               = decode(p_hdr_det_factors_rec.SHIP_TO_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   SHIP_TO_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.SHIP_TO_LOCATION_ID),
         SHIP_FROM_LOCATION_ID             = decode(p_hdr_det_factors_rec.SHIP_FROM_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   SHIP_FROM_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.SHIP_FROM_LOCATION_ID),
         BILL_TO_LOCATION_ID               = decode(p_hdr_det_factors_rec.BILL_TO_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   BILL_TO_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.BILL_TO_LOCATION_ID),
         BILL_FROM_LOCATION_ID             = decode(p_hdr_det_factors_rec.BILL_FROM_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   BILL_FROM_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.BILL_FROM_LOCATION_ID),
         POA_LOCATION_ID                   = decode(p_hdr_det_factors_rec.POA_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   POA_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.POA_LOCATION_ID),
         POO_LOCATION_ID                   = decode(p_hdr_det_factors_rec.POO_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   POO_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.POO_LOCATION_ID),
         PAYING_LOCATION_ID                = decode(p_hdr_det_factors_rec.PAYING_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   PAYING_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.PAYING_LOCATION_ID),
         OWN_HQ_LOCATION_ID                = decode(p_hdr_det_factors_rec.OWN_HQ_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   OWN_HQ_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.OWN_HQ_LOCATION_ID),
         TRADING_HQ_LOCATION_ID            = decode(p_hdr_det_factors_rec.TRADING_HQ_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   TRADING_HQ_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.TRADING_HQ_LOCATION_ID),
         POC_LOCATION_ID                   = decode(p_hdr_det_factors_rec.POC_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   POC_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.POC_LOCATION_ID),
         POI_LOCATION_ID                   = decode(p_hdr_det_factors_rec.POI_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   POI_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.POI_LOCATION_ID),
         POD_LOCATION_ID                   = decode(p_hdr_det_factors_rec.POD_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   POD_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.POD_LOCATION_ID),
         TITLE_TRANSFER_LOCATION_ID        = decode(p_hdr_det_factors_rec.TITLE_TRANSFER_LOCATION_ID,FND_API.G_MISS_NUM,
                                                                                                   TITLE_TRANSFER_LOCATION_ID,
                                                                                                   p_hdr_det_factors_rec.TITLE_TRANSFER_LOCATION_ID),
         SHIP_TO_PARTY_TAX_PROF_ID         = decode(p_hdr_det_factors_rec.SHIP_TO_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   SHIP_TO_PARTY_TAX_PROF_ID,
                                                                                                   l_ship_to_ptp_id),
         SHIP_FROM_PARTY_TAX_PROF_ID       = decode(p_hdr_det_factors_rec.SHIP_FROM_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   SHIP_FROM_PARTY_TAX_PROF_ID,
                                                                                                   l_ship_from_ptp_id),
         POA_PARTY_TAX_PROF_ID             = decode(p_hdr_det_factors_rec.POA_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   POA_PARTY_TAX_PROF_ID,
                                                                                                   l_poa_ptp_id),
         POO_PARTY_TAX_PROF_ID             = decode(p_hdr_det_factors_rec.POO_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   POO_PARTY_TAX_PROF_ID,
                                                                                                   l_poo_ptp_id),
         PAYING_PARTY_TAX_PROF_ID          = decode(p_hdr_det_factors_rec.PAYING_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   PAYING_PARTY_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.PAYING_PARTY_TAX_PROF_ID),
         OWN_HQ_PARTY_TAX_PROF_ID          = decode(p_hdr_det_factors_rec.OWN_HQ_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   OWN_HQ_PARTY_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.OWN_HQ_PARTY_TAX_PROF_ID),
         TRADING_HQ_PARTY_TAX_PROF_ID      = decode(p_hdr_det_factors_rec.TRADING_HQ_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   TRADING_HQ_PARTY_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.TRADING_HQ_PARTY_TAX_PROF_ID),
         POI_PARTY_TAX_PROF_ID             = decode(p_hdr_det_factors_rec.POI_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   POI_PARTY_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.POI_PARTY_TAX_PROF_ID),
         POD_PARTY_TAX_PROF_ID             = decode(p_hdr_det_factors_rec.POD_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   POD_PARTY_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.POD_PARTY_TAX_PROF_ID),
         BILL_TO_PARTY_TAX_PROF_ID         = decode(p_hdr_det_factors_rec.BILL_TO_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   BILL_TO_PARTY_TAX_PROF_ID,
                                                                                                   l_bill_to_ptp_id),
         BILL_FROM_PARTY_TAX_PROF_ID       = decode(p_hdr_det_factors_rec.BILL_FROM_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   BILL_FROM_PARTY_TAX_PROF_ID,
                                                                                                   l_bill_from_ptp_id),
         TITLE_TRANS_PARTY_TAX_PROF_ID     = decode(p_hdr_det_factors_rec.TITLE_TRANSFER_PARTY_ID,FND_API.G_MISS_NUM,
                                                                                                   TITLE_TRANS_PARTY_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.TITLE_TRANS_PARTY_TAX_PROF_ID),
         SHIP_TO_SITE_TAX_PROF_ID          = decode(p_hdr_det_factors_rec.SHIP_TO_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   SHIP_TO_SITE_TAX_PROF_ID,
                                                                                                   l_ship_to_ptp_site_id),
         SHIP_FROM_SITE_TAX_PROF_ID        = decode(p_hdr_det_factors_rec.SHIP_FROM_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   SHIP_FROM_SITE_TAX_PROF_ID,
                                                                                                   l_ship_from_ptp_site_id),
         BILL_TO_SITE_TAX_PROF_ID          = decode(p_hdr_det_factors_rec.BILL_TO_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   BILL_TO_SITE_TAX_PROF_ID,
                                                                                                   l_bill_to_ptp_site_id),
         BILL_FROM_SITE_TAX_PROF_ID        = decode(p_hdr_det_factors_rec.BILL_FROM_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   BILL_FROM_SITE_TAX_PROF_ID,
                                                                                                   l_bill_from_ptp_site_id),
         POA_SITE_TAX_PROF_ID              = decode(p_hdr_det_factors_rec.POA_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   POA_SITE_TAX_PROF_ID,
                                                                                                   l_poa_ptp_site_id),
         POO_SITE_TAX_PROF_ID              = decode(p_hdr_det_factors_rec.POO_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   POO_SITE_TAX_PROF_ID,
                                                                                                   l_poo_ptp_site_id),
         PAYING_SITE_TAX_PROF_ID           = decode(p_hdr_det_factors_rec.PAYING_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   PAYING_SITE_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.PAYING_SITE_TAX_PROF_ID),
         OWN_HQ_SITE_TAX_PROF_ID           = decode(p_hdr_det_factors_rec.OWN_HQ_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   OWN_HQ_SITE_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.OWN_HQ_SITE_TAX_PROF_ID),
         POI_SITE_TAX_PROF_ID              = decode(p_hdr_det_factors_rec.POI_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   POI_SITE_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.POI_SITE_TAX_PROF_ID),
         POD_SITE_TAX_PROF_ID              = decode(p_hdr_det_factors_rec.POD_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   POD_SITE_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.POD_SITE_TAX_PROF_ID),
         TITLE_TRANS_SITE_TAX_PROF_ID      = decode(p_hdr_det_factors_rec.TITLE_TRANSFER_PARTY_SITE_ID,FND_API.G_MISS_NUM,
                                                                                                   TITLE_TRANS_SITE_TAX_PROF_ID,
                                                                                                   p_hdr_det_factors_rec.TITLE_TRANS_SITE_TAX_PROF_ID),
         HQ_ESTB_PARTY_TAX_PROF_ID         = l_hq_estb_ptp_id,
         LINE_LEVEL_ACTION                 = decode(LINE_LEVEL_ACTION, 'CREATE','UPDATE',
                                                                       'SYNCHRONIZE','UPDATE',
                                                                        LINE_LEVEL_ACTION),
         TAX_PROCESSING_COMPLETED_FLAG     = 'N',
         LAST_UPDATE_DATE                  = sysdate,
         LAST_UPDATED_BY                   = fnd_global.user_id,
         LAST_UPDATE_LOGIN                 = fnd_global.conc_login_id
       WHERE APPLICATION_ID   = p_hdr_det_factors_rec.APPLICATION_ID
         AND ENTITY_CODE      = p_hdr_det_factors_rec.ENTITY_CODE
         AND EVENT_CLASS_CODE = p_hdr_det_factors_rec.EVENT_CLASS_CODE
         AND TRX_ID           = p_hdr_det_factors_rec.TRX_ID;
      END IF;
    --Bugfix 4486946 - on-the-fly upgrade end

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
    END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Update_Det_Factors_Hdr_PVT;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          DUMP_MSG;
        /*---------------------------------------------------------+
          | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
          | in the message stack. If there is only one message in   |
          | the stack it retrieves this message                     |
          +---------------------------------------------------------*/
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                    p_count  =>      x_msg_count,
                                    p_data   =>      x_msg_data
                                    );

           IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
           END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Update_Det_Factors_Hdr_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          DUMP_MSG;
          FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
          FND_MSG_PUB.Add;
         /*---------------------------------------------------------+
          | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
          | in the message stack. If there is only one message in   |
          | the stack it retrieves this message                     |
          +---------------------------------------------------------*/
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                    p_count   =>      x_msg_count,
                                    p_data    =>      x_msg_data
                                    );
          IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
          END IF;
        WHEN OTHERS THEN
           ROLLBACK TO Update_Det_Factors_Hdr_PVT;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
           FND_MSG_PUB.Add;
         /*---------------------------------------------------------+
          | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
          | in the message stack. If there is only one message in   |
          | the stack it retrieves this message                     |
          +---------------------------------------------------------*/
           FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                     p_count  =>      x_msg_count,
                                     p_data   =>      x_msg_data
                                     );

           IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;
 END update_det_factors_hdr;


/* ========================================================================*
 | PROCEDURE  update_line_det_factors : This procedure should be called by |
 | products when updating any of the line attributes on the transaction    |
 | so that the tax repository is also in sync with the line level updates  |
 | This line will be flagged to be picked up by the tax calculation process|
 * =======================================================================*/

PROCEDURE update_line_det_factors (
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2,
  p_commit             IN  VARCHAR2,
  p_validation_level   IN  NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2
 )  IS
  l_api_name           CONSTANT  VARCHAR2(30) := 'UPDATE_LINE_DET_FACTORS';
  l_api_version        CONSTANT  NUMBER := 1.0;
  l_return_status      VARCHAR2(1);
  l_init_msg_list      VARCHAR2(1);
  l_user_updated_flag  VARCHAR2(1);
  l_call_default_APIs  BOOLEAN;
  l_upg_trx_info_rec   ZX_ON_FLY_TRX_UPGRADE_PKG.zx_upg_trx_info_rec_type;
  l_event_class_rec    event_class_rec_type;

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Update_Line_Det_Factors_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
       l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

  /*-----------------------------------------+
   |   Initialize return status to SUCCESS   |
   +-----------------------------------------*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*-----------------------------------------+
   |   Populate Global Variable              |
   +-----------------------------------------*/
   G_PUB_SRVC := l_api_name;
   G_DATA_TRANSFER_MODE := 'PLS';
   G_EXTERNAL_API_CALL  := 'N';

   l_event_class_rec.INTERNAL_ORGANIZATION_ID     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID(1);
   l_event_class_rec.LEGAL_ENTITY_ID              :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEGAL_ENTITY_ID(1);
   l_event_class_rec.LEDGER_ID                    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEDGER_ID(1);
   l_event_class_rec.APPLICATION_ID               :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLICATION_ID(1);
   l_event_class_rec.ENTITY_CODE                  :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ENTITY_CODE(1);
   l_event_class_rec.EVENT_CLASS_CODE             :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_CLASS_CODE(1);
   l_event_class_rec.EVENT_TYPE_CODE              :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_TYPE_CODE(1);
   l_event_class_rec.CTRL_TOTAL_HDR_TX_AMT        :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CTRL_TOTAL_HDR_TX_AMT(1);
   l_event_class_rec.TRX_ID                       :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID(1);
   l_event_class_rec.TRX_DATE                     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DATE(1);
   l_event_class_rec.REL_DOC_DATE                 :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_DATE(1);
   l_event_class_rec.PROVNL_TAX_DETERMINATION_DATE:=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PROVNL_TAX_DETERMINATION_DATE(1);
   l_event_class_rec.TRX_CURRENCY_CODE            :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_CURRENCY_CODE(1);
   l_event_class_rec.PRECISION                    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRECISION(1);
   l_event_class_rec.CURRENCY_CONVERSION_TYPE     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_TYPE(1);
   l_event_class_rec.CURRENCY_CONVERSION_RATE     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_RATE(1);
   l_event_class_rec.CURRENCY_CONVERSION_DATE     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_DATE(1);
   l_event_class_rec.ROUNDING_SHIP_TO_PARTY_ID    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_SHIP_TO_PARTY_ID(1);
   l_event_class_rec.ROUNDING_SHIP_FROM_PARTY_ID  :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_SHIP_FROM_PARTY_ID(1);
   l_event_class_rec.ROUNDING_BILL_TO_PARTY_ID    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_BILL_TO_PARTY_ID(1);
   l_event_class_rec.ROUNDING_BILL_FROM_PARTY_ID  :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_BILL_FROM_PARTY_ID(1);
   l_event_class_rec.RNDG_SHIP_TO_PARTY_SITE_ID   :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_SHIP_TO_PARTY_SITE_ID(1);
   l_event_class_rec.RNDG_SHIP_FROM_PARTY_SITE_ID :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_SHIP_FROM_PARTY_SITE_ID(1);
   l_event_class_rec.RNDG_BILL_TO_PARTY_SITE_ID   :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_BILL_TO_PARTY_SITE_ID(1);
   l_event_class_rec.RNDG_BILL_FROM_PARTY_SITE_ID :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_BILL_FROM_PARTY_SITE_ID(1);


   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
            'application_id: '||to_char(l_event_class_rec.application_id)||
             ', entity_code: '||l_event_class_rec.entity_code||
             ', event_class_code: '||l_event_class_rec.event_class_code||
             ', event_type_code: '||l_event_class_rec.event_type_code||
             ', trx_id: '||to_char(l_event_class_rec.trx_id)||
             ', internal_organization_id: '||to_char(l_event_class_rec.internal_organization_id)||
             ', ledger_id: '||to_char(l_event_class_rec.ledger_id)||
             ', legal_entity_id: '||to_char(l_event_class_rec.legal_entity_id)||
             ', trx_date: '||to_char(l_event_class_rec.trx_date)||
             ', related_document_date: '||to_char(l_event_class_rec.rel_doc_date)||
             ', provnl_tax_determination_date: '||to_char(l_event_class_rec.provnl_tax_determination_date)||
             ', trx_currency_code: '||l_event_class_rec.trx_currency_code||
             ', currency_conversion_type: '||l_event_class_rec.currency_conversion_type||
             ', currency_conversion_rate: '||to_char(l_event_class_rec.currency_conversion_rate)||
             ', currency_conversion_date: '||to_char(l_event_class_rec.currency_conversion_date)||
             ', rounding_ship_to_party_id: '||to_char(l_event_class_rec.rounding_ship_to_party_id)||
             ', rounding_ship_from_party_id: '||to_char(l_event_class_rec.rounding_ship_from_party_id)||
             ', rounding_bill_to_party_id: '||to_char(l_event_class_rec.rounding_bill_to_party_id)||
             ', rounding_bill_from_party_id: '||to_char(l_event_class_rec.rounding_bill_from_party_id)||
             ', rndg_ship_to_party_site_id: '||to_char(l_event_class_rec.rndg_ship_to_party_site_id)||
             ', rndg_ship_from_party_site_id: '||to_char(l_event_class_rec.rndg_ship_from_party_site_id)||
             ', rndg_bill_to_party_site_id: '||to_char(l_event_class_rec.rndg_bill_to_party_site_id)||
             ', rndg_bill_from_party_site_id: '||to_char(l_event_class_rec.rndg_bill_from_party_site_id)
            );
   END IF;


   /*Lock the line so no updates by another user can happen*/
   BEGIN
     SELECT event_id,
            nvl(user_upd_det_factors_flag,'N')
      INTO l_event_class_rec.event_id,
           l_user_updated_flag
      FROM ZX_LINES_DET_FACTORS
     WHERE application_id   = l_event_class_rec.application_id
       AND entity_code      = l_event_class_rec.entity_code
       AND event_class_code = l_event_class_rec.event_class_code
       AND trx_id           = l_event_class_rec.trx_id
       AND trx_line_id      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(1)
       AND trx_level_type   = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(1)
     FOR UPDATE NOWAIT; --locks the line

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_upg_trx_info_rec.application_id   := l_event_class_rec.application_id;
         l_upg_trx_info_rec.entity_code      := l_event_class_rec.entity_code;
         l_upg_trx_info_rec.event_class_code := l_event_class_rec.event_class_code;
         l_upg_trx_info_rec.trx_id           := l_event_class_rec.trx_id;
         ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly(p_upg_trx_info_rec   =>  l_upg_trx_info_rec,
                                                      x_return_status      =>  l_return_status
                                                     );
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly returned errors');
           END IF;
           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
           ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
         END IF;
         /*Lock the line so no updates by another user can happen*/
         SELECT event_id,
                nvl(user_upd_det_factors_flag,'N')
           INTO l_event_class_rec.event_id,
                l_user_updated_flag
           FROM ZX_LINES_DET_FACTORS
          WHERE application_id   = l_event_class_rec.application_id
            AND entity_code      = l_event_class_rec.entity_code
            AND event_class_code = l_event_class_rec.event_class_code
            AND trx_id           = l_event_class_rec.trx_id
            AND trx_line_id      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(1)
            AND trx_level_type   = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_level_type(1)
          FOR UPDATE NOWAIT; --locks the line
   END;

     /*------------------------------------------------------+
      |   Validate and Initializate parameters for Inserting |
      |   into line_det_factors                              |
      +------------------------------------------------------*/

   IF ( G_LEVEL_EVENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_EVENT,G_MODULE_NAME||l_api_name,
              'Validating Transaction: '||
              to_char(l_event_class_rec.trx_id)||
              ' of Application: '||
              to_char(l_event_class_rec.application_id) ||
              ' and Event Class: '||
              l_event_class_rec.event_class_code
            );
   END IF;

   ZX_VALID_INIT_PARAMS_PKG.insupd_line_det_factors(p_event_class_rec =>l_event_class_rec,
                                                    p_trx_line_index  => 1,
                                                    x_return_status   =>l_return_status
                                                    );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
          ':ZX_VALID_INIT_PARAMS_PKG.insupd_line_det_factors returned errors');
     END IF;
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;

-- Fix for Bug 5038953
   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_EVENT_CLASS_CODE(1) := l_event_class_rec.TAX_EVENT_CLASS_CODE;
-- End fix for Bug 5038953

   /*----------------------------------------------------------------------------+
   |Call the defaulting API to default the determining attributes if user has not|
   |already overridden them in the determining factors window in which case we   |
   |need to honor the overridden values                                          |
   +----------------------------------------------------------------------------*/
   IF l_user_updated_flag = 'N' THEN
      --Call the redefaulting APIs only if all tax determining attributes passed as null
      l_call_default_APIs := ZX_SRVC_TYP_PKG.decide_call_redefault_APIs (p_trx_line_index  => 1);

      IF l_call_default_APIs THEN
        IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(1) = 'UPDATE' THEN
           ZX_SRVC_TYP_PKG.call_redefaulting_APIs(p_event_class_rec  => l_event_class_rec,
                                                  p_trx_line_index   => 1,
                                                  x_return_status    => l_return_status
                                                 );
        END IF;
      END IF;

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
            ':ZX_SRVC_TYP_PKG.call_redefaulting_APIs returned errors');
        END IF;
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
   END IF;

   /*------------------------------------------+
   |Call to update the lines                   |
   +------------------------------------------*/
   ZX_SRVC_TYP_PKG.insupd_line_det_factors(p_event_class_rec => l_event_class_rec,
                                           x_return_status   => l_return_status
                                          );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
          ':ZX_SRVC_TYP_PKG.insupd_line_det_factors returned errors');
     END IF;
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;

   --Delete from the global structures so that there are no hanging/redundant
   --records sitting there
   ZX_GLOBAL_STRUCTURES_PKG.delete_trx_line_dist_tbl;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
   END IF;

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO Update_Line_Det_Factors_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       DUMP_MSG;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count  =>      x_msg_count,
                                 p_data   =>      x_msg_data
                                 );

       IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
       END IF;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO Update_Line_Det_Factors_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       DUMP_MSG;
       FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
       FND_MSG_PUB.Add;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count   =>      x_msg_count,
                                 p_data    =>      x_msg_data
                                );
       IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
       END IF;

       WHEN OTHERS THEN
          /*-------------------------------------------------------+
           |  Handle application errors that result from trapable  |
           |  error conditions. The error messages have already    |
           |  been put on the error stack.                         |
           +-------------------------------------------------------*/
          ROLLBACK TO Update_Line_Det_Factors_PVT;
          IF (SQLCODE = 54) THEN
             x_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MESSAGE.SET_NAME('ZX','ZX_RESOURCE_BUSY');
          ELSE
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
          END IF;
          FND_MSG_PUB.Add;
         /*---------------------------------------------------------+
          | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
          | in the message stack. If there is only one message in   |
          | the stack it retrieves this message                     |
          +---------------------------------------------------------*/
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                    p_count  =>      x_msg_count,
                                    p_data   =>      x_msg_data
                                    );

          IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;
   END update_line_det_factors;

/* ============================================================================*
 | PROCEDURE  copy_insert_line_det_factors : This procedure will be called      |
 | by iProcurement to insert all the transaction lines into zx_lines_det_factors|
 | after copying the tax determining attributes from the source document        |
 | information passed in. All lines thus inserted will be flagged to be picked  |
 | up by the tax calculation process                                            |
 * ============================================================================*/

 PROCEDURE copy_insert_line_det_factors(
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2,
  p_commit             IN  VARCHAR2,
  p_validation_level   IN  NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2
  )IS
  l_api_name                  CONSTANT  VARCHAR2(30) := 'COPY_INSERT_LINE_DET_FACTORS';
  l_api_version               CONSTANT  NUMBER := 1.0;
  l_return_status             VARCHAR2(1);
  l_event_class_rec           event_class_rec_type;
  l_line_det_rec              ZX_LINES_DET_FACTORS%rowtype;
  l_line_exists               NUMBER;
  l_record_exists             BOOLEAN;
  l_init_msg_list             VARCHAR2(1);
  l_tax_classification_code   VARCHAR2(50);
 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Copy_Ins_Line_Det_Factors_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
       l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

  /*-----------------------------------------+
   |   Initialize return status to SUCCESS   |
   +-----------------------------------------*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*-----------------------------------------+
   |   Populate Global Variable              |
   +-----------------------------------------*/
   G_PUB_SRVC := l_api_name;
   G_DATA_TRANSFER_MODE := 'PLS';
   G_EXTERNAL_API_CALL  := 'N';


   /*-----------------------------------------+
    |Populate the event class record structure|
    +-----------------------------------------*/
   l_event_class_rec.INTERNAL_ORGANIZATION_ID     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID(1);
   l_event_class_rec.LEGAL_ENTITY_ID              :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEGAL_ENTITY_ID(1);
   l_event_class_rec.LEDGER_ID                    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEDGER_ID(1);
   l_event_class_rec.APPLICATION_ID               :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLICATION_ID(1);
   l_event_class_rec.ENTITY_CODE                  :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ENTITY_CODE(1);
   l_event_class_rec.EVENT_CLASS_CODE             :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_CLASS_CODE(1);
   l_event_class_rec.EVENT_TYPE_CODE              :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_TYPE_CODE(1);
   l_event_class_rec.CTRL_TOTAL_HDR_TX_AMT        :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CTRL_TOTAL_HDR_TX_AMT(1);
   l_event_class_rec.TRX_ID                       :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID(1);
   l_event_class_rec.TRX_DATE                     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DATE(1);
   l_event_class_rec.REL_DOC_DATE                 :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RELATED_DOC_DATE(1);
   l_event_class_rec.PROVNL_TAX_DETERMINATION_DATE:=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PROVNL_TAX_DETERMINATION_DATE(1);
   l_event_class_rec.TRX_CURRENCY_CODE            :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_CURRENCY_CODE(1);
   l_event_class_rec.CURRENCY_CONVERSION_TYPE     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_TYPE(1);
   l_event_class_rec.CURRENCY_CONVERSION_RATE     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_RATE(1);
   l_event_class_rec.CURRENCY_CONVERSION_DATE     :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_DATE(1);
   l_event_class_rec.ROUNDING_SHIP_TO_PARTY_ID    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_SHIP_TO_PARTY_ID(1);
   l_event_class_rec.ROUNDING_SHIP_FROM_PARTY_ID  :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_SHIP_FROM_PARTY_ID(1);
   l_event_class_rec.ROUNDING_BILL_TO_PARTY_ID    :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_BILL_TO_PARTY_ID(1);
   l_event_class_rec.ROUNDING_BILL_FROM_PARTY_ID  :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_BILL_FROM_PARTY_ID(1);
   l_event_class_rec.RNDG_SHIP_TO_PARTY_SITE_ID   :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_SHIP_TO_PARTY_SITE_ID(1);
   l_event_class_rec.RNDG_SHIP_FROM_PARTY_SITE_ID :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_SHIP_FROM_PARTY_SITE_ID(1);
   l_event_class_rec.RNDG_BILL_TO_PARTY_SITE_ID   :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_BILL_TO_PARTY_SITE_ID(1);
   l_event_class_rec.RNDG_BILL_FROM_PARTY_SITE_ID :=  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_BILL_FROM_PARTY_SITE_ID(1);


   /*------------------------------------------------------------------------------------------+
    | Set the event id for the whole document- Since this API is called for each transaction   |
    | line, the event id needs to be generated from the sequence only for the first transaction|
    | line. For other lines, we need to retrieve the event id from the table.                  |
    | Also store the taxation country, document sub type from the line to be passed to         |
    | defaulting API which will honor these header attributes of the line instead of trying to |
    | redefault them again                                                                     |
    +-----------------------------------------------------------------------------------------*/
    l_record_exists := FALSE;
    FOR l_line_det_rec in lock_line_det_factors_for_doc(l_event_class_rec)
    LOOP
      l_record_exists := TRUE;
      l_event_class_rec.event_id := l_line_det_rec.event_id;
      exit;
    END LOOP;


    IF NOT(l_record_exists) THEN
      SELECT zx_lines_det_factors_s.nextval
        INTO l_event_class_rec.event_id
        FROM dual;
    END IF;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
             'application_id: '||to_char(l_event_class_rec.application_id)||
             ', entity_code: '||l_event_class_rec.entity_code||
             ', event_class_code: '||l_event_class_rec.event_class_code||
             ', event_type_code: '||l_event_class_rec.event_type_code||
             ', trx_id: '||to_char(l_event_class_rec.trx_id)||
             ', internal_organization_id: '||to_char(l_event_class_rec.internal_organization_id)||
             ', ledger_id: '||to_char(l_event_class_rec.ledger_id)||
             ', legal_entity_id: '||to_char(l_event_class_rec.legal_entity_id)||
             ', trx_date: '||to_char(l_event_class_rec.trx_date)||
             ', related_document_date: '||to_char(l_event_class_rec.rel_doc_date)||
             ', provnl_tax_determination_date: '||to_char(l_event_class_rec.provnl_tax_determination_date)||
             ', trx_currency_code: '||l_event_class_rec.trx_currency_code||
             ', currency_conversion_type: '||l_event_class_rec.currency_conversion_type||
             ', currency_conversion_rate: '||to_char(l_event_class_rec.currency_conversion_rate)||
             ', currency_conversion_date: '||to_char(l_event_class_rec.currency_conversion_date)||
             ', rounding_ship_to_party_id: '||to_char(l_event_class_rec.rounding_ship_to_party_id)||
             ', rounding_ship_from_party_id: '||to_char(l_event_class_rec.rounding_ship_from_party_id)||
             ', rounding_bill_to_party_id: '||to_char(l_event_class_rec.rounding_bill_to_party_id)||
             ', rounding_bill_from_party_id: '||to_char(l_event_class_rec.rounding_bill_from_party_id)||
             ', rndg_ship_to_party_site_id: '||to_char(l_event_class_rec.rndg_ship_to_party_site_id)||
             ', rndg_ship_from_party_site_id: '||to_char(l_event_class_rec.rndg_ship_from_party_site_id)||
             ', rndg_bill_to_party_site_id: '||to_char(l_event_class_rec.rndg_bill_to_party_site_id)||
             ', rndg_bill_from_party_site_id: '||to_char(l_event_class_rec.rndg_bill_from_party_site_id)
            );
   END IF;

   /*------------------------------------------------------+
   |   Validate and Initializate parameters for Inserting |
   |   into line_det_factors                              |
   +------------------------------------------------------*/
   ZX_VALID_INIT_PARAMS_PKG.insupd_line_det_factors(p_event_class_rec =>l_event_class_rec,
                                                     p_trx_line_index  => 1,
                                                     x_return_status   =>l_return_status
                                                    );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
          ':ZX_VALID_INIT_PARAMS_PKG.insupd_line_det_factors returned errors');
     END IF;
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;

 /* =============================================*
   |Default the tax determining attributes        |
   * ============================================*/
   /*If the Source Document Line identifiers are passed, then derive the values
     of the tax determining factors from ZX_LINES_DET_FACTORS for the source document line.*/
   FOR i in 1 .. nvl(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id.LAST,-99)
   LOOP
     SELECT
       default_taxation_country,
       document_sub_type,
       trx_business_category,
       line_intended_use,
       user_defined_fisc_class,
       product_fisc_classification,
       product_category,
       assessable_value,
       product_type,
       decode(l_event_class_rec.prod_family_grp_code,'P2P',input_tax_classification_code,
                                                     'O2C',output_tax_classification_code)
     INTO
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.default_taxation_country(i),
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.document_sub_type(i),
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_business_category(i),
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_intended_use(i),
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.user_defined_fisc_class(i),
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_fisc_classification(i),
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_category(i),
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.assessable_value(i),
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_type(i),
        l_tax_classification_code
     FROM ZX_LINES_DET_FACTORS
    WHERE application_id = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_application_id(i)
      AND entity_code = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_entity_code(i)
      AND event_class_code = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_event_class_code(i)
      AND trx_id = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_trx_id(i)
      AND trx_line_id = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_line_id(i)
      AND trx_level_type = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_trx_level_type(i);

     IF l_event_class_rec.prod_family_grp_code = 'P2P' THEN
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.input_tax_classification_code(i) := l_tax_classification_code;
     ELSIF l_event_class_rec.prod_family_grp_code = 'O2C' AND --AR passes the tax classification code so do not override
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.output_tax_classification_code(i) is null  THEN
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.output_tax_classification_code(i) := l_tax_classification_code;
     END IF;
   END LOOP;
   /*------------------------------------------+
   |Call to insert the lines                   |
   +------------------------------------------*/
   ZX_SRVC_TYP_PKG.insupd_line_det_factors(p_event_class_rec  => l_event_class_rec,
                                           x_return_status    => l_return_status
                                          );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
          ':ZX_SRVC_TYP_PKG.insupd_line_det_factors returned errors');
     END IF;
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;

   --Delete from the global structures so that there are no hanging/redundant
   --records sitting there
   ZX_GLOBAL_STRUCTURES_PKG.delete_trx_line_dist_tbl;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
   END IF;

   EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Copy_Ins_Line_Det_Factors_PVT;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          DUMP_MSG;
         /*---------------------------------------------------------+
          | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
          | in the message stack. If there is only one message in   |
          | the stack it retrieves this message                     |
          +---------------------------------------------------------*/
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                    p_count  =>      x_msg_count,
                                    p_data   =>      x_msg_data
                                    );

           IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
           END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Copy_Ins_Line_Det_Factors_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          DUMP_MSG;
          FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
          FND_MSG_PUB.Add;
         /*---------------------------------------------------------+
          | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
          | in the message stack. If there is only one message in   |
          | the stack it retrieves this message                     |
          +---------------------------------------------------------*/
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                    p_count   =>      x_msg_count,
                                    p_data    =>      x_msg_data
                                    );
          IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
          END IF;

        WHEN OTHERS THEN
          /*-------------------------------------------------------+
           |  Handle application errors that result from trapable  |
           |  error conditions. The error messages have already    |
           |  been put on the error stack.                         |
           +-------------------------------------------------------*/
           ROLLBACK TO Copy_Ins_Line_Det_Factors_PVT;
           IF (SQLCODE = 54) THEN
             x_return_status := FND_API.G_RET_STS_ERROR ;
             FND_MESSAGE.SET_NAME('ZX','ZX_RESOURCE_BUSY');
           ELSE
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
           END IF;
           FND_MSG_PUB.Add;
         /*---------------------------------------------------------+
          | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
          | in the message stack. If there is only one message in   |
          | the stack it retrieves this message                     |
          +---------------------------------------------------------*/
           FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                     p_count  =>      x_msg_count,
                                     p_data   =>      x_msg_data
                                     );

           IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
           END IF;
 END copy_insert_line_det_factors;


/* ============================================================================*
 | PROCEDURE  is_recoverability_affected : This procedure will determine       |
 | whether some accounting related information can be modified on the item     |
 | distribution from tax point of view.                                        |
 * ============================================================================*/
 PROCEDURE is_recoverability_affected(
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2,
  p_commit             IN  VARCHAR2,
  p_validation_level   IN  NUMBER,
  x_return_status      OUT NOCOPY     VARCHAR2,
  x_msg_count          OUT NOCOPY     NUMBER,
  x_msg_data           OUT NOCOPY     VARCHAR2,
  p_pa_item_info_tbl   IN  OUT NOCOPY pa_item_info_tbl_type
  )IS
  l_api_name                  CONSTANT  VARCHAR2(30) := 'IS_RECOVERABILITY_AFFECTED';
  l_api_version               CONSTANT  NUMBER := 1.0;
  l_return_status             VARCHAR2(1);
  l_init_msg_list             VARCHAR2(1);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Is_Recoverability_Affected_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
       l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

  /*-----------------------------------------+
   |   Initialize return status to SUCCESS   |
   +-----------------------------------------*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*-----------------------------------------+
   |   Populate Global Variable              |
   +-----------------------------------------*/
   G_PUB_SRVC := l_api_name;
   G_DATA_TRANSFER_MODE := 'PLS';
   G_EXTERNAL_API_CALL  := 'N';

   IF ( G_LEVEL_EVENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_EVENT,G_MODULE_NAME||l_api_name,
      'Call TRD service to determine if accouting info on distributions can be modified'
       );
   END IF;

   ZX_TRD_SERVICES_PUB_PKG.is_recoverability_affected(p_pa_item_info_tbl => p_pa_item_info_tbl,
                                                      x_return_status    => l_return_status
                                                     );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
          ':ZX_TRD_SERVICES_PUB_PKG.is_recoverability_affected returned errors');
     END IF;
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
   END IF;

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Is_Recoverability_Affected_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        DUMP_MSG;
       /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data
                                  );

        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Is_Recoverability_Affected_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        DUMP_MSG;
        FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
        FND_MSG_PUB.Add;
       /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data
                                  );

        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN OTHERS THEN
         ROLLBACK TO Is_Recoverability_Affected_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
         FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count   => x_msg_count,
                                   p_data    => x_msg_data
                                   );
         IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;

 END is_recoverability_affected;

/* ======================================================================*
 | PROCEDURE delete_tax_line_and_distributions:                          |
 * ======================================================================*/

 PROCEDURE del_tax_line_and_distributions(
  p_api_version           IN            NUMBER,
  p_init_msg_list         IN            VARCHAR2,
  p_commit                IN            VARCHAR2,
  p_validation_level      IN            NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2 ,
  x_msg_count             OUT NOCOPY    NUMBER ,
  x_msg_data              OUT NOCOPY    VARCHAR2 ,
  p_transaction_line_rec  IN OUT NOCOPY transaction_line_rec_type
  )IS
  l_api_name                  CONSTANT  VARCHAR2(30) := 'DEL_TAX_LINE_AND_DISTRIBUTIONS';
  l_api_version               CONSTANT  NUMBER := 1.0;
  l_return_status             VARCHAR2(1);
  l_init_msg_list             VARCHAR2(1);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Del_Tax_Line_And_Dists_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
       l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

    /*-----------------------------------------+
     |   Initialize return status to SUCCESS   |
     +-----------------------------------------*/
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*-----------------------------------------+
     |   Populate Global Variable              |
     +-----------------------------------------*/
     G_PUB_SRVC := l_api_name;
     G_DATA_TRANSFER_MODE := 'PLS';
     G_EXTERNAL_API_CALL  := 'N';

    /*-----------------------------------------+
     |   Delete transaction line               |
     +-----------------------------------------*/

     DELETE from ZX_LINES_DET_FACTORS
       WHERE application_id = p_transaction_line_rec.application_id
         AND entity_code = p_transaction_line_rec.entity_code
         AND event_class_code = p_transaction_line_rec.event_class_code
         AND trx_id = p_transaction_line_rec.trx_id
         AND trx_line_id = p_transaction_line_rec.trx_line_id
         AND trx_level_type = p_transaction_line_rec.trx_level_type;


    /*-----------------------------------------+
     |   Delete tax line and distributions     |
     +-----------------------------------------*/
     ZX_TRL_PUB_PKG.delete_tax_lines_and_dists(p_application_id    => p_transaction_line_rec.application_id,
                                               p_entity_code       => p_transaction_line_rec.entity_code,
                                               p_event_class_code  => p_transaction_line_rec.event_class_code,
                                               p_trx_id            => p_transaction_line_rec.trx_id,
                                               p_trx_line_id       => p_transaction_line_rec.trx_line_id,
                                               p_trx_level_type    => p_transaction_line_rec.trx_level_type,
                                               x_return_status     => l_return_status
                                              );
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
           ':ZX_TRL_PUB_PKG.delete_tax_lines_and_dists returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
     END IF;

     EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Del_Tax_Line_And_Dists_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        DUMP_MSG;
       /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data
                                  );

        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Del_Tax_Line_And_Dists_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        DUMP_MSG;
        FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
        FND_MSG_PUB.Add;
       /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data
                                  );

        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN OTHERS THEN
         ROLLBACK TO Del_Tax_Line_And_Dists_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
         FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count   => x_msg_count,
                                   p_data    => x_msg_data
                                   );
         IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;

 END del_tax_line_and_distributions;

/* ======================================================================*
 | PROCEDURE delete_tax_distributions:                                   |
 * ======================================================================*/

 PROCEDURE delete_tax_distributions(
  p_api_version           IN            NUMBER,
  p_init_msg_list         IN            VARCHAR2,
  p_commit                IN            VARCHAR2,
  p_validation_level      IN            NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2 ,
  x_msg_count             OUT NOCOPY    NUMBER ,
  x_msg_data              OUT NOCOPY    VARCHAR2 ,
  p_transaction_line_rec  IN OUT NOCOPY transaction_line_rec_type
  )IS
  l_api_name                  CONSTANT  VARCHAR2(30) := 'DEL_TAX_DISTRIBUTIONS';
  l_api_version               CONSTANT  NUMBER := 1.0;
  l_return_status             VARCHAR2(1);
  l_init_msg_list             VARCHAR2(1);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Del_Tax_Distributions_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
       l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

    /*-----------------------------------------+
     |   Initialize return status to SUCCESS   |
     +-----------------------------------------*/
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*-----------------------------------------+
     |   Populate Global Variable              |
     +-----------------------------------------*/
     G_PUB_SRVC := l_api_name;
     G_DATA_TRANSFER_MODE := 'PLS';
     G_EXTERNAL_API_CALL  := 'N';

    /*-----------------------------------------+
     |   Delete tax distributions              |
     +-----------------------------------------*/
     IF ( G_LEVEL_EVENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_EVENT,G_MODULE_NAME||l_api_name,
        'Call TRL service to delete tax distributions'
        );
     END IF;

     ZX_TRL_PUB_PKG.delete_tax_dists (p_application_id    => p_transaction_line_rec.application_id,
                                      p_entity_code       => p_transaction_line_rec.entity_code,
                                      p_event_class_code  => p_transaction_line_rec.event_class_code,
                                      p_trx_id            => p_transaction_line_rec.trx_id,
                                      p_trx_line_id       => p_transaction_line_rec.trx_line_id,
                                      p_trx_level_type    => p_transaction_line_rec.trx_level_type,
                                      x_return_status     => l_return_status
                                      );
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
           ':ZX_TRL_PUB_PKG.delete_tax_dists returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
     END IF;

     EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Del_Tax_Distributions_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        DUMP_MSG;
       /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data
                                  );

        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Del_Tax_Distributions_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        DUMP_MSG;
        FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
        FND_MSG_PUB.Add;
       /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data
                                  );

        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN OTHERS THEN
         ROLLBACK TO Del_Tax_Distributions_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
         FND_MSG_PUB.Add;
       /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count   => x_msg_count,
                                   p_data    => x_msg_data
                                   );
         IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;

 END delete_tax_distributions;

 -----------------------------------------------------------------------
 --  PUBLIC PROCEDURE
 --  get_default_tax_det_attrs
 --
 --  DESCRIPTION
 --  This overloaded procedure acts as a wrapper on TDS default_tax_attribs
 --  procedure to default the tax determining attributes. It follows the
 --  following logic defaulting the determining attributes.
 --
 --  Fetch from zx_trx_headers_gt and zx_trx_transaction_lines_gt into
 --  global structure zx_global_structures_pkg.trx_line_dist_tbl
 --  For records in trx_line_dist_tbl
 --  Loop
 --    If line_level_action is UPDATE
 --      If all tax determining attributes are passed null
 --        Fetch all attributes from zx_lines_det_factors
 --        if item/item_org_id/country has changed
 --           call RE-defaulting API for intended_use, product_fiscal_classification
 --        if item/item_org_id/assessable value has changed
 --           call redefaulting API for assessable value
 --        Always call the tax classification defaulting API
 --    ELSIF line level action is CREATE
 --       IF historical_tax_code_id/global_attribute_category/global_Attribute1 passed
 --          redefault the tax attributes for PO (on the fly migration)
 --       elsif historical tax code id/global_attribute_category/global_attribute1 null
 --          If adjusted_doc informaiton passed
 --            default from adjusted_doc
 --          elsif applied_from information passed
 --            default from applied_from
 --          elsif soure_doc information passed
 --            default from source
 --          else
 --            call the TDM default API
 --  End loop
 --  Update the GTTs with the defaulting attributes derived here.

 --  CALLED BY
 --    populateTaxAttributes java method given to iP/PO
 --    directly from forms
 ----------------------------------------------------------------------
 PROCEDURE get_default_tax_det_attribs(
  p_api_version           IN            NUMBER,
  p_init_msg_list         IN            VARCHAR2,
  p_commit                IN            VARCHAR2,
  p_validation_level      IN            NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2
 )IS
  l_api_name                      CONSTANT  VARCHAR2(30) := 'GET_DEFAULT_TAX_DET_ATTRIBS';
  l_api_version                   CONSTANT  NUMBER := 1.0;
  l_return_status                 VARCHAR2(1);
  l_init_msg_list                 VARCHAR2(1);
  l_event_class_rec               event_class_rec_type;
  l_context_info_rec              context_info_rec_type;
  l_transaction_header_rec        transaction_header_rec_type;

   CURSOR headers_doc IS
     SELECT INTERNAL_ORGANIZATION_ID,
            LEGAL_ENTITY_ID,
            LEDGER_ID,
            APPLICATION_ID,
            ENTITY_CODE,
            EVENT_CLASS_CODE,
            EVENT_TYPE_CODE,
            CTRL_TOTAL_HDR_TX_AMT,
            TRX_ID,
            TRX_DATE,
            RELATED_DOC_DATE,
            PROVNL_TAX_DETERMINATION_DATE,
            TRX_CURRENCY_CODE,
            PRECISION,
            CURRENCY_CONVERSION_TYPE,
            CURRENCY_CONVERSION_RATE,
            CURRENCY_CONVERSION_DATE,
            ROUNDING_SHIP_TO_PARTY_ID,
            ROUNDING_SHIP_FROM_PARTY_ID,
            ROUNDING_BILL_TO_PARTY_ID,
            ROUNDING_BILL_FROM_PARTY_ID,
            RNDG_SHIP_TO_PARTY_SITE_ID,
            RNDG_SHIP_FROM_PARTY_SITE_ID,
            RNDG_BILL_TO_PARTY_SITE_ID,
            RNDG_BILL_FROM_PARTY_SITE_ID,
            QUOTE_FLAG,
            ESTABLISHMENT_ID
       FROM ZX_TRX_HEADERS_GT;

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Get_Default_Tax_Det_Attrs_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
       l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

    /*-----------------------------------------+
     |   Initialize return status to SUCCESS   |
     +-----------------------------------------*/
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*-----------------------------------------+
     |   Populate Global Variable              |
     +-----------------------------------------*/
     G_PUB_SRVC := l_api_name;
     G_DATA_TRANSFER_MODE := 'TAB';
     G_EXTERNAL_API_CALL  := 'N';

     OPEN headers_doc;
     LOOP
       FETCH headers_doc BULK COLLECT INTO
             l_transaction_header_rec.INTERNAL_ORGANIZATION_ID,
             l_transaction_header_rec.LEGAL_ENTITY_ID,
             l_transaction_header_rec.LEDGER_ID,
             l_transaction_header_rec.APPLICATION_ID,
             l_transaction_header_rec.ENTITY_CODE,
             l_transaction_header_rec.EVENT_CLASS_CODE,
             l_transaction_header_rec.EVENT_TYPE_CODE,
             l_transaction_header_rec.CTRL_TOTAL_HDR_TX_AMT,
             l_transaction_header_rec.TRX_ID,
             l_transaction_header_rec.TRX_DATE,
             l_transaction_header_rec.REL_DOC_DATE,
             l_transaction_header_rec.PROVNL_TAX_DETERMINATION_DATE,
             l_transaction_header_rec.TRX_CURRENCY_CODE,
             l_transaction_header_rec.PRECISION,
             l_transaction_header_rec.CURRENCY_CONVERSION_TYPE,
             l_transaction_header_rec.CURRENCY_CONVERSION_RATE,
             l_transaction_header_rec.CURRENCY_CONVERSION_DATE,
             l_transaction_header_rec.ROUNDING_SHIP_TO_PARTY_ID,
             l_transaction_header_rec.ROUNDING_SHIP_FROM_PARTY_ID,
             l_transaction_header_rec.ROUNDING_BILL_TO_PARTY_ID,
             l_transaction_header_rec.ROUNDING_BILL_FROM_PARTY_ID,
             l_transaction_header_rec.RNDG_SHIP_TO_PARTY_SITE_ID,
             l_transaction_header_rec.RNDG_SHIP_FROM_PARTY_SITE_ID,
             l_transaction_header_rec.RNDG_BILL_TO_PARTY_SITE_ID,
             l_transaction_header_rec.RNDG_BILL_FROM_PARTY_SITE_ID,
             l_transaction_header_rec.QUOTE_FLAG,
             l_transaction_header_rec.ESTABLISHMENT_ID
       LIMIT G_LINES_PER_FETCH;

       FOR l_index IN 1..nvl(l_transaction_header_rec.application_id.LAST,0)
       LOOP
         BEGIN
           SAVEPOINT Get_Def_Tax_Det_Attrs_Doc_PVT;
           l_event_class_rec.INTERNAL_ORGANIZATION_ID     :=  l_transaction_header_rec.INTERNAL_ORGANIZATION_ID(l_index);
           l_event_class_rec.LEGAL_ENTITY_ID              :=  l_transaction_header_rec.LEGAL_ENTITY_ID(l_index);
           l_event_class_rec.LEDGER_ID                    :=  l_transaction_header_rec.LEDGER_ID(l_index);
           l_event_class_rec.APPLICATION_ID               :=  l_transaction_header_rec.APPLICATION_ID(l_index);
           l_event_class_rec.ENTITY_CODE                  :=  l_transaction_header_rec.ENTITY_CODE(l_index);
           l_event_class_rec.EVENT_CLASS_CODE             :=  l_transaction_header_rec.EVENT_CLASS_CODE(l_index);
           l_event_class_rec.EVENT_TYPE_CODE              :=  l_transaction_header_rec.EVENT_TYPE_CODE(l_index);
           l_event_class_rec.CTRL_TOTAL_HDR_TX_AMT        :=  l_transaction_header_rec.CTRL_TOTAL_HDR_TX_AMT(l_index);
           l_event_class_rec.TRX_ID                       :=  l_transaction_header_rec.TRX_ID(l_index);
           l_event_class_rec.TRX_DATE                     :=  l_transaction_header_rec.TRX_DATE(l_index);
           l_event_class_rec.REL_DOC_DATE                 :=  l_transaction_header_rec.REL_DOC_DATE(l_index);
           l_event_class_rec.PROVNL_TAX_DETERMINATION_DATE:=  l_transaction_header_rec.PROVNL_TAX_DETERMINATION_DATE(l_index);
           l_event_class_rec.TRX_CURRENCY_CODE            :=  l_transaction_header_rec.TRX_CURRENCY_CODE(l_index);
           l_event_class_rec.PRECISION                    :=  l_transaction_header_rec.PRECISION(l_index);
           l_event_class_rec.CURRENCY_CONVERSION_TYPE     :=  l_transaction_header_rec.CURRENCY_CONVERSION_TYPE(l_index);
           l_event_class_rec.CURRENCY_CONVERSION_RATE     :=  l_transaction_header_rec.CURRENCY_CONVERSION_RATE(l_index);
           l_event_class_rec.CURRENCY_CONVERSION_DATE     :=  l_transaction_header_rec.CURRENCY_CONVERSION_DATE(l_index);
           l_event_class_rec.ROUNDING_SHIP_TO_PARTY_ID    :=  l_transaction_header_rec.ROUNDING_SHIP_TO_PARTY_ID(l_index);
           l_event_class_rec.ROUNDING_SHIP_FROM_PARTY_ID  :=  l_transaction_header_rec.ROUNDING_SHIP_FROM_PARTY_ID(l_index);
           l_event_class_rec.ROUNDING_BILL_TO_PARTY_ID    :=  l_transaction_header_rec.ROUNDING_BILL_TO_PARTY_ID(l_index);
           l_event_class_rec.ROUNDING_BILL_FROM_PARTY_ID  :=  l_transaction_header_rec.ROUNDING_BILL_FROM_PARTY_ID(l_index);
           l_event_class_rec.RNDG_SHIP_TO_PARTY_SITE_ID   :=  l_transaction_header_rec.RNDG_SHIP_TO_PARTY_SITE_ID(l_index);
           l_event_class_rec.RNDG_SHIP_FROM_PARTY_SITE_ID :=  l_transaction_header_rec.RNDG_SHIP_FROM_PARTY_SITE_ID(l_index);
           l_event_class_rec.RNDG_BILL_TO_PARTY_SITE_ID   :=  l_transaction_header_rec.RNDG_BILL_TO_PARTY_SITE_ID(l_index);
           l_event_class_rec.RNDG_BILL_FROM_PARTY_SITE_ID :=  l_transaction_header_rec.RNDG_BILL_FROM_PARTY_SITE_ID(l_index);
           l_event_class_rec.QUOTE_FLAG                   :=  nvl(l_transaction_header_rec.QUOTE_FLAG(l_index),'N');

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               'application_id: '||to_char(l_event_class_rec.application_id)||
               ', entity_code: '||l_event_class_rec.entity_code||
               ', event_class_code: '||l_event_class_rec.event_class_code||
               ', event_type_code: '||l_event_class_rec.event_type_code||
               ', trx_id: '||to_char(l_event_class_rec.trx_id)||
               ', internal_organization_id: '||to_char(l_event_class_rec.internal_organization_id)||
               ', ledger_id: '||to_char(l_event_class_rec.ledger_id)||
               ', legal_entity_id: '||to_char(l_event_class_rec.legal_entity_id)||
               ', trx_date: '||to_char(l_event_class_rec.trx_date)||
               ', related_document_date: '||to_char(l_event_class_rec.rel_doc_date)||
               ', provnl_tax_determination_date: '||to_char(l_event_class_rec.provnl_tax_determination_date)||
               ', trx_currency_code: '||l_event_class_rec.trx_currency_code||
               ', currency_conversion_type: '||l_event_class_rec.currency_conversion_type||
               ', currency_conversion_rate: '||to_char(l_event_class_rec.currency_conversion_rate)||
               ', currency_conversion_date: '||to_char(l_event_class_rec.currency_conversion_date)||
               ', rounding_ship_to_party_id: '||to_char(l_event_class_rec.rounding_ship_to_party_id)||
               ', rounding_ship_from_party_id: '||to_char(l_event_class_rec.rounding_ship_from_party_id)||
               ', rounding_bill_to_party_id: '||to_char(l_event_class_rec.rounding_bill_to_party_id)||
               ', rounding_bill_from_party_id: '||to_char(l_event_class_rec.rounding_bill_from_party_id)||
               ', rndg_ship_to_party_site_id: '||to_char(l_event_class_rec.rndg_ship_to_party_site_id)||
               ', rndg_ship_from_party_site_id: '||to_char(l_event_class_rec.rndg_ship_from_party_site_id)||
               ', rndg_bill_to_party_site_id: '||to_char(l_event_class_rec.rndg_bill_to_party_site_id)||
               ', rndg_bill_from_party_site_id: '||to_char(l_event_class_rec.rndg_bill_from_party_site_id));
           END IF;

          /*------------------------------------------------------+
           |   Validate and Initializate parameters for Calculate |
           |   tax                                                |
           +------------------------------------------------------*/
           ZX_VALID_INIT_PARAMS_PKG.get_default_tax_det_attrs(p_event_class_rec => l_event_class_rec,
                                                              x_return_status   => l_return_status
                                                             );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
                ':ZX_VALID_INIT_PARAMS_PKG.get_default_tax_det_attrs returned errors');
             END IF;
             IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
           END IF;

          /*------------------------------------------------------+
           |   Call the redefaulting APIs                         |
           +------------------------------------------------------*/
           ZX_SRVC_TYP_PKG.get_default_tax_det_attrs(p_event_class_rec => l_event_class_rec,
                                                     x_return_status   => l_return_status
                                                    );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
                ':ZX_SRVC_TYP_PKG.get_default_tax_det_attrs returned errors');
             END IF;
             IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
           END IF;

           --Delete from the global structure for every loop on header
           --so that there are no hanging/redundant records sitting there
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               'Calling routine to delete the global structures ');
           END IF;
           ZX_GLOBAL_STRUCTURES_PKG.delete_trx_line_dist_tbl;

           EXCEPTION
             WHEN FND_API.G_EXC_ERROR THEN
               ROLLBACK TO Get_Def_Tax_Det_Attrs_Doc_PVT;
               x_return_status := FND_API.G_RET_STS_ERROR ;
	             --Call API to dump into zx_errors_gt
               DUMP_MSG;
               IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
               END IF;
         END;
       END LOOP;--for headers_doc
       EXIT WHEN headers_doc%NOTFOUND;
    END LOOP;
    CLOSE headers_doc;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
    END IF;

    EXCEPTION
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Get_Default_Tax_Det_Attrs_PVT;
            --Close all open cursors
            IF headers_doc%ISOPEN THEN CLOSE headers_doc; END IF;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            DUMP_MSG;
            FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
            FND_MSG_PUB.Add;
           /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count   =>      x_msg_count,
                                      p_data    =>      x_msg_data
                                      );
            IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
            END IF;

          WHEN OTHERS THEN
             ROLLBACK TO Get_Default_Tax_Det_Attrs_PVT;
             --Close all open cursors
             IF headers_doc%ISOPEN THEN CLOSE headers_doc; END IF;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
             FND_MSG_PUB.Add;
            /*---------------------------------------------------------+
             | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
             | in the message stack. If there is only one message in   |
             | the stack it retrieves this message                     |
             +---------------------------------------------------------*/
             IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
             END IF;
 END get_default_tax_det_attribs;

/* ======================================================================*
 | PROCEDURE redefault_intended_use: Redefault intended use              |
 * ======================================================================*/

 PROCEDURE redefault_intended_use(
  p_api_version          IN            NUMBER,
  p_init_msg_list        IN            VARCHAR2,
  p_commit               IN            VARCHAR2,
  p_validation_level     IN            NUMBER,
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_count            OUT NOCOPY    NUMBER ,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_application_id       IN            NUMBER,
  p_entity_code          IN            VARCHAR2,
  p_event_class_code     IN            VARCHAR2,
  p_internal_org_id      IN            NUMBER,
  p_country_code         IN            VARCHAR2,
  p_item_id              IN            NUMBER,
  p_item_org_id          IN            NUMBER,
  x_intended_use         OUT NOCOPY    VARCHAR2
  )IS
  l_api_name                  CONSTANT  VARCHAR2(30) := 'REDEFAULT_INTENDED_USE';
  l_api_version               CONSTANT  NUMBER := 1.0;
  l_return_status             VARCHAR2(1);
  l_init_msg_list             VARCHAR2(1);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Redefault_Intended_Use_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
       l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

    /*-----------------------------------------+
     |   Initialize return status to SUCCESS   |
     +-----------------------------------------*/
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*-----------------------------------------+
     |   Populate Global Variable              |
     +-----------------------------------------*/
     G_PUB_SRVC := l_api_name;
     G_DATA_TRANSFER_MODE := 'PLS';
     G_EXTERNAL_API_CALL  := 'N';

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
       'application_id: ' || to_char(p_application_id)||
       ', entity_code: ' || p_entity_code||
       ', event_class_code: ' || p_event_class_code||
       ', country_code: ' || p_country_code||
       ', org_id: ' || to_char(p_internal_org_id)||
       ', product_id: ' || to_char(p_item_id)||
       ', product_org_id: ' || to_char(p_item_org_id));
     END IF;

     ZX_DEFAULT_AUTOMATION_PKG.redefault_intended_use(p_application_id,
                                                      p_entity_code,
                                                      p_event_class_code,
                                                      p_internal_org_id,
                                                      p_country_code,
                                                      p_item_id,
                                                      p_item_org_id,
                                                      x_intended_use,
                                                      x_return_status
                                                      );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
           ':ZX_DEFAULT_AUTOMATION_PKG.redefault_intended_use returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     ELSE
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
           ':Intended Use :' || x_intended_use);
       END IF;
     END IF;

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
     END IF;

     EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Redefault_Intended_Use_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            DUMP_MSG;
           /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count   =>      x_msg_count,
                                      p_data    =>      x_msg_data
                                      );
            IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
            END IF;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Redefault_Intended_Use_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            DUMP_MSG;
            FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
            FND_MSG_PUB.Add;
           /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count   =>      x_msg_count,
                                      p_data    =>      x_msg_data
                                      );
            IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
            END IF;

          WHEN OTHERS THEN
             ROLLBACK TO Redefault_Intended_Use_PVT;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
             FND_MSG_PUB.Add;
            /*---------------------------------------------------------+
             | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
             | in the message stack. If there is only one message in   |
             | the stack it retrieves this message                     |
             +---------------------------------------------------------*/
             FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                       p_count  =>      x_msg_count,
                                       p_data   =>      x_msg_data
                                      );
             IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
             END IF;
 END redefault_intended_use;

/* ======================================================================*
 | PROCEDURE redefault_prod_fisc_class_code: Redefault product fiscal    |
 |                                           classification              |
 * ======================================================================*/
 PROCEDURE redefault_prod_fisc_class_code(
  p_api_version          IN            NUMBER,
  p_init_msg_list        IN            VARCHAR2,
  p_commit               IN            VARCHAR2,
  p_validation_level     IN            NUMBER,
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_count            OUT NOCOPY    NUMBER ,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_application_id       IN            NUMBER,
  p_entity_code          IN            VARCHAR2,
  p_event_class_code     IN            VARCHAR2,
  p_internal_org_id      IN            NUMBER,
  p_country_code         IN            VARCHAR2,
  p_item_id              IN            NUMBER,
  p_item_org_id          IN            NUMBER,
  x_prod_fisc_class_code OUT NOCOPY    VARCHAR2
  )IS
  l_api_name                  CONSTANT  VARCHAR2(30) := 'REDEFAULT_PROD_FISC_CLASS_CODE';
  l_api_version               CONSTANT  NUMBER := 1.0;
  l_return_status             VARCHAR2(1);
  l_init_msg_list             VARCHAR2(1);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Redef_Prod_Fisc_Class_Code_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
       l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

    /*-----------------------------------------+
     |   Initialize return status to SUCCESS   |
     +-----------------------------------------*/
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*-----------------------------------------+
     |   Populate Global Variable              |
     +-----------------------------------------*/
     G_PUB_SRVC := l_api_name;
     G_DATA_TRANSFER_MODE := 'PLS';
     G_EXTERNAL_API_CALL  := 'N';

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
       'application_id: ' || to_char(p_application_id)||
       ', entity_code: ' || p_entity_code||
       ', event_class_code: ' || p_event_class_code||
       ', country_code: ' || p_country_code||
       ', org_id: ' || to_char(p_internal_org_id)||
       ', product_id: ' || to_char(p_item_id)||
       ', product_org_id: ' || to_char(p_item_org_id));
     END IF;

     ZX_DEFAULT_AUTOMATION_PKG.redefault_prod_fisc_class_code(p_application_id,
                                                              p_entity_code,
                                                              p_event_class_code,
                                                              p_internal_org_id,
                                                              p_country_code,
                                                              p_item_id,
                                                              p_item_org_id,
                                                              x_prod_fisc_class_code,
                                                              x_return_status
                                                              );
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
           ':ZX_DEFAULT_AUTOMATION_PKG.redefault_prod_fisc_class_code returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     ELSE
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
           ':Product Fiscal Classification Code :' || x_prod_fisc_class_code);
       END IF;
     END IF;

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
     END IF;

     EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Redef_Prod_Fisc_Class_Code_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            DUMP_MSG;
            /*---------------------------------------------------------+
             | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
             | in the message stack. If there is only one message in   |
             | the stack it retrieves this message                     |
             +---------------------------------------------------------*/
             FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                       p_count  =>      x_msg_count,
                                       p_data   =>      x_msg_data
                                       );

            IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
            END IF;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Redef_Prod_Fisc_Class_Code_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            DUMP_MSG;
            FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
            FND_MSG_PUB.Add;
           /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count   =>      x_msg_count,
                                      p_data    =>      x_msg_data
                                      );
            IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
            END IF;

          WHEN OTHERS THEN
             ROLLBACK TO Redef_Prod_Fisc_Class_Code_PVT;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
             FND_MSG_PUB.Add;
            /*---------------------------------------------------------+
             | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
             | in the message stack. If there is only one message in   |
             | the stack it retrieves this message                     |
             +---------------------------------------------------------*/
             FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                       p_count  =>      x_msg_count,
                                       p_data   =>      x_msg_data
                                       );
             IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
             END IF;
 END redefault_prod_fisc_class_code;


/* ======================================================================*
 | PROCEDURE redefault_assessable_value: Redefault assessable value      |
 * ======================================================================*/

 PROCEDURE redefault_assessable_value(
  p_api_version          IN            NUMBER,
  p_init_msg_list        IN            VARCHAR2,
  p_commit               IN            VARCHAR2,
  p_validation_level     IN            NUMBER,
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_count            OUT NOCOPY    NUMBER ,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_application_id       IN            NUMBER,
  p_entity_code          IN            VARCHAR2,
  p_event_class_code     IN            VARCHAR2,
  p_internal_org_id      IN            NUMBER,
  p_trx_id               IN            NUMBER,
  p_trx_line_id          IN            NUMBER,
  p_trx_level_type       IN            VARCHAR2,
  p_item_id              IN            NUMBER,
  p_item_org_id          IN            NUMBER,
  p_line_amt             IN            NUMBER,
  x_assessable_value     OUT NOCOPY    NUMBER
  )IS
  l_api_name                  CONSTANT  VARCHAR2(30) := 'REDEFAULT_ASSESSABLE_VALUE';
  l_api_version               CONSTANT  NUMBER := 1.0;
  l_return_status             VARCHAR2(1);
  l_init_msg_list             VARCHAR2(1);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Redefault_Assessable_Value_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
       l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

    /*-----------------------------------------+
     |   Initialize return status to SUCCESS   |
     +-----------------------------------------*/
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*-----------------------------------------+
     |   Populate Global Variable              |
     +-----------------------------------------*/
     G_PUB_SRVC := l_api_name;
     G_DATA_TRANSFER_MODE := 'PLS';
     G_EXTERNAL_API_CALL  := 'N';

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
       'application_id: ' || to_char(p_application_id)||
       ', entity_code: ' || p_entity_code||
       ', event_class_code: ' || p_event_class_code||
       ', org_id: ' || to_char(p_internal_org_id)||
       ', product_id: ' || to_char(p_item_id)||
       ', product_org_id: ' || to_char(p_item_org_id)||
       ', trx_id: ' || to_char(p_trx_id)||
       ', trx_line_id: ' || to_char(p_trx_line_id)||
       ', trx_level_type: ' || to_char(p_trx_level_type)||
       ', line_amount: ' || to_char(p_line_amt));
     END IF;

     ZX_DEFAULT_AUTOMATION_PKG.redefault_assessable_value(p_application_id,
                                                          p_entity_code,
                                                          p_event_class_code,
                                                          p_internal_org_id,
                                                          p_trx_id,
                                                          p_trx_line_id,
                                                          p_trx_level_type,
                                                          p_item_id,
                                                          p_item_org_id,
                                                          p_line_amt,
                                                          x_assessable_value,
                                                          x_return_status
                                                          );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
           ':ZX_DEFAULT_AUTOMATION_PKG.redefault_assessable_value returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     ELSE
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
           'Reassessable Value :' || to_char(x_assessable_value));
       END IF;
     END IF;

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
     END IF;

     EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Redefault_Assessable_Value_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            DUMP_MSG;
           /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count   =>      x_msg_count,
                                      p_data    =>      x_msg_data
                                      );
            IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
            END IF;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Redefault_Assessable_Value_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            DUMP_MSG;
            FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
            FND_MSG_PUB.Add;
           /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count   =>      x_msg_count,
                                      p_data    =>      x_msg_data
                                      );
            IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
            END IF;

          WHEN OTHERS THEN
             ROLLBACK TO Redefault_Assessable_Value_PVT;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
             FND_MSG_PUB.Add;
           /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                       p_count  =>      x_msg_count,
                                       p_data   =>      x_msg_data
                                      );
             IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
             END IF;
 END redefault_assessable_value;

/* ======================================================================*
 | PROCEDURE redefault_product_type: Redefault product type              |
 * ======================================================================*/

 PROCEDURE redefault_product_type(
  p_api_version          IN            NUMBER,
  p_init_msg_list        IN            VARCHAR2,
  p_commit               IN            VARCHAR2,
  p_validation_level     IN            NUMBER,
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_count            OUT NOCOPY    NUMBER ,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_application_id       IN            NUMBER,
  p_entity_code          IN            VARCHAR2,
  p_event_class_code     IN            VARCHAR2,
  p_country_code         IN            VARCHAR2,
  p_item_id              IN            NUMBER,
  p_org_id               IN            NUMBER,
  x_product_type         OUT NOCOPY    VARCHAR2
  )IS
  l_api_name                  CONSTANT  VARCHAR2(30) := 'REDEFAULT_ASSESSABLE_VALUE';
  l_api_version               CONSTANT  NUMBER := 1.0;
  l_return_status             VARCHAR2(1);
  l_init_msg_list             VARCHAR2(1);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Redefault_Assessable_Value_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
       l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

    /*-----------------------------------------+
     |   Initialize return status to SUCCESS   |
     +-----------------------------------------*/
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*-----------------------------------------+
     |   Populate Global Variable              |
     +-----------------------------------------*/
     G_PUB_SRVC := l_api_name;
     G_DATA_TRANSFER_MODE := 'PLS';
     G_EXTERNAL_API_CALL  := 'N';


     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
       'application_id: ' || to_char(p_application_id)||
       ', entity_code: ' || p_entity_code||
       ', event_class_code: ' || p_event_class_code||
       ', country_code: ' || p_country_code||
       ', org_id: ' || to_char(p_org_id)||
       ', product_id: ' || to_char(p_item_id));
     END IF;

     ZX_TCM_EXT_SERVICES_PUB.get_default_classif_code(p_fiscal_type_code  =>  'PRODUCT_TYPE',
                                                      p_country_code      =>  p_country_code,
                                                      p_application_id    =>  p_application_id,
                                                      p_entity_code       =>  p_entity_code,
                                                      p_event_class_code  =>  p_event_class_code,
                                                      p_source_event_class_code  =>  null,
                                                      p_item_id           =>  p_item_id,
                                                      p_org_id            =>  p_org_id,
                                                      p_default_code      =>  x_product_type ,
                                                      p_return_status     =>  l_return_status
                                                      );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
           ':ZX_DEFAULT_AUTOMATION_PKG.redefault_assessable_value returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     ELSE
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
           'Product Type :' || x_product_type);
       END IF;
     END IF;

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
     END IF;

     EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Redefault_Assessable_Value_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            DUMP_MSG;
           /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count   =>      x_msg_count,
                                      p_data    =>      x_msg_data
                                      );
            IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
            END IF;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Redefault_Assessable_Value_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            DUMP_MSG;
            FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
            FND_MSG_PUB.Add;
           /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count   =>      x_msg_count,
                                      p_data    =>      x_msg_data
                                      );
            IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
            END IF;

          WHEN OTHERS THEN
             ROLLBACK TO Redefault_Assessable_Value_PVT;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
             FND_MSG_PUB.Add;
           /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                       p_count  =>      x_msg_count,
                                       p_data   =>      x_msg_data
                                      );
             IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
             END IF;
 END redefault_product_type;
 /* ======================================================================*
 | PROCEDURE redef_tax_classification_code: ReDefault tax classification  |
 * ======================================================================*/
 PROCEDURE redef_tax_classification_code(
  p_api_version                  IN               NUMBER,
  p_init_msg_list                IN               VARCHAR2,
  p_commit                       IN               VARCHAR2,
  p_validation_level             IN               NUMBER,
  x_msg_count                    OUT    NOCOPY    NUMBER ,
  x_msg_data                     OUT    NOCOPY    VARCHAR2,
  x_return_status                OUT    NOCOPY    VARCHAR2,
  p_redef_tax_cls_code_info_rec  IN OUT NOCOPY    def_tax_cls_code_info_rec_type
  ) IS
  l_api_name                  CONSTANT  VARCHAR2(30) := 'REDEF_TAX_CLASSIFICATION_CODE';
  l_api_version               CONSTANT  NUMBER := 1.0;
  l_return_status             VARCHAR2(1);
  l_init_msg_list             VARCHAR2(1);
  l_error_buffer              VARCHAR2(1000);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Redef_Tax_Class_Code_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
       l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

    /*-----------------------------------------+
     |   Initialize return status to SUCCESS   |
     +-----------------------------------------*/
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*-----------------------------------------+
     |   Populate Global Variable              |
     +-----------------------------------------*/
     G_PUB_SRVC := l_api_name;
     G_DATA_TRANSFER_MODE := 'PLS';
     G_EXTERNAL_API_CALL  := 'N';


     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
       'application_id: ' || to_char(p_redef_tax_cls_code_info_rec.application_id)||
       ', entity_code: ' || p_redef_tax_cls_code_info_rec.entity_code||
       ', event_class_code: ' || p_redef_tax_cls_code_info_rec.event_class_code||
       ', org_id: ' || to_char(p_redef_tax_cls_code_info_rec.internal_organization_id)||
       ', product_id: ' || to_char(p_redef_tax_cls_code_info_rec.product_id)||
       ', product_org_id: ' || to_char(p_redef_tax_cls_code_info_rec.product_org_id)||
       ', trx_date: ' || to_char(p_redef_tax_cls_code_info_rec.trx_date)||
       ', trx_id: ' || to_char(p_redef_tax_cls_code_info_rec.trx_id)||
       ', trx_line_id: ' || to_char(p_redef_tax_cls_code_info_rec.trx_line_id)||
       ', trx_level_type: ' || p_redef_tax_cls_code_info_rec.trx_level_type||
       ', trx_date: ' || to_char(p_redef_tax_cls_code_info_rec.trx_date)||
       ', ledger_id: ' || to_char(p_redef_tax_cls_code_info_rec.ledger_id)||
       ', ship_third_pty_acct_id: ' || to_char(p_redef_tax_cls_code_info_rec.ship_third_pty_acct_id)||
       ', ship_third_pty_acct_site_id: ' || to_char(p_redef_tax_cls_code_info_rec.ship_third_pty_acct_site_id)||
       ', bill_third_pty_acct_id: ' || to_char(p_redef_tax_cls_code_info_rec.bill_third_pty_acct_id)||
       ', bill_third_pty_acct_site_id: ' || to_char(p_redef_tax_cls_code_info_rec.bill_third_pty_acct_site_id)||
       ', ship_to_cust_acct_site_use_id: ' || to_char(p_redef_tax_cls_code_info_rec.ship_to_cust_acct_site_use_id)||
       ', bill_to_cust_acct_site_use_id: ' || to_char(p_redef_tax_cls_code_info_rec.bill_to_cust_acct_site_use_id)||
       ', ship_to_location_id: ' || to_char(p_redef_tax_cls_code_info_rec.ship_to_location_id)||
       ', account_ccid: ' || to_char(p_redef_tax_cls_code_info_rec.account_ccid)||
       ', account_string: ' || p_redef_tax_cls_code_info_rec.account_string||
       ', ref_doc_application_id: ' || to_char(p_redef_tax_cls_code_info_rec.application_id)||
       ', ref_doc_entity_code: ' || p_redef_tax_cls_code_info_rec.ref_doc_entity_code||
       ', ref_doc_event_class_code: ' || p_redef_tax_cls_code_info_rec.ref_doc_event_class_code||
       ', ref_doc_trx_id: ' || to_char(p_redef_tax_cls_code_info_rec.ref_doc_trx_id)||
       ', ref_doc_line_id: ' || to_char(p_redef_tax_cls_code_info_rec.ref_doc_line_id)||
       ', ref_doc_trx_level_type: ' || p_redef_tax_cls_code_info_rec.ref_doc_trx_level_type||
       ', tax_user_override_flag: ' || p_redef_tax_cls_code_info_rec.tax_user_override_flag||
       ', overridden_tax_cls_code : ' || p_redef_tax_cls_code_info_rec.overridden_tax_cls_code ||
       ', defaulting_attribute10: ' || p_redef_tax_cls_code_info_rec.defaulting_attribute10||
       ', defaulting_attribute1: ' || p_redef_tax_cls_code_info_rec.defaulting_attribute1||
       ', defaulting_attribute2: ' || p_redef_tax_cls_code_info_rec.defaulting_attribute2||
       ', defaulting_attribute3: ' || p_redef_tax_cls_code_info_rec.defaulting_attribute3||
       ', defaulting_attribute4: ' || p_redef_tax_cls_code_info_rec.defaulting_attribute4||
       ', defaulting_attribute5: ' || p_redef_tax_cls_code_info_rec.defaulting_attribute5||
       ', defaulting_attribute6: ' || p_redef_tax_cls_code_info_rec.defaulting_attribute6||
       ', defaulting_attribute7: ' || p_redef_tax_cls_code_info_rec.defaulting_attribute7||
       ', defaulting_attribute8: ' || p_redef_tax_cls_code_info_rec.defaulting_attribute8||
       ', defaulting_attribute9: ' || p_redef_tax_cls_code_info_rec.defaulting_attribute9||
       ', defaulting_attribute10: ' || p_redef_tax_cls_code_info_rec.defaulting_attribute10);
     END IF;


    /*-------------------------------------------------+
     |   Call TDM API to default the tax classification|
     +-------------------------------------------------*/
     ZX_TAX_DEFAULT_PKG.get_default_tax_classification (p_definfo            =>  p_redef_tax_cls_code_info_rec,
                                                        p_return_status      =>  l_return_status,
                                                        p_error_buffer       =>  l_error_buffer
                                                        );
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
           ':ZX_TAX_DEFAULT_PKG.get_default_tax_classification returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     ELSE
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
         'Tax Classification: ' || p_redef_tax_cls_code_info_rec.x_tax_classification_code
         );
       END IF;
     END IF;

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
     END IF;

     EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Redef_Tax_Class_Code_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            DUMP_MSG;
           /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count   =>      x_msg_count,
                                      p_data    =>      x_msg_data
                                      );
            IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
            END IF;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Redef_Tax_Class_Code_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            DUMP_MSG;
            FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
            FND_MSG_PUB.Add;
           /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count   =>      x_msg_count,
                                      p_data    =>      x_msg_data
                                      );
            IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
            END IF;

          WHEN OTHERS THEN
             ROLLBACK TO Redef_Tax_Class_Code_PVT;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
             FND_MSG_PUB.Add;
            /*---------------------------------------------------------+
             | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
             | in the message stack. If there is only one message in   |
             | the stack it retrieves this message                     |
             +---------------------------------------------------------*/
             FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                       p_count  =>      x_msg_count,
                                       p_data   =>      x_msg_data
                                       );
             IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
             END IF;
 END redef_tax_classification_code;

/* =========================================================================*
 | PROCEDURE purge_tax_repository: Purges the transaction lines and tax data|
 | GTT : ZX_PURGE_TRANSACTIONS_GT                                           |
 * ========================================================================*/
 PROCEDURE purge_tax_repository(
  p_api_version                  IN               NUMBER,
  p_init_msg_list                IN               VARCHAR2,
  p_commit                       IN               VARCHAR2,
  p_validation_level             IN               NUMBER,
  x_msg_count                    OUT    NOCOPY    NUMBER ,
  x_msg_data                     OUT    NOCOPY    VARCHAR2,
  x_return_status                OUT    NOCOPY    VARCHAR2
  )IS
  l_api_name                  CONSTANT  VARCHAR2(30) := 'PURGE_TAX_REPOSITORY';
  l_api_version               CONSTANT  NUMBER := 1.0;
  l_init_msg_list             VARCHAR2(1);
  l_summarization_flag        VARCHAR2(1);
  l_tax_recovery_flag         VARCHAR2(1);
  l_tax_reporting_flag        VARCHAR2(1);
  l_row_count                 NUMBER;
  l_context_info_rec          context_info_rec_type;
  l_application_id            NUMBER;
  l_entity_code               VARCHAR2(30);
  l_event_class_code          VARCHAR2(30);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Purge_Tax_Repository_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
       l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

    /*-----------------------------------------+
     |   Initialize return status to SUCCESS   |
     +-----------------------------------------*/
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*-----------------------------------------+
     |   Populate Global Variable              |
     +------ -----------------------------------*/
     G_PUB_SRVC := l_api_name;
     G_DATA_TRANSFER_MODE := 'TAB';
     G_EXTERNAL_API_CALL  := 'N';

    SELECT application_id,
           entity_code,
           event_class_code
      INTO l_application_id,
           l_entity_code,
           l_event_class_code
      FROM ZX_PURGE_TRANSACTIONS_GT
     WHERE rownum=1;

    IF l_event_class_code = 'SALES_TRANSACTION_TAX_QUOTE' THEN
        SELECT summarization_flag,
               tax_reporting_flag,
               tax_recovery_flag
          INTO l_summarization_flag,
               l_tax_reporting_flag,
               l_tax_recovery_flag
          FROM ZX_EVNT_CLS_MAPPINGS
         WHERE APPLICATION_ID    = 222
           AND ENTITY_CODE       = 'TRANSACTIONS'
           AND EVENT_CLASS_CODE  = 'INVOICE';
     ELSIF l_event_class_code = 'PURCHASE_TRANSACTION_TAX_QUOTE' THEN
       SELECT summarization_flag,
              tax_reporting_flag,
              tax_recovery_flag
         INTO l_summarization_flag,
              l_tax_reporting_flag,
              l_tax_recovery_flag
         FROM ZX_EVNT_CLS_MAPPINGS
        WHERE APPLICATION_ID    = 200
          AND ENTITY_CODE       = 'AP_INVOICES'
          AND EVENT_CLASS_CODE  = 'STANDARD INVOICE';
     ELSE
       SELECT summarization_flag,
              tax_reporting_flag,
              tax_recovery_flag
         INTO l_summarization_flag,
              l_tax_reporting_flag,
              l_tax_recovery_flag
         FROM ZX_EVNT_CLS_MAPPINGS
        WHERE APPLICATION_ID    = l_application_id
          AND ENTITY_CODE       = l_entity_code
          AND EVENT_CLASS_CODE  = l_event_class_code;
     END IF;

     --PO does not report taxes so go ahead and delete the tax repository
     IF l_tax_reporting_flag = 'N' THEN
        DELETE
        FROM ZX_LINES tax
       WHERE (APPLICATION_ID, ENTITY_CODE,EVENT_CLASS_CODE, TRX_ID)
          IN (SELECT  /*+ INDEX (ZX_PURGE_TRANSACTIONS_GT ZX_PURGE_TRANSACTIONS_GT_U1)*/
                   APPLICATION_ID,
                   ENTITY_CODE,
                   EVENT_CLASS_CODE,
                   TRX_ID
              FROM ZX_PURGE_TRANSACTIONS_GT purge);

       IF SQL%FOUND THEN
         l_row_count := SQL%ROWCOUNT;
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name ,
                          'Number of rows deleted from ZX_LINES = '|| to_char(l_row_count));
         END IF;
       END IF;

       IF l_summarization_flag = 'Y' THEN
          DELETE
          FROM ZX_LINES_SUMMARY summ
         WHERE (APPLICATION_ID, ENTITY_CODE,EVENT_CLASS_CODE,TRX_ID)
            IN (SELECT  /*+ INDEX (ZX_PURGE_TRANSACTIONS_GT ZX_PURGE_TRANSACTIONS_GT_U1)*/
                     APPLICATION_ID,
                     ENTITY_CODE,
                     EVENT_CLASS_CODE,
                     TRX_ID
                FROM ZX_PURGE_TRANSACTIONS_GT purge);

         IF SQL%FOUND THEN
           l_row_count := SQL%ROWCOUNT;
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name ,
                            'Number of rows deleted from ZX_LINES_SUMMARY = '||to_char(l_row_count));
           END IF;
         END IF;
       END IF; --summarization_flag is Y

       IF l_tax_recovery_flag ='Y' THEN
         DELETE
          FROM ZX_REC_NREC_DIST dist
         WHERE (APPLICATION_ID, ENTITY_CODE,EVENT_CLASS_CODE,TRX_ID)
            IN (SELECT  /*+ INDEX (ZX_PURGE_TRANSACTIONS_GT ZX_PURGE_TRANSACTIONS_GT_U1)*/
                     APPLICATION_ID,
                     ENTITY_CODE,
                     EVENT_CLASS_CODE,
                     TRX_ID
                FROM ZX_PURGE_TRANSACTIONS_GT purge);


         IF SQL%FOUND THEN
           l_row_count := SQL%ROWCOUNT;
           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name ,
                            'Number of rows deleted from ZX_REC_NREC_DIST = '||to_char(l_row_count));
           END IF;
         END IF;
       END IF; --tax recovery is Y

       DELETE
        FROM ZX_LINES_DET_FACTORS lines
       WHERE (APPLICATION_ID, ENTITY_CODE,EVENT_CLASS_CODE, TRX_ID)
          IN (SELECT  /*+ INDEX (ZX_PURGE_TRANSACTIONS_GT ZX_PURGE_TRANSACTIONS_GT_U1)*/
                   APPLICATION_ID,
                   ENTITY_CODE,
                   EVENT_CLASS_CODE,
                   TRX_ID
              FROM ZX_PURGE_TRANSACTIONS_GT purge);

       IF SQL%FOUND THEN
         l_row_count := SQL%ROWCOUNT;
         IF (G_LEVEL_PROCEDURE >= g_current_runtime_level ) THEN
           FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name ,
                          'Number of rows deleted from ZX_LINES_DET_FACTORS = '||to_char(l_row_count));
         END IF;
       END IF;
     --ELSIF tax_reporting_flag = 'Y' --AR/AP cases wherein we need to purge only if tax lines are frozen --TBD on requirement basis
     END IF; --tax reporting flag is N


     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
     END IF;

     EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Purge_Tax_Repository_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            --Call API to dump into zx_errors_gt
            DUMP_MSG;
            IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
            END IF;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Purge_Tax_Repository_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            DUMP_MSG;
            FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
            FND_MSG_PUB.Add;
           /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count   =>      x_msg_count,
                                      p_data    =>      x_msg_data
                                      );
            IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
            END IF;

          WHEN OTHERS THEN
             ROLLBACK TO Purge_Tax_Repository_PVT;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
             FND_MSG_PUB.Add;
            /*---------------------------------------------------------+
             | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
             | in the message stack. If there is only one message in   |
             | the stack it retrieves this message                     |
             +---------------------------------------------------------*/
             FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count   =>      x_msg_count,
                                      p_data    =>      x_msg_data
                                      );
             IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
             END IF;

 END purge_tax_repository;

/* ======================================================================*
 | API TO GET  LE FOR AP IMPORT TRANSACTIONS                             |
 * ======================================================================*/
FUNCTION get_le_from_tax_registration(
   p_api_version       IN         NUMBER,
   p_init_msg_list     IN         VARCHAR2,
   p_commit            IN         VARCHAR2,
   p_validation_level  IN         NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_registration_num  IN         ZX_REGISTRATIONS.Registration_Number%type,
   p_effective_date    IN         ZX_REGISTRATIONS.effective_from%type,
   p_country           IN         ZX_PARTY_TAX_PROFILE.Country_code%type
  ) RETURN Number IS
  l_api_name           CONSTANT VARCHAR2(30) := 'GET_LE_FROM_TAX_REGISTRATION';
  l_api_version        CONSTANT  NUMBER := 1.0;
  l_init_msg_list      VARCHAR2(1);
  l_legal_entity_id    NUMBER;
  l_return_status      VARCHAR2(1);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT GET_LE_FROM_TAX_REGISTRATN_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
       l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

    /*-----------------------------------------+
     |   Initialize return status to SUCCESS   |
     +-----------------------------------------*/
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*-----------------------------------------+
     |   Populate Global Variable              |
     +-----------------------------------------*/
     G_PUB_SRVC := l_api_name;
     G_DATA_TRANSFER_MODE := 'PLS';
     G_EXTERNAL_API_CALL  := 'N';


     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
         'Registration Number: ' || to_char(p_registration_num)||
         ', Country Code: ' || p_country ||
         ', Effective_date: ' || to_char(p_effective_date));
     END IF;


    /*-------------------------------------------------+
     |   Call TDM API to default the tax classification|
     +-------------------------------------------------*/

    l_legal_entity_id :=  ZX_TCM_EXT_SERVICES_PUB.get_le_from_tax_registration (x_return_status,
                                                                                p_registration_num,
                                                                                p_effective_date,
                                                                                p_country
                                                                               );
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
           ':ZX_TCM_EXT_SERVICES.get_le_from_tax_registration returned errors');
       END IF;
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     ELSE
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
         'Legal Entity : ' || to_char(l_legal_entity_id)
         );
       END IF;
       RETURN l_legal_entity_id;
     END IF;

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
     END IF;
     EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO GET_LE_FROM_TAX_REGISTRATN_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            DUMP_MSG;
           /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count   =>      x_msg_count,
                                      p_data    =>      x_msg_data
                                      );
            IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
            END IF;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO GET_LE_FROM_TAX_REGISTRATN_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            DUMP_MSG;
            FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
            FND_MSG_PUB.Add;
           /*---------------------------------------------------------+
            | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
            | in the message stack. If there is only one message in   |
            | the stack it retrieves this message                     |
            +---------------------------------------------------------*/
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                      p_count   =>      x_msg_count,
                                      p_data    =>      x_msg_data
                                      );
            IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
            END IF;

          WHEN OTHERS THEN
             ROLLBACK TO GET_LE_FROM_TAX_REGISTRATN_PVT;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
             FND_MSG_PUB.Add;
            /*---------------------------------------------------------+
             | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
             | in the message stack. If there is only one message in   |
             | the stack it retrieves this message                     |
             +---------------------------------------------------------*/
             FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                       p_count  =>      x_msg_count,
                                       p_data   =>      x_msg_data
                                       );
             IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
             END IF;
END get_le_from_tax_registration;

 /* ============================================================================*
 | PROCEDURE  update_posting_flag : This procedure will update the posting_flag|
 | for the tax distribution ids that are passed in from product.               |
 * ============================================================================*/
 PROCEDURE update_posting_flag(
  p_api_version        IN  NUMBER,
  p_init_msg_list      IN  VARCHAR2,
  p_commit             IN  VARCHAR2,
  p_validation_level   IN  NUMBER,
  x_return_status      OUT NOCOPY     VARCHAR2,
  x_msg_count          OUT NOCOPY     NUMBER,
  x_msg_data           OUT NOCOPY     VARCHAR2,
  p_tax_dist_id_tbl    IN  tax_dist_id_tbl_type
  )IS
  l_api_name                  CONSTANT  VARCHAR2(30) := 'UPDATE_POSTING_FLAG';
  l_api_version               CONSTANT  NUMBER := 1.0;
  l_return_status             VARCHAR2(1);
  l_init_msg_list             VARCHAR2(1);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT update_posting_flag_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
       l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

  /*-----------------------------------------+
   |   Initialize return status to SUCCESS   |
   +-----------------------------------------*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*-----------------------------------------+
   |   Populate Global Variable              |
   +-----------------------------------------*/
   G_PUB_SRVC := l_api_name;
   G_DATA_TRANSFER_MODE := 'PLS';
   G_EXTERNAL_API_CALL  := 'N';

   IF ( G_LEVEL_EVENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_EVENT,G_MODULE_NAME||l_api_name,
      'Call TRD service to update posting flag'
       );
   END IF;

   ZX_TRD_SERVICES_PUB_PKG.update_posting_flag(p_tax_dist_id_tbl => p_tax_dist_id_tbl,
                                                      x_return_status    => l_return_status
                                                     );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||
          ':ZX_TRD_SERVICES_PUB_PKG.update_posting_flag returned errors');
     END IF;
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_API_PUB: '||l_api_name||'()-');
   END IF;

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_posting_flag_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        DUMP_MSG;
       /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data
                                  );

        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_posting_flag_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        DUMP_MSG;
        FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
        FND_MSG_PUB.Add;
       /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data
                                  );

        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN OTHERS THEN
         ROLLBACK TO update_posting_flag_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
         FND_MSG_PUB.Add;
        /*---------------------------------------------------------+
         | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
         | in the message stack. If there is only one message in   |
         | the stack it retrieves this message                     |
         +---------------------------------------------------------*/
         FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count   => x_msg_count,
                                   p_data    => x_msg_data
                                   );
         IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;

 END update_posting_flag;

PROCEDURE unapply_applied_cm
   ( p_api_version           IN            NUMBER,
     p_init_msg_list         IN            VARCHAR2,
     p_commit                IN            VARCHAR2,
     p_validation_level      IN            NUMBER,
     p_trx_id                IN            NUMBER,
     x_return_status         OUT NOCOPY    VARCHAR2,
     x_msg_count             OUT NOCOPY    NUMBER,
     x_msg_data              OUT NOCOPY    VARCHAR2
    ) IS

  l_api_name                  CONSTANT  VARCHAR2(30) := 'UNAPPLY_APPLIED_CM';
  l_api_version               CONSTANT  NUMBER := 1.0;
  l_init_msg_list             VARCHAR2(1);
BEGIN
  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()+');
  END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
  SAVEPOINT unapply_applied_cm_PVT;

  /*-------------------------------------------------+
  |   Standard call to check for call compatibility  |
  +--------------------------------------------------*/
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME
                                     ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /*-------------------------------------------------------------+
  |   Initialize message list if p_init_msg_list is set to TRUE  |
  +--------------------------------------------------------------*/
  IF p_init_msg_list is null THEN
    l_init_msg_list := FND_API.G_FALSE;
  ELSE
    l_init_msg_list := p_init_msg_list;
  END IF;

  IF FND_API.to_Boolean(l_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  /*----------------------------------------+
  |   Initialize return status to SUCCESS   |
  +-----------------------------------------*/

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*----------------------------------------+
  |   Populate Global Variable              |
  +-----------------------------------------*/

  G_DATA_TRANSFER_MODE := 'WIN';

  update zx_lines
  set adjusted_doc_application_id = null,
    adjusted_doc_entity_code = null,
    adjusted_doc_event_class_code = null,
    adjusted_doc_trx_id = null,
    adjusted_doc_line_id = null,
    adjusted_doc_number = null,
    adjusted_doc_date = null,
    adjusted_doc_trx_level_type = null,
    adjusted_doc_tax_line_id = null
  where application_id = 222
  and entity_code = 'TRANSACTIONS'
  and event_class_code = 'CREDIT_MEMO'
  and trx_id = p_trx_id;

  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                  'Number of Rows updated in zx_lines: '||SQL%ROWCOUNT);
  END IF;

  update zx_lines_det_factors
  set adjusted_doc_application_id = null,
    adjusted_doc_entity_code = null,
    adjusted_doc_event_class_code = null,
    adjusted_doc_trx_id = null,
    adjusted_doc_line_id = null,
    adjusted_doc_number = null,
    adjusted_doc_trx_level_type = null,
    adjusted_doc_date = null
  where application_id = 222
  and entity_code = 'TRANSACTIONS'
  and event_class_code = 'CREDIT_MEMO'
  and trx_id = p_trx_id;

  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                  'Number of Rows updated in zx_lines_det_factors: '||SQL%ROWCOUNT);
    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_API_PUB: '||l_api_name||'()-');
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO unapply_applied_cm_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    DUMP_MSG;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => x_msg_count,
                              p_data    => x_msg_data
                             );
    IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'Exception(-)');
    END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO unapply_applied_cm_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    DUMP_MSG;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => x_msg_count,
                              p_data    => x_msg_data
                             );
    IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'Unexpected Error(-)');
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO unapply_applied_cm_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
    END IF;
END unapply_applied_cm;

END ZX_API_PUB;

/
