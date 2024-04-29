--------------------------------------------------------
--  DDL for Package PQP_EXR_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_EXR_SWI" AUTHID CURRENT_USER As
/* $Header: pqexrswi.pkh 120.0.12010000.2 2010/01/27 12:19:43 mdubasi ship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_exception_report >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqp_exr_api.create_exception_report
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
PROCEDURE create_exception_report
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_exception_report_name        in     varchar2
  ,p_legislation_code             in     varchar2  default null
  ,p_business_group_id            in     number    default null
  ,p_currency_code                in     varchar2  default null
  ,p_balance_type_id              in     number    default null
  ,p_balance_dimension_id         in     number    default null
  ,p_variance_type                in     varchar2  default null
  ,p_variance_value               in     number    default null
  ,p_comparison_type              in     varchar2  default null
  ,p_comparison_value             in     number    default null
  ,p_language_code                in     varchar2  default null
  ,p_exception_report_id             out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_output_format_type           in     varchar2
  ,p_variance_operator            in     varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_exception_report >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqp_exr_api.delete_exception_report
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
PROCEDURE delete_exception_report
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_exception_report_id          in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_exception_report >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqp_exr_api.update_exception_report
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
PROCEDURE update_exception_report
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_exception_report_name        in     varchar2  default hr_api.g_varchar2
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_balance_type_id              in     number    default hr_api.g_number
  ,p_balance_dimension_id         in     number    default hr_api.g_number
  ,p_variance_type                in     varchar2  default hr_api.g_varchar2
  ,p_variance_value               in     number    default hr_api.g_number
  ,p_comparison_type              in     varchar2  default hr_api.g_varchar2
  ,p_comparison_value             in     number    default hr_api.g_number
  ,p_exception_report_id          in     number    default hr_api.g_number
  ,p_language_code                in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_output_format_type           in     varchar2  default hr_api.g_varchar2
  ,p_variance_operator            in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< submit_request_set >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to submitting the
--   request set from OF.
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

procedure submit_request_set(
   p_validate                     in     number    default hr_api.g_false_num
  ,p_exception_report_id          in     number
  ,p_legislation_code             in     varchar2  default null
  ,p_business_group_id            in     number    default null
  ,p_consolidation_set_id         in     number    default null
  ,p_payroll_id                   in     number    default null
  ,p_variance_type                in     varchar2  default null
  ,p_variance_value               in     number    default null
  ,p_request_type                 in     varchar2  default null
  ,p_gre_id                       in     number    default null
  ,p_state_code                   in     number    default null
  ,p_exception_grp_name           in     varchar2  default null
  ,p_exception_rep_name           in     varchar2  default null
  ,p_exception_group_id           in     number
  ,p_effective_date               in     date
  ,p_output_format                in     varchar2  default null
  ,p_template_name                in     varchar2  default null
  ,p_component_id                 in     number    default null
  ,p_request_id                   out nocopy number
  ,p_return_status                out nocopy varchar2

) ;


-- ----------------------------------------------------------------------------
-- |------------------------< exception_report_xml_process >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is used to submit the XML publisher related calls.
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--
-- Post Failure:
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
procedure exception_report_xml_process(
   errbuf                        OUT NOCOPY  VARCHAR2
  ,retcode                       OUT NOCOPY  VARCHAR2
  ,p_ppa_finder                   in     varchar2  default null
  ,p_DES_TYPE                     in     varchar2 default null
  ,p_business_group_id            in     varchar2    default null
  ,p_request_name                 in     varchar2  default null
  ,p_grp_request_code             in     varchar2  default null
  ,p_exception_grp_name           in     varchar2  default null
  ,p_rep_request_code             in     varchar2  default null
  ,p_exception_report_id          in     varchar2  default null
  ,p_variance_type                in     varchar2  default null
  ,p_variance_value               in     number    default null
  ,p_payroll_id                   in     number    default null
  ,p_consolidation_set_id         in     number    default null
  ,p_effective_date               in     varchar2  default null
  ,p_template_name               in     varchar2  default null
  ,p_output_format		  in     varchar2  default null

) ;


end pqp_exr_swi;

/
