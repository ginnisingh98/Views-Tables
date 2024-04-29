--------------------------------------------------------
--  DDL for Package HXC_ULC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ULC_RKD" AUTHID CURRENT_USER as
/* $Header: hxculcrhi.pkh 120.0 2005/05/29 06:04:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_layout_component_id          in number
  ,p_layout_id_o                  in number
  ,p_parent_component_id_o        in number
  ,p_component_name_o             in varchar2
  ,p_component_value_o            in varchar2
  ,p_sequence_o                   in number
  ,p_name_value_string_o          in varchar2
  ,p_region_code_o                in varchar2
  ,p_region_code_app_id_o         in number
  ,p_attribute_code_o             in varchar2
  ,p_attribute_code_app_id_o      in number
  ,p_object_version_number_o      in number
  ,p_layout_comp_definition_id_o  in number
  ,p_component_alias_o            in varchar2
  ,p_parent_bean_o                in varchar2
  ,p_attribute1_o                 in varchar2
  ,p_attribute2_o                 in varchar2
  ,p_attribute3_o                 in varchar2
  ,p_attribute4_o                 in varchar2
  ,p_attribute5_o                 in varchar2
  );
--
end hxc_ulc_rkd;

 

/
