--------------------------------------------------------
--  DDL for Package HR_KI_OPTIONS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_OPTIONS_SWI" AUTHID CURRENT_USER As
/* $Header: hroptswi.pkh 115.0 2004/01/09 02:36 vkarandi noship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_option >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_ki_options_api.create_option
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
PROCEDURE create_option
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_option_type_id               in     number
  ,p_option_level                 in     number
  ,p_option_level_id              in     varchar2  default null
  ,p_value                        in     varchar2  default null
  ,p_encrypted                    in     varchar2  default 'N'
  ,p_integration_id               in     number
  ,p_option_id                    in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_option >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_ki_options_api.delete_option
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
PROCEDURE delete_option
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_option_id                    in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_option >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_ki_options_api.update_option
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
PROCEDURE update_option
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_option_id                    in     number
  ,p_value                        in     varchar2  default hr_api.g_varchar2
  ,p_encrypted                    in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end hr_ki_options_swi;

 

/
