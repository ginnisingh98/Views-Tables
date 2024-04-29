--------------------------------------------------------
--  DDL for Package Body ZX_EVNT_OPTIONS_MIGRATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_EVNT_OPTIONS_MIGRATE_PKG" as
/* $Header: zxevntoptmigpkgb.pls 120.25.12010000.2 2009/06/04 12:30:57 ssanka ship $ */

G_PKG_NAME                CONSTANT VARCHAR2(30) := 'ZX_EVNT_OPTIONS_MIGRATE_PKG';
G_CURRENT_RUNTIME_LEVEL   CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED        CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR             CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION         CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT             CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE         CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT         CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME             CONSTANT VARCHAR2(250):= 'ZX.PLSQL.ZX_EVNT_OPTIONS_MIGRATE_PKG.';

l_multi_org_flag fnd_product_groups.multi_org_flag%type;
l_org_id NUMBER(15);


PROCEDURE AP_OPTIONS_MIGRATE (x_return_status OUT NOCOPY VARCHAR2) IS

    l_api_name  CONSTANT   VARCHAR2(30) := 'AP_OPTIONS_MIGRATE';

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

     INSERT INTO ZX_EVNT_CLS_OPTIONS (
                EVENT_CLASS_OPTIONS_ID,
                APPLICATION_ID,
                ENTITY_CODE,
                EVENT_CLASS_CODE,
                DET_FACTOR_TEMPL_CODE,
                DEFAULT_ROUNDING_LEVEL_CODE,
                ROUNDING_LEVEL_HIER_1_CODE,
                ROUNDING_LEVEL_HIER_2_CODE,
                ROUNDING_LEVEL_HIER_3_CODE,
                ROUNDING_LEVEL_HIER_4_CODE,
                ALLOW_MANUAL_LIN_RECALC_FLAG,
                ALLOW_OVERRIDE_FLAG,
                ALLOW_MANUAL_LINES_FLAG,
                PERF_ADDNL_APPL_FOR_IMPRT_FLAG,
                EFFECTIVE_FROM,
                EFFECTIVE_TO,
                ENABLED_FLAG,
                FIRST_PTY_ORG_ID,
                ENFORCE_TAX_FROM_ACCT_FLAG,
                TAX_TOLERANCE,
                TAX_TOL_AMT_RANGE,
                RECORD_TYPE_CODE,
                OFFSET_TAX_BASIS_CODE,
                ALLOW_OFFSET_TAX_CALC_FLAG,
                ENTER_OVRD_INCL_TAX_LINES_FLAG,
                CTRL_EFF_OVRD_CALC_LINES_FLAG,
                ENFORCE_TAX_FROM_REF_DOC_FLAG,
                PROCESS_FOR_APPLICABILITY_FLAG,
                OBJECT_VERSION_NUMBER,
                ALLOW_EXEMPTIONS_FLAG,
                EXMPTN_PTY_BASIS_HIER_1_CODE,
                EXMPTN_PTY_BASIS_HIER_2_CODE,
                DEF_INTRCMP_TRX_BIZ_CATEGORY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN
                )
       	SELECT ZX_EVNT_CLS_OPTIONS_S.nextval,
                mapping.application_id,
                mapping.entity_code,
                mapping.event_class_code,
                'STCC',
                nvl(decode(sys.auto_tax_calc_flag,'Y','HEADER','L','LINE','T','HEADER','N',mapping.default_rounding_level_code),mapping.default_rounding_level_code),
                nvl(decode (sys.auto_tax_calc_override,'Y','SHIP_FROM_PTY_SITE','N','SHIP_TO_PTY'),mapping.rounding_level_hier_1_code),
		nvl(decode (sys.auto_tax_calc_override,'Y','SHIP_FROM_PTY','N',null),mapping.rounding_level_hier_2_code),
         	nvl(decode (sys.auto_tax_calc_override,'Y','SHIP_TO_PTY_SITE','N',null),mapping.rounding_level_hier_3_code),
        	nvl(decode (sys.auto_tax_calc_override,'Y','SHIP_TO_PTY','N',null),mapping.rounding_level_hier_4_code),
                decode (mapping.allow_manual_lin_recalc_flag,'Y','Y','N'),
                'N',
                decode(mapping.allow_manual_lines_flag,'Y','Y','N'),
                decode(mapping.perf_addnl_appl_for_imprt_flag,'Y','Y','N'),
                to_date('01-01-1951','DD-MM-YYYY'),
                null,
                'Y',
    	        ptp.party_tax_profile_id,
                decode(mapping.enforce_tax_from_acct_flag,'Y',nvl(sys.enforce_tax_from_account,'N'),'N'),
                sys.tax_tolerance,     --Bug 5117926
                sys.tax_tol_amt_range, --Bug 5117926
                'MIGRATED',
                'SHIP_FROM_SITE',
                decode(mapping.allow_offset_tax_calc_flag,'Y','Y','N'),
                decode(mapping.enter_ovrd_incl_taX_lines_flag,'Y','Y','N'),
                decode(mapping.ctrl_eff_ovrd_calc_lines_flag,'Y','Y','N'),
                decode(mapping.enforce_tax_from_ref_doc_flag,'Y',nvl(sys.MATCH_ON_TAX_FLAG,'N'),'N'),
                nvl(decode(sys.AUTO_TAX_CALC_FLAG,'N','N','Y'),mapping.process_for_applicability_flag),
                1,
                'N',
                null,
                null,
                decode(mapping.intrcmp_tx_evnt_cls_code,'INTERCOMPANY_TRANSACTION','INTERCOMPANY_TRANSACTION'),
                ptp.CREATION_DATE,
                ptp.CREATED_BY,
                ptp.LAST_UPDATE_DATE,
                ptp.LAST_UPDATED_BY,
                ptp.LAST_UPDATE_LOGIN
       	  FROM  ZX_PARTY_TAX_PROFILE ptp,
                AP_SYSTEM_PARAMETERS_ALL sys,
--                AP_TOLERANCE_TEMPLATES tol, --Bug 5117926
                ZX_EVNT_CLS_MAPPINGS mapping
          WHERE mapping.application_id = 200
            AND decode(l_multi_org_flag,'N',l_org_id,sys.org_id) = ptp.party_id
--            AND sys.tolerance_id = tol.tolerance_id(+) -- Bug 5232304 --Bug 5117926
            AND ptp.PARTY_TYPE_CODE ='OU'
	    AND ptp.record_type_code='MIGRATED' -- Bug 6837760
            AND   NOT EXISTS (SELECT 1
          	              FROM   ZX_EVNT_CLS_OPTIONS opt
    	                      WHERE  opt.FIRST_PTY_ORG_ID = ptp.party_tax_profile_id
                                AND  opt.APPLICATION_ID   = mapping.application_id
                                AND  opt.ENTITY_CODE      = mapping.entity_code
                                AND  opt.EVENT_CLASS_CODE = mapping.event_class_code
                             );



   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
   END IF;

   EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
     FND_MESSAGE.SET_TOKEN ('GENERIC_TEXT',' AP Event Class Options Migration : '||SQLERRM);
     FND_MSG_PUB.Add;
     IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
     END IF;
END AP_OPTIONS_MIGRATE;


PROCEDURE AR_OPTIONS_MIGRATE (x_return_status OUT NOCOPY VARCHAR2) IS

    l_api_name CONSTANT   VARCHAR2(30) := 'AR_OPTIONS_MIGRATE';

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT INTO ZX_EVNT_CLS_OPTIONS (
                EVENT_CLASS_OPTIONS_ID,
                APPLICATION_ID,
                ENTITY_CODE,
                EVENT_CLASS_CODE,
                DET_FACTOR_TEMPL_CODE,
                DEFAULT_ROUNDING_LEVEL_CODE,
                ROUNDING_LEVEL_HIER_1_CODE,
                ROUNDING_LEVEL_HIER_2_CODE,
                ROUNDING_LEVEL_HIER_3_CODE,
                ROUNDING_LEVEL_HIER_4_CODE,
                ALLOW_MANUAL_LIN_RECALC_FLAG,
                ALLOW_OVERRIDE_FLAG,
                ALLOW_MANUAL_LINES_FLAG,
                PERF_ADDNL_APPL_FOR_IMPRT_FLAG,
                EFFECTIVE_FROM,
                EFFECTIVE_TO,
                ENABLED_FLAG,
                FIRST_PTY_ORG_ID,
                ENFORCE_TAX_FROM_ACCT_FLAG,
                TAX_TOLERANCE,
                TAX_TOL_AMT_RANGE,
                RECORD_TYPE_CODE,
                OFFSET_TAX_BASIS_CODE,
                ALLOW_OFFSET_TAX_CALC_FLAG,
                ENTER_OVRD_INCL_TAX_LINES_FLAG,
                CTRL_EFF_OVRD_CALC_LINES_FLAG,
                ENFORCE_TAX_FROM_REF_DOC_FLAG,
                PROCESS_FOR_APPLICABILITY_FLAG,
                OBJECT_VERSION_NUMBER,
                ALLOW_EXEMPTIONS_FLAG,
                EXMPTN_PTY_BASIS_HIER_1_CODE,
                EXMPTN_PTY_BASIS_HIER_2_CODE,
		DEF_INTRCMP_TRX_BIZ_CATEGORY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN
                )
       	SELECT ZX_EVNT_CLS_OPTIONS_S.nextval,
                mapping.application_id,
                mapping.entity_code,
                mapping.event_class_code,
                decode(sys.tax_database_view_set,'_V','TAXREGIME','_A','TAXREGIME','STCC'), --Bug 5385949
                decode(sys.tax_header_level_flag,'Y','HEADER','N','LINE',null),
                decode (sys.tax_rounding_allow_override,'Y','SHIP_TO_PTY_SITE','N','SHIP_FROM_PTY'),
		decode (sys.tax_rounding_allow_override,'Y','BILL_TO_PTY_SITE','N',null),
		decode (sys.tax_rounding_allow_override,'Y','SHIP_TO_PTY','N',null),
		decode (sys.tax_rounding_allow_override,'Y','BILL_TO_PTY','N',null),
                decode(mapping.allow_manual_lin_recalc_flag,'Y','Y','N'),
                'N',
                decode(mapping.allow_manual_lines_flag,'Y','Y','N'),
                decode(mapping.perf_addnl_appl_for_imprt_flag, 'Y',
                                                                decode(sys.tax_method,'SALES_TAX','Y','N'),
                                                                'N'),
                to_date('01-01-1951','DD-MM-YYYY'),
                null,
                'Y',
    		ptp.party_tax_profile_id,
                decode(mapping.enforce_tax_from_acct_flag,'Y',nvl(sys.tax_enforce_account_flag,'N'),'N'),
                null,
                null,
                'MIGRATED',
                mapping.offset_tax_basis_code,
                'N',
                decode(mapping.enter_ovrd_incl_tax_lines_flag,'Y',nvl(sys.inclusive_tax_used,'N'),'N'),
                decode(mapping.ctrl_eff_ovrd_calc_lines_flag,'Y',
                                                             decode(sys.inclusive_tax_used,'Y','Y','N'),
                                                            'N'),
                'N',
                decode(mapping.process_for_applicability_flag,'Y','Y','N'),
                1,
                decode(sys.tax_use_customer_exempt_flag, 'Y','Y','N'), --Bug Fix 5184711
                'BILL_TO',
                null,
                decode(mapping.intrcmp_tx_evnt_cls_code,'INTERCOMPANY_TRANSACTION','INTERCOMPANY_TRANSACTION'),
                ptp.CREATION_DATE,
                ptp.CREATED_BY,
                ptp.LAST_UPDATE_DATE,
                ptp.LAST_UPDATED_BY,
                ptp.LAST_UPDATE_LOGIN
    	FROM  ZX_PARTY_TAX_PROFILE ptp,
              AR_SYSTEM_PARAMETERS_ALL sys,
              ZX_EVNT_CLS_MAPPINGS mapping
   	WHERE mapping.application_id = 222
          AND decode(l_multi_org_flag,'N',l_org_id,sys.org_id) = ptp.party_id
          AND ptp.PARTY_TYPE_CODE ='OU'
	  AND ptp.record_type_code='MIGRATED'
          AND   NOT EXISTS (SELECT 1
        	            FROM   ZX_EVNT_CLS_OPTIONS opt
    	                    WHERE  opt.FIRST_PTY_ORG_ID = ptp.party_tax_profile_id
                              AND  opt.APPLICATION_ID   = mapping.application_id
                              AND  opt.ENTITY_CODE      = mapping.entity_code
                              AND  opt.EVENT_CLASS_CODE = mapping.event_class_code
                            );



   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
   END IF;

   EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
     FND_MESSAGE.SET_TOKEN ('GENERIC_TEXT','AR Event Class Options Migration : '||SQLERRM);
     FND_MSG_PUB.Add;
     IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
     END IF;
END AR_OPTIONS_MIGRATE;



PROCEDURE PO_OPTIONS_MIGRATE (x_return_status OUT NOCOPY VARCHAR2) IS

    l_api_name  CONSTANT   VARCHAR2(30) := 'PO_OPTIONS_MIGRATE';

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

     INSERT INTO ZX_EVNT_CLS_OPTIONS (
                EVENT_CLASS_OPTIONS_ID,
                APPLICATION_ID,
                ENTITY_CODE,
                EVENT_CLASS_CODE,
                DET_FACTOR_TEMPL_CODE,
                DEFAULT_ROUNDING_LEVEL_CODE,
                ROUNDING_LEVEL_HIER_1_CODE,
                ROUNDING_LEVEL_HIER_2_CODE,
                ROUNDING_LEVEL_HIER_3_CODE,
                ROUNDING_LEVEL_HIER_4_CODE,
                ALLOW_MANUAL_LIN_RECALC_FLAG,
                ALLOW_OVERRIDE_FLAG,
                ALLOW_MANUAL_LINES_FLAG,
                PERF_ADDNL_APPL_FOR_IMPRT_FLAG,
                EFFECTIVE_FROM,
                EFFECTIVE_TO,
                ENABLED_FLAG,
                FIRST_PTY_ORG_ID,
                ENFORCE_TAX_FROM_ACCT_FLAG,
                TAX_TOLERANCE,
                TAX_TOL_AMT_RANGE,
                RECORD_TYPE_CODE,
                OFFSET_TAX_BASIS_CODE,
                ALLOW_OFFSET_TAX_CALC_FLAG,
                ENTER_OVRD_INCL_TAX_LINES_FLAG,
                CTRL_EFF_OVRD_CALC_LINES_FLAG,
                ENFORCE_TAX_FROM_REF_DOC_FLAG,
                PROCESS_FOR_APPLICABILITY_FLAG,
                OBJECT_VERSION_NUMBER,
                ALLOW_EXEMPTIONS_FLAG,
                EXMPTN_PTY_BASIS_HIER_1_CODE,
                EXMPTN_PTY_BASIS_HIER_2_CODE,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_LOGIN
                )
       	SELECT ZX_EVNT_CLS_OPTIONS_S.nextval,
                mapping.application_id,
                mapping.entity_code,
                mapping.event_class_code,
                'STCC',
                nvl(decode(sysap.auto_tax_calc_flag,'Y','HEADER','L','LINE','T','HEADER','N',mapping.default_rounding_level_code),mapping.default_rounding_level_code),
                nvl(decode (sysap.auto_tax_calc_override,'Y','SHIP_FROM_PTY_SITE','N','SHIP_TO_PTY'),mapping.rounding_level_hier_1_code),
                nvl(decode (sysap.auto_tax_calc_override,'Y','SHIP_FROM_PTY','N',null),mapping.rounding_level_hier_2_code),
                nvl(decode (sysap.auto_tax_calc_override,'Y','SHIP_TO_PTY_SITE','N',null),mapping.rounding_level_hier_3_code),
                nvl(decode (sysap.auto_tax_calc_override,'Y','SHIP_TO_PTY','N',null),mapping.rounding_level_hier_4_code),
                'N',
                'N',
                'N',
                decode(mapping.perf_addnl_appl_for_imprt_flag,'Y','Y','N'),
                to_date('01-01-1951','DD-MM-YYYY'),
                null,
                'Y',
    	        ptp.party_tax_profile_id,
                'N',
                null,
                null,
                'MIGRATED',
                'SHIP_FROM_SITE',
                'N',
                'N',
                'N',
                'N',
                nvl(decode(sysap.AUTO_TAX_CALC_FLAG,'N','N','Y'),mapping.process_for_applicability_flag),
                1,
                'N',
                null,
                null,
                ptp.CREATION_DATE,
                ptp.CREATED_BY,
                ptp.LAST_UPDATE_DATE,
                ptp.LAST_UPDATED_BY,
                ptp.LAST_UPDATE_LOGIN
      	   FROM ZX_PARTY_TAX_PROFILE ptp,
                PO_SYSTEM_PARAMETERS_ALL syspo,
                AP_SYSTEM_PARAMETERS_ALL sysap,
                ZX_EVNT_CLS_MAPPINGS mapping
    	 WHERE  mapping.application_id = 201
           AND  decode(l_multi_org_flag,'N',l_org_id,syspo.org_id) = ptp.party_id
           AND  decode(l_multi_org_flag,'N',l_org_id,syspo.org_id) = decode(l_multi_org_flag,'N',l_org_id,sysap.org_id(+))
           AND  ptp.PARTY_TYPE_CODE ='OU'
	   AND  ptp.record_type_code='MIGRATED'
           AND  NOT EXISTS (SELECT 1
                             FROM ZX_EVNT_CLS_OPTIONS opt
    	                    WHERE opt.FIRST_PTY_ORG_ID = ptp.party_tax_profile_id
                              AND opt.APPLICATION_ID   = mapping.application_id
                              AND opt.ENTITY_CODE      = mapping.entity_code
                              AND opt.EVENT_CLASS_CODE = mapping.event_class_code
                            );

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
     FND_MESSAGE.SET_TOKEN ('GENERIC_TEXT',' PO Event Class Options Migration : '||SQLERRM);
     FND_MSG_PUB.Add;
     IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
     END IF;

END PO_OPTIONS_MIGRATE;

PROCEDURE MIGRATE_EVNT_CLS_OPTIONS(x_return_status OUT NOCOPY VARCHAR2)
IS
  l_api_name       CONSTANT    VARCHAR2(30) := 'AR_OPTIONS_MIGRATE';
  l_return_status              VARCHAR2(1);

  BEGIN
    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

   /*-----------------------------------------------------+
    |   Process records from AR                           |
    +-----------------------------------------------------*/
    AR_OPTIONS_MIGRATE(l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN ('GENERIC_TEXT','Event Class Options Migration : '||SQLERRM);
      FND_MSG_PUB.Add;
      RETURN;
    END IF;


   /*-----------------------------------------------------+
    |   Process records from AP                           |
    +-----------------------------------------------------*/
    AP_OPTIONS_MIGRATE (l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN ('GENERIC_TEXT','Event Class Options Migration : '||SQLERRM);
      FND_MSG_PUB.Add;
      RETURN;
    END IF;

   /*-----------------------------------------------------+
    |   Process records from PO                           |
    +-----------------------------------------------------*/
    PO_OPTIONS_MIGRATE (l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME ('ZX','GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN ('GENERIC_TEXT','Event Class Options Migration : '||SQLERRM);
      FND_MSG_PUB.Add;
      RETURN;
    END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
   END IF;
 END MIGRATE_EVNT_CLS_OPTIONS;

BEGIN

   SELECT NVL(MULTI_ORG_FLAG,'N')
     INTO L_MULTI_ORG_FLAG
     FROM FND_PRODUCT_GROUPS;

    IF L_MULTI_ORG_FLAG  = 'N' THEN
      FND_PROFILE.GET('ORG_ID',L_ORG_ID);
      IF L_ORG_ID IS NULL THEN
        arp_util_tax.debug('MO: Operating Units site level profile option value not set , resulted in Null Org Id');
      END IF;
    ELSE
      L_ORG_ID := NULL;
    END IF;



EXCEPTION
WHEN OTHERS THEN
    arp_util_tax.debug('Exception in constructor of EventOptions '||sqlerrm);

END ZX_EVNT_OPTIONS_MIGRATE_PKG;

/
