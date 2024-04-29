--------------------------------------------------------
--  DDL for Package PER_RI_CONFIGURATION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_CONFIGURATION_SWI" AUTHID CURRENT_USER As
/* $Header: pecnfswi.pkh 120.0 2005/05/31 06:47 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_configuration >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_ri_configuration_api.create_configuration
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
PROCEDURE create_configuration
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_configuration_code           in     varchar2
  ,p_configuration_type           in     varchar2
  ,p_configuration_status         in     varchar2
  ,p_configuration_name           in     varchar2
  ,p_configuration_description    in     varchar2
  ,p_language_code                in     varchar2  default null
  ,p_effective_date               in     date
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_configuration >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_ri_configuration_api.update_configuration
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
PROCEDURE update_configuration
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_configuration_code           in     varchar2
  ,p_configuration_type           in     varchar2  default hr_api.g_varchar2
  ,p_configuration_status         in     varchar2  default hr_api.g_varchar2
  ,p_configuration_name           in     varchar2  default hr_api.g_varchar2
  ,p_configuration_description    in     varchar2  default hr_api.g_varchar2
  ,p_language_code                in     varchar2  default hr_api.g_varchar2
  ,p_effective_date               in     date
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_configuration >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_ri_configuration_api.delete_configuration
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
PROCEDURE delete_configuration
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_configuration_code           in     varchar2
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end per_ri_configuration_swi;

 

/
