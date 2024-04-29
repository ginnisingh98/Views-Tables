--------------------------------------------------------
--  DDL for Package PAY_RCU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RCU_RKD" AUTHID CURRENT_USER as
/* $Header: pyrcurhi.pkh 120.0 2005/05/29 08:17:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_retro_component_usage_id     in number
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
end pay_rcu_rkd;

 

/
