--------------------------------------------------------
--  DDL for Package HXC_ULD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ULD_RKI" AUTHID CURRENT_USER as
/* $Header: hxculdrhi.pkh 120.0 2005/05/29 06:04:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_layout_comp_definition_id    in number
  ,p_component_type               in varchar2
  ,p_component_class              in varchar2
  ,p_render_type                  in varchar2
  ,p_object_version_number        in number
  );
end hxc_uld_rki;

 

/
