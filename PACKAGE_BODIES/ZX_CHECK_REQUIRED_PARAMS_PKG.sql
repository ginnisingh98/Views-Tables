--------------------------------------------------------
--  DDL for Package Body ZX_CHECK_REQUIRED_PARAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_CHECK_REQUIRED_PARAMS_PKG" AS
/* $Header: zxifreqparampkgb.pls 120.39.12010000.4 2010/02/03 00:48:28 ssanka ship $ */

/* ======================================================================*
 | Global Data Types                                                     |
 * ======================================================================*/

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'ZX_CHECK_REQUIRED_PARAMS_PKG';
G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME           CONSTANT VARCHAR2(80) := 'ZX.PLSQL.ZX_CHECK_REQUIRED_PARAMS_PKG.';


/*----------------------------------------------------------------------------*
 |   PRIVATE FUNCTIONS/PROCEDURES                                             |
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*
 |   PUBLIC  FUNCTIONS/PROCEDURES                                             |
 *----------------------------------------------------------------------------*/

/* ===========================================================================*
 | PROCEDURE Check_trx_line_tbl : Checks the required elements of the         |
 |                                transaction line                            |
 | Called by:                                                                 |
 |     zx_valid_init_params_pkg.calculate_tax (GTT version)                   |
 |     zx_valid_init_params_pkg.import_document_with_tax                      |
 * ===========================================================================*/

  PROCEDURE Check_trx_line_tbl
  ( x_return_status             OUT NOCOPY  VARCHAR2,
    p_event_class_rec           IN          ZX_API_PUB.event_class_rec_type
  )
  IS
  l_api_name         CONSTANT VARCHAR2(30):= 'CHECK_TRX_LINE_TBL';
  l_count            NUMBER;
  l_context_info_rec ZX_API_PUB.context_info_rec_type;
  l_message_locm     VARCHAR2(240);
  l_message_unitp    VARCHAR2(240);

  l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

  BEGIN
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_count := 0;

       l_message_locm := fnd_message.get_string('ZX','ZX_LOCATION_MISSING');
       l_message_unitp := fnd_message.get_string('ZX','ZX_UNIT_PRICE_REQD');
       INSERT ALL
        WHEN (ZX_LOCATION_MISSING = 'Y') THEN
        INTO ZX_ERRORS_GT(
                application_id,
                entity_code,
                event_class_code,
                trx_id,
                trx_line_id,
                MESSAGE_TEXT,
                TRX_LEVEL_TYPE
                )
        VALUES(
                application_id,
                entity_code,
                event_class_code,
                trx_id,
                trx_line_id,
                l_message_locm,
                trx_level_type
                 )
 /*  Bug 5516630: Unit price needs to be checked only for distribution lines
         WHEN (ZX_UNIT_PRICE_MISSING = 'Y') THEN
                INTO ZX_ERRORS_GT(
                application_id,
                entity_code,
                event_class_code,
                trx_id,
                trx_line_id,
                MESSAGE_TEXT,
                TRX_LEVEL_TYPE
                )
        VALUES(
                application_id,
                entity_code,
                event_class_code,
                trx_id,
                trx_line_id,
                l_message_unitp,
                trx_level_type
                 )
*/

            SELECT
                header.application_id,
                header.entity_code,
                header.event_class_code,
                header.trx_id,
                lines_gt.trx_line_id,
                lines_gt.trx_level_type,
                -- Check for existence of at least one location at line
                CASE WHEN (lines_gt.ship_from_location_id is not null OR
                           lines_gt.ship_to_location_id is not NULL OR
                           lines_gt.poa_location_id is not NULL OR
                           lines_gt.poo_location_id is not NULL OR
                           lines_gt.paying_location_id is not NULL OR
                           lines_gt.own_hq_location_id is not NULL OR
                           lines_gt.trading_hq_location_id is not NULL OR
                           lines_gt.poc_location_id is not NULL OR
                           lines_gt.poi_location_id is not NULL OR
                           lines_gt.pod_location_id is not NULL OR
                           lines_gt.bill_to_location_id is not NULL OR
                           lines_gt.bill_from_location_id is not NULL OR
                           lines_gt.title_transfer_location_id is not NULL)
                      THEN NULL
                      ELSE 'Y'
                  END ZX_LOCATION_MISSING
/*,
                 CASE WHEN (p_event_class_rec.tax_variance_calc_flag = 'Y'
                           and lines_gt.unit_price is null
                           and lines_gt.ref_doc_application_id IS NOT NULL
                           and lines_gt.line_class <> 'AMOUNT_MATCHED')
                     THEN  'Y'
                     ELSE  NULL
                END ZX_UNIT_PRICE_MISSING
*/
             FROM ZX_TRX_HEADERS_GT header,
                  ZX_TRANSACTION_LINES_GT       lines_gt
             WHERE lines_gt.trx_id = header.trx_id
               AND lines_gt.application_id = header.application_id
               AND lines_gt.entity_code    = header.entity_code
               AND lines_gt.event_class_code = header.event_class_code;

  END check_trx_line_tbl;


/* ===========================================================================*
 | PROCEDURE Check_trx_lines : Checks the required elements of the            |
 |                             transaction line in structure                  |
 | Called by:                                                                 |
 |     zx_valid_init_params_pkg.calculate_tax (PLS/WIN version)               |
 |     zx_valid_init_params_pkg.insupd_line_det_factors                       |
 * ===========================================================================*/

  PROCEDURE Check_trx_lines
  ( x_return_status             OUT NOCOPY  VARCHAR2,
    p_event_class_rec           IN          ZX_API_PUB.event_class_rec_type
  )
  IS
  l_api_name           CONSTANT VARCHAR2(30):= 'CHECK_TRX_LINE';
  l_count              NUMBER;
  l_context_info_rec   ZX_API_PUB.context_info_rec_type;

  l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

  BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_count := 0;

    FOR l_trx_line_index IN 1 .. nvl(zx_global_structures_pkg.trx_line_dist_tbl.internal_organization_id.LAST,0)
    LOOP
      IF zx_global_structures_pkg.trx_line_dist_tbl.LINE_LEVEL_ACTION(l_trx_line_index) not in ('CANCEL','DELETE') THEN
        IF    zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_LOCATION_ID(l_trx_line_index) is NULL
          AND zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_LOCATION_ID(l_trx_line_index) is NULL
          AND zx_global_structures_pkg.trx_line_dist_tbl.POA_LOCATION_ID(l_trx_line_index) is NULL
          AND zx_global_structures_pkg.trx_line_dist_tbl.poo_location_id(l_trx_line_index) is NULL
          AND zx_global_structures_pkg.trx_line_dist_tbl.PAYING_LOCATION_ID(l_trx_line_index) is NULL
          AND zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_LOCATION_ID(l_trx_line_index) is NULL
          AND zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_LOCATION_ID(l_trx_line_index) is NULL
          AND zx_global_structures_pkg.trx_line_dist_tbl.POC_LOCATION_ID(l_trx_line_index) is NULL
          AND zx_global_structures_pkg.trx_line_dist_tbl.POI_LOCATION_ID(l_trx_line_index) is NULL
          AND zx_global_structures_pkg.trx_line_dist_tbl.POD_LOCATION_ID(l_trx_line_index) is NULL
          AND zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_LOCATION_ID(l_trx_line_index) is NULL
          AND zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_LOCATION_ID(l_trx_line_index) is NULL
          AND zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANSFER_LOCATION_ID(l_trx_line_index) is NULL THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            --FND_MESSAGE.SET_NAME('ZX','ZX_LOCATION_MISSING');
            l_context_info_rec.APPLICATION_ID   := p_event_class_rec.APPLICATION_ID;
            l_context_info_rec.ENTITY_CODE      := p_event_class_rec.ENTITY_CODE;
            l_context_info_rec.EVENT_CLASS_CODE := p_event_class_rec.EVENT_CLASS_CODE;
            l_context_info_rec.TRX_ID           := p_event_class_rec.TRX_ID;
            ZX_API_PUB.add_msg( p_context_info_rec =>l_context_info_rec );
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'At least one location is required');
            END IF;
            EXIT;
        END IF;
      END IF;
    END LOOP;

    FOR l_trx_line_index IN 1 .. nvl(zx_global_structures_pkg.trx_line_dist_tbl.internal_organization_id.LAST,0)
    LOOP
      IF p_event_class_rec.header_level_currency_flag is null THEN
        IF zx_global_structures_pkg.trx_line_dist_tbl.LINE_LEVEL_ACTION(l_trx_line_index) not in ('CANCEL','DELETE') THEN
          IF zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_CURRENCY_CODE(l_trx_line_index) is NULL and
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_PRECISION(l_trx_line_index) is NULL THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('ZX','ZX_CURRENCY_INFO_REQD');
             l_context_info_rec.APPLICATION_ID   := p_event_class_rec.APPLICATION_ID;
             l_context_info_rec.ENTITY_CODE      := p_event_class_rec.ENTITY_CODE;
             l_context_info_rec.EVENT_CLASS_CODE := p_event_class_rec.EVENT_CLASS_CODE;
             l_context_info_rec.TRX_ID           := p_event_class_rec.TRX_ID;
             ZX_API_PUB.add_msg( p_context_info_rec =>l_context_info_rec );
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Currency code and precision are required at line level');
             END IF;
             EXIT;
           END IF;
        END IF;
      END IF;
    END LOOP;

    IF p_event_class_rec.tax_variance_calc_flag = 'Y' THEN
      IF ZX_API_PUB.G_PUB_SRVC = 'CALCULATE_TAX' THEN
	    FOR l_trx_line_index IN 1 .. nvl(zx_global_structures_pkg.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID.LAST,0)
        LOOP
          IF zx_global_structures_pkg.trx_line_dist_tbl.LINE_LEVEL_ACTION(l_trx_line_index) not in ('CANCEL','DELETE') AND
             zx_global_structures_pkg.trx_line_dist_tbl.LINE_CLASS(l_trx_line_index) <> 'AMOUNT_MATCHED' AND
             zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_APPLICATION_ID(l_trx_line_index) is not null THEN
             IF zx_global_structures_pkg.trx_line_dist_tbl.UNIT_PRICE(l_trx_line_index) is NULL THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('ZX','ZX_UNIT_PRICE_REQD');
               l_context_info_rec.APPLICATION_ID   := p_event_class_rec.APPLICATION_ID;
               l_context_info_rec.ENTITY_CODE      := p_event_class_rec.ENTITY_CODE;
               l_context_info_rec.EVENT_CLASS_CODE := p_event_class_rec.EVENT_CLASS_CODE;
               l_context_info_rec.TRX_ID           := p_event_class_rec.TRX_ID;
               ZX_API_PUB.add_msg( p_context_info_rec =>l_context_info_rec );
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Unit price is required');
              END IF;
              EXIT;
            END IF;
          END IF;
        END LOOP;
      END IF; --g_pub_srvc
    END IF; --tax_variance_calc_flag

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.END',
        G_PKG_NAME||': '||l_api_name||'()-'||' RETURN_STATUS = ' || x_return_status);
    END IF;

  END check_trx_lines;

/* ===========================================================================*
 | PROCEDURE Check_trx_headers_tbl : Checks the required elements of the      |
 |                                   Transaction Header                       |
 | Called by:                                                                 |
 |     zx_valid_init_params_pkg.calculate_tax (GTT version)                   |
 |     zx_valid_init_params_pkg.import_document_with_tax                      |
 |     zx_valid_init_params_pkg.determine_recovery                            |
 |     zx_valid_init_params_pkg.insupd_line_det_factors                       |
 * ===========================================================================*/

  PROCEDURE Check_trx_headers_tbl
  ( x_return_status                 OUT NOCOPY  VARCHAR2,
    p_event_class_rec           IN  OUT NOCOPY  ZX_API_PUB.event_class_rec_type
  )
  IS
  l_api_name         CONSTANT VARCHAR2(30):= 'CHECK_TRX_HEADERS_TBL';
  l_func_curr_code   VARCHAR2(80);
  l_count            NUMBER;
  l_context_info_rec ZX_API_PUB.context_info_rec_type;
  l_message_pty     VARCHAR2(2000);
  l_message_curr     VARCHAR2(2000);

  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF ZX_API_PUB.G_PUB_SRVC <> 'DETERMINE_RECOVERY' THEN
       IF ZX_API_PUB.G_DATA_TRANSFER_MODE <> 'TAB' THEN

         IF (p_event_class_rec.rounding_ship_to_party_id is NULL)   AND
            (p_event_class_rec.rounding_ship_from_party_id is NULL) AND
            (p_event_class_rec.rounding_bill_to_party_id is NULL)   AND
            (p_event_class_rec.rounding_bill_from_party_id is NULL) THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              --FND_MESSAGE.SET_NAME('ZX','ZX_ROUND_PARTY_MISSING');
              --l_context_info_rec.APPLICATION_ID   := p_event_class_rec.APPLICATION_ID;
              --l_context_info_rec.ENTITY_CODE      := p_event_class_rec.ENTITY_CODE;
              --l_context_info_rec.EVENT_CLASS_CODE := p_event_class_rec.EVENT_CLASS_CODE;
              --l_context_info_rec.TRX_ID           := p_event_class_rec.TRX_ID;
              --ZX_API_PUB.add_msg( p_context_info_rec =>l_context_info_rec );
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'At least one rounding party is required');
              END IF;
         END IF;
      ELSIF ZX_API_PUB.G_DATA_TRANSFER_MODE = 'TAB' THEN
       l_message_pty := fnd_message.get_string('ZX','ZX_ROUND_PARTY_MISSING');
       l_message_curr := fnd_message.get_string('ZX','ZX_CURRENCY_INFO_REQD');
       INSERT ALL
        WHEN (ZX_ROUND_PARTY_MISSING = 'Y')  THEN
        INTO ZX_ERRORS_GT(
                application_id,
                entity_code,
                event_class_code,
                trx_id,
                trx_line_id,
                MESSAGE_TEXT,
                TRX_LEVEL_TYPE
                )
        VALUES(
                application_id,
                entity_code,
                event_class_code,
                trx_id,
                NULL ,--trx_line_id,
                l_message_pty,
                NULL --interface_line_id
                 )
        WHEN (ZX_CURRENCY_INFO_REQD = 'Y')  THEN
                INTO ZX_ERRORS_GT(
                application_id,
                entity_code,
                event_class_code,
                trx_id,
                trx_line_id,
                MESSAGE_TEXT,
                TRX_LEVEL_TYPE
                )
        VALUES(
                application_id,
                entity_code,
                event_class_code,
                trx_id,
                NULL ,--trx_line_id,
                l_message_curr,
                NULL --interface_line_id
                 )
        SELECT
        header.application_id,
        header.entity_code,
        header.event_class_code,
        header.trx_id,
        -- Check for existence of at least one rounding party
        CASE WHEN (header.rounding_ship_from_party_id is NULL AND
                   header.rounding_ship_to_party_id is NULL AND
                   header.rounding_bill_to_party_id is NULL AND
                   header.rounding_bill_from_party_id is NULL )
              THEN 'Y'
              ELSE NULL
         END  ZX_ROUND_PARTY_MISSING,
       CASE WHEN (header.TRX_CURRENCY_CODE is NULL
                   AND header.precision is NULL )
                   AND EXISTS
                   ( SELECT 1 FROM zx_transaction_lines_gt
                       WHERE application_id = header.application_id
                       AND   entity_code = header.entity_code
                       AND   event_class_code = header.event_class_code
                       AND   trx_id = header.trx_id
                       AND   ( TRX_LINE_CURRENCY_CODE is NULL
                             OR trx_line_precision is NULL)
                    )
             THEN 'Y'
             ELSE NULL
        END  ZX_CURRENCY_INFO_REQD

       FROM
            ZX_TRX_HEADERS_GT             header
       WHERE VALIDATION_CHECK_FLAG is null;

     END IF; -- ZX_API_PUB.G_DATA_TRANSFER_MODE <> 'TAB'

/* Needs to be moved to service types package

      IF p_event_class_rec.trx_currency_code is not NULL   AND
         p_event_class_rec.precision is not NULL THEN
         p_event_class_rec.header_level_currency_flag := 'Y';
      END IF;
*/

    ELSIF ZX_API_PUB.G_PUB_SRVC = 'DETERMINE_RECOVERY' THEN
      IF p_event_class_rec.tax_variance_calc_flag = 'Y' THEN
       /* -----------------------------------------------------------------------------+
        |    If tax_variance_calc_flag is 'Y' then trx_line_quantity cannot be null    |
        + ----------------------------------------------------------------------------*/
        --BUGFIX 4938906 - No need to check for trx_line_quantity
        /*BEGIN
          SELECT  /*+ INDEX (ZX_ITM_DISTRIBUTIONS_GT ZX_ITM_DISTRIBUTIONS_GT_U1)*/
        /*         1
            INTO l_count
            FROM ZX_ITM_DISTRIBUTIONS_GT
            WHERE application_id   = p_event_class_rec.application_id
              AND entity_code      = p_event_class_rec.entity_code
              AND event_class_code = p_event_class_rec.event_class_code
              AND trx_id           = p_event_class_rec.trx_id
      	      AND trx_line_quantity is null;

    	EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_count := 0;
          WHEN OTHERS THEN
            l_count := 1;
        END;
        IF l_count <> 0  THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('ZX','ZX_TRX_LINE_QUANTITY_REQD');
            l_context_info_rec.APPLICATION_ID   := p_event_class_rec.APPLICATION_ID;
            l_context_info_rec.ENTITY_CODE      := p_event_class_rec.ENTITY_CODE;
            l_context_info_rec.EVENT_CLASS_CODE := p_event_class_rec.EVENT_CLASS_CODE;
            l_context_info_rec.TRX_ID           := p_event_class_rec.TRX_ID;
            ZX_API_PUB.add_msg( p_context_info_rec =>l_context_info_rec );
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Transaction line quantity is required');
            END IF;
        END IF;
        */
       /* ---------------------------------------------------------------------+
        |    If tax_variance_calc_flag is 'Y' then unit price cannot be null   |
        + ---------------------------------------------------------------------*/
        --BUGFIX 4779214 - No need to check for unit_price
        /*
        BEGIN
          SELECT  /*+ INDEX (ZX_ITM_DISTRIBUTIONS_GT ZX_ITM_DISTRIBUTIONS_GT_U1)*/
        /*         1
           INTO l_count
            FROM ZX_ITM_DISTRIBUTIONS_GT
            WHERE application_id   = p_event_class_rec.application_id
              AND entity_code      = p_event_class_rec.entity_code
              AND event_class_code = p_event_class_rec.event_class_code
              AND trx_id           = p_event_class_rec.trx_id
      	      AND unit_price is null;

 	    EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_count := 0;
          WHEN OTHERS THEN
            l_count := 1;
        END;
        IF l_count <> 0  THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('ZX','ZX_UNIT_PRICE_REQD');
            l_context_info_rec.APPLICATION_ID   := p_event_class_rec.APPLICATION_ID;
            l_context_info_rec.ENTITY_CODE      := p_event_class_rec.ENTITY_CODE;
            l_context_info_rec.EVENT_CLASS_CODE := p_event_class_rec.EVENT_CLASS_CODE;
            l_context_info_rec.TRX_ID           := p_event_class_rec.TRX_ID;
            ZX_API_PUB.add_msg( p_context_info_rec =>l_context_info_rec );
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Unit Price is required');
            END IF;
        END IF;
     */
    /* ------------------------------------------------------------------------- -+
    |    If tax_variance_calc_flag is 'Y' then trx line dist qty cannot be null   |
    + ----------------------------------------------------------------------------*/
        NULL;
        -- moved this logic to ZX_API_PUB and execute it only once
        -- BEGIN
        --   SELECT  /*+ INDEX (ZX_ITM_DISTRIBUTIONS_GT ZX_ITM_DISTRIBUTIONS_GT_U1)*/
        --          1
        --     INTO l_count
        --     FROM ZX_ITM_DISTRIBUTIONS_GT
        --     WHERE application_id   = p_event_class_rec.application_id
        --       AND entity_code      = p_event_class_rec.entity_code
        --       AND event_class_code = p_event_class_rec.event_class_code
        --       AND trx_id           = p_event_class_rec.trx_id
        --       AND ref_doc_application_id is not null
      	--       AND trx_line_dist_qty is null;
  	--
 	--     EXCEPTION
        --   WHEN NO_DATA_FOUND THEN
        --     l_count := 0;
        --   WHEN OTHERS THEN
        --     l_count := 1;
        -- END;
        -- IF l_count <> 0  THEN
        --     x_return_status := FND_API.G_RET_STS_ERROR;
        --     FND_MESSAGE.SET_NAME('ZX','ZX_TRX_LINE_DIST_QTY_REQD');
        --     l_context_info_rec.APPLICATION_ID   := p_event_class_rec.APPLICATION_ID;
        --     l_context_info_rec.ENTITY_CODE      := p_event_class_rec.ENTITY_CODE;
        --     l_context_info_rec.EVENT_CLASS_CODE := p_event_class_rec.EVENT_CLASS_CODE;
        --     l_context_info_rec.TRX_ID           := p_event_class_rec.TRX_ID;
        --     ZX_API_PUB.add_msg( p_context_info_rec =>l_context_info_rec );
        --     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        --       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Transaction line distribution quantity is required');
        --     END IF;
        -- END IF;
      END IF; --tax_variance_calc_flag
    END IF; -- g_pub_srvc


    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.END',
        G_PKG_NAME||': '||l_api_name||'()-'||' RETURN_STATUS = ' || x_return_status);
    END IF;

  END check_trx_headers_tbl;


/* ===========================================================================*
 | PROCEDURE Check_trx_rec : Checks the required elements of the transaction  |
 |                           record                                           |
 | Called by:                                                                 |
 |     zx_valid_init_params_pkg.override_tax                                  |
 |     zx_valid_init_params_pkg.global_document_update                        |
 |     zx_valid_init_params_pkg.override_recovery                             |
 |     zx_valid_init_params_pkg.freeze_distribution_lines                     |
 |     zx_valid_init_params_pkg.validate_document_for_tax                     |
 |     zx_valid_init_params_pkg.discard_tax_only_lines                        |
 * ===========================================================================*/

  PROCEDURE Check_trx_rec
  ( x_return_status 	OUT  NOCOPY VARCHAR2,
    p_trx_rec           IN          ZX_API_PUB.transaction_rec_type
  )
  IS
  l_api_name            CONSTANT VARCHAR2(30):= 'CHECK_TRX_REC';
  l_count               NUMBER;
  l_context_info_rec    ZX_API_PUB.context_info_rec_type;

  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    l_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*Bugfix 3423297
    IF p_trx_rec.internal_organization_id is NULL THEN

            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('ZX','ZX_ORG_ID_REQD');
            FND_MSG_PUB.Add;

    END IF;
    */
    IF p_trx_rec.application_id is NULL THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Application ID is required');
      END IF;
    END IF;

    IF p_trx_rec.entity_code is NULL THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Entity code is required');
      END IF;
    END IF;


    IF p_trx_rec.event_class_code is NULL THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Event class code is required');
      END IF;
    END IF;

    IF p_trx_rec.event_type_code is NULL THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Event type code is required');
      END IF;
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.END',
        G_PKG_NAME||': '||l_api_name||'()-'||' RETURN_STATUS = ' || x_return_status);
    END IF;

  END check_trx_rec;


/*==============================================================================*
 | PROCEDURE Check_trx_line_rec : Checks the required elements of the specified |
 |                                transaction line have values                  |
 | Called by:                                                                   |
 |     zx_valid_init_params_pkg.mark_tax_lines_deleted                          |
 * ============================================================================*/

  PROCEDURE Check_trx_line_rec
  ( x_return_status  OUT  NOCOPY   VARCHAR2,
    p_trx_line_rec   IN            zx_api_pub.transaction_line_rec_type
  ) IS
  l_api_name           CONSTANT VARCHAR2(30) := 'CHECK_TRX_LINE_REC';
  l_context_info_rec   ZX_API_PUB.context_info_rec_type;

  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_trx_line_rec.internal_organization_id is NULL THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Org ID is required');
      END IF;
    END IF;

    IF p_trx_line_rec.application_id is NULL THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Application ID is required');
      END IF;
    END IF;

    IF p_trx_line_rec.entity_code is NULL THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Entity code is required');
      END IF;
    END IF;

    IF p_trx_line_rec.event_class_code is NULL THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Event class code is required');
      END IF;
    END IF;

    IF p_trx_line_rec.trx_id is NULL THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Transaction ID is required');
      END IF;
    END IF;

    IF p_trx_line_rec.trx_line_id is NULL THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Transaction line ID is required');
      END IF;
    END IF;

    IF p_trx_line_rec.trx_level_type is NULL THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'Transaction line level type is required');
      END IF;
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.END',
        G_PKG_NAME||': '||l_api_name||'()-'||' RETURN_STATUS = ' || x_return_status);
    END IF;
  END check_trx_line_rec ;

END ZX_CHECK_REQUIRED_PARAMS_PKG;

/
