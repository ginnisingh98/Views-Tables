--------------------------------------------------------
--  DDL for Package PSP_EFF_REPORT_APPROVALS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_EFF_REPORT_APPROVALS_BK1" AUTHID CURRENT_USER AS
/* $Header: PSPEAAIS.pls 120.5 2006/07/21 13:04:05 tbalacha noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< insert_eff_report_approvals_b >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE insert_eff_report_approvals_b
(p_effort_report_detail_id        in            number
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
);

-- ----------------------------------------------------------------------------
-- |---------------------< insert_eff_report_approvals_a >-------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE insert_eff_report_approvals_a
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
,p_object_version_number          in            number
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
,p_return_status                  in            boolean
);

END psp_eff_report_approvals_bk1;

/
