--------------------------------------------------------
--  DDL for Package PAY_ECU_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ECU_API" AUTHID CURRENT_USER as
/* $Header: pyecuapi.pkh 120.2 2005/12/12 23:31:49 pgongada noship $ */
/*#
 * This package contains Element Classification Usages API.
 * @rep:scope public
 * @rep:product PAY
 * @rep:displayname ecu
*/
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Development Use Only             |
-- ----------------------------------------------------------------------------
--
g_api_dml  boolean;                               -- Global api dml status
g_package  varchar2(33) := '  pay_ecu_api.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ele_class_usages >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new Element classification usage.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The Classification, Runtype should exist on the Effective date.
 * The Business Group and Legislation should also exist on the Effective date
 * if they are specified.
 *
 * <p><b>Post Success</b><br>
 * Creates a new Element classification usage.
 *
 * <p><b>Post Failure</b><br>
 * Element classification usage is not created and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Effective date of the Element classification
 * usage to be created.
 * @param p_run_type_id Run type id.
 * @param p_classification_id Element classification id.
 * @param p_business_group_id Business Group of the Element classification
 * usage to be created.
 * @param p_legislation_code Legislation Code of the Element classification
 * usage to be created.
 * @param p_element_class_usage_id If p_validate is false, then set to the
 * newly created Element classification usage id and if p_validate is true,
 * then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * Object version number of the newly created Element classification usage
 * and if p_validate is true, then set to null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * Effective start date of the Element classification usage and if p_validate
 * is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * Effective end date of the Element classification usage and if p_validate
 * is true, then set to null.
 * @rep:displayname HRMS Element Classification
 * @rep:category BUSINESS_ENTITY PAY_ELEMENT_CLASSIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_ELE_CLASS_USAGES
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_run_type_id                   in	  number
  ,p_classification_id             in     number
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_element_class_usage_id        out nocopy   number
  ,p_object_version_number         out nocopy   number
  ,p_effective_start_date          out nocopy   date
  ,p_effective_end_date            out nocopy   date
  );
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ele_class_usages >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an Element classification usage.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The Element classification usage must exist.
 * The Classification, Runtype should exist on the Effective date if specified.
 *
 * <p><b>Post Success</b><br>
 * Updates the specified Element classification usage.
 *
 * <p><b>Post Failure</b><br>
 * Element classification usage is not updated and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Effective date on which the Element
 * classification usage should be updated.
 * @param p_datetrack_mode Date track mode of the update.
 * @param p_run_type_id Run type id.
 * @param p_classification_id Element classification id.
 * @param p_business_group_id Business Group of the Element classification
 * usage.
 * @param p_legislation_code Legislation Code of the Element classification
 * usage.
 * @param p_element_class_usage_id Element classification usage to be
 * updated.
 * @param p_object_version_number Object version number of the Element
 * classification usage to be updated. If p_validate is false, then
 * set to the Object version number of the updated record and if p_validate is
 * true, then set to null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * Effective start date of the Element classification usage and if p_validate
 * is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * Effective end date of the Element classification usage and if p_validate
 * is true, then set to null.
 * @rep:displayname HRMS Element Classification
 * @rep:category BUSINESS_ENTITY PAY_ELEMENT_CLASSIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_ELE_CLASS_USAGES
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_run_type_id                   in	  number   default hr_api.g_number
  ,p_classification_id             in     number   default hr_api.g_number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_element_class_usage_id        in out nocopy   number
  ,p_object_version_number         in out nocopy   number
  ,p_effective_start_date          out    nocopy   date
  ,p_effective_end_date            out    nocopy   date
  );
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_ele_class_usages >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an Element classification usage.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The Element classification usage must exist.
 *
 * <p><b>Post Success</b><br>
 * Deletes the Element classification usage.
 *
 * <p><b>Post Failure</b><br>
 * Element classification usage is not deleted and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Effective date on which the Element
 * classification usage should be updated.
 * @param p_datetrack_mode Date track mode of the delete.
 * @param p_element_class_usage_id Element classification usage to be
 * deleted.
 * @param p_object_version_number Object version number of the Element
 * classification usage to be deleted. If p_validate is false, then set
 * to the Object version number of the deleted record and if p_validate is
 * true, then set to null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * Effective start date of the Element classification usage and if p_validate
 * is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * Effective end date of the Element classification usage and if p_validate
 * is true, then set to null.
 * @rep:displayname HRMS Element Classification
 * @rep:category BUSINESS_ENTITY PAY_ELEMENT_CLASSIFICATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
procedure DELETE_ELE_CLASS_USAGES
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_element_class_usage_id        in     number
  ,p_object_version_number         in out nocopy   number
  ,p_effective_start_date          out    nocopy   date
  ,p_effective_end_date            out    nocopy   date
  );
--
end PAY_ECU_API;

 

/
