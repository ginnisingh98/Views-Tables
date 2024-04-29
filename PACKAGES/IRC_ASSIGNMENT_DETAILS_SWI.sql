--------------------------------------------------------
--  DDL for Package IRC_ASSIGNMENT_DETAILS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_ASSIGNMENT_DETAILS_SWI" AUTHID CURRENT_USER As
/* $Header: iriadswi.pkh 120.2.12010000.2 2010/01/11 10:38:55 uuddavol ship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< create_assignment_details >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_assignment_details_api.create_assignment_details
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
PROCEDURE create_assignment_details
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_assignment_id                in     number
  ,p_attempt_id                   in     number    default null
  ,p_assignment_details_id        in     number
  ,p_qualified                    in     varchar2  default null
  ,p_considered                   in     varchar2  default null
  ,p_details_version                 out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_assignment_details >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_assignment_details_api.update_assignment_details
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
PROCEDURE update_assignment_details
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_attempt_id                   in     number    default hr_api.g_number
  ,p_qualified                    in     varchar2  default hr_api.g_varchar2
  ,p_considered                   in     varchar2  default hr_api.g_varchar2
  ,p_assignment_details_id        in out nocopy number
  ,p_object_version_number        in out nocopy number
  ,p_details_version                 out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  );
 end irc_assignment_details_swi;

/
