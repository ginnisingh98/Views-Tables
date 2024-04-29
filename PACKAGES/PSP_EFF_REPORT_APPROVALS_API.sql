--------------------------------------------------------
--  DDL for Package PSP_EFF_REPORT_APPROVALS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_EFF_REPORT_APPROVALS_API" AUTHID CURRENT_USER AS
/* $Header: PSPEAAIS.pls 120.5 2006/07/21 13:04:05 tbalacha noship $ */
/*#
 * This package contains ...
 * @rep:scope public
 * @rep:product  psp
 * @rep:displayname Effort Approvals
*/
g_pera_information1 varchar2(150);
g_pera_information2 varchar2(150);
g_pera_information3 varchar2(150);
g_pera_information4 varchar2(150);
g_pera_information5 varchar2(150);
g_pera_information6 varchar2(150);
g_pera_information7 varchar2(150);
g_pera_information8 varchar2(150);
g_pera_information9 varchar2(150);
g_pera_information10 varchar2(150);
g_pera_information11 varchar2(150);
g_pera_information12 varchar2(150);
g_pera_information13 varchar2(150);
g_pera_information14 varchar2(150);
g_pera_information15 varchar2(150);
g_pera_information16 varchar2(150);
g_pera_information17 varchar2(150);
g_pera_information18 varchar2(150);
g_pera_information19 varchar2(150);
g_pera_information20 varchar2(150);

g_eff_information1 varchar2(150);
g_eff_information2 varchar2(150);
g_eff_information3 varchar2(150);
g_eff_information4 varchar2(150);
g_eff_information5 varchar2(150);
g_eff_information6 varchar2(150);
g_eff_information7 varchar2(150);
g_eff_information8 varchar2(150);
g_eff_information9 varchar2(150);
g_eff_information10 varchar2(150);
g_eff_information11 varchar2(150);
g_eff_information12 varchar2(150);
g_eff_information13 varchar2(150);
g_eff_information14 varchar2(150);
g_eff_information15 varchar2(150);

--
-- ----------------------------------------------------------------------------
-- |------------------------< insert_eff_report_approvals >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- Create a Effort Report Approval line
--
-- Prerequisites:
-- Effort report and Effort Report detail lines must be exist
--
-- In Parameters:
--   Name                           Reqd Type     Description
-- p_validate                       Yes   boolean  Identifier  the validation of effort report
-- p_effort_report_approval_id      Yes   number   Identifier  for effort report approval
-- p_effort_report_detail_id        Yes   number   Effort report details identifier
-- p_wf_role_name                   Yes   varchar2 Workflow Role or user name
-- p_wf_orig_system_id              Yes   number   System id from where the workflow orginated
-- p_wf_orig_system                 Yes   varchar2 System name from where the workflow orginated
-- p_approver_order_num             Yes   number   Hierearchy for approvers
-- p_approval_status                Yes  varchar2  Status variable for approval
-- p_response_date                  Yes  date      Date for acting on the approval
-- p_actual_cost_share              Yes  number    Actual coast share entered from screen
-- p_overwritten_effort_percent     Yes  number    Overriwritten Effort Percent  value
-- p_wf_item_key                    Yes  varchar2  Workflow Notification  identifier
-- p_comments                       Yes  varchar2  Description for notification approval
-- p_pera_information_category      Yes  varchar2  Extra information category
-- p_pera_information1              Yes  varchar2  Extra Information
-- p_pera_information2              Yes  varchar2  Extra Information
-- p_pera_information3              Yes  varchar2  Extra Information
-- p_pera_information4              Yes  varchar2  Extra Information
-- p_pera_information5              Yes  varchar2  Extra Information
-- p_pera_information6              Yes  varchar2  Extra Information
-- p_pera_information7              Yes  varchar2  Extra Information
-- p_pera_information8              Yes  varchar2  Extra Information
-- p_pera_information9              Yes  varchar2  Extra Information
-- p_pera_information10             Yes  varchar2  Extra Information
-- p_pera_information11             Yes  varchar2  Extra Information
-- p_pera_information12             Yes  varchar2  Extra Information
-- p_pera_information13             Yes  varchar2  Extra Information
-- p_pera_information14             Yes  varchar2  Extra Information
-- p_pera_information15             Yes  varchar2  Extra Information
-- p_pera_information16             Yes  varchar2  Extra Information
-- p_pera_information17             Yes  varchar2  Extra Information
-- p_pera_information18             Yes  varchar2  Extra Information
-- p_pera_information19             Yes  varchar2  Extra Information
-- p_pera_information20             Yes  varchar2  Extra Information
-- p_wf_role_display_name           Yes  varchar2  Workflow Role display name
-- p_eff_information_category       Yes  varchar2  Effort Information Category
-- p_eff_information1               Yes  varchar2  Effort Information
-- p_eff_information2               Yes  varchar2  Effort Information
-- p_eff_information3               Yes  varchar2  Effort Information
-- p_eff_information4               Yes  varchar2  Effort Information
-- p_eff_information5               Yes  varchar2  Effort Information
-- p_eff_information6               Yes  varchar2  Effort Information
-- p_eff_information7               Yes  varchar2  Effort Information
-- p_eff_information8               Yes  varchar2  Effort Information
-- p_eff_information9               Yes  varchar2  Effort Information
-- p_eff_information10              Yes  varchar2  Effort Information
-- p_eff_information11              Yes  varchar2  Effort Information
-- p_eff_information12              Yes  varchar2  Effort Information
-- p_eff_information13              Yes  varchar2  Effort Information
-- p_eff_information14              Yes  varchar2  Effort Information
-- p_eff_information15              Yes  varchar2  Effort Information
--
-- Post Success:
-- Effort Report approval line is created
--
--
-- Post Failure:
-- Effort Report approval line is not created and an error is raised
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure insert_eff_report_approvals
(p_validate                       in            boolean  default false
,p_effort_report_detail_id        in            number
,p_wf_role_name                   in            varchar2
,p_wf_orig_system_id              in            number
,p_wf_orig_system                 in            varchar2
,p_approver_order_num             in            number
,p_approval_status                in            varchar2
,p_response_date                  in            date
,p_actual_cost_share              in            number
,p_overwritten_effort_percent     in            number
,p_wf_item_key                    in            varchar2
,p_comments                       in            varchar2
,p_pera_information_category      in            varchar2
,p_pera_information1              in            varchar2
,p_pera_information2              in            varchar2
,p_pera_information3              in            varchar2
,p_pera_information4              in            varchar2
,p_pera_information5              in            varchar2
,p_pera_information6              in            varchar2
,p_pera_information7              in            varchar2
,p_pera_information8              in            varchar2
,p_pera_information9              in            varchar2
,p_pera_information10             in            varchar2
,p_pera_information11             in            varchar2
,p_pera_information12             in            varchar2
,p_pera_information13             in            varchar2
,p_pera_information14             in            varchar2
,p_pera_information15             in            varchar2
,p_pera_information16             in            varchar2
,p_pera_information17             in            varchar2
,p_pera_information18             in            varchar2
,p_pera_information19             in            varchar2
,p_pera_information20             in            varchar2
,p_wf_role_display_name           in            varchar2
,p_eff_information_category       in            varchar2
,p_eff_information1               in            varchar2
,p_eff_information2               in            varchar2
,p_eff_information3               in            varchar2
,p_eff_information4               in            varchar2
,p_eff_information5               in            varchar2
,p_eff_information6               in            varchar2
,p_eff_information7               in            varchar2
,p_eff_information8               in            varchar2
,p_eff_information9               in            varchar2
,p_eff_information10              in            varchar2
,p_eff_information11              in            varchar2
,p_eff_information12              in            varchar2
,p_eff_information13              in            varchar2
,p_eff_information14              in            varchar2
,p_eff_information15              in            varchar2
,p_effort_report_approval_id         out nocopy number
,p_object_version_number             out nocopy number
,p_return_status                     out nocopy boolean
);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_eff_report_approvals >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a Effort Report Approval line.
 *
 * The API does update the existing effort report Approval line.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Human Resources..
 *
 * <p><b>Prerequisites</b><br>
 * Effort report and Effort Report detail lines must be exist
 *
 * <p><b>Post Success</b><br>
 * Effort Report approval line is updated
 *
 * <p><b>Post Failure</b><br>
 * Effort Report approval line is not updated and an error is raised
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effort_report_approval_id Identifier  for effort report approval
 * @param p_effort_report_detail_id  Effort report details identifier
 * @param p_wf_role_name   Workflow Role or user name
 * @param p_wf_orig_system_id System id from where the workflow orginated
 * @param p_wf_orig_system  System name from where the workflow orginated
 * @param p_approver_order_num Hierearchy for approvers
 * @param p_approval_status Status variable for approval
 * @param p_response_date Date for acting on the approval
 * @param p_actual_cost_share Actual coast share entered from screen
 * @param p_overwritten_effort_percent  Overriwritten Effort Percent  value
 * @param p_wf_item_key                 Workflow Notification  identifier
 * @param p_comments                    Description for notification approval
 * @param p_pera_information_category   Extra information category
 * @param p_pera_information1   Extra Information
 * @param p_pera_information2   Extra Information
 * @param p_pera_information3   Extra Information
 * @param p_pera_information4   Extra Information
 * @param p_pera_information5   Extra Information
 * @param p_pera_information6   Extra Information
 * @param p_pera_information7   Extra Information
 * @param p_pera_information8   Extra Information
 * @param p_pera_information9   Extra Information
 * @param p_pera_information10  Extra Information
 * @param p_pera_information11  Extra Information
 * @param p_pera_information12  Extra Information
 * @param p_pera_information13  Extra Information
 * @param p_pera_information14  Extra Information
 * @param p_pera_information15  Extra Information
 * @param p_pera_information16  Extra Information
 * @param p_pera_information17  Extra Information
 * @param p_pera_information18  Extra Information
 * @param p_pera_information19  Extra Information
 * @param p_pera_information20  Extra Information
 * @param p_wf_role_display_name       Workflow Role display name
 * @param p_eff_information_category   Effort Information Category
 * @param p_eff_information1  Effort Information
 * @param p_eff_information2  Effort Information
 * @param p_eff_information3  Effort Information
 * @param p_eff_information4  Effort Information
 * @param p_eff_information5  Effort Information
 * @param p_eff_information6  Effort Information
 * @param p_eff_information7  Effort Information
 * @param p_eff_information8  Effort Information
 * @param p_eff_information9  Effort Information
 * @param p_eff_information10   Effort Information
 * @param p_eff_information11   Effort Information
 * @param p_eff_information12   Effort Information
 * @param p_eff_information13   Effort Information
 * @param p_eff_information14   Effort Information
 * @param p_eff_information15   Effort Information
 * @param p_object_version_number Object version number identifier used for concurrenct
 * @param p_return_status The status whether the procedure is successful or not
 * @rep:displayname Update Effort Report Apprvals
 * @rep:category BUSINESS_ENTITY  PSP_EFF_REPORT_DETAILS
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}

procedure update_eff_report_approvals
(p_validate                       in            boolean  default false
,p_effort_report_approval_id      in            number
,p_effort_report_detail_id        in            number   default hr_api.g_number
,p_wf_role_name                   in            varchar2 default hr_api.g_varchar2
,p_wf_orig_system_id              in            number   default hr_api.g_number
,p_wf_orig_system                 in            varchar2 default hr_api.g_varchar2
,p_approver_order_num             in            number   default hr_api.g_number
,p_approval_status                in            varchar2 default hr_api.g_varchar2
,p_response_date                  in            date     default hr_api.g_date
,p_actual_cost_share              in            number   default hr_api.g_number
,p_overwritten_effort_percent     in            number   default hr_api.g_number
,p_wf_item_key                    in            varchar2 default hr_api.g_varchar2
,p_comments                       in            varchar2 default hr_api.g_varchar2
,p_pera_information_category      in            varchar2 default hr_api.g_varchar2
,p_pera_information1              in            varchar2 default hr_api.g_varchar2
,p_pera_information2              in            varchar2 default hr_api.g_varchar2
,p_pera_information3              in            varchar2 default hr_api.g_varchar2
,p_pera_information4              in            varchar2 default hr_api.g_varchar2
,p_pera_information5              in            varchar2 default hr_api.g_varchar2
,p_pera_information6              in            varchar2 default hr_api.g_varchar2
,p_pera_information7              in            varchar2 default hr_api.g_varchar2
,p_pera_information8              in            varchar2 default hr_api.g_varchar2
,p_pera_information9              in            varchar2 default hr_api.g_varchar2
,p_pera_information10             in            varchar2 default hr_api.g_varchar2
,p_pera_information11             in            varchar2 default hr_api.g_varchar2
,p_pera_information12             in            varchar2 default hr_api.g_varchar2
,p_pera_information13             in            varchar2 default hr_api.g_varchar2
,p_pera_information14             in            varchar2 default hr_api.g_varchar2
,p_pera_information15             in            varchar2 default hr_api.g_varchar2
,p_pera_information16             in            varchar2 default hr_api.g_varchar2
,p_pera_information17             in            varchar2 default hr_api.g_varchar2
,p_pera_information18             in            varchar2 default hr_api.g_varchar2
,p_pera_information19             in            varchar2 default hr_api.g_varchar2
,p_pera_information20             in            varchar2 default hr_api.g_varchar2
,p_wf_role_display_name           in            varchar2 default hr_api.g_varchar2
,p_eff_information_category       in            varchar2 default hr_api.g_varchar2
,p_eff_information1               in            varchar2 default hr_api.g_varchar2
,p_eff_information2               in            varchar2 default hr_api.g_varchar2
,p_eff_information3               in            varchar2 default hr_api.g_varchar2
,p_eff_information4               in            varchar2 default hr_api.g_varchar2
,p_eff_information5               in            varchar2 default hr_api.g_varchar2
,p_eff_information6               in            varchar2 default hr_api.g_varchar2
,p_eff_information7               in            varchar2 default hr_api.g_varchar2
,p_eff_information8               in            varchar2 default hr_api.g_varchar2
,p_eff_information9               in            varchar2 default hr_api.g_varchar2
,p_eff_information10              in            varchar2 default hr_api.g_varchar2
,p_eff_information11              in            varchar2 default hr_api.g_varchar2
,p_eff_information12              in            varchar2 default hr_api.g_varchar2
,p_eff_information13              in            varchar2 default hr_api.g_varchar2
,p_eff_information14              in            varchar2 default hr_api.g_varchar2
,p_eff_information15              in            varchar2 default hr_api.g_varchar2
,p_object_version_number          in out nocopy number
,p_return_status                     out nocopy boolean
);

--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_eff_report_approvals >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- Deletes a Effort Report Approval line
--
-- Prerequisites:
-- Effort report and Effort Report detail lines must be deleted before this
--
-- In Parameters:
--   Name                           Reqd Type     Description
-- p_validate                       Yes  boolean  Identifier  the validation of effort report
-- p_effort_report_approval_id      Yes  number   Identifier the effort report approval
--
-- Post Success:
-- Effort Report approval line is deleted
--
--
-- Post Failure:
-- No Effort Report approval line is deleted
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_eff_report_approvals
( p_validate                     in             boolean  default false
, p_effort_report_approval_id    in             number
, p_object_version_number        in out nocopy  number
, p_return_status                   out	nocopy  boolean
);
end psp_eff_report_approvals_api;

/
