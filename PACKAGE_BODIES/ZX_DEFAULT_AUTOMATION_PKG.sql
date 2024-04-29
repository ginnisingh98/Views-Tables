--------------------------------------------------------
--  DDL for Package Body ZX_DEFAULT_AUTOMATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_DEFAULT_AUTOMATION_PKG" AS
 /* $Header: zxdidefautopvtb.pls 120.31.12010000.9 2010/03/25 08:51:32 ssohal ship $ */

 /* Declare constants */

 G_PKG_NAME      CONSTANT VARCHAR2(30)   := 'ZX_DEFAULT_AUTOMATION_PKG';
 G_MODULE_NAME   CONSTANT VARCHAR2(30)   := 'ZX.PLSQL.ZX_DFLT_AUTO_PKG.';
 G_MSG_UERROR    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
 G_MSG_ERROR     CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_ERROR;
 G_MSG_SUCCESS   CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_SUCCESS;

 G_MSG_HIGH      CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
 G_MSG_MEDIUM    CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
 G_MSG_LOW       CONSTANT NUMBER         := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;


 l_error_buffer VARCHAR2(240);

 g_current_runtime_level    NUMBER;
 g_level_statement          CONSTANT  NUMBER   := FND_LOG.LEVEL_STATEMENT;
 g_level_procedure          CONSTANT  NUMBER   := FND_LOG.LEVEL_PROCEDURE;
 g_level_event              CONSTANT  NUMBER   := FND_LOG.LEVEL_EVENT;
 g_level_unexpected         CONSTANT  NUMBER   := FND_LOG.LEVEL_UNEXPECTED;
 g_level_error	           CONSTANT  NUMBER   := FND_LOG.LEVEL_ERROR;

TYPE DET_TAX_ATTR_REC IS RECORD
(DEFAULT_TAXATION_COUNTRY      zx_lines_det_factors.DEFAULT_TAXATION_COUNTRY%type,
 DOCUMENT_SUB_TYPE             zx_lines_det_factors.DOCUMENT_SUB_TYPE%type,
 TRX_BUSINESS_CATEGORY         zx_lines_det_factors.TRX_BUSINESS_CATEGORY%type,
 LINE_INTENDED_USE             zx_lines_det_factors.LINE_INTENDED_USE%type,
 PRODUCT_FISC_CLASSIFICATION   zx_lines_det_factors.PRODUCT_FISC_CLASSIFICATION%type,
 PRODUCT_CATEGORY              zx_lines_det_factors.PRODUCT_CATEGORY%type,
 PRODUCT_TYPE                  zx_lines_det_factors.PRODUCT_TYPE%type,
 USER_DEFINED_FISC_CLASS       zx_lines_det_factors.USER_DEFINED_FISC_CLASS%type,
 ASSESSABLE_VALUE              zx_lines_det_factors.ASSESSABLE_VALUE%type,
 PRODUCT_ID                    zx_lines_det_factors.PRODUCT_ID%type,
 PRODUCT_ORG_ID                zx_lines_det_factors.PRODUCT_ORG_ID%type,
 TAX_CLASSIFICATION_CODE       zx_lines_det_factors.INPUT_TAX_CLASSIFICATION_CODE%type,
 USER_OVERRIDE_TAX_FLAG        zx_lines_det_factors.USER_UPD_DET_FACTORS_FLAG%type);

TYPE DET_TAX_ATTR_TBL IS TABLE OF DET_TAX_ATTR_REC INDEX BY VARCHAR2(150);
l_det_tax_attr_tbl             DET_TAX_ATTR_TBL;

PROCEDURE DEFAULT_FROM_SOURCE_DOC
(
  p_event_class_rec              IN OUT NOCOPY ZX_API_PUB.event_class_rec_type,
  p_trx_line_index               IN            BINARY_INTEGER,
  x_default                      OUT NOCOPY    VARCHAR2,
  x_return_status                OUT NOCOPY    VARCHAR2 )
IS

l_source_line_key    VARCHAR2(2000);
l_upg_trx_info_rec             ZX_ON_FLY_TRX_UPGRADE_PKG.zx_upg_trx_info_rec_type;
l_intrcmp_src_appln_id         NUMBER;
l_intrcmp_src_entity_code      VARCHAR2(30);
l_intrcmp_src_event_class_code VARCHAR2(30);
BEGIN
  IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS.BEGIN',
             'ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_FROM_SOURCE_DOC(+)');
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  x_default       :=  'N';

  IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS',
               'default_taxation_country(' || p_trx_line_index || ') = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.default_taxation_country(p_trx_line_index) || '$' ||
               'DOCUMENT_SUB_TYPE = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOCUMENT_SUB_TYPE(p_trx_line_index) || '$' ||
               'TRX_BUSINESS_CATEGORY = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_BUSINESS_CATEGORY(p_trx_line_index) || '$' ||
               'LINE_INTENDED_USE = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_INTENDED_USE(p_trx_line_index) || '$' ||
               'PRODUCT_FISC_CLASSIFICATION = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION(p_trx_line_index) || '$' ||
               'PRODUCT_CATEGORY = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_CATEGORY(p_trx_line_index) || '$' ||
               'PRODUCT_TYPE = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_TYPE(p_trx_line_index) || '$' ||
               'USER_DEFINED_FISC_CLASS = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.USER_DEFINED_FISC_CLASS(p_trx_line_index) || '$' ||
               'ASSESSABLE_VALUE = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSESSABLE_VALUE(p_trx_line_index) || '$' ||
               'PRODUCT_ID = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_ID(p_trx_line_index) || '$' ||
               'PRODUCT_ORG_ID = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_ORG_ID(p_trx_line_index) || '$' ||
               'INPUT_TAX_CLASSIFICATION_CODE = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INPUT_TAX_CLASSIFICATION_CODE(p_trx_line_index) || '$' ||
               'OUTPUT_TAX_CLASSIFICATION_CODE = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE(p_trx_line_index) || '$' ||
               'LINE_LEVEL_ACTION = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_LEVEL_ACTION(p_trx_line_index)
        );
  END IF;

  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_EVENT_CLASS_CODE(p_trx_line_index) = 'INTERCOMPANY_TRX' THEN
    SELECT intrcmp_src_appln_id,
           intrcmp_src_entity_code,
           intrcmp_src_evnt_cls_code
    INTO l_intrcmp_src_appln_id,
         l_intrcmp_src_entity_code,
         l_intrcmp_src_event_class_code
    FROM ZX_EVNT_CLS_MAPPINGS
    WHERE application_id = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id(p_trx_line_index)
    AND entity_code      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.entity_code(p_trx_line_index)
    AND event_class_code = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_class_code(p_trx_line_index);

    IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_class(p_trx_line_index) = 'AP_CREDIT_MEMO' THEN
      l_intrcmp_src_event_class_code := 'CREDIT_MEMO';
    ELSIF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_class(p_trx_line_index) = 'AP_DEBIT_MEMO' THEN
      l_intrcmp_src_event_class_code := 'DEBIT_MEMO';
    END IF;
  END IF;

  IF (
--    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULT_TAXATION_COUNTRY(p_trx_line_index) IS NULL AND
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOCUMENT_SUB_TYPE(p_trx_line_index) IS NULL AND
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_BUSINESS_CATEGORY(p_trx_line_index) IS NULL AND
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_INTENDED_USE(p_trx_line_index) IS NULL AND
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION(p_trx_line_index) IS NULL AND
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_CATEGORY(p_trx_line_index) IS NULL AND
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_TYPE(p_trx_line_index) IS NULL AND
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.USER_DEFINED_FISC_CLASS(p_trx_line_index) IS NULL) THEN
--      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSESSABLE_VALUE(p_trx_line_index) IS NULL AND

     l_source_line_key := NVL(l_intrcmp_src_appln_id,ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_application_id(p_trx_line_index)) || '$' ||
         NVL(l_intrcmp_src_entity_code,ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_entity_code(p_trx_line_index)) || '$' ||
         NVL(l_intrcmp_src_event_class_code,ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_event_class_code(p_trx_line_index)) || '$' ||
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_trx_id(p_trx_line_index) || '$' ||
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_line_id(p_trx_line_index) || '$' ||
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_trx_level_type(p_trx_line_index);
     IF NOT (l_det_tax_attr_tbl.EXISTS(l_source_line_key)) THEN
        BEGIN
           SELECT default_taxation_country
                , document_sub_type
                , CASE WHEN ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_application_id(p_trx_line_index) <>
                            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id(p_trx_line_index)
                       THEN (
                              CASE WHEN l_intrcmp_src_appln_id IS NOT NULL
                                   THEN DECODE(trx_business_category,
                                               'SALES_TRANSACTION', NULL,
                                               trx_business_category)
                                   WHEN l_intrcmp_src_appln_id IS NULL AND
                                        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(p_trx_line_index)
                                        IN ('RECORD_WITH_NO_TAX','LINE_INFO_TAX_ONLY','CREATE_TAX_ONLY')
                                   THEN NULL
                                   ELSE trx_business_category
                              END
                            )
                       ELSE trx_business_category
                  END trx_business_category
                 , line_intended_use
                , product_fisc_classification
                , product_category
                , product_type
                , user_defined_fisc_class
                , assessable_value
                , product_id
                , product_org_id
                , decode(p_event_class_rec.prod_family_grp_code,
                         'P2P',input_tax_classification_code,
                         'O2C',output_tax_classification_code)
                ,CASE WHEN ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(p_trx_line_index) <> 'COPY_AND_CREATE' THEN
                   DECODE(APPLICATION_ID, 201, NVL(USER_UPD_DET_FACTORS_FLAG, 'N'), 'Y')
                 ELSE 'Y' END user_override_tax_flag
             INTO l_det_tax_attr_tbl(l_source_line_key).DEFAULT_TAXATION_COUNTRY
                , l_det_tax_attr_tbl(l_source_line_key).DOCUMENT_SUB_TYPE
                , l_det_tax_attr_tbl(l_source_line_key).TRX_BUSINESS_CATEGORY
                , l_det_tax_attr_tbl(l_source_line_key).LINE_INTENDED_USE
                , l_det_tax_attr_tbl(l_source_line_key).PRODUCT_FISC_CLASSIFICATION
                , l_det_tax_attr_tbl(l_source_line_key).PRODUCT_CATEGORY
                , l_det_tax_attr_tbl(l_source_line_key).PRODUCT_TYPE
                , l_det_tax_attr_tbl(l_source_line_key).USER_DEFINED_FISC_CLASS
                , l_det_tax_attr_tbl(l_source_line_key).ASSESSABLE_VALUE
                , l_det_tax_attr_tbl(l_source_line_key).PRODUCT_ID
                , l_det_tax_attr_tbl(l_source_line_key).PRODUCT_ORG_ID
                , l_det_tax_attr_tbl(l_source_line_key).TAX_CLASSIFICATION_CODE
                , l_det_tax_attr_tbl(l_source_line_key).USER_OVERRIDE_TAX_FLAG
             FROM zx_lines_det_factors
            WHERE application_id   = NVL(l_intrcmp_src_appln_id,ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_application_id(p_trx_line_index))
              AND entity_code      = NVL(l_intrcmp_src_entity_code,ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_entity_code(p_trx_line_index))
              AND event_class_code = NVL(l_intrcmp_src_event_class_code,ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_event_class_code(p_trx_line_index))
              AND trx_id           = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_trx_id(p_trx_line_index)
              AND trx_line_id      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_line_id(p_trx_line_index)
              AND trx_level_type   = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_trx_level_type(p_trx_line_index);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SOURCE_EVENT_CLASS_CODE(p_trx_line_index) = 'INTERCOMPANY_TRX' THEN
                l_upg_trx_info_rec.application_id   := l_intrcmp_src_appln_id;
                l_upg_trx_info_rec.entity_code      := l_intrcmp_src_entity_code;
                l_upg_trx_info_rec.event_class_code := l_intrcmp_src_event_class_code;
            ELSE
                l_upg_trx_info_rec.application_id   := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_application_id(p_trx_line_index);
                l_upg_trx_info_rec.entity_code      := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_entity_code(p_trx_line_index);
                l_upg_trx_info_rec.event_class_code := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_event_class_code(p_trx_line_index);
            END IF;
            l_upg_trx_info_rec.trx_id           := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_trx_id(p_trx_line_index);
            ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly(p_upg_trx_info_rec   =>  l_upg_trx_info_rec,
                                                         x_return_status      =>  x_return_status
                                                         );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(G_LEVEL_STATEMENT,
                 'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS',
                  ' RETURN_STATUS = ' || x_return_status);
              END IF;
              RETURN;
            END IF;
            SELECT default_taxation_country
                , document_sub_type
                , CASE WHEN ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_application_id(p_trx_line_index) <>
                            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id(p_trx_line_index)
                       THEN (
                              CASE WHEN l_intrcmp_src_appln_id IS NOT NULL
                                   THEN DECODE(trx_business_category,
                                               'SALES_TRANSACTION', NULL,
                                               trx_business_category)
                                   WHEN l_intrcmp_src_appln_id IS NULL AND
                                        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(p_trx_line_index)
                                        IN ('RECORD_WITH_NO_TAX','LINE_INFO_TAX_ONLY','CREATE_TAX_ONLY')
                                   THEN NULL
                                   ELSE trx_business_category
                              END
                            )
                       ELSE trx_business_category
                  END trx_business_category
                , line_intended_use
                , product_fisc_classification
                , product_category
                , product_type
                , user_defined_fisc_class
                , assessable_value
                , product_id
                , product_org_id
                , decode(p_event_class_rec.prod_family_grp_code,
                         'P2P',input_tax_classification_code,
                         'O2C',output_tax_classification_code)
                ,CASE WHEN ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.line_level_action(p_trx_line_index) <> 'COPY_AND_CREATE' THEN
                   DECODE(APPLICATION_ID, 201, NVL(USER_UPD_DET_FACTORS_FLAG, 'N'), 'Y')
                 ELSE 'Y' END user_override_tax_flag
             INTO l_det_tax_attr_tbl(l_source_line_key).DEFAULT_TAXATION_COUNTRY
                , l_det_tax_attr_tbl(l_source_line_key).DOCUMENT_SUB_TYPE
                , l_det_tax_attr_tbl(l_source_line_key).TRX_BUSINESS_CATEGORY
                , l_det_tax_attr_tbl(l_source_line_key).LINE_INTENDED_USE
                , l_det_tax_attr_tbl(l_source_line_key).PRODUCT_FISC_CLASSIFICATION
                , l_det_tax_attr_tbl(l_source_line_key).PRODUCT_CATEGORY
                , l_det_tax_attr_tbl(l_source_line_key).PRODUCT_TYPE
                , l_det_tax_attr_tbl(l_source_line_key).USER_DEFINED_FISC_CLASS
                , l_det_tax_attr_tbl(l_source_line_key).ASSESSABLE_VALUE
                , l_det_tax_attr_tbl(l_source_line_key).PRODUCT_ID
                , l_det_tax_attr_tbl(l_source_line_key).PRODUCT_ORG_ID
                , l_det_tax_attr_tbl(l_source_line_key).TAX_CLASSIFICATION_CODE
                , l_det_tax_attr_tbl(l_source_line_key).USER_OVERRIDE_TAX_FLAG
             FROM zx_lines_det_factors
            WHERE application_id   = NVL(l_intrcmp_src_appln_id,ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_application_id(p_trx_line_index))
              AND entity_code      = NVL(l_intrcmp_src_entity_code,ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_entity_code(p_trx_line_index))
              AND event_class_code = NVL(l_intrcmp_src_event_class_code,ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_event_class_code(p_trx_line_index))
              AND trx_id           = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_trx_id(p_trx_line_index)
              AND trx_line_id      = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_line_id(p_trx_line_index)
              AND trx_level_type   = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_trx_level_type(p_trx_line_index);
        END;
     END IF;
     IF l_det_tax_attr_tbl(l_source_line_key).USER_OVERRIDE_TAX_FLAG = 'Y' THEN
       x_default := 'Y';
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULT_TAXATION_COUNTRY(p_trx_line_index) :=
          NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULT_TAXATION_COUNTRY(p_trx_line_index),l_det_tax_attr_tbl(l_source_line_key).DEFAULT_TAXATION_COUNTRY);
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOCUMENT_SUB_TYPE(p_trx_line_index) := l_det_tax_attr_tbl(l_source_line_key).DOCUMENT_SUB_TYPE;
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_BUSINESS_CATEGORY(p_trx_line_index) := l_det_tax_attr_tbl(l_source_line_key).TRX_BUSINESS_CATEGORY;
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_INTENDED_USE(p_trx_line_index) := l_det_tax_attr_tbl(l_source_line_key).LINE_INTENDED_USE;
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION(p_trx_line_index) := l_det_tax_attr_tbl(l_source_line_key).PRODUCT_FISC_CLASSIFICATION;
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_CATEGORY(p_trx_line_index) := l_det_tax_attr_tbl(l_source_line_key).PRODUCT_CATEGORY;
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_TYPE(p_trx_line_index) := l_det_tax_attr_tbl(l_source_line_key).PRODUCT_TYPE;
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.USER_DEFINED_FISC_CLASS(p_trx_line_index) := l_det_tax_attr_tbl(l_source_line_key).USER_DEFINED_FISC_CLASS;
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSESSABLE_VALUE(p_trx_line_index) :=
          NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSESSABLE_VALUE(p_trx_line_index),l_det_tax_attr_tbl(l_source_line_key).ASSESSABLE_VALUE);
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_ID(p_trx_line_index) :=
          NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_ID(p_trx_line_index),l_det_tax_attr_tbl(l_source_line_key).PRODUCT_ID);
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_ORG_ID(p_trx_line_index) :=
          NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_ORG_ID(p_trx_line_index),l_det_tax_attr_tbl(l_source_line_key).PRODUCT_ORG_ID);

       IF p_event_class_rec.prod_family_grp_code = 'P2P' AND
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INPUT_TAX_CLASSIFICATION_CODE(p_trx_line_index) is null THEN
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.input_tax_classification_code(p_trx_line_index) := l_det_tax_attr_tbl(l_source_line_key).TAX_CLASSIFICATION_CODE;
       ELSIF p_event_class_rec.prod_family_grp_code = 'O2C' AND
             ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE(p_trx_line_index) is null THEN
         ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.output_tax_classification_code(p_trx_line_index) := l_det_tax_attr_tbl(l_source_line_key).TAX_CLASSIFICATION_CODE;
       END IF;
     END IF;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS',
               'default_taxation_country(' || p_trx_line_index || ') = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.default_taxation_country(p_trx_line_index) || '$' ||
               'DOCUMENT_SUB_TYPE = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOCUMENT_SUB_TYPE(p_trx_line_index) || '$' ||
               'TRX_BUSINESS_CATEGORY = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_BUSINESS_CATEGORY(p_trx_line_index) || '$' ||
               'LINE_INTENDED_USE = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_INTENDED_USE(p_trx_line_index) || '$' ||
               'PRODUCT_FISC_CLASSIFICATION = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION(p_trx_line_index) || '$' ||
               'PRODUCT_CATEGORY = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_CATEGORY(p_trx_line_index) || '$' ||
               'PRODUCT_TYPE = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_TYPE(p_trx_line_index) || '$' ||
               'USER_DEFINED_FISC_CLASS = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.USER_DEFINED_FISC_CLASS(p_trx_line_index) || '$' ||
               'ASSESSABLE_VALUE = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSESSABLE_VALUE(p_trx_line_index) || '$' ||
               'PRODUCT_ID = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_ID(p_trx_line_index) || '$' ||
               'PRODUCT_ORG_ID = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_ORG_ID(p_trx_line_index) || '$' ||
               'INPUT_TAX_CLASSIFICATION_CODE = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INPUT_TAX_CLASSIFICATION_CODE(p_trx_line_index) || '$' ||
               'OUTPUT_TAX_CLASSIFICATION_CODE = '
             || ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE(p_trx_line_index)
        );
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
     FND_LOG.STRING(g_level_procedure,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS.END',
             'ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_FROM_SOURCE_DOC(-)');
  END IF;

END DEFAULT_FROM_SOURCE_DOC;

/* =================================================================================*
 | PROCEDURE DEFAULT_TAX_DET_FACTORS                                                    |
 | This procedure is to be called by  lines determine factors UI and                |
 | calculate_tax API                                                                |
 | Expected input trx line information should have been populated in                |
 | ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.                                      |
 | The output will also be populated in ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl. |
                                                                                    |
 * ================================================================================*/

PROCEDURE DEFAULT_TAX_DET_FACTORS
(
  p_trx_line_index       IN            BINARY_INTEGER,
  p_event_class_rec      IN OUT NOCOPY ZX_API_PUB.event_class_rec_type,
  p_taxation_country     IN            VARCHAR2,
  p_document_sub_type    IN            VARCHAR2,
  x_return_status        OUT NOCOPY    VARCHAR2 )
IS
  l_country_code            XLE_FIRSTPARTY_INFORMATION_V.COUNTRY%TYPE;
  l_trx_business_category   VARCHAR2(240);
  l_product_category        ZX_FC_COUNTRY_DEFAULTS.PRODUCT_CATEG_DEFAULT%TYPE;
  l_product_fisc_class      ZX_FC_TYPES_B.CLASSIFICATION_TYPE_CODE%TYPE;
  l_intended_use            ZX_FC_TYPES_B.CLASSIFICATION_TYPE_CODE%TYPE;
  l_trx_date                DATE;
  l_document_sub_type       ZX_FC_DOCUMENT_FISCAL_V.CLASSIFICATION_CODE%TYPE;
  l_user_defined_fisc_class ZX_FC_CODES_B.CLASSIFICATION_CODE%TYPE;
  l_product_type            FND_LOOKUPS.LOOKUP_CODE%TYPE;
  l_init_msg_list           VARCHAR2(1);
  l_commit                  VARCHAR2(1);
  l_validation_level        NUMBER;
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(1);
  l_error_buffer            VARCHAR2(2000);
  l_definfo                 ZX_API_PUB.def_tax_cls_code_info_rec_type;
  l_inventory_org_id        NUMBER;
  l_context_info_rec        ZX_API_PUB.context_info_rec_type;
  l_default                 VARCHAR2(1);

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS.BEGIN',
             'ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS(+)'||
             ' taxation_country = ' || p_taxation_country||
             ' document_sub_type = ' || p_document_sub_type);
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  l_trx_date := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DATE(p_trx_line_index);

  l_country_code := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULT_TAXATION_COUNTRY(p_trx_line_index);

  /*
  When a transaction is created from a source transaction,
  the defaulting should happen from the source and NOT from the setup.
  */

  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.source_trx_id(p_trx_line_index) is not null THEN
     default_from_source_doc( p_event_class_rec,
                              p_trx_line_index,
			      l_default,
                              x_return_status);
     IF l_default = 'Y' THEN
       RETURN;
     END IF;
  END IF;

  /*
  case 1 : In update mode, if taxation country is changed or
  case 2 : When a new trx line gets inserted, if there are already other trx lines existing
           in zx_lines_det_facotrs then default taxation country and document sub type values
           will be passed from the existing trx lines.
  In both cases re-default the tax attributes based on taxation country parameter
  */

  -- If taxation country is passed then default the other tax attributes based on the passed value.
  IF p_taxation_country IS NOT NULL AND (l_country_code IS NULL OR l_country_code <> p_taxation_country) THEN

    l_country_code := p_taxation_country;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULT_TAXATION_COUNTRY(p_trx_line_index) := p_taxation_country;

    /* If line level action is other than Create or any of the defaulting tax attributes are not null then
    don't do the defaulting */

  ELSE
    IF p_taxation_country IS NULL AND l_country_code IS NULL THEN

      --******************** DEFAULT TAXATION COUNTRY *************************
      --Call the procedure the get the default country code
      GET_DEFAULT_COUNTRY_CODE(
            p_event_class_rec.tax_method_code,
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.internal_organization_id(p_trx_line_index),
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEGAL_ENTITY_ID(p_trx_line_index),
            l_country_code,
            x_return_status );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
           'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS',
           'Incorrect return_status after calling ' ||
           'ZX_TCM_EXT_SERVICES_PUB.GET_DEFAULT_COUNTRY_CODE');
          FND_LOG.STRING(g_level_error,
           'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS.END',
           'ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS(-)'||x_return_status);
        END IF;

        RETURN;

      END IF;

      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DEFAULT_TAXATION_COUNTRY(p_trx_line_index) := l_country_code;

      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS',
               'l_country_code = ' || l_country_code);
      END IF;

    ELSE

      IF NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.USER_UPD_DET_FACTORS_FLAG(p_trx_line_index), 'N') = 'Y' OR
        -- NVL(p_trx_line_changed,'N') = 'N' AND
       (ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOCUMENT_SUB_TYPE(p_trx_line_index) IS NOT NULL OR
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_BUSINESS_CATEGORY(p_trx_line_index) IS NOT NULL OR
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_INTENDED_USE(p_trx_line_index) IS NOT NULL OR
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION(p_trx_line_index) IS NOT NULL OR
        -- ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_CATEGORY(p_trx_line_index) IS NOT NULL OR
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_TYPE(p_trx_line_index) IS NOT NULL OR
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.USER_DEFINED_FISC_CLASS(p_trx_line_index) IS NOT NULL OR
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSESSABLE_VALUE(p_trx_line_index) IS NOT NULL) THEN

        IF (g_level_statement >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_statement,
            'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS',
            'One of the defaulting tax attributes are not null. So defaulting logic is not required.' ||
            'ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS()');
         FND_LOG.STRING(g_level_statement,
            'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS.END',
            'ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS(-)');
        END IF;

        RETURN;
      END IF;
    END IF;  -- p_taxation_country IS NULL AND l_country_code IS NULL
  END IF;    -- p_taxation_country IS NOT NULL AND (l_country_code IS NULL OR ...)

  --******************** DOCUMENT SUB TYPE ********************************
  -- In the update mode if document sub type is passed then copy the passed value.
  IF p_document_sub_type IS NOT NULL THEN

    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOCUMENT_SUB_TYPE(p_trx_line_index) := p_document_sub_type;

  ELSIF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOCUMENT_SUB_TYPE(p_trx_line_index) IS NULL THEN

    -- Bug 4637855: Use TCM API to derive document_sub_type
    --
    ZX_TCM_EXT_SERVICES_PUB.get_default_classif_code(
            p_fiscal_type_code  => 'DOCUMENT_SUBTYPE',
            p_country_code      => l_country_code,
            p_application_id    => NULL,
            p_entity_code       => NULL,
            p_event_class_code  => NULL,
            p_source_event_class_code  => NULL,
            p_item_id           => NULL,
            p_org_id            => NULL,
            p_default_code      => l_document_sub_type,
            p_return_status     => x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
         'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS',
         'Incorrect return_status after calling ' ||
         'ZX_TCM_EXT_SERVICES_PUB.get_default_classif_code for document_sub_type');
        FND_LOG.STRING(g_level_error,
         'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS.END',
         'ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS(-)'||x_return_status);
      END IF;
      RETURN;
    END IF;

--    BEGIN
--      SELECT classification_code INTO l_document_sub_type
--        FROM ZX_FC_DOCUMENT_FISCAL_V
--       WHERE l_trx_date between effective_from and nvl(effective_to, l_trx_date)
--         AND (country_code = l_country_code OR country_code IS NULL);
--    EXCEPTION
--      WHEN NO_DATA_FOUND THEN
--        IF (g_level_event >= g_current_runtime_level ) THEN
--          FND_LOG.STRING(g_level_event,
--                 'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS',
--                 'No document_sub_type Found. ');
--        END IF;
--        l_document_sub_type := NULL;
--      WHEN TOO_MANY_ROWS THEN
--        IF (g_level_event >= g_current_runtime_level ) THEN
--          FND_LOG.STRING(g_level_event,
--                 'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS',
--                 'No document_sub_type defaulted. ');
--        END IF;
--        l_document_sub_type := NULL;
--      WHEN OTHERS THEN
--        IF (g_level_event >= g_current_runtime_level ) THEN
--          FND_LOG.STRING(g_level_event,
--                 'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS',
--                  sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
--          FND_LOG.STRING(g_level_event,
--                 'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS',
--                 'Other Exception: This exception will not stop the program.');
--        END IF;
--    END;

    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.DOCUMENT_SUB_TYPE(p_trx_line_index) := l_document_sub_type;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS',
             'l_document_sub_type = ' || l_document_sub_type);
    END IF;
  END IF;

  -- If Tax method is Latin Tax Engine then
  IF p_event_class_rec.tax_method_code = 'LTE' THEN

    JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR(
    		p_trx_line_index  => p_trx_line_index,
    		x_return_status   => x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
         'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS',
         'Incorrect return_status after calling ' ||
         'ZX_API_PUB.GET_DEFAULT_TAX_DET_ATTRIBS');
        FND_LOG.STRING(g_level_error,
         'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS.END',
         'ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS(-)'||x_return_status);
      END IF;
      RETURN;
    END IF;
  ELSE -- if tax method is ETAX then

  --******************** DEFAULT TAX LINE ATTRIBUTES ***********************
  IF p_event_class_rec.prod_family_grp_code = 'O2C' THEN
    l_inventory_org_id := nvl(ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_from_party_id(p_trx_line_index),
                                ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_org_id(p_trx_line_index));
  ELSIF p_event_class_rec.prod_family_grp_code = 'P2P' THEN
    l_inventory_org_id := nvl(ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.ship_to_party_id(p_trx_line_index),
                                ZX_GLOBAL_STRUCTURES_PKG.TRX_LINE_DIST_TBL.product_org_id(p_trx_line_index));
  END IF;
  IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS',
             'l_inventory_org_id = ' || NVL(l_inventory_org_id,-99));
  END IF;
    ZX_API_PUB.GET_DEFAULT_TAX_DET_ATTRIBS
    (p_api_version            => 1.0,
     p_init_msg_list          => l_init_msg_list,
     p_commit                 => l_commit,
     p_validation_level       => l_validation_level,
     x_return_status          => x_return_status,
     x_msg_count              => l_msg_count,
     x_msg_data               => l_msg_data,
     p_application_id         => p_event_class_rec.application_id,
     p_entity_code            => p_event_class_rec.entity_code,
     p_event_class_code       => p_event_class_rec.event_class_code,
     p_org_id                 => zx_global_structures_pkg.trx_line_dist_tbl.internal_organization_id(p_trx_line_index),
     p_item_id                => zx_global_structures_pkg.trx_line_dist_tbl.product_id(p_trx_line_index),
     p_country_code           => l_country_code,
     p_effective_date         => l_trx_date,
     p_source_event_class_code       => zx_global_structures_pkg.trx_line_dist_tbl.source_event_class_code(p_trx_line_index),
     x_trx_biz_category       => l_trx_business_category,
     x_intended_use           => l_intended_use,
     x_prod_category          => l_product_category,
     x_prod_fisc_class_code   => l_product_fisc_class,
     x_product_type           => l_product_type,
     p_inventory_org_id       => l_inventory_org_id
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
           'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS',
           'Incorrect return_status after calling ' ||
           'ZX_API_PUB.GET_DEFAULT_TAX_DET_ATTRIBS');
        FND_LOG.STRING(g_level_error,
           'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS.END',
           'ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS(-)'||x_return_status);
      END IF;
      RETURN;
    END IF;

    -- Populate the default value for Product category, Product Fiscal Classification and Intended Use
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_BUSINESS_CATEGORY(p_trx_line_index) := l_trx_business_category;
    IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_CATEGORY(p_trx_line_index) IS NULL THEN
      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_CATEGORY(p_trx_line_index) := l_product_category;
    END IF;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION(p_trx_line_index) := l_product_fisc_class;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_INTENDED_USE(p_trx_line_index) := l_intended_use;
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_TYPE(p_trx_line_index) := l_product_type;

    --Populate the default value for assessable value from line amount
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ASSESSABLE_VALUE(p_trx_line_index) := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_AMT(p_trx_line_index);

    -- Bug 5622704: Do not default user defined fiscal classification
    -- Bug 4637855: Use TCM API to derive user defined fiscal classification
    --
    -- ZX_TCM_EXT_SERVICES_PUB.get_default_classif_code(
    --         p_fiscal_type_code  => 'USER_DEFINED',
    --         p_country_code      => l_country_code,
    --         p_application_id    => NULL,
    --         p_entity_code       => NULL,
    --         p_event_class_code  => NULL,
    --         p_source_event_class_code  => NULL,
    --         p_item_id           => NULL,
    --         p_org_id            => NULL,
    --         p_default_code      => l_user_defined_fisc_class,
    --         p_return_status     => x_return_status);
    --
    -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    --   IF (g_level_statement >= g_current_runtime_level ) THEN
    --     FND_LOG.STRING(g_level_statement,
    --      'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS',
    --      'Incorrect return_status after calling ' ||
    --      'ZX_TCM_EXT_SERVICES_PUB.get_default_classif_code for user_defined');
    --     FND_LOG.STRING(g_level_statement,
    --      'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS.END',
    --      'ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS(-)'||x_return_status);
    --   END IF;
    --   RETURN;
    -- END IF;
    --
    -- IF (g_level_statement >= g_current_runtime_level ) THEN
    --   FND_LOG.STRING(g_level_statement,
    --          'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS',
    --          'l_user_defined_fisc_class= ' || l_user_defined_fisc_class);
    -- END IF;
    --
    -- ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.USER_DEFINED_FISC_CLASS(
    --                          p_trx_line_index) := l_user_defined_fisc_class;


  END IF; -- End of Tax method check

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS.END',
           'ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS(-)'||x_return_status);
  END IF;

EXCEPTION

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
    l_context_info_rec.APPLICATION_ID   := p_event_class_rec.application_id;
    l_context_info_rec.ENTITY_CODE      := p_event_class_rec.entity_code;
    l_context_info_rec.EVENT_CLASS_CODE := p_event_class_rec.event_class_code;
    l_context_info_rec.TRX_ID           := p_event_class_rec.trx_id;
    IF ZX_API_PUB.G_DATA_TRANSFER_MODE IS NULL
      OR l_context_info_rec.TRX_ID IS NULL
    THEN
      FND_MSG_PUB.Add;
    ELSE
      ZX_API_PUB.add_msg( p_context_info_rec =>l_context_info_rec );
    END IF;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS',
              sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS.END',
             'ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_DET_FACTORS(-)');
    END IF;

END DEFAULT_TAX_DET_FACTORS;


PROCEDURE DEFAULT_TAX_REPORTING_ATTRIBS
(
  p_trx_line_index         IN  BINARY_INTEGER,
  p_tax_invoice_number     IN  VARCHAR2,
  p_tax_invoice_date       IN  DATE,
  x_return_status          OUT NOCOPY VARCHAR2
)

IS

 l_api_name           CONSTANT VARCHAR2(30) := 'DEFAULT_TAX_REPORTING_ATTRIBS';

 l_tax_invoice_number    ZX_LINES_DET_FACTORS.TAX_INVOICE_NUMBER%TYPE;
 l_tax_invoice_date      ZX_LINES_DET_FACTORS.TAX_INVOICE_DATE%TYPE;

 l_context_info_rec        ZX_API_PUB.context_info_rec_type;

BEGIN
-- start bug#6503114
x_return_status  := FND_API.G_RET_STS_SUCCESS;
-- end bug#6503114

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

  BEGIN
    SELECT nvl(global_attribute8,'0') global_attribute8,
           to_char(to_date(global_attribute9,'YYYY/MM/DD HH24:MI:SS'),
           'RRRR-MON-DD') global_attribute9 INTO l_tax_invoice_number, l_tax_invoice_date
      FROM RA_BATCH_SOURCES_ALL
     WHERE batch_source_id = ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BATCH_SOURCE_ID(p_trx_line_index)
       AND NVL(org_id, -99) =
           NVL(ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.internal_organization_id(p_trx_line_index), -99);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_REPORTING_ATTRIBS',
               'No Record Found for tax_invoice_number and tax_invoice_date.');
      END IF;
    WHEN OTHERS THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_REPORTING_ATTRIBS',
                sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      END IF;
  END;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        'p_tax_invoice_number   := ' || p_tax_invoice_number||
        ' l_tax_invoice_number   := ' || l_tax_invoice_number||
        'p_tax_invoice_date   := ' || p_tax_invoice_date||
        'l_tax_invoice_date   := ' || l_tax_invoice_date);
  END IF;

  IF p_tax_invoice_number IS NOT NULL THEN

    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_INVOICE_NUMBER(p_trx_line_index) := p_tax_invoice_number;

  ELSIF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_INVOICE_NUMBER(p_trx_line_index) IS NULL THEN

    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_INVOICE_NUMBER(p_trx_line_index) := l_tax_invoice_number;

  END IF;

  IF p_tax_invoice_date IS NOT NULL THEN

    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_INVOICE_DATE(p_trx_line_index) := p_tax_invoice_date;

  ELSIF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_INVOICE_DATE(p_trx_line_index) IS NULL THEN

    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TAX_INVOICE_DATE(p_trx_line_index) := l_tax_invoice_date;

  END IF;

  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME ||l_api_name||'(-)');
  END IF;

EXCEPTION

  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
    l_context_info_rec.APPLICATION_ID   := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id(p_trx_line_index);
    l_context_info_rec.ENTITY_CODE      := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.entity_code(p_trx_line_index);
    l_context_info_rec.EVENT_CLASS_CODE := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_class_code(p_trx_line_index);
    l_context_info_rec.TRX_ID           := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_id(p_trx_line_index);
    IF ZX_API_PUB.G_DATA_TRANSFER_MODE IS NULL
      OR l_context_info_rec.TRX_ID IS NULL
    THEN
      FND_MSG_PUB.Add;
    ELSE
      ZX_API_PUB.add_msg( p_context_info_rec =>l_context_info_rec );
    END IF;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_REPORTING_ATTRIBS',
              sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_REPORTING_ATTRIBS.END',
             'ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_REPORTING_ATTRIBS(-)');
    END IF;


END DEFAULT_TAX_REPORTING_ATTRIBS;


PROCEDURE DEFAULT_TAX_CLASSIFICATION
(
  p_trx_line_index        IN  BINARY_INTEGER,
  x_return_status         OUT NOCOPY VARCHAR2
)

IS

 l_api_name           CONSTANT VARCHAR2(30) := 'DEFAULT_TAX_CLASSIFICATION';
 l_error_buffer    VARCHAR2(240);
 l_definfo         ZX_API_PUB.def_tax_cls_code_info_rec_type;

BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    -- If Application is PO and Input classification code is Null then default the value.
    IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLICATION_ID(p_trx_line_index) = 201 AND
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INPUT_TAX_CLASSIFICATION_CODE(p_trx_line_index) IS NULL THEN

      l_definfo.ref_doc_application_id   := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_application_id(p_trx_line_index);
      l_definfo.ref_doc_entity_code      := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_entity_code(p_trx_line_index);
      l_definfo.ref_doc_event_class_code := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_event_class_code(p_trx_line_index);
      l_definfo.ref_doc_trx_id           := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_trx_id(p_trx_line_index);
      l_definfo.ref_doc_line_id          := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_line_id(p_trx_line_index);
      l_definfo.ref_doc_trx_level_type   := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ref_doc_trx_level_type(p_trx_line_index);
      --l_definfo.vendor_id             := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_from_party_id(p_trx_line_index);
      -- bug#4991176
      -- l_definfo.ship_third_pty_acct_id  := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_from_party_id(p_trx_line_index);
      --l_definfo.vendor_site_id        := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_from_party_site_id(p_trx_line_index);
      -- bug#4991176
      --l_definfo.ship_third_pty_acct_site_id := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_from_party_site_id(p_trx_line_index);
      l_definfo.account_ccid := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.account_ccid(p_trx_line_index);
      l_definfo.account_string  := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.account_string(p_trx_line_index);
      l_definfo.ship_to_location_id   := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_to_location_id(p_trx_line_index);
      l_definfo.product_id            := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_id(p_trx_line_index);
      l_definfo.application_id        := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id(p_trx_line_index);
      l_definfo.event_class_code      := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_class_code(p_trx_line_index);
      l_definfo.entity_code           := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.entity_code(p_trx_line_index);
      --l_definfo.bill_to_site_use_id   := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_third_pty_acct_id(p_trx_line_index);
      l_definfo.bill_to_cust_acct_site_use_id  := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_to_cust_acct_site_use_id(p_trx_line_index);
      --l_definfo.ship_to_site_use_id   := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_third_pty_acct_id(p_trx_line_index);
     l_definfo.ship_to_cust_acct_site_use_id := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_to_cust_acct_site_use_id(p_trx_line_index);
      l_definfo.ledger_id             := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ledger_id(p_trx_line_index);
      l_definfo.trx_date              := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_date(p_trx_line_index);
      l_definfo.receivables_trx_type_id  := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.receivables_trx_type_id(p_trx_line_index);
      l_definfo.trx_id                := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_id(p_trx_line_index);
      l_definfo.trx_line_id           := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_line_id(p_trx_line_index);
      l_definfo.ship_third_pty_acct_id := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_third_pty_acct_id(p_trx_line_index);
      -- bug#4991176
      l_definfo.ship_third_pty_acct_site_id := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ship_third_pty_acct_site_id(p_trx_line_index);

       l_definfo.bill_third_pty_acct_id := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.bill_third_pty_acct_id(p_trx_line_index);

      l_definfo.product_org_id        := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_org_id(p_trx_line_index);
      l_definfo.internal_organization_id := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.internal_organization_id(p_trx_line_index);

      --
      -- bug#4868489
      --
      l_definfo.legal_entity_id       :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.legal_entity_id(p_trx_line_index);

      -- Per discussion with Sri, Pass all the defaulting attributes from
      -- trx_line_dist_tbl. These defaulting attributes will be intepreted internally.
      --
      -- bug#4868489- removed the call to
      -- ZX_TAX_DEFAULT_PKG.map_parm_for_def_tax_classif
      -- and assign directly to defaulting_attributes
      -- in l_definfo record
      --
      l_definfo.defaulting_attribute1  :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.defaulting_attribute1(p_trx_line_index);
      l_definfo.defaulting_attribute2  :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.defaulting_attribute2(p_trx_line_index);
      l_definfo.defaulting_attribute3  :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.defaulting_attribute3(p_trx_line_index);
      l_definfo.defaulting_attribute4  :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.defaulting_attribute4(p_trx_line_index);
      l_definfo.defaulting_attribute5  :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.defaulting_attribute5(p_trx_line_index);
      l_definfo.defaulting_attribute6  :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.defaulting_attribute6(p_trx_line_index);
      l_definfo.defaulting_attribute7  :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.defaulting_attribute7(p_trx_line_index);
      l_definfo.defaulting_attribute8  :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.defaulting_attribute8(p_trx_line_index);
      l_definfo.defaulting_attribute9  :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.defaulting_attribute9(p_trx_line_index);
      l_definfo.defaulting_attribute10 :=
            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.defaulting_attribute10(p_trx_line_index);

      ZX_TAX_DEFAULT_PKG.get_default_tax_classification
          (p_definfo        => l_definfo,
           p_return_status  => x_return_status,
           p_error_buffer   => l_error_buffer
          );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        IF (g_level_error >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_error,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_CLASSIFICATION',
             'Incorrect return_status after calling ' ||
             'ZX_TAX_DEFAULT_PKG.get_default_tax_classification');
          FND_LOG.STRING(g_level_error,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_CLASSIFICATION.END',
             'ZX_DEFAULT_AUTOMATION_PKG.DEFAULT_TAX_CLASSIFICATION(-)');
        END IF;

        RETURN;

      END IF;

      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INPUT_TAX_CLASSIFICATION_CODE(p_trx_line_index) := l_definfo.input_tax_classification_code;

    END IF; -- End of PO Application check

  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME ||l_api_name||'(-)');
  END IF;

END DEFAULT_TAX_CLASSIFICATION;


-- This is the main wrapper procedure
PROCEDURE DEFAULT_TAX_ATTRIBS
(
  p_trx_line_index         IN	         BINARY_INTEGER,
  p_event_class_rec        IN OUT NOCOPY ZX_API_PUB.event_class_rec_type,
  p_taxation_country	   IN            VARCHAR2,
  p_document_sub_type	   IN            VARCHAR2,
  p_tax_invoice_number     IN            VARCHAR2,
  p_tax_invoice_date       IN            DATE,
  x_return_status          OUT NOCOPY    VARCHAR2
)
IS

  l_api_name           CONSTANT VARCHAR2(30) := 'DEFAULT_TAX_ATTRIBS';

BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   DEFAULT_TAX_DET_FACTORS
	(
	  p_trx_line_index,
	  p_event_class_rec,
	  p_taxation_country,
	  p_document_sub_type,
	  x_return_status
	);

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            'after calling default_tax_det_factors RETURN_STATUS = ' || x_return_status);
      END IF;
--      RETURN;
   END IF;

   DEFAULT_TAX_REPORTING_ATTRIBS
	(
	  p_trx_line_index,
	  p_tax_invoice_number,
	  p_tax_invoice_date,
	  x_return_status
	);

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            'after calling default_tax_reporting_attribs RETURN_STATUS = ' || x_return_status);
      END IF;
--      RETURN;
   END IF;

   DEFAULT_TAX_CLASSIFICATION
	(
	  p_trx_line_index,
	  x_return_status
	);

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF ( G_LEVEL_error >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_error,G_MODULE_NAME||l_api_name,
            'after calling default_tax_classification RETURN_STATUS = ' || x_return_status);
      END IF;
--      RETURN;
   END IF;

END DEFAULT_TAX_ATTRIBS;

-- Re-Defaulting APIs
--
PROCEDURE redefault_intended_use(
  p_application_id       IN            NUMBER,
  p_entity_code          IN            VARCHAR2,
  p_event_class_code     IN            VARCHAR2,
  p_internal_org_id      IN            NUMBER,
  p_country_code         IN            VARCHAR2,
  p_item_id              IN            NUMBER,
  p_item_org_id          IN            NUMBER,
  x_intended_use            OUT NOCOPY VARCHAR2,
  x_return_status           OUT NOCOPY VARCHAR2) IS

  l_tax_method                  VARCHAR2(30);
  l_error_buffer		VARCHAR2(256);
  l_zx_proudct_options_rec      ZX_GLOBAL_STRUCTURES_PKG.zx_product_options_rec_type;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.redefault_intended_use.BEGIN',
           'ZX_DEFAULT_AUTOMATION_PKG.redefault_intended_use(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- get tax method
  --

  ZX_GLOBAL_STRUCTURES_PKG.get_product_options_info
                   (p_application_id      => p_application_id,
                    p_org_id              => p_internal_org_id,
                    x_product_options_rec => l_zx_proudct_options_rec,
                    x_return_status       => x_return_status);
  IF x_return_status = FND_API.G_RET_STS_ERROR then
        l_tax_method := 'EBTAX';
  ELSE
        l_tax_method := l_zx_proudct_options_rec.tax_method_code;
  END IF;

  IF l_tax_method = 'EBTAX' THEN

    ZX_TCM_EXT_SERVICES_PUB.get_default_classif_code(
                            p_fiscal_type_code  =>  'INTENDED_USE',
                            p_country_code      =>  p_country_code,
                            p_application_id    =>  p_application_id,
                            p_entity_code       =>  p_entity_code,
                            p_event_class_code  =>  p_event_class_code,
            		    p_source_event_class_code  => NULL,
                            p_org_id            =>  p_item_org_id,
                            p_item_id           =>  p_item_id,
                            p_default_code      =>  x_intended_use,
                            p_return_status     =>  x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.redefault_intended_use',
               'Incorrect return_status after calling ' ||
               'ZX_TCM_EXT_SERVICES_PUB.get_default_classif_code()');
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.redefault_intended_use.END',
               'ZX_DEFAULT_AUTOMATION_PKG.redefault_intended_use(-)');
      END IF;
      RETURN;
    END IF;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.redefault_intended_use.END',
                  'ZX_DEFAULT_AUTOMATION_PKG.redefault_intended_use(-)'||
                  'x_intended_use := ' || x_intended_use||
                  'RETURN_STATUS = ' || x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_intended_use := NULL;

    FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.redefault_intended_use',
              sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.redefault_intended_use.END',
             'ZX_DEFAULT_AUTOMATION_PKG.redefault_intended_use(-)');
    END IF;

END redefault_intended_use;

PROCEDURE redefault_prod_fisc_class_code(
  p_application_id       IN            NUMBER,
  p_entity_code          IN            VARCHAR2,
  p_event_class_code     IN            VARCHAR2,
  p_internal_org_id      IN            NUMBER,
  p_country_code         IN            VARCHAR2,
  p_item_id              IN            NUMBER,
  p_item_org_id          IN            NUMBER,
  x_prod_fisc_class_code    OUT NOCOPY VARCHAR2,
  x_return_status           OUT NOCOPY VARCHAR2) IS

  l_tax_method                  VARCHAR2(30);
  l_error_buffer		VARCHAR2(256);
  l_zx_proudct_options_rec      ZX_GLOBAL_STRUCTURES_PKG.zx_product_options_rec_type;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.redefault_prod_fisc_class_code.BEGIN',
           'ZX_DEFAULT_AUTOMATION_PKG.redefault_prod_fisc_class_code(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  ZX_GLOBAL_STRUCTURES_PKG.get_product_options_info
                   (p_application_id      => p_application_id,
                    p_org_id              => p_internal_org_id,
                    x_product_options_rec => l_zx_proudct_options_rec,
                    x_return_status       => x_return_status);
  IF x_return_status = FND_API.G_RET_STS_ERROR then
        l_tax_method := 'EBTAX';
  ELSE
        l_tax_method := l_zx_proudct_options_rec.tax_method_code;
  END IF;


  IF l_tax_method = 'EBTAX' THEN

    ZX_TCM_EXT_SERVICES_PUB.get_default_product_classif(
                            p_country_code    =>  p_country_code,
                            p_item_id         =>  p_item_id,
                            p_org_id          =>  p_item_org_id,
                            p_default_code    =>  x_prod_fisc_class_code,
                            p_return_status   =>  x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_error >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.redefault_prod_fisc_class_code',
               'Incorrect return_status after calling ' ||
               'ZX_TCM_EXT_SERVICES_PUB.get_default_product_classif()');
        FND_LOG.STRING(g_level_error,
               'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.redefault_prod_fisc_class_code.END',
               'ZX_DEFAULT_AUTOMATION_PKG.redefault_prod_fisc_class_code(-)'||x_return_status);
      END IF;
      RETURN;
    END IF;
  ELSIF l_tax_method = 'LTE' THEN

    IF p_item_id IS NOT NULL and p_item_org_id IS NOT NULL THEN

      BEGIN

        SELECT fc.classification_code
          INTO x_prod_fisc_class_code
          FROM zx_fc_product_fiscal_v fc,
               mtl_item_categories mic
         WHERE fc.country_code =  p_country_code
           AND mic.inventory_item_id = p_item_id
           AND mic.organization_id  = p_item_org_id
           AND mic.category_id = fc.category_id
           AND mic.category_set_id = fc.category_set_id
           AND fc.structure_name = 'PRODUCT_FISCAL_CLASS'
           AND fc.country_code in ('JL', 'BR', 'CO')
           AND EXISTS
               ( SELECT 1
                   FROM jl_zz_ar_tx_fsc_cls_all
                  WHERE fiscal_classification_code = fc.classification_code
                    AND NVL(org_id, -99) = NVL(p_internal_org_id, -99)
                    AND enabled_flag = 'Y');

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.redefault_prod_fisc_class_code',
                   'Unable to default Product Fiscal Classification which is mandatory for LTE');
          END IF;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      END;
    ELSIF p_item_id IS NOT NULL and p_item_org_id IS NULL THEN

      -- In case where the product type is 'MEMO', default Product Category
      -- from ar_memo_lines.
      --
      BEGIN
        SELECT memo.global_attribute2 product_category
          INTO x_prod_fisc_class_code
          FROM ar_memo_lines_all_b Memo
         WHERE memo_line_id = p_item_id
           AND NVL(org_id, -99) = NVL(p_internal_org_id, -99);

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                   'JL_ZZ_TAX_VALIDATE_PKG.DEFAULT_TAX_ATTR',
                   'Unable to default Product Fiscal Classification ot Trx Business Category'||
                   ' which is mandatory for LTE');
          END IF;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      END;
    END IF;
  END IF;


  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.redefault_prod_fisc_class_code.END',
           'ZX_DEFAULT_AUTOMATION_PKG.redefault_prod_fisc_class_code(-)'||
           'x_prod_fisc_class_code := ' || x_prod_fisc_class_code||
           'RETURN_STATUS = ' || x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_prod_fisc_class_code := NULL;

    FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.redefault_prod_fisc_class_code',
              sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.redefault_prod_fisc_class_code.END',
             'ZX_DEFAULT_AUTOMATION_PKG.redefault_prod_fisc_class_code(-)');
    END IF;

END redefault_prod_fisc_class_code;

PROCEDURE redefault_assessable_value(
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
  x_assessable_value        OUT NOCOPY NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2) IS

  l_error_buffer		VARCHAR2(256);

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.redefault_assessable_value.BEGIN',
           'ZX_DEFAULT_AUTOMATION_PKG.redefault_assessable_value(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Just assign line_amt to the x_assessable_vale. For the logic to get default
  -- assessable value will be determinered based on the input parameters
  --
  x_assessable_value := p_line_amt;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.redefault_assessable_value.END',
           'ZX_DEFAULT_AUTOMATION_PKG.redefault_assessable_value(-)'||
           ' assessable value: '||x_assessable_value);
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_assessable_value := NULL;

    FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.redefault_assessable_value',
              sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.redefault_assessable_value.END',
             'ZX_DEFAULT_AUTOMATION_PKG.redefault_assessable_value(-)');
    END IF;

END redefault_assessable_value;

 -- This is the defaulting api for PO on-the_fly migration
 --
 PROCEDURE default_tax_attributes_for_po(
  p_trx_line_index         IN	         BINARY_INTEGER,
  x_return_status          OUT NOCOPY    VARCHAR2) IS

 l_tax_code_id                  NUMBER;
 l_tax_determine_date           DATE;
 l_tax_date                     DATE;
 l_tax_point_date               DATE;
 l_tax_classification_code      VARCHAR2(150);
 l_effective_from               DATE;
 l_effective_to                 DATE;

 l_country_code                 XLE_FIRSTPARTY_INFORMATION_V.COUNTRY%TYPE;
 l_fnd_return                   BOOLEAN;
 l_inv_flag                     VARCHAR2(30);
 l_inv_industry                 VARCHAR2(30);
 l_temp_attribute1            mtl_system_items_b.global_attribute1%TYPE;

 l_error_buffer		        VARCHAR2(256);
 l_context_info_rec             ZX_API_PUB.context_info_rec_type;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.default_tax_attributes_for_po.BEGIN',
           'ZX_DEFAULT_AUTOMATION_PKG.default_tax_attributes_for_po(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_tax_code_id :=
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.historical_tax_code_id(
                                                              p_trx_line_index);

  IF l_tax_code_id IS NOT NULL THEN


    ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_date(
                                       p_trx_line_index,
                                       l_tax_date,
                                       l_tax_determine_date,
                                       l_tax_point_date,
                                       x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.default_tax_attributes_for_po',
               'Incorrect return_status after calling ' ||
               'ZX_TDS_APPLICABILITY_DETM_PKG.get_tax_date()');
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.default_tax_attributes_for_po',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.default_tax_attributes_for_po.END',
               'ZX_DEFAULT_AUTOMATION_PKG.default_tax_attributes_for_po(-)');
      END IF;
      RETURN;
    END IF;


    BEGIN
      SELECT tax_classification_code, effective_from, effective_to
        INTO l_tax_classification_code, l_effective_from, l_effective_to
        FROM zx_id_tcc_mapping
       WHERE tax_rate_code_id = l_tax_code_id
         AND source = 'AP';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected,
                 'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.default_tax_attributes_for_po',
                 'Invalid Tax Code Id: No Record Found');
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;     -- bug 4893261;
    END;

    IF l_effective_from <= l_tax_determine_date AND
       (l_effective_to >= l_tax_determine_date OR l_effective_to IS NULL)
    THEN

      ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.input_tax_classification_code(
                                 p_trx_line_index) := l_tax_classification_code;

    ELSE
      IF (g_level_statement >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_statement,
               'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.default_tax_attributes_for_po',
               'No Valid Tax Classification Code Found for Tax Code Id: ' ||
                l_tax_code_id);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;     -- bug 4893261
      RETURN;
    END IF;
  END IF;

  -- get the country code
  --
  l_country_code := SUBSTR(
    ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.global_attribute_category(
                                                         p_trx_line_index), 4, 2);

  -- get if inventory is installed
  --
  l_fnd_return := FND_INSTALLATION.get(401, 401, l_inv_flag, l_inv_industry);

  IF NOT l_fnd_return THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.default_tax_attributes_for_po',
             'Got error after calling FND_INSTALLATION.get');
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.default_tax_attributes_for_po.END',
             'ZX_DEFAULT_AUTOMATION_PKG.default_tax_attributes_for_po(-)');
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;     -- bug 4893261
    RETURN;
  END IF;

  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.global_attribute1(
                                             p_trx_line_index) IS NOT NULL THEN

    IF g_level_statement >= G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.default_tax_attributes_for_po',
             'Default Product Fisiclassification Code or Product Category');
    END IF;

    IF l_country_code = 'BR' THEN

      IF l_inv_flag = 'I' THEN

        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_fisc_classification(
              p_trx_line_index) :=
                ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.global_attribute1(
                                                               p_trx_line_index);
      ELSE
       IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_category(p_trx_line_index) IS NULL THEN
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_category(
             p_trx_line_index) := 'STATISTICAL CODE' || '.' ||
                   ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.global_attribute1(
                                                                p_trx_line_index);
       END IF;
      END IF;
    ELSIF l_country_code = 'HU' OR l_country_code = 'PL' THEN

      BEGIN
        SELECT global_attribute1
          INTO l_temp_attribute1
          FROM mtl_system_items_b
         WHERE inventory_item_id =
               ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_id(p_trx_line_index)
           AND organization_id =
               ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_org_id(p_trx_line_index);

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.default_tax_attributes_for_po',
                   'Not MTL Item Found');
          END IF;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;     -- bug 4893261
      END;

      IF l_inv_flag = 'I' THEN

          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_fisc_classification(
                                         p_trx_line_index) := l_temp_attribute1;
      ELSE
        IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_category(p_trx_line_index) IS NULL THEN
          ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_category(
            p_trx_line_index) := 'STATISTICAL CODE' || '.' || l_temp_attribute1;
        END IF;
      END IF;
    END IF;
  END IF;

  IF ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_id(
                                               p_trx_line_index) IS NOT NULL AND
     ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_org_id(
                                               p_trx_line_index) IS NOT NULL
  THEN

    IF ( g_level_statement >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(g_level_statement,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.default_tax_attributes_for_po',
             'Default Transaction Business _category for Brazil');
    END IF;

    IF l_country_code = 'BR' THEN

      BEGIN
        SELECT ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.tax_event_class_code( p_trx_line_index)
                || '.' || global_attribute2
          INTO ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_business_category(p_trx_line_index)
          FROM mtl_system_items_b
         WHERE inventory_item_id =
               ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_id(p_trx_line_index)
           AND organization_id =
               ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.product_org_id(p_trx_line_index);

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.default_tax_attributes_for_po',
                   'Not MTL Item Found');
          END IF;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;     -- bug 4893261
      END;
    END IF;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN

    FND_LOG.STRING(g_level_procedure,
           'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.default_tax_attributes_for_po.END',
           'ZX_DEFAULT_AUTOMATION_PKG.default_tax_attributes_for_po(-)'||x_return_status);
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
    l_context_info_rec.APPLICATION_ID   := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.application_id(p_trx_line_index);
    l_context_info_rec.ENTITY_CODE      := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.entity_code(p_trx_line_index);
    l_context_info_rec.EVENT_CLASS_CODE := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.event_class_code(p_trx_line_index);
    l_context_info_rec.TRX_ID           := ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.trx_id(p_trx_line_index);
    IF ZX_API_PUB.G_DATA_TRANSFER_MODE IS NULL
      OR l_context_info_rec.TRX_ID IS NULL
    THEN
      FND_MSG_PUB.Add;
    ELSE
      ZX_API_PUB.add_msg( p_context_info_rec =>l_context_info_rec );
    END IF;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.default_tax_attributes_for_po',
              sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
             'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.default_tax_attributes_for_po.END',
             'ZX_DEFAULT_AUTOMATION_PKG.default_tax_attributes_for_po(-)');
    END IF;

END default_tax_attributes_for_po;

/* This procedure is used to get the default country code  based on
   tax method for input parameter internal_org_id/legal_entity_id
   This procedure is called from Additional Tax Attributes UI when Taxation Country is null
*/
PROCEDURE GET_DEFAULT_COUNTRY_CODE
(
  p_tax_method_code      IN            VARCHAR2,
  p_internal_org_id      IN            NUMBER,
  p_legal_entity_id      IN            NUMBER,
  x_country_code            OUT NOCOPY VARCHAR2,
  x_return_status           OUT NOCOPY VARCHAR2
)
IS
 l_api_name           CONSTANT VARCHAR2(30) := 'GET_DEFAULT_COUNTRY_CODE';
 l_country_code       XLE_FIRSTPARTY_INFORMATION_V.COUNTRY%TYPE;

BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
        ' p_tax_method_code    := ' || p_tax_method_code ||
        ' p_internal_org_id    := ' || to_char(p_internal_org_id) ||
        ' p_legal_entity_id    := ' || to_char(p_legal_entity_id) );
   END IF;

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

      IF p_tax_method_code = 'LTE' THEN

        BEGIN
          SELECT decode(global_attribute13,'ARGENTINA', 'AR',
                                           'COLOMBIA',  'CO',
                                           'BRAZIL',    'BR',
                        NULL) INTO l_country_code FROM ar_system_parameters_all
           WHERE  NVL(org_id, -99) = NVL(p_internal_org_id, -99)
                  AND global_attribute_category like 'JL%';

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.GET_DEFAULT_COUNTRY_CODE',
                     'No COUNTRY_CODE Found For LTE.');
            END IF;
          WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            IF (g_level_unexpected >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.GET_DEFAULT_COUNTRY_CODE',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
            END IF;
        END;

      ELSE

        BEGIN
          SELECT le.country INTO l_country_code
            FROM XLE_FIRSTPARTY_INFORMATION_V le
           WHERE le.legal_entity_id = p_legal_entity_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            IF (g_level_statement >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.GET_DEFAULT_COUNTRY_CODE',
                     'No COUNTRY_CODE Found for EBTax. ');
            END IF;
          WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            IF (g_level_unexpected >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_DEFAULT_AUTOMATION_PKG.GET_DEFAULT_COUNTRY_CODE',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
            END IF;
        END;

     END IF; -- tax_method_code

     x_country_code:= l_country_code;

END GET_DEFAULT_COUNTRY_CODE;

END ZX_DEFAULT_AUTOMATION_PKG;

/
