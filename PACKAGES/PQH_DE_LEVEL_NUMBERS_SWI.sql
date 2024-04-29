--------------------------------------------------------
--  DDL for Package PQH_DE_LEVEL_NUMBERS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_LEVEL_NUMBERS_SWI" AUTHID CURRENT_USER As
/* $Header: pqgvnswi.pkh 115.1 2002/11/27 23:44:04 rpasapul noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_level_numbers >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_level_numbers_api.delete_level_numbers
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
PROCEDURE delete_level_numbers
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_level_number_id              in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< insert_level_numbers >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_level_numbers_api.insert_level_numbers
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
PROCEDURE insert_level_numbers
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_level_number                 in     varchar2
  ,p_description                  in     varchar2
  ,p_level_number_id                 out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_level_numbers >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_level_numbers_api.update_level_numbers
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
PROCEDURE update_level_numbers
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_level_number                 in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_level_number_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end pqh_de_level_numbers_swi;

 

/
