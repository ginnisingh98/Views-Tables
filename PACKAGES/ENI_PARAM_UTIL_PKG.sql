--------------------------------------------------------
--  DDL for Package ENI_PARAM_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_PARAM_UTIL_PKG" AUTHID CURRENT_USER AS
/*$Header: ENIPUTPS.pls 120.0 2005/05/26 19:35:41 appldev noship $*/

-- Retrieve the default parameter values
-- for the Product Performance - Development
-- parameter portlet
FUNCTION get_dbi_pme_params RETURN VARCHAR2;

FUNCTION get_dbi_pme_c_params RETURN VARCHAR2;

--Bug#3967047
-- Retrieve the default ORGANIZATION ID
g_default_org varchar2(50);
FUNCTION get_dbi_pme_org RETURN VARCHAR2;

FUNCTION is_valid_org(
	p_org_id NUMBER,
	p_resp_id NUMBER,
	p_as_of_date VARCHAR2) RETURN VARCHAR2;

FUNCTION get_dbi_pms_params RETURN VARCHAR2;

END eni_param_util_pkg;

 

/
