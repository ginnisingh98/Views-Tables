--------------------------------------------------------
--  DDL for Package Body ZX_MIGRATE_REP_ENTITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_MIGRATE_REP_ENTITIES_PKG" AS
/* $Header: zxrepentitiesb.pls 120.54.12010000.3 2009/11/18 13:03:43 tsen ship $ */

PG_DEBUG CONSTANT VARCHAR(1) default
		NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
l_multi_org_flag fnd_product_groups.multi_org_flag%type;
l_org_id NUMBER(15);

/* Used to create the reporting code association for AP */
PROCEDURE CREATE_ZX_REPORTING_ASSOC_AP(p_tax_id IN NUMBER);

/* Used to create the reporting code association for AR */
PROCEDURE CREATE_ZX_REPORTING_ASSOC_AR(p_tax_id IN NUMBER);

/* Used to create the reporting type and code for AP */
PROCEDURE CREATE_ZX_REP_TYPE_CODES_AP(p_tax_id IN NUMBER);

/* Used to create the reporting type and code for AR */
PROCEDURE CREATE_ZX_REP_TYPE_CODES_AR(p_tax_id IN NUMBER);

/* Common procedure used to create Reporting Types for AR*/
PROCEDURE  CREATE_REPORTING_TYPE_AR(
	p_reporting_type_code 	IN  ZX_REPORTING_TYPES_B.REPORTING_TYPE_CODE %TYPE,
	p_datatype		IN  ZX_REPORTING_TYPES_B.REPORTING_TYPE_DATATYPE_CODE%TYPE,
	p_has_rep_code		IN  ZX_REPORTING_TYPES_B.HAS_REPORTING_CODES_FLAG%TYPE,
	P_category		IN  AR_VAT_TAX_ALL_B.GLOBAL_ATTRIBUTE_CATEGORY%TYPE,
	p_tax_id	        IN  NUMBER
	);

/* Common procedure used to create Reporting Types for AP*/
PROCEDURE  CREATE_REPORTING_TYPE_AP(
	p_reporting_type_code 	IN  ZX_REPORTING_TYPES_B.REPORTING_TYPE_CODE %TYPE,
	p_datatype		IN  ZX_REPORTING_TYPES_B.REPORTING_TYPE_DATATYPE_CODE%TYPE,
	p_has_rep_code		IN  ZX_REPORTING_TYPES_B.HAS_REPORTING_CODES_FLAG%TYPE,
	P_category		IN  AR_VAT_TAX_ALL_B.GLOBAL_ATTRIBUTE_CATEGORY%TYPE,
	p_tax_id	        IN  NUMBER
	);

/* Common procedure used to create Reporting Codes */
PROCEDURE  CREATE_REPORTING_CODES (
	p_reporting_type_code 	IN  ZX_REPORTING_TYPES_B.REPORTING_TYPE_CODE %TYPE,
	P_lookup_type		IN  FND_LOOKUPS.LOOKUP_TYPE%TYPE
	);

/*Common procedure used to create Reporting types for bug fix 3722296*/
PROCEDURE  CREATE_REPORT_TYPE_PTP
	(
	p_reporting_type_code 	IN  ZX_REPORTING_TYPES_B.REPORTING_TYPE_CODE %TYPE,
	p_datatype		IN  ZX_REPORTING_TYPES_B.REPORTING_TYPE_DATATYPE_CODE%TYPE,
	p_has_rep_code		IN  ZX_REPORTING_TYPES_B.HAS_REPORTING_CODES_FLAG%TYPE
	);

PROCEDURE CREATE_REPORT_TYPE_SEED
	(
	p_reporting_type_code 	IN  ZX_REPORTING_TYPES_B.REPORTING_TYPE_CODE %TYPE,
	p_datatype		IN  ZX_REPORTING_TYPES_B.REPORTING_TYPE_DATATYPE_CODE%TYPE,
	p_has_rep_code		IN  ZX_REPORTING_TYPES_B.HAS_REPORTING_CODES_FLAG%TYPE
	);

PROCEDURE CREATE_REPORTING_CODES_SEED (
	p_reporting_type_code 	IN  ZX_REPORTING_TYPES_B.REPORTING_TYPE_CODE %TYPE,
	P_lookup_type		IN  FND_LOOKUPS.LOOKUP_TYPE%TYPE
	);

PROCEDURE CREATE_REPORTTYPE_USAGES_SEED;

/* Used to create the reporting types for EMEA */
PROCEDURE CREATE_REPORTING_TYPE_EMEA;

/* Used to create the reporting type usages for EMEA */
PROCEDURE CREATE_REPORT_TYP_USAGES_EMEA;

/* Used to create the reporting codes for EMEA */
PROCEDURE CREATE_REPORTING_CODES_EMEA;

/* Used to create the reporting code association for EMEA */
PROCEDURE CREATE_REP_CODE_ASSOC_EMEA;

/* Used to create the reporting entities for UK Reverse Charge Vat */
PROCEDURE CREATE_REP_ENT_REVERSE_VAT;

/*=========================================================================+
 | PROCEDURE                                                               |
 |    CREATE_ZX_REPORTING_ASSOC                                            |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 |    Used to create the reporting code association for different eTax     |
 |    entities.                                                            |
 |                                                                         |
 | SCOPE - PUBLIC                                                          |
 |                                                                         |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                  |
 |                                                                         |
 | CALLED FROM                                                             |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     01-Jul-04  Arnab Sengupta      Created.                             |
 |                                                                         |
 |=========================================================================*/

PROCEDURE CREATE_ZX_REPORTING_ASSOC(p_tax_id IN NUMBER)  IS
	l_status fnd_module_installations.status%TYPE;
	l_db_status fnd_module_installations.DB_STATUS%TYPE;

	l_reporting_type_id apps.zx_reporting_types_b.reporting_type_id%TYPE ;

BEGIN
   arp_util_tax.debug('CREATE_ZX_REPORTING_ASSOC(+)');

	IF Zx_Migrate_Util.IS_INSTALLED('AP') = 'Y'  THEN
		CREATE_ZX_REPORTING_ASSOC_AP(p_tax_id);
	END IF;

	IF Zx_Migrate_Util.IS_INSTALLED('AR') = 'Y'  THEN
	        CREATE_ZX_REPORTING_ASSOC_AR(p_tax_id);
	END IF;

--Bug 5092560 : To Create Association with Taxes for Reporting Type 'REPORTING_STATUS_TRACKING'

   BEGIN
	   SELECT reporting_type_id
	   INTO l_reporting_type_id
	   FROM zx_reporting_types_b
	   WHERE reporting_type_code = 'REPORTING_STATUS_TRACKING';

	   INSERT
	   INTO   ZX_REPORT_CODES_ASSOC(
		  REPORTING_CODE_ASSOC_ID,
		  ENTITY_CODE            ,
		  ENTITY_ID              ,
		  REPORTING_TYPE_ID      ,
		  REPORTING_CODE_ID      ,
		  EXCEPTION_CODE         ,
		  EFFECTIVE_FROM         ,
		  EFFECTIVE_TO           ,
		  CREATED_BY             ,
		  CREATION_DATE          ,
		  LAST_UPDATED_BY        ,
		  LAST_UPDATE_DATE       ,
		  LAST_UPDATE_LOGIN      ,
		  REPORTING_CODE_CHAR_VALUE,
		  REPORTING_CODE_DATE_VALUE,
		  REPORTING_CODE_NUM_VALUE,
		  OBJECT_VERSION_NUMBER
	    )
	    SELECT
		  ZX_REPORT_CODES_ASSOC_S.nextval  ,
		 'ZX_TAXES'                        ,--ENTITY_CODE
		  TAX_ID                      ,--ENTITY_ID
		  l_reporting_type_id                        ,--REPORTING_TYPE_ID
		  NULL				   ,--REPORTING_CODE_ID
		  NULL                             ,--EXCEPTION_CODE
		  EFFECTIVE_FROM                   ,
		  effective_to                             ,--EFFECTIVE_TO
		  created_by ,
		  CREATION_DATE                         ,
		  LAST_UPDATED_BY               ,
		  LAST_UPDATE_DATE                         ,
		  LAST_UPDATE_LOGIN          ,
		  'Y'                              , --REPORTING_CODE_CHAR_VALUE
		  NULL,
		  NULL,
		  1
		from zx_taxes_b taxes
		where legal_reporting_status_def_val = '000000000000000'
		AND  not EXISTS
			( SELECT  1 from ZX_REPORT_CODES_ASSOC
			    where  entity_code         = 'ZX_TAXES'
			    and    entity_id           = taxes.tax_id
			    and    reporting_type_id = l_reporting_type_id
			);
    EXCEPTION
    WHEN OTHERS THEN
	NULL ;
    END ;



   arp_util_tax.debug('CREATE_ZX_REPORTING_ASSOC(-)');

END CREATE_ZX_REPORTING_ASSOC;


 /*==========================================================================+
 | PROCEDURE                                                                 |
 |    CREATE_ZX_REP_TYPES_CODES                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine inserts data into following zx reporting entities based  |
 |     on data in AP_TAX_CODES_ALL GDF attributes.                           |
 |     ZX_REPORTING_TYPES_B                                                  |
 |     ZX_REPORTING_TYPES_TL                                                 |
 |     ZX_REPORTING_CODES_B                                                  |
 |     ZX_REPORTING_CODES_TL                                                 |
 |     ZX_REPORT_TYPES_USAGES                                                |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     01-Jul-04       Arnab Sengupta     Created                            |
 |==========================================================================*/


PROCEDURE CREATE_ZX_REP_TYPE_CODES(p_tax_id IN NUMBER ) IS
l_lookup_code ZX_REPORTING_CODES_B.REPORTING_CODE_CHAR_VALUE%TYPE ; -- Bug 4936036
BEGIN

	IF PG_DEBUG = 'Y' THEN
		arp_util_tax.debug('CREATE_ZX_REP_TYPE_CODES(+)');
	END IF;

	-- If AP Installed then
	IF Zx_Migrate_Util.IS_INSTALLED('AP') = 'Y' THEN
		CREATE_ZX_REP_TYPE_CODES_AP(p_tax_id);
	END IF;

	-- If AR Installed then
	IF Zx_Migrate_Util.IS_INSTALLED('AR') = 'Y' THEN
		CREATE_ZX_REP_TYPE_CODES_AR(p_tax_id);
	END IF;


	-- Following code is common for both AP and AR

 /*  Bug 4936036 :
 Added the Code to create reporting codes for PT_LOCATION for both AP and AR regimes as code is common for both
 of them */
 FOR i IN 1..3
   LOOP
     IF ( i = 1 ) THEN l_lookup_code := 'A' ;
     ELSIF ( i = 2 ) THEN l_lookup_code := 'C';
     ELSE  l_lookup_code := 'M';
     END IF ;

     INSERT
    INTO  ZX_REPORTING_CODES_B(
		REPORTING_CODE_ID      ,
		EXCEPTION_CODE         ,
		EFFECTIVE_FROM         ,
		EFFECTIVE_TO           ,
		RECORD_TYPE_CODE       ,
		CREATED_BY                     ,
		CREATION_DATE                  ,
		LAST_UPDATED_BY                ,
		LAST_UPDATE_DATE               ,
		LAST_UPDATE_LOGIN              ,
		REQUEST_ID                     ,
		PROGRAM_APPLICATION_ID         ,
		PROGRAM_ID                     ,
		PROGRAM_LOGIN_ID		  ,
		REPORTING_CODE_CHAR_VALUE	  ,
		REPORTING_CODE_DATE_VALUE      ,
		REPORTING_CODE_NUM_VALUE       ,
		REPORTING_TYPE_ID		,
		OBJECT_VERSION_NUMBER
	   )
    SELECT
           zx_reporting_codes_b_s.nextval,--REPORTING_CODE_ID
           NULL                          ,--EXCEPTION_CODE
           report_types.EFFECTIVE_FROM                ,
           NULL                          ,--EFFECTIVE_TO
          'MIGRATED'                     ,--RECORD_TYPE_CODE
           fnd_global.user_id            ,
           SYSDATE                       ,
           fnd_global.user_id            ,
           SYSDATE                       ,
           fnd_global.conc_login_id      ,
           fnd_global.conc_request_id    , -- Request Id
           fnd_global.prog_appl_id       , -- Program Application ID
           fnd_global.conc_program_id    , -- Program Id
           fnd_global.conc_login_id      ,  -- Program Login ID
           l_lookup_code,
	   NULL,
	   NULL,
	   report_types.REPORTING_TYPE_ID,
	   1
    FROM
	ZX_REPORTING_TYPES_B report_types
    WHERE
	report_types.REPORTING_TYPE_CODE = 'PT_LOCATION'
	AND  report_types.RECORD_TYPE_CODE    = 'MIGRATED'
	AND  NOT EXISTS
	(SELECT 1 FROM ZX_REPORTING_CODES_B WHERE
	REPORTING_TYPE_ID   = report_types.REPORTING_TYPE_ID AND
	REPORTING_CODE_CHAR_VALUE= l_lookup_code
	);
  END LOOP ;
-- End Bug 4936036

	-- Creation of FISCAL PRINTER Reporting Type and Reporting Usage
	-- Bug # 3587896
	INSERT ALL
	WHEN ( NOT EXISTS (select 1 from zx_reporting_types_b
				where  reporting_type_code='FISCAL PRINTER'
				and    tax_regime_code = l_tax_regime_code)
	)
	THEN
	INTO ZX_REPORTING_TYPES_B(
		REPORTING_TYPE_ID              ,
		REPORTING_TYPE_CODE            ,
		REPORTING_TYPE_DATATYPE_CODE   ,
		TAX_REGIME_CODE                ,
		TAX                            ,
		FORMAT_MASK                    ,
		MIN_LENGTH                     ,
		MAX_LENGTH                     ,
		LEGAL_MESSAGE_FLAG             ,
		EFFECTIVE_FROM                 ,
		EFFECTIVE_TO                   ,
		RECORD_TYPE_CODE	       ,
		HAS_REPORTING_CODES_FLAG       ,
		CREATED_BY                     ,
		CREATION_DATE                  ,
		LAST_UPDATED_BY                ,
		LAST_UPDATE_DATE               ,
		LAST_UPDATE_LOGIN              ,
		REQUEST_ID                     ,
		PROGRAM_APPLICATION_ID         ,
		PROGRAM_ID                     ,
		PROGRAM_LOGIN_ID		,
		OBJECT_VERSION_NUMBER
		)
	VALUES(
		zx_migrate_util.get_next_seqid('zx_reporting_types_b_s') ,--REPORTING_TYPE_ID
		'FISCAL PRINTER'               				 ,--REPORTING_TYPE_CODE
		'YES_NO'                       ,--REPORTING_TYPE_DATATYPE
		l_tax_regime_code	       ,--TAX_REGIME_CODE
		NULL                           ,--TAX
		NULL                           ,--FORMAT_MASK
		1                              ,--MIN_LENGTH
		30                             ,--MAX_LENGTH
		'N'                            ,--LEGAL_MESSAGE_FLAG
		effective_from                 ,
		NULL                           ,--EFFECTIVE_TO
		'MIGRATED'                     ,--RECORD_TYPE_CODE
		'N'                            ,--HAS_REPORTING_CODES_FLAG
		fnd_global.user_id             ,
		SYSDATE                        ,
		fnd_global.user_id             ,
		SYSDATE                        ,
		fnd_global.conc_login_id       ,
		fnd_global.conc_request_id     , -- Request Id
		fnd_global.prog_appl_id        , -- Program Application ID
		fnd_global.conc_program_id     , -- Program Id
		fnd_global.conc_login_id       , -- Program Login ID
		1
		)
	-- Creation of CAI NUMBER Reporting Type and Usage

	WHEN ( NOT EXISTS (select 1 from zx_reporting_types_b
				where  reporting_type_code='CAI NUMBER'
				and    tax_regime_code = l_tax_regime_code)
	)
	THEN
	INTO ZX_REPORTING_TYPES_B(
		REPORTING_TYPE_ID              ,
		REPORTING_TYPE_CODE            ,
		REPORTING_TYPE_DATATYPE_CODE   ,
		TAX_REGIME_CODE                ,
		TAX                            ,
		FORMAT_MASK                    ,
		MIN_LENGTH                     ,
		MAX_LENGTH                     ,
		LEGAL_MESSAGE_FLAG             ,
		EFFECTIVE_FROM                 ,
		EFFECTIVE_TO                   ,
		RECORD_TYPE_CODE		  ,
		HAS_REPORTING_CODES_FLAG       ,
		CREATED_BY                     ,
		CREATION_DATE                  ,
		LAST_UPDATED_BY                ,
		LAST_UPDATE_DATE               ,
		LAST_UPDATE_LOGIN              ,
		REQUEST_ID                     ,
		PROGRAM_APPLICATION_ID         ,
		PROGRAM_ID                     ,
		PROGRAM_LOGIN_ID		,
		OBJECT_VERSION_NUMBER
		)
	VALUES(
		zx_migrate_util.get_next_seqid('zx_reporting_types_b_s') ,--REPORTING_TYPE_ID
		'CAI NUMBER'                   				 ,--REPORTING_TYPE_CODE
		--'NUMBER'                       ,--REPORTING_TYPE_DATATYPE
		'TEXT'                       ,--REPORTING_TYPE_DATATYPE (Bug6430516)
		l_tax_regime_code	       ,--TAX_REGIME_CODE
		NULL                           ,--TAX
		NULL                           ,--FORMAT_MASK
		1                              ,--MIN_LENGTH
		30                             ,--MAX_LENGTH
		'N'                            ,--LEGAL_MESSAGE_FLAG
		effective_from                 ,
		NULL                           ,--EFFECTIVE_TO
		'MIGRATED'                     ,--RECORD_TYPE_CODE
		'N'                            ,--HAS_REPORTING_CODES_FLAG
		fnd_global.user_id             ,
		SYSDATE                        ,
		fnd_global.user_id             ,
		SYSDATE                        ,
		fnd_global.conc_login_id       ,
		fnd_global.conc_request_id     , -- Request Id
		fnd_global.prog_appl_id        , -- Program Application ID
		fnd_global.conc_program_id     , -- Program Id
		fnd_global.conc_login_id       ,  -- Program Login ID
		1
		)

	--Bug# 3587896
	SELECT 	effective_from, tax_regime_code l_tax_regime_code
	FROM 	ZX_REPORTING_TYPES_B
	WHERE	REPORTING_TYPE_CODE = 'AR_DGI_TRX_CODE'; --YK:

	-----Creating reporting types for bug fix 3722296-------

	CREATE_REPORT_TYPE_PTP('JA - REG NUMBER', 'TEXT', 'N');
	CREATE_REPORT_TYPE_PTP('JL - REG NUMBER', 'TEXT', 'N');
	CREATE_REPORT_TYPE_PTP('JE - REG NUMBER', 'TEXT', 'N');
	CREATE_REPORT_TYPE_PTP('AR-SYSTEM-PARAM-REG-NUM', 'TEXT', 'N');
	CREATE_REPORT_TYPE_PTP('FSO-REG-NUM', 'TEXT', 'N');

	INSERT INTO ZX_REPORT_TYPES_USAGES(
		REPORTING_TYPE_USAGE_ID	,
		ENTITY_CODE		,
		ENABLED_FLAG		,
		CREATED_BY		,
		CREATION_DATE		,
		LAST_UPDATED_BY		,
		LAST_UPDATE_DATE	,
		LAST_UPDATE_LOGIN	,
		REPORTING_TYPE_ID	,
		OBJECT_VERSION_NUMBER
	)
	SELECT  zx_report_types_usages_s.nextval,--REPORTING_TYPE_USAGE_ID
		LOOKUP_CODE		,--ENTITY_CODE
		decode(LOOKUP_CODE,
		  'ZX_PARTY_TAX_PROFILE',
		  'Y',
		  'N')			,--ENABLED_FLAG
		fnd_global.user_id      ,--CREATED_BY
		SYSDATE                 ,--CREATION_DATE
		fnd_global.user_id      ,--LAST_UPDATED_BY
		SYSDATE                 ,--LAST_UPDATE_DATE
		fnd_global.conc_login_id,--LAST_UPDATE_LOGIN
		reporting_type_id	,--REPORTING_TYPE_ID
		1

	FROM
		zx_reporting_types_b rep_type,
		fnd_lookups

	WHERE
	          reporting_type_code = 'FISCAL PRINTER'
	AND	  LOOKUP_TYPE= 'ZX_REPORTING_TABLE_USE'

	AND  NOT EXISTS ( select 1 from zx_report_types_usages
			where reporting_type_id = rep_type.reporting_type_id and
			entity_code = fnd_lookups.lookup_code );


	INSERT INTO ZX_REPORT_TYPES_USAGES(
		REPORTING_TYPE_USAGE_ID	,
		ENTITY_CODE		,
		ENABLED_FLAG		,
		CREATED_BY		,
		CREATION_DATE		,
		LAST_UPDATED_BY		,
		LAST_UPDATE_DATE	,
		LAST_UPDATE_LOGIN	,
		REPORTING_TYPE_ID	,
		OBJECT_VERSION_NUMBER
	)
	SELECT  zx_report_types_usages_s.nextval,--REPORTING_TYPE_USAGE_ID
		LOOKUP_CODE		,--ENTITY_CODE
		decode(LOOKUP_CODE,
		  'ZX_PARTY_TAX_PROFILE',
		  'Y',
		  'N')			,--ENABLED_FLAG
		fnd_global.user_id      ,--CREATED_BY
		SYSDATE                 ,--CREATION_DATE
		fnd_global.user_id      ,--LAST_UPDATED_BY
		SYSDATE                 ,--LAST_UPDATE_DATE
		fnd_global.conc_login_id,--LAST_UPDATE_LOGIN
		reporting_type_id	,--REPORTING_TYPE_ID
		1
	FROM
	        zx_reporting_types_b rep_type,
		fnd_lookups

	WHERE
	         reporting_type_code = 'CAI NUMBER'
	AND	 LOOKUP_TYPE= 'ZX_REPORTING_TABLE_USE'

	AND  NOT EXISTS ( select 1 from zx_report_types_usages
			where reporting_type_id = rep_type.reporting_type_id and
			entity_code = fnd_lookups.lookup_code );

    --BugFix 3604885
    INSERT INTO ZX_REPORT_TYPES_USAGES(
          REPORTING_TYPE_USAGE_ID,
          REPORTING_TYPE_ID      ,
          ENTITY_CODE            ,
          ENABLED_FLAG           ,
          CREATED_BY             ,
          CREATION_DATE          ,
          LAST_UPDATED_BY        ,
          LAST_UPDATE_DATE       ,
          LAST_UPDATE_LOGIN	 ,
	  OBJECT_VERSION_NUMBER
          )
    SELECT
          zx_report_types_usages_s.nextval,--REPORTING_TYPE_USAGE_ID
          types.reporting_type_id         ,--REPORTING_TYPE_ID
          lookups.lookup_code             ,--ENTITY_CODE
          DECODE(lookups.lookup_code,
                'ZX_RATES','Y',             --Bug 5528045
                'N')             ,--ENABLED_FLAG
          fnd_global.user_id     ,
          SYSDATE                ,
          fnd_global.user_id     ,
          SYSDATE                ,
          fnd_global.conc_login_id,
	  1
     FROM
           zx_reporting_types_b types,
           fnd_lookups        lookups

    WHERE
      types.reporting_type_code IN('PT_LOCATION'           ,
                                       'PT_PRD_TAXABLE_BOX'    ,
                                       'PT_PRD_REC_TAX_BOX'    ,
                                       'PT_ANL_TTL_TAXABLE_BOX',
                                       'PT_ANL_REC_TAXABLE'    ,
                                       'PT_ANL_NON_REC_TAXABLE',
                                       'PT_ANL_REC_TAX_BOX'    ,
                                       'AR_DGI_TRX_CODE'       )
    AND   types.record_type_code    = 'MIGRATED'

    AND   lookups.LOOKUP_TYPE       = 'ZX_REPORTING_TABLE_USE'

    AND  NOT EXISTS ( select 1 from zx_report_types_usages
                      where reporting_type_id = types.reporting_type_id
                      and entity_code = lookups.lookup_code );


    CREATE_REPORTING_CODES('AR_DGI_TRX_CODE', 'JLZZ_AP_DGI_TRX_CODE');

    --Bug# 4952838
    CREATE_REPORTING_CODES('CZ_TAX_ORIGIN', 'JGZZ_TAX_ORIGIN');
    CREATE_REPORTING_CODES('HU_TAX_ORIGIN', 'JGZZ_TAX_ORIGIN');
    CREATE_REPORTING_CODES('PL_TAX_ORIGIN', 'JGZZ_TAX_ORIGIN');

    INSERT
    INTO  ZX_REPORTING_CODES_B(
		REPORTING_CODE_ID      ,
		EXCEPTION_CODE         ,
		EFFECTIVE_FROM         ,
		EFFECTIVE_TO           ,
		RECORD_TYPE_CODE       ,
		CREATED_BY                     ,
		CREATION_DATE                  ,
		LAST_UPDATED_BY                ,
		LAST_UPDATE_DATE               ,
		LAST_UPDATE_LOGIN              ,
		REQUEST_ID                     ,
		PROGRAM_APPLICATION_ID         ,
		PROGRAM_ID                     ,
		PROGRAM_LOGIN_ID		  ,
		REPORTING_CODE_CHAR_VALUE	  ,
		REPORTING_CODE_DATE_VALUE      ,
		REPORTING_CODE_NUM_VALUE       ,
		REPORTING_TYPE_ID		,
		OBJECT_VERSION_NUMBER
	   )
    SELECT
           zx_reporting_codes_b_s.nextval,--REPORTING_CODE_ID
           NULL                          ,--EXCEPTION_CODE
           EFFECTIVE_FROM                ,
           NULL                          ,--EFFECTIVE_TO
          'MIGRATED'                     ,--RECORD_TYPE_CODE
           fnd_global.user_id            ,
           SYSDATE                       ,
           fnd_global.user_id            ,
           SYSDATE                       ,
           fnd_global.conc_login_id      ,
           fnd_global.conc_request_id    , -- Request Id
           fnd_global.prog_appl_id       , -- Program Application ID
           fnd_global.conc_program_id    , -- Program Id
           fnd_global.conc_login_id      ,  -- Program Login ID
           decode(DATATYPE,'TEXT',LOOKUP_CODE,'YES_NO',LOOKUP_CODE,NULL),
	   decode(DATATYPE,'DATE',LOOKUP_CODE,NULL),
	   decode(DATATYPE,'NUMERIC_VALUE',LOOKUP_CODE,NULL),
	   REPORTING_TYPE_ID,
	   1

    FROM
    (
    SELECT
           lookups.LOOKUP_CODE           LOOKUP_CODE   ,
           report_types.EFFECTIVE_FROM   EFFECTIVE_FROM,
	   report_types.REPORTING_TYPE_ID REPORTING_TYPE_ID,
	   report_types.REPORTING_TYPE_DATATYPE_CODE DATATYPE
    FROM
        ZX_REPORTING_TYPES_B report_types,
        JA_LOOKUPS          lookups
    WHERE
             report_types.REPORTING_TYPE_CODE = 'TW_GOVERNMENT_TAX_TYPE'
    AND  report_types.RECORD_TYPE_CODE    = 'MIGRATED'
    AND  lookups.LOOKUP_TYPE = 'JATW_GOVERNMENT_TAX_TYPE'
    AND  NOT EXISTS
    	 (SELECT 1 FROM ZX_REPORTING_CODES_B WHERE
	  REPORTING_TYPE_ID   = report_types.REPORTING_TYPE_ID AND
	  REPORTING_CODE_CHAR_VALUE=lookups.LOOKUP_CODE
	 )
    );

    arp_util_tax.debug('Inserting into ZX_REPORTING_CODES_TL table');

    INSERT INTO ZX_REPORTING_CODES_TL(
           REPORTING_CODE_ID      ,
           LANGUAGE               ,
           SOURCE_LANG            ,
           REPORTING_CODE_NAME    ,
           CREATED_BY             ,
           CREATION_DATE          ,
           LAST_UPDATED_BY        ,
           LAST_UPDATE_DATE       ,
           LAST_UPDATE_LOGIN
          )
     SELECT
           codes.reporting_code_id ,
           lookups.language        ,
           lookups.source_lang     ,
	    CASE WHEN lookups.meaning = UPPER(lookups.meaning)
	     THEN    Initcap(lookups.meaning)
	     ELSE
		     lookups.meaning
	     END,
           fnd_global.user_id      ,
           sysdate                 ,
           fnd_global.user_id      ,
           sysdate                 ,
           fnd_global.conc_login_id
      FROM
	  ZX_REPORTING_TYPES_B TYPES,
          ZX_REPORTING_CODES_B CODES,
	  FND_LOOKUP_VALUES    lookups,
	  FND_LANGUAGES L
      WHERE

           TYPES.REPORTING_TYPE_ID     = CODES.REPORTING_TYPE_ID
      AND  TYPES.REPORTING_TYPE_CODE   = 'TW_GOVERNMENT_TAX_TYPE'
      AND  lookups.LOOKUP_TYPE         = 'JATW_GOVERNMENT_TAX_TYPE'
      AND  CODES.REPORTING_CODE_CHAR_VALUE = lookups.lookup_code
      AND  CODES.RECORD_TYPE_CODE      = 'MIGRATED'
      AND  lookups.VIEW_APPLICATION_ID = 7000  -- Pl note Application id is different here.
      AND  lookups.SECURITY_GROUP_ID   = 0
      AND  lookups.LANGUAGE            = L.LANGUAGE_CODE(+)
      AND  L.INSTALLED_FLAG in ('I', 'B')
      AND  not exists
               (select NULL
                from ZX_REPORTING_CODES_TL T
                where T.REPORTING_CODE_ID = CODES.REPORTING_CODE_ID
                and T.LANGUAGE = L.LANGUAGE_CODE);


    INSERT INTO ZX_REPORTING_TYPES_TL(
           REPORTING_TYPE_ID      ,
           LANGUAGE               ,
           SOURCE_LANG            ,
           REPORTING_TYPE_NAME    ,
           CREATED_BY             ,
           CREATION_DATE          ,
           LAST_UPDATED_BY        ,
           LAST_UPDATE_DATE       ,
           LAST_UPDATE_LOGIN
          )
     SELECT
     	REPORTING_TYPE_ID	,
     	LANGUAGE_CODE		,
     	userenv('LANG')    	,
     	REPORTING_TYPE_NAME ,
		fnd_global.user_id             ,
		SYSDATE                        ,
		fnd_global.user_id             ,
		SYSDATE                        ,
		fnd_global.conc_login_id

     FROM
     (
        SELECT
           types.REPORTING_TYPE_ID ,
           L.LANGUAGE_CODE         ,
           CASE
           WHEN types.REPORTING_TYPE_CODE = 'PT_LOCATION'
           	THEN 'Location'
           WHEN types.REPORTING_TYPE_CODE = 'PT_PRD_TAXABLE_BOX'
           	THEN 'Periodic: Taxable Box'
           WHEN types.REPORTING_TYPE_CODE = 'PT_PRD_REC_TAX_BOX'
           	THEN 'Periodic: Recoverable Tax Box'
           WHEN types.REPORTING_TYPE_CODE = 'PT_ANL_TTL_TAXABLE_BOX'
           	THEN 'Annual: Total Taxable Box'
           WHEN types.REPORTING_TYPE_CODE = 'PT_ANL_REC_TAXABLE'
           	THEN 'Annual: Recoverable Taxable'
           WHEN types.REPORTING_TYPE_CODE = 'PT_ANL_NON_REC_TAXABLE'
           	THEN 'Annual: Non Recoverable Taxable'
           WHEN types.REPORTING_TYPE_CODE = 'PT_ANL_REC_TAX_BOX'
           	THEN 'Annual: Recoverable Tax Box'
           WHEN types.REPORTING_TYPE_CODE = 'AR_DGI_TRX_CODE'
           	THEN 'DGI Transaction Code'
           WHEN types.REPORTING_TYPE_CODE = 'FISCAL PRINTER'
           	THEN 'Fiscal Printer Used'
           WHEN types.REPORTING_TYPE_CODE = 'CAI NUMBER'
           	THEN 'CAI Number'
	   WHEN types.REPORTING_TYPE_CODE = 'TAX_CODE_CLASSIFICATION'
	   	THEN 'Tax Code Classification'
	   -- Bug # 4952838
	   WHEN types.REPORTING_TYPE_CODE = 'CZ_TAX_ORIGIN' or
	        types.REPORTING_TYPE_CODE = 'HU_TAX_ORIGIN' or
	        types.REPORTING_TYPE_CODE = 'PL_TAX_ORIGIN'
	   	THEN 'Tax Origin'
	   WHEN types.REPORTING_TYPE_CODE = 'CH_VAT_REGIME'
	   	THEN 'Tax Regime'
	   WHEN types.REPORTING_TYPE_CODE = 'CL_DEBIT_ACCOUNT'
	   	THEN 'Debit Account'

           ELSE  types.REPORTING_TYPE_CODE   END  REPORTING_TYPE_NAME -- Bug 4886324

        FROM
	 ZX_REPORTING_TYPES_B TYPES,
	 FND_LANGUAGES L
	 WHERE
	        TYPES.RECORD_TYPE_CODE = 'MIGRATED'
	AND L.INSTALLED_FLAG in ('I', 'B')
	) TYPES

	WHERE REPORTING_TYPE_NAME is not null
	AND  not exists
	    (select NULL
	    from ZX_REPORTING_TYPES_TL T
	    where T.REPORTING_TYPE_ID = TYPES.REPORTING_TYPE_ID
	    and T.LANGUAGE = TYPES.LANGUAGE_CODE);

    --BugFix 3557652 REPORTING CODE_TL IMPL FOR ARGENTINE DGI TRANSACTION CODE
    --Bug# 4952838. Moved this logic to common procedure CREATE_REPORTING_CODES
    /*
    INSERT INTO ZX_REPORTING_CODES_TL(
           REPORTING_CODE_ID      ,
           LANGUAGE               ,
           SOURCE_LANG            ,
           REPORTING_CODE_NAME    ,
           CREATED_BY             ,
           CREATION_DATE          ,
           LAST_UPDATED_BY        ,
           LAST_UPDATE_DATE       ,
           LAST_UPDATE_LOGIN
          )
     SELECT
           codes.reporting_code_id ,
           lookups.language        ,
           lookups.source_lang     ,
           lookups.meaning         ,
           fnd_global.user_id      ,
           sysdate                 ,
           fnd_global.user_id      ,
           sysdate                 ,
           fnd_global.conc_login_id
      FROM
	  ZX_REPORTING_TYPES_B TYPES,
          ZX_REPORTING_CODES_B CODES,
	  FND_LOOKUP_VALUES    lookups,
	  FND_LANGUAGES L
      WHERE

           TYPES.REPORTING_TYPE_ID     = CODES.REPORTING_TYPE_ID
      AND  TYPES.REPORTING_TYPE_CODE   = 'AR_DGI_TRX_CODE'
      AND  lookups.LOOKUP_TYPE         = 'JLZZ_AP_DGI_TRX_CODE'  --Bug Fix 4930895
      AND  CODES.REPORTING_CODE_CHAR_VALUE = lookups.lookup_code --Bug Fix 4930895
      AND  CODES.RECORD_TYPE_CODE      = 'MIGRATED'
      AND  lookups.VIEW_APPLICATION_ID = 0
      AND  lookups.SECURITY_GROUP_ID   = 0
      AND  lookups.LANGUAGE            = L.LANGUAGE_CODE(+)
      AND  L.INSTALLED_FLAG in ('I', 'B')
      AND  not exists
               (select NULL
                from ZX_REPORTING_CODES_TL T
                where T.REPORTING_CODE_ID = CODES.REPORTING_CODE_ID
                and T.LANGUAGE = L.LANGUAGE_CODE);
      */

    INSERT INTO ZX_REPORTING_CODES_TL(
           REPORTING_CODE_ID      ,
           LANGUAGE               ,
           SOURCE_LANG            ,
           REPORTING_CODE_NAME    ,
           CREATED_BY             ,
           CREATION_DATE          ,
           LAST_UPDATED_BY        ,
           LAST_UPDATE_DATE       ,
           LAST_UPDATE_LOGIN
          )
     SELECT
           codes.reporting_code_id,
           L.LANGUAGE_CODE        ,
           userenv('LANG')        ,
           CASE
           WHEN CODES.REPORTING_CODE_CHAR_VALUE = 'A'
           THEN Initcap('ACORES')
           WHEN CODES.REPORTING_CODE_CHAR_VALUE = 'C'
           THEN Initcap('CONTINENTE')
           WHEN CODES.REPORTING_CODE_CHAR_VALUE = 'M'
           THEN Initcap('MADEIRA')
           ELSE
		    CASE WHEN CODES.REPORTING_CODE_CHAR_VALUE = UPPER(CODES.REPORTING_CODE_CHAR_VALUE)
		     THEN    Initcap(CODES.REPORTING_CODE_CHAR_VALUE)
		     ELSE
			     CODES.REPORTING_CODE_CHAR_VALUE
		     END
           END  ,--REPORTING_CODE_NAME
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id
      FROM
          ZX_REPORTING_CODES_B CODES,
          FND_LANGUAGES L

      WHERE
                CODES.RECORD_TYPE_CODE  = 'MIGRATED'
      AND   L.INSTALLED_FLAG in ('I', 'B')
      AND   not exists
                (select NULL
                from ZX_REPORTING_CODES_TL T
                where T.REPORTING_CODE_ID = CODES.REPORTING_CODE_ID
                and T.LANGUAGE = L.LANGUAGE_CODE);


    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('CREATE_ZX_REP_TYPE_CODES(-)');
    END IF;

EXCEPTION
         WHEN OTHERS THEN
            IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: CREATE_ZX_REP_TYPE_CODES ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('CREATE_ZX_REP_TYPE_CODES(-)');
            END IF;
            app_exception.raise_exception;

END CREATE_ZX_REP_TYPE_CODES;


/*THIS IS THE COMMON PROCEDURE USED TO INSERT THE  REPORTING TYPES FOR AR*/

PROCEDURE  CREATE_REPORTING_TYPE_AR(
	p_reporting_type_code 	IN  ZX_REPORTING_TYPES_B.REPORTING_TYPE_CODE %TYPE,
	p_datatype		IN  ZX_REPORTING_TYPES_B.REPORTING_TYPE_DATATYPE_CODE%TYPE,
	p_has_rep_code		IN  ZX_REPORTING_TYPES_B.HAS_REPORTING_CODES_FLAG%TYPE,
	P_category		IN  AR_VAT_TAX_ALL_B.GLOBAL_ATTRIBUTE_CATEGORY%TYPE,
	p_tax_id	        IN  NUMBER
	)
IS

BEGIN

    arp_util_tax.debug('CREATE_REPORTING_TYPE_AR(+)');
    arp_util_tax.debug('p_reporting_type_code = '||p_reporting_type_code);
INSERT ALL
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code= p_reporting_type_code
                       and    tax_regime_code = l_tax_regime_code)
          ) THEN
    INTO  ZX_REPORTING_TYPES_B(
		REPORTING_TYPE_ID              ,
		REPORTING_TYPE_CODE            ,
		REPORTING_TYPE_DATATYPE_CODE   ,
		TAX_REGIME_CODE                ,
		TAX                            ,
		FORMAT_MASK                    ,
		MIN_LENGTH                     ,
		MAX_LENGTH                     ,
		LEGAL_MESSAGE_FLAG             ,
		EFFECTIVE_FROM                 ,
		EFFECTIVE_TO                   ,
		RECORD_TYPE_CODE               ,
		HAS_REPORTING_CODES_FLAG       ,
		CREATED_BY                     ,
		CREATION_DATE                  ,
		LAST_UPDATED_BY                ,
		LAST_UPDATE_DATE               ,
		LAST_UPDATE_LOGIN              ,
		REQUEST_ID                     ,
		PROGRAM_APPLICATION_ID         ,
		PROGRAM_ID                     ,
		PROGRAM_LOGIN_ID		,
		OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_reporting_types_b_s.nextval ,--REPORTING_TYPE_ID
           p_reporting_type_code              ,--REPORTING_TYPE_CODE
           p_datatype		,             --REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                           ,--MIN_LENGTH
           30                           ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
           p_has_rep_code              , --HAS_REPORTING_CODES_FLAG
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       ,  -- Program Login ID
	   1
          )
    SELECT
           min(zx_rates.effective_from) effective_from,
           zx_rates.tax_regime_code  l_tax_regime_code
    FROM
        AR_VAT_TAX_ALL_B  vat_tax,
        zx_rates_b zx_rates
    WHERE
         vat_tax.vat_tax_id                = zx_rates.tax_rate_id
    AND  vat_tax.global_attribute_category = p_category
    AND  zx_rates.record_type_code         = 'MIGRATED'
    AND  vat_tax.vat_tax_id                = nvl(p_tax_id, vat_tax.vat_tax_id)
    GROUP BY
            zx_rates.tax_regime_code;

     arp_util_tax.debug('CREATE_REPORTING_TYPE_AR(-)');

END CREATE_REPORTING_TYPE_AR;


/*THIS IS THE COMMON PROCEDURE USED TO INSERT THE  REPORTING TYPES FOR AP*/

PROCEDURE  CREATE_REPORTING_TYPE_AP(
	p_reporting_type_code 	IN  ZX_REPORTING_TYPES_B.REPORTING_TYPE_CODE %TYPE,
	p_datatype		IN  ZX_REPORTING_TYPES_B.REPORTING_TYPE_DATATYPE_CODE%TYPE,
	p_has_rep_code		IN  ZX_REPORTING_TYPES_B.HAS_REPORTING_CODES_FLAG%TYPE,
	P_category		IN  AR_VAT_TAX_ALL_B.GLOBAL_ATTRIBUTE_CATEGORY%TYPE,
	p_tax_id	        IN  NUMBER
	)
IS

BEGIN

    arp_util_tax.debug('CREATE_REPORTING_TYPE_AP(+)');
    arp_util_tax.debug('p_reporting_type_code = '||p_reporting_type_code);
INSERT ALL
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code= p_reporting_type_code
                       and    tax_regime_code = l_tax_regime_code)
          ) THEN
    INTO  ZX_REPORTING_TYPES_B(
		REPORTING_TYPE_ID              ,
		REPORTING_TYPE_CODE            ,
		REPORTING_TYPE_DATATYPE_CODE   ,
		TAX_REGIME_CODE                ,
		TAX                            ,
		FORMAT_MASK                    ,
		MIN_LENGTH                     ,
		MAX_LENGTH                     ,
		LEGAL_MESSAGE_FLAG             ,
		EFFECTIVE_FROM                 ,
		EFFECTIVE_TO                   ,
		RECORD_TYPE_CODE               ,
		HAS_REPORTING_CODES_FLAG       ,
		CREATED_BY                     ,
		CREATION_DATE                  ,
		LAST_UPDATED_BY                ,
		LAST_UPDATE_DATE               ,
		LAST_UPDATE_LOGIN              ,
		REQUEST_ID                     ,
		PROGRAM_APPLICATION_ID         ,
		PROGRAM_ID                     ,
		PROGRAM_LOGIN_ID		,
		OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_reporting_types_b_s.nextval ,--REPORTING_TYPE_ID
           p_reporting_type_code              ,--REPORTING_TYPE_CODE
           p_datatype		,             --REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                           ,--MIN_LENGTH
           30                           ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
           p_has_rep_code              , --HAS_REPORTING_CODES_FLAG
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       ,  -- Program Login ID
	   1
          )
    SELECT
           min(zx_rates.effective_from) effective_from,
           zx_rates.tax_regime_code  l_tax_regime_code
    FROM
        ap_tax_codes_all codes,
        zx_rates_b zx_rates
    WHERE
         codes.tax_id                    = zx_rates.tax_rate_id
    AND  codes.tax_id                    = nvl(p_tax_id,codes.tax_id)
    AND  codes.global_attribute_category = p_category
    AND  zx_rates.record_type_code       = 'MIGRATED'

    GROUP BY
            zx_rates.tax_regime_code;

     arp_util_tax.debug('CREATE_REPORTING_TYPE_AP(-)');

END CREATE_REPORTING_TYPE_AP;


/*THIS IS THE COMMON PROCEDURE USED TO INSERT THE  REPORTING CODES */

PROCEDURE  CREATE_REPORTING_CODES (
	p_reporting_type_code 	IN  ZX_REPORTING_TYPES_B.REPORTING_TYPE_CODE %TYPE,
	P_lookup_type		IN  FND_LOOKUPS.LOOKUP_TYPE%TYPE
	) IS

BEGIN
  arp_util_tax.debug('CREATE_REPORTING_CODES(+)');
  arp_util_tax.debug('p_reporting_type_code = '||p_reporting_type_code);
  arp_util_tax.debug('p_lookup_type = '||p_lookup_type);
    INSERT
    INTO  ZX_REPORTING_CODES_B(
		REPORTING_CODE_ID      ,
		EXCEPTION_CODE         ,
		EFFECTIVE_FROM         ,
		EFFECTIVE_TO           ,
		RECORD_TYPE_CODE       ,
		CREATED_BY                     ,
		CREATION_DATE                  ,
		LAST_UPDATED_BY                ,
		LAST_UPDATE_DATE               ,
		LAST_UPDATE_LOGIN              ,
		REQUEST_ID                     ,
		PROGRAM_APPLICATION_ID         ,
		PROGRAM_ID                     ,
		PROGRAM_LOGIN_ID		  ,
		REPORTING_CODE_CHAR_VALUE	  ,
		REPORTING_CODE_DATE_VALUE      ,
		REPORTING_CODE_NUM_VALUE       ,
		REPORTING_TYPE_ID		,
		OBJECT_VERSION_NUMBER
	   )
    SELECT
           zx_reporting_codes_b_s.nextval,--REPORTING_CODE_ID
           NULL                          ,--EXCEPTION_CODE
           EFFECTIVE_FROM                ,
           NULL                          ,--EFFECTIVE_TO
          'MIGRATED'                     ,--RECORD_TYPE_CODE
           fnd_global.user_id            ,
           SYSDATE                       ,
           fnd_global.user_id            ,
           SYSDATE                       ,
           fnd_global.conc_login_id      ,
           fnd_global.conc_request_id    , -- Request Id
           fnd_global.prog_appl_id       , -- Program Application ID
           fnd_global.conc_program_id    , -- Program Id
           fnd_global.conc_login_id      ,  -- Program Login ID
           decode(DATATYPE,'TEXT',LOOKUP_CODE,'YES_NO',LOOKUP_CODE,NULL),
	   decode(DATATYPE,'DATE',LOOKUP_CODE,NULL),
	   decode(DATATYPE,'NUMERIC_VALUE',LOOKUP_CODE,NULL),
	   REPORTING_TYPE_ID,
	   1

    FROM
    (
    SELECT
           lookups.LOOKUP_CODE           LOOKUP_CODE   ,
           report_types.EFFECTIVE_FROM   EFFECTIVE_FROM,
	   report_types.REPORTING_TYPE_ID REPORTING_TYPE_ID,
	   report_types.REPORTING_TYPE_DATATYPE_CODE DATATYPE
    FROM
        ZX_REPORTING_TYPES_B report_types,
        FND_LOOKUPS          lookups
    WHERE
             report_types.REPORTING_TYPE_CODE = p_reporting_type_code
    AND  report_types.RECORD_TYPE_CODE    = 'MIGRATED'
    AND  lookups.LOOKUP_TYPE = p_lookup_type
    AND  NOT EXISTS
    	 (SELECT 1 FROM ZX_REPORTING_CODES_B WHERE
	  REPORTING_TYPE_ID   = report_types.REPORTING_TYPE_ID AND
	  REPORTING_CODE_CHAR_VALUE=lookups.LOOKUP_CODE
	 )
    );

    arp_util_tax.debug('Inserting into ZX_REPORTING_CODES_TL table');

    INSERT INTO ZX_REPORTING_CODES_TL(
           REPORTING_CODE_ID      ,
           LANGUAGE               ,
           SOURCE_LANG            ,
           REPORTING_CODE_NAME    ,
           CREATED_BY             ,
           CREATION_DATE          ,
           LAST_UPDATED_BY        ,
           LAST_UPDATE_DATE       ,
           LAST_UPDATE_LOGIN
          )
     SELECT
           codes.reporting_code_id ,
           lookups.language        ,
           lookups.source_lang     ,
	    CASE WHEN lookups.meaning = UPPER(lookups.meaning)
	     THEN    Initcap(lookups.meaning)
	     ELSE
		     lookups.meaning
	     END,
           fnd_global.user_id      ,
           sysdate                 ,
           fnd_global.user_id      ,
           sysdate                 ,
           fnd_global.conc_login_id
      FROM
	  ZX_REPORTING_TYPES_B TYPES,
          ZX_REPORTING_CODES_B CODES,
	  FND_LOOKUP_VALUES    lookups,
	  FND_LANGUAGES L
      WHERE

           TYPES.REPORTING_TYPE_ID     = CODES.REPORTING_TYPE_ID
      AND  TYPES.REPORTING_TYPE_CODE   = p_reporting_type_code
      AND  lookups.LOOKUP_TYPE         = p_lookup_type  --Bug Fix 4930895
      AND  CODES.REPORTING_CODE_CHAR_VALUE = lookups.lookup_code --Bug Fix 4930895
      AND  CODES.RECORD_TYPE_CODE      = 'MIGRATED'
      AND  lookups.VIEW_APPLICATION_ID = 0
      AND  lookups.SECURITY_GROUP_ID   = 0
      AND  lookups.LANGUAGE            = L.LANGUAGE_CODE(+)
      AND  L.INSTALLED_FLAG in ('I', 'B')
      AND  not exists
               (select NULL
                from ZX_REPORTING_CODES_TL T
                where T.REPORTING_CODE_ID = CODES.REPORTING_CODE_ID
                and T.LANGUAGE = L.LANGUAGE_CODE);


    arp_util_tax.debug('CREATE_REPORTING_CODES(-)');

END CREATE_REPORTING_CODES;


/* Used to create the reporting code association for AP */

PROCEDURE CREATE_ZX_REPORTING_ASSOC_AP(p_tax_id IN NUMBER)  IS
	l_status fnd_module_installations.status%TYPE;
	l_db_status fnd_module_installations.DB_STATUS%TYPE;

BEGIN
   arp_util_tax.debug(' CREATE_ZX_REPORTING_ASSOC_AP(+)');
     -- Verify Argentina Installation
     BEGIN
     	SELECT STATUS, DB_STATUS
        INTO l_status, l_db_status
        FROM  fnd_module_installations
        WHERE APPLICATION_ID = '7004'
	And MODULE_SHORT_NAME = 'jlarloc';
     EXCEPTION
        WHEN OTHERS THEN
		IF PG_DEBUG = 'Y' THEN
       		    arp_util_tax.debug('Error in verification of argentina installation ');
    		 END IF;
     END;

     IF (nvl(l_status,'N') in ('I','S') or
         nvl(l_db_status,'N') in ('I','S')) THEN


	-- Code for Reporting Code Association. Bug # 3594759
	-- Insert the Fiscal Printer Codes into Association table
    	 IF PG_DEBUG = 'Y' THEN
     		arp_util_tax.debug('Entering into zx_report_codes_assoc insert statement');
    	 END IF;
--Bug 5247324
/*
	INSERT INTO ZX_REPORT_CODES_ASSOC(
		REPORTING_CODE_ASSOC_ID,
		ENTITY_CODE,
		ENTITY_ID,
		REPORTING_TYPE_ID,
		REPORTING_CODE_CHAR_VALUE,
		EXCEPTION_CODE,
		EFFECTIVE_FROM,
		EFFECTIVE_TO,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
		OBJECT_VERSION_NUMBER)
	(SELECT
		ZX_REPORT_CODES_ASSOC_S.nextval, --REPORTING_CODE_ASSOC_ID
		'ZX_PARTY_TAX_PROFILE',		 --ENTITY_CODE
		ptp.Party_Tax_Profile_Id,	 --ENTITY_ID
		REPORTING_TYPE_ID	,	 --REPORTING_TYPE_ID
		pvs.GLOBAL_ATTRIBUTE18,		 --REPORTING_CODE_CHAR_VALUE
		null,				 --EXCEPTION_CODE
		sysdate,			 --EFFECTIVE_FROM
		null,				 --EFFECTIVE_TO
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		sysdate,
		fnd_global.conc_login_id,
		1
	FROM
		zx_reporting_types_b types,
		ap_supplier_sites pvs,
		zx_party_tax_profile ptp

	WHERE

		types.reporting_type_code = 'FISCAL PRINTER'  and
		pvs.GLOBAL_ATTRIBUTE_CATEGORY='JL.AR.APXVDMVD.SUPPLIER_SITES'  and
		ptp.Party_Type_Code = 'THIRD_PARTY_SITE' AND  -- Bug 4886324
	        ptp.party_id = pvs.PARTY_SITE_ID

		AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_PARTY_TAX_PROFILE'
                    and      entity_id           = ptp.Party_Tax_Profile_Id
                    and      reporting_type_id = types.reporting_type_id));


	-- Insert the CAI Number and Date into Association table

	INSERT INTO ZX_REPORT_CODES_ASSOC(
		REPORTING_CODE_ASSOC_ID,
		ENTITY_CODE,
		ENTITY_ID,
		REPORTING_TYPE_ID,
		REPORTING_CODE_NUM_VALUE,
		EXCEPTION_CODE,
		EFFECTIVE_FROM,
		EFFECTIVE_TO,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
		OBJECT_VERSION_NUMBER)
	(SELECT
		ZX_REPORT_CODES_ASSOC_S.nextval, --REPORTING_CODE_ASSOC_ID
		'ZX_PARTY_TAX_PROFILE',		 --ENTITY_CODE
		ptp.Party_Tax_Profile_Id,	 --ENTITY_ID
		REPORTING_TYPE_ID       ,	 --REPORTING_TYPE_ID
		pvs.GLOBAL_ATTRIBUTE19,		 --REPORTING_CODE_NUM_VALUE
		null,				 --EXCEPTION_CODE
		sysdate,			 --EFFECTIVE_FROM
		to_date(pvs.GLOBAL_ATTRIBUTE20,'yyyy/mm/dd hh24:mi:ss'),--EFFECTIVE_TO
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		sysdate,
		fnd_global.conc_login_id,
		1
	FROM
	       zx_reporting_types_b types,
	       ap_supplier_sites pvs ,
	       zx_party_tax_profile ptp

	WHERE
		types.reporting_type_code = 'CAI NUMBER' and
		pvs.GLOBAL_ATTRIBUTE_CATEGORY='JL.AR.APXVDMVD.SUPPLIER_SITES' and
		ptp.Party_Type_Code = 'THIRD_PARTY_SITE' AND  -- Bug 4886324
		ptp.party_id = pvs.PARTY_SITE_ID
    		AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_PARTY_TAX_PROFILE'
                    and    entity_id           = ptp.Party_Tax_Profile_Id
                    and    reporting_type_id = types.reporting_type_id));
*/

	--BugFix 3557652 REPORTING CODE ASSOC IMPL FOR ARGENTINE DGI TRANSACTION CODE
	--Association for Reporting Type Code AR_DGI_TRX_CODE
       INSERT INTO
		ZX_REPORT_CODES_ASSOC(
		REPORTING_CODE_ASSOC_ID,
		ENTITY_CODE            ,
		ENTITY_ID              ,
		REPORTING_TYPE_ID      ,
		REPORTING_CODE_ID      ,
		EXCEPTION_CODE         ,
		EFFECTIVE_FROM         ,
		EFFECTIVE_TO           ,
		CREATED_BY             ,
		CREATION_DATE          ,
		LAST_UPDATED_BY        ,
		LAST_UPDATE_DATE       ,
		LAST_UPDATE_LOGIN	 ,
		REPORTING_CODE_CHAR_VALUE,
		REPORTING_CODE_DATE_VALUE,
		REPORTING_CODE_NUM_VALUE,
		OBJECT_VERSION_NUMBER
		)
       (SELECT
		ZX_REPORT_CODES_ASSOC_S.nextval		,
		'ZX_RATES'				,--ENTITY_CODE
		rates.TAX_RATE_ID			,--ENTITY_ID
		report_codes.REPORTING_TYPE_ID		,
		report_codes.REPORTING_CODE_ID          ,
		NULL					,--EXCEPTION_CODE
		rates.EFFECTIVE_FROM             ,
		NULL					,--EFFECTIVE_TO
		fnd_global.user_id			,
		SYSDATE					,
		fnd_global.user_id			,
		SYSDATE					,
		fnd_global.conc_login_id		,
		report_codes.REPORTING_CODE_CHAR_VALUE	,
		report_codes.REPORTING_CODE_DATE_VALUE	,
		report_codes.REPORTING_CODE_NUM_VALUE   ,
		1
	FROM

		AP_TAX_CODES_ALL codes,
		ZX_RATES_B       rates,
		ZX_REPORTING_CODES_B report_codes
	WHERE
		     codes.tax_id               =  rates.tax_rate_id
	        AND  codes.tax_id  =  nvl(p_tax_id,codes.tax_id)
		AND  codes.global_attribute_category = 'JL.AR.APXTADTC.VAT'
		AND  codes.global_attribute4  	     =
		     report_codes.REPORTING_CODE_CHAR_VALUE
		AND  rates.record_type_code          = 'MIGRATED'
		AND  report_codes.record_type_code   = 'MIGRATED'


		AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
			    where  entity_code         = 'ZX_RATES'
			    and    entity_id           = rates.tax_rate_id
			    and    reporting_type_id =
				   report_codes.reporting_type_id)
		);


     END IF; -- end of Argentina Installation verification

   --Association for Reporting Type Code PT_ANL_REC_TAX_BOX
   INSERT
   INTO   ZX_REPORT_CODES_ASSOC(
          REPORTING_CODE_ASSOC_ID,
          ENTITY_CODE            ,
          ENTITY_ID              ,
          REPORTING_TYPE_ID      ,
          REPORTING_CODE_ID      ,
          EXCEPTION_CODE         ,
          EFFECTIVE_FROM         ,
          EFFECTIVE_TO           ,
          CREATED_BY             ,
          CREATION_DATE          ,
          LAST_UPDATED_BY        ,
          LAST_UPDATE_DATE       ,
          LAST_UPDATE_LOGIN	 ,
	  REPORTING_CODE_CHAR_VALUE,
	  REPORTING_CODE_DATE_VALUE,
	  REPORTING_CODE_NUM_VALUE,
	  OBJECT_VERSION_NUMBER
				)
    SELECT
          ZX_REPORT_CODES_ASSOC_S.nextval  ,
         'ZX_RATES'                        ,--ENTITY_CODE
          TAX_RATE_ID                      ,--ENTITY_ID
          REPORTING_TYPE_ID              ,
          REPORTING_CODE_ID                   ,
          NULL                             ,--EXCEPTION_CODE
          EFFECTIVE_FROM                   ,
          NULL                             ,--EFFECTIVE_TO
          fnd_global.user_id               ,
          SYSDATE                          ,
          fnd_global.user_id               ,
          SYSDATE                          ,
          fnd_global.conc_login_id	   ,
	  REPORTING_CODE_CHAR_VALUE,
	  REPORTING_CODE_DATE_VALUE,
 	  REPORTING_CODE_NUM_VALUE,
	  1
    FROM
    (
    SELECT
          rates.TAX_RATE_ID                       TAX_RATE_ID,
          report_codes.REPORTING_CODE_ID          REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM             EFFECTIVE_FROM,
	  report_codes.REPORTING_TYPE_ID          REPORTING_TYPE_ID,
	  report_codes.REPORTING_CODE_CHAR_VALUE  REPORTING_CODE_CHAR_VALUE ,
	  report_codes.REPORTING_CODE_DATE_VALUE  REPORTING_CODE_DATE_VALUE,
 	  report_codes.REPORTING_CODE_NUM_VALUE   REPORTING_CODE_NUM_VALUE
    FROM
          AP_TAX_CODES_ALL codes,
          ZX_RATES_B       rates,
	  ZX_REPORTING_TYPES_B  reporting_types,
          ZX_REPORTING_CODES_B report_codes
    WHERE
             codes.tax_id                    =  rates.tax_rate_id
    AND  codes.tax_id                    =  nvl(p_tax_id,codes.tax_id)
    AND  codes.global_attribute_category = 'JE.PT.APXTADTC.TAX_INFO'
    AND  codes.global_attribute1         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  reporting_types.reporting_type_code = 'PT_LOCATION'
    AND  reporting_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
    AND  reporting_types.reporting_type_id = report_codes.reporting_type_id
    AND  report_codes.record_type_code   = 'MIGRATED'

    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id   =
                           report_codes.reporting_type_id)

    --Bug# 4952838
    UNION ALL
    SELECT
          rates.TAX_RATE_ID                       TAX_RATE_ID,
          report_codes.REPORTING_CODE_ID          REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM             EFFECTIVE_FROM,
	  report_codes.REPORTING_TYPE_ID          REPORTING_TYPE_ID,
	  report_codes.REPORTING_CODE_CHAR_VALUE  REPORTING_CODE_CHAR_VALUE ,
	  report_codes.REPORTING_CODE_DATE_VALUE  REPORTING_CODE_DATE_VALUE,
 	  report_codes.REPORTING_CODE_NUM_VALUE   REPORTING_CODE_NUM_VALUE
    FROM
          AP_TAX_CODES_ALL codes,
          ZX_RATES_B       rates,
	  ZX_REPORTING_TYPES_B  reporting_types,
          ZX_REPORTING_CODES_B report_codes
    WHERE
             codes.tax_id                    =  rates.tax_rate_id
    AND  codes.tax_id                    =  nvl(p_tax_id,codes.tax_id)
    AND  codes.global_attribute_category = 'JE.CZ.APXTADTC.TAX_ORIGIN'
    AND  codes.global_attribute1         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  reporting_types.reporting_type_code = 'CZ_TAX_ORIGIN'
    AND  reporting_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
    AND  reporting_types.reporting_type_id = report_codes.reporting_type_id
    AND  report_codes.record_type_code   = 'MIGRATED'

    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id   =
                           report_codes.reporting_type_id)

    UNION ALL
    SELECT
          rates.TAX_RATE_ID                       TAX_RATE_ID,
          report_codes.REPORTING_CODE_ID          REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM             EFFECTIVE_FROM,
	  report_codes.REPORTING_TYPE_ID          REPORTING_TYPE_ID,
	  report_codes.REPORTING_CODE_CHAR_VALUE  REPORTING_CODE_CHAR_VALUE ,
	  report_codes.REPORTING_CODE_DATE_VALUE  REPORTING_CODE_DATE_VALUE,
 	  report_codes.REPORTING_CODE_NUM_VALUE   REPORTING_CODE_NUM_VALUE
    FROM
          AP_TAX_CODES_ALL codes,
          ZX_RATES_B       rates,
	  ZX_REPORTING_TYPES_B  reporting_types,
          ZX_REPORTING_CODES_B report_codes
    WHERE
             codes.tax_id                    =  rates.tax_rate_id
    AND  codes.tax_id                    =  nvl(p_tax_id,codes.tax_id)
    AND  codes.global_attribute_category = 'JE.HU.APXTADTC.TAX_ORIGIN'
    AND  codes.global_attribute1         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  reporting_types.reporting_type_code = 'HU_TAX_ORIGIN'
    AND  reporting_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
    AND  reporting_types.reporting_type_id = report_codes.reporting_type_id
    AND  report_codes.record_type_code   = 'MIGRATED'

    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id   =
                           report_codes.reporting_type_id)

    UNION ALL
    SELECT
          rates.TAX_RATE_ID                       TAX_RATE_ID,
          report_codes.REPORTING_CODE_ID          REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM             EFFECTIVE_FROM,
	  report_codes.REPORTING_TYPE_ID          REPORTING_TYPE_ID,
	  report_codes.REPORTING_CODE_CHAR_VALUE  REPORTING_CODE_CHAR_VALUE ,
	  report_codes.REPORTING_CODE_DATE_VALUE  REPORTING_CODE_DATE_VALUE,
 	  report_codes.REPORTING_CODE_NUM_VALUE   REPORTING_CODE_NUM_VALUE
    FROM
          AP_TAX_CODES_ALL codes,
          ZX_RATES_B       rates,
	  ZX_REPORTING_TYPES_B  reporting_types,
          ZX_REPORTING_CODES_B report_codes
    WHERE
             codes.tax_id                =  rates.tax_rate_id
    AND  codes.tax_id                    =  nvl(p_tax_id,codes.tax_id)
    AND  codes.global_attribute_category = 'JE.PL.APXTADTC.TAX_ORIGIN'
    AND  codes.global_attribute1         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  reporting_types.reporting_type_code = 'PL_TAX_ORIGIN'
    AND  reporting_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
    AND  reporting_types.reporting_type_id = report_codes.reporting_type_id
    AND  report_codes.record_type_code   = 'MIGRATED'

    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id   =
                           report_codes.reporting_type_id)

    UNION ALL
    SELECT
          rates.TAX_RATE_ID                       TAX_RATE_ID,
          report_codes.REPORTING_CODE_ID          REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM             EFFECTIVE_FROM,
	  report_codes.REPORTING_TYPE_ID          REPORTING_TYPE_ID,
	  report_codes.REPORTING_CODE_CHAR_VALUE  REPORTING_CODE_CHAR_VALUE ,
	  report_codes.REPORTING_CODE_DATE_VALUE  REPORTING_CODE_DATE_VALUE,
 	  report_codes.REPORTING_CODE_NUM_VALUE   REPORTING_CODE_NUM_VALUE
    FROM
          AP_TAX_CODES_ALL codes,
          ZX_RATES_B       rates,
	  ZX_REPORTING_TYPES_B  reporting_types,
          ZX_REPORTING_CODES_B report_codes
    WHERE
             codes.tax_id                =  rates.tax_rate_id
    AND  codes.tax_id                    =  nvl(p_tax_id,codes.tax_id)
    AND  codes.global_attribute_category = 'JE.CH.APXTADTC.TAX_INFO'
    AND  codes.global_attribute1         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  reporting_types.reporting_type_code = 'CH_VAT_REGIME'
    AND  reporting_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
    AND  reporting_types.reporting_type_id = report_codes.reporting_type_id
    AND  report_codes.record_type_code   = 'MIGRATED'

    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id   =
                           report_codes.reporting_type_id)

    UNION ALL
    SELECT
          rates.TAX_RATE_ID                       TAX_RATE_ID,
          report_codes.REPORTING_CODE_ID          REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM             EFFECTIVE_FROM,
	  report_codes.REPORTING_TYPE_ID          REPORTING_TYPE_ID,
	  report_codes.REPORTING_CODE_CHAR_VALUE  REPORTING_CODE_CHAR_VALUE ,
	  report_codes.REPORTING_CODE_DATE_VALUE  REPORTING_CODE_DATE_VALUE,
 	  report_codes.REPORTING_CODE_NUM_VALUE   REPORTING_CODE_NUM_VALUE
    FROM
          AP_TAX_CODES_ALL codes,
          ZX_RATES_B       rates,
	  ZX_REPORTING_TYPES_B  reporting_types,
          ZX_REPORTING_CODES_B report_codes
    WHERE
             codes.tax_id                =  rates.tax_rate_id
    AND  codes.tax_id                    =  nvl(p_tax_id,codes.tax_id)
    AND  codes.global_attribute_category = 'JA.TW.APXTADTC.TAX_CODES'
    AND  codes.global_attribute1         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  reporting_types.reporting_type_code = 'TW_GOVERNMENT_TAX_TYPE'
    AND  reporting_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
    AND  reporting_types.reporting_type_id = report_codes.reporting_type_id
    AND  report_codes.record_type_code   = 'MIGRATED'

    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id   =
                           report_codes.reporting_type_id)
    --End of Bug# 4952838

    UNION ALL
/* Bug 4936036 : As reporting codes would not be created for reporting types PT_PRD_TAXABLE_BOX,
 PT_PRD_REC_TAX_BOX, PT_ANL_TTL_TAXABLE_BOX, PT_ANL_REC_TAXABLE, PT_ANL_NON_REC_TAXABLE,PT_ANL_REC_TAX_BOX */
  SELECT
          rates.TAX_RATE_ID                TAX_RATE_ID,
          null				   REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM      EFFECTIVE_FROM,
	  reporting_types.REPORTING_TYPE_ID   REPORTING_TYPE_ID,
	  codes.global_attribute2 REPORTING_CODE_CHAR_VALUE,
	  NULL REPORTING_CODE_DATE_VALUE,
	  NULL REPORTING_CODE_NUM_VALUE
    FROM
          AP_TAX_CODES_ALL codes,
          ZX_RATES_B       rates,
	  ZX_REPORTING_TYPES_B reporting_types
--          ZX_REPORTING_CODES_B report_codes
    WHERE
             codes.tax_id                    =  rates.tax_rate_id
    AND  codes.tax_id                    =  nvl(p_tax_id,codes.tax_id)
    AND  codes.global_attribute_category = 'JE.PT.APXTADTC.TAX_INFO'
    AND  codes.global_attribute2 IS NOT NULL
--    AND  codes.global_attribute2         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  reporting_types.reporting_type_code = 'PT_PRD_TAXABLE_BOX'
    AND  reporting_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
--    AND  reporting_types.reporting_type_id = report_codes.reporting_type_id
--    AND  report_codes.record_type_code   = 'MIGRATED'
    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id =
                           reporting_types.reporting_type_id)
    UNION ALL
    SELECT
          rates.TAX_RATE_ID                TAX_RATE_ID,
          null				   REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM      EFFECTIVE_FROM,
	  reporting_types.REPORTING_TYPE_ID   REPORTING_TYPE_ID,
	 codes.global_attribute3 REPORTING_CODE_CHAR_VALUE,
	 NULL REPORTING_CODE_DATE_VALUE,
	 NULL REPORTING_CODE_NUM_VALUE
    FROM
          AP_TAX_CODES_ALL codes,
          ZX_RATES_B       rates,
	  ZX_REPORTING_TYPES_B  reporting_types
--          ZX_REPORTING_CODES_B report_codes
    WHERE
             codes.tax_id                    =  rates.tax_rate_id
    AND  codes.tax_id                    =  nvl(p_tax_id,codes.tax_id)
    AND  codes.global_attribute_category = 'JE.PT.APXTADTC.TAX_INFO'
    AND  codes.global_attribute3 IS NOT NULL
--    AND  codes.global_attribute3         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  reporting_types.reporting_type_code = 'PT_PRD_REC_TAX_BOX'
    AND  reporting_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
--    AND  reporting_types.reporting_type_id = report_codes.reporting_type_id
--    AND  report_codes.record_type_code   = 'MIGRATED'

    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id =
                           reporting_types.reporting_type_id)
    UNION ALL
    SELECT
          rates.TAX_RATE_ID                TAX_RATE_ID,
          null				   REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM      EFFECTIVE_FROM,
	  reporting_types.REPORTING_TYPE_ID   REPORTING_TYPE_ID,
	  codes.global_attribute4 REPORTING_CODE_CHAR_VALUE,
	  NULL REPORTING_CODE_DATE_VALUE,
	  NULL REPORTING_CODE_NUM_VALUE
    FROM
          AP_TAX_CODES_ALL codes,
          ZX_RATES_B       rates,
	  ZX_REPORTING_TYPES_B  reporting_types
--          ZX_REPORTING_CODES_B report_codes
    WHERE
             codes.tax_id                    =  rates.tax_rate_id
    AND  codes.tax_id                    =  nvl(p_tax_id,codes.tax_id)
    AND  codes.global_attribute_category = 'JE.PT.APXTADTC.TAX_INFO'
    AND  codes.global_attribute4 IS NOT NULL
  --  AND  codes.global_attribute4         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  reporting_types.reporting_type_code = 'PT_ANL_TTL_TAXABLE_BOX'
    AND  reporting_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
--    AND  reporting_types.reporting_type_id = report_codes.reporting_type_id
--    AND  report_codes.record_type_code   = 'MIGRATED'

    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id =
                           reporting_types.reporting_type_id)
    UNION ALL
    SELECT
          rates.TAX_RATE_ID                TAX_RATE_ID,
          null				   REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM      EFFECTIVE_FROM,
	  reporting_types.REPORTING_TYPE_ID   REPORTING_TYPE_ID,
	  codes.global_attribute5 REPORTING_CODE_CHAR_VALUE,
	 NULL REPORTING_CODE_DATE_VALUE,
	 NULL REPORTING_CODE_NUM_VALUE
    FROM
          AP_TAX_CODES_ALL codes,
          ZX_RATES_B       rates,
	  ZX_REPORTING_TYPES_B reporting_types
--          ZX_REPORTING_CODES_B report_codes
    WHERE
             codes.tax_id                    =  rates.tax_rate_id
    AND  codes.tax_id                    =  nvl(p_tax_id,codes.tax_id)
    AND  codes.global_attribute_category = 'JE.PT.APXTADTC.TAX_INFO'
    AND  codes.global_attribute5 IS NOT NULL
--    AND  codes.global_attribute5         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  reporting_types.reporting_type_code = 'PT_ANL_REC_TAXABLE'
    AND  reporting_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
--    AND  reporting_types.reporting_type_id = report_codes.reporting_type_id
--    AND  report_codes.record_type_code   = 'MIGRATED'

    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id =
                           reporting_types.reporting_type_id)
    UNION ALL
    SELECT
          rates.TAX_RATE_ID                TAX_RATE_ID,
          null				   REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM      EFFECTIVE_FROM,
	  reporting_types.REPORTING_TYPE_ID   REPORTING_TYPE_ID,
	 codes.global_attribute6 REPORTING_CODE_CHAR_VALUE,
	 NULL REPORTING_CODE_DATE_VALUE,
	 NULL REPORTING_CODE_NUM_VALUE
    FROM
          AP_TAX_CODES_ALL codes,
          ZX_RATES_B       rates,
	  ZX_REPORTING_TYPES_B reporting_types
--          ZX_REPORTING_CODES_B report_codes
    WHERE

             codes.tax_id                    =  rates.tax_rate_id
    AND  codes.tax_id                    =  nvl(p_tax_id,codes.tax_id)
    AND  codes.global_attribute_category = 'JE.PT.APXTADTC.TAX_INFO'
    AND  codes.global_attribute6 IS NOT NULL
--    AND  codes.global_attribute6         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  reporting_types.reporting_type_code = 'PT_ANL_NON_REC_TAXABLE'
    AND  reporting_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
--    AND  reporting_types.reporting_type_id = report_codes.reporting_type_id
    AND  rates.record_type_code          = 'MIGRATED'

--    AND  report_codes.record_type_code   = 'MIGRATED'

    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id =
                           reporting_types.reporting_type_id)
    UNION ALL
    SELECT
          rates.TAX_RATE_ID                TAX_RATE_ID,
          null				   REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM      EFFECTIVE_FROM,
	  reporting_types.REPORTING_TYPE_ID   REPORTING_TYPE_ID,
	 codes.global_attribute7 REPORTING_CODE_CHAR_VALUE,
	 NULL REPORTING_CODE_DATE_VALUE,
	 NULL REPORTING_CODE_NUM_VALUE

    FROM
          AP_TAX_CODES_ALL codes,
          ZX_RATES_B       rates,
	  ZX_REPORTING_TYPES_B reporting_types
--          ZX_REPORTING_CODES_B report_codes
    WHERE
              codes.tax_id                    =  rates.tax_rate_id
     AND  codes.tax_id                    =  nvl(p_tax_id,codes.tax_id)
    AND   codes.global_attribute_category = 'JE.PT.APXTADTC.TAX_INFO'
    AND  codes.global_attribute7 IS NOT NULL
--    AND  codes.global_attribute7         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  reporting_types.reporting_type_code = 'PT_ANL_REC_TAX_BOX'
    AND  reporting_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
--    AND  reporting_types.reporting_type_id = report_codes.reporting_type_id
--    AND  report_codes.record_type_code   = 'MIGRATED'

    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id =
                           reporting_types.reporting_type_id));

   -- Bug # 3935161. Association for 'MEMBER STATE'
 IF L_MULTI_ORG_FLAG = 'Y'
 THEN
   INSERT INTO ZX_REPORT_CODES_ASSOC(
	REPORTING_CODE_ASSOC_ID,
	ENTITY_CODE,
	ENTITY_ID,
	REPORTING_TYPE_ID,
	REPORTING_CODE_ID,
	EXCEPTION_CODE,
	EFFECTIVE_FROM,
	EFFECTIVE_TO,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	OBJECT_VERSION_NUMBER) -- Bug 5031787
   (SELECT
	ZX_REPORT_CODES_ASSOC_S.nextval, --REPORTING_CODE_ASSOC_ID
	'ZX_PARTY_TAX_PROFILE',		 --ENTITY_CODE
	ptp.Party_Tax_Profile_Id,	 --ENTITY_ID
	codes.REPORTING_TYPE_ID       ,	 --REPORTING_TYPE_ID
	codes.REPORTING_CODE_ID,	 --REPORTING_CODE_ID
	null,				 --EXCEPTION_CODE
	codes.EFFECTIVE_FROM,		 --EFFECTIVE_FROM
	codes.EFFECTIVE_TO,		 --EFFECTIVE_TO
	fnd_global.user_id,
	sysdate,
	fnd_global.user_id,
	sysdate,
	fnd_global.conc_login_id,
	1  -- Bug 5031787
   FROM
	financials_system_params_all fin_sys_param,
	zx_reporting_types_b types,
	zx_reporting_codes_b codes,
	xle_etb_profiles  etb,
	zx_party_tax_profile ptp

   WHERE
	    types.reporting_type_id = codes.reporting_type_id
	AND types.reporting_type_code = 'MEMBER STATE'
        AND fin_sys_param.vat_country_code = codes.reporting_code_char_value
        AND etb.legal_entity_id = fin_sys_param.org_id -- Bug 5031787
        AND ptp.party_id = etb.party_id
	AND ptp.Party_Type_Code = 'LEGAL_ESTABLISHMENT'

	AND not exists(select 1 from ZX_REPORT_CODES_ASSOC
	    where  entity_code         = 'ZX_PARTY_TAX_PROFILE'
	    and    entity_id           = ptp.Party_Tax_Profile_Id
	    and    reporting_type_id   = types.reporting_type_id));
  ELSE
   INSERT INTO ZX_REPORT_CODES_ASSOC(
	REPORTING_CODE_ASSOC_ID,
	ENTITY_CODE,
	ENTITY_ID,
	REPORTING_TYPE_ID,
	REPORTING_CODE_ID,
	EXCEPTION_CODE,
	EFFECTIVE_FROM,
	EFFECTIVE_TO,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	OBJECT_VERSION_NUMBER) -- Bug 5031787
   (SELECT
	ZX_REPORT_CODES_ASSOC_S.nextval, --REPORTING_CODE_ASSOC_ID
	'ZX_PARTY_TAX_PROFILE',		 --ENTITY_CODE
	ptp.Party_Tax_Profile_Id,	 --ENTITY_ID
	codes.REPORTING_TYPE_ID       ,	 --REPORTING_TYPE_ID
	codes.REPORTING_CODE_ID,	 --REPORTING_CODE_ID
	null,				 --EXCEPTION_CODE
	codes.EFFECTIVE_FROM,		 --EFFECTIVE_FROM
	codes.EFFECTIVE_TO,		 --EFFECTIVE_TO
	fnd_global.user_id,
	sysdate,
	fnd_global.user_id,
	sysdate,
	fnd_global.conc_login_id,
	1  -- Bug 5031787
   FROM
	financials_system_params_all fin_sys_param,
	zx_reporting_types_b types,
	zx_reporting_codes_b codes,
	xle_etb_profiles  etb,
	zx_party_tax_profile ptp

   WHERE
	    types.reporting_type_id = codes.reporting_type_id
	AND types.reporting_type_code = 'MEMBER STATE'
        AND fin_sys_param.vat_country_code = codes.reporting_code_char_value
        AND etb.legal_entity_id = fin_sys_param.org_id --Bug 5031787
	AND etb.legal_entity_id = l_org_id
        AND ptp.party_id = etb.party_id
	AND ptp.Party_Type_Code = 'LEGAL_ESTABLISHMENT'

	AND not exists(select 1 from ZX_REPORT_CODES_ASSOC
	    where  entity_code         = 'ZX_PARTY_TAX_PROFILE'
	    and    entity_id           = ptp.Party_Tax_Profile_Id
	    and    reporting_type_id   = types.reporting_type_id));
END IF;



--Bug 3922583
INSERT
   INTO   ZX_REPORT_CODES_ASSOC(
          REPORTING_CODE_ASSOC_ID,
          ENTITY_CODE            ,
          ENTITY_ID              ,
          REPORTING_TYPE_ID      ,
          REPORTING_CODE_ID      ,
          EXCEPTION_CODE         ,
          EFFECTIVE_FROM         ,
          EFFECTIVE_TO           ,
          CREATED_BY             ,
          CREATION_DATE          ,
          LAST_UPDATED_BY        ,
          LAST_UPDATE_DATE       ,
          LAST_UPDATE_LOGIN      ,
          REPORTING_CODE_CHAR_VALUE,
          REPORTING_CODE_DATE_VALUE,
          REPORTING_CODE_NUM_VALUE,
	  OBJECT_VERSION_NUMBER
                                )
    SELECT
          ZX_REPORT_CODES_ASSOC_S.nextval  ,
         'ZX_RATES'                        ,--ENTITY_CODE
          rates.TAX_RATE_ID           ,--ENTITY_ID
          report_codes.REPORTING_TYPE_ID, --REPORTING_TYPE_ID
          report_codes.REPORTING_CODE_ID  ,--REPORTING_CODE_ID
          NULL                             ,--EXCEPTION_CODE
           rates.EFFECTIVE_FROM   ,
          NULL                             ,--EFFECTIVE_TO
          fnd_global.user_id               ,
          SYSDATE                          ,
          fnd_global.user_id               ,
          SYSDATE                          ,
          fnd_global.conc_login_id         ,
          report_codes.REPORTING_CODE_CHAR_VALUE,--REPORTING_CODE_CHAR_VALUE
          report_codes.REPORTING_CODE_DATE_VALUE,--REPORTING_CODE_DATE_VALUE
          report_codes.REPORTING_CODE_NUM_VALUE , --REPORTING_CODE_NUM_VALUE
	  1
   FROM
          AP_TAX_CODES_ALL codes,
          ZX_REPORTING_TYPES_B reporting_types,
          ZX_REPORTING_CODES_B report_codes,
          ZX_RATES_B       rates


    WHERE
         codes.tax_id                    =  rates.tax_rate_id
    AND  codes.tax_id                    =  nvl(p_tax_id,codes.tax_id)
    AND  codes.global_attribute_category = 'JL.CL.APXTADTC.AP_TAX_CODES'
    AND  codes.global_attribute19         =  report_codes.REPORTING_CODE_CHAR_VALUE --Bug 4928369
    AND  reporting_types.reporting_type_id = report_codes.reporting_type_id
    AND  reporting_types.reporting_type_code ='CL_TAX_CODE_CLASSIF'
    AND  reporting_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
    AND  report_codes.record_type_code   = 'MIGRATED'
    AND  rates.record_type_code          = 'MIGRATED'

    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id   =
                           report_codes.reporting_type_id);

 arp_util_tax.debug(' CREATE_ZX_REPORTING_ASSOC_AP(-)');

END CREATE_ZX_REPORTING_ASSOC_AP;



/* Used to create the reporting code association for AR */

PROCEDURE CREATE_ZX_REPORTING_ASSOC_AR(p_tax_id IN NUMBER)  IS
	l_status fnd_module_installations.status%TYPE;
	l_db_status fnd_module_installations.DB_STATUS%TYPE;

BEGIN

   /* Create the Reporting Code association*/
   --Association for Reporting Type Code PT_ANL_TAX_BOX
   arp_util_tax.debug('ZX_REPORTING_ASSOC_AR(+)');
   INSERT
   INTO   ZX_REPORT_CODES_ASSOC(
          REPORTING_CODE_ASSOC_ID,
          ENTITY_CODE            ,
          ENTITY_ID              ,
          REPORTING_TYPE_ID      ,
          REPORTING_CODE_ID      ,
          EXCEPTION_CODE         ,
          EFFECTIVE_FROM         ,
          EFFECTIVE_TO           ,
          CREATED_BY             ,
          CREATION_DATE          ,
          LAST_UPDATED_BY        ,
          LAST_UPDATE_DATE       ,
          LAST_UPDATE_LOGIN      ,
          REPORTING_CODE_CHAR_VALUE,
          REPORTING_CODE_DATE_VALUE,
          REPORTING_CODE_NUM_VALUE,
	  OBJECT_VERSION_NUMBER
                                )
    SELECT
          ZX_REPORT_CODES_ASSOC_S.nextval  ,
         'ZX_RATES'                        ,--ENTITY_CODE
          TAX_RATE_ID                      ,--ENTITY_ID
          REPORTING_TYPE_ID              ,
          REPORTING_CODE_ID                   ,
          NULL                             ,--EXCEPTION_CODE
          EFFECTIVE_FROM                   ,
          NULL                             ,--EFFECTIVE_TO
          fnd_global.user_id               ,
          SYSDATE                          ,
          fnd_global.user_id               ,
          SYSDATE                          ,
          fnd_global.conc_login_id         ,
          REPORTING_CODE_CHAR_VALUE,
          REPORTING_CODE_DATE_VALUE,
          REPORTING_CODE_NUM_VALUE,
	  1
    FROM
    (
    SELECT
          rates.TAX_RATE_ID                       TAX_RATE_ID,
          report_codes.REPORTING_CODE_ID          REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM             EFFECTIVE_FROM,
          report_codes.REPORTING_TYPE_ID          REPORTING_TYPE_ID,
          report_codes.REPORTING_CODE_CHAR_VALUE  REPORTING_CODE_CHAR_VALUE ,
          report_codes.REPORTING_CODE_DATE_VALUE  REPORTING_CODE_DATE_VALUE,
          report_codes.REPORTING_CODE_NUM_VALUE   REPORTING_CODE_NUM_VALUE
    FROM

          AR_VAT_TAX_ALL_B     codes,
          ZX_RATES_B     rates,
	  ZX_REPORTING_TYPES_B report_types,
          ZX_REPORTING_CODES_B report_codes

    WHERE

    	 codes.vat_tax_id                =  rates.tax_rate_id
    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
    AND  codes.global_attribute_category = 'JE.PT.ARXSUVAT.TAX_INFO'
    AND  codes.global_attribute1         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  report_types.reporting_type_id  = report_codes.reporting_type_id
    AND  report_types.REPORTING_TYPE_CODE= 'PT_LOCATION'
    AND  report_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
    AND  report_codes.record_type_code   = 'MIGRATED'


    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id   =
                           report_codes.reporting_type_id)

    --Bug# 4952838

    UNION ALL

    SELECT
          rates.TAX_RATE_ID                       TAX_RATE_ID,
          report_codes.REPORTING_CODE_ID          REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM             EFFECTIVE_FROM,
          report_codes.REPORTING_TYPE_ID          REPORTING_TYPE_ID,
          report_codes.REPORTING_CODE_CHAR_VALUE  REPORTING_CODE_CHAR_VALUE ,
          report_codes.REPORTING_CODE_DATE_VALUE  REPORTING_CODE_DATE_VALUE,
          report_codes.REPORTING_CODE_NUM_VALUE   REPORTING_CODE_NUM_VALUE
    FROM

          AR_VAT_TAX_ALL_B     codes,
          ZX_RATES_B     rates,
	  ZX_REPORTING_TYPES_B report_types,
          ZX_REPORTING_CODES_B report_codes

    WHERE

    	 codes.vat_tax_id                =  rates.tax_rate_id
    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
    AND  codes.global_attribute_category = 'JE.CZ.ARXSUVAT.TAX_ORIGIN'
    AND  codes.global_attribute1         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  report_types.reporting_type_id  = report_codes.reporting_type_id
    AND  report_types.REPORTING_TYPE_CODE= 'CZ_TAX_ORIGIN'
    AND  report_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
    AND  report_codes.record_type_code   = 'MIGRATED'

    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id   =
                           report_codes.reporting_type_id)

    UNION ALL

    SELECT
          rates.TAX_RATE_ID                       TAX_RATE_ID,
          report_codes.REPORTING_CODE_ID          REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM             EFFECTIVE_FROM,
          report_codes.REPORTING_TYPE_ID          REPORTING_TYPE_ID,
          report_codes.REPORTING_CODE_CHAR_VALUE  REPORTING_CODE_CHAR_VALUE ,
          report_codes.REPORTING_CODE_DATE_VALUE  REPORTING_CODE_DATE_VALUE,
          report_codes.REPORTING_CODE_NUM_VALUE   REPORTING_CODE_NUM_VALUE
    FROM

          AR_VAT_TAX_ALL_B     codes,
          ZX_RATES_B     rates,
	  ZX_REPORTING_TYPES_B report_types,
          ZX_REPORTING_CODES_B report_codes

    WHERE

    	 codes.vat_tax_id                =  rates.tax_rate_id
    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
    AND  codes.global_attribute_category = 'JE.HU.ARXSUVAT.TAX_ORIGIN'
    AND  codes.global_attribute1         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  report_types.reporting_type_id  = report_codes.reporting_type_id
    AND  report_types.REPORTING_TYPE_CODE= 'HU_TAX_ORIGIN'
    AND  report_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
    AND  report_codes.record_type_code   = 'MIGRATED'

    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id   =
                           report_codes.reporting_type_id)

    UNION ALL

    SELECT
          rates.TAX_RATE_ID                       TAX_RATE_ID,
          report_codes.REPORTING_CODE_ID          REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM             EFFECTIVE_FROM,
          report_codes.REPORTING_TYPE_ID          REPORTING_TYPE_ID,
          report_codes.REPORTING_CODE_CHAR_VALUE  REPORTING_CODE_CHAR_VALUE ,
          report_codes.REPORTING_CODE_DATE_VALUE  REPORTING_CODE_DATE_VALUE,
          report_codes.REPORTING_CODE_NUM_VALUE   REPORTING_CODE_NUM_VALUE
    FROM

          AR_VAT_TAX_ALL_B     codes,
          ZX_RATES_B     rates,
	  ZX_REPORTING_TYPES_B report_types,
          ZX_REPORTING_CODES_B report_codes

    WHERE

    	 codes.vat_tax_id                =  rates.tax_rate_id
    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
    AND  codes.global_attribute_category = 'JE.PL.ARXSUVAT.TAX_ORIGIN'
    AND  codes.global_attribute1         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  report_types.reporting_type_id  = report_codes.reporting_type_id
    AND  report_types.REPORTING_TYPE_CODE= 'PL_TAX_ORIGIN'
    AND  report_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
    AND  report_codes.record_type_code   = 'MIGRATED'

    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id   =
                           report_codes.reporting_type_id)

    UNION ALL

    SELECT
          rates.TAX_RATE_ID                       TAX_RATE_ID,
          report_codes.REPORTING_CODE_ID          REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM             EFFECTIVE_FROM,
          report_codes.REPORTING_TYPE_ID          REPORTING_TYPE_ID,
          report_codes.REPORTING_CODE_CHAR_VALUE  REPORTING_CODE_CHAR_VALUE ,
          report_codes.REPORTING_CODE_DATE_VALUE  REPORTING_CODE_DATE_VALUE,
          report_codes.REPORTING_CODE_NUM_VALUE   REPORTING_CODE_NUM_VALUE
    FROM

          AR_VAT_TAX_ALL_B     codes,
          ZX_RATES_B     rates,
	  ZX_REPORTING_TYPES_B report_types,
          ZX_REPORTING_CODES_B report_codes

    WHERE

    	 codes.vat_tax_id                =  rates.tax_rate_id
    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
    AND  codes.global_attribute_category = 'JA.TW.ARXSUVAT.VAT_TAX'
    AND  codes.global_attribute1         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  report_types.reporting_type_id  = report_codes.reporting_type_id
    AND  report_types.REPORTING_TYPE_CODE= 'TW_GOVERNMENT_TAX_TYPE'
    AND  report_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
    AND  report_codes.record_type_code   = 'MIGRATED'

    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id   =
                           report_codes.reporting_type_id)

    UNION ALL

    SELECT
         rates.TAX_RATE_ID                TAX_RATE_ID,
         null				   REPORTING_CODE_ID,
         rates.EFFECTIVE_FROM      EFFECTIVE_FROM,
	 report_types.REPORTING_TYPE_ID   REPORTING_TYPE_ID,
	 codes.global_attribute5 REPORTING_CODE_CHAR_VALUE,
	 NULL REPORTING_CODE_DATE_VALUE,
	 NULL REPORTING_CODE_NUM_VALUE

    FROM
          AR_VAT_TAX_ALL_B     codes,
          ZX_RATES_B     rates,
	  ZX_REPORTING_TYPES_B report_types
    WHERE
    	 codes.vat_tax_id                =  rates.tax_rate_id
    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
    AND  codes.global_attribute_category = 'JL.CL.ARXSUVAT.VAT_TAX'
    AND  rates.record_type_code          = 'MIGRATED'
    AND  report_types.REPORTING_TYPE_CODE= 'CL_DEBIT_ACCOUNT'
    AND  report_types.tax_regime_code = rates.tax_regime_code
    AND  codes.global_attribute5 IS NOT NULL

    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id =
                           report_types.reporting_type_id)

    --End of Bug# 4952838

    UNION ALL
/* Bug 4936036 : As reporting codes would not be created for reporting types PT_PRD_TAXABLE_BOX ,
 PT_PRD_REC_TAX_BOX, PT_ANL_TTL_TAXABLE_BOX, PT_ANL_REC_TAXABLE, PT_ANL_NON_REC_TAXABLE,PT_ANL_REC_TAX_BOX */
    SELECT
          rates.TAX_RATE_ID                TAX_RATE_ID,
          null				   REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM      EFFECTIVE_FROM,
	  report_types.REPORTING_TYPE_ID   REPORTING_TYPE_ID,
	 codes.global_attribute2 REPORTING_CODE_CHAR_VALUE,
	 NULL REPORTING_CODE_DATE_VALUE,
	 NULL REPORTING_CODE_NUM_VALUE

    FROM

          AR_VAT_TAX_ALL_B     codes,
          ZX_RATES_B     rates,
	  ZX_REPORTING_TYPES_B report_types
--          ZX_REPORTING_CODES_B report_codes

    WHERE

    	 codes.vat_tax_id                =  rates.tax_rate_id
    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
    AND  codes.global_attribute_category = 'JE.PT.ARXSUVAT.TAX_INFO'
    AND  codes.global_attribute2 IS NOT NULL
--    AND  codes.global_attribute2         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
--    AND  report_types.reporting_type_id  = report_codes.reporting_type_id
    AND  report_types.REPORTING_TYPE_CODE= 'PT_PRD_TAXABLE_BOX'
    AND  report_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
--    AND  report_codes.record_type_code   = 'MIGRATED'


    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id =
                           report_types.reporting_type_id)
    UNION ALL
    SELECT
          rates.TAX_RATE_ID                TAX_RATE_ID,
          null				   REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM      EFFECTIVE_FROM,
	  report_types.REPORTING_TYPE_ID   REPORTING_TYPE_ID,
	 codes.global_attribute3 REPORTING_CODE_CHAR_VALUE,
	 NULL REPORTING_CODE_DATE_VALUE,
	 NULL REPORTING_CODE_NUM_VALUE
    FROM

          AR_VAT_TAX_ALL_B     codes,
          ZX_RATES_B     rates,
	  ZX_REPORTING_TYPES_B report_types
--          ZX_REPORTING_CODES_B report_codes

    WHERE

    	 codes.vat_tax_id                =  rates.tax_rate_id
    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
    AND  codes.global_attribute_category = 'JE.PT.ARXSUVAT.TAX_INFO'
    AND  codes.global_attribute3 IS NOT NULL
  --  AND  codes.global_attribute3         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
--    AND  report_types.reporting_type_id  = report_codes.reporting_type_id
    AND  report_types.REPORTING_TYPE_CODE= 'PT_PRD_REC_TAX_BOX'
    AND  report_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
--    AND  report_codes.record_type_code   = 'MIGRATED'


    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id =
                           report_types.reporting_type_id)
    UNION ALL
    SELECT
          rates.TAX_RATE_ID                TAX_RATE_ID,
          null				   REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM      EFFECTIVE_FROM,
	  report_types.REPORTING_TYPE_ID   REPORTING_TYPE_ID,
	 codes.global_attribute4 REPORTING_CODE_CHAR_VALUE,
	 NULL REPORTING_CODE_DATE_VALUE,
	 NULL REPORTING_CODE_NUM_VALUE
    FROM

          AR_VAT_TAX_ALL_B     codes,
          ZX_RATES_B     rates,
	  ZX_REPORTING_TYPES_B report_types
--          ZX_REPORTING_CODES_B report_codes

    WHERE

    	 codes.vat_tax_id                =  rates.tax_rate_id
    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
    AND  codes.global_attribute_category = 'JE.PT.ARXSUVAT.TAX_INFO'
    AND  codes.global_attribute4 IS NOT NULL
--    AND  codes.global_attribute4         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
--    AND  report_types.reporting_type_id  = report_codes.reporting_type_id
    AND  report_types.REPORTING_TYPE_CODE= 'PT_ANL_TTL_TAXABLE_BOX'
    AND  report_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
--    AND  report_codes.record_type_code   = 'MIGRATED'


    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id =
                           report_types.reporting_type_id)
    UNION ALL
    SELECT

          rates.TAX_RATE_ID                TAX_RATE_ID,
          null				   REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM      EFFECTIVE_FROM,
	  report_types.REPORTING_TYPE_ID   REPORTING_TYPE_ID,
	 codes.global_attribute5 REPORTING_CODE_CHAR_VALUE,
	 NULL REPORTING_CODE_DATE_VALUE,
	 NULL REPORTING_CODE_NUM_VALUE

    FROM

          AR_VAT_TAX_ALL_B     codes,
          ZX_RATES_B     rates,
	  ZX_REPORTING_TYPES_B report_types
--          ZX_REPORTING_CODES_B report_codes

    WHERE

    	 codes.vat_tax_id                =  rates.tax_rate_id
    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
    AND  codes.global_attribute_category = 'JE.PT.ARXSUVAT.TAX_INFO'
    AND  codes.global_attribute5 IS NOT NULL
  --  AND  codes.global_attribute5         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
--    AND  report_types.reporting_type_id  = report_codes.reporting_type_id
    AND  report_types.REPORTING_TYPE_CODE= 'PT_ANL_REC_TAXABLE'
    AND  report_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
--    AND  report_codes.record_type_code   = 'MIGRATED'


    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id =
                           report_types.reporting_type_id)
    UNION ALL
    SELECT
          rates.TAX_RATE_ID                TAX_RATE_ID,
          null				   REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM      EFFECTIVE_FROM,
	  report_types.REPORTING_TYPE_ID   REPORTING_TYPE_ID,
	 codes.global_attribute6 REPORTING_CODE_CHAR_VALUE,
	 NULL REPORTING_CODE_DATE_VALUE,
	 NULL REPORTING_CODE_NUM_VALUE
    FROM

          AR_VAT_TAX_ALL_B     codes,
          ZX_RATES_B     rates,
	  ZX_REPORTING_TYPES_B report_types
--          ZX_REPORTING_CODES_B report_codes

    WHERE

    	 codes.vat_tax_id                =  rates.tax_rate_id
    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
    AND  codes.global_attribute_category = 'JE.PT.ARXSUVAT.TAX_INFO'
    AND  codes.global_attribute6 IS NOT NULL
--    AND  codes.global_attribute6         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
--    AND  report_types.reporting_type_id  = report_codes.reporting_type_id
    AND  report_types.REPORTING_TYPE_CODE= 'PT_ANL_NON_REC_TAXABLE'
    AND  report_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
--    AND  report_codes.record_type_code   = 'MIGRATED'


    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id =
                           report_types.reporting_type_id)
    UNION ALL
    SELECT
          rates.TAX_RATE_ID                TAX_RATE_ID,
          null				   REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM      EFFECTIVE_FROM,
	  report_types.REPORTING_TYPE_ID   REPORTING_TYPE_ID,
	 codes.global_attribute7 REPORTING_CODE_CHAR_VALUE,
	 NULL REPORTING_CODE_DATE_VALUE,
	 NULL REPORTING_CODE_NUM_VALUE

    FROM

          AR_VAT_TAX_ALL_B     codes,
          ZX_RATES_B     rates,
	  ZX_REPORTING_TYPES_B report_types
--          ZX_REPORTING_CODES_B report_codes

    WHERE

    	 codes.vat_tax_id                =  rates.tax_rate_id
    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
    AND  codes.global_attribute_category = 'JE.PT.ARXSUVAT.TAX_INFO'
    AND  codes.global_attribute7 IS NOT NULL
--    AND  codes.global_attribute7         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
--    AND  report_types.reporting_type_id  = report_codes.reporting_type_id
    AND  report_types.REPORTING_TYPE_CODE= 'PT_ANL_REC_TAX_BOX'
    AND  report_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
--    AND  report_codes.record_type_code   = 'MIGRATED'

    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id =
                           report_types.reporting_type_id)
    UNION ALL
    -- For DGI Transaction Code
    SELECT
          rates.TAX_RATE_ID                TAX_RATE_ID,
          report_codes.REPORTING_CODE_ID   REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM      EFFECTIVE_FROM,
          report_codes.REPORTING_TYPE_ID REPORTING_TYPE_ID,
          report_codes.REPORTING_CODE_CHAR_VALUE,
          report_codes.REPORTING_CODE_DATE_VALUE,
          report_codes.REPORTING_CODE_NUM_VALUE

    FROM

          AR_VAT_TAX_ALL_B  codes,
          ZX_RATES_B       rates,
	  ZX_REPORTING_TYPES_B report_types,
          ZX_REPORTING_CODES_B report_codes

    WHERE

         codes.vat_tax_id                =  rates.tax_rate_id
    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
    AND  codes.global_attribute_category = 'JL.AR.ARXSUVAT.AR_VAT_TAX'
    AND  codes.global_attribute4         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  report_types.reporting_type_id  = report_codes.reporting_type_id
    AND  report_types.REPORTING_TYPE_CODE= 'AR_DGI_TRX_CODE'
    AND  report_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
    AND  report_codes.record_type_code   = 'MIGRATED'


    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id =
                           report_codes.reporting_type_id)

    UNION ALL
    -- For Turnover Jurisdiction Code
    SELECT
          rates.TAX_RATE_ID                TAX_RATE_ID,
          report_codes.REPORTING_CODE_ID   REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM      EFFECTIVE_FROM,
          report_codes.REPORTING_TYPE_ID REPORTING_TYPE_ID,
          report_codes.REPORTING_CODE_CHAR_VALUE,
          report_codes.REPORTING_CODE_DATE_VALUE,
          report_codes.REPORTING_CODE_NUM_VALUE

    FROM

          AR_VAT_TAX_ALL_B  codes,
          ZX_RATES_B       rates,
	  ZX_REPORTING_TYPES_B report_types,
          ZX_REPORTING_CODES_B report_codes

    WHERE

         codes.vat_tax_id                =  rates.tax_rate_id
    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
    AND  codes.global_attribute_category = 'JL.AR.ARXSUVAT.AR_VAT_TAX'
    AND  codes.global_attribute5         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  report_types.reporting_type_id  = report_codes.reporting_type_id
    AND  report_types.REPORTING_TYPE_CODE= 'AR_TURN_OVER_JUR_CODE'
    AND  report_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
    AND  report_codes.record_type_code   = 'MIGRATED'


    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id =
                           report_codes.reporting_type_id)

    UNION ALL
    -- For Municipal Jurisdiction
    SELECT
          rates.TAX_RATE_ID                TAX_RATE_ID,
          report_codes.REPORTING_CODE_ID   REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM      EFFECTIVE_FROM,
          report_codes.REPORTING_TYPE_ID REPORTING_TYPE_ID,
          report_codes.REPORTING_CODE_CHAR_VALUE,
          report_codes.REPORTING_CODE_DATE_VALUE,
          report_codes.REPORTING_CODE_NUM_VALUE

    FROM

          AR_VAT_TAX_ALL_B  codes,
          ZX_RATES_B       rates,
	  ZX_REPORTING_TYPES_B report_types,
          ZX_REPORTING_CODES_B report_codes

    WHERE

         codes.vat_tax_id                =  rates.tax_rate_id
    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
    AND  codes.global_attribute_category = 'JL.AR.ARXSUVAT.AR_VAT_TAX'
    AND  codes.global_attribute6         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  report_types.reporting_type_id  = report_codes.reporting_type_id
    AND  report_types.REPORTING_TYPE_CODE= 'AR_MUNICIPAL_JUR'
    AND  report_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
    AND  report_codes.record_type_code   = 'MIGRATED'


    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id =
                           report_codes.reporting_type_id)

   UNION ALL
   -- For Tax Code Classification
    SELECT
          rates.TAX_RATE_ID                TAX_RATE_ID,
          report_codes.REPORTING_CODE_ID   REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM      EFFECTIVE_FROM,
          report_codes.REPORTING_TYPE_ID REPORTING_TYPE_ID,
          report_codes.REPORTING_CODE_CHAR_VALUE,
          report_codes.REPORTING_CODE_DATE_VALUE,
          report_codes.REPORTING_CODE_NUM_VALUE

    FROM

          AR_VAT_TAX_ALL_B codes,
          ZX_RATES_B       rates,
	  ZX_REPORTING_TYPES_B report_types,
          ZX_REPORTING_CODES_B report_codes

    WHERE

         codes.vat_tax_id                =  rates.tax_rate_id
    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
    AND  codes.global_attribute_category = 'JL.CL.ARXSUVAT.VAT_TAX'
    AND  codes.global_attribute4         =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  report_types.reporting_type_id  = report_codes.reporting_type_id
    AND  report_types.REPORTING_TYPE_CODE= 'CL_TAX_CODE_CLASSIF'
    AND  report_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
    AND  report_codes.record_type_code   = 'MIGRATED'


    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id =
                           report_codes.reporting_type_id)

    UNION ALL
   -- For Adjustment Tax Codes Bug Fix 4466085
    SELECT
          rates.TAX_RATE_ID                TAX_RATE_ID,
          report_codes.REPORTING_CODE_ID   REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM      EFFECTIVE_FROM,
          report_codes.REPORTING_TYPE_ID REPORTING_TYPE_ID,
          report_codes.REPORTING_CODE_CHAR_VALUE,
          report_codes.REPORTING_CODE_DATE_VALUE,
          report_codes.REPORTING_CODE_NUM_VALUE

    FROM

          AR_VAT_TAX_ALL_B codes,
          ZX_RATES_B       rates,
	  ZX_REPORTING_TYPES_B report_types,
          ZX_REPORTING_CODES_B report_codes

    WHERE

         codes.vat_tax_id                =  rates.tax_rate_id
    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
    AND  rates.record_type_code          = 'MIGRATED'
    AND  codes.adjustment_tax_code       = report_codes.reporting_code_char_value
    AND  rates.tax_regime_code           = report_types.tax_regime_code
    AND  report_types.reporting_type_id  = report_codes.reporting_type_id
    AND  report_types.REPORTING_TYPE_CODE= 'ZX_ADJ_TAX_CLASSIF_CODE'
    AND  report_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
    AND  report_codes.record_type_code   = 'MIGRATED'


    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id =
                           report_codes.reporting_type_id)
    );
   --Bug 4705196
   /*
    UNION ALL
   -- For Printed Tax Rate Names [Base Bug 4422813] [Main bug 4653456]
       SELECT
          rates.TAX_RATE_ID                TAX_RATE_ID,
          report_codes.REPORTING_CODE_ID   REPORTING_CODE_ID,
          report_codes.EFFECTIVE_FROM      EFFECTIVE_FROM,
          report_codes.REPORTING_TYPE_ID   REPORTING_TYPE_ID,
          report_codes.REPORTING_CODE_CHAR_VALUE,
          report_codes.REPORTING_CODE_DATE_VALUE,
          report_codes.REPORTING_CODE_NUM_VALUE
    FROM
          AR_VAT_TAX_ALL_TL codes,
          ZX_RATES_B       rates,
	  ZX_REPORTING_TYPES_B report_types,
          ZX_REPORTING_CODES_B report_codes

    WHERE

         codes.vat_tax_id                =  Nvl(rates.source_id,rates.tax_rate_id)
    AND  rates.record_type_code          = 'MIGRATED'
    AND  report_types.tax_regime_code    = rates.tax_regime_code
    AND  codes.printed_tax_name          = report_codes.REPORTING_CODE_CHAR_VALUE
    AND  codes.LANGUAGE                  = (select nvl(language_code,'US')  from FND_LANGUAGES where installed_flag = 'B' )
    AND  report_types.reporting_type_id  = report_codes.reporting_type_id
    AND  report_types.REPORTING_TYPE_CODE= 'PRINTED_TAX_RATE_NAME'
    AND  report_codes.record_type_code   = 'MIGRATED'


    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id =
                           report_codes.reporting_type_id)
    );*/

   -- To handle 'YES_NO' DataType - Reporting Type Codes

   INSERT
   INTO   ZX_REPORT_CODES_ASSOC(
          REPORTING_CODE_ASSOC_ID,
          ENTITY_CODE            ,
          ENTITY_ID              ,
          REPORTING_TYPE_ID      ,
          REPORTING_CODE_ID      ,
          EXCEPTION_CODE         ,
          EFFECTIVE_FROM         ,
          EFFECTIVE_TO           ,
          CREATED_BY             ,
          CREATION_DATE          ,
          LAST_UPDATED_BY        ,
          LAST_UPDATE_DATE       ,
          LAST_UPDATE_LOGIN      ,
          REPORTING_CODE_CHAR_VALUE,
          REPORTING_CODE_DATE_VALUE,
          REPORTING_CODE_NUM_VALUE,
	  OBJECT_VERSION_NUMBER
    )
    SELECT
          ZX_REPORT_CODES_ASSOC_S.nextval  ,
         'ZX_RATES'                        ,--ENTITY_CODE
          TAX_RATE_ID                      ,--ENTITY_ID
          REPORTING_TYPE_ID              ,
          NULL				   ,--REPORTING_CODE_ID
          NULL                             ,--EXCEPTION_CODE
          EFFECTIVE_FROM                   ,
          NULL                             ,--EFFECTIVE_TO
          fnd_global.user_id               ,
          SYSDATE                          ,
          fnd_global.user_id               ,
          SYSDATE                          ,
          fnd_global.conc_login_id         ,
          REPORTING_CODE_CHAR_VALUE	   ,
          NULL,
          NULL,
	  1
    FROM
    (
    	    --Bills of Exchange Tax

	    SELECT TAX_RATE_ID,
		   REPORTING_TYPE_ID,
		   rates.EFFECTIVE_FROM,
		   codes.global_attribute6 REPORTING_CODE_CHAR_VALUE
	    FROM
	          ZX_REPORTING_TYPES_B report_types,
		  AR_VAT_TAX_ALL_B  codes,
		  ZX_RATES_B       rates

	    WHERE
	             report_types.reporting_type_code= 'CL_BILLS_OF_EXCH_TAX'
            AND  report_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
	    AND  codes.vat_tax_id                =  rates.tax_rate_id
	    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
	    AND  codes.global_attribute_category = 'JL.CL.ARXSUVAT.VAT_TAX'
	    AND  rates.record_type_code          = 'MIGRATED'
            AND  codes.global_attribute6 IS NOT NULL

	    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
			    where  entity_code         = 'ZX_RATES'
			    and    entity_id           = rates.tax_rate_id
			    and    reporting_type_id   =
				   report_types.reporting_type_id)
	  UNION ALL

    	    --Municipal Jurisdiction

	    SELECT TAX_RATE_ID,
		   REPORTING_TYPE_ID,
		   rates.EFFECTIVE_FROM,
		   codes.global_attribute6 REPORTING_CODE_CHAR_VALUE
	    FROM
	          ZX_REPORTING_TYPES_B report_types,
		  AR_VAT_TAX_ALL_B codes,
		  ZX_RATES_B       rates

	    WHERE
	         report_types.reporting_type_code= 'AR_MUNICIPAL_JUR'
            AND  report_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
	    AND  codes.vat_tax_id                =  rates.tax_rate_id
            AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
	    AND  codes.global_attribute_category = 'JL.AR.ARXSUVAT.AR_VAT_TAX'
	    AND  rates.record_type_code          = 'MIGRATED'
            AND  codes.global_attribute6 IS NOT NULL

	    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
			    where  entity_code         = 'ZX_RATES'
			    and    entity_id           = rates.tax_rate_id
			    and    reporting_type_id   =
				   report_types.reporting_type_id)

	  UNION ALL

	    --Print Tax Line for JL.AR.ARXSUVAT.AR_VAT_TAX context

	    SELECT TAX_RATE_ID,
		   REPORTING_TYPE_ID,
		   rates.EFFECTIVE_FROM,
		   codes.global_attribute2 REPORTING_CODE_CHAR_VALUE
	    FROM
	    	  ZX_REPORTING_TYPES_B report_types,
		  AR_VAT_TAX_ALL_B codes,
		  ZX_RATES_B       rates

	    WHERE
	         report_types.reporting_type_code= 'PRINT TAX LINE'
            AND  report_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
	    AND  codes.vat_tax_id                =  rates.tax_rate_id
            AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
	    AND  codes.global_attribute_category = 'JL.AR.ARXSUVAT.AR_VAT_TAX'
	    AND  rates.record_type_code          = 'MIGRATED'
            AND  codes.global_attribute2 IS NOT NULL


	    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
			    where  entity_code         = 'ZX_RATES'
			    and    entity_id           = rates.tax_rate_id
			    and    reporting_type_id   =
				   report_types.reporting_type_id)
	  UNION ALL

	    --Print Tax Line for JL.BR.ARXSUVAT.Tax Information context

	    SELECT TAX_RATE_ID,
		   REPORTING_TYPE_ID,
		   rates.EFFECTIVE_FROM,
		   codes.global_attribute2 REPORTING_CODE_CHAR_VALUE
	    FROM
	          ZX_REPORTING_TYPES_B report_types,
		  AR_VAT_TAX_ALL_B codes,
		  ZX_RATES_B       rates

	    WHERE
	         report_types.reporting_type_code= 'PRINT TAX LINE'
            AND  report_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
	    AND  codes.vat_tax_id                =  rates.tax_rate_id
	    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
	    AND  codes.global_attribute_category = 'JL.BR.ARXSUVAT.Tax Information'
	    AND  rates.record_type_code          = 'MIGRATED'
            AND  codes.global_attribute2 IS NOT NULL


	    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
			    where  entity_code         = 'ZX_RATES'
			    and    entity_id           = rates.tax_rate_id
			    and    reporting_type_id   =
				   report_types.reporting_type_id)

	  UNION ALL

	    --Print Tax Line for JL.CO.ARXSUVAT.AR_VAT_TAX context

	    SELECT TAX_RATE_ID,
		   REPORTING_TYPE_ID,
		   rates.EFFECTIVE_FROM,
		   codes.global_attribute2 REPORTING_CODE_CHAR_VALUE
	    FROM
	    	  ZX_REPORTING_TYPES_B report_types,
		  AR_VAT_TAX_ALL_B codes,
		  ZX_RATES_B       rates

	    WHERE
	         report_types.reporting_type_code= 'PRINT TAX LINE'
            AND  report_types.tax_regime_code = rates.tax_regime_code --Bug 4928369
	    AND  codes.vat_tax_id                =  rates.tax_rate_id
	    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
	    AND  codes.global_attribute_category = 'JL.CO.ARXSUVAT.AR_VAT_TAX'
	    AND  rates.record_type_code          = 'MIGRATED'
            AND  codes.global_attribute2 IS NOT NULL

	    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
			    where  entity_code         = 'ZX_RATES'
			    and    entity_id           = rates.tax_rate_id
			    and    reporting_type_id   =
				   report_types.reporting_type_id)

	);

        -- YK:9/22/2004: Korean GDF
   INSERT
   INTO   ZX_REPORT_CODES_ASSOC(
          REPORTING_CODE_ASSOC_ID,
          ENTITY_CODE            ,
          ENTITY_ID              ,
          REPORTING_TYPE_ID      ,
          REPORTING_CODE_CHAR_VALUE,
          REPORTING_CODE_DATE_VALUE,
          REPORTING_CODE_NUM_VALUE,
          EXCEPTION_CODE         ,
          EFFECTIVE_FROM         ,
          EFFECTIVE_TO           ,
          CREATED_BY             ,
          CREATION_DATE          ,
          LAST_UPDATED_BY        ,
          LAST_UPDATE_DATE       ,
          LAST_UPDATE_LOGIN	 ,
	  OBJECT_VERSION_NUMBER
          )
    SELECT
          ZX_REPORT_CODES_ASSOC_S.nextval  ,
         'ZX_RATES'                        ,--ENTITY_CODE
          TAX_RATE_ID                      ,--ENTITY_ID
          REPORTING_TYPE_ID                ,--REPORTING_TYPE_ID
          REPORTING_CODE_CHAR_VALUE        ,--REPORTING_CODE_CHAR_VALUE
          NULL                             ,--REPORTING_CODE_DATE_VALUE
          NULL                             ,--REPORTING_CODE_NUM_VALUE
          NULL                             ,--EXCEPTION_CODE
          EFFECTIVE_FROM                   ,
          NULL                             ,--EFFECTIVE_TO
          fnd_global.user_id               ,
          SYSDATE                          ,
          fnd_global.user_id               ,
          SYSDATE                          ,
          fnd_global.conc_login_id	   ,
	  1
    FROM
    (
	 SELECT   rates.TAX_RATE_ID                       TAX_RATE_ID,
		  report_codes.REPORTING_TYPE_ID          REPORTING_TYPE_ID,
		  report_codes.REPORTING_CODE_CHAR_VALUE  REPORTING_CODE_CHAR_VALUE,
		  rates.EFFECTIVE_FROM             EFFECTIVE_FROM
	    FROM
		  AR_VAT_TAX_ALL_B codes,
		  ZX_RATES_B       rates,
		  ZX_REPORTING_CODES_B report_codes,
		  hr_locations loc
	    WHERE
		 codes.global_attribute_category = 'JA.KR.ARXSUVAT.VAT'
	    AND codes.vat_tax_id  =  rates.tax_rate_id
	    and loc.location_id = codes.global_attribute1
	    AND  report_codes.reporting_code_char_value  = loc.location_code
	    AND  report_codes.record_type_code   = 'MIGRATED'
	    AND  rates.record_type_code          = 'MIGRATED'
	    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
	    AND  not exists( select 1 from ZX_REPORT_CODES_ASSOC
			    where  entity_code         = 'ZX_RATES'
			    and    entity_id           = rates.tax_rate_id
			    and    reporting_type_id = report_codes.reporting_type_id)
   );





   arp_util_tax.debug(' CREATE_ZX_REPORTING_ASSOC_AR(-)');
END CREATE_ZX_REPORTING_ASSOC_AR;


/* Used to create the reporting type and code for AP */

PROCEDURE CREATE_ZX_REP_TYPE_CODES_AP(p_tax_id IN NUMBER ) IS
BEGIN

    IF PG_DEBUG = 'Y' THEN
	arp_util_tax.debug('CREATE_ZX_REP_TYPE_CODES_AP(+)');
    END IF;

    INSERT ALL
    WHEN   (NOT EXISTS (select 1 from zx_reporting_types_b
                        where  reporting_type_code='PT_LOCATION'
                        and    tax_regime_code = l_tax_regime_code)
           ) THEN
    INTO   ZX_REPORTING_TYPES_B(
           REPORTING_TYPE_ID              ,
	   REPORTING_TYPE_CODE            ,
   	   REPORTING_TYPE_DATATYPE_CODE   ,
   	   TAX_REGIME_CODE                ,
	   TAX                            ,
	   FORMAT_MASK                    ,
	   MIN_LENGTH                     ,
	   MAX_LENGTH                     ,
	   LEGAL_MESSAGE_FLAG             ,
	   EFFECTIVE_FROM                 ,
	   EFFECTIVE_TO                   ,
	   RECORD_TYPE_CODE               ,
         --BugFix 3566148
           HAS_REPORTING_CODES_FLAG       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID		  ,
	   OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_migrate_util.get_next_seqid('zx_reporting_types_b_s'),--REPORTING_TYPE_ID
          'PT_LOCATION'                   			   ,--REPORTING_TYPE_CODE
          'TEXT'                          ,--REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                              ,--MIN_LENGTH
           30                             ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
          'Y'                             ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       , -- Program Login ID
	   1
          )
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code='PT_PRD_TAXABLE_BOX'
                       and    tax_regime_code = l_tax_regime_code)
          ) THEN
    INTO   ZX_REPORTING_TYPES_B(
           REPORTING_TYPE_ID              ,
           REPORTING_TYPE_CODE            ,
           REPORTING_TYPE_DATATYPE_CODE   ,
           TAX_REGIME_CODE                ,
           TAX                            ,
           FORMAT_MASK                    ,
           MIN_LENGTH                     ,
           MAX_LENGTH                     ,
           LEGAL_MESSAGE_FLAG             ,
           EFFECTIVE_FROM                 ,
           EFFECTIVE_TO                   ,
           RECORD_TYPE_CODE               ,
         --BugFix 3566148
           HAS_REPORTING_CODES_FLAG       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID		  ,
	   OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_migrate_util.get_next_seqid('zx_reporting_types_b_s') ,--REPORTING_TYPE_ID
          'PT_PRD_TAXABLE_BOX'            			    ,--REPORTING_TYPE_CODE
          'TEXT'                          ,--REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                              ,--MIN_LENGTH
           30                             ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
          'N'                             ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       ,-- Program Login ID
	   1
          )
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code='PT_PRD_REC_TAX_BOX'
                       and    tax_regime_code = l_tax_regime_code)
          ) THEN
    INTO   ZX_REPORTING_TYPES_B(
           REPORTING_TYPE_ID              ,
           REPORTING_TYPE_CODE            ,
           REPORTING_TYPE_DATATYPE_CODE   ,
           TAX_REGIME_CODE                ,
           TAX                            ,
           FORMAT_MASK                    ,
           MIN_LENGTH                     ,
           MAX_LENGTH                     ,
           LEGAL_MESSAGE_FLAG             ,
           EFFECTIVE_FROM                 ,
           EFFECTIVE_TO                   ,
           RECORD_TYPE_CODE               ,
         --BugFix 3566148
           HAS_REPORTING_CODES_FLAG       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID		  ,
	   OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_migrate_util.get_next_seqid('zx_reporting_types_b_s'),--REPORTING_TYPE_ID
          'PT_PRD_REC_TAX_BOX'            			   ,--REPORTING_TYPE_CODE
          'TEXT'                          ,--REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                           ,--MIN_LENGTH
           30                             ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
          'N'                             ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       , -- Program Login ID
	   1
          )
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code='PT_ANL_TTL_TAXABLE_BOX'
                       and    tax_regime_code = l_tax_regime_code)
          ) THEN
    INTO   ZX_REPORTING_TYPES_B(
           REPORTING_TYPE_ID              ,
           REPORTING_TYPE_CODE            ,
           REPORTING_TYPE_DATATYPE_CODE   ,
           TAX_REGIME_CODE                ,
           TAX                            ,
           FORMAT_MASK                    ,
           MIN_LENGTH                     ,
           MAX_LENGTH                     ,
           LEGAL_MESSAGE_FLAG             ,
           EFFECTIVE_FROM                 ,
           EFFECTIVE_TO                   ,
           RECORD_TYPE_CODE               ,
         --BugFix 3566148
           HAS_REPORTING_CODES_FLAG       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID		  ,
	   OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_migrate_util.get_next_seqid('zx_reporting_types_b_s'),--REPORTING_TYPE_ID
          'PT_ANL_TTL_TAXABLE_BOX'                                 ,--REPORTING_TYPE_CODE
          'TEXT'                          ,--REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                              ,--MIN_LENGTH
           30                             ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
          'N'                             ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       , -- Program Login ID
	   1
          )
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code='PT_ANL_REC_TAXABLE'
                       and    tax_regime_code = l_tax_regime_code)
          ) THEN
    INTO   ZX_REPORTING_TYPES_B(
           REPORTING_TYPE_ID              ,
           REPORTING_TYPE_CODE            ,
           REPORTING_TYPE_DATATYPE_CODE   ,
           TAX_REGIME_CODE                ,
           TAX                            ,
           FORMAT_MASK                    ,
           MIN_LENGTH                     ,
           MAX_LENGTH                     ,
           LEGAL_MESSAGE_FLAG             ,
           EFFECTIVE_FROM                 ,
           EFFECTIVE_TO                   ,
           RECORD_TYPE_CODE               ,
         --BugFix 3566148
           HAS_REPORTING_CODES_FLAG       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID		  ,
	   OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_migrate_util.get_next_seqid('zx_reporting_types_b_s'),--REPORTING_TYPE_ID
          'PT_ANL_REC_TAXABLE'            			   ,--REPORTING_TYPE_CODE
          'TEXT'                          ,--REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                              ,--MIN_LENGTH
           30                             ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
          'N'                             ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       , -- Program Login ID
	   1
          )
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code='PT_ANL_NON_REC_TAXABLE'
                       and    tax_regime_code = l_tax_regime_code)
          ) THEN
    INTO   ZX_REPORTING_TYPES_B(
           REPORTING_TYPE_ID              ,
           REPORTING_TYPE_CODE            ,
           REPORTING_TYPE_DATATYPE_CODE   ,
           TAX_REGIME_CODE                ,
           TAX                            ,
           FORMAT_MASK                    ,
           MIN_LENGTH                     ,
           MAX_LENGTH                     ,
           LEGAL_MESSAGE_FLAG             ,
           EFFECTIVE_FROM                 ,
           EFFECTIVE_TO                   ,
           RECORD_TYPE_CODE               ,
         --BugFix 3566148
           HAS_REPORTING_CODES_FLAG       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID		  ,
	   OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_migrate_util.get_next_seqid('zx_reporting_types_b_s'),--REPORTING_TYPE_ID
          'PT_ANL_NON_REC_TAXABLE'        			   ,--REPORTING_TYPE_CODE
          'TEXT'                          ,--REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                              ,--MIN_LENGTH
           30                             ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
          'N'                             ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       , -- Program Login ID
	   1
          )
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code='PT_ANL_REC_TAX_BOX'
                       and    tax_regime_code = l_tax_regime_code)
          ) THEN
    INTO   ZX_REPORTING_TYPES_B(
           REPORTING_TYPE_ID              ,
           REPORTING_TYPE_CODE            ,
           REPORTING_TYPE_DATATYPE_CODE   ,
           TAX_REGIME_CODE                ,
           TAX                            ,
           FORMAT_MASK                    ,
           MIN_LENGTH                     ,
           MAX_LENGTH                     ,
           LEGAL_MESSAGE_FLAG             ,
           EFFECTIVE_FROM                 ,
           EFFECTIVE_TO                   ,
           RECORD_TYPE_CODE               ,
         --BugFix 3566148
           HAS_REPORTING_CODES_FLAG       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID		  ,
	   OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_migrate_util.get_next_seqid('zx_reporting_types_b_s'),--REPORTING_TYPE_ID
          'PT_ANL_REC_TAX_BOX'            			   ,--REPORTING_TYPE_CODE
          'TEXT'                          ,--REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                              ,--MIN_LENGTH
           30                             ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
          'N'                             ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       , -- Program Login ID
	   1
          )
    SELECT
           min(zx_rates.effective_from) effective_from,
           zx_rates.tax_regime_code  l_tax_regime_code
    FROM
        ap_tax_codes_all codes,
        zx_rates_b zx_rates
    WHERE
         codes.tax_id                    = zx_rates.tax_rate_id
    AND  codes.tax_id                    = nvl(p_tax_id,codes.tax_id)
    AND  codes.global_attribute_category = 'JE.PT.APXTADTC.TAX_INFO'
    AND  zx_rates.record_type_code       = 'MIGRATED'

    GROUP BY
            zx_rates.tax_regime_code;


    --BugFix 3557652 REPORTING TYPES IMPL FOR ARGENTINE DGI TRANSACTION CODE
    CREATE_REPORTING_TYPE_AP('AR_DGI_TRX_CODE','TEXT','Y', 'JL.AR.APXTADTC.VAT', p_tax_id);

    /*
    INSERT ALL
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code='AR_DGI_TRX_CODE'
                       and    tax_regime_code = l_tax_regime_code)
          ) THEN
    INTO   ZX_REPORTING_TYPES_B(
           REPORTING_TYPE_ID              ,
	   REPORTING_TYPE_CODE            ,
   	   REPORTING_TYPE_DATATYPE_CODE   ,
   	   TAX_REGIME_CODE                ,
	   TAX                            ,
	   FORMAT_MASK                    ,
	   MIN_LENGTH                     ,
	   MAX_LENGTH                     ,
	   LEGAL_MESSAGE_FLAG             ,
	   EFFECTIVE_FROM                 ,
	   EFFECTIVE_TO                   ,
	   RECORD_TYPE_CODE               ,
           HAS_REPORTING_CODES_FLAG       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID		  ,
	   OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_reporting_types_b_s.nextval ,--REPORTING_TYPE_ID
          'AR_DGI_TRX_CODE'               ,--REPORTING_TYPE_CODE
          'TEXT'                          ,--REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                              ,--MIN_LENGTH
           30                             ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
          'Y'                             ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       , -- Program Login ID
	   1
          )
    SELECT
	   min(zx_rates.effective_from) effective_from,
	   zx_rates.tax_regime_code  l_tax_regime_code
    FROM
	   ap_tax_codes_all codes,
  	   zx_rates_b zx_rates
    WHERE
 	        codes.tax_id                         = zx_rates.tax_rate_id
	   AND  codes.tax_id                    = nvl(p_tax_id,codes.tax_id)
	   AND  codes.global_attribute_category = 'JL.AR.APXTADTC.VAT'
	   AND  zx_rates.record_type_code       = 'MIGRATED'

	   GROUP BY
	        zx_rates.tax_regime_code;
    */

    CREATE_REPORTING_TYPE_AP('CL_TAX_CODE_CLASSIF','TEXT','Y', 'JL.CL.APXTADTC.AP_TAX_CODES', p_tax_id);

    --Bug Fix : 4928369
    /*
    INSERT ALL
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code='CL_TAX_CODE_CLASSIF'
                       and    tax_regime_code = l_tax_regime_code)
          ) THEN
    INTO   ZX_REPORTING_TYPES_B(
           REPORTING_TYPE_ID              ,
	   REPORTING_TYPE_CODE            ,
   	   REPORTING_TYPE_DATATYPE_CODE   ,
   	   TAX_REGIME_CODE                ,
	   TAX                            ,
	   FORMAT_MASK                    ,
	   MIN_LENGTH                     ,
	   MAX_LENGTH                     ,
	   LEGAL_MESSAGE_FLAG             ,
	   EFFECTIVE_FROM                 ,
	   EFFECTIVE_TO                   ,
	   RECORD_TYPE_CODE               ,
           HAS_REPORTING_CODES_FLAG       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID		  ,
	   OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_reporting_types_b_s.nextval ,--REPORTING_TYPE_ID
          'CL_TAX_CODE_CLASSIF'               ,--REPORTING_TYPE_CODE
          'TEXT'                          ,--REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                              ,--MIN_LENGTH
           30                             ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
          'Y'                             ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       , -- Program Login ID
	   1
          )
    SELECT
	   min(zx_rates.effective_from) effective_from,
	   zx_rates.tax_regime_code  l_tax_regime_code
    FROM
	   ap_tax_codes_all codes,
  	   zx_rates_b zx_rates
    WHERE
 	        codes.tax_id                         = zx_rates.tax_rate_id
	   AND  codes.tax_id                    = nvl(p_tax_id,codes.tax_id)
	   AND  codes.global_attribute_category = 'JL.CL.APXTADTC.AP_TAX_CODES'
	   AND  zx_rates.record_type_code       = 'MIGRATED'
    GROUP BY
         zx_rates.tax_regime_code;
    */

    --Bug# 4952838
    CREATE_REPORTING_TYPE_AP('CZ_TAX_ORIGIN','TEXT','Y', 'JE.CZ.APXTADTC.TAX_ORIGIN', p_tax_id);

    CREATE_REPORTING_TYPE_AP('HU_TAX_ORIGIN','TEXT','Y', 'JE.HU.APXTADTC.TAX_ORIGIN', p_tax_id);

    CREATE_REPORTING_TYPE_AP('PL_TAX_ORIGIN','TEXT','Y', 'JE.PL.APXTADTC.TAX_ORIGIN', p_tax_id);

    CREATE_REPORTING_TYPE_AP('CH_VAT_REGIME','TEXT','Y', 'JE.CH.APXTADTC.TAX_INFO', p_tax_id);

    CREATE_REPORTING_TYPE_AP('TW_GOVERNMENT_TAX_TYPE','TEXT','Y', 'JA.TW.APXTADTC.TAX_CODES', p_tax_id);

    CREATE_REPORTING_CODES('CH_VAT_REGIME', 'JECH_VAT_REGIME');

    --Bug#3922583  Creating reporting codes for 'CHILEAN GDF'
    CREATE_REPORTING_CODES('CL_TAX_CODE_CLASSIF','JLCL_TAX_CODE_CLASS');

    --Bug # 3935161
    CREATE_REPORT_TYPE_PTP('MEMBER STATE', 'TEXT', 'Y');

    -- Create Reporting Codes for 'MEMBER STATE'
    INSERT
    INTO  ZX_REPORTING_CODES_B(
	REPORTING_CODE_ID      ,
	EXCEPTION_CODE         ,
	EFFECTIVE_FROM         ,
	EFFECTIVE_TO           ,
	RECORD_TYPE_CODE       ,
	CREATED_BY                     ,
	CREATION_DATE                  ,
	LAST_UPDATED_BY                ,
	LAST_UPDATE_DATE               ,
	LAST_UPDATE_LOGIN              ,
	REQUEST_ID                     ,
	PROGRAM_APPLICATION_ID         ,
	PROGRAM_ID                     ,
	PROGRAM_LOGIN_ID		  ,
	REPORTING_CODE_CHAR_VALUE	  ,
	REPORTING_TYPE_ID		,
        OBJECT_VERSION_NUMBER
    )
    SELECT
	zx_reporting_codes_b_s.nextval,--REPORTING_CODE_ID
	NULL                          ,--EXCEPTION_CODE
	EFFECTIVE_FROM                ,
	NULL                          ,--EFFECTIVE_TO
	'MIGRATED'                    ,--RECORD_TYPE_CODE
	fnd_global.user_id            ,
	SYSDATE                       ,
	fnd_global.user_id            ,
	SYSDATE                       ,
	fnd_global.conc_login_id      ,
	fnd_global.conc_request_id    , -- Request Id
	fnd_global.prog_appl_id       , -- Program Application ID
	fnd_global.conc_program_id    , -- Program Id
	fnd_global.conc_login_id      , -- Program Login ID
	REPORTING_CODE,
	REPORTING_TYPE_ID,
	1

    FROM
    (
    SELECT
           distinct fin_sys_param.VAT_COUNTRY_CODE  REPORTING_CODE,
           report_types.EFFECTIVE_FROM     EFFECTIVE_FROM,
	   report_types.REPORTING_TYPE_ID  REPORTING_TYPE_ID
    FROM

        FINANCIALS_SYSTEM_PARAMS_ALL fin_sys_param,
        ZX_REPORTING_TYPES_B report_types

    WHERE

         report_types.REPORTING_TYPE_CODE = 'MEMBER STATE'
    AND  fin_sys_param.VAT_COUNTRY_CODE is NOT NULL
--    AND  report_types.RECORD_TYPE_CODE    = 'MIGRATED' -- Bug 5344337
    AND  NOT EXISTS
    	 (SELECT 1 FROM ZX_REPORTING_CODES_B WHERE
	  REPORTING_TYPE_ID   = report_types.REPORTING_TYPE_ID AND
	  fin_sys_param.VAT_COUNTRY_CODE = REPORTING_CODE_CHAR_VALUE
	 )
    );


  /*Insert into ZX_REPORTING_CODES_B for PORTUGAL Global Attribute 1.
    BugFix 3557652 REPORTING CODE IMPL FOR ARGENTINE DGI TRANSACTION CODE.
    Following Insert will take care of both of ABOVE since for both these
    the REPORTING CODES needs to pick up from FND_LOOKUPS */

   /* Commented for the Bug 4936036 : as the below logic is wrong and is based on the lookup_type = 'PT_LOCATION'
   which doesn't exist
   INSERT
    INTO  ZX_REPORTING_CODES_B(
		REPORTING_CODE_ID      ,
		EXCEPTION_CODE         ,
		EFFECTIVE_FROM         ,
		EFFECTIVE_TO           ,
		RECORD_TYPE_CODE       ,
		CREATED_BY                     ,
		CREATION_DATE                  ,
		LAST_UPDATED_BY                ,
		LAST_UPDATE_DATE               ,
		LAST_UPDATE_LOGIN              ,
		REQUEST_ID                     ,
		PROGRAM_APPLICATION_ID         ,
		PROGRAM_ID                     ,
		PROGRAM_LOGIN_ID		  ,
		REPORTING_CODE_CHAR_VALUE	  ,
		REPORTING_CODE_DATE_VALUE      ,
		REPORTING_CODE_NUM_VALUE       ,
		REPORTING_TYPE_ID,
                OBJECT_VERSION_NUMBER
	   )
    SELECT
           zx_reporting_codes_b_s.nextval,--REPORTING_CODE_ID
           NULL                          ,--EXCEPTION_CODE
           EFFECTIVE_FROM                ,
           NULL                          ,--EFFECTIVE_TO
          'MIGRATED'                     ,--RECORD_TYPE_CODE
           fnd_global.user_id            ,
           SYSDATE                       ,
           fnd_global.user_id            ,
           SYSDATE                       ,
           fnd_global.conc_login_id      ,
           fnd_global.conc_request_id    , -- Request Id
           fnd_global.prog_appl_id       , -- Program Application ID
           fnd_global.conc_program_id    , -- Program Id
           fnd_global.conc_login_id      ,  -- Program Login ID
           decode(DATATYPE,'TEXT',LOOKUP_CODE,'YES_NO',LOOKUP_CODE,NULL),
	   decode(DATATYPE,'DATE',LOOKUP_CODE,NULL),
	   decode(DATATYPE,'NUMERIC_VALUE',LOOKUP_CODE,NULL),
	   REPORTING_TYPE_ID,
	   1

    FROM
    (
    SELECT
           lookups.LOOKUP_CODE           LOOKUP_CODE        ,
           report_types.EFFECTIVE_FROM   EFFECTIVE_FROM,
	   report_types.REPORTING_TYPE_ID REPORTING_TYPE_ID,
	   report_types.REPORTING_TYPE_DATATYPE_CODE DATATYPE

    FROM

        ZX_REPORTING_TYPES_B report_types,
        FND_LOOKUPS          lookups

    WHERE

    	 report_types.REPORTING_TYPE_CODE = 'PT_LOCATION'
    AND  report_types.REPORTING_TYPE_CODE = lookups.LOOKUP_TYPE
    AND  report_types.RECORD_TYPE_CODE    = 'MIGRATED'

    AND  NOT EXISTS(SELECT 1 FROM ZX_REPORTING_CODES_B
                    WHERE  REPORTING_TYPE_ID   = report_types.REPORTING_TYPE_ID
                    AND   REPORTING_CODE_CHAR_VALUE =   lookups.LOOKUP_CODE
		    )

    );
    */

    --Insert into ZX_REPORTING_CODES_B for PORTUGAL Global Attribute 2..7
  /* Commented : Bug 4936036 : Reporting Codes should not be created for the below reporting types
  as has_reporting_codes_flag = 'N'
    INSERT
    INTO   ZX_REPORTING_CODES_B(
           REPORTING_CODE_ID      ,
           EXCEPTION_CODE         ,
           EFFECTIVE_FROM         ,
           EFFECTIVE_TO           ,
           RECORD_TYPE_CODE       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID		  ,
           REPORTING_CODE_CHAR_VALUE	  ,
	   REPORTING_CODE_DATE_VALUE      ,
	   REPORTING_CODE_NUM_VALUE       ,
	   REPORTING_TYPE_ID		  ,
 	   OBJECT_VERSION_NUMBER
			)
    SELECT
           zx_reporting_codes_b_s.nextval,--REPORTING_CODE_ID
           NULL                   ,--EXCEPTION_CODE
           effective_from         ,
           NULL                   ,--EFFECTIVE_TO
          'MIGRATED'              ,--RECORD_TYPE_CODE
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       ,  -- Program Login ID
           decode(DATATYPE,'TEXT',global_attribute,'YES_NO',global_attribute,NULL),
	   decode(DATATYPE,'DATE',global_attribute,NULL),
	   decode(DATATYPE,'NUMERIC_VALUE',global_attribute,NULL),
	   reporting_type_id,
	   1

    FROM
    (
    SELECT
    	   DISTINCT
           codes.global_attribute2      global_attribute,
           types.reporting_type_code    reporting_type_code,
           types.effective_from         effective_from,
	   types.reporting_type_id      reporting_type_id,
	   types.REPORTING_TYPE_DATATYPE_CODE DATATYPE
    FROM
        zx_reporting_types_b types,
        ap_tax_codes_all codes

    WHERE
             types.reporting_type_code       = 'PT_PRD_TAXABLE_BOX'
    AND  types.record_type_code          = 'MIGRATED'
    AND  codes.tax_id                    = nvl(p_tax_id,codes.tax_id)
    AND  codes.global_attribute_category = 'JE.PT.APXTADTC.TAX_INFO'
    AND  codes.global_attribute2  IS NOT NULL

    AND  (NOT EXISTS
              (select 1 from zx_reporting_codes_b where
               reporting_type_code     = types.reporting_type_code and
               REPORTING_CODE_CHAR_VALUE=codes.global_attribute2 )
         )

    UNION ALL
    SELECT
           DISTINCT
           codes.global_attribute3      global_attribute,
           types.reporting_type_code    reporting_type_code,
           types.effective_from         effective_from,
	   types.reporting_type_id      reporting_type_id,
	   types.REPORTING_TYPE_DATATYPE_CODE DATATYPE

    FROM
        zx_reporting_types_b types,
        ap_tax_codes_all codes

    WHERE
         types.reporting_type_code       = 'PT_PRD_REC_TAX_BOX'
    AND  types.record_type_code          = 'MIGRATED'
    AND  codes.tax_id                    = nvl(p_tax_id,codes.tax_id)
    AND  codes.global_attribute_category = 'JE.PT.APXTADTC.TAX_INFO'
    AND  codes.global_attribute3  IS NOT NULL


    AND  (NOT EXISTS
              (select 1 from zx_reporting_codes_b where
               reporting_type_code     = types.reporting_type_code and
                REPORTING_CODE_CHAR_VALUE=codes.global_attribute3 )
         )

    UNION ALL
    SELECT
    	   DISTINCT
           codes.global_attribute4      global_attribute,
           types.reporting_type_code    reporting_type_code,
           types.effective_from         effective_from,
	   types.reporting_type_id      reporting_type_id,
	   types.REPORTING_TYPE_DATATYPE_CODE DATATYPE
    FROM
        zx_reporting_types_b types,
        ap_tax_codes_all codes

    WHERE
             types.reporting_type_code       = 'PT_ANL_TTL_TAXABLE_BOX'
    AND  types.record_type_code          = 'MIGRATED'
    AND  codes.tax_id                    = nvl(p_tax_id,codes.tax_id)
    AND  codes.global_attribute_category = 'JE.PT.APXTADTC.TAX_INFO'
    AND  codes.global_attribute4  IS NOT NULL

    AND  (NOT EXISTS
              (select 1 from zx_reporting_codes_b where
               reporting_type_code     = types.reporting_type_code and
                REPORTING_CODE_CHAR_VALUE=codes.global_attribute4 )
         )

    UNION ALL
    SELECT
    	   DISTINCT
           codes.global_attribute5      global_attribute,
           types.reporting_type_code    l_reporting_type_code,
           types.effective_from         effective_from,
	   types.reporting_type_id      reporting_type_id,
	   types.REPORTING_TYPE_DATATYPE_CODE DATATYPE
    FROM
        zx_reporting_types_b types,
        ap_tax_codes_all codes

    WHERE
             types.reporting_type_code       = 'PT_ANL_REC_TAXABLE'
    AND  types.record_type_code          = 'MIGRATED'
     AND codes.global_attribute_category = 'JE.PT.APXTADTC.TAX_INFO'
    AND  codes.global_attribute5  IS NOT NULL


    AND  (NOT EXISTS
              (select 1 from zx_reporting_codes_b where
               reporting_type_code     = types.reporting_type_code and
               REPORTING_CODE_CHAR_VALUE=codes.global_attribute5 )
         )

    UNION ALL
    SELECT
           DISTINCT
           codes.global_attribute6      global_attribute,
           types.reporting_type_code    l_reporting_type_code,
           types.effective_from         effective_from,
	   types.reporting_type_id      reporting_type_id,
	   types.REPORTING_TYPE_DATATYPE_CODE DATATYPE
    FROM
        zx_reporting_types_b types,
        ap_tax_codes_all codes

    WHERE
             types.reporting_type_code       = 'PT_ANL_NON_REC_TAXABLE'
    AND  types.record_type_code          = 'MIGRATED'
    AND  codes.tax_id                    = nvl(p_tax_id,codes.tax_id)
     AND codes.global_attribute_category = 'JE.PT.APXTADTC.TAX_INFO'
    AND  codes.global_attribute6  IS NOT NULL


    AND  (NOT EXISTS
              (select 1 from zx_reporting_codes_b where
               reporting_type_code     = types.reporting_type_code and
               codes.global_attribute6 = REPORTING_CODE_CHAR_VALUE)
         )

    UNION ALL
    SELECT
           DISTINCT
           codes.global_attribute7      global_attribute,
           types.reporting_type_code    l_reporting_type_code,
           types.effective_from         effective_from,
	   types.reporting_type_id      reporting_type_id,
	   types.REPORTING_TYPE_DATATYPE_CODE DATATYPE
    FROM
        zx_reporting_types_b types,
        ap_tax_codes_all codes

    WHERE
             types.reporting_type_code       = 'PT_ANL_REC_TAX_BOX'
    AND  types.record_type_code          = 'MIGRATED'
    AND  codes.tax_id                    = nvl(p_tax_id,codes.tax_id)
    AND  codes.global_attribute_category = 'JE.PT.APXTADTC.TAX_INFO'
    AND  codes.global_attribute7  IS NOT NULL


    AND  (NOT EXISTS
              (select 1 from zx_reporting_codes_b where
               reporting_type_code     = types.reporting_type_code and
               codes.global_attribute7 = REPORTING_CODE_CHAR_VALUE)
         )

    );
*/

--   Bug Fix 4671652
--   Creation of reporting types for KR_BUSINESS_LOCATIONS

    INSERT ALL
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code= 'KR_BUSINESS_LOCATIONS'
                       and    tax_regime_code = l_tax_regime_code
	  )
          ) THEN
    INTO  ZX_REPORTING_TYPES_B(
		REPORTING_TYPE_ID              ,
		REPORTING_TYPE_CODE            ,
		REPORTING_TYPE_DATATYPE_CODE   ,
		TAX_REGIME_CODE                ,
		TAX                            ,
		FORMAT_MASK                    ,
		MIN_LENGTH                     ,
		MAX_LENGTH                     ,
		LEGAL_MESSAGE_FLAG             ,
		EFFECTIVE_FROM                 ,
		EFFECTIVE_TO                   ,
		RECORD_TYPE_CODE               ,
		HAS_REPORTING_CODES_FLAG       ,
		CREATED_BY                     ,
		CREATION_DATE                  ,
		LAST_UPDATED_BY                ,
		LAST_UPDATE_DATE               ,
		LAST_UPDATE_LOGIN              ,
		REQUEST_ID                     ,
		PROGRAM_APPLICATION_ID         ,
		PROGRAM_ID                     ,
		PROGRAM_LOGIN_ID		,
		OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_reporting_types_b_s.nextval ,--REPORTING_TYPE_ID
          'KR_BUSINESS_LOCATIONS'       ,--REPORTING_TYPE_CODE
           --'VARCHAR'	                  ,--REPORTING_TYPE_DATATYPE
	   'TEXT'	                  ,--REPORTING_TYPE_DATATYPE (Bug6430516)
           l_tax_regime_code              ,--TAX_REGIME_CODE
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                              ,--MIN_LENGTH
           30                             ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,--EFFECTIVE_FROM
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
           'Y'				  ,--HAS_REPORTING_CODES_FLAG
           fnd_global.user_id             ,--CREATED_BY
           SYSDATE                        ,--CREATION_DATE
           fnd_global.user_id             ,--LAST_UPDATED_BY
           SYSDATE                        ,--LAST_UPDATE_DATE
           fnd_global.conc_login_id       ,--LAST_UPDATE_LOGIN
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       ,  -- Program Login ID
	   1
          )
    SELECT
           min(zx_rates.effective_from) effective_from,
           zx_rates.tax_regime_code     l_tax_regime_code

    FROM
        ap_tax_codes_all           ap_tax,
        zx_rates_b                 zx_rates
    WHERE
            ap_tax.tax_id             = zx_rates.tax_rate_id
    AND  ap_tax.global_attribute_category = 'JA.KR.APXTADTC.WITHHOLDING'
    AND  zx_rates.record_type_code      = 'MIGRATED'
    AND  ap_tax.tax_id            = nvl(p_tax_id, ap_tax.tax_id)
    GROUP BY
          zx_rates.tax_regime_code;

--   Bug Fix 4671652
--   Creation of reporting codes for KR_BUSINESS_LOCATIONS
INSERT ALL
	INTO
	ZX_REPORTING_CODES_B
	(
	 REPORTING_CODE_ID ,
	 EXCEPTION_CODE    ,
	 EFFECTIVE_FROM    ,
	 EFFECTIVE_TO      ,
	 RECORD_TYPE_CODE  ,
	 CREATED_BY        ,
	 CREATION_DATE     ,
	 LAST_UPDATED_BY   ,
	 LAST_UPDATE_DATE  ,
	 LAST_UPDATE_LOGIN,
	 REQUEST_ID       ,
	 PROGRAM_APPLICATION_ID,
	 PROGRAM_ID            ,
	 PROGRAM_LOGIN_ID      ,
	 REPORTING_CODE_CHAR_VALUE,
	 REPORTING_CODE_DATE_VALUE,
	 REPORTING_CODE_NUM_VALUE ,
	 REPORTING_TYPE_ID        ,
	 OBJECT_VERSION_NUMBER
	)
	VALUES
	(
	ZX_REPORTING_CODES_B_S.NEXTVAL,
	NULL,
	l_start_date,
	NULL,
	'MIGRATED',
	FND_GLOBAL.USER_ID,
	SYSDATE,
	FND_GLOBAL.USER_ID,
	SYSDATE,
	fnd_global.conc_login_id      ,
	fnd_global.conc_request_id    , -- Request Id
	fnd_global.prog_appl_id       , -- Program Application ID
	fnd_global.conc_program_id    , -- Program Id
	fnd_global.conc_login_id      ,  -- Program Login ID
	l_location_code,
	NULL,
	NULL,
	(select reporting_type_id FROM zx_reporting_types_b where tax_regime_code = l_tax_regime_code
	  and reporting_type_code = 'KR_BUSINESS_LOCATIONS'),
	1)

    select
        distinct
		tax_id_values_and_codes.location_code l_location_code,
		zxrb.tax_regime_code l_tax_regime_code  ,
		(SELECT min(r.effective_from) FROM zx_rates_b r WHERE r.tax_regime_code = zxrb.tax_regime_code)  l_start_date
     from
               (
               select tax_id,hrloc.location_code location_code
			   from  ap_tax_codes_all aptax, hr_locations hrloc
			   where aptax.global_attribute_category = 'JA.KR.APXTADTC.WITHHOLDING'
                           and   aptax.global_attribute1 = to_char(hrloc.location_id)
   	       ) tax_id_values_and_codes,
                 zx_rates_b zxrb
    where zxrb.tax_rate_id               = tax_id_values_and_codes.tax_id
    and   tax_id_values_and_codes.tax_id = nvl(p_tax_id,tax_id_values_and_codes.tax_id)
    and   tax_id_values_and_codes.location_code is not null
	and not exists
		( select 1 from zx_reporting_codes_b where reporting_type_id =
		                      (select reporting_type_id FROM  zx_reporting_types_b
					                                    WHERE tax_regime_code = zxrb.tax_regime_code
		                                                AND   reporting_type_code = 'KR_BUSINESS_LOCATIONS')
		  AND reporting_code_char_value = tax_id_values_and_codes.location_code);


--   Bug Fix 4671652
--   Creation of reporting codes associations for KR_BUSINESS_LOCATIONS


 INSERT
   INTO   ZX_REPORT_CODES_ASSOC(
          REPORTING_CODE_ASSOC_ID,
          ENTITY_CODE            ,
          ENTITY_ID              ,
          REPORTING_TYPE_ID      ,
          REPORTING_CODE_ID      ,
          EXCEPTION_CODE         ,
          EFFECTIVE_FROM         ,
          EFFECTIVE_TO           ,
          CREATED_BY             ,
          CREATION_DATE          ,
          LAST_UPDATED_BY        ,
          LAST_UPDATE_DATE       ,
          LAST_UPDATE_LOGIN	 ,
	  REPORTING_CODE_CHAR_VALUE,
	  REPORTING_CODE_DATE_VALUE,
	  REPORTING_CODE_NUM_VALUE,
	  OBJECT_VERSION_NUMBER
				)
    SELECT
          ZX_REPORT_CODES_ASSOC_S.nextval  ,
         'ZX_RATES'                        ,--ENTITY_CODE
          TAX_RATE_ID                      ,--ENTITY_ID
          REPORTING_TYPE_ID              ,
          REPORTING_CODE_ID                   ,
          NULL                             ,--EXCEPTION_CODE
          EFFECTIVE_FROM                   ,
          NULL                             ,--EFFECTIVE_TO
          fnd_global.user_id               ,
          SYSDATE                          ,
          fnd_global.user_id               ,
          SYSDATE                          ,
          fnd_global.conc_login_id	   ,
	  REPORTING_CODE_CHAR_VALUE,
	  REPORTING_CODE_DATE_VALUE,
 	  REPORTING_CODE_NUM_VALUE,
	  1
    FROM
    (
    SELECT
          rates.TAX_RATE_ID                       TAX_RATE_ID,
          report_codes.REPORTING_CODE_ID          REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM             EFFECTIVE_FROM,
	  report_codes.REPORTING_TYPE_ID          REPORTING_TYPE_ID,
	  report_codes.REPORTING_CODE_CHAR_VALUE  REPORTING_CODE_CHAR_VALUE ,
	  report_codes.REPORTING_CODE_DATE_VALUE  REPORTING_CODE_DATE_VALUE,
 	  report_codes.REPORTING_CODE_NUM_VALUE   REPORTING_CODE_NUM_VALUE
    FROM
      AP_TAX_CODES_ALL codes,
      HR_LOCATIONS     hrloc,
      ZX_RATES_B       rates,
      ZX_REPORTING_TYPES_B  reporting_types,
      ZX_REPORTING_CODES_B report_codes
    WHERE
         codes.tax_id                    =  rates.tax_rate_id
    AND  codes.tax_id                    =  nvl(p_tax_id,codes.tax_id)
    AND  codes.global_attribute1         =  TO_CHAR(hrloc.location_id)
    AND  codes.global_attribute_category = 'JA.KR.APXTADTC.WITHHOLDING'
    AND  hrloc.location_code             =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  rates.tax_regime_code           =  reporting_types.tax_regime_code
    AND  reporting_types.reporting_type_code = 'KR_BUSINESS_LOCATIONS'
    AND  reporting_types.reporting_type_id = report_codes.reporting_type_id
    AND  report_codes.record_type_code   = 'MIGRATED'

    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id   =
                           report_codes.reporting_type_id)
     );


    IF PG_DEBUG = 'Y' THEN
	arp_util_tax.debug('CREATE_ZX_REP_TYPE_CODES_AP(-)');
    END IF;

END CREATE_ZX_REP_TYPE_CODES_AP;


/* Used to create the reporting type and code for AR */

PROCEDURE CREATE_ZX_REP_TYPE_CODES_AR(p_tax_id IN NUMBER ) IS
--l_lookup_code ZX_REPORTING_CODES_B.REPORTING_CODE_CHAR_VALUE%TYPE ; -- Bug 4874049
l_exists_cnt NUMBER ; --Bug 5344337
BEGIN

     IF PG_DEBUG = 'Y' THEN
		arp_util_tax.debug('CREATE_ZX_REP_TYPE_CODES_AR(+)');
     END IF;

	-- Call a common procedure to create a reporting types.
	CREATE_REPORTING_TYPE_AR('CL_BILLS_OF_EXCH_TAX','YES_NO','N', 'JL.CL.ARXSUVAT.VAT_TAX', p_tax_id);
	CREATE_REPORTING_TYPE_AR('CL_TAX_CODE_CLASSIF','TEXT','Y', 'JL.CL.ARXSUVAT.VAT_TAX', p_tax_id);

	CREATE_REPORTING_TYPE_AR('PRINT TAX LINE','YES_NO','N','JL.AR.ARXSUVAT.AR_VAT_TAX', p_tax_id);
	CREATE_REPORTING_TYPE_AR('PRINT TAX LINE','YES_NO','N','JL.BR.ARXSUVAT.Tax Information', p_tax_id);
	CREATE_REPORTING_TYPE_AR('PRINT TAX LINE','YES_NO','N','JL.CO.ARXSUVAT.AR_VAT_TAX', p_tax_id);

        -- For Korea
        CREATE_REPORTING_TYPE_AR('KR_LOCATION','TEXT','Y', 'JA.KR.ARXSUVAT.VAT', p_tax_id);


	--Bug# 4952838
	CREATE_REPORTING_TYPE_AR('CZ_TAX_ORIGIN','TEXT','Y', 'JE.CZ.ARXSUVAT.TAX_ORIGIN', p_tax_id);

	CREATE_REPORTING_TYPE_AR('HU_TAX_ORIGIN','TEXT','Y', 'JE.HU.ARXSUVAT.TAX_ORIGIN', p_tax_id);

	CREATE_REPORTING_TYPE_AR('PL_TAX_ORIGIN','TEXT','Y', 'JE.PL.ARXSUVAT.TAX_ORIGIN', p_tax_id);

	CREATE_REPORTING_TYPE_AR('TW_GOVERNMENT_TAX_TYPE','TEXT','Y', 'JA.TW.ARXSUVAT.VAT_TAX', p_tax_id);

	CREATE_REPORTING_TYPE_AR('CL_DEBIT_ACCOUNT','TEXT','N', 'JL.CL.ARXSUVAT.VAT_TAX', p_tax_id);

	/*  In the above methods, we are using different context (global attribute category) to insert into
	reporting types. But in the below insert all  we are using same context for all the reporting types.
	Hence we are using bulk insert only for the same context case. */

     INSERT ALL
     WHEN   (NOT EXISTS (select 1 from zx_reporting_types_b
                        where  reporting_type_code='PT_LOCATION'
                        and    tax_regime_code = l_tax_regime_code)
           ) THEN
     INTO
	   ZX_REPORTING_TYPES_B(
           REPORTING_TYPE_ID              ,
	   REPORTING_TYPE_CODE            ,
   	   REPORTING_TYPE_DATATYPE_CODE   ,
   	   TAX_REGIME_CODE                ,
	   TAX                            ,
	   FORMAT_MASK                    ,
	   MIN_LENGTH                     ,
	   MAX_LENGTH                     ,
	   LEGAL_MESSAGE_FLAG             ,
	   EFFECTIVE_FROM                 ,
	   EFFECTIVE_TO                   ,
	   RECORD_TYPE_CODE               ,
         --BugFix 3566148
           HAS_REPORTING_CODES_FLAG       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID		  ,
	   OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_migrate_util.get_next_seqid('zx_reporting_types_b_s'),--REPORTING_TYPE_ID
          'PT_LOCATION'                                            ,--REPORTING_TYPE_CODE
          'TEXT'                          ,--REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                              ,--MIN_LENGTH
           30                             ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
          'Y'                             ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       , -- Program Login ID
	   1
          )
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code='PT_PRD_TAXABLE_BOX'
                       and    tax_regime_code = l_tax_regime_code)
          ) THEN
    INTO   ZX_REPORTING_TYPES_B(
           REPORTING_TYPE_ID              ,
           REPORTING_TYPE_CODE            ,
           REPORTING_TYPE_DATATYPE_CODE   ,
           TAX_REGIME_CODE                ,
           TAX                            ,
           FORMAT_MASK                    ,
           MIN_LENGTH                     ,
           MAX_LENGTH                     ,
           LEGAL_MESSAGE_FLAG             ,
           EFFECTIVE_FROM                 ,
           EFFECTIVE_TO                   ,
           RECORD_TYPE_CODE               ,
         --BugFix 3566148
           HAS_REPORTING_CODES_FLAG       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID		  ,
	   OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_migrate_util.get_next_seqid('zx_reporting_types_b_s') ,--REPORTING_TYPE_ID
          'PT_PRD_TAXABLE_BOX'                                      ,--REPORTING_TYPE_CODE
          'TEXT'                          ,--REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                              ,--MIN_LENGTH
           30                             ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
          'N'                             ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       , -- Program Login ID
	   1
          )
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code='PT_PRD_REC_TAX_BOX'
                       and    tax_regime_code = l_tax_regime_code)
          ) THEN
    INTO   ZX_REPORTING_TYPES_B(
           REPORTING_TYPE_ID              ,
           REPORTING_TYPE_CODE            ,
           REPORTING_TYPE_DATATYPE_CODE   ,
           TAX_REGIME_CODE                ,
           TAX                            ,
           FORMAT_MASK                    ,
           MIN_LENGTH                     ,
           MAX_LENGTH                     ,
           LEGAL_MESSAGE_FLAG             ,
           EFFECTIVE_FROM                 ,
           EFFECTIVE_TO                   ,
           RECORD_TYPE_CODE               ,
         --BugFix 3566148
           HAS_REPORTING_CODES_FLAG       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID		  ,
	   OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_migrate_util.get_next_seqid('zx_reporting_types_b_s') ,--REPORTING_TYPE_ID
          'PT_PRD_REC_TAX_BOX'                                          ,--REPORTING_TYPE_CODE
          'TEXT'                          ,--REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                           ,--MIN_LENGTH
           30                              ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
          'N'                             ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       , -- Program Login ID
	   1
          )
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code='PT_ANL_TTL_TAXABLE_BOX'
                       and    tax_regime_code = l_tax_regime_code)
          ) THEN
    INTO   ZX_REPORTING_TYPES_B(
           REPORTING_TYPE_ID              ,
           REPORTING_TYPE_CODE            ,
           REPORTING_TYPE_DATATYPE_CODE   ,
           TAX_REGIME_CODE                ,
           TAX                            ,
           FORMAT_MASK                    ,
           MIN_LENGTH                     ,
           MAX_LENGTH                     ,
           LEGAL_MESSAGE_FLAG             ,
           EFFECTIVE_FROM                 ,
           EFFECTIVE_TO                   ,
           RECORD_TYPE_CODE               ,
         --BugFix 3566148
           HAS_REPORTING_CODES_FLAG       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID		  ,
	   OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_migrate_util.get_next_seqid('zx_reporting_types_b_s') ,--REPORTING_TYPE_ID
          'PT_ANL_TTL_TAXABLE_BOX'                                  ,--REPORTING_TYPE_CODE
          'TEXT'                          ,--REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                              ,--MIN_LENGTH
           30                             ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
          'N'                             ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       , -- Program Login ID
	   1
          )
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code='PT_ANL_REC_TAXABLE' -- Bug 5031787
                       and    tax_regime_code = l_tax_regime_code)
          ) THEN
    INTO   ZX_REPORTING_TYPES_B(
           REPORTING_TYPE_ID              ,
           REPORTING_TYPE_CODE            ,
           REPORTING_TYPE_DATATYPE_CODE   ,
           TAX_REGIME_CODE                ,
           TAX                            ,
           FORMAT_MASK                    ,
           MIN_LENGTH                     ,
           MAX_LENGTH                     ,
           LEGAL_MESSAGE_FLAG             ,
           EFFECTIVE_FROM                 ,
           EFFECTIVE_TO                   ,
           RECORD_TYPE_CODE               ,
         --BugFix 3566148
           HAS_REPORTING_CODES_FLAG       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID		  ,
	   OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_migrate_util.get_next_seqid('zx_reporting_types_b_s') ,--REPORTING_TYPE_ID
          'PT_ANL_REC_TAXABLE'                                          ,--REPORTING_TYPE_CODE
          'TEXT'                          ,--REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                           ,--MIN_LENGTH
           30                              ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
          'N'                             ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       ,  -- Program Login ID
	   1
          )
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code='PT_ANL_NON_REC_TAXABLE'
                       and    tax_regime_code = l_tax_regime_code)
          ) THEN
    INTO   ZX_REPORTING_TYPES_B(
           REPORTING_TYPE_ID              ,
           REPORTING_TYPE_CODE            ,
           REPORTING_TYPE_DATATYPE_CODE   ,
           TAX_REGIME_CODE                ,
           TAX                            ,
           FORMAT_MASK                    ,
           MIN_LENGTH                     ,
           MAX_LENGTH                     ,
           LEGAL_MESSAGE_FLAG             ,
           EFFECTIVE_FROM                 ,
           EFFECTIVE_TO                   ,
           RECORD_TYPE_CODE               ,
         --BugFix 3566148
           HAS_REPORTING_CODES_FLAG       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID		  ,
	   OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_migrate_util.get_next_seqid('zx_reporting_types_b_s') ,--REPORTING_TYPE_ID
          'PT_ANL_NON_REC_TAXABLE'                                  ,--REPORTING_TYPE_CODE
          'TEXT'                          ,--REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                           ,--MIN_LENGTH
           30                              ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
          'N'                             ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       ,  -- Program Login ID
	   1
          )
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code='PT_ANL_REC_TAX_BOX' -- Bug 5031787
                       and    tax_regime_code = l_tax_regime_code)
          ) THEN
    INTO   ZX_REPORTING_TYPES_B(
           REPORTING_TYPE_ID              ,
           REPORTING_TYPE_CODE            ,
           REPORTING_TYPE_DATATYPE_CODE   ,
           TAX_REGIME_CODE                ,
           TAX                            ,
           FORMAT_MASK                    ,
           MIN_LENGTH                     ,
           MAX_LENGTH                     ,
           LEGAL_MESSAGE_FLAG             ,
           EFFECTIVE_FROM                 ,
           EFFECTIVE_TO                   ,
           RECORD_TYPE_CODE               ,
         --BugFix 3566148
           HAS_REPORTING_CODES_FLAG       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID		  ,
	   OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_migrate_util.get_next_seqid('zx_reporting_types_b_s') ,--REPORTING_TYPE_ID
          'PT_ANL_REC_TAX_BOX'                                          ,--REPORTING_TYPE_CODE
          'TEXT'                          ,--REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                           ,--MIN_LENGTH
           30                              ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
          'N'                             ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       ,  -- Program Login ID
	   1
          )

    SELECT
           min(zx_rates.effective_from) effective_from,
           zx_rates.tax_regime_code  l_tax_regime_code
    FROM
        AR_VAT_TAX_ALL_B  vat_tax,
        zx_rates_b zx_rates
    WHERE
         vat_tax.vat_tax_id                    = zx_rates.tax_rate_id
    AND  vat_tax.vat_tax_id                      = nvl(p_tax_id, vat_tax.vat_tax_id)
    AND  vat_tax.global_attribute_category = 'JE.PT.ARXSUVAT.TAX_INFO'
    AND  zx_rates.record_type_code       = 'MIGRATED'

    GROUP BY
            zx_rates.tax_regime_code;


    INSERT ALL
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code='AR_DGI_TRX_CODE'
                       and    tax_regime_code = l_tax_regime_code)
          ) THEN
    INTO   ZX_REPORTING_TYPES_B(
           REPORTING_TYPE_ID              ,
	   REPORTING_TYPE_CODE            ,
   	   REPORTING_TYPE_DATATYPE_CODE   ,
   	   TAX_REGIME_CODE                ,
	   TAX                            ,
	   FORMAT_MASK                    ,
	   MIN_LENGTH                     ,
	   MAX_LENGTH                     ,
	   LEGAL_MESSAGE_FLAG             ,
	   EFFECTIVE_FROM                 ,
	   EFFECTIVE_TO                   ,
	   RECORD_TYPE_CODE               ,
           HAS_REPORTING_CODES_FLAG       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID		  ,
	   OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_migrate_util.get_next_seqid('zx_reporting_types_b_s') ,--REPORTING_TYPE_ID
          'AR_DGI_TRX_CODE'                                         ,--REPORTING_TYPE_CODE
          'TEXT'                          ,--REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                              ,--MIN_LENGTH
           30                             ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
          'Y'                             ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       ,  -- Program Login ID
	   1
          )

     WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code='AR_MUNICIPAL_JUR'
                       and    tax_regime_code = l_tax_regime_code)
          ) THEN
	INTO  ZX_REPORTING_TYPES_B(
		REPORTING_TYPE_ID              ,
		REPORTING_TYPE_CODE            ,
		REPORTING_TYPE_DATATYPE_CODE   ,
		TAX_REGIME_CODE                ,
		TAX                            ,
		FORMAT_MASK                    ,
		MIN_LENGTH                     ,
		MAX_LENGTH                     ,
		LEGAL_MESSAGE_FLAG             ,
		EFFECTIVE_FROM                 ,
		EFFECTIVE_TO                   ,
		RECORD_TYPE_CODE               ,
		HAS_REPORTING_CODES_FLAG       ,
		CREATED_BY                     ,
		CREATION_DATE                  ,
		LAST_UPDATED_BY                ,
		LAST_UPDATE_DATE               ,
		LAST_UPDATE_LOGIN              ,
		REQUEST_ID                     ,
		PROGRAM_APPLICATION_ID         ,
		PROGRAM_ID                     ,
		PROGRAM_LOGIN_ID	       ,
                OBJECT_VERSION_NUMBER
		)
    VALUES(
           zx_migrate_util.get_next_seqid('zx_reporting_types_b_s') ,--REPORTING_TYPE_ID
          'AR_MUNICIPAL_JUR'                                        ,--REPORTING_TYPE_CODE
          'TEXT'                          ,--REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                              ,--MIN_LENGTH
           30                             ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
          'N'                             ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       , -- Program Login ID
	    1
          )

    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code='AR_TURN_OVER_JUR_CODE'
                       and    tax_regime_code = l_tax_regime_code)
          ) THEN
    INTO   ZX_REPORTING_TYPES_B(
           REPORTING_TYPE_ID              ,
	   REPORTING_TYPE_CODE            ,
   	   REPORTING_TYPE_DATATYPE_CODE   ,
   	   TAX_REGIME_CODE                ,
	   TAX                            ,
	   FORMAT_MASK                    ,
	   MIN_LENGTH                     ,
	   MAX_LENGTH                     ,
	   LEGAL_MESSAGE_FLAG             ,
	   EFFECTIVE_FROM                 ,
	   EFFECTIVE_TO                   ,
	   RECORD_TYPE_CODE               ,
           HAS_REPORTING_CODES_FLAG       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID	           ,
	   OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_migrate_util.get_next_seqid('zx_reporting_types_b_s') ,--REPORTING_TYPE_ID
          'AR_TURN_OVER_JUR_CODE'                                   ,--REPORTING_TYPE_CODE
          'TEXT'                          ,--REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                              ,--MIN_LENGTH
           30                             ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
          'Y'                             ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       , -- Program Login ID
	   1
          )

    SELECT
           min(zx_rates.effective_from) effective_from,
           zx_rates.tax_regime_code  l_tax_regime_code
    FROM
        AR_VAT_TAX_ALL_B  codes,
        zx_rates_b zx_rates
    WHERE
         codes.vat_tax_id                = zx_rates.tax_rate_id
     AND  codes.vat_tax_id                = nvl(p_tax_id,codes.vat_tax_id)
    AND  codes.global_attribute_category = 'JL.AR.ARXSUVAT.AR_VAT_TAX'
    AND  zx_rates.record_type_code       = 'MIGRATED'

    GROUP BY
            zx_rates.tax_regime_code;
--Bug 4705196
/*
--Bug 4422813
--The creation of zx_reporting_types_b , zx_reporting_codes_b and zx_reporting_codes_tl has been put together for
--easy understanding

INSERT ALL
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code= 'PRINTED_TAX_RATE_NAME'
                       and    tax_regime_code = l_tax_regime_code
	  )
          ) THEN
    INTO  ZX_REPORTING_TYPES_B(
		REPORTING_TYPE_ID              ,
		REPORTING_TYPE_CODE            ,
		REPORTING_TYPE_DATATYPE_CODE   ,
		TAX_REGIME_CODE                ,
		TAX                            ,
		FORMAT_MASK                    ,
		MIN_LENGTH                     ,
		MAX_LENGTH                     ,
		LEGAL_MESSAGE_FLAG             ,
		EFFECTIVE_FROM                 ,
		EFFECTIVE_TO                   ,
		RECORD_TYPE_CODE               ,
		HAS_REPORTING_CODES_FLAG       ,
		CREATED_BY                     ,
		CREATION_DATE                  ,
		LAST_UPDATED_BY                ,
		LAST_UPDATE_DATE               ,
		LAST_UPDATE_LOGIN              ,
		REQUEST_ID                     ,
		PROGRAM_APPLICATION_ID         ,
		PROGRAM_ID                     ,
		PROGRAM_LOGIN_ID		,
		OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_reporting_types_b_s.nextval ,--REPORTING_TYPE_ID
          'PRINTED_TAX_RATE_NAME'           ,--REPORTING_TYPE_CODE
           'VARCHAR'	,             --REPORTING_TYPE_DATATYPE
           l_tax_regime_code              ,
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                              ,--MIN_LENGTH
           30                             ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG  ?? What should this be
           effective_from                 ,
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
           'Y'				  ,--HAS_REPORTING_CODES_FLAG
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       ,  -- Program Login ID
	   1
          )
    SELECT
           min(zx_rates.effective_from) effective_from,
           zx_rates.tax_regime_code  l_tax_regime_code

    FROM
        ar_vat_tax_all_b           vat_tax,
        zx_rates_b                 zx_rates
    WHERE
           vat_tax.vat_tax_id             = zx_rates.tax_rate_id
    AND  zx_rates.record_type_code        = 'MIGRATED'
    AND  vat_tax.vat_tax_id               = nvl(p_tax_id, vat_tax.vat_tax_id)
    GROUP BY
          zx_rates.tax_regime_code;


declare
l_language_code varchar2(30);
l_seqid    number;
begin
select nvl(language_code,'US') into l_language_code from FND_LANGUAGES where installed_flag = 'B' ;


for cursor_rec in
(select vat_tax_id  from ar_vat_tax_all_b )


LOOP
select zx_reporting_codes_b_s.nextval into l_seqid from dual;

INSERT ALL
INTO
ZX_REPORTING_CODES_B
(
 REPORTING_CODE_ID ,
 EXCEPTION_CODE    ,
 EFFECTIVE_FROM    ,
 EFFECTIVE_TO      ,
 RECORD_TYPE_CODE  ,
 CREATED_BY        ,
 CREATION_DATE     ,
 LAST_UPDATED_BY   ,
 LAST_UPDATE_DATE  ,
 LAST_UPDATE_LOGIN,
 REQUEST_ID       ,
 PROGRAM_APPLICATION_ID,
 PROGRAM_ID            ,
 PROGRAM_LOGIN_ID      ,
 REPORTING_CODE_CHAR_VALUE,
 REPORTING_CODE_DATE_VALUE,
 REPORTING_CODE_NUM_VALUE ,
 REPORTING_TYPE_ID        ,
 OBJECT_VERSION_NUMBER
)
VALUES
(
l_seqid,
NULL,
l_start_date,
NULL,
'MIGRATED',
FND_GLOBAL.USER_ID,
SYSDATE,
FND_GLOBAL.USER_ID,
SYSDATE,
fnd_global.conc_login_id      ,
fnd_global.conc_request_id    , -- Request Id
fnd_global.prog_appl_id       , -- Program Application ID
fnd_global.conc_program_id    , -- Program Id
fnd_global.conc_login_id      ,  -- Program Login ID
printed_tax_name,
NULL,
NULL,
(select reporting_type_id FROM zx_reporting_types_b where tax_regime_code = l_tax_regime_code
  and reporting_type_code = 'PRINTED_TAX_RATE_NAME'),
1)

(select
	printed_tax_name ,
	zxrb.tax_regime_code l_tax_regime_code  ,
	zxrb.effective_from  l_start_date
from	ar_vat_tax_all_tl avtl ,
	zx_rates_b zxrb
where   zxrb.tax_rate_id       = cursor_rec.vat_tax_id
    and zxrb.tax_rate_id      = avtl.vat_tax_id
    and language = l_language_code
    and printed_tax_name is not null
    and not exists
        ( select 1 from zx_reporting_codes_b where reporting_type_id =
	 (select reporting_type_id FROM zx_reporting_types_b where tax_regime_code = zxrb.tax_regime_code
     								and reporting_type_code = 'PRINTED_TAX_RATE_NAME')
	 and reporting_code_char_value = printed_tax_name)
);



INSERT ALL
INTO
ZX_REPORTING_CODES_TL
(
 REPORTING_CODE_ID  ,
 LANGUAGE           ,
 SOURCE_LANG        ,
 REPORTING_CODE_NAME,
 CREATED_BY         ,
 CREATION_DATE      ,
 LAST_UPDATED_BY    ,
 LAST_UPDATE_DATE   ,
 LAST_UPDATE_LOGIN
)
VALUES
(
    	l_seqid,
	l_language,
	l_source_lang,
        CASE WHEN l_printed_tax_name = UPPER(l_printed_tax_name)
	     THEN    Initcap(l_printed_tax_name)
	     ELSE
		     l_printed_tax_name
        END,
	fnd_global.user_id,
	sysdate,
	fnd_global.user_id,
	sysdate,
	fnd_global.conc_login_id
)
SELECT
	avtl.language l_language,
	avtl.source_lang l_source_lang,
	avtl.printed_tax_name l_printed_tax_name

from
	ar_vat_tax_all_tl avtl
where   avtl.vat_tax_id = cursor_rec.vat_tax_id
and     avtl.printed_tax_name is not null
and     not exists
		(select 1 from zx_reporting_codes_tl where reporting_code_id = l_seqid
		and language = avtl.language);
END LOOP;


END;

--End of bug fix 4422813

*/

--Bug Fix 4466085
--Creation of reporting type for REPORTING_TYPE_CODE ZX_ADJ_TAX_CLASSIF_CODE
-- Bug 5344337
SELECT COUNT(1) INTO l_exists_cnt
FROM
	ar_vat_tax_all_b vat_tax,
        zx_rates_b                 zx_rates
WHERE
	vat_tax.vat_tax_id             = zx_rates.tax_rate_id
	AND  zx_rates.record_type_code      = 'MIGRATED';

--Need to Delete Seeded records if there is a source for reporting type to get created using 11i Migrated Regimes.
IF ( l_exists_cnt > 0 ) THEN
	DELETE FROM ZX_REPORTING_TYPES_TL
		WHERE reporting_type_id IN ( SELECT reporting_type_id FROM ZX_REPORTING_TYPES_B
			WHERE  reporting_type_code= 'ZX_ADJ_TAX_CLASSIF_CODE' AND record_type_code = 'SEEDED' );

	DELETE FROM ZX_REPORT_TYPES_USAGES
		WHERE reporting_type_id IN ( SELECT reporting_type_id FROM ZX_REPORTING_TYPES_B
			WHERE  reporting_type_code= 'ZX_ADJ_TAX_CLASSIF_CODE' AND record_type_code = 'SEEDED' );

	DELETE FROM ZX_REPORTING_TYPES_B WHERE  reporting_type_code= 'ZX_ADJ_TAX_CLASSIF_CODE' AND record_type_code = 'SEEDED';
END IF ;

INSERT ALL
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code= 'ZX_ADJ_TAX_CLASSIF_CODE'
                       and    tax_regime_code = l_tax_regime_code
	  )
          ) THEN
    INTO  ZX_REPORTING_TYPES_B(
		REPORTING_TYPE_ID              ,
		REPORTING_TYPE_CODE            ,
		REPORTING_TYPE_DATATYPE_CODE   ,
		TAX_REGIME_CODE                ,
		TAX                            ,
		FORMAT_MASK                    ,
		MIN_LENGTH                     ,
		MAX_LENGTH                     ,
		LEGAL_MESSAGE_FLAG             ,
		EFFECTIVE_FROM                 ,
		EFFECTIVE_TO                   ,
		RECORD_TYPE_CODE               ,
		HAS_REPORTING_CODES_FLAG       ,
		CREATED_BY                     ,
		CREATION_DATE                  ,
		LAST_UPDATED_BY                ,
		LAST_UPDATE_DATE               ,
		LAST_UPDATE_LOGIN              ,
		REQUEST_ID                     ,
		PROGRAM_APPLICATION_ID         ,
		PROGRAM_ID                     ,
		PROGRAM_LOGIN_ID		,
		OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_reporting_types_b_s.nextval ,--REPORTING_TYPE_ID
          'ZX_ADJ_TAX_CLASSIF_CODE'       ,--REPORTING_TYPE_CODE
           --'VARCHAR'	                  ,--REPORTING_TYPE_DATATYPE
	   'TEXT'	                  ,--REPORTING_TYPE_DATATYPE (bug6430516)
           l_tax_regime_code              ,--TAX_REGIME_CODE
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                              ,--MIN_LENGTH
           30                             ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,--EFFECTIVE_FROM
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
           'Y'				  ,--HAS_REPORTING_CODES_FLAG
           fnd_global.user_id             ,--CREATED_BY
           SYSDATE                        ,--CREATION_DATE
           fnd_global.user_id             ,--LAST_UPDATED_BY
           SYSDATE                        ,--LAST_UPDATE_DATE
           fnd_global.conc_login_id       ,--LAST_UPDATE_LOGIN
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       ,  -- Program Login ID
	   1
          )
    SELECT
           min(zx_rates.effective_from) effective_from,
           zx_rates.tax_regime_code     l_tax_regime_code

    FROM
        ar_vat_tax_all_b           vat_tax,
        zx_rates_b                 zx_rates
    WHERE
         vat_tax.vat_tax_id             = zx_rates.tax_rate_id
    AND  zx_rates.record_type_code      = 'MIGRATED'
    AND  vat_tax.vat_tax_id             = nvl(p_tax_id, vat_tax.vat_tax_id)
    GROUP BY
          zx_rates.tax_regime_code;


--Bug Fix 4466085
--Creation of Reporting Codes for Reporting Type ZX_ADJ_TAX_CLASSIF_CODE

	INSERT ALL
	INTO
	ZX_REPORTING_CODES_B
	(
	 REPORTING_CODE_ID ,
	 EXCEPTION_CODE    ,
	 EFFECTIVE_FROM    ,
	 EFFECTIVE_TO      ,
	 RECORD_TYPE_CODE  ,
	 CREATED_BY        ,
	 CREATION_DATE     ,
	 LAST_UPDATED_BY   ,
	 LAST_UPDATE_DATE  ,
	 LAST_UPDATE_LOGIN,
	 REQUEST_ID       ,
	 PROGRAM_APPLICATION_ID,
	 PROGRAM_ID            ,
	 PROGRAM_LOGIN_ID      ,
	 REPORTING_CODE_CHAR_VALUE,
	 REPORTING_CODE_DATE_VALUE,
	 REPORTING_CODE_NUM_VALUE ,
	 REPORTING_TYPE_ID        ,
	 OBJECT_VERSION_NUMBER
	)
	VALUES
	(
	ZX_REPORTING_CODES_B_S.NEXTVAL,
	NULL,
	l_start_date,
	NULL,
	'MIGRATED',
	FND_GLOBAL.USER_ID,
	SYSDATE,
	FND_GLOBAL.USER_ID,
	SYSDATE,
	fnd_global.conc_login_id      ,
	fnd_global.conc_request_id    , -- Request Id
	fnd_global.prog_appl_id       , -- Program Application ID
	fnd_global.conc_program_id    , -- Program Id
	fnd_global.conc_login_id      ,  -- Program Login ID
	adjustment_tax_code,
	NULL,
	NULL,
	(select reporting_type_id FROM zx_reporting_types_b where tax_regime_code = l_tax_regime_code
	  and reporting_type_code = 'ZX_ADJ_TAX_CLASSIF_CODE'),
	1)

	select
		adjustment_tax_code ,
		zxrb.tax_regime_code l_tax_regime_code  ,
		zxrb.effective_from  l_start_date
	from	ar_vat_tax_all_b avtb ,
  		    zx_rates_b zxrb
    where   zxrb.tax_rate_id       = avtb.vat_tax_id
	and     adjustment_tax_code is not null
	and not exists
		( select 1 from zx_reporting_codes_b where reporting_type_id =
                      (select reporting_type_id FROM  zx_reporting_types_b
                          WHERE tax_regime_code = zxrb.tax_regime_code
                          AND   reporting_type_code = 'ZX_ADJ_TAX_CLASSIF_CODE')
		  AND reporting_code_char_value = adjustment_tax_code);

	--Bug# 4952838
	/* Bug 5031787 : Commented for the Bug as has_reporting_code_flag is 'N' and no codes creation is redundant
	INSERT ALL
	INTO
	ZX_REPORTING_CODES_B
	(
	 REPORTING_CODE_ID ,
	 EXCEPTION_CODE    ,
	 EFFECTIVE_FROM    ,
	 EFFECTIVE_TO      ,
	 RECORD_TYPE_CODE  ,
	 CREATED_BY        ,
	 CREATION_DATE     ,
	 LAST_UPDATED_BY   ,
	 LAST_UPDATE_DATE  ,
	 LAST_UPDATE_LOGIN,
	 REQUEST_ID       ,
	 PROGRAM_APPLICATION_ID,
	 PROGRAM_ID            ,
	 PROGRAM_LOGIN_ID      ,
	 REPORTING_CODE_CHAR_VALUE,
	 REPORTING_CODE_DATE_VALUE,
	 REPORTING_CODE_NUM_VALUE ,
	 REPORTING_TYPE_ID        ,
	 OBJECT_VERSION_NUMBER
	)
	VALUES
	(
	ZX_REPORTING_CODES_B_S.NEXTVAL,
	NULL,
	l_start_date,
	NULL,
	'MIGRATED',
	FND_GLOBAL.USER_ID,
	SYSDATE,
	FND_GLOBAL.USER_ID,
	SYSDATE,
	fnd_global.conc_login_id      ,
	fnd_global.conc_request_id    , -- Request Id
	fnd_global.prog_appl_id       , -- Program Application ID
	fnd_global.conc_program_id    , -- Program Id
	fnd_global.conc_login_id      , -- Program Login ID
	global_attribute5,
	NULL,
	NULL,
	(select reporting_type_id FROM zx_reporting_types_b where tax_regime_code = l_tax_regime_code
	  and reporting_type_code = 'CL_DEBIT_ACCOUNT'),
	1)

	select
		avtb.global_attribute5,
		zxrb.tax_regime_code l_tax_regime_code  ,
		zxrb.effective_from  l_start_date
	from	ar_vat_tax_all_b avtb ,
  		zx_rates_b zxrb
     where      zxrb.tax_rate_id       = avtb.vat_tax_id
	and     avtb.global_attribute_category ='JL.CL.ARXSUVAT.VAT_TAX'
	and     avtb.global_attribute5 is not null
	and not exists
		( select 1 from zx_reporting_codes_b where reporting_type_id =
                      (select reporting_type_id FROM  zx_reporting_types_b
                          WHERE tax_regime_code = zxrb.tax_regime_code
                          AND   reporting_type_code = 'CL_DEBIT_ACCOUNT')
		          AND   reporting_code_char_value = avtb.global_attribute5);*/

	--Note: We have common logic to insert into Codes TL table
	--at the end  of CREATE_ZX_REP_TYPE_CODES procedure.


--Bug Fix 4466085
--Creation of Reporting Types Usages  for Reporting Type ZX_ADJ_TAX_CLASSIF_CODE

INSERT INTO ZX_REPORT_TYPES_USAGES(
		REPORTING_TYPE_USAGE_ID	,
		ENTITY_CODE		,
		ENABLED_FLAG		,
		CREATED_BY		,
		CREATION_DATE		,
		LAST_UPDATED_BY		,
		LAST_UPDATE_DATE	,
		LAST_UPDATE_LOGIN	,
		REPORTING_TYPE_ID	,
		OBJECT_VERSION_NUMBER
	)
	SELECT  zx_report_types_usages_s.nextval,--REPORTING_TYPE_USAGE_ID
	        lookups.lookup_code     , --ENTITY_CODE --Bug 5528045
		DECODE(lookups.lookup_code,
                'ZX_RATES','Y',
                'N')                    ,--ENABLED_FLAG --Bug 5528045
		fnd_global.user_id      ,--CREATED_BY
		SYSDATE                 ,--CREATION_DATE
		fnd_global.user_id      ,--LAST_UPDATED_BY
		SYSDATE                 ,--LAST_UPDATE_DATE
		fnd_global.conc_login_id,--LAST_UPDATE_LOGIN
		reporting_type_id	,--REPORTING_TYPE_ID
		1
	FROM
		zx_reporting_types_b rep_type,
		fnd_lookups          lookups
	WHERE
	          reporting_type_code = 'ZX_ADJ_TAX_CLASSIF_CODE'
        AND       record_type_code    = 'MIGRATED'
        AND     lookup_type = 'ZX_REPORTING_TABLE_USE'
        AND  NOT EXISTS ( select 1 from zx_report_types_usages
                      where reporting_type_id = rep_type.reporting_type_id
                      and entity_code = lookups.lookup_code );




--Creation Of Reporting Type Usages for


 INSERT INTO ZX_REPORTING_TYPES_TL(
           REPORTING_TYPE_ID      ,
           LANGUAGE               ,
           SOURCE_LANG            ,
           REPORTING_TYPE_NAME    ,
           CREATED_BY             ,
           CREATION_DATE          ,
           LAST_UPDATED_BY        ,
           LAST_UPDATE_DATE       ,
           LAST_UPDATE_LOGIN
          )

     SELECT
        REPORTING_TYPE_ID       ,
        LANGUAGE_CODE           ,
        userenv('LANG')         ,
    CASE WHEN REPORTING_TYPE_NAME = UPPER(REPORTING_TYPE_NAME)
     THEN    Initcap(REPORTING_TYPE_NAME)
     ELSE
             REPORTING_TYPE_NAME
     END,
                fnd_global.user_id             ,
                SYSDATE                        ,
                fnd_global.user_id             ,
                SYSDATE                        ,
                fnd_global.conc_login_id

     FROM
     (
        SELECT
           types.REPORTING_TYPE_ID ,
           L.LANGUAGE_CODE         ,
           CASE
           WHEN types.REPORTING_TYPE_CODE = 'PT_PRD_REC_TAX_BOX'
           THEN 'Periodic: Tax Box'
           WHEN types.REPORTING_TYPE_CODE = 'PT_ANL_REC_TAXABLE'
           THEN 'Annual: Taxable'
           WHEN types.REPORTING_TYPE_CODE = 'PT_ANL_REC_TAX_BOX'
           THEN 'Annual: Tax Box'
           WHEN types.REPORTING_TYPE_CODE = 'AR_MUNICIPAL_JUR'
           THEN 'Municipal Jurisdiction'
           WHEN types.REPORTING_TYPE_CODE = 'CL_TAX_CODE_CLASSIF'
           THEN 'Tax Code Classification'
           WHEN types.REPORTING_TYPE_CODE = 'AR_TURN_OVER_JUR_CODE'
           THEN 'Turnover Jurisdiction Code'
           WHEN types.REPORTING_TYPE_CODE = 'CL_BILLS_OF_EXCH_TAX'
           THEN 'Bills of Exchange Tax'
           WHEN types.REPORTING_TYPE_CODE = 'PRINT TAX LINE'
           THEN 'Print Tax Line'
           --Bug 4705196
           --WHEN  types.REPORTING_TYPE_CODE = 'PRINTED_TAX_RATE_NAME' --Bug 4422813
           --THEN 'Printed Tax Rate Name'
	   WHEN  types.REPORTING_TYPE_CODE = 'ZX_ADJ_TAX_CLASSIF_CODE' --Bug 4466085
           THEN 'Adjustment Tax Classification Code'
	   WHEN  types.REPORTING_TYPE_CODE = 'KR_BUSINESS_LOCATIONS'   --Bug 4671652
	   THEN 'Korean Business Locations'
	     ELSE types.REPORTING_TYPE_CODE   END REPORTING_TYPE_NAME -- Bug 4886324
           FROM
                        ZX_REPORTING_TYPES_B TYPES,
                        FND_LANGUAGES L
                WHERE

                 TYPES.RECORD_TYPE_CODE = 'MIGRATED'
        AND   L.INSTALLED_FLAG in ('I', 'B')
        ) TYPES

        WHERE REPORTING_TYPE_NAME is not null
        AND  not exists
            (select NULL
            from ZX_REPORTING_TYPES_TL T
            where T.REPORTING_TYPE_ID = TYPES.REPORTING_TYPE_ID
            and T.LANGUAGE = TYPES.LANGUAGE_CODE);

    -- Creation of records in Reporting_Usages
    INSERT INTO ZX_REPORT_TYPES_USAGES(
          REPORTING_TYPE_USAGE_ID,
          REPORTING_TYPE_ID      ,
          ENTITY_CODE            ,
          ENABLED_FLAG           ,
          CREATED_BY             ,
          CREATION_DATE          ,
          LAST_UPDATED_BY        ,
          LAST_UPDATE_DATE       ,
          LAST_UPDATE_LOGIN	 ,
	   OBJECT_VERSION_NUMBER
          )
    SELECT
          zx_report_types_usages_s.nextval,--REPORTING_TYPE_USAGE_ID
          types.reporting_type_id         ,--REPORTING_TYPE_ID
          lookups.lookup_code             ,--ENTITY_CODE
          DECODE(lookups.lookup_code,
                'ZX_RATES','Y',            --Bug 5528045
                'N')             ,--ENABLED_FLAG
          fnd_global.user_id     ,
          SYSDATE                ,
          fnd_global.user_id     ,
          SYSDATE                ,
          fnd_global.conc_login_id,
	  1
     FROM
          zx_reporting_types_b types,
          fnd_lookups        lookups

    WHERE   types.reporting_type_code IN(
					    'AR_MUNICIPAL_JUR',
					    'CL_TAX_CODE_CLASSIF',
					    'AR_TURN_OVER_JUR_CODE',
					    'CL_BILLS_OF_EXCH_TAX',
					    'PRINT TAX LINE',
                                            'KR_LOCATION'  --YK:9/22/2004: Korean GDF
						)
    AND  lookups.LOOKUP_TYPE       = 'ZX_REPORTING_TABLE_USE'
    AND   types.record_type_code    = 'MIGRATED'
    AND  NOT EXISTS ( select 1 from zx_report_types_usages
                      where reporting_type_id = types.reporting_type_id
                      and entity_code = lookups.lookup_code );

    -- Call the common procedure to create the reporting codes
      -- Commented the Call for Bug 4874049
--    CREATE_REPORTING_CODES('PT_LOCATION', 'JLZZ_AP_DGI_TRX_CODE');

 /*FOR i IN 1..3
   LOOP
     IF ( i = 1 ) THEN l_lookup_code := 'A' ;
     ELSIF ( i = 2 ) THEN l_lookup_code := 'C';
     ELSE  l_lookup_code := 'M';
     END IF ;

     INSERT
    INTO  ZX_REPORTING_CODES_B(
		REPORTING_CODE_ID      ,
		EXCEPTION_CODE         ,
		EFFECTIVE_FROM         ,
		EFFECTIVE_TO           ,
		RECORD_TYPE_CODE       ,
		CREATED_BY                     ,
		CREATION_DATE                  ,
		LAST_UPDATED_BY                ,
		LAST_UPDATE_DATE               ,
		LAST_UPDATE_LOGIN              ,
		REQUEST_ID                     ,
		PROGRAM_APPLICATION_ID         ,
		PROGRAM_ID                     ,
		PROGRAM_LOGIN_ID		  ,
		REPORTING_CODE_CHAR_VALUE	  ,
		REPORTING_CODE_DATE_VALUE      ,
		REPORTING_CODE_NUM_VALUE       ,
		REPORTING_TYPE_ID		,
		OBJECT_VERSION_NUMBER
	   )
    SELECT
           zx_reporting_codes_b_s.nextval,--REPORTING_CODE_ID
           NULL                          ,--EXCEPTION_CODE
           report_types.EFFECTIVE_FROM                ,
           NULL                          ,--EFFECTIVE_TO
          'MIGRATED'                     ,--RECORD_TYPE_CODE
           fnd_global.user_id            ,
           SYSDATE                       ,
           fnd_global.user_id            ,
           SYSDATE                       ,
           fnd_global.conc_login_id      ,
           fnd_global.conc_request_id    , -- Request Id
           fnd_global.prog_appl_id       , -- Program Application ID
           fnd_global.conc_program_id    , -- Program Id
           fnd_global.conc_login_id      ,  -- Program Login ID
           l_lookup_code,
	   NULL,
	   NULL,
	   report_types.REPORTING_TYPE_ID,
	   1
    FROM
	ZX_REPORTING_TYPES_B report_types
    WHERE
	report_types.REPORTING_TYPE_CODE = 'PT_LOCATION'
	AND  report_types.RECORD_TYPE_CODE    = 'MIGRATED'
	AND  NOT EXISTS
	(SELECT 1 FROM ZX_REPORTING_CODES_B WHERE
	REPORTING_TYPE_ID   = report_types.REPORTING_TYPE_ID AND
	REPORTING_CODE_CHAR_VALUE= l_lookup_code
	);
  END LOOP ; */
-- End for the bug 4874049.


    CREATE_REPORTING_CODES('CL_TAX_CODE_CLASSIF', 'JLCL_TAX_CODE_CLASS');

    --Bug Fix 4930895 Populate FND_LOOKUPS.MEANING INTO REPORTING_CODE_NAME
    -- Moved this logic to common procedure CREATE_REPORTING_CODES
    /*
    INSERT INTO ZX_REPORTING_CODES_TL (
           REPORTING_CODE_ID      ,
           LANGUAGE               ,
           SOURCE_LANG            ,
           REPORTING_CODE_NAME    ,
           CREATED_BY             ,
           CREATION_DATE          ,
           LAST_UPDATED_BY        ,
           LAST_UPDATE_DATE       ,
           LAST_UPDATE_LOGIN
          )
     SELECT
           codes.reporting_code_id ,
           lookups.language        ,
           lookups.source_lang     ,
           lookups.meaning         ,
           fnd_global.user_id      ,
           sysdate                 ,
           fnd_global.user_id      ,
           sysdate                 ,
           fnd_global.conc_login_id
      FROM
	   ZX_REPORTING_TYPES_B  TYPES,
           ZX_REPORTING_CODES_B  CODES,
	   FND_LOOKUP_VALUES    lookups,
	   FND_LANGUAGES L
      WHERE
           TYPES.REPORTING_TYPE_ID     = CODES.REPORTING_TYPE_ID
      AND  TYPES.REPORTING_TYPE_CODE   = 'CL_TAX_CODE_CLASSIF'
      AND  lookups.LOOKUP_TYPE         = 'JLCL_TAX_CODE_CLASS'
      AND  codes.REPORTING_CODE_CHAR_VALUE = lookups.lookup_code
      AND  CODES.RECORD_TYPE_CODE      = 'MIGRATED'
      AND  lookups.VIEW_APPLICATION_ID = 0
      AND  lookups.SECURITY_GROUP_ID   = 0
      AND  lookups.LANGUAGE            = L.LANGUAGE_CODE(+)
      AND  L.INSTALLED_FLAG in ('I', 'B')
      AND  not exists
               (select NULL
                from ZX_REPORTING_CODES_TL  T
                where T.REPORTING_CODE_ID = CODES.REPORTING_CODE_ID
                and T.LANGUAGE = L.LANGUAGE_CODE);
      */

    CREATE_REPORTING_CODES('AR_TURN_OVER_JUR_CODE', 'JLZZ_AR_TO_JURISDICTION_CODE');

    --Bug Fix 4930895 Populate FND_LOOKUPS.MEANING INTO REPORTING_CODE_NAME
    -- Moved this logic to common procedure CREATE_REPORTING_CODES
    /*
    INSERT INTO ZX_REPORTING_CODES_TL (
            REPORTING_CODE_ID      ,
            LANGUAGE               ,
            SOURCE_LANG            ,
            REPORTING_CODE_NAME    ,
            CREATED_BY             ,
            CREATION_DATE          ,
            LAST_UPDATED_BY        ,
            LAST_UPDATE_DATE       ,
            LAST_UPDATE_LOGIN
           )
     SELECT
            codes.reporting_code_id ,
            lookups.language        ,
            lookups.source_lang     ,
            lookups.meaning         ,
            fnd_global.user_id      ,
            sysdate                 ,
            fnd_global.user_id      ,
            sysdate                 ,
            fnd_global.conc_login_id
     FROM
           ZX_REPORTING_TYPES_B   TYPES,
           ZX_REPORTING_CODES_B   CODES,
           FND_LOOKUP_VALUES    lookups,
           FND_LANGUAGES L
     WHERE
            TYPES.REPORTING_TYPE_ID     = CODES.REPORTING_TYPE_ID
       AND  TYPES.REPORTING_TYPE_CODE   = 'AR_TURN_OVER_JUR_CODE'
       AND  lookups.LOOKUP_TYPE         = 'JLZZ_AR_TO_JURISDICTION_CODE'
       AND  lookups.lookup_code          = codes.REPORTING_CODE_CHAR_VALUE
       AND  CODES.RECORD_TYPE_CODE      = 'MIGRATED'
       AND  lookups.VIEW_APPLICATION_ID = 0
       AND  lookups.SECURITY_GROUP_ID   = 0
       AND  lookups.LANGUAGE            = L.LANGUAGE_CODE(+)
       AND  L.INSTALLED_FLAG in ('I', 'B')
       AND  not exists
                (select NULL
                 from ZX_REPORTING_CODES_TL  T
                 where T.REPORTING_CODE_ID = CODES.REPORTING_CODE_ID
                 and T.LANGUAGE = L.LANGUAGE_CODE);
    */

    -- YK:9/22/2004: Korean GDF: Reporting Code creation
    INSERT
    INTO   ZX_REPORTING_CODES_B(
           REPORTING_CODE_ID      ,
           REPORTING_CODE_CHAR_VALUE,
           REPORTING_CODE_NUM_VALUE,
           REPORTING_CODE_DATE_VALUE,
           REPORTING_TYPE_ID,
           EXCEPTION_CODE         ,
           EFFECTIVE_FROM         ,
           EFFECTIVE_TO           ,
           RECORD_TYPE_CODE       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID		  ,
	   OBJECT_VERSION_NUMBER
           )
    SELECT
           zx_reporting_codes_b_s.nextval,--REPORTING_CODE_ID
           global_attribute       ,--REPORTING_CODE_CHAR_VALUE
           NULL                   ,--REPORTING_CODE_NUM_VALUE
           NULL                   ,--REPORTING_CODE_DATE_VALUE
           reporting_type_id      ,--REPORTING_TYPE_ID
           NULL                   ,--EXCEPTION_CODE
           effective_from         ,
           NULL                   ,--EFFECTIVE_TO
          'MIGRATED'              ,--RECORD_TYPE_CODE
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     , -- Request
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       , -- Program Login ID
	   1
    FROM
    (
    SELECT
           DISTINCT
           locations.location_code      global_attribute,
           types.reporting_type_id      reporting_type_id,
           types.effective_from         effective_from
    FROM
        zx_reporting_types_b types,
        hr_locations         locations
    WHERE
             types.reporting_type_code       = 'KR_LOCATION'
    AND  types.record_type_code          = 'MIGRATED'
    AND  locations.global_attribute_category = 'JA.KR.PERWSLOC.WITHHOLDING'
    AND  locations.global_attribute1  IS NOT NULL

    AND  (NOT EXISTS (select 1 from zx_reporting_codes_b
                      where  reporting_type_id = types.reporting_type_id
                      and    reporting_code_char_value  = locations.location_code
							   /*(select location_code
                                                           from   hr_locations
                                                           where  global_attribute_category = 'JA.KR.PERWSLOC.WITHHOLDING'
                                                           and    global_attribute1 is not null)*/
                      )
         )

    );  --YK:9/22/2004: Synch is taken care by checking NOT EXISTS.
   /* Bug 5031787
    INSERT INTO ZX_REPORTING_CODES_TL(
           REPORTING_CODE_ID      ,
           LANGUAGE               ,
           SOURCE_LANG            ,
           REPORTING_CODE_NAME    ,
           CREATED_BY             ,
           CREATION_DATE          ,
           LAST_UPDATED_BY        ,
           LAST_UPDATE_DATE       ,
           LAST_UPDATE_LOGIN
          )
    SELECT
           codes.reporting_code_id ,
           lookups.language        ,
           lookups.source_lang     ,
           lookups.meaning         ,
           fnd_global.user_id      ,
           sysdate                 ,
           fnd_global.user_id      ,
           sysdate                 ,
           fnd_global.conc_login_id
    FROM
	  ZX_REPORTING_TYPES_B TYPES,
          ZX_REPORTING_CODES_B CODES,
          FND_LOOKUP_VALUES    lookups,
	  FND_LANGUAGES L
    WHERE

           TYPES.REPORTING_TYPE_ID     = CODES.REPORTING_TYPE_ID
      AND  TYPES.REPORTING_TYPE_CODE   = 'KR_LOCATION'
      AND  TYPES.REPORTING_TYPE_CODE   = lookups.LOOKUP_TYPE
      AND  CODES.RECORD_TYPE_CODE      = 'MIGRATED'
      AND  lookups.VIEW_APPLICATION_ID = 0
      AND  lookups.SECURITY_GROUP_ID   = 0
      AND  lookups.LANGUAGE            = L.LANGUAGE_CODE(+)
      AND  L.INSTALLED_FLAG in ('I', 'B')
      AND  not exists
               (select NULL
                from ZX_REPORTING_CODES_TL T
                where T.REPORTING_CODE_ID = CODES.REPORTING_CODE_ID
                and T.LANGUAGE = L.LANGUAGE_CODE);
		*/
   -- End of Korean GDF


--Bug Fix 4671652
--Creation of Reporting Types for KR_BUSINESS_LOCATIONS

INSERT ALL
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code= 'KR_BUSINESS_LOCATIONS'
                       and    tax_regime_code = l_tax_regime_code
	  )
          ) THEN
    INTO  ZX_REPORTING_TYPES_B(
		REPORTING_TYPE_ID              ,
		REPORTING_TYPE_CODE            ,
		REPORTING_TYPE_DATATYPE_CODE   ,
		TAX_REGIME_CODE                ,
		TAX                            ,
		FORMAT_MASK                    ,
		MIN_LENGTH                     ,
		MAX_LENGTH                     ,
		LEGAL_MESSAGE_FLAG             ,
		EFFECTIVE_FROM                 ,
		EFFECTIVE_TO                   ,
		RECORD_TYPE_CODE               ,
		HAS_REPORTING_CODES_FLAG       ,
		CREATED_BY                     ,
		CREATION_DATE                  ,
		LAST_UPDATED_BY                ,
		LAST_UPDATE_DATE               ,
		LAST_UPDATE_LOGIN              ,
		REQUEST_ID                     ,
		PROGRAM_APPLICATION_ID         ,
		PROGRAM_ID                     ,
		PROGRAM_LOGIN_ID		,
		OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_reporting_types_b_s.nextval ,--REPORTING_TYPE_ID
          'KR_BUSINESS_LOCATIONS'       ,--REPORTING_TYPE_CODE
           --'VARCHAR'	                  ,--REPORTING_TYPE_DATATYPE
	   'TEXT'	                  ,--REPORTING_TYPE_DATATYPE (Bug6430516)
           l_tax_regime_code              ,--TAX_REGIME_CODE
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                              ,--MIN_LENGTH
           30                             ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,--EFFECTIVE_FROM
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
           'Y'				  ,--HAS_REPORTING_CODES_FLAG
           fnd_global.user_id             ,--CREATED_BY
           SYSDATE                        ,--CREATION_DATE
           fnd_global.user_id             ,--LAST_UPDATED_BY
           SYSDATE                        ,--LAST_UPDATE_DATE
           fnd_global.conc_login_id       ,--LAST_UPDATE_LOGIN
           fnd_global.conc_request_id     , -- Request Id
           fnd_global.prog_appl_id        , -- Program Application ID
           fnd_global.conc_program_id     , -- Program Id
           fnd_global.conc_login_id       ,  -- Program Login ID
	   1
          )
    SELECT
           min(zx_rates.effective_from) effective_from,
           zx_rates.tax_regime_code     l_tax_regime_code

    FROM
        ar_vat_tax_all_b           ar_vat,
        zx_rates_b                 zx_rates
    WHERE
            ar_vat.vat_tax_id             = zx_rates.tax_rate_id
    AND  ar_vat.global_attribute_category = 'JA.KR.ARXSUVAT.VAT'
    AND  zx_rates.record_type_code      = 'MIGRATED'
    AND  ar_vat.vat_tax_id            = nvl(p_tax_id, ar_vat.vat_tax_id)
    GROUP BY
          zx_rates.tax_regime_code;

--Bug Fix 4671652
--Creation of Reporting Codes for KR_BUSINESS_LOCATIONS

INSERT ALL
	INTO
	ZX_REPORTING_CODES_B
	(
	 REPORTING_CODE_ID ,
	 EXCEPTION_CODE    ,
	 EFFECTIVE_FROM    ,
	 EFFECTIVE_TO      ,
	 RECORD_TYPE_CODE  ,
	 CREATED_BY        ,
	 CREATION_DATE     ,
	 LAST_UPDATED_BY   ,
	 LAST_UPDATE_DATE  ,
	 LAST_UPDATE_LOGIN,
	 REQUEST_ID       ,
	 PROGRAM_APPLICATION_ID,
	 PROGRAM_ID            ,
	 PROGRAM_LOGIN_ID      ,
	 REPORTING_CODE_CHAR_VALUE,
	 REPORTING_CODE_DATE_VALUE,
	 REPORTING_CODE_NUM_VALUE ,
	 REPORTING_TYPE_ID        ,
	 OBJECT_VERSION_NUMBER
	)
	VALUES
	(
	ZX_REPORTING_CODES_B_S.NEXTVAL,
	NULL,
	l_start_date,
	NULL,
	'MIGRATED',
	FND_GLOBAL.USER_ID,
	SYSDATE,
	FND_GLOBAL.USER_ID,
	SYSDATE,
	fnd_global.conc_login_id      ,
	fnd_global.conc_request_id    , -- Request Id
	fnd_global.prog_appl_id       , -- Program Application ID
	fnd_global.conc_program_id    , -- Program Id
	fnd_global.conc_login_id      ,  -- Program Login ID
	l_location_code,
	NULL,
	NULL,
	(select reporting_type_id FROM zx_reporting_types_b where tax_regime_code = l_tax_regime_code
	  and reporting_type_code = 'KR_BUSINESS_LOCATIONS'),
	1)

    select
        distinct
		tax_id_values_and_codes.location_code l_location_code,
		zxrb.tax_regime_code l_tax_regime_code  ,
		(SELECT min(r.effective_from) FROM zx_rates_b r WHERE r.tax_regime_code = zxrb.tax_regime_code)  l_start_date
     from
               (
               select vat_tax_id,hrloc.location_code location_code
			   from  ar_vat_tax_all_b artax, hr_locations hrloc
			   where artax.global_attribute_category = 'JA.KR.ARXSUVAT.VAT'  -- Bug 5031787
                           and   artax.global_attribute1 = to_char(hrloc.location_id)
			   ) tax_id_values_and_codes,
                 zx_rates_b zxrb
    where zxrb.tax_rate_id               = tax_id_values_and_codes.vat_tax_id
    and   tax_id_values_and_codes.vat_tax_id = nvl(p_tax_id,tax_id_values_and_codes.vat_tax_id)
	and   tax_id_values_and_codes.location_code is not null
	and not exists
		( select 1 from zx_reporting_codes_b where reporting_type_id =
		                      (select reporting_type_id FROM  zx_reporting_types_b
					                                    WHERE tax_regime_code = zxrb.tax_regime_code
		                                                AND   reporting_type_code = 'KR_BUSINESS_LOCATIONS')
		  AND reporting_code_char_value = tax_id_values_and_codes.location_code);


--Bug Fix 4671652
--Creation of Reporting Codes Associations for KR_BUSINESS_LOCATIONS

 INSERT
   INTO   ZX_REPORT_CODES_ASSOC(
          REPORTING_CODE_ASSOC_ID,
          ENTITY_CODE            ,
          ENTITY_ID              ,
          REPORTING_TYPE_ID      ,
          REPORTING_CODE_ID      ,
          EXCEPTION_CODE         ,
          EFFECTIVE_FROM         ,
          EFFECTIVE_TO           ,
          CREATED_BY             ,
          CREATION_DATE          ,
          LAST_UPDATED_BY        ,
          LAST_UPDATE_DATE       ,
          LAST_UPDATE_LOGIN	 ,
	  REPORTING_CODE_CHAR_VALUE,
	  REPORTING_CODE_DATE_VALUE,
	  REPORTING_CODE_NUM_VALUE,
	  OBJECT_VERSION_NUMBER
				)
    SELECT
          ZX_REPORT_CODES_ASSOC_S.nextval  ,
         'ZX_RATES'                        ,--ENTITY_CODE
          TAX_RATE_ID                      ,--ENTITY_ID
          REPORTING_TYPE_ID              ,
          REPORTING_CODE_ID                   ,
          NULL                             ,--EXCEPTION_CODE
          EFFECTIVE_FROM                   ,
          NULL                             ,--EFFECTIVE_TO
          fnd_global.user_id               ,
          SYSDATE                          ,
          fnd_global.user_id               ,
          SYSDATE                          ,
          fnd_global.conc_login_id	   ,
	  REPORTING_CODE_CHAR_VALUE,
	  REPORTING_CODE_DATE_VALUE,
 	  REPORTING_CODE_NUM_VALUE,
	  1
    FROM
    (
    SELECT
          rates.TAX_RATE_ID                       TAX_RATE_ID,
          report_codes.REPORTING_CODE_ID          REPORTING_CODE_ID,
          rates.EFFECTIVE_FROM             EFFECTIVE_FROM,
	  report_codes.REPORTING_TYPE_ID          REPORTING_TYPE_ID,
	  report_codes.REPORTING_CODE_CHAR_VALUE  REPORTING_CODE_CHAR_VALUE ,
	  report_codes.REPORTING_CODE_DATE_VALUE  REPORTING_CODE_DATE_VALUE,
 	  report_codes.REPORTING_CODE_NUM_VALUE   REPORTING_CODE_NUM_VALUE
    FROM
      AR_VAT_TAX_ALL_B codes,
      HR_LOCATIONS     hrloc,
      ZX_RATES_B       rates,
      ZX_REPORTING_TYPES_B  reporting_types,
      ZX_REPORTING_CODES_B report_codes
    WHERE
         codes.vat_tax_id                =  rates.tax_rate_id
    AND  codes.vat_tax_id                =  nvl(p_tax_id,codes.vat_tax_id)
    AND  codes.global_attribute1         =  TO_CHAR(hrloc.location_id)
    AND  codes.global_attribute_category = 'JA.KR.ARXSUVAT.VAT'
    AND  hrloc.location_code             =  report_codes.REPORTING_CODE_CHAR_VALUE
    AND  rates.record_type_code          = 'MIGRATED'
    AND  rates.tax_regime_code           =  reporting_types.tax_regime_code
    AND  reporting_types.reporting_type_code = 'KR_BUSINESS_LOCATIONS'
    AND  reporting_types.reporting_type_id = report_codes.reporting_type_id
    AND  report_codes.record_type_code   = 'MIGRATED'

    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id   =
                           report_codes.reporting_type_id)
     );


--Bug Fix 4716057
/*
--   Bug Fix 4671652
--   Creation of reporting types usages for KR_BUSINESS_LOCATIONS


     INSERT INTO ZX_REPORT_TYPES_USAGES(
		REPORTING_TYPE_USAGE_ID	,
		ENTITY_CODE		,
		ENABLED_FLAG		,
		CREATED_BY		,
		CREATION_DATE		,
		LAST_UPDATED_BY		,
		LAST_UPDATE_DATE	,
		LAST_UPDATE_LOGIN	,
		REPORTING_TYPE_ID	,
		OBJECT_VERSION_NUMBER
	)
	SELECT  zx_report_types_usages_s.nextval,--REPORTING_TYPE_USAGE_ID
		'ZX_RATES_B'		,--ENTITY_CODE
		 'Y'                     ,--ENABLED_FLAG
		fnd_global.user_id      ,--CREATED_BY
		SYSDATE                 ,--CREATION_DATE
		fnd_global.user_id      ,--LAST_UPDATED_BY
		SYSDATE                 ,--LAST_UPDATE_DATE
		fnd_global.conc_login_id,--LAST_UPDATE_LOGIN
		reporting_type_id	,--REPORTING_TYPE_ID
		1

	FROM
		zx_reporting_types_b rep_type

	WHERE
	          reporting_type_code = 'KR_BUSINESS_LOCATIONS'
	AND  NOT EXISTS ( select 1 from zx_report_types_usages
			where reporting_type_id = rep_type.reporting_type_id and
			entity_code = 'ZX_RATES_B' );
*/

   IF PG_DEBUG = 'Y' THEN
	arp_util_tax.debug('CREATE_ZX_REP_TYPE_CODES_AR(-)');
   END IF;



END CREATE_ZX_REP_TYPE_CODES_AR;



/*=========================================================================+
 | PROCEDURE                                                               |
 |    ZX_CREATE_REP_ASSOCIATION_PTP                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 |    Used to create the reporting type associations			   |
 |    for various entities like						   |
 |				1.HR Organization Information              |
 |				2.Hr Locations				   |
 |				3.AR System Parameters All		   |
 |				4.Financial Systems Parameters All         |
 |                                                                         |
 | SCOPE - PUBLIC                                                          |
 |                                                                         |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                  |
 |                                                                         |
 | CALLED FROM                                                             |
 |     REG_REP_DRIVER_PROC                                                 |
 | NOTES                                                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     23-Sep-04  Arnab Sengupta      Created.                             |
 |                                                                         |
 |=========================================================================*/


PROCEDURE ZX_CREATE_REP_ASSOCIATION_PTP
(

p_rep_type_info		 varchar2,
p_ptp_id                 zx_party_tax_profile.party_tax_profile_id%type,
p_reporting_type_code    zx_reporting_types_b.reporting_type_code%type
)

IS

BEGIN
arp_util_tax.debug('ZX_CREATE_REP_ASSOCIATION_PTP(+)');
arp_util_tax.debug('p_rep_type_info='||p_rep_type_info);

INSERT INTO ZX_REPORT_CODES_ASSOC(
		REPORTING_CODE_ASSOC_ID,
		ENTITY_CODE,
		ENTITY_ID,
		REPORTING_TYPE_ID,
		REPORTING_CODE_CHAR_VALUE,
		EXCEPTION_CODE,
		EFFECTIVE_FROM,
		EFFECTIVE_TO,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
                OBJECT_VERSION_NUMBER)
	SELECT
		ZX_REPORT_CODES_ASSOC_S.nextval, --REPORTING_CODE_ASSOC_ID
		'ZX_PARTY_TAX_PROFILE' ,	 --ENTITY_CODE
		p_ptp_id			, --ENTITY_ID
		REPORTING_TYPE_ID	,	 --REPORTING_TYPE_ID
		p_rep_type_info,	         --REPORTING_CODE_CHAR_VALUE
		null,				 --EXCEPTION_CODE
		sysdate,			 --EFFECTIVE_FROM
		null,				 --EFFECTIVE_TO
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		sysdate,
		fnd_global.conc_login_id,
		1

	FROM	ZX_REPORTING_TYPES_B
	WHERE   REPORTING_TYPE_CODE=p_reporting_type_code

	AND NOT EXISTS (SELECT 1 FROM
				ZX_REPORTING_TYPES_B RTB,
				ZX_REPORT_CODES_ASSOC RCA
			 WHERE

			       RTB.REPORTING_TYPE_ID = RCA.REPORTING_TYPE_ID
		         AND   RTB.REPORTING_TYPE_CODE = p_reporting_type_code
			 AND   RCA.ENTITY_ID = p_ptp_id
			 AND   RCA.REPORTING_CODE_CHAR_VALUE = p_rep_type_info);


arp_util_tax.debug('ZX_CREATE_REP_ASSOCIATION_PTP(-)');
END ZX_CREATE_REP_ASSOCIATION_PTP;


/*=========================================================================+
 | PROCEDURE                                                               |
 |    ZX_CREATE_REPORT_TYPE_PTP                                            |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 |    Used to create the reporting types.				   |
 |									   |
 |									   |
 |									   |
 |									   |
 |                                                                         |
 | SCOPE - PUBLIC                                                          |
 |                                                                         |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                  |
 |                                                                         |
 | CALLED FROM                                                             |
 |									   |
 | NOTES                                                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     23-Sep-04  Arnab Sengupta      Created.                             |
 |                                                                         |
 |=========================================================================*/
PROCEDURE  CREATE_REPORT_TYPE_PTP
	(
	p_reporting_type_code 	IN  ZX_REPORTING_TYPES_B.REPORTING_TYPE_CODE %TYPE,
	p_datatype		IN  ZX_REPORTING_TYPES_B.REPORTING_TYPE_DATATYPE_CODE%TYPE,
	p_has_rep_code		IN  ZX_REPORTING_TYPES_B.HAS_REPORTING_CODES_FLAG%TYPE
	)
IS

BEGIN

arp_util_tax.debug('CREATE_REPORT_TYPE_PTP(+)');
arp_util_tax.debug('p_reporting_type_code='||p_reporting_type_code);

INSERT
  INTO   ZX_REPORTING_TYPES_B(
           REPORTING_TYPE_ID              ,
	   REPORTING_TYPE_CODE            ,
   	   REPORTING_TYPE_DATATYPE_CODE   ,
   	   TAX_REGIME_CODE                ,
	   TAX                            ,
	   FORMAT_MASK                    ,
	   MIN_LENGTH                     ,
	   MAX_LENGTH                     ,
	   LEGAL_MESSAGE_FLAG             ,
	   EFFECTIVE_FROM                 ,
	   EFFECTIVE_TO                   ,
	   RECORD_TYPE_CODE               ,
           HAS_REPORTING_CODES_FLAG       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID		  ,
	   OBJECT_VERSION_NUMBER
           )
   SELECT
           zx_reporting_types_b_s.nextval, 	--REPORTING_TYPE_ID
           p_reporting_type_code,               --REPORTING_TYPE_CODE
           p_datatype,			        --REPORTING_TYPE_DATATYPE
	   NULL,			        --TAX REGIME CODE
           NULL,				--TAX
           NULL,				--FORMAT_MASK
           1,					--MIN_LENGTH
           30,					--MAX_LENGTH
          'N',					--LEGAL_MESSAGE_FLAG
           SYSDATE,				--EFFECTIVE_FROM
           NULL,				--EFFECTIVE_TO
          'MIGRATED',				--RECORD_TYPE_CODE
           p_has_rep_code	          ,     --HAS_REPORTING_CODES_FLAG
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.user_id             ,
           SYSDATE                        ,
           fnd_global.conc_login_id       ,
           fnd_global.conc_request_id     ,	 -- Request Id
           fnd_global.prog_appl_id        ,	 -- Program Application ID
           fnd_global.conc_program_id     ,	 -- Program Id
           fnd_global.conc_login_id	  , 	 -- Program Login ID
	   1

     FROM  DUAL

     WHERE NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code= p_reporting_type_code
                       and    tax_regime_code IS NULL);


     arp_util_tax.debug('CREATE_REPORT_TYPE_PTP(+)');
END CREATE_REPORT_TYPE_PTP;

/*=========================================================================+
 | PROCEDURE                                                               |
 |    CREATE_REPORT_TYPE_SEED                                            |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 |    Used to create seeded reporting types.				   |
 |									   |
 |									   |
 |									   |
 |									   |
 |                                                                         |
 | SCOPE - PRIVATE                                                          |
 |                                                                         |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                  |
 |                                                                         |
 | CALLED FROM    : CREATE_SEEDED_REPORTING_TYPES                          |
 |									   |
 | NOTES                                                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     25-May-2006  Ashwin Gurram      Created.                             |
 |                                                                         |
 |=========================================================================*/
PROCEDURE  CREATE_REPORT_TYPE_SEED
	(
	p_reporting_type_code 	IN  ZX_REPORTING_TYPES_B.REPORTING_TYPE_CODE %TYPE,
	p_datatype		IN  ZX_REPORTING_TYPES_B.REPORTING_TYPE_DATATYPE_CODE%TYPE,
	p_has_rep_code		IN  ZX_REPORTING_TYPES_B.HAS_REPORTING_CODES_FLAG%TYPE
	)
IS

BEGIN

arp_util_tax.debug('CREATE_REPORT_TYPE_PTP(+)');
arp_util_tax.debug('p_reporting_type_code='||p_reporting_type_code);

INSERT
  INTO   ZX_REPORTING_TYPES_B(
           REPORTING_TYPE_ID              ,
	   REPORTING_TYPE_CODE            ,
   	   REPORTING_TYPE_DATATYPE_CODE   ,
   	   TAX_REGIME_CODE                ,
	   TAX                            ,
	   FORMAT_MASK                    ,
	   MIN_LENGTH                     ,
	   MAX_LENGTH                     ,
	   LEGAL_MESSAGE_FLAG             ,
	   EFFECTIVE_FROM                 ,
	   EFFECTIVE_TO                   ,
	   RECORD_TYPE_CODE               ,
           HAS_REPORTING_CODES_FLAG       ,
           CREATED_BY                     ,
           CREATION_DATE                  ,
           LAST_UPDATED_BY                ,
           LAST_UPDATE_DATE               ,
           LAST_UPDATE_LOGIN              ,
           REQUEST_ID                     ,
           PROGRAM_APPLICATION_ID         ,
           PROGRAM_ID                     ,
           PROGRAM_LOGIN_ID		  ,
	   OBJECT_VERSION_NUMBER
           )
   SELECT
           zx_reporting_types_b_s.nextval, 	--REPORTING_TYPE_ID
           p_reporting_type_code,               --REPORTING_TYPE_CODE
           p_datatype,			        --REPORTING_TYPE_DATATYPE
	   NULL,			        --TAX REGIME CODE
           NULL,				--TAX
           NULL,				--FORMAT_MASK
           1,					--MIN_LENGTH
           30,					--MAX_LENGTH
          'N',					--LEGAL_MESSAGE_FLAG
           SYSDATE,				--EFFECTIVE_FROM
           NULL,				--EFFECTIVE_TO
          'SEEDED',				--RECORD_TYPE_CODE
           p_has_rep_code	          ,     --HAS_REPORTING_CODES_FLAG
           120             ,
           SYSDATE                        ,
           120             ,
           SYSDATE                        ,
           0       ,
           fnd_global.conc_request_id     ,	 -- Request Id
           fnd_global.prog_appl_id        ,	 -- Program Application ID
           fnd_global.conc_program_id     ,	 -- Program Id
           fnd_global.conc_login_id	  , 	 -- Program Login ID
	   1
     FROM  DUAL
     WHERE NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code= p_reporting_type_code
			);

-- Insert into ZX_REPORTING_TYPES_TL

    INSERT INTO ZX_REPORTING_TYPES_TL(
           REPORTING_TYPE_ID      ,
           LANGUAGE               ,
           SOURCE_LANG            ,
           REPORTING_TYPE_NAME    ,
           CREATED_BY             ,
           CREATION_DATE          ,
           LAST_UPDATED_BY        ,
           LAST_UPDATE_DATE       ,
           LAST_UPDATE_LOGIN
          )
     SELECT
     	REPORTING_TYPE_ID	,
     	LANGUAGE_CODE		,
     	userenv('LANG')    	,
	CASE WHEN REPORTING_TYPE_NAME = UPPER(REPORTING_TYPE_NAME)
	THEN    Initcap(REPORTING_TYPE_NAME)
	ELSE
	     REPORTING_TYPE_NAME
	END,
		120             ,
		SYSDATE                        ,
		120             ,
		SYSDATE                        ,
		0

     FROM
     (
        SELECT
           types.REPORTING_TYPE_ID ,
           L.LANGUAGE_CODE         ,
           CASE
           WHEN types.REPORTING_TYPE_CODE = 'PT_LOCATION'
           	THEN 'Location'
           WHEN types.REPORTING_TYPE_CODE = 'PT_PRD_TAXABLE_BOX'
           	THEN 'Periodic: Taxable Box'
           WHEN types.REPORTING_TYPE_CODE = 'PT_PRD_REC_TAX_BOX'
           	THEN 'Periodic: Recoverable Tax Box'
           WHEN types.REPORTING_TYPE_CODE = 'PT_ANL_TTL_TAXABLE_BOX'
           	THEN 'Annual: Total Taxable Box'
           WHEN types.REPORTING_TYPE_CODE = 'PT_ANL_REC_TAXABLE'
           	THEN 'Annual: Recoverable Taxable'
           WHEN types.REPORTING_TYPE_CODE = 'PT_ANL_NON_REC_TAXABLE'
           	THEN 'Annual: Non Recoverable Taxable'
           WHEN types.REPORTING_TYPE_CODE = 'PT_ANL_REC_TAX_BOX'
           	THEN 'Annual: Recoverable Tax Box'
           WHEN types.REPORTING_TYPE_CODE = 'AR_DGI_TRX_CODE'
           	THEN 'DGI Transaction Code'
           WHEN types.REPORTING_TYPE_CODE = 'FISCAL PRINTER'
           	THEN 'Fiscal Printer Used'
           WHEN types.REPORTING_TYPE_CODE = 'CAI NUMBER'
           	THEN 'CAI Number'
	   WHEN types.REPORTING_TYPE_CODE = 'TAX_CODE_CLASSIFICATION'
	   	THEN 'Tax Code Classification'
	   -- Bug # 4952838
	   WHEN types.REPORTING_TYPE_CODE = 'CZ_TAX_ORIGIN' or
	        types.REPORTING_TYPE_CODE = 'HU_TAX_ORIGIN' or
	        types.REPORTING_TYPE_CODE = 'PL_TAX_ORIGIN'
	   	THEN 'Tax Origin'
	   WHEN types.REPORTING_TYPE_CODE = 'CH_VAT_REGIME'
	   	THEN 'Tax Regime'
	   WHEN types.REPORTING_TYPE_CODE = 'CL_DEBIT_ACCOUNT'
	   	THEN 'Debit Account'
           WHEN types.REPORTING_TYPE_CODE = 'AR_MUNICIPAL_JUR'
	           THEN 'Municipal Jurisdiction'
           WHEN types.REPORTING_TYPE_CODE = 'CL_TAX_CODE_CLASSIF'
	           THEN 'Tax Code Classification'
           WHEN types.REPORTING_TYPE_CODE = 'AR_TURN_OVER_JUR_CODE'
	           THEN 'Turnover Jurisdiction Code'
           WHEN types.REPORTING_TYPE_CODE = 'CL_BILLS_OF_EXCH_TAX'
	           THEN 'Bills of Exchange Tax'
           WHEN types.REPORTING_TYPE_CODE = 'PRINT TAX LINE'
	           THEN 'Print Tax Line'
	   WHEN  types.REPORTING_TYPE_CODE = 'KR_BUSINESS_LOCATIONS'
		   THEN 'Korean Business Locations'
           ELSE  types.REPORTING_TYPE_CODE   END  REPORTING_TYPE_NAME

        FROM
	 ZX_REPORTING_TYPES_B TYPES,
	 FND_LANGUAGES L
	 WHERE
	        TYPES.RECORD_TYPE_CODE = 'SEEDED'
	AND L.INSTALLED_FLAG in ('I', 'B')
	) TYPES
	WHERE REPORTING_TYPE_NAME is not null
	AND  not exists
	    (select NULL
	    from ZX_REPORTING_TYPES_TL T
	    where T.REPORTING_TYPE_ID = TYPES.REPORTING_TYPE_ID
	    and T.LANGUAGE = TYPES.LANGUAGE_CODE);

     arp_util_tax.debug('CREATE_REPORT_TYPE_PTP(+)');

END CREATE_REPORT_TYPE_SEED;

/*=========================================================================+
 | PROCEDURE                                                               |
 |    CREATE_REPORTING_CODES_SEED                                          |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 |    Used to create seeded reporting types.				   |
 |									   |
 |									   |
 |									   |
 |									   |
 |                                                                         |
 | SCOPE - PRIVATE                                                         |
 |                                                                         |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                  |
 |                                                                         |
 | CALLED FROM    : CREATE_SEEDED_REPORTING_TYPES                          |
 |									   |
 | NOTES                                                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     25-May-2006  Ashwin Gurram      Created.                            |
 |                                                                         |
 |=========================================================================*/
PROCEDURE  CREATE_REPORTING_CODES_SEED (
	p_reporting_type_code 	IN  ZX_REPORTING_TYPES_B.REPORTING_TYPE_CODE %TYPE,
	P_lookup_type		IN  FND_LOOKUPS.LOOKUP_TYPE%TYPE
	) IS

BEGIN
  arp_util_tax.debug('CREATE_REPORTING_CODES(+)');
  arp_util_tax.debug('p_reporting_type_code = '||p_reporting_type_code);
  arp_util_tax.debug('p_lookup_type = '||p_lookup_type);
    INSERT
    INTO  ZX_REPORTING_CODES_B(
		REPORTING_CODE_ID      ,
		EXCEPTION_CODE         ,
		EFFECTIVE_FROM         ,
		EFFECTIVE_TO           ,
		RECORD_TYPE_CODE       ,
		CREATED_BY                     ,
		CREATION_DATE                  ,
		LAST_UPDATED_BY                ,
		LAST_UPDATE_DATE               ,
		LAST_UPDATE_LOGIN              ,
		REQUEST_ID                     ,
		PROGRAM_APPLICATION_ID         ,
		PROGRAM_ID                     ,
		PROGRAM_LOGIN_ID		  ,
		REPORTING_CODE_CHAR_VALUE	  ,
		REPORTING_CODE_DATE_VALUE      ,
		REPORTING_CODE_NUM_VALUE       ,
		REPORTING_TYPE_ID		,
		OBJECT_VERSION_NUMBER
	   )
    SELECT
           zx_reporting_codes_b_s.nextval,--REPORTING_CODE_ID
           NULL                          ,--EXCEPTION_CODE
           EFFECTIVE_FROM                ,
           NULL                          ,--EFFECTIVE_TO
          'SEEDED'                     ,--RECORD_TYPE_CODE
           120            ,
           SYSDATE                       ,
           120            ,
           SYSDATE                       ,
           0      ,
           fnd_global.conc_request_id    , -- Request Id
           fnd_global.prog_appl_id       , -- Program Application ID
           fnd_global.conc_program_id    , -- Program Id
           fnd_global.conc_login_id      ,  -- Program Login ID
           decode(DATATYPE,'TEXT',LOOKUP_CODE,'YES_NO',LOOKUP_CODE,NULL),
	   decode(DATATYPE,'DATE',LOOKUP_CODE,NULL),
	   decode(DATATYPE,'NUMERIC_VALUE',LOOKUP_CODE,NULL),
	   REPORTING_TYPE_ID,
	   1

    FROM
    (
    SELECT
           lookups.LOOKUP_CODE           LOOKUP_CODE   ,
           report_types.EFFECTIVE_FROM   EFFECTIVE_FROM,
	   report_types.REPORTING_TYPE_ID REPORTING_TYPE_ID,
	   report_types.REPORTING_TYPE_DATATYPE_CODE DATATYPE
    FROM
        ZX_REPORTING_TYPES_B report_types,
        FND_LOOKUPS          lookups
    WHERE
             report_types.REPORTING_TYPE_CODE = p_reporting_type_code
    AND  report_types.RECORD_TYPE_CODE    = 'SEEDED'
    AND  lookups.LOOKUP_TYPE = p_lookup_type
    AND  NOT EXISTS
    	 (SELECT 1 FROM ZX_REPORTING_CODES_B WHERE
	  REPORTING_TYPE_ID   = report_types.REPORTING_TYPE_ID AND
	  REPORTING_CODE_CHAR_VALUE=lookups.LOOKUP_CODE
	 )
    );

    arp_util_tax.debug('Inserting into ZX_REPORTING_CODES_TL table');

    INSERT INTO ZX_REPORTING_CODES_TL(
           REPORTING_CODE_ID      ,
           LANGUAGE               ,
           SOURCE_LANG            ,
           REPORTING_CODE_NAME    ,
           CREATED_BY             ,
           CREATION_DATE          ,
           LAST_UPDATED_BY        ,
           LAST_UPDATE_DATE       ,
           LAST_UPDATE_LOGIN
          )
     SELECT
           codes.reporting_code_id ,
           lookups.language        ,
           lookups.source_lang     ,
		CASE WHEN lookups.meaning = UPPER(lookups.meaning)
		THEN    Initcap(lookups.meaning)
		ELSE
		     lookups.meaning
		END,
           120      ,
           sysdate                 ,
           120      ,
           sysdate                 ,
           0
      FROM
	  ZX_REPORTING_TYPES_B TYPES,
          ZX_REPORTING_CODES_B CODES,
	  FND_LOOKUP_VALUES    lookups,
	  FND_LANGUAGES L
      WHERE

           TYPES.REPORTING_TYPE_ID     = CODES.REPORTING_TYPE_ID
      AND  TYPES.REPORTING_TYPE_CODE   = p_reporting_type_code
      AND  lookups.LOOKUP_TYPE         = p_lookup_type  --Bug Fix 4930895
      AND  CODES.REPORTING_CODE_CHAR_VALUE = lookups.lookup_code --Bug Fix 4930895
      AND  CODES.RECORD_TYPE_CODE      = 'SEEDED'
      AND  lookups.VIEW_APPLICATION_ID = 0
      AND  lookups.SECURITY_GROUP_ID   = 0
      AND  lookups.LANGUAGE            = L.LANGUAGE_CODE(+)
      AND  L.INSTALLED_FLAG in ('I', 'B')
      AND  not exists
               (select NULL
                from ZX_REPORTING_CODES_TL T
                where T.REPORTING_CODE_ID = CODES.REPORTING_CODE_ID
                and T.LANGUAGE = L.LANGUAGE_CODE);


    arp_util_tax.debug('CREATE_REPORTING_CODES(-)');

END CREATE_REPORTING_CODES_SEED;

/*=========================================================================+
 | PROCEDURE                                                               |
 |    CREATE_REPORTTYPE_USAGES_SEED                                          |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 |    Used to create seeded reporting types.				   |
 |									   |
 |									   |
 |									   |
 |									   |
 |                                                                         |
 | SCOPE - PRIVATE                                                         |
 |                                                                         |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                  |
 |                                                                         |
 | CALLED FROM    : CREATE_SEEDED_REPORTING_TYPES                          |
 |									   |
 | NOTES                                                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     25-May-2006  Ashwin Gurram      Created.                            |
 |                                                                         |
 |=========================================================================*/

PROCEDURE CREATE_REPORTTYPE_USAGES_SEED IS

BEGIN
INSERT INTO ZX_REPORT_TYPES_USAGES(
		REPORTING_TYPE_USAGE_ID	,
		ENTITY_CODE		,
		ENABLED_FLAG		,
		CREATED_BY		,
		CREATION_DATE		,
		LAST_UPDATED_BY		,
		LAST_UPDATE_DATE	,
		LAST_UPDATE_LOGIN	,
		REPORTING_TYPE_ID	,
		OBJECT_VERSION_NUMBER
	)
	SELECT  zx_report_types_usages_s.nextval,--REPORTING_TYPE_USAGE_ID
		'ZX_RATES'		,--ENTITY_CODE   --Bug 5528484
		'Y'	,--ENABLED_FLAG
		120      ,--CREATED_BY
		SYSDATE                 ,--CREATION_DATE
		120      ,--LAST_UPDATED_BY
		SYSDATE                 ,--LAST_UPDATE_DATE
		0,--LAST_UPDATE_LOGIN
		reporting_type_id	,--REPORTING_TYPE_ID
		1
	FROM
		zx_reporting_types_b rep_type
	WHERE
	          reporting_type_code IN
		  (
		  'PT_LOCATION','PT_PRD_TAXABLE_BOX','PT_PRD_REC_TAX_BOX','PT_ANL_TTL_TAXABLE_BOX',
		  'PT_ANL_REC_TAXABLE','PT_ANL_NON_REC_TAXABLE','PT_ANL_REC_TAX_BOX','AR_DGI_TRX_CODE',
		  'PRINT TAX LINE','AR_MUNICIPAL_JUR','AR_TURN_OVER_JUR_CODE',
		  'CL_TAX_CODE_CLASSIF','CL_BILLS_OF_EXCH_TAX','KR_LOCATION'
		  )
        AND record_type_code = 'SEEDED'
	AND  NOT EXISTS ( select 1 from zx_report_types_usages
			where reporting_type_id = rep_type.reporting_type_id and
			entity_code = 'ZX_RATES' );


INSERT INTO ZX_REPORT_TYPES_USAGES(
		REPORTING_TYPE_USAGE_ID	,
		ENTITY_CODE		,
		ENABLED_FLAG		,
		CREATED_BY		,
		CREATION_DATE		,
		LAST_UPDATED_BY		,
		LAST_UPDATE_DATE	,
		LAST_UPDATE_LOGIN	,
		REPORTING_TYPE_ID	,
		OBJECT_VERSION_NUMBER
	)
	SELECT  zx_report_types_usages_s.nextval,--REPORTING_TYPE_USAGE_ID
		'ZX_PARTY_TAX_PROFILE'		,--ENTITY_CODE
		'Y'	,--ENABLED_FLAG
		120      ,--CREATED_BY
		SYSDATE                 ,--CREATION_DATE
		120      ,--LAST_UPDATED_BY
		SYSDATE                 ,--LAST_UPDATE_DATE
		0,--LAST_UPDATE_LOGIN
		reporting_type_id	,--REPORTING_TYPE_ID
		1
	FROM
		zx_reporting_types_b rep_type
	WHERE
	          reporting_type_code IN ('FISCAL PRINTER','CAI NUMBER')
        AND record_type_code = 'SEEDED'
	AND  NOT EXISTS ( select 1 from zx_report_types_usages
			where reporting_type_id = rep_type.reporting_type_id and
			entity_code = 'ZX_PARTY_TAX_PROFILE' );

END CREATE_REPORTTYPE_USAGES_SEED;

/*=========================================================================+
 | PROCEDURE                                                               |
 |    CREATE_SEEDED_REPORTING_TYPES                                            |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 |    Used to create the reporting types FOR SEED data from UI   	   |
 |    called from the Country defaults UI.				   |
 |									   |
 | SCOPE - PUBLIC                                                          |
 |                                                                         |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                  |
 |                                                                         |
 | CALLED FROM  : Country Defaults UI                                      |
 |									   |
 | NOTES                                                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     19-May-06  Ashwin Gurram      Created.                             |
 |                                                                         |
 |=========================================================================*/

PROCEDURE CREATE_SEEDED_REPORTING_TYPES
(
	p_country_code          IN	   VARCHAR2,
	x_return_status        OUT NOCOPY VARCHAR2
) IS
l_lookup_code varchar2(1);

BEGIN
x_return_status := 'S';

IF ( p_country_code = 'PT' ) THEN
		--Create Reporting Types
		CREATE_REPORT_TYPE_SEED('PT_LOCATION','TEXT','Y');
		CREATE_REPORT_TYPE_SEED('PT_PRD_TAXABLE_BOX','TEXT','N');
		CREATE_REPORT_TYPE_SEED('PT_PRD_REC_TAX_BOX','TEXT','N');
		CREATE_REPORT_TYPE_SEED('PT_ANL_TTL_TAXABLE_BOX','TEXT','N');
		CREATE_REPORT_TYPE_SEED('PT_ANL_REC_TAXABLE','TEXT','N');
		CREATE_REPORT_TYPE_SEED('PT_ANL_NON_REC_TAXABLE','TEXT','N');
		CREATE_REPORT_TYPE_SEED('PT_ANL_REC_TAX_BOX','TEXT','N');

		-- Create Reporting Codes
		FOR i IN 1..3
		   LOOP
		     IF ( i = 1 ) THEN l_lookup_code := 'A' ;
		     ELSIF ( i = 2 ) THEN l_lookup_code := 'C';
		     ELSE  l_lookup_code := 'M';
		     END IF ;

		     INSERT
		    INTO  ZX_REPORTING_CODES_B(
				REPORTING_CODE_ID      ,
				EXCEPTION_CODE         ,
				EFFECTIVE_FROM         ,
				EFFECTIVE_TO           ,
				RECORD_TYPE_CODE       ,
				CREATED_BY                     ,
				CREATION_DATE                  ,
				LAST_UPDATED_BY                ,
				LAST_UPDATE_DATE               ,
				LAST_UPDATE_LOGIN              ,
				REQUEST_ID                     ,
				PROGRAM_APPLICATION_ID         ,
				PROGRAM_ID                     ,
				PROGRAM_LOGIN_ID		  ,
				REPORTING_CODE_CHAR_VALUE	  ,
				REPORTING_CODE_DATE_VALUE      ,
				REPORTING_CODE_NUM_VALUE       ,
				REPORTING_TYPE_ID		,
				OBJECT_VERSION_NUMBER
			   )
		    SELECT
			   zx_reporting_codes_b_s.nextval,--REPORTING_CODE_ID
			   NULL                          ,--EXCEPTION_CODE
			   report_types.EFFECTIVE_FROM                ,
			   NULL                          ,--EFFECTIVE_TO
			  'SEEDED'                     ,--RECORD_TYPE_CODE
			   120            ,
			   SYSDATE                       ,
			   120            ,
			   SYSDATE                       ,
			   0      ,
			   fnd_global.conc_request_id    , -- Request Id
			   fnd_global.prog_appl_id       , -- Program Application ID
			   fnd_global.conc_program_id    , -- Program Id
			   fnd_global.conc_login_id      ,  -- Program Login ID
			   l_lookup_code,
			   NULL,
			   NULL,
			   report_types.REPORTING_TYPE_ID,
			   1
		    FROM
			ZX_REPORTING_TYPES_B report_types
		    WHERE
			report_types.REPORTING_TYPE_CODE = 'PT_LOCATION'
			AND  report_types.RECORD_TYPE_CODE    = 'SEEDED'
			AND  NOT EXISTS
			(SELECT 1 FROM ZX_REPORTING_CODES_B WHERE
			REPORTING_TYPE_ID   = report_types.REPORTING_TYPE_ID AND
			REPORTING_CODE_CHAR_VALUE= l_lookup_code
			);
		  END LOOP ;

		  --Create Reporting Codes TL for PT_LOCATION
		  INSERT INTO ZX_REPORTING_CODES_TL(
		   REPORTING_CODE_ID      ,
		   LANGUAGE               ,
		   SOURCE_LANG            ,
		   REPORTING_CODE_NAME    ,
		   CREATED_BY             ,
		   CREATION_DATE          ,
		   LAST_UPDATED_BY        ,
		   LAST_UPDATE_DATE       ,
		   LAST_UPDATE_LOGIN
		  )
	     SELECT
		   codes.reporting_code_id,
		   L.LANGUAGE_CODE        ,
		   userenv('LANG')        ,
		   CASE
		   WHEN CODES.REPORTING_CODE_CHAR_VALUE = 'A'
		   THEN Initcap('ACORES')
		   WHEN CODES.REPORTING_CODE_CHAR_VALUE = 'C'
		   THEN Initcap('CONTINENTE')
		   WHEN CODES.REPORTING_CODE_CHAR_VALUE = 'M'
		   THEN Initcap('MADEIRA')
		   ELSE
			   CASE WHEN CODES.REPORTING_CODE_CHAR_VALUE = UPPER(CODES.REPORTING_CODE_CHAR_VALUE)
				THEN    Initcap(CODES.REPORTING_CODE_CHAR_VALUE)
				ELSE
					CODES.REPORTING_CODE_CHAR_VALUE
			   END
		   END  ,--REPORTING_CODE_NAME
		   120             ,
		   SYSDATE                        ,
		   120             ,
		   SYSDATE                        ,
		   0
	      FROM
		  ZX_REPORTING_CODES_B CODES,
		  FND_LANGUAGES L
	      WHERE
	      CODES.RECORD_TYPE_CODE  = 'SEEDED'
	      AND   codes.reporting_type_id = ( SELECT reporting_type_id FROM ZX_REPORTING_TYPES_B
	            WHERE REPORTING_TYPE_CODE = 'PT_LOCATION' AND record_type_code = 'SEEDED' )
	      AND   L.INSTALLED_FLAG in ('I', 'B')
	      AND   not exists
			(select NULL
			from ZX_REPORTING_CODES_TL T
			where T.REPORTING_CODE_ID = CODES.REPORTING_CODE_ID
			and T.LANGUAGE = L.LANGUAGE_CODE);
END IF ;

IF ( p_country_code = 'AR') THEN
	CREATE_REPORT_TYPE_SEED('AR_DGI_TRX_CODE','TEXT','Y');
	CREATE_REPORT_TYPE_SEED('PRINT TAX LINE','YES_NO','N');
	CREATE_REPORT_TYPE_SEED('AR_MUNICIPAL_JUR','TEXT','N');
	CREATE_REPORT_TYPE_SEED('AR_TURN_OVER_JUR_CODE','TEXT','Y');
	CREATE_REPORT_TYPE_SEED('FISCAL PRINTER','YES_NO','N');
	CREATE_REPORT_TYPE_SEED('CAI NUMBER','TEXT','N'); --bug6430516

	CREATE_REPORTING_CODES_SEED('AR_DGI_TRX_CODE','JLZZ_AP_DGI_TRX_CODE');
	CREATE_REPORTING_CODES_SEED('AR_TURN_OVER_JUR_CODE','JLZZ_AR_TO_JURISDICTION_CODE');
END IF ;

IF ( p_country_code = 'CL') THEN
	CREATE_REPORT_TYPE_SEED('CL_TAX_CODE_CLASSIF','TEXT','Y');
	CREATE_REPORT_TYPE_SEED('CL_BILLS_OF_EXCH_TAX','YES_NO','N');
	CREATE_REPORT_TYPE_SEED('CL_DEBIT_ACCOUNT','TEXT','N');

	CREATE_REPORTING_CODES_SEED('CL_TAX_CODE_CLASSIF','JLCL_TAX_CODE_CLASS');

END IF ;

IF ( p_country_code = 'CZ') THEN
	CREATE_REPORT_TYPE_SEED('CZ_TAX_ORIGIN','TEXT','Y');

	CREATE_REPORTING_CODES_SEED('CZ_TAX_ORIGIN','JGZZ_TAX_ORIGIN');
END IF ;

IF ( p_country_code = 'HU') THEN
	CREATE_REPORT_TYPE_SEED('HU_TAX_ORIGIN','TEXT','Y');

	CREATE_REPORTING_CODES_SEED('HU_TAX_ORIGIN','JGZZ_TAX_ORIGIN');
END IF ;

IF ( p_country_code = 'PL') THEN
	CREATE_REPORT_TYPE_SEED('PL_TAX_ORIGIN','TEXT','Y');

	CREATE_REPORTING_CODES_SEED('PL_TAX_ORIGIN','JGZZ_TAX_ORIGIN');
END IF ;

IF ( p_country_code = 'CH') THEN
	CREATE_REPORT_TYPE_SEED('CH_VAT_REGIME','TEXT','Y');

	CREATE_REPORTING_CODES_SEED('CH_VAT_REGIME','JECH_VAT_REGIME');
END IF ;

IF ( p_country_code = 'TW') THEN
	CREATE_REPORT_TYPE_SEED('TW_GOVERNMENT_TAX_TYPE','TEXT','Y');

	--Create Reporting Codes
	    INSERT
	    INTO  ZX_REPORTING_CODES_B(
			REPORTING_CODE_ID      ,
			EXCEPTION_CODE         ,
			EFFECTIVE_FROM         ,
			EFFECTIVE_TO           ,
			RECORD_TYPE_CODE       ,
			CREATED_BY                     ,
			CREATION_DATE                  ,
			LAST_UPDATED_BY                ,
			LAST_UPDATE_DATE               ,
			LAST_UPDATE_LOGIN              ,
			REQUEST_ID                     ,
			PROGRAM_APPLICATION_ID         ,
			PROGRAM_ID                     ,
			PROGRAM_LOGIN_ID		  ,
			REPORTING_CODE_CHAR_VALUE	  ,
			REPORTING_CODE_DATE_VALUE      ,
			REPORTING_CODE_NUM_VALUE       ,
			REPORTING_TYPE_ID		,
			OBJECT_VERSION_NUMBER
		   )
	    SELECT
		   zx_reporting_codes_b_s.nextval,--REPORTING_CODE_ID
		   NULL                          ,--EXCEPTION_CODE
		   EFFECTIVE_FROM                ,
		   NULL                          ,--EFFECTIVE_TO
		  'SEEDED'                     ,--RECORD_TYPE_CODE
		   120            ,
		   SYSDATE                       ,
		   120            ,
		   SYSDATE                       ,
		   0      ,
		   fnd_global.conc_request_id    , -- Request Id
		   fnd_global.prog_appl_id       , -- Program Application ID
		   fnd_global.conc_program_id    , -- Program Id
		   fnd_global.conc_login_id      ,  -- Program Login ID
		   decode(DATATYPE,'TEXT',LOOKUP_CODE,'YES_NO',LOOKUP_CODE,NULL),
		   decode(DATATYPE,'DATE',LOOKUP_CODE,NULL),
		   decode(DATATYPE,'NUMERIC_VALUE',LOOKUP_CODE,NULL),
		   REPORTING_TYPE_ID,
		   1

	    FROM
	    (
	    SELECT
		   lookups.LOOKUP_CODE           LOOKUP_CODE   ,
		   report_types.EFFECTIVE_FROM   EFFECTIVE_FROM,
		   report_types.REPORTING_TYPE_ID REPORTING_TYPE_ID,
		   report_types.REPORTING_TYPE_DATATYPE_CODE DATATYPE
	    FROM
		ZX_REPORTING_TYPES_B report_types,
		JA_LOOKUPS          lookups
	    WHERE
		     report_types.REPORTING_TYPE_CODE = 'TW_GOVERNMENT_TAX_TYPE'
	    AND  report_types.RECORD_TYPE_CODE    = 'SEEDED'
	    AND  lookups.LOOKUP_TYPE = 'JATW_GOVERNMENT_TAX_TYPE'
	    AND  NOT EXISTS
		 (SELECT 1 FROM ZX_REPORTING_CODES_B WHERE
		  REPORTING_TYPE_ID   = report_types.REPORTING_TYPE_ID AND
		  REPORTING_CODE_CHAR_VALUE=lookups.LOOKUP_CODE
		 )
	    );

	    arp_util_tax.debug('Inserting into ZX_REPORTING_CODES_TL table');

	    INSERT INTO ZX_REPORTING_CODES_TL(
		   REPORTING_CODE_ID      ,
		   LANGUAGE               ,
		   SOURCE_LANG            ,
		   REPORTING_CODE_NAME    ,
		   CREATED_BY             ,
		   CREATION_DATE          ,
		   LAST_UPDATED_BY        ,
		   LAST_UPDATE_DATE       ,
		   LAST_UPDATE_LOGIN
		  )
	     SELECT
		   codes.reporting_code_id ,
		   lookups.language        ,
		   lookups.source_lang     ,
			CASE WHEN lookups.meaning = UPPER(lookups.meaning)
			THEN    Initcap(lookups.meaning)
			ELSE
			     lookups.meaning
			END,
		   120      ,
		   sysdate                 ,
		   120      ,
		   sysdate                 ,
		   0
	      FROM
		  ZX_REPORTING_TYPES_B TYPES,
		  ZX_REPORTING_CODES_B CODES,
		  FND_LOOKUP_VALUES    lookups,
		  FND_LANGUAGES L
	      WHERE

		   TYPES.REPORTING_TYPE_ID     = CODES.REPORTING_TYPE_ID
	      AND  TYPES.REPORTING_TYPE_CODE   = 'TW_GOVERNMENT_TAX_TYPE'
	      AND  lookups.LOOKUP_TYPE         = 'JATW_GOVERNMENT_TAX_TYPE'
	      AND  CODES.REPORTING_CODE_CHAR_VALUE = lookups.lookup_code
	      AND  CODES.RECORD_TYPE_CODE      = 'SEEDED'
	      AND  lookups.VIEW_APPLICATION_ID = 7000  -- Pl note Application id is different here.
	      AND  lookups.SECURITY_GROUP_ID   = 0
	      AND  lookups.LANGUAGE            = L.LANGUAGE_CODE(+)
	      AND  L.INSTALLED_FLAG in ('I', 'B')
	      AND  not exists
		       (select NULL
			from ZX_REPORTING_CODES_TL T
			where T.REPORTING_CODE_ID = CODES.REPORTING_CODE_ID
			and T.LANGUAGE = L.LANGUAGE_CODE);

END IF ;

IF ( p_country_code = 'KR') THEN
	CREATE_REPORT_TYPE_SEED('KR_BUSINESS_LOCATIONS','TEXT','Y'); ----bug6430516
	CREATE_REPORT_TYPE_SEED('KR_LOCATION','TEXT','Y');

END IF ;

IF ( p_country_code = 'BR') THEN
	CREATE_REPORT_TYPE_SEED('PRINT TAX LINE ','YES_NO','N');

END IF ;

IF ( p_country_code = 'CO' ) THEN
	CREATE_REPORT_TYPE_SEED('PRINT TAX LINE ','YES_NO','N');

END IF ;

--Create Reporting Types Usages
CREATE_REPORTTYPE_USAGES_SEED;

EXCEPTION
WHEN OTHERS THEN
--NULL ;
x_return_status := 'E';
END CREATE_SEEDED_REPORTING_TYPES;
/*===========================================================================+
|  Procedure:    CREATE_REPORT_TYPES_USAGES                                 |
|  Description:  This is the  procedure that creates report_types_usages    |
|                for the following reporting types                          |
|                PL_TAX_ORIGIN						    |
|		 CH_VAT_REGIME						    |
|		 CL_DEBIT_ACCOUNT					    |
|		 HU_TAX_ORIGIN						    |
|		 CZ_TAX_ORIGIN						    |
|		 TW_GOVERNMENT_TAX_TYPE					    |
|                                                                           |
|  ARGUMENTS  :                                                             |
|                                                                           |
|  NOTES                                                                    |
|                                                                           |
|  History                                                                  |
|  29-Sep-04  Arnab        Created                                          |
|                                                                           |
+===========================================================================*/

PROCEDURE CREATE_REPORT_TYPES_USAGES
IS
BEGIN
INSERT INTO ZX_REPORT_TYPES_USAGES(
		REPORTING_TYPE_USAGE_ID	,
 		REPORTING_TYPE_ID	,
		ENTITY_CODE		,
		ENABLED_FLAG		,
		CREATED_BY		,
		CREATION_DATE		,
		LAST_UPDATED_BY		,
		LAST_UPDATE_DATE	,
		LAST_UPDATE_LOGIN	,
		OBJECT_VERSION_NUMBER
	)
   SELECT
          zx_report_types_usages_s.nextval,--REPORTING_TYPE_USAGE_ID
          types.reporting_type_id         ,--REPORTING_TYPE_ID
          lookups.lookup_code             ,--ENTITY_CODE
          DECODE(lookups.lookup_code,
                'ZX_RATES','Y',
                'N')             ,--ENABLED_FLAG
          fnd_global.user_id     ,
          SYSDATE                ,
          fnd_global.user_id     ,
          SYSDATE                ,
          fnd_global.conc_login_id,
	  1
     FROM
           zx_reporting_types_b types,
           fnd_lookups        lookups

    WHERE
      types.reporting_type_code  IN('PL_TAX_ORIGIN',
                                    'CH_VAT_REGIME',
				    'CL_DEBIT_ACCOUNT',
				    'HU_TAX_ORIGIN',
				    'CZ_TAX_ORIGIN',
				    'TW_GOVERNMENT_TAX_TYPE'
				    )
    AND   types.record_type_code    = 'MIGRATED'

    AND   lookups.LOOKUP_TYPE       = 'ZX_REPORTING_TABLE_USE'

        AND  NOT EXISTS ( select 1 from zx_report_types_usages
                      where reporting_type_id = types.reporting_type_id
                      and entity_code = lookups.lookup_code );

INSERT INTO ZX_REPORT_TYPES_USAGES(
		REPORTING_TYPE_USAGE_ID	,
    REPORTING_TYPE_ID,
		ENTITY_CODE		,
		ENABLED_FLAG		,
		CREATED_BY		,
		CREATION_DATE		,
		LAST_UPDATED_BY		,
		LAST_UPDATE_DATE	,
		LAST_UPDATE_LOGIN	,
		OBJECT_VERSION_NUMBER
	)
   SELECT
          zx_report_types_usages_s.nextval,--REPORTING_TYPE_USAGE_ID
          types.reporting_type_id         ,--REPORTING_TYPE_ID
          lookups.lookup_code             ,--ENTITY_CODE
          DECODE(lookups.lookup_code,
                'ZX_PARTY_TAX_PROFILE','Y',
                'N')             ,--ENABLED_FLAG
          fnd_global.user_id     ,
          SYSDATE                ,
          fnd_global.user_id     ,
          SYSDATE                ,
          fnd_global.conc_login_id,
	  1
     FROM
           zx_reporting_types_b types,
           fnd_lookups        lookups

    WHERE
      types.reporting_type_code IN('MEMBER STATE',
				   'AR-SYSTEM-PARAM-REG-NUM',
				   'JA - REG NUMBER',
				   'FSO-REG-NUM',
				   'JE - REG NUMBER',
				   'JE - REG NUMBER'
				    )
    AND   types.record_type_code    = 'MIGRATED'

    AND   lookups.LOOKUP_TYPE       = 'ZX_REPORTING_TABLE_USE'

        AND  NOT EXISTS ( select 1 from zx_report_types_usages
                      where reporting_type_id = types.reporting_type_id
                      and entity_code = lookups.lookup_code );


END;

/*Code included for EMEA VAT reporting */

/*==========================================================================+
|  Procedure:    CREATE_REPORTING_TYPE_EMEA                                 |
|  Description:  This is the  procedure that creates reporting_type         |
|                EMEA_VAT_REPORTING_TYPE                                    |
|                for the following EMEA countries                           |
|                BE,CH,CZ,     						    |
|		 DE,ES,FR,      					    |
|		 HU,IT,KP,             					    |
|		 KR,NO,PL,       					    |
|		 PT,SK	        					    |
|                                                                           |
|  ARGUMENTS  :                                                             |
|                                                                           |
|  NOTES                                                                    |
|                                                                           |
|  History                                                                  |
|  29-Sep-04  Taniya        Created                                         |
|                                                                           |
+===========================================================================*/

PROCEDURE CREATE_REPORTING_TYPE_EMEA
IS
BEGIN
    arp_util_tax.debug('CREATE_REPORTING_TYPE_EMEA(+)');
    arp_util_tax.debug('p_reporting_type_code = '||'EMEA_VAT_REPORTING_TYPE');
INSERT
    WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                       where  reporting_type_code= 'EMEA_VAT_REPORTING_TYPE'
                       and    tax_regime_code is NULL)
          ) THEN
    INTO  ZX_REPORTING_TYPES_B(
		REPORTING_TYPE_ID              ,
		REPORTING_TYPE_CODE            ,
		REPORTING_TYPE_DATATYPE_CODE   ,
		TAX_REGIME_CODE                ,
		TAX                            ,
		FORMAT_MASK                    ,
		MIN_LENGTH                     ,
		MAX_LENGTH                     ,
		LEGAL_MESSAGE_FLAG             ,
		EFFECTIVE_FROM                 ,
		EFFECTIVE_TO                   ,
		RECORD_TYPE_CODE               ,
		HAS_REPORTING_CODES_FLAG       ,
		CREATED_BY                     ,
		CREATION_DATE                  ,
		LAST_UPDATED_BY                ,
		LAST_UPDATE_DATE               ,
		LAST_UPDATE_LOGIN              ,
		REQUEST_ID                     ,
		PROGRAM_APPLICATION_ID         ,
		PROGRAM_ID                     ,
		PROGRAM_LOGIN_ID		,
		OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_reporting_types_b_s.nextval ,--REPORTING_TYPE_ID
          'EMEA_VAT_REPORTING_TYPE'       ,--REPORTING_TYPE_CODE
          --'VARCHAR'		          ,--REPORTING_TYPE_DATATYPE
	  'TEXT'		          ,--REPORTING_TYPE_DATATYPE (Bug6430516)
           NULL                           ,--TAX_REGIME_CODE
           NULL                           ,--TAX
           NULL                           ,--FORMAT_MASK
           1                              ,--MIN_LENGTH
           30                             ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           effective_from                 ,--EFFECTIVE_FROM
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
          'Y'                             ,--HAS_REPORTING_CODES_FLAG
           fnd_global.user_id             ,--CREATED_BY
           SYSDATE                        ,--CREATION_DATE
           fnd_global.user_id             ,--LAST_UPDATED_BY
           SYSDATE                        ,--LAST_UPDATE_DATE
           fnd_global.conc_login_id       ,--LAST_UPDATE_LOGIN
           fnd_global.conc_request_id     ,--REQUEST_ID
           fnd_global.prog_appl_id        ,--PROGRAM_APPLICATION_ID
           fnd_global.conc_program_id     ,--PROGRAM_ID
           fnd_global.conc_login_id       ,--PROGRAM_LOGIN_ID
	   1                               --OBJECT_VERSION_NUMBER
          )
    SELECT min(zx_rates.effective_from) effective_from
    FROM zx_rates_b zx_rates,
         zx_regimes_b zx_regimes
    WHERE zx_rates.tax_regime_code = zx_regimes.tax_regime_code
    AND zx_regimes.country_code in ('BE','CH','CZ','DE','ES','FR','HU',
                                    'IT','KP','KR','NO','PL','PT','SK', 'IL')
    AND  zx_rates.record_type_code = 'MIGRATED';

    arp_util_tax.debug('Inserting into ZX_REPORTING_TYPES_TL table');

    INSERT INTO ZX_REPORTING_TYPES_TL(
           REPORTING_TYPE_ID      ,
           LANGUAGE               ,
           SOURCE_LANG            ,
           REPORTING_TYPE_NAME    ,
           CREATED_BY             ,
           CREATION_DATE          ,
           LAST_UPDATED_BY        ,
           LAST_UPDATE_DATE       ,
           LAST_UPDATE_LOGIN
          )
     SELECT
     	REPORTING_TYPE_ID	 ,
     	LANGUAGE_CODE		 ,
     	userenv('LANG')    	 ,
       'EMEA VAT Reporting Type' ,
	fnd_global.user_id       ,
	SYSDATE                  ,
	fnd_global.user_id       ,
	SYSDATE                  ,
	fnd_global.conc_login_id
    FROM
     (
        SELECT
           TYPES.REPORTING_TYPE_ID ,
           L.LANGUAGE_CODE
	FROM
	 ZX_REPORTING_TYPES_B TYPES,
	 FND_LANGUAGES L
	WHERE TYPES.RECORD_TYPE_CODE = 'MIGRATED'
	AND TYPES.REPORTING_TYPE_CODE = 'EMEA_VAT_REPORTING_TYPE'
	AND L.INSTALLED_FLAG in ('I', 'B')
	) TYPES

	WHERE not exists
	       (select NULL
	        from ZX_REPORTING_TYPES_TL T
	        where T.REPORTING_TYPE_ID = TYPES.REPORTING_TYPE_ID
	        and T.LANGUAGE = TYPES.LANGUAGE_CODE);

    arp_util_tax.debug('CREATE_REPORTING_TYPE_EMEA(-)');

END CREATE_REPORTING_TYPE_EMEA;

/*==========================================================================+
|  Procedure:    CREATE_REPORT_TYP_USAGES_EMEA                              |
|  Description:  This is the  procedure that creates report_type_usages     |
|                for the reporting type EMEA_VAT_REPORTING_TYPE             |
|                                                                           |
|  ARGUMENTS  :                                                             |
|                                                                           |
|  NOTES                                                                    |
|                                                                           |
|  History                                                                  |
|  29-Sep-04  Taniya        Created                                         |
|                                                                           |
+===========================================================================*/

PROCEDURE CREATE_REPORT_TYP_USAGES_EMEA
IS
BEGIN
    arp_util_tax.debug('CREATE_REPORT_TYP_USAGES_EMEA(+)');

    INSERT INTO ZX_REPORT_TYPES_USAGES(
          REPORTING_TYPE_USAGE_ID,
          REPORTING_TYPE_ID      ,
          ENTITY_CODE            ,
          ENABLED_FLAG           ,
          CREATED_BY             ,
          CREATION_DATE          ,
          LAST_UPDATED_BY        ,
          LAST_UPDATE_DATE       ,
          LAST_UPDATE_LOGIN	 ,
	  OBJECT_VERSION_NUMBER
          )
    SELECT
          zx_report_types_usages_s.nextval,--REPORTING_TYPE_USAGE_ID
          types.reporting_type_id         ,--REPORTING_TYPE_ID
         'ZX_RATES'                       ,--ENTITY_CODE
         'Y'                              ,--ENABLED_FLAG
          fnd_global.user_id              ,--CREATED_BY
          SYSDATE                         ,--CREATION_DATE
          fnd_global.user_id              ,--LAST_UPDATED_BY
          SYSDATE                         ,--LAST_UPDATE_DATE
          fnd_global.conc_login_id        ,--LAST_UPDATE_LOGIN
	  1                                --OBJECT_VERSION_NUMBER
     FROM
          zx_reporting_types_b types
     WHERE types.reporting_type_code IN('EMEA_VAT_REPORTING_TYPE')
     --AND types.record_type_code    = 'MIGRATED'
     AND NOT EXISTS ( select 1 from zx_report_types_usages
                      where reporting_type_id = types.reporting_type_id
                      and entity_code = 'ZX_RATES');

     arp_util_tax.debug('CREATE_REPORT_TYP_USAGES_EMEA(-)');

END CREATE_REPORT_TYP_USAGES_EMEA;

/*==========================================================================+
|  Procedure:    CREATE_REPORTING_CODES_EMEA                                |
|  Description:  This is the  procedure that creates reporting_codes        |
|                for the reporting type EMEA_VAT_REPORTING_TYPE             |
|                and lookup_type ZX_TAX_TYPE_CATEGORY                       |
|                                                                           |
|  ARGUMENTS  :                                                             |
|                                                                           |
|  NOTES                                                                    |
|                                                                           |
|  History                                                                  |
|  29-Sep-04  Taniya        Created                                         |
|                                                                           |
+===========================================================================*/

PROCEDURE CREATE_REPORTING_CODES_EMEA
IS
BEGIN
  arp_util_tax.debug('CREATE_REPORTING_CODES_EMEA(+)');
  arp_util_tax.debug('p_reporting_type_code = '||'EMEA_VAT_REPORTING_TYPE');
  arp_util_tax.debug('p_lookup_type = '||'ZX_TAX_TYPE_CATEGORY');
  INSERT
    INTO  ZX_REPORTING_CODES_B(
		REPORTING_CODE_ID      ,
		EXCEPTION_CODE         ,
		EFFECTIVE_FROM         ,
		EFFECTIVE_TO           ,
		RECORD_TYPE_CODE       ,
		CREATED_BY                     ,
		CREATION_DATE                  ,
		LAST_UPDATED_BY                ,
		LAST_UPDATE_DATE               ,
		LAST_UPDATE_LOGIN              ,
		REQUEST_ID                     ,
		PROGRAM_APPLICATION_ID         ,
		PROGRAM_ID                     ,
		PROGRAM_LOGIN_ID		  ,
		REPORTING_CODE_CHAR_VALUE	  ,
		REPORTING_CODE_DATE_VALUE      ,
		REPORTING_CODE_NUM_VALUE       ,
		REPORTING_TYPE_ID		,
		OBJECT_VERSION_NUMBER
	   )
    SELECT
           zx_reporting_codes_b_s.nextval,--REPORTING_CODE_ID
           NULL                          ,--EXCEPTION_CODE
           EFFECTIVE_FROM                ,--EFFECTIVE_FROM
           NULL                          ,--EFFECTIVE_TO
          'MIGRATED'                     ,--RECORD_TYPE_CODE
           fnd_global.user_id            ,--CREATED_BY
           SYSDATE                       ,--CREATION_DATE
           fnd_global.user_id            ,--LAST_UPDATED_BY
           SYSDATE                       ,--LAST_UPDATE_DATE
           fnd_global.conc_login_id      ,--LAST_UPDATE_LOGIN
           fnd_global.conc_request_id    ,--REQUEST_ID
           fnd_global.prog_appl_id       ,--PROGRAM_APPLICATION_ID
           fnd_global.conc_program_id    ,--PROGRAM_ID
           fnd_global.conc_login_id      ,--PROGRAM_LOGIN_ID
           DECODE(DATATYPE,'TEXT',REPORTING_CODE_CHAR_VALUE,NULL),--REPORTING_CODE_CHAR_VALUE --Bug#6615621
	   NULL                                         ,--REPORTING_CODE_DATE_VALUE
	   NULL                                         ,--REPORTING_CODE_NUM_VALUE
	   REPORTING_TYPE_ID                            ,--REPORTING_TYPE_ID
	   1                                             --OBJECT_VERSION_NUMBER

    FROM
    (
    SELECT
           DISTINCT Decode (lookup_code,
                            'SALES','SALES_TAX',
                            'Exempt Vat','EXEMPT',
			    'SERV','SERVICES',
                             Upper(lookup_code)) REPORTING_CODE_CHAR_VALUE,
           report_types.EFFECTIVE_FROM   EFFECTIVE_FROM,
	   report_types.REPORTING_TYPE_ID REPORTING_TYPE_ID,
	   report_types.REPORTING_TYPE_DATATYPE_CODE DATATYPE
    FROM
        ZX_REPORTING_TYPES_B report_types,
        FND_LOOKUPS          lookups
    WHERE
         report_types.REPORTING_TYPE_CODE = 'EMEA_VAT_REPORTING_TYPE'
    --AND  report_types.RECORD_TYPE_CODE    = 'MIGRATED'
    AND  lookups.LOOKUP_TYPE = 'ZX_TAX_TYPE_CATEGORY'
    --Consider only the following lookup_codes
    AND  lookups.LOOKUP_CODE IN ('EXEMPT','LOCATION','NON TAXABLE','SALES_TAX',
                                 'VAT','Custom Bill','Exempt Vat','ICMS','IPI',
				 'Non Taxable','SALES','Self Invoice','USE',
				 'SERVICES','SERV','INTER EC','VAT-A','VAT-S',
				 'VAT-KA','VAT-KS','VAT-RA','VAT-RS','VAT-NO-REP',
				 'IL_VAT_EXEMPT','IL_VAT')
    AND  NOT EXISTS
    	 (SELECT 1 FROM ZX_REPORTING_CODES_B WHERE
	  REPORTING_TYPE_ID   = report_types.REPORTING_TYPE_ID AND
	  REPORTING_CODE_CHAR_VALUE = DECODE(lookups.LOOKUP_CODE,
	                                     'SALES','SALES_TAX',
					     'Exempt Vat','EXEMPT',
					     'SERV','SERVICES',
					     UPPER(lookups.lookup_code))
	 )
    );

    arp_util_tax.debug('Inserting into ZX_REPORTING_CODES_TL table');

    INSERT INTO ZX_REPORTING_CODES_TL(
           REPORTING_CODE_ID      ,
           LANGUAGE               ,
           SOURCE_LANG            ,
           REPORTING_CODE_NAME    ,
           CREATED_BY             ,
           CREATION_DATE          ,
           LAST_UPDATED_BY        ,
           LAST_UPDATE_DATE       ,
           LAST_UPDATE_LOGIN
          )
     SELECT
           codes.reporting_code_id ,
           lookups.language        ,
           lookups.source_lang     ,
	    CASE WHEN lookups.meaning = UPPER(lookups.meaning)
	     THEN    Initcap(lookups.meaning)
	     ELSE
		     lookups.meaning
	     END,
           fnd_global.user_id      ,
           sysdate                 ,
           fnd_global.user_id      ,
           sysdate                 ,
           fnd_global.conc_login_id
      FROM
	  ZX_REPORTING_TYPES_B TYPES,
          ZX_REPORTING_CODES_B CODES,
	  FND_LOOKUP_VALUES    lookups,
	  FND_LANGUAGES L
      WHERE

           TYPES.REPORTING_TYPE_ID     = CODES.REPORTING_TYPE_ID
      AND  TYPES.REPORTING_TYPE_CODE   = 'EMEA_VAT_REPORTING_TYPE'
      AND  lookups.LOOKUP_TYPE         = 'ZX_TAX_TYPE_CATEGORY'
      AND  CODES.REPORTING_CODE_CHAR_VALUE = Decode(lookups.lookup_code,
                                                    'Exempt',NULL,
                                                    'Non Taxable', NULL,
                                                    'SERV',NULL,
                                                    'SALES',NULL,
                                                    'Exempt Vat',NULL,
                                                    Upper(lookups.lookup_code))
      AND  CODES.RECORD_TYPE_CODE      = 'MIGRATED'
      AND  lookups.VIEW_APPLICATION_ID = 0
      AND  lookups.SECURITY_GROUP_ID   = 0
      AND  lookups.LANGUAGE            = L.LANGUAGE_CODE(+)
      AND  L.INSTALLED_FLAG in ('I', 'B')
      AND  not exists
               (select NULL
                from ZX_REPORTING_CODES_TL T
                where T.REPORTING_CODE_ID = CODES.REPORTING_CODE_ID
                and T.LANGUAGE = L.LANGUAGE_CODE);

     arp_util_tax.debug('CREATE_REPORTING_CODES_EMEA(-)');

END CREATE_REPORTING_CODES_EMEA;

/*==========================================================================+
|  Procedure:    CREATE_REP_CODE_ASSOC_EMEA                                 |
|  Description:  This is the  procedure that creates reporting_codes        |
|                for the reporting type EMEA_VAT_REPORTING_TYPE,            |
|                for both AP and AR rates                                   |
|                                                                           |
|  ARGUMENTS  :                                                             |
|                                                                           |
|  NOTES                                                                    |
|                                                                           |
|  History                                                                  |
|  29-Sep-04  Taniya        Created                                         |
|                                                                           |
+===========================================================================*/

PROCEDURE CREATE_REP_CODE_ASSOC_EMEA
IS
BEGIN
  arp_util_tax.debug('CREATE_REP_CODE_ASSOC_EMEA(+)');
  arp_util_tax.debug('p_reporting_type_code = '||'EMEA_VAT_REPORTING_TYPE');

  arp_util_tax.debug('Inserting into ZX_REPORT_CODES_ASSOC table for AP tax codes');

  INSERT
   INTO   ZX_REPORT_CODES_ASSOC(
          REPORTING_CODE_ASSOC_ID,
          ENTITY_CODE            ,
          ENTITY_ID              ,
          REPORTING_TYPE_ID      ,
          REPORTING_CODE_ID      ,
          EXCEPTION_CODE         ,
          EFFECTIVE_FROM         ,
          EFFECTIVE_TO           ,
          CREATED_BY             ,
          CREATION_DATE          ,
          LAST_UPDATED_BY        ,
          LAST_UPDATE_DATE       ,
          LAST_UPDATE_LOGIN      ,
          REPORTING_CODE_CHAR_VALUE,
          REPORTING_CODE_DATE_VALUE,
          REPORTING_CODE_NUM_VALUE,
	  OBJECT_VERSION_NUMBER
                                )
    SELECT
          ZX_REPORT_CODES_ASSOC_S.nextval  ,
         'ZX_RATES'                        ,--ENTITY_CODE
          rates.TAX_RATE_ID           ,--ENTITY_ID
          report_codes.REPORTING_TYPE_ID, --REPORTING_TYPE_ID
          report_codes.REPORTING_CODE_ID  ,--REPORTING_CODE_ID
          NULL                             ,--EXCEPTION_CODE
           rates.EFFECTIVE_FROM   ,
          NULL                             ,--EFFECTIVE_TO
          fnd_global.user_id               ,
          SYSDATE                          ,
          fnd_global.user_id               ,
          SYSDATE                          ,
          fnd_global.conc_login_id         ,
          report_codes.REPORTING_CODE_CHAR_VALUE,--REPORTING_CODE_CHAR_VALUE
          report_codes.REPORTING_CODE_DATE_VALUE,--REPORTING_CODE_DATE_VALUE
          report_codes.REPORTING_CODE_NUM_VALUE , --REPORTING_CODE_NUM_VALUE
	  1
   FROM
          AP_TAX_CODES_ALL codes,
          ZX_REPORTING_TYPES_B reporting_types,
          ZX_REPORTING_CODES_B report_codes,
          ZX_RATES_B       rates,
-- Bug 7620818
          ZX_REGIMES_B reg
    WHERE
         codes.tax_id                    =  rates.tax_rate_id
    AND  reporting_types.reporting_type_id = report_codes.reporting_type_id
    AND  reporting_types.reporting_type_code ='EMEA_VAT_REPORTING_TYPE'
    AND  codes.tax_type = Decode(report_codes.REPORTING_CODE_CHAR_VALUE,
                                 'SALES_TAX','SALES',
                                 'EXEMPT','Exempt Vat',
                                 'CUSTOM BILL',InitCap(report_codes.REPORTING_CODE_CHAR_VALUE),
                                 'NON TAXABLE',InitCap(report_codes.REPORTING_CODE_CHAR_VALUE),
                                 report_codes.REPORTING_CODE_CHAR_VALUE)
    AND  reporting_types.tax_regime_code IS NULL
    AND  reporting_types.tax IS NULL
    --AND  report_codes.record_type_code   = 'MIGRATED'
    AND  rates.record_type_code          = 'MIGRATED'
-- Bug 7620818
    AND  rates.tax_regime_code = reg.tax_regime_code
    AND  reg.country_code in ('BE','CH','CZ','DE','ES','FR','HU',
                              'IT','KP','KR','NO','PL','PT','SK', 'IL')
-- End Bug 7620818
    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id   =
                           report_codes.reporting_type_id);

   arp_util_tax.debug('Inserting into ZX_REPORT_CODES_ASSOC table for AR tax codes');

INSERT
   INTO   ZX_REPORT_CODES_ASSOC(
          REPORTING_CODE_ASSOC_ID,
          ENTITY_CODE            ,
          ENTITY_ID              ,
          REPORTING_TYPE_ID      ,
          REPORTING_CODE_ID      ,
          EXCEPTION_CODE         ,
          EFFECTIVE_FROM         ,
          EFFECTIVE_TO           ,
          CREATED_BY             ,
          CREATION_DATE          ,
          LAST_UPDATED_BY        ,
          LAST_UPDATE_DATE       ,
          LAST_UPDATE_LOGIN      ,
          REPORTING_CODE_CHAR_VALUE,
          REPORTING_CODE_DATE_VALUE,
          REPORTING_CODE_NUM_VALUE,
	  OBJECT_VERSION_NUMBER
                                )
    SELECT
          ZX_REPORT_CODES_ASSOC_S.nextval  ,
         'ZX_RATES'                        ,--ENTITY_CODE
          rates.TAX_RATE_ID           ,--ENTITY_ID
          report_codes.REPORTING_TYPE_ID, --REPORTING_TYPE_ID
          report_codes.REPORTING_CODE_ID  ,--REPORTING_CODE_ID
          NULL                             ,--EXCEPTION_CODE
           rates.EFFECTIVE_FROM   ,
          NULL                             ,--EFFECTIVE_TO
          fnd_global.user_id               ,
          SYSDATE                          ,
          fnd_global.user_id               ,
          SYSDATE                          ,
          fnd_global.conc_login_id         ,
          report_codes.REPORTING_CODE_CHAR_VALUE,--REPORTING_CODE_CHAR_VALUE
          report_codes.REPORTING_CODE_DATE_VALUE,--REPORTING_CODE_DATE_VALUE
          report_codes.REPORTING_CODE_NUM_VALUE , --REPORTING_CODE_NUM_VALUE
	  1
   FROM
          AR_VAT_TAX_ALL codes,
          ZX_REPORTING_TYPES_B reporting_types,
          ZX_REPORTING_CODES_B report_codes,
          ZX_RATES_B       rates,
-- Bug 7620818
          ZX_REGIMES_B reg
    WHERE
         codes.vat_tax_id                    =  rates.tax_rate_id
    AND  reporting_types.reporting_type_id = report_codes.reporting_type_id
    AND  reporting_types.reporting_type_code ='EMEA_VAT_REPORTING_TYPE'
    AND  codes.tax_type = DECODE(report_codes.REPORTING_CODE_CHAR_VALUE,
                                 'SERVICES','SERV',
                                  report_codes.REPORTING_CODE_CHAR_VALUE)
    AND  reporting_types.tax_regime_code IS NULL
    AND  reporting_types.tax IS NULL
    --AND  report_codes.record_type_code   = 'MIGRATED'
    AND  rates.record_type_code          = 'MIGRATED'
-- Bug 7620818
    AND  rates.tax_regime_code = reg.tax_regime_code
    AND  reg.country_code in ('BE','CH','CZ','DE','ES','FR','HU',
                              'IT','KP','KR','NO','PL','PT','SK', 'IL')
-- End Bug 7620818
    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id   = report_codes.reporting_type_id);

    arp_util_tax.debug('CREATE_REP_CODE_ASSOC_EMEA(-)');

END CREATE_REP_CODE_ASSOC_EMEA;

/*===========================================================================+
|  Procedure:    CREATE_REP_ENT_REVERSE_VAT                                 |
|  Description:  This is the procedure for Reporting Entities migration     |
|                for UK Reverse Vat                                         |
|                                                                           |
|  ARGUMENTS  :  None                                                       |
|                                                                           |
|  NOTES                                                                    |
|                                                                           |
|  History                                                                  |
|  14-May-08       Taniya Sen     Created                                   |
|                                                                           |
+===========================================================================*/

PROCEDURE CREATE_REP_ENT_REVERSE_VAT
IS
BEGIN
  arp_util_tax.debug('CREATE_REP_ENT_REVERSE_VAT(+)');
  arp_util_tax.debug('p_reporting_type_code = '||'REVERSE_CHARGE_VAT');

  arp_util_tax.debug('Inserting into ZX_REPORTING_TYPES_B table...');

  INSERT WHEN  (NOT EXISTS (select 1 from zx_reporting_types_b
                          where  reporting_type_code = l_reporting_type_code
                          and    tax_regime_code = l_tax_regime_code
                          and    tax = l_tax)
             ) THEN
    INTO  ZX_REPORTING_TYPES_B(
		REPORTING_TYPE_ID              ,
		REPORTING_TYPE_CODE            ,
		REPORTING_TYPE_DATATYPE_CODE   ,
		TAX_REGIME_CODE                ,
		TAX                            ,
		FORMAT_MASK                    ,
		MIN_LENGTH                     ,
		MAX_LENGTH                     ,
		LEGAL_MESSAGE_FLAG             ,
		EFFECTIVE_FROM                 ,
		EFFECTIVE_TO                   ,
		RECORD_TYPE_CODE               ,
		HAS_REPORTING_CODES_FLAG       ,
		CREATED_BY                     ,
		CREATION_DATE                  ,
		LAST_UPDATED_BY                ,
		LAST_UPDATE_DATE               ,
		LAST_UPDATE_LOGIN              ,
		REQUEST_ID                     ,
		PROGRAM_APPLICATION_ID         ,
		PROGRAM_ID                     ,
		PROGRAM_LOGIN_ID		,
		OBJECT_VERSION_NUMBER
           )
    VALUES(
           zx_reporting_types_b_s.nextval ,--REPORTING_TYPE_ID
           l_reporting_type_code          ,--REPORTING_TYPE_CODE
          'YES_NO'		          ,--REPORTING_TYPE_DATATYPE
	   l_tax_regime_code              ,--TAX_REGIME_CODE
           l_tax                          ,--TAX
           NULL                           ,--FORMAT_MASK
           1                              ,--MIN_LENGTH
           30                             ,--MAX_LENGTH
          'N'                             ,--LEGAL_MESSAGE_FLAG
           l_effective_from               ,--EFFECTIVE_FROM
           NULL                           ,--EFFECTIVE_TO
          'MIGRATED'                      ,--RECORD_TYPE_CODE
          'N'                             ,--HAS_REPORTING_CODES_FLAG
           fnd_global.user_id             ,--CREATED_BY
           SYSDATE                        ,--CREATION_DATE
           fnd_global.user_id             ,--LAST_UPDATED_BY
           SYSDATE                        ,--LAST_UPDATE_DATE
           fnd_global.conc_login_id       ,--LAST_UPDATE_LOGIN
           fnd_global.conc_request_id     ,--REQUEST_ID
           fnd_global.prog_appl_id        ,--PROGRAM_APPLICATION_ID
           fnd_global.conc_program_id     ,--PROGRAM_ID
           fnd_global.conc_login_id       ,--PROGRAM_LOGIN_ID
	   1                               --OBJECT_VERSION_NUMBER
          )
    SELECT
          'REVERSE_CHARGE_VAT'          l_reporting_type_code,
           rates.tax_regime_code        l_tax_regime_code,
           rates.tax                    l_tax,
           min(rates.effective_from)    l_effective_from
    FROM  zx_rates_b rates,
          ar_vat_tax_all codes
    WHERE rates.tax_rate_id = codes.vat_tax_id
    AND   codes.tax_type = 'REVERSE_CHARGE_VAT'
    AND   rates.record_type_code = 'MIGRATED'
    GROUP BY rates.tax_regime_code, rates.tax;

  arp_util_tax.debug('Inserting into ZX_REPORTING_TYPES_TL table...');

  INSERT INTO ZX_REPORTING_TYPES_TL(
           REPORTING_TYPE_ID      ,
           LANGUAGE               ,
           SOURCE_LANG            ,
           REPORTING_TYPE_NAME    ,
           CREATED_BY             ,
           CREATION_DATE          ,
           LAST_UPDATED_BY        ,
           LAST_UPDATE_DATE       ,
           LAST_UPDATE_LOGIN
          )
     SELECT
     	REPORTING_TYPE_ID	 ,
     	LANGUAGE_CODE		 ,
     	userenv('LANG')    	 ,
       'Reverse Charge VAT'      ,
        fnd_global.user_id       ,
        SYSDATE                  ,
        fnd_global.user_id       ,
        SYSDATE                  ,
        fnd_global.conc_login_id
    FROM
     (
        SELECT
           TYPES.REPORTING_TYPE_ID ,
           L.LANGUAGE_CODE
        FROM
           ZX_REPORTING_TYPES_B TYPES,
           FND_LANGUAGES L
        WHERE TYPES.RECORD_TYPE_CODE = 'MIGRATED'
        AND TYPES.REPORTING_TYPE_CODE = 'REVERSE_CHARGE_VAT'
        AND L.INSTALLED_FLAG in ('I', 'B')
     ) TYPES
    WHERE not exists
	       (select NULL
	        from ZX_REPORTING_TYPES_TL T
	        where T.REPORTING_TYPE_ID = TYPES.REPORTING_TYPE_ID
	        and T.LANGUAGE = TYPES.LANGUAGE_CODE);

  arp_util_tax.debug('Inserting into ZX_REPORT_TYPES_USAGES table...');

  INSERT INTO ZX_REPORT_TYPES_USAGES(
          REPORTING_TYPE_USAGE_ID,
          REPORTING_TYPE_ID      ,
          ENTITY_CODE            ,
          ENABLED_FLAG           ,
          CREATED_BY             ,
          CREATION_DATE          ,
          LAST_UPDATED_BY        ,
          LAST_UPDATE_DATE       ,
          LAST_UPDATE_LOGIN	 ,
	        OBJECT_VERSION_NUMBER
          )
    SELECT
          zx_report_types_usages_s.nextval,--REPORTING_TYPE_USAGE_ID
          types.reporting_type_id         ,--REPORTING_TYPE_ID
         'ZX_RATES'                       ,--ENTITY_CODE
         'Y'                              ,--ENABLED_FLAG
          fnd_global.user_id              ,--CREATED_BY
          SYSDATE                         ,--CREATION_DATE
          fnd_global.user_id              ,--LAST_UPDATED_BY
          SYSDATE                         ,--LAST_UPDATE_DATE
          fnd_global.conc_login_id        ,--LAST_UPDATE_LOGIN
	  1                                --OBJECT_VERSION_NUMBER
     FROM
          zx_reporting_types_b types
     WHERE types.reporting_type_code = 'REVERSE_CHARGE_VAT'
     --AND types.record_type_code    = 'MIGRATED'
     AND NOT EXISTS ( select 1 from zx_report_types_usages
                      where reporting_type_id = types.reporting_type_id
                      and entity_code = 'ZX_RATES');

  arp_util_tax.debug('Inserting into ZX_REPORTING_CODES_B table...');

  INSERT
    INTO  ZX_REPORTING_CODES_B(
		REPORTING_CODE_ID      ,
		EXCEPTION_CODE         ,
		EFFECTIVE_FROM         ,
		EFFECTIVE_TO           ,
		RECORD_TYPE_CODE       ,
		CREATED_BY                     ,
		CREATION_DATE                  ,
		LAST_UPDATED_BY                ,
		LAST_UPDATE_DATE               ,
		LAST_UPDATE_LOGIN              ,
		REQUEST_ID                     ,
		PROGRAM_APPLICATION_ID         ,
		PROGRAM_ID                     ,
		PROGRAM_LOGIN_ID		  ,
		REPORTING_CODE_CHAR_VALUE	  ,
		REPORTING_CODE_DATE_VALUE      ,
		REPORTING_CODE_NUM_VALUE       ,
		REPORTING_TYPE_ID		,
		OBJECT_VERSION_NUMBER
	   )
    SELECT
           zx_reporting_codes_b_s.nextval,--REPORTING_CODE_ID
           NULL                          ,--EXCEPTION_CODE
           EFFECTIVE_FROM                ,--EFFECTIVE_FROM
           NULL                          ,--EFFECTIVE_TO
          'MIGRATED'                     ,--RECORD_TYPE_CODE
           fnd_global.user_id            ,--CREATED_BY
           SYSDATE                       ,--CREATION_DATE
           fnd_global.user_id            ,--LAST_UPDATED_BY
           SYSDATE                       ,--LAST_UPDATE_DATE
           fnd_global.conc_login_id      ,--LAST_UPDATE_LOGIN
           fnd_global.conc_request_id    ,--REQUEST_ID
           fnd_global.prog_appl_id       ,--PROGRAM_APPLICATION_ID
           fnd_global.conc_program_id    ,--PROGRAM_ID
           fnd_global.conc_login_id      ,--PROGRAM_LOGIN_ID
           REPORTING_CODE_CHAR_VALUE     ,--REPORTING_CODE_CHAR_VALUE
	   NULL                                         ,--REPORTING_CODE_DATE_VALUE
	   NULL                                         ,--REPORTING_CODE_NUM_VALUE
	   REPORTING_TYPE_ID                            ,--REPORTING_TYPE_ID
	   1                                             --OBJECT_VERSION_NUMBER

    FROM
    (
      SELECT
           DISTINCT Upper(lookup_code) REPORTING_CODE_CHAR_VALUE,
           report_types.EFFECTIVE_FROM   EFFECTIVE_FROM,
	         report_types.REPORTING_TYPE_ID REPORTING_TYPE_ID,
	         report_types.REPORTING_TYPE_DATATYPE_CODE DATATYPE
      FROM
        ZX_REPORTING_TYPES_B report_types,
        FND_LOOKUPS          lookups
      WHERE
             report_types.REPORTING_TYPE_CODE = 'REVERSE_CHARGE_VAT'
      --AND  report_types.RECORD_TYPE_CODE    = 'MIGRATED'
      AND  lookups.LOOKUP_TYPE = 'ZX_TAX_TYPE_CATEGORY'
      --Consider only the following lookup_codes
      AND  lookups.LOOKUP_CODE = 'REVERSE_CHARGE_VAT'
      AND  NOT EXISTS
    	     (SELECT 1
            FROM ZX_REPORTING_CODES_B
            WHERE REPORTING_TYPE_ID = report_types.REPORTING_TYPE_ID
            AND REPORTING_CODE_CHAR_VALUE = UPPER(lookups.lookup_code)
	   )
  );

  arp_util_tax.debug('Inserting into ZX_REPORTING_CODES_TL table...');

  INSERT INTO ZX_REPORTING_CODES_TL(
           REPORTING_CODE_ID      ,
           LANGUAGE               ,
           SOURCE_LANG            ,
           REPORTING_CODE_NAME    ,
           CREATED_BY             ,
           CREATION_DATE          ,
           LAST_UPDATED_BY        ,
           LAST_UPDATE_DATE       ,
           LAST_UPDATE_LOGIN
          )
     SELECT
           codes.reporting_code_id ,
           lookups.language        ,
           lookups.source_lang     ,
	    CASE WHEN lookups.meaning = UPPER(lookups.meaning)
	     THEN    Initcap(lookups.meaning)
	     ELSE
		     lookups.meaning
	     END,
           fnd_global.user_id      ,
           sysdate                 ,
           fnd_global.user_id      ,
           sysdate                 ,
           fnd_global.conc_login_id
      FROM
	  ZX_REPORTING_TYPES_B TYPES,
          ZX_REPORTING_CODES_B CODES,
	  FND_LOOKUP_VALUES    lookups,
	  FND_LANGUAGES L
      WHERE

           TYPES.REPORTING_TYPE_ID     = CODES.REPORTING_TYPE_ID
      AND  TYPES.REPORTING_TYPE_CODE   = 'REVERSE_CHARGE_VAT'
      AND  lookups.LOOKUP_TYPE         = 'ZX_TAX_TYPE_CATEGORY'
      AND  CODES.REPORTING_CODE_CHAR_VALUE = Upper(lookups.lookup_code)
      AND  CODES.RECORD_TYPE_CODE      = 'MIGRATED'
      AND  lookups.VIEW_APPLICATION_ID = 0
      AND  lookups.SECURITY_GROUP_ID   = 0
      AND  lookups.LANGUAGE            = L.LANGUAGE_CODE(+)
      AND  L.INSTALLED_FLAG in ('I', 'B')
      AND  not exists
               (select NULL
                from ZX_REPORTING_CODES_TL T
                where T.REPORTING_CODE_ID = CODES.REPORTING_CODE_ID
                and T.LANGUAGE = L.LANGUAGE_CODE);

  arp_util_tax.debug('Inserting into ZX_REPORT_CODES_ASSOC table...');

  INSERT
   INTO   ZX_REPORT_CODES_ASSOC(
          REPORTING_CODE_ASSOC_ID,
          ENTITY_CODE            ,
          ENTITY_ID              ,
          REPORTING_TYPE_ID      ,
          REPORTING_CODE_ID      ,
          EXCEPTION_CODE         ,
          EFFECTIVE_FROM         ,
          EFFECTIVE_TO           ,
          CREATED_BY             ,
          CREATION_DATE          ,
          LAST_UPDATED_BY        ,
          LAST_UPDATE_DATE       ,
          LAST_UPDATE_LOGIN      ,
          REPORTING_CODE_CHAR_VALUE,
          REPORTING_CODE_DATE_VALUE,
          REPORTING_CODE_NUM_VALUE,
	  OBJECT_VERSION_NUMBER
                                )
    SELECT
          ZX_REPORT_CODES_ASSOC_S.nextval  ,
         'ZX_RATES'                        ,--ENTITY_CODE
          rates.TAX_RATE_ID           ,--ENTITY_ID
          report_codes.REPORTING_TYPE_ID, --REPORTING_TYPE_ID
          report_codes.REPORTING_CODE_ID  ,--REPORTING_CODE_ID
          NULL                             ,--EXCEPTION_CODE
          rates.EFFECTIVE_FROM   ,
          NULL                             ,--EFFECTIVE_TO
          fnd_global.user_id               ,
          SYSDATE                          ,
          fnd_global.user_id               ,
          SYSDATE                          ,
          fnd_global.conc_login_id         ,
          report_codes.REPORTING_CODE_CHAR_VALUE,--REPORTING_CODE_CHAR_VALUE
          report_codes.REPORTING_CODE_DATE_VALUE,--REPORTING_CODE_DATE_VALUE
          report_codes.REPORTING_CODE_NUM_VALUE , --REPORTING_CODE_NUM_VALUE
	  1
   FROM
          AR_VAT_TAX_ALL codes,
          ZX_REPORTING_TYPES_B reporting_types,
          ZX_REPORTING_CODES_B report_codes,
          ZX_RATES_B       rates
    WHERE
         codes.vat_tax_id                    =  rates.tax_rate_id
    AND  reporting_types.reporting_type_id = report_codes.reporting_type_id
    AND  reporting_types.reporting_type_code ='REVERSE_CHARGE_VAT'
    AND  codes.tax_type = report_codes.REPORTING_CODE_CHAR_VALUE
    AND  reporting_types.tax_regime_code = rates.tax_regime_code
    AND  reporting_types.tax = rates.tax
    --AND  report_codes.record_type_code   = 'MIGRATED'
    AND  rates.record_type_code          = 'MIGRATED'
    AND  not exists(select 1 from ZX_REPORT_CODES_ASSOC
                    where  entity_code         = 'ZX_RATES'
                    and    entity_id           = rates.tax_rate_id
                    and    reporting_type_id   = report_codes.reporting_type_id);

  arp_util_tax.debug('CREATE_REP_ENT_REVERSE_VAT(-)');

END CREATE_REP_ENT_REVERSE_VAT;

/*===========================================================================+
|  Procedure:    ZX_MIGRATE_REP_ENTITIES_MAIN                               |
|  Description:  This is the main procedure for Reporting Entities migration|
|                                                                           |
|  ARGUMENTS  :                                                             |
|                                                                           |
|  NOTES                                                                    |
|                                                                           |
|  History                                                                  |
|  29-Sep-04  Venkatavaradhan    Created                                    |
|                                                                           |
+===========================================================================*/


PROCEDURE ZX_MIGRATE_REP_ENTITIES_MAIN IS

BEGIN

         arp_util_tax.debug('ZX_MIGRATE_REP_ENTITIES_MAIN(+) ' );

         arp_util_tax.debug('Now calling Reporting Type Code...' );

         CREATE_ZX_REP_TYPE_CODES(null);

         arp_util_tax.debug('Now calling Reporting Association...' );

         CREATE_ZX_REPORTING_ASSOC(null);

         arp_util_tax.debug('Now calling Usages...' );

	 CREATE_REPORT_TYPES_USAGES;


	 /* Calling the procedures for EMEA VAT reporting type */
	 arp_util_tax.debug('ZX_MIGRATE_REP_ENTITIES_FOR_EMEA(+) ' );

	 arp_util_tax.debug('Now calling Reporting Type Code for EMEA...' );

	 CREATE_REPORTING_TYPE_EMEA;

         arp_util_tax.debug('Now calling Usages for EMEA...' );

	 CREATE_REPORT_TYP_USAGES_EMEA;

	 arp_util_tax.debug('Now calling Reporting Codes for EMEA...' );

	 CREATE_REPORTING_CODES_EMEA;

	 arp_util_tax.debug('Now calling Reporting Association...' );

	 CREATE_REP_CODE_ASSOC_EMEA;

	 arp_util_tax.debug('ZX_MIGRATE_REP_ENTITIES_FOR_EMEA(-) ' );

	 arp_util_tax.debug('ZX_MIGRATE_REP_ENTITIES_REVERSE_VAT(+) ' );

	 CREATE_REP_ENT_REVERSE_VAT;

	 arp_util_tax.debug('ZX_MIGRATE_REP_ENTITIES_REVERSE_VAT(-) ' );

         arp_util_tax.debug('ZX_MIGRATE_REP_ENTITIES_MAIN(-) ');


END ZX_MIGRATE_REP_ENTITIES_MAIN;

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



EXCEPTION
WHEN OTHERS THEN
    arp_util_tax.debug('Exception in constructor of Reporting Types Codes and Associations '||sqlerrm);

END ZX_MIGRATE_REP_ENTITIES_PKG ;

/
