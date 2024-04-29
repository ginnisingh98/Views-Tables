--------------------------------------------------------
--  DDL for Package PER_SEC_PROFILE_ASG_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SEC_PROFILE_ASG_SWI" AUTHID CURRENT_USER As
/* $Header: peaspswi.pkh 115.0 2003/09/15 23:16 vkonda noship $ */

-- ----------------------------------------------------------------------------
-- |----------------------< create_security_profile_asg >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_sec_profile_asg_api.create_security_profile_asg
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
PROCEDURE create_security_profile_asg
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_sec_profile_assignment_id       out nocopy number
  ,p_user_id                      in     number
  ,p_security_group_id            in     number
  ,p_business_group_id            in     number
  ,p_security_profile_id          in     number
  ,p_responsibility_id            in     number
  ,p_responsibility_application_i in     number
  ,p_start_date                   in     date
  ,p_end_date                     in     date      default null
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );

-- ----------------------------------------------------------------------------
-- |----------------------< update_security_profile_asg >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_sec_profile_asg_api.update_security_profile_asg
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
PROCEDURE update_security_profile_asg
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_sec_profile_assignment_id    in     number
  ,p_user_id                      in     number
  ,p_security_group_id            in     number
  ,p_business_group_id            in     number
  ,p_security_profile_id          in     number
  ,p_responsibility_id            in     number
  ,p_responsibility_application_i in     number
  ,p_start_date                   in     date
  ,p_end_date                     in     date
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end per_sec_profile_asg_swi;

 

/
