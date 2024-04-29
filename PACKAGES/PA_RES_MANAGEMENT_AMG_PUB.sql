--------------------------------------------------------
--  DDL for Package PA_RES_MANAGEMENT_AMG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RES_MANAGEMENT_AMG_PUB" AUTHID CURRENT_USER AS
/* $Header: PAPMRSPS.pls 120.1.12010000.3 2010/03/22 09:55:59 vgovvala ship $ */
/*#
 * This package contains the public APIs for Project Resource Management
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Resource Management Public API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJ_RESOURCE
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/
-- This record type is used for passing the requirement information to APIs.
/* Name: REQUIREMENT_IN_REC_TYPE
 * Description: This record is used to pass the required parameters for
 *              requirement APIs.
 *
 * Attributes:
 * REQUIREMENT_ID	        Identifier of the requirement
 *                              Usage: Update, Delete
 * 				Reference: pa_project_assignments.assignment_id
 * REQUIREMENT_NAME		The user-defined name that identifies the requirement.
 *                              If a value is not supplied, the role name is used
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.assignment_name
 * TEAM_TEMPLATE_ID		The identifier of the requirement template to which
 *                              this requirement belongs
 *                              Usage: Create
 * 				Reference: pa_team_templates.team_template_id
 * NUMBER_OF_REQUIREMENTS	The number of requirements that you want to create
 *                              using the details passed in. This parameter is used
 *                              when creating requirements for team template
 *                              Usage: Create
 *                              Reference:N/A
 * PROJECT_ROLE_ID		Identifier of the project role for the requirement.
 *                              The role must be part of the role list, if a role
 *                              list is attached to the project or team template
 *                              Usage: Create
 * 				Reference: pa_project_assignments.project_role_id
 * PROJECT_ROLE_NAME    	The name of the project role. Used when PROJECT_ROLE_ID
 *                              is not supplied. The role must be part of the role list,
 *                              if a role list is attached to the project or team template
 *                              Usage: Create
 * 				Reference: pa_project_role_types.meaning
 * PROJECT_ID       	        The identifier of the project to which this requirement belongs
 *                              Usage: Create
 * 				Reference: pa_project_assignments.project_id
 * PROJECT_NAME       	        The name of the project to which this requirement belongs.
 *                              Used when PROJECT_ID is not supplied
 *                              Usage: Create
 * 				Reference: pa_projects_all.name
 * PROJECT_NUMBER      	        The number of the project to which this requirement belongs.
 *                              Used when PROJECT_ID is not supplied
 *                              Usage: Create
 * 				Reference: pa_projects_all.segment1
 * STAFFING_OWNER_PERSON_ID     The owner person for the staffing of this requirement.
 *                              If not supplied, the value is obtained from the project setup
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.staffing_owner_person_id
 * STAFFING_PRIORITY_CODE       The staffing priority of the requirement. Valid values
 *                              are obtained from lookup type STAFFING_PRIORITY_CODE
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.staffing_priority_code
 * STAFFING_PRIORITY_NAME       The name of the staffing priority of the requirement. Used
 *                              when STAFFING_PRIORITY_CODE is not supplied. Valid values
 *                              are obtained from lookup type STAFFING_PRIORITY_CODE
 *                              Usage: Create, Update
 * 				Reference: pa_lookups.meaning
 * PROJECT_SUBTEAM_ID           The identifier for the project subteam to which this
 *                              requirement belongs
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.project_subteam_id
 * PROJECT_SUBTEAM_NAME         The name of the project subteam to which this requirement
 *                              belongs. Used when PROJECT_SUBTEAM_ID is not supplied
 *                              Usage: Create, Update
 * 				Reference: pa_project_subteams.name
 * LOCATION_ID                  Identifier of the location of the requirement. For new
 *                              requirements, this parameter gets its default value from
 *                              the project setup
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.location_id
 * LOCATION_COUNTRY_CODE        The country code of the location. Used when LOCATION_ID is
 *                              not supplied
 *                              Usage: Create, Update
 * 				Reference: pa_locations.country_code
 * LOCATION_COUNTRY_NAME        The country where this requirement will be performed. Used
 *                              when LOCATION_ID is not supplied
 *                              Usage: Create, Update
 * 				Reference: fnd_territories_tl.territory_short_name
 * LOCATION_REGION              The region where this requirement will be performed. Used
 *                              when LOCATION_ID is not supplied
 *                              Usage: Create, Update
 * 				Reference: pa_locations.region
 * LOCATION_CITY                The city where this requirement will be performed. Used
 *                              when LOCATION_ID is not supplied
 *                              Usage: Create, Update
 * 				Reference: pa_locations.city
 * MIN_RESOURCE_JOB_LEVEL       The minimum acceptable job level for the requirement.
 *                              For new requirements, this parameter obtains its default
 *                              values from the project roles setup
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.min_resource_job_level
 * MAX_RESOURCE_JOB_LEVEL       The maximum acceptable job level for the requirement.
 *                              For new requirements, this parameter obtains its default
 *                              values from the project roles setup
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.max_resource_job_level
 * DESCRIPTION                  The free text description of the requirement
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.description
 * ADDITIONAL_INFORMATION       The free text additional information of the requirement
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.additional_information
 * START_DATE                   The start date of the requirement
 *                              Usage: Create
 * 				Reference: Pa_project_assignments.start_date
 * END_DATE                     The end date of the requirement
 *                              Usage: Create
 * 				Reference: Pa_project_assignments.end_date
 * STATUS_CODE                  The status of the requirement. This parameter may be null
 *                              if the underlying schedule has multiple status codes.
 *                              Valid values are obtained from PA_PROJECT_STATUSES with
 *                              status type as OPEN_ASGMT
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.status_code
 * STATUS_NAME                  The status of the requirement. Used when STATUS_CODE is
 *                              not supplied. Valid values are obtained from
 *                              PA_PROJECT_STATUSES with status type as OPEN_ASGMT
 *                              Usage: Create, Update
 * 				Reference: pa_project_statuses.project_status_name
 * CALENDAR_TYPE                The base calendar used to generate schedules. It can be a
 *                              project calendar, resource calendar or any other calendar.
 *                              For requirements, the base calendar cannot be a resource
 *                              calendar.Valid values are obtained from lookup type
 *                              CHANGE_CALENDAR_TYPE_CODE
 *                              Usage: Create
 * 				Reference: pa_lookups.lookup_code
 * CALENDAR_ID                  Identifier of the calendar for the requirement. If
 *                              P_CALENDAR_TYPE is PROJECT, then the default value is
 *                              obtained from the project setup
 *                              Usage: Create
 * 				Reference: pa_project_assignments.calendar_id
 * CALENDAR_NAME                The calendar for the requirement. If P_CALENDAR_TYPE is
 *                              PROJECT, then the default value is obtained from the project
 *                              setup. Used when CALENDAR_ID is not supplied
 *                              Usage: Create
 * 				Reference: jtf_calendars_tl.calendar_name
 * START_ADV_ACTION_SET_FLAG    Flag indicating whether the advertisement rule will start
 *                              automatically. If not specified, the value is obtained
 *                              from the project setup
 *                              Usage: Create
 * 				Reference: pa_projects_all.start_adv_action_set_flag
 * ADV_ACTION_SET_ID            Identifier of the advertisement rule to be applied on this
 *                              requirement. If not specified, the value is obtained from
 *                              project setup
 *                              Usage: Create
 * 				Reference: pa_action_sets.action_set_id
 * ADV_ACTION_SET_NAME          The name of the advertisement rule to be applied on this
 *                              requirement. If not specified, the value is obtained from
 *                              project setup.from the project setup. Used when
 *                              ADV_ACTION_SET_ID is not supplied
 *                              Usage: Create
 * 				Reference: pa_action_sets.action_set_name
 * COMP_MATCH_WEIGHTING         The weight of competence match for evaluating candidate search
 *                              score. If not specified, the value is obtained from the project setup
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.competence_match_weighting
 * AVAIL_MATCH_WEIGHTING        The weight of availability match for evaluating candidate search
 *                              score. If not specified, the value is obtained from project setup
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.availability_match_weighting
 * JOB_LEVEL_MATCH_WEIGHTING    The weight of job match for evaluating candidate search score.
 *                              If not specified, then the value is obtained from the project setup.
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.job_level_match_weighting
 * ENABLE_AUTO_CAND_NOM_FLAG    Flag indicating whether to enable automatic candidate nominations
 *                              for this requirement. If not specified, then the value is
 *                              obtained from the project setup
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.enable_auto_cand_nom_flag
 * SEARCH_MIN_AVAILABILITY      The minimum availability percentage of resources that can be
 *                              assigned on this requirement. If not specified, then the value
 *                              is obtained from the project setup
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.search_min_availability
 * SEARCH_EXP_ORG_STR_VER_ID    Identifier of the expenditure organization hierarchy version.
 *                              This parameter is used in candidate searches for this requirement.
 *                              If not specified, then the value is obtained from the project setup
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.search_exp_org_struct_ver_id
 * SEARCH_EXP_ORG_HIER_NAME     The expenditure organization hierarchy name. This parameter is
 *                              used in candidate searches for this requirement if
 *                              SEARCH_EXP_ORG_STRUCT_VER_ID is not specified. If the hierarchy
 *                              has multiple versions, then you must supply a value for
 *                              SEARCH_EXP_ORG_STRUCT_VER_ID, so that the API find the version
 *                              Usage: Create, Update
 * 				Reference: per_organization_structures.name
 * SEARCH_EXP_START_ORG_ID      Identifier of the start organization in the organization hierarchy.
 *                              This parameter is used in candidate searches for this requirement.
 *                              If not specified, then the value is obtained from the project setup
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.search_exp_start_org_id
 * SEARCH_EXP_START_ORG_NAME    The start organization name in the organization hierarchy. This
 *                              parameter is used in candidate searches for this requirement if
 *                              SEARCH_EXP_START_ORG_ID is not specified
 *                              Usage: Create, Update
 * 				Reference: hr_organization_units.name
 * SEARCH_COUNTRY_CODE          The country code for candidate search. If not specified, then
 *                              the value is obtained from the project setup
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.search_country_code
 * SEARCH_COUNTRY_NAME          The country name for candidate search. If not specified, then
 *                              the value is obtained from the project setup
 *                              Usage: Create, Update
 * 				Reference: fnd_territories_tl.territory_short_name
 * SEARCH_MIN_CANDIDATE_SCORE   The minimum score required for candidate nomination. If not
 *                              specified, then the value is obtained from the project setup
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.search_min_candidate_score
 * EXPENDITURE_ORG_ID           The default operating unit for the requirement. If not
 *                              specified, then the value is obtained from the project setup
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.expenditure_org_id
 * EXPENDITURE_ORG_NAME         The default operating unit for the requirement. If not
 *                              specified, then the value is obtained from the project setup
 *                              Usage: Create, Update
 * 				Reference: hr_organizations_tl.name
 * EXPENDITURE_ORGANIZATION_ID  The project organization for the requirement. If not
 *                              specified, then the value is obtained from the project setup
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments. expenditure_organization_id
 * EXPENDITURE_ORGANIZATION_NAME  The project organization for the requirement. If not
 *                              specified, then the value is obtained from the project setup
 *                              Usage: Create, Update
 * 				Reference: hr_organizations_tl.name
 * EXPENDITURE_TYPE_CLASS       The expenditure type class to be used to generate forecast
 *                              transactions. If not specified, the value is obtained from the
 *                              forecasting options. Valid values are: ST - Straight Time
 *                              OT - Overtime
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.expenditure_type_class
 * EXPENDITURE_TYPE             Identifies the type of expenditure used to generate forecast
 *                              transactions. If not specified, the value is obtained from the
 *                              forecasting options.
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.expenditure_type
 * FCST_JOB_GROUP_ID            Identifier of the job group associated with the forecasting job.
 *                              If not specified, the value is obtained from the team role
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.fcst_job_group_id
 * FCST_JOB_GROUP_NAME          The job group name associated with the forecasting job. If
 *                              not specified, the value is obtained from the team role.
 *                              This parameter is used when FCST_JOB_GROUP_ID is not supplied
 *                              Usage: Create, Update
 * 				Reference: per_job_groups.displayed_name
 * FCST_JOB_ID                  The identifier of the job for the forecast of the requirement.
 *                              This parameter is used to determine cost, revenue, and transfer
 *                              price rates for the requirement during forecast processing.
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.fcst_job_id
 * FCST_JOB_NAME                The job name for the forecast of the requirement. This parameter
 *                              is used to determine cost, revenue, and transfer price rates for
 *                              the requirement during forecast processing. It is used when
 *                              FCST_JOB_ID is not supplied
 *                              Usage: Create, Update
 * 				Reference: per_jobs.name
 * WORK_TYPE_ID                 The type of work being performed. This parameter is used as a
 *                              default value for work type schedules. The default value is
 *                              obtained from the project setup
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.work_type_id
 * WORK_TYPE_NAME               The work type name being performed. Used when WORK_TYPE_ID
 *                              is not supplied
 *                              Usage: Create, Update
 * 				Reference: pa_work_types_vl.name
 * BILL_RATE_OPTION             The bill rate option. Valid values are: RATE, MARKUP, DISCOUNT, NONE
 *                              Usage: Create, Update
 * 				Reference: N/A
 * BILL_RATE_OVERRIDE           The override bill rate for the requirement. This parameter is
 *                              used when the value of BILL_RATE_OPTION is RATE.
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.bill_rate_override
 * BILL_RATE_CURR_OVERRIDE      The override bill rate currency code for the requirement. This
 *                              parameter is used when the value of BILL_RATE_OPTION is RATE
 *                              and a value is supplied for BILL_RATE_OVERRIDE
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.bill_rate_curr_override
 * MARKUP_PERCENT_OVERRIDE      The override markup percentage for the requirement. This
 *                              parameter is used when the value of BILL_RATE_OPTION is MARKUP
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.markup_percent_override
 * DISCOUNT_PERCENTAGE          The override discounts percentage for the requirement. This
 *                              parameter is used when the value of BILL_RATE_OPTION is DISCOUNT
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.discount_percentage
 * RATE_DISC_REASON_CODE        The identifier of the discount reason for discount. This parameter
 *                              is mandatory when either of BILL_RATE_OVERRIDE, MARKUP_PERCENT_OVERRIDE
 *                              DISCOUNT_PERCENTAGE is supplied, and "Require Rate and Discount Reason"
 *                              option is enabled in implementation. Valid values are obtained from
 *                              lookup type RATE AND DISCOUNT REASON. This parameter is not used when
 *                              the value of BILL_RATE_OPTION is NONE
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.rate_disc_reason_code
 * TP_RATE_OPTION               The transfer price options. Valid values are:RATE, BASIS, NONE
 *                              Usage: Create, Update
 * 				Reference: N/A
 * TP_RATE_OVERRIDE             The override transfer price rate for the requirement. This
 *                              parameter is used when the value of TP_RATE_OPTION is RATE
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.tp_rate_override
 * TP_CURRENCY_OVERRIDE         The override transfer price currency code for the requirement.
 *                              Used when a value is supplied for TP_RATE_OVERRIDE, and the
 *                              value of TP_RATE_OPTION is RATE.
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.tp_currency_override
 * TP_CALC_BASE_CODE_OVERRIDE   The override transfer price basis code (for example, raw cost,
 *                              or burden cost, etc). This parameter is used when the value of
 *                              TP_RATE_OPTION is BASIS. The valid values can be obtained from
 *                              lookup type CC_MARKUP_BASE_CODE
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.tp_calc_base_code_override
 * TP_PERCENT_APPLIED_OVERRIDE  Percentage of a given basis. This parameter is used when the
 *                              value of TP_RATE_OPTION is BASIS and a value is supplied for
 *                              TP_CALC_BASE_CODE_OVERRIDE
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.tp_percent_applied_override
 * EXTENSION_POSSIBLE           Flag indicating whether it is possible to extend the requirement.
 *                              Valid values are Y and N
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.extension_possible
 * EXPENSE_OWNER                The owner of the requirement expenses. The valid values can be
 *                              obtained from lookup type EXPENSE_OWNER_TYPE
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.expense_owner
 * EXPENSE_LIMIT                The maximum amount that the expense owner is willing to pay
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.expense_limit
 * ORIG_SYSTEM_CODE             Code specifying the system where this requirement was generated
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.orig_system_code
 * ORIG_SYSTEM_REFERENCE        Reference code specifying the system where this requirement
 *                              was generated
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.orig_system_reference
 * RECORD_VERSION_NUMBER        The system-generated version number of this record. The value is
 *                              incremented by one with each update
 *                              Usage: Update, Delete
 * 				Reference: pa_project_assignments.record_version_number
 * ATTRIBUTE_CATEGORY           Descriptive flexfield context field
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute_category
 * ATTRIBUTE1                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute1
 * ATTRIBUTE2                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute2
 * ATTRIBUTE3                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute3
 * ATTRIBUTE4                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute4
 * ATTRIBUTE5                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute5
 * ATTRIBUTE6                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute6
 * ATTRIBUTE7                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute7
 * ATTRIBUTE8                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute8
 * ATTRIBUTE9                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute9
 * ATTRIBUTE10                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute10
 * ATTRIBUTE11                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute11
 * ATTRIBUTE12                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute12
 * ATTRIBUTE13                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute13
 * ATTRIBUTE14                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute14
 * ATTRIBUTE15                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute15
  */
TYPE REQUIREMENT_IN_REC_TYPE IS RECORD
(
  requirement_id		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, requirement_name		VARCHAR2(80)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, team_template_id		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, number_of_requirements	NUMBER		:= 1
, project_role_id           	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, project_role_name		VARCHAR2(80)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, project_id			NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, project_name			VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, project_number		VARCHAR2(25)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, staffing_owner_person_id	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, staffing_priority_code	VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, staffing_priority_name	VARCHAR2(80)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, project_subteam_id		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, project_subteam_name		VARCHAR2(80)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, location_id			NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, location_country_code		VARCHAR2(2)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, location_country_name		VARCHAR2(80)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, location_region		VARCHAR2(240)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, location_city			VARCHAR2(80)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, min_resource_job_level	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, max_resource_job_level	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, description			VARCHAR2(2000)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, additional_information	VARCHAR2(2000)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, start_date			DATE		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
, end_date			DATE		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
, status_code			VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, status_name         		VARCHAR2(80)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--, resource_list_member_id       NUMBER	        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--, budget_version_id             NUMBER	        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, calendar_type			VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, calendar_id			NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, calendar_name			VARCHAR2(50)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, start_adv_action_set_flag	VARCHAR2(1)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, adv_action_set_id		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, adv_action_set_name		VARCHAR2(80)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, comp_match_weighting		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, avail_match_weighting		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, job_level_match_weighting	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, enable_auto_cand_nom_flag	VARCHAR2(1)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, search_min_availability	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, search_exp_org_str_ver_id	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, search_exp_org_hier_name      VARCHAR2(30)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, search_exp_start_org_id	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, search_exp_start_org_name	VARCHAR2(240)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, search_country_code		VARCHAR2(2)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, search_country_name		VARCHAR2(80)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, search_min_candidate_score	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, expenditure_org_id		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, expenditure_org_name		VARCHAR2(240)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, expenditure_organization_id	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, expenditure_organization_name	VARCHAR2(240)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, expenditure_type_class	VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, expenditure_type		VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, fcst_job_group_id		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, fcst_job_group_name		VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, fcst_job_id			NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, fcst_job_name			VARCHAR2(700)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, work_type_id			NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, work_type_name		VARCHAR2(80)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, bill_rate_option		VARCHAR2(10)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, bill_rate_override		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, bill_rate_curr_override	VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, markup_percent_override	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, discount_percentage       	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, rate_disc_reason_code     	VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, tp_rate_option		VARCHAR2(10)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, tp_rate_override		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, tp_currency_override		VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, tp_calc_base_code_override	VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, tp_percent_applied_override	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, extension_possible		VARCHAR2(1)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, expense_owner			VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, expense_limit			NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, orig_system_code   		VARCHAR2(80)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, orig_system_reference		VARCHAR2(240)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, record_version_number  	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, attribute_category		VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute1			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute2			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute3			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute4			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute5			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute6			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute7			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute8			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute9			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute10			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute11			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute12			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute13			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute14			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute15			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
);

-- This table type is used for passing the multiple requirements information to APIs.
/*
 * It is table of record type REQUIREMENT_IN_REC_TYPE.
 */
TYPE REQUIREMENT_IN_TBL_TYPE IS TABLE OF REQUIREMENT_IN_REC_TYPE
    INDEX BY BINARY_INTEGER;

/* Name: REQUIREMENT_IN_REC_TYPE
 * Description: This record is used to pass the required parameters for
 *              requirement APIs.
 *
 * Attributes:
 * ASSIGNMENT_ID		Identifier of the assignment
 *                              Usage: Update, Delete
 * 				Reference: pa_project_assignments.assignment_id
 * ASSIGNMENT_NAME		The user-defined name that identifies the assignment.
 *                              If a value is not supplied, the role name is used
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.assignment_name
 * ASSIGNMENT_TYPE		The type of assignment. Valid values are:
 *                              STAFFED_ASSIGNMENT, STAFFED_ADMIN_ASSIGNMENT
 *                              Usage: Create
 * 				Reference: pa_project_assignments.assignment_type
 * PROJECT_ROLE_ID		Identifier of the project role for the assignment.
 *                              The role must be part of the role list, if a role
 *                              list is attached to the project
 *                              Usage: Create
 * 				Reference: pa_project_assignments.project_role_id
 * PROJECT_ROLE_NAME    	The name of the project role. Used when PROJECT_ROLE_ID
 *                              is not supplied. The role must be part of the role list,
 *                              if a role list is attached to the project
 *                              Usage: Create
 * 				Reference: pa_project_role_types.meaning
 * PROJECT_ID       	        The identifier of the project to which this assignment belongs
 *                              Usage: Create
 * 				Reference: pa_project_assignments.project_id
 * PROJECT_NAME       	        The name of the project to which this assignment belongs.
 *                              Used when PROJECT_ID is not supplied
 *                              Usage: Create
 * 				Reference: pa_projects_all.name
 * PROJECT_NUMBER      	        The number of the project to which this assignment belongs.
 *                              Used when PROJECT_ID is not supplied
 *                              Usage: Create
 * 				Reference: pa_projects_all.segment1
 * RESOURCE_ID      	        Identifier of the project resource
 *                              Usage: Create
 * 				Reference: pa_project_assignments.resource_id
 * STAFFING_OWNER_PERSON_ID     The owner person for the staffing of this assignment.
 *                              If not supplied, the value is obtained from the project setup
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.staffing_owner_person_id
 * STAFFING_PRIORITY_CODE       The staffing priority of the assignment. Valid values
 *                              are obtained from lookup type STAFFING_PRIORITY_CODE
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.staffing_priority_code
 * STAFFING_PRIORITY_NAME       The name of the staffing priority of the assignment. Used
 *                              when STAFFING_PRIORITY_CODE is not supplied. Valid values
 *                              are obtained from lookup type STAFFING_PRIORITY_CODE
 *                              Usage: Create, Update
 * 				Reference: pa_lookups.meaning
 * PROJECT_SUBTEAM_ID           The identifier for the project subteam to which this
 *                              assignment belongs
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.project_subteam_id
 * PROJECT_SUBTEAM_NAME         The name of the project subteam to which this assignment
 *                              belongs. Used when PROJECT_SUBTEAM_ID is not supplied
 *                              Usage: Create, Update
 * 				Reference: pa_project_subteams.name
 * LOCATION_ID                  Identifier of the location of the assignment. For new
 *                              assignments, this parameter gets its default value from
 *                              the project setup
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.location_id
 * LOCATION_COUNTRY_CODE        The country code of the location. Used when LOCATION_ID is
 *                              not supplied
 *                              Usage: Create, Update
 * 				Reference: pa_locations.country_code
 * LOCATION_COUNTRY_NAME        The country where this assignment will be performed. Used
 *                              when LOCATION_ID is not supplied
 *                              Usage: Create, Update
 * 				Reference: fnd_territories_tl.territory_short_name
 * LOCATION_REGION              The region where this assignment will be performed. Used
 *                              when LOCATION_ID is not supplied
 *                              Usage: Create, Update
 * 				Reference: pa_locations.region
 * LOCATION_CITY                The city where this assignment will be performed. Used
 *                              when LOCATION_ID is not supplied
 *                              Usage: Create, Update
 * 				Reference: pa_locations.city
 * DESCRIPTION                  The free text description of the assignment
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.description
 * ADDITIONAL_INFORMATION       The free text additional information of the assignment
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.additional_information
 * START_DATE                   The start date of the assignment
 *                              Usage: Create
 * 				Reference: Pa_project_assignments.start_date
 * END_DATE                     The end date of the assignment
 *                              Usage: Create
 * 				Reference: Pa_project_assignments.end_date
 * STATUS_CODE                  The status of the assignment. Valid values are obtained from
 *                              PA_PROJECT_STATUSES with STAFFED_ASGMT as status type
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.status_code
 * STATUS_NAME                  The status of the assignment. Used when a value is not supplied
 *                              for STATUS_CODE. Valid values are obtained from PA_PROJECT_STATUSES
 *                              with STAFFED_ASGMT as status type
 *                              Usage: Create, Update
 * 				Reference: pa_project_statuses.project_status_name
 * CALENDAR_TYPE                The base calendar used to generate schedules. It can be a
 *                              project calendar, resource calendar or any other calendar.
 *                              For requirements, the base calendar cannot be a resource
 *                              calendar.Valid values are obtained from lookup type
 *                              CHANGE_CALENDAR_TYPE_CODE
 *                              Usage: Create
 * 				Reference: pa_lookups.lookup_code
 * CALENDAR_ID                  Identifier of the calendar for the assignment. If
 *                              P_CALENDAR_TYPE is PROJECT, then the default value is
 *                              obtained from the project setup
 *                              Usage: Create
 * 				Reference: pa_project_assignments.calendar_id
 * CALENDAR_NAME                The calendar for the assignment. If P_CALENDAR_TYPE is
 *                              PROJECT, then the default value is obtained from the project
 *                              setup. Used when CALENDAR_ID is not supplied
 *                              Usage: Create
 * 				Reference: jtf_calendars_tl.calendar_name
 * RESOURCE_CALENDAR_PERCENT    The daily percentage of resource calendar
 *                              Usage: Create
 * 				Reference: pa_project_assignments.resource_calendar_percent
 * EXPENDITURE_TYPE_CLASS       The expenditure type class to be used to generate forecast
 *                              transactions. If not specified, the value is obtained from the
 *                              forecasting options. Valid values are: ST - Straight Time
 *                              OT - Overtime
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.expenditure_type_class
 * EXPENDITURE_TYPE             Identifies the type of expenditure used to generate forecast
 *                              transactions. If not specified, the value is obtained from the
 *                              forecasting options.
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.expenditure_type
 * WORK_TYPE_ID                 The type of work being performed. This parameter is used as a
 *                              default value for work type schedules. The default value is
 *                              obtained from the project setup
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.work_type_id
 * WORK_TYPE_NAME               The work type name being performed. Used when WORK_TYPE_ID
 *                              is not supplied
 *                              Usage: Create, Update
 * 				Reference: pa_work_types_vl.name
 * BILL_RATE_OPTION             The bill rate option. Valid values are: RATE, MARKUP, DISCOUNT, NONE
 *                              Usage: Create, Update
 * 				Reference: N/A
 * BILL_RATE_OVERRIDE           The override bill rate for the assignment. This parameter is
 *                              used when the value of BILL_RATE_OPTION is RATE.
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.bill_rate_override
 * BILL_RATE_CURR_OVERRIDE      The override bill rate currency code for the assignment. This
 *                              parameter is used when the value of BILL_RATE_OPTION is RATE
 *                              and a value is supplied for BILL_RATE_OVERRIDE
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.bill_rate_curr_override
 * MARKUP_PERCENT_OVERRIDE      The override markup percentage for the assignment. This
 *                              parameter is used when the value of BILL_RATE_OPTION is MARKUP
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.markup_percent_override
 * DISCOUNT_PERCENTAGE          The override discounts percentage for the assignment. This
 *                              parameter is used when the value of BILL_RATE_OPTION is DISCOUNT
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.discount_percentage
 * RATE_DISC_REASON_CODE        The identifier of the discount reason for discount. This parameter
 *                              is mandatory when either of BILL_RATE_OVERRIDE, MARKUP_PERCENT_OVERRIDE
 *                              DISCOUNT_PERCENTAGE is supplied, and "Require Rate and Discount Reason"
 *                              option is enabled in implementation. Valid values are obtained from
 *                              lookup type RATE AND DISCOUNT REASON. This parameter is not used when
 *                              the value of BILL_RATE_OPTION is NONE
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.rate_disc_reason_code
 * TP_RATE_OPTION               The transfer price options. Valid values are:RATE, BASIS, NONE
 *                              Usage: Create, Update
 * 				Reference: N/A
 * TP_RATE_OVERRIDE             The override transfer price rate for the assignment. This
 *                              parameter is used when the value of TP_RATE_OPTION is RATE
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.tp_rate_override
 * TP_CURRENCY_OVERRIDE         The override transfer price currency code for the assignment.
 *                              Used when a value is supplied for TP_RATE_OVERRIDE, and the
 *                              value of TP_RATE_OPTION is RATE.
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.tp_currency_override
 * TP_CALC_BASE_CODE_OVERRIDE   The override transfer price basis code (for example, raw cost,
 *                              or burden cost, etc). This parameter is used when the value of
 *                              TP_RATE_OPTION is BASIS. The valid values can be obtained from
 *                              lookup type CC_MARKUP_BASE_CODE
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.tp_calc_base_code_override
 * TP_PERCENT_APPLIED_OVERRIDE  Percentage of a given basis. This parameter is used when the
 *                              value of TP_RATE_OPTION is BASIS and a value is supplied for
 *                              TP_CALC_BASE_CODE_OVERRIDE
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.tp_percent_applied_override
 * EXTENSION_POSSIBLE           Flag indicating whether it is possible to extend the assignment.
 *                              Valid values are Y and N
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.extension_possible
 * EXPENSE_OWNER                The owner of the assignment expenses. The valid values can be
 *                              obtained from lookup type EXPENSE_OWNER_TYPE
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.expense_owner
 * EXPENSE_LIMIT                The maximum amount that the expense owner is willing to pay
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.expense_limit
 * ORIG_SYSTEM_CODE             Code specifying the system where this assignment was generated
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.orig_system_code
 * ORIG_SYSTEM_REFERENCE        Reference code specifying the system where this assignment
 *                              was generated
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.orig_system_reference
 * RECORD_VERSION_NUMBER        The system-generated version number of this record. The value is
 *                              incremented by one with each update
 *                              Usage: Update, Delete
 * 				Reference: pa_project_assignments.record_version_number
 * AUTO_APPROVE                 Flag indicating whether the assignment should be automatically
 *                              approved, if privelege is there
 *                              Usage: Update, Delete
 * 				Reference: N/A
 * ATTRIBUTE_CATEGORY           Descriptive flexfield context field
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute_category
 * ATTRIBUTE1                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute1
 * ATTRIBUTE2                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute2
 * ATTRIBUTE3                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute3
 * ATTRIBUTE4                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute4
 * ATTRIBUTE5                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute5
 * ATTRIBUTE6                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute6
 * ATTRIBUTE7                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute7
 * ATTRIBUTE8                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute8
 * ATTRIBUTE9                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute9
 * ATTRIBUTE10                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute10
 * ATTRIBUTE11                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute11
 * ATTRIBUTE12                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute12
 * ATTRIBUTE13                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute13
 * ATTRIBUTE14                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute14
 * ATTRIBUTE15                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute15
 */
-- This record type is used for passing the assignment information to APIs.
TYPE ASSIGNMENT_IN_REC_TYPE IS RECORD
(
  assignment_id		        NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, assignment_name		VARCHAR2(80)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, assignment_type		VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, project_role_id           	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, project_role_name		VARCHAR2(80)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, project_id			NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, project_name			VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, project_number		VARCHAR2(25)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, resource_id		        NUMBER	        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, staffing_owner_person_id	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, staffing_priority_code	VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, staffing_priority_name	VARCHAR2(80)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, project_subteam_id		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, project_subteam_name		VARCHAR2(80)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, location_id			NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, location_country_code		VARCHAR2(2)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, location_country_name		VARCHAR2(80)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, location_region		VARCHAR2(240)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, location_city			VARCHAR2(80)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, description			VARCHAR2(2000)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, additional_information	VARCHAR2(2000)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, start_date			DATE		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
, end_date			DATE		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
, status_code			VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, status_name         		VARCHAR2(80)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--, resource_list_member_id       NUMBER	        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--, budget_version_id             NUMBER	        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, calendar_type			VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, calendar_id			NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, calendar_name			VARCHAR2(50)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, resource_calendar_percent     NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, expenditure_type_class	VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, expenditure_type		VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, work_type_id			NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, work_type_name		VARCHAR2(80)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, bill_rate_option		VARCHAR2(10)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, bill_rate_override		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, bill_rate_curr_override	VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, markup_percent_override	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, discount_percentage       	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, rate_disc_reason_code     	VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, tp_rate_option		VARCHAR2(10)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, tp_rate_override		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, tp_currency_override		VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, tp_calc_base_code_override	VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, tp_percent_applied_override	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, extension_possible		VARCHAR2(1)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, expense_owner			VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, expense_limit			NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, orig_system_code   		VARCHAR2(80)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, orig_system_reference		VARCHAR2(240)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, record_version_number  	NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, auto_approve			VARCHAR2(1)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute_category		VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute1			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute2			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute3			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute4			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute5			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute6			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute7			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute8			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute9			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute10			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute11			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute12			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute13			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute14			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute15			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
);

-- This table type is used for passing the multiple assignments information to APIs.
/*
 * It is table of record type ASSIGNMENT_IN_TBL_TYPE.
 */
TYPE ASSIGNMENT_IN_TBL_TYPE IS TABLE OF ASSIGNMENT_IN_REC_TYPE
    INDEX BY BINARY_INTEGER;

-- This record type is used for passing the requirement information to APIs.
/* Name: STAFF_REQUIREMENT_REC_TYPE
 * Description: This record is used to pass the required parameters for
 *              staff requirement APIs.
 *
 * Attributes:
 * SOURCE_REQUIREMENT_ID	Identifier of the existing base requirement
 * 				Reference:pa_project_assignments.assignment_id
 * RESOURCE_ID			Identifier of the project resource
 * 				Reference:pa_project_assignments.resource_id
 * PERSON_ID			Identifier of the person. This attribute is
 * 				required if an assignment is being created and
 * 				the value of RESOURCE_ID is null.
 * 				Reference:Per_all_people_f.person_id
 * START_DATE			The start date of the assignment. This
 *                              attribute is required.
 *                              Reference:Pa_project_assignments.start_date
 * END_DATE			The end date of the assignment. This attribute
 * 				is required.
 * 				Reference:Pa_project_assignments.end_date
 * ASSIGNMENT_STATUS_CODE	Status code of the assignment. This attribute
 * 				is required if STATUS_NAME is null. Valid
 * 				values are obtained from PA_PROJECT_STATUSES,
 * 				where STAFFED_ASGMT is the STATUS_TYPE.
 * 				Reference:Pa_project_assignments.status_code
 * ASSIGNMENT_STATUS_NAME	Status name for the assignment. This attribute
 * 				is required if STATUS_CODE is null.
 *  			     Reference:Pa_project_statuses.project_status_name
 * UNFILLED_ASSIGN_STATUS_CODE	The status code of the newly-created
 * 				requirement for the unfilled section when a
 * 				partial assignment occurs. Valid values are
 * 				obtained from PA_PROJECT_STATUSES, where
 * 				OPEN_ASGMT is the STATUS_TYPE.
 * 				Reference:Pa_project_assignments.status_code
 * UNFILLED_ASSIGN_STATUS_NAME	This parameter can be used in place of
 * 				UNFILLED_ASSIGN_STATUS_CODE.
 * 			     Reference:Pa_project_statuses.project_status_name
 * REMAINING_CANDIDATE_CODE	When the API is used to staff a requirement
 * 				that has associated candidates, this field
 * 				specifies the status code to assign to
 * 				candidates who are not assigned to fill the
 * 				requirement. Valid values are obtained from
 * 				PA_PROJECT_STATUSES, where CANDIDATE is the
 * 				STATUS_TYPE.
 * 				Reference:Pa_candidates.status_code
 * CHANGE_REASON_CODE		The reason code for changing the candidate
 * 				status code. Valid values are obtained from
 * 				PA_LOOKUPS, where CANDIDATE_STS_CHANGE_REASON
 * 				is the LOOKUP_TYPE.
 * 			     Reference:Pa_candidates_reviews.change_reason_code
 * RECORD_VERSION_NUMBER  	The system-generated version number of this
 * 				record. The value is incremented by one with
 * 				each update.
 * 				Usage: Update
 * 			Reference:pa_project_assignments.record_version_number
 */
TYPE STAFF_REQUIREMENT_REC_TYPE IS RECORD
(
  source_requirement_id         NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, resource_id			NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, person_id			NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, assignment_status_code 	VARCHAR2(30)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, assignment_status_name	VARCHAR2(80)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, unfilled_assign_status_code   VARCHAR2(30)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, unfilled_assign_status_name   VARCHAR2(80)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, remaining_candidate_code 	VARCHAR2(30)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, change_reason_code		VARCHAR2(30)    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, record_version_number	        NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, start_date		        DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
, end_date		        DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
);


-- This table type is used for passing the required parameters for staff requirement APIs
/*
 * It is table of record type STAFF_REQUIREMENT_TBL_TYPE.
 */
TYPE STAFF_REQUIREMENT_TBL_TYPE  IS TABLE OF STAFF_REQUIREMENT_REC_TYPE
    INDEX BY BINARY_INTEGER;


-- This record is used to pass the required parameters for competence APIs.
/* Name: COMPETENCE_IN_REC_TYPE
 * Description: This record type enables you to supply information about
 *              multiple competences.
 *
 * Attributes:
 * REQUIREMENT_ID		Identifier of the requirement.
 * 				Usage: Create
 * 				Reference: pa_project_assignments.assignment_id
 * COMPETENCE_ELEMENT_ID	Identifier of the competence element
 *                              Usage: Update, Delete
 *                              Reference: per_competence_elements.competence_element_id
 * COMPETENCE_ID		Identifier of the competence
 *                              Usage: Create
 *                              Reference: per_competences.competence_id
 * COMPETENCE_NAME		Name of the competence. Used when
 *                              P_COMPETENCE_ID is not supplied
 *                              Usage: Create
 *                              Reference: per_comepetences.name
 * COMPETENCE_ALIAS		Alias for the competence. Used when
 *                              P_COMPETENCE_ID is not supplied.
 *                              Usage: Create
 *                              Reference: per_comepetences.competence_alias
 * RATING_LEVEL_ID		Identifier of the rating level
 *                              Usage: Create, Update
 *                              Reference: per_competence_elements.rating_level_id
 * RATING_LEVEL_VALUE		Identifier of the rating level value. Used
 *                              when P_RATING_LEVEL_ID  is not supplied.
 *                              Usage: Create, Update
 *                              Reference: per_rating_levels.step_value
 * MANDATORY_FLAG		Flag indicating if competence is mandatory
 *                              Usage: Create, Update
 *                              Reference: per_competence_elements.mandatory
 * RECORD_VERSION_NUMBER	Record version number of the competence record
 *                              being updated. This parameter is derived if it
 *                              is not supplied.
 *                              Usage: Update, Delete
 *                              Reference: per_competence_elements.object_version_number
 *
 */
TYPE COMPETENCE_IN_REC_TYPE IS RECORD(
  requirement_id		NUMBER		:=	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, competence_element_id	        NUMBER		:=	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, competence_id		        NUMBER		:=	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, competence_name		VARCHAR2(700)   :=	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, competence_alias		VARCHAR2(30)	:=	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, rating_level_id		NUMBER		:=	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, rating_level_value		NUMBER		:=	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, mandatory_flag		VARCHAR2(30)	:=	PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, record_version_number	        NUMBER		:=	PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
);


-- This table is used to pass the required parameters for competence APIs.
/*
 * It is table of record type COMPETENCE_IN_REC_TYPE.
 */
TYPE COMPETENCE_IN_TBL_TYPE IS TABLE OF COMPETENCE_IN_REC_TYPE
INDEX BY  BINARY_INTEGER;


-- This record is used to pass the required parameters for candidate APIs.
/* Name: CANDIDATE_IN_REC_TYPE
 * Decription: This record type enables you to pass information about
 *             multiple candidates.
 *
 * Attributes:
 * CANDIDATE_ID   Identifier of the candidate, used when updating an existing
 *                candidate.
 *                Usage: Update
 *                Reference: pa_candidates.candidate_id
 * REQUIREMENT_ID Identifier of the requirement for which the nomination is
 *                being created or updated
 *                Usage: Create, Delete
 *                Reference: pa_project_assignments.assignment_id
 * RESOURCE_ID	  Identifier of the resource being nominated
 *                Usage: Create
 *                Reference: pa_resources_denorm.resource_id
 * PERSON_ID	  Identifier of the person being nominated. This parameter
 *                is used when P_RESOURCE_ID is not supplied.
 *                Usage: Create
 *                Reference: per_all_people_f.person_id
 * STATUS_CODE	  Status code of the candidate. Valid values can be
 *                obtained from PA_PROJECT_STATUSES where status_type
 *                is CANDIDATE.
 *                Usage: Create, Update
 *                Reference: pa_project_statuses.project_status_code
 * NOMINATION_COMMENTS	Comments by the nominator to add the resource on
 *                      the assignment.
 *                      Usage: Create
 *                      Reference: pa_candidates.nomination_comments
 * RANKING        Ranking of the candidate being updated. This parameter
 *                is used when updating an existing candidate.
 *                Usage: Update
 *                Reference: pa_candidates.candidate_ranking
 * CHANGE_REASON_CODE   Change reason for status change. Required for only
 *                      certain cases of status code changes. This parameter
 *                      is used when updating an existing candidate.
 *                      Valid values are obtained from PA_LOOKUPS where
 *                      LOOKUP_TYPE is CANDIDATE_STS_CHANGE_REASON.
 *                      Usage: Update
 *                      Reference: pa_candidate_reviews.change_reason_code
 * RECORD_VERSION_NUMBER Record version number of the candidate record
 *                       being updated. This parameter is used when updating
 *                       an existing candidate.
 *                       Usage: Update
 *                       Reference: pa_candidates.record_version_number
  --Added below attribute columns for Bug 8339510
 * ATTRIBUTE_CATEGORY           Descriptive flexfield context field
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute_category
 * ATTRIBUTE1                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute1
 * ATTRIBUTE2                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute2
 * ATTRIBUTE3                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute3
 * ATTRIBUTE4                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute4
 * ATTRIBUTE5                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute5
 * ATTRIBUTE6                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute6
 * ATTRIBUTE7                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute7
 * ATTRIBUTE8                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute8
 * ATTRIBUTE9                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute9
 * ATTRIBUTE10                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute10
 * ATTRIBUTE11                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute11
 * ATTRIBUTE12                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute12
 * ATTRIBUTE13                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute13
 * ATTRIBUTE14                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute14
 * ATTRIBUTE15                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute15
 */
TYPE CANDIDATE_IN_REC_TYPE IS RECORD
(
  candidate_id		        NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, requirement_id		NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, resource_id		        NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, person_id		        NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, status_code		        VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, nomination_comments	        VARCHAR2(2000)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, ranking			NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, change_reason_code	        VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, record_version_number	        NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 --Added below attribute columns for Bug 8339510
, attribute_category		VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute1			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute2			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute3			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute4			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute5			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute6			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute7			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute8			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute9			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute10			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute11			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute12			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute13			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute14			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute15			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
);


-- This table is used to pass the required parameters for candidate APIs.
/*
 * It is table of record type CANDIDATE_IN_REC_TYPE.
 */
TYPE CANDIDATE_IN_TBL_TYPE IS TABLE OF CANDIDATE_IN_REC_TYPE
INDEX BY BINARY_INTEGER;


-- This record is used to pass the required parameters for candidate log APIs.
/* Name: CANDIDATE_LOG_REC_TYPE
 * Decription: This record type supplies parameters for candidate logs.
 *
 * Attributes:
 * CANDIDATE_ID	         Identifier of the candidate
 *                       Usage: Create
 *                       Reference: pa_project_assignments.assignment_id
 * STATUS_CODE		 Status code of the candidate. Valid values are
 *                       obtained from PA_PROJECT_STATUSES where status_type
 *                       is CANDIDATE.
 *                       Usage: Create
 *                       Reference: pa_project_statuses.project_status_code
 * CHANGE_REASON_CODE	 Change reason for status change. Valid values
 *                       are obtained from pa_lookups where lookup_type is
 *                       CANDIDATE_STS_CHANGE_REASON.
 *                       Usage: Create
 *                       Reference: pa_candidate_reviews.change_reason_code
 * REVIEW_COMMENTS	 Review comments on candidate
 *                       Usage: Create
 *                       Reference: pa_candidate_reviews.review_comments
 --Added below attribute columns for Bug 8339510
 * ATTRIBUTE_CATEGORY           Descriptive flexfield context field
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute_category
 * ATTRIBUTE1                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute1
 * ATTRIBUTE2                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute2
 * ATTRIBUTE3                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute3
 * ATTRIBUTE4                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute4
 * ATTRIBUTE5                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute5
 * ATTRIBUTE6                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute6
 * ATTRIBUTE7                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute7
 * ATTRIBUTE8                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute8
 * ATTRIBUTE9                   Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute9
 * ATTRIBUTE10                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute10
 * ATTRIBUTE11                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute11
 * ATTRIBUTE12                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute12
 * ATTRIBUTE13                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute13
 * ATTRIBUTE14                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute14
 * ATTRIBUTE15                  Descriptive flexfield attribute
 *                              Usage: Create, Update
 * 				Reference: pa_project_assignments.attribute15
 */
TYPE CANDIDATE_LOG_REC_TYPE IS RECORD
(
  candidate_id		        NUMBER		:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
, status_code		        VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, change_reason_code	        VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, review_comments		VARCHAR2(2000)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 --Added below attribute columns for Bug 8339510
, attribute_category		VARCHAR2(30)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute1			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute2			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute3			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute4			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute5			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute6			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute7			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute8			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute9			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute10			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute11			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute12			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute13			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute14			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, attribute15			VARCHAR2(150)	:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
);

-- This table is used to pass the required parameters for candidate log APIs.
/*
 * It is table of record type CANDIDATE_LOG_REC_TYPE
 */
TYPE CANDIDATE_LOG_TBL_TYPE IS TABLE OF CANDIDATE_LOG_REC_TYPE
INDEX BY BINARY_INTEGER;

-- This record is used to pass the required parameters for submit assignment APIs.
/* Name: SUBMIT_ASSIGNMENT_IN_REC_TYPE
 * Decription: This record is used to pass the required parameters for
 *             submit assignment APIs.
 *
 * Attributes:
 * ASSIGNMENT_ID	Identifier of the assignment
 * 			Reference: pa_project_assignments.assignment_id
 * AUTO_APPROVE		Indicates whether automatically approve the assignment
 * 			if resource authority is available.
 * APR_PERSON_ID_1	The first approver for the assignment
 * 			Reference: per_all_people_f.person_id
 * APR_PERSON_ID_2	The second approver for the assignment
 * 			Reference: per_all_people_f.person_id
 * NOTE_TO_APPROVER	Comment for approvers
 * RECORD_VERSION_NUMBER  The system-generated version number of this record.
 * 			  The value is incremented by one with each update.
 *
 */
TYPE SUBMIT_ASSIGNMENT_IN_REC_TYPE IS RECORD
(
 assignment_id                  NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,auto_approve                   VARCHAR2(1)     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,apr_person_id_1                NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,apr_person_id_2                NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,note_to_approver               VARCHAR2(240)   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,record_version_number          NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
);

/*
 * It is table of record type SUBMIT_ASSIGNMENT_IN_REC_TYPE.
 */
TYPE SUBMIT_ASSIGNMENT_IN_TBL_TYPE  IS TABLE OF SUBMIT_ASSIGNMENT_IN_REC_TYPE
    INDEX BY BINARY_INTEGER;

-- This is a public API to create one or more requirements for one or more projects
/* Name: CREATE_REQUIREMENTS
 * Description: This procedure enables you to create project requirements.
 *
 * Parameters:
 * Parameter Name	Null?		Description
 * P_COMMIT		NULL		API standard (default = F)
 * P_INIT_MSG_LIST	NULL		API standard (default = T)
 * P_API_VERSION_NUMBER	NOT NULL	API standard
 * P_REQUIREMENT_IN_TBL	NOT NULL	Table of requirement records. Please
 * 					see the REQUIREMENT_IN_TBL_TYPE
 * 					datatype table.
 * X_REQUIREMENT_ID_TBL N/A             Table of requirement IDs created by
 *                                      the API
 *                              Reference: pa_project_assignments.assignment_id
 * X_RETURN_STATUS	N/A		The return status of the API. Valid
 *                                      values are: S (success)
 *                                                  E (error)
 *                                                  U (unexpected error)
 * X_MSG_COUNT		N/A		The number of error messages in the
 *                                      message stack
 * X_MSG_DATA		N/A		The error message text if only one
 *                                      error exists
 */
/*#
 * This is a public API to create one or more requirements for one or more projects
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = T): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_requirement_in_tbl Table of requirement records
 * @rep:paraminfo {@rep:required}
 * @param x_requirement_id_tbl Table of requirement IDs created by the API
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Requirements
 * @rep:compatibility S
*/
PROCEDURE CREATE_REQUIREMENTS
(
  p_api_version_number		IN		NUMBER   := 1.0
, p_init_msg_list		IN		VARCHAR2 := FND_API.G_TRUE
, p_commit			IN		VARCHAR2 := FND_API.G_FALSE
, p_requirement_in_tbl		IN		REQUIREMENT_IN_TBL_TYPE
, x_requirement_id_tbl		OUT	NOCOPY	SYSTEM.PA_NUM_TBL_TYPE
, x_return_status		OUT	NOCOPY	VARCHAR2
, x_msg_count			OUT	NOCOPY	NUMBER
, x_msg_data			OUT	NOCOPY	VARCHAR2
);

-- This is a public API to update one or more requirements for one or more projects
/* Name: UPDATE_REQUIREMENTS
 * Description: This procedure enables you to update project requirements.
 *
 * Parameters:
 * Parameter Name	Null?		Description
 * P_COMMIT		NULL		API standard (default = F)
 * P_INIT_MSG_LIST	NULL		API standard (default = T)
 * P_API_VERSION_NUMBER	NOT NULL	API standard
 * P_REQUIREMENT_IN_TBL	NOT NULL	Table of requirement records. Please
 * 					see the REQUIREMENT_IN_TBL_TYPE
 * 					datatype table.
 * X_RETURN_STATUS	N/A		The return status of the API. Valid
 *                                      values are: S (success)
 *                                                  E (error)
 *                                                  U (unexpected error)
 * X_MSG_COUNT		N/A		The number of error messages in the
 *                                      message stack
 * X_MSG_DATA		N/A		The error message text if only one
 *                                      error exists
 */
/*#
 * This is a public API to update one or more requirements for one or more projects
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = T): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_requirement_in_tbl Table of requirement records
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Requirements
 * @rep:compatibility S
*/
PROCEDURE UPDATE_REQUIREMENTS
(
  p_api_version_number		IN		NUMBER   := 1.0
, p_init_msg_list		IN		VARCHAR2 := FND_API.G_TRUE
, p_commit			IN		VARCHAR2 := FND_API.G_FALSE
, p_requirement_in_tbl		IN		REQUIREMENT_IN_TBL_TYPE
, x_return_status		OUT	NOCOPY	VARCHAR2
, x_msg_count			OUT	NOCOPY	NUMBER
, x_msg_data			OUT	NOCOPY	VARCHAR2
);

-- This is a public API to delete one or more requirements for one or more projects
/* Name: DELETE_REQUIREMENTS
 * Description: This procedure enables you to delete project requirements.
 *
 * Parameters:
 * Parameter Name	Null?		Description
 * P_COMMIT		NULL		API standard (default = F)
 * P_INIT_MSG_LIST	NULL		API standard (default = T)
 * P_API_VERSION_NUMBER	NOT NULL	API standard
 * P_REQUIREMENT_IN_TBL	NOT NULL	Table of requirement records. Please
 * 					see the REQUIREMENT_IN_TBL_TYPE
 * 					datatype table.
 * X_RETURN_STATUS	N/A		The return status of the API. Valid
 *                                      values are: S (success)
 *                                                  E (error)
 *                                                  U (unexpected error)
 * X_MSG_COUNT		N/A		The number of error messages in the
 *                                      message stack
 * X_MSG_DATA		N/A		The error message text if only one
 *                                      error exists
 */
/*#
 * This is a public API to delete one or more requirements for one or more projects
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = T): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_requirement_in_tbl Table of requirement records
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Requirements
 * @rep:compatibility S
*/
PROCEDURE DELETE_REQUIREMENTS
(
  p_api_version_number		IN		NUMBER   := 1.0
, p_init_msg_list		IN		VARCHAR2 := FND_API.G_TRUE
, p_commit			IN		VARCHAR2 := FND_API.G_FALSE
, p_requirement_in_tbl		IN		REQUIREMENT_IN_TBL_TYPE
, x_return_status		OUT	NOCOPY	VARCHAR2
, x_msg_count			OUT	NOCOPY	NUMBER
, x_msg_data			OUT	NOCOPY	VARCHAR2
);

-- This is a public API to staff one or more requirements for one or more projects
/* Name: STAFF_REQUIREMENTS
 * Description: This procedure enables you to staff requirements.
 *
 * Parameters:
 * Parameter Name	Null?		Description
 * P_COMMIT		NULL		API standard (default = F)
 * P_INIT_MSG_LIST	NULL		API standard (default = T)
 * P_API_VERSION_NUMBER	NOT NULL	API standard
 * P_STAFF_REQUIREMENT_TBL   NOT NULL	Table of staffing information for each
 *                                      requirement. Please see the
 *                                      Staff_requirement_tbl_TYPE datatype
 *                                      table.
 * X_ASSIGNMENT_ID_TBL  N/A             Table of staffed assignment IDs.
 *                              Reference: pa_project_assignments.assignment_id
 * X_RETURN_STATUS	N/A		The return status of the API. Valid
 *                                      values are: S (success)
 *                                                  E (error)
 *                                                  U (unexpected error)
 * X_MSG_COUNT		N/A		The number of error messages in the
 *                                      message stack
 * X_MSG_DATA		N/A		The error message text if only one
 *                                      error exists
 */
/*#
 * This is a public API to staff one or more requirements for one or more projects
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = T): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_staff_requirement_tbl Table of staffing information for each requirement
 * @rep:paraminfo {@rep:required}
 * @param x_assignment_id_tbl Table of staffed assignment IDs.
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Staff Requirements
 * @rep:compatibility S
*/
PROCEDURE STAFF_REQUIREMENTS
(
  p_api_version_number          IN              NUMBER   := 1.0
, p_init_msg_list               IN              VARCHAR2 := FND_API.G_TRUE
, p_commit                      IN              VARCHAR2 := FND_API.G_FALSE
, p_staff_requirement_tbl	IN 		STAFF_REQUIREMENT_TBL_TYPE
, x_assignment_id_tbl		OUT     NOCOPY  SYSTEM.PA_NUM_TBL_TYPE
, x_return_status               OUT     NOCOPY  VARCHAR2
, x_msg_count                   OUT     NOCOPY  NUMBER
, x_msg_data                    OUT     NOCOPY  VARCHAR2
);

-- This is a public API to copy one or more team roles
/* Name: COPY_TEAM_ROLES
 * Description: This procedure enables you to copy team roles from existing
 *              project assignments or requirements.
 *
 * Parameters:
 * Parameter Name	Null?		Description
 * P_COMMIT		NULL		API standard (default = F)
 * P_INIT_MSG_LIST	NULL		API standard (default = T)
 * P_API_VERSION_NUMBER	NOT NULL	API standard
 * P_REQ_ASGN_ID_TBL    NOT NULL	Table of requirement or assignment IDs.
 *                              Reference: pa_project_assignments.assignment_id
 * X_REQ_ASGN_ID_TBL    N/A             Table of requirement or assignment IDs
 *                                      created by the API.
 *                              Reference: pa_project_assignments.assignment_id
 * X_RETURN_STATUS	N/A		The return status of the API. Valid
 *                                      values are: S (success)
 *                                                  E (error)
 *                                                  U (unexpected error)
 * X_MSG_COUNT		N/A		The number of error messages in the
 *                                      message stack
 * X_MSG_DATA		N/A		The error message text if only one
 *                                      error exists
 */
/*#
 * This is a public API to copy one or more team roles
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = T): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_req_asgn_id_tbl Table of requirement or assignment IDs
 * @rep:paraminfo {@rep:required}
 * @param x_req_asgn_id_tbl Table of requirement or assignment IDs
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Copy Team Roles
 * @rep:compatibility S
*/
PROCEDURE COPY_TEAM_ROLES
(
  p_api_version_number          IN              NUMBER   := 1.0
, p_init_msg_list               IN              VARCHAR2 := FND_API.G_TRUE
, p_commit                      IN              VARCHAR2 := FND_API.G_FALSE
, p_req_asgn_id_tbl		IN 	        SYSTEM.PA_NUM_TBL_TYPE
, x_req_asgn_id_tbl		OUT     NOCOPY  SYSTEM.PA_NUM_TBL_TYPE
, x_return_status               OUT     NOCOPY  VARCHAR2
, x_msg_count                   OUT     NOCOPY  NUMBER
, x_msg_data                    OUT     NOCOPY  VARCHAR2
);

-- This is a public API to create one or more assignments for one or more projects
/* Name: CREATE_ASSIGNMENTS
 * Description: This procedure enables you to create project assignments.
 *
 * Parameters:
 * Parameter Name	Null?		Description
 * P_COMMIT		NULL		API standard (default = F)
 * P_INIT_MSG_LIST	NULL		API standard (default = T)
 * P_API_VERSION_NUMBER	NOT NULL	API standard
 * P_ASSIGNMENT_IN_TBL	NOT NULL	Table of assignment records. Please
 * 					see the ASSIGNMENT_IN_TBL_TYPE
 * 					datatype table.
 * X_ASSIGNMENT_ID_TBL N/A              Table to store assignment IDs created
 *                                      by the API.
 *                              Reference: pa_project_assignments.assignment_id
 * X_RETURN_STATUS	N/A		The return status of the API. Valid
 *                                      values are: S (success)
 *                                                  E (error)
 *                                                  U (unexpected error)
 * X_MSG_COUNT		N/A		The number of error messages in the
 *                                      message stack
 * X_MSG_DATA		N/A		The error message text if only one
 *                                      error exists
 */
/*#
 * This is a public API to create one or more assignments for one or more projects
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = T): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_assignment_in_tbl Table of assignment records
 * @rep:paraminfo {@rep:required}
 * @param x_assignment_id_tbl Table to store assignment IDs created by the API
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Assignments
 * @rep:compatibility S
*/
PROCEDURE CREATE_ASSIGNMENTS
(
  p_api_version_number		IN		NUMBER   := 1.0
, p_init_msg_list		IN		VARCHAR2 := FND_API.G_TRUE
, p_commit			IN		VARCHAR2 := FND_API.G_FALSE
, p_assignment_in_tbl		IN		ASSIGNMENT_IN_TBL_TYPE
, x_assignment_id_tbl		OUT	NOCOPY	SYSTEM.PA_NUM_TBL_TYPE
, x_return_status		OUT	NOCOPY	VARCHAR2
, x_msg_count			OUT	NOCOPY	NUMBER
, x_msg_data			OUT	NOCOPY	VARCHAR2
) ;

-- This is a public API to update one or more assignments for one or more projects.
/* Name: UPDATE_ASSIGNMENTS
 * Description: This procedure enables you to update project assignments.
 *
 * Parameters:
 * Parameter Name	Null?		Description
 * P_COMMIT		NULL		API standard (default = F)
 * P_INIT_MSG_LIST	NULL		API standard (default = T)
 * P_API_VERSION_NUMBER	NOT NULL	API standard
 * P_ASSIGNMENT_IN_TBL	NOT NULL	Table of assignment records. Please
 * 					see the ASSIGNMENT_IN_TBL_TYPE
 * 					datatype table.
 * X_RETURN_STATUS	N/A		The return status of the API. Valid
 *                                      values are: S (success)
 *                                                  E (error)
 *                                                  U (unexpected error)
 * X_MSG_COUNT		N/A		The number of error messages in the
 *                                      message stack
 * X_MSG_DATA		N/A		The error message text if only one
 *                                      error exists
 */
/*#
 * This is a public API to update one or more assignments for one or more projects.
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = T): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_assignment_in_tbl Table of assignment records
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Assignments
 * @rep:compatibility S
*/
PROCEDURE UPDATE_ASSIGNMENTS
(
  p_api_version_number          IN              NUMBER   := 1.0
, p_init_msg_list               IN              VARCHAR2 := FND_API.G_TRUE
, p_commit                      IN              VARCHAR2 := FND_API.G_FALSE
, p_assignment_in_tbl           IN              ASSIGNMENT_IN_TBL_TYPE
, x_return_status               OUT     NOCOPY  VARCHAR2
, x_msg_count                   OUT     NOCOPY  NUMBER
, x_msg_data                    OUT     NOCOPY  VARCHAR2
);

-- This is a public API to Delete one or more assignments for one or more projects.
/* Name: DELETE_ASSIGNMENTS
 * Description: This procedure enables you to delete project assignments.
 *
 * Parameters:
 * Parameter Name	Null?		Description
 * P_COMMIT		NULL		API standard (default = F)
 * P_INIT_MSG_LIST	NULL		API standard (default = T)
 * P_API_VERSION_NUMBER	NOT NULL	API standard
 * P_ASSIGNMENT_IN_TBL	NOT NULL	Table of assignment records. Please
 * 					see the ASSIGNMENT_IN_TBL_TYPE
 * 					datatype table.
 * X_RETURN_STATUS	N/A		The return status of the API. Valid
 *                                      values are: S (success)
 *                                                  E (error)
 *                                                  U (unexpected error)
 * X_MSG_COUNT		N/A		The number of error messages in the
 *                                      message stack
 * X_MSG_DATA		N/A		The error message text if only one
 *                                      error exists
 */
/*#
 * This is a public API to Delete one or more assignments for one or more projects.
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = T): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_assignment_in_tbl Table of assignment records
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Assignments
 * @rep:compatibility S
*/
PROCEDURE DELETE_ASSIGNMENTS (
p_commit                  IN               VARCHAR2                :=      'F'
, p_init_msg_list         IN               VARCHAR2                :=      'T'
, p_api_version_number    IN               NUMBER                  :=      1.0
, p_assignment_in_tbl     IN               ASSIGNMENT_IN_TBL_TYPE
, x_return_status         OUT     NOCOPY   VARCHAR2
, x_msg_count             OUT     NOCOPY   NUMBER
, x_msg_data              OUT     NOCOPY   VARCHAR2 ) ;

-- This is a public API to submit/approve one or more assignments for one or more projects.
/* Name: SUBMIT_ASSIGNMENTS
 * Description: This procedure enables you to submit and approve project
 *              assignments.
 *
 * Parameters:
 * Parameter Name	Null?		Description
 * P_COMMIT		NULL		API standard (default = F)
 * P_INIT_MSG_LIST	NULL		API standard (default = T)
 * P_API_VERSION_NUMBER	NOT NULL	API standard
 * P_SUBMIT_ASSIGNMENT_IN_TBL  NOT NULL	Table of assignment records. Please
 * 					see the SUBMIT_ASSIGNMENT_IN_TBL_TYPE
 * 					datatype table.
 * X_RETURN_STATUS	N/A		The return status of the API. Valid
 *                                      values are: S (success)
 *                                                  E (error)
 *                                                  U (unexpected error)
 * X_MSG_COUNT		N/A		The number of error messages in the
 *                                      message stack
 * X_MSG_DATA		N/A		The error message text if only one
 *                                      error exists
 */
/*#
 * This is a public API to submit/approve one or more assignments for one or more projects.
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = T): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_submit_assignment_in_tbl Table of assignment records
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Submit Assignments
 * @rep:compatibility S
*/
PROCEDURE SUBMIT_ASSIGNMENTS
(
  p_api_version_number          IN              NUMBER   := 1.0
, p_init_msg_list               IN              VARCHAR2 := FND_API.G_TRUE
, p_commit                      IN              VARCHAR2 := FND_API.G_FALSE
, p_submit_assignment_in_tbl    IN              SUBMIT_ASSIGNMENT_IN_TBL_TYPE
, x_return_status               OUT     NOCOPY  VARCHAR2
, x_msg_count                   OUT     NOCOPY  NUMBER
, x_msg_data                    OUT     NOCOPY  VARCHAR2
);

--This is a public API to create one or more competences for one or more project requirements.
/* Name: CREATE_REQUIREMENT_COMPETENCE
 * Description: This procedure enables you to create competences for
 *              project requirements.
 * Parameters:
 * Parameter Name	Null?		Description
 * P_COMMIT		NULL		API standard (default = F)
 * P_INIT_MSG_LIST	NULL		API standard (default = T)
 * P_API_VERSION_NUMBER	NOT NULL	API standard
 * P_COMPETENCE_IN_TBL	NOT NULL	Table of competence records. Please
 * 					see the COMPETENCE_IN_TBL_TYPE
 * 					datatype table.
 * X_COMPETENCE_ELEMENT_ID_TBL  N/A	Table to store the competence element
 *                                      IDs created by the API.
 *                     Reference: per_comepetence_elements.competence_element_id
 * X_RETURN_STATUS	N/A		The return status of the API. Valid
 *                                      values are: S (success)
 *                                                  E (error)
 *                                                  U (unexpected error)
 * X_MSG_COUNT		N/A		The number of error messages in the
 *                                      message stack
 * X_MSG_DATA		N/A		The error message text if only one
 *                                      error exists
 */
/*#
 * This is a public API to create one or more competences for one or more project requirements.
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = T): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_competence_in_tbl Table of competence records
 * @rep:paraminfo {@rep:required}
 * @param x_competence_element_id_tbl Table to store the competence element IDs created by the API
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Requirement Competence
 * @rep:compatibility S
*/
PROCEDURE CREATE_REQUIREMENT_COMPETENCE
(
  p_commit			IN	        VARCHAR2   :='F'
, p_init_msg_list		IN	        VARCHAR2   :='T'
, p_api_version_number		IN	        NUMBER     :=1.0
, p_competence_in_tbl		IN	        COMPETENCE_IN_TBL_TYPE
, x_competence_element_id_tbl	OUT     NOCOPY  SYSTEM.PA_NUM_TBL_TYPE
, x_return_status		OUT     NOCOPY  VARCHAR2
, x_msg_count			OUT     NOCOPY  NUMBER
, x_msg_data			OUT     NOCOPY  VARCHAR2
);

--This is a public API to update one or more competences for one or more project requirements
/* Name: UPDATE_REQUIREMENT_COMPETENCE
 * Description: This procedure enables you to update competences for
 *              project requirements.
 * Parameters:
 * Parameter Name	Null?		Description
 * P_COMMIT		NULL		API standard (default = F)
 * P_INIT_MSG_LIST	NULL		API standard (default = T)
 * P_API_VERSION_NUMBER	NOT NULL	API standard
 * P_COMPETENCE_IN_TBL	NOT NULL	Table of competence records. Please
 * 					see the COMPETENCE_IN_TBL_TYPE
 * 					datatype table.
 * X_RETURN_STATUS	N/A		The return status of the API. Valid
 *                                      values are: S (success)
 *                                                  E (error)
 *                                                  U (unexpected error)
 * X_MSG_COUNT		N/A		The number of error messages in the
 *                                      message stack
 * X_MSG_DATA		N/A		The error message text if only one
 *                                      error exists
 */
/*#
 * This is a public API to update one or more competences for one or more project requirements
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = T): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_competence_in_tbl Table of competence records
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Requirement Competence
 * @rep:compatibility S
*/
PROCEDURE UPDATE_REQUIREMENT_COMPETENCE
(
  p_commit		        IN		VARCHAR2  := 'F'
, p_init_msg_list	        IN		VARCHAR2  := 'T'
, p_api_version_number	        IN		NUMBER    := 1.0
, p_competence_in_tbl	        IN		COMPETENCE_IN_TBL_TYPE
, x_return_status	        OUT     NOCOPY  VARCHAR2
, x_msg_count		        OUT     NOCOPY  NUMBER
, x_msg_data		        OUT     NOCOPY  VARCHAR2
);


--This is a public API to delete one or more competences for one or more project requirements.
/* Name: DELETE_REQUIREMENT_COMPETENCE
 * Description: This procedure enables you to delete competences for
 *              project requirements.
 * Parameters:
 * Parameter Name	Null?		Description
 * P_COMMIT		NULL		API standard (default = F)
 * P_INIT_MSG_LIST	NULL		API standard (default = T)
 * P_API_VERSION_NUMBER	NOT NULL	API standard
 * P_COMPETENCE_IN_TBL	NOT NULL	Table of competence records. Please
 * 					see the COMPETENCE_IN_TBL_TYPE
 * 					datatype table.
 * X_RETURN_STATUS	N/A		The return status of the API. Valid
 *                                      values are: S (success)
 *                                                  E (error)
 *                                                  U (unexpected error)
 * X_MSG_COUNT		N/A		The number of error messages in the
 *                                      message stack
 * X_MSG_DATA		N/A		The error message text if only one
 *                                      error exists
 */
/*#
 * This is a public API to delete one or more competences for one or more project requirements.
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = T): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_competence_in_tbl Table of competence records
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Requirement Competence
 * @rep:compatibility S
*/
PROCEDURE  DELETE_REQUIREMENT_COMPETENCE
(
  p_commit		        IN              VARCHAR2 :='F'
, p_init_msg_list	        IN              VARCHAR2 := 'T'
, p_api_version_number	        IN              NUMBER   := 1.0
, p_competence_in_tbl	        IN              COMPETENCE_IN_TBL_TYPE
, x_return_status	        OUT     NOCOPY  VARCHAR2
, x_msg_count		        OUT     NOCOPY  NUMBER
, x_msg_data		        OUT     NOCOPY  VARCHAR2
);



-- This is a public API to create/nominate one or more candidates for project requirements.
/* Name: CREATE_CANDIDATES
 * Description: This procedure enables you to nominate candidates for
 *              project requirements.
 * Parameters:
 * Parameter Name	Null?		Description
 * P_COMMIT		NULL		API standard (default = F)
 * P_INIT_MSG_LIST	NULL		API standard (default = T)
 * P_API_VERSION_NUMBER	NOT NULL	API standard
 * P_CANDIDATE_IN_TBL	NOT NULL        Table of candidate records. Please see
 *                                     the CANDIDATE_IN_TBL_TYPE datatype table.
 * X_CANDIDATE_ID_TBL	N/A		Table to store the candidate IDs
 *                                      created by the API.
 *                                      Reference: pa_candidates.candidate_id
 * X_RETURN_STATUS	N/A		The return status of the API. Valid
 *                                      values are: S (success)
 *                                                  E (error)
 *                                                  U (unexpected error)
 * X_MSG_COUNT		N/A		The number of error messages in the
 *                                      message stack
 * X_MSG_DATA		N/A		The error message text if only one
 *                                      error exists
 */
/*#
 * This is a public API to create/nominate one or more candidates for project requirements
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = T): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_candidate_in_tbl Table of candidate records
 * @rep:paraminfo {@rep:required}
 * @param x_candidate_id_tbl Table to store the candidate IDs created by the API.
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Candidates
 * @rep:compatibility S
*/
PROCEDURE CREATE_CANDIDATES
(
  p_commit		        IN		VARCHAR2 := FND_API.G_FALSE
, p_init_msg_list	        IN		VARCHAR2 := FND_API.G_TRUE
, p_api_version_number	        IN		NUMBER   := 1.0
, p_candidate_in_tbl	        IN		CANDIDATE_IN_TBL_TYPE
, x_candidate_id_tbl	        OUT     NOCOPY	SYSTEM.PA_NUM_TBL_TYPE
, x_return_status	        OUT     NOCOPY	VARCHAR2
, x_msg_count		        OUT     NOCOPY 	NUMBER
, x_msg_data		        OUT     NOCOPY 	VARCHAR2
);


-- This is a public API to update one or more candidates for project requirements.
/* Name: UPDATE_CANDIDATES
 * Description: This procedure enables you to update the candidates for
 *              project requirements.
 * Parameters:
 * Parameter Name	Null?		Description
 * P_COMMIT		NULL		API standard (default = F)
 * P_INIT_MSG_LIST	NULL		API standard (default = T)
 * P_API_VERSION_NUMBER	NOT NULL	API standard
 * P_CANDIDATE_IN_TBL	NOT NULL        Table of candidate records. Please see
 *                                     the CANDIDATE_IN_TBL_TYPE datatype table.
 * X_RETURN_STATUS	N/A		The return status of the API. Valid
 *                                      values are: S (success)
 *                                                  E (error)
 *                                                  U (unexpected error)
 * X_MSG_COUNT		N/A		The number of error messages in the
 *                                      message stack
 * X_MSG_DATA		N/A		The error message text if only one
 *                                      error exists
 */
/*#
 * This is a public API to update one or more candidates for project requirements
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = T): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_candidate_in_tbl Table of candidate records
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Candidates
 * @rep:compatibility S
*/
PROCEDURE UPDATE_CANDIDATES
(
  p_commit		        IN		VARCHAR2 := FND_API.G_FALSE
, p_init_msg_list	        IN		VARCHAR2 := FND_API.G_TRUE
, p_api_version_number	        IN		NUMBER   := 1.0
, p_candidate_in_tbl	        IN		CANDIDATE_IN_TBL_TYPE
, x_return_status	        OUT     NOCOPY	VARCHAR2
, x_msg_count		        OUT     NOCOPY	NUMBER
, x_msg_data		        OUT     NOCOPY	VARCHAR2
);


-- This is a public API to delete one or more candidates for project requirements.
/* Name: DELETE_CANDIDATES
 * Description: This procedure enables you to delete candidates from
 *              project requirements.
 * Parameters:
 * Parameter Name	Null?		Description
 * P_COMMIT		NULL		API standard (default = F)
 * P_INIT_MSG_LIST	NULL		API standard (default = T)
 * P_API_VERSION_NUMBER	NOT NULL	API standard
 * P_CANDIDATE_IN_TBL	NOT NULL        Table of candidate records. Please see
 *                                     the CANDIDATE_IN_TBL_TYPE datatype table.
 * X_RETURN_STATUS	N/A		The return status of the API. Valid
 *                                      values are: S (success)
 *                                                  E (error)
 *                                                  U (unexpected error)
 * X_MSG_COUNT		N/A		The number of error messages in the
 *                                      message stack
 * X_MSG_DATA		N/A		The error message text if only one
 *                                      error exists
 */
/*#
 * This is a public API to delete one or more candidates for project requirements.
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = T): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_candidate_in_tbl Table of candidate records
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Candidates
 * @rep:compatibility S
*/
PROCEDURE DELETE_CANDIDATES
(
  p_commit		        IN		VARCHAR2 := FND_API.G_FALSE
, p_init_msg_list	        IN		VARCHAR2 := FND_API.G_TRUE
, p_api_version_number	        IN		NUMBER   := 1.0
, p_candidate_in_tbl	        IN		CANDIDATE_IN_TBL_TYPE
, x_return_status	        OUT     NOCOPY	VARCHAR2
, x_msg_count		        OUT     NOCOPY	NUMBER
, x_msg_data		        OUT     NOCOPY	VARCHAR2
);


-- This is a public API to create log for one or more candidates for project requirements.
/* Name: CREATE_CANDIDATE_LOG
 * Description: This procedure creates a log for one or more candidates for
 *              project requirements.
 * Parameters:
 * Parameter Name	Null?		Description
 * P_COMMIT		NULL		API standard (default = F)
 * P_INIT_MSG_LIST	NULL		API standard (default = T)
 * P_API_VERSION_NUMBER	NOT NULL	API standard
 * P_CANDIDATE_LOG_TBL	NOT NULL        Table of candidate review records.
 *                                      Please see the CANDIDATE_LOG_TBL_TYPE
 *                                      datatype table.
 * X_CANDIDATE_REVIEW_ID_TBL   N/A	Table to store the candidate review IDs
 *                                      created by the API.
 *                          Reference: pa_candidate_reviews.candidate_review_id
 * X_RETURN_STATUS	N/A		The return status of the API. Valid
 *                                      values are: S (success)
 *                                                  E (error)
 *                                                  U (unexpected error)
 * X_MSG_COUNT		N/A		The number of error messages in the
 *                                      message stack
 * X_MSG_DATA		N/A		The error message text if only one
 *                                      error exists
 */
/*#
 * This is a public API to create log for one or more candidates for project requirements.
 * @param p_api_version_number API standard version number
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list API standard (default = T): indicates if message stack will be initialized
 * @param p_commit API standard (default = F): indicates if transaction will be committed
 * @param p_candidate_log_tbl Table of candidate review records
 * @rep:paraminfo {@rep:required}
 * @param x_candidate_review_id_tbl Table to store the candidate review IDs created by the API
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Candidate Log
 * @rep:compatibility S
*/
PROCEDURE CREATE_CANDIDATE_LOG
(
  p_commit			IN		VARCHAR2 := FND_API.G_FALSE
, p_init_msg_list		IN		VARCHAR2 := FND_API.G_TRUE
, p_api_version_number		IN		NUMBER   := 1.0
, p_candidate_log_tbl		IN		CANDIDATE_LOG_TBL_TYPE
, x_candidate_review_id_tbl	OUT     NOCOPY	SYSTEM.PA_NUM_TBL_TYPE
, x_return_status		OUT     NOCOPY	VARCHAR2
, x_msg_count			OUT     NOCOPY	NUMBER
, x_msg_data			OUT     NOCOPY	VARCHAR2
);

END PA_RES_MANAGEMENT_AMG_PUB;

/
