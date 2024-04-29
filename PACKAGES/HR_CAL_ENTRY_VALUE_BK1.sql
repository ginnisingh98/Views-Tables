--------------------------------------------------------
--  DDL for Package HR_CAL_ENTRY_VALUE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAL_ENTRY_VALUE_BK1" AUTHID CURRENT_USER as
/* $Header: peenvapi.pkh 120.0 2005/05/31 08:10:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_entry_value_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_entry_value_b
  (p_effective_date          in date
  ,p_calendar_entry_id       in number
  ,p_hierarchy_node_id       in number
  ,p_value                   in varchar2
  ,p_org_structure_element_id in number
  ,p_organization_id         in number
  ,p_override_name           in varchar2
  ,p_override_type           in varchar2
  ,p_parent_entry_value_id   in number
  ,p_usage_flag              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_entry_value_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_entry_value_a
  (p_effective_date          in date
  ,p_calendar_entry_id       in number
  ,p_hierarchy_node_id       in number
  ,p_value                   in varchar2
  ,p_org_structure_element_id in number
  ,p_organization_id         in number
  ,p_override_name           in varchar2
  ,p_override_type           in varchar2
  ,p_parent_entry_value_id   in number
  ,p_usage_flag              in varchar2
  ,p_cal_entry_value_id      in number
  ,p_object_version_number   in number
  );
--
end HR_CAL_ENTRY_VALUE_BK1;

 

/
