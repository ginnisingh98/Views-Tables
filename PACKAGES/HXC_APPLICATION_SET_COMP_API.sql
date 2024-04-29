--------------------------------------------------------
--  DDL for Package HXC_APPLICATION_SET_COMP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APPLICATION_SET_COMP_API" AUTHID CURRENT_USER as
/* $Header: hxcascapi.pkh 120.0 2005/05/29 05:26:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------< create_application_set_comp >----------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API creates a Application Set Group Comp for a given entity
-- and entity group.
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
--                                                then a new entity_group_comp
--                                                is created. Default is FALSE.
--   p_application_set_comp_id No   number   Primary Key for entity
--   p_object_version_number        No   number   Object Version Number
--   p_time_recipient_id           Yes  number   Application Set Id
--   p_application_set_id     Yes  number   Application Set Group Id
--
-- Post Success:
--
-- when the entity_group_comp has been created successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_application_set_comp_id Number   Primary Key for the application set
--   p_object_version_number        Number   Object version number for the
--                                           new application set group comp
--
-- Post Failure:
--
-- The Application Set Group Comp will not be inserted and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure create_application_set_comp
  (p_validate                       in  boolean   default false
  ,p_effective_date                 in  date
  ,p_application_set_comp_id       in  out nocopy number
  ,p_object_version_number          in  out nocopy number
  ,p_time_recipient_id             in     number
  ,p_application_set_id       in     number
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_attribute21                    in     varchar2 default null
  ,p_attribute22                    in     varchar2 default null
  ,p_attribute23                    in     varchar2 default null
  ,p_attribute24                    in     varchar2 default null
  ,p_attribute25                    in     varchar2 default null
  ,p_attribute26                    in     varchar2 default null
  ,p_attribute27                    in     varchar2 default null
  ,p_attribute28                    in     varchar2 default null
  ,p_attribute29                    in     varchar2 default null
  ,p_attribute30                    in     varchar2 default null
  ,p_called_from_form               in     varchar2 default 'Y' -- NOTE: default to Y because no DF for Application Sets
  );
    --
-- ----------------------------------------------------------------------------
-- |--------------------<update_application_set_comp >-----------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API updates an existing Application Set Group Comp with a given name and DDF
-- context
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
--                                                then the entity_group_comp
--                                                is updated. Default is FALSE.
--   p_application_set_comp_id Yes  number   Primary Key for application set
--   p_object_version_number        Yes  number   Object Version Number
--   p_time_recipient_id           No   number   Application Set ID
--   p_application_set_id     No   number   Application Set Group ID
--
-- Post Success:
--
-- when the application_set_comp has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated application set group comp
--
-- Post Failure:
--
-- The Application Set Group Comp will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure update_application_set_comp
  (p_validate                       in  boolean   default false
  ,p_effective_date                 in  date
  ,p_application_set_comp_id  in  number
  ,p_object_version_number          in  out nocopy number
  ,p_time_recipient_id             in     number   default null
  ,p_application_set_id       in     number   default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_attribute21                    in     varchar2 default null
  ,p_attribute22                    in     varchar2 default null
  ,p_attribute23                    in     varchar2 default null
  ,p_attribute24                    in     varchar2 default null
  ,p_attribute25                    in     varchar2 default null
  ,p_attribute26                    in     varchar2 default null
  ,p_attribute27                    in     varchar2 default null
  ,p_attribute28                    in     varchar2 default null
  ,p_attribute29                    in     varchar2 default null
  ,p_attribute30                    in     varchar2 default null
  ,p_called_from_form               in     varchar2 default 'Y' -- NOTE: default to Y because no DF for Application Sets
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_application_set_comp >---------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API deletes an existing Application Set Group Comp
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
--                                                then the entity_group_comp
--                                                is deleted. Default is FALSE.
--   p_application_set_comp_id Yes  number   Primary Key for application set
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the entity_group_comp has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The Application Set Group Comp will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure delete_application_set_comp
  (p_validate                       in  boolean  default false
  ,p_application_set_comp_id  in  number
  ,p_application_set_id       in  number
  ,p_object_version_number          in  number
  );
--
Procedure chk_as_unique
  (
   p_application_set_comp_id    in hxc_entity_group_comps.entity_group_comp_id%TYPE
,  p_application_set_id         in hxc_entity_group_comps.entity_group_id%TYPE
,  p_time_recipient_id               in hxc_entity_group_comps.entity_id%TYPE );
--
-- added by 'ksethi' in ver: 115.6
Procedure chk_appl_as_unique
  (
    p_application_set_id         in hxc_entity_group_comps.entity_group_id%TYPE
    );
--
--
END hxc_application_set_comp_api;

 

/
