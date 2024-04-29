--------------------------------------------------------
--  DDL for Package BEN_CHECK_ORGANIZATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CHECK_ORGANIZATION" AUTHID CURRENT_USER AS
/* $Header: bechkorg.pkh 120.0 2005/05/28 01:02:46 appldev noship $*/
procedure chk_org_role_bnf_upd
(
  p_organization_id              IN hr_all_organization_units.organization_id%TYPE
 ,p_date_from                    IN date
 ,p_date_to                      IN date
);

procedure chk_org_role_bnf_del
(
  p_organization_id              IN hr_all_organization_units.organization_id%TYPE
);

END BEN_CHECK_ORGANIZATION;


 

/
