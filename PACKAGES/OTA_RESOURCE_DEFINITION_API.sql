--------------------------------------------------------
--  DDL for Package OTA_RESOURCE_DEFINITION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_RESOURCE_DEFINITION_API" AUTHID CURRENT_USER as
/* $Header: ottsrapi.pkh 120.3 2006/08/04 10:43:59 niarora noship $ */
/*#
 * This package contains Resource definition section APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Resource Definition
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_resource_definition >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the Resource Definition.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * Business group record must exist.
 *
 * <p><b>Post Success</b><br>
 * The Resource Definition is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a Resource Definition record and raises an error.
 *
 * @param p_supplied_resource_id The unique identifier for the Resource definition.
 * @param p_vendor_id The vendor.
 * @param p_business_group_id The business group owning the Resource definition.
 * @param p_resource_definition_id The foreign key of the OTA_RESOURCE_DEFINITIONS.
 * @param p_consumable_flag The warn-if-overlapping-booking flag.
 * Permissible values Y and N.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Resource Definition. If p_validate is true,
 * then the value will be null.
 * @param p_resource_type The resource type of the resource.
 * @param p_start_date Start date of a resource.
 * If p_validate is true, then set to null.
 * @param p_comments Comment text.
 * @param p_cost The cost associated with the resource.
 * @param p_cost_unit The rate of charge of the resource.
 * @param p_currency_code The currency for the rate of the charge of the resource.
 * @param p_end_date End date of a resource.
 * @param p_internal_address_line The further address detail relating to
 * a location.
 * @param p_lead_time The normal lead time when hiring from this supplier.
 * Days (99.99).
 * @param p_name  The name of the resource.
 * @param p_supplier_reference The name by which the supplier will recognize
 * this resource.
 * @param p_tsr_information_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
 * @param p_tsr_information1   Descriptive flexfield segment.
 * @param p_tsr_information2   Descriptive flexfield segment.
 * @param p_tsr_information3   Descriptive flexfield segment.
 * @param p_tsr_information4   Descriptive flexfield segment.
 * @param p_tsr_information5   Descriptive flexfield segment.
 * @param p_tsr_information6   Descriptive flexfield segment.
 * @param p_tsr_information7   Descriptive flexfield segment.
 * @param p_tsr_information8   Descriptive flexfield segment.
 * @param p_tsr_information9   Descriptive flexfield segment.
 * @param p_tsr_information10  Descriptive flexfield segment.
 * @param p_tsr_information11  Descriptive flexfield segment.
 * @param p_tsr_information12  Descriptive flexfield segment.
 * @param p_tsr_information13  Descriptive flexfield segment.
 * @param p_tsr_information14  Descriptive flexfield segment.
 * @param p_tsr_information15  Descriptive flexfield segment.
 * @param p_tsr_information16  Descriptive flexfield segment.
 * @param p_tsr_information17  Descriptive flexfield segment.
 * @param p_tsr_information18  Descriptive flexfield segment.
 * @param p_tsr_information19  Descriptive flexfield segment.
 * @param p_tsr_information20  Descriptive flexfield segment.
 * @param p_training_center_id The Training center of the resource.
 * @param p_location_id The Location associated to the resource.
 * @param p_trainer_id The trainer associated to the resource.
 * @param p_special_instruction Special Instruction.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating that lookup values
 * are applicable during the start to end active date range. This date does
 * not determine when the changes take effect.
 * @param p_data_source Obsolete.
 * @rep:displayname Create Resource Definition
 * @rep:category BUSINESS_ENTITY OTA_RESOURCE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure CREATE_RESOURCE_DEFINITION
  (  p_supplied_resource_id          out nocopy number
  ,p_vendor_id                    in number
  ,p_business_group_id            in number
  ,p_resource_definition_id       in number
  ,p_consumable_flag              in varchar2 default null
  ,p_object_version_number        out nocopy number
  ,p_resource_type                in varchar2 default null
  ,p_start_date                   in date default null
  ,p_comments                     in varchar2 default null
  ,p_cost                         in number
  ,p_cost_unit                    in varchar2 default null
  ,p_currency_code                in varchar2 default null
  ,p_end_date                     in date default null
  ,p_internal_address_line        in varchar2 default null
  ,p_lead_time                    in number
  ,p_name                         in varchar2 default null
  ,p_supplier_reference           in varchar2 default null
  ,p_tsr_information_category     in varchar2 default null
  ,p_tsr_information1             in varchar2 default null
  ,p_tsr_information2             in varchar2 default null
  ,p_tsr_information3             in varchar2 default null
  ,p_tsr_information4             in varchar2 default null
  ,p_tsr_information5             in varchar2 default null
  ,p_tsr_information6             in varchar2 default null
  ,p_tsr_information7             in varchar2 default null
  ,p_tsr_information8             in varchar2 default null
  ,p_tsr_information9             in varchar2 default null
  ,p_tsr_information10            in varchar2 default null
  ,p_tsr_information11            in varchar2 default null
  ,p_tsr_information12            in varchar2 default null
  ,p_tsr_information13            in varchar2 default null
  ,p_tsr_information14            in varchar2 default null
  ,p_tsr_information15            in varchar2 default null
  ,p_tsr_information16            in varchar2 default null
  ,p_tsr_information17            in varchar2 default null
  ,p_tsr_information18            in varchar2 default null
  ,p_tsr_information19            in varchar2 default null
  ,p_tsr_information20            in varchar2 default null
  ,p_training_center_id           in number
  ,p_location_id	          in number
  ,p_trainer_id                   in number
  ,p_special_instruction          in varchar2 default null
  ,p_validate                     in boolean
  ,p_effective_date               in date
  ,p_data_source                  in varchar2 default null
  );
  --
  -- ----------------------------------------------------------------------------
  -- |------------------------< update_resource_definition >--------------------|
  -- ----------------------------------------------------------------------------
  --
  -- {Start Of Comments}
  /*#
   * This API updates the Resource Definition.
   *
   *
   * <p><b>Licensing</b><br>
   * This API is licensed for use with Learning Management.
   *
   * <p><b>Prerequisites</b><br>
   * Resource definition with the given object version number should exist.
   *
   * <p><b>Post Success</b><br>
   * The Resource Definition is updated successfully.
   *
   * <p><b>Post Failure</b><br>
   * The API does not update a Resource Definition record, and raises an error.
   *
   * @param p_supplied_resource_id The unique identifier for the Resource definition.
   * @param p_vendor_id The vendor.
   * @param p_business_group_id The business group owning the Resource definition.
   * @param p_resource_definition_id The foreign key of the OTA_RESOURCE_DEFINITIONS.
   * @param p_consumable_flag The warn-if-overlapping-booking flag.
   * Permissible values Y and N.
   * @param p_object_version_number If p_validate is false, then set to
   * the version number of the created Resource Definition. If p_validate
   * is true, then the value will be null.
   * @param p_resource_type The resource type of the resource.
   * @param p_start_date Start date of a resource.
   * @param p_comments Comment text.
   * @param p_cost The cost associated with the resource.
   * @param p_cost_unit The rate of charge of the resource.
   * @param p_currency_code The currency for the rate of the charge
   * of the resource.
   * @param p_end_date End date of a resource.
   * If p_validate is true, then set to null.
   * @param p_internal_address_line The further address detail relating
   * to a location.
   * @param p_lead_time The normal lead time when hiring from this supplier.
   * Days (99.99).
   * @param p_name The name of the resource.
   * @param p_supplier_reference The name by which the supplier will
   * recognize this resource.
   * @param p_tsr_information_category This context value determines
   * which flexfield structure to use with the descriptive flexfield segments.
   * @param p_tsr_information1  Descriptive flexfield segment.
   * @param p_tsr_information2  Descriptive flexfield segment.
   * @param p_tsr_information3  Descriptive flexfield segment.
   * @param p_tsr_information4  Descriptive flexfield segment.
   * @param p_tsr_information5  Descriptive flexfield segment.
   * @param p_tsr_information6  Descriptive flexfield segment.
   * @param p_tsr_information7  Descriptive flexfield segment.
   * @param p_tsr_information8  Descriptive flexfield segment.
   * @param p_tsr_information9  Descriptive flexfield segment.
   * @param p_tsr_information10 Descriptive flexfield segment.
   * @param p_tsr_information11 Descriptive flexfield segment.
   * @param p_tsr_information12 Descriptive flexfield segment.
   * @param p_tsr_information13 Descriptive flexfield segment.
   * @param p_tsr_information14 Descriptive flexfield segment.
   * @param p_tsr_information15 Descriptive flexfield segment.
   * @param p_tsr_information16 Descriptive flexfield segment.
   * @param p_tsr_information17 Descriptive flexfield segment.
   * @param p_tsr_information18 Descriptive flexfield segment.
   * @param p_tsr_information19 Descriptive flexfield segment.
   * @param p_tsr_information20 Descriptive flexfield segment.
   * @param p_training_center_id The Training center of the resource.
   * @param p_location_id The location associated to the resource.
   * @param p_trainer_id The trainer associated to the resource.
   * @param p_special_instruction Special Instruction.
   * @param p_validate If true, then validation alone will be performed and the
   * database will remain unchanged. If false and all validation checks pass,
   * then the database will be modified.
   * @param p_effective_date Reference date for validating that lookup values
   * are applicable during the start to end active date range. This date does
   * not determine when the changes take effect.
   * @param p_data_source Obsolete.
   * @rep:displayname Update Resource Definition
   * @rep:category BUSINESS_ENTITY OTA_RESOURCE
   * @rep:lifecycle active
   * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
   * @rep:scope public
   * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
  */
  --
  -- {End Of Comments}
  --

procedure UPDATE_RESOURCE_DEFINITION
  (p_supplied_resource_id          in number
  ,p_vendor_id                    in number
  ,p_business_group_id            in number
  ,p_resource_definition_id       in number
  ,p_consumable_flag              in varchar2
  ,p_object_version_number        in out nocopy number
  ,p_resource_type                in varchar2
  ,p_start_date                   in date default hr_api.g_date
  ,p_comments                     in varchar2
  ,p_cost                         in number
  ,p_cost_unit                    in varchar2
  ,p_currency_code                in varchar2
  ,p_end_date                     in date default hr_api.g_date
  ,p_internal_address_line        in varchar2
  ,p_lead_time                    in number
  ,p_name                         in varchar2
  ,p_supplier_reference           in varchar2
  ,p_tsr_information_category     in varchar2
  ,p_tsr_information1             in varchar2
  ,p_tsr_information2             in varchar2
  ,p_tsr_information3             in varchar2
  ,p_tsr_information4             in varchar2
  ,p_tsr_information5             in varchar2
  ,p_tsr_information6             in varchar2
  ,p_tsr_information7             in varchar2
  ,p_tsr_information8             in varchar2
  ,p_tsr_information9             in varchar2
  ,p_tsr_information10            in varchar2
  ,p_tsr_information11            in varchar2
  ,p_tsr_information12            in varchar2
  ,p_tsr_information13            in varchar2
  ,p_tsr_information14            in varchar2
  ,p_tsr_information15            in varchar2
  ,p_tsr_information16            in varchar2
  ,p_tsr_information17            in varchar2
  ,p_tsr_information18            in varchar2
  ,p_tsr_information19            in varchar2
  ,p_tsr_information20            in varchar2
  ,p_training_center_id           in number
  ,p_location_id	          in number
  ,p_trainer_id                   in number
  ,p_special_instruction          in varchar2
  ,p_validate                     in boolean
  ,p_effective_date               in date
  ,p_data_source                  in varchar2
  );
  --
  -- ----------------------------------------------------------------------------
  -- |------------------------< delete_resource_definition >--------------------|
  -- ----------------------------------------------------------------------------
  --
  -- {Start Of Comments}
  /*#
   * This API deletes the Resource Definition.
   *
   *
   * <p><b>Licensing</b><br>
   * This API is licensed for use with Learning Management.
   *
   * <p><b>Prerequisites</b><br>
   * Resource definition with the given object version number should exist.
   *
   * <p><b>Post Success</b><br>
   * The Resource Definition is deleted successfully.
   *
   * <p><b>Post Failure</b><br>
   * The API does not delete a Resource Definition record and raises an error.
   *
   * @param p_validate If true, then validation alone will be performed and the
   * database will remain unchanged. If false and all validation checks pass,
   * then the database will be modified.
   * @param p_supplied_resource_id The unique identifier for the Resource definition.
   * @param p_object_version_number If p_validate is false, then set to the version
   * number of the created Resource Definition. If p_validate is true, then the
   * value will be null.
   * @rep:displayname Delete Resource Definition
   * @rep:category BUSINESS_ENTITY OTA_RESOURCE
   * @rep:lifecycle active
   * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
   * @rep:scope public
   * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
  */
  --
  -- {End Of Comments}
  --

procedure DELETE_RESOURCE_DEFINITION
  (p_validate                      in     boolean  default false
  ,p_supplied_resource_id        in     number
  ,p_object_version_number         in     number
  );

end ota_RESOURCE_DEFINITION_api;

 

/
