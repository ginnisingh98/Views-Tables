--------------------------------------------------------
--  DDL for Package PSP_PERIOD_FREQUENCY_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PERIOD_FREQUENCY_SWI" AUTHID CURRENT_USER As
/* $Header: PSPFBSWS.pls 120.0 2005/06/02 15:55 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_period_frequency >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: psp_period_frequency_api.create_period_frequency
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
PROCEDURE create_period_frequency
  ( p_validate                      in     number    default hr_api.g_false_num
    ,p_start_date                   in     date
    ,p_unit_of_measure              in     varchar2
    ,p_period_duration              in     number
    ,p_report_type                  in     varchar2  default null
    ,p_period_frequency             in     varchar2
    ,p_language_code                in     varchar2  default hr_api.userenv_lang
    ,p_period_frequency_id          in     number
    ,p_object_version_number           out nocopy number
    ,p_api_warning                     out nocopy varchar2
    ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_period_frequency >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: psp_period_frequency_api.update_period_frequency
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
PROCEDURE update_period_frequency
  ( p_validate                     in     number default hr_api.g_false_num
   ,p_start_date                   in     date
   ,p_unit_of_measure              in     varchar2
   ,p_period_duration              in     number
   ,p_report_type                  in     varchar2  default hr_api.g_varchar2
   ,p_period_frequency             in     varchar2
   ,p_period_frequency_id          in     number
   ,p_object_version_number        in out nocopy number
   ,p_api_warning                     out nocopy varchar2
   ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_period_frequency >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: psp_period_frequency_api.delete_period_frequency
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
PROCEDURE delete_period_frequency
  ( p_validate                     in     number   default hr_api.g_false_num
   ,p_period_frequency_id          in     number
   ,p_object_version_number        in out nocopy number
   ,p_api_warning                     out nocopy varchar2
   ,p_return_status                   out nocopy varchar2
  );
 end psp_period_frequency_swi;

 

/
