--------------------------------------------------------
--  DDL for Package GHR_SF52_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_SF52_API" AUTHID CURRENT_USER as
/* $Header: ghparapi.pkh 120.10.12010000.2 2009/02/27 12:12:19 vmididho ship $ */
/*#
 * This package contains the procedures for creating, updating, and deleting a
 * Request for Personnel Action (RPA).
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Request for Personnel Action
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< create_sf52 >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates Request for Personnel Actions (RPA).
 *
 * This API creates a pa_request record and two pa_routing_history records, one
 * that populates the details regarding the action taken (the user name of the
 * person who acted on the RPA, that person's roles and actions taken) and a
 * second that stores the routing information (the user name or the groupbox
 * name of each routing destination). The API also stores the mandatory remarks
 * required for the specific first_nature_of_action in the pa_remarks table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Nature of Action and Family records must exist as of the effective date.
 * A Routing Group must be assigned to the user.
 *
 * <p><b>Post Success</b><br>
 * The API creates the Request for Personnel Action, Personnel Action Remark,
 * and the Personnel Action Routing History records.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the Request for Personnel Action, Personnel Action
 * Remark or the Personnel Action Routing History records and an error is
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_noa_family_code Nature Of Action Family Code
 * @param p_pa_request_id If p_validate is false, this parameter uniquely
 * identifies the Request for Personnel Action record Created. If p_validate is
 * true, sets null.
 * @param p_routing_group_id {@rep:casecolumn GHR_PA_REQUESTS.ROUTING_GROUP_ID}
 * @param p_proposed_effective_asap_flag Flag to indicate ASAP for proposed
 * effective date. Valid Values are Y - Yes, N - No.
 * @param p_academic_discipline Academic Discipline. Valid values are defined
 * by 'GHR_US_ACADEMIC_DISCIPLINE' lookup type.
 * @param p_additional_info_person_id Uniquely identifies the person chosen as
 * the Additional Information Person.
 * @param p_additional_info_tel_number {@rep:casecolumn
 * GHR_PA_REQUESTS.ADDITIONAL_INFO_TEL_NUMBER}
 * @param p_altered_pa_request_id {@rep:casecolumn
 * GHR_PA_REQUESTS.ALTERED_PA_REQUEST_ID}
 * @param p_annuitant_indicator Annuitant Indicator. Valid values are defined
 * by 'GHR_US_ANNUITANT_INDICATOR' lookup type.
 * @param p_annuitant_indicator_desc Annuitant Indicator Description. Valid
 * values are defined by 'GHR_US_ANNUITANT_INDICATOR' lookup meaning.
 * @param p_appropriation_code1 Appropriation Code1. Valid values are defined
 * by 'GHR_US_APPROPRIATION_CODE1' lookup type.
 * @param p_appropriation_code2 Appropriation Code2. Valid values are defined
 * by 'GHR_US_APPROPRIATION_CODE2' lookup type.
 * @param p_approval_date {@rep:casecolumn GHR_PA_REQUESTS.APPROVAL_DATE}
 * @param p_approving_official_full_name {@rep:casecolumn
 * GHR_PA_REQUESTS.APPROVING_OFFICIAL_FULL_NAME}
 * @param p_approving_official_work_titl {@rep:casecolumn
 * GHR_PA_REQUESTS.APPROVING_OFFICIAL_WORK_TITLE}
 * @param p_authorized_by_person_id Uniquely identifies the Person Authorizing
 * the Request for Personnel Action.
 * @param p_authorized_by_title {@rep:casecolumn
 * GHR_PA_REQUESTS.AUTHORIZED_BY_TITLE}
 * @param p_award_amount {@rep:casecolumn GHR_PA_REQUESTS.AWARD_AMOUNT}
 * @param p_award_uom {@rep:casecolumn GHR_PA_REQUESTS.AWARD_UOM}
 * @param p_bargaining_unit_status Bargaining Unit Status. Valid values are
 * defined by 'GHR_US_BARG_UNIT_STATUS' lookup type.
 * @param p_citizenship Citizenship. Valid values are defined by
 * 'GHR_US_CITIZENSHIP' lookup type.
 * @param p_concurrence_date {@rep:casecolumn GHR_PA_REQUESTS.CONCURRENCE_DATE}
 * @param p_custom_pay_calc_flag {@rep:casecolumn
 * GHR_PA_REQUESTS.CUSTOM_PAY_CALC_FLAG}
 * @param p_duty_station_code {@rep:casecolumn
 * GHR_PA_REQUESTS.DUTY_STATION_CODE}
 * @param p_duty_station_desc {@rep:casecolumn
 * GHR_PA_REQUESTS.DUTY_STATION_DESC}
 * @param p_duty_station_id {@rep:casecolumn GHR_PA_REQUESTS.DUTY_STATION_ID}
 * @param p_duty_station_location_id {@rep:casecolumn
 * GHR_PA_REQUESTS.DUTY_STATION_LOCATION_ID}
 * @param p_education_level Education Level. Valid values are defined by
 * 'GHR_US_EDUCATION_LEVEL' lookup type.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_employee_assignment_id {@rep:casecolumn
 * GHR_PA_REQUESTS.EMPLOYEE_ASSIGNMENT_ID}
 * @param p_employee_date_of_birth {@rep:casecolumn
 * GHR_PA_REQUESTS.EMPLOYEE_DATE_OF_BIRTH}
 * @param p_employee_first_name {@rep:casecolumn
 * GHR_PA_REQUESTS.EMPLOYEE_FIRST_NAME}
 * @param p_employee_last_name {@rep:casecolumn
 * GHR_PA_REQUESTS.EMPLOYEE_LAST_NAME}
 * @param p_employee_middle_names {@rep:casecolumn
 * GHR_PA_REQUESTS.EMPLOYEE_MIDDLE_NAMES}
 * @param p_employee_national_identifier {@rep:casecolumn
 * GHR_PA_REQUESTS.EMPLOYEE_NATIONAL_IDENTIFIER}
 * @param p_fegli FEGLI. Valid values are defined by 'GHR_US_FEGLI' lookup
 * type.
 * @param p_fegli_desc FEGLI Description. Valid values are defined by
 * 'GHR_US_FEGLI' lookup meaning.
 * @param p_first_action_la_code1 Legal Authority Code. Valid values are
 * defined by 'GHR_US_LEGAL_AUTHORITY' lookup type.
 * @param p_first_action_la_code2 Legal Authority Code. Valid values are
 * defined by 'GHR_US_LEGAL_AUTHORITY' lookup type.
 * @param p_first_action_la_desc1 Legal Authority Code description.
 * @param p_first_action_la_desc2 Legal Authority Code description.
 * @param p_first_noa_cancel_or_correct {@rep:casecolumn
 * GHR_PA_REQUESTS.FIRST_NOA_CANCEL_OR_CORRECT}
 * @param p_first_noa_code {@rep:casecolumn GHR_PA_REQUESTS.FIRST_NOA_CODE}
 * @param p_first_noa_desc {@rep:casecolumn GHR_PA_REQUESTS.FIRST_NOA_DESC}
 * @param p_first_noa_id {@rep:casecolumn GHR_PA_REQUESTS.FIRST_NOA_ID}
 * @param p_first_noa_pa_request_id {@rep:casecolumn
 * GHR_PA_REQUESTS.FIRST_NOA_PA_REQUEST_ID}
 * @param p_flsa_category {@rep:casecolumn GHR_PA_REQUESTS.FLSA_CATEGORY}
 * @param p_forwarding_address_line1 {@rep:casecolumn
 * GHR_PA_REQUESTS.FORWARDING_ADDRESS_LINE1}
 * @param p_forwarding_address_line2 {@rep:casecolumn
 * GHR_PA_REQUESTS.FORWARDING_ADDRESS_LINE2}
 * @param p_forwarding_address_line3 {@rep:casecolumn
 * GHR_PA_REQUESTS.FORWARDING_ADDRESS_LINE3}
 * @param p_forwarding_country {@rep:casecolumn
 * GHR_PA_REQUESTS.FORWARDING_COUNTRY}
 * @param p_forwarding_country_short_nam {@rep:casecolumn
 * GHR_PA_REQUESTS.FORWARDING_COUNTRY_SHORT_NAME}
 * @param p_forwarding_postal_code {@rep:casecolumn
 * GHR_PA_REQUESTS.FORWARDING_POSTAL_CODE}
 * @param p_forwarding_region_2 {@rep:casecolumn
 * GHR_PA_REQUESTS.FORWARDING_REGION_2}
 * @param p_forwarding_town_or_city {@rep:casecolumn
 * GHR_PA_REQUESTS.FORWARDING_TOWN_OR_CITY}
 * @param p_from_adj_basic_pay {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_ADJ_BASIC_PAY}
 * @param p_from_basic_pay {@rep:casecolumn GHR_PA_REQUESTS.FROM_BASIC_PAY}
 * @param p_from_grade_or_level {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_GRADE_OR_LEVEL}
 * @param p_from_locality_adj {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_LOCALITY_ADJ}
 * @param p_from_occ_code {@rep:casecolumn GHR_PA_REQUESTS.FROM_OCC_CODE}
 * @param p_from_other_pay_amount {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_OTHER_PAY_AMOUNT}
 * @param p_from_pay_basis From Pay basis. Valid values are defined by
 * 'GHR_US_PAY_BASIS' lookup type.
 * @param p_from_pay_plan {@rep:casecolumn GHR_PA_REQUESTS.FROM_PAY_PLAN}
 * @param p_from_position_id {@rep:casecolumn GHR_PA_REQUESTS.FROM_POSITION_ID}
 * @param p_from_position_org_line1 {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_POSITION_ORG_LINE1}
 * @param p_from_position_org_line2 {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_POSITION_ORG_LINE2}
 * @param p_from_position_org_line3 {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_POSITION_ORG_LINE3}
 * @param p_from_position_org_line4 {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_POSITION_ORG_LINE4}
 * @param p_from_position_org_line5 {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_POSITION_ORG_LINE5}
 * @param p_from_position_org_line6 {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_POSITION_ORG_LINE6}
 * @param p_from_position_number {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_POSITION_NUMBER}
 * @param p_from_position_seq_no {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_POSITION_SEQ_NO}
 * @param p_from_position_title {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_POSITION_TITLE}
 * @param p_from_step_or_rate {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_STEP_OR_RATE}
 * @param p_from_total_salary {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_TOTAL_SALARY}
 * @param p_functional_class Functional Class. Valid values are defined by
 * 'GHR_US_FUNCTIONAL_CLASS' lookup type.
 * @param p_notepad {@rep:casecolumn GHR_PA_REQUESTS.NOTEPAD}
 * @param p_part_time_hours {@rep:casecolumn GHR_PA_REQUESTS.PART_TIME_HOURS}
 * @param p_pay_rate_determinant Pay Rate Determinant. Valid values are defined
 * by 'GHR_US_PAY_RATE_DETERMINANT' lookup type.
 * @param p_person_id Identifies the person for whom you create the personnel
 * action record.
 * @param p_position_occupied {@rep:casecolumn
 * GHR_PA_REQUESTS.POSITION_OCCUPIED}
 * @param p_proposed_effective_date {@rep:casecolumn
 * GHR_PA_REQUESTS.PROPOSED_EFFECTIVE_DATE}
 * @param p_requested_by_person_id {@rep:casecolumn
 * GHR_PA_REQUESTS.REQUESTED_BY_PERSON_ID}
 * @param p_requested_by_title {@rep:casecolumn
 * GHR_PA_REQUESTS.REQUESTED_BY_TITLE}
 * @param p_requested_date {@rep:casecolumn GHR_PA_REQUESTS.REQUESTED_DATE}
 * @param p_requesting_office_remarks_de Requesting Office remarks description
 * @param p_requesting_office_remarks_fl Flag to indicate if there are remarks
 * from the Requesting Office. Valid values are Y - Yes, N - No.
 * @param p_request_number {@rep:casecolumn GHR_PA_REQUESTS.REQUEST_NUMBER}
 * @param p_resign_and_retire_reason_des {@rep:casecolumn
 * GHR_PA_REQUESTS.RESIGN_AND_RETIRE_REASON_DESC}
 * @param p_retirement_plan Retirement Plan. Valid values are defined by
 * 'GHR_US_RETIREMENT_PLAN' lookup type.
 * @param p_retirement_plan_desc Retirement Plan Description. Valid values are
 * defined by 'GHR_US_RETIREMENT_PLAN' lookup meaning.
 * @param p_second_action_la_code1 Legal Authority Code. Valid values are
 * defined by 'GHR_US_LEGAL_AUTHORITY' lookup type.
 * @param p_second_action_la_code2 Legal Authority Code. Valid values are
 * defined by 'GHR_US_LEGAL_AUTHORITY' lookup type.
 * @param p_second_action_la_desc1 Legal Authority Code description.
 * @param p_second_action_la_desc2 Legal Authority Code description.
 * @param p_second_noa_cancel_or_correct {@rep:casecolumn
 * GHR_PA_REQUESTS.SECOND_NOA_CANCEL_OR_CORRECT}
 * @param p_second_noa_code {@rep:casecolumn GHR_PA_REQUESTS.SECOND_NOA_CODE}
 * @param p_second_noa_desc {@rep:casecolumn GHR_PA_REQUESTS.SECOND_NOA_DESC}
 * @param p_second_noa_id {@rep:casecolumn GHR_PA_REQUESTS.SECOND_NOA_ID}
 * @param p_second_noa_pa_request_id {@rep:casecolumn
 * GHR_PA_REQUESTS.SECOND_NOA_PA_REQUEST_ID}
 * @param p_service_comp_date {@rep:casecolumn
 * GHR_PA_REQUESTS.SERVICE_COMP_DATE}
 * @param p_supervisory_status Supervisory Status. Valid values are defined by
 * 'GHR_US_SUPERVISORY_STATUS' lookup type.
 * @param p_tenure Tenure. Valid values are defined by 'GHR_US_TENURE' lookup
 * type.
 * @param p_to_adj_basic_pay {@rep:casecolumn GHR_PA_REQUESTS.TO_ADJ_BASIC_PAY}
 * @param p_to_basic_pay {@rep:casecolumn GHR_PA_REQUESTS.TO_BASIC_PAY}
 * @param p_to_grade_id {@rep:casecolumn GHR_PA_REQUESTS.TO_GRADE_ID}
 * @param p_to_grade_or_level {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_GRADE_OR_LEVEL}
 * @param p_to_job_id {@rep:casecolumn GHR_PA_REQUESTS.TO_JOB_ID}
 * @param p_to_locality_adj {@rep:casecolumn GHR_PA_REQUESTS.TO_LOCALITY_ADJ}
 * @param p_to_occ_code {@rep:casecolumn GHR_PA_REQUESTS.TO_OCC_CODE}
 * @param p_to_organization_id {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_ORGANIZATION_ID}
 * @param p_to_other_pay_amount {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_OTHER_PAY_AMOUNT}
 * @param p_to_au_overtime {@rep:casecolumn GHR_PA_REQUESTS.TO_AU_OVERTIME}
 * @param p_to_auo_premium_pay_indicator To authorized uncontrollable overtime
 * premium pay indicator. Valid values are defined by 'GHR_US_PREM_PAY_IND'
 * lookup type.
 * @param p_to_availability_pay {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_AVAILABILITY_PAY}
 * @param p_to_ap_premium_pay_indicator {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_AP_PREMIUM_PAY_INDICATOR}
 * @param p_to_retention_allowance {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_RETENTION_ALLOWANCE}
 * @param p_to_supervisory_differential {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_SUPERVISORY_DIFFERENTIAL}
 * @param p_to_staffing_differential {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_STAFFING_DIFFERENTIAL}
 * @param p_to_pay_basis To Pay basis. Valid values are defined by
 * 'GHR_US_PAY_BASIS' lookup type.
 * @param p_to_pay_plan {@rep:casecolumn GHR_PA_REQUESTS.TO_PAY_PLAN}
 * @param p_to_position_id {@rep:casecolumn GHR_PA_REQUESTS.TO_POSITION_ID}
 * @param p_to_position_org_line1 {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_POSITION_ORG_LINE1}
 * @param p_to_position_org_line2 {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_POSITION_ORG_LINE2}
 * @param p_to_position_org_line3 {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_POSITION_ORG_LINE3}
 * @param p_to_position_org_line4 {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_POSITION_ORG_LINE4}
 * @param p_to_position_org_line5 {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_POSITION_ORG_LINE5}
 * @param p_to_position_org_line6 {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_POSITION_ORG_LINE6}
 * @param p_to_position_number {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_POSITION_NUMBER}
 * @param p_to_position_seq_no {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_POSITION_SEQ_NO}
 * @param p_to_position_title {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_POSITION_TITLE}
 * @param p_to_step_or_rate {@rep:casecolumn GHR_PA_REQUESTS.TO_STEP_OR_RATE}
 * @param p_to_total_salary {@rep:casecolumn GHR_PA_REQUESTS.TO_TOTAL_SALARY}
 * @param p_veterans_preference Veterans Preference. Valid values are defined
 * by 'GHR_US_VETERANS_PREF' lookup type.
 * @param p_veterans_pref_for_rif Veterans Preference for Reduction in Force.
 * Valid values are defined by 'GHR_US_VETERANS_PREF_FOR_RIF' lookup type.
 * @param p_veterans_status Veterans Status. Valid values are defined by
 * 'GHR_US_VET_STATUS' lookup type
 * @param p_work_schedule Work Schedule. Valid values are defined by
 * 'GHR_US_WORK_SCHEDULE' lookup type.
 * @param p_work_schedule_desc Work Schedule Description. Valid values are
 * defined by 'GHR_US_WORK_SCHEDULE' lookup meaning
 * @param p_year_degree_attained {@rep:casecolumn
 * GHR_PA_REQUESTS.YEAR_DEGREE_ATTAINED}
 * @param p_first_noa_information1 First Nature of Action description Insertion
 * Value1
 * @param p_first_noa_information2 First Nature of Action description Insertion
 * Value2
 * @param p_first_noa_information3 First Nature of Action description Insertion
 * Value3
 * @param p_first_noa_information4 First Nature of Action description Insertion
 * Value4
 * @param p_first_noa_information5 First Nature of Action description Insertion
 * Value5
 * @param p_second_lac1_information1 Second Legal Authority Code1 Description
 * Insertion Value1
 * @param p_second_lac1_information2 Second Legal Authority Code1 Description
 * Insertion Value2
 * @param p_second_lac1_information3 Second Legal Authority Code1 Description
 * Insertion Value3
 * @param p_second_lac1_information4 Second Legal Authority Code1 Description
 * Insertion Value4
 * @param p_second_lac1_information5 Second Legal Authority Code1 Description
 * Insertion Value5
 * @param p_second_lac2_information1 Second Legal Authority Code2 Description
 * Insertion Value1
 * @param p_second_lac2_information2 Second Legal Authority Code2 Description
 * Insertion Value2
 * @param p_second_lac2_information3 Second Legal Authority Code2 Description
 * Insertion Value3
 * @param p_second_lac2_information4 Second Legal Authority Code2 Description
 * Insertion Value4
 * @param p_second_lac2_information5 Second Legal Authority Code2 Description
 * Insertion Value5
 * @param p_second_noa_information1 Second Nature of Action description
 * Insertion Value1
 * @param p_second_noa_information2 Second Nature of Action description
 * Insertion Value2
 * @param p_second_noa_information3 Second Nature of Action description
 * Insertion Value3
 * @param p_second_noa_information4 Second Nature of Action description
 * Insertion Value4
 * @param p_second_noa_information5 Second Nature of Action description
 * Insertion Value5
 * @param p_first_lac1_information1 First Legal Authority Code1 Description
 * Insertion Value1.
 * @param p_first_lac1_information2 First Legal Authority Code1 Description
 * Insertion Value2.
 * @param p_first_lac1_information3 First Legal Authority Code1 Description
 * Insertion Value3.
 * @param p_first_lac1_information4 First Legal Authority Code1 Description
 * Insertion Value4.
 * @param p_first_lac1_information5 First Legal Authority Code1 Description
 * Insertion Value5.
 * @param p_first_lac2_information1 First Legal Authority Code2 Description
 * Insertion Value1.
 * @param p_first_lac2_information2 First Legal Authority Code2 Description
 * Insertion Value2.
 * @param p_first_lac2_information3 First Legal Authority Code2 Description
 * Insertion Value3.
 * @param p_first_lac2_information4 First Legal Authority Code2 Description
 * Insertion Value4.
 * @param p_first_lac2_information5 First Legal Authority Code2 Description
 * Insertion Value5.
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
 * @param p_print_sf50_flag Print Flag Yes or No.
 * @param p_printer_name Printer Name
 * @param p_1_attachment_modified_flag {@rep:casecolumn
 * GHR_PA_ROUTING_HISTORY.ATTACHMENT_MODIFIED_FLAG}
 * @param p_1_approved_flag {@rep:casecolumn
 * GHR_PA_ROUTING_HISTORY.APPROVED_FLAG}
 * @param p_1_user_name_acted_on The user name of the person who acted on the
 * Request for Personnel Action (RPA)
 * @param p_1_action_taken Action taken by the user
 * @param p_1_approval_status {@rep:casecolumn GHR_PA_REQUESTS.STATUS}
 * @param p_2_user_name_routed_to The user name of the person to whom the RPA
 * is routed.
 * @param p_2_groupbox_id Groupbox to which the Request for Personnel Action
 * (RPA) is routed. Note: You can designate a groupbox or a user name as a
 * routing destination.
 * @param p_2_routing_list_id Routing List to which you are routing the Request
 * for Personnel Action (RPA)
 * @param p_2_routing_seq_number Sequence number within the Routing List
 * @param p_capped_other_pay Other Pay amount after being reduced (capped) due
 * to hitting the Pay Cap.
 * @param p_to_retention_allow_percentag {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_RETENTION_ALLOW_PERCENTAGE}
 * @param p_to_supervisory_diff_percenta {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_SUPERVISORY_DIFF_PERCENTAGE}
 * @param p_to_staffing_diff_percentage {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_STAFFING_DIFF_PERCENTAGE}
 * @param p_award_percentage {@rep:casecolumn GHR_PA_REQUESTS.AWARD_PERCENTAGE}
 * @param p_rpa_type {@rep:casecolumn GHR_PA_REQUESTS.RPA_TYPE}
 * @param p_mass_action_id {@rep:casecolumn GHR_PA_REQUESTS.MASS_ACTION_ID}
 * @param p_mass_action_eligible_flag {@rep:casecolumn
 * GHR_PA_REQUESTS.MASS_ACTION_ELIGIBLE_FLAG}
 * @param p_mass_action_select_flag {@rep:casecolumn
 * GHR_PA_REQUESTS.MASS_ACTION_SELECT_FLAG}
 * @param p_mass_action_comments {@rep:casecolumn
 * GHR_PA_REQUESTS.MASS_ACTION_COMMENTS}
 * @param p_payment_option Payment option for the Incentive Family
 * @param p_award_salary Award Salary used for award calculation
 * @param p_par_object_version_number If p_validate is false, then sets the
 * version number of the created pa_request_id. If p_validate is true, then the
 * value is null.
 * @param p_1_pa_routing_history_id pa_routing_history_id for the record
 * containing action details
 * @param p_1_prh_object_version_number If p_validate is false, then sets the
 * version number of the created first routing history id. If p_validate is
 * true, then the value is null.
 * @param p_2_pa_routing_history_id pa_routing_history_id for the record
 * containing routing details
 * @param p_2_prh_object_version_number If p_validate is false, then sets the
 * version number of the created second routing history id. If p_validate is
 * true, then the value is null.
 * @param p_input_pay_rate_determinant Pay Rate Determinant passed to the pay calculation procedure
 * @param p_from_pay_table_identifier Pay Table ID on the RPA effective date
 * @param p_to_pay_table_identifier Pay Table ID after pay calculation has completed
 * @param p_print_back_page If Print Back Page is set to Yes then NPA back page will be printed
 * @rep:displayname Create Request for Personnel Action
 * @rep:category BUSINESS_ENTITY GHR_REQ_FOR_PERSONNEL_ACTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_sf52
 (p_validate                     in boolean   default false,
  p_noa_family_code              in varchar2,
  p_pa_request_id                in out nocopy number,
  p_routing_group_id             in number           default null,
  p_proposed_effective_asap_flag in varchar2         default 'N',
  p_academic_discipline          in varchar2         default null,
  p_additional_info_person_id    in number           default null,
  p_additional_info_tel_number   in varchar2         default null,
  p_altered_pa_request_id        in number           default null,
  p_annuitant_indicator          in varchar2         default null,
  p_annuitant_indicator_desc     in varchar2         default null,
  p_appropriation_code1          in varchar2         default null,
  p_appropriation_code2          in varchar2         default null,
  p_approval_date                in date             default null,
  p_approving_official_full_name in varchar2         default null,
  p_approving_official_work_titl in varchar2         default null,
--  p_sf50_approval_date           in date             default null,
--  p_sf50_approving_ofcl_full_nam in varchar2         default null,
--  p_sf50_approving_ofcl_work_tit in varchar2         default null,
  p_authorized_by_person_id      in number           default null,
  p_authorized_by_title          in varchar2         default null,
  p_award_amount                 in number           default null,
  p_award_uom                    in varchar2         default null,
  p_bargaining_unit_status       in varchar2         default null,
  p_citizenship                  in varchar2         default null,
  p_concurrence_date             in date             default null,
  p_custom_pay_calc_flag         in varchar2         default null,
  p_duty_station_code            in varchar2         default null,
  p_duty_station_desc            in varchar2         default null,
  p_duty_station_id              in number           default null,
  p_duty_station_location_id     in number           default null,
  p_education_level              in varchar2         default null,
  p_effective_date               in date             default null,
  p_employee_assignment_id       in number           default null,
  p_employee_date_of_birth       in date             default null,
  p_employee_first_name          in varchar2         default null,
  p_employee_last_name           in varchar2         default null,
  p_employee_middle_names        in varchar2         default null,
  p_employee_national_identifier in varchar2         default null,
  p_fegli                        in varchar2         default null,
  p_fegli_desc                   in varchar2         default null,
  p_first_action_la_code1        in varchar2         default null,
  p_first_action_la_code2        in varchar2         default null,
  p_first_action_la_desc1        in varchar2         default null,
  p_first_action_la_desc2        in varchar2         default null,
  p_first_noa_cancel_or_correct  in varchar2         default null,
  p_first_noa_code               in varchar2         default null,
  p_first_noa_desc               in varchar2         default null,
  p_first_noa_id                 in number           default null,
  p_first_noa_pa_request_id      in number           default null,
  p_flsa_category                in varchar2         default null,
  p_forwarding_address_line1     in varchar2         default null,
  p_forwarding_address_line2     in varchar2         default null,
  p_forwarding_address_line3     in varchar2         default null,
  p_forwarding_country           in varchar2         default null,
  p_forwarding_country_short_nam in varchar2         default null,
  p_forwarding_postal_code       in varchar2         default null,
  p_forwarding_region_2          in varchar2         default null,
  p_forwarding_town_or_city      in varchar2         default null,
  p_from_adj_basic_pay           in number           default null,
  p_from_basic_pay               in number           default null,
  p_from_grade_or_level          in varchar2         default null,
  p_from_locality_adj            in number           default null,
  p_from_occ_code                in varchar2         default null,
  p_from_other_pay_amount        in number           default null,
  p_from_pay_basis               in varchar2         default null,
  p_from_pay_plan                in varchar2         default null,
  -- FWFA Changes Bug#4444609
  p_input_pay_rate_determinant      in varchar2         default null,
  p_from_pay_table_identifier    in number           default null,
  -- FWFA Changes
  p_from_position_id             in number           default null,
  p_from_position_org_line1      in varchar2         default null,
  p_from_position_org_line2      in varchar2         default null,
  p_from_position_org_line3      in varchar2         default null,
  p_from_position_org_line4      in varchar2         default null,
  p_from_position_org_line5      in varchar2         default null,
  p_from_position_org_line6      in varchar2         default null,
  p_from_position_number         in varchar2         default null,
  p_from_position_seq_no         in number           default null,
  p_from_position_title          in varchar2         default null,
  p_from_step_or_rate            in varchar2         default null,
  p_from_total_salary            in number           default null,
  p_functional_class             in varchar2         default null,
  p_notepad                      in varchar2         default null,
  p_part_time_hours              in number           default null,
  p_pay_rate_determinant         in varchar2         default null,
  p_person_id                    in number           default null,
  p_position_occupied            in varchar2         default null,
  p_proposed_effective_date      in date             default null,
  p_requested_by_person_id       in number           default null,
  p_requested_by_title           in varchar2         default null,
  p_requested_date               in date             default null,
  p_requesting_office_remarks_de in varchar2         default null,
  p_requesting_office_remarks_fl in varchar2         default null,
  p_request_number               in varchar2         default null,
  p_resign_and_retire_reason_des in varchar2         default null,
  p_retirement_plan              in varchar2         default null,
  p_retirement_plan_desc         in varchar2         default null,
  p_second_action_la_code1       in varchar2         default null,
  p_second_action_la_code2       in varchar2         default null,
  p_second_action_la_desc1       in varchar2         default null,
  p_second_action_la_desc2       in varchar2         default null,
  p_second_noa_cancel_or_correct in varchar2         default null,
  p_second_noa_code              in varchar2         default null,
  p_second_noa_desc              in varchar2         default null,
  p_second_noa_id                in number           default null,
  p_second_noa_pa_request_id     in number           default null,
  p_service_comp_date            in date             default null,
  p_supervisory_status           in varchar2         default null,
  p_tenure                       in varchar2         default null,
  p_to_adj_basic_pay             in number           default null,
  p_to_basic_pay                 in number           default null,
  p_to_grade_id                  in number           default null,
  p_to_grade_or_level            in varchar2         default null,
  p_to_job_id                    in number           default null,
  p_to_locality_adj              in number           default null,
  p_to_occ_code                  in varchar2         default null,
  p_to_organization_id           in number           default null,
  p_to_other_pay_amount          in number           default null,
  p_to_au_overtime               in number           default null,
  p_to_auo_premium_pay_indicator in varchar2         default null,
  p_to_availability_pay          in number           default null,
  p_to_ap_premium_pay_indicator  in varchar2         default null,
  p_to_retention_allowance       in number           default null,
  p_to_supervisory_differential  in number           default null,
  p_to_staffing_differential     in number           default null,
  p_to_pay_basis                 in varchar2         default null,
  p_to_pay_plan                  in varchar2         default null,
  -- FWFA Changes Bug#4444609
  p_to_pay_table_identifier      in number           default null,
  -- FWFA Changes
  p_to_position_id               in number           default null,
  p_to_position_org_line1        in varchar2         default null,
  p_to_position_org_line2        in varchar2         default null,
  p_to_position_org_line3        in varchar2         default null,
  p_to_position_org_line4        in varchar2         default null,
  p_to_position_org_line5        in varchar2         default null,
  p_to_position_org_line6        in varchar2         default null,
  p_to_position_number           in varchar2         default null,
  p_to_position_seq_no           in number           default null,
  p_to_position_title            in varchar2         default null,
  p_to_step_or_rate              in varchar2         default null,
  p_to_total_salary              in number           default null,
  p_veterans_preference          in varchar2         default null,
  p_veterans_pref_for_rif        in varchar2         default null,
  p_veterans_status              in varchar2         default null,
  p_work_schedule                in varchar2         default null,
  p_work_schedule_desc           in varchar2         default null,
  p_year_degree_attained         in number           default null,
  p_first_noa_information1       in varchar2         default null,
  p_first_noa_information2       in varchar2         default null,
  p_first_noa_information3       in varchar2         default null,
  p_first_noa_information4       in varchar2         default null,
  p_first_noa_information5       in varchar2         default null,
  p_second_lac1_information1     in varchar2         default null,
  p_second_lac1_information2     in varchar2         default null,
  p_second_lac1_information3     in varchar2         default null,
  p_second_lac1_information4     in varchar2         default null,
  p_second_lac1_information5     in varchar2         default null,
  p_second_lac2_information1     in varchar2         default null,
  p_second_lac2_information2     in varchar2         default null,
  p_second_lac2_information3     in varchar2         default null,
  p_second_lac2_information4     in varchar2         default null,
  p_second_lac2_information5     in varchar2         default null,
  p_second_noa_information1      in varchar2         default null,
  p_second_noa_information2      in varchar2         default null,
  p_second_noa_information3      in varchar2         default null,
  p_second_noa_information4      in varchar2         default null,
  p_second_noa_information5      in varchar2         default null,
  p_first_lac1_information1      in varchar2         default null,
  p_first_lac1_information2      in varchar2         default null,
  p_first_lac1_information3      in varchar2         default null,
  p_first_lac1_information4      in varchar2         default null,
  p_first_lac1_information5      in varchar2         default null,
  p_first_lac2_information1      in varchar2         default null,
  p_first_lac2_information2      in varchar2         default null,
  p_first_lac2_information3      in varchar2         default null,
  p_first_lac2_information4      in varchar2         default null,
  p_first_lac2_information5      in varchar2         default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_print_sf50_flag              in varchar2         default 'N',
  p_printer_name                 in varchar2         default null,
  p_print_back_page              in varchar2         default 'Y',
  p_1_attachment_modified_flag   in varchar2         default 'N',
  p_1_approved_flag              in varchar2         default null,
  p_1_user_name_acted_on         in varchar2         default null,
  p_1_action_taken		   in varchar2         default null,
  p_1_approval_status            in varchar2         default null,
  p_2_user_name_routed_to        in varchar2         default null,
  p_2_groupbox_id                in number           default null,
  p_2_routing_list_id            in number           default null,
  p_2_routing_seq_number         in number           default null,
  p_capped_other_pay             in number           default null,
  p_to_retention_allow_percentag in number           default null,
  p_to_supervisory_diff_percenta in number           default null,
  p_to_staffing_diff_percentage  in number           default null,
  p_award_percentage             in number           default null,
  p_rpa_type                     in varchar2         default null,
  p_mass_action_id               in number           default null,
  p_mass_action_eligible_flag    in varchar2         default null,
  p_mass_action_select_flag      in varchar2         default null,
  p_mass_action_comments         in varchar2         default null,
   -- Bug#4486823 RRR Changes
  p_payment_option               in varchar2         default null,
  p_award_salary                 in number           default null,
  -- Bug#4486823 RRR Changes
  p_par_object_version_number     out nocopy number,
  p_1_pa_routing_history_id       out nocopy number,
  p_1_prh_object_version_number   out nocopy number,
  p_2_pa_routing_history_id       out nocopy number,
  p_2_prh_object_version_number   out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< update_sf52 >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the Request for Personnel Action (RPA).
 *
 * This API updates the pa_request record and the latest pa_routing_history
 * record with details about the action taken, including the user name of the
 * person who acted on the Request for Personnel Action (RPA), the person's
 * roles and the action taken. The API creates a new record to store the
 * routing information for the Request for Personnel Action (RPA), including
 * the user name or the groupbox for each time the Request for Personnel Action
 * (RPA) is routed. If the first_nature_of_action_id changes, the API deletes
 * the mandatory remarks for the former first_nature_of_action_id from the
 * pa_remarks table, and then populates the pa_remarks table with the set of
 * mandatory remarks for the new first_nature_of_action_id.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A parent Request for Personnel Action record must exist in ghr_pa_requests.
 *
 * <p><b>Post Success</b><br>
 * The API updates the Request for Personnel Action, and inserts/updates the
 * Personnel Action Remark and the Personnel Action Routing History records as
 * required.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Request for Personnel Action, Personnel Action
 * Remark, or the Personnel Action Routing History records and an error is
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_pa_request_id Uniquely identifies the Request for Personnel Action.
 * @param p_noa_family_code {@rep:casecolumn GHR_PA_REQUESTS.NOA_FAMILY_CODE}
 * @param p_routing_group_id {@rep:casecolumn GHR_PA_REQUESTS.ROUTING_GROUP_ID}
 * @param p_par_object_version_number Pass in the current version number of the
 * pa_request_id that you are updating. When the API completes, if p_validate
 * is false, sets the new version number of the updated pa_request_id. If
 * p_validate is true, sets the same value passed in.
 * @param p_proposed_effective_asap_flag Flag to indicate ASAP for proposed
 * effective date. Valid Values are Y - Yes, N - No.
 * @param p_academic_discipline Academic Discipline. Valid values are defined
 * by 'GHR_US_ACADEMIC_DISCIPLINE' lookup type.
 * @param p_additional_info_person_id Uniquely identifies the Person chosen as
 * the Additional Information Person.
 * @param p_additional_info_tel_number {@rep:casecolumn
 * GHR_PA_REQUESTS.ADDITIONAL_INFO_TEL_NUMBER}
 * @param p_altered_pa_request_id {@rep:casecolumn
 * GHR_PA_REQUESTS.ALTERED_PA_REQUEST_ID}
 * @param p_annuitant_indicator Annuitant Indicator. Valid values are defined
 * by 'GHR_US_ANNUITANT_INDICATOR' lookup type.
 * @param p_annuitant_indicator_desc Annuitant Indicator Description. Valid
 * values are defined by 'GHR_US_ANNUITANT_INDICATOR' lookup meaning.
 * @param p_appropriation_code1 Appropriation Code1. Valid values are defined
 * by 'GHR_US_APPROPRIATION_CODE1' lookup type.
 * @param p_appropriation_code2 Appropriation Code2. Valid values are defined
 * by 'GHR_US_APPROPRIATION_CODE2' lookup type.
 * @param p_approval_date {@rep:casecolumn GHR_PA_REQUESTS.APPROVAL_DATE}
 * @param p_approving_official_full_name {@rep:casecolumn
 * GHR_PA_REQUESTS.APPROVING_OFFICIAL_FULL_NAME}
 * @param p_approving_official_work_titl {@rep:casecolumn
 * GHR_PA_REQUESTS.APPROVING_OFFICIAL_WORK_TITLE}
 * @param p_authorized_by_person_id Uniquely identifies the person authorizing
 * the Request for Personnel Action.
 * @param p_authorized_by_title {@rep:casecolumn
 * GHR_PA_REQUESTS.AUTHORIZED_BY_TITLE}
 * @param p_award_amount {@rep:casecolumn GHR_PA_REQUESTS.AWARD_AMOUNT}
 * @param p_award_uom {@rep:casecolumn GHR_PA_REQUESTS.AWARD_UOM}
 * @param p_bargaining_unit_status Bargaining Unit Status. Valid values are
 * defined by 'GHR_US_BARG_UNIT_STATUS' lookup type.
 * @param p_citizenship Citizenship. Valid values are defined by
 * 'GHR_US_CITIZENSHIP' lookup type.
 * @param p_concurrence_date {@rep:casecolumn GHR_PA_REQUESTS.CONCURRENCE_DATE}
 * @param p_custom_pay_calc_flag {@rep:casecolumn
 * GHR_PA_REQUESTS.CUSTOM_PAY_CALC_FLAG}
 * @param p_duty_station_code {@rep:casecolumn
 * GHR_PA_REQUESTS.DUTY_STATION_CODE}
 * @param p_duty_station_desc {@rep:casecolumn
 * GHR_PA_REQUESTS.DUTY_STATION_DESC}
 * @param p_duty_station_id {@rep:casecolumn GHR_PA_REQUESTS.DUTY_STATION_ID}
 * @param p_duty_station_location_id {@rep:casecolumn
 * GHR_PA_REQUESTS.DUTY_STATION_LOCATION_ID}
 * @param p_education_level Education Level. Valid values are defined by
 * 'GHR_US_EDUCATION_LEVEL' lookup type.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_employee_assignment_id {@rep:casecolumn
 * GHR_PA_REQUESTS.EMPLOYEE_ASSIGNMENT_ID}
 * @param p_employee_date_of_birth {@rep:casecolumn
 * GHR_PA_REQUESTS.EMPLOYEE_DATE_OF_BIRTH}
 * @param p_employee_first_name {@rep:casecolumn
 * GHR_PA_REQUESTS.EMPLOYEE_FIRST_NAME}
 * @param p_employee_last_name {@rep:casecolumn
 * GHR_PA_REQUESTS.EMPLOYEE_LAST_NAME}
 * @param p_employee_middle_names {@rep:casecolumn
 * GHR_PA_REQUESTS.EMPLOYEE_MIDDLE_NAMES}
 * @param p_employee_national_identifier {@rep:casecolumn
 * GHR_PA_REQUESTS.EMPLOYEE_NATIONAL_IDENTIFIER}
 * @param p_fegli FEGLI. Valid values are defined by 'GHR_US_FEGLI' lookup
 * type.
 * @param p_fegli_desc FEGLI Description. Valid values are defined by
 * 'GHR_US_FEGLI' lookup meaning.
 * @param p_first_action_la_code1 Legal Authority Code. Valid values are
 * defined by 'GHR_US_LEGAL_AUTHORITY' lookup type.
 * @param p_first_action_la_code2 Legal Authority Code. Valid values are
 * defined by 'GHR_US_LEGAL_AUTHORITY' lookup type.
 * @param p_first_action_la_desc1 Legal Authority Code description.
 * @param p_first_action_la_desc2 Legal Authority Code description.
 * @param p_first_noa_cancel_or_correct {@rep:casecolumn
 * GHR_PA_REQUESTS.FIRST_NOA_CANCEL_OR_CORRECT}
 * @param p_first_noa_code {@rep:casecolumn GHR_PA_REQUESTS.FIRST_NOA_CODE}
 * @param p_first_noa_desc {@rep:casecolumn GHR_PA_REQUESTS.FIRST_NOA_DESC}
 * @param p_first_noa_id {@rep:casecolumn GHR_PA_REQUESTS.FIRST_NOA_ID}
 * @param p_first_noa_pa_request_id {@rep:casecolumn
 * GHR_PA_REQUESTS.FIRST_NOA_PA_REQUEST_ID}
 * @param p_flsa_category FLSA Category. Valid values are defined by
 * 'GHR_US_FLSA_CATEGORY' lookup type.
 * @param p_forwarding_address_line1 {@rep:casecolumn
 * GHR_PA_REQUESTS.FORWARDING_ADDRESS_LINE1}
 * @param p_forwarding_address_line2 {@rep:casecolumn
 * GHR_PA_REQUESTS.FORWARDING_ADDRESS_LINE2}
 * @param p_forwarding_address_line3 {@rep:casecolumn
 * GHR_PA_REQUESTS.FORWARDING_ADDRESS_LINE3}
 * @param p_forwarding_country {@rep:casecolumn
 * GHR_PA_REQUESTS.FORWARDING_COUNTRY}
 * @param p_forwarding_country_short_nam {@rep:casecolumn
 * GHR_PA_REQUESTS.FORWARDING_COUNTRY_SHORT_NAME}
 * @param p_forwarding_postal_code {@rep:casecolumn
 * GHR_PA_REQUESTS.FORWARDING_POSTAL_CODE}
 * @param p_forwarding_region_2 {@rep:casecolumn
 * GHR_PA_REQUESTS.FORWARDING_REGION_2}
 * @param p_forwarding_town_or_city {@rep:casecolumn
 * GHR_PA_REQUESTS.FORWARDING_TOWN_OR_CITY}
 * @param p_from_adj_basic_pay {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_ADJ_BASIC_PAY}
 * @param p_from_basic_pay {@rep:casecolumn GHR_PA_REQUESTS.FROM_BASIC_PAY}
 * @param p_from_grade_or_level {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_GRADE_OR_LEVEL}
 * @param p_from_locality_adj {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_LOCALITY_ADJ}
 * @param p_from_occ_code {@rep:casecolumn GHR_PA_REQUESTS.FROM_OCC_CODE}
 * @param p_from_other_pay_amount {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_OTHER_PAY_AMOUNT}
 * @param p_from_pay_basis From Pay basis. Valid values are defined by
 * 'GHR_US_PAY_BASIS' lookup type.
 * @param p_from_pay_plan {@rep:casecolumn GHR_PA_REQUESTS.FROM_PAY_PLAN}
 * @param p_from_position_id {@rep:casecolumn GHR_PA_REQUESTS.FROM_POSITION_ID}
 * @param p_from_position_org_line1 {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_POSITION_ORG_LINE1}
 * @param p_from_position_org_line2 {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_POSITION_ORG_LINE2}
 * @param p_from_position_org_line3 {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_POSITION_ORG_LINE3}
 * @param p_from_position_org_line4 {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_POSITION_ORG_LINE4}
 * @param p_from_position_org_line5 {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_POSITION_ORG_LINE5}
 * @param p_from_position_org_line6 {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_POSITION_ORG_LINE6}
 * @param p_from_position_number {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_POSITION_NUMBER}
 * @param p_from_position_seq_no {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_POSITION_SEQ_NO}
 * @param p_from_position_title {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_POSITION_TITLE}
 * @param p_from_step_or_rate {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_STEP_OR_RATE}
 * @param p_from_total_salary {@rep:casecolumn
 * GHR_PA_REQUESTS.FROM_TOTAL_SALARY}
 * @param p_functional_class Functional Class. Valid values are defined by
 * 'GHR_US_FUNCTIONAL_CLASS' lookup type.
 * @param p_notepad {@rep:casecolumn GHR_PA_REQUESTS.NOTEPAD}
 * @param p_part_time_hours {@rep:casecolumn GHR_PA_REQUESTS.PART_TIME_HOURS}
 * @param p_pay_rate_determinant Pay Rate Determinant. Valid values are defined
 * by 'GHR_US_PAY_RATE_DETERMINANT' lookup type.
 * @param p_person_id Uniquely identifies the Person for whom you update the
 * Request for Personnel Action record.
 * @param p_position_occupied {@rep:casecolumn
 * GHR_PA_REQUESTS.POSITION_OCCUPIED}
 * @param p_proposed_effective_date {@rep:casecolumn
 * GHR_PA_REQUESTS.PROPOSED_EFFECTIVE_DATE}
 * @param p_requested_by_person_id {@rep:casecolumn
 * GHR_PA_REQUESTS.REQUESTED_BY_PERSON_ID}
 * @param p_requested_by_title {@rep:casecolumn
 * GHR_PA_REQUESTS.REQUESTED_BY_TITLE}
 * @param p_requested_date {@rep:casecolumn GHR_PA_REQUESTS.REQUESTED_DATE}
 * @param p_requesting_office_remarks_de Requesting Office remarks description
 * @param p_requesting_office_remarks_fl Flag to indicate if there are remarks
 * from the Requesting Office. Valid values are Y - Yes, N - No.
 * @param p_request_number {@rep:casecolumn GHR_PA_REQUESTS.REQUEST_NUMBER}
 * @param p_resign_and_retire_reason_des {@rep:casecolumn
 * GHR_PA_REQUESTS.RESIGN_AND_RETIRE_REASON_DESC}
 * @param p_retirement_plan Retirement Plan. Valid values are defined by
 * 'GHR_US_RETIREMENT_PLAN' lookup type.
 * @param p_retirement_plan_desc Retirement Plan Description. Valid values are
 * defined by 'GHR_US_RETIREMENT_PLAN' lookup meaning.
 * @param p_second_action_la_code1 Legal Authority lookup code. Valid values
 * are defined by 'GHR_US_LEGAL_AUTHORITY' lookup type.
 * @param p_second_action_la_code2 Legal Authority lookup code. Valid values
 * are defined by 'GHR_US_LEGAL_AUTHORITY' lookup type.
 * @param p_second_action_la_desc1 Legal Authority Code description.
 * @param p_second_action_la_desc2 Legal Authority Code description.
 * @param p_second_noa_cancel_or_correct {@rep:casecolumn
 * GHR_PA_REQUESTS.SECOND_NOA_CANCEL_OR_CORRECT}
 * @param p_second_noa_code {@rep:casecolumn GHR_PA_REQUESTS.SECOND_NOA_CODE}
 * @param p_second_noa_desc {@rep:casecolumn GHR_PA_REQUESTS.SECOND_NOA_DESC}
 * @param p_second_noa_id {@rep:casecolumn GHR_PA_REQUESTS.SECOND_NOA_ID}
 * @param p_second_noa_pa_request_id {@rep:casecolumn
 * GHR_PA_REQUESTS.SECOND_NOA_PA_REQUEST_ID}
 * @param p_service_comp_date {@rep:casecolumn
 * GHR_PA_REQUESTS.SERVICE_COMP_DATE}
 * @param p_supervisory_status Supervisory Status. Valid values are defined by
 * 'GHR_US_SUPERVISORY_STATUS' lookup type.
 * @param p_tenure Tenure. Valid values are defined by 'GHR_US_TENURE' lookup
 * type.
 * @param p_to_adj_basic_pay {@rep:casecolumn GHR_PA_REQUESTS.TO_ADJ_BASIC_PAY}
 * @param p_to_basic_pay {@rep:casecolumn GHR_PA_REQUESTS.TO_BASIC_PAY}
 * @param p_to_grade_id {@rep:casecolumn GHR_PA_REQUESTS.TO_GRADE_ID}
 * @param p_to_grade_or_level {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_GRADE_OR_LEVEL}
 * @param p_to_job_id {@rep:casecolumn GHR_PA_REQUESTS.TO_JOB_ID}
 * @param p_to_locality_adj {@rep:casecolumn GHR_PA_REQUESTS.TO_LOCALITY_ADJ}
 * @param p_to_occ_code {@rep:casecolumn GHR_PA_REQUESTS.TO_OCC_CODE}
 * @param p_to_organization_id {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_ORGANIZATION_ID}
 * @param p_to_other_pay_amount {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_OTHER_PAY_AMOUNT}
 * @param p_to_au_overtime {@rep:casecolumn GHR_PA_REQUESTS.TO_AU_OVERTIME}
 * @param p_to_auo_premium_pay_indicator To authorized uncontrollable overtime
 * premium pay indicator. Valid values are defined by 'GHR_US_PREM_PAY_IND'
 * lookup type.
 * @param p_to_availability_pay {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_AVAILABILITY_PAY}
 * @param p_to_ap_premium_pay_indicator {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_AP_PREMIUM_PAY_INDICATOR}
 * @param p_to_retention_allowance {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_RETENTION_ALLOWANCE}
 * @param p_to_supervisory_differential {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_SUPERVISORY_DIFFERENTIAL}
 * @param p_to_staffing_differential {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_STAFFING_DIFFERENTIAL}
 * @param p_to_pay_basis To Pay basis. Valid values are defined by
 * 'GHR_US_PAY_BASIS' lookup type.
 * @param p_to_pay_plan {@rep:casecolumn GHR_PA_REQUESTS.TO_PAY_PLAN}
 * @param p_to_position_id {@rep:casecolumn GHR_PA_REQUESTS.TO_POSITION_ID}
 * @param p_to_position_org_line1 {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_POSITION_ORG_LINE1}
 * @param p_to_position_org_line2 {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_POSITION_ORG_LINE2}
 * @param p_to_position_org_line3 {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_POSITION_ORG_LINE3}
 * @param p_to_position_org_line4 {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_POSITION_ORG_LINE4}
 * @param p_to_position_org_line5 {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_POSITION_ORG_LINE5}
 * @param p_to_position_org_line6 {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_POSITION_ORG_LINE6}
 * @param p_to_position_number {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_POSITION_NUMBER}
 * @param p_to_position_seq_no {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_POSITION_SEQ_NO}
 * @param p_to_position_title {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_POSITION_TITLE}
 * @param p_to_step_or_rate {@rep:casecolumn GHR_PA_REQUESTS.TO_STEP_OR_RATE}
 * @param p_to_total_salary {@rep:casecolumn GHR_PA_REQUESTS.TO_TOTAL_SALARY}
 * @param p_veterans_preference Veterans Preference. Valid values are defined
 * by 'GHR_US_VETERANS_PREF' lookup type.
 * @param p_veterans_pref_for_rif Veterans Preference for Reduction in Force.
 * Valid values are defined by 'GHR_US_VETERANS_PREF_FOR_RIF' lookup type.
 * @param p_veterans_status Veterans Status. Valid values are defined by
 * 'GHR_US_VET_STATUS' lookup type
 * @param p_work_schedule Work Schedule. Valid values are defined by
 * 'GHR_US_WORK_SCHEDULE' lookup type.
 * @param p_work_schedule_desc Work Schedule Description. Valid values are
 * defined by 'GHR_US_WORK_SCHEDULE' lookup meaning
 * @param p_year_degree_attained {@rep:casecolumn
 * GHR_PA_REQUESTS.YEAR_DEGREE_ATTAINED}
 * @param p_first_noa_information1 First Nature of Action description Insertion
 * Value1
 * @param p_first_noa_information2 First Nature of Action description Insertion
 * Value2
 * @param p_first_noa_information3 First Nature of Action description Insertion
 * Value3
 * @param p_first_noa_information4 First Nature of Action description Insertion
 * Value4
 * @param p_first_noa_information5 First Nature of Action description Insertion
 * Value5
 * @param p_second_lac1_information1 Second Legal Authority Code1 Description
 * Insertion Value1
 * @param p_second_lac1_information2 Second Legal Authority Code1 Description
 * Insertion Value2
 * @param p_second_lac1_information3 Second Legal Authority Code1 Description
 * Insertion Value3
 * @param p_second_lac1_information4 Second Legal Authority Code1 Description
 * Insertion Value4
 * @param p_second_lac1_information5 Second Legal Authority Code1 Description
 * Insertion Value5
 * @param p_second_lac2_information1 Second Legal Authority Code2 Description
 * Insertion Value1
 * @param p_second_lac2_information2 Second Legal Authority Code2 Description
 * Insertion Value2
 * @param p_second_lac2_information3 Second Legal Authority Code2 Description
 * Insertion Value3
 * @param p_second_lac2_information4 Second Legal Authority Code2 Description
 * Insertion Value4
 * @param p_second_lac2_information5 Second Legal Authority Code2 Description
 * Insertion Value5
 * @param p_second_noa_information1 Second Nature of Action description
 * Insertion Value1
 * @param p_second_noa_information2 Second Nature of Action description
 * Insertion Value2
 * @param p_second_noa_information3 Second Nature of Action description
 * Insertion Value3
 * @param p_second_noa_information4 Second Nature of Action description
 * Insertion Value4
 * @param p_second_noa_information5 Second Nature of Action description
 * Insertion Value5
 * @param p_first_lac1_information1 First Legal Authority Code1 Description
 * Insertion Value1.
 * @param p_first_lac1_information2 First Legal Authority Code1 Description
 * Insertion Value2.
 * @param p_first_lac1_information3 First Legal Authority Code1 Description
 * Insertion Value3.
 * @param p_first_lac1_information4 First Legal Authority Code1 Description
 * Insertion Value4.
 * @param p_first_lac1_information5 First Legal Authority Code1 Description
 * Insertion Value5.
 * @param p_first_lac2_information1 First Legal Authority Code2 Description
 * Insertion Value1.
 * @param p_first_lac2_information2 First Legal Authority Code2 Description
 * Insertion Value2.
 * @param p_first_lac2_information3 First Legal Authority Code2 Description
 * Insertion Value3.
 * @param p_first_lac2_information4 First Legal Authority Code2 Description
 * Insertion Value4.
 * @param p_first_lac2_information5 First Legal Authority Code2 Description
 * Insertion Value5.
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
 * @param p_print_sf50_flag Print Flag Yes or No.
 * @param p_printer_name Printer Name
 * @param p_u_attachment_modified_flag {@rep:casecolumn
 * GHR_PA_ROUTING_HISTORY.ATTACHMENT_MODIFIED_FLAG}
 * @param p_u_approved_flag {@rep:casecolumn
 * GHR_PA_ROUTING_HISTORY.APPROVED_FLAG}
 * @param p_u_user_name_acted_on User name of the person who acted on the
 * Request for Personnel Action (RPA)
 * @param p_u_action_taken Action taken by the user
 * @param p_u_approval_status {@rep:casecolumn GHR_PA_REQUESTS.STATUS}
 * @param p_i_user_name_routed_to The user name of the person to whom the RPA
 * is routed.
 * @param p_i_groupbox_id Groupbox to which the Request for Personnel Action
 * (RPA) is routed. Note: You can designate a groupbox or a user name as a
 * routing destination.
 * @param p_i_routing_list_id Routing List to which you are routing the Request
 * for Personnel Action (RPA)
 * @param p_i_routing_seq_number Sequence number within the Routing list
 * @param p_capped_other_pay Other Pay amount after being reduced (capped) due
 * to hitting the Pay Cap.
 * @param p_to_retention_allow_percentag {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_RETENTION_ALLOW_PERCENTAGE}
 * @param p_to_supervisory_diff_percenta {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_SUPERVISORY_DIFF_PERCENTAGE}
 * @param p_to_staffing_diff_percentage {@rep:casecolumn
 * GHR_PA_REQUESTS.TO_STAFFING_DIFF_PERCENTAGE}
 * @param p_award_percentage {@rep:casecolumn GHR_PA_REQUESTS.AWARD_PERCENTAGE}
 * @param p_rpa_type {@rep:casecolumn GHR_PA_REQUESTS.RPA_TYPE}
 * @param p_mass_action_id {@rep:casecolumn GHR_PA_REQUESTS.MASS_ACTION_ID}
 * @param p_mass_action_eligible_flag {@rep:casecolumn
 * GHR_PA_REQUESTS.MASS_ACTION_ELIGIBLE_FLAG}
 * @param p_mass_action_select_flag {@rep:casecolumn
 * GHR_PA_REQUESTS.MASS_ACTION_SELECT_FLAG}
 * @param p_mass_action_comments {@rep:casecolumn
 * GHR_PA_REQUESTS.MASS_ACTION_COMMENTS}
 * @param p_payment_option Payment option for the Incentive Family
 * @param p_award_salary Award Salary used for award calculation
 * @param p_u_prh_object_version_number If p_validate is false, then set to the
 * version number of the updated routing history that contains the action
 * details. If p_validate is true, then the value of the version number is
 * retained from the routing record containing the original routing details.
 * @param p_i_pa_routing_history_id If p_validate is false, then set to the
 * updated routing history that contains the action details. If p_validate is
 * true , it is set to null.
 * @param p_i_prh_object_version_number If p_validate is false, then set to the
 * version_number of the routing history record that contains the routing
 * details. If p_validate is true, it is set to null.
 * @param p_input_pay_rate_determinant Pay Rate Determinant passed to the pay calculation procedure
 * @param p_from_pay_table_identifier Pay Table ID on the RPA effective date
 * @param p_to_pay_table_identifier Pay Table ID after pay calculation has completed
 * @param p_print_back_page If Print Back Page is set to Yes then NPA back page will be printed
 * @rep:displayname Update Request for Personnel Action
 * @rep:category BUSINESS_ENTITY GHR_REQ_FOR_PERSONNEL_ACTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
    procedure update_sf52
 (p_validate                     in boolean default false,
  p_pa_request_id                in number,
 -- p_pa_notification_id           in number           default hr_api.g_number,
  p_noa_family_code              in varchar2         default hr_api.g_varchar2,
  p_routing_group_id             in number           default hr_api.g_number,
  p_par_object_version_number    in out nocopy number,
  p_proposed_effective_asap_flag in varchar2         default hr_api.g_varchar2,
  p_academic_discipline          in varchar2         default hr_api.g_varchar2,
  p_additional_info_person_id    in number           default hr_api.g_number,
  p_additional_info_tel_number   in varchar2         default hr_api.g_varchar2,
--p_agency_code                  in varchar2         default hr_api.g_varchar2,
  p_altered_pa_request_id        in number           default hr_api.g_number,
  p_annuitant_indicator          in varchar2         default hr_api.g_varchar2,
  p_annuitant_indicator_desc     in varchar2         default hr_api.g_varchar2,
  p_appropriation_code1          in varchar2         default hr_api.g_varchar2,
  p_appropriation_code2          in varchar2         default hr_api.g_varchar2,
  p_approval_date                in date             default hr_api.g_date,
  p_approving_official_full_name in varchar2         default hr_api.g_varchar2,
  p_approving_official_work_titl in varchar2         default hr_api.g_varchar2,
--  p_sf50_approval_date           in date             default hr_api.g_date,
--  p_sf50_approving_ofcl_full_nam in varchar2         default hr_api.g_varchar2,
--  p_sf50_approving_ofcl_work_tit in varchar2         default hr_api.g_varchar2,
  p_authorized_by_person_id      in number           default hr_api.g_number,
  p_authorized_by_title          in varchar2         default hr_api.g_varchar2,
  p_award_amount                 in number           default hr_api.g_number,
  p_award_uom                    in varchar2         default hr_api.g_varchar2,
  p_bargaining_unit_status       in varchar2         default hr_api.g_varchar2,
  p_citizenship                  in varchar2         default hr_api.g_varchar2,
  p_concurrence_date             in date             default hr_api.g_date,
  p_custom_pay_calc_flag         in varchar2         default hr_api.g_varchar2,
  p_duty_station_code            in varchar2         default hr_api.g_varchar2,
  p_duty_station_desc            in varchar2         default hr_api.g_varchar2,
  p_duty_station_id              in number           default hr_api.g_number,
  p_duty_station_location_id     in number           default hr_api.g_number,
  p_education_level              in varchar2         default hr_api.g_varchar2,
  p_effective_date               in date             default hr_api.g_date,
  p_employee_assignment_id       in number           default hr_api.g_number,
  p_employee_date_of_birth       in date             default hr_api.g_date,
 --p_employee_dept_or_agency      in varchar2         default hr_api.g_varchar2,
  p_employee_first_name          in varchar2         default hr_api.g_varchar2,
  p_employee_last_name           in varchar2         default hr_api.g_varchar2,
  p_employee_middle_names        in varchar2         default hr_api.g_varchar2,
  p_employee_national_identifier in varchar2         default hr_api.g_varchar2,
  p_fegli                        in varchar2         default hr_api.g_varchar2,
  p_fegli_desc                   in varchar2         default hr_api.g_varchar2,
  p_first_action_la_code1        in varchar2         default hr_api.g_varchar2,
  p_first_action_la_code2        in varchar2         default hr_api.g_varchar2,
  p_first_action_la_desc1        in varchar2         default hr_api.g_varchar2,
  p_first_action_la_desc2        in varchar2         default hr_api.g_varchar2,
  p_first_noa_cancel_or_correct  in varchar2         default hr_api.g_varchar2,
  p_first_noa_code               in varchar2         default hr_api.g_varchar2,
  p_first_noa_desc               in varchar2         default hr_api.g_varchar2,
  p_first_noa_id                 in number           default hr_api.g_number,
  p_first_noa_pa_request_id      in number           default hr_api.g_number,
  p_flsa_category                in varchar2         default hr_api.g_varchar2,
  p_forwarding_address_line1     in varchar2         default hr_api.g_varchar2,
  p_forwarding_address_line2     in varchar2         default hr_api.g_varchar2,
  p_forwarding_address_line3     in varchar2         default hr_api.g_varchar2,
  p_forwarding_country           in varchar2         default hr_api.g_varchar2,
  p_forwarding_country_short_nam in varchar2         default hr_api.g_varchar2,
  p_forwarding_postal_code       in varchar2         default hr_api.g_varchar2,
  p_forwarding_region_2          in varchar2         default hr_api.g_varchar2,
  p_forwarding_town_or_city      in varchar2         default hr_api.g_varchar2,
  p_from_adj_basic_pay           in number           default hr_api.g_number,
--  p_from_agency_code             in varchar2         default hr_api.g_varchar2,
--  p_from_agency_desc             in varchar2         default hr_api.g_varchar2,
  p_from_basic_pay               in number           default hr_api.g_number,
  p_from_grade_or_level          in varchar2         default hr_api.g_varchar2,
  p_from_locality_adj            in number           default hr_api.g_number,
  p_from_occ_code                in varchar2         default hr_api.g_varchar2,
--  p_from_office_symbol           in varchar2         default hr_api.g_varchar2,
  p_from_other_pay_amount        in number           default hr_api.g_number,
  p_from_pay_basis               in varchar2         default hr_api.g_varchar2,
  p_from_pay_plan                in varchar2         default hr_api.g_varchar2,
  -- FWFA Changes Bug#4444609
  p_input_pay_rate_determinant  in varchar2        default hr_api.g_varchar2,
  p_from_pay_table_identifier   in number          default hr_api.g_number,
  -- FWFA Changes
  p_from_position_id             in number           default hr_api.g_number,
  p_from_position_org_line1      in varchar2         default hr_api.g_varchar2,
  p_from_position_org_line2      in varchar2         default hr_api.g_varchar2,
  p_from_position_org_line3      in varchar2         default hr_api.g_varchar2,
  p_from_position_org_line4      in varchar2         default hr_api.g_varchar2,
  p_from_position_org_line5      in varchar2         default hr_api.g_varchar2,
  p_from_position_org_line6      in varchar2         default hr_api.g_varchar2,
  p_from_position_number         in varchar2         default hr_api.g_varchar2,
  p_from_position_seq_no         in number           default hr_api.g_number,
  p_from_position_title          in varchar2         default hr_api.g_varchar2,
  p_from_step_or_rate            in varchar2         default hr_api.g_varchar2,
  p_from_total_salary            in number           default hr_api.g_number,
  p_functional_class             in varchar2         default hr_api.g_varchar2,
  p_notepad                      in varchar2         default hr_api.g_varchar2,
  p_part_time_hours              in number           default hr_api.g_number,
  p_pay_rate_determinant         in varchar2         default hr_api.g_varchar2,
  p_person_id                    in number           default hr_api.g_number,
  p_position_occupied            in varchar2         default hr_api.g_varchar2,
  p_proposed_effective_date      in date             default hr_api.g_date,
  p_requested_by_person_id       in number           default hr_api.g_number,
  p_requested_by_title           in varchar2         default hr_api.g_varchar2,
  p_requested_date               in date             default hr_api.g_date,
  p_requesting_office_remarks_de in varchar2         default hr_api.g_varchar2,
  p_requesting_office_remarks_fl in varchar2         default hr_api.g_varchar2,
  p_request_number               in varchar2         default hr_api.g_varchar2,
  p_resign_and_retire_reason_des in varchar2         default hr_api.g_varchar2,
  p_retirement_plan              in varchar2         default hr_api.g_varchar2,
  p_retirement_plan_desc         in varchar2         default hr_api.g_varchar2,
  p_second_action_la_code1       in varchar2         default hr_api.g_varchar2,
  p_second_action_la_code2       in varchar2         default hr_api.g_varchar2,
  p_second_action_la_desc1       in varchar2         default hr_api.g_varchar2,
  p_second_action_la_desc2       in varchar2         default hr_api.g_varchar2,
  p_second_noa_cancel_or_correct in varchar2         default hr_api.g_varchar2,
  p_second_noa_code              in varchar2         default hr_api.g_varchar2,
  p_second_noa_desc              in varchar2         default hr_api.g_varchar2,
  p_second_noa_id                in number           default hr_api.g_number,
  p_second_noa_pa_request_id     in number           default hr_api.g_number,
  p_service_comp_date            in date             default hr_api.g_date,
  p_supervisory_status           in varchar2         default hr_api.g_varchar2,
  p_tenure                       in varchar2         default hr_api.g_varchar2,
  p_to_adj_basic_pay             in number           default hr_api.g_number,
  p_to_basic_pay                 in number           default hr_api.g_number,
  p_to_grade_id                  in number           default hr_api.g_number,
  p_to_grade_or_level            in varchar2         default hr_api.g_varchar2,
  p_to_job_id                    in number           default hr_api.g_number,
  p_to_locality_adj              in number           default hr_api.g_number,
  p_to_occ_code                  in varchar2         default hr_api.g_varchar2,
--  p_to_office_symbol             in varchar2         default hr_api.g_varchar2,
  p_to_organization_id           in number           default hr_api.g_number,
  p_to_other_pay_amount          in number           default hr_api.g_number,
  p_to_au_overtime               in number           default hr_api.g_number,
  p_to_auo_premium_pay_indicator in varchar2         default hr_api.g_varchar2,
  p_to_availability_pay          in number           default hr_api.g_number,
  p_to_ap_premium_pay_indicator  in varchar2         default hr_api.g_varchar2,
  p_to_retention_allowance       in number           default hr_api.g_number,
  p_to_supervisory_differential  in number           default hr_api.g_number,
  p_to_staffing_differential     in number           default hr_api.g_number,
  p_to_pay_basis                 in varchar2         default hr_api.g_varchar2,
  p_to_pay_plan                  in varchar2         default hr_api.g_varchar2,
  -- FWFA Changes Bug#4444609
  p_to_pay_table_identifier      in number           default hr_api.g_number,
  -- FWFA Changes
  p_to_position_id               in number           default hr_api.g_number,
  p_to_position_org_line1        in varchar2         default hr_api.g_varchar2,
  p_to_position_org_line2        in varchar2         default hr_api.g_varchar2,
  p_to_position_org_line3        in varchar2         default hr_api.g_varchar2,
  p_to_position_org_line4        in varchar2         default hr_api.g_varchar2,
  p_to_position_org_line5        in varchar2         default hr_api.g_varchar2,
  p_to_position_org_line6        in varchar2         default hr_api.g_varchar2,
  p_to_position_number           in varchar2         default hr_api.g_varchar2,
  p_to_position_seq_no           in number           default hr_api.g_number,
  p_to_position_title            in varchar2         default hr_api.g_varchar2,
  p_to_step_or_rate              in varchar2         default hr_api.g_varchar2,
  p_to_total_salary              in number           default hr_api.g_number,
  p_veterans_preference          in varchar2         default hr_api.g_varchar2,
  p_veterans_pref_for_rif        in varchar2         default hr_api.g_varchar2,
  p_veterans_status              in varchar2         default hr_api.g_varchar2,
  p_work_schedule                in varchar2         default hr_api.g_varchar2,
  p_work_schedule_desc           in varchar2         default hr_api.g_varchar2,
  p_year_degree_attained         in number           default hr_api.g_number,
  p_first_noa_information1       in varchar2         default hr_api.g_varchar2,
  p_first_noa_information2       in varchar2         default hr_api.g_varchar2,
  p_first_noa_information3       in varchar2         default hr_api.g_varchar2,
  p_first_noa_information4       in varchar2         default hr_api.g_varchar2,
  p_first_noa_information5       in varchar2         default hr_api.g_varchar2,
  p_second_lac1_information1     in varchar2         default hr_api.g_varchar2,
  p_second_lac1_information2     in varchar2         default hr_api.g_varchar2,
  p_second_lac1_information3     in varchar2         default hr_api.g_varchar2,
  p_second_lac1_information4     in varchar2         default hr_api.g_varchar2,
  p_second_lac1_information5     in varchar2         default hr_api.g_varchar2,
  p_second_lac2_information1     in varchar2         default hr_api.g_varchar2,
  p_second_lac2_information2     in varchar2         default hr_api.g_varchar2,
  p_second_lac2_information3     in varchar2         default hr_api.g_varchar2,
  p_second_lac2_information4     in varchar2         default hr_api.g_varchar2,
  p_second_lac2_information5     in varchar2         default hr_api.g_varchar2,
  p_second_noa_information1      in varchar2         default hr_api.g_varchar2,
  p_second_noa_information2      in varchar2         default hr_api.g_varchar2,
  p_second_noa_information3      in varchar2         default hr_api.g_varchar2,
  p_second_noa_information4      in varchar2         default hr_api.g_varchar2,
  p_second_noa_information5      in varchar2         default hr_api.g_varchar2,
  p_first_lac1_information1      in varchar2         default hr_api.g_varchar2,
  p_first_lac1_information2      in varchar2         default hr_api.g_varchar2,
  p_first_lac1_information3      in varchar2         default hr_api.g_varchar2,
  p_first_lac1_information4      in varchar2         default hr_api.g_varchar2,
  p_first_lac1_information5      in varchar2         default hr_api.g_varchar2,
  p_first_lac2_information1      in varchar2         default hr_api.g_varchar2,
  p_first_lac2_information2      in varchar2         default hr_api.g_varchar2,
  p_first_lac2_information3      in varchar2         default hr_api.g_varchar2,
  p_first_lac2_information4      in varchar2         default hr_api.g_varchar2,
  p_first_lac2_information5      in varchar2         default hr_api.g_varchar2,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_print_sf50_flag              in varchar2         default 'N',
  p_printer_name                 in varchar2         default null,
  p_print_back_page              in varchar2         default 'Y',
  p_u_attachment_modified_flag   in varchar2  	     default hr_api.g_varchar2,
  p_u_approved_flag              in varchar2	     default hr_api.g_varchar2,
  p_u_user_name_acted_on         in varchar2  	     default hr_api.g_varchar2,
  p_u_action_taken               in varchar2  	     default null,
  p_u_approval_status            in varchar2         default hr_api.g_varchar2, -- check this
  p_i_user_name_routed_to        in varchar2  	     default null,
  p_i_groupbox_id                in number    	     default null,
  p_i_routing_list_id            in number    	     default null,
  p_i_routing_seq_number         in number    	     default null,
  p_capped_other_pay             in number           default null,
  p_to_retention_allow_percentag in number           default hr_api.g_number,
  p_to_supervisory_diff_percenta in number           default hr_api.g_number,
  p_to_staffing_diff_percentage  in number           default hr_api.g_number,
  p_award_percentage             in number           default hr_api.g_number,
  p_rpa_type                     in varchar2         default hr_api.g_varchar2,
  p_mass_action_id               in number           default hr_api.g_number,
  p_mass_action_eligible_flag    in varchar2         default hr_api.g_varchar2,
  p_mass_action_select_flag      in varchar2         default hr_api.g_varchar2,
  p_mass_action_comments         in varchar2         default hr_api.g_varchar2,
   -- Bug#4486823 RRR Changes
  p_payment_option               in varchar2         default null,
  p_award_salary                 in number           default hr_api.g_number,
  -- Bug#4486823 RRR Changes
  p_u_prh_object_version_number   out nocopy  number,
  p_i_pa_routing_history_id       out nocopy  number,
  p_i_prh_object_version_number   out nocopy  number
   );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< end_sf52 >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API ends the routing of the Request for Personnel Action (RPA).
 *
 * This API updates the pa_request record and the latest pa_routing_history
 * record to store the details regarding the action taken, including the user
 * name of the person who acted on the Request for Personnel Action (RPA), that
 * person's roles and the action taken. This API is valid only for
 * 'UPDATE_HR_COMPLETE' and 'CANCELED' actions.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Request for Personnel Action record specified must exist.
 *
 * <p><b>Post Success</b><br>
 * This API ends the routing record of the Request for Personnel Action (RPA).
 *
 * <p><b>Post Failure</b><br>
 * The API does not end the routing of the Request for Personnel Action (RPA).
 * It does not update the GHR_pa_requests and GHR_pa_routing_history records
 * and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_pa_request_id Uniquely identifies the Request for Personnel Action
 * record.
 * @param p_user_name {@rep:casecolumn GHR_PA_ROUTING_HISTORY.USER_NAME}
 * @param p_action_taken Action taken that ended routing of the RPA. Possible
 * values are 'UPDATE_HR_COMPLETE' and 'CANCELED'.
 * @param p_altered_pa_request_id {@rep:casecolumn
 * GHR_PA_REQUESTS.ALTERED_PA_REQUEST_ID}
 * @param p_first_noa_code {@rep:casecolumn GHR_PA_REQUESTS.FIRST_NOA_CODE}
 * @param p_second_noa_code {@rep:casecolumn GHR_PA_REQUESTS.SECOND_NOA_CODE}
 * @param p_par_object_version_number Pass in the current version number of the
 * pa_request_id that you are updating. When the API completes, if p_validate
 * is false, sets the new version number of the updated pa_request_id. If
 * p_validate is true, sets the same value passed in.
 * @rep:displayname End Request for Personnel Action
 * @rep:category BUSINESS_ENTITY GHR_REQ_FOR_PERSONNEL_ACTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  procedure end_sf52
  (p_validate                        in      boolean   default false,
   p_pa_request_id                   in      number,
   p_user_name                       in      varchar2  default hr_api.g_varchar2,
   p_action_taken                    in      varchar2,
   p_altered_pa_request_id           in      number    default null,
   p_first_noa_code                  in      varchar2  default null,
   p_second_noa_code                 in      varchar2  default null,
   p_par_object_version_number       in out nocopy  number
   );

--

  Procedure Cancel_Cancor
  (p_altered_pa_request_id	in	number,
   p_noa_code_correct     	in	varchar2,
   p_result			 out nocopy boolean
   );

  --Bug#3757201 Added p_back_page parameter
  Procedure submit_request_to_print_50
 (p_printer_name                       in varchar2,
  p_pa_request_id                      in ghr_pa_requests.pa_request_id%type,
  p_effective_date                     in date,
  p_user_name                          in varchar2,
  p_back_page			       in varchar2
  );


--
-- ----------------------------------------------------------------------------
-- |--------------------------<   get_par_status   >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure  determines the current RPA status
--
-- Prerequisites:
--
-- Post Success:
--
--   Returns the most current status of the RPA

--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
--
--

  Procedure get_par_status
  (p_effective_date   	  	in   date,
   p_approval_date     		in   date,
   p_requested_by_person_id 	in   number,
   p_authorized_by_person_id 	in   number,
   p_action_taken      		in   varchar2,
   --8279908
   p_pa_request_id              in   number,
   p_status            		   out nocopy  varchar2
   );


--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_for_open_events>--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure checks for any open events pertaining to the RPA, before
--    Routing it to another individual / Groupbox or when submitted to Update HR
--
-- Prerequisites:
--
-- Post Success:
--
--   The RPA will be either routed or successfully submitted for Update to HR
--
-- Post Failure:
--    The RPA will not be routed and not submitted to Update HR.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
--
--
  Procedure check_for_open_events
 (p_pa_request_id      in      ghr_pa_requests.pa_request_id%type,
  p_action_taken        in      varchar2,
  p_user_name_acted_on  in     varchar2,
  p_user_name_routed_to in    varchar2,
  p_groupbox_routed_to  in    number,
  p_message             out nocopy  boolean
 );
--
end ghr_sf52_api ;

/
