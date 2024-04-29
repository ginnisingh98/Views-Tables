--------------------------------------------------------
--  DDL for Package Body ZX_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_UTIL_PKG" AS
/* $Header: zxutilb.pls 120.2.12010000.2 2008/12/17 07:22:26 spasala ship $ */

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_lookup_meaning                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function is used to get the FND lookup meaning value for the      |
 | given fnd lookup_type and lookup_code.                                    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_lookup_type                                          |
 |                    p_lookup_code                                          |
 |              OUT:                                                         |
 |                    Meaning                                                |
 |                                                                           |
 | RETURNS    :	Returns the lookup meaning value.                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 | 22-Mar-06    Venkatavaradhan    Created.                                  |
 +===========================================================================*/

FUNCTION get_lookup_meaning (p_lookup_type  IN VARCHAR2,
                             p_lookup_code  IN VARCHAR2)
         RETURN VARCHAR2 IS
   l_meaning fnd_lookups.meaning%TYPE;
   l_hash_value NUMBER;
BEGIN

   IF p_lookup_code IS NOT NULL AND
      p_lookup_type IS NOT NULL THEN

      l_hash_value := DBMS_UTILITY.get_hash_value(
                                   p_lookup_type||'@*?'||p_lookup_code,
                                   1000,
                                   25000);

      IF pg_zx_lookups_rec.EXISTS(l_hash_value) THEN
         l_meaning := pg_zx_lookups_rec(l_hash_value);
      ELSE
         SELECT meaning  INTO l_meaning
         FROM   fnd_lookups
         WHERE  lookup_type = p_lookup_type
           AND  lookup_code = p_lookup_code
 	   AND  SYSDATE BETWEEN START_DATE_ACTIVE AND NVL(END_DATE_ACTIVE, SYSDATE)
	   AND  NVL(ENABLED_FLAG, 'N') = 'Y';

         pg_zx_lookups_rec(l_hash_value) := l_meaning;

     END IF;

   END IF;

   return(l_meaning);

 EXCEPTION
  WHEN no_data_found  THEN
   return(null);
  WHEN OTHERS THEN
   raise;

END;

PROCEDURE copy_accounts(p_tax_account_entity_code  IN VARCHAR2,
                        p_tax_account_entity_id    IN NUMBER)
IS
BEGIN

  IF (p_tax_account_entity_code = 'TAXES')
  THEN

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
        za.RECORD_TYPE_CODE,
        za.CREATED_BY,
        za.CREATION_DATE,
        za.LAST_UPDATED_BY,
        za.LAST_UPDATE_DATE,
        za.LAST_UPDATE_LOGIN
      FROM ZX_ACCOUNTS za,
           ZX_TAXES_B ztb,
           ZX_JURISDICTIONS_B zjb
      WHERE za.TAX_ACCOUNT_ENTITY_CODE = p_tax_account_entity_code
      AND   za.TAX_ACCOUNT_ENTITY_ID = p_tax_account_entity_id
      AND   ztb.TAX_ID = za.TAX_ACCOUNT_ENTITY_ID
      AND   zjb.TAX_REGIME_CODE = ztb.TAX_REGIME_CODE
      AND   zjb.TAX = ztb.TAX
      AND   NOT EXISTS (SELECT NULL
                        FROM ZX_ACCOUNTS juris_za
                        WHERE juris_za.TAX_ACCOUNT_ENTITY_CODE = 'JURISDICTION'
                        AND   juris_za.TAX_ACCOUNT_ENTITY_ID = zjb.TAX_JURISDICTION_ID
                        AND   juris_za.LEDGER_ID = za.LEDGER_ID
                        AND   juris_za.INTERNAL_ORGANIZATION_ID = za.INTERNAL_ORGANIZATION_ID);

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
        za.RECORD_TYPE_CODE,
        za.CREATED_BY,
        za.CREATION_DATE,
        za.LAST_UPDATED_BY,
        za.LAST_UPDATE_DATE,
        za.LAST_UPDATE_LOGIN
      FROM ZX_ACCOUNTS za,
           ZX_TAXES_B ztb,
           ZX_RATES_B zrb
      WHERE za.TAX_ACCOUNT_ENTITY_CODE = p_tax_account_entity_code
      AND   za.TAX_ACCOUNT_ENTITY_ID = p_tax_account_entity_id
      AND   ztb.TAX_ID = za.TAX_ACCOUNT_ENTITY_ID
      AND   zrb.TAX_REGIME_CODE = ztb.TAX_REGIME_CODE
      AND   zrb.TAX = ztb.TAX
      AND   NOT EXISTS (SELECT NULL
                        FROM ZX_ACCOUNTS rates_za
                        WHERE rates_za.TAX_ACCOUNT_ENTITY_CODE = 'RATES'
                        AND   rates_za.TAX_ACCOUNT_ENTITY_ID = zrb.TAX_RATE_ID
                        AND   rates_za.LEDGER_ID = za.LEDGER_ID
                        AND   rates_za.INTERNAL_ORGANIZATION_ID = za.INTERNAL_ORGANIZATION_ID);

  END IF;

  IF (p_tax_account_entity_code = 'JURISDICTION')
  THEN

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
        za.RECORD_TYPE_CODE,
        za.CREATED_BY,
        za.CREATION_DATE,
        za.LAST_UPDATED_BY,
        za.LAST_UPDATE_DATE,
        za.LAST_UPDATE_LOGIN
      FROM ZX_ACCOUNTS za,
           ZX_JURISDICTIONS_B zjb,
           ZX_RATES_B zrb
      WHERE za.TAX_ACCOUNT_ENTITY_CODE = p_tax_account_entity_code
      AND   za.TAX_ACCOUNT_ENTITY_ID = p_tax_account_entity_id
      AND   zjb.TAX_JURISDICTION_CODE = zrb.TAX_JURISDICTION_CODE
      AND   zjb.TAX_JURISDICTION_ID = za.TAX_ACCOUNT_ENTITY_ID
      AND   zrb.TAX_REGIME_CODE = zjb.TAX_REGIME_CODE
      AND   zrb.TAX = zjb.TAX
      AND   NOT EXISTS (SELECT NULL
                        FROM ZX_ACCOUNTS rates_za
                        WHERE rates_za.TAX_ACCOUNT_ENTITY_CODE = 'RATES'
                        AND   rates_za.TAX_ACCOUNT_ENTITY_ID = zrb.TAX_RATE_ID
                        AND   rates_za.LEDGER_ID = za.LEDGER_ID
                        AND   rates_za.INTERNAL_ORGANIZATION_ID = za.INTERNAL_ORGANIZATION_ID);

  END IF;

 EXCEPTION

  WHEN OTHERS THEN
   raise;

END copy_accounts;

END ZX_UTIL_PKG;

/
