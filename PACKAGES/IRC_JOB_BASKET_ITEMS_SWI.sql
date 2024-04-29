--------------------------------------------------------
--  DDL for Package IRC_JOB_BASKET_ITEMS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_JOB_BASKET_ITEMS_SWI" AUTHID CURRENT_USER As
/* $Header: irjbiswi.pkh 120.0 2005/07/26 15:13:38 mbocutt noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_job_basket_item >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_job_basket_items_api.create_job_basket_item
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
PROCEDURE create_job_basket_item
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_recruitment_activity_id      in     number
  ,p_person_id                    in     number
  ,p_job_basket_item_id           in     number
  ,p_object_version_number        out nocopy number
  ,p_return_status                out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< delete_job_basket_item >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_job_basket_items_api.delete_job_basket_item
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
PROCEDURE delete_job_basket_item
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_object_version_number        in     number
  ,p_job_basket_item_id           in     number
  ,p_return_status                out nocopy varchar2
  );
end irc_job_basket_items_swi;

 

/
