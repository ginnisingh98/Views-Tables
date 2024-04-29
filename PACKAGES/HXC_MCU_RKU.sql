--------------------------------------------------------
--  DDL for Package HXC_MCU_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_MCU_RKU" AUTHID CURRENT_USER as
/* $Header: hxcmcurhi.pkh 120.0 2005/05/29 05:47:17 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_mapping_comp_usage_id        in number
  ,p_object_version_number        in number
  ,p_mapping_component_id         in number
  ,p_mapping_id                   in number
  ,p_object_version_number_o      in number
  ,p_mapping_component_id_o       in number
  ,p_mapping_id_o                 in number
  );
--
end hxc_mcu_rku;

 

/
