--------------------------------------------------------
--  DDL for Package PER_ENV_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ENV_RKD" AUTHID CURRENT_USER as
/* $Header: peenvrhi.pkh 120.0 2005/05/31 08:11:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_cal_entry_value_id           in number
  ,p_calendar_entry_id_o          in number
  ,p_hierarchy_node_id_o          in number
  ,p_value_o                      in varchar2
  ,p_org_structure_element_id_o   in number
  ,p_organization_id_o            in number
  ,p_override_name_o              in varchar2
  ,p_override_type_o              in varchar2
  ,p_parent_entry_value_id_o      in number
  ,p_usage_flag_o                 in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_env_rkd;

 

/
