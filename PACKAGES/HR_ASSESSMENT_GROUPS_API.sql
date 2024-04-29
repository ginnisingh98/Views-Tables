--------------------------------------------------------
--  DDL for Package HR_ASSESSMENT_GROUPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSESSMENT_GROUPS_API" AUTHID CURRENT_USER as
/* $Header: peasrapi.pkh 115.3 99/10/05 09:44:03 porting ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< <create_assessment_group> >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This API creates a new assessment group.
--
-- Prerequisites:
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the address is created.
--   p_effective_date               Yes  date     Effective date.
--   p_name                         Yes  varchar2 Is the unique name of the
--						  assessment_group.
--   p_business_group_id            Yes  number   Business group id in which
--						  the competence is created.
--   p_comments                          varchar2 Extra comments.
--   p_attribute_category                varchar2 Determines context of the
--                                                attribute Descriptive
--                                                flexfield in parameters.
--   p_attribute1                        varchar2 Descriptive flexfield.
--   p_attribute2                        varchar2 Descriptive flexfield.
--   p_attribute3                        varchar2 Descriptive flexfield.
--   p_attribute4                        varchar2 Descriptive flexfield.
--   p_attribute5                        varchar2 Descriptive flexfield.
--   p_attribute6                        varchar2 Descriptive flexfield.
--   p_attribute7                        varchar2 Descriptive flexfield.
--   p_attribute8                        varchar2 Descriptive flexfield.
--   p_attribute9                        varchar2 Descriptive flexfield.
--   p_attribute10                       varchar2 Descriptive flexfield.
--   p_attribute11                       varchar2 Descriptive flexfield.
--   p_attribute12                       varchar2 Descriptive flexfield.
--   p_attribute13                       varchar2 Descriptive flexfield.
--   p_attribute14                       varchar2 Descriptive flexfield.
--   p_attribute15                       varchar2 Descriptive flexfield.
--   p_attribute16                       varchar2 Descriptive flexfield.
--   p_attribute17                       varchar2 Descriptive flexfield.
--   p_attribute18                       varchar2 Descriptive flexfield.
--   p_attribute19                       varchar2 Descriptive flexfield.
--   p_attribute20                       varchar2 Descriptive flexfield.
--
-- Post Success:
-- Competence is created and sets the following out parameters.
--
--   Name                           Type     Description
--   p_assessment_group_id	    number   If p_validate is false, uniquely
--                                           identifies the assessment_group
--					     created.
--                                           If p_validate is true, set to
--                                           null.
--
--   p_object_version_number        number   If p_validate is false, set to
--                                           the version number of this
--                                           assessment_group. If p_validate is
--					    true, set to null.
-- Post Failure:
-- Does not create a assessment_group and the api raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_assessment_group
 (p_assessment_group_id          out      number,
  p_name                         in       varchar2,
  p_business_group_id            in       number,
  p_comments                     in       varchar2         default null,
  p_object_version_number        out      number,
  p_attribute_category           in 	varchar2         default null,
  p_attribute1                   in 	varchar2         default null,
  p_attribute2                   in 	varchar2         default null,
  p_attribute3                   in 	varchar2         default null,
  p_attribute4                   in 	varchar2         default null,
  p_attribute5                   in 	varchar2         default null,
  p_attribute6                   in 	varchar2         default null,
  p_attribute7                   in 	varchar2         default null,
  p_attribute8                   in 	varchar2         default null,
  p_attribute9                   in 	varchar2         default null,
  p_attribute10                  in 	varchar2         default null,
  p_attribute11                  in 	varchar2         default null,
  p_attribute12                  in 	varchar2         default null,
  p_attribute13                  in 	varchar2         default null,
  p_attribute14                  in 	varchar2         default null,
  p_attribute15                  in 	varchar2         default null,
  p_attribute16                  in 	varchar2         default null,
  p_attribute17                  in 	varchar2         default null,
  p_attribute18                  in 	varchar2         default null,
  p_attribute19                  in 	varchar2         default null,
  p_attribute20                  in 	varchar2         default null,
  p_validate                     in       boolean          default false,
  p_effective_date               in       date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< <update_assessment_group> >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This API updates an assessment_group as identified by the in parameter
-- p_assessment_group_id and the in out parameter p_object_version_number.
--
-- Prerequisites:
-- A valid assessment_group_id must be passed to the API.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the address is created.
--   p_effective_date               Yes  date     Effective date.
--   p_name                         Yes  varchar2 Is the unique name for the
--                                                assessment_group.
-- p_comments                           varchar2  free form text comments.
--                                                flexfield in parameters.
--   p_attribute_category                varchar2 Determines context
--   p_attribute1                        varchar2 Descriptive flexfield.
--   p_attribute2                        varchar2 Descriptive flexfield.
--   p_attribute3                        varchar2 Descriptive flexfield.
--   p_attribute4                        varchar2 Descriptive flexfield.
--   p_attribute5                        varchar2 Descriptive flexfield.
--   p_attribute6                        varchar2 Descriptive flexfield.
--   p_attribute7                        varchar2 Descriptive flexfield.
--   p_attribute8                        varchar2 Descriptive flexfield.
--   p_attribute9                        varchar2 Descriptive flexfield.
--   p_attribute10                       varchar2 Descriptive flexfield.
--   p_attribute11                       varchar2 Descriptive flexfield.
--   p_attribute12                       varchar2 Descriptive flexfield.
--   p_attribute13                       varchar2 Descriptive flexfield.
--   p_attribute14                       varchar2 Descriptive flexfield.
--   p_attribute15                       varchar2 Descriptive flexfield.
--   p_attribute16                       varchar2 Descriptive flexfield.
--   p_attribute17                       varchar2 Descriptive flexfield.
--   p_attribute18                       varchar2 Descriptive flexfield.
--   p_attribute19                       varchar2 Descriptive flexfield.
--   p_attribute20                       varchar2 Descriptive flexfield.
--
-- Post Success:
--   Assessment_group is updated and the API sets the following out parameters:
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false, set to
--                                           the version number of this
--                                           assessment_group.
--					     If p_validate is true,
--                                           set to null.
--
-- Post Failure:
--   Assessment_group remains unchanged and the api raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
procedure update_assessment_group
 (p_assessment_group_id          in number,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out number,
  --
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean      default false,
  p_effective_date               in date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< <delete_assessment_group> >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Deletes an existing assessment_group.
--
-- Prerequisites:
-- A valid assessment_group must already exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the address is created.
--   p_assessment_group_id           Yes  number   Assessment_group to be deleted.
--						  If p_validate is false,
--						  uniquely identifies the
--						  assessment_group to be deleted.
--                                                If p_validate is true, set to
--                                                null.
--   p_object_version_number             number   If p_validate is false, set
--						  to the version number of this
--                                                assessment_type. If
--						  p_validate is true, set to
--						  null.
-- Post Success:
-- Assessment_group is removed from the database.
--
-- Post Failure:
-- Assessment_group is not deleted and an application error is raised.
--
-- Access Status:
--   Public.
--
procedure delete_assessment_group
(p_validate                           in boolean default false,
 p_assessment_group_id                 in number,
 p_object_version_number              in number
);
--
end hr_assessment_groups_api;

 

/
