--------------------------------------------------------
--  DDL for Package HR_QUALIFICATION_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_QUALIFICATION_TYPE_API" AUTHID CURRENT_USER as
/* $Header: peeqtapi.pkh 120.1 2005/10/02 02:16 aroussel $ */
/*#
 * This package contains qualification type APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Qualification Type
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_qualification_type >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a qualification type.
 *
 * Qualification types holds the list of qualification types that can be
 * attained.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * There are no prereqs for this API.
 *
 * <p><b>Post Success</b><br>
 * Qualification type is created.
 *
 * <p><b>Post Failure</b><br>
 * Qualification type is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_name Qualification type name.
 * @param p_category Category or grouping name. Valid values are defined by
 * PER_CATEGORIES lookup type.
 * @param p_rank Holds the rank of the qualification
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
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_information21 Developer descriptive flexfield segment.
 * @param p_information22 Developer descriptive flexfield segment.
 * @param p_information23 Developer descriptive flexfield segment.
 * @param p_information24 Developer descriptive flexfield segment.
 * @param p_information25 Developer descriptive flexfield segment.
 * @param p_information26 Developer descriptive flexfield segment.
 * @param p_information27 Developer descriptive flexfield segment.
 * @param p_information28 Developer descriptive flexfield segment.
 * @param p_information29 Developer descriptive flexfield segment.
 * @param p_information30 Developer descriptive flexfield segment.
 * @param p_qual_framework_id Qualifications Framework identifier
 * @param p_qualification_type Qualification Framework type. Valid values are
 * defined by PER_QUAL_FWK_QUAL_TYPE lookup type.
 * @param p_credit_type Qualifications Framework credit type. Valid values are
 * defined by PER_QUAL_FWK_CREDIT_TYPE lookup type.
 * @param p_credits Qualifications Framework credits
 * @param p_level_type Qualifications Framework level type. Valid values are
 * defined by PER_QUAL_FWK_LEVEL_TYPE lookup type.
 * @param p_level_number Qualifications Framework level number. Valid values
 * are defined by PER_QUAL_FWK_LEVEL lookup type.
 * @param p_field Qualifications Framework field of learning. Valid values are
 * defined by PER_QUAL_FWK_FIELD lookup type.
 * @param p_sub_field Qualifications Framework subfield. Valid values are
 * defined by PER_QUAL_FWK_SUB_FIELD lookup type.
 * @param p_provider Qualifications Framework provider. Valid values are
 * defined by PER_QUAL_FWK_PROVIDER lookup type.
 * @param p_qa_organization Qualifications Framework Quality Assurance
 * Organization. Valid values are defined by PER_QUAL_FWK_QA_ORG lookup type.
 * @param p_qualification_type_id If p_validate is false, then this uniquely
 * identifies the qualification type created. If p_validate is true, then set
 * to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created qualification type. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Qualification Type
 * @rep:category BUSINESS_ENTITY PER_QUALIFICATION
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_qualification_type
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
  ,p_information1           in varchar2         default null
  ,p_information2           in varchar2         default null
  ,p_information3           in varchar2         default null
  ,p_information4           in varchar2         default null
  ,p_information5           in varchar2         default null
  ,p_information6           in varchar2         default null
  ,p_information7           in varchar2         default null
  ,p_information8           in varchar2         default null
  ,p_information9           in varchar2         default null
  ,p_information10          in varchar2         default null
  ,p_information11          in varchar2         default null
  ,p_information12          in varchar2         default null
  ,p_information13          in varchar2         default null
  ,p_information14          in varchar2         default null
  ,p_information15          in varchar2         default null
  ,p_information16          in varchar2         default null
  ,p_information17          in varchar2         default null
  ,p_information18          in varchar2         default null
  ,p_information19          in varchar2         default null
  ,p_information20          in varchar2         default null
  ,p_information21          in varchar2         default null
  ,p_information22          in varchar2         default null
  ,p_information23          in varchar2         default null
  ,p_information24          in varchar2         default null
  ,p_information25          in varchar2         default null
  ,p_information26          in varchar2         default null
  ,p_information27          in varchar2         default null
  ,p_information28          in varchar2         default null
  ,p_information29          in varchar2         default null
  ,p_information30          in varchar2         default null
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
-- |------------------------< update_qualification_type >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates qualification type.
 *
 * Qualification types holds the list of qualification types that can be
 * attained.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The qualification type to be updated must exist.
 *
 * <p><b>Post Success</b><br>
 * Qualification type is updated.
 *
 * <p><b>Post Failure</b><br>
 * Qualification type is not updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_qualification_type_id Identifies the qualification type to be
 * modified.
 * @param p_object_version_number Pass in the current version number of the
 * qualification type to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated qualification
 * type. If p_validate is true will be set to the same value which was passed
 * in
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_name Qualification type name
 * @param p_category Category or grouping name. Valid values are defined by
 * PER_CATEGORIES lookup type.
 * @param p_rank Rank of the qualification
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
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_information21 Developer descriptive flexfield segment.
 * @param p_information22 Developer descriptive flexfield segment.
 * @param p_information23 Developer descriptive flexfield segment.
 * @param p_information24 Developer descriptive flexfield segment.
 * @param p_information25 Developer descriptive flexfield segment.
 * @param p_information26 Developer descriptive flexfield segment.
 * @param p_information27 Developer descriptive flexfield segment.
 * @param p_information28 Developer descriptive flexfield segment.
 * @param p_information29 Developer descriptive flexfield segment.
 * @param p_information30 Developer descriptive flexfield segment.
 * @param p_qual_framework_id Qualifications Framework Identifier
 * @param p_qualification_type Qualification Framework type. Valid values are
 * defined by PER_QUAL_FWK_QUAL_TYPE lookup type.
 * @param p_credit_type Qualifications Framework credit type. Valid values are
 * defined by PER_QUAL_FWK_CREDIT_TYPE lookup type.
 * @param p_credits Qualifications Framework credits
 * @param p_level_type Qualifications Framework level type. Valid values are
 * defined by PER_QUAL_FWK_LEVEL_TYPE lookup type.
 * @param p_level_number Qualifications Framework level number. Valid values
 * are defined by PER_QUAL_FWK_LEVEL lookup type.
 * @param p_field Qualifications Framework field of learning. Valid values are
 * defined by PER_QUAL_FWK_FIELD lookup type.
 * @param p_sub_field Qualifications Framework subfield. Valid values are
 * defined by PER_QUAL_FWK_SUB_FIELD lookup type.
 * @param p_provider Qualifications Framework provider. Valid values are
 * defined by PER_QUAL_FWK_PROVIDER lookup type.
 * @param p_qa_organization Qualifications Framework Quality Assurance
 * Organization. Valid values are defined by PER_QUAL_FWK_QA_ORG lookup type.
 * @rep:displayname Update Qualification Type
 * @rep:category BUSINESS_ENTITY PER_QUALIFICATION
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_qualification_type
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
  ,p_information1                  in     varchar2 default hr_api.g_varchar2
  ,p_information2                  in     varchar2 default hr_api.g_varchar2
  ,p_information3                  in     varchar2 default hr_api.g_varchar2
  ,p_information4                  in     varchar2 default hr_api.g_varchar2
  ,p_information5                  in     varchar2 default hr_api.g_varchar2
  ,p_information6                  in     varchar2 default hr_api.g_varchar2
  ,p_information7                  in     varchar2 default hr_api.g_varchar2
  ,p_information8                  in     varchar2 default hr_api.g_varchar2
  ,p_information9                  in     varchar2 default hr_api.g_varchar2
  ,p_information10                 in     varchar2 default hr_api.g_varchar2
  ,p_information11                 in     varchar2 default hr_api.g_varchar2
  ,p_information12                 in     varchar2 default hr_api.g_varchar2
  ,p_information13                 in     varchar2 default hr_api.g_varchar2
  ,p_information14                 in     varchar2 default hr_api.g_varchar2
  ,p_information15                 in     varchar2 default hr_api.g_varchar2
  ,p_information16                 in     varchar2 default hr_api.g_varchar2
  ,p_information17                 in     varchar2 default hr_api.g_varchar2
  ,p_information18                 in     varchar2 default hr_api.g_varchar2
  ,p_information19                 in     varchar2 default hr_api.g_varchar2
  ,p_information20                 in     varchar2 default hr_api.g_varchar2
  ,p_information21                 in     varchar2 default hr_api.g_varchar2
  ,p_information22                 in     varchar2 default hr_api.g_varchar2
  ,p_information23                 in     varchar2 default hr_api.g_varchar2
  ,p_information24                 in     varchar2 default hr_api.g_varchar2
  ,p_information25                 in     varchar2 default hr_api.g_varchar2
  ,p_information26                 in     varchar2 default hr_api.g_varchar2
  ,p_information27                 in     varchar2 default hr_api.g_varchar2
  ,p_information28                 in     varchar2 default hr_api.g_varchar2
  ,p_information29                 in     varchar2 default hr_api.g_varchar2
  ,p_information30                 in     varchar2 default hr_api.g_varchar2
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
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_qualification_type >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes qualification type.
 *
 * Qualification types holds the list of qualification types that can be
 * attained.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * Existing qualification type must exist.
 *
 * <p><b>Post Success</b><br>
 * Qualification type is deleted.
 *
 * <p><b>Post Failure</b><br>
 * Qualification type is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_qualification_type_id Identifies the qualification type to be
 * deleted.
 * @param p_object_version_number Current version number of the qualification
 * type to be deleted.
 * @rep:displayname Delete Qualification Type
 * @rep:category BUSINESS_ENTITY PER_QUALIFICATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_qualification_type
  (p_validate                in      boolean
  ,p_qualification_type_id   in      number
  ,p_object_version_number   in out  nocopy number
  );

--
end hr_qualification_type_api;
--

 

/
