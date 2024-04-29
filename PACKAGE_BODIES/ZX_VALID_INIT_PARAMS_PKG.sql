--------------------------------------------------------
--  DDL for Package Body ZX_VALID_INIT_PARAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_VALID_INIT_PARAMS_PKG" AS
/* $Header: zxifvaldinitpkgb.pls 120.153.12010000.5 2010/02/26 09:42:51 tsen ship $ */


/* ======================================================================*
 | Global Data Types                                                     |
 * ======================================================================*/

G_PKG_NAME                CONSTANT VARCHAR2(30) := 'ZX_VALID_INIT_PARAMS_PKG';
G_CURRENT_RUNTIME_LEVEL   CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED        CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR             CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION         CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT             CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE         CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT         CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME             CONSTANT VARCHAR2(80) := 'ZX.PLSQL.ZX_VALID_INIT_PARAMS_PKG.';
NULL_EVENT_CLASS_REC      ZX_API_PUB.event_class_rec_type;

/*----------------------------------------------------------------------------*
 |   PRIVATE FUNCTIONS/PROCEDURES                                             |
 *----------------------------------------------------------------------------*/

 PROCEDURE get_event_class_info(
     P_ENTITY_CODE         IN         ZX_EVNT_CLS_MAPPINGS.entity_code%TYPE,
     P_EVENT_CLASS_CODE    IN         ZX_EVNT_CLS_MAPPINGS.event_class_code%TYPE,
     P_APPLICATION_ID      IN         ZX_EVNT_CLS_MAPPINGS.application_id%TYPE,
     X_TBL_INDEX           OUT NOCOPY BINARY_INTEGER,
     X_RETURN_STATUS       OUT NOCOPY VARCHAR2);

 PROCEDURE get_event_typ_mappings_info(
     P_ENTITY_CODE         IN         ZX_EVNT_TYP_MAPPINGS.entity_code%TYPE,
     P_EVENT_CLASS_CODE    IN         ZX_EVNT_TYP_MAPPINGS.event_class_code%TYPE,
     P_APPLICATION_ID      IN         ZX_EVNT_TYP_MAPPINGS.application_id%TYPE,
     P_EVENT_TYPE_CODE     IN         ZX_EVNT_TYP_MAPPINGS.event_type_code%TYPE,
     X_TBL_INDEX           OUT NOCOPY BINARY_INTEGER,
     X_RETURN_STATUS       OUT NOCOPY VARCHAR2);

 PROCEDURE populate_event_cls_typs;
 PROCEDURE populate_tax_event_class_info;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_locations
--
--  DESCRIPTION
--  Returns the location passed into input structures
--
--  CALLED BY
--    Private procedure get_loc_id_and_ptp_ids
-----------------------------------------------------------------------
  PROCEDURE get_locations
  ( p_event_class_rec        IN zx_api_pub.event_class_rec_type,
    p_trx_line_index         IN  NUMBER,
    x_ship_from_location_id  OUT NOCOPY NUMBER,
    x_bill_from_location_id  OUT NOCOPY NUMBER,
    x_ship_to_location_id    OUT NOCOPY NUMBER,
    x_bill_to_location_id    OUT NOCOPY NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2
  )IS
  l_api_name           CONSTANT VARCHAR2(30) := 'GET_LOCATIONS';
  l_return_status      VARCHAR2(30);
  l_index              NUMBER;

  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ZX_API_PUB.G_DATA_TRANSFER_MODE IN ('TAB','WIN') THEN

       l_index := p_trx_line_index;

     ELSIF ZX_API_PUB.G_DATA_TRANSFER_MODE = 'PLS' THEN

       l_index := nvl(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.internal_organization_id.first,0);

     END IF;

     IF l_index <> 0 then
        x_ship_to_location_id := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_to_location_id(l_index);
        x_ship_from_location_id := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_from_location_id(l_index);
        x_bill_to_location_id := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_to_location_id(l_index);
        x_bill_from_location_id := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_from_location_id(l_index);
     END IF;


    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(
        G_LEVEL_STATEMENT,
        G_MODULE_NAME||l_api_name||'.END',
        G_PKG_NAME||': '||l_api_name||'()-'||
        ' Ship from Location = ' || to_char(x_ship_from_location_id)||
        ', Ship To Location = ' || to_char(x_ship_to_location_id)||
        ', Bill From Location = ' || to_char(x_bill_from_location_id)||
        ', Bill To Location = ' || to_char(x_bill_to_location_id)||
        ', RETURN_STATUS = ' || x_return_status);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(
           G_LEVEL_UNEXPECTED,
           G_MODULE_NAME||l_api_name,
           'No lines exist in zx_transaction_lines_gt which '||
           'is incorrect or the event information in headers and lines is incorrect.' ||
           SQLERRM);
      END IF;
  END get_locations;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_loc_id_and_ptp_ids
--
--  DESCRIPTION
--  Returns the location and ptp ids for parties passed into input structures
--
--  CALLED BY
--    calculate_tax
--    import_document_with_tax
--    insupd_line_det_factors
-----------------------------------------------------------------------
PROCEDURE get_loc_id_and_ptp_ids(
 p_event_class_rec  IN OUT NOCOPY ZX_API_PUB.event_class_rec_type,
 p_trx_line_index   IN NUMBER,
 x_return_status    OUT    NOCOPY VARCHAR2
 ) IS
 l_api_name    CONSTANT  VARCHAR2(30) := 'GET_LOC_ID_AND_PTP_IDS';
 l_return_status         VARCHAR2(1);
 l_ship_from_location_id NUMBER;
 l_ship_to_location_id   NUMBER;
 l_bill_from_location_id NUMBER;
 l_bill_to_location_id   NUMBER;
 l_context_info_rec      ZX_API_PUB.context_info_rec_type;

 BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    get_locations (p_event_class_rec,
                   nvl(p_trx_line_index,0),
                   l_ship_from_location_id,
                   l_bill_from_location_id,
                   l_ship_to_location_id,
                   l_bill_to_location_id,
                   l_return_status
                   );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

    IF p_event_class_rec.rounding_ship_to_party_id is NOT NULL THEN
       ZX_TCM_PTP_PKG.get_ptp(p_event_class_rec.rounding_ship_to_party_id
                             ,source_rec.ship_to_party_type
                             ,p_event_class_rec.legal_entity_id
                             ,l_ship_to_location_id
                             ,p_event_class_rec.rdng_ship_to_pty_tx_prof_id
                             ,l_return_status
                             );
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               'Error: Unable to return rdng_ship_to_pty_tx_prof_id for  rounding_ship_to_party_id : ' || to_char(p_event_class_rec.rounding_ship_to_party_id));
            END IF;
            l_context_info_rec.APPLICATION_ID   := p_event_class_rec.APPLICATION_ID;
            l_context_info_rec.ENTITY_CODE      := p_event_class_rec.ENTITY_CODE;
            l_context_info_rec.EVENT_CLASS_CODE := p_event_class_rec.EVENT_CLASS_CODE;
            l_context_info_rec.TRX_ID           := p_event_class_rec.TRX_ID;
            ZX_API_PUB.add_msg(p_context_info_rec  =>  l_context_info_rec);
          END IF;
          x_return_status := l_return_status;
          RETURN;
        END IF;
    END IF;

    IF p_event_class_rec.rounding_ship_from_party_id is NOT NULL THEN
       ZX_TCM_PTP_PKG.get_ptp(p_event_class_rec.rounding_ship_from_party_id
                             ,source_rec.ship_from_party_type
                             ,p_event_class_rec.legal_entity_id
                             ,l_ship_from_location_id
                             ,p_event_class_rec.rdng_ship_from_pty_tx_prof_id
                             ,l_return_status
                             );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                'Error: Unable to return rdng_ship_from_pty_tx_prof_id for  rounding_ship_from_party_id : ' || to_char(p_event_class_rec.rounding_ship_from_party_id));
            END IF;
            l_context_info_rec.APPLICATION_ID   := p_event_class_rec.APPLICATION_ID;
            l_context_info_rec.ENTITY_CODE      := p_event_class_rec.ENTITY_CODE;
            l_context_info_rec.EVENT_CLASS_CODE := p_event_class_rec.EVENT_CLASS_CODE;
            l_context_info_rec.TRX_ID           := p_event_class_rec.TRX_ID;
            ZX_API_PUB.add_msg(p_context_info_rec  =>  l_context_info_rec);
          END IF;
          x_return_status := l_return_status;
          RETURN;
        END IF;
    END IF;

    IF p_event_class_rec.rndg_ship_to_party_site_id is NOT NULL THEN
       ZX_TCM_PTP_PKG.get_ptp( p_event_class_rec.rndg_ship_to_party_site_id
                              ,source_rec.ship_to_pty_site_type
                              ,p_event_class_rec.legal_entity_id
                              ,null
                              ,p_event_class_rec.rdng_ship_to_pty_tx_p_st_id
                              ,l_return_status
                              );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               'Error: Unable to return rdng_ship_to_pty_tx_p_st_id for rndg_ship_to_party_site_id : ' || to_char(p_event_class_rec.rndg_ship_to_party_site_id));
            END IF;
            l_context_info_rec.APPLICATION_ID   := p_event_class_rec.APPLICATION_ID;
            l_context_info_rec.ENTITY_CODE      := p_event_class_rec.ENTITY_CODE;
            l_context_info_rec.EVENT_CLASS_CODE := p_event_class_rec.EVENT_CLASS_CODE;
            l_context_info_rec.TRX_ID           := p_event_class_rec.TRX_ID;
            ZX_API_PUB.add_msg(p_context_info_rec  =>  l_context_info_rec);
          END IF;
          x_return_status := l_return_status;
          RETURN;
        END IF;
    END IF;

    IF p_event_class_rec.rndg_ship_from_party_site_id is NOT NULL THEN
       ZX_TCM_PTP_PKG.get_ptp( p_event_class_rec.rndg_ship_from_party_site_id
                              ,source_rec.ship_from_pty_site_type
                              ,p_event_class_rec.legal_entity_id
                              ,null
                              ,p_event_class_rec.rdng_ship_from_pty_tx_p_st_id
                              ,l_return_status
                              );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               'Error: Unable to return rdng_ship_from_pty_tx_p_st_id for  rndg_ship_from_party_site_id : ' || to_char(p_event_class_rec.rndg_ship_from_party_site_id));
           END IF;
           l_context_info_rec.APPLICATION_ID   := p_event_class_rec.APPLICATION_ID;
           l_context_info_rec.ENTITY_CODE      := p_event_class_rec.ENTITY_CODE;
           l_context_info_rec.EVENT_CLASS_CODE := p_event_class_rec.EVENT_CLASS_CODE;
           l_context_info_rec.TRX_ID           := p_event_class_rec.TRX_ID;
           ZX_API_PUB.add_msg(p_context_info_rec  =>  l_context_info_rec);
         END IF;
         x_return_status := l_return_status;
         RETURN;
       END IF;
    END IF;

    IF p_event_class_rec.rounding_bill_to_party_id is NOT NULL THEN
       IF (p_event_class_rec.rounding_bill_to_party_id <> p_event_class_rec.rounding_ship_to_party_id)
           OR (source_rec.ship_to_party_type <> source_rec.bill_to_party_type)
           OR p_event_class_rec.rounding_ship_to_party_id is null THEN
           ZX_TCM_PTP_PKG.get_ptp(p_event_class_rec.rounding_bill_to_party_id
                                 ,source_rec.bill_to_party_type
                                 ,p_event_class_rec.legal_entity_id
                                 ,l_bill_to_location_id
                                 ,p_event_class_rec.rdng_bill_to_pty_tx_prof_id
                                 ,l_return_status
                                 );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                   'Error: Unable to return rdng_bill_to_pty_tx_prof_id for  rounding_bill_to_party_id : ' || to_char(p_event_class_rec.rounding_bill_to_party_id));
               END IF;
               l_context_info_rec.APPLICATION_ID   := p_event_class_rec.APPLICATION_ID;
               l_context_info_rec.ENTITY_CODE      := p_event_class_rec.ENTITY_CODE;
               l_context_info_rec.EVENT_CLASS_CODE := p_event_class_rec.EVENT_CLASS_CODE;
               l_context_info_rec.TRX_ID           := p_event_class_rec.TRX_ID;
               ZX_API_PUB.add_msg(p_context_info_rec  =>  l_context_info_rec);
             END IF;
             x_return_status := l_return_status;
             RETURN;
           END IF;
       ELSE
          p_event_class_rec.rdng_bill_to_pty_tx_prof_id := p_event_class_rec.rdng_ship_to_pty_tx_prof_id;
       END IF;
    END IF;

    IF p_event_class_rec.rounding_bill_from_party_id is NOT NULL THEN
       IF (p_event_class_rec.rounding_bill_from_party_id <> p_event_class_rec.rounding_ship_from_party_id)
           OR (source_rec.ship_from_party_type <> source_rec.bill_from_party_type)
           OR p_event_class_rec.rounding_ship_from_party_id is null THEN
           ZX_TCM_PTP_PKG.get_ptp(p_event_class_rec.rounding_bill_from_party_id
                                 ,source_rec.bill_from_party_type
                                 ,p_event_class_rec.legal_entity_id
                                 ,l_bill_from_location_id
                                 ,p_event_class_rec.rdng_bill_from_pty_tx_prof_id
                                 ,l_return_status
                                 );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                   'Error: Unable to return rdng_bill_from_pty_tx_prof_id for  rounding_bill_from_party_id : ' || to_char(p_event_class_rec.rounding_bill_from_party_id));
               END IF;
               l_context_info_rec.APPLICATION_ID   := p_event_class_rec.APPLICATION_ID;
               l_context_info_rec.ENTITY_CODE      := p_event_class_rec.ENTITY_CODE;
               l_context_info_rec.EVENT_CLASS_CODE := p_event_class_rec.EVENT_CLASS_CODE;
               l_context_info_rec.TRX_ID           := p_event_class_rec.TRX_ID;
               ZX_API_PUB.add_msg(p_context_info_rec =>  l_context_info_rec);
             END IF;
             x_return_status := l_return_status;
             RETURN;
           END IF;
       ELSE
          p_event_class_rec.rdng_bill_from_pty_tx_prof_id := p_event_class_rec.rdng_ship_from_pty_tx_prof_id;
       END IF;
    END IF;

    IF p_event_class_rec.rndg_bill_to_party_site_id is NOT NULL THEN
       IF (p_event_class_rec.rndg_bill_to_party_site_id <> p_event_class_rec.rndg_ship_to_party_site_id)
           OR (source_rec.ship_to_pty_site_type <> source_rec.bill_to_pty_site_type)
           OR p_event_class_rec.rndg_ship_to_party_site_id is null THEN
           ZX_TCM_PTP_PKG.get_ptp(p_event_class_rec.rndg_bill_to_party_site_id
                                 ,source_rec.bill_to_pty_site_type
                                 ,p_event_class_rec.legal_entity_id
                                 ,null
                                 ,p_event_class_rec.rdng_bill_to_pty_tx_p_st_id
                                 ,l_return_status
                                );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                   'Error: Unable to return rdng_bill_to_pty_tx_p_st_id for  rndg_bill_to_party_site_id : ' || to_char(p_event_class_rec.rndg_bill_to_party_site_id));
               END IF;
               l_context_info_rec.APPLICATION_ID   := p_event_class_rec.APPLICATION_ID;
               l_context_info_rec.ENTITY_CODE      := p_event_class_rec.ENTITY_CODE;
               l_context_info_rec.EVENT_CLASS_CODE := p_event_class_rec.EVENT_CLASS_CODE;
               l_context_info_rec.TRX_ID           := p_event_class_rec.TRX_ID;
               ZX_API_PUB.add_msg(p_context_info_rec  =>  l_context_info_rec);
             END IF;
             x_return_status := l_return_status;
             RETURN;
           END IF;
       ELSE
          p_event_class_rec.rdng_bill_to_pty_tx_p_st_id := p_event_class_rec.rdng_ship_to_pty_tx_p_st_id;
       END IF;
    END IF;

    IF p_event_class_rec.rndg_bill_from_party_site_id is NOT NULL THEN
       IF p_event_class_rec.rndg_bill_from_party_site_id <> p_event_class_rec.rndg_ship_from_party_site_id
           OR (source_rec.ship_from_pty_site_type <> source_rec.bill_from_pty_site_type)
           OR p_event_class_rec.rndg_ship_from_party_site_id is null THEN
           ZX_TCM_PTP_PKG.get_ptp(p_event_class_rec.rndg_bill_from_party_site_id
                                 ,source_rec.bill_from_pty_site_type
                                 ,p_event_class_rec.legal_entity_id
                                 ,null
                                 ,p_event_class_rec.rdng_bill_from_pty_tx_p_st_id
                                 ,l_return_status
                                 );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                   'Error: Unable to return rdng_bill_from_pty_tx_p_st_id for  rndg_bill_from_party_site_id : ' || to_char(p_event_class_rec.rndg_bill_from_party_site_id));
               END IF;
               l_context_info_rec.APPLICATION_ID   := p_event_class_rec.APPLICATION_ID;
               l_context_info_rec.ENTITY_CODE      := p_event_class_rec.ENTITY_CODE;
               l_context_info_rec.EVENT_CLASS_CODE := p_event_class_rec.EVENT_CLASS_CODE;
               l_context_info_rec.TRX_ID           := p_event_class_rec.TRX_ID;
               ZX_API_PUB.add_msg(p_context_info_rec  =>  l_context_info_rec);
             END IF;
             x_return_status := l_return_status;
             RETURN;
           END IF;
       ELSE
          p_event_class_rec.rdng_bill_from_pty_tx_p_st_id := p_event_class_rec.rdng_ship_from_pty_tx_p_st_id;
       END IF;
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_api_name||'.END',
                   G_PKG_NAME||': '||l_api_name||'()-' ||
                   ', RETURN_STATUS = ' || x_return_status);
    END IF;
 END GET_LOC_ID_AND_PTP_IDS;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_effective_date
--
--  DESCRIPTION
--  Logic to get the effective dates
--
--  CALLED BY
--    determine_effective_date
--    get_tax_subscriber
--    set_security_context
-----------------------------------------------------------------------
  FUNCTION get_effective_date
  ( p_related_doc_date   IN DATE,
    p_prov_tax_det_date  IN DATE,
    p_adjusted_doc_date  IN DATE,
    p_trx_date           IN DATE
  ) RETURN DATE IS
  l_api_name         CONSTANT VARCHAR2(30) := 'GET_EFFECTIVE_DATE';
  l_effective_date   DATE;

  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    IF p_related_doc_date is NOT NULL THEN
       l_effective_date := p_related_doc_date;
    ELSIF p_prov_tax_det_date is NOT NULL THEN
       l_effective_date := p_prov_tax_det_date;
    ELSIF p_adjusted_doc_date is NOT NULL THEN
       l_effective_date := p_adjusted_doc_date;
    ELSE
       l_effective_date := p_trx_date;
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
    END IF;

    RETURN l_effective_date;
  END get_effective_date;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  determine_effective_date
--
--  DESCRIPTION
--  Logic for determining effective_date
--
--  CALLED BY
--    calculate_tax
--    import_document_with_tax
--    get_default_tax_det_attrs
--    override_tax
--    validate_document_for_tax
--    insupd_line_det_factors
-----------------------------------------------------------------------
  PROCEDURE determine_effective_date
  ( p_event_class_rec IN         ZX_API_PUB.event_class_rec_type,
    x_effective_date  OUT NOCOPY DATE,
    x_return_status   OUT NOCOPY VARCHAR2
  )IS
  l_api_name            CONSTANT VARCHAR2(30):= 'DETERMINE_EFFECTIVE_DATE';
  l_adj_doc_date        DATE;

  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF  ZX_API_PUB.G_PUB_SRVC in ('CALCULATE_TAX','IMPORT_DOCUMENT_WITH_TAX','OVERRIDE_TAX',
                                  'GET_DEFAULT_TAX_DET_ATTRS','VALIDATE_DOCUMENT_FOR_TAX') THEN
      IF  ZX_API_PUB.G_DATA_TRANSFER_MODE = 'TAB' THEN
        SELECT /*+ INDEX (ZX_TRANSACTION_LINES_GT ZX_TRANSACTION_LINES_GT_U1)*/
               adjusted_doc_date
          INTO l_adj_doc_date
         FROM  ZX_TRANSACTION_LINES_GT
         WHERE application_id   = p_event_class_rec.application_id
           AND entity_code      = p_event_class_rec.entity_code
           AND event_class_code = p_event_class_rec.event_class_code
           AND trx_id           = p_event_class_rec.trx_id
           AND rownum           = 1;
      ELSIF ZX_API_PUB.G_DATA_TRANSFER_MODE = 'WIN' OR
            ZX_API_PUB.G_PUB_SRVC in ('VALIDATE_DOCUMENT_FOR_TAX','OVERRIDE_TAX') THEN
        SELECT adjusted_doc_date
          INTO l_adj_doc_date
         FROM  ZX_LINES_DET_FACTORS
         WHERE application_id   = p_event_class_rec.application_id
           AND entity_code      = p_event_class_rec.entity_code
           AND event_class_code = p_event_class_rec.event_class_code
           AND trx_id           = p_event_class_rec.trx_id
           AND rownum           = 1;
      ELSIF ZX_API_PUB.G_DATA_TRANSFER_MODE = 'PLS' THEN
        l_adj_doc_date := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_date(1);
      END IF;
    ELSE --for calls from products via global structures eg. update_line_det_factors/insert_line_det_factors
      l_adj_doc_date := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.adjusted_doc_date(1);
    END IF;

    x_effective_date := get_effective_date (p_event_class_rec.rel_doc_date,
                                            p_event_class_rec.provnl_tax_determination_date,
                                            l_adj_doc_date,
                                            p_event_class_rec.trx_date
                                            );

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||
                   '.END',G_PKG_NAME||': '||l_api_name||'()-'||
                   ', Adjusted doc date = ' || l_adj_doc_date||
                   ', x_effective_date = ' || x_effective_date||
                   ', RETURN_STATUS = ' || x_return_status);
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      null;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,
           'No lines exist in zx_transaction_lines_gt/zx_lines_det_factors'||
           ' which is incorrect or the event information in headers and lines is incorrect.'||
           SQLERRM);
      END IF;
  END determine_effective_date;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  Populate_event_class_options
--
--  DESCRIPTION
--  For the specified subscriber this procedure identifies and fetches
--  the event class options setup for the specified event class into
--  the event class record
--
--  CALLED BY
--    calculate_tax
--    import_document_with_tax
--    override_tax
--    validate_document_for_tax
--    insupd_line_det_factors
--    get_default_tax_det_attrs
-----------------------------------------------------------------------
  PROCEDURE populate_event_class_options
  ( x_return_status   OUT NOCOPY    VARCHAR2,
    p_trx_date        IN            DATE,
    p_event_class_rec IN OUT NOCOPY ZX_API_PUB.event_class_rec_type
  )IS
  l_api_name          CONSTANT VARCHAR2(30) := 'POPULATE_EVENT_CLASS_OPTIONS';

  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := null_event_class_rec;

    BEGIN
    IF p_event_class_rec.event_class_code = 'SALES_TRANSACTION_TAX_QUOTE' THEN
      SELECT det_factor_templ_code,
             default_rounding_level_code,
             rounding_level_hier_1_code,
             rounding_level_hier_2_code,
             rounding_level_hier_3_code,
             rounding_level_hier_4_code,
             process_for_applicability_flag,
             def_intrcmp_trx_biz_category,
             exmptn_pty_basis_hier_1_code,
             exmptn_pty_basis_hier_2_code,
             allow_exemptions_flag
      INTO   p_event_class_rec.det_factor_templ_code,
             p_event_class_rec.default_rounding_level_code,
             p_event_class_rec.rounding_level_hier_1_code,
             p_event_class_rec.rounding_level_hier_2_code,
             p_event_class_rec.rounding_level_hier_3_code,
             p_event_class_rec.rounding_level_hier_4_code,
             p_event_class_rec.process_for_applicability_flag,
             p_event_class_rec.DEF_INTRCMP_TRX_BIZ_CATEGORY,
             p_event_class_rec.exmptn_pty_basis_hier_1_code,
             p_event_class_rec.exmptn_pty_basis_hier_2_code,
             p_event_class_rec.ALLOW_EXEMPTIONS_FLAG
      FROM   ZX_EVNT_CLS_OPTIONS
      WHERE  application_id = 222
      AND    entity_code = 'TRANSACTIONS'
      AND    event_class_code = 'INVOICE'
      AND    first_pty_org_id = p_event_class_rec.first_pty_org_id
      AND    p_trx_date >= EFFECTIVE_FROM and p_trx_date <= nvl(EFFECTIVE_TO,p_trx_date)
      AND    enabled_flag = 'Y';
    ELSIF p_event_class_rec.event_class_code = 'PURCHASE_TRANSACTION_TAX_QUOTE' THEN
      SELECT det_factor_templ_code,
             default_rounding_level_code,
             rounding_level_hier_1_code,
             rounding_level_hier_2_code,
             rounding_level_hier_3_code,
             rounding_level_hier_4_code,
             process_for_applicability_flag,
             def_intrcmp_trx_biz_category,
             exmptn_pty_basis_hier_1_code,
             exmptn_pty_basis_hier_2_code,
             allow_exemptions_flag
      INTO   p_event_class_rec.det_factor_templ_code,
             p_event_class_rec.default_rounding_level_code,
             p_event_class_rec.rounding_level_hier_1_code,
             p_event_class_rec.rounding_level_hier_2_code,
             p_event_class_rec.rounding_level_hier_3_code,
             p_event_class_rec.rounding_level_hier_4_code,
             p_event_class_rec.process_for_applicability_flag,
             p_event_class_rec.DEF_INTRCMP_TRX_BIZ_CATEGORY,
             p_event_class_rec.exmptn_pty_basis_hier_1_code,
             p_event_class_rec.exmptn_pty_basis_hier_2_code,
             p_event_class_rec.ALLOW_EXEMPTIONS_FLAG
      FROM   ZX_EVNT_CLS_OPTIONS
      WHERE  application_id = 200
      AND    entity_code = 'AP_INVOICES'
      AND    event_class_code = 'STANDARD INVOICES'
      AND    first_pty_org_id = p_event_class_rec.first_pty_org_id
      AND    p_trx_date >= EFFECTIVE_FROM and p_trx_date <= nvl(EFFECTIVE_TO,p_trx_date)
      AND    enabled_flag = 'Y';
    ELSE
      SELECT det_factor_templ_code,
             default_rounding_level_code,
             rounding_level_hier_1_code,
             rounding_level_hier_2_code,
             rounding_level_hier_3_code,
             rounding_level_hier_4_code,
             allow_manual_lin_recalc_flag,
             allow_override_flag,
             allow_manual_lines_flag,
             perf_addnl_appl_for_imprt_flag,
             enforce_tax_from_acct_flag,
             offset_tax_basis_code,
             tax_tolerance,
             tax_tol_amt_range,
             'N',
             allow_offset_tax_calc_flag,
             enter_ovrd_incl_tax_lines_flag ,
             ctrl_eff_ovrd_calc_lines_flag,
             enforce_tax_from_ref_doc_flag,
             process_for_applicability_flag,
             allow_exemptions_flag,
             exmptn_pty_basis_hier_1_code,
             exmptn_pty_basis_hier_2_code,
             def_intrcmp_trx_biz_category
      INTO   p_event_class_rec.DET_FACTOR_TEMPL_CODE,
             p_event_class_rec.DEFAULT_ROUNDING_LEVEL_CODE,
             p_event_class_rec.ROUNDING_LEVEL_HIER_1_CODE,
             p_event_class_rec.ROUNDING_LEVEL_HIER_2_CODE,
             p_event_class_rec.ROUNDING_LEVEL_HIER_3_CODE,
             p_event_class_rec.ROUNDING_LEVEL_HIER_4_CODE,
             p_event_class_rec.ALLOW_MANUAL_LIN_RECALC_FLAG,
             p_event_class_rec.ALLOW_OVERRIDE_FLAG,
             p_event_class_rec.ALLOW_MANUAL_LINES_FLAG,
             p_event_class_rec.PERF_ADDNL_APPL_FOR_IMPRT_FLAG,
             p_event_class_rec.ENFORCE_TAX_FROM_ACCT_FLAG,
             p_event_class_rec.OFFSET_TAX_BASIS_CODE,
             p_event_class_rec.TAX_TOLERANCE,
             p_event_class_rec.TAX_TOL_AMT_RANGE,
             p_event_class_rec.CTRL_TOTAL_LINE_TX_AMT_FLG,
             p_event_class_rec.ALLOW_OFFSET_TAX_CALC_FLAG,
             p_event_class_rec.ENTER_OVRD_INCL_TAX_LINES_FLAG ,
             p_event_class_rec.CTRL_EFF_OVRD_CALC_LINES_FLAG,
             p_event_class_rec.ENFORCE_TAX_FROM_REF_DOC_FLAG,
             p_event_class_rec.PROCESS_FOR_APPLICABILITY_FLAG,
             p_event_class_rec.ALLOW_EXEMPTIONS_FLAG,
             p_event_class_rec.EXMPTN_PTY_BASIS_HIER_1_CODE,
             p_event_class_rec.EXMPTN_PTY_BASIS_HIER_2_CODE,
             p_event_class_rec.DEF_INTRCMP_TRX_BIZ_CATEGORY
      FROM   ZX_EVNT_CLS_OPTIONS
      WHERE  application_id = p_event_class_rec.application_id
      AND    entity_code = p_event_class_rec.entity_code
      AND    event_class_code = p_event_class_rec.event_class_code
      AND    first_pty_org_id = p_event_class_rec.first_pty_org_id
      AND    p_trx_date >= EFFECTIVE_FROM and p_trx_date <= nvl(EFFECTIVE_TO,p_trx_date)
      AND    enabled_flag = 'Y';
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
          null;
    END;
    --Bugfix 4765758 - Populate the process_for_applicability_flag in case the
    --source_event_class_code in ('TRADE_MGT_PAYABLES','TRADE_MGT_RECEIVABLES')
    --If 'N' then tax processing will not be done for such docs.
    BEGIN
      IF (ZX_API_PUB.G_DATA_TRANSFER_MODE =  'WIN' AND ZX_API_PUB.G_PUB_SRVC ='CALCULATE_TAX')
         OR (ZX_API_PUB.G_PUB_SRVC ='DETERMINE_RECOVERY') THEN
        SELECT opt.process_for_applicability_flag
          INTO p_event_class_rec.source_process_for_appl_flag
          FROM zx_evnt_cls_options opt,
               zx_lines_det_factors det
         WHERE opt.application_id    = det.source_application_id
           AND opt.entity_code       = det.source_entity_code
           AND opt.event_class_code  = det.source_event_class_code
           AND opt.first_pty_org_id  = p_event_class_rec.first_pty_org_id
           AND p_trx_date >= opt.EFFECTIVE_FROM and p_trx_date <= nvl(opt.EFFECTIVE_TO,p_trx_date)
           AND opt.enabled_flag      = 'Y'
           AND det.trx_id            = p_event_class_rec.trx_id
           AND det.application_id    = p_event_class_rec.application_id
           AND det.entity_code       = p_event_class_rec.entity_code
           AND det.event_class_code  = p_event_class_rec.event_class_code
           AND det.source_event_class_code in ('TRADE_MGT_PAYABLES','TRADE_MGT_RECEIVABLES')
           AND rownum=1;
      ELSIF ZX_API_PUB.G_DATA_TRANSFER_MODE =  'PLS' AND ZX_API_PUB.G_PUB_SRVC ='CALCULATE_TAX' THEN
        IF zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_EVENT_CLASS_CODE(1) = 'TRADE_MGT_PAYABLES' OR
	   zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_EVENT_CLASS_CODE(1) = 'TRADE_MGT_RECEIVABLES' THEN
          SELECT opt.process_for_applicability_flag
            INTO p_event_class_rec.source_process_for_appl_flag
            FROM zx_evnt_cls_options opt
           WHERE opt.application_id   = zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_APPLICATION_ID(1)
             AND opt.entity_code      = zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_ENTITY_CODE(1)
             AND opt.event_class_code = zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_EVENT_CLASS_CODE(1)
             AND opt.first_pty_org_id = p_event_class_rec.first_pty_org_id
             AND p_trx_date >= opt.EFFECTIVE_FROM and p_trx_date <= nvl(opt.EFFECTIVE_TO,p_trx_date)
             AND opt.enabled_flag = 'Y';
        END IF;
      ELSIF ZX_API_PUB.G_DATA_TRANSFER_MODE =  'TAB' THEN --import/calculate_tax
        SELECT opt.process_for_applicability_flag
          INTO p_event_class_rec.source_process_for_appl_flag
          FROM zx_evnt_cls_options opt,
               zx_transaction_lines_gt lines
         WHERE opt.application_id      = lines.source_application_id
           AND opt.entity_code         = lines.source_entity_code
           AND opt.event_class_code    = lines.source_event_class_code
           AND opt.first_pty_org_id    = p_event_class_rec.first_pty_org_id
           AND p_trx_date >= opt.EFFECTIVE_FROM and p_trx_date <= nvl(opt.EFFECTIVE_TO,p_trx_date)
           AND opt.enabled_flag        = 'Y'
           AND lines.trx_id            = p_event_class_rec.trx_id
           AND lines.application_id    = p_event_class_rec.application_id
           AND lines .entity_code      = p_event_class_rec.entity_code
           AND lines.event_class_code  = p_event_class_rec.event_class_code
           AND lines.source_event_class_code in ('TRADE_MGT_PAYABLES','TRADE_MGT_RECEIVABLES')
           AND rownum=1;
      END IF;
      EXCEPTION
        WHEN OTHERS THEN
          null;
    END;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.END',
                   G_PKG_NAME||': '||l_api_name||'()-'||
                   ' RETURN_STATUS = ' || x_return_status);
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      RETURN;
  END populate_event_class_options;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  populate_appl_product_options
--
--  DESCRIPTION
--  For the specified subscriber the procedure identifies and fetches
--  the product options set for the specified application into event class record
--
--  CALLED BY
--    calculate_tax
--    import_document_with_tax
--    insupd_line_det_factors
--    get_default_tax_det_attrs
-----------------------------------------------------------------------
  PROCEDURE populate_appl_product_options
  ( x_return_status    OUT    NOCOPY VARCHAR2,
    p_event_class_rec  IN OUT NOCOPY ZX_API_PUB.event_class_rec_type
  )IS
  l_api_name                CONSTANT VARCHAR2(30):= 'POPULATE_APPL_PRODUCT_OPTIONS';
  l_zx_product_options_rec  ZX_GLOBAL_STRUCTURES_PKG.zx_product_options_rec_type;
  l_application_id          NUMBER;

  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_event_class_rec.event_class_code = 'SALES_TRANSACTION_TAX_QUOTE' THEN
      l_application_id := 222;
    ELSIF p_event_class_rec.event_class_code = 'PURCHASE_TRANSACTION_TAX_QUOTE' THEN
      IF p_event_class_rec.application_id = 8407 THEN -- Bug 6510307
        l_application_id := p_event_class_rec.application_id;
      ELSE
        l_application_id := 200;
      END IF;
    ELSE
      l_application_id := p_event_class_rec.application_id;
    END IF;

   /* replaced the select from zx_product_options with cached structure
         SELECT nvl(tax_method_code,'EBTAX'),
                inclusive_tax_used_flag,
                tax_use_customer_exempt_flag,
                tax_use_product_exempt_flag,
                tax_use_loc_exc_rate_flag,
                tax_allow_compound_flag,
                use_tax_classification_flag,
                allow_tax_rounding_ovrd_flag,
                home_country_default_flag
         INTO   p_event_class_rec.TAX_METHOD_CODE,
                p_event_class_rec.INCLUSIVE_TAX_USED_FLAG,
                p_event_class_rec.TAX_USE_CUSTOMER_EXEMPT_FLAG,
                p_event_class_rec.TAX_USE_PRODUCT_EXEMPT_FLAG,
                p_event_class_rec.TAX_USE_LOC_EXC_RATE_FLAG,
                p_event_class_rec.TAX_ALLOW_COMPOUND_FLAG,
                p_event_class_rec.USE_TAX_CLASSIFICATION_FLAG,
                p_event_class_rec.ALLOW_TAX_ROUNDING_OVRD_FLAG,
                p_event_class_rec.HOME_COUNTRY_DEFAULT_FLAG
         FROM   ZX_PRODUCT_OPTIONS_ALL
         WHERE  application_id = l_application_id
           AND  org_id = p_event_class_rec.internal_organization_id
           AND  rownum = 1;
    */

    ZX_GLOBAL_STRUCTURES_PKG.get_product_options_info
                   (p_application_id      => l_application_id,
                    p_org_id              => p_event_class_rec.internal_organization_id,
                    x_product_options_rec => l_zx_product_options_rec,
                    x_return_status       => x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR then

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Incorrect return status after calling '||
                          'ZX_GLOBAL_STRUCTURES_PKG.get_product_options_info');
        END IF;

    ELSE
        p_event_class_rec.TAX_METHOD_CODE   :=                l_zx_product_options_rec.tax_method_code;
        p_event_class_rec.INCLUSIVE_TAX_USED_FLAG   :=        l_zx_product_options_rec.inclusive_tax_used_flag;
        p_event_class_rec.TAX_USE_CUSTOMER_EXEMPT_FLAG   :=   l_zx_product_options_rec.tax_use_customer_exempt_flag;
        p_event_class_rec.TAX_USE_PRODUCT_EXEMPT_FLAG   :=    l_zx_product_options_rec.tax_use_product_exempt_flag;
        p_event_class_rec.TAX_USE_LOC_EXC_RATE_FLAG   :=      l_zx_product_options_rec.tax_use_loc_exc_rate_flag;
        p_event_class_rec.TAX_ALLOW_COMPOUND_FLAG   :=        l_zx_product_options_rec.tax_allow_compound_flag;
        p_event_class_rec.USE_TAX_CLASSIFICATION_FLAG   :=    l_zx_product_options_rec.use_tax_classification_flag;
        p_event_class_rec.ALLOW_TAX_ROUNDING_OVRD_FLAG   :=   l_zx_product_options_rec.allow_tax_rounding_ovrd_flag;
        p_event_class_rec.HOME_COUNTRY_DEFAULT_FLAG    :=     l_zx_product_options_rec.home_country_default_flag;
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.END',
                   G_PKG_NAME||': '||l_api_name||'()-'||
                   ', RETURN_STATUS = ' || x_return_status);
    END IF;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
        END IF;
  END populate_appl_product_options;

----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  Get_Tax_Event_Class
--
--  DESCRIPTION
--  Fetch the tax event class code and reference application id
--
--  CALLED BY
--   reverse_document
--   reverse_distributions
--   override_recovery
--   freeze_distribution_lines
--   validate_document_for_tax
-----------------------------------------------------------------------
  PROCEDURE get_tax_event_class
  ( x_return_status             OUT  NOCOPY  VARCHAR2 ,
    p_appln_id                  IN           NUMBER,
    p_entity_code               IN           VARCHAR2,
    p_evnt_cls_code             IN           VARCHAR2,
    x_tx_evnt_cls_code          OUT  NOCOPY  VARCHAR2,
    x_ref_appln_id              OUT  NOCOPY  NUMBER,
    x_record_flag               OUT  NOCOPY  VARCHAR2,   -- Bug 5200373
    x_record_for_partners_flag  OUT  NOCOPY  VARCHAR2,   -- Bug 5200373
    x_prod_family_grp_code      OUT  NOCOPY  VARCHAR2,   -- Bug 5200373
    x_event_class_mapping_id    OUT  NOCOPY  NUMBER ,     -- Bug 5200373
    x_summarization_flag        OUT NOCOPY   VARCHAR2
  )IS
  l_api_name            CONSTANT VARCHAR2(30) := 'GET_TAX_EVENT_CLASS';
  l_index   binary_integer;

  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

   /*
    SELECT tax_event_class_code,
           reference_application_id,
           record_flag,                 -- Bug 5200373
           record_for_partners_flag,    -- Bug 5200373
           prod_family_grp_code,        -- Bug 5200373
           event_class_mapping_id,
           summarization_flag        -- Bug 5200373
      INTO x_tx_evnt_cls_code,
           x_ref_appln_id,
           x_record_flag,               -- Bug 5200373
           x_record_for_partners_flag,  -- Bug 5200373
           x_prod_family_grp_code,      -- Bug 5200373
           x_event_class_mapping_id,     -- Bug 5200373
           x_summarization_flag
      FROM ZX_EVNT_CLS_MAPPINGS
     WHERE event_class_code = p_evnt_cls_code
       AND application_id   = p_appln_id
       AND entity_code      = p_entity_code;
   */

   get_event_class_info(
     P_ENTITY_CODE         =>  p_entity_code,
     P_EVENT_CLASS_CODE    =>  p_evnt_cls_code,
     P_APPLICATION_ID      =>  p_appln_id,
     X_TBL_INDEX           =>  l_index,
     X_RETURN_STATUS       =>  x_return_status);

    IF L_INDEX IS NULL THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,
           'The event class information passed is incorrect. Please CHECK! '||SQLERRM);
      END IF;

    ELSE

      x_tx_evnt_cls_code         :=  ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).tax_event_class_code;
      x_ref_appln_id             :=  ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).reference_application_id;
      x_record_flag              :=  ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).record_flag;
      x_record_for_partners_flag :=  ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).record_for_partners_flag;
      x_prod_family_grp_code     :=  ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).prod_family_grp_code;
      x_event_class_mapping_id   :=  ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).event_class_mapping_id;
      x_summarization_flag       :=  ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).summarization_flag;

    END IF;


    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||
                   '.END',G_PKG_NAME||': '||l_api_name||'()-' ||
                   ', RETURN_STATUS = ' || x_return_status);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,
           'The event class information passed is incorrect. Please CHECK! '||SQLERRM);
      END IF;
  END get_tax_event_class;

----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  Get_Tax_Event_Class
--
--  DESCRIPTION
--  Fetch the relevant events information from zx_evnt_cls_mappings
--
--  CALLED BY
--   calculate_tax
--   import_document_with_tax
--   override_tax
--   determine_recovery
--   insupd_line_det_factors
-----------------------------------------------------------------------
  PROCEDURE get_tax_event_class
  ( x_return_status 	OUT    NOCOPY  VARCHAR2,
    p_event_class_rec   IN OUT NOCOPY  ZX_API_PUB.event_class_rec_type
  )IS
  l_api_name          CONSTANT VARCHAR2(30):= 'GET_TAX_EVENT_CLASS';
  l_index             BINARY_INTEGER;

  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_event_class_rec.event_class_code = 'SALES_TRANSACTION_TAX_QUOTE' THEN
      SELECT 0,
       	     zxevntclsmap.tax_event_class_code,
             zxevntclsmap.det_factor_templ_code,
             zxevntclsmap.default_rounding_level_code,
             zxevntclsmap.rounding_level_hier_1_code,
             zxevntclsmap.rounding_level_hier_2_code,
             zxevntclsmap.rounding_level_hier_3_code,
             zxevntclsmap.rounding_level_hier_4_code,
             'N',                                        --allow_manual_lin_recalc_flag
             'N',                                        --allow_override_flag,
             'N',                                        --allow_manual_lines_flag,
             'N',                                        --perf_addnl_appl_for_imprt_flag,
             'N',                                        --record_flag
             'THIRD_PARTY',                              --ship_to_party_type
             'LEGAL_ESTABLISHMENT',                      --ship_from_party_type
             'THIRD_PARTY',                              --bill_to_party_type
             'LEGAL_ESTABLISHMENT',                      --bill_from_party_type
             'THIRD_PARTY_SITE',                         --ship_to_pty_site_type
             'THIRD_PARTY_SITE',                         --bill_to_pty_site_type
             'N',                                        --enforce_tax_from_acct_flag,
              null,                                      --offset_tax_basis_code
             'N',                                        --allow_offset_tax_calc_flag
             'N',                                        --self_assess_tax_lines_flag
             'N',                                        --tax_recovery_flag
             'N',                                        --allow_cancel_tax_lines_flag
             'N',                                        --allow_man_tax_only_lines_flag
             'N',                                        --enable_mrc_flag
             'N',                                        --tax_reporting_flag,
             'N',                                        --enter_ovrd_incl_tax_lines_flag
             'N',                                        --ctrl_eff_ovrd_calc_lines_flag
             'N',                                        --summarization_flag
             'N',                                        --retain_summ_tax_line_id_flag
             'N',                                        --tax_variance_calc_flag
             'O2C',                                      --prod_family_grp_code
             'N',                                        --record_for_partners_flag
             'N',                                        --manual_lines_for_partner_flag
             'N',                                        --man_tax_only_lin_for_ptnr_flag
             'N',                                        --always_use_ebtax_for_calc_flag
             'N',                                        --enforce_tax_from_ref_doc_flag
             zxevntclsmap.process_for_applicability_flag,
             zxevntclsmap.allow_exemptions_flag,         --allow_exemptions_flag
             zxevntclsmap.sup_cust_acct_type_code,
             'N',                                        --intgrtn_det_factors_ui_flag
             'N',                                         --display_tax_classif_flag
             zxcls.asc_intrcmp_tx_evnt_cls_code,
             zxevntclsmap.intrcmp_tx_evnt_cls_code,
             zxevntclsmap.intrcmp_src_appln_id,
             zxevntclsmap.intrcmp_src_entity_code,
             zxevntclsmap.intrcmp_src_evnt_cls_code
      INTO   p_event_class_rec.event_class_mapping_id,
             p_event_class_rec.tax_event_class_code,
             p_event_class_rec.det_factor_templ_code,
             p_event_class_rec.default_rounding_level_code,
             p_event_class_rec.rounding_level_hier_1_code,
             p_event_class_rec.rounding_level_hier_2_code,
             p_event_class_rec.rounding_level_hier_3_code,
             p_event_class_rec.rounding_level_hier_4_code,
             p_event_class_rec.allow_manual_lin_recalc_flag,
             p_event_class_rec.allow_override_flag,
             p_event_class_rec.allow_manual_lines_flag,
             p_event_class_rec.perf_addnl_appl_for_imprt_flag,
             p_event_class_rec.record_flag,
             source_rec.ship_to_party_type,
             source_rec.ship_from_party_type,
             source_rec.bill_to_party_type,
             source_rec.bill_from_party_type,
             source_rec.ship_to_pty_site_type,
             source_rec.bill_to_pty_site_type,
             p_event_class_rec.enforce_tax_from_acct_flag,
             p_event_class_rec.offset_tax_basis_code ,
             p_event_class_rec.allow_offset_tax_calc_flag,
             p_event_class_rec.self_assess_tax_lines_flag,
             p_event_class_rec.tax_recovery_flag,
             p_event_class_rec.allow_cancel_tax_lines_flag,
             p_event_class_rec.allow_man_tax_only_lines_flag,
             p_event_class_rec.enable_mrc_flag,
             p_event_class_rec.tax_reporting_flag,
             p_event_class_rec.enter_ovrd_incl_tax_lines_flag,
             p_event_class_rec.ctrl_eff_ovrd_calc_lines_flag,
             p_event_class_rec.summarization_flag,
             p_event_class_rec.retain_summ_tax_line_id_flag,
             p_event_class_rec.tax_variance_calc_flag,
             p_event_class_rec.prod_family_grp_code,
             p_event_class_rec.record_for_partners_flag,
             p_event_class_rec.manual_lines_for_partner_flag,
             p_event_class_rec.man_tax_only_lin_for_ptnr_flag,
             p_event_class_rec.always_use_ebtax_for_calc_flag,
             p_event_class_rec.enforce_tax_from_ref_doc_flag,
             p_event_class_rec.process_for_applicability_flag,
             p_event_class_rec.allow_exemptions_flag,
             p_event_class_rec.sup_cust_acct_type,
             p_event_class_rec.intgrtn_det_factors_ui_flag,
             p_event_class_rec.display_tax_classif_flag,
             p_event_class_rec.asc_intrcmp_tx_evnt_cls_code,
             p_event_class_rec.intrcmp_tx_evnt_cls_code,
             p_event_class_rec.intrcmp_src_appln_id,
             p_event_class_rec.intrcmp_src_entity_code,
             p_event_class_rec.intrcmp_src_evnt_cls_code
      FROM   ZX_EVNT_CLS_MAPPINGS zxevntclsmap,
             ZX_EVENT_CLASSES_B zxcls
      WHERE  zxevntclsmap.event_class_code = 'INVOICE'
      AND    zxevntclsmap.application_id = 222
      AND    zxevntclsmap.entity_code = 'TRANSACTIONS'
      AND    zxevntclsmap.tax_event_class_code = zxcls.tax_event_class_code ;
    ELSIF p_event_class_rec.event_class_code = 'PURCHASE_TRANSACTION_TAX_QUOTE' THEN
      SELECT -1,
       	     zxevntclsmap.tax_event_class_code,
             zxevntclsmap.det_factor_templ_code,
             zxevntclsmap.default_rounding_level_code,
             zxevntclsmap.rounding_level_hier_1_code,
             zxevntclsmap.rounding_level_hier_2_code,
             zxevntclsmap.rounding_level_hier_3_code,
             zxevntclsmap.rounding_level_hier_4_code,
             'N',                                        --allow_manual_lin_recalc_flag
             'N',                                        --allow_override_flag,
             'N',                                        --allow_manual_lines_flag,
             'N',                                        --perf_addnl_appl_for_imprt_flag,
             'N',                                        --record_flag
             'LEGAL_ESTABLISHMENT',                      --ship_to_party_type
             'THIRD_PARTY',                              --ship_from_party_type
             'LEGAL_ESTABLISHMENT',                      --bill_to_party_type
             'THIRD_PARTY',                              --bill_from_party_type
             'THIRD_PARTY_SITE',                         --ship_from_pty_site_type
             'THIRD_PARTY_SITE',                         --bill_from_pty_site_type
             'N',                                        --enforce_tax_from_acct_flag,
              null,                                      --offset_tax_basis_code
             'N',                                        --allow_offset_tax_calc_flag
             'N',                                        --self_assess_tax_lines_flag
             DECODE(p_event_class_rec.application_id,'8407','Y','N'),                                        --tax_recovery_flag //Added decode logic for bug 6751638
             'N',                                        --allow_cancel_tax_lines_flag
             'N',                                        --allow_man_tax_only_lines_flag
             'N',                                        --enable_mrc_flag
             'N',                                        --tax_reporting_flag,
             'N',                                        --enter_ovrd_incl_tax_lines_flag
             'N',                                        --ctrl_eff_ovrd_calc_lines_flag
             'N',                                        --summarization_flag
             'N',                                        --retain_summ_tax_line_id_flag
             'N',                                        --tax_variance_calc_flag
             'P2P',                                      --prod_family_grp_code
             'N',                                        --record_for_partners_flag
             'N',                                        --manual_lines_for_partner_flag
             'N',                                        --man_tax_only_lin_for_ptnr_flag
             'N',                                        --always_use_ebtax_for_calc_flag
             'N',                                        --enforce_tax_from_ref_doc_flag
             zxevntclsmap.process_for_applicability_flag,
             zxevntclsmap.allow_exemptions_flag,         --allow_exemptions_flag
             zxevntclsmap.sup_cust_acct_type_code,
             'N',                                        --intgrtn_det_factors_ui_flag
             'N',                                        --display_tax_classif_flag
             zxcls.asc_intrcmp_tx_evnt_cls_code,
             zxevntclsmap.intrcmp_tx_evnt_cls_code,
             zxevntclsmap.intrcmp_src_appln_id,
             zxevntclsmap.intrcmp_src_entity_code,
             zxevntclsmap.intrcmp_src_evnt_cls_code
      INTO   p_event_class_rec.event_class_mapping_id,
             p_event_class_rec.tax_event_class_code,
             p_event_class_rec.det_factor_templ_code,
             p_event_class_rec.default_rounding_level_code,
             p_event_class_rec.rounding_level_hier_1_code,
             p_event_class_rec.rounding_level_hier_2_code,
             p_event_class_rec.rounding_level_hier_3_code,
             p_event_class_rec.rounding_level_hier_4_code,
             p_event_class_rec.allow_manual_lin_recalc_flag,
             p_event_class_rec.allow_override_flag,
             p_event_class_rec.allow_manual_lines_flag,
             p_event_class_rec.perf_addnl_appl_for_imprt_flag,
             p_event_class_rec.record_flag,
             source_rec.ship_to_party_type,
             source_rec.ship_from_party_type,
             source_rec.bill_to_party_type,
             source_rec.bill_from_party_type,
             source_rec.ship_from_pty_site_type,
             source_rec.bill_from_pty_site_type,
             p_event_class_rec.enforce_tax_from_acct_flag,
             p_event_class_rec.offset_tax_basis_code ,
             p_event_class_rec.allow_offset_tax_calc_flag,
             p_event_class_rec.self_assess_tax_lines_flag,
             p_event_class_rec.tax_recovery_flag,
             p_event_class_rec.allow_cancel_tax_lines_flag,
             p_event_class_rec.allow_man_tax_only_lines_flag,
             p_event_class_rec.enable_mrc_flag,
             p_event_class_rec.tax_reporting_flag,
             p_event_class_rec.enter_ovrd_incl_tax_lines_flag,
             p_event_class_rec.ctrl_eff_ovrd_calc_lines_flag,
             p_event_class_rec.summarization_flag,
             p_event_class_rec.retain_summ_tax_line_id_flag,
             p_event_class_rec.tax_variance_calc_flag,
             p_event_class_rec.prod_family_grp_code,
             p_event_class_rec.record_for_partners_flag,
             p_event_class_rec.manual_lines_for_partner_flag,
             p_event_class_rec.man_tax_only_lin_for_ptnr_flag,
             p_event_class_rec.always_use_ebtax_for_calc_flag,
             p_event_class_rec.enforce_tax_from_ref_doc_flag,
             p_event_class_rec.process_for_applicability_flag,
             p_event_class_rec.allow_exemptions_flag,
             p_event_class_rec.sup_cust_acct_type,
             p_event_class_rec.intgrtn_det_factors_ui_flag,
             p_event_class_rec.display_tax_classif_flag,
             p_event_class_rec.asc_intrcmp_tx_evnt_cls_code,
             p_event_class_rec.intrcmp_tx_evnt_cls_code,
             p_event_class_rec.intrcmp_src_appln_id,
             p_event_class_rec.intrcmp_src_entity_code,
             p_event_class_rec.intrcmp_src_evnt_cls_code
      FROM   ZX_EVNT_CLS_MAPPINGS zxevntclsmap,
             ZX_EVENT_CLASSES_B zxcls
      WHERE  zxevntclsmap.entity_code = 'AP_INVOICES'
      AND    zxevntclsmap.application_id = 200
      AND    zxevntclsmap.event_class_code = 'STANDARD INVOICES'
      AND    zxevntclsmap.tax_event_class_code = zxcls.tax_event_class_code ;
  ELSE
   /*
     get_event_class_info(
        P_ENTITY_CODE         =>  p_event_class_rec.entity_code,
        P_EVENT_CLASS_CODE    =>  p_event_class_rec.event_class_code,
        P_APPLICATION_ID      =>  p_event_class_rec.application_id,
        X_TBL_INDEX           =>  l_index,
        X_RETURN_STATUS       =>  x_return_status);

     IF L_INDEX IS NULL THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,
           'The event class information passed is incorrect. Please CHECK! '||SQLERRM);
      END IF;

     ELSE

       p_event_class_rec.event_class_mapping_id  :=            ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).event_class_mapping_id;
       p_event_class_rec.tax_event_class_code  :=              ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).tax_event_class_code;
       p_event_class_rec.det_factor_templ_code  :=             ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).det_factor_templ_code;
       p_event_class_rec.default_rounding_level_code  :=       ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).default_rounding_level_code;
       p_event_class_rec.rounding_level_hier_1_code  :=        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).rounding_level_hier_1_code;
       p_event_class_rec.rounding_level_hier_2_code  :=        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).rounding_level_hier_2_code;
       p_event_class_rec.rounding_level_hier_3_code  :=        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).rounding_level_hier_3_code;
       p_event_class_rec.rounding_level_hier_4_code  :=        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).rounding_level_hier_4_code;
       p_event_class_rec.allow_manual_lin_recalc_flag  :=      ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).allow_manual_lin_recalc_flag;
       p_event_class_rec.allow_override_flag  :=               ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).allow_override_flag;
       p_event_class_rec.allow_manual_lines_flag  :=           ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).allow_manual_lines_flag;
       p_event_class_rec.perf_addnl_appl_for_imprt_flag  :=    ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).perf_addnl_appl_for_imprt_flag;
       p_event_class_rec.record_flag  :=                       ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).record_flag;
       source_rec.ship_to_party_type  :=                       ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ship_to_party_type;
       source_rec.ship_from_party_type  :=                     ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ship_from_party_type;
       source_rec.poa_party_type  :=                           ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).poa_party_type;
       source_rec.poo_party_type  :=                           ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).poo_party_type;
       source_rec.paying_party_type  :=                        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).paying_party_type;
       source_rec.own_hq_party_type  :=                        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).own_hq_party_type;
       source_rec.trad_hq_party_type  :=                       ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).trad_hq_party_type;
       source_rec.poi_party_type  :=                           ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).poi_party_type;
       source_rec.pod_party_type  :=                           ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).pod_party_type;
       source_rec.bill_to_party_type  :=                       ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).bill_to_party_type;
       source_rec.bill_from_party_type  :=                     ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).bill_from_party_type;
       source_rec.ttl_trns_party_type  :=                      ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ttl_trns_party_type;
       source_rec.ship_to_pty_site_type  :=                    ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ship_to_pty_site_type;
       source_rec.ship_from_pty_site_type  :=                  ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ship_from_pty_site_type;
       source_rec.poa_pty_site_type  :=                        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).poa_pty_site_type;
       source_rec.poo_pty_site_type  :=                        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).poo_pty_site_type;
       source_rec.paying_pty_site_type  :=                     ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).paying_pty_site_type;
       source_rec.own_hq_pty_site_type  :=                     ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).own_hq_pty_site_type;
       source_rec.trad_hq_pty_site_type  :=                    ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).trad_hq_pty_site_type;
       source_rec.poi_pty_site_type  :=                        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).poi_pty_site_type;
       source_rec.pod_pty_site_type  :=                        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).pod_pty_site_type;
       source_rec.bill_to_pty_site_type  :=                    ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).bill_to_pty_site_type;
       source_rec.bill_from_pty_site_type  :=                  ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).bill_from_pty_site_type;
       source_rec.ttl_trns_pty_site_type  :=                   ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ttl_trns_pty_site_type;
       source_rec.merchant_party_type  :=                      ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).merchant_party_type;
       p_event_class_rec.reference_application_id  :=          ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).reference_application_id;
       p_event_class_rec.enforce_tax_from_acct_flag  :=        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).enforce_tax_from_acct_flag;
       p_event_class_rec.offset_tax_basis_code   :=            ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).offset_tax_basis_code ;
       p_event_class_rec.allow_offset_tax_calc_flag  :=        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).allow_offset_tax_calc_flag;
       p_event_class_rec.self_assess_tax_lines_flag  :=        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).self_assess_tax_lines_flag;
       p_event_class_rec.tax_recovery_flag  :=                 ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).tax_recovery_flag;
       p_event_class_rec.allow_cancel_tax_lines_flag  :=       ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).allow_cancel_tax_lines_flag;
       p_event_class_rec.allow_man_tax_only_lines_flag  :=     ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).allow_man_tax_only_lines_flag;
       --p_event_class_rec.enable_mrc_flag  :=                   ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).enable_mrc_flag;
       p_event_class_rec.tax_reporting_flag  :=                ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).tax_reporting_flag;
       p_event_class_rec.enter_ovrd_incl_tax_lines_flag  :=    ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).enter_ovrd_incl_tax_lines_flag;
       p_event_class_rec.ctrl_eff_ovrd_calc_lines_flag  :=     ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ctrl_eff_ovrd_calc_lines_flag;
       p_event_class_rec.summarization_flag  :=                ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).summarization_flag;
       p_event_class_rec.retain_summ_tax_line_id_flag  :=      ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).retain_summ_tax_line_id_flag;
       p_event_class_rec.tax_variance_calc_flag  :=            ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).tax_variance_calc_flag;
       p_event_class_rec.prod_family_grp_code  :=              ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).prod_family_grp_code;
       p_event_class_rec.record_for_partners_flag  :=          ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).record_for_partners_flag;
       p_event_class_rec.manual_lines_for_partner_flag  :=     ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).manual_lines_for_partner_flag;
       p_event_class_rec.man_tax_only_lin_for_ptnr_flag  :=    ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).man_tax_only_lin_for_ptnr_flag;
       p_event_class_rec.always_use_ebtax_for_calc_flag  :=    ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).always_use_ebtax_for_calc_flag;
       p_event_class_rec.enforce_tax_from_ref_doc_flag  :=     ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).enforce_tax_from_ref_doc_flag;
       p_event_class_rec.process_for_applicability_flag  :=    ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).process_for_applicability_flag;
       p_event_class_rec.allow_exemptions_flag  :=             ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).allow_exemptions_flag;
       p_event_class_rec.sup_cust_acct_type  :=                ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).sup_cust_acct_type_code;
       p_event_class_rec.intgrtn_det_factors_ui_flag  :=       ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).intgrtn_det_factors_ui_flag;
       p_event_class_rec.display_tax_classif_flag  :=          ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).display_tax_classif_flag;
       p_event_class_rec.intrcmp_tx_evnt_cls_code  :=          ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).intrcmp_tx_evnt_cls_code;
       p_event_class_rec.intrcmp_src_appln_id  :=              ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).intrcmp_src_appln_id;
       p_event_class_rec.intrcmp_src_entity_code  :=           ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).intrcmp_src_entity_code;
       p_event_class_rec.intrcmp_src_evnt_cls_code :=          ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).intrcmp_src_evnt_cls_code;

       IF  ZX_GLOBAL_STRUCTURES_PKG.g_zx_tax_evnt_cls_tbl.exists(p_event_class_rec.tax_event_class_code) THEN
          p_event_class_rec.normal_sign_flag  :=
                    ZX_GLOBAL_STRUCTURES_PKG.g_zx_tax_evnt_cls_tbl(p_event_class_rec.tax_event_class_code).normal_sign_flag;
          p_event_class_rec.asc_intrcmp_tx_evnt_cls_code  :=
                    ZX_GLOBAL_STRUCTURES_PKG.g_zx_tax_evnt_cls_tbl(p_event_class_rec.tax_event_class_code).asc_intrcmp_tx_evnt_cls_code;
       ELSE
          populate_tax_event_class_info;
          p_event_class_rec.normal_sign_flag  :=
                    ZX_GLOBAL_STRUCTURES_PKG.g_zx_tax_evnt_cls_tbl(p_event_class_rec.tax_event_class_code).normal_sign_flag;
          p_event_class_rec.asc_intrcmp_tx_evnt_cls_code  :=
                    ZX_GLOBAL_STRUCTURES_PKG.g_zx_tax_evnt_cls_tbl(p_event_class_rec.tax_event_class_code).asc_intrcmp_tx_evnt_cls_code;
       END IF;
    END IF; -- l_index is NULL
    */
        SELECT zxevntclsmap.event_class_mapping_id,
       	     zxevntclsmap.tax_event_class_code,
             zxevntclsmap.det_factor_templ_code,
             zxevntclsmap.default_rounding_level_code,
             zxevntclsmap.rounding_level_hier_1_code,
             zxevntclsmap.rounding_level_hier_2_code,
             zxevntclsmap.rounding_level_hier_3_code,
             zxevntclsmap.rounding_level_hier_4_code,
             zxevntclsmap.allow_manual_lin_recalc_flag,
             zxevntclsmap.allow_override_flag,
             zxevntclsmap.allow_manual_lines_flag,
             zxevntclsmap.perf_addnl_appl_for_imprt_flag,
             zxcls.normal_sign_flag,
             zxevntclsmap.record_flag,
             zxevntclsmap.ship_to_party_type,
             zxevntclsmap.ship_from_party_type,
             zxevntclsmap.poa_party_type,
             zxevntclsmap.poo_party_type,
             zxevntclsmap.paying_party_type,
             zxevntclsmap.own_hq_party_type,
             zxevntclsmap.trad_hq_party_type,
             zxevntclsmap.poi_party_type,
             zxevntclsmap.pod_party_type,
             zxevntclsmap.bill_to_party_type,
             zxevntclsmap.bill_from_party_type,
             zxevntclsmap.ttl_trns_party_type,
             zxevntclsmap.ship_to_pty_site_type,
             zxevntclsmap.ship_from_pty_site_type,
             zxevntclsmap.poa_pty_site_type,
             zxevntclsmap.poo_pty_site_type,
             zxevntclsmap.paying_pty_site_type,
             zxevntclsmap.own_hq_pty_site_type,
             zxevntclsmap.trad_hq_pty_site_type,
             zxevntclsmap.poi_pty_site_type,
             zxevntclsmap.pod_pty_site_type,
             zxevntclsmap.bill_to_pty_site_type,
             zxevntclsmap.bill_from_pty_site_type,
             zxevntclsmap.ttl_trns_pty_site_type,
             zxevntclsmap.merchant_party_type,
             zxevntclsmap.reference_application_id,
             zxevntclsmap.enforce_tax_from_acct_flag,
             zxevntclsmap.offset_tax_basis_code ,
             zxevntclsmap.allow_offset_tax_calc_flag,
             zxevntclsmap.self_assess_tax_lines_flag,
             zxevntclsmap.tax_recovery_flag,
             zxevntclsmap.allow_cancel_tax_lines_flag,
             zxevntclsmap.allow_man_tax_only_lines_flag,
             zxevntclsmap.enable_mrc_flag,
             zxevntclsmap.tax_reporting_flag,
             zxevntclsmap.enter_ovrd_incl_tax_lines_flag,
             zxevntclsmap.ctrl_eff_ovrd_calc_lines_flag,
             zxevntclsmap.summarization_flag,
             zxevntclsmap.retain_summ_tax_line_id_flag,
             zxevntclsmap.tax_variance_calc_flag,
             zxevntclsmap.prod_family_grp_code,
             zxevntclsmap.record_for_partners_flag,
             zxevntclsmap.manual_lines_for_partner_flag,
             zxevntclsmap.man_tax_only_lin_for_ptnr_flag,
             zxevntclsmap.always_use_ebtax_for_calc_flag,
             zxevntclsmap.enforce_tax_from_ref_doc_flag,
             zxevntclsmap.process_for_applicability_flag,
             zxevntclsmap.allow_exemptions_flag,
             zxevntclsmap.sup_cust_acct_type_code,
             zxevntclsmap.intgrtn_det_factors_ui_flag,
             zxevntclsmap.display_tax_classif_flag,
             zxcls.asc_intrcmp_tx_evnt_cls_code,
             zxevntclsmap.intrcmp_tx_evnt_cls_code,
             zxevntclsmap.intrcmp_src_appln_id,
             zxevntclsmap.intrcmp_src_entity_code,
             zxevntclsmap.intrcmp_src_evnt_cls_code
      INTO   p_event_class_rec.event_class_mapping_id,
             p_event_class_rec.tax_event_class_code,
             p_event_class_rec.det_factor_templ_code,
             p_event_class_rec.default_rounding_level_code,
             p_event_class_rec.rounding_level_hier_1_code,
             p_event_class_rec.rounding_level_hier_2_code,
             p_event_class_rec.rounding_level_hier_3_code,
             p_event_class_rec.rounding_level_hier_4_code,
             p_event_class_rec.allow_manual_lin_recalc_flag,
             p_event_class_rec.allow_override_flag,
             p_event_class_rec.allow_manual_lines_flag,
             p_event_class_rec.perf_addnl_appl_for_imprt_flag,
             p_event_class_rec.normal_sign_flag,
             p_event_class_rec.record_flag,
             source_rec.ship_to_party_type,
             source_rec.ship_from_party_type,
             source_rec.poa_party_type,
             source_rec.poo_party_type,
             source_rec.paying_party_type,
             source_rec.own_hq_party_type,
             source_rec.trad_hq_party_type,
             source_rec.poi_party_type,
             source_rec.pod_party_type,
             source_rec.bill_to_party_type,
             source_rec.bill_from_party_type,
             source_rec.ttl_trns_party_type,
             source_rec.ship_to_pty_site_type,
             source_rec.ship_from_pty_site_type,
             source_rec.poa_pty_site_type,
             source_rec.poo_pty_site_type,
             source_rec.paying_pty_site_type,
             source_rec.own_hq_pty_site_type,
             source_rec.trad_hq_pty_site_type,
             source_rec.poi_pty_site_type,
             source_rec.pod_pty_site_type,
             source_rec.bill_to_pty_site_type,
             source_rec.bill_from_pty_site_type,
             source_rec.ttl_trns_pty_site_type,
             source_rec.merchant_party_type,
             p_event_class_rec.reference_application_id,
             p_event_class_rec.enforce_tax_from_acct_flag,
             p_event_class_rec.offset_tax_basis_code ,
             p_event_class_rec.allow_offset_tax_calc_flag,
             p_event_class_rec.self_assess_tax_lines_flag,
             p_event_class_rec.tax_recovery_flag,
             p_event_class_rec.allow_cancel_tax_lines_flag,
             p_event_class_rec.allow_man_tax_only_lines_flag,
             p_event_class_rec.enable_mrc_flag,
             p_event_class_rec.tax_reporting_flag,
             p_event_class_rec.enter_ovrd_incl_tax_lines_flag,
             p_event_class_rec.ctrl_eff_ovrd_calc_lines_flag,
             p_event_class_rec.summarization_flag,
             p_event_class_rec.retain_summ_tax_line_id_flag,
             p_event_class_rec.tax_variance_calc_flag,
             p_event_class_rec.prod_family_grp_code,
             p_event_class_rec.record_for_partners_flag,
             p_event_class_rec.manual_lines_for_partner_flag,
             p_event_class_rec.man_tax_only_lin_for_ptnr_flag,
             p_event_class_rec.always_use_ebtax_for_calc_flag,
             p_event_class_rec.enforce_tax_from_ref_doc_flag,
             p_event_class_rec.process_for_applicability_flag,
             p_event_class_rec.allow_exemptions_flag,
             p_event_class_rec.sup_cust_acct_type,
             p_event_class_rec.intgrtn_det_factors_ui_flag,
             p_event_class_rec.display_tax_classif_flag,
             p_event_class_rec.asc_intrcmp_tx_evnt_cls_code,
             p_event_class_rec.intrcmp_tx_evnt_cls_code,
             p_event_class_rec.intrcmp_src_appln_id,
             p_event_class_rec.intrcmp_src_entity_code,
             p_event_class_rec.intrcmp_src_evnt_cls_code
      FROM   ZX_EVNT_CLS_MAPPINGS zxevntclsmap,
             ZX_EVENT_CLASSES_B zxcls
      WHERE  zxevntclsmap.event_class_code = p_event_class_rec.event_class_code
      AND    zxevntclsmap.application_id = p_event_class_rec.application_id
      AND    zxevntclsmap.entity_code = p_event_class_rec.entity_code
      AND    zxevntclsmap.tax_event_class_code = zxcls.tax_event_class_code ;


  END IF;  -- p_event_class_rec.event_class_code = 'SALES_TRANSACTION_TAX_QUOTE

    --Bug 4670938:populate the source_event_class_mapping_id for rules engine processing
    BEGIN
      IF (ZX_API_PUB.G_DATA_TRANSFER_MODE =  'WIN' AND ZX_API_PUB.G_PUB_SRVC ='CALCULATE_TAX')
 -- for recovery determination this logic is not needed
 --                OR (ZX_API_PUB.G_PUB_SRVC ='DETERMINE_RECOVERY')
      THEN
        SELECT mapp.event_class_mapping_id,
               mapp.tax_event_class_code,
               mapp.process_for_applicability_flag
          INTO p_event_class_rec.source_event_class_mapping_id,
               p_event_class_rec.source_tax_event_class_code,
               p_event_class_rec.source_process_for_appl_flag
          FROM zx_evnt_cls_mappings mapp,
               zx_lines_det_factors det
         WHERE mapp.application_id   = det.source_application_id
           AND mapp.entity_code      = det.source_entity_code
           AND mapp.event_class_code = det.source_event_class_code
           AND det.trx_id            = p_event_class_rec.trx_id
           AND det.application_id    = p_event_class_rec.application_id
           AND det.entity_code       = p_event_class_rec.entity_code
           AND det.event_class_code  = p_event_class_rec.event_class_code
           AND rownum=1;
      ELSIF ZX_API_PUB.G_DATA_TRANSFER_MODE =  'PLS' AND ZX_API_PUB.G_PUB_SRVC ='CALCULATE_TAX' THEN
        SELECT mapp.event_class_mapping_id,
               mapp.tax_event_class_code,
               mapp.process_for_applicability_flag
          INTO p_event_class_rec.source_event_class_mapping_id,
               p_event_class_rec.source_tax_event_class_code,
               p_event_class_rec.source_process_for_appl_flag
          FROM zx_evnt_cls_mappings mapp
         WHERE mapp.application_id   = zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_APPLICATION_ID(1)
           AND mapp.entity_code      = zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_ENTITY_CODE(1)
           AND mapp.event_class_code = zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_EVENT_CLASS_CODE(1);

     -- When the data transfer mode is TAB, the logic
     -- to populate  p_event_class_rec.source* columns
     -- is moved to service types pkg as it requires trx_id

      END IF;
      EXCEPTION
        WHEN OTHERS THEN
          null;
    END;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||
                   '.END',G_PKG_NAME||': '||l_api_name||'()-'||
                   ', RETURN_STATUS = ' || x_return_status);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,
           'The event class information passed is incorrect. Please CHECK! ' ||
           SQLERRM);
      END IF;
  END get_tax_event_class;

----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  Get_Tax_Event_Type
--
--  DESCRIPTION
--  Fetch the tax event type information
--
--  CALLED BY
--   calculate_tax
--   import_document_with_tax
--   override_tax
--   determine_recovery
--   global_document_update
--   override_recovery
--   freeze_distribution_lines
--   validate_document_for_tax
-----------------------------------------------------------------------
  PROCEDURE Get_Tax_Event_Type
  ( x_return_status    OUT NOCOPY VARCHAR2,
    p_evnt_cls_code    IN         VARCHAR2,
    p_appln_id         IN         NUMBER,
    p_entity_code      IN         VARCHAR2,
    p_evnt_typ_code    IN         VARCHAR2,
    p_tx_evnt_cls_code IN         VARCHAR2,
    x_tx_evnt_typ_code OUT NOCOPY VARCHAR2,
    x_doc_status       OUT NOCOPY VARCHAR2
  )IS
  l_api_name              CONSTANT VARCHAR2(30) := 'GET_TAX_EVENT_TYPE';
  l_index    BINARY_INTEGER;
  l_index2   BINARY_INTEGER;

  l_tax_event_type_code   ZX_EVNT_TYP_MAPPINGS.TAX_EVENT_CLASS_CODE%TYPE;

  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;


       get_event_typ_mappings_info(
        P_ENTITY_CODE         =>  p_entity_code,
        P_EVENT_CLASS_CODE    =>  p_evnt_cls_code,
        P_APPLICATION_ID      =>  p_appln_id,
        P_EVENT_TYPE_CODE     =>  p_evnt_typ_code,
        X_TBL_INDEX           =>  l_index,
        X_RETURN_STATUS       =>  x_return_status);

        IF  l_index is NULL then

              IF p_evnt_cls_code in ('SALES_TRANSACTION_TAX_QUOTE','PURCHASE_TRANSACTION_TAX_QUOTE') THEN
                 x_tx_evnt_typ_code:='CREATE';
              ELSE
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                     ' Incorrect event information passed in for event type :' ||p_evnt_typ_code ||' Please Check!');
                END IF;
              END IF;

        ELSE
              x_tx_evnt_typ_code := ZX_GLOBAL_STRUCTURES_PKG.g_zx_evnt_typ_map_tbl(l_index).tax_event_type_code;
              l_tax_event_type_code  := ZX_GLOBAL_STRUCTURES_PKG.g_zx_evnt_typ_map_tbl(l_index).tax_event_type_code;

              l_index2 :=  dbms_utility.get_hash_value(p_tx_evnt_cls_code ||l_tax_event_type_code,
                                                   1,8192);

              IF ZX_GLOBAL_STRUCTURES_PKG.g_zx_evnt_cls_typs_tbl.exists(l_index2) THEN

                  x_doc_status := ZX_GLOBAL_STRUCTURES_PKG.g_zx_evnt_cls_typs_tbl(l_index2);

              ELSE
                   populate_event_cls_typs;

                   IF ZX_GLOBAL_STRUCTURES_PKG.g_zx_evnt_cls_typs_tbl.exists(l_index2) THEN
                        x_doc_status := ZX_GLOBAL_STRUCTURES_PKG.g_zx_evnt_cls_typs_tbl(l_index2);
                   ELSE
                        IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
                              FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,
                              ' Unable to derive doc_event_status. Please Check!');
                        END IF;
                   END IF;
              END IF;

         END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||
            '.END',G_PKG_NAME||': '||l_api_name||'()-'||
            ', Tax Event Type = ' || x_tx_evnt_typ_code ||
            ', Doc Event Status = ' || x_doc_status ||
            ', RETURN_STATUS = ' || x_return_status);

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
  END get_tax_event_type;


----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_tax_subscriber
--
--  DESCRIPTION
--  Determine the first party org id
--
--  CALLED BY
--   calculate_tax
--   import_document_with_tax
--   inspud_line_det_factors
--   get_default_tax_det_attribs(GTT version)
-----------------------------------------------------------------------
  PROCEDURE get_tax_subscriber
  ( p_event_class_rec      IN OUT NOCOPY      ZX_API_PUB.event_class_rec_type,
    p_effective_date       IN                 DATE,
    x_return_status        OUT    NOCOPY      VARCHAR2
  )IS
  l_api_name             CONSTANT VARCHAR2(30):= 'GET_TAX_SUBSCRIBER';
  l_return_status        VARCHAR2(30);
  l_context_info_rec     ZX_API_PUB.context_info_rec_type;
  l_first_pty_org_id     NUMBER;

  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    l_first_pty_org_id := ZX_SECURITY.G_FIRST_PARTY_ORG_ID ;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    ZX_SECURITY.set_security_context(p_event_class_rec.legal_entity_id,
                                     p_event_class_rec.internal_organization_id,
                                     p_effective_date,
                                     l_return_status
                                     );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        l_context_info_rec.APPLICATION_ID   := p_event_class_rec.APPLICATION_ID;
        l_context_info_rec.ENTITY_CODE      := p_event_class_rec.ENTITY_CODE;
        l_context_info_rec.EVENT_CLASS_CODE := p_event_class_rec.EVENT_CLASS_CODE;
        l_context_info_rec.TRX_ID           := p_event_class_rec.TRX_ID;
        ZX_API_PUB.add_msg(p_context_info_rec  =>  l_context_info_rec);
      END IF;
      RETURN;
    END IF;

    IF nvl(l_first_pty_org_id,-1087) <> nvl(ZX_SECURITY.G_FIRST_PARTY_ORG_ID,-1087) THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                'First Party org_id has changed. Old first_pty_org_id = '||to_char(l_first_pty_org_id)||
                ', New first_pty_org_id = '||to_char(ZX_SECURITY.G_FIRST_PARTY_ORG_ID)||
                '. Initializing Tax, Status and Rate cache..');
        END IF;
         ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl.delete;
         ZX_TDS_UTILITIES_PKG.g_tax_status_info_tbl.delete;
         ZX_TDS_UTILITIES_PKG.g_tax_rate_info_tbl.delete;
         ZX_TDS_UTILITIES_PKG.g_tax_rate_info_ind_by_hash.delete;

    END IF;

    p_event_class_rec.first_pty_org_id := ZX_SECURITY.G_FIRST_PARTY_ORG_ID ;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||
         '.END',G_PKG_NAME||': '||l_api_name||'()-'||
         ', RETURN_STATUS = ' || l_return_status);
    END IF;
  END get_tax_subscriber;


----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_tax_subscriber
--
--  DESCRIPTION
--  Overloaded version to determine the first party org id
--
--  CALLED BY
--   override_tax
--   global_document_update
--   determine_recovery
--   override_recovery
--   freeze_distribution_lines
--   validate_document_for_tax
-----------------------------------------------------------------------
  PROCEDURE get_tax_subscriber
  ( p_event_class_rec  IN OUT NOCOPY ZX_API_PUB.event_class_rec_type,
    x_return_status    OUT    NOCOPY VARCHAR2
  )IS
  l_api_name            CONSTANT  VARCHAR2(30) := 'GET_TAX_SUBSCRIBER';
  l_effective_date                DATE;
  l_related_doc_date              DATE;
  l_adjusted_doc_date             DATE;
  l_trx_date                      DATE;
  l_prov_tax_det_date             DATE;
  l_return_status                 VARCHAR2(30);
  l_upg_trx_info_rec              ZX_ON_FLY_TRX_UPGRADE_PKG.zx_upg_trx_info_rec_type;
  l_context_info_rec              ZX_API_PUB.context_info_rec_type;

  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
      SELECT first_pty_org_id ,
             related_doc_date,
             adjusted_doc_date,
             trx_date,
             provnl_tax_determination_date
      INTO   p_event_class_rec.first_pty_org_id,
             l_related_doc_date,
             l_adjusted_doc_date,
             l_trx_date,
             l_prov_tax_det_date
      FROM   ZX_LINES_DET_FACTORS
      WHERE  application_id   = p_event_class_rec.application_id
        AND  entity_code      = p_event_class_rec.entity_code
        AND  event_class_code = p_event_class_rec.event_class_code
        AND  trx_id           = p_event_class_rec.trx_id
        AND  rownum           = 1;

    --Bugfix 4486946 -Call on the fly upgrade if the transaction if not found
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               'Call on-the-fly upgrade since transaction does not exist in repository for trx id: '||to_char(p_event_class_rec.trx_id));
          END IF;
          l_upg_trx_info_rec.application_id   := p_event_class_rec.application_id;
          l_upg_trx_info_rec.entity_code      := p_event_class_rec.entity_code;
          l_upg_trx_info_rec.event_class_code := p_event_class_rec.event_class_code;
          l_upg_trx_info_rec.trx_id           := p_event_class_rec.trx_id;
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
          SELECT first_pty_org_id ,
                 related_doc_date,
                 adjusted_doc_date,
                 trx_date,
                 provnl_tax_determination_date
          INTO   p_event_class_rec.first_pty_org_id,
                 l_related_doc_date,
                 l_adjusted_doc_date,
                 l_trx_date,
                 l_prov_tax_det_date
           FROM  ZX_LINES_DET_FACTORS
          WHERE  application_id   = p_event_class_rec.application_id
            AND  entity_code      = p_event_class_rec.entity_code
            AND  event_class_code = p_event_class_rec.event_class_code
            AND  trx_id           = p_event_class_rec.trx_id
            AND  rownum           = 1;
    END;
    --Bugfix 4486946; on-the-fly upgrade end

    l_effective_date := get_effective_date (l_related_doc_date,
                                            l_prov_tax_det_date,
                                            l_adjusted_doc_date,
                                            l_trx_date
                                           );

    IF nvl(p_event_class_rec.first_pty_org_id,-1087) <> nvl(ZX_SECURITY.G_FIRST_PARTY_ORG_ID,-1087) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
                 'First Party org_id has changed. Old first_pty_org_id = '||to_char(ZX_SECURITY.G_FIRST_PARTY_ORG_ID)||
                 ', New first_pty_org_id = '||to_char(p_event_class_rec.first_pty_org_id)||
                 '. Initializing Tax, Status and Rate cache..');
         END IF;
          ZX_TDS_UTILITIES_PKG.g_tax_rec_tbl.delete;
          ZX_TDS_UTILITIES_PKG.g_tax_status_info_tbl.delete;
          ZX_TDS_UTILITIES_PKG.g_tax_rate_info_tbl.delete;
          ZX_TDS_UTILITIES_PKG.g_tax_rate_info_ind_by_hash.delete;

    END IF;



    ZX_SECURITY.set_security_context(p_event_class_rec.first_pty_org_id,
                                     l_effective_date,
                                     l_return_status
                                    );


    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        l_context_info_rec.APPLICATION_ID   := p_event_class_rec.APPLICATION_ID;
        l_context_info_rec.ENTITY_CODE      := p_event_class_rec.ENTITY_CODE;
        l_context_info_rec.EVENT_CLASS_CODE := p_event_class_rec.EVENT_CLASS_CODE;
        l_context_info_rec.TRX_ID           := p_event_class_rec.TRX_ID;
        ZX_API_PUB.add_msg(p_context_info_rec  =>  l_context_info_rec);
      END IF;
      RETURN;
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||
           '.END',G_PKG_NAME||': '||l_api_name||'()-' ||
           ', RETURN_STATUS = ' || l_return_status);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,
         'Data is expected to be in eBTax repository for this call. Please CHECK your sequence of calls to eBTax' ||
         SQLERRM);
      END IF;
  END get_tax_subscriber;

----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  set_security_context
--
--  DESCRIPTION
--  Call set security context directlyl; need not return to event class rec
--
--  CALLED BY
--   discard_tax_only_lines
--   mark_tax_lines_deleted
--   reverse_distributions
-----------------------------------------------------------------------
  PROCEDURE set_security_context
  ( p_application_id   IN         NUMBER,
    p_entity_code      IN         VARCHAR2,
    p_event_class_code IN         VARCHAR2,
    p_trx_id           IN         NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2
  )IS
  l_api_name          CONSTANT    VARCHAR2(30) := 'SET_SECURITY_CONTEXT';
  l_effective_date                DATE;
  l_related_doc_date              DATE;
  l_trx_date                      DATE;
  l_prov_tax_det_date             DATE;
  l_adjusted_doc_date             DATE;
  l_first_pty_org_id              NUMBER;
  l_return_status                 VARCHAR2(30);
  l_upg_trx_info_rec              ZX_ON_FLY_TRX_UPGRADE_PKG.zx_upg_trx_info_rec_type;
  l_context_info_rec              ZX_API_PUB.context_info_rec_type;

  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    BEGIN
      SELECT first_pty_org_id ,
             related_doc_date,
             adjusted_doc_date,
             trx_date,
             provnl_tax_determination_date
       INTO  l_first_pty_org_id,
             l_related_doc_date,
             l_adjusted_doc_date,
             l_trx_date,
             l_prov_tax_det_date
       FROM  ZX_LINES_DET_FACTORS
      WHERE  application_id = p_application_id
        AND  entity_code    = p_entity_code
        AND  event_class_code = p_event_class_code
        AND  trx_id = p_trx_id
        AND  rownum = 1;

    --Bugfix 4486946 -Call on the fly upgrade if the transaction if not found
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               'Call on-the-fly upgrade since transaction does not exist in repository for trx id: '||to_char(p_trx_id));
          END IF;
          l_upg_trx_info_rec.application_id   := p_application_id;
          l_upg_trx_info_rec.entity_code      := p_entity_code;
          l_upg_trx_info_rec.event_class_code := p_event_class_code;
          l_upg_trx_info_rec.trx_id           := p_trx_id;
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
          SELECT first_pty_org_id ,
                 related_doc_date,
                 adjusted_doc_date,
                 trx_date,
                 provnl_tax_determination_date
          INTO   l_first_pty_org_id,
                 l_related_doc_date,
                 l_adjusted_doc_date,
                 l_trx_date,
                 l_prov_tax_det_date
           FROM  ZX_LINES_DET_FACTORS
          WHERE  application_id   = p_application_id
            AND  entity_code      = p_entity_code
            AND  event_class_code = p_event_class_code
            AND  trx_id           = p_trx_id
            AND  rownum           = 1;
    END;
    --Bugfix 4486946; on-the-fly upgrade end

    l_effective_date := get_effective_date (l_related_doc_date,
                                            l_prov_tax_det_date,
                                            l_adjusted_doc_date,
                                            l_trx_date
                                           );


    ZX_SECURITY.set_security_context(l_first_pty_org_id,
                                     l_effective_date,
                                     l_return_status
                                    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        l_context_info_rec.APPLICATION_ID   := p_application_id;
        l_context_info_rec.ENTITY_CODE      := p_entity_code;
        l_context_info_rec.EVENT_CLASS_CODE := p_event_class_code;
        l_context_info_rec.TRX_ID           := p_trx_id;
        ZX_API_PUB.add_msg(p_context_info_rec  =>  l_context_info_rec);
      END IF;
      RETURN;
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||
          '.END',G_PKG_NAME||': '||l_api_name||'()-'||
          ', RETURN_STATUS = ' || l_return_status);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,
           'Data is expected to be in eBTax repository for this call. Please CHECK your sequence of calls to eBTax '||
           SQLERRM);
      END IF;
  END set_security_context;

----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  set_security_context
--
--  DESCRIPTION
--  Call set security context directly; need not return to event class rec
--
--  CALLED BY
--   reverse_document
-----------------------------------------------------------------------
  PROCEDURE set_security_context
  ( x_return_status   OUT NOCOPY VARCHAR2,
    p_event_class_rec IN         ZX_API_PUB.event_class_rec_type
  )IS
  l_api_name          CONSTANT    VARCHAR2(30):= 'SET_SECURITY_CONTEXT';
  l_effective_date                DATE;
  l_related_doc_date              DATE;
  l_trx_date                      DATE;
  l_prov_tax_det_date             DATE;
  l_adjusted_doc_date             DATE;
  l_legal_entity_id               NUMBER;
  l_ou_id                         NUMBER;
  l_application_id                NUMBER;
  l_entity_code                   VARCHAR2(30);
  l_event_class_code              VARCHAR2(30);
  l_trx_id                        NUMBER;
  l_return_status                 VARCHAR2(1);
  l_upg_trx_info_rec              ZX_ON_FLY_TRX_UPGRADE_PKG.zx_upg_trx_info_rec_type;
  l_context_info_rec              ZX_API_PUB.context_info_rec_type;

  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
      SELECT /*+ INDEX(ZX_REV_TRX_HEADERS_GT ZX_REV_TRX_HEADERS_GT_U1) INDEX(ZX_REVERSE_TRX_LINES_GT ZX_REVERSE_TRX_LINES_GT_U1) */
           hdrgt.legal_entity_id ,
           hdrgt.internal_organization_id,
           zl.related_doc_date,
           zl.adjusted_doc_date,
           zl.trx_date,
           zl.provnl_tax_determination_date,
           hdrgt.reversing_appln_id ,
           hdrgt.reversing_entity_code,
           hdrgt.reversing_evnt_cls_code,
           hdrgt.reversing_trx_id
      INTO l_legal_entity_id,
           l_ou_id,
           l_related_doc_date,
           l_adjusted_doc_date,
           l_trx_date,
           l_prov_tax_det_date,
           l_application_id,
           l_entity_code,
           l_event_class_code,
           l_trx_id
      FROM ZX_REV_TRX_HEADERS_GT hdrgt,
           ZX_REVERSE_TRX_LINES_GT lngt,
           ZX_LINES_DET_FACTORS zl
     WHERE hdrgt.reversing_appln_id      = p_event_class_rec.application_id
       AND hdrgt.reversing_entity_code   = p_event_class_rec.entity_code
       AND hdrgt.reversing_evnt_cls_code = p_event_class_rec.event_class_code
       AND hdrgt.reversing_trx_id        = p_event_class_rec.trx_id
       AND lngt.reversing_trx_id         = hdrgt.reversing_trx_id
       AND lngt.reversing_appln_id       = hdrgt.reversing_appln_id
       AND lngt.reversing_entity_code    = hdrgt.reversing_entity_code
       AND lngt.reversing_evnt_cls_code  = hdrgt.reversing_evnt_cls_code
       AND zl.application_id             = lngt.reversed_appln_id
       AND zl.entity_code                = lngt.reversed_entity_code
       AND zl.event_class_code           = lngt.reversed_evnt_cls_code
       AND zl.trx_id                     = lngt.reversed_trx_id
       AND zl.trx_line_id                = lngt.reversed_trx_line_id
       AND zl.trx_level_type             = lngt.reversed_trx_level_type
       AND rownum = 1; --bug6083282


    --Bugfix 4486946 -Call on the fly upgrade if the transaction if not found
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
               'Call on-the-fly upgrade since transaction does not exist in repository for trx id: '||to_char(p_event_class_rec.trx_id));
          END IF;
          l_upg_trx_info_rec.application_id   := p_event_class_rec.application_id;
          l_upg_trx_info_rec.entity_code      := p_event_class_rec.entity_code;
          l_upg_trx_info_rec.event_class_code := p_event_class_rec.event_class_code;
          l_upg_trx_info_rec.trx_id           := p_event_class_rec.trx_id;
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
          SELECT /*+ INDEX(ZX_REV_TRX_HEADERS_GT ZX_REV_TRX_HEADERS_GT_U1) INDEX(ZX_REVERSE_TRX_LINES_GT ZX_REVERSE_TRX_LINES_GT_U1) */
             hdrgt.legal_entity_id ,
             hdrgt .internal_organization_id,
             zl.related_doc_date,
             zl.adjusted_doc_date,
             zl.trx_date,
             zl.provnl_tax_determination_date,
             hdrgt.reversing_appln_id ,
             hdrgt.reversing_entity_code,
             hdrgt.reversing_evnt_cls_code,
             hdrgt.reversing_trx_id
        INTO l_legal_entity_id,
             l_ou_id,
             l_related_doc_date,
             l_adjusted_doc_date,
             l_trx_date,
             l_prov_tax_det_date,
             l_application_id,
             l_entity_code,
             l_event_class_code,
             l_trx_id
        FROM ZX_REV_TRX_HEADERS_GT hdrgt,
             ZX_REVERSE_TRX_LINES_GT lngt,
             ZX_LINES_DET_FACTORS zl
       WHERE hdrgt.reversing_appln_id      = p_event_class_rec.application_id
         AND hdrgt.reversing_entity_code   = p_event_class_rec.entity_code
         AND hdrgt.reversing_evnt_cls_code = p_event_class_rec.event_class_code
         AND hdrgt.reversing_trx_id        = p_event_class_rec.trx_id
         AND lngt.reversing_trx_id         = hdrgt.reversing_trx_id
         AND lngt.reversing_appln_id       = hdrgt.reversing_appln_id
         AND lngt.reversing_entity_code    = hdrgt.reversing_entity_code
         AND lngt.reversing_evnt_cls_code  = hdrgt.reversing_evnt_cls_code
         AND zl.application_id             = lngt.reversed_appln_id
         AND zl.entity_code                = lngt.reversed_entity_code
         AND zl.event_class_code           = lngt.reversed_evnt_cls_code
         AND zl.trx_id                     = lngt.reversed_trx_id
         AND zl.trx_line_id                = lngt.reversed_trx_line_id
         AND zl.trx_level_type             = lngt.reversed_trx_level_type;
    END;
    --Bugfix 4486946; on-the-fly upgrade end

    l_effective_date := get_effective_date(l_related_doc_date,
                                           l_prov_tax_det_date,
                                           l_adjusted_doc_date,
                                           l_trx_date
                                          );

    ZX_SECURITY.set_security_context(l_legal_entity_id,
                                     l_ou_id,
                                     l_effective_date,
                                     l_return_status
                                    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        l_context_info_rec.APPLICATION_ID   := p_event_class_rec.APPLICATION_ID;
        l_context_info_rec.ENTITY_CODE      := p_event_class_rec.ENTITY_CODE;
        l_context_info_rec.EVENT_CLASS_CODE := p_event_class_rec.EVENT_CLASS_CODE;
        l_context_info_rec.TRX_ID           := p_event_class_rec.TRX_ID;
        ZX_API_PUB.add_msg(p_context_info_rec  =>  l_context_info_rec);
      END IF;
      RETURN;
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||
         '.END',G_PKG_NAME||': '||l_api_name||'()-' ||
         ', RETURN_STATUS = ' || l_return_status);
    END IF;

   EXCEPTION
     WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,
           'Data is expected to be in eBTax repository for this call. Please CHECK your sequence of calls to eBTax '||
           SQLERRM);
      END IF;
  END set_security_context;

/*----------------------------------------------------------------------------*
 |   PUBLIC  FUNCTIONS/PROCEDURES                                             |
 *----------------------------------------------------------------------------*/

-----------------------------------------------------------------------
--  PUBLIC FUNCTION
--  is_doc_to_be_recorded
--
--  DESCRIPTION
--  Determine if document should be recorded
--
--  CALLED BY
--
-----------------------------------------------------------------------
Function is_doc_to_be_recorded
  ( p_application_id    IN NUMBER,
    p_entity_code       IN VARCHAR2,
    p_event_class_code  IN VARCHAR2,
    p_quote_flag        IN VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2
   )RETURN VARCHAR2 IS
   l_api_name           CONSTANT VARCHAR2(30) := 'IS_DOC_TO_BE_RECORDED';
   l_record_flag        VARCHAR2(1);

  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT record_flag
     INTO l_record_flag
     FROM ZX_EVNT_CLS_MAPPINGS
    WHERE application_id = p_application_id
      AND entity_code = p_entity_code
      AND event_class_code = p_event_class_code;

    IF l_record_flag = 'Y' THEN
      IF p_quote_Flag = 'Y' THEN
        l_record_flag := 'N';
      END IF;
    END IF;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||
         '.END',G_PKG_NAME||': '||l_api_name||'()-' ||
         ', Record Flag = ' || l_record_flag ||
         ', RETURN_STATUS = ' || x_return_status);

    END IF;

    RETURN l_record_flag;

    EXCEPTION
      WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
      RETURN l_record_flag;
END is_doc_to_be_recorded;


-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  Calculate_Tax
--
--  DESCRIPTION
--  Validates and initializes parameters for calculate_tax published service
--
--  CALLED BY
--    ZX_API_PUB.calculate_tax
-----------------------------------------------------------------------
  PROCEDURE Calculate_Tax
  ( x_return_status    OUT    NOCOPY VARCHAR2,
    p_event_class_rec  IN OUT NOCOPY ZX_API_PUB.event_class_rec_type
  )IS
  l_api_name            CONSTANT  VARCHAR2(30):= 'CALCULATE_TAX';
  l_return_status                 VARCHAR2(30);
  l_effective_date                DATE;
  l_ship_from_location_id         NUMBER;
  l_bill_from_location_id         NUMBER;
  l_ship_to_location_id           NUMBER;
  l_bill_to_location_id           NUMBER;

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := null_event_class_rec;

    /* ----------------------------------------------------------------------+
     |      Initializing the tax regime dtl procedures                       |
     + ----------------------------------------------------------------------*/
     ZX_GLOBAL_STRUCTURES_PKG.Init_Tax_Regime_Tbl;

     ZX_GLOBAL_STRUCTURES_PKG.Init_Detail_Tax_Regime_Tbl;

    /* ----------------------------------------------------------------------+
     |      Get Tax Event Class                                              |
     + ----------------------------------------------------------------------*/
     get_tax_event_class (l_return_status
                          ,p_event_class_rec
                         );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RETURN;
     END IF;

    IF ZX_API_PUB.G_DATA_TRANSFER_MODE <> 'TAB' THEN

     /* ----------------------------------------------------------------------+
      |  Determine effective date                                             |
      + ----------------------------------------------------------------------*/
     determine_effective_date(p_event_class_rec,
                              l_effective_date,
                              l_return_status
                             );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
        RETURN;
     END IF;

    /* ----------------------------------------------------------------------+
     | Bug 3129063 -      Setting the Security Context for Subscription      |
     + ----------------------------------------------------------------------*/
     get_tax_subscriber(p_event_class_rec,
	                l_effective_date,
                        l_return_status
                       );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RETURN;
     END IF;

    /* ----------------------------------------------------------------------+
     |      Get Tax Event Type                                               |
     + ----------------------------------------------------------------------*/
     get_tax_event_type (l_return_status
                         ,p_event_class_rec.event_class_code
                         ,p_event_class_rec.application_id
                         ,p_event_class_rec.entity_code
                         ,p_event_class_rec.event_type_code
                         ,p_event_class_rec.tax_event_class_code
                         ,p_event_class_rec.tax_event_type_code
                         ,p_event_class_rec.doc_status_code
                         );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RETURN;
     END IF;

    /* ----------------------------------------------------------------------+
     |      Populate Event Class Options                                     |
     + ----------------------------------------------------------------------*/
     populate_event_class_options(l_return_status,
                                  l_effective_date,
                                  p_event_class_rec
                                 );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RETURN;
     END IF;

   END IF; -- ZX_API_PUB.g_data_tranfer_mode <> 'TAB'

     /* ----------------------------------------------------------------------+
      |      Populate Application Product Options                             |
      +----------------------------------------------------------------------*/
     populate_appl_product_options(l_return_status,
                                   p_event_class_rec
                                   );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RETURN;
     END IF;

    -- populate global event class record structure
    ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := p_event_class_rec;

    /* ----------------------------------------------------------------------+
     | The below logic needs not be executed for calculate tax called by     |
     | products uptaking the determining factors UI since the values of      |
	 | rounding parties are already available in zx_lines_det_factors.       |
	 + ----------------------------------------------------------------------*/

    /* ----------------------------------------------------------------------+
     |      Get the locations for parties and their ptp ids                  |
     + ----------------------------------------------------------------------*/
     IF ZX_API_PUB.G_DATA_TRANSFER_MODE = 'PLS' THEN
        get_loc_id_and_ptp_ids( p_event_class_rec  => p_event_class_rec,
                                p_trx_line_index   => NULL,
                                x_return_status    => l_return_status
                              );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          RETURN;
        END IF;
     END IF;
     /* ----------------------------------------------------------------------+
      |      Check Required parameters - Header and Line level                |
      + ----------------------------------------------------------------------*/
      IF ZX_API_PUB.G_DATA_TRANSFER_MODE = 'TAB' THEN
         ZX_CHECK_REQUIRED_PARAMS_PKG.check_trx_headers_tbl(l_return_status,
                                                            p_event_class_rec
                                                           );

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_return_status := l_return_status;
           RETURN;
         END IF;

         ZX_CHECK_REQUIRED_PARAMS_PKG.check_trx_line_tbl(l_return_status,
                                                         p_event_class_rec
                                                         );
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_return_status := l_return_status;
           RETURN;
         END IF;
      ELSIF ZX_API_PUB.G_DATA_TRANSFER_MODE = 'PLS' THEN
          ZX_CHECK_REQUIRED_PARAMS_PKG.check_trx_lines(l_return_status,
                                                       p_event_class_rec
                                                      );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            RETURN;
          END IF;
      END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
          '  application_id: '||p_event_class_rec.application_id||
          ', entity_code: '||p_event_class_rec.entity_code||
          ', event_class_code: '||p_event_class_rec.event_class_code||
          ', internal_organization_id: '||p_event_class_rec.internal_organization_id||
          ', legal_entity_id: '||p_event_class_rec.legal_entity_id||
          ', first_pty_org_id: '||p_event_class_rec.first_pty_org_id||
          ', ledger_id: '||p_event_class_rec.ledger_id||
          ', reference_application_id: '||p_event_class_rec.reference_application_id||
          ', event_type_code: '||p_event_class_rec.event_type_code||
          ', trx_id: '||p_event_class_rec.trx_id||
          ', trx_date: '||p_event_class_rec.trx_date||
          ', rel_doc_date: '||p_event_class_rec.rel_doc_date||
          ', trx_currency_code: '||p_event_class_rec.trx_currency_code||
          ', currency_conversion_type: '||p_event_class_rec.currency_conversion_type||
          ', currency_conversion_rate: '||p_event_class_rec.currency_conversion_rate||
          ', currency_conversion_date: '||p_event_class_rec.currency_conversion_date||
          ', rounding_ship_to_party_id: '||p_event_class_rec.rounding_ship_to_party_id||
          ', rounding_ship_from_party_id: '||p_event_class_rec.rounding_ship_from_party_id||
          ', rounding_bill_to_party_id: '||p_event_class_rec.rounding_bill_to_party_id||
          ', rounding_bill_from_party_id: '||p_event_class_rec.rounding_bill_from_party_id||
          ', rndg_ship_to_party_site_id: '||p_event_class_rec.rndg_ship_to_party_site_id||
          ', rndg_ship_from_party_site_id: '||p_event_class_rec.rndg_ship_from_party_site_id||
          ', rndg_bill_to_party_site_id: '||p_event_class_rec.rndg_bill_to_party_site_id||
          ', rndg_bill_from_party_site_id: '||p_event_class_rec.rndg_bill_from_party_site_id||
          ', tax_event_class_code: '||p_event_class_rec.tax_event_class_code||
          ', tax_event_type_code: '||p_event_class_rec.tax_event_type_code||
          ', doc_status_code: '||p_event_class_rec.doc_status_code||
          ', det_factor_templ_code: '||p_event_class_rec.det_factor_templ_code||
          ', default_rounding_level_code: '||p_event_class_rec.default_rounding_level_code||
          ', rounding_level_hier1: '||p_event_class_rec.rounding_level_hier_1_code||
          ', rounding_level_hier2: '||p_event_class_rec.rounding_level_hier_2_code||
          ', rounding_level_hier3: '||p_event_class_rec.rounding_level_hier_3_code||
          ', rounding_level_hier4: '||p_event_class_rec.rounding_level_hier_4_code||
          ', rdng_ship_to_pty_tx_prof_id: '||p_event_class_rec.rdng_ship_to_pty_tx_prof_id||
          ', rdng_ship_from_pty_tx_prof_id: '||p_event_class_rec.rdng_ship_from_pty_tx_prof_id||
          ', rdng_bill_to_pty_tx_prof_id: '||p_event_class_rec.rdng_bill_to_pty_tx_prof_id||
          ', rdng_bill_from_pty_tx_prof_id: '||p_event_class_rec.rdng_bill_from_pty_tx_prof_id||
          ', rdng_ship_to_pty_tx_p_st_id: '||p_event_class_rec.rdng_ship_to_pty_tx_p_st_id||
          ', rdng_ship_from_pty_tx_p_st_id: '||p_event_class_rec.rdng_ship_from_pty_tx_p_st_id||
          ', rdng_bill_to_pty_tx_p_st_id: '||p_event_class_rec.rdng_bill_to_pty_tx_p_st_id||
          ', rdng_bill_from_pty_tx_p_st_id: '||p_event_class_rec.rdng_bill_from_pty_tx_p_st_id||
          ', allow_manual_lin_recalc_flag: '||p_event_class_rec.allow_manual_lin_recalc_flag||
          ', allow_manual_lines_flag: '||p_event_class_rec.allow_manual_lines_flag||
          ', allow_override_flag: '||p_event_class_rec.allow_override_flag||
          ', enforce_tax_from_acct_flag: '||p_event_class_rec.enforce_tax_from_acct_flag||
          ', perform_additional_applicability_for_import_flag: '||p_event_class_rec.perf_addnl_appl_for_imprt_flag||
          ', record_flag: '||p_event_class_rec.record_flag||
          ', quote_flag: '||p_event_class_rec.quote_flag||
          ', normal_sign_flag: '||p_event_class_rec.normal_sign_flag||
          ', offset_tax_basis_code: '||p_event_class_rec.offset_tax_basis_code||
          ', tax_tolerance: '||p_event_class_rec.tax_tolerance||
          ', tax_tol_amt_range: '||p_event_class_rec.tax_tol_amt_range ||
          ', allow_offset_tax_calc_flag: '||p_event_class_rec.allow_offset_tax_calc_flag||
          ', self_assess_tax_lines_flag: '||p_event_class_rec.self_assess_tax_lines_flag||
          ', tax_recovery_flag: '||p_event_class_rec.tax_recovery_flag||
          ', allow_cancel_tax_lines_flag: '||p_event_class_rec.allow_cancel_tax_lines_flag||
          ', allow_man_tax_only_lines_flag: '||p_event_class_rec.allow_man_tax_only_lines_flag||
          ', enable_mrc_flag: '||p_event_class_rec.enable_mrc_flag||
          ', tax_reporting_flag: '||p_event_class_rec.tax_reporting_flag||
          ', enter_ovrd_incl_tax_lines_flag: '||p_event_class_rec.enter_ovrd_incl_tax_lines_flag||
          ', ctrl_eff_ovrd_calc_lines_flag: '||p_event_class_rec.ctrl_eff_ovrd_calc_lines_flag||
          ', summarization_flag: '||p_event_class_rec.summarization_flag||
          ', retain_summ_tax_line_id_flag: '||p_event_class_rec.retain_summ_tax_line_id_flag||
          ', tax_variance_calc_flag: '||p_event_class_rec.tax_variance_calc_flag||
          ', prod_family_grp_code: '||p_event_class_rec.prod_family_grp_code||
          ', record_for_partners_flag: '||p_event_class_rec.record_for_partners_flag||
          ', manual_lines_for_partner_flag: '||p_event_class_rec.manual_lines_for_partner_flag||
          ', man_tax_only_lin_for_ptnr_flag: '||p_event_class_rec.man_tax_only_lin_for_ptnr_flag||
          ', always_use_ebtax_for_calc_flag: '||p_event_class_rec.always_use_ebtax_for_calc_flag||
          ', enforce_tax_from_ref_doc_flag: '||p_event_class_rec.enforce_tax_from_ref_doc_flag||
          ', process_for_applicability_flag: '||p_event_class_rec.process_for_applicability_flag||
          ', allow_exemptions_flag: '||p_event_class_rec.allow_exemptions_flag||
          ', sup_cust_acct_type: '||p_event_class_rec.sup_cust_acct_type||
          ', intgrtn_det_factors_ui_flag: '||p_event_class_rec.intgrtn_det_factors_ui_flag||
          ', exmptn_pty_basis_hier_1_code: '||p_event_class_rec.exmptn_pty_basis_hier_1_code||
          ', exmptn_pty_basis_hier_2_code: '||p_event_class_rec.exmptn_pty_basis_hier_2_code||
          ', tax_method_code: '||p_event_class_rec.tax_method_code||
          ', inclusive_tax_used_flag: '||p_event_class_rec.inclusive_tax_used_flag||
          ', tax_use_customer_exempt_flag: '||p_event_class_rec.tax_use_customer_exempt_flag||
          ', tax_use_product_exempt_flag: '||p_event_class_rec.tax_use_product_exempt_flag||
          ', tax_use_loc_exc_rate_flag: '||p_event_class_rec.tax_use_loc_exc_rate_flag||
          ', tax_allow_compound_flag: '||p_event_class_rec.tax_allow_compound_flag||
          ', use_tax_classification_flag: '||p_event_class_rec.use_tax_classification_flag||
          ', allow_tax_rounding_ovrd_flag: '||p_event_class_rec.allow_tax_rounding_ovrd_flag||
          ', home_country_default_flag: '||p_event_class_rec.home_country_default_flag ||
          ', header_level_currency_flag: '||p_event_class_rec.header_level_currency_flag||
          ', source_process_for_applicability_flag: '||p_event_class_rec.source_process_for_appl_flag||
          ', RETURN_STATUS = ' || x_return_status);
    END IF;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
    END IF;
  END calculate_tax;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  import_document_with_tax
--
--  DESCRIPTION
--  Validates and initializes parameters for import_document_with_tax published service
--
--  CALLED BY
--    ZX_API_PUB.import_document_with_tax
-----------------------------------------------------------------------
  PROCEDURE import_document_with_tax
  ( x_return_status    OUT    NOCOPY   VARCHAR2,
    p_event_class_rec  IN OUT NOCOPY   ZX_API_PUB.event_class_rec_type
  )IS
  l_api_name                      CONSTANT VARCHAR2(30) := 'IMPORT_DOCUMENT_WITH_TAX';
  l_return_status                 VARCHAR2(30);
  l_effective_date                DATE;
  l_ship_from_location_id         NUMBER;
  l_bill_from_location_id         NUMBER;
  l_ship_to_location_id           NUMBER;
  l_bill_to_location_id           NUMBER;

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := null_event_class_rec;

   /* ----------------------------------------------------------------------+
    |      Initializing the tax regime dtl procedures                       |
    + ----------------------------------------------------------------------*/
    ZX_GLOBAL_STRUCTURES_PKG.init_tax_regime_tbl;

    ZX_GLOBAL_STRUCTURES_PKG.init_detail_tax_regime_tbl;

   /* ----------------------------------------------------------------------+
    |      Get Tax Event Class                                              |
    + ----------------------------------------------------------------------*/
    get_tax_event_class (l_return_status
                         ,p_event_class_rec
                        );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;


    /* ----------------------------------------------------------------------+
     |      Populate Application Product Options                             |
     + ----------------------------------------------------------------------*/
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' Populate Application product options');
     END IF;

     populate_appl_product_options(l_return_status,
                                   p_event_class_rec
                                  );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RETURN;
     END IF;

     -- populate global event class record structure
     ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := p_event_class_rec;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
          'application_id: '||p_event_class_rec.application_id||
          ', entity_code: '||p_event_class_rec.entity_code||
          ', event_class_code: '||p_event_class_rec.event_class_code||
          ', internal_organization_id: '||p_event_class_rec.internal_organization_id||
          ', tax_event_class_code: '||p_event_class_rec.tax_event_class_code||
          ', Det_Factor_Templ_Code: '||p_event_class_rec.det_factor_templ_code||
          ', Default_Rounding_Level_Code: '||p_event_class_rec.default_rounding_level_code||
          ', rounding_level_hier1: '||p_event_class_rec.rounding_level_hier_1_code||
          ', rounding_level_hier2: '||p_event_class_rec.rounding_level_hier_2_code||
          ', rounding_level_hier3: '||p_event_class_rec.rounding_level_hier_3_code||
          ', rounding_level_hier4: '||p_event_class_rec.rounding_level_hier_4_code||
          ', allow_manual_lin_recalc_flag: '||p_event_class_rec.allow_manual_lin_recalc_flag||
          ', allow_manual_lines_flag: '||p_event_class_rec.allow_manual_lines_flag||
          ', allow_override_flag: '||p_event_class_rec.allow_override_flag||
          ', enforce_tax_from_acct_flag: '||p_event_class_rec.enforce_tax_from_acct_flag||
          ', perform_additional_applicability_for_import_flag: '||p_event_class_rec.perf_addnl_appl_for_imprt_flag||
          ', record_flag: '||p_event_class_rec.record_flag||
          ', quote_flag: '||p_event_class_rec.quote_flag||
          ', normal_sign_flag: '||p_event_class_rec.normal_sign_flag||
          ', offset_tax_basis_code: '||p_event_class_rec.offset_tax_basis_code||
          ', allow_offset_tax_calc_flag: '||p_event_class_rec.allow_offset_tax_calc_flag||
          ', self_assess_tax_lines_flag: '||p_event_class_rec.self_assess_tax_lines_flag||
          ', tax_recovery_flag: '||p_event_class_rec.tax_recovery_flag||
          ', allow_cancel_tax_lines_flag: '||p_event_class_rec.allow_cancel_tax_lines_flag||
          ', allow_man_tax_only_lines_flag: '||p_event_class_rec.allow_man_tax_only_lines_flag||
          ', enable_mrc_flag: '||p_event_class_rec.enable_mrc_flag||
          ', tax_reporting_flag: '||p_event_class_rec.tax_reporting_flag||
          ', enter_ovrd_incl_tax_lines_flag: '||p_event_class_rec.enter_ovrd_incl_tax_lines_flag||
          ', ctrl_eff_ovrd_calc_lines_flag: '||p_event_class_rec.ctrl_eff_ovrd_calc_lines_flag||
          ', summarization_flag: '||p_event_class_rec.summarization_flag||
          ', retain_summ_tax_line_id_flag: '||p_event_class_rec.retain_summ_tax_line_id_flag||
          ', tax_variance_calc_flag: '||p_event_class_rec.tax_variance_calc_flag||
          ', prod_family_grp_code: '||p_event_class_rec.prod_family_grp_code||
          ', record_for_partners_flag: '||p_event_class_rec.record_for_partners_flag||
          ', manual_lines_for_partner_flag: '||p_event_class_rec.manual_lines_for_partner_flag||
          ', man_tax_only_lin_for_ptnr_flag: '||p_event_class_rec.man_tax_only_lin_for_ptnr_flag||
          ', always_use_ebtax_for_calc_flag: '||p_event_class_rec.always_use_ebtax_for_calc_flag||
          ', enforce_tax_from_ref_doc_flag: '||p_event_class_rec.enforce_tax_from_ref_doc_flag||
          ', process_for_applicability_flag: '||p_event_class_rec.process_for_applicability_flag||
          ', allow_exemptions_flag: '||p_event_class_rec.allow_exemptions_flag||
          ', sup_cust_acct_type: '||p_event_class_rec.sup_cust_acct_type||
          ', intgrtn_det_factors_ui_flag: '||p_event_class_rec.intgrtn_det_factors_ui_flag||
          ', exmptn_pty_basis_hier_1_code: '||p_event_class_rec.exmptn_pty_basis_hier_1_code||
          ', exmptn_pty_basis_hier_2_code: '||p_event_class_rec.exmptn_pty_basis_hier_2_code||
          ', tax_method_code: '||p_event_class_rec.tax_method_code||
          ', inclusive_tax_used_flag: '||p_event_class_rec.inclusive_tax_used_flag||
          ', tax_use_customer_exempt_flag: '||p_event_class_rec.tax_use_customer_exempt_flag||
          ', tax_use_product_exempt_flag: '||p_event_class_rec.tax_use_product_exempt_flag||
          ', tax_use_loc_exc_rate_flag: '||p_event_class_rec.tax_use_loc_exc_rate_flag||
          ', tax_allow_compound_flag: '||p_event_class_rec.tax_allow_compound_flag||
          ', use_tax_classification_flag: '||p_event_class_rec.use_tax_classification_flag||
          ', allow_tax_rounding_ovrd_flag: '||p_event_class_rec.allow_tax_rounding_ovrd_flag||
          ', home_country_default_flag: '||p_event_class_rec.home_country_default_flag ||
          ', header_level_currency_flag: '||p_event_class_rec.header_level_currency_flag||
          ', RETURN_STATUS = ' || x_return_status);
    END IF;
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
    END IF;
  END import_document_with_tax;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  Override_Tax
--
--  DESCRIPTION
--  Validates and initializes parameters for Override_Tax published service
--
--  CALLED BY
--    ZX_API_PUB.Override_Tax
-----------------------------------------------------------------------
  PROCEDURE Override_Tax
  ( x_return_status    OUT    NOCOPY VARCHAR2,
    p_override         IN     	     VARCHAR2,
    p_event_class_rec  IN OUT NOCOPY ZX_API_PUB.event_class_rec_type,
    p_trx_rec          IN            ZX_API_PUB.transaction_rec_type
  ) IS
  l_api_name                      CONSTANT VARCHAR2(30):= 'OVERRIDE_TAX';
  l_return_status                 VARCHAR2(30);
  l_effective_date                DATE;
  l_ship_from_location_id         NUMBER;
  l_bill_from_location_id         NUMBER;
  l_ship_to_location_id           NUMBER;
  l_bill_to_location_id           NUMBER;

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := null_event_class_rec;

   /* ----------------------------------------------------------------------+
    |      Get Tax Event Class                                              |
    + ----------------------------------------------------------------------*/
    get_tax_event_class (l_return_status
                         ,p_event_class_rec
                         );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;


   /* ----------------------------------------------------------------------+
    | Bug 3129063 - Setting the Security Context for Subscription           |
    + ----------------------------------------------------------------------*/

    get_tax_subscriber(p_event_class_rec,
                       l_return_status
                       );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;



   /* ----------------------------------------------------------------------+
    |      Get Tax Event Type                                               |
    + ----------------------------------------------------------------------*/
    get_tax_event_type (l_return_status
                        ,p_event_class_rec.event_class_code
                        ,p_event_class_rec.application_id
                        ,p_event_class_rec.entity_code
                        ,p_event_class_rec.event_type_code
                        ,p_event_class_rec.tax_event_class_code
                        ,p_event_class_rec.tax_event_type_code
                        ,p_event_class_rec.doc_status_code
                       );


    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;


   /* ----------------------------------------------------------------------+
    |      Check Trx Rec                                                    |
    + ----------------------------------------------------------------------*/
    ZX_CHECK_REQUIRED_PARAMS_PKG.check_trx_rec(l_return_status,
                                               p_trx_rec
                                              );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;


   /* ----------------------------------------------------------------------+
    |  Determine effective date                                             |
    + ----------------------------------------------------------------------*/
    determine_effective_date(p_event_class_rec,
                             l_effective_date,
                             l_return_status
                            );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;


    /* ----------------------------------------------------------------------+
     |      Populate Event Class Options                                     |
     + ----------------------------------------------------------------------*/
    populate_event_class_options(l_return_status,
                                 l_effective_date,
                                 p_event_class_rec
                                 );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

   /* Bug 5382069 */
   -- populate global event class record structure
      p_event_class_rec.quote_flag := 'N';

    /* ----------------------------------------------------------------------+
     |      Override Flag                                                    |
     + ----------------------------------------------------------------------*/
     IF p_override is NULL THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,'Override Level is required');
        END IF;
       RETURN;
     ELSE
       p_event_class_rec.override_level := p_override;
     END IF;

    ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := p_event_class_rec;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
          'application_id: '||p_event_class_rec.application_id||
          ', entity_code: '||p_event_class_rec.entity_code||
          ', event_class_code: '||p_event_class_rec.event_class_code||
          ', internal_organization_id: '||p_event_class_rec.internal_organization_id||
          ', legal_entity_id: '||p_event_class_rec.legal_entity_id||
          ', first_pty_org_id: '||p_event_class_rec.first_pty_org_id||
          ', reference_application_id: '||p_event_class_rec.reference_application_id||
          ', event_type_code: '||p_event_class_rec.event_type_code||
          ', trx_id: '||p_event_class_rec.trx_id||
          ', trx_date: '||p_event_class_rec.trx_date||
          ', rel_doc_date: '||p_event_class_rec.rel_doc_date||
          ', trx_currency_code: '||p_event_class_rec.trx_currency_code||
          ', tax_event_class_code: '||p_event_class_rec.tax_event_class_code||
          ', tax_event_type_code: '||p_event_class_rec.tax_event_type_code||
          ', doc_status_code: '||p_event_class_rec.doc_status_code||
          ', Det_Factor_Templ_Code: '||p_event_class_rec.det_factor_templ_code||
          ', Default_Rounding_Level_Code: '||p_event_class_rec.default_rounding_level_code||
          ', rounding_level_hier1: '||p_event_class_rec.rounding_level_hier_1_code||
          ', rounding_level_hier2: '||p_event_class_rec.rounding_level_hier_2_code||
          ', rounding_level_hier3: '||p_event_class_rec.rounding_level_hier_3_code||
          ', rounding_level_hier4: '||p_event_class_rec.rounding_level_hier_4_code||
          ', rdng_ship_to_pty_tx_prof_id: '||p_event_class_rec.rdng_ship_to_pty_tx_prof_id||
          ', rdng_ship_from_pty_tx_prof_id: '||p_event_class_rec.rdng_ship_from_pty_tx_prof_id||
          ', rdng_bill_to_pty_tx_prof_id: '||p_event_class_rec.rdng_bill_to_pty_tx_prof_id||
          ', rdng_bill_from_pty_tx_prof_id: '||p_event_class_rec.rdng_bill_from_pty_tx_prof_id||
          ', rdng_ship_to_pty_tx_p_st_id: '||p_event_class_rec.rdng_ship_to_pty_tx_p_st_id||
          ', rdng_ship_from_pty_tx_p_st_id: '||p_event_class_rec.rdng_ship_from_pty_tx_p_st_id||
          ', rdng_bill_to_pty_tx_p_st_id: '||p_event_class_rec.rdng_bill_to_pty_tx_p_st_id||
          ', rdng_bill_from_pty_tx_p_st_id: '||p_event_class_rec.rdng_bill_from_pty_tx_p_st_id||
          ', allow_manual_lin_recalc_flag: '||p_event_class_rec.allow_manual_lin_recalc_flag||
          ', allow_manual_lines_flag: '||p_event_class_rec.allow_manual_lines_flag||
          ', allow_override_flag: '||p_event_class_rec.allow_override_flag||
          ', enforce_tax_from_acct_flag: '||p_event_class_rec.enforce_tax_from_acct_flag||
          ', perform_additional_applicability_for_import_flag: '||p_event_class_rec.perf_addnl_appl_for_imprt_flag||
          ', record_flag: '||p_event_class_rec.record_flag||
          ', quote_flag: '||p_event_class_rec.quote_flag||
          ', normal_sign_flag: '||p_event_class_rec.normal_sign_flag||
          ', offset_tax_basis_code: '||p_event_class_rec.offset_tax_basis_code||
          ', tax_tolerance: '||p_event_class_rec.tax_tolerance||
          ', tax_tol_amt_range: '||p_event_class_rec.tax_tol_amt_range ||
          ', reference_application_id: '||p_event_class_rec.reference_application_id||
          ', offset_tax_basis_code: '||p_event_class_rec.offset_tax_basis_code||
          ', allow_offset_tax_calc_flag: '||p_event_class_rec.allow_offset_tax_calc_flag||
          ', self_assess_tax_lines_flag: '||p_event_class_rec.self_assess_tax_lines_flag||
          ', tax_recovery_flag: '||p_event_class_rec.tax_recovery_flag||
          ', allow_cancel_tax_lines_flag: '||p_event_class_rec.allow_cancel_tax_lines_flag||
          ', allow_man_tax_only_lines_flag: '||p_event_class_rec.allow_man_tax_only_lines_flag||
          ', enable_mrc_flag: '||p_event_class_rec.enable_mrc_flag||
          ', tax_reporting_flag: '||p_event_class_rec.tax_reporting_flag||
          ', enter_ovrd_incl_tax_lines_flag: '||p_event_class_rec.enter_ovrd_incl_tax_lines_flag||
          ', ctrl_eff_ovrd_calc_lines_flag: '||p_event_class_rec.ctrl_eff_ovrd_calc_lines_flag||
          ', summarization_flag: '||p_event_class_rec.summarization_flag||
          ', retain_summ_tax_line_id_flag: '||p_event_class_rec.retain_summ_tax_line_id_flag||
          ', tax_variance_calc_flag: '||p_event_class_rec.tax_variance_calc_flag||
          ', prod_family_grp_code: '||p_event_class_rec.prod_family_grp_code||
          ', record_for_partners_flag: '||p_event_class_rec.record_for_partners_flag||
          ', manual_lines_for_partner_flag: '||p_event_class_rec.manual_lines_for_partner_flag||
          ', man_tax_only_lin_for_ptnr_flag: '||p_event_class_rec.man_tax_only_lin_for_ptnr_flag||
          ', always_use_ebtax_for_calc_flag: '||p_event_class_rec.always_use_ebtax_for_calc_flag||
          ', enforce_tax_from_ref_doc_flag: '||p_event_class_rec.enforce_tax_from_ref_doc_flag||
          ', process_for_applicability_flag: '||p_event_class_rec.process_for_applicability_flag||
          ', allow_exemptions_flag: '||p_event_class_rec.allow_exemptions_flag||
          ', sup_cust_acct_type: '||p_event_class_rec.sup_cust_acct_type||
          ', intgrtn_det_factors_ui_flag: '||p_event_class_rec.intgrtn_det_factors_ui_flag||
          ', exmptn_pty_basis_hier_1_code: '||p_event_class_rec.exmptn_pty_basis_hier_1_code||
          ', exmptn_pty_basis_hier_2_code: '||p_event_class_rec.exmptn_pty_basis_hier_2_code||
          ', RETURN_STATUS = ' || x_return_status);
    END IF;
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
     END IF;
   END override_tax;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  global_document_update
--
--  DESCRIPTION
--  Validates and initializes parameters for global_document_update published service
--
--  CALLED BY
--    ZX_API_PUB.global_document_update
-----------------------------------------------------------------------
  PROCEDURE Global_Document_Update
  ( x_return_status    OUT NOCOPY  VARCHAR2,
    p_event_class_rec  OUT NOCOPY  ZX_API_PUB.event_class_rec_type,
    p_trx_rec          IN          ZX_API_PUB.transaction_rec_type
  )IS
  l_api_name         CONSTANT VARCHAR2(30):= 'GLOBAL_DOCUMENT_UPDATE';
  l_return_status    VARCHAR2(30);
  l_ref_appln_id     NUMBER;

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := null_event_class_rec;

    /*------------------------------------------------------+
     |   Copy to Event Class Record                         |
     +------------------------------------------------------*/
     p_event_class_rec.INTERNAL_ORGANIZATION_ID :=  p_trx_rec.INTERNAL_ORGANIZATION_ID;
     p_event_class_rec.APPLICATION_ID           :=  p_trx_rec.APPLICATION_ID;
     p_event_class_rec.ENTITY_CODE              :=  p_trx_rec.ENTITY_CODE;
     p_event_class_rec.EVENT_CLASS_CODE         :=  p_trx_rec.EVENT_CLASS_CODE;
     p_event_class_rec.EVENT_TYPE_CODE          :=  p_trx_rec.EVENT_TYPE_CODE;
     p_event_class_rec.TRX_ID                   :=  p_trx_rec.TRX_ID;

   /* ----------------------------------------------------------------------+
     | Bug 3129063 - Setting the Security Context for Subscription           |
     + ----------------------------------------------------------------------*/
    --IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    --   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' Call GET_TAX_SUBSCRIBER');
    -- END IF;

    --get_tax_subscriber(p_event_class_rec,
    --                   l_return_status
    --                   );

    --IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    --  x_return_status := l_return_status;
    --  RETURN;
    --END IF;

   /* ------------------------------------------------+
    |      Get Tax Event Class                        |
    + -----------------------------------------------*/
    get_tax_event_class (l_return_status,
                         p_event_class_rec.application_id,
                         p_event_class_rec.entity_code,
                         p_event_class_rec.event_class_code,
                         p_event_class_rec.tax_event_class_code,
                         l_ref_appln_id,
                         p_event_class_rec.record_flag,                 -- Bug 5200373
                         p_event_class_rec.record_for_partners_flag,    -- Bug 5200373
                         p_event_class_rec.prod_family_grp_code,        -- Bug 5200373
                         p_event_class_rec.event_class_mapping_id,         -- Bug 5200373
                         p_event_class_rec.summarization_flag
                         );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

   /* ----------------------------------------------------------------------+
    |      Get Tax Event Type                                               |
    + ----------------------------------------------------------------------*/
    get_tax_event_type (l_return_status,
                        p_event_class_rec.event_class_code,
                        p_event_class_rec.application_id,
                        p_event_class_rec.entity_code,
                        p_event_class_rec.event_type_code,
                        p_event_class_rec.tax_event_class_code,
                        p_event_class_rec.tax_event_type_code,
                        p_event_class_rec.doc_status_code
                       );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

   /* ----------------------------------------------------------------------+
    |      Check Trx Rec                                                    |
    + ----------------------------------------------------------------------*/
    ZX_CHECK_REQUIRED_PARAMS_PKG.check_trx_rec(l_return_status,
                                               p_trx_rec
                                              );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

    -- populate global event class record structure
    ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := p_event_class_rec;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
          'application_id: '||p_event_class_rec.application_id||
          ', entity_code: '||p_event_class_rec.entity_code||
          ', event_class_code: '||p_event_class_rec.event_class_code||
          ', event_type_code: '||p_event_class_rec.event_type_code||
          ', trx_id: '||p_event_class_rec.trx_id||
          ', tax_event_class_code: '||p_event_class_rec.tax_event_class_code||
          ', tax_event_type_code: '||p_event_class_rec.tax_event_type_code||
          ', doc_event_status: '||p_event_class_rec.doc_status_code||
          ', RETURN_STATUS = ' || x_return_status);
    END IF;
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
    END IF;
  END global_document_update;


/* ======================================================================*
 | PROCEDURE Mark_tax_lines_deleted:Validates the input parameters of    |
 |                               Mark_tax_lines_deleted published        |
 |                               service                                 |
 * ======================================================================*/
  PROCEDURE mark_tax_lines_deleted
  ( x_return_status        OUT 	NOCOPY VARCHAR2,
    p_transaction_line_rec IN   ZX_API_PUB.transaction_line_rec_type
  ) IS
  l_api_name       CONSTANT VARCHAR2(30):= 'MARK_TAX_LINES_DELETED';
  l_return_status  VARCHAR2(30);

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* ----------------------------------------------------------------------+
     | Bug 3129063 - Setting the Security Context for Subscription           |
     + ----------------------------------------------------------------------*/
     set_security_context(p_transaction_line_rec.application_id,
                          p_transaction_line_rec.entity_code,
                          p_transaction_line_rec.event_class_code,
                          p_transaction_line_rec.trx_id,
                          l_return_status
                         );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RETURN;
    END IF;

   /* ----------------------------------------------------------------------+
    |      Check Required Parameters                                        |
    + ----------------------------------------------------------------------*/
    ZX_CHECK_REQUIRED_PARAMS_PKG.check_trx_line_rec(l_return_status
                                                   ,p_transaction_line_rec
                                                   );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
          'application_id: '||p_transaction_line_rec.application_id||
          ', entity_code: '||p_transaction_line_rec.entity_code||
          ', event_class_code: '||p_transaction_line_rec.event_class_code||
          ', event_type_code: '||p_transaction_line_rec.event_type_code||
          ', trx_id: '||p_transaction_line_rec.trx_id||
          ', tax_event_class_code: '||p_transaction_line_rec.tax_event_class_code||
          ', tax_event_type_code: '||p_transaction_line_rec.tax_event_type_code||
          ', doc_event_status: '||p_transaction_line_rec.doc_event_status||
          ', trx_level_type: '||p_transaction_line_rec.trx_level_type||
          ', doc_trx_line_id: '||p_transaction_line_rec.trx_line_id||
          ', RETURN_STATUS = ' || x_return_status);
    END IF;
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
    END IF;
  END mark_tax_lines_deleted;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  reverse_document
--
--  DESCRIPTION
--  Validates and initializes parameters for reverse_document published service
--
--  CALLED BY
--    ZX_API_PUB.reverse_document
-----------------------------------------------------------------------
  PROCEDURE reverse_document
  ( x_return_status         OUT NOCOPY VARCHAR2 ,
    p_event_class_rec       OUT NOCOPY ZX_API_PUB.event_class_rec_type
  ) IS
    l_api_name              CONSTANT VARCHAR2(30):= 'REVERSE_DOCUMENT';
    l_return_status         VARCHAR2(30);
    l_appln_id              NUMBER;
    l_entity_code           VARCHAR2(30);
    l_evnt_cls_code         VARCHAR2(30);
    l_tx_evnt_cls_code      VARCHAR2(30);
    l_ref_appln_id          NUMBER;

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := null_event_class_rec;


    /* ----------------------------------------------------------------------+
     |      Get Tax Event Class                                              |
     + ----------------------------------------------------------------------*/
      SELECT reversing_appln_id,
             reversing_entity_code,
             reversing_evnt_cls_code,
             reversing_trx_id
      INTO   p_event_class_rec.application_id,
             p_event_class_rec.entity_code,
             p_event_class_rec.event_class_code,
             p_event_class_rec.trx_id
      FROM   ZX_REV_TRX_HEADERS_GT
      WHERE  rownum = 1;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,' Get tax event class');
     END IF;

    /* -----------------------------------------------------------------------+
     | Bug 3129063     Setting the Security Context for Subscription         |
     + ----------------------------------------------------------------------*/

     set_security_context(l_return_status,p_event_class_rec);

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RETURN;
     END IF;

      get_tax_event_class (l_return_status,
                           p_event_class_rec.application_id,
                           p_event_class_rec.entity_code,
                           p_event_class_rec.event_class_code,
                           p_event_class_rec.tax_event_class_code,
                           l_ref_appln_id,
                           p_event_class_rec.record_flag,              -- Bug 5200373
                           p_event_class_rec.record_for_partners_flag, -- Bug 5200373
                           p_event_class_rec.prod_family_grp_code,     -- Bug 5200373
                           p_event_class_rec.event_class_mapping_id,      -- Bug 5200373
                           p_event_class_rec.summarization_flag
                          );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         RETURN;
      END IF;

      -- populate global event class record structure
      ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := p_event_class_rec;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
          'application_id: '||l_appln_id||
          ', entity_code: '||l_entity_code||
          ', event_class_code: '||l_evnt_cls_code||
          ', tax_event_class_code: '||l_tx_evnt_cls_code||
          ', reference_application_id: '||l_ref_appln_id||
          ', RETURN_STATUS = ' || x_return_status);
      END IF;
      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
      END IF;

  END reverse_document;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  reverse_distributions
--
--  DESCRIPTION
--  Validates and initializes parameters for reverse_distributions published service
--
--  CALLED BY
--    ZX_API_PUB.reverse_distributions
-----------------------------------------------------------------------
  PROCEDURE reverse_distributions
  ( x_return_status         OUT NOCOPY VARCHAR2
  )
  IS
    l_api_name              CONSTANT VARCHAR2(30):= 'REVERSE_DISTRIBUTIONS';
    l_appln_id              NUMBER;
    l_return_status         VARCHAR2(30);
    l_entity_code           VARCHAR2(30);
    l_evnt_cls_code         VARCHAR2(30);
    l_tx_evnt_cls_code      VARCHAR2(30);
    l_ref_appln_id          NUMBER;
    l_trx_id                NUMBER;
    l_record_flag               zx_evnt_cls_mappings.record_flag%type;
    l_record_for_partners_flag  zx_evnt_cls_mappings.record_for_partners_flag%type;
    l_prod_family_grp_code      zx_evnt_cls_mappings.prod_family_grp_code%type;
    l_event_class_mapping_id      zx_evnt_cls_mappings.event_class_mapping_id%type;
    l_summarization_flag          zx_evnt_cls_mappings.summarization_flag%TYPE;

  BEGIN

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := null_event_class_rec;

    SELECT reversing_appln_id,
           reversing_entity_code,
           reversing_evnt_cls_code,
           reversing_trx_id
    INTO   l_appln_id,
           l_entity_code,
           l_evnt_cls_code,
           l_trx_id
    FROM   ZX_REVERSE_DIST_GT
    WHERE  rownum = 1;

    /* ----------------------------------------------------------------------+
     | Bug 3129063 - Setting the Security Context for Subscription           |
     + ----------------------------------------------------------------------*/
     set_security_context(l_appln_id,
                          l_entity_code,
                          l_evnt_cls_code,
                          l_trx_id,
                          l_return_status
                         );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RETURN;
    END IF;

    /* ----------------------------------------------------------------------+
     |      Get Tax Event Class                                              |
     + ----------------------------------------------------------------------*/
      get_tax_event_class (l_return_status
                          ,l_appln_id
                          ,l_entity_code
                          ,l_evnt_cls_code
                          ,l_tx_evnt_cls_code
                          ,l_ref_appln_id
                          ,l_record_flag               -- Bug 5200373
                          ,l_record_for_partners_flag  -- Bug 5200373
                          ,l_prod_family_grp_code      -- Bug 5200373
                          ,l_event_class_mapping_id      -- Bug 5200373
                          ,l_summarization_flag
                          );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         RETURN;
       END IF;


       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
          'application_id: '||l_appln_id||
          ', entity_code: '||l_entity_code||
          ', event_class_code: '||l_evnt_cls_code||
          ', tax_event_class_code: '||l_tx_evnt_cls_code||
          ', reference_application_id: '||l_ref_appln_id||
          ', RETURN_STATUS = ' || x_return_status);
        END IF;

        IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
        END IF;
  END reverse_distributions;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  determine_recovery
--
--  DESCRIPTION
--  Validates and initializes parameters for determine_recovery published service
--
--  CALLED BY
--    ZX_API_PUB.determine_recovery
-----------------------------------------------------------------------
  PROCEDURE determine_recovery
  ( x_return_status        OUT    NOCOPY VARCHAR2,
    p_event_class_rec      IN OUT NOCOPY ZX_API_PUB.event_class_rec_type
  )IS
  l_api_name         CONSTANT VARCHAR2(30):= 'DETERMINE_RECOVERY';
  l_return_status    VARCHAR2(30);

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := null_event_class_rec;

    /* ----------------------------------------------------------------------+
     |      Get Tax Event Class                                              |
     + ----------------------------------------------------------------------*/
     get_tax_event_class (l_return_status
                          ,p_event_class_rec
                         );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;


    -- populate global event class record structure
    ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := p_event_class_rec;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
          'application_id: '||p_event_class_rec.application_id||
          ', entity_code: '||p_event_class_rec.entity_code||
          ', event_class_code: '||p_event_class_rec.event_class_code||
          ', internal_organization_id: '||p_event_class_rec.internal_organization_id||
          ', legal_entity_id: '||p_event_class_rec.legal_entity_id||
          ', first_pty_org_id: '||p_event_class_rec.first_pty_org_id||
          ', event_type_code: '||p_event_class_rec.event_type_code||
          ', trx_id: '||p_event_class_rec.trx_id||
          ', tax_event_class_code: '||p_event_class_rec.tax_event_class_code||
          ', tax_event_type_code: '||p_event_class_rec.tax_event_type_code||
          ', doc_status_code: '||p_event_class_rec.doc_status_code||
          ', RETURN_STATUS = ' || x_return_status);
    END IF;
    IF  ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
    END IF;
  END determine_recovery;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  override_recovery
--
--  DESCRIPTION
--  Validates and initializes parameters for override_recovery published service
--
--  CALLED BY
--    ZX_API_PUB.override_recovery
-----------------------------------------------------------------------
  PROCEDURE override_recovery
  ( x_return_status   OUT     NOCOPY VARCHAR2,
    p_event_class_rec IN OUT  NOCOPY ZX_API_PUB.event_class_rec_type,
    p_trx_rec         IN OUT  NOCOPY ZX_API_PUB.transaction_rec_type
  )IS
  l_api_name        CONSTANT VARCHAR2(30) := 'OVERRIDE_RECOVERY';
  l_return_status   VARCHAR2(30);

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := null_event_class_rec;

    /*------------------------------------------------------+
     |   Copy to Event Class Record                         |
     +------------------------------------------------------*/
     p_event_class_rec.INTERNAL_ORGANIZATION_ID :=  p_trx_rec.INTERNAL_ORGANIZATION_ID;
     p_event_class_rec.APPLICATION_ID           :=  p_trx_rec.APPLICATION_ID;
     p_event_class_rec.ENTITY_CODE              :=  p_trx_rec.ENTITY_CODE;
     p_event_class_rec.EVENT_CLASS_CODE         :=  p_trx_rec.EVENT_CLASS_CODE;
     p_event_class_rec.EVENT_TYPE_CODE          :=  p_trx_rec.EVENT_TYPE_CODE;
     p_event_class_rec.TRX_ID                   :=  p_trx_rec.TRX_ID;

   /* ----------------------------------------------------------------------+
     | Bug 3129063 - Setting the Security Context for Subscription           |
     + ----------------------------------------------------------------------*/
    get_tax_subscriber(p_event_class_rec,
                       l_return_status
                      );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

   /* ----------------------------------------------------------------------+
    |      Get Tax Event Class                                              |
    + ----------------------------------------------------------------------*/
    get_tax_event_class (l_return_status
                         ,p_trx_rec.application_id
                         ,p_trx_rec.entity_code
                         ,p_trx_rec.event_class_code
                         ,p_trx_rec.tax_event_class_code
                         ,p_event_class_rec.reference_application_id
                         ,p_event_class_rec.record_flag              -- Bug 5200373
                         ,p_event_class_rec.record_for_partners_flag -- Bug 5200373
                         ,p_event_class_rec.prod_family_grp_code     -- Bug 5200373
                         ,p_event_class_rec.event_class_mapping_id     -- Bug 5200373
                         ,p_event_class_rec.summarization_flag
                         );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

   /* ----------------------------------------------------------------------+
    |      Get Tax Event type                                               |
    + ----------------------------------------------------------------------*/
    get_tax_event_type (l_return_status
                        ,p_trx_rec.event_class_code
                        ,p_trx_rec.application_id
                        ,p_trx_rec.entity_code
                        ,p_trx_rec.event_type_code
                        ,p_trx_rec.tax_event_class_code
                        ,p_trx_rec.tax_event_type_code
                        ,p_trx_rec.doc_event_status
                       );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

   /* ----------------------------------------------------------------------+
    |      Check Required Parameters                                        |
    + ----------------------------------------------------------------------*/
    ZX_CHECK_REQUIRED_PARAMS_PKG.check_trx_rec(l_return_status,
                                               p_trx_rec
                                              );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

   /* ----------------------------------------------------------------------+
    |      Populating Event Class Record                                    |
    + ----------------------------------------------------------------------*/
    p_event_class_rec.first_pty_org_id     := p_trx_rec.FIRST_PTY_ORG_ID;
    p_event_class_rec.application_id       := p_trx_rec.APPLICATION_ID;
    p_event_class_rec.entity_code          := p_trx_rec.ENTITY_CODE;
    p_event_class_rec.event_class_code     := p_trx_rec.EVENT_CLASS_CODE;
    p_event_class_rec.tax_event_class_code := p_trx_rec.TAX_EVENT_CLASS_CODE;
    p_event_class_rec.trx_id               := p_trx_rec.TRX_ID;
    p_event_class_rec.event_type_code      := p_trx_rec.EVENT_TYPE_CODE;
    p_event_class_rec.tax_event_type_code  := p_trx_rec.TAX_EVENT_TYPE_CODE;

    p_event_class_rec.quote_flag           := 'N';

    -- populate global event class record structure
    ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := p_event_class_rec;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
          'application_id: '||p_event_class_rec.application_id||
          ', entity_code: '||p_event_class_rec.entity_code||
          ', event_class_code: '||p_event_class_rec.event_class_code||
          ', legal_entity_id: '||p_event_class_rec.legal_entity_id||
          ', first_pty_org_id: '||p_event_class_rec.first_pty_org_id||
          ', event_type_code: '||p_event_class_rec.event_type_code||
          ', trx_id: '||p_event_class_rec.trx_id||
          ', tax_event_class_code: '||p_event_class_rec.tax_event_class_code||
          ', tax_event_type_code: '||p_event_class_rec.tax_event_type_code||
          ', doc_status_code: '||p_event_class_rec.doc_status_code||
          ', quote_flag: '||p_event_class_rec.quote_flag||
          ', RETURN_STATUS = ' || x_return_status);
    END IF;
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
    END IF;
  END override_recovery;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  freeze_distribution_lines
--
--  DESCRIPTION
--  Validates and initializes parameters for freeze_distribution_lines published service
--
--  CALLED BY
--    ZX_API_PUB.freeze_distribution_lines
-----------------------------------------------------------------------
  PROCEDURE freeze_distribution_lines
  ( x_return_status   OUT    NOCOPY VARCHAR2,
    p_event_class_rec OUT    NOCOPY ZX_API_PUB.event_class_rec_type,
    p_trx_rec         IN OUT NOCOPY ZX_API_PUB.transaction_rec_type
  ) IS
    l_api_name           CONSTANT VARCHAR2(30):= 'FREEZE_DISTRIBUTION_LINES';
    l_return_status      VARCHAR2(30);
    l_ref_appln_id       NUMBER;

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := null_event_class_rec;

    /*------------------------------------------------------+
     |   Copy to Event Class Record                         |
     +------------------------------------------------------*/
     p_event_class_rec.INTERNAL_ORGANIZATION_ID :=  p_trx_rec.INTERNAL_ORGANIZATION_ID;
     p_event_class_rec.APPLICATION_ID           :=  p_trx_rec.APPLICATION_ID;
     p_event_class_rec.ENTITY_CODE              :=  p_trx_rec.ENTITY_CODE;
     p_event_class_rec.EVENT_CLASS_CODE         :=  p_trx_rec.EVENT_CLASS_CODE;
     p_event_class_rec.EVENT_TYPE_CODE          :=  p_trx_rec.EVENT_TYPE_CODE;
     p_event_class_rec.TRX_ID                   :=  p_trx_rec.TRX_ID;

    /* ----------------------------------------------------------------------+
     | Bug 3129063 - Setting the Security Context for Subscription           |
     + ----------------------------------------------------------------------*/
     get_tax_subscriber(p_event_class_rec,
                        l_return_status
                       );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RETURN;
    END IF;

   /* ----------------------------------------------------------------------+
    |      Get Tax Event Class                                              |
    + ----------------------------------------------------------------------*/
    get_tax_event_class (l_return_status
                         ,p_event_class_rec
                        );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

    p_trx_rec.tax_event_class_code := p_event_class_rec.tax_event_class_code;

   /* ----------------------------------------------------------------------+
    |      Get Tax Event Type                                               |
    + ----------------------------------------------------------------------*/
    get_tax_event_type (l_return_status
                        ,p_trx_rec.event_class_code
                        ,p_trx_rec.application_id
                        ,p_trx_rec.entity_code
                        ,p_trx_rec.event_type_code
                        ,p_trx_rec.tax_event_class_code
                        ,p_trx_rec.tax_event_type_code
                        ,p_trx_rec.doc_event_status
                       );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

   /* ----------------------------------------------------------------------+
    |      Check Required Parameters                                        |
    + ----------------------------------------------------------------------*/
    ZX_CHECK_REQUIRED_PARAMS_PKG.check_trx_rec(l_return_status,
                                               p_trx_rec
                                              );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

    -- populate global event class record structure
    ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := p_event_class_rec;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
          'application_id: '||p_trx_rec.application_id||
          ', entity_code: '||p_trx_rec.entity_code||
          ', event_class_code: '||p_trx_rec.event_class_code||
          ', event_type_code: '||p_trx_rec.event_type_code||
          ', trx_id: '||p_trx_rec.trx_id||
          ', tax_event_class_code: '||p_trx_rec.tax_event_class_code||
          ', tax_event_type_code: '||p_trx_rec.tax_event_type_code||
          ', doc_event_status: '||p_trx_rec.doc_event_status||
          ', RETURN_STATUS = ' || x_return_status);
    END IF;
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
    END IF;
  END freeze_distribution_lines;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  validate_document_for_tax
--
--  DESCRIPTION
--  Validates and initializes parameters for validate_document_for_tax published service
--
--  CALLED BY
--    ZX_API_PUB.validate_document_for_tax
-----------------------------------------------------------------------
  PROCEDURE validate_document_for_tax
  ( x_return_status    OUT    NOCOPY  VARCHAR2,
    p_event_class_rec  OUT    NOCOPY  ZX_API_PUB.event_class_rec_type,
    p_trx_rec          IN OUT NOCOPY  ZX_API_PUB.transaction_rec_type
  )IS
  l_api_name          CONSTANT VARCHAR2(30):= 'VALIDATE_DOCUMENT_FOR_TAX';
  l_return_status     VARCHAR2(30);
  l_ref_appln_id      NUMBER;
  l_effective_date    DATE;

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := null_event_class_rec;

    /*------------------------------------------------------+
     |   Copy to Event Class Record                         |
     +------------------------------------------------------*/
     p_event_class_rec.INTERNAL_ORGANIZATION_ID :=  p_trx_rec.INTERNAL_ORGANIZATION_ID;
     p_event_class_rec.APPLICATION_ID           :=  p_trx_rec.APPLICATION_ID;
     p_event_class_rec.ENTITY_CODE              :=  p_trx_rec.ENTITY_CODE;
     p_event_class_rec.EVENT_CLASS_CODE         :=  p_trx_rec.EVENT_CLASS_CODE;
     p_event_class_rec.EVENT_TYPE_CODE          :=  p_trx_rec.EVENT_TYPE_CODE;
     p_event_class_rec.TRX_ID                   :=  p_trx_rec.TRX_ID;

     /*-------------------------------------------------------------+
     | Initialize Event Class Record With Related Doc Date, Trx Date|
     | and Provisional Tax Determination Date --Bug 5617541         |
     +--------------------------------------------------------------*/
     BEGIN
        SELECT RELATED_DOC_DATE              ,
               TRX_DATE                      ,
               PROVNL_TAX_DETERMINATION_DATE
        INTO   p_event_class_rec.REL_DOC_DATE,
               p_event_class_rec.TRX_DATE    ,
               p_event_class_rec.PROVNL_TAX_DETERMINATION_DATE
        FROM   ZX_LINES_DET_FACTORS
	WHERE  APPLICATION_ID   = p_trx_rec.APPLICATION_ID
        AND    EVENT_CLASS_CODE = p_trx_rec.EVENT_CLASS_CODE
        AND    ENTITY_CODE      = p_trx_rec.ENTITY_CODE
        AND    TRX_ID           = p_trx_rec.TRX_ID
	AND    ROWNUM           = 1;
     EXCEPTION WHEN OTHERS THEN
        NULL;
     END;

    /* ----------------------------------------------------------------------+
     | Bug 3129063 - Setting the Security Context for Subscription           |
     + ----------------------------------------------------------------------*/
     get_tax_subscriber(p_event_class_rec,
                        l_return_status
                       );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

    /* ----------------------------------------------------------------------+
     |      Get Tax Event Class                                              |
     + ----------------------------------------------------------------------*/
    get_tax_event_class (l_return_status
                         ,p_trx_rec.application_id
                         ,p_trx_rec.entity_code
                         ,p_trx_rec.event_class_code
                         ,p_trx_rec.tax_event_class_code
                         ,l_ref_appln_id
                         ,p_event_class_rec.record_flag              -- Bug 5200373
                         ,p_event_class_rec.record_for_partners_flag -- Bug 5200373
                         ,p_event_class_rec.prod_family_grp_code     -- Bug 5200373
                         ,p_event_class_rec.event_class_mapping_id     -- Bug 5200373
                         ,p_event_class_rec.summarization_flag
                        );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;


   /* ----------------------------------------------------------------------+
    |      Get Tax Event Type                                               |
    + ----------------------------------------------------------------------*/
    get_tax_event_type (l_return_status
                        ,p_trx_rec.event_class_code
                        ,p_trx_rec.application_id
                        ,p_trx_rec.entity_code
                        ,p_trx_rec.event_type_code
                        ,p_trx_rec.tax_event_class_code
                        ,p_trx_rec.tax_event_type_code
                        ,p_trx_rec.doc_event_status
                       );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

    p_event_class_rec.tax_event_class_code := p_trx_rec.tax_event_class_code;
    p_event_class_rec.tax_event_type_code  := p_trx_rec.tax_event_type_code;
    p_event_class_rec.doc_status_code     := p_trx_rec.doc_event_status;

     /* ----------------------------------------------------------------------+
      |  Determine effective date                                             |
      + ----------------------------------------------------------------------*/
     determine_effective_date(p_event_class_rec,
                              l_effective_date,
                              l_return_status
                             );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
        RETURN;
     END IF;

    /* ----------------------------------------------------------------------+
     |      Populate Event Class Options                                     |
     + ----------------------------------------------------------------------*/
     populate_event_class_options(l_return_status,
                                  l_effective_date,
                                  p_event_class_rec
                                 );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RETURN;
     END IF;

   /* ----------------------------------------------------------------------+
    |      Check Trx Rec                                                    |
    + ----------------------------------------------------------------------*/
    ZX_CHECK_REQUIRED_PARAMS_PKG.check_trx_rec(l_return_status,
                                               p_trx_rec
                                              );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

    -- populate global event class record structure
    ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := p_event_class_rec;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
          'application_id: '||p_event_class_rec.application_id||
          ', entity_code: '||p_event_class_rec.entity_code||
          ', event_class_code: '||p_event_class_rec.event_class_code||
          ', internal_organization_id: '||p_event_class_rec.internal_organization_id||
          ', legal_entity_id: '||p_event_class_rec.legal_entity_id||
          ', first_pty_org_id: '||p_event_class_rec.first_pty_org_id||
          ', ledger_id: '||p_event_class_rec.ledger_id||
          ', reference_application_id: '||p_event_class_rec.reference_application_id||
          ', event_type_code: '||p_event_class_rec.event_type_code||
          ', trx_id: '||p_event_class_rec.trx_id||
          ', trx_date: '||p_event_class_rec.trx_date||
          ', rel_doc_date: '||p_event_class_rec.rel_doc_date||
          ', trx_currency_code: '||p_event_class_rec.trx_currency_code||
          ', currency_conversion_type: '||p_event_class_rec.currency_conversion_type||
          ', currency_conversion_rate: '||p_event_class_rec.currency_conversion_rate||
          ', currency_conversion_date: '||p_event_class_rec.currency_conversion_date||
          ', rounding_ship_to_party_id: '||p_event_class_rec.rounding_ship_to_party_id||
          ', rounding_ship_from_party_id: '||p_event_class_rec.rounding_ship_from_party_id||
          ', rounding_bill_to_party_id: '||p_event_class_rec.rounding_bill_to_party_id||
          ', rounding_bill_from_party_id: '||p_event_class_rec.rounding_bill_from_party_id||
          ', rndg_ship_to_party_site_id: '||p_event_class_rec.rndg_ship_to_party_site_id||
          ', rndg_ship_from_party_site_id: '||p_event_class_rec.rndg_ship_from_party_site_id||
          ', rndg_bill_to_party_site_id: '||p_event_class_rec.rndg_bill_to_party_site_id||
          ', rndg_bill_from_party_site_id: '||p_event_class_rec.rndg_bill_from_party_site_id||
          ', tax_event_class_code: '||p_event_class_rec.tax_event_class_code||
          ', tax_event_type_code: '||p_event_class_rec.tax_event_type_code||
          ', doc_status_code: '||p_event_class_rec.doc_status_code||
          ', Det_Factor_Templ_Code: '||p_event_class_rec.det_factor_templ_code||
          ', Default_Rounding_Level_Code: '||p_event_class_rec.default_rounding_level_code||
          ', rounding_level_hier1: '||p_event_class_rec.rounding_level_hier_1_code||
          ', rounding_level_hier2: '||p_event_class_rec.rounding_level_hier_2_code||
          ', rounding_level_hier3: '||p_event_class_rec.rounding_level_hier_3_code||
          ', rounding_level_hier4: '||p_event_class_rec.rounding_level_hier_4_code||
          ', rdng_ship_to_pty_tx_prof_id: '||p_event_class_rec.rdng_ship_to_pty_tx_prof_id||
          ', rdng_ship_from_pty_tx_prof_id: '||p_event_class_rec.rdng_ship_from_pty_tx_prof_id||
          ', rdng_bill_to_pty_tx_prof_id: '||p_event_class_rec.rdng_bill_to_pty_tx_prof_id||
          ', rdng_bill_from_pty_tx_prof_id: '||p_event_class_rec.rdng_bill_from_pty_tx_prof_id||
          ', rdng_ship_to_pty_tx_p_st_id: '||p_event_class_rec.rdng_ship_to_pty_tx_p_st_id||
          ', rdng_ship_from_pty_tx_p_st_id: '||p_event_class_rec.rdng_ship_from_pty_tx_p_st_id||
          ', rdng_bill_to_pty_tx_p_st_id: '||p_event_class_rec.rdng_bill_to_pty_tx_p_st_id||
          ', rdng_bill_from_pty_tx_p_st_id: '||p_event_class_rec.rdng_bill_from_pty_tx_p_st_id||
          ', allow_manual_lin_recalc_flag: '||p_event_class_rec.allow_manual_lin_recalc_flag||
          ', allow_manual_lines_flag: '||p_event_class_rec.allow_manual_lines_flag||
          ', allow_override_flag: '||p_event_class_rec.allow_override_flag||
          ', enforce_tax_from_acct_flag: '||p_event_class_rec.enforce_tax_from_acct_flag||
          ', perform_additional_applicability_for_import_flag: '||p_event_class_rec.perf_addnl_appl_for_imprt_flag||
          ', record_flag: '||p_event_class_rec.record_flag||
          ', quote_flag: '||p_event_class_rec.quote_flag||
          ', normal_sign_flag: '||p_event_class_rec.normal_sign_flag||
          ', offset_tax_basis_code: '||p_event_class_rec.offset_tax_basis_code||
          ', tax_tolerance: '||p_event_class_rec.tax_tolerance||
          ', tax_tol_amt_range: '||p_event_class_rec.tax_tol_amt_range ||
          ', allow_offset_tax_calc_flag: '||p_event_class_rec.allow_offset_tax_calc_flag||
          ', self_assess_tax_lines_flag: '||p_event_class_rec.self_assess_tax_lines_flag||
          ', tax_recovery_flag: '||p_event_class_rec.tax_recovery_flag||
          ', allow_cancel_tax_lines_flag: '||p_event_class_rec.allow_cancel_tax_lines_flag||
          ', allow_man_tax_only_lines_flag: '||p_event_class_rec.allow_man_tax_only_lines_flag||
          ', enable_mrc_flag: '||p_event_class_rec.enable_mrc_flag||
          ', tax_reporting_flag: '||p_event_class_rec.tax_reporting_flag||
          ', enter_ovrd_incl_tax_lines_flag: '||p_event_class_rec.enter_ovrd_incl_tax_lines_flag||
          ', ctrl_eff_ovrd_calc_lines_flag: '||p_event_class_rec.ctrl_eff_ovrd_calc_lines_flag||
          ', summarization_flag: '||p_event_class_rec.summarization_flag||
          ', retain_summ_tax_line_id_flag: '||p_event_class_rec.retain_summ_tax_line_id_flag||
          ', tax_variance_calc_flag: '||p_event_class_rec.tax_variance_calc_flag||
          ', prod_family_grp_code: '||p_event_class_rec.prod_family_grp_code||
          ', record_for_partners_flag: '||p_event_class_rec.record_for_partners_flag||
          ', manual_lines_for_partner_flag: '||p_event_class_rec.manual_lines_for_partner_flag||
          ', man_tax_only_lin_for_ptnr_flag: '||p_event_class_rec.man_tax_only_lin_for_ptnr_flag||
          ', always_use_ebtax_for_calc_flag: '||p_event_class_rec.always_use_ebtax_for_calc_flag||
          ', enforce_tax_from_ref_doc_flag: '||p_event_class_rec.enforce_tax_from_ref_doc_flag||
          ', process_for_applicability_flag: '||p_event_class_rec.process_for_applicability_flag||
          ', allow_exemptions_flag: '||p_event_class_rec.allow_exemptions_flag||
          ', sup_cust_acct_type: '||p_event_class_rec.sup_cust_acct_type||
          ', intgrtn_det_factors_ui_flag: '||p_event_class_rec.intgrtn_det_factors_ui_flag||
          ', exmptn_pty_basis_hier_1_code: '||p_event_class_rec.exmptn_pty_basis_hier_1_code||
          ', exmptn_pty_basis_hier_2_code: '||p_event_class_rec.exmptn_pty_basis_hier_2_code||
          ', tax_method_code: '||p_event_class_rec.tax_method_code||
          ', inclusive_tax_used_flag: '||p_event_class_rec.inclusive_tax_used_flag||
          ', tax_use_customer_exempt_flag: '||p_event_class_rec.tax_use_customer_exempt_flag||
          ', tax_use_product_exempt_flag: '||p_event_class_rec.tax_use_product_exempt_flag||
          ', tax_use_loc_exc_rate_flag: '||p_event_class_rec.tax_use_loc_exc_rate_flag||
          ', tax_allow_compound_flag: '||p_event_class_rec.tax_allow_compound_flag||
          ', use_tax_classification_flag: '||p_event_class_rec.use_tax_classification_flag||
          ', allow_tax_rounding_ovrd_flag: '||p_event_class_rec.allow_tax_rounding_ovrd_flag||
          ', home_country_default_flag: '||p_event_class_rec.home_country_default_flag||
          ', RETURN_STATUS = ' || x_return_status);
    END IF;
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
    END IF;
  END validate_document_for_tax;


-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  discard_tax_only_lines
--
--  DESCRIPTION
--  Validates and initializes parameters for discard_tax_only_lines published service
--
--  CALLED BY
--    ZX_API_PUB.discard_tax_only_lines
-----------------------------------------------------------------------
  PROCEDURE discard_tax_only_lines
  (  x_return_status  OUT NOCOPY VARCHAR2,
     p_trx_rec        IN         ZX_API_PUB.transaction_rec_type
  ) IS
  l_api_name        CONSTANT VARCHAR2(30):= 'DISCARD_TAX_ONLY_LINES';
  l_return_status   VARCHAR2(30);

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* ----------------------------------------------------------------------+
     | Bug 3129063 - Setting the Security Context for Subscription           |
     + ----------------------------------------------------------------------*/
     set_security_context(p_trx_rec.application_id,
                          p_trx_rec.entity_code,
                          p_trx_rec.event_class_code,
                          p_trx_rec.trx_id,
                          l_return_status
                         );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RETURN;
    END IF;


   /* ----------------------------------------------------------------------+
    |      Check Required Parameters                                        |
    + ----------------------------------------------------------------------*/
    ZX_CHECK_REQUIRED_PARAMS_PKG.check_trx_rec(l_return_status,
                                               p_trx_rec
                                              );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
          'application_id: '||p_trx_rec.application_id||
          ', entity_code: '||p_trx_rec.entity_code||
          ', event_class_code: '||p_trx_rec.event_class_code||
          ', event_type_code: '||p_trx_rec.event_type_code||
          ', trx_id: '||p_trx_rec.trx_id||
          ', RETURN_STATUS = ' || x_return_status);
    END IF;
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
    END IF;
  END discard_tax_only_lines;


-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  insupd_line_det_factors
--
--  DESCRIPTION
--  Validates and initializes parameters for the insert/update published service
--
--  CALLED BY
--    ZX_API_PUB.insert_line_det_factors
--    ZX_API_PUB.update_line_det_factos
--    ZX_API_PUB.update_det_factors_hdr
--    ZX_API_PUB.copy_insert_line_det_factors
-----------------------------------------------------------------------
  PROCEDURE insupd_line_det_factors
  ( x_return_status    OUT    NOCOPY VARCHAR2,
    p_event_class_rec  IN OUT NOCOPY ZX_API_PUB.event_class_rec_type,
    p_trx_line_index   IN     NUMBER
  )IS
  l_api_name            CONSTANT  VARCHAR2(30):= 'INSUPD_LINE_DET_FACTORS';
  l_return_status                 VARCHAR2(30);
  l_effective_date                DATE;
  l_ship_from_location_id         NUMBER;
  l_bill_from_location_id         NUMBER;
  l_ship_to_location_id           NUMBER;
  l_bill_to_location_id           NUMBER;

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := null_event_class_rec;

    /* ----------------------------------------------------------------------+
     |      Get Tax Event Class                                              |
     + ----------------------------------------------------------------------*/
    get_tax_event_class (l_return_status
                         ,p_event_class_rec
                        );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

    /* ----------------------------------------------------------------------+
     |  Determine effective date                                             |
     + ----------------------------------------------------------------------*/
     determine_effective_date(p_event_class_rec,
                              l_effective_date,
                              l_return_status
                              );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RETURN;
     END IF;


    /* ----------------------------------------------------------------------+
     | Bug 3129063 -      Setting the Security Context for Subscription      |
     + ----------------------------------------------------------------------*/

    get_tax_subscriber(p_event_class_rec,
                       l_effective_date ,
                       l_return_status
                      );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

   /* ----------------------------------------------------------------------+
    |      Get Tax Event Type                                               |
    + ----------------------------------------------------------------------*/
    get_tax_event_type (l_return_status
                        ,p_event_class_rec.event_class_code
                        ,p_event_class_rec.application_id
                        ,p_event_class_rec.entity_code
                        ,p_event_class_rec.event_type_code
                        ,p_event_class_rec.tax_event_class_code
                        ,p_event_class_rec.tax_event_type_code
                        ,p_event_class_rec.doc_status_code
                        );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

    /* ----------------------------------------------------------------------+
     |      Get the locations for parties                                    |
     + ----------------------------------------------------------------------*/
     IF ZX_API_PUB.G_PUB_SRVC <> 'UPDATE_DET_FACTORS_HDR' THEN

       get_loc_id_and_ptp_ids(p_event_class_rec  => p_event_class_rec,
                              p_trx_line_index  =>  p_trx_line_index,
                              x_return_status    => l_return_status
                             );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         RETURN;
       END IF;

      /* ----------------------------------------------------------------------+
       |      Check Required parameters                                        |
       + ----------------------------------------------------------------------*/
       --Skip validation if published service is copy_insert_line_det_factors
       IF ZX_API_PUB.G_PUB_SRVC <> 'COPY_INSERT_LINE_DET_FACTORS' THEN
         ZX_CHECK_REQUIRED_PARAMS_PKG.check_trx_headers_tbl(l_return_status,
                                                            p_event_class_rec
                                                           );

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_return_status := l_return_status;
           RETURN;
         END IF;


        /* ----------------------------------------------------------------------+
         |      Check Required parameters                                        |
         + ----------------------------------------------------------------------*/
         ZX_CHECK_REQUIRED_PARAMS_PKG.check_trx_lines(l_return_status,
                                                      p_event_class_rec
                                                     );

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_return_status := l_return_status;
           RETURN;
         END IF;
       END IF; --G_PUB_SRVC <> 'COPY_INSERT_LINE_DET_FACTORS'
     END IF; --G_PUB_SRVC <> 'UPDATE_DET_FACTORS_HDR

    /* ----------------------------------------------------------------------+
     |      Populate Event Class Options                                     |
     + ----------------------------------------------------------------------*/
    populate_event_class_options(l_return_status,
                                 l_effective_date,
                                 p_event_class_rec
                                );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RETURN;
     END IF;

    /* ----------------------------------------------------------------------+
     |      Populate Application Product Options                             |
     + ----------------------------------------------------------------------*/
     populate_appl_product_options(l_return_status,
                                   p_event_class_rec
                                  );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RETURN;
     END IF;

     -- populate global event class record structure
     ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := p_event_class_rec;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
          'application_id: '||p_event_class_rec.application_id||
          ', entity_code: '||p_event_class_rec.entity_code||
          ', event_class_code: '||p_event_class_rec.event_class_code||
          ', internal_organization_id: '||p_event_class_rec.internal_organization_id||
          ', legal_entity_id: '||p_event_class_rec.legal_entity_id||
          ', first_pty_org_id: '||p_event_class_rec.first_pty_org_id||
          ', ledger_id: '||p_event_class_rec.ledger_id||
          ', reference_application_id: '||p_event_class_rec.reference_application_id||
          ', event_type_code: '||p_event_class_rec.event_type_code||
          ', trx_id: '||p_event_class_rec.trx_id||
          ', trx_date: '||p_event_class_rec.trx_date||
          ', rel_doc_date: '||p_event_class_rec.rel_doc_date||
          ', trx_currency_code: '||p_event_class_rec.trx_currency_code||
          ', currency_conversion_type: '||p_event_class_rec.currency_conversion_type||
          ', currency_conversion_rate: '||p_event_class_rec.currency_conversion_rate||
          ', currency_conversion_date: '||p_event_class_rec.currency_conversion_date||
          ', rounding_ship_to_party_id: '||p_event_class_rec.rounding_ship_to_party_id||
          ', rounding_ship_from_party_id: '||p_event_class_rec.rounding_ship_from_party_id||
          ', rounding_bill_to_party_id: '||p_event_class_rec.rounding_bill_to_party_id||
          ', rounding_bill_from_party_id: '||p_event_class_rec.rounding_bill_from_party_id||
          ', rndg_ship_to_party_site_id: '||p_event_class_rec.rndg_ship_to_party_site_id||
          ', rndg_ship_from_party_site_id: '||p_event_class_rec.rndg_ship_from_party_site_id||
          ', rndg_bill_to_party_site_id: '||p_event_class_rec.rndg_bill_to_party_site_id||
          ', rndg_bill_from_party_site_id: '||p_event_class_rec.rndg_bill_from_party_site_id||
          ', tax_event_class_code: '||p_event_class_rec.tax_event_class_code||
          ', tax_event_type_code: '||p_event_class_rec.tax_event_type_code||
          ', doc_status_code: '||p_event_class_rec.doc_status_code||
          ', Det_Factor_Templ_Code: '||p_event_class_rec.det_factor_templ_code||
          ', Default_Rounding_Level_Code: '||p_event_class_rec.default_rounding_level_code||
          ', rounding_level_hier1: '||p_event_class_rec.rounding_level_hier_1_code||
          ', rounding_level_hier2: '||p_event_class_rec.rounding_level_hier_2_code||
          ', rounding_level_hier3: '||p_event_class_rec.rounding_level_hier_3_code||
          ', rounding_level_hier4: '||p_event_class_rec.rounding_level_hier_4_code||
          ', rdng_ship_to_pty_tx_prof_id: '||p_event_class_rec.rdng_ship_to_pty_tx_prof_id||
          ', rdng_ship_from_pty_tx_prof_id: '||p_event_class_rec.rdng_ship_from_pty_tx_prof_id||
          ', rdng_bill_to_pty_tx_prof_id: '||p_event_class_rec.rdng_bill_to_pty_tx_prof_id||
          ', rdng_bill_from_pty_tx_prof_id: '||p_event_class_rec.rdng_bill_from_pty_tx_prof_id||
          ', rdng_ship_to_pty_tx_p_st_id: '||p_event_class_rec.rdng_ship_to_pty_tx_p_st_id||
          ', rdng_ship_from_pty_tx_p_st_id: '||p_event_class_rec.rdng_ship_from_pty_tx_p_st_id||
          ', rdng_bill_to_pty_tx_p_st_id: '||p_event_class_rec.rdng_bill_to_pty_tx_p_st_id||
          ', rdng_bill_from_pty_tx_p_st_id: '||p_event_class_rec.rdng_bill_from_pty_tx_p_st_id||
          ', allow_manual_lin_recalc_flag: '||p_event_class_rec.allow_manual_lin_recalc_flag||
          ', allow_manual_lines_flag: '||p_event_class_rec.allow_manual_lines_flag||
          ', allow_override_flag: '||p_event_class_rec.allow_override_flag||
          ', enforce_tax_from_acct_flag: '||p_event_class_rec.enforce_tax_from_acct_flag||
          ', perform_additional_applicability_for_import_flag: '||p_event_class_rec.perf_addnl_appl_for_imprt_flag||
          ', record_flag: '||p_event_class_rec.record_flag||
          ', quote_flag: '||p_event_class_rec.quote_flag||
          ', normal_sign_flag: '||p_event_class_rec.normal_sign_flag||
          ', offset_tax_basis_code: '||p_event_class_rec.offset_tax_basis_code||
          ', tax_tolerance: '||p_event_class_rec.tax_tolerance||
          ', tax_tol_amt_range: '||p_event_class_rec.tax_tol_amt_range ||
          ', allow_offset_tax_calc_flag: '||p_event_class_rec.allow_offset_tax_calc_flag||
          ', self_assess_tax_lines_flag: '||p_event_class_rec.self_assess_tax_lines_flag||
          ', tax_recovery_flag: '||p_event_class_rec.tax_recovery_flag||
          ', allow_cancel_tax_lines_flag: '||p_event_class_rec.allow_cancel_tax_lines_flag||
          ', allow_man_tax_only_lines_flag: '||p_event_class_rec.allow_man_tax_only_lines_flag||
          ', enable_mrc_flag: '||p_event_class_rec.enable_mrc_flag||
          ', tax_reporting_flag: '||p_event_class_rec.tax_reporting_flag||
          ', enter_ovrd_incl_tax_lines_flag: '||p_event_class_rec.enter_ovrd_incl_tax_lines_flag||
          ', ctrl_eff_ovrd_calc_lines_flag: '||p_event_class_rec.ctrl_eff_ovrd_calc_lines_flag||
          ', summarization_flag: '||p_event_class_rec.summarization_flag||
          ', retain_summ_tax_line_id_flag: '||p_event_class_rec.retain_summ_tax_line_id_flag||
          ', tax_variance_calc_flag: '||p_event_class_rec.tax_variance_calc_flag||
          ', prod_family_grp_code: '||p_event_class_rec.prod_family_grp_code||
          ', record_for_partners_flag: '||p_event_class_rec.record_for_partners_flag||
          ', manual_lines_for_partner_flag: '||p_event_class_rec.manual_lines_for_partner_flag||
          ', man_tax_only_lin_for_ptnr_flag: '||p_event_class_rec.man_tax_only_lin_for_ptnr_flag||
          ', always_use_ebtax_for_calc_flag: '||p_event_class_rec.always_use_ebtax_for_calc_flag||
          ', enforce_tax_from_ref_doc_flag: '||p_event_class_rec.enforce_tax_from_ref_doc_flag||
          ', process_for_applicability_flag: '||p_event_class_rec.process_for_applicability_flag||
          ', allow_exemptions_flag: '||p_event_class_rec.allow_exemptions_flag||
          ', sup_cust_acct_type: '||p_event_class_rec.sup_cust_acct_type||
          ', intgrtn_det_factors_ui_flag: '||p_event_class_rec.intgrtn_det_factors_ui_flag||
          ', exmptn_pty_basis_hier_1_code: '||p_event_class_rec.exmptn_pty_basis_hier_1_code||
          ', exmptn_pty_basis_hier_2_code: '||p_event_class_rec.exmptn_pty_basis_hier_2_code||
          ', tax_method_code: '||p_event_class_rec.tax_method_code||
          ', inclusive_tax_used_flag: '||p_event_class_rec.inclusive_tax_used_flag||
          ', tax_use_customer_exempt_flag: '||p_event_class_rec.tax_use_customer_exempt_flag||
          ', tax_use_product_exempt_flag: '||p_event_class_rec.tax_use_product_exempt_flag||
          ', tax_use_loc_exc_rate_flag: '||p_event_class_rec.tax_use_loc_exc_rate_flag||
          ', tax_allow_compound_flag: '||p_event_class_rec.tax_allow_compound_flag||
          ', use_tax_classification_flag: '||p_event_class_rec.use_tax_classification_flag||
          ', allow_tax_rounding_ovrd_flag: '||p_event_class_rec.allow_tax_rounding_ovrd_flag||
          ', home_country_default_flag: '||p_event_class_rec.home_country_default_flag||
          ', RETURN_STATUS = ' || l_return_status);
     END IF;

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
     END IF;
  END insupd_line_det_factors;



-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  get_default_tax_det_attrs
--
--  DESCRIPTION
--  Validates and initializes parameters for get_default_tax_det_attrs published service
--
--  CALLED BY
--    ZX_API_PUB.get_default_tax_det_attrs
-----------------------------------------------------------------------
  PROCEDURE get_default_tax_det_attrs(
    x_return_status    OUT    NOCOPY VARCHAR2,
    p_event_class_rec  IN OUT NOCOPY ZX_API_PUB.event_class_rec_type
  )IS
  l_api_name            CONSTANT  VARCHAR2(30):= 'GET_DEFAULT_TAX_DET_ATTRS';
  l_return_status                 VARCHAR2(30);
  l_effective_date                DATE;
  l_ship_from_location_id         NUMBER;
  l_bill_from_location_id         NUMBER;
  l_ship_to_location_id           NUMBER;
  l_bill_to_location_id           NUMBER;

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := null_event_class_rec;

    /* ----------------------------------------------------------------------+
     |      Get Tax Event Class                                              |
     + ----------------------------------------------------------------------*/
    get_tax_event_class (l_return_status
                         ,p_event_class_rec
                        );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

    /* ----------------------------------------------------------------------+
     |  Determine effective date                                             |
     + ----------------------------------------------------------------------*/
     determine_effective_date(p_event_class_rec,
                              l_effective_date,
                              l_return_status
                              );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RETURN;
     END IF;


    /* ----------------------------------------------------------------------+
     | Bug 3129063 -      Setting the Security Context for Subscription      |
     + ----------------------------------------------------------------------*/
    get_tax_subscriber(p_event_class_rec,
                       l_effective_date ,
                       l_return_status
                      );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

   /* ----------------------------------------------------------------------+
    |      Get Tax Event Type                                               |
    + ----------------------------------------------------------------------*/
    get_tax_event_type (l_return_status
                        ,p_event_class_rec.event_class_code
                        ,p_event_class_rec.application_id
                        ,p_event_class_rec.entity_code
                        ,p_event_class_rec.event_type_code
                        ,p_event_class_rec.tax_event_class_code
                        ,p_event_class_rec.tax_event_type_code
                        ,p_event_class_rec.doc_status_code
                        );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := l_return_status;
      RETURN;
    END IF;

    /* ----------------------------------------------------------------------+
     |      Populate Event Class Options                                     |
     + ----------------------------------------------------------------------*/
     populate_event_class_options(l_return_status,
                                  l_effective_date,
                                  p_event_class_rec
                                 );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RETURN;
     END IF;

    /* ----------------------------------------------------------------------+
     |      Populate Application Product Options                             |
     + ----------------------------------------------------------------------*/
     populate_appl_product_options(l_return_status,
                                   p_event_class_rec
          			              );

     -- populate global event class record structure
     ZX_GLOBAL_STRUCTURES_PKG.g_event_class_rec := p_event_class_rec;

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RETURN;
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
          'application_id: '||p_event_class_rec.application_id||
          ', entity_code: '||p_event_class_rec.entity_code||
          ', event_class_code: '||p_event_class_rec.event_class_code||
          ', internal_organization_id: '||p_event_class_rec.internal_organization_id||
          ', legal_entity_id: '||p_event_class_rec.legal_entity_id||
          ', first_pty_org_id: '||p_event_class_rec.first_pty_org_id||
          ', ledger_id: '||p_event_class_rec.ledger_id||
          ', reference_application_id: '||p_event_class_rec.reference_application_id||
          ', event_type_code: '||p_event_class_rec.event_type_code||
          ', trx_id: '||p_event_class_rec.trx_id||
          ', trx_date: '||p_event_class_rec.trx_date||
          ', rel_doc_date: '||p_event_class_rec.rel_doc_date||
          ', trx_currency_code: '||p_event_class_rec.trx_currency_code||
          ', currency_conversion_type: '||p_event_class_rec.currency_conversion_type||
          ', currency_conversion_rate: '||p_event_class_rec.currency_conversion_rate||
          ', currency_conversion_date: '||p_event_class_rec.currency_conversion_date||
          ', rounding_ship_to_party_id: '||p_event_class_rec.rounding_ship_to_party_id||
          ', rounding_ship_from_party_id: '||p_event_class_rec.rounding_ship_from_party_id||
          ', rounding_bill_to_party_id: '||p_event_class_rec.rounding_bill_to_party_id||
          ', rounding_bill_from_party_id: '||p_event_class_rec.rounding_bill_from_party_id||
          ', rndg_ship_to_party_site_id: '||p_event_class_rec.rndg_ship_to_party_site_id||
          ', rndg_ship_from_party_site_id: '||p_event_class_rec.rndg_ship_from_party_site_id||
          ', rndg_bill_to_party_site_id: '||p_event_class_rec.rndg_bill_to_party_site_id||
          ', rndg_bill_from_party_site_id: '||p_event_class_rec.rndg_bill_from_party_site_id||
          ', tax_event_class_code: '||p_event_class_rec.tax_event_class_code||
          ', tax_event_type_code: '||p_event_class_rec.tax_event_type_code||
          ', doc_status_code: '||p_event_class_rec.doc_status_code||
          ', Det_Factor_Templ_Code: '||p_event_class_rec.det_factor_templ_code||
          ', Default_Rounding_Level_Code: '||p_event_class_rec.default_rounding_level_code||
          ', rounding_level_hier1: '||p_event_class_rec.rounding_level_hier_1_code||
          ', rounding_level_hier2: '||p_event_class_rec.rounding_level_hier_2_code||
          ', rounding_level_hier3: '||p_event_class_rec.rounding_level_hier_3_code||
          ', rounding_level_hier4: '||p_event_class_rec.rounding_level_hier_4_code||
          ', rdng_ship_to_pty_tx_prof_id: '||p_event_class_rec.rdng_ship_to_pty_tx_prof_id||
          ', rdng_ship_from_pty_tx_prof_id: '||p_event_class_rec.rdng_ship_from_pty_tx_prof_id||
          ', rdng_bill_to_pty_tx_prof_id: '||p_event_class_rec.rdng_bill_to_pty_tx_prof_id||
          ', rdng_bill_from_pty_tx_prof_id: '||p_event_class_rec.rdng_bill_from_pty_tx_prof_id||
          ', rdng_ship_to_pty_tx_p_st_id: '||p_event_class_rec.rdng_ship_to_pty_tx_p_st_id||
          ', rdng_ship_from_pty_tx_p_st_id: '||p_event_class_rec.rdng_ship_from_pty_tx_p_st_id||
          ', rdng_bill_to_pty_tx_p_st_id: '||p_event_class_rec.rdng_bill_to_pty_tx_p_st_id||
          ', rdng_bill_from_pty_tx_p_st_id: '||p_event_class_rec.rdng_bill_from_pty_tx_p_st_id||
          ', allow_manual_lin_recalc_flag: '||p_event_class_rec.allow_manual_lin_recalc_flag||
          ', allow_manual_lines_flag: '||p_event_class_rec.allow_manual_lines_flag||
          ', allow_override_flag: '||p_event_class_rec.allow_override_flag||
          ', enforce_tax_from_acct_flag: '||p_event_class_rec.enforce_tax_from_acct_flag||
          ', perform_additional_applicability_for_import_flag: '||p_event_class_rec.perf_addnl_appl_for_imprt_flag||
          ', record_flag: '||p_event_class_rec.record_flag||
          ', quote_flag: '||p_event_class_rec.quote_flag||
          ', normal_sign_flag: '||p_event_class_rec.normal_sign_flag||
          ', offset_tax_basis_code: '||p_event_class_rec.offset_tax_basis_code||
          ', tax_tolerance: '||p_event_class_rec.tax_tolerance||
          ', tax_tol_amt_range: '||p_event_class_rec.tax_tol_amt_range ||
          ', allow_offset_tax_calc_flag: '||p_event_class_rec.allow_offset_tax_calc_flag||
          ', self_assess_tax_lines_flag: '||p_event_class_rec.self_assess_tax_lines_flag||
          ', tax_recovery_flag: '||p_event_class_rec.tax_recovery_flag||
          ', allow_cancel_tax_lines_flag: '||p_event_class_rec.allow_cancel_tax_lines_flag||
          ', allow_man_tax_only_lines_flag: '||p_event_class_rec.allow_man_tax_only_lines_flag||
          ', enable_mrc_flag: '||p_event_class_rec.enable_mrc_flag||
          ', tax_reporting_flag: '||p_event_class_rec.tax_reporting_flag||
          ', enter_ovrd_incl_tax_lines_flag: '||p_event_class_rec.enter_ovrd_incl_tax_lines_flag||
          ', ctrl_eff_ovrd_calc_lines_flag: '||p_event_class_rec.ctrl_eff_ovrd_calc_lines_flag||
          ', summarization_flag: '||p_event_class_rec.summarization_flag||
          ', retain_summ_tax_line_id_flag: '||p_event_class_rec.retain_summ_tax_line_id_flag||
          ', tax_variance_calc_flag: '||p_event_class_rec.tax_variance_calc_flag||
          ', prod_family_grp_code: '||p_event_class_rec.prod_family_grp_code||
          ', record_for_partners_flag: '||p_event_class_rec.record_for_partners_flag||
          ', manual_lines_for_partner_flag: '||p_event_class_rec.manual_lines_for_partner_flag||
          ', man_tax_only_lin_for_ptnr_flag: '||p_event_class_rec.man_tax_only_lin_for_ptnr_flag||
          ', always_use_ebtax_for_calc_flag: '||p_event_class_rec.always_use_ebtax_for_calc_flag||
          ', enforce_tax_from_ref_doc_flag: '||p_event_class_rec.enforce_tax_from_ref_doc_flag||
          ', process_for_applicability_flag: '||p_event_class_rec.process_for_applicability_flag||
          ', allow_exemptions_flag: '||p_event_class_rec.allow_exemptions_flag||
          ', sup_cust_acct_type: '||p_event_class_rec.sup_cust_acct_type||
          ', intgrtn_det_factors_ui_flag: '||p_event_class_rec.intgrtn_det_factors_ui_flag||
          ', exmptn_pty_basis_hier_1_code: '||p_event_class_rec.exmptn_pty_basis_hier_1_code||
          ', exmptn_pty_basis_hier_2_code: '||p_event_class_rec.exmptn_pty_basis_hier_2_code||
          ', tax_method_code: '||p_event_class_rec.tax_method_code||
          ', inclusive_tax_used_flag: '||p_event_class_rec.inclusive_tax_used_flag||
          ', tax_use_customer_exempt_flag: '||p_event_class_rec.tax_use_customer_exempt_flag||
          ', tax_use_product_exempt_flag: '||p_event_class_rec.tax_use_product_exempt_flag||
          ', tax_use_loc_exc_rate_flag: '||p_event_class_rec.tax_use_loc_exc_rate_flag||
          ', tax_allow_compound_flag: '||p_event_class_rec.tax_allow_compound_flag||
          ', use_tax_classification_flag: '||p_event_class_rec.use_tax_classification_flag||
          ', allow_tax_rounding_ovrd_flag: '||p_event_class_rec.allow_tax_rounding_ovrd_flag||
          ', home_country_default_flag: '||p_event_class_rec.home_country_default_flag||
          ', RETURN_STATUS = ' || l_return_status);
     END IF;

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
     END IF;
  END get_default_tax_det_attrs;

PROCEDURE get_event_class_info(
     P_ENTITY_CODE         IN         ZX_EVNT_CLS_MAPPINGS.entity_code%TYPE,
     P_EVENT_CLASS_CODE    IN         ZX_EVNT_CLS_MAPPINGS.event_class_code%TYPE,
     P_APPLICATION_ID      IN         ZX_EVNT_CLS_MAPPINGS.application_id%TYPE,
     X_TBL_INDEX           OUT NOCOPY BINARY_INTEGER,
     X_RETURN_STATUS       OUT NOCOPY VARCHAR2)
is
  cursor c_evnt_class_info is
  SELECT
    EVENT_CLASS_CODE
    ,APPLICATION_ID
    ,ENTITY_CODE
    ,TAX_EVENT_CLASS_CODE
    ,RECORD_FLAG
    ,DET_FACTOR_TEMPL_CODE
    ,DEFAULT_ROUNDING_LEVEL_CODE
    ,ROUNDING_LEVEL_HIER_1_CODE
    ,ROUNDING_LEVEL_HIER_2_CODE
    ,ROUNDING_LEVEL_HIER_3_CODE
    ,ROUNDING_LEVEL_HIER_4_CODE
    ,ALLOW_MANUAL_LIN_RECALC_FLAG
    ,ALLOW_OVERRIDE_FLAG
    ,ALLOW_MANUAL_LINES_FLAG
    ,PERF_ADDNL_APPL_FOR_IMPRT_FLAG
    ,SHIP_TO_PARTY_TYPE
    ,SHIP_FROM_PARTY_TYPE
    ,POA_PARTY_TYPE
    ,POO_PARTY_TYPE
    ,PAYING_PARTY_TYPE
    ,OWN_HQ_PARTY_TYPE
    ,TRAD_HQ_PARTY_TYPE
    ,POI_PARTY_TYPE
    ,POD_PARTY_TYPE
    ,BILL_TO_PARTY_TYPE
    ,BILL_FROM_PARTY_TYPE
    ,TTL_TRNS_PARTY_TYPE
    ,MERCHANT_PARTY_TYPE
    ,SHIP_TO_PTY_SITE_TYPE
    ,SHIP_FROM_PTY_SITE_TYPE
    ,POA_PTY_SITE_TYPE
    ,POO_PTY_SITE_TYPE
    ,PAYING_PTY_SITE_TYPE
    ,OWN_HQ_PTY_SITE_TYPE
    ,TRAD_HQ_PTY_SITE_TYPE
    ,POI_PTY_SITE_TYPE
    ,POD_PTY_SITE_TYPE
    ,BILL_TO_PTY_SITE_TYPE
    ,BILL_FROM_PTY_SITE_TYPE
    ,TTL_TRNS_PTY_SITE_TYPE
    ,ENFORCE_TAX_FROM_ACCT_FLAG
    ,OFFSET_TAX_BASIS_CODE
    ,REFERENCE_APPLICATION_ID
    ,PROD_FAMILY_GRP_CODE
    ,ALLOW_OFFSET_TAX_CALC_FLAG
    ,SELF_ASSESS_TAX_LINES_FLAG
    ,TAX_RECOVERY_FLAG
    ,ALLOW_CANCEL_TAX_LINES_FLAG
    ,ALLOW_MAN_TAX_ONLY_LINES_FLAG
    ,TAX_VARIANCE_CALC_FLAG
    ,TAX_REPORTING_FLAG
    ,ENTER_OVRD_INCL_TAX_LINES_FLAG
    ,CTRL_EFF_OVRD_CALC_LINES_FLAG
    ,SUMMARIZATION_FLAG
    ,RETAIN_SUMM_TAX_LINE_ID_FLAG
    ,RECORD_FOR_PARTNERS_FLAG
    ,MANUAL_LINES_FOR_PARTNER_FLAG
    ,MAN_TAX_ONLY_LIN_FOR_PTNR_FLAG
    ,ALWAYS_USE_EBTAX_FOR_CALC_FLAG
    ,PROCESSING_PRECEDENCE
    ,EVENT_CLASS_MAPPING_ID
    ,ENFORCE_TAX_FROM_REF_DOC_FLAG
    ,PROCESS_FOR_APPLICABILITY_FLAG
    ,SUP_CUST_ACCT_TYPE_CODE
    ,DISPLAY_TAX_CLASSIF_FLAG
    ,INTGRTN_DET_FACTORS_UI_FLAG
    ,INTRCMP_TX_EVNT_CLS_CODE
    ,INTRCMP_SRC_ENTITY_CODE
    ,INTRCMP_SRC_EVNT_CLS_CODE
    ,INTRCMP_SRC_APPLN_ID
    ,ALLOW_EXEMPTIONS_FLAG
    ,ENABLE_MRC_FLAG
  from
    ZX_EVNT_CLS_MAPPINGS
  WHERE
        application_id = p_application_id
    AND entity_code = p_entity_code
    AND event_class_Code = p_event_class_code;

  l_index  binary_integer;

BEGIN

  x_return_status       := FND_API.G_RET_STS_SUCCESS;

  l_index := dbms_utility.get_hash_value(to_char(p_application_id)||p_entity_code||p_event_class_code,1,8192);

  IF ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl.EXISTS(l_index) then

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,'ZX_VALID_INIT_PKG.get_evnt_cls_info',
                         'Event class record found in cache ');
      END IF;

      X_TBL_INDEX := l_index;
      RETURN;

  ELSE

    FOR L_EVENT_CLASS_REC IN C_EVNT_CLASS_INFO LOOP

        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).EVENT_CLASS_CODE                 := L_EVENT_CLASS_REC.EVENT_CLASS_CODE               ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).APPLICATION_ID                   := L_EVENT_CLASS_REC.APPLICATION_ID                 ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ENTITY_CODE                      := L_EVENT_CLASS_REC.ENTITY_CODE                    ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).TAX_EVENT_CLASS_CODE             := L_EVENT_CLASS_REC.TAX_EVENT_CLASS_CODE           ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).RECORD_FLAG                      := L_EVENT_CLASS_REC.RECORD_FLAG                    ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).DET_FACTOR_TEMPL_CODE            := L_EVENT_CLASS_REC.DET_FACTOR_TEMPL_CODE          ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).DEFAULT_ROUNDING_LEVEL_CODE      := L_EVENT_CLASS_REC.DEFAULT_ROUNDING_LEVEL_CODE    ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ROUNDING_LEVEL_HIER_1_CODE       := L_EVENT_CLASS_REC.ROUNDING_LEVEL_HIER_1_CODE     ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ROUNDING_LEVEL_HIER_2_CODE       := L_EVENT_CLASS_REC.ROUNDING_LEVEL_HIER_2_CODE     ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ROUNDING_LEVEL_HIER_3_CODE       := L_EVENT_CLASS_REC.ROUNDING_LEVEL_HIER_3_CODE     ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ROUNDING_LEVEL_HIER_4_CODE       := L_EVENT_CLASS_REC.ROUNDING_LEVEL_HIER_4_CODE     ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ALLOW_MANUAL_LIN_RECALC_FLAG     := L_EVENT_CLASS_REC.ALLOW_MANUAL_LIN_RECALC_FLAG   ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ALLOW_OVERRIDE_FLAG              := L_EVENT_CLASS_REC.ALLOW_OVERRIDE_FLAG            ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ALLOW_MANUAL_LINES_FLAG          := L_EVENT_CLASS_REC.ALLOW_MANUAL_LINES_FLAG        ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).PERF_ADDNL_APPL_FOR_IMPRT_FLAG   := L_EVENT_CLASS_REC.PERF_ADDNL_APPL_FOR_IMPRT_FLAG ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).SHIP_TO_PARTY_TYPE               := L_EVENT_CLASS_REC.SHIP_TO_PARTY_TYPE             ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).SHIP_FROM_PARTY_TYPE             := L_EVENT_CLASS_REC.SHIP_FROM_PARTY_TYPE           ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).POA_PARTY_TYPE                   := L_EVENT_CLASS_REC.POA_PARTY_TYPE                 ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).POO_PARTY_TYPE                   := L_EVENT_CLASS_REC.POO_PARTY_TYPE                 ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).PAYING_PARTY_TYPE                := L_EVENT_CLASS_REC.PAYING_PARTY_TYPE              ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).OWN_HQ_PARTY_TYPE                := L_EVENT_CLASS_REC.OWN_HQ_PARTY_TYPE              ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).TRAD_HQ_PARTY_TYPE               := L_EVENT_CLASS_REC.TRAD_HQ_PARTY_TYPE             ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).POI_PARTY_TYPE                   := L_EVENT_CLASS_REC.POI_PARTY_TYPE                 ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).POD_PARTY_TYPE                   := L_EVENT_CLASS_REC.POD_PARTY_TYPE                 ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).BILL_TO_PARTY_TYPE               := L_EVENT_CLASS_REC.BILL_TO_PARTY_TYPE             ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).BILL_FROM_PARTY_TYPE             := L_EVENT_CLASS_REC.BILL_FROM_PARTY_TYPE           ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).TTL_TRNS_PARTY_TYPE              := L_EVENT_CLASS_REC.TTL_TRNS_PARTY_TYPE            ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).MERCHANT_PARTY_TYPE              := L_EVENT_CLASS_REC.MERCHANT_PARTY_TYPE            ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).SHIP_TO_PTY_SITE_TYPE            := L_EVENT_CLASS_REC.SHIP_TO_PTY_SITE_TYPE          ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).SHIP_FROM_PTY_SITE_TYPE          := L_EVENT_CLASS_REC.SHIP_FROM_PTY_SITE_TYPE        ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).POA_PTY_SITE_TYPE                := L_EVENT_CLASS_REC.POA_PTY_SITE_TYPE              ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).POO_PTY_SITE_TYPE                := L_EVENT_CLASS_REC.POO_PTY_SITE_TYPE              ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).PAYING_PTY_SITE_TYPE             := L_EVENT_CLASS_REC.PAYING_PTY_SITE_TYPE           ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).OWN_HQ_PTY_SITE_TYPE             := L_EVENT_CLASS_REC.OWN_HQ_PTY_SITE_TYPE           ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).TRAD_HQ_PTY_SITE_TYPE            := L_EVENT_CLASS_REC.TRAD_HQ_PTY_SITE_TYPE          ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).POI_PTY_SITE_TYPE                := L_EVENT_CLASS_REC.POI_PTY_SITE_TYPE              ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).POD_PTY_SITE_TYPE                := L_EVENT_CLASS_REC.POD_PTY_SITE_TYPE              ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).BILL_TO_PTY_SITE_TYPE            := L_EVENT_CLASS_REC.BILL_TO_PTY_SITE_TYPE          ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).BILL_FROM_PTY_SITE_TYPE          := L_EVENT_CLASS_REC.BILL_FROM_PTY_SITE_TYPE        ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).TTL_TRNS_PTY_SITE_TYPE           := L_EVENT_CLASS_REC.TTL_TRNS_PTY_SITE_TYPE         ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ENFORCE_TAX_FROM_ACCT_FLAG       := L_EVENT_CLASS_REC.ENFORCE_TAX_FROM_ACCT_FLAG     ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).OFFSET_TAX_BASIS_CODE            := L_EVENT_CLASS_REC.OFFSET_TAX_BASIS_CODE          ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).REFERENCE_APPLICATION_ID         := L_EVENT_CLASS_REC.REFERENCE_APPLICATION_ID       ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).PROD_FAMILY_GRP_CODE             := L_EVENT_CLASS_REC.PROD_FAMILY_GRP_CODE           ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ALLOW_OFFSET_TAX_CALC_FLAG       := L_EVENT_CLASS_REC.ALLOW_OFFSET_TAX_CALC_FLAG     ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).SELF_ASSESS_TAX_LINES_FLAG       := L_EVENT_CLASS_REC.SELF_ASSESS_TAX_LINES_FLAG     ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).TAX_RECOVERY_FLAG                := L_EVENT_CLASS_REC.TAX_RECOVERY_FLAG              ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ALLOW_CANCEL_TAX_LINES_FLAG      := L_EVENT_CLASS_REC.ALLOW_CANCEL_TAX_LINES_FLAG    ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ALLOW_MAN_TAX_ONLY_LINES_FLAG    := L_EVENT_CLASS_REC.ALLOW_MAN_TAX_ONLY_LINES_FLAG  ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).TAX_VARIANCE_CALC_FLAG           := L_EVENT_CLASS_REC.TAX_VARIANCE_CALC_FLAG         ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).TAX_REPORTING_FLAG               := L_EVENT_CLASS_REC.TAX_REPORTING_FLAG             ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ENTER_OVRD_INCL_TAX_LINES_FLAG   := L_EVENT_CLASS_REC.ENTER_OVRD_INCL_TAX_LINES_FLAG ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).CTRL_EFF_OVRD_CALC_LINES_FLAG    := L_EVENT_CLASS_REC.CTRL_EFF_OVRD_CALC_LINES_FLAG  ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).SUMMARIZATION_FLAG               := L_EVENT_CLASS_REC.SUMMARIZATION_FLAG             ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).RETAIN_SUMM_TAX_LINE_ID_FLAG     := L_EVENT_CLASS_REC.RETAIN_SUMM_TAX_LINE_ID_FLAG   ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).RECORD_FOR_PARTNERS_FLAG         := L_EVENT_CLASS_REC.RECORD_FOR_PARTNERS_FLAG       ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).MANUAL_LINES_FOR_PARTNER_FLAG    := L_EVENT_CLASS_REC.MANUAL_LINES_FOR_PARTNER_FLAG  ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).MAN_TAX_ONLY_LIN_FOR_PTNR_FLAG   := L_EVENT_CLASS_REC.MAN_TAX_ONLY_LIN_FOR_PTNR_FLAG ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ALWAYS_USE_EBTAX_FOR_CALC_FLAG   := L_EVENT_CLASS_REC.ALWAYS_USE_EBTAX_FOR_CALC_FLAG ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).PROCESSING_PRECEDENCE            := L_EVENT_CLASS_REC.PROCESSING_PRECEDENCE          ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).EVENT_CLASS_MAPPING_ID           := L_EVENT_CLASS_REC.EVENT_CLASS_MAPPING_ID         ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ENFORCE_TAX_FROM_REF_DOC_FLAG    := L_EVENT_CLASS_REC.ENFORCE_TAX_FROM_REF_DOC_FLAG  ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).PROCESS_FOR_APPLICABILITY_FLAG   := L_EVENT_CLASS_REC.PROCESS_FOR_APPLICABILITY_FLAG ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).SUP_CUST_ACCT_TYPE_CODE          := L_EVENT_CLASS_REC.SUP_CUST_ACCT_TYPE_CODE        ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).DISPLAY_TAX_CLASSIF_FLAG         := L_EVENT_CLASS_REC.DISPLAY_TAX_CLASSIF_FLAG       ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).INTGRTN_DET_FACTORS_UI_FLAG      := L_EVENT_CLASS_REC.INTGRTN_DET_FACTORS_UI_FLAG    ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).INTRCMP_TX_EVNT_CLS_CODE         := L_EVENT_CLASS_REC.INTRCMP_TX_EVNT_CLS_CODE       ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).INTRCMP_SRC_ENTITY_CODE          := L_EVENT_CLASS_REC.INTRCMP_SRC_ENTITY_CODE        ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).INTRCMP_SRC_EVNT_CLS_CODE        := L_EVENT_CLASS_REC.INTRCMP_SRC_EVNT_CLS_CODE      ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).INTRCMP_SRC_APPLN_ID             := L_EVENT_CLASS_REC.INTRCMP_SRC_APPLN_ID           ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ALLOW_EXEMPTIONS_FLAG            := L_EVENT_CLASS_REC.ALLOW_EXEMPTIONS_FLAG          ;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_event_class_rec_tbl(l_index).ENABLE_MRC_FLAG                  := L_EVENT_CLASS_REC.ENABLE_MRC_FLAG                ;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,'ZX_VALID_INIT_PKG.get_evnt_cls_info',
                         'Event class record not found in cache. Populating from database ');
        END IF;

        X_TBL_INDEX := l_index;
        EXIT;

    END LOOP;

  END IF;

EXCEPTION
  WHEN OTHERS THEN

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_VALID_INIT_PKG.get_evnt_cls_info',
                   'Exception in ZZX_VALID_INIT_PKG.get_evnt_cls_info. '||SQLCODE||SQLERRM);
      END IF;

      IF C_EVNT_CLASS_INFO%ISOPEN then
         close C_EVNT_CLASS_INFO;
      END IF;

END get_event_class_info;



PROCEDURE get_event_typ_mappings_info(
     P_ENTITY_CODE         IN         ZX_EVNT_TYP_MAPPINGS.entity_code%TYPE,
     P_EVENT_CLASS_CODE    IN         ZX_EVNT_TYP_MAPPINGS.event_class_code%TYPE,
     P_APPLICATION_ID      IN         ZX_EVNT_TYP_MAPPINGS.application_id%TYPE,
     P_EVENT_TYPE_CODE     IN         ZX_EVNT_TYP_MAPPINGS.event_type_code%TYPE,
     X_TBL_INDEX           OUT NOCOPY BINARY_INTEGER,
     X_RETURN_STATUS       OUT NOCOPY VARCHAR2)
is
  cursor c_evnt_typ_mapping_info is
  SELECT
      EVENT_CLASS_MAPPING_ID,
      EVENT_TYPE_MAPPING_ID,
      EVENT_CLASS_CODE,
      EVENT_TYPE_CODE,
      APPLICATION_ID,
      ENTITY_CODE,
      TAX_EVENT_CLASS_CODE,
      TAX_EVENT_TYPE_CODE,
      ENABLED_FLAG
  from
    ZX_EVNT_TYP_MAPPINGS
  WHERE
        application_id   = P_APPLICATION_ID
   AND  entity_code      = P_ENTITY_CODE
   AND  event_class_code = P_EVENT_CLASS_CODE
   AND  event_type_code  = P_EVENT_TYPE_CODE ;

  l_index  binary_integer;

BEGIN

  x_return_status       := FND_API.G_RET_STS_SUCCESS;

  l_index := dbms_utility.get_hash_value(to_char(p_application_id)||p_entity_code||p_event_class_code
                                         ||p_event_type_Code,1,8192);

  IF ZX_GLOBAL_STRUCTURES_PKG.g_zx_evnt_typ_map_tbl.EXISTS(l_index) then

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,'ZX_VALID_INIT_PKG.get_evnt_cls_info',
           'Event type record found in cache ');
      END IF;

      X_TBL_INDEX := l_index;
      RETURN;

  ELSE

    FOR L_EVENT_TYPE_REC IN c_evnt_typ_mapping_info LOOP

        ZX_GLOBAL_STRUCTURES_PKG.g_zx_evnt_typ_map_tbl(l_index).EVENT_CLASS_MAPPING_ID := l_event_type_rec.EVENT_CLASS_MAPPING_ID;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_evnt_typ_map_tbl(l_index).EVENT_TYPE_MAPPING_ID  := l_event_type_rec.EVENT_TYPE_MAPPING_ID;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_evnt_typ_map_tbl(l_index).EVENT_CLASS_CODE       := l_event_type_rec.EVENT_CLASS_CODE;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_evnt_typ_map_tbl(l_index).EVENT_TYPE_CODE        := l_event_type_rec.EVENT_TYPE_CODE;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_evnt_typ_map_tbl(l_index).APPLICATION_ID         := l_event_type_rec.APPLICATION_ID;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_evnt_typ_map_tbl(l_index).ENTITY_CODE            := l_event_type_rec.ENTITY_CODE;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_evnt_typ_map_tbl(l_index).TAX_EVENT_CLASS_CODE   := l_event_type_rec.TAX_EVENT_CLASS_CODE;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_evnt_typ_map_tbl(l_index).TAX_EVENT_TYPE_CODE    := l_event_type_rec.TAX_EVENT_TYPE_CODE;
        ZX_GLOBAL_STRUCTURES_PKG.g_zx_evnt_typ_map_tbl(l_index).ENABLED_FLAG           := l_event_type_rec.ENABLED_FLAG;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,'ZX_VALID_INIT_PKG.get_evnt_typ_mappings_info',
                         'Event type record not found in cache. Populating from database ');
        END IF;

        X_TBL_INDEX := l_index;
        EXIT;

    END LOOP;

  END IF;

EXCEPTION
  WHEN OTHERS THEN

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_VALID_INIT_PKG.get_evnt_typ_mappings_info',
                   'Exception in ZX_VALID_INIT_PKG.get_evnt_typ_mappings_info. '||SQLCODE||SQLERRM);
      END IF;

      IF c_evnt_typ_mapping_info%ISOPEN then
         close c_evnt_typ_mapping_info;
      END IF;

END get_event_typ_mappings_info;

PROCEDURE populate_event_cls_typs
IS

  cursor c_get_evnt_cls_typs is
   select TAX_EVENT_CLASS_CODE,
          TAX_EVENT_TYPE_CODE,
          STATUS_CODE
   from    zx_evnt_cls_typs;
   l_index binary_integer;

BEGIN

   FOR l_evnt_cls_typs_rec in  c_get_evnt_cls_typs LOOP

      l_index := dbms_utility.get_hash_value(l_evnt_cls_typs_rec.TAX_EVENT_CLASS_CODE ||
                                             l_evnt_cls_typs_rec.TAX_EVENT_TYPE_CODE,
                                             1,8192);

      ZX_GLOBAL_STRUCTURES_PKG.g_zx_evnt_cls_typs_tbl(l_index) := l_evnt_cls_typs_rec.STATUS_CODE;

   END LOOP;

EXCEPTION
 WHEN OTHERS THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_VALID_INIT_PKG.populate_event_cls_typs',
                   'Exception in ZX_VALID_INIT_PKG.populate_event_cls_typs. '||SQLCODE||SQLERRM);
      END IF;

      IF c_get_evnt_cls_typs%ISOPEN then
         close c_get_evnt_cls_typs;
      END IF;
END populate_event_cls_typs;

PROCEDURE populate_tax_event_class_info
IS

  cursor c_get_tax_evnt_cls is
   select TAX_EVENT_CLASS_CODE,
          NORMAL_SIGN_FLAG,
          ASC_INTRCMP_TX_EVNT_CLS_CODE
   from    zx_event_classes_b;

BEGIN

   FOR l_tax_evnt_cls_rec in  c_get_tax_evnt_cls LOOP

      ZX_GLOBAL_STRUCTURES_PKG.g_zx_tax_evnt_cls_tbl(l_tax_evnt_cls_rec.TAX_EVENT_CLASS_CODE).TAX_EVENT_CLASS_CODE := l_tax_evnt_cls_rec.TAX_EVENT_CLASS_CODE;
      ZX_GLOBAL_STRUCTURES_PKG.g_zx_tax_evnt_cls_tbl(l_tax_evnt_cls_rec.TAX_EVENT_CLASS_CODE).NORMAL_SIGN_FLAG := l_tax_evnt_cls_rec.NORMAL_SIGN_FLAG;
      ZX_GLOBAL_STRUCTURES_PKG.g_zx_tax_evnt_cls_tbl(l_tax_evnt_cls_rec.TAX_EVENT_CLASS_CODE).ASC_INTRCMP_TX_EVNT_CLS_CODE := l_tax_evnt_cls_rec.ASC_INTRCMP_TX_EVNT_CLS_CODE;

   END LOOP;

EXCEPTION
 WHEN OTHERS THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_VALID_INIT_PKG.populate_tax_event_class_info',
                   'Exception in ZX_VALID_INIT_PKG.populate_tax_event_class_info. '||SQLCODE||SQLERRM);
      END IF;

      IF c_get_tax_evnt_cls%ISOPEN then
         close c_get_tax_evnt_cls;
      END IF;
END populate_tax_event_class_info;

END ZX_VALID_INIT_PARAMS_PKG;


/
