--------------------------------------------------------
--  DDL for Package HXC_RETRIEVAL_RULE_GRP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RETRIEVAL_RULE_GRP_API" AUTHID CURRENT_USER as
/* $Header: hxcrrgapi.pkh 120.0 2005/05/29 05:50:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_retrieval_rule_grp >---------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API creates a retreival rule group with a given name
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
--   p_retrieval_rule_grp_id        No   number   Primary Key for retreival rule group
--   p_object_version_number        No   number   Object Version Number
--   p_name                         Yes  varchar2 Name for the retrieval_rule_grp
--
-- Post Success:
--
-- when the retrieval_rule_grp has been created successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_retrieval_rule_grp_id        Number   Primary Key for the new rule
--   p_object_version_number        Number   Object version number for the
--                                           new rule
--
-- Post Failure:
--
-- The retrieval_rule_grp will not be inserted and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure create_retrieval_rule_grp
  (p_validate                       in  boolean   default false
  ,p_retrieval_rule_grp_id          in  out nocopy number
  ,p_object_version_number          in  out nocopy number
  ,p_name                           in     varchar2
  );
    --
-- ----------------------------------------------------------------------------
-- |----------------------<update_retrieval_rule_grp>-------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API updates an existing Retrieval_Rule_Grp with a given name
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
--   p_retrieval_rule_grp_id        Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--   p_name                         Yes  varchar2 Name for the retrieval_rule_grp
--
-- Post Success:
--
-- when the retrieval_rule_grp has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated rule
--
-- Post Failure:
--
-- The retrieval_rule_grp will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure update_retrieval_rule_grp
  (p_validate                       in  boolean   default false
  ,p_retrieval_rule_grp_id          in  number
  ,p_object_version_number          in  out nocopy number
  ,p_name                           in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------< delete_retrieval_rule_grp >--------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API deletes an existing Retrieval_Rule_Grp
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
--                                                then the retrieval_rule_grp
--                                                is deleted. Default is FALSE.
--   p_retrieval_rule_grp_id        Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the retrieval_rule_grp has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The retrieval_rule_grp will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure delete_retrieval_rule_grp
  (p_validate                       in  boolean  default false
  ,p_retrieval_rule_grp_id          in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_name >---------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure insures a valid retreival rule group name
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   name
--   entity_group_id
--
-- Post Success:
--   Processing continues if the name business rules have not been violated
--
-- Post Failure:
--   An application error is raised if the name is not valid
--
-- ----------------------------------------------------------------------------
Procedure chk_name
  (
   p_name            in hxc_entity_groups.name%TYPE
  ,p_entity_group_id in hxc_entity_groups.entity_group_id%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_delete >-------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure carries out delete time referential integrity checks
--   to ensure that a retreival rule group is not being referenced in a
--   in an approval hierarchy.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   entity_group_id
--
-- Post Success:
--   Processing continues if the name is not being referenced
--
-- Post Failure:
--   An application error is raised if the rule is being used.
--
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (
   p_entity_group_id in hxc_entity_groups.entity_group_id%TYPE
  );
--
--
END hxc_retrieval_rule_grp_api;

 

/
