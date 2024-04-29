--------------------------------------------------------
--  DDL for Package HXC_MAPPING_COMPONENT_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_MAPPING_COMPONENT_BK_3" AUTHID CURRENT_USER as
/* $Header: hxcmpcapi.pkh 120.0 2005/05/29 05:47:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_mapping_component_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_mapping_component_b
  (p_mapping_component_id          in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_mapping_component_a >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_mapping_component_a
  (p_mapping_component_id          in  number
  ,p_object_version_number          in  number
  );
--
end hxc_mapping_component_bk_3;

 

/
