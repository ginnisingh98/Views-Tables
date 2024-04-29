--------------------------------------------------------
--  DDL for Package IRC_ASG_STATUS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_ASG_STATUS_SWI" AUTHID CURRENT_USER As
/* $Header: iriasswi.pkh 120.0.12010000.2 2009/07/30 03:44:18 vmummidi ship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_irc_asg_status >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_asg_status_api.create_irc_asg_status
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_irc_asg_status
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_assignment_id                in     number
  ,p_assignment_status_type_id    in     number
  ,p_status_change_date           in     date
  ,p_status_change_reason         in     varchar2  default null
  ,p_assignment_status_id         in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_status_change_comments       in     varchar2  default null
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_irc_asg_status >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_asg_status_api.delete_irc_asg_status
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_irc_asg_status
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_assignment_status_id         in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_irc_asg_status >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_asg_status_api.update_irc_asg_status
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_irc_asg_status
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_status_change_reason         in     varchar2  default hr_api.g_varchar2
  ,p_status_change_date           in     date
  ,p_assignment_status_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_status_change_comments       in     varchar2  default hr_api.g_varchar2
  );
end irc_asg_status_swi;

/
