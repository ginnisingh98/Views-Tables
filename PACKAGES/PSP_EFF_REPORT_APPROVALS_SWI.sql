--------------------------------------------------------
--  DDL for Package PSP_EFF_REPORT_APPROVALS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_EFF_REPORT_APPROVALS_SWI" AUTHID CURRENT_USER As
/* $Header: PSPEASWS.pls 120.3 2006/03/26 01:10 dpaudel noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< delete_eff_report_approvals >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: psp_eff_report_approvals_api.delete_eff_report_approvals
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_eff_report_approvals
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effort_report_approval_id    in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< insert_eff_report_approvals >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: psp_eff_report_approvals_api.insert_eff_report_approvals
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE insert_eff_report_approvals
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effort_report_detail_id      in     number
  ,p_wf_role_name                 in     varchar2
  ,p_wf_orig_system_id            in     number
  ,p_wf_orig_system               in     varchar2
  ,p_approver_order_num           in     number
  ,p_approval_status              in     varchar2
  ,p_response_date                in     date
  ,p_actual_cost_share            in     number
  ,p_overwritten_effort_percent   in     number
  ,p_wf_item_key                  in     varchar2
  ,p_comments                     in     varchar2
  ,p_pera_information_category    in     varchar2
  ,p_pera_information1            in     varchar2
  ,p_pera_information2            in     varchar2
  ,p_pera_information3            in     varchar2
  ,p_pera_information4            in     varchar2
  ,p_pera_information5            in     varchar2
  ,p_pera_information6            in     varchar2
  ,p_pera_information7            in     varchar2
  ,p_pera_information8            in     varchar2
  ,p_pera_information9            in     varchar2
  ,p_pera_information10           in     varchar2
  ,p_pera_information11           in     varchar2
  ,p_pera_information12           in     varchar2
  ,p_pera_information13           in     varchar2
  ,p_pera_information14           in     varchar2
  ,p_pera_information15           in     varchar2
  ,p_pera_information16           in     varchar2
  ,p_pera_information17           in     varchar2
  ,p_pera_information18           in     varchar2
  ,p_pera_information19           in     varchar2
  ,p_pera_information20           in     varchar2
  ,p_wf_role_display_name         in     varchar2
  ,p_eff_information_category     in     varchar2
  ,p_eff_information1             in     varchar2
  ,p_eff_information2             in     varchar2
  ,p_eff_information3             in     varchar2
  ,p_eff_information4             in     varchar2
  ,p_eff_information5             in     varchar2
  ,p_eff_information6             in     varchar2
  ,p_eff_information7             in     varchar2
  ,p_eff_information8             in     varchar2
  ,p_eff_information9             in     varchar2
  ,p_eff_information10            in     varchar2
  ,p_eff_information11            in     varchar2
  ,p_eff_information12            in     varchar2
  ,p_eff_information13            in     varchar2
  ,p_eff_information14            in     varchar2
  ,p_eff_information15            in     varchar2
  ,p_effort_report_approval_id       out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_eff_report_approvals >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: psp_eff_report_approvals_api.update_eff_report_approvals
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_eff_report_approvals
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effort_report_approval_id    in     number
  ,p_effort_report_detail_id      in     number    default hr_api.g_number
  ,p_wf_role_name                 in     varchar2  default hr_api.g_varchar2
  ,p_wf_orig_system_id            in     number    default hr_api.g_number
  ,p_wf_orig_system               in     varchar2  default hr_api.g_varchar2
  ,p_approver_order_num           in     number    default hr_api.g_number
  ,p_approval_status              in     varchar2  default hr_api.g_varchar2
  ,p_response_date                in     date      default hr_api.g_date
  ,p_actual_cost_share            in     number    default hr_api.g_number
  ,p_overwritten_effort_percent   in     number    default hr_api.g_number
  ,p_wf_item_key                  in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_pera_information_category    in     varchar2  default hr_api.g_varchar2
  ,p_pera_information1            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information2            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information3            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information4            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information5            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information6            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information7            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information8            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information9            in     varchar2  default hr_api.g_varchar2
  ,p_pera_information10           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information11           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information12           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information13           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information14           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information15           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information16           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information17           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information18           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information19           in     varchar2  default hr_api.g_varchar2
  ,p_pera_information20           in     varchar2  default hr_api.g_varchar2
  ,p_wf_role_display_name         in     varchar2  default hr_api.g_varchar2
  ,p_eff_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_eff_information1             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information2             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information3             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information4             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information5             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information6             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information7             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information8             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information9             in     varchar2  default hr_api.g_varchar2
  ,p_eff_information10            in     varchar2  default hr_api.g_varchar2
  ,p_eff_information11            in     varchar2  default hr_api.g_varchar2
  ,p_eff_information12            in     varchar2  default hr_api.g_varchar2
  ,p_eff_information13            in     varchar2  default hr_api.g_varchar2
  ,p_eff_information14            in     varchar2  default hr_api.g_varchar2
  ,p_eff_information15            in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
 end psp_eff_report_approvals_swi;

 

/
