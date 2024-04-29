--------------------------------------------------------
--  DDL for Package HR_PERSON_BE2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_BE2" AUTHID CURRENT_USER as 
--Code generated on 30/08/2013 11:36:17
/* $Header: hrapiwfe.pkb 120.4.12010000.2 2008/09/29 12:54:07 srgnanas ship $*/
procedure delete_person_a (
p_effective_date               date,
p_person_id                    number,
p_person_org_manager_warning   varchar2);
end hr_person_be2;

/
