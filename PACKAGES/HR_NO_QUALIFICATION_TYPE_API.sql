--------------------------------------------------------
--  DDL for Package HR_NO_QUALIFICATION_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NO_QUALIFICATION_TYPE_API" AUTHID CURRENT_USER as
/* $Header: peeqtnoi.pkh 120.1 2005/10/02 02:41 aroussel $ */
/*#
 * This package contains qualification type APIs for Norway.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Qualification Type for Norway
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_no_qualification_type >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new qualification type for Norway.
 *
 * This API creates a qualification type for a business group with a
 * legislation code of Norway.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid business group must exist.
 *
 * <p><b>Post Success</b><br>
 * A new qualification type will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The qualification type will not be created, and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_name Qualification type name.
 * @param p_category A grouping or categorization of the qualification type.
 * Valid values are defined in the PER_CATEGORIES lookup type.
 * @param p_rank The rank of the qualification.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_nus2000_code NUS-2000 code.
 * @param p_qual_framework_id Qualifications Framework identifier for the
 * qualification.
 * @param p_qualification_type Qualifications Framework qualification type.
 * @param p_credit_type Qualifications Framework credit type.
 * @param p_credits Qualifications Framework credits.
 * @param p_level_type Qualifications Framework level type.
 * @param p_level_number Qualifications Framework level.
 * @param p_field Qualifications Framework field of learning.
 * @param p_sub_field Qualifications Framework subsidiary field of learning.
 * @param p_provider Qualification provider.
 * @param p_qa_organization Quality Assurance (QA) organization that registered
 * the qualification provider.
 * @param p_qualification_type_id Identifier of the qualification type.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created qualification type. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Qualification Type for Norway
 * @rep:category BUSINESS_ENTITY PER_QUALIFICATION
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_no_qualification_type
  (p_validate               in boolean          default false
  ,p_effective_date         in date
  ,p_language_code          in varchar2         default hr_api.userenv_lang
  ,p_name                   in varchar2
  ,p_category               in varchar2
  ,p_rank                   in number           default null
  ,p_attribute_category     in varchar2         default null
  ,p_attribute1             in varchar2         default null
  ,p_attribute2             in varchar2         default null
  ,p_attribute3             in varchar2         default null
  ,p_attribute4             in varchar2         default null
  ,p_attribute5             in varchar2         default null
  ,p_attribute6             in varchar2         default null
  ,p_attribute7             in varchar2         default null
  ,p_attribute8             in varchar2         default null
  ,p_attribute9             in varchar2         default null
  ,p_attribute10            in varchar2         default null
  ,p_attribute11            in varchar2         default null
  ,p_attribute12            in varchar2         default null
  ,p_attribute13            in varchar2         default null
  ,p_attribute14            in varchar2         default null
  ,p_attribute15            in varchar2         default null
  ,p_attribute16            in varchar2         default null
  ,p_attribute17            in varchar2         default null
  ,p_attribute18            in varchar2         default null
  ,p_attribute19            in varchar2         default null
  ,p_attribute20            in varchar2         default null
  ,p_information_category   in varchar2         default null
  ,p_nus2000_code           in varchar2         default null
  ,p_qual_framework_id      in number           default null
  ,p_qualification_type     in varchar2         default null
  ,p_credit_type            in varchar2         default null
  ,p_credits                in number           default null
  ,p_level_type             in varchar2         default null
  ,p_level_number           in number           default null
  ,p_field                  in varchar2         default null
  ,p_sub_field              in varchar2         default null
  ,p_provider               in varchar2         default null
  ,p_qa_organization        in varchar2         default null
  ,p_qualification_type_id  out NOCOPY number
  ,p_object_version_number  out NOCOPY number
 ) ;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_no_qualification_type >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing qualification type.
 *
 * This API updates the qualification type identified by the in parameter
 * p_qualification_type_id and the in out parameter p_object_version_number.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The qualification type must exist.
 *
 * <p><b>Post Success</b><br>
 * The qualification type is successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The qualification type will not be updated, and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_qualification_type_id Identifier of the qualification type.
 * @param p_object_version_number Pass in the current version number of the
 * qualification type. to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated qualification
 * type. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_name Qualification type name.
 * @param p_category A grouping or categorization of the qualification type.
 * Valid values are defined in the PER_CATEGORIES lookup type.
 * @param p_rank The rank of the qualification.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_nus2000_code NUS-2000 code.
 * @param p_qual_framework_id Qualifications Framework identifier for the
 * qualification.
 * @param p_qualification_type Qualifications Framework qualification type.
 * @param p_credit_type Qualifications Framework credit type.
 * @param p_credits Qualifications Framework credits.
 * @param p_level_type Qualifications Framework level type.
 * @param p_level_number Qualifications Framework level.
 * @param p_field Qualifications Framework field of learning.
 * @param p_sub_field Qualifications Framework subsidiary field of learning.
 * @param p_provider Qualification provider.
 * @param p_qa_organization Quality Assurance (QA) organization post success:
 * when the qualification type is valid, the API updates the qualification type
 * successfully.
 * @rep:displayname Update Qualification Type for Norway
 * @rep:category BUSINESS_ENTITY PER_QUALIFICATION
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_no_qualification_type
  (p_validate                      in     boolean          default false
  ,p_qualification_type_id         in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_date                in     date
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_name                          in     varchar2 default hr_api.g_varchar2
  ,p_category                      in     varchar2 default hr_api.g_varchar2
  ,p_rank                          in     number   default hr_api.g_number
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_information_category          in     varchar2 default hr_api.g_varchar2
  ,p_nus2000_code           	   in     varchar2 default hr_api.g_varchar2
  ,p_qual_framework_id             in     number   default hr_api.g_number
  ,p_qualification_type            in     varchar2 default hr_api.g_varchar2
  ,p_credit_type                   in     varchar2 default hr_api.g_varchar2
  ,p_credits                       in     number   default hr_api.g_number
  ,p_level_type                    in     varchar2 default hr_api.g_varchar2
  ,p_level_number                  in     number   default hr_api.g_number
  ,p_field                         in     varchar2 default hr_api.g_varchar2
  ,p_sub_field                     in     varchar2 default hr_api.g_varchar2
  ,p_provider                      in     varchar2 default hr_api.g_varchar2
  ,p_qa_organization               in     varchar2 default hr_api.g_varchar2
);

end hr_no_qualification_type_api;

 

/
