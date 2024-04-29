--------------------------------------------------------
--  DDL for Package OTA_NHS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_NHS_API" AUTHID CURRENT_USER as
/* $Header: otnhsapi.pkh 120.2 2006/01/09 03:19:33 dbatra noship $ */
/*#
 * This package creates and updates a user's external learning.
 * @rep:scope public
 * @rep:product ota
 * @rep:displayname External Learning
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <create_non_ota_histories> >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a user's external learning.
 *
 * This API, called from both OAF and the PUI, inserts records in the
 * OTA_NOTRNG_HISTORIES table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * User should be a valid employee on effective date
 *
 * <p><b>Post Success</b><br>
 * External Learning record for the user is created in the database
 *
 * <p><b>Post Failure</b><br>
 * External Learning record is not created for the user and an error is raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_nota_history_id If p_validate is false then this uniquely
 * identifies the external learning created. If p_validate is true, then set to
 * null.
 * @param p_person_id Identifies the person for whom you create the external
 * learning record.
 * @param p_contact_id {@rep:casecolumn OTA_NOTRNG_HISTORIES.CONTACT_ID}
 * @param p_trng_title {@rep:casecolumn OTA_NOTRNG_HISTORIES.TRNG_TITLE}
 * @param p_provider {@rep:casecolumn OTA_NOTRNG_HISTORIES.PROVIDER}
 * @param p_type External Learning's type. Valid values are defined by the
 * 'OTA_TRAINING_TYPES' lookup type.
 * @param p_centre {@rep:casecolumn OTA_NOTRNG_HISTORIES.CENTRE}
 * @param p_completion_date {@rep:casecolumn
 * OTA_NOTRNG_HISTORIES.COMPLETION_DATE}
 * @param p_award {@rep:casecolumn OTA_NOTRNG_HISTORIES.AWARD}
 * @param p_rating {@rep:casecolumn OTA_NOTRNG_HISTORIES.RATING}
 * @param p_duration {@rep:casecolumn OTA_NOTRNG_HISTORIES.DURATION}
 * @param p_duration_units External Learning's duration units. Valid values are
 * defined by 'OTA_DURATION_UNITS' lookup type.
 * @param p_activity_version_id The unique identifier of the equivalent Course
 * @param p_status External Learning's Status.Valid values are defined by
 * 'OTA_TRAINING_STATUSES' lookup type.
 * @param p_verified_by_id {@rep:casecolumn
 * OTA_NOTRNG_HISTORIES.VERIFIED_BY_ID}
 * @param p_nth_information_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_nth_information1 Descriptive flexfield segment.
 * @param p_nth_information2 Descriptive flexfield segment.
 * @param p_nth_information3 Descriptive flexfield segment.
 * @param p_nth_information4 Descriptive flexfield segment.
 * @param p_nth_information5 Descriptive flexfield segment.
 * @param p_nth_information6 Descriptive flexfield segment.
 * @param p_nth_information7 Descriptive flexfield segment.
 * @param p_nth_information8 Descriptive flexfield segment.
 * @param p_nth_information9 Descriptive flexfield segment.
 * @param p_nth_information10 Descriptive flexfield segment.
 * @param p_nth_information11 Descriptive flexfield segment.
 * @param p_nth_information12 Descriptive flexfield segment.
 * @param p_nth_information13 Descriptive flexfield segment.
 * @param p_nth_information15 Descriptive flexfield segment.
 * @param p_nth_information16 Descriptive flexfield segment.
 * @param p_nth_information17 Descriptive flexfield segment.
 * @param p_nth_information18 Descriptive flexfield segment.
 * @param p_nth_information19 Descriptive flexfield segment.
 * @param p_nth_information20 Descriptive flexfield segment.
 * @param p_org_id {@rep:casecolumn OTA_NOTRNG_HISTORIES.ORG_ID}
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created external learning. If p_validate is true, then
 * the value will be null.
 * @param p_business_group_id {@rep:casecolumn
 * OTA_NOTRNG_HISTORIES.BUSINESS_GROUP_ID}
 * @param p_nth_information14 Descriptive flexfield segment.
 * @param p_customer_id {@rep:casecolumn OTA_NOTRNG_HISTORIES.CUSTOMER_ID}
 * @param p_organization_id {@rep:casecolumn
 * OTA_NOTRNG_HISTORIES.ORGANIZATION_ID}
 * @param p_some_warning If set to true then one of the business logic
 * validations has failed
 * @rep:displayname Create External Learning
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_EXTERNAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_non_ota_histories
  (p_validate                      in   boolean    default false
  ,p_effective_date                in   date
  ,p_nota_history_id               out nocopy number
  ,p_person_id                   in    number
  ,p_contact_id                in   number   default null
  ,p_trng_title              in  varchar2
  ,p_provider                      in  varchar2
  ,p_type                    in  varchar2    default null
  ,p_centre                     in  varchar2    default null
  ,p_completion_date            in  date
  ,p_award                      in  varchar2    default null
  ,p_rating                     in  varchar2    default null
  ,p_duration                in  number   default null
  ,p_duration_units                in  varchar2    default null
  ,p_activity_version_id           in  number   default null
  ,p_status                        in  varchar2    default null
  ,p_verified_by_id                in  number   default null
  ,p_nth_information_category      in  varchar2    default null
  ,p_nth_information1              in  varchar2 default null
  ,p_nth_information2              in  varchar2 default null
  ,p_nth_information3              in  varchar2 default null
  ,p_nth_information4              in  varchar2    default null
  ,p_nth_information5              in  varchar2    default null
  ,p_nth_information6              in  varchar2    default null
  ,p_nth_information7              in  varchar2    default null
  ,p_nth_information8              in  varchar2  default null
  ,p_nth_information9              in  varchar2    default null
  ,p_nth_information10             in  varchar2 default null
  ,p_nth_information11             in  varchar2 default null
  ,p_nth_information12             in  varchar2 default null
  ,p_nth_information13             in  varchar2 default null
  ,p_nth_information15             in  varchar2    default null
  ,p_nth_information16             in  varchar2 default null
  ,p_nth_information17             in  varchar2 default null
  ,p_nth_information18             in  varchar2    default null
  ,p_nth_information19             in  varchar2 default null
  ,p_nth_information20             in  varchar2 default null
  ,p_org_id                        in  number   default null
  ,p_object_version_number         out nocopy   number
  ,p_business_group_id             in  number
  ,p_nth_information14             in  varchar2    default null
  ,p_customer_id             in  number   default null
  ,p_organization_id         in  number   default null
  ,p_some_warning                  out nocopy   boolean
  );
--





-- ----------------------------------------------------------------------------
-- |--------------------------< <update_non_ota_histories> >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a user's external learning.
 *
 * This API, called from both OAF and the PUI, updates records in the
 * OTA_NOTRNG_HISTORIES table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * External Learning record must exist for the user
 *
 * <p><b>Post Success</b><br>
 * External Learning record of the user is updated
 *
 * <p><b>Post Failure</b><br>
 * External Learning record is not updated for the user and an error is raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_nota_history_id {@rep:casecolumn
 * OTA_NOTRNG_HISTORIES.NOTA_HISTORY_ID}
 * @param p_person_id Identifies the person for whom you update the external
 * learning record.
 * @param p_contact_id {@rep:casecolumn OTA_NOTRNG_HISTORIES.CONTACT_ID}
 * @param p_trng_title {@rep:casecolumn OTA_NOTRNG_HISTORIES.TRNG_TITLE}
 * @param p_provider {@rep:casecolumn OTA_NOTRNG_HISTORIES.PROVIDER}
 * @param p_type External Learning's Type.Valid values are defined by the
 * 'OTA_TRAINING_TYPES' lookup type.
 * @param p_centre {@rep:casecolumn OTA_NOTRNG_HISTORIES.CENTRE}
 * @param p_completion_date {@rep:casecolumn
 * OTA_NOTRNG_HISTORIES.COMPLETION_DATE}
 * @param p_award {@rep:casecolumn OTA_NOTRNG_HISTORIES.AWARD}
 * @param p_rating {@rep:casecolumn OTA_NOTRNG_HISTORIES.RATING}
 * @param p_duration {@rep:casecolumn OTA_NOTRNG_HISTORIES.DURATION}
 * @param p_duration_units External Learning's duration units. Valid values are
 * defined by the 'OTA_DURATION_UNITS' lookup type.
 * @param p_activity_version_id The unique identifier of the equivalent Course
 * @param p_status External Learning's Status. Valid values are defined by the
 * 'OTA_TRAINING_STATUSES' lookup type.
 * @param p_verified_by_id {@rep:casecolumn
 * OTA_NOTRNG_HISTORIES.VERIFIED_BY_ID}
 * @param p_nth_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield segment
 * @param p_nth_information1 Descriptive flexfield segment.
 * @param p_nth_information2 Descriptive flexfield segment.
 * @param p_nth_information3 Descriptive flexfield segment.
 * @param p_nth_information4 Descriptive flexfield segment.
 * @param p_nth_information5 Descriptive flexfield segment.
 * @param p_nth_information6 Descriptive flexfield segment.
 * @param p_nth_information7 Descriptive flexfield segment.
 * @param p_nth_information8 Descriptive flexfield segment.
 * @param p_nth_information9 Descriptive flexfield segment.
 * @param p_nth_information10 Descriptive flexfield segment.
 * @param p_nth_information11 Descriptive flexfield segment.
 * @param p_nth_information12 Descriptive flexfield segment.
 * @param p_nth_information13 Descriptive flexfield segment.
 * @param p_nth_information15 Descriptive flexfield segment.
 * @param p_nth_information16 Descriptive flexfield segment.
 * @param p_nth_information17 Descriptive flexfield segment.
 * @param p_nth_information18 Descriptive flexfield segment.
 * @param p_nth_information19 Descriptive flexfield segment.
 * @param p_nth_information20 Descriptive flexfield segment.
 * @param p_org_id {@rep:casecolumn OTA_NOTRNG_HISTORIES.ORG_ID}
 * @param p_object_version_number Pass in the current version number of the
 * external learning to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated external
 * learning. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_business_group_id {@rep:casecolumn
 * OTA_NOTRNG_HISTORIES.BUSINESS_GROUP_ID}
 * @param p_nth_information14 Developer Descriptive flexfield segment.
 * @param p_customer_id {@rep:casecolumn OTA_NOTRNG_HISTORIES.CUSTOMER_ID}
 * @param p_organization_id {@rep:casecolumn
 * OTA_NOTRNG_HISTORIES.ORGANIZATION_ID}
 * @param p_some_warning If set to true then one of the business logic
 * validations has failed
 * @rep:displayname Update External Learning
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_EXTERNAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure update_non_ota_histories
  (p_validate                      in   boolean    default false
  ,p_effective_date                in   date
  ,p_nota_history_id               in  number
  ,p_person_id                   in    number
  ,p_contact_id                in   number   default hr_api.g_number
  ,p_trng_title              in  varchar2
  ,p_provider                      in  varchar2
  ,p_type                    in  varchar2    default hr_api.g_varchar2
  ,p_centre                     in  varchar2    default hr_api.g_varchar2
  ,p_completion_date            in  date
  ,p_award                      in  varchar2    default hr_api.g_varchar2
  ,p_rating                     in  varchar2    default hr_api.g_varchar2
  ,p_duration                in  number   default hr_api.g_number
  ,p_duration_units                in  varchar2    default hr_api.g_varchar2
  ,p_activity_version_id           in  number   default hr_api.g_number
  ,p_status                        in  varchar2    default hr_api.g_varchar2
  ,p_verified_by_id                in  number   default hr_api.g_number
  ,p_nth_information_category      in  varchar2    default hr_api.g_varchar2
  ,p_nth_information1              in  varchar2 default hr_api.g_varchar2
  ,p_nth_information2              in  varchar2 default hr_api.g_varchar2
  ,p_nth_information3              in  varchar2 default hr_api.g_varchar2
  ,p_nth_information4              in  varchar2    default hr_api.g_varchar2
  ,p_nth_information5              in  varchar2    default hr_api.g_varchar2
  ,p_nth_information6              in  varchar2    default hr_api.g_varchar2
  ,p_nth_information7              in  varchar2    default hr_api.g_varchar2
  ,p_nth_information8              in  varchar2  default hr_api.g_varchar2
  ,p_nth_information9              in  varchar2    default hr_api.g_varchar2
  ,p_nth_information10             in  varchar2 default hr_api.g_varchar2
  ,p_nth_information11             in  varchar2 default hr_api.g_varchar2
  ,p_nth_information12             in  varchar2 default hr_api.g_varchar2
  ,p_nth_information13             in  varchar2 default hr_api.g_varchar2
  ,p_nth_information15             in  varchar2    default hr_api.g_varchar2
  ,p_nth_information16             in  varchar2 default hr_api.g_varchar2
  ,p_nth_information17             in  varchar2 default hr_api.g_varchar2
  ,p_nth_information18             in  varchar2    default hr_api.g_varchar2
  ,p_nth_information19             in  varchar2 default hr_api.g_varchar2
  ,p_nth_information20             in  varchar2 default hr_api.g_varchar2
  ,p_org_id                        in  number   default hr_api.g_number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in  number
  ,p_nth_information14             in  varchar2    default hr_api.g_varchar2
  ,p_customer_id             in  number   default hr_api.g_number
  ,p_organization_id         in  number   default hr_api.g_number
  ,p_some_warning                  out nocopy   boolean
  );


-- ----------------------------------------------------------------------------
-- |--------------------------< <delete_external_learning> >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an external learning.
 *
 * This business process allows the user to delete an external learning
 * identified by a external learning identifier (p_nota_history_id ).
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The external learning must exist
 *
 * <p><b>Post Success</b><br>
 * The external learning is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the external learning record and raises an
 * error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_nota_history_id {@rep:casecolumn
 * OTA_NOTRNG_HISTORIES.NOTA_HISTORY_ID}
 * @param p_object_version_number Passes in the current version number of the
 * course-to-category inclusion to be deleted.
 * @rep:displayname Delete External Learning
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_EXTERNAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_external_learning
  (p_validate                      in   boolean    default false
  ,p_nota_history_id                    in number
  ,p_object_version_number              in number
  );

end OTA_NHS_API;

 

/
