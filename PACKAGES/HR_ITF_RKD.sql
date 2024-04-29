--------------------------------------------------------
--  DDL for Package HR_ITF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ITF_RKD" AUTHID CURRENT_USER as
/* $Header: hritfrhi.pkh 120.0 2005/05/31 00:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_user_interface_id            in number
  ,p_user_interface_key_o         in varchar2
  ,p_type_o                       in varchar2
  ,p_form_name_o                  in varchar2
  ,p_page_region_code_o           in varchar2
  ,p_region_code_o                in varchar2
  ,p_object_version_number_o      in number
  );
--
end hr_itf_rkd;

 

/
