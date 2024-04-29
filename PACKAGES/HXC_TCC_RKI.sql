--------------------------------------------------------
--  DDL for Package HXC_TCC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TCC_RKI" AUTHID CURRENT_USER as
/* $Header: hxctccrhi.pkh 120.0 2005/05/29 05:56:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
   p_time_category_comp_id        in number
  ,p_time_category_id             in number
  ,p_ref_time_category_id         in number
  ,p_component_type_id            in number
  ,p_flex_value_set_id            in number
  ,p_value_id                     in varchar2
  ,p_is_null                        in varchar2
  ,p_equal_to                       in varchar2
  ,p_type                           in varchar2
  ,p_object_version_number        in number
  );
end hxc_tcc_rki;

 

/
