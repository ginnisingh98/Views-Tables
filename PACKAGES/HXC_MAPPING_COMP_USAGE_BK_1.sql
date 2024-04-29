--------------------------------------------------------
--  DDL for Package HXC_MAPPING_COMP_USAGE_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_MAPPING_COMP_USAGE_BK_1" AUTHID CURRENT_USER as
/* $Header: hxcmcuapi.pkh 120.0.12010000.1 2008/07/28 11:16:15 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_mapping_comp_usage_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_mapping_comp_usage_b
  (p_mapping_comp_usage_id          in     number
  ,p_object_version_number          in     number
  ,p_mapping_id                     in     number
  ,p_mapping_component_id           in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_mapping_comp_usage_a >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_mapping_comp_usage_a
  (p_mapping_comp_usage_id          in     number
  ,p_object_version_number          in     number
  ,p_mapping_id                     in     number
  ,p_mapping_component_id           in     number
  );
--
--
end hxc_mapping_comp_usage_bk_1;

/
