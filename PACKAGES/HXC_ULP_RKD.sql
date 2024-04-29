--------------------------------------------------------
--  DDL for Package HXC_ULP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ULP_RKD" AUTHID CURRENT_USER as
/* $Header: hxculprhi.pkh 120.0 2005/05/29 06:04:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_layout_comp_prompt_id        in number
  ,p_layout_component_id_o        in number
  ,p_prompt_alias_o               in varchar2
  ,p_prompt_type_o                in varchar2
  ,p_region_code_o                in varchar2
  ,p_region_application_id_o      in number
  ,p_attribute_code_o             in varchar2
  ,p_attribute_application_id_o   in number
  ,p_object_version_number_o      in number
  );
--
end hxc_ulp_rkd;

 

/
