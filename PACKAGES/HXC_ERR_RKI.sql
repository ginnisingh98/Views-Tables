--------------------------------------------------------
--  DDL for Package HXC_ERR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ERR_RKI" AUTHID CURRENT_USER as
/* $Header: hxcerrrhi.pkh 120.0.12010000.2 2008/08/05 12:01:57 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_error_id                     in number
  ,p_transaction_detail_id        in number
  ,p_time_building_block_id       in number
  ,p_time_building_block_ovn      in number
  ,p_time_attribute_id            in number
  ,p_time_attribute_ovn           in number
  ,p_message_name                 in varchar2
  ,p_message_level                in varchar2
  ,p_message_field                in varchar2
  ,p_message_tokens               in varchar2
  ,p_application_short_name       in varchar2
  ,p_object_version_number        in number
  );
end hxc_err_rki;

/
