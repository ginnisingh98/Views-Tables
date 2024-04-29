--------------------------------------------------------
--  DDL for Package HR_APPLICANT_BE4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPLICANT_BE4" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:36:18
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure convert_to_applicant_a (
p_effective_date               date,
p_person_id                    number,
p_business_group_id            number,
p_object_version_number        number,
p_applicant_number             varchar2,
p_person_type_id               number,
p_effective_start_date         date,
p_effective_end_date           date,
p_appl_override_warning        boolean);
end hr_applicant_be4;

/
