--------------------------------------------------------
--  DDL for Package IRC_NOTIFICATION_PREFS_BE3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_NOTIFICATION_PREFS_BE3" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 09:58:20
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure delete_notification_prefs_a (
p_notification_preference_id   number,
p_object_version_number        number);
end irc_notification_prefs_be3;

/
