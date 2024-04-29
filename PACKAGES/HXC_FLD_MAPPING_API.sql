--------------------------------------------------------
--  DDL for Package HXC_FLD_MAPPING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_FLD_MAPPING_API" AUTHID CURRENT_USER as
/* $Header: hxcmapapi.pkh 120.0 2005/05/29 05:45:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_fld_mapping >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API creates a field mapping with a given name
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then a new data_approval_rule
--                                                is created. Default is FALSE.
--   p_mapping_id                   No   number   Primary Key for entity
--   p_object_version_number        No   number   Object Version Number
--   p_name                         Yes  varchar2 Name for the mapping
--
-- Post Success:
--
-- when the mapping has been created successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_mapping_id                   Number   Primary Key for the new rule
--   p_object_version_number        Number   Object version number for the
--                                           new rule
--
-- Post Failure:
--
-- The mapping will not be inserted and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_fld_mapping
  (p_validate                       in  boolean   default false
  ,p_mapping_id                     in  out nocopy number
  ,p_object_version_number          in  out nocopy number
  ,p_name                           in     varchar2
  );
    --
-- ----------------------------------------------------------------------------
-- |--------------------------------<update_fld_mapping>----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API updates an existing Mapping with a given name, approval
-- rule usage covering a particular date range.
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then the data_approval_rule
--                                                is updated. Default is FALSE.
--   p_mapping_id                   Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--   p_name                         Yes  varchar2 Name for the mapping
--
-- Post Success:
--
-- when the mapping has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated rule
--
-- Post Failure:
--
-- The mapping will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_fld_mapping
  (p_validate                       in  boolean   default false
  ,p_mapping_id                     in  number
  ,p_object_version_number          in  out nocopy number
  ,p_name                           in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_fld_mapping >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API deletes an existing Mapping
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then the mapping
--                                                is deleted. Default is FALSE.
--   p_mapping_id                   Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the mapping has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The mapping will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_fld_mapping
  (p_validate                       in  boolean  default false
  ,p_mapping_id                     in  number
  ,p_object_version_number          in  number
  );
--
--
END hxc_fld_mapping_api;

 

/
