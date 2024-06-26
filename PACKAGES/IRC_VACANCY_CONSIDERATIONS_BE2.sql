--------------------------------------------------------
--  DDL for Package IRC_VACANCY_CONSIDERATIONS_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_VACANCY_CONSIDERATIONS_BE2" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:35:52
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_vacancy_consideration_a (
p_vacancy_consideration_id     number,
p_party_id                     number,
p_consideration_status         varchar2,
p_object_version_number        number,
p_effective_date               date);
end irc_vacancy_considerations_be2;

/
