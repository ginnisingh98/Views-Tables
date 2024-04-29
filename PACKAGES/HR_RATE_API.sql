--------------------------------------------------------
--  DDL for Package HR_RATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RATE_API" AUTHID CURRENT_USER AS
/* $Header: pypyrapi.pkh 120.1 2005/10/02 02:34:02 aroussel $ */
/*#
 * This package contains HR Rate APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Rate
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< create_rate >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates Grade Rates and Grade Scale Rates.
 *
 * Use this API to create two types of Pay Rates: Grade Rates and Pay Scale
 * Rates. Create Grade Rates to enter fixed amounts and ranges for each grade.
 * Create Pay Scale Rates to enter values for each point in a pay scale. In
 * addition to the rate itself, the process automatically creates database
 * items for each pay rate. To create Assignment Rate Types, use the Create
 * Assignment Rate API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Grade for which this rate is created must already exist. The Pay Scale
 * for which this rate is created must already exist.
 *
 * <p><b>Post Success</b><br>
 * The pay rate will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The pay rate will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id The business group under which the pay rate is
 * created.
 * @param p_name Named reference for the pay rate.
 * @param p_rate_type The type of pay rate: Grade or Pay Scale. Valid values
 * are defined by the 'RATE_TYPE' lookup type.
 * @param p_rate_uom The rate's unit of measure (UOM). Valid values are defined
 * by the 'RATE_TYPE' lookup type.
 * @param p_parent_spine_id The pay scale for which this rate is being created.
 * For use when creating rates for a Pay Scale.
 * @param p_comments Comment text.
 * @param p_rate_basis The rate basis associated with the rate. Valid values
 * are defined by the 'RATE_BASIS' lookup type, but rate basis is specific to
 * assignment rates. Use the Assignment Rate APIs instead.
 * @param p_asg_rate_type The assignment rate type associated with the rate.
 * Valid values are defined by the 'PRICE_DIFFERENTIALS' lookup type, but this
 * is specific to assignment rates. Use the Assignment Rate APIs instead.
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
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created pay rate record. If p_validate is true, then
 * the value will be null.
 * @param p_rate_id If p_validate is false, then this uniquely identifies the
 * pay rate created. If p_validate is true, then this is set to null.
 * @rep:displayname Create Rate
 * @rep:category BUSINESS_ENTITY PER_CWK_RATE
 * @rep:category BUSINESS_ENTITY PER_GRADE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_rate
  (p_validate                      IN            BOOLEAN   DEFAULT FALSE
  ,p_effective_date                IN            DATE
  ,p_business_group_id             IN            NUMBER
  ,p_name                          IN            VARCHAR2
  ,p_rate_type                     IN            VARCHAR2
  ,p_rate_uom                      IN            VARCHAR2
  ,p_parent_spine_id               IN            NUMBER   DEFAULT NULL
  ,p_comments                      IN            VARCHAR2 DEFAULT NULL
  ,p_rate_basis                    IN            VARCHAR2 DEFAULT NULL
  ,p_asg_rate_type                 IN            VARCHAR2 DEFAULT NULL
  ,p_attribute_category            IN            VARCHAR2 DEFAULT NULL
  ,p_attribute1                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute2                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute3                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute4                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute5                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute6                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute7                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute8                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute9                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute10                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute11                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute12                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute13                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute14                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute15                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute16                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute17                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute18                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute19                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute20                   IN            VARCHAR2 DEFAULT NULL
  ,p_object_version_number            OUT NOCOPY NUMBER
  ,p_rate_id                          OUT NOCOPY NUMBER);
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< update_rate >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates Grade Rates or Grade Scale Rates.
 *
 * Use this API to update two types of Pay Rates: Grade Rates and Pay Scale
 * Rates. Update Grade Rates to enter fixed amounts and ranges for each grade.
 * Update Pay Scale Rates to enter values for each point in a pay scale. In
 * addition to the rate itself, the process automatically creates/updates
 * database items for each pay rate. To update Assignment Rate Types, use the
 * Update Assignment Rate API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Pay Rate that is being updated must already exist.
 *
 * <p><b>Post Success</b><br>
 * The pay rate will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The pay rate will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_rate_id Uniquely identifies the pay rate that is being updated.
 * @param p_object_version_number Pass in the current version number of the
 * Rate to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated Rate. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_name Named reference for the pay rate.
 * @param p_rate_uom The rate's unit of measure (UOM). Valid values are defined
 * by the 'RATE_TYPE' lookup type.
 * @param p_parent_spine_id The pay scale for which this rate is being created.
 * For use when creating rates for a Pay Scale.
 * @param p_comments Comment text.
 * @param p_rate_basis The rate basis associated with the rate. Valid values
 * are defined by the 'RATE_BASIS' lookup type, but rate basis is specific to
 * assignment rates. Use the Assignment Rate APIs instead.
 * @param p_asg_rate_type The assignment rate type associated with the rate.
 * Valid values are defined by the 'PRICE_DIFFERENTIALS' lookup type, but this
 * is specific to assignment rates. Use the Assignment Rate APIs instead.
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
 * @rep:displayname Update Rate
 * @rep:category BUSINESS_ENTITY PER_CWK_RATE
 * @rep:category BUSINESS_ENTITY PER_GRADE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_rate
  (p_validate                      IN     BOOLEAN   DEFAULT FALSE
  ,p_rate_id                       IN     NUMBER
  ,p_object_version_number         IN OUT NOCOPY NUMBER
  ,p_effective_date                IN     DATE
  ,p_name                          IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_rate_uom                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_parent_spine_id               IN     NUMBER   DEFAULT hr_api.g_number
  ,p_comments                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_rate_basis                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_asg_rate_type                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
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
  ,p_attribute20                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2);
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< delete_rate >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a pay rate.
 *
 * Use this API to delete one of the three types of pay rates (Grade Rates, Pay
 * Scale Rates, and Assignment Rates). The process deletes any database items
 * already created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The rate that is being deleted must already exist.
 *
 * <p><b>Post Success</b><br>
 * The rate will have been deleted.
 *
 * <p><b>Post Failure</b><br>
 * The rate will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_rate_id Uniquely identifies the rate that is being deleted.
 * @param p_rate_type The type of pay rate: Grade or Pay Scale. Valid values
 * are defined by the 'RATE_TYPE' lookup type.
 * @param p_object_version_number Current version number of the Rate to be
 * deleted.
 * @rep:displayname Delete Rate
 * @rep:category BUSINESS_ENTITY PER_CWK_RATE
 * @rep:category BUSINESS_ENTITY PER_GRADE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE delete_rate
  (p_validate                      IN            BOOLEAN  DEFAULT FALSE
  ,p_effective_date                IN            DATE
  ,p_rate_id                       IN            NUMBER
  ,p_rate_type                     IN            VARCHAR2
  ,p_object_version_number         IN OUT NOCOPY NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_assignment_rate >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates Assignment Rate Types.
 *
 * Use this API to define rates for use with contingent worker assignments. In
 * addition to the rate itself, database items are created automatically for
 * each rate type. To create grade rates or pay scale rates, use the Create
 * Rate API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Business Group must already exist. The 'RATE_BASIS' and
 * 'PRICE_DIFFERENTIALS' lookup types must have values.
 *
 * <p><b>Post Success</b><br>
 * The Assignment Rate Type will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The Assignment Rate Type will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id The business group under which the assignment
 * rate will be created.
 * @param p_name Named reference for the Assignment Rate Type.
 * @param p_rate_basis The basis for the Assignment Rate Type, such as Hourly
 * or Weekly. Valid values are defined by the 'RATE_BASIS' lookup type.
 * @param p_asg_rate_type The assignment rate type associated with the rate.
 * Valid values are defined by the 'PRICE_DIFFERENTIALS' lookup type.
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
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created assignment rate record. If p_validate is true,
 * then the value will be null.
 * @param p_rate_id If p_validate is false, uniquely identifies the assignment
 * rate created. If p_validate is true, set to null.
 * @rep:displayname Create Assignment Rate
 * @rep:category BUSINESS_ENTITY PER_CWK_RATE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_assignment_rate
  (p_validate                      IN            BOOLEAN   DEFAULT FALSE
  ,p_effective_date                IN            DATE
  ,p_business_group_id             IN            NUMBER
  ,p_name                          IN            VARCHAR2
  ,p_rate_basis                    IN            VARCHAR2
  ,p_asg_rate_type                 IN            VARCHAR2 DEFAULT NULL
  ,p_attribute_category            IN            VARCHAR2 DEFAULT NULL
  ,p_attribute1                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute2                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute3                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute4                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute5                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute6                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute7                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute8                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute9                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute10                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute11                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute12                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute13                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute14                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute15                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute16                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute17                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute18                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute19                   IN            VARCHAR2 DEFAULT NULL
  ,p_attribute20                   IN            VARCHAR2 DEFAULT NULL
  ,p_object_version_number            OUT NOCOPY NUMBER
  ,p_rate_id                          OUT NOCOPY NUMBER);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_assignment_rate >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates Assignment Rate Types.
 *
 * Use this API to update assignment rate types, which define rates for use
 * with contingent worker assignments. In addition to the rate itself, database
 * items are created automatically for each rate type. To update grade rates or
 * pay scale rates, use the Update Rate API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Assignment Rate Type that is being updated must already exist.
 *
 * <p><b>Post Success</b><br>
 * The Assignment Rate Type will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The Assignment Rate Type will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_rate_id Uniquely identifies the Assignment Rate Type that is being
 * updated.
 * @param p_object_version_number Pass in the current version number of the
 * Assignment Rate to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated Assignment Rate.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_name Named reference for the Assignment Rate Type.
 * @param p_rate_basis The basis for the Assignment Rate Type, for example,
 * Hourly or Weekly. Valid values are defined by the 'RATE_BASIS' lookup type.
 * @param p_asg_rate_type The assignment rate type associated with the rate.
 * Valid values are defined by the 'PRICE_DIFFERENTIALS' lookup type.
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
 * @rep:displayname Update Assignment Rate
 * @rep:category BUSINESS_ENTITY PER_CWK_RATE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_assignment_rate
  (p_validate                      IN     BOOLEAN   DEFAULT FALSE
  ,p_rate_id                       IN     NUMBER
  ,p_object_version_number         IN OUT NOCOPY NUMBER
  ,p_effective_date                IN     DATE
  ,p_name                          IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_rate_basis                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_asg_rate_type                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
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
  ,p_attribute20                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2);
--
END hr_rate_api;

 

/
