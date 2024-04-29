--------------------------------------------------------
--  DDL for Package HR_BE_EXTRA_PERSON_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_BE_EXTRA_PERSON_RULES" AUTHID CURRENT_USER AS
/* $Header: pebeexpr.pkh 120.0.12010000.1 2008/07/28 04:14:47 appldev ship $ */
--
procedure extra_language_checks
(p_person_type_id          in number
,p_correspondence_language in varchar2);
--
procedure extra_person_checks
(p_region_of_birth in varchar2);
--
procedure extra_assignment_checks
(p_employee_category in varchar2);
--
END HR_BE_EXTRA_PERSON_RULES;

/
