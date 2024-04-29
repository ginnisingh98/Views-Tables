--------------------------------------------------------
--  DDL for Package HXC_ATC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ATC_RKU" AUTHID CURRENT_USER as
/* $Header: hxcatcrhi.pkh 120.0 2005/05/29 05:27:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_alias_type_component_id      in number
  ,p_component_name               in varchar2
  ,p_component_type               in varchar2
  ,p_mapping_component_id         in number
  ,p_alias_type_id                in number
  ,p_object_version_number        in number
  ,p_component_name_o             in varchar2
  ,p_component_type_o             in varchar2
  ,p_mapping_component_id_o       in number
  ,p_alias_type_id_o              in number
  ,p_object_version_number_o      in number
  );
--
end hxc_atc_rku;

 

/
