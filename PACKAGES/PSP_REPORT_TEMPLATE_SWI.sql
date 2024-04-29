--------------------------------------------------------
--  DDL for Package PSP_REPORT_TEMPLATE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_REPORT_TEMPLATE_SWI" AUTHID CURRENT_USER As
/* $Header: PSPRTSWS.pls 120.1 2005/07/05 23:50 dpaudel noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_report_template >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: psp_report_template_api.create_report_template
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
PROCEDURE create_report_template
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_template_id                  in     number
  ,p_template_name                in     varchar2
  ,p_business_group_id            in     number
  ,p_set_of_books_id              in     number
  ,p_report_type                  in     varchar2
  ,p_period_frequency_id          in     number
  ,p_report_template_code         in     varchar2
  ,p_display_all_emp_distrib_flag in     varchar2
  ,p_manual_entry_override_flag   in     varchar2
  ,p_approval_type                in     varchar2
  ,p_sup_levels                   in     number
  ,p_preview_effort_report_flag   in     varchar2
  ,p_notification_reminder        in     number
  ,p_sprcd_tolerance_amt          in     number
  ,p_sprcd_tolerance_percent      in     number
  ,p_description                  in     varchar2
  ,p_egislation_code              in     varchar2
  ,p_object_version_number           out nocopy number
  ,p_return_status_from_api          out nocopy number
  ,p_custom_approval_code         in     varchar2
  ,p_hundred_pcent_eff_at_per_asg in     varchar2
  ,p_selection_match_level        in     varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_report_template >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: psp_report_template_api.update_report_template
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
PROCEDURE update_report_template
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_template_id                  in     number
  ,p_template_name                in     varchar2
  ,p_business_group_id            in     number
  ,p_set_of_books_id              in     number
  ,p_report_type                  in     varchar2
  ,p_period_frequency_id          in     number
  ,p_report_template_code         in     varchar2
  ,p_display_all_emp_distrib_flag in     varchar2
  ,p_manual_entry_override_flag   in     varchar2
  ,p_approval_type                in     varchar2
  ,p_sup_levels                   in     number
  ,p_preview_effort_report_flag   in     varchar2
  ,p_notification_reminder        in     number
  ,p_sprcd_tolerance_amt          in     number
  ,p_sprcd_tolerance_percent      in     number
  ,p_description                  in     varchar2
  ,p_egislation_code              in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status_from_api          out nocopy number
  ,p_custom_approval_code         in     varchar2
  ,p_hundred_pcent_eff_at_per_asg in     varchar2
  ,p_selection_match_level        in     varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_report_template >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: psp_report_template_api.delete_report_template
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
PROCEDURE delete_report_template
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_template_id                  in     number
  ,p_object_version_number        in out nocopy number
  ,p_warning                         out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  );
 end psp_report_template_swi;

 

/
