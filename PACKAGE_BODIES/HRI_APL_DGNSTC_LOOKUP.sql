--------------------------------------------------------
--  DDL for Package Body HRI_APL_DGNSTC_LOOKUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_APL_DGNSTC_LOOKUP" AS
/* $Header: hriadglk.pkb 120.1 2006/12/05 08:55:38 smohapat noship $ */

FUNCTION get_lookup_sql(p_lookup_code  IN VARCHAR2)
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT hr_bis.bis_decode_lookup(''' || p_lookup_code || ''',:p_value)
 FROM dual';

  RETURN l_sql_stmt;

END get_lookup_sql;

FUNCTION get_rate_type
      RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT user_conversion_type
FROM gl_daily_conversion_types
WHERE conversion_type = :p_value';

  RETURN l_sql_stmt;

END get_rate_type;

FUNCTION get_currency_code
      RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT name meaning
FROM fnd_currencies_active_v
WHERE currency_code = :p_value';

  RETURN l_sql_stmt;

END get_currency_code;

FUNCTION get_flex_value_set
      RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT flex_value_set_name
FROM fnd_flex_value_sets
WHERE flex_value_set_id = :p_value';

  RETURN l_sql_stmt;

END get_flex_value_set;


FUNCTION get_org_struct_name
      RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT name
FROM per_organization_structures
WHERE organization_structure_id =:p_value';

  RETURN l_sql_stmt;

END get_org_struct_name;


FUNCTION validate_bucket_sql(p_bucket_code  IN VARCHAR2)
       RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT
 CASE WHEN ((CASE WHEN range1_low  IS NOT NULL OR
                       range1_high IS NOT NULL
                  THEN 1 ELSE 0 END) +
            (CASE WHEN range2_low  IS NOT NULL OR
                       range2_high IS NOT NULL
                  THEN 1 ELSE 0 END) +
            (CASE WHEN range3_low  IS NOT NULL OR
                       range3_high IS NOT NULL
                  THEN 1 ELSE 0 END) +
            (CASE WHEN range4_low  IS NOT NULL OR
                       range4_high IS NOT NULL
                 THEN 1 ELSE 0 END) +
            (CASE WHEN range5_low  IS NOT NULL OR
                       range5_high IS NOT NULL
                  THEN 1 ELSE 0 END) +
            (CASE WHEN range6_low  IS NOT NULL OR
                       range6_high IS NOT NULL
                  THEN 1 ELSE 0 END) +
            (CASE WHEN range7_low  IS NOT NULL OR
                       range7_high IS NOT NULL
                 THEN 1 ELSE 0 END) +
            (CASE WHEN range8_low  IS NOT NULL OR
                       range8_high IS NOT NULL
                  THEN 1 ELSE 0 END) +
            (CASE WHEN range9_low  IS NOT NULL OR
                       range9_high IS NOT NULL
                  THEN 1 ELSE 0 END) +
            (CASE WHEN range10_low  IS NOT NULL OR
                       range10_high IS NOT NULL
                  THEN 1 ELSE 0 END)
          <= 5 )
      THEN ''Y'' ELSE ''N''
 END range
FROM bis_bucket
WHERE short_name = ''' || p_bucket_code || '''';

  RETURN l_sql_stmt;

END validate_bucket_sql;

END hri_apl_dgnstc_lookup;

/
