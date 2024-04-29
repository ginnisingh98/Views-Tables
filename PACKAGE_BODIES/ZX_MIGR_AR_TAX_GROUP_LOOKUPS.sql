--------------------------------------------------------
--  DDL for Package Body ZX_MIGR_AR_TAX_GROUP_LOOKUPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_MIGR_AR_TAX_GROUP_LOOKUPS" AS
/* $Header: zxcondconstmigrb.pls 120.3 2006/08/18 12:47:52 asengupt ship $ */

-- Forward declarations
Procedure DISABLE_EXT_AR_TG_LOOKUPS;
Procedure Create_Lookups;

PG_DEBUG CONSTANT VARCHAR(1) default
                  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/*=========================================================================+
 | PROCEDURE                                                               |
 |    migrate_condition_constraints                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This routine migrates the lookups for AR Tax Group conditions and   |
 |     constraints to eBTax rules model.                                   |
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
 |     15-Oct-04  Nilesh Patel        Created.                             |
 |                                                                         |
 |=========================================================================*/


PROCEDURE MIGRATE_CONDITION_CONSTRAINTS is
BEGIN

   IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('ZX_MIGRATE_AR_TAX_GROUPS.Migrate_Condition_Constraints(+)');
   END IF;

   Savepoint pre_migr_ar_tax_group_lookups;

    Disable_Ext_Ar_Tg_Lookups;
    Create_Lookups;

   IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('ZX_MIGRATE_AR_TAX_GROUPS.Migrate_Condition_Constraints(-)');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
        IF PG_DEBUG = 'Y' THEN
            arp_util_tax.debug('Exception in ZX_MIGRATE_AR_TAX_GROUPS.Migrate_Condition_Constraints: '
            || SQLCODE ||';'||SQLERRM);
        END IF;

        Rollback To pre_migr_ar_tax_group_lookups;
        app_exception.raise_exception;

END;


/*=========================================================================+
 | PROCEDURE                                                               |
 |    disable_ext_ar_tg_lookups                                            |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This routine makes the user extensible  lookups for AR Tax Group    |
 |     conditions and constraintes non-extensible during the upgrade       |
 |     window.                                                             |
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
 |     11-Oct-04  Nilesh Patel        Created.                             |
 |                                                                         |
 |=========================================================================*/


PROCEDURE DISABLE_EXT_AR_TG_LOOKUPS is
BEGIN

   IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('ZX_MIGRATE_AR_TAX_GROUPS.disable_ext_ar_tg_lookups(+)');
   END IF;

   UPDATE FND_LOOKUP_TYPES
   SET    CUSTOMIZATION_LEVEL = 'S'
   WHERE  lookup_type in (
        'TAX_CONDITION_TYPE',
        'TAX_CONDITION_OPERATOR',
        'TAX_CONDITION_FIELD',
        'TAX_CONDITION_ENTITY',
        'TAX_CONDITION_CLAUSE',
        'TAX_CONDITION_ACTION_TYPE',
        'TAX_CONDITION_ACTION_CODE',
        'TAX_CONDITION_VALUE',
        'AR_TAX_CLASSIFICATION')
   AND  CUSTOMIZATION_LEVEL = 'E'
   AND  APPLICATION_ID = 222;

   IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('ZX_MIGRATE_AR_TAX_GROUPS.disable_ext_ar_tg_lookups(-)');
   END IF;

END;



/*=========================================================================+
 | PROCEDURE                                                               |
 |    Create_Lookups                                                       |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This procedure is used to create lookups for AR Lookup types        |
 |     TAX_CONDITION_TYPE                                                  |
 |     TAX_CONDITION_OPERATOR                                              |
 |     TAX_CONDITION_FIELD                                                 |
 |     TAX_CONDITION_ENTITY                                                |
 |     TAX_CONDITION_CLAUSE                                                |
 |     TAX_CONDITION_ACTION_TYPE                                           |
 |     TAX_CONDITION_ACTION_CODE                                           |
 |     TAX_CONDITION_VALUE                                                 |
 |     AR_TAX_CLASSIFICATION                                               |
 |     used in Tax Group conditions and constraints                          |
 |                                                                         |
 | SCOPE - PUBLIC                                                          |
 |                                                                         |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                  |
 |                                                                         |
 | CALLED FROM                                                             |
 |     MIGRATE_CONDITION_CONSTRAINTS                                       |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |     08-Oct-04  Nilesh Patel       Created.                              |
 |                                                                         |
 |=========================================================================*/

 PROCEDURE Create_Lookups IS
 BEGIN

 IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('Create_Lookups(+)');
 END IF;

 IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('creating FND_LOOKUP_TYPES....');
 END IF;

INSERT ALL
WHEN (NOT EXISTS
      (SELECT 1 FROM FND_LOOKUP_TYPES
       WHERE LOOKUP_TYPE = 'ZX_CONDITION_TYPE'
         AND APPLICATION_ID = 235)
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
'ZX_CONDITION_TYPE'      ,
'S'                      ,
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
       WHERE LOOKUP_TYPE = 'ZX_CONDITION_OPERATOR'
         AND APPLICATION_ID = 235)
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
'ZX_CONDITION_OPERATOR' ,
'S'                      ,
 0                       ,
 0                    ,
 SYSDATE                 ,
 fnd_global.user_id      ,
 SYSDATE                 ,
 fnd_global.user_id      ,
 fnd_global.conc_login_id
)
WHEN (NOT EXISTS
      (SELECT 1 FROM FND_LOOKUP_TYPES
       WHERE LOOKUP_TYPE = 'ZX_CONDITION_FIELD'
         AND APPLICATION_ID = 235)
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
'ZX_CONDITION_FIELD' ,
'S'                      ,
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
       WHERE LOOKUP_TYPE = 'ZX_CONDITION_ENTITY'
         AND APPLICATION_ID = 235)
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
'ZX_CONDITION_ENTITY' ,
'S'                      ,
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
       WHERE LOOKUP_TYPE = 'ZX_CONDITION_CLAUSE'
         AND APPLICATION_ID = 235)
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
'ZX_CONDITION_CLAUSE'    ,
'S'                      ,
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
       WHERE LOOKUP_TYPE = 'ZX_CONDITION_ACTION_TYPE'
         AND APPLICATION_ID = 235)
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
'ZX_CONDITION_ACTION_TYPE' ,
'S'                      ,
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
       WHERE LOOKUP_TYPE = 'ZX_CONDITION_ACTION_CODE'
         AND APPLICATION_ID = 235)
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
 235                   ,
'ZX_CONDITION_ACTION_CODE' ,
'S'                      ,
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
       WHERE LOOKUP_TYPE = 'ZX_CONDITION_VALUE'
         AND APPLICATION_ID = 235)
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
 235                     ,
'ZX_CONDITION_VALUE'     ,
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
       WHERE LOOKUP_TYPE = 'ZX_TAX_CLASSIFICATION'
         AND APPLICATION_ID = 235)
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
'ZX_TAX_CLASSIFICATION'  ,
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


IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('creating records in FND_LOOKUP_TYPES_TL...');
END IF;

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
            Initcap(types.lookup_type),--MEANING
            types.lookup_type,--DESCRIPTION
            fnd_global.user_id             ,
            SYSDATE                        ,
            fnd_global.user_id             ,
            SYSDATE                        ,
            fnd_global.conc_login_id
FROM        FND_LOOKUP_TYPES types,
            FND_LANGUAGES L
WHERE  L.INSTALLED_FLAG in ('I', 'B')
AND    types.lookup_type in (
        'ZX_CONDITION_TYPE',
        'ZX_CONDITION_OPERATOR',
        'ZX_CONDITION_FIELD',
        'ZX_CONDITION_ENTITY',
        'ZX_CONDITION_CLAUSE',
        'ZX_CONDITION_ACTION_TYPE',
        'ZX_CONDITION_ACTION_CODE',
        'ZX_CONDITION_VALUE',
        'ZX_TAX_CLASSIFICATION')
AND    not exists
       (select 1
        from   fnd_lookup_types_tl sub
        where  sub.lookup_type = types.lookup_type
        and    sub.security_group_id = 0
        and    sub.view_application_id = 0
        and    sub.language = l.language_code);


IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('creating records in FND_LOOKUP_VALUES...');
END IF;

/* Insert lookup codes for the lookup types */
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
     'ZX_CONDITION_TYPE',
      l.language_code , -- LANGUAGE
      lk.LOOKUP_CODE             ,
      lk.MEANING                 ,
      lk.DESCRIPTION             ,
      'Y'                     ,--ENABLED_FLAG
      lk.START_DATE_ACTIVE       ,
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
   FROM  FND_LOOKUP_VALUES lk, FND_LANGUAGES l
   WHERE lk.lookup_type = 'TAX_CONDITION_TYPE'
	  AND view_application_id = 222
	  AND lk.language = 'US'
	  AND l.installed_flag in ('I', 'B')
	  AND not exists
	    (select '1'
	    from FND_LOOKUP_VALUES
	    where lookup_code = lk.lookup_code
	    and   lookup_type = 'ZX_CONDITION_TYPE'
	    and   language    = l.LANGUAGE_CODE);

/* Insert lookup codes for the lookup types */
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
     'ZX_CONDITION_OPERATOR',
      l.language_code , -- LANGUAGE
      lk.LOOKUP_CODE             ,
      lk.MEANING                 ,
      lk.DESCRIPTION             ,
      'Y'                     ,--ENABLED_FLAG
      lk.START_DATE_ACTIVE       ,
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
   FROM  FND_LOOKUP_VALUES lk, FND_LANGUAGES l
   WHERE lk.lookup_type = 'TAX_CONDITION_OPERATOR'
	  AND view_application_id = 222
	  AND lk.language = 'US'
	  AND l.installed_flag in ('I', 'B')
	  AND not exists
	    (select '1'
	    from FND_LOOKUP_VALUES
	    where lookup_code = lk.lookup_code
	    and   lookup_type = 'ZX_CONDITION_OPERATOR'
	    and   language    = l.LANGUAGE_CODE);

/* Insert lookup codes for the lookup types */
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
     'ZX_CONDITION_FIELD',
      l.language_code , -- LANGUAGE
      lk.LOOKUP_CODE             ,
      lk.MEANING                 ,
      lk.DESCRIPTION             ,
      'Y'                     ,--ENABLED_FLAG
      lk.START_DATE_ACTIVE       ,
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
   FROM  FND_LOOKUP_VALUES lk, FND_LANGUAGES l
   WHERE lk.lookup_type = 'TAX_CONDITION_FIELD'
	  AND view_application_id = 222
	  AND lk.language = 'US'
	  AND l.installed_flag in ('I', 'B')
	  AND not exists
	    (select '1'
	    from FND_LOOKUP_VALUES
	    where lookup_code = lk.lookup_code
	    and   lookup_type = 'ZX_CONDITION_FIELD'
	    and   language    = l.LANGUAGE_CODE);

/* Insert lookup codes for the lookup types */
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
     'ZX_CONDITION_ENTITY',
      l.language_code , -- LANGUAGE
      lk.LOOKUP_CODE             ,
      lk.MEANING                 ,
      lk.DESCRIPTION             ,
      'Y'                     ,--ENABLED_FLAG
      lk.START_DATE_ACTIVE       ,
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
   FROM  FND_LOOKUP_VALUES lk, FND_LANGUAGES l
   WHERE lk.lookup_type = 'TAX_CONDITION_ENTITY'
	  AND view_application_id = 222
	  AND lk.language = 'US'
	  AND l.installed_flag in ('I', 'B')
	  AND not exists
	    (select '1'
	    from FND_LOOKUP_VALUES
	    where lookup_code = lk.lookup_code
	    and   lookup_type = 'ZX_CONDITION_ENTITY'
	    and   language    = l.LANGUAGE_CODE);

/* Insert lookup codes for the lookup types */
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
     'ZX_CONDITION_CLAUSE',
      l.language_code , -- LANGUAGE
      lk.LOOKUP_CODE             ,
      lk.MEANING                 ,
      lk.DESCRIPTION             ,
      'Y'                     ,--ENABLED_FLAG
      lk.START_DATE_ACTIVE       ,
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
   FROM  FND_LOOKUP_VALUES lk, FND_LANGUAGES l
   WHERE lk.lookup_type = 'TAX_CONDITION_CLAUSE'
	  AND view_application_id = 222
	  AND lk.language = 'US'
	  AND l.installed_flag in ('I', 'B')
	  AND not exists
	    (select '1'
	    from FND_LOOKUP_VALUES
	    where lookup_code = lk.lookup_code
	    and   lookup_type = 'ZX_CONDITION_CLAUSE'
	    and   language    = l.LANGUAGE_CODE);

/* Insert lookup codes for the lookup types */
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
     'ZX_CONDITION_ACTION_TYPE',
      l.language_code , -- LANGUAGE
      lk.LOOKUP_CODE             ,
      lk.MEANING                 ,
      lk.DESCRIPTION             ,
      'Y'                     ,--ENABLED_FLAG
      lk.START_DATE_ACTIVE       ,
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
   FROM  FND_LOOKUP_VALUES lk, FND_LANGUAGES l
   WHERE lk.lookup_type = 'TAX_CONDITION_ACTION_TYPE'
	  AND view_application_id = 222
	  AND lk.language = 'US'
	  AND l.installed_flag in ('I', 'B')
	  AND not exists
	    (select '1'
	    from FND_LOOKUP_VALUES
	    where lookup_code = lk.lookup_code
	    and   lookup_type = 'ZX_CONDITION_ACTION_TYPE'
	    and   language    = l.LANGUAGE_CODE);

/* Insert lookup codes for the lookup types */
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
     'ZX_CONDITION_ACTION_CODE',
      l.language_code , -- LANGUAGE
      lk.LOOKUP_CODE             ,
      lk.MEANING                 ,
      lk.DESCRIPTION             ,
      'Y'                     ,--ENABLED_FLAG
      lk.START_DATE_ACTIVE       ,
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
   FROM  FND_LOOKUP_VALUES lk, FND_LANGUAGES l
   WHERE lk.lookup_type = 'TAX_CONDITION_ACTION_CODE'
	  AND view_application_id = 222
	  AND lk.language = 'US'
	  AND l.installed_flag in ('I', 'B')
	  AND not exists
	    (select '1'
	    from FND_LOOKUP_VALUES
	    where lookup_code = lk.lookup_code
	    and   lookup_type = 'ZX_CONDITION_ACTION_CODE'
	    and   language    = l.LANGUAGE_CODE);

/* Insert lookup codes for the lookup types */
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
     'ZX_CONDITION_VALUE',
      l.language_code , -- LANGUAGE
      lk.LOOKUP_CODE             ,
      lk.MEANING                 ,
      lk.DESCRIPTION             ,
      'Y'                     ,--ENABLED_FLAG
      lk.START_DATE_ACTIVE       ,
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
   FROM  FND_LOOKUP_VALUES lk, FND_LANGUAGES l
   WHERE lk.lookup_type = 'TAX_CONDITION_VALUE'
	  AND view_application_id = 222
	  AND lk.language = 'US'
	  AND l.installed_flag in ('I', 'B')
	  AND not exists
	    (select '1'
	    from FND_LOOKUP_VALUES
	    where lookup_code = lk.lookup_code
	    and   lookup_type = 'ZX_CONDITION_VALUE'
	    and   language    = l.LANGUAGE_CODE);

/* Insert lookup codes for the lookup types */
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
     'ZX_TAX_CLASSIFICATION',
      l.language_code , -- LANGUAGE
      lk.LOOKUP_CODE             ,
      lk.MEANING                 ,
      lk.DESCRIPTION             ,
      'Y'                     ,--ENABLED_FLAG
      lk.START_DATE_ACTIVE       ,
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
   FROM  FND_LOOKUP_VALUES lk, FND_LANGUAGES l
   WHERE lk.lookup_type = 'AR_TAX_CLASSIFICATION'
	  AND view_application_id = 222
	  AND lk.language = 'US'
	  AND l.installed_flag in ('I', 'B')
	  AND not exists
	    (select '1'
	    from FND_LOOKUP_VALUES
	    where lookup_code = lk.lookup_code
	    and   lookup_type = 'ZX_TAX_CLASSIFICATION'
	    and   language    = l.LANGUAGE_CODE);

   IF PG_DEBUG = 'Y' THEN
      arp_util_tax.debug('Create_Lookup(-)');
	    END IF;
Exception
  When others then
       IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('Exception: ZX_MIGRATE_AR_TAX_GROUPS.Create_Lookup:' ||
                            SQLCODE||' ; '||SQLERRM);
       END IF;
       raise;
END Create_Lookups;

/*=========================================================================+
 | PROCEDURE                                                               |
 |    end_date_cond_cons_lk                                                |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This routine end dates the old  lookups for AR Tax Group conditions |
 |     and constraints in the downtime.                                    |
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
 |     15-Oct-04  Nilesh Patel        Created.                             |
 |                                                                         |
 |=========================================================================*/


PROCEDURE end_date_cond_cons_lk is
BEGIN

   IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('ZX_MIGRATE_AR_TAX_GROUPS.end_date_cond_cons_lk(+)');
   END IF;

   UPDATE fnd_lookup_values
   SET   ENABLED_FLAG = 'N',
         END_DATE_ACTIVE = SYSDATE
   WHERE lookup_type in (
        'ZX_CONDITION_TYPE',
        'ZX_CONDITION_OPERATOR',
        'ZX_CONDITION_FIELD',
        'ZX_CONDITION_ENTITY',
        'ZX_CONDITION_CLAUSE',
        'ZX_CONDITION_ACTION_TYPE',
        'ZX_CONDITION_ACTION_CODE',
        'ZX_CONDITION_VALUE',
        'ZX_TAX_CLASSIFICATION')
   AND  view_application_id = 0;


   IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('ZX_MIGRATE_AR_TAX_GROUPS.end_date_cond_cons_lk(-)');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG = 'Y' THEN
        arp_util_tax.debug('Exception in ZX_MIGRATE_AR_TAX_GROUPS.end_date_cond_cons_lk: '||
                            SQLCODE||' ; '||SQLERRM);
     END IF;

END end_date_cond_cons_lk;

END ZX_MIGR_AR_TAX_GROUP_LOOKUPS;

/
