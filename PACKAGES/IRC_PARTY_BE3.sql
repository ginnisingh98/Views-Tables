--------------------------------------------------------
--  DDL for Package IRC_PARTY_BE3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PARTY_BE3" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:35:52
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure registered_user_application_a (
p_effective_date               date,
p_person_id                    number,
p_applicant_number             varchar2,
p_application_received_date    date,
p_vacancy_id                   number,
p_posting_content_id           number,
p_assignment_id                number,
p_asg_object_version_number    number);
end irc_party_be3;

/
