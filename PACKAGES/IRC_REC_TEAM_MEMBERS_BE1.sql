--------------------------------------------------------
--  DDL for Package IRC_REC_TEAM_MEMBERS_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_REC_TEAM_MEMBERS_BE1" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 09:58:19
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_rec_team_member_a (
p_rec_team_member_id           number,
p_person_id                    number,
p_vacancy_id                   number,
p_job_id                       number,
p_start_date                   date,
p_end_date                     date,
p_update_allowed               varchar2,
p_delete_allowed               varchar2,
p_object_version_number        number,
p_interview_security           varchar2);
end irc_rec_team_members_be1;

/
