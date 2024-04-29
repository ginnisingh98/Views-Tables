--------------------------------------------------------
--  DDL for Package PER_SEC_PROFILE_ASG_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SEC_PROFILE_ASG_API" AUTHID CURRENT_USER as
/* $Header: peaspapi.pkh 115.1 2003/09/16 01:13 vkonda noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_security_profile_asg >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  Assigns security profiles for an assignment.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd  Type     Description
-- p_validate                       No   Boolean   Assigns a security profile to
--                                                 an assignment if the value is
--                                                 true.
-- p_user_id                        Yes  Number    user id for which the security
--                                                 profile is attached.
-- p_security_group_id              Yes  Number    The security group of the
--                                                 responsibility
-- p_business_group_id              Yes  Number    Business group id
-- p_security_profile_id            Yes  Number    id of the security profile
--                                                 being attached.
-- p_responsibility_id              Yes  Number    Responsibility for which the
--                                                 profile is being set.
-- p_responsibility_application_i   Yes  Number    Application id of the
--                                                 responsibility.
-- p_start_date                     Yes  Date      Start date of the assignment
-- p_end_date                       Yes  Date      End date of the assignment
--
-- Post Success:
--  A security profile is attached to an user / responsibility .

-- Out Parameters:
--   Name                           Type     Description
-- p_sec_profile_assignment_id     Number    Id of the row created for the
--                                           new assignment.
-- p_object_version_number         Number    Object version number of the row
--                                           created.
-- Post Failure:
-- Security profile is not assigned and raises an application error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_security_profile_asg
  (p_validate                     in  boolean default false,
   p_sec_profile_assignment_id    out nocopy number,
   p_user_id                      in number,
   p_security_group_id            in number,
   p_business_group_id            in number,
   p_security_profile_id          in number,
   p_responsibility_id            in number,
   p_responsibility_application_i in number,
   p_start_date                   in date,
   p_end_date                     in date             default null,
   p_object_version_number        out nocopy number
  );

--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_security_profile_asg >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  Assigns security profiles for an assignment.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd  Type     Description
-- p_validate                       No   Boolean   updates an assignment of the
--                                                 security profile if the value is
--                                                 true.
-- p_sec_profile_assignment_id      Yes  Number    Id of the assignment being updated.
-- p_start_date                     Yes  Date      Start date of the assignment
-- p_end_date                       Yes  Date      End date of the assignment
--
-- Post Success:
--  A security profile attached to an user / responsibility is updated.

-- Out Parameters:
--   Name                           Type     Description
-- p_object_version_number         Number    Object version number of the
--                                           updated assignment.
-- Post Failure:
-- Security profile is not updated and raises an application error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_security_profile_asg
  (p_validate                     in  boolean default false,
   p_sec_profile_assignment_id    in number,
   p_user_id                      in number,
   p_security_group_id            in number,
   p_business_group_id            in number,
   p_security_profile_id          in number,
   p_responsibility_id            in number,
   p_responsibility_application_i in number,
   p_start_date                   in date,
   p_end_date                     in date,
   p_object_version_number        in out nocopy number
  );
--

end per_sec_profile_asg_api;

 

/
