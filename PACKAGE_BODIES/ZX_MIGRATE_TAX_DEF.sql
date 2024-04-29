--------------------------------------------------------
--  DDL for Package Body ZX_MIGRATE_TAX_DEF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_MIGRATE_TAX_DEF" AS
/* $Header: zxtaxdefmigb.pls 120.124.12010000.6 2009/02/05 12:14:05 srajapar ship $ */


PG_DEBUG CONSTANT VARCHAR(1) := 'Y';
ID_CLASH VARCHAR2(1) default NULL;

procedure CREATE_ADHOC_RECOVERY_RATES; -- Bug : 4622937


l_multi_org_flag fnd_product_groups.multi_org_flag%type;
l_org_id NUMBER(15);


PROCEDURE migrate_disabled_tax_codes(p_tax_id IN NUMBER DEFAULT NULL);
PROCEDURE stamp_default_rate_flag;
PROCEDURE migrate_recovery_rates_rules;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    migrate_ap_tax_codes_setup                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine is a wrapper for migration of AP TAX SETUP.              |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        migrate_ap_tax_codes_setup                                         |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-Dec-03  Srinivas Lokam      Created.                               |
 |                                                                           |
 |==========================================================================*/


PROCEDURE Migrate_Ap_Tax_Codes_Setup is
BEGIN
    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('Migrate_Ap_Tax_Codes_Setup(+)');
    END IF;
     SavePoint Ap_Tax_Setup;

     BEGIN
     arp_util_tax.debug('b:Migrate FND LOOKUPS');
       BEGIN
         migrate_fnd_lookups;
       EXCEPTION WHEN OTHERS THEN
      arp_util_tax.debug('Exception encountered in migrate_fnd_lookups:'||sqlerrm);
       END;
     arp_util_tax.debug('a:Migrate FND LOOKUPS');

   --BugFix 3557681
     arp_util_tax.debug('b:Create Tax Classifications');
        BEGIN
         Create_Tax_Classifications;
        EXCEPTION WHEN OTHERS THEN
         arp_util_tax.debug('Exception encountered in Create Tax Classifications:'||sqlerrm);
        END;
     arp_util_tax.debug('a:Create Tax Classifications');

      arp_util_tax.debug('b:Migrate Normal Tax Codes');
        BEGIN
          migrate_normal_tax_codes;
        EXCEPTION WHEN OTHERS THEN
          arp_util_tax.debug('Exception encountered in migrate_normal_tax_codes:' ||sqlerrm);
        END;

     arp_util_tax.debug('a:Migrate Normal Tax Codes');


     arp_util_tax.debug('b:Migrate Disabled Tax Codes');
        BEGIN
         migrate_disabled_tax_codes; --Bug Fix 4580573
        EXCEPTION WHEN OTHERS THEN
          arp_util_tax.debug('Exception encountered in migrate_disabled_tax_codes:' ||sqlerrm);
        END;

     arp_util_tax.debug('b:Migrate Disabled Tax Codes');

     arp_util_tax.debug('b:Migrate Assign Offset Tax Codes');
        BEGIN
         migrate_assign_offset_codes;
        EXCEPTION WHEN OTHERS THEN
          arp_util_tax.debug('Exception encountered in migrate_assign_offset_codes:' ||sqlerrm);
        END;
      arp_util_tax.debug('a:Migrate Assign Offset Tax Codes');

     arp_util_tax.debug('b:Migrate Un Assign Offset Tax Codes');
        BEGIN
         migrate_unassign_offset_codes;
        EXCEPTION WHEN OTHERS THEN
          arp_util_tax.debug('Exception encountered in migrate_unassign_offset_codes:' ||sqlerrm);
        END;

      arp_util_tax.debug('a:Migrate Un Assign Offset Tax Codes');

       /* Bug 4710118 : To Ensure that atleast one rate code gets created with default_rate_flag = 'Y' for a particular
          Combination of regime , tax , status and Content Owner */
       /* Bug 5199954  To Ensure that atleast one rate code gets created with default_rate_flag = 'Y' for a particular
          Combination of regime , tax , status and Content Owner for a recovery rate */

       arp_util_tax.debug('b:Stamp Default Rate Flag');
    BEGIN
      stamp_default_rate_flag;
    EXCEPTION WHEN OTHERS THEN
           arp_util_tax.debug('Exception encountered in default rate flag updation logic in rates'||sqlerrm);
    END;

  arp_util_tax.debug('b:Create Status');
        BEGIN
           create_zx_statuses;
        EXCEPTION WHEN OTHERS THEN
           arp_util_tax.debug('Exception encountered in create_zx_statuses'||sqlerrm);
        END;


         arp_util_tax.debug('a:Create Status');


      arp_util_tax.debug('b:Create Taxes');
        BEGIN
         create_zx_taxes;
          EXCEPTION WHEN OTHERS THEN
         arp_util_tax.debug('Exception encountered in create_zx_taxes'||sqlerrm);
        END;


      arp_util_tax.debug('a:Create Taxes');

    -- Added for Bug : 4622937 : For Adhoc Recovery Rate Creation .
        arp_util_tax.debug('b:Create_Adhoc_Recovery_Rates');
        BEGIN
         Create_Adhoc_Recovery_Rates;
          EXCEPTION WHEN OTHERS THEN
         arp_util_tax.debug('Exception encountered in Create_Adhoc_Recovery_Rates'||sqlerrm);
        END;

       arp_util_tax.debug('a:Create_Adhoc_Recovery_Rates');
      arp_util_tax.debug('b:Migrate Recovery Rates Rules');
         BEGIN
      migrate_recovery_rates_rules;
         EXCEPTION WHEN OTHERS THEN
           arp_util_tax.debug('Exception encountered in migrate_recovery logic '||sqlerrm);
         END;
       arp_util_tax.debug('a:Migrate Recovery Rates Rules');

       arp_util_tax.debug('b:Create Tax Accounts');
        BEGIN
         create_tax_accounts;
          EXCEPTION WHEN OTHERS THEN
         arp_util_tax.debug('Exception encountered in create_tax_accounts'||sqlerrm);
        END;

       arp_util_tax.debug('a:Create Tax Accounts');

     arp_util_tax.debug('b:Create Templates');
       BEGIN
         create_templates;
       EXCEPTION WHEN OTHERS THEN
         arp_util_tax.debug('Exception encountered in create_tax_accounts'||sqlerrm);
       END;

        arp_util_tax.debug('a:Create Templates');

     arp_util_tax.debug('b:Create Condition Groups');

       BEGIN
         create_condition_groups;
       EXCEPTION WHEN OTHERS THEN
         arp_util_tax.debug('Exception encountered in create_condition_groups'||sqlerrm);
       END;

      arp_util_tax.debug('a:Create Condition Groups');

      arp_util_tax.debug('b:Create Rules');
       BEGIN
         create_rules;
       EXCEPTION WHEN OTHERS THEN
         arp_util_tax.debug('Exception encountered in create_condition_groups'||sqlerrm);
       END;

       arp_util_tax.debug('a:Create Rules');

      arp_util_tax.debug('b:Migrate Recovery Rates');
         BEGIN
      migrate_recovery_rates;  --Bug Fix 553303
         EXCEPTION WHEN OTHERS THEN
           arp_util_tax.debug('Exception encountered in migrate_recovery logic '||sqlerrm);
         END;
       arp_util_tax.debug('a:Migrate Recovery Rates');

    EXCEPTION
  WHEN OTHERS THEN
     arp_util_tax.debug('ERROR: '||sqlerrm);
    END;


    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('Migrate_Ap_Tax_Codes_Setup(-)');
    END IF;
EXCEPTION
         WHEN OTHERS THEN
             IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Migrate_ap_tax_codes_setup ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('Migrate_Ap_Tax_Codes_Setup(-)');
             END IF;
             RollBack To Ap_Tax_Setup;
             --app_exception.raise_exception;
END migrate_ap_tax_codes_setup;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    migrate_fnd_lookups                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This routine processes AP Tax_setup related fnd_lookups and creates    |
 |    appropriate ZX lookups in FND_LOOKUPS.                                 |
 |    For Instance                                                           |
 |    AP_TAX_CODES_ALL.VAT_TRANSACTION_TYPE --> ZX_RATES.VAT_TRANSACTION_TYPE|
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        migrate_ap_tax_codes_setup                                         |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-Dec-03  Srinivas Lokam      Created.                               |
 |                                                                           |
 |==========================================================================*/

PROCEDURE migrate_fnd_lookups IS

  l_cnt  PLS_INTEGER := 0;

BEGIN
    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('Migrate_fnd_lookups(+)');
    END IF;
/* For VAT_TRANSACTION_TYPE Lookup */

/*SELECT count(vat_transaction_type)
INTO   l_cnt
FROM   ap_tax_codes_all;

IF l_cnt <> 0 THEN*/
BEGIN
  INSERT INTO FND_LOOKUP_VALUES
  (
   LOOKUP_TYPE            ,
   LANGUAGE               ,
   LOOKUP_CODE            ,
   MEANING                ,
   DESCRIPTION            ,
   ENABLED_FLAG           ,
   START_DATE_ACTIVE      ,
   END_DATE_ACTIVE        ,
   SOURCE_LANG            ,
   SECURITY_GROUP_ID      ,
   VIEW_APPLICATION_ID    ,
   TERRITORY_CODE         ,
   ATTRIBUTE_CATEGORY     ,
   ATTRIBUTE1             ,
   ATTRIBUTE2             ,
   ATTRIBUTE3             ,
   ATTRIBUTE4             ,
   ATTRIBUTE5             ,
   ATTRIBUTE6             ,
   ATTRIBUTE7             ,
   ATTRIBUTE8             ,
   ATTRIBUTE9             ,
   ATTRIBUTE10            ,
   ATTRIBUTE11            ,
   ATTRIBUTE12            ,
   ATTRIBUTE13            ,
   ATTRIBUTE14            ,
   ATTRIBUTE15            ,
   TAG                    ,
   CREATION_DATE          ,
   CREATED_BY             ,
   LAST_UPDATE_DATE       ,
   LAST_UPDATED_BY        ,
   LAST_UPDATE_LOGIN
  )
  SELECT
  'ZX_JEBE_VAT_TRANS_TYPE' ,
   LANGUAGE                ,
   LOOKUP_CODE             ,
   MEANING                 ,
   DESCRIPTION             ,
   ENABLED_FLAG            ,
   nvl(START_DATE_ACTIVE, to_date('01/01/1951','DD/MM/YYYY')), --Bug 5589178
   END_DATE_ACTIVE         ,
   SOURCE_LANG             ,
   SECURITY_GROUP_ID       ,
   VIEW_APPLICATION_ID     ,
   TERRITORY_CODE          ,
   ATTRIBUTE_CATEGORY      ,
   ATTRIBUTE1              ,
   ATTRIBUTE2              ,
   ATTRIBUTE3              ,
   ATTRIBUTE4              ,
   ATTRIBUTE5              ,
   ATTRIBUTE6              ,
   ATTRIBUTE7              ,
   ATTRIBUTE8              ,
   ATTRIBUTE9              ,
   ATTRIBUTE10             ,
   ATTRIBUTE11             ,
   ATTRIBUTE12             ,
   ATTRIBUTE13             ,
   ATTRIBUTE14             ,
   ATTRIBUTE15             ,
   TAG                     ,
   SYSDATE                 ,
   fnd_global.user_id      ,
   SYSDATE                 ,
   fnd_global.user_id      ,
   fnd_global.conc_login_id
  FROM FND_LOOKUP_VALUES ap_lookups
  WHERE ap_lookups.LOOKUP_TYPE = 'JEBE_VAT_TRANS_TYPE'
  AND NOT EXISTS
      (select 1 from FND_LOOKUP_VALUES
       where  lookup_type = 'ZX_JEBE_VAT_TRANS_TYPE'
       and    lookup_code = ap_lookups.lookup_code);
EXCEPTION
WHEN OTHERS THEN
       IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Migrate_fnd_lookups : JEBE_VAT_TRANS_TYPE');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('Migrate_fnd_lookups(-)');
             END IF;
END ;

--END IF;

/* For TAX_TYPE lookup */
/*l_cnt := 0;
SELECT count(tax_type)
INTO   l_cnt
FROM   ap_tax_codes_all;

IF l_cnt <> 0 THEN*/

  INSERT INTO FND_LOOKUP_VALUES
  (
   LOOKUP_TYPE            ,
   LANGUAGE               ,
   LOOKUP_CODE            ,
   MEANING                ,
   DESCRIPTION            ,
   ENABLED_FLAG           ,
   START_DATE_ACTIVE      ,
   END_DATE_ACTIVE        ,
   SOURCE_LANG            ,
   SECURITY_GROUP_ID      ,
   VIEW_APPLICATION_ID    ,
   TERRITORY_CODE         ,
   ATTRIBUTE_CATEGORY     ,
   ATTRIBUTE1             ,
   ATTRIBUTE2             ,
   ATTRIBUTE3             ,
   ATTRIBUTE4             ,
   ATTRIBUTE5             ,
   ATTRIBUTE6             ,
   ATTRIBUTE7             ,
   ATTRIBUTE8             ,
   ATTRIBUTE9             ,
   ATTRIBUTE10            ,
   ATTRIBUTE11            ,
   ATTRIBUTE12            ,
   ATTRIBUTE13            ,
   ATTRIBUTE14            ,
   ATTRIBUTE15            ,
   TAG                    ,
   CREATION_DATE          ,
   CREATED_BY             ,
   LAST_UPDATE_DATE       ,
   LAST_UPDATED_BY        ,
   LAST_UPDATE_LOGIN
  )
  SELECT
  'ZX_TAX_TYPE_CATEGORY'  ,
   LANGUAGE               ,
   LOOKUP_CODE            ,
   MEANING                ,
   DESCRIPTION            ,
   ENABLED_FLAG           ,
   nvl(START_DATE_ACTIVE, to_date('01/01/1951','DD/MM/YYYY')), --Bug 5589178
   END_DATE_ACTIVE        ,
   SOURCE_LANG            ,
   SECURITY_GROUP_ID      ,
   0                      ,
   TERRITORY_CODE         ,
   ATTRIBUTE_CATEGORY     ,
   ATTRIBUTE1             ,
   ATTRIBUTE2             ,
   ATTRIBUTE3             ,
   ATTRIBUTE4             ,
   ATTRIBUTE5             ,
   ATTRIBUTE6             ,
   ATTRIBUTE7             ,
   ATTRIBUTE8             ,
   ATTRIBUTE9             ,
   ATTRIBUTE10            ,
   ATTRIBUTE11            ,
   ATTRIBUTE12            ,
   ATTRIBUTE13            ,
   ATTRIBUTE14            ,
   ATTRIBUTE15            ,
   TAG                    ,
   SYSDATE                ,
   fnd_global.user_id     ,
   SYSDATE                ,
   fnd_global.user_id     ,
   fnd_global.conc_login_id
  FROM FND_LOOKUP_VALUES ap_lookups
  WHERE ap_lookups.LOOKUP_TYPE = 'TAX TYPE'
-- Changed the re-runnability check
   AND NOT EXISTS
      (select 1 from FND_LOOKUP_VALUES
       where  lookup_type = 'ZX_TAX_TYPE_CATEGORY'
       and    lookup_code = ap_lookups.lookup_code)
   and NOT EXISTS
      (select 1 from FND_LOOKUP_VALUES
       where  lookup_type = 'ZX_TAX_TYPE_CATEGORY'
       and    meaning = ap_lookups.meaning) ;

--END IF;

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('Migrate_fnd_lookups(-)');
    END IF;



EXCEPTION
         WHEN OTHERS THEN
             IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Migrate_fnd_lookups ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('Migrate_fnd_lookups(-)');
             END IF;
             --app_exception.raise_exception;

END migrate_fnd_lookups;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Create_Tax_Classifications                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This routine processes AP Tax Codes and creates associated             |
 |    Tax Classification records in  FND_LOOKUPS.                            |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        migrate_ap_tax_codes_setup                                         |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     01-Jun-04  Srinivas Lokam      BugFix 3557681 Created.                |
 |                                                                           |
 |==========================================================================*/

PROCEDURE Create_Tax_Classifications(p_tax_id IN NUMBER DEFAULT NULL) IS
BEGIN
    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('Create_Tax_Classifications(+)');
    END IF;

/* For AP and AR  LookupType */

INSERT ALL
WHEN (NOT EXISTS
      (SELECT 1 FROM FND_LOOKUP_TYPES
       WHERE LOOKUP_TYPE = 'ZX_INPUT_CLASSIFICATIONS')
      ) THEN
INTO FND_LOOKUP_TYPES
(
 APPLICATION_ID         ,
 LOOKUP_TYPE            ,
 CUSTOMIZATION_LEVEL    ,
 SECURITY_GROUP_ID      ,
 VIEW_APPLICATION_ID    ,
 CREATION_DATE          ,
 CREATED_BY             ,
 LAST_UPDATE_DATE       ,
 LAST_UPDATED_BY        ,
 LAST_UPDATE_LOGIN
)
VALUES
(
 235                    ,
'ZX_INPUT_CLASSIFICATIONS' ,
'E'                      ,
 0                       ,
 0                       ,
 SYSDATE                 ,
 fnd_global.user_id      ,
 SYSDATE                 ,
 fnd_global.user_id      ,
 fnd_global.conc_login_id
)
WHEN (NOT EXISTS
      (SELECT 1 FROM FND_LOOKUP_TYPES
       WHERE LOOKUP_TYPE = 'ZX_OUTPUT_CLASSIFICATIONS')
      ) THEN
INTO FND_LOOKUP_TYPES
(
 APPLICATION_ID         ,
 LOOKUP_TYPE            ,
 CUSTOMIZATION_LEVEL    ,
 SECURITY_GROUP_ID      ,
 VIEW_APPLICATION_ID    ,
 CREATION_DATE          ,
 CREATED_BY             ,
 LAST_UPDATE_DATE       ,
 LAST_UPDATED_BY        ,
 LAST_UPDATE_LOGIN
)
VALUES
(
 235                    ,
'ZX_OUTPUT_CLASSIFICATIONS' ,
'E'                      ,
 0                       ,
 0                       ,
 SYSDATE                 ,
 fnd_global.user_id      ,
 SYSDATE                 ,
 fnd_global.user_id      ,
 fnd_global.conc_login_id
)
WHEN (NOT EXISTS
      (SELECT 1 FROM FND_LOOKUP_TYPES
       WHERE LOOKUP_TYPE = 'ZX_WEB_EXP_TAX_CLASSIFICATIONS')
      ) THEN
INTO FND_LOOKUP_TYPES
(
 APPLICATION_ID         ,
 LOOKUP_TYPE            ,
 CUSTOMIZATION_LEVEL    ,
 SECURITY_GROUP_ID      ,
 VIEW_APPLICATION_ID    ,
 CREATION_DATE          ,
 CREATED_BY             ,
 LAST_UPDATE_DATE       ,
 LAST_UPDATED_BY        ,
 LAST_UPDATE_LOGIN
)
VALUES
(
 235                    ,
'ZX_WEB_EXP_TAX_CLASSIFICATIONS' ,
'E'                      ,
 0                       ,
 0                       ,
 SYSDATE                 ,
 fnd_global.user_id      ,
 SYSDATE                 ,
 fnd_global.user_id      ,
 fnd_global.conc_login_id
)
SELECT 1  FROM DUAL;

INSERT INTO FND_LOOKUP_TYPES_TL
(
            LOOKUP_TYPE,
            SECURITY_GROUP_ID,
            VIEW_APPLICATION_ID,
            LANGUAGE,
            SOURCE_LANG,
            MEANING,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
)
SELECT
            types.lookup_type,
            0                ,--SECURITY_GROUP_ID
            0                ,--VIEW_APPLICATION_ID
            L.LANGUAGE_CODE  ,
            userenv('LANG')  ,
      CASE WHEN types.lookup_type = UPPER(types.lookup_type)
       THEN    Initcap(types.lookup_type)
       ELSE
         types.lookup_type
       END,--MEANING
            types.lookup_type,--DESCRIPTION
            fnd_global.user_id             ,
            SYSDATE                        ,
            fnd_global.user_id             ,
            SYSDATE                        ,
            fnd_global.conc_login_id
FROM        FND_LOOKUP_TYPES types,
            FND_LANGUAGES L
WHERE  L.INSTALLED_FLAG in ('I', 'B')
AND    types.lookup_type in ('ZX_OUTPUT_CLASSIFICATIONS',
                             'ZX_INPUT_CLASSIFICATIONS',
                             'ZX_WEB_EXP_TAX_CLASSIFICATIONS')
AND    not exists
       (select null
        from   fnd_lookup_types_tl sub
        where  sub.lookup_type = types.lookup_type
        and    sub.security_group_id = 0
        and    sub.view_application_id = 0
        and    sub.language = l.language_code);


/* For AP Tax codes and Groups */
BEGIN

FOR CURSOR_REC IN
(
SELECT
DISTINCT
NAME
FROM
AP_TAX_CODES_ALL
)

LOOP


INSERT INTO FND_LOOKUP_VALUES
(
 LOOKUP_TYPE            ,
 LANGUAGE               ,
 LOOKUP_CODE            ,
 MEANING                ,
 DESCRIPTION            ,
 ENABLED_FLAG           ,
 START_DATE_ACTIVE      ,
 END_DATE_ACTIVE        ,
 SOURCE_LANG            ,
 SECURITY_GROUP_ID      ,
 VIEW_APPLICATION_ID    ,
 TERRITORY_CODE         ,
 ATTRIBUTE_CATEGORY     ,
 ATTRIBUTE1             ,
 ATTRIBUTE2             ,
 ATTRIBUTE3             ,
 ATTRIBUTE4             ,
 ATTRIBUTE5             ,
 ATTRIBUTE6             ,
 ATTRIBUTE7             ,
 ATTRIBUTE8             ,
 ATTRIBUTE9             ,
 ATTRIBUTE10            ,
 ATTRIBUTE11            ,
 ATTRIBUTE12            ,
 ATTRIBUTE13            ,
 ATTRIBUTE14            ,
 ATTRIBUTE15            ,
 TAG                    ,
 CREATION_DATE          ,
 CREATED_BY             ,
 LAST_UPDATE_DATE       ,
 LAST_UPDATED_BY        ,
 LAST_UPDATE_LOGIN
)
SELECT
'ZX_INPUT_CLASSIFICATIONS',
 LANG.LANGUAGE_CODE                ,
 CODES.LOOKUP_CODE             ,
 CODES.MEANING                 ,
 CODES.DESCRIPTION             ,
 'Y'                     ,--ENABLED_FLAG
 codes.START_DATE_ACTIVE ,--START_DATE_ACTIVE
 NULL                    ,--END_DATE_ACTIVE
 userenv('LANG')         ,--SOURCE_LANG
 0                       ,--SECURITY_GROUP_ID
 0                       ,--VIEW_APPLICATION_ID
 NULL                    ,--TERRITORY_CODE
 NULL                    ,--ATTRIBUTE_CATEGORY
 NULL                    ,--ATTRIBUTE1
 NULL                    ,--ATTRIBUTE2
 NULL                    ,--ATTRIBUTE3
 NULL                    ,--ATTRIBUTE4
 NULL                    ,--ATTRIBUTE5
 NULL                    ,--ATTRIBUTE6
 NULL                    ,--ATTRIBUTE7
 NULL                    ,--ATTRIBUTE8
 NULL                    ,--ATTRIBUTE9
 NULL                    ,--ATTRIBUTE10
 NULL                    ,--ATTRIBUTE11
 NULL                    ,--ATTRIBUTE12
 NULL                    ,--ATTRIBUTE13
 NULL                    ,--ATTRIBUTE14
 NULL                    ,--ATTRIBUTE15
 NULL                    ,--TAG
 SYSDATE                 ,
 fnd_global.user_id      ,
 SYSDATE                 ,
 fnd_global.user_id      ,
 fnd_global.conc_login_id
FROM
(
SELECT
     codes.name LOOKUP_CODE,
     codes.name MEANING,
     codes.description DESCRIPTION,
    (select min(codes.start_date) from ap_tax_codes_all where codes.name = cursor_rec.name)  START_DATE_ACTIVE
FROM
          AP_TAX_CODES_ALL codes

WHERE

    codes.tax_type <> 'AWT'
AND codes.tax_id  = nvl(p_tax_id,codes.tax_id)
AND codes.name   = cursor_rec.name
AND ROWNUM = 1

)CODES,
FND_LANGUAGES LANG


WHERE
LANG.INSTALLED_FLAG IN ('I','B')
AND
NOT EXISTS
    (select NULL
    from FND_LOOKUP_VALUES
    where lookup_code = codes.LOOKUP_CODE
    and   lookup_type = 'ZX_INPUT_CLASSIFICATIONS'
    and   language    =LANG.LANGUAGE_CODE
    and   view_application_id = 0
    and   security_group_id   = 0);

END LOOP;

END;

-- Bug 4241633
/* For Tax Classification Codes for Web Expense */
BEGIN

FOR CURSOR_REC IN
(
SELECT
DISTINCT
NAME
FROM
AP_TAX_CODES_ALL
WHERE
WEB_ENABLED_FLAG = 'Y'
)

LOOP


INSERT INTO FND_LOOKUP_VALUES
(
 LOOKUP_TYPE            ,
 LANGUAGE               ,
 LOOKUP_CODE            ,
 MEANING                ,
 DESCRIPTION            ,
 ENABLED_FLAG           ,
 START_DATE_ACTIVE      ,
 END_DATE_ACTIVE        ,
 SOURCE_LANG            ,
 SECURITY_GROUP_ID      ,
 VIEW_APPLICATION_ID    ,
 TERRITORY_CODE         ,
 ATTRIBUTE_CATEGORY     ,
 ATTRIBUTE1             ,
 ATTRIBUTE2             ,
 ATTRIBUTE3             ,
 ATTRIBUTE4             ,
 ATTRIBUTE5             ,
 ATTRIBUTE6             ,
 ATTRIBUTE7             ,
 ATTRIBUTE8             ,
 ATTRIBUTE9             ,
 ATTRIBUTE10            ,
 ATTRIBUTE11            ,
 ATTRIBUTE12            ,
 ATTRIBUTE13            ,
 ATTRIBUTE14            ,
 ATTRIBUTE15            ,
 TAG                    ,
 CREATION_DATE          ,
 CREATED_BY             ,
 LAST_UPDATE_DATE       ,
 LAST_UPDATED_BY        ,
 LAST_UPDATE_LOGIN
)
SELECT
'ZX_WEB_EXP_TAX_CLASSIFICATIONS',
 LANG.LANGUAGE_CODE                ,
 CODES.LOOKUP_CODE             ,
 CODES.MEANING                 ,
 CODES.DESCRIPTION             ,
 'Y'                     ,--ENABLED_FLAG
 codes.START_DATE_ACTIVE ,--START_DATE_ACTIVE
 NULL                    ,--END_DATE_ACTIVE
 userenv('LANG')         ,--SOURCE_LANG
 0                       ,--SECURITY_GROUP_ID
 0                       ,--VIEW_APPLICATION_ID
 NULL                    ,--TERRITORY_CODE
 NULL                    ,--ATTRIBUTE_CATEGORY
 NULL                    ,--ATTRIBUTE1
 NULL                    ,--ATTRIBUTE2
 NULL                    ,--ATTRIBUTE3
 NULL                    ,--ATTRIBUTE4
 NULL                    ,--ATTRIBUTE5
 NULL                    ,--ATTRIBUTE6
 NULL                    ,--ATTRIBUTE7
 NULL                    ,--ATTRIBUTE8
 NULL                    ,--ATTRIBUTE9
 NULL                    ,--ATTRIBUTE10
 NULL                    ,--ATTRIBUTE11
 NULL                    ,--ATTRIBUTE12
 NULL                    ,--ATTRIBUTE13
 NULL                    ,--ATTRIBUTE14
 NULL                    ,--ATTRIBUTE15
 NULL                    ,--TAG
 SYSDATE                 ,
 fnd_global.user_id      ,
 SYSDATE                 ,
 fnd_global.user_id      ,
 fnd_global.conc_login_id
FROM
(
SELECT
     codes.name LOOKUP_CODE,
     codes.name MEANING,
     codes.description DESCRIPTION,
    (select min(codes.start_date) from ap_tax_codes_all where codes.name = cursor_rec.name)  START_DATE_ACTIVE
FROM
          AP_TAX_CODES_ALL codes

WHERE

    codes.tax_type <> 'AWT'
AND codes.tax_id  = nvl(p_tax_id,codes.tax_id)
AND codes.name   = cursor_rec.name
AND ROWNUM = 1

)CODES,
FND_LANGUAGES LANG


WHERE
LANG.INSTALLED_FLAG IN ('I','B')
AND
NOT EXISTS
    (select NULL
    from FND_LOOKUP_VALUES
    where lookup_code = codes.LOOKUP_CODE
    and   lookup_type = 'ZX_WEB_EXP_TAX_CLASSIFICATIONS'
    and   language    =LANG.LANGUAGE_CODE
    and   view_application_id = 0
    and   security_group_id   = 0);

END LOOP;

END;


--Bug  4096752
INSERT INTO ZX_ID_TCC_MAPPING_ALL
(
  TCC_MAPPING_ID                 ,
  ORG_ID                         ,
  TAX_CLASS                      ,
  TAX_RATE_CODE_ID               ,
  TAX_CLASSIFICATION_CODE        ,
  TAX_TYPE       ,
  EFFECTIVE_FROM     ,
  EFFECTIVE_TO       ,
  SOURCE                         ,
  CREATED_BY                     ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
  --Bug 4241667
  LEDGER_ID                     ,
  ACTIVE_FLAG
)

SELECT
   ZX_ID_TCC_MAPPING_ALL_S.nextval   , --tcc_mapping_id
  decode(l_multi_org_flag,'N',l_org_id,ORG_ID) , --org_id
  'INPUT'                        , --tax_class
  TAX_ID                         , --tax_id
  NAME                           , --tax_classification_code
  TAX_TYPE       , --tax_type
  START_DATE        , --effective_from
  INACTIVE_DATE       , --effective_to
  'AP'                           , --source
  fnd_global.user_id             , --created_by
  SYSDATE                        , --creation_date
  fnd_global.user_id             , --last_updated_by
  SYSDATE                        , --last_update_date
  fnd_global.user_id             , --last_update_login
  fnd_global.conc_request_id     , --request_id
  fnd_global.prog_appl_id        , --program_application_id
  fnd_global.conc_program_id     , --program_id
  fnd_global.conc_login_id       , --program_login_id
  codes.set_of_books_id          , --ledger_id
  codes.enabled_flag
FROM
       AP_TAX_CODES_ALL codes
WHERE
       codes.TAX_TYPE <> 'AWT'
AND    codes.TAX_ID = nvl(p_tax_id,codes.TAX_ID)
AND    NOT EXISTS
          (SELECT NULL  FROM ZX_ID_TCC_MAPPING_ALL
           WHERE TAX_RATE_CODE_ID  =  codes.TAX_ID
            AND  SOURCE = 'AP'
          );

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('Create_Tax_Classifications(-)');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug('EXCEPTION: Migrate_ap_tax_codes_setup ');
      arp_util_tax.debug(sqlerrm);
      arp_util_tax.debug('Create_Tax_Classifications(-)');
    END IF;

END Create_Tax_Classifications;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    migrate_normal_tax_codes                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine processes AP normal Tax codes and inserts appropriate    |
 |     data into the following zx base tables.                               |
 |               ZX_RATES_B                                                  |
 |               ZX_RATES_TL                                                 |
 |               ZX_ACCOUNTS                                                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        migrate_ap_tax_codes_setup                                         |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-Dec-03  Srinivas Lokam      Created.                               |
 |     30-Jan-04  Srinivas Lokam      Added INPUT parameters,AND conditions  |
 |                                    in SELECT statements for handling      |
 |                                    SYNC process.                          |
 |==========================================================================*/

PROCEDURE Migrate_Normal_Tax_Codes(p_tax_id IN NUMBER DEFAULT NULL) IS
BEGIN

/* Normal codes without offsets and with recovery rate,recovery rules
   UNION ALL
   Normal codes with offset and with recovery rates,recovery rules.
*/
    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('Migrate_Normal_Tax_Codes(+)');
    END IF;

--BugFix 3605729
IF ID_CLASH = 'Y' THEN
  IF L_MULTI_ORG_FLAG = 'Y' THEN

INSERT ALL
INTO zx_rates_b_tmp
(
  TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
  --DEFAULT_REC_TAX              ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  SOURCE_ID                      , --BugFix 3605729
  TAX_CLASS                      ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
  --BugFix 3426244
  ADJ_FOR_ADHOC_AMT_CODE         ,
  ALLOW_ADHOC_TAX_RATE_FLAG       ,
  OBJECT_VERSION_NUMBER
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
VALUES
(
  TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
  --DEFAULT_REC_TAX              ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  TAX_RATE_ID                    ,
  'INPUT'                        ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  zx_rates_b_s.nextval           ,--TAX_RATE_ID
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
  'TAX_RATE'                     ,
  'Y'                            , -- ALLOW_ADHOC_TAX_RATE_FLAG
  1
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
INTO zx_accounts
(
  TAX_ACCOUNT_ID                 ,
  TAX_ACCOUNT_ENTITY_ID          ,
  TAX_ACCOUNT_ENTITY_CODE        ,
  LEDGER_ID                      ,
  INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
  TAX_ACCOUNT_CCID               ,
  INTERIM_TAX_CCID               ,
  NON_REC_ACCOUNT_CCID           ,
  ADJ_CCID                       ,
  EDISC_CCID                     ,
  UNEDISC_CCID                   ,
  FINCHRG_CCID                   ,
  ADJ_NON_REC_TAX_CCID           ,
  EDISC_NON_REC_TAX_CCID         ,
  UNEDISC_NON_REC_TAX_CCID       ,
  FINCHRG_NON_REC_TAX_CCID       ,
  RECORD_TYPE_CODE               ,
  ATTRIBUTE1             ,
  ATTRIBUTE2             ,
  ATTRIBUTE3             ,
  ATTRIBUTE4             ,
  ATTRIBUTE5             ,
  ATTRIBUTE6             ,
  ATTRIBUTE7             ,
  ATTRIBUTE8             ,
  ATTRIBUTE9             ,
  ATTRIBUTE10            ,
  ATTRIBUTE11            ,
  ATTRIBUTE12            ,
  ATTRIBUTE13            ,
  ATTRIBUTE14            ,
  ATTRIBUTE15            ,
  ATTRIBUTE_CATEGORY,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
  OBJECT_VERSION_NUMBER
)
VALUES
(
        ZX_ACCOUNTS_S.nextval ,
        zx_rates_b_s.nextval  ,--TAX_RATE_ID
        'RATES'               ,
         LEDGER_ID            ,
         ORG_ID               ,
         TAX_ACCOUNT_CCID     ,
         NULL                 ,
         NON_REC_ACCOUNT_CCID ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         RECORD_TYPE_CODE     ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
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
      results.tax_code_id            TAX_RATE_ID,
      results.tax_code               TAX_RATE_CODE,
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
      'N'                            SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                 DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                 DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                       DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID, --Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ar_vat_tax_all_b   ar_codes,
    ap_tax_recvry_rules_all rec_rules,
    financials_system_params_all fsp,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = codes.tax_id
and  results.tax_class = 'INPUT'
and  codes.tax_id  = ar_codes.vat_tax_id
and  codes.enabled_flag = 'Y'
and  codes.offset_tax_code_id IS NULL
AND  codes.tax_recovery_rule_id  = rec_rules.rule_id(+)
AND  codes.tax_type not in ('AWT','OFFSET','TAX_GROUP')
AND  codes.org_id = fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'
--Added following conditions for Sync process
--AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
AND  not exists (select 1 from zx_rates_b
                 where  source_id =  nvl(p_tax_id,codes.tax_id)
                )
UNION ALL

SELECT
      results.tax_code_id            TAX_RATE_ID,
      results.tax_code               TAX_RATE_CODE,
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
     'N'                             SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                           DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                           DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
     offset.tax                      OFFSET_TAX    ,
     offset.tax_status_code          OFFSET_STATUS_CODE ,
     offset.tax_code                 OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID ,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ar_vat_tax_all_b   ar_codes,
    zx_update_criteria_results offset,
    financials_system_params_all fsp,
    ap_tax_recvry_rules_all rec_rules,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = codes.tax_id
AND  results.tax_class = 'INPUT'
AND  results.tax_class = offset.tax_class  -- Condition added for Bug#7115321
AND  codes.tax_id = ar_codes.vat_tax_id
AND  codes.enabled_flag = 'Y'
AND  codes.offset_tax_code_id       = offset.tax_code_id
AND  codes.tax_recovery_rule_id     = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id =  fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'
--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
AND  not exists (select 1 from zx_rates_b
                 where  source_id  =  nvl(p_tax_id,codes.tax_id)
                ) ;
  ELSE
INSERT ALL
INTO zx_rates_b_tmp
(
    TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
    --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  SOURCE_ID                      ,--BugFix 3605729
  TAX_CLASS                      ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
--BugFix 3426244
  ADJ_FOR_ADHOC_AMT_CODE             ,
  ALLOW_ADHOC_TAX_RATE_FLAG    ,
  OBJECT_VERSION_NUMBER
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
VALUES
(
  TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  TAX_RATE_ID                    ,
  'INPUT'                         ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  zx_rates_b_s.nextval           ,--TAX_RATE_ID
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
  'TAX_RATE'                     ,
  'Y'                            ,-- ALLOW_ADHOC_TAX_RATE_FLAG
  1
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
INTO zx_accounts
(
    TAX_ACCOUNT_ID                 ,
  TAX_ACCOUNT_ENTITY_ID          ,
  TAX_ACCOUNT_ENTITY_CODE        ,
  LEDGER_ID                      ,
  INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
  TAX_ACCOUNT_CCID               ,
  INTERIM_TAX_CCID               ,
  NON_REC_ACCOUNT_CCID           ,
  ADJ_CCID                       ,
  EDISC_CCID                     ,
  UNEDISC_CCID                   ,
  FINCHRG_CCID                   ,
  ADJ_NON_REC_TAX_CCID           ,
  EDISC_NON_REC_TAX_CCID         ,
  UNEDISC_NON_REC_TAX_CCID       ,
  FINCHRG_NON_REC_TAX_CCID       ,
  RECORD_TYPE_CODE               ,
  ATTRIBUTE1             ,
  ATTRIBUTE2             ,
  ATTRIBUTE3             ,
  ATTRIBUTE4             ,
  ATTRIBUTE5             ,
  ATTRIBUTE6             ,
  ATTRIBUTE7             ,
  ATTRIBUTE8             ,
  ATTRIBUTE9             ,
  ATTRIBUTE10            ,
  ATTRIBUTE11            ,
  ATTRIBUTE12            ,
  ATTRIBUTE13            ,
  ATTRIBUTE14            ,
  ATTRIBUTE15            ,
  ATTRIBUTE_CATEGORY,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID    ,
  OBJECT_VERSION_NUMBER
)
VALUES
(
        ZX_ACCOUNTS_S.nextval ,
        zx_rates_b_s.nextval  ,--TAX_RATE_ID
        'RATES'                ,
         LEDGER_ID            ,
         ORG_ID               ,
         TAX_ACCOUNT_CCID     ,
         NULL                 ,
         NON_REC_ACCOUNT_CCID ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         RECORD_TYPE_CODE     ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
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
      results.tax_code_id            TAX_RATE_ID,
      results.tax_code               TAX_RATE_CODE,
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
      'N'                            SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                 DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                 DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                       DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID, --Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ar_vat_tax_all_b   ar_codes,
    ap_tax_recvry_rules_all rec_rules,
    financials_system_params_all fsp,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = codes.tax_id
and  results.tax_class = 'INPUT'
and  codes.tax_id  = ar_codes.vat_tax_id
and  codes.enabled_flag = 'Y'
and  codes.offset_tax_code_id IS NULL
AND  codes.tax_recovery_rule_id  = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id = l_org_id
AND  codes.org_id = fsp.org_id
AND  codes.org_id  =ptp.party_id
AND  ptp.party_Type_code = 'OU'
--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
AND  not exists (select 1 from zx_rates_b
                 where  source_id =  nvl(p_tax_id,codes.tax_id)
                )
UNION ALL

SELECT
      results.tax_code_id            TAX_RATE_ID,
      results.tax_code               TAX_RATE_CODE,
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
     'N'                             SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                           DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                           DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
      offset.tax                     OFFSET_TAX    ,
      offset.tax_status_code         OFFSET_STATUS_CODE ,
      offset.tax_code                OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID ,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ar_vat_tax_all_b   ar_codes,
    zx_update_criteria_results offset,
    financials_system_params_all fsp,
    ap_tax_recvry_rules_all rec_rules,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = codes.tax_id
AND  results.tax_class = 'INPUT'
AND  results.tax_class = offset.tax_class  -- Condition added for Bug#7115321
AND  codes.tax_id = ar_codes.vat_tax_id
AND  codes.enabled_flag = 'Y'
AND  codes.offset_tax_code_id       = offset.tax_code_id
AND  codes.tax_recovery_rule_id     = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id  = l_org_id
AND  codes.org_id  = fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'
--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
AND  not exists (select 1 from zx_rates_b
                 where  source_id  =  nvl(p_tax_id,codes.tax_id)
                ) ;


 END IF;
END IF;

if l_multi_org_flag = 'Y'
then
INSERT ALL
INTO zx_rates_b_tmp
(
    TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
    TAX_CLASS                      , --Bug 3987672
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
  --BugFix 3426244
  ADJ_FOR_ADHOC_AMT_CODE         ,
  ALLOW_ADHOC_TAX_RATE_FLAG       ,
  OBJECT_VERSION_NUMBER           ,
  --Bug 4241667 : SOURCE_ID = TAX_RATE_ID for AP TAX CODES
  SOURCE_ID
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
VALUES
(
  TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  'INPUT'                        ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
  'TAX_RATE'                      ,
  'Y'        , --ALLOW_ADHOC_TAX_RATE_FLAG
  1                               ,
  --Bug 4241667 : SOURCE_ID = TAX_RATE_ID for AP TAX CODES
  TAX_RATE_ID
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
INTO zx_accounts
(
  TAX_ACCOUNT_ID                 ,
  TAX_ACCOUNT_ENTITY_ID          ,
  TAX_ACCOUNT_ENTITY_CODE        ,
  LEDGER_ID                      ,
  INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
  TAX_ACCOUNT_CCID               ,
  INTERIM_TAX_CCID               ,
  NON_REC_ACCOUNT_CCID           ,
  ADJ_CCID                       ,
  EDISC_CCID                     ,
  UNEDISC_CCID                   ,
  FINCHRG_CCID                   ,
  ADJ_NON_REC_TAX_CCID           ,
  EDISC_NON_REC_TAX_CCID         ,
  UNEDISC_NON_REC_TAX_CCID       ,
  FINCHRG_NON_REC_TAX_CCID       ,
  RECORD_TYPE_CODE               ,
  ATTRIBUTE1             ,
  ATTRIBUTE2             ,
  ATTRIBUTE3             ,
  ATTRIBUTE4             ,
  ATTRIBUTE5             ,
  ATTRIBUTE6             ,
  ATTRIBUTE7             ,
  ATTRIBUTE8             ,
  ATTRIBUTE9             ,
  ATTRIBUTE10            ,
  ATTRIBUTE11            ,
  ATTRIBUTE12            ,
  ATTRIBUTE13            ,
  ATTRIBUTE14            ,
  ATTRIBUTE15            ,
  ATTRIBUTE_CATEGORY,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID    ,
  OBJECT_VERSION_NUMBER
)
VALUES
(
        ZX_ACCOUNTS_S.nextval ,
        TAX_RATE_ID           ,
        'RATES'                ,
         LEDGER_ID            ,
         ORG_ID               ,
         TAX_ACCOUNT_CCID     ,
         NULL                 ,
         NON_REC_ACCOUNT_CCID ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         RECORD_TYPE_CODE     ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
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
      results.tax_code_id                 TAX_RATE_ID,
      results.tax_code               TAX_RATE_CODE,
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
      'N'                            SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                           DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                       DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ap_tax_recvry_rules_all rec_rules,
    financials_system_params_all fsp,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = codes.tax_id
AND  results.tax_class = 'INPUT'
AND  codes.offset_tax_code_id IS NULL
AND  codes.enabled_flag = 'Y'
AND  codes.tax_recovery_rule_id  = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id = fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'

--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
--BugFix 3605729 added nvl(source_id, in the following condition.
AND  not exists (select 1 from zx_rates_b
                 where  nvl(source_id,tax_rate_id) =  nvl(p_tax_id,codes.tax_id)
                )
UNION ALL

SELECT
      results.tax_code_id            TAX_RATE_ID,
      results.tax_code               TAX_RATE_CODE,
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
     'N'                             SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                           DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                           DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
      offset.tax                      OFFSET_TAX    ,
      offset.tax_status_code          OFFSET_STATUS_CODE ,
      offset.tax_code                OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196

FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    zx_update_criteria_results offset,
    financials_system_params_all fsp,
    ap_tax_recvry_rules_all rec_rules,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id            = codes.tax_id
AND  results.tax_class = 'INPUT'
AND  results.tax_class = offset.tax_class  -- Condition added for Bug#7115321
AND  codes.enabled_flag = 'Y'
AND  codes.offset_tax_code_id       = offset.tax_code_id
AND  codes.tax_recovery_rule_id     = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id = fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'

--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
--BugFix 3605729 added nvl(source_id, in the following condition.
AND  not exists (select 1 from zx_rates_b
                 where  nvl(source_id,tax_rate_id) =  nvl(p_tax_id,codes.tax_id)
                );
else

INSERT ALL
INTO zx_rates_b_tmp
(
    TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
    TAX_CLASS                      , --Bug 3987672
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
  --BugFix 3426244
  ADJ_FOR_ADHOC_AMT_CODE         ,
  ALLOW_ADHOC_TAX_RATE_FLAG       ,
  OBJECT_VERSION_NUMBER           ,
  --Bug 4241667 : SOURCE_ID = TAX_RATE_ID for AP TAX CODES
  SOURCE_ID
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
VALUES
(
  TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  'INPUT'                        ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
  'TAX_RATE'                      ,
  'Y'        , --ALLOW_ADHOC_TAX_RATE_FLAG
  1                               ,
  --Bug 4241667 : SOURCE_ID = TAX_RATE_ID for AP TAX CODES
  TAX_RATE_ID
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
INTO zx_accounts
(
    TAX_ACCOUNT_ID                 ,
  TAX_ACCOUNT_ENTITY_ID          ,
  TAX_ACCOUNT_ENTITY_CODE        ,
  LEDGER_ID                      ,
  INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
  TAX_ACCOUNT_CCID               ,
  INTERIM_TAX_CCID               ,
  NON_REC_ACCOUNT_CCID           ,
  ADJ_CCID                       ,
  EDISC_CCID                     ,
  UNEDISC_CCID                   ,
  FINCHRG_CCID                   ,
  ADJ_NON_REC_TAX_CCID           ,
  EDISC_NON_REC_TAX_CCID         ,
  UNEDISC_NON_REC_TAX_CCID       ,
  FINCHRG_NON_REC_TAX_CCID       ,
  RECORD_TYPE_CODE               ,
  ATTRIBUTE1             ,
  ATTRIBUTE2             ,
  ATTRIBUTE3             ,
  ATTRIBUTE4             ,
  ATTRIBUTE5             ,
  ATTRIBUTE6             ,
  ATTRIBUTE7             ,
  ATTRIBUTE8             ,
  ATTRIBUTE9             ,
  ATTRIBUTE10            ,
  ATTRIBUTE11            ,
  ATTRIBUTE12            ,
  ATTRIBUTE13            ,
  ATTRIBUTE14            ,
  ATTRIBUTE15            ,
  ATTRIBUTE_CATEGORY,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID    ,
  OBJECT_VERSION_NUMBER
)
VALUES
(
        ZX_ACCOUNTS_S.nextval ,
        TAX_RATE_ID           ,
        'RATES'                ,
         LEDGER_ID            ,
         ORG_ID               ,
         TAX_ACCOUNT_CCID     ,
         NULL                 ,
         NON_REC_ACCOUNT_CCID ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         RECORD_TYPE_CODE     ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
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
      results.tax_code_id                 TAX_RATE_ID,
      results.tax_code               TAX_RATE_CODE,
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
      'N'                            SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                           DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                       DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ap_tax_recvry_rules_all rec_rules,
    financials_system_params_all fsp,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = codes.tax_id
AND  results.tax_class = 'INPUT'
AND  codes.offset_tax_code_id IS NULL
AND  codes.enabled_flag = 'Y'
AND  codes.tax_recovery_rule_id  = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id = l_org_id
AND  codes.org_id = fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'

--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
--BugFix 3605729 added nvl(source_id, in the following condition.
AND  not exists (select 1 from zx_rates_b
                 where  nvl(source_id,tax_rate_id) =  nvl(p_tax_id,codes.tax_id)
                )
UNION ALL

SELECT
      results.tax_code_id            TAX_RATE_ID,
      results.tax_code               TAX_RATE_CODE,
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
     'N'                             SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                           DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                           DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
      offset.tax                    OFFSET_TAX    ,
      offset.tax_status_code        OFFSET_STATUS_CODE ,
      offset.tax_code               OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196

FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    zx_update_criteria_results offset,
    financials_system_params_all fsp,
    ap_tax_recvry_rules_all rec_rules,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id            = codes.tax_id
AND  results.tax_class = 'INPUT'
AND  results.tax_class = offset.tax_class  -- Condition added for Bug#7115321
AND  codes.enabled_flag = 'Y'
AND  codes.offset_tax_code_id       = offset.tax_code_id
AND  codes.tax_recovery_rule_id     = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id = l_org_id
AND  codes.org_id = fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'

--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
--BugFix 3605729 added nvl(source_id, in the following condition.
AND  not exists (select 1 from zx_rates_b
                 where  nvl(source_id,tax_rate_id) =  nvl(p_tax_id,codes.tax_id)
                );


end if;


INSERT INTO  ZX_RATES_TL
(
    TAX_RATE_ID,
    TAX_RATE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
    description
)
SELECT
    TAX_RATE_ID,
    CASE WHEN TAX_RATE_CODE = UPPER(TAX_RATE_CODE)
    THEN    Initcap(TAX_RATE_CODE)
    ELSE
             TAX_RATE_CODE
    END,
    fnd_global.user_id             ,
    SYSDATE                        ,
    fnd_global.user_id             ,
    SYSDATE                        ,
    fnd_global.conc_login_id       ,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    avtb.description
FROM FND_LANGUAGES L,
     ZX_RATES_B RATES,
     ar_vat_tax_all_b   avtb
WHERE
     L.INSTALLED_FLAG in ('I', 'B')
AND  avtb.vat_tax_id = RATES.tax_rate_id
AND  RATES.RECORD_TYPE_CODE = 'MIGRATED'
AND  not exists
    (select NULL
    from ZX_RATES_TL T
    where T.TAX_RATE_ID = RATES.TAX_RATE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('Migrate_Normal_Tax_Codes(-)');
    END IF;


EXCEPTION
         WHEN OTHERS THEN
            IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Migrate_normal_tax_codes ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('Migrate_Normal_Tax_Codes(-)');
            END IF;
            --app_exception.raise_exception;


END migrate_normal_tax_codes;



/*===========================================================================+
 | PROCEDURE                                                                 |
 |    migrate_assign_offset_codes                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine processes assigned OFFSET Tax codes and inserts          |
 |     appropriate data into the following zx base tables.                   |
 |               ZX_RATES_B                                                  |
 |               ZX_RATES_TL                                                 |
 |               ZX_ACCOUNTS                                                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        migrate_ap_tax_codes_setup                                         |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-Dec-03  Srinivas Lokam      Created.                               |
 |     30-Jan-04  Srinivas Lokam      Added INPUT parameters,AND conditions  |
 |                                    in SELECT statements for handling      |
 |                                    SYNC process.                          |
 |                                                                           |
 |==========================================================================*/



PROCEDURE migrate_assign_offset_codes(p_tax_id IN NUMBER DEFAULT NULL) IS
BEGIN

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('Migrate_Assign_Offset_Codes(+)');
    END IF;

--BugFix 3605729
IF ID_CLASH = 'Y' THEN
 IF L_MULTI_ORG_FLAG = 'Y' THEN
INSERT ALL
INTO zx_rates_b_tmp
(
        TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  SOURCE_ID                      ,--BugFix 3605729
  TAX_CLASS                      ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
      --BugFix 3426244
        ADJ_FOR_ADHOC_AMT_CODE         ,
        ALLOW_ADHOC_TAX_RATE_FLAG  ,
  OBJECT_VERSION_NUMBER
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
VALUES
(
    TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  TAX_RATE_ID                    ,
  'INPUT'                        ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  zx_rates_b_s.nextval           ,--TAX_RATE_ID
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
  'TAX_RATE'                      ,
  'Y'        ,-- ALLOW_ADHOC_TAX_RATE_FLAG
  1
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
INTO zx_accounts
(
  TAX_ACCOUNT_ID                 ,
  TAX_ACCOUNT_ENTITY_ID          ,
  TAX_ACCOUNT_ENTITY_CODE        ,
  LEDGER_ID                      ,
  INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
  TAX_ACCOUNT_CCID               ,
  INTERIM_TAX_CCID               ,
  NON_REC_ACCOUNT_CCID           ,
  ADJ_CCID                       ,
  EDISC_CCID                     ,
  UNEDISC_CCID                   ,
  FINCHRG_CCID                   ,
  ADJ_NON_REC_TAX_CCID           ,
  EDISC_NON_REC_TAX_CCID         ,
  UNEDISC_NON_REC_TAX_CCID       ,
  FINCHRG_NON_REC_TAX_CCID       ,
  RECORD_TYPE_CODE               ,
  ATTRIBUTE1             ,
  ATTRIBUTE2             ,
  ATTRIBUTE3             ,
  ATTRIBUTE4             ,
  ATTRIBUTE5             ,
  ATTRIBUTE6             ,
  ATTRIBUTE7             ,
  ATTRIBUTE8             ,
  ATTRIBUTE9             ,
  ATTRIBUTE10            ,
  ATTRIBUTE11            ,
  ATTRIBUTE12            ,
  ATTRIBUTE13            ,
  ATTRIBUTE14            ,
  ATTRIBUTE15            ,
  ATTRIBUTE_CATEGORY,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID    ,
  OBJECT_VERSION_NUMBER
)
VALUES
(
   ZX_ACCOUNTS_S.NEXTVAL,
   zx_rates_b_s.nextval ,--TAX_RATE_ID
   'RATES'              ,
   LEDGER_ID            ,
   ORG_ID               ,
   TAX_ACCOUNT_CCID     ,
   NULL                 ,
   NON_REC_ACCOUNT_CCID ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   RECORD_TYPE_CODE     ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
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
      DISTINCT
      offset.tax_id                  TAX_RATE_ID,  --Change 1
      offset.name                    TAX_RATE_CODE,--Change 2
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      offset.start_date              EFFECTIVE_FROM,
      offset.inactive_date           EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE , --Review1 changes
      results.tax                    TAX,  --Review1 changes
      results.tax_status_code        TAX_STATUS_CODE,  --Review1 changes
     'N'                             SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      offset.tax_rate                PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      NULL                           RECOVERY_TYPE_CODE, --Change 3
      offset.enabled_flag            ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                       DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(offset.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                       DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
            'Y',
            'STANDARD-'||nvl(offset.tax_recovery_rate,0),
             NULL)                   DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX    ,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      NULL                           RECOVERY_RULE_CODE    ,
      'IMMEDIATE'                    DEF_REC_SETTLEMENT_OPTION_CODE,
      offset.vat_transaction_type    VAT_TRANSACTION_TYPE_CODE ,
                                   --Reveiw1 changes
     'MIGRATED'                      RECORD_TYPE_CODE,
      offset.ATTRIBUTE1               ATTRIBUTE1,
      offset.ATTRIBUTE2               ATTRIBUTE2,
      offset.ATTRIBUTE3               ATTRIBUTE3,
      offset.ATTRIBUTE4               ATTRIBUTE4,
      offset.ATTRIBUTE5               ATTRIBUTE5,
      offset.ATTRIBUTE6               ATTRIBUTE6,
      offset.ATTRIBUTE7               ATTRIBUTE7,
      offset.ATTRIBUTE8               ATTRIBUTE8,
      offset.ATTRIBUTE9               ATTRIBUTE9,
      offset.ATTRIBUTE10              ATTRIBUTE10,
      offset.ATTRIBUTE11              ATTRIBUTE11,
      offset.ATTRIBUTE12              ATTRIBUTE12,
      offset.ATTRIBUTE13              ATTRIBUTE13,
      offset.ATTRIBUTE14              ATTRIBUTE14,
      offset.ATTRIBUTE15              ATTRIBUTE15,
      offset.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      offset.set_of_books_id          LEDGER_ID,
      results.org_id                  ORG_ID,
      offset.tax_code_combination_id  TAX_ACCOUNT_CCID, --Review1 changes ----Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',offset.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID , --Review1 changes
      offset.DESCRIPTION         DESCRIPTION -- Bug 4705196

FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ar_vat_tax_all_b  ar_codes,
    ap_tax_codes_all offset,
    financials_system_params_all fsp,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id     = codes.offset_tax_code_id
AND  codes.offset_tax_code_id = offset.tax_id
AND  offset.tax_id            = ar_codes.vat_tax_id
AND  results.tax_class       = 'INPUT'
AND  codes.org_id = fsp.org_id
AND  codes.org_id  =ptp.party_id
AND  ptp.party_type_code      = 'OU'

--Added following conditions for Sync process
AND  offset.tax_id  = nvl(p_tax_id,offset.tax_id)
--Added following conditions for Re-runnability check
AND  not exists (select 1 from zx_rates_b
                 where  source_id =  nvl(p_tax_id,offset.tax_id)
                ) ;
 ELSE
 INSERT ALL
INTO zx_rates_b_tmp
(
        TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  SOURCE_ID                      ,--BugFix 3605729
  TAX_CLASS                      ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
--BugFix 3426244
  ADJ_FOR_ADHOC_AMT_CODE         ,
  ALLOW_ADHOC_TAX_RATE_FLAG  ,
  OBJECT_VERSION_NUMBER
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
VALUES
(
  TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  TAX_RATE_ID                    ,
  'INPUT'                        ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  zx_rates_b_s.nextval           ,--TAX_RATE_ID
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
  'TAX_RATE'                      ,
  'Y'        ,-- ALLOW_ADHOC_TAX_RATE_FLAG
  1
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
INTO zx_accounts
(
        TAX_ACCOUNT_ID                 ,
  TAX_ACCOUNT_ENTITY_ID          ,
  TAX_ACCOUNT_ENTITY_CODE        ,
  LEDGER_ID                      ,
  INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
  TAX_ACCOUNT_CCID               ,
  INTERIM_TAX_CCID               ,
  NON_REC_ACCOUNT_CCID           ,
  ADJ_CCID                       ,
  EDISC_CCID                     ,
  UNEDISC_CCID                   ,
  FINCHRG_CCID                   ,
  ADJ_NON_REC_TAX_CCID           ,
  EDISC_NON_REC_TAX_CCID         ,
  UNEDISC_NON_REC_TAX_CCID       ,
  FINCHRG_NON_REC_TAX_CCID       ,
  RECORD_TYPE_CODE               ,
  ATTRIBUTE1             ,
  ATTRIBUTE2             ,
  ATTRIBUTE3             ,
  ATTRIBUTE4             ,
  ATTRIBUTE5             ,
  ATTRIBUTE6             ,
  ATTRIBUTE7             ,
  ATTRIBUTE8             ,
  ATTRIBUTE9             ,
  ATTRIBUTE10            ,
  ATTRIBUTE11            ,
  ATTRIBUTE12            ,
  ATTRIBUTE13            ,
  ATTRIBUTE14            ,
  ATTRIBUTE15            ,
  ATTRIBUTE_CATEGORY,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID    ,
  OBJECT_VERSION_NUMBER
)
VALUES
(
        ZX_ACCOUNTS_S.NEXTVAL ,
        zx_rates_b_s.nextval  ,--TAX_RATE_ID
        'RATES'                ,
         LEDGER_ID            ,
         ORG_ID               ,
         TAX_ACCOUNT_CCID     ,
         NULL                 ,
         NON_REC_ACCOUNT_CCID ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         RECORD_TYPE_CODE     ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
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
      DISTINCT
      offset.tax_id                  TAX_RATE_ID,  --Change 1
      offset.name                    TAX_RATE_CODE,--Change 2
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      offset.start_date              EFFECTIVE_FROM,
      offset.inactive_date           EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE , --Review1 changes
      results.tax                    TAX,  --Review1 changes
      results.tax_status_code        TAX_STATUS_CODE,  --Review1 changes
     'N'                             SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      offset.tax_rate                PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      NULL                           RECOVERY_TYPE_CODE, --Change 3
      offset.enabled_flag            ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                       DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(offset.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                       DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
            'Y',
            'STANDARD-'||nvl(offset.tax_recovery_rate,0),
             NULL)                   DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX    ,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      NULL                           RECOVERY_RULE_CODE    ,
      'IMMEDIATE'                    DEF_REC_SETTLEMENT_OPTION_CODE,
      offset.vat_transaction_type    VAT_TRANSACTION_TYPE_CODE ,
                                   --Reveiw1 changes
     'MIGRATED'                      RECORD_TYPE_CODE,
      offset.ATTRIBUTE1               ATTRIBUTE1,
      offset.ATTRIBUTE2               ATTRIBUTE2,
      offset.ATTRIBUTE3               ATTRIBUTE3,
      offset.ATTRIBUTE4               ATTRIBUTE4,
      offset.ATTRIBUTE5               ATTRIBUTE5,
      offset.ATTRIBUTE6               ATTRIBUTE6,
      offset.ATTRIBUTE7               ATTRIBUTE7,
      offset.ATTRIBUTE8               ATTRIBUTE8,
      offset.ATTRIBUTE9               ATTRIBUTE9,
      offset.ATTRIBUTE10              ATTRIBUTE10,
      offset.ATTRIBUTE11              ATTRIBUTE11,
      offset.ATTRIBUTE12              ATTRIBUTE12,
      offset.ATTRIBUTE13              ATTRIBUTE13,
      offset.ATTRIBUTE14              ATTRIBUTE14,
      offset.ATTRIBUTE15              ATTRIBUTE15,
      offset.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      offset.set_of_books_id          LEDGER_ID,
      results.org_id                  ORG_ID,
      offset.tax_code_combination_id  TAX_ACCOUNT_CCID, --Review1 changes ----Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',offset.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID , --Review1 changes
      offset.DESCRIPTION         DESCRIPTION -- Bug 4705196

FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ar_vat_tax_all_b  ar_codes,
    ap_tax_codes_all offset,
    financials_system_params_all fsp,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id     = codes.offset_tax_code_id
AND  codes.offset_tax_code_id = offset.tax_id
AND  offset.tax_id            = ar_codes.vat_tax_id
AND  results.tax_class       = 'INPUT'
AND  codes.org_id = l_org_id
AND  codes.org_id = fsp.org_id
AND  codes.org_id  =ptp.party_id
AND  ptp.party_type_code      = 'OU'

--Added following conditions for Sync process
AND  offset.tax_id  = nvl(p_tax_id,offset.tax_id)
--Added following conditions for Re-runnability check
AND  not exists (select 1 from zx_rates_b
                 where  source_id =  nvl(p_tax_id,offset.tax_id)
                ) ;

 END IF;
END IF;

IF L_MULTI_ORG_FLAG = 'Y'
THEN

INSERT ALL
INTO zx_rates_b_tmp
(
        TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
        TAX_CLASS                      , -- Bug 3987672
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
--BugFix 3426244
  ADJ_FOR_ADHOC_AMT_CODE         ,
  ALLOW_ADHOC_TAX_RATE_FLAG  ,
  OBJECT_VERSION_NUMBER           ,
-- Bug 4241667 : SOURCE_ID = TAX_RATE_ID for AP TAX CODES
SOURCE_ID
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
VALUES
(
  TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
        'INPUT'                        ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
  'TAX_RATE'                      ,
  'Y'        , -- ALLOW_ADHOC_TAX_RATE_FLAG
  1                               ,
-- Bug 4241667 : SOURCE_ID = TAX_RATE_ID for AP TAX CODES
  TAX_RATE_ID
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
INTO zx_accounts
(
        TAX_ACCOUNT_ID                 ,
  TAX_ACCOUNT_ENTITY_ID          ,
  TAX_ACCOUNT_ENTITY_CODE        ,
  LEDGER_ID                      ,
  INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
  TAX_ACCOUNT_CCID               ,
  INTERIM_TAX_CCID               ,
  NON_REC_ACCOUNT_CCID           ,
  ADJ_CCID                       ,
  EDISC_CCID                     ,
  UNEDISC_CCID                   ,
  FINCHRG_CCID                   ,
  ADJ_NON_REC_TAX_CCID           ,
  EDISC_NON_REC_TAX_CCID         ,
  UNEDISC_NON_REC_TAX_CCID       ,
  FINCHRG_NON_REC_TAX_CCID       ,
  RECORD_TYPE_CODE               ,
  ATTRIBUTE1             ,
  ATTRIBUTE2             ,
  ATTRIBUTE3             ,
  ATTRIBUTE4             ,
  ATTRIBUTE5             ,
  ATTRIBUTE6             ,
  ATTRIBUTE7             ,
  ATTRIBUTE8             ,
  ATTRIBUTE9             ,
  ATTRIBUTE10            ,
  ATTRIBUTE11            ,
  ATTRIBUTE12            ,
  ATTRIBUTE13            ,
  ATTRIBUTE14            ,
  ATTRIBUTE15            ,
  ATTRIBUTE_CATEGORY,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID    ,
  OBJECT_VERSION_NUMBER
)
VALUES
(
        ZX_ACCOUNTS_S.NEXTVAL ,
        TAX_RATE_ID           ,
        'RATES'                ,
         LEDGER_ID            ,
         ORG_ID               ,
         TAX_ACCOUNT_CCID     ,
         NULL                 ,
         NON_REC_ACCOUNT_CCID ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         RECORD_TYPE_CODE     ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
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
      DISTINCT
      offset.tax_id                  TAX_RATE_ID, --Change 1
      offset.name                    TAX_RATE_CODE,--Change 2
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      offset.start_date              EFFECTIVE_FROM,
      offset.inactive_date           EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
     'N'                             SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      offset.tax_rate                PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      NULL                           RECOVERY_TYPE_CODE,
      offset.enabled_flag            ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                       DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(offset.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                       DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
            'Y',
            'STANDARD-'||nvl(offset.tax_recovery_rate,0),
             NULL)                   DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX    ,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      NULL                           RECOVERY_RULE_CODE    ,
      'IMMEDIATE'                    DEF_REC_SETTLEMENT_OPTION_CODE,
      offset.vat_transaction_type    VAT_TRANSACTION_TYPE_CODE ,
                                   --Reveiw1 changes
     'MIGRATED'                      RECORD_TYPE_CODE,
      offset.ATTRIBUTE1               ATTRIBUTE1,
      offset.ATTRIBUTE2               ATTRIBUTE2,
      offset.ATTRIBUTE3               ATTRIBUTE3,
      offset.ATTRIBUTE4               ATTRIBUTE4,
      offset.ATTRIBUTE5               ATTRIBUTE5,
      offset.ATTRIBUTE6               ATTRIBUTE6,
      offset.ATTRIBUTE7               ATTRIBUTE7,
      offset.ATTRIBUTE8               ATTRIBUTE8,
      offset.ATTRIBUTE9               ATTRIBUTE9,
      offset.ATTRIBUTE10              ATTRIBUTE10,
      offset.ATTRIBUTE11              ATTRIBUTE11,
      offset.ATTRIBUTE12              ATTRIBUTE12,
      offset.ATTRIBUTE13              ATTRIBUTE13,
      offset.ATTRIBUTE14              ATTRIBUTE14,
      offset.ATTRIBUTE15              ATTRIBUTE15,
      offset.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      offset.set_of_books_id          LEDGER_ID,
      results.org_id                  ORG_ID,
      offset.tax_code_combination_id  TAX_ACCOUNT_CCID, --Review1 changes ----Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',offset.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID ,--Review1 changes
      offset.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ap_tax_codes_all offset,
    financials_system_params_all fsp,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id      = codes.offset_tax_code_id
AND  results.tax_class = 'INPUT'
AND  codes.offset_tax_code_id = offset.tax_id
AND  codes.org_id = fsp.org_id
AND  codes.org_id = ptp.party_id
AND  ptp.party_type_code      = 'OU'

--Added following conditions for Sync process
AND  offset.tax_id  = nvl(p_tax_id,offset.tax_id)
--BugFix 3605729 added nvl(source_id, in the following condition.
AND  not exists (select 1 from zx_rates_b
                 where  nvl(source_id,tax_rate_id) =  nvl(p_tax_id,offset.tax_id)
                )
;
ELSE
INSERT ALL
INTO zx_rates_b_tmp
(
        TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
        TAX_CLASS                      , -- Bug 3987672
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
--BugFix 3426244
  ADJ_FOR_ADHOC_AMT_CODE         ,
  ALLOW_ADHOC_TAX_RATE_FLAG  ,
  OBJECT_VERSION_NUMBER           ,
-- Bug 4241667 : SOURCE_ID = TAX_RATE_ID for AP TAX CODES
  SOURCE_ID
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
VALUES
(
  TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  'INPUT'                        ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
  'TAX_RATE'                      ,
  'Y'        , -- ALLOW_ADHOC_TAX_RATE_FLAG
  1                               ,
-- Bug 4241667 : SOURCE_ID = TAX_RATE_ID for AP TAX CODES
  TAX_RATE_ID
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
INTO zx_accounts
(
  TAX_ACCOUNT_ID                 ,
  TAX_ACCOUNT_ENTITY_ID          ,
  TAX_ACCOUNT_ENTITY_CODE        ,
  LEDGER_ID                      ,
  INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
  TAX_ACCOUNT_CCID               ,
  INTERIM_TAX_CCID               ,
  NON_REC_ACCOUNT_CCID           ,
  ADJ_CCID                       ,
  EDISC_CCID                     ,
  UNEDISC_CCID                   ,
  FINCHRG_CCID                   ,
  ADJ_NON_REC_TAX_CCID           ,
  EDISC_NON_REC_TAX_CCID         ,
  UNEDISC_NON_REC_TAX_CCID       ,
  FINCHRG_NON_REC_TAX_CCID       ,
  RECORD_TYPE_CODE               ,
  ATTRIBUTE1             ,
  ATTRIBUTE2             ,
  ATTRIBUTE3             ,
  ATTRIBUTE4             ,
  ATTRIBUTE5             ,
  ATTRIBUTE6             ,
  ATTRIBUTE7             ,
  ATTRIBUTE8             ,
  ATTRIBUTE9             ,
  ATTRIBUTE10            ,
  ATTRIBUTE11            ,
  ATTRIBUTE12            ,
  ATTRIBUTE13            ,
  ATTRIBUTE14            ,
  ATTRIBUTE15            ,
  ATTRIBUTE_CATEGORY,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID    ,
  OBJECT_VERSION_NUMBER
)
VALUES
(
   ZX_ACCOUNTS_S.NEXTVAL ,
   TAX_RATE_ID           ,
   'RATES'               ,
   LEDGER_ID            ,
   ORG_ID               ,
   TAX_ACCOUNT_CCID     ,
   NULL                 ,
   NON_REC_ACCOUNT_CCID ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   RECORD_TYPE_CODE     ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
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
      DISTINCT
      offset.tax_id                  TAX_RATE_ID, --Change 1
      offset.name                    TAX_RATE_CODE,--Change 2
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      offset.start_date              EFFECTIVE_FROM,
      offset.inactive_date           EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
     'N'                             SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      offset.tax_rate                PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      NULL                           RECOVERY_TYPE_CODE,
      offset.enabled_flag            ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                       DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(offset.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                       DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
            'Y',
            'STANDARD-'||nvl(offset.tax_recovery_rate,0),
             NULL)                   DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX    ,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      NULL                           RECOVERY_RULE_CODE    ,
      'IMMEDIATE'                    DEF_REC_SETTLEMENT_OPTION_CODE,
      offset.vat_transaction_type    VAT_TRANSACTION_TYPE_CODE ,
                                   --Reveiw1 changes
     'MIGRATED'                      RECORD_TYPE_CODE,
      offset.ATTRIBUTE1               ATTRIBUTE1,
      offset.ATTRIBUTE2               ATTRIBUTE2,
      offset.ATTRIBUTE3               ATTRIBUTE3,
      offset.ATTRIBUTE4               ATTRIBUTE4,
      offset.ATTRIBUTE5               ATTRIBUTE5,
      offset.ATTRIBUTE6               ATTRIBUTE6,
      offset.ATTRIBUTE7               ATTRIBUTE7,
      offset.ATTRIBUTE8               ATTRIBUTE8,
      offset.ATTRIBUTE9               ATTRIBUTE9,
      offset.ATTRIBUTE10              ATTRIBUTE10,
      offset.ATTRIBUTE11              ATTRIBUTE11,
      offset.ATTRIBUTE12              ATTRIBUTE12,
      offset.ATTRIBUTE13              ATTRIBUTE13,
      offset.ATTRIBUTE14              ATTRIBUTE14,
      offset.ATTRIBUTE15              ATTRIBUTE15,
      offset.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      offset.set_of_books_id          LEDGER_ID,
      results.org_id                  ORG_ID,
      offset.tax_code_combination_id  TAX_ACCOUNT_CCID, --Review1 changes ----Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',offset.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID ,--Review1 changes
      offset.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ap_tax_codes_all offset,
    financials_system_params_all fsp,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id      = codes.offset_tax_code_id
AND  results.tax_class = 'INPUT'
AND  codes.offset_tax_code_id = offset.tax_id
AND  codes.org_id = l_org_id
AND  codes.org_id = fsp.org_id
AND  codes.org_id = ptp.party_id
AND  ptp.party_type_code      = 'OU'

--Added following conditions for Sync process
AND  offset.tax_id  = nvl(p_tax_id,offset.tax_id)
--BugFix 3605729 added nvl(source_id, in the following condition.
AND  not exists (select 1 from zx_rates_b
                 where  nvl(source_id,tax_rate_id) =  nvl(p_tax_id,offset.tax_id)
                )
;


END IF;


INSERT INTO  ZX_RATES_TL
(
    TAX_RATE_ID,
    TAX_RATE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
  description
)
SELECT
    TAX_RATE_ID,
    CASE WHEN TAX_RATE_CODE = UPPER(TAX_RATE_CODE)
         THEN Initcap(TAX_RATE_CODE)
         ELSE TAX_RATE_CODE
    END                           ,
    fnd_global.user_id             ,
    SYSDATE                        ,
    fnd_global.user_id             ,
    SYSDATE                        ,
    fnd_global.conc_login_id       ,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    avtb.description
FROM FND_LANGUAGES L,
     ZX_RATES_B RATES,
     ar_vat_tax_all_b   avtb
WHERE
     L.INSTALLED_FLAG in ('I', 'B')
AND  avtb.vat_tax_id = RATES.tax_rate_id
AND  RATES.RECORD_TYPE_CODE = 'MIGRATED'
AND  not exists
    (select NULL
    from ZX_RATES_TL T
    where T.TAX_RATE_ID = RATES.TAX_RATE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('Migrate_Assign_Offset_Codes(-)');
    END IF;


EXCEPTION
         WHEN OTHERS THEN
            IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Migrate_assign_offset_codes ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('Migrate_Assign_Offset_Codes(-)');
            END IF;
            --app_exception.raise_exception;

END migrate_assign_offset_codes;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    migrate_unassign_offset_codes                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine processes unassigned OFFSET Tax codes and inserts        |
 |     appropriate data into the following zx base tables.                   |
 |               ZX_RATES_B                                                  |
 |               ZX_RATES_TL                                                 |
 |               ZX_ACCOUNTS                                                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        migrate_ap_tax_codes_setup                                         |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-Dec-03  Srinivas Lokam      Created.                               |
 |     30-Jan-04  Srinivas Lokam      Added INPUT parameters,AND conditions  |
 |                                    in SELECT statements for handling      |
 |                                    SYNC process.                          |
 |                                                                           |
 |==========================================================================*/


PROCEDURE migrate_unassign_offset_codes(p_tax_id IN NUMBER DEFAULT NULL) IS
BEGIN

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('Migrate_UnAssign_Offset_Codes(+)');
    END IF;

--BugFix 3605729
IF ID_CLASH = 'Y'  THEN
 IF L_MULTI_ORG_FLAG = 'Y' THEN
INSERT ALL
INTO zx_rates_b_tmp
(
        TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  SOURCE_ID                      ,--BugFix 3605729
  TAX_CLASS                      ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
--BugFix 3426244
  ADJ_FOR_ADHOC_AMT_CODE         ,
  ALLOW_ADHOC_TAX_RATE_FLAG  ,
  OBJECT_VERSION_NUMBER
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
VALUES
(
        TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  TAX_RATE_ID                    ,
  'INPUT'                        ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  zx_rates_b_s.nextval           ,--TAX_RATE_ID
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
  'TAX_RATE'                      ,
  'Y'        ,-- ALLOW_ADHOC_TAX_RATE_FLAG
  1
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
INTO zx_accounts
(
  TAX_ACCOUNT_ID                 ,
  TAX_ACCOUNT_ENTITY_ID          ,
  TAX_ACCOUNT_ENTITY_CODE        ,
  LEDGER_ID                      ,
  INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
  TAX_ACCOUNT_CCID               ,
  INTERIM_TAX_CCID               ,
  NON_REC_ACCOUNT_CCID           ,
  ADJ_CCID                       ,
  EDISC_CCID                     ,
  UNEDISC_CCID                   ,
  FINCHRG_CCID                   ,
  ADJ_NON_REC_TAX_CCID           ,
  EDISC_NON_REC_TAX_CCID         ,
  UNEDISC_NON_REC_TAX_CCID       ,
  FINCHRG_NON_REC_TAX_CCID       ,
  RECORD_TYPE_CODE               ,
  ATTRIBUTE1             ,
  ATTRIBUTE2             ,
  ATTRIBUTE3             ,
  ATTRIBUTE4             ,
  ATTRIBUTE5             ,
  ATTRIBUTE6             ,
  ATTRIBUTE7             ,
  ATTRIBUTE8             ,
  ATTRIBUTE9             ,
  ATTRIBUTE10            ,
  ATTRIBUTE11            ,
  ATTRIBUTE12            ,
  ATTRIBUTE13            ,
  ATTRIBUTE14            ,
  ATTRIBUTE15            ,
  ATTRIBUTE_CATEGORY,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID    ,
  OBJECT_VERSION_NUMBER
)
VALUES
(
   ZX_ACCOUNTS_S.NEXTVAL ,
   zx_rates_b_s.nextval  ,--TAX_RATE_ID
   'RATES'                ,
   LEDGER_ID            ,
   ORG_ID               ,
   TAX_ACCOUNT_CCID     ,
   NULL                 ,
   NON_REC_ACCOUNT_CCID ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   RECORD_TYPE_CODE     ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
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
      results.tax_code_id            TAX_RATE_ID,
      results.tax_code               TAX_RATE_CODE,
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      offset.start_date              EFFECTIVE_FROM,
      offset.inactive_date           EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
      'N'                            SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      offset.tax_rate                PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      offset.enabled_flag            ACTIVE_FLAG,
      'N'                            DEFAULT_RATE_FLAG          ,
      NULL                        DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                        DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(offset.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                           DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
            'Y',
            'STANDARD-'||nvl(offset.tax_recovery_rate,0),
             NULL)                   DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX    ,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      NULL                           RECOVERY_RULE_CODE    ,
      'IMMEDIATE'                    DEF_REC_SETTLEMENT_OPTION_CODE,
      offset.vat_transaction_type    VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      offset.ATTRIBUTE1              ATTRIBUTE1,
      offset.ATTRIBUTE2              ATTRIBUTE2,
      offset.ATTRIBUTE3              ATTRIBUTE3,
      offset.ATTRIBUTE4              ATTRIBUTE4,
      offset.ATTRIBUTE5              ATTRIBUTE5,
      offset.ATTRIBUTE6              ATTRIBUTE6,
      offset.ATTRIBUTE7              ATTRIBUTE7,
      offset.ATTRIBUTE8              ATTRIBUTE8,
      offset.ATTRIBUTE9              ATTRIBUTE9,
      offset.ATTRIBUTE10             ATTRIBUTE10,
      offset.ATTRIBUTE11             ATTRIBUTE11,
      offset.ATTRIBUTE12             ATTRIBUTE12,
      offset.ATTRIBUTE13             ATTRIBUTE13,
      offset.ATTRIBUTE14             ATTRIBUTE14,
      offset.ATTRIBUTE15             ATTRIBUTE15,
      offset.ATTRIBUTE_CATEGORY      ATTRIBUTE_CATEGORY,
      offset.set_of_books_id         LEDGER_ID,
      results.org_id                 ORG_ID,
      offset.tax_code_combination_id TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',offset.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID ,
      offset.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all offset,
    ar_vat_tax_all_b   ar_codes,
    financials_system_params_all fsp,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = offset.tax_id
AND  results.tax_class = 'INPUT'
AND  offset.tax_id   = ar_codes.vat_tax_id
AND  offset.tax_type = 'OFFSET'
AND  offset.org_id = fsp.org_id
AND  offset.org_id   = ptp.party_id
AND  ptp.party_type_code  ='OU'
AND  not exists (select 1 from ap_tax_codes_all  where
                 offset_tax_code_id = offset.tax_id)
--Added following conditions for Sync process
AND  offset.tax_id  = nvl(p_tax_id,offset.tax_id)
--Rerunnability check
AND  not exists (select 1 from zx_rates_b
                 where  source_id =  nvl(p_tax_id,offset.tax_id)
                ) ;
ELSE

INSERT ALL
INTO zx_rates_b_tmp
(
        TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  SOURCE_ID                      ,--BugFix 3605729
  TAX_CLASS                      ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
      --BugFix 3426244
        ADJ_FOR_ADHOC_AMT_CODE         ,
        ALLOW_ADHOC_TAX_RATE_FLAG  ,
  OBJECT_VERSION_NUMBER
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
VALUES
(
        TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  TAX_RATE_ID                    ,
  'INPUT'                        ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  zx_rates_b_s.nextval           ,--TAX_RATE_ID
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
  'TAX_RATE'                      ,
  'Y'        ,-- ALLOW_ADHOC_TAX_RATE_FLAG
  1
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
INTO zx_accounts
(
  TAX_ACCOUNT_ID                 ,
  TAX_ACCOUNT_ENTITY_ID          ,
  TAX_ACCOUNT_ENTITY_CODE        ,
  LEDGER_ID                      ,
  INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
  TAX_ACCOUNT_CCID               ,
  INTERIM_TAX_CCID               ,
  NON_REC_ACCOUNT_CCID           ,
  ADJ_CCID                       ,
  EDISC_CCID                     ,
  UNEDISC_CCID                   ,
  FINCHRG_CCID                   ,
  ADJ_NON_REC_TAX_CCID           ,
  EDISC_NON_REC_TAX_CCID         ,
  UNEDISC_NON_REC_TAX_CCID       ,
  FINCHRG_NON_REC_TAX_CCID       ,
  RECORD_TYPE_CODE               ,
  ATTRIBUTE1             ,
  ATTRIBUTE2             ,
  ATTRIBUTE3             ,
  ATTRIBUTE4             ,
  ATTRIBUTE5             ,
  ATTRIBUTE6             ,
  ATTRIBUTE7             ,
  ATTRIBUTE8             ,
  ATTRIBUTE9             ,
  ATTRIBUTE10            ,
  ATTRIBUTE11            ,
  ATTRIBUTE12            ,
  ATTRIBUTE13            ,
  ATTRIBUTE14            ,
  ATTRIBUTE15            ,
  ATTRIBUTE_CATEGORY,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID    ,
  OBJECT_VERSION_NUMBER
)
VALUES
(
   ZX_ACCOUNTS_S.NEXTVAL ,
   zx_rates_b_s.nextval  ,--TAX_RATE_ID
   'RATES'                ,
   LEDGER_ID            ,
   ORG_ID               ,
   TAX_ACCOUNT_CCID     ,
   NULL                 ,
   NON_REC_ACCOUNT_CCID ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   RECORD_TYPE_CODE     ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
   NULL                 ,
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
      results.tax_code_id            TAX_RATE_ID,
      results.tax_code               TAX_RATE_CODE,
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      offset.start_date              EFFECTIVE_FROM,
      offset.inactive_date           EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
      'N'                            SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      offset.tax_rate                PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      offset.enabled_flag            ACTIVE_FLAG,
      'N'                            DEFAULT_RATE_FLAG          ,
      NULL                        DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                        DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(offset.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                           DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
            'Y',
            'STANDARD-'||nvl(offset.tax_recovery_rate,0),
             NULL)                   DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX    ,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      NULL                           RECOVERY_RULE_CODE    ,
      'IMMEDIATE'                    DEF_REC_SETTLEMENT_OPTION_CODE,
      offset.vat_transaction_type    VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      offset.ATTRIBUTE1              ATTRIBUTE1,
      offset.ATTRIBUTE2              ATTRIBUTE2,
      offset.ATTRIBUTE3              ATTRIBUTE3,
      offset.ATTRIBUTE4              ATTRIBUTE4,
      offset.ATTRIBUTE5              ATTRIBUTE5,
      offset.ATTRIBUTE6              ATTRIBUTE6,
      offset.ATTRIBUTE7              ATTRIBUTE7,
      offset.ATTRIBUTE8              ATTRIBUTE8,
      offset.ATTRIBUTE9              ATTRIBUTE9,
      offset.ATTRIBUTE10             ATTRIBUTE10,
      offset.ATTRIBUTE11             ATTRIBUTE11,
      offset.ATTRIBUTE12             ATTRIBUTE12,
      offset.ATTRIBUTE13             ATTRIBUTE13,
      offset.ATTRIBUTE14             ATTRIBUTE14,
      offset.ATTRIBUTE15             ATTRIBUTE15,
      offset.ATTRIBUTE_CATEGORY      ATTRIBUTE_CATEGORY,
      offset.set_of_books_id         LEDGER_ID,
      results.org_id                 ORG_ID,
      offset.tax_code_combination_id TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',offset.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID ,
      offset.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all offset,
    ar_vat_tax_all_b   ar_codes,
    financials_system_params_all fsp,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = offset.tax_id
AND  results.tax_class = 'INPUT'
AND  offset.tax_id   = ar_codes.vat_tax_id
AND  offset.tax_type = 'OFFSET'
AND  offset.org_id = l_org_id
AND  offset.org_id = fsp.org_id
AND  offset.org_id   = ptp.party_id
AND  ptp.party_type_code  ='OU'
AND  not exists (select 1 from ap_tax_codes_all  where
                 offset_tax_code_id = offset.tax_id)
--Added following conditions for Sync process
AND  offset.tax_id  = nvl(p_tax_id,offset.tax_id)
--Rerunnability check
AND  not exists (select 1 from zx_rates_b
                 where  source_id =  nvl(p_tax_id,offset.tax_id)
                ) ;

 END IF;
END IF;

IF L_MULTI_ORG_FLAG = 'Y'
THEN
INSERT ALL
INTO zx_rates_b_tmp
(
        TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
        TAX_CLASS                      , --Bug 3987672
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
--BugFix 3426244
  ADJ_FOR_ADHOC_AMT_CODE         ,
  ALLOW_ADHOC_TAX_RATE_FLAG  ,
  OBJECT_VERSION_NUMBER           ,
-- Bug 4241667 : SOURCE_ID = TAX_RATE_ID for AP TAX CODES
  SOURCE_ID
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
VALUES
(
        TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
        'INPUT'                        ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
  'TAX_RATE'                      ,
  'Y'        ,-- ALLOW_ADHOC_TAX_RATE_FLAG
  1                               ,
-- Bug 4241667 : SOURCE_ID = TAX_RATE_ID for AP TAX CODES
   TAX_RATE_ID
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
INTO zx_accounts
(
        TAX_ACCOUNT_ID                 ,
  TAX_ACCOUNT_ENTITY_ID          ,
  TAX_ACCOUNT_ENTITY_CODE        ,
  LEDGER_ID                      ,
  INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
  TAX_ACCOUNT_CCID               ,
  INTERIM_TAX_CCID               ,
  NON_REC_ACCOUNT_CCID           ,
  ADJ_CCID                       ,
  EDISC_CCID                     ,
  UNEDISC_CCID                   ,
  FINCHRG_CCID                   ,
  ADJ_NON_REC_TAX_CCID           ,
  EDISC_NON_REC_TAX_CCID         ,
  UNEDISC_NON_REC_TAX_CCID       ,
  FINCHRG_NON_REC_TAX_CCID       ,
  RECORD_TYPE_CODE               ,
  ATTRIBUTE1             ,
  ATTRIBUTE2             ,
  ATTRIBUTE3             ,
  ATTRIBUTE4             ,
  ATTRIBUTE5             ,
  ATTRIBUTE6             ,
  ATTRIBUTE7             ,
  ATTRIBUTE8             ,
  ATTRIBUTE9             ,
  ATTRIBUTE10            ,
  ATTRIBUTE11            ,
  ATTRIBUTE12            ,
  ATTRIBUTE13            ,
  ATTRIBUTE14            ,
  ATTRIBUTE15            ,
  ATTRIBUTE_CATEGORY,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID    ,
  OBJECT_VERSION_NUMBER
)
VALUES
(
        ZX_ACCOUNTS_S.NEXTVAL ,
        TAX_RATE_ID           ,
        'RATES'                ,
         LEDGER_ID            ,
         ORG_ID               ,
         TAX_ACCOUNT_CCID     ,
         NULL                 ,
         NON_REC_ACCOUNT_CCID ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         RECORD_TYPE_CODE     ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
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
      results.tax_code_id            TAX_RATE_ID,
      results.tax_code               TAX_RATE_CODE,
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      offset.start_date              EFFECTIVE_FROM,
      offset.inactive_date           EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
      'N'                            SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      offset.tax_rate                PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      offset.enabled_flag            ACTIVE_FLAG,
      'N'                            DEFAULT_RATE_FLAG          ,
      NULL                        DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                        DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(offset.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105

    --NULL                           DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
            'Y',
            'STANDARD-'||nvl(offset.tax_recovery_rate,0),
             NULL)                   DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX    ,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      NULL                           RECOVERY_RULE_CODE    ,
      'IMMEDIATE'                    DEF_REC_SETTLEMENT_OPTION_CODE,
      offset.vat_transaction_type    VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      offset.ATTRIBUTE1              ATTRIBUTE1,
      offset.ATTRIBUTE2              ATTRIBUTE2,
      offset.ATTRIBUTE3              ATTRIBUTE3,
      offset.ATTRIBUTE4              ATTRIBUTE4,
      offset.ATTRIBUTE5              ATTRIBUTE5,
      offset.ATTRIBUTE6              ATTRIBUTE6,
      offset.ATTRIBUTE7              ATTRIBUTE7,
      offset.ATTRIBUTE8              ATTRIBUTE8,
      offset.ATTRIBUTE9              ATTRIBUTE9,
      offset.ATTRIBUTE10             ATTRIBUTE10,
      offset.ATTRIBUTE11             ATTRIBUTE11,
      offset.ATTRIBUTE12             ATTRIBUTE12,
      offset.ATTRIBUTE13             ATTRIBUTE13,
      offset.ATTRIBUTE14             ATTRIBUTE14,
      offset.ATTRIBUTE15             ATTRIBUTE15,
      offset.ATTRIBUTE_CATEGORY      ATTRIBUTE_CATEGORY,
      offset.set_of_books_id         LEDGER_ID,
      results.org_id                 ORG_ID,
      offset.tax_code_combination_id TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',offset.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      offset.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all offset,
    financials_system_params_all fsp,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = offset.tax_id
AND  results.tax_class = 'INPUT'
AND  offset.tax_type = 'OFFSET'
AND  offset.org_id = fsp.org_id
AND  offset.org_id = ptp.party_id
AND  ptp.party_type_code  ='OU'
AND  not exists (select 1 from ap_tax_codes_all  where
                 offset_tax_code_id = offset.tax_id)
--Added following conditions for Sync process
AND  offset.tax_id  = nvl(p_tax_id,offset.tax_id)
--BugFix 3605729 added nvl(source_id, in the following condition.
AND  not exists (select 1 from zx_rates_b
                 where  nvl(source_id,tax_rate_id) =  nvl(p_tax_id,offset.tax_id)
                )
;
ELSE

INSERT ALL
INTO zx_rates_b_tmp
(
        TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
        TAX_CLASS                      , --Bug 3987672
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
--BugFix 3426244
  ADJ_FOR_ADHOC_AMT_CODE         ,
  ALLOW_ADHOC_TAX_RATE_FLAG  ,
  OBJECT_VERSION_NUMBER           ,
-- Bug 4241667 : SOURCE_ID = TAX_RATE_ID for AP TAX CODES
  SOURCE_ID
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
VALUES
(
        TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
        'INPUT'                        ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
  'TAX_RATE'                      ,
  'Y'        ,-- ALLOW_ADHOC_TAX_RATE_FLAG
  1                               ,
-- Bug 4241667 : SOURCE_ID = TAX_RATE_ID for AP TAX CODES
  TAX_RATE_ID
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
INTO zx_accounts
(
        TAX_ACCOUNT_ID                 ,
  TAX_ACCOUNT_ENTITY_ID          ,
  TAX_ACCOUNT_ENTITY_CODE        ,
  LEDGER_ID                      ,
  INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
  TAX_ACCOUNT_CCID               ,
  INTERIM_TAX_CCID               ,
  NON_REC_ACCOUNT_CCID           ,
  ADJ_CCID                       ,
  EDISC_CCID                     ,
  UNEDISC_CCID                   ,
  FINCHRG_CCID                   ,
  ADJ_NON_REC_TAX_CCID           ,
  EDISC_NON_REC_TAX_CCID         ,
  UNEDISC_NON_REC_TAX_CCID       ,
  FINCHRG_NON_REC_TAX_CCID       ,
  RECORD_TYPE_CODE               ,
  ATTRIBUTE1             ,
  ATTRIBUTE2             ,
  ATTRIBUTE3             ,
  ATTRIBUTE4             ,
  ATTRIBUTE5             ,
  ATTRIBUTE6             ,
  ATTRIBUTE7             ,
  ATTRIBUTE8             ,
  ATTRIBUTE9             ,
  ATTRIBUTE10            ,
  ATTRIBUTE11            ,
  ATTRIBUTE12            ,
  ATTRIBUTE13            ,
  ATTRIBUTE14            ,
  ATTRIBUTE15            ,
  ATTRIBUTE_CATEGORY,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID    ,
  OBJECT_VERSION_NUMBER
)
VALUES
(
        ZX_ACCOUNTS_S.NEXTVAL ,
        TAX_RATE_ID           ,
        'RATES'                ,
         LEDGER_ID            ,
         ORG_ID               ,
         TAX_ACCOUNT_CCID     ,
         NULL                 ,
         NON_REC_ACCOUNT_CCID ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         RECORD_TYPE_CODE     ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
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
      results.tax_code_id            TAX_RATE_ID,
      results.tax_code               TAX_RATE_CODE,
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      offset.start_date              EFFECTIVE_FROM,
      offset.inactive_date           EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
      'N'                            SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      offset.tax_rate                PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      offset.enabled_flag            ACTIVE_FLAG,
      'N'                            DEFAULT_RATE_FLAG          ,
      NULL                        DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                        DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(offset.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105

    --NULL                           DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
            'Y',
            'STANDARD-'||nvl(offset.tax_recovery_rate,0),
             NULL)                   DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX    ,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      NULL                           RECOVERY_RULE_CODE    ,
      'IMMEDIATE'                    DEF_REC_SETTLEMENT_OPTION_CODE,
      offset.vat_transaction_type    VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      offset.ATTRIBUTE1              ATTRIBUTE1,
      offset.ATTRIBUTE2              ATTRIBUTE2,
      offset.ATTRIBUTE3              ATTRIBUTE3,
      offset.ATTRIBUTE4              ATTRIBUTE4,
      offset.ATTRIBUTE5              ATTRIBUTE5,
      offset.ATTRIBUTE6              ATTRIBUTE6,
      offset.ATTRIBUTE7              ATTRIBUTE7,
      offset.ATTRIBUTE8              ATTRIBUTE8,
      offset.ATTRIBUTE9              ATTRIBUTE9,
      offset.ATTRIBUTE10             ATTRIBUTE10,
      offset.ATTRIBUTE11             ATTRIBUTE11,
      offset.ATTRIBUTE12             ATTRIBUTE12,
      offset.ATTRIBUTE13             ATTRIBUTE13,
      offset.ATTRIBUTE14             ATTRIBUTE14,
      offset.ATTRIBUTE15             ATTRIBUTE15,
      offset.ATTRIBUTE_CATEGORY      ATTRIBUTE_CATEGORY,
      offset.set_of_books_id         LEDGER_ID,
      results.org_id                 ORG_ID,
      offset.tax_code_combination_id TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',offset.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      offset.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all offset,
    financials_system_params_all fsp,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = offset.tax_id
AND  results.tax_class = 'INPUT'
AND  offset.tax_type = 'OFFSET'
AND  offset.org_id = l_org_id
AND  offset.org_id = fsp.org_id
AND  offset.org_id = ptp.party_id
AND  ptp.party_type_code  ='OU'
AND  not exists (select 1 from ap_tax_codes_all  where
                 offset_tax_code_id = offset.tax_id)
--Added following conditions for Sync process
AND  offset.tax_id  = nvl(p_tax_id,offset.tax_id)
--BugFix 3605729 added nvl(source_id, in the following condition.
AND  not exists (select 1 from zx_rates_b
                 where  nvl(source_id,tax_rate_id) =  nvl(p_tax_id,offset.tax_id)
                )
;
END IF;


INSERT INTO  ZX_RATES_TL
(
    TAX_RATE_ID,
    TAX_RATE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
  description
)
SELECT
    TAX_RATE_ID,
    CASE WHEN TAX_RATE_CODE = UPPER(TAX_RATE_CODE)
         THEN    Initcap(TAX_RATE_CODE)
         ELSE    TAX_RATE_CODE
    END                           ,
    fnd_global.user_id             ,
    SYSDATE                        ,
    fnd_global.user_id             ,
    SYSDATE                        ,
    fnd_global.conc_login_id       ,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    avtb.description
FROM FND_LANGUAGES L,
     ZX_RATES_B RATES,
     ar_vat_tax_all_b   avtb
WHERE
     L.INSTALLED_FLAG in ('I', 'B')
AND avtb.vat_tax_id = RATES.tax_rate_id
AND  RATES.RECORD_TYPE_CODE = 'MIGRATED'
AND  not exists
    (select NULL
    from ZX_RATES_TL T
    where T.TAX_RATE_ID = RATES.TAX_RATE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('Migrate_UnAssign_Offset_Codes(-)');
    END IF;


EXCEPTION
         WHEN OTHERS THEN
            IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Migrate_unassign_offset_codes ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('Migrate_UnAssign_Offset_Codes(-)');
            END IF;
            --app_exception.raise_exception;
END migrate_unassign_offset_codes;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    migrate_recovery_rates                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine processes distinct recovery rates,inserts appropriate    |
 |     data into the following zx base tables.                               |
 |               ZX_RATES_B                                                  |
 |               ZX_RATES_TL                                                 |
 |               ZX_ACCOUNTS                                                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        migrate_ap_tax_codes_setup                                         |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-Dec-03  Srinivas Lokam      Created.                               |
 |     30-Jan-04  Srinivas Lokam      Added INPUT parameters,AND conditions  |
 |                                    in SELECT statements for handling      |
 |                                    SYNC process.                          |
 |                                                                           |
 |==========================================================================*/


PROCEDURE migrate_recovery_rates(p_tax_id IN NUMBER DEFAULT NULL) IS
BEGIN

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('Migrate_Recovery_Rates(+)');
    END IF;

--For Default Recovery Rates.
BEGIN
--Bug 4677185 --Bug 4943105
for cursor_rec in
(
SELECT
  TAX_REGIME_CODE,
  TAX,
  CONTENT_OWNER_ID,
  decode(INSTRB(DEFAULT_REC_RATE_CODE,'-',1,2),
           0,DEFAULT_REC_RATE_CODE,
        substrb(DEFAULT_REC_RATE_CODE,1,instrb(DEFAULT_REC_RATE_CODE,'-',1,2)-1)) DEFAULT_REC_RATE_CODE

 FROM
 ZX_RATES_B
  where record_type_code = 'MIGRATED'
 and DEFAULT_REC_RATE_CODE is not null
GROUP BY
 TAX_REGIME_CODE,
 TAX,
 CONTENT_OWNER_ID,
  decode(INSTRB(DEFAULT_REC_RATE_CODE,'-',1,2),
           0,DEFAULT_REC_RATE_CODE,
        substrb(DEFAULT_REC_RATE_CODE,1,instrb(DEFAULT_REC_RATE_CODE,'-',1,2)-1))

)
LOOP
BEGIN
INSERT INTO zx_rates_b_tmp
(
      TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  RECORD_TYPE_CODE               ,
      TAX_CLASS                      , --Bug 3987672
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
      --BugFix 3426244
  ADJ_FOR_ADHOC_AMT_CODE         ,
  ALLOW_ADHOC_TAX_RATE_FLAG      ,
  OBJECT_VERSION_NUMBER
)
SELECT
      TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  RECORD_TYPE_CODE               ,
        'INPUT'                        ,
  ZX_RATES_B_S.NEXTVAL           ,
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
       'TAX_RATE'                      ,
       'Y'              ,-- ALLOW_ADHOC_TAX_RATE_FLAG
  1
FROM
(
SELECT
      SUBSTRB(rates.default_rec_rate_code,1,24)    TAX_RATE_CODE, --Bug 4943105
      rates.CONTENT_OWNER_ID,
     (select min(effective_from)
      from zx_rates_b
      where record_type_code = 'MIGRATED'
      and   default_rec_rate_code =
            rates.default_rec_rate_code
      and   tax_regime_code =
      rates.tax_regime_code
      and   tax =
      rates.tax
      and   content_owner_id =
            rates.content_owner_id
      )
                                     EFFECTIVE_FROM,
      NULL                           EFFECTIVE_TO,
      rates.TAX_REGIME_CODE ,
      rates.TAX,
      NULL                           TAX_STATUS_CODE,
     'N'                             SCHEDULE_BASED_RATE_FLAG,
     'RECOVERY'                      RATE_TYPE_CODE,
      nvl(codes.tax_recovery_rate,0)        PERCENTAGE_RATE,--Bug 5118399
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      (SELECT tax_id FROM zx_taxes_b WHERE tax_regime_code = rates.tax_regime_code AND tax = rates.tax AND content_owner_id = rates.content_owner_id)
                                     TAX_JURISDICTION_CODE,--Bug 4943105
     'STANDARD'                      RECOVERY_TYPE_CODE, --important
     'Y'                             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                           DEFAULT_FLG_EFFECTIVE_TO   ,
      NULL                           DEFAULT_REC_TYPE_CODE      ,
    --NULL                           DEFAULT_REC_TAX            ,
      NULL                           DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      NULL                           RECOVERY_RULE_CODE    ,
      NULL                           DEF_REC_SETTLEMENT_OPTION_CODE,
     'MIGRATED'                      RECORD_TYPE_CODE
FROM
    ap_tax_codes_all codes,
    zx_rates_b rates
WHERE
   --BugFix 3480468
     rates.default_rec_rate_code is not null
AND  rates.TAX_REGIME_CODE = cursor_rec.TAX_REGIME_CODE
AND  rates.TAX = cursor_rec.TAX
AND  rates.CONTENT_OWNER_ID = cursor_rec.CONTENT_OWNER_ID
and rates.DEFAULT_REC_RATE_CODE = cursor_rec.DEFAULT_REC_RATE_CODE --Bug 4677185
--AND  codes.tax_recovery_rate is not null -- Bug 5103375
--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
AND  codes.tax_id  = nvl(rates.source_id, rates.tax_rate_id)
AND  rates.record_type_code = 'MIGRATED'
AND  ROWNUM = 1
AND  not exists (select 1 from zx_rates_b_tmp
                 where  SUBSTRB(tax_rate_code,1,24)    = substrb(rates.default_rec_rate_code,1,24) --Bug 4943105
                 and    content_owner_id = rates.content_owner_id
     and    tax_jurisdiction_code =  (SELECT tax_id FROM zx_taxes_b WHERE tax_regime_code = rates.tax_regime_code AND tax = rates.tax AND content_owner_id = rates.content_owner_id)
                )
);


-- Bug 4677185 : Logic to backupdate the Recovery_Tax_Rate_Code created on to the orginal tax rate.
/* Commented for the Bug 4943105 :
update zx_rates_b rates
set rates.DEFAULT_REC_RATE_CODE = ( select rates2.tax_rate_code
  from zx_rates_b rates2
  where rates2.CONTENT_OWNER_ID = cursor_rec.CONTENT_OWNER_ID
  AND  rates2.TAX_REGIME_CODE =  cursor_rec.TAX_REGIME_CODE
  AND  rates2.TAX = cursor_rec.TAX
  AND  rates2.TAX_STATUS_CODE = cursor_rec.TAX_STATUS_CODE
  AND  INSTRB(rates2.tax_rate_code,'-',1,2) > 0
  and  substrb(rates2.tax_rate_code,1,instr(rates2.tax_rate_code,'-',1,2)-1) = cursor_rec.DEFAULT_REC_RATE_CODE
        and rownum = 1
       )
where rates.CONTENT_OWNER_ID = cursor_rec.CONTENT_OWNER_ID
AND  rates.TAX_REGIME_CODE = cursor_rec.TAX_REGIME_CODE
AND  rates.TAX = cursor_rec.TAX
AND  rates.TAX_STATUS_CODE =  cursor_rec.TAX_STATUS_CODE
and  rates.DEFAULT_REC_RATE_CODE = cursor_rec.DEFAULT_REC_RATE_CODE ;*/
EXCEPTION
WHEN OTHERS THEN
            IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Migrate_recovery_rates - Default Recovery Rates ');
              arp_util_tax.debug(cursor_rec.CONTENT_OWNER_ID||'-'||cursor_rec.TAX_REGIME_CODE||'-'||cursor_rec.TAX||'-'||cursor_rec.CONTENT_OWNER_ID||'-'||cursor_rec.DEFAULT_REC_RATE_CODE||'-'||sqlerrm);
            END IF;
END;
end loop;
end;

-- No need to insert into ZX_ACCOUNTS for Recovery rates.
BEGIN
INSERT INTO  ZX_RATES_TL
(
    TAX_RATE_ID,
    TAX_RATE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
  description
)
SELECT
    TAX_RATE_ID,
    CASE WHEN TAX_RATE_CODE = UPPER(TAX_RATE_CODE)
     THEN    Initcap(TAX_RATE_CODE)
     ELSE
             TAX_RATE_CODE
     END,
    fnd_global.user_id             ,
    SYSDATE                        ,
    fnd_global.user_id             ,
    SYSDATE                        ,
    fnd_global.conc_login_id       ,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    avtb.description
FROM FND_LANGUAGES L,
     ZX_RATES_B RATES,
     ar_vat_tax_all_b   avtb
WHERE
     L.INSTALLED_FLAG in ('I', 'B')
AND  avtb.vat_tax_id = RATES.tax_rate_id
AND  RATES.RECORD_TYPE_CODE = 'MIGRATED'
AND  not exists
    (select NULL
    from ZX_RATES_TL T
    where T.TAX_RATE_ID = RATES.TAX_RATE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
EXCEPTION WHEN OTHERS THEN
NULL;
END;

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('Migrate_Recovery_Rates(-)');
    END IF;

EXCEPTION
         WHEN OTHERS THEN
            IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Migrate_recovery_rates ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('Migrate_Recovery_Rates(-)');
            END IF;
            --app_exception.raise_exception;
END migrate_recovery_rates;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    migrate_recovery_rates_rules                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine processes distinct recovery rates,inserts appropriate    |
 |     data into the following zx base tables.                               |
 |               ZX_RATES_B                                                  |
 |               ZX_RATES_TL                                                 |
 |               ZX_ACCOUNTS                                                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        migrate_ap_tax_codes_setup                                         |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-Dec-03  Srinivas Lokam      Created.                               |
 |     30-Jan-04  Srinivas Lokam      Added INPUT parameters,AND conditions  |
 |                                    in SELECT statements for handling      |
 |                                    SYNC process.                          |
 |                                                                           |
 |==========================================================================*/
PROCEDURE migrate_recovery_rates_rules IS
BEGIN

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('Migrate_Recovery_Rates_Rules(+)');
    END IF;

--For Tax Recovery Rules associated Recovery Rates.
BEGIN

INSERT INTO zx_rates_b_tmp
(
        TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  RECORD_TYPE_CODE               ,
        TAX_CLASS                      , --Bug 3987672
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
      --BugFix 3426244
        ADJ_FOR_ADHOC_AMT_CODE         ,
        ALLOW_ADHOC_TAX_RATE_FLAG  ,
  OBJECT_VERSION_NUMBER
)
SELECT
        TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  NULL                           ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  RECORD_TYPE_CODE               ,
        'INPUT'                        ,
  ZX_RATES_B_S.NEXTVAL           ,
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
       'TAX_RATE'                      ,
       'Y'         ,-- ALLOW_ADHOC_TAX_RATE_FLAG
  1
FROM
(
SELECT
      DISTINCT
      'STANDARD-'||rates.recovery_rate    TAX_RATE_CODE, --Bug 4644762 --Bug4882676
      zx_rates.CONTENT_OWNER_ID                   ,
      (select min(start_date)  from ap_tax_codes_all
      where  tax_recovery_rule_id = codes.tax_recovery_rule_id
      group by tax_recovery_rule_id) EFFECTIVE_FROM,
      NULL                           EFFECTIVE_TO,
      zx_rates.TAX_REGIME_CODE                   ,
      zx_rates.TAX                               ,
      NULL                                       ,
     'N'                             SCHEDULE_BASED_RATE_FLAG,
     'RECOVERY'                      RATE_TYPE_CODE,
      rates.recovery_rate            PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      (select tax_id from zx_taxes_b where tax = zx_rates.tax and tax_regime_code
       = zx_rates.tax_regime_code and content_owner_id = zx_rates.content_owner_id )
                                     TAX_JURISDICTION_CODE,
     'STANDARD'                      RECOVERY_TYPE_CODE, --important
      rates.enabled_flag             ACTIVE_FLAG,
      'N'                            DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                           DEFAULT_FLG_EFFECTIVE_TO   ,
      NULL                           DEFAULT_REC_TYPE_CODE      ,
    --NULL                           DEFAULT_REC_TAX            ,
      NULL                           DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      NULL                           RECOVERY_RULE_CODE    ,
      NULL                           DEF_REC_SETTLEMENT_OPTION_CODE,
     'MIGRATED'                      RECORD_TYPE_CODE
FROM
    ap_tax_codes_all codes,
    zx_rates_b zx_rates,
    ap_tax_recvry_rules_all rules,
    ap_tax_recvry_rates_all rates
WHERE
     codes.tax_recovery_rule_id = rules.rule_id
AND  rules.rule_id = rates.rule_id
--Added following conditions for Sync process

AND  codes.tax_id  = nvl(zx_rates.source_id, zx_rates.tax_rate_id)
AND  zx_rates.record_type_code = 'MIGRATED'
AND  not exists (select 1 from zx_rates_b
                 where  decode(instrb(tax_rate_code,'-',1,2),
            0,tax_rate_code,
      substrb(tax_rate_code,1,instrb(tax_rate_code,'-',1,2)-1)) = 'STANDARD-'|| rates.recovery_rate -- Bug 4644762
                 and    rate_type_code   = 'RECOVERY'
                 and    content_owner_id = zx_rates.content_owner_id
                 AND    tax_jurisdiction_code = (select tax_id from zx_taxes_b where tax = zx_rates.tax and tax_regime_code
                                                 = zx_rates.tax_regime_code and content_owner_id = zx_rates.content_owner_id )
                )
);
exception when others then
null;
end;

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('Migrate_Recovery_Rates_Rules(-)');
    END IF;

EXCEPTION
         WHEN OTHERS THEN
            IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Migrate_recovery_rates_Rules ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('Migrate_Recovery_Rates_Rules(-)');
            END IF;
            --app_exception.raise_exception;
END migrate_recovery_rates_rules;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Create_Adhoc_Recovery_Rates                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine creates an adhoc recovery rate with tax_rate_code        |
 |     starting with AD_HOC_RECOVERY for each tax for which tax recovery     |
 |      is allowed and populates the following ZX base tables.               |
 |               ZX_RATES_B                                                  |
 |               ZX_RATES_TL                                                 |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        migrate_ap_tax_codes_setup                                         |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     04-Oct-05  Ashwin Gurram      Created. Bug 4622937.                   |
 |                                                                           |
 |==========================================================================*/

 PROCEDURE Create_Adhoc_Recovery_Rates IS
 BEGIN

   IF PG_DEBUG = 'Y' THEN
         arp_util_tax.debug('Create_Adhoc_Revocery_Rates(+)');
   END IF;

  -- For adhoc Recovery Rate creation.
  BEGIN
    INSERT INTO zx_rates_b_tmp
    (
      TAX_RATE_CODE                  ,
      EFFECTIVE_FROM                 ,
      EFFECTIVE_TO                   ,
      TAX_REGIME_CODE                ,
      TAX                            ,
      TAX_STATUS_CODE                ,
      SCHEDULE_BASED_RATE_FLAG       ,
      RATE_TYPE_CODE                 ,
      PERCENTAGE_RATE                ,
      QUANTITY_RATE                  ,
      UOM_CODE                       ,
      TAX_JURISDICTION_CODE          ,
      RECOVERY_TYPE_CODE             ,
      ACTIVE_FLAG                    ,
      DEFAULT_RATE_FLAG              ,
      DEFAULT_FLG_EFFECTIVE_FROM     ,
      DEFAULT_FLG_EFFECTIVE_TO       ,
      DEFAULT_REC_TYPE_CODE          ,
      DEFAULT_REC_RATE_CODE          ,
      OFFSET_TAX                     ,
      OFFSET_STATUS_CODE             ,
      OFFSET_TAX_RATE_CODE           ,
      RECOVERY_RULE_CODE             ,
      DEF_REC_SETTLEMENT_OPTION_CODE ,
      RECORD_TYPE_CODE               ,
      TAX_CLASS                      ,
      TAX_RATE_ID                    ,
      CONTENT_OWNER_ID               ,
      CREATED_BY                      ,
      CREATION_DATE                  ,
      LAST_UPDATED_BY                ,
      LAST_UPDATE_DATE               ,
      LAST_UPDATE_LOGIN              ,
      REQUEST_ID                     ,
      PROGRAM_APPLICATION_ID         ,
      PROGRAM_ID                     ,
      PROGRAM_LOGIN_ID               ,
      ADJ_FOR_ADHOC_AMT_CODE         ,
      ALLOW_ADHOC_TAX_RATE_FLAG      ,
      OBJECT_VERSION_NUMBER
    )
    SELECT
      TAX_RATE_CODE                  ,
      EFFECTIVE_FROM                 ,
      EFFECTIVE_TO                   ,
      TAX_REGIME_CODE                ,
      TAX                            ,
      TAX_STATUS_CODE                ,
      SCHEDULE_BASED_RATE_FLAG       ,
      RATE_TYPE_CODE                 ,
      PERCENTAGE_RATE                ,
      QUANTITY_RATE                  ,
      UOM_CODE                       ,
      TAX_JURISDICTION_CODE          ,
      RECOVERY_TYPE_CODE             ,
      ACTIVE_FLAG                    ,
      DEFAULT_RATE_FLAG              ,
      DEFAULT_FLG_EFFECTIVE_FROM     ,
      DEFAULT_FLG_EFFECTIVE_TO       ,
      DEFAULT_REC_TYPE_CODE          ,
      DEFAULT_REC_RATE_CODE          ,
      OFFSET_TAX                     ,
      OFFSET_STATUS_CODE             ,
      OFFSET_TAX_RATE_CODE           ,
      RECOVERY_RULE_CODE             ,
      DEF_REC_SETTLEMENT_OPTION_CODE ,
      RECORD_TYPE_CODE               ,
      'INPUT'                        ,
      ZX_RATES_B_S.NEXTVAL           ,
      CONTENT_OWNER_ID               ,
      fnd_global.user_id             ,
      SYSDATE                        ,
      fnd_global.user_id             ,
      SYSDATE                        ,
      fnd_global.conc_login_id       ,
      fnd_global.conc_request_id     , -- Request Id
      fnd_global.prog_appl_id        , -- Program Application ID
      fnd_global.conc_program_id     , -- Program Id
      fnd_global.conc_login_id       , -- Program Login ID
           'TAX_RATE'                      , -- ADJ_FOR_ADHOC_AMT_CODE
           'Y'              ,-- ALLOW_ADHOC_TAX_RATE_FLAG
      1
    FROM
    (
    SELECT
          'AD_HOC_RECOVERY'              TAX_RATE_CODE,  --Bug 5477985
          taxes.CONTENT_OWNER_ID,
          taxes.effective_from           EFFECTIVE_FROM,
          NULL                           EFFECTIVE_TO,
          taxes.TAX_REGIME_CODE ,
          taxes.TAX,
          NULL             TAX_STATUS_CODE,   --Bug 5477985
         'N'                             SCHEDULE_BASED_RATE_FLAG,
         'RECOVERY'                      RATE_TYPE_CODE,
          0                              PERCENTAGE_RATE,
          NULL                           QUANTITY_RATE       ,
          NULL                           UOM_CODE,
          taxes.tax_id                   TAX_JURISDICTION_CODE, --Bug 5477985
         'STANDARD'                      RECOVERY_TYPE_CODE,
         'Y'                             ACTIVE_FLAG,
         'N'                             DEFAULT_RATE_FLAG    ,
          NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
          NULL                           DEFAULT_FLG_EFFECTIVE_TO   ,
          NULL                           DEFAULT_REC_TYPE_CODE      ,
          NULL                           DEFAULT_REC_RATE_CODE,
          NULL                           OFFSET_TAX,
          NULL                           OFFSET_STATUS_CODE ,
          NULL                           OFFSET_TAX_RATE_CODE  ,
          NULL                           RECOVERY_RULE_CODE    ,
          NULL                           DEF_REC_SETTLEMENT_OPTION_CODE,
         'MIGRATED'                      RECORD_TYPE_CODE
    FROM
        zx_taxes_b taxes
    WHERE taxes.ALLOW_RECOVERABILITY_FLAG = 'Y'
    AND taxes.RECORD_TYPE_CODE = 'MIGRATED'
    -- Re-runnability Check
    AND not exists (select 1 from zx_rates_b
            WHERE TAX_RATE_CODE = 'AD_HOC_RECOVERY'
            AND CONTENT_OWNER_ID = taxes.content_owner_id
            AND tax_regime_code = taxes.tax_regime_code
            AND TAX = taxes.tax
            AND TAX_JURISDICTION_CODE = taxes.tax_id
            ) );
  EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG = 'Y' THEN
          arp_util_tax.debug('EXCEPTION: Create_Adhoc_Recovery_Rates-insert into ZX_RATES_B ');
          arp_util_tax.debug(sqlerrm);
    END IF;
  END;

  -- inserting into ZX_RATES_TL

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
  SELECT
      TAX_RATE_ID,
      CASE WHEN TAX_RATE_CODE = UPPER(TAX_RATE_CODE)
       THEN    Initcap(TAX_RATE_CODE)
       ELSE
         TAX_RATE_CODE
       END                           ,
      fnd_global.user_id             ,
      SYSDATE                        ,
      fnd_global.user_id             ,
      SYSDATE                        ,
      fnd_global.conc_login_id       ,
      L.LANGUAGE_CODE,
      userenv('LANG')
  FROM FND_LANGUAGES L,
       ZX_RATES_B RATES
  WHERE
       L.INSTALLED_FLAG in ('I', 'B')
  AND  RATES.RECORD_TYPE_CODE = 'MIGRATED'
  AND  not exists
      (select NULL
      from ZX_RATES_TL T
      where T.TAX_RATE_ID = RATES.TAX_RATE_ID
      and T.LANGUAGE = L.LANGUAGE_CODE);

      IF PG_DEBUG = 'Y' THEN
         arp_util_tax.debug('Create_Adhoc_Revocery_Rates(-)');
      END IF;

EXCEPTION
WHEN OTHERS THEN
            IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Create_Adhoc_Recovery_Rates ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('Create_Adhoc_Recovery_Rates(-)');
            END IF;

 END Create_Adhoc_Recovery_Rates;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    create_zx_statuses                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine inserts data into ZX_STATUS_B,_TL based on the           |
 |     above inserted data into ZX_RATES_B.                                  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        migrate_ap_tax_codes_setup                                         |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-Dec-03  Srinivas Lokam      Created.                               |
 |     30-Jan-04  Srinivas Lokam      Added INPUT parameters,AND conditions  |
 |                                    in SELECT statements for handling      |
 |                                    SYNC process.                          |
 |                                                                           |
 |==========================================================================*/


PROCEDURE create_zx_statuses(p_tax_id IN NUMBER DEFAULT NULL) IS
  NumRec  Number(10);
BEGIN

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('create_zx_statuses (+)');
    END IF;

BEGIN

INSERT INTO ZX_STATUS_B_TMP
(
    TAX_STATUS_ID,
    TAX_STATUS_CODE,
    EFFECTIVE_FROM,
    EFFECTIVE_TO,
    TAX,
    TAX_REGIME_CODE,
    RULE_BASED_RATE_FLAG,
    ALLOW_RATE_OVERRIDE_FLAG,
  --BugFix 3426244
  --ALLOW_ADHOC_TAX_RATE_FLAG,
    ALLOW_EXEMPTIONS_FLAG,
    ALLOW_EXCEPTIONS_FLAG,
    DEFAULT_STATUS_FLAG,
    DEFAULT_FLG_EFFECTIVE_FROM,
    DEFAULT_FLG_EFFECTIVE_TO,
    DEF_REC_SETTLEMENT_OPTION_CODE,
    CONTENT_OWNER_ID,
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

SELECT
                ZX_STATUS_B_S.NEXTVAL,
                TAX_STATUS_CODE,
                EFFECTIVE_FROM,
                NULL,
                TAX,
                TAX_REGIME_CODE,
                'N',
                'N',
              --'N',
                'N',
                'N',
                'Y',
                EFFECTIVE_FROM,
                NULL,
                NULL,   ---  DEF_REC_SETTLEMENT_OPTION  for global
                CONTENT_OWNER_ID,
                'MIGRATED',
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
FROM
(
SELECT TAX_REGIME_CODE,
       CONTENT_OWNER_ID,
       TAX,
       TAX_STATUS_CODE,
       min(EFFECTIVE_FROM)  EFFECTIVE_FROM
FROM   ZX_RATES_B rates
WHERE
       rates.record_type_code = 'MIGRATED'
AND    rates.tax_status_code IS NOT NULL
--Added following conditions for Sync process
AND  rates.tax_rate_id  = nvl(p_tax_id,rates.tax_rate_id)
AND  not exists (select 1 from zx_status_b
                 where  tax_regime_code = rates.tax_regime_code
                 and    tax             = rates.tax
                 and    tax_status_code = rates.tax_status_code
     and    content_owner_id = rates.content_owner_id
                )
GROUP BY
       TAX_REGIME_CODE,
       CONTENT_OWNER_ID,
       TAX,
       TAX_STATUS_CODE
);
EXCEPTION WHEN OTHERS THEN
  NULL;
END;

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('Statuses For  Unused JATW_GOVERNMENT_TAX_TYPE.. ');
    END IF;

BEGIN
NumRec := 0;
Begin

    SELECT count(distinct global_attribute1) into NumRec
    FROM   ap_tax_codes_all
    WHERE  global_attribute_category = 'JA.TW.APXTADTC.TAX_CODES'
           and global_attribute1 is not null;
EXCEPTION
    WHEN OTHERS THEN
        arp_util_tax.debug('EXCEPTION: ' || sqlerrm);
END;

IF NumRec > 0 THEN
  IF L_MULTI_ORG_FLAG = 'Y'
  THEN

  -- For Unused JATW_GOVERNMENT_TAX_TYPE lookup code
  INSERT INTO ZX_STATUS_B_TMP
  (
    TAX_STATUS_ID,
    TAX_STATUS_CODE,
    EFFECTIVE_FROM,
    EFFECTIVE_TO,
    TAX,
    TAX_REGIME_CODE,
    RULE_BASED_RATE_FLAG,
    ALLOW_RATE_OVERRIDE_FLAG,
  --BugFix 3426244
  --ALLOW_ADHOC_TAX_RATE_FLAG,
    ALLOW_EXEMPTIONS_FLAG,
    ALLOW_EXCEPTIONS_FLAG,
    DEFAULT_STATUS_FLAG,
    DEFAULT_FLG_EFFECTIVE_FROM,
    DEFAULT_FLG_EFFECTIVE_TO,
    DEF_REC_SETTLEMENT_OPTION_CODE,
    CONTENT_OWNER_ID,
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
  SELECT
                ZX_STATUS_B_S.NEXTVAL,
                lookups.lookup_code,  --TAX_STATUS_CODE
                EFFECTIVE_FROM,
                NULL,
                TAX,
                TAX_REGIME_CODE,
                'N',
                'N',
              --'N',
                'N',
                'N',
                'Y',
                EFFECTIVE_FROM,
                NULL,
                NULL,   ---  DEF_REC_SETTLEMENT_OPTION  for global
                CONTENT_OWNER_ID,
                'MIGRATED',
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
  FROM

  (SELECT
       TAX_REGIME_CODE,
       CONTENT_OWNER_ID,
       TAX,
       min(EFFECTIVE_FROM) EFFECTIVE_FROM
  FROM
       ZX_RATES_B rates,
       ap_tax_codes_all codes,
       zx_party_tax_profile ptp
  WHERE
       rates.record_type_code = 'MIGRATED' AND
       codes.tax_id = nvl(rates.source_id, rates.tax_rate_id) AND
       codes.global_attribute_category = 'JA.TW.APXTADTC.TAX_CODES' AND
       global_attribute1 is not null AND
       codes.org_id  = ptp.party_id AND
       ptp.party_Type_code = 'OU' AND
       rates.tax_status_code is not null

  GROUP BY
       TAX_REGIME_CODE,
       CONTENT_OWNER_ID,
       TAX
  ) Statuses,

  (SELECT lookup_code
   FROM   JA_LOOKUPS
   WHERE  lookup_type = 'JATW_GOVERNMENT_TAX_TYPE'

   MINUS

   SELECT distinct global_attribute1
   FROM   ap_tax_codes_all
   WHERE  global_attribute_category = 'JA.TW.APXTADTC.TAX_CODES'
          and global_attribute1 is not null
  ) lookups
WHERE NOT EXISTS
(SELECT 1 FROM ZX_STATUS_B
WHERE
    TAX_REGIME_CODE= Statuses.TAX_REGIME_CODE
AND TAX   = Statuses.TAX
AND TAX_STATUS_CODE=lookups.lookup_code
AND CONTENT_OWNER_ID= Statuses.CONTENT_OWNER_ID
);


ELSE
  INSERT INTO ZX_STATUS_B_TMP
  (
    TAX_STATUS_ID,
    TAX_STATUS_CODE,
    EFFECTIVE_FROM,
    EFFECTIVE_TO,
    TAX,
    TAX_REGIME_CODE,
    RULE_BASED_RATE_FLAG,
    ALLOW_RATE_OVERRIDE_FLAG,
  --BugFix 3426244
  --ALLOW_ADHOC_TAX_RATE_FLAG,
    ALLOW_EXEMPTIONS_FLAG,
    ALLOW_EXCEPTIONS_FLAG,
    DEFAULT_STATUS_FLAG,
    DEFAULT_FLG_EFFECTIVE_FROM,
    DEFAULT_FLG_EFFECTIVE_TO,
    DEF_REC_SETTLEMENT_OPTION_CODE,
    CONTENT_OWNER_ID,
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
  SELECT
                ZX_STATUS_B_S.NEXTVAL,
                lookups.lookup_code,  --TAX_STATUS_CODE
                EFFECTIVE_FROM,
                NULL,
                TAX,
                TAX_REGIME_CODE,
                'N',
                'N',
              --'N',
                'N',
                'N',
                'Y',
                EFFECTIVE_FROM,
                NULL,
                NULL,   ---  DEF_REC_SETTLEMENT_OPTION  for global
                CONTENT_OWNER_ID,
                'MIGRATED',
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
  FROM

  (SELECT
       TAX_REGIME_CODE,
       CONTENT_OWNER_ID,
       TAX,
       min(EFFECTIVE_FROM) EFFECTIVE_FROM
  FROM
       ZX_RATES_B rates,
       ap_tax_codes_all codes,
       zx_party_tax_profile ptp
  WHERE
       rates.record_type_code = 'MIGRATED' AND
       codes.tax_id = nvl(rates.source_id, rates.tax_rate_id) AND
       codes.global_attribute_category = 'JA.TW.APXTADTC.TAX_CODES' AND
       global_attribute1 is not null AND
       codes.org_id  = l_org_id     AND
       codes.org_id  = ptp.party_id AND
       ptp.party_Type_code = 'OU'

  GROUP BY
       TAX_REGIME_CODE,
       CONTENT_OWNER_ID,
       TAX
  ) Statuses,

  (SELECT lookup_code
   FROM   JA_LOOKUPS
   WHERE  lookup_type = 'JATW_GOVERNMENT_TAX_TYPE'

   MINUS

   SELECT distinct global_attribute1
   FROM   ap_tax_codes_all
   WHERE  global_attribute_category = 'JA.TW.APXTADTC.TAX_CODES'
          and global_attribute1 is not null
  ) lookups
WHERE NOT EXISTS
(SELECT 1 FROM ZX_STATUS_B
WHERE
    TAX_REGIME_CODE= Statuses.TAX_REGIME_CODE
AND TAX   = Statuses.TAX
AND TAX_STATUS_CODE=lookups.lookup_code
AND CONTENT_OWNER_ID= Statuses.CONTENT_OWNER_ID
);

END IF;


  -- Bug # 3907038
BEGIN
  INSERT INTO ZX_STATUS_TL
  (
    TAX_STATUS_ID,
    TAX_STATUS_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  )
  SELECT
    DISTINCT     --added
    Status.TAX_STATUS_ID,
    CASE WHEN lookups.MEANING = UPPER(lookups.MEANING)
     THEN    Initcap(lookups.MEANING)
     ELSE
             lookups.MEANING
     END,
    SYSDATE,
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    fnd_global.conc_login_id,
    L.LANGUAGE_CODE,
    userenv('LANG')
  FROM
    FND_LANGUAGES L,
    ZX_STATUS_B Status,
    JA_LOOKUPS lookups,
    ap_tax_codes_all codes,
    ZX_RATES_B rates
  WHERE
    L.INSTALLED_FLAG in ('I', 'B')
  AND Status.RECORD_TYPE_CODE = 'MIGRATED'
  AND codes.tax_id = nvl(rates.source_id, rates.tax_rate_id)
  AND codes.global_attribute_category = 'JA.TW.APXTADTC.TAX_CODES'
  AND global_attribute1 is not null
  AND rates.TAX_REGIME_CODE   = Status.TAX_REGIME_CODE
  AND rates.CONTENT_OWNER_ID  = Status.CONTENT_OWNER_ID
  AND rates.TAX                = Status.TAX
  AND Status.TAX_STATUS_CODE  = lookups.lookup_code
  AND lookups.lookup_type     = 'JATW_GOVERNMENT_TAX_TYPE'
  AND  not exists
       (select NULL
       from ZX_STATUS_TL T
       where T.TAX_STATUS_ID =  Status.TAX_STATUS_ID
       and T.LANGUAGE = L.LANGUAGE_CODE);
EXCEPTION WHEN OTHERS THEN
  NULL;
END;

  --End of JATW_GOVERNMENT_TAX_TYPE lookup code

END IF;

EXCEPTION WHEN OTHERS THEN
  NULL;
END;


BEGIN

INSERT INTO ZX_STATUS_TL
(
    TAX_STATUS_ID,
    TAX_STATUS_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  )
SELECT
    TAX_STATUS_ID,
    CASE WHEN TAX_STATUS_CODE = UPPER(TAX_STATUS_CODE)
     THEN    Initcap(TAX_STATUS_CODE)
     ELSE
             TAX_STATUS_CODE
     END,
    SYSDATE,
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    fnd_global.conc_login_id,
    L.LANGUAGE_CODE,
    userenv('LANG')
FROM
    FND_LANGUAGES L,
    ZX_STATUS_B B
WHERE
    L.INSTALLED_FLAG in ('I', 'B')
AND RECORD_TYPE_CODE = 'MIGRATED'
AND  not exists
     (select NULL
     from ZX_STATUS_TL T
     where T.TAX_STATUS_ID =  B.TAX_STATUS_ID
     and T.LANGUAGE = L.LANGUAGE_CODE);
EXCEPTION WHEN OTHERS THEN
  NULL;
END;

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('create_zx_statuses (-)');
    END IF;


EXCEPTION
         WHEN OTHERS THEN
            IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Create_zx_statuses ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('create_zx_statuses (-)');
            END IF;
            --app_exception.raise_exception;
END create_zx_statuses;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    create_zx_taxes                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine inserts data into ZX_TAXES_B,_TL based on the            |
 |     above inserted data into ZX_RATES_B.                                  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        migrate_ap_tax_codes_setup                                         |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-Dec-03  Srinivas Lokam      Created.                               |
 |     30-Jan-04  Srinivas Lokam      Added INPUT parameters,AND conditions  |
 |                                    in SELECT statements for handling      |
 |                                    SYNC process.                          |
 |                                                                           |
 |==========================================================================*/



PROCEDURE create_zx_taxes(p_tax_id IN NUMBER DEFAULT NULL) IS
BEGIN

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('create_zx_taxes(+)');
    END IF;
BEGIN

IF L_MULTI_ORG_FLAG = 'Y'
THEN
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
       --BugFix 3493419
     SOURCE_TAX_FLAG                        ,
     SPECIAL_INCLUSIVE_TAX_FLAG             ,
     ALLOW_DUP_REGN_NUM_FLAG                ,
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
       --BugFix 3480468
     DEF_PRIMARY_REC_RATE_CODE              ,
     DEF_SECONDARY_REC_RATE_CODE            ,
      CREATED_BY                       ,
   CREATION_DATE                          ,
   LAST_UPDATED_BY                        ,
   LAST_UPDATE_DATE                       ,
   LAST_UPDATE_LOGIN                      ,
   REQUEST_ID                             ,
   PROGRAM_APPLICATION_ID                 ,
   PROGRAM_ID                             ,
   PROGRAM_LOGIN_ID                       ,
     OVERRIDE_GEOGRAPHY_TYPE    ,
   OBJECT_VERSION_NUMBER      ,
   LIVE_FOR_APPLICABILITY_FLAG    ,--Bug # 4225216
         APPLICABLE_BY_DEFAULT_FLAG              --Bug # 4905771
)

SELECT
         l_TAX                            ,
   EFFECTIVE_FROM                   ,
   EFFECTIVE_TO                     ,
   l_TAX_REGIME_CODE                ,
   (select tax_type_code
      from
        (select

                      codes.tax_type         tax_type_code,
          rates.tax_regime_code  tax_regime_code,
          rates.tax              tax,
          rates.content_owner_id content_owner_id
         from   zx_rates_b rates, ap_tax_codes_all codes
         where  codes.tax_id = rates.source_id  --ID Clash
         AND rates.tax_class = 'INPUT'
         AND rates.record_type_code = 'MIGRATED'
         group  by rates.tax_regime_code, rates.tax, rates.content_owner_id, codes.tax_type
        )
      where   tax_regime_code = l_tax_regime_code
      and     tax = l_tax
      and     content_owner_id = l_content_owner_id
      AND ROWNUM = 1
   )          ,--TAX_TYPE_CODE  Refer Bug 3922583
  ALLOW_MANUAL_ENTRY_FLAG           ,--ALLOW_MANUAL_ENTRY_FLAG
  ALLOW_TAX_OVERRIDE_FLAG           ,--ALLOW_TAX_OVERRIDE_FLAG
   NULL                             ,--MIN_TXBL_BSIS_THRSHLD
   NULL                             ,--MAX_TXBL_BSIS_THRSHLD
   NULL                             ,--MIN_TAX_RATE_THRSHLD
   NULL                             ,--MAX_TAX_RATE_THRSHLD
   NULL                             ,--MIN_TAX_AMT_THRSHLD
   NULL                             ,--MAX_TAX_AMT_THRSHLD
   NULL                             ,--TAX_COMPOUNDING_PRECEDENCE
   NULL                             ,--PERIOD_SET_NAME
   -- Bug 4539221
         -- Deriving exchange_rate_type
         -- If default_exchange_rate_type is NULL use most frequently
         -- used conversion_type from gl_daily_rates.
        -- CASE WHEN DEFAULT_EXCHANGE_RATE_TYPE IS NULL
        --   THEN
  --  'Corporate'
        --   ELSE
             -- Bug 6006519/5654551, 'User' is not a valid exchange rate type
         --     DECODE(DEFAULT_EXCHANGE_RATE_TYPE,
         --    'User', 'Corporate',
         --     DEFAULT_EXCHANGE_RATE_TYPE)
        -- END                              ,--EXCHANGE_RATE_TYPE
   NULL          , -- EXCHANGE_RATE_TYPE
   TAX_CURRENCY_CODE                ,
   TAX_PRECISION                    ,
   MINIMUM_ACCOUNTABLE_UNIT         ,
   ROUNDING_RULE_CODE               ,
   'N'                              ,--TAX_STATUS_RULE_FLAG Bug 5260722
   'N'                              ,--TAX_RATE_RULE_FLAG
  'SHIP_FROM'                       ,--DEF_PLACE_OF_SUPPLY_TYPE_CODE
  'N'                               ,--PLACE_OF_SUPPLY_RULE_FLAG
  'N'                               ,--DIRECT_RATE_RULE_FLAG -- Bug 5090631
  'N'                               ,--APPLICABILITY_RULE_FLAG
  'N'                               ,--TAX_CALC_RULE_FLAG
  'N'                               ,--TXBL_BSIS_THRSHLD_FLAG
  'N'                               ,--TAX_RATE_THRSHLD_FLAG
  'N'                               ,--TAX_AMT_THRSHLD_FLAG
  'N'                               ,--TAXABLE_BASIS_RULE_FLAG
   DEF_INCLUSIVE_TAX_FLAG           ,
   NULL                             ,--THRSHLD_GROUPING_LVL_CODE
  'N'                               ,--HAS_OTHER_JURISDICTIONS_FLAG
  'N'                               ,--ALLOW_EXEMPTIONS_FLAG
  'N'                               ,--ALLOW_EXCEPTIONS_FLAG
   ALLOW_RECOVERABILITY_FLAG        ,
   DEF_TAX_CALC_FORMULA             ,
   TAX_INCLUSIVE_OVERRIDE_FLAG      ,
   DEF_TAXABLE_BASIS_FORMULA        ,
  'SHIP_FROM_PARTY'                 ,--DEF_REGISTR_PARTY_TYPE_CODE
  'N'                               ,--REGISTRATION_TYPE_RULE_FLAG
    'N'                               ,--REPORTING_ONLY_FLAG
  'N'                               ,--AUTO_PRVN_FLAG
  CASE WHEN
    EXISTS (select  1 from  zx_rates_b active_rate
      where active_rate.TAX = l_TAX
      and   active_rate.TAX_REGIME_CODE = l_TAX_REGIME_CODE
      and   sysdate between active_rate.effective_from
      and   nvl(active_rate.effective_to,sysdate))
       THEN 'Y'
       ELSE 'N'
  END           ,--LIVE_FOR_PROCESSING_FLAG . Bug 3618167

  'N'                               ,--HAS_DETAIL_TB_THRSHLD_FLAG
  'N'                               ,--HAS_TAX_DET_DATE_RULE_FLAG
  'N'                               ,--HAS_EXCH_RATE_DATE_RULE_FLAG
  'N'                               ,--HAS_TAX_POINT_DATE_RULE_FLAG
  'N'                               ,--PRINT_ON_INVOICE_FLAG
        'N'                               ,--USE_LEGAL_MSG_FLAG
  'N'                               ,--CALC_ONLY_FLAG
       --BugFix 3485851(3480468)
         DECODE(ALLOW_RECOVERABILITY_FLAG,'Y',
                'STANDARD',NULL)          ,--PRIMARY_RECOVERY_TYPE_CODE
  'N'                               ,--PRIMARY_REC_TYPE_RULE_FLAG
   NULL                             ,--SECONDARY_RECOVERY_TYPE_CODE
  'N'                               ,--SECONDARY_REC_TYPE_RULE_FLAG
  'N'                               ,--PRIMARY_REC_RATE_DET_RULE_FLAG
  'N'                               ,--SEC_REC_RATE_DET_RULE_FLAG
   OFFSET_TAX_FLAG                  ,
  'N'                               ,--RECOVERY_RATE_OVERRIDE_FLAG
   NULL                             ,--ZONE_GEOGRAPHY_TYPE
  'N'                               ,--REGN_NUM_SAME_AS_LE_FLAG
   DEF_REC_SETTLEMENT_OPTION_CODE   ,
   'MIGRATED'                       ,--RECORD_TYPE_CODE
   'N'                              ,--ALLOW_ROUNDING_OVERRIDE_FLAG
       --BugFix 3493419
         DECODE(l_CONTENT_OWNER_ID,
                (select min(CONTENT_OWNER_ID)
                from   zx_rates_b
                where  tax = l_TAX
                and    tax_regime_code  = l_TAX_REGIME_CODE
                and    RECORD_TYPE_CODE = 'MIGRATED'),
                'Y',
                'N')                      ,--SOURCE_TAX_FLAG
        'N'                               ,--SPECIAL_INCL_TAX_FLAG
        'N'                               ,--ALLOW_DUP_REGN_NUM_FLAG
   NULL                             ,--ATTRIBUTE1
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,--ATTRIBUTE_CATEGORY
   NULL                             ,--PARENT_GEOGRAPHY_TYPE
   NULL                             ,--PARENT_GEOGRAPHY_ID
  'N'                               ,--ALLOW_MASS_CREATE_FLAG
  'P'                               ,--APPLIED_AMT_HANDLING_FLAG
   ZX_TAXES_B_S.NEXTVAL             ,--TAX_ID
   l_CONTENT_OWNER_ID                 ,
   REP_TAX_AUTHORITY_ID             ,
   COLL_TAX_AUTHORITY_ID            ,
   NULL                             ,--THRSHLD_CHK_TMPLT_CODE
         DEF_PRIMARY_REC_RATE_CODE        ,
         NULL                             ,
         fnd_global.user_id               ,
   SYSDATE                          ,
   fnd_global.user_id               ,
   SYSDATE                          ,
   fnd_global.conc_login_id         ,
   fnd_global.conc_request_id       ,--Request Id
   fnd_global.prog_appl_id          ,--Program Application ID
   fnd_global.conc_program_id       ,--Program Id
   fnd_global.conc_login_id         ,--Program Login ID
         NULL                             ,--OVERRIDE_GEOGRAPHY_TYPE
   1          ,
   DECODE((select tax_type_code
      from
        (select

                      codes.tax_type         tax_type_code,
          rates.tax_regime_code  tax_regime_code,
          rates.tax              tax,
          rates.content_owner_id content_owner_id
         from   zx_rates_b rates, ap_tax_codes_all codes
         where  codes.tax_id = rates.source_id  --ID Clash
         AND rates.tax_class = 'INPUT'
         AND rates.record_type_code = 'MIGRATED'
         group  by rates.tax_regime_code, rates.tax, rates.content_owner_id, codes.tax_type
        )
      where   tax_regime_code = l_tax_regime_code
      and     tax = l_tax
      and     content_owner_id = l_content_owner_id
          AND ROWNUM = 1
   )  ,'USE','N','Y')
                               , --LIVE_FOR_APPLICABILITY_FLAG
         'N'                                      --APPLICABLE_BY_DEFAULT_FLAG
FROM
(
    SELECT
          RATES.TAX_REGIME_CODE                 l_TAX_REGIME_CODE,
          RATES.TAX                             l_TAX,
          ptp.party_tax_profile_id              l_CONTENT_OWNER_ID,
          DECODE(CODES.TAX_TYPE,
                 'OFFSET','Y',
                 'N')                           OFFSET_TAX_FLAG,
          DECODE(CODES.TAX_TYPE,
                 'OFFSET','N',
                 'Y')                           ALLOW_MANUAL_ENTRY_FLAG,
    DECODE(CODES.TAX_TYPE,
                 'OFFSET','N',
                 'Y')        ALLOW_TAX_OVERRIDE_FLAG,
    SOB.CURRENCY_CODE                     TAX_CURRENCY_CODE,
          FSP.PRECISION                         TAX_PRECISION,
          FSP.MINIMUM_ACCOUNTABLE_UNIT          MINIMUM_ACCOUNTABLE_UNIT,
          DECODE(FSP.TAX_ROUNDING_RULE,
                  'D', 'DOWN',
                  'U', 'UP',
                  'N', 'NEAREST')                 ROUNDING_RULE_CODE,
          ASP.AMOUNT_INCLUDES_TAX_FLAG          DEF_INCLUSIVE_TAX_FLAG,
        --BugFix 3480468
          DECODE(NVL(FSP.non_recoverable_tax_flag, 'N'),
                'Y',
                'STANDARD-'||nvl(FSP.default_recovery_rate,0),
                 NULL)                          DEF_PRIMARY_REC_RATE_CODE,
          nvl(FSP.non_recoverable_tax_flag,
              'N')                              ALLOW_RECOVERABILITY_FLAG,
         'STANDARD_TC'                          DEF_TAX_CALC_FORMULA,
                                              --Review1 changes
          ASP.amount_includes_tax_override      TAX_INCLUSIVE_OVERRIDE_FLAG,
         'STANDARD_TB'                          DEF_TAXABLE_BASIS_FORMULA,
                                              --Review1 changes
          NULL                                  DEF_REC_SETTLEMENT_OPTION_CODE,
          NULL                                  REP_TAX_AUTHORITY_ID,
          NULL                                  COLL_TAX_AUTHORITY_ID,
          min(RATES.EFFECTIVE_FROM)             EFFECTIVE_FROM,
          NULL                                  EFFECTIVE_TO,
          -- Bug 4539221
          -- Bug 6006519/5654551, 'User' is not a valid exchange rate type
       --   DECODE(ASP.DEFAULT_EXCHANGE_RATE_TYPE,'User','Corporate',ASP.DEFAULT_EXCHANGE_RATE_TYPE)        DEFAULT_EXCHANGE_RATE_TYPE
    NULL          DEFAULT_EXCHANGE_RATE_TYPE
FROM
          ZX_RATES_B RATES,
          AP_TAX_CODES_ALL CODES,
          GL_SETS_OF_BOOKS SOB,
          AP_SYSTEM_PARAMETERS_ALL ASP,
          FINANCIALS_SYSTEM_PARAMS_ALL FSP,
          zx_party_tax_profile ptp
WHERE
          CODES.TAX_ID           =  RATES.SOURCE_ID --No need for the nvl check
AND       RATES.TAX_CLASS        = 'INPUT'          --Creating only INPUT Taxes
AND       CODES.ORG_ID           =  PTP.PARTY_ID
AND       PTP.PARTY_TYPE_CODE    = 'OU'
AND       codes.org_id = fsp.org_id
AND       codes.org_id = asp.org_id
AND       FSP.SET_OF_BOOKS_ID    =  SOB.SET_OF_BOOKS_ID
AND       RATES.RECORD_TYPE_CODE = 'MIGRATED'
--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
AND  not exists (select 1 from zx_taxes_b
                 where  tax_regime_code = rates.tax_regime_code
                 and    tax             = rates.tax
                 and    content_owner_id= rates.content_owner_id
                )
GROUP BY
          RATES.TAX_REGIME_CODE                 ,
          RATES.TAX                             ,
          ptp.party_tax_profile_id              ,
          DECODE(CODES.TAX_TYPE,
                 'OFFSET','Y',
                 'N')                           ,
          DECODE(CODES.TAX_TYPE,
                 'OFFSET','N',
                 'Y')                           ,
    DECODE(CODES.TAX_TYPE,
                 'OFFSET','N',
                 'Y')        ,
          SOB.CURRENCY_CODE                     ,
          FSP.PRECISION                         ,
          FSP.MINIMUM_ACCOUNTABLE_UNIT          ,
          DECODE(FSP.TAX_ROUNDING_RULE,
                   'D', 'DOWN',
                   'U', 'UP',
                   'N', 'NEAREST')                ,
          ASP.AMOUNT_INCLUDES_TAX_FLAG          ,
          DECODE(NVL(FSP.non_recoverable_tax_flag, 'N'),
                'Y',
                'STANDARD-'||nvl(FSP.default_recovery_rate,0),
                 NULL)                          ,
          nvl(FSP.non_recoverable_tax_flag,
              'N')                              ,
          NULL                                  ,
          ASP.amount_includes_tax_override      ,
          NULL,
         -- Bug 6006519/5654551, 'User' is not a valid exchange rate type
         -- decode(ASP.DEFAULT_EXCHANGE_RATE_TYPE,'User','Corporate',ASP.DEFAULT_EXCHANGE_RATE_TYPE)
         NULL

);
ELSE

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
       --BugFix 3493419
     SOURCE_TAX_FLAG                        ,
     SPECIAL_INCLUSIVE_TAX_FLAG             ,
     ALLOW_DUP_REGN_NUM_FLAG                ,
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
       --BugFix 3480468
     DEF_PRIMARY_REC_RATE_CODE              ,
     DEF_SECONDARY_REC_RATE_CODE            ,
      CREATED_BY                       ,
   CREATION_DATE                          ,
   LAST_UPDATED_BY                        ,
   LAST_UPDATE_DATE                       ,
   LAST_UPDATE_LOGIN                      ,
   REQUEST_ID                             ,
   PROGRAM_APPLICATION_ID                 ,
   PROGRAM_ID                             ,
   PROGRAM_LOGIN_ID                       ,
     OVERRIDE_GEOGRAPHY_TYPE    ,
   OBJECT_VERSION_NUMBER      ,
   LIVE_FOR_APPLICABILITY_FLAG    ,--Bug # 4225216
         APPLICABLE_BY_DEFAULT_FLAG              --Bug # 4905771
)

SELECT
         l_TAX                            ,
   EFFECTIVE_FROM                   ,
   EFFECTIVE_TO                     ,
   l_TAX_REGIME_CODE                ,
   (select tax_type_code
      from
        (select

                      codes.tax_type         tax_type_code,
          rates.tax_regime_code  tax_regime_code,
          rates.tax              tax,
          rates.content_owner_id content_owner_id
         from   zx_rates_b rates, ap_tax_codes_all codes
         where  codes.tax_id = rates.source_id  --ID Clash
         AND rates.tax_class = 'INPUT'
         AND rates.record_type_code = 'MIGRATED'
         group  by rates.tax_regime_code, rates.tax, rates.content_owner_id, codes.tax_type
        )
      where   tax_regime_code = l_tax_regime_code
      and     tax = l_tax
      and     content_owner_id = l_content_owner_id
      AND ROWNUM = 1
   )          ,--TAX_TYPE_CODE  Refer Bug 3922583
  ALLOW_MANUAL_ENTRY_FLAG           ,--ALLOW_MANUAL_ENTRY_FLAG
  ALLOW_TAX_OVERRIDE_FLAG           ,--ALLOW_TAX_OVERRIDE_FLAG
   NULL                             ,--MIN_TXBL_BSIS_THRSHLD
   NULL                             ,--MAX_TXBL_BSIS_THRSHLD
   NULL                             ,--MIN_TAX_RATE_THRSHLD
   NULL                             ,--MAX_TAX_RATE_THRSHLD
   NULL                             ,--MIN_TAX_AMT_THRSHLD
   NULL                             ,--MAX_TAX_AMT_THRSHLD
   NULL                             ,--TAX_COMPOUNDING_PRECEDENCE
   NULL                             ,--PERIOD_SET_NAME
   -- Bug 4539221
         -- Deriving exchange_rate_type
         -- If default_exchange_rate_type is NULL use most frequently
         -- used conversion_type from gl_daily_rates.
       --  CASE WHEN DEFAULT_EXCHANGE_RATE_TYPE IS NULL
       --    THEN
       --  'Corporate'
       --    ELSE
           --Bug 6006519/5654551, 'User' is not a valid exchange rate type
        --   DECODE(DEFAULT_EXCHANGE_RATE_TYPE,
        --  'User', 'Corporate',
        --   DEFAULT_EXCHANGE_RATE_TYPE)
       --  END                              ,--EXCHANGE_RATE_TYPE
   NULL          , -- EXCHANGE_RATE_TYPE
   TAX_CURRENCY_CODE                ,
   TAX_PRECISION                    ,
   MINIMUM_ACCOUNTABLE_UNIT         ,
   ROUNDING_RULE_CODE               ,
   'N'                              ,--TAX_STATUS_RULE_FLAG Bug 5260722
   'N'                              ,--TAX_RATE_RULE_FLAG
  'SHIP_FROM'                       ,--DEF_PLACE_OF_SUPPLY_TYPE_CODE
  'N'                               ,--PLACE_OF_SUPPLY_RULE_FLAG
  'N'                               ,--DIRECT_RATE_RULE_FLAG -- Bug 5090631
  'N'                               ,--APPLICABILITY_RULE_FLAG
  'N'                               ,--TAX_CALC_RULE_FLAG
  'N'                               ,--TXBL_BSIS_THRSHLD_FLAG
  'N'                               ,--TAX_RATE_THRSHLD_FLAG
  'N'                               ,--TAX_AMT_THRSHLD_FLAG
  'N'                               ,--TAXABLE_BASIS_RULE_FLAG
   DEF_INCLUSIVE_TAX_FLAG           ,
   NULL                             ,--THRSHLD_GROUPING_LVL_CODE
  'N'                               ,--HAS_OTHER_JURISDICTIONS_FLAG
  'N'                               ,--ALLOW_EXEMPTIONS_FLAG
  'N'                               ,--ALLOW_EXCEPTIONS_FLAG
   ALLOW_RECOVERABILITY_FLAG        ,
   DEF_TAX_CALC_FORMULA             ,
   TAX_INCLUSIVE_OVERRIDE_FLAG      ,
   DEF_TAXABLE_BASIS_FORMULA        ,
  'SHIP_FROM_PARTY'                 ,--DEF_REGISTR_PARTY_TYPE_CODE
  'N'                               ,--REGISTRATION_TYPE_RULE_FLAG
    'N'                               ,--REPORTING_ONLY_FLAG
  'N'                               ,--AUTO_PRVN_FLAG
  CASE WHEN
    EXISTS (select  1 from  zx_rates_b active_rate
      where active_rate.TAX = l_TAX
      and   active_rate.TAX_REGIME_CODE = l_TAX_REGIME_CODE
      and   sysdate between active_rate.effective_from
      and   nvl(active_rate.effective_to,sysdate))
       THEN 'Y'
       ELSE 'N'
  END           ,--LIVE_FOR_PROCESSING_FLAG . Bug 3618167

  'N'                               ,--HAS_DETAIL_TB_THRSHLD_FLAG
  'N'                               ,--HAS_TAX_DET_DATE_RULE_FLAG
  'N'                               ,--HAS_EXCH_RATE_DATE_RULE_FLAG
  'N'                               ,--HAS_TAX_POINT_DATE_RULE_FLAG
  'N'                               ,--PRINT_ON_INVOICE_FLAG
        'N'                               ,--USE_LEGAL_MSG_FLAG
  'N'                               ,--CALC_ONLY_FLAG
       --BugFix 3485851(3480468)
         DECODE(ALLOW_RECOVERABILITY_FLAG,'Y',
                'STANDARD',NULL)          ,--PRIMARY_RECOVERY_TYPE_CODE
  'N'                               ,--PRIMARY_REC_TYPE_RULE_FLAG
   NULL                             ,--SECONDARY_RECOVERY_TYPE_CODE
  'N'                               ,--SECONDARY_REC_TYPE_RULE_FLAG
  'N'                               ,--PRIMARY_REC_RATE_DET_RULE_FLAG
  'N'                               ,--SEC_REC_RATE_DET_RULE_FLAG
   OFFSET_TAX_FLAG                  ,
  'N'                               ,--RECOVERY_RATE_OVERRIDE_FLAG
   NULL                             ,--ZONE_GEOGRAPHY_TYPE
  'N'                               ,--REGN_NUM_SAME_AS_LE_FLAG
   DEF_REC_SETTLEMENT_OPTION_CODE   ,
   'MIGRATED'                       ,--RECORD_TYPE_CODE
   'N'                              ,--ALLOW_ROUNDING_OVERRIDE_FLAG
       --BugFix 3493419
         DECODE(l_CONTENT_OWNER_ID,
                (select min(CONTENT_OWNER_ID)
                from   zx_rates_b
                where  tax = l_TAX
                and    tax_regime_code  = l_TAX_REGIME_CODE
                and    RECORD_TYPE_CODE = 'MIGRATED'),
                'Y',
                'N')                      ,--SOURCE_TAX_FLAG
        'N'                               ,--SPECIAL_INCL_TAX_FLAG
        'N'                               ,--ALLOW_DUP_REGN_NUM_FLAG
   NULL                             ,--ATTRIBUTE1
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,--ATTRIBUTE_CATEGORY
   NULL                             ,--PARENT_GEOGRAPHY_TYPE
   NULL                             ,--PARENT_GEOGRAPHY_ID
  'N'                               ,--ALLOW_MASS_CREATE_FLAG
  'P'                               ,--APPLIED_AMT_HANDLING_FLAG
   ZX_TAXES_B_S.NEXTVAL             ,--TAX_ID
   l_CONTENT_OWNER_ID                 ,
   REP_TAX_AUTHORITY_ID             ,
   COLL_TAX_AUTHORITY_ID            ,
   NULL                             ,--THRSHLD_CHK_TMPLT_CODE
         DEF_PRIMARY_REC_RATE_CODE        ,
         NULL                             ,
         fnd_global.user_id               ,
   SYSDATE                          ,
   fnd_global.user_id               ,
   SYSDATE                          ,
   fnd_global.conc_login_id         ,
   fnd_global.conc_request_id       ,--Request Id
   fnd_global.prog_appl_id          ,--Program Application ID
   fnd_global.conc_program_id       ,--Program Id
   fnd_global.conc_login_id         ,--Program Login ID
         NULL                             ,--OVERRIDE_GEOGRAPHY_TYPE
   1          ,
   DECODE((select tax_type_code
      from
        (select

                      codes.tax_type         tax_type_code,
          rates.tax_regime_code  tax_regime_code,
          rates.tax              tax,
          rates.content_owner_id content_owner_id
         from   zx_rates_b rates, ap_tax_codes_all codes
         where  codes.tax_id = rates.source_id  --ID Clash
         AND rates.tax_class = 'INPUT'
         AND rates.record_type_code = 'MIGRATED'
         group  by rates.tax_regime_code, rates.tax, rates.content_owner_id, codes.tax_type
        )
      where   tax_regime_code = l_tax_regime_code
      and     tax = l_tax
      and     content_owner_id = l_content_owner_id
          AND ROWNUM = 1
   )  ,'USE','N','Y')
                               , --LIVE_FOR_APPLICABILITY_FLAG
         'N'                                      --APPLICABLE_BY_DEFAULT_FLAG
FROM
(
    SELECT
          RATES.TAX_REGIME_CODE                 l_TAX_REGIME_CODE,
          RATES.TAX                             l_TAX,
          ptp.party_tax_profile_id              l_CONTENT_OWNER_ID,
          DECODE(CODES.TAX_TYPE,
                 'OFFSET','Y',
                 'N')                           OFFSET_TAX_FLAG,
          DECODE(CODES.TAX_TYPE,
                 'OFFSET','N',
                 'Y')                           ALLOW_MANUAL_ENTRY_FLAG,
    DECODE(CODES.TAX_TYPE,
                 'OFFSET','N',
                 'Y')        ALLOW_TAX_OVERRIDE_FLAG,
    SOB.CURRENCY_CODE                     TAX_CURRENCY_CODE,
          FSP.PRECISION                         TAX_PRECISION,
          FSP.MINIMUM_ACCOUNTABLE_UNIT          MINIMUM_ACCOUNTABLE_UNIT,
          DECODE(FSP.TAX_ROUNDING_RULE,
                  'D', 'DOWN',
                  'U', 'UP',
                  'N', 'NEAREST')                 ROUNDING_RULE_CODE,
          ASP.AMOUNT_INCLUDES_TAX_FLAG          DEF_INCLUSIVE_TAX_FLAG,
        --BugFix 3480468
          DECODE(NVL(FSP.non_recoverable_tax_flag, 'N'),
                'Y',
                'STANDARD-'||nvl(FSP.default_recovery_rate,0),
                 NULL)                          DEF_PRIMARY_REC_RATE_CODE,
          nvl(FSP.non_recoverable_tax_flag,
              'N')                              ALLOW_RECOVERABILITY_FLAG,
         'STANDARD_TC'                          DEF_TAX_CALC_FORMULA,
                                              --Review1 changes
          ASP.amount_includes_tax_override      TAX_INCLUSIVE_OVERRIDE_FLAG,
         'STANDARD_TB'                          DEF_TAXABLE_BASIS_FORMULA,
                                              --Review1 changes
          NULL                                  DEF_REC_SETTLEMENT_OPTION_CODE,
          NULL                                  REP_TAX_AUTHORITY_ID,
          NULL                                  COLL_TAX_AUTHORITY_ID,
          min(RATES.EFFECTIVE_FROM)             EFFECTIVE_FROM,
          NULL                                  EFFECTIVE_TO,
          -- Bug 4539221
    -- Bug 6006519/5654551, 'User' is not a valid exchange rate type
        --  DECODE(ASP.DEFAULT_EXCHANGE_RATE_TYPE,'User','Corporate',ASP.DEFAULT_EXCHANGE_RATE_TYPE)        DEFAULT_EXCHANGE_RATE_TYPE
   NULL          DEFAULT_EXCHANGE_RATE_TYPE
FROM
          ZX_RATES_B RATES,
          AP_TAX_CODES_ALL CODES,
          GL_SETS_OF_BOOKS SOB,
          AP_SYSTEM_PARAMETERS_ALL ASP,
          FINANCIALS_SYSTEM_PARAMS_ALL FSP,
          zx_party_tax_profile ptp
WHERE
          CODES.TAX_ID           =  RATES.SOURCE_ID --No need for the nvl check
AND       RATES.TAX_CLASS        = 'INPUT'          --Creating only INPUT Taxes
AND       CODES.ORG_ID           =  PTP.PARTY_ID
AND       PTP.PARTY_TYPE_CODE    = 'OU'
AND       codes.org_id = l_org_id
AND       codes.org_id = fsp.org_id
AND       codes.org_id = asp.org_id
AND       FSP.SET_OF_BOOKS_ID    =  SOB.SET_OF_BOOKS_ID
AND       RATES.RECORD_TYPE_CODE = 'MIGRATED'
--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
AND  not exists (select 1 from zx_taxes_b
                 where  tax_regime_code = rates.tax_regime_code
                 and    tax             = rates.tax
                 and    content_owner_id= rates.content_owner_id
                )
GROUP BY
          RATES.TAX_REGIME_CODE                 ,
          RATES.TAX                             ,
          ptp.party_tax_profile_id              ,
          DECODE(CODES.TAX_TYPE,
                 'OFFSET','Y',
                 'N')                           ,
          DECODE(CODES.TAX_TYPE,
                 'OFFSET','N',
                 'Y')                           ,
    DECODE(CODES.TAX_TYPE,
                 'OFFSET','N',
                 'Y')        ,
          SOB.CURRENCY_CODE                     ,
          FSP.PRECISION                         ,
          FSP.MINIMUM_ACCOUNTABLE_UNIT          ,
          DECODE(FSP.TAX_ROUNDING_RULE,
                   'D', 'DOWN',
                   'U', 'UP',
                   'N', 'NEAREST')                ,
          ASP.AMOUNT_INCLUDES_TAX_FLAG          ,
          DECODE(NVL(FSP.non_recoverable_tax_flag, 'N'),
                'Y',
                'STANDARD-'||nvl(FSP.default_recovery_rate,0),
                 NULL)                          ,
          nvl(FSP.non_recoverable_tax_flag,
              'N')                              ,
          NULL                                  ,
          ASP.amount_includes_tax_override      ,
          NULL,
   -- Bug 6006519/5654551, 'User' is not a valid exchange rate type
        --  decode(ASP.DEFAULT_EXCHANGE_RATE_TYPE,'User','Corporate',ASP.DEFAULT_EXCHANGE_RATE_TYPE)
    NULL

);

END IF;

EXCEPTION WHEN OTHERS THEN
  NULL;
END;
--For Unused JGZZ_TAX_ORIGIN,JECH_VAT_REGIME lookup code

BEGIN

IF L_MULTI_ORG_FLAG = 'Y'
THEN

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
       --BugFix 3493419
         SOURCE_TAX_FLAG                        ,
         SPECIAL_INCLUSIVE_TAX_FLAG             ,
         ALLOW_DUP_REGN_NUM_FLAG                ,
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
       --BugFix 3480468
         DEF_PRIMARY_REC_RATE_CODE              ,
         DEF_SECONDARY_REC_RATE_CODE            ,
      CREATED_BY                       ,
   CREATION_DATE                          ,
   LAST_UPDATED_BY                        ,
   LAST_UPDATE_DATE                       ,
   LAST_UPDATE_LOGIN                      ,
   REQUEST_ID                             ,
   PROGRAM_APPLICATION_ID                 ,
   PROGRAM_ID                             ,
   PROGRAM_LOGIN_ID                       ,
         OVERRIDE_GEOGRAPHY_TYPE           ,
   OBJECT_VERSION_NUMBER           ,
   LIVE_FOR_APPLICABILITY_FLAG    ,--Bug # 4225216
         APPLICABLE_BY_DEFAULT_FLAG             --Bug # 4905771
)

SELECT
     lookups.lookup_code              ,--TAX
   EFFECTIVE_FROM                   ,
   EFFECTIVE_TO                     ,
   l_TAX_REGIME_CODE                ,
  DECODE(lookup_type,
  'JLCL_TAX_CODE_CLASS',
  lookup_code,
    (select tax_type_code
    from
    (select codes.tax_type         tax_type_code,
      rates.tax_regime_code  tax_regime_code,
      rates.tax              tax,
      rates.content_owner_id content_owner_id
    from   zx_rates_b rates, ap_tax_codes_all codes
    where  codes.tax_id = nvl(rates.source_id, rates.tax_rate_id)   --ID Clash
    group  by rates.tax_regime_code, rates.tax, rates.content_owner_id,codes.tax_type
    )
    where   tax_regime_code = l_tax_regime_code
    and     tax = l_tax
    and     content_owner_id = l_content_owner_id
    )  )                      ,--TAX_TYPE_CODE Refer Bug 3922583
  ALLOW_MANUAL_ENTRY_FLAG           ,--ALLOW_MANUAL_ENTRY_FLAG
  ALLOW_TAX_OVERRIDE_FLAG           ,--ALLOW_TAX_OVERRIDE_FLAG
   NULL                             ,--MIN_TXBL_BSIS_THRSHLD
   NULL                             ,--MAX_TXBL_BSIS_THRSHLD
   NULL                             ,--MIN_TAX_RATE_THRSHLD
   NULL                             ,--MAX_TAX_RATE_THRSHLD
   NULL                             ,--MIN_TAX_AMT_THRSHLD
   NULL                             ,--MAX_TAX_AMT_THRSHLD
   NULL                             ,--TAX_COMPOUNDING_PRECEDENCE
   NULL                             ,--PERIOD_SET_NAME
   -- Bug 4539221
         -- Deriving exchange_rate_type
         -- If default_exchange_rate_type is NULL use most frequently
         -- used conversion_type from gl_daily_rates.
        -- CASE WHEN DEFAULT_EXCHANGE_RATE_TYPE IS NULL
        --   THEN
  --     'Corporate'
        --   ELSE
           --Bug 6006519/5654551, 'User' is not a valid exchange rate type
  --   DECODE(DEFAULT_EXCHANGE_RATE_TYPE,
  --       'User', 'Corporate',
        --  DEFAULT_EXCHANGE_RATE_TYPE)
       --  END                              ,--EXCHANGE_RATE_TYPE
   NULL          ,--EXCHANGE_RATE_TYPE
   TAX_CURRENCY_CODE                ,
   TAX_PRECISION                    ,
   MINIMUM_ACCOUNTABLE_UNIT         ,
   ROUNDING_RULE_CODE               ,
   'N'                              ,--TAX_STATUS_RULE_FLAG Bug 5260722
   'N'                              ,--TAX_RATE_RULE_FLAG
  'SHIP_FROM'                       ,--DEF_PLACE_OF_SUPPLY_TYPE_CODE
  'N'                               ,--PLACE_OF_SUPPLY_RULE_FLAG
  'Y'                               ,--DIRECT_RATE_RULE_FLAG
  'N'                               ,--APPLICABILITY_RULE_FLAG
  'N'                               ,--TAX_CALC_RULE_FLAG
  'N'                               ,--TXBL_BSIS_THRSHLD_FLAG
  'N'                               ,--TAX_RATE_THRSHLD_FLAG
  'N'                               ,--TAX_AMT_THRSHLD_FLAG
  'N'                               ,--TAXABLE_BASIS_RULE_FLAG
   DEF_INCLUSIVE_TAX_FLAG           ,
   NULL                             ,--THRSHLD_GROUPING_LVL_CODE
  'N'                               ,--HAS_OTHER_JURISDICTIONS_FLAG
  'N'                               ,--ALLOW_EXEMPTIONS_FLAG
  'N'                               ,--ALLOW_EXCEPTIONS_FLAG
   ALLOW_RECOVERABILITY_FLAG        ,
   DEF_TAX_CALC_FORMULA             ,
   TAX_INCLUSIVE_OVERRIDE_FLAG      ,
   DEF_TAXABLE_BASIS_FORMULA        ,
  'SHIP_FROM_PARTY'                 ,--DEF_REGISTR_PARTY_TYPE_CODE
  'N'                               ,--REGISTRATION_TYPE_RULE_FLAG
  'N'                               ,--REPORTING_ONLY_FLAG
  'N'                               ,--AUTO_PRVN_FLAG
  CASE WHEN
    EXISTS (select  1 from  zx_rates_b active_rate
      where active_rate.TAX = lookups.lookup_code
      and   active_rate.TAX_REGIME_CODE = l_TAX_REGIME_CODE
      and   sysdate between active_rate.effective_from
      and   nvl(active_rate.effective_to,sysdate))
       THEN 'Y'
       ELSE 'N'
  END           ,--LIVE_FOR_PROCESSING_FLAG . Bug 3618167
  'N'                               ,--HAS_DETAIL_TB_THRSHLD_FLAG
  'N'                               ,--HAS_TAX_DET_DATE_RULE_FLAG
  'N'                               ,--HAS_EXCH_RATE_DATE_RULE_FLAG
  'N'                               ,--HAS_TAX_POINT_DATE_RULE_FLAG
  'N'                               ,--PRINT_ON_INVOICE_FLAG
  'N'                               ,--USE_LEGAL_MSG_FLAG
  'N'                               ,--CALC_ONLY_FLAG
       --BugFix 3485851(3480468)
         DECODE(ALLOW_RECOVERABILITY_FLAG,'Y',
          'STANDARD',NULL)          ,--PRIMARY_RECOVERY_TYPE_CODE
  'N'                               ,--PRIMARY_REC_TYPE_RULE_FLAG
   NULL                             ,--SECONDARY_RECOVERY_TYPE_CODE
  'N'                               ,--SECONDARY_REC_TYPE_RULE_FLAG
  'N'                               ,--PRIMARY_REC_RATE_DET_RULE_FLAG
  'N'                               ,--SEC_REC_RATE_DET_RULE_FLAG
   OFFSET_TAX_FLAG                  ,
   'N'                              ,--RECOVERY_RATE_OVERRIDE_FLAG
   NULL                             ,--ZONE_GEOGRAPHY_TYPE
  'N'                               ,--REGN_NUM_SAME_AS_LE_FLAG
   DEF_REC_SETTLEMENT_OPTION_CODE   ,
   'MIGRATED'                       ,--RECORD_TYPE_CODE
   'N'                              ,--ALLOW_ROUNDING_OVERRIDE_FLAG
       --BugFix 3493419
         DECODE(l_CONTENT_OWNER_ID,
                (select min(CONTENT_OWNER_ID)
                from   zx_rates_b
                where  tax = lookups.lookup_code
                and    tax_regime_code  = l_TAX_REGIME_CODE
                and    RECORD_TYPE_CODE = 'MIGRATED'),
                'Y',
                'N')                      ,--SOURCE_TAX_FLAG
         'N'                              ,--SPECIAL_INCL_TAX_FLAG
         'N'                              ,--ALLOW_DUP_REGN_NUM_FLAG
   NULL                             ,--ATTRIBUTE1
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,--ATTRIBUTE_CATEGORY
   NULL                             ,--PARENT_GEOGRAPHY_TYPE
   NULL                             ,--PARENT_GEOGRAPHY_ID
  'N'                               ,--ALLOW_MASS_CREATE_FLAG
  'P'                               ,--APPLIED_AMT_HANDLING_FLAG
   ZX_TAXES_B_S.NEXTVAL             ,--TAX_ID
   l_CONTENT_OWNER_ID               ,
   REP_TAX_AUTHORITY_ID             ,
   COLL_TAX_AUTHORITY_ID            ,
   NULL                             ,--THRSHLD_CHK_TMPLT_CODE
         DEF_PRIMARY_REC_RATE_CODE        ,
         NULL                             ,
         fnd_global.user_id               ,
   SYSDATE                          ,
   fnd_global.user_id               ,
   SYSDATE                          ,
   fnd_global.conc_login_id         ,
   fnd_global.conc_request_id       ,--Request Id
   fnd_global.prog_appl_id          ,--Program Application ID
   fnd_global.conc_program_id       ,--Program Id
   fnd_global.conc_login_id         ,--Program Login ID
         NULL                             ,--OVERRIDE_GEOGRAPHY_TYPE
   1          ,
    DECODE((select tax_type_code
      from
        (select

                      codes.tax_type         tax_type_code,
          rates.tax_regime_code  tax_regime_code,
          rates.tax              tax,
          rates.content_owner_id content_owner_id
         from   zx_rates_b rates, ap_tax_codes_all codes
         where  codes.tax_id = nvl(rates.source_id, rates.tax_rate_id)  --ID Clash
         group  by rates.tax_regime_code, rates.tax, rates.content_owner_id, codes.tax_type
        )
      where   tax_regime_code = l_tax_regime_code
      and     tax = l_tax
      and     content_owner_id = l_content_owner_id
   ),'USE','N','Y')     ,--LIVE_FOR_APPLICABILITY_FLAG
         'N'                        --APPLICABLE_BY_DEFAULT_FLAG
FROM
(
    SELECT
          RATES.TAX_REGIME_CODE                 l_TAX_REGIME_CODE,
          RATES.TAX                             l_TAX,
          ptp.party_tax_profile_id              l_CONTENT_OWNER_ID,
          DECODE(CODES.TAX_TYPE,
                 'OFFSET','Y',
                 'N')                           OFFSET_TAX_FLAG,
     DECODE(CODES.TAX_TYPE,
                 'OFFSET','N',
                 'Y')                           ALLOW_MANUAL_ENTRY_FLAG,
           DECODE(CODES.TAX_TYPE,
                 'OFFSET','N',
                 'Y')                           ALLOW_TAX_OVERRIDE_FLAG,

          SOB.CURRENCY_CODE                     TAX_CURRENCY_CODE,
          FSP.PRECISION                         TAX_PRECISION,
          FSP.MINIMUM_ACCOUNTABLE_UNIT          MINIMUM_ACCOUNTABLE_UNIT,
          DECODE(FSP.TAX_ROUNDING_RULE,
                   'D', 'DOWN',
                   'U', 'UP',
                   'N', 'NEAREST')              ROUNDING_RULE_CODE,
          ASP.AMOUNT_INCLUDES_TAX_FLAG          DEF_INCLUSIVE_TAX_FLAG,
        --BugFix 3480468
        DECODE(NVL(FSP.non_recoverable_tax_flag, 'N'),
              'Y',
              'STANDARD-'||nvl(FSP.default_recovery_rate,0),
              NULL)                             DEF_PRIMARY_REC_RATE_CODE,
          nvl(FSP.non_recoverable_tax_flag,
              'N')                              ALLOW_RECOVERABILITY_FLAG,
         'STANDARD_TC'                          DEF_TAX_CALC_FORMULA,
                                                --Review1 changes
          ASP.amount_includes_tax_override      TAX_INCLUSIVE_OVERRIDE_FLAG,
         'STANDARD_TB'                          DEF_TAXABLE_BASIS_FORMULA,
                                                --Review1 changes
          RATES.DEF_REC_SETTLEMENT_OPTION_CODE  DEF_REC_SETTLEMENT_OPTION_CODE,
          NULL                                  REP_TAX_AUTHORITY_ID,
          NULL                                  COLL_TAX_AUTHORITY_ID,
          min(RATES.EFFECTIVE_FROM)             EFFECTIVE_FROM,
          NULL                                  EFFECTIVE_TO,
          -- Bug 4539221
      -- Bug 6006519/5654551, 'User' is not a valid exchange rate type
         -- decode(ASP.DEFAULT_EXCHANGE_RATE_TYPE,'User','Corporate',ASP.DEFAULT_EXCHANGE_RATE_TYPE)        DEFAULT_EXCHANGE_RATE_TYPE
   NULL          DEFAULT_EXCHANGE_RATE_TYPE
FROM
          ZX_RATES_B RATES,
          AP_TAX_CODES_ALL CODES,
          GL_SETS_OF_BOOKS SOB,
          AP_SYSTEM_PARAMETERS_ALL ASP,
          FINANCIALS_SYSTEM_PARAMS_ALL FSP,
          zx_party_tax_profile ptp
WHERE
          CODES.TAX_ID           =  NVL(RATES.SOURCE_ID, RATES.TAX_RATE_ID)
AND       CODES.ORG_ID           =  PTP.PARTY_ID
AND       PTP.PARTY_TYPE_CODE    = 'OU'
AND   (   CODES.global_attribute_category = 'JE.CZ.APXTADTC.TAX_ORIGIN'
       OR CODES.global_attribute_category = 'JE.CH.APXTADTC.TAX_INFO'
                                             -- Review1 changes
       OR CODES.global_attribute_category = 'JL.CL.APXTADTC.AP_TAX_CODES'
                                             -- Review1 changes
      )
AND        codes.org_id = fsp.org_id
AND        codes.org_id = asp.org_id
AND       FSP.SET_OF_BOOKS_ID    = SOB.SET_OF_BOOKS_ID
AND       RATES.RECORD_TYPE_CODE = 'MIGRATED'
--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
AND  not exists (select 1 from zx_taxes_b
                 where  tax_regime_code = rates.tax_regime_code
                 and    tax             = rates.tax
                 and    content_owner_id= rates.content_owner_id
                )
GROUP BY
          RATES.TAX_REGIME_CODE                 ,
          RATES.TAX                             ,
          ptp.party_tax_profile_id              ,
          DECODE(CODES.TAX_TYPE,
                 'OFFSET','Y',
                 'N')                           ,
    DECODE(CODES.TAX_TYPE,
                 'OFFSET','N',
                 'Y')                           ,
    DECODE(CODES.TAX_TYPE,
                 'OFFSET','N',
                 'Y')        ,
          SOB.CURRENCY_CODE                     ,
          FSP.PRECISION                         ,
          FSP.MINIMUM_ACCOUNTABLE_UNIT          ,
          DECODE(FSP.TAX_ROUNDING_RULE,
                   'D', 'DOWN',
                   'U', 'UP',
                   'N', 'NEAREST')                 ,
          ASP.AMOUNT_INCLUDES_TAX_FLAG          ,
          DECODE(NVL(FSP.non_recoverable_tax_flag, 'N'),
                'Y',
                'STANDARD-'||nvl(FSP.default_recovery_rate,0),
                 NULL)                          ,
          nvl(FSP.non_recoverable_tax_flag,
              'N')                              ,
          NULL                                  ,
          ASP.amount_includes_tax_override      ,
          NULL                                  ,
          RATES.DEF_REC_SETTLEMENT_OPTION_CODE  ,
          NULL                                  ,
          NULL                                  ,
   -- Bug 6006519/5654551, 'User' is not a valid exchange rate type
   -- decode(ASP.DEFAULT_EXCHANGE_RATE_TYPE,'User','Corporate',ASP.DEFAULT_EXCHANGE_RATE_TYPE)
   NULL
) rates,
(
 SELECT
        lookup_code,lookup_type
  FROM
        FND_LOOKUPS
  WHERE
        lookup_type = 'JGZZ_TAX_ORIGIN'
  OR    lookup_type = 'JECH_VAT_REGIME'
  OR    lookup_type = 'JLCL_TAX_CODE_CLASS'
 MINUS
  SELECT
        lookup_code,lookup_type
  FROM
        ap_tax_codes_all,
        fnd_lookups
  WHERE
       (lookup_type = 'JGZZ_TAX_ORIGIN'
        AND  global_attribute_category = 'JE.CZ.APXTADTC.TAX_ORIGIN'
        AND  global_attribute1 = lookup_code) --Review1 changes
        OR
       (lookup_type = 'JECH_VAT_REGIME'
        AND  global_attribute_category = 'JE.CH.APXTADTC.TAX_INFO'
        AND  global_attribute1 = lookup_code) --Review1 changes
        OR
       (lookup_type = 'JLCL_TAX_CODE_CLASS'
        AND  global_attribute_category = 'JL.CL.APXTADTC.AP_TAX_CODES'
        AND  global_attribute1 = lookup_code) --Review1 changes
) lookups;
ELSE

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
       --BugFix 3493419
         SOURCE_TAX_FLAG                        ,
         SPECIAL_INCLUSIVE_TAX_FLAG             ,
         ALLOW_DUP_REGN_NUM_FLAG                ,
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
       --BugFix 3480468
         DEF_PRIMARY_REC_RATE_CODE              ,
         DEF_SECONDARY_REC_RATE_CODE            ,
      CREATED_BY                       ,
   CREATION_DATE                          ,
   LAST_UPDATED_BY                        ,
   LAST_UPDATE_DATE                       ,
   LAST_UPDATE_LOGIN                      ,
   REQUEST_ID                             ,
   PROGRAM_APPLICATION_ID                 ,
   PROGRAM_ID                             ,
   PROGRAM_LOGIN_ID                       ,
         OVERRIDE_GEOGRAPHY_TYPE           ,
   OBJECT_VERSION_NUMBER           ,
   LIVE_FOR_APPLICABILITY_FLAG    ,--Bug # 4225216
         APPLICABLE_BY_DEFAULT_FLAG             --Bug # 4905771
)

SELECT
     lookups.lookup_code              ,--TAX
   EFFECTIVE_FROM                   ,
   EFFECTIVE_TO                     ,
   l_TAX_REGIME_CODE                ,
  DECODE(lookup_type,
  'JLCL_TAX_CODE_CLASS',
  lookup_code,
    (select tax_type_code
    from
    (select codes.tax_type         tax_type_code,
      rates.tax_regime_code  tax_regime_code,
      rates.tax              tax,
      rates.content_owner_id content_owner_id
    from   zx_rates_b rates, ap_tax_codes_all codes
    where  codes.tax_id = nvl(rates.source_id, rates.tax_rate_id)   --ID Clash
    group  by rates.tax_regime_code, rates.tax, rates.content_owner_id,codes.tax_type
    )
    where   tax_regime_code = l_tax_regime_code
    and     tax = l_tax
    and     content_owner_id = l_content_owner_id
    )  )                      ,--TAX_TYPE_CODE Refer Bug 3922583
  ALLOW_MANUAL_ENTRY_FLAG           ,--ALLOW_MANUAL_ENTRY_FLAG
  ALLOW_TAX_OVERRIDE_FLAG           ,--ALLOW_TAX_OVERRIDE_FLAG
   NULL                             ,--MIN_TXBL_BSIS_THRSHLD
   NULL                             ,--MAX_TXBL_BSIS_THRSHLD
   NULL                             ,--MIN_TAX_RATE_THRSHLD
   NULL                             ,--MAX_TAX_RATE_THRSHLD
   NULL                             ,--MIN_TAX_AMT_THRSHLD
   NULL                             ,--MAX_TAX_AMT_THRSHLD
   NULL                             ,--TAX_COMPOUNDING_PRECEDENCE
   NULL                             ,--PERIOD_SET_NAME
   -- Bug 4539221
         -- Deriving exchange_rate_type
         -- If default_exchange_rate_type is NULL use most frequently
         -- used conversion_type from gl_daily_rates.
         --CASE WHEN DEFAULT_EXCHANGE_RATE_TYPE IS NULL
         --  THEN
   --    'Corporate'
         --  ELSE
           -- Bug 6006519/5654551, 'User' is not a valid exchange rate type
   --  DECODE(DEFAULT_EXCHANGE_RATE_TYPE,
    --     'User', 'Corporate',
          --     DEFAULT_EXCHANGE_RATE_TYPE)
        -- END                              ,--EXCHANGE_RATE_TYPE
   NULL          , --EXCHANGE_RATE_TYPE
   TAX_CURRENCY_CODE                ,
   TAX_PRECISION                    ,
   MINIMUM_ACCOUNTABLE_UNIT         ,
   ROUNDING_RULE_CODE               ,
   'N'                              ,--TAX_STATUS_RULE_FLAG Bug 5260722
   'N'                              ,--TAX_RATE_RULE_FLAG
  'SHIP_FROM'                       ,--DEF_PLACE_OF_SUPPLY_TYPE_CODE
  'N'                               ,--PLACE_OF_SUPPLY_RULE_FLAG
  'Y'                               ,--DIRECT_RATE_RULE_FLAG
  'N'                               ,--APPLICABILITY_RULE_FLAG
  'N'                               ,--TAX_CALC_RULE_FLAG
  'N'                               ,--TXBL_BSIS_THRSHLD_FLAG
  'N'                               ,--TAX_RATE_THRSHLD_FLAG
  'N'                               ,--TAX_AMT_THRSHLD_FLAG
  'N'                               ,--TAXABLE_BASIS_RULE_FLAG
   DEF_INCLUSIVE_TAX_FLAG           ,
   NULL                             ,--THRSHLD_GROUPING_LVL_CODE
  'N'                               ,--HAS_OTHER_JURISDICTIONS_FLAG
  'N'                               ,--ALLOW_EXEMPTIONS_FLAG
  'N'                               ,--ALLOW_EXCEPTIONS_FLAG
   ALLOW_RECOVERABILITY_FLAG        ,
   DEF_TAX_CALC_FORMULA             ,
   TAX_INCLUSIVE_OVERRIDE_FLAG      ,
   DEF_TAXABLE_BASIS_FORMULA        ,
  'SHIP_FROM_PARTY'                 ,--DEF_REGISTR_PARTY_TYPE_CODE
  'N'                               ,--REGISTRATION_TYPE_RULE_FLAG
  'N'                               ,--REPORTING_ONLY_FLAG
  'N'                               ,--AUTO_PRVN_FLAG
  CASE WHEN
    EXISTS (select  1 from  zx_rates_b active_rate
      where active_rate.TAX = lookups.lookup_code
      and   active_rate.TAX_REGIME_CODE = l_TAX_REGIME_CODE
      and   sysdate between active_rate.effective_from
      and   nvl(active_rate.effective_to,sysdate))
       THEN 'Y'
       ELSE 'N'
  END           ,--LIVE_FOR_PROCESSING_FLAG . Bug 3618167
  'N'                               ,--HAS_DETAIL_TB_THRSHLD_FLAG
  'N'                               ,--HAS_TAX_DET_DATE_RULE_FLAG
  'N'                               ,--HAS_EXCH_RATE_DATE_RULE_FLAG
  'N'                               ,--HAS_TAX_POINT_DATE_RULE_FLAG
  'N'                               ,--PRINT_ON_INVOICE_FLAG
  'N'                               ,--USE_LEGAL_MSG_FLAG
  'N'                               ,--CALC_ONLY_FLAG
       --BugFix 3485851(3480468)
         DECODE(ALLOW_RECOVERABILITY_FLAG,'Y',
          'STANDARD',NULL)          ,--PRIMARY_RECOVERY_TYPE_CODE
  'N'                               ,--PRIMARY_REC_TYPE_RULE_FLAG
   NULL                             ,--SECONDARY_RECOVERY_TYPE_CODE
  'N'                               ,--SECONDARY_REC_TYPE_RULE_FLAG
  'N'                               ,--PRIMARY_REC_RATE_DET_RULE_FLAG
  'N'                               ,--SEC_REC_RATE_DET_RULE_FLAG
   OFFSET_TAX_FLAG                  ,
   'N'                              ,--RECOVERY_RATE_OVERRIDE_FLAG
   NULL                             ,--ZONE_GEOGRAPHY_TYPE
  'N'                               ,--REGN_NUM_SAME_AS_LE_FLAG
   DEF_REC_SETTLEMENT_OPTION_CODE   ,
   'MIGRATED'                       ,--RECORD_TYPE_CODE
   'N'                              ,--ALLOW_ROUNDING_OVERRIDE_FLAG
       --BugFix 3493419
         DECODE(l_CONTENT_OWNER_ID,
                (select min(CONTENT_OWNER_ID)
                from   zx_rates_b
                where  tax = lookups.lookup_code
                and    tax_regime_code  = l_TAX_REGIME_CODE
                and    RECORD_TYPE_CODE = 'MIGRATED'),
                'Y',
                'N')                      ,--SOURCE_TAX_FLAG
         'N'                              ,--SPECIAL_INCL_TAX_FLAG
         'N'                              ,--ALLOW_DUP_REGN_NUM_FLAG
   NULL                             ,--ATTRIBUTE1
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,
   NULL                             ,--ATTRIBUTE_CATEGORY
   NULL                             ,--PARENT_GEOGRAPHY_TYPE
   NULL                             ,--PARENT_GEOGRAPHY_ID
  'N'                               ,--ALLOW_MASS_CREATE_FLAG
  'P'                               ,--APPLIED_AMT_HANDLING_FLAG
   ZX_TAXES_B_S.NEXTVAL             ,--TAX_ID
   l_CONTENT_OWNER_ID               ,
   REP_TAX_AUTHORITY_ID             ,
   COLL_TAX_AUTHORITY_ID            ,
   NULL                             ,--THRSHLD_CHK_TMPLT_CODE
         DEF_PRIMARY_REC_RATE_CODE        ,
         NULL                             ,
         fnd_global.user_id               ,
   SYSDATE                          ,
   fnd_global.user_id               ,
   SYSDATE                          ,
   fnd_global.conc_login_id         ,
   fnd_global.conc_request_id       ,--Request Id
   fnd_global.prog_appl_id          ,--Program Application ID
   fnd_global.conc_program_id       ,--Program Id
   fnd_global.conc_login_id         ,--Program Login ID
         NULL                             ,--OVERRIDE_GEOGRAPHY_TYPE
   1          ,
    DECODE((select tax_type_code
      from
        (select

                      codes.tax_type         tax_type_code,
          rates.tax_regime_code  tax_regime_code,
          rates.tax              tax,
          rates.content_owner_id content_owner_id
         from   zx_rates_b rates, ap_tax_codes_all codes
         where  codes.tax_id = nvl(rates.source_id, rates.tax_rate_id)  --ID Clash
         group  by rates.tax_regime_code, rates.tax, rates.content_owner_id, codes.tax_type
        )
      where   tax_regime_code = l_tax_regime_code
      and     tax = l_tax
      and     content_owner_id = l_content_owner_id
   ),'USE','N','Y')     ,--LIVE_FOR_APPLICABILITY_FLAG
         'N'                        --APPLICABLE_BY_DEFAULT_FLAG
FROM
(
    SELECT
          RATES.TAX_REGIME_CODE                 l_TAX_REGIME_CODE,
          RATES.TAX                             l_TAX,
          ptp.party_tax_profile_id              l_CONTENT_OWNER_ID,
          DECODE(CODES.TAX_TYPE,
                 'OFFSET','Y',
                 'N')                           OFFSET_TAX_FLAG,
     DECODE(CODES.TAX_TYPE,
                 'OFFSET','N',
                 'Y')                           ALLOW_MANUAL_ENTRY_FLAG,
           DECODE(CODES.TAX_TYPE,
                 'OFFSET','N',
                 'Y')                           ALLOW_TAX_OVERRIDE_FLAG,

          SOB.CURRENCY_CODE                     TAX_CURRENCY_CODE,
          FSP.PRECISION                         TAX_PRECISION,
          FSP.MINIMUM_ACCOUNTABLE_UNIT          MINIMUM_ACCOUNTABLE_UNIT,
          DECODE(FSP.TAX_ROUNDING_RULE,
                   'D', 'DOWN',
                   'U', 'UP',
                   'N', 'NEAREST')              ROUNDING_RULE_CODE,
          ASP.AMOUNT_INCLUDES_TAX_FLAG          DEF_INCLUSIVE_TAX_FLAG,
        --BugFix 3480468
        DECODE(NVL(FSP.non_recoverable_tax_flag, 'N'),
              'Y',
              'STANDARD-'||nvl(FSP.default_recovery_rate,0),
              NULL)                             DEF_PRIMARY_REC_RATE_CODE,
          nvl(FSP.non_recoverable_tax_flag,
              'N')                              ALLOW_RECOVERABILITY_FLAG,
         'STANDARD_TC'                          DEF_TAX_CALC_FORMULA,
                                                --Review1 changes
          ASP.amount_includes_tax_override      TAX_INCLUSIVE_OVERRIDE_FLAG,
         'STANDARD_TB'                          DEF_TAXABLE_BASIS_FORMULA,
                                                --Review1 changes
          RATES.DEF_REC_SETTLEMENT_OPTION_CODE  DEF_REC_SETTLEMENT_OPTION_CODE,
          NULL                                  REP_TAX_AUTHORITY_ID,
          NULL                                  COLL_TAX_AUTHORITY_ID,
          min(RATES.EFFECTIVE_FROM)             EFFECTIVE_FROM,
          NULL                                  EFFECTIVE_TO,
          -- Bug 4539221
   -- Bug 6006519/5654551, 'User' is not a valid exchange rate type
         --  decode(ASP.DEFAULT_EXCHANGE_RATE_TYPE,'User','Corporate',ASP.DEFAULT_EXCHANGE_RATE_TYPE)        DEFAULT_EXCHANGE_RATE_TYPE
   NULL           DEFAULT_EXCHANGE_RATE_TYPE
FROM
          ZX_RATES_B RATES,
          AP_TAX_CODES_ALL CODES,
          GL_SETS_OF_BOOKS SOB,
          AP_SYSTEM_PARAMETERS_ALL ASP,
          FINANCIALS_SYSTEM_PARAMS_ALL FSP,
          zx_party_tax_profile ptp
WHERE
          CODES.TAX_ID           =  NVL(RATES.SOURCE_ID, RATES.TAX_RATE_ID)
AND       CODES.ORG_ID           =  PTP.PARTY_ID
AND       CODES.ORG_ID           =  L_ORG_ID
AND       PTP.PARTY_TYPE_CODE    = 'OU'
AND   (   CODES.global_attribute_category = 'JE.CZ.APXTADTC.TAX_ORIGIN'
       OR CODES.global_attribute_category = 'JE.CH.APXTADTC.TAX_INFO'
                                             -- Review1 changes
       OR CODES.global_attribute_category = 'JL.CL.APXTADTC.AP_TAX_CODES'
                                             -- Review1 changes
      )
AND        codes.org_id = fsp.org_id
AND        codes.org_id = asp.org_id
AND       FSP.SET_OF_BOOKS_ID    = SOB.SET_OF_BOOKS_ID
AND       RATES.RECORD_TYPE_CODE = 'MIGRATED'
--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
AND  not exists (select 1 from zx_taxes_b
                 where  tax_regime_code = rates.tax_regime_code
                 and    tax             = rates.tax
                 and    content_owner_id= rates.content_owner_id
                )
GROUP BY
          RATES.TAX_REGIME_CODE                 ,
          RATES.TAX                             ,
          ptp.party_tax_profile_id              ,
          DECODE(CODES.TAX_TYPE,
                 'OFFSET','Y',
                 'N')                           ,
    DECODE(CODES.TAX_TYPE,
                 'OFFSET','N',
                 'Y')                           ,
    DECODE(CODES.TAX_TYPE,
                 'OFFSET','N',
                 'Y')        ,
          SOB.CURRENCY_CODE                     ,
          FSP.PRECISION                         ,
          FSP.MINIMUM_ACCOUNTABLE_UNIT          ,
          DECODE(FSP.TAX_ROUNDING_RULE,
                   'D', 'DOWN',
                   'U', 'UP',
                   'N', 'NEAREST')                 ,
          ASP.AMOUNT_INCLUDES_TAX_FLAG          ,
          DECODE(NVL(FSP.non_recoverable_tax_flag, 'N'),
                'Y',
                'STANDARD-'||nvl(FSP.default_recovery_rate,0),
                 NULL)                          ,
          nvl(FSP.non_recoverable_tax_flag,
              'N')                              ,
          NULL                                  ,
          ASP.amount_includes_tax_override      ,
          NULL                                  ,
          RATES.DEF_REC_SETTLEMENT_OPTION_CODE  ,
          NULL                                  ,
          NULL                                  ,
   -- Bug 6006519/5654551, 'User' is not a valid exchange rate type
    -- decode(ASP.DEFAULT_EXCHANGE_RATE_TYPE,'User','Corporate',ASP.DEFAULT_EXCHANGE_RATE_TYPE)
    NULL
) rates,
(
 SELECT
        lookup_code,lookup_type
  FROM
        FND_LOOKUPS
  WHERE
        lookup_type = 'JGZZ_TAX_ORIGIN'
  OR    lookup_type = 'JECH_VAT_REGIME'
  OR    lookup_type = 'JLCL_TAX_CODE_CLASS'
 MINUS
  SELECT
        lookup_code,lookup_type
  FROM
        ap_tax_codes_all,
        fnd_lookups
  WHERE
       (lookup_type = 'JGZZ_TAX_ORIGIN'
        AND  global_attribute_category = 'JE.CZ.APXTADTC.TAX_ORIGIN'
        AND  global_attribute1 = lookup_code) --Review1 changes
        OR
       (lookup_type = 'JECH_VAT_REGIME'
        AND  global_attribute_category = 'JE.CH.APXTADTC.TAX_INFO'
        AND  global_attribute1 = lookup_code) --Review1 changes
        OR
       (lookup_type = 'JLCL_TAX_CODE_CLASS'
        AND  global_attribute_category = 'JL.CL.APXTADTC.AP_TAX_CODES'
        AND  global_attribute1 = lookup_code) --Review1 changes
) lookups;


END IF;

EXCEPTION WHEN OTHERS THEN
  NULL;
END;


-- End of Unused JGZZ_TAX_ORIGIN lookup code


--
-- Bug 4948332
--
-- Populating zx_taxes_tl.tax_full_name for
-- JE.CH.APXTADTC.TAX_INFO
-- JE.CZ.APXTADTC.TAX_ORIGIN
-- JE.HU.APXTADTC.TAX_ORIGIN
-- JE.PL.APXTADTC.TAX_ORIGIN
--
--
-- For CH (Tax Regime)
--

BEGIN

INSERT INTO ZX_TAXES_TL
(
 LANGUAGE                    ,
 SOURCE_LANG                 ,
 TAX_FULL_NAME               ,
 CREATION_DATE               ,
 CREATED_BY                  ,
 LAST_UPDATE_DATE            ,
 LAST_UPDATED_BY             ,
 LAST_UPDATE_LOGIN           ,
 TAX_ID
)
SELECT
    DISTINCT
    flv.language             ,
    userenv('LANG')          ,
    CASE WHEN flv.meaning = UPPER(flv.meaning)
     THEN    Initcap(flv.meaning)
     ELSE
             flv.meaning
     END                     ,
    SYSDATE                  ,
    fnd_global.user_id       ,
    SYSDATE                  ,
    fnd_global.user_id       ,
    fnd_global.conc_login_id ,
    taxes.tax_id
FROM
    zx_taxes_b                     taxes,
    zx_rates_b                     rates,
    fnd_lookup_values              flv,
    ap_tax_codes_all               ap_code
WHERE
       taxes.CONTENT_OWNER_ID   = rates.CONTENT_OWNER_ID
AND    taxes.TAX_REGIME_CODE    = rates.TAX_REGIME_CODE
AND    taxes.TAX          = rates.TAX
AND    taxes.Record_Type_Code   = 'MIGRATED'
AND    rates.source_id = ap_code.tax_id
AND    flv.lookup_code = ap_code.global_attribute1
AND    ap_code.global_attribute_category = 'JE.CH.APXTADTC.TAX_INFO'
AND    flv.lookup_type = 'JECH_VAT_REGIME'
AND    NOT EXISTS
    (select NULL
         from ZX_TAXES_TL T
         where T.TAX_ID =  TAXES.TAX_ID
         and   T.LANGUAGE = FLV.LANGUAGE);

--
-- For CZ/HU/PL (Tax Origin)
--
INSERT INTO ZX_TAXES_TL
(
 LANGUAGE                    ,
 SOURCE_LANG                 ,
 TAX_FULL_NAME               ,
 CREATION_DATE               ,
 CREATED_BY                  ,
 LAST_UPDATE_DATE            ,
 LAST_UPDATED_BY             ,
 LAST_UPDATE_LOGIN           ,
 TAX_ID
)
SELECT
    DISTINCT
    flv.language             ,
    userenv('LANG')          ,
    CASE WHEN flv.meaning = UPPER(flv.meaning)
     THEN    Initcap(flv.meaning)
     ELSE
             flv.meaning
     END,
    SYSDATE                  ,
    fnd_global.user_id       ,
    SYSDATE                  ,
    fnd_global.user_id       ,
    fnd_global.conc_login_id ,
    taxes.tax_id
FROM
    zx_taxes_b                     taxes,
    zx_rates_b                     rates,
    fnd_lookup_values              flv,
    ap_tax_codes_all               ap_code
WHERE
       taxes.CONTENT_OWNER_ID   = rates.CONTENT_OWNER_ID
AND    taxes.TAX_REGIME_CODE    = rates.TAX_REGIME_CODE
AND    taxes.TAX          = rates.TAX
AND    taxes.Record_Type_Code   = 'MIGRATED'
AND    rates.source_id = ap_code.tax_id
AND    flv.lookup_code = ap_code.global_attribute1
AND    ap_code.global_attribute_category = 'JE.CZ.APXTADTC.TAX_ORIGIN'
AND    flv.lookup_type = 'JGZZ_TAX_ORIGIN'
AND    NOT EXISTS
    (select NULL
         from ZX_TAXES_TL T
         where T.TAX_ID =  TAXES.TAX_ID
         and   T.LANGUAGE = FLV.LANGUAGE);

INSERT INTO ZX_TAXES_TL
(
 LANGUAGE                    ,
 SOURCE_LANG                 ,
 TAX_FULL_NAME               ,
 CREATION_DATE               ,
 CREATED_BY                  ,
 LAST_UPDATE_DATE            ,
 LAST_UPDATED_BY             ,
 LAST_UPDATE_LOGIN           ,
 TAX_ID
)
SELECT
    DISTINCT
    flv.language             ,
    userenv('LANG')          ,
    CASE WHEN flv.meaning = UPPER(flv.meaning)
     THEN    Initcap(flv.meaning)
     ELSE
             flv.meaning
     END,
    SYSDATE                  ,
    fnd_global.user_id       ,
    SYSDATE                  ,
    fnd_global.user_id       ,
    fnd_global.conc_login_id ,
    taxes.tax_id
FROM
    zx_taxes_b                     taxes,
    zx_rates_b                     rates,
    fnd_lookup_values              flv,
    ap_tax_codes_all               ap_code
WHERE
       taxes.CONTENT_OWNER_ID   = rates.CONTENT_OWNER_ID
AND    taxes.TAX_REGIME_CODE    = rates.TAX_REGIME_CODE
AND    taxes.TAX          = rates.TAX
AND    taxes.Record_Type_Code   = 'MIGRATED'
AND    rates.source_id = ap_code.tax_id
AND    flv.lookup_code = ap_code.global_attribute1
AND    ap_code.global_attribute_category = 'JE.HU.APXTADTC.TAX_ORIGIN'
AND    flv.lookup_type = 'JGZZ_TAX_ORIGIN'
AND    NOT EXISTS
    (select NULL
         from ZX_TAXES_TL T
         where T.TAX_ID =  TAXES.TAX_ID
         and   T.LANGUAGE = FLV.LANGUAGE);

INSERT INTO ZX_TAXES_TL
(
 LANGUAGE                    ,
 SOURCE_LANG                 ,
 TAX_FULL_NAME               ,
 CREATION_DATE               ,
 CREATED_BY                  ,
 LAST_UPDATE_DATE            ,
 LAST_UPDATED_BY             ,
 LAST_UPDATE_LOGIN           ,
 TAX_ID
)
SELECT
    DISTINCT
    flv.language             ,
    userenv('LANG')          ,
    CASE WHEN flv.meaning = UPPER(flv.meaning)
     THEN    Initcap(flv.meaning)
     ELSE
             flv.meaning
     END,
    SYSDATE                  ,
    fnd_global.user_id       ,
    SYSDATE                  ,
    fnd_global.user_id       ,
    fnd_global.conc_login_id ,
    taxes.tax_id
FROM
    zx_taxes_b                     taxes,
    zx_rates_b                     rates,
    fnd_lookup_values              flv,
    ap_tax_codes_all               ap_code
WHERE
       taxes.CONTENT_OWNER_ID   = rates.CONTENT_OWNER_ID
AND    taxes.TAX_REGIME_CODE    = rates.TAX_REGIME_CODE
AND    taxes.TAX          = rates.TAX
AND    taxes.Record_Type_Code   = 'MIGRATED'
AND    rates.source_id = ap_code.tax_id
AND    flv.lookup_code = ap_code.global_attribute1
AND    ap_code.global_attribute_category = 'JE.PL.APXTADTC.TAX_ORIGIN'
AND    flv.lookup_type = 'JGZZ_TAX_ORIGIN'
AND    NOT EXISTS
    (select NULL
         from ZX_TAXES_TL T
         where T.TAX_ID =  TAXES.TAX_ID
         and   T.LANGUAGE = FLV.LANGUAGE);
EXCEPTION WHEN OTHERS THEN
  NULL;
END;



--BugFix 4039733
--This fix was done in order to preserve the full tax name

BEGIN

INSERT INTO ZX_TAXES_TL
(
 LANGUAGE                    ,
 SOURCE_LANG                 ,
 TAX_FULL_NAME               ,
 CREATION_DATE               ,
 CREATED_BY                  ,
 LAST_UPDATE_DATE            ,
 LAST_UPDATED_BY             ,
 LAST_UPDATE_LOGIN           ,
 TAX_ID
)
SELECT
    L.LANGUAGE_CODE          ,
    userenv('LANG')          ,
    CASE WHEN B.TAX = UPPER(B.TAX)
     THEN    Initcap(B.TAX)
     ELSE
             B.TAX
     END,
    SYSDATE                  ,
    fnd_global.user_id       ,
    SYSDATE                  ,
    fnd_global.user_id       ,
    fnd_global.conc_login_id ,
    B.TAX_ID
FROM
    FND_LANGUAGES L,
    ZX_TAXES_B B
WHERE
    L.INSTALLED_FLAG in ('I', 'B')
AND RECORD_TYPE_CODE = 'MIGRATED'
AND  not exists
     (select NULL
     from ZX_TAXES_TL T
     where T.TAX_ID =  B.TAX_ID
     and T.LANGUAGE = L.LANGUAGE_CODE);
EXCEPTION WHEN OTHERS THEN
  NULL;
END;

--Bug : 5092560 : This is to populate the ZX_TAXES_B.legal_reporting_status_def_val with '000000000000000'

BEGIN

update zx_taxes_b_tmp
set legal_reporting_status_def_val = '000000000000000'
WHERE record_type_code = 'MIGRATED'
AND tax_regime_code in (
  select distinct tax_regime_code from zx_regimes_b
  where country_code in (
  'BE',
  'CH',
  'CZ',
  'DE',
  'ES',
  'FR',
  'HU',
  'IT',
  'KP',
  'KR',
  'NO',
  'PL',
  'PT',
  'SK')
)  ;

EXCEPTION WHEN OTHERS THEN
  NULL;
END;

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('create_zx_taxes(-)');
    END IF;


EXCEPTION
         WHEN OTHERS THEN
            IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Create_zx_taxes ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('create_zx_taxes(-)');
            END IF;
            --app_exception.raise_exception;
END create_zx_taxes;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    create_templates                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine will insert only one Template with 2 det_factors(one for |
 |     Accounting ranges and another for conditions in Tax Recovery rules)   |
 |     for entire AP Tax definition setup.                                   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        migrate_ap_tax_codes_setup                                         |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-Dec-03  Srinivas Lokam      Created.                               |
 |                                                                           |
 |==========================================================================*/


PROCEDURE create_templates IS
BEGIN

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('create_templates(+)');
    END IF;

INSERT INTO ZX_DET_FACTOR_TEMPL_B
(
  DET_FACTOR_TEMPL_CODE  ,
  TAX_REGIME_CODE        ,
  TEMPLATE_USAGE_CODE    ,
  RECORD_TYPE_CODE       ,
  LEDGER_ID              ,
  CHART_OF_ACCOUNTS_ID   ,
  DET_FACTOR_TEMPL_ID    ,
   CREATED_BY                       ,
  CREATION_DATE                          ,
  LAST_UPDATED_BY                        ,
  LAST_UPDATE_DATE                       ,
  LAST_UPDATE_LOGIN                      ,
  REQUEST_ID                             ,
  PROGRAM_APPLICATION_ID                 ,
  PROGRAM_ID                             ,
  PROGRAM_LOGIN_ID                ,
  OBJECT_VERSION_NUMBER
)
SELECT
       'EX Acct String Range-Party FC' , --Review1 changes
        NULL                           ,
       'TAX_RULES'                     ,
       'MIGRATED'                      ,
        NULL                           ,
        NULL                           ,
        zx_det_factor_templ_b_s.nextval ,
        fnd_global.user_id                     ,
  SYSDATE                                ,
  fnd_global.user_id                     ,
  SYSDATE                                ,
  fnd_global.conc_login_id               ,
  fnd_global.conc_request_id             ,--Request Id
  fnd_global.prog_appl_id                ,--Program Application ID
  fnd_global.conc_program_id             ,--Program Id
  fnd_global.conc_login_id               , --Program Login ID
  1
FROM DUAL
WHERE not exists (select 1
                  from ZX_DET_FACTOR_TEMPL_B
                  where DET_FACTOR_TEMPL_CODE =
                        'EX Acct String Range-Party FC'
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
    L.LANGUAGE_CODE          ,
    userenv('LANG')          ,
    CASE WHEN B.DET_FACTOR_TEMPL_CODE = UPPER(B.DET_FACTOR_TEMPL_CODE)
     THEN    Initcap(B.DET_FACTOR_TEMPL_CODE)
     ELSE
             B.DET_FACTOR_TEMPL_CODE
     END,
    B.DET_FACTOR_TEMPL_CODE  ,
    B.DET_FACTOR_TEMPL_ID    ,
    SYSDATE                  ,
    fnd_global.user_id       ,
    SYSDATE                  ,
    fnd_global.user_id       ,
    fnd_global.conc_login_id
FROM
    FND_LANGUAGES L,
    ZX_DET_FACTOR_TEMPL_B B
WHERE
    L.INSTALLED_FLAG in ('I', 'B')
AND RECORD_TYPE_CODE = 'MIGRATED'
AND  not exists
     (select NULL
     from ZX_DET_FACTOR_TEMPL_TL T
     where T.DET_FACTOR_TEMPL_ID =  B.DET_FACTOR_TEMPL_ID
     and T.LANGUAGE = L.LANGUAGE_CODE);



INSERT INTO ZX_DET_FACTOR_TEMPL_DTL
(
  DETERMINING_FACTOR_CLASS_CODE  ,
  DETERMINING_FACTOR_CQ_CODE     ,
  DETERMINING_FACTOR_CODE        ,
  REQUIRED_FLAG                  ,
  RECORD_TYPE_CODE               ,
  DET_FACTOR_TEMPL_DTL_ID        ,
  DET_FACTOR_TEMPL_ID            ,
   CREATED_BY                       ,
  CREATION_DATE                          ,
  LAST_UPDATED_BY                        ,
  LAST_UPDATE_DATE                       ,
  LAST_UPDATE_LOGIN                      ,
  REQUEST_ID                             ,
  PROGRAM_APPLICATION_ID                 ,
  PROGRAM_ID                             ,
  PROGRAM_LOGIN_ID
)

SELECT
        DETERMINING_FACTOR_CLASS_CODE  ,
        DETERMINING_FACTOR_CQ_CODE     ,
        DETERMINING_FACTOR_CODE        ,
        REQUIRED_FLAG                  ,
        RECORD_TYPE_CODE               ,
        zx_det_factor_templ_dtl_s.nextval ,--DET_FACTOR_TEMPL_DTL_ID
        DET_FACTOR_TEMPL_ID               ,
        fnd_global.user_id                ,
  SYSDATE                           ,
  fnd_global.user_id                ,
  SYSDATE                           ,
  fnd_global.conc_login_id          ,
  fnd_global.conc_request_id        ,--Request Id
  fnd_global.prog_appl_id           ,--Program Application ID
  fnd_global.conc_program_id        ,--Program Id
  fnd_global.conc_login_id           --Program Login ID
FROM
(
SELECT
        'ACCOUNTING_FLEXFIELD'            DETERMINING_FACTOR_CLASS_CODE  ,
   NULL                             DETERMINING_FACTOR_CQ_CODE     ,
  'LINE_ACCOUNT'                    DETERMINING_FACTOR_CODE        , --Bug 5247466
  'Y'                               REQUIRED_FLAG                  ,
  'MIGRATED'                        RECORD_TYPE_CODE               ,
  TEMPL.DET_FACTOR_TEMPL_ID         DET_FACTOR_TEMPL_ID
FROM
    ZX_DET_FACTOR_TEMPL_B   TEMPL
WHERE
     TEMPL.DET_FACTOR_TEMPL_CODE = 'EX Acct String Range-Party FC'
AND  TEMPL.RECORD_TYPE_CODE      = 'MIGRATED'
AND  not exists (select 1 from ZX_DET_FACTOR_TEMPL_DTL
                 where DETERMINING_FACTOR_CLASS_CODE = 'ACCOUNTING_FLEXFIELD'
                 and   DET_FACTOR_TEMPL_ID = templ.DET_FACTOR_TEMPL_ID
                )

UNION ALL

SELECT
       'PARTY_FISCAL_CLASS'               DETERMINING_FACTOR_CLASS_CODE  ,
       'SHIP_FROM'                        DETERMINING_FACTOR_CQ_CODE     ,
       'ESTB_TAX_CLASSIFICATION'          DETERMINING_FACTOR_CODE        ,
       'N'                                REQUIRED_FLAG                  ,
       'MIGRATED'                         RECORD_TYPE_CODE               ,
  TEMPL.DET_FACTOR_TEMPL_ID         DET_FACTOR_TEMPL_ID
FROM
    ZX_DET_FACTOR_TEMPL_B   TEMPL
WHERE
     TEMPL.DET_FACTOR_TEMPL_CODE = 'EX Acct String Range-Party FC'
AND  TEMPL.RECORD_TYPE_CODE      = 'MIGRATED'
AND  not exists (select 1 from ZX_DET_FACTOR_TEMPL_DTL
                 where DETERMINING_FACTOR_CLASS_CODE = 'PARTY_FISCAL_CLASS'
                 and   DET_FACTOR_TEMPL_ID = templ.DET_FACTOR_TEMPL_ID
                )
);

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('create_templates(-)');
    END IF;


EXCEPTION
         WHEN OTHERS THEN
            IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Create_zx_templates ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('create_templates(-)');
            END IF;
            --app_exception.raise_exception;
END create_templates;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    create_condition_groups                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine inserts data into ZX_CONDITIONS,ZX_CONDITION_GROUPS_B,_TL|
 |     Based on AP recovery rules and associated rates.                      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        migrate_ap_tax_codes_setup                                         |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-Dec-03  Srinivas Lokam      Created.                               |
 |     30-Jan-04  Srinivas Lokam      Added INPUT parameters,AND conditions  |
 |                                    in SELECT statements for handling      |
 |                                    SYNC process.                          |
 |                                                                           |
 |==========================================================================*/


PROCEDURE create_condition_groups(p_rate_id IN NUMBER DEFAULT NULL) IS
BEGIN

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('create_condition_groups(+)');
    END IF;

INSERT INTO  ZX_conditions
(
  DETERMINING_FACTOR_CODE        ,
  CONDITION_GROUP_CODE           ,
  TAX_PARAMETER_CODE             ,
  DATA_TYPE_CODE                 ,
  DETERMINING_FACTOR_CLASS_CODE  ,
  DETERMINING_FACTOR_CQ_CODE     ,
  OPERATOR_CODE                  ,
  RECORD_TYPE_CODE               ,
  IGNORE_FLAG                    ,
  NUMERIC_VALUE                  ,
  DATE_VALUE                     ,
  ALPHANUMERIC_VALUE             ,
  VALUE_LOW                      ,
  VALUE_HIGH                     ,
  CONDITION_ID                   ,
   CREATED_BY                       ,
  CREATION_DATE                          ,
  LAST_UPDATED_BY                        ,
  LAST_UPDATE_DATE                       ,
  LAST_UPDATE_LOGIN                      ,
  REQUEST_ID                             ,
  PROGRAM_APPLICATION_ID                 ,
  PROGRAM_ID                             ,
  PROGRAM_LOGIN_ID                       ,
  OBJECT_VERSION_NUMBER

)

SELECT
     DETERMINING_FACTOR_CODE       ,
     CONDITION_GROUP_CODE          ,
     TAX_PARAMETER_CODE            ,
     DATA_TYPE_CODE                ,
     DETERMINING_FACTOR_CLASS_CODE ,
     DETERMINING_FACTOR_CQ_CODE    ,
     OPERATOR_CODE                 ,
     RECORD_TYPE_CODE              ,
     IGNORE_FLAG                   ,
     NUMERIC_VALUE                 ,
     DATE_VALUE                    ,
     ALPHANUMERIC_VALUE            ,
     VALUE_LOW                     ,
     VALUE_HIGH                    ,
     zx_conditions_s.nextval       ,--CONDITION_ID
     fnd_global.user_id                ,
     SYSDATE                           ,
     fnd_global.user_id                ,
     SYSDATE                           ,
     fnd_global.conc_login_id          ,
     fnd_global.conc_request_id        ,--Request Id
     fnd_global.prog_appl_id           ,--Program Application ID
     fnd_global.conc_program_id        ,--Program Id
     fnd_global.conc_login_id          ,--Program Login ID
     1
FROM
(
SELECT
    'LINE_ACCOUNT'                            DETERMINING_FACTOR_CODE  ,--Bug 5247466
     SUBSTRB(RULES.NAME,1,24) || '-' || ROW_NUMBER()
     OVER (PARTITION BY RATES.rule_id ORDER BY
                        RATES.rate_id)         CONDITION_GROUP_CODE     ,
    'ACCOUNT'                                  TAX_PARAMETER_CODE       ,--Bug 5247466
    'ALPHANUMERIC'                             DATA_TYPE_CODE           ,
    'ACCOUNTING_FLEXFIELD'                     DETERMINING_FACTOR_CLASS_CODE,
     NULL                                      DETERMINING_FACTOR_CQ_CODE,
    'BETWEEN'                                  OPERATOR_CODE             ,
    'MIGRATED'                                 RECORD_TYPE_CODE          ,
    'N'                                        IGNORE_FLAG               ,
     NULL                                      NUMERIC_VALUE             ,
     NULL                                      DATE_VALUE                ,
     NULL                                      ALPHANUMERIC_VALUE        ,
     RATES.CONCATENATED_SEGMENT_LOW            VALUE_LOW                 ,
     RATES.CONCATENATED_SEGMENT_HIGH           VALUE_HIGH

FROM
    ap_tax_recvry_rules_all RULES,
    ap_tax_recvry_rates_all RATES
WHERE
     RULES.rule_id = rates.rule_id
--Added following conditions for Sync process
AND  rates.rate_id = nvl(p_rate_id,rates.rate_id)

UNION ALL

SELECT
    'ESTB_TAX_CLASSIFICATION'                  DETERMINING_FACTOR_CODE    ,
     substrb(RULES.NAME,1,24) || '-' || ROW_NUMBER()
     OVER (PARTITION BY RATES.rule_id ORDER BY
                        RATES.rate_id)         CONDITION_GROUP_CODE       ,
     NULL                                      TAX_PARAMETER_CODE         ,
    'ALPHANUMERIC'                             DATA_TYPE_CODE             ,
    'PARTY_FISCAL_CLASS'                       DETERMINING_FACTOR_CLASS_CODE,
    'SHIP_FROM'                                DETERMINING_FACTOR_CQ_CODE  ,
    '='                                        OPERATOR_CODE               ,
    'MIGRATED'                                 RECORD_TYPE_CODE            ,
     DECODE(RATES.condition,
            null,'Y','N')                      IGNORE_FLAG                 ,
     NULL                                      NUMERIC_VALUE               ,
     NULL                                      DATE_VALUE                  ,
     RATES.condition_value                     ALPHANUMERIC_VALUE          ,
     NULL                                      VALUE_LOW                   ,
     NULL                                      VALUE_HIGH
FROM
    ap_tax_recvry_rules_all RULES,
    ap_tax_recvry_rates_all RATES
WHERE
     RULES.rule_id = rates.rule_id
--Added following conditions for Sync process
AND  rates.rate_id = nvl(p_rate_id,rates.rate_id)
) ZX_COND

WHERE NOT EXISTS

(SELECT 1 FROM ZX_CONDITIONS WHERE
   DETERMINING_FACTOR_CODE      = ZX_COND.DETERMINING_FACTOR_CODE
    AND DETERMINING_FACTOR_CLASS_CODE= ZX_COND.DETERMINING_FACTOR_CLASS_CODE
    AND CONDITION_GROUP_CODE         = ZX_COND.CONDITION_GROUP_CODE);


IF L_MULTI_ORG_FLAG = 'Y'
THEN

INSERT INTO ZX_CONDITION_GROUPS_B
(
  CONDITION_GROUP_CODE           ,
  DET_FACTOR_TEMPL_CODE          ,
  COUNTRY_CODE                   ,
  MORE_THAN_MAX_COND_FLAG        ,
  ENABLED_FLAG                   ,
  DETERMINING_FACTOR_CODE1       ,
  TAX_PARAMETER_CODE1            ,
  DATA_TYPE1_CODE                ,
  DETERMINING_FACTOR_CLASS1_CODE ,
  DETERMINING_FACTOR_CQ1_CODE    ,
  OPERATOR1_CODE                 ,
  NUMERIC_VALUE1                 ,
  DATE_VALUE1                    ,
  ALPHANUMERIC_VALUE1            ,
  VALUE_LOW1                     ,
  VALUE_HIGH1                    ,
  DETERMINING_FACTOR_CODE2       ,
  TAX_PARAMETER_CODE2            ,
  DATA_TYPE2_CODE                ,
  DETERMINING_FACTOR_CLASS2_CODE ,
  DETERMINING_FACTOR_CQ2_CODE    ,
  OPERATOR2_CODE                 ,
  NUMERIC_VALUE2                 ,
  DATE_VALUE2                    ,
  ALPHANUMERIC_VALUE2            ,
  VALUE_LOW2                     ,
  VALUE_HIGH2                    ,
  RECORD_TYPE_CODE               ,
  LEDGER_ID                      ,
  CHART_OF_ACCOUNTS_ID           ,
  CONDITION_GROUP_ID             ,
   CREATED_BY                       ,
  CREATION_DATE                          ,
  LAST_UPDATED_BY                        ,
  LAST_UPDATE_DATE                       ,
  LAST_UPDATE_LOGIN                      ,
  REQUEST_ID                             ,
  PROGRAM_APPLICATION_ID                 ,
  PROGRAM_ID                             ,
  PROGRAM_LOGIN_ID        ,
  OBJECT_VERSION_NUMBER
)

SELECT
     substrb(RULES.NAME,1,24) || '-' || ROW_NUMBER()
     OVER (PARTITION BY RATES.rule_id ORDER BY
                        RATES.rate_id)            ,--CONDITION_GROUP_CODE
     'EX Acct String Range-Party FC'              ,--DET_FACTOR_TEMPL_CODE
                                                   --Review1 changes
     zx_migrate_util.get_country(fsp.org_id)      ,--COUNTRY_CODE
     'N'                                          ,--MORE_THAN_MAX_COND_FLAG
     'Y'                                          ,--ENABLED_FLAG
    'LINE_ACCOUNT'                                , --DETERMINING_FACTOR_CODE1 ----Bug 5247466
    'ACCOUNT'                                  ,--TAX_PARAMETER_CODE1    ----Bug 5247466
    'ALPHANUMERIC'                             ,--DATA_TYPE1_CODE
    'ACCOUNTING_FLEXFIELD'                     ,--DETERMINING_FACTOR_CLASS1_CODE
     NULL                                      ,--DETERMINING_FACTOR_CQ1_CODE
    'BETWEEN'                                  ,--OPERATOR1_CODE
     NULL                                      ,--NUMERIC_VALUE1
     NULL                                      ,--DATE_VALUE1
     NULL                                      ,--ALPHANUMERIC_VALUE1
     RATES.CONCATENATED_SEGMENT_LOW            ,--VALUE_LOW1
     RATES.CONCATENATED_SEGMENT_HIGH           ,--VALUE_HIGH1
     DECODE(RATES.condition,null,
            null,'ESTB_TAX_CLASSIFICATION')    ,--DETERMINING_FACTOR_CODE2
     NULL                                      ,--TAX_PARAMETER_CODE2
     DECODE(RATES.condition,null,
            null,'ALPHANUMERIC')               ,--DATA_TYPE2_CODE
     DECODE(RATES.condition,null,
            null,'PARTY_FISCAL_CLASS')         ,--DETERMINING_FACTOR_CLASS2_CODE
     DECODE(RATES.condition,null,
            null,'SHIP_FROM')                  ,--DETERMINING_FACTOR_CQ2_CODE
     DECODE(RATES.condition,null,
            null,'=')                          ,--OPERATOR2_CODE
     NULL                                      ,--NUMERIC_VALUE2
     NULL                                      ,--DATE_VALUE2
     DECODE(RATES.condition,null,
            null,RATES.condition_value)        ,--ALPHANUMERIC_VALUE2
     NULL                                      ,--VALUE_LOW2
     NULL                                      ,--VALUE_HIGH2
    'MIGRATED'                                 ,--RECORD_TYPE_CODE
     SOB.SET_OF_BOOKS_ID                       ,--LEDGER_ID
     SOB.CHART_OF_ACCOUNTS_ID                  ,--CHART_OF_ACCOUNTS_ID
     zx_condition_groups_b_s.nextval           ,--CONDITION_GROUP_ID
     fnd_global.user_id                ,
     SYSDATE                           ,
     fnd_global.user_id                ,
     SYSDATE                           ,
     fnd_global.conc_login_id          ,
     fnd_global.conc_request_id        ,--Request Id
     fnd_global.prog_appl_id           ,--Program Application ID
     fnd_global.conc_program_id        ,--Program Id
     fnd_global.conc_login_id          ,--Program Login ID
     1
FROM
      ap_tax_recvry_rules_all RULES,
    --ap_system_parameters_all ASP,
      gl_sets_of_books SOB,
      financials_system_params_all FSP,
      ap_tax_recvry_rates_all RATES
WHERE
     rules.org_id = fsp.org_id
AND   FSP.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
AND   RULES.RULE_ID = RATES.RULE_ID
--Added following conditions for Sync process
AND   RATES.RATE_ID = nvl(p_rate_id,RATES.RATE_ID)
AND not exists (select 1 from zx_condition_groups_b
                where  CONDITION_GROUP_CODE =
                       (SELECT TEMP_GROUPS.CONDITION_GROUP_CODE
                        FROM
                        (SELECT  substrb(RULES1.NAME,1,24) || '-' || ROW_NUMBER()
                                 OVER (PARTITION BY RATES1.rule_id ORDER BY
                                 RATES1.rate_id)  CONDITION_GROUP_CODE,
                                 RULES1.RULE_ID,
                                 RATES1.RATE_ID
                         FROM
                         ap_tax_recvry_rules_all RULES1,
                         ap_tax_recvry_rates_all RATES1
                         WHERE
                         RULES1.rule_id = RATES1.rule_id
                        ) TEMP_GROUPS
                WHERE
                TEMP_GROUPS.RULE_ID = RULES.RULE_ID
                AND  TEMP_GROUPS.RATE_ID = RATES.RATE_ID
               )
              )
   ;
ELSE

INSERT INTO ZX_CONDITION_GROUPS_B
(
  CONDITION_GROUP_CODE           ,
  DET_FACTOR_TEMPL_CODE          ,
  COUNTRY_CODE                   ,
  MORE_THAN_MAX_COND_FLAG        ,
  ENABLED_FLAG                   ,
  DETERMINING_FACTOR_CODE1       ,
  TAX_PARAMETER_CODE1            ,
  DATA_TYPE1_CODE                ,
  DETERMINING_FACTOR_CLASS1_CODE ,
  DETERMINING_FACTOR_CQ1_CODE    ,
  OPERATOR1_CODE                 ,
  NUMERIC_VALUE1                 ,
  DATE_VALUE1                    ,
  ALPHANUMERIC_VALUE1            ,
  VALUE_LOW1                     ,
  VALUE_HIGH1                    ,
  DETERMINING_FACTOR_CODE2       ,
  TAX_PARAMETER_CODE2            ,
  DATA_TYPE2_CODE                ,
  DETERMINING_FACTOR_CLASS2_CODE ,
  DETERMINING_FACTOR_CQ2_CODE    ,
  OPERATOR2_CODE                 ,
  NUMERIC_VALUE2                 ,
  DATE_VALUE2                    ,
  ALPHANUMERIC_VALUE2            ,
  VALUE_LOW2                     ,
  VALUE_HIGH2                    ,
  RECORD_TYPE_CODE               ,
  LEDGER_ID                      ,
  CHART_OF_ACCOUNTS_ID           ,
  CONDITION_GROUP_ID             ,
   CREATED_BY                       ,
  CREATION_DATE                          ,
  LAST_UPDATED_BY                        ,
  LAST_UPDATE_DATE                       ,
  LAST_UPDATE_LOGIN                      ,
  REQUEST_ID                             ,
  PROGRAM_APPLICATION_ID                 ,
  PROGRAM_ID                             ,
  PROGRAM_LOGIN_ID        ,
  OBJECT_VERSION_NUMBER
)

SELECT
     substrb(RULES.NAME,1,24) || '-' || ROW_NUMBER()
     OVER (PARTITION BY RATES.rule_id ORDER BY
                        RATES.rate_id)            ,--CONDITION_GROUP_CODE
     'EX Acct String Range-Party FC'              ,--DET_FACTOR_TEMPL_CODE
                                                   --Review1 changes
     zx_migrate_util.get_country(fsp.org_id)      ,--COUNTRY_CODE
     'N'                                          ,--MORE_THAN_MAX_COND_FLAG
     'Y'                                          ,--ENABLED_FLAG
    'LINE_ACCOUNT'                                , --DETERMINING_FACTOR_CODE1 ----Bug 5247466
    'ACCOUNT'                                  ,--TAX_PARAMETER_CODE1    ----Bug 5247466
    'ALPHANUMERIC'                             ,--DATA_TYPE1_CODE
    'ACCOUNTING_FLEXFIELD'                     ,--DETERMINING_FACTOR_CLASS1_CODE
     NULL                                      ,--DETERMINING_FACTOR_CQ1_CODE
    'BETWEEN'                                  ,--OPERATOR1_CODE
     NULL                                      ,--NUMERIC_VALUE1
     NULL                                      ,--DATE_VALUE1
     NULL                                      ,--ALPHANUMERIC_VALUE1
     RATES.CONCATENATED_SEGMENT_LOW            ,--VALUE_LOW1
     RATES.CONCATENATED_SEGMENT_HIGH           ,--VALUE_HIGH1
     DECODE(RATES.condition,null,
            null,'ESTB_TAX_CLASSIFICATION')    ,--DETERMINING_FACTOR_CODE2
     NULL                                      ,--TAX_PARAMETER_CODE2
     DECODE(RATES.condition,null,
            null,'ALPHANUMERIC')               ,--DATA_TYPE2_CODE
     DECODE(RATES.condition,null,
            null,'PARTY_FISCAL_CLASS')         ,--DETERMINING_FACTOR_CLASS2_CODE
     DECODE(RATES.condition,null,
            null,'SHIP_FROM')                  ,--DETERMINING_FACTOR_CQ2_CODE
     DECODE(RATES.condition,null,
            null,'=')                          ,--OPERATOR2_CODE
     NULL                                      ,--NUMERIC_VALUE2
     NULL                                      ,--DATE_VALUE2
     DECODE(RATES.condition,null,
            null,RATES.condition_value)        ,--ALPHANUMERIC_VALUE2
     NULL                                      ,--VALUE_LOW2
     NULL                                      ,--VALUE_HIGH2
    'MIGRATED'                                 ,--RECORD_TYPE_CODE
     SOB.SET_OF_BOOKS_ID                       ,--LEDGER_ID
     SOB.CHART_OF_ACCOUNTS_ID                  ,--CHART_OF_ACCOUNTS_ID
     zx_condition_groups_b_s.nextval           ,--CONDITION_GROUP_ID
     fnd_global.user_id                ,
     SYSDATE                           ,
     fnd_global.user_id                ,
     SYSDATE                           ,
     fnd_global.conc_login_id          ,
     fnd_global.conc_request_id        ,--Request Id
     fnd_global.prog_appl_id           ,--Program Application ID
     fnd_global.conc_program_id        ,--Program Id
     fnd_global.conc_login_id          ,--Program Login ID
     1
FROM
      ap_tax_recvry_rules_all RULES,
    --ap_system_parameters_all ASP,
      gl_sets_of_books SOB,
      financials_system_params_all FSP,
      ap_tax_recvry_rates_all RATES
WHERE
     rules.org_id = fsp.org_id
AND  rules.org_id = l_org_id
AND   FSP.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
AND   RULES.RULE_ID = RATES.RULE_ID
--Added following conditions for Sync process
AND   RATES.RATE_ID = nvl(p_rate_id,RATES.RATE_ID)
AND not exists (select 1 from zx_condition_groups_b
                where  CONDITION_GROUP_CODE =
                       (SELECT TEMP_GROUPS.CONDITION_GROUP_CODE
                        FROM
                        (SELECT  substrb(RULES1.NAME,1,24) || '-' || ROW_NUMBER()
                                 OVER (PARTITION BY RATES1.rule_id ORDER BY
                                 RATES1.rate_id)  CONDITION_GROUP_CODE,
                                 RULES1.RULE_ID,
                                 RATES1.RATE_ID
                         FROM
                         ap_tax_recvry_rules_all RULES1,
                         ap_tax_recvry_rates_all RATES1
                         WHERE
                         RULES1.rule_id = RATES1.rule_id
                        ) TEMP_GROUPS
                WHERE
                TEMP_GROUPS.RULE_ID = RULES.RULE_ID
                AND  TEMP_GROUPS.RATE_ID = RATES.RATE_ID
               )
              )
   ;


END IF;



INSERT INTO ZX_CONDITION_GROUPS_TL
(
 LANGUAGE                    ,
 SOURCE_LANG                 ,
 CONDITION_GROUP_NAME        ,
 CONDITION_GROUP_DESC        ,
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
     END,
    B.CONDITION_GROUP_CODE   ,
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
     (select NULL
     from  ZX_CONDITION_GROUPS_TL T
     where T.CONDITION_GROUP_ID =  B.CONDITION_GROUP_ID
     and T.LANGUAGE = L.LANGUAGE_CODE);

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('create_condition_groups(-)');
    END IF;

EXCEPTION
         WHEN OTHERS THEN
            IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Create_condition_groups ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('create_condition_groups(-)');
            END IF;
            --app_exception.raise_exception;
END create_condition_groups;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    create_rules                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine inserts data into ZX_RULES_B,_TL,ZX_PROCESS_RESULTS      |
 |     Based on AP recovery rules and associated rates.                      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        migrate_ap_tax_codes_setup                                         |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     24-Dec-03  Srinivas Lokam      Created.                               |
 |     30-Jan-04  Srinivas Lokam      Added INPUT parameters,AND conditions  |
 |                                    in SELECT statements for handling      |
 |                                    SYNC process.                          |
 |                                                                           |
 |==========================================================================*/

PROCEDURE create_rules(p_tax_id IN NUMBER DEFAULT NULL) IS
BEGIN

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('create_rules(+)');
    END IF;

IF L_MULTI_ORG_FLAG = 'Y'
THEN

INSERT INTO ZX_RULES_B_TMP
(
  TAX_RULE_CODE          ,
  TAX                    ,
  TAX_REGIME_CODE        ,
  SERVICE_TYPE_CODE      ,
  APPLICATION_ID         ,
  RECOVERY_TYPE_CODE     ,
  PRIORITY               ,
  SYSTEM_DEFAULT_FLAG    ,
  EFFECTIVE_FROM         ,
  EFFECTIVE_TO           ,
  ENABLED_FLAG           ,
  RECORD_TYPE_CODE       ,
  DET_FACTOR_TEMPL_CODE  ,
  CONTENT_OWNER_ID       ,
  TAX_RULE_ID            ,
   CREATED_BY                       ,
  CREATION_DATE                          ,
  LAST_UPDATED_BY                        ,
  LAST_UPDATE_DATE                       ,
  LAST_UPDATE_LOGIN                      ,
  REQUEST_ID                             ,
  PROGRAM_APPLICATION_ID                 ,
  PROGRAM_ID                             ,
  PROGRAM_LOGIN_ID          ,
  OBJECT_VERSION_NUMBER
)

SELECT
      TAX_RULE_CODE          ,
      TAX                    ,
      TAX_REGIME_CODE        ,
     'DET_RECOVERY_RATE'     ,--SERVICE_TYPE_CODE
      --200                    ,--APPLICATION_ID   --Review1 changes
      NULL                   ,--APPLICATION_ID   --bug 7395339
     'STANDARD'              ,--RECOVERY_TYPE_CODE
      1                      ,--PRIORITY
     'Y'                     ,--SYSTEM_DEFAULT_FLAG
      EFFECTIVE_FROM         ,
      NULL                   ,--EFFECTIVE_TO
     'Y'                     ,--ENABLED_FLAG
     'MIGRATED'              ,--RECORD_TYPE_CODE
     'EX Acct String Range-Party FC' ,--DET_FACTOR_TEMPL_CODE
      CONTENT_OWNER_ID               ,
      zx_rules_b_s.nextval           ,--TAX_RULE_ID
      fnd_global.user_id                ,
      SYSDATE                           ,
      fnd_global.user_id                ,
      SYSDATE                           ,
      fnd_global.conc_login_id          ,
      fnd_global.conc_request_id        ,--Request Id
      fnd_global.prog_appl_id           ,--Program Application ID
      fnd_global.conc_program_id        ,--Program Id
      fnd_global.conc_login_id          ,--Program Login ID
      1
FROM
(
SELECT
      DISTINCT
      --check if there exists multiple rows in  ap_tax_recvry_rules_all with the same name.

      CASE WHEN EXISTS(select NULL from ap_tax_recvry_rules_all where name=RULES.NAME
                  group by name having count(*)>1)
       THEN
                  --check if ap_tax_recvry_rules_all.NAME || rates.TAX is more than 30 characters in length

           DECODE(SIGN(LENGTHB(RULES.NAME||RATES.TAX)-30),
                      1,
          SUBSTRB(RULES.NAME,1,24)||ZX_MIGRATE_UTIL.GET_NEXT_SEQID('ZX_RULES_B_S'),
          RULES.NAME||RATES.TAX)

      ELSE -- else for GROUP BY CHECKING
          RULES.NAME
    END                                            TAX_RULE_CODE,
      RATES.TAX                              TAX          ,
      RATES.TAX_REGIME_CODE           TAX_REGIME_CODE,
     (select min(start_date)
      from ap_tax_recvry_rates_all
      where rule_id = RULES.rule_id)         EFFECTIVE_FROM,
      ptp.party_tax_profile_id                      CONTENT_OWNER_ID
FROM
    ap_tax_codes_all codes,
    zx_rates_b       rates,
    ap_tax_recvry_rules_all Rules,
    zx_party_tax_profile ptp
WHERE
     CODES.TAX_ID               = NVL(RATES.SOURCE_ID, RATES.TAX_RATE_ID)
AND  CODES.TAX_RECOVERY_RULE_ID = RULES.RULE_ID
AND  CODES.ORG_ID   = PTP.PARTY_ID
AND  PTP.PARTY_TYPE_CODE        ='OU'
--Added following conditions for Sync process
AND  codes.tax_id = nvl(p_tax_id,codes.tax_id)
AND  not exists (select 1 from zx_rules_b
                 where substrb(tax_rule_code,1,24)
          = ( --check if there exists multiple rows in  ap_tax_recvry_rules_all with the same name.

               CASE WHEN EXISTS(select NULL from ap_tax_recvry_rules_all where name=RULES.NAME
                      group by name having count(*)>1)
               THEN
                        --check if ap_tax_recvry_rules_all.NAME || rates.TAX is more than 30 characters in length

                   DECODE(SIGN(LENGTHB(RULES.NAME||RATES.TAX)-30),
                           1,
               SUBSTRB(RULES.NAME,1,24),
                            SUBSTRB(RULES.NAME||RATES.TAX,1,24))

                ELSE -- else for GROUP BY CHECKING
                SUBSTRB(RULES.NAME,1,24)
                END  )
                 and   enabled_flag  = 'Y'

                )
);
ELSE

INSERT INTO ZX_RULES_B_TMP
(
  TAX_RULE_CODE          ,
  TAX                    ,
  TAX_REGIME_CODE        ,
  SERVICE_TYPE_CODE      ,
  APPLICATION_ID         ,
  RECOVERY_TYPE_CODE     ,
  PRIORITY               ,
  SYSTEM_DEFAULT_FLAG    ,
  EFFECTIVE_FROM         ,
  EFFECTIVE_TO           ,
  ENABLED_FLAG           ,
  RECORD_TYPE_CODE       ,
  DET_FACTOR_TEMPL_CODE  ,
  CONTENT_OWNER_ID       ,
  TAX_RULE_ID            ,
   CREATED_BY                       ,
  CREATION_DATE                          ,
  LAST_UPDATED_BY                        ,
  LAST_UPDATE_DATE                       ,
  LAST_UPDATE_LOGIN                      ,
  REQUEST_ID                             ,
  PROGRAM_APPLICATION_ID                 ,
  PROGRAM_ID                             ,
  PROGRAM_LOGIN_ID          ,
  OBJECT_VERSION_NUMBER
)

SELECT
      TAX_RULE_CODE          ,
      TAX                    ,
      TAX_REGIME_CODE        ,
     'DET_RECOVERY_RATE'     ,--SERVICE_TYPE_CODE
      --200                    ,--APPLICATION_ID   --Review1 changes
      NULL                   ,--APPLICATION_ID   --bug 7395339
     'STANDARD'              ,--RECOVERY_TYPE_CODE
      1                      ,--PRIORITY
     'Y'                     ,--SYSTEM_DEFAULT_FLAG
      EFFECTIVE_FROM         ,
      NULL                   ,--EFFECTIVE_TO
     'Y'                     ,--ENABLED_FLAG
     'MIGRATED'              ,--RECORD_TYPE_CODE
     'EX Acct String Range-Party FC' ,--DET_FACTOR_TEMPL_CODE
      CONTENT_OWNER_ID               ,
      zx_rules_b_s.nextval           ,--TAX_RULE_ID
      fnd_global.user_id                ,
      SYSDATE                           ,
      fnd_global.user_id                ,
      SYSDATE                           ,
      fnd_global.conc_login_id          ,
      fnd_global.conc_request_id        ,--Request Id
      fnd_global.prog_appl_id           ,--Program Application ID
      fnd_global.conc_program_id        ,--Program Id
      fnd_global.conc_login_id          ,--Program Login ID
      1
FROM
(
SELECT
      DISTINCT
      --check if there exists multiple rows in  ap_tax_recvry_rules_all with the same name.

      CASE WHEN EXISTS(select NULL from ap_tax_recvry_rules_all where name=RULES.NAME
                  group by name having count(*)>1)
       THEN
                  --check if ap_tax_recvry_rules_all.NAME || rates.TAX is more than 30 characters in length

           DECODE(SIGN(LENGTHB(RULES.NAME||RATES.TAX)-30),
                      1,
          SUBSTRB(RULES.NAME,1,24)||ZX_MIGRATE_UTIL.GET_NEXT_SEQID('ZX_RULES_B_S'),
          RULES.NAME||RATES.TAX)

      ELSE -- else for GROUP BY CHECKING
          RULES.NAME
    END                                            TAX_RULE_CODE,
      RATES.TAX                              TAX          ,
      RATES.TAX_REGIME_CODE           TAX_REGIME_CODE,
     (select min(start_date)
      from ap_tax_recvry_rates_all
      where rule_id = RULES.rule_id)         EFFECTIVE_FROM,
      ptp.party_tax_profile_id                      CONTENT_OWNER_ID
FROM
    ap_tax_codes_all codes,
    zx_rates_b       rates,
    ap_tax_recvry_rules_all Rules,
    zx_party_tax_profile ptp
WHERE
     CODES.TAX_ID               = NVL(RATES.SOURCE_ID, RATES.TAX_RATE_ID)
AND  CODES.TAX_RECOVERY_RULE_ID = RULES.RULE_ID
AND  CODES.ORG_ID   = L_ORG_ID
AND  CODES.ORG_ID   = PTP.PARTY_ID
AND  PTP.PARTY_TYPE_CODE        ='OU'
--Added following conditions for Sync process
AND  codes.tax_id = nvl(p_tax_id,codes.tax_id)
AND  not exists (select 1 from zx_rules_b
                 where substrb(tax_rule_code,1,24)
          = ( --check if there exists multiple rows in  ap_tax_recvry_rules_all with the same name.

               CASE WHEN EXISTS(select NULL from ap_tax_recvry_rules_all where name=RULES.NAME
                      group by name having count(*)>1)
               THEN
                        --check if ap_tax_recvry_rules_all.NAME || rates.TAX is more than 30 characters in length

                   DECODE(SIGN(LENGTHB(RULES.NAME||RATES.TAX)-30),
                           1,
               SUBSTRB(RULES.NAME,1,24),
                            SUBSTRB(RULES.NAME||RATES.TAX,1,24))

                ELSE -- else for GROUP BY CHECKING
                SUBSTRB(RULES.NAME,1,24)
                END  )
                 and   enabled_flag  = 'Y'

                )
);

END IF;



INSERT INTO ZX_RULES_TL
(
 LANGUAGE                    ,
 SOURCE_LANG                 ,
 TAX_RULE_NAME               ,
 TAX_RULE_DESC               ,
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
     END,
    B.TAX_RULE_CODE          ,
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

IF L_MULTI_ORG_FLAG = 'Y'
THEN

INSERT INTO ZX_PROCESS_RESULTS
(
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
RESULT_API            ,
RESULT_ID             ,
CONTENT_OWNER_ID      ,
CONDITION_GROUP_ID    ,
TAX_RULE_ID           ,
CREATED_BY                ,
CREATION_DATE             ,
LAST_UPDATED_BY           ,
LAST_UPDATE_DATE          ,
LAST_UPDATE_LOGIN         ,
REQUEST_ID                ,
PROGRAM_APPLICATION_ID    ,
PROGRAM_ID                ,
PROGRAM_LOGIN_ID     ,
OBJECT_VERSION_NUMBER
)

SELECT
     CONDITION_GROUP_CODE                      ,--CONDITION_GROUP_CODE
     ROW_NUMBER()
     OVER (PARTITION BY AP_RULE_ID ORDER BY
                        AP_RATE_ID)            ,--PRIORITY
    'CODE'                                       ,--RESULT_TYPE_CODE
     NULL                                        ,--TAX_STATUS_CODE slokam
     NULL                                        ,--NUMERIC_RESULT
     ALPHANUMERIC_RESULT                        ,--ALPHANUMERIC_RESULT
     NULL                                        ,--STATUS_RESULT
     NULL                                        ,--RATE_RESULT
     NULL                                        ,--LEGAL_MESSAGE_CODE
     NULL                                        ,--MIN_TAX_AMT
     NULL                                        ,--MAX_TAX_AMT
     NULL                                        ,--MIN_TAXABLE_BASIS
     NULL                                        ,--MAX_TAXABLE_BASIS
     NULL                                        ,--MIN_TAX_RATE
     NULL                                        ,--MAX_TAX_RATE
     --'Y'                                       ,--ENABLED_FLAG    -- Commented as a fix for Bug#7412888
      ENABLED_FLAG                               ,--ENABLED_FLAG    -- Added as a fix for Bug#7412888
     'N'                                         ,--ALLOW_EXEMPTIONS_FLAG
     'N'                                         ,--ALLOW_EXCEPTIONS_FLAG
     'MIGRATED'                                  ,--RECORD_TYPE_CODE
      NULL                                       ,--RESULT_API
      zx_process_results_s.nextval               ,--RESULT_ID
      CONTENT_OWNER_ID                         ,--CONTENT_OWNER_ID
      CONDITION_GROUP_ID                       ,--CONDITION_GROUP_ID
      TAX_RULE_ID                              ,--TAX_RULE_ID
      fnd_global.user_id                ,
      SYSDATE                           ,
      fnd_global.user_id                ,
      SYSDATE                           ,
      fnd_global.conc_login_id          ,
      fnd_global.conc_request_id        ,--Request Id
      fnd_global.prog_appl_id           ,--Program Application ID
      fnd_global.conc_program_id        ,--Program Id
      fnd_global.conc_login_id          , --Program Login ID
      1
FROM
(SELECT  DISTINCT
      GROUPS.condition_group_code   CONDITION_GROUP_CODE,--CONDITION_GROUP_CODE
      AP_RATES.rule_id              AP_RULE_ID,--AP_RULE_ID
      AP_RATES.rate_id              AP_RATE_ID,--AP_RATE_ID
     'STANDARD-' || AP_RATES.RECOVERY_RATE  ALPHANUMERIC_RESULT,--ALPHANUMERIC_RESULT
      ptp.party_tax_profile_id      CONTENT_OWNER_ID,--CONTENT_OWNER_ID
      GROUPS.CONDITION_GROUP_ID     CONDITION_GROUP_ID,--CONDITION_GROUP_ID
      ZX_RULES.TAX_RULE_ID          TAX_RULE_ID, --TAX_RULE_ID
      -- Added as a fix for Bug#7412888
      CASE WHEN (AP_RATES.END_DATE IS NOT NULL
                 AND AP_RATES.END_DATE < SYSDATE)
      THEN 'N'
      ELSE 'Y'
      END                           ENABLED_FLAG --ENABLED_FLAG
 FROM
    AP_TAX_CODES_ALL CODES,
    ap_tax_recvry_rules_all AP_RULES,
    ap_tax_recvry_rates_all AP_RATES,
    ZX_RATES_B  ZX_RATES,
    ZX_RULES_B  ZX_RULES,
    ZX_CONDITION_GROUPS_B GROUPS,
    zx_party_tax_profile ptp
WHERE
     CODES.TAX_ID               = NVL(ZX_RATES.SOURCE_ID, ZX_RATES.TAX_RATE_ID)
AND  CODES.TAX_RECOVERY_RULE_ID = AP_RULES.RULE_ID
AND  AP_RULES.RULE_ID           = AP_RATES.RULE_ID
AND  AP_RULES.NAME              = ZX_RULES.TAX_RULE_CODE
AND  ZX_RATES.TAX               = ZX_RULES.TAX
AND  ZX_RATES.TAX_REGIME_CODE   = ZX_RULES.TAX_REGIME_CODE
AND  ZX_RATES.CONTENT_OWNER_ID  = ZX_RULES.CONTENT_OWNER_ID
AND  PTP.PARTY_ID               = CODES.ORG_ID
--Added following conditions for Sync process
AND  codes.tax_id = nvl(p_tax_id,codes.tax_id)
AND  PTP.PARTY_TYPE_CODE        = 'OU'
AND  GROUPS.CONDITION_GROUP_CODE =
 (SELECT TEMP_GROUPS.CONDITION_GROUP_CODE
  FROM
     (SELECT  substrb(RULES1.NAME,1,24) || '-' || ROW_NUMBER()
              OVER (PARTITION BY RATES1.rule_id ORDER BY
                                 RATES1.rate_id)  CONDITION_GROUP_CODE,
              RULES1.RULE_ID,
              RATES1.RATE_ID
      FROM
             ap_tax_recvry_rules_all RULES1,
             ap_tax_recvry_rates_all RATES1
      WHERE
             RULES1.rule_id = RATES1.rule_id
     ) TEMP_GROUPS
  WHERE
       TEMP_GROUPS.RULE_ID = AP_RULES.RULE_ID
  AND  TEMP_GROUPS.RATE_ID = AP_RATES.RATE_ID
 )
 AND not exists (select 1 from zx_process_results
                 where tax_rule_id        = zx_rules.tax_rule_id
                 and condition_group_code = groups.condition_group_code
                 and alphanumeric_result  = 'STANDARD-' || AP_RATES.RECOVERY_RATE
                 )

);

ELSE

INSERT INTO ZX_PROCESS_RESULTS
(
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
RESULT_API            ,
RESULT_ID             ,
CONTENT_OWNER_ID      ,
CONDITION_GROUP_ID    ,
TAX_RULE_ID           ,
CREATED_BY                ,
CREATION_DATE             ,
LAST_UPDATED_BY           ,
LAST_UPDATE_DATE          ,
LAST_UPDATE_LOGIN         ,
REQUEST_ID                ,
PROGRAM_APPLICATION_ID    ,
PROGRAM_ID                ,
PROGRAM_LOGIN_ID     ,
OBJECT_VERSION_NUMBER
)

SELECT
     CONDITION_GROUP_CODE                      ,--CONDITION_GROUP_CODE
     ROW_NUMBER()
     OVER (PARTITION BY AP_RULE_ID ORDER BY
                        AP_RATE_ID)            ,--PRIORITY
    'CODE'                                       ,--RESULT_TYPE_CODE
     NULL                                        ,--TAX_STATUS_CODE slokam
     NULL                                        ,--NUMERIC_RESULT
     ALPHANUMERIC_RESULT                        ,--ALPHANUMERIC_RESULT
     NULL                                        ,--STATUS_RESULT
     NULL                                        ,--RATE_RESULT
     NULL                                        ,--LEGAL_MESSAGE_CODE
     NULL                                        ,--MIN_TAX_AMT
     NULL                                        ,--MAX_TAX_AMT
     NULL                                        ,--MIN_TAXABLE_BASIS
     NULL                                        ,--MAX_TAXABLE_BASIS
     NULL                                        ,--MIN_TAX_RATE
     NULL                                        ,--MAX_TAX_RATE
     -- 'Y'                                      ,--ENABLED_FLAG     -- Commented as a fix for Bug#7412888
     ENABLED_FLAG                                ,--ENABLED_FLAG     -- Added as a fix for Bug#7412888
     'N'                                         ,--ALLOW_EXEMPTIONS_FLAG
     'N'                                         ,--ALLOW_EXCEPTIONS_FLAG
     'MIGRATED'                                  ,--RECORD_TYPE_CODE
      NULL                                       ,--RESULT_API
      zx_process_results_s.nextval               ,--RESULT_ID
      CONTENT_OWNER_ID                         ,--CONTENT_OWNER_ID
      CONDITION_GROUP_ID                       ,--CONDITION_GROUP_ID
      TAX_RULE_ID                              ,--TAX_RULE_ID
      fnd_global.user_id                ,
      SYSDATE                           ,
      fnd_global.user_id                ,
      SYSDATE                           ,
      fnd_global.conc_login_id          ,
      fnd_global.conc_request_id        ,--Request Id
      fnd_global.prog_appl_id           ,--Program Application ID
      fnd_global.conc_program_id        ,--Program Id
      fnd_global.conc_login_id          , --Program Login ID
      1
FROM
(SELECT  DISTINCT
      GROUPS.condition_group_code   CONDITION_GROUP_CODE,--CONDITION_GROUP_CODE
      AP_RATES.rule_id              AP_RULE_ID,--AP_RULE_ID
      AP_RATES.rate_id              AP_RATE_ID,--AP_RATE_ID
     'STANDARD-' || AP_RATES.RECOVERY_RATE  ALPHANUMERIC_RESULT,--ALPHANUMERIC_RESULT
      ptp.party_tax_profile_id      CONTENT_OWNER_ID,--CONTENT_OWNER_ID
      GROUPS.CONDITION_GROUP_ID     CONDITION_GROUP_ID,--CONDITION_GROUP_ID
      ZX_RULES.TAX_RULE_ID          TAX_RULE_ID, --TAX_RULE_ID
      -- Added as a fix for Bug#7412888
      CASE WHEN (AP_RATES.END_DATE IS NOT NULL
                 AND AP_RATES.END_DATE < SYSDATE)
      THEN 'N'
      ELSE 'Y'
      END                           ENABLED_FLAG --ENABLED_FLAG
 FROM
    AP_TAX_CODES_ALL CODES,
    ap_tax_recvry_rules_all AP_RULES,
    ap_tax_recvry_rates_all AP_RATES,
    ZX_RATES_B  ZX_RATES,
    ZX_RULES_B  ZX_RULES,
    ZX_CONDITION_GROUPS_B GROUPS,
    zx_party_tax_profile ptp
WHERE
     CODES.TAX_ID               = NVL(ZX_RATES.SOURCE_ID, ZX_RATES.TAX_RATE_ID)
AND  CODES.TAX_RECOVERY_RULE_ID = AP_RULES.RULE_ID
AND  AP_RULES.RULE_ID           = AP_RATES.RULE_ID
AND  AP_RULES.NAME              = ZX_RULES.TAX_RULE_CODE
AND  ZX_RATES.TAX               = ZX_RULES.TAX
AND  ZX_RATES.TAX_REGIME_CODE   = ZX_RULES.TAX_REGIME_CODE
AND  ZX_RATES.CONTENT_OWNER_ID  = ZX_RULES.CONTENT_OWNER_ID
AND  PTP.PARTY_ID               = CODES.ORG_ID
--Added following conditions for Sync process
AND  codes.tax_id = nvl(p_tax_id,codes.tax_id)
AND  CODES.ORG_ID                = L_ORG_ID
AND  PTP.PARTY_TYPE_CODE        = 'OU'
AND  GROUPS.CONDITION_GROUP_CODE =
 (SELECT TEMP_GROUPS.CONDITION_GROUP_CODE
  FROM
     (SELECT  substrb(RULES1.NAME,1,24) || '-' || ROW_NUMBER()
              OVER (PARTITION BY RATES1.rule_id ORDER BY
                                 RATES1.rate_id)  CONDITION_GROUP_CODE,
              RULES1.RULE_ID,
              RATES1.RATE_ID
      FROM
             ap_tax_recvry_rules_all RULES1,
             ap_tax_recvry_rates_all RATES1
      WHERE
             RULES1.rule_id = RATES1.rule_id
     ) TEMP_GROUPS
  WHERE
       TEMP_GROUPS.RULE_ID = AP_RULES.RULE_ID
  AND  TEMP_GROUPS.RATE_ID = AP_RATES.RATE_ID
 )
 AND not exists (select 1 from zx_process_results
                 where tax_rule_id        = zx_rules.tax_rule_id
                 and condition_group_code = groups.condition_group_code
                 and alphanumeric_result  = 'STANDARD-' || AP_RATES.RECOVERY_RATE
                 )
);

END IF;
    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('create_rules(-)');
    END IF;

EXCEPTION
         WHEN OTHERS THEN
            IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Create_rules ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('create_rules(-)');
             END IF;
            --app_exception.raise_exception;
END create_rules;


/*==========================================================================+
|  Procedure   :    CREATE_TAX_ACCOUNTS                                     |
|                                                                           |
|  Description :    This procedure is used to insert the most frequently    |
|        used account information at taxes level               |
|                                  |
|  ARGUMENTS   :                   |
|                                                                           |
|  NOTES       :     This procedure was developed in response to            |
|         Bug No: 3700674                                      |
|                                                                           |
|  History     :                       |
|                                                                           |
|  Venkatavaradhan      24-Aug-04     Initial Version                       |
|                          |
============================================================================*/

PROCEDURE CREATE_TAX_ACCOUNTS
IS

-- Used to get the Account info. from Rates / account entity
CURSOR C_GET_AC_INFO IS
  SELECT
    tax_id,
    decode (rates.rate_type_code, 'RECOVERY',
      tax_account_ccid,
      non_rec_account_ccid) ac_id,
    tax_account_ccid,
    non_rec_account_ccid,
    ledger_id,
    accounts.internal_organization_id
  FROM
    ZX_ACCOUNTS accounts,
    ZX_RATES_B rates,
    ZX_TAXES_B taxes
  WHERE   taxes.tax                  = rates.tax
          and taxes.tax_regime_code  = rates.tax_regime_code
    and taxes.content_owner_id = rates.content_owner_id
    and rates.tax_rate_id      = accounts.tax_account_entity_id
    and accounts.tax_account_entity_code = 'RATES'
  ORDER BY
    taxes.tax_id, ac_id;
  -- Please note the order by condition in the above cursor



------------------------pl/sql table declarations----------------------------
TYPE tax_id_tab IS TABLE OF  ZX_TAXES_B.TAX_ID%TYPE
        INDEX BY BINARY_INTEGER;

TYPE ac_id_tab IS TABLE OF ZX_ACCOUNTS.TAX_ACCOUNT_CCID%TYPE
        INDEX BY BINARY_INTEGER;

TYPE ledger_id_tab IS TABLE OF ZX_ACCOUNTS.LEDGER_ID%TYPE
        INDEX BY BINARY_INTEGER;

TYPE org_id_tab IS TABLE OF ZX_ACCOUNTS.INTERNAL_ORGANIZATION_ID%TYPE
        INDEX BY BINARY_INTEGER;

-----The tables given below used to collect all account info. records-------

pg_tax_id_tab      tax_id_tab;
pg_ac_id_tab      ac_id_tab;
pg_tax_ac_id_tab    ac_id_tab;
pg_nonrec_ac_id_tab    ac_id_tab;
pg_ledger_id_tab    ledger_id_tab;
pg_org_id_tab      org_id_tab;

--The tables given below collect the final set of most frequently used accounts

pg_max_tax_id_tab    tax_id_tab;
pg_max_ac_id_tab    ac_id_tab;
pg_max_tax_ac_id_tab    ac_id_tab;
pg_max_nonrec_ac_id_tab    ac_id_tab;
pg_max_ledger_id_tab    ledger_id_tab;
pg_max_org_id_tab    org_id_tab;

-----------Variable declaration ---------------------
v_max_ac_count    number;
v_current_ac_count  number;
v_max_row_index    number;
v_count            number;
v_insert_flag    boolean;

v_prev_tax_id    ZX_TAXES_B.TAX_ID%TYPE;
v_prev_ac_id    ZX_ACCOUNTS.TAX_ACCOUNT_CCID%TYPE;
v_current_tax_id  ZX_TAXES_B.TAX_ID%TYPE;
v_current_ac_id    ZX_ACCOUNTS.TAX_ACCOUNT_CCID%TYPE;


BEGIN
  arp_util_tax.debug('Create Tax Accounts(+)');

v_max_ac_count    := 0;
v_current_ac_count  := 0;
v_count      := 0;
v_max_row_index    := 1;
v_insert_flag    := false;

--------------Fetch all records into PL sql tables-----------------
OPEN C_GET_AC_INFO;

FETCH C_GET_AC_INFO BULK COLLECT INTO
  pg_tax_id_tab,
  pg_ac_id_tab,
  pg_tax_ac_id_tab,
  pg_nonrec_ac_id_tab,
  pg_ledger_id_tab,
  pg_org_id_tab ;

FOR i IN 1..nvl(pg_tax_id_tab.last, 0)
LOOP
  -- Get the first record info.
  IF i = 1 THEN
    v_prev_tax_id     := pg_tax_id_tab(1);
    v_prev_ac_id     := pg_ac_id_tab(1);
    v_current_ac_count := 1;
  END IF;

  v_current_tax_id   := pg_tax_id_tab(i);
  v_current_ac_id     := pg_ac_id_tab(i);

  -- if current tax id and previous tax id's are same then
  IF v_prev_tax_id = v_current_tax_id THEN

    /* if current and previous account id's are same then
    increment the current ac counter variable */
    IF v_prev_ac_id = v_current_ac_id THEN
      v_current_ac_count := v_current_ac_count + 1;
    ELSE
      /* if current account id is different from previous
      account id then check if current ac count is greater
      than the max ac counter then store the previous row
      index into max row index variable.
      */
      IF v_current_ac_count > v_max_ac_count THEN
        v_max_ac_count     := v_current_ac_count;
        v_current_ac_count := 1;
        IF i <> 1 THEN
            v_max_row_index    := i-1;
        END IF;
      END IF;
    END IF;

  ELSE
    IF v_current_ac_count > v_max_ac_count THEN
         IF i <> 1 THEN
      v_max_row_index    := i-1;
         END IF;
    END IF;

    -- This counter is used to keep track the final result table
    v_count        := v_count+1;
    -- move the max account info details to final result set
    pg_max_tax_id_tab(v_count)  := pg_tax_id_tab(v_max_row_index);
    pg_max_tax_ac_id_tab(v_count)  := pg_tax_ac_id_tab(v_max_row_index);
    pg_max_nonrec_ac_id_tab(v_count):= pg_nonrec_ac_id_tab(v_max_row_index);
    pg_max_ledger_id_tab(v_count)  := pg_ledger_id_tab(v_max_row_index);
    pg_max_org_id_tab(v_count)  := pg_org_id_tab(v_max_row_index);
    -- Reset the values
    v_max_row_index    := i;
    v_max_ac_count    := 0;
    v_current_ac_count  := 1;
    -- This condition is used to handle the last record insert
    IF i = pg_tax_id_tab.last THEN
      v_insert_flag  := false;
    ELSE
      v_insert_flag  := true;
    END IF;

  END IF;

  v_prev_tax_id := v_current_tax_id;
  v_prev_ac_id  := v_current_ac_id;

END LOOP;

/*This condition is used to handle the last record and only
one max account record case*/
IF nvl(pg_tax_id_tab.first,0) > 0 AND not v_insert_flag THEN
  v_count        := v_count+1;
  pg_max_tax_id_tab(v_count)  := pg_tax_id_tab(v_max_row_index);
  pg_max_tax_ac_id_tab(v_count)  := pg_tax_ac_id_tab(v_max_row_index);
  pg_max_nonrec_ac_id_tab(v_count):= pg_nonrec_ac_id_tab(v_max_row_index);
  pg_max_ledger_id_tab(v_count)  := pg_ledger_id_tab(v_max_row_index);
  pg_max_org_id_tab(v_count)  := pg_org_id_tab(v_max_row_index);

END IF;

FORALL j IN 1..nvl(pg_max_tax_id_tab.last,0)

  INSERT INTO ZX_ACCOUNTS
  (
    TAX_ACCOUNT_ENTITY_CODE,
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
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
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
    PROGRAM_LOGIN_ID,
    TAX_ACCOUNT_ID,
    TAX_ACCOUNT_ENTITY_ID,
    LEDGER_ID,
    INTERNAL_ORGANIZATION_ID,
    OBJECT_VERSION_NUMBER
  )
  (SELECT
    'TAXES',
    pg_max_tax_ac_id_tab(j),
    NULL,
    pg_max_nonrec_ac_id_tab(j),
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'MIGRATED',
    fnd_global.user_id,
    SYSDATE,
    fnd_global.user_id,
    SYSDATE,
    fnd_global.conc_login_id,
    fnd_global.conc_request_id,
    fnd_global.prog_appl_id,
    fnd_global.conc_program_id,
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
    fnd_global.conc_login_id,
    zx_accounts_s.nextval,
    pg_max_tax_id_tab(j),
    pg_max_ledger_id_tab(j),
    pg_max_org_id_tab(j),
    1

  FROM DUAL WHERE NOT EXISTS
    ( SELECT NULL FROM ZX_ACCOUNTS accounts
      WHERE accounts.TAX_ACCOUNT_ENTITY_CODE = 'TAXES' and
            accounts.TAX_ACCOUNT_ENTITY_ID   = pg_max_tax_id_tab(j)
    )
  );
  arp_util_tax.debug('Create Tax Accounts(-)');

END ;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    migrate_disabled_tax_codes                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine is used to migrate disabled tax codes with overlapping   |
 |     into zx_rates_b                         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        migrate_disabled_tax_codes                                         |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     30-Sep-05  Arnab Sengupta      Created.                               |
 |                                                                           |
 |==========================================================================*/

 PROCEDURE migrate_disabled_tax_codes(p_tax_id IN NUMBER DEFAULT NULL) IS

 TYPE  tax_id_table is table of ap_tax_codes_all.tax_id%TYPE index by BINARY_INTEGER;
 tax_id_tab tax_id_table ;
 l_min_start_date date;
 l_max_end_date   date;



 /*The purpose of the following cursor is to pick up data sets in which tax codes are disabled
   and these records have identical org_id set_of_books_id and name but differ only in their
   effective from and effective to dates .These date ranges however overlap*/

/*   Sample Data Set

ORG_ID SOB NAME      START_DATE INACTIVE_DATE ENABLED_FLAG TAX_RATE
====== === ====      ========== ============= ============ ========
204  1  CA-Sales  04-JAN-51  07-JAN-51         N          0
204  1  CA-Sales  NULL       NULL              N          10
204  1  CA-Sales  01-JAN-51  11-JAN-51         N          15

Records 1 and 3 are a case of overlap */




  CURSOR tax_id_csr
  IS
  select aptax2.tax_id tax_id
  from
  (
    select DISTINCT org_id,set_of_books_id,name
    from   ap_tax_codes_all a
    where a.enabled_flag = 'N'
    and    exists
    (
      select 1 from ap_tax_codes_all b
           where  a.org_id = b.org_id
             and    a.set_of_books_id = b.set_of_books_id
             and    a.name =  b.name
             and
        (          (    Nvl(a.START_DATE,l_min_start_date) > Nvl(b.START_DATE,l_min_start_date)
              and Nvl(a.INACTIVE_DATE,l_max_end_date)  < Nvl(b.INACTIVE_DATE,l_max_end_date))

               or  (    Nvl(a.START_DATE,l_min_start_date) < Nvl(b.START_DATE,l_min_start_date)
              and Nvl(a.INACTIVE_DATE,l_max_end_date) > Nvl(b.START_DATE,l_max_end_date)
              and Nvl(a.INACTIVE_DATE,l_max_end_date) <Nvl(b.INACTIVE_DATE,l_max_end_date))

               or (     Nvl(a.START_DATE,l_min_start_date) > Nvl(b.START_DATE,l_min_start_date)
              and Nvl(a.START_DATE,l_min_start_date) <Nvl(b.INACTIVE_DATE,l_max_end_date)
              and Nvl(a.INACTIVE_DATE,l_max_end_date) >Nvl(b.INACTIVE_DATE,l_max_end_date))
                     )
    and     b.enabled_flag = 'N'
                )
    and     exists
    (select c.org_id,c.set_of_books_id,c.name ,count(c.org_id) from ap_tax_codes_all c
       where        a.org_id                 = c.org_id
             and    a.set_of_books_id        = c.set_of_books_id
             and    a.name                   = c.name
       group by c.org_id,c.set_of_books_id,c.name
       having count(c.org_id) > 1)
  )
  aptax1,
  ap_tax_codes_all aptax2
  where
    aptax1.org_id           =   aptax2.org_id
  and  aptax1.set_of_books_id  =        aptax2.set_of_books_id
  and  aptax1.  name            =        aptax2.  name
  ;


 BEGIN
    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('Migrate_Disabled_Tax_Codes');
    END IF;

          BEGIN
         SELECT  sysdate-999999  into l_min_start_date from dual;
         SELECT  sysdate+999999  into l_max_end_date   from dual;
    EXCEPTION WHEN OTHERS THEN
         NULL;
          END;

    BEGIN

    OPEN tax_id_csr;
    FETCH tax_id_csr
    BULK COLLECT INTO tax_id_tab;

          EXCEPTION WHEN OTHERS THEN
          arp_util_tax.debug('Failed to open the tax_id_csr in migrate_disabled_tax_codes');
    END;




FOR i in 1..nvl(tax_id_tab.last,0)
LOOP

--BugFix 3605729
IF ID_CLASH = 'Y' THEN

BEGIN

IF L_MULTI_ORG_FLAG = 'Y'
THEN

INSERT ALL
INTO zx_rates_b_tmp
(
    TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
    --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  SOURCE_ID                      ,--BugFix 3605729
  TAX_CLASS                      ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
    --BugFix 3426244
  ADJ_FOR_ADHOC_AMT_CODE             ,
  ALLOW_ADHOC_TAX_RATE_FLAG    ,
  OBJECT_VERSION_NUMBER
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
VALUES
(
    TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  TAX_RATE_ID                    ,
       'INPUT'                         ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  zx_rates_b_s.nextval           ,--TAX_RATE_ID
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
  'TAX_RATE'                      ,
  'Y'        ,-- ALLOW_ADHOC_TAX_RATE_FLAG
  1
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
INTO zx_accounts
(
    TAX_ACCOUNT_ID                 ,
  TAX_ACCOUNT_ENTITY_ID          ,
  TAX_ACCOUNT_ENTITY_CODE        ,
  LEDGER_ID                      ,
  INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
  TAX_ACCOUNT_CCID               ,
  INTERIM_TAX_CCID               ,
  NON_REC_ACCOUNT_CCID           ,
  ADJ_CCID                       ,
  EDISC_CCID                     ,
  UNEDISC_CCID                   ,
  FINCHRG_CCID                   ,
  ADJ_NON_REC_TAX_CCID           ,
  EDISC_NON_REC_TAX_CCID         ,
  UNEDISC_NON_REC_TAX_CCID       ,
  FINCHRG_NON_REC_TAX_CCID       ,
  RECORD_TYPE_CODE               ,
  ATTRIBUTE1             ,
  ATTRIBUTE2             ,
  ATTRIBUTE3             ,
  ATTRIBUTE4             ,
  ATTRIBUTE5             ,
  ATTRIBUTE6             ,
  ATTRIBUTE7             ,
  ATTRIBUTE8             ,
  ATTRIBUTE9             ,
  ATTRIBUTE10            ,
  ATTRIBUTE11            ,
  ATTRIBUTE12            ,
  ATTRIBUTE13            ,
  ATTRIBUTE14            ,
  ATTRIBUTE15            ,
  ATTRIBUTE_CATEGORY,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID    ,
  OBJECT_VERSION_NUMBER
)
VALUES
(
        ZX_ACCOUNTS_S.nextval ,
        zx_rates_b_s.nextval  ,--TAX_RATE_ID
        'RATES'                ,
         LEDGER_ID            ,
         ORG_ID               ,
         TAX_ACCOUNT_CCID     ,
         NULL                 ,
         NON_REC_ACCOUNT_CCID ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         RECORD_TYPE_CODE     ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
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
      results.tax_code_id             TAX_RATE_ID,
      results.tax_code||'-'||results.tax_code_id TAX_RATE_CODE, --Bug 4942908
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
      'N'                            SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                 DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                 DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                       DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID, --Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ar_vat_tax_all_b   ar_codes,
    ap_tax_recvry_rules_all rec_rules,
    financials_system_params_all fsp,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = tax_id_tab(i)
and  results.tax_code_id = codes.tax_id
and  results.tax_class = 'INPUT'
and  codes.tax_id  = ar_codes.vat_tax_id
and  codes.offset_tax_code_id IS NULL
AND  codes.tax_recovery_rule_id  = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id = fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'
--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
AND  not exists (select 1 from zx_rates_b
                 where  source_id =  nvl(p_tax_id,codes.tax_id)
                )
UNION ALL

SELECT
      results.tax_code_id              TAX_RATE_ID,
      results.tax_code||'-'||results.tax_code_id TAX_RATE_CODE, --Bug 4942908
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
     'N'                             SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                           DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                           DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
     offset.tax                      OFFSET_TAX    ,
     offset.tax_status_code          OFFSET_STATUS_CODE ,
     offset.tax_code                 OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196

FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ar_vat_tax_all_b   ar_codes,
    zx_update_criteria_results offset,
    financials_system_params_all fsp,
    ap_tax_recvry_rules_all rec_rules,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = tax_id_tab(i)
AND  results.tax_code_id = codes.tax_id
AND  results.tax_class = 'INPUT'
AND  results.tax_class = offset.tax_class  -- Condition added for Bug#7115321
AND  codes.tax_id = ar_codes.vat_tax_id
AND  codes.offset_tax_code_id       = offset.tax_code_id
AND  codes.tax_recovery_rule_id     = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id =  fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'
--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
AND  not exists (select 1 from zx_rates_b
                 where  source_id  =  nvl(p_tax_id,codes.tax_id)
                ) ;

 ELSE
 INSERT ALL
INTO zx_rates_b_tmp
(
    TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
    --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  SOURCE_ID                      ,--BugFix 3605729
  TAX_CLASS                      ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
      --BugFix 3426244
    ADJ_FOR_ADHOC_AMT_CODE             ,
    ALLOW_ADHOC_TAX_RATE_FLAG    ,
    OBJECT_VERSION_NUMBER
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
VALUES
(
    TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  TAX_RATE_ID                    ,
       'INPUT'                         ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  zx_rates_b_s.nextval           ,--TAX_RATE_ID
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
       'TAX_RATE'                      ,
       'Y'        ,-- ALLOW_ADHOC_TAX_RATE_FLAG
  1
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
INTO zx_accounts
(
    TAX_ACCOUNT_ID                 ,
  TAX_ACCOUNT_ENTITY_ID          ,
  TAX_ACCOUNT_ENTITY_CODE        ,
  LEDGER_ID                      ,
  INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
  TAX_ACCOUNT_CCID               ,
  INTERIM_TAX_CCID               ,
  NON_REC_ACCOUNT_CCID           ,
  ADJ_CCID                       ,
  EDISC_CCID                     ,
  UNEDISC_CCID                   ,
  FINCHRG_CCID                   ,
  ADJ_NON_REC_TAX_CCID           ,
  EDISC_NON_REC_TAX_CCID         ,
  UNEDISC_NON_REC_TAX_CCID       ,
  FINCHRG_NON_REC_TAX_CCID       ,
  RECORD_TYPE_CODE               ,
  ATTRIBUTE1             ,
  ATTRIBUTE2             ,
  ATTRIBUTE3             ,
  ATTRIBUTE4             ,
  ATTRIBUTE5             ,
  ATTRIBUTE6             ,
  ATTRIBUTE7             ,
  ATTRIBUTE8             ,
  ATTRIBUTE9             ,
  ATTRIBUTE10            ,
  ATTRIBUTE11            ,
  ATTRIBUTE12            ,
  ATTRIBUTE13            ,
  ATTRIBUTE14            ,
  ATTRIBUTE15            ,
  ATTRIBUTE_CATEGORY,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID    ,
  OBJECT_VERSION_NUMBER
)
VALUES
(
        ZX_ACCOUNTS_S.nextval ,
        zx_rates_b_s.nextval  ,--TAX_RATE_ID
        'RATES'                ,
         LEDGER_ID            ,
         ORG_ID               ,
         TAX_ACCOUNT_CCID     ,
         NULL                 ,
         NON_REC_ACCOUNT_CCID ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         RECORD_TYPE_CODE     ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
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
      results.tax_code_id             TAX_RATE_ID,
      results.tax_code||'-'||results.tax_code_id TAX_RATE_CODE, --Bug 4942908
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
      'N'                            SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                 DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                 DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                       DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID, --Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ar_vat_tax_all_b   ar_codes,
    ap_tax_recvry_rules_all rec_rules,
    financials_system_params_all fsp,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = tax_id_tab(i)
and  results.tax_code_id = codes.tax_id
and  results.tax_class = 'INPUT'
and  codes.tax_id  = ar_codes.vat_tax_id
and  codes.offset_tax_code_id IS NULL
AND  codes.tax_recovery_rule_id  = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id = l_org_id
AND  codes.org_id = fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'
--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
AND  not exists (select 1 from zx_rates_b
                 where  source_id =  nvl(p_tax_id,codes.tax_id)
                )
UNION ALL

SELECT
      results.tax_code_id              TAX_RATE_ID,
      results.tax_code||'-'||results.tax_code_id TAX_RATE_CODE, --Bug 4942908
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
     'N'                             SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                           DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                           DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
     offset.tax                      OFFSET_TAX    ,
     offset.tax_status_code          OFFSET_STATUS_CODE ,
     offset.tax_code                 OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196

FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ar_vat_tax_all_b   ar_codes,
    zx_update_criteria_results offset,
    financials_system_params_all fsp,
    ap_tax_recvry_rules_all rec_rules,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = tax_id_tab(i)
AND  results.tax_code_id = codes.tax_id
AND  results.tax_class = 'INPUT'
AND  results.tax_class = offset.tax_class  -- Condition added for Bug#7115321
AND  codes.tax_id = ar_codes.vat_tax_id
AND  codes.offset_tax_code_id       = offset.tax_code_id
AND  codes.tax_recovery_rule_id     = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id =  l_org_id
AND  codes.org_id =  fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'
--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
AND  not exists (select 1 from zx_rates_b
                 where  source_id  =  nvl(p_tax_id,codes.tax_id)
                ) ;
 END IF;
 EXCEPTION WHEN OTHERS THEN
    arp_util_tax.debug('Encountered error in the ID clash insert for disabled tax codes'||sqlerrm);
END ;
END IF;


BEGIN

IF L_MULTI_ORG_FLAG = 'Y'
THEN

INSERT ALL
INTO zx_rates_b_tmp
(
    TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
    TAX_CLASS                      , --Bug 3987672
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
     --BugFix 3426244
    ADJ_FOR_ADHOC_AMT_CODE         ,
    ALLOW_ADHOC_TAX_RATE_FLAG       ,
    OBJECT_VERSION_NUMBER           ,
    --Bug 4241667 : SOURCE_ID = TAX_RATE_ID for AP TAX CODES
    SOURCE_ID
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
VALUES
(
    TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
    'INPUT'                        ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
  'TAX_RATE'                      ,
  'Y'        , --ALLOW_ADHOC_TAX_RATE_FLAG
  1                               ,
        --Bug 4241667 : SOURCE_ID = TAX_RATE_ID for AP TAX CODES
        TAX_RATE_ID
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
INTO zx_accounts
(
    TAX_ACCOUNT_ID                 ,
  TAX_ACCOUNT_ENTITY_ID          ,
  TAX_ACCOUNT_ENTITY_CODE        ,
  LEDGER_ID                      ,
  INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
  TAX_ACCOUNT_CCID               ,
  INTERIM_TAX_CCID               ,
  NON_REC_ACCOUNT_CCID           ,
  ADJ_CCID                       ,
  EDISC_CCID                     ,
  UNEDISC_CCID                   ,
  FINCHRG_CCID                   ,
  ADJ_NON_REC_TAX_CCID           ,
  EDISC_NON_REC_TAX_CCID         ,
  UNEDISC_NON_REC_TAX_CCID       ,
  FINCHRG_NON_REC_TAX_CCID       ,
  RECORD_TYPE_CODE               ,
  ATTRIBUTE1             ,
  ATTRIBUTE2             ,
  ATTRIBUTE3             ,
  ATTRIBUTE4             ,
  ATTRIBUTE5             ,
  ATTRIBUTE6             ,
  ATTRIBUTE7             ,
  ATTRIBUTE8             ,
  ATTRIBUTE9             ,
  ATTRIBUTE10            ,
  ATTRIBUTE11            ,
  ATTRIBUTE12            ,
  ATTRIBUTE13            ,
  ATTRIBUTE14            ,
  ATTRIBUTE15            ,
  ATTRIBUTE_CATEGORY,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID    ,
  OBJECT_VERSION_NUMBER
)
VALUES
(
        ZX_ACCOUNTS_S.nextval ,
        TAX_RATE_ID           ,
        'RATES'                ,
         LEDGER_ID            ,
         ORG_ID               ,
         TAX_ACCOUNT_CCID     ,
         NULL                 ,
         NON_REC_ACCOUNT_CCID ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         RECORD_TYPE_CODE     ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
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
      results.tax_code_id                 TAX_RATE_ID,
      results.tax_code||'-'||results.tax_code_id TAX_RATE_CODE, --Bug 4942908
      ptp.party_tax_profile_id            CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
      'N'                            SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                           DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                       DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ap_tax_recvry_rules_all rec_rules,
    financials_system_params_all fsp,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = tax_id_tab(i)
AND  results.tax_code_id = codes.tax_id
AND  results.tax_class = 'INPUT'
AND  codes.offset_tax_code_id IS NULL
AND  codes.tax_recovery_rule_id  = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id = fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'

--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
--BugFix 3605729 added nvl(source_id, in the following condition.
AND  not exists (select 1 from zx_rates_b
                 where  nvl(source_id,tax_rate_id) =  nvl(p_tax_id,codes.tax_id)
                )
UNION ALL

SELECT
      results.tax_code_id             TAX_RATE_ID,
      results.tax_code||'-'||results.tax_code_id TAX_RATE_CODE, --Bug 4942908
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
     'N'                             SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                           DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                           DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
      offset.tax                     OFFSET_TAX    ,
      offset.tax_status_code         OFFSET_STATUS_CODE ,
      offset.tax_code                OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196

FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    zx_update_criteria_results offset,
    financials_system_params_all fsp,
    ap_tax_recvry_rules_all rec_rules,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id            = tax_id_tab(i)
AND  results.tax_code_id            = codes.tax_id
AND  results.tax_class = 'INPUT'
AND  results.tax_class = offset.tax_class  -- Condition added for Bug#7115321
AND  codes.offset_tax_code_id       = offset.tax_code_id
AND  codes.tax_recovery_rule_id     = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id =  fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'

--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
--BugFix 3605729 added nvl(source_id, in the following condition.
AND  not exists (select 1 from zx_rates_b
                 where  nvl(source_id,tax_rate_id) =  nvl(p_tax_id,codes.tax_id)
                );
ELSE

INSERT ALL
INTO zx_rates_b_tmp
(
    TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
    TAX_CLASS                      , --Bug 3987672
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
     --BugFix 3426244
    ADJ_FOR_ADHOC_AMT_CODE         ,
    ALLOW_ADHOC_TAX_RATE_FLAG       ,
    OBJECT_VERSION_NUMBER           ,
    --Bug 4241667 : SOURCE_ID = TAX_RATE_ID for AP TAX CODES
    SOURCE_ID
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
VALUES
(
    TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
    'INPUT'                        ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
  'TAX_RATE'                      ,
  'Y'        , --ALLOW_ADHOC_TAX_RATE_FLAG
  1                               ,
        --Bug 4241667 : SOURCE_ID = TAX_RATE_ID for AP TAX CODES
        TAX_RATE_ID
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
INTO zx_accounts
(
    TAX_ACCOUNT_ID                 ,
  TAX_ACCOUNT_ENTITY_ID          ,
  TAX_ACCOUNT_ENTITY_CODE        ,
  LEDGER_ID                      ,
  INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
  TAX_ACCOUNT_CCID               ,
  INTERIM_TAX_CCID               ,
  NON_REC_ACCOUNT_CCID           ,
  ADJ_CCID                       ,
  EDISC_CCID                     ,
  UNEDISC_CCID                   ,
  FINCHRG_CCID                   ,
  ADJ_NON_REC_TAX_CCID           ,
  EDISC_NON_REC_TAX_CCID         ,
  UNEDISC_NON_REC_TAX_CCID       ,
  FINCHRG_NON_REC_TAX_CCID       ,
  RECORD_TYPE_CODE               ,
  ATTRIBUTE1             ,
  ATTRIBUTE2             ,
  ATTRIBUTE3             ,
  ATTRIBUTE4             ,
  ATTRIBUTE5             ,
  ATTRIBUTE6             ,
  ATTRIBUTE7             ,
  ATTRIBUTE8             ,
  ATTRIBUTE9             ,
  ATTRIBUTE10            ,
  ATTRIBUTE11            ,
  ATTRIBUTE12            ,
  ATTRIBUTE13            ,
  ATTRIBUTE14            ,
  ATTRIBUTE15            ,
  ATTRIBUTE_CATEGORY,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID    ,
  OBJECT_VERSION_NUMBER
)
VALUES
(
        ZX_ACCOUNTS_S.nextval ,
        TAX_RATE_ID           ,
        'RATES'                ,
         LEDGER_ID            ,
         ORG_ID               ,
         TAX_ACCOUNT_CCID     ,
         NULL                 ,
         NON_REC_ACCOUNT_CCID ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         RECORD_TYPE_CODE     ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
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
      results.tax_code_id                 TAX_RATE_ID,
      results.tax_code||'-'||results.tax_code_id TAX_RATE_CODE, --Bug 4942908
      ptp.party_tax_profile_id            CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
      'N'                            SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                           DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                       DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ap_tax_recvry_rules_all rec_rules,
    financials_system_params_all fsp,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = tax_id_tab(i)
AND  results.tax_code_id = codes.tax_id
AND  results.tax_class = 'INPUT'
AND  codes.offset_tax_code_id IS NULL
AND  codes.tax_recovery_rule_id  = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id = l_org_id
AND  codes.org_id = fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'

--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
--BugFix 3605729 added nvl(source_id, in the following condition.
AND  not exists (select 1 from zx_rates_b
                 where  nvl(source_id,tax_rate_id) =  nvl(p_tax_id,codes.tax_id)
                )
UNION ALL

SELECT
      results.tax_code_id             TAX_RATE_ID,
      results.tax_code||'-'||results.tax_code_id TAX_RATE_CODE, --Bug 4942908
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
     'N'                             SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                           DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                           DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
      offset.tax                     OFFSET_TAX    ,
      offset.tax_status_code         OFFSET_STATUS_CODE ,
      offset.tax_code                OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196

FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    zx_update_criteria_results offset,
    financials_system_params_all fsp,
    ap_tax_recvry_rules_all rec_rules,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id            = tax_id_tab(i)
AND  results.tax_code_id            = codes.tax_id
AND  results.tax_class = 'INPUT'
AND  results.tax_class = offset.tax_class  -- Condition added for Bug#7115321
AND  codes.offset_tax_code_id       = offset.tax_code_id
AND  codes.tax_recovery_rule_id     = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id =  l_org_id
AND  codes.org_id =  fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'

--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
--BugFix 3605729 added nvl(source_id, in the following condition.
AND  not exists (select 1 from zx_rates_b
                 where  nvl(source_id,tax_rate_id) =  nvl(p_tax_id,codes.tax_id)
                );


END IF;

EXCEPTION WHEN OTHERS THEN
      arp_util_tax.debug('Caught an error in the non id clash portion for the disabled tax codes'||sqlerrm);
END;

END LOOP;




/*This portion of the code handles non overlapped date tax codes which are disabled*/

IF ID_CLASH = 'Y' THEN
 IF L_MULTI_ORG_FLAG = 'Y' THEN

BEGIN
INSERT ALL
INTO zx_rates_b_tmp
(
    TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
    --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  SOURCE_ID                      ,--BugFix 3605729
  TAX_CLASS                      ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
      --BugFix 3426244
    ADJ_FOR_ADHOC_AMT_CODE             ,
    ALLOW_ADHOC_TAX_RATE_FLAG    ,
    OBJECT_VERSION_NUMBER
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
VALUES
(
    TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  TAX_RATE_ID                    ,
       'INPUT'                         ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  zx_rates_b_s.nextval           ,--TAX_RATE_ID
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
       'TAX_RATE'                      ,
       'Y'        ,-- ALLOW_ADHOC_TAX_RATE_FLAG
  1
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
INTO zx_accounts
(
    TAX_ACCOUNT_ID                 ,
  TAX_ACCOUNT_ENTITY_ID          ,
  TAX_ACCOUNT_ENTITY_CODE        ,
  LEDGER_ID                      ,
  INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
  TAX_ACCOUNT_CCID               ,
  INTERIM_TAX_CCID               ,
  NON_REC_ACCOUNT_CCID           ,
  ADJ_CCID                       ,
  EDISC_CCID                     ,
  UNEDISC_CCID                   ,
  FINCHRG_CCID                   ,
  ADJ_NON_REC_TAX_CCID           ,
  EDISC_NON_REC_TAX_CCID         ,
  UNEDISC_NON_REC_TAX_CCID       ,
  FINCHRG_NON_REC_TAX_CCID       ,
  RECORD_TYPE_CODE               ,
  ATTRIBUTE1             ,
  ATTRIBUTE2             ,
  ATTRIBUTE3             ,
  ATTRIBUTE4             ,
  ATTRIBUTE5             ,
  ATTRIBUTE6             ,
  ATTRIBUTE7             ,
  ATTRIBUTE8             ,
  ATTRIBUTE9             ,
  ATTRIBUTE10            ,
  ATTRIBUTE11            ,
  ATTRIBUTE12            ,
  ATTRIBUTE13            ,
  ATTRIBUTE14            ,
  ATTRIBUTE15            ,
  ATTRIBUTE_CATEGORY,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID    ,
  OBJECT_VERSION_NUMBER
)
VALUES
(
        ZX_ACCOUNTS_S.nextval ,
        zx_rates_b_s.nextval  ,--TAX_RATE_ID
        'RATES'                ,
         LEDGER_ID            ,
         ORG_ID               ,
         TAX_ACCOUNT_CCID     ,
         NULL                 ,
         NON_REC_ACCOUNT_CCID ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         RECORD_TYPE_CODE     ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
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
      results.tax_code_id             TAX_RATE_ID,
      results.tax_code||'-'||results.tax_code_id TAX_RATE_CODE, --Bug 4942908
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
      'N'                            SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                 DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                 DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                       DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID, --Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ar_vat_tax_all_b   ar_codes,
    ap_tax_recvry_rules_all rec_rules,
    financials_system_params_all fsp,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = codes.tax_id
AND  codes.enabled_flag = 'N'
and  results.tax_class = 'INPUT'
and  codes.tax_id  = ar_codes.vat_tax_id
and  codes.offset_tax_code_id IS NULL
AND  codes.tax_recovery_rule_id  = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id = fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'
--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
AND  not exists (select 1 from zx_rates_b
                 where  source_id =  nvl(p_tax_id,codes.tax_id)
                )
UNION ALL

SELECT
      results.tax_code_id            TAX_RATE_ID,
     results.tax_code||'-'||results.tax_code_id TAX_RATE_CODE, --Bug 4942908
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
     'N'                             SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                           DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                           DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
      offset.tax                     OFFSET_TAX    ,
      offset.tax_status_code         OFFSET_STATUS_CODE ,
      offset.tax_code                OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ar_vat_tax_all_b   ar_codes,
    zx_update_criteria_results offset,
    financials_system_params_all fsp,
    ap_tax_recvry_rules_all rec_rules,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = codes.tax_id
AND  codes.enabled_flag = 'N'
AND  results.tax_class = 'INPUT'
AND  results.tax_class = offset.tax_class  -- Condition added for Bug#7115321
AND  codes.tax_id = ar_codes.vat_tax_id
AND  codes.offset_tax_code_id       = offset.tax_code_id
AND  codes.tax_recovery_rule_id     = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id = fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'
--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
AND  not exists (select 1 from zx_rates_b
                 where  source_id  =  nvl(p_tax_id,codes.tax_id)
                ) ;
EXCEPTION WHEN OTHERS THEN
      arp_util_tax.debug('Caught an error in the id clash portion for the disabled tax codes
                           with no date overlap'||sqlerrm);
END;
ELSE
BEGIN
INSERT ALL
INTO zx_rates_b_tmp
(
    TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
    --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  SOURCE_ID                      ,--BugFix 3605729
  TAX_CLASS                      ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
      --BugFix 3426244
    ADJ_FOR_ADHOC_AMT_CODE             ,
    ALLOW_ADHOC_TAX_RATE_FLAG    ,
    OBJECT_VERSION_NUMBER
    --,    DESCRIPTION -- Bug 4705196
)
VALUES
(
    TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
  TAX_RATE_ID                    ,
       'INPUT'                         ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  zx_rates_b_s.nextval           ,--TAX_RATE_ID
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
       'TAX_RATE'                      ,
       'Y'        ,-- ALLOW_ADHOC_TAX_RATE_FLAG
  1
  --  ,  DESCRIPTION -- Bug 4705196
)
INTO zx_accounts
(
    TAX_ACCOUNT_ID                 ,
  TAX_ACCOUNT_ENTITY_ID          ,
  TAX_ACCOUNT_ENTITY_CODE        ,
  LEDGER_ID                      ,
  INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
  TAX_ACCOUNT_CCID               ,
  INTERIM_TAX_CCID               ,
  NON_REC_ACCOUNT_CCID           ,
  ADJ_CCID                       ,
  EDISC_CCID                     ,
  UNEDISC_CCID                   ,
  FINCHRG_CCID                   ,
  ADJ_NON_REC_TAX_CCID           ,
  EDISC_NON_REC_TAX_CCID         ,
  UNEDISC_NON_REC_TAX_CCID       ,
  FINCHRG_NON_REC_TAX_CCID       ,
  RECORD_TYPE_CODE               ,
  ATTRIBUTE1             ,
  ATTRIBUTE2             ,
  ATTRIBUTE3             ,
  ATTRIBUTE4             ,
  ATTRIBUTE5             ,
  ATTRIBUTE6             ,
  ATTRIBUTE7             ,
  ATTRIBUTE8             ,
  ATTRIBUTE9             ,
  ATTRIBUTE10            ,
  ATTRIBUTE11            ,
  ATTRIBUTE12            ,
  ATTRIBUTE13            ,
  ATTRIBUTE14            ,
  ATTRIBUTE15            ,
  ATTRIBUTE_CATEGORY,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID    ,
  OBJECT_VERSION_NUMBER
)
VALUES
(
        ZX_ACCOUNTS_S.nextval ,
        zx_rates_b_s.nextval  ,--TAX_RATE_ID
        'RATES'                ,
         LEDGER_ID            ,
         ORG_ID               ,
         TAX_ACCOUNT_CCID     ,
         NULL                 ,
         NON_REC_ACCOUNT_CCID ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         RECORD_TYPE_CODE     ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
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
      results.tax_code_id             TAX_RATE_ID,
      results.tax_code||'-'||results.tax_code_id TAX_RATE_CODE, --Bug 4942908
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
      'N'                            SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                 DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                 DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                       DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID, --Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ar_vat_tax_all_b   ar_codes,
    ap_tax_recvry_rules_all rec_rules,
    financials_system_params_all fsp,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = codes.tax_id
AND  codes.enabled_flag = 'N'
and  results.tax_class = 'INPUT'
and  codes.tax_id  = ar_codes.vat_tax_id
and  codes.offset_tax_code_id IS NULL
AND  codes.tax_recovery_rule_id  = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id = l_org_id
AND  codes.org_id = fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'
--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
AND  not exists (select 1 from zx_rates_b
                 where  source_id =  nvl(p_tax_id,codes.tax_id)
                )
UNION ALL

SELECT
      results.tax_code_id            TAX_RATE_ID,
     results.tax_code||'-'||results.tax_code_id TAX_RATE_CODE, --Bug 4942908
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
     'N'                             SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                           DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                           DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
      offset.tax                     OFFSET_TAX    ,
      offset.tax_status_code         OFFSET_STATUS_CODE ,
      offset.tax_code                OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ar_vat_tax_all_b   ar_codes,
    zx_update_criteria_results offset,
    financials_system_params_all fsp,
    ap_tax_recvry_rules_all rec_rules,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = codes.tax_id
AND  codes.enabled_flag = 'N'
AND  results.tax_class = 'INPUT'
AND  results.tax_class = offset.tax_class  -- Condition added for Bug#7115321
AND  codes.tax_id = ar_codes.vat_tax_id
AND  codes.offset_tax_code_id       = offset.tax_code_id
AND  codes.tax_recovery_rule_id     = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id = l_org_id
AND  codes.org_id = fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'
--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
AND  not exists (select 1 from zx_rates_b
                 where  source_id  =  nvl(p_tax_id,codes.tax_id)
                ) ;
EXCEPTION WHEN OTHERS THEN
      arp_util_tax.debug('Caught an error in the id clash portion for the disabled tax codes
                           with no date overlap'||sqlerrm);
END;


END IF;
END IF;


BEGIN

IF L_MULTI_ORG_FLAG = 'Y'
THEN

INSERT ALL
INTO zx_rates_b_tmp
(
    TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
    TAX_CLASS                      , --Bug 3987672
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
     --BugFix 3426244
    ADJ_FOR_ADHOC_AMT_CODE         ,
    ALLOW_ADHOC_TAX_RATE_FLAG       ,
    OBJECT_VERSION_NUMBER           ,
    --Bug 4241667 : SOURCE_ID = TAX_RATE_ID for AP TAX CODES
    SOURCE_ID
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
VALUES
(
    TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
    'INPUT'                        ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
  'TAX_RATE'                      ,
  'Y'        , --ALLOW_ADHOC_TAX_RATE_FLAG
  1                               ,
        --Bug 4241667 : SOURCE_ID = TAX_RATE_ID for AP TAX CODES
        TAX_RATE_ID
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
INTO zx_accounts
(
    TAX_ACCOUNT_ID                 ,
  TAX_ACCOUNT_ENTITY_ID          ,
  TAX_ACCOUNT_ENTITY_CODE        ,
  LEDGER_ID                      ,
  INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
  TAX_ACCOUNT_CCID               ,
  INTERIM_TAX_CCID               ,
  NON_REC_ACCOUNT_CCID           ,
  ADJ_CCID                       ,
  EDISC_CCID                     ,
  UNEDISC_CCID                   ,
  FINCHRG_CCID                   ,
  ADJ_NON_REC_TAX_CCID           ,
  EDISC_NON_REC_TAX_CCID         ,
  UNEDISC_NON_REC_TAX_CCID       ,
  FINCHRG_NON_REC_TAX_CCID       ,
  RECORD_TYPE_CODE               ,
  ATTRIBUTE1             ,
  ATTRIBUTE2             ,
  ATTRIBUTE3             ,
  ATTRIBUTE4             ,
  ATTRIBUTE5             ,
  ATTRIBUTE6             ,
  ATTRIBUTE7             ,
  ATTRIBUTE8             ,
  ATTRIBUTE9             ,
  ATTRIBUTE10            ,
  ATTRIBUTE11            ,
  ATTRIBUTE12            ,
  ATTRIBUTE13            ,
  ATTRIBUTE14            ,
  ATTRIBUTE15            ,
  ATTRIBUTE_CATEGORY,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID    ,
  OBJECT_VERSION_NUMBER
)
VALUES
(
        ZX_ACCOUNTS_S.nextval ,
        TAX_RATE_ID           ,
        'RATES'                ,
         LEDGER_ID            ,
         ORG_ID               ,
         TAX_ACCOUNT_CCID     ,
         NULL                 ,
         NON_REC_ACCOUNT_CCID ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         RECORD_TYPE_CODE     ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
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
      results.tax_code_id            TAX_RATE_ID,
     results.tax_code||'-'||results.tax_code_id TAX_RATE_CODE, --Bug 4942908
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
      'N'                            SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                           DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                       DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ap_tax_recvry_rules_all rec_rules,
    financials_system_params_all fsp,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = codes.tax_id
AND  codes.enabled_flag = 'N'
AND  results.tax_class = 'INPUT'
AND  codes.offset_tax_code_id IS NULL
AND  codes.tax_recovery_rule_id  = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id = fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'

--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
--BugFix 3605729 added nvl(source_id, in the following condition.
AND  not exists (select 1 from zx_rates_b
                 where  nvl(source_id,tax_rate_id) =  nvl(p_tax_id,codes.tax_id)
                )
UNION ALL

SELECT
      results.tax_code_id            TAX_RATE_ID,
     results.tax_code||'-'||results.tax_code_id TAX_RATE_CODE, --Bug 4942908
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
     'N'                             SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                           DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                           DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
      offset.tax                     OFFSET_TAX    ,
      offset.tax_status_code         OFFSET_STATUS_CODE ,
      offset.tax_code                OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196

FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    zx_update_criteria_results offset,
    financials_system_params_all fsp,
    ap_tax_recvry_rules_all rec_rules,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id            = codes.tax_id
AND  codes.enabled_flag = 'N'
AND  results.tax_class = 'INPUT'
AND  results.tax_class = offset.tax_class  -- Condition added for Bug#7115321
AND  codes.offset_tax_code_id       = offset.tax_code_id
AND  codes.tax_recovery_rule_id     = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id = fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'

--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
--BugFix 3605729 added nvl(source_id, in the following condition.
AND  not exists (select 1 from zx_rates_b
                 where  nvl(source_id,tax_rate_id) =  nvl(p_tax_id,codes.tax_id)
                );
ELSE

INSERT ALL
INTO zx_rates_b_tmp
(
    TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
    TAX_CLASS                      , --Bug 3987672
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID               ,
     --BugFix 3426244
    ADJ_FOR_ADHOC_AMT_CODE         ,
    ALLOW_ADHOC_TAX_RATE_FLAG       ,
    OBJECT_VERSION_NUMBER           ,
    --Bug 4241667 : SOURCE_ID = TAX_RATE_ID for AP TAX CODES
    SOURCE_ID
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
VALUES
(
    TAX_RATE_CODE                  ,
  EFFECTIVE_FROM                 ,
  EFFECTIVE_TO                   ,
  TAX_REGIME_CODE                ,
  TAX                            ,
  TAX_STATUS_CODE                ,
  SCHEDULE_BASED_RATE_FLAG       ,
  RATE_TYPE_CODE                 ,
  PERCENTAGE_RATE                ,
  QUANTITY_RATE                  ,
  UOM_CODE                       ,
  TAX_JURISDICTION_CODE          ,
  RECOVERY_TYPE_CODE             ,
  ACTIVE_FLAG                    ,
  DEFAULT_RATE_FLAG              ,
  DEFAULT_FLG_EFFECTIVE_FROM     ,
  DEFAULT_FLG_EFFECTIVE_TO       ,
  DEFAULT_REC_TYPE_CODE          ,
      --DEFAULT_REC_TAX                ,
  DEFAULT_REC_RATE_CODE          ,
  OFFSET_TAX                     ,
  OFFSET_STATUS_CODE             ,
  OFFSET_TAX_RATE_CODE           ,
  RECOVERY_RULE_CODE             ,
  DEF_REC_SETTLEMENT_OPTION_CODE ,
  VAT_TRANSACTION_TYPE_CODE      ,
  RECORD_TYPE_CODE               ,
    'INPUT'                        ,
  ATTRIBUTE1                     ,
  ATTRIBUTE2                     ,
  ATTRIBUTE3                     ,
  ATTRIBUTE4                     ,
  ATTRIBUTE5                     ,
  ATTRIBUTE6                     ,
  ATTRIBUTE7                     ,
  ATTRIBUTE8                     ,
  ATTRIBUTE9                     ,
  ATTRIBUTE10                    ,
  ATTRIBUTE11                    ,
  ATTRIBUTE12                    ,
  ATTRIBUTE13                    ,
  ATTRIBUTE14                    ,
  ATTRIBUTE15                    ,
  ATTRIBUTE_CATEGORY             ,
  TAX_RATE_ID                    ,
  CONTENT_OWNER_ID               ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.user_id             ,
  SYSDATE                        ,
  fnd_global.conc_login_id       ,
  fnd_global.conc_request_id     , -- Request Id
  fnd_global.prog_appl_id        , -- Program Application ID
  fnd_global.conc_program_id     , -- Program Id
  fnd_global.conc_login_id       , -- Program Login ID
  'TAX_RATE'                      ,
  'Y'        , --ALLOW_ADHOC_TAX_RATE_FLAG
  1                               ,
        --Bug 4241667 : SOURCE_ID = TAX_RATE_ID for AP TAX CODES
        TAX_RATE_ID
-- 6820043, commenting out description
-- DESCRIPTION                      -- Bug 4705196
)
INTO zx_accounts
(
    TAX_ACCOUNT_ID                 ,
  TAX_ACCOUNT_ENTITY_ID          ,
  TAX_ACCOUNT_ENTITY_CODE        ,
  LEDGER_ID                      ,
  INTERNAL_ORGANIZATION_ID       , -- Bug 3495741
  TAX_ACCOUNT_CCID               ,
  INTERIM_TAX_CCID               ,
  NON_REC_ACCOUNT_CCID           ,
  ADJ_CCID                       ,
  EDISC_CCID                     ,
  UNEDISC_CCID                   ,
  FINCHRG_CCID                   ,
  ADJ_NON_REC_TAX_CCID           ,
  EDISC_NON_REC_TAX_CCID         ,
  UNEDISC_NON_REC_TAX_CCID       ,
  FINCHRG_NON_REC_TAX_CCID       ,
  RECORD_TYPE_CODE               ,
  ATTRIBUTE1             ,
  ATTRIBUTE2             ,
  ATTRIBUTE3             ,
  ATTRIBUTE4             ,
  ATTRIBUTE5             ,
  ATTRIBUTE6             ,
  ATTRIBUTE7             ,
  ATTRIBUTE8             ,
  ATTRIBUTE9             ,
  ATTRIBUTE10            ,
  ATTRIBUTE11            ,
  ATTRIBUTE12            ,
  ATTRIBUTE13            ,
  ATTRIBUTE14            ,
  ATTRIBUTE15            ,
  ATTRIBUTE_CATEGORY,
  CREATED_BY                      ,
  CREATION_DATE                  ,
  LAST_UPDATED_BY                ,
  LAST_UPDATE_DATE               ,
  LAST_UPDATE_LOGIN              ,
  REQUEST_ID                     ,
  PROGRAM_APPLICATION_ID         ,
  PROGRAM_ID                     ,
  PROGRAM_LOGIN_ID    ,
  OBJECT_VERSION_NUMBER
)
VALUES
(
        ZX_ACCOUNTS_S.nextval ,
        TAX_RATE_ID           ,
        'RATES'                ,
         LEDGER_ID            ,
         ORG_ID               ,
         TAX_ACCOUNT_CCID     ,
         NULL                 ,
         NON_REC_ACCOUNT_CCID ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         RECORD_TYPE_CODE     ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
         NULL                 ,
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
      results.tax_code_id            TAX_RATE_ID,
     results.tax_code||'-'||results.tax_code_id TAX_RATE_CODE, --Bug 4942908
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
      'N'                            SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                           DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                       DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
      NULL                           OFFSET_TAX,
      NULL                           OFFSET_STATUS_CODE ,
      NULL                           OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196
FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    ap_tax_recvry_rules_all rec_rules,
    financials_system_params_all fsp,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id = codes.tax_id
AND  codes.enabled_flag = 'N'
AND  results.tax_class = 'INPUT'
AND  codes.offset_tax_code_id IS NULL
AND  codes.tax_recovery_rule_id  = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id = l_org_id
AND  codes.org_id = fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'

--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
--BugFix 3605729 added nvl(source_id, in the following condition.
AND  not exists (select 1 from zx_rates_b
                 where  nvl(source_id,tax_rate_id) =  nvl(p_tax_id,codes.tax_id)
                )
UNION ALL

SELECT
      results.tax_code_id            TAX_RATE_ID,
     results.tax_code||'-'||results.tax_code_id TAX_RATE_CODE, --Bug 4942908
      ptp.party_tax_profile_id       CONTENT_OWNER_ID,
      codes.start_date               EFFECTIVE_FROM,
      codes.inactive_date            EFFECTIVE_TO,
      results.tax_regime_code        TAX_REGIME_CODE ,
      results.tax                    TAX,
      results.tax_status_code        TAX_STATUS_CODE,
     'N'                             SCHEDULE_BASED_RATE_FLAG,
     'PERCENTAGE'                    RATE_TYPE_CODE,
      codes.tax_rate                 PERCENTAGE_RATE,
      NULL                           QUANTITY_RATE       ,
      NULL                           UOM_CODE,
      NULL                           TAX_JURISDICTION_CODE,
      results.recovery_type_code     RECOVERY_TYPE_CODE,
      codes.enabled_flag             ACTIVE_FLAG,
     'N'                             DEFAULT_RATE_FLAG    ,
      NULL                           DEFAULT_FLG_EFFECTIVE_FROM ,
      NULL                           DEFAULT_FLG_EFFECTIVE_TO   ,
     decode(DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
      NULL,
      NULL,
      'STANDARD') DEFAULT_REC_TYPE_CODE, --Bug 4943105
    --NULL                           DEFAULT_REC_TAX            ,
    --BugFix 3480468
      DECODE(codes.tax_recovery_rule_id,
             NULL,
             DECODE(NVL(fsp.non_recoverable_tax_flag, 'N'),
                   'Y',
                   'STANDARD-'||nvl(codes.tax_recovery_rate,0),
                    NULL),
             NULL)                   DEFAULT_REC_RATE_CODE,
      offset.tax                     OFFSET_TAX    ,
      offset.tax_status_code         OFFSET_STATUS_CODE ,
      offset.tax_code                OFFSET_TAX_RATE_CODE  ,
      rec_rules.name                 RECOVERY_RULE_CODE    ,
      DECODE(codes.global_attribute_category,
             'JA.TH.APXTADTC.TAX_CODES',
              DECODE(codes.global_attribute1,
                     'INVOICES' ,
                     'IMMEDIATE',
                     'PAYMENTS',
                     'DEFFERED',
                      NULL),
               'IMMEDIATE')          DEF_REC_SETTLEMENT_OPTION_CODE,
      codes.vat_transaction_type     VAT_TRANSACTION_TYPE_CODE ,
     'MIGRATED'                      RECORD_TYPE_CODE,
      codes.ATTRIBUTE1               ATTRIBUTE1,
      codes.ATTRIBUTE2               ATTRIBUTE2,
      codes.ATTRIBUTE3               ATTRIBUTE3,
      codes.ATTRIBUTE4               ATTRIBUTE4,
      codes.ATTRIBUTE5               ATTRIBUTE5,
      codes.ATTRIBUTE6               ATTRIBUTE6,
      codes.ATTRIBUTE7               ATTRIBUTE7,
      codes.ATTRIBUTE8               ATTRIBUTE8,
      codes.ATTRIBUTE9               ATTRIBUTE9,
      codes.ATTRIBUTE10              ATTRIBUTE10,
      codes.ATTRIBUTE11              ATTRIBUTE11,
      codes.ATTRIBUTE12              ATTRIBUTE12,
      codes.ATTRIBUTE13              ATTRIBUTE13,
      codes.ATTRIBUTE14              ATTRIBUTE14,
      codes.ATTRIBUTE15              ATTRIBUTE15,
      codes.ATTRIBUTE_CATEGORY       ATTRIBUTE_CATEGORY,
      codes.set_of_books_id          LEDGER_ID,
      results.org_id                 ORG_ID,
      codes.tax_code_combination_id  TAX_ACCOUNT_CCID,--Bug Fix 4502551
      DECODE(nvl(fsp.non_recoverable_tax_flag,'N'),
             'N',codes.tax_code_combination_id,
              NULL)                  NON_REC_ACCOUNT_CCID,
      codes.DESCRIPTION         DESCRIPTION -- Bug 4705196

FROM
    zx_update_criteria_results results,
    ap_tax_codes_all codes,
    zx_update_criteria_results offset,
    financials_system_params_all fsp,
    ap_tax_recvry_rules_all rec_rules,
    zx_party_tax_profile ptp
WHERE
     results.tax_code_id            = codes.tax_id
AND  codes.enabled_flag = 'N'
AND  results.tax_class = 'INPUT'
AND  results.tax_class = offset.tax_class  -- Condition added for Bug#7115321
AND  codes.offset_tax_code_id       = offset.tax_code_id
AND  codes.tax_recovery_rule_id     = rec_rules.rule_id(+)
AND  codes.tax_type not in ( 'AWT','OFFSET','TAX_GROUP')
AND  codes.org_id = l_org_id
AND  codes.org_id = fsp.org_id
AND  codes.org_id  = ptp.party_id
AND  ptp.party_Type_code = 'OU'

--Added following conditions for Sync process
AND  codes.tax_id  = nvl(p_tax_id,codes.tax_id)
--BugFix 3605729 added nvl(source_id, in the following condition.
AND  not exists (select 1 from zx_rates_b
                 where  nvl(source_id,tax_rate_id) =  nvl(p_tax_id,codes.tax_id)
                );

END IF;

EXCEPTION WHEN OTHERS THEN
      arp_util_tax.debug('Caught an error in the non id clash portion for the disabled tax codes
                           with no date overlap'||sqlerrm);
END;


INSERT INTO  ZX_RATES_TL
(
    TAX_RATE_ID,
    TAX_RATE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
  description
)
SELECT
    TAX_RATE_ID,
    CASE WHEN TAX_RATE_CODE = UPPER(TAX_RATE_CODE)
     THEN    Initcap(TAX_RATE_CODE)
     ELSE
             TAX_RATE_CODE
     END ,
    fnd_global.user_id             ,
    SYSDATE                        ,
    fnd_global.user_id             ,
    SYSDATE                        ,
    fnd_global.conc_login_id       ,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    avtb.description
FROM FND_LANGUAGES L,
     ZX_RATES_B RATES,
     ar_vat_tax_all_b   avtb
WHERE
     L.INSTALLED_FLAG in ('I', 'B')
AND avtb.vat_tax_id = RATES.tax_rate_id
AND  RATES.RECORD_TYPE_CODE = 'MIGRATED'
AND  not exists
    (select NULL
    from ZX_RATES_TL T
    where T.TAX_RATE_ID = RATES.TAX_RATE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

    IF PG_DEBUG = 'Y' THEN
       arp_util_tax.debug('Migrate_Normal_Tax_Codes(-)');
    END IF;


EXCEPTION
         WHEN OTHERS THEN
            IF PG_DEBUG = 'Y' THEN
              arp_util_tax.debug('EXCEPTION: Migrate_disabled_tax_codes ');
              arp_util_tax.debug(sqlerrm);
              arp_util_tax.debug('Migrate_disabled_Tax_Codes(-)');
            END IF;
            --app_exception.raise_exception;


 END migrate_disabled_tax_codes;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    stamp_default_rate_flag                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |     This routine is used to stamp the default rate flag for recovery and  |
 |     non recovery based rates as applicable                                |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |                                                                           |
 | CALLED FROM                                                               |
 |        migrate_ap_tax_code_setup                                          |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     04-May-06  Arnab Sengupta      Created.                               |
 |                                                                           |
 |==========================================================================*/
 PROCEDURE stamp_default_rate_flag IS
 BEGIN

 /*Stamp the default rate flag correctly for non recovery based rates
   Atleast one rate should have this flag set to 'Y' for a given combination
   of regime,tax, status and content owner */

 update zx_rates_b_tmp rates
  set rates.default_rate_flag = 'Y' ,
  rates.default_flg_effective_from = rates.effective_from, --Bug 5104891
        rates.default_flg_effective_to = rates.effective_to -- Bug 6680676
  where rates.tax_rate_code in ( select rates1.tax_rate_code from zx_rates_b rates1
            where rates.tax_regime_code = rates1.tax_regime_code
            and rates.tax = rates1.tax
            and rates.tax_status_code = rates1.tax_status_code
            and rates.content_owner_id = rates1.content_owner_id
            and rates1.record_type_code = 'MIGRATED'
            and rates1.rate_type_code <> 'RECOVERY'
                              and sysdate between rates1.effective_from
            and nvl(rates1.effective_to,sysdate)
            and rownum = 1)
  /* Not Exists is to prevent the default_rate_flag to be updated to 'Y' for 2 rates under the same combination of
  regime,tax,status and Content owner */
  and not exists (select 1 from zx_rates_b rates2
             where rates2.tax_regime_code = rates.tax_regime_code
            and rates2.tax = rates.tax
            and rates2.tax_status_code = rates.tax_status_code
            and rates2.content_owner_id = rates.content_owner_id
                  and rates2.rate_type_code <> 'RECOVERY'
            and rates2.default_rate_flag = 'Y' );

 /*Stamp the default rate flag correctly for recovery based rates
   Atleast one rate should have this flag set to 'Y' for a given combination
   of regime ,tax, status and content owner */

--Commenting out the logic as it is no longer required
--Bug 5209434
/*   update zx_rates_b_tmp rates
  set rates.default_rate_flag = 'Y' ,
  rates.default_flg_effective_from = rates.effective_from --Bug 5104891
  where rates.tax_rate_code in ( select rates1.tax_rate_code from zx_rates_b rates1
            where rates.tax_regime_code = rates1.tax_regime_code
            and rates.tax = rates1.tax
            and rates.tax_status_code = rates1.tax_status_code
            and rates.content_owner_id = rates1.content_owner_id
            and rates1.record_type_code = 'MIGRATED'
            and rates1.rate_type_code = 'RECOVERY'
                              and sysdate between rates1.effective_from
            and nvl(rates1.effective_to,sysdate)
            and rownum = 1)

  and not exists (select 1 from zx_rates_b rates2
             where rates2.tax_regime_code = rates.tax_regime_code
            and rates2.tax = rates.tax
            and rates2.tax_status_code = rates.tax_status_code
            and rates2.content_owner_id = rates.content_owner_id
                  and rates2.rate_type_code = 'RECOVERY'
            and rates2.default_rate_flag = 'Y' );*/


 EXCEPTION WHEN OTHERS THEN

 NULL;

 END;




--BugFix 3605729
/* Constructor */
BEGIN
    BEGIN

    SELECT 'Y' INTO ID_CLASH FROM DUAL
    WHERE EXISTS (select 1
                  from ap_tax_codes_all,
           ar_vat_tax_all_b
                  where tax_id = vat_tax_id);
    EXCEPTION
    WHEN no_data_found THEN
      arp_util_tax.debug('No data found exception encountered for tax definition in constructor :'||sqlerrm);

    WHEN others THEN
      arp_util_tax.debug('Exception in Constructor for AP  tax definition :'||sqlerrm);
  END;

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
    WHEN no_data_found THEN
      arp_util_tax.debug('No data found exception encountered for tax definition in constructor :'||sqlerrm);

    WHEN others THEN
      arp_util_tax.debug('Exception in Constructor for AP  tax definition :'||sqlerrm);
  END;
  BEGIN
  MO_GLOBAL.INIT('ZX');
  EXCEPTION WHEN OTHERS THEN
  arp_util_tax.debug('Exception in MO_GLOBAL.init');
  END;



END zx_migrate_tax_def;

/
