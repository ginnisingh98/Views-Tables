--------------------------------------------------------
--  DDL for Package HXC_FLD_MAPPING_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_FLD_MAPPING_BK_3" AUTHID CURRENT_USER as
/* $Header: hxcmapapi.pkh 120.0 2005/05/29 05:45:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_fld_mapping_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_fld_mapping_b
  (p_mapping_id                     in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_fld_mapping_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_fld_mapping_a
  (p_mapping_id                     in  number
  ,p_object_version_number          in  number
  );
--
end hxc_fld_mapping_bk_3;

 

/
