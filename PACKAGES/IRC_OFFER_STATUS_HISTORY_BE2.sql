--------------------------------------------------------
--  DDL for Package IRC_OFFER_STATUS_HISTORY_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_OFFER_STATUS_HISTORY_BE2" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 09:58:20
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_offer_status_history_a (
p_effective_date               date,
p_offer_status_history_id      number,
p_status_change_date           date,
p_change_reason                varchar2,
p_decline_reason               varchar2,
p_note_text                    varchar2,
p_object_version_number        number);
end irc_offer_status_history_be2;

/
