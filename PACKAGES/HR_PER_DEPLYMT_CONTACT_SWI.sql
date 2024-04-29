--------------------------------------------------------
--  DDL for Package HR_PER_DEPLYMT_CONTACT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PER_DEPLYMT_CONTACT_SWI" AUTHID CURRENT_USER As
/* $Header: hrpdcswi.pkh 120.0 2005/09/23 06:46 adhunter noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< create_per_deplymt_contact >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_per_deplymt_contact_api.create_per_deplymt_contact
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
PROCEDURE create_per_deplymt_contact
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_person_deployment_id         in     number
  ,p_contact_relationship_id      in     number
  ,p_per_deplymt_contact_id       in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_per_deplymt_contact >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_per_deplymt_contact_api.delete_per_deplymt_contact
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
PROCEDURE delete_per_deplymt_contact
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_per_deplymt_contact_id       in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end hr_per_deplymt_contact_swi;

 

/
