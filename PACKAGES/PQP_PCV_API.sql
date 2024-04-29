--------------------------------------------------------
--  DDL for Package PQP_PCV_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PCV_API" AUTHID CURRENT_USER as
/* $Header: pqpcvapi.pkh 120.1 2005/10/02 02:45:10 aroussel $ */
/*#
 * This package contains APIs for configuration values.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Configuration Value
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_configuration_value >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a configuration values record for a particular
 * configuration type.
 *
 * The columns for the configuration values are determined in the flexfield for
 * the configuration type. This is predefined by the product teams. The
 * configuration type definition determines whether there can be multiple rows
 * for a type.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The configuration type and module need to be present in the configuration
 * type and configuration module tables respectively.
 *
 * <p><b>Post Success</b><br>
 * The configuration value record will be created in the table.
 *
 * <p><b>Post Failure</b><br>
 * The configuration value record will be not be created and an error will be
 * raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.BUSINESS_GROUP_ID}
 * @param p_legislation_code {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.LEGISLATION_CODE}
 * @param p_pcv_attribute_category {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE_CATEGORY}
 * @param p_pcv_attribute1 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE1}
 * @param p_pcv_attribute2 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE2}
 * @param p_pcv_attribute3 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE3}
 * @param p_pcv_attribute4 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE4}
 * @param p_pcv_attribute5 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE5}
 * @param p_pcv_attribute6 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE6}
 * @param p_pcv_attribute7 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE7}
 * @param p_pcv_attribute8 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE8}
 * @param p_pcv_attribute9 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE9}
 * @param p_pcv_attribute10 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE10}
 * @param p_pcv_attribute11 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE11}
 * @param p_pcv_attribute12 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE12}
 * @param p_pcv_attribute13 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE13}
 * @param p_pcv_attribute14 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE14}
 * @param p_pcv_attribute15 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE15}
 * @param p_pcv_attribute16 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE16}
 * @param p_pcv_attribute17 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE17}
 * @param p_pcv_attribute18 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE18}
 * @param p_pcv_attribute19 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE19}
 * @param p_pcv_attribute20 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE20}
 * @param p_pcv_information_category {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION_CATEGORY}
 * @param p_pcv_information1 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION1}
 * @param p_pcv_information2 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION2}
 * @param p_pcv_information3 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION3}
 * @param p_pcv_information4 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION4}
 * @param p_pcv_information5 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION5}
 * @param p_pcv_information6 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION6}
 * @param p_pcv_information7 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION7}
 * @param p_pcv_information8 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION8}
 * @param p_pcv_information9 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION9}
 * @param p_pcv_information10 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION10}
 * @param p_pcv_information11 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION11}
 * @param p_pcv_information12 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION12}
 * @param p_pcv_information13 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION13}
 * @param p_pcv_information14 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION14}
 * @param p_pcv_information15 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION15}
 * @param p_pcv_information16 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION16}
 * @param p_pcv_information17 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION17}
 * @param p_pcv_information18 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION18}
 * @param p_pcv_information19 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION19}
 * @param p_pcv_information20 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION20}
 * @param p_configuration_value_id The primary key generated for the
 * configuration value record. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created configuration value. If p_validate is true,
 * then the value will be null.
 * @param p_configuration_name A name to identify the unique row for the
 * configuration values. This is used to identify the row when the
 * configuration category can have more than one row.
 * @rep:displayname Create Configuration Value
 * @rep:category BUSINESS_ENTITY PQP_VEHICLE_REPOSITORY
 * @rep:category BUSINESS_ENTITY PQP_VEHICLE_ALLOCATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_configuration_value
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_legislation_code               in     varchar2 default null
  ,p_pcv_attribute_category         in     varchar2 default null
  ,p_pcv_attribute1                 in     varchar2 default null
  ,p_pcv_attribute2                 in     varchar2 default null
  ,p_pcv_attribute3                 in     varchar2 default null
  ,p_pcv_attribute4                 in     varchar2 default null
  ,p_pcv_attribute5                 in     varchar2 default null
  ,p_pcv_attribute6                 in     varchar2 default null
  ,p_pcv_attribute7                 in     varchar2 default null
  ,p_pcv_attribute8                 in     varchar2 default null
  ,p_pcv_attribute9                 in     varchar2 default null
  ,p_pcv_attribute10                in     varchar2 default null
  ,p_pcv_attribute11                in     varchar2 default null
  ,p_pcv_attribute12                in     varchar2 default null
  ,p_pcv_attribute13                in     varchar2 default null
  ,p_pcv_attribute14                in     varchar2 default null
  ,p_pcv_attribute15                in     varchar2 default null
  ,p_pcv_attribute16                in     varchar2 default null
  ,p_pcv_attribute17                in     varchar2 default null
  ,p_pcv_attribute18                in     varchar2 default null
  ,p_pcv_attribute19                in     varchar2 default null
  ,p_pcv_attribute20                in     varchar2 default null
  ,p_pcv_information_category       in     varchar2 default null
  ,p_pcv_information1               in     varchar2 default null
  ,p_pcv_information2               in     varchar2 default null
  ,p_pcv_information3               in     varchar2 default null
  ,p_pcv_information4               in     varchar2 default null
  ,p_pcv_information5               in     varchar2 default null
  ,p_pcv_information6               in     varchar2 default null
  ,p_pcv_information7               in     varchar2 default null
  ,p_pcv_information8               in     varchar2 default null
  ,p_pcv_information9               in     varchar2 default null
  ,p_pcv_information10              in     varchar2 default null
  ,p_pcv_information11              in     varchar2 default null
  ,p_pcv_information12              in     varchar2 default null
  ,p_pcv_information13              in     varchar2 default null
  ,p_pcv_information14              in     varchar2 default null
  ,p_pcv_information15              in     varchar2 default null
  ,p_pcv_information16              in     varchar2 default null
  ,p_pcv_information17              in     varchar2 default null
  ,p_pcv_information18              in     varchar2 default null
  ,p_pcv_information19              in     varchar2 default null
  ,p_pcv_information20              in     varchar2 default null
  ,p_configuration_value_id            out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_configuration_name             in     varchar2 default null
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_configuration_value >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a configuration values record for a particular
 * configuration type.
 *
 * The columns for the configuration values are determined in the flexfield for
 * the configuration type. This is predefined by the product teams. The
 * configuration type definition determines whether there can be multiple rows
 * for a type.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The configuration type and module need to be present in the configuration
 * type and configuration module tables respectively.
 *
 * <p><b>Post Success</b><br>
 * The configuration value record will be updated in the table.
 *
 * <p><b>Post Failure</b><br>
 * The configuration value record will be not be updated and an error will be
 * raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.BUSINESS_GROUP_ID}
 * @param p_configuration_value_id {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.CONFIGURATION_VALUE_ID}
 * @param p_legislation_code {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.LEGISLATION_CODE}
 * @param p_pcv_attribute_category {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE_CATEGORY}
 * @param p_pcv_attribute1 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE1}
 * @param p_pcv_attribute2 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE2}
 * @param p_pcv_attribute3 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE3}
 * @param p_pcv_attribute4 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE4}
 * @param p_pcv_attribute5 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE5}
 * @param p_pcv_attribute6 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE6}
 * @param p_pcv_attribute7 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE7}
 * @param p_pcv_attribute8 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE8}
 * @param p_pcv_attribute9 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE9}
 * @param p_pcv_attribute10 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE10}
 * @param p_pcv_attribute11 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE11}
 * @param p_pcv_attribute12 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE12}
 * @param p_pcv_attribute13 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE13}
 * @param p_pcv_attribute14 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE14}
 * @param p_pcv_attribute15 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE15}
 * @param p_pcv_attribute16 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE16}
 * @param p_pcv_attribute17 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE17}
 * @param p_pcv_attribute18 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE18}
 * @param p_pcv_attribute19 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE19}
 * @param p_pcv_attribute20 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_ATTRIBUTE20}
 * @param p_pcv_information_category {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION_CATEGORY}
 * @param p_pcv_information1 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION1}
 * @param p_pcv_information2 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION2}
 * @param p_pcv_information3 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION3}
 * @param p_pcv_information4 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION4}
 * @param p_pcv_information5 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION5}
 * @param p_pcv_information6 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION6}
 * @param p_pcv_information7 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION7}
 * @param p_pcv_information8 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION8}
 * @param p_pcv_information9 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION9}
 * @param p_pcv_information10 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION10}
 * @param p_pcv_information11 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION11}
 * @param p_pcv_information12 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION12}
 * @param p_pcv_information13 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION13}
 * @param p_pcv_information14 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION14}
 * @param p_pcv_information15 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION15}
 * @param p_pcv_information16 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION16}
 * @param p_pcv_information17 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION17}
 * @param p_pcv_information18 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION18}
 * @param p_pcv_information19 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION19}
 * @param p_pcv_information20 {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.PCV_INFORMATION20}
 * @param p_object_version_number Pass in the current version number of the
 * configuration value to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated configuration
 * value. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_configuration_name A name to identify the unique row for the
 * configuration values. This is used to identify the row when the
 * configuration category can have more than one row.
 * @rep:displayname Update Configuration Value
 * @rep:category BUSINESS_ENTITY PQP_VEHICLE_REPOSITORY
 * @rep:category BUSINESS_ENTITY PQP_VEHICLE_ALLOCATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_configuration_value
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_configuration_value_id         in     number
  ,p_legislation_code               in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute_category         in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute1                 in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute2                 in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute3                 in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute4                 in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute5                 in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute6                 in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute7                 in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute8                 in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute9                 in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute10                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute11                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute12                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute13                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute14                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute15                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute16                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute17                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute18                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute19                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_attribute20                in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information_category       in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information1               in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information2               in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information3               in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information4               in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information5               in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information6               in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information7               in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information8               in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information9               in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information10              in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information11              in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information12              in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information13              in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information14              in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information15              in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information16              in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information17              in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information18              in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information19              in     varchar2 default hr_api.g_varchar2
  ,p_pcv_information20              in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_configuration_name             in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_configuration_value >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a configuration values record for a particular
 * configuration type.
 *
 * The columns for the configuration values are determined in the flexfield for
 * the configuration type. This is predefined by the product teams. The
 * configuration type definition determines whether there can be multiple rows
 * for a type.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 *
 * <p><b>Post Success</b><br>
 * The configuration value record will be deleted in the table.
 *
 * <p><b>Post Failure</b><br>
 * The configuration value record will be not be deleted and an error will be
 * raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_business_group_id {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.BUSINESS_GROUP_ID}
 * @param p_configuration_value_id {@rep:casecolumn
 * PQP_CONFIGURATION_VALUES.CONFIGURATION_VALUE_ID}
 * @param p_object_version_number Current version number of the configuration
 * value to be deleted.
 * @rep:displayname Delete Configuration Value
 * @rep:category BUSINESS_ENTITY PQP_VEHICLE_REPOSITORY
 * @rep:category BUSINESS_ENTITY PQP_VEHICLE_ALLOCATION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_configuration_value
  (p_validate                       in     boolean  default false
  ,p_business_group_id              in     number
  ,p_configuration_value_id         in     number
  ,p_object_version_number          in     number
  );
--
end pqp_pcv_api;

 

/
