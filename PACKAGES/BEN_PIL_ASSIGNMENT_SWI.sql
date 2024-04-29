--------------------------------------------------------
--  DDL for Package BEN_PIL_ASSIGNMENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PIL_ASSIGNMENT_SWI" AUTHID CURRENT_USER As
/* $Header: bepsgswi.pkh 120.0 2006/03/23 10:05 mmillmor noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pil_assignment >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_pil_assignment_api.create_pil_assignment
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
PROCEDURE create_pil_assignment
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_pil_assignment_id               out nocopy number
  ,p_per_in_ler_id                in     number    default null
  ,p_applicant_assignment_id      in     number    default null
  ,p_offer_assignment_id          in     number    default null
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_pil_assignment >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_pil_assignment_api.delete_pil_assignment
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
PROCEDURE delete_pil_assignment
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_pil_assignment_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_pil_assignment_api.lck
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
PROCEDURE lck
  (p_pil_assignment_id            in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_pil_assignment >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ben_pil_assignment_api.update_pil_assignment
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
PROCEDURE update_pil_assignment
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_pil_assignment_id            in     number    default hr_api.g_number
  ,p_per_in_ler_id                in     number    default hr_api.g_number
  ,p_applicant_assignment_id      in     number    default hr_api.g_number
  ,p_offer_assignment_id          in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
 end ben_pil_assignment_swi;

 

/
