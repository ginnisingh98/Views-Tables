--------------------------------------------------------
--  DDL for Package CN_SFP_ROLE_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SFP_ROLE_UTIL_PVT" AUTHID CURRENT_USER AS
 /*$Header: cnsfrols.pls 115.1 2003/01/08 20:25:47 sbadami noship $*/

FUNCTION is_org_valid_role
(
  p_role_id IN NUMBER
) RETURN VARCHAR2;

FUNCTION validate_roleqc_for_rates
(
  p_role_quota_cate_id IN NUMBER
) RETURN VARCHAR2;

END CN_SFP_ROLE_UTIL_PVT;

 

/
