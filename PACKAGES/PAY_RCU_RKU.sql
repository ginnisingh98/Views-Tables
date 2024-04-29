--------------------------------------------------------
--  DDL for Package PAY_RCU_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RCU_RKU" AUTHID CURRENT_USER as
/* $Header: pyrcurhi.pkh 120.0 2005/05/29 08:17:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_retro_component_usage_id     in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_retro_component_id           in number
  ,p_creator_id                   in number
  ,p_creator_type                 in varchar2
  ,p_default_component            in varchar2
  ,p_reprocess_type               in varchar2
  ,p_object_version_number        in number
  ,p_replace_run_flag             in varchar2
  ,p_use_override_dates           in varchar2
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_retro_component_id_o         in number
  ,p_creator_id_o                 in number
  ,p_creator_type_o               in varchar2
  ,p_default_component_o          in varchar2
  ,p_reprocess_type_o             in varchar2
  ,p_object_version_number_o      in number
  ,p_replace_run_flag_o           in varchar2
  ,p_use_override_dates_o         in varchar2
  );
--
end pay_rcu_rku;

 

/
