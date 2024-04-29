--------------------------------------------------------
--  DDL for Package PER_ENV_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ENV_RKI" AUTHID CURRENT_USER as
/* $Header: peenvrhi.pkh 120.0 2005/05/31 08:11:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_cal_entry_value_id           in number
  ,p_calendar_entry_id            in number
  ,p_hierarchy_node_id            in number
  ,p_value                        in varchar2
  ,p_org_structure_element_id     in number
  ,p_organization_id              in number
  ,p_override_name                in varchar2
  ,p_override_type                in varchar2
  ,p_parent_entry_value_id        in number
  ,p_usage_flag                   in varchar2
  ,p_object_version_number        in number
  );
end per_env_rki;

 

/
