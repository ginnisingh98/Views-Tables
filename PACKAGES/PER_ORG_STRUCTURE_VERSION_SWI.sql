--------------------------------------------------------
--  DDL for Package PER_ORG_STRUCTURE_VERSION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ORG_STRUCTURE_VERSION_SWI" AUTHID CURRENT_USER As
/* $Header: peosvswi.pkh 115.1 2002/12/03 01:27:50 ndorai noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------< create_org_structure_version >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_org_structure_version_api.create_org_structure_version
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
PROCEDURE create_org_structure_version
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_organization_structure_id    in     number
  ,p_date_from                    in     date
  ,p_version_number               in     number
  ,p_copy_structure_version_id    in     number    default null
  ,p_date_to                      in     date      default null
  ,p_request_id                   in     number    default null
  ,p_program_application_id       in     number    default null
  ,p_program_id                   in     number    default null
  ,p_program_update_date          in     date      default null
  ,p_topnode_pos_ctrl_enabled_fla in     varchar2  default null
  ,p_org_structure_version_id        out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< delete_org_structure_version >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_org_structure_version_api.delete_org_structure_version
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
PROCEDURE delete_org_structure_version
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_org_structure_version_id     in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |---------------------< update_org_structure_version >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: per_org_structure_version_api.update_org_structure_version
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
PROCEDURE update_org_structure_version
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
  ,p_topnode_pos_ctrl_enabled_fla in     varchar2  default hr_api.g_varchar2
  ,p_org_structure_version_id     in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
end per_org_structure_version_swi;

 

/
