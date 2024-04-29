--------------------------------------------------------
--  DDL for Package Body PSP_ERA_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ERA_EXT" AS
/* $Header: PSPEAEXB.pls 120.1 2006/04/07 06:32 dpaudel noship $ */
-- WARNING:
--          Please note that any PL/SQL statements that cause Commit/Rollback
--          are not allowed in the user extension code. Commit/Rollback's
--          will interfere with the Commit cycle of the main
--          process and Restart/Recover process will not work properly.
--
--         ------------------------------------------------------
Procedure UPDATE_EFF_REPORT_APPROVAL_EXT
(p_effort_report_approval_id      in            number
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
,p_object_version_number          in            number
) IS
BEGIN
  NULL;
  -- EDIT:Add your code here
  -- p_effort_report_id is the Effort Report id
  -- This procedure is a hook which will be called When you Update the Efffort Report using update effort report
  -- you can update columns pera_information1, pera_information2, pera_information3 etc of table psp_eff_report_approvals,
  -- you need to put crossponding value in global variable g_pera_information1, g_pera_information2, g_pera_information3 etc.
  /*
  Available global variables:
    psp_eff_report_approvals_api.g_pera_information1
    psp_eff_report_approvals_api.g_pera_information2
    psp_eff_report_approvals_api.g_pera_information3
    psp_eff_report_approvals_api.g_pera_information4
    psp_eff_report_approvals_api.g_pera_information5
    psp_eff_report_approvals_api.g_pera_information6
    psp_eff_report_approvals_api.g_pera_information7
    psp_eff_report_approvals_api.g_pera_information8
    psp_eff_report_approvals_api.g_pera_information9
    psp_eff_report_approvals_api.g_pera_information10
    psp_eff_report_approvals_api.g_pera_information11
    psp_eff_report_approvals_api.g_pera_information12
    psp_eff_report_approvals_api.g_pera_information13
    psp_eff_report_approvals_api.g_pera_information14
    psp_eff_report_approvals_api.g_pera_information15
    psp_eff_report_approvals_api.g_pera_information16
    psp_eff_report_approvals_api.g_pera_information17
    psp_eff_report_approvals_api.g_pera_information18
    psp_eff_report_approvals_api.g_pera_information19
    psp_eff_report_approvals_api.g_pera_information20

    psp_eff_report_approvals_api.g_eff_information1
    psp_eff_report_approvals_api.g_eff_information2
    psp_eff_report_approvals_api.g_eff_information3
    psp_eff_report_approvals_api.g_eff_information4
    psp_eff_report_approvals_api.g_eff_information5
    psp_eff_report_approvals_api.g_eff_information6
    psp_eff_report_approvals_api.g_eff_information7
    psp_eff_report_approvals_api.g_eff_information8
    psp_eff_report_approvals_api.g_eff_information9
    psp_eff_report_approvals_api.g_eff_information10
    psp_eff_report_approvals_api.g_eff_information11
    psp_eff_report_approvals_api.g_eff_information12
    psp_eff_report_approvals_api.g_eff_information13
    psp_eff_report_approvals_api.g_eff_information14
    psp_eff_report_approvals_api.g_eff_information15

    -- Sample code to update pera_information1 as number of hours workes
    SELECT number_of_hours
    INTO psp_eff_report_approvals_api.g_pera_information1
    from psp_custom_table
    where wf_role_name = p_wf_role_name;
  */
EXCEPTION
  WHEN others THEN
    fnd_msg_pub.add_exc_msg('PSP_ERA_EXT','UPDATE_EFF_REPORT_APPROVAL_EXT');
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
END;
END PSP_ERA_EXT;

/
