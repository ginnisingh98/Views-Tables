--------------------------------------------------------
--  DDL for Package IRC_REC_TEAM_MEMBERS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_REC_TEAM_MEMBERS_SWI" AUTHID CURRENT_USER As
/* $Header: irrtmswi.pkh 120.3.12010000.1 2008/07/28 12:50:12 appldev ship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_rec_team_member >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_rec_team_members_api.create_rec_team_member
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
PROCEDURE create_rec_team_member
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rec_team_member_id           in     number
  ,p_person_id                    in     number
  ,p_vacancy_id                   in     number
  ,p_job_id                       in     number    default null
  ,p_start_date                   in     date      default null
  ,p_end_date                     in     date      default null
  ,p_update_allowed               in     varchar2  default null
  ,p_delete_allowed               in     varchar2  default null
  ,p_interview_security            in     varchar2  default 'SELF'
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_rec_team_member >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_rec_team_members_api.delete_rec_team_member
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
PROCEDURE delete_rec_team_member
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rec_team_member_id           in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_rec_team_member >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_rec_team_members_api.update_rec_team_member
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
PROCEDURE update_rec_team_member
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rec_team_member_id           in     number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_party_id                     in     number    default hr_api.g_number
  ,p_vacancy_id                   in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_job_id                       in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_update_allowed               in     varchar2  default hr_api.g_varchar2
  ,p_delete_allowed               in     varchar2  default hr_api.g_varchar2
  ,p_interview_security            in     varchar2  default 'SELF'
  ,p_return_status                   out nocopy varchar2
  );
--
procedure process_api
(
  p_document            in         CLOB
 ,p_return_status       out nocopy VARCHAR2
 ,p_validate            in         number    default hr_api.g_false_num
 ,p_effective_date      in         date      default null
);
--
end irc_rec_team_members_swi;

/
