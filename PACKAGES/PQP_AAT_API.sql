--------------------------------------------------------
--  DDL for Package PQP_AAT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_AAT_API" AUTHID CURRENT_USER as
/* $Header: pqaatapi.pkh 120.6.12010000.1 2008/07/28 11:07:01 appldev ship $ */
/*#
 * This package contains APIs for assignment attributes.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Assignment Attribute
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_assignment_attribute >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an assignment attribute record for an employee including
 * contract types and details of work patterns.
 *
 * This package is used to create assignment attributes. These attributes
 * include contract type and details of work patterns that are mainly used by
 * public sector. Note: even though there are columns for vehicle information,
 * these are not used anymore as the new api's pqp_vehicle_repository_api and
 * pqp_vehicle_allocation_api are used for vehicle repository and allocations
 * respectively.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The employee must have an assignment on the effective date.
 *
 * <p><b>Post Success</b><br>
 * The assignment attributes will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The assignment attributes will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_business_group_id {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.BUSINESS_GROUP_ID}
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created assignment attribute. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created assignment attribute. If p_validate is
 * true, then set to null.
 * @param p_assignment_id Identifies the assignment for which you create the
 * assignment attribute record.
 * @param p_contract_type {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.CONTRACT_TYPE}
 * @param p_work_pattern {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.WORK_PATTERN}
 * @param p_start_day {@rep:casecolumn PQP_ASSIGNMENT_ATTRIBUTES_F.START_DAY}
 * @param p_primary_company_car {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.PRIMARY_COMPANY_CAR}
 * @param p_primary_car_fuel_benefit {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.PRIMARY_CAR_FUEL_BENEFIT}
 * @param p_primary_capital_contribution {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.PRIMARY_CAPITAL_CONTRIBUTION}
 * @param p_primary_class_1a {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.PRIMARY_CLASS_1A}
 * @param p_secondary_company_car {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.SECONDARY_COMPANY_CAR}
 * @param p_secondary_car_fuel_benefit {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.SECONDARY_CAR_FUEL_BENEFIT}
 * @param p_secondary_capital_contributi {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.SECONDARY_CAPITAL_CONTRIBUTION}
 * @param p_secondary_class_1a {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.SECONDARY_CLASS_1A}
 * @param p_company_car_calc_method {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.COMPANY_CAR_CALC_METHOD}
 * @param p_company_car_rates_table_id {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.COMPANY_CAR_RATES_TABLE_ID}
 * @param p_company_car_secondary_table {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.COMPANY_CAR_SECONDARY_TABLE_ID}
 * @param p_private_car {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.PRIVATE_CAR}
 * @param p_private_car_calc_method {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.PRIVATE_CAR_CALC_METHOD}
 * @param p_private_car_rates_table_id {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.PRIVATE_CAR_RATES_TABLE_ID}
 * @param p_private_car_essential_table {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.PRIVATE_CAR_ESSENTIAL_TABLE_ID}
 * @param p_primary_private_contribution {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.PRIMARY_PRIVATE_CONTRIBUTION}
 * @param p_secondary_private_contributi {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.SECONDARY_PRIVATE_CONTRIBUTION}
 * @param p_tp_is_teacher {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.TP_IS_TEACHER}
 * @param p_tp_safeguarded_grade {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.TP_SAFEGUARDED_GRADE}
 * @param p_tp_safeguarded_grade_id {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.TP_SAFEGUARDED_GRADE_ID}
 * @param p_tp_safeguarded_rate_type {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.TP_SAFEGUARDED_RATE_TYPE}
 * @param p_tp_safeguarded_rate_id {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.TP_SAFEGUARDED_RATE_ID}
 * @param p_tp_spinal_point_id {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.TP_SAFEGUARDED_SPINAL_POINT_ID}
 * @param p_tp_elected_pension {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.TP_ELECTED_PENSION}
 * @param p_tp_fast_track {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.TP_FAST_TRACK}
 * @param p_aat_attribute_category {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE_CATEGORY}
 * @param p_aat_attribute1 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE1}
 * @param p_aat_attribute2 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE2}
 * @param p_aat_attribute3 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE3}
 * @param p_aat_attribute4 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE4}
 * @param p_aat_attribute5 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE5}
 * @param p_aat_attribute6 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE6}
 * @param p_aat_attribute7 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE7}
 * @param p_aat_attribute8 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE8}
 * @param p_aat_attribute9 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE9}
 * @param p_aat_attribute10 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE10}
 * @param p_aat_attribute11 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE11}
 * @param p_aat_attribute12 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE12}
 * @param p_aat_attribute13 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE13}
 * @param p_aat_attribute14 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE14}
 * @param p_aat_attribute15 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE15}
 * @param p_aat_attribute16 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE16}
 * @param p_aat_attribute17 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE17}
 * @param p_aat_attribute18 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE18}
 * @param p_aat_attribute19 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE19}
 * @param p_aat_attribute20 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE20}
 * @param p_aat_information_category {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION_CATEGORY}
 * @param p_aat_information1 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION1}
 * @param p_aat_information2 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION2}
 * @param p_aat_information3 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION3}
 * @param p_aat_information4 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION4}
 * @param p_aat_information5 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION5}
 * @param p_aat_information6 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION6}
 * @param p_aat_information7 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION7}
 * @param p_aat_information8 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION8}
 * @param p_aat_information9 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION9}
 * @param p_aat_information10 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION10}
 * @param p_aat_information11 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION11}
 * @param p_aat_information12 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION12}
 * @param p_aat_information13 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION13}
 * @param p_aat_information14 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION14}
 * @param p_aat_information15 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION15}
 * @param p_aat_information16 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION16}
 * @param p_aat_information17 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION17}
 * @param p_aat_information18 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION18}
 * @param p_aat_information19 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION19}
 * @param p_aat_information20 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION20}
 * @param p_lgps_process_flag  {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.LGPS_PROCESS_FLAG}
 * @param p_lgps_exclusion_type {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.LGPS_EXCLUSION_TYPE}
 * @param p_lgps_pensionable_pay {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.LGPS_PENSIONABLE_PAY}
 * @param p_lgps_trans_arrang_flag {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.LGPS_TRANS_ARRANG_FLAG}
 * @param p_lgps_membership_number {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.LGPS_MEMBERSHIP_NUMBER}
 * @param p_assignment_attribute_id If p_validate is false, then this uniquely
 * identifies the assignment attribute row created. If p_validate is true, then
 * set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created assignment attribute. If p_validate is true,
 * then the value will be null.
 * @param p_tp_headteacher_grp_code {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.TP_HEADTEACHER_GRP_CODE}
 * @rep:displayname Create Assignment Attribute
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_assignment_attribute
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_assignment_id                 in     number
  ,p_contract_type                 in     varchar2	default null
  ,p_work_pattern                  in     varchar2	default null
  ,p_start_day                     in     varchar2	default null
  ,p_primary_company_car            in     number	default null
  ,p_primary_car_fuel_benefit       in     varchar2	default null
  ,p_primary_capital_contribution   in     number	default null
  ,p_primary_class_1a               in     varchar2	default null
  ,p_secondary_company_car          in     number	default null
  ,p_secondary_car_fuel_benefit     in     varchar2	default null
  ,p_secondary_capital_contributi   in     number	default null
  ,p_secondary_class_1a             in     varchar2	default null
  ,p_company_car_calc_method        in     varchar2	default null
  ,p_company_car_rates_table_id     in     number	default null
  ,p_company_car_secondary_table    in     number	default null
  ,p_private_car                    in     number	default null
  ,p_private_car_calc_method        in     varchar2	default null
  ,p_private_car_rates_table_id     in     number	default null
  ,p_private_car_essential_table    in     number	default null
  ,p_primary_private_contribution   in number		default null
  ,p_secondary_private_contributi   in number		default null
  ,p_tp_is_teacher                  in varchar2		default null
  --added for head Teacher seconded location for salary scale calculation
  ,p_tp_headteacher_grp_code        in number 		default null
  ,p_tp_safeguarded_grade           in varchar2		default null
  ,p_tp_safeguarded_grade_id        in number		default null
  ,p_tp_safeguarded_rate_type       in varchar2		default null
  ,p_tp_safeguarded_rate_id         in number		default null
  ,p_tp_spinal_point_id             in number		default null
  ,p_tp_elected_pension             in varchar2		default null
  ,p_tp_fast_track                  in varchar2		default null
  ,p_aat_attribute_category     in varchar2		default null
  ,p_aat_attribute1             in varchar2		default null
  ,p_aat_attribute2             in varchar2		default null
  ,p_aat_attribute3             in varchar2		default null
  ,p_aat_attribute4             in varchar2		default null
  ,p_aat_attribute5             in varchar2		default null
  ,p_aat_attribute6             in varchar2		default null
  ,p_aat_attribute7             in varchar2		default null
  ,p_aat_attribute8             in varchar2		default null
  ,p_aat_attribute9             in varchar2		default null
  ,p_aat_attribute10            in varchar2		default null
  ,p_aat_attribute11            in varchar2		default null
  ,p_aat_attribute12            in varchar2		default null
  ,p_aat_attribute13            in varchar2		default null
  ,p_aat_attribute14            in varchar2		default null
  ,p_aat_attribute15            in varchar2		default null
  ,p_aat_attribute16            in varchar2		default null
  ,p_aat_attribute17            in varchar2		default null
  ,p_aat_attribute18            in varchar2		default null
  ,p_aat_attribute19            in varchar2		default null
  ,p_aat_attribute20            in varchar2		default null
  ,p_aat_information_category   in varchar2		default null
  ,p_aat_information1           in varchar2		default null
  ,p_aat_information2           in varchar2		default null
  ,p_aat_information3           in varchar2		default null
  ,p_aat_information4           in varchar2		default null
  ,p_aat_information5           in varchar2		default null
  ,p_aat_information6           in varchar2		default null
  ,p_aat_information7           in varchar2		default null
  ,p_aat_information8           in varchar2		default null
  ,p_aat_information9           in varchar2		default null
  ,p_aat_information10          in varchar2		default null
  ,p_aat_information11          in varchar2		default null
  ,p_aat_information12          in varchar2		default null
  ,p_aat_information13          in varchar2		default null
  ,p_aat_information14          in varchar2		default null
  ,p_aat_information15          in varchar2		default null
  ,p_aat_information16          in varchar2		default null
  ,p_aat_information17          in varchar2		default null
  ,p_aat_information18          in varchar2		default null
  ,p_aat_information19          in varchar2		default null
  ,p_aat_information20          in varchar2		default null
  ,p_lgps_process_flag          in varchar2           default null
  ,p_lgps_exclusion_type        in varchar2           default null
  ,p_lgps_pensionable_pay       in varchar2           default null
  ,p_lgps_trans_arrang_flag     in varchar2           default null
  ,p_lgps_membership_number     in varchar2           default null
  ,p_assignment_attribute_id          out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_assignment_attribute >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an assignment attribute record for an employee including
 * contract types and details of work patterns.
 *
 * This package is used to update assignment attributes. These attributes
 * include contract type and details of work patterns that are mainly used by
 * public sector. Note: even though there are columns for vehicle information,
 * these are not used anymore as the new api's pqp_vehicle_repository_api and
 * pqp_vehicle_allocation_api are used for vehicle repository and allocations
 * respectively.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The employee must have an assignment attribute on the effective date.
 *
 * <p><b>Post Success</b><br>
 * The assignment attributes will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The assignment attributes will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_assignment_attribute_id {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.ASSIGNMENT_ATTRIBUTE_ID}
 * @param p_business_group_id {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.BUSINESS_GROUP_ID}
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated assignment attribute row which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated assignment attribute row which now exists
 * as of the effective date. If p_validate is true, then set to null.
 * @param p_assignment_id Identifies the assignment record to modify.
 * @param p_contract_type {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.CONTRACT_TYPE}
 * @param p_work_pattern {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.WORK_PATTERN}
 * @param p_start_day {@rep:casecolumn PQP_ASSIGNMENT_ATTRIBUTES_F.START_DAY}
 * @param p_primary_company_car {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.PRIMARY_COMPANY_CAR}
 * @param p_primary_car_fuel_benefit {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.PRIMARY_CAR_FUEL_BENEFIT}
 * @param p_primary_capital_contribution {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.PRIMARY_CAPITAL_CONTRIBUTION}
 * @param p_primary_class_1a {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.PRIMARY_CLASS_1A}
 * @param p_secondary_company_car {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.SECONDARY_COMPANY_CAR}
 * @param p_secondary_car_fuel_benefit Indictates whether the secondary company
 * car is provided with fuel benefit
 * @param p_secondary_capital_contributi {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.SECONDARY_CAPITAL_CONTRIBUTION}
 * @param p_secondary_class_1a {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.SECONDARY_CLASS_1A}
 * @param p_company_car_calc_method {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.COMPANY_CAR_CALC_METHOD}
 * @param p_company_car_rates_table_id {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.COMPANY_CAR_RATES_TABLE_ID}
 * @param p_company_car_secondary_table {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.COMPANY_CAR_SECONDARY_TABLE_ID}
 * @param p_private_car {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.PRIVATE_CAR}
 * @param p_private_car_calc_method {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.PRIVATE_CAR_CALC_METHOD}
 * @param p_private_car_rates_table_id {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.PRIVATE_CAR_RATES_TABLE_ID}
 * @param p_private_car_essential_table {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.PRIVATE_CAR_ESSENTIAL_TABLE_ID}
 * @param p_primary_private_contribution {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.PRIMARY_PRIVATE_CONTRIBUTION}
 * @param p_secondary_private_contributi {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.SECONDARY_PRIVATE_CONTRIBUTION}
 * @param p_tp_is_teacher {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.TP_IS_TEACHER}
 * @param p_tp_safeguarded_grade {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.TP_SAFEGUARDED_GRADE}
 * @param p_tp_safeguarded_grade_id {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.TP_SAFEGUARDED_GRADE_ID}
 * @param p_tp_safeguarded_rate_type {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.TP_SAFEGUARDED_RATE_TYPE}
 * @param p_tp_safeguarded_rate_id {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.TP_SAFEGUARDED_RATE_ID}
 * @param p_tp_spinal_point_id {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.TP_SAFEGUARDED_SPINAL_POINT_ID}
 * @param p_tp_elected_pension {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.TP_ELECTED_PENSION}
 * @param p_tp_fast_track {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.TP_FAST_TRACK}
 * @param p_aat_attribute_category {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE_CATEGORY}
 * @param p_aat_attribute1 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE1}
 * @param p_aat_attribute2 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE2}
 * @param p_aat_attribute3 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE3}
 * @param p_aat_attribute4 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE4}
 * @param p_aat_attribute5 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE5}
 * @param p_aat_attribute6 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE6}
 * @param p_aat_attribute7 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE7}
 * @param p_aat_attribute8 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE8}
 * @param p_aat_attribute9 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE9}
 * @param p_aat_attribute10 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE10}
 * @param p_aat_attribute11 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE11}
 * @param p_aat_attribute12 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE12}
 * @param p_aat_attribute13 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE13}
 * @param p_aat_attribute14 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE14}
 * @param p_aat_attribute15 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE15}
 * @param p_aat_attribute16 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE16}
 * @param p_aat_attribute17 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE17}
 * @param p_aat_attribute18 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE18}
 * @param p_aat_attribute19 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE19}
 * @param p_aat_attribute20 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_ATTRIBUTE20}
 * @param p_aat_information_category {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION_CATEGORY}
 * @param p_aat_information1 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION1}
 * @param p_aat_information2 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION2}
 * @param p_aat_information3 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION3}
 * @param p_aat_information4 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION4}
 * @param p_aat_information5 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION5}
 * @param p_aat_information6 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION6}
 * @param p_aat_information7 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION7}
 * @param p_aat_information8 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION8}
 * @param p_aat_information9 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION9}
 * @param p_aat_information10 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION10}
 * @param p_aat_information11 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION11}
 * @param p_aat_information12 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION12}
 * @param p_aat_information13 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION13}
 * @param p_aat_information14 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION14}
 * @param p_aat_information15 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION15}
 * @param p_aat_information16 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION16}
 * @param p_aat_information17 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION17}
 * @param p_aat_information18 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION18}
 * @param p_aat_information19 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION19}
 * @param p_aat_information20 {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.AAT_INFORMATION20}
 * @param p_lgps_process_flag  {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.LGPS_PROCESS_FLAG}
 * @param p_lgps_exclusion_type {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.LGPS_EXCLUSION_TYPE}
 * @param p_lgps_pensionable_pay {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.LGPS_PENSIONABLE_PAY}
 * @param p_lgps_trans_arrang_flag {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.LGPS_TRANS_ARRANG_FLAG}
 * @param p_lgps_membership_number {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.LGPS_MEMBERSHIP_NUMBER}
 * @param p_object_version_number Pass in the current version number of the
 * assignment attribute to be updated. When the API completes, if p_validate is
 * false then it will be set to the new version number of the updated
 * assignment attribute. If p_validate is true then it will be set to the same
 * value which was passed in.
 * @param p_tp_headteacher_grp_code {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.TP_HEADTEACHER_GRP_CODE}
 * @rep:displayname Update Assignment Attribute
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_assignment_attribute
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_assignment_attribute_id       in     number
  ,p_business_group_id             in     number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_assignment_id                 in     number   default hr_api.g_number
  ,p_contract_type                 in     varchar2 default hr_api.g_varchar2
  ,p_work_pattern                  in     varchar2 default hr_api.g_varchar2
  ,p_start_day                     in     varchar2 default hr_api.g_varchar2
  ,p_primary_company_car           in     number   default hr_api.g_number
  ,p_primary_car_fuel_benefit      in     varchar2 default hr_api.g_varchar2
  ,p_primary_capital_contribution  in     number    default hr_api.g_number
  ,p_primary_class_1a              in     varchar2 default hr_api.g_varchar2
  ,p_secondary_company_car         in     number   default hr_api.g_number
  ,p_secondary_car_fuel_benefit    in     varchar2 default hr_api.g_varchar2
  ,p_secondary_capital_contributi  in     number    default hr_api.g_number
  ,p_secondary_class_1a            in     varchar2 default hr_api.g_varchar2
  ,p_company_car_calc_method       in     varchar2 default hr_api.g_varchar2
  ,p_company_car_rates_table_id    in     number   default hr_api.g_number
  ,p_company_car_secondary_table   in     number   default hr_api.g_number
  ,p_private_car                   in     number    default hr_api.g_number
  ,p_private_car_calc_method       in     varchar2 default hr_api.g_varchar2
  ,p_private_car_rates_table_id    in     number default hr_api.g_number
  ,p_private_car_essential_table   in     number default hr_api.g_number
  ,p_primary_private_contribution  in     number  default hr_api.g_number
  ,p_secondary_private_contributi  in     number  default hr_api.g_number
  ,p_tp_is_teacher                 in     varchar2  default hr_api.g_varchar2
  ,p_tp_headteacher_grp_code       in     number  default hr_api.g_number --added for head Teacher seconded location for salary scale calculation
  ,p_tp_safeguarded_grade          in     varchar2  default hr_api.g_varchar2
  ,p_tp_safeguarded_grade_id       in     number    default hr_api.g_number
  ,p_tp_safeguarded_rate_type      in     varchar2  default hr_api.g_varchar2
  ,p_tp_safeguarded_rate_id        in     number    default hr_api.g_number
  ,p_tp_spinal_point_id            in     number  default hr_api.g_number
  ,p_tp_elected_pension            in     varchar2  default hr_api.g_varchar2
  ,p_tp_fast_track                 in     varchar2  default hr_api.g_varchar2
  ,p_aat_attribute_category     in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute1             in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute2             in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute3             in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute4             in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute5             in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute6             in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute7             in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute8             in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute9             in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute10            in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute11            in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute12            in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute13            in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute14            in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute15            in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute16            in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute17            in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute18            in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute19            in varchar2  default hr_api.g_varchar2
  ,p_aat_attribute20            in varchar2  default hr_api.g_varchar2
  ,p_aat_information_category   in varchar2  default hr_api.g_varchar2
  ,p_aat_information1           in varchar2  default hr_api.g_varchar2
  ,p_aat_information2           in varchar2  default hr_api.g_varchar2
  ,p_aat_information3           in varchar2  default hr_api.g_varchar2
  ,p_aat_information4           in varchar2  default hr_api.g_varchar2
  ,p_aat_information5           in varchar2  default hr_api.g_varchar2
  ,p_aat_information6           in varchar2  default hr_api.g_varchar2
  ,p_aat_information7           in varchar2  default hr_api.g_varchar2
  ,p_aat_information8           in varchar2  default hr_api.g_varchar2
  ,p_aat_information9           in varchar2  default hr_api.g_varchar2
  ,p_aat_information10          in varchar2  default hr_api.g_varchar2
  ,p_aat_information11          in varchar2  default hr_api.g_varchar2
  ,p_aat_information12          in varchar2  default hr_api.g_varchar2
  ,p_aat_information13          in varchar2  default hr_api.g_varchar2
  ,p_aat_information14          in varchar2  default hr_api.g_varchar2
  ,p_aat_information15          in varchar2  default hr_api.g_varchar2
  ,p_aat_information16          in varchar2  default hr_api.g_varchar2
  ,p_aat_information17          in varchar2  default hr_api.g_varchar2
  ,p_aat_information18          in varchar2  default hr_api.g_varchar2
  ,p_aat_information19          in varchar2  default hr_api.g_varchar2
  ,p_aat_information20          in varchar2  default hr_api.g_varchar2
  ,p_lgps_process_flag          in varchar2  default hr_api.g_varchar2
  ,p_lgps_exclusion_type        in varchar2  default hr_api.g_varchar2
  ,p_lgps_pensionable_pay       in varchar2  default hr_api.g_varchar2
  ,p_lgps_trans_arrang_flag     in varchar2  default hr_api.g_varchar2
  ,p_lgps_membership_number     in varchar2  default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_assignment_attribute >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an assignment attribute like the contract types and details
 * of work patterns.
 *
 * Assignment attributes are deleted for the employee assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The employee must have an assignment attribute on the effective date.
 *
 * <p><b>Post Success</b><br>
 * The assignment attributes will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The assignment attributes will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when deleting
 * the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_business_group_id {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.BUSINESS_GROUP_ID}
 * @param p_assignment_attribute_id {@rep:casecolumn
 * PQP_ASSIGNMENT_ATTRIBUTES_F.ASSIGNMENT_ATTRIBUTE_ID}
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted assignment attribute row which now
 * exists as of the effective date. If p_validate is true or all row instances
 * have been deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted assignment attribute row which now exists
 * as of the effective date. If p_validate is true or all row instances have
 * been deleted then set to null.
 * @param p_object_version_number Current version number of the assignment
 * attribute to be deleted.
 * @rep:displayname Delete Assignment Attribute
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_assignment_attribute
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_business_group_id             in     number
  ,p_assignment_attribute_id       in     number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_object_version_number         in out nocopy number
  );
--
end pqp_aat_api;

/
