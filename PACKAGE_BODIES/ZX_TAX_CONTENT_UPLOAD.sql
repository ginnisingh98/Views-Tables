--------------------------------------------------------
--  DDL for Package Body ZX_TAX_CONTENT_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TAX_CONTENT_UPLOAD" AS
/* $Header: zxldgeorateb.pls 120.17.12010000.12 2009/11/02 10:20:50 tsen ship $ */

/* ======================================================================*
 | Global Data Types                                                     |
 * ======================================================================*/

  G_PKG_NAME               CONSTANT VARCHAR2(30) := 'ZX_TAX_CONTENT_UPLOAD';
  G_CURRENT_RUNTIME_LEVEL  CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED       CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR            CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION        CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT            CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE        CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT        CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME            CONSTANT VARCHAR2(40) := 'ZX.PLSQL.ZX_TAX_CONTENT_UPLOAD.';
  G_CREATED_BY_MODULE      CONSTANT VARCHAR2(30) := 'EBTAX_CONTENT_UPLOAD';
  G_RECORD_EFFECTIVE_START CONSTANT DATE         := TO_DATE('01/01/1952','MM/DD/YYYY');

  --
  -- Method to setup initial data for content provider
  --
  PROCEDURE SETUP_DATA
  (
    errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY VARCHAR2,
    p_tax_content_source IN  VARCHAR2,
    p_tax_regime_code    IN  VARCHAR2,
    p_tax_zone_type      IN  VARCHAR2
  ) IS

    l_api_name           CONSTANT VARCHAR2(30):= 'setup_data';

    CURSOR c_tax_exists
    (
      b_tax_regime_code   VARCHAR2,
      b_tax               VARCHAR2,
      b_content_owner_id  NUMBER
    ) IS
      SELECT 'Y'
      FROM ZX_TAXES_B
      WHERE TAX_REGIME_CODE   = b_tax_regime_code
      AND   TAX               = b_tax
      AND   CONTENT_OWNER_ID  = b_content_owner_id;

    CURSOR c_tax_status_exists
    (
      b_tax_regime_code   VARCHAR2,
      b_tax               VARCHAR2,
      b_content_owner_id  NUMBER,
      b_tax_status_code   VARCHAR2
    ) IS
      SELECT 'Y'
      FROM ZX_STATUS_B
      WHERE TAX_REGIME_CODE   = b_tax_regime_code
      AND   TAX               = b_tax
      AND   CONTENT_OWNER_ID  = b_content_owner_id
      AND   TAX_STATUS_CODE   = b_tax_status_code;

    CURSOR c_geography_type_exists
    (
      b_geography_type  VARCHAR2
    ) IS
      SELECT 'Y'
      FROM HZ_GEOGRAPHY_TYPES_VL
      WHERE GEOGRAPHY_TYPE = b_geography_type;

    l_exists_flag        VARCHAR2(1);
    l_tax                VARCHAR2(30);
    l_incl_geo_type      HZ_GEOGRAPHY_STRUCTURE_PUB.INCL_GEO_TYPE_TBL_TYPE;
    l_zone_type_rec      HZ_GEOGRAPHY_STRUCTURE_PUB.ZONE_TYPE_REC_TYPE;
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

  BEGIN

    retcode := '0';

    FND_FILE.PUT_LINE
    (
      FND_FILE.LOG,
      'Starting setup_data.'
    );

    FOR I IN 1..3
    LOOP
      IF (I = 1)
      THEN
        l_tax := 'STATE';
      ELSIF (I = 2)
      THEN
        l_tax := 'COUNTY';
      ELSIF (I = 3)
      THEN
        l_tax := 'CITY';
      ELSE
        EXIT;
      END IF;

      l_exists_flag := 'N';
      OPEN c_tax_exists(p_tax_regime_code,l_tax,-99);
      FETCH c_tax_exists
        INTO l_exists_flag;
      CLOSE c_tax_exists;

      IF (NVL(l_exists_flag,'N') = 'N')
      THEN

        FND_FILE.PUT_LINE
        (
          FND_FILE.LOG,
          'Creating Tax: '||l_tax||'.'
        );

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
          OVERRIDE_GEOGRAPHY_TYPE                  ,
          OBJECT_VERSION_NUMBER                  ,
          TAX_ACCOUNT_CREATE_METHOD_CODE         ,
          TAX_ACCOUNT_SOURCE_TAX                 ,
          TAX_EXMPT_CR_METHOD_CODE               ,
          TAX_EXMPT_SOURCE_TAX                   ,
          APPLICABLE_BY_DEFAULT_FLAG
        )
        VALUES
        (
          l_tax                                  , -- TAX
          G_RECORD_EFFECTIVE_START               , -- EFFECTIVE_FROM
          NULL                                   , -- EFFECTIVE_TO
          p_tax_regime_code                      , -- TAX_REGIME_CODE
          NULL                                   , -- TAX_TYPE_CODE
          'N'                                    , -- ALLOW_MANUAL_ENTRY_FLAG
          'N'                                    , -- ALLOW_TAX_OVERRIDE_FLAG
          NULL                                   , -- MIN_TXBL_BSIS_THRSHLD
          NULL                                   , -- MAX_TXBL_BSIS_THRSHLD
          NULL                                   , -- MIN_TAX_RATE_THRSHLD
          NULL                                   , -- MAX_TAX_RATE_THRSHLD
          NULL                                   , -- MIN_TAX_AMT_THRSHLD
          NULL                                   , -- MAX_TAX_AMT_THRSHLD
          NULL                                   , -- COMPOUNDING_PRECEDENCE
          NULL                                   , -- PERIOD_SET_NAME
          NULL                                   , -- EXCHANGE_RATE_TYPE
          'USD'                                  , -- TAX_CURRENCY_CODE
          2                                      , -- TAX_PRECISION
          NULL                                   , -- MINIMUM_ACCOUNTABLE_UNIT
          'DOWN'                                 , -- ROUNDING_RULE_CODE
          'N'                                    , -- TAX_STATUS_RULE_FLAG
          'N'                                    , -- TAX_RATE_RULE_FLAG
          'SHIP_TO_BILL_TO'                      , -- DEF_PLACE_OF_SUPPLY_TYPE_CODE
          'N'                                    , -- PLACE_OF_SUPPLY_RULE_FLAG
          'N'                                    , -- DIRECT_RATE_RULE_FLAG
          'N'                                    , -- APPLICABILITY_RULE_FLAG
          'N'                                    , -- TAX_CALC_RULE_FLAG
          'N'                                    , -- TXBL_BSIS_THRSHLD_FLAG
          'N'                                    , -- TAX_RATE_THRSHLD_FLAG
          'N'                                    , -- TAX_AMT_THRSHLD_FLAG
          'N'                                    , -- TAXABLE_BASIS_RULE_FLAG
          'N'                                    , -- DEF_INCLUSIVE_TAX_FLAG
          NULL                                   , -- THRSHLD_GROUPING_LVL_CODE
          'Y'                                    , -- HAS_OTHER_JURISDICTIONS_FLAG
          'Y'                                    , -- ALLOW_EXEMPTIONS_FLAG
          'Y'                                    , -- ALLOW_EXCEPTIONS_FLAG
          'N'                                    , -- ALLOW_RECOVERABILITY_FLAG
          'STANDARD_TC'                          , -- DEF_TAX_CALC_FORMULA
          'N'                                    , -- TAX_INCLUSIVE_OVERRIDE_FLAG
          'STANDARD_TB'                          , -- DEF_TAXABLE_BASIS_FORMULA
          'SHIP_TO_PARTY'                        , -- DEF_REGISTR_PARTY_TYPE_CODE
          'N'                                    , -- REGISTRATION_TYPE_RULE_FLAG
          'N'                                    , -- REPORTING_ONLY_FLAG
          'N'                                    , -- AUTO_PRVN_FLAG
          'N'                                    , -- LIVE_FOR_PROCESSING_FLAG
          'Y'                                    , -- LIVE_FOR_APPLICABILITY_FLAG
          'N'                                    , -- HAS_DETAIL_TB_THRSHLD_FLAG
          'N'                                    , -- HAS_TAX_DET_DATE_RULE_FLAG
          'N'                                    , -- HAS_EXCH_RATE_DATE_RULE_FLAG
          'N'                                    , -- HAS_TAX_POINT_DATE_RULE_FLAG
          'Y'                                    , -- PRINT_ON_INVOICE_FLAG
          'N'                                    , -- USE_LEGAL_MSG_FLAG
          'N'                                    , -- CALC_ONLY_FLAG
          NULL                                   , -- PRIMARY_RECOVERY_TYPE_CODE
          'N'                                    , -- PRIMARY_REC_TYPE_RULE_FLAG
          NULL                                   , -- SECONDARY_RECOVERY_TYPE_CODE
          'N'                                    , -- SECONDARY_REC_TYPE_RULE_FLAG
          'N'                                    , -- PRIMARY_REC_RATE_DET_RULE_FLAG
          'N'                                    , -- SEC_REC_RATE_DET_RULE_FLAG
          'N'                                    , -- OFFSET_TAX_FLAG
          'N'                                    , -- RECOVERY_RATE_OVERRIDE_FLAG
          l_tax                                  , -- ZONE_GEOGRAPHY_TYPE
          'N'                                    , -- REGN_NUM_SAME_AS_LE_FLAG
          NULL                                   , -- DEF_REC_SETTLEMENT_OPTION_CODE
          G_CREATED_BY_MODULE                    , -- RECORD_TYPE_CODE
          NULL                                   , -- ALLOW_ROUNDING_OVERRIDE_FLAG
          'Y'                                    , -- SOURCE_TAX_FLAG
          'N'                                    , -- SPECIAL_INCLUSIVE_TAX_FLAG
          NULL                                   , -- ATTRIBUTE1
          NULL                                   , -- ATTRIBUTE2
          NULL                                   , -- ATTRIBUTE3
          NULL                                   , -- ATTRIBUTE4
          NULL                                   , -- ATTRIBUTE5
          NULL                                   , -- ATTRIBUTE6
          NULL                                   , -- ATTRIBUTE7
          NULL                                   , -- ATTRIBUTE8
          NULL                                   , -- ATTRIBUTE9
          NULL                                   , -- ATTRIBUTE10
          NULL                                   , -- ATTRIBUTE11
          NULL                                   , -- ATTRIBUTE12
          NULL                                   , -- ATTRIBUTE13
          NULL                                   , -- ATTRIBUTE14
          NULL                                   , -- ATTRIBUTE15
          NULL                                   , -- ATTRIBUTE_CATEGORY
          'COUNTRY'                              , -- PARENT_GEOGRAPHY_TYPE
          1                                      , -- PARENT_GEOGRAPHY_ID
          'N'                                    , -- ALLOW_MASS_CREATE_FLAG
          'P'                                    , -- APPLIED_AMT_HANDLING_FLAG
          zx_taxes_b_s.nextval                   , -- TAX_ID
          -99                                    , -- CONTENT_OWNER_ID
          NULL                                   , -- REP_TAX_AUTHORITY_ID
          NULL                                   , -- COLL_TAX_AUTHORITY_ID
          NULL                                   , -- THRSHLD_CHK_TMPLT_CODE
          NULL                                   , -- DEF_PRIMARY_REC_RATE_CODE
          NULL                                   , -- DEF_SECONDARY_REC_RATE_CODE
          fnd_global.user_id                     , -- CREATED_BY
          SYSDATE                                , -- CREATION_DATE
          fnd_global.user_id                     , -- LAST_UPDATED_BY
          SYSDATE                                , -- LAST_UPDATE_DATE
          fnd_global.conc_login_id               , -- LAST_UPDATE_LOGIN
          fnd_global.conc_request_id             , -- REQUEST_ID
          fnd_global.prog_appl_id                , -- PROGRAM_APPLICATION_ID
          fnd_global.conc_program_id             , -- PROGRAM_ID
          fnd_global.conc_login_id               , -- PROGRAM_LOGIN_ID
          p_tax_zone_type                        , -- OVERRIDE_GEOGRAPHY_TYPE
          1                                      , -- OBJECT_VERSION_NUMBER
          'CREATE_ACCOUNTS'                      , --TAX_ACCOUNT_CREATE_METHOD_CODE
          decode(l_tax,'STATE', NULL,'STATE')    , --TAX_ACCOUNT_SOURCE_TAX
          'CREATE_EXEMPTIONS'                    , --TAX_EXMPT_CR_METHOD_CODE
          NULL                                   ,
          'Y'                                      --APPLICABLE_BY_DEFAULT_FLAG
        );

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
          fl.LANGUAGE_CODE            ,
          USERENV('LANG')             ,
          l_tax                       ,
          fnd_global.user_id          , -- CREATED_BY
          SYSDATE                     , -- CREATION_DATE
          fnd_global.user_id          , -- LAST_UPDATED_BY
          SYSDATE                     , -- LAST_UPDATE_DATE
          fnd_global.conc_login_id    , -- LAST_UPDATE_LOGIN
          ztb.tax_id
        FROM ZX_TAXES_B ztb,
             FND_LANGUAGES fl
        WHERE fl.INSTALLED_FLAG IN ('I', 'B')
        AND   ztb.TAX_REGIME_CODE = p_tax_regime_code
        AND   ztb.CONTENT_OWNER_ID = -99
        AND   ztb.TAX = l_tax;

      END IF;

      l_exists_flag := 'N';
      OPEN c_tax_status_exists(p_tax_regime_code,l_tax,-99,'STANDARD');
      FETCH c_tax_status_exists
        INTO l_exists_flag;
      CLOSE c_tax_status_exists;

      IF (NVL(l_exists_flag,'N') = 'N')
      THEN

        FND_FILE.PUT_LINE
        (
          FND_FILE.LOG,
          'Creating STANDARD Status for Tax: '||l_tax||'.'
        );


        INSERT INTO ZX_STATUS_B_TMP
        (
          TAX_STATUS_ID,
          TAX_STATUS_CODE,
          CONTENT_OWNER_ID,
          EFFECTIVE_FROM,
          EFFECTIVE_TO,
          TAX,
          TAX_REGIME_CODE,
          RULE_BASED_RATE_FLAG,
          ALLOW_RATE_OVERRIDE_FLAG,
          ALLOW_EXEMPTIONS_FLAG,
          ALLOW_EXCEPTIONS_FLAG,
          DEFAULT_STATUS_FLAG,
          DEFAULT_FLG_EFFECTIVE_FROM,
          DEFAULT_FLG_EFFECTIVE_TO,
          DEF_REC_SETTLEMENT_OPTION_CODE,
          RECORD_TYPE_CODE,
          ATTRIBUTE1,
          ATTRIBUTE2,
          ATTRIBUTE3,
          ATTRIBUTE4,
          ATTRIBUTE5,
          ATTRIBUTE6,
          ATTRIBUTE7,
          ATTRIBUTE8,
          ATTRIBUTE9,
          ATTRIBUTE10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13,
          ATTRIBUTE14,
          ATTRIBUTE15,
          ATTRIBUTE_CATEGORY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          REQUEST_ID,
          OBJECT_VERSION_NUMBER
        )
        VALUES
        (
          ZX_STATUS_B_S.NEXTVAL,  --TAX_STATUS_ID
          'STANDARD',             --TAX_STATUS_CODE
          -99,                    --CONTENT_OWNER_ID
          G_RECORD_EFFECTIVE_START,--EFFECTIVE_FROM
          NULL,                   --EFFECTIVE_TO
          l_tax,                  --TAX
          p_tax_regime_code,      --TAX_REGIME_CODE
          'N',                    --RULE_BASED_RATE_FLAG
          'N',                    --ALLOW_RATE_OVERRIDE_FLAG
          'Y',                    --ALLOW_EXEMPTIONS_FLAG
          'Y',                    --ALLOW_EXCEPTIONS_FLAG
          'Y',                    --DEFAULT_STATUS_FLAG
          G_RECORD_EFFECTIVE_START,--DEFAULT_FLG_EFFECTIVE_FROM
          NULL,                   --DEFAULT_FLG_EFFECTIVE_TO
          NULL,                   --DEF_REC_SETTLEMENT_OPTION_CODE
          G_CREATED_BY_MODULE,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          NULL,
          SYSDATE,
          fnd_global.user_id,
          SYSDATE,
          fnd_global.user_id,
          fnd_global.conc_login_id,
          fnd_global.conc_request_id ,-- Request Id
          1
        );

        INSERT INTO ZX_STATUS_TL
        (
          LANGUAGE                    ,
          SOURCE_LANG                 ,
          TAX_STATUS_NAME             ,
          CREATED_BY                  ,
          CREATION_DATE               ,
          LAST_UPDATED_BY             ,
          LAST_UPDATE_DATE            ,
          LAST_UPDATE_LOGIN           ,
          TAX_STATUS_ID
        )
        SELECT
          fl.LANGUAGE_CODE            ,
          USERENV('LANG')             ,
          'STANDARD'                  ,
          fnd_global.user_id          , -- CREATED_BY
          SYSDATE                     , -- CREATION_DATE
          fnd_global.user_id          , -- LAST_UPDATED_BY
          SYSDATE                     , -- LAST_UPDATE_DATE
          fnd_global.conc_login_id    , -- LAST_UPDATE_LOGIN
          zsb.tax_status_id
        FROM ZX_STATUS_B zsb,
             FND_LANGUAGES fl
        WHERE fl.INSTALLED_FLAG IN ('I', 'B')
        AND   zsb.TAX_REGIME_CODE = p_tax_regime_code
        AND   zsb.CONTENT_OWNER_ID = -99
        AND   zsb.TAX = l_tax
        AND   zsb.TAX_STATUS_CODE = 'STANDARD';

      END IF;

    END LOOP;

    l_exists_flag := 'N';
    OPEN c_geography_type_exists(p_tax_zone_type);
    FETCH c_geography_type_exists
      INTO l_exists_flag;
    CLOSE c_geography_type_exists;

    IF (NVL(l_exists_flag,'N') = 'N')
    THEN

      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Creating Tax Zone Type: '||p_tax_zone_type||'.'
      );

      l_incl_geo_type(1) := 'COUNTY';
      l_incl_geo_type(2) := 'CITY';
      l_incl_geo_type(3) := 'STATE';
      l_zone_type_rec.geography_type := p_tax_zone_type;
      l_zone_type_rec.included_geography_type := l_incl_geo_type;
      l_zone_type_rec.postal_code_range_flag := 'Y';
      l_zone_type_rec.geography_use := 'TAX';
      l_zone_type_rec.limited_by_geography_id := 1;
      l_zone_type_rec.created_by_module := G_CREATED_BY_MODULE;
      l_zone_type_rec.application_id := 235;
      HZ_GEOGRAPHY_STRUCTURE_PUB.create_zone_type
      (
        'F',
        l_zone_type_rec,
        l_return_status,
        l_msg_count,
        l_msg_data
      );

      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Status returned by HZ_GEOGRAPHY_STRUCTURE_PUB.create_zone_type: '||l_return_status||', and message: '||l_msg_data
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        retcode := '2';
        errbuf := 'Error creating tax zone type: '||l_msg_data;
      END IF;

    END IF;

  END SETUP_DATA;

  --
  -- Method to find geography ids and stamp interface table
  --
  PROCEDURE GENERATE_GEOGRAPHY_ID
  (
    p_tax_content_source        IN VARCHAR2,
    p_tax_regime_code           IN VARCHAR2,
    p_migrated_tax_regime_flag  IN VARCHAR2,
    p_tax_zone_type             IN VARCHAR2,
    p_last_run_version          IN  NUMBER
  ) IS

    CURSOR C_CNTRY_ID IS
      SELECT GEOGRAPHY_ID
      FROM HZ_GEOGRAPHIES
      WHERE GEOGRAPHY_CODE = 'US'
      AND   GEOGRAPHY_TYPE = 'COUNTRY'
      AND   GEOGRAPHY_USE  = 'MASTER_REF';

    l_api_name           CONSTANT VARCHAR2(30):= 'generate_geography_id';
    l_rows_processed     NUMBER;
    l_start              NUMBER;
    l_end                NUMBER;
    l_cntry_geography_id NUMBER;
    l_log                VARCHAR2(2000);

    TYPE rowid_type IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
    TYPE geography_id_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_rowids             rowid_type;
    l_geography_ids      geography_id_type;
    l_rowcount           number;
    cursor c_get_city_rows
    (
      b_cntry_geography_id NUMBER
    ) IS
      SELECT DISTINCT
             X.ROWID,
             Y.GEOGRAPHY_ID
      FROM ZX_DATA_UPLOAD_INTERFACE X,
           HZ_GEOGRAPHIES Y,
           ZX_DATA_UPLOAD_INTERFACE Z,
           ZX_DATA_UPLOAD_INTERFACE ZZ
      WHERE X.RECORD_TYPE = 6
      AND   UPPER(Y.GEOGRAPHY_NAME) = UPPER(X.GEOGRAPHY_NAME)
      AND   Y.GEOGRAPHY_USE = 'MASTER_REF'
      AND   Y.GEOGRAPHY_TYPE = 'CITY'
      AND   Y.GEOGRAPHY_ELEMENT1_ID = b_cntry_geography_id
      AND   Y.GEOGRAPHY_ELEMENT2_ID = Z.GEOGRAPHY_ID
      AND   Z.RECORD_TYPE = 1
      AND   Z.STATE_JURISDICTION_CODE = X.STATE_JURISDICTION_CODE
      AND   Y.GEOGRAPHY_ELEMENT3_ID = ZZ.GEOGRAPHY_ID
      AND   ZZ.RECORD_TYPE = 3
      AND   ZZ.STATE_JURISDICTION_CODE = X.STATE_JURISDICTION_CODE
      AND   ZZ.COUNTY_JURISDICTION_CODE = X.COUNTY_JURISDICTION_CODE
      AND   NVL(Y.END_DATE, TO_DATE('12-31-4712', 'MM-DD-YYYY')) = TO_DATE('12-31-4712', 'MM-DD-YYYY');

  BEGIN

    OPEN C_CNTRY_ID;
    FETCH C_CNTRY_ID
      INTO l_cntry_geography_id;
    CLOSE C_CNTRY_ID;

    l_start := DBMS_UTILITY.GET_TIME;

    -- Find the state geography id using abbreviation code. Note that since we
    -- are using code, even the name change records will get the geography_id.
    update ZX_DATA_UPLOAD_INTERFACE  x
    set x.geography_id = (SELECT Y.GEOGRAPHY_ID
                          FROM HZ_GEOGRAPHIES Y
                          WHERE Y.GEOGRAPHY_NAME = X.COUNTRY_STATE_ABBREVIATION
                          AND   Y.GEOGRAPHY_CODE = X.COUNTRY_STATE_ABBREVIATION
                          AND   Y.COUNTRY_CODE = 'US'
                          AND   Y.GEOGRAPHY_TYPE = 'STATE'
                          AND   Y.GEOGRAPHY_USE = 'MASTER_REF'
                          AND   Y.GEOGRAPHY_ELEMENT1_ID = L_CNTRY_GEOGRAPHY_ID
                          AND   NVL(Y.END_DATE, TO_DATE('12-31-4712', 'MM-DD-YYYY'))
                                    = TO_DATE('12-31-4712', 'MM-DD-YYYY')),
        x.status       = 'NOCHANGE'
    where x.record_type = 1;

    l_rows_processed := SQL%ROWCOUNT;
    l_end := DBMS_UTILITY.GET_TIME;
    l_log := 'After State Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
    FND_FILE.PUT_LINE
    (
      FND_FILE.LOG,
      l_log
    );

    l_start := DBMS_UTILITY.GET_TIME;

    -- Now update the status of the name change record.
    update ZX_DATA_UPLOAD_INTERFACE  x
    set x.status       = 'UPDATE'
    where x.record_type = 1
    and   x.effective_to IS NULL
    and   exists (select null
                  from ZX_DATA_UPLOAD_INTERFACE y
                  where y.record_type = 1
                  and   y.state_jurisdiction_code = x.state_jurisdiction_code
                  and   y.country_state_abbreviation = x.country_state_abbreviation
                  and   y.effective_to IS NOT NULL);

    l_rows_processed := SQL%ROWCOUNT;
    l_end := DBMS_UTILITY.GET_TIME;
    l_log := 'After State Name Change Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
    FND_FILE.PUT_LINE
    (
      FND_FILE.LOG,
      l_log
    );

    l_start := DBMS_UTILITY.GET_TIME;

    -- Geography Id's for County for pre-existing geographies
    -- The state record could have been ended or it could have been sent twice
    -- with name change, so rownum clause is used.
    update ZX_DATA_UPLOAD_INTERFACE  x
    set x.geography_id = (SELECT Y.GEOGRAPHY_ID
                          FROM HZ_GEOGRAPHIES Y,
                               ZX_DATA_UPLOAD_INTERFACE Z
                          WHERE UPPER(Y.GEOGRAPHY_NAME) = UPPER(X.GEOGRAPHY_NAME)
                          AND   Y.GEOGRAPHY_USE = 'MASTER_REF'
                          AND   Y.GEOGRAPHY_TYPE = 'COUNTY'
                          AND   Y.GEOGRAPHY_ELEMENT1_ID = L_CNTRY_GEOGRAPHY_ID
                          AND   Y.GEOGRAPHY_ELEMENT2_ID = Z.GEOGRAPHY_ID
                          AND   Z.RECORD_TYPE = 1
                          AND   Z.STATE_JURISDICTION_CODE = X.STATE_JURISDICTION_CODE
                          AND   NVL(Y.END_DATE, TO_DATE('12-31-4712', 'MM-DD-YYYY'))
                                     = TO_DATE('12-31-4712', 'MM-DD-YYYY')
                          AND   rownum = 1),
        x.status       = 'NOCHANGE'
    where x.record_type = 3;

    l_rows_processed := SQL%ROWCOUNT;
    l_end := DBMS_UTILITY.GET_TIME;
    l_log := 'After County Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
    FND_FILE.PUT_LINE
    (
      FND_FILE.LOG,
      l_log
    );

    l_start := DBMS_UTILITY.GET_TIME;

    -- Geography Id's for County for pre-existing geographies, which had name
    -- change. Use existing record with old name to find the id.
    update ZX_DATA_UPLOAD_INTERFACE  x
    set x.geography_id = (SELECT Y.GEOGRAPHY_ID
                          FROM ZX_DATA_UPLOAD_INTERFACE y
                          WHERE y.record_type = 3
                          AND   y.STATE_JURISDICTION_CODE = x.STATE_JURISDICTION_CODE
                          AND   y.COUNTY_JURISDICTION_CODE = x.COUNTY_JURISDICTION_CODE
                          AND   y.geography_id is not null),
        x.status       = 'UPDATE'
    where x.record_type = 3
    and   x.geography_id is null
    and   x.effective_to is null;

    l_rows_processed := SQL%ROWCOUNT;
    l_end := DBMS_UTILITY.GET_TIME;
    l_log := 'After County Name Change Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
    FND_FILE.PUT_LINE
    (
      FND_FILE.LOG,
      l_log
    );

    l_start := DBMS_UTILITY.GET_TIME;

    -- Geography Id's for City for pre-existing geographies.
    -- This is for the case where a city is in a single county
    -- or city with multiple counties has been created as multiple geographies.
    -- rownum = 1 clause is used as the there could be multiple county
    -- or state records with different effective dates
/**
    update ZX_DATA_UPLOAD_INTERFACE  x
    set x.geography_id = (SELECT Y.GEOGRAPHY_ID
                          FROM HZ_GEOGRAPHIES Y,
                               ZX_DATA_UPLOAD_INTERFACE Z,
                               ZX_DATA_UPLOAD_INTERFACE ZZ
                          WHERE UPPER(Y.GEOGRAPHY_NAME) = UPPER(X.GEOGRAPHY_NAME)
                          AND   Y.GEOGRAPHY_USE = 'MASTER_REF'
                          AND   Y.GEOGRAPHY_TYPE = 'CITY'
                          AND   Y.GEOGRAPHY_ELEMENT1_ID = L_CNTRY_GEOGRAPHY_ID
                          AND   Y.GEOGRAPHY_ELEMENT2_ID = Z.GEOGRAPHY_ID
                          AND   Z.RECORD_TYPE = 1
                          AND   Z.STATE_JURISDICTION_CODE = X.STATE_JURISDICTION_CODE
                          AND   Y.GEOGRAPHY_ELEMENT3_ID = ZZ.GEOGRAPHY_ID
                          AND   ZZ.RECORD_TYPE = 3
                          AND   ZZ.STATE_JURISDICTION_CODE = X.STATE_JURISDICTION_CODE
                          AND   ZZ.COUNTY_JURISDICTION_CODE = X.COUNTY_JURISDICTION_CODE
                          AND   rownum = 1),
        x.status       = 'NOCHANGE'
    where x.record_type = 6;
    l_rows_processed := SQL%ROWCOUNT;
**/
    l_rowcount := 0;
    l_rows_processed := 0;
    open c_get_city_rows(l_cntry_geography_id);
    fetch c_get_city_rows
      bulk collect into l_rowids, l_geography_ids;
    l_rowcount := c_get_city_rows%rowcount;
    l_rows_processed := l_rows_processed + l_rowcount;
    forall i in l_rowids.first..l_rowids.last
      update zx_data_upload_interface
      set geography_id = l_geography_ids(i),
          status = 'NOCHANGE'
      where rowid = l_rowids(i);
    l_end := DBMS_UTILITY.GET_TIME;
    l_log := 'After City Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
    FND_FILE.PUT_LINE
    (
      FND_FILE.LOG,
      l_log
    );

    /*l_start := DBMS_UTILITY.GET_TIME;

    -- Geography Id's for City for pre-existing geographies, which had name
    -- change. Use existing record with old name to find the id.
    update ZX_DATA_UPLOAD_INTERFACE  x
    set x.geography_id = (SELECT Y.GEOGRAPHY_ID
                          FROM ZX_DATA_UPLOAD_INTERFACE y
                          WHERE y.record_type = 6
                          AND   y.STATE_JURISDICTION_CODE = x.STATE_JURISDICTION_CODE
                          AND   y.COUNTY_JURISDICTION_CODE = x.COUNTY_JURISDICTION_CODE
                          AND   y.CITY_JURISDICTION_CODE = x.CITY_JURISDICTION_CODE
                          AND   y.geography_id is not null
                          AND   rownum = 1),
        x.status       = 'UPDATE'
    where x.record_type = 6
    and   x.geography_id is null
    and   x.effective_to is null;

    l_rows_processed := SQL%ROWCOUNT;
    l_end := DBMS_UTILITY.GET_TIME;
    l_log := 'After City Name Change Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
    FND_FILE.PUT_LINE
    (
      FND_FILE.LOG,
      l_log
    );*/

    l_start := DBMS_UTILITY.GET_TIME;

    -- Get new id for new state and county
    update ZX_DATA_UPLOAD_INTERFACE
    set geography_id = hz_geographies_s.nextval,
        status       = 'CREATE'
    where record_type in (1,3)
    and   geography_id is null
    and   effective_to is null;

    l_rows_processed := SQL%ROWCOUNT;
    l_end := DBMS_UTILITY.GET_TIME;
    l_log := 'After new State and County Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
    FND_FILE.PUT_LINE
    (
      FND_FILE.LOG,
      l_log
    );

    l_start := DBMS_UTILITY.GET_TIME;

    -- Get new id for new city. In the case of city divided in two or more
    -- jurisdictions, get new id only for the first one
    update ZX_DATA_UPLOAD_INTERFACE
    set geography_id = hz_geographies_s.nextval,
        status       = 'CREATE'
    where record_type = 6
    and   geography_id is null
    and   effective_to is null
    and   (GEOGRAPHY_NAME,CITY_JURISDICTION_CODE,COUNTY_JURISDICTION_CODE,STATE_JURISDICTION_CODE)
          IN (SELECT GEOGRAPHY_NAME,
                     CITY_JURISDICTION_CODE,
                     COUNTY_JURISDICTION_CODE,
                     STATE_JURISDICTION_CODE
              FROM
                (SELECT GEOGRAPHY_NAME,
                        CITY_JURISDICTION_CODE,
                        COUNTY_JURISDICTION_CODE,
                        STATE_JURISDICTION_CODE,
                        GEOGRAPHY_ID,
                        ROW_NUMBER()
                          OVER (PARTITION BY STATE_JURISDICTION_CODE,COUNTY_JURISDICTION_CODE,GEOGRAPHY_NAME ORDER BY GEOGRAPHY_ID, EFFECTIVE_FROM) AS CITY_ROW_NUMBER
                 FROM ZX_DATA_UPLOAD_INTERFACE
                 WHERE RECORD_TYPE = 6
                 --AND   GEOGRAPHY_ID IS NULL
                 AND   EFFECTIVE_TO IS NULL)
              WHERE CITY_ROW_NUMBER = 1
              AND GEOGRAPHY_ID IS NULL);

    l_rows_processed := SQL%ROWCOUNT;
    l_end := DBMS_UTILITY.GET_TIME;
    l_log := 'After new City Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
    FND_FILE.PUT_LINE
    (
      FND_FILE.LOG,
      l_log
    );

    l_start := DBMS_UTILITY.GET_TIME;

    -- Use the id from previous step for multi jurisdiction cities
    update ZX_DATA_UPLOAD_INTERFACE a
    set geography_id = (select b.geography_id
                        from ZX_DATA_UPLOAD_INTERFACE b
                        where b.geography_name = a.geography_name
                        and   b.STATE_JURISDICTION_CODE = a.STATE_JURISDICTION_CODE
                        and   b.COUNTY_JURISDICTION_CODE = a.COUNTY_JURISDICTION_CODE
                        and   b.record_type = 6
                        and   b.geography_id IS NOT NULL),
        status       = 'NOCHANGE'
    where record_type = 6
    and   geography_id is null
    and   effective_to is null;

    l_rows_processed := SQL%ROWCOUNT;
    l_end := DBMS_UTILITY.GET_TIME;
    l_log := 'After new City 2nd Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
    FND_FILE.PUT_LINE
    (
      FND_FILE.LOG,
      l_log
    );

    l_start := DBMS_UTILITY.GET_TIME;

    -- Update a new geography id for all remaining cities.
    update ZX_DATA_UPLOAD_INTERFACE
    set geography_id = hz_geographies_s.nextval,
        status       = 'CREATE'
    where record_type = 6
    and   geography_id is null
    and   effective_to is null;

    l_rows_processed := SQL%ROWCOUNT;
    l_end := DBMS_UTILITY.GET_TIME;
    l_log := 'After new City 3rd Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
    FND_FILE.PUT_LINE
    (
      FND_FILE.LOG,
      l_log
    );

    l_start := DBMS_UTILITY.GET_TIME;

    -- Update the zip range with their corresponding city rows
    update ZX_DATA_UPLOAD_INTERFACE a
    set (geography_id,status) = (select b.geography_id,b.status
                                 from ZX_DATA_UPLOAD_INTERFACE b
                                 where b.STATE_JURISDICTION_CODE = a.STATE_JURISDICTION_CODE
                                 and   b.COUNTY_JURISDICTION_CODE = a.COUNTY_JURISDICTION_CODE
                                 and   b.CITY_JURISDICTION_CODE = a.CITY_JURISDICTION_CODE
                                 and   b.GEOGRAPHY_NAME = a.GEOGRAPHY_NAME
                                 and   b.effective_to is null
                                 and   b.record_type = 6
                                 and   rownum = 1)
    where record_type = 8
    and   geography_id is null
    and   effective_to is null;

    l_rows_processed := SQL%ROWCOUNT;
    l_end := DBMS_UTILITY.GET_TIME;
    l_log := 'After Zip Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
    FND_FILE.PUT_LINE
    (
      FND_FILE.LOG,
      l_log
    );

    -- The zone type used is different for migrated records and uploaded ones
    -- So, separate updates.

    IF (p_migrated_tax_regime_flag = 'Y')
    THEN

      l_start := DBMS_UTILITY.GET_TIME;

      -- First update the zone_geography_id for pre-existing states
      update ZX_DATA_UPLOAD_INTERFACE  x
      set x.zone_geography_id = (select y.geography_id from hz_geographies y
                                 where y.geography_name = DECODE(p_tax_content_source,
                                                          'TAXWARE','ST-'||x.COUNTRY_STATE_ABBREVIATION,
                                                          'ST-'||x.STATE_JURISDICTION_CODE||'0000000')
                                 and   y.GEOGRAPHY_TYPE = 'US_STATE_ZONE_TYPE_'||SUBSTRB(p_tax_regime_code, 14,10)
                                 and   NVL(y.END_DATE, TO_DATE('12-31-4712', 'MM-DD-YYYY'))
                                                = TO_DATE('12-31-4712', 'MM-DD-YYYY'))
      where x.record_type = 1
      and   x.zone_geography_id is null;
      /*and   EXISTS (select null
                    from ZX_DATA_UPLOAD_INTERFACE y
                    where y.STATE_JURISDICTION_CODE = x.STATE_JURISDICTION_CODE
                    and   y.COUNTY_JURISDICTION_CODE = x.COUNTY_JURISDICTION_CODE
                    and   y.CITY_JURISDICTION_CODE = x.CITY_JURISDICTION_CODE
                    and   y.record_type in (9,10,11,12));*/

      l_rows_processed := SQL%ROWCOUNT;
      l_end := DBMS_UTILITY.GET_TIME;
      l_log := 'After State Zone Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        l_log
      );

      l_start := DBMS_UTILITY.GET_TIME;

      -- First update the zone_geography_id for pre-existing counties
      update ZX_DATA_UPLOAD_INTERFACE  x
      set x.zone_geography_id = (select y.geography_id from hz_geographies y
                                 where y.geography_name = DECODE(p_tax_content_source,
                                                          'TAXWARE','CO-'||x.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(x.GEOGRAPHY_NAME,1,21)),
                                                          'CO-'||x.STATE_JURISDICTION_CODE||x.COUNTY_JURISDICTION_CODE||'0000')
                                 and   y.GEOGRAPHY_TYPE = 'US_COUNTY_ZONE_TYPE_'||SUBSTRB(p_tax_regime_code, 14,10)
                                 and   NVL(y.END_DATE, TO_DATE('12-31-4712', 'MM-DD-YYYY'))
                                                = TO_DATE('12-31-4712', 'MM-DD-YYYY'))
      where x.record_type = 3
      and   x.zone_geography_id is null;
      /*and   EXISTS (select null
                    from ZX_DATA_UPLOAD_INTERFACE y
                    where y.STATE_JURISDICTION_CODE = x.STATE_JURISDICTION_CODE
                    and   y.COUNTY_JURISDICTION_CODE = x.COUNTY_JURISDICTION_CODE
                    and   y.CITY_JURISDICTION_CODE = x.CITY_JURISDICTION_CODE
                    and   y.record_type in (9,10,11,12)); */

      l_rows_processed := SQL%ROWCOUNT;
      l_end := DBMS_UTILITY.GET_TIME;
      l_log := 'After County Zone Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        l_log
      );

      l_start := DBMS_UTILITY.GET_TIME;

      -- First update the zone_geography_id for pre-existing cities
      update ZX_DATA_UPLOAD_INTERFACE  x
      set x.zone_geography_id = (select y.geography_id from hz_geographies y
                                 where y.geography_name = DECODE(p_tax_content_source,
                                                          'TAXWARE','CI-'||x.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(x.GEOGRAPHY_NAME,1,12))||'-'||x.CITY_JURISDICTION_CODE,
                                                          'CI-'||x.STATE_JURISDICTION_CODE||x.COUNTY_JURISDICTION_CODE||LPAD(x.CITY_JURISDICTION_CODE,4,'0'))
                                 and   y.GEOGRAPHY_TYPE = 'US_CITY_ZONE_TYPE_'||SUBSTRB(p_tax_regime_code, 14,10)
                                 and   NVL(y.END_DATE, TO_DATE('12-31-4712', 'MM-DD-YYYY'))
                                                = TO_DATE('12-31-4712', 'MM-DD-YYYY'))
      where x.record_type = 6
      and   x.zone_geography_id is null;
      /*and   EXISTS (select null
                    from ZX_DATA_UPLOAD_INTERFACE y
                    where y.STATE_JURISDICTION_CODE = x.STATE_JURISDICTION_CODE
                    and   y.COUNTY_JURISDICTION_CODE = x.COUNTY_JURISDICTION_CODE
                    and   y.CITY_JURISDICTION_CODE = x.CITY_JURISDICTION_CODE
                    and   y.record_type in (9,10,11,12));*/

      l_rows_processed := SQL%ROWCOUNT;
      l_end := DBMS_UTILITY.GET_TIME;
      l_log := 'After City Zone Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        l_log
      );

      l_start := DBMS_UTILITY.GET_TIME;

      -- update the existing zone_geography_id for cities with same geocode
      update ZX_DATA_UPLOAD_INTERFACE  x
      set x.zone_geography_id = (select y.zone_geography_id
                                 from zx_data_upload_interface y
                                 where x.state_jurisdiction_code = y.state_jurisdiction_code
                                 and x.county_jurisdiction_code = y.county_jurisdiction_code
                                 and x.city_jurisdiction_code = y.city_jurisdiction_code
                                 and x.geography_name <> y.geography_name
                                 and y.zone_geography_id is not null
                                 and y.record_type = 6
                                 and rownum = 1
                                 )
      where x.record_type = 6
      and   x.zone_geography_id is null;

      l_rows_processed := SQL%ROWCOUNT;
      l_end := DBMS_UTILITY.GET_TIME;
      l_log := 'After City Zone Update 2, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        l_log
      );

      l_start := DBMS_UTILITY.GET_TIME;

      -- Now, update the zone_geography_id for new records for counties and states
      update ZX_DATA_UPLOAD_INTERFACE  x
      set x.zone_geography_id = hz_geographies_s.nextval
      where x.record_type IN (1,3)
      and   x.zone_geography_id is null
      and   x.effective_to is null;
      /*and   EXISTS (select null
                    from ZX_DATA_UPLOAD_INTERFACE y
                    where y.STATE_JURISDICTION_CODE = x.STATE_JURISDICTION_CODE
                    and   nvl(y.COUNTY_JURISDICTION_CODE,'-1') = nvl(x.COUNTY_JURISDICTION_CODE,'-1')
                    and   nvl(y.CITY_JURISDICTION_CODE,'-1') = nvl(x.CITY_JURISDICTION_CODE,'-1')
                    and   y.record_type in (9,10,11,12));*/

      l_rows_processed := SQL%ROWCOUNT;
      l_end := DBMS_UTILITY.GET_TIME;
      l_log := 'After new State/County Zone Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        l_log
      );

      l_start := DBMS_UTILITY.GET_TIME;

      -- Update the zone geography id for primary cities first.
      update ZX_DATA_UPLOAD_INTERFACE  x
      set x.zone_geography_id = hz_geographies_s.nextval
      where x.record_type = 6
      and   x.zone_geography_id is null
      and   x.effective_to is null
      and   x.primary_flag = 'Y';

      l_rows_processed := SQL%ROWCOUNT;
      l_end := DBMS_UTILITY.GET_TIME;
      l_log := 'After new Primary City Zone Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        l_log
      );

      l_start := DBMS_UTILITY.GET_TIME;

      -- Update the zone geography id for non primary cities.
      update ZX_DATA_UPLOAD_INTERFACE  x
      set x.zone_geography_id = (select y.zone_geography_id
                                 from zx_data_upload_interface y
                                 where x.state_jurisdiction_code = y.state_jurisdiction_code
                                 and x.county_jurisdiction_code = y.county_jurisdiction_code
                                 and x.city_jurisdiction_code = y.city_jurisdiction_code
                                 and x.geography_name <> y.geography_name
                                 and y.zone_geography_id is not null
                                 and y.record_type = 6
                                 and y.primary_flag = 'Y'
                                 and rownum = 1
                                 )
      where x.record_type = 6
      and   x.zone_geography_id is null
      and   x.effective_to is null
      and   x.primary_flag = 'N';

      l_rows_processed := SQL%ROWCOUNT;
      l_end := DBMS_UTILITY.GET_TIME;
      l_log := 'After new Non Primary City Zone Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        l_log
      );

      l_start := DBMS_UTILITY.GET_TIME;

      -- Now, update the zone_geography_id for override rates
      -- Update only the first row as there could be multiple rates for one
      -- overriding jurisdiction. First case is for city overriding state/county
      update ZX_DATA_UPLOAD_INTERFACE  x
      set x.zone_geography_id = (select y.geography_id from hz_geographies y
                                 where y.geography_name = DECODE(p_tax_content_source,
                                                          'TAXWARE','CI-'||x.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(x.GEOGRAPHY_NAME,1,12))||'-'||x.CITY_JURISDICTION_CODE,
                                                          'CI-'||x.STATE_JURISDICTION_CODE||x.COUNTY_JURISDICTION_CODE||LPAD(x.CITY_JURISDICTION_CODE,4,'0'))
                                 and   y.GEOGRAPHY_TYPE = 'US_OVERRIDE_ZONE_TYPE_'||SUBSTRB(p_tax_regime_code, 14,10)
                                 and   NVL(y.END_DATE, TO_DATE('12-31-4712', 'MM-DD-YYYY'))
                                                = TO_DATE('12-31-4712', 'MM-DD-YYYY'))
      where x.record_type IN (9,10,11,12)
      and   x.zone_geography_id is null
      and   x.STATE_JURISDICTION_CODE is not null
      and   x.COUNTY_JURISDICTION_CODE is not null
      and   x.CITY_JURISDICTION_CODE is not null
      and   x.rowid
            IN (select row_id
                from (
                      select ROWID as row_id,
                             record_type,
                             state_jurisdiction_code,
                             county_jurisdiction_code,
                             city_jurisdiction_code,
                             ROW_NUMBER()
                              OVER (PARTITION BY STATE_JURISDICTION_CODE,COUNTY_JURISDICTION_CODE,CITY_JURISDICTION_CODE ORDER BY ROWID) AS ROW_NUMBER
                      from ZX_DATA_UPLOAD_INTERFACE
                      where record_type IN (9,10,11,12)
                      and   last_updation_version > p_last_run_version
                      and   state_jurisdiction_code is not null
                      and   county_jurisdiction_code is not null
                      and   city_jurisdiction_code is not null
                      and   (sales_tax_authority_level = 'STATE'
                             or sales_tax_authority_level = 'COUNTY'
                             or rental_tax_authority_level = 'STATE'
                             or rental_tax_authority_level = 'COUNTY'
                             or use_tax_authority_level = 'STATE'
                             or use_tax_authority_level = 'COUNTY'
                             or lease_tax_authority_level = 'STATE'
                             or lease_tax_authority_level = 'COUNTY')
                     )
                where row_number = 1
               );

      l_rows_processed := SQL%ROWCOUNT;
      l_end := DBMS_UTILITY.GET_TIME;
      l_log := 'After City Override Zone Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        l_log
      );

      l_start := DBMS_UTILITY.GET_TIME;

      -- Now, update the zone_geography_id for override rates
      -- Update only the first row as there could be multiple rates for one
      -- overriding jurisdiction
      update ZX_DATA_UPLOAD_INTERFACE  x
      set x.zone_geography_id = hz_geographies_s.nextval
      where x.record_type IN (9,10,11,12)
      and   x.zone_geography_id is null
      and   x.STATE_JURISDICTION_CODE is not null
      and   x.COUNTY_JURISDICTION_CODE is not null
      and   x.CITY_JURISDICTION_CODE is not null
      and   x.rowid
            IN (select row_id
                from (
                      select ROWID as row_id,
                             record_type,
                             state_jurisdiction_code,
                             county_jurisdiction_code,
                             city_jurisdiction_code,
                             ROW_NUMBER()
                              OVER (PARTITION BY STATE_JURISDICTION_CODE,COUNTY_JURISDICTION_CODE,CITY_JURISDICTION_CODE ORDER BY ROWID) AS ROW_NUMBER
                      from ZX_DATA_UPLOAD_INTERFACE
                      where record_type IN (9,10,11,12)
                      and   last_updation_version > p_last_run_version
                      and   state_jurisdiction_code is not null
                      and   county_jurisdiction_code is not null
                      and   city_jurisdiction_code is not null
                      and   (sales_tax_authority_level = 'STATE'
                             or sales_tax_authority_level = 'COUNTY'
                             or rental_tax_authority_level = 'STATE'
                             or rental_tax_authority_level = 'COUNTY'
                             or use_tax_authority_level = 'STATE'
                             or use_tax_authority_level = 'COUNTY'
                             or lease_tax_authority_level = 'STATE'
                             or lease_tax_authority_level = 'COUNTY')
                     )
                where row_number = 1
               );

      l_rows_processed := SQL%ROWCOUNT;
      l_end := DBMS_UTILITY.GET_TIME;
      l_log := 'After new City Override Zone Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        l_log
      );

      l_start := DBMS_UTILITY.GET_TIME;

      -- Now, update the zone_geography_id for override rates
      -- Update only the first row as there could be multiple rates for one
      -- overriding jurisdiction. First case is for county overriding state
      update ZX_DATA_UPLOAD_INTERFACE  x
      set x.zone_geography_id = (select y.geography_id from hz_geographies y
                                 where y.geography_name = DECODE(p_tax_content_source,
                                                          'TAXWARE','CO-'||x.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(x.GEOGRAPHY_NAME,1,21)),
                                                          'CO-'||x.STATE_JURISDICTION_CODE||x.COUNTY_JURISDICTION_CODE||'0000')
                                 and   y.GEOGRAPHY_TYPE = 'US_OVERRIDE_ZONE_TYPE_'||SUBSTRB(p_tax_regime_code, 14,10)
                                 and   NVL(y.END_DATE, TO_DATE('12-31-4712', 'MM-DD-YYYY'))
                                                = TO_DATE('12-31-4712', 'MM-DD-YYYY'))
      where x.record_type IN (9,10,11,12)
      and   x.zone_geography_id is null
      and   x.STATE_JURISDICTION_CODE is not null
      and   x.COUNTY_JURISDICTION_CODE is not null
      and   x.CITY_JURISDICTION_CODE is null
      and   x.rowid
            IN (select row_id
                from (
                      select ROWID as row_id,
                             record_type,
                             state_jurisdiction_code,
                             county_jurisdiction_code,
                             ROW_NUMBER()
                              OVER (PARTITION BY STATE_JURISDICTION_CODE,COUNTY_JURISDICTION_CODE ORDER BY ROWID) AS ROW_NUMBER
                      from ZX_DATA_UPLOAD_INTERFACE
                      where record_type IN (9,10,11,12)
                      and   last_updation_version > p_last_run_version
                      and   state_jurisdiction_code is not null
                      and   county_jurisdiction_code is not null
                      and   city_jurisdiction_code is null
                      and   (sales_tax_authority_level = 'STATE'
                             or rental_tax_authority_level = 'STATE'
                             or use_tax_authority_level = 'STATE'
                             or lease_tax_authority_level = 'STATE')
                     )
                where row_number = 1
               );

      l_rows_processed := SQL%ROWCOUNT;
      l_end := DBMS_UTILITY.GET_TIME;
      l_log := 'After County Override Zone Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        l_log
      );

      l_start := DBMS_UTILITY.GET_TIME;

      -- Now, update the zone_geography_id for override rates
      -- Update only the first row as there could be multiple rates for one
      -- overriding jurisdiction
      update ZX_DATA_UPLOAD_INTERFACE  x
      set x.zone_geography_id = hz_geographies_s.nextval
      where x.record_type IN (9,10,11,12)
      and   x.zone_geography_id is null
      and   x.STATE_JURISDICTION_CODE is not null
      and   x.COUNTY_JURISDICTION_CODE is not null
      and   x.CITY_JURISDICTION_CODE is null
      and   x.rowid
            IN (select row_id
                from (
                      select ROWID as row_id,
                             record_type,
                             state_jurisdiction_code,
                             county_jurisdiction_code,
                             ROW_NUMBER()
                              OVER (PARTITION BY STATE_JURISDICTION_CODE,COUNTY_JURISDICTION_CODE ORDER BY ROWID) AS ROW_NUMBER
                      from ZX_DATA_UPLOAD_INTERFACE
                      where record_type IN (9,10,11,12)
                      and   last_updation_version > p_last_run_version
                      and   state_jurisdiction_code is not null
                      and   county_jurisdiction_code is not null
                      and   city_jurisdiction_code is null
                      and   (sales_tax_authority_level = 'STATE'
                             or rental_tax_authority_level = 'STATE'
                             or use_tax_authority_level = 'STATE'
                             or lease_tax_authority_level = 'STATE')
                     )
                where row_number = 1
               );

      l_rows_processed := SQL%ROWCOUNT;
      l_end := DBMS_UTILITY.GET_TIME;
      l_log := 'After new County Override Zone Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        l_log
      );

    ELSE

      l_start := DBMS_UTILITY.GET_TIME;

      -- First update the zone_geography_id for pre-existing cities,
      update ZX_DATA_UPLOAD_INTERFACE  x
      set x.zone_geography_id = (select y.geography_id from hz_geographies y
                                 where y.geography_name = DECODE(p_tax_content_source,
                                                          'TAXWARE','CI-'||x.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(x.GEOGRAPHY_NAME,1,12))||'-'||x.CITY_JURISDICTION_CODE,
                                                          'CI-'||x.STATE_JURISDICTION_CODE||x.COUNTY_JURISDICTION_CODE||LPAD(x.CITY_JURISDICTION_CODE,4,'0'))
                                 and   y.GEOGRAPHY_USE = 'TAX'
                                 and   y.GEOGRAPHY_TYPE = p_tax_zone_type
                                 and   NVL(y.END_DATE, TO_DATE('12-31-4712', 'MM-DD-YYYY'))
                                                = TO_DATE('12-31-4712', 'MM-DD-YYYY'))
      where x.record_type = 6
      and   x.zone_geography_id is null;
      /*and   EXISTS (select null
                    from ZX_DATA_UPLOAD_INTERFACE y
                    where y.STATE_JURISDICTION_CODE = x.STATE_JURISDICTION_CODE
                    and   y.COUNTY_JURISDICTION_CODE = x.COUNTY_JURISDICTION_CODE
                    and   y.CITY_JURISDICTION_CODE = x.CITY_JURISDICTION_CODE
                    and   y.record_type in (9,10,11,12));*/

      l_rows_processed := SQL%ROWCOUNT;
      l_end := DBMS_UTILITY.GET_TIME;
      l_log := 'After City Zone Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        l_log
      );

      l_start := DBMS_UTILITY.GET_TIME;

      -- update the zone_geography_id for cities
      update ZX_DATA_UPLOAD_INTERFACE  x
      set x.zone_geography_id = (select y.zone_geography_id
                                 from zx_data_upload_interface y
                                 where x.state_jurisdiction_code = y.state_jurisdiction_code
                                 and x.county_jurisdiction_code = y.county_jurisdiction_code
                                 and x.city_jurisdiction_code = y.city_jurisdiction_code
                                 and x.geography_name <> y.geography_name
                                 and y.zone_geography_id is not null
                                 and y.record_type = 6
                                 and rownum = 1
                                 )
      where x.record_type = 6
      and   x.zone_geography_id is null;

      l_rows_processed := SQL%ROWCOUNT;
      l_end := DBMS_UTILITY.GET_TIME;
      l_log := 'After City Zone Update 2, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        l_log
      );

      l_start := DBMS_UTILITY.GET_TIME;

      -- Now, update the zone_geography_id for new records,
      update ZX_DATA_UPLOAD_INTERFACE  x
      set x.zone_geography_id = hz_geographies_s.nextval
      where x.record_type = 6
      and   x.zone_geography_id is null
      and   x.effective_to is null
      and   x.primary_flag = 'Y';
      /*and   EXISTS (select null
                    from ZX_DATA_UPLOAD_INTERFACE y
                    where y.STATE_JURISDICTION_CODE = x.STATE_JURISDICTION_CODE
                    and   y.COUNTY_JURISDICTION_CODE = x.COUNTY_JURISDICTION_CODE
                    and   y.CITY_JURISDICTION_CODE = x.CITY_JURISDICTION_CODE
                    and   y.record_type in (9,10,11,12));*/

      l_rows_processed := SQL%ROWCOUNT;
      l_end := DBMS_UTILITY.GET_TIME;
      l_log := 'After new Primary City Zone Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        l_log
      );

      update ZX_DATA_UPLOAD_INTERFACE  x
      set x.zone_geography_id = (select y.zone_geography_id
                                 from zx_data_upload_interface y
                                 where x.state_jurisdiction_code = y.state_jurisdiction_code
                                 and x.county_jurisdiction_code = y.county_jurisdiction_code
                                 and x.city_jurisdiction_code = y.city_jurisdiction_code
                                 and x.geography_name <> y.geography_name
                                 and y.zone_geography_id is not null
                                 and y.record_type = 6
                                 and y.primary_flag = 'Y'
                                 and rownum = 1
                                 )
      where x.record_type = 6
      and   x.zone_geography_id is null
      and   x.effective_to is null
      and   x.primary_flag = 'N';

      l_rows_processed := SQL%ROWCOUNT;
      l_end := DBMS_UTILITY.GET_TIME;
      l_log := 'After new City Zone Update, rows processed:'||l_rows_processed||', in time (ms):'||to_char((l_end-l_start)*10);
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        l_log
      );

    END IF;

  END GENERATE_GEOGRAPHY_ID;

  --
  -- Procedure to do error check
  --
  PROCEDURE DO_ERROR_CHECK
  (
    p_tax_content_source        IN  VARCHAR2,
    p_last_run_version          IN  NUMBER,
    p_tax_regime_code           IN  VARCHAR2,
    p_migrated_tax_regime_flag  IN  VARCHAR2
  ) IS

    CURSOR c_get_zip
    IS
      SELECT ROWID as row_id,
             city_jurisdiction_code,
             county_jurisdiction_code,
             state_jurisdiction_code,
             state_jurisdiction_code||county_jurisdiction_code||city_jurisdiction_code||geography_name concat_code,
             zip_begin,
             zip_end
      FROM  zx_data_upload_interface
      WHERE record_type = 08
      AND   last_updation_version > p_last_run_version
      AND   effective_to IS NULL;

    CURSOR c_get_rates
    IS
      SELECT
        v1.row_id,
        v1.record_type,
        v1.city_jurisdiction_code,
        v1.county_jurisdiction_code,
        v1.state_jurisdiction_code,
        v1.tax_regime_code,
        v1.tax,
        v1.content_owner_id,
        v1.tax_status_code,
        v1.tax_jurisdiction_code,
        v1.tax_rate_code,
        v1.effective_from new_effective_from,
        v1.effective_to new_effective_to,
        v1.active_flag new_active_flag,
        v1.rate_type_code,
        v1.percentage_rate,
        v1.jur_effective_from,
        zrb.tax_rate_id,
        zrb.effective_from old_effective_from,
        zrb.effective_to old_effective_to,
        zrb.active_flag old_active_flag,
        zrb.record_type_code record_type_code
      FROM (
        SELECT v.rowid as row_id,
               v.record_type,
               v.city_jurisdiction_code,
               v.county_jurisdiction_code,
               v.state_jurisdiction_code,
               v.tax_regime_code,
               v.tax,
               v.content_owner_id,
               v.tax_status_code,
               decode(p_tax_content_source,
                      'TAXWARE',decode(v.tax,'STATE',
                        decode(to_char(jur.record_type),'1','ST-'||v.COUNTRY_STATE_ABBREVIATION,
                          '3','ST-CO-'||v.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,21)),
                          '6','ST-CI-'||v.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,12))||'-'||v.city_jurisdiction_code),
                        'COUNTY',decode(to_char(jur.record_type),
                          '3','CO-'||v.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,21)),
                          '6','CO-CI-'||v.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,12))||'-'||v.city_jurisdiction_code),
                        'CITY','CI-'||v.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,12))||'-'||v.city_jurisdiction_code),
                      DECODE(v.tax,'STATE',
                        decode(to_char(jur.record_type),'1','ST-','3','ST-CO-','6','ST-CI-'),
                        'COUNTY',decode(to_char(jur.record_type),'3','CO-','6','CO-CI-'),'CITY','CI-')||
                        v.state_jurisdiction_code||nvl(v.county_jurisdiction_code,'000')||lpad(nvl(v.city_jurisdiction_code,'0000'),4,'0')
                     ) tax_jurisdiction_code,
               v.tax_rate_code,
               v.effective_from,
               v.effective_to,
               v.active_flag,
               v.rate_type_code,
               v.percentage_rate,
               jur.effective_from jur_effective_from
        FROM
            (SELECT x.row_id,
                    x.record_type,
                    x.country_state_abbreviation,
                    x.city_jurisdiction_code,
                    x.county_jurisdiction_code,
                    x.state_jurisdiction_code,
                    x.tax_regime_code,
                    x.tax,
                    x.content_owner_id,
                    x.tax_status_code,
                    x.tax_rate_code,
                    x.effective_from,
                    x.effective_to,
                    x.rate_type_code,
                    x.percentage_rate,
                    x.active_flag,
                    ROW_NUMBER()
                     OVER(PARTITION BY x.RECORD_TYPE,
                                       x.STATE_JURISDICTION_CODE,
                                       x.COUNTY_JURISDICTION_CODE,
                                       x.CITY_JURISDICTION_CODE,
                                       x.TAX,
                                       x.ACTIVE_FLAG
                                       ORDER BY x.EFFECTIVE_FROM ASC)
                     AS rate_row_num
             FROM
                (SELECT rowid row_id,
                   record_type,
                   country_state_abbreviation,
                   city_jurisdiction_code,
                   county_jurisdiction_code,
                   state_jurisdiction_code,
                   p_tax_regime_code tax_regime_code,
                   decode(to_char(record_type),'9',sales_tax_authority_level,'10',rental_tax_authority_level,'11',use_tax_authority_level,'12',lease_tax_authority_level) tax,
                   -99 content_owner_id,
                   'STANDARD' tax_status_code,
                   decode(p_migrated_tax_regime_flag,'Y','STANDARD','STD')||decode(to_char(record_type),'10','-RENTAL','11','-USE','12','-LEASE') tax_rate_code,
                   effective_from,
                   effective_to,
                   'PERCENTAGE' rate_type_code,
                   decode(record_type,9,sales_tax_rate,10,rental_tax_rate,11,use_tax_rate,12,lease_tax_rate) percentage_rate,
                   decode(to_char(record_type),'9',sales_tax_rate_active_flag,'10',rental_tax_rate_active_flag,'11',use_tax_rate_active_flag,'12',lease_tax_rate_active_flag) active_flag
                 FROM
                    zx_data_upload_interface
                 WHERE record_type in (9,10,11,12)
                 AND   last_updation_version > p_last_run_version
                ) x
            ) v,
            zx_data_upload_interface jur
        WHERE v.rate_row_num = 1
        AND   jur.record_type = decode(v.city_jurisdiction_code,null,decode(v.county_jurisdiction_code,null,1,3),6)
        AND   jur.state_jurisdiction_code = v.state_jurisdiction_code
        AND   NVL(jur.county_jurisdiction_code,'-1') = NVL(v.county_jurisdiction_code,'-1')
        AND   NVL(jur.city_jurisdiction_code,'-1') = NVL(v.city_jurisdiction_code,'-1')
        AND   NVL(jur.primary_flag,'Y') = 'Y'
        AND   jur.effective_to IS NULL) v1,
        ZX_RATES_B zrb
      WHERE zrb.tax_regime_code(+) = v1.tax_regime_code
      AND   zrb.tax(+) = v1.tax
      AND   zrb.content_owner_id(+) = v1.content_owner_id
      AND   zrb.tax_jurisdiction_code(+) = v1.tax_jurisdiction_code
      AND   zrb.tax_rate_code(+) = v1.tax_rate_code;

    -- Cursor to find duplicates in the set-up
    -- Added for Bug#7527399
    CURSOR c_get_dup_rates
    IS
    SELECT
        v1.row_id                   row_id,
        v1.record_type              record_type,
        v1.state_jurisdiction_code  state_jurisdiction_code,
        v1.county_jurisdiction_code county_jurisdiction_code,
        v1.city_jurisdiction_code   city_jurisdiction_code,
        v1.tax                      data_upload_tax,
        v1.tax_jurisdiction_code    data_upload_jurisdiction_code,
        v1.tax_rate_code            data_upload_tax_rate_code,
        v1.effective_from           data_upload_effective_from,
        v1.active_flag              data_upload_active_flag,
        zrb.tax_regime_code         tax_regime_code,
        zrb.tax                     tax,
        zrb.tax_status_code         tax_status_code,
        zrb.tax_jurisdiction_code   tax_jurisdiction_code,
        zrb.effective_from          effective_from,
        zrb.active_flag             active_flag
    FROM (
        SELECT v.rowid as row_id,
               v.record_type,
               v.city_jurisdiction_code,
               v.county_jurisdiction_code,
               v.state_jurisdiction_code,
               v.tax,
               v.content_owner_id,
               DECODE(p_tax_content_source,
                      'TAXWARE',DECODE(v.tax,
                                'STATE',DECODE(to_char(jur.record_type),'1','ST-'||v.COUNTRY_STATE_ABBREVIATION,
                                '3','ST-CO-'||v.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,21)),
                                '6','ST-CI-'||v.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,12))||'-'||v.city_jurisdiction_code),
                                'COUNTY',decode(to_char(jur.record_type),
                                '3','CO-'||v.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,21)),
                                '6','CO-CI-'||v.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,12))||'-'||v.city_jurisdiction_code),
                                'CITY','CI-'||v.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,12))||'-'||v.city_jurisdiction_code),
                      DECODE(v.tax,
                             'STATE',decode(to_char(jur.record_type),'1','ST-','3','ST-CO-','6','ST-CI-'),
                             'COUNTY',decode(to_char(jur.record_type),'3','CO-','6','CO-CI-'),
                             'CITY','CI-')||v.state_jurisdiction_code||nvl(v.county_jurisdiction_code,'000')||lpad(nvl(v.city_jurisdiction_code,'0000'),4,'0')
                     ) tax_jurisdiction_code,
               v.tax_rate_code,
               v.effective_from,
               v.active_flag
        FROM
            (SELECT x.row_id,
                    x.record_type,
                    x.country_state_abbreviation,
                    x.city_jurisdiction_code,
                    x.county_jurisdiction_code,
                    x.state_jurisdiction_code,
                    x.tax,
                    x.content_owner_id,
                    x.tax_rate_code,
                    x.effective_from,
                    x.active_flag,
                    ROW_NUMBER()
                     OVER(PARTITION BY x.RECORD_TYPE,
                                       x.STATE_JURISDICTION_CODE,
                                       x.COUNTY_JURISDICTION_CODE,
                                       x.CITY_JURISDICTION_CODE,
                                       x.TAX,
                                       x.ACTIVE_FLAG
                                       ORDER BY x.EFFECTIVE_FROM ASC)
                     AS rate_row_num
             FROM
                (SELECT rowid row_id,
                   record_type,
                   country_state_abbreviation,
                   city_jurisdiction_code,
                   county_jurisdiction_code,
                   state_jurisdiction_code,
                   decode(to_char(record_type),'9',sales_tax_authority_level,'10',rental_tax_authority_level,'11',use_tax_authority_level,'12',lease_tax_authority_level) tax,
                   -99 content_owner_id,
                   decode(p_migrated_tax_regime_flag,'Y','STANDARD','STD')||decode(to_char(record_type),'10','-RENTAL','11','-USE','12','-LEASE') tax_rate_code,
                   effective_from,
                   decode(to_char(record_type),'9',sales_tax_rate_active_flag,'10',rental_tax_rate_active_flag,'11',use_tax_rate_active_flag,'12',lease_tax_rate_active_flag) active_flag
                 FROM zx_data_upload_interface
                 WHERE record_type in (9,10,11,12)
                 AND NVL(status,'CREATE') <> 'ERROR'
                 AND last_updation_version > p_last_run_version
                ) x
            ) v,
            zx_data_upload_interface jur
        WHERE v.rate_row_num = 1
        AND   jur.record_type = DECODE(v.city_jurisdiction_code,NULL,DECODE(v.county_jurisdiction_code,NULL,1,3),6)
        AND   jur.state_jurisdiction_code = v.state_jurisdiction_code
        AND   NVL(jur.county_jurisdiction_code,'-1') = NVL(v.county_jurisdiction_code,'-1')
        AND   NVL(jur.city_jurisdiction_code,'-1') = NVL(v.city_jurisdiction_code,'-1')
        AND   NVL(jur.primary_flag,'Y') = 'Y'
        AND   jur.effective_to IS NULL) v1,
        ZX_RATES_B zrb
      WHERE zrb.content_owner_id = v1.content_owner_id
      AND   zrb.tax_jurisdiction_code = v1.tax_jurisdiction_code
      AND   zrb.tax_rate_code = v1.tax_rate_code
      AND   zrb.active_flag = v1.active_flag
      AND   zrb.effective_from = v1.effective_from
      AND   zrb.tax_class IS NULL
      AND   zrb.recovery_type_code IS NULL
      AND   zrb.tax_regime_code <> p_tax_regime_code;

    -- Cursor to find duplicates in the data-file
    -- Added for Bug#7527399
    CURSOR c_file_dup IS
    SELECT v2.row_id,
           v2.record_type,
           v2.country_code,
           v2.state_jurisdiction_code,
           v2.county_jurisdiction_code,
           v2.city_jurisdiction_code,
           v2.tax,
           v2.effective_from,
           v2.active_flag,
           v2.rec_cnt
    FROM   ( SELECT v.row_id,
                    v.record_type,
                    v.country_code,
                    v.state_jurisdiction_code,
                    v.county_jurisdiction_code,
                    v.city_jurisdiction_code,
                    v.tax,
                    v.effective_from,
                    v.active_flag,
                    Count(v.row_id) OVER(PARTITION BY v.record_type,
                                                      v.state_jurisdiction_code,
                                                      v.county_jurisdiction_code,
                                                      v.city_jurisdiction_code,
                                                      v.tax,
                                                      v.effective_from,
                                                      v.active_flag
                                             ORDER BY v.effective_from ASC) AS rec_cnt
            FROM   ( SELECT ROWID row_id,
                            record_type,
                            country_code,
                            state_jurisdiction_code,
                            county_jurisdiction_code,
                            city_jurisdiction_code,
                            DECODE(to_char(record_type),'9',sales_tax_authority_level,'10',rental_tax_authority_level,'11',use_tax_authority_level,'12',lease_tax_authority_level) tax,
                            effective_from,
                            DECODE(TO_CHAR(record_type),'9',sales_tax_rate_active_flag,'10',rental_tax_rate_active_flag,'11',use_tax_rate_active_flag,'12',lease_tax_rate_active_flag) active_flag
                      FROM  zx_data_upload_interface
                      WHERE record_type in (9,10,11,12)
                      AND   NVL(status,'CREATE') <> 'ERROR' ) v,
                    zx_data_upload_interface v1
            WHERE  v1.record_type = DECODE(v.city_jurisdiction_code,NULL,DECODE(v.county_jurisdiction_code,NULL,1,3),6)
            AND    v1.state_jurisdiction_code = v.state_jurisdiction_code
            AND    NVL(v1.county_jurisdiction_code,'-1') = NVL(v.county_jurisdiction_code,'-1')
            AND    NVL(v1.city_jurisdiction_code,'-1') = NVL(v.city_jurisdiction_code,'-1')
            AND    NVL(v1.primary_flag,'Y') = 'Y'
            AND    v1.effective_to IS NULL ) v2
    WHERE  v2.rec_cnt > 1;

    TYPE l_number_tbl_typ IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    l_previous_concat_code    VARCHAR2(60);
    l_previous_zip_begin      l_number_tbl_typ;
    l_previous_zip_end        l_number_tbl_typ;
    l_count                   NUMBER;
    l_msg                     VARCHAR2(240);
    l_dup_rec_count           NUMBER;        -- Added for Bug#7527399

    -- Start : Added for Bug#7298430
    TYPE l_date_tbl_typ  IS TABLE OF DATE  INDEX BY BINARY_INTEGER;
    TYPE l_rowid_tbl_typ IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
    TYPE l_varchar_1_tbl_typ   IS TABLE OF VARCHAR2(1)   INDEX BY BINARY_INTEGER;
    TYPE l_varchar_60_tbl_typ  IS TABLE OF VARCHAR2(60)  INDEX BY BINARY_INTEGER;
    TYPE l_varchar_240_tbl_typ IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;

    TYPE l_rates_rec_type IS RECORD
    (
      tax_rate_id     l_number_tbl_typ,
      active_flag     l_varchar_1_tbl_typ,
      effective_from  l_date_tbl_typ,
      effective_to    l_date_tbl_typ
    );

    TYPE l_upload_rec_type IS RECORD
    (
      row_id          l_rowid_tbl_typ,
      status          l_varchar_60_tbl_typ,
      log_msg         l_varchar_240_tbl_typ
    );

    l_rates_count    NUMBER;
    l_upload_count   NUMBER;
    l_rates_rec      l_rates_rec_type;
    l_upload_rec     l_upload_rec_type;
    -- End : Added for Bug#7298430

  BEGIN

    FND_FILE.PUT_LINE
    (
      FND_FILE.OUTPUT,
      'Starting validation.'
    );
    -- Initializing count variables
    l_count := 0;
    l_rates_count   := 1;
    l_upload_count  := 1;
    l_dup_rec_count := 0;         -- Added for Bug#7527399
    -- Check for zip overlap
    FOR ref_zip IN c_get_zip
    LOOP
      IF (ref_zip.concat_code <> NVL(l_previous_concat_code,' '))
      THEN
        l_previous_zip_begin.DELETE;
        l_previous_zip_end.DELETE;
        l_count := 1;
        l_previous_zip_begin(l_count) := ref_zip.zip_begin;
        l_previous_zip_end(l_count) := ref_zip.zip_end;
      ELSE
        FOR i IN 1..l_count
        LOOP
          IF ((ref_zip.zip_begin BETWEEN l_previous_zip_begin(i) AND l_previous_zip_end(i)) OR
             (l_previous_zip_begin(i) BETWEEN ref_zip.zip_begin AND ref_zip.zip_end))
          THEN
            l_msg := 'Overlapping zip range exists for the state: '||ref_zip.state_jurisdiction_code||', county: '||ref_zip.county_jurisdiction_code||', city : '||ref_zip.city_jurisdiction_code||'.';
            /* Commented for Bug#7298430
            UPDATE zx_data_upload_interface
            SET STATUS = 'ERROR',
                ERROR_MESSAGE = l_msg
            WHERE ROWID = ref_zip.row_id;
            FND_FILE.PUT_LINE
            (
              FND_FILE.OUTPUT,
              l_msg
            );*/
            l_upload_rec.log_msg(l_upload_count) := l_msg;
            l_upload_rec.row_id(l_upload_count)  := ref_zip.row_id;
            l_upload_rec.status(l_upload_count)  := 'ERROR';

            l_upload_count := l_upload_count + 1;
          END IF;
        END LOOP;
      END IF;
      l_previous_zip_begin(l_count) := ref_zip.zip_begin;
      l_previous_zip_end(l_count) := ref_zip.zip_end;
      l_previous_concat_code := ref_zip.concat_code;
    END LOOP;

    -- Check for rates overlap
    FOR ref_rates IN c_get_rates
    LOOP
      -- Rates date not in tax zone date
      /*IF (ref_rates.new_effective_from < ref_rates.jur_effective_from)
      THEN
        l_msg := 'The '||ref_rates.tax;
        IF (ref_rates.record_type = 9)
        THEN
          l_msg := l_msg||' Sales';
        ELSIF (ref_rates.record_type = 10)
        THEN
          l_msg := l_msg||' Rental';
        ELSIF (ref_rates.record_type = 11)
        THEN
          l_msg := l_msg||' Use';
        ELSIF (ref_rates.record_type = 12)
        THEN
          l_msg := l_msg||' Lease';
        END IF;
        l_msg := l_msg||' tax rate record for state: '||ref_rates.state_jurisdiction_code;
        IF (ref_rates.county_jurisdiction_code IS NOT NULL)
        THEN
          l_msg := l_msg||', county: '||ref_rates.county_jurisdiction_code;
        END IF;
        IF (ref_rates.city_jurisdiction_code IS NOT NULL)
        THEN
          l_msg := l_msg||', city: '||ref_rates.city_jurisdiction_code;
        END IF;
        l_msg := l_msg||' has effective date of '||to_char(ref_rates.new_effective_from,'MM/DD/YYYY')||', which is earlier than the tax zone''s effective date '||to_char(ref_rates.jur_effective_from,'MM/DD/YYYY')||'.';
        UPDATE zx_data_upload_interface
        SET STATUS = 'ERROR',
            ERROR_MESSAGE = l_msg
        WHERE ROWID = ref_rates.row_id;
        FND_FILE.PUT_LINE
        (
          FND_FILE.OUTPUT,
          l_msg
        );
      END IF; */

      -- Overlap
      IF ((ref_rates.new_effective_from <> ref_rates.old_effective_from) AND
         (ref_rates.new_active_flag = 'Y') AND (ref_rates.old_active_flag = 'Y') AND
         ((ref_rates.new_effective_from BETWEEN ref_rates.old_effective_from AND NVL(ref_rates.old_effective_to,TO_DATE('12/31/4712','MM/DD/YYYY'))) OR
         (ref_rates.old_effective_from BETWEEN ref_rates.new_effective_from AND NVL(ref_rates.new_effective_to,TO_DATE('12/31/4712','MM/DD/YYYY')))))
      THEN
        -- Start : Added for Bug#7298430
        IF ref_rates.record_type_code = 'MIGRATED' THEN
          IF ref_rates.new_effective_from BETWEEN ref_rates.old_effective_from AND NVL(ref_rates.old_effective_to,TO_DATE('12/31/4712','MM/DD/YYYY'))
          THEN
            -- End date Old rate i.e. Update the effective_to of Old Rate to (new_effective_from - 1)
            l_rates_rec.tax_rate_id(l_rates_count)    :=  ref_rates.tax_rate_id;
            l_rates_rec.effective_from(l_rates_count) :=  ref_rates.old_effective_from;
            l_rates_rec.effective_to(l_rates_count)   :=  ref_rates.new_effective_from - 1;
            l_rates_rec.active_flag(l_rates_count)    :=  ref_rates.old_active_flag;
            l_msg := 'An Upgraded '||ref_rates.tax;
            IF (ref_rates.record_type = 9)
            THEN
              l_msg := l_msg||' Sales';
            ELSIF (ref_rates.record_type = 10)
            THEN
              l_msg := l_msg||' Rental';
            ELSIF (ref_rates.record_type = 11)
            THEN
              l_msg := l_msg||' Use';
            ELSIF (ref_rates.record_type = 12)
            THEN
              l_msg := l_msg||' Lease';
            END IF;
            l_msg := l_msg||' tax rate for the state: '||ref_rates.state_jurisdiction_code;
            IF (ref_rates.county_jurisdiction_code IS NOT NULL)
            THEN
              l_msg := l_msg||', county: '||ref_rates.county_jurisdiction_code;
            END IF;
            IF (ref_rates.city_jurisdiction_code IS NOT NULL)
            THEN
              l_msg := l_msg||', city: '||ref_rates.city_jurisdiction_code;
            END IF;
            l_msg := l_msg||' has been End-Dated to '||TO_CHAR(ref_rates.new_effective_from - 1,'DD-MON-YYYY')||'.';
            l_upload_rec.log_msg(l_upload_count) := l_msg;
            l_upload_rec.row_id(l_upload_count)  := ref_rates.row_id;
            l_upload_rec.status(l_upload_count)  := '';

            l_rates_count  := l_rates_count + 1;
            l_upload_count := l_upload_count + 1;

          ELSIF ref_rates.old_effective_from BETWEEN ref_rates.new_effective_from AND NVL(ref_rates.new_effective_to,TO_DATE('12/31/4712','MM/DD/YYYY'))
          THEN
            -- Update the effective_from of Old rate to new_effective_from
            l_rates_rec.tax_rate_id(l_rates_count)    :=  ref_rates.tax_rate_id;
            l_rates_rec.effective_from(l_rates_count) :=  ref_rates.old_effective_from;
            l_rates_rec.effective_to(l_rates_count)   :=  ref_rates.old_effective_to;
            l_rates_rec.active_flag(l_rates_count)    :=  'N';
            l_msg := 'An Upgraded '||ref_rates.tax;
            IF (ref_rates.record_type = 9)
            THEN
              l_msg := l_msg||' Sales';
            ELSIF (ref_rates.record_type = 10)
            THEN
              l_msg := l_msg||' Rental';
            ELSIF (ref_rates.record_type = 11)
            THEN
              l_msg := l_msg||' Use';
            ELSIF (ref_rates.record_type = 12)
            THEN
              l_msg := l_msg||' Lease';
            END IF;
            l_msg := l_msg||' tax rate for the state: '||ref_rates.state_jurisdiction_code;
            IF (ref_rates.county_jurisdiction_code IS NOT NULL)
            THEN
              l_msg := l_msg||', county: '||ref_rates.county_jurisdiction_code;
            END IF;
            IF (ref_rates.city_jurisdiction_code IS NOT NULL)
            THEN
              l_msg := l_msg||', city: '||ref_rates.city_jurisdiction_code;
            END IF;
            l_msg := l_msg||' with Effective-From '||TO_CHAR(ref_rates.old_effective_from,'DD-MON-YYYY');
            l_msg := l_msg||' has been disabled.';
            l_upload_rec.log_msg(l_upload_count) := l_msg;
            l_upload_rec.row_id(l_upload_count)  := ref_rates.row_id;
            l_upload_rec.status(l_upload_count)  := '';

            l_rates_count  := l_rates_count + 1;
            l_upload_count := l_upload_count + 1;
          END IF;
        -- End : Added for Bug#7298430
        ELSE
          l_msg := 'An active '||ref_rates.tax;
          IF (ref_rates.record_type = 9)
          THEN
            l_msg := l_msg||' Sales';
          ELSIF (ref_rates.record_type = 10)
          THEN
            l_msg := l_msg||' Rental';
          ELSIF (ref_rates.record_type = 11)
          THEN
            l_msg := l_msg||' Use';
          ELSIF (ref_rates.record_type = 12)
          THEN
            l_msg := l_msg||' Lease';
          END IF;
          l_msg := l_msg||' tax rate already exists for the state: '||ref_rates.state_jurisdiction_code;
          IF (ref_rates.county_jurisdiction_code IS NOT NULL)
          THEN
            l_msg := l_msg||', county: '||ref_rates.county_jurisdiction_code;
          END IF;
          IF (ref_rates.city_jurisdiction_code IS NOT NULL)
          THEN
            l_msg := l_msg||', city: '||ref_rates.city_jurisdiction_code;
          END IF;
          l_msg := l_msg||'.';
          /* -- Commented for Bug#7298430
          UPDATE zx_data_upload_interface
          SET STATUS = 'ERROR',
              ERROR_MESSAGE = l_msg
          WHERE ROWID = ref_rates.row_id;
          FND_FILE.PUT_LINE
           (
            FND_FILE.OUTPUT,
            l_msg
           );*/
          l_upload_rec.log_msg(l_upload_count) := l_msg;
          l_upload_rec.row_id(l_upload_count)  := ref_rates.row_id;
          l_upload_rec.status(l_upload_count)  := 'ERROR';

          l_upload_count := l_upload_count + 1;
        END IF;
      END IF;

      -- End dated by user
      IF ((ref_rates.new_effective_from = ref_rates.old_effective_from) AND
         (ref_rates.new_active_flag = 'N') AND (ref_rates.old_active_flag = 'N'))
      THEN
        l_msg := 'The '||ref_rates.tax;
        IF (ref_rates.record_type = 9)
        THEN
          l_msg := l_msg||' Sales';
        ELSIF (ref_rates.record_type = 10)
        THEN
          l_msg := l_msg||' Rental';
        ELSIF (ref_rates.record_type = 11)
        THEN
          l_msg := l_msg||' Use';
        ELSIF (ref_rates.record_type = 12)
        THEN
          l_msg := l_msg||' Lease';
        END IF;
        l_msg := l_msg||' tax rate record for state: '||ref_rates.state_jurisdiction_code;
        IF (ref_rates.county_jurisdiction_code IS NOT NULL)
        THEN
          l_msg := l_msg||', county: '||ref_rates.county_jurisdiction_code;
        END IF;
        IF (ref_rates.city_jurisdiction_code IS NOT NULL)
        THEN
          l_msg := l_msg||', city: '||ref_rates.city_jurisdiction_code;
        END IF;
        l_msg := l_msg||' has already been ended by user.';
        /* -- Commented for Bug#7298430
        UPDATE zx_data_upload_interface
        SET STATUS = 'ERROR',
            ERROR_MESSAGE = l_msg
        WHERE ROWID = ref_rates.row_id;
        FND_FILE.PUT_LINE
        (
          FND_FILE.OUTPUT,
          l_msg
        );*/
        l_upload_rec.log_msg(l_upload_count) := l_msg;
        l_upload_rec.row_id(l_upload_count)  := ref_rates.row_id;
        l_upload_rec.status(l_upload_count)  := 'ERROR';

        l_upload_count := l_upload_count + 1;
      END IF;
    END LOOP;

    -- Start : Added for Bug#7298430
    FORALL i IN INDICES OF l_rates_rec.tax_rate_id
      UPDATE zx_rates_b_tmp
         SET active_flag = l_rates_rec.active_flag(i),
             effective_from = l_rates_rec.effective_from(i),
             effective_to   = l_rates_rec.effective_to(i),
             default_flg_effective_from = l_rates_rec.effective_from(i),
             default_flg_effective_to   = l_rates_rec.effective_to(i)
       WHERE tax_rate_id    = l_rates_rec.tax_rate_id(i);
    -- End : Added for Bug#7298430

    -- Start : Added for Bug#7527399
    -- Added to check the duplicates in the existing set-up
    FOR dup_rates_rec IN c_get_dup_rates
    LOOP
      l_msg := 'Duplicate record for '||dup_rates_rec.data_upload_tax;
      IF (dup_rates_rec.record_type = 9)
      THEN
        l_msg := l_msg||' Sales';
      ELSIF (dup_rates_rec.record_type = 10)
      THEN
        l_msg := l_msg||' Rental';
      ELSIF (dup_rates_rec.record_type = 11)
      THEN
        l_msg := l_msg||' Use';
      ELSIF (dup_rates_rec.record_type = 12)
      THEN
        l_msg := l_msg||' Lease';
      END IF;

      l_msg := l_msg||' tax rate exists for state: '||dup_rates_rec.state_jurisdiction_code;
      IF (dup_rates_rec.county_jurisdiction_code IS NOT NULL)
      THEN
        l_msg := l_msg||', county: '||dup_rates_rec.county_jurisdiction_code;
      END IF;
      IF (dup_rates_rec.city_jurisdiction_code IS NOT NULL)
      THEN
        l_msg := l_msg||', city: '||dup_rates_rec.city_jurisdiction_code;
      END IF;

      l_msg := l_msg||' for Tax-Regime: '||dup_rates_rec.tax_regime_code;
      l_msg := l_msg||'. Please check your Tax Set-up.';

      l_upload_rec.log_msg(l_upload_count) := l_msg;
      l_upload_rec.row_id(l_upload_count)  := dup_rates_rec.row_id;
      l_upload_rec.status(l_upload_count)  := 'ERROR';
      l_upload_count := l_upload_count + 1;
      l_dup_rec_count := l_dup_rec_count + 1;
    END LOOP;

    IF l_dup_rec_count = 0 THEN
      -- Added to check the duplicates in the data-file
      FOR dup_file_rec IN c_file_dup
      LOOP
        l_msg := 'Duplicate record for '||dup_file_rec.tax;
        IF (dup_file_rec.record_type = 9)
        THEN
          l_msg := l_msg||' Sales';
        ELSIF (dup_file_rec.record_type = 10)
        THEN
          l_msg := l_msg||' Rental';
        ELSIF (dup_file_rec.record_type = 11)
        THEN
          l_msg := l_msg||' Use';
        ELSIF (dup_file_rec.record_type = 12)
        THEN
          l_msg := l_msg||' Lease';
        END IF;

        l_msg := l_msg||' tax rate exists for state: '||dup_file_rec.state_jurisdiction_code;
        IF (dup_file_rec.county_jurisdiction_code IS NOT NULL)
        THEN
          l_msg := l_msg||', county: '||dup_file_rec.county_jurisdiction_code;
        END IF;
        IF (dup_file_rec.city_jurisdiction_code IS NOT NULL)
        THEN
          l_msg := l_msg||', city: '||dup_file_rec.city_jurisdiction_code;
        END IF;

        l_msg := l_msg||' in the Data-File. Please contact your Tax Service Provider.';

        l_upload_rec.log_msg(l_upload_count) := l_msg;
        l_upload_rec.row_id(l_upload_count)  := dup_file_rec.row_id;
        l_upload_rec.status(l_upload_count)  := 'ERROR';
        l_upload_count := l_upload_count + 1;
        l_dup_rec_count := l_dup_rec_count + 1;
      END LOOP;
    END IF;
    -- End : Added for Bug#7527399

    -- Start : Added for Bug#7298430
    FORALL i IN INDICES OF l_upload_rec.row_id
      UPDATE zx_data_upload_interface
         SET STATUS = l_upload_rec.status(i),
             ERROR_MESSAGE = l_upload_rec.log_msg(i)
       WHERE ROWID = l_upload_rec.row_id(i);

    FOR i IN NVL(l_upload_rec.log_msg.FIRST,0)..NVL(l_upload_rec.log_msg.LAST,-99)
    LOOP
      FND_FILE.PUT_LINE
      (
         FND_FILE.OUTPUT,
         l_upload_rec.log_msg(i)
      );
    END LOOP;
    -- End : Added for Bug#7298430

    FND_FILE.PUT_LINE
    (
      FND_FILE.OUTPUT,
      'Validation Complete.'
    );

    -- Added for Bug#7527399
    -- If there are any duplicates, then stop the Data Upload program and raise error.
    IF l_dup_rec_count > 0 THEN
       RAISE_APPLICATION_ERROR(-20001,'E-Business Tax cannot upload the file as duplicate records are present. Please see the output file for details.');
    END IF;

  END DO_ERROR_CHECK;

  --
  -- Procedure to create master reference geography
  --
  PROCEDURE CREATE_GEOGRAPHY
  (
    errbuf               OUT NOCOPY VARCHAR2,
    retcode              OUT NOCOPY VARCHAR2,
    p_batch_size         IN  NUMBER,
    p_worker_id          IN  NUMBER,
    p_num_workers        IN  NUMBER,
    p_tax_content_source IN  VARCHAR2,
    p_last_run_version   IN  NUMBER
  ) IS

    l_api_name           CONSTANT VARCHAR2(30):= 'create_geography';

    -----------------------------------------------------
    -- Ad parallelization variables
    -----------------------------------------------------
    l_table_owner         VARCHAR2(30) := 'ZX';
    l_any_rows_to_process BOOLEAN;
    l_table_name          VARCHAR2(30) := 'ZX_DATA_UPLOAD_INTERFACE';
    l_start_rowid         ROWID;
    l_end_rowid           ROWID;
    l_rows_processed      NUMBER;


  BEGIN

    retcode := '0';

    /*-- Initialize the rowid ranges
    --
    ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           l_table_owner,
           l_table_name,
           l_api_name,
           p_Worker_Id,
           p_Num_Workers,
           p_batch_size,
           0);
    --
    -- Get rowid ranges
    --
    ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           p_batch_size,
           TRUE);

    WHILE (l_any_rows_to_process)
    LOOP*/

      INSERT ALL
        WHEN (action_type = 'CREATE' AND existing_geography_id IS NULL AND geography_id IS NOT NULL AND geography_type IS NOT NULL) THEN
          INTO HZ_GEOGRAPHIES
            (
             GEOGRAPHY_ID,
             OBJECT_VERSION_NUMBER,
             GEOGRAPHY_TYPE,
             GEOGRAPHY_NAME,
             GEOGRAPHY_USE,
             GEOGRAPHY_CODE,
             START_DATE,
             END_DATE,
             MULTIPLE_PARENT_FLAG,
             geography_element1,
             geography_element1_id,
             geography_element1_code,
             geography_element2,
             geography_element2_id,
             geography_element2_code,
             geography_element3,
             geography_element3_id,
             geography_element4,
             geography_element4_id,
             geography_element4_code,
             CREATED_BY_MODULE,
             COUNTRY_CODE,
             TIMEZONE_CODE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
            )
          VALUES
            (
             geography_id,
             1,
             geography_type,
             geography_name,
             'MASTER_REF',
             geography_code,
             start_date,
             end_date,
             'N',
             geography_element1,
             geography_element1_id,
             geography_element1_code,
             geography_element2,
             geography_element2_id,
             geography_element2_code,
             geography_element3,
             geography_element3_id,
             geography_element4,
             geography_element4_id,
             geography_element4_code,
             G_CREATED_BY_MODULE,
             country_code,
             'PST',
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id
            )
          INTO HZ_GEOGRAPHY_IDENTIFIERS
            (
             GEOGRAPHY_ID,
             GEO_DATA_PROVIDER,
             IDENTIFIER_SUBTYPE,
             IDENTIFIER_VALUE,
             OBJECT_VERSION_NUMBER,
             IDENTIFIER_TYPE,
             PRIMARY_FLAG,
             LANGUAGE_CODE,
             GEOGRAPHY_USE,
             GEOGRAPHY_TYPE,
             CREATED_BY_MODULE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
            )
          VALUES
            (
             geography_id,
             p_tax_content_source,
             'STANDARD_NAME',
             geography_name,
             1,
             'NAME',
             'Y',
             'US',
             'MASTER_REF',
             geography_type,
             G_CREATED_BY_MODULE,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id
            )
          --Self
          INTO hz_hierarchy_nodes
            (
             HIERARCHY_TYPE,
             PARENT_ID,
             PARENT_TABLE_NAME,
             PARENT_OBJECT_TYPE,
             CHILD_ID,
             CHILD_TABLE_NAME,
             CHILD_OBJECT_TYPE,
             LEVEL_NUMBER,
             TOP_PARENT_FLAG,
             LEAF_CHILD_FLAG,
             EFFECTIVE_START_DATE,
             EFFECTIVE_END_DATE,
             STATUS,
             RELATIONSHIP_ID,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             ACTUAL_CONTENT_SOURCE
            )
          VALUES
            (
             'MASTER_REF',
             geography_id,
             'HZ_GEOGRAPHIES',
             geography_type,
             geography_id,
             'HZ_GEOGRAPHIES',
             geography_type,
             0  ,
             'N',
             'Y',
             start_date,
             end_date,
             'A',
             null,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id,
             p_tax_content_source
            )
        WHEN (action_type = 'UPDATE' AND geography_type = 'STATE' AND geography_name1 IS NOT NULL) THEN
          INTO HZ_GEOGRAPHY_IDENTIFIERS
            (
             GEOGRAPHY_ID,
             GEO_DATA_PROVIDER,
             IDENTIFIER_SUBTYPE,
             IDENTIFIER_VALUE,
             OBJECT_VERSION_NUMBER,
             IDENTIFIER_TYPE,
             PRIMARY_FLAG,
             LANGUAGE_CODE,
             GEOGRAPHY_USE,
             GEOGRAPHY_TYPE,
             CREATED_BY_MODULE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
            )
          VALUES
            (
             geography_id,
             p_tax_content_source,
             'STANDARD_NAME',
             geography_name1,
             1,
             'NAME',
             'N',
             'US',
             'MASTER_REF',
             geography_type,
             G_CREATED_BY_MODULE,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id
            )
        WHEN (action_type = 'UPDATE' AND geography_type IN ('COUNTY','CITY') AND geography_name IS NOT NULL) THEN
          INTO HZ_GEOGRAPHY_IDENTIFIERS
            (
             GEOGRAPHY_ID,
             GEO_DATA_PROVIDER,
             IDENTIFIER_SUBTYPE,
             IDENTIFIER_VALUE,
             OBJECT_VERSION_NUMBER,
             IDENTIFIER_TYPE,
             PRIMARY_FLAG,
             LANGUAGE_CODE,
             GEOGRAPHY_USE,
             GEOGRAPHY_TYPE,
             CREATED_BY_MODULE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
            )
          VALUES
            (
             geography_id,
             p_tax_content_source,
             'STANDARD_NAME',
             geography_name,
             1,
             'NAME',
             'N',
             'US',
             'MASTER_REF',
             geography_type,
             G_CREATED_BY_MODULE,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id
            )
        WHEN (action_type = 'CREATE' AND geography_type = 'STATE' AND geography_name1 IS NOT NULL) THEN
          INTO HZ_GEOGRAPHY_IDENTIFIERS
            (
             GEOGRAPHY_ID,
             GEO_DATA_PROVIDER,
             IDENTIFIER_SUBTYPE,
             IDENTIFIER_VALUE,
             OBJECT_VERSION_NUMBER,
             IDENTIFIER_TYPE,
             PRIMARY_FLAG,
             LANGUAGE_CODE,
             GEOGRAPHY_USE,
             GEOGRAPHY_TYPE,
             CREATED_BY_MODULE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
            )
          VALUES
            (
             geography_id,
             p_tax_content_source,
             'FIPS_CODE',
             geography_name,
             1,
             'CODE',
             'Y',
             'US',
             'MASTER_REF',
             geography_type,
             G_CREATED_BY_MODULE,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id
            )
          INTO HZ_GEOGRAPHY_IDENTIFIERS
            (
             GEOGRAPHY_ID,
             GEO_DATA_PROVIDER,
             IDENTIFIER_SUBTYPE,
             IDENTIFIER_VALUE,
             OBJECT_VERSION_NUMBER,
             IDENTIFIER_TYPE,
             PRIMARY_FLAG,
             LANGUAGE_CODE,
             GEOGRAPHY_USE,
             GEOGRAPHY_TYPE,
             CREATED_BY_MODULE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
            )
          VALUES
            (
             geography_id,
             p_tax_content_source,
             'STANDARD_NAME',
             geography_name1,
             1,
             'NAME',
             'N',
             'US',
             'MASTER_REF',
             geography_type,
             G_CREATED_BY_MODULE,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id
            )
        WHEN (action_type = 'CREATE') THEN
          INTO HZ_RELATIONSHIPS
            (
             RELATIONSHIP_ID,
             SUBJECT_ID,
             SUBJECT_TYPE,
             SUBJECT_TABLE_NAME,
             OBJECT_ID,
             OBJECT_TYPE,
             OBJECT_TABLE_NAME,
             RELATIONSHIP_CODE,
             DIRECTIONAL_FLAG,
             COMMENTS,
             START_DATE,
             END_DATE,
             STATUS,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             CONTENT_SOURCE_TYPE,
             RELATIONSHIP_TYPE,
             OBJECT_VERSION_NUMBER,
             CREATED_BY_MODULE,
             APPLICATION_ID,
             DIRECTION_CODE,
             PERCENTAGE_OWNERSHIP,
             ACTUAL_CONTENT_SOURCE
            )
          VALUES
            (
             hz_relationships_s.nextval,
             parent_geography_id,
             parent_geography_type,
             'HZ_GEOGRAPHIES',
             geography_id,
             geography_type,
             'HZ_GEOGRAPHIES',
             'PARENT_OF',
             'F',
             null,
             start_date,
             end_date,
             'A',
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id,
             G_CREATED_BY_MODULE,
             'MASTER_REF',
             1,
             G_CREATED_BY_MODULE,
             null,
             'P',
             null,
             p_tax_content_source
            )
          INTO HZ_RELATIONSHIPS
            (
             RELATIONSHIP_ID,
             SUBJECT_ID,
             SUBJECT_TYPE,
             SUBJECT_TABLE_NAME,
             OBJECT_ID,
             OBJECT_TYPE,
             OBJECT_TABLE_NAME,
             RELATIONSHIP_CODE,
             DIRECTIONAL_FLAG,
             COMMENTS,
             START_DATE,
             END_DATE,
             STATUS,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             CONTENT_SOURCE_TYPE,
             RELATIONSHIP_TYPE,
             OBJECT_VERSION_NUMBER,
             CREATED_BY_MODULE,
             APPLICATION_ID,
             DIRECTION_CODE,
             PERCENTAGE_OWNERSHIP,
             ACTUAL_CONTENT_SOURCE
            )
          VALUES
            (
             hz_relationships_s.nextval,
             geography_id,
             geography_type,
             'HZ_GEOGRAPHIES',
             parent_geography_id,
             parent_geography_type,
             'HZ_GEOGRAPHIES',
             'CHILD_OF',
             'B',
             null,
             start_date,
             end_date,
             'A',
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id,
             G_CREATED_BY_MODULE,
             'MASTER_REF',
             1,
             G_CREATED_BY_MODULE,
             null,
             'C',
             null,
             p_tax_content_source
            )
          --Immediate Parent
          INTO hz_hierarchy_nodes
            (
             HIERARCHY_TYPE,
             PARENT_ID,
             PARENT_TABLE_NAME,
             PARENT_OBJECT_TYPE,
             CHILD_ID,
             CHILD_TABLE_NAME,
             CHILD_OBJECT_TYPE,
             LEVEL_NUMBER,
             TOP_PARENT_FLAG,
             LEAF_CHILD_FLAG,
             EFFECTIVE_START_DATE,
             EFFECTIVE_END_DATE,
             STATUS,
             RELATIONSHIP_ID,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             ACTUAL_CONTENT_SOURCE
            )
          VALUES
            (
             'MASTER_REF',
             parent_geography_id,
             'HZ_GEOGRAPHIES',
             parent_geography_type,
             geography_id,
             'HZ_GEOGRAPHIES',
             geography_type,
             1,
             '',
             '',
             start_date,
             end_date,
             'A',
             hz_relationships_s.nextval,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id,
             p_tax_content_source
            )
        WHEN (action_type = 'CREATE' AND geography_type = 'COUNTY') THEN
          INTO hz_hierarchy_nodes
            (
             HIERARCHY_TYPE,
             PARENT_ID,
             PARENT_TABLE_NAME,
             PARENT_OBJECT_TYPE,
             CHILD_ID,
             CHILD_TABLE_NAME,
             CHILD_OBJECT_TYPE,
             LEVEL_NUMBER,
             TOP_PARENT_FLAG,
             LEAF_CHILD_FLAG,
             EFFECTIVE_START_DATE,
             EFFECTIVE_END_DATE,
             STATUS,
             RELATIONSHIP_ID,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             ACTUAL_CONTENT_SOURCE
            )
          VALUES
            (
             'MASTER_REF',
             geography_element1_id,
             'HZ_GEOGRAPHIES',
             geography_element1_type,
             geography_id,
             'HZ_GEOGRAPHIES',
             geography_type,
             2  ,
             '',
             '',
             start_date,
             end_date,
             'A',
             null  ,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id,
             p_tax_content_source
            )
        WHEN (action_type = 'CREATE' AND geography_type = 'CITY') THEN
          INTO hz_hierarchy_nodes
            (
             HIERARCHY_TYPE,
             PARENT_ID,
             PARENT_TABLE_NAME,
             PARENT_OBJECT_TYPE,
             CHILD_ID,
             CHILD_TABLE_NAME,
             CHILD_OBJECT_TYPE,
             LEVEL_NUMBER,
             TOP_PARENT_FLAG,
             LEAF_CHILD_FLAG,
             EFFECTIVE_START_DATE,
             EFFECTIVE_END_DATE,
             STATUS,
             RELATIONSHIP_ID,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             ACTUAL_CONTENT_SOURCE
            )
          VALUES
            (
             'MASTER_REF',
             geography_element2_id,
             'HZ_GEOGRAPHIES',
             geography_element2_type,
             geography_id,
             'HZ_GEOGRAPHIES',
             geography_type,
             2  ,
             '',
             '',
             start_date,
             end_date,
             'A',
             null  ,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id,
             p_tax_content_source
            )
          INTO hz_hierarchy_nodes
            (
             HIERARCHY_TYPE,
             PARENT_ID,
             PARENT_TABLE_NAME,
             PARENT_OBJECT_TYPE,
             CHILD_ID,
             CHILD_TABLE_NAME,
             CHILD_OBJECT_TYPE,
             LEVEL_NUMBER,
             TOP_PARENT_FLAG,
             LEAF_CHILD_FLAG,
             EFFECTIVE_START_DATE,
             EFFECTIVE_END_DATE,
             STATUS,
             RELATIONSHIP_ID,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             ACTUAL_CONTENT_SOURCE
            )
          VALUES
            (
             'MASTER_REF',
             geography_element1_id,
             'HZ_GEOGRAPHIES',
             geography_element1_type,
             geography_id,
             'HZ_GEOGRAPHIES',
             geography_type,
             3  ,
             '',
             '',
             start_date,
             end_date,
             'A',
             null  ,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id,
             p_tax_content_source
            )
        select geography_id,
               geography_name,
               geography_code,
               geography_type,
               parent_geography_id,
               parent_geography_name,
               parent_geography_type,
               geography_element1_id,
               geography_element1,
               geography_element1_code,
               geography_element1_type,
               geography_element2_id,
               geography_element2,
               geography_element2_code,
               geography_element2_type,
               geography_element3_id,
               geography_element3,
               geography_element3_code,
               geography_element3_type,
               geography_element4_id,
               geography_element4,
               geography_element4_code,
               geography_element4_type,
               geography_name1,
               multiple_parent_flag,
               start_date,
               end_date,
               country_code,
	       CASE WHEN status = 'CREATE'
                 THEN
                   'CREATE'
                 WHEN status = 'UPDATE' AND
                   'EXISTS' = (SELECT 'EXISTS'
                               FROM HZ_GEOGRAPHY_IDENTIFIERS hgi
                               WHERE hgi.geography_id = v.geography_id
                               AND   hgi.identifier_type = 'NAME'
                               AND   hgi.identifier_subtype = 'STANDARD_NAME'
                               AND   UPPER(hgi.identifier_value) = UPPER(DECODE(geography_type,'STATE',geography_name1,geography_name)))
                 THEN
                   'NOCHANGE'
                 WHEN status = 'UPDATE'
                 THEN
                   'UPDATE'
                 ELSE
                   NULL END as action_type,
               existing_geography_id
        FROM
        (
          SELECT state.geography_id geography_id,
                 state.country_state_abbreviation geography_name,
                 state.country_state_abbreviation geography_code,
                 'STATE' geography_type,
                 1 parent_geography_id,
                 'United States' parent_geography_name,
                 'COUNTRY' parent_geography_type,
                 1 geography_element1_id,
                 'United States' geography_element1,
                 'US' geography_element1_code,
                 'COUNTRY' geography_element1_type,
                 state.geography_id geography_element2_id,
                 state.country_state_abbreviation geography_element2,
                 state.country_state_abbreviation geography_element2_code,
                 'STATE' geography_element2_type,
                 null geography_element3_id,
                 null geography_element3 ,
                 null geography_element3_code,
                 null geography_element3_type,
                 null geography_element4_id,
                 null geography_element4,
                 null geography_element4_code,
                 null geography_element4_type,
                 state.geography_name geography_name1,
                 state.multiple_parent_flag,
                 state.effective_from start_date,
                 nvl(state.effective_to,to_date('12/31/4712','mm/dd/yyyy')) end_date,
                 state.country_code,
                 state.status,
		 (SELECT hzg.geography_id
	          FROM HZ_GEOGRAPHIES hzg
		  WHERE hzg.geography_id = state.geography_id) existing_geography_id
          FROM zx_data_upload_interface state
          WHERE state.record_type = 01
          AND   state.LAST_UPDATION_VERSION > p_last_run_version
          AND   state.geography_id IS NOT NULL
          AND   nvl(state.status,'ERROR') IN ('CREATE','UPDATE')
          --AND   state.rowid between l_start_rowid and l_end_rowid
          UNION
          SELECT county.geography_id geography_id,
                 county.geography_name geography_name,
                 null geography_code,
                 'COUNTY' geography_type,
                 state.geography_id parent_geography_id,
                 state.geography_name parent_geography_name,
                 'STATE' parent_geography_type,
                 1 geography_element1_id,
                 'United States' geography_element1,
                 'US' geography_element1_code,
                 'COUNTRY' geography_element1_type,
                 state.geography_id geography_element2_id,
                 state.country_state_abbreviation geography_element2,
                 state.country_state_abbreviation geography_element2_code,
                 'STATE' geography_element2_type,
                 county.geography_id geography_element3_id,
                 county.geography_name geography_element3 ,
                 county.geography_name geography_element3_code,
                 'COUNTY' geography_element3_type,
                 null geography_element4_id ,
                 null geography_element4,
                 null geography_element4_code,
                 null geography_element4_type,
                 null geography_name1,
                 county.multiple_parent_flag,
                 county.effective_from start_date,
                 nvl(county.effective_to,to_date('12/31/4712','mm/dd/yyyy')) end_date,
                 county.country_code,
                 county.status,
		 (SELECT hzg.geography_id
	         FROM HZ_GEOGRAPHIES hzg
		 WHERE hzg.geography_id = county.geography_id) existing_geography_id
          FROM zx_data_upload_interface county,
               zx_data_upload_interface state
          WHERE county.record_type = 03
          AND   county.LAST_UPDATION_VERSION > p_last_run_version
          AND   county.geography_id IS NOT NULL
          AND   nvl(county.status,'ERROR') IN ('CREATE','UPDATE')
          --AND   county.rowid between l_start_rowid and l_end_rowid
          AND   state.record_type = 01
          AND   state.geography_id IS NOT NULL
          AND   state.state_jurisdiction_code = county.state_jurisdiction_code
          AND   state.country_code = county.country_code
          AND   state.effective_to IS NULL
          UNION
          SELECT city.geography_id geography_id,
                 city.geography_name geography_name,
                 null geography_code,
                 'CITY' geography_type,
                 county.geography_id parent_geography_id,
                 county.geography_name parent_geography_name,
                 'COUNTY' parent_geography_type,
                 1 geography_element1_id,
                 'United States' geography_element1,
                 'US' geography_element1_code,
                 'COUNTRY' geography_element1_type,
                 state.geography_id geography_element2_id,
                 state.country_state_abbreviation geography_element2,
                 state.country_state_abbreviation geography_element2_code,
                 'STATE' geography_element2_type,
                 county.geography_id geography_element3_id,
                 county.geography_name geography_element3 ,
                 county.geography_name geography_element3_code,
                 'COUNTY' geography_element3_type,
                 city.geography_id geography_element4_id ,
                 city.geography_name geography_element4,
                 null geography_element4_code,
                 'CITY' geography_element4_type,
                 null geography_name1,
                 city.multiple_parent_flag,
                 city.effective_from start_date,
                 nvl(city.effective_to,to_date('12/31/4712','mm/dd/yyyy')) end_date,
                 city.country_code,
                 city.status,
		 (SELECT hzg.geography_id
	          FROM HZ_GEOGRAPHIES hzg
		  WHERE hzg.geography_id = city.geography_id) existing_geography_id
          FROM zx_data_upload_interface city,
               zx_data_upload_interface county,
               zx_data_upload_interface state
          WHERE city.record_type = 06
          AND   city.LAST_UPDATION_VERSION > p_last_run_version
          AND   city.geography_id IS NOT NULL
          AND   nvl(city.status,'ERROR') IN ('CREATE','UPDATE')
          --AND   city.rowid between l_start_rowid and l_end_rowid
          AND   county.record_type = 03
          AND   county.geography_id IS NOT NULL
          AND   county.county_jurisdiction_code = city.county_jurisdiction_code
          AND   county.state_jurisdiction_code = city.state_jurisdiction_code
          AND   county.country_code  = city.country_code
          AND   county.effective_to IS NULL
          AND   state.record_type = 01
          AND   state.geography_id IS NOT NULL
          AND   state.state_jurisdiction_code = county.state_jurisdiction_code
          AND   state.country_code  = county.country_code
          AND   state.effective_to IS NULL
        ) v;


      /*SELECT COUNT(*)
        INTO l_rows_processed
      FROM zx_data_upload_interface
      WHERE rowid between l_start_rowid and l_end_rowid;
      --l_rows_processed := SQL%ROWCOUNT;

      ad_parallel_updates_pkg.processed_rowid_range(l_rows_processed,l_end_rowid);*/

      COMMIT;
      /*--
      -- get new range of ids
      --
      ad_parallel_updates_pkg.get_rowid_range
      (
       l_start_rowid,
       l_end_rowid,
       l_any_rows_to_process,
       P_batch_size,
       FALSE
      );

    END LOOP;*/

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      retcode := '1';
      errbuf := 'No data found';
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Error in '||l_api_name||': '||errbuf
      );

    WHEN OTHERS THEN
      ROLLBACK;
      retcode := '2';
      errbuf := SQLERRM;
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Unexpected Error in '||l_api_name||': '||errbuf
      );

  END CREATE_GEOGRAPHY;


  --
  -- Procedure to create tax geography for cities and jurisidictions for all
  --
  PROCEDURE CREATE_TAX_ZONES
  (
    errbuf               OUT NOCOPY VARCHAR2,
    retcode              OUT NOCOPY VARCHAR2,
    p_tax_content_source IN  VARCHAR2,
    p_last_run_version   IN  NUMBER,
    p_tax_regime_code    IN  VARCHAR2,
    p_tax_zone_type      IN  VARCHAR2
  ) IS

    l_api_name           CONSTANT VARCHAR2(30):= 'create_tax_zones';

    -----------------------------------------------------
    -- Ad parallelization variables
    -----------------------------------------------------
    l_table_owner         VARCHAR2(30) := 'ZX';
    l_any_rows_to_process BOOLEAN;
    l_table_name          VARCHAR2(30) := 'ZX_DATA_UPLOAD_INTERFACE';
    l_start_rowid         ROWID;
    l_end_rowid           ROWID;
    l_rows_processed      NUMBER;


  BEGIN

    retcode := '0';

    /**--
    -- Initialize the rowid ranges
    --
    ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           l_table_owner,
           l_table_name,
           p_script_name,
           p_Worker_Id,
           p_Num_Workers,
           p_batch_size, 0);
    --
    -- Get rowid ranges
    --
    ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           p_batch_size,
           TRUE);


    WHILE (l_any_rows_to_process)
    LOOP**/

      INSERT ALL
        WHEN (zone_geography_type IS NOT NULL AND zone_geography_id IS NOT NULL
              AND existing_geography_id IS NULL AND primary_flag = 'Y') THEN
          INTO HZ_GEOGRAPHIES
            (
             GEOGRAPHY_ID,
             OBJECT_VERSION_NUMBER,
             GEOGRAPHY_TYPE,
             GEOGRAPHY_NAME,
             GEOGRAPHY_USE,
             GEOGRAPHY_CODE,
             START_DATE,
             END_DATE,
             MULTIPLE_PARENT_FLAG,
             CREATED_BY_MODULE,
             COUNTRY_CODE,
             TIMEZONE_CODE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
            )
          VALUES
            (
             zone_geography_id,
             1,
             zone_geography_type,
             geo_code,
             'TAX',
             geo_code,
             start_date,
             end_date,
             'N',
             G_CREATED_BY_MODULE,
             country_code,
             'PST',
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id
            )
          WHEN (zone_geography_type IS NOT NULL AND zone_geography_id IS NOT NULL
                AND existing_geography_id IS NULL and primary_flag = 'Y') THEN
          INTO HZ_GEOGRAPHY_IDENTIFIERS
            (
             GEOGRAPHY_ID,
             GEO_DATA_PROVIDER,
             IDENTIFIER_SUBTYPE,
             IDENTIFIER_VALUE,
             OBJECT_VERSION_NUMBER,
             IDENTIFIER_TYPE,
             PRIMARY_FLAG,
             LANGUAGE_CODE,
             GEOGRAPHY_USE,
             GEOGRAPHY_TYPE,
             CREATED_BY_MODULE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
            )
          VALUES
            (
             zone_geography_id,
             p_tax_content_source,
             'STANDARD_NAME',
             geo_code,
             1,
             'NAME',
             'Y',
             'US',
             'TAX',
             zone_geography_type,
             G_CREATED_BY_MODULE,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id
            )
          WHEN (zone_geography_type IS NOT NULL AND zone_geography_id IS NOT NULL
                AND existing_geography_id IS NULL and primary_flag = 'Y') THEN
          INTO HZ_GEOGRAPHY_IDENTIFIERS
            (
             GEOGRAPHY_ID,
             GEO_DATA_PROVIDER,
             IDENTIFIER_SUBTYPE,
             IDENTIFIER_VALUE,
             OBJECT_VERSION_NUMBER,
             IDENTIFIER_TYPE,
             PRIMARY_FLAG,
             LANGUAGE_CODE,
             GEOGRAPHY_USE,
             GEOGRAPHY_TYPE,
             CREATED_BY_MODULE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
            )
          VALUES
            (
             zone_geography_id,
             p_tax_content_source,
             'GEO_CODE',
             geo_code,
             1,
             'CODE',
             'Y',
             'US',
             'TAX',
             zone_geography_type,
             G_CREATED_BY_MODULE,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id
            )
          WHEN (zone_geography_type IS NOT NULL AND zone_geography_id IS NOT NULL) THEN
          INTO HZ_RELATIONSHIPS
            (
             RELATIONSHIP_ID,
             SUBJECT_ID,
             SUBJECT_TYPE,
             SUBJECT_TABLE_NAME,
             OBJECT_ID,
             OBJECT_TYPE,
             OBJECT_TABLE_NAME,
             RELATIONSHIP_CODE,
             DIRECTIONAL_FLAG,
             COMMENTS,
             START_DATE,
             END_DATE,
             STATUS,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             CONTENT_SOURCE_TYPE,
             RELATIONSHIP_TYPE,
             OBJECT_VERSION_NUMBER,
             CREATED_BY_MODULE,
             APPLICATION_ID,
             DIRECTION_CODE,
             PERCENTAGE_OWNERSHIP,
             ACTUAL_CONTENT_SOURCE
            )
          VALUES
            (
             hz_relationships_s.nextval,
             zone_geography_id,
             zone_geography_type,
             'HZ_GEOGRAPHIES',
             geography_id,
             geography_type,
             'HZ_GEOGRAPHIES',
             'PARENT_OF',
             'F',
             null,
             start_date,
             end_date,
             'A',
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id,
             G_CREATED_BY_MODULE,
             'TAX',
             1,
             G_CREATED_BY_MODULE,
             null,
             'P',
             null,
             p_tax_content_source
            )
          WHEN (zone_geography_type IS NOT NULL AND zone_geography_id IS NOT NULL) THEN
          INTO HZ_RELATIONSHIPS
            (
             RELATIONSHIP_ID,
             SUBJECT_ID,
             SUBJECT_TYPE,
             SUBJECT_TABLE_NAME,
             OBJECT_ID,
             OBJECT_TYPE,
             OBJECT_TABLE_NAME,
             RELATIONSHIP_CODE,
             DIRECTIONAL_FLAG,
             COMMENTS,
             START_DATE,
             END_DATE,
             STATUS,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             CONTENT_SOURCE_TYPE,
             RELATIONSHIP_TYPE,
             OBJECT_VERSION_NUMBER,
             CREATED_BY_MODULE,
             APPLICATION_ID,
             DIRECTION_CODE,
             PERCENTAGE_OWNERSHIP,
             ACTUAL_CONTENT_SOURCE
            )
          VALUES
            (
             hz_relationships_s.nextval,
             geography_id,
             geography_type,
             'HZ_GEOGRAPHIES',
             zone_geography_id,
             zone_geography_type,
             'HZ_GEOGRAPHIES',
             'CHILD_OF',
             'B',
             null,
             start_date,
             end_date,
             'A',
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id,
             G_CREATED_BY_MODULE,
             'TAX',
             1,
             G_CREATED_BY_MODULE,
             null,
             'C',
             null,
             p_tax_content_source
            )
 -- Bug 6393452
        WHEN (existing_jurisdiction_id IS NULL and CITY_ROW_NUMBER = 1 and existing_zone_geography_id IS NULL
              AND existing_tax_rate = 1 AND primary_flag = 'Y') THEN
          INTO ZX_JURISDICTIONS_B
            (
             TAX_JURISDICTION_CODE,
             EFFECTIVE_FROM,
             EFFECTIVE_TO,
             TAX_REGIME_CODE,
             TAX,
             DEFAULT_JURISDICTION_FLAG,
             RECORD_TYPE_CODE,
             TAX_JURISDICTION_ID,
             ZONE_GEOGRAPHY_ID,
             INNER_CITY_JURISDICTION_FLAG,
             PRECEDENCE_LEVEL,
             ALLOW_TAX_REGISTRATIONS_FLAG,
             OBJECT_VERSION_NUMBER,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
            )
          VALUES
            (
             geo_code,
             decode(greatest(start_date,G_RECORD_EFFECTIVE_START),start_date,start_date,G_RECORD_EFFECTIVE_START),
             NULL,
             tax_regime_code,
             tax,
             'N',
             G_CREATED_BY_MODULE,
             zx_jurisdictions_b_s1.nextval,
             zone_geography_id,
             inner_city_flag,
             precedence_level,
             'Y',
             1,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id
            )
        SELECT v.geography_id,
               v.geography_type,
               v.tax_regime_code,
               v.tax,
               v.zone_geography_id,
               v.zone_geography_type,
               v.geo_code,
               v.start_date,
               nvl(v.end_date,to_date('12/31/4712','mm/dd/yyyy')) end_date,
               v.country_code,
               v.precedence_level,
               (select tax_jurisdiction_id
                from ZX_JURISDICTIONS_B j
                where j.tax_regime_code = v.tax_regime_code
                and   j.tax = v.tax
                and   j.tax_jurisdiction_code = v.geo_code) existing_jurisdiction_id,
	       (select tax_jurisdiction_id
                from ZX_JURISDICTIONS_B j
                where j.tax_regime_code = v.tax_regime_code
                and   j.tax = v.tax
                and   j.zone_geography_id = v.zone_geography_id
		and   j.effective_from = decode(greatest(v.start_date,G_RECORD_EFFECTIVE_START),v.start_date,v.start_date,G_RECORD_EFFECTIVE_START)) existing_zone_geography_id,
               (select geography_id
                from hz_geographies
                where geography_id = v.zone_geography_id) existing_geography_id,
               v.inner_city_flag,
               -- Bug 6393452
	       CITY_ROW_NUMBER,
	       existing_tax_rate,
	             primary_flag

        FROM (
          SELECT inter.geography_id,
                 'STATE' geography_type,
                 p_tax_regime_code tax_regime_code,
                 'STATE' tax,
                 inter.geography_id zone_geography_id,
                 to_char(null) zone_geography_type,
                 DECODE(p_tax_content_source,
                        'TAXWARE','ST-'||inter.COUNTRY_STATE_ABBREVIATION,
                        'ST-'||inter.STATE_JURISDICTION_CODE||'0000000') geo_code,
                 inter.effective_from start_date,
                 inter.effective_to end_date,
                 inter.country_code,
                 275 precedence_level,
                 'N' inner_city_flag,
		 1 CITY_ROW_NUMBER,
		 (SELECT 1
                  FROM zx_data_upload_interface rate
                  WHERE rate.record_type IN (09,10,11,12)
                  AND   rate.state_jurisdiction_code = inter.state_jurisdiction_code
                  AND   rate.county_jurisdiction_code IS NULL
                  AND   rate.city_jurisdiction_code IS NULL
                  AND   rate.LAST_UPDATION_VERSION > p_last_run_version
                  AND   rownum = 1) existing_tax_rate,
                  'Y' primary_flag
          FROM zx_data_upload_interface inter
          WHERE inter.record_type = 01
          AND   inter.geography_id IS NOT NULL
          AND   inter.effective_to IS NULL
          AND   inter.LAST_UPDATION_VERSION > p_last_run_version
          AND   p_tax_zone_type IS NOT NULL -- Means new regime
          UNION
          SELECT inter.geography_id,
                 'STATE' geography_type,
                 p_tax_regime_code tax_regime_code,
                 'STATE' tax,
                 inter.zone_geography_id,
                 'US_STATE_ZONE_TYPE_'||SUBSTRB(p_tax_regime_code, 14,10) zone_geography_type,
                 DECODE(p_tax_content_source,
                        'TAXWARE','ST-'||inter.COUNTRY_STATE_ABBREVIATION,
                        'ST-'||inter.STATE_JURISDICTION_CODE||'0000000') geo_code,
                 inter.effective_from start_date,
                 inter.effective_to end_date,
                 inter.country_code,
                 275 precedence_level,
                 'N' inner_city_flag,
                 1 CITY_ROW_NUMBER,
                 (SELECT 1
                  FROM zx_data_upload_interface rate
                  WHERE rate.record_type IN (09,10,11,12)
                  AND   rate.state_jurisdiction_code = inter.state_jurisdiction_code
                  AND   rate.county_jurisdiction_code IS NULL
                  AND   rate.city_jurisdiction_code IS NULL
                  AND   rate.LAST_UPDATION_VERSION > p_last_run_version
                  AND   rownum = 1) existing_tax_rate,
                  'Y' primary_flag
          FROM zx_data_upload_interface inter
          WHERE inter.record_type = 01
          AND   inter.zone_geography_id IS NOT NULL
          AND   inter.effective_to IS NULL
          AND   p_tax_zone_type IS NULL -- Means migrated regime
          /*AND   EXISTS (SELECT NULL
                        FROM zx_data_upload_interface rate
                        WHERE rate.record_type IN (09,10,11,12)
                        AND   rate.state_jurisdiction_code = inter.state_jurisdiction_code
                        AND   rate.county_jurisdiction_code IS NULL
                        AND   rate.city_jurisdiction_code IS NULL
                        AND   rate.LAST_UPDATION_VERSION > p_last_run_version)*/
          UNION
          SELECT inter.geography_id,
                 'COUNTY' geography_type,
                 p_tax_regime_code tax_regime_code,
                 'COUNTY' tax,
                 inter.geography_id zone_geography_id,
                 to_char(null) zone_geography_type,
                 DECODE(p_tax_content_source,
                        'TAXWARE','CO-'||inter.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(inter.GEOGRAPHY_NAME,1,21)),
                        'CO-'||inter.STATE_JURISDICTION_CODE||inter.COUNTY_JURISDICTION_CODE||'0000') geo_code,
                 inter.effective_from start_date,
                 inter.effective_to end_date,
                 inter.country_code,
                 175 precedence_level,
                 'N' inner_city_flag,
		 1 CITY_ROW_NUMBER,
		 (SELECT 1
                  FROM zx_data_upload_interface rate
                  WHERE rate.record_type IN (09,10,11,12)
                  AND   rate.state_jurisdiction_code = inter.state_jurisdiction_code
                  AND   rate.county_jurisdiction_code = inter.county_jurisdiction_code
                  AND   rate.city_jurisdiction_code IS NULL
                  AND   rate.LAST_UPDATION_VERSION > p_last_run_version
                  AND   rownum = 1) existing_tax_rate,
                  'Y' primary_flag
          FROM zx_data_upload_interface inter
          WHERE inter.record_type = 03
          AND   inter.geography_id IS NOT NULL
          AND   inter.effective_to IS NULL
          AND   inter.LAST_UPDATION_VERSION > p_last_run_version
          AND   p_tax_zone_type IS NOT NULL -- Means new regime
          UNION
          SELECT inter.geography_id,
                 'COUNTY' geography_type,
                 p_tax_regime_code tax_regime_code,
                 'COUNTY' tax,
                 inter.zone_geography_id,
                 'US_COUNTY_ZONE_TYPE_'||SUBSTRB(p_tax_regime_code, 14,10) zone_geography_type,
                 DECODE(p_tax_content_source,
                        'TAXWARE','CO-'||inter.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(inter.GEOGRAPHY_NAME,1,21)),
                        'CO-'||inter.STATE_JURISDICTION_CODE||inter.COUNTY_JURISDICTION_CODE||'0000') geo_code,
                 inter.effective_from start_date,
                 inter.effective_to end_date,
                 inter.country_code,
                 175 precedence_level,
                 'N' inner_city_flag,
		 1 CITY_ROW_NUMBER,
		 (SELECT 1
                  FROM zx_data_upload_interface rate
                  WHERE rate.record_type IN (09,10,11,12)
                  AND   rate.state_jurisdiction_code = inter.state_jurisdiction_code
                  AND   rate.county_jurisdiction_code = inter.county_jurisdiction_code
                  AND   rate.city_jurisdiction_code IS NULL
                  AND   rate.LAST_UPDATION_VERSION > p_last_run_version
                  AND   rownum = 1) existing_tax_rate,
                  'Y' primary_flag
          FROM zx_data_upload_interface inter
          WHERE inter.record_type = 03
          AND   inter.zone_geography_id IS NOT NULL
          AND   inter.effective_to IS NULL
          AND   p_tax_zone_type IS NULL -- Means migrated regime
          /*AND   EXISTS (SELECT NULL
                        FROM zx_data_upload_interface rate
                        WHERE rate.record_type IN (09,10,11,12)
                        AND   rate.state_jurisdiction_code = inter.state_jurisdiction_code
                        AND   rate.county_jurisdiction_code = inter.county_jurisdiction_code
                        AND   rate.city_jurisdiction_code IS NULL
                        AND   rate.LAST_UPDATION_VERSION > p_last_run_version)*/
          UNION
          SELECT inter.geography_id,
                 'CITY' geography_type,
                 p_tax_regime_code tax_regime_code,
                 'CITY' tax,
                 inter.zone_geography_id,
                 DECODE(p_tax_zone_type,null,'US_CITY_ZONE_TYPE_'||SUBSTRB(p_tax_regime_code, 14,10),p_tax_zone_type) zone_geography_type,
                 DECODE(p_tax_content_source,
                        'TAXWARE','CI-'||inter.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(inter.GEOGRAPHY_NAME,1,12))||'-'||inter.CITY_JURISDICTION_CODE,
                        'CI-'||inter.STATE_JURISDICTION_CODE||inter.COUNTY_JURISDICTION_CODE||LPAD(inter.CITY_JURISDICTION_CODE,4,'0')) geo_code,
                 inter.effective_from start_date,
                 inter.effective_to end_date,
                 inter.country_code,
                 75 precedence_level,
                 DECODE(TO_CHAR(inter.JURISDICTION_SERIAL_NUMBER),'1','Y','N') inner_city_flag,
		 1 CITY_ROW_NUMBER,
		 (SELECT 1
                  FROM zx_data_upload_interface rate
                  WHERE rate.record_type IN (09,10,11,12)
                  AND   rate.state_jurisdiction_code = inter.state_jurisdiction_code
                  AND   rate.county_jurisdiction_code = inter.county_jurisdiction_code
                  AND   rate.city_jurisdiction_code = inter.city_jurisdiction_code
                  AND   rate.LAST_UPDATION_VERSION > p_last_run_version
                  AND   rownum = 1) existing_tax_rate,
                  primary_flag
          FROM zx_data_upload_interface inter
          WHERE inter.record_type = 06
          AND   inter.zone_geography_id IS NOT NULL
          AND   inter.effective_to IS NULL
          -- cities should be considered always as they might have been created earlier but their zip range or rates are sent for the first time
          /*AND   EXISTS (SELECT NULL
                        FROM zx_data_upload_interface rate
                        WHERE rate.record_type IN (08,09,10,11,12)
                        AND   rate.state_jurisdiction_code = inter.state_jurisdiction_code
                        AND   rate.county_jurisdiction_code = inter.county_jurisdiction_code
                        AND   rate.city_jurisdiction_code = inter.city_jurisdiction_code
                        AND   rate.LAST_UPDATION_VERSION > p_last_run_version)*/
          UNION
          SELECT z.geography_id,
                 'CITY' geography_type,
                 p_tax_regime_code tax_regime_code,
                 decode(to_char(inter.record_type),'9',inter.SALES_TAX_AUTHORITY_LEVEL,'10',inter.RENTAL_TAX_AUTHORITY_LEVEL,'11',inter.USE_TAX_AUTHORITY_LEVEL,'12',inter.LEASE_TAX_AUTHORITY_LEVEL) tax,
                 DECODE(p_tax_zone_type,null,inter.zone_geography_id,z.zone_geography_id) zone_geography_id,
                 DECODE(p_tax_zone_type,null,'US_OVERRIDE_ZONE_TYPE_'||SUBSTRB(p_tax_regime_code, 14,10),null) zone_geography_type,
                 DECODE(decode(to_char(inter.record_type),'9',inter.SALES_TAX_AUTHORITY_LEVEL,'10',inter.RENTAL_TAX_AUTHORITY_LEVEL,'11',inter.USE_TAX_AUTHORITY_LEVEL,'12',inter.LEASE_TAX_AUTHORITY_LEVEL),
                          'STATE','ST-','COUNTY','CO-')||
                        DECODE(p_tax_content_source,
                          'TAXWARE','CI-'||z.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(z.GEOGRAPHY_NAME,1,12))||'-'||z.CITY_JURISDICTION_CODE,
                          'CI-'||z.STATE_JURISDICTION_CODE||z.COUNTY_JURISDICTION_CODE||LPAD(z.CITY_JURISDICTION_CODE,4,'0')) geo_code,
                 z.effective_from start_date,
                 z.effective_to end_date,
                 inter.country_code,
                 75 precedence_level,
                 'N' inner_city_flag,
		 ROW_NUMBER()
                 OVER (PARTITION BY
		       p_tax_regime_code
                      ,decode(to_char(inter.record_type),'9',inter.SALES_TAX_AUTHORITY_LEVEL,'10',inter.RENTAL_TAX_AUTHORITY_LEVEL,'11',inter.USE_TAX_AUTHORITY_LEVEL,'12',inter.LEASE_TAX_AUTHORITY_LEVEL)
                      ,DECODE(p_tax_zone_type,null,inter.zone_geography_id,z.geography_id)
                      ,z.effective_from ORDER BY z.effective_from ) AS CITY_ROW_NUMBER,
                 1 existing_tax_rate,
                 z.primary_flag
          FROM zx_data_upload_interface inter,
               zx_data_upload_interface z
          WHERE inter.record_type IN (09,10,11,12)
          AND   (inter.SALES_TAX_AUTHORITY_LEVEL = 'STATE'
                 OR inter.SALES_TAX_AUTHORITY_LEVEL = 'COUNTY'
                 OR inter.RENTAL_TAX_AUTHORITY_LEVEL = 'STATE'
                 OR inter.RENTAL_TAX_AUTHORITY_LEVEL = 'COUNTY'
                 OR inter.USE_TAX_AUTHORITY_LEVEL = 'STATE'
                 OR inter.USE_TAX_AUTHORITY_LEVEL = 'COUNTY'
                 OR inter.LEASE_TAX_AUTHORITY_LEVEL = 'STATE'
                 OR inter.LEASE_TAX_AUTHORITY_LEVEL = 'COUNTY')
          AND   inter.STATE_JURISDICTION_CODE IS NOT NULL
          AND   inter.COUNTY_JURISDICTION_CODE IS NOT NULL
          AND   inter.CITY_JURISDICTION_CODE IS NOT NULL
          AND   inter.effective_to IS NULL
          AND   inter.LAST_UPDATION_VERSION > p_last_run_version
          AND   (p_tax_zone_type IS NOT NULL
                 OR inter.zone_geography_id IS NOT NULL)
          and   z.record_type = 06
          and   z.STATE_JURISDICTION_CODE = inter.STATE_JURISDICTION_CODE
          and   z.COUNTY_JURISDICTION_CODE = inter.COUNTY_JURISDICTION_CODE
          and   z.CITY_JURISDICTION_CODE = inter.CITY_JURISDICTION_CODE
          and   z.zone_geography_id IS NOT NULL
          and   z.effective_to IS NULL
          UNION
          SELECT z.geography_id,
                 'COUNTY' geography_type,
                 p_tax_regime_code tax_regime_code,
                 decode(to_char(inter.record_type),'9',inter.SALES_TAX_AUTHORITY_LEVEL,'10',inter.RENTAL_TAX_AUTHORITY_LEVEL,'11',inter.USE_TAX_AUTHORITY_LEVEL,'12',inter.LEASE_TAX_AUTHORITY_LEVEL) tax,
                 DECODE(p_tax_zone_type,null,inter.zone_geography_id,z.geography_id) zone_geography_id,
                 DECODE(p_tax_zone_type,null,'US_OVERRIDE_ZONE_TYPE_'||SUBSTRB(p_tax_regime_code, 14,10),null) zone_geography_type,
                 DECODE(p_tax_content_source,
                        'TAXWARE','ST-CO-'||z.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(z.GEOGRAPHY_NAME,1,21)),
                        'ST-CO-'||z.STATE_JURISDICTION_CODE||z.COUNTY_JURISDICTION_CODE||'0000') geo_code,
                 z.effective_from start_date,
                 z.effective_to end_date,
                 inter.country_code,
                 175 precedence_level,
                 'N' inner_city_flag,
		 1 CITY_ROW_NUMBER,
		 1 existing_tax_rate,
		             'Y' primary_flag
          FROM zx_data_upload_interface inter,
               zx_data_upload_interface z
          WHERE inter.record_type IN (09,10,11,12)
          AND   (inter.SALES_TAX_AUTHORITY_LEVEL = 'STATE'
                 OR inter.RENTAL_TAX_AUTHORITY_LEVEL = 'STATE'
                 OR inter.USE_TAX_AUTHORITY_LEVEL = 'STATE'
                 OR inter.LEASE_TAX_AUTHORITY_LEVEL = 'STATE')
          AND   inter.STATE_JURISDICTION_CODE IS NOT NULL
          AND   inter.COUNTY_JURISDICTION_CODE IS NOT NULL
          AND   inter.CITY_JURISDICTION_CODE IS NULL
          AND   inter.effective_to IS NULL
          AND   inter.LAST_UPDATION_VERSION > p_last_run_version
          AND   (p_tax_zone_type IS NOT NULL
                 OR inter.zone_geography_id IS NOT NULL)
          and   z.record_type = 03
          and   z.STATE_JURISDICTION_CODE = inter.STATE_JURISDICTION_CODE
          and   z.COUNTY_JURISDICTION_CODE = inter.COUNTY_JURISDICTION_CODE
          and   z.geography_id IS NOT NULL
          and   z.effective_to IS NULL
        ) v;


      l_rows_processed := SQL%ROWCOUNT;

      -- Copy accounts from taxes
      -- Do this only for newly created jurisdicition
      -- Use TL table and regime/tax/record type combination to find new ones
      INSERT INTO ZX_ACCOUNTS
      (
        TAX_ACCOUNT_ID,
        OBJECT_VERSION_NUMBER,
        TAX_ACCOUNT_ENTITY_CODE,
        TAX_ACCOUNT_ENTITY_ID,
        LEDGER_ID,
        INTERNAL_ORGANIZATION_ID,
        TAX_ACCOUNT_CCID,
        INTERIM_TAX_CCID,
        NON_REC_ACCOUNT_CCID,
        ADJ_CCID,
        EDISC_CCID,
        UNEDISC_CCID,
        FINCHRG_CCID,
        ADJ_NON_REC_TAX_CCID,
        EDISC_NON_REC_TAX_CCID,
        UNEDISC_NON_REC_TAX_CCID,
        FINCHRG_NON_REC_TAX_CCID,
        RECORD_TYPE_CODE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
      )
      SELECT
        zx_accounts_s.nextval,
        1,
        'JURISDICTION',
        zjb.TAX_JURISDICTION_ID,
        za.LEDGER_ID,
        za.INTERNAL_ORGANIZATION_ID,
        za.TAX_ACCOUNT_CCID,
        za.INTERIM_TAX_CCID,
        za.NON_REC_ACCOUNT_CCID,
        za.ADJ_CCID,
        za.EDISC_CCID,
        za.UNEDISC_CCID,
        za.FINCHRG_CCID,
        za.ADJ_NON_REC_TAX_CCID,
        za.EDISC_NON_REC_TAX_CCID,
        za.UNEDISC_NON_REC_TAX_CCID,
        za.FINCHRG_NON_REC_TAX_CCID,
        G_CREATED_BY_MODULE,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.conc_login_id
      FROM ZX_JURISDICTIONS_B zjb,
           ZX_TAXES_B ztb,
           ZX_ACCOUNTS za
      WHERE zjb.TAX_REGIME_CODE = p_tax_regime_code
      AND   zjb.TAX IN ('STATE','COUNTY','CITY')
      AND   zjb.RECORD_TYPE_CODE = G_CREATED_BY_MODULE
      AND   NOT EXISTS (SELECT NULL
                        FROM ZX_JURISDICTIONS_TL zjt
                        WHERE zjt.TAX_JURISDICTION_ID = zjb.TAX_JURISDICTION_ID)
      AND   ztb.TAX_REGIME_CODE = zjb.TAX_REGIME_CODE
      AND   ztb.TAX = zjb.TAX
      AND   ztb.SOURCE_TAX_FLAG = 'Y'
      AND   za.TAX_ACCOUNT_ENTITY_CODE = 'TAXES'
      AND   za.TAX_ACCOUNT_ENTITY_ID = ztb.TAX_ID
      AND   NOT EXISTS (SELECT 1
                        FROM ZX_ACCOUNTS
                        WHERE TAX_ACCOUNT_ENTITY_ID = zjb.TAX_JURISDICTION_ID
                        AND   TAX_ACCOUNT_ENTITY_CODE = 'JURISDICTION'
                        AND   LEDGER_ID = za.LEDGER_ID
                        AND   INTERNAL_ORGANIZATION_ID = za.INTERNAL_ORGANIZATION_ID);

      INSERT INTO ZX_JURISDICTIONS_TL
      (
       TAX_JURISDICTION_ID,
       TAX_JURISDICTION_NAME,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN,
       LANGUAGE,
       SOURCE_LANG
      )
      SELECT zjb.TAX_JURISDICTION_ID,
             DECODE((SELECT SUBSTR(hg.geography_element2_code,1,2)||'-'||
                            DECODE(hg.geography_element3,null,'',SUBSTR(hg.geography_element3,1,30)||'-')||
                            DECODE(hg.geography_element4,null,'',SUBSTR(hg.geography_element4,1,30)||'-')
                     FROM HZ_GEOGRAPHIES hg
                     WHERE hg.GEOGRAPHY_ID = zjb.zone_geography_id),
                     '-',
                     (SELECT SUBSTR(hg.geography_element2_code,1,2)||'-'||
                      DECODE(hg.geography_element3,null,'',SUBSTR(hg.geography_element3,1,30)||'-')||
                      DECODE(hg.geography_element4,null,'',SUBSTR(hg.geography_element4,1,30)||'-')
                      FROM hz_geographies hg_zone,
                           hz_relationships hr,
                           hz_geographies hg
                      WHERE hg_zone.GEOGRAPHY_ID = zjb.zone_geography_id
                      AND   hr.SUBJECT_ID = hg_zone.GEOGRAPHY_ID
                      AND   hr.SUBJECT_TYPE = hg_zone.GEOGRAPHY_TYPE
                      AND   hr.SUBJECT_TABLE_NAME = 'HZ_GEOGRAPHIES'
                      AND   hr.RELATIONSHIP_CODE = 'PARENT_OF'
                      AND   hr.DIRECTIONAL_FLAG = 'F'
                      AND   hr.OBJECT_TABLE_NAME = 'HZ_GEOGRAPHIES'
                      AND   hg.GEOGRAPHY_ID = hr.OBJECT_ID
                      AND   hg.GEOGRAPHY_TYPE = hr.OBJECT_TYPE
                      AND   ROWNUM = 1),
                      (SELECT SUBSTR(hg.geography_element2_code,1,2)||'-'||
                              DECODE(hg.geography_element3,null,'',SUBSTR(hg.geography_element3,1,30)||'-')||
                              DECODE(hg.geography_element4,null,'',SUBSTR(hg.geography_element4,1,30)||'-')
                       FROM HZ_GEOGRAPHIES hg
                       WHERE hg.GEOGRAPHY_ID = zjb.zone_geography_id))
             || zjb.TAX_JURISDICTION_CODE,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id,
             fl.LANGUAGE_CODE,
             USERENV('LANG')
      FROM ZX_JURISDICTIONS_B zjb,
           FND_LANGUAGES fl
      WHERE fl.INSTALLED_FLAG IN ('I', 'B')
      AND   zjb.TAX_REGIME_CODE = p_tax_regime_code
      AND   zjb.TAX IN ('STATE','COUNTY','CITY')
      AND   NOT EXISTS (SELECT NULL
                        FROM ZX_JURISDICTIONS_TL zjt
                        WHERE zjt.TAX_JURISDICTION_ID = zjb.TAX_JURISDICTION_ID
                        AND   zjt.LANGUAGE = fl.LANGUAGE_CODE);

      l_rows_processed := SQL%ROWCOUNT;

      FOR ref_ranges IN
        (SELECT master_ref_geography_id,
                geography_id,
                geography_type,
                zip_begin,
                zip_end,
                start_date,
                end_date,
                hgr_row_id,
                postal_code_num
         FROM
               (SELECT DISTINCT
                city.geography_id master_ref_geography_id,
                city.zone_geography_id geography_id,
                NVL(p_tax_zone_type,'US_CITY_ZONE_TYPE_'||SUBSTRB(p_tax_regime_code, 14,10)) geography_type,
                zip.zip_begin,
                zip.zip_end,
                zip.effective_from start_date,
                nvl(zip.effective_to,to_date('12/31/4712','mm/dd/yyyy')) end_date,
                (select hgr.rowid
                 FROM hz_geography_ranges hgr
                 WHERE hgr.GEOGRAPHY_ID = city.zone_geography_id
                 --AND   hgr.GEOGRAPHY_TYPE = NVL(p_tax_zone_type,'US_CITY_ZONE_TYPE_'||SUBSTRB(p_tax_regime_code, 14,10))
                 --AND   hgr.GEOGRAPHY_USE = 'TAX'
                 --AND   hgr.MASTER_REF_GEOGRAPHY_ID = city.geography_id
                 --AND   hgr.IDENTIFIER_TYPE = 'NAME'
                 AND   hgr.GEOGRAPHY_FROM = zip.zip_begin
                 AND   hgr.START_DATE = zip.effective_from
                 AND   ROWNUM=1
                 --AND   hgr.GEOGRAPHY_TO = zip.zip_end
                ) hgr_row_id,
                Row_Number()
                OVER (PARTITION BY zip.zip_begin, city.geography_id,
	                    zip.effective_from order by zip.zip_end DESC ) as postal_code_num
         FROM ZX_DATA_UPLOAD_INTERFACE zip,
              ZX_DATA_UPLOAD_INTERFACE city
         WHERE zip.record_type = 08
         AND   city.record_type = 06
         AND   city.STATE_JURISDICTION_CODE = zip.STATE_JURISDICTION_CODE
         AND   city.COUNTY_JURISDICTION_CODE = zip.COUNTY_JURISDICTION_CODE
         AND   city.CITY_JURISDICTION_CODE = zip.CITY_JURISDICTION_CODE
         AND   city.zone_geography_id IS NOT NULL
         AND   city.geography_id IS NOT NULL
         AND   city.primary_flag = 'Y'
         AND   city.geography_name = zip.geography_name
         /*AND   EXISTS (SELECT NULL
                       FROM zx_data_upload_interface rate
                       WHERE rate.record_type IN (08,09,10,11,12)
                       AND   rate.state_jurisdiction_code = zip.state_jurisdiction_code
                       AND   rate.county_jurisdiction_code = zip.county_jurisdiction_code
                       AND   rate.city_jurisdiction_code = zip.city_jurisdiction_code
                       AND   rate.LAST_UPDATION_VERSION > p_last_run_version)*/
                ) v
         WHERE postal_code_num = 1)
      LOOP
        IF (ref_ranges.hgr_row_id IS NOT NULL)
        THEN
          UPDATE hz_geography_ranges
          SET END_DATE = ref_ranges.end_date,
              LAST_UPDATED_BY = fnd_global.user_id,
              LAST_UPDATE_DATE = sysdate,
              LAST_UPDATE_LOGIN = fnd_global.conc_login_id
          WHERE ROWID = ref_ranges.hgr_row_id;
        ELSE
          INSERT WHEN (NOT EXISTS
                             (SELECT 1 FROM HZ_GEOGRAPHY_RANGES
                             WHERE GEOGRAPHY_ID = ref_ranges.geography_id
                             AND GEOGRAPHY_FROM =  ref_ranges.zip_begin
                             AND START_DATE = ref_ranges.start_date)

          ) THEN
	  INTO hz_geography_ranges
            (
             GEOGRAPHY_ID,
             GEOGRAPHY_FROM,
             START_DATE,
             OBJECT_VERSION_NUMBER,
             GEOGRAPHY_TO,
             IDENTIFIER_TYPE,
             END_DATE,
             GEOGRAPHY_TYPE,
             GEOGRAPHY_USE,
             MASTER_REF_GEOGRAPHY_ID,
             CREATED_BY_MODULE,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
           )
         VALUES
           (
             ref_ranges.geography_id,
             ref_ranges.zip_begin,
             ref_ranges.start_date,
             1,
             ref_ranges.zip_end,
             'NAME',
             ref_ranges.end_date,
             ref_ranges.geography_type,
             'TAX',
             ref_ranges.master_ref_geography_id,
             G_CREATED_BY_MODULE,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id
           )
	   select sysdate from dual;
        END IF;
      END LOOP;

      -- Migrated regime case
      -- insert ranges for state/county/override jurisdictions too
      IF (p_tax_zone_type IS NULL) THEN
        INSERT ALL
        INTO hz_geography_ranges
            (
             GEOGRAPHY_ID,
             GEOGRAPHY_FROM,
             START_DATE,
             OBJECT_VERSION_NUMBER,
             GEOGRAPHY_TO,
             IDENTIFIER_TYPE,
             END_DATE,
             GEOGRAPHY_TYPE,
             GEOGRAPHY_USE,
             MASTER_REF_GEOGRAPHY_ID,
             CREATED_BY_MODULE,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
           )
         VALUES
           (
             zone_geography_id,
             zip_begin,
             start_date,
             1,
             zip_end,
             'NAME',
             end_date,
             zone_geography_type,
             'TAX',
             geography_id,
             G_CREATED_BY_MODULE,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id
           )
        SELECT
          zone_geography_id,
          '0000' zip_begin,
          effective_from start_date,
          '9999' zip_end,
          nvl(effective_to,to_date('12/31/4712','mm/dd/yyyy')) end_date,
          DECODE(TO_CHAR(record_type),'1','US_STATE_ZONE_TYPE_'||SUBSTRB(p_tax_regime_code, 14,10),
            '3','US_COUNTY_ZONE_TYPE_'||SUBSTRB(p_tax_regime_code, 14,10)) zone_geography_type,
          geography_id
        FROM ZX_DATA_UPLOAD_INTERFACE inter
        WHERE record_type in (1,3)
        AND   zone_geography_id IS NOT NULL
        AND   NOT EXISTS (SELECT NULL
                           FROM hz_geography_ranges hgr
                           WHERE hgr.GEOGRAPHY_ID = inter.zone_geography_id
                           AND   hgr.GEOGRAPHY_FROM = '0000'
                           AND   hgr.START_DATE = inter.effective_from
                          );
      END IF;

      COMMIT;

      /**ad_parallel_updates_pkg.processed_rowid_range(l_rows_processed,l_end_rowid);

      COMMIT;
      --
      -- get new range of ids
      --
      ad_parallel_updates_pkg.get_rowid_range
      (
       l_start_rowid,
       l_end_rowid,
       l_any_rows_to_process,
       P_batch_size,
       FALSE
      );

    END LOOP;**/

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      retcode := '1';
      errbuf := 'No data found';
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Error in '||l_api_name||': '||errbuf
      );

    WHEN OTHERS THEN
      ROLLBACK;
      retcode := '2';
      errbuf := SQLERRM;
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Unexpected Error '||l_api_name||': '||errbuf
      );

  END CREATE_TAX_ZONES;

  --
  -- Procedure to create master geography for postal codes
  --
  PROCEDURE CREATE_ZIP
  (
    errbuf               OUT NOCOPY VARCHAR2,
    retcode              OUT NOCOPY VARCHAR2,
    p_tax_content_source IN  VARCHAR2,
    p_last_run_version   IN  NUMBER
  ) IS

    l_api_name           CONSTANT VARCHAR2(30):= 'create_zip';

    -----------------------------------------------------
    -- Ad parallelization variables
    -----------------------------------------------------
    l_table_owner         VARCHAR2(30) := 'ZX';
    l_any_rows_to_process BOOLEAN;
    l_table_name          VARCHAR2(30) := 'ZX_DATA_UPLOAD_INTERFACE';
    l_start_rowid         ROWID;
    l_end_rowid           ROWID;
    l_rows_processed      NUMBER;


  BEGIN

    retcode := '0';

    /**--
    -- Initialize the rowid ranges
    --
    ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           l_table_owner,
           l_table_name,
           p_script_name,
           p_Worker_Id,
           p_Num_Workers,
           p_batch_size, 0);
    --
    -- Get rowid ranges
    --
    ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           p_batch_size,
           TRUE);


    WHILE (l_any_rows_to_process)
    LOOP**/

      INSERT ALL
        WHEN (1=1) THEN
        INTO HZ_GEOGRAPHIES
          (
           GEOGRAPHY_ID,
           OBJECT_VERSION_NUMBER,
           GEOGRAPHY_TYPE,
           GEOGRAPHY_NAME,
           GEOGRAPHY_USE,
           GEOGRAPHY_CODE,
           START_DATE,
           END_DATE,
           MULTIPLE_PARENT_FLAG,
           geography_element1,
           geography_element1_id,
           geography_element1_code,
           geography_element2,
           geography_element2_id,
           geography_element2_code,
           geography_element3,
           geography_element3_id,
           geography_element4,
           geography_element4_id,
           geography_element4_code,
           geography_element5,
           geography_element5_id,
           geography_element5_code,
           CREATED_BY_MODULE,
           COUNTRY_CODE,
           TIMEZONE_CODE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN
          )
        VALUES
          (
           hz_geographies_s.nextval,
           1,
           geography_type,
           geography_name,
           'MASTER_REF',
           geography_code,
           start_date,
           end_date,
           'N',
           geography_element1,
           geography_element1_id,
           geography_element1_code,
           geography_element2,
           geography_element2_id,
           geography_element2_code,
           geography_element3,
           geography_element3_id,
           geography_element4,
           geography_element4_id,
           geography_element4_code,
           geography_name,
           hz_geographies_s.nextval,
           null,
           G_CREATED_BY_MODULE,
           country_code,
           'PST',
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.conc_login_id
          )
        INTO HZ_GEOGRAPHY_IDENTIFIERS
          (
           GEOGRAPHY_ID,
           GEO_DATA_PROVIDER,
           IDENTIFIER_SUBTYPE,
           IDENTIFIER_VALUE,
           OBJECT_VERSION_NUMBER,
           IDENTIFIER_TYPE,
           PRIMARY_FLAG,
           LANGUAGE_CODE,
           GEOGRAPHY_USE,
           GEOGRAPHY_TYPE,
           CREATED_BY_MODULE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN
          )
        VALUES
          (
           hz_geographies_s.nextval,
           p_tax_content_source,
           'STANDARD_NAME',
           geography_name,
           1,
           'NAME',
           'Y',
           'US',
           'MASTER_REF',
           geography_type,
           G_CREATED_BY_MODULE,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.conc_login_id
          )
        INTO HZ_GEOGRAPHY_IDENTIFIERS
          (
           GEOGRAPHY_ID,
           GEO_DATA_PROVIDER,
           IDENTIFIER_SUBTYPE,
           IDENTIFIER_VALUE,
           OBJECT_VERSION_NUMBER,
           IDENTIFIER_TYPE,
           PRIMARY_FLAG,
           LANGUAGE_CODE,
           GEOGRAPHY_USE,
           GEOGRAPHY_TYPE,
           CREATED_BY_MODULE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN
          )
        VALUES
          (
           hz_geographies_s.nextval,
           p_tax_content_source,
           'FIPS_CODE',
           geography_code,
           1,
           'CODE',
           'Y',
           'US',
           'MASTER_REF',
           geography_type,
           G_CREATED_BY_MODULE,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.conc_login_id
          )
        INTO HZ_RELATIONSHIPS
          (
           RELATIONSHIP_ID,
           SUBJECT_ID,
           SUBJECT_TYPE,
           SUBJECT_TABLE_NAME,
           OBJECT_ID,
           OBJECT_TYPE,
           OBJECT_TABLE_NAME,
           RELATIONSHIP_CODE,
           DIRECTIONAL_FLAG,
           COMMENTS,
           START_DATE,
           END_DATE,
           STATUS,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           CONTENT_SOURCE_TYPE,
           RELATIONSHIP_TYPE,
           OBJECT_VERSION_NUMBER,
           CREATED_BY_MODULE,
           APPLICATION_ID,
           DIRECTION_CODE,
           PERCENTAGE_OWNERSHIP,
           ACTUAL_CONTENT_SOURCE
          )
        VALUES
          (
           hz_relationships_s.nextval,
           parent_geography_id,
           parent_geography_type,
           'HZ_GEOGRAPHIES',
           hz_geographies_s.nextval,
           geography_type,
           'HZ_GEOGRAPHIES',
           'PARENT_OF',
           'F',
           null,
           start_date,
           end_date,
           'A',
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.conc_login_id,
           G_CREATED_BY_MODULE,
           'MASTER_REF',
           1,
           G_CREATED_BY_MODULE,
           null,
           'P',
           null,
           p_tax_content_source
          )
        INTO HZ_RELATIONSHIPS
          (
           RELATIONSHIP_ID,
           SUBJECT_ID,
           SUBJECT_TYPE,
           SUBJECT_TABLE_NAME,
           OBJECT_ID,
           OBJECT_TYPE,
           OBJECT_TABLE_NAME,
           RELATIONSHIP_CODE,
           DIRECTIONAL_FLAG,
           COMMENTS,
           START_DATE,
           END_DATE,
           STATUS,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           CONTENT_SOURCE_TYPE,
           RELATIONSHIP_TYPE,
           OBJECT_VERSION_NUMBER,
           CREATED_BY_MODULE,
           APPLICATION_ID,
           DIRECTION_CODE,
           PERCENTAGE_OWNERSHIP,
           ACTUAL_CONTENT_SOURCE
          )
        VALUES
          (
           hz_relationships_s.nextval,
           hz_geographies_s.nextval,
           geography_type,
           'HZ_GEOGRAPHIES',
           parent_geography_id,
           parent_geography_type,
           'HZ_GEOGRAPHIES',
           'CHILD_OF',
           'B',
           null,
           start_date,
           end_date,
           'A',
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.conc_login_id,
           G_CREATED_BY_MODULE,
           'MASTER_REF',
           1,
           G_CREATED_BY_MODULE,
           null,
           'C',
           null,
           p_tax_content_source
          )
        --Self
        INTO hz_hierarchy_nodes
          (
           HIERARCHY_TYPE,
           PARENT_ID,
           PARENT_TABLE_NAME,
           PARENT_OBJECT_TYPE,
           CHILD_ID,
           CHILD_TABLE_NAME,
           CHILD_OBJECT_TYPE,
           LEVEL_NUMBER,
           TOP_PARENT_FLAG,
           LEAF_CHILD_FLAG,
           EFFECTIVE_START_DATE,
           EFFECTIVE_END_DATE,
           STATUS,
           RELATIONSHIP_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ACTUAL_CONTENT_SOURCE
          )
        VALUES
          (
           'MASTER_REF',
           hz_geographies_s.nextval,
           'HZ_GEOGRAPHIES',
           geography_type,
           hz_geographies_s.nextval,
           'HZ_GEOGRAPHIES',
           geography_type,
           0  ,
           'N',
           'Y',
           start_date,
           end_date,
           'A',
           null,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.conc_login_id,
           p_tax_content_source
          )
        -- City
        INTO hz_hierarchy_nodes
          (
           HIERARCHY_TYPE,
           PARENT_ID,
           PARENT_TABLE_NAME,
           PARENT_OBJECT_TYPE,
           CHILD_ID,
           CHILD_TABLE_NAME,
           CHILD_OBJECT_TYPE,
           LEVEL_NUMBER,
           TOP_PARENT_FLAG,
           LEAF_CHILD_FLAG,
           EFFECTIVE_START_DATE,
           EFFECTIVE_END_DATE,
           STATUS,
           RELATIONSHIP_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ACTUAL_CONTENT_SOURCE
          )
        VALUES
          (
           'MASTER_REF',
           parent_geography_id,
           'HZ_GEOGRAPHIES',
           parent_geography_type,
           hz_geographies_s.nextval,
           'HZ_GEOGRAPHIES',
           geography_type,
           1,
           '',
           '',
           start_date,
           end_date,
           'A',
           hz_relationships_s.nextval,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.conc_login_id,
           p_tax_content_source
          )
        -- County
        WHEN (geography_element3_id IS NOT NULL) THEN
        INTO hz_hierarchy_nodes
          (
           HIERARCHY_TYPE,
           PARENT_ID,
           PARENT_TABLE_NAME,
           PARENT_OBJECT_TYPE,
           CHILD_ID,
           CHILD_TABLE_NAME,
           CHILD_OBJECT_TYPE,
           LEVEL_NUMBER,
           TOP_PARENT_FLAG,
           LEAF_CHILD_FLAG,
           EFFECTIVE_START_DATE,
           EFFECTIVE_END_DATE,
           STATUS,
           RELATIONSHIP_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ACTUAL_CONTENT_SOURCE
          )
        VALUES
          (
           'MASTER_REF',
           geography_element3_id,
           'HZ_GEOGRAPHIES',
           'COUNTY',
           hz_geographies_s.nextval,
           'HZ_GEOGRAPHIES',
           geography_type,
           2  ,
           '',
           '',
           start_date,
           end_date,
           'A',
           null  ,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.conc_login_id,
           p_tax_content_source
          )
        WHEN (geography_element2_id IS NOT NULL) THEN
        INTO hz_hierarchy_nodes
          (
           HIERARCHY_TYPE,
           PARENT_ID,
           PARENT_TABLE_NAME,
           PARENT_OBJECT_TYPE,
           CHILD_ID,
           CHILD_TABLE_NAME,
           CHILD_OBJECT_TYPE,
           LEVEL_NUMBER,
           TOP_PARENT_FLAG,
           LEAF_CHILD_FLAG,
           EFFECTIVE_START_DATE,
           EFFECTIVE_END_DATE,
           STATUS,
           RELATIONSHIP_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ACTUAL_CONTENT_SOURCE
          )
        VALUES
          (
           'MASTER_REF',
           geography_element2_id,
           'HZ_GEOGRAPHIES',
           'STATE',
           hz_geographies_s.nextval,
           'HZ_GEOGRAPHIES',
           geography_type,
           3  ,
           '',
           '',
           start_date,
           end_date,
           'A',
           null  ,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.conc_login_id,
           p_tax_content_source
          )
        WHEN (geography_element1_id IS NOT NULL) THEN
        INTO hz_hierarchy_nodes
          (
           HIERARCHY_TYPE,
           PARENT_ID,
           PARENT_TABLE_NAME,
           PARENT_OBJECT_TYPE,
           CHILD_ID,
           CHILD_TABLE_NAME,
           CHILD_OBJECT_TYPE,
           LEVEL_NUMBER,
           TOP_PARENT_FLAG,
           LEAF_CHILD_FLAG,
           EFFECTIVE_START_DATE,
           EFFECTIVE_END_DATE,
           STATUS,
           RELATIONSHIP_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ACTUAL_CONTENT_SOURCE
          )
        VALUES
          (
           'MASTER_REF',
           geography_element1_id,
           'HZ_GEOGRAPHIES',
           'COUNTRY',
           hz_geographies_s.nextval,
           'HZ_GEOGRAPHIES',
           geography_type,
           4  ,
           '',
           '',
           start_date,
           end_date,
           'A',
           null  ,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.conc_login_id,
           p_tax_content_source
          )

        select v.zip_code geography_name,
               v.zip_code geography_code,
               'POSTAL_CODE' geography_type,
               --v.start_date,
               --v.end_date,
               MIN(v.start_date)  start_date,
               MAX(v.end_date)  end_date,
               g.geography_id parent_geography_id,
               g.geography_type parent_geography_type,
               g.geography_element1,
               g.geography_element1_id,
               g.geography_element1_code,
               g.geography_element2,
               g.geography_element2_id,
               g.geography_element2_code,
               g.geography_element3,
               g.geography_element3_id,
               g.geography_element3_code,
               g.geography_element4,
               g.geography_element4_id,
               g.geography_element4_code,
               g.country_code
        from
        (
          select geography_id,
                 effective_from start_date,
                 nvl(effective_to,to_date('12/31/4712','mm/dd/yyyy')) end_date,
                 from_code,
                 to_code,
                 trim(to_char(val,'09999')) zip_code,cnt
          from (
                select distinct
                       geography_id,
                       effective_from,
                       effective_to,
                       zip_begin,
                       zip_end
                from zx_data_upload_interface
                where record_type = 08
                and   last_updation_version > p_last_run_version
                and   city_jurisdiction_code is not null
                and   geography_id is not null
                and   effective_to is null
                and   nvl(status,'CREATE') <> 'ERROR'
               )
          model
            partition by (geography_id,zip_begin,zip_end,effective_from,effective_to)
            dimension by (0 as attr)
            measures (0 as val,
                      to_number(zip_begin) as from_code,
                      to_number(zip_end) as to_code,
                      (to_number(zip_end)-to_number(zip_begin)+1) as cnt
                     )
            rules iterate (200)
              until (iteration_number+1 >= cnt[0])
              (
                val[iteration_number] = from_code[0]+iteration_number
              )
        ) v,
        hz_geographies g
        WHERE v.geography_id = g.geography_id
        AND   g.country_code = 'US'
        AND NOT EXISTS ( SELECT /*+ordered */'1'
                         FROM  hz_geographies g1,
                               hz_relationships rel
                         WHERE rel.subject_id = g.geography_id
                         AND   rel.subject_type = g.geography_type
                         AND   rel.subject_table_name = 'HZ_GEOGRAPHIES'
                         AND   rel.object_id = g1.geography_id
                         AND   rel.object_type = 'POSTAL_CODE'
                         AND   rel.object_table_name = 'HZ_GEOGRAPHIES'
                         AND   g1.geography_code = v.zip_code
                         AND   g1.geography_type = 'POSTAL_CODE'
                         AND   rel.relationship_type = 'MASTER_REF')
       GROUP BY v.zip_code ,
                v.zip_code ,
                g.geography_id ,
                g.geography_type ,
                g.geography_element1,
                g.geography_element1_id,
                g.geography_element1_code,
                g.geography_element2,
                g.geography_element2_id,
                g.geography_element2_code,
                g.geography_element3,
                g.geography_element3_id,
                g.geography_element3_code,
                g.geography_element4,
                g.geography_element4_id,
                g.geography_element4_code,
                g.country_code;

      l_rows_processed := SQL%ROWCOUNT;

      COMMIT;

      /**ad_parallel_updates_pkg.processed_rowid_range(l_rows_processed,l_end_rowid);

      COMMIT;
      --
      -- get new range of ids
      --
      ad_parallel_updates_pkg.get_rowid_range
      (
       l_start_rowid,
       l_end_rowid,
       l_any_rows_to_process,
       P_batch_size,
       FALSE
      );

    END LOOP;**/

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      retcode := '1';
      errbuf := 'No data found';
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Error in '||l_api_name||': '||errbuf
      );

    WHEN OTHERS THEN
      ROLLBACK;
      retcode := '2';
      errbuf := SQLERRM;
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Unexpected Error in '||l_api_name||': '||errbuf
      );

  END CREATE_ZIP;

  --
  -- Procedure to create geography identifiers for alternate city names
  --
  PROCEDURE CREATE_ALTERNATE_CITIES
  (
    errbuf               OUT NOCOPY VARCHAR2,
    retcode              OUT NOCOPY VARCHAR2,
    p_tax_content_source IN  VARCHAR2,
    p_last_run_version   IN  NUMBER
  ) IS

    l_api_name           CONSTANT VARCHAR2(30):= 'create_alternate_cities';

    -----------------------------------------------------
    -- Ad parallelization variables
    -----------------------------------------------------
    l_table_owner         VARCHAR2(30) := 'ZX';
    l_any_rows_to_process BOOLEAN;
    l_table_name          VARCHAR2(30) := 'ZX_DATA_UPLOAD_INTERFACE';
    l_start_rowid         ROWID;
    l_end_rowid           ROWID;
    l_rows_processed      NUMBER;


  BEGIN

    retcode := '0';

    /**--
    -- Initialize the rowid ranges
    --
    ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           l_table_owner,
           l_table_name,
           p_script_name,
           p_Worker_Id,
           p_Num_Workers,
           p_batch_size, 0);
    --
    -- Get rowid ranges
    --
    ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           p_batch_size,
           TRUE);


    WHILE (l_any_rows_to_process)
    LOOP**/

      INSERT ALL
        INTO HZ_GEOGRAPHY_IDENTIFIERS
          (
           GEOGRAPHY_ID,
           GEO_DATA_PROVIDER,
           IDENTIFIER_SUBTYPE,
           IDENTIFIER_VALUE,
           OBJECT_VERSION_NUMBER,
           IDENTIFIER_TYPE,
           PRIMARY_FLAG,
           LANGUAGE_CODE,
           GEOGRAPHY_USE,
           GEOGRAPHY_TYPE,
           CREATED_BY_MODULE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN
          )
        VALUES
          (
           geography_id,
           p_tax_content_source,
           'STANDARD_NAME',
           geography_name,
           1,
           'NAME',
           'N',
           'US',
           'MASTER_REF',
           geography_type,
           G_CREATED_BY_MODULE,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.conc_login_id
          )
      SELECT DISTINCT inter.geography_id,
             inter.geography_name geography_name,
             'CITY' geography_type
      FROM ZX_DATA_UPLOAD_INTERFACE inter
      WHERE inter.record_type = 07
      AND   inter.last_updation_version > p_last_run_version
      AND   inter.geography_id IS NOT NULL
      AND   NOT EXISTS (SELECT 1
                        FROM HZ_GEOGRAPHY_IDENTIFIERS hgi
                        WHERE hgi.geography_id = inter.geography_id
                        AND   hgi.IDENTIFIER_TYPE = 'NAME'
                        AND   hgi.IDENTIFIER_SUBTYPE = 'STANDARD_NAME'
                        AND   UPPER(hgi.IDENTIFIER_VALUE) = UPPER(inter.geography_name)
                        AND   hgi.LANGUAGE_CODE = 'US');

      l_rows_processed := SQL%ROWCOUNT;

      COMMIT;

      /**ad_parallel_updates_pkg.processed_rowid_range(l_rows_processed,l_end_rowid);

      COMMIT;
      --
      -- get new range of ids
      --
      ad_parallel_updates_pkg.get_rowid_range
      (
       l_start_rowid,
       l_end_rowid,
       l_any_rows_to_process,
       P_batch_size,
       FALSE
      );

    END LOOP;**/

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      retcode := '1';
      errbuf := 'No data found';
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Error in '||l_api_name||': '||errbuf
      );

    WHEN OTHERS THEN
      ROLLBACK;
      retcode := '2';
      errbuf := SQLERRM;
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Unexpected Error in '||l_api_name||': '||errbuf
      );

  END CREATE_ALTERNATE_CITIES;

  --
  -- Procedure to create rates
  --
  PROCEDURE CREATE_RATES
  (
    errbuf               OUT NOCOPY VARCHAR2,
    retcode              OUT NOCOPY VARCHAR2,
    p_tax_content_source IN  VARCHAR2,
    p_last_run_version   IN  NUMBER,
    p_tax_regime_code    IN  VARCHAR2
  ) IS

    l_api_name           CONSTANT VARCHAR2(30):= 'create_rates';

    CURSOR c_get_regime_migrated
    (
      b_regime_code  VARCHAR2
    ) IS
      SELECT decode(record_type_code,'MIGRATED','Y','N')
      FROM zx_regimes_b
      WHERE tax_regime_code = b_regime_code;

    l_table_owner         VARCHAR2(30) := 'ZX';
    l_any_rows_to_process BOOLEAN;
    l_table_name          VARCHAR2(30) := 'ZX_DATA_UPLOAD_INTERFACE';
    l_start_rowid         ROWID;
    l_end_rowid           ROWID;
    l_rows_processed      NUMBER;
    l_migrated_tax_regime_flag VARCHAR2(1);


  BEGIN

    retcode := '0';

    OPEN c_get_regime_migrated(p_tax_regime_code);
    FETCH c_get_regime_migrated
      INTO l_migrated_tax_regime_flag;
    CLOSE c_get_regime_migrated;

    /**--
    -- Initialize the rowid ranges
    --
    ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           l_table_owner,
           l_table_name,
           p_script_name,
           p_Worker_Id,
           p_Num_Workers,
           p_batch_size, 0);
    --
    -- Get rowid ranges
    --
    ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           p_batch_size,
           TRUE);


    WHILE (l_any_rows_to_process)
    LOOP**/
      MERGE INTO ZX_RATES_B_TMP zrbt
        USING (SELECT tax_regime_code,
                      tax,
                      content_owner_id,
                      tax_status_code,
                      tax_jurisdiction_code,
                      tax_rate_code,
                      effective_from,
                      effective_to,
                      rate_type_code,
                      percentage_rate,
                      active_flag,
                      default_rate_flag,
                      RATE_COUNT
               FROM
               (SELECT DISTINCT
                 p_tax_regime_code tax_regime_code,
                 decode(to_char(rt.record_type),'9',rt.sales_tax_authority_level,'10',rt.rental_tax_authority_level,'11',rt.use_tax_authority_level,'12',rt.lease_tax_authority_level) tax,
                 -99 content_owner_id,
                 'STANDARD' tax_status_code,
                 DECODE(decode(to_char(rt.record_type),'9',rt.sales_tax_authority_level,'10',rt.rental_tax_authority_level,'11',rt.use_tax_authority_level,'12',rt.lease_tax_authority_level),
                        'STATE',decode(to_char(jur.record_type),'1','ST-','3','ST-CO-','6','ST-CI-'),
                        'COUNTY',decode(to_char(jur.record_type),'3','CO-','6','CO-CI-'),
                        'CITY','CI-')||
                        decode(p_tax_content_source,
                        'TAXWARE',decode(to_char(jur.record_type),
                                  '1',jur.COUNTRY_STATE_ABBREVIATION,
                                  '3',jur.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,21)),
                                  '6',jur.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,12))||'-'||jur.city_jurisdiction_code),
                        DECODE(to_char(jur.record_type),
                         '1',jur.state_jurisdiction_code||'0000000',
                         '3',jur.state_jurisdiction_code||jur.county_jurisdiction_code||'0000',
                         '6',jur.state_jurisdiction_code||jur.county_jurisdiction_code||LPAD(jur.city_jurisdiction_code,4,'0'))
                 ) tax_jurisdiction_code,
                 decode(l_migrated_tax_regime_flag,'Y','STANDARD','STD')||decode(to_char(rt.record_type),'10','-RENTAL','11','-USE','12','-LEASE') tax_rate_code,
                 decode(greatest(rt.effective_from,G_RECORD_EFFECTIVE_START),rt.effective_from,rt.effective_from,G_RECORD_EFFECTIVE_START) effective_from,
                 rt.effective_to,
                 'PERCENTAGE' rate_type_code,
                 decode(rt.record_type,9,rt.sales_tax_rate,10,rt.rental_tax_rate,11,rt.use_tax_rate,12,rt.lease_tax_rate) percentage_rate,
                 decode(to_char(rt.record_type),'9',rt.sales_tax_rate_active_flag,'10',rt.rental_tax_rate_active_flag,'11',rt.use_tax_rate_active_flag,'12',rt.lease_tax_rate_active_flag) active_flag,
                 decode(to_char(rt.record_type),'9','Y','N') default_rate_flag,
                 count(*)
                   OVER (PARTITION BY
                       p_tax_regime_code,
                       decode(to_char(rt.record_type),'9',rt.sales_tax_authority_level,'10',rt.rental_tax_authority_level,'11',rt.use_tax_authority_level,'12',rt.lease_tax_authority_level) ,
                       -99 ,
                      'STANDARD' ,
                       DECODE(decode(to_char(rt.record_type),'9',rt.sales_tax_authority_level,'10',rt.rental_tax_authority_level,'11',rt.use_tax_authority_level,'12',rt.lease_tax_authority_level),
                        'STATE',decode(to_char(jur.record_type),'1','ST-','3','ST-CO-','6','ST-CI-'),
                        'COUNTY',decode(to_char(jur.record_type),'3','CO-','6','CO-CI-'),
                        'CITY','CI-')||
                        decode(p_tax_content_source,
                        'TAXWARE',decode(to_char(jur.record_type),
                                  '1',jur.COUNTRY_STATE_ABBREVIATION,
                                  '3',jur.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,21)),
                                  '6',jur.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,12))||'-'||jur.city_jurisdiction_code),
                        DECODE(to_char(jur.record_type),
                         '1',jur.state_jurisdiction_code||'0000000',
                         '3',jur.state_jurisdiction_code||jur.county_jurisdiction_code||'0000',
                         '6',jur.state_jurisdiction_code||jur.county_jurisdiction_code||LPAD(jur.city_jurisdiction_code,4,'0'))
                 ) ,
                 decode(l_migrated_tax_regime_flag,'Y','STANDARD','STD')||decode(to_char(rt.record_type),'10','-RENTAL','11','-USE','12','-LEASE') ,
                 decode(greatest(rt.effective_from,G_RECORD_EFFECTIVE_START),rt.effective_from,rt.effective_from,G_RECORD_EFFECTIVE_START)
		       ) AS RATE_COUNT,
                 (SELECT Count(*)
                  FROM zx_rates_b
                  WHERE TAX_REGIME_CODE = p_tax_regime_code
                  AND tax = decode(to_char(rt.record_type),'9',rt.sales_tax_authority_level,'10',rt.rental_tax_authority_level,'11',rt.use_tax_authority_level,'12',rt.lease_tax_authority_level)
                  AND tax_status_code = 'STANDARD'
                  AND content_owner_id = -99
                  AND tax_jurisdiction_code = DECODE(decode(to_char(rt.record_type),'9',rt.sales_tax_authority_level,'10',rt.rental_tax_authority_level,'11',rt.use_tax_authority_level,'12',rt.lease_tax_authority_level),
                        'STATE',decode(to_char(jur.record_type),'1','ST-','3','ST-CO-','6','ST-CI-'),
                        'COUNTY',decode(to_char(jur.record_type),'3','CO-','6','CO-CI-'),
                        'CITY','CI-')||
                        decode(p_tax_content_source,
                        'TAXWARE',decode(to_char(jur.record_type),
                                  '1',jur.COUNTRY_STATE_ABBREVIATION,
                                  '3',jur.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,21)),
                                  '6',jur.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,12))||'-'||jur.city_jurisdiction_code),
                        DECODE(to_char(jur.record_type),
                         '1',jur.state_jurisdiction_code||'0000000',
                         '3',jur.state_jurisdiction_code||jur.county_jurisdiction_code||'0000',
                         '6',jur.state_jurisdiction_code||jur.county_jurisdiction_code||LPAD(jur.city_jurisdiction_code,4,'0')))
                  AND tax_rate_code = decode(l_migrated_tax_regime_flag,'Y','STANDARD','STD')||decode(to_char(rt.record_type),'10','-RENTAL','11','-USE','12','-LEASE')
                  AND effective_from = decode(greatest(rt.effective_from,G_RECORD_EFFECTIVE_START),rt.effective_from,rt.effective_from,G_RECORD_EFFECTIVE_START)
		  ) l_count
          FROM zx_data_upload_interface rt,
               zx_data_upload_interface jur
          where rt.record_type in (9,10,11,12)
          and   rt.last_updation_version > p_last_run_version
          and   nvl(rt.status,'CREATE') <> 'ERROR'
          and   jur.record_type = decode(rt.city_jurisdiction_code,null,decode(rt.county_jurisdiction_code,null,1,3),6)
          and   jur.state_jurisdiction_code = rt.state_jurisdiction_code
          and   nvl(jur.county_jurisdiction_code,'-1') = nvl(rt.county_jurisdiction_code,'-1')
          and   nvl(jur.city_jurisdiction_code,'-1') = nvl(rt.city_jurisdiction_code,'-1')
          and   nvl(jur.primary_flag,'Y') = 'Y'
          and   jur.effective_to is null)
	  where RATE_COUNT = 1
	  and (l_count = 1 OR l_count = 0))v
        ON (zrbt.tax_regime_code = v.tax_regime_code
            and zrbt.content_owner_id = v.content_owner_id
            and zrbt.tax = v.tax
            and zrbt.tax_status_code = v.tax_status_code
            and zrbt.tax_jurisdiction_code = v.tax_jurisdiction_code
            and zrbt.tax_rate_code = v.tax_rate_code
            and zrbt.effective_from = v.effective_from)
        WHEN NOT MATCHED THEN
          INSERT
          (
           zrbt.TAX_RATE_ID,
           zrbt.OBJECT_VERSION_NUMBER,
           zrbt.TAX_RATE_CODE,
           zrbt.TAX_REGIME_CODE,
           zrbt.TAX,
           zrbt.TAX_STATUS_CODE,
           zrbt.TAX_JURISDICTION_CODE,
           zrbt.CONTENT_OWNER_ID,
           zrbt.ACTIVE_FLAG,
           zrbt.EFFECTIVE_FROM,
           zrbt.EFFECTIVE_TO,
           zrbt.DEFAULT_RATE_FLAG,
           zrbt.DEFAULT_FLG_EFFECTIVE_FROM,
           zrbt.DEFAULT_FLG_EFFECTIVE_TO,
           zrbt.RATE_TYPE_CODE,
           zrbt.PERCENTAGE_RATE,
           zrbt.ALLOW_EXEMPTIONS_FLAG,
           zrbt.ALLOW_EXCEPTIONS_FLAG,
           zrbt.RECORD_TYPE_CODE,
           zrbt.CREATED_BY,
           zrbt.CREATION_DATE,
           zrbt.LAST_UPDATED_BY,
           zrbt.LAST_UPDATE_DATE,
           zrbt.LAST_UPDATE_LOGIN
          )
        VALUES
          (
           zx_rates_b_s.nextval,
           1,
           v.TAX_RATE_CODE,
           v.TAX_REGIME_CODE,
           v.TAX,
           v.TAX_STATUS_CODE,
           v.TAX_JURISDICTION_CODE,
           v.CONTENT_OWNER_ID,
           v.ACTIVE_FLAG,
           v.EFFECTIVE_FROM,
           v.EFFECTIVE_TO,
           v.default_rate_flag,
           decode(v.default_rate_flag,'Y',v.EFFECTIVE_FROM,NULL),
           decode(v.default_rate_flag,'Y',v.EFFECTIVE_TO,NULL),
           v.RATE_TYPE_CODE,
           v.PERCENTAGE_RATE,
           'Y',
           'Y',
           G_CREATED_BY_MODULE,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.conc_login_id
          )
        WHEN MATCHED THEN
          UPDATE SET zrbt.PERCENTAGE_RATE = v.percentage_rate,
	             zrbt.EFFECTIVE_TO = v.effective_to,
                     zrbt.DEFAULT_FLG_EFFECTIVE_TO = v.effective_to,
                     zrbt.ACTIVE_FLAG = v.active_flag,
                     zrbt.LAST_UPDATED_BY = fnd_global.user_id,
                     zrbt.LAST_UPDATE_DATE = sysdate,
                     zrbt.LAST_UPDATE_LOGIN = fnd_global.conc_login_id;

      l_rows_processed := SQL%ROWCOUNT;

      -- added this to ensure that when we have two rate records with same effectivity, then
      -- active_flag is not updated as it needs to be included in the ON clause
      -- also need to update percentage_rate for this case.

      MERGE INTO ZX_RATES_B_TMP zrbt
        USING (SELECT tax_regime_code,
                      tax,
                      content_owner_id,
                      tax_status_code,
                      tax_jurisdiction_code,
                      tax_rate_code,
                      effective_from,
                      effective_to,
                      rate_type_code,
                      percentage_rate,
                      active_flag,
                      default_rate_flag,
                      RATE_COUNT
               FROM
               (SELECT DISTINCT
                 p_tax_regime_code tax_regime_code,
                 decode(to_char(rt.record_type),'9',rt.sales_tax_authority_level,'10',rt.rental_tax_authority_level,'11',rt.use_tax_authority_level,'12',rt.lease_tax_authority_level) tax,
                 -99 content_owner_id,
                 'STANDARD' tax_status_code,
                 DECODE(decode(to_char(rt.record_type),'9',rt.sales_tax_authority_level,'10',rt.rental_tax_authority_level,'11',rt.use_tax_authority_level,'12',rt.lease_tax_authority_level),
                        'STATE',decode(to_char(jur.record_type),'1','ST-','3','ST-CO-','6','ST-CI-'),
                        'COUNTY',decode(to_char(jur.record_type),'3','CO-','6','CO-CI-'),
                        'CITY','CI-')||
                        decode(p_tax_content_source,
                        'TAXWARE',decode(to_char(jur.record_type),
                                  '1',jur.COUNTRY_STATE_ABBREVIATION,
                                  '3',jur.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,21)),
                                  '6',jur.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,12))||'-'||jur.city_jurisdiction_code),
                        DECODE(to_char(jur.record_type),
                         '1',jur.state_jurisdiction_code||'0000000',
                         '3',jur.state_jurisdiction_code||jur.county_jurisdiction_code||'0000',
                         '6',jur.state_jurisdiction_code||jur.county_jurisdiction_code||LPAD(jur.city_jurisdiction_code,4,'0'))
                 ) tax_jurisdiction_code,
                 decode(l_migrated_tax_regime_flag,'Y','STANDARD','STD')||decode(to_char(rt.record_type),'10','-RENTAL','11','-USE','12','-LEASE') tax_rate_code,
                 decode(greatest(rt.effective_from,G_RECORD_EFFECTIVE_START),rt.effective_from,rt.effective_from,G_RECORD_EFFECTIVE_START) effective_from,
                 rt.effective_to,
                 'PERCENTAGE' rate_type_code,
                 decode(rt.record_type,9,rt.sales_tax_rate,10,rt.rental_tax_rate,11,rt.use_tax_rate,12,rt.lease_tax_rate) percentage_rate,
                 decode(to_char(rt.record_type),'9',rt.sales_tax_rate_active_flag,'10',rt.rental_tax_rate_active_flag,'11',rt.use_tax_rate_active_flag,'12',rt.lease_tax_rate_active_flag) active_flag,
                 decode(to_char(rt.record_type),'9','Y','N') default_rate_flag,
                 count(*)
                   OVER (PARTITION BY
                       p_tax_regime_code,
                       decode(to_char(rt.record_type),'9',rt.sales_tax_authority_level,'10',rt.rental_tax_authority_level,'11',rt.use_tax_authority_level,'12',rt.lease_tax_authority_level) ,
                       -99 ,
                      'STANDARD' ,
                       DECODE(decode(to_char(rt.record_type),'9',rt.sales_tax_authority_level,'10',rt.rental_tax_authority_level,'11',rt.use_tax_authority_level,'12',rt.lease_tax_authority_level),
                        'STATE',decode(to_char(jur.record_type),'1','ST-','3','ST-CO-','6','ST-CI-'),
                        'COUNTY',decode(to_char(jur.record_type),'3','CO-','6','CO-CI-'),
                        'CITY','CI-')||
                        decode(p_tax_content_source,
                        'TAXWARE',decode(to_char(jur.record_type),
                                  '1',jur.COUNTRY_STATE_ABBREVIATION,
                                  '3',jur.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,21)),
                                  '6',jur.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,12))||'-'||jur.city_jurisdiction_code),
                        DECODE(to_char(jur.record_type),
                         '1',jur.state_jurisdiction_code||'0000000',
                         '3',jur.state_jurisdiction_code||jur.county_jurisdiction_code||'0000',
                         '6',jur.state_jurisdiction_code||jur.county_jurisdiction_code||LPAD(jur.city_jurisdiction_code,4,'0'))
                        ) ,
                        decode(l_migrated_tax_regime_flag,'Y','STANDARD','STD')||decode(to_char(rt.record_type),'10','-RENTAL','11','-USE','12','-LEASE') ,
                        decode(greatest(rt.effective_from,G_RECORD_EFFECTIVE_START),rt.effective_from,rt.effective_from,G_RECORD_EFFECTIVE_START)
                 ) AS RATE_COUNT,
                 (SELECT Count(*)
                  FROM zx_rates_b
                  WHERE TAX_REGIME_CODE = p_tax_regime_code
                  AND tax = decode(to_char(rt.record_type),'9',rt.sales_tax_authority_level,'10',rt.rental_tax_authority_level,'11',rt.use_tax_authority_level,'12',rt.lease_tax_authority_level)
                  AND tax_status_code = 'STANDARD'
                  AND content_owner_id = -99
                  AND tax_jurisdiction_code = DECODE(decode(to_char(rt.record_type),'9',rt.sales_tax_authority_level,'10',rt.rental_tax_authority_level,'11',rt.use_tax_authority_level,'12',rt.lease_tax_authority_level),
                        'STATE',decode(to_char(jur.record_type),'1','ST-','3','ST-CO-','6','ST-CI-'),
                        'COUNTY',decode(to_char(jur.record_type),'3','CO-','6','CO-CI-'),
                        'CITY','CI-')||
                        decode(p_tax_content_source,
                        'TAXWARE',decode(to_char(jur.record_type),
                                  '1',jur.COUNTRY_STATE_ABBREVIATION,
                                  '3',jur.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,21)),
                                  '6',jur.COUNTRY_STATE_ABBREVIATION||'-'||UPPER(SUBSTRB(jur.GEOGRAPHY_NAME,1,12))||'-'||jur.city_jurisdiction_code),
                        DECODE(to_char(jur.record_type),
                         '1',jur.state_jurisdiction_code||'0000000',
                         '3',jur.state_jurisdiction_code||jur.county_jurisdiction_code||'0000',
                         '6',jur.state_jurisdiction_code||jur.county_jurisdiction_code||LPAD(jur.city_jurisdiction_code,4,'0')))
                  AND tax_rate_code = decode(l_migrated_tax_regime_flag,'Y','STANDARD','STD')||decode(to_char(rt.record_type),'10','-RENTAL','11','-USE','12','-LEASE')
                  AND effective_from = decode(greatest(rt.effective_from,G_RECORD_EFFECTIVE_START),rt.effective_from,rt.effective_from,G_RECORD_EFFECTIVE_START)
		  ) l_count
          FROM zx_data_upload_interface rt,
               zx_data_upload_interface jur
          where rt.record_type in (9,10,11,12)
          and   rt.last_updation_version > p_last_run_version
          and   nvl(rt.status,'CREATE') <> 'ERROR'
          and   jur.record_type = decode(rt.city_jurisdiction_code,null,decode(rt.county_jurisdiction_code,null,1,3),6)
          and   jur.state_jurisdiction_code = rt.state_jurisdiction_code
          and   nvl(jur.county_jurisdiction_code,'-1') = nvl(rt.county_jurisdiction_code,'-1')
          and   nvl(jur.city_jurisdiction_code,'-1') = nvl(rt.city_jurisdiction_code,'-1')
          and   NVL(jur.primary_flag,'Y') = 'Y'
          and   jur.effective_to is null)
	  where RATE_COUNT > 1
	  OR (l_count > 1 or l_count = 0))v
        ON (zrbt.tax_regime_code = v.tax_regime_code
            and zrbt.content_owner_id = v.content_owner_id
            and zrbt.tax = v.tax
            and zrbt.tax_status_code = v.tax_status_code
            and zrbt.tax_jurisdiction_code = v.tax_jurisdiction_code
            and zrbt.tax_rate_code = v.tax_rate_code
            and zrbt.effective_from = v.effective_from
	    and zrbt.active_flag = v.active_flag
	   )
        WHEN NOT MATCHED THEN
          INSERT
          (
           zrbt.TAX_RATE_ID,
           zrbt.OBJECT_VERSION_NUMBER,
           zrbt.TAX_RATE_CODE,
           zrbt.TAX_REGIME_CODE,
           zrbt.TAX,
           zrbt.TAX_STATUS_CODE,
           zrbt.TAX_JURISDICTION_CODE,
           zrbt.CONTENT_OWNER_ID,
           zrbt.ACTIVE_FLAG,
           zrbt.EFFECTIVE_FROM,
           zrbt.EFFECTIVE_TO,
           zrbt.DEFAULT_RATE_FLAG,
           zrbt.DEFAULT_FLG_EFFECTIVE_FROM,
           zrbt.DEFAULT_FLG_EFFECTIVE_TO,
           zrbt.RATE_TYPE_CODE,
           zrbt.PERCENTAGE_RATE,
           zrbt.ALLOW_EXEMPTIONS_FLAG,
           zrbt.ALLOW_EXCEPTIONS_FLAG,
           zrbt.RECORD_TYPE_CODE,
           zrbt.CREATED_BY,
           zrbt.CREATION_DATE,
           zrbt.LAST_UPDATED_BY,
           zrbt.LAST_UPDATE_DATE,
           zrbt.LAST_UPDATE_LOGIN
          )
        VALUES
          (
           zx_rates_b_s.nextval,
           1,
           v.TAX_RATE_CODE,
           v.TAX_REGIME_CODE,
           v.TAX,
           v.TAX_STATUS_CODE,
           v.TAX_JURISDICTION_CODE,
           v.CONTENT_OWNER_ID,
           v.ACTIVE_FLAG,
           v.EFFECTIVE_FROM,
           v.EFFECTIVE_TO,
           v.default_rate_flag,
           decode(v.default_rate_flag,'Y',v.EFFECTIVE_FROM,NULL),
           decode(v.default_rate_flag,'Y',v.EFFECTIVE_TO,NULL),
           v.RATE_TYPE_CODE,
           v.PERCENTAGE_RATE,
           'Y',
           'Y',
           G_CREATED_BY_MODULE,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.conc_login_id
          )
        WHEN MATCHED THEN
          UPDATE SET zrbt.PERCENTAGE_RATE = v.percentage_rate,
	             zrbt.EFFECTIVE_TO = v.effective_to,
                     zrbt.DEFAULT_FLG_EFFECTIVE_TO = v.effective_to,
                     zrbt.LAST_UPDATED_BY = fnd_global.user_id,
                     zrbt.LAST_UPDATE_DATE = sysdate,
                     zrbt.LAST_UPDATE_LOGIN = fnd_global.conc_login_id;

      l_rows_processed := SQL%ROWCOUNT;

      -- Create rates with NULL Jurisdiction codes
      -- Used for Partner tax calculation.
      INSERT ALL INTO ZX_RATES_B_TMP
      (
           TAX_RATE_ID,
           OBJECT_VERSION_NUMBER,
           TAX_RATE_CODE,
           TAX_REGIME_CODE,
           TAX,
           TAX_STATUS_CODE,
           TAX_JURISDICTION_CODE,
           CONTENT_OWNER_ID,
           ACTIVE_FLAG,
           EFFECTIVE_FROM,
           EFFECTIVE_TO,
           DEFAULT_RATE_FLAG,
           DEFAULT_FLG_EFFECTIVE_FROM,
           DEFAULT_FLG_EFFECTIVE_TO,
           RATE_TYPE_CODE,
           PERCENTAGE_RATE,
           ALLOW_EXEMPTIONS_FLAG,
           ALLOW_EXCEPTIONS_FLAG,
           RECORD_TYPE_CODE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN
          )
        VALUES
          (
           zx_rates_b_s.nextval,
           1,
           TAX,
           TAX_REGIME_CODE,
           TAX,
           'STANDARD',
           NULL,
           -99,
           'Y',
           decode(greatest(EFFECTIVE_FROM,G_RECORD_EFFECTIVE_START),EFFECTIVE_FROM,EFFECTIVE_FROM,G_RECORD_EFFECTIVE_START),
           NULL,
           'Y',
           decode(greatest(EFFECTIVE_FROM,G_RECORD_EFFECTIVE_START),EFFECTIVE_FROM,EFFECTIVE_FROM,G_RECORD_EFFECTIVE_START),
           NULL,
           'PERCENTAGE',
           0,
           'Y',
           'Y',
           G_CREATED_BY_MODULE,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.conc_login_id
          )
          SELECT tax.TAX_REGIME_CODE  TAX_REGIME_CODE,
                 tax.TAX              TAX,
                 tax.EFFECTIVE_FROM   EFFECTIVE_FROM
          FROM ZX_TAXES_B tax
          WHERE tax.TAX_REGIME_CODE = p_tax_regime_code
          AND tax.RECORD_TYPE_CODE  = G_CREATED_BY_MODULE
          AND tax.CONTENT_OWNER_ID  = -99                            -- Condition Added as a fix for Bug#8286647
          AND NOT EXISTS (SELECT 1 FROM ZX_RATES_B rate
                          WHERE rate.TAX_RATE_CODE = tax.TAX
                          AND rate.CONTENT_OWNER_ID = -99
                          AND rate.TAX_JURISDICTION_CODE IS NULL
                          AND rate.EFFECTIVE_FROM = tax.EFFECTIVE_FROM
                          AND rate.ACTIVE_FLAG = 'Y');

      -- Copy accounts from jurisdiction
      -- Do this only for newly created rates
      -- Use TL table and regime/tax/record type combination to find new ones
      INSERT INTO ZX_ACCOUNTS
      (
        TAX_ACCOUNT_ID,
        OBJECT_VERSION_NUMBER,
        TAX_ACCOUNT_ENTITY_CODE,
        TAX_ACCOUNT_ENTITY_ID,
        LEDGER_ID,
        INTERNAL_ORGANIZATION_ID,
        TAX_ACCOUNT_CCID,
        INTERIM_TAX_CCID,
        NON_REC_ACCOUNT_CCID,
        ADJ_CCID,
        EDISC_CCID,
        UNEDISC_CCID,
        FINCHRG_CCID,
        ADJ_NON_REC_TAX_CCID,
        EDISC_NON_REC_TAX_CCID,
        UNEDISC_NON_REC_TAX_CCID,
        FINCHRG_NON_REC_TAX_CCID,
        RECORD_TYPE_CODE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
      )
      SELECT
        zx_accounts_s.nextval,
        1,
        'RATES',
        zrb.TAX_RATE_ID,
        za.LEDGER_ID,
        za.INTERNAL_ORGANIZATION_ID,
        za.TAX_ACCOUNT_CCID,
        za.INTERIM_TAX_CCID,
        za.NON_REC_ACCOUNT_CCID,
        za.ADJ_CCID,
        za.EDISC_CCID,
        za.UNEDISC_CCID,
        za.FINCHRG_CCID,
        za.ADJ_NON_REC_TAX_CCID,
        za.EDISC_NON_REC_TAX_CCID,
        za.UNEDISC_NON_REC_TAX_CCID,
        za.FINCHRG_NON_REC_TAX_CCID,
        G_CREATED_BY_MODULE,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.conc_login_id
      FROM ZX_RATES_B zrb,
           ZX_JURISDICTIONS_B zjb,
           ZX_ACCOUNTS za
      WHERE zrb.TAX_REGIME_CODE = p_tax_regime_code
      AND   zrb.TAX IN ('STATE','COUNTY','CITY')
      AND   zrb.CONTENT_OWNER_ID = -99
      AND   zrb.RECORD_TYPE_CODE = G_CREATED_BY_MODULE
      AND   NOT EXISTS (SELECT NULL
                        FROM ZX_RATES_TL zrt
                        WHERE zrt.TAX_RATE_ID = zrb.TAX_RATE_ID)
      AND   zjb.TAX_REGIME_CODE = zrb.TAX_REGIME_CODE
      AND   zjb.TAX = zrb.TAX
      AND   zjb.TAX_JURISDICTION_CODE = zrb.TAX_JURISDICTION_CODE
      AND   za.TAX_ACCOUNT_ENTITY_CODE = 'JURISDICTION'
      AND   za.TAX_ACCOUNT_ENTITY_ID = zjb.TAX_JURISDICTION_ID;

      INSERT INTO ZX_RATES_TL
      (
       TAX_RATE_ID,
       TAX_RATE_NAME,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN,
       LANGUAGE,
       SOURCE_LANG
      )
      SELECT zrb.TAX_RATE_ID,
             zrb.TAX_RATE_CODE,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.conc_login_id,
             fl.LANGUAGE_CODE,
             USERENV('LANG')
      FROM ZX_RATES_B zrb,
           FND_LANGUAGES fl
      WHERE fl.INSTALLED_FLAG IN ('I', 'B')
      AND   zrb.TAX_REGIME_CODE = p_tax_regime_code
      AND   zrb.CONTENT_OWNER_ID = -99
      AND   zrb.TAX IN ('STATE','COUNTY','CITY')
      AND   NOT EXISTS (SELECT NULL
                        FROM ZX_RATES_TL zrt
                        WHERE zrt.TAX_RATE_ID = zrb.TAX_RATE_ID
                        AND   zrt.LANGUAGE = fl.LANGUAGE_CODE);

      l_rows_processed := SQL%ROWCOUNT;

      -- make the tax live for processing if there is atleast one rate defined for the tax
      UPDATE ZX_TAXES_B_TMP tax
      SET tax.LIVE_FOR_PROCESSING_FLAG = 'Y'
      WHERE tax.RECORD_TYPE_CODE = G_CREATED_BY_MODULE
      AND tax.TAX_REGIME_CODE = p_tax_regime_code
      AND tax.CONTENT_OWNER_ID  = -99                                -- Condition Added as a fix for Bug#8286647
      AND EXISTS (SELECT 1
                  FROM ZX_RATES_B rate
                  WHERE rate.TAX_REGIME_CODE = tax.TAX_REGIME_CODE
                  AND rate.TAX = tax.TAX
                  AND rate.CONTENT_OWNER_ID  = -99                   -- Condition Added as a fix for Bug#8286647
                  AND rate.RECORD_TYPE_CODE = G_CREATED_BY_MODULE);

      COMMIT;

     /**ad_parallel_updates_pkg.processed_rowid_range(l_rows_processed,l_end_rowid);

      COMMIT;
      --
      -- get new range of ids
      --
      ad_parallel_updates_pkg.get_rowid_range
      (
       l_start_rowid,
       l_end_rowid,
       l_any_rows_to_process,
       P_batch_size,
       FALSE
      );

    END LOOP;**/

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      retcode := '1';
      errbuf := 'No data found';
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Error in '||l_api_name||': '||errbuf
      );

    WHEN OTHERS THEN
      ROLLBACK;
      retcode := '2';
      errbuf := SQLERRM;
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Unexpected Error in '||l_api_name||': '||errbuf
      );

  END CREATE_RATES;

  --
  -- Procedure to pre-process interface data and call other programs
  --
  PROCEDURE PROCESS_DATA
  (
    errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY VARCHAR2,
    p_batch_size            IN  NUMBER,
    p_num_workers           IN  NUMBER,
    p_tax_content_source_id IN  NUMBER,
    p_tax_regime_code       IN  VARCHAR2
  ) IS

    l_api_name           CONSTANT VARCHAR2(30):= 'process_data';
    l_error              EXCEPTION;

    CURSOR c_get_regime_migrated
    (
      b_regime_code  VARCHAR2
    ) IS
      SELECT decode(record_type_code,'MIGRATED','Y','N')
      FROM zx_regimes_b
      WHERE tax_regime_code = b_regime_code;

    CURSOR c_get_last_run
    (
      b_ptp_id      NUMBER,
      b_regime_code VARCHAR2
    ) IS
      SELECT NVL(VERSION_LOADED,'0')
      FROM ZX_CONTENT_SOURCES
      WHERE PROVIDER_ID = b_ptp_id
      AND   STANDARD_REGIME_CODE = b_regime_code;

    l_migrated_tax_regime_flag  VARCHAR2(1);
    l_tax_content_source        VARCHAR2(80);
    l_tax_zone_type             VARCHAR2(30);
    l_last_run_version          NUMBER;
    l_request_id                NUMBER;
    l_req_data                  VARCHAR2(255);
    l_current_pos               NUMBER;
    l_next_pos                  NUMBER;
    l_check_status              BOOLEAN;
    l_phase                     VARCHAR2(255);
    l_dev_phase                 VARCHAR2(255);
    l_status                    VARCHAR2(255);
    l_dev_status                VARCHAR2(255);
    l_message                   VARCHAR2(255);
    l_submit_phase              NUMBER;

  BEGIN

    retcode := '0';

    IF (p_tax_content_source_id = 1)
    THEN
      l_tax_content_source := 'VERTEX';
      l_tax_zone_type      := 'US_ZONE_TYPE_VERTEX';
    ELSIF (p_tax_content_source_id = 2)
    THEN
      l_tax_content_source := 'TAXWARE';
      l_tax_zone_type      := 'US_ZONE_TYPE_TAXWARE';
    ELSIF (p_tax_content_source_id = 3)
    THEN
      l_tax_content_source := 'OTHER TAX PARTNER';
      l_tax_zone_type      := 'US_ZONE_TYPE_TAX_PARTNER';
    ELSE
      errbuf := 'The specified content source provider is not supported. Contact support.';
      RAISE l_error;
    END IF;

    OPEN c_get_regime_migrated(p_tax_regime_code);
    FETCH c_get_regime_migrated
      INTO l_migrated_tax_regime_flag;
    CLOSE c_get_regime_migrated;

    IF (l_migrated_tax_regime_flag = 'Y')
    THEN
      l_tax_zone_type := NULL;
    END IF;

    OPEN c_get_last_run(p_tax_content_source_id,p_tax_regime_code);
    FETCH c_get_last_run
      INTO l_last_run_version;
    CLOSE c_get_last_run;

    IF (l_last_run_version IS NULL)
    THEN
      l_last_run_version := 0;
    END IF;

    l_req_data := fnd_conc_global.request_data;

    IF (l_req_data IS NULL)
    THEN

      -- Call method to stamp ids
      GENERATE_GEOGRAPHY_ID
      (
        l_tax_content_source,
        p_tax_regime_code,
        l_migrated_tax_regime_flag,
        l_tax_zone_type,
        l_last_run_version
      );

      COMMIT;

      -- Call method to do error processing
      DO_ERROR_CHECK
      (
        l_tax_content_source,
        l_last_run_version,
        p_tax_regime_code,
        l_migrated_tax_regime_flag
      );

      COMMIT;

      IF (l_tax_zone_type IS NOT NULL)
      THEN
        -- Call method to setup initial data
        SETUP_DATA
        (
          errbuf,
          retcode,
          l_tax_content_source,
          p_tax_regime_code,
          l_tax_zone_type
        );
        IF (retcode <> '0')
        THEN
          errbuf := 'Setup_data failed with: '||errbuf;
          RAISE l_error;
        END IF;

        COMMIT;
      END IF;

      l_submit_phase := 1;

    ELSE

      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Starting status check of sub-request, ids obtained from global: '||l_req_data
      );
      -- Check status of sub-requests
      l_current_pos := INSTR(l_req_data,'-',1);
      IF (l_current_pos > 0)
      THEN
        IF ('RUNGEO' = SUBSTR(l_req_data,1,l_current_pos-1))
        THEN
          l_submit_phase := 2;
        ELSIF ('RUNZONE' = SUBSTR(l_req_data,1,l_current_pos-1))
        THEN
          l_submit_phase := 3;
        END IF;
      END IF;

      WHILE (l_current_pos <> 0)
      LOOP
        l_next_pos := INSTR(l_req_data,'-',l_current_pos+1);
        IF (l_next_pos = 0)
        THEN
          l_request_id := TO_NUMBER(SUBSTR(l_req_data,l_current_pos+1));
        ELSE
          l_request_id := TO_NUMBER(SUBSTR(l_req_data,l_current_pos+1,l_next_pos-l_current_pos-1));
        END IF;
        IF (l_request_id IS NOT NULL)
        THEN
          l_check_status := FND_CONCURRENT.GET_REQUEST_STATUS
                            (
                              request_id  => l_request_id,
                              phase       => l_phase,
                              status      => l_status,
                              dev_phase   => l_dev_phase,
                              dev_status  => l_dev_status,
                              message     => l_message
                            );
          FND_FILE.PUT_LINE
          (
            FND_FILE.LOG,
            'Checking status of sub-request, id: '||l_request_id||', return dev status value:'||l_dev_status||', return status value:'||l_status
          );
          IF (l_check_status AND (l_dev_status = 'ERROR'))
          THEN
            errbuf := 'Sub-request failed with error: '||l_message;
            RAISE l_error;
          END IF;
        END IF;
        l_current_pos := l_next_pos;
      END LOOP;

    END IF;

    IF (l_submit_phase = 1)
    THEN

      l_req_data := 'RUNGEO';

      l_request_id  := fnd_request.submit_request
                       (
                         application      => 'ZX',
                         program          => 'ZXUPMGEOWKR',
                         sub_request      => true,
                         argument1        => p_batch_size,
                         argument2        => 1,
                         argument3        => p_num_workers,
                         argument4        => l_tax_content_source,
                         argument5        => l_last_run_version
                       );
      IF (l_request_id = 0)
      THEN
        errbuf := 'E-Business Tax Content Upload Master Geography Program submission failed. Contact support.';
        RAISE l_error;
      END IF;

      l_req_data := l_req_data||'-'||l_request_id;

      errbuf := 'Sub-requests Submitted.';

      fnd_conc_global.set_req_globals
      (
        conc_status => 'PAUSED',
        request_data => l_req_data
      );

    ELSIF (l_submit_phase = 2)
    THEN

      l_req_data := 'RUNZONE';
      l_request_id  := fnd_request.submit_request
                       (
                         application      => 'ZX',
                         program          => 'ZXUPTGEOWKR',
                         sub_request      => true,
                         argument1        => l_tax_content_source,
                         argument2        => l_last_run_version,
                         argument3        => p_tax_regime_code,
                         argument4        => l_tax_zone_type
                       );
      IF (l_request_id = 0)
      THEN
        errbuf := 'E-Business Tax Content Upload Tax Zone Program submission failed. Contact support.';
        RAISE l_error;
      END IF;

      l_req_data := l_req_data||'-'||l_request_id;

      l_request_id  := fnd_request.submit_request
                       (
                         application      => 'ZX',
                         program          => 'ZXUPMALTCITY',
                         sub_request      => true,
                         argument1        => l_tax_content_source,
                         argument2        => l_last_run_version
                       );
      IF (l_request_id = 0)
      THEN
        errbuf := 'E-Business Tax Content Upload Alternate City Geography Program submission failed. Contact support.';
        RAISE l_error;
      END IF;

      l_req_data := l_req_data||'-'||l_request_id;

      errbuf := 'Sub-requests Submitted.';

      fnd_conc_global.set_req_globals
      (
        conc_status => 'PAUSED',
        request_data => l_req_data
      );

    ELSIF (l_submit_phase = 3)
    THEN

      l_req_data := 'RUNRATE';
      l_request_id  := fnd_request.submit_request
                       (
                         application      => 'ZX',
                         program          => 'ZXUPMZIPWKR',
                         sub_request      => true,
                         argument1        => l_tax_content_source,
                         argument2        => l_last_run_version
                       );
      IF (l_request_id = 0)
      THEN
        errbuf := 'E-Business Tax Content Upload Exploded Zip Program submission failed. Contact support.';
        RAISE l_error;
      END IF;

      l_req_data := l_req_data||'-'||l_request_id;

      l_request_id  := fnd_request.submit_request
                       (
                         application      => 'ZX',
                         program          => 'ZXUPTRATEWKR',
                         sub_request      => true,
                         argument1        => l_tax_content_source,
                         argument2        => l_last_run_version,
                         argument3        => p_tax_regime_code
                       );
      IF (l_request_id = 0)
      THEN
        errbuf := 'E-Business Tax Content Upload Tax Rates Program submission failed. Contact support.';
        RAISE l_error;
      END IF;

      l_req_data := l_req_data||'-'||l_request_id;

      errbuf := 'Sub-requests Submitted.';

      fnd_conc_global.set_req_globals
      (
        conc_status => 'PAUSED',
        request_data => l_req_data
      );

    END IF;

  EXCEPTION

    WHEN l_error THEN
      ROLLBACK;
      retcode := '2';
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Error in '||l_api_name||': '||errbuf
      );

    WHEN OTHERS THEN
      ROLLBACK;
      retcode := '2';
      errbuf := SQLERRM;
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Unexpected Error in '||l_api_name||': '||errbuf
      );

  END PROCESS_DATA;

  --
  -- Procedure to post-process interface data and call other programs
  --
  PROCEDURE POST_PROCESS_DATA
  (
    errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY VARCHAR2,
    p_tax_content_source_id IN  NUMBER,
    p_tax_regime_code       IN  VARCHAR2,
    p_file_location_name    IN  VARCHAR2
  ) IS

    l_api_name           CONSTANT VARCHAR2(30):= 'post_process_data';
    l_error              EXCEPTION;

    CURSOR c_get_max_version
    IS
    SELECT MAX(LAST_UPDATION_VERSION)
    FROM ZX_DATA_UPLOAD_INTERFACE;

    CURSOR c_get_regime_name
    (
      b_tax_regime_code  VARCHAR2
    ) IS
    SELECT TAX_REGIME_NAME,
           COUNTRY_CODE
    FROM ZX_REGIMES_VL
    WHERE TAX_REGIME_CODE = b_tax_regime_code;

    l_last_run_version    NUMBER;
    l_tax_regime_name     VARCHAR2(240);
    l_country_code        VARCHAR2(30);
    l_file_location       VARCHAR2(240);
    l_file_name           VARCHAR2(240);
    l_position            NUMBER;
    l_file_start          NUMBER;

  BEGIN

    retcode := '0';

    OPEN c_get_max_version;
    FETCH c_get_max_version
      INTO l_last_run_version;
    CLOSE c_get_max_version;

    IF (l_last_run_version IS NULL)
    THEN
      errbuf := 'Could not find last update version from the interface table. Contact support.';
    ELSE
      OPEN c_get_regime_name(p_tax_regime_code);
      FETCH c_get_regime_name
        INTO l_tax_regime_name,l_country_code;
      CLOSE c_get_regime_name;

      l_file_start := 1;
      l_position   := 1;
      WHILE (l_position <> 0)
      LOOP
        l_position := INSTR(p_file_location_name,'/',l_file_start);
        IF (l_position = 0)
        THEN
          l_file_location := SUBSTR(p_file_location_name,1,l_file_start-1);
          l_file_name     := SUBSTR(p_file_location_name,l_file_start);
          EXIT;
        END IF;
        l_file_start := l_position + 1;
      END LOOP;

      UPDATE ZX_CONTENT_SOURCES
      SET PROVIDER_REGIME_CODE   = p_tax_regime_code,
          PROVIDER_REGIME_NAME   = l_tax_regime_name,
          LANGUAGE               = USERENV('LANG'),
          COUNTRY_CODE           = l_country_code,
          VERSION_LOADED         = TO_CHAR(l_last_run_version),
          CONTENT_FILE_LOCATION  = l_file_location,
          CONTENT_FILE_NAME      = l_file_name,
          PROGRAM_ID             = FND_GLOBAL.CONC_PROGRAM_ID,
          PROGRAM_APPLICATION_ID = FND_GLOBAL.PROG_APPL_ID,
          PROGRAM_UPDATE_DATE    = SYSDATE
      WHERE PROVIDER_ID = p_tax_content_source_id
      AND   STANDARD_REGIME_CODE = p_tax_regime_code;

      IF (SQL%ROWCOUNT = 0)
      THEN
        INSERT INTO ZX_CONTENT_SOURCES
        (
          PROVIDER_ID,
          PROVIDER_REGIME_CODE,
          PROVIDER_REGIME_NAME,
          LANGUAGE,
          STANDARD_REGIME_CODE,
          COUNTRY_CODE,
          LOADED_FOR_GCO_FLAG,
          REGIME_PURPOSE_CODE,
          ENTITY_GROUP_CODE,
          VERSION_LOADED,
          POINT_RELEASE_VERSION_LOADED,
          CONTENT_FILE_TYPE,
          CONTENT_FILE_LOCATION,
          CONTENT_FILE_NAME,
          PROGRAM_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_UPDATE_DATE
        )
        VALUES
        (
          p_tax_content_source_id,
          p_tax_regime_code,
          l_tax_regime_name,
          USERENV('LANG'),
          p_tax_regime_code,
          l_country_code,
          'Y',
          'CONTENT',
          NULL,
          TO_CHAR(l_last_run_version),
          '0',
          'LOADER',
          l_file_location,
          l_file_name,
          FND_GLOBAL.CONC_PROGRAM_ID,
          FND_GLOBAL.PROG_APPL_ID,
          SYSDATE
        );
      ELSIF (SQL%ROWCOUNT <> 1)
      THEN
        errbuf := 'Could not update last update version. Contact support.';
      END IF;
    END IF;

  EXCEPTION

    WHEN l_error THEN
      ROLLBACK;
      retcode := '2';
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Error in '||l_api_name||': '||errbuf
      );

    WHEN OTHERS THEN
      ROLLBACK;
      retcode := '2';
      errbuf := SQLERRM;
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Unexpected Error in '||l_api_name||': '||errbuf
      );

  END POST_PROCESS_DATA;

  --
  -- Procedure to validate parameters and call SQL LOADER
  --
  PROCEDURE LOAD_FILE
  (
    errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY VARCHAR2,
    p_file_location_name    IN  VARCHAR2,
    p_tax_content_source_id IN  NUMBER,
    p_tax_regime_code       IN  VARCHAR2
  ) IS

    CURSOR c_check_data
    IS
      SELECT COUNT(*)
      FROM ZX_DATA_UPLOAD_INTERFACE;

    l_api_name           CONSTANT VARCHAR2(30):= 'load_file';
    l_error              EXCEPTION;
    l_request_id         NUMBER;
    l_req_data           VARCHAR2(255);
    l_data_count         NUMBER;

  BEGIN

    retcode := '0';

    l_req_data := fnd_conc_global.request_data;

    IF (l_req_data IS NULL)
    THEN

      l_req_data := 'LOAD-FILE';
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Validating input parameters.'
      );

      IF (p_file_location_name IS NULL)
      THEN
        errbuf := 'Please specify complete location and name of the data file.';
        RAISE l_error;
      END IF;

      IF (p_tax_content_source_id IS NULL)
      THEN
        errbuf := 'Please select a valid Content Source.';
        RAISE l_error;
      END IF;

      IF (p_tax_regime_code IS NULL)
      THEN
        errbuf := 'Please select a valid Tax Regime to load the data into.';
        RAISE l_error;
      END IF;

      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Calling Sql*Loader to load data.'
      );
      l_request_id  := fnd_request.submit_request
                       (
                         application      => 'ZX',
                         program          => 'ZXUPSQLLOAD',
                         sub_request      => true,
                         argument1        => p_file_location_name
                       );
      IF (l_request_id = 0)
      THEN
        errbuf := 'E-Business Tax Content Upload Sql Loader Program submission failed. Contact support.';
        RAISE l_error;
      END IF;

      errbuf := 'Sub-request Submitted.';

      fnd_conc_global.set_req_globals
      (
        conc_status => 'PAUSED',
        request_data => l_req_data
      );

    ELSE

      OPEN c_check_data;
      FETCH c_check_data
        INTO l_data_count;
      CLOSE c_check_data;

      IF (NVL(l_data_count,0) = 0)
      THEN
        errbuf := 'No data uploaded, check data file location and name.';
        RAISE l_error;
      END IF;

      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Data uploaded into interface table. No. of records: '||l_data_count
      );

    END IF;

  EXCEPTION

    WHEN l_error THEN
      retcode := '2';
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Error in '||l_api_name||': '||errbuf
      );

    WHEN OTHERS THEN
      retcode := '2';
      errbuf := SQLERRM;
      FND_FILE.PUT_LINE
      (
        FND_FILE.LOG,
        'Unexpected Error in '||l_api_name||': '||errbuf
      );

  END LOAD_FILE;

END ZX_TAX_CONTENT_UPLOAD;

/
