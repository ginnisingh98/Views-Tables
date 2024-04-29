--------------------------------------------------------
--  DDL for Package PQH_RST_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RST_RKD" AUTHID CURRENT_USER as
/* $Header: pqrstrhi.pkh 120.4 2007/04/19 12:47:42 brsinha noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_rule_set_id                    in number
 ,p_business_group_id_o            in number
 ,p_rule_set_name_o                in varchar2
 ,p_organization_structure_id_o    in number
 ,p_organization_id_o              in number
 ,p_referenced_rule_set_id_o       in number
 ,p_rule_level_cd_o                in varchar2
 ,p_object_version_number_o        in number
 ,p_short_name_o                   in varchar2
 ,p_rule_applicability_o	   in varchar2
 ,p_rule_category_o		   in varchar2
 ,p_starting_organization_id_o	   in number
 ,p_seeded_rule_flag_o             in varchar2
 ,p_status_o                       in varchar2
  );
--
end pqh_rst_rkd;

/