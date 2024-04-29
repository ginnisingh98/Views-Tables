--------------------------------------------------------
--  DDL for Package HXC_TCC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TCC_RKD" AUTHID CURRENT_USER as
/* $Header: hxctccrhi.pkh 120.0 2005/05/29 05:56:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
   p_time_category_comp_id        in number
  ,p_time_category_id_o           in number
  ,p_ref_time_category_id_o       in number
  ,p_component_type_id_o          in number
  ,p_flex_value_set_id_o          in number
  ,p_value_id_o                   in varchar2
  ,p_is_null_o                      in varchar2
  ,p_equal_to_o                     in varchar2
  ,p_type_o                         in varchar2
  ,p_object_version_number_o      in number
  );
--
end hxc_tcc_rkd;

 

/
