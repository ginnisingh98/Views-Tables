--------------------------------------------------------
--  DDL for Package HR_NAME_FORMAT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NAME_FORMAT_SWI" AUTHID CURRENT_USER As
/* $Header: hrnmfswi.pkh 120.0 2005/05/31 01:35 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< create_name_format >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_name_format_api.create_name_format
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
PROCEDURE create_name_format
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_format_name                  in     varchar2
  ,p_user_format_choice           in     varchar2
  ,p_format_mask                  in     varchar2
  ,p_legislation_code             in     varchar2
  ,p_name_format_id               in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< update_name_format >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_name_format_api.update_name_format
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
PROCEDURE update_name_format
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_name_format_id               in     number
  ,p_format_mask                  in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_name_format >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_name_format_api.delete_name_format
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
PROCEDURE delete_name_format
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_name_format_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
 end hr_name_format_swi;

 

/
