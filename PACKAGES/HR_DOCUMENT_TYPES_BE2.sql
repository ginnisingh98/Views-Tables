--------------------------------------------------------
--  DDL for Package HR_DOCUMENT_TYPES_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DOCUMENT_TYPES_BE2" AUTHID CURRENT_USER as 
--Code generated on 29/08/2013 10:00:52
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure update_document_type_a (
p_document_type_id             number,
p_effective_date               date,
p_document_type                varchar2,
p_language_code                varchar2,
p_description                  varchar2,
p_category_code                varchar2,
p_active_inactive_flag         varchar2,
p_multiple_occurences_flag     varchar2,
p_authorization_required       varchar2,
p_sub_category_code            varchar2,
p_legislation_code             varchar2,
p_warning_period               number,
p_request_id                   number,
p_program_application_id       number,
p_program_id                   number,
p_program_update_date          date,
p_object_version_number        number);
end hr_document_types_be2;

/
