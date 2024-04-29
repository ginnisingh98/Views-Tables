--------------------------------------------------------
--  DDL for Package HXC_APPROVAL_PERIOD_SETS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APPROVAL_PERIOD_SETS_API" AUTHID CURRENT_USER as
/* $Header: hxcaprpsapi.pkh 120.0 2005/05/29 06:12:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_approval_period_sets >-----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- This API creates the Approval Period Sets.
--
-- Prerequisites:
--
-- None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then a new Approval Period Set
--                                                is created. Default is FALSE.
--   p_approval_period_set_id       Yes  number   Primary Key for entity
--   p_object_version_number        No   number   Object Version Number
--   p_name                         Yes  varchar2 Approval Period Set Name
--
-- Post Success:
--
-- The OUT PARAMETERS set,after the approval period set has been created
-- successfully,are:
--
--   Name                           Type     Description
--
--   p_approval_period_set_id       number   Primary key of the new
--                                           approval period set
--   p_object_version_number        number   Object version number for the
--                                           new approval period set
--
-- Post Failure:
--
-- The approval set will not be created and an application error will be
-- raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_approval_period_sets
  (p_validate                      in     boolean  default false
  ,p_approval_period_set_id        in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2
--  ,p_effective_date                in     date     default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------<update_approval_period_sets>---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API updates an existing Approval Period Sets
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
--                                                then the approval set
--                                                is updated. Default is FALSE.
--   p_approval_period_set_id       Yes  number   Primary Key for entity
--   p_object_version_number        No   number   Object Version Number
--   p_name                         Yes  varchar2 Approval Period Set Name
--
-- Post Success:
--
-- when the approval set has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated approval set
--
-- Post Failure:
--
-- The approval set will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_approval_period_sets
  (p_validate                      in     boolean  default false
  ,p_approval_period_set_id        in     number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2
--  ,p_effective_date                in     date     default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_approval_period_sets >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API deletes an existing Approval Period Sets
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
--                                                then the approval set
--                                                is deleted. Default is FALSE.
--   p_approval_period_set_id       Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the approval set has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The approval set will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_approval_period_sets
  (p_validate                       in  boolean  default false
  ,p_approval_period_set_id         in  number
  ,p_object_version_number          in  number
  );
--
--
END hxc_approval_period_sets_api;

 

/
