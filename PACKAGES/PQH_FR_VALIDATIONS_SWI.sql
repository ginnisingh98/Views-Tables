--------------------------------------------------------
--  DDL for Package PQH_FR_VALIDATIONS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_VALIDATIONS_SWI" AUTHID CURRENT_USER As
/* $Header: pqvldswi.pkh 115.1 2002/12/05 00:31:07 rpasapul noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validation >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_validations_api.delete_validation
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
PROCEDURE delete_validation
  (p_validation_id                in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validation >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_validations_api.insert_validation
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
PROCEDURE insert_validation
  (p_effective_date               in     date
  ,p_pension_fund_type_code       in     varchar2
  ,p_pension_fund_id              in     number
  ,p_business_group_id            in     number
  ,p_person_id                    in     number
  ,p_previously_validated_flag    in     varchar2
  ,p_request_date                 in     date      default null
  ,p_completion_date              in     date      default null
  ,p_previous_employer_id         in     number    default null
  ,p_status                       in     varchar2  default null
  ,p_employer_amount              in     number    default null
  ,p_employer_currency_code       in     varchar2  default null
  ,p_employee_amount              in     number    default null
  ,p_employee_currency_code       in     varchar2  default null
  ,p_deduction_per_period         in     number    default null
  ,p_deduction_currency_code      in     varchar2  default null
  ,p_percent_of_salary            in     number    default null
  ,p_validation_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validation >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_fr_validations_api.update_validation
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
PROCEDURE update_validation
  (p_effective_date               in     date
  ,p_validation_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_pension_fund_type_code       in     varchar2  default hr_api.g_varchar2
  ,p_pension_fund_id              in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_previously_validated_flag    in     varchar2  default hr_api.g_varchar2
  ,p_request_date                 in     date      default hr_api.g_date
  ,p_completion_date              in     date      default hr_api.g_date
  ,p_previous_employer_id         in     number    default hr_api.g_number
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_employer_amount              in     number    default hr_api.g_number
  ,p_employer_currency_code       in     varchar2  default hr_api.g_varchar2
  ,p_employee_amount              in     number    default hr_api.g_number
  ,p_employee_currency_code       in     varchar2  default hr_api.g_varchar2
  ,p_deduction_per_period         in     number    default hr_api.g_number
  ,p_deduction_currency_code      in     varchar2  default hr_api.g_varchar2
  ,p_percent_of_salary            in     number    default hr_api.g_number
  ,p_return_status                   out nocopy varchar2
  );
end pqh_fr_validations_swi;

 

/
