--------------------------------------------------------
--  DDL for Package HXC_TK_GROUP_QUERY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TK_GROUP_QUERY_API" AUTHID CURRENT_USER as
/* $Header: hxctkgqapi.pkh 120.0 2005/05/29 06:11:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_tk_group_query >---------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API creates a timekeeper group query with a given name
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
--                                                then a new tk group query
--                                                is created. Default is FALSE.
--   p_tk_group_query_id            No   number   Primary Key for timekeeper group query group query
--   p_tk_group_id                  Yes  number   Foreign Key for timekeeper group query group
--   p_object_version_number        No   number   Object Version Number
--   p_group_query_name             Yes  varchar2 tk group Name for the tk_group_query
--   p_include_exclude              Yes  varchar2 Include or Exclude flag
--   p_system_user                  Yes  varchar2 System or User flag
--
-- Post Success:
--
-- when the tk_group_query has been created successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_tk_group_query_id            Number   Primary Key for the new tk group query
--   p_object_version_number        Number   Object version number for the
--                                           new tk group
--
-- Post Failure:
--
-- The timekeeper group query will not be inserted and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure create_tk_group_query
  (p_validate                       in  boolean   default false
  ,p_tk_group_query_id              in  out nocopy number
  ,p_tk_group_id                    in  number
  ,p_object_version_number          in  out nocopy number
  ,p_group_query_name                  in     varchar2
  ,p_include_exclude                in  varchar2
  ,p_system_user                    in  varchar2
  );
    --
-- ----------------------------------------------------------------------------
-- |-------------------------<update_tk_group_query>------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API updates an existing Tk_Group_Query with a given name
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
--                                                then the tk group query
--                                                is updated. Default is FALSE.
--   p_tk_group_id                  Yes  number   Primary Key for entity
--   p_tk_group_query_id            Yes  number   Foreign Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--   p_group_query_name             Yes  varchar2 tk group Name for the timekeeper group query
--   p_include_exclude              Yes  varchar2 Include or Exclude flag
--   p_system_user                  Yes  varchar2 System or User flag
--
-- Post Success:
--
-- when the timekeeper group query has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated tk group query
--
-- Post Failure:
--
-- The tk_group_query will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure update_tk_group_query
  (p_validate                       in  boolean   default false
  ,p_tk_group_id                    in  number
  ,p_tk_group_query_id              in  number
  ,p_object_version_number          in  out nocopy number
  ,p_group_query_name                  in     varchar2
  ,p_include_exclude                in  varchar2
  ,p_system_user                    in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_tk_group_query >-------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--
-- This API deletes an existing Tk_Group_Query
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
--                                                then the tk_group_query
--                                                is deleted. Default is FALSE.
--   p_tk_group_query_id            Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the timekeeper group query has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The tk_group_query will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
--
procedure delete_tk_group_query
  (p_validate                       in  boolean  default false
  ,p_tk_group_query_id              in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_name >---------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure insures a valid timekeeper group query name
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   group_query_name
--   tk_group_query_id
--
-- Post Success:
--   Processing continues if the name business tk group querys have not been violated
--
-- Post Failure:
--   An application error is raised if the name is not valid
--
-- ----------------------------------------------------------------------------
Procedure chk_name
  (
   p_group_query_name     in varchar2
  ,p_tk_group_id       in number
  ,p_tk_group_query_id in number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_tk_group_id >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure insures a valid timekeeper group id
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   tk_group_id
--
-- Post Success:
--   Processing continues if the name business tk group querys have not been violated
--
-- Post Failure:
--   An application error is raised if the name is not valid
--
-- ----------------------------------------------------------------------------
Procedure chk_tk_group_id
  (
   p_tk_group_id in number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_delete >-------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure carries out delete time referential integrity checks
--   Currently there are none but include this now for minimum impact
--   in the future.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   tk_group_id
--
-- Post Success:
--   Processing continues if the name is not being referenced
--
-- Post Failure:
--   An application error is raised if the tk group query is being used.
--
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (
   p_tk_group_query_id in number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< maintain_tk_group_query >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedures maintains the hxc tk group query entity.
--   It is called whenever a tk group query criteria row is created.
--
-- Pre Conditions:
--   None
--
-- In Arguments:
--   p_tk_group_query_id
--   p_tk_group_id
--
-- Post Success:
--   Processing continues if the grpu query is created or retrieved successfully.
--
-- Post Failure:
--   An application error is raised if the tk group query is being used.
--
-- ----------------------------------------------------------------------------
Procedure maintain_tk_group_query
  (
   p_tk_group_query_id              in  out nocopy number
  ,p_tk_group_id                    in  number
  );

--
END hxc_tk_group_query_api;

 

/
