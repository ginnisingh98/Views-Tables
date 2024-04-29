--------------------------------------------------------
--  DDL for Package Body ZX_MIGRATE_TAX_DEFAULT_HIER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_MIGRATE_TAX_DEFAULT_HIER" AS
/*$Header: zxtaxhiermigb.pls 120.40.12010000.2 2008/12/24 15:24:18 ssanka ship $ */

PG_DEBUG CONSTANT VARCHAR(1) default
                  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

L_MULTI_ORG_FLAG      FND_PRODUCT_GROUPS.MULTI_ORG_FLAG%TYPE;
L_ORG_ID	      NUMBER(15);

/*Private procedure forward declarations*/
PROCEDURE create_template;


/*=========================================================================+
 | PROCEDURE                                                               |
 |    migrate_default_hierarchy                                            |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This routine is a wrapper for migration of current AP/PO Default    |
 |     Hierarchy functionality to eBTax rules model.                       |
 |                                                                         |
 | SCOPE - PUBLIC                                                          |
 |                                                                         |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                 |
 |                                                                         |
 | CALLED FROM                                                             |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     15-Jan-04  Srinivas Lokam      Created.                             |
 |                                                                         |
 |=========================================================================*/


PROCEDURE migrate_default_hierarchy is
BEGIN
     IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('Migrate_Default_Hierarchy(+)');
     END IF;
     Savepoint Default_Setup;
     create_template; --Bug 4935978
     create_condition_groups;
     create_rules;
     create_process_results;
     IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('Migrate_Default_Hierarchy(-)');
     END IF;
EXCEPTION
         WHEN OTHERS THEN
             IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Migrate_default_hierarchy ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('Migrate_Default_Hierarchy(-)');
             END IF;
             Rollback To Default_Setup;
             --app_exception.raise_exception;
END migrate_default_hierarchy;


/*=========================================================================+
 | PROCEDURE                                                               |
 |    create_template                                                      |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This procedure is used to create determining factor templates        |
 |    explicitly for the purpose of rules determination                    |
 |									   |
 | SCOPE - PUBLIC                                                          |
 |                                                                         |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                 |
 |                                                                         |
 | CALLED FROM                                                             |
 |        migrate_default_hierarchy                                        |
 | NOTES                                                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     23-Jan-06  Arnab Sengupta      Created as part of bug 4935978       |
 |=========================================================================*/

 PROCEDURE create_template IS
 BEGIN
      IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('create_template(+)');
     END IF;

  -- Determining factor template: STCC
  INSERT INTO ZX_DET_FACTOR_TEMPL_B
	(
	DET_FACTOR_TEMPL_CODE  ,
	TAX_REGIME_CODE        ,
	TEMPLATE_USAGE_CODE    ,
	RECORD_TYPE_CODE       ,
	LEDGER_ID              ,
	CHART_OF_ACCOUNTS_ID   ,
	DET_FACTOR_TEMPL_ID    ,
	CREATED_BY	       ,
	CREATION_DATE	       ,
	LAST_UPDATED_BY	       ,
	LAST_UPDATE_DATE       ,
	LAST_UPDATE_LOGIN      ,
	REQUEST_ID	       ,
	PROGRAM_APPLICATION_ID ,
	PROGRAM_ID	       ,
	PROGRAM_LOGIN_ID       ,
	OBJECT_VERSION_NUMBER
	)
SELECT
	'STCC'                          , --DET_FACTOR_TEMPL_CODE
	NULL                            , --TAX_REGIME_CODE
	'TAX_RULES'                     , --TEMPLATE_USAGE_CODE
	'MIGRATED'                      , --RECORD_TYPE_CODE
	NULL                            , --LEDGER_ID
	NULL                            , --CHART_OF_ACCOUNTS_ID
	zx_det_factor_templ_b_s.nextval , --DET_FACTOR_TEMPL_ID
	fnd_global.user_id              , --CREATED_BY
	SYSDATE                         , --CREATION_DATE
	fnd_global.user_id              , --LAST_UPDATED_BY
	SYSDATE                         , --LAST_UPDATE_DATE
	fnd_global.conc_login_id        , --LAST_UPDATE_LOGIN
	fnd_global.conc_request_id      , --Request Id
	fnd_global.prog_appl_id         , --Program Application ID
	fnd_global.conc_program_id      , --Program Id
	fnd_global.conc_login_id        , --Program Login ID
	1
FROM DUAL
WHERE not exists (select 1
                  from ZX_DET_FACTOR_TEMPL_B
                  where DET_FACTOR_TEMPL_CODE = 'STCC'
                  );

  --Determining factor template: LEASE_MGT_RATE_DET_TEMPL
  INSERT INTO ZX_DET_FACTOR_TEMPL_B
	(
	DET_FACTOR_TEMPL_CODE  ,
	TAX_REGIME_CODE        ,
	TEMPLATE_USAGE_CODE    ,
	RECORD_TYPE_CODE       ,
	LEDGER_ID              ,
	CHART_OF_ACCOUNTS_ID   ,
	DET_FACTOR_TEMPL_ID    ,
	CREATED_BY	       ,
	CREATION_DATE	       ,
	LAST_UPDATED_BY	       ,
	LAST_UPDATE_DATE       ,
	LAST_UPDATE_LOGIN      ,
	REQUEST_ID	       ,
	PROGRAM_APPLICATION_ID ,
	PROGRAM_ID	       ,
	PROGRAM_LOGIN_ID       ,
	OBJECT_VERSION_NUMBER
	)
SELECT
	'LEASE_MGT_RATE_DET_TEMPL'      , --DET_FACTOR_TEMPL_CODE
	NULL                            , --TAX_REGIME_CODE
	'TAX_RULES'                     , --TEMPLATE_USAGE_CODE
	'MIGRATED'                      , --RECORD_TYPE_CODE
	NULL                            , --LEDGER_ID
	NULL                            , --CHART_OF_ACCOUNTS_ID
	zx_det_factor_templ_b_s.nextval , --DET_FACTOR_TEMPL_ID
	fnd_global.user_id              , --CREATED_BY
	SYSDATE                         , --CREATION_DATE
	fnd_global.user_id              , --LAST_UPDATED_BY
	SYSDATE                         , --LAST_UPDATE_DATE
	fnd_global.conc_login_id        , --LAST_UPDATE_LOGIN
	fnd_global.conc_request_id      , --Request Id
	fnd_global.prog_appl_id         , --Program Application ID
	fnd_global.conc_program_id      , --Program Id
	fnd_global.conc_login_id        , --Program Login ID
	1
FROM DUAL
WHERE not exists (select 1
                  from ZX_DET_FACTOR_TEMPL_B
                  where DET_FACTOR_TEMPL_CODE = 'LEASE_MGT_RATE_DET_TEMPL'
                  );

INSERT INTO ZX_DET_FACTOR_TEMPL_TL
	(
	 LANGUAGE                    ,
	 SOURCE_LANG                 ,
	 DET_FACTOR_TEMPL_NAME       ,
	 DET_FACTOR_TEMPL_DESC       ,
	 DET_FACTOR_TEMPL_ID         ,
	 CREATION_DATE               ,
	 CREATED_BY                  ,
	 LAST_UPDATE_DATE            ,
	 LAST_UPDATED_BY             ,
	 LAST_UPDATE_LOGIN
	)
SELECT
	L.LANGUAGE_CODE          ,--LANGUAGE
	userenv('LANG')          ,--SOURCE_LANG
	Initcap(B.DET_FACTOR_TEMPL_CODE)  ,--DET_FACTOR_TEMPL_NAME
	B.DET_FACTOR_TEMPL_CODE  ,--DET_FACTOR_TEMPL_DESC
	B.DET_FACTOR_TEMPL_ID    ,--DET_FACTOR_TEMPL_ID
	SYSDATE                  ,--CREATION_DATE
	fnd_global.user_id       ,--CREATED_BY
	SYSDATE                  ,--LAST_UPDATE_DATE
	fnd_global.user_id       ,--LAST_UPDATED_BY
	fnd_global.conc_login_id  --LAST_UPDATE_LOGIN
FROM
    FND_LANGUAGES L,
    ZX_DET_FACTOR_TEMPL_B B
WHERE
    L.INSTALLED_FLAG in ('I', 'B')
AND B.DET_FACTOR_TEMPL_CODE IN ('STCC' , 'LEASE_MGT_RATE_DET_TEMPL')
AND  not exists
     (select 1
     from ZX_DET_FACTOR_TEMPL_TL T
     where T.DET_FACTOR_TEMPL_ID =  B.DET_FACTOR_TEMPL_ID
     and T.LANGUAGE = L.LANGUAGE_CODE);

-- Determining factor code of input factor tax_classification_code is part of
-- seed data

-- Create determining factor code for input factor PRODUCT_FISCAL_CLASS
INSERT INTO ZX_DETERMINING_FACTORS_B
(
  DETERMINING_FACTOR_CODE      ,
  DETERMINING_FACTOR_CLASS_CODE,
  VALUE_SET                    ,
  TAX_PARAMETER_CODE           ,
  DATA_TYPE_CODE               ,
  TAX_FUNCTION_CODE            ,
  RECORD_TYPE_CODE             ,
  TAX_REGIME_DET_FLAG          ,
  TAX_SUMMARIZATION_FLAG       ,
  TAX_RULES_FLAG               ,
  TAXABLE_BASIS_FLAG           ,
  TAX_CALCULATION_FLAG         ,
  INTERNAL_FLAG                ,
  RECORD_ONLY_FLAG             ,
  CREATION_DATE                ,
  LAST_UPDATE_DATE             ,
  REQUEST_ID                   ,
  PROGRAM_APPLICATION_ID       ,
  PROGRAM_ID                   ,
  PROGRAM_LOGIN_ID             ,
  DETERMINING_FACTOR_ID        ,
  CREATED_BY                   ,
  LAST_UPDATED_BY              ,
  LAST_UPDATE_LOGIN            ,
  OBJECT_VERSION_NUMBER        )

SELECT
   'LEASE_MGT_PROD_FISC_CLASS'    DETERMINING_FACTOR_CODE,
   'PRODUCT_FISCAL_CLASS'       DETERMINING_FACTOR_CLASS_CODE,
   NULL                         VALUE_SET,
   NULL                         TAX_PARAMETER_CODE,
   'ALPHANUMERIC'               DATA_TYPE_CODE,
    NULL                        TAX_FUNCTION_CODE,
   'MIGRATED'                   RECORD_TYPE_CODE,
   'N'                          TAX_REGIME_DET_FLAG,
   'N'                          TAX_SUMMARIZATION_FLAG,
   'Y'                          TAX_RULES_FLAG,
   'N'                          TAXABLE_BASIS_FLAG,
   'N'				TAX_CALCULATION_FLAG,
   'N'				INTERNAL_FLAG,
   'N'				RECORD_ONLY_FLAG,
   SYSDATE                         , --CREATION_DATE
   SYSDATE                         , --LAST_UPDATE_DATE
   fnd_global.conc_request_id      , --Request Id
   fnd_global.prog_appl_id         , --Program Application ID
   fnd_global.conc_program_id      , --Program Id
   fnd_global.conc_login_id        , --Program Login ID
   ZX_DETERMINING_FACTORS_B_S.nextval  DETERMINING_FACTOR_ID        ,
   fnd_global.user_id              , --CREATED_BY
   fnd_global.user_id              , --LAST_UPDATED_BY
   fnd_global.conc_login_id        , --LAST_UPDATE_LOGIN
   1    OBJECT_VERSION_NUMBER
FROM DUAL
WHERE NOT EXISTS (SELECT 1
                    FROM ZX_DETERMINING_FACTORS_B
                   WHERE DETERMINING_FACTOR_CLASS_CODE ='PRODUCT_FISCAL_CLASS'
                     AND DETERMINING_FACTOR_CODE = 'LEASE_MGT_PROD_FISC_CLASS');


-- Create determining factor code for  PARTY_FISCAL_CLASS
INSERT INTO ZX_DETERMINING_FACTORS_B
(
  DETERMINING_FACTOR_CODE      ,
  DETERMINING_FACTOR_CLASS_CODE,
  VALUE_SET                    ,
  TAX_PARAMETER_CODE           ,
  DATA_TYPE_CODE               ,
  TAX_FUNCTION_CODE            ,
  RECORD_TYPE_CODE             ,
  TAX_REGIME_DET_FLAG          ,
  TAX_SUMMARIZATION_FLAG       ,
  TAX_RULES_FLAG               ,
  TAXABLE_BASIS_FLAG           ,
  TAX_CALCULATION_FLAG         ,
  INTERNAL_FLAG                ,
  RECORD_ONLY_FLAG             ,
  CREATION_DATE                ,
  LAST_UPDATE_DATE             ,
  REQUEST_ID                   ,
  PROGRAM_APPLICATION_ID       ,
  PROGRAM_ID                   ,
  PROGRAM_LOGIN_ID             ,
  DETERMINING_FACTOR_ID        ,
  CREATED_BY                   ,
  LAST_UPDATED_BY              ,
  LAST_UPDATE_LOGIN            ,
  OBJECT_VERSION_NUMBER        )

SELECT
   'LEASE_MGT_PTY_FISC_CLASS'   DETERMINING_FACTOR_CODE,
   'PARTY_FISCAL_CLASS'            DETERMINING_FACTOR_CLASS_CODE,
   NULL                            VALUE_SET,
   NULL                            TAX_PARAMETER_CODE,
   'ALPHANUMERIC'                  DATA_TYPE_CODE,
    NULL                           TAX_FUNCTION_CODE,
   'MIGRATED'                      RECORD_TYPE_CODE,
   'N'                             TAX_REGIME_DET_FLAG,
   'N'                             TAX_SUMMARIZATION_FLAG,
   'Y'                             TAX_RULES_FLAG,
   'N'                             TAXABLE_BASIS_FLAG,
   'N'				   TAX_CALCULATION_FLAG,
   'N'				   INTERNAL_FLAG,
   'N'				   RECORD_ONLY_FLAG,
   SYSDATE                         , --CREATION_DATE
   SYSDATE                         , --LAST_UPDATE_DATE
   fnd_global.conc_request_id      , --Request Id
   fnd_global.prog_appl_id         , --Program Application ID
   fnd_global.conc_program_id      , --Program Id
   fnd_global.conc_login_id        , --Program Login ID
   ZX_DETERMINING_FACTORS_B_S.nextval  DETERMINING_FACTOR_ID        ,
   fnd_global.user_id              , --CREATED_BY
   fnd_global.user_id              , --LAST_UPDATED_BY
   fnd_global.conc_login_id        , --LAST_UPDATE_LOGIN
   1    OBJECT_VERSION_NUMBER
FROM DUAL
WHERE NOT EXISTS (SELECT 1
                    FROM ZX_DETERMINING_FACTORS_B
                   WHERE DETERMINING_FACTOR_CLASS_CODE ='PARTY_FISCAL_CLASS'
                     AND DETERMINING_FACTOR_CODE = 'LEASE_MGT_PTY_FISC_CLASS');

-- Determining factor code of input factor USER_DEFINED_FISC_CLASS is part of seed
-- data

-- Insert into the determining factors tl table
INSERT INTO ZX_DET_FACTORS_TL
	(
	LANGUAGE               ,
	SOURCE_LANG            ,
	DETERMINING_FACTOR_NAME,
	DETERMINING_FACTOR_DESC,
	CREATION_DATE          ,
	LAST_UPDATE_DATE       ,
	DETERMINING_FACTOR_ID  ,
	CREATED_BY             ,
	LAST_UPDATED_BY        ,
	LAST_UPDATE_LOGIN
	)
SELECT
	L.LANGUAGE_CODE          ,--LANGUAGE
	userenv('LANG')          ,--SOURCE_LANG
	Initcap(B.DETERMINING_FACTOR_CODE),--DETERMINING_FACTOR_NAME
	B.DETERMINING_FACTOR_CODE,--DETERMINING_FACTOR_DESC
	SYSDATE                  ,--CREATION_DATE
	SYSDATE                  ,--LAST_UPDATE_DATE
	B.DETERMINING_FACTOR_ID  ,--DETERMINING_FACTOR_ID
	fnd_global.user_id       ,--CREATED_BY
	fnd_global.user_id       ,--LAST_UPDATED_BY
	fnd_global.conc_login_id  --LAST_UPDATE_LOGIN
FROM
    FND_LANGUAGES L,
    ZX_DETERMINING_FACTORS_B B
WHERE
    L.INSTALLED_FLAG in ('I', 'B')
AND ((B.DETERMINING_FACTOR_CLASS_CODE ='PARTY_FISCAL_CLASS'
           AND B.DETERMINING_FACTOR_CODE = 'LEASE_MGT_PTY_FISC_CLASS')
      OR (B.DETERMINING_FACTOR_CLASS_CODE ='PRODUCT_FISCAL_CLASS'
            AND B.DETERMINING_FACTOR_CODE = 'LEASE_MGT_PROD_FISC_CLASS'))
AND  NOT EXISTS
     (SELECT 1
     FROM ZX_DET_FACTORS_TL T
     WHERE T.DETERMINING_FACTOR_ID =  B.DETERMINING_FACTOR_ID
     AND T.LANGUAGE = L.LANGUAGE_CODE);

-- insert the template detail table for STCC
INSERT INTO ZX_DET_FACTOR_TEMPL_DTL
(
   DETERMINING_FACTOR_CLASS_CODE,
   DETERMINING_FACTOR_CQ_CODE   ,
   DETERMINING_FACTOR_CODE      ,
   REQUIRED_FLAG                ,
   RECORD_TYPE_CODE             ,
   CREATION_DATE                ,
   LAST_UPDATE_DATE             ,
   REQUEST_ID                   ,
   PROGRAM_APPLICATION_ID       ,
   PROGRAM_ID                   ,
   TAX_REGIME_DET_LEVEL_CODE    ,
   TAX_PARAMETER_CODE           ,
   PROGRAM_LOGIN_ID             ,
   DET_FACTOR_TEMPL_DTL_ID      ,
   DET_FACTOR_TEMPL_ID          ,
   CREATED_BY                   ,
   LAST_UPDATED_BY              ,
   LAST_UPDATE_LOGIN            ,
   OBJECT_VERSION_NUMBER
)
SELECT
   factor.DETERMINING_FACTOR_CLASS_CODE, --DETERMINING_FACTOR_CLASS_CODE
   NULL				       , --DETERMINING_FACTOR_CQ_CODE
   factor.DETERMINING_FACTOR_CODE      , --DETERMINING_FACTOR_CODE
   'Y'				       , --REQUIRED_FLAG
   'MIGRATED'                          , --RECORD_TYPE_CODE
   SYSDATE                             , --CREATION_DATE
   SYSDATE                             , --LAST_UPDATE_DATE
   factor.REQUEST_ID                   , --REQUEST_ID
   factor.PROGRAM_APPLICATION_ID       , --PROGRAM_APPLICATION_ID
   factor.PROGRAM_ID                   , --PROGRAM_ID
   NULL                                , --TAX_REGIME_DET_LEVEL_CODE
   factor.TAX_PARAMETER_CODE           , --TAX_PARAMETER_CODE
   factor.PROGRAM_LOGIN_ID             , --PROGRAM_LOGIN_ID
   ZX_DET_FACTOR_TEMPL_DTL_S.nextval   , --DET_FACTOR_TEMPL_DTL_ID
   templ.DET_FACTOR_TEMPL_ID           , --DET_FACTOR_TEMPL_ID
   factor.CREATED_BY                   , --CREATED_BY
   factor.LAST_UPDATED_BY              , --LAST_UPDATED_BY
   factor.LAST_UPDATE_LOGIN            , --LAST_UPDATE_LOGIN
   factor.OBJECT_VERSION_NUMBER          --OBJECT_VERSION_NUMBER

FROM ZX_DET_FACTOR_TEMPL_B templ,
     ZX_DETERMINING_FACTORS_B factor
WHERE templ.DET_FACTOR_TEMPL_CODE = 'STCC'
  AND factor.DETERMINING_FACTOR_CLASS_CODE ='TRX_INPUT_FACTOR'
  AND factor.DETERMINING_FACTOR_CODE = 'TAX_CLASSIFICATION_CODE'
  AND NOT EXISTS
    (select 1 from ZX_DET_FACTOR_TEMPL_DTL DTL_TEMP2
     where DET_FACTOR_TEMPL_ID = templ.DET_FACTOR_TEMPL_ID
     and   DETERMINING_FACTOR_CLASS_CODE = factor.DETERMINING_FACTOR_CLASS_CODE
     and   DETERMINING_FACTOR_CODE  = factor.DETERMINING_FACTOR_CODE);

-- insert the template detail table for LEASE_MGT_RATE_DET_TEMPL
INSERT INTO ZX_DET_FACTOR_TEMPL_DTL
(
   DETERMINING_FACTOR_CLASS_CODE,
   DETERMINING_FACTOR_CQ_CODE   ,
   DETERMINING_FACTOR_CODE      ,
   REQUIRED_FLAG                ,
   RECORD_TYPE_CODE             ,
   CREATION_DATE                ,
   LAST_UPDATE_DATE             ,
   REQUEST_ID                   ,
   PROGRAM_APPLICATION_ID       ,
   PROGRAM_ID                   ,
   TAX_REGIME_DET_LEVEL_CODE    ,
   TAX_PARAMETER_CODE           ,
   PROGRAM_LOGIN_ID             ,
   DET_FACTOR_TEMPL_DTL_ID      ,
   DET_FACTOR_TEMPL_ID          ,
   CREATED_BY                   ,
   LAST_UPDATED_BY              ,
   LAST_UPDATE_LOGIN            ,
   OBJECT_VERSION_NUMBER
)
SELECT
   factor.DETERMINING_FACTOR_CLASS_CODE, --DETERMINING_FACTOR_CLASS_CODE
   decode(factor.DETERMINING_FACTOR_CLASS_CODE,
          'PARTY_FISCAL_CLASS', 'BILL_TO_PARTY',
          NULL)    		       , --DETERMINING_FACTOR_CQ_CODE
   factor.DETERMINING_FACTOR_CODE      , --DETERMINING_FACTOR_CODE
   decode(factor.DETERMINING_FACTOR_CODE,
          'TAX_CLASSIFICATION_CODE', 'Y',
          'N')    		       , --REQUIRED_FLAG
   'MIGRATED'                          , --RECORD_TYPE_CODE
   SYSDATE                             , --CREATION_DATE
   SYSDATE                             , --LAST_UPDATE_DATE
   factor.REQUEST_ID                   , --REQUEST_ID
   factor.PROGRAM_APPLICATION_ID       , --PROGRAM_APPLICATION_ID
   factor.PROGRAM_ID                   , --PROGRAM_ID
   NULL                                , --TAX_REGIME_DET_LEVEL_CODE
   factor.TAX_PARAMETER_CODE           , --TAX_PARAMETER_CODE
   factor.PROGRAM_LOGIN_ID             , --PROGRAM_LOGIN_ID
   ZX_DET_FACTOR_TEMPL_DTL_S.nextval   , --DET_FACTOR_TEMPL_DTL_ID
   templ.DET_FACTOR_TEMPL_ID           , --DET_FACTOR_TEMPL_ID
   factor.CREATED_BY                   , --CREATED_BY
   factor.LAST_UPDATED_BY              , --LAST_UPDATED_BY
   factor.LAST_UPDATE_LOGIN            , --LAST_UPDATE_LOGIN
   factor.OBJECT_VERSION_NUMBER          --OBJECT_VERSION_NUMBER

FROM ZX_DET_FACTOR_TEMPL_B templ,
     ZX_DETERMINING_FACTORS_B factor
WHERE templ.DET_FACTOR_TEMPL_CODE = 'LEASE_MGT_RATE_DET_TEMPL'
  AND ((factor.DETERMINING_FACTOR_CLASS_CODE ='TRX_INPUT_FACTOR'
        AND factor.DETERMINING_FACTOR_CODE IN ('TAX_CLASSIFICATION_CODE',
                                               'USER_DEFINED_FISC_CLASS'))
      OR (factor.DETERMINING_FACTOR_CLASS_CODE ='PARTY_FISCAL_CLASS'
          AND factor.DETERMINING_FACTOR_CODE = 'LEASE_MGT_PTY_FISC_CLASS')
      OR (factor.DETERMINING_FACTOR_CLASS_CODE ='PRODUCT_FISCAL_CLASS'
          AND factor.DETERMINING_FACTOR_CODE = 'LEASE_MGT_PROD_FISC_CLASS')
          )
  AND NOT EXISTS
    (select 1 from ZX_DET_FACTOR_TEMPL_DTL DTL_TEMP2
     where DET_FACTOR_TEMPL_ID = templ.DET_FACTOR_TEMPL_ID
     and   DETERMINING_FACTOR_CLASS_CODE = factor.DETERMINING_FACTOR_CLASS_CODE
--     and   DETERMINING_FACTOR_CQ_CODE = cqtemp.DETERMINING_FACTOR_CQ_CODE
     and   DETERMINING_FACTOR_CODE  = factor.DETERMINING_FACTOR_CODE);

END create_template;

/*=========================================================================+
 | PROCEDURE                                                               |
 |    create_condition_groups                                              |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This routine inserts data INTO ZX_CONDITION_GROUPS_B,_TL for each of |
 |    AP/PO default Hierarchy options defined in AP,PO system parameters   |
 |    This routine has number of INSERT...SELECTs based on the AP,PO       |
 |    Hierarchy setup.Each of the INSERT..SELECT is having UNION ALL of two|
 |    SELECT statements,                                                   |
 |         one for AP setup and another for PO setup                       |
 |    For Example,while processing the Supplier options check in the AP/PO |
 |    Hierarchy process,in INSERT..SELECT,one select statement will be for |
 |    AP supplier option and another for PO supplier option.               |
 |                                                                         |
 | SCOPE - PUBLIC                                                          |
 |                                                                         |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                 |
 |                                                                         |
 | CALLED FROM                                                             |
 |        migrate_default_hierarchy                                        |
 | NOTES                                                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     15-Jan-04  Srinivas Lokam      Created.                             |
 |     30-Jan-04  Srinivas Lokam      Added INPUT parameters,AND conditions|
 |                                    in SELECT statements for handling    |
 |                                    SYNC process.                        |
 |=========================================================================*/

PROCEDURE create_condition_groups(p_name IN VARCHAR2 DEFAULT NULL) IS
BEGIN
     IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('Create_Condition_Groups(+)');
     END IF;

--Insert records into both CONDITION_GROUPS and CONDITIONS.
--Insert of Input tax classification codes
--Bug 4935978
--As part of this bug we are not going to prefix I_ to any condition group code
--We will directly insert the LOOKUP CODE for INPUT CLASSIFICATION lookup types

INSERT ALL
WHEN ( not exists
(select 1 from zx_condition_groups_b
 where condition_group_code=l_condition_group_code)
 ) THEN
INTO ZX_CONDITION_GROUPS_B
(
	CONDITION_GROUP_CODE            ,
	DET_FACTOR_TEMPL_CODE           ,
	COUNTRY_CODE                    ,
	MORE_THAN_MAX_COND_FLAG         ,
	ENABLED_FLAG                    ,
	DETERMINING_FACTOR_CODE1        ,
	TAX_PARAMETER_CODE1             ,
	DATA_TYPE1_CODE                 ,
	DETERMINING_FACTOR_CLASS1_CODE  ,
	DETERMINING_FACTOR_CQ1_CODE     ,
	OPERATOR1_CODE                  ,
	ALPHANUMERIC_VALUE1             ,
	RECORD_TYPE_CODE                ,
	CONDITION_GROUP_ID              ,
	CONSTRAINT_ID                   ,
        CREATED_BY                      ,
        CREATION_DATE                   ,
        LAST_UPDATED_BY                 ,
        LAST_UPDATE_DATE                ,
        LAST_UPDATE_LOGIN               ,
        REQUEST_ID                      ,
        PROGRAM_APPLICATION_ID          ,
        PROGRAM_ID                      ,
        PROGRAM_LOGIN_ID		,
	OBJECT_VERSION_NUMBER
)
VALUES
(
	l_condition_group_code            ,
	DET_FACTOR_TEMPL_CODE           ,
	COUNTRY_CODE                    ,
	MORE_THAN_MAX_COND_FLAG         ,
	ENABLED_FLAG                    ,
	DETERMINING_FACTOR_CODE1        ,
	TAX_PARAMETER_CODE1             ,
	DATA_TYPE1_CODE                 ,
	DETERMINING_FACTOR_CLASS1_CODE  ,
	DETERMINING_FACTOR_CQ1_CODE     ,
	OPERATOR1_CODE                  ,
	ALPHANUMERIC_VALUE1             ,
       'MIGRATED'                       ,
        zx_condition_groups_b_s.nextval ,
	CONSTRAINT_ID                   ,
        fnd_global.user_id              ,
        SYSDATE                         ,
        fnd_global.user_id              ,
        SYSDATE                         ,
        fnd_global.conc_login_id        ,
        fnd_global.conc_request_id      ,
        fnd_global.prog_appl_id         ,
        fnd_global.conc_program_id      ,
        fnd_global.conc_login_id	,
	1
)
WHEN (not exists
      (select 1 from zx_conditions
      where condition_group_code    = l_condition_group_code
      and   determining_factor_code = determining_factor_code1
      and   determining_factor_class_code =
            determining_factor_class1_code)
      ) THEN
INTO ZX_CONDITIONS
(
 	DETERMINING_FACTOR_CODE         ,
 	CONDITION_GROUP_CODE            ,
 	TAX_PARAMETER_CODE              ,
 	DATA_TYPE_CODE                  ,
 	DETERMINING_FACTOR_CLASS_CODE   ,
	DETERMINING_FACTOR_CQ_CODE      ,
	OPERATOR_CODE                   ,
        RECORD_TYPE_CODE                ,
        IGNORE_FLAG                     ,
        ALPHANUMERIC_VALUE              ,
        CONDITION_ID                    ,
        CREATED_BY                      ,
        CREATION_DATE                   ,
        LAST_UPDATED_BY                 ,
        LAST_UPDATE_DATE                ,
        LAST_UPDATE_LOGIN               ,
        REQUEST_ID                      ,
        PROGRAM_APPLICATION_ID          ,
        PROGRAM_ID                      ,
        PROGRAM_LOGIN_ID                ,
	OBJECT_VERSION_NUMBER
)
VALUES
(
        DETERMINING_FACTOR_CODE1        ,
	l_condition_group_code            ,
	TAX_PARAMETER_CODE1             ,
	DATA_TYPE1_CODE                 ,
	DETERMINING_FACTOR_CLASS1_CODE  ,
	DETERMINING_FACTOR_CQ1_CODE     ,
	OPERATOR1_CODE                  ,
       'MIGRATED'                       ,
       'N'                              ,
        ALPHANUMERIC_VALUE1             ,
        zx_conditions_s.nextval         ,
        fnd_global.user_id              ,
        SYSDATE                         ,
        fnd_global.user_id              ,
        SYSDATE                         ,
        fnd_global.conc_login_id        ,
        fnd_global.conc_request_id      ,
        fnd_global.prog_appl_id         ,
        fnd_global.conc_program_id      ,
        fnd_global.conc_login_id        ,
        1
)
SELECT distinct
      codes.name             l_condition_group_code  ,
       'STCC'                            DET_FACTOR_TEMPL_CODE  ,
       NULL                              COUNTRY_CODE           ,
      'N'                                MORE_THAN_MAX_COND_FLAG,
       'Y'           ENABLED_FLAG           , --Bug 5090631
       'TAX_CLASSIFICATION_CODE'         DETERMINING_FACTOR_CODE1      ,
       'TAX_CLASSIFICATION_CODE'         TAX_PARAMETER_CODE1           ,
      'ALPHANUMERIC'                     DATA_TYPE1_CODE               ,
      'TRX_INPUT_FACTOR'                 DETERMINING_FACTOR_CLASS1_CODE,
       NULL                              DETERMINING_FACTOR_CQ1_CODE   ,
      '='                                OPERATOR1_CODE                ,
       codes.name
                                         ALPHANUMERIC_VALUE1           ,
       NULL                              CONSTRAINT_ID
FROM
    ap_tax_codes_all codes --Bug 5061471
WHERE
    codes.tax_type = 'TAX_GROUP'
AND  codes.name  = nvl(p_name,codes.name);

-- Insert of Output tax classification codes
--Bug 4935978
--As part of this bug we are not going to prefix I_ to any condition group code
--We will directly insert the LOOKUP CODE for OUTPUT CLASSIFICATION lookup types
--Tax Constraint Id will be appended if it is not null

INSERT ALL
WHEN ( not exists
(select 1 from zx_condition_groups_b
 where condition_group_code=l_condition_group_code)
 ) THEN
INTO ZX_CONDITION_GROUPS_B
(
	CONDITION_GROUP_CODE            ,
	DET_FACTOR_TEMPL_CODE           ,
	COUNTRY_CODE                    ,
	MORE_THAN_MAX_COND_FLAG         ,
	ENABLED_FLAG                    ,
	DETERMINING_FACTOR_CODE1        ,
	TAX_PARAMETER_CODE1             ,
	DATA_TYPE1_CODE                 ,
	DETERMINING_FACTOR_CLASS1_CODE  ,
	DETERMINING_FACTOR_CQ1_CODE     ,
	OPERATOR1_CODE                  ,
	ALPHANUMERIC_VALUE1             ,
	RECORD_TYPE_CODE                ,
	CONDITION_GROUP_ID              ,
	CONSTRAINT_ID                   ,
        CREATED_BY                      ,
        CREATION_DATE                   ,
        LAST_UPDATED_BY                 ,
        LAST_UPDATE_DATE                ,
        LAST_UPDATE_LOGIN               ,
        REQUEST_ID                      ,
        PROGRAM_APPLICATION_ID          ,
        PROGRAM_ID                      ,
        PROGRAM_LOGIN_ID		,
	OBJECT_VERSION_NUMBER
)
VALUES
(
	l_condition_group_code            ,
	DET_FACTOR_TEMPL_CODE           ,
	COUNTRY_CODE                    ,
	MORE_THAN_MAX_COND_FLAG         ,
	ENABLED_FLAG                    ,
	DETERMINING_FACTOR_CODE1        ,
	TAX_PARAMETER_CODE1             ,
	DATA_TYPE1_CODE                 ,
	DETERMINING_FACTOR_CLASS1_CODE  ,
	DETERMINING_FACTOR_CQ1_CODE     ,
	OPERATOR1_CODE                  ,
	ALPHANUMERIC_VALUE1             ,
       'MIGRATED'                       ,
        zx_condition_groups_b_s.nextval ,
	CONSTRAINT_ID                   ,
        fnd_global.user_id              ,
        SYSDATE                         ,
        fnd_global.user_id              ,
        SYSDATE                         ,
        fnd_global.conc_login_id        ,
        fnd_global.conc_request_id      ,
        fnd_global.prog_appl_id         ,
        fnd_global.conc_program_id      ,
        fnd_global.conc_login_id	,
	1
)
WHEN (not exists
      (select 1 from zx_conditions
      where condition_group_code    = l_condition_group_code
      and   determining_factor_code = determining_factor_code1
      and   determining_factor_class_code =
            determining_factor_class1_code)
      ) THEN
INTO ZX_CONDITIONS
(
 	DETERMINING_FACTOR_CODE         ,
 	CONDITION_GROUP_CODE            ,
 	TAX_PARAMETER_CODE              ,
 	DATA_TYPE_CODE                  ,
 	DETERMINING_FACTOR_CLASS_CODE   ,
	DETERMINING_FACTOR_CQ_CODE      ,
	OPERATOR_CODE                   ,
        RECORD_TYPE_CODE                ,
        IGNORE_FLAG                     ,
        ALPHANUMERIC_VALUE              ,
        CONDITION_ID                    ,
        CREATED_BY                      ,
        CREATION_DATE                   ,
        LAST_UPDATED_BY                 ,
        LAST_UPDATE_DATE                ,
        LAST_UPDATE_LOGIN               ,
        REQUEST_ID                      ,
        PROGRAM_APPLICATION_ID          ,
        PROGRAM_ID                      ,
        PROGRAM_LOGIN_ID                 ,
	OBJECT_VERSION_NUMBER
)
VALUES
(
        DETERMINING_FACTOR_CODE1        ,
	l_condition_group_code            ,
	TAX_PARAMETER_CODE1             ,
	DATA_TYPE1_CODE                 ,
	DETERMINING_FACTOR_CLASS1_CODE  ,
	DETERMINING_FACTOR_CQ1_CODE     ,
	OPERATOR1_CODE                  ,
       'MIGRATED'                       ,
       'N'                              ,
        ALPHANUMERIC_VALUE1             ,
        zx_conditions_s.nextval         ,
        fnd_global.user_id              ,
        SYSDATE                         ,
        fnd_global.user_id              ,
        SYSDATE                         ,
        fnd_global.conc_login_id        ,
        fnd_global.conc_request_id      ,
        fnd_global.prog_appl_id         ,
        fnd_global.conc_program_id      ,
        fnd_global.conc_login_id        ,
        1
)
SELECT
      DISTINCT
      SUBSTRB(ar_vat.tax_code,1, 40)
        || decode(ar_vat.tax_constraint_id,
                  NULL, '', '~'||ar_vat.tax_constraint_id) l_condition_group_code,
      'STCC'                            DET_FACTOR_TEMPL_CODE,
      NULL                              COUNTRY_CODE           ,
      'N'                               MORE_THAN_MAX_COND_FLAG,
      'Y'                                ENABLED_FLAG           , --Bug 5090631
      'TAX_CLASSIFICATION_CODE'         DETERMINING_FACTOR_CODE1      ,
      'TAX_CLASSIFICATION_CODE'         TAX_PARAMETER_CODE1           ,
       'ALPHANUMERIC'                    DATA_TYPE1_CODE               ,
      'TRX_INPUT_FACTOR'                DETERMINING_FACTOR_CLASS1_CODE,
       NULL                             DETERMINING_FACTOR_CQ1_CODE   ,
      '='                               OPERATOR1_CODE                ,
       ar_vat.tax_code
                                         ALPHANUMERIC_VALUE1           ,
       ar_vat.TAX_CONSTRAINT_ID          CONSTRAINT_ID
FROM
    AR_VAT_TAX_ALL_B  ar_vat --Bug 5061471
WHERE
    ar_vat.tax_type IN ( 'TAX_GROUP','LOCATION')
OR EXISTS ( SELECT 1
              FROM ar_system_parameters_all sys
             WHERE ar_vat.set_of_books_id = sys.set_of_books_id
               AND ar_vat.org_id = sys.org_id
               AND sys.tax_method = 'SALES_TAX')
--Added following AND condition for Sync process
AND  ar_vat.tax_code  = nvl(p_name,ar_vat.tax_Code);

-- create condition set and conditions for the OKL migration
-- creat the separate condition sets for BILL_TO_PARTY
-- det_factor_cq_code

INSERT ALL
WHEN ( not exists
(select 1 from zx_condition_groups_b
 where SUBSTR(condition_group_code, 1, 44) = SUBSTR(l_condition_group_code, 1,44)
       and DET_FACTOR_TEMPL_CODE = l_det_factor_templ_code)
 ) THEN
INTO ZX_CONDITION_GROUPS_B
(
	CONDITION_GROUP_CODE            ,
	DET_FACTOR_TEMPL_CODE           ,
	COUNTRY_CODE                    ,
	MORE_THAN_MAX_COND_FLAG         ,
	ENABLED_FLAG                    ,
	DETERMINING_FACTOR_CODE1        ,
	TAX_PARAMETER_CODE1             ,
	DATA_TYPE1_CODE                 ,
	DETERMINING_FACTOR_CLASS1_CODE  ,
	DETERMINING_FACTOR_CQ1_CODE     ,
	OPERATOR1_CODE                  ,
	ALPHANUMERIC_VALUE1             ,

	DETERMINING_FACTOR_CODE2        ,
	TAX_PARAMETER_CODE2             ,
	DATA_TYPE2_CODE                 ,
	DETERMINING_FACTOR_CLASS2_CODE  ,
	DETERMINING_FACTOR_CQ2_CODE     ,
	OPERATOR2_CODE                  ,
	ALPHANUMERIC_VALUE2             ,

	DETERMINING_FACTOR_CODE3        ,
	TAX_PARAMETER_CODE3             ,
	DATA_TYPE3_CODE                 ,
	DETERMINING_FACTOR_CLASS3_CODE  ,
	DETERMINING_FACTOR_CQ3_CODE     ,
	OPERATOR3_CODE                  ,
	ALPHANUMERIC_VALUE3             ,

	DETERMINING_FACTOR_CODE4        ,
	TAX_PARAMETER_CODE4             ,
	DATA_TYPE4_CODE                 ,
	DETERMINING_FACTOR_CLASS4_CODE  ,
	DETERMINING_FACTOR_CQ4_CODE     ,
	OPERATOR4_CODE                  ,
	ALPHANUMERIC_VALUE4             ,

	RECORD_TYPE_CODE                ,
	CONDITION_GROUP_ID              ,
	CONSTRAINT_ID                   ,
        CREATED_BY                      ,
        CREATION_DATE                   ,
        LAST_UPDATED_BY                 ,
        LAST_UPDATE_DATE                ,
        LAST_UPDATE_LOGIN               ,
        REQUEST_ID                      ,
        PROGRAM_APPLICATION_ID          ,
        PROGRAM_ID                      ,
        PROGRAM_LOGIN_ID		,
	OBJECT_VERSION_NUMBER
)
VALUES
(
	l_condition_group_code            ,
	l_det_factor_templ_code           ,
	COUNTRY_CODE                    ,
	MORE_THAN_MAX_COND_FLAG         ,
	ENABLED_FLAG                    ,
        -- create first condition
	DETERMINING_FACTOR_CODE1        ,
	TAX_PARAMETER_CODE1             ,
	DATA_TYPE1_CODE                 ,
	DETERMINING_FACTOR_CLASS1_CODE  ,
	DETERMINING_FACTOR_CQ1_CODE     ,
	OPERATOR1_CODE                  ,
	ALPHANUMERIC_VALUE1             ,

        -- create second condition

        (CASE WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
             THEN DETERMINING_FACTOR_CODE2
             WHEN ALPHANUMERIC_VALUE2 IS NULL
                AND ALPHANUMERIC_VALUE3 IS NOT NULL
             THEN DETERMINING_FACTOR_CODE3
             ELSE DETERMINING_FACTOR_CODE4
             END),        --DETERMINING_FACTOR_CODE2,

        (CASE WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
             THEN TAX_PARAMETER_CODE2
             WHEN ALPHANUMERIC_VALUE2 IS NULL
                AND ALPHANUMERIC_VALUE3 IS NOT NULL
             THEN TAX_PARAMETER_CODE3
             ELSE TAX_PARAMETER_CODE4
             END),        --TAX_PARAMETER_CODE2,

        (CASE WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
             THEN DATA_TYPE2_CODE
             WHEN ALPHANUMERIC_VALUE2 IS NULL
                AND ALPHANUMERIC_VALUE3 IS NOT NULL
             THEN DATA_TYPE3_CODE
             ELSE DATA_TYPE4_CODE
             END),        --DATA_TYPE2_CODE,

        (CASE WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
             THEN DETERMINING_FACTOR_CLASS2_CODE
             WHEN ALPHANUMERIC_VALUE2 IS NULL
                AND ALPHANUMERIC_VALUE3 IS NOT NULL
             THEN DETERMINING_FACTOR_CLASS3_CODE
             ELSE DETERMINING_FACTOR_CLASS4_CODE
             END),        --DETERMINING_FACTOR_CLASS2_CODE,

        (CASE WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
             THEN DETERMINING_FACTOR_CQ2_CODE
             WHEN ALPHANUMERIC_VALUE2 IS NULL
                AND ALPHANUMERIC_VALUE3 IS NOT NULL
             THEN DETERMINING_FACTOR_CQ3_CODE
             ELSE DETERMINING_FACTOR_CQ4_CODE
             END),        --DETERMINING_FACTOR_CQ2_CODE,

        (CASE WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
             THEN OPERATOR2_CODE
             WHEN ALPHANUMERIC_VALUE2 IS NULL
                AND ALPHANUMERIC_VALUE3 IS NOT NULL
             THEN OPERATOR3_CODE
             ELSE OPERATOR4_CODE
             END),        --OPERATOR2_CODE,

        (CASE WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
             THEN ALPHANUMERIC_VALUE2
             WHEN ALPHANUMERIC_VALUE2 IS NULL
                AND ALPHANUMERIC_VALUE3 IS NOT NULL
             THEN ALPHANUMERIC_VALUE3
             ELSE ALPHANUMERIC_VALUE4
             END),        --ALPHANUMERIC_VALUE2,

        -- create third condition

        (CASE WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
               AND ALPHANUMERIC_VALUE3 IS NOT NULL
             THEN DETERMINING_FACTOR_CODE3
             WHEN ALPHANUMERIC_VALUE2 IS NULL
               AND ALPHANUMERIC_VALUE3 IS NULL
             THEN NULL
             ELSE DETERMINING_FACTOR_CODE4
             END),         --DETERMINING_FACTOR_CODE3,

        (CASE WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
               AND ALPHANUMERIC_VALUE3 IS NOT NULL
             THEN TAX_PARAMETER_CODE3
             WHEN ALPHANUMERIC_VALUE2 IS NULL
               AND ALPHANUMERIC_VALUE3 IS NULL
             THEN NULL
             ELSE TAX_PARAMETER_CODE4
             END),         --TAX_PARAMETER_CODE3,

        (CASE WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
               AND ALPHANUMERIC_VALUE3 IS NOT NULL
             THEN DATA_TYPE3_CODE
             WHEN ALPHANUMERIC_VALUE2 IS NULL
               AND ALPHANUMERIC_VALUE3 IS NULL
             THEN NULL
             ELSE DATA_TYPE4_CODE
             END),         --DATA_TYPE3_CODE,

        (CASE WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
               AND ALPHANUMERIC_VALUE3 IS NOT NULL
             THEN DETERMINING_FACTOR_CLASS3_CODE
             WHEN ALPHANUMERIC_VALUE2 IS NULL
               AND ALPHANUMERIC_VALUE3 IS NULL
             THEN NULL
             ELSE DETERMINING_FACTOR_CLASS4_CODE
             END),         --DETERMINING_FACTOR_CLASS3_CODE,

        (CASE WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
               AND ALPHANUMERIC_VALUE3 IS NOT NULL
             THEN DETERMINING_FACTOR_CQ3_CODE
             WHEN ALPHANUMERIC_VALUE2 IS NULL
               AND ALPHANUMERIC_VALUE3 IS NULL
             THEN NULL
             ELSE DETERMINING_FACTOR_CQ4_CODE
             END),         --DETERMINING_FACTOR_CQ3_CODE,

        (CASE WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
               AND ALPHANUMERIC_VALUE3 IS NOT NULL
             THEN OPERATOR3_CODE
             WHEN ALPHANUMERIC_VALUE2 IS NULL
               AND ALPHANUMERIC_VALUE3 IS NULL
             THEN NULL
             ELSE OPERATOR4_CODE
             END),         --OPERATOR3_CODE,

        (CASE WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
               AND ALPHANUMERIC_VALUE3 IS NOT NULL
             THEN ALPHANUMERIC_VALUE3
             WHEN ALPHANUMERIC_VALUE2 IS NULL
               AND ALPHANUMERIC_VALUE3 IS NULL
             THEN NULL
             ELSE ALPHANUMERIC_VALUE4
             END),         --ALPHANUMERIC_VALUE3,

        -- create forth condition

        (CASE WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
                AND ALPHANUMERIC_VALUE3 IS NOT NULL
             THEN DETERMINING_FACTOR_CODE4
             ELSE NULL
             END),         --DETERMINING_FACTOR_CODE4,

        (CASE WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
                AND ALPHANUMERIC_VALUE3 IS NOT NULL
             THEN TAX_PARAMETER_CODE4
             ELSE NULL
             END),         --TAX_PARAMETER_CODE4,

        (CASE WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
                AND ALPHANUMERIC_VALUE3 IS NOT NULL
             THEN DATA_TYPE4_CODE
             ELSE NULL
             END),         --DATA_TYPE4_CODE,

        (CASE WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
                AND ALPHANUMERIC_VALUE3 IS NOT NULL
             THEN DETERMINING_FACTOR_CLASS4_CODE
             ELSE NULL
             END),         --DETERMINING_FACTOR_CLASS4_CODE,

        (CASE WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
                AND ALPHANUMERIC_VALUE3 IS NOT NULL
             THEN DETERMINING_FACTOR_CQ4_CODE
             ELSE NULL
             END),         --DETERMINING_FACTOR_CQ4_CODE,

        (CASE WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
                AND ALPHANUMERIC_VALUE3 IS NOT NULL
             THEN OPERATOR4_CODE
             ELSE NULL
             END),         --OPERATOR4_CODE,

        (CASE WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
                AND ALPHANUMERIC_VALUE3 IS NOT NULL
             THEN ALPHANUMERIC_VALUE4
             ELSE NULL
             END),         --ALPHANUMERIC_VALUE4,


       'MIGRATED'                       ,
        zx_condition_groups_b_s.nextval ,
	CONSTRAINT_ID                   ,
        fnd_global.user_id              ,
        SYSDATE                         ,
        fnd_global.user_id              ,
        SYSDATE                         ,
        fnd_global.conc_login_id        ,
        fnd_global.conc_request_id      ,
        fnd_global.prog_appl_id         ,
        fnd_global.conc_program_id      ,
        fnd_global.conc_login_id	,
	1
)
-- create conditions for tax_classification_code
WHEN (not exists
      (select 1 from zx_conditions
      where condition_group_code    = l_condition_group_code
      and   determining_factor_code = determining_factor_code1
      and   determining_factor_class_code =
            determining_factor_class1_code)
      ) THEN
INTO ZX_CONDITIONS
(
 	DETERMINING_FACTOR_CODE         ,
 	CONDITION_GROUP_CODE            ,
 	TAX_PARAMETER_CODE              ,
 	DATA_TYPE_CODE                  ,
 	DETERMINING_FACTOR_CLASS_CODE   ,
	DETERMINING_FACTOR_CQ_CODE      ,
	OPERATOR_CODE                   ,
        RECORD_TYPE_CODE                ,
        IGNORE_FLAG                     ,
        ALPHANUMERIC_VALUE              ,
        CONDITION_ID                    ,
        CREATED_BY                      ,
        CREATION_DATE                   ,
        LAST_UPDATED_BY                 ,
        LAST_UPDATE_DATE                ,
        LAST_UPDATE_LOGIN               ,
        REQUEST_ID                      ,
        PROGRAM_APPLICATION_ID          ,
        PROGRAM_ID                      ,
        PROGRAM_LOGIN_ID                 ,
	OBJECT_VERSION_NUMBER
)
VALUES
(
        DETERMINING_FACTOR_CODE1        ,
	l_condition_group_code            ,
	TAX_PARAMETER_CODE1             ,
	DATA_TYPE1_CODE                 ,
	DETERMINING_FACTOR_CLASS1_CODE  ,
	DETERMINING_FACTOR_CQ1_CODE     ,
	OPERATOR1_CODE                  ,
       'MIGRATED'                       ,
       'N'                              ,
        ALPHANUMERIC_VALUE1             ,
        zx_conditions_s.nextval         ,
        fnd_global.user_id              ,
        SYSDATE                         ,
        fnd_global.user_id              ,
        SYSDATE                         ,
        fnd_global.conc_login_id        ,
        fnd_global.conc_request_id      ,
        fnd_global.prog_appl_id         ,
        fnd_global.conc_program_id      ,
        fnd_global.conc_login_id        ,
        1
)
-- create condition for product_fisc_classification
WHEN ALPHANUMERIC_VALUE2 IS NOT NULL
     AND (not exists
      (select 1 from zx_conditions
      where condition_group_code    = l_condition_group_code
      and   determining_factor_code = determining_factor_code2
      and   determining_factor_class_code =
            determining_factor_class2_code)
      ) THEN
INTO ZX_CONDITIONS
(
 	DETERMINING_FACTOR_CODE         ,
 	CONDITION_GROUP_CODE            ,
 	TAX_PARAMETER_CODE              ,
 	DATA_TYPE_CODE                  ,
 	DETERMINING_FACTOR_CLASS_CODE   ,
	DETERMINING_FACTOR_CQ_CODE      ,
	OPERATOR_CODE                   ,
        RECORD_TYPE_CODE                ,
        IGNORE_FLAG                     ,
        ALPHANUMERIC_VALUE              ,
        CONDITION_ID                    ,
        CREATED_BY                      ,
        CREATION_DATE                   ,
        LAST_UPDATED_BY                 ,
        LAST_UPDATE_DATE                ,
        LAST_UPDATE_LOGIN               ,
        REQUEST_ID                      ,
        PROGRAM_APPLICATION_ID          ,
        PROGRAM_ID                      ,
        PROGRAM_LOGIN_ID                ,
	OBJECT_VERSION_NUMBER
)
VALUES
(
        DETERMINING_FACTOR_CODE2        ,
	l_condition_group_code          ,
	TAX_PARAMETER_CODE2             ,
	DATA_TYPE2_CODE                 ,
	DETERMINING_FACTOR_CLASS2_CODE  ,
	DETERMINING_FACTOR_CQ2_CODE     ,
	OPERATOR2_CODE                  ,
       'MIGRATED'                       ,
       'N'                              ,
        ALPHANUMERIC_VALUE2             ,
        zx_conditions_s.nextval         ,
        fnd_global.user_id              ,
        SYSDATE                         ,
        fnd_global.user_id              ,
        SYSDATE                         ,
        fnd_global.conc_login_id        ,
        fnd_global.conc_request_id      ,
        fnd_global.prog_appl_id         ,
        fnd_global.conc_program_id      ,
        fnd_global.conc_login_id        ,
        1
)

-- create condition for trx_business_category_code
WHEN ALPHANUMERIC_VALUE3 IS NOT NULL
  AND (not exists
      (select 1 from zx_conditions
      where condition_group_code    = l_condition_group_code
      and   determining_factor_code = determining_factor_code3
      and   determining_factor_class_code =
            determining_factor_class3_code)
      ) THEN
INTO ZX_CONDITIONS
(
 	DETERMINING_FACTOR_CODE         ,
 	CONDITION_GROUP_CODE            ,
 	TAX_PARAMETER_CODE              ,
 	DATA_TYPE_CODE                  ,
 	DETERMINING_FACTOR_CLASS_CODE   ,
	DETERMINING_FACTOR_CQ_CODE      ,
	OPERATOR_CODE                   ,
        RECORD_TYPE_CODE                ,
        IGNORE_FLAG                     ,
        ALPHANUMERIC_VALUE              ,
        CONDITION_ID                    ,
        CREATED_BY                      ,
        CREATION_DATE                   ,
        LAST_UPDATED_BY                 ,
        LAST_UPDATE_DATE                ,
        LAST_UPDATE_LOGIN               ,
        REQUEST_ID                      ,
        PROGRAM_APPLICATION_ID          ,
        PROGRAM_ID                      ,
        PROGRAM_LOGIN_ID                 ,
	OBJECT_VERSION_NUMBER
)
VALUES
(
        DETERMINING_FACTOR_CODE3        ,
	l_condition_group_code            ,
	TAX_PARAMETER_CODE3             ,
	DATA_TYPE3_CODE                 ,
	DETERMINING_FACTOR_CLASS3_CODE  ,
	DETERMINING_FACTOR_CQ3_CODE     ,
	OPERATOR3_CODE                  ,
       'MIGRATED'                       ,
       'N'                              ,
        ALPHANUMERIC_VALUE3             ,
        zx_conditions_s.nextval         ,
        fnd_global.user_id              ,
        SYSDATE                         ,
        fnd_global.user_id              ,
        SYSDATE                         ,
        fnd_global.conc_login_id        ,
        fnd_global.conc_request_id      ,
        fnd_global.prog_appl_id         ,
        fnd_global.conc_program_id      ,
        fnd_global.conc_login_id        ,
        1
)

-- create condition for party_fisc_classification
WHEN ALPHANUMERIC_VALUE4 IS NOT NULL
  AND (not exists
      (select 1 from zx_conditions
      where condition_group_code    = l_condition_group_code
      and   determining_factor_code = determining_factor_code4
      and   determining_factor_class_code =
            determining_factor_class4_code)
      ) THEN
INTO ZX_CONDITIONS
(
 	DETERMINING_FACTOR_CODE         ,
 	CONDITION_GROUP_CODE            ,
 	TAX_PARAMETER_CODE              ,
 	DATA_TYPE_CODE                  ,
 	DETERMINING_FACTOR_CLASS_CODE   ,
	DETERMINING_FACTOR_CQ_CODE      ,
	OPERATOR_CODE                   ,
        RECORD_TYPE_CODE                ,
        IGNORE_FLAG                     ,
        ALPHANUMERIC_VALUE              ,
        CONDITION_ID                    ,
        CREATED_BY                      ,
        CREATION_DATE                   ,
        LAST_UPDATED_BY                 ,
        LAST_UPDATE_DATE                ,
        LAST_UPDATE_LOGIN               ,
        REQUEST_ID                      ,
        PROGRAM_APPLICATION_ID          ,
        PROGRAM_ID                      ,
        PROGRAM_LOGIN_ID                 ,
	OBJECT_VERSION_NUMBER
)
VALUES
(
        DETERMINING_FACTOR_CODE4        ,
	l_condition_group_code            ,
	TAX_PARAMETER_CODE4             ,
	DATA_TYPE4_CODE                 ,
	DETERMINING_FACTOR_CLASS4_CODE  ,
	DETERMINING_FACTOR_CQ4_CODE     ,
	OPERATOR4_CODE                  ,
       'MIGRATED'                       ,
       'N'                              ,
        ALPHANUMERIC_VALUE4             ,
        zx_conditions_s.nextval         ,
        fnd_global.user_id              ,
        SYSDATE                         ,
        fnd_global.user_id              ,
        SYSDATE                         ,
        fnd_global.conc_login_id        ,
        fnd_global.conc_request_id      ,
        fnd_global.prog_appl_id         ,
        fnd_global.conc_program_id      ,
        fnd_global.conc_login_id        ,
        1
)

SELECT
--      DISTINCT
      SUBSTRB(ar_vat.tax_code,1, 44)
        ||ZX_MIGRATE_UTIL.GET_NEXT_SEQID('ZX_CONDITION_GROUPS_B_S')  l_condition_group_code,
      'LEASE_MGT_RATE_DET_TEMPL'        l_det_factor_templ_code,
      NULL                              COUNTRY_CODE           ,
      'N'                               MORE_THAN_MAX_COND_FLAG,
      'Y'                               ENABLED_FLAG           , --Bug 5090631

      'TAX_CLASSIFICATION_CODE'         DETERMINING_FACTOR_CODE1      ,
      'TAX_CLASSIFICATION_CODE'         TAX_PARAMETER_CODE1           ,
       'ALPHANUMERIC'                   DATA_TYPE1_CODE               ,
      'TRX_INPUT_FACTOR'                DETERMINING_FACTOR_CLASS1_CODE,
       NULL                             DETERMINING_FACTOR_CQ1_CODE   ,
      '='                               OPERATOR1_CODE                ,
       ar_grp_tax.tax_code              ALPHANUMERIC_VALUE1           ,

      NVL2(ar_grp.product_fisc_classification,'LEASE_MGT_PROD_FISC_CLASS', NULL)       DETERMINING_FACTOR_CODE2      ,
      NVL2(ar_grp.product_fisc_classification,'PRODUCT_ID' , NULL)                     TAX_PARAMETER_CODE2           ,
      NVL2(ar_grp.product_fisc_classification,'ALPHANUMERIC', NULL)                    DATA_TYPE2_CODE               ,
      NVL2(ar_grp.product_fisc_classification,'PRODUCT_FISCAL_CLASS', NULL)            DETERMINING_FACTOR_CLASS2_CODE,
      NULL                             DETERMINING_FACTOR_CQ2_CODE   ,
      NVL2(ar_grp.product_fisc_classification,'=' , NULL) OPERATOR2_CODE                ,
      ar_grp.product_fisc_classification   ALPHANUMERIC_VALUE2           ,

      NVL2(ar_grp.trx_business_category_code,'USER_DEFINED_FISC_CLASS', NULL)         DETERMINING_FACTOR_CODE3      ,
      NVL2(ar_grp.trx_business_category_code,'USER_DEFINED_FISC_CLASS', NULL)         TAX_PARAMETER_CODE3           ,
      NVL2(ar_grp.trx_business_category_code, 'ALPHANUMERIC', NULL)                   DATA_TYPE3_CODE               ,
      NVL2(ar_grp.trx_business_category_code,'TRX_INPUT_FACTOR', NULL)                DETERMINING_FACTOR_CLASS3_CODE,
      NULL                             DETERMINING_FACTOR_CQ3_CODE   ,
      NVL2(ar_grp.trx_business_category_code,'=', NULL)                               OPERATOR3_CODE                ,
      ar_grp.trx_business_category_code  ALPHANUMERIC_VALUE3           ,

      NVL2(ar_grp.party_fisc_classification,'LEASE_MGT_PTY_FISC_CLASS', NULL)        DETERMINING_FACTOR_CODE4      ,
      NVL2(ar_grp.party_fisc_classification,'BILL_TO_PARTY_TAX_PROF_ID', NULL)       TAX_PARAMETER_CODE4           ,
      NVL2(ar_grp.party_fisc_classification,'ALPHANUMERIC', NULL)                    DATA_TYPE4_CODE               ,
      NVL2(ar_grp.party_fisc_classification,'PARTY_FISCAL_CLASS', NULL)              DETERMINING_FACTOR_CLASS4_CODE,
      NVL2(ar_grp.party_fisc_classification,'BILL_TO_PARTY', NULL)                   DETERMINING_FACTOR_CQ4_CODE   ,
      NVL2(ar_grp.party_fisc_classification,'=', NULL)                               OPERATOR4_CODE                ,
      ar_grp.party_fisc_classification   ALPHANUMERIC_VALUE4           ,

      ar_grp_tax.TAX_CONSTRAINT_ID         CONSTRAINT_ID
FROM
    AR_VAT_TAX_ALL_B  ar_vat,
    AR_TAX_GROUP_CODES_ALL ar_grp,
    ar_vat_tax_all_b  ar_grp_tax
WHERE ar_grp_tax.tax_type = 'TAX_GROUP'
  AND ar_grp_tax.vat_tax_id = ar_grp.TAX_GROUP_ID
  AND ar_vat.vat_tax_id = ar_grp.tax_code_id
  AND ar_vat.tax_type <> 'TAX_GROUP'
  AND ar_grp.product_fisc_classification ||
      ar_grp.trx_business_category_code||
      ar_grp.party_fisc_classification IS NOT NULL
--Added following AND condition for Sync process
AND  ar_vat.tax_code  = nvl(p_name,ar_vat.tax_Code);


INSERT INTO ZX_CONDITION_GROUPS_TL
(
 LANGUAGE                    ,
 SOURCE_LANG                 ,
 CONDITION_GROUP_NAME        ,
 CONDITION_GROUP_ID          ,
 CREATION_DATE               ,
 CREATED_BY                  ,
 LAST_UPDATE_DATE            ,
 LAST_UPDATED_BY             ,
 LAST_UPDATE_LOGIN
)
SELECT
    L.LANGUAGE_CODE          ,
    userenv('LANG')          ,
    CASE WHEN B.CONDITION_GROUP_CODE = UPPER(B.CONDITION_GROUP_CODE)
     THEN    Initcap(B.CONDITION_GROUP_CODE)
     ELSE
             B.CONDITION_GROUP_CODE
     END
     ,
    B.CONDITION_GROUP_ID     ,
    SYSDATE                  ,
    fnd_global.user_id       ,
    SYSDATE                  ,
    fnd_global.user_id       ,
    fnd_global.conc_login_id
FROM
    FND_LANGUAGES L,
    ZX_CONDITION_GROUPS_B B
WHERE
    L.INSTALLED_FLAG in ('I', 'B')
AND RECORD_TYPE_CODE = 'MIGRATED'
AND  not exists
     (select 1
     from  ZX_CONDITION_GROUPS_TL T
     where T.CONDITION_GROUP_ID =  B.CONDITION_GROUP_ID
     and T.LANGUAGE = L.LANGUAGE_CODE);
     IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('Create_Condition_Groups(-)');
     END IF;
EXCEPTION
         WHEN OTHERS THEN
             IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Create_condition_groups ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('Create_Condition_Groups(-)');
             END IF;
             --app_exception.raise_exception;
END create_condition_groups;


/*=========================================================================+
 | PROCEDURE                                                               |
 |    create_rules                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This routine inserts data into ZX_RULES_B/_TL by following the same |
 |     logic used while inserting the data in ZX_CONDITION_GROUPS_B.       |
 |                                                                         |
 | SCOPE - PUBLIC                                                          |
 |                                                                         |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                 |
 |                                                                         |
 | CALLED FROM                                                             |
 |        migrate_default_hierarchy                                        |
 | NOTES                                                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     15-Jan-04  Srinivas Lokam      Created.                             |
 |     30-Jan-04  Srinivas Lokam      Added INPUT parameters,AND conditions|
 |                                    in SELECT statements for handling    |
 |                                    SYNC process.                        |
 |                                                                         |
 |=========================================================================*/

PROCEDURE create_rules(p_tax IN VARCHAR2 DEFAULT NULL) IS
BEGIN
     IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('Create_Rules(+)');
     END IF;


--Rules for AP, AR Tax setup

/* Commented Bug : 5061471
INSERT ALL
WHEN (exists (select 1
              from zx_rates_b rates, FND_LOOKUP_VALUES codes
	      where codes.language    = userenv('LANG')
              and   codes.view_application_id = 0
	      and   rates.tax_rate_code = NVL(codes.tag,codes.lookup_code)
              and   codes.lookup_type IN('ZX_INPUT_CLASSIFICATIONS', 'ZX_OUTPUT_CLASSIFICATIONS')
	      and   rates.tax = L_TAX
	      and   rates.tax_regime_code = L_TAX_REGIME_CODE
	      and   rates.record_type_code = 'MIGRATED'
	      )
       )
THEN
INTO ZX_RULES_B_TMP
(
 TAX_RULE_ID                    ,
 TAX_RULE_CODE                  ,
 TAX                            ,
 TAX_REGIME_CODE                ,
 SERVICE_TYPE_CODE              ,
 APPLICATION_ID                 ,
 RECOVERY_TYPE_CODE             ,
 PRIORITY                       ,
 SYSTEM_DEFAULT_FLAG            ,
 EFFECTIVE_FROM                 ,
 EFFECTIVE_TO                   ,
 ENABLED_FLAG                   ,
 RECORD_TYPE_CODE               ,
 DET_FACTOR_TEMPL_CODE          ,
 CONTENT_OWNER_ID               ,
 CREATED_BY             ,
 CREATION_DATE          ,
 LAST_UPDATED_BY        ,
 LAST_UPDATE_DATE       ,
 LAST_UPDATE_LOGIN      ,
 REQUEST_ID             ,
 PROGRAM_APPLICATION_ID ,
 PROGRAM_ID             ,
 PROGRAM_LOGIN_ID  	,
OBJECT_VERSION_NUMBER
)
VALUES
(
       zx_rules_b_s.nextval,--TAX_RULE_ID
       L_TAX               ,--TAX_RULE_CODE
       L_TAX               ,--TAX
       L_TAX_REGIME_CODE   ,--TAX_REGIME_CODE
      'DET_DIRECT_RATE'    ,--SERVICE_TYPE_CODE
       NULL                ,--APPLICATION_ID
       NULL                ,--RECOVERY_TYPE_CODE
       1                   ,--PRIORITY
      'N'                  ,--SYSTEM_DEFAULT_FLAG  :  Bug 4590290
       EFFECTIVE_FROM      ,
       EFFECTIVE_TO        ,
      'Y'                  ,--ENABLED_FLAG
      'MIGRATED'           ,--RECORD_TYPE_CODE
      'STCC'       ,--DET_FACTOR_TEMPL_CODE
       CONTENT_OWNER_ID               ,
       fnd_global.user_id             ,
       SYSDATE                        ,
       fnd_global.user_id             ,
       SYSDATE                        ,
       fnd_global.conc_login_id       ,
       fnd_global.conc_request_id     ,--Request Id
       fnd_global.prog_appl_id        ,--Program Application ID
       fnd_global.conc_program_id     ,--Program Id
       fnd_global.conc_login_id       , --Program Login ID
	1
)
SELECT
       taxes.TAX             L_TAX                 ,
       taxes.TAX_REGIME_CODE L_TAX_REGIME_CODE     ,
       taxes.EFFECTIVE_FROM  EFFECTIVE_FROM      ,
       taxes.EFFECTIVE_TO    EFFECTIVE_TO        ,
       taxes.CONTENT_OWNER_ID
FROM
    ZX_TAXES_B taxes
WHERE
     taxes.TAX_TYPE_CODE NOT IN ('AWT','OFFSET')
AND  taxes.RECORD_TYPE_CODE  = 'MIGRATED'
AND  taxes.tax_type_code <> 'LOCATION' --Bug Fix 4626074
AND NOT EXISTS ( select 1
		 from  ZX_RULES_B_TMP rule
  	         where
		     rule.CONTENT_OWNER_ID   = taxes.CONTENT_OWNER_ID
		 and rule.TAX_REGIME_CODE    = taxes.TAX_REGIME_CODE
		 and rule.TAX                = taxes.TAX
		 and rule.SERVICE_TYPE_CODE  = 'DET_DIRECT_RATE'
		 and rule.RECOVERY_TYPE_CODE IS NULL
		 and rule.TAX_RULE_CODE      = taxes.TAX
		 and rule.EFFECTIVE_FROM     = taxes.EFFECTIVE_FROM
		 and rule.PRIORITY           = 1
                 ) ;
*/
--Bug : 5061471
-- Create Direct Rate Rule for distinct tax_regime, tax and content_owner_id combination for both AP and AR
INSERT ALL INTO ZX_RULES_B_TMP
(
 TAX_RULE_ID                    ,
 TAX_RULE_CODE                  ,
 TAX                            ,
 TAX_REGIME_CODE                ,
 SERVICE_TYPE_CODE              ,
 APPLICATION_ID                 ,
 RECOVERY_TYPE_CODE             ,
 PRIORITY                       ,
 SYSTEM_DEFAULT_FLAG            ,
 EFFECTIVE_FROM                 ,
 EFFECTIVE_TO                   ,
 ENABLED_FLAG                   ,
 RECORD_TYPE_CODE               ,
 DET_FACTOR_TEMPL_CODE          ,
 CONTENT_OWNER_ID               ,
 CREATED_BY             ,
 CREATION_DATE          ,
 LAST_UPDATED_BY        ,
 LAST_UPDATE_DATE       ,
 LAST_UPDATE_LOGIN      ,
 REQUEST_ID             ,
 PROGRAM_APPLICATION_ID ,
 PROGRAM_ID             ,
 PROGRAM_LOGIN_ID  	,
 OBJECT_VERSION_NUMBER
)
VALUES
(
       zx_rules_b_s.nextval,--TAX_RULE_ID
       L_TAX               ,--TAX_RULE_CODE
       L_TAX               ,--TAX
       L_TAX_REGIME_CODE   ,--TAX_REGIME_CODE
      'DET_DIRECT_RATE'    ,--SERVICE_TYPE_CODE
       NULL                ,--APPLICATION_ID
       NULL                ,--RECOVERY_TYPE_CODE
       PRIORITY            ,
      'N'                  ,--SYSTEM_DEFAULT_FLAG  :  Bug 4590290
       EFFECTIVE_FROM      ,
       EFFECTIVE_TO        ,
      'Y'                  ,--ENABLED_FLAG
      'MIGRATED'           ,--RECORD_TYPE_CODE
      'STCC'       ,--DET_FACTOR_TEMPL_CODE
       CONTENT_OWNER_ID               ,
       fnd_global.user_id             ,
       SYSDATE                        ,
       fnd_global.user_id             ,
       SYSDATE                        ,
       fnd_global.conc_login_id       ,
       fnd_global.conc_request_id     ,--Request Id
       fnd_global.prog_appl_id        ,--Program Application ID
       fnd_global.conc_program_id     ,--Program Id
       fnd_global.conc_login_id       , --Program Login ID
	1
) --Bug 5090631
--Bug 5572117
SELECT DISTINCT
       taxes.TAX             L_TAX                 ,
       taxes.TAX_REGIME_CODE L_TAX_REGIME_CODE     ,
       taxgrp.START_DATE     EFFECTIVE_FROM      ,
       taxgrp.END_DATE       EFFECTIVE_TO        ,
       taxes.CONTENT_OWNER_ID,
       (taxgrp.tax_group_id * 2) + taxgrp.DISPLAY_ORDER      PRIORITY
FROM
    ZX_TAXES_B taxes  ,
    ZX_RATES_B rates,
    AR_TAX_GROUP_CODES_ALL taxgrp,
    ZX_ID_TCC_MAPPING_ALL idmap
WHERE
      taxgrp.tax_code_id = idmap.tax_rate_code_id
AND   taxgrp.tax_group_type =idmap.source
and   taxgrp.org_id = idmap.org_id
and   idmap.tax_rate_code_id = decode(idmap.source, 'AR', rates.tax_rate_id, 'AP', rates.source_id)
and   rates.tax = taxes.TAX
and   rates.tax_regime_code = taxes.TAX_REGIME_CODE
AND   rates.content_owner_id = taxes.content_owner_id
and   rates.record_type_code = 'MIGRATED'
AND   taxes.TAX_TYPE_CODE NOT IN ('AWT','OFFSET')
AND   taxes.RECORD_TYPE_CODE  = 'MIGRATED'
AND   taxes.tax_type_code <> 'LOCATION' --Bug Fix 4626074
AND NOT EXISTS ( select 1
		 from  ZX_RULES_B_TMP rule
  	         where
		     rule.CONTENT_OWNER_ID   = taxes.CONTENT_OWNER_ID
		 and rule.TAX_REGIME_CODE    = taxes.TAX_REGIME_CODE
		 and rule.TAX                = taxes.TAX
		 and rule.SERVICE_TYPE_CODE  = 'DET_DIRECT_RATE'
		 and rule.RECOVERY_TYPE_CODE IS NULL
		 and rule.TAX_RULE_CODE      = taxes.TAX
		 and rule.EFFECTIVE_FROM     = taxgrp.START_DATE
		 and rule.PRIORITY           = (taxgrp.tax_group_id * 2)  + taxgrp.DISPLAY_ORDER
                 )
union
SELECT DISTINCT
       taxes.TAX             L_TAX                 ,
       taxes.TAX_REGIME_CODE L_TAX_REGIME_CODE     ,
       taxes.EFFECTIVE_FROM  EFFECTIVE_FROM      ,
       taxes.EFFECTIVE_TO    EFFECTIVE_TO        ,
       taxes.CONTENT_OWNER_ID                    ,
       1                     PRIORITY

FROM
    ZX_TAXES_B taxes
WHERE
     taxes.TAX_TYPE_CODE NOT IN ('AWT','OFFSET')
AND  taxes.RECORD_TYPE_CODE  = 'MIGRATED'
AND  taxes.tax_type_code <> 'LOCATION' --Bug Fix 4626074
and exists ( select 1
          from zx_rates_b rates,zx_id_tcc_mapping_all idmap,ar_system_parameters_all sys
          where idmap.ledger_id = sys.set_of_books_id
          AND idmap.org_id = sys.org_id
          AND idmap.source = 'AR'
          AND sys.tax_method = 'SALES_TAX'
          and   idmap.tax_rate_code_id = rates.tax_rate_id
          and   rates.tax = taxes.TAX
          and   rates.tax_regime_code = taxes.TAX_REGIME_CODE
          AND rates.content_owner_id = taxes.content_owner_id
          and   rates.record_type_code = 'MIGRATED' )
AND NOT EXISTS ( select 1
		 from  ZX_RULES_B_TMP rule
  	         where
		     rule.CONTENT_OWNER_ID   = taxes.CONTENT_OWNER_ID
		 and rule.TAX_REGIME_CODE    = taxes.TAX_REGIME_CODE
		 and rule.TAX                = taxes.TAX
		 and rule.SERVICE_TYPE_CODE  = 'DET_DIRECT_RATE'
		 and rule.RECOVERY_TYPE_CODE IS NULL
		 and rule.TAX_RULE_CODE      = taxes.TAX
		 and rule.EFFECTIVE_FROM     = taxes.EFFECTIVE_FROM
		 and rule.PRIORITY           = 1
                 )
;

--Create Applicability Rules For Location Based Taxes , Refer Bug 4910386
--Refer Bug 4935978 for further modificatiions

INSERT ALL
INTO ZX_RULES_B_TMP
(
 TAX_RULE_ID                    ,
 TAX_RULE_CODE                  ,
 TAX                            ,
 TAX_REGIME_CODE                ,
 SERVICE_TYPE_CODE              ,
 APPLICATION_ID                 ,
 RECOVERY_TYPE_CODE             ,
 PRIORITY                       ,
 SYSTEM_DEFAULT_FLAG            ,
 EFFECTIVE_FROM                 ,
 EFFECTIVE_TO                   ,
 ENABLED_FLAG                   ,
 RECORD_TYPE_CODE               ,
 DET_FACTOR_TEMPL_CODE          ,
 CONTENT_OWNER_ID               ,
 CREATED_BY             ,
 CREATION_DATE          ,
 LAST_UPDATED_BY        ,
 LAST_UPDATE_DATE       ,
 LAST_UPDATE_LOGIN      ,
 REQUEST_ID             ,
 PROGRAM_APPLICATION_ID ,
 PROGRAM_ID             ,
 PROGRAM_LOGIN_ID       ,
OBJECT_VERSION_NUMBER
)
VALUES
(
       zx_rules_b_s.nextval,--TAX_RULE_ID
       TAX                 ,--TAX_RULE_CODE
       TAX                 ,--TAX
       TAX_REGIME_CODE     ,--REGIME
       'DET_DIRECT_RATE'   , -- SERVICE_TYPE_CODE  --Bug 5385949
       NULL                ,--APPLICATION_ID
       NULL                ,--RECOVERY_TYPE_CODE
       PRIORITY            ,
      'N'                  ,--SYSTEM_DEFAULT_FLAG  : Bug 4590290
       EFFECTIVE_FROM      ,
       EFFECTIVE_TO        ,
       ENABLED_FLAG                  ,
      'MIGRATED'           ,--RECORD_TYPE_CODE
      'STCC'     ,--DET_FACTOR_TEMPL_CODE
       CONTENT_OWNER_ID       ,
       fnd_global.user_id             ,
       SYSDATE                        ,
       fnd_global.user_id             ,
       SYSDATE                        ,
       fnd_global.conc_login_id       ,
       fnd_global.conc_request_id     ,--Request Id
       fnd_global.prog_appl_id        ,--Program Application ID
       fnd_global.conc_program_id     ,--Program Id
       fnd_global.conc_login_id       ,--Program Login ID
       1
)
SELECT
       taxes.TAX             TAX                 ,
       taxes.TAX_REGIME_CODE TAX_REGIME_CODE     ,
       taxes.EFFECTIVE_FROM  EFFECTIVE_FROM      ,
       taxes.EFFECTIVE_TO    EFFECTIVE_TO        ,
       ptp.party_tax_profile_id  CONTENT_OWNER_ID,
--       nvl(vat.enabled_flag,'Y') ENABLED_FLAG
	'Y' ENABLED_FLAG,  -- Bug 5209434
       1           PRIORITY
FROM
    ZX_TAXES_B taxes,
--    AR_VAT_TAX_ALL_B vat,
    zx_party_tax_profile ptp,
    ar_system_parameters_all sys
WHERE
     taxes.RECORD_TYPE_CODE  = 'MIGRATED'
AND  taxes.tax_type_code = 'LOCATION'
AND  taxes.live_for_applicability_flag = 'Y'
AND  taxes.content_owner_id = -99
AND  taxes.tax_regime_code = sys.default_country||'-SALES-TAX-'||sys.location_structure_id
/*AND  vat.tax_type = 'LOCATION'
AND  vat.set_of_books_id = sys.set_of_books_id
AND  vat.org_id = sys.org_id*/
AND  sys.org_id = ptp.party_id
AND  ptp.party_type_code = 'OU'
-- Added following AND condition for Sync process
AND  taxes.tax = nvl(p_tax,taxes.tax)
-- Bug 5209434
AND EXISTS (
	SELECT 1 FROM ar_vat_tax_all_b vat WHERE  vat.tax_type = 'LOCATION'
	AND  vat.set_of_books_id = sys.set_of_books_id
	AND  vat.org_id = sys.org_id
	AND vat.enabled_flag = 'Y'
	)
AND  not exists (select 1
                   from zx_rules_b
                  where tax_rule_code = taxes.tax
                    and effective_from = taxes.effective_from
                     and content_owner_id = ptp.party_tax_profile_id
                     and service_type_code = 'DET_DIRECT_RATE'  --Bug 5385949
                     and tax_regime_code = taxes.tax_regime_code
                     and tax = taxes.tax
                     and recovery_type_code IS NULL
                     and priority           = 1
                )
UNION
SELECT
       taxes.TAX             TAX                 ,
       taxes.TAX_REGIME_CODE TAX_REGIME_CODE     ,
       taxgrp.START_DATE     EFFECTIVE_FROM      ,
       taxgrp.END_DATE       EFFECTIVE_TO        ,
       ptp.party_tax_profile_id  CONTENT_OWNER_ID,
--       nvl(vat.enabled_flag,'Y') ENABLED_FLAG
	'Y' ENABLED_FLAG, -- Bug 5209434
       (taxgrp.tax_group_id * 2) + taxgrp.DISPLAY_ORDER     PRIORITY
FROM
    ZX_TAXES_B taxes,
    AR_VAT_TAX_ALL_B vat,
    zx_party_tax_profile ptp,
    ar_system_parameters_all sys,
    AR_TAX_GROUP_CODES_ALL taxgrp

WHERE
     taxes.RECORD_TYPE_CODE  = 'MIGRATED'
AND  taxes.tax_type_code = 'LOCATION'
AND  taxes.live_for_applicability_flag = 'Y'
AND  taxes.content_owner_id = -99
AND  taxes.tax_regime_code = sys.default_country||'-SALES-TAX-'||sys.location_structure_id
AND  vat.tax_type = 'LOCATION'
AND  vat.set_of_books_id = sys.set_of_books_id
AND  vat.org_id = sys.org_id
AND  vat.vat_tax_id = taxgrp.tax_code_id
AND  vat.enabled_flag = 'Y'
AND  sys.org_id = ptp.party_id
AND  ptp.party_type_code = 'OU'
-- Added following AND condition for Sync process
AND  taxes.tax = nvl(p_tax,taxes.tax)
-- Bug 5209434
/*AND EXISTS (
	SELECT 1 FROM ar_vat_tax_all_b vat
	WHERE  vat.tax_type = 'LOCATION'
	AND  vat.set_of_books_id = sys.set_of_books_id
	AND  vat.org_id = sys.org_id
	AND vat.enabled_flag = 'Y'
        AND  vat.vat_tax_id = taxgrp.tax_code_id
	)
*/
AND  not exists (select 1
                   from zx_rules_b
                  where tax_rule_code = taxes.tax
                    and effective_from = taxes.effective_from
                     and content_owner_id = ptp.party_tax_profile_id
                     and service_type_code = 'DET_DIRECT_RATE'  --Bug 5385949
                     and tax_regime_code = taxes.tax_regime_code
                     and tax = taxes.tax
                     and recovery_type_code IS NULL
		     and PRIORITY           = (taxgrp.tax_group_id * 2) + taxgrp.DISPLAY_ORDER
                );

-- Create Applicablity Rule for all the tax codes in the leasing tax group with
-- at least one not NULL PFC, PTFC, TBC

-- Bug : 5147341
-- Create Rate Determination Rule for location based taxes for OKL migration
-- even though there can be VAT taxes with leasing flag as 'Y', but for these taxes
-- no multiple rate will be defined, hence no need to create the rate det rules.

INSERT ALL INTO ZX_RULES_B_TMP
(
 TAX_RULE_ID                    ,
 TAX_RULE_CODE                  ,
 TAX                            ,
 TAX_REGIME_CODE                ,
 SERVICE_TYPE_CODE              ,
 APPLICATION_ID                 ,
 RECOVERY_TYPE_CODE             ,
 PRIORITY                       ,
 SYSTEM_DEFAULT_FLAG            ,
 EFFECTIVE_FROM                 ,
 EFFECTIVE_TO                   ,
 ENABLED_FLAG                   ,
 RECORD_TYPE_CODE               ,
 DET_FACTOR_TEMPL_CODE          ,
 CONTENT_OWNER_ID               ,
 CREATED_BY             ,
 CREATION_DATE          ,
 LAST_UPDATED_BY        ,
 LAST_UPDATE_DATE       ,
 LAST_UPDATE_LOGIN      ,
 REQUEST_ID             ,
 PROGRAM_APPLICATION_ID ,
 PROGRAM_ID             ,
 PROGRAM_LOGIN_ID  	,
 OBJECT_VERSION_NUMBER
)
VALUES
(
       zx_rules_b_s.nextval,--TAX_RULE_ID
       L_TAX               ,--TAX_RULE_CODE
       L_TAX               ,--TAX
       L_TAX_REGIME_CODE   ,--TAX_REGIME_CODE
       l_service_type_code ,--SERVICE_TYPE_CODE
       NULL                ,--APPLICATION_ID
       NULL                ,--RECOVERY_TYPE_CODE
       1                   ,--PRIORITY
      'N'                  ,--SYSTEM_DEFAULT_FLAG  :  Bug 4590290
       EFFECTIVE_FROM      ,
       EFFECTIVE_TO        ,
      'Y'                  ,--ENABLED_FLAG
      'MIGRATED'           ,--RECORD_TYPE_CODE
      'LEASE_MGT_RATE_DET_TEMPL'      ,--DET_FACTOR_TEMPL_CODE
       CONTENT_OWNER_ID               ,
       fnd_global.user_id             ,
       SYSDATE                        ,
       fnd_global.user_id             ,
       SYSDATE                        ,
       fnd_global.conc_login_id       ,
       fnd_global.conc_request_id     ,--Request Id
       fnd_global.prog_appl_id        ,--Program Application ID
       fnd_global.conc_program_id     ,--Program Id
       fnd_global.conc_login_id       , --Program Login ID
	1
) --Bug 5090631
SELECT DISTINCT
       taxes.TAX             L_TAX                 ,
       taxes.TAX_REGIME_CODE L_TAX_REGIME_CODE     ,
       taxes.EFFECTIVE_FROM  EFFECTIVE_FROM      ,
       taxes.EFFECTIVE_TO    EFFECTIVE_TO        ,
       taxes.CONTENT_OWNER_ID                    ,
       srvtype.service_type_code l_service_type_code
FROM
    ZX_TAXES_B taxes,
    (SELECT 'DET_APPLICABLE_TAXES' service_type_code
       FROM DUAL
     UNION
     SELECT 'DET_TAX_RATE' service_type_code
       FROM DUAL ) srvtype
WHERE
     taxes.TAX_TYPE_CODE NOT IN ('AWT','OFFSET','LOCATION')
AND  taxes.RECORD_TYPE_CODE  = 'MIGRATED'
AND  EXISTS (SELECT 1
               FROM zx_rates_b rates,
                    ar_tax_group_codes_all taxgrp,
                    ar_vat_tax_all tax
              WHERE taxgrp.tax_group_type = 'AR'
                AND taxgrp.tax_code_id = tax.vat_tax_id
                AND taxgrp.org_id = tax.org_id
                AND tax.vat_tax_id = rates.tax_rate_id
                AND rates.tax = taxes.tax
                AND rates.tax_regime_code = taxes.tax_regime_code
                AND rates.content_owner_id = taxes.content_owner_id
                AND rates.record_type_code = 'MIGRATED'
                AND taxgrp.product_fisc_classification ||
                    taxgrp.trx_business_category_code ||
                    taxgrp.party_fisc_classification IS NOT NULL
          )
AND NOT EXISTS ( select 1
		 from  ZX_RULES_B_TMP rule
  	         where
		     rule.CONTENT_OWNER_ID   = taxes.CONTENT_OWNER_ID
		 and rule.TAX_REGIME_CODE    = taxes.TAX_REGIME_CODE
		 and rule.TAX                = taxes.TAX
		 and rule.SERVICE_TYPE_CODE  = srvtype.service_type_code
		 and rule.RECOVERY_TYPE_CODE IS NULL
		 and rule.TAX_RULE_CODE      = taxes.TAX
		 and rule.EFFECTIVE_FROM     = taxes.EFFECTIVE_FROM
		 and rule.PRIORITY           = 1
                 )
UNION
SELECT DISTINCT
       taxes.TAX             L_TAX                 ,
       taxes.TAX_REGIME_CODE L_TAX_REGIME_CODE     ,
       taxes.EFFECTIVE_FROM  EFFECTIVE_FROM      ,
       taxes.EFFECTIVE_TO    EFFECTIVE_TO        ,
       taxes.CONTENT_OWNER_ID,
       srvtype.service_type_code l_service_type_code
FROM
    ZX_TAXES_B taxes,
    zx_party_tax_profile ptp,
    ar_system_parameters_all sys,
    (SELECT 'DET_APPLICABLE_TAXES' service_type_code
       FROM DUAL
     UNION
     SELECT 'DET_TAX_RATE' service_type_code
       FROM DUAL ) srvtype

WHERE taxes.RECORD_TYPE_CODE  = 'MIGRATED'
AND  taxes.live_for_applicability_flag = 'Y' -- add to filter location taxes defined in 11i
AND  taxes.tax_type_code = 'LOCATION'
AND  taxes.content_owner_id = -99
AND  taxes.tax_regime_code = sys.default_country||'-SALES-TAX-'||sys.location_structure_id
AND  sys.org_id = ptp.party_id
AND  ptp.party_type_code = 'OU'
-- Added following AND condition for Sync process
AND  taxes.tax = nvl(p_tax,taxes.tax)
-- only create the rate determining rules for the tax codes in the tax group with
-- at least one not NULL PFC, PTFC, TBC and not the migrated disabled leasing location taxes
AND  EXISTS (SELECT 1
               FROM zx_rates_b rates,
                    ar_tax_group_codes_all taxgrp,
                    ar_vat_tax_all tax
              WHERE taxgrp.tax_group_type = 'AR'
                AND taxgrp.tax_code_id = tax.vat_tax_id
                AND taxgrp.org_id = tax.org_id
                AND tax.vat_tax_id = rates.tax_rate_id
                AND tax.tax_type = 'LOCATION'
                AND rates.tax <> taxes.tax -- not create rule for the disabled taxes migrated for the location based tax code
                AND rates.tax_regime_code = taxes.tax_regime_code
                AND rates.content_owner_id = taxes.content_owner_id
                AND rates.record_type_code = 'MIGRATED'
                AND taxgrp.product_fisc_classification ||
                    taxgrp.trx_business_category_code ||
                    taxgrp.party_fisc_classification IS NOT NULL
          )
AND  not exists (select 1
                   from zx_rules_b
                  where tax_rule_code = taxes.tax
                     and effective_from = taxes.effective_from
                     and content_owner_id = ptp.party_tax_profile_id
   		     and service_type_code = srvtype.service_type_code
                     and tax_regime_code = taxes.tax_regime_code
                     and tax = taxes.tax
                     and recovery_type_code IS NULL
                     and priority           = 1
                );


INSERT INTO ZX_RULES_TL
(
 LANGUAGE                    ,
 SOURCE_LANG                 ,
 TAX_RULE_NAME               ,
 TAX_RULE_ID                 ,
 CREATION_DATE               ,
 CREATED_BY                  ,
 LAST_UPDATE_DATE            ,
 LAST_UPDATED_BY             ,
 LAST_UPDATE_LOGIN
)

SELECT
    L.LANGUAGE_CODE          ,
    userenv('LANG')          ,
     CASE WHEN B.TAX_RULE_CODE = UPPER(B.TAX_RULE_CODE)
     THEN    Initcap(B.TAX_RULE_CODE)
     ELSE
             B.TAX_RULE_CODE
     END                     ,
    B.TAX_RULE_ID            ,
    SYSDATE                  ,
    fnd_global.user_id       ,
    SYSDATE                  ,
    fnd_global.user_id       ,
    fnd_global.conc_login_id
FROM
    FND_LANGUAGES L,
    ZX_RULES_B B
WHERE
    L.INSTALLED_FLAG in ('I', 'B')
AND RECORD_TYPE_CODE = 'MIGRATED'
AND  not exists
     (select NULL
     from  ZX_RULES_TL T
     where T.TAX_RULE_ID =  B.TAX_RULE_ID
       and T.LANGUAGE = L.LANGUAGE_CODE);


--Bug : 5090631 : Added to update the DIRECT_RATE_RULE_FLAG to 'Y' for all tax,regime,contentOwners for which
-- direct rate rules have been created.

    update zx_taxes_b_tmp tax
    set tax.DIRECT_RATE_RULE_FLAG = 'Y'
    where exists
          ( select 1
            from zx_rules_b rule
            where rule.content_owner_id = tax.content_owner_id
            and rule.tax_regime_code = tax.tax_regime_code
            and rule.tax = tax.tax
            and rule.record_type_code = 'MIGRATED'
            and rule.SERVICE_TYPE_CODE = 'DET_DIRECT_RATE'
            and rule.recovery_type_code is NULL
            and rule.tax_rule_code = tax.tax );
          --  and rule.priority = 1);

-- bug fix: 5548613 update the DIRECT_RATE_RULE_FLAG to 'Y' for location based taxes which have the direct rate rule migrated
    update zx_taxes_b_tmp tax
    set tax.DIRECT_RATE_RULE_FLAG = 'Y'
    where tax.tax_type_code = 'LOCATION'
      and tax.RECORD_TYPE_CODE  = 'MIGRATED'
      and tax.live_for_applicability_flag = 'Y' -- add to filter location taxes defined in 11i
      and tax.content_owner_id = -99
      and exists
          ( select 1
            from zx_rules_b rule
            where rule.tax_regime_code = tax.tax_regime_code
            and rule.tax = tax.tax
            and rule.record_type_code = 'MIGRATED'
            and rule.SERVICE_TYPE_CODE = 'DET_DIRECT_RATE'
            and rule.recovery_type_code is NULL
            and rule.tax_rule_code = tax.tax);
          --  and rule.priority = 1);
-- bug fix: 5548613 end

-- Added to update the TAX_RATE_RULE_FLAG to 'Y' for all tax,regime,contentOwners for which
-- direct rate rules have been created.

    update zx_taxes_b_tmp tax
    set tax.TAX_RATE_RULE_FLAG = 'Y'
    where exists
          ( select 1
            from zx_rules_b rule
            where rule.content_owner_id = tax.content_owner_id
            and rule.tax_regime_code = tax.tax_regime_code
            and rule.tax = tax.tax
            and rule.record_type_code = 'MIGRATED'
            and rule.SERVICE_TYPE_CODE = 'DET_TAX_RATE'
            and rule.recovery_type_code is NULL
            and rule.tax_rule_code = tax.tax
            and rule.priority = 1);

--
-- Added to update the APPLICABILITY_RULE to 'Y' for all tax,regime,contentOwners for which
-- applicability rules have been created.

    update zx_taxes_b_tmp tax
    set tax.APPLICABILITY_RULE_FLAG = 'Y'
    where exists
          ( select 1
            from zx_rules_b rule
            where rule.content_owner_id = tax.content_owner_id
            and rule.tax_regime_code = tax.tax_regime_code
            and rule.tax = tax.tax
            and rule.record_type_code = 'MIGRATED'
            and rule.SERVICE_TYPE_CODE = 'DET_APPLICABLE_TAXES'
            and rule.recovery_type_code is NULL
            and rule.tax_rule_code = tax.tax
            and rule.priority = 1);

    -- bug fix: 5548613: copy the location based taxes
    -- which has an applicability rule defined.

    INSERT INTO ZX_TAXES_B (
      TAX
      ,EFFECTIVE_FROM
      ,EFFECTIVE_TO
      ,TAX_REGIME_CODE
      ,TAX_TYPE_CODE
      ,ALLOW_MANUAL_ENTRY_FLAG
      ,ALLOW_TAX_OVERRIDE_FLAG
      ,MIN_TXBL_BSIS_THRSHLD
      ,MAX_TXBL_BSIS_THRSHLD
      ,MIN_TAX_RATE_THRSHLD
      ,MAX_TAX_RATE_THRSHLD
      ,MIN_TAX_AMT_THRSHLD
      ,MAX_TAX_AMT_THRSHLD
      ,COMPOUNDING_PRECEDENCE
      ,PERIOD_SET_NAME
      ,EXCHANGE_RATE_TYPE
      ,TAX_CURRENCY_CODE
      ,TAX_PRECISION
      ,MINIMUM_ACCOUNTABLE_UNIT
      ,ROUNDING_RULE_CODE
      ,TAX_STATUS_RULE_FLAG
      ,TAX_RATE_RULE_FLAG
      ,DEF_PLACE_OF_SUPPLY_TYPE_CODE
      ,PLACE_OF_SUPPLY_RULE_FLAG
      ,DIRECT_RATE_RULE_FLAG
      ,APPLICABILITY_RULE_FLAG
      ,TAX_CALC_RULE_FLAG
      ,TXBL_BSIS_THRSHLD_FLAG
      ,TAX_RATE_THRSHLD_FLAG
      ,TAX_AMT_THRSHLD_FLAG
      ,TAXABLE_BASIS_RULE_FLAG
      ,DEF_INCLUSIVE_TAX_FLAG
      ,THRSHLD_GROUPING_LVL_CODE
      ,HAS_OTHER_JURISDICTIONS_FLAG
      ,ALLOW_EXEMPTIONS_FLAG
      ,ALLOW_EXCEPTIONS_FLAG
      ,ALLOW_RECOVERABILITY_FLAG
      ,DEF_TAX_CALC_FORMULA
      ,TAX_INCLUSIVE_OVERRIDE_FLAG
      ,DEF_TAXABLE_BASIS_FORMULA
      ,DEF_REGISTR_PARTY_TYPE_CODE
      ,REGISTRATION_TYPE_RULE_FLAG
      ,REPORTING_ONLY_FLAG
      ,AUTO_PRVN_FLAG
      ,LIVE_FOR_PROCESSING_FLAG
      ,HAS_DETAIL_TB_THRSHLD_FLAG
      ,HAS_TAX_DET_DATE_RULE_FLAG
      ,HAS_EXCH_RATE_DATE_RULE_FLAG
      ,HAS_TAX_POINT_DATE_RULE_FLAG
      ,PRINT_ON_INVOICE_FLAG
      ,USE_LEGAL_MSG_FLAG
      ,CALC_ONLY_FLAG
      ,PRIMARY_RECOVERY_TYPE_CODE
      ,PRIMARY_REC_TYPE_RULE_FLAG
      ,SECONDARY_RECOVERY_TYPE_CODE
      ,SECONDARY_REC_TYPE_RULE_FLAG
      ,PRIMARY_REC_RATE_DET_RULE_FLAG
      ,SEC_REC_RATE_DET_RULE_FLAG
      ,OFFSET_TAX_FLAG
      ,RECOVERY_RATE_OVERRIDE_FLAG
      ,ZONE_GEOGRAPHY_TYPE
      ,REGN_NUM_SAME_AS_LE_FLAG
      ,DEF_REC_SETTLEMENT_OPTION_CODE
      ,PARENT_GEOGRAPHY_TYPE
      ,PARENT_GEOGRAPHY_ID
      ,ALLOW_MASS_CREATE_FLAG
      ,APPLIED_AMT_HANDLING_FLAG
      ,CREATED_BY
      ,CREATION_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_DATE
      ,LAST_UPDATE_LOGIN
      ,REQUEST_ID
      ,PROGRAM_APPLICATION_ID
      ,PROGRAM_ID
      ,RECORD_TYPE_CODE
      ,ALLOW_ROUNDING_OVERRIDE_FLAG
      ,ATTRIBUTE1
      ,ATTRIBUTE2
      ,ATTRIBUTE3
      ,ATTRIBUTE4
      ,ATTRIBUTE5
      ,ATTRIBUTE6
      ,ATTRIBUTE7
      ,ATTRIBUTE8
      ,ATTRIBUTE9
      ,ATTRIBUTE10
      ,ATTRIBUTE11
      ,ATTRIBUTE12
      ,ATTRIBUTE13
      ,ATTRIBUTE14
      ,ATTRIBUTE15
      ,ATTRIBUTE_CATEGORY
      ,SOURCE_TAX_FLAG
      ,DEF_PRIMARY_REC_RATE_CODE
      ,ALLOW_DUP_REGN_NUM_FLAG
      ,DEF_SECONDARY_REC_RATE_CODE
      ,SPECIAL_INCLUSIVE_TAX_FLAG
      ,PROGRAM_LOGIN_ID
      ,TAX_ID
      ,CONTENT_OWNER_ID
      ,REP_TAX_AUTHORITY_ID
      ,COLL_TAX_AUTHORITY_ID
      ,THRSHLD_CHK_TMPLT_CODE
      ,TAX_ACCOUNT_SOURCE_TAX
      ,TAX_ACCOUNT_CREATE_METHOD_CODE
      ,OVERRIDE_GEOGRAPHY_TYPE
      ,LIVE_FOR_APPLICABILITY_FLAG
      ,OBJECT_VERSION_NUMBER
      ,TAX_EXMPT_CR_METHOD_CODE
      ,TAX_EXMPT_SOURCE_TAX
      ,APPLICABLE_BY_DEFAULT_FLAG
      ,LEGAL_REPORTING_STATUS_DEF_VAL )
    SELECT  tax.TAX
           ,tax.EFFECTIVE_FROM
           ,tax.EFFECTIVE_TO
           ,tax.TAX_REGIME_CODE
           ,tax.TAX_TYPE_CODE
           ,tax.ALLOW_MANUAL_ENTRY_FLAG
           ,tax.ALLOW_TAX_OVERRIDE_FLAG
           ,tax.MIN_TXBL_BSIS_THRSHLD
           ,tax.MAX_TXBL_BSIS_THRSHLD
           ,tax.MIN_TAX_RATE_THRSHLD
           ,tax.MAX_TAX_RATE_THRSHLD
           ,tax.MIN_TAX_AMT_THRSHLD
           ,tax.MAX_TAX_AMT_THRSHLD
           ,tax.COMPOUNDING_PRECEDENCE
           ,tax.PERIOD_SET_NAME
           ,tax.EXCHANGE_RATE_TYPE
           ,tax.TAX_CURRENCY_CODE
           ,tax.TAX_PRECISION
           ,tax.MINIMUM_ACCOUNTABLE_UNIT
           ,tax.ROUNDING_RULE_CODE
           ,tax.TAX_STATUS_RULE_FLAG
           ,tax.TAX_RATE_RULE_FLAG
           ,tax.DEF_PLACE_OF_SUPPLY_TYPE_CODE
           ,tax.PLACE_OF_SUPPLY_RULE_FLAG
           ,tax.DIRECT_RATE_RULE_FLAG
           ,'Y'                         --APPLICABILITY_RULE_FLAG
           ,tax.TAX_CALC_RULE_FLAG
           ,tax.TXBL_BSIS_THRSHLD_FLAG
           ,tax.TAX_RATE_THRSHLD_FLAG
           ,tax.TAX_AMT_THRSHLD_FLAG
           ,tax.TAXABLE_BASIS_RULE_FLAG
           ,tax.DEF_INCLUSIVE_TAX_FLAG
           ,tax.THRSHLD_GROUPING_LVL_CODE
           ,tax.HAS_OTHER_JURISDICTIONS_FLAG
           ,tax.ALLOW_EXEMPTIONS_FLAG
           ,tax.ALLOW_EXCEPTIONS_FLAG
           ,tax.ALLOW_RECOVERABILITY_FLAG
           ,tax.DEF_TAX_CALC_FORMULA
           ,tax.TAX_INCLUSIVE_OVERRIDE_FLAG
           ,tax.DEF_TAXABLE_BASIS_FORMULA
           ,tax.DEF_REGISTR_PARTY_TYPE_CODE
           ,tax.REGISTRATION_TYPE_RULE_FLAG
           ,tax.REPORTING_ONLY_FLAG
           ,tax.AUTO_PRVN_FLAG
           ,tax.LIVE_FOR_PROCESSING_FLAG
           ,tax.HAS_DETAIL_TB_THRSHLD_FLAG
           ,tax.HAS_TAX_DET_DATE_RULE_FLAG
           ,tax.HAS_EXCH_RATE_DATE_RULE_FLAG
           ,tax.HAS_TAX_POINT_DATE_RULE_FLAG
           ,tax.PRINT_ON_INVOICE_FLAG
           ,tax.USE_LEGAL_MSG_FLAG
           ,tax.CALC_ONLY_FLAG
           ,tax.PRIMARY_RECOVERY_TYPE_CODE
           ,tax.PRIMARY_REC_TYPE_RULE_FLAG
           ,tax.SECONDARY_RECOVERY_TYPE_CODE
           ,tax.SECONDARY_REC_TYPE_RULE_FLAG
           ,tax.PRIMARY_REC_RATE_DET_RULE_FLAG
           ,tax.SEC_REC_RATE_DET_RULE_FLAG
           ,tax.OFFSET_TAX_FLAG
           ,tax.RECOVERY_RATE_OVERRIDE_FLAG
           ,tax.ZONE_GEOGRAPHY_TYPE
           ,tax.REGN_NUM_SAME_AS_LE_FLAG
           ,tax.DEF_REC_SETTLEMENT_OPTION_CODE
           ,tax.PARENT_GEOGRAPHY_TYPE
           ,tax.PARENT_GEOGRAPHY_ID
           ,tax.ALLOW_MASS_CREATE_FLAG
           ,tax.APPLIED_AMT_HANDLING_FLAG
	   ,fnd_global.user_id            --CREATED_BY
	   ,SYSDATE                       --CREATION_DATE
	   ,fnd_global.user_id            --LAST_UPDATED_BY
	   ,SYSDATE                       --LAST_UPDATE_DATE
	   ,fnd_global.conc_login_id      --LAST_UPDATE_LOGIN
           ,tax.REQUEST_ID
           ,tax.PROGRAM_APPLICATION_ID
           ,tax.PROGRAM_ID
           ,tax.RECORD_TYPE_CODE
           ,tax.ALLOW_ROUNDING_OVERRIDE_FLAG
           ,tax.ATTRIBUTE1
           ,tax.ATTRIBUTE2
           ,tax.ATTRIBUTE3
           ,tax.ATTRIBUTE4
           ,tax.ATTRIBUTE5
           ,tax.ATTRIBUTE6
           ,tax.ATTRIBUTE7
           ,tax.ATTRIBUTE8
           ,tax.ATTRIBUTE9
           ,tax.ATTRIBUTE10
           ,tax.ATTRIBUTE11
           ,tax.ATTRIBUTE12
           ,tax.ATTRIBUTE13
           ,tax.ATTRIBUTE14
           ,tax.ATTRIBUTE15
           ,tax.ATTRIBUTE_CATEGORY
           ,tax.SOURCE_TAX_FLAG
           ,tax.DEF_PRIMARY_REC_RATE_CODE
           ,tax.ALLOW_DUP_REGN_NUM_FLAG
           ,tax.DEF_SECONDARY_REC_RATE_CODE
           ,tax.SPECIAL_INCLUSIVE_TAX_FLAG
           ,tax.PROGRAM_LOGIN_ID
           ,ZX_TAXES_B_S.NEXTVAL
           ,rule.CONTENT_OWNER_ID
           ,tax.REP_TAX_AUTHORITY_ID
           ,tax.COLL_TAX_AUTHORITY_ID
           ,tax.THRSHLD_CHK_TMPLT_CODE
           ,tax.TAX_ACCOUNT_SOURCE_TAX
           ,tax.TAX_ACCOUNT_CREATE_METHOD_CODE
           ,tax.OVERRIDE_GEOGRAPHY_TYPE
           ,tax.LIVE_FOR_APPLICABILITY_FLAG
           ,tax.OBJECT_VERSION_NUMBER
           ,tax.TAX_EXMPT_CR_METHOD_CODE
           ,tax.TAX_EXMPT_SOURCE_TAX
           ,tax.APPLICABLE_BY_DEFAULT_FLAG
           ,tax.LEGAL_REPORTING_STATUS_DEF_VAL
      FROM ZX_TAXES_B tax, zx_rules_b rule
     WHERE tax.tax_type_code ='LOCATION'
       AND tax.RECORD_TYPE_CODE  = 'MIGRATED'
       AND tax.live_for_applicability_flag = 'Y' -- add to filter location taxes defined in 11i
       AND tax.content_owner_id = -99
       AND rule.tax_regime_code = tax.tax_regime_code
       AND rule.tax = tax.tax
       AND rule.record_type_code = 'MIGRATED'
       AND rule.SERVICE_TYPE_CODE = 'DET_APPLICABLE_TAXES'
       AND rule.recovery_type_code is NULL
       AND rule.tax_rule_code = tax.tax
       AND rule.priority = 1
       AND NOT EXISTS (
             SELECT 1
               FROM zx_taxes_b tax2
              WHERE tax2.tax = tax.tax
                AND tax2.tax_regime_code = tax.tax_regime_code
                AND tax2.content_owner_id = tax.content_owner_id);

-- bug fix: 5548613 end

     IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('Create_Rules(-)');
     END IF;
EXCEPTION
         WHEN OTHERS THEN
             IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Create_rules ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('Create_Rules(-)');
             END IF;
             --app_exception.raise_exception;
END create_rules;

/*=========================================================================+
 | PROCEDURE                                                               |
 |    create_process_results                                               |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This routine inserts data into ZX_PROCESS_RESULTS by following same |
 |     logic used while inserting the data in ZX_CONDITION_GROUPS_B.       |
 |                                                                         |
 | SCOPE - PUBLIC                                                          |
 |                                                                         |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                 |
 |                                                                         |
 | CALLED FROM                                                             |
 |        migrate_default_hierarchy                                        |
 | NOTES                                                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     15-Jan-04  Srinivas Lokam      Created.                             |
 |     30-Jan-04  Srinivas Lokam      Added INPUT parameters,AND conditions|
 |                                    in SELECT statements for handling    |
 |                                    SYNC process.                        |
 |                                                                         |
 |=========================================================================*/

PROCEDURE create_process_results(p_tax_id      IN NUMBER   DEFAULT NULL,
                                 p_sync_module IN VARCHAR2 DEFAULT NULL
                                ) IS
BEGIN
     IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('Create_Process_Results(+)');
     END IF;

IF (nvl(p_sync_module,'AP') = 'AP') THEN
--Process_Results for AP Tax codes and Tax Groups Setup
INSERT INTO ZX_PROCESS_RESULTS
(
 CONDITION_GROUP_CODE           ,
 PRIORITY                       ,
 RESULT_TYPE_CODE               ,
 TAX_STATUS_CODE                ,
 NUMERIC_RESULT                 ,
 ALPHANUMERIC_RESULT            ,
 STATUS_RESULT                  ,
 RATE_RESULT                    ,
 LEGAL_MESSAGE_CODE             ,
 MIN_TAX_AMT                    ,
 MAX_TAX_AMT                    ,
 MIN_TAXABLE_BASIS              ,
 MAX_TAXABLE_BASIS              ,
 MIN_TAX_RATE                   ,
 MAX_TAX_RATE                   ,
 ENABLED_FLAG                   ,
 ALLOW_EXEMPTIONS_FLAG          ,
 ALLOW_EXCEPTIONS_FLAG          ,
 RECORD_TYPE_CODE               ,
 RESULT_API                     ,
 RESULT_ID                      ,
 CONTENT_OWNER_ID               ,
 CONDITION_GROUP_ID             ,
 TAX_RULE_ID                    ,
 CREATED_BY             ,
 CREATION_DATE          ,
 LAST_UPDATED_BY        ,
 LAST_UPDATE_DATE       ,
 LAST_UPDATE_LOGIN      ,
 REQUEST_ID             ,
 PROGRAM_APPLICATION_ID ,
 PROGRAM_ID             ,
 PROGRAM_LOGIN_ID	,
OBJECT_VERSION_NUMBER

)
SELECT
     CONDITION_GROUP_CODE ,
     nvl(PRIORITY,ap_tax_codes_s.nextval),
    'CODE'                ,--RESULT_TYPE_CODE
     NULL                 ,--TAX_STATUS_CODE
     NULL                 ,--NUMERIC_RESULT
    'APPLICABLE'          ,--ALPHANUMERIC_RESULT
     STATUS_RESULT        ,--STATUS_RESULT
     RATE_RESULT          ,
     NULL                 ,--LEGAL_MESSAGE_CODE
     NULL                 ,--MIN_TAX_AMT
     NULL                 ,--MAX_TAX_AMT
     NULL                 ,--MIN_TAXABLE_BASIS
     NULL                 ,--MAX_TAXABLE_BASIS
     NULL                 ,--MIN_TAX_RATE
     NULL                 ,--MAX_TAX_RATE
     ENABLED_FLAG         ,
    'N'                   ,--ALLOW_EXEMPTIONS_FLAG
    'N'                   ,--ALLOW_EXCEPTIONS_FLAG
    'MIGRATED'            ,--RECORD_TYPE_CODE
     NULL                 ,--RESULT_API
     zx_process_results_s.nextval   ,--RESULT_ID
     CONTENT_OWNER_ID               ,
     CONDITION_GROUP_ID             ,
     TAX_RULE_ID                    ,
     fnd_global.user_id             ,
     SYSDATE                        ,
     fnd_global.user_id             ,
     SYSDATE                        ,
     fnd_global.conc_login_id       ,
     fnd_global.conc_request_id     ,--Request Id
     fnd_global.prog_appl_id        ,--Program Application ID
     fnd_global.conc_program_id     ,--Program Id
     fnd_global.conc_login_id        ,--Program Login ID
     1
FROM
(
/* Bug 5061471 : Commenting this as we no longer require creation of process results for simple taxes
SELECT
     cond_groups.CONDITION_GROUP_CODE CONDITION_GROUP_CODE,
     max(rates.TAX_RATE_ID)           PRIORITY            ,
     rates.TAX_STATUS_CODE            STATUS_RESULT       ,
     rates.TAX_RATE_CODE              RATE_RESULT         ,
     rates.ACTIVE_FLAG                ENABLED_FLAG        ,
     rules.CONTENT_OWNER_ID           CONTENT_OWNER_ID    ,
     cond_groups.CONDITION_GROUP_ID   CONDITION_GROUP_ID  ,
     rules.TAX_RULE_ID                TAX_RULE_ID
FROM
    ZX_RATES_B rates,
    FND_LOOKUPS fnd,
    ZX_RULES_B rules,
    ZX_CONDITION_GROUPS_B cond_groups,
    AP_TAX_CODES_ALL codes
WHERE
    rates.record_type_code  = 'MIGRATED'
AND nvl(rates.source_id, rates.tax_rate_id)      = codes.tax_id
AND rates.tax_rate_code     =  fnd.lookup_code
AND fnd.lookup_type         = 'ZX_INPUT_CLASSIFICATIONS'
AND codes.tax_type NOT IN('AWT','OFFSET','TAX_GROUP')
AND rules.tax_rule_code = rates.TAX
AND rules.content_owner_id  = rates.content_owner_id
AND cond_groups.condition_group_code = rates.tax_rate_code
AND cond_groups.enabled_flag = codes.enabled_flag
--Added following AND condition for Sync process
AND  codes.tax_id = nvl(p_tax_id,codes.tax_id)
AND not exists (select 1 from zx_process_results where
                tax_rule_id              = rules.tax_rule_id
                and condition_group_code = cond_groups.condition_group_code
                and rate_result          = rates.tax_rate_code
               )
GROUP BY
       cond_groups.CONDITION_GROUP_CODE,
       cond_groups.CONDITION_GROUP_ID,
       rules.TAX_RULE_ID,
       rules.CONTENT_OWNER_ID,
       rates.TAX_RATE_CODE,
       rates.ACTIVE_FLAG,
       rates.TAX_STATUS_CODE
UNION ALL */
SELECT
     cond_groups.CONDITION_GROUP_CODE CONDITION_GROUP_CODE,
     NULL                             PRIORITY            ,
     rates.TAX_STATUS_CODE            STATUS_RESULT       ,
     rates.TAX_RATE_CODE              RATE_RESULT         ,
     groups.enabled_flag              ENABLED_FLAG        ,
     rates.CONTENT_OWNER_ID           CONTENT_OWNER_ID    ,
     cond_groups.CONDITION_GROUP_ID   CONDITION_GROUP_ID  ,
     rules.TAX_RULE_ID                TAX_RULE_ID
FROM
    AR_TAX_GROUP_CODES_ALL GROUPS,
    AP_TAX_CODES_ALL GROUP_CODES,
    AP_TAX_CODES_ALL CODES,
    ZX_RATES_B rates,
    ZX_RULES_B rules,
    ZX_CONDITION_GROUPS_B cond_groups
WHERE
     GROUP_CODES.TAX_ID = GROUPS.TAX_GROUP_ID
AND  GROUPS.TAX_GROUP_TYPE   = 'AP'
AND  GROUPS.TAX_CODE_ID = CODES.TAX_ID
AND  rates.RECORD_TYPE_CODE  = 'MIGRATED'
AND  nvl(rates.source_id, rates.tax_rate_id)       = codes.TAX_ID
--Added following AND condition for Sync process
AND  codes.tax_id = nvl(p_tax_id,codes.tax_id)
AND rules.tax_regime_code = rates.TAX_REGIME_CODE
AND rules.service_type_code = 'DET_DIRECT_RATE'
AND rules.recovery_type_code IS NULL
AND rules.priority = (groups.tax_group_id * 2) + groups.display_order
AND rules.tax_rule_code = rates.TAX
AND  rules.content_owner_id  = rates.content_owner_id
AND  cond_groups.CONDITION_GROUP_CODE =  group_codes.NAME
--AND cond_groups.enabled_flag = codes.enabled_flag --Bug 5061471
AND rules.effective_from = GROUPS.start_date           -- bug 6680676
AND NVL(rules.effective_to, sysdate) = NVL(GROUPS.end_date, sysdate)
AND not exists (select 1 from zx_process_results where
                tax_rule_id              = rules.tax_rule_id
                and condition_group_code = cond_groups.condition_group_code
                and rate_result          = rates.tax_rate_code
               )
);
END IF;


IF (nvl(p_sync_module,'AR') = 'AR') THEN
--Process_Results for AR Tax codes and Tax Groups Setup
INSERT INTO ZX_PROCESS_RESULTS
(
 CONDITION_GROUP_CODE           ,
 PRIORITY                       ,
 RESULT_TYPE_CODE               ,
 TAX_STATUS_CODE                ,
 NUMERIC_RESULT                 ,
 ALPHANUMERIC_RESULT            ,
 STATUS_RESULT                  ,
 RATE_RESULT                    ,
 LEGAL_MESSAGE_CODE             ,
 MIN_TAX_AMT                    ,
 MAX_TAX_AMT                    ,
 MIN_TAXABLE_BASIS              ,
 MAX_TAXABLE_BASIS              ,
 MIN_TAX_RATE                   ,
 MAX_TAX_RATE                   ,
 ENABLED_FLAG                   ,
 ALLOW_EXEMPTIONS_FLAG          ,
 ALLOW_EXCEPTIONS_FLAG          ,
 RECORD_TYPE_CODE               ,
 RESULT_API                     ,
 RESULT_ID                      ,
 CONTENT_OWNER_ID               ,
 CONDITION_GROUP_ID             ,
 TAX_RULE_ID                    ,
 CONDITION_SET_ID               ,
 EXCEPTION_SET_ID               ,
 CREATED_BY             ,
 CREATION_DATE          ,
 LAST_UPDATED_BY        ,
 LAST_UPDATE_DATE       ,
 LAST_UPDATE_LOGIN      ,
 REQUEST_ID             ,
 PROGRAM_APPLICATION_ID ,
 PROGRAM_ID             ,
 PROGRAM_LOGIN_ID	,
OBJECT_VERSION_NUMBER
)
SELECT
     CONDITION_GROUP_CODE ,
     nvl(PRIORITY,ar_vat_tax_s.nextval),--slokam
    'CODE'                ,--RESULT_TYPE_CODE
     NULL                 ,--TAX_STATUS_CODE
     NULL                 ,--NUMERIC_RESULT
    'APPLICABLE'          ,--ALPHANUMERIC_RESULT
     STATUS_RESULT        ,--STATUS_RESULT
     RATE_RESULT          ,
     NULL                 ,--LEGAL_MESSAGE_CODE
     NULL                 ,--MIN_TAX_AMT
     NULL                 ,--MAX_TAX_AMT
     NULL                 ,--MIN_TAXABLE_BASIS
     NULL                 ,--MAX_TAXABLE_BASIS
     NULL                 ,--MIN_TAX_RATE
     NULL                 ,--MAX_TAX_RATE
     ENABLED_FLAG         ,
    'N'                   ,--ALLOW_EXEMPTIONS_FLAG
    'N'                   ,--ALLOW_EXCEPTIONS_FLAG
    'MIGRATED'            ,--RECORD_TYPE_CODE
     NULL                 ,--RESULT_API
     zx_process_results_s.nextval   ,--RESULT_ID
     CONTENT_OWNER_ID               ,
     CONDITION_GROUP_ID             ,
     TAX_RULE_ID                    ,
     CONDITION_SET_ID               ,
     EXCEPTION_SET_ID               ,
     fnd_global.user_id             ,
     SYSDATE                        ,
     fnd_global.user_id             ,
     SYSDATE                        ,
     fnd_global.conc_login_id       ,
     fnd_global.conc_request_id     ,--Request Id
     fnd_global.prog_appl_id        ,--Program Application ID
     fnd_global.conc_program_id     ,--Program Id
     fnd_global.conc_login_id       ,--Program Login ID
     1
FROM
(
SELECT
     cond_groups.CONDITION_GROUP_CODE CONDITION_GROUP_CODE,
     max(rates.TAX_RATE_ID)           PRIORITY            ,
     rates.TAX_STATUS_CODE            STATUS_RESULT       ,
     rates.TAX_RATE_CODE              RATE_RESULT         ,
     rates.ACTIVE_FLAG                ENABLED_FLAG        ,
     rules.CONTENT_OWNER_ID           CONTENT_OWNER_ID    ,
     cond_groups.CONDITION_GROUP_ID   CONDITION_GROUP_ID  ,
     rules.TAX_RULE_ID                TAX_RULE_ID         ,
     NULL                             CONDITION_SET_ID    ,
     NULL                             EXCEPTION_SET_ID
FROM
    ZX_RATES_B rates,
    ZX_RULES_B rules,
    ZX_CONDITION_GROUPS_B cond_groups,
    AR_VAT_TAX_ALL_B codes,
    ar_system_parameters_all sys
WHERE
    rates.RECORD_TYPE_CODE  = 'MIGRATED'
AND codes.vat_tax_id       = rates.tax_rate_id
AND codes.tax_type NOT IN('AWT','OFFSET','TAX_GROUP')
AND rules.tax_regime_code = rates.TAX_REGIME_CODE
AND rules.tax = rates.TAX
AND rules.service_type_code = 'DET_DIRECT_RATE'
AND rules.recovery_type_code IS NULL
AND rules.priority = 1
AND rules.tax_rule_code = rates.TAX
AND rules.content_owner_id  = rates.content_owner_id
AND  cond_groups.condition_group_code = SUBSTRB(codes.tax_code,1, 40)
                                          ||DECODE(codes.tax_constraint_id,
                                                     NULL, '', '~'||codes.tax_constraint_id)
AND  codes.set_of_books_id = sys.set_of_books_id --Bug 5090631
AND  codes.org_id = sys.org_id   --Bug 5090631
AND  sys.tax_method ='SALES_TAX'
--Added following AND condition for Sync process
AND  codes.vat_tax_id = nvl(p_tax_id,codes.vat_tax_id)
AND not exists (select 1 from zx_process_results where
                tax_rule_id              = rules.tax_rule_id
                and condition_group_code = cond_groups.condition_group_code
                and rate_result          = rates.tax_rate_code
               )
GROUP BY
       cond_groups.CONDITION_GROUP_CODE,
       rates.TAX_STATUS_CODE,
       cond_groups.CONDITION_GROUP_ID,
       rules.TAX_RULE_ID,
       rules.CONTENT_OWNER_ID,
       rates.TAX_RATE_CODE,
       rates.ACTIVE_FLAG,
       NULL,
       NULL
UNION ALL
SELECT
     cond_groups.CONDITION_GROUP_CODE CONDITION_GROUP_CODE,
     NULL                             PRIORITY            ,--slokam
     rates.TAX_STATUS_CODE            STATUS_RESULT       ,
     rates.TAX_RATE_CODE              RATE_RESULT         ,
   decode(gc.enabled_flag,'N','N',gvat.enabled_flag) ENABLED_FLAG, --bug 6684262
     rates.CONTENT_OWNER_ID           CONTENT_OWNER_ID    ,
     cond_groups.CONDITION_GROUP_ID   CONDITION_GROUP_ID  ,
     rules.TAX_RULE_ID                TAX_RULE_ID         ,
     gc.TAX_CONDITION_ID              CONDITION_SET_ID    ,
     gc.TAX_EXCEPTION_ID              EXCEPTION_SET_ID
FROM AR_VAT_TAX_ALL_B         gvat,
     AR_TAX_GROUP_CODES_ALL gc,
     AR_VAT_TAX_ALL_B         vat,
     AR_TAX_CONDITIONS_ALL cond,
     AR_TAX_CONDITIONS_ALL excp,
     ZX_RATES_B rates,
     ZX_RULES_B rules,
     ZX_CONDITION_GROUPS_B cond_groups
WHERE
     gvat.vat_tax_id   = gc.tax_group_id
AND  gc.tax_group_type = 'AR'
AND  gvat.tax_type = 'TAX_GROUP'
AND  vat.tax_class = 'O'
AND  vat.vat_tax_id = gc.tax_code_id
AND  vat.tax_type <> 'TAX_GROUP'
AND  gc.tax_condition_id = cond.tax_condition_id (+)
AND  gc.tax_exception_id = excp.tax_condition_id (+)
AND  rates.RECORD_TYPE_CODE  = 'MIGRATED'
AND  vat.vat_tax_id          = rates.tax_rate_id
AND  rules.effective_from = gc.start_date --6718736
--Added following AND condition for Sync process
AND  vat.vat_tax_id          =  nvl(p_tax_id,vat.vat_tax_id)
AND rules.tax_regime_code = rates.TAX_REGIME_CODE
AND rules.tax = rates.TAX
AND rules.service_type_code = 'DET_DIRECT_RATE'
AND rules.recovery_type_code IS NULL
AND rules.priority = (gc.tax_group_id * 2) + gc.display_order
AND rules.tax_rule_code = rates.TAX
AND  rules.content_owner_id  = rates.content_owner_id
AND  cond_groups.condition_group_code = SUBSTRB(gvat.tax_code,1,40)
                                          ||DECODE(gvat.tax_constraint_id,
                                                   NULL, '', '~'||gvat.tax_constraint_id)
--AND  cond_groups.enabled_flag = vat.enabled_flag --Bug 5061471
AND  not exists (select 1 from zx_process_results where
                 tax_rule_id              = rules.tax_rule_id
                 and condition_group_code = cond_groups.condition_group_code
                 and rate_result          = rates.tax_rate_code
                )
);


--Create process results for Location Based Taxes

INSERT INTO ZX_PROCESS_RESULTS (
  CONDITION_GROUP_CODE  ,
  PRIORITY              ,
  RESULT_TYPE_CODE      ,
  TAX_STATUS_CODE       ,
  NUMERIC_RESULT        ,
  ALPHANUMERIC_RESULT   ,
  STATUS_RESULT         ,
  RATE_RESULT           ,
  LEGAL_MESSAGE_CODE    ,
  MIN_TAX_AMT           ,
  MAX_TAX_AMT           ,
  MIN_TAXABLE_BASIS     ,
  MAX_TAXABLE_BASIS     ,
  MIN_TAX_RATE          ,
  MAX_TAX_RATE          ,
  ENABLED_FLAG          ,
  ALLOW_EXEMPTIONS_FLAG ,
  ALLOW_EXCEPTIONS_FLAG ,
  RECORD_TYPE_CODE      ,
  CREATION_DATE         ,
  LAST_UPDATE_DATE      ,
  REQUEST_ID            ,
  PROGRAM_APPLICATION_ID,
  PROGRAM_ID            ,
  CONDITION_SET_ID      ,
  EXCEPTION_SET_ID      ,
  PROGRAM_LOGIN_ID      ,
  RESULT_ID             ,
  CONTENT_OWNER_ID      ,
  CONDITION_GROUP_ID    ,
  TAX_RULE_ID           ,
  CREATED_BY            ,
  LAST_UPDATED_BY       ,
  LAST_UPDATE_LOGIN     ,
  RESULT_API            ,
  OBJECT_VERSION_NUMBER
)
SELECT
  CONDITION_GROUP_CODE  ,
  nvl(PRIORITY,ar_vat_tax_s.nextval),--slokam
  'CODE'        ,   --RESULT_TYPE_CODE      , --Bug 5385949
  NULL		,   --TAX_STATUS_CODE       ,
  NULL		,   --NUMERIC_RESULT        ,
  'APPLICABLE'  ,   --ALPHANUMERIC_RESULT   ,
  'STANDARD'		,   --STATUS_RESULT , --Bug 5385949
  RATE_RESULT   ,
  NULL		,   --LEGAL_MESSAGE_CODE    ,
  NULL		,   --MIN_TAX_AMT           ,
  NULL		,   --MAX_TAX_AMT           ,
  NULL		,   --MIN_TAXABLE_BASIS     ,
  NULL		,   --MAX_TAXABLE_BASIS     ,
  NULL		,   --MIN_TAX_RATE          ,
  NULL		,   --MAX_TAX_RATE          ,
  ENABLED_FLAG          ,
  'Y'           ,   --ALLOW_EXEMPTIONS_FLAG ,
  'Y'           ,   --ALLOW_EXCEPTIONS_FLAG ,
  'MIGRATED'    ,   --RECORD_TYPE_CODE      ,
  sysdate , -- CREATION_DATE         ,
  sysdate , -- LAST_UPDATE_DATE      ,
  fnd_global.conc_request_id, --  REQUEST_ID            ,
  fnd_global.prog_appl_id,     --PROGRAM_APPLICATION_ID,
  NULL,             --   PROGRAM_ID            ,
  CONDITION_SET_ID      ,
  EXCEPTION_SET_ID      ,
  NULL			,      -- PROGRAM_LOGIN_ID      ,
  zx_process_results_s.nextval,
  CONTENT_OWNER_ID      ,
  condition_group_id,
  tax_rule_id,
  fnd_global.user_id      ,    --CREATED_BY            ,
  fnd_global.user_id      ,    --LAST_UPDATED_BY       ,
  fnd_global.conc_login_id,    --LAST_UPDATE_LOGIN
  NULL        ,    --            RESULT_API            ,
  1               --OBJECT_VERSION_NUMBER
FROM
(
SELECT
  CONDITION_GROUP_CODE,
  1                             PRIORITY            ,
  rules.ENABLED_FLAG          ENABLED_FLAG,
  PTP.party_tax_profile_id    CONTENT_OWNER_ID      ,
  CONDITION_GROUP_ID,
  rules.tax_rule_id           TAX_RULE_ID           ,
  NULL			      CONDITION_SET_ID      ,
  NULL			      EXCEPTION_SET_ID      ,
  decode(vat.leasing_flag,'Y',vat.tax_code,'STANDARD') RATE_RESULT
FROM ZX_TAXES_B TAXES,
     ZX_CONDITION_GROUPS_B CG,
     ZX_PARTY_TAX_PROFILE PTP,
     AR_VAT_TAX_ALL_B VAT  ,
     ZX_RULES_B       RULES,
     ar_system_parameters_all sys
WHERE
     taxes.RECORD_TYPE_CODE  = 'MIGRATED'
AND  taxes.tax_type_code = 'LOCATION'
AND  taxes.live_for_applicability_flag = 'Y'
AND  taxes.content_owner_id = -99
AND  taxes.tax_regime_code = sys.default_country||'-SALES-TAX-'||sys.location_structure_id
AND  vat.tax_type = 'LOCATION'
AND  vat.enabled_flag = 'Y'
AND  vat.set_of_books_id = sys.set_of_books_id
AND  vat.org_id = sys.org_id
AND  vat.org_id = ptp.party_id
AND  ptp.party_type_code = 'OU'
AND  ptp.party_tax_profile_id = rules.content_owner_id
AND  taxes.tax_regime_code = rules.tax_regime_code
AND  taxes.tax = rules.tax
AND  rules.service_type_code ='DET_DIRECT_RATE'    --Bug 5385949
AND  rules.RECOVERY_TYPE_CODE IS NULL
AND  rules.tax_rule_code = taxes.TAX
-- AND  rules.effective_from = taxes.effective_from
AND  rules.priority = 1
AND  CG.condition_group_code = SUBSTRB(vat.tax_code,1,40)
                                 ||DECODE(vat.tax_constraint_id,
                                          NULL, '', '~'||vat.tax_constraint_id)
--Added following AND condition for Sync process
AND  vat.vat_tax_id = nvl(p_tax_id,vat.vat_tax_id)
AND not exists (select 1 from zx_process_results where
                tax_rule_id              = rules.tax_rule_id
                and condition_group_code = cg.condition_group_code
                and result_type_code ='CODE'    --Bug 5385949
		and rate_result is null
               )
UNION ALL
SELECT
     cond_groups.CONDITION_GROUP_CODE CONDITION_GROUP_CODE,
     NULL                          PRIORITY            ,--slokam
     gvat.enabled_flag                ENABLED_FLAG        ,
     ptp.party_tax_profile_id           CONTENT_OWNER_ID    ,
     cond_groups.CONDITION_GROUP_ID   CONDITION_GROUP_ID  ,
     rules.TAX_RULE_ID                TAX_RULE_ID         ,
     gc.TAX_CONDITION_ID              CONDITION_SET_ID    ,
     gc.TAX_EXCEPTION_ID              EXCEPTION_SET_ID    ,
     NULL                             RATE_RESULT
FROM AR_VAT_TAX_ALL_B         gvat,
     AR_TAX_GROUP_CODES_ALL gc,
     AR_VAT_TAX_ALL_B         vat,
     AR_TAX_CONDITIONS_ALL cond,
     AR_TAX_CONDITIONS_ALL excp,
     ZX_TAXES_B TAXES,
     ZX_RULES_B rules,
     ZX_CONDITION_GROUPS_B cond_groups,
     ZX_PARTY_TAX_PROFILE PTP,
     ar_system_parameters_all sys
WHERE
     gvat.vat_tax_id   = gc.tax_group_id
AND  gc.tax_group_type = 'AR'
AND  gvat.tax_type = 'TAX_GROUP'
AND  vat.tax_class = 'O'
AND  vat.vat_tax_id = gc.tax_code_id
AND  vat.tax_type <> 'TAX_GROUP'
AND  gc.tax_condition_id = cond.tax_condition_id (+)
AND  gc.tax_exception_id = excp.tax_condition_id (+)
AND  taxes.RECORD_TYPE_CODE  = 'MIGRATED'
AND  taxes.tax_type_code = 'LOCATION'
AND  taxes.live_for_applicability_flag = 'Y'
AND  taxes.content_owner_id = -99
AND  taxes.tax_regime_code = sys.default_country||'-SALES-TAX-'||sys.location_structure_id
AND  vat.tax_type = 'LOCATION'
AND  vat.set_of_books_id = sys.set_of_books_id
AND  vat.org_id = sys.org_id
AND  vat.org_id = ptp.party_id
AND  ptp.party_type_code = 'OU'
AND  ptp.party_tax_profile_id = rules.content_owner_id
AND  taxes.tax_regime_code = rules.tax_regime_code
AND  taxes.tax = rules.tax
AND  rules.service_type_code ='DET_DIRECT_RATE'  --Bug 5385949
AND  rules.RECOVERY_TYPE_CODE IS NULL
AND  rules.tax_rule_code = taxes.TAX
-- AND  rules.effective_from = taxes.effective_from
AND  rules.priority = (gc.tax_group_id * 2) + gc.display_order
--Added following AND condition for Sync process
AND  vat.vat_tax_id          =  nvl(p_tax_id,vat.vat_tax_id)
AND  cond_groups.condition_group_code = SUBSTRB(gvat.tax_code,1,40)
                                          ||DECODE(gvat.tax_constraint_id,
                                                   NULL, '', '~'||gvat.tax_constraint_id)
AND  cond_groups.enabled_flag = vat.enabled_flag
AND  not exists (select 1 from zx_process_results where
                 tax_rule_id              = rules.tax_rule_id
                 and condition_group_code = cond_groups.condition_group_code
                 AND ALPHANUMERIC_RESULT = 'APPLICABLE'
                )
);

-- Create applicability rule process results for the tax codes in the OKL tax group with at lease one
-- not null PFC, PTFC, TBC

INSERT INTO ZX_PROCESS_RESULTS (
  CONDITION_GROUP_CODE  ,
  PRIORITY              ,
  RESULT_TYPE_CODE      ,
  TAX_STATUS_CODE       ,
  NUMERIC_RESULT        ,
  ALPHANUMERIC_RESULT   ,
  STATUS_RESULT         ,
  RATE_RESULT           ,
  LEGAL_MESSAGE_CODE    ,
  MIN_TAX_AMT           ,
  MAX_TAX_AMT           ,
  MIN_TAXABLE_BASIS     ,
  MAX_TAXABLE_BASIS     ,
  MIN_TAX_RATE          ,
  MAX_TAX_RATE          ,
  ENABLED_FLAG          ,
  ALLOW_EXEMPTIONS_FLAG ,
  ALLOW_EXCEPTIONS_FLAG ,
  RECORD_TYPE_CODE      ,
  CREATION_DATE         ,
  LAST_UPDATE_DATE      ,
  REQUEST_ID            ,
  PROGRAM_APPLICATION_ID,
  PROGRAM_ID            ,
  CONDITION_SET_ID      ,
  EXCEPTION_SET_ID      ,
  PROGRAM_LOGIN_ID      ,
  RESULT_ID             ,
  CONTENT_OWNER_ID      ,
  CONDITION_GROUP_ID    ,
  TAX_RULE_ID           ,
  CREATED_BY            ,
  LAST_UPDATED_BY       ,
  LAST_UPDATE_LOGIN     ,
  RESULT_API            ,
  OBJECT_VERSION_NUMBER
)
SELECT
  CONDITION_GROUP_CODE  ,
  nvl(PRIORITY,ar_vat_tax_s.nextval),--slokam
  'APPLICABILITY'        ,   --RESULT_TYPE_CODE      ,
  NULL		,   --TAX_STATUS_CODE       ,
  NULL		,   --NUMERIC_RESULT        ,
  'APPLICABLE'  ,   --ALPHANUMERIC_RESULT   ,
  NULL ,   --STATUS_RESULT         ,
  NULL   ,   --RATE_RESULT           ,
  NULL		,   --LEGAL_MESSAGE_CODE    ,
  NULL		,   --MIN_TAX_AMT           ,
  NULL		,   --MAX_TAX_AMT           ,
  NULL		,   --MIN_TAXABLE_BASIS     ,
  NULL		,   --MAX_TAXABLE_BASIS     ,
  NULL		,   --MIN_TAX_RATE          ,
  NULL		,   --MAX_TAX_RATE          ,
  ENABLED_FLAG          ,
  NULL           ,   --ALLOW_EXEMPTIONS_FLAG ,
  NULL           ,   --ALLOW_EXCEPTIONS_FLAG ,
  'MIGRATED'    ,   --RECORD_TYPE_CODE      ,
  sysdate , -- CREATION_DATE         ,
  sysdate , -- LAST_UPDATE_DATE      ,
  fnd_global.conc_request_id, --  REQUEST_ID            ,
  fnd_global.prog_appl_id,     --PROGRAM_APPLICATION_ID,
  NULL,             --   PROGRAM_ID            ,
  CONDITION_SET_ID      ,
  EXCEPTION_SET_ID      ,
  NULL			,      -- PROGRAM_LOGIN_ID      ,
  zx_process_results_s.nextval,
  CONTENT_OWNER_ID      ,
  condition_group_id,
  tax_rule_id,
  fnd_global.user_id      ,    --CREATED_BY            ,
  fnd_global.user_id      ,    --LAST_UPDATED_BY       ,
  fnd_global.conc_login_id,    --LAST_UPDATE_LOGIN
  NULL        ,    --            RESULT_API            ,
  1               --OBJECT_VERSION_NUMBER
FROM
(
SELECT
     cg.CONDITION_GROUP_CODE CONDITION_GROUP_CODE,
     NULL                          PRIORITY            ,--slokam
     gvat.enabled_flag                ENABLED_FLAG        ,
     rules.content_owner_id            CONTENT_OWNER_ID    ,
     cg.CONDITION_GROUP_ID   CONDITION_GROUP_ID  ,
     rules.TAX_RULE_ID                TAX_RULE_ID         ,
     taxgrp.TAX_CONDITION_ID              CONDITION_SET_ID    ,
     taxgrp.TAX_EXCEPTION_ID              EXCEPTION_SET_ID

FROM AR_VAT_TAX_ALL_B       gvat,
     AR_TAX_GROUP_CODES_ALL taxgrp,
     ZX_TAXES_B             TAXES,
     ZX_RULES_B             rules,
     ZX_CONDITION_GROUPS_B  cg
WHERE gvat.vat_tax_id   = taxgrp.tax_group_id
AND  taxgrp.tax_group_type = 'AR'
AND  gvat.tax_type = 'TAX_GROUP'
AND  taxgrp.product_fisc_classification ||
     taxgrp.trx_business_category_code ||
     taxgrp.party_fisc_classification IS NOT NULL
AND  taxes.TAX_TYPE_CODE NOT IN ('AWT','OFFSET', 'LOCATION')
AND  taxes.RECORD_TYPE_CODE  = 'MIGRATED'
AND  EXISTS (SELECT 1
               FROM zx_rates_b rates,
                    ar_vat_tax_all vat
              WHERE taxgrp.tax_code_id = vat.vat_tax_id
                AND taxgrp.org_id = vat.org_id
                AND vat.vat_tax_id = rates.tax_rate_id
                AND rates.tax = taxes.tax
                AND rates.tax_regime_code = taxes.tax_regime_code
                AND rates.content_owner_id = taxes.content_owner_id
                AND rates.record_type_code = 'MIGRATED'
          )
AND  rules.tax_regime_code = taxes.tax_regime_code
AND  rules.tax = taxes.tax
AND  rules.content_owner_id = taxes.content_owner_id
AND  rules.service_type_code = 'DET_APPLICABLE_TAXES'
AND  rules.recovery_type_code IS NULL
AND  rules.tax_rule_code = taxes.TAX
--AND  rules.effective_from = taxes.effective_from
AND  rules.priority = 1
--Added following AND condition for Sync process
AND  gvat.vat_tax_id          =  nvl(p_tax_id,gvat.vat_tax_id)
AND  SUBSTRB(cg.condition_group_code,1,44) = SUBSTRB(gvat.tax_code,1,44)
AND  cg.ALPHANUMERIC_VALUE2||cg.ALPHANUMERIC_VALUE3||cg.ALPHANUMERIC_VALUE4
      = taxgrp.product_fisc_classification ||
        taxgrp.trx_business_category_code ||
        taxgrp.party_fisc_classification
AND  cg.enabled_flag = 'Y'
AND  not exists (select 1 from zx_process_results where
                tax_rule_id              = rules.tax_rule_id
                and condition_group_code = cg.condition_group_code
                and result_type_code = 'APPLICABILITY'
               )
UNION ALL
SELECT
     cg.condition_group_code CONDITION_GROUP_CODE,
     NULL                          PRIORITY            ,--slokam
     gvat.enabled_flag                ENABLED_FLAG        ,
     rules.content_owner_id           CONTENT_OWNER_ID    ,
     cg.condition_group_id   CONDITION_GROUP_ID  ,
     rules.TAX_RULE_ID                TAX_RULE_ID         ,
     taxgrp.tax_condition_id              CONDITION_SET_ID    ,
     taxgrp.tax_exception_id              EXCEPTION_SET_ID

FROM AR_VAT_TAX_ALL_B         gvat,
     AR_TAX_GROUP_CODES_ALL taxgrp,
     ZX_TAXES_B TAXES,
     ZX_RULES_B rules,
     ZX_CONDITION_GROUPS_B cg,
     ar_system_parameters_all sys,
     zx_party_tax_profile ptp

WHERE  taxgrp.tax_group_type = 'AR'
AND  taxgrp.product_fisc_classification ||
      taxgrp.trx_business_category_code ||
     taxgrp.party_fisc_classification IS NOT NULL
AND  gvat.vat_tax_id = taxgrp.tax_group_id
AND  gvat.tax_type = 'TAX_GROUP'
AND  taxes.RECORD_TYPE_CODE  = 'MIGRATED'
AND  taxes.live_for_applicability_flag = 'Y' -- add to filter location taxes defined in 11i
AND  taxes.tax_type_code = 'LOCATION'
AND  taxes.content_owner_id = -99
AND  taxes.tax_regime_code = sys.default_country||'-SALES-TAX-'||sys.location_structure_id
AND  gvat.set_of_books_id = sys.set_of_books_id
AND  gvat.org_id = sys.org_id
AND  sys.org_id = ptp.party_id
AND  ptp.party_type_code = 'OU'
/*  AND EXISTS (SELECT 1
	      FROM ar_vat_tax_all_b vat
	     WHERE vat.tax_type = 'LOCATION'
	       AND vat.set_of_books_id = sys.set_of_books_id
	       AND vat.org_id = sys.org_id
	       AND vat.enabled_flag = 'Y'
	       ) */
-- find the migrationed location based taxes in the tax group and
-- filter the disabled location based tax
AND  EXISTS (SELECT 1
               FROM zx_rates_b rates,
                    ar_vat_tax_all tax
              WHERE taxgrp.tax_code_id = tax.vat_tax_id
                AND taxgrp.org_id = tax.org_id
                AND tax.vat_tax_id = rates.tax_rate_id
                AND tax.tax_type = 'LOCATION'
                AND rates.tax <> taxes.tax
                AND rates.tax_regime_code = taxes.tax_regime_code
                AND rates.content_owner_id = taxes.content_owner_id
                AND rates.record_type_code = 'MIGRATED'
          )
AND  rules.tax_regime_code = taxes.tax_regime_code
AND  rules.tax = taxes.tax
AND  rules.content_owner_id = ptp.party_tax_profile_id
AND  rules.service_type_code ='DET_APPLICABLE_TAXES'
AND  rules.recovery_type_code IS NULL
AND  rules.tax_rule_code = taxes.tax
--AND  rules.effective_from = taxes.effective_from
AND  rules.priority = 1
--Added following AND condition for Sync process
AND  gvat.vat_tax_id          =  nvl(p_tax_id,gvat.vat_tax_id)
AND  SUBSTRB(cg.condition_group_code, 1, 44) = SUBSTRB(gvat.tax_code,1,44)
AND  cg.ALPHANUMERIC_VALUE2||cg.ALPHANUMERIC_VALUE3||cg.ALPHANUMERIC_VALUE4
      = taxgrp.product_fisc_classification ||
        taxgrp.trx_business_category_code ||
        taxgrp.party_fisc_classification
AND  cg.enabled_flag = 'Y'
AND not exists (select 1 from zx_process_results where
                tax_rule_id              = rules.tax_rule_id
                and condition_group_code = cg.condition_group_code
                and result_type_code ='APPLICABILITY'
               )
);


-- Create rate det rule process results for the tax codes in the OKL tax group with at lease one
-- not null PFC, PTFC, TBC

INSERT INTO ZX_PROCESS_RESULTS (
  CONDITION_GROUP_CODE  ,
  PRIORITY              ,
  RESULT_TYPE_CODE      ,
  TAX_STATUS_CODE       ,
  NUMERIC_RESULT        ,
  ALPHANUMERIC_RESULT   ,
  STATUS_RESULT         ,
  RATE_RESULT           ,
  LEGAL_MESSAGE_CODE    ,
  MIN_TAX_AMT           ,
  MAX_TAX_AMT           ,
  MIN_TAXABLE_BASIS     ,
  MAX_TAXABLE_BASIS     ,
  MIN_TAX_RATE          ,
  MAX_TAX_RATE          ,
  ENABLED_FLAG          ,
  ALLOW_EXEMPTIONS_FLAG ,
  ALLOW_EXCEPTIONS_FLAG ,
  RECORD_TYPE_CODE      ,
  CREATION_DATE         ,
  LAST_UPDATE_DATE      ,
  REQUEST_ID            ,
  PROGRAM_APPLICATION_ID,
  PROGRAM_ID            ,
  CONDITION_SET_ID      ,
  EXCEPTION_SET_ID      ,
  PROGRAM_LOGIN_ID      ,
  RESULT_ID             ,
  CONTENT_OWNER_ID      ,
  CONDITION_GROUP_ID    ,
  TAX_RULE_ID           ,
  CREATED_BY            ,
  LAST_UPDATED_BY       ,
  LAST_UPDATE_LOGIN     ,
  RESULT_API            ,
  OBJECT_VERSION_NUMBER
)
SELECT
  CONDITION_GROUP_CODE  ,
  nvl(PRIORITY,ar_vat_tax_s.nextval),--slokam
  'CODE'        ,   --RESULT_TYPE_CODE      ,
  NULL		,   --TAX_STATUS_CODE       ,
  NULL		,   --NUMERIC_RESULT        ,
  'APPLICABLE'  ,   --ALPHANUMERIC_RESULT   ,
  STATUS_RESULT ,   --STATUS_RESULT         ,
  RATE_RESULT   ,   --RATE_RESULT           ,
  NULL		,   --LEGAL_MESSAGE_CODE    ,
  NULL		,   --MIN_TAX_AMT           ,
  NULL		,   --MAX_TAX_AMT           ,
  NULL		,   --MIN_TAXABLE_BASIS     ,
  NULL		,   --MAX_TAXABLE_BASIS     ,
  NULL		,   --MIN_TAX_RATE          ,
  NULL		,   --MAX_TAX_RATE          ,
  ENABLED_FLAG          ,
  NULL           ,   --ALLOW_EXEMPTIONS_FLAG ,
  NULL           ,   --ALLOW_EXCEPTIONS_FLAG ,
  'MIGRATED'    ,   --RECORD_TYPE_CODE      ,
  sysdate , -- CREATION_DATE         ,
  sysdate , -- LAST_UPDATE_DATE      ,
  fnd_global.conc_request_id, --  REQUEST_ID            ,
  fnd_global.prog_appl_id,     --PROGRAM_APPLICATION_ID,
  NULL,             --   PROGRAM_ID            ,
  CONDITION_SET_ID      ,
  EXCEPTION_SET_ID      ,
  NULL			,      -- PROGRAM_LOGIN_ID      ,
  zx_process_results_s.nextval,
  CONTENT_OWNER_ID      ,
  condition_group_id,
  tax_rule_id,
  fnd_global.user_id      ,    --CREATED_BY            ,
  fnd_global.user_id      ,    --LAST_UPDATED_BY       ,
  fnd_global.conc_login_id,    --LAST_UPDATE_LOGIN
  NULL        ,    --            RESULT_API            ,
  1               --OBJECT_VERSION_NUMBER
FROM
(
SELECT
     cg.CONDITION_GROUP_CODE CONDITION_GROUP_CODE,
     NULL                          PRIORITY            ,--slokam
     gvat.enabled_flag                ENABLED_FLAG        ,
     rules.content_owner_id            CONTENT_OWNER_ID    ,
     cg.CONDITION_GROUP_ID   CONDITION_GROUP_ID  ,
     rules.TAX_RULE_ID                TAX_RULE_ID         ,
     taxgrp.TAX_CONDITION_ID              CONDITION_SET_ID    ,
     taxgrp.TAX_EXCEPTION_ID              EXCEPTION_SET_ID    ,
     rates.tax_status_code       STATUS_RESULT         ,
     rates.tax_rate_code         RATE_RESULT

FROM AR_VAT_TAX_ALL_B       gvat,
     AR_TAX_GROUP_CODES_ALL taxgrp,
     AR_VAT_TAX_ALL_B       vat,
--     ZX_TAXES_B             TAXES,
     ZX_RULES_B             rules,
     ZX_CONDITION_GROUPS_B  cg,
     ZX_RATES_B             rates
WHERE gvat.vat_tax_id   = taxgrp.tax_group_id
AND  taxgrp.tax_group_type = 'AR'
AND  gvat.tax_type = 'TAX_GROUP'
AND  taxgrp.product_fisc_classification ||
     taxgrp.trx_business_category_code ||
     taxgrp.party_fisc_classification IS NOT NULL
AND  vat.tax_class = 'O'
AND  vat.vat_tax_id = taxgrp.tax_code_id
AND  vat.vat_tax_id = rates.tax_rate_id
AND  vat.tax_type NOT IN ('TAX_GROUP', 'LOCATION')
AND  rates.RECORD_TYPE_CODE  = 'MIGRATED'
--AND  rates.tax_regime_code = taxes.tax_regime_code
--AND  rates.tax = taxes.tax
--AND  taxes.RECORD_TYPE_CODE  = 'MIGRATED'
--AND  rates.content_owner_id = taxes.content_owner_id
AND  rates.tax_regime_code = rules.tax_regime_code
AND  rates.tax = rules.tax
AND  rates.content_owner_id = rules.content_owner_id
AND  rules.service_type_code = 'DET_TAX_RATE'
AND  rules.recovery_type_code IS NULL
AND  rules.tax_rule_code = rates.TAX
--AND  rules.effective_from = taxes.effective_from
AND  rules.priority = 1
--Added following AND condition for Sync process
AND  vat.vat_tax_id          =  nvl(p_tax_id,vat.vat_tax_id)
AND  SUBSTRB(cg.condition_group_code,1,44) = SUBSTRB(gvat.tax_code,1,44)
AND  cg.ALPHANUMERIC_VALUE2||cg.ALPHANUMERIC_VALUE3||cg.ALPHANUMERIC_VALUE4
      = taxgrp.product_fisc_classification ||
        taxgrp.trx_business_category_code ||
        taxgrp.party_fisc_classification
AND  cg.enabled_flag = vat.enabled_flag
AND  not exists (select 1 from zx_process_results where
                tax_rule_id              = rules.tax_rule_id
                and condition_group_code = cg.condition_group_code
                and result_type_code = 'CODE'
               )
UNION ALL
SELECT
     cg.condition_group_code CONDITION_GROUP_CODE,
     NULL                          PRIORITY            ,--slokam
     gvat.enabled_flag                ENABLED_FLAG        ,
     rules.content_owner_id           CONTENT_OWNER_ID    ,
     cg.condition_group_id   CONDITION_GROUP_ID  ,
     rules.TAX_RULE_ID                TAX_RULE_ID         ,
     taxgrp.tax_condition_id              CONDITION_SET_ID    ,
     taxgrp.tax_exception_id              EXCEPTION_SET_ID    ,
     rates.tax_status_code       STATUS_RESULT         ,
     rates.tax_rate_code         RATE_RESULT

FROM AR_VAT_TAX_ALL_B         gvat,
     AR_TAX_GROUP_CODES_ALL taxgrp,
     AR_VAT_TAX_ALL_B         vat,
     ZX_TAXES_B TAXES,
     ZX_RULES_B rules,
     ZX_CONDITION_GROUPS_B cg,
     ar_system_parameters_all sys,
     zx_party_tax_profile  ptp,
     ZX_RATES_B  oklrates,
     ZX_RATES_B  rates

WHERE  taxgrp.tax_group_type = 'AR'
AND  taxgrp.product_fisc_classification ||
     taxgrp.trx_business_category_code ||
     taxgrp.party_fisc_classification IS NOT NULL
AND  gvat.vat_tax_id = taxgrp.tax_group_id
AND  gvat.tax_type = 'TAX_GROUP'
AND  vat.vat_tax_id = taxgrp.tax_code_id
AND  vat.tax_class = 'O'
AND  vat.vat_tax_id = oklrates.tax_rate_id -- not create rule for the disabled location based taxes
AND  vat.tax_type = 'LOCATION'
AND  oklrates.record_type_code  = 'MIGRATED'
AND  rates.tax_regime_code = oklrates.tax_regime_code
AND  rates.tax = oklrates.tax
AND  rates.tax_status_code = oklrates.tax_status_code
AND  rates.tax_rate_code <> oklrates.tax_rate_code
AND  rates.record_type_code  = 'MIGRATED'
AND  rates.tax_regime_code = taxes.tax_regime_code
AND  rates.tax = taxes.tax
AND  taxes.record_type_code  = 'MIGRATED'
AND  taxes.tax_type_code = 'LOCATION'
AND  taxes.live_for_applicability_flag = 'Y'
AND  taxes.content_owner_id = -99
AND  taxes.tax_regime_code = sys.default_country||'-SALES-TAX-'||sys.location_structure_id
AND  gvat.set_of_books_id = sys.set_of_books_id
AND  gvat.org_id = sys.org_id
AND  ptp.party_id = sys.org_id
AND  ptp.party_type_code = 'OU'
AND  rules.tax_regime_code = taxes.tax_regime_code
AND  rules.tax = taxes.tax
AND  rules.content_owner_id = ptp.party_tax_profile_id
AND  rules.service_type_code ='DET_TAX_RATE'
AND  rules.recovery_type_code IS NULL
AND  rules.tax_rule_code = taxes.tax
-- AND  rules.effective_from = taxes.effective_from
AND  rules.priority = 1
--Added following AND condition for Sync process
AND  vat.vat_tax_id          =  nvl(p_tax_id,vat.vat_tax_id)
AND  SUBSTRB(cg.condition_group_code, 1, 44) = SUBSTRB(gvat.tax_code,1,44)
AND  cg.ALPHANUMERIC_VALUE2||cg.ALPHANUMERIC_VALUE3||cg.ALPHANUMERIC_VALUE4
      = taxgrp.product_fisc_classification ||
        taxgrp.trx_business_category_code ||
        taxgrp.party_fisc_classification
AND  cg.enabled_flag = vat.enabled_flag
AND not exists (select 1 from zx_process_results where
                tax_rule_id              = rules.tax_rule_id
                and condition_group_code = cg.condition_group_code
                and result_type_code ='CODE'
               )
);


END IF;

     IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('Create_Process_Results(-)');
     END IF;
EXCEPTION
         WHEN OTHERS THEN
             IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Create_process_results ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('Create_Process_Results(-)');
             END IF;
             --app_exception.raise_exception;
END create_process_results;

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
    arp_util_tax.debug('Exception in constructor of Tax Hierarchy Migration '||sqlerrm);



END Zx_Migrate_Tax_Default_Hier;

/
