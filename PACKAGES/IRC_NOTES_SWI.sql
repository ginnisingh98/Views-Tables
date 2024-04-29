--------------------------------------------------------
--  DDL for Package IRC_NOTES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_NOTES_SWI" AUTHID CURRENT_USER As
/* $Header: irinoswi.pkh 120.0 2005/09/27 09:09 sayyampe noship $ */
-- ----------------------------------------------------------------------------
-- |------------------------------< create_note >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_notes_api.create_note
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
PROCEDURE create_note
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_offer_status_history_id      in     number
  ,p_note_text                    in     varchar2
  ,p_note_id                      in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------------< update_note >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_notes_api.update_note
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
PROCEDURE update_note
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_note_id                      in     number
  ,p_offer_status_history_id      in     number    default hr_api.g_number
  ,p_note_text                    in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_note >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_notes_api.delete_note
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
PROCEDURE delete_note
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_note_id                      in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
 end irc_notes_swi;

 

/
