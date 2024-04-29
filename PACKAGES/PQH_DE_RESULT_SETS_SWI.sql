--------------------------------------------------------
--  DDL for Package PQH_DE_RESULT_SETS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_RESULT_SETS_SWI" AUTHID CURRENT_USER As
/* $Header: pqrssswi.pkh 115.2 2002/12/03 20:43:27 rpasapul noship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_result_sets >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_result_sets_api.delete_result_sets
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
PROCEDURE delete_result_sets
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_result_set_id                in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< insert_result_sets >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_result_sets_api.insert_result_sets
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
PROCEDURE insert_result_sets
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_gradual_value_number_from    in     number
  ,p_gradual_value_number_to      in     number
  ,p_grade_id                     in     number
  ,p_result_set_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< update_result_sets >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pqh_de_result_sets_api.update_result_sets
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
PROCEDURE update_result_sets
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_result_set_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_gradual_value_number_from    in     number    default hr_api.g_number
  ,p_gradual_value_number_to      in     number    default hr_api.g_number
  ,p_grade_id                     in     number    default hr_api.g_number
  ,p_return_status                   out nocopy varchar2
  );
end pqh_de_result_sets_swi;

 

/
