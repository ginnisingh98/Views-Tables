--------------------------------------------------------
--  DDL for Package HXC_HEG_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HEG_RKU" AUTHID CURRENT_USER as
/* $Header: hxchegrhi.pkh 120.0.12010000.1 2008/07/28 11:11:09 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_entity_group_id              in number
  ,p_name                         in varchar2
  ,p_entity_type		  in varchar2
  ,p_object_version_number        in number
  ,p_description                  in varchar2
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_name_o                       in varchar2
  ,p_entity_type_o                in varchar2
  ,p_object_version_number_o      in number
  ,p_description_o                in varchar2
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  );
--
end hxc_heg_rku;

/
