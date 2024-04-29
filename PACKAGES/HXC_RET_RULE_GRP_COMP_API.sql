--------------------------------------------------------
--  DDL for Package HXC_RET_RULE_GRP_COMP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RET_RULE_GRP_COMP_API" AUTHID CURRENT_USER as
/* $Header: hxcrrcapi.pkh 120.0 2005/05/29 05:50:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------< create_ret_rule_grp_comp >-------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API creates a Retrieval Rule Group Comp for a given entity
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
--   p_ret_rule_grp_comp_id   No   number   Primary Key for entity
--   p_object_version_number        No   number   Object Version Number
--   p_retrieval_rule_id            Yes  number   Retrieval Rule Id
--   p_retrieval_rule_grp_id        Yes  number   Retrieval Rule Group Id
--
-- Post Success:
--
-- when the entity_group_comp has been created successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_ret_rule_grp_comp_id Number   Primary Key for the retrieval rule grp
--   p_object_version_number      Number   Object version number for the
--                                         new retrieval rule group comp
--
-- Post Failure:
--
-- The Retrieval Rule Group Comp will not be inserted and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure create_ret_rule_grp_comp
  (p_validate                       in  boolean   default false
  ,p_effective_date                 in  date
  ,p_ret_rule_grp_comp_id     in  out nocopy number
  ,p_object_version_number          in  out nocopy number
  ,p_retrieval_rule_id              in     number
  ,p_retrieval_rule_grp_id          in     number
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
  ,p_called_from_form               in     varchar2 default 'Y' -- NOTE: default to Y because no DF for Retrieval Rule Grps
  );
    --
-- ----------------------------------------------------------------------------
-- |--------------------<update_ret_rule_grp_comp >---------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API updates an existing Retrieval Rule Group Comp with a given name and DDF
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
--   p_ret_rule_grp_comp_id Yes  number   Primary Key for retrieval rule grp
--   p_object_version_number        Yes  number   Object Version Number
--   p_retrieval_rule_id           No   number   Retrieval Rule ID
--   p_retrieval_rule_grp_id     No   number   Retrieval Rule Group ID
--
-- Post Success:
--
-- when the ret_rule_grp_comp has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated retrieval rule group comp
--
-- Post Failure:
--
-- The Retrieval Rule Group Comp will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure update_ret_rule_grp_comp
  (p_validate                       in  boolean   default false
  ,p_effective_date                 in  date
  ,p_ret_rule_grp_comp_id  in  number
  ,p_object_version_number          in  out nocopy number
  ,p_retrieval_rule_id             in     number   default null
  ,p_retrieval_rule_grp_id       in     number   default null
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
  ,p_called_from_form               in     varchar2 default 'Y' -- NOTE: default to Y because no DF for Retrieval Rule Grps
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_ret_rule_grp_comp >---------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API deletes an existing Retrieval Rule Group Comp
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
--   p_ret_rule_grp_comp_id Yes  number   Primary Key for retrieval rule grp
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the entity_group_comp has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The Retrieval Rule Group Comp will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure delete_ret_rule_grp_comp
  (p_validate                       in  boolean  default false
  ,p_ret_rule_grp_comp_id  in  number
  ,p_retrieval_rule_grp_id       in  number
  ,p_object_version_number          in  number
  );
--
Procedure chk_rr_unique
  (
   p_ret_rule_grp_comp_id    in hxc_entity_group_comps.entity_group_comp_id%TYPE
,  p_retrieval_rule_grp_id         in hxc_entity_group_comps.entity_group_id%TYPE
,  p_retrieval_rule_id               in hxc_entity_group_comps.entity_id%TYPE );
--
END hxc_ret_rule_grp_comp_api;

 

/
