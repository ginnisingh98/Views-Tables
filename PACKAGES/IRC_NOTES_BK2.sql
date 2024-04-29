--------------------------------------------------------
--  DDL for Package IRC_NOTES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_NOTES_BK2" AUTHID CURRENT_USER as
/* $Header: irinoapi.pkh 120.3 2008/02/21 14:14:34 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_NOTE_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_NOTE_b
  (p_note_id                       in     number
  ,p_offer_status_history_id       in     number
  ,p_note_text                     in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_NOTE_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_NOTE_a
  (p_note_id                       in     number
  ,p_offer_status_history_id       in     number
  ,p_note_text                     in     varchar2
  ,p_object_version_number         in     number
  );
--
end IRC_NOTES_BK2;

/
