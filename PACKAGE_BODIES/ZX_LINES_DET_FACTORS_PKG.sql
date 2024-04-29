--------------------------------------------------------
--  DDL for Package Body ZX_LINES_DET_FACTORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_LINES_DET_FACTORS_PKG" AS
/* $Header: zxiflinedetfactb.pls 120.21 2006/06/28 16:56:04 lxzhang ship $ */

/* ======================================================================*
 | Global Data Types                                                     |
 * ======================================================================*/

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'ZX_LINES_DET_FACTORS_PKG';
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
G_MODULE_NAME           CONSTANT VARCHAR2(80) := 'ZX.PLSQL.ZX_LINES_DET_FACTORS_PKG.';

 CURSOR get_lines_det_factors(p_transaction_rec ZX_API_PUB.transaction_rec_type)  IS
   SELECT  APPLICATION_ID,
           ENTITY_CODE,
           EVENT_CLASS_CODE,
           EVENT_TYPE_CODE,
           LINE_LEVEL_ACTION,
           TRX_ID,
           TRX_LINE_ID,
           TRX_LEVEL_TYPE,
           DEFAULT_TAXATION_COUNTRY,
           DOCUMENT_SUB_TYPE,
           TAX_INVOICE_DATE,
           TAX_INVOICE_NUMBER,
           LINE_INTENDED_USE ,
           PRODUCT_FISC_CLASSIFICATION ,
           PRODUCT_TYPE ,
           PRODUCT_CATEGORY ,
           USER_DEFINED_FISC_CLASS,
           ASSESSABLE_VALUE,
           INPUT_TAX_CLASSIFICATION_CODE,
           OUTPUT_TAX_CLASSIFICATION_CODE,
           USER_UPD_DET_FACTORS_FLAG,
           TAX_EVENT_CLASS_CODE
    FROM  ZX_LINES_DET_FACTORS
    WHERE application_id = p_transaction_rec.application_id
      AND entity_code = p_transaction_rec.entity_code
      AND event_class_code = p_transaction_rec.event_class_code
      AND trx_id = p_transaction_rec.trx_id
    FOR UPDATE NOWAIT;


/* ============================================================================*
 | PROCEDURE  update_line_det_attribs : Update only the determining applicable |
 | at line level back to zx_lines_det_factors                                  |
 * ===========================================================================*/
PROCEDURE update_line_det_attribs (
  p_trx_biz_category         IN  VARCHAR2,
  p_line_intended_use        IN  VARCHAR2,
  p_prod_fisc_class          IN  VARCHAR2,
  p_prod_category            IN  VARCHAR2,
  p_product_type             IN  VARCHAR2,
  p_user_def_fisc_class      IN  VARCHAR2,
  p_assessable_value         IN  NUMBER,
  p_tax_classification_code  IN  VARCHAR2,
  p_display_tax_classif_flag IN  VARCHAR2,
  p_transaction_line_rec     IN  ZX_API_PUB.transaction_line_rec_type,
  x_return_status            OUT NOCOPY VARCHAR2
 )  IS
  l_api_name                 CONSTANT  VARCHAR2(30) := 'UPDATE_LINE_DET_ATTRIBS';
  l_return_status            VARCHAR2(1);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_LINES_DET_FACTORS_PKG: '||l_api_name||'()+');
   END IF;

  /*-----------------------------------------+
   |   Initialize return status to SUCCESS   |
   +-----------------------------------------*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;


  /*-----------------------------------------+
   |  Update zx_lines_det_factors            |
   +-----------------------------------------*/
   UPDATE ZX_LINES_DET_FACTORS SET
         trx_business_category         = p_trx_biz_category,
         line_intended_use             = p_line_intended_use,
         user_defined_fisc_class       = p_user_def_fisc_class,
         product_fisc_classification   = p_prod_fisc_class,
         product_category              = p_prod_category,
         product_type                  = p_product_type,
         assessable_value              = p_assessable_value,
         input_tax_classification_code = decode(p_display_tax_classif_flag,'Y', p_tax_classification_code,
                                                                                input_tax_classification_code),
         user_upd_det_factors_flag     = 'Y',
         tax_processing_completed_flag = 'N',
         object_version_number         = object_version_number+1,
         line_level_action             = decode(line_level_action,'SYNCHRONIZE', 'UPDATE', line_level_action)
     WHERE application_id    = p_transaction_line_rec.application_id
       AND entity_code       = p_transaction_line_rec.entity_code
       AND event_class_code  = p_transaction_line_rec.event_class_code
       AND trx_id            = p_transaction_line_rec.trx_id
       AND trx_line_id       = p_transaction_line_rec.trx_line_id
       AND trx_level_type    = p_transaction_line_rec.trx_level_type;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_LINES_DET_FACTORS_PKG: '||l_api_name||'()-');
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
        END IF;
  END update_line_det_attribs;

/* ============================================================================*
 | PROCEDURE  update_header_det_attribs : Calls the defaulting API to redefault|
 | tax determining attributes since the taxation country has changed           |
 | Also update the lines_det_factors with these values for UI to reflect the   |
 | changes.                                                                    |
 * ===========================================================================*/
PROCEDURE update_header_det_attribs (
  p_taxation_country         IN             VARCHAR2,
  p_document_subtype         IN             VARCHAR2,
  p_tax_invoice_date         IN             DATE,
  p_tax_invoice_number       IN             VARCHAR2,
  p_display_tax_classif_flag IN             VARCHAR2,
  p_transaction_rec          IN             ZX_API_PUB.transaction_rec_type,
  p_event_class_rec          IN  OUT NOCOPY ZX_API_PUB.event_class_rec_type,
  x_return_status            OUT     NOCOPY VARCHAR2
 )  IS
  l_api_name                 CONSTANT  VARCHAR2(30) := 'UPDATE_HEADER_DET_ATTRIBS';
  l_return_status            VARCHAR2(1);
  l_event_class_rec          ZX_API_PUB.event_class_rec_type;

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_LINES_DET_FACTORS_PKG: '||l_api_name||'()+');
   END IF;


   /*-----------------------------------------+
   |   Initialize return status to SUCCESS   |
   +-----------------------------------------*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   OPEN get_lines_det_factors(p_transaction_rec);
     LOOP
       FETCH get_lines_det_factors BULK COLLECT INTO
           zx_global_structures_pkg.trx_line_dist_tbl.APPLICATION_ID,
           zx_global_structures_pkg.trx_line_dist_tbl.ENTITY_CODE,
           zx_global_structures_pkg.trx_line_dist_tbl.EVENT_CLASS_CODE,
           zx_global_structures_pkg.trx_line_dist_tbl.EVENT_TYPE_CODE,
           zx_global_structures_pkg.trx_line_dist_tbl.LINE_LEVEL_ACTION,
           zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID,
           zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_ID,
           zx_global_structures_pkg.trx_line_dist_tbl.TRX_LEVEL_TYPE,
           zx_global_structures_pkg.trx_line_dist_tbl.DEFAULT_TAXATION_COUNTRY,
           zx_global_structures_pkg.trx_line_dist_tbl.DOCUMENT_SUB_TYPE,
           zx_global_structures_pkg.trx_line_dist_tbl.TAX_INVOICE_DATE,
           zx_global_structures_pkg.trx_line_dist_tbl.TAX_INVOICE_NUMBER,
           zx_global_structures_pkg.trx_line_dist_tbl.LINE_INTENDED_USE ,
           zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION ,
           zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_TYPE ,
           zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_CATEGORY ,
           zx_global_structures_pkg.trx_line_dist_tbl.USER_DEFINED_FISC_CLASS,
           zx_global_structures_pkg.trx_line_dist_tbl.ASSESSABLE_VALUE,
           zx_global_structures_pkg.trx_line_dist_tbl.INPUT_TAX_CLASSIFICATION_CODE,
           zx_global_structures_pkg.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE,
           zx_global_structures_pkg.trx_line_dist_tbl.USER_UPD_DET_FACTORS_FLAG,
           zx_global_structures_pkg.trx_line_dist_tbl.TAX_EVENT_CLASS_CODE
     LIMIT G_LINES_PER_FETCH;

     FOR l_trx_line_index IN 1 .. nvl(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.internal_organization_id.LAST,0)
       LOOP
         IF p_taxation_country <>  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULT_TAXATION_COUNTRY(l_trx_line_index) THEN

           --Call TRD service to default the determining attributes again
           ZX_DEFAULT_AUTOMATION_PKG.default_tax_attribs (p_trx_line_index    => l_trx_line_index,
                                                          p_event_class_rec   => p_event_class_rec,
                                                          p_taxation_country  => p_taxation_country,
                                                          p_document_sub_type => p_document_subtype,
                                                          p_tax_invoice_number=> p_tax_invoice_number,
                                                          p_tax_invoice_date  => p_tax_invoice_date,
                                                          x_return_status     => l_return_status
                                                         );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             x_return_status := l_return_status;
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,G_PKG_NAME||': '||l_api_name||':ZX_DEFAULT_AUTOMATION_PKG.redefault_intended_use returned errors');
             END IF;
             RETURN;
           END IF;
         ELSE
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULT_TAXATION_COUNTRY(l_trx_line_index) := p_taxation_country;
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOCUMENT_SUB_TYPE(l_trx_line_index)        := p_document_subtype;
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_INVOICE_DATE(l_trx_line_index)         := p_tax_invoice_date;
           ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_INVOICE_NUMBER(l_trx_line_index)       := p_tax_invoice_number;
         END IF;--taxation country is different
       END LOOP;
     EXIT WHEN get_lines_det_factors%NOTFOUND  OR get_lines_det_factors%NOTFOUND IS NULL;
    END LOOP;
   CLOSE get_lines_det_factors;


   FORALL i IN ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id.FIRST .. ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id.LAST
     UPDATE ZX_LINES_DET_FACTORS SET
          default_taxation_country      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.default_taxation_country(i),
          document_sub_type             = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.document_sub_type(i),
          line_intended_use             = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_intended_use(i),
          user_defined_fisc_class       = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.user_defined_fisc_class(i),
          product_fisc_classification   = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_fisc_classification(i),
          product_category              = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_category(i),
          assessable_value              = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.assessable_value(i),
          input_tax_classification_code = decode(p_display_tax_classif_flag,'Y',ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.input_tax_classification_code(i),
                                                                                input_tax_classification_code),
          tax_invoice_date              = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_invoice_date(i),
          tax_invoice_number            = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_invoice_number(i),
          user_upd_det_factors_flag     ='Y',
          tax_processing_completed_flag ='N',
          object_version_number         = object_version_number+1,
          line_level_action             = decode(line_level_action,'SYNCHRONIZE', 'UPDATE', line_level_action)
        WHERE application_id    = p_transaction_rec.application_id
          AND entity_code       = p_transaction_rec.entity_code
          AND event_class_code  = p_transaction_rec.event_class_code
          AND trx_id            = p_transaction_rec.trx_id ;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_LINES_DET_FACTORS_PKG: '||l_api_name||'()-'||' RETURN_STATUS = ' || l_return_status);
    END IF;

   EXCEPTION
     WHEN OTHERS THEN
        IF (SQLCODE = 54) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('ZX','ZX_RESOURCE_BUSY');
        ELSE
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        END IF;
        IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
        END IF;
 END update_header_det_attribs;

/* =======================================================================*
 | PROCEDURE  lock_line_det_factors : Lock all the lines of a transaction |
 | in zx_lines_det_factors                                                |
 * =======================================================================*/
PROCEDURE lock_line_det_factors (
  p_transaction_rec    IN  ZX_API_PUB.transaction_rec_type,
  x_return_status      OUT NOCOPY VARCHAR2
  )  IS
  l_api_name           CONSTANT  VARCHAR2(30) := 'LOCK_LINE_DET_FACTORS';
  l_return_status      VARCHAR2(1);

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_LINE_DET_FACTORS_PKG: '||l_api_name||'()+');
   END IF;

  /*-----------------------------------------+
   |   Initialize return status to SUCCESS   |
   +-----------------------------------------*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   OPEN get_lines_det_factors(p_transaction_rec);
   CLOSE get_lines_det_factors;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_LINE_DET_FACTORS_PKG: LOCK_LINE_DET_FACTORS()-');
   END IF;

  EXCEPTION
    WHEN OTHERS THEN

        IF (SQLCODE = 54) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('ZX','ZX_RESOURCE_BUSY');
          IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;
        ELSE
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
          END IF;

        END IF;
  END lock_line_det_factors;

END  ZX_LINES_DET_FACTORS_PKG;


/
