--------------------------------------------------------
--  DDL for Package OTA_TCC_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TCC_SWI" AUTHID CURRENT_USER As
/* $Header: ottccswi.pkh 120.0 2005/06/24 07:59 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< create_cross_charge >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_tcc_api.create_cross_charge
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
PROCEDURE create_cross_charge
  (p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_gl_set_of_books_id           in     number
  ,p_type                         in     varchar2
  ,p_from_to                      in     varchar2
  ,p_start_date_active            in     date
  ,p_end_date_active              in     date      default null
  ,p_cross_charge_id                 out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< update_cross_charge >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_tcc_api.update_cross_charge
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
PROCEDURE update_cross_charge
  (p_effective_date               in     date
  ,p_cross_charge_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_gl_set_of_books_id           in     number    default hr_api.g_number
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_from_to                      in     varchar2  default hr_api.g_varchar2
  ,p_start_date_active            in     date      default hr_api.g_date
  ,p_end_date_active              in     date      default hr_api.g_date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  );
 end ota_tcc_swi;

 

/
