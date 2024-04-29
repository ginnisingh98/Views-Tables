--------------------------------------------------------
--  DDL for Package HR_ITF_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ITF_RKU" AUTHID CURRENT_USER as
/* $Header: hritfrhi.pkh 120.0 2005/05/31 00:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_user_interface_id            in number
  ,p_user_interface_key           in varchar2
  ,p_type                         in varchar2
  ,p_form_name                    in varchar2
  ,p_page_region_code             in varchar2
  ,p_region_code                  in varchar2
  ,p_object_version_number        in number
  ,p_user_interface_key_o         in varchar2
  ,p_type_o                       in varchar2
  ,p_form_name_o                  in varchar2
  ,p_page_region_code_o           in varchar2
  ,p_region_code_o                in varchar2
  ,p_object_version_number_o      in number
  );
--
end hr_itf_rku;

 

/
