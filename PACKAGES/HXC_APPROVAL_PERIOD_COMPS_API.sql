--------------------------------------------------------
--  DDL for Package HXC_APPROVAL_PERIOD_COMPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APPROVAL_PERIOD_COMPS_API" AUTHID CURRENT_USER as
/* $Header: hxcapcapi.pkh 120.0 2005/05/29 05:24:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_approval_period_comps >----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- This API creates the Approval Period Components.
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
--                                                then a new Approval Period
--                                                Comp is created.
--                                                Default is FALSE.
--   p_approval_period_comp_id      Yes  number   Primary Key for entity
--   p_approval_period_set_id       Yes  number   Approval Period Set ID
--   p_time_recipient_id            Yes  number   ID of the Application to
--                                                which the approval component
--                                                is applicable
--   p_recurring_period_id          Yes  number   Recurring Period ID
--   p_object_version_number        No   number   Object Version Number
--   p_effective_date               No   date     Effective date
--
-- Post Success:
--
-- The OUT PARAMETERS set,after the approval period component has been created
-- successfully,are:
--
--   Name                           Type     Description
--
--   p_approval_period_comp_id      number   Primary key of the new
--                                           approval component
--   p_object_version_number        number   Object version number for the
--                                           new approval comp
--
-- Post Failure:
--
-- The approval comp will not be created and an application error will be
-- raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_approval_period_comps
  (p_validate                      in     boolean  default false
  ,p_approval_period_comp_id       in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_approval_period_set_id        in     number
  ,p_time_recipient_id             in     number
  ,p_recurring_period_id           in     number
  ,p_effective_date                in     date     default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------<update_approval_period_comps> -------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API updates an existing Approval Component of an Approval Set
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
--                                                then a new Approval Comp is
--                                                created. Default is FALSE.
--   p_approval_period_comp_id      Yes  number   Primary Key for entity
--   p_approval_period_set_id       Yes  number   Approval Set ID
--   p_time_recipient_id            No   number   ID of the Application to
--                                                which the approval component
--                                                is applicable
--   p_recurring_period_id          No   number   Recurring period id
--                                                corresponding to the approval
--                                                comp
--   p_object_version_number        No   number   Object Version Number
--   p_effective_date               No   date     Effective date
--
-- Post Success:
--
-- when the approval comp has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated approval component
--
-- Post Failure:
--
-- The approval component will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_approval_period_comps
  (p_validate                      in     boolean  default false
  ,p_approval_period_comp_id       in     number
  ,p_object_version_number         in out nocopy number
  ,p_approval_period_set_id        in     number
  ,p_time_recipient_id             in     number
  ,p_recurring_period_id           in     number
  ,p_effective_date                in     date     default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_approval_period_comps >------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API deletes an existing Approval Component of an Approval Set
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
--                                                then the approval component
--                                                is deleted. Default is FALSE.
--   p_approval_period_comp_id      Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the approval component has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The approval comp will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_approval_period_comps
  (p_validate                       in  boolean  default false
  ,p_approval_period_comp_id        in  number
  ,p_object_version_number          in  number
  );
--
--
END hxc_approval_period_comps_api;

 

/
