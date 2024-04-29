--------------------------------------------------------
--  DDL for Package IRC_SAVED_SEARCH_CRITERIA_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_SAVED_SEARCH_CRITERIA_BE2" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 09:58:20
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_search_criteria_a (
p_vacancy_id                   number,
p_saved_search_criteria_id     number,
p_object_version_number        number);
end irc_saved_search_criteria_be2;

/
