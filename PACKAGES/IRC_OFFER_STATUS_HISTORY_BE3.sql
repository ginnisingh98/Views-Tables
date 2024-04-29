--------------------------------------------------------
--  DDL for Package IRC_OFFER_STATUS_HISTORY_BE3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_OFFER_STATUS_HISTORY_BE3" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 09:58:20
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure delete_offer_status_history_a (
p_object_version_number        number,
p_offer_status_history_id      number);
end irc_offer_status_history_be3;

/
