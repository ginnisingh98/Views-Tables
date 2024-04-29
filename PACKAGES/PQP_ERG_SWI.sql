--------------------------------------------------------
--  DDL for Package PQP_ERG_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ERG_SWI" AUTHID CURRENT_USER As
/* $Header: pqexgswi.pkh 115.0 2003/02/14 02:03:49 rpinjala noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_exception_group >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqp_erg_api.create_exception_group
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
PROCEDURE create_exception_group
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_exception_group_name         in     varchar2  default null
  ,p_exception_report_id          in     number
  ,p_legislation_code             in     varchar2  default null
  ,p_business_group_id            in     number    default null
  ,p_consolidation_set_id         in     number    default null
  ,p_payroll_id                   in     number    default null
  ,p_exception_group_id              out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_output_format                in     varchar2
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_exception_group >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqp_erg_api.delete_exception_group
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
PROCEDURE delete_exception_group
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_exception_group_id           in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_exception_group >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqp_erg_api.update_exception_group
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
PROCEDURE update_exception_group
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_exception_group_id           in     number    default hr_api.g_number
  ,p_exception_group_name         in     varchar2  default hr_api.g_varchar2
  ,p_exception_report_id          in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_consolidation_set_id         in     number    default hr_api.g_number
  ,p_payroll_id                   in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_output_format                in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
end pqp_erg_swi;

 

/
