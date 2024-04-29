--------------------------------------------------------
--  DDL for Package PER_RI_VIEW_REPORT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_VIEW_REPORT_SWI" AUTHID CURRENT_USER As
/* $Header: pervrswi.pkh 120.0 2005/05/31 20:29:37 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< create_view_report >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_ri_view_report_api.create_view_report
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
PROCEDURE create_view_report
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_workbench_view_report_code   in     varchar2
  ,p_workbench_view_report_name   in     varchar2
  ,p_wb_view_report_description   in     varchar2
  ,p_workbench_item_code          in     varchar2
  ,p_workbench_view_report_type   in     varchar2
  ,p_workbench_view_report_action in     varchar2
  ,p_workbench_view_country       in     varchar2
  ,p_wb_view_report_instruction   in     varchar2
  ,p_language_code                in     varchar2  default null
  ,p_effective_date               in     date
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_primary_industry		  in	 varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_view_report >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_ri_view_report_api.delete_view_report
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
PROCEDURE delete_view_report
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_workbench_view_report_code   in     varchar2
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< update_view_report >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_ri_view_report_api.update_view_report
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
PROCEDURE update_view_report
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_workbench_view_report_code   in     varchar2
  ,p_workbench_view_report_name   in     varchar2  default hr_api.g_varchar2
  ,p_wb_view_report_description   in     varchar2  default hr_api.g_varchar2
  ,p_workbench_item_code          in     varchar2  default hr_api.g_varchar2
  ,p_workbench_view_report_type   in     varchar2  default hr_api.g_varchar2
  ,p_workbench_view_report_action in     varchar2  default hr_api.g_varchar2
  ,p_workbench_view_country       in     varchar2  default hr_api.g_varchar2
  ,p_wb_view_report_instruction   in     varchar2  default hr_api.g_varchar2
  ,p_language_code                in     varchar2  default hr_api.g_varchar2
  ,p_effective_date               in     date
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_primary_industry		  in	 varchar2  default hr_api.g_varchar2
  );
end per_ri_view_report_swi;

 

/
