--------------------------------------------------------
--  DDL for Package HXC_ULD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ULD_RKU" AUTHID CURRENT_USER as
/* $Header: hxculdrhi.pkh 120.0 2005/05/29 06:04:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_layout_comp_definition_id    in number
  ,p_component_type               in varchar2
  ,p_component_class              in varchar2
  ,p_render_type                  in varchar2
  ,p_object_version_number        in number
  ,p_component_type_o             in varchar2
  ,p_component_class_o            in varchar2
  ,p_render_type_o                in varchar2
  ,p_object_version_number_o      in number
  );
--
end hxc_uld_rku;

 

/
