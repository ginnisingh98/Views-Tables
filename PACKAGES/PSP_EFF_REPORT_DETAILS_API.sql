--------------------------------------------------------
--  DDL for Package PSP_EFF_REPORT_DETAILS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_EFF_REPORT_DETAILS_API" AUTHID CURRENT_USER as
/* $Header: PSPEDAIS.pls 120.5 2006/01/25 01:49:59 dpaudel noship $ */
/*#
 * This package contains Update API for Effort Report Details.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Effort Report Detail
*/
TYPE proposed_salary_amt_TYPE IS TABLE OF PSP_EFF_REPORT_DETAILS.PROPOSED_SALARY_AMT%TYPE INDEX BY BINARY_INTEGER;
TYPE  proposed_effort_percent_TYPE IS TABLE OF PSP_EFF_REPORT_DETAILS.proposed_effort_percent%TYPE INDEX BY BINARY_INTEGER;
TYPE committed_cost_share_TYPE  IS TABLE OF PSP_EFF_REPORT_DETAILS.committed_cost_share%TYPE INDEX BY BINARY_INTEGER;
TYPE value_TYPE IS  TABLE OF PSP_EFF_REPORT_DETAILS.value1%TYPE INDEX BY BINARY_INTEGER;
TYPE attribute_TYPE IS  TABLE OF PSP_EFF_REPORT_DETAILS.attribute1%TYPE INDEX BY BINARY_INTEGER;
TYPE EFFORT_REPORT_DETAIL_ID_TYPE IS  TABLE OF PSP_EFF_REPORT_DETAILS.EFFORT_REPORT_DETAIL_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE ASSIGNMENT_ID  IS  TABLE OF PSP_EFF_REPORT_DETAILS.ASSIGNMENT_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE GL_SEGMENT  IS  TABLE OF PSP_EFF_REPORT_DETAILS.GL_SEGMENT1%TYPE INDEX BY BINARY_INTEGER;
TYPE PROJECT_ID  IS  TABLE OF PSP_EFF_REPORT_DETAILS.PROJECT_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE EXPENDITURE_ORGANIZATION_ID  IS  TABLE OF PSP_EFF_REPORT_DETAILS.EXPENDITURE_ORGANIZATION_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE EXPENDITURE_TYPE  IS  TABLE OF PSP_EFF_REPORT_DETAILS.EXPENDITURE_TYPE%TYPE INDEX BY BINARY_INTEGER;
TYPE TASK_ID  IS  TABLE OF PSP_EFF_REPORT_DETAILS.TASK_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE AWARD_ID  IS  TABLE OF PSP_EFF_REPORT_DETAILS.AWARD_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE OBJECT_VERSION_NUMBER_TYPE IS  TABLE OF PSP_EFF_REPORT_DETAILS.OBJECT_VERSION_NUMBER%TYPE INDEX BY BINARY_INTEGER;
TYPE FULL_NAME_TYPE IS  TABLE OF PSP_EFF_REPORTS.FULL_NAME%TYPE INDEX BY BINARY_INTEGER;
TYPE GROUPING_CATEGORY IS TABLE OF PSP_EFF_REPORT_DETAILS.GROUPING_CATEGORY%TYPE INDEX BY BINARY_INTEGER;  -- Add for Hospital Effort Report

g_er_proposed_salary_amt                proposed_salary_amt_TYPE;
g_er_proposed_effort_percent       proposed_effort_percent_TYPE;
g_er_committed_cost_share          committed_cost_share_TYPE;
g_er_value1                     value_TYPE ;
g_er_value2                        value_TYPE;
g_er_value3                        value_TYPE;
g_er_value4                        value_TYPE;
g_er_value5                        value_TYPE;
g_er_value6                        value_TYPE;
g_er_value7                        value_TYPE;
g_er_value8                        value_TYPE;
g_er_value9                        value_TYPE ;
g_er_value10                       value_TYPE ;
g_er_attribute1                    attribute_TYPE;
g_er_attribute2                    attribute_TYPE;
g_er_attribute3                    attribute_TYPE;
g_er_attribute4                    attribute_TYPE;
g_er_attribute5                    attribute_TYPE;
g_er_attribute6                    attribute_TYPE;
g_er_attribute7                    attribute_TYPE;
g_er_attribute8                    attribute_TYPE;
g_er_attribute9                    attribute_TYPE;
g_er_attribute10                   attribute_TYPE;
g_er_EFFORT_REPORT_DETAIL_ID       EFFORT_REPORT_DETAIL_ID_TYPE;
g_er_ASSIGNMENT_ID                 ASSIGNMENT_ID;
g_er_GL_SEGMENT1                   GL_SEGMENT;
g_er_GL_SEGMENT2                   GL_SEGMENT;
g_er_GL_SEGMENT3                   GL_SEGMENT;
g_er_GL_SEGMENT4                   GL_SEGMENT;
g_er_GL_SEGMENT5                   GL_SEGMENT;
g_er_GL_SEGMENT6                   GL_SEGMENT;
g_er_GL_SEGMENT7                   GL_SEGMENT;
g_er_GL_SEGMENT8                   GL_SEGMENT;
g_er_GL_SEGMENT9                   GL_SEGMENT;
g_er_GL_SEGMENT10                  GL_SEGMENT;
g_er_GL_SEGMENT11                  GL_SEGMENT;
g_er_GL_SEGMENT12                  GL_SEGMENT;
g_er_GL_SEGMENT13                  GL_SEGMENT;
g_er_GL_SEGMENT14                  GL_SEGMENT;
g_er_GL_SEGMENT15                  GL_SEGMENT;
g_er_GL_SEGMENT16                  GL_SEGMENT;
g_er_GL_SEGMENT17                  GL_SEGMENT;
g_er_GL_SEGMENT18                  GL_SEGMENT;
g_er_GL_SEGMENT19                  GL_SEGMENT;
g_er_GL_SEGMENT20                  GL_SEGMENT;
g_er_GL_SEGMENT21                  GL_SEGMENT;
g_er_GL_SEGMENT22                  GL_SEGMENT;
g_er_GL_SEGMENT23                  GL_SEGMENT;
g_er_GL_SEGMENT24                  GL_SEGMENT;
g_er_GL_SEGMENT25                  GL_SEGMENT;
g_er_GL_SEGMENT26                  GL_SEGMENT;
g_er_GL_SEGMENT27                  GL_SEGMENT;
g_er_GL_SEGMENT28                  GL_SEGMENT;
g_er_GL_SEGMENT29                  GL_SEGMENT;
g_er_GL_SEGMENT30                  GL_SEGMENT;
g_er_PROJECT_ID                    PROJECT_ID;
g_er_EXPENDITURE_ORG_ID   EXPENDITURE_ORGANIZATION_ID;
g_er_EXPENDITURE_TYPE              EXPENDITURE_TYPE;
g_er_TASK_ID                       TASK_ID;
g_er_AWARD_ID                      AWARD_ID;
g_er_OBJECT_VERSION_NUMBER      OBJECT_VERSION_NUMBER_TYPE;
g_er_FULL_NAME          FULL_NAME_TYPE;
g_er_approver_person_id assignment_id;   --- added folowing vars vor uva
g_er_investigator_name full_name_type;
g_er_investigator_org_name full_name_type;
g_er_inv_primary_org_id assignment_id;
g_er_grouping_category grouping_category; -- Add for Hospital Effort Report
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_eff_report_details >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates Effort Report Details.
 *
 * This API updates Effort Report cost share details and Effort Report detail
 * attributes/values.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Effort Report record must exist for the concerned person and period.
 *
 * <p><b>Post Success</b><br>
 * Effort Report cost share details will be updated.
 *
 * <p><b>Post Failure</b><br>
 * Effort Report cost share details will not be updated and an error will be
 * raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_request_id When the API is executed from a concurrent program, set
 * to the concurrent request identifier.
 * @param p_start_person When the API is executed from a multi-threaded
 * concurrent program, set to the start_person in the chunk range.
 * @param p_end_person When the API is executed from a multi-threaded
 * concurrent program, set to the end_person in a chunk range.
 * @param p_warning Set to TRUE when an error condition is encountered within
 * the API.
 * @rep:displayname Update Effort Report Detail
 * @rep:category BUSINESS_ENTITY PSP_EFF_REPORT_DETAILS
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_EFF_REPORT_DETAILS
  (p_validate                                      in boolean  default false
  ,p_Request_id                                    in number
  ,p_start_person                                  in number
  ,p_end_person                                    in number
  ,p_warning                          out nocopy   boolean
  );
--
end PSP_EFF_REPORT_DETAILS_API;

 

/
