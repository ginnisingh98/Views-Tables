--------------------------------------------------------
--  DDL for Package PER_MEDICAL_ASSESSMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_MEDICAL_ASSESSMENT_API" AUTHID CURRENT_USER as
/* $Header: pemeaapi.pkh 120.2 2005/10/22 01:23:54 aroussel noship $ */
/*#
 * This package contains APIs which create and maintain medical assessment
 * records for a person.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Medical Assessment
*/
 g_package  varchar2(33) := 'per_medical_assessment_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_medical_assessment >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a medical assessment record for a person.
 *
 * A medical assessment collects information about the health and well-being of
 * a person during an examination or consultation with a specific medical
 * practitioner on a specific date. Typically they are carried out to assess
 * the extent of an injury, disease or physical disability. One or more medical
 * assessment can arise as a result of a work incident the person has suffered
 * or a disability that they have.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person for whom the medical assessment is to be created must exist.
 *
 * <p><b>Post Success</b><br>
 * The medical assessment record is created.
 *
 * <p><b>Post Failure</b><br>
 * The medical assessment record is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_person_id Uniquely identifies the person for whom the medical
 * assessment applies.
 * @param p_consultation_date The date of medical assessment is carried out.
 * @param p_consultation_type The type of medical assessment performed. Valid
 * values are defined by the 'CONSULTATION_TYPE' lookup type.
 * @param p_examiner_name The name of the examiner who performed the
 * assessment.
 * @param p_organization_id Uniquely identifies the organization where the
 * medical assessment was performed.
 * @param p_consultation_result The outcome or result of the assessment or
 * consultation . Valid values are defined by the 'CONSULTATION_RESULT' lookup
 * type.
 * @param p_incident_id Uniquely identifies the work incident to which the
 * medical assessment relates.
 * @param p_disability_id Uniquely identifies the disability to which the
 * medical assessment relates.
 * @param p_next_consultation_date The date of the next consultation.
 * @param p_description Description text.
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_mea_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_mea_information1 Developer Descriptive flexfield segment.
 * @param p_mea_information2 Developer Descriptive flexfield segment.
 * @param p_mea_information3 Developer Descriptive flexfield segment.
 * @param p_mea_information4 Developer Descriptive flexfield segment.
 * @param p_mea_information5 Developer Descriptive flexfield segment.
 * @param p_mea_information6 Developer Descriptive flexfield segment.
 * @param p_mea_information7 Developer Descriptive flexfield segment.
 * @param p_mea_information8 Developer Descriptive flexfield segment.
 * @param p_mea_information9 Developer Descriptive flexfield segment.
 * @param p_mea_information10 Developer Descriptive flexfield segment.
 * @param p_mea_information11 Developer Descriptive flexfield segment.
 * @param p_mea_information12 Developer Descriptive flexfield segment.
 * @param p_mea_information13 Developer Descriptive flexfield segment.
 * @param p_mea_information14 Developer Descriptive flexfield segment.
 * @param p_mea_information15 Developer Descriptive flexfield segment.
 * @param p_mea_information16 Developer Descriptive flexfield segment.
 * @param p_mea_information17 Developer Descriptive flexfield segment.
 * @param p_mea_information18 Developer Descriptive flexfield segment.
 * @param p_mea_information19 Developer Descriptive flexfield segment.
 * @param p_mea_information20 Developer Descriptive flexfield segment.
 * @param p_mea_information21 Developer Descriptive flexfield segment.
 * @param p_mea_information22 Developer Descriptive flexfield segment.
 * @param p_mea_information23 Developer Descriptive flexfield segment.
 * @param p_mea_information24 Developer Descriptive flexfield segment.
 * @param p_mea_information25 Developer Descriptive flexfield segment.
 * @param p_mea_information26 Developer Descriptive flexfield segment.
 * @param p_mea_information27 Developer Descriptive flexfield segment.
 * @param p_mea_information28 Developer Descriptive flexfield segment.
 * @param p_mea_information29 Developer Descriptive flexfield segment.
 * @param p_mea_information30 Developer Descriptive flexfield segment.
 * @param p_medical_assessment_id If p_validate is false, uniquely identifies
 * the medical assessment created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created medical assessment. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Medical Assessment
 * @rep:category BUSINESS_ENTITY PER_MEDICAL_ASSESSMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_medical_assessment
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date                IN     DATE
  ,p_person_id                     IN     NUMBER
  ,p_consultation_date             IN     DATE
  ,p_consultation_type             IN     VARCHAR2
  ,p_examiner_name                 IN     VARCHAR2 DEFAULT NULL
  ,p_organization_id               IN     NUMBER   DEFAULT NULL
  ,p_consultation_result           IN     VARCHAR2 DEFAULT NULL
  ,p_incident_id                   IN     NUMBER   DEFAULT NULL
  ,p_disability_id                 IN     NUMBER   DEFAULT NULL
  ,p_next_consultation_date        IN     DATE     DEFAULT NULL
  ,p_description                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute_category            IN     VARCHAR2 DEFAULT NULL
  ,p_attribute1                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute2                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute3                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute4                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute5                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute6                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute7                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute8                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute9                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute10                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute11                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute12                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute13                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute14                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute15                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute16                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute17                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute18                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute19                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute20                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute21                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute22                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute23                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute24                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute25                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute26                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute27                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute28                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute29                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute30                   IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information_category      IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information1              IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information2              IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information3              IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information4              IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information5              IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information6              IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information7              IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information8              IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information9              IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information10             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information11             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information12             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information13             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information14             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information15             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information16             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information17             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information18             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information19             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information20             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information21             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information22             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information23             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information24             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information25             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information26             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information27             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information28             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information29             IN     VARCHAR2 DEFAULT NULL
  ,p_mea_information30             IN     VARCHAR2 DEFAULT NULL
  ,p_medical_assessment_id            OUT NOCOPY NUMBER
  ,p_object_version_number            OUT NOCOPY NUMBER);
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_medical_assessment >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a medical assessment record for a person.
 *
 * A medical assessment collects information about the health and well-being of
 * a person during an examination or consultation with a specific medical
 * practitioner on a specific date. Typically they are carried out to assess
 * the extent of an injury, disease or physical disability. One or more medical
 * assessment can arise as a result of a work incident the person has suffered
 * or a disability that they have.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The medical assessment to be updated must exist.
 *
 * <p><b>Post Success</b><br>
 * The medical assessment is updated.
 *
 * <p><b>Post Failure</b><br>
 * The medical assessment is not updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_medical_assessment_id Uniquely identifies the medical assessment to
 * be updated.
 * @param p_object_version_number Pass in the current version number of the
 * medical assessment to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated medical
 * assessment. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_consultation_date The date of medical assessment is carried out.
 * @param p_consultation_type The type of medical assessment performed. Valid
 * values are defined by the 'CONSULTATION_TYPE' lookup type.
 * @param p_examiner_name The name of the examiner who performed the
 * assessment.
 * @param p_organization_id Uniquely identifies the organization where the
 * medical assessment was performed.
 * @param p_consultation_result The outcome or result of the assessment or
 * consultation . Valid values are defined by the 'CONSULTATION_RESULT' lookup
 * type.
 * @param p_incident_id Uniquely identifies the work incident to which the
 * medical assessment relates.
 * @param p_disability_id Uniquely identifies the disability to which the
 * medical assessment relates.
 * @param p_next_consultation_date The date of the next consultation.
 * @param p_description Description text.
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_mea_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_mea_information1 Developer Descriptive flexfield segment.
 * @param p_mea_information2 Developer Descriptive flexfield segment.
 * @param p_mea_information3 Developer Descriptive flexfield segment.
 * @param p_mea_information4 Developer Descriptive flexfield segment.
 * @param p_mea_information5 Developer Descriptive flexfield segment.
 * @param p_mea_information6 Developer Descriptive flexfield segment.
 * @param p_mea_information7 Developer Descriptive flexfield segment.
 * @param p_mea_information8 Developer Descriptive flexfield segment.
 * @param p_mea_information9 Developer Descriptive flexfield segment.
 * @param p_mea_information10 Developer Descriptive flexfield segment.
 * @param p_mea_information11 Developer Descriptive flexfield segment.
 * @param p_mea_information12 Developer Descriptive flexfield segment.
 * @param p_mea_information13 Developer Descriptive flexfield segment.
 * @param p_mea_information14 Developer Descriptive flexfield segment.
 * @param p_mea_information15 Developer Descriptive flexfield segment.
 * @param p_mea_information16 Developer Descriptive flexfield segment.
 * @param p_mea_information17 Developer Descriptive flexfield segment.
 * @param p_mea_information18 Developer Descriptive flexfield segment.
 * @param p_mea_information19 Developer Descriptive flexfield segment.
 * @param p_mea_information20 Developer Descriptive flexfield segment.
 * @param p_mea_information21 Developer Descriptive flexfield segment.
 * @param p_mea_information22 Developer Descriptive flexfield segment.
 * @param p_mea_information23 Developer Descriptive flexfield segment.
 * @param p_mea_information24 Developer Descriptive flexfield segment.
 * @param p_mea_information25 Developer Descriptive flexfield segment.
 * @param p_mea_information26 Developer Descriptive flexfield segment.
 * @param p_mea_information27 Developer Descriptive flexfield segment.
 * @param p_mea_information28 Developer Descriptive flexfield segment.
 * @param p_mea_information29 Developer Descriptive flexfield segment.
 * @param p_mea_information30 Developer Descriptive flexfield segment.
 * @rep:displayname Update Medical Assessment
 * @rep:category BUSINESS_ENTITY PER_MEDICAL_ASSESSMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_medical_assessment
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_medical_assessment_id         IN     NUMBER
  ,p_object_version_number         IN OUT NOCOPY NUMBER
  ,p_effective_date                IN     DATE
  ,p_consultation_date             IN     DATE     DEFAULT hr_api.g_date
  ,p_consultation_type             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_examiner_name                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_organization_id               IN     NUMBER   DEFAULT hr_api.g_number
  ,p_consultation_result           IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_incident_id                   IN     NUMBER   DEFAULT hr_api.g_number
  ,p_disability_id                 IN     NUMBER   DEFAULT hr_api.g_number
  ,p_next_consultation_date        IN     DATE     DEFAULT hr_api.g_date
  ,p_description                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute_category            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute1                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute2                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute3                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute4                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute5                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute6                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute7                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute8                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute9                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute10                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute11                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute12                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute13                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute14                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute15                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute16                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute17                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute18                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute19                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute20                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute21                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute22                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute23                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute24                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute25                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute26                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute27                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute28                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute29                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_attribute30                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information_category      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information1              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information2              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information3              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information4              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information5              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information6              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information7              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information8              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information9              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information10             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information11             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information12             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information13             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information14             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information15             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information16             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information17             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information18             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information19             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information20             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information21             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information22             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information23             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information24             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information25             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information26             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information27             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information28             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information29             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_mea_information30             IN     VARCHAR2 DEFAULT hr_api.g_varchar2 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_medical_assessment >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a medical assessment record for a person.
 *
 * A medical assessment collects information about the health and well-being of
 * a person during an examination or consultation with a specific medical
 * practitioner on a specific date. Typically they are carried out to assess
 * the extent of an injury, disease or physical disability. One or more medical
 * assessment can arise as a result of a work incident the person has suffered
 * or a disability that they have.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The medical assessment to be deleted must exist.
 *
 * <p><b>Post Success</b><br>
 * The medical assessment is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The medical assessment is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_medical_assessment_id Uniquely identifies the medical assessment to
 * be deleted.
 * @param p_object_version_number Current version number of the medical
 * assessment to be deleted.
 * @rep:displayname Delete Medical Assessment
 * @rep:category BUSINESS_ENTITY PER_MEDICAL_ASSESSMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE delete_medical_assessment
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_medical_assessment_id         IN     NUMBER
  ,p_object_version_number         IN     NUMBER
  );
--
END per_medical_assessment_api;

 

/
