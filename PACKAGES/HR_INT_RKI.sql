--------------------------------------------------------
--  DDL for Package HR_INT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_INT_RKI" AUTHID CURRENT_USER as
/* $Header: hrintrhi.pkh 120.0 2005/05/31 00:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_integration_id               in number
  ,p_integration_key              in varchar2
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
  ,p_synched                      in varchar2
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
  );
end hr_int_rki;

 

/
