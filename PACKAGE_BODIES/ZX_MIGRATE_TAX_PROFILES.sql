--------------------------------------------------------
--  DDL for Package Body ZX_MIGRATE_TAX_PROFILES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_MIGRATE_TAX_PROFILES" AS
/* $Header: zxtaxprofilemigb.pls 120.4 2006/10/05 23:38:44 svaze ship $ */

/*===========================================================================+
 | PROCEDURE
 |    migrate_tax_profile_values
 |
 | IN
 |
 | OUT
 |
 | DESCRIPTION
 |     This routine migrates AP/AR/OM Tax Profile values to ZX.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | 04/08/2005   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/
PROCEDURE migrate_tax_profile_values
IS
BEGIN
--
-- INSERT FND_PROFILE_OPTION_VALUES
--
INSERT INTO FND_PROFILE_OPTION_VALUES
(
 APPLICATION_ID                  ,
 PROFILE_OPTION_ID               ,
 LEVEL_ID                        ,
 LEVEL_VALUE                     ,
 LAST_UPDATE_DATE                ,
 LAST_UPDATED_BY                 ,
 CREATION_DATE                   ,
 CREATED_BY                      ,
 LAST_UPDATE_LOGIN               ,
 PROFILE_OPTION_VALUE            ,
 LEVEL_VALUE_APPLICATION_ID
)
SELECT
 235,                               -- APPLICATION_ID
 (select profile_option_id
  from   fnd_profile_options
  where  profile_option_name = 'ZX_ALLOW_TRX_LINE_EXEMPTIONS'), -- PROFILE_OPTION_ID
 LEVEL_ID,
 LEVEL_VALUE,
 sysdate,                        --LAST_UPDATE_DATE
 fnd_global.user_id,             --LAST_UPDATED_BY
 sysdate,                        --CREATION_DATE
 fnd_global.user_id,             --CREATED_BY
 fnd_global.conc_login_id,       --LAST_UPDATE_LOGIN
 PROFILE_OPTION_VALUE,
 LEVEL_VALUE_APPLICATION_ID
FROM     fnd_profile_option_values
WHERE    profile_option_id = (select profile_option_id
                              from   fnd_profile_options
                              where  profile_option_name = 'AR_ALLOW_TRX_LINE_EXEMPTIONS')
AND     NOT EXISTS (SELECT 1
                    FROM   fnd_profile_option_values
                    WHERE  profile_option_id = (SELECT profile_option_id
                                                FROM   fnd_profile_options
                                                WHERE  profile_option_name = 'ZX_ALLOW_TRX_LINE_EXEMPTIONS')
                   );

-- 1.

INSERT INTO FND_PROFILE_OPTION_VALUES
(
 APPLICATION_ID                  ,
 PROFILE_OPTION_ID               ,
 LEVEL_ID                        ,
 LEVEL_VALUE                     ,
 LAST_UPDATE_DATE                ,
 LAST_UPDATED_BY                 ,
 CREATION_DATE                   ,
 CREATED_BY                      ,
 LAST_UPDATE_LOGIN               ,
 PROFILE_OPTION_VALUE            ,
 LEVEL_VALUE_APPLICATION_ID
)
SELECT
 235,                               -- APPLICATION_ID
 (select profile_option_id
  from   fnd_profile_options
  where  profile_option_name = 'ZX_ALLOW_TAX_UPDATE'), -- PROFILE_OPTION_ID
 LEVEL_ID,
 LEVEL_VALUE,
 sysdate,                        --LAST_UPDATE_DATE
 fnd_global.user_id,             --LAST_UPDATED_BY
 sysdate,                        --CREATION_DATE
 fnd_global.user_id,             --CREATED_BY
 fnd_global.conc_login_id,       --LAST_UPDATE_LOGIN
 PROFILE_OPTION_VALUE,
 LEVEL_VALUE_APPLICATION_ID
FROM     fnd_profile_option_values
WHERE    profile_option_id = (select profile_option_id
                              from   fnd_profile_options
                              where  profile_option_name = 'AR_ALLOW_TAX_UPDATE')
AND     APPLICATION_ID     = 222
AND     NOT EXISTS (SELECT 1
                    FROM   fnd_profile_option_values
                    WHERE  profile_option_id = (SELECT profile_option_id
                                                FROM   fnd_profile_options
                                                WHERE  profile_option_name = 'ZX_ALLOW_TAX_UPDATE')
                   );

-- 2.

INSERT INTO FND_PROFILE_OPTION_VALUES
(
 APPLICATION_ID                  ,
 PROFILE_OPTION_ID               ,
 LEVEL_ID                        ,
 LEVEL_VALUE                     ,
 LAST_UPDATE_DATE                ,
 LAST_UPDATED_BY                 ,
 CREATION_DATE                   ,
 CREATED_BY                      ,
 LAST_UPDATE_LOGIN               ,
 PROFILE_OPTION_VALUE            ,
 LEVEL_VALUE_APPLICATION_ID
)
SELECT
 235,                               -- APPLICATION_ID
 (select profile_option_id
  from   fnd_profile_options
  where  profile_option_name = 'ZX_ALLOW_MANUAL_TAX_LINES'), -- PROFILE_OPTION_ID
 LEVEL_ID,
 LEVEL_VALUE,
 sysdate,                        --LAST_UPDATE_DATE
 fnd_global.user_id,             --LAST_UPDATED_BY
 sysdate,                        --CREATION_DATE
 fnd_global.user_id,             --CREATED_BY
 fnd_global.conc_login_id,       --LAST_UPDATE_LOGIN
 PROFILE_OPTION_VALUE,
 LEVEL_VALUE_APPLICATION_ID
FROM     fnd_profile_option_values
WHERE    profile_option_id = (select profile_option_id
                              from   fnd_profile_options
                              where  profile_option_name = 'AR_ALLOW_MANUAL_TAX_LINES')
AND     NOT EXISTS (SELECT 1
                    FROM   fnd_profile_option_values
                    WHERE  profile_option_id = (SELECT profile_option_id
                                                FROM   fnd_profile_options
                                                WHERE  profile_option_name = 'ZX_ALLOW_MANUAL_TAX_LINES')
                   );

-- 3.
/*Bug 5529992
INSERT INTO FND_PROFILE_OPTION_VALUES
(
 APPLICATION_ID                  ,
 PROFILE_OPTION_ID               ,
 LEVEL_ID                        ,
 LEVEL_VALUE                     ,
 LAST_UPDATE_DATE                ,
 LAST_UPDATED_BY                 ,
 CREATION_DATE                   ,
 CREATED_BY                      ,
 LAST_UPDATE_LOGIN               ,
 PROFILE_OPTION_VALUE            ,
 LEVEL_VALUE_APPLICATION_ID
)
SELECT
 235,                               -- APPLICATION_ID
 (select profile_option_id
  from   fnd_profile_options
  where  profile_option_name = 'ZX_INVENTORY_ITEM_FOR_FREIGHT'), -- PROFILE_OPTION_ID
 LEVEL_ID,
 LEVEL_VALUE,
 sysdate,                        --LAST_UPDATE_DATE
 fnd_global.user_id,             --LAST_UPDATED_BY
 sysdate,                        --CREATION_DATE
 fnd_global.user_id,             --CREATED_BY
 fnd_global.conc_login_id,       --LAST_UPDATE_LOGIN
 PROFILE_OPTION_VALUE,
 LEVEL_VALUE_APPLICATION_ID
FROM     fnd_profile_option_values
WHERE    profile_option_id = (select profile_option_id
                              from   fnd_profile_options
                              where  profile_option_name = 'OE_INVENTORY_ITEM_FOR_FREIGHT')
AND     NOT EXISTS (SELECT 1
                    FROM   fnd_profile_option_values
                    WHERE  profile_option_id = (SELECT profile_option_id
                                                FROM   fnd_profile_options
                                                WHERE  profile_option_name = 'ZX_INVENTORY_ITEM_FOR_FREIGHT')
                   );


-- 4.

INSERT INTO FND_PROFILE_OPTION_VALUES
(
 APPLICATION_ID                  ,
 PROFILE_OPTION_ID               ,
 LEVEL_ID                        ,
 LEVEL_VALUE                     ,
 LAST_UPDATE_DATE                ,
 LAST_UPDATED_BY                 ,
 CREATION_DATE                   ,
 CREATED_BY                      ,
 LAST_UPDATE_LOGIN               ,
 PROFILE_OPTION_VALUE            ,
 LEVEL_VALUE_APPLICATION_ID
)
SELECT
 235,                               -- APPLICATION_ID
 (select profile_option_id
  from   fnd_profile_options
  where  profile_option_name = 'ZX_INVOICE_FREIGHT_AS_LINE'), -- PROFILE_OPTION_ID
 LEVEL_ID,
 LEVEL_VALUE,
 sysdate,                        --LAST_UPDATE_DATE
 fnd_global.user_id,             --LAST_UPDATED_BY
 sysdate,                        --CREATION_DATE
 fnd_global.user_id,             --CREATED_BY
 fnd_global.conc_login_id,       --LAST_UPDATE_LOGIN
 PROFILE_OPTION_VALUE,
 LEVEL_VALUE_APPLICATION_ID
FROM     fnd_profile_option_values
WHERE    profile_option_id = (select profile_option_id
                              from   fnd_profile_options
                              where  profile_option_name = 'OE_INVOICE_FREIGHT_AS_LINE')
AND     NOT EXISTS (SELECT 1
                    FROM   fnd_profile_option_values
                    WHERE  profile_option_id = (SELECT profile_option_id
                                                FROM   fnd_profile_options
                                                WHERE  profile_option_name = 'ZX_INVOICE_FREIGHT_AS_LINE')
                   );
*/

-- 5.

INSERT INTO FND_PROFILE_OPTION_VALUES
(
 APPLICATION_ID                  ,
 PROFILE_OPTION_ID               ,
 LEVEL_ID                        ,
 LEVEL_VALUE                     ,
 LAST_UPDATE_DATE                ,
 LAST_UPDATED_BY                 ,
 CREATION_DATE                   ,
 CREATED_BY                      ,
 LAST_UPDATE_LOGIN               ,
 PROFILE_OPTION_VALUE            ,
 LEVEL_VALUE_APPLICATION_ID
)
SELECT
 235,                               -- APPLICATION_ID
 (select profile_option_id
  from   fnd_profile_options
  where  profile_option_name = 'ZX_ALLOW_TAX_RECVRY_RATE_OVERRIDE'), -- PROFILE_OPTION_ID
 LEVEL_ID,
 LEVEL_VALUE,
 sysdate,                        --LAST_UPDATE_DATE
 fnd_global.user_id,             --LAST_UPDATED_BY
 sysdate,                        --CREATION_DATE
 fnd_global.user_id,             --CREATED_BY
 fnd_global.conc_login_id,       --LAST_UPDATE_LOGIN
 PROFILE_OPTION_VALUE,
 LEVEL_VALUE_APPLICATION_ID
FROM     fnd_profile_option_values
WHERE    profile_option_id = (select profile_option_id
                              from   fnd_profile_options
                              where  profile_option_name = 'AP_ALLOW_TAX_RECVRY_RATE_OVERRIDE')
AND     NOT EXISTS (SELECT 1
                    FROM   fnd_profile_option_values
                    WHERE  profile_option_id = (SELECT profile_option_id
                                                FROM   fnd_profile_options
                                                WHERE  profile_option_name = 'ZX_ALLOW_TAX_RECVRY_RATE_OVERRIDE')
                   );

-- 6.

INSERT INTO FND_PROFILE_OPTION_VALUES
(
 APPLICATION_ID                  ,
 PROFILE_OPTION_ID               ,
 LEVEL_ID                        ,
 LEVEL_VALUE                     ,
 LAST_UPDATE_DATE                ,
 LAST_UPDATED_BY                 ,
 CREATION_DATE                   ,
 CREATED_BY                      ,
 LAST_UPDATE_LOGIN               ,
 PROFILE_OPTION_VALUE            ,
 LEVEL_VALUE_APPLICATION_ID
)
SELECT
 235,                               -- APPLICATION_ID
 (select profile_option_id
  from   fnd_profile_options
  where  profile_option_name = 'ZX_ALLOW_TAX_CLASSIF_OVERRIDE'), -- PROFILE_OPTION_ID
 LEVEL_ID,
 LEVEL_VALUE,
 sysdate,                        --LAST_UPDATE_DATE
 fnd_global.user_id,             --LAST_UPDATED_BY
 sysdate,                        --CREATION_DATE
 fnd_global.user_id,             --CREATED_BY
 fnd_global.conc_login_id,       --LAST_UPDATE_LOGIN
 PROFILE_OPTION_VALUE,
 LEVEL_VALUE_APPLICATION_ID
FROM     fnd_profile_option_values
WHERE    profile_option_id = (select profile_option_id
                              from   fnd_profile_options
                              where  profile_option_name = 'AR_ALLOW_TAX_CODE_OVERRIDE')
AND     NOT EXISTS (SELECT 1
                    FROM   fnd_profile_option_values
                    WHERE  profile_option_id = (SELECT profile_option_id
                                                FROM   fnd_profile_options
                                                WHERE  profile_option_name = 'ZX_ALLOW_TAX_CLASSIF_OVERRIDE')
                   );

-- 7.

/* Vendor Profiles : Bug 4631047 */

INSERT INTO FND_PROFILE_OPTION_VALUES
(
 APPLICATION_ID                  ,
 PROFILE_OPTION_ID               ,
 LEVEL_ID                        ,
 LEVEL_VALUE                     ,
 LAST_UPDATE_DATE                ,
 LAST_UPDATED_BY                 ,
 CREATION_DATE                   ,
 CREATED_BY                      ,
 LAST_UPDATE_LOGIN               ,
 PROFILE_OPTION_VALUE            ,
 LEVEL_VALUE_APPLICATION_ID
)
SELECT
 235,                               -- APPLICATION_ID
 (select profile_option_id
  from   fnd_profile_options
  where  profile_option_name = 'ZX_TAXVDR_USENEXPRO'), -- PROFILE_OPTION_ID
 LEVEL_ID,
 LEVEL_VALUE,
 sysdate,                        --LAST_UPDATE_DATE
 fnd_global.user_id,             --LAST_UPDATED_BY
 sysdate,                        --CREATION_DATE
 fnd_global.user_id,             --CREATED_BY
 fnd_global.conc_login_id,       --LAST_UPDATE_LOGIN
 PROFILE_OPTION_VALUE,
 LEVEL_VALUE_APPLICATION_ID
FROM     fnd_profile_option_values valar
       , fnd_profile_options fpoar
WHERE    valar.profile_option_id = fpoar.profile_option_id
AND      fpoar.profile_option_name = 'AR_TAXVDR_USENEXPRO'
AND      NOT EXISTS (SELECT 1
                    FROM   fnd_profile_option_values valzx
                         , fnd_profile_options fpozx
                    WHERE  valzx.profile_option_id = fpozx.profile_option_id
                      AND  fpozx.profile_option_name = 'ZX_TAXVDR_USENEXPRO');

-- 8.

INSERT INTO FND_PROFILE_OPTION_VALUES
(
 APPLICATION_ID                  ,
 PROFILE_OPTION_ID               ,
 LEVEL_ID                        ,
 LEVEL_VALUE                     ,
 LAST_UPDATE_DATE                ,
 LAST_UPDATED_BY                 ,
 CREATION_DATE                   ,
 CREATED_BY                      ,
 LAST_UPDATE_LOGIN               ,
 PROFILE_OPTION_VALUE            ,
 LEVEL_VALUE_APPLICATION_ID
)
SELECT
 235,                               -- APPLICATION_ID
 (select profile_option_id
  from   fnd_profile_options
  where  profile_option_name = 'ZX_TAXVDR_TAXSELPARAM'), -- PROFILE_OPTION_ID
 LEVEL_ID,
 LEVEL_VALUE,
 sysdate,                        --LAST_UPDATE_DATE
 fnd_global.user_id,             --LAST_UPDATED_BY
 sysdate,                        --CREATION_DATE
 fnd_global.user_id,             --CREATED_BY
 fnd_global.conc_login_id,       --LAST_UPDATE_LOGIN
 PROFILE_OPTION_VALUE,
 LEVEL_VALUE_APPLICATION_ID
FROM     fnd_profile_option_values valar
       , fnd_profile_options fpoar
WHERE    valar.profile_option_id = fpoar.profile_option_id
AND      fpoar.profile_option_name = 'AR_TAXVDR_TAXSELPARAM'
AND      NOT EXISTS (SELECT 1
                    FROM   fnd_profile_option_values valzx
                         , fnd_profile_options fpozx
                    WHERE  valzx.profile_option_id = fpozx.profile_option_id
                      AND  fpozx.profile_option_name = 'ZX_TAXVDR_TAXSELPARAM');

-- 9.

/*
INSERT INTO FND_PROFILE_OPTION_VALUES
(
 APPLICATION_ID                  ,
 PROFILE_OPTION_ID               ,
 LEVEL_ID                        ,
 LEVEL_VALUE                     ,
 LAST_UPDATE_DATE                ,
 LAST_UPDATED_BY                 ,
 CREATION_DATE                   ,
 CREATED_BY                      ,
 LAST_UPDATE_LOGIN               ,
 PROFILE_OPTION_VALUE            ,
 LEVEL_VALUE_APPLICATION_ID
)
SELECT
 235,                               -- APPLICATION_ID
 (select profile_option_id
  from   fnd_profile_options
  where  profile_option_name = 'ZX_TAXVDR_TAXTYPE'), -- PROFILE_OPTION_ID
 LEVEL_ID,
 LEVEL_VALUE,
 sysdate,                        --LAST_UPDATE_DATE
 fnd_global.user_id,             --LAST_UPDATED_BY
 sysdate,                        --CREATION_DATE
 fnd_global.user_id,             --CREATED_BY
 fnd_global.conc_login_id,       --LAST_UPDATE_LOGIN
 PROFILE_OPTION_VALUE,
 LEVEL_VALUE_APPLICATION_ID
FROM     fnd_profile_option_values valar
       , fnd_profile_options fpoar
WHERE    valar.profile_option_id = fpoar.profile_option_id
AND      fpoar.profile_option_name = 'AR_TAXVDR_TAXTYPE'
AND      NOT EXISTS (SELECT 1
                    FROM   fnd_profile_option_values valzx
                         , fnd_profile_options fpozx
                    WHERE  valzx.profile_option_id = fpozx.profile_option_id
                      AND  fpozx.profile_option_name = 'ZX_TAXVDR_TAXTYPE');
*/

-- 10.

INSERT INTO FND_PROFILE_OPTION_VALUES
(
 APPLICATION_ID                  ,
 PROFILE_OPTION_ID               ,
 LEVEL_ID                        ,
 LEVEL_VALUE                     ,
 LAST_UPDATE_DATE                ,
 LAST_UPDATED_BY                 ,
 CREATION_DATE                   ,
 CREATED_BY                      ,
 LAST_UPDATE_LOGIN               ,
 PROFILE_OPTION_VALUE            ,
 LEVEL_VALUE_APPLICATION_ID
)
SELECT
 235,                               -- APPLICATION_ID
 (select profile_option_id
  from   fnd_profile_options
  where  profile_option_name = 'ZX_TAXVDR_SERVICEIND'), -- PROFILE_OPTION_ID
 LEVEL_ID,
 LEVEL_VALUE,
 sysdate,                        --LAST_UPDATE_DATE
 fnd_global.user_id,             --LAST_UPDATED_BY
 sysdate,                        --CREATION_DATE
 fnd_global.user_id,             --CREATED_BY
 fnd_global.conc_login_id,       --LAST_UPDATE_LOGIN
 PROFILE_OPTION_VALUE,
 LEVEL_VALUE_APPLICATION_ID
FROM     fnd_profile_option_values valar
       , fnd_profile_options fpoar
WHERE    valar.profile_option_id = fpoar.profile_option_id
AND      fpoar.profile_option_name = 'AR_TAXVDR_SERVICEIND'
AND      NOT EXISTS (SELECT 1
                    FROM   fnd_profile_option_values valzx
                         , fnd_profile_options fpozx
                    WHERE  valzx.profile_option_id = fpozx.profile_option_id
                      AND  fpozx.profile_option_name = 'ZX_TAXVDR_SERVICEIND');

-- 11.

INSERT INTO FND_PROFILE_OPTION_VALUES
(
 APPLICATION_ID                  ,
 PROFILE_OPTION_ID               ,
 LEVEL_ID                        ,
 LEVEL_VALUE                     ,
 LAST_UPDATE_DATE                ,
 LAST_UPDATED_BY                 ,
 CREATION_DATE                   ,
 CREATED_BY                      ,
 LAST_UPDATE_LOGIN               ,
 PROFILE_OPTION_VALUE            ,
 LEVEL_VALUE_APPLICATION_ID
)
SELECT
 235,                               -- APPLICATION_ID
 (select profile_option_id
  from   fnd_profile_options
  where  profile_option_name = 'ZX_TAXVDR_CASESENSITIVE'), -- PROFILE_OPTION_ID
 LEVEL_ID,
 LEVEL_VALUE,
 sysdate,                        --LAST_UPDATE_DATE
 fnd_global.user_id,             --LAST_UPDATED_BY
 sysdate,                        --CREATION_DATE
 fnd_global.user_id,             --CREATED_BY
 fnd_global.conc_login_id,       --LAST_UPDATE_LOGIN
 PROFILE_OPTION_VALUE,
 LEVEL_VALUE_APPLICATION_ID
FROM     fnd_profile_option_values valar
       , fnd_profile_options fpoar
WHERE    valar.profile_option_id = fpoar.profile_option_id
AND      fpoar.profile_option_name = 'AR_TAXVDR_CASESENSITIVE'
AND      NOT EXISTS (SELECT 1
                    FROM   fnd_profile_option_values valzx
                         , fnd_profile_options fpozx
                    WHERE  valzx.profile_option_id = fpozx.profile_option_id
                      AND  fpozx.profile_option_name = 'ZX_TAXVDR_CASESENSITIVE');

-- 12.

END migrate_tax_profile_values;


/*===========================================================================+
 | PROCEDURE
 |    end_date_tax_profiles
 |
 | IN
 |    p_mig_phase : NULL for downtime processing.
 |                  PRE-MIG for pre-migration patch processing.
 |
 | OUT
 |
 | DESCRIPTION
 |     This routine end date AP/AR/OM Tax Profiles.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | CALLED FROM
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | 04/08/2005   Yoshimichi Konishi   Created.
 |
 +==========================================================================*/
PROCEDURE end_date_tax_profiles (p_mig_phase   VARCHAR2)
IS
BEGIN
IF p_mig_phase <> 'PRE-MIG' THEN
--
-- DISABLE/END DATE FND_PROFILE_OPTIONS
--
-- Note: 04/08/2005
--       End dating profile should not be executed for pre-migration patch.
--
UPDATE fnd_profile_options
SET    END_DATE_ACTIVE = sysdate,
       LAST_UPDATE_DATE = sysdate,
       LAST_UPDATED_BY = fnd_global.user_id,
       LAST_UPDATE_LOGIN = fnd_global.conc_login_id
WHERE  profile_option_name = 'AR_ALLOW_TRX_LINE_EXEMPTIONS'
AND    end_date_active IS NULL;

-- 1.

UPDATE fnd_profile_options
SET    END_DATE_ACTIVE = sysdate,
       LAST_UPDATE_DATE = sysdate,
       LAST_UPDATED_BY = fnd_global.user_id,
       LAST_UPDATE_LOGIN = fnd_global.conc_login_id
WHERE  profile_option_name = 'AR_ALLOW_TAX_UPDATE'
AND    end_date_active IS NULL;

-- 2.

UPDATE fnd_profile_options
SET    END_DATE_ACTIVE = sysdate,
       LAST_UPDATE_DATE = sysdate,
       LAST_UPDATED_BY = fnd_global.user_id,
       LAST_UPDATE_LOGIN = fnd_global.conc_login_id
WHERE  profile_option_name = 'AR_ALLOW_MANUAL_TAX_LINES'
AND    end_date_active IS NULL;

-- 3.

UPDATE fnd_profile_options
SET    END_DATE_ACTIVE = sysdate,
       LAST_UPDATE_DATE = sysdate,
       LAST_UPDATED_BY = fnd_global.user_id,
       LAST_UPDATE_LOGIN = fnd_global.conc_login_id
WHERE  profile_option_name = 'OE_INVENTORY_ITEM_FOR_FREIGHT'
AND    end_date_active IS NULL;


-- 4.

UPDATE fnd_profile_options
SET    END_DATE_ACTIVE = sysdate,
       LAST_UPDATE_DATE = sysdate,
       LAST_UPDATED_BY = fnd_global.user_id,
       LAST_UPDATE_LOGIN = fnd_global.conc_login_id
WHERE  profile_option_name = 'OE_INVOICE_FREIGHT_AS_LINE'
AND    end_date_active IS NULL;

-- 5.

UPDATE fnd_profile_options
SET    END_DATE_ACTIVE = sysdate,
       LAST_UPDATE_DATE = sysdate,
       LAST_UPDATED_BY = fnd_global.user_id,
       LAST_UPDATE_LOGIN = fnd_global.conc_login_id
WHERE  profile_option_name = 'AP_ALLOW_TAX_RECVRY_RATE_OVERRIDE'
AND    end_date_active IS NULL;

-- 6.

UPDATE fnd_profile_options
SET    END_DATE_ACTIVE = sysdate,
       LAST_UPDATE_DATE = sysdate,
       LAST_UPDATED_BY = fnd_global.user_id,
       LAST_UPDATE_LOGIN = fnd_global.conc_login_id
WHERE  profile_option_name = 'AR_ALLOW_TAX_CODE_OVERRIDE'
AND    end_date_active IS NULL;

-- 7.

/* Tax Vendor Profiles : Bug 4631047 */

UPDATE fnd_profile_options
SET    END_DATE_ACTIVE = sysdate,
       LAST_UPDATE_DATE = sysdate,
       LAST_UPDATED_BY = fnd_global.user_id,
       LAST_UPDATE_LOGIN = fnd_global.conc_login_id
WHERE  profile_option_name = 'AR_TAXVDR_USENEXPRO'
AND    end_date_active IS NULL;

-- 8.

UPDATE fnd_profile_options
SET    END_DATE_ACTIVE = sysdate,
       LAST_UPDATE_DATE = sysdate,
       LAST_UPDATED_BY = fnd_global.user_id,
       LAST_UPDATE_LOGIN = fnd_global.conc_login_id
WHERE  profile_option_name =  'AR_TAXVDR_TAXSELPARAM'
AND    end_date_active IS NULL;

-- 9.

UPDATE fnd_profile_options
SET    END_DATE_ACTIVE = sysdate,
       LAST_UPDATE_DATE = sysdate,
       LAST_UPDATED_BY = fnd_global.user_id,
       LAST_UPDATE_LOGIN = fnd_global.conc_login_id
WHERE  profile_option_name =  'AR_TAXVDR_TAXTYPE'
AND    end_date_active IS NULL;

-- 10.

UPDATE fnd_profile_options
SET    END_DATE_ACTIVE = sysdate,
       LAST_UPDATE_DATE = sysdate,
       LAST_UPDATED_BY = fnd_global.user_id,
       LAST_UPDATE_LOGIN = fnd_global.conc_login_id
WHERE  profile_option_name =  'AR_TAXVDR_SERVICEIND'
AND    end_date_active IS NULL;

-- 11.

UPDATE fnd_profile_options
SET    END_DATE_ACTIVE = sysdate,
       LAST_UPDATE_DATE = sysdate,
       LAST_UPDATED_BY = fnd_global.user_id,
       LAST_UPDATE_LOGIN = fnd_global.conc_login_id
WHERE  profile_option_name =  'AR_TAXVDR_CASESENSITIVE'
AND    end_date_active IS NULL;

-- 12.

END IF;
END;

END zx_migrate_tax_profiles;

/
