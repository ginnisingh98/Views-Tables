--------------------------------------------------------
--  DDL for Package IRC_ASSIGNMENT_DETAILS_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_ASSIGNMENT_DETAILS_BE1" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:35:51
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_assignment_details_a (
p_effective_date               date,
p_assignment_details_id        number,
p_assignment_id                number,
p_attempt_id                   number,
p_details_version              number,
p_latest_details               varchar2,
p_effective_start_date         date,
p_effective_end_date           date,
p_object_version_number        number,
p_qualified                    varchar2,
p_considered                   varchar2);
end irc_assignment_details_be1;

/
