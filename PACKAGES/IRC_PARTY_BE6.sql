--------------------------------------------------------
--  DDL for Package IRC_PARTY_BE6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PARTY_BE6" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:35:53
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure self_register_user_a (
p_current_email_address        varchar2,
p_responsibility_id            number,
p_resp_appl_id                 number,
p_security_group_id            number,
p_first_name                   varchar2,
p_last_name                    varchar2,
p_middle_names                 varchar2,
p_previous_last_name           varchar2,
p_employee_number              varchar2,
p_national_identifier          varchar2,
p_date_of_birth                date,
p_email_address                varchar2,
p_home_phone_number            varchar2,
p_work_phone_number            varchar2,
p_address_line_1               varchar2,
p_manager_last_name            varchar2,
p_allow_access                 varchar2,
p_language                     varchar2,
p_user_name                    varchar2);
end irc_party_be6;

/
