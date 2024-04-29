--------------------------------------------------------
--  DDL for Package HXC_ULA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ULA_RKD" AUTHID CURRENT_USER as
/* $Header: hxcularhi.pkh 120.0 2005/05/29 06:03:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_layout_id                    in number
  ,p_layout_name_o                in varchar2
  ,p_application_id_o             in number
  ,p_layout_type_o                in varchar2
  ,p_modifier_level_o             in varchar2
  ,p_modifier_value_o             in varchar2
  ,p_top_level_region_code_o      in varchar2
  ,p_object_version_number_o      in number
  );
--
end hxc_ula_rkd;

 

/
