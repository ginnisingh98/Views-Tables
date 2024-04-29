--------------------------------------------------------
--  DDL for Package HR_CAGR_ENTITLEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAGR_ENTITLEMENT_API" AUTHID CURRENT_USER AS
/* $Header: pepceapi.pkh 120.2 2006/10/18 09:14:12 grreddy noship $ */
/*#
 * This package contains APIs that maintain entitlements used by collective
 * agreements.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Collective Agreement Entitlement
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_cagr_entitlement >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a collective agreement entitlement.
 *
 * An entitlement is a dated instance of an entitlement item for a specific
 * collective agreement. If the entitlement uses fast formula to calculate its
 * value, then there will not be any child entitlement lines under the
 * entitlement. If the entitlement does not use a fast formula, then there will
 * be one or more entitlement lines (each linked to an eligibility profile).
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The collective agreement and entitlement item must exist.
 *
 * <p><b>Post Success</b><br>
 * The entitlement record is created.
 *
 * <p><b>Post Failure</b><br>
 * The entitlement record is not created and an error is realised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_cagr_entitlement_item_id Uniquely identifies the parent entitlement
 * item.
 * @param p_collective_agreement_id Uniquely identifies the parent collective
 * agreement.
 * @param p_end_date The end date of the entitlement.
 * @param p_status The status of the record. Valid values are defined by the
 * 'CAGR_STATUS' lookup type.
 * @param p_formula_criteria Indicates whether the entitlement's value should
 * be calculated by fast formula or determined from eligibility processing of
 * entitlement lines. Valid values are defined by the 'CAGR_CRITERIA_TYPE'
 * lookup type.
 * @param p_formula_id The fast formula to be used to determine the entitlement
 * value, for a formula based entitlement.
 * @param p_units_of_measure The unit of measure the entitlement value is
 * expressed in. Valid values are defined by the 'UNITS' lookup type.
 * @param p_message_level Identifies whether an error or a warning may be
 * produced during processing of the entitlement. Valid values are defined by
 * the 'CAGR_MESSAGE_LEVEL' lookup type.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created entitlement. If p_validate is true, then the
 * value will be null.
 * @param p_cagr_entitlement_id If p_validate is false, then this uniquely
 * identifies the entitlement created. If p_validate is true, then set to null.
 * @rep:displayname Create Collective Agreement Entitlement
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_cagr_entitlement
  (p_validate                       IN     BOOLEAN   DEFAULT FALSE
  ,p_effective_date                 IN     DATE
  ,p_cagr_entitlement_item_id       IN     NUMBER
  ,p_collective_agreement_id        IN     NUMBER
  ,p_end_date                       IN     DATE      DEFAULT NULL
  ,p_status                         IN     VARCHAR2
  ,p_formula_criteria               IN     VARCHAR2
  ,p_formula_id                     IN     NUMBER    DEFAULT NULL
  ,p_units_of_measure               IN     VARCHAR2  DEFAULT NULL
  ,p_message_level                  IN     VARCHAR2  DEFAULT NULL
  ,p_object_version_number             OUT NOCOPY NUMBER
  ,p_cagr_entitlement_id               OUT NOCOPY NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_cagr_entitlement >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a collective agreement entitlement.
 *
 * An entitlement is a dated instance of an entitlement item for a specific
 * collective agreement. If the entitlement uses a fast formula to calculate
 * its value, then there will not be child entitlement lines under the
 * entitlement. If the entitlement does not use a fast formula, then there will
 * be one or more entitlement lines (each linked to an eligibility profile).
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The entitlement must exist.
 *
 * <p><b>Post Success</b><br>
 * The entitlement is updated.
 *
 * <p><b>Post Failure</b><br>
 * The entitlement is not updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_cagr_entitlement_id Uniquely identifies the entitlement to be
 * updated.
 * @param p_cagr_entitlement_item_id Uniquely identifies the parent entitlement
 * item.
 * @param p_collective_agreement_id Uniquely identifies the parent collective
 * agreement.
 * @param p_status The status of the record. Valid values are defined by the
 * 'CAGR_STATUS' lookup type.
 * @param p_end_date The end date of the entitlement.
 * @param p_formula_criteria Indicates whether the entitlement's value should
 * be calculated by fast formula or determined from eligibility processing of
 * entitlement lines. Valid values are defined by the 'CAGR_CRITERIA_TYPE'
 * lookup type.
 * @param p_formula_id The fast formula to be used to determine the entitlement
 * value, for a formula based entitlement.
 * @param p_units_of_measure The unit of measure the entitlement value is
 * expressed in. Valid values are defined by the 'UNITS' lookup type.
 * @param p_message_level Identifies whether an error or a warning may be
 * produced during processing of the entitlement. Valid values are defined by
 * the 'CAGR_MESSAGE_LEVEL' lookup type.
 * @param p_object_version_number Pass in the current version number of the
 * entitlement to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated entitlement. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Collective Agreement Entitlement
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_cagr_entitlement
  (p_validate                       IN     BOOLEAN   DEFAULT false
  ,p_effective_date                 IN     DATE
  ,p_cagr_entitlement_id            IN     NUMBER    DEFAULT hr_api.g_number
  ,p_cagr_entitlement_item_id       IN     NUMBER    DEFAULT hr_api.g_number
  ,p_collective_agreement_id        IN     NUMBER    DEFAULT hr_api.g_number
  ,p_status                         IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_end_date                       IN     DATE      DEFAULT hr_api.g_date
  ,p_formula_criteria               IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_formula_id                     IN     NUMBER    DEFAULT hr_api.g_number
  ,p_units_of_measure               IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_message_level                  IN     VARCHAR2  DEFAULT hr_api.g_varchar2
  ,p_object_version_number          IN OUT NOCOPY NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_cagr_entitlement >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a collective agreement entitlement.
 *
 * An entitlement is a dated instance of an entitlement item for a specific
 * collective agreement. If the entitlement uses fast formula to calculate its
 * value, then there will not be any child entitlement lines under the
 * entitlement. If the entitlement does not use a fast formula, then there will
 * be one or more entitlement lines (each linked to an eligibility profile).
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The entitlement must exist.
 *
 * <p><b>Post Success</b><br>
 * The entitlement is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The entitlement is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_cagr_entitlement_id Uniquely identifies the entitlement to be
 * deleted.
 * @param p_object_version_number Current version number of the entitlement to
 * be deleted.
 * @rep:displayname Delete Collective Agreement Entitlement
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE delete_cagr_entitlement
  (p_validate              IN     BOOLEAN  DEFAULT false
  ,p_effective_date        IN     DATE
  ,p_cagr_entitlement_id   IN     per_cagr_entitlements.cagr_entitlement_id%TYPE
  ,p_object_version_number IN OUT NOCOPY NUMBER
  );
--
END hr_cagr_entitlement_api;

/
