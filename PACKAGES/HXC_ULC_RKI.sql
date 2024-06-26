--------------------------------------------------------
--  DDL for Package HXC_ULC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ULC_RKI" AUTHID CURRENT_USER as
/* $Header: hxculcrhi.pkh 120.0 2005/05/29 06:04:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_layout_component_id          in number
  ,p_layout_id                    in number
  ,p_parent_component_id          in number
  ,p_component_name               in varchar2
  ,p_component_value              in varchar2
  ,p_sequence                     in number
  ,p_name_value_string            in varchar2
  ,p_region_code                  in varchar2
  ,p_region_code_app_id           in number
  ,p_attribute_code               in varchar2
  ,p_attribute_code_app_id        in number
  ,p_object_version_number        in number
  ,p_layout_comp_definition_id    in number
  ,p_component_alias              in varchar2
  ,p_parent_bean                  in varchar2
  ,p_attribute1                   in varchar2
  ,p_attribute2                   in varchar2
  ,p_attribute3                   in varchar2
  ,p_attribute4                   in varchar2
  ,p_attribute5                   in varchar2
  );
end hxc_ulc_rki;

 

/
