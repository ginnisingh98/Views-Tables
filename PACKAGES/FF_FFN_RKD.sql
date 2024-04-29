--------------------------------------------------------
--  DDL for Package FF_FFN_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_FFN_RKD" AUTHID CURRENT_USER as
/* $Header: ffffnrhi.pkh 120.0 2005/05/27 23:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_function_id                  in number
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_class_o                      in varchar2
  ,p_name_o                       in varchar2
  ,p_alias_name_o                 in varchar2
  ,p_data_type_o                  in varchar2
  ,p_definition_o                 in varchar2
  ,p_description_o                in varchar2
  ,p_object_version_number_o      in number
  );
--
end ff_ffn_rkd;

 

/
