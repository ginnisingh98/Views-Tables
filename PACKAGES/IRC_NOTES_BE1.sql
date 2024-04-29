--------------------------------------------------------
--  DDL for Package IRC_NOTES_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_NOTES_BE1" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 09:58:18
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_note_a (
p_note_id                      number,
p_offer_status_history_id      number,
p_note_text                    varchar2,
p_object_version_number        number);
end irc_notes_be1;

/
