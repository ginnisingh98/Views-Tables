--------------------------------------------------------
--  DDL for Package HXC_MAPPING_COMPONENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_MAPPING_COMPONENT_API" AUTHID CURRENT_USER as
/* $Header: hxcmpcapi.pkh 120.0 2005/05/29 05:47:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_mapping_component>-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API creates a Mapping Component. The user is ablel to specify a name
-- for the component and the application field name the component relates
-- to.
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
--                                                then a new mapping_component
--                                                is created. Default is FALSE.
--   p_mapping_component_id         No   number   Primary Key for entity
--   p_object_version_number        No   number   Object Version Number
--   p_name                         Yes  varchar2 Name for the mapping component
--   p_field_name                   Yes  varchar2 Field Name for the mapping component
--   p_bld_blk_info_type_id         Yes  number   bld_blk_info_type_id from
--                                                HXC_BLD_BLK_INFO_TYPE_USAGES
--   p_segment                      Yes  varchar2 segment from the table
--                                                FND_DESCR_FLEX_COLUMN_USAGES
--
-- Post Success:
--
-- when the mapping_component has been created successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_mapping_component_id        Number   Primary Key for the new rule
--   p_object_version_number        Number   Object version number for the
--                                           new rule
--
-- Post Failure:
--
-- The mapping component will not be inserted and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_mapping_component
  (p_validate                       in  boolean   default false
  ,p_mapping_component_id           in  out nocopy number
  ,p_object_version_number          in  out nocopy number
  ,p_name                           in     varchar2
  ,p_field_name                     in     varchar2
  ,p_bld_blk_info_type_id           in     number
  ,p_segment                        in     varchar2
  );
    --
-- ----------------------------------------------------------------------------
-- |------------------------<update_mapping_component>------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API updates an existing Mapping Component with a given name, approval
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
--                                                then the mapping_component
--                                                is updated. Default is FALSE.
--   p_mapping_component_id         Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--   p_name                         Yes  varchar2 Name for the mapping component
--   p_field_name                   Yes  varchar2 Field Name for the mapping component
--   p_bld_blk_info_type_id         Yes  number   building block info type id from
--                                                HXC_BLD_BLK_INFO_TYPE_USAGES
--   p_segment                      Yes  varchar2 segment from the table
--                                                FND_DESCR_FLEX_COLUMN_USAGES
-- Post Success:
--
-- when the mapping_component has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated rule
--
-- Post Failure:
--
-- The mapping component will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_mapping_component
  (p_validate                       in  boolean   default false
  ,p_mapping_component_id           in  number
  ,p_object_version_number          in  out nocopy number
  ,p_name                           in     varchar2
  ,p_field_name                     in     varchar2
  ,p_bld_blk_info_type_id           in     number
  ,p_segment                        in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_mapping_component >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API deletes an existing Mapping Component
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
--                                                then the mapping_component
--                                                is deleted. Default is FALSE.
--   p_mapping_component_id        Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the mapping_component has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The mapping component will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_mapping_component
  (p_validate                       in  boolean  default false
  ,p_mapping_component_id          in  number
  ,p_object_version_number          in  number
  );
--
--
END hxc_mapping_component_api;

 

/
