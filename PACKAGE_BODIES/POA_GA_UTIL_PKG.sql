--------------------------------------------------------
--  DDL for Package Body POA_GA_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_GA_UTIL_PKG" as
/* $Header: poagautilb.pls 115.2 2004/01/24 00:00:08 mangupta noship $ */

FUNCTION is_enabled(p_po_header_id IN PO_HEADERS_ALL.po_header_id%TYPE,
                    p_org_id IN PO_HEADERS_ALL.org_id%TYPE)
RETURN VARCHAR2 IS

 l_enabled_flag PO_GA_ORG_ASSIGNMENTS.enabled_flag%TYPE;

BEGIN

 SELECT pgoa.enabled_flag
 INTO   l_enabled_flag
 FROM   po_ga_org_assignments pgoa
 WHERE  pgoa.po_header_id = p_po_header_id -- input global agreement id
 AND    pgoa.organization_id = p_org_id; -- input org id

 return l_enabled_flag;

EXCEPTION

 WHEN OTHERS THEN
   return 'N';

END is_enabled;

FUNCTION is_global_agreement(p_po_header_id IN PO_HEADERS_ALL.po_header_id%TYPE)
RETURN VARCHAR2 IS

  l_global_agreement_flag PO_HEADERS_ALL.global_agreement_flag%TYPE;

BEGIN

 SELECT global_agreement_flag
 INTO l_global_agreement_flag
 FROM po_headers_all
 WHERE po_header_id = p_po_header_id;

 return nvl(l_global_agreement_flag, 'N');

EXCEPTION

 WHEN OTHERS THEN
   return 'N';

END is_global_agreement;

-- from currency code is the functional currency of the global agreement
-- to currency code is the functional currency of the standard PO
-- We convert from the functional currency of the GA to the DBI
-- primary global currency using DBI primary rate type and Std PO rate date
-- and then convert from DBI primary global currency to the functional
-- currency of the std PO using DBI primary rate type and Std PO rate date

FUNCTION get_ga_conversion_rate(p_from_currency_code IN VARCHAR2, p_to_currency_code IN VARCHAR2, p_rate_date IN DATE)

RETURN NUMBER IS

  l_global_currency_code  VARCHAR2(30);
  l_global_rate_type   VARCHAR2(15);
  rate1  NUMBER;
  rate2  NUMBER;

begin

  -- convert GA functional currency to DBI global currency
  rate1 := fii_currency.get_global_rate_primary(p_from_currency_code, p_rate_date);

  if(rate1 is null or rate1 < 0) then return null; end if;

  -- now convert DBI global currency to std PO functional currency
  l_global_currency_code := bis_common_parameters.get_currency_code;
  l_global_rate_type := bis_common_parameters.get_rate_type;

  rate2 := fii_currency.get_rate(l_global_currency_code, p_to_currency_code, p_rate_date, l_global_rate_type);

  if(rate2 is null or rate2 < 0) then return null; end if;

  RETURN (rate1 * rate2);

EXCEPTION
  WHEN OTHERS THEN
     return null;

END get_ga_conversion_rate;

END POA_GA_UTIL_PKG;

/
