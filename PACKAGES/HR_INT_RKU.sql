--------------------------------------------------------
--  DDL for Package HR_INT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_INT_RKU" AUTHID CURRENT_USER as
/* $Header: hrintrhi.pkh 120.0 2005/05/31 00:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_integration_id               in number
  ,p_synched                      in varchar2
  ,p_party_type                   in varchar2
  ,p_party_name                   in varchar2
  ,p_party_site_name              in varchar2
  ,p_transaction_type             in varchar2
  ,p_transaction_subtype          in varchar2
  ,p_standard_code                in varchar2
  ,p_ext_trans_type               in varchar2
  ,p_ext_trans_subtype            in varchar2
  ,p_trans_direction              in varchar2
  ,p_url                          in varchar2
  ,p_ext_application_id           in number
  ,p_application_name             in varchar2
  ,p_application_type             in varchar2
  ,p_application_url              in varchar2
  ,p_logout_url                   in varchar2
  ,p_user_field                   in varchar2
  ,p_password_field               in varchar2
  ,p_authentication_needed        in varchar2
  ,p_field_name1                  in varchar2
  ,p_field_value1                 in varchar2
  ,p_field_name2                  in varchar2
  ,p_field_value2                 in varchar2
  ,p_field_name3                  in varchar2
  ,p_field_value3                 in varchar2
  ,p_field_name4                  in varchar2
  ,p_field_value4                 in varchar2
  ,p_field_name5                  in varchar2
  ,p_field_value5                 in varchar2
  ,p_field_name6                  in varchar2
  ,p_field_value6                 in varchar2
  ,p_field_name7                  in varchar2
  ,p_field_value7                 in varchar2
  ,p_field_name8                  in varchar2
  ,p_field_value8                 in varchar2
  ,p_field_name9                  in varchar2
  ,p_field_value9                 in varchar2
  ,p_object_version_number        in number
  ,p_integration_key_o            in varchar2
  ,p_party_type_o                 in varchar2
  ,p_party_name_o                 in varchar2
  ,p_party_site_name_o            in varchar2
  ,p_transaction_type_o           in varchar2
  ,p_transaction_subtype_o        in varchar2
  ,p_standard_code_o              in varchar2
  ,p_ext_trans_type_o             in varchar2
  ,p_ext_trans_subtype_o          in varchar2
  ,p_trans_direction_o            in varchar2
  ,p_url_o                        in varchar2
  ,p_synched_o                    in varchar2
  ,p_ext_application_id_o         in number
  ,p_application_name_o           in varchar2
  ,p_application_type_o           in varchar2
  ,p_application_url_o            in varchar2
  ,p_logout_url_o                 in varchar2
  ,p_user_field_o                 in varchar2
  ,p_password_field_o             in varchar2
  ,p_authentication_needed_o      in varchar2
  ,p_field_name1_o                in varchar2
  ,p_field_value1_o               in varchar2
  ,p_field_name2_o                in varchar2
  ,p_field_value2_o               in varchar2
  ,p_field_name3_o                in varchar2
  ,p_field_value3_o               in varchar2
  ,p_field_name4_o                in varchar2
  ,p_field_value4_o               in varchar2
  ,p_field_name5_o                in varchar2
  ,p_field_value5_o               in varchar2
  ,p_field_name6_o                in varchar2
  ,p_field_value6_o               in varchar2
  ,p_field_name7_o                in varchar2
  ,p_field_value7_o               in varchar2
  ,p_field_name8_o                in varchar2
  ,p_field_value8_o               in varchar2
  ,p_field_name9_o                in varchar2
  ,p_field_value9_o               in varchar2
  ,p_object_version_number_o      in number
  );
--
end hr_int_rku;

 

/
