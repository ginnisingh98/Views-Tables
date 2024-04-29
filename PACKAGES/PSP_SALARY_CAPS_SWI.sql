--------------------------------------------------------
--  DDL for Package PSP_SALARY_CAPS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_SALARY_CAPS_SWI" AUTHID CURRENT_USER As
/* $Header: PSPSCSWS.pls 120.0 2005/11/20 23:56 dpaudel noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------< create_salary_cap >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: psp_salary_caps_api.create_salary_cap
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
PROCEDURE create_salary_cap
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_funding_source_code          in     varchar2
  ,p_start_date                   in     date
  ,p_end_date                     in     date
  ,p_currency_code                in     varchar2
  ,p_annual_salary_cap            in     number
  ,p_seed_flag                    in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_salary_cap_id                in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_salary_cap >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: psp_salary_caps_api.delete_salary_cap
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
PROCEDURE delete_salary_cap
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_salary_cap_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< update_salary_cap >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: psp_salary_caps_api.update_salary_cap
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
PROCEDURE update_salary_cap
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_salary_cap_id                in     number
  ,p_funding_source_code          in     varchar2
  ,p_start_date                   in     date
  ,p_end_date                     in     date
  ,p_currency_code                in     varchar2
  ,p_annual_salary_cap            in     number
  ,p_seed_flag                    in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
 end psp_salary_caps_swi;

 

/
