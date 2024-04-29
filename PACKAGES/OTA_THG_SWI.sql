--------------------------------------------------------
--  DDL for Package OTA_THG_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_THG_SWI" AUTHID CURRENT_USER As
/* $Header: otthgswi.pkh 120.0 2005/06/24 07:59 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------< create_hr_gl_flex >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_thg_api.create_hr_gl_flex
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
PROCEDURE create_hr_gl_flex
  (p_effective_date               in     date
  ,p_cross_charge_id              in     number
  ,p_segment                      in     varchar2
  ,p_segment_num                  in     number
  ,p_hr_data_source               in     varchar2  default null
  ,p_constant                     in     varchar2  default null
  ,p_hr_cost_segment              in     varchar2  default null
  ,p_gl_default_segment_id           out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< update_hr_gl_flex >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ota_thg_api.update_hr_gl_flex
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
PROCEDURE update_hr_gl_flex
  (p_effective_date               in     date
  ,p_gl_default_segment_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_cross_charge_id              in     number    default hr_api.g_number
  ,p_segment                      in     varchar2  default hr_api.g_varchar2
  ,p_segment_num                  in     number    default hr_api.g_number
  ,p_hr_data_source               in     varchar2  default hr_api.g_varchar2
  ,p_constant                     in     varchar2  default hr_api.g_varchar2
  ,p_hr_cost_segment              in     varchar2  default hr_api.g_varchar2
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  );
 end ota_thg_swi;

 

/
