--------------------------------------------------------
--  DDL for Package Body ZX_TCM_EXT_SERVICES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TCM_EXT_SERVICES_PUB" AS
 /* $Header: zxpservb.pls 120.32.12010000.6 2009/10/23 07:16:23 ssanka ship $ */

  -- Logging Infra
  G_CURRENT_RUNTIME_LEVEL      NUMBER;
  G_LEVEL_UNEXPECTED           CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR                CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT                CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE            CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(40) := 'ZX.PLSQL.ZX_TCM_EXT_SERVICES_PUB.';

PROCEDURE get_fc_country_def_cache_info (
  p_country_code        IN          fnd_territories.territory_code%TYPE,
  p_classification_type IN          varchar2,
  x_classification_rec  OUT NOCOPY  ZX_GLOBAL_STRUCTURES_PKG.fc_country_def_val_rec_type,
  x_found_in_cache      OUT NOCOPY  BOOLEAN,
  x_return_status       OUT NOCOPY  VARCHAR2,
  x_error_buffer        OUT NOCOPY  VARCHAR2);

PROCEDURE  set_fc_country_def_cache_info(
  p_country_code        IN          fnd_territories.territory_code%TYPE,
  p_classification_type IN          varchar2,
  p_classification_code IN          varchar2);

FUNCTION is_territory_code_valid(p_country_code IN VARCHAR2)
RETURN  BOOLEAN;

Procedure GET_DEFAULT_STATUS_RATES(
            p_tax_regime_code        IN  ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_tax                    IN  ZX_TAXES_B.TAX%TYPE,
            p_date                   IN  DATE,
            p_tax_status_code        OUT NOCOPY ZX_STATUS_B.TAX_STATUS_CODE%TYPE,
            p_tax_rate_code          OUT NOCOPY ZX_RATES_B.TAX_RATE_CODE%TYPE,
            P_RETURN_STATUS          OUT NOCOPY VARCHAR2) IS

/*

A Procedure to return Default Status code and Rate code for an effective date
given a Tax Regime Code and Tax

*/

  -- Logging Infra:
  l_procedure_name CONSTANT VARCHAR2(30) := 'get_default_status_rates';
  l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

-- get default status code
  CURSOR c_default_status IS
  SELECT tax_status_code
  FROM   zx_sco_status
  WHERE  tax_regime_code     = p_tax_regime_code
  AND    tax                 = p_tax
  AND    default_status_flag  = 'Y'
  AND    p_date >= default_flg_effective_from
  AND   (p_date <= default_flg_effective_to OR default_flg_effective_to IS NULL);


-- get default rate code
  CURSOR c_default_rate(c_status_code zx_status_b.tax_status_code%TYPE) IS
  SELECT tax_rate_code
  FROM   zx_sco_rates
  WHERE  tax_regime_code     = p_tax_regime_code
  AND    tax                 = p_tax
  AND    tax_status_code     = c_status_code
  AND    active_flag          = 'Y'
  AND    default_rate_flag    = 'Y'
  AND    p_date >= default_flg_effective_from
  AND    (p_date <= default_flg_effective_to OR default_flg_effective_to IS NULL);



BEGIN
  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := l_procedure_name||'(+)';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;


  --
  -- Initialize Return Status and Error Buffer
  --

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Logging Infra: YK: 3/10: Break point
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: input params: p_tax_regime_code=' || p_tax_regime_code ||
                       ', p_tax=' || p_tax ||
                       ', p_date=' || p_date;

          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
  END IF;

  IF p_tax_regime_code is NULL OR p_tax is NULL THEN
      p_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
      --p_error_buffer:='One or more of the parameters are not entered';
      --fnd_message.set_name('ZX','ZX_PARAM_NOT_SET');
      -- Logging Infra: YK: 3/10:
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
       l_log_msg := 'E: wrong input params: p_tax_regime_code is null or p_tax is null';
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      l_log_msg);
     END IF;
     RETURN;
     --RAISE FND_API.G_EXC_ERROR;
  ELSE
      OPEN c_default_status;
      FETCH c_default_status INTO p_tax_status_code;

      -- Logging Infra: YK: 3/10: Break point
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: CUR: c_default_status: fetched: p_tax_status_code=' || p_tax_status_code;

          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
      END IF;

      IF c_default_status%found THEN
         OPEN c_default_rate(p_tax_status_code);
         FETCH c_default_rate into p_tax_rate_code;

         -- Logging Infra: YK: 3/10: Break point
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'B: CUR: c_default_rate: fetched: p_tax_rate_code=' || p_tax_rate_code;
           FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
         END IF;

         p_return_status := FND_API.G_RET_STS_SUCCESS;
         --p_error_buffer := 'Default Tax Status found';

         IF c_default_rate%FOUND THEN
            --p_return_status := FND_API.G_RET_STS_SUCCESS;
            --p_error_buffer := 'Default Tax Status and Rate found';

            -- Logging Infra: YK: 3/10: Break point
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
              l_log_msg := 'B: CUR: c_default_rate: found';
              FND_LOG.STRING(G_LEVEL_STATEMENT,
                             G_MODULE_NAME || l_procedure_name,
                             l_log_msg);
            END IF;
         ELSE
            -- Logging Infra: YK: 3/10: Break point
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
              l_log_msg := 'B: CUR: c_default_rate: notfound';
              FND_LOG.STRING(G_LEVEL_STATEMENT,
                             G_MODULE_NAME || l_procedure_name,
                             l_log_msg);
            END IF;
         END IF;

         CLOSE c_default_rate;

      ELSIF  c_default_status%notfound THEN
         --p_return_status := FND_API.G_RET_STS_SUCCESS;
         --p_error_buffer := 'No Default values exist for the given Tax Regime Code and Tax';
         --fnd_message.set_name('ZX','ZX_DEFAULT_VALUE_NOT_EXIST');

         -- Logging Infra: YK: 3/10: Break point
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'B: CUR: c_default_status: notfound';
           FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
         END IF;
         --RAISE FND_API.G_EXC_ERROR;
      END IF;

      CLOSE c_default_status;

  END IF;

  -- Logging Infra: YK: 3/10: Put output value here
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_msg := 'R: p_tax_status_code=' || p_tax_status_code ||
                 ', p_tax_rate_code=' || p_tax_rate_code;
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME || l_procedure_name,
                   l_log_msg);
  END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := l_procedure_name||'(-)';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
  END IF;

EXCEPTION
   WHEN INVALID_CURSOR THEN
        p_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
        FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);
        IF c_default_rate%ISOPEN THEN CLOSE c_default_rate; end if;
        IF c_default_status%ISOPEN THEN CLOSE c_default_status; end if;

        -- Logging Infra: YK: 3/10:
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,SQLCODE || ': ' || SQLERRM);
        END IF;

   WHEN FND_API.G_EXC_ERROR THEN
        p_return_status := FND_API.G_RET_STS_ERROR;
        IF c_default_rate%ISOPEN THEN CLOSE c_default_rate; end if;
        IF c_default_status%ISOPEN THEN CLOSE c_default_status; end if;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,SQLCODE || ': ' || SQLERRM);
        END IF;


   WHEN OTHERS THEN
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
        FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

        IF c_default_rate%ISOPEN THEN CLOSE c_default_rate; end if;
        IF c_default_status%ISOPEN THEN CLOSE c_default_status; end if;

        -- Logging Infra: YK: 3/10:
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,SQLCODE || ': ' || SQLERRM);
        END IF;

END GET_DEFAULT_STATUS_RATES;


Procedure GET_DEFAULT_CLASSIF_CODE(
            p_fiscal_type_code       IN  ZX_FC_TYPES_B.CLASSIFICATION_TYPE_CODE%TYPE,
            p_country_code           IN  FND_TERRITORIES.TERRITORY_CODE%TYPE,
            p_application_id         IN ZX_EVNT_CLS_MAPPINGS.APPLICATION_ID%TYPE,
            p_entity_code            IN ZX_EVNT_CLS_MAPPINGS.ENTITY_CODE%TYPE,
            p_event_class_code       IN ZX_EVNT_CLS_MAPPINGS.EVENT_CLASS_CODE%TYPE,
            p_source_event_class_code       IN ZX_EVNT_CLS_MAPPINGS.EVENT_CLASS_CODE%TYPE,
            p_item_id                IN MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID%TYPE,
            p_org_id                 IN MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID%TYPE,
            p_default_code           OUT NOCOPY VARCHAR2,
            P_RETURN_STATUS          OUT NOCOPY VARCHAR2) IS

/*

A Procedure to return Default values for Fiscal Classifications on to Transactions
given a Country Code

*/

   l_country_code              FND_TERRITORIES.TERRITORY_CODE%TYPE;
   l_intended_use              ZX_FC_COUNTRY_DEFAULTS.INTENDED_USE_DEFAULT%TYPE;
   l_product_category_code     VARCHAR2(240);
   l_tax_event_class_code      ZX_EVNT_CLS_MAPPINGS.TAX_EVENT_CLASS_CODE%TYPE;
   l_owner_table               ZX_FC_TYPES_B.OWNER_TABLE_CODE%TYPE;
   l_owner_id_num              ZX_FC_TYPES_B.OWNER_ID_NUM%TYPE;
   l_category_id               MTL_ITEM_CATEGORIES.CATEGORY_ID%TYPE;
   l_category_code             varchar2(200);
   l_product_type              varchar2(200);
   l_status                    varchar2(1);
   l_db_status                 varchar2(1);
   l_classif_code              ZX_FC_CODES_B.CLASSIFICATION_CODE%TYPE;
   l_classif_code_1            ZX_FC_CODES_B.CLASSIFICATION_CODE%TYPE;
   l_intrcmp_code              zx_evnt_cls_mappings.intrcmp_tx_evnt_cls_code%TYPE;
   l_def_intrcmp_code          ZX_EVNT_CLS_OPTIONS.DEF_INTRCMP_TRX_BIZ_CATEGORY%TYPE;
   l_category_set              ZX_FC_COUNTRY_DEFAULTS.PRIMARY_INVENTORY_CATEGORY_SET%TYPE;

   -- Logging Infra:
   l_procedure_name CONSTANT VARCHAR2(30) := 'get_default_classif_code';
   l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

-- get country defaults
  CURSOR c_country_default IS
  SELECT intended_use_default, product_categ_default, primary_inventory_category_set
  FROM   zx_fc_country_defaults
  WHERE  country_code   = p_country_code;

/*
-- get default Intended Use
  CURSOR c_default_Intended_Use IS
  SELECT intended_use_default
  FROM   zx_fc_country_defaults
  WHERE  country_code   = p_country_code;

-- get default Product Category
  CURSOR c_default_Product_Category IS
  SELECT product_categ_default
  FROM   zx_fc_country_defaults
  WHERE  country_code   = p_country_code;
  */

/* Bug 5102996 no need to issue query against zx_evnt_cls_mappings or
               zx_event_cls_options. These are cached in zx_global_Structures_pkg.g_event_class_rec
-- get default Transaction Business Category
  CURSOR c_trx_biz_cat IS
  SELECT tax_event_class_code, intrcmp_tx_evnt_cls_code
  FROM   zx_evnt_cls_mappings
  WHERE  application_id = p_application_id
  AND    entity_code = p_entity_code
  AND    event_class_code = p_event_class_code;

  CURSOR c_intrcmp_code IS
  SELECT  DEF_INTRCMP_TRX_BIZ_CATEGORY
  FROM  ZX_EVNT_CLS_OPTIONS
  WHERE event_class_code = p_event_class_code
  AND   FIRST_PTY_ORG_ID =  p_org_id;
*/

  -- Get the Model use for Intended Use
   CURSOR c_model_Intended_use IS
   SELECT owner_table_code,owner_id_num
   FROM   zx_fc_types_b
   WHERE  classification_type_code ='INTENDED_USE';

   CURSOR c_item_category IS
   SELECT category_id
   FROM mtl_item_categories
   WHERE category_set_id = l_owner_id_num
   AND organization_id = p_org_id
   AND inventory_item_id = p_item_id;

   CURSOR c_category_code IS
   SELECT REPLACE (mtl.concatenated_segments,flex.concatenated_segment_delimiter,'')
   FROM MTL_CATEGORIES_B_KFV mtl,
        FND_ID_FLEX_STRUCTURES flex,
        MTL_CATEGORY_SETS_B mcs
   WHERE mtl.structure_id = mcs.structure_id
   AND   mcs.category_set_id = l_owner_id_num
   AND flex.ID_FLEX_NUM = mtl.STRUCTURE_ID
   AND flex.APPLICATION_ID = 401
   AND flex.ID_FLEX_CODE = 'MCAT'
   AND mtl.category_id = l_category_id;

 -- Get Default Product Type
   CURSOR c_product_type IS
   SELECT F.LOOKUP_CODE
   FROM FND_LOOKUPS F,
        MTL_SYSTEM_ITEMS_B I
   WHERE  F.LOOKUP_TYPE= 'ZX_PRODUCT_TYPE'
   AND I.INVENTORY_ITEM_ID = p_item_id
   AND I.ORGANIZATION_ID = p_org_id
   AND    F.LOOKUP_CODE =  DECODE (I.CONTRACT_ITEM_TYPE_CODE,
                   'SERVICE','SERVICES',
                   'WARRANTY','SERVICES',
                   'USAGE','SERVICES',
                   'SUBSCRIPTION','GOODS',
                   'GOODS');

-- get default values for User Defined / Document Subtype
  CURSOR c_classification_code (c_classification_type in varchar2) IS
  SELECT classification_code
  FROM   zx_fc_codes_denorm_b
  WHERE  classification_type_code = c_classification_type
  AND country_code   = p_country_code
  AND LANGUAGE = userenv('LANG');

  CURSOR c_delimiter IS
  SELECT delimiter
  FROM   zx_fc_types_b
  WHERE  classification_type_code ='TRX_BUSINESS_CATEGORY';

  l_fc_country_def_val_rec ZX_GLOBAL_STRUCTURES_PKG.fc_country_def_val_rec_type;
  l_found_in_cache  boolean;
  l_tbl_index       binary_integer;
  l_return_status   VARCHAR2(80);
  l_error_buffer    VARCHAR2(200);
  g_delimiter             zx_fc_types_b.delimiter%type;
  l_index           BINARY_INTEGER;

BEGIN
  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := l_procedure_name||'(+)';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;

  -- Logging Infra: YK: 3/10: Break point
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: input params: p_fiscal_type_code=' || p_fiscal_type_code ||
                       ', p_country_code=' || p_country_code ||
                       ', p_application_id=' || p_application_id ||
                       ', p_entity_code=' || p_entity_code ||
                       ', p_event_class_code=' || p_event_class_code ||
                       ', p_item_id=' || p_item_id ||
                       ', p_org_id=' || p_org_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
  END IF;

  --
  -- Initialize Return Status and Error Buffer
  --
  p_default_code:= Null;
  p_return_status := FND_API.G_RET_STS_SUCCESS;
  l_classif_code :=null;

  OPEN c_delimiter;
  FETCH c_delimiter INTO g_delimiter;
  CLOSE c_delimiter;

   IF p_country_code is NULL THEN
        p_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
        --p_error_buffer:='One or more of the parameters are not entered';
        --fnd_message.set_name('ZX','ZX_PARAM_NOT_SET');
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'E: p_country_code is null';
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_procedure_name,
                         l_log_msg);
        END IF;

        RETURN;
        -- RAISE FND_API.G_EXC_ERROR;
   ELSE

       IF NOT is_territory_code_valid(p_country_code) then
            p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            --p_error_buffer := 'Invalid Country Code: '||p_country_code;
            --fnd_message.set_name('ZX','ZX_COUNTRY_CODE_INVALID');
            -- Logging Infra: YK: 3/10: Break point
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
              l_log_msg := 'Invalid Country Code: '||p_country_code;
              FND_LOG.STRING(G_LEVEL_STATEMENT,
                        G_MODULE_NAME || l_procedure_name,
                        l_log_msg);
            END IF;
            RETURN;
       END IF;

   END IF;

   IF p_fiscal_type_code ='INTENDED_USE' then

      -- try to locate in cache first.
      l_found_in_cache := FALSE;
      get_fc_country_def_cache_info (
              p_country_code        => l_country_code,
              p_classification_type => 'INTENDED_USE',
              x_classification_rec  => l_fc_country_def_val_rec,
              x_found_in_cache      => l_found_in_cache,
              x_return_status       => l_return_status,
              x_error_buffer        => l_error_buffer);

     IF l_found_in_cache then
             p_default_code := l_fc_country_def_val_rec.fc_default_value;
     ELSE

         IF ZX_GLOBAL_STRUCTURES_PKG.g_intended_use_owner_tbl_info.owner_table_code is not NULL then
         -- model intended use found in cache

                    l_owner_table :=  ZX_GLOBAL_STRUCTURES_PKG.g_intended_use_owner_tbl_info.owner_table_code;
                    l_owner_id_num := ZX_GLOBAL_STRUCTURES_PKG.g_intended_use_owner_tbl_info.owner_id_num;

         ELSE
            OPEN c_model_intended_use;
            FETCH c_model_intended_use into l_owner_table, l_owner_id_num;

            ZX_GLOBAL_STRUCTURES_PKG.g_intended_use_owner_tbl_info.owner_table_code := l_owner_table ;
            ZX_GLOBAL_STRUCTURES_PKG.g_intended_use_owner_tbl_info.owner_id_num := l_owner_id_num;

            -- Logging Infra: YK: 3/10: Break point
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                l_log_msg := 'B: CUR: c_model_intended_use: fetched: l_owner_table=' || l_owner_table ||
                             ', l_owner_id_num=' || l_owner_id_num;
                FND_LOG.STRING(G_LEVEL_STATEMENT,
                             G_MODULE_NAME || l_procedure_name,
                             l_log_msg);
            END IF;

            IF c_model_intended_use%NOTFOUND then
               p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              --p_error_buffer := 'Seeded Fiscal Classification Type is missing';
              --fnd_message.set_name('ZX','ZX_FC_TYPE_NOT_EXIST');
              CLOSE c_model_intended_use;

              -- Logging Infra: YK: 3/10: Break point
              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                l_log_msg := 'E: CUR: c_model_intended_use: notfound';
                FND_LOG.STRING(G_LEVEL_STATEMENT,
                             G_MODULE_NAME || l_procedure_name,
                             l_log_msg);
              END IF;
              RETURN;
              -- RAISE FND_API.G_EXC_ERROR;
            END IF;

            CLOSE c_model_intended_use;
       END IF; -- model intended use found in cache

       IF l_owner_table = 'ZX_FC_TYPES_B' then

        OPEN c_country_default;
        FETCH c_country_default into l_Intended_Use, l_product_category_code, l_category_set;

        -- Logging Infra: YK: 3/10: Break point
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
           l_log_msg := 'B: CUR: c_country_default: fetched: l_intended_use=' || l_intended_use;
           FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_procedure_name,
                          l_log_msg);
        END IF;

        p_default_code := l_Intended_Use;

        set_fc_country_def_cache_info(
                  p_country_code        =>  l_country_code,
                  p_classification_type =>  'INTENDED_USE',
                  p_classification_code =>  l_intended_use);

        set_fc_country_def_cache_info(
                  p_country_code        =>  l_country_code,
                  p_classification_type =>  'PRODUCT_CATEGORY',
                  p_classification_code =>  l_product_category_code);

        set_fc_country_def_cache_info(
                  p_country_code        =>  l_country_code,
                  p_classification_type =>  'PRIMARY_CATEGORY_SET',
                  p_classification_code =>  l_category_set);


        CLOSE c_country_default;

        -- Logging Infra: YK: What should be the return status for this condition?
        -- p_return_status?
        -- p_error_buffer?

        -- Logging Infra: YK: 3/10: Break point: Assuming this is successful condition
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'S: p_default_code=' || p_default_code;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_procedure_name,
                         l_log_msg);
        END IF;

       ELSE
         IF l_owner_table is NOT NULL THEN
          OPEN c_item_category;
          FETCH c_item_category into l_category_id;

          -- Logging Infra: YK: 3/10: Break point
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            l_log_msg := 'B: CUR: c_item_category: fetched: l_category_id=' || l_category_id;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                           G_MODULE_NAME || l_procedure_name,
                           l_log_msg);
          END IF;

          IF c_item_category%rowcount>1 THEN
            p_default_code := NULL;
            -- p_return_status := FND_API.G_RET_STS_ERROR;
            -- p_error_buffer := 'Many categories assigned';
            fnd_message.set_name('ZX','ZX_MANY_CATEG_ASSIGNED');
            CLOSE c_item_category;

            -- Logging Infra: YK: 3/10: Break point:
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
              l_log_msg := 'E: CUR: c_item_category: rowcount > 1: category_set_id=' || l_owner_id_num ||
                           ', organization_id=' || p_org_id ||
                           ', inventory_item_id='|| p_item_id;
              FND_LOG.STRING(G_LEVEL_STATEMENT,
                             G_MODULE_NAME || l_procedure_name,
                             l_log_msg);
            END IF;
            RETURN;
            -- RAISE FND_API.G_EXC_ERROR;
          END IF;

          CLOSE c_item_category;

          OPEN c_category_code;
          FETCH c_category_code into l_category_code;

          -- Logging Infra: YK: 3/11: Break point
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            l_log_msg := 'B: CUR: c_category_code: fetched: l_category_code=' || l_category_code;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                           G_MODULE_NAME || l_procedure_name,
                          l_log_msg);
          END IF;

          IF c_category_code%NOTFOUND  THEN
            p_default_code := NULL;
            --p_return_status := FND_API.G_RET_STS_ERROR;
            --p_error_buffer := 'Category Code does not exists';
            fnd_message.set_name('ZX','ZX_ITEM_CAT_NOT_EXIST');
            CLOSE c_category_code;

            -- Logging Infra: YK: 3/10: Break point:
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
              l_log_msg := 'E: CUR: c_category_code: notfound: category_set_id=' || l_owner_id_num ||
                           ', category_id=' || l_category_id;
              FND_LOG.STRING(G_LEVEL_STATEMENT,
                             G_MODULE_NAME || l_procedure_name,
                             l_log_msg);
            END IF;

            RETURN;
            -- RAISE FND_API.G_EXC_ERROR;
          END IF;

          p_default_code := l_category_code;

          -- set the value in cache
          set_fc_country_def_cache_info(
                  p_country_code        =>  l_country_code,
                  p_classification_type =>  'INTENDED_USE',
                  p_classification_code =>  l_category_code);

          CLOSE c_category_code;

          -- YK: 3/11: What if l_category_code is NULL?
         END IF;

       END IF; --owner table
     END IF;  -- found in cache

   ELSIF p_fiscal_type_code ='PRODUCT_CATEGORY' then

        -- try to locate in cache first.
        l_found_in_cache := FALSE;
        get_fc_country_def_cache_info (
              p_country_code        => l_country_code,
              p_classification_type => 'PRODUCT_CATEGORY',
              x_classification_rec  => l_fc_country_def_val_rec,
              x_found_in_cache      => l_found_in_cache,
              x_return_status       => l_return_status,
              x_error_buffer        => l_error_buffer);

     IF l_found_in_cache then
        p_default_code := l_fc_country_def_val_rec.fc_default_value;
     ELSE

       OPEN c_country_default;
       FETCH c_country_default into l_intended_use, l_product_category_code, l_category_set;

       -- Logging Infra: YK: 3/11: Break point
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         l_log_msg := 'B: CUR: c_country_default: fetched: l_product_category_code=' || l_product_category_code;
         FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      l_log_msg);
       END IF;

       -- YK: 3/11: What if c_country_default returned notfound?

       p_default_code := l_product_category_code;

        -- set the value in cache

        set_fc_country_def_cache_info(
                  p_country_code        =>  l_country_code,
                  p_classification_type =>  'INTENDED_USE',
                  p_classification_code =>  l_intended_use);

        set_fc_country_def_cache_info(
                  p_country_code        =>  l_country_code,
                  p_classification_type =>  'PRODUCT_CATEGORY',
                  p_classification_code =>  l_product_category_code);

        set_fc_country_def_cache_info(
                  p_country_code        =>  l_country_code,
                  p_classification_type =>  'PRIMARY_CATEGORY_SET',
                  p_classification_code =>  l_category_set);

       CLOSE c_country_default;
     END IF; -- found in cache

   ELSIF p_fiscal_type_code ='PRODUCT_TYPE' then

     -- try to locate in cache first.
     l_index := dbms_utility.get_hash_value(
                    p_org_id||p_item_id||p_fiscal_type_code,
                    1,
                    8192);

     IF ZX_GLOBAL_STRUCTURES_PKG.ITEM_PRODUCT_TYPE_VAL_TBL.EXISTS(l_index)
        AND ZX_GLOBAL_STRUCTURES_PKG.ITEM_PRODUCT_TYPE_VAL_TBL(l_index).ORG_ID = p_org_id then
        p_default_code := ZX_GLOBAL_STRUCTURES_PKG.ITEM_PRODUCT_TYPE_VAL_TBL(l_index).FC_DEFAULT_VALUE;
     ELSE
        OPEN c_product_type;
        FETCH c_product_type into l_product_type;

        -- Logging Infra: Break point
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: CUR: c_product_type: fetched: l_product_type=' || l_product_type;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_procedure_name,
                         l_log_msg);
        END IF;

        p_default_code := l_product_type;

        -- set the value in cache
        ZX_GLOBAL_STRUCTURES_PKG.ITEM_PRODUCT_TYPE_VAL_TBL(l_index).ORG_ID := p_org_id;
        ZX_GLOBAL_STRUCTURES_PKG.ITEM_PRODUCT_TYPE_VAL_TBL(l_index).FC_ITEM_ID := p_item_id;
        ZX_GLOBAL_STRUCTURES_PKG.ITEM_PRODUCT_TYPE_VAL_TBL(l_index).FC_TYPE := p_fiscal_type_code;
        ZX_GLOBAL_STRUCTURES_PKG.ITEM_PRODUCT_TYPE_VAL_TBL(l_index).FC_DEFAULT_VALUE := l_product_type;

        CLOSE c_product_type;

     END IF;  -- found in cache

   ELSIF p_fiscal_type_code ='USER_DEFINED' then

      -- try to locate in cache first.
       l_found_in_cache := FALSE;
       get_fc_country_def_cache_info (
             p_country_code        => l_country_code,
             p_classification_type => 'USER_DEFINED',
             x_classification_rec  => l_fc_country_def_val_rec,
             x_found_in_cache      => l_found_in_cache,
             x_return_status       => l_return_status,
             x_error_buffer        => l_error_buffer);

     IF l_found_in_cache then
        p_default_code := l_fc_country_def_val_rec.fc_default_value;

     ELSE

        OPEN c_classification_code('USER_DEFINED' );
        FETCH c_classification_code into l_classif_code;
	FETCH c_classification_code into l_classif_code_1; --Bug fix 5343842
	/*The second fetch is used to check if the cursor returned more than one row
	  If yes then do not default the classification code */
        IF  c_classification_code%FOUND then
		l_classif_code := NULL;
        END IF;

        -- Logging Infra: Break point
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: CUR: c_user_defined: fetched: l_classif_code=' || l_classif_code;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_procedure_name,
                         l_log_msg);
        END IF;

        IF l_classif_code is not null then
           p_default_code := l_classif_code;

           -- set the value in cache

           set_fc_country_def_cache_info(
                  p_country_code        =>  l_country_code,
                  p_classification_type =>  'USER_DEFINED',
                  p_classification_code =>  l_classif_code);

        end if;

        CLOSE c_classification_code;
     END IF; -- found in cache

   ELSIF p_fiscal_type_code ='DOCUMENT_SUBTYPE' then

       -- try to locate in cache first.
       l_found_in_cache := FALSE;
       get_fc_country_def_cache_info (
             p_country_code        => l_country_code,
             p_classification_type => 'DOCUMENT_SUBYPE',
             x_classification_rec  => l_fc_country_def_val_rec,
             x_found_in_cache      => l_found_in_cache,
             x_return_status       => l_return_status,
             x_error_buffer        => l_error_buffer);

     IF l_found_in_cache then
        p_default_code := l_fc_country_def_val_rec.fc_default_value;

     ELSE

        OPEN c_classification_code('DOCUMENT_SUBTYPE');
        FETCH c_classification_code into l_classif_code;
	FETCH c_classification_code into l_classif_code_1; --Bug fix 5343842
	/*The second fetch is used to check if the cursor returned more than one row
	  If yes then do not default the classification code */
        IF  c_classification_code%FOUND then
		l_classif_code := NULL;
        END IF;



        -- Logging Infra: Break point
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: CUR: c_document_subtype : fetched: l_classif_code =' || l_classif_code;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_procedure_name,
                         l_log_msg);
        END IF;

        IF l_classif_code is not null then
           p_default_code := l_classif_code;

           -- set the value in cache
           set_fc_country_def_cache_info(
                  p_country_code        =>  l_country_code,
                  p_classification_type =>  'DOCUMENT_SUBTYPE',
                  p_classification_code =>  l_classif_code);

        END IF;

        CLOSE c_classification_code;
     END IF;  -- found in cache

   ELSIF p_fiscal_type_code ='TRX_BUSINESS_CATEGORY' then

     l_tax_event_class_code := ZX_GLOBAL_STRUCTURES_PKG.g_event_class_Rec.tax_event_class_code;
     l_intrcmp_code := ZX_GLOBAL_STRUCTURES_PKG.g_event_class_Rec.intrcmp_tx_evnt_cls_code;

     -- Logging Infra: YK: 3/11: Break point
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
       l_log_msg := 'B: CUR: c_trx_biz_cat: fetched: l_tax_event_class_code=' || l_tax_event_class_code;
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      l_log_msg);
     END IF;


      IF substr(p_source_event_class_code,1,5) = 'TRADE' THEN
         p_default_code := l_tax_event_class_code || g_delimiter || 'TRADE_MGT';
         RETURN;
      END IF;

      IF l_intrcmp_code IS NOT NULL THEN
         l_def_intrcmp_code := ZX_GLOBAL_STRUCTURES_PKG.g_event_class_Rec.DEF_INTRCMP_TRX_BIZ_CATEGORY;
         p_default_code := l_def_intrcmp_code;
      ELSE
         p_default_code :=  l_tax_event_class_code;
      END IF;


   END IF; -- p_fiscal_type_code


 -- Logging Infra: YK: 3/11: Put output value here
 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
   l_log_msg := 'R: p_default_code=' || p_default_code;
   FND_LOG.STRING(G_LEVEL_STATEMENT,
                  G_MODULE_NAME || l_procedure_name,
                  l_log_msg);
 END IF;

 -- Logging Infra: YK: 3/11: Procedure level
 IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
   l_log_msg := l_procedure_name||'(-)';
   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
 END IF;

EXCEPTION
   WHEN INVALID_CURSOR THEN
        p_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
        FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

        IF c_country_default%isopen THEN CLOSE c_country_default; END IF;
        IF c_model_Intended_use%isopen THEN CLOSE c_model_Intended_use; END IF;
        IF c_item_category%isopen THEN CLOSE c_item_category; END IF;
        IF c_category_code%isopen THEN CLOSE c_category_code; END IF;

        -- Logging Infra: YK: 3/12:
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,SQLCODE || ': ' || SQLERRM);
        END IF;

   WHEN FND_API.G_EXC_ERROR THEN
        p_return_status := FND_API.G_RET_STS_ERROR;
        IF c_country_default%isopen THEN CLOSE c_country_default; END IF;
        IF c_model_Intended_use%isopen THEN CLOSE c_model_Intended_use; END IF;
        IF c_item_category%isopen THEN CLOSE c_item_category; END IF;
        IF c_category_code%isopen THEN CLOSE c_category_code; END IF;


        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,SQLCODE || ': ' || SQLERRM);
        END IF;


   WHEN OTHERS THEN
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
        FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

        IF c_country_default%isopen THEN CLOSE c_country_default; END IF;
        IF c_model_Intended_use%isopen THEN CLOSE c_model_Intended_use; END IF;
        IF c_item_category%isopen THEN CLOSE c_item_category; END IF;
        IF c_category_code%isopen THEN CLOSE c_category_code; END IF;

        -- Logging Infra: YK: 3/12:
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,SQLCODE || ': ' || SQLERRM);
        END IF;

END GET_DEFAULT_CLASSIF_CODE;


Procedure 	GET_DEFAULT_PRODUCT_CLASSIF(
            p_country_code           IN  FND_TERRITORIES.TERRITORY_CODE%TYPE,
            p_item_id                IN MTL_SYSTEM_ITEMS_B.INVENTORY_ITEM_ID%TYPE,
            p_org_id                 IN MTL_SYSTEM_ITEMS_B.ORGANIZATION_ID%TYPE,
            p_default_code           OUT NOCOPY VARCHAR2,
            P_RETURN_STATUS          OUT NOCOPY VARCHAR2) IS

/*

A Procedure to return Default values for Fiscal Classifications on to Transactions
given a Country Code

*/

   l_country_code FND_TERRITORIES.TERRITORY_CODE%TYPE;
   l_category_set ZX_FC_COUNTRY_DEFAULTS.PRIMARY_INVENTORY_CATEGORY_SET%TYPE;
   l_category_id MTL_ITEM_CATEGORIES.CATEGORY_ID%TYPE;
   l_intended_use              ZX_FC_COUNTRY_DEFAULTS.INTENDED_USE_DEFAULT%TYPE;
   l_product_category_code     VARCHAR2(240);
   l_category_code varchar2(200);

   l_status            varchar2(1);
   l_db_status         varchar2(1);
   L_TBL_INDEX         binary_integer;

   -- Logging Infra:
   l_procedure_name CONSTANT VARCHAR2(30) := 'get_default_product_classif';
   l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

 -- Get default Product Fiscal Classification

  CURSOR c_country_default IS
  SELECT intended_use_default, product_categ_default, primary_inventory_category_set
  FROM   zx_fc_country_defaults
  WHERE  country_code   = p_country_code;

   CURSOR c_item_category IS
   SELECT category_id
   FROM mtl_item_categories
   WHERE category_set_id = l_category_set
   AND organization_id = p_org_id
   AND inventory_item_id = p_item_id;

   CURSOR c_default_category IS
   SELECT default_category_id
   FROM mtl_category_sets_b
   WHERE category_set_id = l_category_set;

   CURSOR c_category_code IS
   SELECT REPLACE (mtl.concatenated_segments,flex.concatenated_segment_delimiter,'')
   FROM MTL_CATEGORIES_B_KFV mtl,
        FND_ID_FLEX_STRUCTURES flex,
        MTL_CATEGORY_SETS_B mcs
   WHERE mtl.structure_id = mcs.structure_id
   AND   mcs.category_set_id = l_category_set
   AND flex.ID_FLEX_NUM = mtl.STRUCTURE_ID
   AND flex.APPLICATION_ID = 401
   AND flex.ID_FLEX_CODE = 'MCAT'
   AND mtl.category_id = l_category_id;




BEGIN
  -- Logging Infra: Setting up runtime level
  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := l_procedure_name||'(+)';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;

  -- Logging Infra: YK: 3/12: Break point
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: input params: p_country_code=' || p_country_code ||
                       ', p_item_id =' || p_item_id  ||
                       ', p_org_id=' || p_org_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_procedure_name,
                         l_log_msg);
  END IF;

  --
  -- Initialize Return Status and Error Buffer
  --
  p_default_code:= Null;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

 IF p_country_code is NULL THEN
      p_return_status:=FND_API.G_RET_STS_UNEXP_ERROR;
      --p_error_buffer:='One or more of the parameters are not entered';
      --fnd_message.set_name('ZX','ZX_PARAM_NOT_SET');

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'E: p_country_code is null';
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_procedure_name,
                         l_log_msg);
      END IF;
      RETURN;
      --RAISE FND_API.G_EXC_ERROR;
 ELSE

     IF NOT is_territory_code_valid(p_country_code) then
          p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          --p_error_buffer := 'Invalid Country Code: '||p_country_code;
          --fnd_message.set_name('ZX','ZX_COUNTRY_CODE_INVALID');
          -- Logging Infra: YK: 3/10: Break point
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            l_log_msg := 'Invalid Country Code: '||p_country_code;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || l_procedure_name,
                      l_log_msg);
          END IF;
          RETURN;
     END IF;
     OPEN c_country_default;
     FETCH c_country_default into l_intended_use, l_product_category_code,l_category_set;

     -- Logging Infra: YK: 3/12: Break point
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: CUR: c_country_default: fetched: l_category_set=' || l_category_set;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_procedure_name,
                         l_log_msg);
      END IF;

     IF c_country_default%NOTFOUND then
      -- p_return_status := FND_API.G_RET_STS_ERROR;
      --p_error_buffer := 'No defaults have been defined for the country';
      fnd_message.set_name('ZX','ZX_COUNTRY_DEFFAULTS_NOT_EXIST');
      CLOSE c_country_default;

      -- Logging Infra: YK: 3/12: Break point
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: CUR: c_country_default: notfound: country_code=' || p_country_code;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_procedure_name,
                         l_log_msg);
      END IF;
      return;
      -- RAISE FND_API.G_EXC_ERROR;

     ELSE
        -- data found. Store in cache.

        set_fc_country_def_cache_info(
                  p_country_code        =>  l_country_code,
                  p_classification_type =>  'INTENDED_USE',
                  p_classification_code =>  l_intended_use);

        set_fc_country_def_cache_info(
                  p_country_code        =>  l_country_code,
                  p_classification_type =>  'PRODUCT_CATEGORY',
                  p_classification_code =>  l_product_category_code);

        set_fc_country_def_cache_info(
                  p_country_code        =>  l_country_code,
                  p_classification_type =>  'PRIMARY_CATEGORY_SET',
                  p_classification_code =>  l_category_set);

     END IF;

     CLOSE c_country_default;

     IF l_category_set is NOT NULL THEN
        OPEN c_item_category;
        FETCH c_item_category into l_category_id;

        -- Logging Infra: YK: 3/12: Break point
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: CUR: c_item_categoryt: fetched: l_category_id=' || l_category_id;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_procedure_name,
                         l_log_msg);
        END IF;

        IF c_item_category%rowcount>1 THEN
          p_default_code := NULL;
          -- p_return_status := FND_API.G_RET_STS_ERROR;
          --p_error_buffer := 'Many categories assigned under same Category Set';
          fnd_message.set_name('ZX','ZX_MANY_CATEG_ASSIGNED');
          CLOSE c_item_category;

          -- Logging Infra: YK: 3/12: Break point:
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            l_log_msg := 'E: CUR: c_item_category: rowcount > 1: category_set_id=' || l_category_set ||
                         ', organization_id=' || p_org_id ||
                         ', inventory_item_id='|| p_item_id;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                           G_MODULE_NAME || l_procedure_name,
                           l_log_msg);
          END IF;

          RETURN;
          --RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF c_item_category%notfound THEN
          CLOSE c_item_category;
          -- Get default value from the Category Set
          OPEN c_default_category;
          FETCH c_default_category into l_category_id;

          -- Logging Infra: YK: 3/12: Break point
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            l_log_msg := 'B: CUR: c_default_category: fetched: l_category_id=' || l_category_id;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                           G_MODULE_NAME || l_procedure_name,
                           l_log_msg);
          END IF;

          IF c_default_category%notfound THEN
            CLOSE c_default_category ;
            p_default_code := NULL;
            -- p_return_status := FND_API.G_RET_STS_ERROR;
            --p_error_buffer := 'No default value could be derived';
            fnd_message.set_name('ZX','ZX_NO_DEFAULT_DERIVED');

            -- Logging Infra: YK: 3/12: Break point:
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
              l_log_msg := 'E: CUR: c_default_category: notfound: category_set_id=' || l_category_set;
              FND_LOG.STRING(G_LEVEL_STATEMENT,
                             G_MODULE_NAME || l_procedure_name,
                             l_log_msg);
            END IF;
            return;
            --RAISE FND_API.G_EXC_ERROR;
          END IF;
          CLOSE c_default_category ;
        END IF;

        CLOSE c_item_category;

        OPEN c_category_code;
        FETCH c_category_code into l_category_code;

        -- Logging Infra: YK: 3/12: Break point
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          l_log_msg := 'B: CUR: c__category_code: fetched: l_category_code=' || l_category_code;
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_procedure_name,
                         l_log_msg);
        END IF;

        IF c_category_code%NOTFOUND  THEN
          p_default_code := NULL;
          --p_return_status := FND_API.G_RET_STS_ERROR;
          --p_error_buffer := 'Classification Category Code does not exists';
          fnd_message.set_name('ZX','ZX_FC_CATEG_NOT_EXIST');

          CLOSE c_category_code;

          -- Logging Infra: YK: 3/12: Break point:
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            l_log_msg := 'E: CUR: c_category_code: notfound: category_set_id=' || l_category_set ||
                         ', category_id=' || l_category_id;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                           G_MODULE_NAME || l_procedure_name,
                           l_log_msg);
          END IF;

          RETURN;
          -- RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_default_code := l_category_code;
        CLOSE c_category_code;

      END IF; -- l_category_set

 END IF;

 -- Logging Infra: YK: 3/12: Put output value here
 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
   l_log_msg := 'R: p_default_code=' || p_default_code;
   FND_LOG.STRING(G_LEVEL_STATEMENT,
                  G_MODULE_NAME || l_procedure_name,
                  l_log_msg);
 END IF;

 -- Logging Infra: YK: 3/12: Procedure level
 IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
   l_log_msg := l_procedure_name||'(-)';
   FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
 END IF;

EXCEPTION
   WHEN INVALID_CURSOR THEN
        p_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
        FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

        IF c_country_default%ISOPEN THEN CLOSE c_country_default; END IF;
        IF c_item_category%ISOPEN THEN CLOSE c_item_category; END IF;
        IF c_default_category%ISOPEN THEN CLOSE c_default_category; END IF;
        IF c_category_code%ISOPEN THEN CLOSE c_category_code; END IF;

        -- Logging Infra: YK: 3/12
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,SQLCODE || ': ' || SQLERRM);
        END IF;

   WHEN FND_API.G_EXC_ERROR THEN
        p_return_status := FND_API.G_RET_STS_ERROR;
        IF c_country_default%ISOPEN THEN CLOSE c_country_default; END IF;
        IF c_item_category%ISOPEN THEN CLOSE c_item_category; END IF;
        IF c_default_category%ISOPEN THEN CLOSE c_default_category; END IF;
        IF c_category_code%ISOPEN THEN CLOSE c_category_code; END IF;


        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,SQLCODE || ': ' || SQLERRM);
        END IF;


    WHEN OTHERS THEN
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
        FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

        IF c_country_default%ISOPEN THEN CLOSE c_country_default; END IF;
        IF c_item_category%ISOPEN THEN CLOSE c_item_category; END IF;
        IF c_default_category%ISOPEN THEN CLOSE c_default_category; END IF;
        IF c_category_code%ISOPEN THEN CLOSE c_category_code; END IF;

        -- Logging Infra: YK: 3/12
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,SQLCODE || ': ' || SQLERRM);
        END IF;

END GET_DEFAULT_PRODUCT_CLASSIF;


/*==============================================================================+
 |  Function:     ZX_GET_PROD_CATEG                                                                      |
 |  Description:  This function returns passed product fc if inventory is installed            |
 |                If not , then return the passed product category                                        |
 |                Classification migration                                                                              |
 +=============================================================================*/

FUNCTION ZX_GET_PROD_CATEG (p_product_category IN OUT  NOCOPY VARCHAR2,
                   p_product_fc IN OUT  NOCOPY VARCHAR2,
                   p_country_code IN  VARCHAR2) RETURN VARCHAR2 IS

 Cursor c_prod_category is
 Select product_categ_default
 From ZX_FC_COUNTRY_DEFAULTS
 Where country_code = p_country_code;

 l_product_categ_default zx_fc_country_defaults.product_categ_default%TYPE;
BEGIN

     arp_util_tax.debug(' ZX_GET_PROD_CATEG .. (+) ' );

     If IS_INV_INSTALLED then

        return(p_product_fc);
     Else
         open c_prod_category;
         fetch c_prod_category into l_product_categ_default;
         if c_prod_category%notfound then
            close c_prod_category;
            return(null);
         else
           close c_prod_category;
           return(l_product_categ_default);
         end if;
     End if;

   arp_util_tax.debug(' ZX_GET_PROD_CATEG .. (-) ' );

END ZX_GET_PROD_CATEG;

/*===========================================================================+
|  Function:     IS_INV_INSTALLED                                            |
|  Description:  This function returns true if inventory is installed        |
|                This API is again used by other procedures in Fiscal        |
|                Classification migration 				     |
|                   							     |
|    								             |
|    								             |
|    								             |
|  ARGUMENTS  : 							     |
|                                                                            |
|                                                                            |
|  NOTES                                                                     |
|    								             |
|                                                                            |
|                                                                            |
|  History                                                                   |
|    zmohiudd	Created                                  		     |
|                                                                            |
|    									     |
+===========================================================================*/


FUNCTION IS_INV_INSTALLED RETURN BOOLEAN IS

	l_status 	fnd_product_installations.STATUS%type;
	l_db_status	fnd_product_installations.DB_STATUS%type;


BEGIN

		arp_util_tax.debug(' IS_INV_INSTALLED .. (+) ' );

	       SELECT 	STATUS, DB_STATUS
	       INTO		l_status, l_db_status
	       FROM 	fnd_product_installations
	       WHERE 	APPLICATION_ID = '401';

IF (nvl(l_status,'N') = 'N' or  nvl(l_db_status,'N') = 'N') THEN
		return FALSE;
ELSE
		return TRUE;
END IF;
		arp_util_tax.debug(' IS_INV_INSTALLED .. (-) ' );

END IS_INV_INSTALLED ;

/**************************************************************************
 *                                                                        *
 * Name       : Get_Default_Tax_Reg                                       *
 * Purpose    : Returns the Default Registration Number for a Given Party *
 * Logic      : In case there is tax registration mark as default         *
 *              the function will return the registration number          *
 *              associated to that record. Second case the function will  *
 *              look for the registration row with null regime            *
 *              (migrated records)                                        *
 * Parameters : P_Party_ID ------------ P_Party_Type                      *
 *              Party_Id                Third Party                       *
 *              Party_Site_Id           Third Party Site                  *
 *              Party_ID                Establishments                    *
 *                                                                        *
 *              P_Effective_Date        Default Sysdate                   *
 *                                                                        *
 *                                                                        *
 **************************************************************************/
FUNCTION Get_Default_Tax_Reg
              (P_Party_ID          IN         zx_party_tax_profile.party_id%Type,
               P_Party_Type        IN         zx_party_tax_profile.party_type_code%Type,
               P_Effective_Date    IN         zx_registrations.effective_from%Type,
               x_return_status     OUT NOCOPY VARCHAR2
              )
  RETURN Varchar2
IS
  -- Logging Infra
  l_procedure_name CONSTANT VARCHAR2(30) := 'Get_Default_Tax_Reg';
  l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  l_effective_date zx_registrations.effective_from%Type;
  --p_error_buffer varchar2(200);

  Cursor Default_Reg IS
  Select NVL(reg.registration_number, PTP.rep_registration_number) registration_number
  From   zx_registrations reg
        ,zx_party_tax_profile ptp
  Where  ptp.party_id = p_party_id
  AND    ptp.party_type_code = p_party_type
  AND    ptp.party_tax_profile_id = reg.party_tax_profile_id
  AND    reg.default_registration_flag = 'Y'
  AND    l_effective_date >= effective_from
  AND    (l_effective_date <= effective_to OR effective_to IS NULL);

  Cursor Reporting_Reg IS
  Select REP_REGISTRATION_NUMBER
  From   zx_party_tax_profile ptp
  Where  ptp.party_id = p_party_id
  AND    ptp.party_type_code = p_party_type;

Begin
    -- Logging Infra: Setting up runtime level
    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := l_procedure_name||'(+)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
    END IF;

    -- Logging Infra: Statement level
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Parameters ';
      l_log_msg :=  l_log_msg||'P_Party_Id: '||to_char(p_party_id);
      l_log_msg :=  l_log_msg||'P_Party_Type: '||p_party_type;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;
    -- Logging Infra: Statement level

  -- Initialize Return Status and Error Buffer
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Set initial value for effective date in case it comes null
  IF p_effective_date is null Then
     l_Effective_Date:= sysdate;
  Else
     l_Effective_Date:= p_effective_date;
  End if;
  --
  -- Always Party_ID and Party_Type parameters cannot be NULL
  --
  IF P_Party_Id IS NULL OR P_Party_Type IS NULL THEN

     -- Logging Infra: Statement level
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'Parameter P_Party_ID and/or Party_Type are null ';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;
     -- Logging Infra: Statement level

     --x_return_status := FND_API.G_RET_STS_ERROR;
     --return (NULL);
     fnd_message.set_name('ZX','ZX_PTP_ID_NOT_EXIST');
     RAISE FND_API.G_EXC_ERROR;

  ELSE
   -- Try Default Registration First
    For Regis IN Default_Reg Loop
        Return (Regis.registration_number);
    END LOOP;

    -- Checking at PTP level
    For Regis IN Reporting_Reg Loop
        Return (Regis.rep_registration_number);
    END LOOP;
  END IF;

  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := l_procedure_name||'(-)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.END', l_log_msg);
  END IF;
  return(null);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
   /*
       --Return(Null);
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
       FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

       -- Logging Infra: Statement level
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'NO DATA FOUND EXCEP - Error Message: '||SQLERRM;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;
       -- Logging Infra: Statement level
 */
   NULL;
   WHEN INVALID_CURSOR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
      FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Logging Infra: Statement level
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'NO DATA FOUND EXCEP - Error Message: '||SQLERRM;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
      FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);
       -- Logging Infra: Statement level
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Error Message: '||SQLERRM;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;
       -- Logging Infra: Statement level

End Get_Default_Tax_Reg;



FUNCTION get_le_from_tax_registration
       (
          x_return_status     OUT NOCOPY VARCHAR2,
          p_registration_num  IN         ZX_REGISTRATIONS.Registration_Number%type,
          p_effective_date    IN         ZX_REGISTRATIONS.effective_from%type,
          p_country           IN         ZX_PARTY_TAX_PROFILE.Country_code%type
       ) RETURN Number IS
  l_legal_entity_id NUMBER;
BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  IF p_registration_num IS NOT NULL THEN
    SELECT distinct xle.legal_entity_id
    INTO   l_legal_entity_id
    from  zx_registrations tr, zx_party_tax_profile ptp, xle_etb_profiles xle
    where tr.registration_number = p_registration_num
    and  tr.party_tax_profile_id = ptp.party_tax_profile_id
    and  ptp.party_type_code = 'LEGAL_ESTABLISHMENT'
    and ptp.party_id = xle.party_id;
  ELSE
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --FND_MESSAGE.Set_Name ('ZX','ZX_REG_NUM_MANDATORY');
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,
                      G_MODULE_NAME || 'get_le_from_tax_registration',
                      'Registration Number is mandatory but it is null.');
      END IF;
  END IF;
  return l_legal_entity_id;
EXCEPTION WHEN NO_DATA_FOUND THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  FND_MESSAGE.Set_Name ('ZX','ZX_REG_LE_NOT_FOUND');
  --
WHEN TOO_MANY_ROWS THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  FND_MESSAGE.Set_Name ('ZX','ZX_REG_MANY_LEGAL_ENTITY');
  --
END get_le_from_tax_registration;

PROCEDURE get_fc_country_def_cache_info (
  p_country_code        IN          fnd_territories.territory_code%TYPE,
  p_classification_type IN          varchar2,
  x_classification_rec  OUT NOCOPY  ZX_GLOBAL_STRUCTURES_PKG.fc_country_def_val_rec_type,
  x_found_in_cache      OUT NOCOPY  BOOLEAN,
  x_return_status       OUT NOCOPY  VARCHAR2,
  x_error_buffer        OUT NOCOPY  VARCHAR2) is

  l_index              BINARY_INTEGER;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  x_found_in_cache := FALSE;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement, 'ZX.PLSQL.ZX_TCM_EXT_SERVICES_PUB.get_fc_country_def_cache_info.BEGIN',
                  'ZX_TCM_EXT_SERVICES_PUB.get_fc_country_def_cache_info(+)');
  END IF;


   l_index :=   dbms_utility.get_hash_value(
                p_country_code||p_classification_type,
                1,
                8192);
  --
  -- first check if the status info is available from the cache
  --

  IF ZX_GLOBAL_STRUCTURES_PKG.FC_COUNTRY_DEF_VAL_TBL.EXISTS(l_index)
  THEN
    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.LSQL.ZX_TCM_EXT_SERVICES_PUB.get_fc_country_def_cache_info',
                    'Default Classification type '||p_classification_type||
                    ' for country code '||p_country_code||' from cache, at index = ' || to_char(l_index));
    END IF;
    x_found_in_cache := TRUE;
    x_classification_rec := ZX_GLOBAL_STRUCTURES_PKG.FC_COUNTRY_DEF_VAL_TBL(l_index);

  ELSE
      IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.LSQL.ZX_TCM_EXT_SERVICES_PUB.get_fc_country_def_cache_info',
                    'Default Classification type '||p_classification_type||
                    ' for country code '||p_country_code||' not found in cache ');
      END IF;

  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement, 'ZX.PLSQL.ZX_TCM_EXT_SERVICES_PUB.get_fc_country_def_cache_info.BEGIN',
                  'ZX_TCM_EXT_SERVICES_PUB.get_fc_country_def_cache_info(-)');
  END IF;

END get_fc_country_def_cache_info;

PROCEDURE  set_fc_country_def_cache_info(
  p_country_code        IN          fnd_territories.territory_code%TYPE,
  p_classification_type IN          varchar2,
  p_classification_code IN          varchar2)
is
  l_tbl_index binary_integer;
BEGIN

        -- set the value in cache
        l_tbl_index := dbms_utility.get_hash_value(
                p_country_code||p_classification_type,
                1,
                8192);

        ZX_GLOBAL_STRUCTURES_PKG.FC_COUNTRY_DEF_VAL_TBL(l_tbl_index).country_code := p_country_code;
        ZX_GLOBAL_STRUCTURES_PKG.FC_COUNTRY_DEF_VAL_TBL(l_tbl_index).fc_type := p_classification_type;
        ZX_GLOBAL_STRUCTURES_PKG.FC_COUNTRY_DEF_VAL_TBL(l_tbl_index).fc_default_value := p_classification_code;

END set_fc_country_def_cache_info;

FUNCTION is_territory_code_valid(p_country_code IN VARCHAR2)
RETURN  BOOLEAN is
  l_country_index  binary_integer;
  l_territory_code fnd_territories.territory_code%type;
BEGIN
   l_country_index := dbms_utility.get_hash_value(P_COUNTRY_CODE, 1, 8192);
   IF ZX_GLOBAL_STRUCTURES_PKG.G_TERRITORY_TBL.exists(l_country_index) then
         RETURN TRUE;
   ELSE
     BEGIN
      select TERRITORY_CODE into l_territory_code
      FROM   FND_TERRITORIES
      WHERE  TERRITORY_CODE = p_country_code;

      ZX_GLOBAL_STRUCTURES_PKG.G_TERRITORY_TBL(l_country_index) := l_territory_code;
      return TRUE;

     EXCEPTION
        WHEN NO_DATA_FOUND then
            return FALSE;
     END;
   END IF;
END is_territory_code_valid;

END ZX_TCM_EXT_SERVICES_PUB;

/
