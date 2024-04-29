--------------------------------------------------------
--  DDL for Package HR_RATE_VALUES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RATE_VALUES_API" AUTHID CURRENT_USER AS
/* $Header: pypgrapi.pkh 120.1 2005/10/02 02:32:48 aroussel $ */
/*#
 * This package contains APIs to create and maintain Grade Rate Values and
 * Grade Scale Rate Values.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Rate Value
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_rate_value >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates Grade Rate Values and Grade Scale Rate Values.
 *
 * To create Assignment Rate Values, use the Create Assignment Rate Value API.
 * To create Grade Rate Values, use the Create Grade Rate Value API. To create
 * Pay Rate Values, use the Create Pay Scale Value API. This API is now
 * out-of-date however it has been provided to you for backward compatibility
 * support and will be removed in the future. Oracle recommends you to modify
 * existing calling programs in advance of the support being withdrawn thus
 * avoiding any
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Pay Rate, Grade and Pay Scale must already exist.
 *
 * <p><b>Post Success</b><br>
 * The Rate Value will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The Rate Value will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_business_group_id The business group under which the pay rate will
 * be created.
 * @param p_rate_id Uniquely identifies the pay rate to which this rate value
 * belongs.
 * @param p_grade_or_spinal_point_id Uniquely identifies the grade (for direct
 * grade compensation relationships), or uniquely identifies the Pay Scale (for
 * indirect grade compensation relationships).
 * @param p_rate_type The type of pay rate value: Grade Rate Value or Grade
 * Scale Rate Value. Valid values are defined by the 'RATE_TYPE' lookup type.
 * @param p_currency_code The currency of the rate value.
 * @param p_maximum The maximum allowable rate value.
 * @param p_mid_value The mid-range rate value.
 * @param p_minimum The minimum allowable rate value.
 * @param p_sequence The sequence of this rate value in relation to other rate
 * values within the pay rate.
 * @param p_value The actual rate for this grade or pay scale.
 * @param p_grade_rule_id If p_validate is false, then this uniquely identifies
 * the Rate Value. If p_validate is true, then this is set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Rate Value record. If p_validate is true, then
 * the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created Rate Value. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created Rate Value. If p_validate is true, then
 * set to null.
 * @rep:displayname Create Rate Value
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
PROCEDURE create_rate_value
  (p_validate                 IN     BOOLEAN       DEFAULT FALSE
  ,p_effective_date           IN     DATE
  ,p_business_group_id        IN     NUMBER
  ,p_rate_id                  IN     NUMBER
  ,p_grade_or_spinal_point_id IN     NUMBER
  ,p_rate_type                IN     VARCHAR2
  ,p_currency_code            IN     VARCHAR2      DEFAULT NULL
  ,p_maximum                  IN     VARCHAR2      DEFAULT NULL
  ,p_mid_value                IN     VARCHAR2      DEFAULT NULL
  ,p_minimum                  IN     VARCHAR2      DEFAULT NULL
  ,p_sequence                 IN     NUMBER        DEFAULT NULL
  ,p_value                    IN     VARCHAR2      DEFAULT NULL
  ,p_grade_rule_id               OUT NOCOPY NUMBER
  ,p_object_version_number       OUT NOCOPY NUMBER
  ,p_effective_start_date        OUT NOCOPY DATE
  ,p_effective_end_date          OUT NOCOPY DATE);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_rate_value >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates Grade Rate Values and Grade Scale Rate Values.
 *
 * To update Assignment Rate Values, use the Update Assignment Rate Value API.
 * To update Grade Rate Values, use the Update Grade Rate Value API. To update
 * Pay Rate Values, use the Update Pay Scale Value API. This API is now
 * out-of-date however it has been provided to you for backward compatibility
 * support and will be removed in the future. Oracle recommends you to modify
 * existing calling programs in advance of the support being withdrawn thus
 * avoiding any potential disruption.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Rate Value that is being updated must already exist.
 *
 * <p><b>Post Success</b><br>
 * The Rate Value will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The Rate Value will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_grade_rule_id Uniquely identifies the Rate Value that is being
 * updated.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_currency_code The currency of the rate value.
 * @param p_maximum The maximum allowable rate value.
 * @param p_mid_value The mid-range rate value.
 * @param p_minimum The minimum allowable rate value.
 * @param p_sequence The sequence of this rate value in relation to other rate
 * values within the pay rate.
 * @param p_value The actual rate for this grade or pay scale.
 * @param p_object_version_number Pass in the current version number of the
 * Rate Value to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated Rate Value. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated Rate Value row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated Rate Value row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Rate Value
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
PROCEDURE update_rate_value
  (p_validate                 IN     BOOLEAN       DEFAULT FALSE
  ,p_grade_rule_id            IN     NUMBER
  ,p_effective_date           IN     DATE
  ,p_datetrack_mode           IN     VARCHAR2
  ,p_currency_code            IN     VARCHAR2      DEFAULT hr_api.g_varchar2
  ,p_maximum                  IN     VARCHAR2      DEFAULT hr_api.g_varchar2
  ,p_mid_value                IN     VARCHAR2      DEFAULT hr_api.g_varchar2
  ,p_minimum                  IN     VARCHAR2      DEFAULT hr_api.g_varchar2
  ,p_sequence                 IN     NUMBER        DEFAULT hr_api.g_number
  ,p_value                    IN     VARCHAR2      DEFAULT hr_api.g_varchar2
  ,p_object_version_number    IN OUT NOCOPY NUMBER
  ,p_effective_start_date        OUT NOCOPY DATE
  ,p_effective_end_date          OUT NOCOPY DATE);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_rate_value >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes Grade Rate Values and Grade Scale Rate Values.
 *
 * To delete Assignment Rate Values, use the Delete Assignment Rate Value API.
 * To delete Grade Rate Values, use the Delete Grade Rate Value API. To delete
 * Pay Rate Values, use the Delete Pay Scale Value API. This API is now
 * out-of-date however it has been provided to you for backward compatibility
 * support and will be removed in the future. Oracle recommends you to modify
 * existing calling programs in advance of the support being withdrawn thus
 * avoiding any potential disruption.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Rate Value that is being deleted must already exist.
 *
 * <p><b>Post Success</b><br>
 * The Rate Value will have been deleted.
 *
 * <p><b>Post Failure</b><br>
 * The Rate Value will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_grade_rule_id Uniquely identifies the Rate Value that is being
 * deleted.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when deleting
 * the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_object_version_number Current version number of the Rate Value to
 * be deleted.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted Rate Value row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted Rate Value row which now exists as of the
 * effective date. If p_validate is true or all row instances have been deleted
 * then set to null.
 * @rep:displayname Delete Rate Value
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
PROCEDURE delete_rate_value
  (p_validate                       IN     BOOLEAN  DEFAULT FALSE
  ,p_grade_rule_id                  IN     NUMBER
  ,p_datetrack_mode                 IN     VARCHAR2
  ,p_effective_date                 IN     DATE
  ,p_object_version_number          IN OUT NOCOPY NUMBER
  ,p_effective_start_date              OUT NOCOPY DATE
  ,p_effective_end_date                OUT NOCOPY DATE
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_assignment_rate_value >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates Assignment Rate Values.
 *
 * Use this API to create Assignment Rate Values, (rates for a particular
 * contingent worker assignment).
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Assignment Rate Type must already exist. The assignment must be
 * effective and must be a contingent worker assignment.
 *
 * <p><b>Post Success</b><br>
 * The assignment rate value will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The assignment rate value will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_business_group_id The business group under which the assignment
 * rate will be created.
 * @param p_rate_id Uniquely identifies the assignment rate type to which this
 * rate value belongs.
 * @param p_assignment_id Uniquely identifies the assignment for which you
 * create the Assignment Rate Value record.
 * @param p_rate_type The type of pay rate value. This should be 'A' for
 * Assignment; valid values are defined by the 'RATE_TYPE' lookup type.
 * @param p_currency_code The currency of the rate value.
 * @param p_value The actual rate paid to this Assignment.
 * @param p_grade_rule_id If p_validate is false, then this uniquely identifies
 * the Assignment Rate Type. If p_validate is true, then this is set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Assignment Rate Value record. If p_validate is
 * true, then the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created Assignment Rate Value. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created Assignment Rate Value. If p_validate is
 * true, then set to null.
 * @rep:displayname Create Assignment Rate Value
 * @rep:category BUSINESS_ENTITY PER_CWK_RATE
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_assignment_rate_value
  (p_validate                 IN     BOOLEAN       DEFAULT FALSE
  ,p_effective_date           IN     DATE
  ,p_business_group_id        IN     NUMBER
  ,p_rate_id                  IN     NUMBER
  ,p_assignment_id            IN     NUMBER
  ,p_rate_type                IN     VARCHAR2
  ,p_currency_code            IN     VARCHAR2      DEFAULT NULL
  ,p_value                    IN     VARCHAR2
  ,p_grade_rule_id               OUT NOCOPY NUMBER
  ,p_object_version_number       OUT NOCOPY NUMBER
  ,p_effective_start_date        OUT NOCOPY DATE
  ,p_effective_end_date          OUT NOCOPY DATE);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_assignment_rate_value >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates Assignment Rate Values.
 *
 * Use this API to update Assignment Rate Values (rates for a particular
 * contingent worker assignment). Assignment rates are date tracked so you can
 * maintain a history of rates.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Rate Value that is being updated must already exist.
 *
 * <p><b>Post Success</b><br>
 * The Rate Value will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The Rate Value will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_grade_rule_id Uniquely identifies the Rate Value that is being
 * updated.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_currency_code The currency of the rate value.
 * @param p_value The actual rate paid to this Assignment.
 * @param p_object_version_number Pass in the current version number of the
 * Rate Value to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated Rate Value. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated Rate Value row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated Rate Value row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Assignment Rate Value
 * @rep:category BUSINESS_ENTITY PER_CWK_RATE
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_assignment_rate_value
  (p_validate                 IN     BOOLEAN       DEFAULT FALSE
  ,p_grade_rule_id            IN     NUMBER
  ,p_effective_date           IN     DATE
  ,p_datetrack_mode           IN     VARCHAR2
  ,p_currency_code            IN     VARCHAR2      DEFAULT hr_api.g_varchar2
  ,p_value                    IN     VARCHAR2      DEFAULT hr_api.g_varchar2
  ,p_object_version_number    IN OUT NOCOPY NUMBER
  ,p_effective_start_date        OUT NOCOPY DATE
  ,p_effective_end_date          OUT NOCOPY DATE);
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_grade_rule_id                Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_validation_start_date        Yes      Derived Effective Start Date.
--   p_validation_end_date          Yes      Derived Effective End Date.
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
PROCEDURE lck
  (p_grade_rule_id               IN     NUMBER
  ,p_object_version_number       IN     NUMBER
  ,p_effective_date              IN     DATE
  ,p_datetrack_mode              IN     VARCHAR2
  ,p_validation_start_date          OUT NOCOPY DATE
  ,p_validation_end_date            OUT NOCOPY DATE );
--
END hr_rate_values_api;

 

/
