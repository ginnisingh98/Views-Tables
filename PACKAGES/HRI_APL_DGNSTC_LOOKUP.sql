--------------------------------------------------------
--  DDL for Package HRI_APL_DGNSTC_LOOKUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_APL_DGNSTC_LOOKUP" AUTHID CURRENT_USER AS
/* $Header: hriadglk.pkh 120.1 2006/12/05 09:01:51 smohapat noship $ */

FUNCTION get_lookup_sql(p_lookup_code   IN VARCHAR2)
     RETURN VARCHAR2;

FUNCTION get_rate_type
     RETURN VARCHAR2;

FUNCTION get_currency_code
     RETURN VARCHAR2;

FUNCTION get_flex_value_set
     RETURN VARCHAR2;

FUNCTION get_org_struct_name
     RETURN VARCHAR2;

FUNCTION validate_bucket_sql(p_bucket_code  IN VARCHAR2)
     RETURN VARCHAR2;

END hri_apl_dgnstc_lookup;

/
