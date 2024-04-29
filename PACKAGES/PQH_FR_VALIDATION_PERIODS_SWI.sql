--------------------------------------------------------
--  DDL for Package PQH_FR_VALIDATION_PERIODS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_VALIDATION_PERIODS_SWI" AUTHID CURRENT_USER As
/* $Header: pqvlpswi.pkh 115.1 2002/12/05 00:31:44 rpasapul noship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_validation_period >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_validation_periods_api.delete_validation_period
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
PROCEDURE delete_validation_period
  (p_validation_period_id         in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< insert_validation_period >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_validation_periods_api.insert_validation_period
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
PROCEDURE insert_validation_period
  (p_effective_date               in     date
  ,p_validation_id                in     number
  ,p_start_date                   in     date      default null
  ,p_end_date                     in     date      default null
  ,p_previous_employer_id         in     number    default null
  ,p_assignment_category	  in     varchar2  default null
  ,p_normal_hours                 in     number    default null
  ,p_frequency                    in     varchar2  default null
  ,p_period_years                 in     number    default null
  ,p_period_months                in     number    default null
  ,p_period_days                  in     number    default null
  ,p_comments                     in     varchar2  default null
  ,p_validation_status            in     varchar2  default null
  ,p_validation_period_id            out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_validation_period >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_validation_periods_api.update_validation_period
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
PROCEDURE update_validation_period
  (p_effective_date               in     date
  ,p_validation_period_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_validation_id                in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_previous_employer_id         in     number    default hr_api.g_number
  ,p_assignment_category	  in 	 varchar2  default hr_api.g_varchar2
  ,p_normal_hours                 in     number    default hr_api.g_number
  ,p_frequency                    in     varchar2  default hr_api.g_varchar2
  ,p_period_years                 in     number    default hr_api.g_number
  ,p_period_months                in     number    default hr_api.g_number
  ,p_period_days                  in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_validation_status            in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
end pqh_fr_validation_periods_swi;

 

/
