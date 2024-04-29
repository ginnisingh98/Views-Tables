--------------------------------------------------------
--  DDL for Package PSP_TEMPLATE_DETAILS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_TEMPLATE_DETAILS_SWI" AUTHID CURRENT_USER As
/* $Header: PSPRDSWS.pls 120.0 2005/06/02 15:47 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_template_details >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: psp_template_details_api.create_template_details
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
PROCEDURE create_template_details
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_template_id                  in     number
  ,p_criteria_lookup_type         in     varchar2
  ,p_criteria_lookup_code         in     varchar2
  ,p_include_exclude_flag         in     varchar2
  ,p_criteria_value1              in     varchar2
  ,p_criteria_value2              in     varchar2
  ,p_criteria_value3              in     varchar2
  ,p_template_detail_id           in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status_from_api          out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_template_details >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: psp_template_details_api.update_template_details
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
PROCEDURE update_template_details
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_template_id                  in     number
  ,p_criteria_lookup_type         in     varchar2
  ,p_criteria_lookup_code         in     varchar2
  ,p_include_exclude_flag         in     varchar2
  ,p_criteria_value1              in     varchar2
  ,p_criteria_value2              in     varchar2
  ,p_criteria_value3              in     varchar2
  ,p_template_detail_id           in out nocopy number
  ,p_object_version_number        in out nocopy number
  ,p_return_status_from_api          out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_template_details >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: psp_template_details_api.delete_template_details
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
PROCEDURE delete_template_details
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_template_detail_id           in     number
  ,p_object_version_number        in out nocopy number
  ,p_warning                         out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  );
 end psp_template_details_swi;

 

/
