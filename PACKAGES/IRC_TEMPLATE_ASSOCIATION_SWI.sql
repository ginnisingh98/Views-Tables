--------------------------------------------------------
--  DDL for Package IRC_TEMPLATE_ASSOCIATION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_TEMPLATE_ASSOCIATION_SWI" AUTHID CURRENT_USER As
/* $Header: iritaswi.pkh 120.0 2005/09/27 08:11 sayyampe noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< create_template_association >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_template_association_api.create_template_association
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
PROCEDURE create_template_association
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_template_id                  in     number
  ,p_effective_date               in     date      default null
  ,p_default_association          in     varchar2  default null
  ,p_job_id                       in     number    default null
  ,p_position_id                  in     number    default null
  ,p_organization_id              in     number    default null
  ,p_start_date                   in     date      default null
  ,p_end_date                     in     date      default null
  ,p_object_version_number           out nocopy number
  ,p_template_association_id      in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_template_association >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_template_association_api.update_template_association
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
PROCEDURE update_template_association
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_template_association_id      in     number
  ,p_template_id                  in     number
  ,p_default_association          in     varchar2  default hr_api.g_varchar2
  ,p_job_id                       in     number    default hr_api.g_number
  ,p_position_id                  in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_template_association >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_template_association_api.delete_template_association
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
PROCEDURE delete_template_association
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_template_association_id      in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end irc_template_association_swi;

 

/
