--------------------------------------------------------
--  DDL for Package PER_POS_STRUCTURE_VERSION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_POS_STRUCTURE_VERSION_SWI" AUTHID CURRENT_USER As
/* $Header: pepsvswi.pkh 115.3 2002/12/05 09:56:03 eumenyio noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------< create_pos_structure_version >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_pos_structure_version_api.create_pos_structure_version
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
PROCEDURE create_pos_structure_version
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_position_structure_id        in     number
  ,p_date_from                    in     date
  ,p_version_number               in     number
  ,p_copy_structure_version_id    in     number    default null
  ,p_date_to                      in     date      default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_pos_structure_version_id        out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< delete_pos_structure_version >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_pos_structure_version_api.delete_pos_structure_version
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
PROCEDURE delete_pos_structure_version
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_pos_structure_version_id     in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< update_pos_structure_version >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_pos_structure_version_api.update_pos_structure_version
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
PROCEDURE update_pos_structure_version
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_date_from                    in     date
  ,p_version_number               in     number
  ,p_copy_structure_version_id    in     number    default hr_api.g_number
  ,p_date_to                      in     date      default hr_api.g_date
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_pos_structure_version_id     in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end per_pos_structure_version_swi;

 

/
