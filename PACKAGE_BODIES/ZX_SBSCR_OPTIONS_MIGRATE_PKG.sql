--------------------------------------------------------
--  DDL for Package Body ZX_SBSCR_OPTIONS_MIGRATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_SBSCR_OPTIONS_MIGRATE_PKG" as
/* $Header: zxsbscrmigpkgb.pls 120.23 2006/05/12 12:33:23 asengupt ship $ */

G_PKG_NAME                CONSTANT VARCHAR2(50) := 'ZX_SBSCR_OPTIONS_MIGRATE_PKG';
G_CURRENT_RUNTIME_LEVEL   CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED        CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR             CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION         CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT             CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE         CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT         CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME             CONSTANT VARCHAR2(250) := 'ZX.PLSQL.ZX_SBSCR_OPTIONS_MIGRATE_PKG.';


L_MULTI_ORG_FLAG   FND_PRODUCT_GROUPS.MULTI_ORG_FLAG%TYPE;
L_ORG_ID	      NUMBER(15);

PROCEDURE SBSCRPTN_OPTIONS_MIGRATE (x_return_status OUT NOCOPY VARCHAR2) IS

    l_api_name  CONSTANT  VARCHAR2(50) := 'SUBSCRIPTION_OPTIONS_MIGRATE';

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ZX_REGIMES_USAGES (
                REGIME_USAGE_ID,
                FIRST_PTY_ORG_ID,
                TAX_REGIME_ID,
                TAX_REGIME_CODE,
                RECORD_TYPE_CODE,
                OBJECT_VERSION_NUMBER,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN
                )
          SELECT
	       ZX_REGIMES_USAGES_S.NEXTVAL,
               ptp.party_tax_profile_id CONTENT_OWNER_ID,
               regime.tax_regime_id TAX_REGIME_ID,
               regime.tax_regime_code TAX_REGIME_CODE,
     	       'MIGRATED',
               1,
              SYSDATE                 ,
	      fnd_global.user_id      ,
	      SYSDATE                 ,
	      fnd_global.user_id      ,
	      fnd_global.conc_login_id
         FROM  ZX_REGIMES_B regime,
               ZX_PARTY_TAX_PROFILE ptp,
               ( SELECT  decode(l_multi_org_flag,'N',l_org_id,org_id) org_id
                 FROM    ap_tax_codes_all
                UNION
                 SELECT  decode(l_multi_org_flag,'N',l_org_id,org_id) org_id
                 FROM    ar_vat_tax_all_b) codes
        WHERE   decode(l_multi_org_flag,'N',l_org_id,codes.org_id) = ptp.party_id
        AND     ptp.party_type_code = 'OU'
	AND     regime.record_type_code = 'MIGRATED'
	AND     ptp.record_type_code    = 'MIGRATED'
        AND     NOT EXISTS ( SELECT 1
                             FROM zx_regimes_usages ru
                            WHERE (ru.FIRST_PTY_ORG_ID = ptp.party_tax_profile_id
                              AND ru.tax_regime_code = regime.tax_regime_code)
                               OR (ru.FIRST_PTY_ORG_ID = ptp.party_tax_profile_id
                              AND ru.tax_regime_id   = regime.tax_regime_id)
                            );


    INSERT INTO ZX_SUBSCRIPTION_OPTIONS (
     	        SUBSCRIPTION_OPTION_ID,
         	    REGIME_USAGE_ID,
                SUBSCRIPTION_OPTION_CODE,
                PARENT_FIRST_PTY_ORG_ID,
                EFFECTIVE_FROM,
                EFFECTIVE_TO,
                ENABLED_FLAG,
                ALLOW_SUBSCRIPTION_FLAG,
                RECORD_TYPE_CODE,
                EXCEPTION_OPTION_CODE,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN
                )
        SELECT ZX_SUBSCRIPTION_OPTIONS_S.nextval,
               ru.regime_usage_id,
               'OWN_GCO',
               NULL,
               regime.effective_from,
               regime.effective_to,
               'Y',
               'N',
               'MIGRATED',
               'OWN_ONLY',
               SYSDATE                 ,
	       fnd_global.user_id      ,
	       SYSDATE                 ,
	       fnd_global.user_id      ,
	       fnd_global.conc_login_id
          FROM ZX_REGIMES_B regime,
               ZX_REGIMES_USAGES ru
        WHERE  regime.tax_regime_code = ru.tax_regime_code
          AND  ru.record_type_code = 'MIGRATED'
          AND  NOT EXISTS (SELECT 1
                             FROM ZX_SUBSCRIPTION_OPTIONS opt
                            WHERE opt.regime_usage_id = ru.regime_usage_id
                          ) ;


    INSERT INTO ZX_SUBSCRIPTION_DETAILS (
                SUBSCRIPTION_DETAIL_ID,
                SUBSCRIPTION_OPTION_ID,
                FIRST_PTY_ORG_ID,
                PARENT_FIRST_PTY_ORG_ID,
                VIEW_OPTIONS_CODE,
                TAX_REGIME_CODE,
                EFFECTIVE_FROM,
                EFFECTIVE_TO,
     	        RECORD_TYPE_CODE,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN
                )
         SELECT ZX_SUBSCRIPTION_DETAILS_S.nextval,
                opt.subscription_option_id,
                ru.first_pty_org_id,
                ru.first_pty_org_id,
                'VFC',
                ru.tax_regime_code,
                opt.effective_from,
                opt.effective_to,
                'MIGRATED',
                SYSDATE                 ,
	        fnd_global.user_id      ,
	        SYSDATE                 ,
	        fnd_global.user_id      ,
  	        fnd_global.conc_login_id
           FROM ZX_REGIMES_USAGES ru,
                ZX_SUBSCRIPTION_OPTIONS opt
         WHERE  ru.regime_usage_id = opt.regime_usage_id
           AND  opt.record_type_code = 'MIGRATED'
           AND  NOT EXISTS (SELECT 1
                            FROM ZX_SUBSCRIPTION_DETAILS det
                           WHERE det.first_pty_org_id        = ru.first_pty_org_id
                             AND det.parent_first_pty_org_id = ru.first_pty_org_id
                             AND det.tax_regime_code         = ru.tax_regime_code
                             AND det.view_options_code       = 'VFC'
                             AND det.effective_from          = opt.effective_from
                           );

    /* Insert a row for every regime */
    INSERT INTO ZX_SUBSCRIPTION_DETAILS (
                SUBSCRIPTION_DETAIL_ID,
                SUBSCRIPTION_OPTION_ID,
                FIRST_PTY_ORG_ID,
                PARENT_FIRST_PTY_ORG_ID,
                VIEW_OPTIONS_CODE,
                TAX_REGIME_CODE,
                EFFECTIVE_FROM,
                EFFECTIVE_TO,
     	        RECORD_TYPE_CODE,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN
                )
         SELECT ZX_SUBSCRIPTION_DETAILS_S.nextval,
                0,
                -99,
                -99,
                'VFC',
                zrb.tax_regime_code,
                zrb.effective_from,
                zrb.effective_to,
                'MIGRATED',
                SYSDATE                 ,
	        fnd_global.user_id      ,
	        SYSDATE                 ,
	        fnd_global.user_id      ,
  	        fnd_global.conc_login_id
           FROM ZX_REGIMES_B zrb
         WHERE  NVL(zrb.has_sub_regime_flag,'N') = 'N'
	   AND  zrb.record_type_code = 'MIGRATED'
           AND  NOT EXISTS (SELECT 1
                            FROM ZX_SUBSCRIPTION_DETAILS det
                           WHERE det.first_pty_org_id        = -99
                             AND det.parent_first_pty_org_id = -99
                             AND det.tax_regime_code         = zrb.tax_regime_code
                             AND det.view_options_code       = 'VFC'
                             AND det.effective_from          = zrb.effective_from
                           );

    /** VFD row not insrted for OWN_GCO case now

    INSERT INTO ZX_SUBSCRIPTION_DETAILS (
                SUBSCRIPTION_DETAIL_ID,
                SUBSCRIPTION_OPTION_ID,
                FIRST_PTY_ORG_ID,
                PARENT_FIRST_PTY_ORG_ID,
                VIEW_OPTIONS_CODE,
                TAX_REGIME_CODE,
                EFFECTIVE_FROM,
                EFFECTIVE_TO,
     	        RECORD_TYPE_CODE,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN
                )
         SELECT ZX_SUBSCRIPTION_DETAILS_S.nextval,
                opt.subscription_option_id,
                ru.first_pty_org_id,
                -99,
                'VFD',
                ru.tax_regime_code,
                opt.effective_from,
                opt.effective_to,
                'MIGRATED',
                ru.creation_date,
                ru.created_by,
                ru.last_update_date,
                ru.last_updated_by,
                ru.last_update_login
           FROM ZX_REGIMES_USAGES ru,
                ZX_SUBSCRIPTION_OPTIONS opt
         WHERE  ru.regime_usage_id = opt.regime_usage_id
           AND  NOT EXISTS (SELECT 1
                            FROM ZX_SUBSCRIPTION_DETAILS det
                           WHERE det.first_pty_org_id        = ru.first_pty_org_id
                             AND det.parent_first_pty_org_id = -99
                             AND det.tax_regime_code         = ru.tax_regime_code
                             AND det.view_options_code       = 'VFD'
                             AND det.effective_from          = opt.effective_from
                           );
    **/

    INSERT INTO ZX_SUBSCRIPTION_DETAILS (
                SUBSCRIPTION_DETAIL_ID,
                SUBSCRIPTION_OPTION_ID,
                FIRST_PTY_ORG_ID,
                PARENT_FIRST_PTY_ORG_ID,
                VIEW_OPTIONS_CODE,
                TAX_REGIME_CODE,
                EFFECTIVE_FROM,
                EFFECTIVE_TO,
     	        RECORD_TYPE_CODE,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN
                )
         SELECT ZX_SUBSCRIPTION_DETAILS_S.nextval,
                opt.subscription_option_id,
                ru.first_pty_org_id,
                -99,
                'VFR',
                ru.tax_regime_code,
                opt.effective_from,
                opt.effective_to,
                'MIGRATED',
                SYSDATE                 ,
	        fnd_global.user_id      ,
	        SYSDATE                 ,
	        fnd_global.user_id      ,
  	        fnd_global.conc_login_id
           FROM ZX_REGIMES_USAGES ru,
                ZX_SUBSCRIPTION_OPTIONS opt
         WHERE  ru.regime_usage_id = opt.regime_usage_id
           AND  opt.record_type_code = 'MIGRATED'
           AND  NOT EXISTS (SELECT 1
                            FROM ZX_SUBSCRIPTION_DETAILS det
                           WHERE det.first_pty_org_id        = ru.first_pty_org_id
                             AND det.parent_first_pty_org_id = -99
                             AND det.tax_regime_code         = ru.tax_regime_code
                             AND det.view_options_code       = 'VFR'
                             AND det.effective_from          = opt.effective_from
                           );

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
   END IF;

  /*Bug 5204559*/
    UPDATE ZX_REGIMES_B
	SET    ALLOW_EXEMPTIONS_FLAG = 'Y'
	WHERE  TAX_REGIME_ID IN (SELECT distinct RU.TAX_REGIME_ID
                         FROM   ZX_REGIMES_USAGES RU,
                                ZX_PARTY_TAX_PROFILE PTP,
                                AR_SYSTEM_PARAMETERS_ALL ARSYS
                         WHERE  PTP.PARTY_TAX_PROFILE_ID = RU.FIRST_PTY_ORG_ID
                            AND PTP.PARTY_TYPE_CODE = 'OU'
                            AND PTP.PARTY_ID = ARSYS.ORG_ID
                            AND nvl(ARSYS.TAX_USE_CUSTOMER_EXEMPT_FLAG,'N') = 'Y'
                            AND PTP.RECORD_TYPE_CODE = 'MIGRATED')
        AND RECORD_TYPE_CODE = 'MIGRATED';

    UPDATE ZX_REGIMES_B
	SET    ALLOW_EXCEPTIONS_FLAG = 'Y'
	WHERE  TAX_REGIME_ID IN (SELECT TAX_REGIME_ID
				 FROM   ZX_REGIMES_USAGES RU,
				        ZX_PARTY_TAX_PROFILE PTP,
				 	AR_SYSTEM_PARAMETERS_ALL ARSYS
				 WHERE  PTP.PARTY_TAX_PROFILE_ID = RU.FIRST_PTY_ORG_ID
				 AND PTP.PARTY_TYPE_CODE = 'OU'
				 AND PTP.PARTY_ID = ARSYS.ORG_ID
				 AND (nvl(ARSYS.TAX_USE_PRODUCT_EXEMPT_FLAG,'N') = 'Y'
					      OR nvl(TAX_USE_LOC_EXC_RATE_FLAG,'N') = 'Y')
				AND PTP.RECORD_TYPE_CODE = 'MIGRATED')

	       AND RECORD_TYPE_CODE = 'MIGRATED';

END SBSCRPTN_OPTIONS_MIGRATE;

BEGIN

   SELECT NVL(MULTI_ORG_FLAG,'N')  INTO L_MULTI_ORG_FLAG FROM
    FND_PRODUCT_GROUPS;

    IF L_MULTI_ORG_FLAG  = 'N' THEN

          FND_PROFILE.GET('ORG_ID',L_ORG_ID);

                 IF L_ORG_ID IS NULL THEN
                   arp_util_tax.debug('MO: Operating Units site level profile option value not set , resulted in Null Org Id');
                 END IF;
    ELSE
         L_ORG_ID := NULL;
    END IF;


END ZX_SBSCR_OPTIONS_MIGRATE_PKG;

/
