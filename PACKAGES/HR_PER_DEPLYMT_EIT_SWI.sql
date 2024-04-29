--------------------------------------------------------
--  DDL for Package HR_PER_DEPLYMT_EIT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PER_DEPLYMT_EIT_SWI" AUTHID CURRENT_USER As
/* $Header: hrpdeswi.pkh 120.0 2005/09/23 06:45 adhunter noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_per_deplymt_eit >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_per_deplymt_eit_api.create_per_deplymt_eit
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
PROCEDURE create_per_deplymt_eit
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_person_deployment_id         in     number
  ,p_person_extra_info_id         in     number
  ,p_per_deplymt_eit_id           in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_per_deplymt_eit >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_per_deplymt_eit_api.delete_per_deplymt_eit
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
PROCEDURE delete_per_deplymt_eit
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_per_deplymt_eit_id           in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end hr_per_deplymt_eit_swi;

 

/
