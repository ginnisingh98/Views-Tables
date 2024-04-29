--------------------------------------------------------
--  DDL for Package HR_COMPETENCE_ELEMENT_BE5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COMPETENCE_ELEMENT_BE5" AUTHID CURRENT_USER as 
--Code generated on 04/01/2007 09:31:55
/* $Header: hrapiwfe.pkb 120.3 2006/06/20 10:26:28 sayyampe noship $*/
procedure maintain_student_comp_elemen_a (
p_person_id                    number,
p_competence_id                number,
p_proficiency_level_id         number,
p_business_group_id            number,
p_effective_date_from          date,
p_effective_date_to            date,
p_certification_date           date,
p_certification_method         varchar2,
p_next_certification_date      date,
p_source_of_proficiency_level  varchar2,
p_comments                     varchar2,
p_effective_date               date,
p_competence_created           number);
end hr_competence_element_be5;

 

/
