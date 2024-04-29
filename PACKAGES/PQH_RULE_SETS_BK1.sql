--------------------------------------------------------
--  DDL for Package PQH_RULE_SETS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RULE_SETS_BK1" AUTHID CURRENT_USER as
/* $Header: pqrstapi.pkh 120.2 2005/10/28 17:59:06 deenath noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_RULE_SET_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_RULE_SET_b
  (
   p_business_group_id              in  number
  ,p_rule_set_name                  in  varchar2
  ,p_description		    in varchar2
  ,p_organization_structure_id      in  number
  ,p_organization_id                in  number
  ,p_referenced_rule_set_id         in  number
  ,p_rule_level_cd                  in  varchar2
  ,p_short_name                     in  varchar2
  ,p_effective_date                 in  date
  ,p_rule_applicability		   in varchar2
  ,p_rule_category		   in varchar2
  ,p_starting_organization_id	   in number
  ,p_seeded_rule_flag		   in varchar2
  ,p_status      		   in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_RULE_SET_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_RULE_SET_a
  (
   p_business_group_id              in  number
  ,p_rule_set_id                    in  number
  ,p_rule_set_name                  in  varchar2
  ,p_description		    in  varchar2
  ,p_organization_structure_id      in  number
  ,p_organization_id                in  number
  ,p_referenced_rule_set_id         in  number
  ,p_rule_level_cd                  in  varchar2
  ,p_object_version_number          in  number
  ,p_short_name                     in  varchar2
  ,p_effective_date                 in  date
  ,p_rule_applicability		   in varchar2
  ,p_rule_category		   in varchar2
  ,p_starting_organization_id	   in number
  ,p_seeded_rule_flag		   in varchar2
  ,p_status     		   in varchar2
  );
--
end pqh_RULE_SETS_bk1;

 

/
