--------------------------------------------------------
--  DDL for Package HXC_DRU_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_DRU_RKU" AUTHID CURRENT_USER as
/* $Header: hxcdrurhi.pkh 120.0 2005/05/29 05:29:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_data_app_rule_usage_id       in number
  ,p_approval_style_id            in number
  ,p_time_entry_rule_id           in number
  ,p_time_recipient_id            in number
  ,p_object_version_number        in number
  ,p_approval_style_id_o          in number
  ,p_time_entry_rule_id_o         in number
  ,p_time_recipient_id_o          in number
  ,p_object_version_number_o      in number
  );
--
end hxc_dru_rku;

 

/
