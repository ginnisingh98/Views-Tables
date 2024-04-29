--------------------------------------------------------
--  DDL for Package HXC_MCU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_MCU_RKI" AUTHID CURRENT_USER as
/* $Header: hxcmcurhi.pkh 120.0 2005/05/29 05:47:17 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_mapping_comp_usage_id        in number
  ,p_object_version_number        in number
  ,p_mapping_component_id         in number
  ,p_mapping_id                   in number
  );
end hxc_mcu_rki;

 

/
