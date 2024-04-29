--------------------------------------------------------
--  DDL for Package HXC_ULD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ULD_RKD" AUTHID CURRENT_USER as
/* $Header: hxculdrhi.pkh 120.0 2005/05/29 06:04:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_layout_comp_definition_id    in number
  ,p_component_type_o             in varchar2
  ,p_component_class_o            in varchar2
  ,p_render_type_o                in varchar2
  ,p_object_version_number_o      in number
  );
--
end hxc_uld_rkd;

 

/
