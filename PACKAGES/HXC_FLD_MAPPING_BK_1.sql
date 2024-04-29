--------------------------------------------------------
--  DDL for Package HXC_FLD_MAPPING_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_FLD_MAPPING_BK_1" AUTHID CURRENT_USER as
/* $Header: hxcmapapi.pkh 120.0 2005/05/29 05:45:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_fld_mapping_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_fld_mapping_b
  (p_mapping_id                     in     number
  ,p_object_version_number          in     number
  ,p_name                           in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_fld_mapping_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_fld_mapping_a
  (p_mapping_id                     in     number
  ,p_object_version_number          in     number
  ,p_name                           in     varchar2
  );
--
end hxc_fld_mapping_bk_1;

 

/
