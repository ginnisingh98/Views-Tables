--------------------------------------------------------
--  DDL for Package HXC_HRR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HRR_RKI" AUTHID CURRENT_USER as
/* $Header: hxchrrrhi.pkh 120.0 2005/05/29 05:39:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_resource_rule_id             in number
  ,p_name                         in varchar2
  ,p_business_group_id		  in number
  ,p_legislation_code		  in varchar2
  ,p_eligibility_criteria_type    in varchar2
  ,p_eligibility_criteria_id      in varchar2
  ,p_pref_hierarchy_id            in number
  ,p_rule_evaluation_order        in number
  ,p_resource_type                in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_object_version_number        in number
  );
end hxc_hrr_rki;

 

/
