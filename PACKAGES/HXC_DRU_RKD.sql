--------------------------------------------------------
--  DDL for Package HXC_DRU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_DRU_RKD" AUTHID CURRENT_USER as
/* $Header: hxcdrurhi.pkh 120.0 2005/05/29 05:29:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_data_app_rule_usage_id       in number
  ,p_approval_style_id_o          in number
  ,p_time_entry_rule_id_o         in number
  ,p_time_recipient_id_o          in number
  ,p_object_version_number_o      in number
  );
--
end hxc_dru_rkd;

 

/
