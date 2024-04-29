--------------------------------------------------------
--  DDL for Package IRC_PENDING_DATA_BE1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PENDING_DATA_BE1" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 09:58:18
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure create_pending_data_a (
p_email_address                varchar2,
p_last_name                    varchar2,
p_vacancy_id                   number,
p_first_name                   varchar2,
p_user_password                varchar2,
p_resume_file_name             varchar2,
p_resume_description           varchar2,
p_resume_mime_type             varchar2,
p_source_type                  varchar2,
p_job_post_source_name         varchar2,
p_posting_content_id           number,
p_person_id                    number,
p_processed                    varchar2,
p_sex                          varchar2,
p_date_of_birth                date,
p_per_information_category     varchar2,
p_per_information1             varchar2,
p_per_information2             varchar2,
p_per_information3             varchar2,
p_per_information4             varchar2,
p_per_information5             varchar2,
p_per_information6             varchar2,
p_per_information7             varchar2,
p_per_information8             varchar2,
p_per_information9             varchar2,
p_per_information10            varchar2,
p_per_information11            varchar2,
p_per_information12            varchar2,
p_per_information13            varchar2,
p_per_information14            varchar2,
p_per_information15            varchar2,
p_per_information16            varchar2,
p_per_information17            varchar2,
p_per_information18            varchar2,
p_per_information19            varchar2,
p_per_information20            varchar2,
p_per_information21            varchar2,
p_per_information22            varchar2,
p_per_information23            varchar2,
p_per_information24            varchar2,
p_per_information25            varchar2,
p_per_information26            varchar2,
p_per_information27            varchar2,
p_per_information28            varchar2,
p_per_information29            varchar2,
p_per_information30            varchar2,
p_error_message                varchar2,
p_creation_date                date,
p_last_update_date             date,
p_allow_access                 varchar2,
p_visitor_resp_key             varchar2,
p_visitor_resp_appl_id         number,
p_security_group_key           varchar2);
end irc_pending_data_be1;

/
