--------------------------------------------------------
--  DDL for Package Body ZX_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_RULES_PKG" as
/* $Header: zxdrulesb.pls 120.15.12010000.2 2008/12/01 11:29:04 ssanka ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TAX_RULE_ID in NUMBER,
  X_TAX_RULE_CODE in VARCHAR2,
  X_TAX in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_SERVICE_TYPE_CODE in VARCHAR2,
  X_RECOVERY_TYPE_CODE in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_System_Default_Flag in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_Record_Type_Code in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_TAX_RULE_NAME in VARCHAR2,
  X_TAX_RULE_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_Enabled_Flag in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_OWNER_ID in NUMBER,
  X_DET_FACTOR_TEMPL_CODE in VARCHAR2,
  X_EVENT_CLASS_MAPPING_ID in NUMBER,
  X_TAX_EVENT_CLASS_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
    X_DETERMINING_FACTOR_CQ_CODE               IN VARCHAR2,
	  X_GEOGRAPHY_TYPE                           IN VARCHAR2,
	  X_GEOGRAPHY_ID                             IN NUMBER,
	  X_TAX_LAW_REF_CODE                         IN VARCHAR2,
	  X_TAX_LAW_REF_DESC                         IN VARCHAR2,
	  X_LAST_UPDATE_MODE_FLAG                    IN VARCHAR2,
  X_NEVER_BEEN_ENABLED_FLAG                  IN VARCHAR2
  ) is
  cursor C is select ROWID from ZX_RULES_B
    where TAX_RULE_ID = X_TAX_RULE_ID;

  l_tax_id      NUMBER;

begin

  -- Bug 5501831 - If no tax exists then Update the GCO Tax
  --update zx_taxes_b entity for the flags, as per the latest UE changes
  IF (X_SERVICE_TYPE_CODE = 'DET_PLACE_OF_SUPPLY') THEN

    UPDATE ZX_TAXES_B
	    SET PLACE_OF_SUPPLY_RULE_FLAG = 'Y'
	    WHERE
	    TAX_REGIME_CODE = X_TAX_REGIME_CODE AND
	    TAX = X_TAX AND
	    CONTENT_OWNER_ID = X_CONTENT_OWNER_ID;

    IF (SQL%NOTFOUND) THEN
        UPDATE ZX_TAXES_B
	    SET PLACE_OF_SUPPLY_RULE_FLAG = 'Y'
	    WHERE
	    TAX_REGIME_CODE = X_TAX_REGIME_CODE AND
	    TAX = X_TAX AND
	    CONTENT_OWNER_ID = -99;
    END IF;

  ELSIF (X_SERVICE_TYPE_CODE = 'DET_TAX_REGISTRATION') THEN

    UPDATE ZX_TAXES_B
	    SET REGISTRATION_TYPE_RULE_FLAG = 'Y'
	    WHERE
	    TAX_REGIME_CODE = X_TAX_REGIME_CODE AND
	    TAX = X_TAX AND
	    CONTENT_OWNER_ID = X_CONTENT_OWNER_ID;

    IF (SQL%NOTFOUND) THEN
        UPDATE ZX_TAXES_B
	    SET REGISTRATION_TYPE_RULE_FLAG = 'Y'
	    WHERE
	    TAX_REGIME_CODE = X_TAX_REGIME_CODE AND
	    TAX = X_TAX AND
	    CONTENT_OWNER_ID = -99;
    END IF;

  ELSIF(X_SERVICE_TYPE_CODE = 'CALCULATE_TAX_AMOUNTS') THEN

    UPDATE ZX_TAXES_B
	    SET TAX_CALC_RULE_FLAG = 'Y'
	    WHERE
	    TAX_REGIME_CODE = X_TAX_REGIME_CODE AND
	    TAX = X_TAX AND
	    CONTENT_OWNER_ID = X_CONTENT_OWNER_ID;

    IF (SQL%NOTFOUND) THEN
        UPDATE ZX_TAXES_B
	    SET TAX_CALC_RULE_FLAG = 'Y'
	    WHERE
	    TAX_REGIME_CODE = X_TAX_REGIME_CODE AND
	    TAX = X_TAX AND
	    CONTENT_OWNER_ID = -99;
    END IF;

  ELSIF (X_SERVICE_TYPE_CODE = 'DET_TAXABLE_BASIS') THEN

    UPDATE ZX_TAXES_B
	    SET TAXABLE_BASIS_RULE_FLAG = 'Y'
	    WHERE
	    TAX_REGIME_CODE = X_TAX_REGIME_CODE AND
	    TAX = X_TAX AND
	    CONTENT_OWNER_ID = X_CONTENT_OWNER_ID;

    IF (SQL%NOTFOUND) THEN
        UPDATE ZX_TAXES_B
	    SET TAXABLE_BASIS_RULE_FLAG = 'Y'
	    WHERE
	    TAX_REGIME_CODE = X_TAX_REGIME_CODE AND
	    TAX = X_TAX AND
	    CONTENT_OWNER_ID = -99;
    END IF;

  ELSIF (X_SERVICE_TYPE_CODE = 'DET_TAX_RATE') THEN

    UPDATE ZX_TAXES_B
	    SET TAX_RATE_RULE_FLAG = 'Y'
	    WHERE
	    TAX_REGIME_CODE = X_TAX_REGIME_CODE AND
	    TAX = X_TAX AND
	    CONTENT_OWNER_ID = X_CONTENT_OWNER_ID;

    IF (SQL%NOTFOUND) THEN
        UPDATE ZX_TAXES_B
	    SET TAX_RATE_RULE_FLAG = 'Y'
	    WHERE
	    TAX_REGIME_CODE = X_TAX_REGIME_CODE AND
	    TAX = X_TAX AND
	    CONTENT_OWNER_ID = -99;
    END IF;

  ELSIF (X_SERVICE_TYPE_CODE = 'DET_TAX_STATUS') THEN

    UPDATE ZX_TAXES_B
	    SET TAX_STATUS_RULE_FLAG = 'Y'
	    WHERE
	    TAX_REGIME_CODE = X_TAX_REGIME_CODE AND
	    TAX = X_TAX AND
	    CONTENT_OWNER_ID = X_CONTENT_OWNER_ID;

    IF (SQL%NOTFOUND) THEN
        UPDATE ZX_TAXES_B
	    SET TAX_STATUS_RULE_FLAG = 'Y'
	    WHERE
	    TAX_REGIME_CODE = X_TAX_REGIME_CODE AND
	    TAX = X_TAX AND
	    CONTENT_OWNER_ID = -99;
    END IF;

  ELSIF (X_SERVICE_TYPE_CODE = 'DET_APPLICABLE_TAXES') THEN

      UPDATE ZX_TAXES_B
	    SET APPLICABILITY_RULE_FLAG = 'Y'
	    WHERE
	    TAX_REGIME_CODE = X_TAX_REGIME_CODE AND
	    TAX = X_TAX AND
	    CONTENT_OWNER_ID = X_CONTENT_OWNER_ID;

      -- Bug 5501831 - If no tax exists then Update the GCO Tax
      /*IF (SQL%NOTFOUND) THEN
         UPDATE ZX_TAXES_B
	    SET APPLICABILITY_RULE_FLAG = 'Y'
	    WHERE
	    TAX_REGIME_CODE = X_TAX_REGIME_CODE AND
	    TAX = X_TAX AND
	    CONTENT_OWNER_ID = -99;
      END IF;*/
      -- Bug 5548613 - Copying tax in this case
      IF (SQL%NOTFOUND) THEN
        SELECT zx_taxes_b_s.nextval INTO l_tax_id from dual;

        INSERT INTO ZX_TAXES_B_TMP
        (
          TAX                                    ,
          EFFECTIVE_FROM                         ,
          EFFECTIVE_TO                           ,
          TAX_REGIME_CODE                        ,
          TAX_TYPE_CODE                          ,
          ALLOW_MANUAL_ENTRY_FLAG                ,
          ALLOW_TAX_OVERRIDE_FLAG                ,
          MIN_TXBL_BSIS_THRSHLD                  ,
          MAX_TXBL_BSIS_THRSHLD                  ,
          MIN_TAX_RATE_THRSHLD                   ,
          MAX_TAX_RATE_THRSHLD                   ,
          MIN_TAX_AMT_THRSHLD                    ,
          MAX_TAX_AMT_THRSHLD                    ,
          COMPOUNDING_PRECEDENCE                 ,
          PERIOD_SET_NAME                        ,
          EXCHANGE_RATE_TYPE                     ,
          TAX_CURRENCY_CODE                      ,
          TAX_PRECISION                          ,
          MINIMUM_ACCOUNTABLE_UNIT               ,
          ROUNDING_RULE_CODE                     ,
          TAX_STATUS_RULE_FLAG                   ,
          TAX_RATE_RULE_FLAG                     ,
          DEF_PLACE_OF_SUPPLY_TYPE_CODE          ,
          PLACE_OF_SUPPLY_RULE_FLAG              ,
          DIRECT_RATE_RULE_FLAG                  ,
          APPLICABILITY_RULE_FLAG                ,
          TAX_CALC_RULE_FLAG                     ,
          TXBL_BSIS_THRSHLD_FLAG                 ,
          TAX_RATE_THRSHLD_FLAG                  ,
          TAX_AMT_THRSHLD_FLAG                   ,
          TAXABLE_BASIS_RULE_FLAG                ,
          DEF_INCLUSIVE_TAX_FLAG                 ,
          THRSHLD_GROUPING_LVL_CODE              ,
          HAS_OTHER_JURISDICTIONS_FLAG           ,
          ALLOW_EXEMPTIONS_FLAG                  ,
          ALLOW_EXCEPTIONS_FLAG                  ,
          ALLOW_RECOVERABILITY_FLAG              ,
          DEF_TAX_CALC_FORMULA                   ,
          TAX_INCLUSIVE_OVERRIDE_FLAG            ,
          DEF_TAXABLE_BASIS_FORMULA              ,
          DEF_REGISTR_PARTY_TYPE_CODE            ,
          REGISTRATION_TYPE_RULE_FLAG            ,
          REPORTING_ONLY_FLAG                    ,
          AUTO_PRVN_FLAG                         ,
          LIVE_FOR_PROCESSING_FLAG               ,
          LIVE_FOR_APPLICABILITY_FLAG            ,
          HAS_DETAIL_TB_THRSHLD_FLAG             ,
          HAS_TAX_DET_DATE_RULE_FLAG             ,
          HAS_EXCH_RATE_DATE_RULE_FLAG           ,
          HAS_TAX_POINT_DATE_RULE_FLAG           ,
          PRINT_ON_INVOICE_FLAG                  ,
          USE_LEGAL_MSG_FLAG                     ,
          CALC_ONLY_FLAG                         ,
          PRIMARY_RECOVERY_TYPE_CODE             ,
          PRIMARY_REC_TYPE_RULE_FLAG             ,
          SECONDARY_RECOVERY_TYPE_CODE           ,
          SECONDARY_REC_TYPE_RULE_FLAG           ,
          PRIMARY_REC_RATE_DET_RULE_FLAG         ,
          SEC_REC_RATE_DET_RULE_FLAG             ,
          OFFSET_TAX_FLAG                        ,
          RECOVERY_RATE_OVERRIDE_FLAG            ,
          ZONE_GEOGRAPHY_TYPE                    ,
          REGN_NUM_SAME_AS_LE_FLAG               ,
          DEF_REC_SETTLEMENT_OPTION_CODE         ,
          RECORD_TYPE_CODE                       ,
          ALLOW_ROUNDING_OVERRIDE_FLAG           ,
          SOURCE_TAX_FLAG                        ,
          SPECIAL_INCLUSIVE_TAX_FLAG             ,
          ATTRIBUTE1                             ,
          ATTRIBUTE2                             ,
          ATTRIBUTE3                             ,
          ATTRIBUTE4                             ,
          ATTRIBUTE5                             ,
          ATTRIBUTE6                             ,
          ATTRIBUTE7                             ,
          ATTRIBUTE8                             ,
          ATTRIBUTE9                             ,
          ATTRIBUTE10                            ,
          ATTRIBUTE11                            ,
          ATTRIBUTE12                            ,
          ATTRIBUTE13                            ,
          ATTRIBUTE14                            ,
          ATTRIBUTE15                            ,
          ATTRIBUTE_CATEGORY                     ,
          PARENT_GEOGRAPHY_TYPE                  ,
          PARENT_GEOGRAPHY_ID                    ,
          ALLOW_MASS_CREATE_FLAG                 ,
          APPLIED_AMT_HANDLING_FLAG              ,
          TAX_ID                                 ,
          CONTENT_OWNER_ID                       ,
          REP_TAX_AUTHORITY_ID                   ,
          COLL_TAX_AUTHORITY_ID                  ,
          THRSHLD_CHK_TMPLT_CODE                 ,
          DEF_PRIMARY_REC_RATE_CODE              ,
          DEF_SECONDARY_REC_RATE_CODE            ,
          CREATED_BY                             ,
          CREATION_DATE                          ,
          LAST_UPDATED_BY                        ,
          LAST_UPDATE_DATE                       ,
          LAST_UPDATE_LOGIN                      ,
          REQUEST_ID                             ,
          PROGRAM_APPLICATION_ID                 ,
          PROGRAM_ID                             ,
          PROGRAM_LOGIN_ID                       ,
          OVERRIDE_GEOGRAPHY_TYPE                ,
          OBJECT_VERSION_NUMBER                  ,
          TAX_ACCOUNT_CREATE_METHOD_CODE         ,
          TAX_ACCOUNT_SOURCE_TAX                 ,
          TAX_EXMPT_CR_METHOD_CODE               ,
          TAX_EXMPT_SOURCE_TAX                   ,
          APPLICABLE_BY_DEFAULT_FLAG             ,
          ALLOW_DUP_REGN_NUM_FLAG	               ,
          LEGAL_REPORTING_STATUS_DEF_VAL
        )
        SELECT
          TAX                                    ,
          EFFECTIVE_FROM                         ,
          EFFECTIVE_TO                           ,
          TAX_REGIME_CODE                        ,
          TAX_TYPE_CODE                          ,
          ALLOW_MANUAL_ENTRY_FLAG                ,
          ALLOW_TAX_OVERRIDE_FLAG                ,
          MIN_TXBL_BSIS_THRSHLD                  ,
          MAX_TXBL_BSIS_THRSHLD                  ,
          MIN_TAX_RATE_THRSHLD                   ,
          MAX_TAX_RATE_THRSHLD                   ,
          MIN_TAX_AMT_THRSHLD                    ,
          MAX_TAX_AMT_THRSHLD                    ,
          COMPOUNDING_PRECEDENCE                 ,
          PERIOD_SET_NAME                        ,
          EXCHANGE_RATE_TYPE                     ,
          TAX_CURRENCY_CODE                      ,
          TAX_PRECISION                          ,
          MINIMUM_ACCOUNTABLE_UNIT               ,
          ROUNDING_RULE_CODE                     ,
          TAX_STATUS_RULE_FLAG                   ,
          TAX_RATE_RULE_FLAG                     ,
          DEF_PLACE_OF_SUPPLY_TYPE_CODE          ,
          PLACE_OF_SUPPLY_RULE_FLAG              ,
          DIRECT_RATE_RULE_FLAG                  ,
          'Y'                                    , -- APPLICABILITY_RULE_FLAG
          TAX_CALC_RULE_FLAG                     ,
          TXBL_BSIS_THRSHLD_FLAG                 ,
          TAX_RATE_THRSHLD_FLAG                  ,
          TAX_AMT_THRSHLD_FLAG                   ,
          TAXABLE_BASIS_RULE_FLAG                ,
          DEF_INCLUSIVE_TAX_FLAG                 ,
          THRSHLD_GROUPING_LVL_CODE              ,
          HAS_OTHER_JURISDICTIONS_FLAG           ,
          ALLOW_EXEMPTIONS_FLAG                  ,
          ALLOW_EXCEPTIONS_FLAG                  ,
          ALLOW_RECOVERABILITY_FLAG              ,
          DEF_TAX_CALC_FORMULA                   ,
          TAX_INCLUSIVE_OVERRIDE_FLAG            ,
          DEF_TAXABLE_BASIS_FORMULA              ,
          DEF_REGISTR_PARTY_TYPE_CODE            ,
          REGISTRATION_TYPE_RULE_FLAG            ,
          REPORTING_ONLY_FLAG                    ,
          AUTO_PRVN_FLAG                         ,
          LIVE_FOR_PROCESSING_FLAG               ,
          LIVE_FOR_APPLICABILITY_FLAG            ,
          HAS_DETAIL_TB_THRSHLD_FLAG             ,
          HAS_TAX_DET_DATE_RULE_FLAG             ,
          HAS_EXCH_RATE_DATE_RULE_FLAG           ,
          HAS_TAX_POINT_DATE_RULE_FLAG           ,
          PRINT_ON_INVOICE_FLAG                  ,
          USE_LEGAL_MSG_FLAG                     ,
          CALC_ONLY_FLAG                         ,
          PRIMARY_RECOVERY_TYPE_CODE             ,
          PRIMARY_REC_TYPE_RULE_FLAG             ,
          SECONDARY_RECOVERY_TYPE_CODE           ,
          SECONDARY_REC_TYPE_RULE_FLAG           ,
          PRIMARY_REC_RATE_DET_RULE_FLAG         ,
          SEC_REC_RATE_DET_RULE_FLAG             ,
          OFFSET_TAX_FLAG                        ,
          RECOVERY_RATE_OVERRIDE_FLAG            ,
          ZONE_GEOGRAPHY_TYPE                    ,
          REGN_NUM_SAME_AS_LE_FLAG               ,
          DEF_REC_SETTLEMENT_OPTION_CODE         ,
          RECORD_TYPE_CODE                       ,
          ALLOW_ROUNDING_OVERRIDE_FLAG           ,
          SOURCE_TAX_FLAG                        ,
          SPECIAL_INCLUSIVE_TAX_FLAG             ,
          ATTRIBUTE1                             ,
          ATTRIBUTE2                             ,
          ATTRIBUTE3                             ,
          ATTRIBUTE4                             ,
          ATTRIBUTE5                             ,
          ATTRIBUTE6                             ,
          ATTRIBUTE7                             ,
          ATTRIBUTE8                             ,
          ATTRIBUTE9                             ,
          ATTRIBUTE10                            ,
          ATTRIBUTE11                            ,
          ATTRIBUTE12                            ,
          ATTRIBUTE13                            ,
          ATTRIBUTE14                            ,
          ATTRIBUTE15                            ,
          ATTRIBUTE_CATEGORY                     ,
          PARENT_GEOGRAPHY_TYPE                  ,
          PARENT_GEOGRAPHY_ID                    ,
          ALLOW_MASS_CREATE_FLAG                 ,
          APPLIED_AMT_HANDLING_FLAG              ,
          l_tax_id                               , -- TAX_ID
          x_content_owner_id                     , -- CONTENT_OWNER_ID
          REP_TAX_AUTHORITY_ID                   ,
          COLL_TAX_AUTHORITY_ID                  ,
          THRSHLD_CHK_TMPLT_CODE                 ,
          DEF_PRIMARY_REC_RATE_CODE              ,
          DEF_SECONDARY_REC_RATE_CODE            ,
          X_CREATED_BY                           ,
          X_CREATION_DATE                        ,
          X_LAST_UPDATED_BY                      ,
          X_LAST_UPDATE_DATE                     ,
          X_LAST_UPDATE_LOGIN                    ,
          REQUEST_ID                             ,
          PROGRAM_APPLICATION_ID                 ,
          PROGRAM_ID                             ,
          PROGRAM_LOGIN_ID                       ,
          OVERRIDE_GEOGRAPHY_TYPE                ,
          1                                      , -- OBJECT_VERSION_NUMBER
          TAX_ACCOUNT_CREATE_METHOD_CODE         ,
          TAX_ACCOUNT_SOURCE_TAX                 ,
          TAX_EXMPT_CR_METHOD_CODE               ,
          TAX_EXMPT_SOURCE_TAX                   ,
          APPLICABLE_BY_DEFAULT_FLAG             ,
          ALLOW_DUP_REGN_NUM_FLAG	               ,
          LEGAL_REPORTING_STATUS_DEF_VAL
        FROM ZX_TAXES_B
        WHERE TAX_REGIME_CODE = X_TAX_REGIME_CODE
        AND   TAX = X_TAX
        AND   CONTENT_OWNER_ID = -99;
        --RETURNING TAX_ID INTO l_tax_id;

        IF (l_tax_id IS NOT NULL) THEN
          INSERT INTO ZX_TAXES_TL
          (
            LANGUAGE                    ,
            SOURCE_LANG                 ,
            TAX_FULL_NAME               ,
            CREATED_BY                  ,
            CREATION_DATE               ,
            LAST_UPDATED_BY             ,
            LAST_UPDATE_DATE            ,
            LAST_UPDATE_LOGIN           ,
            TAX_ID
          )
          SELECT
            zttl.LANGUAGE               ,
            zttl.SOURCE_LANG            ,
            zttl.TAX_FULL_NAME          ,
            X_CREATED_BY                ,
            X_CREATION_DATE             ,
            X_LAST_UPDATED_BY           ,
            X_LAST_UPDATE_DATE          ,
            X_LAST_UPDATE_LOGIN         ,
            l_tax_id
          FROM ZX_TAXES_TL zttl,
               ZX_TAXES_B ztb
          WHERE ztb.TAX_REGIME_CODE = X_TAX_REGIME_CODE
          AND   ztb.TAX = X_TAX
          AND   ztb.CONTENT_OWNER_ID = -99
          AND   zttl.TAX_ID = ztb.TAX_ID;
        END IF;

      END IF;

  ELSIF (X_SERVICE_TYPE_CODE = 'DET_DIRECT_RATE') THEN

    UPDATE ZX_TAXES_B
	    SET DIRECT_RATE_RULE_FLAG = 'Y'
	    WHERE
	    TAX_REGIME_CODE = X_TAX_REGIME_CODE AND
	    TAX = X_TAX AND
	    CONTENT_OWNER_ID = X_CONTENT_OWNER_ID;

    IF (SQL%NOTFOUND) THEN
        UPDATE ZX_TAXES_B
	    SET DIRECT_RATE_RULE_FLAG = 'Y'
	    WHERE
	    TAX_REGIME_CODE = X_TAX_REGIME_CODE AND
	    TAX = X_TAX AND
	    CONTENT_OWNER_ID = -99;
    END IF;

  END IF;

  insert into ZX_RULES_B (
    TAX_RULE_ID,
    TAX_RULE_CODE,
    TAX,
    TAX_REGIME_CODE,
    SERVICE_TYPE_CODE,
    RECOVERY_TYPE_CODE,
    PRIORITY,
    System_Default_Flag,
    EFFECTIVE_FROM,
    EFFECTIVE_TO,
    Record_Type_Code,
    REQUEST_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_LOGIN_ID,
    Enabled_Flag,
    APPLICATION_ID,
    CONTENT_OWNER_ID,
    DET_FACTOR_TEMPL_CODE,
    EVENT_CLASS_MAPPING_ID ,
    TAX_EVENT_CLASS_CODE,
    OBJECT_VERSION_NUMBER,
    DETERMINING_FACTOR_CQ_CODE              ,
		 GEOGRAPHY_TYPE                       ,
		 GEOGRAPHY_ID                         ,
		 TAX_LAW_REF_CODE                     ,
		 LAST_UPDATE_MODE_FLAG                ,
  NEVER_BEEN_ENABLED_FLAG
)
  values (
    X_TAX_RULE_ID,
    X_TAX_RULE_CODE,
    X_TAX,
    X_TAX_REGIME_CODE,
    X_SERVICE_TYPE_CODE,
    X_RECOVERY_TYPE_CODE,
    X_PRIORITY,
    NVL(X_SYSTEM_DEFAULT_FLAG,'N'),
    X_EFFECTIVE_FROM,
    X_EFFECTIVE_TO,
    X_Record_Type_Code,
    X_REQUEST_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_ID,
    X_PROGRAM_LOGIN_ID,
    NVL(X_ENABLED_FLAG,'N'),
    X_APPLICATION_ID,
    X_CONTENT_OWNER_ID,
    X_DET_FACTOR_TEMPL_CODE,
    X_EVENT_CLASS_MAPPING_ID,
    X_TAX_EVENT_CLASS_CODE,
    X_OBJECT_VERSION_NUMBER,
      X_DETERMINING_FACTOR_CQ_CODE          ,
  X_GEOGRAPHY_TYPE                          ,
  X_GEOGRAPHY_ID                            ,
  X_TAX_LAW_REF_CODE                        ,
  X_LAST_UPDATE_MODE_FLAG                   ,
  X_NEVER_BEEN_ENABLED_FLAG);
  insert into ZX_RULES_TL (
    TAX_RULE_ID,
    TAX_RULE_NAME,
    TAX_RULE_DESC,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
    TAX_LAW_REF_DESC)
  select
    X_TAX_RULE_ID,
    X_TAX_RULE_NAME,
    X_TAX_RULE_DESC,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG') ,
    X_TAX_LAW_REF_DESC
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ZX_RULES_TL T
    where T.TAX_RULE_ID = X_TAX_RULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

 EXCEPTION
      WHEN OTHERS THEN
        APP_EXCEPTION.RAISE_EXCEPTION;

end INSERT_ROW;

procedure LOCK_ROW (
  X_TAX_RULE_ID in NUMBER,
  X_TAX_RULE_CODE in VARCHAR2,
  X_TAX in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_SERVICE_TYPE_CODE in VARCHAR2,
  X_RECOVERY_TYPE_CODE in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_System_Default_Flag in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_Record_Type_Code in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_TAX_RULE_NAME in VARCHAR2,
  X_TAX_RULE_DESC in VARCHAR2,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_Enabled_Flag in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_OWNER_ID in NUMBER,
  X_DET_FACTOR_TEMPL_CODE in VARCHAR2,
  X_EVENT_CLASS_MAPPING_ID in NUMBER,
  X_TAX_EVENT_CLASS_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
      X_DETERMINING_FACTOR_CQ_CODE               IN VARCHAR2,
		  X_GEOGRAPHY_TYPE                           IN VARCHAR2,
		  X_GEOGRAPHY_ID                             IN NUMBER,
		  X_TAX_LAW_REF_CODE                         IN VARCHAR2,
		  X_TAX_LAW_REF_DESC                         IN VARCHAR2,
		  X_LAST_UPDATE_MODE_FLAG                    IN VARCHAR2,
	  X_NEVER_BEEN_ENABLED_FLAG                  IN VARCHAR2

) is

  cursor c is select
      TAX_RULE_CODE,
      TAX,
      TAX_REGIME_CODE,
      SERVICE_TYPE_CODE,
      RECOVERY_TYPE_CODE,
      PRIORITY,
      System_Default_Flag,
      EFFECTIVE_FROM,
      EFFECTIVE_TO,
      Record_Type_Code,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_LOGIN_ID,
      Enabled_Flag,
      APPLICATION_ID,
      CONTENT_OWNER_ID,
      DET_FACTOR_TEMPL_CODE,
      EVENT_CLASS_MAPPING_ID ,
      TAX_EVENT_CLASS_CODE,
      OBJECT_VERSION_NUMBER,
      DETERMINING_FACTOR_CQ_CODE               ,
			GEOGRAPHY_TYPE                           ,
			GEOGRAPHY_ID                             ,
			TAX_LAW_REF_CODE                         ,
			LAST_UPDATE_MODE_FLAG                    ,
			NEVER_BEEN_ENABLED_FLAG

    from ZX_RULES_B
    where TAX_RULE_ID = X_TAX_RULE_ID
    for update of TAX_RULE_ID nowait;

  recinfo c%rowtype;
  cursor c1 is select
      TAX_RULE_NAME,
      TAX_RULE_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG  ,
      TAX_LAW_REF_DESC
    from ZX_RULES_TL
    where TAX_RULE_ID = X_TAX_RULE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TAX_RULE_ID nowait;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if ((recinfo.TAX_RULE_CODE = X_TAX_RULE_CODE)
      AND ((recinfo.TAX = X_TAX)
           OR ((recinfo.TAX is null) AND (X_TAX is null)))
      AND (recinfo.TAX_REGIME_CODE = X_TAX_REGIME_CODE)
      AND (recinfo.SERVICE_TYPE_CODE = X_SERVICE_TYPE_CODE)
      AND ((recinfo.RECOVERY_TYPE_CODE = X_RECOVERY_TYPE_CODE)
           OR ((recinfo.RECOVERY_TYPE_CODE is null) AND (X_RECOVERY_TYPE_CODE is null)))
      AND (recinfo.PRIORITY = X_PRIORITY)
      AND ((recinfo.System_Default_Flag = X_System_Default_Flag)
           OR ((recinfo.System_Default_Flag is null) AND (X_System_Default_Flag is null)))
      AND (recinfo.EFFECTIVE_FROM = X_EFFECTIVE_FROM)
      AND ((recinfo.EFFECTIVE_TO = X_EFFECTIVE_TO)
           OR ((recinfo.EFFECTIVE_TO is null) AND (X_EFFECTIVE_TO is null)))
      AND (recinfo.Record_Type_Code = X_Record_Type_Code)
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
      AND ((recinfo.PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID)
           OR ((recinfo.PROGRAM_APPLICATION_ID is null) AND (X_PROGRAM_APPLICATION_ID is null)))
      AND ((recinfo.PROGRAM_ID = X_PROGRAM_ID)
           OR ((recinfo.PROGRAM_ID is null) AND (X_PROGRAM_ID is null)))
      AND ((recinfo.PROGRAM_LOGIN_ID = X_PROGRAM_LOGIN_ID)
           OR ((recinfo.PROGRAM_LOGIN_ID is null) AND (X_PROGRAM_LOGIN_ID is null)))
      AND ((recinfo.Enabled_Flag = X_Enabled_Flag)
           OR ((recinfo.Enabled_Flag is null) AND (X_Enabled_Flag is null)))
      AND ((recinfo.APPLICATION_ID = X_APPLICATION_ID)
           OR ((recinfo.APPLICATION_ID is null) AND (X_APPLICATION_ID is null)))
      AND ((recinfo.CONTENT_OWNER_ID = X_CONTENT_OWNER_ID)
           OR ((recinfo.CONTENT_OWNER_ID is null) AND (X_CONTENT_OWNER_ID is null)))
      AND ((recinfo.DET_FACTOR_TEMPL_CODE = X_DET_FACTOR_TEMPL_CODE)
           OR ((recinfo.DET_FACTOR_TEMPL_CODE is null) AND (X_DET_FACTOR_TEMPL_CODE is null)))
      AND ((recinfo.EVENT_CLASS_MAPPING_ID = X_EVENT_CLASS_MAPPING_ID)
           OR ((recinfo.EVENT_CLASS_MAPPING_ID is null) AND (X_EVENT_CLASS_MAPPING_ID is null)))
      AND ((recinfo.TAX_EVENT_CLASS_CODE = X_TAX_EVENT_CLASS_CODE)
           OR ((recinfo.TAX_EVENT_CLASS_CODE is null) AND (X_TAX_EVENT_CLASS_CODE is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)

      AND ((recinfo.DETERMINING_FACTOR_CQ_CODE = X_DETERMINING_FACTOR_CQ_CODE)
           OR ((recinfo.DETERMINING_FACTOR_CQ_CODE is null) AND (X_DETERMINING_FACTOR_CQ_CODE is null)))

      AND ((recinfo.GEOGRAPHY_TYPE = X_GEOGRAPHY_TYPE)
           OR ((recinfo.GEOGRAPHY_TYPE is null) AND (X_GEOGRAPHY_TYPE is null)))

      AND ((recinfo.GEOGRAPHY_ID = X_GEOGRAPHY_ID)
           OR ((recinfo.GEOGRAPHY_ID is null) AND (X_GEOGRAPHY_ID is null)))

      AND ((recinfo.TAX_LAW_REF_CODE = X_TAX_LAW_REF_CODE)
           OR ((recinfo.TAX_LAW_REF_CODE is null) AND (X_TAX_LAW_REF_CODE is null)))

      AND ((recinfo.LAST_UPDATE_MODE_FLAG = X_LAST_UPDATE_MODE_FLAG)
           OR ((recinfo.LAST_UPDATE_MODE_FLAG is null) AND (X_LAST_UPDATE_MODE_FLAG is null)))

      AND ((recinfo.NEVER_BEEN_ENABLED_FLAG = X_NEVER_BEEN_ENABLED_FLAG)
           OR ((recinfo.NEVER_BEEN_ENABLED_FLAG is null) AND (X_NEVER_BEEN_ENABLED_FLAG is null)))

  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if ( (tlinfo.TAX_RULE_NAME = X_TAX_RULE_NAME)
          AND ((tlinfo.TAX_RULE_DESC = X_TAX_RULE_DESC)
           OR ((tlinfo.TAX_RULE_DESC is null) AND (X_TAX_RULE_DESC is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;

 EXCEPTION
      WHEN OTHERS THEN
        APP_EXCEPTION.RAISE_EXCEPTION;

end LOCK_ROW;

procedure UPDATE_ROW (
  X_TAX_RULE_ID in NUMBER,
  X_TAX_RULE_CODE in VARCHAR2,
  X_TAX in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_SERVICE_TYPE_CODE in VARCHAR2,
  X_RECOVERY_TYPE_CODE in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_System_Default_Flag in VARCHAR2,
  X_EFFECTIVE_FROM in DATE,
  X_EFFECTIVE_TO in DATE,
  X_Record_Type_Code in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_TAX_RULE_NAME in VARCHAR2,
  X_TAX_RULE_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_Enabled_Flag in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CONTENT_OWNER_ID in NUMBER,
  X_DET_FACTOR_TEMPL_CODE in VARCHAR2,
  X_EVENT_CLASS_MAPPING_ID in NUMBER,
  X_TAX_EVENT_CLASS_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
      X_DETERMINING_FACTOR_CQ_CODE               IN VARCHAR2,
		  X_GEOGRAPHY_TYPE                           IN VARCHAR2,
		  X_GEOGRAPHY_ID                             IN NUMBER,
		  X_TAX_LAW_REF_CODE                         IN VARCHAR2,
		  X_TAX_LAW_REF_DESC                         IN VARCHAR2,
		  X_LAST_UPDATE_MODE_FLAG                    IN VARCHAR2,
	  X_NEVER_BEEN_ENABLED_FLAG                  IN VARCHAR2
) is

begin
  update ZX_RULES_B set
    TAX_RULE_CODE = X_TAX_RULE_CODE,
    TAX = X_TAX,
    TAX_REGIME_CODE = X_TAX_REGIME_CODE,
    SERVICE_TYPE_CODE = X_SERVICE_TYPE_CODE,
    RECOVERY_TYPE_CODE = X_RECOVERY_TYPE_CODE,
    PRIORITY = X_PRIORITY,
    System_Default_Flag = NVL(X_SYSTEM_DEFAULT_FLAG,'N'),
    EFFECTIVE_FROM = X_EFFECTIVE_FROM,
    EFFECTIVE_TO = X_EFFECTIVE_TO,
    Record_Type_Code = X_Record_Type_Code,
    REQUEST_ID = X_REQUEST_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_LOGIN_ID = X_PROGRAM_LOGIN_ID,
    Enabled_Flag = NVL(X_ENABLED_FLAG,'N'),
    APPLICATION_ID = X_APPLICATION_ID,
    CONTENT_OWNER_ID = X_CONTENT_OWNER_ID,
    DET_FACTOR_TEMPL_CODE = X_DET_FACTOR_TEMPL_CODE,
    EVENT_CLASS_MAPPING_ID =  X_EVENT_CLASS_MAPPING_ID,
    TAX_EVENT_CLASS_CODE = X_TAX_EVENT_CLASS_CODE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    DETERMINING_FACTOR_CQ_CODE=X_DETERMINING_FACTOR_CQ_CODE               ,
		GEOGRAPHY_TYPE=X_GEOGRAPHY_TYPE                     ,
		GEOGRAPHY_ID=X_GEOGRAPHY_ID                  ,
		TAX_LAW_REF_CODE=X_TAX_LAW_REF_CODE              ,
		LAST_UPDATE_MODE_FLAG=X_LAST_UPDATE_MODE_FLAG         ,
		NEVER_BEEN_ENABLED_FLAG=X_NEVER_BEEN_ENABLED_FLAG
  where TAX_RULE_ID = X_TAX_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update ZX_RULES_TL set
    TAX_RULE_NAME = X_TAX_RULE_NAME,
    TAX_RULE_DESC = X_TAX_RULE_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')                ,
    TAX_LAW_REF_DESC = X_TAX_LAW_REF_DESC
  where TAX_RULE_ID = X_TAX_RULE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

 EXCEPTION
      WHEN OTHERS THEN
        APP_EXCEPTION.RAISE_EXCEPTION;

end UPDATE_ROW;
procedure DELETE_ROW (
  X_TAX_RULE_ID in NUMBER) is

begin
  delete from ZX_RULES_TL
  where TAX_RULE_ID = X_TAX_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ZX_RULES_B
  where TAX_RULE_ID = X_TAX_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

 EXCEPTION
      WHEN OTHERS THEN
        APP_EXCEPTION.RAISE_EXCEPTION;

end DELETE_ROW;

procedure ADD_LANGUAGE is
begin
  delete from ZX_RULES_TL T
  where not exists
    (select NULL
    from ZX_RULES_B B
    where B.TAX_RULE_ID = T.TAX_RULE_ID);
  update ZX_RULES_TL T set (
      TAX_RULE_NAME,
      TAX_RULE_DESC) = (select B.TAX_RULE_NAME,
                               B.TAX_RULE_DESC
                        from ZX_RULES_TL B
                        where B.TAX_RULE_ID = T.TAX_RULE_ID
                        and B.LANGUAGE = T.SOURCE_LANG)
  where (T.TAX_RULE_ID, T.LANGUAGE) in
 (select SUBT.TAX_RULE_ID,
         SUBT.LANGUAGE
    from ZX_RULES_TL SUBB, ZX_RULES_TL SUBT
    where SUBB.TAX_RULE_ID = SUBT.TAX_RULE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TAX_RULE_NAME <> SUBT.TAX_RULE_NAME
      or SUBB.TAX_RULE_DESC <> SUBT.TAX_RULE_DESC
      or (SUBB.TAX_RULE_DESC is null and SUBT.TAX_RULE_DESC is not null)
      or (SUBB.TAX_RULE_DESC is not null and SUBT.TAX_RULE_DESC is null) ));

  insert into ZX_RULES_TL (
    TAX_RULE_ID,
    TAX_RULE_NAME,
    TAX_RULE_DESC,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG)
  select
    B.TAX_RULE_ID,
    B.TAX_RULE_NAME,
    B.TAX_RULE_DESC,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ZX_RULES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ZX_RULES_TL T
    where T.TAX_RULE_ID = B.TAX_RULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

 EXCEPTION
      WHEN OTHERS THEN
        APP_EXCEPTION.RAISE_EXCEPTION;
end ADD_LANGUAGE;

procedure bulk_insert_rules (
  X_TAX_RULE_ID            IN t_tax_rule_id,
  X_TAX_RULE_CODE          IN t_tax_rule_code,
  X_TAX                    IN t_tax,
  X_TAX_REGIME_CODE        IN t_tax_regime_code,
  X_SERVICE_TYPE_CODE      IN t_service_type_code,
  X_RECOVERY_TYPE_CODE     IN t_recovery_type_code,
  X_PRIORITY               IN t_priority,
  X_System_Default_Flag     IN t_system_default_flg,
  X_EFFECTIVE_FROM         IN t_effective_from,
  X_EFFECTIVE_TO           IN t_effective_to,
  X_Record_Type_Code            IN t_record_type,
  X_TAX_RULE_NAME          IN t_tax_rule_name,
  X_TAX_RULE_DESC          IN t_tax_rule_desc,
  X_Enabled_Flag            IN t_enabled_flg,
  X_APPLICATION_ID         IN t_application_id,
  X_CONTENT_OWNER_ID       IN t_content_owner_id,
  X_DET_FACTOR_TEMPL_CODE  IN t_det_factor_templ_code) is

begin
  If x_tax_rule_id.count <> 0 then
     forall i in x_tax_rule_id.first..x_tax_rule_id.last
       INSERT INTO ZX_RULES_B (TAX_RULE_ID,
                               TAX_RULE_CODE,
                               TAX,
                               TAX_REGIME_CODE,
                               SERVICE_TYPE_CODE,
                               RECOVERY_TYPE_CODE,
                               PRIORITY,
                               System_Default_Flag,
                               EFFECTIVE_FROM,
                               EFFECTIVE_TO,
                               Record_Type_Code,
                               Enabled_Flag,
                               APPLICATION_ID,
                               CONTENT_OWNER_ID,
                               DET_FACTOR_TEMPL_CODE,
                               CREATED_BY             ,
                               CREATION_DATE          ,
                               LAST_UPDATED_BY        ,
                               LAST_UPDATE_DATE       ,
                               LAST_UPDATE_LOGIN      ,
                               REQUEST_ID             ,
                               PROGRAM_APPLICATION_ID ,
                               PROGRAM_ID             ,
                               PROGRAM_LOGIN_ID)
                       VALUES (X_TAX_RULE_ID(i),
                               X_TAX_RULE_CODE(i),
                               X_TAX(i),
                               X_TAX_REGIME_CODE(i),
                               X_SERVICE_TYPE_CODE(i),
                               X_RECOVERY_TYPE_CODE(i),
                               X_PRIORITY(i),
                               NVL(X_System_Default_Flag(i),'N'),
                               X_EFFECTIVE_FROM(i),
                               X_EFFECTIVE_TO(i),
                               X_Record_Type_Code(i),
                               NVL(X_Enabled_Flag(i),'N'),
                               X_APPLICATION_ID(i),
                               X_CONTENT_OWNER_ID(i),
                               X_DET_FACTOR_TEMPL_CODE(i),
                               fnd_global.user_id               ,
                               sysdate                          ,
                               fnd_global.user_id               ,
                               sysdate                          ,
                               fnd_global.conc_login_id         ,
                               fnd_global.conc_request_id       ,
                               fnd_global.prog_appl_id          ,
                               fnd_global.conc_program_id       ,
                               fnd_global.conc_login_id
                               );

     forall i in x_tax_rule_id.first..x_tax_rule_id.last
       INSERT INTO ZX_RULES_TL (TAX_RULE_ID,
                                TAX_RULE_NAME,
                                TAX_RULE_DESC,
                                CREATED_BY             ,
                                CREATION_DATE          ,
                                LAST_UPDATED_BY        ,
                                LAST_UPDATE_DATE       ,
                                LAST_UPDATE_LOGIN      ,
                                LANGUAGE,
                                SOURCE_LANG)
                              select
                                X_TAX_RULE_ID(i),
                                X_TAX_RULE_NAME(i),
                                X_TAX_RULE_DESC(i),
                                fnd_global.user_id               ,
                                sysdate                          ,
                                fnd_global.user_id               ,
                                sysdate                          ,
                                fnd_global.conc_login_id         ,
                                L.LANGUAGE_CODE,
                                userenv('LANG')
                              from FND_LANGUAGES L
                              where L.INSTALLED_FLAG in ('I', 'B')
                              and not exists
                                     (select 1
                                      from ZX_RULES_TL T
                                      where T.TAX_RULE_ID = X_TAX_RULE_ID(i)
                                      and T.LANGUAGE = L.LANGUAGE_CODE);
  end if;

 EXCEPTION
      WHEN OTHERS THEN
        APP_EXCEPTION.RAISE_EXCEPTION;

end bulk_insert_rules;

end ZX_RULES_PKG;

/
