--------------------------------------------------------
--  DDL for Package HXC_MAPPING_COMP_USAGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_MAPPING_COMP_USAGE_API" AUTHID CURRENT_USER as
/* $Header: hxcmcuapi.pkh 120.0.12010000.1 2008/07/28 11:16:15 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_mapping_comp_usage>----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API creates a Mapping Component Usage for a given mapping
-- and mapping component.
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
--                                                then a new mapping_comp_usage
--                                                is created. Default is FALSE.
--   p_mapping_comp_usage_id        No   number   Primary Key for entity
--   p_object_version_number        No   number   Object Version Number
--   p_mapping_id                   Yes  number   Field Mapping Id
--   p_mapping_component_id         Yes  number   Field Mapping Component Id
--
-- Post Success:
--
-- when the mapping_comp_usage has been created successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_mapping_comp_usage_id        Number   Primary Key for the new rule
--   p_object_version_number        Number   Object version number for the
--                                           new rule
--
-- Post Failure:
--
-- The mapping component usage will not be inserted and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_mapping_comp_usage
  (p_validate                       in  boolean   default false
  ,p_mapping_comp_usage_id          in  out nocopy number
  ,p_object_version_number          in  out nocopy number
  ,p_mapping_id                     in     number
  ,p_mapping_component_id           in     number
  );
    --
/*
-- ----------------------------------------------------------------------------
-- |------------------------<update_mapping_comp_usage>-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API updates an existing Mapping Component Usage with a given name, approval
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
--                                                then the mapping_comp_usage
--                                                is updated. Default is FALSE.
--   p_mapping_comp_usage_id        Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--   p_mapping_id                   No   number   Field Mapping ID
--   p_mapping_component_id         No   number   Field Mapping ID
--
-- Post Success:
--
-- when the mapping_comp_usage has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated rule
--
-- Post Failure:
--
-- The mapping component usage will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_mapping_comp_usage
  (p_validate                       in  boolean   default false
  ,p_mapping_comp_usage_id          in  number
  ,p_object_version_number          in  out nocopy number
  ,p_mapping_id                     in     number   default null
  ,p_mapping_component_id           in     number   default null
  );
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_mapping_comp_usage >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API deletes an existing Mapping Component Usage
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
--                                                then the mapping_comp_usage
--                                                is deleted. Default is FALSE.
--   p_mapping_comp_usage_id        Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the mapping_comp_usage has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The mapping component usage will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_mapping_comp_usage
  (p_validate                       in  boolean  default false
  ,p_mapping_comp_usage_id          in  number
  ,p_object_version_number          in  number
  );
--
--
END hxc_mapping_comp_usage_api;

/
