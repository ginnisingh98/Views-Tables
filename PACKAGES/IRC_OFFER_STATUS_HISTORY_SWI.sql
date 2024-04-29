--------------------------------------------------------
--  DDL for Package IRC_OFFER_STATUS_HISTORY_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_OFFER_STATUS_HISTORY_SWI" AUTHID CURRENT_USER As
/* $Header: iriosswi.pkh 120.4 2005/10/01 12:00 mmillmor noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< create_offer_status_history >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_offer_status_history_api.create_offer_status_history
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
PROCEDURE create_offer_status_history
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default null
  ,p_offer_id                     in     number
  ,p_status_change_date           in     date
  ,p_offer_status                 in     varchar2
  ,p_change_reason                in     varchar2  default null
  ,p_decline_reason               in     varchar2  default null
  ,p_note_text                    in     varchar2  default null
  ,p_offer_status_history_id      in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< update_offer_status_history >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_offer_status_history_api.update_offer_status_history
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
PROCEDURE update_offer_status_history
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_offer_status_history_id      in     number
  ,p_offer_id                     in     number
  ,p_status_change_date           in     date      default hr_api.g_date
  ,p_offer_status                 in     varchar2
  ,p_change_reason                in     varchar2  default hr_api.g_varchar2
  ,p_decline_reason               in     varchar2  default hr_api.g_varchar2
  ,p_note_text                    in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |----------------------< delete_offer_status_history >---------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_offer_status_history_api.delete_offer_status_history
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
PROCEDURE delete_offer_status_history
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_offer_id                     in     number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  );
 end irc_offer_status_history_swi;

 

/
