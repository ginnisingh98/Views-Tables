--------------------------------------------------------
--  DDL for Package JAI_PLSQL_CACHE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_PLSQL_CACHE_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_plsql_cache.pls 120.3 2006/05/26 11:36:23 lgopalsa noship $ */

TYPE func_curr_details IS RECORD
  ( --organization_id  HR_ALL_ORGANIZATION_UNITS.organization_id%TYPE, -- org id
    ledger_id            GL_LEDGERS.ledger_id%TYPE , -- SOB
    currency_code        GL_LEDGERS.currency_code%TYPE ,
    chart_of_accounts_id GL_LEDGERS.chart_of_accounts_id%TYPE,
    organization_code    MTL_PARAMETERS.organization_code%TYPE,
    legal_entity         HR_ORGANIZATION_INFORMATION.org_information2%TYPE,
    organization_name    HR_ALL_ORGANIZATION_UNITS.name%TYPE,
    -- Bug 5243532. Added by Lakshmi Gopalsami
    minimum_acct_unit    FND_CURRENCIES.minimum_accountable_unit%TYPE,
    precision            FND_CURRENCIES.precision%TYPE
  );

TYPE func_curr_det_tab IS TABLE OF func_curr_details
 INDEX BY BINARY_INTEGER;

 g_get_func_curr func_curr_det_tab;

CURSOR get_inv_org
      (cp_org_id IN HR_ALL_ORGANIZATION_UNITS.organization_id%TYPE) is
SELECT set_of_books_id ledger_id ,
       organization_code org_code,
       legal_entity leg_ent,
       organization_name org_name
FROM org_organization_definitions
WHERE organization_id = cp_org_id;


CURSOR get_OU
       (cp_org_id in HR_ALL_ORGANIZATION_UNITS.organization_id%TYPE) is
SELECT set_of_books_id ledger_id ,
       NULL org_code,  -- Bug 5243532.Included org_code
       default_legal_context_id leg_ent,
       name org_name
FROM hr_operating_units
WHERE organization_id = cp_org_id;


CURSOR get_func_curr
       (cp_ledger_id IN GL_LEDGERS.ledger_id%TYPE) IS
SELECT currency_code curr_code,
       chart_of_accounts_id coa
  FROM gl_ledgers
 WHERE ledger_id = cp_ledger_id;

/* Bug 5243532. Added by Lakshmi Gopalsami */
/* Currency precision details */
 CURSOR get_curr_details (cp_curr IN fnd_currencies.currency_code%TYPE) is
 SELECT  minimum_accountable_unit minimum_acct_unit,
         PRECISION
   FROM fnd_currencies
  WHERE currency_code = cp_curr;

/* Read from cache */
FUNCTION  read_cache
         (p_org_id in HR_ALL_ORGANIZATION_UNITS.organization_id%TYPE )
 RETURN func_curr_details;

/* Write from cache */
PROCEDURE write_cache
          (p_org_id IN HR_ALL_ORGANIZATION_UNITS.organization_id%TYPE,
           p_func_curr_det IN func_curr_details
          );

/* Read from db and write into cache */
FUNCTION read_from_db
         (p_org_id IN HR_ALL_ORGANIZATION_UNITS.organization_id%TYPE )
 RETURN func_curr_details;

/* Function which performs reading from cache, if not found
   read from db and write onto the cache and return the same
*/

FUNCTION return_sob_curr
         (p_org_id  IN HR_ALL_ORGANIZATION_UNITS.organization_id%TYPE)
  RETURN func_curr_details;


END JAI_PLSQL_CACHE_PKG;
 

/
