--------------------------------------------------------
--  DDL for Package HXC_ULA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ULA_RKI" AUTHID CURRENT_USER as
/* $Header: hxcularhi.pkh 120.0 2005/05/29 06:03:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_layout_id                    in number
  ,p_layout_name                  in varchar2
  ,p_application_id               in number
  ,p_layout_type                  in varchar2
  ,p_modifier_level               in varchar2
  ,p_modifier_value               in varchar2
  ,p_top_level_region_code        in varchar2
  ,p_object_version_number        in number
  );
end hxc_ula_rki;

 

/
