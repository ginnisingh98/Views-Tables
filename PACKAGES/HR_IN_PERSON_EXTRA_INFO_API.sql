--------------------------------------------------------
--  DDL for Package HR_IN_PERSON_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_IN_PERSON_EXTRA_INFO_API" AUTHID CURRENT_USER AS
/* $Header: pepeiini.pkh 120.1 2005/10/02 02:43 aroussel $ */
/*#
 * This package contains person extra information APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Person Extra Information for India
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_in_person_extra_info >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates miscellaneous extra information for a person.
 *
 * For the extra information type 'IN_MISCELLANEOUS', a record is created for
 * the person.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Person must exist. Extra Person Information Type IN_MISCELLANEOUS must
 * exist.
 *
 * <p><b>Post Success</b><br>
 * The miscellaneous extra information is created for the person.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the person extra info and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_id Identifies the person for whom you create the extra
 * person information record.
 * @param p_pei_attribute_category Determines context of the pei_attribute
 * descriptive flexfield in parameters
 * @param p_pei_attribute1 Descriptive flexfield segment.
 * @param p_pei_attribute2 Descriptive flexfield segment.
 * @param p_pei_attribute3 Descriptive flexfield segment.
 * @param p_pei_attribute4 Descriptive flexfield segment.
 * @param p_pei_attribute5 Descriptive flexfield segment.
 * @param p_pei_attribute6 Descriptive flexfield segment.
 * @param p_pei_attribute7 Descriptive flexfield segment.
 * @param p_pei_attribute8 Descriptive flexfield segment.
 * @param p_pei_attribute9 Descriptive flexfield segment.
 * @param p_pei_attribute10 Descriptive flexfield segment.
 * @param p_pei_attribute11 Descriptive flexfield segment.
 * @param p_pei_attribute12 Descriptive flexfield segment.
 * @param p_pei_attribute13 Descriptive flexfield segment.
 * @param p_pei_attribute14 Descriptive flexfield segment.
 * @param p_pei_attribute15 Descriptive flexfield segment.
 * @param p_pei_attribute16 Descriptive flexfield segment.
 * @param p_pei_attribute17 Descriptive flexfield segment.
 * @param p_pei_attribute18 Descriptive flexfield segment.
 * @param p_pei_attribute19 Descriptive flexfield segment.
 * @param p_pei_attribute20 Descriptive flexfield segment.
 * @param p_religion Religion of the person
 * @param p_community Community of the person
 * @param p_caste_or_tribe Caste or tribe of the person
 * @param p_height Height of the person
 * @param p_weight Weight of the person
 * @param p_person_extra_info_id If p_validate is false, uniquely identifies
 * the person extra info created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created extra person information. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create Miscellaneous Person Extra Information for India
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_in_person_extra_info
  (p_validate                      IN     BOOLEAN  default false
  ,p_person_id                     IN     NUMBER
  ,p_pei_attribute_category        IN     VARCHAR2 default null
  ,p_pei_attribute1                IN     VARCHAR2 default null
  ,p_pei_attribute2                IN     VARCHAR2 default null
  ,p_pei_attribute3                IN     VARCHAR2 default null
  ,p_pei_attribute4                IN     VARCHAR2 default null
  ,p_pei_attribute5                IN     VARCHAR2 default null
  ,p_pei_attribute6                IN     VARCHAR2 default null
  ,p_pei_attribute7                IN     VARCHAR2 default null
  ,p_pei_attribute8                IN     VARCHAR2 default null
  ,p_pei_attribute9                IN     VARCHAR2 default null
  ,p_pei_attribute10               IN     VARCHAR2 default null
  ,p_pei_attribute11               IN     VARCHAR2 default null
  ,p_pei_attribute12               IN     VARCHAR2 default null
  ,p_pei_attribute13               IN     VARCHAR2 default null
  ,p_pei_attribute14               IN     VARCHAR2 default null
  ,p_pei_attribute15               IN     VARCHAR2 default null
  ,p_pei_attribute16               IN     VARCHAR2 default null
  ,p_pei_attribute17               IN     VARCHAR2 default null
  ,p_pei_attribute18               IN     VARCHAR2 default null
  ,p_pei_attribute19               IN     VARCHAR2 default null
  ,p_pei_attribute20               IN     VARCHAR2 default null
  ,p_religion                      IN     VARCHAR2 default null
  ,p_community                     IN     VARCHAR2 default null
  ,p_caste_or_tribe                IN     VARCHAR2 default null
  ,p_height                        IN     VARCHAR2 default null
  ,p_weight                        IN     VARCHAR2 default null
  ,p_person_extra_info_id          OUT NOCOPY NUMBER
  ,p_object_version_number         OUT NOCOPY NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_in_passport_details >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates passport details extra information for a person.
 *
 * For the extra information type 'IN_PASSPORT_DETAILS', a record is created
 * for the person.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Person must exist. Extra Person Information Type IN_PASSPORT_DETAILS must
 * exist.
 *
 * <p><b>Post Success</b><br>
 * The passport details extra information is created for the person.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the person extra info and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_id Identifies the person for whom you create the extra
 * person information record.
 * @param p_pei_attribute_category Determines context of the pei_attribute
 * descriptive flexfield in parameters
 * @param p_pei_attribute1 Descriptive flexfield segment.
 * @param p_pei_attribute2 Descriptive flexfield segment.
 * @param p_pei_attribute3 Descriptive flexfield segment.
 * @param p_pei_attribute4 Descriptive flexfield segment.
 * @param p_pei_attribute5 Descriptive flexfield segment.
 * @param p_pei_attribute6 Descriptive flexfield segment.
 * @param p_pei_attribute7 Descriptive flexfield segment.
 * @param p_pei_attribute8 Descriptive flexfield segment.
 * @param p_pei_attribute9 Descriptive flexfield segment.
 * @param p_pei_attribute10 Descriptive flexfield segment.
 * @param p_pei_attribute11 Descriptive flexfield segment.
 * @param p_pei_attribute12 Descriptive flexfield segment.
 * @param p_pei_attribute13 Descriptive flexfield segment.
 * @param p_pei_attribute14 Descriptive flexfield segment.
 * @param p_pei_attribute15 Descriptive flexfield segment.
 * @param p_pei_attribute16 Descriptive flexfield segment.
 * @param p_pei_attribute17 Descriptive flexfield segment.
 * @param p_pei_attribute18 Descriptive flexfield segment.
 * @param p_pei_attribute19 Descriptive flexfield segment.
 * @param p_pei_attribute20 Descriptive flexfield segment.
 * @param p_passport_name Name of the person as in Passport
 * @param p_passport_number Passport number of the person
 * @param p_place_of_issue Place of issue of the passport
 * @param p_issue_date Issue Date of the passport
 * @param p_expiry_date Expiry Date of the passport
 * @param p_ecnr_required ECNR Required in the passport. Valid values are
 * defined by 'YES_NO' lookup type.
 * @param p_issuing_country Issuing Country of the passport. Valid values in
 * the FND_TERRITORIES table.
 * @param p_person_extra_info_id If p_validate is false, uniquely identifies
 * the person extra info created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created extra person information. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create Passport Details for India
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_in_passport_details
  (p_validate                      IN     BOOLEAN  default false
  ,p_person_id                     IN     NUMBER
  ,p_pei_attribute_category        IN     VARCHAR2 default null
  ,p_pei_attribute1                IN     VARCHAR2 default null
  ,p_pei_attribute2                IN     VARCHAR2 default null
  ,p_pei_attribute3                IN     VARCHAR2 default null
  ,p_pei_attribute4                IN     VARCHAR2 default null
  ,p_pei_attribute5                IN     VARCHAR2 default null
  ,p_pei_attribute6                IN     VARCHAR2 default null
  ,p_pei_attribute7                IN     VARCHAR2 default null
  ,p_pei_attribute8                IN     VARCHAR2 default null
  ,p_pei_attribute9                IN     VARCHAR2 default null
  ,p_pei_attribute10               IN     VARCHAR2 default null
  ,p_pei_attribute11               IN     VARCHAR2 default null
  ,p_pei_attribute12               IN     VARCHAR2 default null
  ,p_pei_attribute13               IN     VARCHAR2 default null
  ,p_pei_attribute14               IN     VARCHAR2 default null
  ,p_pei_attribute15               IN     VARCHAR2 default null
  ,p_pei_attribute16               IN     VARCHAR2 default null
  ,p_pei_attribute17               IN     VARCHAR2 default null
  ,p_pei_attribute18               IN     VARCHAR2 default null
  ,p_pei_attribute19               IN     VARCHAR2 default null
  ,p_pei_attribute20               IN     VARCHAR2 default null
  ,p_passport_name                 IN     VARCHAR2
  ,p_passport_number               IN     VARCHAR2
  ,p_place_of_issue                IN     VARCHAR2
  ,p_issue_date                    IN     VARCHAR2
  ,p_expiry_date                   IN     VARCHAR2
  ,p_ecnr_required                 IN     VARCHAR2
  ,p_issuing_country               IN     VARCHAR2
  ,p_person_extra_info_id          OUT NOCOPY NUMBER
  ,p_object_version_number         OUT NOCOPY NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_in_person_extra_info >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates miscellaneous extra information for a person.
 *
 * This API updates extra information for the information type
 * 'IN_MISCELLANEOUS' for a given person as identified by the in parameter
 * p_person_extra_info_id and the in out parameter p_object_version_number.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Person must exist. Extra Person Information Type IN_MISCELLANEOUS must
 * exist.
 *
 * <p><b>Post Success</b><br>
 * The miscellaneous extra information is updated for the person.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the person extra info and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_extra_info_id Primary key to identify the person extra
 * information record.
 * @param p_object_version_number Pass in the current version number of the
 * extra person information to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated extra person
 * information. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_pei_attribute_category Determines context of the pei_attribute
 * descriptive flexfield in parameters.
 * @param p_pei_attribute1 Descriptive flexfield segment.
 * @param p_pei_attribute2 Descriptive flexfield segment.
 * @param p_pei_attribute3 Descriptive flexfield segment.
 * @param p_pei_attribute4 Descriptive flexfield segment.
 * @param p_pei_attribute5 Descriptive flexfield segment.
 * @param p_pei_attribute6 Descriptive flexfield segment.
 * @param p_pei_attribute7 Descriptive flexfield segment.
 * @param p_pei_attribute8 Descriptive flexfield segment.
 * @param p_pei_attribute9 Descriptive flexfield segment.
 * @param p_pei_attribute10 Descriptive flexfield segment.
 * @param p_pei_attribute11 Descriptive flexfield segment.
 * @param p_pei_attribute12 Descriptive flexfield segment.
 * @param p_pei_attribute13 Descriptive flexfield segment.
 * @param p_pei_attribute14 Descriptive flexfield segment.
 * @param p_pei_attribute15 Descriptive flexfield segment.
 * @param p_pei_attribute16 Descriptive flexfield segment.
 * @param p_pei_attribute17 Descriptive flexfield segment.
 * @param p_pei_attribute18 Descriptive flexfield segment.
 * @param p_pei_attribute19 Descriptive flexfield segment.
 * @param p_pei_attribute20 Descriptive flexfield segment.
 * @param p_religion Religion of the person.
 * @param p_community Community of the person.
 * @param p_caste_or_tribe Caste or tribe of the person.
 * @param p_height Height of the person.
 * @param p_weight Weight of the person.
 * @rep:displayname Update Miscellaneous Person Extra Information for India
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_in_person_extra_info
  (p_validate                      IN     BOOLEAN  default false
  ,p_person_extra_info_id          IN     NUMBER
  ,p_object_version_number         IN OUT NOCOPY NUMBER
  ,p_pei_attribute_category        IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute1                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute2                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute3                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute4                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute5                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute6                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute7                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute8                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute9                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute10               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute11               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute12               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute13               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute14               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute15               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute16               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute17               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute18               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute19               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute20               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_religion                      IN     VARCHAR2 default hr_api.g_varchar2
  ,p_community                     IN     VARCHAR2 default hr_api.g_varchar2
  ,p_caste_or_tribe                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_height                        IN     VARCHAR2 default hr_api.g_varchar2
  ,p_weight                        IN     VARCHAR2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_in_passport_details >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates passport details extra information for a person.
 *
 * This API updates extra information for the information type
 * 'IN_PASSPORT_DETAILS' for a given person as identified by the in parameter
 * p_person_extra_info_id and the in out parameter p_object_version_number.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Person must exist. Extra Person Information Type IN_PASSPORT_DETAILS must
 * exist.
 *
 * <p><b>Post Success</b><br>
 * The passport details extra information is updated for the person.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the person extra info and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_extra_info_id Primary key to identify the person extra
 * information record.
 * @param p_object_version_number Pass in the current version number of the
 * extra person information to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated extra person
 * information. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_pei_attribute_category Determines context of the pei_attribute
 * descriptive flexfield in parameters.
 * @param p_pei_attribute1 Descriptive flexfield segment.
 * @param p_pei_attribute2 Descriptive flexfield segment.
 * @param p_pei_attribute3 Descriptive flexfield segment.
 * @param p_pei_attribute4 Descriptive flexfield segment.
 * @param p_pei_attribute5 Descriptive flexfield segment.
 * @param p_pei_attribute6 Descriptive flexfield segment.
 * @param p_pei_attribute7 Descriptive flexfield segment.
 * @param p_pei_attribute8 Descriptive flexfield segment.
 * @param p_pei_attribute9 Descriptive flexfield segment.
 * @param p_pei_attribute10 Descriptive flexfield segment.
 * @param p_pei_attribute11 Descriptive flexfield segment.
 * @param p_pei_attribute12 Descriptive flexfield segment.
 * @param p_pei_attribute13 Descriptive flexfield segment.
 * @param p_pei_attribute14 Descriptive flexfield segment.
 * @param p_pei_attribute15 Descriptive flexfield segment.
 * @param p_pei_attribute16 Descriptive flexfield segment.
 * @param p_pei_attribute17 Descriptive flexfield segment.
 * @param p_pei_attribute18 Descriptive flexfield segment.
 * @param p_pei_attribute19 Descriptive flexfield segment.
 * @param p_pei_attribute20 Descriptive flexfield segment.
 * @param p_passport_name Name of the person as in Passport.
 * @param p_passport_number Passport number of the person.
 * @param p_place_of_issue Place of issue of the passport.
 * @param p_issue_date Issue Date of the passport.
 * @param p_expiry_date ECNR Required in the passport. Valid values are defined
 * by 'YES_NO' lookup type.
 * @param p_ecnr_required Issuing Country of the passport. Valid values in the
 * FND_TERRITORIES table.
 * @param p_issuing_country Issuing Country of the passport.
 * @rep:displayname Update Passport Details for India
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_in_passport_details
  (p_validate                      IN     BOOLEAN  default false
  ,p_person_extra_info_id          IN     NUMBER
  ,p_object_version_number         IN OUT NOCOPY NUMBER
  ,p_pei_attribute_category        IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute1                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute2                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute3                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute4                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute5                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute6                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute7                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute8                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute9                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute10               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute11               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute12               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute13               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute14               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute15               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute16               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute17               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute18               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute19               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_pei_attribute20               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_passport_name                 IN     VARCHAR2 default hr_api.g_varchar2
  ,p_passport_number               IN     VARCHAR2 default hr_api.g_varchar2
  ,p_place_of_issue                IN     VARCHAR2 default hr_api.g_varchar2
  ,p_issue_date                    IN     VARCHAR2 default hr_api.g_varchar2
  ,p_expiry_date                   IN     VARCHAR2 default hr_api.g_varchar2
  ,p_ecnr_required                 IN     VARCHAR2 default hr_api.g_varchar2
  ,p_issuing_country               IN     VARCHAR2 default hr_api.g_varchar2
  );


END hr_in_person_extra_info_api;

 

/
