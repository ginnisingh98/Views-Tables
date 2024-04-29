--------------------------------------------------------
--  DDL for Package IRC_NOTES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_NOTES_BK3" AUTHID CURRENT_USER as
/* $Header: irinoapi.pkh 120.3 2008/02/21 14:14:34 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_NOTE_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_NOTE_b
  (p_note_id                       in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_NOTE_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_NOTE_a
  (p_note_id                       in     number
  ,p_object_version_number         in     number
  );
--
end IRC_NOTES_BK3;

/
