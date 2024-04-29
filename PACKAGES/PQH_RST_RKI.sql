--------------------------------------------------------
--  DDL for Package PQH_RST_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RST_RKI" AUTHID CURRENT_USER as
/* $Header: pqrstrhi.pkh 120.4 2007/04/19 12:47:42 brsinha noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_business_group_id              in number
 ,p_rule_set_id                    in number
 ,p_rule_set_name                  in varchar2
 ,p_organization_structure_id      in number
 ,p_organization_id                in number
 ,p_referenced_rule_set_id         in number
 ,p_rule_level_cd                  in varchar2
 ,p_object_version_number          in number
 ,p_short_name                     in varchar2
 ,p_effective_date                 in date
 ,p_rule_applicability		   in varchar2
 ,p_rule_category		   in varchar2
 ,p_starting_organization_id	   in number
 ,p_seeded_rule_flag               in varchar2
 ,p_status                         in varchar2
  );
end pqh_rst_rki;

/