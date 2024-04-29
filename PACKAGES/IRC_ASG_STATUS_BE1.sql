--------------------------------------------------------
--  DDL for Package IRC_ASG_STATUS_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_ASG_STATUS_BE1" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:35:51
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_irc_asg_status_a (
p_assignment_id                number,
p_assignment_status_type_id    number,
p_status_change_reason         varchar2,
p_assignment_status_id         number,
p_object_version_number        number,
p_status_change_date           date,
p_status_change_comments       varchar2,
p_status_change_by             varchar2);
end irc_asg_status_be1;

/
