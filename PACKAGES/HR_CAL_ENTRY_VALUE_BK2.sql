--------------------------------------------------------
--  DDL for Package HR_CAL_ENTRY_VALUE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAL_ENTRY_VALUE_BK2" AUTHID CURRENT_USER as
/* $Header: peenvapi.pkh 120.0 2005/05/31 08:10:16 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------< update_entry_value_b >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_entry_value_b
 (p_effective_date                in date
 ,p_cal_entry_value_id            in number
 ,p_object_version_number         in number
 ,p_override_name                 in varchar2
 ,p_override_type                 in varchar2
 ,p_parent_entry_value_id         in number
 ,p_usage_flag                    in varchar2);
--
-- ----------------------------------------------------------------------------
-- |------------------< update_entry_value_a >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_entry_value_a
 (p_effective_date                in date
 ,p_cal_entry_value_id            in number
 ,p_object_version_number         in number
 ,p_override_name                 in varchar2
 ,p_override_type                 in varchar2
 ,p_parent_entry_value_id         in number
 ,p_usage_flag                    in varchar2
 );

--
end HR_CAL_ENTRY_VALUE_BK2;

 

/
