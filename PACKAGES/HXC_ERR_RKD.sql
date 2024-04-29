--------------------------------------------------------
--  DDL for Package HXC_ERR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ERR_RKD" AUTHID CURRENT_USER as
/* $Header: hxcerrrhi.pkh 120.0.12010000.2 2008/08/05 12:01:57 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_error_id                     in number
  ,p_transaction_detail_id_o      in number
  ,p_time_building_block_id_o     in number
  ,p_time_building_block_ovn_o    in number
  ,p_time_attribute_id_o          in number
  ,p_time_attribute_ovn_o         in number
  ,p_message_name_o               in varchar2
  ,p_message_level_o              in varchar2
  ,p_message_field_o              in varchar2
  ,p_message_tokens_o             in varchar2
  ,p_application_short_name_o     in varchar2
  ,p_object_version_number_o      in number
  );
--
end hxc_err_rkd;

/
